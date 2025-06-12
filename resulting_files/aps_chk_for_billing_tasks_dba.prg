CREATE PROGRAM aps_chk_for_billing_tasks:dba
 RECORD reply(
   1 billing_tasks_exist_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET reply->status_data.status = "F"
 SET code_set = 0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET ordered_cd = 0.0
 SET verified_cd = 0.0
 SET code_set = 1305
 SET cdf_meaning = "ORDERED"
 EXECUTE cpm_get_cd_for_cdf
 SET ordered_cd = code_value
 SET cdf_meaning = "VERIFIED"
 EXECUTE cpm_get_cd_for_cdf
 SET verified_cd = code_value
 SELECT INTO "nl:"
  pt.case_id, pt.processing_task_id, pt.status_prsnl_id,
  pt.case_specimen_id, pt.cassette_id, pt.slide_id,
  pt.status_cd, pt.request_prsnl_id, pt.task_assay_cd
  FROM processing_task pt,
   profile_task_r ptr,
   ap_task_assay_addl ataa
  PLAN (pt
   WHERE (request->case_id=pt.case_id)
    AND pt.create_inventory_flag=0
    AND ((pt.status_cd=ordered_cd) OR (pt.status_cd=verified_cd
    AND (request->verified_ind=1))) )
   JOIN (ptr
   WHERE ptr.task_assay_cd=pt.task_assay_cd
    AND ptr.active_ind=1
    AND ptr.item_type_flag=0
    AND ptr.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    AND ptr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (ataa
   WHERE ataa.task_assay_cd=ptr.task_assay_cd
    AND ataa.task_type_flag=0)
  HEAD REPORT
   reply->billing_tasks_exist_ind = 0
  DETAIL
   reply->billing_tasks_exist_ind = 1
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
END GO
