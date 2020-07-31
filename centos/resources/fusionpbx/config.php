<?php
/*
	FusionPBX
	Version: MPL 1.1

	The contents of this file are subject to the Mozilla Public License Version
	1.1 (the "License"); you may not use this file except in compliance with
	the License. You may obtain a copy of the License at
	http://www.mozilla.org/MPL/

	Software distributed under the License is distributed on an "AS IS" basis,
	WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
	for the specific language governing rights and limitations under the
	License.

	The Original Code is FusionPBX

	The Initial Developer of the Original Code is
	Mark J Crane <markjcrane@fusionpbx.com>
	Portions created by the Initial Developer are Copyright (C) 2008-2016
	the Initial Developer. All Rights Reserved.

	Contributor(s):
	Mark J Crane <markjcrane@fusionpbx.com>
*/

//set the database type
	$db_type = 'pgsql'; //sqlite, mysql, pgsql, others with a manually created PDO connection

//sqlite: the db_name and db_path are automatically assigned however the values can be overidden by setting the values here.
	//$db_name = 'fusionpbx.db'; //host name/ip address + '.db' is the default database filename
	//$db_path = '/var/www/fusionpbx/secure'; //the path is determined by a php variable

//pgsql: database connection information
	$db_host = '{database_host}';
	$db_port = '5432';
	$db_name = 'fusionpbx';
	$db_username = '{database_username}';
	$db_password = '{database_password}';

//show errors
	ini_set('display_errors', '1');
	//error_reporting (E_ALL); // Report everything
	//error_reporting (E_ALL ^ E_NOTICE); // hide notices
	error_reporting(E_ALL ^ E_NOTICE ^ E_WARNING ); //hide notices and warnings
