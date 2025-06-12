CREATE PROGRAM aps_get_std_rpts_info:dba
 RECORD reply(
   1 dt_qual[5]
     2 task_assay_cd = f8
     2 procedure = vc
     2 status = i2
     2 ar_qual[*]
       3 nomenclature_id = f8
       3 nomenclature_disp = c40
       3 ref_range_factor_id = f8
   1 sr_qual[*]
     2 standard_rpt_cd = f8
     2 description = vc
     2 hot_key_sequence = i4
     2 code = c5
     2 active_ind = i2
     2 updt_cnt = i4
     2 srr_qual[*]
       3 task_assay_cd = f8
       3 result_cd = f8
       3 result_text = vc
       3 updt_cnt = i4
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
 DECLARE interp_code = f8 WITH protect, noconstant(0.0)
 DECLARE alpha_code = f8 WITH protect, noconstant(0.0)
 DECLARE text_code = f8 WITH protect, noconstant(0.0)
 SET dt_cnt = 0
 SET sr_cnt = 0
 SELECT INTO "nl:"
  cv1.code_value
  FROM code_value cv1
  WHERE 289=cv1.code_set
   AND cv1.cdf_meaning IN ("1", "2", "4")
  HEAD REPORT
   interp_code = 0, alpha_code = 0, text_code = 0
  DETAIL
   IF (cv1.cdf_meaning="1")
    text_code = cv1.code_value
   ENDIF
   IF (cv1.cdf_meaning="2")
    alpha_code = cv1.code_value
   ENDIF
   IF (cv1.cdf_meaning="4")
    interp_code = cv1.code_value
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET err_cnt += 1
  SET reply->status_data.subeventstatus[err_cnt].operationname = "SELECT"
  SET reply->status_data.subeventstatus[err_cnt].operationstatus = "Z"
  SET reply->status_data.subeventstatus[err_cnt].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[err_cnt].targetobjectvalue = "CODE_VALUE"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  dta.description, dta.default_result_type_cd, dta.task_assay_cd,
  ar.nomenclature_id, nnomenclatureidfoundind = evaluate(nullind(ar.nomenclature_id),0,1,0)
  FROM profile_task_r ptr,
   discrete_task_assay dta,
   dummyt d1,
   reference_range_factor rrf,
   alpha_responses ar,
   nomenclature n
  PLAN (ptr
   WHERE (ptr.catalog_cd=request->catalog_cd)
    AND ptr.active_ind=1
    AND cnvtdatetime(sysdate) BETWEEN ptr.beg_effective_dt_tm AND ptr.end_effective_dt_tm)
   JOIN (dta
   WHERE ptr.task_assay_cd=dta.task_assay_cd
    AND dta.default_result_type_cd != interp_code)
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
   x = 0, dt_cnt = 0, ar_cnt = 0
  HEAD dta.description
   dt_cnt += 1
   IF (mod(dt_cnt,5)=1
    AND dt_cnt != 1)
    stat = alter(reply->dt_qual,(dt_cnt+ 4))
   ENDIF
   reply->dt_qual[dt_cnt].task_assay_cd = ptr.task_assay_cd, reply->dt_qual[dt_cnt].procedure = dta
   .description, reply->dt_qual[dt_cnt].status = ptr.pending_ind,
   ar_cnt = 0
  DETAIL
   IF (dta.default_result_type_cd=alpha_code)
    IF (nnomenclatureidfoundind=1)
     ar_cnt += 1, stat = alterlist(reply->dt_qual[dt_cnt].ar_qual,ar_cnt), reply->dt_qual[dt_cnt].
     ar_qual[ar_cnt].nomenclature_id = ar.nomenclature_id,
     reply->dt_qual[dt_cnt].ar_qual[ar_cnt].nomenclature_disp = n.mnemonic, reply->dt_qual[dt_cnt].
     ar_qual[ar_cnt].ref_range_factor_id = ar.reference_range_factor_id
    ENDIF
   ENDIF
  WITH outerjoin = d1
 ;end select
 IF (curqual=0)
  SET err_cnt += 1
  SET reply->status_data.subeventstatus[err_cnt].operationname = "SELECT"
  SET reply->status_data.subeventstatus[err_cnt].operationstatus = "Z"
  SET reply->status_data.subeventstatus[err_cnt].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[err_cnt].targetobjectvalue = "CYTO_STANDARD_RPT"
 ELSE
  SET stat = alter(reply->dt_qual,dt_cnt)
 ENDIF
#exit_script
 IF (err_cnt > 0)
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF (validate(request->alpha_responses_only_ind,- (1)) != 1)
  SELECT INTO "nl:"
   csr.standard_rpt_id, csr.catalog_cd, csr.description,
   csr.hot_key_sequence
   FROM cyto_standard_rpt csr,
    dummyt d2,
    cyto_standard_rpt_r csrr
   PLAN (csr
    WHERE (csr.catalog_cd=request->catalog_cd))
    JOIN (d2)
    JOIN (csrr
    WHERE csr.standard_rpt_id=csrr.standard_rpt_id)
   ORDER BY csr.standard_rpt_id
   HEAD REPORT
    sr_cnt = 0, srr_cnt = 0
   HEAD csr.standard_rpt_id
    sr_cnt += 1
    IF (mod(sr_cnt,5)=1)
     stat = alterlist(reply->sr_qual,(sr_cnt+ 4))
    ENDIF
    reply->sr_qual[sr_cnt].standard_rpt_cd = csr.standard_rpt_id, reply->sr_qual[sr_cnt].description
     = csr.description, reply->sr_qual[sr_cnt].hot_key_sequence = csr.hot_key_sequence,
    reply->sr_qual[sr_cnt].updt_cnt = csr.updt_cnt, reply->sr_qual[sr_cnt].code = csr.short_desc,
    reply->sr_qual[sr_cnt].active_ind = csr.active_ind,
    srr_cnt = 0
   DETAIL
    srr_cnt += 1
    IF (mod(srr_cnt,5)=1)
     stat = alterlist(reply->sr_qual[sr_cnt].srr_qual,(srr_cnt+ 4))
    ENDIF
    reply->sr_qual[sr_cnt].srr_qual[srr_cnt].task_assay_cd = csrr.task_assay_cd, reply->sr_qual[
    sr_cnt].srr_qual[srr_cnt].result_cd = csrr.nomenclature_id, reply->sr_qual[sr_cnt].srr_qual[
    srr_cnt].result_text = csrr.result_text,
    reply->sr_qual[sr_cnt].srr_qual[srr_cnt].updt_cnt = csrr.updt_cnt
   FOOT  csr.standard_rpt_id
    stat = alterlist(reply->sr_qual[sr_cnt].srr_qual,srr_cnt)
   WITH outerjoin = d2
  ;end select
  SET stat = alterlist(reply->sr_qual,sr_cnt)
 ENDIF
END GO
