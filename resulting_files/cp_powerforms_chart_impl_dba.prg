CREATE PROGRAM cp_powerforms_chart_impl:dba
 DECLARE medprofile_formatting(sect=i4,ctrl=i4,medindex=i4) = null
 DECLARE problem_formatting(sect=i4,ctrl=i4,probindex=i4) = null
 DECLARE dx_formatting(sect=i4,ctrl=i4,dxindex=i4) = null
 DECLARE gest_formatting(sect=i4,ctrl=i4,gestindex=i4) = null
 DECLARE encntr_formatting(sect=i4,ctrl=i4,encindex=i4) = null
 DECLARE xrtextlinesizecaculations(null) = null
 DECLARE debug_ind = i2 WITH protect, noconstant(0)
 DECLARE frms_failure_ind = i2 WITH protect, noconstant(0)
 DECLARE form_cnt = i4 WITH protect, noconstant(0)
 DECLARE ln = i4 WITH protect, noconstant(0)
 DECLARE done = c1 WITH protect, noconstant("F")
 DECLARE numrows = i4 WITH protect, noconstant(0)
 DECLARE pagevar = i4 WITH protect, noconstant(0)
 DECLARE last_activity_dt_tm = dq8 WITH protect, noconstant(cnvtdatetime(curdate,curtime))
 DECLARE last_activity_date = c20 WITH protect, noconstant(fillstring(20," "))
 DECLARE last_activity_by = c30 WITH protect, noconstant(fillstring(30," "))
 DECLARE version_dt_tm = dq8 WITH protect, noconstant(cnvtdatetime(curdate,curtime))
 DECLARE labl_length = i4 WITH protect, noconstant(0)
 DECLARE ln_number = vc
 DECLARE prob_desc_size = i4 WITH noconstant(0), protect
 DECLARE prob_desc_idx = i4 WITH noconstant(1), protect
 DECLARE dx_desc_size = i4 WITH noconstant(0), protect
 DECLARE dx_desc_idx = i4 WITH noconstant(1), protect
 DECLARE prob_count = i4 WITH noconstant(0), protect
 DECLARE dx_count = i4 WITH noconstant(0), protect
 DECLARE comm_pref_cnt = i4 WITH noconstant(0), protect
 DECLARE comm_pref_idx = i4 WITH noconstant(0), protect
 DECLARE facnt = i4 WITH noconstant(0), protect
 DECLARE last_mod = c12 WITH private, noconstant(fillstring(12," "))
 SET ec = char(0)
 SET blob_out = fillstring(32000," ")
 SET code_value = 0.0
 SET code_set = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET ycol = 0
 SET xcol = 0
 SET xxx = fillstring(40," ")
 SET day = fillstring(2," ")
 SET month = fillstring(2," ")
 SET year = fillstring(2," ")
 SET hour = fillstring(2," ")
 SET minute = fillstring(2," ")
 SET error_line = fillstring(40," ")
 DECLARE clinical_cd = f8 WITH public, constant(uar_get_code_by("MEANING",18189,"CLINCALEVENT"))
 DECLARE ocfcomp_cd = f8 WITH public, constant(uar_get_code_by("MEANING",120,"OCFCOMP"))
 DECLARE modified_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE canceled_cd = f8 WITH public, constant(uar_get_code_by("MEANING",12025,"CANCELED"))
 DECLARE date_cd = f8 WITH public, constant(uar_get_code_by("MEANING",53,"DATE"))
 DECLARE text_cd = f8 WITH public, constant(uar_get_code_by("MEANING",53,"TXT"))
 DECLARE num_cd = f8 WITH public, constant(uar_get_code_by("MEANING",53,"NUM"))
 DECLARE child_cd = f8 WITH public, constant(uar_get_code_by("MEANING",24,"CHILD"))
 DECLARE root_cd = f8 WITH public, constant(uar_get_code_by("MEANING",24,"ROOT"))
 DECLARE inerror_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"INERROR"))
 DECLARE deceased_cd_yes = f8 WITH public, constant(uar_get_code_by("MEANING",268,"YES"))
 SET error_line = uar_get_code_display(cnvtreal(value(inerror_cd)))
 DECLARE max_length = i4 WITH protect, noconstant(0)
 DECLARE linecnt = i4 WITH protect, noconstant(0)
 DECLARE lineidx = i4 WITH protect, noconstant(0)
 DECLARE pat_name = vc WITH protect, noconstant(fillstring(100," "))
 DECLARE memb_ind_str = vc WITH protect, noconstant(fillstring(100," "))
 DECLARE m_totalchar = i4 WITH protect, noconstant(88)
 DECLARE memb_cnt = i4 WITH protect, noconstant(0)
 DECLARE memb_idx = i4 WITH protect, noconstant(0)
 DECLARE cond_cnt = i4 WITH protect, noconstant(0)
 DECLARE cond_idx = i4 WITH protect, noconstant(0)
 DECLARE cmnt_cnt = i4 WITH protect, noconstant(0)
 DECLARE cmnt_idx = i4 WITH protect, noconstant(0)
 DECLARE pastprob_cnt = i4 WITH protect, noconstant(0)
 DECLARE preg_cnt = i4 WITH protect, noconstant(0)
 DECLARE proc_cnt = i4 WITH protect, noconstant(0)
 DECLARE med_cnt = i4 WITH protect, noconstant(0)
 DECLARE inter_dt_tm = dq8 WITH protect
 DECLARE x11 = vc WITH protect, noconstant(fillstring(11," "))
 DECLARE x9 = vc WITH protect, noconstant(fillstring(9," "))
 DECLARE shx_cnt = i4 WITH protect, noconstant(0)
 DECLARE shx_idx = i4 WITH protect, noconstant(0)
 DECLARE det_cnt = i4 WITH protect, noconstant(0)
 DECLARE det_idx = i4 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE data_text_line_max_length = i4 WITH protect, noconstant(50)
 DECLARE title_column = i4 WITH protect, noconstant(50)
 DECLARE prsnl_column = i4 WITH protect, noconstant(40)
 DECLARE xr_char_size8_in_inches = f8 WITH protect, constant(0.0695)
 DECLARE xr_char_size9_in_inches = f8 WITH protect, constant(0.0807)
 DECLARE xr_char_size10_in_inches = f8 WITH protect, constant(0.0850)
 DECLARE xr_char_size11_in_inches = f8 WITH protect, constant(0.0950)
 DECLARE xr_char_size12_in_inches = f8 WITH protect, constant(0.1042)
 DECLARE xr_min_line_length = i4 WITH protect, constant(70)
 DECLARE first_text_column = i4 WITH protect, constant(50)
 DECLARE gravidaval = vc WITH protect, noconstant(fillstring(2," "))
 DECLARE fulltermval = vc WITH protect, noconstant(fillstring(2," "))
 DECLARE parapretermval = vc WITH protect, noconstant(fillstring(2," "))
 DECLARE abortedval = vc WITH protect, noconstant(fillstring(2," "))
 DECLARE livingval = vc WITH protect, noconstant(fillstring(2," "))
 RECORD blob(
   1 line = vc
   1 cnt = i2
   1 qual[*]
     2 line = vc
     2 sze = i4
 )
 RECORD r_print(
   1 line_cnt = i2
   1 lns[*]
     2 line = vc
 )
 RECORD pt(
   1 line_cnt = i2
   1 lns[*]
     2 line = vc
 )
 IF (validate(request->debug_ind))
  IF ((request->debug_ind=1))
   SET debug_ind = request->debug_ind
   CALL echo("*DEBUG MODE - ON - in CP_POWERFORMS_CHART_IMPL*")
  ENDIF
 ENDIF
 CALL xrtextlinesizecaculations(null)
 SELECT INTO "nl"
  FROM person p
  WHERE p.person_id=person_id
   AND p.active_ind=1
  HEAD p.person_id
   pat_name = trim(p.name_full_formatted), birth_temp->birth_temp_dt = p.birth_dt_tm, birth_temp->
   birth_temp_tz = p.birth_tz
  WITH nocounter
 ;end select
 FOR (frcnt = 1 TO flist->fref_cnt)
  SET dcp_forms_ref_id = flist->fref_l[frcnt].dcp_forms_ref_id
  FOR (facnt = 1 TO flist->fref_l[frcnt].fact_cnt)
    SET dcp_forms_activity_id = flist->fref_l[frcnt].fact_l[facnt].dcp_forms_activity_id
    SET version_dt_tm = cnvtdatetime(flist->fref_l[frcnt].fact_l[facnt].version_dt_tm)
    SET form_cnt = (form_cnt+ 1)
    SET stat = alterlist(form_temp->forms,form_cnt)
    SET form_temp->forms[form_cnt].dcp_forms_activity_id = dcp_forms_activity_id
    SET form_temp->forms[form_cnt].form_start_line_idx = (ln+ 1)
    EXECUTE FROM init_temp_begin TO init_temp_end
    EXECUTE dcp_get_forms_activity_prt
    IF ((reply->status_data.status="F"))
     SET frms_failure_ind = 1
     SET reply->status_data.subeventstatus[1].operationname = "EXECUTION"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "dcp_get_forms_activity_prt"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
      "dcp_get_forms_activity_prt failed in CP_POWERFORMS_CHART_IMPL - dcp_forms_activity_id = ",
      build(dcp_forms_activity_id))
     CALL echo("*Failed - dcp_get_forms_activity_prt in CP_POWERFORMS_CHART_IMPL*")
    ELSE
     SET frms_failure_ind = 0
    ENDIF
    IF (debug_ind=1)
     CALL echo("*BEGIN DEBUG*")
     CALL echo(build("frms_failure_ind is: ",frms_failure_ind))
     CALL echorecord(reply)
     IF (validate(flist)=1)
      CALL echorecord(flist)
     ENDIF
     CALL echo("*END DEBUG*")
    ENDIF
    EXECUTE FROM print_act_begin TO print_act_end
    FREE RECORD temp
    SET form_temp->forms[form_cnt].form_total_line = ((ln - form_temp->forms[form_cnt].
    form_start_line_idx)+ 1)
    SET errcode = error(errmsg,0)
    IF (errcode > 0)
     CALL echo(errmsg)
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = "EXECUTION"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "cp_powerforms_chart_impl"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = concat("dcp_forms_activity_id = ",
      build(dcp_forms_activity_id))
     IF (debug_ind=1)
      CALL echo("*BEGIN DEBUG*")
      CALL echorecord(reply)
      IF (validate(flist)=1)
       CALL echorecord(flist)
      ENDIF
      CALL echo("*END DEBUG*")
     ENDIF
     GO TO exit_script
    ENDIF
  ENDFOR
 ENDFOR
 SET reply->num_lines = ln
 IF (frms_failure_ind=1)
  SET reply->status_data.status = "S"
 ENDIF
 GO TO exit_script
#init_temp_begin
 RECORD temp(
   1 dcp_forms_ref_id = f8
   1 description = vc
   1 sect_cnt = i2
   1 person_id = f8
   1 encntr_id = f8
   1 sl[*]
     2 dcp_section_ref_id = f8
     2 dcp_section_instance_id = f8
     2 description = vc
     2 ind = i2
     2 section_seq = i4
     2 section_event_id = f8
     2 input_cnt = i2
     2 il[*]
       3 dcp_input_ref_id = f8
       3 description = vc
       3 input_ref_seq = i4
       3 input_type = i4
       3 module = c20
       3 length = i4
       3 date = dq8
       3 valid_date = dq8
       3 status_ind = i2
       3 doc = vc
       3 ind = i2
       3 event_tag = vc
       3 event_tag2 = vc
       3 event_tag3 = vc
       3 unit = vc
       3 label = vc
       3 list_ln_cnt = i2
       3 list_tag[*]
         4 list_line = vc
       3 note_ind = i2
       3 event_id = f8
       3 note_text = vc
       3 note_cnt = i2
       3 note_qual[*]
         4 note_line = vc
       3 task_assay_cd = f8
       3 event_cd = f8
       3 parent_event_id = f8
       3 nom_cnt = i2
       3 nom_qual[*]
         4 nom_line = vc
       3 cnt = i2
       3 qual[*]
         4 line = vc
         4 label = vc
         4 list_ln_cnt = i2
         4 list_tag[*]
           5 list_line = vc
         4 nom_cnt = i2
         4 nom_qual[*]
           5 nom_line = vc
       3 grid_cnt = i2
       3 grid_qual[*]
         4 event_tag = vc
         4 event_tag2 = vc
         4 ind = i2
         4 doc = vc
         4 date = dq8
         4 label = vc
         4 label_ln_cnt = i2
         4 label_list_tag[*]
           5 label_list_line = vc
         4 length = i4
         4 event_id = f8
         4 status_ind = i2
         4 note_ind = i2
         4 note_text = vc
         4 note_cnt = i2
         4 note_qual[*]
           5 note_line = vc
         4 nom_cnt = i2
         4 nom_qual[*]
           5 nom_line = vc
         4 list_ln_cnt = i2
         4 list_tag[*]
           5 list_line = vc
         4 section = i4
         4 cnt = i2
         4 qual[*]
           5 event_tag = vc
           5 event_tag2 = vc
           5 event_tag3 = vc
           5 ind = i2
           5 doc = vc
           5 date = dq8
           5 label = vc
           5 label_ln_cnt = i2
           5 label_list_tag[*]
             6 label_list_line = vc
           5 length = i4
           5 event_id = f8
           5 status_ind = i2
           5 note_ind = i2
           5 note_text = vc
           5 note_cnt = i2
           5 note_qual[*]
             6 note_line = vc
           5 nom_cnt = i2
           5 nom_qual[*]
             6 nom_line = vc
           5 list_ln_cnt = i2
           5 list_tag[*]
             6 list_line = vc
           5 cell_result = i4
           5 collating_seq = i4
         4 row_result = i4
       3 pvc_name = vc
       3 pvc_value = vc
       3 val_cnt = i2
       3 val_qual[*]
         4 pvc_name = vc
         4 pvc_value = vc
       3 allergy_cnt = i2
       3 allergy_restricted_ind = i2
       3 allergy_qual[*]
         4 a_inst_id = f8
         4 list = vc
         4 alist_ln_cnt = i2
         4 alist_tag[*]
           5 alist_line = vc
         4 reaction_cnt = i2
         4 reaction_qual[*]
           5 rlist = vc
           5 rlist_ln_cnt = i2
           5 rlist_tag[*]
             6 rlist_line = vc
         4 date = dq8
         4 note_ind = i2
         4 note_cnt = i2
         4 note_qual[*]
           5 note_text = vc
           5 note_ln_cnt = i2
           5 nlist_tag[*]
             6 note_line = vc
       3 med_profile_restricted_ind = i2
       3 med_profile_qual[*]
         4 hna_order_mnemonic = vc
         4 hna_order_tag_list[*]
           5 order_tag = vc
         4 order_detail_display_line = vc
         4 order_detail_tag_list[*]
           5 order_detail_tag = vc
       3 problem_list_restricted_ind = i2
       3 problem_list[*]
         4 problem_desc = vc
         4 problem_tag[*]
           5 problem_line = vc
         4 onset_dt_tm = dq8
         4 onset_dt_flag = i2
         4 onset_dt_tm_str = vc
         4 problem_recorder = vc
         4 qualifier_cd = f8
         4 qualifier_disp = vc
         4 confirmation_cd = f8
         4 confirmation_disp = vc
         4 problem_onset_tz = i4
         4 problem_status_disp = vc
       3 diagnosis[*]
         4 diagnosis_desc = vc
         4 diagnosis_tag[*]
           5 diagnosis_line = vc
         4 diagnosis_onset_dt = dq8
         4 diagnosis_onset_dtstr = vc
         4 diagnosis_type_cd = f8
         4 diagnosis_type_disp = vc
         4 diagnosis_qualifier_cd = f8
         4 diagnosis_qualifier_disp = vc
         4 diagnosis_confirmation_cd = f8
         4 diagnosis_confirmation_disp = vc
         4 diagnosis_tz = i4
       3 gestational[*]
         4 gest_age_at_birth_week = i4
         4 gest_age_at_birth_days = i4
         4 gest_age_method = vc
         4 gest_age_concat = vc
         4 gest_comment = vc
         4 gest_tag[*]
           5 gest_line = vc
       3 tracking_cmt[*]
         4 comment_seq = i4
         4 comment_lbl = vc
         4 comment_visible = i2
         4 tracking_comment = vc
         4 tracking_tag[*]
           5 tracking_line = vc
       3 med_list[*]
         4 reference_name = vc
         4 name_lines[*]
           5 name_line = vc
         4 display_line = vc
         4 display_lines[*]
           5 display_ln = vc
         4 comment = vc
         4 comment_lines[*]
           5 comment_line = vc
         4 provider_id = f8
         4 provider_name = vc
         4 order_tz = i4
         4 order_dt_tm_str = vc
         4 order_status = vc
         4 medication_order_type_cd = f8
         4 originally_ordered_as_type
           5 normal_ind = i2
           5 prescription_ind = i2
           5 documented_ind = i2
           5 patients_own_ind = i2
           5 charge_only_ind = i2
           5 satellite_ind = i2
         4 med_type_ind = i2
       3 order_compliance[*]
         4 no_known_home_meds_ind = i2
         4 unable_to_obtain_ind = i2
         4 performed_by_name = vc
         4 performed_dt_tm_str = vc
       3 past_prob_list_restricted_ind = i2
       3 past_prob_list[*]
         4 prob_desc = vc
         4 prob_lines[*]
           5 prob_line = vc
         4 voca_cd_meaning = vc
         4 source_identifier = vc
         4 onset_year = vc
         4 onset_age = vc
         4 life_cycle_status_disp = vc
         4 comments[*]
           5 comment_dt_tm_str = vc
           5 comment_prsnl_name = vc
           5 comment = vc
           5 comment_lines[*]
             6 comment_line = vc
       3 entire_fam_hist_ind = i2
       3 fam_list_restricted_ind = i2
       3 fam_members[*]
         4 related_person_id = f8
         4 memb_entire_hist_ind = i2
         4 memb_name = vc
         4 reltn_disp = vc
         4 name_lines[*]
           5 aline = vc
         4 deceased_cd = f8
         4 cause_of_death = vc
         4 age_at_death_str = vc
         4 age_at_death_unit_disp = vc
         4 memb_birth_dt_tm = dq8
         4 conditions[*]
           5 fhx_value_flag = i2
           5 source_string = vc
           5 src_str_lines[*]
             6 aline = vc
           5 onset_age = i4
           5 onset_age_unit_disp = vc
           5 onset_age_unit_cd_mean = vc
           5 onset_year = i4
           5 onset_lines[*]
             6 aline = vc
           5 condition_status = vc
           5 comments[*]
             6 comment_prsnl_name = vc
             6 comment_dt_tm_str = vc
             6 comment = vc
             6 comment_lines[*]
               7 line = vc
       3 proc_list_restricted_ind = i2
       3 proc_list[*]
         4 proc_id = f8
         4 proc_desc = vc
         4 proc_lines[*]
           5 proc_line = vc
         4 voca_cd_meaning = vc
         4 source_identifier = vc
         4 proc_year = i4
         4 age_at_proc = vc
         4 proc_prsnl_name = vc
         4 proc_location = vc
         4 perform_lines[*]
           5 aline = vc
         4 comments[*]
           5 comment_dt_tm_str = vc
           5 comment_prsnl_name = vc
           5 comment = vc
           5 comment_lines[*]
             6 comment_line = vc
       3 pregnancies_restricted_ind = i2
       3 pregnancies[*]
         4 preg_start_dt_tm_str = vc
         4 preg_end_dt_tm_str = vc
         4 child_list[*]
           5 gestation_age_in_weeks = i4
           5 gestation_age_in_days = i4
           5 child_name = vc
           5 gender_disp = vc
           5 delivery_dt_tm_str = vc
           5 delivery_date_precision_flag = i2
           5 delivery_hospital = vc
           5 delivery_method_disp = vc
           5 anesthesia_disp = vc
           5 birth_weight_disp = vc
           5 preterm_labor_disp = vc
           5 father_name = vc
           5 neonate_outcome_disp = vc
           5 ma_comp_list[*]
             6 complication_disp = vc
           5 fetus_comp_list[*]
             6 complication_disp = vc
           5 neo_comp_list[*]
             6 complication_disp = vc
           5 preterm_labors[*]
             6 preterm_labor = vc
           5 data_str_lines[*]
             6 aline = vc
           5 gestation_term_txt = vc
         4 auto_close_ind = i2
       3 gravida[*]
         4 gravida = i4
         4 fullterm = i4
         4 parapreterm = i4
         4 aborted = i4
         4 living = i4
       3 shx_unable_to_obtain_ind = i2
       3 social_cat_list_restricted_ind = i2
       3 social_cat_list[*]
         4 shx_cat_ref_id = f8
         4 desc = vc
         4 desc_lines[*]
           5 desc_line = vc
         4 assessment_disp = vc
         4 last_updt_prsnl = vc
         4 last_updt_dt_tm = vc
         4 detail_list[*]
           5 shx_activity_grp_id = f8
           5 detail_disp = vc
           5 disp_lines[*]
             6 aline = vc
           5 detail_updt_prsnl = vc
           5 detail_updt_dt_tm = vc
           5 comments[*]
             6 comment_dt_tm = vc
             6 comment_prsnl = vc
             6 comment = vc
             6 comment_lines[*]
               7 aline = vc
       3 comm_pref_list[*]
         4 contact_method_cd = f8
         4 secure_email = vc
         4 desc = vc
         4 desc_lines[*]
           5 desc_line = vc
   1 updated_prsnl[*]
     2 prsnl_id = f8
     2 prsnl_ft = vc
     2 proxy_prsnl_id = f8
     2 proxy_prsnl_ft = vc
     2 update_dt_tm = dq8
     2 activity_tz = i4
     2 update_dt_str = vc
     2 update_qual[*]
       3 update_wrap_str = vc
   1 performed_prsnl_ft = vc
   1 performed_proxy_id = f8
   1 performed_proxy_ft = vc
   1 performed_dt_tm = dq8
   1 performed_tz = i4
   1 performed_dt_str = vc
   1 performed_qual[*]
     2 perform_wrap_str = vc
   1 time_zone_ind = i2
   1 entered_dt_tm = dq8
   1 entered_tz = i4
   1 entered_dt_str = vc
   1 prsnl_ind = i2
   1 last_updt_dt_tm = dq8
   1 last_updt_prsnl = vc
   1 last_updt_str = vc
   1 performed_prsnl_id = f8
   1 form_status_cd = f8
   1 person_prsnl_r_cd = f8
   1 prsnl_position_cd = f8
 )
#init_temp_end
#print_act_begin
 FOR (z = 1 TO temp->sect_cnt)
   FOR (y = 1 TO temp->sl[z].input_cnt)
     SET max_length = data_text_line_max_length
     IF ((temp->sl[z].il[y].input_type IN (22, 2, 4, 6, 7,
     9, 10, 18, 23))
      AND trim(temp->sl[z].il[y].module)=" ")
      SET pt->line_cnt = 0
      EXECUTE dcp_parse_text value(temp->sl[z].il[y].event_tag), value(max_length)
      SET stat = alterlist(temp->sl[z].il[y].list_tag,pt->line_cnt)
      SET temp->sl[z].il[y].list_ln_cnt = pt->line_cnt
      FOR (x = 1 TO pt->line_cnt)
        SET temp->sl[z].il[y].list_tag[x].list_line = pt->lns[x].line
      ENDFOR
     ENDIF
     IF ((((temp->sl[z].il[y].input_type=5)) OR ((((temp->sl[z].il[y].input_type=1)) OR ((temp->sl[z]
     .il[y].input_type=2)))
      AND trim(temp->sl[z].il[y].module)="PVTRACKFORMS")) )
      FOR (w = 1 TO temp->sl[z].il[y].cnt)
        SET pt->line_cnt = 0
        EXECUTE dcp_parse_text value(temp->sl[z].il[y].qual[w].line), value(max_length)
        SET stat = alterlist(temp->sl[z].il[y].qual[w].list_tag,pt->line_cnt)
        SET temp->sl[z].il[y].qual[w].list_ln_cnt = pt->line_cnt
        FOR (x = 1 TO pt->line_cnt)
          SET temp->sl[z].il[y].qual[w].list_tag[x].list_line = pt->lns[x].line
        ENDFOR
      ENDFOR
     ENDIF
     IF ((temp->sl[z].il[y].input_type=11))
      FOR (w = 1 TO temp->sl[z].il[y].allergy_cnt)
        SET pt->line_cnt = 0
        EXECUTE dcp_parse_text value(temp->sl[z].il[y].allergy_qual[w].list), value(42)
        SET stat = alterlist(temp->sl[z].il[y].allergy_qual[w].alist_tag,pt->line_cnt)
        SET temp->sl[z].il[y].allergy_qual[w].alist_ln_cnt = pt->line_cnt
        FOR (x = 1 TO pt->line_cnt)
          SET temp->sl[z].il[y].allergy_qual[w].alist_tag[x].alist_line = pt->lns[x].line
        ENDFOR
        FOR (v = 1 TO temp->sl[z].il[y].allergy_qual[w].reaction_cnt)
          IF ((temp->sl[z].il[y].allergy_qual[w].reaction_qual[v].rlist > " "))
           SET pt->line_cnt = 0
           EXECUTE dcp_parse_text value(temp->sl[z].il[y].allergy_qual[w].reaction_qual[v].rlist),
           value(max_length)
           SET stat = alterlist(temp->sl[z].il[y].allergy_qual[w].reaction_qual[v].rlist_tag,pt->
            line_cnt)
           SET temp->sl[z].il[y].allergy_qual[w].reaction_qual[v].rlist_ln_cnt = pt->line_cnt
           FOR (x = 1 TO pt->line_cnt)
             SET temp->sl[z].il[y].allergy_qual[w].reaction_qual[v].rlist_tag[x].rlist_line = pt->
             lns[x].line
           ENDFOR
          ENDIF
        ENDFOR
      ENDFOR
     ENDIF
     IF (trim(temp->sl[z].il[y].module)="PFEXTCTRLS")
      IF ((temp->sl[z].il[y].input_type=problemdx_control))
       SET prob_count = size(temp->sl[z].il[y].problem_list,5)
       FOR (w = 1 TO prob_count)
         CALL problem_formatting(z,y,w)
       ENDFOR
       SET dx_count = size(temp->sl[z].il[y].diagnosis,5)
       FOR (w = 1 TO dx_count)
         CALL dx_formatting(z,y,w)
       ENDFOR
      ENDIF
      IF ((temp->sl[z].il[y].input_type=medlist_control))
       SET med_cnt = size(temp->sl[z].il[y].med_list,5)
       FOR (w = 1 TO med_cnt)
         CALL medlist_refname_formatting(z,y,w)
         CALL medlist_comment_formatting(z,y,w)
         CALL medlist_displayln_formatting(z,y,w)
       ENDFOR
      ENDIF
      IF ((temp->sl[z].il[y].input_type=pregnancyhistory_control))
       SET preg_cnt = size(temp->sl[z].il[y].pregnancies,5)
       FOR (w = 1 TO preg_cnt)
         CALL preg_data_str_formatting(z,y,w)
       ENDFOR
      ENDIF
      IF ((temp->sl[z].il[y].input_type=procedurehistory_control))
       SET proc_cnt = size(temp->sl[z].il[y].proc_list,5)
       FOR (w = 1 TO proc_cnt)
        CALL proc_term_formatting(z,y,w)
        CALL proc_comment_formatting(z,y,w)
       ENDFOR
      ENDIF
      IF ((temp->sl[z].il[y].input_type=pastmedhistory_control))
       SET pastprob_cnt = size(temp->sl[z].il[y].past_prob_list,5)
       FOR (w = 1 TO pastprob_cnt)
        CALL past_prob_formatting(z,y,w)
        CALL past_prob_comment_formatting(z,y,w)
       ENDFOR
      ENDIF
      IF ((temp->sl[z].il[y].input_type=familyhistory_control))
       SET memb_cnt = size(temp->sl[z].il[y].fam_members,5)
       FOR (memb_idx = 1 TO memb_cnt)
         CALL family_history_name_str_formatting(z,y,memb_idx)
         SET cond_cnt = size(temp->sl[z].il[y].fam_members[memb_idx].conditions,5)
         FOR (cond_idx = 1 TO cond_cnt)
           SET birth_dt_tm_parameter = cnvtdatetime(temp->sl[z].il[y].fam_members[memb_idx].
            memb_birth_dt_tm)
           SET temp->sl[z].il[y].fam_members[memb_idx].conditions[cond_idx].onset_year =
           calculate_onset_year(temp->sl[z].il[y].fam_members[memb_idx].conditions[cond_idx].
            onset_age,temp->sl[z].il[y].fam_members[memb_idx].conditions[cond_idx].
            onset_age_unit_cd_mean)
           CALL family_history_condition_str_formatting(z,y,memb_idx,cond_idx)
         ENDFOR
       ENDFOR
      ENDIF
      IF ((temp->sl[z].il[y].input_type=socialhistory_control))
       FOR (w = 1 TO size(temp->sl[z].il[y].social_cat_list,5))
         CALL social_data_str_formatting(z,y,w)
       ENDFOR
      ENDIF
      IF ((temp->sl[z].il[y].input_type=communicationpreference_control))
       FOR (w = 1 TO size(temp->sl[z].il[y].comm_pref_list,5))
         CALL communication_preference_str_formatting(z,y,w)
       ENDFOR
      ENDIF
     ENDIF
     IF (trim(temp->sl[z].il[y].module)="PFPMCtrls")
      IF ((temp->sl[z].il[y].input_type=1))
       FOR (w = 1 TO size(temp->sl[z].il[y].gestational,5))
         CALL gest_formatting(z,y,w)
       ENDFOR
      ENDIF
      IF ((temp->sl[z].il[y].input_type=2))
       FOR (w = 1 TO size(temp->sl[z].il[y].tracking_cmt,5))
         CALL encntr_formatting(z,y,w)
       ENDFOR
      ENDIF
     ENDIF
     IF ((temp->sl[z].il[y].input_type=15))
      FOR (w = 1 TO temp->sl[z].il[y].grid_cnt)
        SET pt->line_cnt = 0
        EXECUTE dcp_parse_text value(temp->sl[z].il[y].grid_qual[w].event_tag), value(max_length)
        SET stat = alterlist(temp->sl[z].il[y].grid_qual[w].list_tag,pt->line_cnt)
        SET temp->sl[z].il[y].grid_qual[w].list_ln_cnt = pt->line_cnt
        FOR (x = 1 TO pt->line_cnt)
          SET temp->sl[z].il[y].grid_qual[w].list_tag[x].list_line = pt->lns[x].line
        ENDFOR
      ENDFOR
     ENDIF
     IF ((temp->sl[z].il[y].input_type=14))
      FOR (w = 1 TO temp->sl[z].il[y].grid_cnt)
        SET pt->line_cnt = 0
        SET max_length = 77
        SET labl_length = size(temp->sl[z].il[y].grid_qual[w].label)
        CALL wrap_text(temp->sl[z].il[y].grid_qual[w].event_tag,((max_length - 7) - labl_length),(
         max_length - 10))
        SET stat = alterlist(temp->sl[z].il[y].grid_qual[w].list_tag,pt->line_cnt)
        SET temp->sl[z].il[y].grid_qual[w].list_ln_cnt = pt->line_cnt
        FOR (x = 1 TO pt->line_cnt)
          SET temp->sl[z].il[y].grid_qual[w].list_tag[x].list_line = pt->lns[x].line
        ENDFOR
      ENDFOR
     ENDIF
     IF ((temp->sl[z].il[y].input_type=13))
      SET pt->line_cnt = 0
      SET labl_length = size(temp->sl[z].il[y].description)
      CALL wrap_text(temp->sl[z].il[y].event_tag,data_text_line_max_length,data_text_line_max_length)
      SET stat = alterlist(temp->sl[z].il[y].list_tag,pt->line_cnt)
      SET temp->sl[z].il[y].list_ln_cnt = pt->line_cnt
      FOR (x = 1 TO pt->line_cnt)
        SET temp->sl[z].il[y].list_tag[x].list_line = pt->lns[x].line
      ENDFOR
     ENDIF
     IF ((temp->sl[z].il[y].input_type IN (17, 19)))
      FOR (w = 1 TO temp->sl[z].il[y].grid_cnt)
        FOR (q = 1 TO temp->sl[z].il[y].grid_qual[w].cnt)
          SET pt->line_cnt = 0
          SET max_length = data_text_line_max_length
          EXECUTE dcp_parse_text value(temp->sl[z].il[y].grid_qual[w].qual[q].event_tag), value(
           max_length)
          SET stat = alterlist(temp->sl[z].il[y].grid_qual[w].qual[q].list_tag,pt->line_cnt)
          SET temp->sl[z].il[y].grid_qual[w].qual[q].list_ln_cnt = pt->line_cnt
          FOR (x = 1 TO pt->line_cnt)
            SET temp->sl[z].il[y].grid_qual[w].qual[q].list_tag[x].list_line = pt->lns[x].line
          ENDFOR
        ENDFOR
      ENDFOR
     ENDIF
   ENDFOR
 ENDFOR
 SET x11 = fillstring(11," ")
 SET x9 = fillstring(9," ")
 FOR (z = 1 TO temp->sect_cnt)
   FOR (y = 1 TO temp->sl[z].input_cnt)
     IF ((temp->sl[z].il[y].input_type=11))
      IF ((temp->sl[z].il[y].note_ind=1))
       FOR (x = 1 TO temp->sl[z].il[y].allergy_cnt)
         IF ((temp->sl[z].il[y].allergy_qual[x].note_ind=1))
          FOR (w = 1 TO temp->sl[z].il[y].allergy_qual[x].note_cnt)
            IF ((temp->sl[z].il[y].allergy_qual[x].note_qual[w].note_text > " "))
             SET temp->sl[z].il[y].allergy_qual[x].note_qual[w].note_text = concat(captions->scomment,
              ": ",trim(temp->sl[z].il[y].allergy_qual[x].note_qual[w].note_text))
             SET pt->line_cnt = 0
             SET max_length = data_text_line_max_length
             EXECUTE dcp_parse_text value(temp->sl[z].il[y].allergy_qual[x].note_qual[w].note_text),
             value(max_length)
             SET stat = alterlist(temp->sl[z].il[y].allergy_qual[x].note_qual[w].nlist_tag,pt->
              line_cnt)
             SET temp->sl[z].il[y].allergy_qual[x].note_qual[w].note_ln_cnt = pt->line_cnt
             FOR (v = 1 TO pt->line_cnt)
               IF (v=1)
                SET temp->sl[z].il[y].allergy_qual[x].note_qual[w].nlist_tag[v].note_line = pt->lns[v
                ].line
               ELSE
                SET temp->sl[z].il[y].allergy_qual[x].note_qual[w].nlist_tag[v].note_line = concat(x9,
                 pt->lns[v].line)
               ENDIF
             ENDFOR
            ENDIF
          ENDFOR
         ENDIF
       ENDFOR
      ENDIF
     ENDIF
     IF ((((temp->sl[z].il[y].input_type IN (22, 2, 4, 5, 6,
     7, 9, 10, 13, 14,
     15, 18, 17, 19, 23))) OR ((temp->sl[z].il[y].module="PVTRACKFORMS"))) )
      SET pt->line_cnt = 0
      SET max_length = 50
      IF ((temp->sl[z].il[y].note_ind=1))
       IF ((temp->sl[z].il[y].note_text > " "))
        SET temp->sl[z].il[y].note_text = concat(captions->scomment,": ",trim(temp->sl[z].il[y].
          note_text))
       ENDIF
       EXECUTE dcp_parse_text value(temp->sl[z].il[y].note_text), value(max_length)
       SET stat = alterlist(temp->sl[z].il[y].note_qual,pt->line_cnt)
       SET temp->sl[z].il[y].note_cnt = pt->line_cnt
       FOR (x = 1 TO pt->line_cnt)
         IF (x=1)
          SET temp->sl[z].il[y].note_qual[x].note_line = pt->lns[x].line
         ELSE
          SET temp->sl[z].il[y].note_qual[x].note_line = concat(x11,pt->lns[x].line)
         ENDIF
       ENDFOR
      ENDIF
     ENDIF
     IF ((temp->sl[z].il[y].input_type IN (15, 17, 19)))
      FOR (w = 1 TO temp->sl[z].il[y].grid_cnt)
        IF ((temp->sl[z].il[y].grid_qual[w].note_ind=1))
         SET pt->line_cnt = 0
         SET max_length = 50
         IF ((temp->sl[z].il[y].grid_qual[w].note_text > " "))
          SET temp->sl[z].il[y].grid_qual[w].note_text = concat(captions->scomment,": ",trim(temp->
            sl[z].il[y].grid_qual[w].note_text))
         ENDIF
         EXECUTE dcp_parse_text value(temp->sl[z].il[y].grid_qual[w].note_text), value(max_length)
         SET stat = alterlist(temp->sl[z].il[y].grid_qual[w].note_qual,pt->line_cnt)
         SET temp->sl[z].il[y].grid_qual[w].note_cnt = pt->line_cnt
         FOR (x = 1 TO pt->line_cnt)
           IF (x=1)
            SET temp->sl[z].il[y].grid_qual[w].note_qual[x].note_line = pt->lns[x].line
           ELSE
            SET temp->sl[z].il[y].grid_qual[w].note_qual[x].note_line = concat(x11,pt->lns[x].line)
           ENDIF
         ENDFOR
        ENDIF
      ENDFOR
     ENDIF
     IF ((temp->sl[z].il[y].input_type=14))
      FOR (w = 1 TO temp->sl[z].il[y].grid_cnt)
        IF ((temp->sl[z].il[y].grid_qual[w].note_ind=1))
         SET pt->line_cnt = 0
         SET max_length = 77
         IF ((temp->sl[z].il[y].grid_qual[w].note_text > " "))
          SET temp->sl[z].il[y].grid_qual[w].note_text = concat(captions->scomment,": ",trim(temp->
            sl[z].il[y].grid_qual[w].note_text))
         ENDIF
         CALL wrap_text(temp->sl[z].il[y].grid_qual[w].note_text,(max_length - 7),(max_length - 10))
         SET stat = alterlist(temp->sl[z].il[y].grid_qual[w].note_qual,pt->line_cnt)
         SET temp->sl[z].il[y].grid_qual[w].note_cnt = pt->line_cnt
         FOR (x = 1 TO pt->line_cnt)
           IF (x=1)
            SET temp->sl[z].il[y].grid_qual[w].note_qual[x].note_line = pt->lns[x].line
           ELSE
            SET temp->sl[z].il[y].grid_qual[w].note_qual[x].note_line = concat(x11,pt->lns[x].line)
           ENDIF
         ENDFOR
        ENDIF
      ENDFOR
     ENDIF
     IF ((temp->sl[z].il[y].input_type IN (17, 19)))
      FOR (w = 1 TO temp->sl[z].il[y].grid_cnt)
        FOR (q = 1 TO temp->sl[z].il[y].grid_qual[w].cnt)
          IF ((temp->sl[z].il[y].grid_qual[w].qual[q].note_ind=1))
           SET pt->line_cnt = 0
           SET max_length = data_text_line_max_length
           IF ((temp->sl[z].il[y].grid_qual[w].qual[q].note_text > " "))
            SET temp->sl[z].il[y].grid_qual[w].qual[q].note_text = concat(captions->scomment,": ",
             trim(temp->sl[z].il[y].grid_qual[w].qual[q].note_text))
           ENDIF
           EXECUTE dcp_parse_text value(temp->sl[z].il[y].grid_qual[w].qual[q].note_text), value(
            max_length)
           SET stat = alterlist(temp->sl[z].il[y].grid_qual[w].qual[q].note_qual,pt->line_cnt)
           SET temp->sl[z].il[y].grid_qual[w].qual[q].note_cnt = pt->line_cnt
           FOR (x = 1 TO pt->line_cnt)
             IF (x=1)
              SET temp->sl[z].il[y].grid_qual[w].qual[q].note_qual[x].note_line = pt->lns[x].line
             ELSE
              SET temp->sl[z].il[y].grid_qual[w].qual[q].note_qual[x].note_line = concat(x11,pt->lns[
               x].line)
             ENDIF
           ENDFOR
          ENDIF
        ENDFOR
      ENDFOR
     ENDIF
   ENDFOR
 ENDFOR
 SET inter_dt_tm = cnvtdatetime(curdate,curtime3)
 SET captions->sprintdt = format(inter_dt_tm,"@SHORTDATE;;Q")
 SET captions->sprinttm = format(inter_dt_tm,"@TIMENOSECONDS;;Q")
 SELECT
  FROM (dummyt d1  WITH seq = 1)
  PLAN (d1)
  HEAD REPORT
   ">>>", row + 1, col title_column,
   temp->description, row + 1
   IF (frms_failure_ind=1)
    col title_column, captions->sformactprtfail, row + 1
   ENDIF
   IF ((temp->prsnl_ind=0))
    col prsnl_column, temp->last_updt_str, row + 1
   ELSE
    col prsnl_column, temp->performed_dt_str, row + 1,
    col prsnl_column, temp->entered_dt_str, row + 1
   ENDIF
   "<<<", row + 1, xcol = 30,
   updt_list_cnt = size(temp->updated_prsnl,5)
   IF (updt_list_cnt > 0)
    ">>", row + 1, col 1,
    captions->supdatedon, row + 1, "<<",
    row + 1
    FOR (updt_cnt = 1 TO updt_list_cnt)
      reverse_cnt = ((updt_list_cnt - updt_cnt)+ 1), col 10, temp->updated_prsnl[reverse_cnt].
      update_dt_str,
      row + 1
    ENDFOR
   ENDIF
  DETAIL
   FOR (x = 1 TO temp->sect_cnt)
    IF ((temp->sl[x].ind=1))
     col 0, ">>", row + 1,
     col 1, temp->sl[x].description, row + 1,
     "<<", row + 1
    ENDIF
    ,
    FOR (y = 1 TO temp->sl[x].input_cnt)
      IF ((temp->sl[x].il[y].input_type IN (22, 2, 4, 6, 7,
      9, 10, 13, 18, 23))
       AND trim(temp->sl[x].il[y].module)=" ")
       IF ((temp->sl[x].il[y].ind=1))
        col 1, temp->sl[x].il[y].description
        FOR (z = 1 TO temp->sl[x].il[y].list_ln_cnt)
          col 49, temp->sl[x].il[y].list_tag[z].list_line, row + 1
        ENDFOR
        IF ((temp->sl[x].il[y].note_ind=1))
         FOR (w = 1 TO temp->sl[x].il[y].note_cnt)
           col 49, temp->sl[x].il[y].note_qual[w].note_line, row + 1
         ENDFOR
        ENDIF
       ENDIF
      ENDIF
      IF ((temp->sl[x].il[y].input_type=5))
       IF ((temp->sl[x].il[y].ind=1))
        col 1, temp->sl[x].il[y].description, row + 1
        FOR (z = 1 TO temp->sl[x].il[y].cnt)
          col 6, temp->sl[x].il[y].qual[z].label
          FOR (w = 1 TO temp->sl[x].il[y].qual[z].list_ln_cnt)
            col 49, temp->sl[x].il[y].qual[z].list_tag[w].list_line, row + 1
          ENDFOR
        ENDFOR
        IF ((temp->sl[x].il[y].note_ind=1))
         FOR (w = 1 TO temp->sl[x].il[y].note_cnt)
           col 49, temp->sl[x].il[y].note_qual[w].note_line, row + 1
         ENDFOR
        ENDIF
       ENDIF
       temp->sl[x].il[y].cnt = 0, temp->sl[x].il[y].ind = 0
      ENDIF
      IF ((temp->sl[x].il[y].input_type=15))
       FOR (p = 1 TO temp->sl[x].il[y].grid_cnt)
         IF ((temp->sl[x].il[y].grid_qual[p].ind=1))
          IF (p=1)
           col 1, temp->sl[x].il[y].label, row + 1
          ENDIF
          col 6, temp->sl[x].il[y].grid_qual[p].label
          FOR (z = 1 TO temp->sl[x].il[y].grid_qual[p].list_ln_cnt)
            col 49, temp->sl[x].il[y].grid_qual[p].list_tag[z].list_line, row + 1
          ENDFOR
          IF ((temp->sl[x].il[y].grid_qual[p].note_ind=1))
           FOR (w = 1 TO temp->sl[x].il[y].grid_qual[p].note_cnt)
             col 49, temp->sl[x].il[y].grid_qual[p].note_qual[w].note_line, row + 1
           ENDFOR
          ENDIF
         ENDIF
       ENDFOR
       IF ((temp->sl[x].il[y].note_ind=1))
        FOR (w = 1 TO temp->sl[x].il[y].note_cnt)
          col 49, temp->sl[x].il[y].note_qual[w].note_line, row + 1
        ENDFOR
       ENDIF
       temp->sl[x].il[y].grid_cnt = 0
      ENDIF
      IF ((temp->sl[x].il[y].input_type=14))
       FOR (p = 1 TO temp->sl[x].il[y].grid_cnt)
         IF ((temp->sl[x].il[y].grid_qual[p].ind=1))
          col 1
          IF (p=1)
           temp->sl[x].il[y].label, row + 1
          ENDIF
          col 6, temp->sl[x].il[y].grid_qual[p].label, labl_length = size(temp->sl[x].il[y].
           grid_qual[p].label),
          call reportmove('COL',(8+ labl_length),0), temp->sl[x].il[y].grid_qual[p].list_tag[1].
          list_line, row + 1
          FOR (z = 2 TO temp->sl[x].il[y].grid_qual[p].list_ln_cnt)
            col 8, temp->sl[x].il[y].grid_qual[p].list_tag[z].list_line, row + 1
          ENDFOR
          IF ((temp->sl[x].il[y].grid_qual[p].note_ind=1))
           FOR (w = 1 TO temp->sl[x].il[y].grid_qual[p].note_cnt)
             col 8, temp->sl[x].il[y].grid_qual[p].note_qual[w].note_line, row + 1
           ENDFOR
          ENDIF
         ENDIF
       ENDFOR
       IF ((temp->sl[x].il[y].note_ind=1))
        FOR (w = 1 TO temp->sl[x].il[y].note_cnt)
          col 6, temp->sl[x].il[y].note_qual[w].note_line, row + 1
        ENDFOR
       ENDIF
       temp->sl[x].il[y].grid_cnt = 0
      ENDIF
      IF ((temp->sl[x].il[y].input_type IN (17, 19)))
       FOR (p = 1 TO temp->sl[x].il[y].grid_cnt)
         IF (p=1)
          col 1, temp->sl[x].il[y].description, row + 1
         ENDIF
         IF ((temp->sl[x].il[y].input_type=19))
          col 6, temp->sl[x].il[y].grid_qual[p].label, row + 1
         ENDIF
         FOR (q = 1 TO temp->sl[x].il[y].grid_qual[p].cnt)
           ln_number = trim(cnvtstring(p))
           IF ((temp->sl[x].il[y].input_type=17)
            AND q=1)
            col 3, ln_number, captions->slnnumberchar,
            " "
           ELSE
            col 6
           ENDIF
           temp->sl[x].il[y].grid_qual[p].qual[q].label
           FOR (z = 1 TO temp->sl[x].il[y].grid_qual[p].qual[q].list_ln_cnt)
             IF ((temp->sl[x].il[y].grid_qual[p].qual[q].list_tag[z].list_line > " "))
              col 49, temp->sl[x].il[y].grid_qual[p].qual[q].list_tag[z].list_line, row + 1
             ENDIF
           ENDFOR
           IF ((temp->sl[x].il[y].grid_qual[p].qual[q].note_ind=1))
            FOR (w = 1 TO temp->sl[x].il[y].grid_qual[p].qual[q].note_cnt)
              col 49, temp->sl[x].il[y].grid_qual[p].qual[q].note_qual[w].note_line, row + 1
            ENDFOR
           ENDIF
         ENDFOR
         IF ((temp->sl[x].il[y].grid_qual[p].note_ind=1))
          FOR (w = 1 TO temp->sl[x].il[y].grid_qual[p].note_cnt)
            col 49, temp->sl[x].il[y].grid_qual[p].note_qual[w].note_line, row + 1
          ENDFOR
         ENDIF
       ENDFOR
       IF ((temp->sl[x].il[y].note_ind=1))
        FOR (w = 1 TO temp->sl[x].il[y].note_cnt)
          col 49, temp->sl[x].il[y].note_qual[w].note_line, row + 1
        ENDFOR
       ENDIF
       temp->sl[x].il[y].grid_cnt = 0
      ENDIF
      IF ((temp->sl[x].il[y].input_type=11))
       col 1, captions->sallergy, col 49,
       captions->sreaction, row + 1
       IF ((temp->sl[x].il[y].allergy_restricted_ind=1))
        col 1, captions->sallallergiesnotview, row + 1
       ENDIF
       FOR (z = 1 TO temp->sl[x].il[y].allergy_cnt)
         rline_cnt = 0, temp_cnt = 0, this_rline_cnt = 0,
         r_print->line_cnt = 0, ln_number = trim(cnvtstring(z))
         FOR (v = 1 TO temp->sl[x].il[y].allergy_qual[z].reaction_cnt)
           this_rline_cnt = temp->sl[x].il[y].allergy_qual[z].reaction_qual[v].rlist_ln_cnt,
           rline_cnt = (rline_cnt+ this_rline_cnt), r_print->line_cnt = rline_cnt
           IF (this_rline_cnt > 0)
            stat = alterlist(r_print->lns,rline_cnt)
            FOR (n = 1 TO this_rline_cnt)
              r_print->lns[(temp_cnt+ n)].line = trim(temp->sl[x].il[y].allergy_qual[z].
               reaction_qual[v].rlist_tag[n].rlist_line)
            ENDFOR
            temp_cnt = rline_cnt
           ENDIF
         ENDFOR
         IF ((r_print->line_cnt >= temp->sl[x].il[y].allergy_qual[z].alist_ln_cnt))
          FOR (w = 1 TO r_print->line_cnt)
            IF ((w <= temp->sl[x].il[y].allergy_qual[z].alist_ln_cnt))
             col 1
             IF (w=1)
              ln_number, captions->slnnumberchar, " "
             ELSE
              "   "
             ENDIF
             temp->sl[x].il[y].allergy_qual[z].alist_tag[w].alist_line
            ENDIF
            col 49, r_print->lns[w].line, row + 1
          ENDFOR
         ELSE
          FOR (w = 1 TO temp->sl[x].il[y].allergy_qual[z].alist_ln_cnt)
            col 1
            IF (w=1)
             ln_number, captions->slnnumberchar, " "
            ELSE
             "   "
            ENDIF
            temp->sl[x].il[y].allergy_qual[z].alist_tag[w].alist_line
            IF ((w <= r_print->line_cnt))
             col 49, r_print->lns[w].line
            ENDIF
            row + 1
          ENDFOR
         ENDIF
         IF ((temp->sl[x].il[y].allergy_qual[z].note_ind=1))
          FOR (w = 1 TO temp->sl[x].il[y].allergy_qual[z].note_cnt)
            FOR (v = 1 TO temp->sl[x].il[y].allergy_qual[z].note_qual[w].note_ln_cnt)
              col 49, temp->sl[x].il[y].allergy_qual[z].note_qual[w].nlist_tag[v].note_line, row + 1
            ENDFOR
          ENDFOR
         ENDIF
         stat = alterlist(r_print->lns,0)
       ENDFOR
       IF ((temp->sl[x].il[y].allergy_cnt=0))
        col 1, captions->snoallergy, row + 1
       ENDIF
      ENDIF
      IF ((((temp->sl[x].il[y].input_type=1)) OR ((temp->sl[x].il[y].input_type=2)))
       AND (temp->sl[x].il[y].module="PVTRACKFORMS"))
       FOR (p = 1 TO temp->sl[x].il[y].cnt)
         IF (p=1)
          col 1, temp->sl[x].il[y].description, row + 1
         ENDIF
         col 1, temp->sl[x].il[y].qual[p].label
         FOR (z = 1 TO temp->sl[x].il[y].qual[p].list_ln_cnt)
           col 49, temp->sl[x].il[y].qual[p].list_tag[z].list_line, row + 1
         ENDFOR
       ENDFOR
       IF ((temp->sl[x].il[y].note_ind=1))
        FOR (w = 1 TO temp->sl[x].il[y].note_cnt)
          col 49, temp->sl[x].il[y].note_qual[w].note_line, row + 1
        ENDFOR
       ENDIF
      ENDIF
      IF ((temp->sl[x].il[y].module="PFPMCtrls"))
       IF ((temp->sl[x].il[y].input_type=1))
        gest_ind_cp = 1, col 1, captions->sgestationage,
        col 49, temp->sl[x].il[y].gestational[gest_ind_cp].gest_age_concat, row + 1,
        col 1, captions->sgestationmethod, col 49,
        temp->sl[x].il[y].gestational[gest_ind_cp].gest_age_method, row + 1, col 1,
        captions->sgestationcomment, gest_comment_size = size(temp->sl[x].il[y].gestational[
         gest_ind_cp].gest_tag,5)
        FOR (gest_comment_idx = 1 TO gest_comment_size)
          col 49, temp->sl[x].il[y].gestational[gest_ind_cp].gest_tag[gest_comment_idx].gest_line,
          row + 1
        ENDFOR
       ENDIF
       IF ((temp->sl[x].il[y].input_type=2))
        FOR (trck_ind_cp = 1 TO size(temp->sl[x].il[y].tracking_cmt,5))
          IF ((temp->sl[x].il[y].tracking_cmt[trck_ind_cp].tracking_comment != " "))
           col 1, temp->sl[x].il[y].tracking_cmt[trck_ind_cp].comment_lbl
           FOR (line_cp = 1 TO size(temp->sl[x].il[y].tracking_cmt[trck_ind_cp].tracking_tag,5))
             col 49, temp->sl[x].il[y].tracking_cmt[trck_ind_cp].tracking_tag[line_cp].tracking_line,
             row + 1
           ENDFOR
          ENDIF
        ENDFOR
       ENDIF
      ENDIF
      IF ((temp->sl[x].il[y].module="PFEXTCTRLS"))
       IF ((temp->sl[x].il[y].input_type=medprofile_control))
        med_cnt = size(temp->sl[x].il[y].med_profile_qual,5)
        IF (((med_cnt > 0) OR ((temp->sl[x].il[y].med_profile_restricted_ind=1))) )
         col 1, captions->shomemeds, row + 1
         IF ((temp->sl[x].il[y].med_profile_restricted_ind=1))
          col 1, captions->sallmedsnotview, row + 1
         ENDIF
         FOR (med_ind = 1 TO med_cnt)
           col 1, temp->sl[x].il[y].med_profile_qual[med_ind].hna_order_mnemonic, row + 1
         ENDFOR
        ENDIF
       ENDIF
       IF ((temp->sl[x].il[y].input_type=medlist_control))
        medlist_cnt = size(temp->sl[x].il[y].med_list,5)
        IF (((medlist_cnt > 0) OR (size(temp->sl[x].il[y].order_compliance,5) > 0)) )
         ">>", row + 1, col 1,
         captions->smedlist, row + 1, "<<",
         row + 1
         IF (size(temp->sl[x].il[y].order_compliance,5) > 0)
          col 6, "  ", row + 1,
          col 6, captions->sordercompliance, ": ",
          row + 1, col 10
          IF ((temp->sl[x].il[y].order_compliance[1].unable_to_obtain_ind=1))
           captions->sunabletoobtain, "  "
          ELSE
           captions->sobtained, "  "
          ENDIF
          row + 1
          IF ((temp->sl[x].il[y].order_compliance[1].no_known_home_meds_ind=1))
           col 10, captions->snoknownhomemeds, row + 1
          ENDIF
          IF ((temp->sl[x].il[y].order_compliance[1].performed_by_name > ""))
           col 10, captions->sperformedby, ": ",
           temp->sl[x].il[y].order_compliance[1].performed_by_name, ";"
           IF ((temp->sl[x].il[y].order_compliance[1].performed_dt_tm_str > ""))
            captions->sperformeddate, ": ", temp->sl[x].il[y].order_compliance[1].performed_dt_tm_str
           ENDIF
           row + 1
          ENDIF
         ENDIF
        ENDIF
        IF (medlist_cnt > 0)
         FOR (med_idx = 1 TO medlist_cnt)
           IF (size(temp->sl[x].il[y].med_list[med_idx].name_lines,5) > 0)
            col 6, "   ", row + 1
            FOR (linecnt = 1 TO size(temp->sl[x].il[y].med_list[med_idx].name_lines,5))
              col 6, temp->sl[x].il[y].med_list[med_idx].name_lines[linecnt].name_line, row + 1
            ENDFOR
           ENDIF
           FOR (line = 1 TO size(temp->sl[x].il[y].med_list[med_idx].display_lines,5))
             col 10, temp->sl[x].il[y].med_list[med_idx].display_lines[line].display_ln, row + 1
           ENDFOR
           FOR (line = 1 TO size(temp->sl[x].il[y].med_list[med_idx].comment_lines,5))
             col 10, temp->sl[x].il[y].med_list[med_idx].comment_lines[line].comment_line, row + 1
           ENDFOR
           IF ((temp->sl[x].il[y].med_list[med_idx].provider_name > " "))
            col 10, captions->sprovider, ": ",
            temp->sl[x].il[y].med_list[med_idx].provider_name, row + 1
           ENDIF
           IF ((temp->sl[x].il[y].med_list[med_idx].order_dt_tm_str > " "))
            col 10, captions->sdate, ": ",
            temp->sl[x].il[y].med_list[med_idx].order_dt_tm_str, row + 1
           ENDIF
           IF ((temp->sl[x].il[y].med_list[med_idx].order_status > " "))
            col 10, captions->sstatus, ": ",
            temp->sl[x].il[y].med_list[med_idx].order_status, row + 1
           ENDIF
         ENDFOR
        ENDIF
       ENDIF
       IF ((temp->sl[x].il[y].input_type=pregnancyhistory_control))
        preg_cnt = size(temp->sl[x].il[y].pregnancies,5), ">> ", row + 1,
        col 1, captions->spreghist, row + 1,
        "<<", row + 1
        IF (preg_cnt <= 0
         AND size(temp->sl[x].il[y].gravida,5) <= 0
         AND (temp->sl[x].il[y].pregnancies_restricted_ind != 1))
         col 1, captions->snopregnancy, row + 1
        ELSE
         IF (size(temp->sl[x].il[y].gravida,5) > 0)
          col 4, "  ", row + 1
          IF ((((temp->sl[x].il[y].gravida[1].gravida > 0)) OR ((((temp->sl[x].il[y].gravida[1].
          fullterm > 0)) OR ((((temp->sl[x].il[y].gravida[1].parapreterm > 0)) OR ((((temp->sl[x].il[
          y].gravida[1].aborted > 0)) OR ((temp->sl[x].il[y].gravida[1].living > 0))) )) )) )) )
           IF ((temp->sl[x].il[y].gravida[1].gravida > 0))
            gravidaval = cnvtstring(temp->sl[x].il[y].gravida[1].gravida)
           ENDIF
           IF ((temp->sl[x].il[y].gravida[1].fullterm > 0))
            fulltermval = cnvtstring(temp->sl[x].il[y].gravida[1].fullterm)
           ENDIF
           IF ((temp->sl[x].il[y].gravida[1].parapreterm > 0))
            parapretermval = cnvtstring(temp->sl[x].il[y].gravida[1].parapreterm)
           ENDIF
           IF ((temp->sl[x].il[y].gravida[1].aborted > 0))
            abortedval = cnvtstring(temp->sl[x].il[y].gravida[1].aborted)
           ENDIF
           IF ((temp->sl[x].il[y].gravida[1].living > 0))
            livingval = cnvtstring(temp->sl[x].il[y].gravida[1].living)
           ENDIF
           gravida_str = fillstring(100," "), gravida_str = build2(captions->sgravida," - ",trim(
             gravidaval),"; ",captions->sparaterm,
            " - ",trim(fulltermval),"; ",captions->sparapreterm," - ",
            trim(parapretermval),"; ",captions->sabortions," - ",trim(abortedval),
            "; ",captions->sliving," - ",trim(livingval)), col 4,
           gravida_str, row + 1
          ELSE
           col 1, captions->snogravida, row + 1
          ENDIF
         ELSE
          col 1, captions->snogravida, row + 1
         ENDIF
        ENDIF
        IF ((temp->sl[x].il[y].pregnancies_restricted_ind=1))
         col 1, captions->sallpregnanciesnotview, row + 1
        ENDIF
        FOR (preg_idx = 1 TO preg_cnt)
          col 4, "   ", row + 1
          FOR (chld_idx = 1 TO size(temp->sl[x].il[y].pregnancies[preg_idx].child_list,5))
            col 8, "   ", row + 1
            IF ((temp->sl[x].il[y].pregnancies[preg_idx].child_list[chld_idx].
            delivery_date_precision_flag=3))
             IF ((temp->sl[x].il[y].pregnancies[preg_idx].auto_close_ind=0))
              col 8, captions->scloseddate, ": ",
              temp->sl[x].il[y].pregnancies[preg_idx].preg_end_dt_tm_str, row + 1
             ELSE
              col 8, captions->sautocloseddate, ": ",
              temp->sl[x].il[y].pregnancies[preg_idx].preg_end_dt_tm_str, row + 1
             ENDIF
            ELSE
             col 8, captions->sdeliverydate, ": ",
             temp->sl[x].il[y].pregnancies[preg_idx].child_list[chld_idx].delivery_dt_tm_str, row + 1
            ENDIF
            linecnt = size(temp->sl[x].il[y].pregnancies[preg_idx].child_list[chld_idx].
             data_str_lines,5)
            FOR (lineidx = 1 TO linecnt)
              col 12, temp->sl[x].il[y].pregnancies[preg_idx].child_list[chld_idx].data_str_lines[
              lineidx].aline, row + 1
            ENDFOR
          ENDFOR
        ENDFOR
       ENDIF
       IF ((temp->sl[x].il[y].input_type=pastmedhistory_control))
        past_prob_cnt = size(temp->sl[x].il[y].past_prob_list,5)
        IF (((past_prob_cnt > 0) OR ((temp->sl[x].il[y].past_prob_list_restricted_ind=1))) )
         ">>", row + 1, col 1,
         captions->spastmedhist, row + 1, "<<",
         row + 1
         IF ((temp->sl[x].il[y].past_prob_list_restricted_ind=1))
          col 1, captions->sallpastmedsnotview, row + 1
         ENDIF
         FOR (probind = 1 TO past_prob_cnt)
           col 5, "   ", row + 1
           FOR (line = 1 TO size(temp->sl[x].il[y].past_prob_list[probind].prob_lines,5))
             col 5, temp->sl[x].il[y].past_prob_list[probind].prob_lines[line].prob_line, row + 1
           ENDFOR
           col 10
           IF (trim(temp->sl[x].il[y].past_prob_list[probind].onset_year) > "")
            captions->sonsetyear, " - ", temp->sl[x].il[y].past_prob_list[probind].onset_year,
            "; "
           ENDIF
           IF (trim(temp->sl[x].il[y].past_prob_list[probind].onset_age) > "")
            captions->sonsetage, " -", temp->sl[x].il[y].past_prob_list[probind].onset_age
           ENDIF
           row + 1, comt_cnt = size(temp->sl[x].il[y].past_prob_list[probind].comments,5)
           IF (comt_cnt > 0)
            col 10, captions->scomments, ": ",
            row + 1
           ENDIF
           FOR (comt_idx = 1 TO comt_cnt)
            IF ((temp->sl[x].il[y].past_prob_list[probind].comments[comt_idx].comment_prsnl_name > ""
            ))
             col 15, temp->sl[x].il[y].past_prob_list[probind].comments[comt_idx].comment_dt_tm_str,
             " - ",
             temp->sl[x].il[y].past_prob_list[probind].comments[comt_idx].comment_prsnl_name, row + 1
            ENDIF
            ,
            FOR (comt_line = 1 TO size(temp->sl[x].il[y].past_prob_list[probind].comments[comt_idx].
             comment_lines,5))
              col 15, temp->sl[x].il[y].past_prob_list[probind].comments[comt_idx].comment_lines[
              comt_line].comment_line, row + 1
            ENDFOR
           ENDFOR
           IF ((temp->sl[x].il[y].past_prob_list[probind].life_cycle_status_disp > ""))
            col 10, captions->sstatus, ": ",
            temp->sl[x].il[y].past_prob_list[probind].life_cycle_status_disp, row + 1
           ENDIF
         ENDFOR
        ENDIF
       ENDIF
       IF ((temp->sl[x].il[y].input_type=procedurehistory_control))
        proc_cnt = size(temp->sl[x].il[y].proc_list,5)
        IF (((proc_cnt > 0) OR ((temp->sl[x].il[y].proc_list_restricted_ind=1))) )
         ">>", row + 1, col 1,
         captions->sprochist, row + 1, "<<",
         row + 1
        ENDIF
        IF ((temp->sl[x].il[y].proc_list_restricted_ind=1))
         col 1, captions->sallproceduresnotview, row + 1
        ENDIF
        FOR (proc_idx = 1 TO proc_cnt)
          col 4, "   ", row + 1
          FOR (line = 1 TO size(temp->sl[x].il[y].proc_list[proc_idx].proc_lines,5))
            col 4, temp->sl[x].il[y].proc_list[proc_idx].proc_lines[line].proc_line, row + 1
          ENDFOR
          FOR (line = 1 TO size(temp->sl[x].il[y].proc_list[proc_idx].perform_lines,5))
            col 8, temp->sl[x].il[y].proc_list[proc_idx].perform_lines[line].aline, row + 1
          ENDFOR
          IF (trim(temp->sl[x].il[y].proc_list[proc_idx].age_at_proc) > "")
           col 8, captions->sonsetage, ":",
           temp->sl[x].il[y].proc_list[proc_idx].age_at_proc, row + 1
          ENDIF
          cmnt_cnt = size(temp->sl[x].il[y].proc_list[proc_idx].comments,5)
          IF (cmnt_cnt > 0)
           col 8, captions->scomments, ": ",
           row + 1
          ENDIF
          FOR (cmnt_idx = 1 TO cmnt_cnt)
            IF ((temp->sl[x].il[y].proc_list[proc_idx].comments[cmnt_idx].comment_prsnl_name > ""))
             col 12, temp->sl[x].il[y].proc_list[proc_idx].comments[cmnt_idx].comment_dt_tm_str,
             " - ",
             temp->sl[x].il[y].proc_list[proc_idx].comments[cmnt_idx].comment_prsnl_name, row + 1
            ENDIF
            FOR (cmnt_line = 1 TO size(temp->sl[x].il[y].proc_list[proc_idx].comments[cmnt_idx].
             comment_lines,5))
              col 12, temp->sl[x].il[y].proc_list[proc_idx].comments[cmnt_idx].comment_lines[
              cmnt_line].comment_line, row + 1
            ENDFOR
            col 12, " ", row + 1
          ENDFOR
        ENDFOR
       ENDIF
       IF ((temp->sl[x].il[y].input_type=socialhistory_control))
        IF ((temp->sl[x].il[y].shx_unable_to_obtain_ind > - (1)))
         ">>", row + 1, col 1,
         captions->ssocialhist, row + 1, "<<",
         row + 1
         IF ((temp->sl[x].il[y].shx_unable_to_obtain_ind=1))
          col 4, "   ", row + 1,
          col 4, captions->sunabletoobtain, row + 1
         ENDIF
         IF ((temp->sl[x].il[y].social_cat_list_restricted_ind=1))
          col 1, captions->sallshxnotview, row + 1
         ENDIF
        ENDIF
        shx_cnt = size(temp->sl[x].il[y].social_cat_list,5)
        FOR (shx_idx = 1 TO shx_cnt)
          col 4, "  ", row + 1
          FOR (line = 1 TO size(temp->sl[x].il[y].social_cat_list[shx_idx].desc_lines,5))
            col 4, temp->sl[x].il[y].social_cat_list[shx_idx].desc_lines[line].desc_line, row + 1
          ENDFOR
          det_cnt = size(temp->sl[x].il[y].social_cat_list[shx_idx].detail_list,5)
          IF (det_cnt=0)
           IF (((trim(temp->sl[x].il[y].social_cat_list[shx_idx].last_updt_prsnl) > "") OR (trim(temp
            ->sl[x].il[y].social_cat_list[shx_idx].last_updt_dt_tm) > "")) )
            col 8, "(", captions->slastupdated,
            ": ", temp->sl[x].il[y].social_cat_list[shx_idx].last_updt_dt_tm, " ",
            captions->sby, " ", temp->sl[x].il[y].social_cat_list[shx_idx].last_updt_prsnl,
            ")", row + 1
           ENDIF
          ENDIF
          FOR (det_idx = 1 TO det_cnt)
            FOR (line = 1 TO size(temp->sl[x].il[y].social_cat_list[shx_idx].detail_list[det_idx].
             disp_lines,5))
              col 8, temp->sl[x].il[y].social_cat_list[shx_idx].detail_list[det_idx].disp_lines[line]
              .aline, row + 1
            ENDFOR
            cmnt_cnt = size(temp->sl[x].il[y].social_cat_list[shx_idx].detail_list[det_idx].comments,
             5)
            IF (cmnt_cnt > 0)
             col 8, captions->scomments, ": ",
             row + 1
            ENDIF
            FOR (cmnt_idx = 1 TO cmnt_cnt)
              FOR (cmnt_line = 1 TO size(temp->sl[x].il[y].social_cat_list[shx_idx].detail_list[
               det_idx].comments[cmnt_idx].comment_lines,5))
                col 12, temp->sl[x].il[y].social_cat_list[shx_idx].detail_list[det_idx].comments[
                cmnt_idx].comment_lines[cmnt_line].aline, row + 1
              ENDFOR
            ENDFOR
          ENDFOR
        ENDFOR
       ENDIF
       IF ((temp->sl[x].il[y].input_type=familyhistory_control))
        IF ( NOT ((temp->sl[x].il[y].entire_fam_hist_ind=- (1))))
         ">>", row + 1, col 1,
         captions->sfamhist, row + 1, "<<",
         row + 1
        ENDIF
        col 4
        IF ((temp->sl[x].il[y].entire_fam_hist_ind=0))
         captions->snegative
        ELSEIF ((temp->sl[x].il[y].entire_fam_hist_ind=2))
         captions->sunknown
        ELSEIF ((temp->sl[x].il[y].entire_fam_hist_ind=3))
         captions->sunableobtain
        ELSEIF ((temp->sl[x].il[y].entire_fam_hist_ind=4))
         captions->spatientadopted
        ENDIF
        row + 1, memb_cnt = size(temp->sl[x].il[y].fam_members,5)
        IF ((temp->sl[x].il[y].fam_list_restricted_ind=1))
         col 1, captions->sallfhxnotview, row + 1
        ENDIF
        FOR (memb_idx = 1 TO memb_cnt)
          col 4, "  ", row + 1
          FOR (line = 1 TO size(temp->sl[x].il[y].fam_members[memb_idx].name_lines,5))
            col 4, temp->sl[x].il[y].fam_members[memb_idx].name_lines[line].aline, row + 1
          ENDFOR
          memb_ind_str = ""
          IF ((temp->sl[x].il[y].fam_members[memb_idx].memb_entire_hist_ind=0))
           memb_ind_str = build2(captions->snegative," ",captions->shistory)
          ELSEIF ((temp->sl[x].il[y].fam_members[memb_idx].memb_entire_hist_ind=2))
           memb_ind_str = build2(captions->sunknown," ",captions->shistory)
          ENDIF
          IF (trim(memb_ind_str) > "")
           col 8, memb_ind_str, row + 1
          ENDIF
          IF ((temp->sl[x].il[y].fam_members[memb_idx].cause_of_death > ""))
           col 8, captions->scauseofdeath, ": ",
           temp->sl[x].il[y].fam_members[memb_idx].cause_of_death, row + 1
          ENDIF
          IF ((temp->sl[x].il[y].fam_members[memb_idx].age_at_death_str > ""))
           col 8, captions->sageatdeath, ": ",
           temp->sl[x].il[y].fam_members[memb_idx].age_at_death_str, row + 1
          ENDIF
          IF ((((temp->sl[x].il[y].fam_members[memb_idx].cause_of_death > "")) OR ((temp->sl[x].il[y]
          .fam_members[memb_idx].age_at_death_str > ""))) )
           col 8, " ", row + 1
          ENDIF
          cond_cnt = size(temp->sl[x].il[y].fam_members[memb_idx].conditions,5)
          FOR (cond_idx = 1 TO cond_cnt)
            term_line_cnt = size(temp->sl[x].il[y].fam_members[memb_idx].conditions[cond_idx].
             src_str_lines,5)
            FOR (term_line_idx = 1 TO term_line_cnt)
              col 8, temp->sl[x].il[y].fam_members[memb_idx].conditions[cond_idx].src_str_lines[
              term_line_idx].aline, row + 1
            ENDFOR
            IF ((temp->sl[x].il[y].fam_members[memb_idx].conditions[cond_idx].fhx_value_flag=0))
             col 12, captions->snegative, row + 1
            ELSEIF ((temp->sl[x].il[y].fam_members[memb_idx].conditions[cond_idx].fhx_value_flag=2))
             col 12, captions->sunknown, row + 1
            ELSE
             FOR (line = 1 TO size(temp->sl[x].il[y].fam_members[memb_idx].conditions[cond_idx].
              onset_lines,5))
               col 12, temp->sl[x].il[y].fam_members[memb_idx].conditions[cond_idx].onset_lines[line]
               .aline, row + 1
             ENDFOR
             cmnt_cnt = size(temp->sl[x].il[y].fam_members[memb_idx].conditions[cond_idx].comments,5)
             IF (cmnt_cnt > 0)
              col 12, captions->scomments, ": ",
              row + 1
             ENDIF
             FOR (cmnt_idx = 1 TO cmnt_cnt)
               IF (cmnt_idx > 1)
                col 16, " ", row + 1
               ENDIF
               IF ((temp->sl[x].il[y].fam_members[memb_idx].conditions[cond_idx].comments[cmnt_idx].
               comment_prsnl_name > ""))
                col 16, temp->sl[x].il[y].fam_members[memb_idx].conditions[cond_idx].comments[
                cmnt_idx].comment_dt_tm_str, " - ",
                temp->sl[x].il[y].fam_members[memb_idx].conditions[cond_idx].comments[cmnt_idx].
                comment_prsnl_name, row + 1
               ENDIF
               FOR (line = 1 TO size(temp->sl[x].il[y].fam_members[memb_idx].conditions[cond_idx].
                comments[cmnt_idx].comment_lines,5))
                 col 16, temp->sl[x].il[y].fam_members[memb_idx].conditions[cond_idx].comments[
                 cmnt_idx].comment_lines[line].line, row + 1
               ENDFOR
             ENDFOR
            ENDIF
          ENDFOR
        ENDFOR
       ENDIF
       IF ((temp->sl[x].il[y].input_type=problemdx_control))
        prob_count = size(temp->sl[x].il[y].problem_list,5)
        IF (((prob_count > 0) OR ((temp->sl[x].il[y].problem_list_restricted_ind=1))) )
         col 1, captions->sproblem, row + 1
         IF ((temp->sl[x].il[y].problem_list_restricted_ind=1))
          col 1, captions->sallproblemsnotview, row + 1
         ENDIF
         FOR (prob_ind = 1 TO prob_count)
           prob_desc_size = size(temp->sl[x].il[y].problem_list[prob_ind].problem_tag,5)
           FOR (prob_desc_idx = 1 TO prob_desc_size)
             col 2, temp->sl[x].il[y].problem_list[prob_ind].problem_tag[prob_desc_idx].problem_line,
             row + 1
           ENDFOR
           IF ((temp->sl[x].il[y].problem_list[prob_ind].problem_recorder > " "))
            col 4, captions->sproblemrecorder, col 50,
            temp->sl[x].il[y].problem_list[prob_ind].problem_recorder, row + 1
           ENDIF
           IF ((temp->sl[x].il[y].problem_list[prob_ind].confirmation_disp > " "))
            col 4, captions->sproblemconfirmation, col 50,
            temp->sl[x].il[y].problem_list[prob_ind].confirmation_disp, row + 1
           ENDIF
           IF ((temp->sl[x].il[y].problem_list[prob_ind].qualifier_disp > " "))
            col 4, captions->sproblemqualifier, col 50,
            temp->sl[x].il[y].problem_list[prob_ind].qualifier_disp, row + 1
           ENDIF
           IF ((temp->sl[x].il[y].problem_list[prob_ind].onset_dt_tm_str > " "))
            col 4, captions->sproblemonsetdt, col 50,
            temp->sl[x].il[y].problem_list[prob_ind].onset_dt_tm_str, row + 1
           ENDIF
           IF ((temp->sl[x].il[y].problem_list[prob_ind].problem_status_disp > " "))
            col 4, captions->sproblemstatus, col 50,
            temp->sl[x].il[y].problem_list[prob_ind].problem_status_disp, row + 1
           ENDIF
         ENDFOR
        ENDIF
        dx_count = size(temp->sl[x].il[y].diagnosis,5)
        IF (dx_count > 0)
         col 1, captions->sdx, row + 1
         FOR (dxind = 1 TO dx_count)
           dx_desc_size = size(temp->sl[x].il[y].diagnosis[dxind].diagnosis_tag,5)
           FOR (dx_desc_idx = 1 TO dx_desc_size)
             col 2, temp->sl[x].il[y].diagnosis[dxind].diagnosis_tag[dx_desc_idx].diagnosis_line, row
              + 1
           ENDFOR
           IF ((temp->sl[x].il[y].diagnosis[dxind].diagnosis_qualifier_disp > " "))
            col 4, captions->sdxqualifier, col 50,
            temp->sl[x].il[y].diagnosis[dxind].diagnosis_qualifier_disp, row + 1
           ENDIF
           IF ((temp->sl[x].il[y].diagnosis[dxind].diagnosis_confirmation_disp > " "))
            col 4, captions->sdxconfirmation, col 50,
            temp->sl[x].il[y].diagnosis[dxind].diagnosis_confirmation_disp, row + 1
           ENDIF
           IF ((temp->sl[x].il[y].diagnosis[dxind].diagnosis_type_disp > " "))
            col 4, captions->sdxtype, col 50,
            temp->sl[x].il[y].diagnosis[dxind].diagnosis_type_disp, row + 1
           ENDIF
           IF ((temp->sl[x].il[y].diagnosis[dxind].diagnosis_onset_dtstr > " "))
            col 4, captions->sdxonsetdttm, col 50,
            temp->sl[x].il[y].diagnosis[dxind].diagnosis_onset_dtstr, row + 1
           ENDIF
         ENDFOR
        ENDIF
       ENDIF
       IF ((temp->sl[x].il[y].input_type=communicationpreference_control))
        CALL echo("Entering Print Communication Preference"), comm_pref_cnt = size(temp->sl[x].il[y].
         comm_pref_list,5)
        FOR (comm_pref_idx = 1 TO comm_pref_cnt)
          FOR (line = 1 TO size(temp->sl[x].il[y].comm_pref_list[comm_pref_idx].desc_lines,5))
            IF (line=1)
             col 1, captions->scommunicationmethod, col 49,
             temp->sl[x].il[y].comm_pref_list[comm_pref_idx].desc_lines[line].desc_line, row + 1
            ELSE
             col 4, temp->sl[x].il[y].comm_pref_list[comm_pref_idx].desc_lines[line].desc_line, row
              + 1
            ENDIF
          ENDFOR
        ENDFOR
        CALL echo("Leaving Print Communication Preference")
       ENDIF
      ENDIF
    ENDFOR
   ENDFOR
  FOOT PAGE
   numrows = row, stat = alterlist(reply->qual,((ln+ numrows)+ 1))
   FOR (pagevar = 0 TO numrows)
     ln = (ln+ 1), reply->qual[ln].line = reportrow((pagevar+ 1)), done = "F"
     WHILE (done="F")
      nullpos = findstring(char(0),reply->qual[ln].line),
      IF (nullpos > 0)
       stat = movestring(" ",1,reply->qual[ln].line,nullpos,1)
      ELSE
       done = "T"
      ENDIF
     ENDWHILE
   ENDFOR
  WITH nocounter, maxcol = 1020, maxrow = 104
 ;end select
#print_act_end
 SUBROUTINE problem_formatting(sect,ctrl,probindex)
   SET pt->line_cnt = 0
   EXECUTE dcp_parse_text value(temp->sl[sect].il[ctrl].problem_list[probindex].problem_desc), 70
   SET stat = alterlist(temp->sl[sect].il[ctrl].problem_list[probindex].problem_tag,pt->line_cnt)
   FOR (x = 1 TO pt->line_cnt)
     SET temp->sl[sect].il[ctrl].problem_list[probindex].problem_tag[x].problem_line = pt->lns[x].
     line
   ENDFOR
 END ;Subroutine
 SUBROUTINE dx_formatting(sect,ctrl,dxindex)
   SET pt->line_cnt = 0
   EXECUTE dcp_parse_text temp->sl[sect].il[ctrl].diagnosis[dxindex].diagnosis_desc, 70
   SET stat = alterlist(temp->sl[sect].il[ctrl].diagnosis[dxindex].diagnosis_tag,pt->line_cnt)
   FOR (x = 1 TO pt->line_cnt)
     SET temp->sl[sect].il[ctrl].diagnosis[dxindex].diagnosis_tag[x].diagnosis_line = pt->lns[x].line
   ENDFOR
 END ;Subroutine
 SUBROUTINE gest_formatting(sect,ctrl,gestindex)
   SET pt->line_cnt = 0
   SET max_length = data_text_line_max_length
   EXECUTE dcp_parse_text temp->sl[sect].il[ctrl].gestational[gestindex].gest_comment, value(
    max_length)
   SET stat = alterlist(temp->sl[sect].il[ctrl].gestational[gestindex].gest_tag,pt->line_cnt)
   FOR (x = 1 TO pt->line_cnt)
     SET temp->sl[sect].il[ctrl].gestational[gestindex].gest_tag[x].gest_line = pt->lns[x].line
   ENDFOR
 END ;Subroutine
 SUBROUTINE encntr_formatting(sect,ctrl,encindex)
   SET pt->line_cnt = 0
   SET max_length = data_text_line_max_length
   EXECUTE dcp_parse_text temp->sl[sect].il[ctrl].tracking_cmt[encindex].tracking_comment, value(
    max_length)
   SET stat = alterlist(temp->sl[sect].il[ctrl].tracking_cmt[encindex].tracking_tag,pt->line_cnt)
   FOR (x = 1 TO pt->line_cnt)
     SET temp->sl[sect].il[ctrl].tracking_cmt[encindex].tracking_tag[x].tracking_line = pt->lns[x].
     line
   ENDFOR
 END ;Subroutine
 SUBROUTINE xrtextlinesizecaculations(null)
   IF (xr_indicator=0)
    RETURN
   ENDIF
   DECLARE xr_char_in_inches = f8 WITH private, noconstant(xr_char_size10_in_inches)
   DECLARE xr_max_line_length = i4 WITH private, noconstant(0)
   IF (xr_font_size=8)
    SET xr_char_in_inches = xr_char_size8_in_inches
   ELSEIF (xr_font_size=9)
    SET xr_char_in_inches = xr_char_size9_in_inches
   ELSEIF (xr_font_size=10)
    SET xr_char_in_inches = xr_char_size10_in_inches
   ELSEIF (xr_font_size=11)
    SET xr_char_in_inches = xr_char_size11_in_inches
   ELSEIF (xr_font_size=12)
    SET xr_char_in_inches = xr_char_size12_in_inches
   ELSE
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "RAW TEXT FORMAT"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "cp_powerforms_chart_impl"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = concat("font size = ",build(
      xr_font_size),": out of [8-12] range.")
    GO TO exit_script
   ENDIF
   SET xr_max_line_length = cnvtint((xr_page_width_in_inches/ xr_char_in_inches))
   IF (xr_max_line_length < xr_min_line_length)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "RAW TEXT FORMAT"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "cp_powerforms_chart_impl"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = concat("font size = ",build(
      xr_font_size),", pagewidth = ",build(xr_page_width_in_inches),"inches: line has only ",
     build(xr_max_line_length)," characters < ",build(xr_min_line_length),": Too short.")
    GO TO exit_script
   ENDIF
   SET m_totalchar = xr_max_line_length
   SET data_text_line_max_length = (xr_max_line_length - first_text_column)
   SET title_column = 20
   SET prsnl_column = 15
 END ;Subroutine
#exit_script
 IF (debug_ind=1)
  CALL echo("*BEGIN DEBUG*")
  CALL echo(build("frms_failure_ind is: ",frms_failure_ind))
  CALL echorecord(reply)
  CALL echo("*END DEBUG*")
 ENDIF
 FREE RECORD blog
 FREE RECORD r_print
 FREE RECORD pt
 SET last_mod = "007 16/03/14"
 CALL echo(build("Script was last modified on: ",last_mod))
END GO
