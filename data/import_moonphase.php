<?php
$year = '2015';
require "../db.inc.php";
$base->set_date_arg_format ('%Y-%m-%d');

exec ('(cd SunMoon && ./moonphase '.$year.' 47000 2000 > ../moonphases.csv)');

exec ('(cd SunMoon && ./moonphase4 '.$year.' 47000 2000 > ../moon4.csv)');

$f = fopen ('moonphases.csv', 'r');  
while ( ($line = fgetcsv ($f, 0, "\t")) !== FALSE) {
  $base->geoname_calendar_set_moonphase ($line[0], $line[1]);
  //  exit;
}

fclose ($f);

$f = fopen ('moon4.csv', 'r');  
while ( ($line = fgetcsv ($f, 0, " ")) !== FALSE) {
  $base->geoname_calendar_set_moon4 ($line[0], $line[1]/25*7);
  //  exit;
}
