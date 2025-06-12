CREATE PROGRAM aps_get_cyto_rpt_ref:dba
 RECORD reply(
   1 report_type_flag = i2
   1 endocerv_task_assay_cd = f8
   1 diagnosis_task_assay_cd = f8
   1 adequacy_task_assay_cd = f8
   1 clin_info_task_assay_cd = f8
   1 adeq_reason_task_assay_cd = f8
   1 section_qual[*]
     2 task_assay_cd = f8
     2 required_ind = i2
     2 description = vc
     2 interp_id = f8
     2 interp_type_cd = f8
     2 interp_type_disp = vc
     2 interp_type_mean = c12
     2 interp_option_cd = f8
     2 interp_option_disp = vc
     2 interp_option_mean = c12
     2 generate_interp_flag = i4
     2 order_cat_cd = f8
     2 phase_cd = f8
     2 phase_disp = vc
     2 phase_mean = c12
     2 alpha_qual[*]
       3 nomenclature_id = f8
       3 nomenclature_disp = c50
       3 reference_range_factor_id = f8
       3 diagnostic_category_cd = f8
       3 degrees_from_normal = i4
       3 workload_cd = f8
       3 requeue_flag = i2
       3 requeue_service_resource_cd = f8
       3 verify_level_is = i4
       3 verify_level_rs = i4
       3 qa_flag_type_cd = f8
       3 followup_tracking_type_cd = f8
       3 followup_initial_interval = i4
       3 followup_first_interval = i4
       3 followup_final_interval = i4
       3 followup_termination_interval = i4
     2 interp_comp_qual[*]
       3 interp_detail_id = f8
       3 sequence = i4
       3 included_assay_cd = f8
       3 cross_drawn_dt_tm_ind = i2
       3 time_window_minutes = i4
       3 time_window_units_cd = f8
       3 time_window_units_disp = vc
       3 result_req_flag = i4
       3 verified_flag = i4
   1 e_alpha_qual[*]
     2 nomenclature_id = f8
     2 endocerv_ind = i2
   1 a_alpha_qual[*]
     2 nomenclature_id = f8
     2 reason_required_ind = i2
     2 adequacy_flag = i2
   1 sr_qual[*]
     2 standard_rpt_cd = f8
     2 description = vc
     2 hot_key_sequence = i4
     2 code = c5
     2 srr_qual[*]
       3 task_assay_cd = f8
       3 result_cd = f8
       3 result_text = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD flat_alpha_rec(
   1 list[*]
     2 nomenclature_id = f8
     2 reference_range_factor_id = f8
     2 section_qual_idx = i4
     2 alpha_qual_idx = i4
     2 cyto_sec_level_found_at = i2
     2 ft_params_level_found_at = i2
 )
 RECORD cytoalphasecurity(
   1 list[*]
     2 service_resource_cd = f8
 )
#script
 DECLARE lflatalphareccnt = i4 WITH protect, noconstant(0)
 DECLARE lstat = i4 WITH protect, noconstant(0)
 DECLARE lidx = i4 WITH protect, noconstant(0)
 DECLARE sidx = i4 WITH protect, noconstant(0)
 DECLARE lcur = i4 WITH protect, noconstant(0)
 DECLARE llocatevalidx = i4 WITH protect, noconstant(0)
 DECLARE dservressubsectiontypecd = f8 WITH protect, noconstant(0.0)
 DECLARE suarerror = vc WITH protect, noconstant("")
 DECLARE const_serv_res_subsection_cdf = c12 WITH protect, constant("SUBSECTION")
 DECLARE const_serv_res_bench_cdf = c12 WITH protect, constant("BENCH")
 DECLARE const_serv_res_instrument_cdf = c12 WITH protect, constant("INSTRUMENT")
 DECLARE const_serv_res_type_cs = i4 WITH protect, constant(223)
 DECLARE rescnt = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET error_cnt = 0
 SET alpha_type = 0.0
 SET code_set = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET lstat = uar_get_meaning_by_codeset(const_serv_res_type_cs,const_serv_res_subsection_cdf,1,
  dservressubsectiontypecd)
 IF (dservressubsectiontypecd=0.0)
  SET suarerror = concat("Failed to retrieve service resource type code with meaning of ",trim(
    const_serv_res_subsection_cdf),".")
  CALL handle_errors("aps_get_cyto_rpt_ref","F","uar_get_code_by",suarerror)
  SET reply->status_data.status = "F"
  SET failed = "T"
  GO TO exit_script
 ENDIF
 SET code_set = 289
 SET cdf_meaning = "2"
 EXECUTE cpm_get_cd_for_cdf
 SET alpha_type = code_value
 SELECT INTO "nl:"
  join_path = decode(cear.seq,"E",caar.seq,"A"," "), crc.catalog_cd
  FROM cyto_report_control crc,
   (dummyt d1  WITH seq = 1),
   cyto_adequacy_alpha_r caar,
   cyto_endocerv_alpha_r cear
  PLAN (crc
   WHERE (request->catalog_cd=crc.catalog_cd))
   JOIN (d1
   WHERE 1=d1.seq)
   JOIN (((cear
   WHERE crc.catalog_cd=cear.catalog_cd
    AND crc.endocerv_task_assay_cd=cear.task_assay_cd)
   ) ORJOIN ((caar
   WHERE crc.catalog_cd=caar.catalog_cd
    AND crc.adequacy_task_assay_cd=caar.task_assay_cd)
   ))
  ORDER BY crc.catalog_cd
  HEAD crc.catalog_cd
   reply->report_type_flag = crc.report_type_flag, reply->endocerv_task_assay_cd = crc
   .endocerv_task_assay_cd, reply->diagnosis_task_assay_cd = crc.diagnosis_task_assay_cd,
   reply->adequacy_task_assay_cd = crc.adequacy_task_assay_cd, reply->adeq_reason_task_assay_cd = crc
   .adeq_reason_task_assay_cd, reply->clin_info_task_assay_cd = crc.clin_info_task_assay_cd,
   endo_cnt = 0, adeq_cnt = 0
  DETAIL
   CASE (join_path)
    OF "E":
     endo_cnt = (endo_cnt+ 1),
     IF (mod(endo_cnt,10)=1)
      stat = alterlist(reply->e_alpha_qual,(endo_cnt+ 9))
     ENDIF
     ,reply->e_alpha_qual[endo_cnt].nomenclature_id = cear.nomenclature_id,reply->e_alpha_qual[
     endo_cnt].endocerv_ind = cear.endocerv_ind
    OF "A":
     adeq_cnt = (adeq_cnt+ 1),
     IF (mod(adeq_cnt,10)=1)
      stat = alterlist(reply->a_alpha_qual,(adeq_cnt+ 9))
     ENDIF
     ,reply->a_alpha_qual[adeq_cnt].nomenclature_id = caar.nomenclature_id,reply->a_alpha_qual[
     adeq_cnt].adequacy_flag = caar.adequacy_flag,reply->a_alpha_qual[adeq_cnt].reason_required_ind
      = caar.reason_required_ind
   ENDCASE
  FOOT  crc.catalog_cd
   stat = alterlist(reply->e_alpha_qual,endo_cnt), stat = alterlist(reply->a_alpha_qual,adeq_cnt)
  WITH nocounter, outerjoin = d1
 ;end select
 IF (curqual=0)
  CALL handle_errors("SELECT","Z","TABLE","CYTOLOGY_REPORT_CONTROL")
  SET reply->status_data.status = "Z"
  SET failed = "T"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  rdt.task_assay_cd, join_path = decode(rrf.seq,"A",ita.seq,"I"," "), ita.interp_id,
  ic.interp_detail_id
  FROM report_detail_task rdt,
   reference_range_factor rrf,
   alpha_responses ar,
   nomenclature n,
   (dummyt d2  WITH seq = 1),
   interp_task_assay ita,
   interp_component ic
  PLAN (rdt
   WHERE (request->report_id=rdt.report_id))
   JOIN (d2
   WHERE 1=d2.seq)
   JOIN (((rrf
   WHERE rdt.task_assay_cd=rrf.task_assay_cd
    AND alpha_type=rdt.result_type_cd
    AND 1=rrf.active_ind)
   JOIN (ar
   WHERE rrf.reference_range_factor_id=ar.reference_range_factor_id
    AND 1=ar.active_ind)
   JOIN (n
   WHERE ar.nomenclature_id=n.nomenclature_id)
   ) ORJOIN ((ita
   WHERE rdt.task_assay_cd=ita.task_assay_cd
    AND 1=ita.active_ind)
   JOIN (ic
   WHERE ita.interp_id=ic.interp_id
    AND 1=ic.active_ind)
   ))
  ORDER BY rdt.task_assay_cd, ic.sequence
  HEAD REPORT
   section_cnt = 0, lflatalphareccnt = 0
  HEAD rdt.task_assay_cd
   alph_cnt = 0, section_cnt = (section_cnt+ 1)
   IF (mod(section_cnt,10)=1)
    stat = alterlist(reply->section_qual,(section_cnt+ 9))
   ENDIF
   reply->section_qual[section_cnt].task_assay_cd = rdt.task_assay_cd, reply->section_qual[
   section_cnt].required_ind = rdt.required_ind, interp_cnt = 0
   IF (join_path="I")
    reply->section_qual[section_cnt].interp_id = ita.interp_id, reply->section_qual[section_cnt].
    interp_type_cd = ita.interp_type_cd, reply->section_qual[section_cnt].interp_option_cd = ita
    .interp_option_cd,
    reply->section_qual[section_cnt].generate_interp_flag = ita.generate_interp_flag, reply->
    section_qual[section_cnt].order_cat_cd = ita.order_cat_cd, reply->section_qual[section_cnt].
    phase_cd = ita.phase_cd
   ENDIF
  DETAIL
   CASE (join_path)
    OF "A":
     alph_cnt = (alph_cnt+ 1),
     IF (mod(alph_cnt,10)=1)
      stat = alterlist(reply->section_qual[section_cnt].alpha_qual,(alph_cnt+ 9))
     ENDIF
     ,reply->section_qual[section_cnt].alpha_qual[alph_cnt].nomenclature_id = ar.nomenclature_id,
     reply->section_qual[section_cnt].alpha_qual[alph_cnt].nomenclature_disp = n.mnemonic,reply->
     section_qual[section_cnt].alpha_qual[alph_cnt].reference_range_factor_id = ar
     .reference_range_factor_id,
     lflatalphareccnt = (lflatalphareccnt+ 1),
     IF (lflatalphareccnt > size(flat_alpha_rec->list,5))
      stat = alterlist(flat_alpha_rec->list,(lflatalphareccnt+ 9))
     ENDIF
     ,flat_alpha_rec->list[lflatalphareccnt].nomenclature_id = ar.nomenclature_id,flat_alpha_rec->
     list[lflatalphareccnt].reference_range_factor_id = ar.reference_range_factor_id,flat_alpha_rec->
     list[lflatalphareccnt].alpha_qual_idx = alph_cnt,
     flat_alpha_rec->list[lflatalphareccnt].section_qual_idx = section_cnt
    OF "I":
     interp_cnt = (interp_cnt+ 1),
     IF (mod(interp_cnt,10)=1)
      stat = alterlist(reply->section_qual[section_cnt].interp_comp_qual,(interp_cnt+ 9))
     ENDIF
     ,reply->section_qual[section_cnt].interp_comp_qual[interp_cnt].interp_detail_id = ic
     .interp_detail_id,reply->section_qual[section_cnt].interp_comp_qual[interp_cnt].sequence = ic
     .sequence,reply->section_qual[section_cnt].interp_comp_qual[interp_cnt].included_assay_cd = ic
     .included_assay_cd,
     reply->section_qual[section_cnt].interp_comp_qual[interp_cnt].cross_drawn_dt_tm_ind = ic
     .cross_drawn_dt_tm_ind,reply->section_qual[section_cnt].interp_comp_qual[interp_cnt].
     time_window_minutes = ic.time_window_minutes,reply->section_qual[section_cnt].interp_comp_qual[
     interp_cnt].time_window_units_cd = ic.time_window_units_cd,
     reply->section_qual[section_cnt].interp_comp_qual[interp_cnt].result_req_flag = ic
     .result_req_flag,reply->section_qual[section_cnt].interp_comp_qual[interp_cnt].verified_flag =
     ic.verified_flag
   ENDCASE
  FOOT  rdt.task_assay_cd
   stat = alterlist(reply->section_qual[section_cnt].alpha_qual,alph_cnt), stat = alterlist(reply->
    section_qual[section_cnt].interp_comp_qual,interp_cnt)
  FOOT REPORT
   stat = alterlist(reply->section_qual,section_cnt), stat = alterlist(flat_alpha_rec->list,
    lflatalphareccnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL handle_errors("SELECT","Z","TABLE","REFERENCE")
  SET reply->status_data.status = "Z"
  SET failed = "T"
 ENDIF
 IF (lflatalphareccnt > 0)
  SET stat = alterlist(cytoalphasecurity->list,2)
  SET cytoalphasecurity->list[1].service_resource_cd = request->service_resource_cd
  SET cytoalphasecurity->list[2].service_resource_cd = 0.0
  SET rescnt = 2
  IF (uar_get_code_meaning(request->service_resource_cd) IN (const_serv_res_bench_cdf,
  const_serv_res_instrument_cdf))
   SELECT INTO "nl:"
    rg.parent_service_resource_cd
    FROM resource_group rg
    WHERE (rg.child_service_resource_cd=request->service_resource_cd)
     AND rg.root_service_resource_cd=0.0
     AND ((rg.resource_group_type_cd+ 0)=dservressubsectiontypecd)
     AND ((rg.active_ind+ 0)=1)
     AND rg.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
     AND rg.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    DETAIL
     rescnt = (rescnt+ 1), stat = alterlist(cytoalphasecurity->list,rescnt), cytoalphasecurity->list[
     rescnt].service_resource_cd = rg.parent_service_resource_cd
    WITH nocounter
   ;end select
  ENDIF
  SELECT INTO "nl:"
   cas.service_resource_cd, resourcelevel = evaluate(uar_get_code_meaning(cas.service_resource_cd),
    const_serv_res_bench_cdf,3,const_serv_res_instrument_cdf,3,
    const_serv_res_subsection_cdf,2,1)
   FROM cyto_alpha_security cas
   WHERE expand(lidx,1,lflatalphareccnt,cas.reference_range_factor_id,flat_alpha_rec->list[lidx].
    reference_range_factor_id,
    cas.nomenclature_id,flat_alpha_rec->list[lidx].nomenclature_id)
    AND expand(sidx,1,rescnt,cas.service_resource_cd,cytoalphasecurity->list[sidx].
    service_resource_cd)
   DETAIL
    lcur = locateval(llocatevalidx,1,lflatalphareccnt,cas.reference_range_factor_id,flat_alpha_rec->
     list[llocatevalidx].reference_range_factor_id,
     cas.nomenclature_id,flat_alpha_rec->list[llocatevalidx].nomenclature_id)
    IF ((flat_alpha_rec->list[lcur].cyto_sec_level_found_at < resourcelevel)
     AND cas.definition_ind IN (0, 1))
     flat_alpha_rec->list[lcur].cyto_sec_level_found_at = resourcelevel, reply->section_qual[
     flat_alpha_rec->list[lcur].section_qual_idx].alpha_qual[flat_alpha_rec->list[lcur].
     alpha_qual_idx].degrees_from_normal = cas.degrees_from_normal, reply->section_qual[
     flat_alpha_rec->list[lcur].section_qual_idx].alpha_qual[flat_alpha_rec->list[lcur].
     alpha_qual_idx].diagnostic_category_cd = cas.diagnostic_category_cd,
     reply->section_qual[flat_alpha_rec->list[lcur].section_qual_idx].alpha_qual[flat_alpha_rec->
     list[lcur].alpha_qual_idx].qa_flag_type_cd = cas.qa_flag_type_cd, reply->section_qual[
     flat_alpha_rec->list[lcur].section_qual_idx].alpha_qual[flat_alpha_rec->list[lcur].
     alpha_qual_idx].requeue_flag = cas.requeue_flag, reply->section_qual[flat_alpha_rec->list[lcur].
     section_qual_idx].alpha_qual[flat_alpha_rec->list[lcur].alpha_qual_idx].
     requeue_service_resource_cd = cas.requeue_service_resource_cd,
     reply->section_qual[flat_alpha_rec->list[lcur].section_qual_idx].alpha_qual[flat_alpha_rec->
     list[lcur].alpha_qual_idx].verify_level_is = cas.verify_level_is, reply->section_qual[
     flat_alpha_rec->list[lcur].section_qual_idx].alpha_qual[flat_alpha_rec->list[lcur].
     alpha_qual_idx].verify_level_rs = cas.verify_level_rs, reply->section_qual[flat_alpha_rec->list[
     lcur].section_qual_idx].alpha_qual[flat_alpha_rec->list[lcur].alpha_qual_idx].workload_cd = cas
     .workload_cd
    ENDIF
    IF ((flat_alpha_rec->list[lcur].ft_params_level_found_at < resourcelevel)
     AND cas.definition_ind IN (0, 2))
     flat_alpha_rec->list[lcur].ft_params_level_found_at = resourcelevel, reply->section_qual[
     flat_alpha_rec->list[lcur].section_qual_idx].alpha_qual[flat_alpha_rec->list[lcur].
     alpha_qual_idx].followup_final_interval = cas.followup_final_interval, reply->section_qual[
     flat_alpha_rec->list[lcur].section_qual_idx].alpha_qual[flat_alpha_rec->list[lcur].
     alpha_qual_idx].followup_first_interval = cas.followup_first_interval,
     reply->section_qual[flat_alpha_rec->list[lcur].section_qual_idx].alpha_qual[flat_alpha_rec->
     list[lcur].alpha_qual_idx].followup_initial_interval = cas.followup_initial_interval, reply->
     section_qual[flat_alpha_rec->list[lcur].section_qual_idx].alpha_qual[flat_alpha_rec->list[lcur].
     alpha_qual_idx].followup_termination_interval = cas.followup_termination_interval, reply->
     section_qual[flat_alpha_rec->list[lcur].section_qual_idx].alpha_qual[flat_alpha_rec->list[lcur].
     alpha_qual_idx].followup_tracking_type_cd = cas.followup_tracking_type_cd
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  csr.standard_rpt_id, csrr.task_assay_cd
  FROM cyto_standard_rpt csr,
   cyto_standard_rpt_r csrr
  PLAN (csr
   WHERE (request->catalog_cd=csr.catalog_cd)
    AND 1=csr.active_ind)
   JOIN (csrr
   WHERE csr.standard_rpt_id=csrr.standard_rpt_id)
  ORDER BY csr.standard_rpt_id
  HEAD REPORT
   sr_cnt = 0, srr_cnt = 0
  HEAD csr.standard_rpt_id
   sr_cnt = (sr_cnt+ 1)
   IF (mod(sr_cnt,10)=1)
    stat = alterlist(reply->sr_qual,(sr_cnt+ 9))
   ENDIF
   reply->sr_qual[sr_cnt].standard_rpt_cd = csr.standard_rpt_id, reply->sr_qual[sr_cnt].description
    = csr.description, reply->sr_qual[sr_cnt].code = csr.short_desc,
   reply->sr_qual[sr_cnt].hot_key_sequence = csr.hot_key_sequence, srr_cnt = 0
  DETAIL
   srr_cnt = (srr_cnt+ 1)
   IF (mod(srr_cnt,10)=1)
    stat = alterlist(reply->sr_qual[sr_cnt].srr_qual,(srr_cnt+ 9))
   ENDIF
   reply->sr_qual[sr_cnt].srr_qual[srr_cnt].task_assay_cd = csrr.task_assay_cd, reply->sr_qual[sr_cnt
   ].srr_qual[srr_cnt].result_cd = csrr.nomenclature_id, reply->sr_qual[sr_cnt].srr_qual[srr_cnt].
   result_text = csrr.result_text
  FOOT  csr.standard_rpt_id
   stat = alterlist(reply->sr_qual[sr_cnt].srr_qual,srr_cnt)
  FOOT REPORT
   stat = alterlist(reply->sr_qual,sr_cnt)
  WITH nocounter
 ;end select
 SUBROUTINE handle_errors(op_name,op_status,tar_name,tar_value)
   SET error_cnt = (error_cnt+ 1)
   IF (error_cnt > 1)
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[error_cnt].operationname = op_name
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = op_status
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = tar_name
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = tar_value
 END ;Subroutine
#exit_script
 IF (failed="F")
  SET reply->status_data.status = "S"
 ENDIF
 FREE RECORD flat_alpha_rec
END GO
