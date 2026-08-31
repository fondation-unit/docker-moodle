<?php  // Moodle configuration file

unset($CFG);
global $CFG;
$CFG = new stdClass();

$CFG->dbtype    = 'mariadb';
$CFG->dblibrary = 'native';
$CFG->dbhost    = 'db';
$CFG->dbname    = getenv('MARIADB_DATABASE');
$CFG->dbuser    = getenv('MARIADB_USER');
$CFG->dbpass    = getenv('MARIADB_PASSWORD');
$CFG->prefix    = 'mdl_';
$CFG->dboptions = array(
  'dbcollation' => 'utf8mb4_unicode_ci',
);

$CFG->wwwroot   = 'https://' . getenv('DOMAIN_NAME');
$CFG->dataroot  = '/var/moodledata';
$CFG->directorypermissions = 0777;

$CFG->routerconfigured = true;

$CFG->behat_dataroot = '/var/www/behat_moodledata';
$CFG->behat_prefix = 'bht_';
$CFG->behat_wwwroot = 'http://moodle-behat.local';
$CFG->behat_config = [
  'default' => [
    'extensions' => [
      'Behat\MinkExtension' => [
        'selenium2' => [
          'wd_host' => 'http://selenium:4444/wd/hub',
          'capabilities' => [
            'browser' => 'firefox',
          ],
        ],
      ],
    ],
  ],
];

// DEBUG
@error_reporting(E_ALL); // NOT FOR PRODUCTION SERVERS!
@ini_set('display_errors', '1');    // NOT FOR PRODUCTION SERVERS!
$CFG->debugdisplay = 1;

require_once(__DIR__ . '/lib/setup.php');

// There is no php closing tag in this file,
// it is intentional because it prevents trailing whitespace problems!