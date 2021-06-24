<?php
class SmsApi{
	/**
	 * @var string: URL of karaden API
	 */
	public $URL;
	/**
	 * @var int: Service ID
	 */
	public $SERVICE_ID;
	/**
	 * @var string: Group ID
	 */
	public $GROUP_ID;
	/**
	 * @var string: Sender user ID
	 */
	public $USER;
	/**
	 * @var string: Sender password
	 */
	public $PASS;
	/**
	 * @var int: Max parallel session can be run to send SMS in the same time
	 */
	public $MAX_PARALLEL_SESSION;
	/**
	 * @var int: Max request to send SMS in one minute
	 */
	public $MAX_SEND_IN_MINUTE;
	/**
	 * @var string: Proxy host, which be needed when access to API via proxy
	 */
	public $PROXY_HOST;
	/**
	 * @var string: Proxy port, which be needed when access to API via proxy
	 */
	public $PROXY_PORT;
	/**
	 * @var string: Proxy user, which need when access to API via proxy
	 */
	public $PROXY_USER;
	/**
	 * @var string: Proxy password, which need when access to API via proxy
	 */
	public $PROXY_PASS;
	
	public function __construct(){
	}
	
	/** Set paramaeter using to access to API
	 * 
	 * @param string $URL: URL of karaden API
	 * @param int $SERVICE_ID: Service ID
	 * @param string $GROUP_ID: Group ID
	 * @param string $USER: Sender user ID
	 * @param string $PASS: Sender password
	 * @param int $MAX_PARALLEL_SESSION: Max parallel session can be run to send SMS in the same time
	 * @param int $MAX_SEND_IN_MINUTE: Max request to send SMS in one minute
	 * @param string $PROXY_HOST: Proxy host, which be needed when access to API via proxy
	 * @param string $PROXY_PORT: Proxy port, which be needed when access to API via proxy
	 * @param string $PROXY_USER: Proxy user, which need when access to API via proxy
	 * @param string $PROXY_PASS: Proxy password, which need when access to API via proxy
	 * @return void
	 */
	public function config($URL, $SERVICE_ID,$GROUP_ID,$USER,$PASS,$MAX_PARALLEL_SESSION,$MAX_SEND_IN_MINUTE,$PROXY_HOST,$PROXY_PORT,$PROXY_USER,$PROXY_PASS){
		$this->URL = $URL;
		$this->SERVICE_ID = $SERVICE_ID;
		$this->GROUP_ID = $GROUP_ID;
		$this->USER = $USER;
		$this->PASS = $PASS;
		$this->MAX_PARALLEL_SESSION = $MAX_PARALLEL_SESSION;
		$this->MAX_SEND_IN_MINUTE = $MAX_SEND_IN_MINUTE;
		$this->PROXY_HOST = $PROXY_HOST;
		$this->PROXY_PORT = $PROXY_PORT;
		$this->PROXY_USER = $PROXY_USER;
		$this->PROXY_PASS = $PROXY_PASS;
	}
	/** Set paramaeter using to access to API
	 * @param Mixed $config
	 * @return void
	 */
	public function config1($config = array()){
		if(isset($config["URL"])) $this->URL = $config["URL"];
		if(isset($config["SERVICE_ID"])) $this->SERVICE_ID = $config["SERVICE_ID"];
		if(isset($config["GROUP_ID"])) $this->GROUP_ID = $config["GROUP_ID"];
		if(isset($config["USER"])) $this->USER = $config["USER"];
		if(isset($config["PASS"])) $this->PASS = $config["PASS"];
		if(isset($config["MAX_PARALLEL_SESSION"])) $this->MAX_PARALLEL_SESSION = $config["MAX_PARALLEL_SESSION"];
		if(isset($config["MAX_SEND_IN_MINUTE"])) $this->MAX_SEND_IN_MINUTE = $config["MAX_SEND_IN_MINUTE"];
		if(isset($config["PROXY_HOST"])) $this->PROXY_HOST = $config["PROXY_HOST"];
		if(isset($config["PROXY_PORT"])) $this->PROXY_PORT = $config["PROXY_PORT"];
		if(isset($config["PROXY_USER"])) $this->PROXY_USER = $config["PROXY_USER"];
		if(isset($config["PROXY_PASS"])) $this->PROXY_PASS = $config["PROXY_PASS"];
	}
	/** Initialize a cURL session
	 * @param $url string[optional] If provided, the CURLOPT_URL option will be set to its value. You can manually set this using the curl_setopt function. 	 
	 * @return resource a cURL handle on success, false on errors. 
	 */
	public function initCurlRequest($url = null){
		if(!empty($url))
			$ch = curl_init($url);
		else
			$ch = curl_init();
		return $ch;
	}
	/** Close a cURL session
	 * @param resource $ch a cURL handle
	 * @return void
	 */
	public function closeCurlRequest($ch = null){
		if(!empty($ch)) curl_close($ch);
	}
	/**
	 * @param resource $ch a cURL handle
	 * @param string $apiMethod a api function name
	 * @param array $postData data will be sent to API
	 * @return void
	 */
	public function setCurlRequest($ch = null, $apiMethod = null, $postData = array()){
		if(empty($ch)){
			$ch = $this->initCurlRequest();
		}
		$headers = array (
			"Authorization: Basic " . base64_encode ( $this->USER . ":" . $this->PASS )
		);
		curl_setopt ( $ch, CURLOPT_URL, $this->URL. "/". $this->GROUP_ID. "/" . $apiMethod);
		if(isset($this->PROXY_HOST) && isset($this->PROXY_PORT) && isset($this->PROXY_USER) && isset($this->PROXY_PASS)){
		    if(!empty($this->PROXY_HOST) && !empty($this->PROXY_PORT) && !empty($this->PROXY_USER) && !empty($this->PROXY_PASS)){
				curl_setopt ( $ch, CURLOPT_PROXY, $this->PROXY_HOST . ":" . $this->PROXY_PORT );
				curl_setopt ( $ch, CURLOPT_PROXYUSERPWD, $this->PROXY_USER . ':' . $this->PROXY_PASS );	
			}
		}
		// tls_v1.2‚Å“®‚­‚æ‚¤‚É×H‚·‚é
		curl_setopt($ch, CURLOPT_SSLVERSION, 1);
		curl_setopt ( $ch, CURLOPT_FOLLOWLOCATION, 1 );
		curl_setopt ( $ch, CURLOPT_RETURNTRANSFER, 1 );
		curl_setopt ( $ch, CURLOPT_TIMEOUT, 60 );
		curl_setopt ( $ch, CURLOPT_HTTPHEADER, $headers );
		
		curl_setopt ( $ch, CURLOPT_POST, 1 );
		curl_setopt ( $ch, CURLOPT_POSTFIELDS, http_build_query( $postData ));
	}
	/**
	 * @param resource $ch a cURL handle
	 * @param string $apiMethod a api function name
	 * @param array $getData data will be sent to API
	 * @return void
	 */
	public function setCurlGetRequest($ch = null, $apiMethod = null, $getData = array()){
		if(empty($ch)){
			$ch = $this->initCurlRequest();
		}
		$headers = array (
				"Authorization: Basic " . base64_encode ( $this->USER . ":" . $this->PASS )
		);
		$params = "";
		foreach($getData as $key=>$value)
			$params .= $key.'='.$value.'&';
		$params = trim($params, '&');
		
		
		curl_setopt ( $ch, CURLOPT_URL, $this->URL. "/". $this->GROUP_ID. "/" . $apiMethod.'?'.$params);
		if(isset($this->PROXY_HOST) && isset($this->PROXY_PORT) && isset($this->PROXY_USER) && isset($this->PROXY_PASS)){
		    if(!empty($this->PROXY_HOST) && !empty($this->PROXY_PORT) && !empty($this->PROXY_USER) && !empty($this->PROXY_PASS)){
		        curl_setopt ( $ch, CURLOPT_PROXY, $this->PROXY_HOST . ":" . $this->PROXY_PORT );
		        curl_setopt ( $ch, CURLOPT_PROXYUSERPWD, $this->PROXY_USER . ':' . $this->PROXY_PASS );
		    }
		}
		// tls_v1.2‚Å“®‚­‚æ‚¤‚É×H‚·‚é
		curl_setopt($ch, CURLOPT_SSLVERSION, 1);
		curl_setopt ( $ch, CURLOPT_FOLLOWLOCATION, 1 );
		curl_setopt ( $ch, CURLOPT_RETURNTRANSFER, 1 );
		curl_setopt ( $ch, CURLOPT_TIMEOUT, 60 );
		curl_setopt ( $ch, CURLOPT_HTTPHEADER, $headers );
	}
	/** Perform a cURL session
	 * @param resource $ch a cURL handle
	 * @return Mixed If $ch is null return NULL
	 * 				 If request is not avaible or execute fail return false
	 * 				 If execute request successful return the JSON data
	 * @link
	 */
	public function executeCurlRequest($ch = null){
		if (empty($ch)) return null;
		$data = curl_exec ( $ch );		
		if (curl_errno ( $ch )) {
			curl_close ( $ch );
			return false;
		} else {
			curl_close ( $ch );
			return $data;
		}
	}
	/**
	 * @param string $apiMethod
	 * @param array $postData data will be sent to API
	 * @return Mixed If request is not avaible or execute fail return false
	 * 				 If execute request successful return the JSON data
	 */
	public function runSmsApi($apiMethod = null, $postData = array(), $is_post = true){
		$ch = $this->initCurlRequest();
		if($is_post)
			$this->setCurlRequest($ch, $apiMethod, $postData);
		else 
			$this->setCurlGetRequest($ch, $apiMethod, $postData);
		$data = $this->executeCurlRequest($ch);
//		$this->closeCurlRequest($ch);
		return $data;
	}

	/**	 Perform send sms
	 * @param string $tel_no telephone number be sent message
	 * @param string $consentday 
	 * @param string $consent_flag
	 * @param string $message
	 * @return NULL|Mixed
	 *
	 * 20160930 #8298 add consentday
	 */
	public function sendSms($tel_no, $consentday, $consent_flag, $message){
		if(empty($tel_no) || empty($message))
			return null;
		$apiMethod = "req_entry.php";
		
		if ($consent_flag == "1"){ // use
			$permit_time = $consentday;
			$history_judgement = "1";
		} else {
			$permit_time = date("YmdHis",strtotime("+24 hours"));
			$history_judgement = "0";
		}
		
		$postData = array (
				"carrier_id" => "9", // auto judge the carrier of tel number mode
				"service_id" => $this->SERVICE_ID,
				"address" => $tel_no,
				"message" => base64_encode ($message),
				"encode" => "1",
				"notify" => "1",
				"lifetime_docomo" => "00",
				"lifetime_softbank" => "00",
				"lifetime_au" => "00",
				"permit_time" => $permit_time,
				"history_judgement" => $history_judgement
		);
		return $this->runSmsApi($apiMethod,$postData);
	}

	/** Get Sms sent status
	 * @param string $entry_id
	 * @return NULL|Mixed
	 */
	public function getSendSmsStatus($entry_id = null){
		if(empty($entry_id))
			return null;
		
		$apiMethod = "getSendResult2.php";
		$postData = array (
				"entry_id" => $entry_id
		);
		return $this->runSmsApi($apiMethod,$postData, false);
	}
}

class SmsApi_V2 extends SmsApi{
	/**
	 * @var string: Sender password
	 */
	public $SMS_USE_SHORT_URL;
	public $SMS_POST_DATA;

	public function config_v2($config = array(), $sms_use_short_url = Null){

		if(isset($config["URL"])) $this->URL = $config["URL"];
		if(isset($config["SERVICE_ID"])) $this->SERVICE_ID = $config["SERVICE_ID"];
		if(isset($config["GROUP_ID"])) $this->GROUP_ID = $config["GROUP_ID"];
		if(isset($config["USER"])) $this->USER = $config["USER"];
		if(isset($config["PASS"])) $this->PASS = $config["PASS"];
		if(isset($config["MAX_PARALLEL_SESSION"])) $this->MAX_PARALLEL_SESSION = $config["MAX_PARALLEL_SESSION"];
		if(isset($config["MAX_SEND_IN_MINUTE"])) $this->MAX_SEND_IN_MINUTE = $config["MAX_SEND_IN_MINUTE"];
		if(isset($config["PROXY_HOST"])) $this->PROXY_HOST = $config["PROXY_HOST"];
		if(isset($config["PROXY_PORT"])) $this->PROXY_PORT = $config["PROXY_PORT"];
		if(isset($config["PROXY_USER"])) $this->PROXY_USER = $config["PROXY_USER"];
		if(isset($config["PROXY_PASS"])) $this->PROXY_PASS = $config["PROXY_PASS"];
		if(isset($sms_use_short_url)) $this->SMS_USE_SHORT_URL = $sms_use_short_url;
	}


	public function getSmsPostData(){
		return $this->SMS_POST_DATA;
	}

	public function sendSms($tel_no, $consentday, $consent_flag, $message){
		$apiMethod = "karadenqueue.json";
		$postData = array (
				"Token" => $this->SERVICE_ID,
				"To" => $tel_no,
				"DocomoMessage" => $message,
				"SoftbankMessage" => $message,
				"AuMessage" => $message,
				"OptionMessage" => $message,
				"SecurityCode" => $this->PASS,
				"ShorturlFlg" => $this->SMS_USE_SHORT_URL,
				"format" => "json",
		);
		if ($consent_flag == "1"){ // use
			$postData["PermitDate"] = substr($consentday, 0, 8);
		}
		$this->SMS_POST_DATA = $postData;

		return $this->runSmsApi($apiMethod, $postData, true);
	}

	/** Get Sms sent status
	 * @param string $entry_id
	 * @return NULL|Mixed
	 */
	public function getSendSmsStatus($entry_id = null){
		if(empty($entry_id))
			return null;
		$apiMethod = "karadeninquiry.json";

		$getData = array (
				"Token" => $this->SERVICE_ID,
				"messageId" => $entry_id,
				"SecurityCode" => $this->PASS,
				"format" => "json",
		);

		return $this->runSmsApi($apiMethod,$getData, false);
	}


	public function setCurlRequest($ch = null, $apiMethod = null, $postData = array()){
		if(empty($ch)){
			$ch = $this->initCurlRequest();
		}
		curl_setopt ( $ch, CURLOPT_URL, $this->URL. "/" . $apiMethod);
		if(isset($this->PROXY_HOST) && isset($this->PROXY_PORT) && isset($this->PROXY_USER) && isset($this->PROXY_PASS)){
		    if(!empty($this->PROXY_HOST) && !empty($this->PROXY_PORT) && !empty($this->PROXY_USER) && !empty($this->PROXY_PASS)){
				curl_setopt ( $ch, CURLOPT_PROXY, $this->PROXY_HOST . ":" . $this->PROXY_PORT );
				curl_setopt ( $ch, CURLOPT_PROXYUSERPWD, $this->PROXY_USER . ':' . $this->PROXY_PASS );	
			}
		}
		// tls_v1.2‚Å“®‚­‚æ‚¤‚É×H‚·‚é
		curl_setopt($ch, CURLOPT_SSLVERSION, 1);
		curl_setopt ( $ch, CURLOPT_FOLLOWLOCATION, 1 );
		curl_setopt ( $ch, CURLOPT_RETURNTRANSFER, 1 );
		curl_setopt ( $ch, CURLOPT_TIMEOUT, 60 );
		
		curl_setopt ( $ch, CURLOPT_POST, 1 );
		curl_setopt ( $ch, CURLOPT_POSTFIELDS, http_build_query( $postData ));
	}

	/**
	 * @param resource $ch a cURL handle
	 * @param string $apiMethod a api function name
	 * @param array $getData data will be sent to API
	 * @return void
	 */
	public function setCurlGetRequest($ch = null, $apiMethod = null, $getData = array()){
		if(empty($ch)){
			$ch = $this->initCurlRequest();
		}
		$params = "";
		foreach($getData as $key=>$value)
			$params .= $key.'='.$value.'&';
		$params = trim($params, '&');
		
		curl_setopt ( $ch, CURLOPT_URL, $this->URL. "/". $apiMethod.'?'.$params);
		if(isset($this->PROXY_HOST) && isset($this->PROXY_PORT) && isset($this->PROXY_USER) && isset($this->PROXY_PASS)){
		    if(!empty($this->PROXY_HOST) && !empty($this->PROXY_PORT) && !empty($this->PROXY_USER) && !empty($this->PROXY_PASS)){
		        curl_setopt ( $ch, CURLOPT_PROXY, $this->PROXY_HOST . ":" . $this->PROXY_PORT );
		        curl_setopt ( $ch, CURLOPT_PROXYUSERPWD, $this->PROXY_USER . ':' . $this->PROXY_PASS );
		    }
		}
		// tls_v1.2‚Å“®‚­‚æ‚¤‚É×H‚·‚é
		curl_setopt($ch, CURLOPT_SSLVERSION, 1);
		curl_setopt ( $ch, CURLOPT_FOLLOWLOCATION, 1 );
		curl_setopt ( $ch, CURLOPT_RETURNTRANSFER, 1 );
		curl_setopt ( $ch, CURLOPT_TIMEOUT, 60 );
	}



}

?>
