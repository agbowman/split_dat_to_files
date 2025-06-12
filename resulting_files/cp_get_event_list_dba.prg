CREATE PROGRAM cp_get_event_list:dba
 DECLARE uar_fmt_accession(p1,p2) = c25
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
 SET log_program_name = "CP_GET_EVENT_LIST"
 FREE RECORD temp_request
 RECORD temp_request(
   1 debug_ind = i2
   1 qual[*]
     2 encntr_id = f8
     2 resource_cd = f8
 )
 FREE RECORD temp_reply
 RECORD temp_reply(
   1 qual[*]
     2 resource_cd = f8
     2 ref_lab_description = vc
     2 encntr_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD reply(
   1 rb_list[1]
     2 order_list[*]
       3 order_id = f8
       3 long_text = gc32000
       3 order_mnemonic = vc
       3 comment_dt_tm = dq8
       3 comment_tz = i4
     2 ap_blob_cnt = i2
     2 code_list[*]
       3 cp_entry = i2
       3 cep_entry = i2
       3 cen_entry = i2
       3 cbr_entry = i2
       3 ccr_entry = i2
       3 cdr_entry = i2
       3 cbs_entry = i2
       3 csr_entry = i2
       3 cdl_entry = i2
       3 csc_entry = i2
       3 event_list[*]
         4 encntr_id = f8
         4 event_id = f8
         4 order_id = f8
         4 accession_nbr = vc
         4 frmt_accession_nbr = vc
         4 clinical_event_id = f8
         4 parent_event_id = f8
         4 valid_from_dt_tm = dq8
         4 valid_until_dt_tm = dq8
         4 view_level = i4
         4 event_cd = f8
         4 event_cd_disp = vc
         4 catalog_cd = f8
         4 event_end_dt_tm = dq8
         4 event_end_tz = i4
         4 cp_entry = i2
         4 cep_entry = i2
         4 cen_entry = i2
         4 cbr_entry = i2
         4 ccr_entry = i2
         4 cdr_entry = i2
         4 cbs_entry = i2
         4 csr_entry = i2
         4 cdl_entry = i2
         4 csc_entry = i2
         4 resource_cd = f8
         4 subtable_bit_map = i4
         4 collating_seq = c40
         4 event_title_text = vc
         4 result_status_cd = f8
         4 result_status_cd_disp = vc
         4 normalcy_cd = f8
         4 normalcy_cd_disp = vc
         4 result_val = vc
         4 result_units_cd = f8
         4 result_units_cd_disp = vc
         4 task_assay_cd = f8
         4 verified_dt_tm = dq8
         4 verified_tz = i4
         4 verified_prsnl_id = f8
         4 performed_prsnl_id = f8
         4 perf_sign = vc
         4 perf_username = vc
         4 ver_sign = vc
         4 ver_username = vc
         4 normal_high = vc
         4 normal_low = vc
         4 ref_lab_ind = i2
         4 ref_lab_desc = vc
         4 has_endorse_comment = i2
         4 event_class_cd = f8
         4 mdoc_incomplete = i2
         4 product[*]
           5 product_nbr = vc
           5 product_cd = f8
           5 product_status_cd = f8
           5 product_status_cd_disp = vc
           5 aborh_cd = f8
         4 event_note_list[*]
           5 note_type_cd = f8
           5 note_type_cd_disp = vc
           5 note_type_cd_mean = vc
           5 note_format_cd = f8
           5 note_format_cd_disp = vc
           5 note_format_cd_mean = vc
           5 note_dt_tm = dq8
           5 note_tz = i4
           5 blob_length = i4
           5 long_blob = gc32000
         4 event_prsnl_list[*]
           5 action_type_cd = f8
           5 action_type_cd_disp = vc
           5 action_type_cd_mean = vc
           5 action_dt_tm = dq8
           5 action_tz = i4
           5 action_prsnl_id = f8
           5 action_comment = vc
         4 blob_result[*]
           5 format_cd = f8
           5 format_cd_disp = vc
           5 format_cd_mean = vc
           5 storage_cd = f8
           5 blob_handle = vc
           5 blob_length = i4
           5 is_compressed = i2
           5 blob[*]
             6 blob_seq_num = i4
             6 blob_contents = vc
             6 blob_contents_as_bytes = vgc
           5 event_id = f8
         4 date_result_list[*]
           5 result_dt_tm = dq8
           5 result_tz = i4
           5 result_tz_ind = i2
           5 result_dt_tm_os = f8
           5 date_type_flag = i2
         4 linked_result[*]
           5 event_id = f8
           5 linked_event_id = f8
         4 coded_result_list[*]
           5 short_string = c60
           5 source_identifier = vc
           5 source_string = vc
           5 mnemonic = vc
         4 blob_summary_list[*]
           5 blob_length = i4
           5 long_blob = vgc
           5 format_cd = f8
           5 format_cd_disp = vc
           5 format_cd_mean = vc
         4 child_event_list[*]
         4 attachment_list[*]
           5 event_id = f8
           5 result_status_cd = f8
           5 result_status_cd_disp = vc
           5 result_status_cd_mean = vc
           5 event_title_text = vc
           5 event_end_dt_tm = dq8
           5 event_end_tz = i4
         4 string_result_list[*]
           5 string_long_text_id = f8
           5 string_result_text = vc
         4 nomen_string_flag = i2
         4 dynamic_label_id = f8
         4 dynamic_label_name = vc
         4 label_seq_nbr = i2
         4 listview_info[*]
           5 received_dt_tm = dq8
           5 received_tz = i4
           5 specimen_type = vc
         4 performed_dt_tm = dq8
         4 performed_tz = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD ec_oc_flat_rec
 RECORD ec_oc_flat_rec(
   1 qual[*]
     2 seq = i4
     2 procedure_type_flag = i2
     2 event_set_cd = f8
     2 catalog_cd = f8
     2 event_cd = f8
 )
 FREE SET temp_events
 RECORD temp_events(
   1 qual[*]
     2 event_id = f8
     2 catalog_cd = f8
     2 event_cd = f8
     2 dontcare = i2
     2 ecg_ind = i2
 )
 FREE RECORD attachment_flat_rec
 RECORD attachment_flat_rec(
   1 rec_size = i4
   1 qual[*]
     2 event_id = f8
     2 code_list = i4
     2 event_list = i4
 )
 FREE RECORD cp_entry_flat_rec
 RECORD cp_entry_flat_rec(
   1 rec_size = i4
   1 qual[*]
     2 event_id = f8
     2 code_list = i4
     2 event_list = i4
 )
 FREE RECORD cep_entry_flat_rec
 RECORD cep_entry_flat_rec(
   1 rec_size = i4
   1 qual[*]
     2 event_id = f8
     2 code_list = i4
     2 event_list = i4
 )
 FREE RECORD cen_entry_flat_rec
 RECORD cen_entry_flat_rec(
   1 rec_size = i4
   1 qual[*]
     2 event_id = f8
     2 code_list = i4
     2 event_list = i4
 )
 FREE RECORD cbr_entry_flat_rec
 RECORD cbr_entry_flat_rec(
   1 rec_size = i4
   1 qual[*]
     2 event_id = f8
     2 code_list = i4
     2 event_list = i4
 )
 FREE RECORD ccr_entry_flat_rec
 RECORD ccr_entry_flat_rec(
   1 rec_size = i4
   1 qual[*]
     2 event_id = f8
     2 code_list = i4
     2 event_list = i4
 )
 FREE RECORD cdr_entry_flat_rec
 RECORD cdr_entry_flat_rec(
   1 rec_size = i4
   1 qual[*]
     2 event_id = f8
     2 code_list = i4
     2 event_list = i4
 )
 FREE RECORD cbs_entry_flat_rec
 RECORD cbs_entry_flat_rec(
   1 rec_size = i4
   1 qual[*]
     2 event_id = f8
     2 code_list = i4
     2 event_list = i4
 )
 FREE RECORD csr_entry_flat_rec
 RECORD csr_entry_flat_rec(
   1 rec_size = i4
   1 qual[*]
     2 event_id = f8
     2 code_list = i4
     2 event_list = i4
 )
 FREE RECORD cdl_entry_flat_rec
 RECORD cdl_entry_flat_rec(
   1 rec_size = i4
   1 qual[*]
     2 ce_dynamic_label_id = f8
     2 code_list = i4
     2 event_list = i4
 )
 FREE RECORD order_comment_flat_rec
 RECORD order_comment_flat_rec(
   1 rec_size = i4
   1 qual[*]
     2 order_id = f8
     2 comment_dt_tm = dq8
     2 comment_tz = i4
 )
 FREE RECORD csc_entry_flat_rec
 RECORD csc_entry_flat_rec(
   1 rec_size = i4
   1 qual[*]
     2 event_id = f8
     2 code_list = i4
     2 event_list = i4
 )
 FREE RECORD final_events
 RECORD final_events(
   1 qual[*]
     2 event_id = f8
     2 catalog_cd = f8
     2 event_cd = f8
     2 dontcare = i2
     2 code = f8
     2 seq = i4
 )
 DECLARE ocfcomp_cd = f8 WITH constant(uar_get_code_by("MEANING",120,"OCFCOMP")), protect
 DECLARE ordcomm_cd = f8 WITH constant(uar_get_code_by("MEANING",14,"ORD COMMENT")), protect
 DECLARE ascii_cd = f8 WITH constant(uar_get_code_by("MEANING",23,"AH")), protect
 DECLARE rtf_cd = f8 WITH constant(uar_get_code_by("MEANING",23,"RTF")), protect
 DECLARE endorse_cd = f8 WITH constant(uar_get_code_by("MEANING",21,"ENDORSE")), protect
 DECLARE otg_storage_cd = f8 WITH constant(uar_get_code_by("MEANING",25,"OTG")), protect
 DECLARE acrnema_frmt_cd = f8 WITH constant(uar_get_code_by("MEANING",23,"ACRNEMA")), protect
 DECLARE dicom_storage_cd = f8 WITH constant(uar_get_code_by("MEANING",25,"DICOM_SIUID")), protect
 DECLARE v_until_dt = q8 WITH constant(cnvtdatetime("31-DEC-2100 00:00:00.00")), protect
 DECLARE bind_cnt = i4 WITH constant(50)
 DECLARE flex_section_type = i4 WITH constant(6)
 DECLARE horz_section_type = i4 WITH constant(9)
 DECLARE rad_section_type = i4 WITH constant(14)
 DECLARE vert_section_type = i4 WITH constant(16)
 DECLARE zonal_section_type = i4 WITH constant(17)
 DECLARE ap_section_type = i4 WITH constant(18)
 DECLARE doc_section_type = i4 WITH constant(25)
 DECLARE gltxt_section_type = i4 WITH constant(27)
 DECLARE dynzonal_section_type = i4 WITH constant(32)
 DECLARE listview_section_type = i4 WITH constant(45)
 DECLARE verified_only = i4 WITH constant(0)
 DECLARE verified_performed = i4 WITH constant(1)
 DECLARE verified_pending = i4 WITH constant(2)
 DECLARE event_procedure_type = i2 WITH constant(0)
 DECLARE order_procedure_type = i2 WITH constant(1)
 DECLARE bitmap_ce_event_prsnl = i4 WITH constant(0)
 DECLARE bitmap_ce_event_note = i4 WITH constant(1)
 DECLARE bitmap_ce_specimen_coll = i4 WITH constant(4)
 DECLARE bitmap_ce_blob_result = i4 WITH constant(8)
 DECLARE bitmap_ce_blob_summary = i4 WITH constant(11)
 DECLARE bitmap_ce_coded_result = i4 WITH constant(15)
 DECLARE bitmap_ce_product = i4 WITH constant(20)
 DECLARE bitmap_ce_date_result = i4 WITH constant(22)
 DECLARE bitmap_ce_string_result = i4 WITH constant(13)
 DECLARE bitmap_ce_dynamic_label = i4 WITH constant(18)
 DECLARE max_event_list = i2 WITH noconstant(0), protect
 DECLARE cp_entry_skip = i2 WITH noconstant(0), protect
 DECLARE cep_entry_skip = i2 WITH noconstant(0), protect
 DECLARE cen_entry_skip = i2 WITH noconstant(0), protect
 DECLARE cbr_entry_skip = i2 WITH noconstant(0), protect
 DECLARE ccr_entry_skip = i2 WITH noconstant(0), protect
 DECLARE cdr_entry_skip = i2 WITH noconstant(0), protect
 DECLARE cbs_entry_skip = i2 WITH noconstant(0), protect
 DECLARE csr_entry_skip = i2 WITH noconstant(0), protect
 DECLARE cdl_entry_skip = i2 WITH noconstant(0), protect
 DECLARE csc_entry_skip = i2 WITH noconstant(0), protect
 DECLARE parent_cp_entry_skip = i2 WITH noconstant(0), protect
 DECLARE parent_cep_entry_skip = i2 WITH noconstant(0), protect
 DECLARE parent_cen_entry_skip = i2 WITH noconstant(0), protect
 DECLARE parent_cbr_entry_skip = i2 WITH noconstant(0), protect
 DECLARE parent_ccr_entry_skip = i2 WITH noconstant(0), protect
 DECLARE parent_cdr_entry_skip = i2 WITH noconstant(0), protect
 DECLARE parent_cbs_entry_skip = i2 WITH noconstant(0), protect
 DECLARE parent_csr_entry_skip = i2 WITH noconstant(0), protect
 DECLARE parent_cdl_entry_skip = i2 WITH noconstant(0), protect
 DECLARE parent_csc_entry_skip = i2 WITH noconstant(0), protect
 DECLARE encntr_loc_fac_cd = f8 WITH noconstant(0.0), protect
 DECLARE encntr_loc_org_id = f8 WITH noconstant(0.0), protect
 DECLARE x = i4 WITH noconstant(0), protect
 DECLARE y = i4 WITH noconstant(0), protect
 DECLARE z = i4 WITH noconstant(0), protect
 DECLARE xmax = i4 WITH noconstant(0), protect
 DECLARE ymax = i4 WITH noconstant(0), protect
 DECLARE tempeventcnt = i4 WITH noconstant(0), protect
 DECLARE where_clause = vc WITH noconstant(""), protect
 DECLARE person_clause = vc WITH noconstant(""), protect
 DECLARE date_clause = vc WITH noconstant(""), protect
 DECLARE date_clause1 = vc WITH noconstant(""), protect
 DECLARE date_clause2 = vc WITH noconstant(""), protect
 DECLARE other_clause = vc WITH noconstant(""), protect
 DECLARE result_clause = vc WITH noconstant(""), protect
 DECLARE filter_clause = vc WITH noconstant(""), protect
 DECLARE selected_events = i2 WITH noconstant(0), protect
 DECLARE c1 = vc WITH noconstant(""), protect
 DECLARE c2 = vc WITH noconstant(""), protect
 DECLARE c3 = vc WITH noconstant(""), protect
 DECLARE c4 = vc WITH noconstant(""), protect
 DECLARE c5 = vc WITH noconstant(""), protect
 DECLARE encntr_level_doc = i2 WITH constant(1)
 DECLARE patient_level_doc = i2 WITH constant(2)
 DECLARE event_level_doc = i2 WITH constant(6)
 DECLARE idx = i4
 DECLARE idx2 = i4
 DECLARE idx3 = i4
 DECLARE idxstart = i4 WITH noconstant(1)
 DECLARE noptimizedtotal = i4
 DECLARE nrecordsize = i4
 DECLARE auth_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"AUTH")), protect
 DECLARE unauth_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"UNAUTH")), protect
 DECLARE mod_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"MODIFIED")), protect
 DECLARE alt_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"ALTERED")), protect
 DECLARE super_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"SUPERSEDED")), protect
 DECLARE inlab_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"IN LAB")), protect
 DECLARE inprog_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"IN PROGRESS")), protect
 DECLARE trans_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"TRANSCRIBED")), protect
 DECLARE inerror1_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"INERROR")), protect
 DECLARE inerror2_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"IN ERROR")), protect
 DECLARE inerrornomut_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"INERRNOMUT")), protect
 DECLARE inerrornoview_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"INERRNOVIEW")), protect
 DECLARE cancelled_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"CANCELLED")), protect
 DECLARE rejected_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"REJECTED")), protect
 DECLARE del_stat_cd = f8 WITH constant(uar_get_code_by("MEANING",48,"DELETED")), protect
 DECLARE csm_request_viewer_task = i4 WITH constant(1030024), protect
 DECLARE mdoc_class_cd = f8 WITH constant(uar_get_code_by("MEANING",53,"MDOC")), protect
 DECLARE doc_class_cd = f8 WITH constant(uar_get_code_by("MEANING",53,"DOC")), protect
 DECLARE grp_class_cd = f8 WITH constant(uar_get_code_by("MEANING",53,"GRP")), protect
 DECLARE placehold_class_cd = f8 WITH constant(uar_get_code_by("MEANING",53,"PLACEHOLDER")), protect
 DECLARE attach_class_cd = f8 WITH constant(uar_get_code_by("MEANING",53,"ATTACHMENT")), protect
 DECLARE proc_class_cd = f8 WITH constant(uar_get_code_by("MEANING",53,"PROCEDURE")), protect
 DECLARE flatteneventsetorderablerecords(null) = null
 DECLARE buildpersonclause(null) = null
 DECLARE builddateclause(null) = null
 DECLARE buildotherclause(null) = null
 DECLARE buildwhereclause(null) = null
 DECLARE getprelimevents(null) = null
 DECLARE getvalidevents(null) = null
 DECLARE getattachments(null) = null
 DECLARE getceeventprsnl(null) = null
 DECLARE getceblobresult(null) = null
 DECLARE getcecodedresult(null) = null
 DECLARE getceblobresult(null) = null
 DECLARE getceproduct(null) = null
 DECLARE getceblobsummary(null) = null
 DECLARE getordercomments(null) = null
 DECLARE getcedateresult(null) = null
 DECLARE getfinalevents(null) = null
 DECLARE getcestringresult(null) = null
 DECLARE getcedynamiclabel(null) = null
 DECLARE getcespecimencollforlistview(null) = null
 DECLARE getecgevents(null) = null
 CALL log_message("Starting script: cp_get_event_list",log_level_debug)
 SET reply->status_data.status = "F"
 CALL flatteneventsetorderablerecords(null)
 CALL buildwhereclause(null)
 CALL log_message(concat("where_clause = ",trim(where_clause)),log_level_debug)
 CALL getprelimevents(null)
 CALL getvalidevents(null)
 SET reply->status_data.status = "S"
 SUBROUTINE flatteneventsetorderablerecords(null)
   CALL log_message("In FlattenEventSetOrderableRecords()",log_level_debug)
   DECLARE x_cnt = i4 WITH noconstant(0), protect
   DECLARE y_cnt = i4 WITH noconstant(0), protect
   DECLARE cnt = i4 WITH noconstant(0), protect
   FOR (x_cnt = 1 TO size(request->code_list,5))
     FOR (y_cnt = 1 TO size(request->code_list[x_cnt].event_cd_list,5))
       SET cnt += 1
       IF (cnt > size(ec_oc_flat_rec->qual,5))
        SET stat = alterlist(ec_oc_flat_rec->qual,((cnt+ bind_cnt) - 1))
       ENDIF
       IF ((request->code_list[x_cnt].procedure_type_flag=event_procedure_type))
        SET ec_oc_flat_rec->qual[cnt].event_set_cd = request->code_list[x_cnt].code
       ELSE
        SET ec_oc_flat_rec->qual[cnt].catalog_cd = request->code_list[x_cnt].code
       ENDIF
       SET ec_oc_flat_rec->qual[cnt].event_cd = request->code_list[x_cnt].event_cd_list[y_cnt].
       event_cd
       SET ec_oc_flat_rec->qual[cnt].seq = x_cnt
       SET ec_oc_flat_rec->qual[cnt].procedure_type_flag = request->code_list[x_cnt].
       procedure_type_flag
     ENDFOR
   ENDFOR
   SET stat = alterlist(ec_oc_flat_rec->qual,cnt)
 END ;Subroutine
 SUBROUTINE buildwhereclause(null)
   CALL builddateclause(null)
   CALL buildpersonclause(null)
   CALL buildotherclause(null)
   SET where_clause = concat(trim(person_clause)," and ",trim(date_clause)," and ",trim(other_clause)
    )
 END ;Subroutine
 SUBROUTINE buildpersonclause(null)
   CALL log_message("In BuildPersonClause()",log_level_debug)
   IF ((request->section_type_flag=doc_section_type)
    AND (request->doc_type=encntr_level_doc)
    AND (request->scope_flag=1))
    SET c1 = build("ce.person_id = ",request->person_id," and ce.encntr_id+0 > 0.0")
   ELSEIF ((request->section_type_flag=doc_section_type)
    AND (request->doc_type=patient_level_doc))
    IF ((request->scope_flag=event_level_doc))
     SET c1 = build("ce.person_id+0 = ",request->person_id)
     SET c2 = build("  and ce.event_id in (select event_id from chart_request_event where",
      " chart_request_id = request->request_id)")
    ELSE
     SET c1 = build("ce.person_id = ",request->person_id," and ce.encntr_id+0 = 0.0")
    ENDIF
   ELSEIF ((request->scope_flag=event_level_doc)
    AND (request->section_type_flag=doc_section_type)
    AND (request->doc_type=encntr_level_doc))
    SET c1 = build("ce.person_id+0 = ",request->person_id," and ce.encntr_id+0 > 0.0")
    SET c2 = build("  and ce.event_id in (select event_id from chart_request_event where",
     " chart_request_id = request->request_id)")
   ELSE
    CASE (request->scope_flag)
     OF 1:
      SET c1 = build("ce.person_id = ",request->person_id)
     OF 2:
      SET c1 = build("ce.person_id= ",request->person_id)
      SET c2 = build("and ce.encntr_id = ",request->encntr_id)
     OF 3:
      SET c1 = build("ce.person_id+0 = ",request->person_id)
      SET c2 = build("and ce.encntr_id+0 = ",request->encntr_id)
      SET c3 =
      "and ce.order_id in (select order_id from chart_request_order where chart_request_id = request->request_id)"
     OF 4:
      SET c1 = build("ce.person_id+0 = ",request->person_id)
      SET c2 = build("and ce.encntr_id+0 = ",request->encntr_id)
      SET c3 = build("and ce.accession_nbr = ","request->accession_nbr")
     OF 5:
      SET c1 = build("ce.person_id = ",request->person_id)
      SET c2 =
      " and ce.encntr_id in (select encntr_id from chart_request_encntr where chart_request_id=request->request_id)"
     OF 6:
      SET c1 = build("ce.person_id+0 = ",request->person_id)
      SET c2 = build("  and ce.event_id in (select event_id from chart_request_event where",
       " chart_request_id = request->request_id)")
      SET selected_events = 1
    ENDCASE
   ENDIF
   IF ((request->scope_flag != 6)
    AND (request->chart_section_id > 0)
    AND (request->event_ind=1))
    SELECT INTO "nl:"
     FROM chart_request_section
     WHERE (chart_request_id=request->request_id)
      AND (chart_section_id=request->chart_section_id)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET c4 =
     " and ce.event_id in (select event_id from chart_request_event where chart_request_id = request->request_id)"
     SET selected_events = 1
    ENDIF
   ENDIF
   SET person_clause = concat(trim(c1)," ",trim(c2)," ",trim(c3),
    " ",trim(c4))
 END ;Subroutine
 SUBROUTINE builddateclause(null)
   CALL log_message("In BuildDateClause()",log_level_debug)
   DECLARE s_date = vc
   DECLARE e_date = vc
   IF ((request->date_range_ind=1))
    IF ((request->begin_dt_tm > 0))
     SET s_date = "cnvtdatetime(request->begin_dt_tm)"
    ELSE
     SET s_date = "cnvtdatetime('01-JAN-1800 00:00:00.00')"
    ENDIF
    IF ((request->end_dt_tm > 0))
     SET e_date = "cnvtdatetime(request->end_dt_tm)"
    ELSE
     SET e_date = "cnvtdatetime('31-DEC-2100 23:59:59.99')"
    ENDIF
    IF ((request->request_type=2)
     AND (request->mcis_ind=0))
     SET date_clause = concat(" (ce.verified_dt_tm between ",s_date," and ",e_date)
     IF ((((request->pending_flag=1)) OR ((request->pending_flag=2))) )
      SET date_clause = concat(date_clause," or ce.performed_dt_tm between ",s_date," and ",e_date)
     ENDIF
     IF ((request->pending_flag=2))
      SET date_clause = concat(date_clause," or ce.event_end_dt_tm between ",s_date," and ",e_date)
     ENDIF
     SET date_clause = concat(date_clause,")")
    ELSE
     IF ((request->result_lookup_ind=1))
      SET date_clause = concat(" (ce.event_end_dt_tm+0 between ",s_date," and ",e_date,")")
     ELSE
      SET date_clause = concat(" (ce.clinsig_updt_dt_tm+0 between ",s_date," and ",e_date,")")
     ENDIF
    ENDIF
   ELSE
    SET date_clause = "1=1"
   ENDIF
 END ;Subroutine
 SUBROUTINE buildotherclause(null)
   CALL log_message("In BuildOtherClause()",log_level_debug)
   CASE (request->section_type_flag)
    OF horz_section_type:
    OF vert_section_type:
    OF zonal_section_type:
    OF gltxt_section_type:
    OF dynzonal_section_type:
    OF listview_section_type:
     SET other_clause = " ce.view_level = 1 and ce.publish_flag = 1"
    OF flex_section_type:
     IF ((request->flex_type_flag=0))
      SET other_clause = " ce.view_level = 0 and ce.publish_flag = 1"
     ELSE
      SET other_clause = " ce.view_level = 1 and ce.publish_flag = 1"
     ENDIF
    OF rad_section_type:
     SET other_clause = " ce.view_level = 1 and ce.publish_flag = 1"
    OF ap_section_type:
     IF ((request->pending_flag=0))
      SET other_clause = " ce.view_level = 0 and ce.publish_flag = 1"
     ELSE
      SET other_clause = " ce.view_level = 0 and ce.publish_flag > 0"
     ENDIF
    OF doc_section_type:
     SET other_clause = " ce.event_class_cd in (mdoc_class_cd, doc_class_cd, grp_class_cd)"
     SET other_clause = concat(other_clause," and ce.publish_flag = 1")
   ENDCASE
   SET result_clause = " ce.result_status_cd in "
   CASE (request->pending_flag)
    OF verified_only:
     SET result_clause = concat(result_clause,"(auth_cd, mod_cd, super_cd, alt_cd)")
    OF verified_performed:
     SET result_clause = concat(result_clause,
      "(auth_cd, mod_cd, super_cd, alt_cd, inlab_cd, inprog_cd)")
    ELSE
     SET result_clause = concat(result_clause,
      "(auth_cd, mod_cd, super_cd, alt_cd, inlab_cd, inprog_cd, trans_cd, unauth_cd)")
   ENDCASE
   SET result_clause = concat(result_clause,
    " and ce.event_class_cd != placehold_class_cd and ce.record_status_cd != del_stat_cd")
   SET other_clause = concat(trim(other_clause)," and ",trim(result_clause))
 END ;Subroutine
 SUBROUTINE getprelimevents(null)
   CALL log_message("In GetPrelimEvents()",log_level_debug)
   FREE RECORD flat_rec
   RECORD flat_rec(
     1 qual[*]
       2 event_id = f8
   )
   SET idxstart = 1
   IF ((request->section_type_flag=doc_section_type))
    CALL echo("two")
    SELECT DISTINCT INTO "nl:"
     ce.parent_event_id, ce.event_id
     FROM clinical_event ce,
      clinical_event pce
     PLAN (ce
      WHERE parser(where_clause))
      JOIN (pce
      WHERE pce.event_id=ce.parent_event_id
       AND pce.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100")
       AND pce.event_class_cd != proc_class_cd)
     ORDER BY ce.parent_event_id, ce.event_id
     DETAIL
      tempeventcnt += 1
      IF (mod(tempeventcnt,15)=1)
       stat = alterlist(temp_events->qual,(tempeventcnt+ 14))
      ENDIF
      IF (mod(tempeventcnt,bind_cnt)=1)
       stat = alterlist(flat_rec->qual,(tempeventcnt+ (bind_cnt - 1)))
      ENDIF
      temp_events->qual[tempeventcnt].event_id = ce.event_id, temp_events->qual[tempeventcnt].
      catalog_cd = ce.catalog_cd, temp_events->qual[tempeventcnt].event_cd = ce.event_cd,
      temp_events->qual[tempeventcnt].dontcare = 0, flat_rec->qual[tempeventcnt].event_id = ce
      .event_id
     WITH nocounter
    ;end select
    CALL echo("three")
    CALL echorecord(temp_events)
    CALL echorecord(flat_rec)
   ELSE
    SELECT DISTINCT INTO "nl:"
     ce.parent_event_id, ce.event_id
     FROM clinical_event ce
     WHERE parser(where_clause)
     ORDER BY ce.parent_event_id, ce.event_id
     DETAIL
      tempeventcnt += 1
      IF (mod(tempeventcnt,15)=1)
       stat = alterlist(temp_events->qual,(tempeventcnt+ 14))
      ENDIF
      IF (mod(tempeventcnt,bind_cnt)=1)
       stat = alterlist(flat_rec->qual,(tempeventcnt+ (bind_cnt - 1)))
      ENDIF
      temp_events->qual[tempeventcnt].event_id = ce.event_id, temp_events->qual[tempeventcnt].
      catalog_cd = ce.catalog_cd, temp_events->qual[tempeventcnt].event_cd = ce.event_cd,
      temp_events->qual[tempeventcnt].dontcare = 0, flat_rec->qual[tempeventcnt].event_id = ce
      .event_id
     WITH nocounter
    ;end select
    CALL error_and_zero_check(curqual,"CLINICAL_EVENT","GETPRELIMEVENTS",1,1)
   ENDIF
   IF ((request->section_type_flag=doc_section_type))
    SET filter_clause = " ce.event_class_cd = doc_class_cd"
   ELSE
    SET filter_clause = " 1 = 1"
   ENDIF
   SET nrecordsize = tempeventcnt
   SET noptimizedtotal = (ceil((cnvtreal(nrecordsize)/ bind_cnt)) * bind_cnt)
   SET stat = alterlist(flat_rec->qual,noptimizedtotal)
   FOR (i = (nrecordsize+ 1) TO noptimizedtotal)
     SET flat_rec->qual[i].event_id = flat_rec->qual[nrecordsize].event_id
   ENDFOR
   IF (((selected_events=1) OR ((request->section_type_flag=doc_section_type))) )
    IF (size(flat_rec->qual,5) > 0)
     SELECT DISTINCT INTO "nl:"
      FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
       clinical_event ce1,
       clinical_event ce2
      PLAN (d
       WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
       JOIN (ce1
       WHERE expand(idx,idxstart,((idxstart+ bind_cnt) - 1),ce1.event_id,flat_rec->qual[idx].event_id,
        bind_cnt)
        AND ce1.parent_event_id=ce1.event_id
        AND ce1.event_class_cd IN (mdoc_class_cd, doc_class_cd, grp_class_cd))
       JOIN (ce2
       WHERE ce2.parent_event_id=ce1.event_id
        AND ce2.parent_event_id != ce2.event_id
        AND ce2.event_class_cd=doc_class_cd
        AND ce2.publish_flag=1
        AND ce2.valid_until_dt_tm >= cnvtdatetime(v_until_dt))
      ORDER BY ce1.event_id, ce2.event_id, ce2.event_cd
      DETAIL
       IF (locateval(idx2,1,noptimizedtotal,ce2.event_id,flat_rec->qual[idx2].event_id) > 0)
        do_nothing = 0
       ELSE
        tempeventcnt += 1
        IF (mod(tempeventcnt,15)=1)
         stat = alterlist(temp_events->qual,(tempeventcnt+ 14))
        ENDIF
        IF (mod(tempeventcnt,bind_cnt)=1)
         stat = alterlist(flat_rec->qual,(tempeventcnt+ (bind_cnt - 1)))
        ENDIF
        temp_events->qual[tempeventcnt].event_id = ce2.event_id, temp_events->qual[tempeventcnt].
        catalog_cd = ce2.catalog_cd, temp_events->qual[tempeventcnt].event_cd = ce2.event_cd,
        temp_events->qual[tempeventcnt].dontcare = 0, flat_rec->qual[tempeventcnt].event_id = ce2
        .event_id
       ENDIF
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   SET nrecordsize = tempeventcnt
   SET noptimizedtotal = (ceil((cnvtreal(nrecordsize)/ bind_cnt)) * bind_cnt)
   SET stat = alterlist(flat_rec->qual,noptimizedtotal)
   FOR (i = (nrecordsize+ 1) TO noptimizedtotal)
     SET flat_rec->qual[i].event_id = flat_rec->qual[nrecordsize].event_id
   ENDFOR
   SET stat = alterlist(temp_events->qual,tempeventcnt)
   SET idxstart = 1
   IF (size(flat_rec->qual,5) > 0)
    SELECT DISTINCT INTO "nl:"
     FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
      clinical_event cce,
      clinical_event ce
     PLAN (d
      WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
      JOIN (cce
      WHERE expand(idx,idxstart,((idxstart+ bind_cnt) - 1),cce.event_id,flat_rec->qual[idx].event_id,
       bind_cnt)
       AND cce.parent_event_id != 0)
      JOIN (ce
      WHERE ce.event_id=cce.parent_event_id
       AND ce.result_status_cd IN (inerror1_cd, inerror2_cd, inerrornomut_cd, inerrornoview_cd,
      rejected_cd,
      cancelled_cd)
       AND ce.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100"))
     DETAIL
      locval = locateval(idx2,1,tempeventcnt,ce.event_id,temp_events->qual[idx2].event_id)
      WHILE (locval != 0)
       temp_events->qual[locval].dontcare = 1,locval = locateval(idx2,(locval+ 1),tempeventcnt,ce
        .event_id,temp_events->qual[idx2].event_id)
      ENDWHILE
     WITH nocounter
    ;end select
   ENDIF
   IF ((request->section_type_flag=doc_section_type))
    CALL getecgevents(null)
   ENDIF
   CALL error_and_zero_check(curqual,"KILL_CLINICAL_EVENT","GETPRELIMEVENTS",1,0)
   FREE RECORD flat_rec
 END ;Subroutine
 SUBROUTINE getvalidevents(null)
   CALL log_message("In GetValidEvents()",log_level_debug)
   DECLARE locval_ec_oc = i4
   DECLARE x = i4 WITH noconstant(0), protect
   DECLARE y = i4 WITH noconstant(0), protect
   DECLARE z = i4 WITH noconstant(0), protect
   SET code_nbr = size(request->code_list,5)
   SET stat = alterlist(reply->rb_list[1].code_list,code_nbr)
   SET x1 = 0
   SET x2 = 0
   CALL getfinalevents(null)
   SET nrecordsize = size(final_events->qual,5)
   SET noptimizedtotal = (ceil((cnvtreal(nrecordsize)/ bind_cnt)) * bind_cnt)
   SET stat = alterlist(final_events->qual,noptimizedtotal)
   FOR (i = (nrecordsize+ 1) TO noptimizedtotal)
     SET final_events->qual[i].event_id = final_events->qual[nrecordsize].event_id
     SET final_events->qual[i].catalog_cd = final_events->qual[nrecordsize].catalog_cd
     SET final_events->qual[i].dontcare = final_events->qual[nrecordsize].dontcare
     SET final_events->qual[i].event_cd = final_events->qual[nrecordsize].event_cd
     SET final_events->qual[i].code = final_events->qual[nrecordsize].code
     SET final_events->qual[i].seq = final_events->qual[nrecordsize].seq
   ENDFOR
   SET idxstart = 1
   SELECT INTO "nl:"
    FROM (dummyt d3  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     clinical_event ce
    PLAN (d3
     WHERE initarray(idxstart,evaluate(d3.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (ce
     WHERE expand(idx,idxstart,((idxstart+ bind_cnt) - 1),ce.event_id,final_events->qual[idx].
      event_id,
      bind_cnt)
      AND parser(filter_clause)
      AND ce.valid_until_dt_tm >= cnvtdatetime(v_until_dt)
      AND parser(other_clause))
    ORDER BY ce.parent_event_id, ce.event_id, cnvtdatetime(ce.valid_until_dt_tm)
    HEAD d3.seq
     x1 = 0
    HEAD ce.parent_event_id
     do_nothing = 0
    HEAD ce.event_id
     do_nothing = 0, my_seq = 0
    DETAIL
     locval_ec_oc = locateval(idx2,1,size(ec_oc_flat_rec->qual,5),ce.event_cd,ec_oc_flat_rec->qual[
      idx2].event_cd)
     WHILE (locval_ec_oc != 0)
       parent_cp_entry_skip = 0, parent_cep_entry_skip = 0, parent_cen_entry_skip = 0,
       parent_cbr_entry_skip = 0, parent_ccr_entry_skip = 0, parent_cdr_entry_skip = 0,
       parent_cbs_entry_skip = 0, parent_csr_entry_skip = 0, parent_cdl_entry_skip = 0,
       parent_csc_entry_skip = 0, seq = ec_oc_flat_rec->qual[locval_ec_oc].seq, x1 = (size(reply->
        rb_list[1].code_list[seq].event_list,5)+ 1),
       stat = alterlist(reply->rb_list[1].code_list[seq].event_list,x1), reply->rb_list[1].code_list[
       seq].event_list[x1].encntr_id = ce.encntr_id, reply->rb_list[1].code_list[seq].event_list[x1].
       event_id = ce.event_id,
       reply->rb_list[1].code_list[seq].event_list[x1].order_id = ce.order_id, reply->rb_list[1].
       code_list[seq].event_list[x1].accession_nbr = ce.accession_nbr, reply->rb_list[1].code_list[
       seq].event_list[x1].frmt_accession_nbr =
       IF ((request->format_acc_ind=1)) uar_fmt_accession(ce.accession_nbr,size(ce.accession_nbr,1))
       ELSE null
       ENDIF
       ,
       reply->rb_list[1].code_list[seq].event_list[x1].clinical_event_id = ce.clinical_event_id,
       reply->rb_list[1].code_list[seq].event_list[x1].parent_event_id = ce.parent_event_id, reply->
       rb_list[1].code_list[seq].event_list[x1].valid_from_dt_tm = ce.valid_from_dt_tm,
       reply->rb_list[1].code_list[seq].event_list[x1].valid_until_dt_tm = ce.valid_until_dt_tm,
       reply->rb_list[1].code_list[seq].event_list[x1].view_level = ce.view_level, reply->rb_list[1].
       code_list[seq].event_list[x1].catalog_cd = ce.catalog_cd,
       reply->rb_list[1].code_list[seq].event_list[x1].event_cd = ce.event_cd, reply->rb_list[1].
       code_list[seq].event_list[x1].event_class_cd = ce.event_class_cd, reply->rb_list[1].code_list[
       seq].event_list[x1].event_end_dt_tm = ce.event_end_dt_tm,
       reply->rb_list[1].code_list[seq].event_list[x1].event_end_tz = validate(ce.event_end_tz,0),
       reply->rb_list[1].code_list[seq].event_list[x1].resource_cd = ce.resource_cd, reply->rb_list[1
       ].code_list[seq].event_list[x1].subtable_bit_map = ce.subtable_bit_map,
       reply->rb_list[1].code_list[seq].event_list[x1].collating_seq = format(ce.collating_seq,
        "########################################;P0"), reply->rb_list[1].code_list[seq].event_list[
       x1].event_title_text = ce.event_title_text, reply->rb_list[1].code_list[seq].event_list[x1].
       result_status_cd = ce.result_status_cd,
       reply->rb_list[1].code_list[seq].event_list[x1].normalcy_cd = ce.normalcy_cd, reply->rb_list[1
       ].code_list[seq].event_list[x1].result_val = ce.result_val, reply->rb_list[1].code_list[seq].
       event_list[x1].result_units_cd = ce.result_units_cd,
       reply->rb_list[1].code_list[seq].event_list[x1].task_assay_cd = ce.task_assay_cd, reply->
       rb_list[1].code_list[seq].event_list[x1].verified_dt_tm = ce.verified_dt_tm, reply->rb_list[1]
       .code_list[seq].event_list[x1].verified_tz = validate(ce.verified_tz,0),
       reply->rb_list[1].code_list[seq].event_list[x1].verified_prsnl_id = ce.verified_prsnl_id,
       reply->rb_list[1].code_list[seq].event_list[x1].performed_prsnl_id = ce.performed_prsnl_id,
       reply->rb_list[1].code_list[seq].event_list[x1].performed_dt_tm = ce.performed_dt_tm,
       reply->rb_list[1].code_list[seq].event_list[x1].performed_tz = validate(ce.performed_tz,0),
       reply->rb_list[1].code_list[seq].event_list[x1].normal_high = ce.normal_high, reply->rb_list[1
       ].code_list[seq].event_list[x1].normal_low = ce.normal_low,
       reply->rb_list[1].code_list[seq].event_list[x1].nomen_string_flag = ce.nomen_string_flag,
       reply->rb_list[1].code_list[seq].event_list[x1].dynamic_label_id = ce.ce_dynamic_label_id,
       reply->rb_list[1].code_list[seq].event_list[x1].cp_entry = btest(ce.subtable_bit_map,
        bitmap_ce_product)
       IF ((reply->rb_list[1].code_list[seq].event_list[x1].cp_entry=1))
        cp_entry_skip = 1, parent_cp_entry_skip = 1, cp_entry_flat_rec->rec_size += 1
        IF ((cp_entry_flat_rec->rec_size > size(cp_entry_flat_rec->qual,5)))
         stat = alterlist(cp_entry_flat_rec->qual,((cp_entry_flat_rec->rec_size+ bind_cnt) - 1))
        ENDIF
        cp_entry_flat_rec->qual[cp_entry_flat_rec->rec_size].event_id = ce.event_id,
        cp_entry_flat_rec->qual[cp_entry_flat_rec->rec_size].code_list = seq, cp_entry_flat_rec->
        qual[cp_entry_flat_rec->rec_size].event_list = x1
       ENDIF
       reply->rb_list[1].code_list[seq].event_list[x1].cep_entry = btest(ce.subtable_bit_map,
        bitmap_ce_event_prsnl)
       IF ((reply->rb_list[1].code_list[seq].event_list[x1].cep_entry=1))
        cep_entry_skip = 1, parent_cep_entry_skip = 1, cep_entry_flat_rec->rec_size += 1
        IF ((cep_entry_flat_rec->rec_size > size(cep_entry_flat_rec->qual,5)))
         stat = alterlist(cep_entry_flat_rec->qual,((cep_entry_flat_rec->rec_size+ bind_cnt) - 1))
        ENDIF
        cep_entry_flat_rec->qual[cep_entry_flat_rec->rec_size].event_id = ce.event_id,
        cep_entry_flat_rec->qual[cep_entry_flat_rec->rec_size].code_list = seq, cep_entry_flat_rec->
        qual[cep_entry_flat_rec->rec_size].event_list = x1
       ENDIF
       reply->rb_list[1].code_list[seq].event_list[x1].cen_entry = btest(ce.subtable_bit_map,
        bitmap_ce_event_note)
       IF ((reply->rb_list[1].code_list[seq].event_list[x1].cen_entry=1))
        cen_entry_skip = 1, parent_cen_entry_skip = 1, cen_entry_flat_rec->rec_size += 1
        IF ((cen_entry_flat_rec->rec_size > size(cen_entry_flat_rec->qual,5)))
         stat = alterlist(cen_entry_flat_rec->qual,((cen_entry_flat_rec->rec_size+ bind_cnt) - 1))
        ENDIF
        cen_entry_flat_rec->qual[cen_entry_flat_rec->rec_size].event_id = ce.event_id,
        cen_entry_flat_rec->qual[cen_entry_flat_rec->rec_size].code_list = seq, cen_entry_flat_rec->
        qual[cen_entry_flat_rec->rec_size].event_list = x1
       ENDIF
       reply->rb_list[1].code_list[seq].event_list[x1].cbr_entry = btest(ce.subtable_bit_map,
        bitmap_ce_blob_result)
       IF ((reply->rb_list[1].code_list[seq].event_list[x1].cbr_entry=1))
        cbr_entry_skip = 1, parent_cbr_entry_skip = 1
        IF ((request->section_type_flag=ap_section_type))
         reply->rb_list[1].ap_blob_cnt += 1
        ENDIF
        cbr_entry_flat_rec->rec_size += 1
        IF ((cbr_entry_flat_rec->rec_size > size(cbr_entry_flat_rec->qual,5)))
         stat = alterlist(cbr_entry_flat_rec->qual,((cbr_entry_flat_rec->rec_size+ bind_cnt) - 1))
        ENDIF
        cbr_entry_flat_rec->qual[cbr_entry_flat_rec->rec_size].event_id = ce.event_id,
        cbr_entry_flat_rec->qual[cbr_entry_flat_rec->rec_size].code_list = seq, cbr_entry_flat_rec->
        qual[cbr_entry_flat_rec->rec_size].event_list = x1
       ENDIF
       reply->rb_list[1].code_list[seq].event_list[x1].ccr_entry = btest(ce.subtable_bit_map,
        bitmap_ce_coded_result)
       IF ((reply->rb_list[1].code_list[seq].event_list[x1].ccr_entry=1))
        ccr_entry_skip = 1, parent_ccr_entry_skip = 1, ccr_entry_flat_rec->rec_size += 1
        IF ((ccr_entry_flat_rec->rec_size > size(ccr_entry_flat_rec->qual,5)))
         stat = alterlist(ccr_entry_flat_rec->qual,((ccr_entry_flat_rec->rec_size+ bind_cnt) - 1))
        ENDIF
        ccr_entry_flat_rec->qual[ccr_entry_flat_rec->rec_size].event_id = ce.event_id,
        ccr_entry_flat_rec->qual[ccr_entry_flat_rec->rec_size].code_list = seq, ccr_entry_flat_rec->
        qual[ccr_entry_flat_rec->rec_size].event_list = x1
       ENDIF
       reply->rb_list[1].code_list[seq].event_list[x1].cdr_entry = btest(ce.subtable_bit_map,
        bitmap_ce_date_result)
       IF ((reply->rb_list[1].code_list[seq].event_list[x1].cdr_entry=1))
        cdr_entry_skip = 1, parent_cdr_entry_skip = 1, cdr_entry_flat_rec->rec_size += 1
        IF ((cdr_entry_flat_rec->rec_size > size(cdr_entry_flat_rec->qual,5)))
         stat = alterlist(cdr_entry_flat_rec->qual,((cdr_entry_flat_rec->rec_size+ bind_cnt) - 1))
        ENDIF
        cdr_entry_flat_rec->qual[cdr_entry_flat_rec->rec_size].event_id = ce.event_id,
        cdr_entry_flat_rec->qual[cdr_entry_flat_rec->rec_size].code_list = seq, cdr_entry_flat_rec->
        qual[cdr_entry_flat_rec->rec_size].event_list = x1
       ENDIF
       reply->rb_list[1].code_list[seq].event_list[x1].cbs_entry = btest(ce.subtable_bit_map,
        bitmap_ce_blob_summary)
       IF ((reply->rb_list[1].code_list[seq].event_list[x1].cbs_entry=1))
        cbs_entry_skip = 1, parent_cbs_entry_skip = 1, cbs_entry_flat_rec->rec_size += 1
        IF ((cbs_entry_flat_rec->rec_size > size(cbs_entry_flat_rec->qual,5)))
         stat = alterlist(cbs_entry_flat_rec->qual,((cbs_entry_flat_rec->rec_size+ bind_cnt) - 1))
        ENDIF
        cbs_entry_flat_rec->qual[cbs_entry_flat_rec->rec_size].event_id = ce.event_id,
        cbs_entry_flat_rec->qual[cbs_entry_flat_rec->rec_size].code_list = seq, cbs_entry_flat_rec->
        qual[cbs_entry_flat_rec->rec_size].event_list = x1
       ENDIF
       reply->rb_list[1].code_list[seq].event_list[x1].csr_entry = btest(ce.subtable_bit_map,
        bitmap_ce_string_result)
       IF ((reply->rb_list[1].code_list[seq].event_list[x1].csr_entry=1))
        csr_entry_skip = 1, parent_csr_entry_skip = 1, csr_entry_flat_rec->rec_size += 1
        IF ((csr_entry_flat_rec->rec_size > size(csr_entry_flat_rec->qual,5)))
         stat = alterlist(csr_entry_flat_rec->qual,((csr_entry_flat_rec->rec_size+ bind_cnt) - 1))
        ENDIF
        csr_entry_flat_rec->qual[csr_entry_flat_rec->rec_size].event_id = ce.event_id,
        csr_entry_flat_rec->qual[csr_entry_flat_rec->rec_size].code_list = seq, csr_entry_flat_rec->
        qual[csr_entry_flat_rec->rec_size].event_list = x1
       ENDIF
       reply->rb_list[1].code_list[seq].event_list[x1].csc_entry = btest(ce.subtable_bit_map,
        bitmap_ce_specimen_coll)
       IF ((reply->rb_list[1].code_list[seq].event_list[x1].csc_entry=1))
        csc_entry_skip = 1, parent_csc_entry_skip = 1, csc_entry_flat_rec->rec_size += 1
        IF ((csc_entry_flat_rec->rec_size > size(csc_entry_flat_rec->qual,5)))
         stat = alterlist(csc_entry_flat_rec->qual,((csc_entry_flat_rec->rec_size+ bind_cnt) - 1))
        ENDIF
        csc_entry_flat_rec->qual[csc_entry_flat_rec->rec_size].event_id = ce.event_id,
        csc_entry_flat_rec->qual[csc_entry_flat_rec->rec_size].code_list = seq, csc_entry_flat_rec->
        qual[csc_entry_flat_rec->rec_size].event_list = x1
       ENDIF
       IF (ce.ce_dynamic_label_id > 0)
        cdl_entry_skip = 1, reply->rb_list[1].code_list[seq].event_list[x1].cdl_entry = 1,
        parent_cdl_entry_skip = 1,
        cdl_entry_flat_rec->rec_size += 1
        IF ((cdl_entry_flat_rec->rec_size > size(cdl_entry_flat_rec->qual,5)))
         stat = alterlist(cdl_entry_flat_rec->qual,((cdl_entry_flat_rec->rec_size+ bind_cnt) - 1))
        ENDIF
        cdl_entry_flat_rec->qual[cdl_entry_flat_rec->rec_size].ce_dynamic_label_id = ce
        .ce_dynamic_label_id, cdl_entry_flat_rec->qual[cdl_entry_flat_rec->rec_size].code_list = seq,
        cdl_entry_flat_rec->qual[cdl_entry_flat_rec->rec_size].event_list = x1
       ENDIF
       IF (ce.order_id > 0)
        order_comment_flat_rec->rec_size += 1
        IF ((order_comment_flat_rec->rec_size > size(order_comment_flat_rec->qual,5)))
         stat = alterlist(order_comment_flat_rec->qual,((order_comment_flat_rec->rec_size+ bind_cnt)
           - 1))
        ENDIF
        order_comment_flat_rec->qual[order_comment_flat_rec->rec_size].order_id = ce.order_id,
        order_comment_flat_rec->qual[order_comment_flat_rec->rec_size].comment_dt_tm = ce
        .event_end_dt_tm, order_comment_flat_rec->qual[order_comment_flat_rec->rec_size].comment_tz
         = validate(ce.event_end_tz,0)
       ENDIF
       IF (ce.event_class_cd=doc_class_cd)
        attachment_flat_rec->rec_size += 1
        IF ((attachment_flat_rec->rec_size > size(attachment_flat_rec->qual,5)))
         stat = alterlist(attachment_flat_rec->qual,((attachment_flat_rec->rec_size+ bind_cnt) - 1))
        ENDIF
        attachment_flat_rec->qual[attachment_flat_rec->rec_size].event_id = ce.event_id,
        attachment_flat_rec->qual[attachment_flat_rec->rec_size].code_list = seq, attachment_flat_rec
        ->qual[attachment_flat_rec->rec_size].event_list = x1
       ENDIF
       locval_ec_oc = locateval(idx2,(locval_ec_oc+ 1),size(ec_oc_flat_rec->qual,5),ce.event_cd,
        ec_oc_flat_rec->qual[idx2].event_cd), reply->rb_list[1].code_list[seq].cp_entry =
       parent_cp_entry_skip, reply->rb_list[1].code_list[seq].cep_entry = parent_cep_entry_skip,
       reply->rb_list[1].code_list[seq].cen_entry = parent_cen_entry_skip, reply->rb_list[1].
       code_list[seq].cbr_entry = parent_cbr_entry_skip, reply->rb_list[1].code_list[seq].ccr_entry
        = parent_ccr_entry_skip,
       reply->rb_list[1].code_list[seq].cdr_entry = parent_cdr_entry_skip, reply->rb_list[1].
       code_list[seq].cbs_entry = parent_cbs_entry_skip, reply->rb_list[1].code_list[seq].csr_entry
        = parent_csr_entry_skip,
       reply->rb_list[1].code_list[seq].cdl_entry = parent_cdl_entry_skip, reply->rb_list[1].
       code_list[seq].csc_entry = parent_csc_entry_skip
       IF (x1 > max_event_list)
        max_event_list = x1
       ENDIF
     ENDWHILE
    FOOT  ce.event_id
     do_nothing = 0
    FOOT  ce.parent_event_id
     do_nothing = 0
    FOOT  d3.seq
     do_nothing = 0
    WITH nocounter
   ;end select
   CALL echo(build("event_list_nbr = ",max_event_list))
   CALL error_and_zero_check(curqual,"CLINICAL_EVENT","GETVALIDEVENTS",1,1)
   IF (max_event_list=0)
    CALL error_and_zero_check(0,"CLINICAL_EVENT","GETVALIDEVENTS2",1,1)
   ENDIF
   IF ((request->section_type_flag=doc_section_type))
    CALL getattachments(null)
   ENDIF
   IF (cp_entry_skip=1)
    CALL getceproduct(null)
   ENDIF
   IF (cep_entry_skip=1)
    CALL getceeventprsnl(null)
   ENDIF
   IF (cen_entry_skip=1)
    CALL getceeventnote(null)
   ENDIF
   IF (cbr_entry_skip=1)
    CALL getceblobresult(null)
   ENDIF
   IF (ccr_entry_skip=1)
    CALL getcecodedresult(null)
   ENDIF
   IF (cdr_entry_skip=1)
    CALL getcedateresult(null)
   ENDIF
   IF (cbs_entry_skip=1)
    CALL getceblobsummary(null)
   ENDIF
   IF (csr_entry_skip=1)
    CALL getcestringresult(null)
   ENDIF
   IF (cdl_entry_skip=1)
    CALL getcedynamiclabel(null)
   ENDIF
   IF (csc_entry_skip=1)
    CALL getcespecimencollforlistview(null)
   ENDIF
   IF (request->order_cmnt_ind)
    CALL getordercomments(null)
   ENDIF
   CALL getreflabfootnotes(null)
 END ;Subroutine
 SUBROUTINE getfinalevents(null)
   CALL log_message("In GetFinalEvents()",log_level_debug)
   DECLARE nrecsize = i4 WITH noconstant(0), protect
   DECLARE x = i4 WITH noconstant(0), protect
   DECLARE ec_oc_index = i4 WITH noconstant(0)
   DECLARE idxecoc = i4
   FOR (x = 1 TO size(temp_events->qual,5))
     IF ((temp_events->qual[x].dontcare=0))
      SET ec_oc_index = locateval(idxecoc,1,size(ec_oc_flat_rec->qual,5),temp_events->qual[x].
       event_cd,ec_oc_flat_rec->qual[idxecoc].event_cd)
      WHILE (ec_oc_index != 0)
       IF ((temp_events->qual[x].catalog_cd=ec_oc_flat_rec->qual[ec_oc_index].catalog_cd)
        AND (ec_oc_flat_rec->qual[ec_oc_index].procedure_type_flag=order_procedure_type))
        SET nrecsize += 1
        IF (nrecsize > size(final_events->qual,5))
         SET stat = alterlist(final_events->qual,((nrecsize+ bind_cnt) - 1))
        ENDIF
        SET final_events->qual[nrecsize].event_id = temp_events->qual[x].event_id
        SET final_events->qual[nrecsize].catalog_cd = temp_events->qual[x].catalog_cd
        SET final_events->qual[nrecsize].event_cd = temp_events->qual[x].event_cd
        SET final_events->qual[nrecsize].dontcare = temp_events->qual[x].dontcare
        SET final_events->qual[nrecsize].code = ec_oc_flat_rec->qual[ec_oc_index].catalog_cd
        SET final_events->qual[nrecsize].seq = ec_oc_flat_rec->qual[ec_oc_index].seq
       ELSEIF ((ec_oc_flat_rec->qual[ec_oc_index].procedure_type_flag=event_procedure_type))
        SET nrecsize += 1
        IF (nrecsize > size(final_events->qual,5))
         SET stat = alterlist(final_events->qual,((nrecsize+ bind_cnt) - 1))
        ENDIF
        SET final_events->qual[nrecsize].event_id = temp_events->qual[x].event_id
        SET final_events->qual[nrecsize].catalog_cd = temp_events->qual[x].catalog_cd
        SET final_events->qual[nrecsize].event_cd = temp_events->qual[x].event_cd
        SET final_events->qual[nrecsize].dontcare = temp_events->qual[x].dontcare
        SET final_events->qual[nrecsize].code = ec_oc_flat_rec->qual[ec_oc_index].event_set_cd
        SET final_events->qual[nrecsize].seq = ec_oc_flat_rec->qual[ec_oc_index].seq
       ENDIF
       SET ec_oc_index = locateval(idxecoc,(ec_oc_index+ 1),size(ec_oc_flat_rec->qual,5),temp_events
        ->qual[x].event_cd,ec_oc_flat_rec->qual[idxecoc].event_cd)
      ENDWHILE
     ENDIF
   ENDFOR
   SET stat = alterlist(final_events->qual,nrecsize)
   CALL error_and_zero_check(size(final_events->qual,5),"GETFINALEVENTS","GETFINALEVENTS",1,1)
 END ;Subroutine
 SUBROUTINE getattachments(null)
   CALL log_message("In GetAttachments()",log_level_debug)
   SET idxstart = 1
   SET nrecordsize = attachment_flat_rec->rec_size
   SET noptimizedtotal = (ceil((cnvtreal(nrecordsize)/ bind_cnt)) * bind_cnt)
   FOR (i = (nrecordsize+ 1) TO noptimizedtotal)
     SET attachment_flat_rec->qual[i].event_id = attachment_flat_rec->qual[nrecordsize].event_id
     SET attachment_flat_rec->qual[i].code_list = attachment_flat_rec->qual[nrecordsize].code_list
     SET attachment_flat_rec->qual[i].event_list = attachment_flat_rec->qual[nrecordsize].event_list
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     clinical_event ce
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (ce
     WHERE expand(idx,idxstart,((idxstart+ bind_cnt) - 1),ce.parent_event_id,attachment_flat_rec->
      qual[idx].event_id,
      bind_cnt)
      AND ce.event_class_cd=attach_class_cd
      AND ce.valid_until_dt_tm >= cnvtdatetime(v_until_dt)
      AND ce.publish_flag=1
      AND parser(result_clause))
    ORDER BY ce.parent_event_id, ce.event_id, cnvtdatetime(ce.event_end_dt_tm)
    DETAIL
     locval = locateval(idx2,1,attachment_flat_rec->rec_size,ce.parent_event_id,attachment_flat_rec->
      qual[idx2].event_id)
     WHILE (locval != 0)
       code_list = attachment_flat_rec->qual[locval].code_list, event_list = attachment_flat_rec->
       qual[locval].event_list, x1 = (size(reply->rb_list[1].code_list[code_list].event_list[
        event_list].attachment_list,5)+ 1),
       stat = alterlist(reply->rb_list[1].code_list[code_list].event_list[event_list].attachment_list,
        x1), reply->rb_list[1].code_list[code_list].event_list[event_list].attachment_list[x1].
       event_id = ce.event_id, reply->rb_list[1].code_list[code_list].event_list[event_list].
       attachment_list[x1].result_status_cd = ce.result_status_cd,
       reply->rb_list[1].code_list[code_list].event_list[event_list].attachment_list[x1].
       event_title_text = ce.event_title_text, reply->rb_list[1].code_list[code_list].event_list[
       event_list].attachment_list[x1].event_end_tz = validate(ce.event_end_tz,0), reply->rb_list[1].
       code_list[code_list].event_list[event_list].attachment_list[x1].event_end_dt_tm = ce
       .event_end_dt_tm,
       locval = locateval(idx2,(locval+ 1),attachment_flat_rec->rec_size,ce.parent_event_id,
        attachment_flat_rec->qual[idx2].event_id)
     ENDWHILE
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CLINICAL_EVENT","GETATTACHMENTS",1,0)
 END ;Subroutine
 SUBROUTINE getceeventprsnl(null)
   CALL log_message("In GetCeEventPrsnl()",log_level_debug)
   SET idxstart = 1
   SET nrecordsize = cep_entry_flat_rec->rec_size
   SET noptimizedtotal = (ceil((cnvtreal(nrecordsize)/ bind_cnt)) * bind_cnt)
   FOR (i = (nrecordsize+ 1) TO noptimizedtotal)
     SET cep_entry_flat_rec->qual[i].event_id = cep_entry_flat_rec->qual[nrecordsize].event_id
     SET cep_entry_flat_rec->qual[i].code_list = cep_entry_flat_rec->qual[nrecordsize].code_list
     SET cep_entry_flat_rec->qual[i].event_list = cep_entry_flat_rec->qual[nrecordsize].event_list
   ENDFOR
   SELECT INTO "nl:"
    cep.seq, cep.event_prsnl_id
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     ce_event_prsnl cep
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (cep
     WHERE expand(idx,idxstart,((idxstart+ bind_cnt) - 1),cep.event_id,cep_entry_flat_rec->qual[idx].
      event_id,
      bind_cnt)
      AND cep.valid_until_dt_tm >= cnvtdatetime(v_until_dt))
    ORDER BY cep.action_dt_tm
    DETAIL
     locval = locateval(idx2,1,cep_entry_flat_rec->rec_size,cep.event_id,cep_entry_flat_rec->qual[
      idx2].event_id)
     WHILE (locval != 0)
       code_list = cep_entry_flat_rec->qual[locval].code_list, event_list = cep_entry_flat_rec->qual[
       locval].event_list, x1 = (size(reply->rb_list[1].code_list[code_list].event_list[event_list].
        event_prsnl_list,5)+ 1),
       stat = alterlist(reply->rb_list[1].code_list[code_list].event_list[event_list].
        event_prsnl_list,x1)
       IF (cep.action_type_cd=endorse_cd
        AND cep.system_comment > " ")
        reply->rb_list[1].code_list[code_list].event_list[event_list].has_endorse_comment = 1
       ENDIF
       reply->rb_list[1].code_list[code_list].event_list[event_list].event_prsnl_list[x1].
       action_type_cd = cep.action_type_cd, reply->rb_list[1].code_list[code_list].event_list[
       event_list].event_prsnl_list[x1].action_dt_tm = cep.action_dt_tm, reply->rb_list[1].code_list[
       code_list].event_list[event_list].event_prsnl_list[x1].action_tz = validate(cep.action_tz,0),
       reply->rb_list[1].code_list[code_list].event_list[event_list].event_prsnl_list[x1].
       action_prsnl_id = cep.action_prsnl_id, reply->rb_list[1].code_list[code_list].event_list[
       event_list].event_prsnl_list[x1].action_comment = cep.action_comment, locval = locateval(idx2,
        (locval+ 1),cep_entry_flat_rec->rec_size,cep.event_id,cep_entry_flat_rec->qual[idx2].event_id
        )
     ENDWHILE
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CE_EVENT_PRSNL","GETCEEVENTPRSNL",1,0)
 END ;Subroutine
 SUBROUTINE getceblobresult(null)
   CALL log_message("In GetCeBlobResult()",log_level_debug)
   SET nrecordsize = cbr_entry_flat_rec->rec_size
   SET noptimizedtotal = (ceil((cnvtreal(nrecordsize)/ bind_cnt)) * bind_cnt)
   FOR (i = (nrecordsize+ 1) TO noptimizedtotal)
     SET cbr_entry_flat_rec->qual[i].event_id = cbr_entry_flat_rec->qual[nrecordsize].event_id
     SET cbr_entry_flat_rec->qual[i].code_list = cbr_entry_flat_rec->qual[nrecordsize].code_list
     SET cbr_entry_flat_rec->qual[i].event_list = cbr_entry_flat_rec->qual[nrecordsize].event_list
   ENDFOR
   SET idxstart = 1
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     ce_blob_result cbr
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (cbr
     WHERE expand(idx,idxstart,((idxstart+ bind_cnt) - 1),cbr.event_id,cbr_entry_flat_rec->qual[idx].
      event_id,
      bind_cnt)
      AND cbr.valid_until_dt_tm >= cnvtdatetime(v_until_dt))
    ORDER BY cbr.event_id
    DETAIL
     locval = locateval(idx2,1,cbr_entry_flat_rec->rec_size,cbr.event_id,cbr_entry_flat_rec->qual[
      idx2].event_id)
     WHILE (locval != 0)
       code_list = cbr_entry_flat_rec->qual[locval].code_list, event_list = cbr_entry_flat_rec->qual[
       locval].event_list, x1 = (size(reply->rb_list[1].code_list[code_list].event_list[event_list].
        blob_result,5)+ 1),
       stat = alterlist(reply->rb_list[1].code_list[code_list].event_list[event_list].blob_result,x1),
       reply->rb_list[1].code_list[code_list].event_list[event_list].blob_result[x1].format_cd = cbr
       .format_cd, reply->rb_list[1].code_list[code_list].event_list[event_list].blob_result[x1].
       storage_cd = cbr.storage_cd,
       reply->rb_list[1].code_list[code_list].event_list[event_list].blob_result[x1].blob_handle =
       cbr.blob_handle, reply->rb_list[1].code_list[code_list].event_list[event_list].blob_result[x1]
       .event_id = cbr.event_id
       IF (cbr.format_cd != acrnema_frmt_cd)
        IF ((( NOT (cbr.format_cd IN (ascii_cd, rtf_cd))
         AND cbr.storage_cd != otg_storage_cd) OR (cbr.storage_cd=otg_storage_cd
         AND (request->cdi_supported=0))) )
         reply->rb_list[1].code_list[code_list].event_list[event_list].mdoc_incomplete = 1
        ENDIF
       ELSE
        IF (cbr.storage_cd != dicom_storage_cd)
         reply->rb_list[1].code_list[code_list].event_list[event_list].mdoc_incomplete = 1
        ENDIF
       ENDIF
       locval = locateval(idx2,(locval+ 1),cbr_entry_flat_rec->rec_size,cbr.event_id,
        cbr_entry_flat_rec->qual[idx2].event_id)
     ENDWHILE
    WITH memsort, nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CE_BLOB_RESULT","GETCEBLOBRESULT",1,0)
   SET idxstart = 1
   SELECT INTO "nl:"
    blength = size(trim(cb.blob_contents))
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     ce_blob cb
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (cb
     WHERE expand(idx,idxstart,((idxstart+ bind_cnt) - 1),cb.event_id,cbr_entry_flat_rec->qual[idx].
      event_id,
      bind_cnt)
      AND cb.valid_until_dt_tm >= cnvtdatetime(v_until_dt))
    ORDER BY cb.event_id, cb.blob_seq_num
    DETAIL
     locval = locateval(idx2,1,cbr_entry_flat_rec->rec_size,cb.event_id,cbr_entry_flat_rec->qual[idx2
      ].event_id)
     WHILE (locval != 0)
       code_list = cbr_entry_flat_rec->qual[locval].code_list, event_list = cbr_entry_flat_rec->qual[
       locval].event_list, blob_list = locateval(idx3,1,size(reply->rb_list[1].code_list[code_list].
         event_list[event_list].blob_result,5),cb.event_id,reply->rb_list[1].code_list[code_list].
        event_list[event_list].blob_result[idx3].event_id)
       WHILE (blob_list != 0)
        IF ((reply->rb_list[1].code_list[code_list].event_list[event_list].blob_result[blob_list].
        format_cd IN (ascii_cd, rtf_cd)))
         x1 = (size(reply->rb_list[1].code_list[code_list].event_list[event_list].blob_result[
          blob_list].blob,5)+ 1), stat = alterlist(reply->rb_list[1].code_list[code_list].event_list[
          event_list].blob_result[blob_list].blob,x1)
         IF (cb.compression_cd=ocfcomp_cd)
          reply->rb_list[1].code_list[code_list].event_list[event_list].blob_result[blob_list].
          is_compressed = 1, reply->rb_list[1].code_list[code_list].event_list[event_list].
          blob_result[blob_list].blob_length = cb.blob_length, reply->rb_list[1].code_list[code_list]
          .event_list[event_list].blob_result[blob_list].blob[x1].blob_contents_as_bytes = cb
          .blob_contents
         ELSE
          length = size(trim(cb.blob_contents)), reply->rb_list[1].code_list[code_list].event_list[
          event_list].blob_result[blob_list].blob[x1].blob_contents = notrim(substring(1,(length - 8),
            cb.blob_contents)), reply->rb_list[1].code_list[code_list].event_list[event_list].
          blob_result[blob_list].blob_length = (length - 8)
         ENDIF
         reply->rb_list[1].code_list[code_list].event_list[event_list].blob_result[blob_list].blob[x1
         ].blob_seq_num = cb.blob_seq_num
        ENDIF
        ,blob_list = locateval(idx3,(blob_list+ 1),size(reply->rb_list[1].code_list[code_list].
          event_list[event_list].blob_result,5),cb.event_id,reply->rb_list[1].code_list[code_list].
         event_list[event_list].blob_result[idx3].event_id)
       ENDWHILE
       locval = locateval(idx2,(locval+ 1),cbr_entry_flat_rec->rec_size,cb.event_id,
        cbr_entry_flat_rec->qual[idx2].event_id)
     ENDWHILE
    WITH memsort, nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CE_BLOB","GETCEBLOBRESULT",1,0)
 END ;Subroutine
 SUBROUTINE getcecodedresult(null)
   CALL log_message("In GetCeCodedResult()",log_level_debug)
   SET idxstart = 1
   SET nrecordsize = ccr_entry_flat_rec->rec_size
   SET noptimizedtotal = (ceil((cnvtreal(nrecordsize)/ bind_cnt)) * bind_cnt)
   FOR (i = (nrecordsize+ 1) TO noptimizedtotal)
     SET ccr_entry_flat_rec->qual[i].event_id = ccr_entry_flat_rec->qual[nrecordsize].event_id
     SET ccr_entry_flat_rec->qual[i].code_list = ccr_entry_flat_rec->qual[nrecordsize].code_list
     SET ccr_entry_flat_rec->qual[i].event_list = ccr_entry_flat_rec->qual[nrecordsize].event_list
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     ce_coded_result ccr,
     nomenclature n
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (ccr
     WHERE expand(idx,idxstart,((idxstart+ bind_cnt) - 1),ccr.event_id,ccr_entry_flat_rec->qual[idx].
      event_id,
      bind_cnt)
      AND ccr.valid_until_dt_tm >= cnvtdatetime(v_until_dt))
     JOIN (n
     WHERE ccr.nomenclature_id=n.nomenclature_id)
    ORDER BY ccr.sequence_nbr, cnvtdatetime(ccr.valid_until_dt_tm)
    HEAD REPORT
     x1 = 0
    DETAIL
     locval = locateval(idx2,1,ccr_entry_flat_rec->rec_size,ccr.event_id,ccr_entry_flat_rec->qual[
      idx2].event_id)
     WHILE (locval != 0)
       code_list = ccr_entry_flat_rec->qual[locval].code_list, event_list = ccr_entry_flat_rec->qual[
       locval].event_list, x1 = (size(reply->rb_list[1].code_list[code_list].event_list[event_list].
        coded_result_list,5)+ 1),
       stat = alterlist(reply->rb_list[1].code_list[code_list].event_list[event_list].
        coded_result_list,x1), reply->rb_list[1].code_list[code_list].event_list[event_list].
       coded_result_list[x1].short_string = n.short_string, reply->rb_list[1].code_list[code_list].
       event_list[event_list].coded_result_list[x1].source_string = n.source_string,
       reply->rb_list[1].code_list[code_list].event_list[event_list].coded_result_list[x1].
       source_identifier = n.source_identifier, reply->rb_list[1].code_list[code_list].event_list[
       event_list].coded_result_list[x1].mnemonic = n.mnemonic, locval = locateval(idx2,(locval+ 1),
        ccr_entry_flat_rec->rec_size,ccr.event_id,ccr_entry_flat_rec->qual[idx2].event_id)
     ENDWHILE
    FOOT REPORT
     donothing = 0
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CE_CODED_RESULT","GETCECODEDRESULT",1,0)
 END ;Subroutine
 SUBROUTINE getceeventnote(null)
   CALL log_message("In GetCeEventNote()",log_level_debug)
   SET idxstart = 1
   SET nrecordsize = cen_entry_flat_rec->rec_size
   SET noptimizedtotal = (ceil((cnvtreal(nrecordsize)/ bind_cnt)) * bind_cnt)
   FOR (i = (nrecordsize+ 1) TO noptimizedtotal)
     SET cen_entry_flat_rec->qual[i].event_id = cen_entry_flat_rec->qual[nrecordsize].event_id
     SET cen_entry_flat_rec->qual[i].code_list = cen_entry_flat_rec->qual[nrecordsize].code_list
     SET cen_entry_flat_rec->qual[i].event_list = cen_entry_flat_rec->qual[nrecordsize].event_list
   ENDFOR
   SELECT INTO "nl:"
    blength = textlen(lb.long_blob), cen.event_note_id, lb.seq
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     ce_event_note cen,
     long_blob lb
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (cen
     WHERE expand(idx,idxstart,((idxstart+ bind_cnt) - 1),cen.event_id,cen_entry_flat_rec->qual[idx].
      event_id,
      bind_cnt)
      AND cen.valid_until_dt_tm >= cnvtdatetime(v_until_dt)
      AND ((cen.non_chartable_flag=0) OR (cen.updt_task=csm_request_viewer_task)) )
     JOIN (lb
     WHERE lb.parent_entity_name="CE_EVENT_NOTE"
      AND lb.parent_entity_id=cen.ce_event_note_id)
    ORDER BY cen.event_note_id, cnvtdatetime(cen.valid_until_dt_tm)
    HEAD cen.event_note_id
     do_nothing = 0
    DETAIL
     do_nothing = 0
    FOOT  cen.event_note_id
     locval = locateval(idx2,1,cen_entry_flat_rec->rec_size,cen.event_id,cen_entry_flat_rec->qual[
      idx2].event_id)
     WHILE (locval != 0)
       code_list = cen_entry_flat_rec->qual[locval].code_list, event_list = cen_entry_flat_rec->qual[
       locval].event_list, x1 = (size(reply->rb_list[1].code_list[code_list].event_list[event_list].
        event_note_list,5)+ 1),
       stat = alterlist(reply->rb_list[1].code_list[code_list].event_list[event_list].event_note_list,
        x1), reply->rb_list[1].code_list[code_list].event_list[event_list].event_note_list[x1].
       note_type_cd = cen.note_type_cd, reply->rb_list[1].code_list[code_list].event_list[event_list]
       .event_note_list[x1].note_format_cd = cen.note_format_cd,
       reply->rb_list[1].code_list[code_list].event_list[event_list].event_note_list[x1].note_dt_tm
        = cen.note_dt_tm, reply->rb_list[1].code_list[code_list].event_list[event_list].
       event_note_list[x1].note_tz = validate(cen.note_tz,0), blob_out = fillstring(32000," ")
       IF (cen.compression_cd=ocfcomp_cd)
        blob_ret_len = 0,
        CALL uar_ocf_uncompress(lb.long_blob,blength,blob_out,32000,blob_ret_len), y1 = size(trim(
          blob_out)),
        reply->rb_list[1].code_list[code_list].event_list[event_list].event_note_list[x1].long_blob
         = blob_out, reply->rb_list[1].code_list[code_list].event_list[event_list].event_note_list[x1
        ].blob_length = y1
       ELSE
        y1 = size(trim(lb.long_blob)), reply->rb_list[1].code_list[code_list].event_list[event_list].
        event_note_list[x1].long_blob = notrim(substring(1,(y1 - 8),lb.long_blob)), reply->rb_list[1]
        .code_list[code_list].event_list[event_list].event_note_list[x1].blob_length = (y1 - 8)
       ENDIF
       locval = locateval(idx2,(locval+ 1),cen_entry_flat_rec->rec_size,cen.event_id,
        cen_entry_flat_rec->qual[idx2].event_id)
     ENDWHILE
    WITH memsort, nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CE_EVENT_NOTE","GETCEEVENTNOTE",1,0)
 END ;Subroutine
 SUBROUTINE getceproduct(null)
   CALL log_message("In GetCeProduct()",log_level_debug)
   SET idxstart = 1
   SET nrecordsize = cp_entry_flat_rec->rec_size
   SET noptimizedtotal = (ceil((cnvtreal(nrecordsize)/ bind_cnt)) * bind_cnt)
   FOR (i = (nrecordsize+ 1) TO noptimizedtotal)
     SET cp_entry_flat_rec->qual[i].event_id = cp_entry_flat_rec->qual[nrecordsize].event_id
     SET cp_entry_flat_rec->qual[i].code_list = cp_entry_flat_rec->qual[nrecordsize].code_list
     SET cp_entry_flat_rec->qual[i].event_list = cp_entry_flat_rec->qual[nrecordsize].event_list
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     ce_product cp
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (cp
     WHERE expand(idx,idxstart,((idxstart+ bind_cnt) - 1),cp.event_id,cp_entry_flat_rec->qual[idx].
      event_id,
      bind_cnt)
      AND cp.valid_until_dt_tm >= cnvtdatetime(v_until_dt))
    DETAIL
     locval = locateval(idx2,1,cp_entry_flat_rec->rec_size,cp.event_id,cp_entry_flat_rec->qual[idx2].
      event_id)
     WHILE (locval != 0)
       code_list = cp_entry_flat_rec->qual[locval].code_list, event_list = cp_entry_flat_rec->qual[
       locval].event_list, x1 = (size(reply->rb_list[1].code_list[code_list].event_list[event_list].
        product,5)+ 1),
       stat = alterlist(reply->rb_list[1].code_list[code_list].event_list[event_list].product,x1),
       reply->rb_list[1].code_list[code_list].event_list[event_list].product[x1].product_nbr = cp
       .product_nbr, reply->rb_list[1].code_list[code_list].event_list[event_list].product[x1].
       product_cd = cp.product_cd,
       reply->rb_list[1].code_list[code_list].event_list[event_list].product[x1].product_status_cd =
       cp.product_status_cd, locval = locateval(idx2,(locval+ 1),cp_entry_flat_rec->rec_size,cp
        .event_id,cp_entry_flat_rec->qual[idx2].event_id)
     ENDWHILE
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CE_PRODUCT","GETCEPRODUCT",1,0)
   SET idxstart = 1
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     ce_product cp,
     code_value_extension cve,
     code_value_extension cve2,
     code_value cv
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (cp
     WHERE expand(idx,idxstart,((idxstart+ bind_cnt) - 1),cp.event_id,cp_entry_flat_rec->qual[idx].
      event_id,
      bind_cnt)
      AND cp.valid_until_dt_tm >= cnvtdatetime(v_until_dt))
     JOIN (cve
     WHERE cve.code_set=1640
      AND cve.field_value=trim(cnvtstring(cp.abo_cd))
      AND cve.field_name="ABOOnly_cd")
     JOIN (cve2
     WHERE cve2.code_set=1640
      AND cve2.code_value=cve.code_value
      AND cve2.field_value=trim(cnvtstring(cp.rh_cd))
      AND cve2.field_name="RhOnly_cd")
     JOIN (cv
     WHERE cv.code_set=1640
      AND cv.code_value=cve2.code_value
      AND cv.active_ind=1
      AND cv.begin_effective_dt_tm < sysdate
      AND cv.end_effective_dt_tm > sysdate)
    DETAIL
     locval = locateval(idx2,1,cp_entry_flat_rec->rec_size,cp.event_id,cp_entry_flat_rec->qual[idx2].
      event_id)
     WHILE (locval != 0)
       code_list = cp_entry_flat_rec->qual[locval].code_list, event_list = cp_entry_flat_rec->qual[
       locval].event_list, product_val = locateval(idx3,1,size(reply->rb_list[1].code_list[code_list]
         .event_list[event_list].product,5),cp.product_cd,reply->rb_list[1].code_list[code_list].
        event_list[event_list].product[idx3].product_cd)
       WHILE (product_val != 0)
        reply->rb_list[1].code_list[code_list].event_list[event_list].product[product_val].aborh_cd
         = cve.code_value,product_val = locateval(idx3,(product_val+ 1),size(reply->rb_list[1].
          code_list[code_list].event_list[event_list].product,5),cp.product_cd,reply->rb_list[1].
         code_list[code_list].event_list[event_list].product[idx3].product_cd)
       ENDWHILE
       locval = locateval(idx2,(locval+ 1),cp_entry_flat_rec->rec_size,cp.event_id,cp_entry_flat_rec
        ->qual[idx2].event_id)
     ENDWHILE
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CODE_VALUE_EXTENSION","GETCEPRODUCT",1,0)
 END ;Subroutine
 SUBROUTINE getceblobsummary(null)
   CALL log_message("In GetCeBlobSummary()",log_level_debug)
   SET idxstart = 1
   SET nrecordsize = cbs_entry_flat_rec->rec_size
   SET noptimizedtotal = (ceil((cnvtreal(nrecordsize)/ bind_cnt)) * bind_cnt)
   FOR (i = (nrecordsize+ 1) TO noptimizedtotal)
     SET cbs_entry_flat_rec->qual[i].event_id = cbs_entry_flat_rec->qual[nrecordsize].event_id
     SET cbs_entry_flat_rec->qual[i].code_list = cbs_entry_flat_rec->qual[nrecordsize].code_list
     SET cbs_entry_flat_rec->qual[i].event_list = cbs_entry_flat_rec->qual[nrecordsize].event_list
   ENDFOR
   SELECT INTO "nl:"
    blength = textlen(lb.long_blob)
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     ce_blob_summary cbs,
     long_blob lb
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (cbs
     WHERE expand(idx,idxstart,((idxstart+ bind_cnt) - 1),cbs.event_id,cbs_entry_flat_rec->qual[idx].
      event_id,
      bind_cnt)
      AND cbs.valid_until_dt_tm >= cnvtdatetime(v_until_dt))
     JOIN (lb
     WHERE lb.parent_entity_name="CE_BLOB_SUMMARY"
      AND lb.parent_entity_id=cbs.ce_blob_summary_id)
    ORDER BY cbs.blob_summary_id, cnvtdatetime(cbs.valid_until_dt_tm)
    DETAIL
     locval = locateval(idx2,1,cbs_entry_flat_rec->rec_size,cbs.event_id,cbs_entry_flat_rec->qual[
      idx2].event_id)
     WHILE (locval != 0)
       code_list = cbs_entry_flat_rec->qual[locval].code_list, event_list = cbs_entry_flat_rec->qual[
       locval].event_list, x1 = (size(reply->rb_list[1].code_list[code_list].event_list[event_list].
        blob_summary_list,5)+ 1),
       stat = alterlist(reply->rb_list[1].code_list[code_list].event_list[event_list].
        blob_summary_list,x1), reply->rb_list[1].code_list[code_list].event_list[event_list].
       blob_summary_list[x1].format_cd = cbs.format_cd, reply->rb_list[1].code_list[code_list].
       event_list[event_list].blob_summary_list[x1].long_blob = lb.long_blob,
       locval = locateval(idx2,(locval+ 1),cbs_entry_flat_rec->rec_size,cbs.event_id,
        cbs_entry_flat_rec->qual[idx2].event_id)
     ENDWHILE
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CE_BLOB_SUMMARY","GETCEBLOBSUMMARY",1,0)
 END ;Subroutine
 SUBROUTINE getcestringresult(null)
   CALL log_message("In GetCeStringResult()",log_level_debug)
   SET idxstart = 1
   SET nrecordsize = csr_entry_flat_rec->rec_size
   SET noptimizedtotal = (ceil((cnvtreal(nrecordsize)/ bind_cnt)) * bind_cnt)
   FOR (i = (nrecordsize+ 1) TO noptimizedtotal)
     SET csr_entry_flat_rec->qual[i].event_id = csr_entry_flat_rec->qual[nrecordsize].event_id
     SET csr_entry_flat_rec->qual[i].code_list = csr_entry_flat_rec->qual[nrecordsize].code_list
     SET csr_entry_flat_rec->qual[i].event_list = csr_entry_flat_rec->qual[nrecordsize].event_list
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     ce_string_result csr,
     long_text lt
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (csr
     WHERE expand(idx,idxstart,((idxstart+ bind_cnt) - 1),csr.event_id,csr_entry_flat_rec->qual[idx].
      event_id,
      bind_cnt)
      AND csr.valid_until_dt_tm >= cnvtdatetime(v_until_dt))
     JOIN (lt
     WHERE lt.long_text_id=csr.string_long_text_id)
    HEAD REPORT
     x1 = 0
    DETAIL
     locval = locateval(idx2,1,csr_entry_flat_rec->rec_size,csr.event_id,csr_entry_flat_rec->qual[
      idx2].event_id)
     WHILE (locval != 0)
       code_list = csr_entry_flat_rec->qual[locval].code_list, event_list = csr_entry_flat_rec->qual[
       locval].event_list, x1 = (size(reply->rb_list[1].code_list[code_list].event_list[event_list].
        string_result_list,5)+ 1),
       stat = alterlist(reply->rb_list[1].code_list[code_list].event_list[event_list].
        string_result_list,x1)
       IF (csr.string_long_text_id > 0.0)
        reply->rb_list[1].code_list[code_list].event_list[event_list].string_result_list[x1].
        string_long_text_id = csr.string_long_text_id, reply->rb_list[1].code_list[code_list].
        event_list[event_list].string_result_list[x1].string_result_text = lt.long_text
       ELSE
        reply->rb_list[1].code_list[code_list].event_list[event_list].string_result_list[x1].
        string_result_text = csr.string_result_text
       ENDIF
       locval = locateval(idx2,(locval+ 1),csr_entry_flat_rec->rec_size,csr.event_id,
        csr_entry_flat_rec->qual[idx2].event_id)
     ENDWHILE
    FOOT REPORT
     donothing = 0
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CE_STRING_RESULT","GETCESTRINGRESULT",1,0)
 END ;Subroutine
 SUBROUTINE getcedynamiclabel(null)
   CALL log_message("In GetCeDynamicLabel()",log_level_debug)
   SET idxstart = 1
   SET nrecordsize = cdl_entry_flat_rec->rec_size
   SET noptimizedtotal = (ceil((cnvtreal(nrecordsize)/ bind_cnt)) * bind_cnt)
   FOR (i = (nrecordsize+ 1) TO noptimizedtotal)
     SET cdl_entry_flat_rec->qual[i].ce_dynamic_label_id = cdl_entry_flat_rec->qual[nrecordsize].
     ce_dynamic_label_id
     SET cdl_entry_flat_rec->qual[i].code_list = cdl_entry_flat_rec->qual[nrecordsize].code_list
     SET cdl_entry_flat_rec->qual[i].event_list = cdl_entry_flat_rec->qual[nrecordsize].event_list
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     ce_dynamic_label cdl,
     long_text lt
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (cdl
     WHERE expand(idx,idxstart,((idxstart+ bind_cnt) - 1),cdl.ce_dynamic_label_id,cdl_entry_flat_rec
      ->qual[idx].ce_dynamic_label_id,
      bind_cnt)
      AND cdl.valid_until_dt_tm >= cnvtdatetime(v_until_dt))
     JOIN (lt
     WHERE lt.long_text_id=cdl.long_text_id)
    DETAIL
     locval = locateval(idx2,1,cdl_entry_flat_rec->rec_size,cdl.ce_dynamic_label_id,
      cdl_entry_flat_rec->qual[idx2].ce_dynamic_label_id)
     WHILE (locval != 0)
       code_list = cdl_entry_flat_rec->qual[locval].code_list, event_list = cdl_entry_flat_rec->qual[
       locval].event_list
       IF (cdl.long_text_id > 0.0)
        reply->rb_list[1].code_list[code_list].event_list[event_list].dynamic_label_name = lt
        .long_text
       ELSE
        reply->rb_list[1].code_list[code_list].event_list[event_list].dynamic_label_name = cdl
        .label_name
       ENDIF
       reply->rb_list[1].code_list[code_list].event_list[event_list].label_seq_nbr = cdl
       .label_seq_nbr, locval = locateval(idx2,(locval+ 1),cdl_entry_flat_rec->rec_size,cdl
        .ce_dynamic_label_id,cdl_entry_flat_rec->qual[idx2].ce_dynamic_label_id)
     ENDWHILE
    FOOT REPORT
     donothing = 0
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CE_DYNAMIC_LABEL","GETCEDYNAMICLABEL",1,0)
 END ;Subroutine
 SUBROUTINE getordercomments(null)
   CALL log_message("In GetOrderComments()",log_level_debug)
   SET idxstart = 1
   SET nrecordsize = order_comment_flat_rec->rec_size
   SET noptimizedtotal = (ceil((cnvtreal(nrecordsize)/ bind_cnt)) * bind_cnt)
   FOR (i = (nrecordsize+ 1) TO noptimizedtotal)
     SET order_comment_flat_rec->qual[i].order_id = order_comment_flat_rec->qual[nrecordsize].
     order_id
     SET order_comment_flat_rec->qual[i].comment_dt_tm = order_comment_flat_rec->qual[nrecordsize].
     comment_dt_tm
     SET order_comment_flat_rec->qual[i].comment_tz = order_comment_flat_rec->qual[nrecordsize].
     comment_tz
   ENDFOR
   SELECT DISTINCT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     order_comment oc,
     long_text lt,
     orders o
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (oc
     WHERE expand(idx,idxstart,((idxstart+ bind_cnt) - 1),oc.order_id,order_comment_flat_rec->qual[
      idx].order_id,
      bind_cnt)
      AND oc.comment_type_cd=ordcomm_cd)
     JOIN (lt
     WHERE lt.long_text_id=oc.long_text_id)
     JOIN (o
     WHERE o.order_id=oc.order_id)
    ORDER BY oc.order_id, oc.action_sequence
    HEAD REPORT
     x = 0
    HEAD oc.order_id
     donothing = 0
    FOOT  oc.order_id
     x += 1, stat = alterlist(reply->rb_list[1].order_list,x), reply->rb_list[1].order_list[x].
     order_id = oc.order_id,
     reply->rb_list[1].order_list[x].long_text = lt.long_text, reply->rb_list[1].order_list[x].
     order_mnemonic = o.order_mnemonic, locval = locateval(idx2,1,order_comment_flat_rec->rec_size,oc
      .order_id,order_comment_flat_rec->qual[idx2].order_id),
     reply->rb_list[1].order_list[x].comment_dt_tm = order_comment_flat_rec->qual[locval].
     comment_dt_tm, reply->rb_list[1].order_list[x].comment_tz = order_comment_flat_rec->qual[locval]
     .comment_tz
    FOOT REPORT
     donothing = 0
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"ORDER_COMMENT","GETORDERCOMMENTS",1,0)
 END ;Subroutine
 SUBROUTINE getcedateresult(null)
   CALL log_message("In GetCeDateResult()",log_level_debug)
   SET idxstart = 1
   SET nrecordsize = cdr_entry_flat_rec->rec_size
   SET noptimizedtotal = (ceil((cnvtreal(nrecordsize)/ bind_cnt)) * bind_cnt)
   FOR (i = (nrecordsize+ 1) TO noptimizedtotal)
     SET cdr_entry_flat_rec->qual[i].event_id = cdr_entry_flat_rec->qual[nrecordsize].event_id
     SET cdr_entry_flat_rec->qual[i].code_list = cdr_entry_flat_rec->qual[nrecordsize].code_list
     SET cdr_entry_flat_rec->qual[i].event_list = cdr_entry_flat_rec->qual[nrecordsize].event_list
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     ce_date_result cdr
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (cdr
     WHERE expand(idx,idxstart,((idxstart+ bind_cnt) - 1),cdr.event_id,cdr_entry_flat_rec->qual[idx].
      event_id,
      bind_cnt)
      AND cdr.valid_until_dt_tm >= cnvtdatetime(v_until_dt))
    HEAD cdr.event_id
     do_nothing = 0
    DETAIL
     do_nothing = 0
    FOOT  cdr.event_id
     locval = locateval(idx2,1,cdr_entry_flat_rec->rec_size,cdr.event_id,cdr_entry_flat_rec->qual[
      idx2].event_id)
     WHILE (locval != 0)
       code_list = cdr_entry_flat_rec->qual[locval].code_list, event_list = cdr_entry_flat_rec->qual[
       locval].event_list, x1 = (size(reply->rb_list[1].code_list[code_list].event_list[event_list].
        date_result_list,5)+ 1),
       stat = alterlist(reply->rb_list[1].code_list[code_list].event_list[event_list].
        date_result_list,x1), reply->rb_list[1].code_list[code_list].event_list[event_list].
       date_result_list[x1].result_dt_tm = cdr.result_dt_tm, reply->rb_list[1].code_list[code_list].
       event_list[event_list].date_result_list[x1].result_tz = abs(validate(cdr.result_tz,0))
       IF (validate(cdr.result_tz,0) < 0)
        reply->rb_list[1].code_list[code_list].event_list[event_list].date_result_list[x1].
        result_tz_ind = 1
       ELSE
        reply->rb_list[1].code_list[code_list].event_list[event_list].date_result_list[x1].
        result_tz_ind = 0
       ENDIF
       reply->rb_list[1].code_list[code_list].event_list[event_list].date_result_list[x1].
       result_dt_tm_os = cdr.result_dt_tm_os, reply->rb_list[1].code_list[code_list].event_list[
       event_list].date_result_list[x1].date_type_flag = cdr.date_type_flag, locval = locateval(idx2,
        (locval+ 1),cdr_entry_flat_rec->rec_size,cdr.event_id,cdr_entry_flat_rec->qual[idx2].event_id
        )
     ENDWHILE
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CE_DATE_RESULT","GETCEDATERESULT",1,0)
 END ;Subroutine
 SUBROUTINE getreflabfootnotes(null)
   CALL log_message("In GetRefLabFootnotes()",log_level_debug)
   DECLARE x = i4 WITH noconstant(0), protect
   DECLARE y = i4 WITH noconstant(0), protect
   DECLARE z = i4 WITH noconstant(0), protect
   DECLARE loc_ref = i4 WITH noconstant(0), protect
   SET xmax = value(size(reply->rb_list[1].code_list,5))
   FOR (x = 1 TO xmax)
    SET ymax = value(size(reply->rb_list[1].code_list[x].event_list,5))
    FOR (y = 1 TO ymax)
      IF (locateval(idx2,1,size(temp_request->qual,5),reply->rb_list[1].code_list[x].event_list[y].
       resource_cd,temp_request->qual[idx2].resource_cd,
       reply->rb_list[1].code_list[x].event_list[y].encntr_id,temp_request->qual[idx2].encntr_id)=0)
       SET z += 1
       IF (z > value(size(temp_request->qual,5)))
        SET stat = alterlist(temp_request->qual,(z+ 5))
       ENDIF
       SET temp_request->qual[z].encntr_id = reply->rb_list[1].code_list[x].event_list[y].encntr_id
       SET temp_request->qual[z].resource_cd = reply->rb_list[1].code_list[x].event_list[y].
       resource_cd
      ENDIF
    ENDFOR
   ENDFOR
   SET stat = alterlist(temp_request->qual,z)
   EXECUTE cr_get_reflab_footnote  WITH replace(request,temp_request), replace(reply,temp_reply)
   IF (0 < value(size(temp_reply->qual,5)))
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = value(size(reply->rb_list[1].code_list,5))),
      (dummyt d2  WITH seq = 1),
      (dummyt d3  WITH seq = value(size(temp_reply->qual,5)))
     PLAN (d1
      WHERE maxrec(d2,size(reply->rb_list[1].code_list[d1.seq].event_list,5)))
      JOIN (d2)
      JOIN (d3
      WHERE (temp_reply->qual[d3.seq].resource_cd=reply->rb_list[1].code_list[d1.seq].event_list[d2
      .seq].resource_cd)
       AND (temp_reply->qual[d3.seq].encntr_id=reply->rb_list[1].code_list[d1.seq].event_list[d2.seq]
      .encntr_id))
     DETAIL
      reply->rb_list[1].code_list[d1.seq].event_list[d2.seq].ref_lab_desc = temp_reply->qual[d3.seq].
      ref_lab_description, reply->rb_list[1].code_list[d1.seq].event_list[d2.seq].ref_lab_ind = 1
     WITH nocounter
    ;end select
   ENDIF
 END ;Subroutine
 SUBROUTINE getcespecimencollforlistview(null)
   CALL log_message("In GetCeSpecimenColl()",log_level_debug)
   SET idxstart = 1
   SET nrecordsize = csc_entry_flat_rec->rec_size
   SET noptimizedtotal = (ceil((cnvtreal(nrecordsize)/ bind_cnt)) * bind_cnt)
   FOR (i = (nrecordsize+ 1) TO noptimizedtotal)
     SET csc_entry_flat_rec->qual[i].event_id = csc_entry_flat_rec->qual[nrecordsize].event_id
     SET csc_entry_flat_rec->qual[i].code_list = csc_entry_flat_rec->qual[nrecordsize].code_list
     SET csc_entry_flat_rec->qual[i].event_list = csc_entry_flat_rec->qual[nrecordsize].event_list
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     ce_specimen_coll csc
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (csc
     WHERE expand(idx,idxstart,((idxstart+ bind_cnt) - 1),csc.event_id,csc_entry_flat_rec->qual[idx].
      event_id,
      bind_cnt)
      AND csc.valid_until_dt_tm >= cnvtdatetime(v_until_dt))
    HEAD REPORT
     x1 = 0
    DETAIL
     locval = locateval(idx2,1,csc_entry_flat_rec->rec_size,csc.event_id,csc_entry_flat_rec->qual[
      idx2].event_id)
     WHILE (locval != 0)
       code_list = csc_entry_flat_rec->qual[locval].code_list, event_list = csc_entry_flat_rec->qual[
       locval].event_list, x1 = (size(reply->rb_list[1].code_list[code_list].event_list[event_list].
        listview_info,5)+ 1),
       stat = alterlist(reply->rb_list[1].code_list[code_list].event_list[event_list].listview_info,
        x1), reply->rb_list[1].code_list[code_list].event_list[event_list].listview_info[x1].
       received_dt_tm = csc.recvd_dt_tm, reply->rb_list[1].code_list[code_list].event_list[event_list
       ].listview_info[x1].received_tz = abs(validate(csc.recvd_tz,0)),
       reply->rb_list[1].code_list[code_list].event_list[event_list].listview_info[x1].specimen_type
        = uar_get_code_display(csc.source_type_cd), locval = locateval(idx2,(locval+ 1),
        csc_entry_flat_rec->rec_size,csc.event_id,csc_entry_flat_rec->qual[idx2].event_id)
     ENDWHILE
    FOOT REPORT
     donothing = 0
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CE_SPECIMEN_COLL","GETCESPECIMENCOLL",1,0)
 END ;Subroutine
 SUBROUTINE getecgevents(null)
   CALL log_message("In GetEcgEvents()",log_level_debug)
   DECLARE signed_cd = f8 WITH constant(uar_get_code_by("MEANING",4000341,"SIGNED")), protect
   DECLARE ecg_cd = f8 WITH constant(uar_get_code_by("MEANING",5801,"ECG")), protect
   DECLARE dicom_siuid_cd = f8 WITH constant(uar_get_code_by("MEANING",25,"DICOM_SIUID")), protect
   DECLARE acrnema_cd = f8 WITH constant(uar_get_code_by("MEANING",23,"ACRNEMA")), protect
   DECLARE s_date = vc
   DECLARE e_date = vc
   DECLARE ecg_where_clause = vc
   DECLARE ecg_person_clause = vc
   DECLARE ecg_date_clause = vc
   DECLARE ecg_result_clause = vc
   DECLARE ecg_other_clause = vc
   DECLARE ecg_cnt = i4
   IF (selected_events=1)
    SET ecg_person_clause = build("pce.person_id = ",request->person_id,
     "  and pce.event_id in (select event_id from chart_request_event where",
     " chart_request_id = request->request_id)")
   ELSE
    SET ecg_person_clause = person_clause
   ENDIF
   IF ((request->date_range_ind=1))
    IF ((request->begin_dt_tm > 0))
     SET s_date = "cnvtdatetime(request->begin_dt_tm)"
    ELSE
     SET s_date = "cnvtdatetime('01-JAN-1800 00:00:00.00')"
    ENDIF
    IF ((request->end_dt_tm > 0))
     SET e_date = "cnvtdatetime(request->end_dt_tm)"
    ELSE
     SET e_date = "cnvtdatetime('31-DEC-2100 23:59:59.99')"
    ENDIF
    IF ((request->result_lookup_ind=1))
     SET ecg_date_clause = concat(" (pce.event_end_dt_tm+0 between ",s_date," and ",e_date,")")
    ELSE
     SET ecg_date_clause = concat(" (pce.clinsig_updt_dt_tm+0 between ",s_date," and ",e_date,")")
    ENDIF
   ELSE
    SET ecg_date_clause = "1=1"
   ENDIF
   IF (selected_events=1)
    SET ecg_other_clause = " pce.event_class_cd in (proc_class_cd) and pce.publish_flag = 1"
    SET ecg_result_clause = " pce.result_status_cd in "
   ELSE
    SET ecg_other_clause = " ce.event_class_cd in (doc_class_cd) and ce.publish_flag = 1"
    SET ecg_result_clause = " ce.result_status_cd in "
   ENDIF
   CASE (request->pending_flag)
    OF verified_only:
     SET ecg_result_clause = concat(ecg_result_clause,"(auth_cd, mod_cd, super_cd, alt_cd)")
    OF verified_performed:
     SET ecg_result_clause = concat(ecg_result_clause,
      "(auth_cd, mod_cd, super_cd, alt_cd, inlab_cd, inprog_cd)")
    ELSE
     SET ecg_result_clause = concat(ecg_result_clause,
      "(auth_cd, mod_cd, super_cd, alt_cd, inlab_cd, inprog_cd, trans_cd, unauth_cd)")
   ENDCASE
   IF (selected_events=1)
    SET ecg_result_clause = concat(ecg_result_clause,
     " and pce.event_class_cd != placehold_class_cd and pce.record_status_cd != del_stat_cd")
   ELSE
    SET ecg_result_clause = concat(ecg_result_clause,
     " and ce.event_class_cd != placehold_class_cd and ce.record_status_cd != del_stat_cd")
   ENDIF
   SET ecg_other_clause = concat(trim(ecg_other_clause)," and ",trim(ecg_result_clause))
   SET ecg_where_clause = concat(trim(ecg_person_clause)," and ",trim(ecg_other_clause))
   CALL log_message(concat("ecg_where_clause = ",trim(ecg_where_clause)),log_level_debug)
   CALL log_message(concat("ecg_date_clause = ",trim(ecg_date_clause)),log_level_debug)
   SELECT
    IF (selected_events=1)DISTINCT INTO "nl:"
     ce.parent_event_id, ce.event_id
     FROM clinical_event pce,
      clinical_event ce,
      cv_proc cv,
      ce_blob_result cbr
     PLAN (pce
      WHERE parser(ecg_where_clause)
       AND pce.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100")
       AND parser(ecg_date_clause))
      JOIN (ce
      WHERE ce.parent_event_id=pce.event_id
       AND ce.event_class_cd=doc_class_cd
       AND ce.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100"))
      JOIN (cv
      WHERE cv.group_event_id=pce.event_id
       AND cv.proc_status_cd=signed_cd
       AND cv.activity_subtype_cd=ecg_cd)
      JOIN (cbr
      WHERE cbr.event_id=ce.event_id
       AND cbr.storage_cd=dicom_siuid_cd
       AND cbr.format_cd=acrnema_cd
       AND cbr.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100"))
     ORDER BY ce.parent_event_id, ce.event_id
    ELSE DISTINCT INTO "nl:"
     ce.parent_event_id, ce.event_id
     FROM clinical_event ce,
      clinical_event pce,
      cv_proc cv,
      ce_blob_result cbr
     PLAN (ce
      WHERE parser(ecg_where_clause)
       AND ce.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100"))
      JOIN (pce
      WHERE pce.event_id=ce.parent_event_id
       AND pce.event_class_cd=proc_class_cd
       AND pce.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100")
       AND parser(ecg_date_clause))
      JOIN (cv
      WHERE cv.group_event_id=pce.event_id
       AND cv.proc_status_cd=signed_cd
       AND cv.activity_subtype_cd=ecg_cd)
      JOIN (cbr
      WHERE cbr.event_id=ce.event_id
       AND cbr.storage_cd=dicom_siuid_cd
       AND cbr.format_cd=acrnema_cd
       AND cbr.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100"))
     ORDER BY ce.parent_event_id, ce.event_id
    ENDIF
    HEAD REPORT
     ecg_cnt = 0
    DETAIL
     ecg_cnt += 1, tempeventsize = size(temp_events->qual,5), stat = alterlist(temp_events->qual,(
      tempeventsize+ 1)),
     tempflatcount = size(flat_rec->qual,5), stat = alterlist(flat_rec->qual,(tempflatcount+ 1)),
     temp_events->qual[(tempeventsize+ 1)].event_id = ce.event_id,
     temp_events->qual[(tempeventsize+ 1)].catalog_cd = ce.catalog_cd, temp_events->qual[(
     tempeventsize+ 1)].event_cd = ce.event_cd, temp_events->qual[(tempeventsize+ 1)].dontcare = 0,
     flat_rec->qual[(tempflatcount+ 1)].event_id = ce.event_id
    WITH nocounter
   ;end select
   CALL echo(concat("ecg_cnt = ",cnvtstring(ecg_cnt)))
 END ;Subroutine
#exit_script
 CALL log_message("Exiting script: cp_get_event_list",log_level_debug)
END GO
