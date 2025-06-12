CREATE PROGRAM bbd_get_profile_complete:dba
 RECORD reply(
   1 profile_status = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET super_group_cd = 0.0
 SET cv_cnt = 1
 SET stat = uar_get_meaning_by_codeset(17030,"DONOR INTERP",cv_cnt,super_group_cd)
 SELECT INTO "nl:"
  o.*
  FROM orders o,
   interp_task_assay ita,
   discrete_task_assay dta,
   result r,
   perform_result pr,
   code_value c
  PLAN (o
   WHERE (o.product_id=request->product_id)
    AND o.active_ind=1)
   JOIN (ita
   WHERE ita.order_cat_cd=o.catalog_cd
    AND ita.active_ind=1)
   JOIN (dta
   WHERE dta.task_assay_cd=ita.task_assay_cd
    AND dta.bb_result_processing_cd=super_group_cd
    AND dta.active_ind=1)
   JOIN (r
   WHERE r.order_id=o.order_id
    AND r.task_assay_cd=dta.task_assay_cd)
   JOIN (pr
   WHERE pr.result_id=r.result_id)
   JOIN (c
   WHERE c.code_value=pr.result_status_cd)
  DETAIL
   IF (((c.cdf_meaning="VERIFIED") OR (c.cdf_meaning="OLDVERIFIED")) )
    reply->profile_status = "TRUE"
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
  SET reply->profile_status = "Z"
 ENDIF
#end_script
END GO
