CREATE PROGRAM ams_sch_location_updt1
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter File Name" = "",
  "Path" = "",
  "Enter Appointment Mnemonic" = ""
  WITH outdev, file, path,
  appt
 DECLARE owner_cd = f8 WITH constant(uar_get_code_by("MEANING",106,"SCHEDULING")), protect
 DECLARE con_cd = f8 WITH constant(uar_get_code_by("MEANING",13016,"APPTTYPE")), protect
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
 SET script_failed = false
 SET table_name = fillstring(50," ")
 DECLARE serrmsg = vc WITH protect, noconstant("")
 DECLARE ierrcode = i2 WITH protect, noconstant(0)
 DECLARE bamsassociate = i2 WITH protect, noconstant(false)
 EXECUTE ams_define_toolkit_common
 FREE RECORD request_650613
 RECORD request_650613(
   1 qual[*]
     2 appt_type_cd = f8
 )
 FREE RECORD reply_650613
 RECORD reply_650613(
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
     2 rel_specialty_cnt = i4
     2 rel_specialty_qual[*]
       3 sch_at_specialty_r_id = f8
       3 specialty_cd = f8
       3 specialty_disp = vc
       3 specialty_mean = vc
       3 updt_cnt = i4
       3 active_ind = i2
       3 candidate_id = f8
     2 priority_seq = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD reply_650610
 RECORD reply_650610(
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
     2 rel_med_svc_qual_cnt = i4
     2 rel_med_svc[*]
       3 candidate_id = f8
       3 status = i2
     2 rel_enc_type_qual_cnt = i4
     2 rel_enc_type[*]
       3 candidate_id = f8
       3 status = i2
     2 organization_qual_cnt = i4
     2 organization[*]
       3 organization_id = f8
       3 status = i2
     2 rel_specialty_qual_cnt = i4
     2 rel_specialty[*]
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
 FREE RECORD request_650610
 RECORD request_650610(
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
     2 rel_med_svc_partial_ind = i2
     2 rel_med_svc[*]
       3 med_service_cd = f8
       3 candidate_id = f8
       3 active_ind = i2
       3 active_status_cd = f8
     2 rel_enc_type_partial_ind = i2
     2 rel_enc_type[*]
       3 encntr_type_cd = f8
       3 candidate_id = f8
       3 active_ind = i2
       3 active_status_cd = f8
       3 sch_action_cd = f8
       3 seq_nbr = i4
     2 organization_qual_cnt = i4
     2 organization[*]
       3 organization_id = f8
       3 action = i2
     2 rel_specialty_partial_ind = i2
     2 rel_specialty[*]
       3 specialty_cd = f8
       3 sch_at_specialty_r_id = f8
       3 candidate_id = f8
       3 active_ind = i2
       3 active_status_cd = f8
     2 priority_seq = i4
 )
 FREE RECORD request_951010
 RECORD request_951010(
   1 nbr_of_recs = i2
   1 qual[*]
     2 action = i2
     2 ext_id = f8
     2 ext_contributor_cd = f8
     2 parent_qual_ind = f8
     2 careset_ind = i2
     2 ext_owner_cd = f8
     2 ext_sub_owner_cd = f8
     2 ext_description = c100
     2 ext_short_desc = c50
     2 workload_only_ind = i2
     2 price_qual = i2
     2 prices[*]
       3 price_sched_id = f8
       3 price = f8
     2 billcode_qual = i2
     2 billcodes[*]
       3 billcode_sched_cd = f8
       3 billcode = c25
       3 bim1_int = f8
     2 child_qual = i4
     2 children[*]
       3 ext_id = f8
       3 ext_contributor_cd = f8
       3 ext_description = c100
       3 ext_short_desc = c50
       3 child_seq = i4
       3 bi_id = f8
       3 ext_owner_cd = f8
       3 ext_sub_owner_cd = f8
   1 logical_domain_id = f8
 )
 FREE RECORD reply_951010
 RECORD reply_951010(
   1 bill_item_qual = i4
   1 bill_item[*]
     2 bill_item_id = f8
   1 qual[*]
     2 bill_item_id = f8
   1 price_sched_items_qual = i2
   1 price_sched_items[*]
     2 price_sched_id = f8
     2 price_sched_items_id = f8
   1 bill_item_modifier_qual = i2
   1 bill_item_modifier[10]
     2 bill_item_mod_id = f8
   1 actioncnt = i2
   1 actionlist[*]
     2 action1 = vc
     2 action2 = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c20
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 FREE RECORD temp
 RECORD temp(
   1 list[*]
     2 mnemonic = vc
       3 val = f8
 )
 SET path = value(logical( $PATH))
 SET infile =  $FILE
 SET file_path = build(path,"/",infile)
 CALL echo(file_path)
 DEFINE rtl2 value(file_path)
 FREE RECORD temp
 RECORD temp(
   1 list[*]
     2 mnemonic = vc
 )
 SELECT
  r.line
  FROM rtl2t r
  HEAD REPORT
   row_count = 0, i = 0, count = 0,
   stat = alterlist(temp->list,10)
  HEAD r.line
   line1 = r.line,
   CALL echo(line1), row_count = (row_count+ 1)
   IF (mod(row_count,10)=1)
    stat = alterlist(temp->list,(row_count+ 9))
   ENDIF
   temp->list[row_count].mnemonic = line1
  FOOT REPORT
   stat = alterlist(temp->list,row_count)
  WITH nocounter
 ;end select
 SELECT
  FROM code_value cv
  WHERE cnvtupper(cv.display)=cnvtupper( $APPT)
   AND cv.code_set=14230
   AND active_ind=1
  DETAIL
   stat = alterlist(request_650613->qual,1), request_650613->qual[1].appt_type_cd = cv.code_value,
   CALL echo(request_650613->qual[1].appt_type_cd)
  WITH nocounter
 ;end select
 SET stat = tdbexecute(650600,650600,650613,"REC",request_650613,
  "REC",reply_650613)
 CALL echorecord(reply_650613)
 DECLARE index = i4
 DECLARE index1 = i4
 CALL echorecord(temp)
 FOR (index = 1 TO size(temp->list,5))
   SET stat = alterlist(request_650610->qual,1)
   SET request_650610->qual[1].description = temp->list[index].mnemonic
   SET request_650610->qual[1].recur_cd = reply_650613->qual[1].recur_cd
   SET request_650610->qual[1].recur_meaning = reply_650613->qual[1].recur_meaning
   SET request_650610->qual[1].person_accept_cd = reply_650613->qual[1].person_accept_cd
   SET request_650610->qual[1].person_accept_meaning = reply_650613->qual[1].person_accept_meaning
   SET request_650610->qual[1].active_ind = reply_650613->qual[1].active_ind
   SET stat = alterlist(request_650610->qual[1].syn,1)
   SET request_650610->qual[1].syn[1].mnemonic = temp->list[index].mnemonic
   SET request_650610->qual[1].syn[1].allow_selection_flag = 1
   SET request_650610->qual[1].syn[1].primary_ind = 1
   SET request_650610->qual[1].syn[1].active_ind = 1
   SET request_650610->qual[1].syn[1].new_syn_ref_id = - (1)
   SET stat = alterlist(request_650610->qual[1].loc,size(reply_650613->qual[1].locs,5))
   FOR (index1 = 1 TO size(reply_650613->qual[1].locs,5))
     SET request_650610->qual[1].loc[index1].location_cd = reply_650613->qual[1].locs[index1].
     location_cd
     SET request_650610->qual[1].loc[index1].res_list_id = reply_650613->qual[1].locs[index1].
     res_list_id
     SET request_650610->qual[1].loc[index1].active_ind = 1
   ENDFOR
   SET stat = alterlist(request_650610->qual[1].state,size(reply_650613->qual[1].states,5))
   FOR (index1 = 1 TO size(reply_650613->qual[1].states,5))
     SET request_650610->qual[1].state[index1].active_ind = 1
     SET request_650610->qual[1].state[index1].active_status_cd = 188
     SET request_650610->qual[1].state[index1].candidate_id = reply_650613->qual.states[index1].
     candidate_id
     SET request_650610->qual[1].state[index1].disp_scheme_id = reply_650613->qual.states[index1].
     disp_scheme_id
     SET request_650610->qual[1].state[index1].sch_state_cd = reply_650613->qual.states[index1].
     sch_state_cd
     SET request_650610->qual[1].state[index1].state_meaning = reply_650613->qual.states[index1].
     state_meaning
   ENDFOR
   SET stat = alterlist(request_650610->qual[1].option,size(reply_650613->qual[1].option,5))
   FOR (index1 = 1 TO size(reply_650613->qual[1].option,5))
     SET request_650610->qual[1].option[index1].active_ind = 1
     SET request_650610->qual[1].option[index1].active_status_cd = 188
     SET request_650610->qual[1].option[index1].option_meaning = reply_650613->qual[1].option[index1]
     .option_mean
     SET request_650610->qual[1].option[index1].sch_option_cd = reply_650613->qual[1].option[index1].
     sch_option_cd
   ENDFOR
   SET stat = alterlist(request_650610->qual[1].product,size(reply_650613->qual[1].product,5))
   FOR (index1 = 1 TO size(reply_650613->qual[1].product,5))
     SET request_650610->qual[1].product[index1].product_cd = reply_650613->qual[1].product[index1].
     product_cd
     SET request_650610->qual[1].product[index1].product_meaning = reply_650613->qual[1].product[
     index1].product_mean
     SET request_650610->qual[1].product[index1].active_ind = 1
   ENDFOR
   SET stat = alterlist(request_650610->qual[1].appt_routing_qual,size(reply_650613->qual[1].routing,
     5))
   FOR (index1 = 1 TO size(reply_650613->qual[1].routing,5))
     SET request_650610->qual[1].appt_routing_qual[index1].location_cd = reply_650613->qual[1].
     routing[index1].location_cd
     SET request_650610->qual[1].appt_routing_qual[index1].sch_action_cd = reply_650613->qual[1].
     routing[index1].sch_action_cd
     SET request_650610->qual[1].appt_routing_qual[index1].action_meaning = reply_650613->qual[1].
     routing[index1].action_meaning
     SET request_650610->qual[1].appt_routing_qual[index1].routing_table = reply_650613->qual[1].
     routing[index1].routing_table
     SET request_650610->qual[1].appt_routing_qual[index1].routing_id = reply_650613->qual[1].
     routing[index1].routing_id
     SET request_650610->qual[1].appt_routing_qual[index1].active_ind = 1
     SET request_650610->qual[1].appt_routing_qual[index1].seq_nbr = reply_650613->qual[1].routing[
     index1].seq_nbr
     SET request_650610->qual[1].appt_routing_qual[index1].beg_units = reply_650613->qual[1].routing[
     index1].beg_units
     SET request_650610->qual[1].appt_routing_qual[index1].beg_units_cd = reply_650613->qual[1].
     routing[index1].beg_units_cd
     SET request_650610->qual[1].appt_routing_qual[index1].beg_units_meaning = reply_650613->qual[1].
     routing[index1].beg_units_me
     SET request_650610->qual[1].appt_routing_qual[index1].end_units = reply_650613->qual[1].routing[
     index1].end_units
     SET request_650610->qual[1].appt_routing_qual[index1].end_units_cd = reply_650613->qual[1].
     routing[index1].end_units_cd
     SET request_650610->qual[1].appt_routing_qual[index1].end_units_meaning = reply_650613->qual[1].
     routing[index1].end_units_me
   ENDFOR
   SET request_650610->qual[1].grp_resource_mnem = temp->list[index].mnemonic
   CALL echorecord(request_650610)
   SET stat = tdbexecute(650600,650610,650610,"REC",request_650610,
    "REC",reply_650610)
   IF ((reply_650610->status_data[1].status="S"))
    SET stat = alterlist(request_951010->qual,1)
    SET request_951010->nbr_of_recs = 1
    SET request_951010->qual[1].action = 1
    SET request_951010->qual[1].ext_id = reply_650610->qual[1].appt_type_cd
    SET request_951010->qual[1].ext_contributor_cd = con_cd
    SET request_951010->qual[1].parent_qual_ind = 1
    SET request_951010->qual[1].ext_owner_cd = owner_cd
    SET request_951010->qual[1].ext_description = temp->list[index].mnemonic
    SET request_951010->qual[1].ext_short_desc = temp->list[index].mnemonic
    SET stat = tdbexecute(13000,13001,951010,"REC",request_951010,
     "REC",reply_951010)
    CALL echorecord(reply_951010)
   ENDIF
 ENDFOR
#exit_script
END GO
