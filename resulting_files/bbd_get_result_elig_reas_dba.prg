CREATE PROGRAM bbd_get_result_elig_reas:dba
 RECORD reply(
   1 qual[*]
     2 order_key = f8
     2 task_assay_cd = f8
     2 alpha_responses[*]
       3 nomenclature_id = f8
       3 donor_eligibility_cd = f8
       3 donor_eligibility_disp = c40
       3 donor_eligibility_mean = c12
       3 donor_reason_cd = f8
       3 days_ineligible = i4
       3 result_hash = vc
       3 biohazard_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 sourceobjectname = c15
       3 sourceobjectqual = i4
       3 sourceobjectvalue = c200
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c200
       3 sub_event_dt_tm = di8
 )
 SET reply->status_data.status = "F"
 SET t_cnt = size(request->qual,5)
 SET r_cnt = 0
 SET a_cnt = 0
 SELECT INTO "nl:"
  rh.included_assay_cd, dta.task_assay_cd
  FROM code_value c,
   (dummyt d  WITH seq = value(t_cnt)),
   discrete_task_assay dta,
   interp_task_assay ita,
   result_hash rh
  PLAN (c
   WHERE c.cdf_meaning="DONOR INTERP"
    AND c.code_set=17030
    AND c.active_ind=1
    AND cnvtdatetime(curdate,curtime3) >= c.begin_effective_dt_tm
    AND cnvtdatetime(curdate,curtime3) <= c.end_effective_dt_tm)
   JOIN (dta
   WHERE dta.bb_result_processing_cd=c.code_value
    AND dta.active_ind=1)
   JOIN (ita
   WHERE ita.task_assay_cd=dta.task_assay_cd
    AND ita.active_ind=1)
   JOIN (d)
   JOIN (rh
   WHERE rh.interp_id=ita.interp_id
    AND (rh.included_assay_cd=request->qual[d.seq].task_assay_cd)
    AND rh.active_ind=1)
  HEAD rh.included_assay_cd
   r_cnt = 0, a_cnt = (a_cnt+ 1), stat = alterlist(reply->qual,a_cnt),
   reply->qual[a_cnt].order_key = request->qual[d.seq].order_key, reply->qual[a_cnt].task_assay_cd =
   rh.included_assay_cd
  DETAIL
   r_cnt = (r_cnt+ 1), stat = alterlist(reply->qual[a_cnt].alpha_responses,r_cnt), reply->qual[a_cnt]
   .alpha_responses[r_cnt].nomenclature_id = rh.nomenclature_id,
   reply->qual[a_cnt].alpha_responses[r_cnt].donor_eligibility_cd = rh.donor_eligibility_cd, reply->
   qual[a_cnt].alpha_responses[r_cnt].donor_reason_cd = rh.donor_reason_cd, reply->qual[a_cnt].
   alpha_responses[r_cnt].days_ineligible = rh.days_ineligible,
   reply->qual[a_cnt].alpha_responses[r_cnt].result_hash = rh.result_hash, reply->qual[a_cnt].
   alpha_responses[r_cnt].biohazard_ind = rh.biohazard_ind
  WITH counter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "T"
 ENDIF
#exitscript
END GO
