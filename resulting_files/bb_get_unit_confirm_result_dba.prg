CREATE PROGRAM bb_get_unit_confirm_result:dba
 RECORD reply(
   1 result_code_set_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE history_code_value = f8 WITH noconstant(0.0)
 DECLARE verified_code_value = f8 WITH noconstant(0.0)
 DECLARE corrected_code_value = f8 WITH noconstant(0.0)
 DECLARE cv_cnt = i4 WITH noconstant(1)
 DECLARE dta_cd = f8 WITH noconstant(0.0)
 DECLARE history_upd_meaning = c12 WITH noconstant(fillstring(12," "))
 DECLARE verified_meaning = c12 WITH noconstant(fillstring(12," "))
 DECLARE corrected_meaning = c12 WITH noconstant(fillstring(12," "))
 DECLARE stat = i2 WITH noconstant(0)
 DECLARE errormsg = c132 WITH noconstant(fillstring(132," "))
 DECLARE errorcheck = i2 WITH noconstant(error(errormsg,1))
 DECLARE scriptname = c25 WITH constant("BB_GET_UNIT_CONFIRM_RESULT")
 SET history_upd_meaning = "HISTRY & UPD"
 SET verified_meaning = "VERIFIED"
 SET corrected_meaning = "CORRECTED"
 SET reply->status_data.status = "F"
 SET cv_cnt = 1
 SET stat = uar_get_meaning_by_codeset(1636,history_upd_meaning,cv_cnt,history_code_value)
 IF (stat != 0)
  CALL errorhandler(scriptname,"F","Failed UAR: HISTRY & UPD",
   "An error occurred attempting to retrieve the code value with CDF_Meaning of HISTRY & UPD from codeset 1636"
   )
 ENDIF
 SET cv_cnt = 1
 SET stat = uar_get_meaning_by_codeset(1901,verified_meaning,cv_cnt,verified_code_value)
 IF (stat != 0)
  CALL errorhandler(scriptname,"F","Failed UAR: VERIFIED",
   "An error occurred attempting to retrieve the code value with CDF_Meaning of VERIFIED from codeset 1901"
   )
 ENDIF
 SET cv_cnt = 1
 SET stat = uar_get_meaning_by_codeset(1901,corrected_meaning,cv_cnt,corrected_code_value)
 CALL echo(corrected_code_value)
 IF (stat != 0)
  CALL errorhandler(scriptname,"F","Failed UAR: CORRECTED",
   "An error occurred attempting to retrieve the code value with CDF_Meaning of CORRECTED from codeset 1901"
   )
 ENDIF
 IF ((request->debug_ind=1))
  CALL echo(build("HISTRY=",history_code_value))
  CALL echo(build("VERIFIED=",verified_code_value))
  CALL echo(build("CORRECTED=",corrected_code_value))
  CALL echo(build("CURQUAL=",curqual))
  CALL echo(build("DTA=",dta_cd))
 ENDIF
 SELECT INTO "nl:"
  pr.result_code_set_cd
  FROM perform_result pr,
   result r,
   orders o,
   discrete_task_assay dta
  PLAN (o
   WHERE (o.product_id=request->product_id))
   JOIN (r
   WHERE r.order_id=o.order_id
    AND ((r.result_status_cd=verified_code_value) OR (r.result_status_cd=corrected_code_value)) )
   JOIN (dta
   WHERE dta.task_assay_cd=r.task_assay_cd
    AND dta.bb_result_processing_cd=history_code_value)
   JOIN (pr
   WHERE pr.result_id=r.result_id
    AND pr.result_status_cd=r.result_status_cd)
  ORDER BY pr.perform_dt_tm
  DETAIL
   reply->result_code_set_cd = pr.result_code_set_cd
  WITH nocounter, maxqual(pr,1)
 ;end select
 SET errorcheck = error(errormsg,0)
 IF (errorcheck != 0)
  CALL errorhandler(scriptname,"F","PERFORM_RESULT select",errormsg)
  GO TO exitscript
 ENDIF
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSEIF (curqual=1)
  SET reply->status_data.status = "S"
 ENDIF
 SUBROUTINE (errorhandler(operationname=c25,operationstatus=c1,targetobjectname=vc,targetobjectvalue=
  vc) =null)
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = operationname
   SET reply->status_data.subeventstatus[1].operationstatus = operationstatus
   SET reply->status_data.subeventstatus[1].targetobjectname = targetobjectname
   SET reply->status_data.subeventstatus[1].targetobjectvalue = targetobjectvalue
 END ;Subroutine
#exitscript
 IF ((request->debug_ind=1))
  CALL echorecord(request)
  CALL echorecord(reply)
 ENDIF
END GO
