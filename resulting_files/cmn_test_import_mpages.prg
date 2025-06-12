CREATE PROGRAM cmn_test_import_mpages
 PROMPT
  "outdev" = "MINE",
  "json" = "",
  "cid" = "",
  "flag" = 0,
  "impFile" = ""
  WITH outdev, json, cid,
  flag, impfile
 SUBROUTINE (mock_tdbexecute(app=i4,task=i4,req_num=i4,req_type=vc,request=vc(ref),rep_type=vc,rep=vc
  (ref)) =i4 WITH protect)
   CALL echo("mock_tdbexecute")
   CALL echorecord(request)
   SET reqjson = cnvtrectojson(request)
   RETURN(0)
 END ;Subroutine
 RECORD replyout(
   1 wtf = vc
 )
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE action = vc WITH protect, noconstant("")
 DECLARE reconcile_filename = vc WITH protect, noconstant("")
 DECLARE reqjson = vc WITH protect, noconstant("")
 IF (validate(_memory_reply_string)=false)
  DECLARE _memory_reply_string = vc WITH protect, noconstant("")
 ENDIF
 EXECUTE pex_mp_imp_call_srv  $OUTDEV,  $JSON,  $CID,
  $FLAG,  $IMPFILE WITH replace("TDBEXECUTE",mock_tdbexecute)
 SET stat = cnvtjsontorec(reqjson)
 SET stat = cnvtjsontorec(_memory_reply_string)
 CALL echorecord(reply)
 IF ((reply->validation_flag=1))
  SET action = "VALIDATE"
 ELSE
  SET action = "REVALIDATE"
 ENDIF
 FREE RECORD reply
 RECORD reply(
   1 reconcile_filename = vc
   1 unmatched_items = i4
   1 matched_items = i4
   1 suggestions = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 CALL echo("***********************************************************************")
 CALL echo("***********************************************************************")
 CALL echo(build2("BEGIN ",action))
 CALL echo("***********************************************************************")
 CALL echo("***********************************************************************")
 EXECUTE pex_mp_vp_import_wrapper
 CALL echorecord(reply)
 SET reconcile_filename = reply->reconcile_filename
 FREE RECORD request
 FREE RECORD reply
 EXECUTE pex_mp_imp_call_srv  $OUTDEV,  $JSON,  $CID,
 2, reconcile_filename WITH replace("TDBEXECUTE",mock_tdbexecute)
 SET stat = cnvtjsontorec(reqjson)
 RECORD reply(
   1 reconcile_filename = vc
   1 unmatched_items = i4
   1 matched_items = i4
   1 suggestions = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 CALL echo("***********************************************************************")
 CALL echo("***********************************************************************")
 CALL echo("BEGIN IMPORT")
 CALL echo("***********************************************************************")
 CALL echo("***********************************************************************")
 EXECUTE pex_mp_vp_import_wrapper
 CALL echorecord(reply)
END GO
