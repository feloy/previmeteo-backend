<?php
$year = '2015';
require "../db.inc.php";
$base->set_timestamp_arg_format ('%Y-%m-%d %H:%M');

$geos = $base->geoname_geoname_list (3);
foreach ($geos as $geo) {
  //  if ($geo['geo_name'] != 'Paris')
  //    continue;
  exec ('(cd SunMoon && ./tables '.$year.' '.(1000*$geo['geo_lat']).' '.(1000*$geo['geo_lng']).' > ../ephemeris/'.$geo['geo_id'].'.csv)');

  $f = fopen ('ephemeris/'.$geo['geo_id'].'.csv', 'r');  
  while ( ($line = fgetcsv ($f, 0, "\t")) !== FALSE) {
    $planet = ($line[1] == 'sun');
    $event = ($line[2] == 'rise');
    $base->ephemeris_add ($geo['geo_id'], $line[0], $planet, $event);
    //    exit;
  }
  //  exit;
}