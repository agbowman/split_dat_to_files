CREATE PROGRAM cp_load_chart_sections:dba
 DECLARE log_program_name = vc WITH protect, noconstant("")
 DECLARE log_override_ind = i2 WITH protect, noconstant(0)
 SET log_program_name = curprog
 SET log_override_ind = 0
 DECLARE log_level_error = i2 WITH protect, noconstant(0)
 DECLARE log_level_warning = i2 WITH protect, noconstant(1)
 DECLARE log_level_audit = i2 WITH protect, noconstant(2)
 DECLARE log_level_info = i2 WITH protect, noconstant(3)
 DECLARE log_level_debug = i2 WITH protect, noconstant(4)
 DECLARE hsys = i4 WITH protect, noconstant(0)
 DECLARE sysstat = i4 WITH protect, noconstant(0)
 DECLARE serrmsg = c132 WITH protect, noconstant(" ")
 DECLARE ierrcode = i4 WITH protect, noconstant(error(serrmsg,1))
 DECLARE crsl_msg_default = h WITH protect, noconstant(0)
 DECLARE crsl_msg_level = h WITH protect, noconstant(0)
 EXECUTE msgrtl
 SET crsl_msg_default = uar_msgdefhandle()
 SET crsl_msg_level = uar_msggetlevel(crsl_msg_default)
 DECLARE lcrslsubeventcnt = i4 WITH protect, noconstant(0)
 DECLARE icrslloggingstat = i2 WITH protect, noconstant(0)
 DECLARE lcrslsubeventsize = i4 WITH protect, noconstant(0)
 DECLARE icrslloglvloverrideind = i2 WITH protect, noconstant(0)
 DECLARE scrsllogtext = vc WITH protect, noconstant("")
 DECLARE scrsllogevent = vc WITH protect, noconstant("")
 DECLARE icrslholdloglevel = i2 WITH protect, noconstant(0)
 DECLARE icrslerroroccured = i2 WITH protect, noconstant(0)
 DECLARE lcrsluarmsgwritestat = i4 WITH protect, noconstant(0)
 DECLARE crsl_info_domain = vc WITH protect, constant("CLINRPT SCRIPT LOGGING")
 DECLARE crsl_logging_on = c1 WITH protect, constant("L")
 SELECT INTO "nl:"
  FROM dm_info dm
  PLAN (dm
   WHERE dm.info_domain=crsl_info_domain
    AND dm.info_name=curprog)
  DETAIL
   IF (dm.info_char=crsl_logging_on)
    log_override_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SUBROUTINE (log_message(logmsg=vc,loglvl=i4) =null)
   SET icrslloglvloverrideind = 0
   SET scrsllogtext = ""
   SET scrsllogevent = ""
   SET scrsllogtext = concat("{{Script::",value(log_program_name),"}} ",logmsg)
   IF (log_override_ind=0)
    SET icrslholdloglevel = loglvl
   ELSE
    IF (crsl_msg_level < loglvl)
     SET icrslholdloglevel = crsl_msg_level
     SET icrslloglvloverrideind = 1
    ELSE
     SET icrslholdloglevel = loglvl
    ENDIF
   ENDIF
   IF (icrslloglvloverrideind=1)
    SET scrsllogevent = "Script_Override"
   ELSE
    CASE (icrslholdloglevel)
     OF log_level_error:
      SET scrsllogevent = "Script_Error"
     OF log_level_warning:
      SET scrsllogevent = "Script_Warning"
     OF log_level_audit:
      SET scrsllogevent = "Script_Audit"
     OF log_level_info:
      SET scrsllogevent = "Script_Info"
     OF log_level_debug:
      SET scrsllogevent = "Script_Debug"
    ENDCASE
   ENDIF
   SET lcrsluarmsgwritestat = uar_msgwrite(crsl_msg_default,0,nullterm(scrsllogevent),
    icrslholdloglevel,nullterm(scrsllogtext))
   CALL echo(logmsg)
 END ;Subroutine
 SUBROUTINE (error_message(logstatusblockind=i2) =i2)
   SET icrslerroroccured = 0
   SET ierrcode = error(serrmsg,0)
   WHILE (ierrcode > 0)
     SET icrslerroroccured = 1
     SET reply->status_data.status = "F"
     CALL log_message(serrmsg,log_level_audit)
     IF (logstatusblockind=1)
      CALL populate_subeventstatus("EXECUTE","F","CCL SCRIPT",serrmsg)
     ENDIF
     SET ierrcode = error(serrmsg,0)
   ENDWHILE
   RETURN(icrslerroroccured)
 END ;Subroutine
 SUBROUTINE (error_and_zero_check(qualnum=i4,opname=vc,logmsg=vc,errorforceexit=i2,zeroforceexit=i2
  ) =i2)
   SET icrslerroroccured = 0
   SET ierrcode = error(serrmsg,0)
   WHILE (ierrcode > 0)
     SET icrslerroroccured = 1
     CALL log_message(serrmsg,log_level_audit)
     CALL populate_subeventstatus(opname,"F",serrmsg,logmsg)
     SET ierrcode = error(serrmsg,0)
   ENDWHILE
   IF (icrslerroroccured=1
    AND errorforceexit=1)
    SET reply->status_data.status = "F"
    GO TO exit_script
   ENDIF
   IF (qualnum=0
    AND zeroforceexit=1)
    SET reply->status_data.status = "Z"
    CALL populate_subeventstatus(opname,"Z","No records qualified",logmsg)
    GO TO exit_script
   ENDIF
   RETURN(icrslerroroccured)
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value)) =i2)
   IF (validate(reply->status_data.status,"-1") != "-1")
    SET lcrslsubeventcnt = size(reply->status_data.subeventstatus,5)
    SET lcrslsubeventsize = size(trim(reply->status_data.subeventstatus[lcrslsubeventcnt].
      operationname))
    SET lcrslsubeventsize += size(trim(reply->status_data.subeventstatus[lcrslsubeventcnt].
      operationstatus))
    SET lcrslsubeventsize += size(trim(reply->status_data.subeventstatus[lcrslsubeventcnt].
      targetobjectname))
    SET lcrslsubeventsize += size(trim(reply->status_data.subeventstatus[lcrslsubeventcnt].
      targetobjectvalue))
    IF (lcrslsubeventsize > 0)
     SET lcrslsubeventcnt += 1
     SET icrslloggingstat = alter(reply->status_data.subeventstatus,lcrslsubeventcnt)
    ENDIF
    SET reply->status_data.subeventstatus[lcrslsubeventcnt].operationname = substring(1,25,
     operationname)
    SET reply->status_data.subeventstatus[lcrslsubeventcnt].operationstatus = substring(1,1,
     operationstatus)
    SET reply->status_data.subeventstatus[lcrslsubeventcnt].targetobjectname = substring(1,25,
     targetobjectname)
    SET reply->status_data.subeventstatus[lcrslsubeventcnt].targetobjectvalue = targetobjectvalue
   ENDIF
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus_msg(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value),loglevel=i2(value)) =i2)
  CALL populate_subeventstatus(operationname,operationstatus,targetobjectname,targetobjectvalue)
  CALL log_message(targetobjectvalue,loglevel)
 END ;Subroutine
 SUBROUTINE (check_log_level(arg_log_level=i4) =i2)
   IF (((crsl_msg_level >= arg_log_level) OR (log_override_ind=1)) )
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SET log_program_name = "CP_LOAD_CHART_SECTIONS"
 IF (validate(request) != 1)
  RECORD request(
    1 load_section_format_ind = i2
    1 qual[*]
      2 chart_section_id = f8
  )
 ENDIF
 RECORD reply(
   1 qual[*]
     2 chart_section_id = f8
     2 chart_section_desc = vc
     2 section_type_flag = i2
     2 sect_page_brk_ind = i2
     2 chart_group_list[*]
       3 chart_group_id = f8
       3 max_results = i4
       3 chart_group_desc = vc
       3 enhanced_layout_ind = i2
       3 horizontal_info_list[*]
         4 test_lbl_order = i4
         4 units_lbl_order = i4
         4 refer_lbl_order = i4
         4 normall_lbl_order = i4
         4 normalh_lbl_order = i4
         4 perfid_lbl_order = i4
         4 test_lbl = vc
         4 units_lbl = vc
         4 ref_range_lbl = vc
         4 normal_low_lbl = vc
         4 normal_high_lbl = vc
         4 perfid_lbl = vc
         4 date_order = i4
         4 weekday_order = i4
         4 staydays_order = i4
         4 time_order = i4
         4 rslt_start_col = i4
         4 date_mask = vc
         4 time_mask = vc
         4 ref_rng_form_flag = i2
         4 rslt_seq_flag = i2
         4 ftnote_loc_flag = i2
         4 interp_loc_flag = i2
         4 wkday_format_flag = i2
         4 encntr_alias_order = i4
         4 flowsheet_ind = i2
       3 vertical_info_list[*]
         4 test_lbl_order = i4
         4 units_lbl_order = i4
         4 refer_lbl_order = i4
         4 perfid_lbl_order = i4
         4 test_lbl_pos = i4
         4 units_lbl_pos = i4
         4 refer_lbl_pos = i4
         4 perfid_lbl_pos = i4
         4 test_lbl = vc
         4 units_lbl = vc
         4 ref_range_lbl = vc
         4 perfid_lbl = vc
         4 date_lbl = vc
         4 staydays_lbl = vc
         4 time_lbl = vc
         4 date_order = i4
         4 staydays_order = i4
         4 time_order = i4
         4 ref_rng_form_flag = i2
         4 rslt_seq_flag = i2
         4 ftnote_loc_flag = i2
         4 interp_loc_flag = i2
         4 date_mask = vc
         4 time_mask = vc
         4 staydays_form_flag = i2
         4 rslt_start_col = i4
         4 encntr_alias_order = i4
         4 encntr_alias_lbl = vc
         4 flowsheet_ind = i2
       3 zonal_info_list[*]
         4 date_mask = vc
         4 time_mask = vc
         4 ref_rng_form_flag = i2
         4 rslt_seq_flag = i2
         4 ftnote_loc_flag = i2
         4 interp_loc_flag = i2
         4 zone_seq = i4
         4 test_lbl = vc
         4 units_lbl = vc
         4 ref_range_lbl = vc
         4 alpha_abn_rslt_lbl = vc
         4 all_rslt_lbl = vc
         4 crit_rslt_lbl = vc
         4 high_rslt_lbl = vc
         4 low_rslt_lbl = vc
         4 normal_rslt_lbl = vc
         4 test_col = i4
         4 units_col = i4
         4 ref_range_col = i4
         4 all_rslt_col = i4
         4 low_rslt_col = i4
         4 normal_rslt_col = i4
         4 high_rslt_col = i4
         4 crit_rslt_col = i4
         4 alpha_abn_rslt_col = i4
       3 flex_info
         4 flex_type = i4
         4 prod_nbr_lbl = vc
         4 desc_lbl = vc
         4 disp_lbl = vc
         4 abo_lbl = vc
         4 verified_dt_lbl = vc
         4 collected_dt_lbl = vc
         4 prod_nbr_odr = i4
         4 desc_odr = i4
         4 disp_odr = i4
         4 abo_odr = i4
         4 verified_dt_odr = i4
         4 collected_dt_odr = i4
         4 result_seq = i2
         4 crossmatch_result_lbl = vc
         4 crossmatch_result_odr = i4
         4 product_status_lbl = vc
         4 product_status_odr = i4
         4 received_dt_lbl = vc
         4 received_dt_odr = i4
       3 order_summary_info
         4 order_summary_type = i4
         4 date_lbl = vc
         4 time_lbl = vc
         4 name_lbl = vc
         4 mnemonic_lbl = vc
         4 status_lbl = vc
         4 cancel_reason_lbl = vc
         4 date_mask = vc
         4 time_mask = vc
         4 date_odr = i4
         4 time_odr = i4
         4 name_odr = i4
         4 mnemonic_odr = i4
         4 status_odr = i4
         4 cancel_reason_odr = i4
         4 order_seq_flag = i2
         4 os_filter_list[*]
           5 filter_cd = f8
           5 filter_display = vc
           5 filter_type = i2
           5 filter_seq = i4
         4 order_provider_ind = i2
         4 order_provider_odr = i4
         4 order_provider_lbl = vc
         4 dept_status_odr = i4
         4 dept_status_lbl = vc
       3 rad_info
         4 group_style = vc
         4 reason_annotation = i4
         4 reason_caption = vc
         4 reason_ind = i2
         4 result_sequence = i4
         4 cpt4_code_ind = i2
         4 cpt4_desc_ind = i2
         4 cpt4_label = vc
         4 cpt4_label_style = vc
         4 cdm_code_ind = i2
         4 cdm_desc_ind = i2
         4 cdm_label = vc
         4 cdm_label_style = vc
         4 cor_footnote_ind = i2
       3 ap_info
         4 group_style = vc
         4 result_sequence = i4
         4 snomed_codes_ind = i2
         4 snomed_desc_ind = i2
         4 snomed_codes_lbl = vc
         4 snomed_cd_lbl_style = vc
         4 tcc_codes_ind = i2
         4 tcc_desc_ind = i2
         4 tcc_codes_lbl = vc
         4 tcc_cd_lbl_style = vc
         4 ap_history_flag = i2
         4 cpt_long_text = vc
         4 image_flag = i2
       3 hla_info
         4 hla_type = i4
         4 line_ind = i4
         4 rslt_seq = i2
         4 prsn_name_lbl = vc
         4 date_lbl = vc
         4 mrn_lbl = vc
         4 relation_lbl = vc
         4 abo_rh_lbl = vc
         4 haploid1_lbl = vc
         4 haploid2_lbl = vc
         4 haplotype1_lbl = vc
         4 haplotype2_lbl = vc
         4 prsn_name_odr = i4
         4 date_odr = i4
         4 mrn_odr = i4
         4 relation_odr = i4
         4 abo_rh_odr = i4
         4 result_odr = i4
         4 haploid1_odr = i4
         4 haploid2_odr = i4
         4 haplotype1_odr = i4
         4 haplotype2_odr = i4
         4 prsn_name_rpt = i4
         4 date_rpt = i4
         4 mrn_rpt = i4
         4 relation_rpt = i4
         4 abo_rpt = i4
         4 rh_ind = i2
       3 doc_info
         4 rslt_seq = i2
         4 pgbrk_ind = i2
         4 exclude_img_mdoc_ind = i2
         4 include_img_head_ind = i2
         4 include_img_foot_ind = i2
         4 doc_type = i2
       3 gl_info
         4 rslt_seq = i2
         4 group_style = vc
       3 micro_info
         4 option_list[*]
           5 option_flag = i2
           5 option_value = vc
       3 allergy_info
         4 substance_lbl = vc
         4 category_lbl = vc
         4 updt_dt_lbl = vc
         4 severity_lbl = vc
         4 reaction_stat_lbl = vc
         4 reaction_lbl = vc
         4 updt_by_lbl = vc
         4 source_lbl = vc
         4 onset_dt_lbl = vc
         4 type_lbl = vc
         4 cancel_lbl = vc
         4 comment_lbl = vc
         4 severity_odr = i4
         4 reaction_stat_odr = i4
         4 reaction_odr = i4
         4 source_odr = i4
         4 onset_dt_odr = i4
         4 type_odr = i4
         4 cancel_odr = i4
         4 category_odr = i4
         4 result_sequence_ind = i2
       3 prob_info
         4 prob_name_lbl = vc
         4 date_rec_lbl = vc
         4 code_lbl = vc
         4 con_stat_lbl = vc
         4 life_stat_lbl = vc
         4 course_lbl = vc
         4 perst_lbl = vc
         4 prog_lbl = vc
         4 onset_lbl = vc
         4 prov_lbl = vc
         4 date_est_lbl = vc
         4 cancel_lbl = vc
         4 comment_lbl = vc
         4 code_ord = i4
         4 con_stat_ord = i4
         4 life_stat_ord = i4
         4 course_ord = i4
         4 perst_ord = i4
         4 prog_ord = i4
         4 onset_ord = i4
         4 cancel_ord = i4
         4 result_sequence_ind = i2
         4 date_rec_result_sequence_ind = i2
       3 xencntr_info
         4 rslt_seq = i2
         4 prefix_format_flag = i2
         4 prefix_format = vc
         4 encntr_alias_lbl = vc
         4 facility_lbl = vc
         4 building_lbl = vc
         4 nurse_unit_lbl = vc
         4 client_lbl = vc
         4 fin_nbr_lbl = vc
         4 mrn_lbl = vc
         4 admit_dt_lbl = vc
         4 dischg_dt_lbl = vc
         4 diagnosis_lbl = vc
         4 encntr_alias_odr = i4
         4 facility_odr = i4
         4 building_odr = i4
         4 nurse_unit_odr = i4
         4 client_odr = i4
         4 fin_nbr_odr = i4
         4 mrn_odr = i4
         4 admit_dt_odr = i4
         4 dischg_dt_odr = i4
         4 diagnosis_odr = i4
       3 new_zonal_info
         4 collect_date_lbl = vc
         4 collect_date_chk = i4
         4 date_format_cd = f8
         4 time_format_flag = i2
         4 date_mask = vc
         4 time_mask = vc
         4 ref_rng_form_flag = i2
         4 rslt_seq_flag = i2
         4 ftnote_loc_flag = i2
         4 interp_loc_flag = i2
         4 zone_list[*]
           5 zone_seq = i4
           5 proc_lbl = vc
           5 units_lbl = vc
           5 ref_range_lbl = vc
           5 proc_col = i4
           5 units_col = i4
           5 ref_range_col = i4
           5 result_col_list[*]
             6 column_seq = i4
             6 col_index = i4
             6 description = vc
             6 normalcy_cds[*]
               7 code = f8
               7 meaning = c12
         4 order_group_ind = i2
       3 orders_info
         4 order_seq_flag = i2
         4 date_time_chk = i2
         4 date_time_lbl = vc
         4 action_chk = i2
         4 action_lbl = vc
         4 dept_status_chk = i2
         4 dept_status_lbl = vc
         4 mnemonic_chk = i2
         4 mnemonic_lbl = vc
         4 order_phys_chk = i2
         4 order_phys_lbl = vc
         4 order_placer_chk = i2
         4 order_placer_lbl = vc
         4 order_writer_chk = i2
         4 order_writer_lbl = vc
         4 order_status_chk = i2
         4 order_status_lbl = vc
         4 order_type_chk = i2
         4 order_type_lbl = vc
         4 details_chk = i2
         4 details_lbl = vc
         4 review_chk = i2
         4 review_lbl = vc
         4 detail_order = i4
         4 review_order = i4
         4 single_row_ind = i2
         4 date_mask = vc
         4 time_mask = vc
         4 orderset_exclude_ind = i2
         4 label_bit_map = i4
         4 cancel_reason_lbl = vc
         4 canceled_dttm_lbl = vc
         4 comm_type_lbl = vc
         4 discontinued_dttm_lbl = vc
         4 future_disc_dttm_lbl = vc
         4 orig_order_dttm_lbl = vc
         4 suppress_meds_bit_map = i4
         4 action_seq_flag = i4
         4 detailed_layout_ind = i2
       3 mar_info
         4 med_seq_flag = i2
         4 section_order = i4
         4 admin_seq_ind = i2
         4 ordered_as_mnemonic_chk = i2
         4 dispensed_mnemonic_chk = i2
         4 admin_dt_tm_order = i4
         4 admin_details_order = i4
         4 admin_by_order = i4
         4 primary_mnemonic_lbl = vc
         4 order_details_lbl = vc
         4 admin_dt_tm_lbl = vc
         4 admin_details_lbl = vc
         4 admin_by_lbl = vc
         4 date_mask = vc
         4 time_mask = vc
       3 name_hist_info
         4 order_seq_ind = i2
         4 name_lbl = vc
         4 name_odr = i4
         4 beg_effective_dt_tm_lbl = vc
         4 beg_effective_dt_tm_odr = i4
         4 end_effective_dt_tm_lbl = vc
         4 end_effective_dt_tm_odr = i4
       3 immun_info
         4 result_seq_ind = i2
         4 admin_note_chk = i2
         4 amount_chk = i2
         4 date_given_chk = i2
         4 exp_dt_chk = i2
         4 exp_tm_chk = i2
         4 lot_num_chk = i2
         4 manufact_chk = i2
         4 provider_chk = i2
         4 site_chk = i2
         4 time_given_chk = i2
         4 admin_person_lbl = vc
         4 amount_lbl = vc
         4 date_given_lbl = vc
         4 exp_dt_lbl = vc
         4 lot_num_lbl = vc
         4 manufact_lbl = vc
         4 provider_lbl = vc
         4 site_lbl = vc
         4 vaccine_lbl = vc
         4 date_mask = vc
         4 time_mask = vc
       3 proc_hist_info
         4 proc_lbl = vc
         4 proc_ord = i4
         4 status_lbl = vc
         4 status_ord = i4
         4 date_lbl = vc
         4 date_ord = i4
         4 provider_lbl = vc
         4 provider_ord = i4
         4 location_lbl = vc
         4 location_ord = i4
       3 chart_event_list[*]
         4 event_set_cd = f8
         4 event_set_name = vc
         4 event_set_valid = i2
         4 synonym_id = f8
         4 order_catalog_cd = f8
         4 procedure_type_flag = i2
         4 display_name = vc
         4 zone = i4
         4 powerform_name = vc
         4 dcp_forms_ref_id = f8
       3 mar2_info
         4 include_img_head_ind = i2
         4 include_img_foot_ind = i2
       3 io_info
         4 include_img_head_ind = i2
         4 include_img_foot_ind = i2
         4 long_text = vc
       3 mph_info
         4 include_img_head_ind = i2
         4 include_img_foot_ind = i2
       3 discern_report_info
         4 include_img_head_ind = i2
         4 include_img_foot_ind = i2
         4 chart_discern_request_id = f8
         4 request_number = i4
         4 process_flag = i2
         4 display = vc
         4 scope_bit_map = i4
         4 active_ind = i2
         4 qualification_date_flag = i2
       3 listview_info_list[*]
         4 resseq_ind = i4
         4 result_ord = i4
         4 procedure_ord = i4
         4 units_ord = i4
         4 refrange_ord = i4
         4 refrange_ind = i4
         4 accession_ord = i4
         4 collected_ord = i4
         4 received_ord = i4
         4 verified_ord = i4
         4 perfver_ord = i4
         4 spectype_ord = i4
         4 result_lbl = vc
         4 procedure_lbl = vc
         4 units_lbl = vc
         4 refrange_lbl = vc
         4 accession_lbl = vc
         4 collected_lbl = vc
         4 received_lbl = vc
         4 verified_lbl = vc
         4 perfver_lbl = vc
         4 spectype_lbl = vc
     2 sect_field_list[*]
       3 field_id = i4
       3 field_row = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD group_rec
 RECORD group_rec(
   1 cnt = i4
   1 qual[*]
     2 group_id = f8
     2 group_seq = i4
     2 section_seq = i4
     2 section_type_flag = i4
 )
 FREE RECORD temp_rec
 RECORD temp_rec(
   1 cnt = i4
   1 qual[*]
     2 event_set_name = vc
     2 qual_idx = i4
     2 group_idx = i4
     2 event_idx = i4
     2 powerform_name = vc
     2 dcp_forms_ref_id = f8
 )
 DECLARE getsectiongroupinfo(null) = null
 DECLARE getsectionspecificinfo(null) = null
 DECLARE checksectiontype(null) = null
 DECLARE getxencntrsectioninformation(null) = null
 DECLARE getflexsectioninformation(null) = null
 DECLARE gethorizontalsectioninformation(null) = null
 DECLARE getmicrosectioninformation(null) = null
 DECLARE getordersumsectioninformation(null) = null
 DECLARE getradiologysectioninformation(null) = null
 DECLARE getverticalsectioninformation(null) = null
 DECLARE getzonaloldsectioninformation(null) = null
 DECLARE getapsectioninformation(null) = null
 DECLARE gethlasectioninformation(null) = null
 DECLARE getdocumentsectioninformation(null) = null
 DECLARE getlabtextsectioninformation(null) = null
 DECLARE getallergysectioninformation(null) = null
 DECLARE getproblemlistsectioninformation(null) = null
 DECLARE getzonalnewsectioninformation(null) = null
 DECLARE getorderssectioninformation(null) = null
 DECLARE getmarsectioninformation(null) = null
 DECLARE getnamehistsectioninformation(null) = null
 DECLARE getimmunsectioninformation(null) = null
 DECLARE getprochistsectioninformation(null) = null
 DECLARE getmar2sectioninformation(null) = null
 DECLARE getmedprofhistsectioninformation(null) = null
 DECLARE getuserdefinedsectioninformation(null) = null
 DECLARE getlistviewsectioninformation(null) = null
 DECLARE getpowerformnames(null) = null
 DECLARE qualcount = i4 WITH noconstant(0), protect
 DECLARE grpcount = i4 WITH noconstant(0), protect
 DECLARE itemcount = i4 WITH noconstant(0), protect
 DECLARE evtcount = i4 WITH noconstant(0), protect
 DECLARE fldcount = i4 WITH noconstant(0), protect
 DECLARE filter_count = i4 WITH noconstant(0), protect
 DECLARE opt_nbr = i4 WITH noconstant(0), protect
 DECLARE long_text = vc WITH noconstant(" "), protect
 DECLARE bind_cnt = i4 WITH constant(50)
 DECLARE xencntr_section_type = i4 WITH constant(4)
 DECLARE flex_section_type = i4 WITH constant(6)
 DECLARE horz_section_type = i4 WITH constant(9)
 DECLARE mic_section_type = i4 WITH constant(10)
 DECLARE ord_sum_section_type = i4 WITH constant(11)
 DECLARE rad_section_type = i4 WITH constant(14)
 DECLARE vert_section_type = i4 WITH constant(16)
 DECLARE zonal_old_section_type = i4 WITH constant(17)
 DECLARE ap_section_type = i4 WITH constant(18)
 DECLARE pwrfrm_section_type = i4 WITH constant(21)
 DECLARE hla_section_type = i4 WITH constant(22)
 DECLARE doc_section_type = i4 WITH constant(25)
 DECLARE lab_text_section_type = i4 WITH constant(27)
 DECLARE allergy_section_type = i4 WITH constant(30)
 DECLARE prob_list_section_type = i4 WITH constant(31)
 DECLARE zonal_new_section_type = i4 WITH constant(32)
 DECLARE orders_section_type = i4 WITH constant(33)
 DECLARE mar_section_type = i4 WITH constant(34)
 DECLARE name_hist_section_type = i4 WITH constant(35)
 DECLARE immun_section_type = i4 WITH constant(37)
 DECLARE proc_hist_section_type = i4 WITH constant(38)
 DECLARE mar2_section_type = i4 WITH constant(41)
 DECLARE io_section_type = i4 WITH constant(42)
 DECLARE med_prof_hist_section_type = i4 WITH constant(43)
 DECLARE user_defined_section_type = i4 WITH constant(44)
 DECLARE listview_section_type = i4 WITH constant(45)
 DECLARE xencntr_section_found = i4 WITH noconstant(0)
 DECLARE flex_section_found = i4 WITH noconstant(0)
 DECLARE horz_section_found = i4 WITH noconstant(0)
 DECLARE mic_section_found = i4 WITH noconstant(0)
 DECLARE ord_sum_section_found = i4 WITH noconstant(0)
 DECLARE rad_section_found = i4 WITH noconstant(0)
 DECLARE vert_section_found = i4 WITH noconstant(0)
 DECLARE zonal_old_section_found = i4 WITH noconstant(0)
 DECLARE ap_section_found = i4 WITH noconstant(0)
 DECLARE hla_section_found = i4 WITH noconstant(0)
 DECLARE doc_section_found = i4 WITH noconstant(0)
 DECLARE lab_text_section_found = i4 WITH noconstant(0)
 DECLARE allergy_section_found = i4 WITH noconstant(0)
 DECLARE prob_list_section_found = i4 WITH noconstant(0)
 DECLARE zonal_new_section_found = i4 WITH noconstant(0)
 DECLARE orders_section_found = i4 WITH noconstant(0)
 DECLARE mar_section_found = i4 WITH noconstant(0)
 DECLARE name_hist_section_found = i4 WITH noconstant(0)
 DECLARE immun_section_found = i4 WITH noconstant(0)
 DECLARE proc_hist_section_found = i4 WITH noconstant(0)
 DECLARE mar2_section_found = i4 WITH noconstant(0)
 DECLARE io_section_found = i4 WITH noconstant(0)
 DECLARE med_prof_hist_section_found = i4 WITH noconstant(0)
 DECLARE user_defined_section_found = i4 WITH noconstant(0)
 DECLARE pwrfrm_section_found = i4 WITH noconstant(0)
 DECLARE listview_section_found = i4 WITH noconstant(0)
 CALL log_message("Starting script: cp_load_chart_sections",log_level_debug)
 SET reply->status_data.status = "F"
 CALL getsectiongroupinfo(null)
 IF (request->load_section_format_ind)
  CALL getsectionspecificinfo(null)
 ENDIF
 SET reply->status_data.status = "S"
 SUBROUTINE checksectiontype(null)
   CASE (cs.section_type_flag)
    OF xencntr_section_type:
     IF (xencntr_section_found=0)
      SET xencntr_section_found = 1
      CALL log_message("XENCNTR_SECTION_TYPE found",log_level_debug)
     ENDIF
    OF flex_section_type:
     IF (flex_section_found=0)
      SET flex_section_found = 1
      CALL log_message("FLEX_SECTION_TYPE found",log_level_debug)
     ENDIF
    OF horz_section_type:
     IF (horz_section_found=0)
      SET horz_section_found = 1
      CALL log_message("HORZ_SECTION_TYPE found",log_level_debug)
     ENDIF
    OF mic_section_type:
     IF (mic_section_found=0)
      SET mic_section_found = 1
      CALL log_message("MIC_SECTION_TYPE found",log_level_debug)
     ENDIF
    OF ord_sum_section_type:
     IF (ord_sum_section_found=0)
      SET ord_sum_section_found = 1
      CALL log_message("ORD_SUM_SECTION_TYPE found",log_level_debug)
     ENDIF
    OF rad_section_type:
     IF (rad_section_found=0)
      SET rad_section_found = 1
      CALL log_message("RAD_SECTION_TYPE found",log_level_debug)
     ENDIF
    OF vert_section_type:
     IF (vert_section_found=0)
      SET vert_section_found = 1
      CALL log_message("VERT_SECTION_TYPE found",log_level_debug)
     ENDIF
    OF zonal_old_section_type:
     IF (zonal_old_section_found=0)
      SET zonal_old_section_found = 1
      CALL log_message("ZONAL_OLD_SECTION_TYPE found",log_level_debug)
     ENDIF
    OF ap_section_type:
     IF (ap_section_found=0)
      SET ap_section_found = 1
      CALL log_message("AP_SECTION_TYPE found",log_level_debug)
     ENDIF
    OF hla_section_type:
     IF (hla_section_found=0)
      SET hla_section_found = 1
      CALL log_message("HLA_SECTION_TYPE found",log_level_debug)
     ENDIF
    OF doc_section_type:
     IF (doc_section_found=0)
      SET doc_section_found = 1
      CALL log_message("DOC_SECTION_TYPE found",log_level_debug)
     ENDIF
    OF lab_text_section_type:
     IF (lab_text_section_found=0)
      SET lab_text_section_found = 1
      CALL log_message("LAB_TEXT_SECTION_TYPE found",log_level_debug)
     ENDIF
    OF allergy_section_type:
     IF (allergy_section_found=0)
      SET allergy_section_found = 1
      CALL log_message("ALLERGY_SECTION_TYPE found",log_level_debug)
     ENDIF
    OF prob_list_section_type:
     IF (prob_list_section_found=0)
      SET prob_list_section_found = 1
      CALL log_message("PROB_LIST_SECTION_TYPE found",log_level_debug)
     ENDIF
    OF zonal_new_section_type:
     IF (zonal_new_section_found=0)
      SET zonal_new_section_found = 1
      CALL log_message("ZONAL_NEW_SECTION_TYPE found",log_level_debug)
     ENDIF
    OF orders_section_type:
     IF (orders_section_found=0)
      SET orders_section_found = 1
      CALL log_message("ORDERS_SECTION_TYPE found",log_level_debug)
     ENDIF
    OF mar_section_type:
     IF (mar_section_found=0)
      SET mar_section_found = 1
      CALL log_message("MAR_SECTION_TYPE found",log_level_debug)
     ENDIF
    OF name_hist_section_type:
     IF (name_hist_section_found=0)
      SET name_hist_section_found = 1
      CALL log_message("NAME_HIST_SECTION_TYPE found",log_level_debug)
     ENDIF
    OF immun_section_type:
     IF (immun_section_found=0)
      SET immun_section_found = 1
      CALL log_message("IMMUN_SECTION_TYPE found",log_level_debug)
     ENDIF
    OF proc_hist_section_type:
     IF (proc_hist_section_found=0)
      SET proc_hist_section_found = 1
      CALL log_message("PROC_HIST_SECTION_TYPE found",log_level_debug)
     ENDIF
    OF mar2_section_type:
     IF (mar2_section_found=0)
      SET mar2_section_found = 1
      CALL log_message("MAR2_SECTION_TYPE found",log_level_debug)
     ENDIF
    OF io_section_type:
     IF (io_section_found=0)
      SET io_section_found = 1
      CALL log_message("IO_SECTION_TYPE found",log_level_debug)
     ENDIF
    OF med_prof_hist_section_type:
     IF (med_prof_hist_section_found=0)
      SET med_prof_hist_section_found = 1
      CALL log_message("MED_PROF_HIST_SECTION_TYPE found",log_level_debug)
     ENDIF
    OF user_defined_section_type:
     IF (user_defined_section_found=0)
      SET user_defined_section_found = 1
      CALL log_message("USER_DEFINED_SECTION_TYPE found",log_level_debug)
     ENDIF
    OF pwrfrm_section_type:
     IF (pwrfrm_section_found=0)
      SET pwrfrm_section_found = 1
      CALL log_message("PWRFRM_SECTION_TYPE found",log_level_debug)
     ENDIF
    OF listview_section_type:
     IF (listview_section_found=0)
      SET listview_section_found = 1
      CALL log_message("LISTVIEW_SECTION_TYPE found",log_level_debug)
     ENDIF
   ENDCASE
 END ;Subroutine
 SUBROUTINE getsectiongroupinfo(null)
   CALL log_message("In GetSectionGroupInfo()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE idx1 = i4 WITH noconstant(0), protect
   DECLARE idxstart = i4 WITH noconstant(1), protect
   DECLARE noptimizedtotal = i4 WITH noconstant(0), protect
   DECLARE nrecordsize = i4 WITH noconstant(0), protect
   DECLARE stemp = vc
   IF (size(request->qual,5) > 0)
    SET nrecordsize = size(request->qual,5)
    SET noptimizedtotal = (ceil((cnvtreal(nrecordsize)/ bind_cnt)) * bind_cnt)
    SET stat = alterlist(request->qual,noptimizedtotal)
    FOR (i = (nrecordsize+ 1) TO noptimizedtotal)
      SET request->qual[i].chart_section_id = request->qual[nrecordsize].chart_section_id
    ENDFOR
   ENDIF
   SELECT INTO "nl:"
    cs.chart_section_id, cg.chart_group_id, ce.event_set_name
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     chart_section cs,
     chart_group cg,
     chart_grp_evnt_set ce
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (cs
     WHERE expand(idx1,idxstart,((idxstart+ bind_cnt) - 1),cs.chart_section_id,request->qual[idx1].
      chart_section_id,
      bind_cnt))
     JOIN (cg
     WHERE cg.chart_section_id=cs.chart_section_id)
     JOIN (ce
     WHERE (ce.chart_group_id= Outerjoin(cg.chart_group_id)) )
    ORDER BY cs.chart_section_id, cg.cg_sequence, ce.event_set_seq
    HEAD REPORT
     donothing = 0
    HEAD cs.chart_section_id
     grpcount = 0, evtcount = 0, qualcount += 1
     IF (qualcount > size(reply->qual,5))
      stat = alterlist(reply->qual,(qualcount+ 9))
     ENDIF
     reply->qual[qualcount].chart_section_id = cs.chart_section_id, reply->qual[qualcount].
     chart_section_desc = cs.chart_section_desc, reply->qual[qualcount].section_type_flag = cs
     .section_type_flag,
     reply->qual[qualcount].sect_page_brk_ind = cs.sect_page_brk_ind,
     CALL checksectiontype(null)
    HEAD cg.cg_sequence
     grpcount += 1
     IF (mod(grpcount,10)=1)
      stat = alterlist(reply->qual[qualcount].chart_group_list,(grpcount+ 9))
     ENDIF
     reply->qual[qualcount].chart_group_list[grpcount].chart_group_id = cg.chart_group_id, reply->
     qual[qualcount].chart_group_list[grpcount].chart_group_desc = cg.chart_group_desc, reply->qual[
     qualcount].chart_group_list[grpcount].enhanced_layout_ind = cg.enhanced_layout_ind,
     reply->qual[qualcount].chart_group_list[grpcount].max_results = cg.max_results, group_rec->cnt
      += 1
     IF ((group_rec->cnt > size(group_rec->qual,5)))
      stat = alterlist(group_rec->qual,(group_rec->cnt+ 9))
     ENDIF
     group_rec->qual[group_rec->cnt].group_id = cg.chart_group_id, group_rec->qual[group_rec->cnt].
     group_seq = grpcount, group_rec->qual[group_rec->cnt].section_seq = qualcount,
     group_rec->qual[group_rec->cnt].section_type_flag = cs.section_type_flag, evtcount = 0
    DETAIL
     IF (ce.event_set_seq > 0)
      evtcount += 1
      IF (mod(evtcount,10)=1)
       stat = alterlist(reply->qual[qualcount].chart_group_list[grpcount].chart_event_list,(evtcount
        + 9))
      ENDIF
      reply->qual[qualcount].chart_group_list[grpcount].chart_event_list[evtcount].event_set_name =
      ce.event_set_name, reply->qual[qualcount].chart_group_list[grpcount].chart_event_list[evtcount]
      .synonym_id = ce.synonym_id, reply->qual[qualcount].chart_group_list[grpcount].
      chart_event_list[evtcount].order_catalog_cd = ce.order_catalog_cd,
      reply->qual[qualcount].chart_group_list[grpcount].chart_event_list[evtcount].
      procedure_type_flag = ce.procedure_type_flag, reply->qual[qualcount].chart_group_list[grpcount]
      .chart_event_list[evtcount].display_name = ce.display_name, reply->qual[qualcount].
      chart_group_list[grpcount].chart_event_list[evtcount].zone = ce.zone
      IF ((group_rec->qual[group_rec->cnt].section_type_flag=pwrfrm_section_type))
       temp_rec->cnt += 1
       IF (mod(temp_rec->cnt,5)=1)
        stat = alterlist(temp_rec->qual,(temp_rec->cnt+ 4))
       ENDIF
       temp_rec->qual[temp_rec->cnt].event_set_name = ce.event_set_name, temp_rec->qual[temp_rec->cnt
       ].qual_idx = qualcount, temp_rec->qual[temp_rec->cnt].group_idx = grpcount,
       temp_rec->qual[temp_rec->cnt].event_idx = evtcount
      ENDIF
     ENDIF
    FOOT  cg.cg_sequence
     stat = alterlist(reply->qual[qualcount].chart_group_list[grpcount].chart_event_list,evtcount)
    FOOT  cs.chart_section_id
     stat = alterlist(reply->qual[qualcount].chart_group_list,grpcount)
    FOOT REPORT
     donothing = 0, stat = alterlist(reply->qual,qualcount), stat = alterlist(temp_rec->qual,temp_rec
      ->cnt)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_SECTION","GETSECTIONGROUPINFO",1,1)
   CALL log_message(build("Exit GetSectionGroupInfo(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getpowerformnames(null)
   CALL log_message("In GetPowerFormNames()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE idx = i4 WITH noconstant(0), protect
   DECLARE idx1 = i4 WITH noconstant(0), protect
   DECLARE idx2 = i4 WITH noconstant(0), protect
   DECLARE idxstart = i4 WITH noconstant(1), protect
   DECLARE idxstart2 = i4 WITH noconstant(1), protect
   DECLARE noptimizedtotal = i4 WITH noconstant(0), protect
   DECLARE nrecordsize = i4 WITH noconstant(0), protect
   DECLARE stemp = vc
   IF (size(temp_rec->qual,5) > 0)
    SET nrecordsize = size(temp_rec->qual,5)
    SET noptimizedtotal = (ceil((cnvtreal(nrecordsize)/ bind_cnt)) * bind_cnt)
    SET stat = alterlist(temp_rec->qual,noptimizedtotal)
    FOR (i = (nrecordsize+ 1) TO noptimizedtotal)
      SET temp_rec->qual[i].event_set_name = temp_rec->qual[nrecordsize].event_set_name
      SET temp_rec->qual[i].qual_idx = temp_rec->qual[nrecordsize].qual_idx
      SET temp_rec->qual[i].group_idx = temp_rec->qual[nrecordsize].group_idx
      SET temp_rec->qual[i].event_idx = temp_rec->qual[nrecordsize].event_idx
    ENDFOR
    SELECT DISTINCT INTO "nl:"
     r.dcp_forms_ref_id
     FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
      dcp_forms_ref r
     PLAN (d
      WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
      JOIN (r
      WHERE expand(idx1,idxstart,((idxstart+ bind_cnt) - 1),r.event_set_name,temp_rec->qual[idx1].
       event_set_name)
       AND r.dcp_forms_ref_id > 0
       AND r.active_ind=1
       AND r.event_set_name > "")
     HEAD REPORT
      qualcount = 0
     DETAIL
      locval = locateval(idx,1,size(temp_rec->qual,5),r.event_set_name,temp_rec->qual[idx].
       event_set_name)
      WHILE (locval)
        q_idx = temp_rec->qual[locval].qual_idx, g_idx = temp_rec->qual[locval].group_idx, e_idx =
        temp_rec->qual[locval].event_idx,
        reply->qual[q_idx].chart_group_list[g_idx].chart_event_list[e_idx].dcp_forms_ref_id = r
        .dcp_forms_ref_id, reply->qual[q_idx].chart_group_list[g_idx].chart_event_list[e_idx].
        powerform_name = r.description, locval = locateval(idx,(locval+ 1),size(temp_rec->qual,5),r
         .event_set_name,temp_rec->qual[idx].event_set_name)
      ENDWHILE
     WITH nocounter
    ;end select
    CALL error_and_zero_check(curqual,"DCP_FORMS_REF","GETPOWERFORMNAMES",1,0)
   ENDIF
   CALL log_message(build("Exit GetPowerFormNames(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getxencntrsectioninformation(null)
   CALL log_message("In GetXEncntrSectionInformation()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     chart_xencntr_format xe
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (xe
     WHERE expand(idx1,idxstart,((idxstart+ bind_cnt) - 1),xe.chart_group_id,group_rec->qual[idx1].
      group_id,
      xencntr_section_type,group_rec->qual[idx1].section_type_flag,bind_cnt))
    DETAIL
     loc = locateval(idx2,1,group_rec->cnt,xe.chart_group_id,group_rec->qual[idx2].group_id)
     IF (loc > 0)
      sect_seq = group_rec->qual[loc].section_seq, group_seq = group_rec->qual[loc].group_seq, reply
      ->qual[sect_seq].chart_group_list[group_seq].xencntr_info.rslt_seq = xe.rslt_seq_flag,
      reply->qual[sect_seq].chart_group_list[group_seq].xencntr_info.prefix_format_flag = xe
      .ea_prefix_format_flag, reply->qual[sect_seq].chart_group_list[group_seq].xencntr_info.
      prefix_format = xe.ea_prefix_format, reply->qual[sect_seq].chart_group_list[group_seq].
      xencntr_info.encntr_alias_lbl = xe.encntr_alias_lbl,
      reply->qual[sect_seq].chart_group_list[group_seq].xencntr_info.encntr_alias_odr = xe
      .encntr_alias_odr, reply->qual[sect_seq].chart_group_list[group_seq].xencntr_info.facility_lbl
       = xe.facility_lbl, reply->qual[sect_seq].chart_group_list[group_seq].xencntr_info.building_lbl
       = xe.building_lbl,
      reply->qual[sect_seq].chart_group_list[group_seq].xencntr_info.nurse_unit_lbl = xe
      .nurse_unit_lbl, reply->qual[sect_seq].chart_group_list[group_seq].xencntr_info.client_lbl = xe
      .client_lbl, reply->qual[sect_seq].chart_group_list[group_seq].xencntr_info.fin_nbr_lbl = xe
      .fin_nbr_lbl,
      reply->qual[sect_seq].chart_group_list[group_seq].xencntr_info.mrn_lbl = xe.mrn_lbl, reply->
      qual[sect_seq].chart_group_list[group_seq].xencntr_info.admit_dt_lbl = xe.admit_dt_lbl, reply->
      qual[sect_seq].chart_group_list[group_seq].xencntr_info.dischg_dt_lbl = xe.dischg_dt_lbl,
      reply->qual[sect_seq].chart_group_list[group_seq].xencntr_info.diagnosis_lbl = xe.diagnosis_lbl,
      reply->qual[sect_seq].chart_group_list[group_seq].xencntr_info.facility_odr = xe.facility_odr,
      reply->qual[sect_seq].chart_group_list[group_seq].xencntr_info.building_odr = xe.building_odr,
      reply->qual[sect_seq].chart_group_list[group_seq].xencntr_info.nurse_unit_odr = xe
      .nurse_unit_odr, reply->qual[sect_seq].chart_group_list[group_seq].xencntr_info.client_odr = xe
      .client_odr, reply->qual[sect_seq].chart_group_list[group_seq].xencntr_info.fin_nbr_odr = xe
      .fin_nbr_odr,
      reply->qual[sect_seq].chart_group_list[group_seq].xencntr_info.mrn_odr = xe.mrn_odr, reply->
      qual[sect_seq].chart_group_list[group_seq].xencntr_info.admit_dt_odr = xe.admit_dt_odr, reply->
      qual[sect_seq].chart_group_list[group_seq].xencntr_info.dischg_dt_odr = xe.dischg_dt_odr,
      reply->qual[sect_seq].chart_group_list[group_seq].xencntr_info.diagnosis_odr = xe.diagnosis_odr
     ENDIF
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_XENCNTR_FORMAT","GETXENCNTRSECTIONINFORMATION",1,1)
   CALL log_message(build("Exit GetXEncntrSectionInformation(), Elapsed time in seconds:",
     datetimediff(cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getflexsectioninformation(null)
   CALL log_message("In GetFlexSectionInformation()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     chart_flex_format cff
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (cff
     WHERE expand(idx1,idxstart,((idxstart+ bind_cnt) - 1),cff.chart_group_id,group_rec->qual[idx1].
      group_id,
      flex_section_type,group_rec->qual[idx1].section_type_flag,bind_cnt))
    DETAIL
     loc = locateval(idx2,1,group_rec->cnt,cff.chart_group_id,group_rec->qual[idx2].group_id)
     IF (loc > 0)
      sect_seq = group_rec->qual[loc].section_seq, group_seq = group_rec->qual[loc].group_seq, reply
      ->qual[sect_seq].chart_group_list[group_seq].flex_info.flex_type = cff.flex_type,
      reply->qual[sect_seq].chart_group_list[group_seq].flex_info.prod_nbr_lbl = cff.product_nbr_lbl,
      reply->qual[sect_seq].chart_group_list[group_seq].flex_info.desc_lbl = cff.description_lbl,
      reply->qual[sect_seq].chart_group_list[group_seq].flex_info.disp_lbl = cff.display_lbl,
      reply->qual[sect_seq].chart_group_list[group_seq].flex_info.abo_lbl = cff.abo_rh_lbl, reply->
      qual[sect_seq].chart_group_list[group_seq].flex_info.verified_dt_lbl = cff.verified_dt_tm_lbl,
      reply->qual[sect_seq].chart_group_list[group_seq].flex_info.collected_dt_lbl = cff
      .collected_dt_tm_lbl,
      reply->qual[sect_seq].chart_group_list[group_seq].flex_info.prod_nbr_odr = cff
      .product_nbr_order, reply->qual[sect_seq].chart_group_list[group_seq].flex_info.desc_odr = cff
      .description_order, reply->qual[sect_seq].chart_group_list[group_seq].flex_info.disp_odr = cff
      .display_order,
      reply->qual[sect_seq].chart_group_list[group_seq].flex_info.abo_odr = cff.abo_rh_order, reply->
      qual[sect_seq].chart_group_list[group_seq].flex_info.verified_dt_odr = cff.verified_dt_tm_order,
      reply->qual[sect_seq].chart_group_list[group_seq].flex_info.collected_dt_odr = cff
      .collected_dt_tm_order,
      reply->qual[sect_seq].chart_group_list[group_seq].flex_info.result_seq = cff.order_seq_flag,
      reply->qual[sect_seq].chart_group_list[group_seq].flex_info.crossmatch_result_lbl = cff
      .crossmatch_result_lbl, reply->qual[sect_seq].chart_group_list[group_seq].flex_info.
      crossmatch_result_odr = cff.crossmatch_result_order,
      reply->qual[sect_seq].chart_group_list[group_seq].flex_info.product_status_odr = cff
      .product_status_order, reply->qual[sect_seq].chart_group_list[group_seq].flex_info.
      product_status_lbl = cff.product_status_lbl, reply->qual[sect_seq].chart_group_list[group_seq].
      flex_info.received_dt_odr = cff.received_dt_tm_order,
      reply->qual[sect_seq].chart_group_list[group_seq].flex_info.received_dt_lbl = cff
      .received_dt_tm_lbl
     ENDIF
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_FLEX_FORMAT","GETFLEXSECTIONINFORMATION",1,1)
   CALL log_message(build("Exit GetFlexSectionInformation(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE gethorizontalsectioninformation(null)
   CALL log_message("In GetHorizontalSectionInformation()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     chart_horz_format chf
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (chf
     WHERE expand(idx1,idxstart,((idxstart+ bind_cnt) - 1),chf.chart_group_id,group_rec->qual[idx1].
      group_id,
      horz_section_type,group_rec->qual[idx1].section_type_flag,bind_cnt))
    ORDER BY chf.chart_group_id
    DETAIL
     loc = locateval(idx2,1,group_rec->cnt,chf.chart_group_id,group_rec->qual[idx2].group_id)
     IF (loc > 0)
      sect_seq = group_rec->qual[loc].section_seq, group_seq = group_rec->qual[loc].group_seq, stat
       = alterlist(reply->qual[sect_seq].chart_group_list[group_seq].horizontal_info_list,1),
      reply->qual[sect_seq].chart_group_list[group_seq].horizontal_info_list[1].test_lbl_order = chf
      .test_lbl_order, reply->qual[sect_seq].chart_group_list[group_seq].horizontal_info_list[1].
      units_lbl_order = chf.units_lbl_order, reply->qual[sect_seq].chart_group_list[group_seq].
      horizontal_info_list[1].refer_lbl_order = chf.refer_lbl_order,
      reply->qual[sect_seq].chart_group_list[group_seq].horizontal_info_list[1].normall_lbl_order =
      chf.normall_lbl_order, reply->qual[sect_seq].chart_group_list[group_seq].horizontal_info_list[1
      ].normalh_lbl_order = chf.normalh_lbl_order, reply->qual[sect_seq].chart_group_list[group_seq].
      horizontal_info_list[1].perfid_lbl_order = chf.perfid_lbl_order,
      reply->qual[sect_seq].chart_group_list[group_seq].horizontal_info_list[1].date_order = chf
      .date_order, reply->qual[sect_seq].chart_group_list[group_seq].horizontal_info_list[1].
      weekday_order = chf.weekday_order, reply->qual[sect_seq].chart_group_list[group_seq].
      horizontal_info_list[1].staydays_order = chf.staydays_order,
      reply->qual[sect_seq].chart_group_list[group_seq].horizontal_info_list[1].time_order = chf
      .time_order, reply->qual[sect_seq].chart_group_list[group_seq].horizontal_info_list[1].test_lbl
       = chf.test_lbl, reply->qual[sect_seq].chart_group_list[group_seq].horizontal_info_list[1].
      units_lbl = chf.units_lbl,
      reply->qual[sect_seq].chart_group_list[group_seq].horizontal_info_list[1].ref_range_lbl = chf
      .ref_range_lbl, reply->qual[sect_seq].chart_group_list[group_seq].horizontal_info_list[1].
      normal_low_lbl = chf.normal_low_lbl, reply->qual[sect_seq].chart_group_list[group_seq].
      horizontal_info_list[1].normal_high_lbl = chf.normal_high_lbl,
      reply->qual[sect_seq].chart_group_list[group_seq].horizontal_info_list[1].perfid_lbl = chf
      .perfid_lbl, reply->qual[sect_seq].chart_group_list[group_seq].horizontal_info_list[1].
      date_mask = chf.date_mask, reply->qual[sect_seq].chart_group_list[group_seq].
      horizontal_info_list[1].time_mask = chf.time_mask,
      reply->qual[sect_seq].chart_group_list[group_seq].horizontal_info_list[1].ref_rng_form_flag =
      chf.ref_rng_form_flag, reply->qual[sect_seq].chart_group_list[group_seq].horizontal_info_list[1
      ].rslt_seq_flag = chf.rslt_seq_flag, reply->qual[sect_seq].chart_group_list[group_seq].
      horizontal_info_list[1].ftnote_loc_flag = chf.ftnote_loc_flag,
      reply->qual[sect_seq].chart_group_list[group_seq].horizontal_info_list[1].interp_loc_flag = chf
      .interp_loc_flag, reply->qual[sect_seq].chart_group_list[group_seq].horizontal_info_list[1].
      wkday_format_flag = chf.wkday_format_flag, reply->qual[sect_seq].chart_group_list[group_seq].
      horizontal_info_list[1].rslt_start_col = chf.rslt_start_col,
      reply->qual[sect_seq].chart_group_list[group_seq].horizontal_info_list[1].encntr_alias_order =
      chf.encntr_alias_order, reply->qual[sect_seq].chart_group_list[group_seq].horizontal_info_list[
      1].flowsheet_ind = chf.flowsheet_ind
     ENDIF
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_HORZ_FORMAT","GETHORIZONTALSECTIONINFORMATION",1,1)
   CALL log_message(build("Exit GetHorizontalSectionInformation(), Elapsed time in seconds:",
     datetimediff(cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getmicrosectioninformation(null)
   CALL log_message("In GetMicroSectionInformation()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   FREE RECORD mic_group_rec
   RECORD mic_group_rec(
     1 cnt = i4
     1 qual[*]
       2 group_id = f8
       2 group_seq = i4
       2 section_seq = i4
       2 option_seq = i4
   )
   SELECT INTO "nl:"
    d.object_name
    FROM dprotect d
    PLAN (d
     WHERE d.object="T"
      AND d.object_name="CHART_MICRO_FORMAT")
    WITH nocounter
   ;end select
   IF (curqual)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
      chart_micro_format cmf
     PLAN (d
      WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
      JOIN (cmf
      WHERE expand(idx1,idxstart,((idxstart+ bind_cnt) - 1),cmf.chart_group_id,group_rec->qual[idx1].
       group_id,
       mic_section_type,group_rec->qual[idx1].section_type_flag,bind_cnt))
     ORDER BY cmf.chart_group_id
     HEAD cmf.chart_group_id
      opt_nbr = 0
     DETAIL
      loc = locateval(idx2,1,group_rec->cnt,cmf.chart_group_id,group_rec->qual[idx2].group_id)
      IF (loc > 0)
       sect_seq = group_rec->qual[loc].section_seq, group_seq = group_rec->qual[loc].group_seq,
       opt_nbr += 1
       IF (opt_nbr > size(reply->qual[sect_seq].chart_group_list[group_seq].micro_info.option_list,5)
       )
        stat = alterlist(reply->qual[sect_seq].chart_group_list[group_seq].micro_info.option_list,(
         opt_nbr+ 4))
       ENDIF
       reply->qual[sect_seq].chart_group_list[group_seq].micro_info.option_list[opt_nbr].option_flag
        = cmf.option_flag
       IF (cmf.option_flag=57)
        mic_group_rec->cnt += 1
        IF ((mic_group_rec->cnt > size(mic_group_rec->qual,5)))
         stat = alterlist(mic_group_rec->qual,(mic_group_rec->cnt+ 9))
        ENDIF
        IF (cmf.chart_group_id=0.0)
         CALL echo("HERE HERE HERE")
        ENDIF
        mic_group_rec->qual[mic_group_rec->cnt].group_id = cmf.chart_group_id, mic_group_rec->qual[
        mic_group_rec->cnt].group_seq = group_seq, mic_group_rec->qual[mic_group_rec->cnt].option_seq
         = opt_nbr,
        mic_group_rec->qual[mic_group_rec->cnt].section_seq = sect_seq
       ELSE
        reply->qual[sect_seq].chart_group_list[group_seq].micro_info.option_list[opt_nbr].
        option_value = cmf.option_value
       ENDIF
      ENDIF
     FOOT  cmf.chart_group_id
      IF (loc > 0)
       stat = alterlist(reply->qual[sect_seq].chart_group_list[group_seq].micro_info.option_list,
        opt_nbr)
      ENDIF
     WITH nocounter
    ;end select
    CALL error_and_zero_check(curqual,"CHART_MICRO_FORMAT","GETMICROSECTIONINFORMATION",1,0)
    DECLARE idx3 = i4 WITH noconstant(0), protect
    DECLARE idxstart3 = i4 WITH noconstant(1), protect
    DECLARE nrecordsize3 = i4 WITH noconstant(0), protect
    DECLARE noptimizedtotal3 = i4 WITH noconstant(0), protect
    IF ((mic_group_rec->cnt > 0))
     SET nrecordsize3 = mic_group_rec->cnt
     SET noptimizedtotal3 = (ceil((cnvtreal(nrecordsize3)/ bind_cnt)) * bind_cnt)
     SET stat = alterlist(mic_group_rec->qual,noptimizedtotal3)
     FOR (i = (nrecordsize3+ 1) TO noptimizedtotal3)
       SET mic_group_rec->qual[i].group_id = mic_group_rec->qual[nrecordsize3].group_id
       SET mic_group_rec->qual[i].group_seq = mic_group_rec->qual[nrecordsize3].group_seq
       SET mic_group_rec->qual[i].option_seq = mic_group_rec->qual[nrecordsize3].option_seq
       SET mic_group_rec->qual[i].section_seq = mic_group_rec->qual[nrecordsize3].section_seq
     ENDFOR
    ENDIF
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal3 - 1)/ bind_cnt)))),
      long_text lt
     PLAN (d
      WHERE initarray(idxstart3,evaluate(d.seq,1,1,(idxstart3+ bind_cnt))))
      JOIN (lt
      WHERE expand(idx3,idxstart3,((idxstart3+ bind_cnt) - 1),lt.parent_entity_id,mic_group_rec->
       qual[idx3].group_id,
       bind_cnt)
       AND lt.parent_entity_name="CHART MICRO LEGEND"
       AND lt.active_ind=1)
     HEAD lt.parent_entity_id
      loc = locateval(idx2,1,mic_group_rec->cnt,lt.parent_entity_id,mic_group_rec->qual[idx2].
       group_id)
      IF (loc > 0)
       sect_seq = mic_group_rec->qual[loc].section_seq, group_seq = mic_group_rec->qual[loc].
       group_seq, opt_seq = mic_group_rec->qual[loc].option_seq,
       reply->qual[sect_seq].chart_group_list[group_seq].micro_info.option_list[opt_seq].option_value
        = lt.long_text
      ENDIF
     DETAIL
      donothing = 0
     FOOT  lt.parent_entity_id
      donothing = 0
     WITH nocounter
    ;end select
    CALL error_and_zero_check(curqual,"LONG_TEXT","GETMICROSECTIONINFORMATION",1,0)
   ENDIF
   CALL log_message(build("Exit GetMicroSectionInformation(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getordersumsectioninformation(null)
   CALL log_message("In GetOrderSumSectionInformation()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     chart_order_summary_format cosf,
     chart_ord_sum_filter osf
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (cosf
     WHERE expand(idx1,idxstart,((idxstart+ bind_cnt) - 1),cosf.chart_group_id,group_rec->qual[idx1].
      group_id,
      ord_sum_section_type,group_rec->qual[idx1].section_type_flag,bind_cnt))
     JOIN (osf
     WHERE osf.chart_group_id=cosf.chart_group_id)
    ORDER BY cosf.chart_group_id, osf.sequence
    HEAD cosf.chart_group_id
     loc = locateval(idx2,1,group_rec->cnt,cosf.chart_group_id,group_rec->qual[idx2].group_id)
     IF (loc > 0)
      sect_seq = group_rec->qual[loc].section_seq, group_seq = group_rec->qual[loc].group_seq,
      filter_count = 0,
      reply->qual[sect_seq].chart_group_list[group_seq].order_summary_info.order_summary_type = cosf
      .order_summary_type, reply->qual[sect_seq].chart_group_list[group_seq].order_summary_info.
      date_lbl = cosf.date_lbl, reply->qual[sect_seq].chart_group_list[group_seq].order_summary_info.
      time_lbl = cosf.time_lbl,
      reply->qual[sect_seq].chart_group_list[group_seq].order_summary_info.name_lbl = cosf.name_lbl,
      reply->qual[sect_seq].chart_group_list[group_seq].order_summary_info.mnemonic_lbl = cosf
      .mnemonic_lbl, reply->qual[sect_seq].chart_group_list[group_seq].order_summary_info.status_lbl
       = cosf.status_lbl,
      reply->qual[sect_seq].chart_group_list[group_seq].order_summary_info.cancel_reason_lbl = cosf
      .cancel_reason_lbl, reply->qual[sect_seq].chart_group_list[group_seq].order_summary_info.
      date_mask = cosf.date_mask, reply->qual[sect_seq].chart_group_list[group_seq].
      order_summary_info.time_mask = cosf.time_mask,
      reply->qual[sect_seq].chart_group_list[group_seq].order_summary_info.date_odr = cosf.date_order,
      reply->qual[sect_seq].chart_group_list[group_seq].order_summary_info.time_odr = cosf.time_order,
      reply->qual[sect_seq].chart_group_list[group_seq].order_summary_info.name_odr = cosf.name_order,
      reply->qual[sect_seq].chart_group_list[group_seq].order_summary_info.mnemonic_odr = cosf
      .mnemonic_order, reply->qual[sect_seq].chart_group_list[group_seq].order_summary_info.
      status_odr = cosf.status_order, reply->qual[sect_seq].chart_group_list[group_seq].
      order_summary_info.cancel_reason_odr = cosf.cancel_reason_order,
      reply->qual[sect_seq].chart_group_list[group_seq].order_summary_info.order_seq_flag = cosf
      .order_seq_flag, reply->qual[sect_seq].chart_group_list[group_seq].order_summary_info.
      order_provider_ind = cosf.order_provider_ind, reply->qual[sect_seq].chart_group_list[group_seq]
      .order_summary_info.order_provider_lbl = cosf.order_provider_lbl,
      reply->qual[sect_seq].chart_group_list[group_seq].order_summary_info.order_provider_odr = cosf
      .order_provider_order, reply->qual[sect_seq].chart_group_list[group_seq].order_summary_info.
      dept_status_lbl = cosf.dept_status_lbl, reply->qual[sect_seq].chart_group_list[group_seq].
      order_summary_info.dept_status_odr = cosf.dept_status_order
     ENDIF
    DETAIL
     IF (loc > 0)
      filter_count += 1
      IF (mod(filter_count,5)=1)
       stat = alterlist(reply->qual[sect_seq].chart_group_list[group_seq].order_summary_info.
        os_filter_list,(filter_count+ 4))
      ENDIF
      reply->qual[sect_seq].chart_group_list[group_seq].order_summary_info.os_filter_list[
      filter_count].filter_cd = osf.filter_cd, reply->qual[sect_seq].chart_group_list[group_seq].
      order_summary_info.os_filter_list[filter_count].filter_display = uar_get_code_display(osf
       .filter_cd), reply->qual[sect_seq].chart_group_list[group_seq].order_summary_info.
      os_filter_list[filter_count].filter_type = osf.filter_type_flag,
      reply->qual[sect_seq].chart_group_list[group_seq].order_summary_info.os_filter_list[
      filter_count].filter_seq = osf.sequence
     ENDIF
    FOOT  cosf.chart_group_id
     stat = alterlist(reply->qual[sect_seq].chart_group_list[group_seq].order_summary_info.
      os_filter_list,filter_count)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_ORDER_SUMMARY_FORMAT","GETORDERSUMSECTIONINFORMATION",1,1
    )
   CALL log_message(build("Exit GetOrderSumSectionInformation(), Elapsed time in seconds:",
     datetimediff(cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getradiologysectioninformation(null)
   CALL log_message("In GetRadiologySectionInformation()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     chart_rad_format crf
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (crf
     WHERE expand(idx1,idxstart,((idxstart+ bind_cnt) - 1),crf.chart_group_id,group_rec->qual[idx1].
      group_id,
      rad_section_type,group_rec->qual[idx1].section_type_flag,bind_cnt))
    DETAIL
     loc = locateval(idx2,1,group_rec->cnt,crf.chart_group_id,group_rec->qual[idx2].group_id)
     IF (loc > 0)
      sect_seq = group_rec->qual[loc].section_seq, group_seq = group_rec->qual[loc].group_seq, reply
      ->qual[sect_seq].chart_group_list[group_seq].rad_info.group_style = crf.group_style,
      reply->qual[sect_seq].chart_group_list[group_seq].rad_info.reason_annotation = crf
      .reason_annotation, reply->qual[sect_seq].chart_group_list[group_seq].rad_info.reason_caption
       = crf.reason_caption, reply->qual[sect_seq].chart_group_list[group_seq].rad_info.reason_ind =
      crf.reason_ind,
      reply->qual[sect_seq].chart_group_list[group_seq].rad_info.result_sequence = crf
      .result_sequence, reply->qual[sect_seq].chart_group_list[group_seq].rad_info.cpt4_code_ind =
      crf.cpt4_code_ind, reply->qual[sect_seq].chart_group_list[group_seq].rad_info.cpt4_desc_ind =
      crf.cpt4_desc_ind,
      reply->qual[sect_seq].chart_group_list[group_seq].rad_info.cpt4_label = crf.cpt4_label, reply->
      qual[sect_seq].chart_group_list[group_seq].rad_info.cpt4_label_style = crf.cpt4_label_style,
      reply->qual[sect_seq].chart_group_list[group_seq].rad_info.cdm_code_ind = crf.cdm_code_ind,
      reply->qual[sect_seq].chart_group_list[group_seq].rad_info.cdm_desc_ind = crf.cdm_desc_ind,
      reply->qual[sect_seq].chart_group_list[group_seq].rad_info.cdm_label = crf.cdm_label, reply->
      qual[sect_seq].chart_group_list[group_seq].rad_info.cdm_label_style = crf.cdm_label_style,
      reply->qual[sect_seq].chart_group_list[group_seq].rad_info.cor_footnote_ind = crf
      .cor_footnote_ind
     ENDIF
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_RAD_FORMAT","GETRADIOLOGYSECTIONINFORMATION",1,1)
   CALL log_message(build("Exit GetRadiologySectionInformation(), Elapsed time in seconds:",
     datetimediff(cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getverticalsectioninformation(null)
   CALL log_message("In GetVerticalSectionInformation()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     chart_vert_format cvf
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (cvf
     WHERE expand(idx1,idxstart,((idxstart+ bind_cnt) - 1),cvf.chart_group_id,group_rec->qual[idx1].
      group_id,
      vert_section_type,group_rec->qual[idx1].section_type_flag,bind_cnt))
    ORDER BY cvf.chart_group_id
    HEAD cvf.chart_group_id
     loc = locateval(idx2,1,group_rec->cnt,cvf.chart_group_id,group_rec->qual[idx2].group_id)
     IF (loc > 0)
      sect_seq = group_rec->qual[loc].section_seq, group_seq = group_rec->qual[loc].group_seq, stat
       = alterlist(reply->qual[sect_seq].chart_group_list[group_seq].vertical_info_list,1)
     ENDIF
    DETAIL
     IF (loc > 0)
      reply->qual[sect_seq].chart_group_list[group_seq].vertical_info_list[1].test_lbl_order = cvf
      .test_lbl_order, reply->qual[sect_seq].chart_group_list[group_seq].vertical_info_list[1].
      units_lbl_order = cvf.units_lbl_order, reply->qual[sect_seq].chart_group_list[group_seq].
      vertical_info_list[1].refer_lbl_order = cvf.refer_lbl_order,
      reply->qual[sect_seq].chart_group_list[group_seq].vertical_info_list[1].perfid_lbl_order = cvf
      .perfid_lbl_order, reply->qual[sect_seq].chart_group_list[group_seq].vertical_info_list[1].
      test_lbl_pos = cvf.test_lbl_pos, reply->qual[sect_seq].chart_group_list[group_seq].
      vertical_info_list[1].units_lbl_pos = cvf.units_lbl_pos,
      reply->qual[sect_seq].chart_group_list[group_seq].vertical_info_list[1].refer_lbl_pos = cvf
      .refer_lbl_pos, reply->qual[sect_seq].chart_group_list[group_seq].vertical_info_list[1].
      perfid_lbl_pos = cvf.perfid_lbl_pos, reply->qual[sect_seq].chart_group_list[group_seq].
      vertical_info_list[1].test_lbl = cvf.test_lbl,
      reply->qual[sect_seq].chart_group_list[group_seq].vertical_info_list[1].units_lbl = cvf
      .units_lbl, reply->qual[sect_seq].chart_group_list[group_seq].vertical_info_list[1].
      ref_range_lbl = cvf.ref_range_lbl, reply->qual[sect_seq].chart_group_list[group_seq].
      vertical_info_list[1].perfid_lbl = cvf.perfid_lbl,
      reply->qual[sect_seq].chart_group_list[group_seq].vertical_info_list[1].date_lbl = cvf.date_lbl,
      reply->qual[sect_seq].chart_group_list[group_seq].vertical_info_list[1].staydays_lbl = cvf
      .staydays_lbl, reply->qual[sect_seq].chart_group_list[group_seq].vertical_info_list[1].time_lbl
       = cvf.time_lbl,
      reply->qual[sect_seq].chart_group_list[group_seq].vertical_info_list[1].date_order = cvf
      .date_order, reply->qual[sect_seq].chart_group_list[group_seq].vertical_info_list[1].
      staydays_order = cvf.staydays_order, reply->qual[sect_seq].chart_group_list[group_seq].
      vertical_info_list[1].time_order = cvf.time_order,
      reply->qual[sect_seq].chart_group_list[group_seq].vertical_info_list[1].ref_rng_form_flag = cvf
      .ref_rng_form_flag, reply->qual[sect_seq].chart_group_list[group_seq].vertical_info_list[1].
      rslt_seq_flag = cvf.rslt_seq_flag, reply->qual[sect_seq].chart_group_list[group_seq].
      vertical_info_list[1].ftnote_loc_flag = cvf.ftnote_loc_flag,
      reply->qual[sect_seq].chart_group_list[group_seq].vertical_info_list[1].interp_loc_flag = cvf
      .interp_loc_flag, reply->qual[sect_seq].chart_group_list[group_seq].vertical_info_list[1].
      date_mask = cvf.date_mask, reply->qual[sect_seq].chart_group_list[group_seq].
      vertical_info_list[1].time_mask = cvf.time_mask,
      reply->qual[sect_seq].chart_group_list[group_seq].vertical_info_list[1].staydays_form_flag =
      cvf.staydays_form_flag, reply->qual[sect_seq].chart_group_list[group_seq].vertical_info_list[1]
      .rslt_start_col = cvf.reslt_start_col, reply->qual[sect_seq].chart_group_list[group_seq].
      vertical_info_list[1].encntr_alias_order = cvf.encntr_alias_order,
      reply->qual[sect_seq].chart_group_list[group_seq].vertical_info_list[1].encntr_alias_lbl = cvf
      .encntr_alias_lbl, reply->qual[sect_seq].chart_group_list[group_seq].vertical_info_list[1].
      flowsheet_ind = cvf.flowsheet_ind
     ENDIF
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_VERT_FORMAT","GETVERTICALSECTIONINFORMATION",1,1)
   CALL log_message(build("Exit GetVerticalSectionInformation(), Elapsed time in seconds:",
     datetimediff(cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getlistviewsectioninformation(null)
   CALL log_message("In GetListviewSectionInformation()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     chart_listview_format clf
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (clf
     WHERE expand(idx1,idxstart,((idxstart+ bind_cnt) - 1),clf.chart_group_id,group_rec->qual[idx1].
      group_id,
      listview_section_type,group_rec->qual[idx1].section_type_flag,bind_cnt))
    ORDER BY clf.chart_group_id
    HEAD clf.chart_group_id
     loc = locateval(idx2,1,group_rec->cnt,clf.chart_group_id,group_rec->qual[idx2].group_id)
     IF (loc > 0)
      sect_seq = group_rec->qual[loc].section_seq, group_seq = group_rec->qual[loc].group_seq, stat
       = alterlist(reply->qual[sect_seq].chart_group_list[group_seq].listview_info_list,1)
     ENDIF
    DETAIL
     IF (loc > 0)
      CALL echo(clf.chart_group_id), reply->qual[sect_seq].chart_group_list[group_seq].
      listview_info_list[1].resseq_ind = clf.group_result_seq, reply->qual[sect_seq].
      chart_group_list[group_seq].listview_info_list[1].result_ord = clf.result_seq,
      reply->qual[sect_seq].chart_group_list[group_seq].listview_info_list[1].procedure_ord = clf
      .procedure_seq, reply->qual[sect_seq].chart_group_list[group_seq].listview_info_list[1].
      units_ord = clf.units_seq, reply->qual[sect_seq].chart_group_list[group_seq].
      listview_info_list[1].refrange_ord = clf.refrange_seq,
      reply->qual[sect_seq].chart_group_list[group_seq].listview_info_list[1].refrange_ind = clf
      .ref_rng_form_flag, reply->qual[sect_seq].chart_group_list[group_seq].listview_info_list[1].
      accession_ord = clf.accession_seq, reply->qual[sect_seq].chart_group_list[group_seq].
      listview_info_list[1].collected_ord = clf.collected_dt_tm_seq,
      reply->qual[sect_seq].chart_group_list[group_seq].listview_info_list[1].received_ord = clf
      .received_dt_tm_seq, reply->qual[sect_seq].chart_group_list[group_seq].listview_info_list[1].
      verified_ord = clf.verified_dt_tm_seq, reply->qual[sect_seq].chart_group_list[group_seq].
      listview_info_list[1].perfver_ord = clf.perf_ver_prsnl_seq,
      reply->qual[sect_seq].chart_group_list[group_seq].listview_info_list[1].spectype_ord = clf
      .spectype_seq, reply->qual[sect_seq].chart_group_list[group_seq].listview_info_list[1].
      result_lbl = clf.result_txt, reply->qual[sect_seq].chart_group_list[group_seq].
      listview_info_list[1].procedure_lbl = clf.procedure_txt,
      reply->qual[sect_seq].chart_group_list[group_seq].listview_info_list[1].units_lbl = clf
      .units_txt, reply->qual[sect_seq].chart_group_list[group_seq].listview_info_list[1].
      refrange_lbl = clf.refrange_txt, reply->qual[sect_seq].chart_group_list[group_seq].
      listview_info_list[1].accession_lbl = clf.accession_txt,
      reply->qual[sect_seq].chart_group_list[group_seq].listview_info_list[1].collected_lbl = clf
      .collected_txt, reply->qual[sect_seq].chart_group_list[group_seq].listview_info_list[1].
      received_lbl = clf.received_txt, reply->qual[sect_seq].chart_group_list[group_seq].
      listview_info_list[1].verified_lbl = clf.verified_txt,
      reply->qual[sect_seq].chart_group_list[group_seq].listview_info_list[1].perfver_lbl = clf
      .perf_ver_prsnl_txt, reply->qual[sect_seq].chart_group_list[group_seq].listview_info_list[1].
      spectype_lbl = clf.spectype_txt
     ENDIF
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_LISTVIEW_FORMAT","GETLISTVIEWSECTIONINFORMATION",1,1)
   CALL log_message(build("Exit GetListviewSectionInformation(), Elapsed time in seconds:",
     datetimediff(cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getzonaloldsectioninformation(null)
   CALL log_message("In GetZonalOldSectionInformation()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     chart_zonal_format czf,
     chart_zn_form_zone czfz
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (czf
     WHERE expand(idx1,idxstart,((idxstart+ bind_cnt) - 1),czf.chart_group_id,group_rec->qual[idx1].
      group_id,
      zonal_old_section_type,group_rec->qual[idx1].section_type_flag,bind_cnt))
     JOIN (czfz
     WHERE czfz.chart_group_id=czf.chart_group_id)
    ORDER BY czf.chart_group_id, czfz.zone_seq
    HEAD czf.chart_group_id
     itemcount = 0, loc = locateval(idx2,1,group_rec->cnt,czf.chart_group_id,group_rec->qual[idx2].
      group_id)
     IF (loc > 0)
      sect_seq = group_rec->qual[loc].section_seq, group_seq = group_rec->qual[loc].group_seq, stat
       = alterlist(reply->qual[sect_seq].chart_group_list[group_seq].zonal_info_list,1),
      reply->qual[sect_seq].chart_group_list[group_seq].zonal_info_list[1].ref_rng_form_flag = czf
      .ref_rng_form_flag, reply->qual[sect_seq].chart_group_list[group_seq].zonal_info_list[1].
      date_mask = czf.date_mask, reply->qual[sect_seq].chart_group_list[group_seq].zonal_info_list[1]
      .time_mask = czf.time_mask,
      reply->qual[sect_seq].chart_group_list[group_seq].zonal_info_list[1].rslt_seq_flag = czf
      .rslt_seq_flag, reply->qual[sect_seq].chart_group_list[group_seq].zonal_info_list[1].
      ftnote_loc_flag = czf.ftnote_loc_flag, reply->qual[sect_seq].chart_group_list[group_seq].
      zonal_info_list[1].interp_loc_flag = czf.interp_loc_flag
     ENDIF
    DETAIL
     IF (loc > 0)
      itemcount += 1
      IF (mod(itemcount,5)=1)
       stat = alterlist(reply->qual[sect_seq].chart_group_list[group_seq].zonal_info_list,(itemcount
        + 4))
      ENDIF
      reply->qual[sect_seq].chart_group_list[group_seq].zonal_info_list[itemcount].zone_seq = czfz
      .zone_seq, reply->qual[sect_seq].chart_group_list[group_seq].zonal_info_list[itemcount].
      test_lbl = czfz.test_lbl, reply->qual[sect_seq].chart_group_list[group_seq].zonal_info_list[
      itemcount].units_lbl = czfz.units_lbl,
      reply->qual[sect_seq].chart_group_list[group_seq].zonal_info_list[itemcount].ref_range_lbl =
      czfz.ref_range_lbl, reply->qual[sect_seq].chart_group_list[group_seq].zonal_info_list[itemcount
      ].alpha_abn_rslt_lbl = czfz.alpha_abn_rslt_lbl, reply->qual[sect_seq].chart_group_list[
      group_seq].zonal_info_list[itemcount].all_rslt_lbl = czfz.all_rslt_lbl,
      reply->qual[sect_seq].chart_group_list[group_seq].zonal_info_list[itemcount].crit_rslt_lbl =
      czfz.crit_rslt_lbl, reply->qual[sect_seq].chart_group_list[group_seq].zonal_info_list[itemcount
      ].high_rslt_lbl = czfz.high_rslt_lbl, reply->qual[sect_seq].chart_group_list[group_seq].
      zonal_info_list[itemcount].low_rslt_lbl = czfz.low_rslt_lbl,
      reply->qual[sect_seq].chart_group_list[group_seq].zonal_info_list[itemcount].normal_rslt_lbl =
      czfz.normal_rslt_lbl, reply->qual[sect_seq].chart_group_list[group_seq].zonal_info_list[
      itemcount].test_col = czfz.test_col, reply->qual[sect_seq].chart_group_list[group_seq].
      zonal_info_list[itemcount].units_col = czfz.units_col,
      reply->qual[sect_seq].chart_group_list[group_seq].zonal_info_list[itemcount].ref_range_col =
      czfz.ref_range_col, reply->qual[sect_seq].chart_group_list[group_seq].zonal_info_list[itemcount
      ].all_rslt_col = czfz.all_rslt_col, reply->qual[sect_seq].chart_group_list[group_seq].
      zonal_info_list[itemcount].low_rslt_col = czfz.low_rslt_col,
      reply->qual[sect_seq].chart_group_list[group_seq].zonal_info_list[itemcount].normal_rslt_col =
      czfz.normal_rslt_col, reply->qual[sect_seq].chart_group_list[group_seq].zonal_info_list[
      itemcount].high_rslt_col = czfz.high_rslt_col, reply->qual[sect_seq].chart_group_list[group_seq
      ].zonal_info_list[itemcount].crit_rslt_col = czfz.crit_rslt_col,
      reply->qual[sect_seq].chart_group_list[group_seq].zonal_info_list[itemcount].alpha_abn_rslt_col
       = czfz.alpha_abn_rslt_col
     ENDIF
    FOOT  czf.chart_group_id
     stat = alterlist(reply->qual[sect_seq].chart_group_list[group_seq].zonal_info_list,itemcount)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_ZONAL_FORMAT","GETZONALOLDSECTIONINFORMATION",1,1)
   CALL log_message(build("Exit GetZonalOldSectionInformation(), Elapsed time in seconds:",
     datetimediff(cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getapsectioninformation(null)
   CALL log_message("In GetAPSectionInformation()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     chart_ap_format capf,
     long_text_reference ltr
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (capf
     WHERE expand(idx1,idxstart,((idxstart+ bind_cnt) - 1),capf.chart_group_id,group_rec->qual[idx1].
      group_id,
      ap_section_type,group_rec->qual[idx1].section_type_flag,bind_cnt))
     JOIN (ltr
     WHERE capf.ap_cpt_long_text_id=ltr.long_text_id)
    DETAIL
     loc = locateval(idx2,1,group_rec->cnt,capf.chart_group_id,group_rec->qual[idx2].group_id)
     IF (loc > 0)
      sect_seq = group_rec->qual[loc].section_seq, group_seq = group_rec->qual[loc].group_seq, reply
      ->qual[sect_seq].chart_group_list[group_seq].ap_info.group_style = capf.group_style,
      reply->qual[sect_seq].chart_group_list[group_seq].ap_info.result_sequence = capf
      .result_sequence, reply->qual[sect_seq].chart_group_list[group_seq].ap_info.snomed_codes_ind =
      capf.snomed_codes_ind, reply->qual[sect_seq].chart_group_list[group_seq].ap_info.
      snomed_desc_ind = capf.snomed_desc_ind,
      reply->qual[sect_seq].chart_group_list[group_seq].ap_info.snomed_codes_lbl = capf
      .snomed_codes_lbl, reply->qual[sect_seq].chart_group_list[group_seq].ap_info.
      snomed_cd_lbl_style = capf.snomed_cd_lbl_style, reply->qual[sect_seq].chart_group_list[
      group_seq].ap_info.tcc_codes_ind = capf.tcc_codes_ind,
      reply->qual[sect_seq].chart_group_list[group_seq].ap_info.tcc_desc_ind = capf.tcc_desc_ind,
      reply->qual[sect_seq].chart_group_list[group_seq].ap_info.tcc_codes_lbl = capf.tcc_codes_lbl,
      reply->qual[sect_seq].chart_group_list[group_seq].ap_info.tcc_cd_lbl_style = capf
      .tcc_cd_lbl_style,
      reply->qual[sect_seq].chart_group_list[group_seq].ap_info.ap_history_flag = capf
      .ap_history_flag, reply->qual[sect_seq].chart_group_list[group_seq].ap_info.image_flag = capf
      .image_flag
      IF (capf.ap_cpt_long_text_id != 0)
       reply->qual[sect_seq].chart_group_list[group_seq].ap_info.cpt_long_text = ltr.long_text
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_AP_FORMAT","GETAPSECTIONINFORMATION",1,1)
   CALL log_message(build("Exit GetAPSectionInformation(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE gethlasectioninformation(null)
   CALL log_message("In GetHLASectionInformation()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     chart_hla_format hla
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (hla
     WHERE expand(idx1,idxstart,((idxstart+ bind_cnt) - 1),hla.chart_group_id,group_rec->qual[idx1].
      group_id,
      hla_section_type,group_rec->qual[idx1].section_type_flag,bind_cnt))
    DETAIL
     loc = locateval(idx2,1,group_rec->cnt,hla.chart_group_id,group_rec->qual[idx2].group_id)
     IF (loc > 0)
      sect_seq = group_rec->qual[loc].section_seq, group_seq = group_rec->qual[loc].group_seq, reply
      ->qual[sect_seq].chart_group_list[group_seq].hla_info.hla_type = hla.hla_type,
      reply->qual[sect_seq].chart_group_list[group_seq].hla_info.line_ind = hla.line_indicator, reply
      ->qual[sect_seq].chart_group_list[group_seq].hla_info.rslt_seq = hla.result_seq_flag, reply->
      qual[sect_seq].chart_group_list[group_seq].hla_info.prsn_name_lbl = hla.prsn_name_label,
      reply->qual[sect_seq].chart_group_list[group_seq].hla_info.date_lbl = hla.date_label, reply->
      qual[sect_seq].chart_group_list[group_seq].hla_info.mrn_lbl = hla.mrn_label, reply->qual[
      sect_seq].chart_group_list[group_seq].hla_info.relation_lbl = hla.relation_label,
      reply->qual[sect_seq].chart_group_list[group_seq].hla_info.abo_rh_lbl = hla.abo_rh_label, reply
      ->qual[sect_seq].chart_group_list[group_seq].hla_info.haploid1_lbl = hla.haploid1_label, reply
      ->qual[sect_seq].chart_group_list[group_seq].hla_info.haploid2_lbl = hla.haploid2_label,
      reply->qual[sect_seq].chart_group_list[group_seq].hla_info.haplotype1_lbl = hla
      .haplotype1_label, reply->qual[sect_seq].chart_group_list[group_seq].hla_info.haplotype2_lbl =
      hla.haplotype2_label, reply->qual[sect_seq].chart_group_list[group_seq].hla_info.haploid1_odr
       = hla.haploid1_order,
      reply->qual[sect_seq].chart_group_list[group_seq].hla_info.haploid2_odr = hla.haploid2_order,
      reply->qual[sect_seq].chart_group_list[group_seq].hla_info.haplotype1_odr = hla
      .haplotype1_order, reply->qual[sect_seq].chart_group_list[group_seq].hla_info.haplotype2_odr =
      hla.haplotype2_order,
      reply->qual[sect_seq].chart_group_list[group_seq].hla_info.prsn_name_odr = hla.prsn_name_order,
      reply->qual[sect_seq].chart_group_list[group_seq].hla_info.date_odr = hla.date_order, reply->
      qual[sect_seq].chart_group_list[group_seq].hla_info.mrn_odr = hla.mrn_order,
      reply->qual[sect_seq].chart_group_list[group_seq].hla_info.relation_odr = hla.relation_order,
      reply->qual[sect_seq].chart_group_list[group_seq].hla_info.abo_rh_odr = hla.abo_rh_order, reply
      ->qual[sect_seq].chart_group_list[group_seq].hla_info.result_odr = hla.result_order,
      reply->qual[sect_seq].chart_group_list[group_seq].hla_info.prsn_name_rpt = hla.prsn_name_rpt,
      reply->qual[sect_seq].chart_group_list[group_seq].hla_info.date_rpt = hla.date_rpt, reply->
      qual[sect_seq].chart_group_list[group_seq].hla_info.mrn_rpt = hla.mrn_rpt,
      reply->qual[sect_seq].chart_group_list[group_seq].hla_info.relation_rpt = hla.relation_rpt,
      reply->qual[sect_seq].chart_group_list[group_seq].hla_info.abo_rpt = hla.abo_rpt, reply->qual[
      sect_seq].chart_group_list[group_seq].hla_info.rh_ind = hla.rh_ind
     ENDIF
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_HLA_FORMAT","GETHLASECTIONINFORMATION",1,1)
   CALL log_message(build("Exit GetHLASectionInformation(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getdocumentsectioninformation(null)
   CALL log_message("In GetDocumentSectionInformation()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     chart_doc_format doc
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (doc
     WHERE expand(idx1,idxstart,((idxstart+ bind_cnt) - 1),doc.chart_group_id,group_rec->qual[idx1].
      group_id,
      doc_section_type,group_rec->qual[idx1].section_type_flag,bind_cnt))
    DETAIL
     loc = locateval(idx2,1,group_rec->cnt,doc.chart_group_id,group_rec->qual[idx2].group_id)
     IF (loc > 0)
      sect_seq = group_rec->qual[loc].section_seq, group_seq = group_rec->qual[loc].group_seq, reply
      ->qual[sect_seq].chart_group_list[group_seq].doc_info.rslt_seq = doc.result_seq_flag,
      reply->qual[sect_seq].chart_group_list[group_seq].doc_info.pgbrk_ind = doc.page_brk_ind, reply
      ->qual[sect_seq].chart_group_list[group_seq].doc_info.exclude_img_mdoc_ind = doc
      .exclude_img_mdoc_ind, reply->qual[sect_seq].chart_group_list[group_seq].doc_info.
      include_img_head_ind = doc.include_img_header_ind,
      reply->qual[sect_seq].chart_group_list[group_seq].doc_info.include_img_foot_ind = doc
      .include_img_footer_ind, reply->qual[sect_seq].chart_group_list[group_seq].doc_info.doc_type =
      doc.doc_type_flag
     ENDIF
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_DOC_FORMAT","GETDOCUMENTSECTIONINFORMATION",1,1)
   CALL log_message(build("Exit GetDocumentSectionInformation(), Elapsed time in seconds:",
     datetimediff(cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getlabtextsectioninformation(null)
   CALL log_message("In GetLabTextSectionInformation()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     chart_gl_format gl
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (gl
     WHERE expand(idx1,idxstart,((idxstart+ bind_cnt) - 1),gl.chart_group_id,group_rec->qual[idx1].
      group_id,
      lab_text_section_type,group_rec->qual[idx1].section_type_flag,bind_cnt))
    DETAIL
     loc = locateval(idx2,1,group_rec->cnt,gl.chart_group_id,group_rec->qual[idx2].group_id)
     IF (loc > 0)
      sect_seq = group_rec->qual[loc].section_seq, group_seq = group_rec->qual[loc].group_seq, reply
      ->qual[sect_seq].chart_group_list[group_seq].gl_info.rslt_seq = gl.result_seq_flag,
      reply->qual[sect_seq].chart_group_list[group_seq].gl_info.group_style = gl.group_style
     ENDIF
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_GL_FORMAT","GETLABTEXTSECTIONINFORMATION",1,1)
   CALL log_message(build("Exit GetLabTextSectionInformation(), Elapsed time in seconds:",
     datetimediff(cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getallergysectioninformation(null)
   CALL log_message("In GetAllergySectionInformation()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     chart_allergy_format alg
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (alg
     WHERE expand(idx1,idxstart,((idxstart+ bind_cnt) - 1),alg.chart_group_id,group_rec->qual[idx1].
      group_id,
      allergy_section_type,group_rec->qual[idx1].section_type_flag,bind_cnt))
    DETAIL
     loc = locateval(idx2,1,group_rec->cnt,alg.chart_group_id,group_rec->qual[idx2].group_id)
     IF (loc > 0)
      sect_seq = group_rec->qual[loc].section_seq, group_seq = group_rec->qual[loc].group_seq, reply
      ->qual[sect_seq].chart_group_list[group_seq].allergy_info.substance_lbl = alg.substance_lbl,
      reply->qual[sect_seq].chart_group_list[group_seq].allergy_info.category_lbl = alg.category_lbl,
      reply->qual[sect_seq].chart_group_list[group_seq].allergy_info.updt_dt_lbl = alg.updt_dt_lbl,
      reply->qual[sect_seq].chart_group_list[group_seq].allergy_info.severity_lbl = alg.severity_lbl,
      reply->qual[sect_seq].chart_group_list[group_seq].allergy_info.reaction_stat_lbl = alg
      .reaction_stat_lbl, reply->qual[sect_seq].chart_group_list[group_seq].allergy_info.reaction_lbl
       = alg.reaction_lbl, reply->qual[sect_seq].chart_group_list[group_seq].allergy_info.updt_by_lbl
       = alg.updt_by_lbl,
      reply->qual[sect_seq].chart_group_list[group_seq].allergy_info.source_lbl = alg.source_lbl,
      reply->qual[sect_seq].chart_group_list[group_seq].allergy_info.onset_dt_lbl = alg.onset_dt_lbl,
      reply->qual[sect_seq].chart_group_list[group_seq].allergy_info.type_lbl = alg.type_lbl,
      reply->qual[sect_seq].chart_group_list[group_seq].allergy_info.cancel_lbl = alg.cancel_lbl,
      reply->qual[sect_seq].chart_group_list[group_seq].allergy_info.comment_lbl = alg.comment_lbl,
      reply->qual[sect_seq].chart_group_list[group_seq].allergy_info.severity_odr = alg.severity_odr,
      reply->qual[sect_seq].chart_group_list[group_seq].allergy_info.reaction_stat_odr = alg
      .reaction_stat_odr, reply->qual[sect_seq].chart_group_list[group_seq].allergy_info.reaction_odr
       = alg.reaction_odr, reply->qual[sect_seq].chart_group_list[group_seq].allergy_info.source_odr
       = alg.source_odr,
      reply->qual[sect_seq].chart_group_list[group_seq].allergy_info.onset_dt_odr = alg.onset_dt_odr,
      reply->qual[sect_seq].chart_group_list[group_seq].allergy_info.type_odr = alg.type_odr, reply->
      qual[sect_seq].chart_group_list[group_seq].allergy_info.cancel_odr = alg.cancel_odr,
      reply->qual[sect_seq].chart_group_list[group_seq].allergy_info.category_odr = alg.category_odr,
      reply->qual[sect_seq].chart_group_list[group_seq].allergy_info.result_sequence_ind = alg
      .result_sequence_ind
     ENDIF
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_ALLERGY_FORMAT","GETALLERGYSECTIONINFORMATION",1,1)
   CALL log_message(build("Exit GetAllergySectionInformation(), Elapsed time in seconds:",
     datetimediff(cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getproblemlistsectioninformation(null)
   CALL log_message("In GetProblemListSectionInformation()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     chart_problem_format prob
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (prob
     WHERE expand(idx1,idxstart,((idxstart+ bind_cnt) - 1),prob.chart_group_id,group_rec->qual[idx1].
      group_id,
      prob_list_section_type,group_rec->qual[idx1].section_type_flag,bind_cnt))
    DETAIL
     loc = locateval(idx2,1,group_rec->cnt,prob.chart_group_id,group_rec->qual[idx2].group_id)
     IF (loc > 0)
      sect_seq = group_rec->qual[loc].section_seq, group_seq = group_rec->qual[loc].group_seq, reply
      ->qual[sect_seq].chart_group_list[group_seq].prob_info.prob_name_lbl = prob.prob_name_lbl,
      reply->qual[sect_seq].chart_group_list[group_seq].prob_info.date_rec_lbl = prob
      .date_recorded_lbl, reply->qual[sect_seq].chart_group_list[group_seq].prob_info.code_lbl = prob
      .code_lbl, reply->qual[sect_seq].chart_group_list[group_seq].prob_info.con_stat_lbl = prob
      .con_stat_lbl,
      reply->qual[sect_seq].chart_group_list[group_seq].prob_info.life_stat_lbl = prob.life_stat_lbl,
      reply->qual[sect_seq].chart_group_list[group_seq].prob_info.course_lbl = prob.course_lbl, reply
      ->qual[sect_seq].chart_group_list[group_seq].prob_info.perst_lbl = prob.perst_lbl,
      reply->qual[sect_seq].chart_group_list[group_seq].prob_info.prog_lbl = prob.prog_lbl, reply->
      qual[sect_seq].chart_group_list[group_seq].prob_info.onset_lbl = prob.onset_lbl, reply->qual[
      sect_seq].chart_group_list[group_seq].prob_info.prov_lbl = prob.prov_lbl,
      reply->qual[sect_seq].chart_group_list[group_seq].prob_info.date_est_lbl = prob.date_est_lbl,
      reply->qual[sect_seq].chart_group_list[group_seq].prob_info.cancel_lbl = prob.cancel_lbl, reply
      ->qual[sect_seq].chart_group_list[group_seq].prob_info.comment_lbl = prob.comment_lbl,
      reply->qual[sect_seq].chart_group_list[group_seq].prob_info.code_ord = prob.code_ord, reply->
      qual[sect_seq].chart_group_list[group_seq].prob_info.con_stat_ord = prob.con_stat_ord, reply->
      qual[sect_seq].chart_group_list[group_seq].prob_info.life_stat_ord = prob.life_stat_ord,
      reply->qual[sect_seq].chart_group_list[group_seq].prob_info.course_ord = prob.course_ord, reply
      ->qual[sect_seq].chart_group_list[group_seq].prob_info.perst_ord = prob.perst_ord, reply->qual[
      sect_seq].chart_group_list[group_seq].prob_info.prog_ord = prob.prog_ord,
      reply->qual[sect_seq].chart_group_list[group_seq].prob_info.onset_ord = prob.onset_ord, reply->
      qual[sect_seq].chart_group_list[group_seq].prob_info.cancel_ord = prob.cancel_ord, reply->qual[
      sect_seq].chart_group_list[group_seq].prob_info.result_sequence_ind = prob.result_sequence_ind,
      reply->qual[sect_seq].chart_group_list[group_seq].prob_info.date_rec_result_sequence_ind = prob
      .date_recorded_sequence_ind
     ENDIF
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_PROBLEM_FORMAT","GETPROBLEMLISTSECTIONINFORMATION",1,1)
   CALL log_message(build("Exit GetProblemListSectionInformation(), Elapsed time in seconds:",
     datetimediff(cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getzonalnewsectioninformation(null)
   CALL log_message("In GetZonalNewSectionInformation()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     chart_zonal_format czf,
     chart_dyn_zone_form cdzf,
     chart_zn_result_col czrc,
     chart_zn_result_col_cds czrcc
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (czf
     WHERE expand(idx1,idxstart,((idxstart+ bind_cnt) - 1),czf.chart_group_id,group_rec->qual[idx1].
      group_id,
      zonal_new_section_type,group_rec->qual[idx1].section_type_flag,bind_cnt))
     JOIN (cdzf
     WHERE cdzf.chart_group_id=czf.chart_group_id)
     JOIN (czrc
     WHERE czrc.chart_group_id=cdzf.chart_group_id
      AND czrc.zone_seq=cdzf.zone_seq)
     JOIN (czrcc
     WHERE czrcc.chart_group_id=czrc.chart_group_id
      AND czrcc.zone_seq=czrc.zone_seq
      AND czrcc.column_seq=czrc.column_seq)
    ORDER BY czf.chart_group_id, cdzf.zone_seq, czrc.column_seq,
     czrcc.normalcy_cd
    HEAD czf.chart_group_id
     zonecount = 0, colcount = 0, codecount = 0,
     loc = locateval(idx2,1,group_rec->cnt,czf.chart_group_id,group_rec->qual[idx2].group_id)
     IF (loc > 0)
      sect_seq = group_rec->qual[loc].section_seq, group_seq = group_rec->qual[loc].group_seq, reply
      ->qual[sect_seq].chart_group_list[group_seq].new_zonal_info.collect_date_lbl = czf
      .collect_date_lbl,
      reply->qual[sect_seq].chart_group_list[group_seq].new_zonal_info.collect_date_chk = czf
      .collect_date_chk, reply->qual[sect_seq].chart_group_list[group_seq].new_zonal_info.
      ref_rng_form_flag = czf.ref_rng_form_flag, reply->qual[sect_seq].chart_group_list[group_seq].
      new_zonal_info.date_format_cd = czf.date_format_cd,
      reply->qual[sect_seq].chart_group_list[group_seq].new_zonal_info.time_format_flag = czf
      .time_format_flag, reply->qual[sect_seq].chart_group_list[group_seq].new_zonal_info.date_mask
       = czf.date_mask, reply->qual[sect_seq].chart_group_list[group_seq].new_zonal_info.time_mask =
      czf.time_mask,
      reply->qual[sect_seq].chart_group_list[group_seq].new_zonal_info.rslt_seq_flag = czf
      .rslt_seq_flag, reply->qual[sect_seq].chart_group_list[group_seq].new_zonal_info.
      ftnote_loc_flag = czf.ftnote_loc_flag, reply->qual[sect_seq].chart_group_list[group_seq].
      new_zonal_info.interp_loc_flag = czf.interp_loc_flag,
      reply->qual[sect_seq].chart_group_list[group_seq].new_zonal_info.order_group_ind = validate(czf
       .order_group_ind,1)
     ENDIF
    HEAD cdzf.zone_seq
     IF (loc > 0)
      zonecount += 1
      IF (mod(zonecount,3)=1)
       stat = alterlist(reply->qual[sect_seq].chart_group_list[group_seq].new_zonal_info.zone_list,(
        zonecount+ 2))
      ENDIF
      reply->qual[sect_seq].chart_group_list[group_seq].new_zonal_info.zone_list[zonecount].zone_seq
       = cdzf.zone_seq, reply->qual[sect_seq].chart_group_list[group_seq].new_zonal_info.zone_list[
      zonecount].proc_lbl = cdzf.proc_lbl, reply->qual[sect_seq].chart_group_list[group_seq].
      new_zonal_info.zone_list[zonecount].units_lbl = cdzf.units_lbl,
      reply->qual[sect_seq].chart_group_list[group_seq].new_zonal_info.zone_list[zonecount].
      ref_range_lbl = cdzf.ref_range_lbl, reply->qual[sect_seq].chart_group_list[group_seq].
      new_zonal_info.zone_list[zonecount].proc_col = cdzf.proc_col, reply->qual[sect_seq].
      chart_group_list[group_seq].new_zonal_info.zone_list[zonecount].units_col = cdzf.units_col,
      reply->qual[sect_seq].chart_group_list[group_seq].new_zonal_info.zone_list[zonecount].
      ref_range_col = cdzf.ref_range_col
     ENDIF
    HEAD czrc.column_seq
     IF (loc > 0)
      colcount += 1
      IF (mod(colcount,5)=1)
       stat = alterlist(reply->qual[sect_seq].chart_group_list[group_seq].new_zonal_info.zone_list[
        zonecount].result_col_list,(colcount+ 4))
      ENDIF
      reply->qual[sect_seq].chart_group_list[group_seq].new_zonal_info.zone_list[zonecount].
      result_col_list[colcount].column_seq = czrc.column_seq, reply->qual[sect_seq].chart_group_list[
      group_seq].new_zonal_info.zone_list[zonecount].result_col_list[colcount].col_index = czrc
      .col_index, reply->qual[sect_seq].chart_group_list[group_seq].new_zonal_info.zone_list[
      zonecount].result_col_list[colcount].description = czrc.description
     ENDIF
    DETAIL
     IF (loc > 0)
      codecount += 1
      IF (mod(codecount,10)=1)
       stat = alterlist(reply->qual[sect_seq].chart_group_list[group_seq].new_zonal_info.zone_list[
        zonecount].result_col_list[colcount].normalcy_cds,(codecount+ 9))
      ENDIF
      reply->qual[sect_seq].chart_group_list[group_seq].new_zonal_info.zone_list[zonecount].
      result_col_list[colcount].normalcy_cds[codecount].code = czrcc.normalcy_cd, reply->qual[
      sect_seq].chart_group_list[group_seq].new_zonal_info.zone_list[zonecount].result_col_list[
      colcount].normalcy_cds[codecount].meaning = uar_get_code_meaning(czrcc.normalcy_cd)
     ENDIF
    FOOT  czrc.column_seq
     IF (loc > 0)
      stat = alterlist(reply->qual[sect_seq].chart_group_list[group_seq].new_zonal_info.zone_list[
       zonecount].result_col_list[colcount].normalcy_cds,codecount)
     ENDIF
     codecount = 0
    FOOT  cdzf.zone_seq
     IF (loc > 0)
      stat = alterlist(reply->qual[sect_seq].chart_group_list[group_seq].new_zonal_info.zone_list[
       zonecount].result_col_list,colcount)
     ENDIF
     colcount = 0
    FOOT  czf.chart_group_id
     IF (loc > 0)
      stat = alterlist(reply->qual[sect_seq].chart_group_list[group_seq].new_zonal_info.zone_list,
       zonecount)
     ENDIF
     zonecount = 0
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_DYN_ZONE_FORM","GETZONALNEWSECTIONINFORMATION",1,1)
   CALL log_message(build("Exit GetZonalNewSectionInformation(), Elapsed time in seconds:",
     datetimediff(cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getorderssectioninformation(null)
   CALL log_message("In GetOrdersSectionInformation()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     chart_orders_format cof
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (cof
     WHERE expand(idx1,idxstart,((idxstart+ bind_cnt) - 1),cof.chart_group_id,group_rec->qual[idx1].
      group_id,
      orders_section_type,group_rec->qual[idx1].section_type_flag,bind_cnt))
    DETAIL
     loc = locateval(idx2,1,group_rec->cnt,cof.chart_group_id,group_rec->qual[idx2].group_id)
     IF (loc > 0)
      sect_seq = group_rec->qual[loc].section_seq, group_seq = group_rec->qual[loc].group_seq, reply
      ->qual[sect_seq].chart_group_list[group_seq].orders_info.order_seq_flag = cof.order_seq_flag,
      reply->qual[sect_seq].chart_group_list[group_seq].orders_info.date_time_chk = cof.date_time_ind,
      reply->qual[sect_seq].chart_group_list[group_seq].orders_info.date_time_lbl = cof.date_time_lbl,
      reply->qual[sect_seq].chart_group_list[group_seq].orders_info.action_chk = cof.action_ind,
      reply->qual[sect_seq].chart_group_list[group_seq].orders_info.action_lbl = cof.action_lbl,
      reply->qual[sect_seq].chart_group_list[group_seq].orders_info.mnemonic_chk = cof.mnemonic_ind,
      reply->qual[sect_seq].chart_group_list[group_seq].orders_info.mnemonic_lbl = cof.mnemonic_lbl,
      reply->qual[sect_seq].chart_group_list[group_seq].orders_info.order_phys_chk = cof
      .order_phys_ind, reply->qual[sect_seq].chart_group_list[group_seq].orders_info.order_phys_lbl
       = cof.order_phys_lbl, reply->qual[sect_seq].chart_group_list[group_seq].orders_info.
      order_placer_chk = cof.order_placer_ind,
      reply->qual[sect_seq].chart_group_list[group_seq].orders_info.order_placer_lbl = cof
      .order_placer_lbl, reply->qual[sect_seq].chart_group_list[group_seq].orders_info.
      order_status_chk = cof.order_status_ind, reply->qual[sect_seq].chart_group_list[group_seq].
      orders_info.order_status_lbl = cof.order_status_lbl,
      reply->qual[sect_seq].chart_group_list[group_seq].orders_info.order_type_chk = cof
      .order_type_ind, reply->qual[sect_seq].chart_group_list[group_seq].orders_info.order_type_lbl
       = cof.order_type_lbl, reply->qual[sect_seq].chart_group_list[group_seq].orders_info.
      details_chk = cof.details_ind,
      reply->qual[sect_seq].chart_group_list[group_seq].orders_info.details_lbl = cof.details_lbl,
      reply->qual[sect_seq].chart_group_list[group_seq].orders_info.review_chk = cof.review_ind,
      reply->qual[sect_seq].chart_group_list[group_seq].orders_info.review_lbl = cof.review_lbl,
      reply->qual[sect_seq].chart_group_list[group_seq].orders_info.detail_order = cof.detail_order,
      reply->qual[sect_seq].chart_group_list[group_seq].orders_info.review_order = cof.review_order,
      reply->qual[sect_seq].chart_group_list[group_seq].orders_info.date_mask = cof.date_mask,
      reply->qual[sect_seq].chart_group_list[group_seq].orders_info.time_mask = cof.time_mask, reply
      ->qual[sect_seq].chart_group_list[group_seq].orders_info.orderset_exclude_ind = cof
      .exclude_osname_ind, reply->qual[sect_seq].chart_group_list[group_seq].orders_info.
      label_bit_map = cof.label_bit_map,
      reply->qual[sect_seq].chart_group_list[group_seq].orders_info.cancel_reason_lbl = cof
      .cancel_reason_lbl, reply->qual[sect_seq].chart_group_list[group_seq].orders_info.
      canceled_dttm_lbl = cof.canceled_dttm_lbl, reply->qual[sect_seq].chart_group_list[group_seq].
      orders_info.comm_type_lbl = cof.comm_type_lbl,
      reply->qual[sect_seq].chart_group_list[group_seq].orders_info.dept_status_lbl = cof
      .dept_status_lbl, reply->qual[sect_seq].chart_group_list[group_seq].orders_info.
      discontinued_dttm_lbl = cof.discontinued_dttm_lbl, reply->qual[sect_seq].chart_group_list[
      group_seq].orders_info.future_disc_dttm_lbl = cof.future_disc_dttm_lbl,
      reply->qual[sect_seq].chart_group_list[group_seq].orders_info.orig_order_dttm_lbl = cof
      .orig_order_dttm_lbl, reply->qual[sect_seq].chart_group_list[group_seq].orders_info.
      suppress_meds_bit_map = cof.suppress_meds_bit_map, reply->qual[sect_seq].chart_group_list[
      group_seq].orders_info.action_seq_flag = cof.action_seq_flag,
      reply->qual[sect_seq].chart_group_list[group_seq].orders_info.detailed_layout_ind = cof
      .detailed_layout_ind
     ENDIF
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_ORDERS_FORMAT","GETORDERSSECTIONINFORMATION",1,1)
   CALL log_message(build("Exit GetOrdersSectionInformation(), Elapsed time in seconds:",datetimediff
     (cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getmarsectioninformation(null)
   CALL log_message("In GetMARSectionInformation()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     chart_mar_format cmf
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (cmf
     WHERE expand(idx1,idxstart,((idxstart+ bind_cnt) - 1),cmf.chart_group_id,group_rec->qual[idx1].
      group_id,
      mar_section_type,group_rec->qual[idx1].section_type_flag,bind_cnt))
    DETAIL
     loc = locateval(idx2,1,group_rec->cnt,cmf.chart_group_id,group_rec->qual[idx2].group_id)
     IF (loc > 0)
      sect_seq = group_rec->qual[loc].section_seq, group_seq = group_rec->qual[loc].group_seq, reply
      ->qual[sect_seq].chart_group_list[group_seq].mar_info.section_order = cmf.section_order,
      reply->qual[sect_seq].chart_group_list[group_seq].mar_info.admin_seq_ind = cmf.admin_seq_ind,
      reply->qual[sect_seq].chart_group_list[group_seq].mar_info.ordered_as_mnemonic_chk = cmf
      .ordered_as_mnemonic_ind, reply->qual[sect_seq].chart_group_list[group_seq].mar_info.
      dispensed_mnemonic_chk = cmf.dispensed_mnemonic_ind,
      reply->qual[sect_seq].chart_group_list[group_seq].mar_info.admin_dt_tm_order = cmf
      .admin_dt_tm_order, reply->qual[sect_seq].chart_group_list[group_seq].mar_info.
      admin_details_order = cmf.admin_details_order, reply->qual[sect_seq].chart_group_list[group_seq
      ].mar_info.admin_by_order = cmf.admin_by_order,
      reply->qual[sect_seq].chart_group_list[group_seq].mar_info.primary_mnemonic_lbl = cmf
      .primary_mnemonic_lbl, reply->qual[sect_seq].chart_group_list[group_seq].mar_info.
      order_details_lbl = cmf.order_details_lbl, reply->qual[sect_seq].chart_group_list[group_seq].
      mar_info.admin_dt_tm_lbl = cmf.admin_dt_tm_lbl,
      reply->qual[sect_seq].chart_group_list[group_seq].mar_info.admin_details_lbl = cmf
      .admin_details_lbl, reply->qual[sect_seq].chart_group_list[group_seq].mar_info.admin_by_lbl =
      cmf.admin_by_lbl, reply->qual[sect_seq].chart_group_list[group_seq].mar_info.date_mask = cmf
      .date_mask,
      reply->qual[sect_seq].chart_group_list[group_seq].mar_info.time_mask = cmf.time_mask
     ENDIF
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_MAR_FORMAT","GETMARSECTIONINFORMATION",1,1)
   CALL log_message(build("Exit GetMARSectionInformation(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getnamehistsectioninformation(null)
   CALL log_message("In GetNameHistSectionInformation()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     chart_name_hist_format cnhf
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (cnhf
     WHERE expand(idx1,idxstart,((idxstart+ bind_cnt) - 1),cnhf.chart_group_id,group_rec->qual[idx1].
      group_id,
      name_hist_section_type,group_rec->qual[idx1].section_type_flag,bind_cnt))
    DETAIL
     loc = locateval(idx2,1,group_rec->cnt,cnhf.chart_group_id,group_rec->qual[idx2].group_id)
     IF (loc > 0)
      sect_seq = group_rec->qual[loc].section_seq, group_seq = group_rec->qual[loc].group_seq, reply
      ->qual[sect_seq].chart_group_list[group_seq].name_hist_info.order_seq_ind = cnhf.order_seq_ind,
      reply->qual[sect_seq].chart_group_list[group_seq].name_hist_info.name_lbl = cnhf.name_lbl,
      reply->qual[sect_seq].chart_group_list[group_seq].name_hist_info.name_odr = cnhf.name_odr,
      reply->qual[sect_seq].chart_group_list[group_seq].name_hist_info.beg_effective_dt_tm_lbl = cnhf
      .beg_effective_dt_tm_lbl,
      reply->qual[sect_seq].chart_group_list[group_seq].name_hist_info.beg_effective_dt_tm_odr = cnhf
      .beg_effective_dt_tm_odr, reply->qual[sect_seq].chart_group_list[group_seq].name_hist_info.
      end_effective_dt_tm_lbl = cnhf.end_effective_dt_tm_lbl, reply->qual[sect_seq].chart_group_list[
      group_seq].name_hist_info.end_effective_dt_tm_odr = cnhf.end_effective_dt_tm_odr
     ENDIF
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_NAME_HIST_FORMAT","GETNAMEHISTSECTIONINFORMATION",1,1)
   CALL log_message(build("Exit GetNameHistSectionInformation(), Elapsed time in seconds:",
     datetimediff(cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getimmunsectioninformation(null)
   CALL log_message("In GetImmunSectionInformation()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     chart_immuniz_format cif
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (cif
     WHERE expand(idx1,idxstart,((idxstart+ bind_cnt) - 1),cif.chart_group_id,group_rec->qual[idx1].
      group_id,
      immun_section_type,group_rec->qual[idx1].section_type_flag,bind_cnt))
    DETAIL
     loc = locateval(idx2,1,group_rec->cnt,cif.chart_group_id,group_rec->qual[idx2].group_id)
     IF (loc > 0)
      sect_seq = group_rec->qual[loc].section_seq, group_seq = group_rec->qual[loc].group_seq, reply
      ->qual[sect_seq].chart_group_list[group_seq].immun_info.result_seq_ind = cif.result_seq_ind,
      reply->qual[sect_seq].chart_group_list[group_seq].immun_info.admin_note_chk = cif
      .admin_note_ind, reply->qual[sect_seq].chart_group_list[group_seq].immun_info.amount_chk = cif
      .amount_ind, reply->qual[sect_seq].chart_group_list[group_seq].immun_info.date_given_chk = cif
      .date_given_ind,
      reply->qual[sect_seq].chart_group_list[group_seq].immun_info.exp_dt_chk = cif.exp_dt_ind, reply
      ->qual[sect_seq].chart_group_list[group_seq].immun_info.exp_tm_chk = cif.exp_tm_ind, reply->
      qual[sect_seq].chart_group_list[group_seq].immun_info.lot_num_chk = cif.lot_num_ind,
      reply->qual[sect_seq].chart_group_list[group_seq].immun_info.manufact_chk = cif.manufact_ind,
      reply->qual[sect_seq].chart_group_list[group_seq].immun_info.provider_chk = cif.provider_ind,
      reply->qual[sect_seq].chart_group_list[group_seq].immun_info.site_chk = cif.site_ind,
      reply->qual[sect_seq].chart_group_list[group_seq].immun_info.time_given_chk = cif
      .time_given_ind, reply->qual[sect_seq].chart_group_list[group_seq].immun_info.admin_person_lbl
       = cif.admin_person_lbl, reply->qual[sect_seq].chart_group_list[group_seq].immun_info.
      amount_lbl = cif.amount_lbl,
      reply->qual[sect_seq].chart_group_list[group_seq].immun_info.date_given_lbl = cif
      .date_given_lbl, reply->qual[sect_seq].chart_group_list[group_seq].immun_info.exp_dt_lbl = cif
      .exp_dt_lbl, reply->qual[sect_seq].chart_group_list[group_seq].immun_info.lot_num_lbl = cif
      .lot_num_lbl,
      reply->qual[sect_seq].chart_group_list[group_seq].immun_info.manufact_lbl = cif.manufact_lbl,
      reply->qual[sect_seq].chart_group_list[group_seq].immun_info.provider_lbl = cif.provider_lbl,
      reply->qual[sect_seq].chart_group_list[group_seq].immun_info.site_lbl = cif.site_lbl,
      reply->qual[sect_seq].chart_group_list[group_seq].immun_info.vaccine_lbl = cif.vaccine_lbl,
      reply->qual[sect_seq].chart_group_list[group_seq].immun_info.date_mask = cif.date_mask, reply->
      qual[sect_seq].chart_group_list[group_seq].immun_info.time_mask = cif.time_mask
     ENDIF
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_IMMUNIZ_FORMAT","GETIMMUNSECTIONINFORMATION",1,1)
   CALL log_message(build("Exit GetImmunSectionInformation(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getprochistsectioninformation(null)
   CALL log_message("In GetProcHistSectionInformation()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     chart_prochist_format cpf
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (cpf
     WHERE expand(idx1,idxstart,((idxstart+ bind_cnt) - 1),cpf.chart_group_id,group_rec->qual[idx1].
      group_id,
      proc_hist_section_type,group_rec->qual[idx1].section_type_flag,bind_cnt))
    DETAIL
     loc = locateval(idx2,1,group_rec->cnt,cpf.chart_group_id,group_rec->qual[idx2].group_id)
     IF (loc > 0)
      sect_seq = group_rec->qual[loc].section_seq, group_seq = group_rec->qual[loc].group_seq, reply
      ->qual[sect_seq].chart_group_list[group_seq].proc_hist_info.proc_lbl = cpf.proc_lbl,
      reply->qual[sect_seq].chart_group_list[group_seq].proc_hist_info.proc_ord = cpf.proc_ord, reply
      ->qual[sect_seq].chart_group_list[group_seq].proc_hist_info.status_lbl = cpf.status_lbl, reply
      ->qual[sect_seq].chart_group_list[group_seq].proc_hist_info.status_ord = cpf.status_ord,
      reply->qual[sect_seq].chart_group_list[group_seq].proc_hist_info.date_lbl = cpf.date_lbl, reply
      ->qual[sect_seq].chart_group_list[group_seq].proc_hist_info.date_ord = cpf.date_ord, reply->
      qual[sect_seq].chart_group_list[group_seq].proc_hist_info.provider_lbl = cpf.provider_lbl,
      reply->qual[sect_seq].chart_group_list[group_seq].proc_hist_info.provider_ord = cpf
      .provider_ord, reply->qual[sect_seq].chart_group_list[group_seq].proc_hist_info.location_lbl =
      cpf.location_lbl, reply->qual[sect_seq].chart_group_list[group_seq].proc_hist_info.location_ord
       = cpf.location_ord
     ENDIF
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_PROCHIST_FORMAT","GETPROCHISTSECTIONINFORMATION",1,1)
   CALL log_message(build("Exit GetProcHistSectionInformation(), Elapsed time in seconds:",
     datetimediff(cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getiosectioninformation(null)
   CALL log_message("In GetIOSectionInformation()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     chart_generic_format cgf,
     long_text_reference ltr
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (cgf
     WHERE expand(idx1,idxstart,((idxstart+ bind_cnt) - 1),cgf.chart_group_id,group_rec->qual[idx1].
      group_id,
      io_section_type,group_rec->qual[idx1].section_type_flag,bind_cnt))
     JOIN (ltr
     WHERE cgf.param_long_text_id=ltr.long_text_id)
    DETAIL
     loc = locateval(idx2,1,group_rec->cnt,cgf.chart_group_id,group_rec->qual[idx2].group_id)
     IF (loc > 0)
      sect_seq = group_rec->qual[loc].section_seq, group_seq = group_rec->qual[loc].group_seq, reply
      ->qual[sect_seq].chart_group_list[group_seq].io_info.include_img_foot_ind = cgf
      .include_img_footer_ind,
      reply->qual[sect_seq].chart_group_list[group_seq].io_info.include_img_head_ind = cgf
      .include_img_header_ind, reply->qual[sect_seq].chart_group_list[group_seq].io_info.long_text =
      ltr.long_text
     ENDIF
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"IO_CHART_GENERIC_FORMAT","GETIOSECTIONINFORMATION",1,1)
   CALL log_message(build("Exit GetIOSectionInformation(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getmar2sectioninformation(null)
   CALL log_message("In GetMAR2SectionInformation()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     chart_mar_format cmf
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (cmf
     WHERE expand(idx1,idxstart,((idxstart+ bind_cnt) - 1),cmf.chart_group_id,group_rec->qual[idx1].
      group_id,
      mar2_section_type,group_rec->qual[idx1].section_type_flag,bind_cnt))
    DETAIL
     loc = locateval(idx2,1,group_rec->cnt,cmf.chart_group_id,group_rec->qual[idx2].group_id)
     IF (loc > 0)
      sect_seq = group_rec->qual[loc].section_seq, group_seq = group_rec->qual[loc].group_seq, reply
      ->qual[sect_seq].chart_group_list[group_seq].mar2_info.include_img_foot_ind = cmf
      .include_img_footer_ind,
      reply->qual[sect_seq].chart_group_list[group_seq].mar2_info.include_img_head_ind = cmf
      .include_img_header_ind
     ENDIF
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"NEW_CHART_MAR_FORMAT","GETMAR2SECTIONINFORMATION",1,1)
   CALL log_message(build("Exit GetMAR2SectionInformation(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getmedprofhistsectioninformation(null)
   CALL log_message("In GetMedProfHistSectionInformation()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     chart_generic_format cgf
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (cgf
     WHERE expand(idx1,idxstart,((idxstart+ bind_cnt) - 1),cgf.chart_group_id,group_rec->qual[idx1].
      group_id,
      med_prof_hist_section_type,group_rec->qual[idx1].section_type_flag,bind_cnt))
    DETAIL
     loc = locateval(idx2,1,group_rec->cnt,cgf.chart_group_id,group_rec->qual[idx2].group_id)
     IF (loc > 0)
      sect_seq = group_rec->qual[loc].section_seq, group_seq = group_rec->qual[loc].group_seq, reply
      ->qual[sect_seq].chart_group_list[group_seq].mph_info.include_img_foot_ind = cgf
      .include_img_footer_ind,
      reply->qual[sect_seq].chart_group_list[group_seq].mph_info.include_img_head_ind = cgf
      .include_img_header_ind
     ENDIF
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"MPH_CHART_GENERIC_FORMAT","GETMEDPROFHISTSECTIONINFORMATION",1,
    1)
   CALL log_message(build("Exit GetMedProfHistSectionInformation(), Elapsed time in seconds:",
     datetimediff(cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getuserdefinedsectioninformation(null)
   CALL log_message("In GetUserDefinedSectionInformation()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     chart_generic_format cgf,
     chart_discern_request cdr
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (cgf
     WHERE expand(idx1,idxstart,((idxstart+ bind_cnt) - 1),cgf.chart_group_id,group_rec->qual[idx1].
      group_id,
      user_defined_section_type,group_rec->qual[idx1].section_type_flag,bind_cnt))
     JOIN (cdr
     WHERE cgf.chart_discern_request_id=cdr.chart_discern_request_id)
    DETAIL
     loc = locateval(idx2,1,group_rec->cnt,cgf.chart_group_id,group_rec->qual[idx2].group_id)
     IF (loc > 0)
      sect_seq = group_rec->qual[loc].section_seq, group_seq = group_rec->qual[loc].group_seq, reply
      ->qual[sect_seq].chart_group_list[group_seq].discern_report_info.include_img_foot_ind = cgf
      .include_img_footer_ind,
      reply->qual[sect_seq].chart_group_list[group_seq].discern_report_info.include_img_head_ind =
      cgf.include_img_header_ind, reply->qual[sect_seq].chart_group_list[group_seq].
      discern_report_info.chart_discern_request_id = cdr.chart_discern_request_id, reply->qual[
      sect_seq].chart_group_list[group_seq].discern_report_info.request_number = cdr.request_number,
      reply->qual[sect_seq].chart_group_list[group_seq].discern_report_info.process_flag = cdr
      .process_flag, reply->qual[sect_seq].chart_group_list[group_seq].discern_report_info.display =
      cdr.display_text, reply->qual[sect_seq].chart_group_list[group_seq].discern_report_info.
      scope_bit_map = cdr.scope_bit_map,
      reply->qual[sect_seq].chart_group_list[group_seq].discern_report_info.active_ind = cdr
      .active_ind, reply->qual[sect_seq].chart_group_list[group_seq].discern_report_info.
      qualification_date_flag = validate(cdr.qualification_date_flag,0)
     ENDIF
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"UD_CHART_GENERIC_FORMAT","GETUSERDEFINEDSECTIONINFORMATION",1,1
    )
   CALL log_message(build("Exit GetUserDefinedSectionInformation(), Elapsed time in seconds:",
     datetimediff(cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getsectionspecificinfo(null)
   CALL log_message("In GetSectionSpecificInfo()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE idx1 = i4 WITH noconstant(0), protect
   DECLARE idx2 = i4 WITH noconstant(0), protect
   DECLARE idxstart = i4 WITH noconstant(1), protect
   DECLARE nrecordsize = i4 WITH noconstant(0), protect
   DECLARE noptimizedtotal = i4 WITH noconstant(0), protect
   IF ((group_rec->cnt > 0))
    SET nrecordsize = group_rec->cnt
    SET noptimizedtotal = (ceil((cnvtreal(nrecordsize)/ bind_cnt)) * bind_cnt)
    SET stat = alterlist(group_rec->qual,noptimizedtotal)
    FOR (i = (nrecordsize+ 1) TO noptimizedtotal)
      SET group_rec->qual[i].group_id = group_rec->qual[nrecordsize].group_id
      SET group_rec->qual[i].group_seq = group_rec->qual[nrecordsize].group_seq
      SET group_rec->qual[i].section_seq = group_rec->qual[nrecordsize].section_seq
      SET group_rec->qual[i].section_type_flag = group_rec->qual[nrecordsize].section_type_flag
    ENDFOR
   ENDIF
   IF (xencntr_section_found)
    CALL getxencntrsectioninformation(null)
   ENDIF
   IF (flex_section_found)
    CALL getflexsectioninformation(null)
   ENDIF
   IF (horz_section_found)
    CALL gethorizontalsectioninformation(null)
   ENDIF
   IF (mic_section_found)
    CALL getmicrosectioninformation(null)
   ENDIF
   IF (ord_sum_section_found)
    CALL getordersumsectioninformation(null)
   ENDIF
   IF (rad_section_found)
    CALL getradiologysectioninformation(null)
   ENDIF
   IF (vert_section_found)
    CALL getverticalsectioninformation(null)
   ENDIF
   IF (listview_section_found)
    CALL getlistviewsectioninformation(null)
   ENDIF
   IF (zonal_old_section_found)
    CALL getzonaloldsectioninformation(null)
   ENDIF
   IF (ap_section_found)
    CALL getapsectioninformation(null)
   ENDIF
   IF (hla_section_found)
    CALL gethlasectioninformation(null)
   ENDIF
   IF (doc_section_found)
    CALL getdocumentsectioninformation(null)
   ENDIF
   IF (lab_text_section_found)
    CALL getlabtextsectioninformation(null)
   ENDIF
   IF (allergy_section_found)
    CALL getallergysectioninformation(null)
   ENDIF
   IF (prob_list_section_found)
    CALL getproblemlistsectioninformation(null)
   ENDIF
   IF (zonal_new_section_found)
    CALL getzonalnewsectioninformation(null)
   ENDIF
   IF (orders_section_found)
    CALL getorderssectioninformation(null)
   ENDIF
   IF (mar_section_found)
    CALL getmarsectioninformation(null)
   ENDIF
   IF (name_hist_section_found)
    CALL getnamehistsectioninformation(null)
   ENDIF
   IF (immun_section_found)
    CALL getimmunsectioninformation(null)
   ENDIF
   IF (proc_hist_section_found)
    CALL getprochistsectioninformation(null)
   ENDIF
   IF (mar2_section_found)
    CALL getmar2sectioninformation(null)
   ENDIF
   IF (io_section_found)
    CALL getiosectioninformation(null)
   ENDIF
   IF (med_prof_hist_section_found)
    CALL getmedprofhistsectioninformation(null)
   ENDIF
   IF (user_defined_section_found)
    CALL getuserdefinedsectioninformation(null)
   ENDIF
   IF (pwrfrm_section_found)
    CALL getpowerformnames(null)
   ENDIF
   IF (((rad_section_found) OR (((ap_section_found) OR (((doc_section_found) OR (
   lab_text_section_found)) )) )) )
    CALL getsectionfields(null)
   ENDIF
   CALL log_message(build("Exit GetSectionSpecificInfo(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getsectionfields(null)
   CALL log_message("In GetSectionFields()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE idx1 = i4 WITH noconstant(0), protect
   DECLARE idx2 = i4 WITH noconstant(0), protect
   DECLARE idxstart = i4 WITH noconstant(1), protect
   DECLARE idxstart2 = i4 WITH noconstant(1), protect
   DECLARE noptimizedtotal = i4 WITH constant((ceil((cnvtreal(qualcount)/ bind_cnt)) * bind_cnt)),
   protect
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     chart_sect_flds csf
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (csf
     WHERE expand(idx1,idxstart,((idxstart+ bind_cnt) - 1),csf.chart_section_id,request->qual[idx1].
      chart_section_id,
      bind_cnt))
    ORDER BY csf.chart_section_id, csf.field_seq
    HEAD csf.chart_section_id
     loc = locateval(idx2,1,size(reply->qual,5),csf.chart_section_id,reply->qual[idx2].
      chart_section_id), fldcount = 0
    DETAIL
     IF (loc > 0)
      fldcount += 1
      IF (mod(fldcount,10)=1)
       stat = alterlist(reply->qual[loc].sect_field_list,(fldcount+ 9))
      ENDIF
      reply->qual[loc].sect_field_list[fldcount].field_id = csf.field_id, reply->qual[loc].
      sect_field_list[fldcount].field_row = csf.field_row
     ENDIF
    FOOT  csf.chart_section_id
     IF (loc > 0)
      stat = alterlist(reply->qual[loc].sect_field_list,fldcount)
     ENDIF
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_SECT_FLDS","GETSECTIONFIELDS",1,0)
   CALL log_message(build("Exit GetSectionFields(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
#exit_script
 CALL log_message("Exiting script: cp_load_chart_sections",log_level_debug)
END GO
