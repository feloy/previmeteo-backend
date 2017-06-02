<?php
header ('Content-Type: application/json ; charset=utf-8');
header ('Cache-Control: no-cache , private');
header ('Pragma: no-cache');
require '../../db.inc.php';
require_once ('../../verifyid.inc.php');

$base->set_timestamp_return_format ('Y-m-d H:i');
$base->set_time_return_format ('H:i');
$base->set_date_return_format ('Y-m-d');

$id = $_GET['id'];

if ($forcetoken || isset ($_POST['token'])) {
  $token = isset ($_POST['token']) ? $_POST['token'] : '';
  $tokok = verify($token);
  if (!$tokok) {
    echo json_encode (array ());
    exit;
  }
}

$geo = $base->geoname_from_geoid ($id);
$name = $geo['geo_name'];

$proche = $base->geoname_proche_geoid ($id);
if ($proche['geo_id'] != $id) {
  $id = $proche['geo_id'];
  $station = $proche['geo_name'];
  $station_id = $proche['geo_id'];
} else {
  $station = '';
  $station_id = $id;
}
$fc1h = $base->forecast_forecast_geoid ($id, 1);
$date_debut = substr ($fc1h[0]['for_start'], 0, 10);

// On aligne la fin des forecasts 6h en fin de journée
$fc6h = $base->forecast_forecast_geoid ($id, 6);
while (1) {
  $last_6h = end ($fc6h);
  if (substr ($last_6h['for_end'], -5) != '00:00') 
    array_pop ($fc6h);
  else
    break;
  if (!count ($fc6h)) 
    break;
}

$debut24h = substr ($last_6h['for_end'], 0, 10);

// On supprime les forecasts 24h couverts par ceux de 6h
$fc24h = $base->forecast_forecast_geoid ($id, 24);
/*
  foreach ($fc24h as $k => $fc) {
    if (substr ($fc['for_start'], 0, 10) != $debut24h)
      unset ($fc24h[$k]);
    else
      break;
  }
*/

$res = array_merge ($fc1h, $fc6h, $fc24h);

$eph = $base->ephemeris_get_all ($id, 15);

echo json_encode (array ('id'=>$_GET['id'],
			 'name' => $name,
			 //			 'zip' => $zip['zip_code'],
			 'station' => $station,
			 'stationid' => $station_id,
			 'forecast'=>$res,
			 'eph' => $eph));
