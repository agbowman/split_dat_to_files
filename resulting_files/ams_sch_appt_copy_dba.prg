CREATE PROGRAM ams_sch_appt_copy:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "copy appt" = "",
  "Directory" = "",
  "Pass Input File Name" = ""
  WITH outdev, copy_appt, directory,
  inputfile
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 DECLARE serrmsg = vc WITH protect, noconstant("")
 DECLARE ierrcode = i2 WITH protect, noconstant(0)
 DECLARE bamsassociate = i2 WITH protect, noconstant(false)
 DECLARE smessage = vc WITH protect, noconstant("")
 FREE RECORD rdata
 RECORD rdata(
   1 qual_knt = i4
   1 qual[*]
     2 object_name = vc
     2 user_name = vc
     2 compiled_dt_tm = vc
     2 source_name = vc
 )
 EXECUTE ams_define_toolkit_common
 SET bamsassociate = isamsuser(reqinfo->updt_id)
 IF ( NOT (bamsassociate))
  SET failed = exe_error
  SET serrmsg = "User must be a Cerner AMS associate to run this program from Explorer Menu"
  GO TO exit_script
 ENDIF
 FREE RECORD mnem_request
 RECORD mnem_request(
   1 case_sensitive_ind = i2
   1 mnem = vc
   1 filter_by_type_ind = i2
   1 appt_type_flag = i2
   1 grp_flag = i2
   1 product_ind = i2
   1 product_cd = f8
   1 product_meaning = c12
   1 exclusive_logical_domain_ind = i2
 )
 FREE RECORD mnem_reply
 RECORD mnem_reply(
   1 qual_cnt = i4
   1 qual[*]
     2 appt_type_cd = f8
     2 appt_synonym_cd = f8
     2 mnem = vc
     2 allow_selection_flag = i2
     2 info_sch_text_id = f8
     2 info_sch_text = vc
     2 info_sch_text_updt_cnt = i4
     2 updt_cnt = i4
     2 active_ind = i2
     2 candidate_id = f8
     2 primary_ind = i2
     2 order_sentence_id = f8
     2 oe_format_id = f8
     2 appt_type_flag = i2
     2 granted_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD appt_by_id_request
 RECORD appt_by_id_request(
   1 qual[*]
     2 appt_type_cd = f8
 )
 FREE RECORD appt_by_id_reply
 RECORD appt_by_id_reply(
   1 qual_cnt = i4
   1 catalog_type_cd = f8
   1 catalog_type_meaning = vc
   1 mnemonic_type_cd = f8
   1 mnemonic_type_meaning = vc
   1 qual[*]
     2 appt_type_cd = f8
     2 appt_type_flag = i2
     2 desc = vc
     2 oe_format_id = f8
     2 info_sch_text_id = f8
     2 info_sch_text = vc
     2 info_sch_text_updt_cnt = i4
     2 recur_cd = f8
     2 recur_meaning = vc
     2 person_accept_cd = f8
     2 person_accept_meaning = vc
     2 grp_resource_cd = f8
     2 grp_resource_mnem = vc
     2 updt_cnt = i4
     2 active_ind = i2
     2 candidate_id = f8
     2 object_cnt = i4
     2 object[*]
       3 assoc_type_cd = f8
       3 sch_object_id = f8
       3 object_mnemonic = vc
       3 assoc_type_meaning = c12
       3 assoc_type_disp = vc
       3 seq_nbr = i4
       3 candidate_id = f8
       3 active_ind = i2
       3 updt_cnt = i4
     2 routing_cnt = i4
     2 routing[*]
       3 object_mnemonic = vc
       3 location_cd = f8
       3 location_meaning = c30
       3 location_disp = vc
       3 sch_action_cd = f8
       3 sch_action_disp = vc
       3 seq_nbr = i4
       3 action_meaning = c12
       3 beg_units = i4
       3 beg_units_cd = f8
       3 beg_units_meaning = c12
       3 beg_units_disp = vc
       3 end_units = i4
       3 end_units_cd = f8
       3 end_units_meaning = c12
       3 end_units_disp = vc
       3 routing_table = c32
       3 routing_id = f8
       3 routing_meaning = c12
       3 candidate_id = f8
       3 active_ind = i2
       3 updt_cnt = i4
       3 sch_flex_id = f8
     2 catalog_qual_cnt = i4
     2 catalog_qual[*]
       3 child_cd = f8
       3 child_meaning = c30
       3 child_disp = vc
       3 updt_cnt = i4
       3 active_ind = i2
       3 candidate_id = f8
     2 mnemonic_qual_cnt = i4
     2 mnemonic_qual[*]
       3 child_cd = f8
       3 child_meaning = c30
       3 child_disp = vc
       3 updt_cnt = i4
       3 active_ind = i2
       3 candidate_id = f8
     2 syn_cnt = i4
     2 syn[*]
       3 appt_synonym_cd = f8
       3 mnem = vc
       3 allow_selection_flag = i2
       3 info_sch_text_id = f8
       3 info_sch_text = vc
       3 info_sch_text_updt_cnt = i4
       3 updt_cnt = i4
       3 active_ind = i2
       3 candidate_id = f8
       3 primary_ind = i2
       3 order_sentence_id = f8
     2 states_cnt = i4
     2 states[*]
       3 sch_state_cd = f8
       3 disp_scheme_id = f8
       3 state_meaning = c12
       3 updt_cnt = i4
       3 active_ind = i2
       3 candidate_id = f8
     2 locs_cnt = i4
     2 locs[*]
       3 location_cd = f8
       3 location_disp = c40
       3 location_desc = c60
       3 location_mean = c12
       3 sch_flex_id = f8
       3 res_list_id = f8
       3 res_list_mnem = vc
       3 grp_res_list_id = f8
       3 grp_res_list_mnem = vc
       3 updt_cnt = i4
       3 active_ind = i2
       3 candidate_id = f8
     2 option_cnt = i4
     2 option[*]
       3 sch_option_cd = f8
       3 option_disp = c40
       3 option_mean = c12
       3 updt_cnt = i4
       3 active_ind = i2
       3 candidate_id = f8
     2 product_cnt = i4
     2 product[*]
       3 product_cd = f8
       3 product_disp = c40
       3 product_mean = c12
       3 updt_cnt = i4
       3 active_ind = i2
       3 candidate_id = f8
     2 text_cnt = i4
     2 text[*]
       3 text_link_id = f8
       3 location_cd = f8
       3 location_meaning = vc
       3 location_display = vc
       3 text_type_cd = f8
       3 text_type_meaning = vc
       3 sub_text_cd = f8
       3 sub_text_meaning = vc
       3 text_accept_cd = f8
       3 text_accept_meaning = vc
       3 template_accept_cd = f8
       3 template_accept_meaning = vc
       3 sch_action_cd = f8
       3 action_meaning = vc
       3 expertise_level = i4
       3 lapse_units = i4
       3 lapse_units_cd = f8
       3 lapse_units_meaning = vc
       3 updt_cnt = i4
       3 active_ind = i2
       3 candidate_id = f8
       3 sub_list_cnt = i4
       3 sub_list[*]
         4 template_id = f8
         4 seq_nbr = i4
         4 mnem = vc
         4 required_ind = i2
         4 updt_cnt = i4
         4 active_ind = i2
         4 candidate_id = f8
         4 sch_flex_id = f8
         4 temp_flex_cnt = i4
         4 temp_flex[*]
           5 parent2_table = c32
           5 parent2_id = f8
           5 flex_seq_nbr = i4
           5 updt_cnt = i4
           5 active_ind = i2
           5 candidate_id = f8
           5 mnemonic = vc
     2 order_cnt = i4
     2 orders[*]
       3 required_ind = i2
       3 seq_nbr = i4
       3 synonym_id = f8
       3 alt_sel_category_id = f8
       3 mnemonic = vc
       3 catalog_cd = f8
       3 catalog_type_cd = f8
       3 activity_type_cd = f8
       3 mnemonic_type_cd = f8
       3 oe_format_id = f8
       3 order_sentence_id = f8
       3 orderable_type_flag = i2
       3 ref_text_mask = i4
       3 hide_flag = i2
       3 updt_cnt = i4
       3 active_ind = i2
       3 candidate_id = f8
     2 comp_cnt = i4
     2 comp[*]
       3 appt_type_cd = f8
       3 location_cd = f8
       3 location_disp = vc
       3 location_meaning = vc
       3 seq_nbr = i4
       3 comp_appt_synonym = vc
       3 comp_appt_synonym_cd = f8
       3 comp_appt_type_cd = f8
       3 offset_from_cd = f8
       3 offset_from_meaning = c12
       3 offset_type_cd = f8
       3 offset_type_meaning = c12
       3 offset_seq_nbr = i4
       3 offset_beg_units = i4
       3 offset_beg_units_cd = f8
       3 offset_beg_units_meaning = vc
       3 offset_end_units = i4
       3 offset_end_units_cd = f8
       3 offset_end_units_meaning = vc
       3 updt_cnt = i4
       3 active_ind = i2
       3 candidate_id = f8
       3 comp_loc_cnt = i4
       3 comp_loc[*]
         4 comp_location_cd = f8
         4 comp_location_disp = vc
         4 comp_location_desc = vc
         4 comp_location_mean = vc
         4 updt_cnt = i4
         4 active_ind = i2
         4 candidate_id = f8
     2 inter_cnt = i4
     2 inter[*]
       3 location_cd = f8
       3 inter_type_cd = f8
       3 inter_type_meaning = vc
       3 seq_group_id = f8
       3 mnemonic = vc
       3 updt_cnt = i4
       3 active_ind = i2
       3 candidate_id = f8
     2 dup_cnt = i4
     2 dup[*]
       3 dup_type_cd = f8
       3 dup_disp = c40
       3 dup_mean = c12
       3 location_cd = f8
       3 location_disp = c40
       3 location_mean = c12
       3 seq_nbr = i4
       3 beg_units = i4
       3 beg_units_cd = f8
       3 beg_units_meaning = c12
       3 beg_units_disp = c40
       3 end_units = i4
       3 end_units_cd = f8
       3 end_units_meaning = c12
       3 end_units_disp = c40
       3 dup_action_cd = f8
       3 dup_action_meaning = c12
       3 holiday_weekend_flag = i2
       3 updt_cnt = i4
       3 candidate_id = f8
       3 active_ind = i2
     2 nomen_cnt = i4
     2 nomen[*]
       3 appt_nomen_cd = f8
       3 appt_nomen_disp = c40
       3 appt_nomen_mean = c12
       3 updt_cnt = i4
       3 candidate_id = f8
       3 active_ind = i2
       3 nomen_list_cnt = i4
       3 nomen_list[*]
         4 seq_nbr = i4
         4 beg_nomenclature_id = f8
         4 end_nomenclature_id = f8
         4 source_string = vc
         4 updt_cnt = i4
         4 candidate_id = f8
         4 active_ind = i2
     2 notify_cnt = i4
     2 notify[*]
       3 location_cd = f8
       3 sch_flex_id = f8
       3 location_disp = c40
       3 sch_action_cd = f8
       3 action_mean = c12
       3 seq_nbr = i4
       3 beg_units = i4
       3 beg_units_cd = f8
       3 beg_units_meaning = c12
       3 end_units = i4
       3 end_units_cd = f8
       3 end_units_meaning = c12
       3 sch_route_id = f8
       3 route_mnemonic = vc
       3 updt_cnt = i4
       3 candidate_id = f8
       3 active_ind = i2
     2 appt_action_cnt = i4
     2 appt_action[*]
       3 location_cd = f8
       3 location_disp = vc
       3 location_mean = c30
       3 sch_action_cd = f8
       3 sch_action_disp = vc
       3 sch_action_mean = c12
       3 seq_nbr = i4
       3 child_appt_syn_cd = f8
       3 child_appt_syn_disp = vc
       3 child_appt_syn_mean = vc
       3 sch_flex_id = f8
       3 candidate_id = f8
       3 active_ind = i2
       3 updt_cnt = i4
       3 offset_beg_units = i4
       3 offset_beg_units_cd = f8
       3 offset_beg_units_disp = vc
       3 offset_beg_units_mean = c12
       3 offset_end_units = i4
       3 offset_end_units_cd = f8
       3 offset_end_units_disp = vc
       3 offset_end_units_mean = c12
     2 grp_prompt_cd = f8
     2 grp_prompt_meaning = vc
     2 rel_appt_syn_qual_cnt = i4
     2 rel_appt_syn_qual[*]
       3 appt_synonym_cd = f8
       3 mnem = vc
       3 allow_selection_flag = i2
       3 info_sch_text_id = f8
       3 info_sch_text = vc
       3 info_sch_text_updt_cnt = i4
       3 updt_cnt = i4
       3 active_ind = i2
       3 candidate_id = f8
       3 primary_ind = i2
       3 order_sentence_id = f8
       3 sch_appt_type_syn_r_id = f8
       3 appt_type_cd = f8
       3 rel_syn_type_cd = f8
       3 default_ind = i2
     2 rel_med_svc_cnt = i4
     2 rel_med_svc_qual[*]
       3 med_service_id = f8
       3 med_service_cd = f8
       3 med_service_disp = vc
       3 med_service_mean = vc
       3 updt_cnt = i4
       3 active_ind = i2
       3 candidate_id = f8
       3 sch_action_cd = f8
     2 rel_enc_type_cnt = i4
     2 rel_enc_type_qual[*]
       3 encntr_type_id = f8
       3 encntr_type_cd = f8
       3 encntr_type_disp = vc
       3 encntr_type_mean = vc
       3 updt_cnt = i4
       3 active_ind = i2
       3 candidate_id = f8
       3 sch_action_cd = f8
       3 seq_nbr = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD final_result
 RECORD final_result(
   1 qual[*]
     2 appt_name = vc
     2 added = i2
 )
 SET mnem_request->mnem =  $COPY_APPT
 EXECUTE sch_get_appt_type_by_mnem  WITH replace("REQUEST",mnem_request), replace("REPLY",mnem_reply)
 SET stat = alterlist(appt_by_id_request->qual,1)
 SET appt_by_id_request->qual[1].appt_type_cd = mnem_reply->qual[1].appt_type_cd
 EXECUTE sch_get_appt_type_by_id  WITH replace("REQUEST",appt_by_id_request), replace("REPLY",
  appt_by_id_reply)
 SET path = value(logical( $DIRECTORY))
 SET infile =  $INPUTFILE
 SET file_path = build(path,":",infile)
 DEFINE rtl2 value(file_path)
 RECORD file_content(
   1 line[*]
     2 col[*]
       3 value = vc
     2 req_list[*]
       3 request_type = vc
       3 request_loc_list[*]
         4 value = vc
     2 inst_prep_list[*]
       3 value = vc
 )
 DECLARE parse_req_list(row_count=i2,req_list_content=vc,file_content=vc(ref)) = null
 DECLARE parse_inst_preparation(row_count=i2,inst_prep_list_content=vc,file_content=vc(ref)) = null
 DECLARE sub_content = vc
 SELECT
  r.line
  FROM rtl2t r
  HEAD REPORT
   row_count = 0, stat = alterlist(file_content->line,10)
  DETAIL
   line1 = r.line
   IF (size(trim(line1),1) > 0)
    row_count = (row_count+ 1)
    IF (mod(row_count,10)=1
     AND row_count > 10)
     stat = alterlist(file_content->line,(row_count+ 9))
    ENDIF
    stat = alterlist(file_content->line[row_count].col,10), count = 0
    WHILE (size(trim(line1),1) > 0)
     count = (count+ 1),
     IF (count=8)
      CALL parse_inst_preparation(row_count,line1,file_content)
     ELSEIF (count=7)
      position = findstring("]",line1,1,0)
      IF (position > 0)
       req_list_content = substring(2,(position - 2),line1), line1 = substring((position+ 2),size(
         trim(line1),1),line1),
       CALL parse_req_list(row_count,req_list_content,file_content)
      ENDIF
     ELSE
      IF (count > 10
       AND mod(count,10)=1)
       stat = alterlist(file_content->line[row_count].col,(count+ 9))
      ENDIF
      position = findstring(",",line1,1,0)
      IF (position > 0)
       file_content->line[row_count].col[count].value = substring(1,(position - 1),line1), line1 =
       substring((position+ 1),size(trim(line1),1),line1)
      ELSE
       file_content->line[row_count].col[count].value = line1, line1 = ""
      ENDIF
     ENDIF
    ENDWHILE
    stat = alterlist(file_content->line[row_count].col,count)
   ENDIF
  FOOT REPORT
   stat = alterlist(file_content->line,row_count)
  WITH format, separator = " "
 ;end select
 SUBROUTINE parse_req_list(row_count,req_list_content,file_content)
   SET req_count = 0
   SET stat = alterlist(file_content->line[row_count].req_list,10)
   WHILE (size(trim(req_list_content),1) > 0)
     SET req_count = (req_count+ 1)
     IF (req_count > 10
      AND mod(req_count,10)=1)
      SET stat = alterlist(file_content->line[row_count].req_list,(req_count+ 9))
     ENDIF
     SET close_position = findstring(")",req_list_content,2,0)
     SET sub_content = substring(2,(close_position - 2),req_list_content)
     SET req_list_content = substring((close_position+ 1),size(trim(req_list_content),1),
      req_list_content)
     SET colen_position = findstring(":",sub_content,1,0)
     SET file_content->line[row_count].req_list[req_count].request_type = substring(1,(colen_position
       - 1),sub_content)
     SET sub_content = substring((colen_position+ 1),size(trim(sub_content),1),sub_content)
     SET req_list_count = 0
     SET stat = alterlist(file_content->line[row_count].req_list[req_count].request_loc_list,10)
     WHILE (size(trim(sub_content),1) > 0)
       SET req_list_count = (req_list_count+ 1)
       IF (req_list_count > 10
        AND mod(req_list_count,10)=1)
        SET stat = alterlist(file_content->line[row_count].req_list[req_count].request_loc_list,(
         req_list_count+ 9))
       ENDIF
       SET position = findstring(",",sub_content,1,0)
       IF (position > 0)
        SET file_content->line[row_count].req_list[req_count].request_loc_list[req_list_count].value
         = trim(substring(1,(position - 1),sub_content),3)
        SET sub_content = substring((position+ 1),size(trim(sub_content),1),sub_content)
       ELSE
        SET file_content->line[row_count].req_list[req_count].request_loc_list[req_list_count].value
         = trim(sub_content,3)
        SET sub_content = ""
       ENDIF
     ENDWHILE
     SET stat = alterlist(file_content->line[row_count].req_list[req_count].request_loc_list,
      req_list_count)
   ENDWHILE
   SET stat = alterlist(file_content->line[row_count].req_list,req_count)
 END ;Subroutine
 SUBROUTINE parse_inst_preparation(row_count,inst_prep_list_content,file_content)
   SET prep_count = 0
   SET stat = alterlist(file_content->line[row_count].inst_prep_list,10)
   SET close_position = findstring(")",inst_prep_list_content,2,0)
   SET sub_content = substring(2,(close_position - 2),inst_prep_list_content)
   WHILE (size(trim(sub_content),1) > 0)
     SET prep_count = (prep_count+ 1)
     IF (prep_count > 10
      AND mod(prep_count,10)=1)
      SET stat = alterlist(file_content->line[row_count].inst_prep_list,(prep_count+ 9))
     ENDIF
     SET position = findstring(",",sub_content,1,0)
     IF (position > 0)
      SET file_content->line[row_count].inst_prep_list[prep_count].value = trim(substring(1,(position
         - 1),sub_content),3)
      SET sub_content = substring((position+ 1),size(trim(sub_content),1),sub_content)
     ELSE
      SET file_content->line[row_count].inst_prep_list[prep_count].value = trim(sub_content,3)
      SET sub_content = ""
     ENDIF
   ENDWHILE
   SET stat = alterlist(file_content->line[row_count].inst_prep_list,prep_count)
 END ;Subroutine
 SET stat = alterlist(final_result->qual,value(size(file_content->line,5)))
 FOR (record_cnt = 1 TO value(size(file_content->line,5)))
   IF (value(size(file_content->line[record_cnt].col,5)) > 2)
    FREE RECORD add_appt_request
    RECORD add_appt_request(
      1 call_echo_ind = i2
      1 allow_partial_ind = i2
      1 qual[*]
        2 oe_format_id = f8
        2 description = vc
        2 info_sch_text = vc
        2 appt_type_flag = i2
        2 recur_cd = f8
        2 recur_meaning = c12
        2 person_accept_cd = f8
        2 person_accept_meaning = c12
        2 candidate_id = f8
        2 active_ind = i2
        2 active_status_cd = f8
        2 appt_object_partial_ind = i2
        2 appt_object_qual[*]
          3 assoc_type_cd = f8
          3 sch_object_id = f8
          3 assoc_type_meaning = c12
          3 seq_nbr = i4
          3 candidate_id = f8
          3 active_ind = i2
          3 active_status_cd = f8
        2 appt_routing_partial_ind = i2
        2 appt_routing_qual[*]
          3 location_cd = f8
          3 sch_action_cd = f8
          3 seq_nbr = i4
          3 action_meaning = c12
          3 beg_units = i4
          3 beg_units_cd = f8
          3 beg_units_meaning = c12
          3 end_units = i4
          3 end_units_cd = f8
          3 end_units_meaning = c12
          3 routing_table = c32
          3 routing_id = f8
          3 routing_meaning = c12
          3 candidate_id = f8
          3 active_ind = i2
          3 active_status_cd = f8
          3 sch_flex_id = f8
        2 filter_partial_ind = i2
        2 filter[*]
          3 free_type_cd = f8
          3 child_cd = f8
          3 free_type_meaning = c12
          3 child_type_meaning = c12
          3 candidate_id = f8
          3 active_ind = i2
          3 active_status_cd = f8
        2 syn_partial_ind = i2
        2 syn[*]
          3 mnemonic = vc
          3 allow_selection_flag = i2
          3 info_sch_text = vc
          3 primary_ind = i2
          3 order_sentence_id = f8
          3 candidate_id = f8
          3 active_ind = i2
          3 active_status_cd = f8
          3 new_syn_ref_id = f8
        2 rel_appt_syn_partial_ind = i2
        2 rel_appt_syn_qual[*]
          3 sch_appt_type_syn_r_id = f8
          3 appt_type_cd = f8
          3 appt_rel_syn_cd = f8
          3 rel_syn_type_cd = f8
          3 default_ind = i2
          3 candidate_id = f8
          3 active_status_cd = f8
          3 active_ind = i2
          3 new_syn_ref_id = f8
        2 state_partial_ind = i2
        2 state[*]
          3 sch_state_cd = f8
          3 disp_scheme_id = f8
          3 state_meaning = c12
          3 candidate_id = f8
          3 active_ind = i2
          3 active_status_cd = f8
        2 loc_partial_ind = i2
        2 loc[*]
          3 location_cd = f8
          3 candidate_id = f8
          3 res_list_id = f8
          3 sch_flex_id = f8
          3 active_ind = i2
          3 active_status_cd = f8
          3 grp_res_list_id = f8
        2 option_partial_ind = i2
        2 option[*]
          3 sch_option_cd = f8
          3 option_meaning = c12
          3 candidate_id = f8
          3 active_ind = i2
          3 active_status_cd = f8
        2 product_partial_ind = i2
        2 product[*]
          3 product_cd = f8
          3 product_meaning = c12
          3 candidate_id = f8
          3 active_ind = i2
          3 active_status_cd = f8
        2 text_partial_ind = i2
        2 text[*]
          3 text_link_id = f8
          3 parent_table = c32
          3 parent_id = f8
          3 parent2_table = c32
          3 parent2_id = f8
          3 parent3_table = c32
          3 parent3_id = f8
          3 text_type_cd = f8
          3 sub_text_cd = f8
          3 text_type_meaning = c12
          3 sub_text_meaning = c12
          3 text_accept_cd = f8
          3 text_accept_meaning = c12
          3 template_accept_cd = f8
          3 template_accept_meaning = c12
          3 parent_meaning = c12
          3 parent2_meaning = c12
          3 parent3_meaning = c12
          3 lapse_units = i4
          3 lapse_units_cd = f8
          3 lapse_units_meaning = c12
          3 expertise_level = i4
          3 modified_dt_tm = dq8
          3 candidate_id = f8
          3 active_ind = i2
          3 active_status_cd = f8
          3 sub_list_partial_ind = i2
          3 sub_list[*]
            4 parent_table = c32
            4 parent_id = f8
            4 required_ind = i2
            4 seq_nbr = i4
            4 template_id = f8
            4 candidate_id = f8
            4 active_ind = i2
            4 active_status_cd = f8
            4 sch_flex_id = f8
            4 temp_flex_partial_ind = i2
            4 temp_flex[*]
              5 parent2_table = c32
              5 parent2_id = f8
              5 flex_seq_nbr = i4
              5 candidate_id = f8
              5 active_ind = i2
              5 active_status_cd = f8
        2 ord_partial_ind = i2
        2 ord[*]
          3 required_ind = i2
          3 seq_nbr = i4
          3 alt_sel_category_id = f8
          3 synonym_id = f8
          3 candidate_id = f8
          3 active_ind = i2
          3 active_status_cd = f8
        2 dup_partial_ind = i2
        2 dup[*]
          3 dup_type_cd = f8
          3 location_cd = f8
          3 seq_nbr = i4
          3 dup_type_meaning = c12
          3 beg_units = i4
          3 beg_units_cd = f8
          3 beg_units_meaning = c12
          3 end_units = i4
          3 end_units_cd = f8
          3 end_units_meaning = c12
          3 dup_action_cd = f8
          3 dup_action_meaning = c12
          3 holiday_weekend_flag = i2
          3 candidate_id = f8
          3 active_ind = i2
          3 active_status_cd = f8
        2 comp_partial_ind = i2
        2 comp[*]
          3 location_cd = f8
          3 seq_nbr = i4
          3 comp_appt_synonym_cd = f8
          3 comp_appt_type_cd = f8
          3 offset_from_cd = f8
          3 offset_from_meaning = c12
          3 offset_type_cd = f8
          3 offset_type_meaning = c12
          3 offset_seq_nbr = i4
          3 offset_beg_units = i4
          3 offset_beg_units_cd = f8
          3 offset_beg_units_meaning = c12
          3 offset_end_units = i4
          3 offset_end_units_cd = f8
          3 offset_end_units_meaning = c12
          3 candidate_id = f8
          3 active_ind = i2
          3 active_status_cd = f8
          3 comp_loc_partial_ind = i2
          3 comp_loc[*]
            4 comp_location_cd = f8
            4 candidate_id = f8
            4 active_ind = i2
            4 active_status_cd = f8
        2 nomen_partial_ind = i2
        2 nomen[*]
          3 appt_nomen_cd = f8
          3 appt_nomen_meaning = c12
          3 candidate_id = f8
          3 active_ind = i2
          3 active_status_cd = f8
          3 nomen_list_partial_ind = i2
          3 nomen_list[*]
            4 seq_nbr = i4
            4 beg_nomenclature_id = f8
            4 end_nomenclature_id = f8
            4 candidate_id = f8
            4 active_ind = i2
            4 active_status_cd = f8
        2 notify_partial_ind = i2
        2 notify[*]
          3 location_cd = f8
          3 sch_action_cd = f8
          3 seq_nbr = i4
          3 action_meaning = c12
          3 beg_units = i4
          3 beg_units_cd = f8
          3 beg_units_meaning = c12
          3 end_units = i4
          3 end_units_cd = f8
          3 end_units_meaning = c12
          3 sch_route_id = f8
          3 candidate_id = f8
          3 active_ind = i2
          3 active_status_cd = f8
          3 sch_flex_id = f8
        2 inter_partial_ind = i2
        2 inter[*]
          3 location_cd = f8
          3 inter_type_cd = f8
          3 seq_group_id = f8
          3 inter_type_meaning = c12
          3 candidate_id = f8
          3 active_ind = i2
          3 active_status_cd = f8
        2 grp_resource_mnem = vc
        2 appt_action_partial_ind = i2
        2 appt_action[*]
          3 location_cd = f8
          3 sch_action_cd = f8
          3 seq_nbr = i4
          3 action_meaning = c12
          3 child_appt_syn_cd = f8
          3 offset_beg_units = i4
          3 offset_beg_units_cd = f8
          3 offset_beg_units_meaning = c12
          3 offset_end_units = i4
          3 offset_end_units_cd = f8
          3 offset_end_units_meaning = c12
          3 candidate_id = f8
          3 active_ind = i2
          3 active_status_cd = f8
          3 sch_flex_id = f8
        2 grp_prompt_cd = f8
        2 grp_prompt_meaning = vc
    )
    FREE RECORD add_appt_reply
    RECORD add_appt_reply(
      1 qual_cnt = i4
      1 qual[*]
        2 appt_type_cd = f8
        2 info_sch_text_id = f8
        2 candidate_id = f8
        2 status = i4
        2 appt_object_qual_cnt = i4
        2 appt_object_qual[*]
          3 candidate_id = f8
          3 status = i2
        2 appt_routing_qual_cnt = i4
        2 appt_routing_qual[*]
          3 candidate_id = f8
          3 status = i2
        2 filter_qual_cnt = i4
        2 filter[*]
          3 candidate_id = f8
          3 status = i2
        2 syn_qual_cnt = i4
        2 syn[*]
          3 appt_synonym_cd = f8
          3 info_sch_text_id = f8
          3 candidate_id = f8
          3 status = i2
        2 rel_appt_syn_qual_cnt = i2
        2 rel_appt_syn_qual[*]
          3 sch_appt_type_syn_r_id = f8
          3 candidate_id = f8
          3 status = i4
        2 state_qual_cnt = i4
        2 state[*]
          3 candidate_id = f8
          3 status = i2
        2 loc_qual_cnt = i4
        2 loc[*]
          3 candidate_id = f8
          3 status = i2
        2 option_qual_cnt = i4
        2 option[*]
          3 candidate_id = f8
          3 status = i2
        2 product_qual_cnt = i4
        2 product[*]
          3 candidate_id = f8
          3 status = i2
        2 text_qual_cnt = i4
        2 text[*]
          3 candidate_id = f8
          3 status = i2
          3 sub_list_cnt = i4
          3 sub_list[*]
            4 candidate_id = f8
            4 status = i2
            4 temp_flex_cnt = i4
            4 temp_flex[*]
              5 candidate_id = f8
              5 status = i2
        2 ord_qual_cnt = i4
        2 ord[*]
          3 candidate_id = f8
          3 status = i2
        2 dup_qual_cnt = i4
        2 dup[*]
          3 candidate_id = f8
          3 status = i2
        2 comp_qual_cnt = i4
        2 comp[*]
          3 candidate_id = f8
          3 status = i2
          3 comp_loc_qual_cnt = i4
          3 comp_loc[*]
            4 candidate_id = f8
            4 status = i2
        2 nomen_qual_cnt = i4
        2 nomen[*]
          3 candidate_id = f8
          3 status = i2
          3 nomen_list_qual_cnt = i4
          3 nomen_list[*]
            4 candidate_id = f8
            4 status = i2
        2 notify_qual_cnt = i4
        2 notify[*]
          3 candidate_id = f8
          3 status = i2
        2 inter_qual_cnt = i4
        2 inter[*]
          3 candidate_id = f8
          3 status = i2
        2 grp_resource_cd = f8
        2 appt_action_cnt = i4
        2 appt_action[*]
          3 candidate_id = f8
          3 status = i2
      1 status_data
        2 status = c1
        2 subeventstatus[1]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
    )
    SET add_appt_request->call_echo_ind = false
    SET add_appt_request->allow_partial_ind = false
    SET stat = alterlist(add_appt_request->qual,1)
    SELECT
     oef.oe_format_id
     FROM order_entry_format oef
     WHERE (oef.oe_format_name=file_content->line[record_cnt].col[4].value)
     DETAIL
      add_appt_request->qual[1].oe_format_id = oef.oe_format_id
     WITH nocounter
    ;end select
    SET add_appt_request->qual[1].description = file_content->line[record_cnt].col[2].value
    SET add_appt_request->qual[1].info_sch_text = file_content->line[record_cnt].col[3].value
    SET add_appt_request->qual[1].grp_resource_mnem = file_content->line[record_cnt].col[1].value
    SET add_appt_request->qual[1].appt_type_flag = 0
    SET add_appt_request->qual[1].recur_cd = appt_by_id_reply->qual[1].recur_cd
    SET add_appt_request->qual[1].recur_meaning = appt_by_id_reply->qual[1].recur_meaning
    SET add_appt_request->qual[1].person_accept_cd = appt_by_id_reply->qual[1].person_accept_cd
    SET add_appt_request->qual[1].person_accept_meaning = appt_by_id_reply->qual[1].
    person_accept_meaning
    SET add_appt_request->qual[1].candidate_id = 0
    SET add_appt_request->qual[1].active_ind = true
    SET add_appt_request->qual[1].active_status_cd = 0
    SET add_appt_request->qual[1].filter_partial_ind = false
    SET add_appt_request->qual[1].grp_prompt_cd = appt_by_id_reply->qual[1].grp_prompt_cd
    SET add_appt_request->qual[1].grp_prompt_meaning = appt_by_id_reply->qual[1].grp_prompt_meaning
    SET stat = alterlist(add_appt_request->qual[1].syn,1)
    SET add_appt_request->qual[1].syn[1].mnemonic = file_content->line[record_cnt].col[1].value
    SET add_appt_request->qual[1].syn[1].allow_selection_flag = true
    SET add_appt_request->qual[1].syn[1].info_sch_text = ""
    SET add_appt_request->qual[1].syn[1].primary_ind = true
    SET add_appt_request->qual[1].syn[1].order_sentence_id = 0
    SET add_appt_request->qual[1].syn[1].candidate_id = 0
    SET add_appt_request->qual[1].syn[1].active_ind = true
    SET add_appt_request->qual[1].syn[1].active_status_cd = 0
    SET stat = alterlist(add_appt_request->qual[1].rel_appt_syn_qual,value(size(appt_by_id_reply->
       qual[1].rel_appt_syn_qual,5)))
    FOR (i = 1 TO value(size(appt_by_id_reply->qual[1].rel_appt_syn_qual,5)))
      SET add_appt_request->qual[1].rel_appt_syn_qual[i].rel_syn_type_cd = appt_by_id_reply->qual[1].
      rel_appt_syn_qual[i].rel_syn_type_cd
      SET add_appt_request->qual[1].rel_appt_syn_qual[i].active_ind = true
      SET add_appt_request->qual[1].rel_appt_syn_qual[i].appt_type_cd = appt_by_id_reply->qual[1].
      rel_appt_syn_qual[i].appt_type_cd
      SET add_appt_request->qual[1].rel_appt_syn_qual[i].appt_rel_syn_cd = appt_by_id_reply->qual[1].
      rel_appt_syn_qual[i].appt_synonym_cd
    ENDFOR
    SET stat = alterlist(add_appt_request->qual[1].state,value(size(appt_by_id_reply->qual[1].states,
       5)))
    FOR (i = 1 TO value(size(appt_by_id_reply->qual[1].states,5)))
      SET add_appt_request->qual[1].state[i].sch_state_cd = appt_by_id_reply->qual[1].states[i].
      sch_state_cd
      SET add_appt_request->qual[1].state[i].state_meaning = appt_by_id_reply->qual[1].states[i].
      state_meaning
      SET add_appt_request->qual[1].state[i].disp_scheme_id = appt_by_id_reply->qual[1].states[i].
      disp_scheme_id
      SET add_appt_request->qual[1].state[i].active_ind = true
      SET add_appt_request->qual[1].state[i].active_status_cd = 0
    ENDFOR
    SET stat = alterlist(add_appt_request->qual[1].loc,1)
    FOR (i = 1 TO 1)
      SET add_appt_request->qual[1].loc[i].candidate_id = 0
      SET add_appt_request->qual[1].loc[i].active_ind = true
      SET add_appt_request->qual[1].loc[i].active_status_cd = 0
      SET add_appt_request->qual[1].loc[i].location_cd = cnvtreal(file_content->line[record_cnt].col[
       5].value)
      SELECT INTO "nl:"
       rl.res_list_id, rl.mnemonic_key
       FROM sch_resource_list rl
       WHERE rl.mnemonic_key=patstring(cnvtupper(file_content->line[record_cnt].col[6].value))
       DETAIL
        add_appt_request->qual[1].loc[i].res_list_id = rl.res_list_id
       WITH nocounter
      ;end select
    ENDFOR
    SET stat = alterlist(add_appt_request->qual[1].product,value(size(appt_by_id_reply->qual[1].
       product,5)))
    FOR (i = 1 TO value(size(appt_by_id_reply->qual[1].product,5)))
      SET add_appt_request->qual[1].product[i].product_cd = appt_by_id_reply->qual[1].product[i].
      product_cd
      SET add_appt_request->qual[1].product[i].product_meaning = appt_by_id_reply->qual[1].product[i]
      .product_mean
      SET add_appt_request->qual[1].product[i].active_ind = true
    ENDFOR
    SET stat = alterlist(add_appt_request->qual[1].text,1)
    FOR (i = 1 TO 1)
      SET add_appt_request->qual[1].text[i].text_type_cd = uar_get_code_by("DISPLAY_KEY",15149,
       "PREPARATIONS")
      SET add_appt_request->qual[1].text[i].text_type_meaning = "PREAPPT"
      SET add_appt_request->qual[1].text[i].sub_text_cd = uar_get_code_by("DISPLAY_KEY",15589,
       "PREPARATIONS")
      SET add_appt_request->qual[1].text[i].sub_text_meaning = "PREAPPT"
      SET add_appt_request->qual[1].text[i].active_ind = true
      SET add_appt_request->qual[1].text[i].active_status_cd = 0
      SET add_appt_request->qual[1].text[i].parent2_id = cnvtreal(file_content->line[record_cnt].col[
       5].value)
      SET stat = alterlist(add_appt_request->qual[1].text[i].sub_list,value(size(file_content->line[
         record_cnt].inst_prep_list,5)))
      DECLARE j = i2
      FOR (j = 1 TO value(size(file_content->line[record_cnt].inst_prep_list,5)))
        SELECT
         st.template_id
         FROM sch_template st
         WHERE st.mnemonic_key=cnvtupper(file_content->line[record_cnt].inst_prep_list[j].value)
         DETAIL
          add_appt_request->qual[1].text[i].sub_list[j].template_id = st.template_id
         WITH nocounter
        ;end select
        SET add_appt_request->qual[1].text[i].sub_list[j].active_ind = true
        SET add_appt_request->qual[1].text[i].sub_list[j].seq_nbr = j
      ENDFOR
    ENDFOR
    SET text_count = value(size(add_appt_request->qual[1].text,5))
    SET stat = alterlist(add_appt_request->qual[1].text,10)
    FOR (i = text_count TO value(size(appt_by_id_reply->qual[1].text,5)))
      IF ((((appt_by_id_reply->qual[1].text[i].text_type_cd != uar_get_code_by("DISPLAY_KEY",15149,
       "PREPARATIONS"))) OR ((appt_by_id_reply->qual[1].text[i].text_type_cd != uar_get_code_by(
       "DISPLAY_KEY",15149,"POSTAPPOINTMENTINSTRUCTIONS")))) )
       SET text_count = (text_count+ 1)
       IF (text_count > 10
        AND mod(text_count,10)=1)
        SET stat = alterlist(add_appt_request->qual[1].text,(text_count+ 9))
       ENDIF
       SET add_appt_request->qual[1].text[i].text_type_cd = appt_by_id_reply->qual[1].text[i].
       text_type_cd
       SET add_appt_request->qual[1].text[i].text_type_meaning = appt_by_id_reply->qual[1].text[i].
       text_type_meaning
       SET add_appt_request->qual[1].text[i].sub_text_cd = appt_by_id_reply->qual[1].text[i].
       sub_text_cd
       SET add_appt_request->qual[1].text[i].sub_text_meaning = appt_by_id_reply->qual[1].text[i].
       sub_text_meaning
       SET add_appt_request->qual[1].text[i].template_accept_cd = appt_by_id_reply->qual[1].text[i].
       template_accept_cd
       SET add_appt_request->qual[1].text[i].template_accept_meaning = appt_by_id_reply->qual[1].
       text[i].template_accept_meaning
       SET add_appt_request->qual[1].text[i].text_accept_meaning = appt_by_id_reply->qual[1].text[i].
       text_accept_meaning
       SET add_appt_request->qual[1].text[i].text_accept_cd = appt_by_id_reply->qual[1].text[i].
       text_accept_cd
       SET add_appt_request->qual[1].text[i].lapse_units = appt_by_id_reply->qual[1].text[i].
       lapse_units
       SET add_appt_request->qual[1].text[i].lapse_units_cd = appt_by_id_reply->qual[1].text[i].
       lapse_units_cd
       SET add_appt_request->qual[1].text[i].lapse_units_meaning = appt_by_id_reply->qual[1].text[i].
       lapse_units_meaning
       SET add_appt_request->qual[1].text[i].expertise_level = appt_by_id_reply->qual[1].text[i].
       expertise_level
       SET add_appt_request->qual[1].text[i].active_ind = true
       SET add_appt_request->qual[1].text[i].active_status_cd = 0
       SET add_appt_request->qual[1].text[i].parent2_id = appt_by_id_reply->qual[1].text[i].
       location_cd
       SET add_appt_request->qual[1].text[i].parent3_id = appt_by_id_reply->qual[1].text[i].
       sch_action_cd
       SET stat = alterlist(add_appt_request->qual[1].text[i].sub_list,value(size(appt_by_id_reply->
          qual[1].text[i].sub_list,5)))
       DECLARE j = i2
       FOR (j = 1 TO value(size(appt_by_id_reply->qual[1].text[i].sub_list,5)))
         SET add_appt_request->qual[1].text[i].sub_list[j].template_id = appt_by_id_reply->qual[1].
         text[i].sub_list[j].template_id
         SET add_appt_request->qual[1].text[i].sub_list[j].active_ind = true
         SET add_appt_request->qual[1].text[i].sub_list[j].seq_nbr = j
       ENDFOR
      ENDIF
    ENDFOR
    SET stat = alterlist(add_appt_request->qual[1].text,text_count)
    SET stat = alterlist(add_appt_request->qual[1].ord,value(size(appt_by_id_reply->qual[1].orders,5)
      ))
    FOR (i = 1 TO value(size(appt_by_id_reply->qual[1].orders,5)))
      SET add_appt_request->qual[1].ord[i].synonym_id = appt_by_id_reply->qual[1].orders[i].
      synonym_id
      SET add_appt_request->qual[1].ord[i].required_ind = appt_by_id_reply->qual[1].orders[i].
      required_ind
      SET add_appt_request->qual[1].ord[i].candidate_id = 0
      SET add_appt_request->qual[1].ord[i].active_ind = true
      SET add_appt_request->qual[1].ord[i].active_status_cd = 0
      SET add_appt_request->qual[1].ord[i].seq_nbr = i
    ENDFOR
    SET stat = alterlist(add_appt_request->qual[1].notify,value(size(appt_by_id_reply->qual[1].notify,
       5)))
    FOR (i = 1 TO value(size(appt_by_id_reply->qual[1].notify,5)))
      SET add_appt_request->qual[1].notify[i].location_cd = appt_by_id_reply->qual[1].notify[i].
      location_cd
      SET add_appt_request->qual[1].notify[i].sch_action_cd = appt_by_id_reply->qual[1].notify[i].
      sch_action_cd
      SET add_appt_request->qual[1].notify[i].beg_units = appt_by_id_reply->qual[1].notify[i].
      beg_units
      SET add_appt_request->qual[1].notify[i].beg_units_cd = appt_by_id_reply->qual[1].notify[i].
      beg_units_cd
      SET add_appt_request->qual[1].notify[i].beg_units_meaning = appt_by_id_reply->qual[1].notify[i]
      .beg_units_meaning
      SET add_appt_request->qual[1].notify[i].end_units = appt_by_id_reply->qual[1].notify[i].
      end_units
      SET add_appt_request->qual[1].notify[i].end_units_cd = appt_by_id_reply->qual[1].notify[i].
      end_units_cd
      SET add_appt_request->qual[1].notify[i].end_units_meaning = appt_by_id_reply->qual[1].notify[i]
      .end_units_meaning
      SET add_appt_request->qual[1].notify[i].sch_route_id = appt_by_id_reply->qual[1].notify[i].
      sch_route_id
      SET add_appt_request->qual[1].notify[i].candidate_id = 0
      SET add_appt_request->qual[1].notify[i].active_ind = true
      SET add_appt_request->qual[1].notify[i].active_status_cd = 0
      SET add_appt_request->qual[1].notify[i].seq_nbr = i
    ENDFOR
    SET stat = alterlist(add_appt_request->qual[1].appt_object_qual,value(size(appt_by_id_reply->
       qual[1].object,5)))
    FOR (i = 1 TO value(size(appt_by_id_reply->qual[1].object,5)))
      SET add_appt_request->qual[1].appt_object_qual[i].assoc_type_cd = appt_by_id_reply->qual[1].
      object[i].assoc_type_cd
      SET add_appt_request->qual[1].appt_object_qual[i].sch_object_id = appt_by_id_reply->qual[1].
      object[i].sch_object_id
      SET add_appt_request->qual[1].appt_object_qual[i].assoc_type_meaning = appt_by_id_reply->qual[1
      ].object[i].assoc_type_meaning
      SET add_appt_request->qual[1].appt_object_qual[i].active_ind = true
    ENDFOR
    SET req_list_count = 0
    FOR (i = 1 TO value(size(file_content->line[record_cnt].req_list,5)))
     SET stat = alterlist(add_appt_request->qual[1].appt_routing_qual,(value(size(file_content->line[
        record_cnt].req_list[i].request_loc_list,5))+ req_list_count))
     FOR (j = 1 TO value(size(file_content->line[record_cnt].req_list[i].request_loc_list,5)))
       SET req_list_count = (req_list_count+ 1)
       SET add_appt_request->qual[1].appt_routing_qual[req_list_count].location_cd = cnvtreal(
        file_content->line[record_cnt].col[5].value)
       SELECT
        cv.code_value, cv.display, cv.display_key,
        cv.code_set
        FROM code_value cv
        WHERE cv.display_key=cnvtupper(file_content->line[record_cnt].req_list[i].request_type)
         AND cv.code_set=14232
        DETAIL
         add_appt_request->qual[1].appt_routing_qual[req_list_count].sch_action_cd = cv.code_value,
         add_appt_request->qual[1].appt_routing_qual[req_list_count].action_meaning = cv.cdf_meaning
        WITH nocounter
       ;end select
       SET add_appt_request->qual[1].appt_routing_qual[req_list_count].routing_table = "SCH_OBJECT"
       SELECT
        sr.sch_object_id, sr.description, sr.mnemonic_key
        FROM sch_object sr
        WHERE sr.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
         AND sr.active_ind=1
         AND sr.mnemonic_key=cnvtupper(file_content->line[record_cnt].req_list[i].request_loc_list[j]
         .value)
        DETAIL
         add_appt_request->qual[1].appt_routing_qual[req_list_count].routing_id = sr.sch_object_id
        WITH nocounter
       ;end select
       SET add_appt_request->qual[1].appt_routing_qual[req_list_count].active_ind = true
       SET add_appt_request->qual[1].appt_routing_qual[req_list_count].seq_nbr = req_list_count
     ENDFOR
    ENDFOR
    SET stat = alterlist(add_appt_request->qual[1].appt_action,value(size(appt_by_id_reply->qual[1].
       appt_action,5)))
    FOR (i = 1 TO value(size(appt_by_id_reply->qual[1].appt_action,5)))
      SET add_appt_request->qual[1].appt_action[i].location_cd = appt_by_id_reply->qual[1].
      appt_action[i].location_cd
      SET add_appt_request->qual[1].appt_action[i].sch_action_cd = appt_by_id_reply->qual[1].
      appt_action[i].sch_action_cd
      SET add_appt_request->qual[1].appt_action[i].child_appt_syn_cd = appt_by_id_reply->qual[1].
      appt_action[i].child_appt_syn_cd
      SET add_appt_request->qual[1].appt_action[i].offset_beg_units = appt_by_id_reply->qual[1].
      appt_action[i].offset_beg_units
      SET add_appt_request->qual[1].appt_action[i].offset_beg_units_cd = appt_by_id_reply->qual[1].
      appt_action[i].offset_beg_units_cd
      SET add_appt_request->qual[1].appt_action[i].offset_beg_units_meaning = appt_by_id_reply->qual[
      1].appt_action[i].sch_action_mean
      SET add_appt_request->qual[1].appt_action[i].offset_end_units = appt_by_id_reply->qual[1].
      appt_action[i].offset_end_units
      SET add_appt_request->qual[1].appt_action[i].offset_end_units_cd = appt_by_id_reply->qual[1].
      appt_action[i].offset_end_units_cd
      SET add_appt_request->qual[1].appt_action[i].offset_end_units_meaning = appt_by_id_reply->qual[
      1].appt_action[i].offset_end_units_mean
      SET add_appt_request->qual[1].appt_action[i].active_ind = true
      SET add_appt_request->qual[1].appt_action[i].seq_nbr = i
    ENDFOR
    SET stat = alterlist(add_appt_request->qual[1].rel_med_svc,value(size(appt_by_id_reply->qual[1].
       rel_med_svc_qual,5)))
    FOR (i = 1 TO value(size(appt_by_id_reply->qual[1].rel_med_svc_qual,5)))
     SET add_appt_request->qual[1].rel_med_svc[i].med_service_cd = appt_by_id_reply->qual[1].
     rel_med_svc_qual[i].med_service_cd
     SET add_appt_request->qual[1].rel_med_svc[i].active_ind = true
    ENDFOR
    SET stat = alterlist(add_appt_request->qual[1].rel_enc_type,value(size(appt_by_id_reply->qual[1].
       rel_enc_type_qual,5)))
    FOR (i = 1 TO value(size(appt_by_id_reply->qual[1].rel_enc_type_qual,5)))
      SET add_appt_request->qual[1].rel_enc_type[i].encntr_type_cd = appt_by_id_reply->qual[1].
      rel_enc_type_qual[i].encntr_type_cd
      SET add_appt_request->qual[1].rel_enc_type[i].sch_action_cd = appt_by_id_reply->qual[1].
      rel_enc_type_qual[i].sch_action_cd
      SET add_appt_request->qual[1].rel_enc_type[i].active_ind = true
      SET add_appt_request->qual[1].rel_enc_type[i].seq_nbr = i
    ENDFOR
    SET stat = alterlist(add_appt_request->qual[1].dup,value(size(appt_by_id_reply->qual[1].dup,5)))
    FOR (i = 1 TO value(size(appt_by_id_reply->qual[1].dup,5)))
      SET add_appt_request->qual[1].dup[i].dup_type_cd = appt_by_id_reply->qual[1].dup[i].dup_type_cd
      SET add_appt_request->qual[1].dup[i].location_cd = appt_by_id_reply->qual[1].dup[i].location_cd
      SET add_appt_request->qual[1].dup[i].dup_type_meaning = appt_by_id_reply->qual[1].dup[i].
      dup_mean
      SET add_appt_request->qual[1].dup[i].beg_units = appt_by_id_reply->qual[1].dup[i].beg_units
      SET add_appt_request->qual[1].dup[i].beg_units_cd = appt_by_id_reply->qual[1].dup[i].
      beg_units_cd
      SET add_appt_request->qual[1].dup[i].beg_units_meaning = appt_by_id_reply->qual[1].dup[i].
      beg_units_meaning
      SET add_appt_request->qual[1].dup[i].end_units = appt_by_id_reply->qual[1].dup[i].end_units
      SET add_appt_request->qual[1].dup[i].end_units_cd = appt_by_id_reply->qual[1].dup[i].
      end_units_cd
      SET add_appt_request->qual[1].dup[i].end_units_meaning = appt_by_id_reply->qual[1].dup[i].
      end_units_meaning
      SET add_appt_request->qual[1].dup[i].dup_action_cd = appt_by_id_reply->qual[1].dup[i].
      dup_action_cd
      SET add_appt_request->qual[1].dup[i].dup_action_meaning = appt_by_id_reply->qual[1].dup[i].
      dup_action_meaning
      SET add_appt_request->qual[1].dup[i].active_ind = true
      SET add_appt_request->qual[1].dup[i].seq_nbr = i
    ENDFOR
    SET filter_cnt = (appt_by_id_reply->qual[1].mnemonic_qual_cnt+ appt_by_id_reply->qual[1].
    catalog_qual_cnt)
    SET stat = alterlist(add_appt_request->qual[1].filter,filter_cnt)
    DECLARE catalog_cd = f8 WITH constant(uar_get_code_by("DISPLAY_KEY",16142,"CATALOGTYPECODE"))
    DECLARE mnemonic_cd = f8 WITH constant(uar_get_code_by("DISPLAY_KEY",16142,"MNEMONICTYPECODE"))
    SET filter_cnt = 0
    FOR (i = 1 TO appt_by_id_reply->qual[1].mnemonic_qual_cnt)
      SET add_appt_request->qual[1].filter[i].free_type_cd = uar_get_code_by("DISPLAY_KEY",16142,
       "MNEMONICTYPECODE")
      SET add_appt_request->qual[1].filter[i].free_type_meaning = "MNEMONIC"
      SET add_appt_request->qual[1].filter[i].child_cd = appt_by_id_reply->qual[1].mnemonic_qual[i].
      child_cd
      SET add_appt_request->qual[1].filter[i].child_type_meaning = appt_by_id_reply->qual[1].
      mnemonic_qual[i].child_meaning
      SET add_appt_request->qual[1].filter[i].active_ind = true
      SET filter_cnt = (filter_cnt+ 1)
    ENDFOR
    FOR (i = 1 TO appt_by_id_reply->qual[1].catalog_qual_cnt)
      SET filter_cnt = (filter_cnt+ 1)
      SET add_appt_request->qual[1].filter[filter_cnt].free_type_cd = uar_get_code_by("DISPLAY_KEY",
       16142,"CATALOGTYPECODE")
      SET add_appt_request->qual[1].filter[filter_cnt].free_type_meaning = "CATALOG"
      SET add_appt_request->qual[1].filter[filter_cnt].child_cd = appt_by_id_reply->qual[1].
      catalog_qual[i].child_cd
      SET add_appt_request->qual[1].filter[filter_cnt].child_type_meaning = appt_by_id_reply->qual[1]
      .catalog_qual[i].child_meaning
      SET add_appt_request->qual[1].filter[filter_cnt].active_ind = true
    ENDFOR
    SET stat = alterlist(add_appt_request->qual[1].inter,value(size(appt_by_id_reply->qual[1].inter,5
       )))
    FOR (i = 1 TO value(size(appt_by_id_reply->qual[1].inter,5)))
      SET add_appt_request->qual[1].inter[i].location_cd = appt_by_id_reply->qual[1].inter[i].
      location_cd
      SET add_appt_request->qual[1].inter[i].inter_type_cd = appt_by_id_reply->qual[1].inter[i].
      inter_type_cd
      SET add_appt_request->qual[1].inter[i].inter_type_meaning = appt_by_id_reply->qual[1].inter[i].
      inter_type_meaning
      SET add_appt_request->qual[1].inter[i].seq_group_id = appt_by_id_reply->qual[1].inter[i].
      seq_group_id
      SET add_appt_request->qual[1].inter[i].candidate_id = 0
      SET add_appt_request->qual[1].inter[i].active_ind = true
      SET add_appt_request->qual[1].inter[i].active_status_cd = 0
    ENDFOR
    SET add_appt_request->qual[1].option_partial_ind = false
    SET stat = alterlist(add_appt_request->qual[1].option,value(size(appt_by_id_reply->qual[1].option,
       5)))
    FOR (i = 1 TO value(size(appt_by_id_reply->qual[1].option,5)))
      SET add_appt_request->qual[1].option[i].sch_option_cd = appt_by_id_reply->qual[1].option[i].
      sch_option_cd
      SET add_appt_request->qual[1].option[i].option_meaning = appt_by_id_reply->qual[1].option[i].
      option_mean
      SET add_appt_request->qual[1].option[i].candidate_id = 0
      SET add_appt_request->qual[1].option[i].active_ind = true
    ENDFOR
    SET add_appt_request->qual[1].text_partial_ind = false
    SET add_appt_request->qual[1].ord_partial_ind = false
    EXECUTE sch_addw_appt_type  WITH replace("REQUEST",add_appt_request), replace("REPLY",
     add_appt_reply)
    SET final_result->qual[record_cnt].appt_name = file_content->line[record_cnt].col[1].value
    IF ((add_appt_reply->status_data.status="D"))
     SET final_result->qual[record_cnt].added = 0
    ELSE
     SET final_result->qual[record_cnt].added = 1
    ENDIF
   ELSE
    SET final_result->qual[record_cnt].appt_name = file_content->line[record_cnt].col[1].value
    SET final_result->qual[record_cnt].added = 0
   ENDIF
 ENDFOR
 SELECT INTO  $1
  qual_appt_name = final_result->qual[d1.seq].appt_name, qual_added = final_result->qual[d1.seq].
  added
  FROM (dummyt d1  WITH seq = value(size(final_result->qual,5)))
  PLAN (d1)
  ORDER BY qual_added
  HEAD REPORT
   col 10, " Following appt types were NOT added", row + 1,
   added_count = 0, not_added_count = 0
  DETAIL
   IF (qual_added=1)
    added_count = (added_count+ 1)
   ELSE
    col 10, qual_appt_name, row + 1,
    not_added_count = (not_added_count+ 1)
   ENDIF
  FOOT REPORT
   row + 2, col 10, " Total appointment types NOT added = ",
   col 50, not_added_count, row + 2,
   col 10, " Total appointment types added = ", col 50,
   added_count
  WITH nocounter, separator = " ", format
 ;end select
#exit_script
 IF (failed != false)
  SELECT INTO value( $OUTDEV)
   message = trim(substring(1,200,serrmsg),3)
   FROM (dummyt d  WITH seq = 1)
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
 IF (failed != exe_error)
  CALL updtdminfo(trim(cnvtupper(curprog),3))
 ENDIF
END GO
