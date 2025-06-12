CREATE PROGRAM bbt_get_rspns_for_srv_dir:dba
 RECORD reply(
   1 assay_list[*]
     2 task_assay_cd = f8
     2 alpha_responses_cnt = i4
     2 alpha_list[*]
       3 nomenclature_id = f8
       3 mnemonic = vc
       3 result_process_cd = f8
       3 result_process_disp = c40
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 DECLARE stat = i4 WITH noconstant(0)
 DECLARE q_cnt = i2 WITH noconstant(0)
 DECLARE a_cnt = i2 WITH noconstant(0)
 DECLARE nbr_of_assays = i2 WITH noconstant(0)
 SET cv_cnt = 1
 SET reply->status_data.status = "F"
 SET nbr_of_assays = size(request->assays,5)
 SELECT INTO "nl:"
  d1.seq, rr.reference_range_factor_id, rr.service_resource_cd,
  rr.task_assay_cd, ar.nomenclature_id, ar.result_process_cd,
  ar.sequence, n.nomenclature_id, n.mnemonic
  FROM (dummyt d1  WITH seq = value(nbr_of_assays)),
   reference_range_factor rr,
   alpha_responses ar,
   nomenclature n
  PLAN (d1)
   JOIN (rr
   WHERE (rr.task_assay_cd=request->assays[d1.seq].task_assay_cd)
    AND rr.active_ind=1
    AND (((rr.service_resource_cd=request->assays[d1.seq].service_resource_cd)) OR (rr
   .service_resource_cd=0)) )
   JOIN (ar
   WHERE ar.reference_range_factor_id=rr.reference_range_factor_id
    AND ar.active_ind=1)
   JOIN (n
   WHERE ar.nomenclature_id=n.nomenclature_id)
  ORDER BY rr.task_assay_cd, ar.sequence
  HEAD REPORT
   q_cnt = 0, a_cnt = 0
  HEAD rr.task_assay_cd
   q_cnt += 1
   IF (q_cnt > size(reply->assay_list,5))
    stat = alterlist(reply->assay_list,(q_cnt+ 4))
   ENDIF
   reply->assay_list[q_cnt].task_assay_cd = rr.task_assay_cd, reply->assay_list[q_cnt].
   alpha_responses_cnt = 0, a_cnt = 0
  DETAIL
   found_ind = 0, i = 1
   WHILE (found_ind=0
    AND i <= a_cnt)
    IF ((ar.nomenclature_id=reply->assay_list[q_cnt].alpha_list[i].nomenclature_id))
     found_ind = 1
    ENDIF
    ,i += 1
   ENDWHILE
   IF (found_ind=0)
    a_cnt += 1
    IF (a_cnt > size(reply->assay_list[q_cnt].alpha_list,5))
     stat = alterlist(reply->assay_list[q_cnt].alpha_list,(a_cnt+ 4))
    ENDIF
    reply->assay_list[q_cnt].alpha_list[a_cnt].nomenclature_id = ar.nomenclature_id, reply->
    assay_list[q_cnt].alpha_list[a_cnt].result_process_cd = ar.result_process_cd, reply->assay_list[
    q_cnt].alpha_list[a_cnt].mnemonic = n.mnemonic
   ENDIF
  FOOT  rr.task_assay_cd
   reply->assay_list[q_cnt].alpha_responses_cnt = a_cnt, stat = alterlist(reply->assay_list[q_cnt].
    alpha_list,a_cnt)
  FOOT REPORT
   stat = alterlist(reply->assay_list,q_cnt)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
