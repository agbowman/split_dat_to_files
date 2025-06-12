CREATE PROGRAM bbd_get_pos_result_info:dba
 RECORD reply(
   1 assay[*]
     2 task_assay_cd = f8
     2 task_assay_disp = c40
     2 nomenclature_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 sourceobjectname = c30
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c30
       3 targetobjectvalue = vc
       3 sourceobjectqual = i4
 )
 DECLARE temp_product_id = f8 WITH noconstant(0.0)
 DECLARE parent_product_found = i2 WITH noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE corr_inreview_status_cd = f8 WITH protect, noconstant(0.0)
 DECLARE result_status_cs = i4 WITH protect, constant(1901)
 DECLARE corr_inreview_status_mean = c9 WITH protect, constant("CORRINREV")
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET activity_cd = 0.0
 SET verified_cd = 0.0
 SET corrected_cd = 0.0
 SET eligibility_cd = 0.0
 SET assaycount = 0
 SET code_set = 106
 SET code_cnt = 1
 SET cdf_mean = fillstring(12," ")
 SET cdf_mean = "BBDONORPROD"
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(cdf_mean),code_cnt,activity_cd)
 SET code_set = 14237
 SET code_cnt = 1
 SET cdf_mean = fillstring(12," ")
 SET cdf_mean = "GOOD"
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(cdf_mean),code_cnt,eligibility_cd)
 SET code_set = 1901
 SET code_cnt = 1
 SET cdf_mean = fillstring(12," ")
 SET cdf_mean = "VERIFIED"
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(cdf_mean),code_cnt,verified_cd)
 SET code_cnt = 1
 SET cdf_mean = fillstring(12," ")
 SET cdf_mean = "CORRECTED"
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(cdf_mean),code_cnt,corrected_cd)
 SET stat = uar_get_meaning_by_codeset(result_status_cs,nullterm(corr_inreview_status_mean),1,
  corr_inreview_status_cd)
 IF (((activity_cd=0.0) OR (((eligibility_cd=0.0) OR (((verified_cd=0.0) OR (((corrected_cd=0.0) OR (
 corr_inreview_status_cd=0.0)) )) )) )) )
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_get_pos_result_info.prg"
  SET reply->status_data.subeventstatus[1].operationname = "Select"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE"
  IF (activity_cd=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to read blood bank donor product activity type code value."
  ELSEIF (eligibility_cd=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to read good eligibility type code value."
  ELSEIF (verified_cd=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to read verified result status code value."
  ELSEIF (corr_inreview_status_cd=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to read Corr-InReview result status code value."
  ELSE
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to read corrected result status code value."
  ENDIF
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  GO TO exit_script
 ENDIF
 IF ((request->result_ind="T"))
  SELECT INTO "nl:"
   i.task_assay_cd, r.nomenclature_id
   FROM discrete_task_assay d,
    interp_task_assay i,
    interp_component c,
    result_hash r
   PLAN (d
    WHERE d.activity_type_cd=activity_cd
     AND d.active_ind=1)
    JOIN (i
    WHERE i.task_assay_cd=d.task_assay_cd
     AND i.active_ind=1)
    JOIN (c
    WHERE c.interp_id=i.interp_id
     AND c.active_ind=1)
    JOIN (r
    WHERE r.interp_id=c.interp_id
     AND r.donor_eligibility_cd IN (eligibility_cd)
     AND r.active_ind=1)
   DETAIL
    IF (i.task_assay_cd > 0.0)
     assaycount = (assaycount+ 1), stat = alterlist(reply->assay,assaycount), reply->assay[assaycount
     ].task_assay_cd = r.included_assay_cd,
     reply->assay[assaycount].nomenclature_id = r.nomenclature_id, row + 1
    ENDIF
   WITH nocounter
  ;end select
 ELSE
  SET temp_product_id = request->product_id
  WHILE (parent_product_found=0)
    SELECT INTO "nl:"
     p.product_id
     FROM product p
     PLAN (p
      WHERE p.product_id=temp_product_id)
     DETAIL
      IF (p.modified_product_id > 0)
       temp_product_id = p.modified_product_id, parent_product_found = 0
      ELSE
       parent_product_found = 1
      ENDIF
     WITH nocounter
    ;end select
  ENDWHILE
  SELECT INTO "nl:"
   r.task_assay_cd, pr.nomenclature_id
   FROM orders o,
    result r,
    perform_result pr
   PLAN (o
    WHERE o.product_id=temp_product_id
     AND o.activity_type_cd=activity_cd
     AND o.order_id > 0.0
     AND o.active_ind=1)
    JOIN (r
    WHERE r.order_id=o.order_id
     AND r.result_status_cd IN (verified_cd, corrected_cd, corr_inreview_status_cd))
    JOIN (pr
    WHERE pr.result_id=r.result_id
     AND pr.result_status_cd=r.result_status_cd)
   ORDER BY r.task_assay_cd
   HEAD r.task_assay_cd
    IF (r.task_assay_cd > 0.0)
     assaycount = (assaycount+ 1), stat = alterlist(reply->assay,assaycount), reply->assay[assaycount
     ].task_assay_cd = r.task_assay_cd,
     reply->assay[assaycount].nomenclature_id = pr.nomenclature_id, row + 1
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 IF (failed="F")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
