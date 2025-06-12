CREATE PROGRAM edw_create_orders_file:dba
 DECLARE iorder_count = i4 WITH protect, constant(size(edw_orders->qual,5))
 DECLARE patient_loc_facility_sk = vc WITH protect, noconstant("")
 DECLARE subject_area_flg = vc WITH protect, noconstant("")
 DECLARE interface_dup_flg = vc WITH protect, noconstant(" ")
 DECLARE getint_dup_flg(cur_flg=i2,loc_fac=vc,cur_facilities=vc) = vc WITH public
 SUBROUTINE getint_dup_flg(cur_flg,loc_fac,cur_facilities)
   DECLARE loc_fac1 = vc WITH protect, constant(concat(" ",loc_fac,","))
   DECLARE loc_fac2 = vc WITH protect, constant(concat(",",loc_fac," "))
   DECLARE loc_fac3 = vc WITH protect, constant(concat(",",loc_fac,","))
   IF (cur_flg=2
    AND ((findstring(loc_fac1,cur_facilities)) OR (((findstring(loc_fac2,cur_facilities)) OR (
   findstring(loc_fac3,cur_facilities))) )) )
    RETURN("1")
   ELSE
    RETURN("0")
   ENDIF
 END ;Subroutine
 IF (iorder_count > 0)
  SELECT INTO value(order_extractfile)
   FROM (dummyt d  WITH seq = iorder_count)
   DETAIL
    patient_loc_facility_sk = trim(cnvtstring(edw_orders->qual[d.seq].patient_loc_facility_sk,16)),
    subject_area_flg = trim(evaluate(edw_orders->qual[d.seq].subject_area_flg,0,blank_field,
      cnvtstring(edw_orders->qual[d.seq].subject_area_flg)))
    CASE (subject_area_flg)
     OF "1":
      interface_dup_flg = getint_dup_flg(micro_order_interface_flg,patient_loc_facility_sk,
       micro_order_interface_facilities)
     OF "2":
      interface_dup_flg = getint_dup_flg(pharm_order_interface_flg,patient_loc_facility_sk,
       pharm_order_interface_facilities)
     OF "3":
      interface_dup_flg = getint_dup_flg(gen_lab_order_interface_flg,patient_loc_facility_sk,
       gen_lab_order_interface_facilities)
     OF "4":
      interface_dup_flg = getint_dup_flg(anatomic_path_order_interface_flg,patient_loc_facility_sk,
       anatomic_path_order_interface_facilities)
    ENDCASE
    col 0, health_system_id, v_bar,
    health_system_source_id, v_bar,
    CALL print(trim(replace(edw_orders->qual[d.seq].encounter_nk,str_find,str_replace,3))),
    v_bar,
    CALL print(trim(cnvtstring(edw_orders->qual[d.seq].encounter_sk,16))), v_bar,
    CALL print(trim(cnvtstring(edw_orders->qual[d.seq].order_sk,16))), v_bar,
    CALL print(trim(cnvtstring(edw_orders->qual[d.seq].order_ordbl,16))),
    v_bar,
    CALL print(trim(replace(edw_orders->qual[d.seq].accession,str_find,str_replace,3),3)), v_bar,
    CALL print(trim(cnvtstring(edw_orders->qual[d.seq].activity_type_ref,16))), v_bar,
    CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_orders->qual[d.seq].canceled_dt_tm,0,
       cnvtdatetimeutc(edw_orders->qual[d.seq].canceled_dt_tm,3)),utc_timezone_index,
      "MM/DD/YYYY HH:mm:ss"))),
    v_bar,
    CALL print(trim(cnvtstring(edw_orders->qual[d.seq].canceled_tm_zn))), v_bar,
    CALL print(evaluate(datetimezoneformat(edw_orders->qual[d.seq].canceled_dt_tm,cnvtint(edw_orders
       ->qual[d.seq].canceled_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
     "1")), v_bar,
    CALL print(trim(cnvtstring(edw_orders->qual[d.seq].canceled_prsnl,16))),
    v_bar,
    CALL print(trim(replace(edw_orders->qual[d.seq].canceled_reason_ref,str_find,str_replace,3),3)),
    v_bar,
    CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_orders->qual[d.seq].completed_dt_tm,0,
       cnvtdatetimeutc(edw_orders->qual[d.seq].completed_dt_tm,3)),utc_timezone_index,
      "MM/DD/YYYY HH:mm:ss"))), v_bar,
    CALL print(trim(cnvtstring(edw_orders->qual[d.seq].completed_tm_zn))),
    v_bar,
    CALL print(evaluate(datetimezoneformat(edw_orders->qual[d.seq].completed_dt_tm,cnvtint(edw_orders
       ->qual[d.seq].completed_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
     "1")), v_bar,
    CALL print(trim(cnvtstring(edw_orders->qual[d.seq].completed_prsnl,16))), v_bar,
    CALL print(trim(replace(edw_orders->qual[d.seq].constant_ind,str_find,str_replace,3),3)),
    v_bar,
    CALL print(trim(replace(edw_orders->qual[d.seq].careset_flg,str_find,str_replace,3),3)), v_bar,
    CALL print(trim(cnvtstring(edw_orders->qual[d.seq].grouper_flg))), v_bar,
    CALL print(trim(cnvtstring(edw_orders->qual[d.seq].parent_order_sk,16))),
    v_bar,
    CALL print(trim(cnvtstring(edw_orders->qual[d.seq].top_parent_order_sk,16))), v_bar,
    CALL print(trim(cnvtstring(edw_orders->qual[d.seq].top_parent_ordbl,16))), v_bar,
    CALL print(trim(cnvtstring(edw_orders->qual[d.seq].latest_top_pat_ord_status_ref,16))),
    v_bar,
    CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_orders->qual[d.seq].
       requested_start_dt_tm,0,cnvtdatetimeutc(edw_orders->qual[d.seq].requested_start_dt_tm,3)),
      utc_timezone_index,"MM/DD/YYYY HH:mm:ss"))), v_bar,
    CALL print(trim(cnvtstring(edw_orders->qual[d.seq].requested_start_tm_zn))), v_bar,
    CALL print(evaluate(datetimezoneformat(edw_orders->qual[d.seq].requested_start_dt_tm,cnvtint(
       edw_orders->qual[d.seq].requested_start_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
     "1")),
    v_bar,
    CALL print(trim(cnvtstring(edw_orders->qual[d.seq].dept_status_ref,16))), v_bar,
    CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_orders->qual[d.seq].discontinue_dt_tm,0,
       cnvtdatetimeutc(edw_orders->qual[d.seq].discontinue_dt_tm,3)),utc_timezone_index,
      "MM/DD/YYYY HH:mm:ss"))), v_bar,
    CALL print(trim(cnvtstring(edw_orders->qual[d.seq].discontinue_tm_zn))),
    v_bar,
    CALL print(evaluate(datetimezoneformat(edw_orders->qual[d.seq].discontinue_dt_tm,cnvtint(
       edw_orders->qual[d.seq].discontinue_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
     "1")), v_bar,
    CALL print(trim(cnvtstring(edw_orders->qual[d.seq].discontinue_prsnl,16))), v_bar,
    CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_orders->qual[d.seq].
       discontinue_eff_dt_tm,0,cnvtdatetimeutc(edw_orders->qual[d.seq].discontinue_eff_dt_tm,3)),
      utc_timezone_index,"MM/DD/YYYY HH:mm:ss"))),
    v_bar,
    CALL print(trim(cnvtstring(edw_orders->qual[d.seq].discontinue_eff_tm_zn))), v_bar,
    CALL print(evaluate(datetimezoneformat(edw_orders->qual[d.seq].discontinue_eff_dt_tm,cnvtint(
       edw_orders->qual[d.seq].discontinue_eff_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
     "1")), v_bar,
    CALL print(trim(replace(edw_orders->qual[d.seq].discontinue_ind,str_find,str_replace,3),3)),
    v_bar,
    CALL print(trim(cnvtstring(edw_orders->qual[d.seq].discontinue_type_ref,16))), v_bar,
    CALL print(trim(replace(edw_orders->qual[d.seq].discontinue_reason_ref,str_find,str_replace,3),3)
    ), v_bar,
    CALL print(trim(replace(edw_orders->qual[d.seq].freq_type_flg,str_find,str_replace,3),3)),
    v_bar,
    CALL print(trim(replace(edw_orders->qual[d.seq].orderable_disp,str_find,str_replace,3),3)), v_bar,
    CALL print(trim(replace(edw_orders->qual[d.seq].incomplete_order_ind,str_find,str_replace,3),3)),
    v_bar,
    CALL print(trim(replace(edw_orders->qual[d.seq].interval_ind,str_find,str_replace,3),3)),
    v_bar,
    CALL print(trim(replace(edw_orders->qual[d.seq].last_action_sequence,str_find,str_replace,3),3)),
    v_bar,
    CALL print(trim(replace(edw_orders->qual[d.seq].need_doctor_cosign_flg,str_find,str_replace,3),3)
    ), v_bar,
    CALL print(trim(replace(edw_orders->qual[d.seq].need_nurse_review_ind,str_find,str_replace,3),3)),
    v_bar,
    CALL print(trim(replace(edw_orders->qual[d.seq].need_physician_validate_flg,str_find,str_replace,
      3),3)), v_bar,
    CALL print(trim(replace(edw_orders->qual[d.seq].need_rx_verify_flg,str_find,str_replace,3),3)),
    v_bar,
    CALL print(trim(cnvtstring(edw_orders->qual[d.seq].last_order_status_ref,16))),
    v_bar,
    CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_orders->qual[d.seq].
       last_order_status_dt_tm,0,cnvtdatetimeutc(edw_orders->qual[d.seq].last_order_status_dt_tm,3)),
      utc_timezone_index,"MM/DD/YYYY HH:mm:ss"))), v_bar,
    CALL print(trim(cnvtstring(edw_orders->qual[d.seq].last_order_status_tm_zn))), v_bar,
    CALL print(evaluate(datetimezoneformat(edw_orders->qual[d.seq].last_order_status_dt_tm,cnvtint(
       edw_orders->qual[d.seq].last_order_status_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
     "1")),
    v_bar,
    CALL print(trim(cnvtstring(edw_orders->qual[d.seq].last_order_status_prsnl,16))), v_bar,
    CALL print(trim(replace(edw_orders->qual[d.seq].orig_order_convs_sequence,str_find,str_replace,3),
     3)), v_bar,
    CALL print(trim(replace(edw_orders->qual[d.seq].orig_order_flg,str_find,str_replace,3),3)),
    v_bar,
    CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_orders->qual[d.seq].order_dt_tm,0,
       cnvtdatetimeutc(edw_orders->qual[d.seq].order_dt_tm,3)),utc_timezone_index,
      "MM/DD/YYYY HH:mm:ss"))), v_bar,
    CALL print(trim(cnvtstring(edw_orders->qual[d.seq].order_tm_zn))), v_bar,
    CALL print(evaluate(datetimezoneformat(edw_orders->qual[d.seq].order_dt_tm,cnvtint(edw_orders->
       qual[d.seq].order_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
     "1")),
    v_bar,
    CALL print(trim(cnvtstring(edw_orders->qual[d.seq].orig_communication_ref,16))), v_bar,
    CALL print(trim(cnvtstring(edw_orders->qual[d.seq].order_doc_prsnl,16))), v_bar,
    CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_orders->qual[d.seq].
       first_doc_cosign_dt_tm,0,cnvtdatetimeutc(edw_orders->qual[d.seq].first_doc_cosign_dt_tm,3)),
      utc_timezone_index,"MM/DD/YYYY HH:mm:ss"))),
    v_bar,
    CALL print(trim(cnvtstring(edw_orders->qual[d.seq].first_doc_cosign_tm_zn))), v_bar,
    CALL print(evaluate(datetimezoneformat(edw_orders->qual[d.seq].first_doc_cosign_dt_tm,cnvtint(
       edw_orders->qual[d.seq].first_doc_cosign_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
     "1")), v_bar,
    CALL print(trim(cnvtstring(edw_orders->qual[d.seq].first_cosign_doc_prsnl,16))),
    v_bar,
    CALL print(trim(cnvtstring(edw_orders->qual[d.seq].patient_loc_building_sk,16))), v_bar,
    CALL print(patient_loc_facility_sk), v_bar,
    CALL print(trim(cnvtstring(edw_orders->qual[d.seq].patient_loc_nurse_unit_sk,16))),
    v_bar,
    CALL print(trim(cnvtstring(edw_orders->qual[d.seq].patient_loc_room_sk,16))), v_bar,
    CALL print(trim(cnvtstring(edw_orders->qual[d.seq].patient_loc_bed_sk,16))), v_bar,
    CALL print(trim(cnvtstring(edw_orders->qual[d.seq].pathway_catalog_sk,16))),
    v_bar,
    CALL print(trim(cnvtstring(edw_orders->qual[d.seq].person_sk,16))), v_bar,
    CALL print(trim(replace(edw_orders->qual[d.seq].priority,str_find,str_replace,3),3)), v_bar,
    CALL print(trim(replace(edw_orders->qual[d.seq].prn_ind,str_find,str_replace,3),3)),
    v_bar, "0", v_bar,
    CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_orders->qual[d.seq].projected_stop_dt_tm,
       0,cnvtdatetimeutc(edw_orders->qual[d.seq].projected_stop_dt_tm,3)),utc_timezone_index,
      "MM/DD/YYYY HH:mm:ss"))), v_bar,
    CALL print(trim(cnvtstring(edw_orders->qual[d.seq].projected_stop_tm_zn))),
    v_bar,
    CALL print(evaluate(datetimezoneformat(edw_orders->qual[d.seq].projected_stop_dt_tm,cnvtint(
       edw_orders->qual[d.seq].projected_stop_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
     "1")), v_bar,
    CALL print(trim(replace(edw_orders->qual[d.seq].reporting_priority_ref,str_find,str_replace,3),3)
    ), v_bar,
    CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_orders->qual[d.seq].resume_eff_dt_tm,0,
       cnvtdatetimeutc(edw_orders->qual[d.seq].resume_eff_dt_tm,3)),utc_timezone_index,
      "MM/DD/YYYY HH:mm:ss"))),
    v_bar,
    CALL print(trim(cnvtstring(edw_orders->qual[d.seq].resume_eff_tm_zn))), v_bar,
    CALL print(evaluate(datetimezoneformat(edw_orders->qual[d.seq].resume_eff_dt_tm,cnvtint(
       edw_orders->qual[d.seq].resume_eff_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
     "1")), v_bar,
    CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_orders->qual[d.seq].soft_stop_dt_tm,0,
       cnvtdatetimeutc(edw_orders->qual[d.seq].soft_stop_dt_tm,3)),utc_timezone_index,
      "MM/DD/YYYY HH:mm:ss"))),
    v_bar,
    CALL print(trim(cnvtstring(edw_orders->qual[d.seq].soft_stop_tm_zn))), v_bar,
    CALL print(evaluate(datetimezoneformat(edw_orders->qual[d.seq].soft_stop_dt_tm,cnvtint(edw_orders
       ->qual[d.seq].soft_stop_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
     "1")), v_bar,
    CALL print(trim(cnvtstring(edw_orders->qual[d.seq].stop_type_ref,16))),
    v_bar,
    CALL print(trim(replace(edw_orders->qual[d.seq].suspend_ind,str_find,str_replace,3),3)), v_bar,
    CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_orders->qual[d.seq].suspend_eff_dt_tm,0,
       cnvtdatetimeutc(edw_orders->qual[d.seq].suspend_eff_dt_tm,3)),utc_timezone_index,
      "MM/DD/YYYY HH:mm:ss"))), v_bar,
    CALL print(trim(cnvtstring(edw_orders->qual[d.seq].suspend_eff_tm_zn))),
    v_bar,
    CALL print(evaluate(datetimezoneformat(edw_orders->qual[d.seq].suspend_eff_dt_tm,cnvtint(
       edw_orders->qual[d.seq].suspend_eff_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
     "1")), v_bar,
    CALL print(trim(replace(edw_orders->qual[d.seq].template_order_flg,str_find,str_replace,3),3)),
    v_bar,
    CALL print(trim(cnvtstring(edw_orders->qual[d.seq].is_template_flg))),
    v_bar,
    CALL print(trim(cnvtstring(edw_orders->qual[d.seq].template_order_sk,16))), v_bar,
    CALL print(trim(cnvtstring(edw_orders->qual[d.seq].template_ordbl,16))), v_bar,
    CALL print(trim(cnvtstring(edw_orders->qual[d.seq].template_ord_latest_status_ref,16))),
    v_bar, "3", v_bar,
    extract_dt_tm_fmt, v_bar,
    CALL print(trim(edw_orders->qual[d.seq].active_ind)),
    v_bar,
    CALL print(subject_area_flg), v_bar,
    CALL print(trim(interface_dup_flg)), v_bar,
    CALL print(trim(evaluate(edw_orders->qual[d.seq].patient_loc_bed_sk,0.0,evaluate(edw_orders->
       qual[d.seq].patient_loc_room_sk,0.0,evaluate(edw_orders->qual[d.seq].patient_loc_nurse_unit_sk,
        0.0,evaluate(edw_orders->qual[d.seq].patient_loc_building_sk,0.0,evaluate(edw_orders->qual[d
          .seq].patient_loc_facility_sk,0.0,"0",cnvtstring(edw_orders->qual[d.seq].
           patient_loc_facility_sk,16)),cnvtstring(edw_orders->qual[d.seq].patient_loc_building_sk,16
          )),cnvtstring(edw_orders->qual[d.seq].patient_loc_nurse_unit_sk,16)),cnvtstring(edw_orders
        ->qual[d.seq].patient_loc_room_sk,16)),cnvtstring(edw_orders->qual[d.seq].patient_loc_bed_sk,
       16)))),
    v_bar,
    CALL print(trim(cnvtstring(edw_orders->qual[d.seq].product_item,16))), v_bar,
    CALL print(trim(cnvtstring(edw_orders->qual[d.seq].restrict_autoverified_ind))), v_bar,
    CALL print(trim(cnvtstring(edw_orders->qual[d.seq].last_updt_provider_prsnl,16))),
    v_bar,
    CALL print(trim(cnvtstring(edw_orders->qual[d.seq].ad_hoc_order_flg))), v_bar,
    CALL print(trim(cnvtstring(edw_orders->qual[d.seq].frequency_sk,16))), v_bar,
    CALL print(trim(replace(edw_orders->qual[d.seq].orderable_ft_disp,str_find,str_replace,3),3)),
    v_bar,
    CALL print(trim(replace(edw_orders->qual[d.seq].orderable_mnemonic,str_find,str_replace,3),3)),
    v_bar,
    CALL print(trim(cnvtstring(edw_orders->qual[d.seq].sch_state_ref,16))), v_bar,
    CALL print(trim(cnvtstring(edw_orders->qual[d.seq].sch_appointment_sk,16))),
    v_bar, v_bar, v_bar,
    v_bar, v_bar, v_bar,
    v_bar, v_bar, v_bar,
    CALL print(trim(edw_orders->qual[d.seq].need_rx_clin_review_flg)), v_bar,
    CALL print(trim(cnvtstring(edw_orders->qual[d.seq].protocol_order_id,16))),
    v_bar,
    CALL print(trim(cnvtstring(edw_orders->qual[d.seq].catalog_type_cd,16))), v_bar,
    CALL print(trim(cnvtstring(edw_orders->qual[d.seq].catalog_cd,16))), v_bar,
    CALL print(trim(cnvtstring(edw_orders->qual[d.seq].group_order_cd,16))),
    v_bar,
    CALL print(trim(cnvtstring(edw_orders->qual[d.seq].link_order_cd,16))), v_bar,
    CALL print(trim(replace(edw_orders->qual[d.seq].clinical_display_line,str_find,str_replace,3),3)),
    v_bar,
    CALL print(trim(cnvtstring(edw_orders->qual[d.seq].contributor_system_cd,16))),
    v_bar,
    CALL print(trim(cnvtstring(edw_orders->qual[d.seq].active_status_prsnl,16))), v_bar,
    CALL print(trim(cnvtstring(edw_orders->qual[d.seq].orderable_type_flag,16))), v_bar,
    CALL print(trim(cnvtstring(edw_orders->qual[d.seq].dcp_clin_cat_cd,16))),
    v_bar,
    CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_orders->qual[d.seq].active_status_dt_tm,
       0,cnvtdatetimeutc(edw_orders->qual[d.seq].active_status_dt_tm,3)),utc_timezone_index,
      "MM/DD/YYYY HH:mm:ss"))), v_bar,
    CALL print(trim(cnvtstring(edw_orders->qual[d.seq].order_status_reason_bit,16))), v_bar,
    CALL print(trim(cnvtstring(edw_orders->qual[d.seq].originating_encntr_sk,16))),
    v_bar, row + 1
   WITH noheading, nocounter, format = lfstream,
    maxcol = 2500, maxrow = 1, append
  ;end select
 ENDIF
 FREE RECORD edw_orders
 SET script_version = "019 08/15/19 mf025696"
END GO
