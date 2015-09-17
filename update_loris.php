<?php
/*
 / command line script for updating file order in Scripto
 / takes one argument, which is item_id
 / example: php update_order.php {some_id}
*/
ini_set('display_errors', 'On');
error_reporting(E_ALL);
require_once 'db_settings.php';

function set_loris_path($original_filename){
    $new_path = str_replace("native.jpg","default.jpg",$original_filename);
    $new_path = str_replace("loris/","loris2/",$new_path);
    return $new_path;
}

// Run Query

$q = "SELECT id,original_filename from files";

$result = dbQuery($q);
if(dbNumRows($result) > 0){
	while($row = dbFetchAssoc($result)){
    $rec_id =  $row['id'];
    $path =  set_loris_path($row['original_filename']);

        $u = "UPDATE files SET original_filename='" .  $path . "' where id=" . $rec_id;
  			echo $u . "\n";
  			$rs = dbQuery($u);

  }
}
?>
