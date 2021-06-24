const MSG_ERROR_CSV_COLUMN_SAME = 'インポート先項目に同一の値を選択しないでください。';
const MSG_ERROR_CSV_COLUMN_TEL = 'インポート先項目に電話番号を選択するのは必須です。';
const MSG_ERROR_REQUIRED_LIST_NAME = 'リスト名を入力してください。';
const MSG_ERROR_EXIST_LIST_NAME = '指定したリスト名は既に使用されています。';
const MSG_ERROR_PLS_CHOOSE_FILE = 'ファイルを選択してください。';
const MSG_ERROR_LIMITED_MAX_SIZE = 'ファイルサイズが{0}MBを超えています。';
const MSG_ERROR_BIRTHDAY_INVALID = '行目：生年月日の入力形式が正しくありません。';
const MSG_ERROR_CONSENTDAY_INVALID = '行目：利用承諾日の入力形式が正しくありません。'; // #8298 add consentday
const MSG_ERROR_FEE_NOT_NUMBERIC = '行目：金額の入力形式が正しくありません。';
const MSG_ERROR_TEL_NO_DUPLICATE = '行目：重複電話番号があります。';
const MSG_ERROR_TEL_NO_LENGTH = '行目：電話番号の入力形式が正しくありません。';
const MSG_ERROR_TEL_NO_NULL = '行目：電話番号項目がありません。';
const MSG_ERROR_TEL_NO_NOT_NUMBERIC = '行目：電話番号の入力形式が正しくありません。';
const MSG_ERROR_TEL_NO_POSITION_FIRST_SECCON = '行目：電話番号の入力形式が正しくありません。';
const MSG_ERROR_EXIST_TEL_NO = '対象電話番号は既に使用されています。';
const MSG_ERROR_CHECK_TEL = '電話番号の入力形式が正しくありません。';
const MSG_ERROR_CHECK_TEL_SMS = '電話番号は070または080または090から始まる半角数字11桁を入力してください。';
const MSG_ERROR_CHECK_TEL_INVALID_SMS = '行目：電話番号は070または080または090から始まる半角数字11桁を入力してください。';
const MSG_ERROR_NUMBER_AUTH_DIGIT_OVER = '桁数は' + NUMBER_AUTH_ITEM_MAX_DIGIT + '桁以内で入力して下さい。';
const MSG_ERROR_CHAR_AUTH_DIGIT_OVER = '桁数は' + CHAR_AUTH_ITEM_MAX_DIGIT + '桁以内で入力して下さい。';

const MSG_ALERT_NO_TEL_RECORD = '1行以下ファイルはアップロードできません。';
const MSG_ALERT_OVER_TEL_RECORD = '12万行を超えるファイルはアップロードできません。';
const MSG_ALERT_OVER_TEL_RECORD_INBOUND_CALL_LIST = '13万行を超えるファイルはアップロードできません。';
const MSG_ALERT_TYPE_FILE_UPLOAD = 'ファイルアップ形式が正しくありません。';
const MSG_ALERT_CANNOT_DEL_LIST = '予定されているスケジュールに存在するリストのため削除できません。';
const MSG_ALERT_CANNOT_DEL_LISTNG = '予定されているスケジュールに存在する発信NGリストの為削除できません。';
const MSG_ALERT_DUPLICATE_CSV_COLUMN = "カラム名が重複です。フォーマットを確認してください。";
const MSG_ALERT_HEADER_NO_TEL_NO = "ヘッダーに電話番号項目が見つかりません。フォーマットを確認してください。";
const MSG_ALERT_LIMIT_CSV_COLUMN = "登録できるカラムは11個までです。フォーマットを確認してください。";
const MSG_ALERT_PLS_CHOOSE_LIST = 'リストを選択してください。';
const MSG_ALERT_NO_EXIST_LIST = '対象発信リストは存在していません。';
const MSG_ALERT_NO_EXIST_LISTNG = '対象発信リストNGは存在していません。';
const MSG_ALERT_NO_EXIST_TEL = '対象電話番号は削除されています。';
const MSG_ALERT_UPDATE_SUCCESS = '更新しました。';
const MSG_ALERT_DEL_SUCCESS = '削除しました。';
const MSG_ALERT_PLS_CHOOSE_TEL = '削除対象の電話番号を選択してください。';
const MSG_ALERT_PLS_CHANGE_TEL = '無効項目を変更してください。';
const MSG_ALERT_UPDATE_MUKO_SUCCESS = '無効項目が変更されました。';
const MSG_ALERT_INSERT_SUCCESS = '登録しました。';
const MSG_ALERT_HEADER_NOT_NULL = "カラム名が空欄です。フォーマットを確認してください。";
const MSG_ALERT_LIST_CALLING_DEL_TEL = "対象リストは実行中のスケジュールに存在するため削除できません。";
const MSG_ALERT_LIST_CALLING_ADD_TEL = "対象リストは実行中のスケジュールに存在するため新規登録できません。";
const MSG_ALERT_LIST_CALLING_EDIT_TEL = "対象リストは実行中のスケジュールに存在するため編集できません。";
const MSG_ALERT_LIMIMT_MAX_TEL = "発信リストは12万件を超えているため登録できません。";
const MSG_ALERT_LIMIMT_MAX_TEL_INBOUND_CALL_LIST = "着信リストは13万件を超えているため登録できません。";
const MSG_ALERT_UPDATE_MUKO_ERROR = "発信が完了したchが存在するためご指定番号の発信を停止できませんでした。該当番号がリダイヤルに含まれる場合には、該当番号の発信は無効となります。";

const MSG_CONFIRM_DEL = '削除します。よろしいですか？';
const MSG_CONFIRM_UPDATE = '更新します。よろしいですか？';
const MSG_CONFIRM_UPLOAD = 'アップロードします。よろしいですか？';
const MSG_CONFIRM_CONTINUE = '保存します。よろしいですか？';

/* manage_user*/
const MSG_CONFIRM_UNLOCK_USER = "選択したユーザーのロックを解除します。 よろしいでしょうか？";
const MSG_CONFIRM_DELETE_USER = "選択したユーザーを削除します。 よろしいでしょうか？";

const MSG_ALERT_SYSTEM_ERROR = 'システムのエラーが発生しました。';
const MSG_ALERT_NO_EXIST_USER = 'このユーザを存在されません。';
const MSG_ALERT_UNLOCK_SUCCESS = 'ユーザを解除しました。';
const MSG_ALERT_INSERT_USER_SUCCESS = '登録しました。';
const MSG_ALERT_UPDATE_USER_SUCCESS = '更新しました。';
const MSG_ALERT_PLS_CHOOSE_USER = 'ユーザーを選択してください。';
const MSG_ALERT_DELETE_SUCCESS = 'ユーザを削除しました。';
const MSG_ALERT_FAILED_USER_MANAGE_CHECK = 'ユーザー操作に失敗しました。お手数をおかけいたしますが、再度ユーザー操作をお願い致します。';

const MSG_ERROR_PASSWORD_NOT_CHANGE = 'パスワードは既に存在されています。';
const MSG_ERROR_REQUIRED_COMPANY = 'アカウントを選択してください。';
const MSG_ERROR_REQUIRED_USER = 'ユーザIDを入力してください。';
const MSG_ERROR_DUPLICATE_USER = 'このユーザーIDは使用済みのため、登録出来ません。';
const MSG_ERROR_REQUIRED_PASS = 'パスワードを入力してください。';
const MSG_ERROR_NOT_MATCH_PASS = 'パスワードと確認用パスワードは違いました。';
const MSG_ERROR_REQUIRED_POST_CODE = '権限を選択してください。';

/* manage menu */
const MSG_CONFIRM_SAVE = '保存します。よろしいでしょうか？';
const MSG_ERROR_MUST_CHECK = 'チェックがないアカウントが存在します。';

/* download result */
const MSG_ERROR_BLANK_DIVISION = '区分を選択してください。';
const MSG_ERROR_BLANK_COMPANY = 'アカウントを選択してください。';
const MSG_ERROR_BLANK_DATE_FROM = '日付を選択してください。';
const MSG_ERROR_BLANK_DATE_TO = '日付を選択してください。';
const MSG_CONFIRM_DOWNLOAD = 'ダウンロードします。よろしいですか？';
const MSG_ERROR_LIMIT_COUNT_1 = 'データ件数が20万件を超えているので、ダウンロードできません。\n取得しようとしているデータ件数は';
const MSG_ERROR_LIMIT_COUNT_2 = '件です。';
const MSG_ERROR_DATE_FROM_GREATER_THAN_DATE_TO = '日付の開始と終了が逆です。';
const MSG_ERROR_COUNT_DATE_31 = '日付の範囲は31日以内にしてください。';

/* message for schedule screen */
const SCHEDULE_MSG_ERROR_BLANK_CALL_TIME = '時間帯を選択してください。';
const SCHEDULE_MSG_ERROR_BLANK_CREATE_DATE = '発信日を入力してください。';
const SCHEDULE_MSG_ERROR_DATETIME_LT_NOW = '現在の日時以降を指定してください。';
const SCHEDULE_MSG_ERROR_BLANK_TIME_END = '発信終了時間を選択してください。';
const SCHEDULE_MSG_ERROR_TIME_END_LT_NOW = '他の時間帯を選択してください。';
const SCHEDULE_MSG_ERROR_BLANK_NAME = 'スケジュール名を入力してください。';
const SCHEDULE_MSG_ERROR_OVER_LENGTH_1 = 'スケジュール名は';
const SCHEDULE_MSG_ERROR_OVER_LENGTH_2 = '桁以下で入力してください。';
const SCHEDULE_MSG_ERROR_NAME_EXIST = '指定されたスケジュール名はすでに登録されています。';
const SCHEDULE_MSG_ERROR_BLANK_CALL_TYPE = '番号通知を選択してください。';
const SCHEDULE_MSG_ERROR_BLANK_EXTERNAL_NUMBER = '発信番号を選択してください。';
const SCHEDULE_MSG_ERROR_BLANK_TEMPLATE = '発信テンプレートを選択してください。';
const SCHEDULE_MSG_ERROR_BLANK_LIST = '発信リストを選択してください。';
const SCHEDULE_MSG_ERROR_BLANK_PROCNUM = 'ch数を選択してください。';
const SCHEDULE_MSG_ERROR_TERM_VALID = '以下の数字を入力してください。';
const SCHEDULE_MSG_ERROR_TERM_CONNECT = '以下の数字を入力してください。';
const SCHEDULE_MSG_ERROR_BLANK_RECALL_TIME = 'リダイヤル間隔を入力してください。';
const SCHEDULE_MSG_ERROR_NOT_DIGIT_RECALL_TIME = '数字のみ入力してください。';
const SCHEDULE_MSG_ERROR_CONSENTDAY_NOT_FOUND = '指定された送信リストには履歴判定用の利用承諾日が存在しません。'; // #8298 add consentday


const SCHEDULE_MSG_ALERT_PLS_CHOOSE_SCHEDULE = 'スケジュールを選択してください。';
const SCHEDULE_MSG_ALERT_NOT_EXIST_SCHEDULE = '対象スケジュールは削除されています。';
const SCHEDULE_MSG_ALERT_CANNOT_DEL_SCHEDULE = 'このスケジュールは削除不可の状態になっています。';
const SCHEDULE_MSG_ALERT_SCHEDULE_IS_LOCKING = '対象スケジュールは他ユーザーが更新中です。';
const SCHEDULE_MSG_ALERT_CANNOT_DOWNLOAD_SCHEDULE = '対象スケジュールはダウンロード不可の状態になっています。';
const SCHEDULE_MSG_ALERT_OVER_CH_1 = '対象時間帯のch数が';
const SCHEDULE_MSG_ALERT_OVER_CH_2 = 'を超えています(使用可能ch数は';
const SCHEDULE_MSG_ALERT_OVER_CH_3 = 'です)。';
const SCHEDULE_MSG_ALERT_OVER_CH_4 = 'を超えています(使用可能ch数がありません)。';
const SCHEDULE_MSG_ALERT_OVER_SCHEDULE_1 = '対象日のスケジュールが';
const SCHEDULE_MSG_ALERT_OVER_SCHEDULE_2 = 'を超えています。';
const SCHEDULE_MSG_ERR_OVER_SCHEDULE_1 = '発呼制限を超えたため登録できません。';
const SCHEDULE_MSG_ERR_OVER_SCHEDULE_2 = '株式会社グリーン・シップまでご連絡下さい。';
const SCHEDULE_MSG_ALERT_KAISEN_INVALID = '発信番号の回線情報が存在しないため登録できません。';
const SCHEDULE_MSG_ALERT_STOP_ERROR = 'エラーが発生されました。';
const SCHEDULE_MSG_ALERT_RESTART_ERROR = 'エラーが発生しました。';
const SCHEDULE_MSG_ALERT_SAVE_ERROR = 'エラーが発生しました。';
const SCHEDULE_MSG_ALERT_NOT_EXIST_LIST_NG = '対象発信NGリストは削除されています。';
const SCHEDULE_MSG_ALERT_NOT_EXIST_TEMPLATE = '対象発信テンプレートは削除されています。';
const SCHEDULE_MSG_ALERT_NOT_EXIST_LIST = '対象発信リストは削除されています。';
const SCHEDULE_MSG_ALERT_LIST_LOCKED = '対象発信リストは更新中のため設定できません。';
const SCHEDULE_MSG_ALERT_TEMPLATE_LOCKED = '対象発信テンプレートは更新中のため設定できません。';
const SCHEDULE_MSG_ALERT_NOT_EXIST_ITEM = '指定したテンプレートは発信リストに下記のいずれかの項目が存在しないため登録出来ません。\n　・音声合成読み上げ項目\n　・数値認証項目\n　・SMS挿入項目';
const SCHEDULE_MSG_ALERT_OVER_MAX_ITEM_1 = 'テンプレートの対象音声合成項目又は認証項目があるため発信リスト件数が';
const SCHEDULE_MSG_ALERT_OVER_MAX_ITEM_2 = '件以上超えません。';
const SCHEDULE_MSG_ALERT_SAME_OTHER_SCHEDULE = '登録対象日付に同じ発信リスト・NGリスト・発信テンプレートの組み合わせのスケジュールが存在するため登録できません。\n登録済みのスケジュールを削除してから登録してください。';
const SCHEDULE_MSG_ALERT_UPDATE_SCHEDULE_RUNNING = '対象スケジュールは実行中のため更新できません。';
const SCHEDULE_MSG_ALERT_NOSTOP_NOWAIT = '対象スケジュールは実行中のためステータスが「終了」に更新できません。';
const SCHEDULE_MSG_ALERT_EXIST_YUKO = '対象テンプレートの有効質問が存在しないのため自動停止有効を設定できません。';

const SCHEDULE_MSG_CONFIRM_DEL = 'スケジュールを削除します。よろしいですか？';
const SCHEDULE_MSG_CONFIRM_STOP = '停止します。よろしいですか？';
const SCHEDULE_MSG_CONFIRM_RESTART = '再開します。よろしいですか？';
const SCHEDULE_MSG_CONFIRM_CREATE = '登録します。よろしいですか？';
const SCHEDULE_MSG_CONFIRM_UPDATE = '更新します。よろしいですか？';
const SCHEDULE_MSG_CONFIRM_DUPLICATE = '複製します。よろしいですか？';
const SCHEDULE_MSG_CONFIRM_CALL = '即時発信します。よろしいですか？';
const SCHEDULE_MSG_CONFIRM_DEL_EVENT = '削除します。よろしいでしょうか。？';
const SCHEDULE_MSG_CONFIRM_EXPIRED_LIST_NG = '発信NGリストは有効期間外のため反映されません。';

const MSG_ALERT_PLS_CHOOSE_TEMPLATE = 'テンプレートを選択してください。';
const MSG_ALERT_INSERT_ACCOUNT_SUCCESS = '登録しました。';
const MSG_ALERT_UPDATE_ACCOUNT_SUCCESS = '更新しました。';
const MSG_ALERT_PLS_CHOOSE_ACCOUNT = 'アカウントを選択してください。';
const MSG_CONFIRM_DELETE_ACCOUNT = '削除します。よろしいですか？';
const MSG_ALERT_DELETE_ACCOUNT_SUCCESS = '削除しました。';
const MSG_ALERT_ACCOUNT_NOT_EXIST = 'アカウントは存在されていません。';
const MSG_CONFIRM_DELETE_NUMBER = '削除します。よろしいですか？';

const MSG_ALERT_CHANGE_PASS_SUCCESS = 'パスワードが変更されました。';

/* Template page */
const MSG_ALERT_NO_EXIST_TEMPLATE = '対象テンプレートは削除されています。';

/* 20160226 Add by Giang : #6532 - get msg error for call_list_ng index screen - start */
/* message for call list ng screen */
const MSG_ALERT_OVER_TEL_NG_RECORD = '2万行を超えるファイルはアップロードできません。';
const MSG_ALERT_OVER_INBOUND_TEL_NG_RECORD = '1万行を超えるファイルはアップロードできません。';
const MSG_ALERT_OVER_100TEL_RECORD = '100行を超えるファイルはアップロードできません。';
const MSG_ERROR_REQUIRED_FILE = 'ファイルを選択してください。';
const MSG_ERROR_LIMIT_100LINE = '登録上限は100件です。';
const MSG_ALERT_NO_CHOSSE_DATE_TO = '期間終了日を入力してください。';
const MSG_ALERT_NO_CHOSSE_DATE_FROM = '期間開始日を入力してください。';
const MSG_ALERT_EXPIRED_ERROR = '開始期間日以降を入力してください。';

/* 20160226 Add by Giang : #6532 - get msg error for call_list_ng index screen - end */

/* 20160316 Add by Giang : #6711 - Inbound Restrict index screen- start */
const MSG_ALERT_CANNOT_DEL_LIST_INCOMING_NG = '予定されているスケジュールに存在する着信拒否リストの為削除できません。';
/* 20160316 Add by Giang : #6711 - Inbound Restrict index screen- end */

/* 20160317 Add by Giang : #6740 - Inbound call list screen - start */
const INBOUND_INSERT_CALL_LIST_SUCCESS = 'リストのアップロードが完了しました。';
const INBOUND_ITEM_MAIN_INVALID = 'を選択してください。';
const INBOUND_DETAIL_ITEM_MAIN_INVALID = '指定した照合項目は重複または空白があるため使用できません。'; // 20160406 Edit by Giang - #6740: check item main unique
const INBOUND_CANNOT_DEL_LIST = '現在、設定されている着信リストのため、削除できません。';
const INBOUND_ITEM_MAIN_DUPLICATE1 = '照合項目に重複データが存在するため登録できません。（'; // 20160406 Edit by Giang - #6740: check item main unique
const INBOUND_ITEM_MAIN_DUPLICATE2 = '行目）。';
const INBOUND_ITEM_MAIN_EMPTY1 = '照合項目に空白データが存在するため登録できません。（';
const INBOUND_ITEM_MAIN_EMPTY2 = '行目）。'; // 20160406 Edit by Giang - #6740: check item main unique
/* 20160317 Add by Giang : #6740 -  Inbound call list screen - end */

/* message for setting inbound screen */
const INBOUND_MSG_CONFIRM_CREATE = '登録します。よろしいですか？';
const INBOUND_MSG_CONFIRM_DUPLICATE = '複製します。よろしいですか？';
const INBOUND_MSG_CONFIRM_DEL = '削除します。よろしいですか？';

const INBOUND_MSG_ALERT_EXTERNAL_NUMBER_LOCKED = '対象電話番号は別のユーザにて着信設定中のため設定できません。';
const INBOUND_MSG_ALERT_EXTERNAL_NUMBER_GET_LOCKED = '対象電話番号のロックに失敗しました。';
const INBOUND_MSG_ALERT_NOT_EXIST_TEMPLATE = '対象着信テンプレートは削除されています。';
const INBOUND_MSG_ALERT_NOT_EXIST_LIST_NG = '対象着信拒否リストは削除されています。';
const INBOUND_MSG_ALERT_NOT_EXIST_LIST = '対象着信リストは削除されています。';

const INBOUND_MSG_ALERT_TEMPLATE_LOCKED = '対象着信テンプレートは更新中のため設定できません。';
const INBOUND_MSG_ALERT_LIST_NG_LOCKED = '対象着信拒否リストは更新中のため設定できません。';
const INBOUND_MSG_ALERT_LIST_LOCKED = '対象着信リストは更新中のため設定できません。';
const INBOUND_MSG_ALERT_SAVE_ERROR = 'エラーが発生しました。';

const INBOUND_MSG_ALERT_PLS_CHOOSE_INBOUND = '着信設定を選択してください。';
const INBOUND_MSG_ALERT_NOT_EXIST_INBOUND = '対象着信設定は削除されています。';
const INBOUND_MSG_ALERT_CANNOT_DEL_INBOUND = '現在、設定されている着信設定のため、削除できません。';
const INBOUND_MSG_ALERT_CANNOT_DOWNLOAD_INBOUND = '着信設定がbusyのため、ダウンロードできません。';

/*20160427 Add by Giang - #7074 - Sms template screen - Begin*/
const MSG_ERROR_REQUIRED_SMS_TEMPLATE_NAME = 'テンプレート名を入力してください。';
const MSG_ERROR_EXIST_SMS_TEMPLATE_NAME = '指定したテンプレート名は既に使用しています。';
const MSG_ERROR_REQUIRED_SMS_TEM_DESCRIPTION = '説明を入力してください。';
const MSG_ERROR_REQUIRED_SMS_TEM_CONTENT = '本文を入力してください。';
//const MSG_CONFIRM_SMS_TEM_ADD = 'ポップアップを閉じます。 よろしいですか？';
const MSG_CONFIRM_SMS_TEM_ADD = '保存します。よろしいですか？';
const MSG_CONFIRM_SMS_TEM_UPDATE = '更新します。よろしいですか？';
const MSG_CONFIRM_SMS_TEM_UPDATE_CLOSE_POPUP = 'ポップアップを閉じます。 よろしいですか？';
const MSG_ALERT_SMS_TEM_ADD_SUCCESS = '保存しました';
const MSG_ALERT_SMS_TEM_DEL_SUCCESS = '正常に削除されました';
const MSG_ALERT_SMS_TEM_UPDATE_SUCCESS = '更新しました。';
const MSG_ALERT_PLS_CHOOSE_SMS_TEMPLATE = 'テンプレートを選択してください。';
const MSG_ALERT_NO_EXIST_SMS_TEMPLATE = '対象テンプレートは削除されています。';
const MSG_ALERT_USED_TEMPLATE = '予定されているスケジュールに存在するテンプレートの為削除できません。';
/*20160427 Add by Giang - #7074 - Sms template screen - End*/

/*20160511 Add by Giang - #7108 - Sms schedule screen - Begin*/
const SMS_SCHEDULE_MSG_ERROR_NAME_EXIST = '予定されているスケジュール名はすでに登録されています';
const SMS_SCHEDULE_MSG_ERROR_BLANK_TEMPLATE = 'テンプレートを選択してくだい。';
const SMS_SCHEDULE_MSG_ALERT_LIST_TEMPLATE_USED = '登録対象日付に同じ送信リスト・送信テンプレートの組み合わせのスケジュールが存在するため登録できません。\n登録済みのスケジュールを削除してから登録してください。';
const SMS_SCHEDULE_MSG_ALERT_LIST_LOCKED = '対象送信リストは更新中の為設定できません。';
const SMS_SCHEDULE_MSG_ALERT_TEMPLATE_LOCKED = '対象送信テンプレートは更新中の為設定できません。';
const SMS_SCHEDULE_MSG_ERROR_BLANK_CREATE_DATE = '送信日を入力してください。';
const SMS_SCHEDULE_MSG_ERROR_BLANK_TIME_END = '送信終了時間を選択してください。';
const SMS_SCHEDULE_MSG_ERROR_BLANK_SERVICE_ID = '通知番号を選択してください。';
const SMS_SCHEDULE_MSG_ERROR_BLANK_LIST = '送信リストを選択してください。';
const SMS_SCHEDULE_MSG_ALERT_NOT_EXIST_TEMPLATE = '対象送信テンプレートは削除されています。';
const SMS_SCHEDULE_MSG_ALERT_NOT_EXIST_LIST = '対象送信リストは削除されています。';
const SMS_SCHEDULE_MSG_CONFIRM_CALL = '即時送信します。よろしいですか？';
const SMS_SCHEDULE_MSG_ALERT_SERVICE_USED = 'を既に設定しました。 その間に設定しないでください。';
const SMS_MSG_BODY_INVALID = '本文に「$」文字は使用出来ません。';
const SMS_MSG_BODY_ITEM_REACH_LIMIT = 'SMS本文が挿入項目値を含めて'+SMS_MAX_LENGTH+'文字を超えているため、登録できません。';
const SMS_MSG_ALERT_NOT_EXIST_ITEM = '指定したテンプレートは送信リストに挿入項目が存在しないため登録出来ません。';
/*20160511 Add by Giang - #7108 - Sms schedule screen - End*/

const OUTBOUND_QUESTION_SMS_PHONE_EMPTY = '通知番号を選択してください。';
const OUTBOUND_QUESTION_SMS_BODY_EMPTY = '本文を入力してください。';
const OUTBOUND_QUESTION_SMS_BODY_REACH_LIMIT = '本文は'+SMS_MAX_LENGTH+'文字以下を入力してください。';
const OUTBOUND_QUESTION_SMS_BODY_INVALID = '本文に「$」文字は使用出来ません。';
const OUTBOUND_EXPORT_EXIST_QUESTION_SMS = 'SMSセクションまたは番号指定SMSセクションが存在するため、エクスポートできません。';
const OUTBOUND_CHECK_DISPLAY_NUMBER = '同一テンプレート内でSMSの通知番号を混在させることはできません。';
const OUTBOUND_CHECK_USE_SHORT_URL = '同一テンプレート内でSMSの短縮URLあり・なしを混在させることはできません。';
const OUTBOUND_SCHEDULE_SETTING_INTERVAL_MESSAGE = SCHEDULE_SETTING_INTERVAL+'分以内にスケジュールが設定されている場合は、即時発信はできません。';
const OUTBOUND_SCHEDULE_SETTING_UPDATE_INTERVAL_MESSAGE = '発信が' + SCHEDULE_SETTING_UPD_DEL_INTERVAL + '分以内に開始されるため、更新できません。';
const OUTBOUND_SCHEDULE_SETTING_DELETE_INTERVAL_MESSAGE = '発信が' + SCHEDULE_SETTING_UPD_DEL_INTERVAL + '分以内に開始されるスケジュ－ルが含まれるため、削除できません。';

const INBOUND_EXPORT_EXIST_QUESTION_PROPERTY_SEARCH = '物件入力(賃料、平米)セクションが存在するため、エクスポートできません。';

const INBOUND_QUESTION_SMS_PHONE_EMPTY = '通知番号を選択してください。';
const INBOUND_QUESTION_SMS_BODY_EMPTY = '本文を入力してください。';
const INBOUND_QUESTION_SMS_BODY_REACH_LIMIT = '本文は'+SMS_MAX_LENGTH+'文字以下を入力してください。';
const INBOUND_EXPORT_EXIST_QUESTION_SMS = '通知番号SMS送信セクションまたは番号指定SMSセクションが存在するため、エクスポートできません。';
const INBOUND_EXPORT_EXIST_QUESTION_INBOUND_COLLATION = '着信番号照合セクションが存在するため、エクスポートできません。';
const INBOUND_QUESTION_SMS_BODY_INVALID = '本文に「$」文字は使用出来ません。';
const INBOUND_COLLATION_ERROR = '着信番号照合が存在するテンプレートの場合、電話番号が入っている着信リストを設定してください。';
const SMS_BODY_ITEM_REACH_LIMIT = 'SMS本文が挿入項目値を含めて'+SMS_MAX_LENGTH+'文字を超えているため、登録できません。\n発信リスト内に無効フラグが付いているデータもチェック対象となります。';
const INBOUND_SMS_BODY_ITEM_REACH_LIMIT = 'SMS本文が挿入項目値を含めて'+SMS_MAX_LENGTH+'文字を超えているため、登録できません。';
const ADD_LIST_SMS_BODY_ITEM_REACH_LIMIT = '予定しているスケジュールのSMS本文が'+SMS_MAX_LENGTH+'文字を超えるため、登録できません。';
const ADD_LIST_SMS_BODY_ITEM_ILLEGAL_STRING = '予定しているスケジュールの短縮URLで利用できない禁則文字が挿入項目に入っているため、登録できません。';
const SMS_BODY_ITEM_REACH_LIMIT_SHORT_URL = 'SMS本文が、短縮前のURLと挿入項目値を含めて300文字を超えているため、登録できません。\n発信リスト内に無効フラグが付いているデータもチェック対象となります。';

const SMS_ILLEGAL_STRING_IN_BODY_URL = '短縮URLで利用できない禁則文字がURL中に入っています。';
const SMS_ILLEGAL_USE_SHORT_URL = '短縮URLはAPIバージョン２でのみご利用可能です。';
const SMS_INVALID_USE_SHORT_URL = '選択した通知番号では、短縮URLをご利用できません。';
const SMS_OVER_COUNT_IN_BODY_URL = '短縮URLを利用する場合は、本文のURLは最大'+SMS_MAX_URL_COUNT+'つです。';
const SMS_ILLEGAL_POSITION_TRACKING_CODE = '挿入項目「トラッキングコード１」または「トラッキングコード２」がURL以外の箇所に存在しています。';
const SMS_SCHEDULE_SETTING_INTERVAL_MESSAGE = SCHEDULE_SETTING_INTERVAL+'分以内にスケジュールが設定されている場合は、即時送信はできません。';
const SMS_SCHEDULE_SETTING_UPDATE_INTERVAL_MESSAGE = '送信が' + SCHEDULE_SETTING_UPD_DEL_INTERVAL + '分以内に開始されるため、更新できません。';
const SMS_SCHEDULE_SETTING_DELETE_INTERVAL_MESSAGE = '送信が' + SCHEDULE_SETTING_UPD_DEL_INTERVAL + '分以内に開始されるスケジュ－ルが含まれるため、削除できません。';
