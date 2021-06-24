<?php

/** Define class to write log file
 * @author Hungnv
 *
 */
class Logger {
	/**
	 * @var is local path of sms batch
	 */
	public static $LOCAL_PATH = "/home/ftpuser/robo/sms/";
	
	public static $ROOT_USER = "root";
	public static $PHP_USER = "apache";
	/** Set local path for log folder
	 * @param string $local_path is local path of sms batch
	 * @return void
	 */
	public static function setPath($local_path){
		self::$LOCAL_PATH = $local_path;
	}
	/** Get owner of log file
	 * @return string is owner value. Ex: root, apache
	 */
	public static function getOwner($filepath){
		$cmd = "stat -c %U $filepath";
		$owner = exec($cmd, $result, $result_status);
		if ($result_status != 0) {
			$chmod = "";
		}
		return $owner;
	}
	/** Change permission (chmod) of log file
	 */
	public static function changePermission($filepath){
		$cmd = "chmod 777 $filepath";
		exec($cmd, $result, $result_status);
	}

	/** Change owner of log file
	 */
	public static function changeOwner($filepath, $user){
		$cmd = "chown $user:$user $filepath";
		exec($cmd, $result, $result_status);
	}
	/**
	 * Write content to log file.
	 * Log file name is formated by sms_log_yyyymmdd.log. Ex: sms_log_20150523.log
	 *
	 * @param string $content
	 *        	is content be written to log file.
	 * @return void
	 */
	public static function writeLog($content) {
		if (! empty ( $content )) {
			try {
				$file_name = self::$LOCAL_PATH."log/sms_log_" . date ( "Ymd" ) . ".log";
				if(file_exists($file_name)){
					$owner = self::getOwner($file_name);
					if(!empty($owner) && $owner == self::$ROOT_USER){
						self::changeOwner($file_name,self::$PHP_USER);
						self::changePermission($file_name);
					}else if(empty($owner)){
						self::changePermission($file_name);
					}
				}
				$logfile = fopen ( $file_name, "a" ) or die ( "Unable to open file!" );
				fwrite ( $logfile, mb_convert_encoding(date ( "Y-m-d H:i:s" ) . "\t" . $content . "\n", "SJIS","auto"));
				fclose ( $logfile );

				$owner = self::getOwner($file_name);
				if(!empty($owner) && $owner == self::$ROOT_USER){
					self::changeOwner($file_name,self::$PHP_USER);
					self::changePermission($file_name);
				}else if(empty($owner)){
					self::changePermission($file_name);
				}
			} catch (Exception $e) {
				try{
					$error_file_name = self::$LOCAL_PATH."log/write_log_error_" . date ( "Ymd" ) . ".log";
					if(file_exists($error_file_name)){
						$owner = self::getOwner($error_file_name);
						if(!empty($owner) && $owner == self::$ROOT_USER){
							self::changeOwner($error_file_name,self::$PHP_USER);
							self::changePermission($error_file_name);
						}else if(empty($owner)){
							self::changePermission($error_file_name);
						}
					}
					$errorLogFile = fopen ( $error_file_name, "a" ) or die ( "Unable to open file!" );
					fwrite ( $errorLogFile, mb_convert_encoding(date ( "Y-m-d H:i:s" ) . "\t" . $e->getMessage() . "\n", "SJIS","auto"));
					fclose ( $errorLogFile );
					$owner = self::getOwner($error_file_name);
					if(!empty($owner) && $owner == self::$ROOT_USER){
						self::changeOwner($error_file_name,self::$PHP_USER);
						self::changePermission($error_file_name);
					}else if(empty($owner)){
						self::changePermission($error_file_name);
					}
				}catch(Exception $e){
				}
			}
		}
	}
	
	/**
	 * Get log file name by specified date
	 * 
	 * @param string $date
	 *        	is log of date
	 * @return string name of log file or null if file not exist
	 */
	public static function getLogFileName($date) {
		if (strtotime ( $date ) !== false) {
			$filename = "sms_log_" . date ( "Ymd", strtotime ( $date ) ) . ".log";
			if (file_exists ( self::$LOCAL_PATH."/log/" . $filename ))
				return $filename;
			else
				return null;
		} else
			return null;
	}
}

?>
