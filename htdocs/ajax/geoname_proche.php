<?php
header ('Content-Type: application/json ; charset=utf-8');
header ('Cache-Control: no-cache , private');
header ('Pragma: no-cache');

require_once ('../../db.inc.php');
require_once ('../../verifyid.inc.php');
$lat = $_GET['lat'];
$lng = $_GET['lng'];

if ($forcetoken || isset ($_POST['token'])) {
  $token = isset ($_POST['token']) ? $_POST['token'] : '';
  $tokok = verify($token);
  if (!$tokok) {
    echo json_encode (array ());
    exit;
  }
}

$res = $base->geoname_proche ($lat, $lng);

$ret[] = array ('geoid' => $res['geo_id'],
		'name' => $res['geo_name'],
		'lat' => $res['geo_lat'],
		'lng' => $res['geo_lng']);
echo json_encode ($ret);
