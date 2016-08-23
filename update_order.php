<?php
/*
 / command line script for updating file order in Scripto
 / takes one argument, which is item_id
 / example: php update_order.php {some_id}
*/
ini_set('display_errors', 'On');
error_reporting(E_ALL);
require_once 'db_settings.php';

if (empty($argv[1]) && !ctype_digit($argv[1])){
    echo "We need a valid item...";
    exit();
}else{
  $item_id = $argv[1];
  $element_id_to_transfer = $argv[2];
}
// Run Query

$q = "SELECT id from files where item_id=" . $item_id;

$result = dbQuery($q);
if(dbNumRows($result) > 0){
	while($row = dbFetchAssoc($result)){
    $rec_id =  $row['id'];

    $q2 = "SELECT text from element_texts where element_id=" . $element_id_to_transfer . " and record_type='File' and record_id =" . $rec_id;

    $result2 = dbQuery($q2);
    if(dbNumRows($result2) > 0){
    	#while($row2 = dbFetchAssoc($result2)){
        #$u = "UPDATE files SET `order`=" .  $row2['text'] . " where id=" . $rec_id;
  	#		echo $u . "\n";
  	#		$rs = dbQuery($u);
    	while($row2 = dbFetchAssoc($result2)){
        if (preg_match('/^0+/', $row2['text'])) {
            $padding_cleanup = preg_split("/^0+/", $row2['text']);
            $order = $padding_cleanup[1];
        } else {
            $order = $row2['text'];
        }
        $u = "UPDATE files SET `order`=" .  $order . " where id=" . $rec_id;
        echo $u . "\n";
        $rs = dbQuery($u);
    }
}
  }
}
?>
