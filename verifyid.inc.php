<?php
require_once realpath(dirname(__FILE__) . '/googleapi/autoload.php');

require 'apiids.inc.php';

// TODO
$forcetoken = false;
$debug = false;

function verify($token) {
  global $debug;
  if ($debug && $token == 'toto')
    return true;

  global $client_id, $client_secret, $google_azp_debug, $google_azp_release;
  
  $client = new Google_Client();
  $client->setClientId($client_id);
  $client->setClientSecret($client_secret);

  try {
    $ticket = $client->verifyIdToken($token);
  } catch (Exception $e) {
    return false;
  }
  if ($ticket) {
    $data = $ticket->getAttributes();
    if ($data['payload']['azp'] == $google_azp_debug ||
	$data['payload']['azp'] == $google_azp_release)
      return $data;
  }
  return false;
}


