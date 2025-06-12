CREATE PROGRAM cp_load_chart_section:dba
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
 DECLARE crsl_msg_default = i4 WITH protect, noconstant(0)
 DECLARE crsl_msg_level = i4 WITH protect, noconstant(0)
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
 DECLARE log_message(logmsg=vc,loglvl=i4) = null
 SUBROUTINE log_message(logmsg,loglvl)
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
 DECLARE error_message(logstatusblockind=i2) = i2
 SUBROUTINE error_message(logstatusblockind)
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
 DECLARE error_and_zero_check(qualnum=i4,opname=vc,logname=vc,errorforceexit=i2,zeroforceexit=i2) =
 i2
 SUBROUTINE error_and_zero_check(qualnum,opname,logname,errorforceexit,zeroforceexit)
   SET icrslerroroccured = 0
   SET ierrcode = error(serrmsg,0)
   WHILE (ierrcode > 0)
     SET icrslerroroccured = 1
     CALL log_message(serrmsg,log_level_audit)
     CALL populate_subeventstatus(opname,"F",logname,serrmsg)
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
    CALL populate_subeventstatus(opname,"Z",logname,"No records qualified")
    GO TO exit_script
   ENDIF
   RETURN(icrslerroroccured)
 END ;Subroutine
 DECLARE populate_subeventstatus(operationname=vc(value),operationstatus=vc(value),targetobjectname=
  vc(value),targetobjectvalue=vc(value)) = i2
 SUBROUTINE populate_subeventstatus(operationname,operationstatus,targetobjectname,targetobjectvalue)
   IF (validate(reply->status_data.status,"-1") != "-1")
    SET lcrslsubeventcnt = size(reply->status_data.subeventstatus,5)
    SET lcrslsubeventsize = size(trim(reply->status_data.subeventstatus[lcrslsubeventcnt].
      operationname))
    SET lcrslsubeventsize = (lcrslsubeventsize+ size(trim(reply->status_data.subeventstatus[
      lcrslsubeventcnt].operationstatus)))
    SET lcrslsubeventsize = (lcrslsubeventsize+ size(trim(reply->status_data.subeventstatus[
      lcrslsubeventcnt].targetobjectname)))
    SET lcrslsubeventsize = (lcrslsubeventsize+ size(trim(reply->status_data.subeventstatus[
      lcrslsubeventcnt].targetobjectvalue)))
    IF (lcrslsubeventsize > 0)
     SET lcrslsubeventcnt = (lcrslsubeventcnt+ 1)
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
 DECLARE populate_subeventstatus_msg(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value),loglevel=i2(value)) = i2
 SUBROUTINE populate_subeventstatus_msg(operationname,operationstatus,targetobjectname,
  targetobjectvalue,loglevel)
  CALL populate_subeventstatus(operationname,operationstatus,targetobjectname,targetobjectvalue)
  CALL log_message(targetobjectvalue,loglevel)
 END ;Subroutine
 DECLARE check_log_level(arg_log_level=i4) = i2
 SUBROUTINE check_log_level(arg_log_level)
   IF (((crsl_msg_level >= arg_log_level) OR (log_override_ind=1)) )
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SET log_program_name = "CP_LOAD_CHART_SECTION"
 RECORD reply(
   1 chart_section_id = f8
   1 chart_section_desc = vc
   1 section_type_flag = i2
   1 sect_page_brk_ind = i2
   1 chart_group_list[*]
     2 chart_group_id = f8
     2 max_results = i4
     2 chart_group_desc = vc
     2 enhanced_layout_ind = i2
     2 horizontal_info_list[*]
       3 test_lbl_order = i4
       3 units_lbl_order = i4
       3 refer_lbl_order = i4
       3 normall_lbl_order = i4
       3 normalh_lbl_order = i4
       3 perfid_lbl_order = i4
       3 test_lbl = vc
       3 units_lbl = vc
       3 ref_range_lbl = vc
       3 normal_low_lbl = vc
       3 normal_high_lbl = vc
       3 perfid_lbl = vc
       3 date_order = i4
       3 weekday_order = i4
       3 staydays_order = i4
       3 time_order = i4
       3 rslt_start_col = i4
       3 date_mask = vc
       3 time_mask = vc
       3 ref_rng_form_flag = i2
       3 rslt_seq_flag = i2
       3 ftnote_loc_flag = i2
       3 interp_loc_flag = i2
       3 wkday_format_flag = i2
       3 encntr_alias_order = i4
       3 flowsheet_ind = i2
     2 vertical_info_list[*]
       3 test_lbl_order = i4
       3 units_lbl_order = i4
       3 refer_lbl_order = i4
       3 perfid_lbl_order = i4
       3 test_lbl_pos = i4
       3 units_lbl_pos = i4
       3 refer_lbl_pos = i4
       3 perfid_lbl_pos = i4
       3 test_lbl = vc
       3 units_lbl = vc
       3 ref_range_lbl = vc
       3 perfid_lbl = vc
       3 date_lbl = vc
       3 staydays_lbl = vc
       3 time_lbl = vc
       3 date_order = i4
       3 staydays_order = i4
       3 time_order = i4
       3 ref_rng_form_flag = i2
       3 rslt_seq_flag = i2
       3 ftnote_loc_flag = i2
       3 interp_loc_flag = i2
       3 date_mask = vc
       3 time_mask = vc
       3 staydays_form_flag = i2
       3 rslt_start_col = i4
       3 encntr_alias_order = i4
       3 encntr_alias_lbl = vc
       3 flowsheet_ind = i2
     2 zonal_info_list[*]
       3 date_mask = vc
       3 time_mask = vc
       3 ref_rng_form_flag = i2
       3 rslt_seq_flag = i2
       3 ftnote_loc_flag = i2
       3 interp_loc_flag = i2
       3 zone_seq = i4
       3 test_lbl = vc
       3 units_lbl = vc
       3 ref_range_lbl = vc
       3 alpha_abn_rslt_lbl = vc
       3 all_rslt_lbl = vc
       3 crit_rslt_lbl = vc
       3 high_rslt_lbl = vc
       3 low_rslt_lbl = vc
       3 normal_rslt_lbl = vc
       3 test_col = i4
       3 units_col = i4
       3 ref_range_col = i4
       3 all_rslt_col = i4
       3 low_rslt_col = i4
       3 normal_rslt_col = i4
       3 high_rslt_col = i4
       3 crit_rslt_col = i4
       3 alpha_abn_rslt_col = i4
     2 flex_info
       3 flex_type = i4
       3 prod_nbr_lbl = vc
       3 desc_lbl = vc
       3 disp_lbl = vc
       3 abo_lbl = vc
       3 verified_dt_lbl = vc
       3 collected_dt_lbl = vc
       3 prod_nbr_odr = i4
       3 desc_odr = i4
       3 disp_odr = i4
       3 abo_odr = i4
       3 verified_dt_odr = i4
       3 collected_dt_odr = i4
       3 result_seq = i2
       3 crossmatch_result_lbl = vc
       3 crossmatch_result_odr = i4
     2 order_summary_info
       3 order_summary_type = i4
       3 date_lbl = vc
       3 time_lbl = vc
       3 name_lbl = vc
       3 mnemonic_lbl = vc
       3 status_lbl = vc
       3 cancel_reason_lbl = vc
       3 date_mask = vc
       3 time_mask = vc
       3 date_odr = i4
       3 time_odr = i4
       3 name_odr = i4
       3 mnemonic_odr = i4
       3 status_odr = i4
       3 cancel_reason_odr = i4
       3 order_seq_flag = i2
       3 os_filter_list[*]
         4 filter_cd = f8
         4 filter_display = vc
         4 filter_type = i2
         4 filter_seq = i4
       3 order_provider_ind = i2
       3 order_provider_odr = i4
       3 order_provider_lbl = vc
       3 dept_status_odr = i4
       3 dept_status_lbl = vc
     2 rad_info
       3 group_style = vc
       3 reason_annotation = i4
       3 reason_caption = vc
       3 reason_ind = i2
       3 result_sequence = i4
       3 cpt4_code_ind = i2
       3 cpt4_desc_ind = i2
       3 cpt4_label = vc
       3 cpt4_label_style = vc
       3 cdm_code_ind = i2
       3 cdm_desc_ind = i2
       3 cdm_label = vc
       3 cdm_label_style = vc
       3 cor_footnote_ind = i2
     2 ap_info
       3 group_style = vc
       3 result_sequence = i4
       3 snomed_codes_ind = i2
       3 snomed_desc_ind = i2
       3 snomed_codes_lbl = vc
       3 snomed_cd_lbl_style = vc
       3 tcc_codes_ind = i2
       3 tcc_desc_ind = i2
       3 tcc_codes_lbl = vc
       3 tcc_cd_lbl_style = vc
       3 ap_history_flag = i2
       3 cpt_long_text = vc
       3 image_flag = i2
     2 hla_info
       3 hla_type = i4
       3 line_ind = i4
       3 rslt_seq = i2
       3 prsn_name_lbl = vc
       3 date_lbl = vc
       3 mrn_lbl = vc
       3 relation_lbl = vc
       3 abo_rh_lbl = vc
       3 haploid1_lbl = vc
       3 haploid2_lbl = vc
       3 haplotype1_lbl = vc
       3 haplotype2_lbl = vc
       3 prsn_name_odr = i4
       3 date_odr = i4
       3 mrn_odr = i4
       3 relation_odr = i4
       3 abo_rh_odr = i4
       3 result_odr = i4
       3 haploid1_odr = i4
       3 haploid2_odr = i4
       3 haplotype1_odr = i4
       3 haplotype2_odr = i4
       3 prsn_name_rpt = i4
       3 date_rpt = i4
       3 mrn_rpt = i4
       3 relation_rpt = i4
       3 abo_rpt = i4
       3 rh_ind = i2
     2 doc_info
       3 rslt_seq = i2
       3 pgbrk_ind = i2
       3 exclude_img_mdoc_ind = i2
       3 include_img_head_ind = i2
       3 include_img_foot_ind = i2
       3 doc_type = i2
     2 gl_info
       3 rslt_seq = i2
       3 group_style = vc
     2 micro_info
       3 option_list[*]
         4 option_flag = i2
         4 option_value = vc
     2 allergy_info
       3 substance_lbl = vc
       3 category_lbl = vc
       3 updt_dt_lbl = vc
       3 severity_lbl = vc
       3 reaction_stat_lbl = vc
       3 reaction_lbl = vc
       3 updt_by_lbl = vc
       3 source_lbl = vc
       3 onset_dt_lbl = vc
       3 type_lbl = vc
       3 cancel_lbl = vc
       3 comment_lbl = vc
       3 severity_odr = i4
       3 reaction_stat_odr = i4
       3 reaction_odr = i4
       3 source_odr = i4
       3 onset_dt_odr = i4
       3 type_odr = i4
       3 cancel_odr = i4
       3 category_odr = i4
       3 result_sequence_ind = i2
     2 prob_info
       3 prob_name_lbl = vc
       3 date_rec_lbl = vc
       3 code_lbl = vc
       3 con_stat_lbl = vc
       3 life_stat_lbl = vc
       3 course_lbl = vc
       3 perst_lbl = vc
       3 prog_lbl = vc
       3 onset_lbl = vc
       3 prov_lbl = vc
       3 date_est_lbl = vc
       3 cancel_lbl = vc
       3 comment_lbl = vc
       3 code_ord = i4
       3 con_stat_ord = i4
       3 life_stat_ord = i4
       3 course_ord = i4
       3 perst_ord = i4
       3 prog_ord = i4
       3 onset_ord = i4
       3 cancel_ord = i4
       3 result_sequence_ind = i2
       3 date_rec_result_sequence_ind = i2
     2 xencntr_info
       3 rslt_seq = i2
       3 prefix_format_flag = i2
       3 prefix_format = vc
       3 encntr_alias_lbl = vc
       3 facility_lbl = vc
       3 building_lbl = vc
       3 nurse_unit_lbl = vc
       3 client_lbl = vc
       3 fin_nbr_lbl = vc
       3 mrn_lbl = vc
       3 admit_dt_lbl = vc
       3 dischg_dt_lbl = vc
       3 diagnosis_lbl = vc
       3 encntr_alias_odr = i4
       3 facility_odr = i4
       3 building_odr = i4
       3 nurse_unit_odr = i4
       3 client_odr = i4
       3 fin_nbr_odr = i4
       3 mrn_odr = i4
       3 admit_dt_odr = i4
       3 dischg_dt_odr = i4
       3 diagnosis_odr = i4
     2 new_zonal_info
       3 collect_date_lbl = vc
       3 collect_date_chk = i4
       3 date_format_cd = f8
       3 time_format_flag = i2
       3 date_mask = vc
       3 time_mask = vc
       3 ref_rng_form_flag = i2
       3 rslt_seq_flag = i2
       3 ftnote_loc_flag = i2
       3 interp_loc_flag = i2
       3 zone_list[*]
         4 zone_seq = i4
         4 proc_lbl = vc
         4 units_lbl = vc
         4 ref_range_lbl = vc
         4 proc_col = i4
         4 units_col = i4
         4 ref_range_col = i4
         4 result_col_list[*]
           5 column_seq = i4
           5 col_index = i4
           5 description = vc
           5 normalcy_cds[*]
             6 code = f8
             6 meaning = c12
     2 orders_info
       3 order_seq_flag = i2
       3 date_time_chk = i2
       3 date_time_lbl = vc
       3 action_chk = i2
       3 action_lbl = vc
       3 dept_status_chk = i2
       3 dept_status_lbl = vc
       3 mnemonic_chk = i2
       3 mnemonic_lbl = vc
       3 order_phys_chk = i2
       3 order_phys_lbl = vc
       3 order_placer_chk = i2
       3 order_placer_lbl = vc
       3 order_writer_chk = i2
       3 order_writer_lbl = vc
       3 order_status_chk = i2
       3 order_status_lbl = vc
       3 order_type_chk = i2
       3 order_type_lbl = vc
       3 details_chk = i2
       3 details_lbl = vc
       3 review_chk = i2
       3 review_lbl = vc
       3 detail_order = i4
       3 review_order = i4
       3 single_row_ind = i2
       3 date_mask = vc
       3 time_mask = vc
       3 orderset_exclude_ind = i2
       3 label_bit_map = i4
       3 cancel_reason_lbl = vc
       3 canceled_dttm_lbl = vc
       3 comm_type_lbl = vc
       3 dept_status_lbl = vc
       3 discontinued_dttm_lbl = vc
       3 future_disc_dttm_lbl = vc
       3 orig_order_dttm_lbl = vc
       3 suppress_meds_bit_map = i4
       3 action_seq_flag = i4
       3 detailed_layout_ind = i2
     2 mar_info
       3 med_seq_flag = i2
       3 section_order = i4
       3 admin_seq_ind = i2
       3 ordered_as_mnemonic_chk = i2
       3 dispensed_mnemonic_chk = i2
       3 admin_dt_tm_order = i4
       3 admin_details_order = i4
       3 admin_by_order = i4
       3 primary_mnemonic_lbl = vc
       3 order_details_lbl = vc
       3 admin_dt_tm_lbl = vc
       3 admin_details_lbl = vc
       3 admin_by_lbl = vc
       3 date_mask = vc
       3 time_mask = vc
     2 name_hist_info
       3 order_seq_ind = i2
       3 name_lbl = vc
       3 name_odr = i4
       3 beg_effective_dt_tm_lbl = vc
       3 beg_effective_dt_tm_odr = i4
       3 end_effective_dt_tm_lbl = vc
       3 end_effective_dt_tm_odr = i4
     2 immun_info
       3 result_seq_ind = i2
       3 admin_note_chk = i2
       3 amount_chk = i2
       3 date_given_chk = i2
       3 exp_dt_chk = i2
       3 exp_tm_chk = i2
       3 lot_num_chk = i2
       3 manufact_chk = i2
       3 provider_chk = i2
       3 site_chk = i2
       3 time_given_chk = i2
       3 admin_person_lbl = vc
       3 amount_lbl = vc
       3 date_given_lbl = vc
       3 exp_dt_lbl = vc
       3 lot_num_lbl = vc
       3 manufact_lbl = vc
       3 provider_lbl = vc
       3 site_lbl = vc
       3 vaccine_lbl = vc
       3 date_mask = vc
       3 time_mask = vc
     2 proc_hist_info
       3 proc_lbl = vc
       3 proc_ord = i4
       3 status_lbl = vc
       3 status_ord = i4
       3 date_lbl = vc
       3 date_ord = i4
       3 provider_lbl = vc
       3 provider_ord = i4
       3 location_lbl = vc
       3 location_ord = i4
     2 chart_event_list[*]
       3 event_set_cd = f8
       3 event_set_name = vc
       3 event_set_valid = i2
       3 synonym_id = f8
       3 order_catalog_cd = f8
       3 procedure_type_flag = i2
       3 display_name = vc
       3 zone = i4
     2 mar2_info
       3 include_img_head_ind = i2
       3 include_img_foot_ind = i2
     2 io_info
       3 include_img_head_ind = i2
       3 include_img_foot_ind = i2
       3 long_text = vc
     2 mph_info
       3 include_img_head_ind = i2
       3 include_img_foot_ind = i2
     2 discern_report_info
       3 include_img_head_ind = i2
       3 include_img_foot_ind = i2
       3 chart_discern_request_id = f8
       3 request_number = i4
       3 process_flag = i2
       3 display = vc
       3 scope_bit_map = i4
       3 active_ind = i2
   1 sect_field_list[*]
     2 field_id = i4
     2 field_row = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE getsectionfields(null) = null
 DECLARE getsectiongroupinfo(null) = null
 DECLARE getsectionspecificinfo(null) = null
 DECLARE grpcount = i4 WITH noconstant(0), protect
 DECLARE itemcount = i4 WITH noconstant(0), protect
 DECLARE evtcount = i4 WITH noconstant(0), protect
 DECLARE fldcount = i4 WITH noconstant(0), protect
 DECLARE filter_count = i4 WITH noconstant(0), protect
 DECLARE opt_nbr = i4 WITH noconstant(0), protect
 DECLARE long_text = vc WITH noconstant(" "), protect
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
 CALL log_message("Starting script: cp_load_chart_section",log_level_debug)
 SET reply->status_data.status = "F"
 CALL getsectiongroupinfo(null)
 CALL getsectionspecificinfo(null)
 SET reply->status_data.status = "S"
 SUBROUTINE getsectiongroupinfo(null)
   CALL log_message("In GetSectionGroupInfo()",log_level_debug)
   SELECT INTO "nl:"
    cs.chart_section_id, cg.chart_group_id, ce.event_set_name
    FROM chart_section cs,
     chart_group cg,
     chart_grp_evnt_set ce
    PLAN (cs
     WHERE (cs.chart_section_id=request->chart_section_id))
     JOIN (cg
     WHERE cg.chart_section_id=cs.chart_section_id)
     JOIN (ce
     WHERE ce.chart_group_id=outerjoin(cg.chart_group_id))
    ORDER BY cg.cg_sequence, ce.event_set_seq
    HEAD REPORT
     grpcount = 0, evtcount = 0, reply->chart_section_id = cs.chart_section_id,
     reply->chart_section_desc = cs.chart_section_desc, reply->section_type_flag = cs
     .section_type_flag, reply->sect_page_brk_ind = cs.sect_page_brk_ind
    HEAD cg.cg_sequence
     grpcount = (grpcount+ 1)
     IF (mod(grpcount,10)=1)
      stat = alterlist(reply->chart_group_list,(grpcount+ 9))
     ENDIF
     reply->chart_group_list[grpcount].chart_group_id = cg.chart_group_id, reply->chart_group_list[
     grpcount].chart_group_desc = cg.chart_group_desc, reply->chart_group_list[grpcount].
     enhanced_layout_ind = cg.enhanced_layout_ind,
     reply->chart_group_list[grpcount].max_results = cg.max_results, evtcount = 0
    DETAIL
     IF (ce.event_set_seq > 0)
      evtcount = (evtcount+ 1)
      IF (mod(evtcount,10)=1)
       stat = alterlist(reply->chart_group_list[grpcount].chart_event_list,(evtcount+ 9))
      ENDIF
      reply->chart_group_list[grpcount].chart_event_list[evtcount].event_set_name = ce.event_set_name,
      reply->chart_group_list[grpcount].chart_event_list[evtcount].synonym_id = ce.synonym_id, reply
      ->chart_group_list[grpcount].chart_event_list[evtcount].order_catalog_cd = ce.order_catalog_cd,
      reply->chart_group_list[grpcount].chart_event_list[evtcount].procedure_type_flag = ce
      .procedure_type_flag, reply->chart_group_list[grpcount].chart_event_list[evtcount].display_name
       = ce.display_name, reply->chart_group_list[grpcount].chart_event_list[evtcount].zone = ce.zone
     ENDIF
    FOOT  cg.cg_sequence
     stat = alterlist(reply->chart_group_list[grpcount].chart_event_list,evtcount)
    FOOT REPORT
     stat = alterlist(reply->chart_group_list,grpcount)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_SECTION","GETSECTIONGROUPINFO",1,1)
 END ;Subroutine
 SUBROUTINE getsectionspecificinfo(null)
  CALL log_message("In GetSectionSpecificInfo()",log_level_debug)
  CASE (reply->section_type_flag)
   OF xencntr_section_type:
    SELECT INTO "nl:"
     FROM chart_xencntr_format xe
     PLAN (xe
      WHERE (xe.chart_group_id=reply->chart_group_list[1].chart_group_id))
     DETAIL
      reply->chart_group_list[1].xencntr_info.rslt_seq = xe.rslt_seq_flag, reply->chart_group_list[1]
      .xencntr_info.prefix_format_flag = xe.ea_prefix_format_flag, reply->chart_group_list[1].
      xencntr_info.prefix_format = xe.ea_prefix_format,
      reply->chart_group_list[1].xencntr_info.encntr_alias_lbl = xe.encntr_alias_lbl, reply->
      chart_group_list[1].xencntr_info.encntr_alias_odr = xe.encntr_alias_odr, reply->
      chart_group_list[1].xencntr_info.facility_lbl = xe.facility_lbl,
      reply->chart_group_list[1].xencntr_info.building_lbl = xe.building_lbl, reply->
      chart_group_list[1].xencntr_info.nurse_unit_lbl = xe.nurse_unit_lbl, reply->chart_group_list[1]
      .xencntr_info.client_lbl = xe.client_lbl,
      reply->chart_group_list[1].xencntr_info.fin_nbr_lbl = xe.fin_nbr_lbl, reply->chart_group_list[1
      ].xencntr_info.mrn_lbl = xe.mrn_lbl, reply->chart_group_list[1].xencntr_info.admit_dt_lbl = xe
      .admit_dt_lbl,
      reply->chart_group_list[1].xencntr_info.dischg_dt_lbl = xe.dischg_dt_lbl, reply->
      chart_group_list[1].xencntr_info.diagnosis_lbl = xe.diagnosis_lbl, reply->chart_group_list[1].
      xencntr_info.facility_odr = xe.facility_odr,
      reply->chart_group_list[1].xencntr_info.building_odr = xe.building_odr, reply->
      chart_group_list[1].xencntr_info.nurse_unit_odr = xe.nurse_unit_odr, reply->chart_group_list[1]
      .xencntr_info.client_odr = xe.client_odr,
      reply->chart_group_list[1].xencntr_info.fin_nbr_odr = xe.fin_nbr_odr, reply->chart_group_list[1
      ].xencntr_info.mrn_odr = xe.mrn_odr, reply->chart_group_list[1].xencntr_info.admit_dt_odr = xe
      .admit_dt_odr,
      reply->chart_group_list[1].xencntr_info.dischg_dt_odr = xe.dischg_dt_odr, reply->
      chart_group_list[1].xencntr_info.diagnosis_odr = xe.diagnosis_odr
     WITH nocounter
    ;end select
    CALL error_and_zero_check(curqual,"CHART_XENCNTR_FORMAT","GETSECTIONSPECIFICINFO",1,1)
   OF flex_section_type:
    SELECT INTO "nl:"
     FROM chart_flex_format cff
     PLAN (cff
      WHERE (cff.chart_group_id=reply->chart_group_list[1].chart_group_id))
     DETAIL
      reply->chart_group_list[1].flex_info.flex_type = cff.flex_type, reply->chart_group_list[1].
      flex_info.prod_nbr_lbl = cff.product_nbr_lbl, reply->chart_group_list[1].flex_info.desc_lbl =
      cff.description_lbl,
      reply->chart_group_list[1].flex_info.disp_lbl = cff.display_lbl, reply->chart_group_list[1].
      flex_info.abo_lbl = cff.abo_rh_lbl, reply->chart_group_list[1].flex_info.verified_dt_lbl = cff
      .verified_dt_tm_lbl,
      reply->chart_group_list[1].flex_info.collected_dt_lbl = cff.collected_dt_tm_lbl, reply->
      chart_group_list[1].flex_info.prod_nbr_odr = cff.product_nbr_order, reply->chart_group_list[1].
      flex_info.desc_odr = cff.description_order,
      reply->chart_group_list[1].flex_info.disp_odr = cff.display_order, reply->chart_group_list[1].
      flex_info.abo_odr = cff.abo_rh_order, reply->chart_group_list[1].flex_info.verified_dt_odr =
      cff.verified_dt_tm_order,
      reply->chart_group_list[1].flex_info.collected_dt_odr = cff.collected_dt_tm_order, reply->
      chart_group_list[1].flex_info.result_seq = cff.order_seq_flag, reply->chart_group_list[1].
      flex_info.crossmatch_result_lbl = cff.crossmatch_result_lbl,
      reply->chart_group_list[1].flex_info.crossmatch_result_odr = cff.crossmatch_result_order
     WITH nocounter
    ;end select
    CALL error_and_zero_check(curqual,"CHART_FLEX_FORMAT","GETSECTIONSPECIFICINFO",1,1)
   OF horz_section_type:
    SELECT INTO "nl:"
     FROM chart_horz_format chf,
      (dummyt d  WITH seq = value(grpcount))
     PLAN (d)
      JOIN (chf
      WHERE (chf.chart_group_id=reply->chart_group_list[d.seq].chart_group_id))
     ORDER BY d.seq
     HEAD d.seq
      stat = alterlist(reply->chart_group_list[d.seq].horizontal_info_list,1)
     DETAIL
      reply->chart_group_list[d.seq].horizontal_info_list[1].test_lbl_order = chf.test_lbl_order,
      reply->chart_group_list[d.seq].horizontal_info_list[1].units_lbl_order = chf.units_lbl_order,
      reply->chart_group_list[d.seq].horizontal_info_list[1].refer_lbl_order = chf.refer_lbl_order,
      reply->chart_group_list[d.seq].horizontal_info_list[1].normall_lbl_order = chf
      .normall_lbl_order, reply->chart_group_list[d.seq].horizontal_info_list[1].normalh_lbl_order =
      chf.normalh_lbl_order, reply->chart_group_list[d.seq].horizontal_info_list[1].perfid_lbl_order
       = chf.perfid_lbl_order,
      reply->chart_group_list[d.seq].horizontal_info_list[1].date_order = chf.date_order, reply->
      chart_group_list[d.seq].horizontal_info_list[1].weekday_order = chf.weekday_order, reply->
      chart_group_list[d.seq].horizontal_info_list[1].staydays_order = chf.staydays_order,
      reply->chart_group_list[d.seq].horizontal_info_list[1].time_order = chf.time_order, reply->
      chart_group_list[d.seq].horizontal_info_list[1].test_lbl = chf.test_lbl, reply->
      chart_group_list[d.seq].horizontal_info_list[1].units_lbl = chf.units_lbl,
      reply->chart_group_list[d.seq].horizontal_info_list[1].ref_range_lbl = chf.ref_range_lbl, reply
      ->chart_group_list[d.seq].horizontal_info_list[1].normal_low_lbl = chf.normal_low_lbl, reply->
      chart_group_list[d.seq].horizontal_info_list[1].normal_high_lbl = chf.normal_high_lbl,
      reply->chart_group_list[d.seq].horizontal_info_list[1].perfid_lbl = chf.perfid_lbl, reply->
      chart_group_list[d.seq].horizontal_info_list[1].date_mask = chf.date_mask, reply->
      chart_group_list[d.seq].horizontal_info_list[1].time_mask = chf.time_mask,
      reply->chart_group_list[d.seq].horizontal_info_list[1].ref_rng_form_flag = chf
      .ref_rng_form_flag, reply->chart_group_list[d.seq].horizontal_info_list[1].rslt_seq_flag = chf
      .rslt_seq_flag, reply->chart_group_list[d.seq].horizontal_info_list[1].ftnote_loc_flag = chf
      .ftnote_loc_flag,
      reply->chart_group_list[d.seq].horizontal_info_list[1].interp_loc_flag = chf.interp_loc_flag,
      reply->chart_group_list[d.seq].horizontal_info_list[1].wkday_format_flag = chf
      .wkday_format_flag, reply->chart_group_list[d.seq].horizontal_info_list[1].rslt_start_col = chf
      .rslt_start_col,
      reply->chart_group_list[d.seq].horizontal_info_list[1].encntr_alias_order = chf
      .encntr_alias_order, reply->chart_group_list[d.seq].horizontal_info_list[1].flowsheet_ind = chf
      .flowsheet_ind
     WITH nocounter
    ;end select
    CALL error_and_zero_check(curqual,"CHART_HORZ_FORMAT","GETSECTIONSPECIFICINFO",1,1)
   OF mic_section_type:
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
      FROM long_text lt
      PLAN (lt
       WHERE (lt.parent_entity_id=reply->chart_group_list[1].chart_group_id)
        AND lt.parent_entity_name="CHART MICRO LEGEND"
        AND lt.active_ind=1)
      HEAD REPORT
       long_text = lt.long_text
      WITH nocounter
     ;end select
     CALL error_and_zero_check(curqual,"LONG_TEXT","GETSECTIONSPECIFICINFO",1,0)
     SELECT INTO "nl:"
      FROM chart_micro_format cmf
      PLAN (cmf
       WHERE (cmf.chart_group_id=reply->chart_group_list[1].chart_group_id))
      HEAD REPORT
       opt_nbr = 0
      DETAIL
       opt_nbr = (opt_nbr+ 1)
       IF (mod(opt_nbr,5)=1)
        stat = alterlist(reply->chart_group_list[1].micro_info.option_list,(opt_nbr+ 4))
       ENDIF
       reply->chart_group_list[1].micro_info.option_list[opt_nbr].option_flag = cmf.option_flag,
       reply->chart_group_list[1].micro_info.option_list[opt_nbr].option_value =
       IF (cmf.option_flag=57) long_text
       ELSE cmf.option_value
       ENDIF
      FOOT REPORT
       stat = alterlist(reply->chart_group_list[1].micro_info.option_list,opt_nbr)
      WITH nocounter
     ;end select
     CALL error_and_zero_check(curqual,"CHART_MICRO_FORMAT","GETSECTIONSPECIFICINFO",1,0)
    ENDIF
   OF ord_sum_section_type:
    SELECT INTO "nl:"
     FROM chart_order_summary_format cosf,
      chart_ord_sum_filter osf
     PLAN (cosf
      WHERE (cosf.chart_group_id=reply->chart_group_list[1].chart_group_id))
      JOIN (osf
      WHERE osf.chart_group_id=cosf.chart_group_id)
     ORDER BY osf.sequence
     HEAD REPORT
      filter_count = 0, reply->chart_group_list[1].order_summary_info.order_summary_type = cosf
      .order_summary_type, reply->chart_group_list[1].order_summary_info.date_lbl = cosf.date_lbl,
      reply->chart_group_list[1].order_summary_info.time_lbl = cosf.time_lbl, reply->
      chart_group_list[1].order_summary_info.name_lbl = cosf.name_lbl, reply->chart_group_list[1].
      order_summary_info.mnemonic_lbl = cosf.mnemonic_lbl,
      reply->chart_group_list[1].order_summary_info.status_lbl = cosf.status_lbl, reply->
      chart_group_list[1].order_summary_info.cancel_reason_lbl = cosf.cancel_reason_lbl, reply->
      chart_group_list[1].order_summary_info.date_mask = cosf.date_mask,
      reply->chart_group_list[1].order_summary_info.time_mask = cosf.time_mask, reply->
      chart_group_list[1].order_summary_info.date_odr = cosf.date_order, reply->chart_group_list[1].
      order_summary_info.time_odr = cosf.time_order,
      reply->chart_group_list[1].order_summary_info.name_odr = cosf.name_order, reply->
      chart_group_list[1].order_summary_info.mnemonic_odr = cosf.mnemonic_order, reply->
      chart_group_list[1].order_summary_info.status_odr = cosf.status_order,
      reply->chart_group_list[1].order_summary_info.cancel_reason_odr = cosf.cancel_reason_order,
      reply->chart_group_list[1].order_summary_info.order_seq_flag = cosf.order_seq_flag, reply->
      chart_group_list[1].order_summary_info.order_provider_ind = cosf.order_provider_ind,
      reply->chart_group_list[1].order_summary_info.order_provider_lbl = cosf.order_provider_lbl,
      reply->chart_group_list[1].order_summary_info.order_provider_odr = cosf.order_provider_order,
      reply->chart_group_list[1].order_summary_info.dept_status_lbl = cosf.dept_status_lbl,
      reply->chart_group_list[1].order_summary_info.dept_status_odr = cosf.dept_status_order
     DETAIL
      filter_count = (filter_count+ 1)
      IF (mod(filter_count,5)=1)
       stat = alterlist(reply->chart_group_list[1].order_summary_info.os_filter_list,(filter_count+ 4
        ))
      ENDIF
      reply->chart_group_list[1].order_summary_info.os_filter_list[filter_count].filter_cd = osf
      .filter_cd, reply->chart_group_list[1].order_summary_info.os_filter_list[filter_count].
      filter_display = uar_get_code_display(osf.filter_cd), reply->chart_group_list[1].
      order_summary_info.os_filter_list[filter_count].filter_type = osf.filter_type_flag,
      reply->chart_group_list[1].order_summary_info.os_filter_list[filter_count].filter_seq = osf
      .sequence
     FOOT REPORT
      stat = alterlist(reply->chart_group_list[1].order_summary_info.os_filter_list,filter_count)
     WITH nocounter
    ;end select
    CALL error_and_zero_check(curqual,"CHART_ORDER_SUMMARY_FORMAT","GETSECTIONSPECIFICINFO",1,1)
   OF rad_section_type:
    SELECT INTO "nl:"
     FROM chart_rad_format crf
     PLAN (crf
      WHERE (crf.chart_group_id=reply->chart_group_list[1].chart_group_id))
     DETAIL
      reply->chart_group_list[1].rad_info.group_style = crf.group_style, reply->chart_group_list[1].
      rad_info.reason_annotation = crf.reason_annotation, reply->chart_group_list[1].rad_info.
      reason_caption = crf.reason_caption,
      reply->chart_group_list[1].rad_info.reason_ind = crf.reason_ind, reply->chart_group_list[1].
      rad_info.result_sequence = crf.result_sequence, reply->chart_group_list[1].rad_info.
      cpt4_code_ind = crf.cpt4_code_ind,
      reply->chart_group_list[1].rad_info.cpt4_desc_ind = crf.cpt4_desc_ind, reply->chart_group_list[
      1].rad_info.cpt4_label = crf.cpt4_label, reply->chart_group_list[1].rad_info.cpt4_label_style
       = crf.cpt4_label_style,
      reply->chart_group_list[1].rad_info.cdm_code_ind = crf.cdm_code_ind, reply->chart_group_list[1]
      .rad_info.cdm_desc_ind = crf.cdm_desc_ind, reply->chart_group_list[1].rad_info.cdm_label = crf
      .cdm_label,
      reply->chart_group_list[1].rad_info.cdm_label_style = crf.cdm_label_style, reply->
      chart_group_list[1].rad_info.cor_footnote_ind = crf.cor_footnote_ind
     WITH nocounter
    ;end select
    CALL error_and_zero_check(curqual,"CHART_RAD_FORMAT","GETSECTIONSPECIFICINFO",1,1)
    CALL getsectionfields(null)
   OF vert_section_type:
    SELECT INTO "nl:"
     FROM chart_vert_format cvf,
      (dummyt d  WITH seq = value(grpcount))
     PLAN (d)
      JOIN (cvf
      WHERE (cvf.chart_group_id=reply->chart_group_list[d.seq].chart_group_id))
     ORDER BY d.seq
     HEAD d.seq
      stat = alterlist(reply->chart_group_list[d.seq].vertical_info_list,1)
     DETAIL
      reply->chart_group_list[d.seq].vertical_info_list[1].test_lbl_order = cvf.test_lbl_order, reply
      ->chart_group_list[d.seq].vertical_info_list[1].units_lbl_order = cvf.units_lbl_order, reply->
      chart_group_list[d.seq].vertical_info_list[1].refer_lbl_order = cvf.refer_lbl_order,
      reply->chart_group_list[d.seq].vertical_info_list[1].perfid_lbl_order = cvf.perfid_lbl_order,
      reply->chart_group_list[d.seq].vertical_info_list[1].test_lbl_pos = cvf.test_lbl_pos, reply->
      chart_group_list[d.seq].vertical_info_list[1].units_lbl_pos = cvf.units_lbl_pos,
      reply->chart_group_list[d.seq].vertical_info_list[1].refer_lbl_pos = cvf.refer_lbl_pos, reply->
      chart_group_list[d.seq].vertical_info_list[1].perfid_lbl_pos = cvf.perfid_lbl_pos, reply->
      chart_group_list[d.seq].vertical_info_list[1].test_lbl = cvf.test_lbl,
      reply->chart_group_list[d.seq].vertical_info_list[1].units_lbl = cvf.units_lbl, reply->
      chart_group_list[d.seq].vertical_info_list[1].ref_range_lbl = cvf.ref_range_lbl, reply->
      chart_group_list[d.seq].vertical_info_list[1].perfid_lbl = cvf.perfid_lbl,
      reply->chart_group_list[d.seq].vertical_info_list[1].date_lbl = cvf.date_lbl, reply->
      chart_group_list[d.seq].vertical_info_list[1].staydays_lbl = cvf.staydays_lbl, reply->
      chart_group_list[d.seq].vertical_info_list[1].time_lbl = cvf.time_lbl,
      reply->chart_group_list[d.seq].vertical_info_list[1].date_order = cvf.date_order, reply->
      chart_group_list[d.seq].vertical_info_list[1].staydays_order = cvf.staydays_order, reply->
      chart_group_list[d.seq].vertical_info_list[1].time_order = cvf.time_order,
      reply->chart_group_list[d.seq].vertical_info_list[1].ref_rng_form_flag = cvf.ref_rng_form_flag,
      reply->chart_group_list[d.seq].vertical_info_list[1].rslt_seq_flag = cvf.rslt_seq_flag, reply->
      chart_group_list[d.seq].vertical_info_list[1].ftnote_loc_flag = cvf.ftnote_loc_flag,
      reply->chart_group_list[d.seq].vertical_info_list[1].interp_loc_flag = cvf.interp_loc_flag,
      reply->chart_group_list[d.seq].vertical_info_list[1].date_mask = cvf.date_mask, reply->
      chart_group_list[d.seq].vertical_info_list[1].time_mask = cvf.time_mask,
      reply->chart_group_list[d.seq].vertical_info_list[1].staydays_form_flag = cvf
      .staydays_form_flag, reply->chart_group_list[d.seq].vertical_info_list[1].rslt_start_col = cvf
      .reslt_start_col, reply->chart_group_list[d.seq].vertical_info_list[1].encntr_alias_order = cvf
      .encntr_alias_order,
      reply->chart_group_list[d.seq].vertical_info_list[1].encntr_alias_lbl = cvf.encntr_alias_lbl,
      reply->chart_group_list[d.seq].vertical_info_list[1].flowsheet_ind = cvf.flowsheet_ind
     WITH nocounter
    ;end select
    CALL error_and_zero_check(curqual,"CHART_VERT_FORMAT","GETSECTIONSPECIFICINFO",1,1)
   OF zonal_old_section_type:
    SELECT INTO "nl:"
     FROM chart_zonal_format czf,
      chart_zn_form_zone czfz,
      (dummyt d  WITH seq = value(grpcount))
     PLAN (d)
      JOIN (czf
      WHERE (czf.chart_group_id=reply->chart_group_list[d.seq].chart_group_id))
      JOIN (czfz
      WHERE czfz.chart_group_id=czf.chart_group_id)
     ORDER BY d.seq, czfz.zone_seq
     HEAD d.seq
      itemcount = 0, stat = alterlist(reply->chart_group_list[d.seq].zonal_info_list,1), reply->
      chart_group_list[d.seq].zonal_info_list[1].ref_rng_form_flag = czf.ref_rng_form_flag,
      reply->chart_group_list[d.seq].zonal_info_list[1].date_mask = czf.date_mask, reply->
      chart_group_list[d.seq].zonal_info_list[1].time_mask = czf.time_mask, reply->chart_group_list[d
      .seq].zonal_info_list[1].rslt_seq_flag = czf.rslt_seq_flag,
      reply->chart_group_list[d.seq].zonal_info_list[1].ftnote_loc_flag = czf.ftnote_loc_flag, reply
      ->chart_group_list[d.seq].zonal_info_list[1].interp_loc_flag = czf.interp_loc_flag
     DETAIL
      itemcount = (itemcount+ 1)
      IF (mod(itemcount,5)=1)
       stat = alterlist(reply->chart_group_list[d.seq].zonal_info_list,(itemcount+ 4))
      ENDIF
      reply->chart_group_list[d.seq].zonal_info_list[itemcount].zone_seq = czfz.zone_seq, reply->
      chart_group_list[d.seq].zonal_info_list[itemcount].test_lbl = czfz.test_lbl, reply->
      chart_group_list[d.seq].zonal_info_list[itemcount].units_lbl = czfz.units_lbl,
      reply->chart_group_list[d.seq].zonal_info_list[itemcount].ref_range_lbl = czfz.ref_range_lbl,
      reply->chart_group_list[d.seq].zonal_info_list[itemcount].alpha_abn_rslt_lbl = czfz
      .alpha_abn_rslt_lbl, reply->chart_group_list[d.seq].zonal_info_list[itemcount].all_rslt_lbl =
      czfz.all_rslt_lbl,
      reply->chart_group_list[d.seq].zonal_info_list[itemcount].crit_rslt_lbl = czfz.crit_rslt_lbl,
      reply->chart_group_list[d.seq].zonal_info_list[itemcount].high_rslt_lbl = czfz.high_rslt_lbl,
      reply->chart_group_list[d.seq].zonal_info_list[itemcount].low_rslt_lbl = czfz.low_rslt_lbl,
      reply->chart_group_list[d.seq].zonal_info_list[itemcount].normal_rslt_lbl = czfz
      .normal_rslt_lbl, reply->chart_group_list[d.seq].zonal_info_list[itemcount].test_col = czfz
      .test_col, reply->chart_group_list[d.seq].zonal_info_list[itemcount].units_col = czfz.units_col,
      reply->chart_group_list[d.seq].zonal_info_list[itemcount].ref_range_col = czfz.ref_range_col,
      reply->chart_group_list[d.seq].zonal_info_list[itemcount].all_rslt_col = czfz.all_rslt_col,
      reply->chart_group_list[d.seq].zonal_info_list[itemcount].low_rslt_col = czfz.low_rslt_col,
      reply->chart_group_list[d.seq].zonal_info_list[itemcount].normal_rslt_col = czfz
      .normal_rslt_col, reply->chart_group_list[d.seq].zonal_info_list[itemcount].high_rslt_col =
      czfz.high_rslt_col, reply->chart_group_list[d.seq].zonal_info_list[itemcount].crit_rslt_col =
      czfz.crit_rslt_col,
      reply->chart_group_list[d.seq].zonal_info_list[itemcount].alpha_abn_rslt_col = czfz
      .alpha_abn_rslt_col
     FOOT REPORT
      stat = alterlist(reply->chart_group_list[d.seq].zonal_info_list,itemcount)
     WITH nocounter
    ;end select
    CALL error_and_zero_check(curqual,"CHART_ZONAL_FORMAT","GETSECTIONSPECIFICINFO",1,1)
   OF ap_section_type:
    SELECT INTO "nl:"
     FROM chart_ap_format capf,
      long_text_reference ltr
     PLAN (capf
      WHERE (capf.chart_group_id=reply->chart_group_list[1].chart_group_id))
      JOIN (ltr
      WHERE capf.ap_cpt_long_text_id=ltr.long_text_id)
     DETAIL
      reply->chart_group_list[1].ap_info.group_style = capf.group_style, reply->chart_group_list[1].
      ap_info.result_sequence = capf.result_sequence, reply->chart_group_list[1].ap_info.
      snomed_codes_ind = capf.snomed_codes_ind,
      reply->chart_group_list[1].ap_info.snomed_desc_ind = capf.snomed_desc_ind, reply->
      chart_group_list[1].ap_info.snomed_codes_lbl = capf.snomed_codes_lbl, reply->chart_group_list[1
      ].ap_info.snomed_cd_lbl_style = capf.snomed_cd_lbl_style,
      reply->chart_group_list[1].ap_info.tcc_codes_ind = capf.tcc_codes_ind, reply->chart_group_list[
      1].ap_info.tcc_desc_ind = capf.tcc_desc_ind, reply->chart_group_list[1].ap_info.tcc_codes_lbl
       = capf.tcc_codes_lbl,
      reply->chart_group_list[1].ap_info.tcc_cd_lbl_style = capf.tcc_cd_lbl_style, reply->
      chart_group_list[1].ap_info.ap_history_flag = capf.ap_history_flag, reply->chart_group_list[1].
      ap_info.image_flag = capf.image_flag
      IF (capf.ap_cpt_long_text_id != 0)
       reply->chart_group_list[1].ap_info.cpt_long_text = ltr.long_text
      ENDIF
     WITH nocounter
    ;end select
    CALL error_and_zero_check(curqual,"CHART_AP_FORMAT","GETSECTIONSPECIFICINFO",1,1)
    CALL getsectionfields(null)
   OF hla_section_type:
    SELECT INTO "nl:"
     FROM chart_hla_format hla
     PLAN (hla
      WHERE (hla.chart_group_id=reply->chart_group_list[1].chart_group_id))
     DETAIL
      reply->chart_group_list[1].hla_info.hla_type = hla.hla_type, reply->chart_group_list[1].
      hla_info.line_ind = hla.line_indicator, reply->chart_group_list[1].hla_info.rslt_seq = hla
      .result_seq_flag,
      reply->chart_group_list[1].hla_info.prsn_name_lbl = hla.prsn_name_label, reply->
      chart_group_list[1].hla_info.date_lbl = hla.date_label, reply->chart_group_list[1].hla_info.
      mrn_lbl = hla.mrn_label,
      reply->chart_group_list[1].hla_info.relation_lbl = hla.relation_label, reply->chart_group_list[
      1].hla_info.abo_rh_lbl = hla.abo_rh_label, reply->chart_group_list[1].hla_info.haploid1_lbl =
      hla.haploid1_label,
      reply->chart_group_list[1].hla_info.haploid2_lbl = hla.haploid2_label, reply->chart_group_list[
      1].hla_info.haplotype1_lbl = hla.haplotype1_label, reply->chart_group_list[1].hla_info.
      haplotype2_lbl = hla.haplotype2_label,
      reply->chart_group_list[1].hla_info.haploid1_odr = hla.haploid1_order, reply->chart_group_list[
      1].hla_info.haploid2_odr = hla.haploid2_order, reply->chart_group_list[1].hla_info.
      haplotype1_odr = hla.haplotype1_order,
      reply->chart_group_list[1].hla_info.haplotype2_odr = hla.haplotype2_order, reply->
      chart_group_list[1].hla_info.prsn_name_odr = hla.prsn_name_order, reply->chart_group_list[1].
      hla_info.date_odr = hla.date_order,
      reply->chart_group_list[1].hla_info.mrn_odr = hla.mrn_order, reply->chart_group_list[1].
      hla_info.relation_odr = hla.relation_order, reply->chart_group_list[1].hla_info.abo_rh_odr =
      hla.abo_rh_order,
      reply->chart_group_list[1].hla_info.result_odr = hla.result_order, reply->chart_group_list[1].
      hla_info.prsn_name_rpt = hla.prsn_name_rpt, reply->chart_group_list[1].hla_info.date_rpt = hla
      .date_rpt,
      reply->chart_group_list[1].hla_info.mrn_rpt = hla.mrn_rpt, reply->chart_group_list[1].hla_info.
      relation_rpt = hla.relation_rpt, reply->chart_group_list[1].hla_info.abo_rpt = hla.abo_rpt,
      reply->chart_group_list[1].hla_info.rh_ind = hla.rh_ind
     WITH nocounter
    ;end select
    CALL error_and_zero_check(curqual,"CHART_HLA_FORMAT","GETSECTIONSPECIFICINFO",1,1)
   OF doc_section_type:
    SELECT INTO "nl:"
     FROM chart_doc_format doc
     PLAN (doc
      WHERE (doc.chart_group_id=reply->chart_group_list[1].chart_group_id))
     DETAIL
      reply->chart_group_list[1].doc_info.rslt_seq = doc.result_seq_flag, reply->chart_group_list[1].
      doc_info.pgbrk_ind = doc.page_brk_ind, reply->chart_group_list[1].doc_info.exclude_img_mdoc_ind
       = doc.exclude_img_mdoc_ind,
      reply->chart_group_list[1].doc_info.include_img_head_ind = doc.include_img_header_ind, reply->
      chart_group_list[1].doc_info.include_img_foot_ind = doc.include_img_footer_ind, reply->
      chart_group_list[1].doc_info.doc_type = doc.doc_type_flag
     WITH nocounter
    ;end select
    CALL error_and_zero_check(curqual,"CHART_DOC_FORMAT","GETSECTIONSPECIFICINFO",1,1)
    CALL getsectionfields(null)
   OF lab_text_section_type:
    SELECT INTO "nl:"
     FROM chart_gl_format gl
     PLAN (gl
      WHERE (gl.chart_group_id=reply->chart_group_list[1].chart_group_id))
     DETAIL
      reply->chart_group_list[1].gl_info.rslt_seq = gl.result_seq_flag, reply->chart_group_list[1].
      gl_info.group_style = gl.group_style
     WITH nocounter
    ;end select
    CALL error_and_zero_check(curqual,"CHART_GL_FORMAT","GETSECTIONSPECIFICINFO",1,1)
    CALL getsectionfields(null)
   OF allergy_section_type:
    SELECT INTO "nl:"
     FROM chart_allergy_format alg
     PLAN (alg
      WHERE (alg.chart_group_id=reply->chart_group_list[1].chart_group_id))
     DETAIL
      reply->chart_group_list[1].allergy_info.substance_lbl = alg.substance_lbl, reply->
      chart_group_list[1].allergy_info.category_lbl = alg.category_lbl, reply->chart_group_list[1].
      allergy_info.updt_dt_lbl = alg.updt_dt_lbl,
      reply->chart_group_list[1].allergy_info.severity_lbl = alg.severity_lbl, reply->
      chart_group_list[1].allergy_info.reaction_stat_lbl = alg.reaction_stat_lbl, reply->
      chart_group_list[1].allergy_info.reaction_lbl = alg.reaction_lbl,
      reply->chart_group_list[1].allergy_info.updt_by_lbl = alg.updt_by_lbl, reply->chart_group_list[
      1].allergy_info.source_lbl = alg.source_lbl, reply->chart_group_list[1].allergy_info.
      onset_dt_lbl = alg.onset_dt_lbl,
      reply->chart_group_list[1].allergy_info.type_lbl = alg.type_lbl, reply->chart_group_list[1].
      allergy_info.cancel_lbl = alg.cancel_lbl, reply->chart_group_list[1].allergy_info.comment_lbl
       = alg.comment_lbl,
      reply->chart_group_list[1].allergy_info.severity_odr = alg.severity_odr, reply->
      chart_group_list[1].allergy_info.reaction_stat_odr = alg.reaction_stat_odr, reply->
      chart_group_list[1].allergy_info.reaction_odr = alg.reaction_odr,
      reply->chart_group_list[1].allergy_info.source_odr = alg.source_odr, reply->chart_group_list[1]
      .allergy_info.onset_dt_odr = alg.onset_dt_odr, reply->chart_group_list[1].allergy_info.type_odr
       = alg.type_odr,
      reply->chart_group_list[1].allergy_info.cancel_odr = alg.cancel_odr, reply->chart_group_list[1]
      .allergy_info.category_odr = alg.category_odr, reply->chart_group_list[1].allergy_info.
      result_sequence_ind = alg.result_sequence_ind
     WITH nocounter
    ;end select
    CALL error_and_zero_check(curqual,"CHART_ALLERGY_FORMAT","GETSECTIONSPECIFICINFO",1,1)
   OF prob_list_section_type:
    SELECT INTO "nl:"
     FROM chart_problem_format prob
     PLAN (prob
      WHERE (prob.chart_group_id=reply->chart_group_list[1].chart_group_id))
     DETAIL
      reply->chart_group_list[1].prob_info.prob_name_lbl = prob.prob_name_lbl, reply->
      chart_group_list[1].prob_info.date_rec_lbl = prob.date_recorded_lbl, reply->chart_group_list[1]
      .prob_info.code_lbl = prob.code_lbl,
      reply->chart_group_list[1].prob_info.con_stat_lbl = prob.con_stat_lbl, reply->chart_group_list[
      1].prob_info.life_stat_lbl = prob.life_stat_lbl, reply->chart_group_list[1].prob_info.
      course_lbl = prob.course_lbl,
      reply->chart_group_list[1].prob_info.perst_lbl = prob.perst_lbl, reply->chart_group_list[1].
      prob_info.prog_lbl = prob.prog_lbl, reply->chart_group_list[1].prob_info.onset_lbl = prob
      .onset_lbl,
      reply->chart_group_list[1].prob_info.prov_lbl = prob.prov_lbl, reply->chart_group_list[1].
      prob_info.date_est_lbl = prob.date_est_lbl, reply->chart_group_list[1].prob_info.cancel_lbl =
      prob.cancel_lbl,
      reply->chart_group_list[1].prob_info.comment_lbl = prob.comment_lbl, reply->chart_group_list[1]
      .prob_info.code_ord = prob.code_ord, reply->chart_group_list[1].prob_info.con_stat_ord = prob
      .con_stat_ord,
      reply->chart_group_list[1].prob_info.life_stat_ord = prob.life_stat_ord, reply->
      chart_group_list[1].prob_info.course_ord = prob.course_ord, reply->chart_group_list[1].
      prob_info.perst_ord = prob.perst_ord,
      reply->chart_group_list[1].prob_info.prog_ord = prob.prog_ord, reply->chart_group_list[1].
      prob_info.onset_ord = prob.onset_ord, reply->chart_group_list[1].prob_info.cancel_ord = prob
      .cancel_ord,
      reply->chart_group_list[1].prob_info.result_sequence_ind = prob.result_sequence_ind, reply->
      chart_group_list[1].prob_info.date_rec_result_sequence_ind = prob.date_recorded_sequence_ind
     WITH nocounter
    ;end select
    CALL error_and_zero_check(curqual,"CHART_PROBLEM_FORMAT","GETSECTIONSPECIFICINFO",1,1)
   OF zonal_new_section_type:
    SELECT INTO "nl:"
     FROM chart_zonal_format czf,
      chart_dyn_zone_form cdzf,
      chart_zn_result_col czrc,
      chart_zn_result_col_cds czrcc,
      (dummyt d  WITH seq = value(grpcount))
     PLAN (d)
      JOIN (czf
      WHERE (czf.chart_group_id=reply->chart_group_list[d.seq].chart_group_id))
      JOIN (cdzf
      WHERE cdzf.chart_group_id=czf.chart_group_id)
      JOIN (czrc
      WHERE czrc.chart_group_id=cdzf.chart_group_id
       AND czrc.zone_seq=cdzf.zone_seq)
      JOIN (czrcc
      WHERE czrcc.chart_group_id=czrc.chart_group_id
       AND czrcc.zone_seq=czrc.zone_seq
       AND czrcc.column_seq=czrc.column_seq)
     ORDER BY d.seq, cdzf.zone_seq, czrc.column_seq,
      czrcc.normalcy_cd
     HEAD d.seq
      zonecount = 0, colcount = 0, codecount = 0,
      reply->chart_group_list[d.seq].new_zonal_info.collect_date_lbl = czf.collect_date_lbl, reply->
      chart_group_list[d.seq].new_zonal_info.collect_date_chk = czf.collect_date_chk, reply->
      chart_group_list[d.seq].new_zonal_info.ref_rng_form_flag = czf.ref_rng_form_flag,
      reply->chart_group_list[d.seq].new_zonal_info.date_format_cd = czf.date_format_cd, reply->
      chart_group_list[d.seq].new_zonal_info.time_format_flag = czf.time_format_flag, reply->
      chart_group_list[d.seq].new_zonal_info.date_mask = czf.date_mask,
      reply->chart_group_list[d.seq].new_zonal_info.time_mask = czf.time_mask, reply->
      chart_group_list[d.seq].new_zonal_info.rslt_seq_flag = czf.rslt_seq_flag, reply->
      chart_group_list[d.seq].new_zonal_info.ftnote_loc_flag = czf.ftnote_loc_flag,
      reply->chart_group_list[d.seq].new_zonal_info.interp_loc_flag = czf.interp_loc_flag
     HEAD cdzf.zone_seq
      zonecount = (zonecount+ 1)
      IF (mod(zonecount,3)=1)
       stat = alterlist(reply->chart_group_list[d.seq].new_zonal_info.zone_list,(zonecount+ 2))
      ENDIF
      reply->chart_group_list[d.seq].new_zonal_info.zone_list[zonecount].zone_seq = cdzf.zone_seq,
      reply->chart_group_list[d.seq].new_zonal_info.zone_list[zonecount].proc_lbl = cdzf.proc_lbl,
      reply->chart_group_list[d.seq].new_zonal_info.zone_list[zonecount].units_lbl = cdzf.units_lbl,
      reply->chart_group_list[d.seq].new_zonal_info.zone_list[zonecount].ref_range_lbl = cdzf
      .ref_range_lbl, reply->chart_group_list[d.seq].new_zonal_info.zone_list[zonecount].proc_col =
      cdzf.proc_col, reply->chart_group_list[d.seq].new_zonal_info.zone_list[zonecount].units_col =
      cdzf.units_col,
      reply->chart_group_list[d.seq].new_zonal_info.zone_list[zonecount].ref_range_col = cdzf
      .ref_range_col
     HEAD czrc.column_seq
      colcount = (colcount+ 1)
      IF (mod(colcount,5)=1)
       stat = alterlist(reply->chart_group_list[d.seq].new_zonal_info.zone_list[zonecount].
        result_col_list,(colcount+ 4))
      ENDIF
      reply->chart_group_list[d.seq].new_zonal_info.zone_list[zonecount].result_col_list[colcount].
      column_seq = czrc.column_seq, reply->chart_group_list[d.seq].new_zonal_info.zone_list[zonecount
      ].result_col_list[colcount].col_index = czrc.col_index, reply->chart_group_list[d.seq].
      new_zonal_info.zone_list[zonecount].result_col_list[colcount].description = czrc.description
     DETAIL
      codecount = (codecount+ 1)
      IF (mod(codecount,10)=1)
       stat = alterlist(reply->chart_group_list[d.seq].new_zonal_info.zone_list[zonecount].
        result_col_list[colcount].normalcy_cds,(codecount+ 9))
      ENDIF
      reply->chart_group_list[d.seq].new_zonal_info.zone_list[zonecount].result_col_list[colcount].
      normalcy_cds[codecount].code = czrcc.normalcy_cd, reply->chart_group_list[d.seq].new_zonal_info
      .zone_list[zonecount].result_col_list[colcount].normalcy_cds[codecount].meaning =
      uar_get_code_meaning(czrcc.normalcy_cd)
     FOOT  czrc.column_seq
      stat = alterlist(reply->chart_group_list[d.seq].new_zonal_info.zone_list[zonecount].
       result_col_list[colcount].normalcy_cds,codecount), codecount = 0
     FOOT  cdzf.zone_seq
      stat = alterlist(reply->chart_group_list[d.seq].new_zonal_info.zone_list[zonecount].
       result_col_list,colcount), colcount = 0
     FOOT  d.seq
      stat = alterlist(reply->chart_group_list[d.seq].new_zonal_info.zone_list,zonecount), zonecount
       = 0
     WITH nocounter
    ;end select
    CALL error_and_zero_check(curqual,"CHART_DYN_ZONE_FORM","GETSECTIONSPECIFICINFO",1,1)
   OF orders_section_type:
    SELECT INTO "nl:"
     FROM chart_orders_format cof
     PLAN (cof
      WHERE (cof.chart_group_id=reply->chart_group_list[1].chart_group_id))
     DETAIL
      reply->chart_group_list[1].orders_info.order_seq_flag = cof.order_seq_flag, reply->
      chart_group_list[1].orders_info.date_time_chk = cof.date_time_ind, reply->chart_group_list[1].
      orders_info.date_time_lbl = cof.date_time_lbl,
      reply->chart_group_list[1].orders_info.action_chk = cof.action_ind, reply->chart_group_list[1].
      orders_info.action_lbl = cof.action_lbl, reply->chart_group_list[1].orders_info.mnemonic_chk =
      cof.mnemonic_ind,
      reply->chart_group_list[1].orders_info.mnemonic_lbl = cof.mnemonic_lbl, reply->
      chart_group_list[1].orders_info.order_phys_chk = cof.order_phys_ind, reply->chart_group_list[1]
      .orders_info.order_phys_lbl = cof.order_phys_lbl,
      reply->chart_group_list[1].orders_info.order_placer_chk = cof.order_placer_ind, reply->
      chart_group_list[1].orders_info.order_placer_lbl = cof.order_placer_lbl, reply->
      chart_group_list[1].orders_info.order_status_chk = cof.order_status_ind,
      reply->chart_group_list[1].orders_info.order_status_lbl = cof.order_status_lbl, reply->
      chart_group_list[1].orders_info.order_type_chk = cof.order_type_ind, reply->chart_group_list[1]
      .orders_info.order_type_lbl = cof.order_type_lbl,
      reply->chart_group_list[1].orders_info.details_chk = cof.details_ind, reply->chart_group_list[1
      ].orders_info.details_lbl = cof.details_lbl, reply->chart_group_list[1].orders_info.review_chk
       = cof.review_ind,
      reply->chart_group_list[1].orders_info.review_lbl = cof.review_lbl, reply->chart_group_list[1].
      orders_info.detail_order = cof.detail_order, reply->chart_group_list[1].orders_info.
      review_order = cof.review_order,
      reply->chart_group_list[1].orders_info.date_mask = cof.date_mask, reply->chart_group_list[1].
      orders_info.time_mask = cof.time_mask, reply->chart_group_list[1].orders_info.
      orderset_exclude_ind = cof.exclude_osname_ind,
      reply->chart_group_list[1].orders_info.label_bit_map = cof.label_bit_map, reply->
      chart_group_list[1].orders_info.cancel_reason_lbl = cof.cancel_reason_lbl, reply->
      chart_group_list[1].orders_info.canceled_dttm_lbl = cof.canceled_dttm_lbl,
      reply->chart_group_list[1].orders_info.comm_type_lbl = cof.comm_type_lbl, reply->
      chart_group_list[1].orders_info.dept_status_lbl = cof.dept_status_lbl, reply->chart_group_list[
      1].orders_info.discontinued_dttm_lbl = cof.discontinued_dttm_lbl,
      reply->chart_group_list[1].orders_info.future_disc_dttm_lbl = cof.future_disc_dttm_lbl, reply->
      chart_group_list[1].orders_info.orig_order_dttm_lbl = cof.orig_order_dttm_lbl, reply->
      chart_group_list[1].orders_info.suppress_meds_bit_map = cof.suppress_meds_bit_map,
      reply->chart_group_list[1].orders_info.action_seq_flag = cof.action_seq_flag, reply->
      chart_group_list[1].orders_info.detailed_layout_ind = cof.detailed_layout_ind
     WITH nocounter
    ;end select
    CALL error_and_zero_check(curqual,"CHART_ORDERS_FORMAT","GETSECTIONSPECIFICINFO",1,1)
   OF mar_section_type:
    SELECT INTO "nl:"
     FROM chart_mar_format cmf
     PLAN (cmf
      WHERE (cmf.chart_group_id=reply->chart_group_list[1].chart_group_id))
     DETAIL
      reply->chart_group_list[1].mar_info.section_order = cmf.section_order, reply->chart_group_list[
      1].mar_info.admin_seq_ind = cmf.admin_seq_ind, reply->chart_group_list[1].mar_info.
      ordered_as_mnemonic_chk = cmf.ordered_as_mnemonic_ind,
      reply->chart_group_list[1].mar_info.dispensed_mnemonic_chk = cmf.dispensed_mnemonic_ind, reply
      ->chart_group_list[1].mar_info.admin_dt_tm_order = cmf.admin_dt_tm_order, reply->
      chart_group_list[1].mar_info.admin_details_order = cmf.admin_details_order,
      reply->chart_group_list[1].mar_info.admin_by_order = cmf.admin_by_order, reply->
      chart_group_list[1].mar_info.primary_mnemonic_lbl = cmf.primary_mnemonic_lbl, reply->
      chart_group_list[1].mar_info.order_details_lbl = cmf.order_details_lbl,
      reply->chart_group_list[1].mar_info.admin_dt_tm_lbl = cmf.admin_dt_tm_lbl, reply->
      chart_group_list[1].mar_info.admin_details_lbl = cmf.admin_details_lbl, reply->
      chart_group_list[1].mar_info.admin_by_lbl = cmf.admin_by_lbl,
      reply->chart_group_list[1].mar_info.date_mask = cmf.date_mask, reply->chart_group_list[1].
      mar_info.time_mask = cmf.time_mask
     WITH nocounter
    ;end select
    CALL error_and_zero_check(curqual,"CHART_MAR_FORMAT","GETSECTIONSPECIFICINFO",1,1)
   OF name_hist_section_type:
    SELECT INTO "nl:"
     FROM chart_name_hist_format cnhf
     PLAN (cnhf
      WHERE (cnhf.chart_group_id=reply->chart_group_list[1].chart_group_id))
     DETAIL
      reply->chart_group_list[1].name_hist_info.order_seq_ind = cnhf.order_seq_ind, reply->
      chart_group_list[1].name_hist_info.name_lbl = cnhf.name_lbl, reply->chart_group_list[1].
      name_hist_info.name_odr = cnhf.name_odr,
      reply->chart_group_list[1].name_hist_info.beg_effective_dt_tm_lbl = cnhf
      .beg_effective_dt_tm_lbl, reply->chart_group_list[1].name_hist_info.beg_effective_dt_tm_odr =
      cnhf.beg_effective_dt_tm_odr, reply->chart_group_list[1].name_hist_info.end_effective_dt_tm_lbl
       = cnhf.end_effective_dt_tm_lbl,
      reply->chart_group_list[1].name_hist_info.end_effective_dt_tm_odr = cnhf
      .end_effective_dt_tm_odr
     WITH nocounter
    ;end select
    CALL error_and_zero_check(curqual,"CHART_NAME_HIST_FORMAT","GETSECTIONSPECIFICINFO",1,1)
   OF immun_section_type:
    SELECT INTO "nl:"
     FROM chart_immuniz_format cif
     PLAN (cif
      WHERE (cif.chart_group_id=reply->chart_group_list[1].chart_group_id))
     DETAIL
      reply->chart_group_list[1].immun_info.result_seq_ind = cif.result_seq_ind, reply->
      chart_group_list[1].immun_info.admin_note_chk = cif.admin_note_ind, reply->chart_group_list[1].
      immun_info.amount_chk = cif.amount_ind,
      reply->chart_group_list[1].immun_info.date_given_chk = cif.date_given_ind, reply->
      chart_group_list[1].immun_info.exp_dt_chk = cif.exp_dt_ind, reply->chart_group_list[1].
      immun_info.exp_tm_chk = cif.exp_tm_ind,
      reply->chart_group_list[1].immun_info.lot_num_chk = cif.lot_num_ind, reply->chart_group_list[1]
      .immun_info.manufact_chk = cif.manufact_ind, reply->chart_group_list[1].immun_info.provider_chk
       = cif.provider_ind,
      reply->chart_group_list[1].immun_info.site_chk = cif.site_ind, reply->chart_group_list[1].
      immun_info.time_given_chk = cif.time_given_ind, reply->chart_group_list[1].immun_info.
      admin_person_lbl = cif.admin_person_lbl,
      reply->chart_group_list[1].immun_info.amount_lbl = cif.amount_lbl, reply->chart_group_list[1].
      immun_info.date_given_lbl = cif.date_given_lbl, reply->chart_group_list[1].immun_info.
      exp_dt_lbl = cif.exp_dt_lbl,
      reply->chart_group_list[1].immun_info.lot_num_lbl = cif.lot_num_lbl, reply->chart_group_list[1]
      .immun_info.manufact_lbl = cif.manufact_lbl, reply->chart_group_list[1].immun_info.provider_lbl
       = cif.provider_lbl,
      reply->chart_group_list[1].immun_info.site_lbl = cif.site_lbl, reply->chart_group_list[1].
      immun_info.vaccine_lbl = cif.vaccine_lbl, reply->chart_group_list[1].immun_info.date_mask = cif
      .date_mask,
      reply->chart_group_list[1].immun_info.time_mask = cif.time_mask
     WITH nocounter
    ;end select
    CALL error_and_zero_check(curqual,"CHART_IMMUNIZ_FORMAT","GETSECTIONSPECIFICINFO",1,1)
   OF proc_hist_section_type:
    SELECT INTO "nl:"
     FROM chart_prochist_format cpf
     PLAN (cpf
      WHERE (cpf.chart_group_id=reply->chart_group_list[1].chart_group_id))
     DETAIL
      reply->chart_group_list[1].proc_hist_info.proc_lbl = cpf.proc_lbl, reply->chart_group_list[1].
      proc_hist_info.proc_ord = cpf.proc_ord, reply->chart_group_list[1].proc_hist_info.status_lbl =
      cpf.status_lbl,
      reply->chart_group_list[1].proc_hist_info.status_ord = cpf.status_ord, reply->chart_group_list[
      1].proc_hist_info.date_lbl = cpf.date_lbl, reply->chart_group_list[1].proc_hist_info.date_ord
       = cpf.date_ord,
      reply->chart_group_list[1].proc_hist_info.provider_lbl = cpf.provider_lbl, reply->
      chart_group_list[1].proc_hist_info.provider_ord = cpf.provider_ord, reply->chart_group_list[1].
      proc_hist_info.location_lbl = cpf.location_lbl,
      reply->chart_group_list[1].proc_hist_info.location_ord = cpf.location_ord
     WITH nocounter
    ;end select
    CALL error_and_zero_check(curqual,"CHART_PROCHIST_FORMAT","GETSECTIONSPECIFICINFO",1,1)
   OF mar2_section_type:
    SELECT INTO "nl:"
     FROM chart_mar_format cmf
     PLAN (cmf
      WHERE (cmf.chart_group_id=reply->chart_group_list[1].chart_group_id))
     DETAIL
      reply->chart_group_list[1].mar2_info.include_img_foot_ind = cmf.include_img_footer_ind, reply->
      chart_group_list[1].mar2_info.include_img_head_ind = cmf.include_img_header_ind
     WITH nocounter
    ;end select
    CALL error_and_zero_check(curqual,"NEW_CHART_MAR_FORMAT","GETSECTIONSPECIFICINFO",1,1)
   OF io_section_type:
    SELECT INTO "nl:"
     FROM chart_generic_format cgf,
      long_text_reference ltr
     PLAN (cgf
      WHERE (cgf.chart_group_id=reply->chart_group_list[1].chart_group_id))
      JOIN (ltr
      WHERE cgf.param_long_text_id=ltr.long_text_id)
     DETAIL
      reply->chart_group_list[1].io_info.include_img_foot_ind = cgf.include_img_footer_ind, reply->
      chart_group_list[1].io_info.include_img_head_ind = cgf.include_img_header_ind, reply->
      chart_group_list[1].io_info.long_text = ltr.long_text
     WITH nocounter
    ;end select
    CALL error_and_zero_check(curqual,"IO_CHART_GENERIC_FORMAT","GETSECTIONSPECIFICINFO",1,1)
   OF med_prof_hist_section_type:
    SELECT INTO "nl:"
     FROM chart_generic_format cgf
     WHERE (cgf.chart_group_id=reply->chart_group_list[1].chart_group_id)
     DETAIL
      reply->chart_group_list[1].mph_info.include_img_foot_ind = cgf.include_img_footer_ind, reply->
      chart_group_list[1].mph_info.include_img_head_ind = cgf.include_img_header_ind
     WITH nocounter
    ;end select
    CALL error_and_zero_check(curqual,"MPH_CHART_GENERIC_FORMAT","GETSECTIONSPECIFICINFO",1,1)
   OF user_defined_section_type:
    SELECT INTO "nl:"
     FROM chart_generic_format cgf,
      chart_discern_request cdr
     PLAN (cgf
      WHERE (cgf.chart_group_id=reply->chart_group_list[1].chart_group_id))
      JOIN (cdr
      WHERE cgf.chart_discern_request_id=cdr.chart_discern_request_id)
     DETAIL
      reply->chart_group_list[1].discern_report_info.include_img_foot_ind = cgf
      .include_img_footer_ind, reply->chart_group_list[1].discern_report_info.include_img_head_ind =
      cgf.include_img_header_ind, reply->chart_group_list[1].discern_report_info.
      chart_discern_request_id = cdr.chart_discern_request_id,
      reply->chart_group_list[1].discern_report_info.request_number = cdr.request_number, reply->
      chart_group_list[1].discern_report_info.process_flag = cdr.process_flag, reply->
      chart_group_list[1].discern_report_info.display = cdr.display_text,
      reply->chart_group_list[1].discern_report_info.scope_bit_map = cdr.scope_bit_map, reply->
      chart_group_list[1].discern_report_info.active_ind = cdr.active_ind
     WITH nocounter
    ;end select
    CALL error_and_zero_check(curqual,"UD_CHART_GENERIC_FORMAT","GETSECTIONSPECIFICINFO",1,1)
  ENDCASE
 END ;Subroutine
 SUBROUTINE getsectionfields(null)
   CALL log_message("In GetSectionFields()",log_level_debug)
   SELECT INTO "nl:"
    FROM chart_sect_flds csf
    WHERE (csf.chart_section_id=request->chart_section_id)
    ORDER BY csf.field_seq
    HEAD REPORT
     fldcount = 0
    DETAIL
     fldcount = (fldcount+ 1)
     IF (mod(fldcount,10)=1)
      stat = alterlist(reply->sect_field_list,(fldcount+ 9))
     ENDIF
     reply->sect_field_list[fldcount].field_id = csf.field_id, reply->sect_field_list[fldcount].
     field_row = csf.field_row
    FOOT REPORT
     stat = alterlist(reply->sect_field_list,fldcount)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_SECT_FLDS","GETSECTIONFIELDS",1,0)
 END ;Subroutine
#exit_script
 CALL log_message("Exiting script: cp_load_chart_section",log_level_debug)
END GO
