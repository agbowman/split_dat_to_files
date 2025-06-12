CREATE PROGRAM bed_get_assay_review:dba
 FREE SET reply
 RECORD reply(
   1 assays_checked[*]
     2 assay_code_value = f8
     2 review_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET assay_count = size(request->assays_to_check,5)
 IF (assay_count=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->assays_checked,assay_count)
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = assay_count)
  DETAIL
   reply->assays_checked[d.seq].assay_code_value = request->assays_to_check[d.seq].assay_code_value,
   reply->assays_checked[d.seq].review_ind = 0
  WITH nocounter
 ;end select
 IF ((request->is_numeric_review_ind=1))
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = assay_count),
    reference_range_factor rrf,
    data_map dm
   PLAN (d
    WHERE (reply->assays_checked[d.seq].assay_code_value > 0))
    JOIN (rrf
    WHERE rrf.active_ind=1
     AND (rrf.task_assay_cd=reply->assays_checked[d.seq].assay_code_value)
     AND (rrf.service_resource_cd=request->service_resource_code_value))
    JOIN (dm
    WHERE (dm.service_resource_cd=request->service_resource_code_value)
     AND (dm.task_assay_cd=reply->assays_checked[d.seq].assay_code_value)
     AND dm.data_map_type_flag=0
     AND dm.active_ind=1)
   DETAIL
    reply->assays_checked[d.seq].review_ind = 1
   WITH nocounter
  ;end select
 ELSEIF ((request->is_numeric_review_ind=0))
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = assay_count),
    reference_range_factor rrf,
    alpha_responses ar
   PLAN (d
    WHERE (reply->assays_checked[d.seq].assay_code_value > 0))
    JOIN (rrf
    WHERE rrf.active_ind=1
     AND (rrf.task_assay_cd=reply->assays_checked[d.seq].assay_code_value)
     AND (rrf.service_resource_cd=request->service_resource_code_value))
    JOIN (ar
    WHERE ar.reference_range_factor_id=rrf.reference_range_factor_id
     AND ar.active_ind=1)
   DETAIL
    reply->assays_checked[d.seq].review_ind = 1
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 IF (assay_count > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
