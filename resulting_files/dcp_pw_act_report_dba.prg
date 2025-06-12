CREATE PROGRAM dcp_pw_act_report:dba
 SET reply->status_data.status = "F"
 SET cur_cc = fillstring(100," ")
 SET cur_tf = fillstring(100," ")
 SET line_ctr = 1
 SET char_ctr = 0
 SET start_pos = 0
 SET end_pos = 0
 SET numchars = 0
 SET index = 56
 SET found_ind = 0
 SET m = 1
 SET act_line = fillstring(20," ")
 SET cond_line = fillstring(50," ")
 SET cond_line1 = fillstring(35," ")
 SET ord_line1 = fillstring(27," ")
 SET ord_line = fillstring(30," ")
 SET eo_name1 = fillstring(27," ")
 SET eo_name = fillstring(30," ")
 SET eo_line = fillstring(30," ")
 SET location = fillstring(20," ")
 SET room = fillstring(20," ")
 SET bed = fillstring(20," ")
 SET service = fillstring(40," ")
 SET admit_doc = fillstring(30," ")
 SET attend_doc = fillstring(30," ")
 SET mrn = fillstring(20," ")
 SET pat_name = fillstring(30," ")
 SET age = fillstring(20," ")
 SET sex = fillstring(10," ")
 SET visit = fillstring(3," ")
 SET adm_date = fillstring(20," ")
 SET ind1 = 0
 SET ind2 = 0
 SET footer = fillstring(10," ")
 SET encounter_id = 0.0
 SET formnum = 2
 SET cur_date = cnvtdatetime(curdate,curtime)
 SET u_line = fillstring(92," ")
 SET page_cnt = 0
 SET cur_y = 0
 SET test_y = 0
 SET sort_flag = "T"
 SET comp_flag = "Y"
 SET det_flag = "Y"
 RECORD temp(
   1 encntr_id = f8
   1 count = i4
   1 qual_pw[*]
     2 pathway_id = f8
     2 pw_desc = vc
     2 pw_start_dt_tm = vc
     2 pw_init_by_name = vc
     2 pw_end_dt_tm = vc
     2 pw_disc_by_name = vc
     2 pw_status = vc
     2 acc_cnt = i4
     2 qual_acc[*]
       3 act_cc_id = f8
       3 act_cc_desc = vc
       3 act_cc_seq = i4
       3 list_cnt = i4
       3 list[*]
         4 item = i4
     2 tf_cnt = i4
     2 qual_tf[*]
       3 act_tf_id = f8
       3 act_tf_desc = vc
       3 act_tf_seq = i4
       3 list_cnt = i4
       3 list[*]
         4 item = i4
     2 comp_cnt = i4
     2 qual_comp[*]
       3 comp_seq = i4
       3 comp_type_cd = f8
       3 parent_entity_name = vc
       3 parent_entity_id = f8
       3 pw_comp_id = f8
       3 comp_note_desc = vc
       3 comp_create_desc = vc
       3 comp_results_desc = vc
       3 outcome_operator = vc
       3 result_value = vc
       3 result_units = vc
       3 comp_label_desc = vc
       3 activated_dt_tm = vc
       3 table_used = c2
       3 check = c2
       3 comp_active_ind = i2
       3 act_pw_comp_id = f8
       3 os_display_line = vc
       3 os_id = f8
       3 act_os_display = vc
       3 act_os_id = f8
       3 cond_ind = i2
       3 cond_desc = vc
       3 cond_eval_ind = i2
       3 cond_eval_result_ind = i2
       3 included_ind = i2
       3 required_ind = i2
 )
 RECORD notes(
   1 display = vc
   1 length = i2
 )
 RECORD labels(
   1 display = vc
   1 length = i2
 )
 RECORD os(
   1 display[255] = c1
 )
 RECORD temp1(
   1 display[35] = c1
 )
 RECORD printed(
   1 qual_lines[6]
     2 display[35] = c1
 )
 SET code_set = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET note_meaning = "NOTE"
 SET order_create_meaning = "ORDER CREATE"
 SET label_meaning = "LABEL"
 SET outcome_create_meaning = "OUTCOME CREA"
 SET task_create_meaning = "TASK CREATE"
 SET result_outcome_meaning = "RESULT OUTCO"
 SET code_set = 4
 SET cdf_meaning = "MRN"
 EXECUTE cpm_get_cd_for_cdf
 SET mrn_alias_cd = code_value
 SET code_set = 16789
 SET cdf_meaning = "ACTIVATED"
 EXECUTE cpm_get_cd_for_cdf
 SET tf_act_status_cd = code_value
 SET code_set = 16769
 SET cdf_meaning = "STARTED"
 EXECUTE cpm_get_cd_for_cdf
 SET pw_start_status_cd = code_value
 SET code_set = 16769
 SET cdf_meaning = "COMPLETED"
 EXECUTE cpm_get_cd_for_cdf
 SET pw_comp_status_cd = code_value
 SET code_set = 16769
 SET cdf_meaning = "DISCONTINUED"
 EXECUTE cpm_get_cd_for_cdf
 SET pw_disc_status_cd = code_value
 SET code_set = 16769
 SET cdf_meaning = "ORDERED"
 EXECUTE cpm_get_cd_for_cdf
 SET pw_ord_status_cd = code_value
 SET code_set = 333
 SET cdf_meaning = "ADMITDOC"
 EXECUTE cpm_get_cd_for_cdf
 SET admit_doc_cd = code_value
 SET code_set = 333
 SET cdf_meaning = "ATTENDDOC"
 EXECUTE cpm_get_cd_for_cdf
 SET attend_doc_cd = code_value
 SET code_set = 16750
 SET cdf_meaning = note_meaning
 EXECUTE cpm_get_cd_for_cdf
 SET note_type_cd = code_value
 SET code_set = 16750
 SET cdf_meaning = order_create_meaning
 EXECUTE cpm_get_cd_for_cdf
 SET order_create_type_cd = code_value
 SET code_set = 16750
 SET cdf_meaning = label_meaning
 EXECUTE cpm_get_cd_for_cdf
 SET label_type_cd = code_value
 SET code_set = 16750
 SET cdf_meaning = outcome_create_meaning
 EXECUTE cpm_get_cd_for_cdf
 SET outcome_create_type_cd = code_value
 SET code_set = 16750
 SET cdf_meaning = task_create_meaning
 EXECUTE cpm_get_cd_for_cdf
 SET task_create_type_cd = code_value
 SET code_set = 16750
 SET cdf_meaning = result_outcome_meaning
 EXECUTE cpm_get_cd_for_cdf
 SET result_outcome_type_cd = code_value
 SELECT INTO "nl:"
  pw.pathway_id, pw.description, pw.start_dt_tm,
  pw.actual_end_dt_tm, pw_status = uar_get_code_display(pw.pw_status_cd), pwa.pw_status_cd,
  pwa.pw_action_seq, name = trim(pr.name_full_formatted)
  FROM pathway pw,
   pathway_action pwa,
   prsnl pr,
   (dummyt d  WITH seq = value(request->pw_cnt)),
   (dummyt d1  WITH seq = 1)
  PLAN (d)
   JOIN (pw
   WHERE (pw.pathway_id=request->qual_pw[d.seq].pathway_id))
   JOIN (d1)
   JOIN (pwa
   WHERE pw.pathway_id=pwa.pathway_id)
   JOIN (pr
   WHERE pwa.action_prsnl_id=pr.person_id)
  ORDER BY pw.pathway_id, pwa.pw_status_cd DESC, pwa.pw_action_seq
  HEAD REPORT
   temp->count = 0
  HEAD pw.pathway_id
   temp->count = (temp->count+ 1), stat = alterlist(temp->qual_pw,temp->count), temp->qual_pw[temp->
   count].pathway_id = pw.pathway_id,
   temp->qual_pw[temp->count].pw_desc = pw.description, temp->qual_pw[temp->count].pw_status =
   pw_status
   IF ( NOT (pw.pw_status_cd=pw_disc_status_cd)
    AND  NOT (pw.pw_status_cd=pw_comp_status_cd))
    temp->qual_pw[temp->count].pw_end_dt_tm = " "
   ELSE
    temp->qual_pw[temp->count].pw_end_dt_tm = concat(trim(format(pw.actual_end_dt_tm,"@SHORTDATE")),
     " ",trim(format(pw.actual_end_dt_tm,"@TIMENOSECONDS")))
   ENDIF
  HEAD pwa.pw_status_cd
   IF (pwa.pw_status_cd=pw_start_status_cd)
    temp->qual_pw[temp->count].pw_start_dt_tm = concat(trim(format(pwa.action_dt_tm,"@SHORTDATE")),
     " ",trim(format(pwa.action_dt_tm,"@TIMENOSECONDS"))), temp->qual_pw[temp->count].pw_init_by_name
     = name
   ELSEIF (((pwa.pw_status_cd=pw_disc_status_cd) OR (pwa.pw_status_cd=pw_comp_status_cd)) )
    temp->qual_pw[temp->count].pw_disc_by_name = name
   ENDIF
  WITH nocounter, outerjoin = d1
 ;end select
 SELECT
  IF (sort_flag="C")
   ORDER BY apc.pathway_id, act_cc_seq, act_tf_seq,
    comp_seq
   HEAD REPORT
    pw_cnt = 0, temp->encntr_id = encntr_id
   HEAD apc.pathway_id
    pw_cnt = (pw_cnt+ 1), acc_cnt = 0, tf_cnt = 0,
    comp_cnt = 0, stat = alterlist(temp->qual_pw,pw_cnt)
   HEAD act_cc_seq
    acc_cnt = (acc_cnt+ 1), stat = alterlist(temp->qual_pw[pw_cnt].qual_acc,acc_cnt), temp->qual_pw[
    pw_cnt].qual_acc[acc_cnt].act_cc_id = act_cc_id,
    temp->qual_pw[pw_cnt].qual_acc[acc_cnt].act_cc_desc = act_cc_desc, temp->qual_pw[pw_cnt].
    qual_acc[acc_cnt].act_cc_seq = act_cc_seq, acc_list_cnt = 0
   HEAD act_tf_seq
    tf_cnt = (tf_cnt+ 1), stat = alterlist(temp->qual_pw[pw_cnt].qual_tf,tf_cnt), acc_list_cnt = (
    acc_list_cnt+ 1),
    stat = alterlist(temp->qual_pw[pw_cnt].qual_acc[acc_cnt].list,acc_list_cnt), temp->qual_pw[pw_cnt
    ].qual_acc[acc_cnt].list[acc_list_cnt].item = tf_cnt, temp->qual_pw[pw_cnt].qual_tf[tf_cnt].
    act_tf_id = act_tf_id,
    temp->qual_pw[pw_cnt].qual_tf[tf_cnt].act_tf_desc = act_tf_desc, temp->qual_pw[pw_cnt].qual_tf[
    tf_cnt].act_tf_seq = act_tf_seq, tf_list_cnt = 0
   HEAD comp_seq
    comp_cnt = (comp_cnt+ 1), stat = alterlist(temp->qual_pw[pw_cnt].qual_comp,comp_cnt), tf_list_cnt
     = (tf_list_cnt+ 1),
    stat = alterlist(temp->qual_pw[pw_cnt].qual_tf[tf_cnt].list,tf_list_cnt), temp->qual_pw[pw_cnt].
    qual_tf[tf_cnt].list[tf_list_cnt].item = comp_cnt, temp->qual_pw[pw_cnt].qual_comp[comp_cnt].
    comp_seq = comp_seq,
    temp->qual_pw[pw_cnt].qual_comp[comp_cnt].comp_type_cd = comp_type_cd, temp->qual_pw[pw_cnt].
    qual_comp[comp_cnt].parent_entity_name = parent_entity_name, temp->qual_pw[pw_cnt].qual_comp[
    comp_cnt].parent_entity_id = parent_entity_id,
    temp->qual_pw[pw_cnt].qual_comp[comp_cnt].pw_comp_id = pw_comp_id, temp->qual_pw[pw_cnt].
    qual_comp[comp_cnt].comp_note_desc = comp_note_desc, temp->qual_pw[pw_cnt].qual_comp[comp_cnt].
    comp_create_desc = comp_create_desc,
    temp->qual_pw[pw_cnt].qual_comp[comp_cnt].comp_results_desc = comp_results_desc, temp->qual_pw[
    pw_cnt].qual_comp[comp_cnt].outcome_operator = outcome_operator, temp->qual_pw[pw_cnt].qual_comp[
    comp_cnt].result_value = result_value,
    temp->qual_pw[pw_cnt].qual_comp[comp_cnt].result_units = result_units, temp->qual_pw[pw_cnt].
    qual_comp[comp_cnt].comp_label_desc = comp_label_desc, temp->qual_pw[pw_cnt].qual_comp[comp_cnt].
    activated_dt_tm = activated_dt_tm,
    temp->qual_pw[pw_cnt].qual_comp[comp_cnt].table_used = table_used, temp->qual_pw[pw_cnt].
    qual_comp[comp_cnt].check = check, temp->qual_pw[pw_cnt].qual_comp[comp_cnt].comp_active_ind =
    comp_active_ind,
    temp->qual_pw[pw_cnt].qual_comp[comp_cnt].act_pw_comp_id = act_pw_comp_id, temp->qual_pw[pw_cnt].
    qual_comp[comp_cnt].os_display_line = os_display_line, temp->qual_pw[pw_cnt].qual_comp[comp_cnt].
    os_id = os_id,
    temp->qual_pw[pw_cnt].qual_comp[comp_cnt].act_os_display = act_os_display, temp->qual_pw[pw_cnt].
    qual_comp[comp_cnt].act_os_id = act_os_id, temp->qual_pw[pw_cnt].qual_comp[comp_cnt].cond_ind =
    cond_ind,
    temp->qual_pw[pw_cnt].qual_comp[comp_cnt].cond_desc = cond_desc, temp->qual_pw[pw_cnt].qual_comp[
    comp_cnt].cond_eval_ind = cond_eval_ind, temp->qual_pw[pw_cnt].qual_comp[comp_cnt].
    cond_eval_result_ind = cond_eval_result_ind,
    temp->qual_pw[pw_cnt].qual_comp[comp_cnt].included_ind = included_ind, temp->qual_pw[pw_cnt].
    qual_comp[comp_cnt].required_ind = required_ind
   FOOT  act_tf_seq
    temp->qual_pw[pw_cnt].qual_tf[tf_cnt].list_cnt = tf_list_cnt
   FOOT  act_cc_seq
    temp->qual_pw[pw_cnt].qual_acc[acc_cnt].list_cnt = acc_list_cnt
   FOOT  apc.pathway_id
    temp->qual_pw[pw_cnt].acc_cnt = acc_cnt, temp->qual_pw[pw_cnt].tf_cnt = tf_cnt, temp->qual_pw[
    pw_cnt].comp_cnt = comp_cnt
   FOOT REPORT
    temp->count = pw_cnt
  ELSEIF (sort_flag="T")
   ORDER BY apc.pathway_id, act_tf_seq, act_cc_seq,
    comp_seq
   HEAD REPORT
    pw_cnt = 0, temp->encntr_id = encntr_id
   HEAD apc.pathway_id
    pw_cnt = (pw_cnt+ 1), tf_cnt = 0, acc_cnt = 0,
    comp_cnt = 0, stat = alterlist(temp->qual_pw,pw_cnt)
   HEAD act_tf_seq
    tf_cnt = (tf_cnt+ 1), stat = alterlist(temp->qual_pw[pw_cnt].qual_tf,tf_cnt), temp->qual_pw[
    pw_cnt].qual_tf[tf_cnt].act_tf_id = act_tf_id,
    temp->qual_pw[pw_cnt].qual_tf[tf_cnt].act_tf_desc = act_tf_desc, temp->qual_pw[pw_cnt].qual_tf[
    tf_cnt].act_tf_seq = act_tf_seq, tf_list_cnt = 0
   HEAD act_cc_seq
    acc_cnt = (acc_cnt+ 1), stat = alterlist(temp->qual_pw[pw_cnt].qual_acc,acc_cnt), tf_list_cnt = (
    tf_list_cnt+ 1),
    stat = alterlist(temp->qual_pw[pw_cnt].qual_tf[tf_cnt].list,tf_list_cnt), temp->qual_pw[pw_cnt].
    qual_tf[tf_cnt].list[tf_list_cnt].item = acc_cnt, temp->qual_pw[pw_cnt].qual_acc[acc_cnt].
    act_cc_id = act_cc_id,
    temp->qual_pw[pw_cnt].qual_acc[acc_cnt].act_cc_desc = act_cc_desc, temp->qual_pw[pw_cnt].
    qual_acc[acc_cnt].act_cc_seq = act_cc_seq, acc_list_cnt = 0
   HEAD comp_seq
    comp_cnt = (comp_cnt+ 1), stat = alterlist(temp->qual_pw[pw_cnt].qual_comp,comp_cnt),
    acc_list_cnt = (acc_list_cnt+ 1),
    stat = alterlist(temp->qual_pw[pw_cnt].qual_acc[acc_cnt].list,acc_list_cnt), temp->qual_pw[pw_cnt
    ].qual_acc[acc_cnt].list[acc_list_cnt].item = comp_cnt, temp->qual_pw[pw_cnt].qual_comp[comp_cnt]
    .comp_seq = comp_seq,
    temp->qual_pw[pw_cnt].qual_comp[comp_cnt].comp_type_cd = comp_type_cd, temp->qual_pw[pw_cnt].
    qual_comp[comp_cnt].parent_entity_name = parent_entity_name, temp->qual_pw[pw_cnt].qual_comp[
    comp_cnt].parent_entity_id = parent_entity_id,
    temp->qual_pw[pw_cnt].qual_comp[comp_cnt].pw_comp_id = pw_comp_id, temp->qual_pw[pw_cnt].
    qual_comp[comp_cnt].comp_note_desc = comp_note_desc, temp->qual_pw[pw_cnt].qual_comp[comp_cnt].
    comp_create_desc = comp_create_desc,
    temp->qual_pw[pw_cnt].qual_comp[comp_cnt].comp_results_desc = comp_results_desc, temp->qual_pw[
    pw_cnt].qual_comp[comp_cnt].outcome_operator = outcome_operator, temp->qual_pw[pw_cnt].qual_comp[
    comp_cnt].result_value = result_value,
    temp->qual_pw[pw_cnt].qual_comp[comp_cnt].result_units = result_units, temp->qual_pw[pw_cnt].
    qual_comp[comp_cnt].comp_label_desc = comp_label_desc, temp->qual_pw[pw_cnt].qual_comp[comp_cnt].
    activated_dt_tm = activated_dt_tm,
    temp->qual_pw[pw_cnt].qual_comp[comp_cnt].table_used = table_used, temp->qual_pw[pw_cnt].
    qual_comp[comp_cnt].check = check, temp->qual_pw[pw_cnt].qual_comp[comp_cnt].comp_active_ind =
    comp_active_ind,
    temp->qual_pw[pw_cnt].qual_comp[comp_cnt].act_pw_comp_id = act_pw_comp_id, temp->qual_pw[pw_cnt].
    qual_comp[comp_cnt].os_display_line = os_display_line, temp->qual_pw[pw_cnt].qual_comp[comp_cnt].
    os_id = os_id,
    temp->qual_pw[pw_cnt].qual_comp[comp_cnt].act_os_display = act_os_display, temp->qual_pw[pw_cnt].
    qual_comp[comp_cnt].act_os_id = act_os_id, temp->qual_pw[pw_cnt].qual_comp[comp_cnt].cond_ind =
    cond_ind,
    temp->qual_pw[pw_cnt].qual_comp[comp_cnt].cond_desc = cond_desc, temp->qual_pw[pw_cnt].qual_comp[
    comp_cnt].cond_eval_ind = cond_eval_ind, temp->qual_pw[pw_cnt].qual_comp[comp_cnt].
    cond_eval_result_ind = cond_eval_result_ind,
    temp->qual_pw[pw_cnt].qual_comp[comp_cnt].included_ind = included_ind, temp->qual_pw[pw_cnt].
    qual_comp[comp_cnt].required_ind = required_ind
   FOOT  act_cc_seq
    temp->qual_pw[pw_cnt].qual_acc[acc_cnt].list_cnt = acc_list_cnt
   FOOT  act_tf_seq
    temp->qual_pw[pw_cnt].qual_tf[tf_cnt].list_cnt = tf_list_cnt
   FOOT  apc.pathway_id
    temp->qual_pw[pw_cnt].acc_cnt = acc_cnt, temp->qual_pw[pw_cnt].tf_cnt = tf_cnt, temp->qual_pw[
    pw_cnt].comp_cnt = comp_cnt
   FOOT REPORT
    temp->count = pw_cnt
  ELSE
  ENDIF
  DISTINCT INTO "nl:"
  encntr_id = apc.encntr_id, act_cc_id = apc.act_care_cat_id, act_cc_desc = substring(1,50,acc
   .description),
  act_cc_seq = acc.sequence, act_tf_id = apc.act_time_frame_id, act_tf_desc = concat(trim(atf
    .description)," (Start Date: ",trim(format(atf.calc_start_dt_tm,"@SHORTDATE")),")"),
  act_tf_seq = atf.sequence, comp_seq = apc.sequence, comp_type_cd = apc.comp_type_cd,
  parent_entity_name = apc.ref_prnt_ent_name, parent_entity_id = apc.ref_prnt_ent_id, pw_comp_id =
  apc.pathway_comp_id,
  comp_note_desc = substring(1,200,lt.long_text), comp_create_desc = trim(ocs.mnemonic),
  comp_results_desc = trim(dta.description),
  outcome_operator = uar_get_code_display(apc.outcome_operator_cd), result_value = trim(cnvtstring(
    apc.result_value)), result_units = uar_get_code_display(apc.result_units_cd),
  comp_label_desc = trim(apc2.comp_label), activated_dt_tm = concat(trim(format(apc.activated_dt_tm,
     "@SHORTDATE"))," ",trim(format(apc.activated_dt_tm,"@TIMENOSECONDS"))), table_used = decode(lt
   .seq,"LT",ocs.seq,"OC",dta.seq,
   "DT",apc2.seq,"PC"),
  check = decode(pc.seq,"PC",o.seq,"OR"), comp_active_ind = apc.activated_ind, act_pw_comp_id = apc
  .act_pw_comp_id,
  os_display_line = concat("-",trim(ost.order_sentence_display_line)), os_id = ost.order_sentence_id,
  act_os_display = concat("-",trim(o.order_detail_display_line)),
  act_os_id = o.order_id, cond_ind = apc.cond_ind, cond_desc = substring(1,50,apc.cond_desc),
  cond_eval_ind = apc.cond_eval_ind, cond_eval_result_ind = apc.cond_eval_result_ind, included_ind =
  apc.included_ind,
  required_ind = apc.required_ind
  FROM act_pw_comp apc,
   act_care_cat acc,
   act_time_frame atf,
   pathway_comp pc,
   long_text lt,
   order_catalog_synonym ocs,
   order_sentence ost,
   orders o,
   discrete_task_assay dta,
   act_pw_comp apc2,
   (dummyt d  WITH seq = value(temp->count)),
   (dummyt d1  WITH seq = 1),
   (dummyt d2  WITH seq = 1),
   (dummyt d3  WITH seq = 1)
  PLAN (d)
   JOIN (apc
   WHERE (apc.pathway_id=temp->qual_pw[d.seq].pathway_id)
    AND apc.active_ind > 0)
   JOIN (acc
   WHERE acc.act_care_cat_id=apc.act_care_cat_id
    AND acc.active_ind=1)
   JOIN (atf
   WHERE atf.act_time_frame_id=apc.act_time_frame_id
    AND atf.active_ind=1)
   JOIN (d1)
   JOIN (((lt
   WHERE apc.comp_type_cd=note_type_cd
    AND lt.parent_entity_id=apc.act_pw_comp_id
    AND lt.parent_entity_name="ACT_PW_COMP"
    AND lt.long_text_id=apc.parent_entity_id)
   ) ORJOIN ((((ocs
   WHERE ((apc.comp_type_cd=order_create_type_cd) OR (((apc.comp_type_cd=outcome_create_type_cd) OR (
   apc.comp_type_cd=task_create_type_cd)) ))
    AND apc.ref_prnt_ent_id=ocs.synonym_id)
   JOIN (d2
   WHERE d2.seq=1)
   JOIN (((o
   WHERE apc.parent_entity_id > 0
    AND o.order_detail_display_line > " "
    AND apc.parent_entity_id=o.order_id)
   ) ORJOIN ((d3)
   JOIN (pc
   WHERE apc.pathway_comp_id > 0
    AND apc.pathway_comp_id=pc.pathway_comp_id)
   JOIN (ost
   WHERE pc.order_sentence_id=ost.order_sentence_id)
   )) ) ORJOIN ((((dta
   WHERE apc.comp_type_cd=result_outcome_type_cd
    AND dta.task_assay_cd=apc.task_assay_cd)
   ) ORJOIN ((apc2
   WHERE apc.comp_type_cd=label_type_cd
    AND apc2.act_pw_comp_id=apc.act_pw_comp_id)
   )) )) ))
  WITH counter, outerjoin = d1, outerjoin = d2
 ;end select
 SELECT INTO "nl:"
  FROM encounter e,
   person p,
   person_alias pa,
   prsnl pr,
   encntr_prsnl_reltn epr,
   (dummyt d1  WITH seq = 1),
   (dummyt d2  WITH seq = 1)
  PLAN (p
   WHERE (p.person_id=request->person_id))
   JOIN (e
   WHERE p.person_id=e.person_id
    AND (e.encntr_id=temp->encntr_id))
   JOIN (d1)
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.person_alias_type_cd=mrn_alias_cd
    AND pa.active_ind=1
    AND pa.alias != null)
   JOIN (d2)
   JOIN (epr
   WHERE epr.encntr_id=e.encntr_id
    AND epr.encntr_prsnl_r_cd IN (admit_doc_cd, attend_doc_cd)
    AND epr.active_ind=1
    AND ((epr.expiration_ind != 1) OR (epr.expiration_ind = null)) )
   JOIN (pr
   WHERE pr.person_id=epr.prsnl_person_id)
  HEAD REPORT
   adm_date = format(e.reg_dt_tm,"@SHORTDATE"), location = substring(1,20,uar_get_code_display(e
     .loc_nurse_unit_cd)), room = substring(1,20,uar_get_code_display(e.loc_room_cd)),
   bed = substring(1,20,uar_get_code_display(e.loc_bed_cd)), service = substring(1,40,
    uar_get_code_display(e.med_service_cd)), pat_name = substring(1,30,p.name_full_formatted),
   age = trim(cnvtage(cnvtdate(p.birth_dt_tm),curdate)), sex = substring(1,10,uar_get_code_display(p
     .sex_cd))
  HEAD epr.encntr_prsnl_r_cd
   IF (epr.encntr_prsnl_r_cd=admit_doc_cd)
    admit_doc = substring(1,30,pr.name_full_formatted)
   ELSEIF (epr.encntr_prsnl_r_cd=attend_doc_cd)
    attend_doc = substring(1,30,pr.name_full_formatted)
   ENDIF
  DETAIL
   IF (pa.person_alias_type_cd=mrn_alias_cd)
    IF (pa.alias_pool_cd > 0)
     mrn = cnvtalias(pa.alias,pa.alias_pool_cd)
    ELSE
     mrn = pa.alias
    ENDIF
   ENDIF
   visit = trim(cnvtstring(pa.visit_seq_nbr))
  WITH nocounter, outerjoin = d1, dontcare = pa,
   outerjoin = d2, dontcare = epr
 ;end select
 SELECT INTO value(request->output_device)
  d.seq
  FROM (dummyt d  WITH seq = value(temp->count))
  PLAN (d)
  HEAD REPORT
   "{f/8}", "{cpi/12}", "{ipc}"
  HEAD PAGE
   "{b}{pos/250/48}Pathway Activity Audit{endb}", row + 1,
   "{b}{pos/50/72}____________________________________________________________________________________________{endb}",
   row + 1, "{pos/51/84}Patient Name{pos/139/84}:  ", pat_name,
   "{pos/340/84}Age{pos/397/84}: ", age, row + 1,
   "{pos/51/96}MRN{pos/139/96}:  ", mrn, "{pos/340/96}Gender{pos/397/96}:  ",
   sex, row + 1, "{pos/51/108}Admission Date{pos/139/108}:  ",
   adm_date, "{pos/340/108}Location{pos/397/108}:  ", location,
   row + 1, "{pos/51/120}Admitting Physician{pos/139/120}:  ", admit_doc
   IF (trim(bed) != " "
    AND trim(room) != " ")
    yyy = concat(trim(room)," ; ",trim(bed)), "{pos/340/120}Room & Bed{pos/397/120}:  ", yyy,
    row + 1
   ELSE
    "{pos/340/120}Room & Bed{pos/397/120}:  ", row + 1
   ENDIF
   "{pos/51/132}Attending Physician{pos/139/132}:  ", attend_doc,
   "{pos/340/132}Service{pos/397/132}:  ",
   service, row + 1, "{pos/51/144}Visit Number{pos/139/144}:  ",
   visit, row + 1,
   "{b}{pos/50/147}____________________________________________________________________________________________{endb}",
   row + 1
  HEAD d.seq
   IF (d.seq=1)
    x = 51, y = 180, test_y = y
   ENDIF
   CALL print(calcpos(x,y)), "Description: ", temp->qual_pw[d.seq].pw_desc,
   row + 2, y = (y+ 24),
   CALL print(calcpos(x,y)),
   "Status: ", temp->qual_pw[d.seq].pw_status, row + 2,
   y = (y+ 24),
   CALL print(calcpos(x,y)), "Date/Time Started: ",
   temp->qual_pw[d.seq].pw_start_dt_tm, row + 2, y = (y+ 24),
   CALL print(calcpos(x,y)), "Initiated By: ", temp->qual_pw[d.seq].pw_init_by_name,
   row + 2
  DETAIL
   IF (sort_flag="C")
    FOR (i = 1 TO temp->qual_pw[d.seq].acc_cnt)
      y = (y+ 24)
      IF (((y+ 48) > 716))
       BREAK, y = test_y
      ENDIF
      CALL print(calcpos(x,y)), "{b}{u}", temp->qual_pw[d.seq].qual_acc[i].act_cc_desc,
      row + 2, cur_cc = concat(trim(temp->qual_pw[d.seq].qual_acc[i].act_cc_desc)," (cont'd)")
      FOR (j = 1 TO temp->qual_pw[d.seq].qual_acc[i].list_cnt)
        ind1 = temp->qual_pw[d.seq].qual_acc[i].list[j].item, x1 = 65, y = (y+ 12),
        CALL print(calcpos(x1,y)), "{u}", temp->qual_pw[d.seq].qual_tf[ind1].act_tf_desc,
        row + 1, cur_tf = concat(trim(temp->qual_pw[d.seq].qual_tf[ind1].act_tf_desc)," (cont'd)"),
        comp_cnt = 0
        FOR (k = 1 TO temp->qual_pw[d.seq].qual_tf[ind1].list_cnt)
         ind2 = temp->qual_pw[d.seq].qual_tf[ind1].list[k].item,
         IF (((comp_flag="N"
          AND (temp->qual_pw[d.seq].qual_comp[ind2].included_ind=1)) OR (comp_flag="Y")) )
          IF ((((temp->qual_pw[d.seq].qual_comp[ind2].os_id > 0)) OR ((temp->qual_pw[d.seq].
          qual_comp[ind2].act_os_id > 0))) )
           IF ((temp->qual_pw[d.seq].qual_comp[ind2].act_os_id > 0))
            numchars = textlen(trim(temp->qual_pw[d.seq].qual_comp[ind2].act_os_display))
           ELSE
            numchars = textlen(trim(temp->qual_pw[d.seq].qual_comp[ind2].os_display_line))
           ENDIF
           IF (numchars < 35)
            IF ((temp->qual_pw[d.seq].qual_comp[ind2].act_os_id > 0))
             printed->qual_lines[1] = temp->qual_pw[d.seq].qual_comp[ind2].act_os_display
            ELSE
             printed->qual_lines[1] = temp->qual_pw[d.seq].qual_comp[ind2].os_display_line
            ENDIF
            line_ctr = 1
           ELSE
            end_pos = 0, line_ctr = 1, start_pos = 1,
            char_ctr = 1
            FOR (z = 1 TO 255)
              os->display[z] = " "
            ENDFOR
            IF ((temp->qual_pw[d.seq].qual_comp[ind2].act_os_id > 0))
             FOR (n = 1 TO numchars)
               os->display[n] = substring(n,1,temp->qual_pw[d.seq].qual_comp[ind2].act_os_display)
             ENDFOR
            ELSE
             FOR (n = 1 TO numchars)
               os->display[n] = substring(n,1,temp->qual_pw[d.seq].qual_comp[ind2].os_display_line)
             ENDFOR
            ENDIF
            IF (numchars < 255)
             FOR (n = (numchars+ 1) TO 255)
               os->display[n] = " "
             ENDFOR
            ENDIF
            WHILE (char_ctr <= numchars)
              FOR (z = 1 TO 35)
                temp1->display[z] = " "
              ENDFOR
              printed->qual_lines[line_ctr] = fillstring(35," ")
              IF (line_ctr > 1)
               start_pos = (end_pos+ 1)
              ENDIF
              IF (((numchars - start_pos) < 35)
               AND line_ctr > 1)
               m = 1
               FOR (n = start_pos TO numchars)
                temp1->display[m] = os->display[n],m = (m+ 1)
               ENDFOR
               m = 1
               FOR (n = char_ctr TO numchars)
                printed->qual_lines[line_ctr].display[m] = temp1->display[m],m = (m+ 1)
               ENDFOR
               char_ctr = (numchars+ 1), found_ind = 1
              ELSE
               temp1->display = substring(start_pos,35,os), found_ind = 0
              ENDIF
              index = 35
              WHILE (found_ind=0
               AND index > 0)
                IF ((temp1->display[index]=","))
                 found_ind = 1
                 FOR (n = 1 TO index)
                   printed->qual_lines[line_ctr].display[n] = temp1->display[n]
                 ENDFOR
                 char_ctr = (char_ctr+ index), end_pos = ((start_pos+ index) - 1)
                ELSE
                 index = (index - 1), found_ind = 0
                ENDIF
              ENDWHILE
              IF (index=0
               AND found_ind=0)
               m = 1
               FOR (n = start_pos TO (start_pos+ 33))
                printed->qual_lines[line_ctr].display[m] = temp1->display[m],m = (m+ 1)
               ENDFOR
               end_pos = (start_pos+ 33)
              ENDIF
              line_ctr = (line_ctr+ 1)
            ENDWHILE
           ENDIF
          ENDIF
          IF ((temp->qual_pw[d.seq].qual_comp[ind2].cond_ind=1))
           line_ctr = (line_ctr+ 1)
          ENDIF
          y = (y+ 12), comp_cnt = (comp_cnt+ 1)
          IF (((y+ ((line_ctr+ 1) * 12)) >= 716))
           BREAK, y = test_y,
           CALL print(calcpos(x,y)),
           "{b}{u}", cur_cc, row + 1,
           y = (y+ 12),
           CALL print(calcpos(x1,y)), "{u}",
           cur_tf, row + 1, y = (y+ 12)
          ENDIF
          x2 = 70, comp_num = concat(trim(cnvtstring(comp_cnt),3),")"),
          CALL print(calcpos(x2,y)),
          comp_num, x3 = 85
          IF ((temp->qual_pw[d.seq].qual_comp[ind2].required_ind=1))
           CALL print(calcpos(x3,y)), "R"
          ELSEIF ((temp->qual_pw[d.seq].qual_comp[ind2].included_ind=1))
           CALL print(calcpos(x3,y)), "I"
          ELSE
           CALL print(calcpos(x3,y)), "E"
          ENDIF
          x4 = 100
          IF ((temp->qual_pw[d.seq].qual_comp[ind2].table_used="LT"))
           notes->length = textlen(trim(temp->qual_pw[d.seq].qual_comp[ind2].comp_note_desc))
           IF ((notes->length > 70))
            notes->display = temp->qual_pw[d.seq].qual_comp[ind2].comp_note_desc, notes->display =
            substring(1,67,notes->display), notes->display = concat(trim(notes->display),"...")
           ELSE
            notes->display = substring(1,70,temp->qual_pw[d.seq].qual_comp[ind2].comp_note_desc)
           ENDIF
           pos = findstring(char(13),notes->display)
           IF (pos > 0)
            notes->display = substring(1,(pos - 1),notes->display)
            IF (pos > 67)
             pos = 67
            ENDIF
            notes->display = concat(notes->display,"...")
           ENDIF
           CALL print(calcpos(x4,y)), "NO", x5 = (x4+ 24),
           CALL print(calcpos(x5,y)), notes->display, " ",
           row + 1
          ELSEIF ((temp->qual_pw[d.seq].qual_comp[ind2].table_used="OC"))
           IF ((temp->qual_pw[d.seq].qual_comp[ind2].comp_type_cd=order_create_type_cd))
            CALL print(calcpos(x4,y)), "OR"
           ENDIF
           x5 = (x4+ 24)
           IF (textlen(temp->qual_pw[d.seq].qual_comp[ind2].comp_create_desc) > 30)
            ord_line1 = substring(1,27,temp->qual_pw[d.seq].qual_comp[ind2].comp_create_desc),
            ord_line = concat(ord_line1,"...")
           ELSE
            ord_line = trim(temp->qual_pw[d.seq].qual_comp[ind2].comp_create_desc)
           ENDIF
           CALL print(calcpos(x5,y)), ord_line, " ",
           row + 1
          ELSEIF ((temp->qual_pw[d.seq].qual_comp[ind2].table_used="DT"))
           CALL print(calcpos(x4,y)), "EO", x5 = (x4+ 24),
           str1 = trim(temp->qual_pw[d.seq].qual_comp[ind2].outcome_operator,3), str2 = trim(temp->
            qual_pw[d.seq].qual_comp[ind2].result_value,3), str3 = trim(temp->qual_pw[d.seq].
            qual_comp[ind2].result_units,3),
           eo_line = concat(str1," ",str2," ",str3)
           IF (textlen(temp->qual_pw[d.seq].qual_comp[ind2].comp_results_desc) > 30)
            eo_name1 = substring(1,27,temp->qual_pw[d.seq].qual_comp[ind2].comp_results_desc),
            eo_name = concat(eo_name1,"...")
           ELSE
            eo_name = trim(temp->qual_pw[d.seq].qual_comp[ind2].comp_results_desc)
           ENDIF
           CALL print(calcpos(x5,y)), eo_name,
           CALL print(calcpos(280,y)),
           eo_line, row + 1
          ELSEIF ((temp->qual_pw[d.seq].qual_comp[ind2].table_used="PC"))
           labels->length = textlen(trim(temp->qual_pw[d.seq].qual_comp[ind2].comp_label_desc))
           IF ((labels->length > 70))
            labels->display = substring(1,67,temp->qual_pw[d.seq].qual_comp[ind2].comp_label_desc),
            labels->display = concat(trim(labels->display,3),"...")
           ELSE
            labels->display = substring(1,70,temp->qual_pw[d.seq].qual_comp[ind2].comp_label_desc)
           ENDIF
           CALL print(calcpos(x4,y)), "LA", x5 = (x4+ 24),
           CALL print(calcpos(x5,y)), labels->display, row + 1
          ENDIF
          x6 = 480
          IF ((temp->qual_pw[d.seq].qual_comp[ind2].comp_active_ind=1))
           act_line = concat("Act: ",temp->qual_pw[d.seq].qual_comp[ind2].activated_dt_tm),
           CALL print(calcpos(x6,y)), act_line
          ELSE
           IF (det_flag="Y")
            CALL print(calcpos(x6,y)), "NOT ACTIVE"
           ELSE
            FOR (n = 1 TO line_ctr)
              printed->qual_lines[n].display = fillstring(35," ")
            ENDFOR
           ENDIF
          ENDIF
          IF (((det_flag="Y") OR (det_flag="N"
           AND (temp->qual_pw[d.seq].qual_comp[ind2].comp_active_ind=1))) )
           IF ((((temp->qual_pw[d.seq].qual_comp[ind2].os_id > 0)) OR ((temp->qual_pw[d.seq].
           qual_comp[ind2].act_os_id > 0))) )
            IF ((temp->qual_pw[d.seq].qual_comp[ind2].cond_ind > 0))
             IF (line_ctr=1)
              x7 = 280,
              CALL print(calcpos(x7,y)), printed->qual_lines[1],
              row + 1
             ELSE
              FOR (n = 1 TO (line_ctr - 2))
                IF (n > 1)
                 y = (y+ 12)
                ENDIF
                x7 = 280,
                CALL print(calcpos(x7,y)), printed->qual_lines[n],
                row + 1
              ENDFOR
              x8 = 280, y = (y+ 12), cond_line1 = concat("Cond: ",substring(1,35,temp->qual_pw[d.seq]
                .qual_comp[ind2].cond_desc),"   ")
              IF ((temp->qual_pw[d.seq].qual_comp[ind2].cond_eval_ind=0))
               cond_line = concat(trim(cond_line1),"   Not Evaluated")
              ELSE
               IF ((temp->qual_pw[d.seq].qual_comp[ind2].cond_eval_result_ind=1))
                cond_line = concat(trim(cond_line1),"   Eval: True")
               ELSE
                cond_line = concat(trim(cond_line1),"   Eval: False")
               ENDIF
              ENDIF
              CALL echo(cond_line),
              CALL print(calcpos(x8,y)), cond_line,
              row + 1
             ENDIF
            ELSE
             IF (line_ctr=1)
              x7 = 280,
              CALL print(calcpos(x7,y)), printed->qual_lines[1],
              row + 1
             ELSE
              x7 = 280
              FOR (n = 1 TO (line_ctr - 1))
                IF (n > 1)
                 y = (y+ 12)
                ENDIF
                x7 = 280,
                CALL print(calcpos(x7,y)), printed->qual_lines[n],
                row + 1
              ENDFOR
             ENDIF
            ENDIF
           ENDIF
          ELSE
           row + 1
          ENDIF
         ENDIF
        ENDFOR
        y = (y+ 12), row + 1
      ENDFOR
    ENDFOR
   ELSEIF (sort_flag="T")
    FOR (i = 1 TO temp->qual_pw[d.seq].tf_cnt)
      y = (y+ 24)
      IF (((y+ 48) > 716))
       BREAK, y = test_y
      ENDIF
      CALL print(calcpos(x,y)), "{b}{u}", temp->qual_pw[d.seq].qual_tf[i].act_tf_desc,
      row + 2, cur_tf = concat(trim(temp->qual_pw[d.seq].qual_tf[i].act_tf_desc)," (cont'd)")
      FOR (j = 1 TO temp->qual_pw[d.seq].qual_tf[i].list_cnt)
        ind1 = temp->qual_pw[d.seq].qual_tf[i].list[j].item
        IF (((y+ 36) > 716))
         BREAK, y = test_y,
         CALL print(calcpos(x,y)),
         "{b}{u}", cur_tf, row + 1,
         y = (y+ 12)
        ELSE
         y = (y+ 12)
        ENDIF
        x1 = 65,
        CALL print(calcpos(x1,y)), "{u}",
        temp->qual_pw[d.seq].qual_acc[ind1].act_cc_desc, row + 1, cur_cc = concat(trim(temp->qual_pw[
          d.seq].qual_acc[ind1].act_cc_desc)," (cont'd)"),
        comp_cnt = 0
        FOR (k = 1 TO temp->qual_pw[d.seq].qual_acc[ind1].list_cnt)
         ind2 = temp->qual_pw[d.seq].qual_acc[ind1].list[k].item,
         IF (((comp_flag="N"
          AND (temp->qual_pw[d.seq].qual_comp[ind2].included_ind=1)) OR (comp_flag="Y")) )
          IF ((((temp->qual_pw[d.seq].qual_comp[ind2].os_id > 0)) OR ((temp->qual_pw[d.seq].
          qual_comp[ind2].act_os_id > 0))) )
           IF ((temp->qual_pw[d.seq].qual_comp[ind2].act_os_id > 0))
            numchars = textlen(trim(temp->qual_pw[d.seq].qual_comp[ind2].act_os_display))
           ELSE
            numchars = textlen(trim(temp->qual_pw[d.seq].qual_comp[ind2].os_display_line))
           ENDIF
           FOR (z = 1 TO 6)
             printed->qual_lines[z] = fillstring(35," ")
           ENDFOR
           IF (numchars < 35)
            IF ((temp->qual_pw[d.seq].qual_comp[ind2].act_os_id > 0))
             printed->qual_lines[1] = temp->qual_pw[d.seq].qual_comp[ind2].act_os_display
            ELSE
             printed->qual_lines[1] = temp->qual_pw[d.seq].qual_comp[ind2].os_display_line
            ENDIF
            line_ctr = 1
           ELSE
            end_pos = 0, line_ctr = 1, start_pos = 1,
            char_ctr = 1
            IF ((temp->qual_pw[d.seq].qual_comp[ind2].act_os_id > 0))
             FOR (n = 1 TO numchars)
               os->display[n] = substring(n,1,temp->qual_pw[d.seq].qual_comp[ind2].act_os_display)
             ENDFOR
            ELSE
             FOR (n = 1 TO numchars)
               os->display[n] = substring(n,1,temp->qual_pw[d.seq].qual_comp[ind2].os_display_line)
             ENDFOR
            ENDIF
            IF (numchars < 255)
             FOR (n = (numchars+ 1) TO 255)
               os->display[n] = " "
             ENDFOR
            ENDIF
            WHILE (char_ctr <= numchars)
              FOR (z = 1 TO 35)
                temp1->display[z] = " "
              ENDFOR
              printed->qual_lines[line_ctr] = fillstring(35," ")
              IF (line_ctr > 1)
               start_pos = (end_pos+ 1)
              ENDIF
              IF (((numchars - start_pos) < 35)
               AND line_ctr > 1)
               m = 1
               FOR (n = start_pos TO numchars)
                temp1->display[m] = os->display[n],m = (m+ 1)
               ENDFOR
               m = 1
               FOR (n = start_pos TO numchars)
                printed->qual_lines[line_ctr].display[m] = temp1->display[m],m = (m+ 1)
               ENDFOR
               char_ctr = (numchars+ 1), found_ind = 1
              ELSE
               m = 1
               FOR (n = start_pos TO (start_pos+ 34))
                temp1->display[m] = os->display[n],m = (m+ 1)
               ENDFOR
               found_ind = 0
              ENDIF
              index = 35
              WHILE (found_ind=0
               AND index > 0)
                IF ((temp1->display[index]=","))
                 found_ind = 1
                 FOR (n = 1 TO index)
                   printed->qual_lines[line_ctr].display[n] = temp1->display[n]
                 ENDFOR
                 char_ctr = (char_ctr+ index), end_pos = ((start_pos+ index) - 1)
                ELSE
                 index = (index - 1), found_ind = 0
                ENDIF
              ENDWHILE
              IF (index=0
               AND found_ind=0)
               m = 1
               FOR (n = start_pos TO (start_pos+ 34))
                printed->qual_lines[line_ctr].display[m] = temp1->display[m],m = (m+ 1)
               ENDFOR
               end_pos = (start_pos+ 34)
              ENDIF
              line_ctr = (line_ctr+ 1)
            ENDWHILE
           ENDIF
          ENDIF
          IF ((temp->qual_pw[d.seq].qual_comp[ind2].cond_ind=1))
           line_ctr = (line_ctr+ 1)
          ENDIF
          y = (y+ 12), comp_cnt = (comp_cnt+ 1)
          IF (((y+ ((line_ctr+ 1) * 12)) >= 716))
           BREAK, y = test_y,
           CALL print(calcpos(x,y)),
           "{b}{u}", cur_tf, row + 1,
           y = (y+ 12),
           CALL print(calcpos(x1,y)), "{u}",
           cur_cc, row + 1, y = (y+ 12)
          ENDIF
          x2 = 70, comp_num = concat(trim(cnvtstring(comp_cnt),3),")"),
          CALL print(calcpos(x2,y)),
          comp_num, x3 = 85
          IF ((temp->qual_pw[d.seq].qual_comp[ind2].required_ind=1))
           CALL print(calcpos(x3,y)), "R"
          ELSEIF ((temp->qual_pw[d.seq].qual_comp[ind2].included_ind=1))
           CALL print(calcpos(x3,y)), "I"
          ELSE
           CALL print(calcpos(x3,y)), "E"
          ENDIF
          x4 = 100
          IF ((temp->qual_pw[d.seq].qual_comp[ind2].table_used="LT"))
           notes->length = textlen(trim(temp->qual_pw[d.seq].qual_comp[ind2].comp_note_desc))
           IF ((notes->length > 70))
            notes->display = temp->qual_pw[d.seq].qual_comp[ind2].comp_note_desc, notes->display =
            substring(1,67,notes->display), notes->display = concat(trim(notes->display),"...")
           ELSE
            notes->display = substring(1,70,temp->qual_pw[d.seq].qual_comp[ind2].comp_note_desc)
           ENDIF
           pos = findstring(char(13),notes->display)
           IF (pos > 0)
            notes->display = substring(1,(pos - 1),notes->display)
            IF (pos > 67)
             pos = 67
            ENDIF
            notes->display = concat(notes->display,"...")
           ENDIF
           CALL print(calcpos(x4,y)), "NO", x5 = (x4+ 24),
           CALL print(calcpos(x5,y)), notes->display, " ",
           row + 1
          ELSEIF ((temp->qual_pw[d.seq].qual_comp[ind2].table_used="OC"))
           IF ((temp->qual_pw[d.seq].qual_comp[ind2].comp_type_cd=order_create_type_cd))
            CALL print(calcpos(x4,y)), "OR"
           ENDIF
           x5 = (x4+ 24)
           IF (textlen(temp->qual_pw[d.seq].qual_comp[ind2].comp_create_desc) > 30)
            ord_line1 = substring(1,27,temp->qual_pw[d.seq].qual_comp[ind2].comp_create_desc),
            ord_line = concat(ord_line1,"...")
           ELSE
            ord_line = trim(temp->qual_pw[d.seq].qual_comp[ind2].comp_create_desc)
           ENDIF
           CALL print(calcpos(x5,y)), ord_line, " ",
           row + 1
          ELSEIF ((temp->qual_pw[d.seq].qual_comp[ind2].table_used="DT"))
           CALL print(calcpos(x4,y)), "EO", x5 = (x4+ 24),
           str1 = trim(temp->qual_pw[d.seq].qual_comp[ind2].outcome_operator,3), str2 = trim(temp->
            qual_pw[d.seq].qual_comp[ind2].result_value,3), str3 = trim(temp->qual_pw[d.seq].
            qual_comp[ind2].result_units,3),
           eo_line = concat(str1," ",str2," ",str3)
           IF (textlen(temp->qual_pw[d.seq].qual_comp[ind2].comp_results_desc) > 30)
            eo_name1 = substring(1,27,temp->qual_pw[d.seq].qual_comp[ind2].comp_results_desc),
            eo_name = concat(eo_name1,"...")
           ELSE
            eo_name = trim(temp->qual_pw[d.seq].qual_comp[ind2].comp_results_desc)
           ENDIF
           CALL print(calcpos(x5,y)), eo_name,
           CALL print(calcpos(280,y)),
           eo_line, row + 1
          ELSEIF ((temp->qual_pw[d.seq].qual_comp[ind2].table_used="PC"))
           labels->length = textlen(trim(temp->qual_pw[d.seq].qual_comp[ind2].comp_label_desc))
           IF ((labels->length > 70))
            labels->display = substring(1,67,temp->qual_pw[d.seq].qual_comp[ind2].comp_label_desc),
            labels->display = concat(trim(labels->display,3),"...")
           ELSE
            labels->display = substring(1,70,temp->qual_pw[d.seq].qual_comp[ind2].comp_label_desc)
           ENDIF
           CALL print(calcpos(x4,y)), "LA", x5 = (x4+ 24),
           CALL print(calcpos(x5,y)), labels->display, row + 1
          ENDIF
          x6 = 480
          IF ((temp->qual_pw[d.seq].qual_comp[ind2].comp_active_ind=1))
           act_line = concat("Act: ",temp->qual_pw[d.seq].qual_comp[ind2].activated_dt_tm),
           CALL print(calcpos(x6,y)), act_line
          ELSE
           IF (det_flag="Y")
            CALL print(calcpos(x6,y)), "NOT ACTIVE"
           ELSE
            FOR (n = 1 TO line_ctr)
              printed->qual_lines[n] = fillstring(35," ")
            ENDFOR
           ENDIF
          ENDIF
          IF (((det_flag="Y") OR (det_flag="N"
           AND (temp->qual_pw[d.seq].qual_comp[ind2].comp_active_ind=1))) )
           IF ((((temp->qual_pw[d.seq].qual_comp[ind2].os_id > 0)) OR ((temp->qual_pw[d.seq].
           qual_comp[ind2].act_os_id > 0))) )
            IF ((temp->qual_pw[d.seq].qual_comp[ind2].cond_ind > 0))
             IF (line_ctr=1)
              x7 = 280,
              CALL print(calcpos(x7,y)), printed->qual_lines[1],
              row + 1
             ELSE
              FOR (n = 1 TO (line_ctr - 2))
                IF (n > 1)
                 y = (y+ 12)
                ENDIF
                x7 = 280,
                CALL print(calcpos(x7,y)), printed->qual_lines[n],
                row + 1
              ENDFOR
              x8 = 280, y = (y+ 12), cond_line1 = concat("Cond: ",substring(1,35,temp->qual_pw[d.seq]
                .qual_comp[ind2].cond_desc),"   ")
              IF ((temp->qual_pw[d.seq].qual_comp[ind2].cond_eval_ind=0))
               cond_line = concat(trim(cond_line1),"   Not Evaluated")
              ELSE
               IF ((temp->qual_pw[d.seq].qual_comp[ind2].cond_eval_result_ind=1))
                cond_line = concat(trim(cond_line1),"   Eval: True")
               ELSE
                cond_line = concat(trim(cond_line1),"   Eval: False")
               ENDIF
              ENDIF
              CALL echo(cond_line),
              CALL print(calcpos(x8,y)), cond_line,
              row + 1
             ENDIF
            ELSE
             IF (line_ctr=1)
              x7 = 280,
              CALL print(calcpos(x7,y)), printed->qual_lines[1],
              row + 1
             ELSE
              x7 = 280
              FOR (n = 1 TO (line_ctr - 1))
                IF (n > 1)
                 y = (y+ 12)
                ENDIF
                x7 = 280,
                CALL print(calcpos(x7,y)), printed->qual_lines[n],
                row + 1
              ENDFOR
             ENDIF
            ENDIF
           ENDIF
          ELSE
           row + 1
          ENDIF
         ENDIF
        ENDFOR
        y = (y+ 12), row + 1
      ENDFOR
    ENDFOR
   ENDIF
  FOOT  d.seq
   IF (((y+ 48) > 716))
    BREAK, y = (test_y - 24)
   ENDIF
   y = (y+ 24),
   CALL print(calcpos(x,y)), "Date/Time Stopped: ",
   temp->qual_pw[d.seq].pw_end_dt_tm, row + 2, y = (y+ 24),
   CALL print(calcpos(x,y)), "Discontinued By: ", temp->qual_pw[d.seq].pw_disc_by_name,
   row + 2, cur_y = mod(y,716)
   IF ((d.seq != temp->count))
    IF (((cur_y+ 156) > 716))
     BREAK, y = test_y
    ELSE
     y = (y+ 48)
    ENDIF
   ENDIF
  FOOT PAGE
   mrn_foot = concat("MR Form # ",cnvtstring(formnum)), footer = concat("Page ",cnvtstring(curpage)),
   "{pos/51/740}",
   mrn_foot, "{pos/290/740}", footer,
   "{pos/490/740}", cur_date"mm/dd/yy hh:mm;;d", row + 1
  WITH nocounter, dio = postscript, maxcol = 792,
   maxrow = 6000
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
