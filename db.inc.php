<?php
require('pgprocedures.class.php');
require('config.inc.php');

$base = new PgProcedures ($pghost, $pguser, $pgpass, $pgdb);
