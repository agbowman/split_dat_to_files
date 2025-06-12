CREATE PROGRAM ams_esh_backup:dba
 PROMPT
  "Number of days to save backup files: " = ""
  WITH numdays
 DECLARE emailfile(vcrecep=vc,vcfrom=vc,vcsubj=vc,vcbody=vc,vcfile=vc) = i2 WITH protect
 DECLARE getclient(null) = vc WITH protect
 DECLARE cfrom = c25 WITH protect, constant("ams_esh_backup@cerner.com")
 DECLARE clientstr = vc WITH constant(getclient(null)), protect
 DECLARE cemptystr = c2 WITH constant("-1"), protect
 DECLARE vcsubject = vc WITH noconstant(build2("AMS Event Set Hierarchy Backup ",clientstr,": ",
   curdomain)), protect
 DECLARE script_name = c14 WITH protect, constant("AMS_ESH_BACKUP")
 DECLARE emailind = i2 WITH protect
 DECLARE i = i4 WITH protect
 DECLARE filename = vc WITH protect
 DECLARE purgefilename = vc WITH protect
 DECLARE backupdays = i4 WITH protect
 SET backupdays = cnvtint( $NUMDAYS)
 SET filename = trim(cnvtlower(concat(clientstr,"_esh_unload_",format(cnvtdatetime(curdate,curtime3),
     "mm_dd_yy;;D"),".csv")))
 SET purgefilename = trim(cnvtlower(concat(clientstr,"_esh_unload_",format(cnvtdatetime((curdate -
      value(backupdays)),curtime3),"mm_dd_yy;;D"),".csv")))
 RECORD esh_request(
   1 filename = vc
 ) WITH protect
 SET trace = nocallecho
 EXECUTE ams_define_toolkit_common
 SET trace = callecho
 IF (cemptystr=validate(request->batch_selection,cemptystr))
  IF ( NOT (validate(reply,0)))
   RECORD reply(
     1 ops_event = vc
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
  ENDIF
  IF ( NOT (validate(request,0)))
   RECORD request(
     1 batch_selection = vc
     1 output_dist = vc
     1 ops_date = dq8
   )
  ENDIF
 ENDIF
 SET esh_request->filename = filename
 IF (trim(request->output_dist) > " ")
  SET emailind = 1
 ENDIF
 SET stat = tdbexecute(4170400,4170401,4170030,"REC",esh_request,
  "REC",esh_reply)
 IF ((esh_reply->status=0))
  SET reply->status_data.status = "S"
  SET reply->ops_event = build2("Successfully created backup ESH file: ",filename)
  SET trace = nocallecho
  CALL updtdminfo(script_name,1.0)
  SET trace = callecho
 ELSE
  SET reply->status_data.status = "F"
  SET reply->ops_event = "Failed creating backup ESH file"
 ENDIF
 IF (emailind=1
  AND (reply->status_data.status="S"))
  CALL emailfile(trim(request->output_dist),cfrom,vcsubject,"",filename)
  IF (validate(esh_reply->index))
   IF ((esh_reply->index > 0))
    FOR (i = 1 TO esh_reply->index)
      SET filename = substring(1,(textlen(filename) - 4),filename)
      SET filename = concat(filename,"0",trim(cnvtstring(i)),".csv")
      CALL echo(filename)
      CALL emailfile(trim(request->output_dist),cfrom,vcsubject,"",filename)
    ENDFOR
   ENDIF
  ENDIF
 ENDIF
 SET stat = remove(purgefilename)
 SUBROUTINE emailfile(vcrecep,vcfrom,vcsubj,vcbody,vcfile)
   DECLARE retval = i2
   RECORD email_request(
     1 recepstr = vc
     1 fromstr = vc
     1 subjectstr = vc
     1 bodystr = vc
     1 filenamestr = vc
   ) WITH protect
   RECORD email_reply(
     1 status = c1
     1 errorstr = vc
   ) WITH protect
   SET email_request->recepstr = vcrecep
   SET email_request->fromstr = vcfrom
   SET email_request->subjectstr = vcsubj
   SET email_request->bodystr = vcbody
   SET email_request->filenamestr = vcfile
   EXECUTE ams_run_email_file  WITH replace("REQUEST",email_request), replace("REPLY",email_reply)
   IF ((email_reply->status="S"))
    SET retval = 1
   ELSE
    SET retval = 0
   ENDIF
   RETURN(retval)
 END ;Subroutine
 SUBROUTINE getclient(null)
   DECLARE retval = vc WITH protect, noconstant("")
   SET retval = logical("CLIENT_MNEMONIC")
   IF (retval="")
    SELECT INTO "nl:"
     d.info_char
     FROM dm_info d
     WHERE d.info_domain="DATA MANAGEMENT"
      AND d.info_name="CLIENT MNEMONIC"
     DETAIL
      retval = trim(d.info_char)
     WITH nocounter
    ;end select
   ENDIF
   IF (retval="")
    SET retval = "unknown"
   ENDIF
   RETURN(retval)
 END ;Subroutine
 SET last_mod = "001"
END GO
