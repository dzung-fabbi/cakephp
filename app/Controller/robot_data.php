<?php
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "robot_test";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);
// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$sql = '';
for ($i = 1; $i <= 1000; $i ++) {
    echo $i;
    $tel_no = mt_rand(1, 946362452);
//    $tel_no = '0' + $tel_no;
    $date = new DateTime();
    $date = $date -> format('Y-m-d H:i:s');
    $sql .= "INSERT INTO t80_outgoing_results (schedule_id, redial_flag	, tel_no , tel_type , call_datetime ,del_flag , connect_datetime, cut_datetime , trans_call_datetime, trans_connect_datetime, trans_cut_datetime, status, valid_count)
VALUES (1, 0, '09757343433', '$tel_no', '2021-06-03 11:55:16', 'N', '2021-06-17 00:00:00', '2021-06-17 00:00:00',  '2021-09-15 00:00:00', '2021-09-15 00:00:00' , '2021-07-12 00:00:00', 'transfertimeout', 'e');";

}
if ($conn->multi_query($sql) === TRUE) {
    echo "New records created successfully";
} else {
    echo "Error: " . $sql . "<br>" . $conn->error;
}
$conn->close();
?>
