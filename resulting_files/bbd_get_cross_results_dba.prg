CREATE PROGRAM bbd_get_cross_results:dba
 RECORD reply(
   1 qual[*]
     2 interp_id = f8
     2 cross_results_id = f8
     2 donor_eligibility_cd = f8
     2 donor_eligibility_cd_disp = vc
     2 donor_reason_cd = f8
     2 donor_reason_cd_disp = vc
     2 cross_results_updt_cnt = i4
     2 cross_results_r_id = f8
     2 result_hash_id = f8
     2 included_assay_cd = f8
     2 included_assay_cd_disp = vc
     2 cross_results_r_updt_cnt = i4
     2 nomenclature_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count = 0
 SELECT INTO "nl:"
  cr.*
  FROM cross_results cr,
   cross_results_r cr_r,
   result_hash r
  PLAN (cr
   WHERE (cr.interp_id=request->interp_id)
    AND cr.active_ind=1)
   JOIN (cr_r
   WHERE cr_r.cross_results_id=cr.cross_results_id
    AND cr_r.active_ind=1)
   JOIN (r
   WHERE r.result_hash_id=cr_r.result_hash_id)
  ORDER BY cr.cross_results_id
  DETAIL
   count = (count+ 1), stat = alterlist(reply->qual,count), reply->qual[count].interp_id = cr
   .interp_id,
   reply->qual[count].cross_results_id = cr.cross_results_id, reply->qual[count].donor_eligibility_cd
    = cr.donor_eligibility_cd, reply->qual[count].donor_reason_cd = cr.donor_reason_cd,
   reply->qual[count].cross_results_updt_cnt = cr.updt_cnt, reply->qual[count].cross_results_r_id =
   cr_r.cross_results_r_id, reply->qual[count].result_hash_id = cr_r.result_hash_id,
   reply->qual[count].cross_results_r_updt_cnt = cr_r.updt_cnt, reply->qual[count].included_assay_cd
    = r.included_assay_cd, reply->qual[count].nomenclature_id = r.nomenclature_id
  WITH nocounter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
