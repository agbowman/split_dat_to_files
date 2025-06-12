CREATE PROGRAM dab_pt_transfer_old:dba
 PROMPT
  "Enter printer (mine for screen display): " = "mine",
  "encntr_id" = 0
 SET rhead = concat("{\rtf1\ansi \deff0{\fonttbl{\f0\fswissArial;}{\f1 Courier New;}}",
  "{\colortbl;\red0\green0\blue0;\red255\green255\blue255;}\deftab1134")
 SET test_ind = 0
 FREE RECORD pt_transfer
 RECORD pt_transfer(
   1 person_id = f8
   1 encntr_id = f8
   1 name = vc
   1 dob = vc
   1 mrn = vc
   1 fin = vc
   1 ssn = vc
   1 facility = vc
   1 facility_phone = vc
   1 last_nurse_unit = vc
   1 phone = vc
   1 address_line = vc
   1 city_state_zip = vc
   1 reg_date = vc
   1 disch_date = dq8
   1 allergies = vc
   1 ins_cnt = i2
   1 ins_qual[*]
     2 type = vc
     2 name = vc
     2 member_nbr = vc
     2 group_nbr = vc
     2 subscriber = vc
   1 attending = vc
   1 pcp = vc
   1 admit_reason = vc
   1 adv_dir = vc
   1 adv_type = vc
   1 adv_proxy = vc
   1 adv_phone = vc
   1 adv_date = vc
   1 adv_copy = vc
   1 adv_loc = vc
   1 religion = vc
   1 code_status_qual[*]
     2 order_id = f8
     2 order_name = vc
     2 status_date = vc
     2 order_status = vc
     2 order_detail = vc
   1 isolation_qual[*]
     2 order_id = f8
     2 iso_name = vc
     2 iso_status = vc
     2 status_date = vc
     2 iso_detail = vc
   1 cont_cnt = i2
   1 cont_qual[*]
     2 name = vc
     2 relation = vc
     2 phone_cnt = i2
     2 phone_qual[*]
       3 home_phone = vc
       3 bus_phone = vc
       3 ext = vc
   1 problem_cnt = i2
   1 problem[*]
     2 name = vc
     2 onset_date = vc
     2 status = vc
     2 comment_cnt = i2
     2 comments[*]
       3 comment = vc
       3 date = vc
   1 diet_cnt = i2
   1 diet_qual[*]
     2 order_id = f8
     2 order_name = vc
     2 order_status = vc
     2 status_date = vc
     2 order_detail = vc
   1 immun_cnt = i2
   1 immun[*]
     2 name = vc
     2 given_date = vc
   1 vitals_cnt = i4
   1 vitals[*]
     2 vit_name = vc
     2 vit_date = vc
     2 vit_result = vc
     2 vit_unit = vc
   1 special_vit_cnt = i2
   1 special_vit[*]
     2 vit_name = vc
     2 vit_date = vc
     2 vit_result = vc
     2 vit_unit = vc
   1 special_labs_cnt = i2
   1 special_labs[*]
     2 order_name = vc
     2 order_date = vc
     2 result_cnt = i2
     2 result_qual[*]
       3 result_name = vc
       3 result_date = vc
       3 result_val = vc
       3 units = vc
       3 ref_range = vc
       3 normalcy_disp = vc
       3 result_comments = vc
       3 comment_comp_cd = f8
   1 lab_results_cnt = i4
   1 lab_results[*]
     2 event_id = f8
     2 event_cd_disp = vc
     2 result_val = vc
     2 units = vc
     2 normalcy_disp = vc
     2 ref_range = vc
     2 date = vc
     2 result_comments = vc
     2 comment_comp_cd = f8
   1 micro_cnt = i4
   1 micro_results[*]
     2 parent_event_id = f8
     2 event_id = f8
     2 event_name = vc
     2 result_val = vc
     2 clinsig_updt_dt_tm = vc
     2 collect_dt_tm = vc
     2 result_status = vc
     2 blob_contents = vc
     2 comp_cd = f8
     2 blobseq = i4
     2 result_comments = vc
     2 comment_comp_cd = f8
   1 catalog_cnt = i4
   1 catalog_qual[*]
     2 catalog_type = vc
     2 orders_cnt = i2
     2 orders_qual[*]
       3 order_id = f8
       3 ord_name = vc
       3 status = vc
       3 date = vc
       3 od_display_line = vc
   1 consult_cnt = i4
   1 consult_qual[*]
     2 order_id = f8
     2 ord_name = vc
     2 status = vc
     2 status_date = vc
     2 completed_by = vc
     2 order_detail = vc
   1 resort_consult_cnt = i4
   1 resort_consult_qual[*]
     2 ord_name = vc
     2 status = vc
     2 status_date = vc
     2 completed_by = vc
     2 order_detail = vc
   1 blob_cnt = i4
   1 blob_qual[*]
     2 blob_event_cd = vc
     2 blob_set_name = vc
     2 event_title_text = vc
     2 blob_date = vc
     2 blobs_cnt = i4
     2 blobs_qual[*]
       3 blob_contents = vc
       3 event_id = f8
       3 event_title_text = vc
       3 comp_cd = f8
       3 blobseq = i4
     2 action_cnt = i2
     2 action_qual[*]
       3 type = vc
       3 status = vc
       3 prsnl_name = vc
       3 date = vc
   1 form_cnt = i4
   1 form_qual[*]
     2 form_type = vc
     2 form_name = vc
     2 form_date = vc
     2 p_event_id = f8
     2 event_id = f8
     2 sub1_cnt = i2
     2 sub1_qual[*]
       3 event_display = vc
       3 p_event_id = f8
       3 event_id = f8
       3 sub2_cnt = i2
       3 sub2_qual[*]
         4 event_display = vc
         4 event_result = vc
         4 event_date = vc
         4 event_comm = vc
         4 event_comp_cd = f8
         4 p_event_id = f8
         4 event_id = f8
         4 sub3_cnt = i2
         4 sub3_qual[*]
           5 event_display = vc
           5 event_result = vc
           5 event_date = vc
           5 event_comm = vc
           5 event_comp_cd = f8
           5 p_event_id = f8
           5 event_id = f8
           5 sub4_cnt = i2
           5 sub4_qual[*]
             6 event_display = vc
             6 event_result = vc
             6 event_date = vc
             6 event_comm = vc
             6 event_comp_cd = f8
             6 p_event_id = f8
             6 event_id = f8
 )
 FREE RECORD form_data
 RECORD form_data(
   1 qual[*]
     2 dcp_forms_ref_id = f8
     2 type = vc
     2 max_cnt = i2
     2 cur_cnt = i2
 )
 FREE RECORD form_results
 RECORD form_results(
   1 form_cnt = i4
   1 form_qual[*]
     2 form_type = vc
     2 form_name = vc
     2 dcp_forms_ref_id = f8
     2 dcp_forms_activity_id = f8
     2 form_event_id = f8
 )
 FREE RECORD scheduled_orders
 RECORD scheduled_orders(
   1 qual[*]
     2 order_id = f8
     2 action_type = vc
     2 true_parent = i2
     2 order_detail = vc
     2 stop_dt = dq8
     2 order_name = vc
     2 comm_cnt = i2
     2 comment[*]
       3 comment = vc
     2 print_ind = i2
     2 child_ord[*]
       3 order_id = f8
       3 start_dt = dq8
       3 order_mnemonic = vc
 )
 FREE RECORD scheduled_orders_disp
 RECORD scheduled_orders_disp(
   1 scheduled_orders[*]
     2 template_order_id = f8
     2 action_type = vc
     2 comment[*]
       3 comment = vc
     2 orig_order_dt_tm = dq8
     2 mnemonic = vc
     2 ordered_as_mnemonic = vc
     2 hna_mnemonic = vc
     2 stop_dt = dq8
     2 voided_ind = i2
     2 core_actions[*]
       3 order_id = f8
       3 action_seq = i4
       3 action = c40
       3 action_dt_tm = dq8
       3 clinical_display_line = vc
       3 detail_value = f8
       3 detail_assigned = i2
     2 admins[*]
       3 order_id = f8
       3 parent_event_id = f8
       3 event_id = f8
       3 verified_dt_tm = dq8
       3 verified_prsnl_id = f8
       3 valid_from_dt_tm = dq8
       3 event_title_text = vc
       3 event_end_dt_tm = dq8
       3 result_status_meaning = c12
       3 result_status_display = c40
       3 from_ccr = i2
       3 not_given_reason = vc
       3 admin_start_dt_tm = dq8
       3 dosage_value = f8
       3 dosage_unit = c40
       3 site = c40
       3 admin_by_id = f8
       3 route = c40
       3 vital_signs[*]
         4 event_id = f8
         4 vital_sign = c40
         4 value = vc
         4 unit = c40
         4 normalcy_cd = f8
 )
 FREE RECORD prn_orders
 RECORD prn_orders(
   1 qual[*]
     2 order_id = f8
     2 action_type = vc
     2 true_parent = i2
     2 order_detail = vc
     2 stop_dt = dq8
     2 order_name = vc
     2 comment = vc
     2 print_ind = i2
     2 child_ord[*]
       3 order_id = f8
       3 start_dt = dq8
       3 order_mnemonic = vc
 )
 FREE RECORD prn_orders_disp
 RECORD prn_orders_disp(
   1 prn_orders[*]
     2 order_id = f8
     2 action_type = vc
     2 comment = vc
     2 com_cnt = i2
     2 comment[*]
       3 comment = vc
     2 orig_order_dt_tm = dq8
     2 mnemonic = vc
     2 ordered_as_mnemonic = vc
     2 order_status = vc
     2 order_status_cd = f8
     2 hna_mnemonic = vc
     2 stop_dt = dq8
     2 voided_ind = i2
     2 core_actions[*]
       3 order_id = f8
       3 action_seq = i4
       3 action = c40
       3 action_dt_tm = dq8
       3 clinical_display_line = vc
       3 detail_value = f8
       3 detail_assigned = i2
     2 admins[*]
       3 order_id = f8
       3 parent_event_id = f8
       3 event_id = f8
       3 verified_dt_tm = dq8
       3 verified_prsnl_id = f8
       3 valid_from_dt_tm = dq8
       3 event_title_text = vc
       3 event_end_dt_tm = dq8
       3 result_status_meaning = c12
       3 result_status_display = c40
       3 from_ccr = i2
       3 not_given_reason = vc
       3 admin_start_dt_tm = dq8
       3 dosage_value = f8
       3 dosage_unit = c40
       3 site = c40
       3 admin_by_id = f8
       3 route = c40
       3 vital_signs[*]
         4 event_id = f8
         4 vital_sign = c40
         4 value = vc
         4 unit = c40
         4 normalcy_cd = f8
 )
 FREE RECORD continuous_orders
 RECORD continuous_orders(
   1 qual[*]
     2 order_id = f8
     2 action_type = vc
     2 true_parent = i2
     2 order_detail = vc
     2 stop_dt = dq8
     2 order_name = vc
     2 comment = vc
     2 print_ind = i2
     2 child_ord[*]
       3 order_id = f8
       3 start_dt = dq8
       3 order_mnemonic = vc
 )
 FREE RECORD continuous_orders_disp
 RECORD continuous_orders_disp(
   1 continuous_orders[*]
     2 order_id = f8
     2 action_type = vc
     2 comment = vc
     2 com_cnt = i2
     2 comment[*]
       3 comment = vc
     2 orig_order_dt_tm = dq8
     2 mnemonic = vc
     2 ordered_as_mnemonic = vc
     2 hna_mnemonic = vc
     2 stop_dt = dq8
     2 voided_ind = i2
     2 core_actions[*]
       3 action_seq = i4
       3 action_dt_tm = dq8
       3 action = c40
       3 clinical_display_line = vc
     2 admins[*]
       3 parent_event_id = f8
       3 event_id = f8
       3 verified_dt_tm = dq8
       3 verified_prsnl_id = f8
       3 valid_from_dt_tm = dq8
       3 event_title_text = vc
       3 event_end_dt_tm = dq8
       3 result_status_meaning = c12
       3 result_status_display = c40
       3 from_ccr = i2
       3 not_given_reason = vc
       3 iv_event_meaning = c12
       3 iv_event_display = c40
       3 admin_start_dt_tm = dq8
       3 init_dosage = f8
       3 dosage_unit = c40
       3 initial_volume = f8
       3 infusion_rate = f8
       3 infusion_unit = c40
       3 site = c40
       3 admin_by_id = f8
       3 route = c40
       3 comments[*]
         4 comment_type = c40
         4 text = vc
         4 commenter_id = f8
         4 note_dt_tm = dq8
         4 format = c12
 )
 IF (validate(request->visit,"Z") != "Z")
  SET pt_transfer->encntr_id = request->visit[1].encntr_id
  SET printer_disp = request->output_device
 ELSE
  SET pt_transfer->encntr_id = 29462702.00
  SET printer_disp =  $1
 ENDIF
 DECLARE printed_by = vc
 DECLARE printed_on = vc
 SET printed_on = format(cnvtdatetime(curdate,curtime),"mm/dd/yy hh:mm;;d")
 IF ((reqinfo->updt_id > 0))
  SELECT INTO "nl:"
   FROM prsnl p
   WHERE (p.person_id=reqinfo->updt_id)
   DETAIL
    printed_by = trim(p.name_full_formatted)
   WITH nocounter
  ;end select
 ENDIF
 DECLARE ssn_type = f8 WITH public, constant(uar_get_code_by("displaykey",4,"SSN"))
 DECLARE mrn_type = f8 WITH public, constant(uar_get_code_by("displaykey",319,"MRN"))
 DECLARE fin_type = f8 WITH public, constant(uar_get_code_by("displaykey",319,"FINNBR"))
 DECLARE att_cd = f8 WITH public, constant(uar_get_code_by("displaykey",333,"ATTENDINGPHYSICIAN"))
 DECLARE pcp_cd = f8 WITH public, constant(uar_get_code_by("displaykey",333,"PRIMARYCAREPHYSICIAN"))
 DECLARE add_home_cd = f8 WITH public, constant(uar_get_code_by("displaykey",212,"HOME"))
 DECLARE adv_dir = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"ADVANCEDIRECTIVE"))
 DECLARE adv_type = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"ADVANCEDIRECTIVETYPE"))
 DECLARE adv_proxy = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"PROXY"))
 DECLARE adv_phone = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "CONTACTPROXYPHONENUMBER"))
 DECLARE adv_date = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"ADVANCEDIRECTIVEDATE"))
 DECLARE adv_copy = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"COPYPLACEDONCHART"))
 DECLARE adv_loc = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "ADVANCEDIRECTIVELOCATION"))
 DECLARE bill_address_cd = f8 WITH public, constant(uar_get_code_by("MEANING",212,"BILLING"))
 DECLARE org_insur_cd = f8 WITH public, constant(uar_get_code_by("MEANING",338,"INSURANCE CO"))
 DECLARE org_empl_cd = f8 WITH public, constant(uar_get_code_by("MEANING",338,"EMPLOYER"))
 DECLARE insured_cd = f8 WITH public, constant(uar_get_code_by("MEANING",351,"INSURED"))
 DECLARE emc_cd = f8 WITH public, constant(uar_get_code_by("MEANING",351,"EMC"))
 DECLARE family_cd = f8 WITH public, constant(uar_get_code_by("MEANING",351,"FAMILY"))
 DECLARE def_guar_cd = f8 WITH public, constant(uar_get_code_by("MEANING",351,"DEFGUAR"))
 DECLARE nok_cd = f8 WITH public, constant(uar_get_code_by("MEANING",351,"NOK"))
 DECLARE pcg_cd = f8 WITH public, constant(uar_get_code_by("MEANING",351,"PCG"))
 DECLARE home_phone_cd = f8 WITH public, constant(uar_get_code_by("MEANING",43,"HOME"))
 DECLARE bus_phone_cd = f8 WITH public, constant(uar_get_code_by("MEANING",43,"BUSINESS"))
 DECLARE iv_type_cd = f8
 SET stat = uar_get_meaning_by_codeset(18309,"IV",1,iv_type_cd)
 DECLARE med_type_cd = f8
 SET stat = uar_get_meaning_by_codeset(53,"MED",1,med_type_cd)
 DECLARE num_type_cd = f8
 SET stat = uar_get_meaning_by_codeset(53,"NUM",1,num_type_cd)
 DECLARE not_done_cd = f8
 SET stat = uar_get_meaning_by_codeset(8,"NOT DONE",1,not_done_cd)
 DECLARE voided_cd = f8
 SET stat = uar_get_meaning_by_codeset(6004,"VOIDEDWRSLT",1,voided_cd)
 DECLARE begin_bag_cd = f8
 SET stat = uar_get_meaning_by_codeset(180,"BEGIN",1,begin_bag_cd)
 DECLARE site_chg_cd = f8
 SET stat = uar_get_meaning_by_codeset(180,"SITECHG",1,site_chg_cd)
 DECLARE rate_chg_cd = f8
 SET stat = uar_get_meaning_by_codeset(180,"RATECHG",1,rate_chg_cd)
 DECLARE infuse_cd = f8
 SET stat = uar_get_meaning_by_codeset(180,"INFUSE",1,infuse_cd)
 DECLARE pain_rspns_cd = f8
 SET stat = uar_get_meaning_by_codeset(14,"RESPONSETO",1,pain_rspns_cd)
 DECLARE med_reason_cd = f8
 SET stat = uar_get_meaning_by_codeset(14,"REASONFOR",1,med_reason_cd)
 DECLARE result_cmnt_cd = f8
 SET stat = uar_get_meaning_by_codeset(14,"RES COMMENT",1,result_cmnt_cd)
 DECLARE compress_cd = f8
 SET stat = uar_get_meaning_by_codeset(120,"OCFCOMP",1,compress_cd)
 DECLARE max_num_sched_admins = i4
 DECLARE max_num_prn_admins = i4
 DECLARE max_num_cont_admins = i4
 DECLARE max_num_sched_actions = i4
 DECLARE max_num_prn_actions = i4
 DECLARE max_num_cont_actions = i4
 DECLARE schedordercnt = i4
 DECLARE os_com_cd = f8
 SET stat = uar_get_meaning_by_codeset(6004,"COMPLETED",1,os_com_cd)
 DECLARE os_ord_cd = f8
 SET stat = uar_get_meaning_by_codeset(6004,"ORDERED",1,os_ord_cd)
 DECLARE os_disc_cd = f8
 SET stat = uar_get_meaning_by_codeset(6004,"DISCONTINUED",1,os_disc_cd)
 DECLARE os_canc_cd = f8
 SET stat = uar_get_meaning_by_codeset(6004,"CANCELED",1,os_canc_cd)
 DECLARE temp_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"TEMPERATURE"))
 DECLARE pulse_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"PULSERATE"))
 DECLARE systolic_bp_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "SYSTOLICBLOODPRESSURE"))
 DECLARE diastolic_bp_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "DIASTOLICBLOODPRESSURE"))
 DECLARE resp_rate_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"RESPIRATORYRATE"))
 DECLARE o2_sat_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"OXYGENSATURATION"))
 DECLARE bmi_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"BODYMASSINDEX"))
 DECLARE bsa_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"BODYSURFACEAREA"))
 DECLARE wt_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"WEIGHT"))
 DECLARE ht_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"HEIGHT"))
 DECLARE laboratory_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",6000,"LABORATORY"))
 DECLARE gen_lab_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"GENERALLAB"))
 DECLARE micro_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"MICRO"))
 DECLARE dc_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",6000,"ADMITTRANSFERDISCHARGE")
  )
 DECLARE diet_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6000,"DIETARY"))
 DECLARE diet_consult_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "NUTRITIONSERVICESCONSULTS"))
 SET code_value = 0.0
 SET code_set = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET inerror_cd = 0
 SET code_set = 8
 SET cdf_meaning = "INERROR"
 EXECUTE cpm_get_cd_for_cdf
 SET inerror_cd = code_value
 SET modified_cd = 0
 SET code_set = 8
 SET cdf_meaning = "MODIFIED"
 EXECUTE cpm_get_cd_for_cdf
 SET modified_cd = code_value
 DECLARE notdone_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"NOT DONE"))
 DECLARE pending_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"UNAUTH"))
 DECLARE pharmacy_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6000,"PHARMACY"))
 DECLARE final_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",8,"AUTHVERIFIED"))
 DECLARE prelim_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"UNAUTH"))
 DECLARE output_display = vc
 DECLARE output_display1 = vc
 DECLARE output_display2 = vc
 DECLARE context = i4
 DECLARE status1 = i4
 DECLARE binit = i4
 DECLARE pgwidth = i4
 DECLARE cnvtto = i4
 SET context = 0
 SET status1 = 0
 SET binit = 1
 SET pgwidth = 8.0
 SET cnvtto = 0
 DECLARE blob_set_name = vc
 DECLARE blob_contents = gvc
 DECLARE compression_cd = f8
 DECLARE blob_type = vc
 DECLARE new_blob_contents = gvc
 DECLARE blobout = gvc
 DECLARE blob_return_len = i4
 DECLARE bsize = i4
 DECLARE temp_line_feed = i2
 DECLARE parse_string = vc
 DECLARE cbc1_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",200,"CBC"))
 DECLARE cbc2_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",200,"CBCWDIFFERENTIAL"))
 DECLARE cbc3_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",200,"CBCWMANUALDIFF"))
 DECLARE lytes_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",200,"ELECTROLYTES"))
 DECLARE bun_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",200,"BUN"))
 DECLARE creat_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",200,"CREATININE"))
 DECLARE inr_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",200,"INR"))
 DECLARE isolation_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",200,"ISOLATION"))
 DECLARE full_code_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",200,"FULLRESUSCITATION"
   ))
 DECLARE limited_code_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",200,
   "LIMITEDRESUSCITATION"))
 DECLARE no_code_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",200,"NORESUSCITATION"))
 DECLARE fullop_code_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",200,
   "FULLPERIOPERATIVERESUSCITATION"))
 DECLARE limitedop_code_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",200,
   "LIMITEDPERIOPERATIVERESUSCITATION"))
 DECLARE noop_code_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",200,
   "NOPERIOPERATIVERESUSCITATION"))
 DECLARE op_code_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",200,
   "RESUSCITATIONPERIOPERATIVE"))
 DECLARE ht_result = f8
 DECLARE wt_result = f8
 DECLARE bsa_result = f8
 DECLARE bsa_ind = i2
 DECLARE sbp = vc
 DECLARE dbp = vc
 DECLARE bp_date = vc
 DECLARE cnt1 = i2
 DECLARE cnt2 = i2
 DECLARE cnt3 = i2
 DECLARE line = vc
 DECLARE short_line = vc
 DECLARE wrapcol = i2
 DECLARE tempstring = vc
 DECLARE eol = i4
 DECLARE comment_string = vc
 DECLARE printstring = vc
 DECLARE temprxn = vc
 DECLARE tempall = vc
 DECLARE canceled_cd = f8
 SET canceled_cd = uar_get_code_by("displaykey",12025,"CANCELED")
 DECLARE critical_value = i2
 DECLARE found = i2
 DECLARE found1 = i2
 DECLARE title = vc
 DECLARE print_title = i2
 DECLARE meds_found = i2
 DECLARE sign_cd = f8
 SET sign_cd = uar_get_code_by("displaykey",21,"SIGN")
 DECLARE snmct_cd = f8 WITH public, constant(uar_get_code_by("MEANING",400,"SNMCT"))
 DECLARE consult_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",6000,"CONSULTS"))
 DECLARE cancel_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",12030,"CANCELED"))
 DECLARE only_most_recent = i2
 IF (test_ind=1)
  CALL echo("Get patient demographic info")
 ENDIF
 SELECT INTO "nl:"
  FROM encounter e,
   person p,
   encntr_prsnl_reltn epr,
   prsnl pr,
   encntr_prsnl_reltn epr1,
   prsnl pr1,
   person_alias pa,
   encntr_alias ea,
   encntr_alias ea1,
   phone ph,
   phone phloc,
   address a
  PLAN (e
   WHERE (e.encntr_id=pt_transfer->encntr_id))
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (epr
   WHERE epr.encntr_id=outerjoin(e.encntr_id)
    AND epr.encntr_prsnl_r_cd=outerjoin(pcp_cd)
    AND epr.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
   JOIN (pr
   WHERE pr.person_id=outerjoin(epr.prsnl_person_id)
    AND pr.physician_ind=outerjoin(1))
   JOIN (epr1
   WHERE epr1.encntr_id=outerjoin(e.encntr_id)
    AND epr1.encntr_prsnl_r_cd=outerjoin(att_cd)
    AND epr1.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
   JOIN (pr1
   WHERE pr1.person_id=outerjoin(epr1.prsnl_person_id)
    AND pr1.physician_ind=outerjoin(1))
   JOIN (pa
   WHERE pa.person_id=outerjoin(e.person_id)
    AND pa.person_alias_type_cd=outerjoin(ssn_type)
    AND pa.active_ind=outerjoin(1)
    AND pa.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime)))
   JOIN (ea
   WHERE ea.encntr_id=outerjoin(e.encntr_id)
    AND ea.encntr_alias_type_cd=outerjoin(mrn_type)
    AND ea.active_ind=outerjoin(1)
    AND ea.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime)))
   JOIN (ea1
   WHERE ea1.encntr_id=outerjoin(e.encntr_id)
    AND ea1.encntr_alias_type_cd=outerjoin(fin_type)
    AND ea1.active_ind=outerjoin(1)
    AND ea1.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime)))
   JOIN (ph
   WHERE ph.parent_entity_id=outerjoin(p.person_id)
    AND ph.parent_entity_name=outerjoin("PERSON")
    AND ph.phone_type_cd=outerjoin(home_phone_cd)
    AND ph.active_ind=outerjoin(1)
    AND ph.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime)))
   JOIN (phloc
   WHERE phloc.parent_entity_id=outerjoin(e.loc_facility_cd)
    AND phloc.parent_entity_name=outerjoin("LOCATION")
    AND phloc.phone_type_cd=outerjoin(bus_phone_cd)
    AND phloc.active_ind=outerjoin(1)
    AND phloc.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime)))
   JOIN (a
   WHERE a.parent_entity_id=outerjoin(p.person_id)
    AND a.parent_entity_name=outerjoin("PERSON")
    AND a.address_type_cd=outerjoin(add_home_cd)
    AND a.active_ind=outerjoin(1)
    AND a.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime)))
  ORDER BY ph.beg_effective_dt_tm DESC, a.beg_effective_dt_tm DESC
  HEAD REPORT
   found_phone = false, found_address = false
  DETAIL
   pt_transfer->person_id = e.person_id, pt_transfer->name = trim(p.name_full_formatted), pt_transfer
   ->religion = substring(1,30,uar_get_code_display(p.religion_cd)),
   pt_transfer->dob = format(p.birth_dt_tm,"mm/dd/yy;;d"), pt_transfer->mrn = trim(ea.alias),
   pt_transfer->fin = trim(ea1.alias),
   pt_transfer->ssn = cnvtalias(trim(pa.alias),pa.alias_pool_cd), pt_transfer->admit_reason = trim(e
    .reason_for_visit), pt_transfer->reg_date = format(e.reg_dt_tm,"mm/dd/yy hh:mm;;d"),
   pt_transfer->disch_date = e.disch_dt_tm, pt_transfer->facility = trim(uar_get_code_description(e
     .loc_facility_cd)), pt_transfer->attending = substring(1,20,pr1.name_full_formatted),
   pt_transfer->pcp = substring(1,20,pr.name_full_formatted), pt_transfer->facility = trim(
    uar_get_code_display(e.loc_facility_cd))
   IF (ph.phone_id > 0
    AND found_phone=false)
    found_phone = true, pt_transfer->phone = cnvtphone(ph.phone_num,ph.phone_format_cd,2)
   ENDIF
   IF (a.address_id > 0
    AND found_address=false)
    found_address = true, pt_transfer->address_line = trim(substring(1,33,a.street_addr))
    IF (a.street_addr2 > " ")
     pt_transfer->address_line = trim(concat(trim(pt_transfer->address_line),", ",trim(a.street_addr2
        )))
    ENDIF
    pt_transfer->city_state_zip = trim(a.city)
    IF (a.state_cd > 0)
     pt_transfer->city_state_zip = concat(trim(pt_transfer->city_state_zip),", ",trim(
       uar_get_code_display(a.state_cd)))
    ELSEIF (a.state > " ")
     pt_transfer->city_state_zip = concat(trim(pt_transfer->city_state_zip),", ",trim(a.state))
    ENDIF
    IF (a.zipcode > " ")
     pt_transfer->city_state_zip = concat(trim(pt_transfer->city_state_zip)," ",trim(a.zipcode))
    ENDIF
   ENDIF
   IF ((pt_transfer->facility="BMC"))
    IF (phloc.parent_entity_id > 0)
     pt_transfer->facility_phone = cnvtphone(phloc.phone_num,phloc.phone_format_cd,2)
    ELSE
     pt_transfer->facility_phone = "(413) 794-0000"
    ENDIF
   ELSEIF ((pt_transfer->facility IN ("FMC", "BFMC")))
    IF (phloc.parent_entity_id > 0)
     pt_transfer->facility_phone = cnvtphone(phloc.phone_num,phloc.phone_format_cd,2)
    ELSE
     pt_transfer->facility_phone = "(413) 773-2000"
    ENDIF
   ELSEIF ((pt_transfer->facility IN ("MLH", "BMLH")))
    IF (phloc.parent_entity_id > 0)
     pt_transfer->facility_phone = cnvtphone(phloc.phone_num,phloc.phone_format_cd,2)
    ELSE
     pt_transfer->facility_phone = "(413) 967-2000"
    ENDIF
   ENDIF
   IF (e.loc_nurse_unit_cd > 0)
    pt_transfer->last_nurse_unit = trim(uar_get_code_display(e.loc_nurse_unit_cd))
   ENDIF
  WITH nocounter
 ;end select
 IF (test_ind=1)
  CALL echo("Determine Last Nurse Unit for Discharged encounter")
 ENDIF
 IF (size(pt_transfer->last_nurse_unit)=0)
  SELECT INTO "nl:"
   FROM encntr_loc_hist e
   WHERE (e.encntr_id=pt_transfer->encntr_id)
    AND (e.encntr_loc_hist_id=
   (SELECT
    max(e1.encntr_loc_hist_id)
    FROM encntr_loc_hist e1
    WHERE e1.encntr_id=e.encntr_id
     AND e1.beg_effective_dt_tm != e1.end_effective_dt_tm))
   DETAIL
    pt_transfer->last_nurse_unit = trim(uar_get_code_display(e.loc_nurse_unit_cd))
   WITH nocounter
  ;end select
 ENDIF
 IF (test_ind=1)
  CALL echo("Get Contacts for Encounter")
 ENDIF
 SELECT INTO "nl:"
  FROM encntr_person_reltn e,
   person p,
   phone ph
  PLAN (e
   WHERE (e.encntr_id=pt_transfer->encntr_id)
    AND e.active_ind >= 1
    AND e.person_reltn_type_cd IN (nok_cd, def_guar_cd, pcg_cd, emc_cd)
    AND e.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND e.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (p
   WHERE p.person_id=outerjoin(e.related_person_id))
   JOIN (ph
   WHERE ph.parent_entity_id=outerjoin(p.person_id)
    AND ph.parent_entity_name=outerjoin("PERSON")
    AND ph.active_ind=outerjoin(1))
  ORDER BY e.person_reltn_type_cd, e.beg_effective_dt_tm DESC
  HEAD REPORT
   cnt = 0, stat = alterlist(pt_transfer->cont_qual,3), phone = fillstring(20," "),
   ext = fillstring(8," ")
  HEAD e.person_reltn_type_cd
   cnt = (cnt+ 1)
   IF (mod(cnt,3)=1)
    stat = alterlist(pt_transfer->cont_qual,(cnt+ 3))
   ENDIF
   IF (e.person_reltn_type_cd=nok_cd)
    pt_transfer->cont_qual[cnt].name = trim(p.name_full_formatted), pt_transfer->cont_qual[cnt].
    relation = trim(uar_get_code_display(e.person_reltn_type_cd))
   ENDIF
   IF (e.person_reltn_type_cd=def_guar_cd)
    pt_transfer->cont_qual[cnt].name = trim(p.name_full_formatted), pt_transfer->cont_qual[cnt].
    relation = trim(uar_get_code_display(e.person_reltn_type_cd))
   ENDIF
   IF (e.person_reltn_type_cd=emc_cd)
    pt_transfer->cont_qual[cnt].name = trim(p.name_full_formatted), pt_transfer->cont_qual[cnt].
    relation = trim(uar_get_code_display(e.person_reltn_type_cd))
   ENDIF
   IF (e.person_reltn_type_cd=pcg_cd)
    pt_transfer->cont_qual[cnt].name = trim(p.name_full_formatted), pt_transfer->cont_qual[cnt].
    relation = trim(uar_get_code_display(e.person_reltn_type_cd))
   ENDIF
   cnt_phone = 0, stat = alterlist(pt_transfer->cont_qual[cnt].phone_qual,2)
  DETAIL
   cnt_phone = (cnt_phone+ 1)
   IF (mod(cnt_phone,2)=1)
    stat = alterlist(pt_transfer->cont_qual[cnt].phone_qual,(cnt_phone+ 2))
   ENDIF
   phone = ph.phone_num, ext = substring(1,8,ph.extension)
   IF (e.person_reltn_type_cd=nok_cd)
    IF (ph.phone_type_cd=home_phone_cd)
     pt_transfer->cont_qual[cnt].phone_qual[cnt_phone].home_phone = cnvtphone(ph.phone_num,ph
      .phone_format_cd,2)
    ELSEIF (ph.phone_type_cd=bus_phone_cd)
     pt_transfer->cont_qual[cnt].phone_qual[cnt_phone].bus_phone = cnvtphone(ph.phone_num,ph
      .phone_format_cd,2), pt_transfer->cont_qual[cnt].phone_qual[cnt_phone].ext = trim(ph.extension)
    ENDIF
   ENDIF
   IF (e.person_reltn_type_cd=def_guar_cd)
    IF (ph.phone_type_cd=home_phone_cd)
     pt_transfer->cont_qual[cnt].phone_qual[cnt_phone].home_phone = cnvtphone(ph.phone_num,ph
      .phone_format_cd,2)
    ELSEIF (ph.phone_type_cd=bus_phone_cd)
     pt_transfer->cont_qual[cnt].phone_qual[cnt_phone].bus_phone = cnvtphone(ph.phone_num,ph
      .phone_format_cd,2), pt_transfer->cont_qual[cnt].phone_qual[cnt_phone].ext = trim(ph.extension)
    ENDIF
   ENDIF
   IF (e.person_reltn_type_cd=emc_cd)
    IF (ph.phone_type_cd=home_phone_cd)
     pt_transfer->cont_qual[cnt].phone_qual[cnt_phone].home_phone = cnvtphone(ph.phone_num,ph
      .phone_format_cd,2)
    ELSEIF (ph.phone_type_cd=bus_phone_cd)
     pt_transfer->cont_qual[cnt].phone_qual[cnt_phone].bus_phone = cnvtphone(ph.phone_num,ph
      .phone_format_cd,2), pt_transfer->cont_qual[cnt].phone_qual[cnt_phone].ext = trim(ph.extension)
    ENDIF
   ENDIF
   IF (e.person_reltn_type_cd=pcg_cd)
    IF (ph.phone_type_cd=home_phone_cd)
     pt_transfer->cont_qual[cnt].phone_qual[cnt_phone].home_phone = cnvtphone(ph.phone_num,ph
      .phone_format_cd,2)
    ELSEIF (ph.phone_type_cd=bus_phone_cd)
     pt_transfer->cont_qual[cnt].phone_qual[cnt_phone].bus_phone = cnvtphone(ph.phone_num,ph
      .phone_format_cd,2), pt_transfer->cont_qual[cnt].phone_qual[cnt_phone].ext = trim(ph.extension)
    ENDIF
   ENDIF
  FOOT  e.person_reltn_type_cd
   stat = alterlist(pt_transfer->cont_qual[cnt].phone_qual,cnt_phone), pt_transfer->cont_qual[cnt].
   phone_cnt = cnt_phone
  FOOT REPORT
   stat = alterlist(pt_transfer->cont_qual,cnt), pt_transfer->cont_cnt = cnt
  WITH nocounter
 ;end select
 IF (test_ind=1)
  CALL echo("Get Insurance Information")
 ENDIF
 SELECT INTO "nl:"
  FROM encntr_plan_reltn e,
   person sub,
   organization o
  PLAN (e
   WHERE (e.encntr_id=pt_transfer->encntr_id)
    AND e.active_ind=1
    AND e.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
   JOIN (sub
   WHERE sub.person_id=e.person_id)
   JOIN (o
   WHERE o.organization_id=e.organization_id)
  ORDER BY e.encntr_plan_reltn_id
  HEAD REPORT
   cnt = 0, stat = alterlist(pt_transfer->ins_qual,3)
  HEAD e.encntr_plan_reltn_id
   cnt = (cnt+ 1)
   IF (mod(cnt,3)=1)
    stat = alterlist(pt_transfer->ins_qual,3)
   ENDIF
   pt_transfer->ins_qual[cnt].name = o.org_name, pt_transfer->ins_qual[cnt].type =
   IF (e.priority_seq=1) "Primary"
   ELSEIF (e.priority_seq=2) "Secondary"
   ELSEIF (e.priority_seq=3) "Tertiary"
   ENDIF
   , pt_transfer->ins_qual[cnt].member_nbr = e.member_nbr,
   pt_transfer->ins_qual[cnt].group_nbr = e.group_nbr, pt_transfer->ins_qual[cnt].subscriber = trim(
    sub.name_full_formatted)
  FOOT REPORT
   stat = alterlist(pt_transfer->ins_qual,cnt), pt_transfer->ins_cnt = cnt
  WITH nocounter
 ;end select
 IF (test_ind=1)
  CALL echo("Get Advance Directive results")
 ENDIF
 SELECT INTO "nl:"
  sort_event =
  IF (ce.event_cd=adv_dir) 1
  ELSEIF (ce.event_cd=adv_copy) 2
  ELSE 3
  ENDIF
  FROM clinical_event ce
  PLAN (ce
   WHERE (ce.person_id=pt_transfer->person_id)
    AND ce.event_cd IN (adv_dir, adv_type, adv_proxy, adv_phone, adv_date,
   adv_copy, adv_loc)
    AND ce.view_level=1
    AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime)
    AND ce.result_status_cd != inerror_cd)
  ORDER BY sort_event, ce.event_cd, ce.event_end_dt_tm
  HEAD REPORT
   adv_month = "  ", adv_day = "  ", adv_year = "    "
  DETAIL
   CASE (ce.event_cd)
    OF adv_dir:
     pt_transfer->adv_dir = trim(ce.result_val)
    OF adv_type:
     pt_transfer->adv_type = trim(ce.result_val)
    OF adv_proxy:
     pt_transfer->adv_proxy = trim(ce.result_val)
    OF adv_phone:
     pt_transfer->adv_phone = trim(ce.result_val)
    OF adv_date:
     adv_year = substring(3,4,ce.result_val),adv_month = substring(7,2,ce.result_val),adv_day =
     substring(9,2,ce.result_val),
     pt_transfer->adv_date = concat(trim(adv_month),"/",trim(adv_day),"/",trim(adv_year))
    OF adv_copy:
     pt_transfer->adv_copy = trim(ce.result_val)
   ENDCASE
   IF (ce.event_cd=adv_loc
    AND (pt_transfer->adv_dir="Yes")
    AND (pt_transfer->adv_copy="No"))
    pt_transfer->adv_loc = trim(ce.result_val)
   ENDIF
  WITH nocounter
 ;end select
 IF (test_ind=1)
  CALL echo("Get Allergies")
 ENDIF
 SELECT INTO "nl:"
  FROM allergy a,
   nomenclature n,
   reaction r,
   nomenclature nr
  PLAN (a
   WHERE (a.person_id=pt_transfer->person_id)
    AND a.active_ind=1
    AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND a.reaction_status_cd != canceled_cd
    AND a.cancel_dt_tm=null)
   JOIN (n
   WHERE n.nomenclature_id=outerjoin(a.substance_nom_id))
   JOIN (r
   WHERE r.allergy_id=outerjoin(a.allergy_id)
    AND r.active_ind=outerjoin(1))
   JOIN (nr
   WHERE nr.nomenclature_id=outerjoin(r.reaction_nom_id))
  ORDER BY a.onset_dt_tm, a.allergy_instance_id, a.allergy_id
  HEAD REPORT
   tempall = fillstring(100," ")
  HEAD a.onset_dt_tm
   row + 0
  HEAD a.allergy_instance_id
   row + 0
  HEAD a.allergy_id
   temprxn = fillstring(100," ")
   IF (size(trim(n.source_string)) > 0)
    tempall = trim(n.source_string)
   ELSE
    tempall = trim(a.substance_ftdesc)
   ENDIF
  DETAIL
   IF (size(trim(nr.source_string)) > 0)
    IF (temprxn > " ")
     temprxn = concat(trim(temprxn),", ",trim(nr.source_string))
    ELSE
     temprxn = trim(nr.source_string)
    ENDIF
   ELSEIF (size(trim(r.reaction_ftdesc)) > 0)
    IF (temprxn > " ")
     temprxn = concat(trim(temprxn),", ",trim(r.reaction_ftdesc))
    ELSE
     temprxn = trim(r.reaction_ftdesc)
    ENDIF
   ENDIF
  FOOT  a.allergy_id
   IF ((pt_transfer->allergies > " "))
    IF (temprxn > " ")
     pt_transfer->allergies = concat(pt_transfer->allergies,";  |",trim(tempall),"(",trim(temprxn),
      ")")
    ELSE
     pt_transfer->allergies = concat(pt_transfer->allergies,";  |",tempall)
    ENDIF
   ELSE
    IF (temprxn > " ")
     pt_transfer->allergies = concat(trim(tempall),"(",trim(temprxn),")")
    ELSE
     pt_transfer->allergies = tempall
    ENDIF
   ENDIF
   pt_transfer->allergies = replace(pt_transfer->allergies,"|","",0)
  WITH nocounter
 ;end select
 IF (test_ind=1)
  CALL echo("Get Problems")
 ENDIF
 SELECT INTO "nl"
  p.person_id, encntr_id = pt_transfer->encntr_id, p.onset_dt_tm,
  problem_string =
  IF (p.nomenclature_id=0
   AND trim(p.problem_ftdesc) > " ") trim(p.problem_ftdesc)
  ELSEIF (p.nomenclature_id > 0
   AND n.source_vocabulary_cd=snmct_cd) trim(n.source_string)
  ENDIF
  FROM problem p,
   nomenclature n,
   problem_comment pc
  PLAN (p
   WHERE (p.person_id=pt_transfer->person_id)
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ((p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)) OR (p.end_effective_dt_tm=null))
    AND p.life_cycle_status_cd != cancel_cd)
   JOIN (n
   WHERE n.nomenclature_id=outerjoin(p.nomenclature_id)
    AND n.source_vocabulary_cd=outerjoin(snmct_cd))
   JOIN (pc
   WHERE pc.problem_id=outerjoin(p.problem_id))
  ORDER BY p.person_id, encntr_id, p.onset_dt_tm DESC,
   problem_string
  HEAD p.person_id
   row + 0
  HEAD encntr_id
   prob_cnt = 0
  HEAD problem_string
   IF (size(trim(problem_string,3)) > 0)
    prob_cnt = (prob_cnt+ 1), stat = alterlist(pt_transfer->problem,prob_cnt), pt_transfer->
    problem_cnt = prob_cnt,
    pt_transfer->problem[prob_cnt].name = trim(problem_string,3), pt_transfer->problem[prob_cnt].
    status = uar_get_code_display(p.life_cycle_status_cd), pt_transfer->problem[prob_cnt].onset_date
     = substring(1,14,format(p.onset_dt_tm,"@SHORTDATETIME;;Q")),
    comm_cnt = 0
   ENDIF
  DETAIL
   IF (size(trim(problem_string,3)) > 0
    AND size(trim(pc.problem_comment,3)) > 0)
    comm_cnt = (comm_cnt+ 1), stat = alterlist(pt_transfer->problem[prob_cnt].comments,comm_cnt),
    pt_transfer->problem[prob_cnt].comment_cnt = comm_cnt,
    pt_transfer->problem[prob_cnt].comments[comm_cnt].comment = trim(pc.problem_comment), pt_transfer
    ->problem[prob_cnt].comments[comm_cnt].date = format(pc.comment_dt_tm,"mm/dd/yy hh:mm;;d")
   ENDIF
  WITH nocounter
 ;end select
 IF (test_ind=1)
  CALL echo("GetImmunizations")
 ENDIF
 SELECT INTO "nl:"
  FROM clinical_event ce,
   ce_med_result cem
  PLAN (ce
   WHERE (ce.person_id=pt_transfer->person_id)
    AND ((ce.event_cd IN (1596099.00, 807931.00)
    AND ((ce.event_end_dt_tm >= cnvtdatetime(datetimeadd(pt_transfer->disch_date,- (365.0)))
    AND (pt_transfer->disch_date > 0)) OR (ce.event_end_dt_tm >= cnvtdatetime((curdate - 365),curtime
    ))) ) OR (ce.event_cd IN (1698425.00, 744306.00)
    AND ((ce.event_end_dt_tm >= cnvtdatetime(datetimeadd(pt_transfer->disch_date,- (1825.0)))
    AND (pt_transfer->disch_date > 0)) OR (ce.event_end_dt_tm >= cnvtdatetime((curdate - 1825),
    curtime))) ))
    AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime)
    AND ce.result_status_cd != inerror_cd)
   JOIN (cem
   WHERE cem.event_id=ce.event_id)
  ORDER BY cem.admin_start_dt_tm DESC
  HEAD REPORT
   stat = alterlist(pt_transfer->immun,5), immun_cnt = 0
  DETAIL
   immun_cnt = (immun_cnt+ 1)
   IF (mod(immun_cnt,5)=1)
    stat = alterlist(pt_transfer->immun,(immun_cnt+ 5))
   ENDIF
   pt_transfer->immun[immun_cnt].name = trim(uar_get_code_display(ce.event_cd),3), pt_transfer->
   immun[immun_cnt].given_date = format(cem.admin_start_dt_tm,"mm/dd/yy hh:mm;;d")
  FOOT REPORT
   stat = alterlist(pt_transfer->immun,immun_cnt), pt_transfer->immun_cnt = immun_cnt
  WITH nocounter
 ;end select
 IF (test_ind=1)
  CALL echo("Get Vitals")
 ENDIF
 SELECT INTO "nl:"
  sort_item =
  IF (ce.event_cd=wt_cd) 1
  ELSEIF (ce.event_cd=bsa_cd) 2
  ELSE 3
  ENDIF
  FROM clinical_event ce
  PLAN (ce
   WHERE (ce.encntr_id=pt_transfer->encntr_id)
    AND ((ce.event_cd IN (temp_cd, pulse_cd, resp_rate_cd, systolic_bp_cd, diastolic_bp_cd,
   o2_sat_cd)
    AND (((pt_transfer->disch_date > 0)
    AND ce.event_end_dt_tm >= cnvtdatetime(datetimeadd(pt_transfer->disch_date,- (1.0)))) OR (ce
   .event_end_dt_tm >= cnvtdatetime((curdate - 1),curtime))) ) OR (ce.event_cd IN (bmi_cd, bsa_cd,
   ht_cd, wt_cd)))
    AND ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime)
    AND ce.view_level=1
    AND ce.result_status_cd != inerror_cd)
  ORDER BY sort_item, ce.event_end_dt_tm DESC, ce.event_cd
  HEAD REPORT
   stat = alterlist(pt_transfer->vitals,10), vit_cnt = 0, stat = alterlist(pt_transfer->special_vit,5
    ),
   spec_vit_cnt = 0, sbp = "", dbp = "",
   bp_date = "", ht_result = 0.00, wt_result = 0.00,
   bsa_result = 0.00, bsa_ind = 0, cnt1 = 0,
   cnt2 = 0, cnt3 = 0
  HEAD sort_item
   IF (ce.event_cd=wt_cd)
    wt_event_date = ce.event_end_dt_tm
   ELSEIF (ce.event_cd=bsa_cd)
    bsa_event_date = ce.event_end_dt_tm
   ENDIF
  HEAD ce.event_end_dt_tm
   sbp = "", dbp = "", bp_date = ""
  HEAD ce.event_cd
   IF (((ce.event_cd IN (bmi_cd, wt_cd, ht_cd)) OR (ce.event_cd=bsa_cd
    AND ce.event_end_dt_tm=bsa_event_date)) )
    IF (ce.event_cd=bmi_cd
     AND cnt1=0)
     cnt1 = 1, spec_vit_cnt = (spec_vit_cnt+ 1)
     IF (mod(spec_vit_cnt,5)=1)
      stat = alterlist(pt_transfer->special_vit,(spec_vit_cnt+ 5))
     ENDIF
     pt_transfer->special_vit[spec_vit_cnt].vit_date = format(ce.event_end_dt_tm,"mm/dd/yy hh:mm;;d"),
     pt_transfer->special_vit[spec_vit_cnt].vit_name = trim(uar_get_code_display(ce.event_cd)),
     pt_transfer->special_vit[spec_vit_cnt].vit_result = trim(ce.result_val),
     pt_transfer->special_vit[spec_vit_cnt].vit_unit = trim(uar_get_code_display(ce.result_units_cd))
    ELSEIF (ce.event_cd=bsa_cd
     AND ce.event_end_dt_tm=bsa_event_date
     AND bsa_event_date >= wt_event_date)
     bsa_ind = 1, spec_vit_cnt = (spec_vit_cnt+ 1)
     IF (mod(spec_vit_cnt,5)=1)
      stat = alterlist(pt_transfer->special_vit,(spec_vit_cnt+ 5))
     ENDIF
     pt_transfer->special_vit[spec_vit_cnt].vit_date = format(ce.event_end_dt_tm,"mm/dd/yy hh:mm;;d"),
     pt_transfer->special_vit[spec_vit_cnt].vit_name = trim(uar_get_code_display(ce.event_cd)),
     pt_transfer->special_vit[spec_vit_cnt].vit_result = trim(ce.result_val),
     pt_transfer->special_vit[spec_vit_cnt].vit_unit = trim(uar_get_code_display(ce.result_units_cd))
    ELSEIF (ce.event_cd=ht_cd
     AND cnt2=0)
     cnt2 = 1, spec_vit_cnt = (spec_vit_cnt+ 1)
     IF (mod(spec_vit_cnt,5)=1)
      stat = alterlist(pt_transfer->special_vit,(spec_vit_cnt+ 5))
     ENDIF
     ht_result = cnvtreal(trim(ce.result_val)), pt_transfer->special_vit[spec_vit_cnt].vit_date =
     format(ce.event_end_dt_tm,"mm/dd/yy hh:mm;;d"), pt_transfer->special_vit[spec_vit_cnt].vit_name
      = trim(uar_get_code_display(ce.event_cd)),
     pt_transfer->special_vit[spec_vit_cnt].vit_result = trim(ce.result_val), pt_transfer->
     special_vit[spec_vit_cnt].vit_unit = trim(uar_get_code_display(ce.result_units_cd))
    ELSEIF (ce.event_cd=wt_cd
     AND cnt3=0)
     cnt3 = 1, spec_vit_cnt = (spec_vit_cnt+ 1)
     IF (mod(spec_vit_cnt,5)=1)
      stat = alterlist(pt_transfer->special_vit,(spec_vit_cnt+ 5))
     ENDIF
     wt_result = cnvtreal(trim(ce.result_val)), pt_transfer->special_vit[spec_vit_cnt].vit_date =
     format(ce.event_end_dt_tm,"mm/dd/yy hh:mm;;d"), pt_transfer->special_vit[spec_vit_cnt].vit_name
      = trim(uar_get_code_display(ce.event_cd)),
     pt_transfer->special_vit[spec_vit_cnt].vit_result = trim(ce.result_val), pt_transfer->
     special_vit[spec_vit_cnt].vit_unit = trim(uar_get_code_display(ce.result_units_cd))
    ENDIF
   ENDIF
  DETAIL
   IF (ce.event_cd IN (temp_cd, pulse_cd, resp_rate_cd, o2_sat_cd))
    vit_cnt = (vit_cnt+ 1)
    IF (mod(vit_cnt,10)=1)
     stat = alterlist(pt_transfer->vitals,(vit_cnt+ 10))
    ENDIF
    pt_transfer->vitals[vit_cnt].vit_name = trim(uar_get_code_display(ce.event_cd)), pt_transfer->
    vitals[vit_cnt].vit_date = format(ce.event_end_dt_tm,"mm/dd/yy hh:mm;;d"), pt_transfer->vitals[
    vit_cnt].vit_result = trim(ce.result_val),
    pt_transfer->vitals[vit_cnt].vit_unit = trim(uar_get_code_display(ce.result_units_cd))
   ELSEIF (ce.event_cd IN (systolic_bp_cd, diastolic_bp_cd))
    IF (ce.event_cd=systolic_bp_cd)
     bp_date = format(ce.event_end_dt_tm,"mm/dd/yy hh:mm;;d"), sbp = trim(ce.result_val)
    ELSEIF (ce.event_cd=diastolic_bp_cd)
     dbp = trim(ce.result_val)
    ENDIF
   ENDIF
  FOOT  ce.event_cd
   row + 0
  FOOT  ce.event_end_dt_tm
   IF (sbp > " "
    AND dbp > " ")
    vit_cnt = (vit_cnt+ 1)
    IF (mod(vit_cnt,10)=1)
     stat = alterlist(pt_transfer->vitals,(vit_cnt+ 10))
    ENDIF
    pt_transfer->vitals[vit_cnt].vit_name = "Blood Pressure", pt_transfer->vitals[vit_cnt].vit_date
     = bp_date, pt_transfer->vitals[vit_cnt].vit_result = build(sbp,"/",dbp)
   ENDIF
  FOOT  sort_item
   row + 0
  FOOT REPORT
   IF (bsa_ind=0
    AND ht_result > 0
    AND wt_result > 0)
    spec_vit_cnt = (spec_vit_cnt+ 1)
    IF (mod(spec_vit_cnt,5)=1)
     stat = alterlist(pt_transfer->special_vit,(spec_vit_cnt+ 5))
    ENDIF
    bsa_result = (((ht_result * wt_result)/ 3600.00)** 0.50), pt_transfer->special_vit[spec_vit_cnt].
    vit_result = trim(format(bsa_result,"#####.##"),3), pt_transfer->special_vit[spec_vit_cnt].
    vit_name = "BSA",
    pt_transfer->special_vit[spec_vit_cnt].vit_date = "Calculated"
   ENDIF
   pt_transfer->vitals_cnt = vit_cnt, stat = alterlist(pt_transfer->vitals,vit_cnt), pt_transfer->
   special_vit_cnt = spec_vit_cnt,
   stat = alterlist(pt_transfer->special_vit,spec_vit_cnt)
  WITH nocounter
 ;end select
 IF (test_ind=1)
  CALL echo("Get Micro and Gen Lab")
 ENDIF
 SELECT INTO "nl:"
  event_name = cnvtupper(uar_get_code_display(ce.event_cd)), clinsig_updt_dt_tm = format(ce
   .clinsig_updt_dt_tm,"mm/dd/yyyy hh:mm;;D"), collect_dt_tm = format(ce.event_end_dt_tm,
   "mm/dd/yyyy hh:mm;;d"),
  result_status = uar_get_code_display(ce.result_status_cd), event_name = cnvtupper(
   uar_get_code_display(ce.event_cd))
  FROM orders o,
   clinical_event ce,
   ce_blob ceb,
   ce_event_note cen,
   long_blob lb
  PLAN (o
   WHERE (o.encntr_id=pt_transfer->encntr_id)
    AND o.catalog_type_cd=laboratory_cd
    AND o.activity_type_cd IN (gen_lab_cd, micro_cd)
    AND o.template_order_flag IN (0, 2))
   JOIN (ce
   WHERE ce.order_id=o.order_id
    AND ce.view_level=1
    AND ce.publish_flag=1
    AND ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime)
    AND ce.result_status_cd IN (final_cd, modified_cd, prelim_cd)
    AND (((pt_transfer->disch_date > 0)
    AND ce.event_end_dt_tm >= cnvtdatetime(datetimeadd(pt_transfer->disch_date,- (14.0)))
    AND ce.event_end_dt_tm <= cnvtdatetime(pt_transfer->disch_date)) OR (((ce.event_end_dt_tm+ 0) >=
   cnvtdatetime((curdate - 14),curtime))
    AND ((ce.event_end_dt_tm+ 0) <= cnvtdatetime(curdate,curtime)))) )
   JOIN (ceb
   WHERE ceb.event_id=outerjoin(ce.event_id)
    AND ceb.valid_until_dt_tm > outerjoin(cnvtdatetime(curdate,curtime)))
   JOIN (cen
   WHERE cen.event_id=outerjoin(ce.event_id)
    AND cen.valid_until_dt_tm > outerjoin(cnvtdatetime(curdate,curtime)))
   JOIN (lb
   WHERE lb.parent_entity_id=outerjoin(cen.ce_event_note_id))
  ORDER BY event_name, ce.event_end_dt_tm DESC, ce.event_id
  HEAD REPORT
   stat = alterlist(pt_transfer->micro_results,10), micro_cnt = 0, lab_cnt = 0,
   stat = alterlist(pt_transfer->lab_results,10)
  HEAD ce.event_id
   IF (o.activity_type_cd IN (micro_cd))
    micro_cnt = (micro_cnt+ 1)
    IF (mod(micro_cnt,10)=1
     AND micro_cnt != 1)
     stat = alterlist(pt_transfer->micro_results,(micro_cnt+ 10))
    ENDIF
    pt_transfer->micro_results[micro_cnt].parent_event_id = ce.parent_event_id, pt_transfer->
    micro_results[micro_cnt].event_id = ce.event_id, pt_transfer->micro_results[micro_cnt].event_name
     = trim(uar_get_code_display(ce.event_cd)),
    pt_transfer->micro_results[micro_cnt].clinsig_updt_dt_tm = clinsig_updt_dt_tm, pt_transfer->
    micro_results[micro_cnt].collect_dt_tm = collect_dt_tm, pt_transfer->micro_results[micro_cnt].
    result_status = result_status,
    pt_transfer->micro_results[micro_cnt].event_id = ceb.event_id, pt_transfer->micro_results[
    micro_cnt].blob_contents = ceb.blob_contents, pt_transfer->micro_results[micro_cnt].comp_cd = ceb
    .compression_cd,
    pt_transfer->micro_results[micro_cnt].blobseq = ceb.blob_seq_num, pt_transfer->micro_results[
    micro_cnt].comment_comp_cd = cen.compression_cd, pt_transfer->micro_results[micro_cnt].
    result_comments = trim(lb.long_blob)
   ELSEIF (o.activity_type_cd IN (gen_lab_cd)
    AND ce.result_val > " ")
    lab_cnt = (lab_cnt+ 1)
    IF (mod(lab_cnt,10)=1)
     stat = alterlist(pt_transfer->lab_results,(lab_cnt+ 10))
    ENDIF
    pt_transfer->lab_results[lab_cnt].event_id = ce.event_id, pt_transfer->lab_results[lab_cnt].
    event_cd_disp = trim(uar_get_code_display(ce.event_cd)), pt_transfer->lab_results[lab_cnt].date
     = format(ce.event_end_dt_tm,"mm/dd hh:mm;;d"),
    pt_transfer->lab_results[lab_cnt].normalcy_disp = trim(uar_get_code_display(ce.normalcy_cd)),
    pt_transfer->lab_results[lab_cnt].result_val = trim(ce.result_val), pt_transfer->lab_results[
    lab_cnt].units = trim(uar_get_code_display(ce.result_units_cd)),
    pt_transfer->lab_results[lab_cnt].comment_comp_cd = cen.compression_cd, pt_transfer->lab_results[
    lab_cnt].result_comments = trim(lb.long_blob)
    IF (ce.normal_low > " "
     AND ce.normal_high > " "
     AND ce.result_val != "Pending")
     pt_transfer->lab_results[lab_cnt].ref_range = concat("(",trim(ce.normal_low)," - ",trim(ce
       .normal_high),")")
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(pt_transfer->micro_results,micro_cnt), pt_transfer->micro_cnt = micro_cnt, stat
    = alterlist(pt_transfer->lab_results,lab_cnt),
   pt_transfer->lab_results_cnt = lab_cnt
  WITH maxcol = 400, memsort
 ;end select
 IF (test_ind=1)
  CALL echo("Get last CBC")
 ENDIF
 SELECT INTO "nl:"
  event_name = cnvtupper(uar_get_code_display(ce.event_cd)), clinsig_updt_dt_tm = format(ce
   .clinsig_updt_dt_tm,"mm/dd/yyyy hh:mm;;D"), collect_dt_tm = format(ce.event_end_dt_tm,
   "mm/dd/yyyy hh:mm;;d"),
  result_status = uar_get_code_display(ce.result_status_cd), sort_catalog =
  IF (o.catalog_cd IN (cbc1_cd, cbc2_cd, cbc3_cd)) 1
  ELSEIF (o.catalog_cd=lytes_cd) 2
  ELSEIF (o.catalog_cd=bun_cd) 3
  ELSEIF (o.catalog_cd=creat_cd) 4
  ELSEIF (o.catalog_cd=inr_cd) 5
  ENDIF
  FROM orders o,
   clinical_event ce,
   ce_event_note cen,
   long_blob lb
  PLAN (o
   WHERE (o.person_id=pt_transfer->person_id)
    AND (o.encntr_id=pt_transfer->encntr_id)
    AND o.catalog_cd IN (cbc1_cd, cbc2_cd, cbc3_cd, lytes_cd, bun_cd,
   creat_cd, inr_cd))
   JOIN (ce
   WHERE ce.order_id=o.order_id
    AND ce.view_level=1
    AND ce.publish_flag=1
    AND ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime)
    AND ce.result_status_cd IN (final_cd, modified_cd)
    AND ce.result_val > " ")
   JOIN (cen
   WHERE cen.event_id=outerjoin(ce.event_id)
    AND cen.valid_until_dt_tm > outerjoin(cnvtdatetime(curdate,curtime)))
   JOIN (lb
   WHERE lb.parent_entity_id=outerjoin(cen.ce_event_note_id))
  ORDER BY sort_catalog, ce.event_cd, ce.event_end_dt_tm DESC
  HEAD REPORT
   stat = alterlist(pt_transfer->special_labs,5), spec_cnt = 0
  HEAD sort_catalog
   spec_cnt = (spec_cnt+ 1)
   IF (mod(spec_cnt,5)=1)
    stat = alterlist(pt_transfer->special_labs,(spec_cnt+ 5))
   ENDIF
   pt_transfer->special_labs[spec_cnt].order_date = format(ce.event_end_dt_tm,"mm/dd/yy hh:mm;;d"),
   pt_transfer->special_labs[spec_cnt].order_name = trim(uar_get_code_display(o.catalog_cd)), res_cnt
    = 0,
   stat = alterlist(pt_transfer->special_labs[spec_cnt].result_qual,10)
  HEAD ce.event_cd
   IF ( NOT (trim(uar_get_code_display(ce.event_cd)) IN ("NAFGFR", "GFREST")))
    res_cnt = (res_cnt+ 1)
    IF (mod(res_cnt,10)=1)
     stat = alterlist(pt_transfer->special_labs[spec_cnt].result_qual,(res_cnt+ 10))
    ENDIF
    pt_transfer->special_labs[spec_cnt].result_qual[res_cnt].result_name = trim(uar_get_code_display(
      ce.event_cd)), pt_transfer->special_labs[spec_cnt].result_qual[res_cnt].result_date = format(ce
     .event_end_dt_tm,"mm/dd/yy hh:mm;;d"), pt_transfer->special_labs[spec_cnt].result_qual[res_cnt].
    result_val = trim(ce.result_val,3),
    pt_transfer->special_labs[spec_cnt].result_qual[res_cnt].units = trim(uar_get_code_display(ce
      .result_units_cd),3), pt_transfer->special_labs[spec_cnt].result_qual[res_cnt].normalcy_disp =
    trim(uar_get_code_display(ce.normalcy_cd),3), pt_transfer->special_labs[spec_cnt].result_qual[
    res_cnt].comment_comp_cd = cen.compression_cd,
    pt_transfer->special_labs[spec_cnt].result_qual[res_cnt].result_comments = trim(lb.long_blob)
    IF (ce.normal_low > " "
     AND ce.normal_high > " "
     AND ce.result_val != "Pending")
     pt_transfer->special_labs[spec_cnt].result_qual[res_cnt].ref_range = concat("(",trim(ce
       .normal_low)," - ",trim(ce.normal_high),")")
    ENDIF
   ENDIF
  FOOT  sort_catalog
   stat = alterlist(pt_transfer->special_labs[spec_cnt].result_qual,res_cnt), pt_transfer->
   special_labs[spec_cnt].result_cnt = res_cnt
  FOOT REPORT
   stat = alterlist(pt_transfer->special_labs,spec_cnt), pt_transfer->special_labs_cnt = spec_cnt
  WITH maxcol = 400
 ;end select
 IF (test_ind=1)
  CALL echo("Get meds (Sched)")
 ENDIF
 SELECT INTO "nl:"
  FROM orders o,
   order_action oa
  PLAN (o
   WHERE (o.person_id=pt_transfer->person_id)
    AND (o.encntr_id=pt_transfer->encntr_id)
    AND o.order_status_cd != os_canc_cd
    AND o.catalog_type_cd=pharmacy_cd
    AND o.rx_mask > 0
    AND trim(o.dept_misc_line) > ""
    AND o.template_order_id=0)
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.order_status_cd IN (os_ord_cd, os_com_cd, os_disc_cd))
  ORDER BY o.order_id, oa.action_dt_tm DESC, oa.order_status_cd
  HEAD REPORT
   sordercnt = 0, pordercnt = 0, cordercnt = 0
  HEAD o.order_id
   only_most_recent = 0
   IF ((pt_transfer->disch_date=0))
    IF (((oa.order_status_cd=os_ord_cd) OR (oa.order_status_cd IN (os_com_cd, os_disc_cd)
     AND oa.action_dt_tm >= cnvtdatetime((curdate - 7),curtime))) )
     IF (o.prn_ind=0
      AND o.med_order_type_cd != iv_type_cd)
      sordercnt = (sordercnt+ 1)
      IF (mod(sordercnt,10)=1)
       stat = alterlist(scheduled_orders->qual,(sordercnt+ 9))
      ENDIF
      scheduled_orders->qual[sordercnt].order_id = o.order_id, scheduled_orders->qual[sordercnt].
      true_parent = 1, scheduled_orders->qual[sordercnt].order_name = build(o.order_mnemonic,"(",o
       .ordered_as_mnemonic,")"),
      scheduled_orders->qual[sordercnt].order_detail = trim(o.clinical_display_line),
      scheduled_orders->qual[sordercnt].stop_dt = o.projected_stop_dt_tm, scheduled_orders->qual[
      sordercnt].action_type = trim(uar_get_code_display(oa.order_status_cd))
     ELSEIF (o.prn_ind=1
      AND o.med_order_type_cd != iv_type_cd)
      pordercnt = (pordercnt+ 1)
      IF (mod(pordercnt,10)=1)
       stat = alterlist(prn_orders->qual,(pordercnt+ 9))
      ENDIF
      prn_orders->qual[pordercnt].order_id = o.order_id, prn_orders->qual[pordercnt].order_name =
      build(o.order_mnemonic,"(",o.ordered_as_mnemonic,")"), prn_orders->qual[pordercnt].order_detail
       = o.clinical_display_line,
      prn_orders->qual[pordercnt].stop_dt = o.projected_stop_dt_tm, prn_orders->qual[pordercnt].
      action_type = trim(uar_get_code_display(oa.order_status_cd))
     ELSEIF (o.prn_ind=0
      AND o.med_order_type_cd=iv_type_cd)
      cordercnt = (cordercnt+ 1)
      IF (mod(cordercnt,10)=1)
       stat = alterlist(continuous_orders->qual,(cordercnt+ 9))
      ENDIF
      continuous_orders->qual[cordercnt].order_id = o.order_id, continuous_orders->qual[cordercnt].
      order_name = build(o.order_mnemonic,"(",o.ordered_as_mnemonic,")"), continuous_orders->qual[
      cordercnt].order_detail = o.clinical_display_line,
      continuous_orders->qual[cordercnt].stop_dt = o.projected_stop_dt_tm, continuous_orders->qual[
      cordercnt].action_type = trim(uar_get_code_display(oa.order_status_cd))
     ENDIF
    ENDIF
   ENDIF
  HEAD oa.action_dt_tm
   row + 0
  HEAD oa.order_status_cd
   IF ((pt_transfer->disch_date > 0))
    IF (oa.order_status_cd IN (os_com_cd, os_disc_cd)
     AND oa.action_dt_tm >= cnvtdatetime(datetimeadd(pt_transfer->disch_date,- (7.0)))
     AND oa.action_dt_tm < cnvtdatetime(pt_transfer->disch_date))
     only_most_recent = (only_most_recent+ 1)
    ELSEIF (oa.order_status_cd IN (os_com_cd, os_disc_cd)
     AND oa.action_dt_tm <= cnvtdatetime(datetimeadd(pt_transfer->disch_date,- (7.0))))
     only_most_recent = 2
    ELSEIF (oa.order_status_cd=os_ord_cd
     AND oa.action_dt_tm < cnvtdatetime(pt_transfer->disch_date))
     only_most_recent = (only_most_recent+ 1)
    ENDIF
   ENDIF
  FOOT  oa.order_status_cd
   IF (only_most_recent=1)
    IF (o.prn_ind=0
     AND o.med_order_type_cd != iv_type_cd)
     sordercnt = (sordercnt+ 1)
     IF (mod(sordercnt,10)=1)
      stat = alterlist(scheduled_orders->qual,(sordercnt+ 9))
     ENDIF
     scheduled_orders->qual[sordercnt].order_id = o.order_id, scheduled_orders->qual[sordercnt].
     true_parent = 1, scheduled_orders->qual[sordercnt].order_name = build(o.order_mnemonic,"(",o
      .ordered_as_mnemonic,")"),
     scheduled_orders->qual[sordercnt].order_detail = trim(o.clinical_display_line), scheduled_orders
     ->qual[sordercnt].stop_dt = o.projected_stop_dt_tm, scheduled_orders->qual[sordercnt].
     action_type = trim(uar_get_code_display(oa.order_status_cd))
    ELSEIF (o.prn_ind=1
     AND o.med_order_type_cd != iv_type_cd)
     pordercnt = (pordercnt+ 1)
     IF (mod(pordercnt,10)=1)
      stat = alterlist(prn_orders->qual,(pordercnt+ 9))
     ENDIF
     prn_orders->qual[pordercnt].order_id = o.order_id, prn_orders->qual[pordercnt].order_name =
     build(o.order_mnemonic,"(",o.ordered_as_mnemonic,")"), prn_orders->qual[pordercnt].order_detail
      = o.clinical_display_line,
     prn_orders->qual[pordercnt].stop_dt = o.projected_stop_dt_tm, prn_orders->qual[pordercnt].
     action_type = trim(uar_get_code_display(oa.order_status_cd))
    ELSEIF (o.prn_ind=0
     AND o.med_order_type_cd=iv_type_cd)
     cordercnt = (cordercnt+ 1)
     IF (mod(cordercnt,10)=1)
      stat = alterlist(continuous_orders->qual,(cordercnt+ 9))
     ENDIF
     continuous_orders->qual[cordercnt].order_id = o.order_id, continuous_orders->qual[cordercnt].
     order_name = build(o.order_mnemonic,"(",o.ordered_as_mnemonic,")"), continuous_orders->qual[
     cordercnt].order_detail = o.clinical_display_line,
     continuous_orders->qual[cordercnt].stop_dt = o.projected_stop_dt_tm, continuous_orders->qual[
     cordercnt].action_type = trim(uar_get_code_display(oa.order_status_cd))
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(scheduled_orders->qual,sordercnt), stat = alterlist(prn_orders->qual,pordercnt),
   stat = alterlist(continuous_orders->qual,cordercnt)
  WITH nocounter
 ;end select
 IF (test_ind=1)
  CALL echo("Scheduled meds")
 ENDIF
 SET sch_med_cnt = size(scheduled_orders->qual,0)
 IF (sch_med_cnt > 0)
  SELECT DISTINCT INTO "nl:"
   check = decode(cmr.seq,"cmr",ccr.seq,"ccr",csr.seq,
    "csr"), template_order_id = scheduled_orders->qual[d1.seq].order_id
   FROM orders o,
    order_action oa,
    clinical_event ce,
    ce_med_result cmr,
    ce_coded_result ccr,
    ce_string_result csr,
    (dummyt d1  WITH seq = value(size(scheduled_orders->qual,5))),
    dummyt d2,
    dummyt d3,
    dummyt d4
   PLAN (d1)
    JOIN (o
    WHERE (o.template_order_id=scheduled_orders->qual[d1.seq].order_id)
     AND (scheduled_orders->qual[d1.seq].true_parent=1))
    JOIN (oa
    WHERE oa.order_id=o.template_order_id
     AND oa.core_ind=1)
    JOIN (ce
    WHERE ce.order_id=o.order_id
     AND (ce.person_id=pt_transfer->person_id)
     AND ce.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100")
     AND ce.event_class_cd=med_type_cd
     AND ce.publish_flag=1
     AND ce.result_status_cd != inerror_cd)
    JOIN (d2)
    JOIN (((cmr
    WHERE cmr.event_id=ce.event_id
     AND cmr.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100"))
    ) ORJOIN ((d3)
    JOIN (((ccr
    WHERE ccr.event_id=ce.event_id
     AND ce.result_status_cd=not_done_cd
     AND ccr.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100"))
    ) ORJOIN ((d4)
    JOIN (csr
    WHERE csr.event_id=ce.event_id
     AND ce.result_status_cd=not_done_cd
     AND csr.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100"))
    )) ))
   ORDER BY template_order_id DESC, oa.action_sequence DESC, ce.event_end_dt_tm DESC
   HEAD REPORT
    actioncnt = 0, admincnt = 0
   HEAD template_order_id
    schedordercnt = (schedordercnt+ 1), stat = alterlist(scheduled_orders_disp->scheduled_orders,
     schedordercnt), scheduled_orders_disp->scheduled_orders[schedordercnt].template_order_id =
    template_order_id,
    scheduled_orders_disp->scheduled_orders[schedordercnt].orig_order_dt_tm = o.orig_order_dt_tm,
    scheduled_orders_disp->scheduled_orders[schedordercnt].mnemonic = o.order_mnemonic,
    scheduled_orders_disp->scheduled_orders[schedordercnt].ordered_as_mnemonic = o
    .ordered_as_mnemonic,
    scheduled_orders_disp->scheduled_orders[schedordercnt].hna_mnemonic = o.hna_order_mnemonic,
    scheduled_orders_disp->scheduled_orders[schedordercnt].stop_dt = scheduled_orders->qual[d1.seq].
    stop_dt, scheduled_orders_disp->scheduled_orders[schedordercnt].action_type = scheduled_orders->
    qual[d1.seq].action_type
   HEAD oa.action_sequence
    actioncnt = (actioncnt+ 1), stat = alterlist(scheduled_orders_disp->scheduled_orders[
     schedordercnt].core_actions,actioncnt), scheduled_orders_disp->scheduled_orders[schedordercnt].
    core_actions[actioncnt].order_id = oa.order_id,
    scheduled_orders_disp->scheduled_orders[schedordercnt].core_actions[actioncnt].action_seq = oa
    .action_sequence, scheduled_orders_disp->scheduled_orders[schedordercnt].core_actions[actioncnt].
    action_dt_tm = oa.action_dt_tm, scheduled_orders_disp->scheduled_orders[schedordercnt].
    core_actions[actioncnt].action = uar_get_code_display(oa.action_type_cd),
    scheduled_orders_disp->scheduled_orders[schedordercnt].core_actions[actioncnt].
    clinical_display_line = oa.clinical_display_line
   DETAIL
    IF (actioncnt=1)
     admincnt = (admincnt+ 1), stat = alterlist(scheduled_orders_disp->scheduled_orders[schedordercnt
      ].admins,admincnt), scheduled_orders_disp->scheduled_orders[schedordercnt].admins[admincnt].
     order_id = o.order_id,
     scheduled_orders_disp->scheduled_orders[schedordercnt].admins[admincnt].parent_event_id = ce
     .parent_event_id, scheduled_orders_disp->scheduled_orders[schedordercnt].admins[admincnt].
     event_id = ce.event_id, scheduled_orders_disp->scheduled_orders[schedordercnt].admins[admincnt].
     verified_dt_tm = ce.verified_dt_tm,
     scheduled_orders_disp->scheduled_orders[schedordercnt].admins[admincnt].verified_prsnl_id = ce
     .verified_prsnl_id, scheduled_orders_disp->scheduled_orders[schedordercnt].admins[admincnt].
     valid_from_dt_tm = ce.valid_from_dt_tm, scheduled_orders_disp->scheduled_orders[schedordercnt].
     admins[admincnt].event_title_text = ce.event_title_text,
     scheduled_orders_disp->scheduled_orders[schedordercnt].admins[admincnt].event_end_dt_tm = ce
     .event_end_dt_tm, scheduled_orders_disp->scheduled_orders[schedordercnt].admins[admincnt].
     result_status_meaning = uar_get_code_meaning(ce.result_status_cd), scheduled_orders_disp->
     scheduled_orders[schedordercnt].admins[admincnt].result_status_display = uar_get_code_display(ce
      .result_status_cd),
     scheduled_orders_disp->scheduled_orders[schedordercnt].admins[admincnt].admin_by_id = ce
     .performed_prsnl_id
     IF (check="cmr")
      scheduled_orders_disp->scheduled_orders[schedordercnt].admins[admincnt].admin_start_dt_tm = cmr
      .admin_start_dt_tm, scheduled_orders_disp->scheduled_orders[schedordercnt].admins[admincnt].
      dosage_unit = uar_get_code_display(cmr.dosage_unit_cd), scheduled_orders_disp->
      scheduled_orders[schedordercnt].admins[admincnt].dosage_value = cmr.admin_dosage,
      scheduled_orders_disp->scheduled_orders[schedordercnt].admins[admincnt].site =
      uar_get_code_display(cmr.admin_site_cd), scheduled_orders_disp->scheduled_orders[schedordercnt]
      .admins[admincnt].route = uar_get_code_display(cmr.admin_route_cd)
     ELSEIF (check="ccr")
      scheduled_orders_disp->scheduled_orders[schedordercnt].admins[admincnt].not_given_reason =
      uar_get_code_display(ccr.result_cd), scheduled_orders_disp->scheduled_orders[schedordercnt].
      admins[admincnt].from_ccr = 1
     ELSE
      IF ((scheduled_orders_disp->scheduled_orders[schedordercnt].admins[admincnt].from_ccr != 1))
       scheduled_orders_disp->scheduled_orders[schedordercnt].admins[admincnt].not_given_reason = csr
       .string_result_text
      ENDIF
     ENDIF
    ENDIF
   FOOT  oa.action_sequence
    stat = alterlist(scheduled_orders_disp->scheduled_orders[schedordercnt].admins,admincnt),
    max_num_sched_admins = maxval(max_num_sched_admins,admincnt)
   FOOT  template_order_id
    stat = alterlist(scheduled_orders_disp->scheduled_orders[schedordercnt].core_actions,actioncnt),
    max_num_sched_actions = maxval(max_num_sched_actions,actioncnt), admincnt = 0,
    actioncnt = 0
   WITH nocounter
  ;end select
 ENDIF
 IF (test_ind=1)
  CALL echo("PRN meds")
 ENDIF
 SET prn_med_cnt = size(prn_orders->qual,5)
 IF (prn_med_cnt > 0)
  SELECT DISTINCT INTO "nl:"
   check = decode(cmr.seq,"cmr",ccr.seq,"ccr",csr.seq,
    "csr")
   FROM orders o,
    order_action oa,
    clinical_event ce,
    ce_med_result cmr,
    ce_coded_result ccr,
    ce_string_result csr,
    (dummyt d1  WITH seq = value(size(prn_orders->qual,5))),
    dummyt d2,
    dummyt d3,
    dummyt d4
   PLAN (d1)
    JOIN (o
    WHERE (o.order_id=prn_orders->qual[d1.seq].order_id))
    JOIN (oa
    WHERE oa.order_id=o.order_id
     AND oa.core_ind=1)
    JOIN (ce
    WHERE ce.order_id=oa.order_id
     AND (ce.person_id=pt_transfer->person_id)
     AND ce.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100")
     AND ce.event_class_cd=med_type_cd
     AND ce.publish_flag=1
     AND ce.result_status_cd != inerror_cd)
    JOIN (d2)
    JOIN (((cmr
    WHERE cmr.event_id=ce.event_id
     AND cmr.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100"))
    ) ORJOIN ((d3)
    JOIN (((ccr
    WHERE ccr.event_id=ce.event_id
     AND ce.result_status_cd=not_done_cd
     AND ccr.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100"))
    ) ORJOIN ((d4)
    JOIN (csr
    WHERE csr.event_id=ce.event_id
     AND ce.result_status_cd=not_done_cd
     AND csr.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100"))
    )) ))
   ORDER BY o.order_id DESC, oa.action_sequence DESC, ce.event_end_dt_tm DESC,
    ce.event_id
   HEAD REPORT
    ordercnt = 0, actioncnt = 0, admincnt = 0
   HEAD o.order_id
    ordercnt = (ordercnt+ 1)
    IF (mod(ordercnt,10)=1)
     stat = alterlist(prn_orders_disp->prn_orders,(ordercnt+ 9))
    ENDIF
    prn_orders_disp->prn_orders[ordercnt].order_id = o.order_id, prn_orders_disp->prn_orders[ordercnt
    ].orig_order_dt_tm = o.orig_order_dt_tm, prn_orders_disp->prn_orders[ordercnt].mnemonic = o
    .order_mnemonic,
    prn_orders_disp->prn_orders[ordercnt].ordered_as_mnemonic = o.ordered_as_mnemonic,
    prn_orders_disp->prn_orders[ordercnt].hna_mnemonic = o.hna_order_mnemonic, prn_orders_disp->
    prn_orders[ordercnt].stop_dt = prn_orders->qual[d1.seq].stop_dt,
    prn_orders_disp->prn_orders[ordercnt].action_type = prn_orders->qual[d1.seq].action_type
    IF (o.order_status_cd=voided_cd)
     prn_orders_disp->prn_orders[ordercnt].voided_ind = 1
    ENDIF
   HEAD oa.action_sequence
    actioncnt = (actioncnt+ 1)
    IF (mod(actioncnt,5)=1)
     stat = alterlist(prn_orders_disp->prn_orders[ordercnt].core_actions,(actioncnt+ 4))
    ENDIF
    prn_orders_disp->prn_orders[ordercnt].core_actions[actioncnt].order_id = oa.order_id,
    prn_orders_disp->prn_orders[ordercnt].core_actions[actioncnt].action_seq = oa.action_sequence,
    prn_orders_disp->prn_orders[ordercnt].core_actions[actioncnt].action_dt_tm = oa.action_dt_tm,
    prn_orders_disp->prn_orders[ordercnt].core_actions[actioncnt].action = uar_get_code_display(oa
     .action_type_cd), prn_orders_disp->prn_orders[ordercnt].core_actions[actioncnt].
    clinical_display_line = oa.clinical_display_line
   DETAIL
    IF (actioncnt=1)
     admincnt = (admincnt+ 1)
     IF (mod(admincnt,10)=1)
      stat = alterlist(prn_orders_disp->prn_orders[ordercnt].admins,(admincnt+ 9))
     ENDIF
     prn_orders_disp->prn_orders[ordercnt].admins[admincnt].order_id = o.order_id, prn_orders_disp->
     prn_orders[ordercnt].admins[admincnt].parent_event_id = ce.parent_event_id, prn_orders_disp->
     prn_orders[ordercnt].admins[admincnt].event_id = ce.event_id,
     prn_orders_disp->prn_orders[ordercnt].admins[admincnt].verified_dt_tm = ce.verified_dt_tm,
     prn_orders_disp->prn_orders[ordercnt].admins[admincnt].verified_prsnl_id = ce.verified_prsnl_id,
     prn_orders_disp->prn_orders[ordercnt].admins[admincnt].valid_from_dt_tm = ce.valid_from_dt_tm,
     prn_orders_disp->prn_orders[ordercnt].admins[admincnt].event_title_text = ce.event_title_text,
     prn_orders_disp->prn_orders[ordercnt].admins[admincnt].event_end_dt_tm = ce.event_end_dt_tm,
     prn_orders_disp->prn_orders[ordercnt].admins[admincnt].result_status_meaning =
     uar_get_code_meaning(ce.result_status_cd),
     prn_orders_disp->prn_orders[ordercnt].admins[admincnt].result_status_display =
     uar_get_code_display(ce.result_status_cd), prn_orders_disp->prn_orders[ordercnt].admins[admincnt
     ].admin_by_id = ce.performed_prsnl_id
     IF (check="cmr")
      prn_orders_disp->prn_orders[ordercnt].admins[admincnt].admin_start_dt_tm = cmr
      .admin_start_dt_tm, prn_orders_disp->prn_orders[ordercnt].admins[admincnt].dosage_unit =
      uar_get_code_display(cmr.dosage_unit_cd), prn_orders_disp->prn_orders[ordercnt].admins[admincnt
      ].dosage_value = cmr.admin_dosage,
      prn_orders_disp->prn_orders[ordercnt].admins[admincnt].site = uar_get_code_display(cmr
       .admin_site_cd), prn_orders_disp->prn_orders[ordercnt].admins[admincnt].route =
      uar_get_code_display(cmr.admin_route_cd)
     ELSEIF (check="ccr")
      prn_orders_disp->prn_orders[ordercnt].admins[admincnt].not_given_reason = uar_get_code_display(
       ccr.result_cd), prn_orders_disp->prn_orders[ordercnt].admins[admincnt].from_ccr = 1
     ELSE
      IF ((prn_orders_disp->prn_orders[ordercnt].admins[admincnt].from_ccr != 1))
       prn_orders_disp->prn_orders[ordercnt].admins[admincnt].not_given_reason = csr
       .string_result_text
      ENDIF
     ENDIF
    ENDIF
   FOOT  oa.action_sequence
    do_nothing = 0
   FOOT  o.order_id
    stat = alterlist(prn_orders_disp->prn_orders[ordercnt].core_actions,actioncnt), stat = alterlist(
     prn_orders_disp->prn_orders[ordercnt].admins,admincnt), max_num_prn_actions = maxval(
     max_num_prn_actions,actioncnt),
    max_num_prn_admins = maxval(max_num_prn_admins,admincnt), actioncnt = 0, admincnt = 0
   FOOT REPORT
    stat = alterlist(prn_orders_disp->prn_orders,ordercnt)
   WITH nocounter
  ;end select
 ENDIF
 IF (test_ind=1)
  CALL echo("Continuous meds")
 ENDIF
 SET cont_med_cnt = size(continuous_orders->qual,5)
 IF (cont_med_cnt > 0)
  SELECT DISTINCT INTO "nl:"
   check = decode(cmr.seq,"cmr",ccr.seq,"ccr",csr.seq,
    "csr")
   FROM orders o,
    order_action oa,
    clinical_event ce,
    ce_med_result cmr,
    ce_coded_result ccr,
    ce_string_result csr,
    (dummyt d1  WITH seq = value(size(continuous_orders->qual,5))),
    dummyt d2,
    dummyt d3,
    dummyt d4
   PLAN (d1)
    JOIN (o
    WHERE (o.order_id=continuous_orders->qual[d1.seq].order_id))
    JOIN (oa
    WHERE oa.order_id=o.order_id
     AND oa.core_ind=1)
    JOIN (ce
    WHERE ce.order_id=oa.order_id
     AND (ce.person_id=pt_transfer->person_id)
     AND ce.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100")
     AND ce.event_class_cd=med_type_cd
     AND ce.publish_flag=1
     AND ce.result_status_cd != inerror_cd)
    JOIN (d2)
    JOIN (((cmr
    WHERE cmr.event_id=ce.event_id
     AND cmr.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100")
     AND cmr.iv_event_cd IN (begin_bag_cd, site_chg_cd, rate_chg_cd))
    ) ORJOIN ((d3)
    JOIN (((ccr
    WHERE ccr.event_id=ce.event_id
     AND ce.result_status_cd=not_done_cd
     AND ccr.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100"))
    ) ORJOIN ((d4)
    JOIN (csr
    WHERE csr.event_id=ce.event_id
     AND ce.result_status_cd=not_done_cd
     AND csr.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100"))
    )) ))
   ORDER BY o.order_id DESC, oa.action_sequence DESC, ce.event_end_dt_tm DESC,
    ce.event_id
   HEAD REPORT
    ordercnt = 0, actioncnt = 0, admincnt = 0
   HEAD o.order_id
    ordercnt = (ordercnt+ 1)
    IF (mod(ordercnt,10)=1)
     stat = alterlist(continuous_orders_disp->continuous_orders,(ordercnt+ 9))
    ENDIF
    continuous_orders_disp->continuous_orders[ordercnt].order_id = o.order_id, continuous_orders_disp
    ->continuous_orders[ordercnt].orig_order_dt_tm = o.orig_order_dt_tm, continuous_orders_disp->
    continuous_orders[ordercnt].mnemonic = o.order_mnemonic,
    continuous_orders_disp->continuous_orders[ordercnt].ordered_as_mnemonic = o.ordered_as_mnemonic,
    continuous_orders_disp->continuous_orders[ordercnt].hna_mnemonic = o.hna_order_mnemonic,
    continuous_orders_disp->continuous_orders[ordercnt].stop_dt = continuous_orders->qual[d1.seq].
    stop_dt,
    continuous_orders_disp->continuous_orders[ordercnt].action_type = continuous_orders->qual[d1.seq]
    .action_type
    IF (o.order_status_cd=voided_cd)
     continuous_orders_disp->continuous_orders[ordercnt].voided_ind = 1
    ENDIF
   HEAD oa.action_sequence
    actioncnt = (actioncnt+ 1)
    IF (mod(actioncnt,5)=1)
     stat = alterlist(continuous_orders_disp->continuous_orders[ordercnt].core_actions,(actioncnt+ 4)
      )
    ENDIF
    continuous_orders_disp->continuous_orders[ordercnt].core_actions[actioncnt].action_seq = oa
    .action_sequence, continuous_orders_disp->continuous_orders[ordercnt].core_actions[actioncnt].
    action_dt_tm = oa.action_dt_tm, continuous_orders_disp->continuous_orders[ordercnt].core_actions[
    actioncnt].action = uar_get_code_display(oa.action_type_cd),
    continuous_orders_disp->continuous_orders[ordercnt].core_actions[actioncnt].clinical_display_line
     = oa.clinical_display_line
   DETAIL
    IF (actioncnt=1)
     admincnt = (admincnt+ 1)
     IF (mod(admincnt,10)=1)
      stat = alterlist(continuous_orders_disp->continuous_orders[ordercnt].admins,(admincnt+ 9))
     ENDIF
     continuous_orders_disp->continuous_orders[ordercnt].admins[admincnt].parent_event_id = ce
     .parent_event_id, continuous_orders_disp->continuous_orders[ordercnt].admins[admincnt].event_id
      = ce.event_id, continuous_orders_disp->continuous_orders[ordercnt].admins[admincnt].
     verified_dt_tm = ce.verified_dt_tm,
     continuous_orders_disp->continuous_orders[ordercnt].admins[admincnt].verified_prsnl_id = ce
     .verified_prsnl_id, continuous_orders_disp->continuous_orders[ordercnt].admins[admincnt].
     valid_from_dt_tm = ce.valid_from_dt_tm, continuous_orders_disp->continuous_orders[ordercnt].
     admins[admincnt].event_title_text = ce.event_title_text,
     continuous_orders_disp->continuous_orders[ordercnt].admins[admincnt].event_end_dt_tm = ce
     .event_end_dt_tm, continuous_orders_disp->continuous_orders[ordercnt].admins[admincnt].
     result_status_meaning = uar_get_code_meaning(ce.result_status_cd), continuous_orders_disp->
     continuous_orders[ordercnt].admins[admincnt].result_status_display = uar_get_code_display(ce
      .result_status_cd),
     continuous_orders_disp->continuous_orders[ordercnt].admins[admincnt].admin_by_id = ce
     .performed_prsnl_id
     IF (check="cmr")
      continuous_orders_disp->continuous_orders[ordercnt].admins[admincnt].iv_event_meaning =
      uar_get_code_meaning(cmr.iv_event_cd), continuous_orders_disp->continuous_orders[ordercnt].
      admins[admincnt].iv_event_display = uar_get_code_display(cmr.iv_event_cd),
      continuous_orders_disp->continuous_orders[ordercnt].admins[admincnt].admin_start_dt_tm = cmr
      .admin_start_dt_tm,
      continuous_orders_disp->continuous_orders[ordercnt].admins[admincnt].init_dosage = cmr
      .initial_dosage, continuous_orders_disp->continuous_orders[ordercnt].admins[admincnt].
      dosage_unit = uar_get_code_display(cmr.dosage_unit_cd), continuous_orders_disp->
      continuous_orders[ordercnt].admins[admincnt].initial_volume = cmr.initial_volume,
      continuous_orders_disp->continuous_orders[ordercnt].admins[admincnt].infusion_rate = cmr
      .infusion_rate, continuous_orders_disp->continuous_orders[ordercnt].admins[admincnt].
      infusion_unit = uar_get_code_display(cmr.infusion_unit_cd), continuous_orders_disp->
      continuous_orders[ordercnt].admins[admincnt].site = uar_get_code_display(cmr.admin_site_cd),
      continuous_orders_disp->continuous_orders[ordercnt].admins[admincnt].route =
      uar_get_code_display(cmr.admin_route_cd)
     ELSEIF (check="ccr")
      continuous_orders_disp->continuous_orders[ordercnt].admins[admincnt].not_given_reason =
      uar_get_code_display(ccr.result_cd), continuous_orders_disp->continuous_orders[ordercnt].
      admins[admincnt].from_ccr = 1
     ELSE
      IF ((continuous_orders_disp->continuous_orders[ordercnt].admins[admincnt].from_ccr != 1))
       continuous_orders_disp->continuous_orders[ordercnt].admins[admincnt].not_given_reason = csr
       .string_result_text
      ENDIF
     ENDIF
    ENDIF
   FOOT  oa.action_sequence
    do_nothing = 0
   FOOT  o.order_id
    stat = alterlist(continuous_orders_disp->continuous_orders[ordercnt].core_actions,actioncnt),
    stat = alterlist(continuous_orders_disp->continuous_orders[ordercnt].admins,admincnt),
    max_num_cont_admins = maxval(max_num_cont_admins,admincnt),
    max_num_cont_actions = maxval(max_num_cont_actions,actioncnt), actioncnt = 0, admincnt = 0
   FOOT REPORT
    stat = alterlist(continuous_orders_disp->continuous_orders,ordercnt)
   WITH nocounter
  ;end select
 ENDIF
 IF (test_ind=1)
  CALL echo("Get scheduled med comm")
 ENDIF
 FOR (xx = 1 TO size(scheduled_orders->qual,5))
  SELECT INTO "nl:"
   FROM orders o
   PLAN (o
    WHERE (o.template_order_id=scheduled_orders->qual[xx].order_id)
     AND o.template_order_id > 0
     AND o.current_start_dt_tm > cnvtdatetime(curdate,curtime3))
   ORDER BY o.current_start_dt_tm, o.order_id
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt = (cnt+ 1), stat = alterlist(scheduled_orders->qual[xx].child_ord,cnt), scheduled_orders->
    qual[xx].child_ord[cnt].order_id = o.order_id,
    scheduled_orders->qual[xx].child_ord[cnt].start_dt = o.current_start_dt_tm, scheduled_orders->
    qual[xx].child_ord[cnt].order_mnemonic = trim(o.order_mnemonic)
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   len = textlen(lt.long_text)
   FROM order_comment oc,
    long_text lt
   PLAN (oc
    WHERE (oc.order_id=scheduled_orders->qual[xx].order_id))
    JOIN (lt
    WHERE lt.long_text_id=oc.long_text_id
     AND ((lt.parent_entity_id+ 0)=oc.order_id)
     AND ((lt.active_ind+ 0)=1)
     AND trim(lt.parent_entity_name)="ORDER_COMMENT")
   HEAD REPORT
    b_linefeed = char(10), b_cr = char(13), b_cc = 0,
    b_s = 1, b_len = 0, b_e = 0,
    b_tmp_comment = fillstring(90,""), tmp_var = 0
   DETAIL
    b_cc = 1, scheduled_orders->qual[xx].comm_cnt = 0, b_s = 1
    WHILE (b_cc)
      b_tmp_comment = substring(b_s,90,lt.long_text), b_e = findstring(b_linefeed,b_tmp_comment,1)
      IF (b_e)
       scheduled_orders->qual[xx].comm_cnt = (scheduled_orders->qual[xx].comm_cnt+ 1), tmp_var =
       scheduled_orders->qual[xx].comm_cnt, stat = alterlist(scheduled_orders->qual[xx].comment,
        tmp_var),
       scheduled_orders->qual[xx].comment[tmp_var].comment = substring(1,b_e,b_tmp_comment), b_s = (
       b_s+ b_e)
      ELSE
       IF (b_tmp_comment > " ")
        scheduled_orders->qual[xx].comm_cnt = (scheduled_orders->qual[xx].comm_cnt+ 1), tmp_var =
        scheduled_orders->qual[xx].comm_cnt, stat = alterlist(scheduled_orders->qual[xx].comment,
         tmp_var),
        scheduled_orders->qual[xx].comment[tmp_var].comment = b_tmp_comment, b_s = (b_s+ 90)
       ELSE
        b_cc = 0
       ENDIF
      ENDIF
    ENDWHILE
   WITH nocounter
  ;end select
 ENDFOR
 IF (test_ind=1)
  CALL echo("Get prn med comments")
 ENDIF
 FOR (xx = 1 TO size(prn_orders->qual,5))
   SELECT INTO "nl:"
    FROM orders o,
     order_comment oc,
     long_text lt
    PLAN (o
     WHERE (o.order_id=prn_orders->qual[xx].order_id))
     JOIN (oc
     WHERE oc.order_id=outerjoin(o.order_id))
     JOIN (lt
     WHERE lt.long_text_id=outerjoin(oc.long_text_id)
      AND ((lt.parent_entity_id+ 0)=outerjoin(oc.order_id))
      AND ((lt.active_ind+ 0)=outerjoin(1))
      AND trim(lt.parent_entity_name)=outerjoin("ORDER_COMMENT"))
    ORDER BY o.current_start_dt_tm
    HEAD REPORT
     cnt = 0
    DETAIL
     cnt = (cnt+ 1), stat = alterlist(prn_orders->qual[xx].child_ord,cnt), prn_orders->qual[xx].
     child_ord[cnt].order_id = o.order_id,
     prn_orders->qual[xx].child_ord[cnt].start_dt = o.current_start_dt_tm, prn_orders->qual[xx].
     child_ord[cnt].order_mnemonic = trim(o.order_mnemonic)
     IF (o.order_comment_ind=1)
      prn_orders->qual[xx].comment = lt.long_text
     ENDIF
    WITH nocounter
   ;end select
 ENDFOR
 FOR (p1 = 1 TO size(prn_orders->qual,5))
   FOR (p2 = 1 TO size(prn_orders_disp->prn_orders,5))
     IF ((prn_orders->qual[p1].order_id=prn_orders_disp->prn_orders[p2].order_id))
      SET prn_orders->qual[p1].print_ind = 1
      SET prn_orders_disp->prn_orders[p2].comment = prn_orders->qual[p1].comment
     ENDIF
   ENDFOR
 ENDFOR
 IF (test_ind=1)
  CALL echo("Get continuous med comments")
 ENDIF
 FOR (xx = 1 TO size(continuous_orders->qual,5))
   SELECT INTO "nl:"
    FROM orders o,
     order_comment oc,
     long_text lt
    PLAN (o
     WHERE (o.order_id=continuous_orders->qual[xx].order_id))
     JOIN (oc
     WHERE oc.order_id=outerjoin(o.order_id))
     JOIN (lt
     WHERE lt.long_text_id=outerjoin(oc.long_text_id)
      AND ((lt.parent_entity_id+ 0)=outerjoin(oc.order_id))
      AND ((lt.active_ind+ 0)=outerjoin(1))
      AND trim(lt.parent_entity_name)=outerjoin("ORDER_COMMENT"))
    ORDER BY o.current_start_dt_tm
    HEAD REPORT
     cnt = 0
    DETAIL
     cnt = (cnt+ 1), stat = alterlist(continuous_orders->qual[xx].child_ord,cnt), continuous_orders->
     qual[xx].child_ord[cnt].order_id = o.order_id,
     continuous_orders->qual[xx].child_ord[cnt].start_dt = o.current_start_dt_tm, continuous_orders->
     qual[xx].child_ord[cnt].order_mnemonic = trim(o.order_mnemonic)
     IF (o.order_comment_ind=1)
      continuous_orders->qual[xx].comment = lt.long_text
     ENDIF
    WITH nocounter
   ;end select
 ENDFOR
 FOR (c1 = 1 TO size(continuous_orders->qual,5))
   FOR (c2 = 1 TO size(continuous_orders_disp->continuous_orders,5))
     IF ((continuous_orders->qual[c1].order_id=continuous_orders_disp->continuous_orders[c2].order_id
     ))
      SET continuous_orders->qual[c1].print_ind = 1
      SET continuous_orders_disp->continuous_orders[c2].comment = continuous_orders->qual[c1].comment
     ENDIF
   ENDFOR
 ENDFOR
 IF (test_ind=1)
  CALL echo("Get H&P")
 ENDIF
 SELECT INTO "nl:"
  FROM clinical_event ce,
   v500_event_set_explode vese,
   v500_event_set_code vesc,
   clinical_event ce1,
   ce_blob ceb,
   ce_event_prsnl cep,
   prsnl pr,
   prsnl pr1
  PLAN (ce
   WHERE (ce.encntr_id=pt_transfer->encntr_id)
    AND ce.publish_flag=1
    AND ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime)
    AND  NOT (ce.result_status_cd IN (inerror_cd)))
   JOIN (vese
   WHERE vese.event_cd=ce.event_cd)
   JOIN (vesc
   WHERE vesc.event_set_cd=vese.event_set_cd
    AND vesc.event_set_name IN ("Transfer Summary - Dictated", "MD Discharge Summary",
   "Physician Discharge Summary", "Discharge Summary - Dictated", "Discharge Summary - Converted",
   "Nursing Discharge Status Report", "Cardiovascular", "Cardiovascular (new)", "CARDIOVASCULAR TEST",
   "History and Physical - Dictated",
   "RADIOLOGY", "Consultation Note - Dictated"))
   JOIN (ce1
   WHERE ce1.event_id=outerjoin(ce.parent_event_id))
   JOIN (ceb
   WHERE ceb.event_id=ce.event_id
    AND ceb.valid_until_dt_tm >= cnvtdatetime(curdate,curtime))
   JOIN (cep
   WHERE cep.event_id=outerjoin(ce1.event_id)
    AND cep.valid_until_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime))
    AND cep.action_type_cd=outerjoin(sign_cd))
   JOIN (pr
   WHERE pr.person_id=outerjoin(cep.action_prsnl_id))
   JOIN (pr1
   WHERE pr1.person_id=outerjoin(cep.request_prsnl_id))
  ORDER BY ce.event_end_dt_tm DESC, ce.parent_event_id, ce.event_id,
   cep.ce_event_prsnl_id
  HEAD REPORT
   cnt_blob = 0, stat = alterlist(pt_transfer->blob_qual,5)
  HEAD ce.event_end_dt_tm
   row + 0
  HEAD ce.parent_event_id
   cnt_blob = (cnt_blob+ 1)
   IF (mod(cnt_blob,5)=1)
    stat = alterlist(pt_transfer->blob_qual,(cnt_blob+ 5))
   ENDIF
   pt_transfer->blob_qual[cnt_blob].blob_event_cd = trim(uar_get_code_display(ce.event_cd)),
   pt_transfer->blob_qual[cnt_blob].blob_date = format(ce.event_end_dt_tm,"mm/dd/yy hh:mm;;d"),
   pt_transfer->blob_qual[cnt_blob].blob_set_name = vesc.event_set_name,
   pt_transfer->blob_qual[cnt_blob].event_title_text = trim(ce.event_title_text), stat = alterlist(
    pt_transfer->blob_qual[cnt_blob].action_qual,5), cnt_action = 0,
   stat = alterlist(pt_transfer->blob_qual[cnt_blob].blobs_qual,5), cnt_blobs = 0
  HEAD ce.event_id
   cnt_blobs = (cnt_blobs+ 1)
   IF (mod(cnt_blobs,5)=1)
    stat = alterlist(pt_transfer->blob_qual[cnt_blob].blobs_qual,(cnt_blobs+ 5))
   ENDIF
   pt_transfer->blob_qual[cnt_blob].blobs_qual[cnt_blobs].event_id = ceb.event_id, pt_transfer->
   blob_qual[cnt_blob].blobs_qual[cnt_blobs].event_title_text = trim(ce.event_title_text),
   pt_transfer->blob_qual[cnt_blob].blobs_qual[cnt_blobs].blob_contents = ceb.blob_contents,
   pt_transfer->blob_qual[cnt_blob].blobs_qual[cnt_blobs].comp_cd = ceb.compression_cd, pt_transfer->
   blob_qual[cnt_blob].blobs_qual[cnt_blobs].blobseq = ceb.blob_seq_num
  HEAD cep.ce_event_prsnl_id
   IF (ce.event_title_text != "Addendum by*"
    AND cep.action_type_cd > 0)
    cnt_action = (cnt_action+ 1)
    IF (mod(cnt_action,5)=1)
     stat = alterlist(pt_transfer->blob_qual[cnt_blob].action_qual,(cnt_action+ 5))
    ENDIF
    pt_transfer->blob_qual[cnt_blob].action_qual[cnt_action].type = trim(uar_get_code_display(cep
      .action_type_cd)), pt_transfer->blob_qual[cnt_blob].action_qual[cnt_action].status = trim(
     uar_get_code_display(cep.action_status_cd)), pt_transfer->blob_qual[cnt_blob].action_qual[
    cnt_action].date = format(cep.action_dt_tm,"mm/dd/yy hh:mm;;d")
    IF (pr.person_id > 0)
     pt_transfer->blob_qual[cnt_blob].action_qual[cnt_action].prsnl_name = trim(pr
      .name_full_formatted)
    ELSEIF (pr1.person_id > 0)
     pt_transfer->blob_qual[cnt_blob].action_qual[cnt_action].prsnl_name = trim(pr1
      .name_full_formatted)
    ENDIF
   ENDIF
  FOOT  ce.event_id
   row + 0
  FOOT  ce.parent_event_id
   stat = alterlist(pt_transfer->blob_qual[cnt_blob].action_qual,cnt_action), pt_transfer->blob_qual[
   cnt_blob].action_cnt = cnt_action, stat = alterlist(pt_transfer->blob_qual[cnt_blob].blobs_qual,
    cnt_blobs),
   pt_transfer->blob_qual[cnt_blob].blobs_cnt = cnt_blobs
  FOOT REPORT
   stat = alterlist(pt_transfer->blob_qual,cnt_blob,cnt_blob), pt_transfer->blob_cnt = cnt_blob
  WITH nocounter
 ;end select
 FREE RECORD blob_disp
 RECORD blob_disp(
   1 blob_cnt = i4
   1 qual[*]
     2 event_id = f8
     2 line_cnt = i4
     2 line[*]
       3 disp = vc
 )
 FREE RECORD pt
 RECORD pt(
   1 line_cnt = i2
   1 lns[*]
     2 line = vc
 )
 FOR (x = 1 TO pt_transfer->blob_cnt)
   FOR (y = 1 TO pt_transfer->blob_qual[x].blobs_cnt)
     SET blob_disp->blob_cnt = (blob_disp->blob_cnt+ 1)
     SET stat = alterlist(blob_disp->qual,blob_disp->blob_cnt)
     SET blob_disp->qual[blob_disp->blob_cnt].event_id = pt_transfer->blob_qual[x].blobs_qual[y].
     event_id
     SET pt->line_cnt = 0
     SET max_length = 90
     DECLARE blob_in = vc
     DECLARE blob_out = vc
     DECLARE blob_out2 = vc
     SET blob_out = fillstring(32000,"")
     SET blob_out2 = fillstring(32000,"")
     SET blob_return_len = 0
     SET bsize = 0
     SET bflag = 0
     SET blob_in = pt_transfer->blob_qual[x].blobs_qual[y].blob_contents
     SET stat = uar_ocf_uncompress(blob_in,size(blob_in),blob_out,32000,blob_return_len)
     SET stat = uar_rtf2(blob_out,size(blob_out),blob_out2,size(blob_out2),bsize,
      bflag)
     EXECUTE dcp_parse_text value(blob_out2), value(max_length)
     SET blob_disp->qual[blob_disp->blob_cnt].line_cnt = pt->line_cnt
     SET stat = alterlist(blob_disp->qual[blob_disp->blob_cnt].line,pt->line_cnt)
     FOR (c = 1 TO pt->line_cnt)
       SET blob_disp->qual[blob_disp->blob_cnt].line[c].disp = trim(pt->lns[c].line)
     ENDFOR
   ENDFOR
 ENDFOR
 IF (test_ind=1)
  CALL echo("Get Last 7 days of orders..")
 ENDIF
 SELECT INTO "nl:"
  catalog_type_sort =
  IF (o.catalog_cd IN (full_code_cd, limited_code_cd, no_code_cd, fullop_code_cd, limitedop_code_cd,
  noop_code_cd, op_code_cd)) "1"
  ELSEIF (o.catalog_cd=isolation_cd) "2"
  ELSEIF (o.activity_type_cd=diet_consult_cd) "3"
  ELSE uar_get_code_display(o.catalog_type_cd)
  ENDIF
  FROM orders o,
   prsnl p
  PLAN (o
   WHERE (o.encntr_id=pt_transfer->encntr_id)
    AND o.template_order_flag IN (0, 1)
    AND o.orig_ord_as_flag=0
    AND ((((((o.catalog_type_cd+ 0)=diet_cd)
    AND o.activity_type_cd != diet_consult_cd) OR (((((o.catalog_cd+ 0) IN (full_code_cd,
   limited_code_cd, no_code_cd, fullop_code_cd, limitedop_code_cd,
   noop_code_cd, op_code_cd))) OR (((o.catalog_cd+ 0)=isolation_cd))) ))
    AND ((((o.order_status_cd+ 0)=os_ord_cd)) OR ((pt_transfer->disch_date > 0)
    AND  EXISTS (
   (SELECT
    oa.order_action_id
    FROM order_action oa
    WHERE oa.order_id=o.order_id
     AND oa.action_dt_tm < cnvtdatetime(pt_transfer->disch_date)
     AND oa.order_status_cd=os_ord_cd
     AND  NOT ( EXISTS (
    (SELECT
     oa1.order_action_id
     FROM order_action oa1
     WHERE oa1.order_id=oa.order_id
      AND oa1.action_dt_tm > oa.action_dt_tm
      AND oa1.action_dt_tm < cnvtdatetime(pt_transfer->disch_date)))))))) ) OR (((((o.catalog_type_cd
   + 0)=consult_cd)
    AND ((o.order_status_cd+ 0) != os_canc_cd)) OR (((((o.activity_type_cd+ 0)=diet_consult_cd)
    AND ((o.order_status_cd+ 0) != os_canc_cd)) OR ((((pt_transfer->disch_date > 0)
    AND o.current_start_dt_tm >= cnvtdatetime(datetimeadd(pt_transfer->disch_date,- (7.0)))) OR (o
   .current_start_dt_tm >= cnvtdatetime((curdate - 7),curtime)))
    AND  NOT (o.catalog_type_cd IN (pharmacy_cd, consult_cd, diet_cd))
    AND  NOT (((o.catalog_cd+ 0) IN (full_code_cd, limited_code_cd, no_code_cd, fullop_code_cd,
   limitedop_code_cd,
   noop_code_cd, op_code_cd, isolation_cd)))
    AND o.order_status_cd != os_canc_cd)) )) )) )
   JOIN (p
   WHERE p.person_id=outerjoin(o.status_prsnl_id))
  ORDER BY catalog_type_sort, o.current_start_dt_tm DESC, o.order_id
  HEAD REPORT
   cnt_cat = 0, stat = alterlist(pt_transfer->catalog_qual,10), cnt_cons = 0,
   stat = alterlist(pt_transfer->consult_qual,10), cnt_diet = 0, stat = alterlist(pt_transfer->
    diet_qual,5),
   cnt_iso = 0, stat = alterlist(pt_transfer->isolation_qual,5)
  HEAD catalog_type_sort
   IF (o.catalog_cd IN (full_code_cd, limited_code_cd, no_code_cd, fullop_code_cd, limitedop_code_cd,
   noop_code_cd, op_code_cd))
    stat = alterlist(pt_transfer->code_status_qual,1), pt_transfer->code_status_qual[1].order_name =
    IF (trim(o.ordered_as_mnemonic,3) > " ") trim(o.ordered_as_mnemonic,3)
    ELSE trim(o.hna_order_mnemonic,3)
    ENDIF
    , pt_transfer->code_status_qual[1].order_id = o.order_id,
    pt_transfer->code_status_qual[1].order_detail = trim(o.clinical_display_line,3), pt_transfer->
    code_status_qual[1].order_status = trim(uar_get_code_display(o.order_status_cd)), pt_transfer->
    code_status_qual[1].status_date = format(o.status_dt_tm,"mm/dd/yy hh:mm;;d")
   ENDIF
   IF ( NOT (o.catalog_cd IN (full_code_cd, limited_code_cd, no_code_cd, fullop_code_cd,
   limitedop_code_cd,
   noop_code_cd, op_code_cd, isolation_cd))
    AND  NOT (o.catalog_type_cd IN (pharmacy_cd, consult_cd, diet_cd)))
    cnt_cat = (cnt_cat+ 1)
    IF (mod(cnt_cat,10)=1)
     stat = alterlist(pt_transfer->catalog_qual,(cnt_cat+ 10))
    ENDIF
    pt_transfer->catalog_qual[cnt_cat].catalog_type = cnvtupper(uar_get_code_display(o
      .catalog_type_cd)), cnt_ord = 0, stat = alterlist(pt_transfer->catalog_qual[cnt_cat].
     orders_qual,10)
   ENDIF
  HEAD o.current_start_dt_tm
   row + 0
  HEAD o.order_id
   IF (o.catalog_type_cd=diet_cd
    AND o.activity_type_cd != diet_consult_cd)
    cnt_diet = (cnt_diet+ 1)
    IF (mod(cnt_diet,5)=1)
     stat = alterlist(pt_transfer->diet_qual,(cnt_diet+ 5))
    ENDIF
    pt_transfer->diet_qual[cnt_diet].order_id = o.order_id, pt_transfer->diet_qual[cnt_diet].
    order_name =
    IF (trim(o.ordered_as_mnemonic,3) > " ") trim(o.ordered_as_mnemonic,3)
    ELSE trim(o.hna_order_mnemonic,3)
    ENDIF
    , pt_transfer->diet_qual[cnt_diet].order_detail = trim(o.clinical_display_line,3),
    pt_transfer->diet_qual[cnt_diet].order_status = trim(uar_get_code_display(o.order_status_cd)),
    pt_transfer->diet_qual[cnt_diet].status_date = format(o.status_dt_tm,"mm/dd/yy hh:mm;;d")
   ENDIF
   IF ( NOT (o.catalog_cd IN (full_code_cd, limited_code_cd, no_code_cd, fullop_code_cd,
   limitedop_code_cd,
   noop_code_cd, op_code_cd, isolation_cd))
    AND  NOT (o.catalog_type_cd IN (pharmacy_cd, consult_cd, diet_cd)))
    cnt_ord = (cnt_ord+ 1)
    IF (mod(cnt_ord,10)=1)
     stat = alterlist(pt_transfer->catalog_qual[cnt_cat].orders_qual,(cnt_ord+ 10))
    ENDIF
    pt_transfer->catalog_qual[cnt_cat].orders_qual[cnt_ord].order_id = o.order_id, pt_transfer->
    catalog_qual[cnt_cat].orders_qual[cnt_ord].ord_name =
    IF (trim(o.ordered_as_mnemonic,3) > " ") trim(o.ordered_as_mnemonic,3)
    ELSE trim(o.hna_order_mnemonic,3)
    ENDIF
    , pt_transfer->catalog_qual[cnt_cat].orders_qual[cnt_ord].status = trim(uar_get_code_display(o
      .order_status_cd)),
    pt_transfer->catalog_qual[cnt_cat].orders_qual[cnt_ord].date = format(o.current_start_dt_tm,
     "mm/dd/yy hh:mm;;d"), pt_transfer->catalog_qual[cnt_cat].orders_qual[cnt_ord].od_display_line =
    trim(o.clinical_display_line)
   ENDIF
   IF (((o.catalog_type_cd=consult_cd) OR (o.activity_type_cd=diet_consult_cd)) )
    cnt_cons = (cnt_cons+ 1)
    IF (mod(cnt_cons,10)=1)
     stat = alterlist(pt_transfer->consult_qual,(cnt_cons+ 10))
    ENDIF
    pt_transfer->consult_qual[cnt_cons].order_id = o.order_id, pt_transfer->consult_qual[cnt_cons].
    ord_name =
    IF (trim(o.ordered_as_mnemonic,3) > " ") trim(o.ordered_as_mnemonic,3)
    ELSE trim(o.hna_order_mnemonic,3)
    ENDIF
    , pt_transfer->consult_qual[cnt_cons].status = trim(uar_get_code_display(o.order_status_cd),3),
    pt_transfer->consult_qual[cnt_cons].status_date = format(o.status_dt_tm,"mm/dd/yy hh:mm;;d"),
    pt_transfer->consult_qual[cnt_cons].order_detail = trim(o.order_detail_display_line,3)
    IF ((pt_transfer->consult_qual[cnt_cons].status="Completed"))
     pt_transfer->consult_qual[cnt_cons].completed_by = trim(p.name_full_formatted,3)
    ENDIF
   ENDIF
   IF (o.catalog_cd=isolation_cd)
    cnt_iso = (cnt_iso+ 1)
    IF (mod(cnt_iso,5)=1)
     stat = alterlist(pt_transfer->isolation_qual,(cnt_iso+ 5))
    ENDIF
    pt_transfer->isolation_qual[cnt_iso].order_id = o.order_id, pt_transfer->isolation_qual[cnt_iso].
    iso_name =
    IF (trim(o.ordered_as_mnemonic,3) > " ") trim(o.ordered_as_mnemonic,3)
    ELSE trim(o.hna_order_mnemonic,3)
    ENDIF
    , pt_transfer->isolation_qual[cnt_iso].iso_detail = trim(o.clinical_display_line,3),
    pt_transfer->isolation_qual[cnt_iso].iso_status = trim(uar_get_code_display(o.order_status_cd)),
    pt_transfer->isolation_qual[cnt_iso].status_date = format(o.status_dt_tm,"mm/dd/yy hh:mm;;d")
   ENDIF
  FOOT  o.order_id
   row + 0
  FOOT  o.current_start_dt_tm
   row + 0
  FOOT  catalog_type_sort
   IF ( NOT (o.catalog_cd IN (full_code_cd, limited_code_cd, no_code_cd, fullop_code_cd,
   limitedop_code_cd,
   noop_code_cd, op_code_cd, isolation_cd))
    AND  NOT (o.catalog_type_cd IN (pharmacy_cd, consult_cd, diet_cd))
    AND o.activity_type_cd != diet_consult_cd)
    stat = alterlist(pt_transfer->catalog_qual[cnt_cat].orders_qual,cnt_ord), pt_transfer->
    catalog_qual[cnt_cat].orders_cnt = cnt_ord
   ENDIF
  FOOT REPORT
   stat = alterlist(pt_transfer->catalog_qual,cnt_cat), pt_transfer->catalog_cnt = cnt_cat, stat =
   alterlist(pt_transfer->consult_qual,cnt_cons),
   pt_transfer->consult_cnt = cnt_cons, stat = alterlist(pt_transfer->diet_qual,cnt_diet),
   pt_transfer->diet_cnt = cnt_diet,
   stat = alterlist(pt_transfer->isolation_qual,cnt_iso)
  WITH nocounter
 ;end select
 IF (test_ind=1)
  CALL echo("Resort consults by..")
 ENDIF
 SELECT INTO "nl:"
  status_date = pt_transfer->consult_qual[d1.seq].status_date
  FROM (dummyt d1  WITH seq = value(pt_transfer->consult_cnt))
  WHERE (pt_transfer->consult_cnt > 0)
  ORDER BY status_date DESC
  HEAD REPORT
   stat = alterlist(pt_transfer->resort_consult_qual,10), r_cnt = 0
  DETAIL
   r_cnt = (r_cnt+ 1)
   IF (mod(r_cnt,10)=1)
    stat = alterlist(pt_transfer->resort_consult_qual,(r_cnt+ 10))
   ENDIF
   pt_transfer->resort_consult_qual[r_cnt].ord_name = pt_transfer->consult_qual[d1.seq].ord_name,
   pt_transfer->resort_consult_qual[r_cnt].status = pt_transfer->consult_qual[d1.seq].status,
   pt_transfer->resort_consult_qual[r_cnt].status_date = pt_transfer->consult_qual[d1.seq].
   status_date,
   pt_transfer->resort_consult_qual[r_cnt].order_detail = pt_transfer->consult_qual[d1.seq].
   order_detail, pt_transfer->resort_consult_qual[r_cnt].completed_by = pt_transfer->consult_qual[d1
   .seq].completed_by
  FOOT REPORT
   stat = alterlist(pt_transfer->resort_consult_qual,r_cnt), pt_transfer->resort_consult_cnt = r_cnt
  WITH nocounter
 ;end select
 IF (test_ind=1)
  CALL echo("Get code_status order..")
 ENDIF
 IF (size(pt_transfer->code_status_qual,5)=0)
  SELECT INTO "nl:"
   FROM orders o
   WHERE (o.person_id=pt_transfer->person_id)
    AND o.catalog_cd IN (full_code_cd, limited_code_cd, no_code_cd, fullop_code_cd, limitedop_code_cd,
   noop_code_cd, op_code_cd)
    AND o.template_order_flag IN (0, 2)
    AND o.order_status_cd=os_ord_cd
   ORDER BY o.current_start_dt_tm DESC
   HEAD o.current_start_dt_tm
    stat = alterlist(pt_transfer->code_status_qual,1), pt_transfer->code_status_qual[1].order_name =
    trim(o.ordered_as_mnemonic,3), pt_transfer->code_status_qual[1].status_date = format(o
     .current_start_dt_tm,"mm/dd/yyyy hh:mm;;d"),
    pt_transfer->code_status_qual[1].order_detail = trim(o.order_detail_display_line,3), pt_transfer
    ->code_status_qual[1].order_id = o.order_id, pt_transfer->code_status_qual[1].order_status = trim
    (uar_get_code_display(o.order_status_cd))
   WITH nocounter
  ;end select
 ENDIF
 IF (test_ind=1)
  CALL echo("Get form dta..")
 ENDIF
 DECLARE number_of_forms = i2
 SET number_of_forms = 17
 SET stat = alterlist(form_data->qual,number_of_forms)
 SET form_data->qual[1].dcp_forms_ref_id = 642338.00
 SET form_data->qual[1].type = "Nutrition Eval1"
 SET form_data->qual[1].max_cnt = 1
 SET form_data->qual[1].cur_cnt = 0
 SET form_data->qual[2].dcp_forms_ref_id = 920778.00
 SET form_data->qual[2].type = "Nutrition Eval2"
 SET form_data->qual[2].max_cnt = 1
 SET form_data->qual[2].cur_cnt = 0
 SET form_data->qual[3].dcp_forms_ref_id = 643516.00
 SET form_data->qual[3].type = "PT Eval1"
 SET form_data->qual[3].max_cnt = 1
 SET form_data->qual[3].cur_cnt = 0
 SET form_data->qual[4].dcp_forms_ref_id = 2140767.00
 SET form_data->qual[4].type = "PT Eval2"
 SET form_data->qual[4].max_cnt = 1
 SET form_data->qual[4].cur_cnt = 0
 SET form_data->qual[5].dcp_forms_ref_id = 2140557.00
 SET form_data->qual[5].type = "PT Eval3"
 SET form_data->qual[5].max_cnt = 1
 SET form_data->qual[5].cur_cnt = 0
 SET form_data->qual[6].dcp_forms_ref_id = 852985.00
 SET form_data->qual[6].type = "PT Treat1"
 SET form_data->qual[6].max_cnt = 2
 SET form_data->qual[6].cur_cnt = 0
 SET form_data->qual[7].dcp_forms_ref_id = 1425708.00
 SET form_data->qual[7].type = "OT Eval1"
 SET form_data->qual[7].max_cnt = 1
 SET form_data->qual[7].cur_cnt = 0
 SET form_data->qual[8].dcp_forms_ref_id = 1641839.00
 SET form_data->qual[8].type = "OT Treat1"
 SET form_data->qual[8].max_cnt = 2
 SET form_data->qual[8].cur_cnt = 0
 SET form_data->qual[9].dcp_forms_ref_id = 1632230.00
 SET form_data->qual[9].type = "ST Eval1"
 SET form_data->qual[9].max_cnt = 1
 SET form_data->qual[9].cur_cnt = 0
 SET form_data->qual[10].dcp_forms_ref_id = 1720679.00
 SET form_data->qual[10].type = "ST Eval2"
 SET form_data->qual[10].max_cnt = 1
 SET form_data->qual[10].cur_cnt = 0
 SET form_data->qual[11].dcp_forms_ref_id = 1720689.00
 SET form_data->qual[11].type = "ST Eval3"
 SET form_data->qual[11].max_cnt = 1
 SET form_data->qual[11].cur_cnt = 0
 SET form_data->qual[12].dcp_forms_ref_id = 1720672.00
 SET form_data->qual[12].type = "ST Eval4"
 SET form_data->qual[12].max_cnt = 1
 SET form_data->qual[12].cur_cnt = 0
 SET form_data->qual[13].dcp_forms_ref_id = 1728059.00
 SET form_data->qual[13].type = "ST Treat1"
 SET form_data->qual[13].max_cnt = 2
 SET form_data->qual[13].cur_cnt = 0
 SET form_data->qual[14].dcp_forms_ref_id = 2140563.00
 SET form_data->qual[14].type = "RT Eval1"
 SET form_data->qual[14].max_cnt = 1
 SET form_data->qual[14].cur_cnt = 0
 SET form_data->qual[15].dcp_forms_ref_id = 642707.00
 SET form_data->qual[15].type = "RT Treat1"
 SET form_data->qual[15].max_cnt = 2
 SET form_data->qual[15].cur_cnt = 0
 SET form_data->qual[16].dcp_forms_ref_id = 2079420.00
 SET form_data->qual[16].type = "PULM Eval1"
 SET form_data->qual[16].max_cnt = 1
 SET form_data->qual[16].cur_cnt = 0
 SET form_data->qual[17].dcp_forms_ref_id = 26102340.00
 SET form_data->qual[17].type = "PULM Eval2"
 SET form_data->qual[17].max_cnt = 1
 SET form_data->qual[17].cur_cnt = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(form_data->qual,5))),
   dcp_forms_activity dcp,
   dcp_forms_activity_comp dcpc
  PLAN (d)
   JOIN (dcp
   WHERE (dcp.encntr_id=pt_transfer->encntr_id)
    AND ((dcp.dcp_forms_ref_id+ 0)=form_data->qual[d.seq].dcp_forms_ref_id)
    AND dcp.active_ind=1)
   JOIN (dcpc
   WHERE dcpc.dcp_forms_activity_id=dcp.dcp_forms_activity_id
    AND dcpc.parent_entity_name="CLINICAL_EVENT")
  ORDER BY dcp.dcp_forms_ref_id, dcp.form_dt_tm DESC
  HEAD REPORT
   cnt_f = 0, stat = alterlist(form_results->form_qual,5)
  HEAD dcp.dcp_forms_ref_id
   row + 0
  HEAD dcp.form_dt_tm
   row + 0
  DETAIL
   IF ((form_data->qual[d.seq].cur_cnt < form_data->qual[d.seq].max_cnt))
    cnt_f = (cnt_f+ 1)
    IF (mod(cnt_f,5)=1)
     stat = alterlist(form_results->form_qual,(cnt_f+ 5))
    ENDIF
    form_results->form_qual[cnt_f].form_name = trim(dcp.description), form_results->form_qual[cnt_f].
    form_type = form_data->qual[d.seq].type, form_results->form_qual[cnt_f].dcp_forms_ref_id = dcp
    .dcp_forms_ref_id,
    form_results->form_qual[cnt_f].dcp_forms_activity_id = dcp.dcp_forms_activity_id, form_results->
    form_qual[cnt_f].form_event_id = dcpc.parent_entity_id
   ENDIF
   form_data->qual[d.seq].cur_cnt = (form_data->qual[d.seq].cur_cnt+ 1)
  FOOT REPORT
   stat = alterlist(form_results->form_qual,cnt_f), form_results->form_cnt = cnt_f
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  sort_form =
  IF ((form_results->form_qual[d.seq].form_type="Nutrition Eval1")) 1
  ELSEIF ((form_results->form_qual[d.seq].form_type="Nutrition Eval2")) 2
  ELSEIF ((form_results->form_qual[d.seq].form_type IN ("PT Eval1", "PT Eval2"))) 3
  ELSEIF ((form_results->form_qual[d.seq].form_type="PT Eval3")) 4
  ELSEIF ((form_results->form_qual[d.seq].form_type="PT Treat1")) 5
  ELSEIF ((form_results->form_qual[d.seq].form_type="OT Eval1")) 6
  ELSEIF ((form_results->form_qual[d.seq].form_type="OT Treat1")) 7
  ELSEIF ((form_results->form_qual[d.seq].form_type IN ("ST Eval1", "ST Eval2", "ST Eval3",
  "ST Eval4"))) 8
  ELSEIF ((form_results->form_qual[d.seq].form_type="ST Treat1")) 9
  ELSEIF ((form_results->form_qual[d.seq].form_type="RT Eval1")) 10
  ELSEIF ((form_results->form_qual[d.seq].form_type="RT Treat1")) 11
  ELSEIF ((form_results->form_qual[d.seq].form_type IN ("PULM Eval1", "PULM Eval2"))) 12
  ENDIF
  FROM (dummyt d  WITH seq = value(form_results->form_cnt)),
   clinical_event ce,
   clinical_event ce1,
   clinical_event ce2,
   ce_event_note cen,
   long_blob lb,
   clinical_event ce3,
   ce_event_note cen1,
   long_blob lb1,
   clinical_event ce4,
   ce_event_note cen2,
   long_blob lb2
  PLAN (d)
   JOIN (ce
   WHERE (ce.event_id=form_results->form_qual[d.seq].form_event_id)
    AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime)
    AND ce.result_status_cd != inerror_cd)
   JOIN (ce1
   WHERE ce1.parent_event_id=ce.event_id
    AND ce1.valid_until_dt_tm >= cnvtdatetime(curdate,curtime)
    AND ce1.event_cd != ce.event_cd
    AND ce1.result_status_cd != inerror_cd)
   JOIN (ce2
   WHERE ce2.parent_event_id=outerjoin(ce1.event_id)
    AND ce2.valid_until_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime)))
   JOIN (cen
   WHERE cen.event_id=outerjoin(ce2.event_id)
    AND cen.valid_until_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime)))
   JOIN (lb
   WHERE lb.parent_entity_id=outerjoin(cen.ce_event_note_id))
   JOIN (ce3
   WHERE ce3.parent_event_id=outerjoin(ce2.event_id)
    AND ce3.valid_until_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime)))
   JOIN (cen1
   WHERE cen1.event_id=outerjoin(ce3.event_id)
    AND cen1.valid_until_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime)))
   JOIN (lb1
   WHERE lb1.parent_entity_id=outerjoin(cen1.ce_event_note_id))
   JOIN (ce4
   WHERE ce4.parent_event_id=outerjoin(ce3.event_id)
    AND ce4.valid_until_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime))
    AND ce4.event_id != outerjoin(ce3.event_id)
    AND ce4.parent_event_id != outerjoin(ce3.parent_event_id))
   JOIN (cen2
   WHERE cen2.event_id=outerjoin(ce4.event_id)
    AND cen2.valid_until_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime)))
   JOIN (lb2
   WHERE lb2.parent_entity_id=outerjoin(cen2.ce_event_note_id))
  ORDER BY sort_form, ce.event_end_dt_tm DESC, ce.event_id,
   ce1.event_id, ce2.event_id, ce3.event_id,
   ce4.event_id
  HEAD REPORT
   cnt_form = 0, stat = alterlist(pt_transfer->form_qual,5)
  HEAD sort_form
   row + 0
  HEAD ce.event_end_dt_tm
   row + 0
  HEAD ce.event_id
   cnt_form = (cnt_form+ 1)
   IF (mod(cnt_form,5)=1)
    stat = alterlist(pt_transfer->form_qual,(cnt_form+ 5))
   ENDIF
   pt_transfer->form_qual[cnt_form].form_name = trim(uar_get_code_display(ce.event_cd)), pt_transfer
   ->form_qual[cnt_form].form_date = format(ce.event_end_dt_tm,"mm/dd/yy hh:mm;;d"), pt_transfer->
   form_qual[cnt_form].form_type = form_results->form_qual[d.seq].form_type,
   pt_transfer->form_qual[cnt_form].p_event_id = ce.parent_event_id, pt_transfer->form_qual[cnt_form]
   .event_id = ce.event_id, stat = alterlist(pt_transfer->form_qual[cnt_form].sub1_qual,10),
   cnt_sub1 = 0
  HEAD ce1.event_id
   cnt_sub1 = (cnt_sub1+ 1)
   IF (mod(cnt_sub1,10)=1
    AND cnt_sub1 != 1)
    stat = alterlist(pt_transfer->form_qual[cnt_form].sub1_qual,(cnt_sub1+ 10))
   ENDIF
   pt_transfer->form_qual[cnt_form].sub1_qual[cnt_sub1].event_display = trim(ce1.event_title_text),
   pt_transfer->form_qual[cnt_form].sub1_qual[cnt_sub1].p_event_id = ce1.parent_event_id, pt_transfer
   ->form_qual[cnt_form].sub1_qual[cnt_sub1].event_id = ce1.event_id,
   stat = alterlist(pt_transfer->form_qual[cnt_form].sub1_qual[cnt_sub1].sub2_qual,10), cnt_sub2 = 0
  HEAD ce2.event_id
   cnt_sub2 = (cnt_sub2+ 1)
   IF (mod(cnt_sub2,10)=1
    AND cnt_sub2 != 1)
    stat = alterlist(pt_transfer->form_qual[cnt_form].sub1_qual[cnt_sub1].sub2_qual,(cnt_sub2+ 10))
   ENDIF
   pt_transfer->form_qual[cnt_form].sub1_qual[cnt_sub1].sub2_qual[cnt_sub2].event_display = trim(
    uar_get_code_display(ce2.event_cd)), pt_transfer->form_qual[cnt_form].sub1_qual[cnt_sub1].
   sub2_qual[cnt_sub2].event_result = trim(ce2.result_val), pt_transfer->form_qual[cnt_form].
   sub1_qual[cnt_sub1].sub2_qual[cnt_sub2].event_date = format(ce2.event_end_dt_tm,
    "mm/dd/yy hh:mm;;d"),
   pt_transfer->form_qual[cnt_form].sub1_qual[cnt_sub1].sub2_qual[cnt_sub2].event_comm = trim(lb
    .long_blob), pt_transfer->form_qual[cnt_form].sub1_qual[cnt_sub1].sub2_qual[cnt_sub2].
   event_comp_cd = cen.compression_cd, pt_transfer->form_qual[cnt_form].sub1_qual[cnt_sub1].
   sub2_qual[cnt_sub2].p_event_id = ce2.parent_event_id,
   pt_transfer->form_qual[cnt_form].sub1_qual[cnt_sub1].sub2_qual[cnt_sub2].event_id = ce2.event_id,
   stat = alterlist(pt_transfer->form_qual[cnt_form].sub1_qual[cnt_sub1].sub2_qual[cnt_sub2].
    sub3_qual,10), cnt_sub3 = 0
  HEAD ce3.event_id
   IF (ce3.result_status_cd != inerror_cd
    AND ce3.event_id > 0)
    cnt_sub3 = (cnt_sub3+ 1)
    IF (mod(cnt_sub3,10)=1
     AND cnt_sub3 != 1)
     stat = alterlist(pt_transfer->form_qual[cnt_form].sub1_qual[cnt_sub1].sub2_qual[cnt_sub2].
      sub3_qual,(cnt_sub3+ 10))
    ENDIF
    pt_transfer->form_qual[cnt_form].sub1_qual[cnt_sub1].sub2_qual[cnt_sub2].sub3_qual[cnt_sub3].
    event_display = trim(uar_get_code_display(ce3.event_cd)), pt_transfer->form_qual[cnt_form].
    sub1_qual[cnt_sub1].sub2_qual[cnt_sub2].sub3_qual[cnt_sub3].event_result = trim(ce3.result_val),
    pt_transfer->form_qual[cnt_form].sub1_qual[cnt_sub1].sub2_qual[cnt_sub2].sub3_qual[cnt_sub3].
    event_date = format(ce3.event_end_dt_tm,"mm/dd/yy hh:mm;;d"),
    pt_transfer->form_qual[cnt_form].sub1_qual[cnt_sub1].sub2_qual[cnt_sub2].sub3_qual[cnt_sub3].
    event_comm = trim(lb1.long_blob), pt_transfer->form_qual[cnt_form].sub1_qual[cnt_sub1].sub2_qual[
    cnt_sub2].sub3_qual[cnt_sub3].event_comp_cd = cen1.compression_cd, pt_transfer->form_qual[
    cnt_form].sub1_qual[cnt_sub1].sub2_qual[cnt_sub2].sub3_qual[cnt_sub3].p_event_id = ce3
    .parent_event_id,
    pt_transfer->form_qual[cnt_form].sub1_qual[cnt_sub1].sub2_qual[cnt_sub2].sub3_qual[cnt_sub3].
    event_id = ce3.event_id, stat = alterlist(pt_transfer->form_qual[cnt_form].sub1_qual[cnt_sub1].
     sub2_qual[cnt_sub2].sub3_qual[cnt_sub3].sub4_qual,10), cnt_sub4 = 0
   ENDIF
  HEAD ce4.event_id
   IF (ce4.result_status_cd != inerror_cd
    AND ce4.event_id > 0)
    cnt_sub4 = (cnt_sub4+ 1)
    IF (mod(cnt_sub4,10)=1
     AND cnt_sub4 != 1)
     stat = alterlist(pt_transfer->form_qual[cnt_form].sub1_qual[cnt_sub1].sub2_qual[cnt_sub2].
      sub3_qual[cnt_sub3].sub4_qual,(cnt_sub4+ 10))
    ENDIF
    pt_transfer->form_qual[cnt_form].sub1_qual[cnt_sub1].sub2_qual[cnt_sub2].sub3_qual[cnt_sub3].
    sub4_qual[cnt_sub4].event_display = trim(uar_get_code_display(ce4.event_cd)), pt_transfer->
    form_qual[cnt_form].sub1_qual[cnt_sub1].sub2_qual[cnt_sub2].sub3_qual[cnt_sub3].sub4_qual[
    cnt_sub4].event_result = trim(ce4.result_val), pt_transfer->form_qual[cnt_form].sub1_qual[
    cnt_sub1].sub2_qual[cnt_sub2].sub3_qual[cnt_sub3].sub4_qual[cnt_sub4].event_date = format(ce4
     .event_end_dt_tm,"mm/dd/yy hh:mm;;d"),
    pt_transfer->form_qual[cnt_form].sub1_qual[cnt_sub1].sub2_qual[cnt_sub2].sub3_qual[cnt_sub3].
    sub4_qual[cnt_sub4].event_comm = trim(lb2.long_blob), pt_transfer->form_qual[cnt_form].sub1_qual[
    cnt_sub1].sub2_qual[cnt_sub2].sub3_qual[cnt_sub3].sub4_qual[cnt_sub4].event_comp_cd = cen2
    .compression_cd, pt_transfer->form_qual[cnt_form].sub1_qual[cnt_sub1].sub2_qual[cnt_sub2].
    sub3_qual[cnt_sub3].sub4_qual[cnt_sub4].p_event_id = ce4.parent_event_id,
    pt_transfer->form_qual[cnt_form].sub1_qual[cnt_sub1].sub2_qual[cnt_sub2].sub3_qual[cnt_sub3].
    sub4_qual[cnt_sub4].event_id = ce4.event_id
   ENDIF
  FOOT  ce4.event_id
   row + 0
  FOOT  ce3.event_id
   stat = alterlist(pt_transfer->form_qual[cnt_form].sub1_qual[cnt_sub1].sub2_qual[cnt_sub2].
    sub3_qual[cnt_sub3].sub4_qual,cnt_sub4), pt_transfer->form_qual[cnt_form].sub1_qual[cnt_sub1].
   sub2_qual[cnt_sub2].sub3_qual[cnt_sub3].sub4_cnt = cnt_sub4
  FOOT  ce2.event_id
   stat = alterlist(pt_transfer->form_qual[cnt_form].sub1_qual[cnt_sub1].sub2_qual[cnt_sub2].
    sub3_qual,cnt_sub3), pt_transfer->form_qual[cnt_form].sub1_qual[cnt_sub1].sub2_qual[cnt_sub2].
   sub3_cnt = cnt_sub3
  FOOT  ce1.event_id
   stat = alterlist(pt_transfer->form_qual[cnt_form].sub1_qual[cnt_sub1].sub2_qual,cnt_sub2),
   pt_transfer->form_qual[cnt_form].sub1_qual[cnt_sub1].sub2_cnt = cnt_sub2
  FOOT  ce.event_id
   stat = alterlist(pt_transfer->form_qual[cnt_form].sub1_qual,cnt_sub1), pt_transfer->form_qual[
   cnt_form].sub1_cnt = cnt_sub1
  FOOT  ce.event_end_dt_tm
   row + 0
  FOOT  sort_form
   row + 0
  FOOT REPORT
   stat = alterlist(pt_transfer->form_qual,cnt_form), pt_transfer->form_cnt = cnt_form
  WITH nocounter, memsort
 ;end select
 IF (test_ind=1)
  CALL echo("Print report...")
 ENDIF
 SELECT INTO value(printer_disp)
  FROM (dummyt  WITH seq = value(1))
  HEAD REPORT
   MACRO (print_blob)
    IF (ycol > 725)
     BREAK
    ENDIF
    FOR (y = 1 TO pt_transfer->blob_qual[x].blobs_cnt)
      IF (substring(1,11,pt_transfer->blob_qual[x].blobs_qual[y].event_title_text)="Addendum by")
       xcol = 30, row + 1,
       CALL print(calcpos(xcol,ycol)),
       "{f/0}{cpi/14}{b}", pt_transfer->blob_qual[x].blobs_qual[y].event_title_text, ycol = (ycol+ 12
       ),
       row + 1
      ELSE
       ycol = (ycol+ 12), row + 1, xcol = 15,
       row + 1,
       CALL print(calcpos(xcol,ycol)), "{f/0}{cpi/14}{b}{u}",
       blob_set_name, ":", "{endb}{endu}",
       ycol = (ycol+ 12), row + 1, xcol = 15,
       row + 1,
       CALL print(calcpos(xcol,ycol)), "Note Type: ",
       pt_transfer->blob_qual[x].blob_event_cd, ycol = (ycol+ 12), row + 1,
       xcol = 15, row + 1,
       CALL print(calcpos(xcol,ycol)),
       "Note Date: ", pt_transfer->blob_qual[x].blob_date, ycol = (ycol+ 12),
       row + 1
      ENDIF
      IF ((pt_transfer->blob_qual[x].blobs_qual[y].blobseq < 2)
       AND binit=1)
       status1 = 0,
       CALL uar_rtfcnvt_init(context,pgwidth,status1)
      ELSE
       row + 0
      ENDIF
      eventidhold = pt_transfer->blob_qual[x].blobs_qual[y].event_id, blob_out = fillstring(65536," "
       ), blob_ret_len = 0,
      CALL uar_ocf_uncompress(pt_transfer->blob_qual[x].blobs_qual[y].blob_contents,size(pt_transfer
       ->blob_qual[x].blobs_qual[y].blob_contents),blob_out,65536,blob_ret_len),
      CALL uar_rtfcnvt_put(context,nullterm(trim(blob_out)),status1)
      IF (context > 0)
       CALL uar_rtfcnvt_convert(context,cnvtto,status1)
       WHILE (status1=0)
         plineout = fillstring(350," "),
         CALL uar_rtfcnvt_get(context,plineout,status1)
         IF (status1=0
          AND plineout != fillstring(350," "))
          IF (ycol > 725)
           BREAK
          ENDIF
          xcol = 15,
          CALL print(calcpos(xcol,ycol)), plineout,
          ycol = (ycol+ 12), row + 1
         ELSE
          IF ((status1 != - (1)))
           " ERROR with GET ", status1
          ENDIF
         ENDIF
       ENDWHILE
       CALL uar_rtfcnvt_term(context,status1)
      ENDIF
      FOR (z = 1 TO pt_transfer->blob_qual[x].action_cnt)
        IF (textlen(trim(pt_transfer->blob_qual[x].action_qual[z].type,3)) > 0
         AND (pt_transfer->blob_qual[x].blobs_qual[y].event_title_text != "Addendum by*")
         AND (y=pt_transfer->blob_qual[x].blobs_cnt))
         IF (ycol > 725)
          BREAK
         ENDIF
         IF (z=1)
          ycol = (ycol+ 12), row + 1
         ENDIF
         output_display = concat("{f/0}{cpi/14}{b}",pt_transfer->blob_qual[x].action_qual[z].type," ",
          pt_transfer->blob_qual[x].action_qual[z].status," by ",
          pt_transfer->blob_qual[x].action_qual[z].prsnl_name," ",pt_transfer->blob_qual[x].
          action_qual[z].date,"{endb}"), xcol = 30, row + 1,
         CALL print(calcpos(xcol,ycol)), output_display, ycol = (ycol+ 12),
         row + 1
        ENDIF
      ENDFOR
    ENDFOR
   ENDMACRO
   ,
   MACRO (print_blob_comment_report)
    IF (compression_cd=compress_cd)
     blob_rtf = fillstring(65536," "), blobout2 = fillstring(65536," "), blob_return_len = 0,
     bsize = 0,
     CALL uar_ocf_uncompress(blob_contents,size(blob_contents),blobout2,size(blobout2),
     blob_return_len), blobout2 = replace(blobout2,"ocf_blob","",0),
     blobout2 = replace(blobout2,char(10),"|",0), blobout2 = replace(blobout2,char(13),"|",0),
     CALL uar_rtf2(trim(blobout2),size(blobout2),blobout2,size(blobout2),bsize,0),
     blobout2 = replace(blobout2,char(10),"|",0), blobout2 = replace(blobout2,char(13),"|",0)
     IF (blob_type="comment")
      IF (findstring("|",blobout2,1,0) > 0)
       blobout2 = substring(1,(findstring("|",blobout2,1,0) - 1),blobout2)
      ENDIF
     ELSEIF (blob_type="report")
      WHILE (findstring("||",blobout2,1,0) > 0)
        blobout2 = replace(blobout2,"||","|",0)
      ENDWHILE
     ELSEIF (blob_type="form_comment")
      WHILE (findstring("|",blobout2,1,0) > 0)
       blobout2 = replace(blobout2,"||"," ",0),blobout2 = replace(blobout2,"|"," ",0)
      ENDWHILE
     ENDIF
    ELSEIF (compression_cd > 0)
     blobout2 = fillstring(65536," "), bsize = 0, blobout2 = blob_contents,
     blobout2 = replace(blobout2,"ocf_blob","",0), blobout2 = replace(blobout2,char(10),"|",0),
     blobout2 = replace(blobout2,char(13),"|",0),
     blob_return_len = (size(trim(blobout2))+ 1),
     CALL uar_rtf2(trim(blobout2),size(blobout2),blobout2,size(blobout2),bsize,0), blobout2 = replace
     (blobout2,char(10),"|",0),
     blobout2 = replace(blobout2,char(13),"|",0)
     IF (blob_type="comment")
      IF (findstring("|",blobout2,1,0) > 0)
       blobout2 = substring(1,(findstring("|",blobout2,1,0) - 1),blobout2)
      ENDIF
     ELSEIF (blob_type="report")
      WHILE (findstring("||",blobout2,1,0) > 0)
        blobout2 = replace(blobout2,"||","|",0)
      ENDWHILE
     ELSEIF (blob_type="form_comment")
      WHILE (findstring("|",blobout2,1,0) > 0)
       blobout2 = replace(blobout2,"||"," ",0),blobout2 = replace(blobout2,"|"," ",0)
      ENDWHILE
     ENDIF
    ENDIF
    IF (blob_type="report")
     new_blob_contents = trim(blobout2,3)
     IF (trim(new_blob_contents,3) > " ")
      IF (ycol > 725)
       BREAK
      ENDIF
      xcol = 50, row + 1,
      CALL print(calcpos(xcol,ycol)),
      "{f/0}{cpi/14}Report: ", ycol = (ycol+ 12), row + 1
      IF (findstring("|",new_blob_contents,1,0) > 0)
       tempstring = trim(new_blob_contents,3), eol = size(trim(tempstring,3))
       IF (substring(eol,eol,tempstring) != "|")
        tempstring = concat(tempstring,"|")
       ENDIF
       parse_string = trim(new_blob_contents,3)
       WHILE (size(trim(parse_string,3)) > 0)
        IF (findstring("|",tempstring,1,0)=1)
         temp_line_feed = findstring("|",tempstring,2,0), parse_string = substring(2,(temp_line_feed
           - 1),tempstring)
        ELSEIF (findstring("|",tempstring,1,0) > 0)
         temp_line_feed = findstring("|",tempstring,1,0)
         IF (size(substring(1,(temp_line_feed - 1),tempstring)) >= 1)
          parse_string = substring(1,(temp_line_feed - 1),tempstring)
         ENDIF
        ELSE
         temp_line_feed = size(tempstring), parse_string = substring(1,eol,tempstring)
        ENDIF
        ,
        IF (size(trim(parse_string,3)) > 0)
         IF (ycol > 725)
          BREAK
         ENDIF
         parse_string = replace(parse_string,"|","",0), xcol = 50, row + 1,
         CALL print(calcpos(xcol,ycol)), parse_string, ycol = (ycol+ 12),
         tempstring = trim(substring((temp_line_feed+ 1),(eol - temp_line_feed),tempstring),3)
        ENDIF
       ENDWHILE
      ELSE
       IF (ycol > 725)
        BREAK
       ENDIF
       output_display1 = trim(new_blob_contents,3), xcol = 50, row + 1,
       CALL print(calcpos(xcol,ycol)), output_display1, ycol = (ycol+ 12)
      ENDIF
     ENDIF
    ENDIF
   ENDMACRO
   ,
   MACRO (line_wrap)
    limit = 0, maxlen = wrapcol, cr = char(13),
    lf = char(10)
    WHILE (tempstring > " "
     AND limit < 1000)
      ii = 0, limit = (limit+ 1), pos = 0
      WHILE (pos=0)
       ii = (ii+ 1),
       IF (substring((maxlen - ii),1,tempstring) IN (" ", ",", cr, lf))
        pos = (maxlen - ii)
       ELSEIF (ii=maxlen)
        pos = maxlen
       ENDIF
      ENDWHILE
      printstring = substring(1,pos,tempstring)
      IF (critical_value=1)
       IF (ycol > 725)
        BREAK
       ENDIF
       CALL print(calcpos(xcol,ycol)), "{f/0}{cpi/14}{b}", printstring,
       "{endb}"
      ELSE
       IF (ycol > 725)
        BREAK
       ENDIF
       CALL print(calcpos(xcol,ycol)), "{f/0}{cpi/14}", printstring
      ENDIF
      ycol = (ycol+ 12), row + 1
      IF (limit=1)
       maxlen = (maxlen - 5)
      ENDIF
      tempstring = substring((pos+ 1),999,tempstring)
    ENDWHILE
   ENDMACRO
   ,
   MACRO (line_wrap2)
    b_linefeed = concat(char(10)), b_cc = 0, b_s = 1,
    b_len = 0, b_e = 0, b_tmp_comment = fillstring(90,""),
    a_tmp_string = fillstring(90,""), tmp_var = 0, b_cc = 1,
    b_s = 1
    WHILE (b_cc)
      IF (ycol > 725)
       BREAK
      ENDIF
      b_tmp_comment = substring(b_s,90,tempstring), b_e = findstring(b_linefeed,b_tmp_comment,1)
      IF (b_e)
       a_tmp_string = substring(1,b_e,b_tmp_comment),
       CALL print(calcpos(xcol,ycol)), a_tmp_string,
       row + 1, ycol = (ycol+ 12), b_s = (b_s+ b_e)
      ELSE
       IF (b_tmp_comment > " ")
        CALL print(calcpos(xcol,ycol)), b_tmp_comment, row + 1,
        ycol = (ycol+ 12), b_s = (b_s+ 90)
       ELSE
        b_cc = 0
       ENDIF
      ENDIF
    ENDWHILE
   ENDMACRO
   , line = fillstring(200,"-"), line_short = fillstring(125,"-"),
   xcol = 0, ycol = 0
  HEAD PAGE
   output_display = "", "{f/0}{cpi/14}", ycol = 30,
   xcol = 30,
   CALL print(calcpos(xcol,ycol)), "Baystate Health Post Acute Care Discharge Report",
   xcol = 300,
   CALL print(calcpos(xcol,ycol)), "Printed on: ",
   printed_on, "   by: ", printed_by,
   ycol = (ycol+ 12), row + 1, xcol = 30,
   row + 1,
   CALL print(calcpos(xcol,ycol)), line,
   ycol = (ycol+ 12), row + 1, xcol = 30,
   row + 1,
   CALL print(calcpos(xcol,ycol)), "{b}Name:{endb}",
   xcol = 100, row + 1,
   CALL print(calcpos(xcol,ycol)),
   pt_transfer->name, xcol = 250, row + 1,
   CALL print(calcpos(xcol,ycol)), "{b}DOB:{endb}", xcol = 280,
   row + 1,
   CALL print(calcpos(xcol,ycol)), pt_transfer->dob,
   xcol = 350, row + 1,
   CALL print(calcpos(xcol,ycol)),
   "{b}MR#:{endb}", xcol = 380, row + 1,
   CALL print(calcpos(xcol,ycol)), pt_transfer->mrn, xcol = 440,
   row + 1,
   CALL print(calcpos(xcol,ycol)), "{b}FIN:{endb}",
   xcol = 470, row + 1,
   CALL print(calcpos(xcol,ycol)),
   pt_transfer->fin, ycol = (ycol+ 12), row + 1,
   xcol = 30, row + 1,
   CALL print(calcpos(xcol,ycol)),
   "{b}Last Unit:{endb}", xcol = 100, row + 1,
   CALL print(calcpos(xcol,ycol)), pt_transfer->last_nurse_unit, xcol = 250,
   row + 1,
   CALL print(calcpos(xcol,ycol)), "{b}Admit:{endb}",
   xcol = 290, row + 1,
   CALL print(calcpos(xcol,ycol)),
   pt_transfer->reg_date, xcol = 440, row + 1,
   CALL print(calcpos(xcol,ycol)), "{b}Discharge:{endb}", output_display = format(pt_transfer->
    disch_date,"mm/dd/yyyy hh:mm;;d"),
   xcol = 500, row + 1,
   CALL print(calcpos(xcol,ycol)),
   output_display, ycol = (ycol+ 12), row + 1,
   xcol = 30, row + 1,
   CALL print(calcpos(xcol,ycol)),
   "{b}Facility:{endb}", xcol = 100, row + 1,
   CALL print(calcpos(xcol,ycol)), pt_transfer->facility, xcol = 250,
   row + 1,
   CALL print(calcpos(xcol,ycol)), "{b}Phone:{endb} ",
   pt_transfer->facility_phone, ycol = (ycol+ 12), row + 1,
   xcol = 30, row + 1,
   CALL print(calcpos(xcol,ycol)),
   line, ycol = (ycol+ 24), row + 1
  DETAIL
   output_display = "", output_display1 = "", output_display2 = "",
   blob_set_name = "", parse_tempstring = "", tempstring = "",
   xcol = 30, row + 1,
   CALL print(calcpos(xcol,ycol)),
   "{b}{u}Patient Demographics:{endb}{endu}", ycol = (ycol+ 12), row + 1,
   xcol = 30, row + 1,
   CALL print(calcpos(xcol,ycol)),
   "{b}SSN:{endb}", xcol = 100, row + 1,
   CALL print(calcpos(xcol,ycol)), pt_transfer->ssn, xcol = 250,
   row + 1,
   CALL print(calcpos(xcol,ycol)), "{b}Facility:{endb}",
   xcol = 310, row + 1,
   CALL print(calcpos(xcol,ycol)),
   pt_transfer->facility, xcol = 440, row + 1,
   CALL print(calcpos(xcol,ycol)), "{b}Religion:{endb}", xcol = 500,
   row + 1,
   CALL print(calcpos(xcol,ycol)), pt_transfer->religion,
   ycol = (ycol+ 12), row + 1, xcol = 30,
   row + 1,
   CALL print(calcpos(xcol,ycol)), "{b}Attending:{endb}",
   xcol = 100, row + 1,
   CALL print(calcpos(xcol,ycol)),
   pt_transfer->attending, xcol = 250, row + 1,
   CALL print(calcpos(xcol,ycol)), "{b}PCP:{endb}", xcol = 310,
   row + 1,
   CALL print(calcpos(xcol,ycol)), pt_transfer->pcp,
   ycol = (ycol+ 12), row + 1, xcol = 30,
   row + 1,
   CALL print(calcpos(xcol,ycol)), "{b}Admit Reason:{endb}"
   IF (size(trim(pt_transfer->admit_reason,3)) > 110)
    tempstring = trim(pt_transfer->admit_reason,3), xcol = 100, wrapcol = 110,
    line_wrap
   ELSE
    xcol = 100, row + 1,
    CALL print(calcpos(xcol,ycol)),
    pt_transfer->admit_reason
   ENDIF
   ycol = (ycol+ 12), row + 1, xcol = 30,
   row + 1,
   CALL print(calcpos(xcol,ycol)), "{b}Address:{endb}",
   xcol = 100, row + 1,
   CALL print(calcpos(xcol,ycol)),
   pt_transfer->address_line, ycol = (ycol+ 12), row + 1,
   xcol = 100, row + 1,
   CALL print(calcpos(xcol,ycol)),
   pt_transfer->city_state_zip, ycol = (ycol+ 24), row + 1,
   output_display = ""
   IF (ycol > 725)
    BREAK
   ENDIF
   IF ((pt_transfer->code_status_qual[1].order_name > " "))
    output_display = concat("{b}{u}Code Status immediately before discharge: ",pt_transfer->
     code_status_qual[1].order_name," ",pt_transfer->code_status_qual[1].order_status," on ",
     pt_transfer->code_status_qual[1].status_date," :{endb}{endu}  ",pt_transfer->code_status_qual[1]
     .order_detail)
    IF (size(trim(output_display,3)) > 120)
     tempstring = trim(output_display), xcol = 30, wrapcol = 120,
     line_wrap
    ELSEIF (size(trim(output_display,3)) > 0)
     xcol = 30,
     CALL print(calcpos(xcol,ycol)), output_display
    ENDIF
    ycol = (ycol+ 12), row + 1
   ELSE
    output_display = concat("{b}{u}No Active Code Status Order found{endb}{endu}"), xcol = 30, row +
    1,
    CALL print(calcpos(xcol,ycol)), output_display, ycol = (ycol+ 12),
    row + 1
   ENDIF
   IF (ycol > 725)
    BREAK
   ENDIF
   IF ((pt_transfer->adv_dir > " "))
    xcol = 30, row + 1,
    CALL print(calcpos(xcol,ycol)),
    "{b}{u}Advance Directives:{endb}{endu}", xcol = 140, row + 1,
    CALL print(calcpos(xcol,ycol)), pt_transfer->adv_dir, ycol = (ycol+ 12),
    row + 1
   ELSE
    xcol = 30, row + 1,
    CALL print(calcpos(xcol,ycol)),
    "{b}{u}Advance Directives:{endb}{endu}", xcol = 140, row + 1,
    CALL print(calcpos(xcol,ycol)), "No result found", ycol = (ycol+ 12),
    row + 1
   ENDIF
   IF ((pt_transfer->adv_date > " "))
    xcol = 100, row + 1,
    CALL print(calcpos(xcol,ycol)),
    "Date:", xcol = 140, row + 1,
    CALL print(calcpos(xcol,ycol)), pt_transfer->adv_date, ycol = (ycol+ 12),
    row + 1
   ENDIF
   IF ((pt_transfer->adv_proxy > " "))
    xcol = 100, row + 1,
    CALL print(calcpos(xcol,ycol)),
    "Proxy:", xcol = 140, row + 1,
    CALL print(calcpos(xcol,ycol)), pt_transfer->adv_proxy, ycol = (ycol+ 12),
    row + 1
   ENDIF
   IF ((pt_transfer->adv_phone > " "))
    xcol = 100, row + 1,
    CALL print(calcpos(xcol,ycol)),
    "Proxy Phone:", xcol = 165, row + 1,
    CALL print(calcpos(xcol,ycol)), pt_transfer->adv_phone, ycol = (ycol+ 12),
    row + 1
   ENDIF
   IF ((pt_transfer->adv_type > " "))
    xcol = 100, row + 1,
    CALL print(calcpos(xcol,ycol)),
    "Type:", xcol = 140, row + 1,
    CALL print(calcpos(xcol,ycol)), pt_transfer->adv_type, ycol = (ycol+ 12),
    row + 1
   ELSE
    xcol = 100, row + 1,
    CALL print(calcpos(xcol,ycol)),
    "Type:", xcol = 140, row + 1,
    CALL print(calcpos(xcol,ycol)), "No result found", ycol = (ycol+ 12),
    row + 1
   ENDIF
   IF ((pt_transfer->adv_copy > " "))
    xcol = 100, row + 1,
    CALL print(calcpos(xcol,ycol)),
    "Copy on Chart:", xcol = 180, row + 1,
    CALL print(calcpos(xcol,ycol)), pt_transfer->adv_copy, ycol = (ycol+ 12),
    row + 1
   ENDIF
   IF ((pt_transfer->adv_loc > " "))
    xcol = 100, row + 1,
    CALL print(calcpos(xcol,ycol)),
    "Location:", xcol = 150, row + 1,
    CALL print(calcpos(xcol,ycol)), pt_transfer->adv_loc, ycol = (ycol+ 12),
    row + 1
   ENDIF
   IF (ycol > 725)
    BREAK
   ENDIF
   xcol = 30, ycol = (ycol+ 12), row + 1,
   CALL print(calcpos(xcol,ycol)), "{b}{u}Allergies:{endb}{endu}"
   IF (textlen(trim(pt_transfer->allergies,3)) > 50)
    tempstring = trim(pt_transfer->allergies,3), xcol = 100, wrapcol = 70,
    line_wrap
   ELSEIF (textlen(trim(pt_transfer->allergies,3)) > 0)
    xcol = 100,
    CALL print(calcpos(xcol,ycol)), pt_transfer->allergies,
    ycol = (ycol+ 12), row + 1
   ELSE
    xcol = 100,
    CALL print(calcpos(xcol,ycol)), "No Allergy Assessment found.",
    ycol = (ycol+ 12), row + 1
   ENDIF
   output_display = ""
   IF (ycol > 725)
    BREAK
   ENDIF
   IF ((pt_transfer->disch_date > 0))
    xcol = 30, ycol = (ycol+ 12), row + 1,
    CALL print(calcpos(xcol,ycol)),
    "{b}{u}Infection Control immediately before discharge:{endb}{endu}"
   ELSE
    xcol = 30, ycol = (ycol+ 12), row + 1,
    CALL print(calcpos(xcol,ycol)), "{b}{u}Infection Control:{endb}{endu}"
   ENDIF
   IF (size(pt_transfer->isolation_qual,5) > 0)
    FOR (x = 1 TO size(pt_transfer->isolation_qual,5))
      IF (ycol > 725)
       BREAK
      ENDIF
      IF ((pt_transfer->disch_date > 0))
       output_display = concat(trim(pt_transfer->isolation_qual[x].iso_detail,3)," ",pt_transfer->
        isolation_qual[x].iso_status," on ",pt_transfer->isolation_qual[x].status_date)
      ELSE
       output_display = trim(pt_transfer->isolation_qual[x].iso_detail,3)
      ENDIF
      IF (x=1
       AND (pt_transfer->disch_date > 0))
       ycol = (ycol+ 12), row + 1
      ENDIF
      IF (size(trim(output_display,3)) > 100)
       tempstring = trim(output_display), xcol = 130, wrapcol = 100,
       line_wrap
      ELSEIF (size(trim(output_display,3)) > 0)
       xcol = 130,
       CALL print(calcpos(xcol,ycol)), output_display,
       ycol = (ycol+ 12), row + 1
      ENDIF
    ENDFOR
   ELSE
    IF ((pt_transfer->disch_date > 0))
     xcol = 280
    ELSE
     xcol = 130
    ENDIF
    CALL print(calcpos(xcol,ycol)), "No Isolation Orders found.", ycol = (ycol+ 12),
    row + 1
   ENDIF
   output_display = ""
   IF (ycol > 725)
    BREAK
   ENDIF
   IF ((pt_transfer->disch_date > 0))
    xcol = 30, ycol = (ycol+ 12), row + 1,
    CALL print(calcpos(xcol,ycol)), "{b}{u}Dietary immediately before discharge:{endb}{endu}"
   ELSE
    xcol = 30, ycol = (ycol+ 12), row + 1,
    CALL print(calcpos(xcol,ycol)), "{b}{u}Dietary:{endb}{endu}"
   ENDIF
   IF ((pt_transfer->diet_cnt > 0))
    FOR (x = 1 TO pt_transfer->diet_cnt)
      IF (ycol > 725)
       BREAK
      ENDIF
      IF (size(trim(pt_transfer->diet_qual[x].order_detail,3)) > 0)
       IF ((pt_transfer->disch_date > 0))
        output_display = concat(pt_transfer->diet_qual[x].order_name," ",pt_transfer->diet_qual[x].
         order_status," on ",pt_transfer->diet_qual[x].status_date,
         " Order Detail: ",pt_transfer->diet_qual[x].order_detail)
       ELSE
        output_display = concat(pt_transfer->diet_qual[x].order_name," Order Detail: ",pt_transfer->
         diet_qual[x].order_detail)
       ENDIF
      ELSE
       IF ((pt_transfer->disch_date > 0))
        output_display = concat(pt_transfer->diet_qual[x].order_name," ",pt_transfer->diet_qual[x].
         order_status," on ",pt_transfer->diet_qual[x].status_date)
       ELSE
        output_display = pt_transfer->diet_qual[x].order_name
       ENDIF
      ENDIF
      IF (x=1
       AND (pt_transfer->disch_date > 0))
       ycol = (ycol+ 12), row + 1
      ENDIF
      IF (size(trim(output_display,3)) > 100)
       tempstring = trim(output_display), xcol = 100, wrapcol = 100,
       line_wrap
      ELSEIF (size(trim(output_display,3)) > 0)
       xcol = 100,
       CALL print(calcpos(xcol,ycol)), output_display,
       ycol = (ycol+ 12), row + 1
      ENDIF
    ENDFOR
   ELSE
    IF ((pt_transfer->disch_date > 0))
     xcol = 230
    ELSE
     xcol = 100
    ENDIF
    CALL print(calcpos(xcol,ycol)), "No Diet Orders found.", ycol = (ycol+ 12),
    row + 1
   ENDIF
   IF (ycol > 725)
    BREAK
   ENDIF
   xcol = 30, ycol = (ycol+ 12), row + 1,
   CALL print(calcpos(xcol,ycol)), "{b}{u}Insurance:{endb}{endu}"
   IF ((pt_transfer->ins_cnt > 0))
    FOR (x = 1 TO pt_transfer->ins_cnt)
      IF (ycol > 725)
       BREAK
      ENDIF
      xcol = 100, row + 1,
      CALL print(calcpos(xcol,ycol)),
      "Type: ", "{b}", pt_transfer->ins_qual[x].type,
      "{endb}", ycol = (ycol+ 12), row + 1,
      xcol = 100, row + 1,
      CALL print(calcpos(xcol,ycol)),
      "Name: ", pt_transfer->ins_qual[x].name, ycol = (ycol+ 12),
      row + 1, xcol = 100, row + 1,
      CALL print(calcpos(xcol,ycol)), "Subscriber: ", pt_transfer->ins_qual[x].subscriber,
      ycol = (ycol+ 12), row + 1
      IF ((pt_transfer->ins_qual[x].group_nbr > " "))
       xcol = 100, row + 1,
       CALL print(calcpos(xcol,ycol)),
       "Group #: ", pt_transfer->ins_qual[x].group_nbr, ycol = (ycol+ 12),
       row + 1
      ENDIF
      IF ((pt_transfer->ins_qual[x].member_nbr > " "))
       xcol = 100, row + 1,
       CALL print(calcpos(xcol,ycol)),
       "Member #: ", pt_transfer->ins_qual[x].member_nbr, ycol = (ycol+ 12),
       row + 1
      ENDIF
    ENDFOR
   ELSE
    xcol = 100, row + 1,
    CALL print(calcpos(xcol,ycol)),
    "No insurance information found on visit.", ycol = (ycol+ 12), row + 1
   ENDIF
   IF (ycol > 725)
    BREAK
   ENDIF
   output_display = "", output_display1 = "", output_display2 = "",
   xcol = 30, ycol = (ycol+ 12), row + 1,
   CALL print(calcpos(xcol,ycol)), "{b}{u}Contacts:{endb}{endu}"
   IF ((pt_transfer->cont_cnt > 0))
    FOR (x = 1 TO pt_transfer->cont_cnt)
      IF (ycol > 725)
       BREAK
      ENDIF
      xcol = 100, row + 1,
      CALL print(calcpos(xcol,ycol)),
      "Relation: ", "{b}", pt_transfer->cont_qual[x].relation,
      "{endb}", ycol = (ycol+ 12), row + 1,
      xcol = 100, row + 1,
      CALL print(calcpos(xcol,ycol)),
      "Name: ", pt_transfer->cont_qual[x].name, ycol = (ycol+ 12),
      row + 1
      FOR (y = 1 TO pt_transfer->cont_qual[x].phone_cnt)
       IF (ycol > 725)
        BREAK
       ENDIF
       ,
       IF ((pt_transfer->cont_qual[x].phone_qual[y].home_phone > " "))
        xcol = 100, row + 1,
        CALL print(calcpos(xcol,ycol)),
        "Home Phone: ", pt_transfer->cont_qual[x].phone_qual[y].home_phone, ycol = (ycol+ 12),
        row + 1
       ELSEIF ((pt_transfer->cont_qual[x].phone_qual[y].bus_phone > " "))
        xcol = 100, row + 1,
        CALL print(calcpos(xcol,ycol)),
        "Bus Phone: ", pt_transfer->cont_qual[x].phone_qual[y].bus_phone, ycol = (ycol+ 12),
        row + 1
        IF ((pt_transfer->cont_qual[x].phone_qual[y].ext > " "))
         output_display = build(pt_transfer->cont_qual[x].phone_qual[y].bus_phone,pt_transfer->
          cont_qual[x].phone_qual[y].ext)
        ELSE
         output_display = pt_transfer->cont_qual[x].phone_qual[y].bus_phone
        ENDIF
       ENDIF
      ENDFOR
    ENDFOR
   ELSE
    xcol = 100, row + 1,
    CALL print(calcpos(xcol,ycol)),
    "No Contact information found on visit.", ycol = (ycol+ 12), row + 1
   ENDIF
   output_display = "", output_display1 = "", output_display2 = ""
   IF (ycol > 725)
    BREAK
   ENDIF
   xcol = 30, ycol = (ycol+ 12), row + 1,
   CALL print(calcpos(xcol,ycol)), "{b}{u}Problems:{endb}{endu}"
   IF ((pt_transfer->problem_cnt > 0))
    FOR (x = 1 TO pt_transfer->problem_cnt)
      IF (ycol > 725)
       BREAK
      ENDIF
      output_display = concat(pt_transfer->problem[x].onset_date,"  ",trim(pt_transfer->problem[x].
        name,3))
      IF (textlen(trim(output_display,3)) > 70)
       tempstring = trim(output_display,3), xcol = 100, wrapcol = 70,
       line_wrap
      ELSEIF (textlen(trim(output_display,3)) > 0)
       xcol = 100, row + 1,
       CALL print(calcpos(xcol,ycol)),
       output_display, ycol = (ycol+ 12), row + 1
      ENDIF
      FOR (y = 1 TO pt_transfer->problem[x].comment_cnt)
        IF (ycol > 725)
         BREAK
        ENDIF
        IF (size(trim(pt_transfer->problem[x].comments[y].comment,3)) > 0)
         output_display = concat("Comments: ",pt_transfer->problem[x].comments[y].date," ",trim(
           pt_transfer->problem[x].comments[y].comment,3)), output_display = replace(output_display,
          char(13)," ",0)
        ENDIF
        IF (textlen(trim(output_display,3)) > 68)
         tempstring = trim(output_display,3), xcol = 110, wrapcol = 68,
         line_wrap
        ELSEIF (textlen(trim(output_display,3)) > 0)
         IF (ycol > 725)
          BREAK
         ENDIF
         xcol = 110, row + 1,
         CALL print(calcpos(xcol,ycol)),
         output_display, ycol = (ycol+ 12), row + 1
        ENDIF
      ENDFOR
    ENDFOR
   ELSE
    xcol = 100, row + 1,
    CALL print(calcpos(xcol,ycol)),
    "No Problem Assessment found.", ycol = (ycol+ 12)
   ENDIF
   found = 0
   FOR (x = 1 TO pt_transfer->blob_cnt)
     FOR (y = 1 TO pt_transfer->blob_qual[x].blobs_cnt)
       IF ((pt_transfer->blob_qual[x].blob_set_name="Discharge/Transfer Note"))
        blob_set_name = "Discharge/Transfer Note", found = 1
        IF (found=0)
         ycol = (ycol+ 12), row + 1, xcol = 30,
         row + 1,
         CALL print(calcpos(xcol,ycol)), "{f/0}{cpi/14}{b}{u}",
         blob_set_name, ":", "{endb}{endu}"
        ENDIF
        found = 1
        IF ((pt_transfer->blob_qual[x].blobs_qual[y].event_title_text != "Addendum by*"))
         ycol = (ycol+ 12), row + 1, xcol = 30,
         row + 1,
         CALL print(calcpos(xcol,ycol)), "Note Type: ",
         pt_transfer->blob_qual[x].blob_event_cd, ycol = (ycol+ 12), row + 1,
         xcol = 30, row + 1,
         CALL print(calcpos(xcol,ycol)),
         "Note Date: ", pt_transfer->blob_qual[x].blob_date, ycol = (ycol+ 12),
         row + 1
        ENDIF
        IF (size(pt_transfer->blob_qual[x].blobs_qual[y].blob_contents) > 0)
         FOR (z = 1 TO blob_disp->blob_cnt)
           IF ((blob_disp->qual[z].event_id=pt_transfer->blob_qual[x].blobs_qual[y].event_id))
            FOR (zz = 1 TO size(blob_disp->qual[z].line,5))
              IF (ycol > 725)
               BREAK
              ENDIF
              output_display = fillstring(100,""), output_display = trim(blob_disp->qual[z].line[zz].
               disp,3), xcol = 50,
              row + 1,
              CALL print(calcpos(xcol,ycol)), output_display,
              ycol = (ycol+ 12)
            ENDFOR
           ENDIF
         ENDFOR
        ENDIF
       ENDIF
     ENDFOR
   ENDFOR
   found = 0
   FOR (x = 1 TO pt_transfer->blob_cnt)
     FOR (y = 1 TO pt_transfer->blob_qual[x].blobs_cnt)
       IF ((pt_transfer->blob_qual[x].blob_set_name="Discharge Summary - Dictated"))
        blob_set_name = "Discharge Summary - Dictated", found = 1
        IF (found=0)
         ycol = (ycol+ 12), row + 1, xcol = 30,
         row + 1,
         CALL print(calcpos(xcol,ycol)), "{f/0}{cpi/14}{b}{u}",
         blob_set_name, ":", "{endb}{endu}"
        ENDIF
        found = 1
        IF ((pt_transfer->blob_qual[x].blobs_qual[y].event_title_text != "Addendum by*"))
         ycol = (ycol+ 12), row + 1, xcol = 30,
         row + 1,
         CALL print(calcpos(xcol,ycol)), "Note Type: ",
         pt_transfer->blob_qual[x].blob_event_cd, ycol = (ycol+ 12), row + 1,
         xcol = 30, row + 1,
         CALL print(calcpos(xcol,ycol)),
         "Note Date: ", pt_transfer->blob_qual[x].blob_date, ycol = (ycol+ 12),
         row + 1
        ENDIF
        IF (size(pt_transfer->blob_qual[x].blobs_qual[y].blob_contents) > 0)
         FOR (z = 1 TO blob_disp->blob_cnt)
           IF ((blob_disp->qual[z].event_id=pt_transfer->blob_qual[x].blobs_qual[y].event_id))
            FOR (zz = 1 TO size(blob_disp->qual[z].line,5))
              IF (ycol > 725)
               BREAK
              ENDIF
              output_display = fillstring(100,""), output_display = trim(blob_disp->qual[z].line[zz].
               disp,3), xcol = 50,
              row + 1,
              CALL print(calcpos(xcol,ycol)), output_display,
              ycol = (ycol+ 12)
            ENDFOR
           ENDIF
         ENDFOR
        ENDIF
       ENDIF
     ENDFOR
   ENDFOR
   IF (found=0)
    ycol = (ycol+ 12), row + 1, xcol = 30,
    CALL print(calcpos(xcol,ycol)),
    "{f/0}{cpi/14}{b}No Discharge Summary - Dictated documents found on visit.{endb}", ycol = (ycol+
    12),
    row + 1
   ENDIF
   found = 0
   FOR (x = 1 TO pt_transfer->blob_cnt)
     FOR (y = 1 TO pt_transfer->blob_qual[x].blobs_cnt)
       IF ((pt_transfer->blob_qual[x].blob_set_name="Discharge Summary - Converted"))
        blob_set_name = pt_transfer->blob_qual[x].blob_set_name
        IF (found=0)
         ycol = (ycol+ 12), row + 1, xcol = 30,
         row + 1,
         CALL print(calcpos(xcol,ycol)), "{f/0}{cpi/14}{b}{u}",
         blob_set_name, ":", "{endb}{endu}"
        ENDIF
        found = 1
        IF ((pt_transfer->blob_qual[x].blobs_qual[y].event_title_text != "Addendum by*"))
         ycol = (ycol+ 12), row + 1, xcol = 30,
         row + 1,
         CALL print(calcpos(xcol,ycol)), "Note Type: ",
         pt_transfer->blob_qual[x].blob_event_cd, ycol = (ycol+ 12), row + 1,
         xcol = 30, row + 1,
         CALL print(calcpos(xcol,ycol)),
         "Note Date: ", pt_transfer->blob_qual[x].blob_date, ycol = (ycol+ 12),
         row + 1
        ENDIF
        IF (size(pt_transfer->blob_qual[x].blobs_qual[y].blob_contents) > 0)
         FOR (z = 1 TO blob_disp->blob_cnt)
           IF ((blob_disp->qual[z].event_id=pt_transfer->blob_qual[x].blobs_qual[y].event_id))
            FOR (zz = 1 TO blob_disp->qual[z].line_cnt)
              IF (ycol > 725)
               BREAK
              ENDIF
              output_display = fillstring(100,""), output_display = trim(blob_disp->qual[z].line[zz].
               disp,3), xcol = 50,
              row + 1,
              CALL print(calcpos(xcol,ycol)), output_display,
              ycol = (ycol+ 12)
            ENDFOR
           ENDIF
         ENDFOR
        ENDIF
       ENDIF
     ENDFOR
   ENDFOR
   found = 0
   FOR (x = 1 TO pt_transfer->blob_cnt)
     FOR (y = 1 TO pt_transfer->blob_qual[x].blobs_cnt)
       IF ((pt_transfer->blob_qual[x].blob_set_name="Transfer Summary - Dictated"))
        blob_set_name = pt_transfer->blob_qual[x].blob_set_name
        IF (found=0)
         ycol = (ycol+ 12), row + 1, xcol = 30,
         row + 1,
         CALL print(calcpos(xcol,ycol)), "{f/0}{cpi/14}{b}{u}",
         blob_set_name, ":", "{endb}{endu}"
        ENDIF
        found = 1
        IF ((pt_transfer->blob_qual[x].blobs_qual[y].event_title_text != "Addendum by*"))
         ycol = (ycol+ 12), row + 1, xcol = 30,
         row + 1,
         CALL print(calcpos(xcol,ycol)), "Note Type: ",
         pt_transfer->blob_qual[x].blob_event_cd, ycol = (ycol+ 12), row + 1,
         xcol = 30, row + 1,
         CALL print(calcpos(xcol,ycol)),
         "Note Date: ", pt_transfer->blob_qual[x].blob_date, ycol = (ycol+ 12),
         row + 1
        ENDIF
        IF (size(pt_transfer->blob_qual[x].blobs_qual[y].blob_contents) > 0)
         FOR (z = 1 TO blob_disp->blob_cnt)
           IF ((blob_disp->qual[z].event_id=pt_transfer->blob_qual[x].blobs_qual[y].event_id))
            FOR (zz = 1 TO blob_disp->qual[z].line_cnt)
              IF (ycol > 725)
               BREAK
              ENDIF
              output_display = fillstring(100,""), output_display = trim(blob_disp->qual[z].line[zz].
               disp,3), xcol = 50,
              row + 1,
              CALL print(calcpos(xcol,ycol)), output_display,
              ycol = (ycol+ 12)
            ENDFOR
           ENDIF
         ENDFOR
        ENDIF
       ENDIF
     ENDFOR
   ENDFOR
   IF (found=0)
    ycol = (ycol+ 12), row + 1, xcol = 30,
    CALL print(calcpos(xcol,ycol)),
    "{f/0}{cpi/14}{b}No Physician Discharge or Transfer Summary documents found on visit.{endb}",
    ycol = (ycol+ 12),
    row + 1
   ENDIF
   found = 0
   FOR (x = 1 TO pt_transfer->blob_cnt)
     FOR (y = 1 TO pt_transfer->blob_qual[x].blobs_cnt)
       IF ((pt_transfer->blob_qual[x].blob_set_name="Nursing Discharge Status Report"))
        blob_set_name = pt_transfer->blob_qual[x].blob_set_name
        IF (found=0)
         ycol = (ycol+ 12), row + 1, xcol = 30,
         row + 1,
         CALL print(calcpos(xcol,ycol)), "{f/0}{cpi/14}{b}{u}",
         blob_set_name, ":", "{endb}{endu}"
        ENDIF
        found = 1
        IF ((pt_transfer->blob_qual[x].blobs_qual[y].event_title_text != "Addendum by*"))
         ycol = (ycol+ 12), row + 1, xcol = 30,
         row + 1,
         CALL print(calcpos(xcol,ycol)), "Note Type: ",
         pt_transfer->blob_qual[x].blob_event_cd, ycol = (ycol+ 12), row + 1,
         xcol = 30, row + 1,
         CALL print(calcpos(xcol,ycol)),
         "Note Date: ", pt_transfer->blob_qual[x].blob_date, ycol = (ycol+ 12),
         row + 1
        ENDIF
        IF (size(pt_transfer->blob_qual[x].blobs_qual[y].blob_contents) > 0)
         FOR (z = 1 TO blob_disp->blob_cnt)
           IF ((blob_disp->qual[z].event_id=pt_transfer->blob_qual[x].blobs_qual[y].event_id))
            FOR (zz = 1 TO blob_disp->qual[z].line_cnt)
              IF (ycol > 725)
               BREAK
              ENDIF
              output_display = fillstring(100,""), output_display = trim(blob_disp->qual[z].line[zz].
               disp,3), xcol = 50,
              row + 1,
              CALL print(calcpos(xcol,ycol)), output_display,
              ycol = (ycol+ 12)
            ENDFOR
           ENDIF
         ENDFOR
        ENDIF
       ENDIF
     ENDFOR
   ENDFOR
   IF (found=0)
    ycol = (ycol+ 12), row + 1, xcol = 30,
    CALL print(calcpos(xcol,ycol)),
    "{f/0}{cpi/14}{b}No Nursing Discharge Status Report documents found on visit.{endb}", ycol = (
    ycol+ 12),
    row + 1
   ENDIF
   IF (ycol > 725)
    BREAK
   ENDIF
   xcol = 30, ycol = (ycol+ 12), row + 1,
   CALL print(calcpos(xcol,ycol)),
   "{b}If no Discharge meds are noted in the Physician Discharge Summary, Discharge Summary - Dictated, or Nursing",
   ycol = (ycol+ 12),
   row + 1, xcol = 30, row + 1,
   CALL print(calcpos(xcol,ycol)),
   "{b}Discharge Status Report, please contact facility for appropriate transfer meds.  Meds below are from the",
   ycol = (ycol+ 12),
   row + 1, xcol = 30, row + 1,
   CALL print(calcpos(xcol,ycol)), "{b}Patient's Inpatient Stay.{endb}", ycol = (ycol+ 12),
   row + 1
   IF (ycol > 725)
    BREAK
   ENDIF
   print_title = 0, meds_found = 0
   IF (ycol > 725)
    BREAK
   ENDIF
   IF (size(continuous_orders_disp->continuous_orders,5) > 0)
    FOR (z1 = 1 TO size(continuous_orders_disp->continuous_orders,5))
      IF ((continuous_orders_disp->continuous_orders[z1].action_type="Ordered"))
       IF (ycol > 725)
        BREAK
       ENDIF
       meds_found = 1
       IF (print_title=0)
        xcol = 30, ycol = (ycol+ 12)
        IF ((pt_transfer->disch_date > 0))
         title = build("{b}{u}Current IV Infusions immediately before Discharge:{endb}{endu}")
        ELSE
         title = build("{b}{u}Current IV Infusions:{endb}{endu}")
        ENDIF
        CALL print(calcpos(xcol,ycol)), title, row + 1,
        ycol = (ycol+ 12), print_title = 1, xcol = 50
       ENDIF
       xcol = 50, line1 = fillstring(100,""), line1 = concat("{b}Medication: ",continuous_orders_disp
        ->continuous_orders[z1].ordered_as_mnemonic),
       comment_string = build(continuous_orders_disp->continuous_orders[z1].comment)
       FOR (z2 = 1 TO 1)
         IF (trim(continuous_orders_disp->continuous_orders[z1].action_type)="Ordered")
          IF (ycol > 725)
           BREAK
          ENDIF
          xcol = 50,
          CALL print(calcpos(50,ycol)), line1,
          row + 1, ycol = (ycol+ 12), tempstring =
          IF (size(continuous_orders_disp->continuous_orders[z1].stop_dt) > 0) concat(
            "Order Detail :",continuous_orders_disp->continuous_orders[z1].core_actions[z2].
            clinical_display_line,", Projected Stop date ",format(continuous_orders_disp->
             continuous_orders[z1].stop_dt,"mm/dd/yy hh:mm;;q"))
          ELSE concat("Order Detail :",continuous_orders_disp->continuous_orders[z1].core_actions[z2]
            .clinical_display_line)
          ENDIF
          ,
          wrapcol = 100, line_wrap
          IF (comment_string > "")
           comment_string = replace(comment_string,char(13)," ",0), tempstring = concat("Comment: ",
            comment_string), line_wrap2
          ENDIF
         ENDIF
       ENDFOR
       FOR (z3 = 1 TO 1)
         IF (ycol > 725)
          BREAK
         ENDIF
         xcol = 50,
         CALL print(calcpos(50,ycol)), "{b}Current Last Dose Given",
         row + 1, ycol = (ycol+ 12), xcol = 50
         IF (trim(continuous_orders_disp->continuous_orders[z1].admins[z3].event_title_text)=
         "IVPARENT")
          med_date = continuous_orders_disp->continuous_orders[z1].admins[z3].admin_start_dt_tm,
          med_date_disp = format(med_date,"mm/dd/yyyy hh:mm;;Q"), dose = fillstring(30,""),
          dose = format(continuous_orders_disp->continuous_orders[z1].admins[z3].initial_volume,
           "#######.##;l"), dose_unit = trim(continuous_orders_disp->continuous_orders[z1].admins[z3]
           .dosage_unit), rate = format(continuous_orders_disp->continuous_orders[z1].admins[z3].
           infusion_rate,"#######.##;l"),
          rate_unit = trim(continuous_orders_disp->continuous_orders[z1].admins[z3].infusion_unit),
          event = build(med_date_disp,"->",dose,dose_unit,";",
           rate,",",rate_unit),
          CALL print(calcpos(50,ycol)),
          event, row + 1, ycol = (ycol+ 12)
         ENDIF
       ENDFOR
       ycol = (ycol+ 12)
      ENDIF
    ENDFOR
   ENDIF
   IF (size(continuous_orders->qual,5) > 0)
    FOR (con = 1 TO size(continuous_orders->qual,5))
      IF (ycol > 725)
       BREAK
      ENDIF
      xcol = 50
      IF ((continuous_orders->qual[con].print_ind=0)
       AND  NOT ((continuous_orders->qual[con].action_type IN ("Discontinued", "Completed"))))
       meds_found = 1
       IF (print_title=0)
        xcol = 30, ycol = (ycol+ 12)
        IF ((pt_transfer->disch_date > 0))
         title = build("{b}{u}Current IV Infusions immediately before Discharge:{endb}{endu}")
        ELSE
         title = build("{b}{u}Current IV Infusions:{endb}{endu}")
        ENDIF
        CALL print(calcpos(xcol,ycol)), title, row + 1,
        ycol = (ycol+ 12), print_title = 1, xcol = 50
       ENDIF
       tempstring =
       IF (size(continuous_orders->qual[con].stop_dt) > 0) concat("{b}",continuous_orders->qual[con].
         order_name,"{endb}: ",continuous_orders->qual[con].order_detail,", Projected Stop date ",
         format(continuous_orders->qual[con].stop_dt,"mm/dd/yy hh:mm;;q"))
       ELSE concat("{b}",continuous_orders->qual[con].order_name,"{endb}: ",continuous_orders->qual[
         con].order_detail)
       ENDIF
       , wrapcol = 100, line_wrap,
       comment_string = build(continuous_orders->qual[con].comment)
       IF (comment_string > "")
        comment_string = replace(comment_string,char(13)," ",0), tempstring = concat("Comment: ",
         comment_string), line_wrap2
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   IF (meds_found=0)
    IF (ycol > 725)
     BREAK
    ENDIF
    xcol = 30, ycol = (ycol+ 12)
    IF ((pt_transfer->disch_date > 0))
     title = build(
      "{b}{u}Current IV Infusions immediately before Discharge:{endb}{endu} None found on visit.")
    ELSE
     title = build("{b}{u}Current IV Infusions:{endb}{endu}  None found on visit.")
    ENDIF
    CALL print(calcpos(xcol,ycol)), title, row + 1,
    ycol = (ycol+ 12)
   ENDIF
   IF (ycol > 725)
    BREAK
   ENDIF
   print_title = 0, meds_found = 0
   IF (size(scheduled_orders->qual,5) > 0)
    FOR (z1 = 1 TO size(scheduled_orders->qual,5))
      IF (ycol > 725)
       BREAK
      ENDIF
      line1 = fillstring(100,""), comment_string = fillstring(122,""), line1 = concat(
       "{b}Medication: ",scheduled_orders->qual[z1].order_name)
      FOR (z2 = 1 TO size(scheduled_orders_disp->scheduled_orders,5))
        IF ((scheduled_orders->qual[z1].order_id=scheduled_orders_disp->scheduled_orders[z2].
        template_order_id)
         AND (scheduled_orders_disp->scheduled_orders[z2].action_type="Ordered"))
         scheduled_orders->qual[z1].print_ind = 1, meds_found = 1
         IF (print_title=0)
          xcol = 30, ycol = (ycol+ 12), row + 1
          IF ((pt_transfer->disch_date > 0))
           title = build("{b}{u}Current Scheduled Meds immediately before Discharge:{endb}{endu}")
          ELSE
           title = build("{b}{u}Current Scheduled Meds:{endb}{endu}")
          ENDIF
          CALL print(calcpos(xcol,ycol)), "{b}", title,
          row + 1, ycol = (ycol+ 12), print_title = 1,
          xcol = 50
         ENDIF
         IF (ycol > 725)
          BREAK
         ENDIF
         xcol = 50,
         CALL print(calcpos(50,ycol)), line1,
         row + 1, ycol = (ycol+ 12), tempstring =
         IF (size(scheduled_orders_disp->scheduled_orders[z2].stop_dt) > 0) concat("Order Detail: ",
           trim(scheduled_orders_disp->scheduled_orders[z2].core_actions[1].clinical_display_line,3),
           ", Projected Stop date: ",format(scheduled_orders_disp->scheduled_orders[z2].stop_dt,
            "mm/dd/yy hh:mm;;q"))
         ELSE concat("Order Detail :",trim(scheduled_orders_disp->scheduled_orders[z2].core_actions[1
            ].clinical_display_line,3))
         ENDIF
         ,
         xcol = 50, wrapcol = 100, line_wrap
         IF (size(scheduled_orders->qual[z1].comment,5) > 0)
          FOR (comment = 1 TO size(scheduled_orders->qual[z1].comment,5))
            tempstring = build(scheduled_orders->qual[z1].comment[comment].comment), xcol = 50,
            CALL print(calcpos(xcol,ycol)),
            tempstring, row + 1, ycol = (ycol+ 12)
          ENDFOR
         ENDIF
         IF (ycol > 725)
          BREAK
         ENDIF
         CALL print(calcpos(50,ycol)), "{b}Current Last Dose Given", row + 1,
         xcol = (xcol+ 250),
         CALL print(calcpos(300,ycol)), "{b}Next Dose Due ",
         row + 1, ycol = (ycol+ 12), xcol = 50
         IF (ycol > 725)
          BREAK
         ENDIF
         med_date = scheduled_orders_disp->scheduled_orders[z2].admins[1].event_end_dt_tm,
         med_date_disp = format(med_date,"mm/dd/yyyy hh:mm;;Q"), dose = fillstring(30,""),
         dose = format(scheduled_orders_disp->scheduled_orders[z2].admins[1].dosage_value,
          "#######.##;l"), event1 = build(med_date_disp,"/",dose,scheduled_orders_disp->
          scheduled_orders[z2].admins[1].dosage_unit), event2 = fillstring(40,""),
         event2 = format(scheduled_orders->qual[z1].child_ord[1].start_dt,"mm/dd/yy hh:mm;;q"),
         CALL print(calcpos(50,ycol)), event1,
         row + 1,
         CALL print(calcpos(300,ycol)), event2,
         row + 1, ycol = (ycol+ 12)
        ENDIF
      ENDFOR
      IF ((scheduled_orders->qual[z1].print_ind=1))
       ycol = (ycol+ 12)
      ENDIF
    ENDFOR
   ENDIF
   IF (ycol > 725)
    BREAK
   ENDIF
   IF (size(scheduled_orders->qual,5) > 0)
    FOR (sch = 1 TO size(scheduled_orders->qual,5))
      IF (ycol > 725)
       BREAK
      ENDIF
      xcol = 50
      IF ((scheduled_orders->qual[sch].print_ind=0)
       AND  NOT ((scheduled_orders->qual[sch].action_type IN ("Discontinued", "Completed"))))
       meds_found = 1
       IF (print_title=0)
        xcol = 30, ycol = (ycol+ 12), row + 1
        IF ((pt_transfer->disch_date > 0))
         title = build("{b}{u}Current Scheduled Meds immediately before Discharge:{endb}{endu}")
        ELSE
         title = build("{b}{u}Current Scheduled Meds:{endb}{endu}")
        ENDIF
        CALL print(calcpos(xcol,ycol)), "{b}", title,
        row + 1, ycol = (ycol+ 12), print_title = 1,
        xcol = 50
       ENDIF
       tempstring =
       IF (size(scheduled_orders->qual[sch].stop_dt) > 0) concat("{b}",scheduled_orders->qual[sch].
         order_name,"{endb}: ",scheduled_orders->qual[sch].order_detail,", Projected Stop date ",
         format(scheduled_orders->qual[sch].stop_dt,"mm/dd/yy hh:mm;;q"))
       ELSE concat("{b}",scheduled_orders->qual[sch].order_name,"{endb}: ",scheduled_orders->qual[sch
         ].order_detail)
       ENDIF
       , wrapcol = 100, line_wrap
       IF (size(scheduled_orders->qual[sch].comment,5) > 0)
        FOR (comment = 1 TO size(scheduled_orders->qual[sch].comment,5))
          tempstring = build(scheduled_orders->qual[sch].comment[comment].comment), xcol = 50,
          CALL print(calcpos(xcol,ycol)),
          tempstring, row + 1, ycol = (ycol+ 12)
        ENDFOR
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   IF (meds_found=0)
    IF (ycol > 725)
     BREAK
    ENDIF
    xcol = 30, ycol = (ycol+ 12)
    IF ((pt_transfer->disch_date > 0))
     title = build(
      "{b}{u}Current Scheduled Meds immediately before Discharge:{endb}{endu} None found on visit.")
    ELSE
     title = build("{b}{u}Current Scheduled Meds:{endb}{endu} None found on visit.")
    ENDIF
    CALL print(calcpos(xcol,ycol)), title, row + 1,
    ycol = (ycol+ 12)
   ENDIF
   IF (ycol > 725)
    BREAK
   ENDIF
   print_title = 0, meds_found = 0
   IF (size(scheduled_orders->qual,5) > 0)
    FOR (z1 = 1 TO size(scheduled_orders->qual,5))
      IF (ycol > 725)
       BREAK
      ENDIF
      line1 = fillstring(100,""), comment_string = fillstring(122,""), line1 = concat(
       "{b}Medication: ",scheduled_orders->qual[z1].order_name)
      FOR (z2 = 1 TO size(scheduled_orders_disp->scheduled_orders,5))
        IF ((scheduled_orders->qual[z1].order_id=scheduled_orders_disp->scheduled_orders[z2].
        template_order_id)
         AND (scheduled_orders_disp->scheduled_orders[z2].action_type IN ("Completed", "Discontinued"
        )))
         scheduled_orders->qual[z1].print_ind = 2, meds_found = 1
         IF (print_title=0)
          xcol = 30, ycol = (ycol+ 12), row + 1
          IF ((pt_transfer->disch_date > 0))
           title = build("{b}{u}",
            "Discontinued or Completed Scheduled Meds in last 7 days immediately before Discharge:{endb}{endu}"
            )
          ELSE
           title = build("{b}{u}Discontinued or Completed Scheduled Meds in last 7 days:{endb}{endu}"
            )
          ENDIF
          CALL print(calcpos(xcol,ycol)), "{b}", title,
          row + 1, ycol = (ycol+ 12), print_title = 1,
          xcol = 50
         ENDIF
         IF (ycol > 725)
          BREAK
         ENDIF
         CALL print(calcpos(50,ycol)), line1, row + 1,
         ycol = (ycol+ 12), tempstring =
         IF (size(scheduled_orders_disp->scheduled_orders[z2].stop_dt) > 0) concat("Order Detail :",
           scheduled_orders_disp->scheduled_orders[z2].core_actions[1].clinical_display_line,
           ", Projected Stop date ",format(scheduled_orders_disp->scheduled_orders[z2].stop_dt,
            "mm/dd/yy hh:mm;;q"))
         ELSE concat("Order Detail :",scheduled_orders_disp->scheduled_orders[z2].core_actions[1].
           clinical_display_line)
         ENDIF
         , xcol = 50,
         wrapcol = 100, line_wrap
         IF (size(scheduled_orders->qual[z1].comment,5) > 0)
          FOR (comment = 1 TO size(scheduled_orders->qual[z1].comment,5))
            tempstring = build(scheduled_orders->qual[z1].comment[comment].comment), xcol = 50,
            CALL print(calcpos(xcol,ycol)),
            tempstring, row + 1, ycol = (ycol+ 12)
          ENDFOR
         ENDIF
         IF (ycol > 725)
          BREAK
         ENDIF
         CALL print(calcpos(50,ycol)), "{b}Current Last Dose Given", row + 1,
         ycol = (ycol+ 12), xcol = 50
         IF (ycol > 725)
          BREAK
         ENDIF
         med_date = scheduled_orders_disp->scheduled_orders[z2].admins[1].event_end_dt_tm,
         med_date_disp = format(med_date,"mm/dd/yyyy hh:mm;;Q"), dose = fillstring(30,""),
         dose = format(scheduled_orders_disp->scheduled_orders[z2].admins[1].dosage_value,
          "#######.##;l"), event1 = build(med_date_disp,"/",dose,scheduled_orders_disp->
          scheduled_orders[z2].admins[1].dosage_unit),
         CALL print(calcpos(50,ycol)),
         event1, row + 1, ycol = (ycol+ 12)
        ENDIF
      ENDFOR
      IF ((scheduled_orders->qual[z1].print_ind=2))
       ycol = (ycol+ 12)
      ENDIF
    ENDFOR
   ENDIF
   IF (ycol > 725)
    BREAK
   ENDIF
   IF (size(scheduled_orders->qual,5) > 0)
    FOR (sch = 1 TO size(scheduled_orders->qual,5))
      IF (ycol > 725)
       BREAK
      ENDIF
      xcol = 50
      IF ((scheduled_orders->qual[sch].print_ind=0)
       AND (scheduled_orders->qual[sch].action_type != "Ordered"))
       meds_found = 1
       IF (print_title=0)
        xcol = 30, ycol = (ycol+ 12), row + 1
        IF ((pt_transfer->disch_date > 0))
         title = build(
          "{b}{u}Discontinued or Completed Scheduled Meds in last 7 days immediately before Discharge:{endb}{endu}"
          )
        ELSE
         title = build("{b}{u}Discontinued or Completed Scheduled Meds in last 7 days:{endb}{endu}")
        ENDIF
        CALL print(calcpos(xcol,ycol)), "{b}", title,
        row + 1, ycol = (ycol+ 12), print_title = 1,
        xcol = 50
       ENDIF
       tempstring =
       IF (size(scheduled_orders->qual[sch].stop_dt) > 0) concat("{b}",scheduled_orders->qual[sch].
         order_name,"{endb}: ",scheduled_orders->qual[sch].order_detail,", Projected Stop date ",
         format(scheduled_orders->qual[sch].stop_dt,"mm/dd/yy hh:mm;;q"))
       ELSE concat("{b}",scheduled_orders->qual[sch].order_name,"{endb}: ",scheduled_orders->qual[sch
         ].order_detail)
       ENDIF
       , wrapcol = 100, line_wrap
       IF (size(scheduled_orders->qual[sch].comment,5) > 0)
        FOR (comment = 1 TO size(scheduled_orders->qual[sch].comment,5))
          tempstring = build(scheduled_orders->qual[sch].comment[comment].comment), xcol = 50,
          CALL print(calcpos(xcol,ycol)),
          tempstring, row + 1, ycol = (ycol+ 12)
        ENDFOR
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   IF (meds_found=0)
    IF (ycol > 725)
     BREAK
    ENDIF
    xcol = 30, ycol = (ycol+ 12)
    IF ((pt_transfer->disch_date > 0))
     title = build(
      "{b}{u}Discontinued or Completed Scheduled Meds in last 7 days immediately before Discharge:{endb}{endu}"
      ), title = build(title," None found in last 7 days.")
    ELSE
     title = build("{b}{u}Discontinued or Completed Scheduled Meds in last 7 days:{endb}{endu}"),
     title = build(title," None found in last 7 days.")
    ENDIF
    CALL print(calcpos(xcol,ycol)), title, row + 1,
    ycol = (ycol+ 12)
   ENDIF
   IF (ycol > 725)
    BREAK
   ENDIF
   print_title = 0, meds_found = 0
   IF (ycol > 725)
    BREAK
   ENDIF
   IF (size(prn_orders_disp->prn_orders,5) > 0)
    FOR (z1 = 1 TO size(prn_orders_disp->prn_orders,5))
      IF ((prn_orders_disp->prn_orders[z1].action_type="Ordered"))
       IF (ycol > 725)
        BREAK
       ENDIF
       IF (print_title=0)
        xcol = 30, ycol = (ycol+ 12)
        IF ((pt_transfer->disch_date > 0))
         title = build("{b}{u}Current PRN Meds immediately before Discharge:{endb}{endu}")
        ELSE
         title = build("{b}{u}Current PRN Meds:{endb}{endu}")
        ENDIF
        CALL print(calcpos(xcol,ycol)), "{b}", title,
        row + 1, ycol = (ycol+ 12), print_title = 1,
        xcol = 50
       ENDIF
       line1 = fillstring(100,""), line1 = concat("{b}Medication: ",prn_orders_disp->prn_orders[z1].
        ordered_as_mnemonic), comment_string = build(prn_orders_disp->prn_orders[z1].comment)
       FOR (z2 = 1 TO 1)
         IF (trim(prn_orders_disp->prn_orders[z1].action_type)="Ordered")
          meds_found = 1, print_ind = 1
          IF (ycol > 725)
           BREAK
          ENDIF
          xcol = 50,
          CALL print(calcpos(50,ycol)), line1,
          row + 1, ycol = (ycol+ 12), tempstring =
          IF (size(prn_orders_disp->prn_orders[z1].stop_dt) > 0) concat("Order Detail :",
            prn_orders_disp->prn_orders[z1].core_actions[z2].clinical_display_line,
            ", Projected Stop date ",format(prn_orders_disp->prn_orders[z1].stop_dt,
             "mm/dd/yy hh:mm;;q"))
          ELSE concat("Order Detail :",prn_orders_disp->prn_orders[z1].core_actions[z2].
            clinical_display_line)
          ENDIF
          ,
          wrapcol = 100, line_wrap
          IF (comment_string > "")
           comment_string = replace(comment_string,char(13)," ",0), tempstring = concat("Comment: ",
            comment_string), line_wrap2
          ENDIF
         ENDIF
       ENDFOR
       FOR (z3 = 1 TO 1)
         IF (ycol > 725)
          BREAK
         ENDIF
         xcol = 50,
         CALL print(calcpos(50,ycol)), "{b}Current Last Dose Given",
         row + 1, ycol = (ycol+ 12), xcol = 50,
         med_date = prn_orders_disp->prn_orders[z1].admins[z3].event_end_dt_tm, med_date_disp =
         format(med_date,"mm/dd/yyyy hh:mm;;Q"), dose = fillstring(30,""),
         dose = format(prn_orders_disp->prn_orders[z1].admins[z3].dosage_value,"#######.##;l"), event
          = build(med_date_disp,"->",dose,prn_orders_disp->prn_orders[z1].admins[z3].dosage_unit,",",
          prn_orders_disp->prn_orders[z1].admins[z3].route),
         CALL print(calcpos(50,ycol)),
         event, row + 1, ycol = (ycol+ 12)
       ENDFOR
       ycol = (ycol+ 12)
      ENDIF
    ENDFOR
   ENDIF
   IF (size(prn_orders->qual,5) > 0)
    FOR (prn = 1 TO size(prn_orders->qual,5))
      IF (ycol > 725)
       BREAK
      ENDIF
      xcol = 50
      IF ((prn_orders->qual[prn].print_ind=0)
       AND  NOT ((prn_orders->qual[prn].action_type IN ("Discontinued", "Completed"))))
       meds_found = 1
       IF (print_title=0)
        xcol = 30, ycol = (ycol+ 12)
        IF ((pt_transfer->disch_date > 0))
         title = build("{b}{u}Current PRN Meds immediately before Discharge:{endb}{endu}")
        ELSE
         title = build("{b}{u}Current PRN Meds:{endb}{endu}")
        ENDIF
        CALL print(calcpos(xcol,ycol)), "{b}", title,
        row + 1, ycol = (ycol+ 12), print_title = 1,
        xcol = 50
       ENDIF
       tempstring =
       IF (size(prn_orders->qual[prn].stop_dt) > 0) concat("{b}",prn_orders->qual[prn].order_name,
         "{endb}: ",prn_orders->qual[prn].order_detail,", Projected Stop date ",
         format(prn_orders->qual[prn].stop_dt,"mm/dd/yy hh:mm;;q"))
       ELSE concat("{b}",prn_orders->qual[prn].order_name,"{endb}: ",prn_orders->qual[prn].
         order_detail)
       ENDIF
       , wrapcol = 100, line_wrap,
       comment_string = build(prn_orders->qual[prn].comment)
       IF (comment_string > "")
        comment_string = replace(comment_string,char(13)," ",0), tempstring = concat("Comment: ",
         comment_string), line_wrap2
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   IF (meds_found=0)
    IF (ycol > 725)
     BREAK
    ENDIF
    xcol = 30, ycol = (ycol+ 12)
    IF ((pt_transfer->disch_date > 0))
     title = build(
      "{b}{u}Current PRN Meds immediately before Discharge:{endb}{endu} None found on visit.")
    ELSE
     title = build("{b}{u}Current PRN Meds:{endb}{endu} None found on visit.")
    ENDIF
    CALL print(calcpos(xcol,ycol)), title, row + 1,
    ycol = (ycol+ 12)
   ENDIF
   print_title = 0, meds_found = 0
   IF (ycol > 725)
    BREAK
   ENDIF
   IF (size(prn_orders_disp->prn_orders,5) > 0)
    FOR (z1 = 1 TO size(prn_orders_disp->prn_orders,5))
      IF (trim(prn_orders_disp->prn_orders[z1].action_type) IN ("Completed", "Discontinued"))
       IF (ycol > 725)
        BREAK
       ENDIF
       meds_found = 1
       IF (print_title=0)
        xcol = 30, ycol = (ycol+ 12)
        IF ((pt_transfer->disch_date > 0))
         title = build(
          "{b}{u}Discontinued or Completed PRN Meds in last 7 days immediately before Discharge:{endb}{endu}"
          )
        ELSE
         title = build("{b}{u}Discontinued or Completed PRN Meds in last 7 days:{endb}{endu}")
        ENDIF
        CALL print(calcpos(xcol,ycol)), "{b}", title,
        row + 1, ycol = (ycol+ 12), print_title = 1,
        xcol = 50
       ENDIF
       line1 = fillstring(100,""), line1 = concat("{b}Medication: ",prn_orders_disp->prn_orders[z1].
        ordered_as_mnemonic), comment_string = build(prn_orders_disp->prn_orders[z1].comment)
       FOR (z2 = 1 TO 1)
         IF (trim(prn_orders_disp->prn_orders[z1].action_type) IN ("Completed", "Discontinued"))
          IF (ycol > 725)
           BREAK
          ENDIF
          xcol = 50,
          CALL print(calcpos(50,ycol)), line1,
          row + 1, ycol = (ycol+ 12), tempstring =
          IF (size(prn_orders_disp->prn_orders[z1].stop_dt) > 0) concat("Order Detail :",
            prn_orders_disp->prn_orders[z1].core_actions[z2].clinical_display_line,
            ", Projected Stop date ",format(prn_orders_disp->prn_orders[z1].stop_dt,
             "mm/dd/yy hh:mm;;q"))
          ELSE concat("Order Detail :",prn_orders_disp->prn_orders[z1].core_actions[z2].
            clinical_display_line)
          ENDIF
          ,
          wrapcol = 100, line_wrap
          IF (comment_string > "")
           comment_string = replace(comment_string,char(13)," ",0), tempstring = concat("Comment: ",
            comment_string), line_wrap2
          ENDIF
         ENDIF
       ENDFOR
       FOR (z3 = 1 TO 1)
         IF (ycol > 725)
          BREAK
         ENDIF
         xcol = 50,
         CALL print(calcpos(50,ycol)), "{b}Current Last Dose Given",
         row + 1, ycol = (ycol+ 8), xcol = 50,
         med_date = prn_orders_disp->prn_orders[z1].admins[z3].event_end_dt_tm, med_date_disp =
         format(med_date,"mm/dd/yyyy hh:mm;;Q"), dose = fillstring(30,""),
         dose = format(prn_orders_disp->prn_orders[z1].admins[z3].dosage_value,"#######.##;l"), event
          = build(med_date_disp,"->",dose,prn_orders_disp->prn_orders[z1].admins[z3].dosage_unit,",",
          prn_orders_disp->prn_orders[z1].admins[z3].route),
         CALL print(calcpos(50,ycol)),
         event, row + 1, ycol = (ycol+ 8)
       ENDFOR
       ycol = (ycol+ 12)
      ENDIF
    ENDFOR
   ENDIF
   IF (size(prn_orders->qual,5) > 0)
    FOR (prn = 1 TO size(prn_orders->qual,5))
      IF (ycol > 725)
       BREAK
      ENDIF
      xcol = 50
      IF ((prn_orders->qual[prn].print_ind=0)
       AND (prn_orders->qual[prn].action_type != "Ordered"))
       meds_found = 1
       IF (print_title=0)
        xcol = 30, ycol = (ycol+ 12)
        IF ((pt_transfer->disch_date > 0))
         title = build(
          "{b}{u}Discontinued or Completed PRN Meds in last 7 days immediately before Discharge:{endb}{endu}"
          )
        ELSE
         title = build("{b}{u}Discontinued or Completed PRN Meds in last 7 days:{endb}{endu}")
        ENDIF
        CALL print(calcpos(xcol,ycol)), "{b}", title,
        row + 1, ycol = (ycol+ 12), print_title = 1,
        xcol = 50
       ENDIF
       tempstring =
       IF (size(prn_orders->qual[prn].stop_dt) > 0) concat("{b}",prn_orders->qual[prn].order_name,
         "{endb}: ",prn_orders->qual[prn].order_detail,", Projected Stop date ",
         format(prn_orders->qual[prn].stop_dt,"mm/dd/yy hh:mm;;q"))
       ELSE concat("{b}",prn_orders->qual[prn].order_name,"{endb}: ",prn_orders->qual[prn].
         order_detail)
       ENDIF
       , wrapcol = 100, line_wrap,
       comment_string = build(prn_orders->qual[prn].comment)
       IF (comment_string > "")
        comment_string = replace(comment_string,char(13)," ",0), tempstring = concat("Comment: ",
         comment_string), line_wrap2
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   IF (meds_found=0)
    IF (ycol > 725)
     BREAK
    ENDIF
    xcol = 30, ycol = (ycol+ 12)
    IF ((pt_transfer->disch_date > 0))
     title = build(
      "{b}{u}Discontinued or Completed PRN Meds in last 7 days immediately before Discharge:{endb}{endu}"
      ), title = build(title," None found in last 7 days.")
    ELSE
     title = build("{b}{u}Discontinued or Completed PRN Meds in last 7 days:{endb}{endu}"), title =
     build(title," None found in last 7 days.")
    ENDIF
    CALL print(calcpos(xcol,ycol)), title, ycol = (ycol+ 12),
    row + 1
   ENDIF
   print_title = 0, meds_found = 0
   IF (ycol > 725)
    BREAK
   ENDIF
   IF (size(continuous_orders_disp->continuous_orders,5) > 0)
    FOR (z1 = 1 TO size(continuous_orders_disp->continuous_orders,5))
      IF ((continuous_orders_disp->continuous_orders[z1].action_type IN ("Completed", "Discontinued")
      ))
       IF (ycol > 725)
        BREAK
       ENDIF
       meds_found = 1
       IF (print_title=0)
        xcol = 30, ycol = (ycol+ 12)
        IF ((pt_transfer->disch_date > 0))
         title = build(
          "{f/0}{cpi/14}{b}{u}Discontinued or Completed IV Infusions in last 7 days immediately before Discharge:{endb}{endu}"
          )
        ELSE
         title = build(
          "{f/0}{cpi/14}{b}{u}Discontinued or Completed IV Infusions in last 7 days:{endb}{endu}")
        ENDIF
        CALL print(calcpos(xcol,ycol)), title, row + 1,
        ycol = (ycol+ 12), print_title = 1, xcol = 50
       ENDIF
       xcol = 50, line1 = fillstring(100,""), line1 = concat("{b}Medication: ",continuous_orders_disp
        ->continuous_orders[z1].ordered_as_mnemonic),
       comment_string = build(continuous_orders_disp->continuous_orders[z1].comment)
       FOR (z2 = 1 TO 1)
         IF (trim(continuous_orders_disp->continuous_orders[z1].action_type) IN ("Completed",
         "Discontinued"))
          IF (ycol > 725)
           BREAK
          ENDIF
          CALL print(calcpos(50,ycol)), line1, row + 1,
          ycol = (ycol+ 12), xcol = 50, tempstring =
          IF (size(continuous_orders_disp->continuous_orders[z1].stop_dt) > 0) concat(
            "Order Detail :",continuous_orders_disp->continuous_orders[z1].core_actions[z2].
            clinical_display_line,", Projected Stop date ",format(continuous_orders_disp->
             continuous_orders[z1].stop_dt,"mm/dd/yy hh:mm;;q"))
          ELSE concat("Order Detail :",continuous_orders_disp->continuous_orders[z1].core_actions[z2]
            .clinical_display_line)
          ENDIF
          ,
          wrapcol = 100, line_wrap
          IF (comment_string > "")
           comment_string = replace(comment_string,char(13)," ",0), tempstring = concat("Comment: ",
            comment_string), line_wrap2
          ENDIF
         ENDIF
       ENDFOR
       FOR (z3 = 1 TO 1)
         IF (ycol > 725)
          BREAK
         ENDIF
         xcol = 50,
         CALL print(calcpos(50,ycol)), "{b}Current Last Dose Given",
         row + 1, ycol = (ycol+ 12), xcol = 50
         IF (trim(continuous_orders_disp->continuous_orders[z1].admins[z3].event_title_text)=
         "IVPARENT")
          med_date = continuous_orders_disp->continuous_orders[z1].admins[z3].admin_start_dt_tm,
          med_date_disp = format(med_date,"mm/dd/yyyy hh:mm;;Q"), dose = fillstring(30,""),
          dose = format(continuous_orders_disp->continuous_orders[z1].admins[z3].initial_volume,
           "#######.##;l"), dose_unit = trim(continuous_orders_disp->continuous_orders[z1].admins[z3]
           .dosage_unit), rate = format(continuous_orders_disp->continuous_orders[z1].admins[z3].
           infusion_rate,"#######.##;l"),
          rate_unit = trim(continuous_orders_disp->continuous_orders[z1].admins[z3].infusion_unit),
          event = build(med_date_disp,"->",dose,dose_unit,";",
           rate,",",rate_unit),
          CALL print(calcpos(50,ycol)),
          event, row + 1, ycol = (ycol+ 12)
         ENDIF
       ENDFOR
       ycol = (ycol+ 12)
      ENDIF
    ENDFOR
   ENDIF
   IF (size(continuous_orders->qual,5) > 0)
    FOR (con = 1 TO size(continuous_orders->qual,5))
      IF (ycol > 725)
       BREAK
      ENDIF
      xcol = 50
      IF ((continuous_orders->qual[con].print_ind=0)
       AND (continuous_orders->qual[con].action_type != "Ordered"))
       meds_found = 1
       IF (print_title=0)
        xcol = 30, ycol = (ycol+ 12)
        IF ((pt_transfer->disch_date > 0))
         title = build(
          "{f/0}{cpi/14}{b}{u}Discontinued or Completed IV Infusions in last 7 days immediately before Discharge:{endb}{endu}"
          )
        ELSE
         title = build(
          "{f/0}{cpi/14}{b}{u}Discontinued or Completed IV Infusions in last 7 days:{endb}{endu}")
        ENDIF
        CALL print(calcpos(xcol,ycol)), title, row + 1,
        ycol = (ycol+ 12), print_title = 1, xcol = 50
       ENDIF
       tempstring =
       IF (size(continuous_orders->qual[con].stop_dt) > 0) concat("{b}",continuous_orders->qual[con].
         order_name,"{endb}: ",continuous_orders->qual[con].order_detail,", Projected Stop date ",
         format(continuous_orders->qual[con].stop_dt,"mm/dd/yy hh:mm;;q"))
       ELSE concat("{b}",continuous_orders->qual[con].order_name,"{endb}: ",continuous_orders->qual[
         con].order_detail)
       ENDIF
       , wrapcol = 100, line_wrap,
       comment_string = build(continuous_orders->qual[con].comment)
       IF (comment_string > "")
        comment_string = replace(comment_string,char(13)," ",0), tempstring = concat("Comment: ",
         comment_string), line_wrap2
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   IF (meds_found=0)
    IF (ycol > 725)
     BREAK
    ENDIF
    xcol = 30, ycol = (ycol+ 12)
    IF ((pt_transfer->disch_date > 0))
     title = build(
      "{f/0}{cpi/14}{b}{u}Discontinued or Completed IV Infusions in last 7 days immediately before Discharge:{endb}{endu}"
      ), title = build(title," None found in last 7 days.")
    ELSE
     title = build("{b}{u}Discontinued or Completed IV Infusions in last 7 days:{endb}{endu}"), title
      = build(title," None found in last 7 days.")
    ENDIF
    CALL print(calcpos(xcol,ycol)), title, ycol = (ycol+ 12),
    row + 1
   ENDIF
   IF (ycol > 725)
    BREAK
   ENDIF
   found = 0
   FOR (x = 1 TO pt_transfer->blob_cnt)
     FOR (y = 1 TO pt_transfer->blob_qual[x].blobs_cnt)
       IF ((pt_transfer->blob_qual[x].blob_set_name="History and Physical - Dictated"))
        blob_set_name = "History and Physical - Dictated"
        IF (found=0)
         ycol = (ycol+ 12), row + 1, xcol = 30,
         row + 1,
         CALL print(calcpos(xcol,ycol)), "{f/0}{cpi/14}{b}{u}",
         blob_set_name, ":", "{endb}{endu}"
        ENDIF
        found = 1
        IF ((pt_transfer->blob_qual[x].blobs_qual[y].event_title_text != "Addendum by*"))
         ycol = (ycol+ 12), row + 1, xcol = 30,
         row + 1,
         CALL print(calcpos(xcol,ycol)), "Note Type: ",
         pt_transfer->blob_qual[x].blob_event_cd, ycol = (ycol+ 12), row + 1,
         xcol = 30, row + 1,
         CALL print(calcpos(xcol,ycol)),
         "Note Date: ", pt_transfer->blob_qual[x].blob_date, ycol = (ycol+ 12),
         row + 1
        ENDIF
        IF (size(pt_transfer->blob_qual[x].blobs_qual[y].blob_contents) > 0)
         FOR (z = 1 TO blob_disp->blob_cnt)
           IF ((blob_disp->qual[z].event_id=pt_transfer->blob_qual[x].blobs_qual[y].event_id))
            FOR (zz = 1 TO blob_disp->qual[z].line_cnt)
              IF (ycol > 725)
               BREAK
              ENDIF
              output_display = fillstring(100,""), output_display = trim(blob_disp->qual[z].line[zz].
               disp,3), xcol = 50,
              row + 1,
              CALL print(calcpos(xcol,ycol)), output_display,
              ycol = (ycol+ 12)
            ENDFOR
           ENDIF
         ENDFOR
        ENDIF
       ENDIF
     ENDFOR
   ENDFOR
   IF (found=0)
    ycol = (ycol+ 12), row + 1, xcol = 30,
    CALL print(calcpos(xcol,ycol)), "{f/0}{cpi/14}{b}No History and Physical - Dictated.{endb}", ycol
     = (ycol+ 12),
    row + 1
   ENDIF
   output_display = "", output_display1 = "", output_display2 = ""
   IF (ycol > 725)
    BREAK
   ENDIF
   ycol = (ycol+ 12), row + 1, xcol = 30,
   row + 1,
   CALL print(calcpos(xcol,ycol)), "{f/0}{cpi/14}{b}{u}Consultation Orders:{endb}{endu}"
   IF ((pt_transfer->resort_consult_cnt > 0))
    FOR (x = 1 TO pt_transfer->resort_consult_cnt)
      IF (x=1)
       ycol = (ycol+ 12), row + 1
      ENDIF
      IF (ycol > 725)
       BREAK
      ENDIF
      output_display = concat("{f/0}{cpi/14}{b}",trim(pt_transfer->resort_consult_qual[x].ord_name,3),
       "{endb}"," ",trim(pt_transfer->resort_consult_qual[x].status,3),
       " on: ",pt_transfer->resort_consult_qual[x].status_date)
      IF (size(trim(pt_transfer->resort_consult_qual[x].completed_by,3)) > 0)
       output_display1 = concat(" by: ",trim(pt_transfer->resort_consult_qual[x].completed_by,3))
      ENDIF
      output_display2 = concat(output_display,output_display1)
      IF (textlen(trim(output_display2,3)) > 110)
       tempstring = trim(output_display2,3), xcol = 30, wrapcol = 110,
       line_wrap
      ELSE
       xcol = 30, row + 1,
       CALL print(calcpos(xcol,ycol)),
       output_display2, ycol = (ycol+ 12), row + 1
      ENDIF
      IF (size(trim(pt_transfer->resort_consult_qual[x].order_detail,3)) > 0)
       output_display = concat("Order Detail: ",pt_transfer->resort_consult_qual[x].order_detail)
       IF (textlen(trim(output_display,3)) > 100)
        tempstring = trim(output_display,3), xcol = 35, wrapcol = 98,
        line_wrap
       ELSE
        xcol = 35, row + 1,
        CALL print(calcpos(xcol,ycol)),
        output_display, ycol = (ycol+ 12), row + 1
       ENDIF
      ENDIF
    ENDFOR
   ELSE
    xcol = 140, row + 1,
    CALL print(calcpos(xcol,ycol)),
    "No Consult Orders found on visit.", ycol = (ycol+ 12), row + 1
   ENDIF
   IF (found=0)
    ycol = (ycol+ 12), row + 1, xcol = 30,
    CALL print(calcpos(xcol,ycol)),
    "{f/0}{cpi/14}{b}No Consultation Note - Dictated documents found on visit.{endb}", ycol = (ycol+
    12),
    row + 1
   ENDIF
   FOR (x = 1 TO pt_transfer->blob_cnt)
     FOR (y = 1 TO pt_transfer->blob_qual[x].blobs_cnt)
       IF ((pt_transfer->blob_qual[x].blob_set_name="Consultation Note - Dictated"))
        blob_set_name = "Consultation Note - Dictated"
        IF (found=0)
         ycol = (ycol+ 12), row + 1, xcol = 30,
         row + 1,
         CALL print(calcpos(xcol,ycol)), "{f/0}{cpi/14}{b}{u}",
         blob_set_name, ":", "{endb}{endu}"
        ENDIF
        found = 1
        IF ((pt_transfer->blob_qual[x].blobs_qual[y].event_title_text != "Addendum by*"))
         ycol = (ycol+ 12), row + 1, xcol = 30,
         row + 1,
         CALL print(calcpos(xcol,ycol)), "Note Type: ",
         pt_transfer->blob_qual[x].blob_event_cd, ycol = (ycol+ 12), row + 1,
         xcol = 30, row + 1,
         CALL print(calcpos(xcol,ycol)),
         "Note Date: ", pt_transfer->blob_qual[x].blob_date, ycol = (ycol+ 12),
         row + 1
        ENDIF
        IF (size(pt_transfer->blob_qual[x].blobs_qual[y].blob_contents) > 0)
         FOR (z = 1 TO blob_disp->blob_cnt)
           IF ((blob_disp->qual[z].event_id=pt_transfer->blob_qual[x].blobs_qual[y].event_id))
            FOR (zz = 1 TO blob_disp->qual[z].line_cnt)
              IF (ycol > 725)
               BREAK
              ENDIF
              output_display = fillstring(100,""), output_display = trim(blob_disp->qual[z].line[zz].
               disp,3), xcol = 50,
              row + 1,
              CALL print(calcpos(xcol,ycol)), output_display,
              ycol = (ycol+ 12)
            ENDFOR
           ENDIF
         ENDFOR
        ENDIF
       ENDIF
     ENDFOR
   ENDFOR
   IF (found=0)
    ycol = (ycol+ 12), row + 1, xcol = 30,
    CALL print(calcpos(xcol,ycol)), "{f/0}{cpi/14}{b}No Consultation Note - Dictated found.{endb}",
    ycol = (ycol+ 12),
    row + 1
   ENDIF
   output_display = "", output_display1 = "", output_display2 = ""
   IF (ycol > 725)
    BREAK
   ENDIF
   ycol = (ycol+ 12), row + 1
   IF ((pt_transfer->disch_date > 0))
    xcol = 30, row + 1,
    CALL print(calcpos(xcol,ycol)),
    "{f/0}{cpi/14}{b}{u}Vitals in the last 24 hours immediately before discharge:{endb}{endu}"
   ELSE
    xcol = 30, row + 1,
    CALL print(calcpos(xcol,ycol)),
    "{f/0}{cpi/14}{b}{u}Vitals in the last 24 hours:{endb}{endu}"
   ENDIF
   IF ((pt_transfer->vitals_cnt > 0))
    FOR (x = 1 TO pt_transfer->vitals_cnt)
      IF (x=1)
       ycol = (ycol+ 12), row + 1
      ENDIF
      IF (ycol > 725)
       BREAK
      ENDIF
      IF (mod(x,2)=1)
       output_display1 = concat(pt_transfer->vitals[x].vit_date," ",pt_transfer->vitals[x].vit_name),
       output_display2 = concat(pt_transfer->vitals[x].vit_result," ",pt_transfer->vitals[x].vit_unit
        ), xcol = 30,
       row + 1,
       CALL print(calcpos(xcol,ycol)), output_display1,
       xcol = 210, row + 1,
       CALL print(calcpos(xcol,ycol)),
       output_display2
       IF ((x=pt_transfer->vitals_cnt))
        ycol = (ycol+ 12), row + 1
       ENDIF
      ELSEIF (mod(x,2)=0)
       output_display1 = concat(pt_transfer->vitals[x].vit_date," ",pt_transfer->vitals[x].vit_name),
       output_display2 = concat(pt_transfer->vitals[x].vit_result," ",pt_transfer->vitals[x].vit_unit
        ), xcol = 350,
       row + 1,
       CALL print(calcpos(xcol,ycol)), output_display1,
       xcol = 530, row + 1,
       CALL print(calcpos(xcol,ycol)),
       output_display2, ycol = (ycol+ 12), row + 1
      ENDIF
    ENDFOR
   ELSE
    IF ((pt_transfer->disch_date > 0))
     xcol = 330, row + 1,
     CALL print(calcpos(xcol,ycol)),
     "No Vitals found in the last 24 hours on visit."
    ELSE
     xcol = 180, row + 1,
     CALL print(calcpos(xcol,ycol)),
     "No Vitals found in the last 24 hours on visit."
    ENDIF
    ycol = (ycol+ 12), row + 1
   ENDIF
   output_display = "", output_display1 = "", output_display2 = ""
   IF (ycol > 725)
    BREAK
   ENDIF
   ycol = (ycol+ 12), row + 1
   IF ((pt_transfer->disch_date > 0))
    xcol = 30, row + 1,
    CALL print(calcpos(xcol,ycol)),
    "{f/0}{cpi/14}{b}{u}",
    "Clinical Summary - Last 7 days of Orders immediately before discharge:{endb}{endu}", ycol = (
    ycol+ 12),
    row + 1, xcol = 30, row + 1,
    CALL print(calcpos(xcol,ycol)), "(Excluding meds, code status, isolation, consults, diets)"
   ELSE
    xcol = 30, row + 1,
    CALL print(calcpos(xcol,ycol)),
    "{f/0}{cpi/14}{b}{u}",
    "Clinical Summary - Last 7 days of Orders: (Excluding meds, code status, isolation, consults, diets){endb}{endu}"
   ENDIF
   IF ((pt_transfer->catalog_cnt > 0))
    FOR (x = 1 TO pt_transfer->catalog_cnt)
      IF (x=1)
       ycol = (ycol+ 18), row + 1
      ENDIF
      IF (ycol > 725)
       BREAK
      ENDIF
      output_display = concat(trim(pt_transfer->catalog_qual[x].catalog_type,3),": "), xcol = 30, row
       + 1,
      CALL print(calcpos(xcol,ycol)), "{b}", output_display,
      "{endb}", ycol = (ycol+ 12), row + 1
      FOR (y = 1 TO pt_transfer->catalog_qual[x].orders_cnt)
        IF (ycol > 725)
         BREAK
        ENDIF
        output_display1 = concat(pt_transfer->catalog_qual[x].orders_qual[y].date," ",pt_transfer->
         catalog_qual[x].orders_qual[y].status," {b}",pt_transfer->catalog_qual[x].orders_qual[y].
         ord_name,
         ": {endb}",pt_transfer->catalog_qual[x].orders_qual[y].od_display_line)
        IF (textlen(trim(output_display1,3)) > 110)
         tempstring = trim(output_display1,3), xcol = 30, wrapcol = 110,
         line_wrap
        ELSE
         xcol = 30, row + 1,
         CALL print(calcpos(xcol,ycol)),
         output_display1, ycol = (ycol+ 12), row + 1
        ENDIF
        output_display2 =
        "_______________________________________________________________________________________________",
        xcol = 105, row + 1,
        CALL print(calcpos(xcol,ycol)), output_display2, ycol = (ycol+ 12),
        row + 1
      ENDFOR
      ycol = (ycol+ 6), row + 1
    ENDFOR
   ELSE
    ycol = (ycol+ 12), row + 1
    IF ((pt_transfer->disch_date > 0))
     xcol = 50, row + 1,
     CALL print(calcpos(xcol,ycol)),
     "No Orders found in the last 7 days on visit.", ycol = (ycol+ 12), row + 1
    ELSE
     xcol = 50, row + 1,
     CALL print(calcpos(xcol,ycol)),
     "No Orders found in the last 7 days on visit.", ycol = (ycol+ 12), row + 1
    ENDIF
   ENDIF
   IF (ycol > 725)
    BREAK
   ENDIF
   output_display = "", output_display1 = "", output_display2 = ""
   IF ((pt_transfer->disch_date > 0))
    xcol = 30, ycol = (ycol+ 12), row + 1,
    CALL print(calcpos(xcol,ycol)),
    "{f/0}{cpi/14}{b}{u}Pneumococcal and Influenza Immunizations immediately before discharge:{endb}{endu}"
   ELSE
    xcol = 30, ycol = (ycol+ 12), row + 1,
    CALL print(calcpos(xcol,ycol)),
    "{f/0}{cpi/14}{b}{u}Pneumococcal and Influenza Immunizations:{endb}{endu}"
   ENDIF
   ycol = (ycol+ 12), row + 1
   IF ((pt_transfer->immun_cnt > 0))
    FOR (x = 1 TO pt_transfer->immun_cnt)
     output_display = concat(pt_transfer->immun[x].given_date,"  ",trim(pt_transfer->immun[x].name,3)
      ),
     IF (textlen(trim(output_display,3)) > 110)
      tempstring = trim(output_display,3), xcol = 30, wrapcol = 110,
      line_wrap
     ELSEIF (textlen(trim(output_display,3)) > 0)
      IF (ycol > 725)
       BREAK
      ENDIF
      xcol = 30, row + 1,
      CALL print(calcpos(xcol,ycol)),
      output_display, ycol = (ycol+ 12), row + 1
     ENDIF
    ENDFOR
   ELSE
    IF ((pt_transfer->disch_date > 0))
     xcol = 50, row + 1,
     CALL print(calcpos(xcol,ycol)),
     "No Pneumococcal found in last 5 yrs or Influenza found in last year."
    ELSE
     xcol = 50, row + 1,
     CALL print(calcpos(xcol,ycol)),
     "No Pneumococcal found in last 5 yrs or Influenza found in last year."
    ENDIF
    ycol = (ycol+ 12)
   ENDIF
   IF (ycol > 725)
    BREAK
   ENDIF
   ycol = (ycol+ 12), row + 1, xcol = 30,
   row + 1,
   CALL print(calcpos(xcol,ycol)),
   "{f/0}{cpi/14}{b}{u}Last results for BSA, BMI, Height, and Weight:{endb}{endu}"
   IF ((pt_transfer->special_vit_cnt > 0))
    FOR (x = 1 TO pt_transfer->special_vit_cnt)
      IF (x=1)
       ycol = (ycol+ 12), row + 1
      ENDIF
      IF (ycol > 725)
       BREAK
      ENDIF
      IF (mod(x,2)=1)
       output_display1 = concat(pt_transfer->special_vit[x].vit_date," ",pt_transfer->special_vit[x].
        vit_name), output_display2 = concat(pt_transfer->special_vit[x].vit_result," ",pt_transfer->
        special_vit[x].vit_unit), xcol = 30,
       row + 1,
       CALL print(calcpos(xcol,ycol)), output_display1,
       xcol = 210, row + 1,
       CALL print(calcpos(xcol,ycol)),
       output_display2
       IF ((x=pt_transfer->special_vit_cnt))
        ycol = (ycol+ 12), row + 1
       ENDIF
      ELSEIF (mod(x,2)=0)
       output_display1 = concat(pt_transfer->special_vit[x].vit_date," ",pt_transfer->special_vit[x].
        vit_name), output_display2 = concat(pt_transfer->special_vit[x].vit_result," ",pt_transfer->
        special_vit[x].vit_unit), xcol = 350,
       row + 1,
       CALL print(calcpos(xcol,ycol)), output_display1,
       xcol = 530, row + 1,
       CALL print(calcpos(xcol,ycol)),
       output_display2, ycol = (ycol+ 12), row + 1
      ENDIF
    ENDFOR
   ELSE
    xcol = 270, row + 1,
    CALL print(calcpos(xcol,ycol)),
    "No BSA, BMI, Height, or Weight found on visit.", ycol = (ycol+ 12), row + 1
   ENDIF
   output_display = "", output_display1 = "", output_display2 = ""
   IF (ycol > 725)
    BREAK
   ENDIF
   ycol = (ycol+ 12), row + 1, xcol = 30,
   row + 1,
   CALL print(calcpos(xcol,ycol)),
   "{f/0}{cpi/14}{b}{u}Last results for CBC, Lytes, BUN, Creat, INR:{endb}{endu}"
   IF ((pt_transfer->special_labs_cnt > 0))
    FOR (x = 1 TO pt_transfer->special_labs_cnt)
     IF (x=1)
      ycol = (ycol+ 12), row + 1
     ENDIF
     ,
     FOR (y = 1 TO pt_transfer->special_labs[x].result_cnt)
       critical_value = 0
       IF (ycol > 725)
        BREAK
       ENDIF
       output_display1 = concat(pt_transfer->special_labs[x].result_qual[y].result_date," ",
        pt_transfer->special_labs[x].result_qual[y].result_name), output_display2 = concat(
        pt_transfer->special_labs[x].result_qual[y].result_val," ",pt_transfer->special_labs[x].
        result_qual[y].units," ",pt_transfer->special_labs[x].result_qual[y].ref_range,
        " ",pt_transfer->special_labs[x].result_qual[y].normalcy_disp)
       IF ((pt_transfer->special_labs[x].result_qual[y].normalcy_disp="C"))
        xcol = 30, row + 1,
        CALL print(calcpos(xcol,ycol)),
        "{b}", output_display1, "{endb}"
       ELSE
        xcol = 30, row + 1,
        CALL print(calcpos(xcol,ycol)),
        output_display1
       ENDIF
       IF (textlen(trim(output_display2,3)) > 50)
        IF ((pt_transfer->special_labs[x].result_qual[y].normalcy_disp="C"))
         critical_value = 1
        ENDIF
        tempstring = trim(output_display2,3), eol = size(tempstring), xcol = 340,
        wrapcol = 50, line_wrap
       ELSE
        IF (ycol > 725)
         BREAK
        ENDIF
        IF ((pt_transfer->special_labs[x].result_qual[y].normalcy_disp="C"))
         xcol = 340, row + 1,
         CALL print(calcpos(xcol,ycol)),
         "{b}", output_display2, "{endb}"
        ELSE
         xcol = 340, row + 1,
         CALL print(calcpos(xcol,ycol)),
         output_display2
        ENDIF
       ENDIF
       ycol = (ycol+ 12), row + 1
       IF ((pt_transfer->special_labs[x].result_qual[y].result_comments > " "))
        blob_contents = pt_transfer->special_labs[x].result_qual[y].result_comments, compression_cd
         = pt_transfer->special_labs[x].result_qual[y].comment_comp_cd, blob_type = "comment",
        print_blob_comment_report, new_blob_contents = trim(blobout2,3)
        IF (trim(new_blob_contents,3) > " ")
         IF (ycol > 725)
          BREAK
         ENDIF
         xcol = 50, row + 1,
         CALL print(calcpos(xcol,ycol)),
         "Result Comment: "
         IF (size(trim(new_blob_contents,3)) > 80)
          tempstring = trim(new_blob_contents,3), eol = size(tempstring), xcol = 130,
          wrapcol = 80, line_wrap
         ELSE
          output_display1 = trim(new_blob_contents,3), xcol = 130, row + 1,
          CALL print(calcpos(xcol,ycol)), output_display1, ycol = (ycol+ 12)
         ENDIF
        ENDIF
       ENDIF
     ENDFOR
    ENDFOR
   ELSE
    IF (ycol > 725)
     BREAK
    ENDIF
    xcol = 270, row + 1,
    CALL print(calcpos(xcol,ycol)),
    "No CBC, Lytes, BUN, Creat, or INR results found on visit.", ycol = (ycol+ 12), row + 1
   ENDIF
   critical_value = 0, output_display = "", output_display1 = "",
   output_display2 = ""
   IF (ycol > 725)
    BREAK
   ENDIF
   ycol = (ycol+ 12), row + 1
   IF ((pt_transfer->disch_date > 0))
    xcol = 30, row + 1,
    CALL print(calcpos(xcol,ycol)),
    "{f/0}{cpi/14}{b}{u}Lab results in the last 14 days immediately before discharge:{endb}{endu}"
   ELSE
    xcol = 30, row + 1,
    CALL print(calcpos(xcol,ycol)),
    "{f/0}{cpi/14}{b}{u}Lab results in the last 14 days:{endb}{endu}"
   ENDIF
   IF ((pt_transfer->lab_results_cnt > 0))
    FOR (x = 1 TO pt_transfer->lab_results_cnt)
      critical_value = 0
      IF (x=1)
       ycol = (ycol+ 12), row + 1
      ENDIF
      IF (ycol > 725)
       BREAK
      ENDIF
      output_display1 = concat(pt_transfer->lab_results[x].date," ",pt_transfer->lab_results[x].
       event_cd_disp), output_display2 = concat(pt_transfer->lab_results[x].result_val," ",
       pt_transfer->lab_results[x].units," ",pt_transfer->lab_results[x].ref_range,
       " ",pt_transfer->lab_results[x].normalcy_disp)
      IF ((pt_transfer->lab_results[x].normalcy_disp="C"))
       xcol = 30, row + 1,
       CALL print(calcpos(xcol,ycol)),
       "{b}", output_display1, "{endb}"
      ELSE
       xcol = 30, row + 1,
       CALL print(calcpos(xcol,ycol)),
       output_display1
      ENDIF
      IF (textlen(trim(output_display2,3)) > 50)
       IF ((pt_transfer->lab_results[x].normalcy_disp="C"))
        critical_value = 1
       ENDIF
       tempstring = trim(output_display2,3), xcol = 340, wrapcol = 50,
       line_wrap
      ELSE
       IF (ycol > 725)
        BREAK
       ENDIF
       IF ((pt_transfer->lab_results[x].normalcy_disp="C"))
        xcol = 340, row + 1,
        CALL print(calcpos(xcol,ycol)),
        "{b}", output_display2, "{endb}"
       ELSE
        xcol = 340, row + 1,
        CALL print(calcpos(xcol,ycol)),
        output_display2
       ENDIF
      ENDIF
      ycol = (ycol+ 12), row + 1
      IF (size(pt_transfer->lab_results[x].result_comments) > 0)
       blob_contents = pt_transfer->lab_results[x].result_comments, compression_cd = pt_transfer->
       lab_results[x].comment_comp_cd, blob_type = "comment",
       print_blob_comment_report, new_blob_contents = trim(blobout2,3)
       IF (trim(new_blob_contents,3) > " ")
        xcol = 50, row + 1,
        CALL print(calcpos(xcol,ycol)),
        "Result Comment: "
        IF (size(trim(new_blob_contents,3)) > 80)
         tempstring = trim(new_blob_contents,3), eol = size(tempstring), xcol = 130,
         wrapcol = 80, line_wrap
        ELSE
         IF (ycol > 725)
          BREAK
         ENDIF
         output_display1 = trim(new_blob_contents,3), xcol = 130, row + 1,
         CALL print(calcpos(xcol,ycol)), output_display1, ycol = (ycol+ 12)
        ENDIF
       ENDIF
      ENDIF
    ENDFOR
   ELSE
    IF (ycol > 725)
     BREAK
    ENDIF
    IF ((pt_transfer->disch_date > 0))
     xcol = 360, row + 1,
     CALL print(calcpos(xcol,ycol)),
     "No Lab results found in the last 14 days on visit."
    ELSE
     xcol = 200, row + 1,
     CALL print(calcpos(xcol,ycol)),
     "No Lab results found in the last 14 days on visit."
    ENDIF
    ycol = (ycol+ 12), row + 1
   ENDIF
   critical_value = 0, output_display = "", output_display1 = "",
   output_display2 = ""
   IF (ycol > 725)
    BREAK
   ENDIF
   ycol = (ycol+ 12), row + 1
   IF ((pt_transfer->disch_date > 0))
    xcol = 30, row + 1,
    CALL print(calcpos(xcol,ycol)),
    "{f/0}{cpi/14}{b}{u}Micro results in the last 14 days immediately before discharge:{endb}{endu}"
   ELSE
    xcol = 30, row + 1,
    CALL print(calcpos(xcol,ycol)),
    "{f/0}{cpi/14}{b}{u}Micro results in the last 14 days:{endb}{endu}"
   ENDIF
   IF ((pt_transfer->micro_cnt > 0))
    FOR (x = 1 TO pt_transfer->micro_cnt)
      IF (x=1)
       ycol = (ycol+ 12), row + 1
      ENDIF
      IF (ycol > 725)
       BREAK
      ENDIF
      output_display1 = concat(pt_transfer->micro_results[x].collect_dt_tm," ",pt_transfer->
       micro_results[x].result_status," ","{b}",
       pt_transfer->micro_results[x].event_name,"{endb}"), xcol = 30, row + 1,
      CALL print(calcpos(xcol,ycol)), output_display1, ycol = (ycol+ 12)
      IF (size(pt_transfer->micro_results[x].result_val) > 0)
       IF (ycol > 725)
        BREAK
       ENDIF
       xcol = 50, row + 1,
       CALL print(calcpos(xcol,ycol)),
       "Micro Result:"
       IF (size(trim(pt_transfer->micro_results[x].result_val,3)) > 80)
        tempstring = trim(pt_transfer->micro_results[x].result_val,3), eol = size(tempstring), xcol
         = 120,
        wrapcol = 80, line_wrap
       ELSE
        output_display1 = trim(pt_transfer->micro_results[x].result_val,3), xcol = 120, row + 1,
        CALL print(calcpos(xcol,ycol)), output_display1, ycol = (ycol+ 12)
       ENDIF
      ELSEIF (size(pt_transfer->micro_results[x].blob_contents) > 0)
       blob_contents = pt_transfer->micro_results[x].blob_contents, compression_cd = pt_transfer->
       micro_results[x].comp_cd, blob_type = "report",
       print_blob_comment_report
      ELSE
       IF (ycol > 725)
        BREAK
       ENDIF
       xcol = 50, row + 1,
       CALL print(calcpos(xcol,ycol)),
       "No micro document or result available for test.", ycol = (ycol+ 12)
      ENDIF
      IF ((pt_transfer->micro_results[x].result_comments > " "))
       blob_contents = pt_transfer->micro_results[x].result_comments, compression_cd = pt_transfer->
       micro_results[x].comment_comp_cd, blob_type = "comment",
       print_blob_comment_report, new_blob_contents = trim(blobout2,3)
       IF (trim(new_blob_contents,3) > " ")
        IF (ycol > 725)
         BREAK
        ENDIF
        xcol = 50, row + 1,
        CALL print(calcpos(xcol,ycol)),
        "Result Comment: "
        IF (size(trim(new_blob_contents,3)) > 80)
         tempstring = trim(new_blob_contents,3), eol = size(tempstring), xcol = 130,
         wrapcol = 80, line_wrap
        ELSE
         output_display1 = trim(new_blob_contents,3), xcol = 130, row + 1,
         CALL print(calcpos(xcol,ycol)), output_display1, ycol = (ycol+ 12)
        ENDIF
       ENDIF
      ENDIF
    ENDFOR
   ELSE
    IF (ycol > 725)
     BREAK
    ENDIF
    IF ((pt_transfer->disch_date > 0))
     xcol = 360, row + 1,
     CALL print(calcpos(xcol,ycol)),
     "No Micro results in the last 14 days on visit."
    ELSE
     xcol = 210, row + 1,
     CALL print(calcpos(xcol,ycol)),
     "No Micro results in the last 14 days on visit."
    ENDIF
    ycol = (ycol+ 12), row + 1
   ENDIF
   found = 0
   IF (ycol > 725)
    BREAK
   ENDIF
   FOR (x = 1 TO pt_transfer->blob_cnt)
     FOR (y = 1 TO pt_transfer->blob_qual[x].blobs_cnt)
       IF ((pt_transfer->blob_qual[x].blob_set_name="RADIOLOGY"))
        blob_set_name = "Radiology"
        IF (found=0)
         ycol = (ycol+ 12), row + 1, xcol = 30,
         row + 1,
         CALL print(calcpos(xcol,ycol)), "{f/0}{cpi/14}{b}{u}",
         blob_set_name, ":", "{endb}{endu}"
        ENDIF
        found = 1
        IF ((pt_transfer->blob_qual[x].blobs_qual[y].event_title_text != "Addendum by*"))
         ycol = (ycol+ 12), row + 1, xcol = 30,
         row + 1,
         CALL print(calcpos(xcol,ycol)), "Note Type: ",
         pt_transfer->blob_qual[x].blob_event_cd, ycol = (ycol+ 12), row + 1,
         xcol = 30, row + 1,
         CALL print(calcpos(xcol,ycol)),
         "Note Date: ", pt_transfer->blob_qual[x].blob_date, ycol = (ycol+ 12),
         row + 1
        ENDIF
        IF (size(pt_transfer->blob_qual[x].blobs_qual[y].blob_contents) > 0)
         blob_contents = pt_transfer->blob_qual[x].blobs_qual[y].blob_contents, compression_cd =
         pt_transfer->blob_qual[x].blobs_qual[y].comp_cd, blob_type = "report",
         print_blob_comment_report
        ENDIF
       ENDIF
     ENDFOR
   ENDFOR
   IF (found=0)
    ycol = (ycol+ 12), row + 1, xcol = 30,
    CALL print(calcpos(xcol,ycol)), "{f/0}{cpi/14}{b}No Radiology documents found on visit.{endb}",
    ycol = (ycol+ 12),
    row + 1
   ENDIF
   found = 0
   IF (ycol > 725)
    BREAK
   ENDIF
   FOR (x = 1 TO pt_transfer->blob_cnt)
     FOR (y = 1 TO pt_transfer->blob_qual[x].blobs_cnt)
       IF ((pt_transfer->blob_qual[x].blob_set_name IN ("Cardiovascular", "Cardiovascular (new)",
       "CARDIOVASCULAR TEST")))
        blob_set_name = pt_transfer->blob_qual[x].blob_set_name
        IF (found=0)
         ycol = (ycol+ 12), row + 1, xcol = 30,
         row + 1,
         CALL print(calcpos(xcol,ycol)), "{f/0}{cpi/14}{b}{u}",
         blob_set_name, ":", "{endb}{endu}"
        ENDIF
        found = 1
        IF ((pt_transfer->blob_qual[x].blobs_qual[y].event_title_text != "Addendum by*"))
         ycol = (ycol+ 12), row + 1, xcol = 30,
         row + 1,
         CALL print(calcpos(xcol,ycol)), "Note Type: ",
         pt_transfer->blob_qual[x].blob_event_cd, ycol = (ycol+ 12), row + 1,
         xcol = 30, row + 1,
         CALL print(calcpos(xcol,ycol)),
         "Note Date: ", pt_transfer->blob_qual[x].blob_date, ycol = (ycol+ 12),
         row + 1
        ENDIF
        IF (size(pt_transfer->blob_qual[x].blobs_qual[y].blob_contents) > 0)
         blob_contents = pt_transfer->blob_qual[x].blobs_qual[y].blob_contents, compression_cd =
         pt_transfer->blob_qual[x].blobs_qual[y].comp_cd, blob_type = "report",
         print_blob_comment_report
        ENDIF
       ENDIF
     ENDFOR
   ENDFOR
   IF (found=0)
    ycol = (ycol+ 12), row + 1, xcol = 30,
    CALL print(calcpos(xcol,ycol)),
    "{f/0}{cpi/14}{b}No Cardiovascular documents found on visit .{endb}", ycol = (ycol+ 12),
    row + 1
   ENDIF
   output_display = " ", output_display1 = " ", output_display2 = " "
   IF ((pt_transfer->form_cnt > 0))
    IF (ycol > 725)
     BREAK
    ENDIF
    FOR (l = 1 TO pt_transfer->form_cnt)
      IF (ycol > 725)
       BREAK
      ENDIF
      output_display = "", output_display1 = "", output_display2 = ""
      IF ((pt_transfer->form_qual[l].form_type IN ("Nutrition Eval1", "Nutrition Eval2")))
       output_display = concat("{f/0}{cpi/14}{b}{u}Nutrition Assessment:{endb}{endu}"), xcol = 30,
       row + 1,
       CALL print(calcpos(xcol,ycol)), output_display, ycol = (ycol+ 12),
       row + 1
      ELSEIF ((pt_transfer->form_qual[l].form_type IN ("PT Eval1", "PT Eval2", "PT Eval3")))
       output_display = concat("{f/0}{cpi/14}{b}{u}Physical Therapy Assessment:{endb}{endu}"), xcol
        = 30, row + 1,
       CALL print(calcpos(xcol,ycol)), output_display, ycol = (ycol+ 12),
       row + 1
      ELSEIF ((pt_transfer->form_qual[l].form_type="PT Treat1"))
       output_display = concat("{f/0}{cpi/14}{b}{u}Physical Therapy Treatment:{endb}{endu}"), xcol =
       30, row + 1,
       CALL print(calcpos(xcol,ycol)), output_display, ycol = (ycol+ 12),
       row + 1
      ELSEIF ((pt_transfer->form_qual[l].form_type="OT Eval1"))
       output_display = concat("{f/0}{cpi/14}{b}{u}Occupational Therapy Assessment:{endb}{endu}"),
       xcol = 30, row + 1,
       CALL print(calcpos(xcol,ycol)), output_display, ycol = (ycol+ 12),
       row + 1
      ELSEIF ((pt_transfer->form_qual[l].form_type="OT Treat1"))
       output_display = concat("{f/0}{cpi/14}{b}{u}Occupational TherapyTreatment:{endb}{endu}"),
       xcol = 30, row + 1,
       CALL print(calcpos(xcol,ycol)), output_display, ycol = (ycol+ 12),
       row + 1
      ELSEIF ((pt_transfer->form_qual[l].form_type IN ("ST Eval1", "ST Eval2", "ST Eval3", "ST Eval4"
      )))
       output_display = concat("{f/0}{cpi/14}{b}{u}Speech Therapy Assessment:{endb}{endu}"), xcol =
       30, row + 1,
       CALL print(calcpos(xcol,ycol)), output_display, ycol = (ycol+ 12),
       row + 1
      ELSEIF ((pt_transfer->form_qual[l].form_type="ST Treat1"))
       output_display = concat("{f/0}{cpi/14}{b}{u}Speech Therapy Treatment:{endb}{endu}"), xcol = 30,
       row + 1,
       CALL print(calcpos(xcol,ycol)), output_display, ycol = (ycol+ 12),
       row + 1
      ELSEIF ((pt_transfer->form_qual[l].form_type="RT Eval1"))
       output_display = concat("{f/0}{cpi/14}{b}{u}Respiratory Assessment:{endb}{endu}"), xcol = 30,
       row + 1,
       CALL print(calcpos(xcol,ycol)), output_display, ycol = (ycol+ 12),
       row + 1
      ELSEIF ((pt_transfer->form_qual[l].form_type="RT Treat1"))
       output_display = concat("{f/0}{cpi/14}{b}{u}Respiratory Treatment:{endb}{endu}"), xcol = 30,
       row + 1,
       CALL print(calcpos(xcol,ycol)), output_display, ycol = (ycol+ 12),
       row + 1
      ELSEIF ((pt_transfer->form_qual[l].form_type IN ("PULM Eval1", "PULM Eval2")))
       output_display = concat("{f/0}{cpi/14}{b}{u}Pulmonary Assessment:{endb}{endu}"), xcol = 30,
       row + 1,
       CALL print(calcpos(xcol,ycol)), output_display, ycol = (ycol+ 12),
       row + 1
      ENDIF
      output_display = concat("{b}{u}",pt_transfer->form_qual[l].form_name," from ",pt_transfer->
       form_qual[l].form_date,"{endb}{endu}"), xcol = 40, row + 1,
      CALL print(calcpos(xcol,ycol)), output_display, ycol = (ycol+ 12),
      row + 1
      FOR (l1 = 1 TO pt_transfer->form_qual[l].sub1_cnt)
        output_display = "", output_display1 = "", output_display2 = ""
        IF (ycol > 725)
         BREAK
        ENDIF
        output_display = concat("{b}{u}",pt_transfer->form_qual[l].sub1_qual[l1].event_display,
         "{endb}{endu}"), xcol = 50, row + 1,
        CALL print(calcpos(xcol,ycol)), output_display, ycol = (ycol+ 12),
        row + 1
        FOR (l2 = 1 TO pt_transfer->form_qual[l].sub1_qual[l1].sub2_cnt)
          output_display = "", output_display1 = "", output_display2 = ""
          IF (ycol > 725)
           BREAK
          ENDIF
          output_display = concat("{b}",pt_transfer->form_qual[l].sub1_qual[l1].sub2_qual[l2].
           event_display,"{endb}"," ",pt_transfer->form_qual[l].sub1_qual[l1].sub2_qual[l2].
           event_result), output_display = replace(output_display,char(13)," "), output_display =
          replace(output_display,char(10)," ")
          IF (textlen(trim(output_display,3)) > 100)
           tempstring = trim(output_display,3), xcol = 60, wrapcol = 100,
           line_wrap
          ELSEIF (textlen(trim(output_display,3)) > 0)
           xcol = 60, row + 1,
           CALL print(calcpos(xcol,ycol)),
           output_display, ycol = (ycol+ 12), row + 1
          ENDIF
          IF ((pt_transfer->form_qual[l].sub1_qual[l1].sub2_qual[l2].event_comp_cd > 0))
           blob_contents = pt_transfer->form_qual[l].sub1_qual[l1].sub2_qual[l2].event_comm,
           compression_cd = pt_transfer->form_qual[l].sub1_qual[l1].sub2_qual[l2].event_comp_cd,
           blob_type = "form_comment",
           print_blob_comment_report, new_blob_contents = trim(blobout2,3)
           IF (trim(new_blob_contents,3) > " ")
            new_blob_contents = concat("{u}Result Comment{endu}: ",trim(new_blob_contents,3))
            IF (size(trim(new_blob_contents,3)) > 100)
             tempstring = trim(new_blob_contents,3), eol = size(tempstring), xcol = 65,
             wrapcol = 100, line_wrap
            ELSE
             IF (ycol > 725)
              BREAK
             ENDIF
             output_display1 = trim(new_blob_contents,3), xcol = 65, row + 1,
             CALL print(calcpos(xcol,ycol)), output_display1, ycol = (ycol+ 12)
            ENDIF
           ENDIF
          ENDIF
          FOR (l3 = 1 TO pt_transfer->form_qual[l].sub1_qual[l1].sub2_qual[l2].sub3_cnt)
            output_display = "", output_display1 = "", output_display2 = ""
            IF (ycol > 725)
             BREAK
            ENDIF
            output_display = concat("{b}",pt_transfer->form_qual[l].sub1_qual[l1].sub2_qual[l2].
             sub3_qual[l3].event_display,"{endb}"," ",pt_transfer->form_qual[l].sub1_qual[l1].
             sub2_qual[l2].sub3_qual[l3].event_result), output_display = replace(output_display,char(
              13)," "), output_display = replace(output_display,char(10)," ")
            IF (textlen(trim(output_display,3)) > 100)
             tempstring = trim(output_display,3), xcol = 70, wrapcol = 100,
             line_wrap
            ELSEIF (textlen(trim(output_display,3)) > 0)
             xcol = 70, row + 1,
             CALL print(calcpos(xcol,ycol)),
             output_display, ycol = (ycol+ 12), row + 1
            ENDIF
            IF ((pt_transfer->form_qual[l].sub1_qual[l1].sub2_qual[l2].sub3_qual[l3].event_comp_cd >
            0))
             blob_contents = pt_transfer->form_qual[l].sub1_qual[l1].sub2_qual[l2].sub3_qual[l3].
             event_comm, compression_cd = pt_transfer->form_qual[l].sub1_qual[l1].sub2_qual[l2].
             sub3_qual[l3].event_comp_cd, blob_type = "form_comment",
             print_blob_comment_report, new_blob_contents = trim(blobout2,3)
             IF (trim(new_blob_contents,3) > " ")
              new_blob_contents = concat("{u}Result Comment{endu}: ",trim(new_blob_contents,3))
              IF (size(trim(new_blob_contents,3)) > 100)
               tempstring = trim(new_blob_contents,3), eol = size(tempstring), xcol = 75,
               wrapcol = 100, line_wrap
              ELSE
               IF (ycol > 725)
                BREAK
               ENDIF
               output_display1 = trim(new_blob_contents,3), xcol = 75, row + 1,
               CALL print(calcpos(xcol,ycol)), output_display1, ycol = (ycol+ 12)
              ENDIF
             ENDIF
            ENDIF
            FOR (l4 = 1 TO pt_transfer->form_qual[l].sub1_qual[l1].sub2_qual[l2].sub3_qual[l3].
            sub4_cnt)
              output_display = "", output_display1 = "", output_display2 = ""
              IF (ycol > 725)
               BREAK
              ENDIF
              output_display = concat("{b}",pt_transfer->form_qual[l].sub1_qual[l1].sub2_qual[l2].
               sub3_qual[l3].sub4_qual[l4].event_display,"{endb}"," ",pt_transfer->form_qual[l].
               sub1_qual[l1].sub2_qual[l2].sub3_qual[l3].sub4_qual[l4].event_result), output_display
               = replace(output_display,char(13)," "), output_display = replace(output_display,char(
                10)," ")
              IF (textlen(trim(output_display,3)) > 100)
               tempstring = trim(output_display,3), xcol = 80, wrapcol = 100,
               line_wrap
              ELSEIF (textlen(trim(output_display,3)) > 0)
               xcol = 80, row + 1,
               CALL print(calcpos(xcol,ycol)),
               output_display, ycol = (ycol+ 12), row + 1
              ENDIF
              IF ((pt_transfer->form_qual[l].sub1_qual[l1].sub2_qual[l2].sub3_qual[l3].sub4_qual[l4].
              event_comp_cd > 0))
               blob_contents = pt_transfer->form_qual[l].sub1_qual[l1].sub2_qual[l2].sub3_qual[l3].
               sub4_qual[l4].event_comm, compression_cd = pt_transfer->form_qual[l].sub1_qual[l1].
               sub2_qual[l2].sub3_qual[l3].sub4_qual[l4].event_comp_cd, blob_type = "form_comment",
               print_blob_comment_report, new_blob_contents = trim(blobout2,3)
               IF (trim(new_blob_contents,3) > " ")
                new_blob_contents = concat("{u}Result Comment{endu}: ",trim(new_blob_contents,3))
                IF (size(trim(new_blob_contents,3)) > 100)
                 tempstring = trim(new_blob_contents,3), eol = size(tempstring), xcol = 85,
                 wrapcol = 100, xcol = 30, ycol = (ycol+ 12),
                 line_wrap
                ELSE
                 IF (ycol > 725)
                  BREAK
                 ENDIF
                 output_display1 = trim(new_blob_contents,3), xcol = 85, row + 1,
                 CALL print(calcpos(xcol,ycol)), output_display1, ycol = (ycol+ 12)
                ENDIF
               ENDIF
              ENDIF
            ENDFOR
          ENDFOR
        ENDFOR
      ENDFOR
      ycol = (ycol+ 12), row + 1
    ENDFOR
   ELSE
    xcol = 30, row + 1,
    CALL print(calcpos(xcol,ycol)),
    "{b}No Nutrition Form results found on visit.{endb}", ycol = (ycol+ 12), row + 1,
    xcol = 30, row + 1,
    CALL print(calcpos(xcol,ycol)),
    "{b}No Assessment or Treatment Form results found on visit.{endb}", ycol = (ycol+ 12), row + 1
   ENDIF
  FOOT PAGE
   ycol = 750, xcol = 300, row + 1,
   CALL print(calcpos(xcol,ycol)), "{f/0}{cpi/14}{endb}Page:", curpage
  WITH dio = postscript, maxrow = 800, maxcol = 800,
   check
 ;end select
#exit_script
END GO
