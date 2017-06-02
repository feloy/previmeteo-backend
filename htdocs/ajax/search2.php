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

//$rev = $_POST['version'];
//echo $rev;

if (strlen ($q) == 5 && is_numeric ($q)) {
  //  echo "zip: ".$q;
  // return list of cities with this zip code
  $res = $base->geoname_zip_list2 ($q, $base->order ('name'));
  echo json_encode ($res);
} else if (is_numeric ($q)) {
  //  echo 'imcomplete zip';
  // return Nothing 
} else {
  // search on city names
  $an = $base->geoname_search2 ($q, $base->count());
  $n = $an[0]['count'];
  if ($n > 50) {
    echo $n;
  } else {
    $ret = array ();
    $res = $base->geoname_search2 ($q, $base->order ('name'));
    echo json_encode ($res);  
  }
}