<?php
/*

Call Recordings Maintenance
- Convert WAV to MP3
  - Reduce the file size
- Move recordings
  - Move the recording from the source to a destination directory.
  - To move files, you will need to add the destination_path as a setting under category: call_recordings

In my case, I put the file in /usr/src and then run manually like this.
cd /usr/src/fusionpbx-install.sh
git stash
git pull
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
	$action_name = 'convert'; //convert, move or both
	$action_delay = ''; //number of days before running the action, default empty which means no delay
	$audio_format = 'wav';
	$preferred_command = 'lame'; //mpg123, lame, sox

//includes files
	require_once "resources/require.php";

//create the database connection
	$database = new database;

//use settings object instead of session
	$settings = new settings(['database' => $database]);

//set the source and destination paths
	$source_path = $settings->get('switch','recordings', '');

//set the destination_path
	if ($action_name == 'move' || $action_name == 'both') {
		$destination_path = $settings->get('call_recordings','destination_path', null);
	}

//make sure the directory exists
	if ($action_name == 'move' || $action_name == 'both') {
		system('mkdir -p '.$destination_path);
	}

//get the XML CDR call recordings.
	$sql = "select xml_cdr_uuid, domain_uuid, domain_name, ";
	$sql .= "record_path, record_name, direction, start_stamp, ";
	$sql .= "caller_id_name, caller_id_number from v_xml_cdr ";
	//$sql .= "where start_stamp > NOW() - INTERVAL '7 days' ";
	$sql .= "where true ";
	if ($action_name == 'convert' || $action_name == 'both') {
		$sql .= "and record_name like '%.wav' ";
	}
	if ($action_name == 'move' || $action_name == 'both') {
		$sql .= "and length(record_path) > 0 ";
		$sql .= "and substr(record_path, 1, length(:source_path)) = :source_path ";
		
		$parameters['source_path'] = $source_path;
	}
	if (!empty($action_delay) && is_numeric($action_delay)) {
		$sql .= "and start_stamp < NOW() - INTERVAL '".$action_delay." days' ";
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

		//convert the audio file from WAV to MP3
		if ($action_name == 'convert' || $action_name == 'both') {

			if ($debug) {
				if (!file_exists($source_path."/".$record_name)) {
					//echo "file not found: ".$source_path."/".$record_name."\n";
				}
				else {
					echo "found file: ".$source_path."/".$record_name."\n";
				}
			}
			if (file_exists($source_path."/".$record_name)) {
				//build the sox command
				if ($preferred_command == 'sox' && !file_exists($source_path."/".$path_parts['filename'].".mp3")) {
					$command = "sox ".$source_path."/".$record_name." -C 128 ".$source_path."/".$path_parts['filename'].".mp3 \n";
				}

				//build and run the mpg123 command
				if ($preferred_command == 'mpg123' && !file_exists($source_path."/".$path_parts['filename'].".mp3")) {
					$command = "mpg123 -w ".$source_path."/".$record_name." ".$source_path."/".$path_parts['filename'].".mp3\n";
				}

				//build and run the mpg123 command
				if ($preferred_command == 'lame' && !file_exists($source_path."/".$path_parts['filename'].".mp3")) {
					$command = "lame -b 128 ".$source_path."/".$record_name." ".$source_path."/".$path_parts['filename'].".mp3\n";
				}

				//show debug information
				if ($debug) { 
					echo $command."\n";
				}

				//run the command
				if (!empty($command)) {
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
		if ($action_name == 'move' || $action_name == 'both') {
			//get breakdown of the date to year, month, and day
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
		if ($action_name == 'move' || $action_name == 'both') {
			$sql .= "record_path = '".$new_path."' \n";
		}
		if ($action_name == 'convert' || $action_name == 'both') {
			$sql .= "record_name = '".$path_parts['filename'].".mp3'\n";
		}
		$sql .= "where xml_cdr_uuid = '".$row['xml_cdr_uuid']."';\n";
		if ($debug) { echo $sql."\n"; }
		$database->execute($sql);

	}

?>
