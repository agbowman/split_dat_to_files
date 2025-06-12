CREATE PROGRAM del_ocs_formulary_status:dba
 SET modify = predeclare
 CALL echo("<------------------------------------------->")
 CALL echo("<---   BEGIN: del_ocs_formulary_status   --->")
 CALL echo("<------------------------------------------->")
 DECLARE dqtimerbegindttm = dq8 WITH private, noconstant(cnvtdatetime(curdate,curtime3))
 CALL echo("====================================================")
 CALL echo(build("===     Begin Dt/Tm: ",format(dqtimerbegindttm,";;Q"),"      ==="))
 CALL echo("====================================================")
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF ( NOT (validate(errors,0)))
  RECORD errors(
    1 err_cnt = i4
    1 err[*]
      2 err_code = i4
      2 err_msg = vc
  ) WITH protect
 ENDIF
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errcnt = i4 WITH protect, noconstant(0)
 DECLARE errmsg = c132 WITH protect, noconstant(fillstring(132," "))
 DECLARE nstatus_unknown = i2 WITH private, constant(0)
 DECLARE nsuccess = i2 WITH private, constant(1)
 DECLARE nfailed_ccl_error = i2 WITH private, constant(2)
 DECLARE nscriptstatus = i2 WITH private, noconstant(nstatus_unknown)
 DECLARE nstat = i2 WITH private, noconstant(0)
 DECLARE script_version = vc WITH private, noconstant("")
 DECLARE dentirescriptdiffinsec = f8 WITH protect, noconstant(0.0)
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 DECLARE req_count = i4 WITH protect, noconstant(0)
 SET req_count = size(request->qual,5)
 IF (req_count=0)
  GO TO exit_script
 ENDIF
 DELETE  FROM (dummyt d  WITH seq = value(size(request->qual,5))),
   ocs_facility_formulary_r ocsfr
  SET ocsfr.seq = 1
  PLAN (d)
   JOIN (ocsfr
   WHERE (ocsfr.synonym_id=request->qual[d.seq].synonym_id)
    AND (ocsfr.facility_cd=request->qual[d.seq].facility_cd))
  WITH nocounter
 ;end delete
 CALL echo(build("curqual = ",curqual))
#error_processing
 CALL echo("***********************************")
 CALL echo("***   Start of error checking   ***")
 CALL echo("***********************************")
 SET errcode = error(errmsg,0)
 WHILE (errcode != 0
  AND errcnt < 6)
   SET errcnt = (errcnt+ 1)
   IF (errcnt > size(errors->err,5))
    SET nstat = alterlist(errors->err,(errcnt+ 9))
   ENDIF
   SET errors->err[errcnt].err_code = errcode
   SET errors->err[errcnt].err_msg = errmsg
   SET errors->err_cnt = errcnt
   SET errcode = error(errmsg,0)
 ENDWHILE
 SET nstat = alterlist(errors->err,errcnt)
 IF (errcnt > 0)
  SET nscriptstatus = nfailed_ccl_error
  CALL echorecord(errors)
 ELSE
  SET nscriptstatus = nsuccess
 ENDIF
#exit_script
 CALL echo("*************************************")
 CALL echo("***   Start of error processing   ***")
 CALL echo("*************************************")
 IF (nscriptstatus != nsuccess)
  ROLLBACK
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  CASE (nscriptstatus)
   OF nfailed_ccl_error:
    SET reply->status_data.subeventstatus[1].operationname = "CCL ERROR"
    SET reply->status_data.subeventstatus[1].targetobjectname = "del_ocs_formulary_status"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = errors->err[1].err_msg
  ENDCASE
 ELSEIF (curqual=0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].operationname = "Delete"
  SET reply->status_data.subeventstatus[1].targetobjectname = "del_ocs_formulary_status"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "ocs_facility_formulary_r"
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
  SET reply->status_data.subeventstatus[1].operationstatus = "S"
  SET reply->status_data.subeventstatus[1].operationname = "Delete"
  SET reply->status_data.subeventstatus[1].targetobjectname = "del_ocs_formulary_status"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "ocs_facility_formulary_r"
 ENDIF
 CALL echo("***********************************************")
 CALL echo("***   Start of internal structure cleanup   ***")
 CALL echo("***********************************************")
 FREE RECORD errors
 SET script_version = "000 30/09/09 SA016585"
 SET dentirescriptdiffinsec = datetimediff(cnvtdatetime(curdate,curtime3),dqtimerbegindttm,5)
 CALL echo("=====================================")
 CALL echo(build("===   Total Script Time in Seconds: ",dentirescriptdiffinsec,"   ==="))
 CALL echo("=====================================")
 CALL echo("<---------------------------------------->")
 CALL echo("<---   END del_ocs_formulary_status   --->")
 CALL echo("<---------------------------------------->")
END GO
