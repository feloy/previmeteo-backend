<?php
$key = $_GET['key'];
$geos = isset ($_GET['geo']) ? $_GET['geo'] : null;

require '../../db.inc.php';
require_once ('../../verifyid.inc.php');

$token = isset ($_POST['token']) ? $_POST['token'] : '';
$tokok = verify($token);
if (!$tokok) {
  echo json_encode (array ());
  exit;
}
$account = $tokok['payload']['email'];
$base->gcm_register_set ($key, $account, $geos);

