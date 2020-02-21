<?php
$CONFIG = array(
  'datadirectory' => '/media/owncloud/data',
  'apps_paths' => array (
    0 => array (
      'path' => '/usr/share/webapps/nextcloud/apps',
      'url' => '/apps',
      'writable' => false,
    ),
    1 => array (
      'path' => '/media/owncloud/apps',
      'url' => '/apps2',
      'writable' => true,
    ),
  ),
  'dbname' => 'owncloud',
  'dbhost' => 'localhost',
  'dbuser' => 'owncloud',
  'installed' => false,
  'loglevel' => '3',
  'logfile' => '/media/owncloud/logs/owncloud/owncloud.log',
  'appstoreenabled' => true,
  'appstoreurl' => 'http://api.apps.owncloud.com/v1',  
);
