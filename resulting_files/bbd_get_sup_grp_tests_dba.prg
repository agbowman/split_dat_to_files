CREATE PROGRAM bbd_get_sup_grp_tests:dba
 RECORD reply(
   1 qual[*]
     2 order_id = f8
     2 service_resource_cd = f8
     2 service_resource_disp = f8
     2 task_assay_cd = f8
     2 task_assay_mnemonic = c40
     2 default_result_type_cd = f8
     2 default_result_type_disp = vc
     2 default_result_type_mean = c12
     2 bb_result_processing_cd = f8
     2 bb_result_processing_disp = vc
     2 bb_result_processing_mean = c12
     2 results_cnt = i4
     2 results[*]
       3 perform_result_id = f8
       3 result_id = f8
       3 result_updt_cnt = i4
       3 perform_result_updt_cnt = i4
       3 result_status_cd = f8
       3 result_status_disp = vc
       3 result_status_mean = c12
       3 result_type_cd = f8
       3 result_type_disp = vc
       3 result_type_mean = c12
       3 nomenclature_id = f8
       3 short_string = vc
       3 result_value_mean = c12
       3 result_value_numeric = f8
       3 numeric_raw_value = f8
       3 result_value_alpha = vc
       3 result_value_dt_tm = dq8
       3 long_text_id = f8
       3 rtf_text = vc
       3 ascii_text = vc
       3 result_comment_ind = i2
       3 result_code_set_cd = f8
       3 result_code_set_disp = c40
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET a_cnt = 0
 SET r_cnt = 0
 DECLARE interp_id = f8 WITH noconstant(0.0)
 SELECT INTO "nl:"
  ita.service_resource_cd
  FROM interp_task_assay ita
  PLAN (ita
   WHERE (ita.task_assay_cd=request->task_assay_cd)
    AND (ita.order_cat_cd=request->order_cat_cd)
    AND ita.active_ind=1
    AND (((ita.service_resource_cd=request->service_resource_cd)) OR (ita.service_resource_cd=0.0)) )
  ORDER BY ita.service_resource_cd
  DETAIL
   interp_id = ita.interp_id
  WITH nocounter
 ;end select
 IF (interp_id=0.0)
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  ita2.task_assay_cd, ic.sequence, d_rc.seq,
  rc.seq, interp_yn = decode(d.seq,"Y","N"), result_comment_yn = decode(rc.seq,"Y","N"),
  result_comment2_yn = decode(rc2.seq,"Y","N")
  FROM interp_task_assay ita,
   interp_component ic,
   (dummyt d  WITH seq = 1),
   interp_task_assay ita2,
   (dummyt d_ita2  WITH seq = 1),
   discrete_task_assay dta,
   orders o,
   result r,
   perform_result pr,
   (dummyt d_rc  WITH seq = 1),
   result_comment rc,
   orders o2,
   (dummyt d2  WITH seq = 1),
   result r2,
   perform_result pr2,
   (dummyt d2_rc  WITH seq = 1),
   result_comment rc2
  PLAN (ita
   WHERE ita.interp_id=interp_id)
   JOIN (ic
   WHERE ic.interp_id=ita.interp_id
    AND ic.active_ind=1)
   JOIN (dta
   WHERE dta.task_assay_cd=ic.included_assay_cd
    AND dta.active_ind=1)
   JOIN (((d_ita2
   WHERE d_ita2.seq=1)
   JOIN (ita2
   WHERE ita2.task_assay_cd=ic.included_assay_cd
    AND ita2.active_ind=1)
   JOIN (o
   WHERE (o.product_id=request->product_id)
    AND o.catalog_cd=ita2.order_cat_cd
    AND o.active_ind=1)
   JOIN (d
   WHERE d.seq=1)
   JOIN (r
   WHERE r.order_id=o.order_id
    AND r.task_assay_cd=ic.included_assay_cd)
   JOIN (pr
   WHERE pr.result_id=r.result_id
    AND pr.result_status_cd=r.result_status_cd)
   JOIN (d_rc
   WHERE d_rc.seq=1)
   JOIN (rc
   WHERE rc.result_id=pr.result_id)
   ) ORJOIN ((o2
   WHERE (o2.order_id=request->order_id)
    AND o2.active_ind=1)
   JOIN (d2
   WHERE d2.seq=1)
   JOIN (r2
   WHERE r2.order_id=o2.order_id
    AND r2.task_assay_cd=ic.included_assay_cd)
   JOIN (pr2
   WHERE pr2.result_id=r2.result_id
    AND pr2.result_status_cd=r2.result_status_cd)
   JOIN (d2_rc
   WHERE d2_rc.seq=1)
   JOIN (rc2
   WHERE rc2.result_id=pr2.result_id)
   ))
  ORDER BY ic.sequence, ic.included_assay_cd
  HEAD ic.included_assay_cd
   r_cnt = 0, a_cnt = (a_cnt+ 1), stat = alterlist(reply->qual,a_cnt)
   IF (interp_yn="Y")
    reply->qual[a_cnt].order_id = o.order_id
   ELSE
    reply->qual[a_cnt].order_id = o2.order_id
   ENDIF
   reply->qual[a_cnt].service_resource_cd = ita.service_resource_cd, reply->qual[a_cnt].task_assay_cd
    = ic.included_assay_cd, reply->qual[a_cnt].task_assay_mnemonic = dta.mnemonic,
   reply->qual[a_cnt].bb_result_processing_cd = dta.bb_result_processing_cd, reply->qual[a_cnt].
   default_result_type_cd = dta.default_result_type_cd, reply->qual[a_cnt].results_cnt = 0
  DETAIL
   IF (interp_yn="Y")
    r_cnt = (r_cnt+ 1), stat = alterlist(reply->qual[a_cnt].results,r_cnt), reply->qual[a_cnt].
    results_cnt = r_cnt,
    reply->qual[a_cnt].results[r_cnt].perform_result_id = pr.perform_result_id, reply->qual[a_cnt].
    results[r_cnt].result_id = r.result_id, reply->qual[a_cnt].results[r_cnt].result_updt_cnt = r
    .updt_cnt,
    reply->qual[a_cnt].results[r_cnt].perform_result_updt_cnt = pr.updt_cnt, reply->qual[a_cnt].
    results[r_cnt].result_status_cd = r.result_status_cd, reply->qual[a_cnt].results[r_cnt].
    result_type_cd = pr.result_type_cd,
    reply->qual[a_cnt].results[r_cnt].nomenclature_id = pr.nomenclature_id, reply->qual[a_cnt].
    results[r_cnt].result_value_numeric = pr.result_value_numeric, reply->qual[a_cnt].results[r_cnt].
    numeric_raw_value = pr.numeric_raw_value,
    reply->qual[a_cnt].results[r_cnt].result_value_alpha = pr.result_value_alpha, reply->qual[a_cnt].
    results[r_cnt].result_value_dt_tm = pr.result_value_dt_tm, reply->qual[a_cnt].results[r_cnt].
    long_text_id = pr.long_text_id,
    reply->qual[a_cnt].results[r_cnt].ascii_text = pr.ascii_text, reply->qual[a_cnt].results[r_cnt].
    result_code_set_cd = pr.result_code_set_cd
    IF (result_comment_yn="Y")
     reply->qual[a_cnt].results[r_cnt].result_comment_ind = 1
    ELSE
     reply->qual[a_cnt].results[r_cnt].result_comment_ind = 0
    ENDIF
   ELSE
    r_cnt = (r_cnt+ 1), stat = alterlist(reply->qual[a_cnt].results,r_cnt), reply->qual[a_cnt].
    results_cnt = r_cnt,
    reply->qual[a_cnt].results[r_cnt].perform_result_id = pr2.perform_result_id, reply->qual[a_cnt].
    results[r_cnt].result_id = r2.result_id, reply->qual[a_cnt].results[r_cnt].result_updt_cnt = r2
    .updt_cnt,
    reply->qual[a_cnt].results[r_cnt].perform_result_updt_cnt = pr2.updt_cnt, reply->qual[a_cnt].
    results[r_cnt].result_status_cd = r2.result_status_cd, reply->qual[a_cnt].results[r_cnt].
    result_type_cd = pr2.result_type_cd,
    reply->qual[a_cnt].results[r_cnt].nomenclature_id = pr2.nomenclature_id, reply->qual[a_cnt].
    results[r_cnt].result_value_numeric = pr2.result_value_numeric, reply->qual[a_cnt].results[r_cnt]
    .numeric_raw_value = pr2.numeric_raw_value,
    reply->qual[a_cnt].results[r_cnt].result_value_alpha = pr2.result_value_alpha, reply->qual[a_cnt]
    .results[r_cnt].result_value_dt_tm = pr2.result_value_dt_tm, reply->qual[a_cnt].results[r_cnt].
    long_text_id = pr2.long_text_id,
    reply->qual[a_cnt].results[r_cnt].ascii_text = pr2.ascii_text, reply->qual[a_cnt].results[r_cnt].
    result_code_set_cd = pr2.result_code_set_cd
    IF (result_comment2_yn="Y")
     reply->qual[a_cnt].results[r_cnt].result_comment_ind = 1
    ELSE
     reply->qual[a_cnt].results[r_cnt].result_comment_ind = 0
    ENDIF
   ENDIF
  WITH nocounter, outerjoin = d_ita2, outerjoin = d,
   outerjoin = d_rc, outerjoin = d2, outerjoin = d2_rc
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#exit_script
END GO
