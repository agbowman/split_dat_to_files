CREATE PROGRAM aps_get_db_reports_details:dba
 RECORD reply(
   1 report_type = i2
   1 updt_cnt = i4
   1 dt_ctr = i4
   1 dt_qual[5]
     2 description = vc
     2 task_assay_cd = f8
     2 text_alpha = c4
     2 alpha_cntr = i4
     2 alpha_qual[*]
       3 nomenclature_id = f8
       3 nomenclature_disp = c40
   1 endocerv_cd = f8
   1 endo_cntr = i4
   1 e_alpha_qual[*]
     2 nomenclature_id = f8
     2 endocerv_ind = i2
     2 updt_cnt = i4
   1 diagnosis_cd = f8
   1 adequacy_cd = f8
   1 adeq_cntr = i4
   1 a_alpha_qual[*]
     2 nomenclature_id = f8
     2 reason_required_ind = i2
     2 adequacy_flag = i2
     2 updt_cnt = i4
   1 adeq_reason_task_assay_cd = f8
   1 clin_info_task_assay_cd = f8
   1 second_status_flag = c4
   1 action_task_assay_cd = f8
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
 SET failed = "F"
 SET x = 0
 SET err_cnt = 0
 SET alpha_code = 0.0
 SET text_code = 0.0
 SELECT INTO "nl:"
  cv1.code_value
  FROM code_value cv1
  WHERE 289=cv1.code_set
   AND cv1.cdf_meaning IN ("1", "2")
  HEAD REPORT
   alpha_code = 0.0, text_code = 0.0
  DETAIL
   IF (cv1.cdf_meaning="1")
    text_code = cv1.code_value
   ENDIF
   IF (cv1.cdf_meaning="2")
    alpha_code = cv1.code_value
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET err_cnt += 1
  SET reply->status_data.subeventstatus[err_cnt].operationname = "SELECT"
  SET reply->status_data.subeventstatus[err_cnt].operationstatus = "Z"
  SET reply->status_data.subeventstatus[err_cnt].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[err_cnt].targetobjectvalue = "ORDER_CATALOG"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  dta.description, dta.default_result_type_cd, dta.task_assay_cd,
  ar.nomenclature_id, nnomenclatureidfoundind = evaluate(nullind(ar.nomenclature_id),0,1,0)
  FROM profile_task_r ptr,
   dummyt d1,
   discrete_task_assay dta,
   reference_range_factor rrf,
   alpha_responses ar,
   nomenclature n
  PLAN (ptr
   WHERE (ptr.catalog_cd=request->catalog_cd)
    AND ptr.active_ind=1
    AND cnvtdatetime(sysdate) BETWEEN ptr.beg_effective_dt_tm AND ptr.end_effective_dt_tm)
   JOIN (dta
   WHERE ptr.task_assay_cd=dta.task_assay_cd
    AND dta.default_result_type_cd IN (alpha_code, text_code))
   JOIN (d1)
   JOIN (rrf
   WHERE dta.task_assay_cd=rrf.task_assay_cd
    AND dta.default_result_type_cd=alpha_code
    AND rrf.active_ind=1)
   JOIN (ar
   WHERE rrf.reference_range_factor_id=ar.reference_range_factor_id
    AND ar.active_ind=1)
   JOIN (n
   WHERE ar.nomenclature_id=n.nomenclature_id)
  ORDER BY dta.description
  HEAD REPORT
   row + 1, dt_ctr = 0, alpha_cntr = 0
  HEAD dta.description
   dt_ctr += 1
   IF (mod(dt_ctr,5)=1
    AND dt_ctr != 1)
    stat = alter(reply->dt_qual,(dt_ctr+ 4))
   ENDIF
   reply->dt_ctr = dt_ctr, reply->dt_qual[dt_ctr].task_assay_cd = dta.task_assay_cd, reply->dt_qual[
   dt_ctr].description = dta.description,
   alpha_cntr = 0
  DETAIL
   IF (dta.default_result_type_cd=alpha_code)
    IF (nnomenclatureidfoundind=1)
     alpha_cntr += 1, stat = alterlist(reply->dt_qual[dt_ctr].alpha_qual,alpha_cntr), reply->dt_qual[
     dt_ctr].alpha_qual[alpha_cntr].nomenclature_id = ar.nomenclature_id,
     reply->dt_qual[dt_ctr].alpha_qual[alpha_cntr].nomenclature_disp = n.mnemonic
    ENDIF
    reply->dt_qual[dt_ctr].text_alpha = "A", reply->dt_qual[dt_ctr].alpha_cntr = alpha_cntr
   ELSE
    reply->dt_qual[dt_ctr].text_alpha = "T"
   ENDIF
  WITH outerjoin = d1
 ;end select
 IF (curqual=0)
  SET err_cnt += 1
  SET reply->status_data.subeventstatus[err_cnt].operationname = "SELECT"
  SET reply->status_data.subeventstatus[err_cnt].operationstatus = "Z"
  SET reply->status_data.subeventstatus[err_cnt].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[err_cnt].targetobjectvalue = "ORDER_CATALOG"
 ELSE
  SET stat = alter(reply->dt_qual,reply->dt_ctr)
 ENDIF
#exit_script
 IF (err_cnt > 0)
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SELECT INTO "nl:"
  crc.catalog_cd, join_path = decode(cear.seq,"A",caar.seq,"B"," "), cear.nomenclature_id,
  caar.nomenclature_id
  FROM cyto_report_control crc,
   (dummyt d3  WITH seq = 1),
   cyto_endocerv_alpha_r cear,
   (dummyt d4  WITH seq = 1),
   cyto_adequacy_alpha_r caar
  PLAN (crc
   WHERE (crc.catalog_cd=request->catalog_cd))
   JOIN (((d3
   WHERE 1=d3.seq)
   JOIN (cear
   WHERE crc.catalog_cd=cear.catalog_cd
    AND crc.endocerv_task_assay_cd=cear.task_assay_cd)
   ) ORJOIN ((d4
   WHERE 1=d4.seq)
   JOIN (caar
   WHERE crc.catalog_cd=caar.catalog_cd
    AND crc.adequacy_task_assay_cd=caar.task_assay_cd)
   ))
  ORDER BY crc.catalog_cd
  HEAD crc.catalog_cd
   reply->report_type = crc.report_type_flag, reply->endocerv_cd = crc.endocerv_task_assay_cd, reply
   ->diagnosis_cd = crc.diagnosis_task_assay_cd,
   reply->action_task_assay_cd = crc.action_task_assay_cd, reply->adequacy_cd = crc
   .adequacy_task_assay_cd, reply->adeq_reason_task_assay_cd = crc.adeq_reason_task_assay_cd,
   reply->clin_info_task_assay_cd = crc.clin_info_task_assay_cd, reply->endo_cntr = 0, reply->
   adeq_cntr = 0,
   reply->updt_cnt = crc.updt_cnt
  DETAIL
   CASE (join_path)
    OF "A":
     reply->endo_cntr += 1,stat = alterlist(reply->e_alpha_qual,reply->endo_cntr),reply->
     e_alpha_qual[reply->endo_cntr].nomenclature_id = cear.nomenclature_id,
     reply->e_alpha_qual[reply->endo_cntr].endocerv_ind = cear.endocerv_ind,reply->e_alpha_qual[reply
     ->endo_cntr].updt_cnt = cear.updt_cnt
    OF "B":
     reply->adeq_cntr += 1,stat = alterlist(reply->a_alpha_qual,reply->adeq_cntr),reply->
     a_alpha_qual[reply->adeq_cntr].nomenclature_id = caar.nomenclature_id,
     reply->a_alpha_qual[reply->adeq_cntr].adequacy_flag = caar.adequacy_flag,reply->a_alpha_qual[
     reply->adeq_cntr].updt_cnt = caar.updt_cnt,reply->a_alpha_qual[reply->adeq_cntr].
     reason_required_ind = caar.reason_required_ind
   ENDCASE
  WITH outerjoin = d3, outerjoin = d4
 ;end select
 IF (curqual=0)
  SET reply->second_status_flag = "Z"
 ELSE
  SET reply->second_status_flag = "S"
 ENDIF
END GO
