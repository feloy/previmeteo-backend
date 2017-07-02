<?php
require "../db.inc.php";

$h1only = isset ($argv[1]) && $argv[1] == '1h';
$paidonly = isset ($argv[1]) && $argv[1] == 'paid';

$base->set_timestamp_arg_format ('%Y-%m-%d %H:%M');
$ete = date('I');
$base->set_timezone ($ete ? '+02' : '+01');

$paid_geos = array('3021670', 
		   '3007691',
		   '2988507',
		   '3031582',
		   '2998324',
		   '3034475',
		   '2996944',
		   '3032179',
		   '2992166',
		   '2977921',
		   '2999683',
		   '2972315',
		   '2990969',
		   '3014728',
		   '2988358',
		   '2987914',
		   '2990999',
		   '3024635',
		   '2995469',
		   '3037253',
		   '2972191',
		   '2979303',
		   '2969284',
		   '2970777',
		   '2982652',
		   '3019256',
		   '2983990',
		   '3032833',
		   '2969679',
		   '3021372',
		   '2990355',
		   '3030300',
		   '3037543',
		   '3006958',
		   '3022530');

$geos = $base->geoname_geoname_list (3);
foreach ($geos as $geo) {
  if ($paidonly && !in_array($geo['geo_id'], $paid_geos))
    continue;
  get_geoname ($geo['geo_id'], $h1only || $paidonly);
  $output = array ();
  exec ("php fcgcm.php ".$geo["geo_id"], $output);  
  if (is_array($output) && count ($output)) {
    //    echo $geo['geo_adm2']."\t".$geo['geo_name']."\t";
    foreach ($output as $line) {
      //      echo $line."\n";
    }
    //    exit;
  }
}

exit;

function get_geoname ($id, $h1only) {
  global $pmlog, $pmpass, $base;
  $args = 'log='.$pmlog.'&pass='.$pmpass.'&id='.$id;
  $url14j = $url_apiprevimeteo.'/apercu.php?'.$args;
  $url7j = $url_apiprevimeteo.'/previs.php?'.$args;
  $url1h = $url_apiprevimeteo.'/previs_1h.php?'.$args;

  if (!$h1only) {
    $res = file_get_contents ($url14j);
    $base->requete_add();
    import_forecast_14j (json_decode ($res));

    $res = file_get_contents ($url7j);
    $base->requete_add();
    import_forecast_7j (json_decode ($res));
  }

  $res = file_get_contents ($url1h);
  $base->requete_add();
  import_forecast_1h (json_decode ($res));
}

function import_forecast_14j ($res) {
  global $base;
  if (isset ($res->Previsions)) {
    foreach ($res->Previsions as $d => $data) {
      $base->forecast_forecast_add ($res->Id, 
				    $res->LastModificationDate, 
				    $d." 00:00",
				    24*60*60,
				    $data->fiabilite,
				    $data->picto_ciel,
				    $data->tempe_min,
				    $data->tempe_max,
				    NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
				    $data->phrase_vitesse_vent,
				    NULL, NULL, NULL);
    }
  }
}

function import_forecast_7j ($res) {
  global $base;
  if (isset ($res->Previsions)) {
    foreach ($res->Previsions as $d => $data) {
      $dp1 = date ('Y-m-d H:i', strtotime (date ($d)." + 1 day"));
      if (isset ($data->Ma))
	$base->forecast_forecast_add ($res->Id, 
				      $res->LastModificationDate, 
				      $d." 06:00",
				      6*60*60,
				      $data->fiabilite,
				      $data->Ma->picto_ciel,
				      $data->tempe_min,
				      $data->tempe_max,
				      $data->Ma->nebu,
				      $data->Ma->phrase_nebu,
				      (float)$data->Ma->precip,
				      $data->Ma->phrase_precip,
				      $data->Ma->vent_moy,
				      $data->Ma->raf,
				      $data->Ma->dir,
				      $data->Ma->phrase_vent,
				      $data->Ma->tempe,
				      $data->Ma->tempe_res,
				      $data->Ma->pression
				      );
      if (isset ($data->Mi))
	$base->forecast_forecast_add ($res->Id, 
				      $res->LastModificationDate, 
				      $d." 12:00",
				      6*60*60,
				      $data->fiabilite,
				      $data->Mi->picto_ciel,
				      $data->tempe_min,
				      $data->tempe_max,
				      $data->Mi->nebu,
				      $data->Mi->phrase_nebu,
				      (float)$data->Mi->precip,
				      $data->Mi->phrase_precip,
				      $data->Mi->vent_moy,
				      $data->Mi->raf,
				      $data->Mi->dir,
				      $data->Mi->phrase_vent,
				      $data->Mi->tempe,
				      $data->Mi->tempe_res,
				      $data->Mi->pression
				      );
      if (isset ($data->So))
	$base->forecast_forecast_add ($res->Id, 
				      $res->LastModificationDate, 
				      $d." 18:00",
				      6*60*60,
				      $data->fiabilite,
				      $data->So->picto_ciel,
				      $data->tempe_min,
				      $data->tempe_max,
				      $data->So->nebu,
				      $data->So->phrase_nebu,
				      (float)$data->So->precip,
				      $data->So->phrase_precip,
				      $data->So->vent_moy,
				      $data->So->raf,
				      $data->So->dir,
				      $data->So->phrase_vent,
				      $data->So->tempe,
				      $data->So->tempe_res,
				      $data->So->pression
				      );
      if (isset ($data->Nu))
	$base->forecast_forecast_add ($res->Id, 
				      $res->LastModificationDate, 
				      $dp1,
				      6*60*60,
				      $data->fiabilite,
				      $data->Nu->picto_ciel,
				      $data->tempe_min,
				      $data->tempe_max,
				      $data->Nu->nebu,
				      $data->Nu->phrase_nebu,
				      (float)$data->Nu->precip,
				      $data->Nu->phrase_precip,
				      $data->Nu->vent_moy,
				      $data->Nu->raf,
				      $data->Nu->dir,
				      $data->Nu->phrase_vent,
				      $data->Nu->tempe,
				      $data->Nu->tempe_res,
				      $data->Nu->pression
				      );
    }
  }
}

function import_forecast_1h ($res) {
  global $base;
  if (isset ($res->Previsions)) {
    foreach ($res->Previsions as $d => $data1) {
      $fiabilite = $data1->fiabilite;
      foreach ($data1 as $h => $data) {   
	if (substr ($h, -1) != 'h')
	  continue;
	$base->forecast_forecast_add ($res->Id, 
				      $res->LastModificationDate, 
				      $d." ".substr ($h, 0, -1).":00",
				      1*60*60,
				      $fiabilite,
				      $data->picto_ciel,
				      null,
				      null,
				      $data->nebu,
				      $data->phrase_nebu,
				      (float)$data->precip,
				      $data->phrase_precip,
				      $data->vent_moy,
				      $data->raf,
				      $data->dir,
				      $data->phrase_vent,
				      $data->tempe,
				      $data->tempe_res,
				      $data->pression
				      );
      }
    }
  }
}
