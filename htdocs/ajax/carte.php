<?php
header ('Content-Type: application/json ; charset=utf-8');
header ('Cache-Control: no-cache , private');
header ('Pragma: no-cache');
require '../../db.inc.php';
require_once ('../../verifyid.inc.php');

if ($forcetoken || isset ($_POST['token'])) {
  $token = isset ($_POST['token']) ? $_POST['token'] : '';
  $tokok = verify($token);
  if (!$tokok) {
    echo json_encode (array ());
    exit;
  }
}

if (file_exists ('../../scripts/carte.json'))
  echo file_get_contents ('../../scripts/carte.json');
