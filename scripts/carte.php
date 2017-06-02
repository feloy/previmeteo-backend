<?php
require '../db.inc.php';
$res = $base->forecast_forecast_map (3/*commune*/, 6 /*hours*/);

$interv = $base->forecast_forecast_map_interval (4, 6);
file_put_contents ('carte.json', json_encode (array ('interval'=>$interv, 'forecast'=>$res)));
