<?php
/** Connect to the database
	 * @param string $host is domain or ip address. ex: localhost or 127.0.0.1
	 * @param string $port is port to connect mysql. ex: 3306
	 * @param string $user. ex: root
	 * @param string $pass. ex: 123456
	 * @param string $schema is schema name of database
	 * @return Mixed boolean false if connect fail or mysql connection object if success
	 */
function connectDB($host = null, $port = null, $user = null, $pass = null, $schema = null) {
	$db_con = @mysql_connect ( $host . ":" . $port, $user, $pass );
	if (! $db_con)
		return false;
	mysql_query ( "set names 'utf8'" );
	if (@mysql_select_db ( $schema, $db_con ))
		return $db_con;
	else
		return false;
}
/**
 * Execute the mysql query and return the associated rows
 *
 * @param resource $db_con        	
 * @param string $sql
 *        	is query string
 * @return Array of records, or false on failure.
 */
function query($db_con = null, $sql = null) {
	$result = mysql_query ( $sql, $db_con );
	if (! $result) {
		Logger::writeLog("++++DB.php function query  failed!!++++");
		Logger::writeLog(mysql_error());
		return false;
	} else
		return $result;
}
/** Fetch query results to array
 *
 * @param string $result
 *        	is associated rows returned by execute mysql query
 * @param array $fields
 *        	is A list of fields to be retrieved. if $fields is null, All the fields be retrieved.
 * @param int $limit
 *        	is The maximum number of associated rows you want returned.
 * @param int $offset
 *        	is The number of associated rows to skip over
 * @return Array of records, or NULL if not found
 */
function getRows($result = null, $fields = array(), $limit = null, $offset = null) {
	if (empty ( $result ))
		return null;
	$rs = array ();
	if (empty ( $offset ) || !is_int($offset) || $offset < 0)
		$offset = 0;
	$i = -1;
	while ( $row = mysql_fetch_array ( $result ) ) {
		$i ++;
		if (! empty ( $limit ) && is_int($limit) && $limit > 0) {
			if ($i >= $limit + $offset)
				break;
			else if ($i < $offset) continue;
		}
		$r = array ();
		if (! empty ( $fields )) {
			foreach ( $fields as $col ) {
				$r [$col] = $row [$col];
			}
			array_push ( $rs, $r );
		} else {
			array_push ( $rs, $row );
		}		
	}
	return $rs;
}
/**
 * Execute the mysql query to start transaction
 *
 * @param resource $db_con
 * @return void.
 */
function begin_transaction($db_con = null){
	mysql_query("START TRANSACTION", $db_con);
}
/**
 * Execute the mysql query to commit transaction
 *
 * @param resource $db_con
 * @return void.
 */
function commit($db_con = null){
	mysql_query("COMMIT", $db_con);
}
/**
 * Execute the mysql query to rollback transaction
 *
 * @param resource $db_con
 * @return void.
 */
function rollback($db_con = null){
	mysql_query("ROLLBACK", $db_con);
}
?>