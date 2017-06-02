<?php
require "../db.inc.php";

$filename = 'FR_geonames.txt';
$f = fopen ($filename, 'r');
while (($data = fgetcsv($f, 0, "\t")) !== FALSE) {
  if ($data[6] != 'P')
    continue;
  $geo_feature_code = $data[7];
  if (!in_array ($geo_feature_code, array ('PPLC',
					   'PPLA',
					   'PPLA2',
					   'PPLA3',
					   'PPL')))
    continue;
  $geo_name = $data[1];
  /*  if ($geo_feature_code == 'ADM3') {
    $geo_name = str_replace ("Arrondissement de ", "", $geo_name);
    $geo_name = str_replace ("Arrondissement of ", "", $geo_name);
    $geo_name = str_replace ("Arrondissement d'", "", $geo_name);
    $geo_name = str_replace ("Arrondissement de L'", "", $geo_name);
    $geo_name = str_replace ("Arrondissement du ", "Le ", $geo_name);
    $geo_name = str_replace ("Arrondissement des ", "Les ", $geo_name);
    }*/
  $base->geoname_geoname_add ($data[0], // geo_id
			      $geo_name, // geo_name
			      $data[4], // geo_lat,
			      $data[5], // geo_lat,
			      $data[6], // geo_feature_class,
			      $geo_feature_code,
			      $data[10], // geo_adm1,
			      $data[11], // geo_adm2,
			      $data[12], // geo_adm3,
			      $data[13], // geo_adm4,
			      $data[14], // geo_population,
			      $data[16], // geo_elevation,
			      $data[17], // geo_timezone,
			      $data[18]); // geo_modification,
			      
  //  exit;
}
/*
Array
(
    [0] => 1024032
    [1] => Île Glorieuse
    [2] => Ile Glorieuse
    [3] => Glorieuse,Ile Glorieuse,Île Glorieuse
    [4] => -11.55
    [5] => 47.3
    [6] => T
    [7] => ISL
    [8] => FR
    [9] => 
    [10] => 00
    [11] => 
    [12] => 
    [13] => 
    [14] => 0
    [15] => 
    [16] => -9999
    [17] => Europe/Paris
    [18] => 2012-01-18
 )
*/