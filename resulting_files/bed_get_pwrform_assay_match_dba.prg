CREATE PROGRAM bed_get_pwrform_assay_match:dba
 FREE SET reply
 RECORD reply(
   1 task_assay_uid = vc
   1 description = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM cnt_dta_key2 dk,
   cnt_dta d
  PLAN (dk
   WHERE (dk.task_assay_cd=request->task_assay_code_value))
   JOIN (d
   WHERE d.task_assay_uid=dk.task_assay_uid)
  DETAIL
   reply->task_assay_uid = d.task_assay_uid, reply->description = d.mnemonic
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
