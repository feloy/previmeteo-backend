<?php
require "../db.inc.php";

$filename = 'FR.txt';
$f = fopen ($filename, 'r');
while (($data = fgetcsv($f, 0, "\t")) !== FALSE) {
  //  print_r ($data);
  $adm3 = $data[8];
  $name = $data[2];
  $code = $data[1];
  if (strpos ($code, 'CEDEX') === FALSE) {
    $base->geoname_zip_add ($name, $adm3, $code);
    //    exit;
  }
}
