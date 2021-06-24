<?php
App::uses('CakeEmail', 'Network/Email');
class SendMailComponent extends Component {
    /** 送信先 */
    // private $to = array("robocall-alert@ascend-corp.co.jp");
    private $to = array("hayabusa_dev@ascend-corp.co.jp");

    /**
     * メール送信を行う
     * @param string $subject 件名
     * @param string $company_id 会社ID
     * @param string $company_name 会社名
     * @param string $external_number 電話番号
     */
    public function sendErrorMail($subject, $company_id, $company_name, $external_number){
        $mailObject = $this->getMailObject($subject);
        $mailObject->send($this->getBodyContent($company_id, $company_name, $external_number));
        unlink(ERROR_LOG_DIR . 'tmp_error.log');
    }

    /**
     * メール送信オブジェクトを作成する
     * @param string $subject 件名
     * @return CakeEmail メールオブジェクト
     */
    private function getMailObject($subject){
        $mailObject = new CakeEmail("smtp");
        $mailObject->to($this->to)
                    ->subject($subject)
                    ->attachments($this->getAttachFilePath());

        return $mailObject;
    }

    /**
     * 添付ファイルを作成して、パスを返却する
     * @return string 添付ファイルパス
     */
    private function getAttachFilePath(){
        // エラーログ取得
        $errorLog = file(ERROR_LOG_DIR . 'error.log');

        // 添付用のログファイル作成
        $tempFilePath = ERROR_LOG_DIR . 'tmp_error.log';
        $filePointer = fopen($tempFilePath, "w");

        // エラーログの末尾100行を添付用ログファイルへ書き込み
        for ($i = max(0, count($errorLog) - 100); $i < count($errorLog); $i++) {
            fwrite($filePointer, $errorLog[$i]);
        }

        fclose($filePointer);

        return $tempFilePath;
    }

    /**
     * メール本文を取得する
     * @param string $company_id 会社ID
     * @param string $company_name 会社名
     * @param string $external_number 電話番号
     * @return string メール本文
     */
    private function getBodyContent($company_id, $company_name, $external_number){
        $bodyContent = "お疲れ様です。\r\n"
            . "エラーが発生しました。\r\n"
            . "■エラー情報\r\n"
            . "・アカウント：" . $company_name . "(" . $company_id . ")\r\n"
            . "・電話番号　：" . $external_number . "\r\n"
            . "詳細は下記資料と添付ファイルを確認し、ご対応をお願いします。\r\n"
            . "※資料の場所：\\\\10.101.0.231\ascend-sjk\案件フォルダ\hayabusa_team\\troubleshoot\r\n"
            . "以上、宜しくお願いします。";

        return $bodyContent;
    }
}
?>
