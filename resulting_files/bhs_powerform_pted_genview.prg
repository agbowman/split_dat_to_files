CREATE PROGRAM bhs_powerform_pted_genview
 DECLARE primaryeventid_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",18189,"PRIMARYEVENTID")),
 protect
 DECLARE ordstsord = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"ORDERED")), protect
 DECLARE acttyppharm = f8 WITH constant(uar_get_code_by("DISPLAYKEY",106,"PHARMACY")), protect
 DECLARE prblmrlrec = f8 WITH constant(uar_get_code_by("DISPLAYKEY",12038,"RECORDER")), protect
 DECLARE prblmrlres = f8 WITH constant(uar_get_code_by("DISPLAYKEY",12038,"RESPONSIBLEMANAGING")),
 protect
 DECLARE cd_status = f8 WITH constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE")), protect
 DECLARE cd_comp = f8 WITH constant(uar_get_code_by("DISPLAYKEY",120,"OCFCOMPRESSION")), protect
 DECLARE ecdate = f8 WITH constant(uar_get_code_by("DISPLAYKEY",53,"DATE")), protect
 DECLARE ecnum = f8 WITH constant(uar_get_code_by("DISPLAYKEY",53,"NUM")), protect
 DECLARE ectxt = f8 WITH constant(uar_get_code_by("DISPLAYKEY",53,"TXT")), protect
 DECLARE cd_clinical = f8 WITH constant(uar_get_code_by("DISPLAYKEY",18189,"PRIMARYEVENTID_VAR")),
 protect
 RECORD run_info(
   1 person_id = f8
   1 encntr_id = f8
 )
 RECORD ref_info(
   1 updt_dt_tm = dq8
   1 prsnl_cnt = i4
   1 prsnl[*]
     2 prsnl_name = vc
   1 form_desc = vc
   1 ln_cnt = i4
   1 lns[*]
     2 text = vc
   1 allergy_ind = i2
   1 problem_ind = i2
   1 med_list_ind = i2
   1 ctrl_ind = i2
   1 grid_ind = i2
   1 section_cnt = i4
   1 sections[*]
     2 section_ref_id = f8
     2 section_instance_id = f8
     2 event_id = f8
     2 event_end_dt_tm = dq8
     2 section_seq = i4
     2 section_desc = vc
     2 ln_cnt = i4
     2 lns[*]
       3 text = vc
     2 section_data_ind = i2
     2 ctrl_ind = i2
     2 grid_ind = i2
     2 input_cnt = i4
     2 inputs[*]
       3 input_ref_id = f8
       3 input_type = i4
       3 input_seq = i4
       3 module = vc
       3 input_desc = vc
       3 ln_cnt = i4
       3 lns[*]
         4 text = vc
       3 input_data_ind = i2
       3 allergy_ind = i2
       3 problem_ind = i2
       3 med_list_ind = i2
       3 ctrl_slot_ind = i4
       3 grid_slot_ind = i4
       3 pvc_cnt = i4
       3 pvc_entries[*]
         4 pvc_name = vc
         4 pvc_value = vc
         4 merge_id = f8
         4 merge_name = vc
         4 seq = i4
       3 grid_event_cd = f8
 )
 RECORD act_info(
   1 ctrl_cnt = i4
   1 ctrls[*]
     2 ctrl_type = i4
     2 ctrl_desc = vc
     2 event_tag = vc
     2 ln_cnt = i4
     2 lns[*]
       3 text = vc
     2 event_id = f8
     2 parent_event_id = f8
     2 task_assay_cd = f8
     2 event_cd = f8
     2 result_val = vc
     2 event_class_cd = f8
     2 event_end_dt_tm = dq8
     2 prsnl_name = vc
     2 nomen_cnt = i4
     2 nomen[*]
       3 nomenclature_id = f8
       3 nomenclature = vc
   1 grid_cnt = i4
   1 grids[*]
     2 grid_type = i4
     2 lvl1_event_id = f8
     2 lvl2_event_id = f8
     2 grid_desc = vc
     2 ln_cnt = i4
     2 lns[*]
       3 text = vc
     2 row_cnt = i4
     2 rows[*]
       3 row_event_id = f8
       3 row_event_cd = f8
       3 task_assay_cd = f8
       3 row_desc = vc
       3 row_seq = i4
       3 ln_cnt = i4
       3 lns[*]
         4 text = vc
       3 col_cnt = i4
       3 cols[*]
         4 col_event_id = f8
         4 col_event_cd = f8
         4 task_assay_cd = f8
         4 col_desc = vc
         4 col_seq = i4
         4 event_tag = vc
         4 result_val = vc
         4 event_class_cd = f8
         4 event_end_dt_tm = dq8
         4 prsnl_name = vc
         4 nomen_cnt = i4
         4 nomen[*]
           5 nomenclature_id = f8
           5 nomenclature = vc
         4 ln_cnt = i4
         4 lns[*]
           5 text = vc
   1 allergy_cnt = i4
   1 allergies[*]
     2 allergy_id = f8
     2 allergy_instance_id = f8
     2 allergy = vc
     2 allergy_ln_cnt = i4
     2 allergy_lns[*]
       3 line = vc
     2 reaction_cnt = i4
     2 reactions[*]
       3 nomenclature_id = f8
       3 nomenclature = vc
     2 reaction_status = vc
     2 severity = vc
     2 substance_type = vc
     2 comment_cnt = i4
     2 comments[*]
       3 comment = vc
       3 comment_dt_tm = dq8
       3 prsnl = vc
       3 comment_ln_cnt = i4
       3 comment_lns[*]
         4 text = vc
     2 onset_dt = vc
     2 onset_precision = vc
     2 update_prsnl = vc
     2 update_dt_tm = dq8
     2 source = vc
     2 review_prsnl = vc
     2 review_dt_tm = dq8
   1 problem_cnt = i4
   1 problems[*]
     2 problem_id = f8
     2 problem_instance_id = f8
     2 nomenclature_id = f8
     2 problem = vc
     2 problem_ln_cnt = i4
     2 problem_lns[*]
       3 line = vc
     2 life_cycle_status = vc
     2 course = vc
     2 comment_cnt = i4
     2 comments[*]
       3 comment = vc
       3 comment_dt_tm = dq8
       3 prsnl = vc
       3 comment_ln_cnt = i4
       3 comment_lns[*]
         4 text = vc
     2 onset_dt = vc
     2 onset_precision = vc
     2 responsible_prsnl = vc
     2 recording_prsnl = vc
   1 med_cnt = i4
   1 meds[*]
     2 order_id = f8
     2 action_seq = i4
     2 hna_order_mnemonic = vc
     2 ordered_as_mnemonic = vc
     2 display_line = vc
     2 display_line_ln_cnt = i4
     2 display_line_lns[*]
       3 text = vc
     2 ordering_phys = vc
     2 action_prsnl = vc
     2 communication_type = vc
     2 start_dt_tm = dq8
     2 type_ind = vc
     2 comment_cnt = i4
     2 comments[*]
       3 long_text_id = f8
       3 comment_type = vc
       3 prsnl = vc
       3 comment_dt_tm = dq8
       3 comment = vc
       3 comment_ln_cnt = i4
       3 comment_lns[*]
         4 text = vc
 )
 SET ref_info->form_desc = "Patient/Family Education"
 IF (validate(request->visit[1].encntr_id,0.0) > 0.0)
  SELECT INTO "NL:"
   FROM encounter e
   PLAN (e
    WHERE (e.encntr_id=request->visit[1].encntr_id))
   DETAIL
    run_info->encntr_id = e.encntr_id, run_info->person_id = e.person_id
   WITH nocounter
  ;end select
 ELSE
  SET run_info->encntr_id = 31573351
  SET run_info->person_id = 17892439
 ENDIF
 SELECT DISTINCT INTO "NL:"
  ce.event_id, dsr.definition, dfd.section_seq,
  dsr.dcp_section_instance_id
  FROM dcp_forms_ref dfr,
   dcp_forms_activity dfa,
   dcp_forms_activity_comp dfac,
   clinical_event ce,
   dcp_section_ref dsr,
   dcp_forms_ref dfr2,
   dcp_forms_def dfd
  PLAN (dfr
   WHERE dfr.description="Patient/Family Education")
   JOIN (dfa
   WHERE dfr.dcp_forms_ref_id=dfa.dcp_forms_ref_id
    AND (dfa.encntr_id=run_info->encntr_id))
   JOIN (dfac
   WHERE dfa.dcp_forms_activity_id=dfac.dcp_forms_activity_id
    AND dfac.component_cd=primaryeventid_var)
   JOIN (ce
   WHERE dfac.parent_entity_id=ce.parent_event_id)
   JOIN (dsr
   WHERE cnvtreal(ce.collating_seq)=dsr.dcp_section_ref_id
    AND ce.event_end_dt_tm BETWEEN dsr.beg_effective_dt_tm AND dsr.end_effective_dt_tm)
   JOIN (dfr2
   WHERE dfa.dcp_forms_ref_id=dfr2.dcp_forms_ref_id
    AND dfa.version_dt_tm BETWEEN dfr2.beg_effective_dt_tm AND dfr2.end_effective_dt_tm)
   JOIN (dfd
   WHERE dfr2.dcp_form_instance_id=dfd.dcp_form_instance_id
    AND dsr.dcp_section_ref_id=dfd.dcp_section_ref_id)
  ORDER BY dfd.section_seq, ce.event_end_dt_tm DESC, 0
  HEAD REPORT
   s_cnt = 0
  HEAD dsr.definition
   s_cnt = (s_cnt+ 1), ref_info->section_cnt = s_cnt, stat = alterlist(ref_info->sections,s_cnt),
   ref_info->sections[s_cnt].section_ref_id = dsr.dcp_section_ref_id, ref_info->sections[s_cnt].
   section_instance_id = dsr.dcp_section_instance_id, ref_info->sections[s_cnt].section_seq = dfd
   .section_seq,
   ref_info->sections[s_cnt].section_desc = dsr.description, ref_info->sections[s_cnt].event_id = ce
   .event_id, ref_info->sections[s_cnt].event_end_dt_tm = ce.event_end_dt_tm
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  dir.dcp_input_ref_id, dir.description, nvp1.pvc_name,
  nvp1.pvc_value, nvp1.merge_id, nvp1.merge_name,
  nvp2.pvc_name, nvp2.pvc_value, nvp2.merge_id,
  nvp2.merge_name
  FROM (dummyt d  WITH seq = value(ref_info->section_cnt)),
   dcp_input_ref dir,
   name_value_prefs nvp1,
   name_value_prefs nvp2
  PLAN (d)
   JOIN (dir
   WHERE (ref_info->sections[d.seq].section_instance_id=dir.dcp_section_instance_id)
    AND (( NOT (dir.input_type IN (1, 12, 21, 23))
    AND dir.module=" ") OR (dir.module="PFEXTCTRLS")) )
   JOIN (nvp1
   WHERE outerjoin(dir.dcp_input_ref_id)=nvp1.parent_entity_id
    AND nvp1.parent_entity_name=outerjoin("DCP_INPUT_REF")
    AND nvp1.pvc_name=outerjoin("grid_event_cd"))
   JOIN (nvp2
   WHERE outerjoin(dir.dcp_input_ref_id)=nvp2.parent_entity_id
    AND nvp2.parent_entity_name=outerjoin("DCP_INPUT_REF")
    AND nvp2.pvc_name=outerjoin("discrete_task_assay*"))
  ORDER BY d.seq, dir.input_ref_seq, nvp2.sequence
  HEAD REPORT
   i_cnt = 0, p_cnt = 0
  HEAD d.seq
   i_cnt = 0, p_cnt = 0
  HEAD dir.input_ref_seq
   i_cnt = (i_cnt+ 1), stat = alterlist(ref_info->sections[d.seq].inputs,i_cnt), ref_info->sections[d
   .seq].inputs[i_cnt].input_ref_id = dir.dcp_input_ref_id,
   ref_info->sections[d.seq].inputs[i_cnt].input_type = dir.input_type, ref_info->sections[d.seq].
   inputs[i_cnt].module = dir.module, ref_info->sections[d.seq].inputs[i_cnt].input_desc = dir
   .description,
   ref_info->sections[d.seq].inputs[i_cnt].input_seq = dir.input_ref_seq
   IF (dir.input_type IN (14, 17, 19))
    ref_info->sections[d.seq].inputs[i_cnt].grid_event_cd = nvp1.merge_id
   ENDIF
   IF (dir.input_type IN (4, 6, 7, 9, 10,
   12, 13, 16, 18, 22))
    ref_info->ctrl_ind = 1, ref_info->sections[d.seq].ctrl_ind = 1
   ELSEIF (dir.input_type IN (14, 17, 19))
    ref_info->grid_ind = 1, ref_info->sections[d.seq].grid_ind = 1
   ELSEIF (dir.input_type=11)
    ref_info->allergy_ind = 1, ref_info->sections[d.seq].inputs[i_cnt].allergy_ind = 1, ref_info->
    sections[d.seq].section_data_ind = 1,
    ref_info->sections[d.seq].inputs[i_cnt].input_data_ind = 1
   ELSEIF (dir.input_type=1
    AND dir.module="PFEXTCTRLS")
    ref_info->med_list_ind = 1, ref_info->sections[d.seq].inputs[i_cnt].med_list_ind = 1, ref_info->
    sections[d.seq].section_data_ind = 1,
    ref_info->sections[d.seq].inputs[i_cnt].input_data_ind = 1
   ELSEIF (dir.input_type=2
    AND dir.module="PFEXTCTRLS")
    ref_info->problem_ind = 1, ref_info->sections[d.seq].inputs[i_cnt].problem_ind = 1, ref_info->
    sections[d.seq].section_data_ind = 1,
    ref_info->sections[d.seq].inputs[i_cnt].input_data_ind = 1
   ENDIF
   p_cnt = 0
  DETAIL
   IF (nvp2.name_value_prefs_id > 0.0)
    p_cnt = (p_cnt+ 1), stat = alterlist(ref_info->sections[d.seq].inputs[i_cnt].pvc_entries,p_cnt),
    ref_info->sections[d.seq].inputs[i_cnt].pvc_entries[p_cnt].pvc_name = nvp2.pvc_name,
    ref_info->sections[d.seq].inputs[i_cnt].pvc_entries[p_cnt].pvc_value = nvp2.pvc_value, ref_info->
    sections[d.seq].inputs[i_cnt].pvc_entries[p_cnt].merge_id = nvp2.merge_id, ref_info->sections[d
    .seq].inputs[i_cnt].pvc_entries[p_cnt].merge_name = nvp2.merge_name,
    ref_info->sections[d.seq].inputs[i_cnt].pvc_entries[p_cnt].seq = nvp2.sequence
   ENDIF
  FOOT  dir.input_ref_seq
   ref_info->sections[d.seq].inputs[i_cnt].pvc_cnt = p_cnt
  FOOT  d.seq
   ref_info->sections[d.seq].input_cnt = i_cnt
  WITH nocounter
 ;end select
 IF ((ref_info->ctrl_ind=0))
  GO TO get_grids
 ENDIF
 SELECT INTO "NL:"
  FROM (dummyt d1  WITH seq = value(ref_info->section_cnt)),
   dummyt d2,
   clinical_event ce1,
   prsnl pr,
   ce_date_result cdr,
   ce_coded_result ccr,
   nomenclature n,
   ce_string_result csr,
   ce_blob cb
  PLAN (d1
   WHERE (ref_info->sections[d1.seq].ctrl_ind=1)
    AND maxrec(d2,ref_info->sections[d1.seq].input_cnt))
   JOIN (d2
   WHERE (ref_info->sections[d1.seq].inputs[d2.seq].input_type IN (4, 6, 7, 9, 10,
   12, 13, 16, 18, 22)))
   JOIN (ce1
   WHERE (ref_info->sections[d1.seq].event_id=ce1.parent_event_id)
    AND (ce1.task_assay_cd=ref_info->sections[d1.seq].inputs[d2.seq].pvc_entries[1].merge_id)
    AND ce1.view_level=1
    AND ce1.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
   JOIN (pr
   WHERE outerjoin(ce1.performed_prsnl_id)=pr.person_id)
   JOIN (cdr
   WHERE outerjoin(ce1.event_id)=cdr.event_id
    AND cdr.valid_until_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00")))
   JOIN (ccr
   WHERE outerjoin(ce1.event_id)=ccr.event_id
    AND ccr.valid_until_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00")))
   JOIN (n
   WHERE outerjoin(ccr.nomenclature_id)=n.nomenclature_id)
   JOIN (csr
   WHERE outerjoin(ccr.event_id)=csr.event_id
    AND csr.valid_until_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00")))
   JOIN (cb
   WHERE outerjoin(ce1.event_id)=cb.event_id
    AND cb.valid_until_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00")))
  HEAD REPORT
   c_cnt = 0, n_cnt = 0, blob_in = fillstring(32000," "),
   blob_out = fillstring(32000," "), blob_out2 = fillstring(32000," "), blob_out3 = fillstring(32000,
    " "),
   blob_ret_len = 0
  HEAD ce1.event_id
   c_cnt = (c_cnt+ 1), stat = alterlist(act_info->ctrls,c_cnt), ref_info->sections[d1.seq].
   section_data_ind = 1,
   ref_info->sections[d1.seq].inputs[d2.seq].input_data_ind = 1, ref_info->sections[d1.seq].inputs[d2
   .seq].ctrl_slot_ind = c_cnt, act_info->ctrls[c_cnt].event_id = ce1.event_id,
   act_info->ctrls[c_cnt].parent_event_id = ce1.parent_event_id, act_info->ctrls[c_cnt].event_cd =
   ce1.event_cd, act_info->ctrls[c_cnt].task_assay_cd = ce1.task_assay_cd,
   act_info->ctrls[c_cnt].result_val = ce1.result_val, act_info->ctrls[c_cnt].event_class_cd = ce1
   .event_class_cd, act_info->ctrls[c_cnt].event_end_dt_tm = ce1.event_end_dt_tm,
   act_info->ctrls[c_cnt].prsnl_name = pr.name_full_formatted, act_info->ctrls[c_cnt].ctrl_type =
   ref_info->sections[d1.seq].inputs[d2.seq].input_type, act_info->ctrls[c_cnt].ctrl_desc =
   uar_get_code_display(ce1.event_cd)
   IF (ce1.event_class_cd=ectxt)
    IF (csr.event_id > 0.0)
     act_info->ctrls[c_cnt].event_tag = csr.string_result_text
    ELSE
     act_info->ctrls[c_cnt].event_tag = ce1.result_val
    ENDIF
   ELSEIF (ce1.event_class_cd=ecnum)
    IF (ce1.result_units_cd > 0.0)
     act_info->ctrls[c_cnt].event_tag = concat(trim(ce1.result_val,3)," ",uar_get_code_display(ce1
       .result_units_cd))
    ELSE
     act_info->ctrls[c_cnt].event_tag = ce1.result_val
    ENDIF
   ELSEIF (ce1.event_class_cd=ecdate)
    IF (cdr.date_type_flag=0)
     act_info->ctrls[c_cnt].event_tag = format(cdr.result_dt_tm,"MM/DD/YYYY HH:MM;;D")
    ELSEIF (cdr.date_type_flag=1)
     act_info->ctrls[c_cnt].event_tag = format(cdr.result_dt_tm,"MM/DD/YYYY;;D")
    ELSEIF (cdr.date_type_flag=2)
     act_info->ctrls[c_cnt].event_tag = format(cdr.result_dt_tm,"HH:MM;;S")
    ENDIF
   ENDIF
   IF (cb.event_id > 0.0)
    blob_in = fillstring(32000," "), blob_out = fillstring(32000," "), blob_out2 = fillstring(32000,
     " "),
    blob_out3 = fillstring(32000," "), blob_ret_len = 0
    IF (cb.compression_cd=cd_comp)
     blob_in = cb.blob_contents,
     CALL uar_ocf_uncompress(blob_in,32000,blob_out,32000,blob_ret_len), blob_out2 = replace(blob_out,
      char(013),"",0),
     blob_out2 = replace(blob_out2,"ocf_blob","",0)
    ELSE
     blob_out2 = replace(cb.blob_contents,char(013),"",0), blob_out2 = replace(blob_out2,"ocf_blob",
      "",0)
    ENDIF
    CALL uar_rtf(blob_out2,textlen(blob_out2),blob_out3,32000,32000,0), act_info->ctrls[c_cnt].
    event_tag = trim(blob_out3)
   ENDIF
   n_cnt = 0
  DETAIL
   IF (ccr.event_id > 0.0)
    n_cnt = (n_cnt+ 1), stat = alterlist(act_info->ctrls[c_cnt].nomen,n_cnt), act_info->ctrls[c_cnt].
    nomen[n_cnt].nomenclature_id = n.nomenclature_id,
    act_info->ctrls[c_cnt].nomen[n_cnt].nomenclature = n.source_string
   ENDIF
  FOOT  ce1.event_id
   act_info->ctrls[c_cnt].nomen_cnt = n_cnt
  FOOT REPORT
   act_info->ctrl_cnt = c_cnt
  WITH nocounter
 ;end select
#get_grids
 IF ((ref_info->grid_ind=0))
  GO TO get_allergies
 ENDIF
 SELECT INTO "NL:"
  FROM (dummyt d1  WITH seq = value(ref_info->section_cnt)),
   dummyt d2,
   dummyt d3,
   clinical_event ce1,
   clinical_event ce2,
   clinical_event ce3,
   clinical_event ce4,
   prsnl pr1,
   prsnl pr2,
   ce_coded_result ccr1,
   ce_coded_result ccr2,
   nomenclature n1,
   nomenclature n2,
   ce_date_result cdr,
   ce_string_result csr
  PLAN (d1
   WHERE (ref_info->sections[d1.seq].grid_ind=1)
    AND maxrec(d2,ref_info->sections[d1.seq].input_cnt))
   JOIN (d2
   WHERE (ref_info->sections[d1.seq].inputs[d2.seq].input_type IN (14, 17, 19)))
   JOIN (ce1
   WHERE (ref_info->primary_event_id=ce1.parent_event_id)
    AND ce1.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND ce1.collating_seq > " ")
   JOIN (d3
   WHERE (cnvtreal(ce1.collating_seq)=ref_info->sections[d1.seq].section_ref_id))
   JOIN (ce2
   WHERE outerjoin(ce1.event_id)=ce2.parent_event_id
    AND ce2.event_cd=outerjoin(ref_info->sections[d1.seq].inputs[d2.seq].grid_event_cd)
    AND ce2.valid_until_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00")))
   JOIN (ce3
   WHERE outerjoin(ce2.event_id)=ce3.parent_event_id
    AND ce3.valid_until_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00")))
   JOIN (ce4
   WHERE outerjoin(ce3.event_id)=ce4.parent_event_id
    AND ce4.valid_until_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00")))
   JOIN (pr1
   WHERE outerjoin(ce3.performed_prsnl_id)=pr1.person_id)
   JOIN (pr2
   WHERE outerjoin(ce4.performed_prsnl_id)=pr2.person_id)
   JOIN (ccr1
   WHERE outerjoin(ce3.event_id)=ccr1.event_id
    AND ccr1.valid_until_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00")))
   JOIN (ccr2
   WHERE outerjoin(ce4.event_id)=ccr2.event_id
    AND ccr2.valid_until_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00")))
   JOIN (n1
   WHERE outerjoin(ccr1.nomenclature_id)=n1.nomenclature_id)
   JOIN (n2
   WHERE outerjoin(ccr2.nomenclature_id)=n2.nomenclature_id)
   JOIN (cdr
   WHERE outerjoin(ce4.event_id)=cdr.event_id
    AND cdr.valid_until_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00")))
   JOIN (csr
   WHERE outerjoin(ce4.event_id)=csr.event_id
    AND csr.valid_until_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00")))
  HEAD REPORT
   g_cnt = 0, r_cnt = 0, c_cnt = 0,
   n_cnt = 0
  HEAD ce2.event_id
   g_cnt = (g_cnt+ 1), stat = alterlist(act_info->grids,g_cnt), ref_info->sections[d1.seq].
   section_data_ind = 1,
   ref_info->sections[d1.seq].inputs[d2.seq].input_data_ind = 1, ref_info->sections[d1.seq].inputs[d2
   .seq].grid_slot_ind = g_cnt, act_info->grids[g_cnt].grid_type = ref_info->sections[d1.seq].inputs[
   d2.seq].input_type,
   act_info->grids[g_cnt].lvl1_event_id = ce1.event_id, act_info->grids[g_cnt].lvl2_event_id = ce2
   .event_id, act_info->grids[g_cnt].grid_desc = uar_get_code_display(ce2.event_cd),
   r_cnt = 0, c_cnt = 0, n_cnt = 0
  HEAD ce3.event_id
   r_cnt = (r_cnt+ 1), stat = alterlist(act_info->grids[g_cnt].rows,r_cnt), act_info->grids[g_cnt].
   rows[r_cnt].row_event_id = ce3.event_id,
   act_info->grids[g_cnt].rows[r_cnt].row_event_cd = ce3.event_cd, act_info->grids[g_cnt].rows[r_cnt]
   .task_assay_cd = ce3.task_assay_cd, act_info->grids[g_cnt].rows[r_cnt].row_desc =
   uar_get_code_display(ce3.event_cd),
   act_info->grids[g_cnt].rows[r_cnt].row_seq = cnvtint(ce3.collating_seq), c_cnt = 0, n_cnt = 0
  HEAD ce4.event_id
   IF (ce4.event_id > 0.0)
    c_cnt = (c_cnt+ 1), stat = alterlist(act_info->grids[g_cnt].rows[r_cnt].cols,c_cnt), act_info->
    grids[g_cnt].rows[r_cnt].cols[c_cnt].col_event_id = ce4.event_id,
    act_info->grids[g_cnt].rows[r_cnt].cols[c_cnt].col_event_cd = ce4.event_cd, act_info->grids[g_cnt
    ].rows[r_cnt].cols[c_cnt].task_assay_cd = ce4.task_assay_cd, act_info->grids[g_cnt].rows[r_cnt].
    cols[c_cnt].col_desc = uar_get_code_display(ce4.event_cd),
    act_info->grids[g_cnt].rows[r_cnt].cols[c_cnt].col_seq = cnvtint(ce4.collating_seq), act_info->
    grids[g_cnt].rows[r_cnt].cols[c_cnt].event_tag = ce4.event_tag, act_info->grids[g_cnt].rows[r_cnt
    ].cols[c_cnt].event_class_cd = ce4.event_class_cd,
    act_info->grids[g_cnt].rows[r_cnt].cols[c_cnt].event_end_dt_tm = ce4.event_end_dt_tm, act_info->
    grids[g_cnt].rows[r_cnt].cols[c_cnt].prsnl_name = pr2.name_full_formatted
    IF (ce4.event_class_cd=ectxt)
     IF (csr.event_id > 0.0)
      act_info->grids[g_cnt].rows[r_cnt].cols[c_cnt].event_tag = csr.string_result_text
     ELSE
      act_info->grids[g_cnt].rows[r_cnt].cols[c_cnt].event_tag = ce4.result_val
     ENDIF
    ELSEIF (ce4.event_class_cd=ecnum)
     IF (ce2.result_units_cd > 0.0)
      act_info->grids[g_cnt].rows[r_cnt].cols[c_cnt].event_tag = concat(trim(ce4.result_val,3)," ",
       uar_get_code_display(ce4.result_units_cd))
     ELSE
      act_info->grids[g_cnt].rows[r_cnt].cols[c_cnt].event_tag = ce4.result_val
     ENDIF
    ELSEIF (ce4.event_class_cd=ecdate)
     IF (cdr.date_type_flag=0)
      act_info->grids[g_cnt].rows[r_cnt].cols[c_cnt].event_tag = format(cdr.result_dt_tm,
       "MM/DD/YYYY HH:MM;;D")
     ELSEIF (cdr.date_type_flag=1)
      act_info->grids[g_cnt].rows[r_cnt].cols[c_cnt].event_tag = format(cdr.result_dt_tm,
       "MM/DD/YYYY;;D")
     ELSEIF (cdr.date_type_flag=2)
      act_info->grids[g_cnt].rows[r_cnt].cols[c_cnt].event_tag = format(cdr.result_dt_tm,"HH:MM;;S")
     ENDIF
    ENDIF
   ELSE
    c_cnt = 1, stat = alterlist(act_info->grids[g_cnt].rows[r_cnt].cols,c_cnt), act_info->grids[g_cnt
    ].rows[r_cnt].cols[c_cnt].col_event_id = ce3.event_id,
    act_info->grids[g_cnt].rows[r_cnt].cols[c_cnt].col_event_cd = ce3.event_cd, act_info->grids[g_cnt
    ].rows[r_cnt].cols[c_cnt].task_assay_cd = ce3.task_assay_cd, act_info->grids[g_cnt].rows[r_cnt].
    cols[c_cnt].col_desc = uar_get_code_display(ce3.event_cd),
    act_info->grids[g_cnt].rows[r_cnt].cols[c_cnt].col_seq = cnvtint(ce3.collating_seq), act_info->
    grids[g_cnt].rows[r_cnt].cols[c_cnt].event_tag = ce3.event_tag, act_info->grids[g_cnt].rows[r_cnt
    ].cols[c_cnt].event_end_dt_tm = ce3.event_end_dt_tm,
    act_info->grids[g_cnt].rows[r_cnt].cols[c_cnt].prsnl_name = pr1.name_full_formatted
   ENDIF
   n_cnt = 0
  DETAIL
   IF (n1.nomenclature_id > 0.0)
    n_cnt = (n_cnt+ 1), stat = alterlist(act_info->grids[g_cnt].rows[r_cnt].cols[c_cnt].nomen,n_cnt),
    act_info->grids[g_cnt].rows[r_cnt].cols[c_cnt].nomen[n_cnt].nomenclature_id = n1.nomenclature_id,
    act_info->grids[g_cnt].rows[r_cnt].cols[c_cnt].nomen[n_cnt].nomenclature = n1.source_string
   ELSEIF (n2.nomenclature_id > 0.0)
    n_cnt = (n_cnt+ 1), stat = alterlist(act_info->grids[g_cnt].rows[r_cnt].cols[c_cnt].nomen,n_cnt),
    act_info->grids[g_cnt].rows[r_cnt].cols[c_cnt].nomen[n_cnt].nomenclature_id = n2.nomenclature_id,
    act_info->grids[g_cnt].rows[r_cnt].cols[c_cnt].nomen[n_cnt].nomenclature = n2.source_string
   ENDIF
  FOOT  ce4.event_id
   act_info->grids[g_cnt].rows[r_cnt].cols[c_cnt].nomen_cnt = n_cnt
  FOOT  ce3.event_id
   act_info->grids[g_cnt].rows[r_cnt].col_cnt = c_cnt
  FOOT  ce2.event_id
   act_info->grids[g_cnt].row_cnt = r_cnt
  FOOT REPORT
   act_info->grid_cnt = g_cnt
  WITH nocounter
 ;end select
#get_allergies
 IF ((ref_info->allergy_ind=0))
  GO TO get_problems
 ENDIF
 SELECT INTO "NL:"
  FROM allergy a,
   allergy_comment ac,
   reaction r,
   prsnl pr1,
   prsnl pr2,
   prsnl pr3,
   nomenclature n1,
   nomenclature n2
  PLAN (a
   WHERE (run_info->encntr_id=a.encntr_id)
    AND a.cancel_dt_tm=null
    AND a.active_ind=1
    AND a.active_status_cd=cd_status
    AND a.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 23:59:59"))
   JOIN (n1
   WHERE outerjoin(a.substance_nom_id)=n1.nomenclature_id)
   JOIN (pr1
   WHERE outerjoin(a.updt_id)=pr1.person_id)
   JOIN (pr2
   WHERE outerjoin(a.reviewed_prsnl_id)=pr2.person_id)
   JOIN (ac
   WHERE outerjoin(a.allergy_id)=ac.allergy_id
    AND ac.active_ind=outerjoin(1)
    AND ac.active_status_cd=outerjoin(cd_status)
    AND ac.end_effective_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 23:59:59")))
   JOIN (pr3
   WHERE outerjoin(ac.comment_prsnl_id)=pr3.person_id)
   JOIN (r
   WHERE outerjoin(a.allergy_id)=r.allergy_id
    AND r.active_ind=outerjoin(1)
    AND r.active_status_cd=outerjoin(cd_status)
    AND r.end_effective_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 23:59:59")))
   JOIN (n2
   WHERE outerjoin(r.reaction_nom_id)=n2.nomenclature_id)
  HEAD REPORT
   a_cnt = 0, c_cnt = 0, r_cnt = 0
  HEAD a.allergy_id
   a_cnt = (a_cnt+ 1), stat = alterlist(act_info->allergies,a_cnt), act_info->allergies[a_cnt].
   allergy_id = a.allergy_id,
   act_info->allergies[a_cnt].allergy_instance_id = a.allergy_instance_id, act_info->allergies[a_cnt]
   .reaction_status = uar_get_code_display(a.reaction_status_cd), act_info->allergies[a_cnt].severity
    = uar_get_code_display(a.severity_cd),
   act_info->allergies[a_cnt].substance_type = uar_get_code_display(a.substance_type_cd), act_info->
   allergies[a_cnt].update_prsnl = pr1.name_full_formatted, act_info->allergies[a_cnt].update_dt_tm
    = a.updt_dt_tm
   IF (n1.nomenclature_id > 0.0)
    act_info->allergies[a_cnt].allergy = n1.source_string
   ELSE
    act_info->allergies[a_cnt].allergy = a.substance_ftdesc
   ENDIF
   IF (a.source_of_info_cd > 0.0)
    act_info->allergies[a_cnt].source = uar_get_code_display(a.source_of_info_cd)
   ELSE
    act_info->allergies[a_cnt].source = a.source_of_info_ft
   ENDIF
   IF (pr2.person_id > 0.0)
    act_info->allergies[a_cnt].review_prsnl = pr2.name_full_formatted, act_info->allergies[a_cnt].
    review_dt_tm = a.reviewed_dt_tm
   ENDIF
   CASE (a.onset_precision_flag)
    OF 20:
     act_info->allergies[a_cnt].onset_dt = format(a.onset_dt_tm,"MM/DD/YYYY;;D"),act_info->allergies[
     a_cnt].onset_precision = build2(uar_get_code_display(a.onset_precision_cd)," the day of")
    OF 30:
     act_info->allergies[a_cnt].onset_dt = format(a.onset_dt_tm,"MM/DD/YYYY;;D"),act_info->allergies[
     a_cnt].onset_precision = build2(uar_get_code_display(a.onset_precision_cd)," the week of")
    OF 40:
     act_info->allergies[a_cnt].onset_dt = format(a.onset_dt_tm,"MM/YYYY;;D"),act_info->allergies[
     a_cnt].onset_precision = build2(uar_get_code_display(a.onset_precision_cd)," the month of")
    OF 50:
     act_info->allergies[a_cnt].onset_dt = format(a.onset_dt_tm,"YYYY;;D"),act_info->allergies[a_cnt]
     .onset_precision = build2(uar_get_code_display(a.onset_precision_cd)," the year of")
   ENDCASE
   IF (substring(1,1,act_info->allergies[a_cnt].onset_precision)=" ")
    act_info->allergies[a_cnt].onset_precision = concat(cnvtupper(substring(6,1,act_info->allergies[
       a_cnt].onset_precision)),substring(7,(size(act_info->allergies[a_cnt].onset_precision) - 6),
      act_info->allergies[a_cnt].onset_precision))
   ENDIF
   c_cnt = 0, r_cnt = 0
  HEAD ac.allergy_comment_id
   IF (ac.allergy_comment_id > 0.0)
    c_cnt = (c_cnt+ 1), stat = alterlist(act_info->allergies[a_cnt].comments,c_cnt), act_info->
    allergies[a_cnt].comments[c_cnt].comment = ac.allergy_comment,
    act_info->allergies[a_cnt].comments[c_cnt].comment_dt_tm = ac.comment_dt_tm, act_info->allergies[
    a_cnt].comments[c_cnt].prsnl = pr3.name_full_formatted
   ENDIF
  DETAIL
   IF (c_cnt < 2)
    IF (r.reaction_id > 0.0)
     r_cnt = (r_cnt+ 1), stat = alterlist(act_info->allergies[a_cnt].reactions,r_cnt)
     IF (n2.nomenclature_id > 0.0)
      act_info->allergies[a_cnt].reactions[r_cnt].nomenclature_id = n2.nomenclature_id, act_info->
      allergies[a_cnt].reactions[r_cnt].nomenclature = n2.source_string
     ELSE
      act_info->allergies[a_cnt].reactions[r_cnt].nomenclature = r.reaction_ftdesc
     ENDIF
    ENDIF
   ENDIF
  FOOT  a.allergy_id
   act_info->allergies[a_cnt].comment_cnt = c_cnt, act_info->allergies[a_cnt].reaction_cnt = r_cnt
  FOOT REPORT
   act_info->allergy_cnt = a_cnt
  WITH nocounter
 ;end select
#get_problems
 IF ((ref_info->problem_ind=0))
  GO TO get_med_list
 ENDIF
 SELECT INTO "NL:"
  FROM problem p,
   problem_prsnl_r ppr1,
   problem_prsnl_r ppr2,
   prsnl pr1,
   prsnl pr2,
   nomenclature n,
   problem_comment pc,
   prsnl pr3
  PLAN (p
   WHERE (run_info->person_id=p.person_id)
    AND p.active_ind=1
    AND p.active_status_cd=cd_status
    AND p.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 23:59:59"))
   JOIN (ppr1
   WHERE outerjoin(p.problem_id)=ppr1.problem_id
    AND ppr1.problem_reltn_cd=outerjoin(prblmrlres)
    AND ppr1.active_ind=outerjoin(1)
    AND ppr1.active_status_cd=outerjoin(cd_status)
    AND ppr1.end_effective_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00")))
   JOIN (pr1
   WHERE outerjoin(ppr1.problem_reltn_prsnl_id)=pr1.person_id)
   JOIN (ppr2
   WHERE outerjoin(p.problem_id)=ppr2.problem_id
    AND ppr2.problem_reltn_cd=outerjoin(prblmrlrec)
    AND ppr2.active_ind=outerjoin(1)
    AND ppr2.active_status_cd=outerjoin(cd_status)
    AND ppr2.end_effective_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00")))
   JOIN (pr2
   WHERE outerjoin(ppr2.problem_reltn_prsnl_id)=pr2.person_id)
   JOIN (n
   WHERE outerjoin(p.nomenclature_id)=n.nomenclature_id)
   JOIN (pc
   WHERE outerjoin(p.problem_id)=pc.problem_id
    AND pc.active_ind=outerjoin(1)
    AND pc.active_status_cd=outerjoin(cd_status)
    AND pc.end_effective_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00")))
   JOIN (pr3
   WHERE outerjoin(pc.comment_prsnl_id)=pr3.person_id)
  ORDER BY p.onset_dt_tm, pc.comment_dt_tm
  HEAD REPORT
   p_cnt = 0, c_cnt = 0
  HEAD p.problem_id
   p_cnt = (p_cnt+ 1), stat = alterlist(act_info->problems,p_cnt), act_info->problems[p_cnt].
   problem_id = p.problem_id,
   act_info->problems[p_cnt].problem_instance_id = p.problem_instance_id, act_info->problems[p_cnt].
   life_cycle_status = uar_get_code_display(p.life_cycle_status_cd), act_info->problems[p_cnt].course
    = uar_get_code_display(p.course_cd),
   act_info->problems[p_cnt].responsible_prsnl = pr1.name_full_formatted, act_info->problems[p_cnt].
   recording_prsnl = pr2.name_full_formatted
   IF (n.nomenclature_id > 0.0)
    act_info->problems[p_cnt].nomenclature_id = n.nomenclature_id, act_info->problems[p_cnt].problem
     = n.source_string
   ELSE
    act_info->problems[p_cnt].problem = p.problem_ftdesc
   ENDIF
   CASE (p.onset_dt_flag)
    OF 0:
     act_info->problems[p_cnt].onset_dt = format(p.onset_dt_tm,"MM/DD/YYYY;;D")
    OF 1:
     act_info->problems[p_cnt].onset_dt = format(p.onset_dt_tm,"MM/YYYY;;D")
    OF 2:
     act_info->problems[p_cnt].onset_dt = format(p.onset_dt_tm,"YYYY;;D")
   ENDCASE
   IF (p.onset_dt_cd > 0.0
    AND uar_get_code_meaning(p.onset_dt_cd) != "NOTENTERED")
    act_info->problems[p_cnt].onset_precision = uar_get_code_display(p.onset_dt_cd)
   ENDIF
   c_cnt = 0
  DETAIL
   IF (pc.problem_comment_id > 0.0)
    c_cnt = (c_cnt+ 1), stat = alterlist(act_info->problems[p_cnt].comments,c_cnt), act_info->
    problems[p_cnt].comments[c_cnt].comment = pc.problem_comment,
    act_info->problems[p_cnt].comments[c_cnt].comment_dt_tm = pc.comment_dt_tm, act_info->problems[
    p_cnt].comments[c_cnt].prsnl = pr3.name_full_formatted
   ENDIF
  FOOT  p.problem_id
   act_info->problems[p_cnt].comment_cnt = c_cnt
  FOOT REPORT
   act_info->problem_cnt = p_cnt
  WITH nocounter
 ;end select
#get_med_list
 IF ((ref_info->med_list_ind=0))
  GO TO print_report
 ENDIF
 SELECT INTO "NL:"
  FROM orders o,
   order_action oa,
   prsnl pr1,
   prsnl pr2,
   order_comment oc,
   prsnl pr3,
   long_text lt
  PLAN (o
   WHERE (o.encntr_id=run_info->encntr_id)
    AND o.activity_type_cd=acttyppharm
    AND o.template_order_id=0
    AND o.order_status_cd=ordstsord)
   JOIN (oa
   WHERE o.order_id=oa.order_id
    AND o.last_action_sequence=oa.action_sequence)
   JOIN (pr1
   WHERE outerjoin(oa.order_provider_id)=pr1.person_id)
   JOIN (pr2
   WHERE outerjoin(oa.action_personnel_id)=pr2.person_id)
   JOIN (oc
   WHERE outerjoin(o.order_id)=oc.order_id)
   JOIN (pr3
   WHERE outerjoin(oc.updt_id)=pr3.person_id)
   JOIN (lt
   WHERE outerjoin(oc.long_text_id)=lt.long_text_id)
  ORDER BY o.current_start_dt_tm
  HEAD REPORT
   m_cnt = 0, c_cnt = 0
  HEAD o.order_id
   m_cnt = (m_cnt+ 1), stat = alterlist(act_info->meds,m_cnt), act_info->meds[m_cnt].order_id = o
   .order_id,
   act_info->meds[m_cnt].action_seq = o.last_action_sequence, act_info->meds[m_cnt].
   hna_order_mnemonic = o.hna_order_mnemonic, act_info->meds[m_cnt].ordered_as_mnemonic = o
   .ordered_as_mnemonic,
   act_info->meds[m_cnt].display_line = oa.clinical_display_line, act_info->meds[m_cnt].ordering_phys
    = trim(pr1.name_full_formatted,3), act_info->meds[m_cnt].action_prsnl = trim(pr2
    .name_full_formatted,3),
   act_info->meds[m_cnt].communication_type = uar_get_code_display(oa.communication_type_cd),
   act_info->meds[m_cnt].start_dt_tm = o.current_start_dt_tm
   IF (o.orig_ord_as_flag=0)
    act_info->meds[m_cnt].type_ind = "M"
   ELSEIF (o.orig_ord_as_flag > 0)
    act_info->meds[m_cnt].type_ind = "P"
   ENDIF
   c_cnt = 0
  DETAIL
   IF (lt.long_text_id > 0.0
    AND lt.long_text > " ")
    c_cnt = (c_cnt+ 1), stat = alterlist(act_info->meds[m_cnt].comments,c_cnt), act_info->meds[m_cnt]
    .comments[c_cnt].long_text_id = lt.long_text_id,
    act_info->meds[m_cnt].comments[c_cnt].comment_type = uar_get_code_display(oc.comment_type_cd),
    act_info->meds[m_cnt].comments[c_cnt].prsnl = trim(pr3.name_full_formatted,3), act_info->meds[
    m_cnt].comments[c_cnt].comment_dt_tm = oc.updt_dt_tm,
    act_info->meds[m_cnt].comments[c_cnt].comment = trim(lt.long_text,3)
   ENDIF
  FOOT  o.order_id
   act_info->meds[m_cnt].comment_cnt = c_cnt
  FOOT REPORT
   act_info->med_cnt = m_cnt
  WITH nocounter
 ;end select
#print_report
 DECLARE cell_1_value = vc
 DECLARE cell_2_value = vc
 IF (validate(request->visit[1].encntr_id,0.0) <= 0.0)
  SELECT INTO "BHS_POWERFORM_GENVIEW.RTF"
   FROM dummyt d
   HEAD REPORT
    tab_char = "\tab ", end_line = "\par ", end_para = "\pard ",
    end_page = "\page ", beg_text = "\f0\fs20 ", beg_doc =
    "{\rtf1\deff0{\fonttbl{\f0\fswiss\fprq2\fcharset0 Tahoma;}}{\colortbl;\red204\green204\blue204;}",
    end_doc = "}", beg_bold = "\b ", end_bold = "\b0 ",
    beg_italize = "\i ", end_italize = "\i0 ", beg_underline = "\ul ",
    end_underline = "\ul0 ", beg_tbl_row = "\trowd ", cell_padding = "\trgaph108 ",
    cell_margin = "\trleft", row_shading = "\clcbpat1 ", default_cell_1_size = "\cellx4000 ",
    default_cell_2_size = "\cellx12000 ", cell_1_size = default_cell_1_size, cell_2_size =
    default_cell_2_size,
    beg_tbl_text = "\intbl ", end_cell = "\cell ", end_row = "\row ",
    left_align = "\ql ", right_align = "\qr ", center_align = "\qc ",
    default_align = left_align, cell_1_align = substring(1,4,default_align), cell_2_align = substring
    (1,4,default_align),
    indent_level = 1, base_tbl_margin = 0, tbl_margin_multiplier = 108,
    merge_cell_ind = 0, highlight_row_ind = 0, use_highlight_ind = 1,
    wrote_entry_ind = 0, wrote_grid_ind = 0, tmp_slot_ind = 0,
    wrote_admin_meds_ind = 0, wrote_prescribe_meds_ind = 0, admin_meds_cnt = 0,
    prescribe_meds_cnt = 0, temp_med_cnt = 0,
    MACRO (write_section_head)
     highlight_row_ind = 0
     IF (((wrote_entry_ind=1) OR (wrote_grid_ind=1)) )
      col 0, end_line, " ",
      end_line, " ", row + 1
     ENDIF
     col 0, beg_bold, col + 0,
     beg_underline, col + 0, ref_info->sections[s].section_desc,
     col + 0, end_bold, col + 0,
     end_underline, col + 2, "Last Charted:",
     col + 1, ref_info->sections[s].event_end_dt_tm"MM/DD/YYYY HH:MM;;D", col + 0,
     end_line, row + 1
    ENDMACRO
    ,
    MACRO (write_tbl_row)
     col 0, beg_tbl_row, " ",
     cell_padding, " ", cell_margin,
     " ", col + 0,
     CALL print(build2(((tbl_margin_multiplier * indent_level)+ base_tbl_margin)))
     IF (use_highlight_ind=1)
      IF (highlight_row_ind=0)
       highlight_row_ind = 1
       IF (merge_cell_ind=1)
        col + 0, cell_2_size, end_para,
        " "
       ELSE
        col + 0, cell_1_size, cell_2_size,
        end_para, " "
       ENDIF
      ELSE
       highlight_row_ind = 0
       IF (merge_cell_ind=1)
        col + 0, row_shading, " ",
        cell_2_size, end_para, " "
       ELSE
        col + 0, row_shading, " ",
        cell_1_size, row_shading, " ",
        cell_2_size, end_para, " "
       ENDIF
      ENDIF
     ELSE
      IF (merge_cell_ind=1)
       col + 0, cell_2_size, end_para,
       " "
      ELSE
       col + 0, cell_1_size, cell_2_size,
       end_para, " "
      ENDIF
     ENDIF
     row + 1
     IF (merge_cell_ind=1)
      col 0, beg_tbl_text, " ",
      cell_1_align, cell_1_value, end_cell,
      " ", end_row, " ",
      end_para, " "
     ELSE
      col 0, beg_tbl_text, " ",
      cell_1_align, cell_1_value, end_cell,
      " ", col + 0, cell_2_align,
      cell_2_value, end_cell, " ",
      end_row, " ", end_para,
      " "
     ENDIF
     row + 1, cell_1_value = " ", cell_2_value = " ",
     cell_1_size = default_cell_1_size, cell_2_size = default_cell_2_size, cell_1_align =
     default_align,
     cell_2_align = default_align, merge_cell_ind = 0
    ENDMACRO
    ,
    MACRO (write_ctrl_entry)
     IF (wrote_grid_ind=1)
      wrote_grid_ind = 0, col 0, end_line,
      row + 1
     ENDIF
     wrote_entry_ind = 1, cell_1_value = trim(act_info->ctrls[tmp_slot_ind].ctrl_desc,3),
     cell_2_value = trim(act_info->ctrls[tmp_slot_ind].event_tag,3),
     write_tbl_row
    ENDMACRO
    ,
    MACRO (write_grid_entry)
     highlight_row_ind = 0
     IF (((wrote_entry_ind=1) OR (wrote_grid_ind=1)) )
      col 0, end_line, row + 1
     ENDIF
     wrote_grid_ind = 1, col 2, beg_underline,
     " ", act_info->grids[tmp_slot_ind].grid_desc, end_underline,
     " ", col + 1, end_line,
     " ", row + 1
     IF ((act_info->grids[tmp_slot_ind].grid_type=14))
      indent_level = (indent_level+ 2)
      FOR (r = 1 TO act_info->grids[tmp_slot_ind].row_cnt)
        cell_1_value = trim(act_info->grids[tmp_slot_ind].rows[r].cols[1].col_desc,3), cell_2_value
         = trim(act_info->grids[tmp_slot_ind].rows[r].cols[1].event_tag,3), write_tbl_row
      ENDFOR
      indent_level = (indent_level - 2)
     ELSEIF ((act_info->grids[tmp_slot_ind].grid_type=17))
      FOR (r = 1 TO act_info->grids[tmp_slot_ind].row_cnt)
        col 4, beg_italize, " ",
        CALL print(build2("Row ",format(r,"##"),":")), end_italize, " ",
        col + 1, end_line, " ",
        row + 1, indent_level = (indent_level+ 3)
        FOR (c = 1 TO act_info->grids[tmp_slot_ind].rows[r].col_cnt)
          cell_1_value = trim(act_info->grids[tmp_slot_ind].rows[r].cols[c].col_desc,3), cell_2_value
           = trim(act_info->grids[tmp_slot_ind].rows[r].cols[c].event_tag,3), write_tbl_row
        ENDFOR
        indent_level = (indent_level - 3)
      ENDFOR
      indent_level = (indent_level - 1)
     ELSEIF ((act_info->grids[tmp_slot_ind].grid_type=19))
      FOR (r = 1 TO act_info->grids[tmp_slot_ind].row_cnt)
        col 4, beg_italize, " ",
        act_info->grids[tmp_slot_ind].rows[r].row_desc, end_italize, " ",
        col + 1, end_line, " ",
        row + 1, indent_level = (indent_level+ 3)
        FOR (c = 1 TO act_info->grids[tmp_slot_ind].rows[r].col_cnt)
          cell_1_value = trim(act_info->grids[tmp_slot_ind].rows[r].cols[c].col_desc,3), cell_2_value
           = trim(act_info->grids[tmp_slot_ind].rows[r].cols[c].event_tag,3), write_tbl_row
        ENDFOR
        indent_level = (indent_level - 3)
      ENDFOR
     ENDIF
    ENDMACRO
    ,
    MACRO (write_allergies)
     IF (((wrote_entry_ind=1) OR (wrote_grid_ind=1)) )
      col 0, end_line, " ",
      row + 1
     ENDIF
     wrote_grid_ind = 1
     IF ((act_info->allergy_cnt <= 0))
      col 2, "Allergies: No Allergies Found"
     ELSE
      col 2, beg_underline, " ",
      CALL print(build2("Allergies (Total of ",trim(cnvtstring(act_info->allergy_cnt)),"):")), col +
      0, end_underline,
      " ", end_line, " ",
      row + 1
      FOR (a = 1 TO act_info->allergy_cnt)
        IF (a > 1)
         col 0, end_line, " ",
         row + 1
        ENDIF
        col 4, beg_italize, " ",
        CALL print(build2(trim(cnvtstring(a))," out of ",trim(cnvtstring(act_info->allergy_cnt)),":")
        ), col + 0, end_italize,
        " ", end_line, " ",
        row + 1, indent_level = (indent_level+ 3), cell_1_value = "Substance",
        cell_2_value = trim(act_info->allergies[a].allergy,3), cell_1_size = "\cellx2169",
        write_tbl_row,
        cell_1_value = "Reactions", cell_1_size = "\cellx2169"
        IF ((act_info->allergies[a].reaction_cnt <= 0))
         cell_2_value = "None Recorded"
        ELSE
         FOR (r = 1 TO act_info->allergies[a].reaction_cnt)
           IF (r=1)
            cell_2_value = trim(act_info->allergies[a].reactions[r].nomenclature,3)
           ELSE
            cell_2_value = build2(cell_2_value,", ",trim(act_info->allergies[a].reactions[r].
              nomenclature,3))
           ENDIF
         ENDFOR
        ENDIF
        write_tbl_row, cell_1_value = "Onset Date", cell_1_size = "\cellx2169"
        IF ((act_info->allergies[a].onset_dt <= " "))
         cell_2_value = "None Recorded"
        ELSE
         cell_2_value = trim(act_info->allergies[a].onset_dt,3)
        ENDIF
        write_tbl_row, cell_1_value = "Severity", cell_1_size = "\cellx2169"
        IF ((act_info->allergies[a].severity <= " "))
         cell_2_value = "None Recorded"
        ELSE
         cell_2_value = trim(act_info->allergies[a].severity,3)
        ENDIF
        write_tbl_row, merge_cell_ind = 1, cell_1_align = right_align
        IF ((act_info->allergies[a].review_prsnl > " ")
         AND (act_info->allergies[a].review_dt_tm > 0.0))
         cell_1_value = build2("Reviewed By ",act_info->allergies[a].review_prsnl," on ",format(
           act_info->allergies[a].review_dt_tm,"MM/DD/YYYY HH:MM;;D"))
        ELSEIF ((act_info->allergies[a].review_prsnl > " "))
         cell_1_value = build2("Reviewed By ",act_info->allergies[a].review_prsnl)
        ELSEIF ((act_info->allergies[a].review_dt_tm > 0))
         cell_1_value = build2("Reviewed on ",format(act_info->allergies[a].review_dt_tm,
           "MM/DD/YYYY HH:MM;;D"))
        ELSE
         cell_1_value = "Allergy Not Reviewed"
        ENDIF
        write_tbl_row, indent_level = (indent_level - 3)
      ENDFOR
      col 2, "[ ", beg_underline,
      " ", "End of Allergies", end_underline,
      " ", " ]", end_line,
      " ", row + 1
     ENDIF
    ENDMACRO
    ,
    MACRO (write_problems)
     IF (((wrote_entry_ind=1) OR (wrote_grid_ind=1)) )
      col 0, end_line, " ",
      row + 1
     ENDIF
     wrote_grid_ind = 1
     IF ((act_info->problem_cnt <= 0))
      col 2, "Problems: No Problems Found"
     ELSE
      col 2, beg_underline, " ",
      CALL print(build2("Problems (Total of ",trim(cnvtstring(act_info->problem_cnt)),"):")), col + 0,
      end_underline,
      " ", end_line, " ",
      row + 1
      FOR (p = 1 TO act_info->problem_cnt)
        IF (p > 1)
         col 0, end_line, " ",
         row + 1
        ENDIF
        col 4, beg_italize, " ",
        CALL print(build2(trim(cnvtstring(p))," out of ",trim(cnvtstring(act_info->problem_cnt)),":")
        ), col + 0, end_italize,
        " ", end_line, " ",
        row + 1, indent_level = (indent_level+ 3), cell_1_value = "Description",
        cell_2_value = trim(act_info->problems[p].problem,3), cell_1_size = "\cellx2169",
        write_tbl_row,
        cell_1_value = "Onset Date", cell_2_value = build2(trim(act_info->problems[p].onset_dt,3)," ",
         trim(act_info->problems[p].onset_precision,3)), cell_1_size = "\cellx2169",
        write_tbl_row, cell_1_value = "Course", cell_2_value = trim(act_info->problems[p].course,3),
        cell_1_size = "\cellx2169", write_tbl_row, cell_1_value = "Current Responsible Personnel is ",
        merge_cell_ind = 1
        IF ((act_info->problems[p].responsible_prsnl > " "))
         cell_1_value = build2(cell_1_value,trim(act_info->problems[p].responsible_prsnl,3))
        ELSE
         cell_1_value = build2(cell_1_value,"Unknown")
        ENDIF
        write_tbl_row, indent_level = (indent_level - 3)
      ENDFOR
      col 2, "[ ", beg_underline,
      " ", "End of Problems", end_underline,
      " ", " ]", end_line,
      " ", row + 1
     ENDIF
    ENDMACRO
    ,
    MACRO (write_med_list)
     IF (((wrote_entry_ind=1) OR (wrote_grid_ind=1)) )
      col 0, end_line, " ",
      row + 1
     ENDIF
     wrote_grid_ind = 1
     IF ((act_info->med_cnt <= 0))
      col 2, "Medications: No Medications Found"
     ELSE
      col 2, beg_underline, " ",
      CALL print(build2("Medications (Total of ",trim(cnvtstring(act_info->med_cnt)),"):")), col + 0,
      end_underline,
      " ", end_line, " ",
      row + 1
      FOR (m = 1 TO act_info->med_cnt)
        IF ((act_info->meds[m].type_ind="M"))
         admin_meds_cnt = (admin_meds_cnt+ 1)
        ELSEIF ((act_info->meds[m].type_ind="P"))
         prescribe_meds_cnt = (prescribe_meds_cnt+ 1)
        ENDIF
      ENDFOR
      wrote_admin_meds_ind = 0, wrote_prescribe_meds_ind = 0, indent_level = (indent_level+ 4)
      IF (admin_meds_cnt=0)
       col 4,
       CALL print(build2("Administered:  None Found",end_line," ")), row + 1
      ELSE
       col 4,
       CALL print(build2("Administered (Total of ",trim(cnvtstring(admin_meds_cnt)),"):",end_line," "
        )), row + 1,
       temp_meds_cnt = 0
       FOR (a = 1 TO act_info->med_cnt)
         IF ((act_info->meds[a].type_ind="M"))
          IF (wrote_admin_meds_ind=0)
           wrote_admin_meds_ind = 1
          ELSE
           col 0, end_line, " ",
           row + 1
          ENDIF
          temp_meds_cnt = (temp_meds_cnt+ 1), col 6, beg_italize,
          " ",
          CALL print(build2(trim(cnvtstring(temp_meds_cnt))," out of ",trim(cnvtstring(admin_meds_cnt
             )),":")), col + 0,
          end_italize, " ", end_line,
          " ", row + 1, cell_1_value = trim(act_info->meds[a].ordered_as_mnemonic),
          merge_cell_ind = 1, write_tbl_row, cell_1_value = "Details",
          cell_2_value = trim(act_info->meds[a].display_line), cell_1_size = "\cellx2169",
          write_tbl_row,
          cell_1_value = "Started On", cell_2_value = build2(format(act_info->meds[a].start_dt_tm,
            "MM/DD/YYYY;;D")," ",cnvtupper(format(act_info->meds[a].start_dt_tm,"HH:MM;;S"))),
          cell_1_size = "\cellx2169",
          write_tbl_row, cell_1_value = build2("Medication Placed by ",trim(act_info->meds[a].
            ordering_phys)," (",trim(act_info->meds[a].communication_type)," order)"), merge_cell_ind
           = 1,
          cell_1_align = right_align, write_tbl_row
         ENDIF
       ENDFOR
      ENDIF
      IF (prescribe_meds_cnt=0)
       col 4,
       CALL print(build2("Prescribed:  None Found",end_line," ")), row + 1
      ELSE
       col 4,
       CALL print(build2("Prescribed (Total of ",trim(cnvtstring(prescribe_meds_cnt)),"):",end_line,
        " ")), row + 1,
       temp_meds_cnt = 0
       FOR (p = 1 TO act_info->med_cnt)
         IF ((act_info->meds[p].type_ind="P"))
          IF (wrote_prescribe_meds_ind=0)
           wrote_prescribe_meds_ind = 1
          ELSE
           col 0, end_line, " ",
           row + 1
          ENDIF
          temp_meds_cnt = (temp_meds_cnt+ 1), col 6, beg_italize,
          " ",
          CALL print(build2(trim(cnvtstring(temp_meds_cnt))," out of ",trim(cnvtstring(
             prescribe_meds_cnt)),":")), col + 0,
          end_italize, " ", end_line,
          " ", row + 1, cell_1_value = trim(act_info->meds[p].ordered_as_mnemonic),
          merge_cell_ind = 1, write_tbl_row, cell_1_value = "Details",
          cell_2_value = trim(act_info->meds[p].display_line), cell_1_size = "\cellx2169",
          write_tbl_row,
          cell_1_value = "Started On", cell_2_value = build2(format(act_info->meds[p].start_dt_tm,
            "MM/DD/YYYY;;D")," ",cnvtupper(format(act_info->meds[p].start_dt_tm,"HH:MM;;S"))),
          cell_1_size = "\cellx2169",
          write_tbl_row, cell_1_value = build2("Medication Placed by ",trim(act_info->meds[p].
            ordering_phys)," (",trim(act_info->meds[p].communication_type),")"), merge_cell_ind = 1,
          cell_1_align = right_align, write_tbl_row
         ENDIF
       ENDFOR
      ENDIF
      indent_level = (indent_level - 4), col 2, "[ ",
      beg_underline, " ", "End of Medications",
      end_underline, " ", " ]",
      end_line, " ", row + 1
     ENDIF
    ENDMACRO
    ,
    col 0, beg_doc, " ",
    end_para, " ", beg_text,
    " ", row + 1
   DETAIL
    FOR (s = 1 TO ref_info->section_cnt)
      IF ((ref_info->sections[s].section_data_ind=1))
       write_section_head, wrote_entry_ind = 0, wrote_grid_ind = 0
       FOR (i = 1 TO ref_info->sections[s].input_cnt)
         IF ((ref_info->sections[s].inputs[i].input_data_ind=1))
          IF ((ref_info->sections[s].inputs[i].ctrl_slot_ind > 0))
           tmp_slot_ind = ref_info->sections[s].inputs[i].ctrl_slot_ind, write_ctrl_entry
          ELSEIF ((ref_info->sections[s].inputs[i].grid_slot_ind > 0))
           tmp_slot_ind = ref_info->sections[s].inputs[i].grid_slot_ind, write_grid_entry
          ELSEIF ((ref_info->sections[s].inputs[i].allergy_ind=1))
           use_highlight_ind = 0, write_allergies, use_highlight_ind = 1
          ELSEIF ((ref_info->sections[s].inputs[i].problem_ind=1))
           use_highlight_ind = 0, write_problems, use_highlight_ind = 1
          ELSEIF ((ref_info->sections[s].inputs[i].med_list_ind=1))
           use_highlight_ind = 0, write_med_list, use_highlight_ind = 1
          ENDIF
         ENDIF
       ENDFOR
      ENDIF
    ENDFOR
    row + 1, col 0, end_doc
   WITH nocounter, format = variable, maxrow = 1,
    formfeed = none, maxcol = 32000
  ;end select
 ELSE
  SELECT INTO "NL:"
   FROM dummyt d
   HEAD REPORT
    tab_char = "\tab ", end_line = "\par ", end_para = "\pard ",
    end_page = "\page ", beg_text = "\f0\fs20 ", beg_doc =
    "{\rtf1\deff0{\fonttbl{\f0\fswiss\fprq2\fcharset0 Tahoma;}}{\colortbl ;\red204\green204\blue204;}",
    end_doc = "}", beg_bold = "\b ", end_bold = "\b0 ",
    beg_italize = "\i ", end_italize = "\i0 ", beg_underline = "\ul ",
    end_underline = "\ul0 ", beg_tbl_row = "\trowd ", cell_padding = "\trgaph108 ",
    cell_margin = "\trleft", row_shading = "\clcbpat1 ", default_cell_1_size = "\cellx4000 ",
    default_cell_2_size = "\cellx12000 ", cell_1_size = default_cell_1_size, cell_2_size =
    default_cell_2_size,
    beg_tbl_text = "\intbl ", end_cell = "\cell ", end_row = "\row ",
    left_align = "\ql ", right_align = "\qr ", center_align = "\qc ",
    default_align = left_align, cell_1_align = substring(1,4,default_align), cell_2_align = substring
    (1,4,default_align),
    indent_level = 1, base_tbl_margin = 0, tbl_margin_multiplier = 108,
    merge_cell_ind = 0, highlight_row_ind = 0, use_highlight_ind = 1,
    wrote_entry_ind = 0, wrote_grid_ind = 0, tmp_slot_ind = 0,
    wrote_admin_meds_ind = 0, wrote_prescribe_meds_ind = 0, admin_meds_cnt = 0,
    prescribe_meds_cnt = 0, temp_med_cnt = 0,
    MACRO (write_section_head)
     highlight_row_ind = 0
     IF (((wrote_entry_ind=1) OR (wrote_grid_ind=1)) )
      reply->text = build2(reply->text,end_line,end_line)
     ENDIF
     reply->text = build2(reply->text,"  ",beg_bold), reply->text = build2(reply->text,beg_underline),
     reply->text = build2(reply->text," ",ref_info->sections[s].section_desc),
     reply->text = build2(reply->text,end_bold), reply->text = build2(reply->text,end_underline),
     reply->text = build2(reply->text,"    ","Last Charted:"," ",format(ref_info->sections[s].
       event_end_dt_tm,"MM/DD/YYYY HH:MM;;D")),
     reply->text = build2(reply->text,end_line)
    ENDMACRO
    ,
    MACRO (write_tbl_row)
     reply->text = build(reply->text,beg_tbl_row,cell_padding,cell_margin), reply->text = build(reply
      ->text,((tbl_margin_multiplier * indent_level)+ base_tbl_margin))
     IF (use_highlight_ind=1)
      IF (highlight_row_ind=0)
       highlight_row_ind = 1
       IF (merge_cell_ind=1)
        reply->text = build2(reply->text,cell_2_size,end_para)
       ELSE
        reply->text = build2(reply->text,cell_1_size,cell_2_size,end_para)
       ENDIF
      ELSE
       highlight_row_ind = 0
       IF (merge_cell_ind=1)
        reply->text = build2(reply->text,row_shading,cell_2_size,end_para)
       ELSE
        reply->text = build2(reply->text,row_shading,cell_1_size,row_shading,cell_2_size,
         end_para)
       ENDIF
      ENDIF
     ELSE
      IF (merge_cell_ind=1)
       reply->text = build2(reply->text,cell_2_size,end_para)
      ELSE
       reply->text = build2(reply->text,cell_1_size,cell_2_size,end_para)
      ENDIF
     ENDIF
     IF (merge_cell_ind=1)
      reply->text = build2(reply->text,beg_tbl_text," ",cell_1_align,cell_1_value,
       end_cell,end_row,end_para)
     ELSE
      reply->text = build2(reply->text,beg_tbl_text," ",cell_1_align,cell_1_value,
       end_cell), reply->text = build2(reply->text,cell_2_align,cell_2_value,end_cell,end_row,
       end_para)
     ENDIF
     cell_1_value = " ", cell_2_value = " ", cell_1_size = default_cell_1_size,
     cell_2_size = default_cell_2_size, cell_1_align = default_align, cell_2_align = default_align,
     merge_cell_ind = 0
    ENDMACRO
    ,
    MACRO (write_ctrl_entry)
     IF (wrote_grid_ind=1)
      wrote_grid_ind = 0, reply->text = build2(reply->text,end_line," ")
     ENDIF
     wrote_entry_ind = 1, cell_1_value = trim(act_info->ctrls[tmp_slot_ind].ctrl_desc,3),
     cell_2_value = trim(act_info->ctrls[tmp_slot_ind].event_tag,3),
     write_tbl_row
    ENDMACRO
    ,
    MACRO (write_grid_entry)
     highlight_row_ind = 0
     IF (((wrote_entry_ind=1) OR (wrote_grid_ind=1)) )
      reply->text = build2(reply->text,end_line," ")
     ENDIF
     wrote_grid_ind = 1, reply->text = build2(reply->text,beg_underline," ",act_info->grids[
      tmp_slot_ind].grid_desc,end_underline,
      " ",end_line," ")
     IF ((act_info->grids[tmp_slot_ind].grid_type=14))
      indent_level = (indent_level+ 2)
      FOR (r = 1 TO act_info->grids[tmp_slot_ind].row_cnt)
        cell_1_value = trim(act_info->grids[tmp_slot_ind].rows[r].cols[1].col_desc,3), cell_2_value
         = trim(act_info->grids[tmp_slot_ind].rows[r].cols[1].event_tag,3), write_tbl_row
      ENDFOR
      indent_level = (indent_level - 2)
     ELSEIF ((act_info->grids[tmp_slot_ind].grid_type=17))
      FOR (r = 1 TO act_info->grids[tmp_slot_ind].row_cnt)
        reply->text = build2(reply->text,beg_italize," ","Row ",trim(cnvtstring(r),3),
         ":",end_italize," ",end_line," "), indent_level = (indent_level+ 3)
        FOR (c = 1 TO act_info->grids[tmp_slot_ind].rows[r].col_cnt)
          cell_1_value = trim(act_info->grids[tmp_slot_ind].rows[r].cols[c].col_desc,3), cell_2_value
           = trim(act_info->grids[tmp_slot_ind].rows[r].cols[c].event_tag,3), write_tbl_row
        ENDFOR
        indent_level = (indent_level - 3)
      ENDFOR
      indent_level = (indent_level - 1)
     ELSEIF ((act_info->grids[tmp_slot_ind].grid_type=19))
      FOR (r = 1 TO act_info->grids[tmp_slot_ind].row_cnt)
        reply->text = build2(reply->text,beg_italize," ",act_info->grids[tmp_slot_ind].rows[r].
         row_desc,end_italize,
         " ",end_line," "), indent_level = (indent_level+ 3)
        FOR (c = 1 TO act_info->grids[tmp_slot_ind].rows[r].col_cnt)
          cell_1_value = trim(act_info->grids[tmp_slot_ind].rows[r].cols[c].col_desc,3), cell_2_value
           = trim(act_info->grids[tmp_slot_ind].rows[r].cols[c].event_tag,3), write_tbl_row
        ENDFOR
        indent_level = (indent_level - 3)
      ENDFOR
     ENDIF
    ENDMACRO
    ,
    MACRO (write_allergies)
     IF (((wrote_entry_ind=1) OR (wrote_grid_ind=1)) )
      reply->text = build2(reply->text,end_line," ")
     ENDIF
     wrote_grid_ind = 1
     IF ((act_info->allergy_cnt <= 0))
      reply->text = build2(reply->text,"Allergies: No Allergies Found")
     ELSE
      reply->text = build2(reply->text,beg_underline," "), reply->text = build2(reply->text,
       "Allergies (Total of ",trim(cnvtstring(act_info->allergy_cnt)),"):"), reply->text = build2(
       reply->text,end_underline," ",end_line," ")
      FOR (a = 1 TO act_info->allergy_cnt)
        IF (a > 1)
         reply->text = build2(reply->text,end_line," ")
        ENDIF
        reply->text = build2(reply->text,beg_italize," "), reply->text = build2(reply->text,trim(
          cnvtstring(a))," out of ",trim(cnvtstring(act_info->allergy_cnt)),":"), reply->text =
        build2(reply->text,end_italize," ",end_line," "),
        indent_level = (indent_level+ 3), cell_1_value = "Substance", cell_2_value = trim(act_info->
         allergies[a].allergy,3),
        cell_1_size = "\cellx2169", write_tbl_row, cell_1_value = "Reactions",
        cell_1_size = "\cellx2169"
        IF ((act_info->allergies[a].reaction_cnt <= 0))
         cell_2_value = "None Recorded"
        ELSE
         FOR (r = 1 TO act_info->allergies[a].reaction_cnt)
           IF (r=1)
            cell_2_value = trim(act_info->allergies[a].reactions[r].nomenclature,3)
           ELSE
            cell_2_value = build2(cell_2_value,", ",trim(act_info->allergies[a].reactions[r].
              nomenclature,3))
           ENDIF
         ENDFOR
        ENDIF
        write_tbl_row, cell_1_value = "Onset Date", cell_1_size = "\cellx2169"
        IF ((act_info->allergies[a].onset_dt <= " "))
         cell_2_value = "None Recorded"
        ELSE
         cell_2_value = trim(act_info->allergies[a].onset_dt,3)
        ENDIF
        write_tbl_row, cell_1_value = "Severity", cell_1_size = "\cellx2169"
        IF ((act_info->allergies[a].severity <= " "))
         cell_2_value = "None Recorded"
        ELSE
         cell_2_value = trim(act_info->allergies[a].severity,3)
        ENDIF
        write_tbl_row, merge_cell_ind = 1, cell_1_align = right_align
        IF ((act_info->allergies[a].review_prsnl > " ")
         AND (act_info->allergies[a].review_dt_tm > 0.0))
         cell_1_value = build2("Reviewed By ",act_info->allergies[a].review_prsnl," on ",format(
           act_info->allergies[a].review_dt_tm,"MM/DD/YYYY HH:MM;;D"))
        ELSEIF ((act_info->allergies[a].review_prsnl > " "))
         cell_1_value = build2("Reviewed By ",act_info->allergies[a].review_prsnl)
        ELSEIF ((act_info->allergies[a].review_dt_tm > 0))
         cell_1_value = build2("Reviewed on ",format(act_info->allergies[a].review_dt_tm,
           "MM/DD/YYYY HH:MM;;D"))
        ELSE
         cell_1_value = "Allergy Not Reviewed"
        ENDIF
        write_tbl_row, indent_level = (indent_level - 3)
      ENDFOR
      reply->text = build2(reply->text,"[ ",beg_underline," ","End of Allergies",
       end_underline," "," ]",end_line," ")
     ENDIF
    ENDMACRO
    ,
    MACRO (write_problems)
     IF (((wrote_entry_ind=1) OR (wrote_grid_ind=1)) )
      reply->text = build2(reply->text,end_line," ")
     ENDIF
     wrote_grid_ind = 1
     IF ((act_info->problem_cnt <= 0))
      reply->text = build2(reply->text,"Problems: No Problems Found")
     ELSE
      reply->text = build2(reply->text,beg_underline," "), reply->text = build2(reply->text,
       "Problems (Total of ",trim(cnvtstring(act_info->problem_cnt)),"):"), reply->text = build2(
       reply->text,end_underline," ",end_line," ")
      FOR (p = 1 TO act_info->problem_cnt)
        IF (p > 1)
         reply->text = build2(reply->text,end_line," ")
        ENDIF
        reply->text = build2(reply->text,beg_italize," "), reply->text = build2(reply->text,trim(
          cnvtstring(p))," out of ",trim(cnvtstring(act_info->problem_cnt)),":"), reply->text =
        build2(reply->text,end_italize," ",end_line," "),
        indent_level = (indent_level+ 3), cell_1_value = "Description", cell_2_value = trim(act_info
         ->problems[p].problem,3),
        cell_1_size = "\cellx2169", write_tbl_row, cell_1_value = "Onset Date",
        cell_2_value = build2(trim(act_info->problems[p].onset_dt,3)," ",trim(act_info->problems[p].
          onset_precision,3)), cell_1_size = "\cellx2169", write_tbl_row,
        cell_1_value = "Course", cell_2_value = trim(act_info->problems[p].course,3), cell_1_size =
        "\cellx2169",
        write_tbl_row, cell_1_value = "Current Responsible Personnel is ", merge_cell_ind = 1
        IF ((act_info->problems[p].responsible_prsnl > " "))
         cell_1_value = build2(cell_1_value,trim(act_info->problems[p].responsible_prsnl,3))
        ELSE
         cell_1_value = build2(cell_1_value,"Unknown")
        ENDIF
        write_tbl_row, indent_level = (indent_level - 3)
      ENDFOR
      reply->text = build2(reply->text,"[ ",beg_underline," ","End of Problems",
       end_underline," "," ]",end_line," ")
     ENDIF
    ENDMACRO
    ,
    MACRO (write_med_list)
     IF (((wrote_entry_ind=1) OR (wrote_grid_ind=1)) )
      reply->text = build2(reply->text,end_line," ")
     ENDIF
     wrote_grid_ind = 1
     IF ((act_info->med_cnt <= 0))
      reply->text = build2(reply->text,"Medications: No Medications Found")
     ELSE
      reply->text = build2(reply->text,beg_underline," "), reply->text = build2(reply->text,
       "Medications (Total of ",trim(cnvtstring(act_info->med_cnt)),"):"), reply->text = build2(reply
       ->text,end_underline," ",end_line," ")
      FOR (m = 1 TO act_info->med_cnt)
        IF ((act_info->meds[m].type_ind="M"))
         admin_meds_cnt = (admin_meds_cnt+ 1)
        ELSEIF ((act_info->meds[m].type_ind="P"))
         prescribe_meds_cnt = (prescribe_meds_cnt+ 1)
        ENDIF
      ENDFOR
      wrote_admin_meds_ind = 0, wrote_prescribe_meds_ind = 0, indent_level = (indent_level+ 4)
      IF (admin_meds_cnt=0)
       reply->text = build2(reply->text,"Administered:  None Found",end_line," ")
      ELSE
       reply->text = build2(reply->text,"Administered (Total of ",trim(cnvtstring(admin_meds_cnt)),
        "):",end_line,
        " "), temp_meds_cnt = 0
       FOR (a = 1 TO act_info->med_cnt)
         IF ((act_info->meds[a].type_ind="M"))
          IF (wrote_admin_meds_ind=0)
           wrote_admin_meds_ind = 1
          ELSE
           reply->text = build2(reply->text,end_line," ")
          ENDIF
          temp_meds_cnt = (temp_meds_cnt+ 1), reply->text = build2(reply->text,beg_italize," "),
          reply->text = build2(reply->text,trim(cnvtstring(temp_meds_cnt))," out of ",trim(cnvtstring
            (admin_meds_cnt)),":"),
          reply->text = build2(reply->text,end_italize," ",end_line," "), cell_1_value = trim(
           act_info->meds[a].ordered_as_mnemonic), merge_cell_ind = 1,
          write_tbl_row, cell_1_value = "Details", cell_2_value = trim(act_info->meds[a].display_line
           ),
          cell_1_size = "\cellx2169", write_tbl_row, cell_1_value = "Started On",
          cell_2_value = build2(format(act_info->meds[a].start_dt_tm,"MM/DD/YYYY;;D")," ",cnvtupper(
            format(act_info->meds[a].start_dt_tm,"HH:MM;;S"))), cell_1_size = "\cellx2169",
          write_tbl_row,
          cell_1_value = build2("Medication Placed by ",trim(act_info->meds[a].ordering_phys)," (",
           trim(act_info->meds[a].communication_type)," order)"), merge_cell_ind = 1, cell_1_align =
          right_align,
          write_tbl_row
         ENDIF
       ENDFOR
      ENDIF
      IF (prescribe_meds_cnt=0)
       reply->text = build2(reply->text,"Prescribed:  None Found",end_line," ")
      ELSE
       reply->text = build2(reply->text,"Prescribed (Total of ",trim(cnvtstring(prescribe_meds_cnt)),
        "):",end_line,
        " "), temp_meds_cnt = 0
       FOR (p = 1 TO act_info->med_cnt)
         IF ((act_info->meds[p].type_ind="P"))
          IF (wrote_prescribe_meds_ind=0)
           wrote_prescribe_meds_ind = 1
          ELSE
           reply->text = build2(reply->text,end_line," ")
          ENDIF
          temp_meds_cnt = (temp_meds_cnt+ 1), reply->text = build2(reply->text,beg_italize," "),
          reply->text = build2(reply->text,trim(cnvtstring(temp_meds_cnt))," out of ",trim(cnvtstring
            (prescribe_meds_cnt)),":"),
          reply->text = build2(reply->text,end_italize," ",end_line," "), cell_1_value = trim(
           act_info->meds[p].ordered_as_mnemonic), merge_cell_ind = 1,
          write_tbl_row, cell_1_value = "Details", cell_2_value = trim(act_info->meds[p].display_line
           ),
          cell_1_size = "\cellx2169", write_tbl_row, cell_1_value = "Started On",
          cell_2_value = build2(format(act_info->meds[p].start_dt_tm,"MM/DD/YYYY;;D")," ",cnvtupper(
            format(act_info->meds[p].start_dt_tm,"HH:MM;;S"))), cell_1_size = "\cellx2169",
          write_tbl_row,
          cell_1_value = build2("Medication Placed by ",trim(act_info->meds[p].ordering_phys)," (",
           trim(act_info->meds[p].communication_type),")"), merge_cell_ind = 1, cell_1_align =
          right_align,
          write_tbl_row
         ENDIF
       ENDFOR
      ENDIF
      indent_level = (indent_level - 4), reply->text = build2(reply->text,"[ ",beg_underline," ",
       "End of Medications",
       end_underline," "," ]",end_line," ")
     ENDIF
    ENDMACRO
    ,
    reply->text = build2(reply->text,beg_doc," ",end_para," ",
     beg_text," ",end_line,char(10),char(13))
   DETAIL
    FOR (s = 1 TO ref_info->section_cnt)
      IF ((ref_info->sections[s].section_data_ind=1))
       write_section_head, wrote_entry_ind = 0, wrote_grid_ind = 0
       FOR (i = 1 TO ref_info->sections[s].input_cnt)
         IF ((ref_info->sections[s].inputs[i].input_data_ind=1))
          IF ((ref_info->sections[s].inputs[i].ctrl_slot_ind > 0))
           tmp_slot_ind = ref_info->sections[s].inputs[i].ctrl_slot_ind, write_ctrl_entry
          ELSEIF ((ref_info->sections[s].inputs[i].grid_slot_ind > 0))
           tmp_slot_ind = ref_info->sections[s].inputs[i].grid_slot_ind, write_grid_entry
          ELSEIF ((ref_info->sections[s].inputs[i].allergy_ind=1))
           use_highlight_ind = 0, write_allergies, use_highlight_ind = 1
          ELSEIF ((ref_info->sections[s].inputs[i].problem_ind=1))
           use_highlight_ind = 0, write_problems, use_highlight_ind = 1
          ELSEIF ((ref_info->sections[s].inputs[i].med_list_ind=1))
           use_highlight_ind = 0, write_med_list, use_highlight_ind = 1
          ENDIF
         ENDIF
       ENDFOR
      ENDIF
    ENDFOR
    reply->text = build2(reply->text,end_doc)
   WITH nocounter, format = variable, maxrow = 1,
    formfeed = none, maxcol = 32000
  ;end select
 ENDIF
 CALL echorecord(ref_info,"BHS_POWERFORM_GENVIEW_REF_RS.DAT")
 CALL echorecord(act_info,"BHS_POWERFORM_GENVIEW_ACT_RS.DAT")
END GO
