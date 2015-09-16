<?php
/*
 / command line script for updating file order in Scripto
 / takes one argument, which is item_id
 / example: php update_order.php {some_id}
*/
ini_set('display_errors', 'On');
error_reporting(E_ALL);
require_once 'db_settings.php';

function get_order($original_filename){
    $sort_order = str_replace(".jp2/full/full/0/native.jpg","",$original_filename);
    $sort_order = ltrim(substr($sort_order, -8),"0");
    return $sort_order;
}

if (empty($argv[1]) && !ctype_digit($argv[1])){
    echo "We need a valid item...";
    exit();
}else{
  $item_id = $argv[1];
}
// Run Query

$q = "SELECT id,original_filename from files where item_id=" . $item_id;

$result = dbQuery($q);
if(dbNumRows($result) > 0){
	while($row = dbFetchAssoc($result)){
    $rec_id =  $row['id'];
    $order =  get_order($row['original_filename']);

        $u = "UPDATE files SET `order`=" .  $order . " where id=" . $rec_id;
  			echo $u . "\n";
  			$rs = dbQuery($u);

  }
}
?>
