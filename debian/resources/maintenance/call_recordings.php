<?php
/*

Call Recordings Maintenance
- Convert WAV to MP3
  - Reduce the file size
- Move recordings
  - Move the recording from the source to a destination directory.

At the top of the file need to define or set the destination_directory...

In my case I put the file in /usr/src and then run manually like this.
/usr/bin/php /usr/src/fusionpbx-install.sh/debian/resources/maintenance/call_recordings.php

Debian
crontab -e
0 * * * * /usr/bin/php /usr/src/fusionpbx-install.sh/debian/resources/maintenance/call_recordings.php > /dev/null 2>&1

*/

//add the document root to the included path
	if (defined('STDIN')) {
		$config_glob = glob("{/usr/local/etc,/etc}/fusionpbx/config.conf", GLOB_BRACE);
		$conf = parse_ini_file($config_glob[0]);
		set_include_path($conf['document.root']);
	}
	else {
		exit;
	}

//set pre-defined variables
	$debug = true;
	$action = 'convert'; //convert, move or both
	$audio_format = 'wav';
	$preferred_command = 'lame'; //mpg123, lame

//includes files
	require_once "resources/require.php";

//create the database connection
	$database = new database;

//use settings object instead of session
	$settings = new settings(['database' => $database]);

//set the source and destination paths
	$source_path = $settings->get('switch','recordings', '');

//set the destination_path
	if ($action == 'move' || $action == 'both') {
		$destination_path = $settings->get('call_recordings','destination_path', null);
	}

//make sure the directory exists
	if ($action == 'move' || $action == 'both') {
		system('mkdir -p '.$destination_path);
	}

//get the xml cdr call recordings.
	$sql = "select xml_cdr_uuid, domain_uuid, domain_name, ";
	$sql .= "record_path, record_name, direction, start_stamp, ";
	$sql .= "caller_id_name, caller_id_number from v_xml_cdr ";
	//$sql .= "where start_stamp > NOW() - INTERVAL '7 days' ";
	$sql .= "where true ";
	if ($action == 'convert' || $action == 'both') {
		$sql .= "and record_name like '%.wav' ";
	}
	if ($action == 'move' || $action == 'both') {
		$sql .= "and length(record_path) > 0 ";
		$sql .= "and substr(record_path, 1, length(:source_path)) = :source_path ";
		$parameters['source_path'] = $source_path;
	}
	$sql .= "order by start_stamp desc ";
	if ($debug) { echo $sql."\n"; }
	$call_recordings = $database->select($sql, $parameters, 'all');
	unset($parameters);

//process the changes
	foreach ($call_recordings as $row) {

		//set the record_name
		$record_name = $row['record_name'];

		//set the source_path
		$source_path = realpath($row['record_path']);

		//get the file name without the file extension
		$path_parts = pathinfo($source_path.'/'.$record_name);

		//convert the audio file from wav to mp3
		if ($action == 'convert' || $action == 'both') {

			if ($debug) {
				if (!file_exists($source_path."/".$record_name)) {
					//echo "file not found: ".$source_path."/".$record_name."\n";
				}
				else {
					echo "found file: ".$source_path."/".$record_name."\n";
				}
			}
			if (file_exists($source_path."/".$record_name)) {
				//build the run the mpg123 command
				if ($preferred_command == 'mpg123' && !file_exists($source_path."/".$path_parts['filename'].".mp3")) {
					$command = "mpg123 -w ".$source_path."/".$record_name." ".$source_path."/".$path_parts['filename'].".mp3\n";
					if ($debug) { echo $command."\n"; }
					system($command);
				}

				//build the run the mpg123 command
				if ($preferred_command == 'lame' && !file_exists($source_path."/".$path_parts['filename'].".mp3")) {
					$command = "lame -b 128 ".$source_path."/".$record_name." ".$source_path."/".$path_parts['filename'].".mp3\n";
					if ($debug) { echo $command."\n"; }
					system($command);
				}

				//update the record name to use the new file extension
				if (file_exists($source_path."/".$path_parts['filename'].".mp3")) {
					//make sure the mp3 file exists and then delete the wav file 
					unlink($source_path."/".$path_parts['filename'].".wav");

					//set the record_name with the new file extension
					$record_name = $path_parts['filename'].".mp3";
				}
			}
		}

		//move the files
		if ($action == 'move' || $action == 'both') {
			//get break down the date to year, month and day
			$start_time = strtotime($row['start_stamp']);
			$start_year = date("Y", $start_time);
			$start_month = date("M", $start_time);
			$start_day = date("d", $start_time);

			//move the recording from the old to the new directory
			$old_path = realpath($row['record_path']);
			$new_path = realpath($destination_path).'/'.$row['domain_name'].'/archive/'.$start_year.'/'.$start_month.'/'.$start_day;
			if (!file_exists($new_path)) { system('mkdir -p '.$new_path); }
			$command = "mv ".$old_path."/".$record_name." ".$new_path."/".$record_name;
			if ($debug) { echo $command."\n"; }
			system($command);
		}

		//update the database to the new directory
		$sql = "update v_xml_cdr set \n";
		if ($action == 'move' || $action == 'both') {
			$sql .= "record_path = '".$new_path."' \n";
		}
		if ($action == 'convert' || $action == 'both') {
			$sql .= "record_name = '".$path_parts['filename'].".mp3'\n";
		}
		$sql .= "where xml_cdr_uuid = '".$row['xml_cdr_uuid']."';\n";
		if ($debug) { echo $sql."\n"; }
		$database->execute($sql);

	}

?>
