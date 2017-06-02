<?php
function gcm_send ($base, $regids, $data) {
  if (count ($regids <= 1000)) {
    $ret = gcm_send_mille($regids, $data);
    verify_gcm_ret ($base, $ret, $regids);
  } else {
    $tabs = array_chunk ($regids, 1000);
    foreach ($tabs as $tab) {
      $ret = gcm_send_mille ($tab, $data);
      verify_gcm_ret ($base, $ret, $regids);
    }
  }
}

function verify_gcm_ret ($base, $ret, $regids) {
  $res = json_decode ($ret);
  //  print_r ($res);
  if ($res->failure > 0) {
    foreach ($res->results as $k => $re) {
      if (isset ($re->error)) {
	if ($re->error == 'InvalidRegistration') {
	  echo 'Invalid id '.$regids[$k]."\n";
	  // TODO
	} else if ($re->error == 'NotRegistered') {
	  echo 'Not registered id '.$regids[$k]."\n";
	  $base->gcm_register_delete($regids[$k]);
	} else {
	  echo 'Error id '.$regids[$k].": ".$re->error."\n";
	}
      }
    }
  }
  if ($res->canonical_ids > 0) {
    foreach ($res->results as $k => $result) {
      if (isset ($result->registration_id)) {
	echo $result->registration_id.' replaces '.$regids[$k]."\n";
	$base->gcm_register_delete($regids[$k]);
      }
    }
  }
}

function gcm_send_mille($regids, $data) {
  $apiKey = "maCleApi";
  $url = 'https://android.googleapis.com/gcm/send';
  
  $fields = array(
		  'registration_ids'  => $regids,
		  'time_to_live'      => 86400,
		  'data'              => $data
		  );
  
  $headers = array( 
		   'Authorization: key=' . $apiKey,
		   'Content-Type: application/json'
		    );
  
  // Open connection
  $ch = curl_init();
  
  // Set the url, number of POST vars, POST data
  curl_setopt( $ch, CURLOPT_URL, $url );
  
  curl_setopt( $ch, CURLOPT_POST, true );
  curl_setopt( $ch, CURLOPT_HTTPHEADER, $headers);
  curl_setopt( $ch, CURLOPT_RETURNTRANSFER, true );
  
  curl_setopt( $ch, CURLOPT_POSTFIELDS, json_encode( $fields ) );
  
  // Execute post
  $result = curl_exec($ch);
  
  // Close connection
  curl_close($ch);
  return $result;
}

?>
