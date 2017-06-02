<?php
require "../db.inc.php";

$geos = $base->geoname_geoname_list (5);
echo count ($geos);
$i=0;
foreach ($geos as $geo) {
  $station = $base->geoname_proche_geoid($geo['geo_id']);
  $base->geoname_geoname_set_station ($geo['geo_id'], $station['geo_id']);
  $i++;
  if ($i % 1000 == 0)
    echo $i."\n";
}