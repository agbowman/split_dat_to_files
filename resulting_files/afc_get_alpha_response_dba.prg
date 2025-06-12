CREATE PROGRAM afc_get_alpha_response:dba
 RECORD reply(
   1 alpha_resp_qual = i2
   1 alpha_resp[*]
     2 task_assay_cd = f8
     2 task_assay_desc = c50
     2 reference_range_factor_id = f8
     2 nomenclature_id = f8
     2 short_string = c60
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SELECT INTO "nl:"
  d.description, r.reference_range_factor_id, n.nomenclature_id,
  n.short_string
  FROM discrete_task_assay d,
   reference_range_factor r,
   alpha_responses a,
   nomenclature n
  PLAN (d
   WHERE d.active_ind=1
    AND (d.task_assay_cd=request->task_assay_cd))
   JOIN (r
   WHERE r.task_assay_cd=d.task_assay_cd
    AND r.active_ind=1)
   JOIN (a
   WHERE a.reference_range_factor_id=r.reference_range_factor_id
    AND a.active_ind=1
    AND a.nomenclature_id != 0)
   JOIN (n
   WHERE n.nomenclature_id=a.nomenclature_id
    AND n.active_ind=1)
  DETAIL
   count1 = (count1+ 1), stat = alterlist(reply->alpha_resp,count1), reply->alpha_resp[count1].
   task_assay_cd = request->task_assay_cd,
   reply->alpha_resp[count1].task_assay_desc = d.description, reply->alpha_resp[count1].
   reference_range_factor_id = r.reference_range_factor_id, reply->alpha_resp[count1].nomenclature_id
    = n.nomenclature_id,
   reply->alpha_resp[count1].short_string = n.short_string
  WITH nocounter
 ;end select
 IF (curqual != 0)
  SET reply->alpha_resp_qual = count1
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.subeventstatus[1].operationname = "Select"
  SET reply->status_data.subeventstatus[1].operationstatus = "s"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "????"
  SET reply->status_data.status = "Z"
 ENDIF
END GO
