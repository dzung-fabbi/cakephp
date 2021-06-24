<?php
/**
 * This example shows making an SMTP connection with authentication.
 */

//SMTP needs accurate times, and the PHP time zone MUST be set
//This should be done in your php.ini, but this is how to do it if you don't have access to that
// date_default_timezone_set('Etc/UTC');

require('class.phpmailer.php');
require('class.smtp.php');

class SendMail
{

	/**
	 * @var string: The hostname of the mail server
	 */
	public $email_host;
	/**
	 * @var string: The SMTP port number
	 */
	public $email_port;
	/**
	 * @var string: Email to use for SMTP authentication
	 */
	public $email_user;
	/**
	 * @var string: Password to use for SMTP authentication
	 */
	public $email_pass;
	
	/**
	 * @var string: Receiver email
	 */
	public $email_to;
	
	/**
	 * @var string: Receiver email
	 */
	public $email_alert_to;
	/**
	 * @var string: CC mail of Receiver
	 */
	public $email_cc;
	
	/**
	 * @var string: BCC mail of Receiver
	 */
	public $email_bcc;

	/** Set paramaeter using to send mail
	 *
	 * @param array $config
	 * @return void
	 */
	public function config($config = array()) {
		if (isset($config["email_host"])) $this->email_host = $config["email_host"];
		if (isset($config["email_port"])) $this->email_port = $config["email_port"];
		if (isset($config["email_user"])) $this->email_user = $config["email_user"];
		if (isset($config["email_pass"])) $this->email_pass = $config["email_pass"];
		if (isset($config["email_to"]) && !empty($config["email_to"])){
			$to = explode(',', $config['email_to']);
			if($to !== false)
				$this->email_to = $to;
			else
				$this->email_to = array();
		}else{
			$this->email_to = array();
		}
		if (isset($config["email_alert_to"]) && !empty($config["email_alert_to"])){
			$alert_to = explode(',', $config['email_alert_to']);
			if($to !== false)
				$this->email_alert_to = $alert_to;
			else
				$this->email_alert_to = array();
		}else{
			$this->email_alert_to = array();
		}
		if (isset($config["email_cc"]) && !empty($config["email_cc"])){
			$cc = explode(',', $config['email_cc']);
			if($cc !== false)
				$this->email_cc = $cc;
			else
				$this->email_cc = array();
		}else{
			$this->email_cc = array();
		}
		if (isset($config["email_bcc"]) && !empty($config["email_bcc"])){
			$bcc = explode(',', $config['email_bcc']);
			if($bcc !== false)
				$this->email_bcc = $bcc;
			else
				$this->email_bcc = array();
		}else{
			$this->email_bcc = array();
		}
	}

    /**
     * Create a message and send it.
     * Uses the sending method specified by $Mailer.
     * @param string $content: The body of mail
     * @param string $subject: The Subject of the message.
     * @param string $log_filepath: Path to the attachment
     * @return boolean false on error - See the ErrorInfo property for details of the error.
     */
	public function sendTo($content = null, $subject = 'Send mail', $log_filepath = null, $error_alert = false) {

		echo $subject . " begin:\n";

		//Create a new PHPMailer instance
		$mail = new PHPMailer;
		$mail->CharSet = 'UTF-8';
		//Tell PHPMailer to use SMTP
		$mail->isSMTP();
		//Enable SMTP debugging
		// 0 = off (for production use)
		// 1 = client messages
		// 2 = client and server messages
		$mail->SMTPDebug = 0;
		//Ask for HTML-friendly debug output
		$mail->Debugoutput = 'html';
		//Set the hostname of the mail server
		$mail->Host = $this->email_host;
		//Set the SMTP port number - likely to be 25, 465 or 587
		$mail->Port = $this->email_port;
		//Whether to use SMTP authentication
		$mail->SMTPAuth = true;
		// SMTP connection will not close after each email sent, reduces SMTP overhead
		$mail->SMTPKeepAlive = true;
		//Username to use for SMTP authentication
		$mail->Username = $this->email_user;
		//Password to use for SMTP authentication
		$mail->Password = $this->email_pass;
		//Read an HTML message body from an external file, convert referenced images to embedded,
		//convert HTML into a basic plain-text alternative body
		// $mail->msgHTML(file_get_contents('contents.html'), dirname(__FILE__));
		//Set who the message is to be sent from
		$mail->setFrom($this->email_user);
		//Set the subject line
		$mail->Subject = $subject;
		//Replace the plain text body with one created manually
		$mail->Body = $content;
		$mail->IsHTML(true);

		if (!empty($log_filepath) && file_exists($log_filepath)) {
			$mail->addAttachment($log_filepath, '', 'base64', 'application/octet-stream');
		}
		if(!$error_alert){
			if(isset($this->email_to) && sizeof($this->email_to) > 0){
				foreach ($this->email_to as $to){
					$mail->addAddress($to);
				}
			}
		}else{
			if(isset($this->email_alert_to) && sizeof($this->email_alert_to) > 0){
				foreach ($this->email_alert_to as $to){
					$mail->addAddress($to);
				}
			}
		}
		if(isset($this->email_cc) && sizeof($this->email_cc) > 0){
			foreach ($this->email_cc as $cc){
				$mail->addCC($cc);
			}
		}
		if(isset($this->email_bcc) && sizeof($this->email_bcc) > 0){
			foreach ($this->email_bcc as $bcc){
				$mail->addBCC($bcc);
			}
		}
		if (!$mail->send()) {
			echo 'Mailer Error (' . $to . ') ' . $mail->ErrorInfo . "\n";
			echo $subject . ' end.';
			return false;
		} else {
			echo 'Message sent to : ' . $to . "\n";
		}
		echo $subject . " end.\n";
		return true;
	}
}
