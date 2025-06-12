CREATE PROGRAM bbt_get_task_assays:dba
 RECORD reply(
   1 qual[*]
     2 task_assay_cd = f8
     2 mnemonic = c40
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET err_cnt = 0
 SET qual_cnt = 0
 SET reply->status_data.status = "F"
 SET bb_result_processing_cd = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET cdf_meaning = request->cdf_meaning
 SET stat = uar_get_meaning_by_codeset(1636,cdf_meaning,1,bb_result_processing_cd)
 CALL echo(bb_result_processing_cd)
 IF (stat=1)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "UAR SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "1636"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Unable to retrieve bb result processing cd"
  GO TO end_script
 ENDIF
 SELECT INTO "nl:"
  d.task_assay_cd, d.mnemonic
  FROM discrete_task_assay d
  WHERE d.bb_result_processing_cd=bb_result_processing_cd
   AND d.active_ind=1
  HEAD REPORT
   err_cnt = 0, qual_cnt = 0
  DETAIL
   qual_cnt = (qual_cnt+ 1), stat = alterlist(reply->qual,qual_cnt), reply->qual[qual_cnt].
   task_assay_cd = d.task_assay_cd,
   reply->qual[qual_cnt].mnemonic = d.mnemonic
  WITH format, nocounter
 ;end select
 IF (curqual=0)
  SET err_cnt = (err_cnt+ 1)
  SET reply->status_data.subeventstatus[err_cnt].operationname = "select"
  SET reply->status_data.subeventstatus[err_cnt].operationstatus = "Z"
  SET reply->status_data.subeventstatus[err_cnt].targetobjectname = "discrete task assay"
  SET reply->status_data.subeventstatus[err_cnt].targetobjectvalue =
  "unable to return task assays specified"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#end_script
END GO
