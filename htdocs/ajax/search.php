<?php
header ('Content-Type: application/json ; charset=utf-8');
header ('Cache-Control: no-cache , private');
header ('Pragma: no-cache');

require_once ('../../db.inc.php');
require_once ('../../verifyid.inc.php');
$q = $_GET['q'];

if ($forcetoken || isset ($_POST['token'])) {
  $token = isset ($_POST['token']) ? $_POST['token'] : '';
  $tokok = verify($token);
  if (!$tokok) {
    echo json_encode (array ());
    exit;
  }
}

if (strlen ($q) == 5 && is_numeric ($q)) {
  //  echo "zip: ".$q;
  // return list of cities with this zip code
  $res = $base->geoname_zip_list ($q, $base->order ('zip_name'));
  $ret = array ();
  foreach ($res as $re) {
    $ret[] = array ('geoid' => $re['zip_geoname'],
		    'name' => $re['zip_name'],
		    'zip' => $re['zip_code']);
  }
  echo json_encode ($ret);
} else if (is_numeric ($q)) {
  //  echo 'imcomplete zip';
  // return Nothing 
} else {
  // search on city names
  $an = $base->geoname_search ($q, $base->count());
  $n = $an[0]['count'];
  if ($n > 50) {
    echo $n;
  } else {
    $ret = array ();
    $res = $base->geoname_search ($q, $base->order ('zip_name'));
    foreach ($res as $re) {
      $ret[] = array ('geoid' => $re['zip_geoname'],
		      'name' => $re['zip_name'],
		      'zip' => $re['zip_code']);
    }
    echo json_encode ($ret);  
  }
}