#!/bin/bash
created="$(date +'%Y-%m-%d %H:%M:%S')"
mysql -u$1 -p$2 -D $3 << EOF
LOAD DATA LOCAL INFILE '$4'
		INTO TABLE t81_incoming_results
		CHARACTER SET 'UTF8'
		FIELDS TERMINATED BY ',' enclosed by '"' LINES TERMINATED BY '\n' STARTING BY ''
		(@a_group,@tel_no,@memo,@tel_type,
		@call_datetime,@connect_datetime,@cut_datetime,
		@trans_call_datetime,@trans_connect_datetime,@trans_cut_datetime,
		@a_status,@valid_count,@ans_accuary,
		@a1,@a2,@a3,@a4,@a5,@a6,@a7,@a8,@a9,@a10,
		@a11,@a12,@a13,@a14,@a15,@a16,@a17,@a18,@a19,@a20,
		@a21,@a22,@a23,@a24,@a25,@a26,@a27,@a28,@a29,@a30,
		@a31,@a32,@a33,@a34,@a35,@a36,@a37,@a38,@a39,@a40,
		@a41,@a42,@a43,@a44,@a45,@a46,@a47,@a48,@a49,@a50,
		@a51,@a52,@a53,@a54,@a55,@a56,@a57,@a58,@a59,@a60,
		@a61,@a62,@a63,@a64,@a65,@a66,@a67,@a68,@a69,@a70,
		@a71,@a72,@a73,@a74,@a75,@a76,@a77,@a78,@a79,@a80,
		@a81,@a82,@a83,@a84,@a85,@a86,@a87,@a88,@a89,@a90,
		@a91,@a92,@a93,@a94,@a95,@a96,@a97,@a98,@a99,@a100,
		@a101,@a102,@a103,@a104,@a105,@a106,@a107,@a108,@a109,@a110,
		@a111,@a112,@a113,@a114,@a115,@a116,@a117,@a118,@a119,@a120,
		@a121,@a122,@a123,@a124,@a125,@a126,@a127,@a128,@a129,@a130,
		@a131,@a132,@a133,@a134,@a135,@a136,@a137,@a138,@a139,@a140,
		@a141,@a142,@a143,@a144,@a145,@a146,@a147,@a148,@a149,@a150,
		@a151,@a152,@a153,@a154,@a155,@a156,@a157,@a158,@a159,@a160
		)
		set
			inbound_id= '$5'
			,tel_no=SUBSTRING_INDEX(@tel_no, '_', 1)
			,prefix=SUBSTRING_INDEX(@tel_no, '_', -1)
			,memo=@memo
			,tel_type=@tel_type
			,call_datetime=@call_datetime
			,connect_datetime=@connect_datetime
			,cut_datetime=@cut_datetime
			,trans_call_datetime=@trans_call_datetime
			,trans_connect_datetime=@trans_connect_datetime
			,trans_cut_datetime=@trans_cut_datetime
			,status=@a_status
			,valid_count=@valid_count
			,ans_accuracy=@ans_accuary
			,answer1=@a1,answer2=@a2,answer3=@a3,answer4=@a4,answer5=@a5,answer6=@a6,answer7=@a7,answer8=@a8,answer9=@a9,answer10=@a10
			,answer11=@a11,answer12=@a12,answer13=@a13,answer14=@a14,answer15=@a15,answer16=@a16,answer17=@a17,answer18=@a18,answer19=@a19,answer20=@a20
			,answer21=@a21,answer22=@a22,answer23=@a23,answer24=@a24,answer25=@a25,answer26=@a26,answer27=@a27,answer28=@a28,answer29=@a29,answer30=@a30
			,answer31=@a31,answer32=@a32,answer33=@a33,answer34=@a34,answer35=@a35,answer36=@a36,answer37=@a37,answer38=@a38,answer39=@a39,answer40=@a40
			,answer41=@a41,answer42=@a42,answer43=@a43,answer44=@a44,answer45=@a45,answer46=@a46,answer47=@a47,answer48=@a48,answer49=@a49,answer50=@a50
			,answer51=@a51,answer52=@a52,answer53=@a53,answer54=@a54,answer55=@a55,answer56=@a56,answer57=@a57,answer58=@a58,answer59=@a59,answer60=@a60
			,answer61=@a61,answer62=@a62,answer63=@a63,answer64=@a64,answer65=@a65,answer66=@a66,answer67=@a67,answer68=@a68,answer69=@a69,answer70=@a70
			,answer71=@a71,answer72=@a72,answer73=@a73,answer74=@a74,answer75=@a75,answer76=@a76,answer77=@a77,answer78=@a78,answer79=@a79,answer80=@a80
			,answer81=@a81,answer82=@a82,answer83=@a83,answer84=@a84,answer85=@a85,answer86=@a86,answer87=@a87,answer88=@a88,answer89=@a89,answer90=@a90
			,answer91=@a91,answer92=@a92,answer93=@a93,answer94=@a94,answer95=@a95,answer96=@a96,answer97=@a97,answer98=@a98,answer99=@a99,answer100=@a100
			,answer101=@a101,answer102=@a102,answer103=@a103,answer104=@a104,answer105=@a105,answer106=@a106,answer107=@a107,answer108=@a108,answer109=@a109,answer110=@a110
			,answer111=@a111,answer112=@a112,answer113=@a113,answer114=@a114,answer115=@a115,answer116=@a116,answer117=@a117,answer118=@a118,answer119=@a119,answer120=@a120
			,answer121=@a121,answer122=@a122,answer123=@a123,answer124=@a124,answer125=@a125,answer126=@a126,answer127=@a127,answer128=@a128,answer129=@a129,answer130=@a130
			,answer131=@a131,answer132=@a132,answer133=@a133,answer134=@a134,answer135=@a135,answer136=@a136,answer137=@a137,answer138=@a138,answer139=@a139,answer140=@a140
			,answer141=@a141,answer142=@a142,answer143=@a143,answer144=@a144,answer145=@a145,answer146=@a146,answer147=@a147,answer148=@a148,answer149=@a149,answer150=@a150
			,answer151=@a151,answer152=@a152,answer153=@a153,answer154=@a154,answer155=@a155,answer156=@a156,answer157=@a157,answer158=@a158,answer159=@a159,answer160=@a160
			,created='$created';
EOF
