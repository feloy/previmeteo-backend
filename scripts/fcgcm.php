<?php
include 'gcm_send.inc.php';
require '../db.inc.php';
$base->set_timestamp_return_format ('Y-m-d H:i');
$base->set_time_return_format ('H:i');
$base->set_date_return_format ('Y-m-d');

$id = $argv[1];

$regids = $base->gcm_register_list_from_station_id($id);
if (!is_array ($regids)) 
  exit;

echo count($regids);

$geo = $base->geoname_from_geoid ($id);

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

//$res = array_merge ($fc1h); //, $fc6h, $fc24h);
send_fc ($id, $fc1h, 1, $regids);
send_fc ($id, $fc6h, 6, $regids);
send_fc ($id, $fc24h, 24, $regids);
send_eph ($id, $regids);

function send_fc ($id, $res, $duration, $apps) {
  global $base;
  $rs = array ();
  foreach ($res as $re) {
    $rs[] = array ($re['for_fiability'],
		   $re['for_picto'],
		   $re['for_nebu'],
		   $re['for_precip'],
		   $re['for_tempe'],
		   $re['for_tempe_res'],
		   $re['for_pression'],
		   $re['for_vent_moy'],
		   $re['for_vent_raf'],
		   $re['for_dir'],
		   $re['for_tempe_min'],
		   $re['for_tempe_max'],
		   $re['for_start'],
		   $re['for_end'],
		   );
  }
  $json = json_encode (array ('id'=>$id,
			      'duration' => $duration,
			      'forecast'=>$rs));
  //			 'eph' => $e));

  $res = gcm_send ($base, $apps, array('message'=>$json));
  //  print_r (json_decode ($res));
}

function send_eph ($id, $apps) {
  global $base;
  $eph = $base->ephemeris_get_all ($id, 15);
  $e = array ();

  foreach ($eph as $ep) {
    $e[] = array($ep['d'],
		 $ep['sunrise'],
		 $ep['sunset'],
		 $ep['moonrise'],
		 $ep['moonset'],
		 $ep['moonphase'],
		 $ep['moon4']);    
  }  
  $json = json_encode (array ('id'=>$id,
			      'eph' => $e));
  $res = gcm_send ($base, $apps, array('message'=>$json));
  //  print_r (json_decode ($res));
}

/*
$eph = $base->ephemeris_get_all ($id, 15);
$e = array ();

foreach ($eph as $ep) {
  $e[] = array($ep['d'],
	       $ep['sunrise'],
	       $ep['sunset'],
	       $ep['moonrise'],
	       $ep['moonset'],
	       $ep['moonphase'],
	       $ep['moon4']);
	       
}

$json = json_encode (array ('id'=>$id,
			    'duration' => $res[0]['for_duration'],
			    'forecast'=>$rs));
//			 'eph' => $e));

print_r (gcm_send (array ($regidOpO), array('message'=>$json)));

*/
?>
