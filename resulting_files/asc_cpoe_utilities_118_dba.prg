CREATE PROGRAM asc_cpoe_utilities_118:dba
 PAINT
 IF (validate(isodbc,0)=0)
  EXECUTE cclseclogin
 ENDIF
 CALL video("R")
 CALL clear(1,1,80)
 CALL video("N")
 DECLARE cur_facility_cd = f8
 SET cur_facility_cd = 0
 DECLARE cur_facility_desc = vc
 SET cur_facility_desc = "All Facilities"
 DECLARE facility_selection(inc_val=i2) = f8
 DECLARE strip_str_quotes(start_str=vc) = vc
 DECLARE replace_pp_syn(old_syn_id=f8,old_syn_desc=vc) = null
 DECLARE replace_ivs_syn(old_syn_id=f8,old_syn_desc=vc) = null
 DECLARE replace_specific_ivs_syn(replace_syn_id=f8,new_syn_id=f8) = null
 DECLARE replace_specific_cs_syn(replace_syn_id=f8,new_syn_id=f8) = null
 DECLARE replace_specific_pp_syn(replace_syn_id=f8,new_syn_id=f8) = null
 DECLARE remap_form_prod(prd_item_id=f8,prd_desc=vc) = null
 DECLARE remap_syn_sent(syn_id=f8,syn_desc=vc) = null
 DECLARE cpoe_lookup_synsent(lookup_id=f8,lookup_desc=vc) = null
 DECLARE is_syn_in_favorites(inc_syn_id=f8) = i4
 DECLARE is_syn_in_folders(inc_syn_id=f8) = i4
 DECLARE is_syn_in_powerplans(inc_syn_id=f8) = i4
 DECLARE is_syn_in_careset(inc_syn_id=f8) = i4
 DECLARE is_syn_in_powerorders(inc_syn_id=f8) = i4
 DECLARE down_arrow(str1=vc) = null
 DECLARE up_arrow(strup=vc) = null
 DECLARE create_std_box(mxcnt=i2) = null
 DECLARE clear_screen(abc=i2) = null
 DECLARE dest_syn_id = f8
 DECLARE holdstr_desc = vc
 DECLARE ocknt = i4
 DECLARE ocmknt = i4
 DECLARE ocsmknt = i4
 DECLARE ocmkt = i4
 DECLARE prod_count = i4
 DECLARE ord_count = i4
 DECLARE dnumknt = i4
 DECLARE idknt = i4
 DECLARE txt = vc
 DECLARE txt2 = vc
 DECLARE tmp1 = i4
 DECLARE holdstr60 = c60
 DECLARE holdstr65 = c65
 DECLARE holdstr80 = c80
 DECLARE holdstr20 = c20
 DECLARE holdstr_r = c1
 DECLARE holdstr_a = c1
 DECLARE holdstr = c75
 DECLARE confirm = c1
 DECLARE commit_ind = i2
 DECLARE map_desc = vc
 DECLARE meds_task = f8 WITH constant(989989.0)
 DECLARE meds_applctx = f8 WITH constant(989989.0)
 DECLARE meds_id = f8 WITH constant(989989.0)
 DECLARE mdmknt = i4 WITH noconstant(0)
 DECLARE ln = c78
 DECLARE ln120 = c120
 DECLARE change_ind = i2 WITH noconstant(0)
 DECLARE file_stat = i2 WITH noconstant(0)
 DECLARE csv_file = vc
 DECLARE m_dnum = vc
 DECLARE m_cnum = i4
 DECLARE m_mdid = f8
 DECLARE m_mmdc_cki = vc
 DECLARE numscol = i4 WITH noconstant(75)
 DECLARE numsrow = i4 WITH noconstant(14)
 DECLARE srowoff = i4 WITH noconstant(6)
 DECLARE scoloff = i4 WITH noconstant(2)
 DECLARE arow = i4 WITH noconstant(0)
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE maxcnt = i4 WITH noconstant(0)
 DECLARE ocsknt = i4 WITH noconstant(0)
 DECLARE v500_tables = i2 WITH noconstant(0)
 DECLARE new_form_model = i2 WITH noconstant(0)
 DECLARE multum_v500_ref = i2
 DECLARE multum_v500 = i2
 DECLARE mltm_v500 = i2
 DECLARE meddef_cd = f8
 DECLARE ndc_cd = f8
 DECLARE item_cd = f8
 DECLARE loop_cnt = i4
 DECLARE ord_loc_string = vc
 DECLARE syn_loc_string = vc
 DECLARE prod_loc_string = vc
 DECLARE line = vc
 SET multum_v500_ref = 0
 SET multum_v500 = 1
 SET mltm_v500 = 2
 SET confirm = " "
 SET commit_ind = 0
 SET ln = fillstring(78,"-")
 SET ln120 = fillstring(120,"-")
 SET line = "                                                                                "
 SET cpharm = uar_get_code_by("MEANING",6000,"PHARMACY")
 SET crxm = uar_get_code_by("MEANING",6011,"RXMNEMONIC")
 SET corder = uar_get_code_by("MEANING",6003,"ORDER")
 CALL clear_screen(0)
 CALL text(2,3,"                                                                 ")
 CALL text(3,3," This is an unsupported and uncertified program which has been   ")
 CALL text(4,3," developed for internal Cerner Solution Center use only. It is   ")
 CALL text(5,3," not compatible with all levels of code and is not intended for  ")
 CALL text(6,3," distribution or general use.                                    ")
 CALL text(7,3,"                                                                 ")
 CALL text(15,3,"Continue? (Y/N) ")
 CALL text(15,63,"v1.18ab")
 CALL accept(15,20,"C;CU","Y"
  WHERE curaccept IN ("Y", "N"))
 CASE (curaccept)
  OF "Y":
   GO TO pick_mode
  OF "N":
   GO TO exit_program
 ENDCASE
#pick_mode
 CALL clear_screen(0)
 CALL video("R")
 CALL text(1,1,line)
 CALL text(1,1,"                                SC Meds Utilities                                  ")
 CALL text(3,1,"      PharmNet     ")
 CALL video("N")
 CALL text(4,2,"01 Extracts")
 CALL text(5,2,"02 Problem Audits")
 CALL text(6,2,"03 Utilities")
 CALL text(7,2,"04 Data Lookup")
 CALL video("R")
 CALL text(3,25,"      CareNet      ")
 CALL video("N")
 CALL text(4,26,"05 Problem Audits")
 CALL text(5,26,"06 Utilities")
 CALL video("R")
 CALL text(3,49,"       POC         ")
 CALL video("N")
 CALL text(4,50,"07 Extracts")
 CALL text(5,50,"08 Problem Audits")
 CALL text(6,50,"09 Utilities")
 CALL video("R")
 CALL text(10,1,"      Common       ")
 CALL video("N")
 CALL text(11,2,"10 CareSet / PowerPlan extracts")
 CALL text(12,2,"11 CareSet / PowerPlan audits")
 CALL text(13,2,"12 Utilities")
 CALL video("N")
 CALL text(19,2,"13 Selected facility:")
 CALL video("R")
 IF (cur_facility_cd > 0)
  CALL text(19,25,trim(cur_facility_desc))
 ELSE
  CALL text(19,25,"All Facilities")
 ENDIF
 CALL text(21,0,"14 Exit program")
 CALL text(23,0,"Choose an option:")
 CALL accept(23,19,"99;",14
  WHERE curaccept IN (1, 2, 3, 4, 5,
  6, 7, 8, 9, 10,
  11, 12, 13, 14))
#restart
 CASE (curaccept)
  OF 1:
   GO TO pharm_extract_mode
  OF 2:
   GO TO pharm_problem_mode
  OF 3:
   GO TO pharm_utilities_mode
  OF 4:
   GO TO pharm_data_lookup_mode
  OF 5:
   GO TO care_problem_mode
  OF 6:
   GO TO care_utilities_mode
  OF 7:
   GO TO poc_extract_mode
  OF 8:
   GO TO poc_problem_mode
  OF 9:
   GO TO poc_utilities_mode
  OF 10:
   GO TO cs_pp_extract_mode
  OF 11:
   GO TO cs_pp_problem_mode
  OF 12:
   GO TO common_utilities_mode
  OF 13:
   EXECUTE FROM select_facility_sub TO select_facility_sub_exit
  OF 14:
   GO TO exit_program
 ENDCASE
 GO TO pick_mode
#pharm_extract_mode
 CALL clear_screen(0)
 CALL video("R")
 CALL text(1,1,line)
 CALL text(1,1,"                           SC Meds Utilities - Extracts                            ")
 CALL text(3,1,"  Extracts  ")
 CALL video("N")
 CALL text(5,2,"01 Med Order Catalog Extract: limit to PowerOrders accessible synonyms")
 CALL text(6,2,"02 Med Order Catalog Extract: full")
 CALL text(8,2,"03 Med Order Sentence Extract: inpatient")
 CALL text(9,2,"04 Med Order Sentence Extract: inpatient, PowerOrders-accessible synonyms")
 CALL text(10,2,"05 Med Order Sentence Extract: outpatient")
 CALL text(12,2,"06 Product to Orderable linking / RX Mnemonic RX Masks & OEF's")
 CALL text(13,2,"07 Product ORDERED AS synonyms")
 CALL text(15,2,"08 IV Sets: IV Builder (CPOE) sets")
 CALL text(16,2,"09 IV Sets: PharmNet formulary")
 CALL text(18,2,"10 Phase X: Summary of orders by product")
 CALL text(19,2,"11 Phase X: Summary of orders by MMDC")
 CALL text(21,1,"12 Main menu")
 CALL text(23,1,"Choose an option:")
 CALL accept(23,19,"99;",12
  WHERE curaccept IN (1, 2, 3, 4, 5,
  6, 7, 8, 9, 10,
  11, 12))
 CASE (curaccept)
  OF 1:
   EXECUTE FROM syn_vv_on_output TO syn_vv_on_output_exit
  OF 2:
   EXECUTE FROM asc_aud_pha_ocs_output TO asc_aud_pha_ocs_output_exit
  OF 3:
   EXECUTE FROM asc_med_os_extract TO asc_med_os_extract_exit
  OF 4:
   EXECUTE FROM asc_med_os_vv_extract TO asc_med_os_vv_extract_exit
  OF 5:
   EXECUTE FROM asc_med_op_os_extract TO asc_med_op_os_extract_exit
  OF 6:
   EXECUTE FROM asc_prdct_rxmnem_output TO asc_prdct_rxmnem_output_exit
  OF 7:
   EXECUTE FROM asc_prdct_ordas_output TO asc_prdct_ordas_output_exit
  OF 8:
   EXECUTE FROM cpoe_ivset_output TO cpoe_ivset_output_exit
  OF 9:
   EXECUTE FROM form_ivset_output TO form_ivset_output_exit
  OF 10:
   EXECUTE FROM phasex_sent_by_prod TO phasex_sent_by_prod_exit
  OF 11:
   EXECUTE FROM phasex_sent_by_mmdc TO phasex_sent_by_mmdc_exit
  OF 12:
   GO TO pick_mode
 ENDCASE
 GO TO pharm_extract_mode
#pharm_problem_mode
 CALL clear_screen(0)
 CALL video("R")
 CALL text(1,1,line)
 CALL text(1,1,"                        SC Meds Utilities - Problem Audits                         ")
 CALL text(3,1,"  Reports for the medication order catalog  ")
 CALL video("N")
 CALL text(4,2,"01 PowerOrders-accessible synonyms without order sentences")
 CALL text(5,2,"02 PowerOrders-accessible synonyms with no potential product linking")
 CALL text(6,2,"03 PowerOrders-accessible synonyms missing RX Masks or OEFs")
 CALL text(7,2,"04 PowerOrders-accessible synonyms/orderables missing clinical category code")
 CALL text(8,2,"05 PowerOrders-accessible synonyms missing CKI values (DRC)")
 CALL text(9,2,"06 PowerOrders-accessible synonyms with no product linking")
 CALL text(10,2,"07 Medication orderables which do not require Rx verify")
 CALL text(11,2,"08 Medication orderables with duplicate DNUM CKI values")
 CALL video("R")
 CALL text(13,1,"  Reports for formulary products  ")
 CALL video("N")
 CALL text(14,2,"09 RX Mnemonic synonyms missing RX Masks or OEFS")
 CALL text(15,2,"10 Products which have no links to PowerOrders-accessible synonyms")
 CALL text(16,2,"11 Products which have no ORDERED AS synonym defined")
 CALL video("R")
 CALL text(18,1,"  Reports for medication order sentences  ")
 CALL video("N")
 CALL text(19,2,"12 Sentences containing incompatible OEF fields")
 CALL text(21,1,"13 Main menu")
 CALL text(23,1,"Choose an option:")
 CALL accept(23,19,"99;",13
  WHERE curaccept IN (1, 2, 3, 4, 5,
  6, 7, 8, 9, 10,
  11, 12, 13))
 CASE (curaccept)
  OF 1:
   EXECUTE FROM syn_no_sent TO syn_no_sent_exit
  OF 2:
   EXECUTE FROM syn_no_prod TO syn_no_prod_exit
  OF 3:
   EXECUTE FROM syn_no_rxmask_oef TO syn_no_rxmask_oef_exit
  OF 4:
   EXECUTE FROM missing_clin_cat TO missing_clin_cat_exit
  OF 5:
   EXECUTE FROM syn_no_cki TO syn_no_cki_exit
  OF 6:
   EXECUTE FROM syn_no_link TO syn_no_link_exit
  OF 7:
   EXECUTE FROM med_no_rx_verify TO med_no_rx_verify_exit
  OF 8:
   EXECUTE FROM med_dup_oc_cki TO med_dup_oc_cki_exit
  OF 9:
   EXECUTE FROM rxm_no_rxmask_oef TO rxm_no_rxmask_oef_exit
  OF 10:
   EXECUTE FROM prod_no_syn_links TO prod_no_syn_links_exit
  OF 11:
   EXECUTE FROM prod_no_ordas_syn TO prod_no_ordas_syn_exit
  OF 12:
   EXECUTE FROM sent_oef_incompat TO sent_oef_incompat_exit
  OF 13:
   GO TO pick_mode
 ENDCASE
 GO TO pharm_problem_mode
#pharm_utilities_mode
 CALL clear_screen(0)
 CALL video("R")
 CALL text(1,1,line)
 CALL text(1,1,"                          SC Meds Utilities - Utilities                            ")
 CALL text(3,1,"  Utilities  ")
 CALL video("N")
 CALL text(5,2,"01 Remap formulary product to new orderable")
 CALL text(6,2,"02 Remap synonym & related order sentences to new orderable")
 CALL text(7,2,"03 Change OEF for medication synonym & associated sentences")
 CALL text(9,2,"04 Set RX mnemonic OEF's, based on RX mask")
 CALL text(10,2,"05 Set clinical categories for medications, based on primary synonym RX mask")
 CALL text(11,2,"06 Set ORDERED AS synonyms (prototype)")
 CALL text(12,2,"07 Sequence (inpatient) medication sentences")
 CALL text(14,2,"08 Fix MULTIPLE_ORD_SENT_IND issue")
 CALL text(16,2,"09 Update order sentences for deletion")
 CALL text(18,2,"10 Lock (on modify) all required/optional fields in medication OEF's")
 CALL text(19,2,"11 Unlock (on modify) all fields in medication OEF's")
 CALL text(21,1,"12 Main menu")
 CALL text(23,1,"Choose an option:")
 CALL accept(23,19,"99;",12
  WHERE curaccept IN (1, 2, 3, 4, 5,
  6, 7, 8, 9, 10,
  11, 12))
 CASE (curaccept)
  OF 1:
   EXECUTE FROM remap_form_item TO remap_form_item_exit
  OF 2:
   EXECUTE FROM remap_syn_sent TO remap_syn_sent_exit
  OF 3:
   EXECUTE FROM replace_syn_oef TO replace_syn_oef_exit
  OF 4:
   EXECUTE FROM asc_assign_rxmnem_oef TO asc_assign_rxmnem_oef_exit
  OF 5:
   EXECUTE FROM asc_set_med_clincat_cds TO asc_set_med_clincat_cds_exit
  OF 6:
   EXECUTE FROM asc_set_ordas_syn TO asc_set_ordas_syn_exit
  OF 7:
   EXECUTE FROM asc_med_os_seq TO asc_med_os_seq_exit
  OF 8:
   EXECUTE FROM asc_fix_mul_sent TO asc_fix_mul_sent_exit
  OF 9:
   EXECUTE FROM upd_sent_for_del TO upd_sent_for_del_exit
  OF 10:
   EXECUTE FROM lock_med_oef_fields TO lock_med_oef_fields_exit
  OF 11:
   EXECUTE FROM unlock_med_oef_fields TO unlock_med_oef_fields_exit
  OF 12:
   GO TO pick_mode
 ENDCASE
 GO TO pharm_utilities_mode
#pharm_data_lookup_mode
 CALL clear_screen(0)
 CALL video("R")
 CALL text(1,1,line)
 CALL text(1,1,"                         SC Meds Utilities - Data Lookup                           ")
 CALL text(3,1,"  Data Lookup  ")
 CALL video("N")
 CALL text(5,2,"01 Summary of PowerOrders-accessible synonyms & sentences (by product)")
 CALL text(6,2,"02 Summary of PowerOrders-accessible synonyms & sentences (by orderable)")
 CALL text(8,2,"03 Summary of medication synonym use in CPOE")
 CALL text(10,2,"04 Auto-Product-Selection (APS), Auto-Product-Verification (APV) Audit")
 CALL text(12,2,"05 Order summary by MMDC")
 CALL text(14,2,"06 Medication order report, last x days")
 CALL text(21,1,"07 Main menu")
 CALL text(23,1,"Choose an option:")
 CALL accept(23,19,"99;",7
  WHERE curaccept IN (1, 2, 3, 4, 5,
  6, 7))
 CASE (curaccept)
  OF 1:
   EXECUTE FROM cpoe_lookup_by_prod TO cpoe_lookup_by_prod_exit
  OF 2:
   EXECUTE FROM cpoe_lookup_by_ord TO cpoe_lookup_by_ord_exit
  OF 3:
   EXECUTE FROM syn_lookup_cpoe_use TO syn_lookup_cpoe_use_exit
  OF 4:
   EXECUTE FROM asc_aps_avs_audit TO asc_aps_avs_audit_exit
  OF 5:
   EXECUTE FROM ord_sum_by_mmdc TO ord_sum_by_mmdc_exit
  OF 6:
   EXECUTE FROM med_orders_last_x_days TO med_orders_last_x_days_exit
  OF 7:
   GO TO pick_mode
 ENDCASE
 GO TO pharm_data_lookup_mode
#care_problem_mode
 CALL clear_screen(0)
 CALL video("R")
 CALL text(1,1,line)
 CALL text(1,1,"                        SC Meds Utilities - Problem Audits                         ")
 CALL text(3,1,"  Reports for event codes  ")
 CALL video("N")
 CALL text(5,2,"01 Medication orderables missing event codes")
 CALL text(21,1,"02 Main menu")
 CALL text(23,1,"Choose an option:")
 CALL accept(23,19,"99;",2
  WHERE curaccept IN (1, 2))
 CASE (curaccept)
  OF 1:
   EXECUTE FROM meds_no_event_code TO meds_no_event_code_exit
  OF 2:
   GO TO pick_mode
 ENDCASE
 GO TO care_problem_mode
#care_utilities_mode
 CALL clear_screen(0)
 CALL video("R")
 CALL text(1,1,line)
 CALL text(1,1,"                          SC Meds Utilities - Utilities                            ")
 CALL text(3,1,"  Utilities  ")
 CALL video("N")
 CALL text(5,2,"01 Medication orderables with additional charting elements")
 CALL text(6,2,"02 Medication orderables with associated PRN response")
 CALL text(7,2,"03 Medication synoyms with nurse witness requirements")
 CALL text(21,1,"04 Main menu")
 CALL text(23,1,"Choose an option:")
 CALL accept(23,19,"99;",4
  WHERE curaccept IN (1, 2, 3, 4))
 CASE (curaccept)
  OF 1:
   EXECUTE FROM med_charting_elem TO med_charting_elem_lookup
  OF 2:
   EXECUTE FROM med_prn_resp TO med_prn_resp_exit
  OF 3:
   EXECUTE FROM med_nurse_wit TO med_nurse_wit_exit
  OF 4:
   GO TO pick_mode
 ENDCASE
 GO TO care_utilities_mode
#cs_pp_extract_mode
 CALL clear_screen(0)
 CALL video("R")
 CALL text(1,1,line)
 CALL text(1,1,"                           SC Meds Utilities - Extracts                            ")
 CALL text(3,1,"  Extracts for CareSets / PowerPlans  ")
 CALL video("N")
 CALL text(5,2,"01 CareSets - Medication extract (general)")
 CALL text(6,2,"02 CareSets - Medication sentences extract (detailed)")
 CALL text(7,2,"03 PowerPlans - Medication extract (general)")
 CALL text(8,2,"04 PowerPlans - Medication sentences extract (detailed)")
 CALL text(21,1,"05 Main menu")
 CALL text(23,1,"Choose an option:")
 CALL accept(23,19,"99;",5
  WHERE curaccept IN (1, 2, 3, 4, 5))
 CASE (curaccept)
  OF 1:
   EXECUTE FROM careset_extract TO careset_extract_exit
  OF 2:
   EXECUTE FROM careset_extract_csv TO careset_extract_csv_exit
  OF 3:
   EXECUTE FROM powerplan_extract TO powerplan_extract_exit
  OF 4:
   EXECUTE FROM powerplan_extract_csv TO powerplan_extract_csv_exit
  OF 5:
   GO TO pick_mode
 ENDCASE
 GO TO cs_pp_extract_mode
#cs_pp_problem_mode
 CALL clear_screen(0)
 CALL video("R")
 CALL text(1,1,line)
 CALL text(1,1,"                        SC Meds Utilities - Problem Audits                         ")
 CALL text(3,1,"  Reports for CareSets / PowerPlans  ")
 CALL video("N")
 CALL text(5,2,"01 CareSets - virtually-viewed-off medication synonyms")
 CALL text(6,2,"02 CareSets - medication synonyms with no potential product linking")
 CALL text(7,2,"03 CareSets - medication synonyms of a non-CPOE type")
 CALL text(9,2,"04 PowerPlans - virtually-viewed-off medication synonyms")
 CALL text(10,2,"05 PowerPlans - medication synonyms with no potential product linking")
 CALL text(11,2,"06 PowerPlans - medication synonyms of a non-CPOE type")
 CALL text(12,2,"07 PowerPlans - medications with a combo Rx Mask, no default defined")
 CALL text(21,1,"08 Main menu")
 CALL text(23,1,"Choose an option:")
 CALL accept(23,19,"99;",8
  WHERE curaccept IN (1, 2, 3, 4, 5,
  6, 7, 8))
 CASE (curaccept)
  OF 1:
   EXECUTE FROM careset_med_vvoff TO careset_med_vvoff_exit
  OF 2:
   EXECUTE FROM careset_med_noprod TO careset_med_noprod_exit
  OF 3:
   EXECUTE FROM careset_med_noncpoe TO careset_med_noncpoe_exit
  OF 4:
   EXECUTE FROM powerplan_med_vvoff TO powerplan_med_vvoff_exit
  OF 5:
   EXECUTE FROM powerplan_med_noprod TO powerplan_med_noprod_exit
  OF 6:
   EXECUTE FROM powerplan_med_noncpoe TO powerplan_med_noncpoe_exit
  OF 7:
   EXECUTE FROM powerplan_combo_rxmask TO powerplan_combo_rxmask_exit
  OF 8:
   GO TO pick_mode
 ENDCASE
 GO TO cs_pp_problem_mode
#common_utilities_mode
 CALL clear_screen(0)
 CALL video("R")
 CALL text(1,1,line)
 CALL text(1,1,"                          SC Meds Utilities - Utilities                             "
  )
 CALL text(3,1,"  Utilities  ")
 CALL video("N")
 CALL text(5,2,"01 Look up PREFMAINT preference values")
 CALL text(7,2,"02 Replace medication synonym in PowerPlans")
 CALL text(8,2,"03 Replace medication synonym in CareSets")
 CALL text(9,2,"04 Replace medication synonym in IV Sets")
 CALL text(21,1,"05 Main menu")
 CALL text(23,1,"Choose an option:")
 CALL accept(23,19,"99;",5
  WHERE curaccept IN (1, 2, 3, 4, 5))
 CASE (curaccept)
  OF 1:
   EXECUTE FROM prefmaint_lookup TO prefmaint_lookup_exit
  OF 2:
   EXECUTE FROM replace_plan_syn TO replace_plan_syn_exit
  OF 3:
   EXECUTE FROM replace_cs_syn TO replace_cs_syn_exit
  OF 4:
   EXECUTE FROM replace_ivs_syn TO replace_ivs_syn_exit
  OF 5:
   GO TO pick_mode
 ENDCASE
 GO TO common_utilities_mode
#poc_problem_mode
 CALL clear_screen(0)
 CALL video("R")
 CALL text(1,1,line)
 CALL text(1,1,"                        SC Meds Utilities - Problem Audits                         ")
 CALL text(3,1,"  Reports for POC linking  ")
 CALL video("N")
 CALL text(5,2,"01 RX Mnemonic synonyms with no product linking (all)")
 CALL text(6,2,"02 RX Mnemonic synonyms with no product linking (critical)")
 CALL text(21,1,"02 Main menu")
 CALL text(23,1,"Choose an option:")
 CALL accept(23,19,"99;",3
  WHERE curaccept IN (1, 2, 3))
 CASE (curaccept)
  OF 1:
   EXECUTE FROM rx_mnem_no_link TO rx_mnem_no_link_exit
  OF 2:
   EXECUTE FROM rx_mnem_no_link_crit TO rx_mnem_no_link_crit_exit
  OF 3:
   GO TO pick_mode
 ENDCASE
 GO TO poc_problem_mode
#poc_utilities_mode
 CALL clear_screen(0)
 CALL video("R")
 CALL text(1,1,line)
 CALL text(1,1,"                          SC Meds Utilities - Utilities                            ")
 CALL text(3,1,"  Utilities  ")
 CALL video("N")
 CALL text(5,2,"01 Set Rx Mnemonic / Product linking")
 CALL text(21,1,"02 Main menu")
 CALL text(23,1,"Choose an option:")
 CALL accept(23,19,"99;",2
  WHERE curaccept IN (1, 2))
 CASE (curaccept)
  OF 1:
   EXECUTE FROM set_rxm_poc_linking TO set_rxm_poc_linking_exit
  OF 2:
   GO TO pick_mode
 ENDCASE
 GO TO poc_utilities_mode
#poc_extract_mode
 CALL clear_screen(0)
 CALL video("R")
 CALL text(1,1,line)
 CALL text(1,1,"                           SC Meds Utilities - Extracts                            ")
 CALL text(3,1,"  Extracts  ")
 CALL video("N")
 CALL text(5,2,"01 Rx Mnemonic / Product linking extract")
 CALL text(21,1,"02 Main menu")
 CALL text(23,1,"Choose an option:")
 CALL accept(23,19,"99;",2
  WHERE curaccept IN (1, 2))
 CASE (curaccept)
  OF 1:
   EXECUTE FROM rxm_poc_linking_output TO rxm_poc_linking_output_exit
  OF 2:
   GO TO pick_mode
 ENDCASE
 GO TO poc_extract_mode
#select_facility_sub
 CALL video("N")
 CALL facility_selection(0)
#select_facility_sub_exit
#rx_mnem_no_link_crit
 CALL clear_screen(0)
 FREE RECORD product_list
 RECORD product_list(
   1 products[*]
     2 item_id = f8
     2 synonym_id = f8
     2 catalog_cd = f8
     2 form_cd = f8
     2 mmdc = vc
     2 strength_ind = i2
     2 poc_compare_string = vc
     2 critical_linking_flag = i2
 )
 SET cpharm = uar_get_code_by("MEANING",6000,"PHARMACY")
 SET cdesc = uar_get_code_by("MEANING",11000,"DESC")
 SET cinpatient = uar_get_code_by("MEANING",4500,"INPATIENT")
 SET csystem = uar_get_code_by("MEANING",4062,"SYSTEM")
 SET csystempkg = uar_get_code_by("MEANING",4062,"SYSPKGTYP")
 SET cdesc = uar_get_code_by("MEANING",11000,"DESC")
 SET crxm = uar_get_code_by("MEANING",6011,"RXMNEMONIC")
 SET csyspkgtyp = uar_get_code_by("MEANING",4062,"SYSPKGTYP")
 SET corderable = uar_get_code_by("MEANING",4063,"ORDERABLE")
 SELECT INTO "nl:"
  ocir.catalog_cd, ocir.item_id, ocir.synonym_id,
  md.cki, md.form_cd, form = uar_get_code_display(md.form_cd)
  FROM medication_definition md,
   item_definition id,
   med_def_flex mdf,
   order_catalog_item_r ocir,
   med_dispense mdisp,
   med_def_flex mdf2,
   med_flex_object_idx mfoi2
  PLAN (md
   WHERE md.item_id > 0
    AND md.med_type_flag=0
    AND md.form_cd > 0)
   JOIN (ocir
   WHERE ocir.item_id=md.item_id)
   JOIN (mdisp
   WHERE mdisp.item_id=md.item_id
    AND mdisp.flex_type_cd=csystempkg
    AND mdisp.pharmacy_type_cd=cinpatient)
   JOIN (id
   WHERE id.item_id=md.item_id
    AND id.active_ind=1)
   JOIN (mdf
   WHERE mdf.item_id=md.item_id
    AND mdf.flex_type_cd=csystem
    AND mdf.pharmacy_type_cd=cinpatient)
   JOIN (mdf2
   WHERE mdf2.item_id=ocir.item_id
    AND mdf2.flex_type_cd=csyspkgtyp
    AND mdf2.pharmacy_type_cd=cinpatient)
   JOIN (mfoi2
   WHERE mfoi2.med_def_flex_id=mdf2.med_def_flex_id
    AND mfoi2.flex_object_type_cd=corderable
    AND ((mfoi2.parent_entity_id=0) OR (mfoi2.parent_entity_id=cur_facility_cd)) )
  ORDER BY ocir.catalog_cd, md.cki, md.form_cd
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(product_list->products,cnt), product_list->products[cnt].item_id
    = ocir.item_id,
   product_list->products[cnt].synonym_id = ocir.synonym_id, product_list->products[cnt].catalog_cd
    = ocir.catalog_cd, product_list->products[cnt].mmdc = trim(md.cki),
   product_list->products[cnt].form_cd = md.form_cd
   IF (mdisp.strength > 0
    AND mdisp.strength_unit_cd > 0)
    product_list->products[cnt].strength_ind = 1
   ENDIF
   product_list->products[cnt].poc_compare_string = concat(trim(cnvtstring(ocir.catalog_cd)),", ",
    trim(cnvtstring(mdisp.strength))," ",trim(cnvtstring(mdisp.strength_unit_cd)),
    ", ",trim(cnvtstring(mdisp.volume))," ",trim(cnvtstring(mdisp.volume_unit_cd)))
  WITH nullreport
 ;end select
 SELECT INTO "nl:"
  item_id = product_list->products[d1.seq].item_id, compare_string = product_list->products[d1.seq].
  poc_compare_string
  FROM (dummyt d1  WITH seq = value(size(product_list->products,5))),
   (dummyt d2  WITH seq = value(size(product_list->products,5)))
  PLAN (d1)
   JOIN (d2
   WHERE (product_list->products[d1.seq].poc_compare_string=product_list->products[d2.seq].
   poc_compare_string)
    AND (product_list->products[d1.seq].item_id != product_list->products[d2.seq].item_id))
  ORDER BY product_list->products[d1.seq].poc_compare_string
  DETAIL
   product_list->products[d1.seq].critical_linking_flag = 1
  WITH nullreport
 ;end select
 SELECT
  ocs.synonym_id, ocs.item_id, primary = substring(1,60,oc.primary_mnemonic),
  product = substring(1,60,mi.value), rx_mnemonic = ocs.mnemonic
  FROM (dummyt d  WITH seq = value(size(product_list->products,5))),
   order_catalog_synonym ocs,
   order_catalog oc,
   med_identifier mi,
   item_definition id,
   med_def_flex mdf
  PLAN (d
   WHERE (product_list->products[d.seq].critical_linking_flag=1))
   JOIN (ocs
   WHERE (ocs.synonym_id=product_list->products[d.seq].synonym_id)
    AND ocs.mnemonic_type_cd=crxm
    AND  NOT (ocs.synonym_id IN (
   (SELECT DISTINCT
    synonym_id
    FROM synonym_item_r))))
   JOIN (oc
   WHERE oc.catalog_cd=ocs.catalog_cd
    AND oc.catalog_type_cd=cpharm
    AND oc.orderable_type_flag IN (0, 1))
   JOIN (mi
   WHERE mi.item_id=ocs.item_id
    AND mi.med_identifier_type_cd=cdesc
    AND mi.pharmacy_type_cd=cinpatient
    AND mi.med_product_id=0
    AND mi.primary_ind=1
    AND mi.active_ind=1)
   JOIN (id
   WHERE id.item_id=ocs.item_id
    AND id.active_ind=1)
   JOIN (mdf
   WHERE mdf.item_id=id.item_id
    AND mdf.flex_type_cd=csystem
    AND mdf.pharmacy_type_cd=cinpatient)
  ORDER BY primary, product
  WITH nullreport, format = pcformat
 ;end select
 GO TO poc_problem_mode
#rx_mnem_no_link_crit_exit
#med_dup_oc_cki
 CALL clear_screen(0)
 FREE RECORD dup_cki
 RECORD dup_cki(
   1 dup_cki[*]
     2 catalog_cki = vc
 )
 SET cpharm = uar_get_code_by("MEANING",6000,"PHARMACY")
 SELECT INTO "nl:"
  oc.cki
  FROM order_catalog oc
  PLAN (oc
   WHERE oc.catalog_type_cd=cpharm
    AND oc.active_ind=1
    AND oc.orderable_type_flag IN (0, 1)
    AND trim(oc.cki) > " ")
  ORDER BY oc.cki
  HEAD REPORT
   cnt = 0
  HEAD oc.cki
   cki_cnt = 0
  DETAIL
   cki_cnt = (cki_cnt+ 1)
   IF (cki_cnt=2)
    cnt = (cnt+ 1), stat = alterlist(dup_cki->dup_cki,cnt), dup_cki->dup_cki[cnt].catalog_cki = trim(
     oc.cki)
   ENDIF
  WITH nullreport
 ;end select
 SELECT
  oc.catalog_cd, catalog_cki = substring(1,20,oc.cki), orderable = substring(1,60,oc.primary_mnemonic
   )
  FROM (dummyt d  WITH seq = value(size(dup_cki->dup_cki,5))),
   order_catalog oc
  PLAN (d)
   JOIN (oc
   WHERE (oc.cki=dup_cki->dup_cki[d.seq].catalog_cki)
    AND oc.active_ind=1)
  ORDER BY oc.cki, cnvtupper(oc.primary_mnemonic)
  WITH nocounter, format = pcformat
 ;end select
#med_dup_oc_cki_exit
#set_rxm_poc_linking
 CALL clear_screen(0)
 CALL text(05,2," Do you want to remove all existing linking between Rx Mnemonic ")
 CALL text(06,2," synonyms and products?  (Y/N)")
 CALL text(08,4," * A backup of deleted linking data will be created in a file ")
 CALL text(09,4,"   called 'asc_rxm_linking_backup.csv', located in CCLUSERDIR.")
 CALL text(11,4," * This delete is NOT facility specific. ALL links between Rx ")
 CALL text(12,4,"   Mnemonic synonyms and products will be removed.            ")
 CALL text(14,2," Response: ")
 CALL accept(14,16,"C;CU","N"
  WHERE cnvtupper(curaccept) IN ("Y", "N"))
 IF (cnvtupper(curaccept)="Y")
  SET crxm = uar_get_code_by("MEANING",6011,"RXMNEMONIC")
  SELECT INTO "asc_rxm_linking_backup.csv"
   sir.synonym_id, sir.item_id
   FROM synonym_item_r sir
   PLAN (sir
    WHERE sir.synonym_id IN (
    (SELECT
     synonym_id
     FROM order_catalog_synonym
     WHERE mnemonic_type_cd=crxm)))
   WITH format = pcformat
  ;end select
  DELETE  FROM synonym_item_r sir
   WHERE sir.synonym_id IN (
   (SELECT
    synonym_id
    FROM order_catalog_synonym
    WHERE mnemonic_type_cd=crxm))
   WITH nullreport
  ;end delete
 ENDIF
 CALL clear_screen(0)
 FREE RECORD product_list
 RECORD product_list(
   1 products[*]
     2 item_id = f8
     2 synonym_id = f8
     2 catalog_cd = f8
     2 form_cd = f8
     2 mmdc = vc
     2 strength_ind = i2
 )
 FREE RECORD new_links
 RECORD new_links(
   1 links[*]
     2 item_id = f8
     2 synonym_id = f8
     2 exists_ind = i2
 )
 CALL text(05,02,"Getting product list... ")
 SET cinpatient = uar_get_code_by("MEANING",4500,"INPATIENT")
 SET csystem = uar_get_code_by("MEANING",4062,"SYSTEM")
 SET csystempkg = uar_get_code_by("MEANING",4062,"SYSPKGTYP")
 SET cdesc = uar_get_code_by("MEANING",11000,"DESC")
 SET crxm = uar_get_code_by("MEANING",6011,"RXMNEMONIC")
 SET csyspkgtyp = uar_get_code_by("MEANING",4062,"SYSPKGTYP")
 SET corderable = uar_get_code_by("MEANING",4063,"ORDERABLE")
 SELECT INTO "nl:"
  ocir.catalog_cd, ocir.item_id, ocir.synonym_id,
  md.cki, md.form_cd, form = uar_get_code_display(md.form_cd)
  FROM medication_definition md,
   item_definition id,
   med_def_flex mdf,
   order_catalog_item_r ocir,
   med_dispense mdisp,
   med_def_flex mdf2,
   med_flex_object_idx mfoi2
  PLAN (md
   WHERE md.item_id > 0
    AND md.med_type_flag=0
    AND md.form_cd > 0)
   JOIN (ocir
   WHERE ocir.item_id=md.item_id)
   JOIN (mdisp
   WHERE mdisp.item_id=md.item_id
    AND mdisp.flex_type_cd=csystempkg
    AND mdisp.pharmacy_type_cd=cinpatient)
   JOIN (id
   WHERE id.item_id=md.item_id
    AND id.active_ind=1)
   JOIN (mdf
   WHERE mdf.item_id=md.item_id
    AND mdf.flex_type_cd=csystem
    AND mdf.pharmacy_type_cd=cinpatient)
   JOIN (mdf2
   WHERE mdf2.item_id=ocir.item_id
    AND mdf2.flex_type_cd=csyspkgtyp
    AND mdf2.pharmacy_type_cd=cinpatient)
   JOIN (mfoi2
   WHERE mfoi2.med_def_flex_id=mdf2.med_def_flex_id
    AND mfoi2.flex_object_type_cd=corderable
    AND ((mfoi2.parent_entity_id=0) OR (mfoi2.parent_entity_id=cur_facility_cd)) )
  ORDER BY ocir.catalog_cd, md.cki, md.form_cd
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(product_list->products,cnt), product_list->products[cnt].item_id
    = ocir.item_id,
   product_list->products[cnt].synonym_id = ocir.synonym_id, product_list->products[cnt].catalog_cd
    = ocir.catalog_cd, product_list->products[cnt].mmdc = trim(md.cki),
   product_list->products[cnt].form_cd = md.form_cd
   IF (mdisp.strength > 0
    AND mdisp.strength_unit_cd > 0)
    product_list->products[cnt].strength_ind = 1
   ENDIF
  WITH nullreport
 ;end select
 FOR (x = 1 TO size(product_list->products,5))
   CALL text(06,02,concat("Identifying links for product: ",build(x)))
   FREE RECORD temp_product_list
   RECORD temp_product_list(
     1 products[*]
       2 item_id = f8
       2 catalog_cd = f8
       2 form_cd = f8
       2 mmdc = vc
       2 strength_ind = i2
   )
   SELECT INTO "nl:"
    ocir.catalog_cd, ocir.item_id, md.cki,
    md.form_cd, form = uar_get_code_display(md.form_cd)
    FROM medication_definition md,
     item_definition id,
     med_def_flex mdf,
     order_catalog_item_r ocir,
     med_dispense mdisp,
     med_def_flex mdf2,
     med_flex_object_idx mfoi2
    PLAN (md
     WHERE md.item_id > 0
      AND md.med_type_flag=0
      AND md.form_cd > 0)
     JOIN (ocir
     WHERE ocir.item_id=md.item_id
      AND (ocir.catalog_cd=product_list->products[x].catalog_cd))
     JOIN (mdisp
     WHERE mdisp.item_id=md.item_id
      AND mdisp.flex_type_cd=csystempkg
      AND mdisp.pharmacy_type_cd=cinpatient)
     JOIN (id
     WHERE id.item_id=md.item_id
      AND id.active_ind=1)
     JOIN (mdf
     WHERE mdf.item_id=md.item_id
      AND mdf.flex_type_cd=csystem
      AND mdf.pharmacy_type_cd=cinpatient)
     JOIN (mdf2
     WHERE mdf2.item_id=ocir.item_id
      AND mdf2.flex_type_cd=csyspkgtyp
      AND mdf2.pharmacy_type_cd=cinpatient)
     JOIN (mfoi2
     WHERE mfoi2.med_def_flex_id=mdf2.med_def_flex_id
      AND mfoi2.flex_object_type_cd=corderable
      AND ((mfoi2.parent_entity_id=0) OR (mfoi2.parent_entity_id=cur_facility_cd)) )
    ORDER BY ocir.catalog_cd, md.cki, md.form_cd
    HEAD REPORT
     cnt = 0
    DETAIL
     cnt = (cnt+ 1), stat = alterlist(temp_product_list->products,cnt), temp_product_list->products[
     cnt].item_id = ocir.item_id,
     temp_product_list->products[cnt].catalog_cd = ocir.catalog_cd, temp_product_list->products[cnt].
     mmdc = trim(md.cki), temp_product_list->products[cnt].form_cd = md.form_cd
     IF (mdisp.strength > 0
      AND mdisp.strength_unit_cd > 0)
      temp_product_list->products[cnt].strength_ind = 1
     ENDIF
    WITH nullreport
   ;end select
   FOR (y = 1 TO size(temp_product_list->products,5))
     IF ((product_list->products[x].item_id=temp_product_list->products[y].item_id))
      CALL add_link(product_list->products[x].synonym_id,temp_product_list->products[y].item_id)
     ELSE
      IF ((product_list->products[x].mmdc > " ")
       AND (product_list->products[x].mmdc=temp_product_list->products[y].mmdc)
       AND (product_list->products[x].form_cd=temp_product_list->products[y].form_cd))
       CALL add_link(product_list->products[x].synonym_id,temp_product_list->products[y].item_id)
      ELSEIF ((product_list->products[x].form_cd=temp_product_list->products[y].form_cd)
       AND (product_list->products[x].strength_ind=1)
       AND (temp_product_list->products[y].strength_ind=1))
       CALL add_link(product_list->products[x].synonym_id,temp_product_list->products[y].item_id)
      ENDIF
     ENDIF
   ENDFOR
 ENDFOR
 CALL text(07,02,concat("Checking for duplicate links..."))
 SELECT INTO "nl:"
  sir.synonym_id, sir.item_id
  FROM (dummyt d  WITH seq = value(size(new_links->links,5))),
   synonym_item_r sir
  PLAN (d)
   JOIN (sir
   WHERE (sir.synonym_id=new_links->links[d.seq].synonym_id)
    AND (sir.item_id=new_links->links[d.seq].item_id))
  DETAIL
   new_links->links[d.seq].exists_ind = 1
  WITH nocounter
 ;end select
 CALL text(08,02,concat("Inserting new links..."))
 INSERT  FROM (dummyt d  WITH seq = value(size(new_links->links,5))),
   synonym_item_r sir
  SET sir.synonym_id = new_links->links[d.seq].synonym_id, sir.item_id = new_links->links[d.seq].
   item_id, sir.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   sir.updt_task = - (2516), sir.updt_id = 0
  PLAN (d
   WHERE (new_links->links[d.seq].synonym_id > 0)
    AND (new_links->links[d.seq].item_id > 0)
    AND (new_links->links[d.seq].exists_ind=0))
   JOIN (sir
   WHERE (sir.synonym_id=new_links->links[d.seq].synonym_id)
    AND (sir.item_id=new_links->links[d.seq].item_id))
  WITH nocounter
 ;end insert
 COMMIT
 CALL text(09,02,concat("Linking complete."))
#set_rxm_poc_linking_exit
#asc_med_os_seq
 CALL clear_screen(0)
 CALL text(05,2," Synonyms with existing sequence information assigned may be ")
 CALL text(06,2," skipped in order to preserve any build already completed.   ")
 CALL text(08,2," Would you like to overwite existing sequence values for all ")
 CALL text(09,2," medication (inpatient / administration) sentences (Y/N)?    ")
 CALL text(11,2," Response: ")
 CALL accept(11,15,"C;CU","N"
  WHERE cnvtupper(curaccept) IN ("Y", "N"))
 SET overwrite_existing_response = curaccept
 IF (overwrite_existing_response="Y")
  SET seq_everything = 1
 ELSE
  SET seq_everything = 0
 ENDIF
 CALL clear_screen(0)
 CALL text(05,2," Select the desired sequencing format for medication         ")
 CALL text(06,2," (inpatient / administration) sentences:                     ")
 CALL text(08,2," (1) Ascending by dose, then ascending by route, then ascending by form ")
 CALL text(09,2," (2) Ascending by dose, then ascending by form, then ascending by route ")
 CALL text(10,2," (3) Ascending by route, then ascending by dose, then ascending by form ")
 CALL text(11,2," (4) Ascending by route, then ascending by form, then ascending by dose ")
 CALL text(12,2," (5) Ascending by form, then ascending by dose, then ascending by route ")
 CALL text(13,2," (6) Ascending by form, then ascending by route, then ascending by dose ")
 CALL text(15,2," Response: ")
 CALL accept(15,15,"99;",0
  WHERE curaccept IN (0, 1, 2, 3, 4,
  5, 6))
 SET sort_type_response = curaccept
 CALL clear_screen(0)
 CALL text(05,2," Facility restrict options:                                  ")
 CALL text(07,2," 1) Restrict sequencing to selected facility based on virtual views     ")
 CALL text(08,2," 2) Sequence ALL sentences, regardless of virtual-views                 ")
 CALL text(10,2," Response: ")
 CALL accept(10,15,"99;",0
  WHERE curaccept IN (0, 1, 2))
 SET facility_qual_response = curaccept
 IF (sort_type_response > 0
  AND facility_qual_response > 0)
  CALL clear_screen(0)
  CALL text(5,2,"Getting list of synonyms to process...")
  FREE RECORD synonym_list
  RECORD synonym_list(
    1 list[*]
      2 synonym_id = f8
  )
  SET cpharm = uar_get_code_by("MEANING",6000,"PHARMACY")
  SET corder = uar_get_code_by("MEANING",6003,"ORDER")
  SET cmnem_type_z = uar_get_code_by("MEANING",6011,"TRADEPROD")
  SET cmnem_type_y = uar_get_code_by("MEANING",6011,"GENERICPROD")
  SET cnow = uar_get_code_by("MEANING",4010,"NOW")
  SET croutine = uar_get_code_by("MEANING",4010,"ROUTINE")
  SET cstat = uar_get_code_by("MEANING",4010,"STAT")
  IF (facility_qual_response=1)
   SELECT INTO "nl:"
    primary_synonym = substring(1,60,oc.primary_mnemonic), ocs.synonym_id, synonym = substring(1,60,
     ocs.mnemonic),
    ocsr.display_seq, os.order_sentence_display_line
    FROM order_catalog_synonym ocs,
     ocs_facility_r ofr,
     order_catalog oc,
     order_sentence os,
     ord_cat_sent_r ocsr,
     filter_entity_reltn fer
    PLAN (ocs
     WHERE ocs.active_ind=1
      AND ((ocs.hide_flag=0) OR (ocs.hide_flag=null))
      AND ocs.mnemonic_type_cd IN (
     (SELECT
      code_value
      FROM code_value
      WHERE code_set=6011
       AND cdf_meaning IN ("BRANDNAME", "DCP", "DISPDRUG", "GENERICTOP", "IVNAME",
      "PRIMARY", "TRADETOP"))))
     JOIN (oc
     WHERE oc.catalog_cd=ocs.catalog_cd
      AND oc.active_ind=1
      AND oc.orderable_type_flag IN (0, 1)
      AND oc.catalog_type_cd=cpharm)
     JOIN (ofr
     WHERE ofr.synonym_id=ocs.synonym_id
      AND ((ofr.facility_cd=0) OR (ofr.facility_cd=cur_facility_cd)) )
     JOIN (ocsr
     WHERE ocs.synonym_id=ocsr.synonym_id)
     JOIN (os
     WHERE os.order_sentence_id=ocsr.order_sentence_id)
     JOIN (fer
     WHERE fer.parent_entity_id=os.order_sentence_id
      AND ((fer.filter_entity1_id=0) OR (fer.filter_entity1_id=cur_facility_cd))
      AND fer.parent_entity_name="ORDER_SENTENCE"
      AND fer.filter_entity1_name="LOCATION")
    ORDER BY oc.catalog_cd, ocs.synonym_id, ocsr.display_seq
    HEAD REPORT
     cnt = 0
    HEAD ocs.synonym_id
     seq_build_exists = 0
    DETAIL
     IF (ocsr.display_seq > 0)
      seq_build_exists = 1
     ENDIF
    FOOT  ocs.synonym_id
     IF (((seq_everything=1) OR (seq_build_exists=0)) )
      cnt = (cnt+ 1), stat = alterlist(synonym_list->list,cnt), synonym_list->list[cnt].synonym_id =
      ocs.synonym_id
     ENDIF
    WITH nullreport
   ;end select
  ELSEIF (facility_qual_response=2)
   SELECT INTO "nl:"
    primary_synonym = substring(1,60,oc.primary_mnemonic), ocs.synonym_id, synonym = substring(1,60,
     ocs.mnemonic),
    ocsr.display_seq, os.order_sentence_display_line
    FROM order_catalog_synonym ocs,
     order_catalog oc,
     order_sentence os,
     ord_cat_sent_r ocsr
    PLAN (ocs
     WHERE ocs.active_ind=1
      AND ((ocs.hide_flag=0) OR (ocs.hide_flag=null))
      AND ocs.mnemonic_type_cd IN (
     (SELECT
      code_value
      FROM code_value
      WHERE code_set=6011
       AND cdf_meaning IN ("BRANDNAME", "DCP", "DISPDRUG", "GENERICTOP", "IVNAME",
      "PRIMARY", "TRADETOP"))))
     JOIN (oc
     WHERE oc.catalog_cd=ocs.catalog_cd
      AND oc.active_ind=1
      AND oc.orderable_type_flag IN (0, 1)
      AND oc.catalog_type_cd=cpharm)
     JOIN (ocsr
     WHERE ocs.synonym_id=ocsr.synonym_id)
     JOIN (os
     WHERE os.order_sentence_id=ocsr.order_sentence_id)
    ORDER BY oc.catalog_cd, ocs.synonym_id, ocsr.display_seq
    HEAD REPORT
     cnt = 0
    HEAD ocs.synonym_id
     seq_build_exists = 0
    DETAIL
     IF (ocsr.display_seq > 0)
      seq_build_exists = 1
     ENDIF
    FOOT  ocs.synonym_id
     IF (((seq_everything=1) OR (seq_build_exists=0)) )
      cnt = (cnt+ 1), stat = alterlist(synonym_list->list,cnt), synonym_list->list[cnt].synonym_id =
      ocs.synonym_id
     ENDIF
    WITH nullreport
   ;end select
  ENDIF
  CALL text(6,2,concat("Synonyms found: ",build(size(synonym_list->list,5))))
  FOR (x = 1 TO size(synonym_list->list,5))
    CALL text(8,2,concat("Sequencing progress: ",build(x)))
    FREE RECORD sentence_sort
    RECORD sentence_sort(
      1 sentence[*]
        2 order_sentence_id = f8
        2 synonym_id = f8
        2 sequence = f8
        2 strength = f8
        2 volume = f8
        2 freetext_dose = vc
        2 route = vc
        2 form = vc
        2 freq = vc
        2 prn = i2
        2 prn_reason = vc
        2 priority = i4
        2 rate = f8
        2 infuse = f8
        2 duration = f8
    )
    SELECT INTO "nl:"
     primary_synonym = oc.primary_mnemonic, synonym = ocs.mnemonic, ocsr.order_sentence_id,
     script = ocsr.order_sentence_disp_line, field_meaning = ofm.oe_field_meaning
     FROM ord_cat_sent_r ocsr,
      order_sentence os,
      order_catalog oc,
      order_catalog_synonym ocs,
      order_sentence_detail osd,
      oe_field_meaning ofm
     PLAN (ocsr
      WHERE (ocsr.synonym_id=synonym_list->list[x].synonym_id))
      JOIN (os
      WHERE os.order_sentence_id=ocsr.order_sentence_id
       AND os.usage_flag IN (0, 1))
      JOIN (oc
      WHERE oc.catalog_cd=ocsr.catalog_cd
       AND oc.catalog_type_cd=cpharm
       AND oc.orderable_type_flag IN (0, 1))
      JOIN (ocs
      WHERE ocs.synonym_id=ocsr.synonym_id)
      JOIN (osd
      WHERE osd.order_sentence_id=os.order_sentence_id)
      JOIN (ofm
      WHERE ofm.oe_field_meaning_id=osd.oe_field_meaning_id)
     ORDER BY os.order_sentence_id
     HEAD REPORT
      cnt = 0
     HEAD os.order_sentence_id
      cnt = (cnt+ 1), stat = alterlist(sentence_sort->sentence,cnt), sentence_sort->sentence[cnt].
      order_sentence_id = os.order_sentence_id,
      sentence_sort->sentence[cnt].synonym_id = ocs.synonym_id, freetext_dose_flag = 0, route_flag =
      0,
      form_flag = 0, freq_flag = 0, prn_reason_flag = 0
     DETAIL
      IF (field_meaning="STRENGTHDOSE")
       sentence_sort->sentence[cnt].strength = osd.oe_field_value
      ELSEIF (field_meaning="VOLUMEDOSE")
       sentence_sort->sentence[cnt].volume = osd.oe_field_value
      ELSEIF (field_meaning="FREETXTDOSE")
       freetext_dose_flag = 1, sentence_sort->sentence[cnt].freetext_dose = cnvtupper(osd
        .oe_field_display_value)
      ELSEIF (field_meaning="RXROUTE")
       route_flag = 1, sentence_sort->sentence[cnt].route = cnvtupper(osd.oe_field_display_value)
      ELSEIF (field_meaning="DRUGFORM")
       form_flag = 1, sentence_sort->sentence[cnt].form = cnvtupper(osd.oe_field_display_value)
      ELSEIF (field_meaning="FREQ")
       freq_flag = 1, sentence_sort->sentence[cnt].freq = cnvtupper(osd.oe_field_display_value)
      ELSEIF (field_meaning="SCH/PRN")
       sentence_sort->sentence[cnt].prn = osd.oe_field_value
      ELSEIF (field_meaning="PRNREASON")
       prn_reason_flag = 1, sentence_sort->sentence[cnt].prn_reason = cnvtupper(osd
        .oe_field_display_value)
      ELSEIF (field_meaning="RXPRIORITY")
       IF (osd.oe_field_value=croutine)
        sentence_sort->sentence[cnt].priority = 1
       ELSEIF (osd.oe_field_value=cnow)
        sentence_sort->sentence[cnt].priority = 2
       ELSEIF (osd.oe_field_value=cstat)
        sentence_sort->sentence[cnt].priority = 3
       ELSE
        sentence_sort->sentence[cnt].priority = 0
       ENDIF
      ELSEIF (field_meaning="RATE")
       sentence_sort->sentence[cnt].rate = osd.oe_field_value
      ELSEIF (field_meaning="INFUSEOVER")
       sentence_sort->sentence[cnt].infuse = osd.oe_field_value
      ELSEIF (field_meaning="DURATION")
       sentence_sort->sentence[cnt].duration = osd.oe_field_value
      ENDIF
     FOOT  os.order_sentence_id
      IF (freetext_dose_flag=0)
       sentence_sort->sentence[cnt].freetext_dose = "!"
      ENDIF
      IF (route_flag=0)
       sentence_sort->sentence[cnt].route = "!"
      ENDIF
      IF (form_flag=0)
       sentence_sort->sentence[cnt].form = "!"
      ENDIF
      IF (freq_flag=0)
       sentence_sort->sentence[cnt].freq = "!"
      ENDIF
      IF (prn_reason_flag=0)
       sentence_sort->sentence[cnt].prn_reason = "!"
      ENDIF
     WITH nullreport
    ;end select
    IF (sort_type_response=1)
     SELECT INTO "nl:"
      synonym_id = sentence_sort->sentence[d.seq].synonym_id, strength = sentence_sort->sentence[d
      .seq].strength, volume = sentence_sort->sentence[d.seq].volume,
      freetextdose = sentence_sort->sentence[d.seq].freetext_dose, route = sentence_sort->sentence[d
      .seq].route, form = sentence_sort->sentence[d.seq].form,
      freq = sentence_sort->sentence[d.seq].freq, prn = sentence_sort->sentence[d.seq].prn,
      prn_reason = sentence_sort->sentence[d.seq].prn_reason,
      rate = sentence_sort->sentence[d.seq].rate
      FROM (dummyt d  WITH seq = value(size(sentence_sort->sentence,5)))
      PLAN (d
       WHERE (sentence_sort->sentence[d.seq].order_sentence_id > 0))
      ORDER BY synonym_id, strength, volume,
       freetextdose, route, form,
       freq, prn, prn_reason,
       rate
      HEAD synonym_id
       cur_sequence = 0
      DETAIL
       cur_sequence = (cur_sequence+ 10), sentence_sort->sentence[d.seq].sequence = cur_sequence
      WITH nullreport
     ;end select
    ELSEIF (sort_type_response=2)
     SELECT INTO "nl:"
      synonym_id = sentence_sort->sentence[d.seq].synonym_id, strength = sentence_sort->sentence[d
      .seq].strength, volume = sentence_sort->sentence[d.seq].volume,
      freetextdose = sentence_sort->sentence[d.seq].freetext_dose, route = sentence_sort->sentence[d
      .seq].route, form = sentence_sort->sentence[d.seq].form,
      freq = sentence_sort->sentence[d.seq].freq, prn = sentence_sort->sentence[d.seq].prn,
      prn_reason = sentence_sort->sentence[d.seq].prn_reason,
      rate = sentence_sort->sentence[d.seq].rate
      FROM (dummyt d  WITH seq = value(size(sentence_sort->sentence,5)))
      PLAN (d
       WHERE (sentence_sort->sentence[d.seq].order_sentence_id > 0))
      ORDER BY synonym_id, strength, volume,
       freetextdose, form, route,
       freq, prn, prn_reason,
       rate
      HEAD synonym_id
       cur_sequence = 0
      DETAIL
       cur_sequence = (cur_sequence+ 10), sentence_sort->sentence[d.seq].sequence = cur_sequence
      WITH nullreport
     ;end select
    ELSEIF (sort_type_response=3)
     SELECT INTO "nl:"
      synonym_id = sentence_sort->sentence[d.seq].synonym_id, strength = sentence_sort->sentence[d
      .seq].strength, volume = sentence_sort->sentence[d.seq].volume,
      freetextdose = sentence_sort->sentence[d.seq].freetext_dose, route = sentence_sort->sentence[d
      .seq].route, form = sentence_sort->sentence[d.seq].form,
      freq = sentence_sort->sentence[d.seq].freq, prn = sentence_sort->sentence[d.seq].prn,
      prn_reason = sentence_sort->sentence[d.seq].prn_reason,
      rate = sentence_sort->sentence[d.seq].rate
      FROM (dummyt d  WITH seq = value(size(sentence_sort->sentence,5)))
      PLAN (d
       WHERE (sentence_sort->sentence[d.seq].order_sentence_id > 0))
      ORDER BY synonym_id, route, strength,
       volume, freetextdose, form,
       freq, prn, prn_reason,
       rate
      HEAD synonym_id
       cur_sequence = 0
      DETAIL
       cur_sequence = (cur_sequence+ 10), sentence_sort->sentence[d.seq].sequence = cur_sequence
      WITH nullreport
     ;end select
    ELSEIF (sort_type_response=4)
     SELECT INTO "nl:"
      synonym_id = sentence_sort->sentence[d.seq].synonym_id, strength = sentence_sort->sentence[d
      .seq].strength, volume = sentence_sort->sentence[d.seq].volume,
      freetextdose = sentence_sort->sentence[d.seq].freetext_dose, route = sentence_sort->sentence[d
      .seq].route, form = sentence_sort->sentence[d.seq].form,
      freq = sentence_sort->sentence[d.seq].freq, prn = sentence_sort->sentence[d.seq].prn,
      prn_reason = sentence_sort->sentence[d.seq].prn_reason,
      rate = sentence_sort->sentence[d.seq].rate
      FROM (dummyt d  WITH seq = value(size(sentence_sort->sentence,5)))
      PLAN (d
       WHERE (sentence_sort->sentence[d.seq].order_sentence_id > 0))
      ORDER BY synonym_id, route, form,
       strength, volume, freetextdose,
       freq, prn, prn_reason,
       rate
      HEAD synonym_id
       cur_sequence = 0
      DETAIL
       cur_sequence = (cur_sequence+ 10), sentence_sort->sentence[d.seq].sequence = cur_sequence
      WITH nullreport
     ;end select
    ELSEIF (sort_type_response=5)
     SELECT INTO "nl:"
      synonym_id = sentence_sort->sentence[d.seq].synonym_id, strength = sentence_sort->sentence[d
      .seq].strength, volume = sentence_sort->sentence[d.seq].volume,
      freetextdose = sentence_sort->sentence[d.seq].freetext_dose, route = sentence_sort->sentence[d
      .seq].route, form = sentence_sort->sentence[d.seq].form,
      freq = sentence_sort->sentence[d.seq].freq, prn = sentence_sort->sentence[d.seq].prn,
      prn_reason = sentence_sort->sentence[d.seq].prn_reason,
      rate = sentence_sort->sentence[d.seq].rate
      FROM (dummyt d  WITH seq = value(size(sentence_sort->sentence,5)))
      PLAN (d
       WHERE (sentence_sort->sentence[d.seq].order_sentence_id > 0))
      ORDER BY synonym_id, form, strength,
       volume, freetextdose, route,
       freq, prn, prn_reason,
       rate
      HEAD synonym_id
       cur_sequence = 0
      DETAIL
       cur_sequence = (cur_sequence+ 10), sentence_sort->sentence[d.seq].sequence = cur_sequence
      WITH nullreport
     ;end select
    ELSEIF (sort_type_response=6)
     SELECT INTO "nl:"
      synonym_id = sentence_sort->sentence[d.seq].synonym_id, strength = sentence_sort->sentence[d
      .seq].strength, volume = sentence_sort->sentence[d.seq].volume,
      freetextdose = sentence_sort->sentence[d.seq].freetext_dose, route = sentence_sort->sentence[d
      .seq].route, form = sentence_sort->sentence[d.seq].form,
      freq = sentence_sort->sentence[d.seq].freq, prn = sentence_sort->sentence[d.seq].prn,
      prn_reason = sentence_sort->sentence[d.seq].prn_reason,
      rate = sentence_sort->sentence[d.seq].rate
      FROM (dummyt d  WITH seq = value(size(sentence_sort->sentence,5)))
      PLAN (d
       WHERE (sentence_sort->sentence[d.seq].order_sentence_id > 0))
      ORDER BY synonym_id, form, route,
       strength, volume, freetextdose,
       freq, prn, prn_reason,
       rate
      HEAD synonym_id
       cur_sequence = 0
      DETAIL
       cur_sequence = (cur_sequence+ 10), sentence_sort->sentence[d.seq].sequence = cur_sequence
      WITH nullreport
     ;end select
    ENDIF
    UPDATE  FROM (dummyt d  WITH seq = value(size(sentence_sort->sentence,5))),
      ord_cat_sent_r ocsr
     SET ocsr.display_seq = sentence_sort->sentence[d.seq].sequence
     PLAN (d
      WHERE (sentence_sort->sentence[d.seq].sequence > 0))
      JOIN (ocsr
      WHERE (sentence_sort->sentence[d.seq].order_sentence_id=ocsr.order_sentence_id))
     WITH nullreport
    ;end update
  ENDFOR
  COMMIT
  CALL text(9,2,"Sequencing complete")
 ENDIF
 GO TO pharm_utilities_mode
#asc_med_os_seq_exit
#powerplan_extract_csv
 SET text_row = 5
 CALL clear_screen(0)
 CALL text(5,2,"A file will be created in CCLUSERDIR called 'asc_pp_sent_extract.csv'")
 CALL text(7,2,"Begin? (Y/N)")
 CALL accept(7,17,"C;CU","Y"
  WHERE curaccept IN ("Y", "N"))
 CASE (curaccept)
  OF "Y":
   CALL show_processing(0)
  OF "N":
   GO TO cs_pp_extract_mode
 ENDCASE
 CALL show_processing(0)
 SET text_row = (text_row+ 1)
 DECLARE get_sentence_detail_value(detail_pos=f8) = vc
 DECLARE csv_line = vc
 DECLARE text_result = vc
 DECLARE detail_text_value = vc
 SET order_sentence_count = 0
 SET cprim_rx = 0
 SET cprim_rx_cnt = 0
 SET civ_ingred = 0
 SET civ_ingred_cnt = 0
 SET cprn = 0
 SET cprn_cnt = 0
 SET cerror_flag = 0
 SET cdup_fields = 0
 FREE RECORD details
 RECORD details(
   1 details[*]
     2 os_id = f8
     2 oe_field_id = f8
     2 code_value = f8
     2 field_value = vc
 )
 FREE RECORD used_fields
 RECORD used_fields(
   1 fields[*]
     2 oe_field_id = f8
     2 oe_field_meaning = vc
     2 field_desc = vc
 )
 SET stat = alterlist(used_fields->fields,18)
 SET used_fields->fields[1].oe_field_meaning = "STRENGTHDOSE"
 SET used_fields->fields[2].oe_field_meaning = "STRENGTHDOSEUNIT"
 SET used_fields->fields[3].oe_field_meaning = "VOLUMEDOSE"
 SET used_fields->fields[4].oe_field_meaning = "VOLUMEDOSEUNIT"
 SET used_fields->fields[5].oe_field_meaning = "FREETXTDOSE"
 SET used_fields->fields[6].oe_field_meaning = "RXROUTE"
 SET used_fields->fields[7].oe_field_meaning = "DRUGFORM"
 SET used_fields->fields[8].oe_field_meaning = "FREQ"
 SET used_fields->fields[9].oe_field_meaning = "RXPRIORITY"
 SET used_fields->fields[10].oe_field_meaning = "SCH/PRN"
 SET used_fields->fields[11].oe_field_meaning = "PRNREASON"
 SET used_fields->fields[12].oe_field_meaning = "FREETEXTRATE"
 SET used_fields->fields[13].oe_field_meaning = "RATE"
 SET used_fields->fields[14].oe_field_meaning = "RATEUNIT"
 SET used_fields->fields[15].oe_field_meaning = "INFUSEOVER"
 SET used_fields->fields[16].oe_field_meaning = "INFUSEOVERUNIT"
 SET used_fields->fields[17].oe_field_meaning = "DURATION"
 SET used_fields->fields[18].oe_field_meaning = "DURATIONUNIT"
 CALL text(text_row,2,"Looking up required code values...")
 SET text_row = (text_row+ 1)
 SET cpharm = uar_get_code_by("MEANING",6000,"PHARMACY")
 SET cmnem_type_z = uar_get_code_by("MEANING",6011,"TRADEPROD")
 SET cmnem_type_y = uar_get_code_by("MEANING",6011,"GENERICPROD")
 SET corder = uar_get_code_by("MEANING",6003,"ORDER")
 SELECT INTO "nl:"
  oef.oe_format_id
  FROM order_entry_format oef
  WHERE cnvtupper(oef.oe_format_name)="PRIMARY PHARMACY"
   AND oef.action_type_cd=corder
  DETAIL
   cprim_rx = oef.oe_format_id, cprim_rx_cnt = (cprim_rx_cnt+ 1)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  oef.oe_format_id
  FROM order_entry_format oef
  WHERE cnvtupper(oef.oe_format_name)="IV INGREDIENT"
   AND oef.action_type_cd=corder
  DETAIL
   civ_ingred = oef.oe_format_id, civ_ingred_cnt = (civ_ingred_cnt+ 1)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  oef.oe_field_id
  FROM order_entry_fields oef,
   oe_field_meaning ofm
  WHERE oef.oe_field_meaning_id=ofm.oe_field_meaning_id
   AND ofm.oe_field_meaning="SCH/PRN"
  DETAIL
   cprn = oef.oe_field_id, cprn_cnt = (cprn_cnt+ 1)
  WITH nocounter
 ;end select
 IF (((cprn_cnt != 1) OR (((cprim_rx_cnt != 1) OR (((civ_ingred_cnt != 1) OR (((cpharm=0) OR (((
 cmnem_type_z=0) OR (((cmnem_type_y=0) OR (corder=0)) )) )) )) )) )) )
  SET cerror_flag = 1
  GO TO end_pp_sent_extract
 ENDIF
 CALL text(text_row,2,"Identifying order entry fields used in PowerPlan medication sentences...")
 SET text_row = (text_row+ 1)
 SELECT DISTINCT INTO "nl:"
  osd.oe_field_id, ofm.oe_field_meaning
  FROM pathway_catalog pcat,
   pw_cat_flex pcf,
   pathway_comp pcmp,
   order_catalog_synonym ocs,
   pw_comp_os_reltn pcor,
   order_sentence os,
   order_sentence_detail osd,
   oe_field_meaning ofm
  PLAN (pcat
   WHERE pcat.active_ind=1)
   JOIN (pcf
   WHERE pcf.pathway_catalog_id=pcat.pathway_catalog_id
    AND ((pcf.parent_entity_id=0) OR (pcf.parent_entity_id=cur_facility_cd)) )
   JOIN (pcmp
   WHERE pcat.pathway_catalog_id=pcmp.pathway_catalog_id
    AND pcmp.sequence > 0)
   JOIN (ocs
   WHERE pcmp.parent_entity_id=ocs.synonym_id
    AND ocs.catalog_type_cd=cpharm
    AND ocs.oe_format_id != cprim_rx)
   JOIN (pcor
   WHERE pcor.pathway_comp_id=pcmp.pathway_comp_id)
   JOIN (os
   WHERE os.order_sentence_id=pcor.order_sentence_id
    AND os.oe_format_id != civ_ingred)
   JOIN (osd
   WHERE osd.order_sentence_id=os.order_sentence_id)
   JOIN (ofm
   WHERE ofm.oe_field_meaning_id=osd.oe_field_meaning_id)
  ORDER BY osd.oe_field_id
  HEAD REPORT
   row_cnt = 19, array_loc = 1
  HEAD osd.oe_field_id
   array_loc = 0
   CASE (trim(ofm.oe_field_meaning))
    OF "STRENGTHDOSE":
     array_loc = 1
    OF "STRENGTHDOSEUNIT":
     array_loc = 2
    OF "VOLUMEDOSE":
     array_loc = 3
    OF "VOLUMEDOSEUNIT":
     array_loc = 4
    OF "FREETXTDOSE":
     array_loc = 5
    OF "RXROUTE":
     array_loc = 6
    OF "DRUGFORM":
     array_loc = 7
    OF "FREQ":
     array_loc = 8
    OF "RXPRIORITY":
     array_loc = 9
    OF "SCH/PRN":
     array_loc = 10
    OF "PRNREASON":
     array_loc = 11
    OF "FREETEXTRATE":
     array_loc = 12
    OF "RATE":
     array_loc = 13
    OF "RATEUNIT":
     array_loc = 14
    OF "INFUSEOVER":
     array_loc = 15
    OF "INFUSEOVERUNIT":
     array_loc = 16
    OF "DURATION":
     array_loc = 17
    OF "DURATIONUNIT":
     array_loc = 18
    ELSE
     array_loc = row_cnt,stat = alterlist(used_fields->fields,row_cnt),row_cnt = (row_cnt+ 1)
   ENDCASE
   IF ((used_fields->fields[array_loc].oe_field_id > 0))
    cdup_fields = 1, text_row = (text_row+ 1),
    CALL text(text_row,2,build("Warning!! ...duplicate fields in use for field meaning=",ofm
     .oe_field_meaning)),
    text_row = (text_row+ 1),
    CALL text(text_row,2,"Extracted values for this field may be unpredictable"), text_row = (
    text_row+ 1)
   ENDIF
   used_fields->fields[array_loc].oe_field_id = osd.oe_field_id, used_fields->fields[array_loc].
   oe_field_meaning = ofm.oe_field_meaning
  WITH nullreport
 ;end select
 SELECT INTO "nl:"
  oef.oe_field_id, oef.description
  FROM (dummyt d  WITH seq = value(size(used_fields->fields,5))),
   order_entry_fields oef
  PLAN (d)
   JOIN (oef
   WHERE (oef.oe_field_id=used_fields->fields[d.seq].oe_field_id))
  DETAIL
   used_fields->fields[d.seq].field_desc = oef.description
  WITH nullreport
 ;end select
 CALL text(text_row,2,"Generating index of medication order sentence details...")
 SET text_row = (text_row+ 1)
 SELECT INTO "nl:"
  os.order_sentence_id, osd.oe_field_id, code_value = osd.default_parent_entity_id,
  osd.oe_field_value, osd.oe_field_display_value, code_value_display = cv.display,
  oefld.field_type_flag
  FROM pathway_catalog pcat,
   pw_cat_flex pcf,
   pathway_comp pcmp,
   order_catalog_synonym ocs,
   pw_comp_os_reltn pcor,
   order_sentence os,
   order_entry_format oef,
   order_sentence_detail osd,
   order_entry_fields oefld,
   code_value cv
  PLAN (pcat
   WHERE pcat.active_ind=1)
   JOIN (pcf
   WHERE pcf.pathway_catalog_id=pcat.pathway_catalog_id
    AND ((pcf.parent_entity_id=0) OR (pcf.parent_entity_id=cur_facility_cd)) )
   JOIN (pcmp
   WHERE pcat.pathway_catalog_id=pcmp.pathway_catalog_id
    AND pcmp.sequence > 0)
   JOIN (ocs
   WHERE pcmp.parent_entity_id=ocs.synonym_id
    AND ocs.catalog_type_cd=cpharm
    AND ocs.oe_format_id != cprim_rx
    AND ocs.oe_format_id > 0)
   JOIN (pcor
   WHERE pcor.pathway_comp_id=pcmp.pathway_comp_id)
   JOIN (os
   WHERE os.order_sentence_id=pcor.order_sentence_id
    AND os.oe_format_id != civ_ingred)
   JOIN (oef
   WHERE oef.oe_format_id=outerjoin(ocs.oe_format_id)
    AND oef.action_type_cd=outerjoin(corder))
   JOIN (osd
   WHERE osd.order_sentence_id=os.order_sentence_id)
   JOIN (oefld
   WHERE oefld.oe_field_id=osd.oe_field_id)
   JOIN (cv
   WHERE osd.default_parent_entity_id=cv.code_value)
  ORDER BY os.order_sentence_id, osd.oe_field_id
  HEAD REPORT
   row_cnt = 0
  HEAD os.order_sentence_id
   order_sentence_count = (order_sentence_count+ 1)
  DETAIL
   row_cnt = (row_cnt+ 1), stat = alterlist(details->details,row_cnt), details->details[row_cnt].
   os_id = os.order_sentence_id,
   details->details[row_cnt].oe_field_id = osd.oe_field_id
   IF (osd.default_parent_entity_id > 0)
    details->details[row_cnt].field_value = cv.display
   ELSE
    IF (oefld.field_type_flag=7
     AND trim(osd.oe_field_display_value)="1")
     details->details[row_cnt].field_value = "Yes"
    ELSEIF (oefld.field_type_flag=7
     AND trim(osd.oe_field_display_value)="0")
     details->details[row_cnt].field_value = "No"
    ELSE
     details->details[row_cnt].field_value = osd.oe_field_display_value
    ENDIF
   ENDIF
  WITH nullreport, outerjoin = cv
 ;end select
 CALL text(text_row,2,concat("Building extract. ",build(order_sentence_count),
   " sentences to process..."))
 SET text_row = (text_row+ 1)
 FREE RECORD mylist2
 RECORD mylist2(
   1 vv[*]
     2 syn_id = f8
     2 vv_ind = c1
 )
 CALL load_current_vv(0)
 SELECT INTO "asc_pp_sent_extract.csv"
  primary_synonym = oc.primary_mnemonic, mnemonic_key_cap = ocs.mnemonic_key_cap, mnemonic_type = cv
  .display,
  mnemonic_type_cdf = cv.cdf_meaning, virtual_view = mylist2->vv[d2.seq].vv_ind, oef.oe_format_id,
  oef.oe_format_name, os.order_sentence_id, script = os.order_sentence_display_line,
  os.usage_flag, order_cat_cki = oc.cki, synonym_cki = ocs.cki,
  os.external_identifier, comment = lt.long_text
  FROM pathway_catalog pcat,
   pw_cat_flex pcf,
   pathway_comp pcmp,
   order_catalog_synonym ocs,
   order_catalog oc,
   pw_comp_os_reltn pcor,
   order_sentence os,
   order_catalog_synonym ocs,
   order_entry_format oef,
   long_text lt,
   code_value cv,
   dummyt d1,
   (dummyt d2  WITH seq = value(size(mylist2->vv,5)))
  PLAN (pcat
   WHERE pcat.active_ind=1)
   JOIN (pcf
   WHERE pcf.pathway_catalog_id=pcat.pathway_catalog_id
    AND ((pcf.parent_entity_id=0) OR (pcf.parent_entity_id=cur_facility_cd)) )
   JOIN (pcmp
   WHERE pcat.pathway_catalog_id=pcmp.pathway_catalog_id
    AND pcmp.sequence > 0)
   JOIN (ocs
   WHERE pcmp.parent_entity_id=ocs.synonym_id
    AND ocs.catalog_type_cd=cpharm
    AND ocs.oe_format_id != cprim_rx
    AND ocs.oe_format_id > 0)
   JOIN (pcor
   WHERE pcor.pathway_comp_id=pcmp.pathway_comp_id)
   JOIN (os
   WHERE os.order_sentence_id=pcor.order_sentence_id
    AND os.oe_format_id != civ_ingred)
   JOIN (oc
   WHERE oc.catalog_cd=ocs.catalog_cd
    AND oc.catalog_type_cd=cpharm)
   JOIN (oef
   WHERE oef.oe_format_id=outerjoin(ocs.oe_format_id)
    AND oef.action_type_cd=outerjoin(corder))
   JOIN (lt
   WHERE outerjoin(os.ord_comment_long_text_id)=lt.long_text_id)
   JOIN (cv
   WHERE ocs.mnemonic_type_cd=cv.code_value)
   JOIN (d1)
   JOIN (d2
   WHERE (ocs.synonym_id=mylist2->vv[d2.seq].syn_id))
  ORDER BY oef.oe_format_id, os.order_sentence_id
  HEAD REPORT
   os_cnt = 0, oef_cnt = 0, cur_field_match_found = 0,
   cur_sentence_pos = 0, cur_sentence_detail_count = 0, cur_sentence_details_found = 0,
   csv_line = concat("PowerPlan,SYNONYM_ID,Component Synonym,Component Primary,",
    "Synonym Type,Virtual View,Order Entry Format,ORDER_SENTENCE_ID,",
    "Sentence,Order Catalog CKI,Synonym CKI,")
   FOR (x = 1 TO cnvtint(size(used_fields->fields,5)))
     csv_line = concat(csv_line,'"',"OE_FLD",trim(cnvtstring(x)),'"',
      ",",'"',"OE_FLD_VALUE",trim(cnvtstring(x)),'"',
      ",")
   ENDFOR
   csv_line = concat(csv_line,'"',"COMMENT",'"'), col 0, csv_line,
   row + 1, csv_line = ""
  HEAD oef.oe_format_id
   oef_cnt = (oef_cnt+ 1)
  HEAD os.order_sentence_id
   os_cnt = (os_cnt+ 1), cur_sentence_pos = 0, cur_sentence_detail_count = 0,
   cur_sentence_details_found = 0, cur_field_match_found = 0, csv_line = ""
   IF (os_cnt > 1)
    row + 1
   ENDIF
   csv_line = concat('"',strip_str_quotes(pcat.description),'"',",",'"',
    trim(cnvtstring(ocs.synonym_id)),'"',",",'"',trim(ocs.mnemonic),
    '"',",",'"',trim(oc.primary_mnemonic),'"',
    ",",'"',trim(cv.display),'"',",",
    '"',virtual_view,'"',",",'"',
    trim(oef.oe_format_name),'"',",",'"',trim(cnvtstring(os.order_sentence_id)),
    '"',",",'"',strip_str_quotes(os.order_sentence_display_line),'"',
    ",",'"',trim(oc.cki),'"',",",
    '"',trim(ocs.cki),'"',","), cur_sentence_pos = find_sentence_pos(os.order_sentence_id),
   cur_sentence_detail_count = count_sentence_details(cur_sentence_pos)
   FOR (y = 1 TO size(used_fields->fields,5))
     detail_text_value = "error", cur_field_match_found = 0
     IF ((used_fields->fields[y].oe_field_meaning="OTHER"))
      csv_line = concat(csv_line,'"',used_fields->fields[y].field_desc,'"',",")
     ELSE
      csv_line = concat(csv_line,'"',used_fields->fields[y].oe_field_meaning,'"',",")
     ENDIF
     IF (cur_sentence_detail_count > 0)
      FOR (z = 1 TO cur_sentence_detail_count)
        IF (cur_sentence_details_found < cur_sentence_detail_count
         AND (used_fields->fields[y].oe_field_id=get_sentence_detail_type(((cur_sentence_pos+ z) - 1)
         ))
         AND cur_field_match_found=0)
         cur_sentence_details_found = (cur_sentence_details_found+ 1), detail_text_value = trim(build
          (get_sentence_detail_value(cnvtreal(((cur_sentence_pos+ z) - 1))))), csv_line = concat(
          csv_line,'"',detail_text_value,'"',","),
         cur_field_match_found = 1
        ENDIF
      ENDFOR
      IF ((used_fields->fields[y].oe_field_id=cprn)
       AND cur_field_match_found=0)
       csv_line = concat(csv_line,'"',"No",'"',",")
      ELSEIF (cur_field_match_found=0)
       csv_line = concat(csv_line,'"','"',",")
      ENDIF
     ENDIF
   ENDFOR
   csv_line = concat(csv_line,'"',strip_str_quotes(lt.long_text),'"'), col 0, csv_line
  FOOT REPORT
   CALL text(text_row,2,"Extract complete"), text_row = (text_row+ 1)
  WITH outerjoin = d1, check, maxcol = 10000,
   format = variable, nullreport, noformfeed,
   landscape, maxrow = 1
 ;end select
#end_pp_sent_extract
 IF (cerror_flag=1)
  CALL text(text_row,2,"Unable to locate required information. Extract aborted.")
  SET text_row = (text_row+ 1)
 ENDIF
 GO TO cs_pp_extract_mode
#powerplan_extract_csv_exit
#careset_extract_csv
 SET text_row = 5
 CALL clear_screen(0)
 CALL text(5,2,"A file will be created in CCLUSERDIR called 'asc_cs_sent_extract.csv'")
 CALL text(7,2,"Begin? (Y/N)")
 CALL accept(7,17,"C;CU","Y"
  WHERE curaccept IN ("Y", "N"))
 CASE (curaccept)
  OF "Y":
   CALL show_processing(0)
  OF "N":
   GO TO pcs_pp_extract_mode
 ENDCASE
 CALL show_processing(0)
 SET text_row = (text_row+ 1)
 DECLARE get_sentence_detail_value(detail_pos=f8) = vc
 DECLARE csv_line = vc
 DECLARE text_result = vc
 DECLARE detail_text_value = vc
 SET order_sentence_count = 0
 SET cprim_rx = 0
 SET cprim_rx_cnt = 0
 SET civ_ingred = 0
 SET civ_ingred_cnt = 0
 SET cprn = 0
 SET cprn_cnt = 0
 SET cerror_flag = 0
 SET cdup_fields = 0
 FREE RECORD details
 RECORD details(
   1 details[*]
     2 os_id = f8
     2 oe_field_id = f8
     2 code_value = f8
     2 field_value = vc
 )
 FREE RECORD used_fields
 RECORD used_fields(
   1 fields[*]
     2 oe_field_id = f8
     2 oe_field_meaning = vc
     2 field_desc = vc
 )
 SET stat = alterlist(used_fields->fields,18)
 SET used_fields->fields[1].oe_field_meaning = "STRENGTHDOSE"
 SET used_fields->fields[2].oe_field_meaning = "STRENGTHDOSEUNIT"
 SET used_fields->fields[3].oe_field_meaning = "VOLUMEDOSE"
 SET used_fields->fields[4].oe_field_meaning = "VOLUMEDOSEUNIT"
 SET used_fields->fields[5].oe_field_meaning = "FREETXTDOSE"
 SET used_fields->fields[6].oe_field_meaning = "RXROUTE"
 SET used_fields->fields[7].oe_field_meaning = "DRUGFORM"
 SET used_fields->fields[8].oe_field_meaning = "FREQ"
 SET used_fields->fields[9].oe_field_meaning = "RXPRIORITY"
 SET used_fields->fields[10].oe_field_meaning = "SCH/PRN"
 SET used_fields->fields[11].oe_field_meaning = "PRNREASON"
 SET used_fields->fields[12].oe_field_meaning = "FREETEXTRATE"
 SET used_fields->fields[13].oe_field_meaning = "RATE"
 SET used_fields->fields[14].oe_field_meaning = "RATEUNIT"
 SET used_fields->fields[15].oe_field_meaning = "INFUSEOVER"
 SET used_fields->fields[16].oe_field_meaning = "INFUSEOVERUNIT"
 SET used_fields->fields[17].oe_field_meaning = "DURATION"
 SET used_fields->fields[18].oe_field_meaning = "DURATIONUNIT"
 CALL text(text_row,2,"Looking up required code values...")
 SET text_row = (text_row+ 1)
 SET cpharm = uar_get_code_by("MEANING",6000,"PHARMACY")
 SET cmnem_type_z = uar_get_code_by("MEANING",6011,"TRADEPROD")
 SET cmnem_type_y = uar_get_code_by("MEANING",6011,"GENERICPROD")
 SET corder = uar_get_code_by("MEANING",6003,"ORDER")
 SELECT INTO "nl:"
  oef.oe_format_id
  FROM order_entry_format oef
  WHERE cnvtupper(oef.oe_format_name)="PRIMARY PHARMACY"
   AND oef.action_type_cd=corder
  DETAIL
   cprim_rx = oef.oe_format_id, cprim_rx_cnt = (cprim_rx_cnt+ 1)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  oef.oe_format_id
  FROM order_entry_format oef
  WHERE cnvtupper(oef.oe_format_name)="IV INGREDIENT"
   AND oef.action_type_cd=corder
  DETAIL
   civ_ingred = oef.oe_format_id, civ_ingred_cnt = (civ_ingred_cnt+ 1)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  oef.oe_field_id
  FROM order_entry_fields oef,
   oe_field_meaning ofm
  WHERE oef.oe_field_meaning_id=ofm.oe_field_meaning_id
   AND ofm.oe_field_meaning="SCH/PRN"
  DETAIL
   cprn = oef.oe_field_id, cprn_cnt = (cprn_cnt+ 1)
  WITH nocounter
 ;end select
 IF (((cprn_cnt != 1) OR (((cprim_rx_cnt != 1) OR (((civ_ingred_cnt != 1) OR (((cpharm=0) OR (((
 cmnem_type_z=0) OR (((cmnem_type_y=0) OR (corder=0)) )) )) )) )) )) )
  SET cerror_flag = 1
  GO TO end_cs_sent_extract
 ENDIF
 CALL text(text_row,2,"Identifying order entry fields used in CareSet medication sentences...")
 SET text_row = (text_row+ 1)
 SELECT DISTINCT INTO "nl:"
  osd.oe_field_id, ofm.oe_field_meaning
  FROM order_catalog oc,
   cs_component csp,
   order_catalog_synonym ocs,
   order_sentence os,
   order_sentence_detail osd,
   oe_field_meaning ofm,
   order_catalog_synonym ocs2,
   ocs_facility_r ofr
  PLAN (oc
   WHERE oc.orderable_type_flag=6
    AND oc.active_ind=1)
   JOIN (ocs2
   WHERE oc.catalog_cd=ocs2.catalog_cd
    AND ocs2.active_ind=1
    AND ((ocs2.hide_flag=0) OR (ocs2.hide_flag=null)) )
   JOIN (ofr
   WHERE ofr.synonym_id=ocs2.synonym_id
    AND ((ofr.facility_cd=0) OR (ofr.facility_cd=cur_facility_cd)) )
   JOIN (csp
   WHERE oc.catalog_cd=csp.catalog_cd)
   JOIN (ocs
   WHERE ocs.synonym_id=csp.comp_id
    AND ocs.catalog_type_cd=cpharm)
   JOIN (os
   WHERE csp.order_sentence_id=os.order_sentence_id
    AND os.order_sentence_id > 0
    AND os.oe_format_id != civ_ingred)
   JOIN (osd
   WHERE osd.order_sentence_id=os.order_sentence_id)
   JOIN (ofm
   WHERE ofm.oe_field_meaning_id=osd.oe_field_meaning_id)
  ORDER BY osd.oe_field_id
  HEAD REPORT
   row_cnt = 19, array_loc = 1
  HEAD osd.oe_field_id
   array_loc = 0
   CASE (trim(ofm.oe_field_meaning))
    OF "STRENGTHDOSE":
     array_loc = 1
    OF "STRENGTHDOSEUNIT":
     array_loc = 2
    OF "VOLUMEDOSE":
     array_loc = 3
    OF "VOLUMEDOSEUNIT":
     array_loc = 4
    OF "FREETXTDOSE":
     array_loc = 5
    OF "RXROUTE":
     array_loc = 6
    OF "DRUGFORM":
     array_loc = 7
    OF "FREQ":
     array_loc = 8
    OF "RXPRIORITY":
     array_loc = 9
    OF "SCH/PRN":
     array_loc = 10
    OF "PRNREASON":
     array_loc = 11
    OF "FREETEXTRATE":
     array_loc = 12
    OF "RATE":
     array_loc = 13
    OF "RATEUNIT":
     array_loc = 14
    OF "INFUSEOVER":
     array_loc = 15
    OF "INFUSEOVERUNIT":
     array_loc = 16
    OF "DURATION":
     array_loc = 17
    OF "DURATIONUNIT":
     array_loc = 18
    ELSE
     array_loc = row_cnt,stat = alterlist(used_fields->fields,row_cnt),row_cnt = (row_cnt+ 1)
   ENDCASE
   IF ((used_fields->fields[array_loc].oe_field_id > 0))
    cdup_fields = 1, text_row = (text_row+ 1),
    CALL text(text_row,2,build("Warning!! ...duplicate fields in use for field meaning=",ofm
     .oe_field_meaning)),
    text_row = (text_row+ 1),
    CALL text(text_row,2,"Extracted values for this field may be unpredictable"), text_row = (
    text_row+ 1)
   ENDIF
   used_fields->fields[array_loc].oe_field_id = osd.oe_field_id, used_fields->fields[array_loc].
   oe_field_meaning = ofm.oe_field_meaning
  WITH nullreport
 ;end select
 SELECT INTO "nl:"
  oef.oe_field_id, oef.description
  FROM (dummyt d  WITH seq = value(size(used_fields->fields,5))),
   order_entry_fields oef
  PLAN (d)
   JOIN (oef
   WHERE (oef.oe_field_id=used_fields->fields[d.seq].oe_field_id))
  DETAIL
   used_fields->fields[d.seq].field_desc = oef.description
  WITH nullreport
 ;end select
 CALL text(text_row,2,"Generating index of medication order sentence details...")
 SET text_row = (text_row+ 1)
 SELECT INTO "nl:"
  os.order_sentence_id, osd.oe_field_id, code_value = osd.default_parent_entity_id,
  osd.oe_field_value, osd.oe_field_display_value, code_value_display = cv.display,
  oefld.field_type_flag
  FROM order_catalog oc,
   cs_component csp,
   order_catalog_synonym ocs,
   order_sentence os,
   order_entry_format oef,
   order_sentence_detail osd,
   order_entry_fields oefld,
   code_value cv,
   order_catalog_synonym ocs2,
   ocs_facility_r ofr
  PLAN (oc
   WHERE oc.orderable_type_flag=6
    AND oc.active_ind=1)
   JOIN (ocs2
   WHERE oc.catalog_cd=ocs2.catalog_cd
    AND ocs2.active_ind=1
    AND ((ocs2.hide_flag=0) OR (ocs2.hide_flag=null)) )
   JOIN (ofr
   WHERE ofr.synonym_id=ocs2.synonym_id
    AND ((ofr.facility_cd=0) OR (ofr.facility_cd=cur_facility_cd)) )
   JOIN (csp
   WHERE oc.catalog_cd=csp.catalog_cd)
   JOIN (ocs
   WHERE ocs.synonym_id=csp.comp_id
    AND ocs.catalog_type_cd=cpharm)
   JOIN (os
   WHERE csp.order_sentence_id=os.order_sentence_id
    AND os.order_sentence_id > 0
    AND os.oe_format_id != civ_ingred)
   JOIN (oef
   WHERE oef.oe_format_id=outerjoin(ocs.oe_format_id)
    AND oef.action_type_cd=outerjoin(corder))
   JOIN (osd
   WHERE osd.order_sentence_id=os.order_sentence_id)
   JOIN (oefld
   WHERE oefld.oe_field_id=osd.oe_field_id)
   JOIN (cv
   WHERE osd.default_parent_entity_id=cv.code_value)
  ORDER BY os.order_sentence_id, osd.oe_field_id
  HEAD REPORT
   row_cnt = 0
  HEAD os.order_sentence_id
   order_sentence_count = (order_sentence_count+ 1)
  DETAIL
   row_cnt = (row_cnt+ 1), stat = alterlist(details->details,row_cnt), details->details[row_cnt].
   os_id = os.order_sentence_id,
   details->details[row_cnt].oe_field_id = osd.oe_field_id
   IF (osd.default_parent_entity_id > 0)
    details->details[row_cnt].field_value = cv.display
   ELSE
    IF (oefld.field_type_flag=7
     AND trim(osd.oe_field_display_value)="1")
     details->details[row_cnt].field_value = "Yes"
    ELSEIF (oefld.field_type_flag=7
     AND trim(osd.oe_field_display_value)="0")
     details->details[row_cnt].field_value = "No"
    ELSE
     details->details[row_cnt].field_value = osd.oe_field_display_value
    ENDIF
   ENDIF
  WITH nullreport, outerjoin = cv
 ;end select
 CALL text(text_row,2,concat("Building extract. ",build(order_sentence_count),
   " sentences to process..."))
 SET text_row = (text_row+ 1)
 FREE RECORD mylist2
 RECORD mylist2(
   1 vv[*]
     2 syn_id = f8
     2 vv_ind = c1
 )
 CALL load_current_vv(0)
 SELECT INTO "asc_cs_sent_extract.csv"
  primary_synonym = oc.primary_mnemonic, mnemonic_key_cap = ocs.mnemonic_key_cap, mnemonic_type = cv
  .display,
  mnemonic_type_cdf = cv.cdf_meaning, virtual_view = mylist2->vv[d2.seq].vv_ind, oef.oe_format_id,
  oef.oe_format_name, os.order_sentence_id, script = os.order_sentence_display_line,
  os.usage_flag, order_cat_cki = oc.cki, synonym_cki = ocs.cki,
  os.external_identifier, comment = lt.long_text
  FROM order_catalog oc,
   cs_component csp,
   order_catalog_synonym ocs,
   order_catalog_synonym ocs2,
   ocs_facility_r ofr,
   order_sentence os,
   order_entry_format oef,
   long_text lt,
   code_value cv,
   dummyt d1,
   (dummyt d2  WITH seq = value(size(mylist2->vv,5)))
  PLAN (oc
   WHERE oc.orderable_type_flag=6
    AND oc.active_ind=1)
   JOIN (ocs2
   WHERE oc.catalog_cd=ocs2.catalog_cd
    AND ocs2.active_ind=1
    AND ((ocs2.hide_flag=0) OR (ocs2.hide_flag=null)) )
   JOIN (ofr
   WHERE ofr.synonym_id=ocs2.synonym_id
    AND ((ofr.facility_cd=0) OR (ofr.facility_cd=cur_facility_cd)) )
   JOIN (csp
   WHERE oc.catalog_cd=csp.catalog_cd)
   JOIN (ocs
   WHERE ocs.synonym_id=csp.comp_id
    AND ocs.catalog_type_cd=cpharm)
   JOIN (os
   WHERE csp.order_sentence_id=os.order_sentence_id
    AND os.order_sentence_id > 0
    AND os.oe_format_id != civ_ingred)
   JOIN (oef
   WHERE oef.oe_format_id=outerjoin(ocs.oe_format_id)
    AND oef.action_type_cd=outerjoin(corder))
   JOIN (lt
   WHERE outerjoin(os.ord_comment_long_text_id)=lt.long_text_id)
   JOIN (cv
   WHERE ocs.mnemonic_type_cd=cv.code_value)
   JOIN (d1)
   JOIN (d2
   WHERE (ocs.synonym_id=mylist2->vv[d2.seq].syn_id))
  ORDER BY oef.oe_format_id, os.order_sentence_id
  HEAD REPORT
   os_cnt = 0, oef_cnt = 0, cur_field_match_found = 0,
   cur_sentence_pos = 0, cur_sentence_detail_count = 0, cur_sentence_details_found = 0,
   csv_line = concat("CareSet,SYNONYM_ID,Component,Virtual View,Primary,",
    "Synonym Type,Order Entry Format,ORDER_SENTENCE_ID,Sentence,","Order Catalog CKI,Synonym CKI,")
   FOR (x = 1 TO cnvtint(size(used_fields->fields,5)))
     csv_line = concat(csv_line,'"',"OE_FLD",trim(cnvtstring(x)),'"',
      ",",'"',"OE_FLD_VALUE",trim(cnvtstring(x)),'"',
      ",")
   ENDFOR
   csv_line = concat(csv_line,'"',"COMMENT",'"'), col 0, csv_line,
   row + 1, csv_line = ""
  HEAD oef.oe_format_id
   oef_cnt = (oef_cnt+ 1)
  HEAD os.order_sentence_id
   os_cnt = (os_cnt+ 1), cur_sentence_pos = 0, cur_sentence_detail_count = 0,
   cur_sentence_details_found = 0, cur_field_match_found = 0, csv_line = ""
   IF (os_cnt > 1)
    row + 1
   ENDIF
   csv_line = concat('"',strip_str_quotes(oc.primary_mnemonic),'"',",",'"',
    trim(cnvtstring(ocs.synonym_id)),'"',",",'"',trim(ocs.mnemonic),
    '"',",",'"',virtual_view,'"',
    ",",'"',trim(oc.primary_mnemonic),'"',",",
    '"',trim(cv.display),'"',",",'"',
    trim(oef.oe_format_name),'"',",",'"',trim(cnvtstring(os.order_sentence_id)),
    '"',",",'"',strip_str_quotes(os.order_sentence_display_line),'"',
    ",",'"',trim(oc.cki),'"',",",
    '"',trim(ocs.cki),'"',","), cur_sentence_pos = find_sentence_pos(os.order_sentence_id),
   cur_sentence_detail_count = count_sentence_details(cur_sentence_pos)
   FOR (y = 1 TO size(used_fields->fields,5))
     detail_text_value = "error", cur_field_match_found = 0
     IF ((used_fields->fields[y].oe_field_meaning="OTHER"))
      csv_line = concat(csv_line,'"',used_fields->fields[y].field_desc,'"',",")
     ELSE
      csv_line = concat(csv_line,'"',used_fields->fields[y].oe_field_meaning,'"',",")
     ENDIF
     IF (cur_sentence_detail_count > 0)
      FOR (z = 1 TO cur_sentence_detail_count)
        IF (cur_sentence_details_found < cur_sentence_detail_count
         AND (used_fields->fields[y].oe_field_id=get_sentence_detail_type(((cur_sentence_pos+ z) - 1)
         ))
         AND cur_field_match_found=0)
         cur_sentence_details_found = (cur_sentence_details_found+ 1), detail_text_value = trim(build
          (get_sentence_detail_value(cnvtreal(((cur_sentence_pos+ z) - 1))))), csv_line = concat(
          csv_line,'"',detail_text_value,'"',","),
         cur_field_match_found = 1
        ENDIF
      ENDFOR
      IF ((used_fields->fields[y].oe_field_id=cprn)
       AND cur_field_match_found=0)
       csv_line = concat(csv_line,'"',"No",'"',",")
      ELSEIF (cur_field_match_found=0)
       csv_line = concat(csv_line,'"','"',",")
      ENDIF
     ENDIF
   ENDFOR
   csv_line = concat(csv_line,'"',strip_str_quotes(lt.long_text),'"'), col 0, csv_line
  FOOT REPORT
   CALL text(text_row,2,"Extract complete"), text_row = (text_row+ 1)
  WITH outerjoin = d1, check, maxcol = 10000,
   format = variable, nullreport, noformfeed,
   landscape, maxrow = 1
 ;end select
#end_cs_sent_extract
 IF (cerror_flag=1)
  CALL text(text_row,2,"Unable to locate required information. Extract aborted.")
  SET text_row = (text_row+ 1)
 ENDIF
 GO TO cs_pp_extract_mode
#careset_extract_csv_exit
#powerplan_combo_rxmask
 CALL clear_screen(0)
 SET cpharm = uar_get_code_by("MEANING",6000,"PHARMACY")
 SELECT
  plan_name = substring(1,60,pcat.description), component = substring(1,60,ocs.mnemonic),
  component_rx_mask = evaluate(ocs.rx_mask,1,"Diluent",2,"Additive",
   4,"Medication",6,"Medication+Additive",16,
   "Sliding Scale",32,"Taper",concat(build(ocs.rx_mask),", Not Recommended")),
  sentence = substring(1,100,os.order_sentence_display_line), ocs.catalog_cd, ocs.synonym_id,
  os.rx_type_mean
  FROM pathway_catalog pcat,
   pw_cat_flex pcf,
   pathway_comp pcmp,
   order_catalog_synonym ocs,
   pw_comp_os_reltn pcor,
   order_sentence os
  PLAN (pcat
   WHERE pcat.active_ind=1)
   JOIN (pcf
   WHERE pcf.pathway_catalog_id=pcat.pathway_catalog_id
    AND ((pcf.parent_entity_id=0) OR (pcf.parent_entity_id=cur_facility_cd)) )
   JOIN (pcmp
   WHERE pcat.pathway_catalog_id=pcmp.pathway_catalog_id
    AND pcmp.sequence > 0)
   JOIN (ocs
   WHERE pcmp.parent_entity_id=ocs.synonym_id
    AND ocs.catalog_type_cd=cpharm
    AND  NOT (ocs.rx_mask IN (1, 2, 4))
    AND ocs.orderable_type_flag IN (0, 1))
   JOIN (pcor
   WHERE pcor.pathway_comp_id=outerjoin(pcmp.pathway_comp_id))
   JOIN (os
   WHERE os.order_sentence_id=outerjoin(pcor.order_sentence_id)
    AND ((os.rx_type_mean=null) OR (os.rx_type_mean=" ")) )
  ORDER BY cnvtupper(pcat.description), cnvtupper(ocs.mnemonic)
  WITH format = pcformat
 ;end select
#powerplan_combo_rxmask_exit
#med_orders_last_x_days
 CALL clear_screen(0)
 DECLARE order_type_string = vc
 DECLARE medication_search_string = vc
 DECLARE sort_string1 = vc
 DECLARE sort_string2 = vc
 DECLARE sort_string3 = vc
 SET cpharm = uar_get_code_by("MEANING",6000,"PHARMACY")
 SET lookback_days = 0
 CALL clear_screen(0)
 CALL text(5,2,"How many days to look back? (default = 1)")
 CALL accept(5,45,"99;",1
  WHERE curaccept < 31
   AND curaccept > 0)
 SET lookback_days = curaccept
 CALL text(7,2,"Include non-standard order types? (default = N)")
 CALL accept(7,51,"C;CU","N"
  WHERE curaccept IN ("Y", "N"))
 IF (curaccept="N")
  SET order_type_string = "o.orig_ord_as_flag = 0"
 ELSE
  SET order_type_string = "o.orig_ord_as_flag >= 0"
 ENDIF
 CALL text(9,2,"Limit to orders to a specific medication? (default = *)")
 CALL accept(10,2,"P(30);CU","*")
 SET medication_search_string = cnvtupper(trim(curaccept))
 CALL text(12,2,"Sort method? (default = 1)")
 CALL text(14,5,"(1) order entry time")
 CALL text(15,5,"(2) ordering user")
 CALL text(16,5,"(3) medication")
 CALL accept(12,30,"99;",1
  WHERE curaccept IN (1, 2, 3))
 IF (curaccept=1)
  SET sort_string1 = "o.orig_order_dt_tm"
  SET sort_string2 = "cnvtupper(pr.name_full_formatted)"
  SET sort_string3 = "cnvtupper(o.order_mnemonic)"
 ELSEIF (curaccept=2)
  SET sort_string1 = "cnvtupper(pr.name_full_formatted)"
  SET sort_string2 = "o.orig_order_dt_tm"
  SET sort_string3 = "cnvtupper(o.order_mnemonic)"
 ELSE
  SET sort_string1 = "cnvtupper(o.order_mnemonic)"
  SET sort_string2 = "o.orig_order_dt_tm"
  SET sort_string3 = "cnvtupper(pr.name_full_formatted)"
 ENDIF
 SELECT
  status = substring(1,20,uar_get_code_display(o.order_status_cd)), entry_dt_tm = substring(1,20,
   format(o.orig_order_dt_tm,"@SHORTDATETIME")), patient_name = substring(1,40,p.name_full_formatted),
  patient_loc = substring(1,25,uar_get_code_display(ed.loc_nurse_unit_cd)), order_type = evaluate(o
   .orig_ord_as_flag,0,"Normal Order",1,"Prescription/Discharge Order",
   2,"Recorded / Home Meds",3,"Patients Own Meds",4,
   "Pharmacy Charge Only",5,"Satellite (Super Bill) Meds"), order_name = substring(1,60,o
   .order_mnemonic),
  order_details = substring(1,60,o.simplified_display_line), entered_by = substring(1,50,pr
   .name_full_formatted), facility = substring(1,40,uar_get_code_display(ed.loc_facility_cd)),
  o.order_id
  FROM orders o,
   person p,
   encntr_domain ed,
   order_action oa,
   prsnl pr
  PLAN (o
   WHERE o.orig_order_dt_tm > cnvtdatetime((curdate - lookback_days),curtime3)
    AND parser(order_type_string)
    AND o.template_order_flag IN (0, 1)
    AND o.cs_flag != 1
    AND o.catalog_type_cd=cpharm
    AND cnvtupper(o.order_mnemonic)=patstring(build(medication_search_string,"*")))
   JOIN (p
   WHERE p.person_id=o.person_id)
   JOIN (ed
   WHERE ed.encntr_id=o.encntr_id
    AND ((cur_facility_cd=0) OR (ed.loc_facility_cd=cur_facility_cd)) )
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.action_sequence=1)
   JOIN (pr
   WHERE pr.person_id=oa.action_personnel_id)
  ORDER BY parser(sort_string1), parser(sort_string2), parser(sort_string3)
  WITH nullreport, format = pcformat
 ;end select
 GO TO pharm_data_lookup_mode
#med_orders_last_x_days_exit
#prod_no_ordas_syn
 CALL clear_screen(0)
 SET cbrand = uar_get_code_by("MEANING",11000,"BRAND_NAME")
 SET cdesc = uar_get_code_by("MEANING",11000,"DESC")
 SET cinpatient = uar_get_code_by("MEANING",4500,"INPATIENT")
 SET csystem = uar_get_code_by("MEANING",4062,"SYSTEM")
 SET cprimtype = uar_get_code_by("MEANING",6011,"PRIMARY")
 SET cdcptype = uar_get_code_by("MEANING",6011,"DCP")
 SET cctype = uar_get_code_by("MEANING",6011,"DISPDRUG")
 SET cmtype = uar_get_code_by("MEANING",6011,"GENERICTOP")
 SET cntype = uar_get_code_by("MEANING",6011,"TRADETOP")
 SET cpharm = uar_get_code_by("MEANING",6000,"PHARMACY")
 SET csyspkgtyp = uar_get_code_by("MEANING",4062,"SYSPKGTYP")
 SET corderable = uar_get_code_by("MEANING",4063,"ORDERABLE")
 FREE RECORD ordered_as
 RECORD ordered_as(
   1 ordered_as[*]
     2 item_id = f8
     2 med_oe_defaults_id = f8
     2 catalog_cd = f8
     2 rx_mask = f8
 )
 SELECT INTO "nl:"
  ocir.item_id, mod.*
  FROM order_catalog_item_r ocir,
   item_definition id,
   med_def_flex mdf,
   order_catalog_synonym ocs,
   med_flex_object_idx mfoi,
   med_oe_defaults mod,
   med_def_flex mdf2,
   med_flex_object_idx mfoi2
  PLAN (ocir)
   JOIN (id
   WHERE ocir.item_id=id.item_id
    AND id.active_ind=1)
   JOIN (ocs
   WHERE ocs.synonym_id=ocir.synonym_id)
   JOIN (mdf
   WHERE mdf.item_id=ocir.item_id
    AND mdf.flex_type_cd=csystem
    AND mdf.pharmacy_type_cd=cinpatient)
   JOIN (mfoi
   WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
    AND mfoi.parent_entity_name="MED_OE_DEFAULTS")
   JOIN (mod
   WHERE mod.med_oe_defaults_id=mfoi.parent_entity_id
    AND ((mod.ord_as_synonym_id=0) OR (mod.ord_as_synonym_id=null)) )
   JOIN (mdf2
   WHERE mdf2.item_id=ocir.item_id
    AND mdf2.flex_type_cd=csyspkgtyp
    AND mdf2.pharmacy_type_cd=cinpatient)
   JOIN (mfoi2
   WHERE mfoi2.med_def_flex_id=mdf2.med_def_flex_id
    AND mfoi2.flex_object_type_cd=corderable
    AND ((mfoi2.parent_entity_id=0) OR (mfoi2.parent_entity_id=cur_facility_cd)) )
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(ordered_as->ordered_as,cnt), ordered_as->ordered_as[cnt].item_id
    = ocir.item_id,
   ordered_as->ordered_as[cnt].catalog_cd = ocir.catalog_cd, ordered_as->ordered_as[cnt].rx_mask =
   ocs.rx_mask, ordered_as->ordered_as[cnt].med_oe_defaults_id = mod.med_oe_defaults_id
  FOOT REPORT
   CALL echo("."),
   CALL echo("-------------------------------------"),
   CALL echo(build("Products found:",size(ordered_as->ordered_as,5))),
   CALL echo("-------------------------------------")
  WITH nullreport
 ;end select
 SELECT
  product_desc = substring(1,60,mi.value), emar_display = substring(1,100,ocs.mnemonic)
  FROM (dummyt d  WITH seq = value(size(ordered_as->ordered_as,5))),
   med_identifier mi,
   medication_definition md,
   order_catalog_item_r ocir,
   order_catalog_synonym ocs
  PLAN (d)
   JOIN (mi
   WHERE (mi.item_id=ordered_as->ordered_as[d.seq].item_id)
    AND mi.med_product_id=0
    AND mi.med_identifier_type_cd=cdesc
    AND mi.active_ind=1
    AND mi.primary_ind=1
    AND mi.pharmacy_type_cd=cinpatient)
   JOIN (md
   WHERE md.item_id=mi.item_id)
   JOIN (ocir
   WHERE md.item_id=ocir.item_id)
   JOIN (ocs
   WHERE ocs.catalog_cd=ocir.catalog_cd
    AND ocs.mnemonic_type_cd=cprimtype)
  ORDER BY cnvtupper(mi.value), emar_display
  WITH nullreport, format = pcformat
 ;end select
#prod_no_ordas_syn_exit
#rxm_poc_linking_output
 CALL clear_screen(0)
 CALL video("N")
 CALL text(3,3," Output to CSV file? (1) or display results on screen? (2) ")
 CALL text(5,3," * Results written to file will be saved as 'asc_rxm_poc_linking.csv' in CCLUSERDIR "
  )
 CALL accept(3,62,"99;",1
  WHERE curaccept IN (1, 2))
 CASE (curaccept)
  OF 1:
   EXECUTE FROM rxm_poc_linking TO rxm_poc_linking_exit
  OF 2:
   EXECUTE FROM rxm_poc_linking_scr TO rxm_poc_linking_scr_exit
 ENDCASE
#rxm_poc_linking_output_exit
#asc_prdct_ordas_output
 CALL clear_screen(0)
 CALL video("N")
 CALL text(3,3," Output to CSV file? (1) or display results on screen? (2) ")
 CALL text(5,3," * Results written to file will be saved as 'asc_prdct_ordas.csv' in CCLUSERDIR ")
 CALL accept(3,62,"99;",1
  WHERE curaccept IN (1, 2))
 CASE (curaccept)
  OF 1:
   EXECUTE FROM asc_prdct_ordas TO asc_prdct_ordas_exit
  OF 2:
   EXECUTE FROM asc_prdct_ordas_scr TO asc_prdct_ordas_scr_exit
 ENDCASE
#asc_prdct_ordas_output_exit
#rxm_poc_linking
 CALL clear_screen(0)
 DECLARE line = vc
 SET cinpatient = uar_get_code_by("MEANING",4500,"INPATIENT")
 SET csystem = uar_get_code_by("MEANING",4062,"SYSTEM")
 SET csystempkg = uar_get_code_by("MEANING",4062,"SYSPKGTYP")
 SET cdesc = uar_get_code_by("MEANING",11000,"DESC")
 SET crxm = uar_get_code_by("MEANING",6011,"RXMNEMONIC")
 SET csyspkgtyp = uar_get_code_by("MEANING",4062,"SYSPKGTYP")
 SET corderable = uar_get_code_by("MEANING",4063,"ORDERABLE")
 SELECT INTO "asc_rxm_poc_linking.csv"
  sir.synonym_id, mi1.item_id, ordered_product = substring(1,50,mi1.value),
  form1 = uar_get_code_display(md1.form_cd), mi2.item_id, substitute_product = substring(1,50,mi2
   .value),
  form2 = uar_get_code_display(md2.form_cd)
  FROM synonym_item_r sir,
   order_catalog_synonym ocs,
   order_catalog oc,
   med_identifier mi1,
   med_identifier mi2,
   medication_definition md1,
   medication_definition md2,
   med_def_flex mdf1,
   med_flex_object_idx mfoi1,
   med_def_flex mdf2,
   med_flex_object_idx mfoi2
  PLAN (sir)
   JOIN (ocs
   WHERE ocs.synonym_id=sir.synonym_id
    AND ocs.mnemonic_type_cd=crxm)
   JOIN (mi1
   WHERE mi1.item_id=ocs.item_id
    AND mi1.med_product_id=0
    AND mi1.med_identifier_type_cd=cdesc
    AND mi1.active_ind=1
    AND mi1.primary_ind=1
    AND mi1.pharmacy_type_cd=cinpatient)
   JOIN (md1
   WHERE md1.item_id=mi1.item_id)
   JOIN (mdf1
   WHERE mdf1.item_id=mi1.item_id
    AND mdf1.flex_type_cd=csyspkgtyp
    AND mdf1.pharmacy_type_cd=cinpatient)
   JOIN (mfoi1
   WHERE mfoi1.med_def_flex_id=mdf1.med_def_flex_id
    AND mfoi1.flex_object_type_cd=corderable
    AND ((mfoi1.parent_entity_id=0) OR (mfoi1.parent_entity_id=cur_facility_cd)) )
   JOIN (oc
   WHERE oc.catalog_cd=ocs.catalog_cd)
   JOIN (mi2
   WHERE mi2.item_id=sir.item_id
    AND mi2.med_product_id=0
    AND mi2.med_identifier_type_cd=cdesc
    AND mi2.active_ind=1
    AND mi2.primary_ind=1
    AND mi2.pharmacy_type_cd=cinpatient)
   JOIN (md2
   WHERE md2.item_id=mi2.item_id)
   JOIN (mdf2
   WHERE mdf2.item_id=mi2.item_id
    AND mdf2.flex_type_cd=csyspkgtyp
    AND mdf2.pharmacy_type_cd=cinpatient)
   JOIN (mfoi2
   WHERE mfoi2.med_def_flex_id=mdf2.med_def_flex_id
    AND mfoi2.flex_object_type_cd=corderable
    AND ((mfoi2.parent_entity_id=0) OR (mfoi2.parent_entity_id=cur_facility_cd)) )
  ORDER BY cnvtupper(oc.primary_mnemonic), mi1.value_key, mi2.value_key
  HEAD REPORT
   synonym_cnt = 0, col 0, '"',
   "SYNONYM_ID", '"', ",",
   '"', "ORDERED_PRODUCT_ITEM_ID", '"',
   ",", '"', "ORDERED_PRODUCT",
   '"', ",", '"',
   "ORDERED_PRODUCT_FORM", '"', ",",
   '"', "SUBSTITUTE_PRODUCT_ITEM_ID", '"',
   ",", '"', "SUBSTITUTE_PRODUCT",
   '"', ",", '"',
   "SUBSTITUTE_PRODUCT_FORM", '"', row + 1
  DETAIL
   line = concat('"',trim(cnvtstring(sir.synonym_id)),'"',",",'"',
    trim(cnvtstring(mi1.item_id)),'"',",",'"',trim(mi1.value),
    '"',",",'"',trim(uar_get_code_display(md1.form_cd)),'"',
    ",",'"',trim(cnvtstring(mi2.item_id)),'"',",",
    '"',trim(mi2.value),'"',",",'"',
    trim(uar_get_code_display(md2.form_cd)),'"'), col 0, line,
   row + 1
  WITH check, maxcol = 2500, format = variable,
   nullreport, noformfeed, landscape,
   maxrow = 1
 ;end select
#rxm_poc_linking_exit
#rxm_poc_linking_scr
 CALL clear_screen(0)
 SET cinpatient = uar_get_code_by("MEANING",4500,"INPATIENT")
 SET csystem = uar_get_code_by("MEANING",4062,"SYSTEM")
 SET csystempkg = uar_get_code_by("MEANING",4062,"SYSPKGTYP")
 SET cdesc = uar_get_code_by("MEANING",11000,"DESC")
 SET crxm = uar_get_code_by("MEANING",6011,"RXMNEMONIC")
 SET csyspkgtyp = uar_get_code_by("MEANING",4062,"SYSPKGTYP")
 SET corderable = uar_get_code_by("MEANING",4063,"ORDERABLE")
 SELECT
  sir.synonym_id, mi1.item_id, ordered_product = substring(1,50,mi1.value),
  form = uar_get_code_display(md1.form_cd), mi2.item_id, substitute_product = substring(1,50,mi2
   .value),
  form = uar_get_code_display(md2.form_cd)
  FROM synonym_item_r sir,
   order_catalog_synonym ocs,
   order_catalog oc,
   med_identifier mi1,
   med_identifier mi2,
   medication_definition md1,
   medication_definition md2,
   med_def_flex mdf1,
   med_flex_object_idx mfoi1,
   med_def_flex mdf2,
   med_flex_object_idx mfoi2
  PLAN (sir)
   JOIN (ocs
   WHERE ocs.synonym_id=sir.synonym_id
    AND ocs.mnemonic_type_cd=crxm)
   JOIN (mi1
   WHERE mi1.item_id=ocs.item_id
    AND mi1.med_product_id=0
    AND mi1.med_identifier_type_cd=cdesc
    AND mi1.active_ind=1
    AND mi1.primary_ind=1
    AND mi1.pharmacy_type_cd=cinpatient)
   JOIN (md1
   WHERE md1.item_id=mi1.item_id)
   JOIN (mdf1
   WHERE mdf1.item_id=mi1.item_id
    AND mdf1.flex_type_cd=csyspkgtyp
    AND mdf1.pharmacy_type_cd=cinpatient)
   JOIN (mfoi1
   WHERE mfoi1.med_def_flex_id=mdf1.med_def_flex_id
    AND mfoi1.flex_object_type_cd=corderable
    AND ((mfoi1.parent_entity_id=0) OR (mfoi1.parent_entity_id=cur_facility_cd)) )
   JOIN (oc
   WHERE oc.catalog_cd=ocs.catalog_cd)
   JOIN (mi2
   WHERE mi2.item_id=sir.item_id
    AND mi2.med_product_id=0
    AND mi2.med_identifier_type_cd=cdesc
    AND mi2.active_ind=1
    AND mi2.primary_ind=1
    AND mi2.pharmacy_type_cd=cinpatient)
   JOIN (md2
   WHERE md2.item_id=mi2.item_id)
   JOIN (mdf2
   WHERE mdf2.item_id=mi2.item_id
    AND mdf2.flex_type_cd=csyspkgtyp
    AND mdf2.pharmacy_type_cd=cinpatient)
   JOIN (mfoi2
   WHERE mfoi2.med_def_flex_id=mdf2.med_def_flex_id
    AND mfoi2.flex_object_type_cd=corderable
    AND ((mfoi2.parent_entity_id=0) OR (mfoi2.parent_entity_id=cur_facility_cd)) )
  ORDER BY cnvtupper(oc.primary_mnemonic), mi1.value_key, mi2.value_key
  WITH nullreport, format = pcformat
 ;end select
#rxm_poc_linking_scr_exit
#asc_prdct_ordas
 CALL clear_screen(0)
 SET cbrand = uar_get_code_by("MEANING",11000,"BRAND_NAME")
 SET cdesc = uar_get_code_by("MEANING",11000,"DESC")
 SET cinpatient = uar_get_code_by("MEANING",4500,"INPATIENT")
 SET csystem = uar_get_code_by("MEANING",4062,"SYSTEM")
 SET cprimtype = uar_get_code_by("MEANING",6011,"PRIMARY")
 SET cdcptype = uar_get_code_by("MEANING",6011,"DCP")
 SET cctype = uar_get_code_by("MEANING",6011,"DISPDRUG")
 SET cmtype = uar_get_code_by("MEANING",6011,"GENERICTOP")
 SET cntype = uar_get_code_by("MEANING",6011,"TRADETOP")
 SET csyspkgtyp = uar_get_code_by("MEANING",4062,"SYSPKGTYP")
 SET corderable = uar_get_code_by("MEANING",4063,"ORDERABLE")
 FREE RECORD ordered_as
 RECORD ordered_as(
   1 ordered_as[*]
     2 item_id = f8
     2 med_oe_defaults_id = f8
     2 catalog_cd = f8
     2 ord_as_synonym_id = f8
     2 link_type = f8
     2 already_existed = f8
     2 rx_mask = f8
 )
 SELECT INTO "nl:"
  ocir.item_id, mod.*
  FROM order_catalog_item_r ocir,
   item_definition id,
   med_def_flex mdf,
   med_def_flex mdf2,
   order_catalog_synonym ocs,
   med_flex_object_idx mfoi,
   med_flex_object_idx mfoi2,
   med_oe_defaults mod
  PLAN (ocir)
   JOIN (id
   WHERE ocir.item_id=id.item_id
    AND id.active_ind=1)
   JOIN (ocs
   WHERE ocs.synonym_id=ocir.synonym_id)
   JOIN (mdf
   WHERE mdf.item_id=ocir.item_id
    AND mdf.flex_type_cd=csystem
    AND mdf.pharmacy_type_cd=cinpatient)
   JOIN (mfoi
   WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
    AND mfoi.parent_entity_name="MED_OE_DEFAULTS")
   JOIN (mdf2
   WHERE mdf2.item_id=ocir.item_id
    AND mdf2.flex_type_cd=csyspkgtyp
    AND mdf2.pharmacy_type_cd=cinpatient)
   JOIN (mfoi2
   WHERE mfoi2.med_def_flex_id=mdf2.med_def_flex_id
    AND mfoi2.flex_object_type_cd=corderable
    AND ((mfoi2.parent_entity_id=0) OR (mfoi2.parent_entity_id=cur_facility_cd)) )
   JOIN (mod
   WHERE mod.med_oe_defaults_id=mfoi.parent_entity_id
    AND mod.ord_as_synonym_id > 0)
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(ordered_as->ordered_as,cnt), ordered_as->ordered_as[cnt].item_id
    = ocir.item_id,
   ordered_as->ordered_as[cnt].catalog_cd = ocir.catalog_cd, ordered_as->ordered_as[cnt].rx_mask =
   ocs.rx_mask, ordered_as->ordered_as[cnt].med_oe_defaults_id = mod.med_oe_defaults_id,
   ordered_as->ordered_as[cnt].ord_as_synonym_id = mod.ord_as_synonym_id, ordered_as->ordered_as[cnt]
   .link_type = 4, ordered_as->ordered_as[cnt].already_existed = 1
  FOOT REPORT
   CALL echo("."),
   CALL echo("-------------------------------------"),
   CALL echo(build("Products found:",size(ordered_as->ordered_as,5))),
   CALL echo("-------------------------------------")
  WITH nullreport
 ;end select
 DECLARE line = vc
 SELECT INTO "asc_prdct_ordas.csv"
  product_desc = substring(1,60,mi.value), emar_display =
  IF (ocs.synonym_id > 0
   AND (ordered_as->ordered_as[d.seq].rx_mask=1)) substring(1,100,ocs.mnemonic)
  ELSEIF (ocs.synonym_id > 0) substring(1,100,concat(trim(ocs2.mnemonic)," (",trim(ocs.mnemonic),")")
    )
  ELSE substring(1,100,ocs2.mnemonic)
  ENDIF
  , md.item_id,
  ocs.synonym_id, ocs.catalog_cd
  FROM (dummyt d  WITH seq = value(size(ordered_as->ordered_as,5))),
   med_identifier mi,
   medication_definition md,
   order_catalog_item_r ocir,
   order_catalog_synonym ocs,
   order_catalog_synonym ocs2
  PLAN (d)
   JOIN (mi
   WHERE (mi.item_id=ordered_as->ordered_as[d.seq].item_id)
    AND mi.med_product_id=0
    AND mi.med_identifier_type_cd=cdesc
    AND mi.active_ind=1
    AND mi.primary_ind=1
    AND mi.pharmacy_type_cd=cinpatient)
   JOIN (md
   WHERE md.item_id=mi.item_id)
   JOIN (ocs
   WHERE (ocs.synonym_id=ordered_as->ordered_as[d.seq].ord_as_synonym_id))
   JOIN (ocir
   WHERE md.item_id=ocir.item_id)
   JOIN (ocs2
   WHERE ocs2.catalog_cd=ocir.catalog_cd
    AND ocs2.mnemonic_type_cd=cprimtype)
  ORDER BY cnvtupper(mi.value), emar_display
  HEAD REPORT
   col 0, "PRODUCT_DESC,EMAR_DISPLAY,ITEM_ID,SYNONYM_ID,CATALOG_CD"
  DETAIL
   row + 1, line = concat('"',trim(mi.value),'"',",",'"',
    trim(emar_display),'"',",",'"',trim(cnvtstring(md.item_id)),
    '"',",",'"',trim(cnvtstring(ocs.synonym_id)),'"',
    ",",'"',trim(cnvtstring(ocs.catalog_cd)),'"'), col 0,
   line
  WITH check, maxcol = 2000, format = variable,
   nullreport, noformfeed, landscape,
   maxrow = 1
 ;end select
#asc_prdct_ordas_exit
#asc_prdct_ordas_scr
 CALL clear_screen(0)
 SET cbrand = uar_get_code_by("MEANING",11000,"BRAND_NAME")
 SET cdesc = uar_get_code_by("MEANING",11000,"DESC")
 SET cinpatient = uar_get_code_by("MEANING",4500,"INPATIENT")
 SET csystem = uar_get_code_by("MEANING",4062,"SYSTEM")
 SET cprimtype = uar_get_code_by("MEANING",6011,"PRIMARY")
 SET cdcptype = uar_get_code_by("MEANING",6011,"DCP")
 SET cctype = uar_get_code_by("MEANING",6011,"DISPDRUG")
 SET cmtype = uar_get_code_by("MEANING",6011,"GENERICTOP")
 SET cntype = uar_get_code_by("MEANING",6011,"TRADETOP")
 SET csyspkgtyp = uar_get_code_by("MEANING",4062,"SYSPKGTYP")
 SET corderable = uar_get_code_by("MEANING",4063,"ORDERABLE")
 FREE RECORD ordered_as
 RECORD ordered_as(
   1 ordered_as[*]
     2 item_id = f8
     2 med_oe_defaults_id = f8
     2 catalog_cd = f8
     2 ord_as_synonym_id = f8
     2 link_type = f8
     2 already_existed = f8
     2 rx_mask = f8
 )
 SELECT INTO "nl:"
  ocir.item_id, mod.*
  FROM order_catalog_item_r ocir,
   item_definition id,
   med_def_flex mdf,
   med_def_flex mdf2,
   order_catalog_synonym ocs,
   med_flex_object_idx mfoi,
   med_flex_object_idx mfoi2,
   med_oe_defaults mod
  PLAN (ocir)
   JOIN (id
   WHERE ocir.item_id=id.item_id
    AND id.active_ind=1)
   JOIN (ocs
   WHERE ocs.synonym_id=ocir.synonym_id)
   JOIN (mdf
   WHERE mdf.item_id=ocir.item_id
    AND mdf.flex_type_cd=csystem
    AND mdf.pharmacy_type_cd=cinpatient)
   JOIN (mfoi
   WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
    AND mfoi.parent_entity_name="MED_OE_DEFAULTS")
   JOIN (mdf2
   WHERE mdf2.item_id=ocir.item_id
    AND mdf2.flex_type_cd=csyspkgtyp
    AND mdf2.pharmacy_type_cd=cinpatient)
   JOIN (mfoi2
   WHERE mfoi2.med_def_flex_id=mdf2.med_def_flex_id
    AND mfoi2.flex_object_type_cd=corderable
    AND ((mfoi2.parent_entity_id=0) OR (mfoi2.parent_entity_id=cur_facility_cd)) )
   JOIN (mod
   WHERE mod.med_oe_defaults_id=mfoi.parent_entity_id
    AND mod.ord_as_synonym_id > 0)
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(ordered_as->ordered_as,cnt), ordered_as->ordered_as[cnt].item_id
    = ocir.item_id,
   ordered_as->ordered_as[cnt].catalog_cd = ocir.catalog_cd, ordered_as->ordered_as[cnt].rx_mask =
   ocs.rx_mask, ordered_as->ordered_as[cnt].med_oe_defaults_id = mod.med_oe_defaults_id,
   ordered_as->ordered_as[cnt].ord_as_synonym_id = mod.ord_as_synonym_id, ordered_as->ordered_as[cnt]
   .link_type = 4, ordered_as->ordered_as[cnt].already_existed = 1
  FOOT REPORT
   CALL echo("."),
   CALL echo("-------------------------------------"),
   CALL echo(build("Products found:",size(ordered_as->ordered_as,5))),
   CALL echo("-------------------------------------")
  WITH nullreport
 ;end select
 SELECT
  product_desc = substring(1,60,mi.value), emar_display =
  IF (ocs.synonym_id > 0
   AND (ordered_as->ordered_as[d.seq].rx_mask=1)) substring(1,100,ocs.mnemonic)
  ELSEIF (ocs.synonym_id > 0) substring(1,100,concat(trim(ocs2.mnemonic)," (",trim(ocs.mnemonic),")")
    )
  ELSE substring(1,100,ocs2.mnemonic)
  ENDIF
  , mi.item_id,
  ocs.synonym_id
  FROM (dummyt d  WITH seq = value(size(ordered_as->ordered_as,5))),
   med_identifier mi,
   medication_definition md,
   order_catalog_item_r ocir,
   order_catalog_synonym ocs,
   order_catalog_synonym ocs2
  PLAN (d)
   JOIN (mi
   WHERE (mi.item_id=ordered_as->ordered_as[d.seq].item_id)
    AND mi.med_product_id=0
    AND mi.med_identifier_type_cd=cdesc
    AND mi.active_ind=1
    AND mi.primary_ind=1
    AND mi.pharmacy_type_cd=cinpatient)
   JOIN (md
   WHERE md.item_id=mi.item_id)
   JOIN (ocs
   WHERE (ocs.synonym_id=ordered_as->ordered_as[d.seq].ord_as_synonym_id))
   JOIN (ocir
   WHERE md.item_id=ocir.item_id)
   JOIN (ocs2
   WHERE ocs2.catalog_cd=ocir.catalog_cd
    AND ocs2.mnemonic_type_cd=cprimtype)
  ORDER BY cnvtupper(mi.value), emar_display
  WITH nullreport, format = pcformat
 ;end select
#asc_prdct_ordas_scr_exit
#asc_set_ordas_syn
 CALL clear_screen(0)
 CALL video("R")
 CALL text(2,3,"                                                                  ")
 CALL text(3,3," This program will set ORDERED AS synonyms for PharmNet Inpatient ")
 CALL text(4,3," formulary products, based on:                                    ")
 CALL text(5,3,"                                                                  ")
 CALL text(6,3," 1) Formulary product / CPOE synonym linking                      ")
 CALL text(7,3," 2) Multum MMDC to CNUM CKI mapping                               ")
 CALL text(8,3," 3) Formulary brand name to CPOE synonym matching                 ")
 CALL text(9,3,"                                                                  ")
 CALL text(10,3," Any default values set using this program are intended as a      ")
 CALL text(11,3," starting point only and must be carefully reviewed.              ")
 CALL text(12,3,"                                                                  ")
 CALL text(13,3," If CPOE will be implemented, it is highly recommended that you   ")
 CALL text(14,3," run this utility AFTER appropriate links have been established   ")
 CALL text(15,3," between products and CPOE synonyms.                              ")
 CALL text(16,3,"                                                                  ")
 CALL video("N")
 CALL text(20,3,"Proceed?")
 CALL accept(20,12,"C;CU","N"
  WHERE curaccept IN ("Y", "N"))
 SET cpharm = uar_get_code_by("MEANING",6000,"PHARMACY")
 SET cprimary = uar_get_code_by("MEANING",6011,"PRIMARY")
 SET csystem = uar_get_code_by("MEANING",4062,"SYSTEM")
 SET csyspkgtyp = uar_get_code_by("MEANING",4062,"SYSPKGTYP")
 SET corderable = uar_get_code_by("MEANING",4063,"ORDERABLE")
 SET cinpatient = uar_get_code_by("MEANING",4500,"INPATIENT")
 SET cdesc = uar_get_code_by("MEANING",11000,"DESC")
 IF (curaccept="Y")
  FREE RECORD available_products
  RECORD available_products(
    1 products[*]
      2 item_id = f8
      2 catalog_cd = f8
  )
  SELECT INTO "nl:"
   md.item_id, product_desc = substring(1,50,mi.value), mfoi.*
   FROM medication_definition md,
    order_catalog_item_r ocir,
    item_definition id,
    med_def_flex mdf,
    med_flex_object_idx mfoi,
    med_identifier mi
   PLAN (md)
    JOIN (ocir
    WHERE ocir.item_id=md.item_id)
    JOIN (id
    WHERE id.item_id=ocir.item_id
     AND id.active_ind=1)
    JOIN (mdf
    WHERE mdf.item_id=md.item_id
     AND mdf.flex_type_cd=csyspkgtyp
     AND mdf.pharmacy_type_cd=cinpatient)
    JOIN (mfoi
    WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
     AND mfoi.flex_object_type_cd=corderable
     AND ((mfoi.parent_entity_id=0) OR (mfoi.parent_entity_id=cur_facility_cd)) )
    JOIN (mi
    WHERE mi.item_id=md.item_id
     AND mi.active_ind=1
     AND mi.primary_ind=1
     AND mi.med_product_id=0
     AND mi.med_identifier_type_cd=cdesc
     AND mi.pharmacy_type_cd=cinpatient)
   ORDER BY mi.value
   HEAD REPORT
    cnt = 0
   HEAD md.item_id
    cnt = (cnt+ 1), stat = alterlist(available_products->products,cnt), available_products->products[
    cnt].item_id = md.item_id,
    available_products->products[cnt].catalog_cd = ocir.catalog_cd
   WITH nullreport
  ;end select
  CALL clear_screen(0)
  SET cbrand = uar_get_code_by("MEANING",11000,"BRAND_NAME")
  SET cdesc = uar_get_code_by("MEANING",11000,"DESC")
  SET cinpatient = uar_get_code_by("MEANING",4500,"INPATIENT")
  SET csystem = uar_get_code_by("MEANING",4062,"SYSTEM")
  SET cprimtype = uar_get_code_by("MEANING",6011,"PRIMARY")
  SET cdcptype = uar_get_code_by("MEANING",6011,"DCP")
  SET cctype = uar_get_code_by("MEANING",6011,"DISPDRUG")
  SET cmtype = uar_get_code_by("MEANING",6011,"GENERICTOP")
  SET cntype = uar_get_code_by("MEANING",6011,"TRADETOP")
  FREE RECORD ordered_as
  RECORD ordered_as(
    1 ordered_as[*]
      2 item_id = f8
      2 med_oe_defaults_id = f8
      2 catalog_cd = f8
      2 ord_as_synonym_id = f8
      2 link_type = f8
      2 already_existed = f8
      2 rx_mask = f8
  )
  CALL text(5,3," Generating list of formulary products...           ")
  SELECT INTO "nl:"
   ocir.item_id
   FROM order_catalog_item_r ocir,
    (dummyt d  WITH seq = value(size(available_products->products,5))),
    item_definition id,
    med_def_flex mdf,
    order_catalog_synonym ocs,
    med_flex_object_idx mfoi,
    med_oe_defaults mod
   PLAN (ocir)
    JOIN (d
    WHERE (available_products->products[d.seq].item_id=ocir.item_id))
    JOIN (id
    WHERE ocir.item_id=id.item_id
     AND id.active_ind=1)
    JOIN (ocs
    WHERE ocs.synonym_id=ocir.synonym_id)
    JOIN (mdf
    WHERE mdf.item_id=ocir.item_id
     AND mdf.flex_type_cd=csystem
     AND mdf.pharmacy_type_cd=cinpatient)
    JOIN (mfoi
    WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
     AND mfoi.parent_entity_name="MED_OE_DEFAULTS")
    JOIN (mod
    WHERE mod.med_oe_defaults_id=mfoi.parent_entity_id)
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt = (cnt+ 1), stat = alterlist(ordered_as->ordered_as,cnt), ordered_as->ordered_as[cnt].item_id
     = ocir.item_id,
    ordered_as->ordered_as[cnt].catalog_cd = ocir.catalog_cd, ordered_as->ordered_as[cnt].rx_mask =
    ocs.rx_mask, ordered_as->ordered_as[cnt].med_oe_defaults_id = mod.med_oe_defaults_id
    IF (mod.ord_as_synonym_id > 0)
     ordered_as->ordered_as[cnt].ord_as_synonym_id = mod.ord_as_synonym_id, ordered_as->ordered_as[
     cnt].link_type = 4, ordered_as->ordered_as[cnt].already_existed = 1
    ENDIF
   FOOT REPORT
    CALL echo("."),
    CALL echo("-------------------------------------"),
    CALL echo(build("Products found:",size(ordered_as->ordered_as,5))),
    CALL echo("-------------------------------------")
   WITH nullreport
  ;end select
  CALL text(7,3," Analyzing product / CPOE linking...                ")
  SELECT INTO "nl:"
   sir.item_id, ocs.synonym_id, synonym_type = uar_get_code_display(ocs.mnemonic_type_cd),
   synonym = substring(1,50,ocs.mnemonic)
   FROM (dummyt d  WITH seq = value(size(ordered_as->ordered_as,5))),
    synonym_item_r sir,
    order_catalog_synonym ocs
   PLAN (d
    WHERE (ordered_as->ordered_as[d.seq].ord_as_synonym_id=0))
    JOIN (sir
    WHERE (sir.item_id=ordered_as->ordered_as[d.seq].item_id))
    JOIN (ocs
    WHERE ocs.synonym_id=sir.synonym_id
     AND ocs.active_ind=1
     AND ((ocs.hide_flag=0) OR (ocs.hide_flag=null))
     AND ocs.mnemonic_type_cd IN (
    (SELECT
     code_value
     FROM code_value
     WHERE code_set=6011
      AND cdf_meaning IN ("BRANDNAME", "DCP", "DISPDRUG", "GENERICTOP", "IVNAME",
     "PRIMARY", "TRADETOP"))))
   ORDER BY sir.item_id, synonym_type, ocs.synonym_id
   HEAD REPORT
    array_cnt = 0
   HEAD sir.item_id
    dcp_cnt = 0, c_cnt = 0, n_cnt = 0,
    m_cnt = 0, last_dcp = 0, last_c = 0,
    last_n = 0, last_m = 0
   DETAIL
    IF (ocs.mnemonic_type_cd=cdcptype)
     dcp_cnt = (dcp_cnt+ 1), last_dcp = ocs.synonym_id
    ELSEIF (ocs.mnemonic_type_cd=cctype)
     c_cnt = (c_cnt+ 1), last_c = ocs.synonym_id
    ELSEIF (ocs.mnemonic_type_cd=cntype)
     n_cnt = (n_cnt+ 1), last_n = ocs.synonym_id
    ELSEIF (ocs.mnemonic_type_cd=cmtype)
     m_cnt = (m_cnt+ 1), last_m = ocs.synonym_id
    ENDIF
   FOOT  sir.item_id
    IF (dcp_cnt=1)
     ordered_as->ordered_as[d.seq].ord_as_synonym_id = last_dcp, ordered_as->ordered_as[d.seq].
     link_type = 1
    ELSEIF (c_cnt=1)
     ordered_as->ordered_as[d.seq].ord_as_synonym_id = last_c, ordered_as->ordered_as[d.seq].
     link_type = 1
    ELSEIF (n_cnt=1)
     ordered_as->ordered_as[d.seq].ord_as_synonym_id = last_n, ordered_as->ordered_as[d.seq].
     link_type = 1
    ELSEIF (m_cnt=1)
     ordered_as->ordered_as[d.seq].ord_as_synonym_id = last_m, ordered_as->ordered_as[d.seq].
     link_type = 1
    ENDIF
   WITH nullreport
  ;end select
  CALL text(8,3," Analyzing Multum MMDC/CNUM mapping...              ")
  SELECT INTO "nl:"
   mmdc_cki = substring(1,20,md.cki), mmnp.main_multum_drug_code, mmnp.function_id,
   ocs.synonym_id, synonym_type = uar_get_code_display(ocs.mnemonic_type_cd), synonym = substring(1,
    50,ocs.mnemonic)
   FROM (dummyt d  WITH seq = value(size(ordered_as->ordered_as,5))),
    medication_definition md,
    mltm_mmdc_name_map mmnp,
    order_catalog_synonym ocs
   PLAN (d
    WHERE (ordered_as->ordered_as[d.seq].ord_as_synonym_id=0))
    JOIN (md
    WHERE (md.item_id=ordered_as->ordered_as[d.seq].item_id))
    JOIN (mmnp
    WHERE md.cki=concat("MUL.FRMLTN!",cnvtstring(mmnp.main_multum_drug_code)))
    JOIN (ocs
    WHERE ocs.cki=concat("MUL.ORD-SYN!",cnvtstring(mmnp.drug_synonym_id))
     AND ocs.mnemonic_type_cd IN (
    (SELECT
     code_value
     FROM code_value
     WHERE code_set=6011
      AND cdf_meaning IN ("DISPDRUG", "GENERICTOP", "TRADETOP")))
     AND ocs.active_ind=1
     AND ((ocs.hide_flag=0) OR (ocs.hide_flag=null)) )
   ORDER BY md.item_id, synonym_type, ocs.synonym_id
   HEAD REPORT
    array_cnt = 0
   HEAD md.item_id
    c_cnt = 0, n_cnt = 0, m_cnt = 0,
    last_c = 0, last_n = 0, last_m = 0
   DETAIL
    IF (ocs.mnemonic_type_cd=cntype)
     n_cnt = (n_cnt+ 1), last_n = ocs.synonym_id
    ELSEIF (ocs.mnemonic_type_cd=cmtype)
     m_cnt = (m_cnt+ 1), last_m = ocs.synonym_id
    ENDIF
   FOOT  md.item_id
    IF (c_cnt=1)
     ordered_as->ordered_as[d.seq].ord_as_synonym_id = last_c, ordered_as->ordered_as[d.seq].
     link_type = 2
    ELSEIF (n_cnt=1)
     ordered_as->ordered_as[d.seq].ord_as_synonym_id = last_n, ordered_as->ordered_as[d.seq].
     link_type = 2
    ELSEIF (m_cnt=1)
     ordered_as->ordered_as[d.seq].ord_as_synonym_id = last_m, ordered_as->ordered_as[d.seq].
     link_type = 2
    ENDIF
   WITH nullreport
  ;end select
  CALL text(9,3," Analyzing formulary brand name identifiers...      ")
  SELECT INTO "nl:"
   product_brand_name = substring(1,50,mi.value), synonym_type = uar_get_code_display(ocs
    .mnemonic_type_cd), synonym = substring(1,50,ocs.mnemonic)
   FROM (dummyt d  WITH seq = value(size(ordered_as->ordered_as,5))),
    order_catalog_item_r ocir,
    order_catalog_synonym ocs,
    med_identifier mi
   PLAN (d
    WHERE (ordered_as->ordered_as[d.seq].ord_as_synonym_id=0))
    JOIN (ocir
    WHERE (ocir.item_id=ordered_as->ordered_as[d.seq].item_id))
    JOIN (ocs
    WHERE ocs.catalog_cd=ocir.catalog_cd
     AND ocs.active_ind=1
     AND ((ocs.hide_flag=0) OR (ocs.hide_flag=null))
     AND ocs.mnemonic_type_cd IN (
    (SELECT
     code_value
     FROM code_value
     WHERE code_set=6011
      AND cdf_meaning IN ("BRANDNAME", "DCP", "DISPDRUG", "GENERICTOP", "IVNAME",
     "PRIMARY", "TRADETOP"))))
    JOIN (mi
    WHERE mi.item_id=ocir.item_id
     AND mi.med_product_id=0
     AND mi.med_identifier_type_cd=cbrand
     AND mi.active_ind=1
     AND mi.primary_ind=1
     AND mi.pharmacy_type_cd=cinpatient)
   ORDER BY product_brand_name, synonym
   HEAD ocir.item_id
    match_cnt = 0, ord_as_choice = 0
   DETAIL
    IF (trim(cnvtupper(mi.value))=trim(cnvtupper(ocs.mnemonic)))
     ord_as_choice = ocs.synonym_id, match_cnt = (match_cnt+ 1)
    ENDIF
   FOOT  ocir.item_id
    IF (match_cnt=1
     AND ord_as_choice > 0)
     ordered_as->ordered_as[d.seq].ord_as_synonym_id = ord_as_choice, ordered_as->ordered_as[d.seq].
     link_type = 3
    ENDIF
   WITH nullreport
  ;end select
  CALL clear_screen(0)
  SELECT
   med_oe_defaults_id = ordered_as->ordered_as[d.seq].med_oe_defaults_id, match_source = evaluate(
    cnvtint(ordered_as->ordered_as[d.seq].link_type),1,"Product/Synonym linking   ",2,
    "Multum CKI mapping   ",
    3,"Formulary brand name   ",""), product_desc = substring(1,50,mi.value),
   emar_display =
   IF (ocs.synonym_id > 0
    AND (ordered_as->ordered_as[d.seq].rx_mask=1)) trim(ocs.mnemonic)
   ELSEIF (ocs.synonym_id > 0) concat(trim(ocs2.mnemonic)," (",trim(ocs.mnemonic),")")
   ELSE trim(ocs2.mnemonic)
   ENDIF
   FROM (dummyt d  WITH seq = value(size(ordered_as->ordered_as,5))),
    med_identifier mi,
    medication_definition md,
    order_catalog_item_r ocir,
    order_catalog_synonym ocs,
    order_catalog_synonym ocs2
   PLAN (d
    WHERE (ordered_as->ordered_as[d.seq].already_existed != 1)
     AND cnvtint(ordered_as->ordered_as[d.seq].link_type) IN (1, 2, 3))
    JOIN (mi
    WHERE (mi.item_id=ordered_as->ordered_as[d.seq].item_id)
     AND mi.med_product_id=0
     AND mi.med_identifier_type_cd=cdesc
     AND mi.active_ind=1
     AND mi.primary_ind=1
     AND mi.pharmacy_type_cd=cinpatient)
    JOIN (md
    WHERE md.item_id=mi.item_id)
    JOIN (ocs
    WHERE (ocs.synonym_id=ordered_as->ordered_as[d.seq].ord_as_synonym_id))
    JOIN (ocir
    WHERE md.item_id=ocir.item_id)
    JOIN (ocs2
    WHERE ocs2.catalog_cd=ocir.catalog_cd
     AND ocs2.mnemonic_type_cd=cprimtype)
   ORDER BY ordered_as->ordered_as[d.seq].already_existed, match_source, product_desc,
    emar_display
   WITH nullreport
  ;end select
  CALL clear_screen(0)
  CALL text(5,3,"Commit these new ORDERED AS synonyms?")
  CALL accept(5,43,"C;CU","N"
   WHERE curaccept IN ("Y", "N"))
  IF (curaccept="Y")
   UPDATE  FROM (dummyt d  WITH seq = value(size(ordered_as->ordered_as,5))),
     med_oe_defaults mod
    SET mod.ord_as_synonym_id = ordered_as->ordered_as[d.seq].ord_as_synonym_id, mod.updt_task = - (
     2516), mod.updt_id = 0,
     mod.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    PLAN (d
     WHERE (ordered_as->ordered_as[d.seq].already_existed != 1)
      AND cnvtint(ordered_as->ordered_as[d.seq].link_type) IN (1, 2, 3))
     JOIN (mod
     WHERE (mod.med_oe_defaults_id=ordered_as->ordered_as[d.seq].med_oe_defaults_id))
    WITH nullreport
   ;end update
   COMMIT
  ENDIF
 ENDIF
 GO TO pharm_utilities_mode
#asc_set_ordas_syn_exit
#lock_med_oef_fields
 CALL clear_screen(0)
 SET cpharm = uar_get_code_by("MEANING",6000,"PHARMACY")
 SET corder = uar_get_code_by("MEANING",6003,"ORDER")
 UPDATE  FROM oe_format_fields
  SET lock_on_modify_flag = 1, updt_task = - (2516), updt_dt_tm = cnvtdatetime(curdate,curtime3)
  WHERE oe_format_id IN (
  (SELECT
   oe_format_id
   FROM order_entry_format
   WHERE catalog_type_cd=cpharm
    AND action_type_cd=corder))
   AND accept_flag IN (0, 1)
   AND action_type_cd=corder
  WITH nullreport
 ;end update
 COMMIT
#lock_med_oef_fields_exit
#unlock_med_oef_fields
 CALL clear_screen(0)
 SET cpharm = uar_get_code_by("MEANING",6000,"PHARMACY")
 SET corder = uar_get_code_by("MEANING",6003,"ORDER")
 UPDATE  FROM oe_format_fields
  SET lock_on_modify_flag = 0, updt_task = - (2516), updt_dt_tm = cnvtdatetime(curdate,curtime3)
  WHERE oe_format_id IN (
  (SELECT
   oe_format_id
   FROM order_entry_format
   WHERE catalog_type_cd=cpharm
    AND action_type_cd=corder))
   AND action_type_cd=corder
   AND lock_on_modify_flag=1
  WITH nullreport
 ;end update
 COMMIT
#unlock_med_oef_fields_exit
#med_no_rx_verify
 CALL clear_screen(0)
 SET cpharm = uar_get_code_by("MEANING",6000,"PHARMACY")
 SET corder = uar_get_code_by("MEANING",6003,"ORDER")
 SET cprim = uar_get_code_by("MEANING",6011,"PRIMARY")
 SELECT
  oc.catalog_cd, orderable = ocs.mnemonic
  FROM order_catalog oc,
   order_catalog_review ocr,
   order_catalog_synonym ocs
  PLAN (oc
   WHERE oc.catalog_type_cd=cpharm
    AND oc.active_ind=1
    AND oc.orderable_type_flag IN (0, 1, 10))
   JOIN (ocs
   WHERE ocs.catalog_cd=oc.catalog_cd
    AND ocs.mnemonic_type_cd=cprim
    AND ocs.active_ind=1)
   JOIN (ocr
   WHERE ocr.catalog_cd=outerjoin(oc.catalog_cd)
    AND ocr.action_type_cd=outerjoin(corder)
    AND ocr.rx_verify_flag=outerjoin(2)
    AND ocr.catalog_cd=null)
  ORDER BY orderable
  WITH format = pcformat
 ;end select
#med_no_rx_verify_exit
#med_nurse_wit
 CALL clear_screen(0)
 SET cprimary = uar_get_code_by("MEANING",6011,"PRIMARY")
 SELECT
  primary = substring(1,60,ocs2.mnemonic), synonym = substring(1,60,ocs.mnemonic), col_name =
  uar_get_code_display(oax.ocs_col_name_cd),
  facility = uar_get_code_display(oax.facility_cd), flex_value = oax.flex_nbr_value, flex_object_type
   = uar_get_code_display(oax.flex_obj_type_cd),
  flex_object = uar_get_code_display(oax.flex_obj_cd)
  FROM ocs_attr_xcptn oax,
   order_catalog_synonym ocs,
   order_catalog_synonym ocs2
  PLAN (oax)
   JOIN (ocs
   WHERE ocs.synonym_id=oax.synonym_id)
   JOIN (ocs2
   WHERE ocs.catalog_cd=ocs2.catalog_cd
    AND ocs2.mnemonic_type_cd=cprimary)
  ORDER BY cnvtupper(ocs2.mnemonic), cnvtupper(ocs.mnemonic), col_name,
   facility, flex_object_type, flex_object
  WITH format = pcformat
 ;end select
 GO TO care_utilities_mode
#med_nurse_wit_exit
#form_ivset_output
 CALL clear_screen(0)
 CALL video("N")
 CALL text(3,3," Output to CSV file? (1) or display results on screen? (2) ")
 CALL text(5,3," * Results written to file will be saved as 'asc_form_ivsets.csv' in CCLUSERDIR ")
 CALL accept(3,62,"99;",1
  WHERE curaccept IN (1, 2))
 CASE (curaccept)
  OF 1:
   EXECUTE FROM form_ivset TO form_ivset_exit
  OF 2:
   EXECUTE FROM form_ivset_scr TO form_ivset_scr_exit
 ENDCASE
#form_ivset_output_exit
#cpoe_ivset_output
 CALL clear_screen(0)
 CALL video("N")
 CALL text(3,3," Output to CSV file? (1) or display results on screen? (2) ")
 CALL text(5,3," * Results written to file will be saved as 'asc_cpoe_ivsets.csv' in CCLUSERDIR ")
 CALL accept(3,62,"99;",1
  WHERE curaccept IN (1, 2))
 CASE (curaccept)
  OF 1:
   EXECUTE FROM cpoe_ivset TO cpoe_ivset_exit
  OF 2:
   EXECUTE FROM cpoe_ivset_scr TO cpoe_ivset_scr_exit
 ENDCASE
#cpoe_ivset_output_exit
#asc_prdct_rxmnem_output
 CALL clear_screen(0)
 CALL video("N")
 CALL text(3,3," Output to CSV file? (1) or display results on screen? (2) ")
 CALL text(5,3,
  " * Results written to file will be saved as 'asc_prdct_rxmnem_audit.csv' in CCLUSERDIR ")
 CALL accept(3,62,"99;",1
  WHERE curaccept IN (1, 2))
 CASE (curaccept)
  OF 1:
   EXECUTE FROM asc_prdct_rxmnem TO asc_prdct_rxmnem_exit
  OF 2:
   EXECUTE FROM asc_prdct_rxmnem_scr TO asc_prdct_rxmnem_scr_exit
 ENDCASE
#asc_prdct_rxmnem_output_exit
#syn_vv_on_output
 CALL clear_screen(0)
 CALL video("N")
 CALL text(3,3," Output to CSV file? (1) or display results on screen? (2) ")
 CALL text(5,3," * Results written to file will be saved as 'pha_aud_ocs_vv_on.csv' in CCLUSERDIR ")
 CALL text(6,3,"   and will identify facility-specific virtual views                              ")
 CALL accept(3,62,"99;",1
  WHERE curaccept IN (1, 2))
 CASE (curaccept)
  OF 1:
   EXECUTE FROM syn_vv_on TO syn_vv_on_exit
  OF 2:
   EXECUTE FROM syn_vv_on_scr TO syn_vv_on_scr_exit
 ENDCASE
#syn_vv_on_output_exit
#asc_aud_pha_ocs_output
 CALL clear_screen(0)
 CALL video("N")
 CALL text(3,3," Output to CSV file? (1) or display results on screen? (2) ")
 CALL text(5,3," * Results written to file will be saved as 'pha_aud_ocs.csv' in CCLUSERDIR ")
 CALL accept(3,62,"99;",1
  WHERE curaccept IN (1, 2))
 CASE (curaccept)
  OF 1:
   EXECUTE FROM asc_aud_pha_ocs TO asc_aud_pha_ocs_exit
  OF 2:
   EXECUTE FROM asc_aud_pha_ocs_scr TO asc_aud_pha_ocs_scr_exit
 ENDCASE
#asc_aud_pha_ocs_output_exit
#upd_sent_for_del
 CALL clear_screen(0)
 CALL video("R")
 CALL text(3,3," This program does not delete order sentences, but will update   ")
 CALL text(4,3," sentence attributes to allow deletion using OS_DELETE_UTILITY.  ")
 CALL text(6,3," Facility selection will not be honored. If inpatient medication ")
 CALL text(7,3," sentences are updated for deletion, ALL sentences will be       ")
 CALL text(8,3," updated, regardless of virtual-view settings.                   ")
 CALL video("N")
 CALL text(10,3,"Update inpatient medication sentences for deletion?")
 CALL accept(10,57,"C;CU","N"
  WHERE curaccept IN ("Y", "N"))
 CASE (curaccept)
  OF "Y":
   EXECUTE FROM upd_ip_del_sent TO upd_ip_del_sent_exit
 ENDCASE
 IF (curaccept="N")
  CALL text(12,3,"Update inpatient medication sentences for retention?")
  CALL accept(12,57,"C;CU","N"
   WHERE curaccept IN ("Y", "N"))
  CASE (curaccept)
   OF "Y":
    EXECUTE FROM upd_ip_save_sent TO upd_ip_save_sent_exit
  ENDCASE
 ENDIF
 CALL text(14,3,"Update outpatient medication sentences for deletion?")
 CALL accept(14,57,"C;CU","N"
  WHERE curaccept IN ("Y", "N"))
 CASE (curaccept)
  OF "Y":
   EXECUTE FROM upd_op_del_sent TO upd_op_del_sent_exit
 ENDCASE
 IF (curaccept="N")
  CALL text(16,3,"Update outpatient medication sentences for retention?")
  CALL accept(16,57,"C;CU","N"
   WHERE curaccept IN ("Y", "N"))
  CASE (curaccept)
   OF "Y":
    EXECUTE FROM upd_op_save_sent TO upd_op_save_sent_exit
  ENDCASE
 ENDIF
 COMMIT
 GO TO pharm_utilities_mode
#upd_ip_del_sent
 SET cpharm = uar_get_code_by("MEANING",6000,"PHARMACY")
 SET cmnem_type_z = uar_get_code_by("MEANING",6011,"TRADEPROD")
 SET cmnem_type_y = uar_get_code_by("MEANING",6011,"GENERICPROD")
 UPDATE  FROM order_sentence os
  SET os.updt_task = 0, os.updt_id = 0
  WHERE os.order_sentence_id IN (
  (SELECT
   os.order_sentence_id
   FROM ord_cat_sent_r ocsr,
    order_sentence os,
    order_catalog oc,
    order_catalog_synonym ocs
   WHERE os.order_sentence_id=ocsr.order_sentence_id
    AND os.usage_flag IN (0, 1)
    AND ((os.parent_entity2_name != "ALT_SEL_CAT") OR (os.parent_entity2_name=null))
    AND oc.catalog_cd=ocsr.catalog_cd
    AND oc.catalog_type_cd=cpharm
    AND oc.orderable_type_flag IN (0, 1)
    AND ocs.synonym_id=ocsr.synonym_id
    AND  NOT (ocs.mnemonic_type_cd IN (cmnem_type_z, cmnem_type_y))))
  WITH nullreport
 ;end update
 UPDATE  FROM order_sentence os
  SET os.updt_task = 0, os.updt_id = 0
  WHERE os.order_sentence_id IN (
  (SELECT
   os.order_sentence_id
   FROM ord_cat_sent_r ocsr,
    order_sentence os,
    order_catalog oc,
    order_catalog_synonym ocs
   WHERE os.order_sentence_id=ocsr.order_sentence_id
    AND os.usage_flag=1
    AND ((os.parent_entity2_name != "ALT_SEL_CAT") OR (os.parent_entity2_name=null))
    AND oc.catalog_cd=ocsr.catalog_cd
    AND oc.catalog_type_cd=cpharm
    AND oc.orderable_type_flag IN (0, 1)
    AND ocs.synonym_id=ocsr.synonym_id
    AND ocs.mnemonic_type_cd IN (cmnem_type_z, cmnem_type_y)))
  WITH nullreport
 ;end update
 CALL video("R")
 CALL text(10,57,"Update complete")
 CALL video("N")
#upd_ip_del_sent_exit
#upd_ip_save_sent
 SET cpharm = uar_get_code_by("MEANING",6000,"PHARMACY")
 SET cmnem_type_z = uar_get_code_by("MEANING",6011,"TRADEPROD")
 SET cmnem_type_y = uar_get_code_by("MEANING",6011,"GENERICPROD")
 UPDATE  FROM order_sentence os
  SET os.updt_task = - (2516)
  WHERE os.order_sentence_id IN (
  (SELECT
   os.order_sentence_id
   FROM ord_cat_sent_r ocsr,
    order_sentence os,
    order_catalog oc,
    order_catalog_synonym ocs
   WHERE os.order_sentence_id=ocsr.order_sentence_id
    AND os.usage_flag IN (0, 1)
    AND ((os.parent_entity2_name != "ALT_SEL_CAT") OR (os.parent_entity2_name=null))
    AND oc.catalog_cd=ocsr.catalog_cd
    AND oc.catalog_type_cd=cpharm
    AND oc.orderable_type_flag IN (0, 1)
    AND ocs.synonym_id=ocsr.synonym_id
    AND  NOT (ocs.mnemonic_type_cd IN (cmnem_type_z, cmnem_type_y))))
  WITH nullreport
 ;end update
 UPDATE  FROM order_sentence os
  SET os.updt_task = - (2516)
  WHERE os.order_sentence_id IN (
  (SELECT
   os.order_sentence_id
   FROM ord_cat_sent_r ocsr,
    order_sentence os,
    order_catalog oc,
    order_catalog_synonym ocs
   WHERE os.order_sentence_id=ocsr.order_sentence_id
    AND os.usage_flag=1
    AND ((os.parent_entity2_name != "ALT_SEL_CAT") OR (os.parent_entity2_name=null))
    AND oc.catalog_cd=ocsr.catalog_cd
    AND oc.catalog_type_cd=cpharm
    AND oc.orderable_type_flag IN (0, 1)
    AND ocs.synonym_id=ocsr.synonym_id
    AND ocs.mnemonic_type_cd IN (cmnem_type_z, cmnem_type_y)))
  WITH nullreport
 ;end update
 CALL video("R")
 CALL text(12,57,"Update complete")
 CALL video("N")
#upd_ip_save_sent_exit
#upd_op_del_sent
 SET cpharm = uar_get_code_by("MEANING",6000,"PHARMACY")
 SET cmnem_type_z = uar_get_code_by("MEANING",6011,"TRADEPROD")
 SET cmnem_type_y = uar_get_code_by("MEANING",6011,"GENERICPROD")
 UPDATE  FROM order_sentence os
  SET os.updt_task = 0, os.updt_id = 0
  WHERE os.order_sentence_id IN (
  (SELECT
   os.order_sentence_id
   FROM ord_cat_sent_r ocsr,
    order_sentence os,
    order_catalog oc,
    order_catalog_synonym ocs
   WHERE os.order_sentence_id=ocsr.order_sentence_id
    AND os.usage_flag=2
    AND ((os.parent_entity2_name != "ALT_SEL_CAT") OR (os.parent_entity2_name=null))
    AND oc.catalog_cd=ocsr.catalog_cd
    AND oc.catalog_type_cd=cpharm
    AND oc.orderable_type_flag IN (0, 1)
    AND ocs.synonym_id=ocsr.synonym_id))
  WITH nullreport
 ;end update
 UPDATE  FROM order_sentence os
  SET os.updt_task = 0, os.updt_id = 0
  WHERE os.order_sentence_id IN (
  (SELECT
   os.order_sentence_id
   FROM ord_cat_sent_r ocsr,
    order_sentence os,
    order_catalog oc,
    order_catalog_synonym ocs
   WHERE os.order_sentence_id=ocsr.order_sentence_id
    AND os.usage_flag=0
    AND ((os.parent_entity2_name != "ALT_SEL_CAT") OR (os.parent_entity2_name=null))
    AND oc.catalog_cd=ocsr.catalog_cd
    AND oc.catalog_type_cd=cpharm
    AND oc.orderable_type_flag IN (0, 1)
    AND ocs.synonym_id=ocsr.synonym_id
    AND ocs.mnemonic_type_cd IN (cmnem_type_z, cmnem_type_y)))
  WITH nullreport
 ;end update
 CALL video("R")
 CALL text(14,57,"Update complete")
 CALL video("N")
#upd_op_del_sent_exit
#upd_op_save_sent
 SET cpharm = uar_get_code_by("MEANING",6000,"PHARMACY")
 SET cmnem_type_z = uar_get_code_by("MEANING",6011,"TRADEPROD")
 SET cmnem_type_y = uar_get_code_by("MEANING",6011,"GENERICPROD")
 UPDATE  FROM order_sentence os
  SET os.updt_task = - (2516)
  WHERE os.order_sentence_id IN (
  (SELECT
   os.order_sentence_id
   FROM ord_cat_sent_r ocsr,
    order_sentence os,
    order_catalog oc,
    order_catalog_synonym ocs
   WHERE os.order_sentence_id=ocsr.order_sentence_id
    AND os.usage_flag=2
    AND ((os.parent_entity2_name != "ALT_SEL_CAT") OR (os.parent_entity2_name=null))
    AND oc.catalog_cd=ocsr.catalog_cd
    AND oc.catalog_type_cd=cpharm
    AND oc.orderable_type_flag IN (0, 1)
    AND ocs.synonym_id=ocsr.synonym_id))
  WITH nullreport
 ;end update
 UPDATE  FROM order_sentence os
  SET os.updt_task = - (2516)
  WHERE os.order_sentence_id IN (
  (SELECT
   os.order_sentence_id
   FROM ord_cat_sent_r ocsr,
    order_sentence os,
    order_catalog oc,
    order_catalog_synonym ocs
   WHERE os.order_sentence_id=ocsr.order_sentence_id
    AND os.usage_flag=0
    AND ((os.parent_entity2_name != "ALT_SEL_CAT") OR (os.parent_entity2_name=null))
    AND oc.catalog_cd=ocsr.catalog_cd
    AND oc.catalog_type_cd=cpharm
    AND oc.orderable_type_flag IN (0, 1)
    AND ocs.synonym_id=ocsr.synonym_id
    AND ocs.mnemonic_type_cd IN (cmnem_type_z, cmnem_type_y)))
  WITH nullreport
 ;end update
 CALL video("R")
 CALL text(16,57,"Update complete")
 CALL video("N")
#upd_op_save_sent_exit
#upd_sent_for_del_exit
#prod_no_syn_links
 CALL clear_screen(0)
 CALL show_processing(0)
 SET cpharm = uar_get_code_by("MEANING",6000,"PHARMACY")
 SET cprimary = uar_get_code_by("MEANING",6011,"PRIMARY")
 SET csystem = uar_get_code_by("MEANING",4062,"SYSTEM")
 SET csyspkgtyp = uar_get_code_by("MEANING",4062,"SYSPKGTYP")
 SET corderable = uar_get_code_by("MEANING",4063,"ORDERABLE")
 SET cinpatient = uar_get_code_by("MEANING",4500,"INPATIENT")
 SET cdesc = uar_get_code_by("MEANING",11000,"DESC")
 FREE RECORD available_products
 RECORD available_products(
   1 products[*]
     2 item_id = f8
     2 catalog_cd = f8
 )
 SELECT INTO "nl:"
  md.item_id, product_desc = substring(1,50,mi.value), mfoi.*
  FROM medication_definition md,
   order_catalog_item_r ocir,
   item_definition id,
   med_def_flex mdf,
   med_flex_object_idx mfoi,
   med_identifier mi
  PLAN (md)
   JOIN (ocir
   WHERE ocir.item_id=md.item_id)
   JOIN (id
   WHERE id.item_id=ocir.item_id
    AND id.active_ind=1)
   JOIN (mdf
   WHERE mdf.item_id=md.item_id
    AND mdf.flex_type_cd=csyspkgtyp
    AND mdf.pharmacy_type_cd=cinpatient)
   JOIN (mfoi
   WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
    AND mfoi.flex_object_type_cd=corderable
    AND ((mfoi.parent_entity_id=0) OR (mfoi.parent_entity_id=cur_facility_cd)) )
   JOIN (mi
   WHERE mi.item_id=md.item_id
    AND mi.active_ind=1
    AND mi.primary_ind=1
    AND mi.med_product_id=0
    AND mi.med_identifier_type_cd=cdesc
    AND mi.pharmacy_type_cd=cinpatient)
  ORDER BY mi.value
  HEAD REPORT
   cnt = 0
  HEAD md.item_id
   cnt = (cnt+ 1), stat = alterlist(available_products->products,cnt), available_products->products[
   cnt].item_id = md.item_id,
   available_products->products[cnt].catalog_cd = ocir.catalog_cd
  WITH nullreport
 ;end select
 SELECT
  primary = substring(1,60,oc.primary_mnemonic), item_desc = substring(1,60,mi.value), item_id =
  available_products->products[d1.seq].item_id
  FROM (dummyt d1  WITH seq = value(size(available_products->products,5))),
   med_identifier mi,
   order_catalog oc,
   dummyt d2,
   synonym_item_r sir,
   order_catalog_synonym ocs
  PLAN (d1)
   JOIN (mi
   WHERE (mi.item_id=available_products->products[d1.seq].item_id)
    AND mi.active_ind=1
    AND mi.primary_ind=1
    AND mi.med_product_id=0
    AND mi.med_identifier_type_cd=cdesc
    AND mi.pharmacy_type_cd=cinpatient)
   JOIN (oc
   WHERE (oc.catalog_cd=available_products->products[d1.seq].catalog_cd))
   JOIN (d2)
   JOIN (sir
   WHERE (sir.item_id=available_products->products[d1.seq].item_id))
   JOIN (ocs
   WHERE ocs.synonym_id=sir.synonym_id
    AND ocs.mnemonic_type_cd IN (
   (SELECT
    code_value
    FROM code_value
    WHERE code_set=6011
     AND cdf_meaning IN ("BRANDNAME", "DCP", "DISPDRUG", "GENERICTOP", "IVNAME",
    "PRIMARY", "TRADETOP")))
    AND ocs.active_ind=1
    AND ((ocs.hide_flag=null) OR (ocs.hide_flag=0)) )
  ORDER BY cnvtupper(oc.primary_mnemonic), mi.value_key
  WITH outerjoin = d2, dontexist, format = pcformat
 ;end select
 GO TO pharm_problem_mode
#prod_no_syn_links_exit
#replace_cs_syn
 CALL clear_screen(0)
 CALL text(5,1,"Enter first character(s) of synonym to replace:   ")
 CALL accept(5,53,"P(30);CU","")
 SET syn_loc_string = cnvtupper(curaccept)
 FREE RECORD syn_temp
 RECORD syn_temp(
   1 syn_list[*]
     2 syn_id = f8
     2 synonym = vc
     2 type = vc
 )
 SET syn_count = 0
 SET cpharm = uar_get_code_by("MEANING",6000,"PHARMACY")
 SET corder = uar_get_code_by("MEANING",6003,"ORDER")
 SELECT DISTINCT INTO "nl:"
  ocs.synonym_id, synonym = ocs.mnemonic, synonym_type = evaluate(trim(uar_get_code_display(ocs
     .mnemonic_type_cd)),"Ancillary","NON-CPOE","Brand Name","BRAND",
   "Direct Care Provider","DCP","C - Dispensable Drug Names","C","Generic Name",
   "NON-CPOE","Y - Generic Products","NON-CPOE","M - Generic Miscellaneous Products","M",
   "E - IV Fluids and Nicknames","E","Outreach","NON-CPOE","PathLink",
   "NON-CPOE","Primary","PRIMARY","Rx Mnemonic","NON-CPOE",
   "Surgery Med","NON-CPOE","Z - Trade Products","NON-CPOE","N - Trade Miscellaneous Products",
   "N")
  FROM order_catalog_synonym ocs,
   cs_component csc,
   order_catalog oc
  PLAN (csc
   WHERE csc.comp_id != 0)
   JOIN (oc
   WHERE oc.catalog_cd=csc.catalog_cd
    AND oc.orderable_type_flag=6
    AND oc.active_ind=1)
   JOIN (ocs
   WHERE ocs.synonym_id=csc.comp_id
    AND ocs.catalog_type_cd=cpharm
    AND cnvtupper(ocs.mnemonic)=patstring(build(syn_loc_string,"*")))
  ORDER BY cnvtupper(ocs.mnemonic), synonym_type
  HEAD REPORT
   syn_count = 0
  DETAIL
   syn_count = (syn_count+ 1)
   IF (mod(syn_count,10)=1)
    stat = alterlist(syn_temp->syn_list,(syn_count+ 9))
   ENDIF
   syn_temp->syn_list[syn_count].syn_id = ocs.synonym_id, syn_temp->syn_list[syn_count].synonym =
   trim(ocs.mnemonic), syn_temp->syn_list[syn_count].type = synonym_type
  FOOT REPORT
   stat = alterlist(syn_temp->syn_list,syn_count)
  WITH nocounter
 ;end select
 CALL clear_screen(0)
 CALL text(3,2,"Medication synonyms in CareSets:")
 CALL text(3,38,build(syn_loc_string,"*"))
 CALL text(5,67,"Total:  ")
 CALL text(5,75,cnvtstring(syn_count,4))
 CALL create_std_box(syn_count)
 CALL text(6,8,"Synonym")
 WHILE (cnt <= numsrow
  AND cnt <= maxcnt)
   SET holdstr60 = trim(syn_temp->syn_list[cnt].synonym)
   SET holdstr20 = fillstring(20," ")
   SET holdstr20 = trim(syn_temp->syn_list[cnt].type)
   SET holdstr = concat(cnvtstring(cnt,4,0,r)," ",holdstr60," ",holdstr20)
   CALL scrolltext(cnt,holdstr)
   SET cnt = (cnt+ 1)
 ENDWHILE
 SET cnt = 1
 SET arow = 1
 CALL text(23,1,"Select synonym to replace:         (enter 000 to go back)")
 SET pick = 0
 WHILE (pick=0)
  CALL accept(23,29,"9999;S",cnt)
  CASE (curscroll)
   OF 0:
    IF (curaccept=0)
     CALL clear_screen(0)
     GO TO common_utilities_mode
    ELSEIF (cnvtint(curaccept) BETWEEN 1 AND maxcnt)
     SET pick = cnvtint(curaccept)
     CALL clear_screen(0)
     CALL replace_cs_syn(syn_temp->syn_list[pick].syn_id,syn_temp->syn_list[pick].synonym)
    ELSE
     CALL clear_screen(0)
     GO TO common_utilities_mode
    ENDIF
   OF 1:
    IF (cnt < maxcnt)
     SET cnt = (cnt+ 1)
     SET holdstr60 = trim(syn_temp->syn_list[cnt].synonym)
     SET holdstr20 = fillstring(20," ")
     SET holdstr20 = trim(syn_temp->syn_list[cnt].type)
     SET holdstr = concat(cnvtstring(cnt,4,0,r)," ",holdstr60," ",holdstr20)
     CALL down_arrow(holdstr)
    ENDIF
   OF 2:
    IF (cnt > 1)
     SET cnt = (cnt - 1)
     SET holdstr60 = trim(syn_temp->syn_list[cnt].synonym)
     SET holdstr20 = fillstring(20," ")
     SET holdstr20 = trim(syn_temp->syn_list[cnt].type)
     SET holdstr = concat(cnvtstring(cnt,4,0,r)," ",holdstr60," ",holdstr20)
     CALL up_arrow(holdstr)
    ENDIF
   OF 3:
   OF 4:
   OF 6:
    IF (numsrow < maxcnt)
     SET cnt = ((cnt+ numsrow) - 1)
     IF (((cnt+ numsrow) > maxcnt))
      SET cnt = (maxcnt - numsrow)
     ENDIF
     SET arow = 1
     WHILE (arow <= numsrow)
       SET cnt = (cnt+ 1)
       SET holdstr60 = trim(syn_temp->syn_list[cnt].synonym)
       SET holdstr20 = fillstring(20," ")
       SET holdstr20 = trim(syn_temp->syn_list[cnt].type)
       SET holdstr = concat(cnvtstring(cnt,4,0,r)," ",holdstr60," ",holdstr20)
       CALL scrolltext(arow,holdstr)
       SET arow = (arow+ 1)
     ENDWHILE
     SET arow = 1
     SET cnt = ((cnt - numsrow)+ 1)
    ENDIF
   OF 5:
    IF (((cnt - numsrow) > 0))
     SET cnt = (cnt - numsrow)
    ELSE
     SET cnt = 1
    ENDIF
    SET tmp1 = cnt
    SET arow = 1
    WHILE (arow <= numsrow
     AND cnt < maxcnt)
      SET holdstr60 = trim(syn_temp->syn_list[cnt].synonym)
      SET holdstr20 = fillstring(20," ")
      SET holdstr20 = trim(syn_temp->syn_list[cnt].type)
      SET holdstr = concat(cnvtstring(cnt,4,0,r)," ",holdstr60," ",holdstr20)
      CALL scrolltext(arow,holdstr)
      SET cnt = (cnt+ 1)
      SET arow = (arow+ 1)
    ENDWHILE
    SET cnt = tmp1
    SET arow = 1
  ENDCASE
 ENDWHILE
 CALL clear_screen(0)
 CALL text(23,1,"Replace another synonym? (Y/N) ")
 CALL accept(23,33,"C;CU","N"
  WHERE curaccept IN ("Y", "N"))
 CASE (curaccept)
  OF "Y":
   GO TO replace_cs_syn
  OF "N":
   GO TO common_utilities_mode
 ENDCASE
 GO TO common_utilities_mode
#replace_cs_syn_exit
#replace_ivs_syn
 CALL clear_screen(0)
 CALL text(5,1,"Enter first character(s) of synonym to replace:   ")
 CALL accept(5,53,"P(30);CU","")
 SET syn_loc_string = cnvtupper(curaccept)
 FREE RECORD syn_temp
 RECORD syn_temp(
   1 syn_list[*]
     2 syn_id = f8
     2 synonym = vc
     2 type = vc
 )
 SET syn_count = 0
 SET cpharm = uar_get_code_by("MEANING",6000,"PHARMACY")
 SET corder = uar_get_code_by("MEANING",6003,"ORDER")
 SELECT DISTINCT INTO "nl:"
  ocs.synonym_id, synonym = ocs.mnemonic, synonym_type = evaluate(trim(uar_get_code_display(ocs
     .mnemonic_type_cd)),"Ancillary","NON-CPOE","Brand Name","BRAND",
   "Direct Care Provider","DCP","C - Dispensable Drug Names","C","Generic Name",
   "NON-CPOE","Y - Generic Products","NON-CPOE","M - Generic Miscellaneous Products","M",
   "E - IV Fluids and Nicknames","E","Outreach","NON-CPOE","PathLink",
   "NON-CPOE","Primary","PRIMARY","Rx Mnemonic","NON-CPOE",
   "Surgery Med","NON-CPOE","Z - Trade Products","NON-CPOE","N - Trade Miscellaneous Products",
   "N")
  FROM order_catalog_synonym ocs,
   cs_component csc,
   order_catalog oc
  PLAN (csc
   WHERE csc.comp_id != 0)
   JOIN (oc
   WHERE oc.catalog_cd=csc.catalog_cd
    AND oc.orderable_type_flag=8
    AND oc.active_ind=1)
   JOIN (ocs
   WHERE ocs.synonym_id=csc.comp_id
    AND cnvtupper(ocs.mnemonic)=patstring(build(syn_loc_string,"*")))
  ORDER BY cnvtupper(ocs.mnemonic), synonym_type
  HEAD REPORT
   syn_count = 0
  DETAIL
   syn_count = (syn_count+ 1)
   IF (mod(syn_count,10)=1)
    stat = alterlist(syn_temp->syn_list,(syn_count+ 9))
   ENDIF
   syn_temp->syn_list[syn_count].syn_id = ocs.synonym_id, syn_temp->syn_list[syn_count].synonym =
   trim(ocs.mnemonic), syn_temp->syn_list[syn_count].type = synonym_type
  FOOT REPORT
   stat = alterlist(syn_temp->syn_list,syn_count)
  WITH nocounter
 ;end select
 CALL clear_screen(0)
 CALL text(3,2,"Medication synonyms in IV Sets:")
 CALL text(3,38,build(syn_loc_string,"*"))
 CALL text(5,67,"Total:  ")
 CALL text(5,75,cnvtstring(syn_count,4))
 CALL create_std_box(syn_count)
 CALL text(6,8,"Synonym")
 WHILE (cnt <= numsrow
  AND cnt <= maxcnt)
   SET holdstr60 = trim(syn_temp->syn_list[cnt].synonym)
   SET holdstr20 = fillstring(20," ")
   SET holdstr20 = trim(syn_temp->syn_list[cnt].type)
   SET holdstr = concat(cnvtstring(cnt,4,0,r)," ",holdstr60," ",holdstr20)
   CALL scrolltext(cnt,holdstr)
   SET cnt = (cnt+ 1)
 ENDWHILE
 SET cnt = 1
 SET arow = 1
 CALL text(23,1,"Select synonym to replace:         (enter 000 to go back)")
 SET pick = 0
 WHILE (pick=0)
  CALL accept(23,29,"9999;S",cnt)
  CASE (curscroll)
   OF 0:
    IF (curaccept=0)
     CALL clear_screen(0)
     GO TO common_utilities_mode
    ELSEIF (cnvtint(curaccept) BETWEEN 1 AND maxcnt)
     SET pick = cnvtint(curaccept)
     CALL clear_screen(0)
     CALL replace_ivs_syn(syn_temp->syn_list[pick].syn_id,syn_temp->syn_list[pick].synonym)
    ELSE
     CALL clear_screen(0)
     GO TO common_utilities_mode
    ENDIF
   OF 1:
    IF (cnt < maxcnt)
     SET cnt = (cnt+ 1)
     SET holdstr60 = trim(syn_temp->syn_list[cnt].synonym)
     SET holdstr20 = fillstring(20," ")
     SET holdstr20 = trim(syn_temp->syn_list[cnt].type)
     SET holdstr = concat(cnvtstring(cnt,4,0,r)," ",holdstr60," ",holdstr20)
     CALL down_arrow(holdstr)
    ENDIF
   OF 2:
    IF (cnt > 1)
     SET cnt = (cnt - 1)
     SET holdstr60 = trim(syn_temp->syn_list[cnt].synonym)
     SET holdstr20 = fillstring(20," ")
     SET holdstr20 = trim(syn_temp->syn_list[cnt].type)
     SET holdstr = concat(cnvtstring(cnt,4,0,r)," ",holdstr60," ",holdstr20)
     CALL up_arrow(holdstr)
    ENDIF
   OF 3:
   OF 4:
   OF 6:
    IF (numsrow < maxcnt)
     SET cnt = ((cnt+ numsrow) - 1)
     IF (((cnt+ numsrow) > maxcnt))
      SET cnt = (maxcnt - numsrow)
     ENDIF
     SET arow = 1
     WHILE (arow <= numsrow)
       SET cnt = (cnt+ 1)
       SET holdstr60 = trim(syn_temp->syn_list[cnt].synonym)
       SET holdstr20 = fillstring(20," ")
       SET holdstr20 = trim(syn_temp->syn_list[cnt].type)
       SET holdstr = concat(cnvtstring(cnt,4,0,r)," ",holdstr60," ",holdstr20)
       CALL scrolltext(arow,holdstr)
       SET arow = (arow+ 1)
     ENDWHILE
     SET arow = 1
     SET cnt = ((cnt - numsrow)+ 1)
    ENDIF
   OF 5:
    IF (((cnt - numsrow) > 0))
     SET cnt = (cnt - numsrow)
    ELSE
     SET cnt = 1
    ENDIF
    SET tmp1 = cnt
    SET arow = 1
    WHILE (arow <= numsrow
     AND cnt < maxcnt)
      SET holdstr60 = trim(syn_temp->syn_list[cnt].synonym)
      SET holdstr20 = fillstring(20," ")
      SET holdstr20 = trim(syn_temp->syn_list[cnt].type)
      SET holdstr = concat(cnvtstring(cnt,4,0,r)," ",holdstr60," ",holdstr20)
      CALL scrolltext(arow,holdstr)
      SET cnt = (cnt+ 1)
      SET arow = (arow+ 1)
    ENDWHILE
    SET cnt = tmp1
    SET arow = 1
  ENDCASE
 ENDWHILE
 CALL clear_screen(0)
 CALL text(23,1,"Replace another synonym? (Y/N) ")
 CALL accept(23,33,"C;CU","N"
  WHERE curaccept IN ("Y", "N"))
 CASE (curaccept)
  OF "Y":
   GO TO replace_ivs_syn
  OF "N":
   GO TO common_utilities_mode
 ENDCASE
 GO TO common_utilities_mode
#replace_ivs_syn_exit
#replace_plan_syn
 CALL clear_screen(0)
 CALL text(5,1,"Enter first character(s) of synonym to replace:   ")
 CALL accept(5,53,"P(30);CU","")
 SET syn_loc_string = cnvtupper(curaccept)
 FREE RECORD syn_temp
 RECORD syn_temp(
   1 syn_list[*]
     2 syn_id = f8
     2 synonym = vc
     2 type = vc
 )
 SET syn_count = 0
 SET cpharm = uar_get_code_by("MEANING",6000,"PHARMACY")
 SET corder = uar_get_code_by("MEANING",6003,"ORDER")
 SELECT DISTINCT INTO "nl:"
  ocs.synonym_id, synonym = ocs.mnemonic, synonym_type = evaluate(trim(uar_get_code_display(ocs
     .mnemonic_type_cd)),"Ancillary","NON-CPOE","Brand Name","BRAND",
   "Direct Care Provider","DCP","C - Dispensable Drug Names","C","Generic Name",
   "NON-CPOE","Y - Generic Products","NON-CPOE","M - Generic Miscellaneous Products","M",
   "E - IV Fluids and Nicknames","E","Outreach","NON-CPOE","PathLink",
   "NON-CPOE","Primary","PRIMARY","Rx Mnemonic","NON-CPOE",
   "Surgery Med","NON-CPOE","Z - Trade Products","NON-CPOE","N - Trade Miscellaneous Products",
   "N")
  FROM order_catalog_synonym ocs,
   pathway_comp pc,
   pathway_catalog pcat
  PLAN (pc
   WHERE pc.active_ind=1)
   JOIN (pcat
   WHERE pcat.pathway_catalog_id=pc.pathway_catalog_id
    AND pcat.active_ind=1
    AND pcat.pathway_catalog_id > 0)
   JOIN (ocs
   WHERE ocs.synonym_id=pc.parent_entity_id
    AND ocs.catalog_type_cd=cpharm
    AND cnvtupper(ocs.mnemonic)=patstring(build(syn_loc_string,"*")))
  ORDER BY cnvtupper(ocs.mnemonic), synonym_type
  HEAD REPORT
   syn_count = 0
  DETAIL
   syn_count = (syn_count+ 1)
   IF (mod(syn_count,10)=1)
    stat = alterlist(syn_temp->syn_list,(syn_count+ 9))
   ENDIF
   syn_temp->syn_list[syn_count].syn_id = ocs.synonym_id, syn_temp->syn_list[syn_count].synonym =
   trim(ocs.mnemonic), syn_temp->syn_list[syn_count].type = synonym_type
  FOOT REPORT
   stat = alterlist(syn_temp->syn_list,syn_count)
  WITH nocounter
 ;end select
 CALL clear_screen(0)
 CALL text(3,2,"Medication synonyms in PowerPlans:")
 CALL text(3,38,build(syn_loc_string,"*"))
 CALL text(5,67,"Total:  ")
 CALL text(5,75,cnvtstring(syn_count,4))
 CALL create_std_box(syn_count)
 CALL text(6,8,"Synonym")
 WHILE (cnt <= numsrow
  AND cnt <= maxcnt)
   SET holdstr60 = trim(syn_temp->syn_list[cnt].synonym)
   SET holdstr20 = fillstring(20," ")
   SET holdstr20 = trim(syn_temp->syn_list[cnt].type)
   SET holdstr = concat(cnvtstring(cnt,4,0,r)," ",holdstr60," ",holdstr20)
   CALL scrolltext(cnt,holdstr)
   SET cnt = (cnt+ 1)
 ENDWHILE
 SET cnt = 1
 SET arow = 1
 CALL text(23,1,"Select synonym to replace:         (enter 000 to go back)")
 SET pick = 0
 WHILE (pick=0)
  CALL accept(23,29,"9999;S",cnt)
  CASE (curscroll)
   OF 0:
    IF (curaccept=0)
     CALL clear_screen(0)
     GO TO common_utilities_mode
    ELSEIF (cnvtint(curaccept) BETWEEN 1 AND maxcnt)
     SET pick = cnvtint(curaccept)
     CALL clear_screen(0)
     CALL replace_pp_syn(syn_temp->syn_list[pick].syn_id,syn_temp->syn_list[pick].synonym)
    ELSE
     CALL clear_screen(0)
     GO TO common_utilities_mode
    ENDIF
   OF 1:
    IF (cnt < maxcnt)
     SET cnt = (cnt+ 1)
     SET holdstr60 = trim(syn_temp->syn_list[cnt].synonym)
     SET holdstr20 = fillstring(20," ")
     SET holdstr20 = trim(syn_temp->syn_list[cnt].type)
     SET holdstr = concat(cnvtstring(cnt,4,0,r)," ",holdstr60," ",holdstr20)
     CALL down_arrow(holdstr)
    ENDIF
   OF 2:
    IF (cnt > 1)
     SET cnt = (cnt - 1)
     SET holdstr60 = trim(syn_temp->syn_list[cnt].synonym)
     SET holdstr20 = fillstring(20," ")
     SET holdstr20 = trim(syn_temp->syn_list[cnt].type)
     SET holdstr = concat(cnvtstring(cnt,4,0,r)," ",holdstr60," ",holdstr20)
     CALL up_arrow(holdstr)
    ENDIF
   OF 3:
   OF 4:
   OF 6:
    IF (numsrow < maxcnt)
     SET cnt = ((cnt+ numsrow) - 1)
     IF (((cnt+ numsrow) > maxcnt))
      SET cnt = (maxcnt - numsrow)
     ENDIF
     SET arow = 1
     WHILE (arow <= numsrow)
       SET cnt = (cnt+ 1)
       SET holdstr60 = trim(syn_temp->syn_list[cnt].synonym)
       SET holdstr20 = fillstring(20," ")
       SET holdstr20 = trim(syn_temp->syn_list[cnt].type)
       SET holdstr = concat(cnvtstring(cnt,4,0,r)," ",holdstr60," ",holdstr20)
       CALL scrolltext(arow,holdstr)
       SET arow = (arow+ 1)
     ENDWHILE
     SET arow = 1
     SET cnt = ((cnt - numsrow)+ 1)
    ENDIF
   OF 5:
    IF (((cnt - numsrow) > 0))
     SET cnt = (cnt - numsrow)
    ELSE
     SET cnt = 1
    ENDIF
    SET tmp1 = cnt
    SET arow = 1
    WHILE (arow <= numsrow
     AND cnt < maxcnt)
      SET holdstr60 = trim(syn_temp->syn_list[cnt].synonym)
      SET holdstr20 = fillstring(20," ")
      SET holdstr20 = trim(syn_temp->syn_list[cnt].type)
      SET holdstr = concat(cnvtstring(cnt,4,0,r)," ",holdstr60," ",holdstr20)
      CALL scrolltext(arow,holdstr)
      SET cnt = (cnt+ 1)
      SET arow = (arow+ 1)
    ENDWHILE
    SET cnt = tmp1
    SET arow = 1
  ENDCASE
 ENDWHILE
 CALL clear_screen(0)
 CALL text(23,1,"Replace another synonym? (Y/N) ")
 CALL accept(23,33,"C;CU","N"
  WHERE curaccept IN ("Y", "N"))
 CASE (curaccept)
  OF "Y":
   GO TO replace_plan_syn
  OF "N":
   GO TO common_utilities_mode
 ENDCASE
 GO TO common_utilities_mode
#replace_plan_syn_exit
#rx_mnem_no_link
 CALL show_processing(0)
 SET cpharm = uar_get_code_by("MEANING",6000,"PHARMACY")
 SET cdesc = uar_get_code_by("MEANING",11000,"DESC")
 SET csystem = uar_get_code_by("MEANING",4062,"SYSTEM")
 SET cinpatient = uar_get_code_by("MEANING",4500,"INPATIENT")
 SET crxm = uar_get_code_by("MEANING",6011,"RXMNEMONIC")
 SET cprimary = uar_get_code_by("MEANING",6011,"PRIMARY")
 SET csyspkgtyp = uar_get_code_by("MEANING",4062,"SYSPKGTYP")
 SET corderable = uar_get_code_by("MEANING",4063,"ORDERABLE")
 FREE RECORD available_products
 RECORD available_products(
   1 products[*]
     2 item_id = f8
     2 catalog_cd = f8
     2 synonym_id = f8
 )
 SELECT INTO "nl:"
  md.item_id, product_desc = substring(1,50,mi.value), mfoi.*
  FROM medication_definition md,
   order_catalog_item_r ocir,
   item_definition id,
   med_def_flex mdf,
   med_flex_object_idx mfoi,
   med_identifier mi
  PLAN (md)
   JOIN (ocir
   WHERE ocir.item_id=md.item_id)
   JOIN (id
   WHERE id.item_id=ocir.item_id
    AND id.active_ind=1)
   JOIN (mdf
   WHERE mdf.item_id=md.item_id
    AND mdf.flex_type_cd=csyspkgtyp
    AND mdf.pharmacy_type_cd=cinpatient)
   JOIN (mfoi
   WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
    AND mfoi.flex_object_type_cd=corderable
    AND ((mfoi.parent_entity_id=0) OR (mfoi.parent_entity_id=cur_facility_cd)) )
   JOIN (mi
   WHERE mi.item_id=md.item_id
    AND mi.active_ind=1
    AND mi.primary_ind=1
    AND mi.med_product_id=0
    AND mi.med_identifier_type_cd=cdesc
    AND mi.pharmacy_type_cd=cinpatient)
  ORDER BY mi.value
  HEAD REPORT
   cnt = 0
  HEAD md.item_id
   cnt = (cnt+ 1), stat = alterlist(available_products->products,cnt), available_products->products[
   cnt].item_id = md.item_id,
   available_products->products[cnt].catalog_cd = ocir.catalog_cd, available_products->products[cnt].
   synonym_id = ocir.synonym_id
  WITH nullreport
 ;end select
 SELECT
  primary = substring(1,60,oc.primary_mnemonic), product = substring(1,60,mi.value), rx_mnemonic =
  ocs.mnemonic,
  ocs.synonym_id, ocs.item_id
  FROM (dummyt d1  WITH seq = value(size(available_products->products,5))),
   dummyt d2,
   (dummyt d3  WITH seq = value(size(available_products->products,5))),
   order_catalog_synonym ocs,
   order_catalog oc,
   med_identifier mi,
   item_definition id,
   synonym_item_r sir
  PLAN (d1)
   JOIN (ocs
   WHERE (available_products->products[d1.seq].synonym_id=ocs.synonym_id)
    AND ocs.mnemonic_type_cd=crxm)
   JOIN (oc
   WHERE oc.catalog_cd=ocs.catalog_cd
    AND oc.catalog_type_cd=cpharm
    AND oc.orderable_type_flag IN (0, 1))
   JOIN (mi
   WHERE (mi.item_id=available_products->products[d1.seq].item_id)
    AND mi.med_identifier_type_cd=cdesc
    AND mi.pharmacy_type_cd=cinpatient
    AND mi.med_product_id=0
    AND mi.primary_ind=1
    AND mi.active_ind=1)
   JOIN (id
   WHERE id.item_id=ocs.item_id
    AND id.active_ind=1)
   JOIN (d2)
   JOIN (sir
   WHERE sir.synonym_id=ocs.synonym_id)
   JOIN (d3
   WHERE (sir.item_id=available_products->products[d3.seq].item_id))
  ORDER BY cnvtupper(oc.primary_mnemonic), mi.value_key
  WITH outerjoin = d2, dontexist, format = pcformat
 ;end select
 GO TO poc_problem_mode
#rx_mnem_no_link_exit
#syn_no_link
 CALL show_processing(0)
 SET cpharm = uar_get_code_by("MEANING",6000,"PHARMACY")
 SET cprimary = uar_get_code_by("MEANING",6011,"PRIMARY")
 SET csystem = uar_get_code_by("MEANING",4062,"SYSTEM")
 SET csyspkgtyp = uar_get_code_by("MEANING",4062,"SYSPKGTYP")
 SET corderable = uar_get_code_by("MEANING",4063,"ORDERABLE")
 SET cinpatient = uar_get_code_by("MEANING",4500,"INPATIENT")
 SET cdesc = uar_get_code_by("MEANING",11000,"DESC")
 FREE RECORD available_products
 RECORD available_products(
   1 products[*]
     2 item_id = f8
     2 catalog_cd = f8
 )
 SELECT INTO "nl:"
  md.item_id, product_desc = substring(1,50,mi.value), mfoi.*
  FROM medication_definition md,
   order_catalog_item_r ocir,
   item_definition id,
   med_def_flex mdf,
   med_flex_object_idx mfoi,
   med_identifier mi
  PLAN (md)
   JOIN (ocir
   WHERE ocir.item_id=md.item_id)
   JOIN (id
   WHERE id.item_id=ocir.item_id
    AND id.active_ind=1)
   JOIN (mdf
   WHERE mdf.item_id=md.item_id
    AND mdf.flex_type_cd=csyspkgtyp
    AND mdf.pharmacy_type_cd=cinpatient)
   JOIN (mfoi
   WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
    AND mfoi.flex_object_type_cd=corderable
    AND ((mfoi.parent_entity_id=0) OR (mfoi.parent_entity_id=cur_facility_cd)) )
   JOIN (mi
   WHERE mi.item_id=md.item_id
    AND mi.active_ind=1
    AND mi.primary_ind=1
    AND mi.med_product_id=0
    AND mi.med_identifier_type_cd=cdesc
    AND mi.pharmacy_type_cd=cinpatient)
  ORDER BY mi.value
  HEAD REPORT
   cnt = 0
  HEAD md.item_id
   cnt = (cnt+ 1), stat = alterlist(available_products->products,cnt), available_products->products[
   cnt].item_id = md.item_id,
   available_products->products[cnt].catalog_cd = ocir.catalog_cd
  WITH nullreport
 ;end select
 SELECT
  primary = substring(1,60,oc.primary_mnemonic), synonym = substring(1,60,ocs.mnemonic), synonym_type
   = uar_get_code_display(ocs.mnemonic_type_cd),
  ocs.synonym_id, ocs.catalog_cd
  FROM order_catalog_synonym ocs,
   ocs_facility_r ofr,
   order_catalog oc,
   dummyt d1,
   synonym_item_r sir,
   (dummyt d2  WITH seq = value(size(available_products->products,5)))
  PLAN (oc
   WHERE oc.catalog_type_cd=cpharm
    AND oc.orderable_type_flag IN (0, 1)
    AND oc.active_ind=1)
   JOIN (ocs
   WHERE oc.catalog_cd=ocs.catalog_cd
    AND ocs.mnemonic_type_cd IN (
   (SELECT
    code_value
    FROM code_value
    WHERE code_set=6011
     AND cdf_meaning IN ("BRANDNAME", "DCP", "DISPDRUG", "GENERICTOP", "IVNAME",
    "PRIMARY", "TRADETOP")))
    AND ocs.active_ind=1
    AND ((ocs.hide_flag=null) OR (ocs.hide_flag=0)) )
   JOIN (ofr
   WHERE ofr.synonym_id=ocs.synonym_id
    AND ((ofr.facility_cd=0) OR (ofr.facility_cd=cur_facility_cd)) )
   JOIN (d1)
   JOIN (sir
   WHERE sir.synonym_id=ocs.synonym_id)
   JOIN (d2
   WHERE (available_products->products[d2.seq].item_id=sir.item_id))
  ORDER BY cnvtupper(oc.primary_mnemonic), ocs.mnemonic_key_cap
  WITH outerjoin = d1, dontexist, format = pcformat
 ;end select
 GO TO pharm_problem_mode
#syn_no_link_exit
#phasex_sent_by_prod
 IF (validate(isodbc,0)=0)
  EXECUTE cclseclogin
 ENDIF
 CALL clear_screen(0)
 CALL text(4,1,"Examine orders placed within how many days (max = 180) ? ")
 CALL text(23,1,"Output will be written to 'asc_prod_order_summary.csv' in CCLUSERDIR.")
 CALL accept(4,60,"P(3);CU","30"
  WHERE cnvtreal(curaccept) > 0)
 SET inc_lookback_days = cnvtreal(curaccept)
 CALL text(5,1,"Minimum order threshold for 'common orders' (min = 2) ? ")
 CALL accept(5,60,"P(3);CU","3"
  WHERE cnvtreal(curaccept) > 0)
 SET inc_min_ord_threshold = cnvtreal(curaccept)
 CALL show_processing(0)
 IF (inc_lookback_days > 180)
  SET inc_lookback_days = 180
 ENDIF
 IF (inc_min_ord_threshold < 2)
  SET inc_min_ord_threshold = 2
 ENDIF
 DECLARE sentence_line = vc
 DECLARE str_vol_line = vc
 DECLARE out_line = vc
 SET cpharm = uar_get_code_by("MEANING",6000,"PHARMACY")
 SET batch_number = 0
 SET cur_lookback_day = inc_lookback_days
 FREE RECORD list
 RECORD list(
   1 orders[*]
     2 item_id = f8
     2 order_sentence = vc
     2 count = f8
     2 strengthdose = vc
     2 strengthdoseunit = vc
     2 volumedose = vc
     2 volumedoseunit = vc
     2 rxroute = vc
     2 freq = vc
     2 rxpriority = vc
     2 schprn = vc
     2 prnreason = vc
     2 rate = vc
     2 rateunit = vc
     2 freetextrate = vc
     2 infuseover = vc
     2 infuseoverunit = vc
 )
 SET cpharm = uar_get_code_by("MEANING",6000,"PHARMACY")
 SET cprimary = uar_get_code_by("MEANING",6011,"PRIMARY")
 SET csystem = uar_get_code_by("MEANING",4062,"SYSTEM")
 SET csyspkgtyp = uar_get_code_by("MEANING",4062,"SYSPKGTYP")
 SET corderable = uar_get_code_by("MEANING",4063,"ORDERABLE")
 SET cinpatient = uar_get_code_by("MEANING",4500,"INPATIENT")
 SET cdesc = uar_get_code_by("MEANING",11000,"DESC")
 FREE RECORD available_products
 RECORD available_products(
   1 products[*]
     2 item_id = f8
     2 catalog_cd = f8
 )
 SELECT INTO "nl:"
  md.item_id, product_desc = substring(1,50,mi.value), mfoi.*
  FROM medication_definition md,
   order_catalog_item_r ocir,
   item_definition id,
   med_def_flex mdf,
   med_flex_object_idx mfoi,
   med_identifier mi
  PLAN (md)
   JOIN (ocir
   WHERE ocir.item_id=md.item_id)
   JOIN (id
   WHERE id.item_id=ocir.item_id
    AND id.active_ind=1)
   JOIN (mdf
   WHERE mdf.item_id=md.item_id
    AND mdf.flex_type_cd=csyspkgtyp
    AND mdf.pharmacy_type_cd=cinpatient)
   JOIN (mfoi
   WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
    AND mfoi.flex_object_type_cd=corderable
    AND ((mfoi.parent_entity_id=0) OR (mfoi.parent_entity_id=cur_facility_cd)) )
   JOIN (mi
   WHERE mi.item_id=md.item_id
    AND mi.active_ind=1
    AND mi.primary_ind=1
    AND mi.med_product_id=0
    AND mi.med_identifier_type_cd=cdesc
    AND mi.pharmacy_type_cd=cinpatient)
  ORDER BY mi.value
  HEAD REPORT
   cnt = 0
  HEAD md.item_id
   cnt = (cnt+ 1), stat = alterlist(available_products->products,cnt), available_products->products[
   cnt].item_id = md.item_id,
   available_products->products[cnt].catalog_cd = ocir.catalog_cd
  WITH nullreport
 ;end select
 WHILE (cur_lookback_day > 0)
   SET batch_number = (batch_number+ 1)
   CALL text(7,1,concat("Processing day ",cnvtstring(batch_number,3,0)))
   CALL echo("------------------------------------------------")
   CALL echo(build("Processing day number: ",batch_number))
   CALL echo(build("Days remaining: ",(cur_lookback_day - 1)))
   CALL echo("------------------------------------------------")
   CALL echo(".")
   SELECT INTO "nl:"
    o.order_id, oi.ingredient_type_flag, o.iv_ind,
    order_name = substring(1,40,o.order_mnemonic), strengthdose = od1.oe_field_value,
    strengthdoseunit = uar_get_code_display(od2.oe_field_value),
    volumedose = od3.oe_field_value, volumedoseunit = uar_get_code_display(od4.oe_field_value),
    frequency = uar_get_code_display(od8.oe_field_value),
    route = uar_get_code_display(od5.oe_field_value), prn = od6.oe_field_value, prn_reason =
    uar_get_code_display(od7.oe_field_value),
    freetextrate = od9.oe_field_display_value, rate = od10.oe_field_value, rateunit =
    uar_get_code_display(od11.oe_field_value),
    infuseover = od12.oe_field_value, infuseoverunit = uar_get_code_display(od13.oe_field_value),
    rxpriority = uar_get_code_display(od14.oe_field_value)
    FROM orders o,
     encntr_domain ed,
     order_product op,
     (dummyt d  WITH seq = value(size(available_products->products,5))),
     order_ingredient oi,
     order_detail od1,
     order_detail od2,
     order_detail od3,
     order_detail od4,
     order_detail od5,
     order_detail od6,
     order_detail od7,
     order_detail od8,
     order_detail od9,
     order_detail od10,
     order_detail od11,
     order_detail od12,
     order_detail od13,
     order_detail od14
    PLAN (o
     WHERE o.catalog_type_cd=cpharm
      AND o.orig_order_dt_tm > cnvtdatetime((curdate - cur_lookback_day),curtime3)
      AND o.orig_order_dt_tm < cnvtdatetime(((curdate - cur_lookback_day)+ 1),curtime3)
      AND o.orig_ord_as_flag=0
      AND o.template_order_flag IN (0, 1)
      AND o.cs_flag != 1
      AND ((o.iv_ind=null) OR (o.iv_ind=0)) )
     JOIN (ed
     WHERE ed.encntr_id=o.encntr_id
      AND ((cur_facility_cd=0) OR (ed.loc_facility_cd=cur_facility_cd)) )
     JOIN (op
     WHERE op.order_id=o.order_id
      AND op.action_sequence=1)
     JOIN (d
     WHERE (available_products->products[d.seq].item_id=op.item_id))
     JOIN (oi
     WHERE oi.order_id=op.order_id
      AND oi.comp_sequence=op.ingred_sequence
      AND oi.action_sequence=1
      AND oi.ingredient_type_flag IN (1, 3))
     JOIN (od1
     WHERE od1.order_id=outerjoin(o.order_id)
      AND od1.oe_field_meaning=outerjoin("STRENGTHDOSE")
      AND od1.action_sequence=outerjoin(1))
     JOIN (od2
     WHERE od2.order_id=outerjoin(o.order_id)
      AND od2.oe_field_meaning=outerjoin("STRENGTHDOSEUNIT")
      AND od2.action_sequence=outerjoin(1))
     JOIN (od3
     WHERE od3.order_id=outerjoin(o.order_id)
      AND od3.oe_field_meaning=outerjoin("VOLUMEDOSE")
      AND od3.action_sequence=outerjoin(1))
     JOIN (od4
     WHERE od4.order_id=outerjoin(o.order_id)
      AND od4.oe_field_meaning=outerjoin("VOLUMEDOSEUNIT")
      AND od4.action_sequence=outerjoin(1))
     JOIN (od5
     WHERE od5.order_id=outerjoin(o.order_id)
      AND od5.oe_field_meaning=outerjoin("RXROUTE")
      AND od5.action_sequence=outerjoin(1))
     JOIN (od6
     WHERE od6.order_id=outerjoin(o.order_id)
      AND od6.oe_field_meaning=outerjoin("SCH/PRN")
      AND od6.action_sequence=outerjoin(1))
     JOIN (od7
     WHERE od7.order_id=outerjoin(o.order_id)
      AND od7.oe_field_meaning=outerjoin("PRNREASON")
      AND od7.action_sequence=outerjoin(1))
     JOIN (od8
     WHERE od8.order_id=outerjoin(o.order_id)
      AND od8.oe_field_meaning=outerjoin("FREQ")
      AND od8.action_sequence=outerjoin(1))
     JOIN (od9
     WHERE od9.order_id=outerjoin(o.order_id)
      AND od9.oe_field_meaning=outerjoin("FREETEXTRATE")
      AND od9.action_sequence=outerjoin(1))
     JOIN (od10
     WHERE od10.order_id=outerjoin(o.order_id)
      AND od10.oe_field_meaning=outerjoin("RATE")
      AND od10.action_sequence=outerjoin(1))
     JOIN (od11
     WHERE od11.order_id=outerjoin(o.order_id)
      AND od11.oe_field_meaning=outerjoin("RATEUNIT")
      AND od11.action_sequence=outerjoin(1))
     JOIN (od12
     WHERE od12.order_id=outerjoin(o.order_id)
      AND od12.oe_field_meaning=outerjoin("INFUSEOVER")
      AND od12.action_sequence=outerjoin(1))
     JOIN (od13
     WHERE od13.order_id=outerjoin(o.order_id)
      AND od13.oe_field_meaning=outerjoin("INFUSEOVERUNIT")
      AND od13.action_sequence=outerjoin(1))
     JOIN (od14
     WHERE od14.order_id=outerjoin(o.order_id)
      AND od14.oe_field_meaning=outerjoin("RXPRIORITY")
      AND od14.action_sequence=outerjoin(1))
    ORDER BY op.item_id, o.order_id
    HEAD REPORT
     cnt = 0, assigned = 0, sentence_pos = 0,
     item_begin_pos = 0, str_flag = 0, err_flag = 0
    HEAD op.item_id
     item_begin_pos = 0
    HEAD o.order_id
     cnt = (cnt+ 1), sentence_pos = 0, str_flag = 0,
     err_flag = 0, sentence_line = "Error"
     IF (od1.oe_field_value > 0
      AND od2.oe_field_value > 0
      AND od3.oe_field_value > 0
      AND od4.oe_field_value > 0)
      str_flag = 1, sentence_line = concat(build(num_to_str(od1.oe_field_value))," ",trim(
        strengthdoseunit)," / ",build(num_to_str(od3.oe_field_value)),
       " ",trim(volumedoseunit))
     ELSEIF (od1.oe_field_value > 0
      AND od2.oe_field_value > 0)
      str_flag = 1, sentence_line = concat(build(num_to_str(od1.oe_field_value))," ",trim(
        strengthdoseunit))
     ELSEIF (od3.oe_field_value > 0
      AND od4.oe_field_value > 0)
      sentence_line = concat(build(num_to_str(od3.oe_field_value))," ",trim(volumedoseunit))
     ELSE
      err_flag = 1
     ENDIF
     IF (od8.oe_field_value > 0)
      sentence_line = concat(sentence_line,", ",trim(frequency))
     ENDIF
     IF (od14.oe_field_value > 0)
      sentence_line = concat(sentence_line,", ",trim(rxpriority))
     ENDIF
     sentence_line = concat(sentence_line,", ",route)
     IF (prn=1)
      sentence_line = concat(sentence_line,", ","PRN")
     ENDIF
     IF (od7.oe_field_value > 0)
      sentence_line = concat(sentence_line,", ","reason: ",trim(prn_reason))
     ENDIF
     IF (od10.oe_field_value > 0
      AND o.iv_ind=1)
      sentence_line = concat(sentence_line,", ",cnvtstring(rate,11,3))
     ENDIF
     IF (od11.oe_field_value > 0
      AND o.iv_ind=1)
      sentence_line = concat(sentence_line," ",rateunit)
     ENDIF
     IF (trim(freetextrate) > " ")
      sentence_line = concat(sentence_line,", ",trim(freetextrate))
     ENDIF
     IF (od12.oe_field_value > 0
      AND ((o.iv_ind=0) OR (o.iv_ind=null)) )
      sentence_line = concat(sentence_line,", ",cnvtstring(infuseover,11,3))
     ENDIF
     IF (od13.oe_field_value > 0
      AND ((o.iv_ind=0) OR (o.iv_ind=null)) )
      sentence_line = concat(sentence_line," ",infuseoverunit)
     ENDIF
     IF (size(list->orders,5)=0
      AND err_flag=0)
      stat = alterlist(list->orders,1), list->orders[1].item_id = op.item_id, list->orders[1].
      order_sentence = sentence_line,
      list->orders[1].count = 1, assigned = (assigned+ 1), item_begin_pos = 1
      IF (str_flag=1)
       list->orders[1].strengthdose = build(num_to_str(od1.oe_field_value)), list->orders[1].
       strengthdoseunit = strengthdoseunit
      ELSE
       list->orders[1].volumedose = build(num_to_str(od3.oe_field_value)), list->orders[1].
       volumedoseunit = volumedoseunit
      ENDIF
      list->orders[1].rxroute = route, list->orders[1].freq = frequency, list->orders[1].rxpriority
       = rxpriority,
      list->orders[1].schprn = trim(cnvtstring(prn,11,0)), list->orders[1].prnreason = prn_reason
      IF (rate > 0
       AND o.iv_ind=1)
       list->orders[1].rate = trim(cnvtstring(rate,11,3)), list->orders[1].rateunit = rateunit
      ENDIF
      list->orders[1].freetextrate = freetextrate
      IF (infuseover > 0
       AND ((o.iv_ind=null) OR (o.iv_ind=0)) )
       list->orders[1].infuseover = trim(cnvtstring(infuseover,11,3)), list->orders[1].infuseoverunit
        = infuseoverunit
      ENDIF
     ELSEIF (err_flag=0)
      sentence_pos = find_sentence_pos_itm(op.item_id,sentence_line)
      IF ((list->orders[sentence_pos].order_sentence=sentence_line)
       AND sentence_line != "Error"
       AND sentence_pos > 0)
       list->orders[sentence_pos].count = (list->orders[sentence_pos].count+ 1), assigned = (assigned
       + 1)
      ELSE
       stat = alterlist(list->orders,(size(list->orders,5)+ 1)), list->orders[size(list->orders,5)].
       item_id = op.item_id, list->orders[size(list->orders,5)].order_sentence = sentence_line,
       list->orders[size(list->orders,5)].count = 1, assigned = (assigned+ 1), item_begin_pos = size(
        list->orders,5)
       IF (str_flag=1)
        list->orders[size(list->orders,5)].strengthdose = build(num_to_str(od1.oe_field_value)), list
        ->orders[size(list->orders,5)].strengthdoseunit = strengthdoseunit
       ELSE
        list->orders[size(list->orders,5)].volumedose = build(num_to_str(od3.oe_field_value)), list->
        orders[size(list->orders,5)].volumedoseunit = volumedoseunit
       ENDIF
       list->orders[size(list->orders,5)].rxroute = route, list->orders[size(list->orders,5)].freq =
       frequency, list->orders[size(list->orders,5)].rxpriority = rxpriority,
       list->orders[size(list->orders,5)].schprn = trim(cnvtstring(prn,11,0)), list->orders[size(list
        ->orders,5)].prnreason = prn_reason
       IF (rate > 0
        AND o.iv_ind=1)
        list->orders[size(list->orders,5)].rate = trim(cnvtstring(rate,11,3)), list->orders[size(list
         ->orders,5)].rateunit = rateunit
       ENDIF
       list->orders[size(list->orders,5)].freetextrate = freetextrate
       IF (infuseover > 0
        AND ((o.iv_ind=null) OR (o.iv_ind=0)) )
        list->orders[size(list->orders,5)].infuseover = trim(cnvtstring(infuseover,11,3)), list->
        orders[size(list->orders,5)].infuseoverunit = infuseoverunit
       ENDIF
      ENDIF
     ENDIF
    WITH nullreport
   ;end select
   SET cur_lookback_day = (cur_lookback_day - 1)
 ENDWHILE
 CALL text(8,1,"Removing orders which did not meet the minimum threshold... ")
 FOR (xloop = 1 TO size(list->orders,5))
   IF ((list->orders[xloop].count < 3))
    SET list->orders[xloop].count = 0
    SET list->orders[xloop].item_id = 0
    SET list->orders[xloop].order_sentence = ""
   ENDIF
 ENDFOR
 SET cdesc = uar_get_code_by("MEANING",11000,"DESC")
 SET cndc = uar_get_code_by("MEANING",11000,"NDC")
 SET cbrand = uar_get_code_by("MEANING",11000,"BRAND_NAME")
 SET cgeneric = uar_get_code_by("MEANING",11000,"GENERIC_NAME")
 CALL text(11,1,"Creating output file... ")
 SET cinpatient = uar_get_code_by("MEANING",4500,"INPATIENT")
 SELECT INTO "asc_prod_order_summary.csv"
  item_id = list->orders[d.seq].item_id, desc = mi1.value, generic = mi2.value,
  brand = mi3.value, form = uar_get_code_display(md.form_cd), strength = mdsp.strength,
  strengthunit = uar_get_code_display(mdsp.strength_unit_cd), volume = mdsp.volume, volumeunit =
  uar_get_code_display(mdsp.volume_unit_cd),
  sentence = substring(1,100,list->orders[d.seq].order_sentence), count = cnvtstring(list->orders[d
   .seq].count,3,0)
  FROM (dummyt d  WITH seq = value(size(list->orders,5))),
   med_identifier mi1,
   med_identifier mi2,
   med_identifier mi3,
   medication_definition md,
   med_dispense mdsp,
   item_definition id,
   dummyt d1,
   dummyt d2,
   dummyt d3
  PLAN (d
   WHERE (((list->orders[d.seq].count >= inc_min_ord_threshold)) OR ((list->orders[d.seq].count=0)))
    AND (list->orders[d.seq].item_id > 0))
   JOIN (md
   WHERE (md.item_id=list->orders[d.seq].item_id))
   JOIN (mdsp
   WHERE (mdsp.item_id=list->orders[d.seq].item_id))
   JOIN (id
   WHERE (id.item_id=list->orders[d.seq].item_id)
    AND id.active_ind=1)
   JOIN (d1)
   JOIN (mi1
   WHERE (mi1.item_id=list->orders[d.seq].item_id)
    AND mi1.med_identifier_type_cd=cdesc
    AND mi1.primary_ind=1
    AND mi1.active_ind=1
    AND mi1.med_product_id=0
    AND mi1.pharmacy_type_cd=cinpatient)
   JOIN (d2)
   JOIN (mi2
   WHERE (mi2.item_id=list->orders[d.seq].item_id)
    AND mi2.med_identifier_type_cd=cgeneric
    AND mi2.primary_ind=1
    AND mi2.active_ind=1
    AND mi2.med_product_id=0
    AND mi2.pharmacy_type_cd=cinpatient)
   JOIN (d3)
   JOIN (mi3
   WHERE (mi3.item_id=list->orders[d.seq].item_id)
    AND mi3.med_identifier_type_cd=cbrand
    AND mi3.primary_ind=1
    AND mi3.active_ind=1
    AND mi3.med_product_id=0
    AND mi3.pharmacy_type_cd=cinpatient)
  HEAD REPORT
   order_cnt = 0, col 0, "ITEM_ID,",
   "LABEL_DESC,", "GENERIC_NAME,", "BRAND_NAME,",
   "FORM,", "STRENGTH_VOLUME,", "COUNT,",
   "SCRIPT,", "STRENGTHDOSE,", "STRENGTHDOSEUNIT,",
   "VOLUMEDOSE,", "VOLUMEDOSEUNIT,", "FREQ,",
   "PRIORITY,", "RXROUTE,", "SCH/PRN,",
   "PRNREASON,", "SPECINX,", "RATE,",
   "RATEUNIT,", "FREETEXTRATE,", "INFUSEOVER,",
   "INFUSEOVERUNIT,", "DURATION,", "DURATIONUNIT,",
   "ORDERCOMMENT"
  DETAIL
   str_vol_line = "Error"
   IF (strength > 0
    AND mdsp.strength_unit_cd > 0
    AND volume > 0
    AND mdsp.volume_unit_cd > 0)
    str_vol_line = concat(build(num_to_str(mdsp.strength))," ",trim(strengthunit)," / ",build(
      num_to_str(mdsp.volume)),
     " ",trim(volumeunit))
   ELSEIF (strength > 0
    AND mdsp.strength_unit_cd > 0)
    str_vol_line = concat(build(num_to_str(mdsp.strength))," ",trim(strengthunit))
   ELSEIF (volume > 0
    AND mdsp.volume_unit_cd > 0)
    str_vol_line = concat(build(num_to_str(mdsp.volume))," ",trim(volumeunit))
   ENDIF
   order_cnt = (order_cnt+ 1), row + 1, out_line = concat('"',build(list->orders[d.seq].item_id),'"',
    ",",'"',
    trim(desc),'"',",",'"',trim(generic),
    '"',",",'"',trim(brand),'"',
    ",",'"',trim(form),'"',",",
    '"',trim(str_vol_line),'"',",",'"',
    trim(cnvtstring(list->orders[d.seq].count)),'"',",",'"',trim(list->orders[d.seq].order_sentence),
    '"',",",'"',trim(list->orders[d.seq].strengthdose),'"',
    ",",'"',trim(list->orders[d.seq].strengthdoseunit),'"',",",
    '"',trim(list->orders[d.seq].volumedose),'"',",",'"',
    trim(list->orders[d.seq].volumedoseunit),'"',",",'"',trim(list->orders[d.seq].freq),
    '"',",",'"',trim(list->orders[d.seq].rxpriority),'"',
    ",",'"',trim(list->orders[d.seq].rxroute),'"',",",
    '"',trim(list->orders[d.seq].schprn),'"',",",'"',
    trim(list->orders[d.seq].prnreason),'"',",",'"','"',
    ",",'"',trim(list->orders[d.seq].rate),'"',",",
    '"',trim(list->orders[d.seq].rateunit),'"',",",'"',
    trim(list->orders[d.seq].freetextrate),'"',",",'"',trim(list->orders[d.seq].infuseover),
    '"',",",'"',trim(list->orders[d.seq].infuseoverunit),'"',
    ",",'"','"',",",'"',
    '"',",",'"','"'),
   col 0, out_line
  FOOT REPORT
   CALL echo("."),
   CALL echo("------------------------------------------------"),
   CALL echo(build("Processing complete")),
   CALL echo(build("Results written to CCLUSERDIR file: asc_prod_order_summary.csv")),
   CALL echo(concat("Total unqiue orders meeting minimum threshold: ",build(order_cnt))),
   CALL echo("------------------------------------------------")
   IF (order_cnt > 65535)
    CALL echo(build("... WARNING!!! ...")),
    CALL echo(build("Results exceeded maximum Excel row count")),
    CALL echo(build("Recommend increasing minimum order threshold")),
    CALL echo("------------------------------------------------")
   ENDIF
  WITH check, maxcol = 1500, format = variable,
   nullreport, noformfeed, landscape,
   maxrow = 1, outerjoin = d1, outerjoin = d2,
   outerjoin = d3
 ;end select
 GO TO pharm_extract_mode
#phasex_sent_by_prod_exit
#phasex_sent_by_mmdc
 IF (validate(isodbc,0)=0)
  EXECUTE cclseclogin
 ENDIF
 CALL clear_screen(0)
 CALL text(4,1,"Examine orders placed within how many days (max = 180) ? ")
 CALL text(23,1,"Output will be written to 'asc_mmdc_order_summary.csv' in CCLUSERDIR.")
 CALL accept(4,60,"P(3);CU","30"
  WHERE cnvtreal(curaccept) > 0)
 SET inc_lookback_days = cnvtreal(curaccept)
 CALL text(5,1,"Minimum order threshold for 'common orders' (min = 2) ? ")
 CALL accept(5,60,"P(3);CU","3"
  WHERE cnvtreal(curaccept) > 0)
 SET inc_min_ord_threshold = cnvtreal(curaccept)
 CALL show_processing(0)
 IF (inc_lookback_days > 180)
  SET inc_lookback_days = 180
 ENDIF
 IF (inc_min_ord_threshold < 2)
  SET inc_min_ord_threshold = 2
 ENDIF
 DECLARE sentence_line = vc
 DECLARE out_line = vc
 SET cpharm = uar_get_code_by("MEANING",6000,"PHARMACY")
 SET batch_number = 0
 SET cur_lookback_day = inc_lookback_days
 FREE RECORD list
 RECORD list(
   1 orders[*]
     2 mmdc_cki = vc
     2 order_sentence = vc
     2 count = f8
     2 strengthdose = vc
     2 strengthdoseunit = vc
     2 volumedose = vc
     2 volumedoseunit = vc
     2 rxroute = vc
     2 freq = vc
     2 schprn = vc
     2 prnreason = vc
     2 rate = vc
     2 rateunit = vc
     2 freetextrate = vc
     2 infuseover = vc
     2 infuseoverunit = vc
     2 rxpriority = vc
 )
 SET cpharm = uar_get_code_by("MEANING",6000,"PHARMACY")
 SET cprimary = uar_get_code_by("MEANING",6011,"PRIMARY")
 SET csystem = uar_get_code_by("MEANING",4062,"SYSTEM")
 SET csyspkgtyp = uar_get_code_by("MEANING",4062,"SYSPKGTYP")
 SET corderable = uar_get_code_by("MEANING",4063,"ORDERABLE")
 SET cinpatient = uar_get_code_by("MEANING",4500,"INPATIENT")
 SET cdesc = uar_get_code_by("MEANING",11000,"DESC")
 FREE RECORD available_products
 RECORD available_products(
   1 products[*]
     2 item_id = f8
     2 catalog_cd = f8
 )
 SELECT INTO "nl:"
  md.item_id, product_desc = substring(1,50,mi.value), mfoi.*
  FROM medication_definition md,
   order_catalog_item_r ocir,
   item_definition id,
   med_def_flex mdf,
   med_flex_object_idx mfoi,
   med_identifier mi
  PLAN (md)
   JOIN (ocir
   WHERE ocir.item_id=md.item_id)
   JOIN (id
   WHERE id.item_id=ocir.item_id
    AND id.active_ind=1)
   JOIN (mdf
   WHERE mdf.item_id=md.item_id
    AND mdf.flex_type_cd=csyspkgtyp
    AND mdf.pharmacy_type_cd=cinpatient)
   JOIN (mfoi
   WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
    AND mfoi.flex_object_type_cd=corderable
    AND ((mfoi.parent_entity_id=0) OR (mfoi.parent_entity_id=cur_facility_cd)) )
   JOIN (mi
   WHERE mi.item_id=md.item_id
    AND mi.active_ind=1
    AND mi.primary_ind=1
    AND mi.med_product_id=0
    AND mi.med_identifier_type_cd=cdesc
    AND mi.pharmacy_type_cd=cinpatient)
  ORDER BY mi.value
  HEAD REPORT
   cnt = 0
  HEAD md.item_id
   cnt = (cnt+ 1), stat = alterlist(available_products->products,cnt), available_products->products[
   cnt].item_id = md.item_id,
   available_products->products[cnt].catalog_cd = ocir.catalog_cd
  WITH nullreport
 ;end select
 WHILE (cur_lookback_day > 0)
   SET batch_number = (batch_number+ 1)
   CALL text(7,1,concat("Processing day ",cnvtstring(batch_number,3,0)))
   CALL echo("------------------------------------------------")
   CALL echo(build("Processing day number: ",batch_number))
   CALL echo(build("Days remaining: ",(cur_lookback_day - 1)))
   CALL echo("------------------------------------------------")
   CALL echo(".")
   SELECT INTO "nl:"
    o.order_id, oi.ingredient_type_flag, o.iv_ind,
    order_name = substring(1,40,o.order_mnemonic), mmdc = md.cki, strengthdose = od1.oe_field_value,
    strengthdoseunit = uar_get_code_display(od2.oe_field_value), volumedose = od3.oe_field_value,
    volumedoseunit = uar_get_code_display(od4.oe_field_value),
    frequency = uar_get_code_display(od8.oe_field_value), route = uar_get_code_display(od5
     .oe_field_value), prn = od6.oe_field_value,
    prn_reason = uar_get_code_display(od7.oe_field_value), freetextrate = od9.oe_field_display_value,
    rate = od10.oe_field_value,
    rateunit = uar_get_code_display(od11.oe_field_value), infuseover = od12.oe_field_value,
    infuseoverunit = uar_get_code_display(od13.oe_field_value),
    rxpriority = uar_get_code_display(od14.oe_field_value)
    FROM orders o,
     encntr_domain ed,
     order_product op,
     (dummyt d  WITH seq = value(size(available_products->products,5))),
     order_ingredient oi,
     medication_definition md,
     order_detail od1,
     order_detail od2,
     order_detail od3,
     order_detail od4,
     order_detail od5,
     order_detail od6,
     order_detail od7,
     order_detail od8,
     order_detail od9,
     order_detail od10,
     order_detail od11,
     order_detail od12,
     order_detail od13,
     order_detail od14
    PLAN (o
     WHERE o.catalog_type_cd=cpharm
      AND o.orig_order_dt_tm > cnvtdatetime((curdate - cur_lookback_day),curtime3)
      AND o.orig_order_dt_tm < cnvtdatetime(((curdate - cur_lookback_day)+ 1),curtime3)
      AND o.orig_ord_as_flag=0
      AND o.template_order_flag IN (0, 1)
      AND o.cs_flag != 1
      AND ((o.iv_ind=null) OR (o.iv_ind=0)) )
     JOIN (ed
     WHERE ed.encntr_id=o.encntr_id
      AND ((cur_facility_cd=0) OR (ed.loc_facility_cd=cur_facility_cd)) )
     JOIN (op
     WHERE op.order_id=o.order_id
      AND op.action_sequence=1)
     JOIN (d
     WHERE (available_products->products[d.seq].item_id=op.item_id))
     JOIN (oi
     WHERE oi.order_id=op.order_id
      AND oi.comp_sequence=op.ingred_sequence
      AND oi.action_sequence=1
      AND oi.ingredient_type_flag IN (1, 3))
     JOIN (md
     WHERE op.item_id=md.item_id
      AND md.cki IS NOT null
      AND trim(md.cki) >= " ")
     JOIN (od1
     WHERE od1.order_id=outerjoin(o.order_id)
      AND od1.oe_field_meaning=outerjoin("STRENGTHDOSE")
      AND od1.action_sequence=outerjoin(1))
     JOIN (od2
     WHERE od2.order_id=outerjoin(o.order_id)
      AND od2.oe_field_meaning=outerjoin("STRENGTHDOSEUNIT")
      AND od2.action_sequence=outerjoin(1))
     JOIN (od3
     WHERE od3.order_id=outerjoin(o.order_id)
      AND od3.oe_field_meaning=outerjoin("VOLUMEDOSE")
      AND od3.action_sequence=outerjoin(1))
     JOIN (od4
     WHERE od4.order_id=outerjoin(o.order_id)
      AND od4.oe_field_meaning=outerjoin("VOLUMEDOSEUNIT")
      AND od4.action_sequence=outerjoin(1))
     JOIN (od5
     WHERE od5.order_id=outerjoin(o.order_id)
      AND od5.oe_field_meaning=outerjoin("RXROUTE")
      AND od5.action_sequence=outerjoin(1))
     JOIN (od6
     WHERE od6.order_id=outerjoin(o.order_id)
      AND od6.oe_field_meaning=outerjoin("SCH/PRN")
      AND od6.action_sequence=outerjoin(1))
     JOIN (od7
     WHERE od7.order_id=outerjoin(o.order_id)
      AND od7.oe_field_meaning=outerjoin("PRNREASON")
      AND od7.action_sequence=outerjoin(1))
     JOIN (od8
     WHERE od8.order_id=outerjoin(o.order_id)
      AND od8.oe_field_meaning=outerjoin("FREQ")
      AND od8.action_sequence=outerjoin(1))
     JOIN (od9
     WHERE od9.order_id=outerjoin(o.order_id)
      AND od9.oe_field_meaning=outerjoin("FREETEXTRATE")
      AND od9.action_sequence=outerjoin(1))
     JOIN (od10
     WHERE od10.order_id=outerjoin(o.order_id)
      AND od10.oe_field_meaning=outerjoin("RATE")
      AND od10.action_sequence=outerjoin(1))
     JOIN (od11
     WHERE od11.order_id=outerjoin(o.order_id)
      AND od11.oe_field_meaning=outerjoin("RATEUNIT")
      AND od11.action_sequence=outerjoin(1))
     JOIN (od12
     WHERE od12.order_id=outerjoin(o.order_id)
      AND od12.oe_field_meaning=outerjoin("INFUSEOVER")
      AND od12.action_sequence=outerjoin(1))
     JOIN (od13
     WHERE od13.order_id=outerjoin(o.order_id)
      AND od13.oe_field_meaning=outerjoin("INFUSEOVERUNIT")
      AND od13.action_sequence=outerjoin(1))
     JOIN (od14
     WHERE od14.order_id=outerjoin(o.order_id)
      AND od14.oe_field_meaning=outerjoin("RXPRIORITY")
      AND od14.action_sequence=outerjoin(1))
    ORDER BY md.cki, o.order_id
    HEAD REPORT
     cnt = 0, assigned = 0, sentence_pos = 0,
     mmdc_begin_pos = 0, str_flag = 0, err_flag = 0
    HEAD md.cki
     mmdc_begin_pos = 0
    HEAD o.order_id
     cnt = (cnt+ 1), sentence_pos = 0, str_flag = 0,
     err_flag = 0, sentence_line = "Error"
     IF (od1.oe_field_value > 0
      AND od2.oe_field_value > 0
      AND od3.oe_field_value > 0
      AND od4.oe_field_value > 0)
      str_flag = 1, sentence_line = concat(build(num_to_str(od1.oe_field_value))," ",trim(
        strengthdoseunit)," / ",build(num_to_str(od3.oe_field_value)),
       " ",trim(volumedoseunit))
     ELSEIF (od1.oe_field_value > 0
      AND od2.oe_field_value > 0)
      str_flag = 1, sentence_line = concat(build(num_to_str(od1.oe_field_value))," ",trim(
        strengthdoseunit))
     ELSEIF (od3.oe_field_value > 0
      AND od4.oe_field_value > 0)
      sentence_line = concat(build(num_to_str(od3.oe_field_value))," ",trim(volumedoseunit))
     ELSE
      err_flag = 1
     ENDIF
     IF (od8.oe_field_value > 0)
      sentence_line = concat(sentence_line,", ",trim(frequency))
     ENDIF
     IF (od14.oe_field_value > 0)
      sentence_line = concat(sentence_line,", ",trim(rxpriority))
     ENDIF
     sentence_line = concat(sentence_line,", ",route)
     IF (prn=1)
      sentence_line = concat(sentence_line,", ","PRN")
     ENDIF
     IF (od7.oe_field_value > 0)
      sentence_line = concat(sentence_line,", ","reason: ",trim(prn_reason))
     ENDIF
     IF (od10.oe_field_value > 0
      AND o.iv_ind=1)
      sentence_line = concat(sentence_line,", ",cnvtstring(rate,11,3))
     ENDIF
     IF (od11.oe_field_value > 0
      AND o.iv_ind=1)
      sentence_line = concat(sentence_line," ",rateunit)
     ENDIF
     IF (trim(freetextrate) > " ")
      sentence_line = concat(sentence_line,", ",trim(freetextrate))
     ENDIF
     IF (od12.oe_field_value > 0
      AND ((o.iv_ind=0) OR (o.iv_ind=null)) )
      sentence_line = concat(sentence_line,", ",cnvtstring(infuseover,11,3))
     ENDIF
     IF (od13.oe_field_value > 0
      AND ((o.iv_ind=0) OR (o.iv_ind=null)) )
      sentence_line = concat(sentence_line," ",infuseoverunit)
     ENDIF
     IF (size(list->orders,5)=0
      AND err_flag=0)
      stat = alterlist(list->orders,1), list->orders[1].mmdc_cki = trim(md.cki), list->orders[1].
      order_sentence = sentence_line,
      list->orders[1].count = 1, assigned = (assigned+ 1), mmdc_begin_pos = 1
      IF (str_flag=1)
       list->orders[1].strengthdose = build(num_to_str(od1.oe_field_value)), list->orders[1].
       strengthdoseunit = strengthdoseunit
      ELSE
       list->orders[1].volumedose = build(num_to_str(od3.oe_field_value)), list->orders[1].
       volumedoseunit = volumedoseunit
      ENDIF
      list->orders[1].rxroute = route, list->orders[1].freq = frequency, list->orders[1].rxpriority
       = rxpriority,
      list->orders[1].schprn = trim(cnvtstring(prn,11,0)), list->orders[1].prnreason = prn_reason
      IF (rate > 0
       AND o.iv_ind=1)
       list->orders[1].rate = trim(cnvtstring(rate,11,3)), list->orders[1].rateunit = rateunit
      ENDIF
      list->orders[1].freetextrate = freetextrate
      IF (infuseover > 0
       AND ((o.iv_ind=null) OR (o.iv_ind=0)) )
       list->orders[1].infuseover = trim(cnvtstring(infuseover,11,3)), list->orders[1].infuseoverunit
        = infuseoverunit
      ENDIF
     ELSEIF (err_flag=0)
      sentence_pos = find_sentence_pos_mmdc(trim(md.cki),sentence_line)
      IF ((list->orders[sentence_pos].order_sentence=sentence_line)
       AND sentence_line != "Error"
       AND sentence_pos > 0)
       list->orders[sentence_pos].count = (list->orders[sentence_pos].count+ 1), assigned = (assigned
       + 1)
      ELSE
       stat = alterlist(list->orders,(size(list->orders,5)+ 1)), list->orders[size(list->orders,5)].
       mmdc_cki = trim(md.cki), list->orders[size(list->orders,5)].order_sentence = sentence_line,
       list->orders[size(list->orders,5)].count = 1, assigned = (assigned+ 1), mmdc_begin_pos = size(
        list->orders,5)
       IF (str_flag=1)
        list->orders[size(list->orders,5)].strengthdose = build(num_to_str(od1.oe_field_value)), list
        ->orders[size(list->orders,5)].strengthdoseunit = strengthdoseunit
       ELSE
        list->orders[size(list->orders,5)].volumedose = build(num_to_str(od3.oe_field_value)), list->
        orders[size(list->orders,5)].volumedoseunit = volumedoseunit
       ENDIF
       list->orders[size(list->orders,5)].rxroute = route, list->orders[size(list->orders,5)].freq =
       frequency, list->orders[size(list->orders,5)].rxpriority = rxpriority,
       list->orders[size(list->orders,5)].schprn = trim(cnvtstring(prn,11,0)), list->orders[size(list
        ->orders,5)].prnreason = prn_reason
       IF (rate > 0
        AND o.iv_ind=1)
        list->orders[size(list->orders,5)].rate = trim(cnvtstring(rate,11,3)), list->orders[size(list
         ->orders,5)].rateunit = rateunit
       ENDIF
       list->orders[size(list->orders,5)].freetextrate = freetextrate
       IF (infuseover > 0
        AND ((o.iv_ind=null) OR (o.iv_ind=0)) )
        list->orders[size(list->orders,5)].infuseover = trim(cnvtstring(infuseover,11,3)), list->
        orders[size(list->orders,5)].infuseoverunit = infuseoverunit
       ENDIF
      ENDIF
     ENDIF
    WITH nullreport
   ;end select
   SET cur_lookback_day = (cur_lookback_day - 1)
 ENDWHILE
 CALL text(8,1,"Creating output file... ")
 SELECT INTO "asc_mmdc_order_summary.csv"
  dnum = nmdc.drug_identifier, generic_name = dn1.drug_name, mmdc = substring(1,16,list->orders[d.seq
   ].mmdc_cki),
  description = dn2.drug_name, sentence = substring(1,100,list->orders[d.seq].order_sentence), count
   = cnvtstring(list->orders[d.seq].count,3,0)
  FROM (dummyt d  WITH seq = value(size(list->orders,5))),
   mltm_ndc_main_drug_code nmdc,
   mltm_mmdc_name_map mnm1,
   mltm_mmdc_name_map mnm2,
   mltm_drug_name dn1,
   mltm_drug_name dn2
  PLAN (d
   WHERE (list->orders[d.seq].count >= inc_min_ord_threshold))
   JOIN (nmdc
   WHERE nmdc.main_multum_drug_code=cnvtreal(trim(substring(12,18,list->orders[d.seq].mmdc_cki))))
   JOIN (mnm1
   WHERE nmdc.main_multum_drug_code=mnm1.main_multum_drug_code
    AND mnm1.function_id=16)
   JOIN (dn1
   WHERE mnm1.drug_synonym_id=dn1.drug_synonym_id)
   JOIN (mnm2
   WHERE nmdc.main_multum_drug_code=mnm2.main_multum_drug_code
    AND mnm2.function_id=59)
   JOIN (dn2
   WHERE mnm2.drug_synonym_id=dn2.drug_synonym_id)
  ORDER BY list->orders[d.seq].mmdc_cki, list->orders[d.seq].count DESC
  HEAD REPORT
   order_cnt = 0, col 0, "GENERIC,",
   "DNUM,", "MMDC,", "MMDC_DESC,",
   "COUNT,", "SCRIPT,", "STRENGTHDOSE,",
   "STRENGTHDOSEUNIT,", "VOLUMEDOSE,", "VOLUMEDOSEUNIT,",
   "FREQ,", "PRIORITY,", "RXROUTE,",
   "SCH/PRN,", "PRNREASON,", "SPECINX,",
   "RATE,", "RATEUNIT,", "FREETEXTRATE,",
   "INFUSEOVER,", "INFUSEOVERUNIT,", "DURATION,",
   "DURATIONUNIT"
  DETAIL
   order_cnt = (order_cnt+ 1), row + 1, out_line = concat('"',trim(dn1.drug_name),'"',",",'"',
    trim(nmdc.drug_identifier),'"',",",'"',trim(list->orders[d.seq].mmdc_cki),
    '"',",",'"',trim(dn2.drug_name),'"',
    ",",'"',trim(cnvtstring(list->orders[d.seq].count)),'"',",",
    '"',trim(list->orders[d.seq].order_sentence),'"',",",'"',
    trim(list->orders[d.seq].strengthdose),'"',",",'"',trim(list->orders[d.seq].strengthdoseunit),
    '"',",",'"',trim(list->orders[d.seq].volumedose),'"',
    ",",'"',trim(list->orders[d.seq].volumedoseunit),'"',",",
    '"',trim(list->orders[d.seq].freq),'"',",",'"',
    trim(list->orders[d.seq].rxpriority),'"',",",'"',trim(list->orders[d.seq].rxroute),
    '"',",",'"',trim(list->orders[d.seq].schprn),'"',
    ",",'"',trim(list->orders[d.seq].prnreason),'"',",",
    '"','"',",",'"',trim(list->orders[d.seq].rate),
    '"',",",'"',trim(list->orders[d.seq].rateunit),'"',
    ",",'"',trim(list->orders[d.seq].freetextrate),'"',",",
    '"',trim(list->orders[d.seq].infuseover),'"',",",'"',
    trim(list->orders[d.seq].infuseoverunit),'"',",",'"','"',
    ",",'"','"'),
   col 0, out_line
  FOOT REPORT
   CALL echo("."),
   CALL echo("------------------------------------------------"),
   CALL echo(build("Processing complete")),
   CALL echo(build("Results written to CCLUSERDIR file: asc_mmdc_order_summary.csv")),
   CALL echo(concat("Total unqiue orders meeting minimum threshold: ",build(order_cnt))),
   CALL echo("------------------------------------------------")
   IF (order_cnt > 65535)
    CALL echo(build("... WARNING!!! ...")),
    CALL echo(build("Results exceeded maximum Excel row count")),
    CALL echo(build("Recommend increasing minimum order threshold")),
    CALL echo("------------------------------------------------")
   ENDIF
  WITH check, maxcol = 1500, format = variable,
   nullreport, noformfeed, landscape,
   maxrow = 1
 ;end select
 GO TO pharm_extract_mode
#phasex_sent_by_mmdc_exit
#cpoe_ivset
 CALL clear_screen(0)
 CALL show_processing(0)
 DECLARE line = vc
 SELECT INTO "asc_cpoe_ivsets.csv"
  iv_set_name = substring(1,75,oc.primary_mnemonic), iv_set_synonym = substring(1,75,ocs2.mnemonic),
  iv_set_synonym_type = uar_get_code_display(ocs2.mnemonic_type_cd),
  component = substring(1,60,ocs.mnemonic), sentence = substring(1,100,os.order_sentence_display_line
   ), set_catalog_cd = oc.catalog_cd,
  component_synonym_id = ocs.synonym_id, component_catalog_cd = ocs.catalog_cd, os.order_sentence_id
  FROM order_catalog_synonym ocs,
   cs_component csp,
   order_catalog oc,
   order_catalog_synonym ocs2,
   ocs_facility_r ofr,
   order_sentence os
  PLAN (oc
   WHERE oc.active_ind=1
    AND oc.orderable_type_flag=8)
   JOIN (ocs2
   WHERE ocs2.catalog_cd=oc.catalog_cd
    AND ocs2.orderable_type_flag=8
    AND ((ocs2.hide_flag IS NOT null) OR (ocs2.hide_flag=0)) )
   JOIN (ofr
   WHERE ofr.synonym_id=ocs2.synonym_id
    AND ((ofr.facility_cd=0) OR (ofr.facility_cd=cur_facility_cd)) )
   JOIN (csp
   WHERE oc.catalog_cd=csp.catalog_cd
    AND csp.comp_id != 0)
   JOIN (ocs
   WHERE ocs.synonym_id=csp.comp_id)
   JOIN (os
   WHERE outerjoin(csp.order_sentence_id)=os.order_sentence_id)
  ORDER BY cnvtupper(oc.primary_mnemonic), ocs2.mnemonic_key_cap, ocs.mnemonic_key_cap,
   os.order_sentence_display_line
  HEAD REPORT
   col 0, "IV_SET_NAME,", "IV_SET_SYNONYM,",
   "IV_SET_SYNONYM_TYPE,", "COMPONENT,", "SENTENCE,",
   "SET_CATALOG_CD,", "COMPONENT_SYNONYM_ID,", "COMPONENT_CATALOG_CD,",
   "ORDER_SENTENCE_ID"
  HEAD csp.comp_id
   line = concat('"',trim(oc.primary_mnemonic),'"',",",'"',
    trim(ocs2.mnemonic),'"',",",'"',trim(iv_set_synonym_type),
    '"',",",'"',trim(ocs.mnemonic),'"',
    ",",'"',trim(os.order_sentence_display_line),'"',",",
    '"',trim(cnvtstring(set_catalog_cd)),'"',",",'"',
    trim(cnvtstring(component_synonym_id)),'"',",",'"',trim(cnvtstring(component_catalog_cd)),
    '"',",",'"',trim(cnvtstring(os.order_sentence_id)),'"')
  FOOT  csp.comp_id
   row + 1, col 0, line
  WITH check, maxcol = 2000, format = variable,
   nullreport, noformfeed, landscape,
   maxrow = 1
 ;end select
 GO TO pharm_extract_mode
#cpoe_ivset_exit
#cpoe_ivset_scr
 CALL clear_screen(0)
 CALL show_processing(0)
 SET cprimary = uar_get_code_by("MEANING",6011,"PRIMARY")
 SELECT
  iv_set_name = substring(1,75,oc.primary_mnemonic), iv_set_synonym = substring(1,75,ocs2.mnemonic),
  iv_set_synonym_type = uar_get_code_display(ocs2.mnemonic_type_cd),
  component = substring(1,60,ocs.mnemonic), sentence = substring(1,100,os.order_sentence_display_line
   ), set_catalog_cd = oc.catalog_cd,
  component_synonym_id = ocs.synonym_id, component_catalog_cd = ocs.catalog_cd, os.order_sentence_id
  FROM order_catalog_synonym ocs,
   cs_component csp,
   order_catalog oc,
   order_catalog_synonym ocs2,
   ocs_facility_r ofr,
   order_sentence os
  PLAN (oc
   WHERE oc.active_ind=1
    AND oc.orderable_type_flag=8)
   JOIN (ocs2
   WHERE ocs2.catalog_cd=oc.catalog_cd
    AND ocs2.orderable_type_flag=8
    AND ((ocs2.hide_flag IS NOT null) OR (ocs2.hide_flag=0)) )
   JOIN (ofr
   WHERE ofr.synonym_id=ocs2.synonym_id
    AND ((ofr.facility_cd=0) OR (ofr.facility_cd=cur_facility_cd)) )
   JOIN (csp
   WHERE oc.catalog_cd=csp.catalog_cd
    AND csp.comp_id != 0)
   JOIN (ocs
   WHERE ocs.synonym_id=csp.comp_id)
   JOIN (os
   WHERE outerjoin(csp.order_sentence_id)=os.order_sentence_id)
  ORDER BY cnvtupper(oc.primary_mnemonic), ocs2.mnemonic_key_cap, ocs.mnemonic_key_cap,
   os.order_sentence_display_line
  WITH format = pcformat
 ;end select
 GO TO pharm_extract_mode
#cpoe_ivset_scr_exit
#careset_extract
 CALL show_processing(0)
 SET cpharm = uar_get_code_by("MEANING",6000,"PHARMACY")
 FREE RECORD mylist2
 RECORD mylist2(
   1 vv[*]
     2 syn_id = f8
     2 vv_ind = c1
 )
 CALL load_current_vv(0)
 SELECT
  careset = substring(1,75,oc.primary_mnemonic), careset_synonym = substring(1,75,ocs2.mnemonic),
  component = substring(1,75,ocs.mnemonic),
  virtual_view = mylist2->vv[d2.seq].vv_ind, sentence = substring(1,100,os
   .order_sentence_display_line), careset_catalog_cd = oc.catalog_cd,
  careset_synonym_id = ocs.synonym_id, component_synonym_id = ocs.synonym_id, component_catalog_cd =
  ocs.catalog_cd,
  os.order_sentence_id
  FROM order_catalog_synonym ocs,
   cs_component csp,
   order_catalog oc,
   order_sentence os,
   order_catalog_synonym ocs2,
   ocs_facility_r ofr,
   dummyt d1,
   (dummyt d2  WITH seq = value(size(mylist2->vv,5)))
  PLAN (oc
   WHERE oc.active_ind=1
    AND oc.orderable_type_flag=6)
   JOIN (ocs2
   WHERE ocs2.catalog_cd=oc.catalog_cd
    AND ocs2.active_ind=1
    AND ((ocs2.hide_flag=0) OR (ocs2.hide_flag=null)) )
   JOIN (ofr
   WHERE ofr.synonym_id=ocs2.synonym_id
    AND ((ofr.facility_cd=0) OR (ofr.facility_cd=cur_facility_cd)) )
   JOIN (csp
   WHERE oc.catalog_cd=csp.catalog_cd
    AND csp.comp_id != 0)
   JOIN (ocs
   WHERE ocs.synonym_id=csp.comp_id
    AND ocs.catalog_type_cd=cpharm)
   JOIN (os
   WHERE outerjoin(csp.order_sentence_id)=os.order_sentence_id)
   JOIN (d1)
   JOIN (d2
   WHERE (ocs.synonym_id=mylist2->vv[d2.seq].syn_id))
  ORDER BY cnvtupper(oc.primary_mnemonic), ocs2.mnemonic_key_cap, ocs.mnemonic,
   os.order_sentence_display_line
  WITH outerjoin = d1, format = pcformat
 ;end select
 GO TO cs_pp_extract_mode
#careset_extract_exit
#powerplan_extract
 CALL show_processing(0)
 SET cpharm = uar_get_code_by("MEANING",6000,"PHARMACY")
 SET corder = uar_get_code_by("MEANING",6003,"ORDER")
 FREE RECORD mylist2
 RECORD mylist2(
   1 vv[*]
     2 syn_id = f8
     2 vv_ind = c1
 )
 CALL load_current_vv(0)
 SELECT
  powerplan_name = pcat.description, clinical_category = uar_get_code_display(pc.dcp_clin_cat_cd),
  clinical_sub_category = uar_get_code_display(pc.dcp_clin_sub_cat_cd),
  synonym = ocs.mnemonic, synonym_type = uar_get_code_display(ocs.mnemonic_type_cd), virtual_view =
  mylist2->vv[d3.seq].vv_ind,
  include_exclude = pc.include_ind, order_sentence_display_line = os.order_sentence_display_line,
  order_comment = substring(1,500,lt.long_text),
  pc.pathway_comp_id, component_synonym_id = ocs.synonym_id, component_catalog_cd = ocs.catalog_cd,
  os.order_sentence_id
  FROM order_catalog_synonym ocs,
   pw_comp_os_reltn pcor,
   pathway_comp pc,
   pw_cat_flex pcf,
   pathway_catalog pcat,
   order_sentence os,
   long_text lt,
   dummyt d,
   dummyt d1,
   dummyt d2,
   (dummyt d3  WITH seq = value(size(mylist2->vv,5)))
  PLAN (pc
   WHERE pc.active_ind=1)
   JOIN (pcat
   WHERE pcat.pathway_catalog_id=pc.pathway_catalog_id
    AND pcat.active_ind=1
    AND pcat.pathway_catalog_id > 0)
   JOIN (pcf
   WHERE pcf.pathway_catalog_id=pc.pathway_catalog_id
    AND ((pcf.parent_entity_id=0) OR (pcf.parent_entity_id=cur_facility_cd)) )
   JOIN (ocs
   WHERE ocs.synonym_id=pc.parent_entity_id
    AND ocs.catalog_type_cd=cpharm)
   JOIN (d1)
   JOIN (d3
   WHERE (ocs.synonym_id=mylist2->vv[d3.seq].syn_id))
   JOIN (d)
   JOIN (pcor
   WHERE pcor.pathway_comp_id=pc.pathway_comp_id)
   JOIN (os
   WHERE os.order_sentence_id=pcor.order_sentence_id)
   JOIN (d2)
   JOIN (lt
   WHERE lt.long_text_id=os.ord_comment_long_text_id)
  ORDER BY powerplan_name, clinical_category, clinical_sub_category,
   synonym
  WITH outerjoin = d, outerjoin = d1, outerjoin = d2,
   nullreport, format = pcformat
 ;end select
 GO TO cs_pp_extract_mode
#powerplan_extract_exit
#ord_sum_by_mmdc
 CALL clear_screen(0)
 CALL text(4,1,"How many days back do you wish to examine orders? ")
 CALL accept(4,52,"P(3);CU","30"
  WHERE cnvtreal(curaccept) > 0)
 SET lookback_days = cnvtreal(curaccept)
 CALL text(5,1,"Enter first search character(s) of MMDC to lookup:  ")
 CALL accept(5,52,"P(30);CU","")
 SET mmdc_loc_string = trim(cnvtupper(curaccept))
 FREE RECORD oc
 RECORD oc(
   1 qual[*]
     2 mmdc = f8
     2 desc = vc
 )
 SET ocknt = 0
 SELECT DISTINCT INTO "nl:"
  mmdc = nmdc.main_multum_drug_code, description = dn2.drug_name
  FROM medication_definition md,
   item_definition id,
   med_def_flex mdf2,
   med_flex_object_idx mfoi2,
   mltm_ndc_main_drug_code nmdc,
   mltm_mmdc_name_map mnm,
   mltm_mmdc_name_map mnm2,
   mltm_drug_name dn1,
   mltm_drug_name dn2
  PLAN (md
   WHERE trim(md.cki) > " ")
   JOIN (id
   WHERE id.item_id=md.item_id
    AND id.active_ind=1)
   JOIN (mdf2
   WHERE mdf2.item_id=md.item_id
    AND mdf2.flex_type_cd=csyspkgtyp
    AND mdf2.pharmacy_type_cd=cinpatient)
   JOIN (mfoi2
   WHERE mfoi2.med_def_flex_id=mdf2.med_def_flex_id
    AND mfoi2.flex_object_type_cd=corderable
    AND ((mfoi2.parent_entity_id=0) OR (mfoi2.parent_entity_id=cur_facility_cd)) )
   JOIN (nmdc
   WHERE nmdc.main_multum_drug_code=cnvtreal(substring(12,5,md.cki)))
   JOIN (mnm
   WHERE nmdc.main_multum_drug_code=mnm.main_multum_drug_code
    AND mnm.function_id=16)
   JOIN (dn1
   WHERE mnm.drug_synonym_id=dn1.drug_synonym_id)
   JOIN (mnm2
   WHERE nmdc.main_multum_drug_code=mnm2.main_multum_drug_code
    AND mnm2.function_id=59)
   JOIN (dn2
   WHERE mnm2.drug_synonym_id=dn2.drug_synonym_id
    AND cnvtupper(dn2.drug_name)=patstring(build(mmdc_loc_string,"*")))
  ORDER BY cnvtupper(dn2.drug_name)
  HEAD REPORT
   ocknt = 0
  DETAIL
   ocknt = (ocknt+ 1)
   IF (mod(ocknt,10)=1)
    stat = alterlist(oc->qual,(ocknt+ 9))
   ENDIF
   oc->qual[ocknt].mmdc = nmdc.main_multum_drug_code, oc->qual[ocknt].desc = substring(1,85,dn2
    .drug_name)
  FOOT REPORT
   stat = alterlist(oc->qual,ocknt)
  WITH nocounter
 ;end select
 CALL clear_screen(0)
 CALL text(3,2,"Search: ")
 CALL text(3,10,mmdc_loc_string)
 CALL text(5,67,"Total:  ")
 CALL text(5,75,cnvtstring(ocknt,4))
 CALL create_std_box(ocknt)
 CALL text(6,8,"MMDC ")
 WHILE (cnt <= numsrow
  AND cnt <= maxcnt)
   SET holdstr_desc = oc->qual[cnt].desc
   SET holdstr_mmdc = cnvtstring(oc->qual[cnt].mmdc,5,0)
   SET holdstr = concat(cnvtstring(cnt,4,0,r),"  ",holdstr_desc)
   CALL scrolltext(cnt,holdstr)
   SET cnt = (cnt+ 1)
 ENDWHILE
 SET cnt = 1
 SET arow = 1
 CALL text(23,1,"Select MMDC for order lookup        (enter 000 to go back)")
 SET pick = 0
 WHILE (pick=0)
  CALL accept(23,30,"9999;S",cnt)
  CASE (curscroll)
   OF 0:
    IF (curaccept=0)
     CALL clear_screen(0)
     GO TO pharm_data_lookup_mode
    ELSEIF (cnvtint(curaccept) BETWEEN 1 AND maxcnt)
     SET pick = cnvtint(curaccept)
     CALL clear_screen(0)
     CALL lookup_ord_by_mmdc(oc->qual[pick].mmdc,lookback_days)
    ELSE
     CALL clear_screen(0)
     GO TO exit_program
    ENDIF
   OF 1:
    IF (cnt < maxcnt)
     SET cnt = (cnt+ 1)
     SET holdstr_desc = oc->qual[cnt].desc
     SET holdstr_mmdc = cnvtstring(oc->qual[cnt].mmdc,5,0)
     SET holdstr = concat(cnvtstring(cnt,4,0,r),"  ",holdstr_desc)
     CALL down_arrow(holdstr)
    ENDIF
   OF 2:
    IF (cnt > 1)
     SET cnt = (cnt - 1)
     SET holdstr_desc = oc->qual[cnt].desc
     SET holdstr_mmdc = cnvtstring(oc->qual[cnt].mmdc,5,0)
     SET holdstr = concat(cnvtstring(cnt,4,0,r),"  ",holdstr_desc)
     CALL up_arrow(holdstr)
    ENDIF
   OF 3:
   OF 4:
   OF 6:
    IF (numsrow < maxcnt)
     SET cnt = ((cnt+ numsrow) - 1)
     IF (((cnt+ numsrow) > maxcnt))
      SET cnt = (maxcnt - numsrow)
     ENDIF
     SET arow = 1
     WHILE (arow <= numsrow)
       SET cnt = (cnt+ 1)
       SET holdstr_desc = oc->qual[cnt].desc
       SET holdstr_mmdc = cnvtstring(oc->qual[cnt].mmdc,5,0)
       SET holdstr = concat(cnvtstring(cnt,4,0,r),"  ",holdstr_desc)
       CALL scrolltext(arow,holdstr)
       SET arow = (arow+ 1)
     ENDWHILE
     SET arow = 1
     SET cnt = ((cnt - numsrow)+ 1)
    ENDIF
   OF 5:
    IF (((cnt - numsrow) > 0))
     SET cnt = (cnt - numsrow)
    ELSE
     SET cnt = 1
    ENDIF
    SET tmp1 = cnt
    SET arow = 1
    WHILE (arow <= numsrow
     AND cnt < maxcnt)
      SET holdstr_desc = oc->qual[cnt].desc
      SET holdstr_mmdc = cnvtstring(oc->qual[cnt].mmdc,5,0)
      SET holdstr = concat(cnvtstring(cnt,4,0,r),"  ",holdstr_desc)
      CALL scrolltext(arow,holdstr)
      SET cnt = (cnt+ 1)
      SET arow = (arow+ 1)
    ENDWHILE
    SET cnt = tmp1
    SET arow = 1
  ENDCASE
 ENDWHILE
 GO TO pharm_data_lookup_mode
#ord_sum_by_mmdc_exit
#med_charting_elem
 SELECT
  medication = substring(1,60,ot.task_description), addtl_charting = uar_get_code_display(tdr
   .task_assay_cd), tdr.required_ind
  FROM task_discrete_r tdr,
   order_task ot
  PLAN (tdr)
   JOIN (ot
   WHERE ot.reference_task_id=tdr.reference_task_id
    AND ot.task_type_cd IN (
   (SELECT
    code_value
    FROM code_value
    WHERE code_set=6026
     AND active_ind=1
     AND cdf_meaning="MED"))
    AND ot.active_ind=1)
  ORDER BY medication, tdr.sequence
  WITH format = pcformat
 ;end select
 GO TO care_utilities_mode
#med_charting_elem_exit
#med_prn_resp
 SELECT
  medication = substring(1,60,ot.task_description), prn_response_route = uar_get_code_display(otr
   .route_cd), prn_response_minutes = otr.response_minutes
  FROM order_task ot,
   order_task_response otr
  PLAN (ot
   WHERE ot.task_type_cd IN (
   (SELECT
    code_value
    FROM code_value
    WHERE code_set=6026
     AND active_ind=1
     AND cdf_meaning="MED"))
    AND ot.active_ind=1)
   JOIN (otr
   WHERE otr.reference_task_id=ot.reference_task_id)
  ORDER BY medication, otr.route_cd
  WITH format = pcformat
 ;end select
 GO TO care_utilities_mode
#med_prn_resp_exit
#prefmaint_lookup
 CALL clear_screen(0)
 CALL text(5,1,"Enter PVC name for preference to lookup:   ")
 CALL accept(5,45,"P(30);CU","")
 CALL show_processing(0)
 SELECT
  application = substring(1,35,a.description), position = substring(1,35,cv.display), person =
  substring(1,20,pr.name_full_formatted),
  pref_value = substring(1,30,nvp.pvc_value), last_update = format(nvp.updt_dt_tm,"@SHORTDATETIME"),
  last_updater = substring(1,50,p.name_full_formatted)
  FROM name_value_prefs nvp,
   app_prefs ap,
   application a,
   prsnl pr,
   code_value cv,
   person p
  WHERE cnvtupper(nvp.pvc_name)=trim(cnvtupper(curaccept))
   AND outerjoin(nvp.parent_entity_id)=ap.app_prefs_id
   AND outerjoin(ap.application_number)=a.application_number
   AND outerjoin(ap.prsnl_id)=pr.person_id
   AND outerjoin(ap.position_cd)=cv.code_value
   AND nvp.updt_id=p.person_id
  ORDER BY application, position, person
 ;end select
 GO TO common_utilities_mode
#prefmaint_lookup_exit
#careset_med_noprod
 CALL show_processing(0)
 SET cpharm = uar_get_code_by("MEANING",6000,"PHARMACY")
 SET cprimary = uar_get_code_by("MEANING",6011,"PRIMARY")
 SET csystem = uar_get_code_by("MEANING",4062,"SYSTEM")
 SET csyspkgtyp = uar_get_code_by("MEANING",4062,"SYSPKGTYP")
 SET corderable = uar_get_code_by("MEANING",4063,"ORDERABLE")
 SET cinpatient = uar_get_code_by("MEANING",4500,"INPATIENT")
 SET cdesc = uar_get_code_by("MEANING",11000,"DESC")
 FREE RECORD available_products
 RECORD available_products(
   1 products[*]
     2 item_id = f8
     2 catalog_cd = f8
 )
 SELECT INTO "nl:"
  md.item_id, product_desc = substring(1,50,mi.value), mfoi.*
  FROM medication_definition md,
   order_catalog_item_r ocir,
   item_definition id,
   med_def_flex mdf,
   med_flex_object_idx mfoi,
   med_identifier mi
  PLAN (md)
   JOIN (ocir
   WHERE ocir.item_id=md.item_id)
   JOIN (id
   WHERE id.item_id=ocir.item_id
    AND id.active_ind=1)
   JOIN (mdf
   WHERE mdf.item_id=md.item_id
    AND mdf.flex_type_cd=csyspkgtyp
    AND mdf.pharmacy_type_cd=cinpatient)
   JOIN (mfoi
   WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
    AND mfoi.flex_object_type_cd=corderable
    AND ((mfoi.parent_entity_id=0) OR (mfoi.parent_entity_id=cur_facility_cd)) )
   JOIN (mi
   WHERE mi.item_id=md.item_id
    AND mi.active_ind=1
    AND mi.primary_ind=1
    AND mi.med_product_id=0
    AND mi.med_identifier_type_cd=cdesc
    AND mi.pharmacy_type_cd=cinpatient)
  ORDER BY mi.value
  HEAD REPORT
   cnt = 0
  HEAD md.item_id
   cnt = (cnt+ 1), stat = alterlist(available_products->products,cnt), available_products->products[
   cnt].item_id = md.item_id,
   available_products->products[cnt].catalog_cd = ocir.catalog_cd
  WITH nullreport
 ;end select
 SELECT
  careset = substring(1,75,oc.primary_mnemonic), careset_synonym = substring(1,75,ocs2.mnemonic),
  component = ocs.mnemonic,
  synonym_type = uar_get_code_display(ocs.mnemonic_type_cd), sentence = substring(1,75,os
   .order_sentence_display_line), careset_catalog_cd = oc.catalog_cd,
  careset_synonym_id = ocs2.synonym_id, component_catalog_id = ocs.catalog_cd, component_synonym_id
   = ocs.synonym_id,
  os.order_sentence_id
  FROM order_catalog_synonym ocs,
   order_catalog_synonym ocs2,
   ocs_facility_r ofr,
   dummyt d1,
   (dummyt d2  WITH seq = value(size(available_products->products,5))),
   cs_component csp,
   order_catalog oc,
   order_sentence os
  PLAN (oc
   WHERE oc.active_ind=1
    AND oc.orderable_type_flag=6)
   JOIN (ocs2
   WHERE ocs2.catalog_cd=oc.catalog_cd
    AND ocs2.active_ind=1
    AND ((ocs2.hide_flag=0) OR (ocs2.hide_flag=null)) )
   JOIN (ofr
   WHERE ofr.synonym_id=ocs2.synonym_id
    AND ((ofr.facility_cd=0) OR (ofr.facility_cd=cur_facility_cd)) )
   JOIN (csp
   WHERE oc.catalog_cd=csp.catalog_cd
    AND csp.comp_id != 0)
   JOIN (ocs
   WHERE ocs.synonym_id=csp.comp_id
    AND ocs.catalog_type_cd=cpharm)
   JOIN (os
   WHERE outerjoin(csp.order_sentence_id)=os.order_sentence_id)
   JOIN (d1)
   JOIN (d2
   WHERE (ocs.catalog_cd=available_products->products[d2.seq].catalog_cd))
  ORDER BY cnvtupper(oc.primary_mnemonic), ocs2.mnemonic_key_cap, cnvtupper(ocs.mnemonic),
   cnvtupper(os.order_sentence_display_line)
  WITH outerjoin = d1, dontexist, format = pcformat
 ;end select
 GO TO cs_pp_problem_mode
#careset_med_noprod_exit
#careset_med_vvoff
 CALL show_processing(0)
 SELECT
  careset = substring(1,75,oc.primary_mnemonic), careset_synonym = substring(1,75,ocs2.mnemonic),
  component = ocs.mnemonic,
  synonym_type = uar_get_code_display(ocs.mnemonic_type_cd), sentence = substring(1,75,os
   .order_sentence_display_line), careset_catalog_cd = oc.catalog_cd,
  careset_synonym_id = ocs2.synonym_id, component_catalog_id = ocs.catalog_cd, component_synonym_id
   = ocs.synonym_id,
  os.order_sentence_id
  FROM order_catalog_synonym ocs,
   order_catalog_synonym ocs2,
   ocs_facility_r ofr,
   dummyt d1,
   ocs_facility_r ofr2,
   cs_component csp,
   order_catalog oc,
   order_sentence os
  PLAN (oc
   WHERE oc.active_ind=1
    AND oc.orderable_type_flag=6)
   JOIN (ocs2
   WHERE ocs2.catalog_cd=oc.catalog_cd
    AND ocs2.active_ind=1
    AND ((ocs2.hide_flag=0) OR (ocs2.hide_flag=null)) )
   JOIN (ofr
   WHERE ofr.synonym_id=ocs2.synonym_id
    AND ((ofr.facility_cd=0) OR (ofr.facility_cd=cur_facility_cd)) )
   JOIN (csp
   WHERE oc.catalog_cd=csp.catalog_cd
    AND csp.comp_id != 0)
   JOIN (ocs
   WHERE ocs.synonym_id=csp.comp_id
    AND ocs.catalog_type_cd=cpharm)
   JOIN (os
   WHERE outerjoin(csp.order_sentence_id)=os.order_sentence_id)
   JOIN (d1)
   JOIN (ofr2
   WHERE ofr2.synonym_id=ocs.synonym_id
    AND ((ofr2.facility_cd=0) OR (ofr2.facility_cd=cur_facility_cd)) )
  ORDER BY cnvtupper(oc.primary_mnemonic), ocs2.mnemonic_key_cap, cnvtupper(ocs.mnemonic),
   cnvtupper(os.order_sentence_display_line)
  WITH outerjoin = d1, dontexist, format = pcformat
 ;end select
 GO TO cs_pp_problem_mode
#careset_med_vvoff_exit
#careset_med_noncpoe
 CALL show_processing(0)
 SELECT
  careset = substring(1,75,oc.primary_mnemonic), careset_synonym = substring(1,75,ocs2.mnemonic),
  component = ocs.mnemonic,
  synonym_type = uar_get_code_display(ocs.mnemonic_type_cd), sentence = substring(1,75,os
   .order_sentence_display_line), careset_catalog_cd = oc.catalog_cd,
  careset_synonym_id = ocs2.synonym_id, component_catalog_id = ocs.catalog_cd, component_synonym_id
   = ocs.synonym_id,
  os.order_sentence_id
  FROM order_catalog_synonym ocs,
   order_catalog_synonym ocs2,
   ocs_facility_r ofr,
   cs_component csp,
   order_catalog oc,
   order_sentence os
  PLAN (oc
   WHERE oc.active_ind=1
    AND oc.orderable_type_flag=6)
   JOIN (ocs2
   WHERE ocs2.catalog_cd=oc.catalog_cd
    AND ocs2.active_ind=1
    AND ((ocs2.hide_flag=0) OR (ocs2.hide_flag=null)) )
   JOIN (ofr
   WHERE ofr.synonym_id=ocs2.synonym_id
    AND ((ofr.facility_cd=0) OR (ofr.facility_cd=cur_facility_cd)) )
   JOIN (csp
   WHERE oc.catalog_cd=csp.catalog_cd
    AND csp.comp_id != 0)
   JOIN (ocs
   WHERE ocs.synonym_id=csp.comp_id
    AND ocs.catalog_type_cd=cpharm
    AND  NOT (ocs.mnemonic_type_cd IN (
   (SELECT
    code_value
    FROM code_value
    WHERE code_set=6011
     AND cdf_meaning IN ("BRANDNAME", "DCP", "DISPDRUG", "GENERICTOP", "IVNAME",
    "PRIMARY", "TRADETOP")))))
   JOIN (os
   WHERE outerjoin(csp.order_sentence_id)=os.order_sentence_id)
  ORDER BY cnvtupper(oc.primary_mnemonic), ocs2.mnemonic_key_cap, cnvtupper(ocs.mnemonic),
   cnvtupper(os.order_sentence_display_line)
  WITH format = pcformat
 ;end select
 GO TO cs_pp_problem_mode
#careset_med_noncpoe_exit
#syn_no_cki
 CALL show_processing(0)
 SET corder = uar_get_code_by("MEANING",6003,"ORDER")
 SET cpharm = uar_get_code_by("MEANING",6000,"PHARMACY")
 SELECT
  synonym_id = ocs.synonym_id, orderable = substring(1,60,oc.primary_mnemonic), synonym = substring(1,
   60,ocs.mnemonic),
  mnemonic_type = cv.display, ocs_cki = substring(1,20,ocs.cki), ocs.rx_mask,
  oef = substring(1,30,oef.oe_format_name)
  FROM order_catalog_synonym ocs,
   ocs_facility_r ofr,
   order_catalog oc,
   code_value cv,
   order_entry_format oef
  PLAN (ocs
   WHERE ocs.mnemonic_type_cd IN (
   (SELECT
    code_value
    FROM code_value
    WHERE code_set=6011
     AND cdf_meaning IN ("BRANDNAME", "DCP", "DISPDRUG", "GENERICTOP", "IVNAME",
    "PRIMARY", "TRADETOP")))
    AND ocs.catalog_type_cd=cpharm
    AND ocs.active_ind=1
    AND ((ocs.hide_flag=0) OR (ocs.hide_flag=null))
    AND ((ocs.cki=null) OR (ocs.cki <= " ")) )
   JOIN (ofr
   WHERE ofr.synonym_id=ocs.synonym_id
    AND ((ofr.facility_cd=0) OR (ofr.facility_cd=cur_facility_cd)) )
   JOIN (oc
   WHERE oc.active_ind=1
    AND oc.catalog_cd=ocs.catalog_cd
    AND oc.orderable_type_flag IN (0, 1)
    AND  NOT (((oc.cki=null) OR (oc.cki <= " ")) ))
   JOIN (cv
   WHERE cv.code_value=ocs.mnemonic_type_cd)
   JOIN (oef
   WHERE ocs.oe_format_id=oef.oe_format_id
    AND oef.action_type_cd=corder)
  ORDER BY cnvtupper(ocs.mnemonic)
  WITH format = pcformat
 ;end select
 GO TO pharm_problem_mode
#syn_no_cki_exit
#asc_fix_mul_sent
 CALL show_processing(0)
 UPDATE  FROM order_catalog_synonym
  SET multiple_ord_sent_ind = 1, order_sentence_id = 0, updt_task = - (2516)
  WHERE catalog_type_cd IN (
  (SELECT
   code_value
   FROM code_value
   WHERE code_set=6000
    AND active_ind=1
    AND cdf_meaning="PHARMACY"))
   AND ((multiple_ord_sent_ind=0) OR (multiple_ord_sent_ind=null))
   AND  NOT (order_sentence_id IN (
  (SELECT DISTINCT
   order_sentence_id
   FROM order_sentence)))
 ;end update
 CALL clear_screen(0)
 CALL text(5,5,"Orphaned rows corrected:")
 CALL text(5,30,trim(cnvtstring(curqual)))
 CALL text(7,5,"Commit (Y/N)?")
 CALL accept(7,19,"C;CU","Y"
  WHERE curaccept IN ("Y", "N"))
 CASE (curaccept)
  OF "Y":
   COMMIT
  OF "N":
   ROLLBACK
 ENDCASE
 CALL clear_screen(0)
 GO TO pharm_utilities_mode
#asc_fix_mul_sent_exit
#remap_syn_sent
 CALL clear_screen(0)
 FREE RECORD syn
 RECORD syn(
   1 qual[*]
     2 synonym_id = f8
     2 synonym_desc = vc
     2 active = c1
     2 ref = c1
 )
 SET ocknt = 0
 CALL text(5,1,"Enter first character(s) of synonym to remap:   ")
 CALL accept(5,52,"P(30);CU","")
 SET syn_loc_string = trim(cnvtupper(curaccept))
 SELECT INTO "nl:"
  ocs.synonym_id, ocs.mnemonic, ocs.active_ind,
  ocs.cki
  FROM order_catalog_synonym ocs
  PLAN (ocs
   WHERE ocs.catalog_type_cd IN (
   (SELECT
    code_value
    FROM code_value
    WHERE code_set=6000
     AND cdf_meaning="PHARMACY"
     AND active_ind=1))
    AND ocs.mnemonic_type_cd IN (
   (SELECT
    code_value
    FROM code_value
    WHERE code_set=6011
     AND cdf_meaning != "PRIMARY"))
    AND cnvtupper(ocs.mnemonic)=patstring(build(syn_loc_string,"*")))
  ORDER BY cnvtupper(ocs.mnemonic)
  HEAD REPORT
   ocknt = 0
  DETAIL
   ocknt = (ocknt+ 1)
   IF (mod(ocknt,10)=1)
    stat = alterlist(syn->qual,(ocknt+ 9))
   ENDIF
   syn->qual[ocknt].synonym_id = ocs.synonym_id, syn->qual[ocknt].synonym_desc = substring(1,65,ocs
    .mnemonic), syn->qual[ocknt].ref = "1",
   syn->qual[ocknt].active = "1"
   IF (textlen(trim(ocs.cki))=0)
    syn->qual[ocknt].ref = "0"
   ENDIF
   IF (ocs.active_ind=0)
    syn->qual[ocknt].active = "0"
   ENDIF
  FOOT REPORT
   stat = alterlist(syn->qual,ocknt)
  WITH nocounter
 ;end select
 CALL clear_screen(0)
 CALL text(3,2,"Search: ")
 CALL text(3,10,syn_loc_string)
 CALL text(5,67,"Total:  ")
 CALL text(5,75,cnvtstring(ocknt,4))
 CALL create_std_box(ocknt)
 CALL text(6,8,"Synonym ")
 CALL text(6,75,"A|R")
 WHILE (cnt <= numsrow
  AND cnt <= maxcnt)
   SET holdstr65 = syn->qual[cnt].synonym_desc
   SET holdstr_r = syn->qual[cnt].ref
   SET holdstr_a = syn->qual[cnt].active
   SET holdstr = concat(cnvtstring(cnt,4,0,r),"  ",holdstr65," ",holdstr_a,
    "|",holdstr_r)
   CALL scrolltext(cnt,holdstr)
   SET cnt = (cnt+ 1)
 ENDWHILE
 SET cnt = 1
 SET arow = 1
 CALL text(23,1,"Select synonym for remapping        (enter 000 to go back)")
 SET pick = 0
 WHILE (pick=0)
  CALL accept(23,30,"9999;S",cnt)
  CASE (curscroll)
   OF 0:
    IF (curaccept=0)
     CALL clear_screen(0)
     GO TO pharm_utilities_mode
    ELSEIF (cnvtint(curaccept) BETWEEN 1 AND maxcnt)
     SET pick = cnvtint(curaccept)
     CALL clear_screen(0)
     CALL remap_syn_sent(syn->qual[pick].synonym_id,syn->qual[pick].synonym_desc)
    ELSE
     CALL clear_screen(0)
     GO TO exit_program
    ENDIF
   OF 1:
    IF (cnt < maxcnt)
     SET cnt = (cnt+ 1)
     SET holdstr65 = syn->qual[cnt].synonym_desc
     SET holdstr_r = syn->qual[cnt].ref
     SET holdstr_a = syn->qual[cnt].active
     SET holdstr = concat(cnvtstring(cnt,4,0,r),"  ",holdstr65," ",holdstr_a,
      "|",holdstr_r)
     CALL down_arrow(holdstr)
    ENDIF
   OF 2:
    IF (cnt > 1)
     SET cnt = (cnt - 1)
     SET holdstr65 = syn->qual[cnt].synonym_desc
     SET holdstr_r = syn->qual[cnt].ref
     SET holdstr_a = syn->qual[cnt].active
     SET holdstr = concat(cnvtstring(cnt,4,0,r),"  ",holdstr65," ",holdstr_a,
      "|",holdstr_r)
     CALL up_arrow(holdstr)
    ENDIF
   OF 3:
   OF 4:
   OF 6:
    IF (numsrow < maxcnt)
     SET cnt = ((cnt+ numsrow) - 1)
     IF (((cnt+ numsrow) > maxcnt))
      SET cnt = (maxcnt - numsrow)
     ENDIF
     SET arow = 1
     WHILE (arow <= numsrow)
       SET cnt = (cnt+ 1)
       SET holdstr65 = syn->qual[cnt].synonym_desc
       SET holdstr_r = syn->qual[cnt].ref
       SET holdstr_a = syn->qual[cnt].active
       SET holdstr = concat(cnvtstring(cnt,4,0,r),"  ",holdstr65," ",holdstr_a,
        "|",holdstr_r)
       CALL scrolltext(arow,holdstr)
       SET arow = (arow+ 1)
     ENDWHILE
     SET arow = 1
     SET cnt = ((cnt - numsrow)+ 1)
    ENDIF
   OF 5:
    IF (((cnt - numsrow) > 0))
     SET cnt = (cnt - numsrow)
    ELSE
     SET cnt = 1
    ENDIF
    SET tmp1 = cnt
    SET arow = 1
    WHILE (arow <= numsrow
     AND cnt < maxcnt)
      SET holdstr65 = syn->qual[cnt].synonym_desc
      SET holdstr_r = syn->qual[cnt].ref
      SET holdstr_a = syn->qual[cnt].active
      SET holdstr = concat(cnvtstring(cnt,4,0,r),"  ",holdstr65," ",holdstr_a,
       "|",holdstr_r)
      CALL scrolltext(arow,holdstr)
      SET cnt = (cnt+ 1)
      SET arow = (arow+ 1)
    ENDWHILE
    SET cnt = tmp1
    SET arow = 1
  ENDCASE
 ENDWHILE
 GO TO pharm_utilities_mode
#remap_syn_sent_exit
#meds_no_event_code
 CALL show_processing(0)
 DECLARE code_set = i4 WITH noconstant(0)
 DECLARE cdf_meaning = c12 WITH noconstant(" ")
 DECLARE code_value = f8 WITH noconstant(0.0)
 DECLARE pharmcd = f8 WITH noconstant(0.0)
 SET code_set = 6000
 SET cdf_meaning = "PHARMACY"
 EXECUTE cpm_get_cd_for_cdf
 SET pharmcd = code_value
 SET cdf_meaning = fillstring(12," ")
 SET code_value = 0.0
 SET code_set = 0
 SELECT
  oc.catalog_cd, primary_mnem = trim(substring(1,45,oc.primary_mnemonic)), event_cd =
  uar_get_code_display(cv.event_cd)
  FROM order_catalog oc,
   code_value_event_r cv,
   dummyt d
  PLAN (oc
   WHERE oc.catalog_type_cd=pharmcd
    AND oc.orderable_type_flag IN (0, 1, 10))
   JOIN (d)
   JOIN (cv
   WHERE oc.catalog_cd=cv.parent_cd)
  ORDER BY cv.event_cd
  HEAD REPORT
   report_title = "Order Catalog Audit", pagenum = 0, rpt_line = fillstring(150,"=")
  HEAD PAGE
   pagenum = (pagenum+ 1), col 40, report_title,
   col 100, "Page: ", pagenum"###;r",
   row + 1, col 00, "CATALOG_CD",
   col 17, "Primary Mnemonic", col 58,
   "Event Code Display", col 110, "Event Code",
   row + 1, col 00, rpt_line,
   row + 1
  DETAIL
   col 00, oc.catalog_cd, col 15,
   primary_mnem, event_cd = trim(substring(1,40,event_cd)), col 60,
   event_cd, col 108, cv.event_cd,
   row + 1
  WITH outerjoin = d, dontcare, maxrow = 60,
   maxcol = 200
 ;end select
 GO TO care_problem_mode
#meds_no_event_code_exit
#pharm_gl_dupes
 SET cpharm = uar_get_code_by("MEANING",106,"PHARMACY")
 CALL show_processing(0)
 SET maxsecs = 0
 SELECT
  d_activity_type_disp = uar_get_code_display(d.activity_type_cd), d.active_ind, d.mnemonic,
  o.active_ind, o_activity_type_disp = uar_get_code_display(o.activity_type_cd), o.primary_mnemonic
  FROM discrete_task_assay d,
   dummyt d1,
   order_catalog o
  PLAN (d1)
   JOIN (o
   WHERE o.active_ind=1
    AND o.catalog_type_cd=cpharm)
   JOIN (d
   WHERE d.active_ind=1
    AND d.activity_type_cd IN (
   (SELECT
    code_value
    FROM code_value
    WHERE code_set=106
     AND active_ind=1
     AND definition="GENERAL LAB"))
    AND d.mnemonic_key_cap=cnvtupper(o.primary_mnemonic))
  WITH maxrec = 10000, format, time = value(maxsecs),
   skipreport = 1
 ;end select
 GO TO care_problem_mode
#pharm_gl_dupes_exit
#asc_aud_pha_ocs
 CALL clear_screen(0)
 CALL show_processing(0)
 SET cpharm = uar_get_code_by("MEANING",106,"PHARMACY")
 SET cmnem_type_z = uar_get_code_by("MEANING",6011,"TRADEPROD")
 SET cmnem_type_y = uar_get_code_by("MEANING",6011,"GENERICPROD")
 SET cact_type = uar_get_code_by("MEANING",6003,"ORDER")
 SET cdesc = uar_get_code_by("MEANING",11000,"DESC")
 SET cmnem_type_rx = uar_get_code_by("MEANING",6011,"RXMNEMONIC")
 SET csystem = uar_get_code_by("MEANING",4062,"SYSTEM")
 SET cinpatient = uar_get_code_by("MEANING",4500,"INPATIENT")
 DECLARE line = vc
 DECLARE vv_string = vc
 SELECT INTO "pha_aud_ocs.csv"
  primary = substring(1,50,oc.primary_mnemonic), synonym = substring(1,100,ocs.mnemonic),
  synonym_type = uar_get_code_display(ocs.mnemonic_type_cd),
  ocs.rx_mask, oef.oe_format_name, mi.item_id,
  formulary_product = substring(1,100,mi.value), product_type = uar_get_code_display(mdf
   .pharmacy_type_cd), ocs_cki = substring(1,20,ocs.cki),
  oc_cki = substring(1,20,oc.cki), ocs_active_ind = ocs.active_ind, ocs_hide_flag = ocs.hide_flag,
  ocs_titrate_flag = ocs.ingredient_rate_conversion_ind, ocs_clin_cat = uar_get_code_display(ocs
   .dcp_clin_cat_cd), oc_clin_cat = uar_get_code_display(oc.dcp_clin_cat_cd),
  ocs_high_alert_flag = ocs.high_alert_ind, oc_active_ind = oc.active_ind, ocs.synonym_id,
  ocs.oe_format_id, ocs.catalog_cd, ofr.facility_cd,
  facility = uar_get_code_display(ofr.facility_cd), no_vv = nullind(ofr.facility_cd)
  FROM order_catalog_synonym ocs,
   order_entry_format oef,
   order_catalog oc,
   med_identifier mi,
   med_def_flex mdf,
   order_catalog_item_r ocir,
   ocs_facility_r ofr
  PLAN (ocs
   WHERE ocs.activity_type_cd=cpharm)
   JOIN (oc
   WHERE oc.catalog_cd=ocs.catalog_cd
    AND  NOT (oc.orderable_type_flag IN (6, 8)))
   JOIN (ofr
   WHERE ofr.synonym_id=outerjoin(ocs.synonym_id))
   JOIN (ocir
   WHERE ocir.synonym_id=outerjoin(ocs.synonym_id))
   JOIN (oef
   WHERE outerjoin(ocs.oe_format_id)=oef.oe_format_id
    AND oef.action_type_cd=outerjoin(cact_type))
   JOIN (mi
   WHERE outerjoin(ocir.item_id)=mi.item_id
    AND mi.med_identifier_type_cd=outerjoin(cdesc)
    AND mi.med_product_id=outerjoin(0)
    AND mi.primary_ind=outerjoin(1)
    AND mi.pharmacy_type_cd=outerjoin(cinpatient))
   JOIN (mdf
   WHERE mdf.item_id=outerjoin(ocir.item_id)
    AND mdf.flex_type_cd=outerjoin(csystem)
    AND mdf.pharmacy_type_cd=outerjoin(cinpatient))
  ORDER BY cnvtupper(oc.primary_mnemonic), cnvtupper(ocs.mnemonic), ocs.synonym_id,
   ofr.facility_cd
  HEAD REPORT
   vv_cnt = 0, line = "", col 0,
   "CATALOG_CD,", "PRIMARY,", "SYNONYM_ID,",
   "SYNONYM,", "SYNONYM_TYPE,", "RX_MASK,",
   "OEF,", "OCS_CKI,", "OC_CKI,",
   "ITEM_ID,", "PRODUCT_DESC,", "PRODUCT_TYPE,",
   "OCS_ACTIVE_IND,", "OCS_HIDE,", "OC_ACTIVE_IND,",
   "OCS_TITRATE_FLAG,", "OCS_CLIN_CAT,", "OC_CLIN_CAT,",
   "OCS_HIGH_ALERT,", "VIRTUAL_VIEW"
  HEAD ocs.synonym_id
   vv_cnt = 0, vv_string = "", line = concat('"',trim(cnvtstring(ocs.catalog_cd)),'"',",",'"',
    trim(oc.primary_mnemonic),'"',",",'"',trim(cnvtstring(ocs.synonym_id)),
    '"',",",'"',trim(ocs.mnemonic),'"',
    ",",'"',trim(synonym_type),'"',",",
    '"',trim(cnvtstring(ocs.rx_mask)),'"',",",'"',
    trim(oef.oe_format_name),'"',",",'"',trim(ocs.cki),
    '"',",",'"',trim(oc.cki),'"',
    ",",'"',trim(cnvtstring(mi.item_id)),'"',",",
    '"',trim(mi.value),'"',",",'"',
    trim(product_type),'"',",",'"',trim(cnvtstring(ocs.active_ind)),
    '"',",",'"',trim(cnvtstring(ocs.hide_flag)),'"',
    ",",'"',trim(cnvtstring(oc.active_ind)),'"',",",
    '"',trim(cnvtstring(ocs.ingredient_rate_conversion_ind)),'"',",",'"',
    trim(cnvtstring(ocs_clin_cat)),'"',",",'"',trim(cnvtstring(oc_clin_cat)),
    '"',",",'"',trim(cnvtstring(ocs.high_alert_ind)),'"',
    ",")
  DETAIL
   vv_cnt = (vv_cnt+ 1)
   IF (vv_cnt=1)
    IF (no_vv=1)
     vv_string = ""
    ELSEIF (no_vv=0
     AND ofr.facility_cd=0)
     vv_string = "All Facilities"
    ELSE
     vv_string = facility
    ENDIF
   ELSE
    vv_string = concat(vv_string,", ",facility)
   ENDIF
  FOOT  ocs.synonym_id
   row + 1, line = concat(line,'"',vv_string,'"'), col 0,
   line
  WITH check, maxcol = 2000, format = variable,
   nullreport, noformfeed, landscape,
   maxrow = 1
 ;end select
 CALL clear_screen(0)
#asc_aud_pha_ocs_exit
#asc_aud_pha_ocs_scr
 CALL clear_screen(0)
 CALL show_processing(0)
 SET cpharm = uar_get_code_by("MEANING",106,"PHARMACY")
 SET cmnem_type_z = uar_get_code_by("MEANING",6011,"TRADEPROD")
 SET cmnem_type_y = uar_get_code_by("MEANING",6011,"GENERICPROD")
 SET cact_type = uar_get_code_by("MEANING",6003,"ORDER")
 SET cdesc = uar_get_code_by("MEANING",11000,"DESC")
 SET cmnem_type_rx = uar_get_code_by("MEANING",6011,"RXMNEMONIC")
 SET csystem = uar_get_code_by("MEANING",4062,"SYSTEM")
 SET cinpatient = uar_get_code_by("MEANING",4500,"INPATIENT")
 SELECT
  primary = substring(1,50,oc.primary_mnemonic), synonym = substring(1,100,ocs.mnemonic),
  synonym_type = uar_get_code_display(ocs.mnemonic_type_cd),
  ocs.rx_mask, oef.oe_format_name, mi.item_id,
  formulary_product = substring(1,100,mi.value), product_type = uar_get_code_display(mdf
   .pharmacy_type_cd), ocs_cki = substring(1,20,ocs.cki),
  oc_cki = substring(1,20,oc.cki), ocs_active_ind = ocs.active_ind, ocs_hide_flag = ocs.hide_flag,
  ocs_titrate_flag = ocs.ingredient_rate_conversion_ind, ocs_high_alert_flag = ocs.high_alert_ind,
  oc_active_ind = oc.active_ind,
  ocs.synonym_id, ocs.oe_format_id, ocs.catalog_cd
  FROM order_catalog_synonym ocs,
   order_entry_format oef,
   order_catalog oc,
   med_identifier mi,
   med_def_flex mdf,
   order_catalog_item_r ocir
  PLAN (ocs
   WHERE ocs.activity_type_cd=cpharm)
   JOIN (oc
   WHERE oc.catalog_cd=ocs.catalog_cd
    AND  NOT (oc.orderable_type_flag IN (6, 8)))
   JOIN (ocir
   WHERE ocir.synonym_id=outerjoin(ocs.synonym_id))
   JOIN (oef
   WHERE outerjoin(ocs.oe_format_id)=oef.oe_format_id
    AND oef.action_type_cd=outerjoin(cact_type))
   JOIN (mi
   WHERE outerjoin(ocir.item_id)=mi.item_id
    AND mi.med_identifier_type_cd=outerjoin(cdesc)
    AND mi.med_product_id=outerjoin(0)
    AND mi.primary_ind=outerjoin(1)
    AND mi.pharmacy_type_cd=outerjoin(cinpatient))
   JOIN (mdf
   WHERE mdf.item_id=outerjoin(ocir.item_id)
    AND mdf.flex_type_cd=outerjoin(csystem)
    AND mdf.pharmacy_type_cd=outerjoin(cinpatient))
  ORDER BY cnvtupper(oc.primary_mnemonic), ocs.mnemonic_key_cap
  WITH format = pcformat
 ;end select
#asc_aud_pha_ocs_scr_exit
#asc_prdct_rxmnem
 CALL clear_screen(0)
 CALL show_processing(0)
 SET cdesc = uar_get_code_by("MEANING",11000,"DESC")
 SET crxm = uar_get_code_by("MEANING",6011,"RXMNEMONIC")
 SET corder = uar_get_code_by("MEANING",6003,"ORDER")
 SET csystem = uar_get_code_by("MEANING",4062,"SYSTEM")
 SET csyspkgtyp = uar_get_code_by("MEANING",4062,"SYSPKGTYP")
 SET corderable = uar_get_code_by("MEANING",4063,"ORDERABLE")
 SET cinpatient = uar_get_code_by("MEANING",4500,"INPATIENT")
 DECLARE line = vc
 SELECT INTO "asc_prdct_rxmnem_audit.csv"
  formulary_product = substring(1,80,mi.value), primary = substring(1,60,oc.primary_mnemonic), ocs
  .rx_mask,
  oef = substring(1,40,oef.oe_format_name), oc_cki = substring(1,30,oc.cki), ocir.item_id,
  catalog_cd = oc.catalog_cd
  FROM order_catalog_item_r ocir,
   order_catalog oc,
   med_identifier mi,
   order_catalog_synonym ocs,
   order_entry_format oef,
   med_def_flex mdf,
   med_def_flex mdf2,
   med_flex_object_idx mfoi
  PLAN (ocir)
   JOIN (mdf
   WHERE mdf.item_id=ocir.item_id
    AND mdf.flex_type_cd=csystem
    AND mdf.pharmacy_type_cd=cinpatient)
   JOIN (mdf2
   WHERE mdf2.item_id=ocir.item_id
    AND mdf2.flex_type_cd=csyspkgtyp
    AND mdf2.pharmacy_type_cd=cinpatient)
   JOIN (mfoi
   WHERE mfoi.med_def_flex_id=mdf2.med_def_flex_id
    AND mfoi.flex_object_type_cd=corderable
    AND ((mfoi.parent_entity_id=0) OR (mfoi.parent_entity_id=cur_facility_cd)) )
   JOIN (oc
   WHERE oc.catalog_cd=ocir.catalog_cd)
   JOIN (mi
   WHERE mi.item_id=ocir.item_id
    AND mi.med_product_id=0
    AND mi.med_identifier_type_cd=cdesc
    AND mi.active_ind=1
    AND mi.primary_ind=1
    AND mi.pharmacy_type_cd=cinpatient)
   JOIN (ocs
   WHERE ocs.item_id=ocir.item_id
    AND ocs.mnemonic_type_cd=crxm)
   JOIN (oef
   WHERE oef.oe_format_id=outerjoin(ocs.oe_format_id)
    AND oef.action_type_cd=outerjoin(corder))
  ORDER BY cnvtupper(mi.value), cnvtupper(oc.primary_mnemonic)
  HEAD REPORT
   col 0, "FORMULARY_PRODUCT,", "PRIMARY,",
   "RX_MASK,", "OEF,", "OC_CKI,",
   "ITEM_ID,", "CATALOG_CD"
  HEAD ocir.item_id
   line = concat('"',trim(mi.value),'"',",",'"',
    trim(oc.primary_mnemonic),'"',",",'"',trim(cnvtstring(ocs.rx_mask)),
    '"',",",'"',trim(oef.oe_format_name),'"',
    ",",'"',trim(oc.cki),'"',",",
    '"',trim(cnvtstring(ocir.item_id)),'"',",",'"',
    trim(cnvtstring(oc.catalog_cd)),'"')
  DETAIL
   col + 0
  FOOT  ocir.item_id
   row + 1, col 0, line
  WITH check, maxcol = 2000, format = variable,
   nullreport, noformfeed, landscape,
   maxrow = 1
 ;end select
#asc_prdct_rxmnem_exit
#asc_prdct_rxmnem_scr
 CALL clear_screen(0)
 CALL show_processing(0)
 SET cdesc = uar_get_code_by("MEANING",11000,"DESC")
 SET crxm = uar_get_code_by("MEANING",6011,"RXMNEMONIC")
 SET corder = uar_get_code_by("MEANING",6003,"ORDER")
 SET csystem = uar_get_code_by("MEANING",4062,"SYSTEM")
 SET csyspkgtyp = uar_get_code_by("MEANING",4062,"SYSPKGTYP")
 SET corderable = uar_get_code_by("MEANING",4063,"ORDERABLE")
 SET cinpatient = uar_get_code_by("MEANING",4500,"INPATIENT")
 SELECT
  formulary_product = substring(1,80,mi.value), primary = substring(1,60,oc.primary_mnemonic), ocs
  .rx_mask,
  oef = substring(1,40,oef.oe_format_name), oc_cki = substring(1,30,oc.cki), ocir.item_id,
  catalog_cd = oc.catalog_cd
  FROM order_catalog_item_r ocir,
   order_catalog oc,
   med_identifier mi,
   order_catalog_synonym ocs,
   order_entry_format oef,
   med_def_flex mdf,
   med_def_flex mdf2,
   med_flex_object_idx mfoi
  PLAN (ocir)
   JOIN (mdf
   WHERE mdf.item_id=ocir.item_id
    AND mdf.flex_type_cd=csystem
    AND mdf.pharmacy_type_cd=cinpatient)
   JOIN (mdf2
   WHERE mdf2.item_id=ocir.item_id
    AND mdf2.flex_type_cd=csyspkgtyp
    AND mdf2.pharmacy_type_cd=cinpatient)
   JOIN (mfoi
   WHERE mfoi.med_def_flex_id=mdf2.med_def_flex_id
    AND mfoi.flex_object_type_cd=corderable
    AND ((mfoi.parent_entity_id=0) OR (mfoi.parent_entity_id=cur_facility_cd)) )
   JOIN (oc
   WHERE oc.catalog_cd=ocir.catalog_cd)
   JOIN (mi
   WHERE mi.item_id=ocir.item_id
    AND mi.med_product_id=0
    AND mi.med_identifier_type_cd=cdesc
    AND mi.active_ind=1
    AND mi.primary_ind=1
    AND mi.pharmacy_type_cd=cinpatient)
   JOIN (ocs
   WHERE ocs.item_id=ocir.item_id
    AND ocs.mnemonic_type_cd=crxm)
   JOIN (oef
   WHERE oef.oe_format_id=outerjoin(ocs.oe_format_id)
    AND oef.action_type_cd=outerjoin(corder))
  ORDER BY cnvtupper(mi.value), cnvtupper(oc.primary_mnemonic)
  WITH format = pcformat
 ;end select
#asc_prdct_rxmnem_scr_exit
#asc_med_op_os_extract
 SET text_row = 5
 CALL clear_screen(0)
 CALL text(5,2,"A file will be created in CCLUSERDIR called 'asc_med_op_sent_extract.csv'")
 CALL text(7,2,"Begin? (Y/N)")
 CALL accept(7,17,"C;CU","Y"
  WHERE curaccept IN ("Y", "N"))
 CASE (curaccept)
  OF "Y":
   CALL show_processing(0)
  OF "N":
   GO TO pharm_extract_mode
 ENDCASE
 CALL show_processing(0)
 CALL text(text_row,2,"Beginning sentence extract...")
 SET text_row = (text_row+ 1)
 DECLARE get_sentence_detail_value(detail_pos=f8) = vc
 DECLARE csv_line = vc
 DECLARE text_result = vc
 DECLARE detail_text_value = vc
 SET order_sentence_count = 0
 SET cprim_rx = 0
 SET cprim_rx_cnt = 0
 SET cprn = 0
 SET cprn_cnt = 0
 SET cerror_flag = 0
 SET cdup_fields = 0
 FREE RECORD details
 RECORD details(
   1 details[*]
     2 os_id = f8
     2 oe_field_id = f8
     2 code_value = f8
     2 field_value = vc
 )
 FREE RECORD used_fields
 RECORD used_fields(
   1 fields[*]
     2 oe_field_id = f8
     2 oe_field_meaning = vc
 )
 SET stat = alterlist(used_fields->fields,18)
 SET used_fields->fields[1].oe_field_meaning = "STRENGTHDOSE"
 SET used_fields->fields[2].oe_field_meaning = "STRENGTHDOSEUNIT"
 SET used_fields->fields[3].oe_field_meaning = "VOLUMEDOSE"
 SET used_fields->fields[4].oe_field_meaning = "VOLUMEDOSEUNIT"
 SET used_fields->fields[5].oe_field_meaning = "FREETXTDOSE"
 SET used_fields->fields[6].oe_field_meaning = "RXROUTE"
 SET used_fields->fields[7].oe_field_meaning = "DRUGFORM"
 SET used_fields->fields[8].oe_field_meaning = "FREQ"
 SET used_fields->fields[9].oe_field_meaning = "RXPRIORITY"
 SET used_fields->fields[10].oe_field_meaning = "SCH/PRN"
 SET used_fields->fields[11].oe_field_meaning = "PRNREASON"
 SET used_fields->fields[12].oe_field_meaning = "FREETEXTRATE"
 SET used_fields->fields[13].oe_field_meaning = "RATE"
 SET used_fields->fields[14].oe_field_meaning = "RATEUNIT"
 SET used_fields->fields[15].oe_field_meaning = "INFUSEOVER"
 SET used_fields->fields[16].oe_field_meaning = "INFUSEOVERUNIT"
 SET used_fields->fields[17].oe_field_meaning = "DURATION"
 SET used_fields->fields[18].oe_field_meaning = "DURATIONUNIT"
 CALL text(text_row,2,"Looking up required code values...")
 SET text_row = (text_row+ 1)
 SET cpharm = uar_get_code_by("MEANING",6000,"PHARMACY")
 SET cmnem_type_z = uar_get_code_by("MEANING",6011,"TRADEPROD")
 SET cmnem_type_y = uar_get_code_by("MEANING",6011,"GENERICPROD")
 SET corder = uar_get_code_by("MEANING",6003,"ORDER")
 SELECT INTO "nl:"
  oef.oe_format_id
  FROM order_entry_format oef
  WHERE cnvtupper(oef.oe_format_name)="PRIMARY PHARMACY"
   AND oef.action_type_cd=corder
  DETAIL
   cprim_rx = oef.oe_format_id, cprim_rx_cnt = (cprim_rx_cnt+ 1)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  oef.oe_field_id
  FROM order_entry_fields oef,
   oe_field_meaning ofm
  WHERE oef.oe_field_meaning_id=ofm.oe_field_meaning_id
   AND ofm.oe_field_meaning="SCH/PRN"
  DETAIL
   cprn = oef.oe_field_id, cprn_cnt = (cprn_cnt+ 1)
  WITH nocounter
 ;end select
 IF (((cprn_cnt != 1) OR (((cprim_rx_cnt != 1) OR (((cpharm=0) OR (((cmnem_type_z=0) OR (((
 cmnem_type_y=0) OR (corder=0)) )) )) )) )) )
  SET cerror_flag = 1
  GO TO end_op_sent_extract
 ENDIF
 CALL text(text_row,2,"Identifying order entry fields used in medication sentences...")
 SET text_row = (text_row+ 1)
 SELECT DISTINCT INTO "nl:"
  osd.oe_field_id, ofm.oe_field_meaning
  FROM ord_cat_sent_r ocsr,
   order_sentence os,
   order_catalog oc,
   order_catalog_synonym ocs,
   order_sentence_detail osd,
   oe_field_meaning ofm
  WHERE os.order_sentence_id=ocsr.order_sentence_id
   AND os.usage_flag=2
   AND oc.catalog_cd=ocsr.catalog_cd
   AND oc.catalog_type_cd=cpharm
   AND oc.orderable_type_flag IN (0, 1)
   AND ocs.synonym_id=ocsr.synonym_id
   AND ocs.oe_format_id != cprim_rx
   AND ocs.oe_format_id > 0
   AND osd.order_sentence_id=ocsr.order_sentence_id
   AND osd.oe_field_meaning_id=ofm.oe_field_meaning_id
   AND ofm.oe_field_meaning != "OTHER"
  ORDER BY osd.oe_field_id
  HEAD REPORT
   row_cnt = 19, array_loc = 1
  HEAD osd.oe_field_id
   array_loc = 0
   CASE (trim(ofm.oe_field_meaning))
    OF "STRENGTHDOSE":
     array_loc = 1
    OF "STRENGTHDOSEUNIT":
     array_loc = 2
    OF "VOLUMEDOSE":
     array_loc = 3
    OF "VOLUMEDOSEUNIT":
     array_loc = 4
    OF "FREETXTDOSE":
     array_loc = 5
    OF "RXROUTE":
     array_loc = 6
    OF "DRUGFORM":
     array_loc = 7
    OF "FREQ":
     array_loc = 8
    OF "RXPRIORITY":
     array_loc = 9
    OF "SCH/PRN":
     array_loc = 10
    OF "PRNREASON":
     array_loc = 11
    OF "FREETEXTRATE":
     array_loc = 12
    OF "RATE":
     array_loc = 13
    OF "RATEUNIT":
     array_loc = 14
    OF "INFUSEOVER":
     array_loc = 15
    OF "INFUSEOVERUNIT":
     array_loc = 16
    OF "DURATION":
     array_loc = 17
    OF "DURATIONUNIT":
     array_loc = 18
    ELSE
     array_loc = row_cnt,stat = alterlist(used_fields->fields,row_cnt),row_cnt = (row_cnt+ 1)
   ENDCASE
   IF ((used_fields->fields[array_loc].oe_field_id > 0))
    cdup_fields = 1, text_row = (text_row+ 1),
    CALL text(text_row,2,build("Warning!! ...duplicate fields in use for field meaning=",ofm
     .oe_field_meaning)),
    text_row = (text_row+ 1),
    CALL text(text_row,2,"Extracted values for this field may be unpredictable"), text_row = (
    text_row+ 1)
   ENDIF
   used_fields->fields[array_loc].oe_field_id = osd.oe_field_id, used_fields->fields[array_loc].
   oe_field_meaning = ofm.oe_field_meaning
  WITH nullreport
 ;end select
 CALL text(text_row,2,"Generating index of medication order sentence details...")
 SET text_row = (text_row+ 1)
 SELECT INTO "nl:"
  os.order_sentence_id, osd.oe_field_id, code_value = osd.default_parent_entity_id,
  osd.oe_field_value, osd.oe_field_display_value, code_value_display = cv.display,
  oefld.field_type_flag
  FROM ord_cat_sent_r ocsr,
   order_sentence os,
   order_catalog oc,
   code_value cv,
   order_catalog_synonym ocs,
   order_entry_format oef,
   order_sentence_detail osd,
   order_entry_fields oefld
  PLAN (ocsr)
   JOIN (os
   WHERE os.order_sentence_id=ocsr.order_sentence_id
    AND os.usage_flag=2)
   JOIN (oc
   WHERE oc.catalog_cd=ocsr.catalog_cd
    AND oc.catalog_type_cd=cpharm
    AND oc.orderable_type_flag IN (0, 1))
   JOIN (ocs
   WHERE ocs.synonym_id=ocsr.synonym_id
    AND ocs.oe_format_id != cprim_rx
    AND ocs.oe_format_id > 0)
   JOIN (oef
   WHERE oef.oe_format_id=outerjoin(ocs.oe_format_id)
    AND oef.action_type_cd=outerjoin(corder))
   JOIN (osd
   WHERE osd.order_sentence_id=ocsr.order_sentence_id)
   JOIN (oefld
   WHERE oefld.oe_field_id=osd.oe_field_id)
   JOIN (cv
   WHERE osd.default_parent_entity_id=cv.code_value)
  ORDER BY os.order_sentence_id, osd.oe_field_id
  HEAD REPORT
   row_cnt = 0
  HEAD os.order_sentence_id
   order_sentence_count = (order_sentence_count+ 1)
  DETAIL
   row_cnt = (row_cnt+ 1), stat = alterlist(details->details,row_cnt), details->details[row_cnt].
   os_id = os.order_sentence_id,
   details->details[row_cnt].oe_field_id = osd.oe_field_id
   IF (osd.default_parent_entity_id > 0)
    details->details[row_cnt].field_value = cv.display
   ELSE
    IF (oefld.field_type_flag=7
     AND trim(osd.oe_field_display_value)="1")
     details->details[row_cnt].field_value = "Yes"
    ELSEIF (oefld.field_type_flag=7
     AND trim(osd.oe_field_display_value)="0")
     details->details[row_cnt].field_value = "No"
    ELSE
     details->details[row_cnt].field_value = osd.oe_field_display_value
    ENDIF
   ENDIF
  WITH nullreport, outerjoin = cv
 ;end select
 CALL text(text_row,2,concat("Building extract. ",build(order_sentence_count),
   " sentences to process..."))
 SET text_row = (text_row+ 1)
 SELECT INTO "asc_med_op_sent_extract.csv"
  primary_synonym = oc.primary_mnemonic, ocs.synonym_id, mnemonic_key_cap = ocs.mnemonic_key_cap,
  mnemonic_type = cv.display, mnemonic_type_cdf = cv.cdf_meaning, oef.oe_format_id,
  oef.oe_format_name, ocsr.order_sentence_id, script = ocsr.order_sentence_disp_line,
  os.usage_flag, order_cat_cki = oc.cki, synonym_cki = ocs.cki,
  os.external_identifier, comment = lt.long_text
  FROM ord_cat_sent_r ocsr,
   order_sentence os,
   order_catalog oc,
   code_value cv,
   order_catalog_synonym ocs,
   order_entry_format oef,
   long_text lt
  PLAN (ocsr)
   JOIN (os
   WHERE os.order_sentence_id=ocsr.order_sentence_id
    AND os.usage_flag=2)
   JOIN (oc
   WHERE oc.catalog_cd=ocsr.catalog_cd
    AND oc.catalog_type_cd=cpharm
    AND oc.orderable_type_flag IN (0, 1)
    AND oc.active_ind=1)
   JOIN (ocs
   WHERE ocs.synonym_id=ocsr.synonym_id
    AND ocs.oe_format_id != cprim_rx
    AND ocs.oe_format_id > 0
    AND ocs.active_ind=1
    AND ((ocs.hide_flag=0) OR (ocs.hide_flag=null)) )
   JOIN (oef
   WHERE oef.oe_format_id=outerjoin(ocs.oe_format_id)
    AND oef.action_type_cd=outerjoin(corder))
   JOIN (lt
   WHERE outerjoin(os.ord_comment_long_text_id)=lt.long_text_id)
   JOIN (cv
   WHERE ocs.mnemonic_type_cd=cv.code_value)
  ORDER BY oef.oe_format_id, os.order_sentence_id
  HEAD REPORT
   os_cnt = 0, oef_cnt = 0, cur_field_match_found = 0,
   cur_sentence_pos = 0, cur_sentence_detail_count = 0, cur_sentence_details_found = 0,
   csv_line = concat("SYNONYM_ID,PRIMARY_SYNONYM,MNEMONIC_KEY_CAP,MNEMONIC_TYPE,",
    "MNEMONIC_TYPE_CDF,OEF,ORDER_SENTENCE_ID,SCRIPT,",
    "USAGE_FLAG,ORDER_CAT_CKI,SYNONYM_CKI,EXTERNAL_IDENTIFIER,")
   FOR (x = 1 TO size(used_fields->fields,5))
     csv_line = concat(csv_line,'"',"OE_FLD",trim(cnvtstring(x)),'"',
      ",",'"',"OE_FLD_VALUE",trim(cnvtstring(x)),'"',
      ",")
   ENDFOR
   csv_line = concat(csv_line,'"',"COMMENT",'"'), col 0, csv_line,
   row + 1, csv_line = ""
  HEAD oef.oe_format_id
   oef_cnt = (oef_cnt+ 1)
  HEAD ocsr.order_sentence_id
   os_cnt = (os_cnt+ 1), cur_sentence_pos = 0, cur_sentence_detail_count = 0,
   cur_sentence_details_found = 0, cur_field_match_found = 0, csv_line = ""
   IF (os_cnt > 1)
    row + 1
   ENDIF
   csv_line = concat('"',trim(cnvtstring(ocs.synonym_id)),'"',",",'"',
    trim(oc.primary_mnemonic),'"',",",'"',trim(ocs.mnemonic_key_cap),
    '"',",",'"',trim(cv.display),'"',
    ",",'"',trim(cv.cdf_meaning),'"',",",
    '"',trim(oef.oe_format_name),'"',",",'"',
    trim(cnvtstring(ocsr.order_sentence_id)),'"',",",'"',trim(ocsr.order_sentence_disp_line),
    '"',",",'"',trim(cnvtstring(os.usage_flag)),'"',
    ",",'"',trim(oc.cki),'"',",",
    '"',trim(ocs.cki),'"',",",'"',
    trim(os.external_identifier),'"',","), cur_sentence_pos = find_sentence_pos(ocsr
    .order_sentence_id), cur_sentence_detail_count = count_sentence_details(cur_sentence_pos)
   FOR (y = 1 TO size(used_fields->fields,5))
     detail_text_value = "error", cur_field_match_found = 0, csv_line = concat(csv_line,'"',
      used_fields->fields[y].oe_field_meaning,'"',",")
     IF (cur_sentence_detail_count > 0)
      FOR (z = 1 TO cur_sentence_detail_count)
        IF (cur_sentence_details_found < cur_sentence_detail_count
         AND (used_fields->fields[y].oe_field_id=get_sentence_detail_type(((cur_sentence_pos+ z) - 1)
         ))
         AND cur_field_match_found=0)
         cur_sentence_details_found = (cur_sentence_details_found+ 1), detail_text_value = trim(build
          (get_sentence_detail_value(cnvtreal(((cur_sentence_pos+ z) - 1))))), csv_line = concat(
          csv_line,'"',detail_text_value,'"',","),
         cur_field_match_found = 1
        ENDIF
      ENDFOR
      IF ((used_fields->fields[y].oe_field_id=cprn)
       AND cur_field_match_found=0)
       csv_line = concat(csv_line,'"',"No",'"',",")
      ELSEIF (cur_field_match_found=0)
       csv_line = concat(csv_line,'"','"',",")
      ENDIF
     ENDIF
   ENDFOR
   csv_line = concat(csv_line,'"',trim(lt.long_text),'"'), col 0, csv_line
  FOOT REPORT
   CALL text(text_row,2,"Extract complete"), text_row = (text_row+ 1)
  WITH check, maxcol = 10000, format = variable,
   nullreport, noformfeed, landscape,
   maxrow = 1
 ;end select
#end_op_sent_extract
 IF (cerror_flag=1)
  CALL text(text_row,2,"Unable to locate required information. Extract aborted.")
  SET text_row = (text_row+ 1)
 ENDIF
 FREE RECORD details
 FREE RECORD used_fields
 GO TO pharm_extract_mode
#asc_med_op_os_extract_exit
#asc_med_os_extract
 SET text_row = 5
 CALL clear_screen(0)
 CALL text(5,2,"A file will be created in CCLUSERDIR called 'asc_med_sent_extract.csv'")
 CALL text(7,2,"Begin? (Y/N)")
 CALL accept(7,17,"C;CU","Y"
  WHERE curaccept IN ("Y", "N"))
 CASE (curaccept)
  OF "Y":
   CALL show_processing(0)
  OF "N":
   GO TO pharm_extract_mode
 ENDCASE
 CALL show_processing(0)
 CALL text(text_row,2,"Beginning sentence extract...")
 SET text_row = (text_row+ 1)
 DECLARE get_sentence_detail_value(detail_pos=f8) = vc
 DECLARE csv_line = vc
 DECLARE text_result = vc
 DECLARE detail_text_value = vc
 SET order_sentence_count = 0
 SET cprim_rx = 0
 SET cprim_rx_cnt = 0
 SET cprn = 0
 SET cprn_cnt = 0
 SET cerror_flag = 0
 SET cdup_fields = 0
 FREE RECORD details
 RECORD details(
   1 details[*]
     2 os_id = f8
     2 oe_field_id = f8
     2 code_value = f8
     2 field_value = vc
 )
 FREE RECORD used_fields
 RECORD used_fields(
   1 fields[*]
     2 oe_field_id = f8
     2 oe_field_meaning = vc
 )
 SET stat = alterlist(used_fields->fields,18)
 SET used_fields->fields[1].oe_field_meaning = "STRENGTHDOSE"
 SET used_fields->fields[2].oe_field_meaning = "STRENGTHDOSEUNIT"
 SET used_fields->fields[3].oe_field_meaning = "VOLUMEDOSE"
 SET used_fields->fields[4].oe_field_meaning = "VOLUMEDOSEUNIT"
 SET used_fields->fields[5].oe_field_meaning = "FREETXTDOSE"
 SET used_fields->fields[6].oe_field_meaning = "RXROUTE"
 SET used_fields->fields[7].oe_field_meaning = "DRUGFORM"
 SET used_fields->fields[8].oe_field_meaning = "FREQ"
 SET used_fields->fields[9].oe_field_meaning = "RXPRIORITY"
 SET used_fields->fields[10].oe_field_meaning = "SCH/PRN"
 SET used_fields->fields[11].oe_field_meaning = "PRNREASON"
 SET used_fields->fields[12].oe_field_meaning = "FREETEXTRATE"
 SET used_fields->fields[13].oe_field_meaning = "RATE"
 SET used_fields->fields[14].oe_field_meaning = "RATEUNIT"
 SET used_fields->fields[15].oe_field_meaning = "INFUSEOVER"
 SET used_fields->fields[16].oe_field_meaning = "INFUSEOVERUNIT"
 SET used_fields->fields[17].oe_field_meaning = "DURATION"
 SET used_fields->fields[18].oe_field_meaning = "DURATIONUNIT"
 CALL text(text_row,2,"Looking up required code values...")
 SET text_row = (text_row+ 1)
 SET cpharm = uar_get_code_by("MEANING",6000,"PHARMACY")
 SET cmnem_type_z = uar_get_code_by("MEANING",6011,"TRADEPROD")
 SET cmnem_type_y = uar_get_code_by("MEANING",6011,"GENERICPROD")
 SET corder = uar_get_code_by("MEANING",6003,"ORDER")
 SELECT INTO "nl:"
  oef.oe_format_id
  FROM order_entry_format oef
  WHERE cnvtupper(oef.oe_format_name)="PRIMARY PHARMACY"
   AND oef.action_type_cd=corder
  DETAIL
   cprim_rx = oef.oe_format_id, cprim_rx_cnt = (cprim_rx_cnt+ 1)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  oef.oe_field_id
  FROM order_entry_fields oef,
   oe_field_meaning ofm
  WHERE oef.oe_field_meaning_id=ofm.oe_field_meaning_id
   AND ofm.oe_field_meaning="SCH/PRN"
  DETAIL
   cprn = oef.oe_field_id, cprn_cnt = (cprn_cnt+ 1)
  WITH nocounter
 ;end select
 IF (((cprn_cnt != 1) OR (((cprim_rx_cnt != 1) OR (((cpharm=0) OR (((cmnem_type_z=0) OR (((
 cmnem_type_y=0) OR (corder=0)) )) )) )) )) )
  SET cerror_flag = 1
  GO TO end_sent_extract
 ENDIF
 CALL text(text_row,2,"Identifying order entry fields used in medication sentences...")
 SET text_row = (text_row+ 1)
 SELECT DISTINCT INTO "nl:"
  osd.oe_field_id, ofm.oe_field_meaning
  FROM ord_cat_sent_r ocsr,
   order_sentence os,
   order_catalog oc,
   order_catalog_synonym ocs,
   order_sentence_detail osd,
   oe_field_meaning ofm
  WHERE os.order_sentence_id=ocsr.order_sentence_id
   AND os.usage_flag IN (0, 1)
   AND oc.catalog_cd=ocsr.catalog_cd
   AND oc.catalog_type_cd=cpharm
   AND oc.orderable_type_flag IN (0, 1)
   AND ocs.synonym_id=ocsr.synonym_id
   AND  NOT (ocs.mnemonic_type_cd IN (cmnem_type_z, cmnem_type_y))
   AND ocs.oe_format_id != cprim_rx
   AND ocs.oe_format_id > 0
   AND osd.order_sentence_id=ocsr.order_sentence_id
   AND osd.oe_field_meaning_id=ofm.oe_field_meaning_id
   AND ofm.oe_field_meaning != "OTHER"
  ORDER BY osd.oe_field_id
  HEAD REPORT
   row_cnt = 19, array_loc = 1
  HEAD osd.oe_field_id
   array_loc = 0
   CASE (trim(ofm.oe_field_meaning))
    OF "STRENGTHDOSE":
     array_loc = 1
    OF "STRENGTHDOSEUNIT":
     array_loc = 2
    OF "VOLUMEDOSE":
     array_loc = 3
    OF "VOLUMEDOSEUNIT":
     array_loc = 4
    OF "FREETXTDOSE":
     array_loc = 5
    OF "RXROUTE":
     array_loc = 6
    OF "DRUGFORM":
     array_loc = 7
    OF "FREQ":
     array_loc = 8
    OF "RXPRIORITY":
     array_loc = 9
    OF "SCH/PRN":
     array_loc = 10
    OF "PRNREASON":
     array_loc = 11
    OF "FREETEXTRATE":
     array_loc = 12
    OF "RATE":
     array_loc = 13
    OF "RATEUNIT":
     array_loc = 14
    OF "INFUSEOVER":
     array_loc = 15
    OF "INFUSEOVERUNIT":
     array_loc = 16
    OF "DURATION":
     array_loc = 17
    OF "DURATIONUNIT":
     array_loc = 18
    ELSE
     array_loc = row_cnt,stat = alterlist(used_fields->fields,row_cnt),row_cnt = (row_cnt+ 1)
   ENDCASE
   IF ((used_fields->fields[array_loc].oe_field_id > 0))
    cdup_fields = 1, text_row = (text_row+ 1),
    CALL text(text_row,2,build("Warning!! ...duplicate fields in use for field meaning=",ofm
     .oe_field_meaning)),
    text_row = (text_row+ 1),
    CALL text(text_row,2,"Extracted values for this field may be unpredictable"), text_row = (
    text_row+ 1)
   ENDIF
   used_fields->fields[array_loc].oe_field_id = osd.oe_field_id, used_fields->fields[array_loc].
   oe_field_meaning = ofm.oe_field_meaning
  WITH nullreport
 ;end select
 CALL text(text_row,2,"Generating index of medication order sentence details...")
 SET text_row = (text_row+ 1)
 SELECT INTO "nl:"
  os.order_sentence_id, osd.oe_field_id, code_value = osd.default_parent_entity_id,
  osd.oe_field_value, osd.oe_field_display_value, code_value_display = cv.display,
  oefld.field_type_flag
  FROM ord_cat_sent_r ocsr,
   order_sentence os,
   order_catalog oc,
   code_value cv,
   order_catalog_synonym ocs,
   order_entry_format oef,
   order_sentence_detail osd,
   order_entry_fields oefld
  PLAN (ocsr)
   JOIN (os
   WHERE os.order_sentence_id=ocsr.order_sentence_id
    AND os.usage_flag IN (0, 1))
   JOIN (oc
   WHERE oc.catalog_cd=ocsr.catalog_cd
    AND oc.catalog_type_cd=cpharm
    AND oc.orderable_type_flag IN (0, 1))
   JOIN (ocs
   WHERE ocs.synonym_id=ocsr.synonym_id
    AND  NOT (ocs.mnemonic_type_cd IN (cmnem_type_z, cmnem_type_y))
    AND ocs.oe_format_id != cprim_rx
    AND ocs.oe_format_id > 0)
   JOIN (oef
   WHERE oef.oe_format_id=outerjoin(ocs.oe_format_id)
    AND oef.action_type_cd=outerjoin(corder))
   JOIN (osd
   WHERE osd.order_sentence_id=ocsr.order_sentence_id)
   JOIN (oefld
   WHERE oefld.oe_field_id=osd.oe_field_id)
   JOIN (cv
   WHERE osd.default_parent_entity_id=cv.code_value)
  ORDER BY os.order_sentence_id, osd.oe_field_id
  HEAD REPORT
   row_cnt = 0
  HEAD os.order_sentence_id
   order_sentence_count = (order_sentence_count+ 1)
  DETAIL
   row_cnt = (row_cnt+ 1), stat = alterlist(details->details,row_cnt), details->details[row_cnt].
   os_id = os.order_sentence_id,
   details->details[row_cnt].oe_field_id = osd.oe_field_id
   IF (osd.default_parent_entity_id > 0)
    details->details[row_cnt].field_value = cv.display
   ELSE
    IF (oefld.field_type_flag=7
     AND trim(osd.oe_field_display_value)="1")
     details->details[row_cnt].field_value = "Yes"
    ELSEIF (oefld.field_type_flag=7
     AND trim(osd.oe_field_display_value)="0")
     details->details[row_cnt].field_value = "No"
    ELSE
     details->details[row_cnt].field_value = osd.oe_field_display_value
    ENDIF
   ENDIF
  WITH nullreport, outerjoin = cv
 ;end select
 CALL text(text_row,2,concat("Building extract. ",build(order_sentence_count),
   " sentences to process..."))
 SET text_row = (text_row+ 1)
 SELECT INTO "asc_med_sent_extract.csv"
  primary_synonym = oc.primary_mnemonic, mnemonic_key_cap = ocs.mnemonic_key_cap, mnemonic_type = cv
  .display,
  mnemonic_type_cdf = cv.cdf_meaning, oef.oe_format_id, oef.oe_format_name,
  ocsr.order_sentence_id, script = ocsr.order_sentence_disp_line, os.usage_flag,
  order_cat_cki = oc.cki, synonym_cki = ocs.cki, os.external_identifier,
  comment = lt.long_text
  FROM ord_cat_sent_r ocsr,
   order_sentence os,
   order_catalog oc,
   code_value cv,
   order_catalog_synonym ocs,
   order_entry_format oef,
   long_text lt
  PLAN (ocsr)
   JOIN (os
   WHERE os.order_sentence_id=ocsr.order_sentence_id
    AND os.usage_flag IN (0, 1))
   JOIN (oc
   WHERE oc.catalog_cd=ocsr.catalog_cd
    AND oc.catalog_type_cd=cpharm
    AND oc.orderable_type_flag IN (0, 1)
    AND oc.active_ind=1)
   JOIN (ocs
   WHERE ocs.synonym_id=ocsr.synonym_id
    AND  NOT (ocs.mnemonic_type_cd IN (cmnem_type_z, cmnem_type_y))
    AND ocs.oe_format_id != cprim_rx
    AND ocs.oe_format_id > 0
    AND ocs.active_ind=1)
   JOIN (oef
   WHERE oef.oe_format_id=outerjoin(ocs.oe_format_id)
    AND oef.action_type_cd=outerjoin(corder))
   JOIN (lt
   WHERE outerjoin(os.ord_comment_long_text_id)=lt.long_text_id)
   JOIN (cv
   WHERE ocs.mnemonic_type_cd=cv.code_value)
  ORDER BY oef.oe_format_id, os.order_sentence_id
  HEAD REPORT
   os_cnt = 0, oef_cnt = 0, cur_field_match_found = 0,
   cur_sentence_pos = 0, cur_sentence_detail_count = 0, cur_sentence_details_found = 0,
   csv_line = concat("SYNONYM_ID,PRIMARY_SYNONYM,MNEMONIC_KEY_CAP,MNEMONIC_TYPE,",
    "MNEMONIC_TYPE_CDF,OEF,ORDER_SENTENCE_ID,SCRIPT,",
    "USAGE_FLAG,ORDER_CAT_CKI,SYNONYM_CKI,SEQUENCE,EXTERNAL_IDENTIFIER,")
   FOR (x = 1 TO size(used_fields->fields,5))
     csv_line = concat(csv_line,'"',"OE_FLD",trim(cnvtstring(x)),'"',
      ",",'"',"OE_FLD_VALUE",trim(cnvtstring(x)),'"',
      ",")
   ENDFOR
   csv_line = concat(csv_line,'"',"COMMENT",'"'), col 0, csv_line,
   row + 1, csv_line = ""
  HEAD oef.oe_format_id
   oef_cnt = (oef_cnt+ 1)
  HEAD ocsr.order_sentence_id
   os_cnt = (os_cnt+ 1), cur_sentence_pos = 0, cur_sentence_detail_count = 0,
   cur_sentence_details_found = 0, cur_field_match_found = 0, csv_line = ""
   IF (os_cnt > 1)
    row + 1
   ENDIF
   csv_line = concat('"',trim(cnvtstring(ocs.synonym_id)),'"',",",'"',
    trim(oc.primary_mnemonic),'"',",",'"',trim(ocs.mnemonic_key_cap),
    '"',",",'"',trim(cv.display),'"',
    ",",'"',trim(cv.cdf_meaning),'"',",",
    '"',trim(oef.oe_format_name),'"',",",'"',
    trim(cnvtstring(ocsr.order_sentence_id)),'"',",",'"',trim(ocsr.order_sentence_disp_line),
    '"',",",'"',trim(cnvtstring(os.usage_flag)),'"',
    ",",'"',trim(oc.cki),'"',",",
    '"',trim(ocs.cki),'"',",",'"',
    trim(cnvtstring(ocsr.display_seq)),'"',",",'"',trim(os.external_identifier),
    '"',","), cur_sentence_pos = find_sentence_pos(ocsr.order_sentence_id), cur_sentence_detail_count
    = count_sentence_details(cur_sentence_pos)
   FOR (y = 1 TO size(used_fields->fields,5))
     detail_text_value = "error", cur_field_match_found = 0, csv_line = concat(csv_line,'"',
      used_fields->fields[y].oe_field_meaning,'"',",")
     IF (cur_sentence_detail_count > 0)
      FOR (z = 1 TO cur_sentence_detail_count)
        IF (cur_sentence_details_found < cur_sentence_detail_count
         AND (used_fields->fields[y].oe_field_id=get_sentence_detail_type(((cur_sentence_pos+ z) - 1)
         ))
         AND cur_field_match_found=0)
         cur_sentence_details_found = (cur_sentence_details_found+ 1), detail_text_value = trim(build
          (get_sentence_detail_value(cnvtreal(((cur_sentence_pos+ z) - 1))))), csv_line = concat(
          csv_line,'"',detail_text_value,'"',","),
         cur_field_match_found = 1
        ENDIF
      ENDFOR
      IF ((used_fields->fields[y].oe_field_id=cprn)
       AND cur_field_match_found=0)
       csv_line = concat(csv_line,'"',"No",'"',",")
      ELSEIF (cur_field_match_found=0)
       csv_line = concat(csv_line,'"','"',",")
      ENDIF
     ENDIF
   ENDFOR
   csv_line = concat(csv_line,'"',trim(lt.long_text),'"'), col 0, csv_line
  FOOT REPORT
   CALL text(text_row,2,"Extract complete"), text_row = (text_row+ 1)
  WITH check, maxcol = 10000, format = variable,
   nullreport, noformfeed, landscape,
   maxrow = 1
 ;end select
#end_sent_extract
 IF (cerror_flag=1)
  CALL text(text_row,2,"Unable to locate required information. Extract aborted.")
  SET text_row = (text_row+ 1)
 ENDIF
 GO TO pharm_extract_mode
#asc_med_os_extract_exit
#asc_med_os_vv_extract
 SET text_row = 5
 CALL clear_screen(0)
 CALL text(5,2,"A file will be created in CCLUSERDIR called 'asc_med_sent_extract_vv.csv'")
 CALL text(7,2,"Begin? (Y/N)")
 CALL accept(7,17,"C;CU","Y"
  WHERE curaccept IN ("Y", "N"))
 CASE (curaccept)
  OF "Y":
   CALL show_processing(0)
  OF "N":
   GO TO pharm_extract_mode
 ENDCASE
 CALL show_processing(0)
 CALL text(text_row,2,"Beginning sentence extract...")
 SET text_row = (text_row+ 1)
 DECLARE get_sentence_detail_value(detail_pos=f8) = vc
 DECLARE csv_line = vc
 DECLARE text_result = vc
 DECLARE detail_text_value = vc
 SET order_sentence_count = 0
 SET cprim_rx = 0
 SET cprim_rx_cnt = 0
 SET cprn = 0
 SET cprn_cnt = 0
 SET cerror_flag = 0
 SET cdup_fields = 0
 FREE RECORD details
 RECORD details(
   1 details[*]
     2 os_id = f8
     2 oe_field_id = f8
     2 code_value = f8
     2 field_value = vc
 )
 FREE RECORD used_fields
 RECORD used_fields(
   1 fields[*]
     2 oe_field_id = f8
     2 oe_field_meaning = vc
 )
 SET stat = alterlist(used_fields->fields,18)
 SET used_fields->fields[1].oe_field_meaning = "STRENGTHDOSE"
 SET used_fields->fields[2].oe_field_meaning = "STRENGTHDOSEUNIT"
 SET used_fields->fields[3].oe_field_meaning = "VOLUMEDOSE"
 SET used_fields->fields[4].oe_field_meaning = "VOLUMEDOSEUNIT"
 SET used_fields->fields[5].oe_field_meaning = "FREETXTDOSE"
 SET used_fields->fields[6].oe_field_meaning = "RXROUTE"
 SET used_fields->fields[7].oe_field_meaning = "DRUGFORM"
 SET used_fields->fields[8].oe_field_meaning = "FREQ"
 SET used_fields->fields[9].oe_field_meaning = "RXPRIORITY"
 SET used_fields->fields[10].oe_field_meaning = "SCH/PRN"
 SET used_fields->fields[11].oe_field_meaning = "PRNREASON"
 SET used_fields->fields[12].oe_field_meaning = "FREETEXTRATE"
 SET used_fields->fields[13].oe_field_meaning = "RATE"
 SET used_fields->fields[14].oe_field_meaning = "RATEUNIT"
 SET used_fields->fields[15].oe_field_meaning = "INFUSEOVER"
 SET used_fields->fields[16].oe_field_meaning = "INFUSEOVERUNIT"
 SET used_fields->fields[17].oe_field_meaning = "DURATION"
 SET used_fields->fields[18].oe_field_meaning = "DURATIONUNIT"
 CALL text(text_row,2,"Looking up required code values...")
 SET text_row = (text_row+ 1)
 SET cpharm = uar_get_code_by("MEANING",6000,"PHARMACY")
 SET cmnem_type_z = uar_get_code_by("MEANING",6011,"TRADEPROD")
 SET cmnem_type_y = uar_get_code_by("MEANING",6011,"GENERICPROD")
 SET corder = uar_get_code_by("MEANING",6003,"ORDER")
 SELECT INTO "nl:"
  oef.oe_format_id
  FROM order_entry_format oef
  WHERE cnvtupper(oef.oe_format_name)="PRIMARY PHARMACY"
   AND oef.action_type_cd=corder
  DETAIL
   cprim_rx = oef.oe_format_id, cprim_rx_cnt = (cprim_rx_cnt+ 1)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  oef.oe_field_id
  FROM order_entry_fields oef,
   oe_field_meaning ofm
  WHERE oef.oe_field_meaning_id=ofm.oe_field_meaning_id
   AND ofm.oe_field_meaning="SCH/PRN"
  DETAIL
   cprn = oef.oe_field_id, cprn_cnt = (cprn_cnt+ 1)
  WITH nocounter
 ;end select
 IF (((cprn_cnt != 1) OR (((cprim_rx_cnt != 1) OR (((cpharm=0) OR (((cmnem_type_z=0) OR (((
 cmnem_type_y=0) OR (corder=0)) )) )) )) )) )
  SET cerror_flag = 1
  GO TO end_sent_vv_extract
 ENDIF
 CALL text(text_row,2,"Identifying order entry fields used in medication sentences...")
 SET text_row = (text_row+ 1)
 SELECT DISTINCT INTO "nl:"
  osd.oe_field_id, ofm.oe_field_meaning
  FROM ord_cat_sent_r ocsr,
   order_sentence os,
   order_catalog oc,
   order_catalog_synonym ocs,
   order_sentence_detail osd,
   oe_field_meaning ofm,
   ocs_facility_r ofr,
   filter_entity_reltn fer
  WHERE os.order_sentence_id=ocsr.order_sentence_id
   AND os.usage_flag IN (0, 1)
   AND oc.catalog_cd=ocsr.catalog_cd
   AND oc.catalog_type_cd=cpharm
   AND oc.orderable_type_flag IN (0, 1)
   AND ocs.synonym_id=ocsr.synonym_id
   AND  NOT (ocs.mnemonic_type_cd IN (cmnem_type_z, cmnem_type_y))
   AND ocs.oe_format_id != cprim_rx
   AND ocs.oe_format_id > 0
   AND osd.order_sentence_id=ocsr.order_sentence_id
   AND osd.oe_field_meaning_id=ofm.oe_field_meaning_id
   AND ofm.oe_field_meaning != "OTHER"
   AND ocs.synonym_id=ofr.synonym_id
   AND ((ofr.facility_cd=0) OR (ofr.facility_cd=cur_facility_cd))
   AND ((ocs.hide_flag=null) OR (ocs.hide_flag=0))
   AND fer.parent_entity_id=os.order_sentence_id
   AND ((fer.filter_entity1_id=0) OR (fer.filter_entity1_id=cur_facility_cd))
   AND fer.parent_entity_name="ORDER_SENTENCE"
   AND fer.filter_entity1_name="LOCATION"
   AND ocs.mnemonic_type_cd IN (
  (SELECT
   code_value
   FROM code_value
   WHERE code_set=6011
    AND cdf_meaning IN ("BRANDNAME", "DCP", "DISPDRUG", "GENERICTOP", "IVNAME",
   "PRIMARY", "TRADETOP")))
  ORDER BY osd.oe_field_id
  HEAD REPORT
   row_cnt = 19, array_loc = 1
  HEAD osd.oe_field_id
   array_loc = 0
   CASE (trim(ofm.oe_field_meaning))
    OF "STRENGTHDOSE":
     array_loc = 1
    OF "STRENGTHDOSEUNIT":
     array_loc = 2
    OF "VOLUMEDOSE":
     array_loc = 3
    OF "VOLUMEDOSEUNIT":
     array_loc = 4
    OF "FREETXTDOSE":
     array_loc = 5
    OF "RXROUTE":
     array_loc = 6
    OF "DRUGFORM":
     array_loc = 7
    OF "FREQ":
     array_loc = 8
    OF "RXPRIORITY":
     array_loc = 9
    OF "SCH/PRN":
     array_loc = 10
    OF "PRNREASON":
     array_loc = 11
    OF "FREETEXTRATE":
     array_loc = 12
    OF "RATE":
     array_loc = 13
    OF "RATEUNIT":
     array_loc = 14
    OF "INFUSEOVER":
     array_loc = 15
    OF "INFUSEOVERUNIT":
     array_loc = 16
    OF "DURATION":
     array_loc = 17
    OF "DURATIONUNIT":
     array_loc = 18
    ELSE
     array_loc = row_cnt,stat = alterlist(used_fields->fields,row_cnt),row_cnt = (row_cnt+ 1)
   ENDCASE
   IF ((used_fields->fields[array_loc].oe_field_id > 0))
    cdup_fields = 1, text_row = (text_row+ 1),
    CALL text(text_row,2,build("Warning!! ...duplicate fields in use for field meaning=",ofm
     .oe_field_meaning)),
    text_row = (text_row+ 1),
    CALL text(text_row,2,"Extracted values for this field may be unpredictable"), text_row = (
    text_row+ 1)
   ENDIF
   used_fields->fields[array_loc].oe_field_id = osd.oe_field_id, used_fields->fields[array_loc].
   oe_field_meaning = ofm.oe_field_meaning
  WITH nullreport
 ;end select
 CALL text(text_row,2,"Generating index of medication order sentence details...")
 SET text_row = (text_row+ 1)
 SELECT INTO "nl:"
  os.order_sentence_id, osd.oe_field_id, code_value = osd.default_parent_entity_id,
  osd.oe_field_value, osd.oe_field_display_value, code_value_display = cv.display,
  oefld.field_type_flag
  FROM ord_cat_sent_r ocsr,
   order_sentence os,
   order_catalog oc,
   code_value cv,
   order_catalog_synonym ocs,
   order_entry_format oef,
   order_sentence_detail osd,
   order_entry_fields oefld,
   ocs_facility_r ofr,
   filter_entity_reltn fer
  PLAN (ocsr)
   JOIN (os
   WHERE os.order_sentence_id=ocsr.order_sentence_id
    AND os.usage_flag IN (0, 1))
   JOIN (fer
   WHERE fer.parent_entity_id=os.order_sentence_id
    AND ((fer.filter_entity1_id=0) OR (fer.filter_entity1_id=cur_facility_cd))
    AND fer.parent_entity_name="ORDER_SENTENCE"
    AND fer.filter_entity1_name="LOCATION")
   JOIN (oc
   WHERE oc.catalog_cd=ocsr.catalog_cd
    AND oc.catalog_type_cd=cpharm
    AND oc.orderable_type_flag IN (0, 1))
   JOIN (ocs
   WHERE ocs.synonym_id=ocsr.synonym_id
    AND  NOT (ocs.mnemonic_type_cd IN (cmnem_type_z, cmnem_type_y))
    AND ocs.oe_format_id != cprim_rx
    AND ocs.oe_format_id > 0
    AND ((ocs.hide_flag=null) OR (ocs.hide_flag=0))
    AND ocs.mnemonic_type_cd IN (
   (SELECT
    code_value
    FROM code_value
    WHERE code_set=6011
     AND cdf_meaning IN ("BRANDNAME", "DCP", "DISPDRUG", "GENERICTOP", "IVNAME",
    "PRIMARY", "TRADETOP"))))
   JOIN (ofr
   WHERE ofr.synonym_id=ocs.synonym_id
    AND ((ofr.facility_cd=0) OR (ofr.facility_cd=cur_facility_cd)) )
   JOIN (oef
   WHERE oef.oe_format_id=outerjoin(ocs.oe_format_id)
    AND oef.action_type_cd=outerjoin(corder))
   JOIN (osd
   WHERE osd.order_sentence_id=ocsr.order_sentence_id)
   JOIN (oefld
   WHERE oefld.oe_field_id=osd.oe_field_id)
   JOIN (cv
   WHERE osd.default_parent_entity_id=cv.code_value)
  ORDER BY os.order_sentence_id, osd.oe_field_id
  HEAD REPORT
   row_cnt = 0
  HEAD os.order_sentence_id
   order_sentence_count = (order_sentence_count+ 1)
  DETAIL
   row_cnt = (row_cnt+ 1), stat = alterlist(details->details,row_cnt), details->details[row_cnt].
   os_id = os.order_sentence_id,
   details->details[row_cnt].oe_field_id = osd.oe_field_id
   IF (osd.default_parent_entity_id > 0)
    details->details[row_cnt].field_value = cv.display
   ELSE
    IF (oefld.field_type_flag=7
     AND trim(osd.oe_field_display_value)="1")
     details->details[row_cnt].field_value = "Yes"
    ELSEIF (oefld.field_type_flag=7
     AND trim(osd.oe_field_display_value)="0")
     details->details[row_cnt].field_value = "No"
    ELSE
     details->details[row_cnt].field_value = osd.oe_field_display_value
    ENDIF
   ENDIF
  WITH nullreport, outerjoin = cv
 ;end select
 CALL text(text_row,2,concat("Building extract. ",build(order_sentence_count),
   " sentences to process..."))
 SET text_row = (text_row+ 1)
 SELECT INTO "asc_med_sent_extract_vv.csv"
  primary_synonym = oc.primary_mnemonic, mnemonic_key_cap = ocs.mnemonic_key_cap, mnemonic_type = cv
  .display,
  mnemonic_type_cdf = cv.cdf_meaning, oef.oe_format_id, oef.oe_format_name,
  ocsr.order_sentence_id, script = ocsr.order_sentence_disp_line, os.usage_flag,
  order_cat_cki = oc.cki, synonym_cki = ocs.cki, os.external_identifier,
  comment = lt.long_text
  FROM ord_cat_sent_r ocsr,
   order_sentence os,
   order_catalog oc,
   ocs_facility_r ofr,
   filter_entity_reltn fer,
   code_value cv,
   order_catalog_synonym ocs,
   order_entry_format oef,
   long_text lt
  PLAN (ocsr)
   JOIN (os
   WHERE os.order_sentence_id=ocsr.order_sentence_id
    AND os.usage_flag IN (0, 1))
   JOIN (fer
   WHERE fer.parent_entity_id=os.order_sentence_id
    AND ((fer.filter_entity1_id=0) OR (fer.filter_entity1_id=cur_facility_cd))
    AND fer.parent_entity_name="ORDER_SENTENCE"
    AND fer.filter_entity1_name="LOCATION")
   JOIN (oc
   WHERE oc.catalog_cd=ocsr.catalog_cd
    AND oc.catalog_type_cd=cpharm
    AND oc.orderable_type_flag IN (0, 1)
    AND oc.active_ind=1)
   JOIN (ocs
   WHERE ocs.synonym_id=ocsr.synonym_id
    AND  NOT (ocs.mnemonic_type_cd IN (cmnem_type_z, cmnem_type_y))
    AND ocs.oe_format_id != cprim_rx
    AND ocs.oe_format_id > 0
    AND ocs.active_ind=1
    AND ((ocs.hide_flag=null) OR (ocs.hide_flag=0))
    AND ocs.mnemonic_type_cd IN (
   (SELECT
    code_value
    FROM code_value
    WHERE code_set=6011
     AND cdf_meaning IN ("BRANDNAME", "DCP", "DISPDRUG", "GENERICTOP", "IVNAME",
    "PRIMARY", "TRADETOP"))))
   JOIN (ofr
   WHERE ofr.synonym_id=ocs.synonym_id
    AND ((ofr.facility_cd=0) OR (ofr.facility_cd=cur_facility_cd)) )
   JOIN (oef
   WHERE oef.oe_format_id=outerjoin(ocs.oe_format_id)
    AND oef.action_type_cd=outerjoin(corder))
   JOIN (lt
   WHERE outerjoin(os.ord_comment_long_text_id)=lt.long_text_id)
   JOIN (cv
   WHERE ocs.mnemonic_type_cd=cv.code_value)
  ORDER BY oef.oe_format_id, os.order_sentence_id
  HEAD REPORT
   os_cnt = 0, oef_cnt = 0, cur_field_match_found = 0,
   cur_sentence_pos = 0, cur_sentence_detail_count = 0, cur_sentence_details_found = 0,
   csv_line = concat("SYNONYM_ID,PRIMARY_SYNONYM,MNEMONIC_KEY_CAP,MNEMONIC_TYPE,",
    "MNEMONIC_TYPE_CDF,OEF,ORDER_SENTENCE_ID,SCRIPT,",
    "USAGE_FLAG,ORDER_CAT_CKI,SYNONYM_CKI,SEQUENCE,EXTERNAL_IDENTIFIER,")
   FOR (x = 1 TO size(used_fields->fields,5))
     csv_line = concat(csv_line,'"',"OE_FLD",trim(cnvtstring(x)),'"',
      ",",'"',"OE_FLD_VALUE",trim(cnvtstring(x)),'"',
      ",")
   ENDFOR
   csv_line = concat(csv_line,'"',"COMMENT",'"'), col 0, csv_line,
   row + 1, csv_line = ""
  HEAD oef.oe_format_id
   oef_cnt = (oef_cnt+ 1)
  HEAD ocsr.order_sentence_id
   os_cnt = (os_cnt+ 1), cur_sentence_pos = 0, cur_sentence_detail_count = 0,
   cur_sentence_details_found = 0, cur_field_match_found = 0, csv_line = ""
   IF (os_cnt > 1)
    row + 1
   ENDIF
   csv_line = concat('"',trim(cnvtstring(ocs.synonym_id)),'"',",",'"',
    trim(oc.primary_mnemonic),'"',",",'"',trim(ocs.mnemonic_key_cap),
    '"',",",'"',trim(cv.display),'"',
    ",",'"',trim(cv.cdf_meaning),'"',",",
    '"',trim(oef.oe_format_name),'"',",",'"',
    trim(cnvtstring(ocsr.order_sentence_id)),'"',",",'"',trim(ocsr.order_sentence_disp_line),
    '"',",",'"',trim(cnvtstring(os.usage_flag)),'"',
    ",",'"',trim(oc.cki),'"',",",
    '"',trim(ocs.cki),'"',",",'"',
    trim(cnvtstring(ocsr.display_seq)),'"',",",'"',trim(os.external_identifier),
    '"',","), cur_sentence_pos = find_sentence_pos(ocsr.order_sentence_id), cur_sentence_detail_count
    = count_sentence_details(cur_sentence_pos)
   FOR (y = 1 TO size(used_fields->fields,5))
     detail_text_value = "error", cur_field_match_found = 0, csv_line = concat(csv_line,'"',
      used_fields->fields[y].oe_field_meaning,'"',",")
     IF (cur_sentence_detail_count > 0)
      FOR (z = 1 TO cur_sentence_detail_count)
        IF (cur_sentence_details_found < cur_sentence_detail_count
         AND (used_fields->fields[y].oe_field_id=get_sentence_detail_type(((cur_sentence_pos+ z) - 1)
         ))
         AND cur_field_match_found=0)
         cur_sentence_details_found = (cur_sentence_details_found+ 1), detail_text_value = trim(build
          (get_sentence_detail_value(cnvtreal(((cur_sentence_pos+ z) - 1))))), csv_line = concat(
          csv_line,'"',detail_text_value,'"',","),
         cur_field_match_found = 1
        ENDIF
      ENDFOR
      IF ((used_fields->fields[y].oe_field_id=cprn)
       AND cur_field_match_found=0)
       csv_line = concat(csv_line,'"',"No",'"',",")
      ELSEIF (cur_field_match_found=0)
       csv_line = concat(csv_line,'"','"',",")
      ENDIF
     ENDIF
   ENDFOR
   csv_line = concat(csv_line,'"',trim(lt.long_text),'"'), col 0, csv_line
  FOOT REPORT
   CALL text(text_row,2,"Extract complete"), text_row = (text_row+ 1)
  WITH check, maxcol = 10000, format = variable,
   nullreport, noformfeed, landscape,
   maxrow = 1
 ;end select
#end_sent_vv_extract
 IF (cerror_flag=1)
  CALL text(text_row,2,"Unable to locate required information. Extract aborted.")
  SET text_row = (text_row+ 1)
 ENDIF
 GO TO pharm_extract_mode
#asc_med_os_vv_extract_exit
#asc_aps_avs_audit
 CALL clear_screen(0)
 IF (validate(isodbc,0)=0)
  EXECUTE cclseclogin
 ENDIF
 CALL show_processing(0)
 SET msg = fillstring(2000," ")
 SET starline = fillstring(50,"*")
 SELECT
  FROM rx_auto_verify_audit mydesc,
   rx_auto_verify_ing_audit mying,
   orders o,
   prsnl p,
   prsnl p2,
   rx_product_assign_audit myproddesc,
   rx_product_assign_group_audit mygroup,
   rx_product_assign_item_audit myitem
  PLAN (mydesc
   WHERE mydesc.order_id > 0)
   JOIN (mying
   WHERE mydesc.rx_auto_verify_audit_id=mying.rx_auto_verify_audit_id)
   JOIN (o
   WHERE mydesc.order_id=o.order_id)
   JOIN (p
   WHERE mydesc.order_provider_id=p.person_id)
   JOIN (p2
   WHERE mydesc.action_personnel_id=p2.person_id)
   JOIN (myitem
   WHERE myitem.catalog_group_id=mydesc.catalog_group_id)
   JOIN (mygroup
   WHERE mygroup.catalog_group_id=myitem.catalog_group_id)
   JOIN (myproddesc
   WHERE myproddesc.catalog_group_id=myitem.catalog_group_id)
  ORDER BY mydesc.rx_auto_verify_audit_id DESC
  HEAD REPORT
   row + 1, col 0, "AUTO VERIFY AUDIT",
   row + 1
  HEAD mydesc.order_id
   row + 2, col 0, starline,
   row + 1, msg = concat("Order Id: ",trim(cnvtstring(mydesc.order_id))), col 1,
   msg, col 27, mydesc.updt_dt_tm"mm/dd/yy hh:mm:ss",
   row + 1, col 5, "Orderable:",
   msg = concat(trim(uar_get_code_display(o.catalog_cd)),"  (",trim(cnvtstring(o.catalog_cd)),")"),
   col 27, msg,
   row + 1, col 5, "Ordering Provider:"
   CASE (cnvtstring(mydesc.order_provider_av_priv_flag))
    OF "0":
     a = " (AV Priv Not Set)"
    OF "1":
     a = " (AV Priv On)"
    OF "2":
     a = " (Av Priv Off)"
    ELSE
     a = " ()"
   ENDCASE
   msg = concat(trim(p.name_full_formatted)," *",trim(uar_get_code_display(p.position_cd)),"*",a),
   col 27, msg,
   row + 1, col 5, "Ordering User:"
   CASE (cnvtstring(mydesc.prsnl_auto_verify_priv_flag))
    OF "0":
     a = " (AV Priv Not Set)"
    OF "1":
     a = " (AV Priv On)"
    OF "2":
     a = " (AV Priv Off)"
    ELSE
     a = " ()"
   ENDCASE
   msg = concat(trim(p2.name_full_formatted)," *",trim(uar_get_code_display(p2.position_cd)),"*",a),
   col 27, msg,
   row + 1, col 5, "Communication Type:",
   msg = trim(uar_get_code_display(mydesc.communication_type_cd)), col 27, msg,
   row + 1, col 1, "Verification Status Message(s):",
   row + 1
  HEAD mydesc.status_string
   col 5, mydesc.status_string, row + 1
  HEAD mying.rx_auto_verify_ing_audit_id
   i = 0
  HEAD mygroup.catalog_group_id
   row + 1, col 1, "Order Details:",
   row + 1, col 5, "Strength:",
   strengthunit = uar_get_code_display(myitem.strength_unit_cd), msg = concat(trim(cnvtstring(myitem
      .strength))," ",strengthunit), col 21,
   msg, col 45, "Volume:",
   volumeunit = uar_get_code_display(myitem.volume_unit_cd), msg = concat(trim(cnvtstring(myitem
      .volume))," ",volumeunit), col 59,
   msg, row + 1, col 5,
   "Route:", route = uar_get_code_display(mygroup.route_cd), col 21,
   route, col 45, "Form:",
   form = uar_get_code_display(mygroup.form_cd), col 59, form,
   row + 1, col 5, "Facility:",
   facility = uar_get_code_display(mygroup.facility_cd), col 21, facility,
   col 45, "Patient Locn:", patientlocn = uar_get_code_display(mygroup.pat_locn_cd),
   col 59, patientlocn, row + 1,
   col 5, "Encounter Type:", encounter = uar_get_code_display(mygroup.encntr_type_cd),
   col 21, encounter, row + 1,
   col 1, "Assignment Status Message(s):"
  HEAD myproddesc.status_message
   row + 1, col 5, myproddesc.status_message
  FOOT REPORT
   row + 2
  WITH nocounter, maxcol = 2100
 ;end select
 GO TO pharm_data_lookup_mode
#asc_aps_avs_audit_exit
#asc_assign_rxmnem_oef
 CALL show_processing(0)
 CALL clear_screen(0)
 SET cpharm = uar_get_code_by("MEANING",6000,"PHARMACY")
 SET cprimary = uar_get_code_by("MEANING",6011,"PRIMARY")
 SET csystem = uar_get_code_by("MEANING",4062,"SYSTEM")
 SET csyspkgtyp = uar_get_code_by("MEANING",4062,"SYSPKGTYP")
 SET corderable = uar_get_code_by("MEANING",4063,"ORDERABLE")
 SET cinpatient = uar_get_code_by("MEANING",4500,"INPATIENT")
 SET cdesc = uar_get_code_by("MEANING",11000,"DESC")
 SET corder = uar_get_code_by("MEANING",6003,"ORDER")
 SET crxm = uar_get_code_by("MEANING",6011,"RXMNEMONIC")
 FREE RECORD available_products
 RECORD available_products(
   1 products[*]
     2 item_id = f8
     2 catalog_cd = f8
     2 synonym_id = f8
 )
 SELECT INTO "nl:"
  md.item_id, product_desc = substring(1,50,mi.value), mfoi.*
  FROM medication_definition md,
   order_catalog_item_r ocir,
   item_definition id,
   med_def_flex mdf,
   med_flex_object_idx mfoi,
   med_identifier mi
  PLAN (md)
   JOIN (ocir
   WHERE ocir.item_id=md.item_id)
   JOIN (id
   WHERE id.item_id=ocir.item_id
    AND id.active_ind=1)
   JOIN (mdf
   WHERE mdf.item_id=md.item_id
    AND mdf.flex_type_cd=csyspkgtyp
    AND mdf.pharmacy_type_cd=cinpatient)
   JOIN (mfoi
   WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
    AND mfoi.flex_object_type_cd=corderable
    AND ((mfoi.parent_entity_id=0) OR (mfoi.parent_entity_id=cur_facility_cd)) )
   JOIN (mi
   WHERE mi.item_id=md.item_id
    AND mi.active_ind=1
    AND mi.primary_ind=1
    AND mi.med_product_id=0
    AND mi.med_identifier_type_cd=cdesc
    AND mi.pharmacy_type_cd=cinpatient)
  ORDER BY mi.value
  HEAD REPORT
   cnt = 0
  HEAD md.item_id
   cnt = (cnt+ 1), stat = alterlist(available_products->products,cnt), available_products->products[
   cnt].item_id = md.item_id,
   available_products->products[cnt].synonym_id = ocir.synonym_id, available_products->products[cnt].
   catalog_cd = ocir.catalog_cd
  WITH nullreport
 ;end select
 CALL text(5,1,"Do you wish to remove existing RX Mnemonic OEF's for ALL med products? (Y/N) ")
 CALL accept(5,79,"C;CU","N"
  WHERE cnvtupper(curaccept) IN ("Y", "N"))
 CASE (curaccept)
  OF "Y":
   CALL show_processing(0)
   UPDATE  FROM (dummyt d  WITH seq = value(size(available_products->products,5))),
     order_catalog_synonym ocs
    SET ocs.oe_format_id = 0, ocs.updt_task = - (2516)
    PLAN (d)
     JOIN (ocs
     WHERE (ocs.synonym_id=available_products->products[d.seq].synonym_id)
      AND ocs.catalog_type_cd=cpharm
      AND ocs.mnemonic_type_cd=crxm)
    WITH nocounter
   ;end update
   COMMIT
  OF "N":
   CALL clear_screen(0)
 ENDCASE
 CALL show_processing(0)
 CALL clear_screen(0)
 CALL text(5,1,"Do you wish to set missing OEF's for RX Mnemonics, based on RX Masks? (Y/N) ")
 CALL accept(5,78,"C;CU","Y"
  WHERE cnvtupper(curaccept) IN ("Y", "N"))
 CASE (curaccept)
  OF "Y":
   CALL show_processing(0)
   SET cstr_oef = 0
   SET cvol_oef = 0
   SET civ_oef = 0
   SELECT INTO "nl:"
    oe.oe_format_id
    FROM order_entry_format oe
    WHERE oe.oe_format_name="Pharmacy Strength Med"
     AND oe.action_type_cd=corder
    DETAIL
     cstr_oef = oe.oe_format_id
    WITH nocounter, noheading, maxrec = 10
   ;end select
   SELECT INTO "nl:"
    oe.oe_format_id
    FROM order_entry_format oe
    WHERE oe.oe_format_name="Pharmacy Volume Med"
     AND oe.action_type_cd=corder
    DETAIL
     cvol_oef = oe.oe_format_id
    WITH nocounter, noheading, maxrec = 10
   ;end select
   SELECT INTO "nl:"
    oe.oe_format_id
    FROM order_entry_format oe
    WHERE oe.oe_format_name="Pharmacy IV"
     AND oe.action_type_cd=corder
    DETAIL
     civ_oef = oe.oe_format_id
    WITH nocounter, noheading, maxrec = 10
   ;end select
   IF (((cvol_oef=0) OR (((civ_oef=0) OR (cstr_oef=0)) )) )
    CALL text(7,1,"Unable to locate one or more standard Rx Order Entry Formats")
   ELSE
    FREE RECORD rxm_oefs
    RECORD rxm_oefs(
      1 iv_rxm[*]
        2 synonym_id = f8
        2 oef = f8
      1 str_rxm[*]
        2 synonym_id = f8
        2 oef = f8
      1 vol_rxm[*]
        2 synonym_id = f8
        2 oef = f8
    )
    CALL text(7,1,"Looking for IV format synonyms...")
    SELECT INTO "nl:"
     ocs.synonym_id
     FROM med_dispense mi,
      order_catalog_synonym ocs,
      order_catalog_item_r ocir,
      med_def_flex mdf,
      med_flex_object_idx mfoi
     WHERE ocs.catalog_type_cd=cpharm
      AND ocs.mnemonic_type_cd=crxm
      AND ocs.item_id > 0
      AND ocs.rx_mask=1
      AND ocs.oe_format_id=0
      AND ocs.synonym_id=ocir.synonym_id
      AND mi.item_id=ocir.item_id
      AND mdf.item_id=ocir.item_id
      AND mdf.flex_type_cd=csyspkgtyp
      AND mdf.pharmacy_type_cd=cinpatient
      AND mfoi.med_def_flex_id=mdf.med_def_flex_id
      AND mfoi.flex_object_type_cd=corderable
      AND ((mfoi.parent_entity_id=0) OR (mfoi.parent_entity_id=cur_facility_cd))
     HEAD REPORT
      cnt = 0
     DETAIL
      cnt = (cnt+ 1), stat = alterlist(rxm_oefs->iv_rxm,cnt), rxm_oefs->iv_rxm[cnt].synonym_id = ocs
      .synonym_id,
      rxm_oefs->iv_rxm[cnt].oef = civ_oef
     WITH nullreport
    ;end select
    CALL text(8,1,"Updating database...")
    UPDATE  FROM (dummyt d  WITH seq = value(size(rxm_oefs->iv_rxm,5))),
      order_catalog_synonym ocs
     SET ocs.oe_format_id = rxm_oefs->iv_rxm[d.seq].oef, ocs.updt_task = - (2516), ocs.updt_dt_tm =
      cnvtdatetime(curdate,curtime3)
     PLAN (d)
      JOIN (ocs
      WHERE ocs.synonym_id > 0
       AND (ocs.synonym_id=rxm_oefs->iv_rxm[d.seq].synonym_id))
     WITH nocounter
    ;end update
    CALL text(10,1,"Looking for strength format synonyms...")
    SELECT INTO "nl:"
     ocs.synonym_id
     FROM med_dispense mi,
      order_catalog_synonym ocs,
      order_catalog_item_r ocir,
      med_def_flex mdf,
      med_flex_object_idx mfoi
     WHERE ocs.catalog_type_cd=cpharm
      AND ocs.mnemonic_type_cd=crxm
      AND ocs.oe_format_id=0
      AND ocs.rx_mask > 1
      AND ocs.synonym_id=ocir.synonym_id
      AND mi.item_id=ocir.item_id
      AND mi.item_id > 0
      AND mi.strength != 0
      AND mi.strength_unit_cd != 0
      AND mdf.item_id=ocir.item_id
      AND mdf.flex_type_cd=csyspkgtyp
      AND mdf.pharmacy_type_cd=cinpatient
      AND mfoi.med_def_flex_id=mdf.med_def_flex_id
      AND mfoi.flex_object_type_cd=corderable
      AND ((mfoi.parent_entity_id=0) OR (mfoi.parent_entity_id=cur_facility_cd))
     HEAD REPORT
      cnt = 0
     DETAIL
      cnt = (cnt+ 1), stat = alterlist(rxm_oefs->str_rxm,cnt), rxm_oefs->str_rxm[cnt].synonym_id =
      ocs.synonym_id,
      rxm_oefs->str_rxm[cnt].oef = cstr_oef
     WITH nullreport
    ;end select
    CALL text(11,1,"Updating database...")
    UPDATE  FROM (dummyt d  WITH seq = value(size(rxm_oefs->str_rxm,5))),
      order_catalog_synonym ocs
     SET ocs.oe_format_id = rxm_oefs->str_rxm[d.seq].oef, ocs.updt_task = - (2516), ocs.updt_dt_tm =
      cnvtdatetime(curdate,curtime3)
     PLAN (d)
      JOIN (ocs
      WHERE ocs.synonym_id > 0
       AND (ocs.synonym_id=rxm_oefs->str_rxm[d.seq].synonym_id))
     WITH nocounter
    ;end update
    CALL text(13,1,"Looking for volume format synonyms...")
    SELECT INTO "nl:"
     ocs.synonym_id
     FROM med_dispense mi,
      order_catalog_synonym ocs,
      order_catalog_item_r ocir,
      med_def_flex mdf,
      med_flex_object_idx mfoi
     WHERE ocs.catalog_type_cd=cpharm
      AND ocs.mnemonic_type_cd=crxm
      AND ocs.oe_format_id=0
      AND ocs.rx_mask > 1
      AND ocs.synonym_id=ocir.synonym_id
      AND mi.item_id=ocir.item_id
      AND mi.item_id > 0
      AND mi.strength=0
      AND mi.strength_unit_cd=0
      AND mdf.item_id=ocir.item_id
      AND mdf.flex_type_cd=csyspkgtyp
      AND mdf.pharmacy_type_cd=cinpatient
      AND mfoi.med_def_flex_id=mdf.med_def_flex_id
      AND mfoi.flex_object_type_cd=corderable
      AND ((mfoi.parent_entity_id=0) OR (mfoi.parent_entity_id=cur_facility_cd))
     HEAD REPORT
      cnt = 0
     DETAIL
      cnt = (cnt+ 1), stat = alterlist(rxm_oefs->vol_rxm,cnt), rxm_oefs->vol_rxm[cnt].synonym_id =
      ocs.synonym_id,
      rxm_oefs->vol_rxm[cnt].oef = cvol_oef
     WITH nullreport
    ;end select
    CALL text(14,1,"Updating database")
    UPDATE  FROM (dummyt d  WITH seq = value(size(rxm_oefs->vol_rxm,5))),
      order_catalog_synonym ocs
     SET ocs.oe_format_id = rxm_oefs->vol_rxm[d.seq].oef, ocs.updt_task = - (2516), ocs.updt_dt_tm =
      cnvtdatetime(curdate,curtime3)
     PLAN (d)
      JOIN (ocs
      WHERE ocs.synonym_id > 0
       AND (ocs.synonym_id=rxm_oefs->vol_rxm[d.seq].synonym_id))
     WITH nocounter
    ;end update
    CALL text(16,1,"Updates complete")
    COMMIT
    FREE RECORD rxm_oefs
   ENDIF
  OF "N":
   GO TO pharm_utilities_mode
 ENDCASE
#asc_assign_rxmnem_oef_exit
#asc_set_med_clincat_cds
 CALL clear_screen(0)
 SET cpharm = uar_get_code_by("MEANING",6000,"PHARMACY")
 SET cprimary = uar_get_code_by("MEANING",6011,"PRIMARY")
 SET civsol = uar_get_code_by("MEANING",16389,"IVSOLUTIONS")
 SET cmeds = uar_get_code_by("MEANING",16389,"MEDICATIONS")
 CALL clear_screen(0)
 CALL text(5,1,"Do you wish to remove existing clinical category data for ALL medications (Y/N)  ")
 CALL accept(5,83,"C;CU","n"
  WHERE cnvtupper(curaccept) IN ("Y", "N"))
 SET response1 = curaccept
 CALL text(7,1,
  "Are you sure you wish to set missing clinical category codes for ALL medications (Y/N)  ")
 CALL accept(7,90,"C;CU","Y"
  WHERE cnvtupper(curaccept) IN ("Y", "N"))
 SET response2 = curaccept
 IF (cnvtupper(trim(response1)) != "Y")
  GO TO asc_set_med_clincat_cds_2
 ENDIF
 CALL show_processing(0)
 UPDATE  FROM order_catalog
  SET dcp_clin_cat_cd = 0, updt_task = - (2516)
  WHERE catalog_type_cd=cpharm
 ;end update
 UPDATE  FROM order_catalog_synonym
  SET dcp_clin_cat_cd = 0, updt_task = - (2516)
  WHERE catalog_type_cd=cpharm
 ;end update
#asc_set_med_clincat_cds_2
 IF (cnvtupper(trim(response2))="Y")
  GO TO asc_set_med_clincat_cds_3
 ELSE
  GO TO pharm_utilities_mode
 ENDIF
#asc_set_med_clincat_cds_3
 CALL show_processing(0)
 UPDATE  FROM order_catalog
  SET dcp_clin_cat_cd = civsol, updt_task = - (2516)
  WHERE dcp_clin_cat_cd=0
   AND orderable_type_flag IN (0, 1)
   AND catalog_type_cd=cpharm
   AND catalog_cd IN (
  (SELECT
   catalog_cd
   FROM order_catalog_synonym
   WHERE catalog_type_cd=cpharm
    AND mnemonic_type_cd=cprimary
    AND rx_mask=1))
 ;end update
 UPDATE  FROM order_catalog_synonym
  SET dcp_clin_cat_cd = civsol, updt_task = - (2516)
  WHERE dcp_clin_cat_cd=0
   AND catalog_type_cd=cpharm
   AND catalog_cd IN (
  (SELECT
   catalog_cd
   FROM order_catalog
   WHERE catalog_type_cd=cpharm
    AND orderable_type_flag IN (0, 1)
    AND dcp_clin_cat_cd=civsol))
 ;end update
 UPDATE  FROM order_catalog
  SET dcp_clin_cat_cd = cmeds, updt_task = - (2516)
  WHERE dcp_clin_cat_cd=0
   AND orderable_type_flag IN (0, 1)
   AND catalog_type_cd=cpharm
   AND catalog_cd IN (
  (SELECT
   catalog_cd
   FROM order_catalog_synonym
   WHERE catalog_type_cd=cpharm
    AND mnemonic_type_cd=cprimary
    AND rx_mask > 1))
 ;end update
 UPDATE  FROM order_catalog_synonym
  SET dcp_clin_cat_cd = cmeds, updt_task = - (2516)
  WHERE dcp_clin_cat_cd=0
   AND catalog_type_cd=cpharm
   AND catalog_cd IN (
  (SELECT
   catalog_cd
   FROM order_catalog
   WHERE catalog_type_cd=cpharm
    AND orderable_type_flag IN (0, 1)
    AND dcp_clin_cat_cd=cmeds))
 ;end update
 UPDATE  FROM order_catalog
  SET dcp_clin_cat_cd = civsol, updt_task = - (2516)
  WHERE dcp_clin_cat_cd=0
   AND orderable_type_flag=8
   AND catalog_type_cd=cpharm
 ;end update
 UPDATE  FROM order_catalog_synonym
  SET dcp_clin_cat_cd = civsol, updt_task = - (2516)
  WHERE dcp_clin_cat_cd=0
   AND catalog_type_cd=cpharm
   AND catalog_cd IN (
  (SELECT
   catalog_cd
   FROM order_catalog
   WHERE catalog_type_cd=cpharm
    AND orderable_type_flag=8))
 ;end update
 CALL clear_screen(0)
 CALL text(5,1,"Update completed. Commit changes?")
 CALL accept(5,39,"C;CU","Y"
  WHERE curaccept IN ("Y", "N"))
 CASE (curaccept)
  OF "Y":
   COMMIT
  OF "N":
   ROLLBACK
 ENDCASE
 GO TO pharm_utilities_mode
#asc_set_med_clincat_cds_exit
#syn_no_sent
 CALL show_processing(0)
 FREE RECORD syn_w_sent
 RECORD syn_w_sent(
   1 synonyms[*]
     2 synonym_id = f8
 )
 SET corder = uar_get_code_by("MEANING",6003,"ORDER")
 SET cpharm = uar_get_code_by("MEANING",6000,"PHARMACY")
 SELECT INTO "nl:"
  primary = substring(1,60,oc.primary_mnemonic), synonym = substring(1,80,ocs.mnemonic),
  mnemonic_type = uar_get_code_display(ocs.mnemonic_type_cd),
  synonym_id = ocs.synonym_id, catalog_cd = ocs.catalog_cd, oc_cki = substring(1,20,oc.cki),
  ocs_cki = substring(1,20,ocs.cki), os.*
  FROM order_catalog_synonym ocs,
   ocs_facility_r ofr,
   order_catalog oc,
   ord_cat_sent_r ocsr,
   order_sentence os,
   filter_entity_reltn fer
  PLAN (ocs
   WHERE ocs.mnemonic_type_cd IN (
   (SELECT
    code_value
    FROM code_value
    WHERE code_set=6011
     AND cdf_meaning IN ("BRANDNAME", "DCP", "DISPDRUG", "GENERICTOP", "IVNAME",
    "PRIMARY", "TRADETOP")))
    AND ocs.catalog_type_cd=cpharm
    AND ocs.active_ind=1
    AND ((ocs.hide_flag=0) OR (ocs.hide_flag=null)) )
   JOIN (ofr
   WHERE ofr.synonym_id=ocs.synonym_id
    AND ((ofr.facility_cd=0) OR (ofr.facility_cd=cur_facility_cd)) )
   JOIN (oc
   WHERE oc.active_ind=1
    AND oc.catalog_cd=ocs.catalog_cd
    AND oc.orderable_type_flag IN (0, 1))
   JOIN (ocsr
   WHERE ocsr.synonym_id=ocs.synonym_id)
   JOIN (os
   WHERE os.order_sentence_id=ocsr.order_sentence_id
    AND os.usage_flag IN (0, 1))
   JOIN (fer
   WHERE fer.parent_entity_id=os.order_sentence_id
    AND ((fer.filter_entity1_id=0) OR (fer.filter_entity1_id=cur_facility_cd))
    AND fer.parent_entity_name="ORDER_SENTENCE"
    AND fer.filter_entity1_name="LOCATION")
  ORDER BY ocs.synonym_id
  HEAD REPORT
   cnt = 0
  HEAD ocs.synonym_id
   cnt = (cnt+ 1), stat = alterlist(syn_w_sent->synonyms,cnt), syn_w_sent->synonyms[cnt].synonym_id
    = ocs.synonym_id
  WITH nullreport
 ;end select
 SELECT
  primary = substring(1,60,oc.primary_mnemonic), synonym = substring(1,60,ocs.mnemonic), synonym_type
   = uar_get_code_display(ocs.mnemonic_type_cd),
  oef = substring(1,30,oef.oe_format_name), synonym_id = ocs.synonym_id, catalog_cd = ocs.catalog_cd,
  oc_cki = substring(1,20,oc.cki), ocs_cki = substring(1,20,ocs.cki)
  FROM order_catalog_synonym ocs,
   ocs_facility_r ofr,
   dummyt d1,
   (dummyt d2  WITH seq = value(size(syn_w_sent->synonyms,5))),
   order_catalog oc,
   order_entry_format oef
  PLAN (ocs
   WHERE ocs.mnemonic_type_cd IN (
   (SELECT
    code_value
    FROM code_value
    WHERE code_set=6011
     AND cdf_meaning IN ("BRANDNAME", "DCP", "DISPDRUG", "GENERICTOP", "IVNAME",
    "PRIMARY", "TRADETOP")))
    AND ocs.catalog_type_cd=cpharm
    AND ocs.active_ind=1
    AND ((ocs.hide_flag=0) OR (ocs.hide_flag=null)) )
   JOIN (ofr
   WHERE ofr.synonym_id=ocs.synonym_id
    AND ((ofr.facility_cd=0) OR (ofr.facility_cd=cur_facility_cd)) )
   JOIN (oc
   WHERE oc.active_ind=1
    AND oc.catalog_cd=ocs.catalog_cd
    AND oc.orderable_type_flag IN (0, 1))
   JOIN (oef
   WHERE ocs.oe_format_id=oef.oe_format_id
    AND oef.action_type_cd=corder)
   JOIN (d1)
   JOIN (d2
   WHERE (syn_w_sent->synonyms[d2.seq].synonym_id=ocs.synonym_id))
  ORDER BY cnvtupper(oc.primary_mnemonic), ocs.mnemonic_key_cap
  WITH outerjoin = d1, dontexist, format = pcformat
 ;end select
#syn_no_sent_exit
#syn_no_prod
 CALL show_processing(0)
 SET cpharm = uar_get_code_by("MEANING",6000,"PHARMACY")
 SET cprimary = uar_get_code_by("MEANING",6011,"PRIMARY")
 SET csystem = uar_get_code_by("MEANING",4062,"SYSTEM")
 SET csyspkgtyp = uar_get_code_by("MEANING",4062,"SYSPKGTYP")
 SET corderable = uar_get_code_by("MEANING",4063,"ORDERABLE")
 SET cinpatient = uar_get_code_by("MEANING",4500,"INPATIENT")
 SET cdesc = uar_get_code_by("MEANING",11000,"DESC")
 SET cur_facility_cd = 0
 FREE RECORD available_products
 RECORD available_products(
   1 products[*]
     2 item_id = f8
     2 catalog_cd = f8
 )
 SELECT INTO "nl:"
  md.item_id, product_desc = substring(1,50,mi.value), mfoi.*
  FROM medication_definition md,
   order_catalog_item_r ocir,
   med_def_flex mdf,
   med_flex_object_idx mfoi,
   med_identifier mi
  PLAN (md)
   JOIN (ocir
   WHERE ocir.item_id=md.item_id)
   JOIN (mdf
   WHERE mdf.item_id=md.item_id
    AND mdf.flex_type_cd=csyspkgtyp
    AND mdf.pharmacy_type_cd=cinpatient)
   JOIN (mfoi
   WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
    AND mfoi.flex_object_type_cd=corderable
    AND ((mfoi.parent_entity_id=0) OR (mfoi.parent_entity_id=cur_facility_cd)) )
   JOIN (mi
   WHERE mi.item_id=md.item_id
    AND mi.active_ind=1
    AND mi.primary_ind=1
    AND mi.med_product_id=0
    AND mi.med_identifier_type_cd=cdesc
    AND mi.pharmacy_type_cd=cinpatient)
  ORDER BY mi.value
  HEAD REPORT
   cnt = 0
  HEAD md.item_id
   cnt = (cnt+ 1), stat = alterlist(available_products->products,cnt), available_products->products[
   cnt].item_id = md.item_id,
   available_products->products[cnt].catalog_cd = ocir.catalog_cd
  WITH nullreport
 ;end select
 SELECT DISTINCT
  ocs.catalog_cd, ocs.synonym_id, primary_synonym = substring(1,75,oc.primary_mnemonic),
  synonym = substring(1,75,ocs.mnemonic), synonym_type = uar_get_code_display(ocs.mnemonic_type_cd),
  ocs_cki = substring(1,20,ocs.cki),
  array_item_id = available_products->products[d2.seq].item_id
  FROM order_catalog_synonym ocs,
   ocs_facility_r ofr,
   order_catalog oc,
   dummyt d1,
   (dummyt d2  WITH seq = value(size(available_products->products,5)))
  PLAN (ocs
   WHERE ocs.active_ind=1
    AND ocs.active_ind=1
    AND ((ocs.hide_flag=0) OR (ocs.hide_flag=null))
    AND ocs.mnemonic_type_cd IN (
   (SELECT
    code_value
    FROM code_value
    WHERE code_set=6011
     AND cdf_meaning IN ("BRANDNAME", "DCP", "DISPDRUG", "GENERICTOP", "IVNAME",
    "PRIMARY", "TRADETOP"))))
   JOIN (oc
   WHERE oc.catalog_cd=ocs.catalog_cd
    AND oc.active_ind=1
    AND oc.orderable_type_flag IN (0, 1)
    AND oc.catalog_type_cd=cpharm)
   JOIN (ofr
   WHERE ofr.synonym_id=ocs.synonym_id
    AND ((ofr.facility_cd=0) OR (ofr.facility_cd=cur_facility_cd)) )
   JOIN (d1)
   JOIN (d2
   WHERE (available_products->products[d2.seq].catalog_cd=ocs.catalog_cd))
  ORDER BY cnvtupper(oc.primary_mnemonic), cnvtupper(ocs.mnemonic)
  WITH outerjoin = d1, dontexist, format = pcformat
 ;end select
#syn_no_prod_exit
#syn_vv_on
 CALL clear_screen(0)
 CALL show_processing(0)
 SET cpharm = uar_get_code_by("MEANING",6000,"PHARMACY")
 SET corder = uar_get_code_by("MEANING",6003,"ORDER")
 DECLARE line = vc
 DECLARE vv_string = vc
 SELECT INTO "pha_aud_ocs_vv_on.csv"
  ocs.catalog_cd, primary = substring(1,60,oc.primary_mnemonic), ocs.synonym_id,
  synonym = substring(1,60,ocs.mnemonic), synonym_type = uar_get_code_display(ocs.mnemonic_type_cd),
  facility = uar_get_code_display(ofr.facility_cd),
  ocs.rx_mask, oef = substring(1,40,oef.oe_format_name), ocs_cki = substring(1,20,ocs.cki),
  oc_cki = substring(1,20,ocs.cki)
  FROM order_catalog_synonym ocs,
   order_catalog oc,
   order_entry_format oef,
   ocs_facility_r ofr
  PLAN (oc
   WHERE oc.catalog_type_cd=cpharm
    AND oc.active_ind=1
    AND oc.orderable_type_flag IN (0, 1))
   JOIN (ocs
   WHERE ocs.catalog_cd=oc.catalog_cd
    AND ocs.active_ind=1
    AND ((ocs.hide_flag=0) OR (ocs.hide_flag=null))
    AND ocs.mnemonic_type_cd IN (
   (SELECT
    code_value
    FROM code_value
    WHERE code_set=6011
     AND cdf_meaning IN ("BRANDNAME", "DCP", "DISPDRUG", "GENERICTOP", "IVNAME",
    "PRIMARY", "TRADETOP"))))
   JOIN (ofr
   WHERE ofr.synonym_id=ocs.synonym_id
    AND ((ofr.facility_cd=0) OR (ofr.facility_cd=cur_facility_cd)) )
   JOIN (oef
   WHERE oef.oe_format_id=outerjoin(ocs.oe_format_id)
    AND oef.action_type_cd=outerjoin(corder))
  ORDER BY cnvtupper(oc.primary_mnemonic), cnvtupper(ocs.mnemonic), ocs.synonym_id,
   ofr.facility_cd
  HEAD REPORT
   vv_cnt = 0, line = "", col 0,
   "CATALOG_CD,", "PRIMARY,", "SYNONYM_ID,",
   "SYNONYM,", "SYNONYM_TYPE,", "RX_MASK,",
   "OEF,", "OCS_CKI,", "OC_CKI,",
   "VIRTUAL_VIEW"
  HEAD ocs.synonym_id
   vv_cnt = 0, vv_string = "", line = concat('"',trim(cnvtstring(ocs.catalog_cd)),'"',",",'"',
    trim(primary),'"',",",'"',trim(cnvtstring(ocs.synonym_id)),
    '"',",",'"',trim(synonym),'"',
    ",",'"',trim(synonym_type),'"',",",
    '"',trim(cnvtstring(ocs.rx_mask)),'"',",",'"',
    trim(oef),'"',",",'"',trim(ocs_cki),
    '"',",",'"',trim(oc_cki),'"',
    ",")
  DETAIL
   vv_cnt = (vv_cnt+ 1)
   IF (vv_cnt=1)
    IF (ofr.facility_cd=0)
     vv_string = "All Facilities"
    ELSE
     vv_string = facility
    ENDIF
   ELSE
    vv_string = concat(vv_string,", ",facility)
   ENDIF
  FOOT  ocs.synonym_id
   row + 1, line = concat(line,'"',vv_string,'"'), col 0,
   line
  WITH check, maxcol = 2000, format = variable,
   nullreport, noformfeed, landscape,
   maxrow = 1
 ;end select
 GO TO pharm_extract_mode
#syn_vv_on_exit
#syn_vv_on_scr
 CALL clear_screen(0)
 CALL show_processing(0)
 SET cpharm = uar_get_code_by("MEANING",6000,"PHARMACY")
 SET corder = uar_get_code_by("MEANING",6003,"ORDER")
 SELECT
  primary_synonym = substring(1,60,oc.primary_mnemonic), synonym = substring(1,60,ocs.mnemonic),
  synonym_type = uar_get_code_display(ocs.mnemonic_type_cd),
  ocs.rx_mask, oef = substring(1,30,oef.oe_format_name), oc_cki = substring(1,20,oc.cki),
  ocs_cki = substring(1,20,ocs.cki), ocs.synonym_id, ocs.catalog_cd
  FROM order_catalog_synonym ocs,
   order_catalog oc,
   order_entry_format oef,
   ocs_facility_r ofr
  WHERE ocs.active_ind=1
   AND oc.active_ind=1
   AND ((ocs.hide_flag=0) OR (ocs.hide_flag=null))
   AND oc.catalog_cd=ocs.catalog_cd
   AND oc.orderable_type_flag IN (0, 1)
   AND oc.catalog_type_cd=cpharm
   AND ofr.synonym_id=ocs.synonym_id
   AND ((ofr.facility_cd=0) OR (ofr.facility_cd=cur_facility_cd))
   AND oef.oe_format_id=outerjoin(ocs.oe_format_id)
   AND oef.action_type_cd=outerjoin(corder)
   AND ocs.mnemonic_type_cd IN (
  (SELECT
   code_value
   FROM code_value
   WHERE code_set=6011
    AND cdf_meaning IN ("BRANDNAME", "DCP", "DISPDRUG", "GENERICTOP", "IVNAME",
   "PRIMARY", "TRADETOP")))
  ORDER BY cnvtupper(oc.primary_mnemonic), cnvtupper(ocs.mnemonic)
  WITH format = pcformat
 ;end select
 GO TO pharm_extract_mode
#syn_vv_on_scr_exit
#syn_no_rxmask_oef
 CALL show_processing(0)
 SET cpharm = uar_get_code_by("MEANING",6000,"PHARMACY")
 SET corder = uar_get_code_by("MEANING",6003,"ORDER")
 SET cprimpharm = 0
 SELECT INTO "nl:"
  oef.oe_format_id
  FROM order_entry_format oef
  WHERE oef.action_type_cd=corder
   AND cnvtupper(oef.oe_format_name)="PRIMARY PHARMACY"
  DETAIL
   cprimpharm = oef.oe_format_id
 ;end select
 SELECT DISTINCT
  ocs.catalog_cd, ocs.synonym_id, primary_synonym = substring(1,75,oc.primary_mnemonic),
  synonym = substring(1,100,ocs.mnemonic), synonym_type = substring(1,25,cv.display), ocs.rx_mask,
  oef = substring(1,30,oef.oe_format_name), ocs_cki = substring(1,20,ocs.cki)
  FROM order_catalog_synonym ocs,
   ocs_facility_r ofr,
   order_catalog oc,
   code_value cv,
   order_entry_format oef
  WHERE ocs.active_ind=1
   AND oc.active_ind=1
   AND ((ocs.hide_flag=0) OR (ocs.hide_flag=null))
   AND oc.catalog_cd=ocs.catalog_cd
   AND oc.orderable_type_flag IN (0, 1)
   AND oc.catalog_type_cd=cpharm
   AND cv.code_value=ocs.mnemonic_type_cd
   AND ((ocs.rx_mask=0) OR (ocs.oe_format_id IN (0, cprimpharm)))
   AND oef.oe_format_id=outerjoin(ocs.oe_format_id)
   AND oef.action_type_cd=outerjoin(corder)
   AND ocs.mnemonic_type_cd IN (
  (SELECT
   code_value
   FROM code_value
   WHERE code_set=6011
    AND cdf_meaning IN ("BRANDNAME", "DCP", "DISPDRUG", "GENERICTOP", "IVNAME",
   "PRIMARY", "TRADETOP")))
   AND ofr.synonym_id=ocs.synonym_id
   AND ((ofr.facility_cd=0) OR (ofr.facility_cd=cur_facility_cd))
  ORDER BY cnvtupper(ocs.mnemonic)
  WITH format = pcformat
 ;end select
#syn_no_rxmask_oef_exit
#rxm_no_rxmask_oef
 CALL show_processing(0)
 SET cdesc = uar_get_code_by("MEANING",11000,"DESC")
 SET crxm = uar_get_code_by("MEANING",6011,"RXMNEMONIC")
 SET corder = uar_get_code_by("MEANING",6003,"ORDER")
 SET csystem = uar_get_code_by("MEANING",4062,"SYSTEM")
 SET cinpatient = uar_get_code_by("MEANING",4500,"INPATIENT")
 SET cpharm = uar_get_code_by("MEANING",6000,"PHARMACY")
 SET cprimary = uar_get_code_by("MEANING",6011,"PRIMARY")
 SET csyspkgtyp = uar_get_code_by("MEANING",4062,"SYSPKGTYP")
 SET corderable = uar_get_code_by("MEANING",4063,"ORDERABLE")
 SELECT
  ocir.item_id, formulary_product = substring(1,75,mi.value), ocs.rx_mask,
  oef = substring(1,30,oef.oe_format_name), oef.oe_format_id, catalog_cd = oc.catalog_cd,
  primary_synonym = substring(1,75,oc.primary_mnemonic), order_catalog_cki = substring(1,30,oc.cki)
  FROM order_catalog_item_r ocir,
   order_catalog oc,
   med_identifier mi,
   order_catalog_synonym ocs,
   order_entry_format oef,
   item_definition id,
   med_def_flex mdf,
   med_def_flex mdf2,
   med_flex_object_idx mfoi2,
   dummyt d
  PLAN (ocir)
   JOIN (oc
   WHERE oc.catalog_cd=ocir.catalog_cd)
   JOIN (id
   WHERE ocir.item_id=id.item_id
    AND id.active_ind=1)
   JOIN (mdf
   WHERE mdf.item_id=ocir.item_id
    AND mdf.flex_type_cd=csystem
    AND mdf.pharmacy_type_cd=cinpatient)
   JOIN (mdf2
   WHERE mdf2.item_id=ocir.item_id
    AND mdf2.flex_type_cd=csyspkgtyp
    AND mdf2.pharmacy_type_cd=cinpatient)
   JOIN (mfoi2
   WHERE mfoi2.med_def_flex_id=mdf2.med_def_flex_id
    AND mfoi2.flex_object_type_cd=corderable
    AND ((mfoi2.parent_entity_id=0) OR (mfoi2.parent_entity_id=cur_facility_cd)) )
   JOIN (mi
   WHERE mi.item_id=ocir.item_id
    AND mi.med_product_id=0
    AND mi.med_identifier_type_cd=cdesc
    AND mi.active_ind=1
    AND mi.primary_ind=1
    AND mi.pharmacy_type_cd=cinpatient)
   JOIN (ocs
   WHERE ocs.item_id=ocir.item_id
    AND ocs.mnemonic_type_cd=crxm
    AND ((ocs.rx_mask=0) OR (ocs.oe_format_id=0)) )
   JOIN (d)
   JOIN (oef
   WHERE oef.oe_format_id=ocs.oe_format_id
    AND oef.action_type_cd=corder)
  ORDER BY cnvtupper(mi.value)
  WITH outerjoin = d, format = pcformat
 ;end select
#rxm_no_rxmask_oef_exit
#missing_clin_cat
 CALL show_processing(0)
 SET cpharm = uar_get_code_by("MEANING",6000,"PHARMACY")
 SELECT DISTINCT
  ocs.catalog_cd, ocs.synonym_id, primary_synonym = substring(1,75,ocs.mnemonic),
  synonym_type = substring(1,30,cv.display), oc_clinincal_cat = substring(1,20,cv2.display),
  ocs_clinincal_cat = substring(1,20,cv3.display)
  FROM order_catalog_synonym ocs,
   ocs_facility_r ofr,
   order_catalog oc,
   code_value cv,
   code_value cv2,
   code_value cv3
  WHERE ocs.active_ind=1
   AND oc.active_ind=1
   AND ((ocs.hide_flag=0) OR (ocs.hide_flag=null))
   AND oc.catalog_cd=ocs.catalog_cd
   AND oc.orderable_type_flag IN (0, 1, 8)
   AND oc.catalog_type_cd=cpharm
   AND cv.code_value=ocs.mnemonic_type_cd
   AND ((oc.dcp_clin_cat_cd=0) OR (ocs.dcp_clin_cat_cd=0))
   AND cv2.code_value=oc.dcp_clin_cat_cd
   AND cv3.code_value=ocs.dcp_clin_cat_cd
   AND ocs.mnemonic_type_cd IN (
  (SELECT
   code_value
   FROM code_value
   WHERE code_set=6011
    AND cdf_meaning IN ("BRANDNAME", "DCP", "DISPDRUG", "GENERICTOP", "IVNAME",
   "PRIMARY", "TRADETOP")))
   AND ofr.synonym_id=ocs.synonym_id
   AND ((ofr.facility_cd=0) OR (ofr.facility_cd=cur_facility_cd))
  ORDER BY cnvtupper(ocs.mnemonic)
  WITH format = pcformat
 ;end select
#missing_clin_cat_exit
#sent_oef_incompat
 CALL show_processing(0)
 SET corder = uar_get_code_by("MEANING",6003,"ORDER")
 SET cpharm = uar_get_code_by("MEANING",6000,"PHARMACY")
 FREE RECORD format_fields
 RECORD format_fields(
   1 fields[*]
     2 oe_format_id = f8
     2 oe_field_id = f8
     2 field_text = vc
 )
 SELECT INTO "nl:"
  oe.oe_format_id, o.oe_field_id, o.accept_flag,
  format_name = substring(1,30,oe.oe_format_name), field_text = substring(1,50,o.label_text)
  FROM order_entry_format oe,
   oe_format_fields o
  PLAN (oe
   WHERE oe.catalog_type_cd=cpharm
    AND oe.action_type_cd=corder)
   JOIN (o
   WHERE oe.oe_format_id=o.oe_format_id
    AND oe.action_type_cd=o.action_type_cd
    AND o.accept_flag=2)
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(format_fields->fields,cnt), format_fields->fields[cnt].
   oe_format_id = oe.oe_format_id,
   format_fields->fields[cnt].oe_field_id = o.oe_field_id, format_fields->fields[cnt].field_text =
   trim(o.label_text)
  WITH nullreport
 ;end select
 SELECT
  primary = substring(1,50,oc.primary_mnemonic), synonym = substring(1,75,ocs.mnemonic), synonym_type
   = uar_get_code_display(ocs.mnemonic_type_cd),
  oef = substring(1,40,oef.oe_format_name), field_name = substring(1,40,format_fields->fields[d.seq].
   field_text), field_value = substring(1,30,osd.oe_field_display_value),
  sentence = substring(1,100,ocsr.order_sentence_disp_line), ocs.synonym_id, ocs.catalog_cd,
  os.order_sentence_id
  FROM ord_cat_sent_r ocsr,
   order_sentence_detail osd,
   order_catalog_synonym ocs,
   order_catalog oc,
   order_sentence os,
   filter_entity_reltn fer,
   ocs_facility_r ofr,
   order_entry_format oef,
   (dummyt d  WITH seq = value(size(format_fields->fields,5)))
  PLAN (oc
   WHERE oc.orderable_type_flag IN (0, 1)
    AND oc.catalog_type_cd=cpharm
    AND oc.active_ind=1)
   JOIN (ocs
   WHERE oc.catalog_cd=ocs.catalog_cd
    AND ocs.active_ind=1
    AND ((ocs.hide_flag=0) OR (ocs.hide_flag=null))
    AND ocs.mnemonic_type_cd IN (
   (SELECT
    code_value
    FROM code_value
    WHERE code_set=6011
     AND cdf_meaning IN ("BRANDNAME", "DCP", "DISPDRUG", "GENERICTOP", "IVNAME",
    "PRIMARY", "TRADETOP"))))
   JOIN (ofr
   WHERE ofr.synonym_id=ocs.synonym_id
    AND ((ofr.facility_cd=0) OR (ofr.facility_cd=cur_facility_cd)) )
   JOIN (ocsr
   WHERE ocs.synonym_id=ocsr.synonym_id)
   JOIN (os
   WHERE os.order_sentence_id=ocsr.order_sentence_id
    AND os.usage_flag IN (0, 1))
   JOIN (fer
   WHERE fer.parent_entity_id=os.order_sentence_id
    AND ((fer.filter_entity1_id=0) OR (fer.filter_entity1_id=cur_facility_cd))
    AND fer.parent_entity_name="ORDER_SENTENCE"
    AND fer.filter_entity1_name="LOCATION")
   JOIN (oef
   WHERE oef.oe_format_id=ocs.oe_format_id
    AND oef.action_type_cd=corder)
   JOIN (osd
   WHERE osd.order_sentence_id=os.order_sentence_id)
   JOIN (d
   WHERE (format_fields->fields[d.seq].oe_field_id=osd.oe_field_id)
    AND (format_fields->fields[d.seq].oe_format_id=oef.oe_format_id))
  ORDER BY cnvtupper(oc.primary_mnemonic), cnvtupper(ocs.mnemonic), os.order_sentence_id,
   field_name
  WITH format = pcformat
 ;end select
#sent_oef_incompat_exit
#cpoe_lookup_by_prod
 CALL show_processing(0)
 CALL clear_screen(0)
 CALL text(5,1,"Enter first character(s) of product to look up:   ")
 CALL accept(5,53,"P(30);CU","*")
 SET prod_loc_string = trim(cnvtupper(curaccept))
 FREE RECORD prod_temp
 RECORD prod_temp(
   1 prod_list[*]
     2 item_id = f8
     2 desc = vc
     2 item_id_str = vc
     2 catalog_cd = f8
 )
 SET prod_count = 0
 SET csyspkgtyp = uar_get_code_by("MEANING",4062,"SYSPKGTYP")
 SET corderable = uar_get_code_by("MEANING",4063,"ORDERABLE")
 SET cdesc = uar_get_code_by("MEANING",11000,"DESC")
 SET csystem = uar_get_code_by("MEANING",4062,"SYSTEM")
 SET cinpatient = uar_get_code_by("MEANING",4500,"INPATIENT")
 SELECT INTO "nl:"
  ocir.item_id, mi.value
  FROM order_catalog_item_r ocir,
   item_definition id,
   med_identifier mi,
   med_def_flex mdf,
   med_def_flex mdf2,
   med_flex_object_idx mfoi
  PLAN (ocir)
   JOIN (id
   WHERE id.item_id=ocir.item_id
    AND id.active_ind=1)
   JOIN (mdf
   WHERE mdf.item_id=ocir.item_id
    AND mdf.flex_type_cd=csystem
    AND mdf.pharmacy_type_cd=cinpatient)
   JOIN (mi
   WHERE mi.item_id=ocir.item_id
    AND mi.med_product_id=0
    AND mi.med_identifier_type_cd=cdesc
    AND mi.active_ind=1
    AND mi.primary_ind=1
    AND mi.pharmacy_type_cd=cinpatient
    AND cnvtupper(mi.value)=patstring(build(prod_loc_string,"*")))
   JOIN (mdf2
   WHERE mdf2.item_id=ocir.item_id
    AND mdf2.flex_type_cd=csyspkgtyp
    AND mdf2.pharmacy_type_cd=cinpatient)
   JOIN (mfoi
   WHERE mfoi.med_def_flex_id=mdf2.med_def_flex_id
    AND mfoi.flex_object_type_cd=corderable
    AND ((mfoi.parent_entity_id=0) OR (mfoi.parent_entity_id=cur_facility_cd)) )
  ORDER BY cnvtupper(mi.value)
  HEAD REPORT
   prod_count = 0
  DETAIL
   prod_count = (prod_count+ 1)
   IF (mod(prod_count,10)=1)
    stat = alterlist(prod_temp->prod_list,(prod_count+ 9))
   ENDIF
   prod_temp->prod_list[prod_count].item_id = ocir.item_id, prod_temp->prod_list[prod_count].desc =
   mi.value, prod_temp->prod_list[prod_count].item_id_str = cnvtstring(ocir.item_id),
   prod_temp->prod_list[prod_count].catalog_cd = ocir.catalog_cd
  FOOT REPORT
   stat = alterlist(prod_temp->prod_list,prod_count)
  WITH nocounter
 ;end select
 CALL clear_screen(0)
 CALL text(3,2,build("Products available for look up (",prod_loc_string,") :"))
 CALL text(5,67,"Total:  ")
 CALL text(5,75,cnvtstring(prod_count,4))
 CALL create_std_box(prod_count)
 CALL text(6,8,"Product")
 WHILE (cnt <= numsrow
  AND cnt <= maxcnt)
   SET holdstr60 = trim(prod_temp->prod_list[cnt].desc)
   SET holdstr20 = trim(prod_temp->prod_list[cnt].item_id_str)
   SET holdstr = concat(cnvtstring(cnt,4,0,r),"  ",holdstr60,"  ",holdstr20)
   CALL scrolltext(cnt,holdstr)
   SET cnt = (cnt+ 1)
 ENDWHILE
 SET cnt = 1
 SET arow = 1
 CALL text(23,1,"Select product to look up            (enter 000 to go back)")
 SET pick = 0
 WHILE (pick=0)
  CALL accept(23,32,"9999;S",cnt)
  CASE (curscroll)
   OF 0:
    IF (curaccept=0)
     CALL clear_screen(0)
     GO TO pharm_data_lookup_mode
    ELSEIF (cnvtint(curaccept) BETWEEN 1 AND maxcnt)
     SET pick = cnvtint(curaccept)
     CALL clear_screen(0)
     CALL cpoe_lookup_synsent(prod_temp->prod_list[pick].catalog_cd,prod_temp->prod_list[pick].desc)
    ELSE
     CALL clear_screen(0)
     GO TO pharm_data_lookup_mode
    ENDIF
   OF 1:
    IF (cnt < maxcnt)
     SET cnt = (cnt+ 1)
     SET holdstr60 = trim(prod_temp->prod_list[cnt].desc)
     SET holdstr20 = trim(prod_temp->prod_list[cnt].item_id_str)
     SET holdstr = concat(cnvtstring(cnt,4,0,r),"  ",holdstr60,"  ",holdstr20)
     CALL down_arrow(holdstr)
    ENDIF
   OF 2:
    IF (cnt > 1)
     SET cnt = (cnt - 1)
     SET holdstr60 = trim(prod_temp->prod_list[cnt].desc)
     SET holdstr20 = trim(prod_temp->prod_list[cnt].item_id_str)
     SET holdstr = concat(cnvtstring(cnt,4,0,r),"  ",holdstr60,"  ",holdstr20)
     CALL up_arrow(holdstr)
    ENDIF
   OF 3:
   OF 4:
   OF 6:
    IF (numsrow < maxcnt)
     SET cnt = ((cnt+ numsrow) - 1)
     IF (((cnt+ numsrow) > maxcnt))
      SET cnt = (maxcnt - numsrow)
     ENDIF
     SET arow = 1
     WHILE (arow <= numsrow)
       SET cnt = (cnt+ 1)
       SET holdstr60 = trim(prod_temp->prod_list[cnt].desc)
       SET holdstr20 = trim(prod_temp->prod_list[cnt].item_id_str)
       SET holdstr = concat(cnvtstring(cnt,4,0,r),"  ",holdstr60,"  ",holdstr20)
       CALL scrolltext(arow,holdstr)
       SET arow = (arow+ 1)
     ENDWHILE
     SET arow = 1
     SET cnt = ((cnt - numsrow)+ 1)
    ENDIF
   OF 5:
    IF (((cnt - numsrow) > 0))
     SET cnt = (cnt - numsrow)
    ELSE
     SET cnt = 1
    ENDIF
    SET tmp1 = cnt
    SET arow = 1
    WHILE (arow <= numsrow
     AND cnt < maxcnt)
      SET holdstr60 = trim(prod_temp->prod_list[cnt].desc)
      SET holdstr20 = trim(prod_temp->prod_list[cnt].item_id_str)
      SET holdstr = concat(cnvtstring(cnt,4,0,r),"  ",holdstr60,"  ",holdstr20)
      CALL scrolltext(arow,holdstr)
      SET cnt = (cnt+ 1)
      SET arow = (arow+ 1)
    ENDWHILE
    SET cnt = tmp1
    SET arow = 1
  ENDCASE
 ENDWHILE
 GO TO pharm_data_lookup_mode
#cpoe_lookup_by_prod_exit
#cpoe_lookup_by_ord
 CALL clear_screen(0)
 CALL text(5,1,"Enter first character(s) of orderable to lookup:  ")
 CALL accept(5,52,"P(30);CU","")
 SET ord_loc_string = trim(cnvtupper(curaccept))
 FREE RECORD oc
 RECORD oc(
   1 qual[*]
     2 catalog_cd = f8
     2 orderable = vc
     2 ref = c1
     2 active = c1
 )
 SET ocknt = 0
 SELECT INTO "nl:"
  oc.catalog_cd, oc.active_ind, oc.cki,
  oc.primary_mnemonic
  FROM order_catalog oc
  PLAN (oc
   WHERE oc.catalog_type_cd IN (
   (SELECT
    code_value
    FROM code_value
    WHERE code_set=6000
     AND cdf_meaning="PHARMACY"
     AND active_ind=1))
    AND cnvtupper(oc.primary_mnemonic)=patstring(build(ord_loc_string,"*")))
  ORDER BY cnvtupper(oc.primary_mnemonic)
  HEAD REPORT
   ocknt = 0
  DETAIL
   ocknt = (ocknt+ 1)
   IF (mod(ocknt,10)=1)
    stat = alterlist(oc->qual,(ocknt+ 9))
   ENDIF
   oc->qual[ocknt].catalog_cd = oc.catalog_cd, oc->qual[ocknt].orderable = substring(1,65,oc
    .primary_mnemonic), oc->qual[ocknt].ref = "1",
   oc->qual[ocknt].active = "1"
   IF (textlen(trim(oc.cki))=0)
    oc->qual[ocknt].ref = "0"
   ENDIF
   IF (oc.active_ind=0)
    oc->qual[ocknt].active = "0"
   ENDIF
  FOOT REPORT
   stat = alterlist(oc->qual,ocknt)
  WITH nocounter
 ;end select
 CALL clear_screen(0)
 CALL text(3,2,"Search: ")
 CALL text(3,10,ord_loc_string)
 CALL text(5,67,"Total:  ")
 CALL text(5,75,cnvtstring(ocknt,4))
 CALL create_std_box(ocknt)
 CALL text(6,8,"Orderable ")
 CALL text(6,75,"A|R")
 WHILE (cnt <= numsrow
  AND cnt <= maxcnt)
   SET holdstr65 = oc->qual[cnt].orderable
   SET holdstr_r = oc->qual[cnt].ref
   SET holdstr_a = oc->qual[cnt].active
   SET holdstr = concat(cnvtstring(cnt,4,0,r),"  ",holdstr65," ",holdstr_a,
    "|",holdstr_r)
   CALL scrolltext(cnt,holdstr)
   SET cnt = (cnt+ 1)
 ENDWHILE
 SET cnt = 1
 SET arow = 1
 CALL text(23,1,"Select orderable for lookup        (enter 000 to go back)")
 SET pick = 0
 WHILE (pick=0)
  CALL accept(23,30,"9999;S",cnt)
  CASE (curscroll)
   OF 0:
    IF (curaccept=0)
     CALL clear_screen(0)
     GO TO pharm_data_lookup_mode
    ELSEIF (cnvtint(curaccept) BETWEEN 1 AND maxcnt)
     SET pick = cnvtint(curaccept)
     CALL clear_screen(0)
     CALL cpoe_lookup_synsent(oc->qual[pick].catalog_cd,oc->qual[pick].orderable)
    ELSE
     CALL clear_screen(0)
     GO TO pharm_data_lookup_mode
    ENDIF
   OF 1:
    IF (cnt < maxcnt)
     SET cnt = (cnt+ 1)
     SET holdstr65 = oc->qual[cnt].orderable
     SET holdstr_r = oc->qual[cnt].ref
     SET holdstr_a = oc->qual[cnt].active
     SET holdstr = concat(cnvtstring(cnt,4,0,r),"  ",holdstr65," ",holdstr_a,
      "|",holdstr_r)
     CALL down_arrow(holdstr)
    ENDIF
   OF 2:
    IF (cnt > 1)
     SET cnt = (cnt - 1)
     SET holdstr65 = oc->qual[cnt].orderable
     SET holdstr_r = oc->qual[cnt].ref
     SET holdstr_a = oc->qual[cnt].active
     SET holdstr = concat(cnvtstring(cnt,4,0,r),"  ",holdstr65," ",holdstr_a,
      "|",holdstr_r)
     CALL up_arrow(holdstr)
    ENDIF
   OF 3:
   OF 4:
   OF 6:
    IF (numsrow < maxcnt)
     SET cnt = ((cnt+ numsrow) - 1)
     IF (((cnt+ numsrow) > maxcnt))
      SET cnt = (maxcnt - numsrow)
     ENDIF
     SET arow = 1
     WHILE (arow <= numsrow)
       SET cnt = (cnt+ 1)
       SET holdstr65 = oc->qual[cnt].orderable
       SET holdstr_r = oc->qual[cnt].ref
       SET holdstr_a = oc->qual[cnt].active
       SET holdstr = concat(cnvtstring(cnt,4,0,r),"  ",holdstr65," ",holdstr_a,
        "|",holdstr_r)
       CALL scrolltext(arow,holdstr)
       SET arow = (arow+ 1)
     ENDWHILE
     SET arow = 1
     SET cnt = ((cnt - numsrow)+ 1)
    ENDIF
   OF 5:
    IF (((cnt - numsrow) > 0))
     SET cnt = (cnt - numsrow)
    ELSE
     SET cnt = 1
    ENDIF
    SET tmp1 = cnt
    SET arow = 1
    WHILE (arow <= numsrow
     AND cnt < maxcnt)
      SET holdstr65 = oc->qual[cnt].orderable
      SET holdstr_r = oc->qual[cnt].ref
      SET holdstr_a = oc->qual[cnt].active
      SET holdstr = concat(cnvtstring(cnt,4,0,r),"  ",holdstr65," ",holdstr_a,
       "|",holdstr_r)
      CALL scrolltext(arow,holdstr)
      SET cnt = (cnt+ 1)
      SET arow = (arow+ 1)
    ENDWHILE
    SET cnt = tmp1
    SET arow = 1
  ENDCASE
 ENDWHILE
 GO TO pharm_data_lookup_mode
#cpoe_lookup_by_ord_exit
#remap_form_item
 CALL clear_screen(0)
 CALL text(5,1,"Enter first character(s) of product to remap:   ")
 CALL accept(5,53,"P(30);CU","")
 SET prod_loc_string = trim(cnvtupper(curaccept))
 FREE RECORD prod_temp
 RECORD prod_temp(
   1 prod_list[*]
     2 item_id = f8
     2 desc = vc
     2 item_id_str = vc
 )
 SET prod_count = 0
 SET cdesc = uar_get_code_by("MEANING",11000,"DESC")
 SET csystem = uar_get_code_by("MEANING",4062,"SYSTEM")
 SET cinpatient = uar_get_code_by("MEANING",4500,"INPATIENT")
 SELECT INTO "nl:"
  md.item_id, product_desc = substring(1,50,mi.value), mfoi.*
  FROM medication_definition md,
   order_catalog_item_r ocir,
   item_definition id,
   med_def_flex mdf,
   med_flex_object_idx mfoi,
   med_identifier mi
  PLAN (md)
   JOIN (ocir
   WHERE ocir.item_id=md.item_id)
   JOIN (id
   WHERE id.item_id=ocir.item_id
    AND id.active_ind=1)
   JOIN (mdf
   WHERE mdf.item_id=md.item_id
    AND mdf.flex_type_cd=csyspkgtyp
    AND mdf.pharmacy_type_cd=cinpatient)
   JOIN (mfoi
   WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
    AND mfoi.flex_object_type_cd=corderable
    AND ((mfoi.parent_entity_id=0) OR (mfoi.parent_entity_id=cur_facility_cd)) )
   JOIN (mi
   WHERE mi.item_id=md.item_id
    AND mi.active_ind=1
    AND mi.primary_ind=1
    AND mi.med_product_id=0
    AND mi.med_identifier_type_cd=cdesc
    AND mi.pharmacy_type_cd=cinpatient
    AND cnvtupper(mi.value)=patstring(build(prod_loc_string,"*")))
  ORDER BY mi.value
  HEAD REPORT
   prod_count = 0
  DETAIL
   prod_count = (prod_count+ 1)
   IF (mod(prod_count,10)=1)
    stat = alterlist(prod_temp->prod_list,(prod_count+ 9))
   ENDIF
   prod_temp->prod_list[prod_count].item_id = ocir.item_id, prod_temp->prod_list[prod_count].desc =
   mi.value, prod_temp->prod_list[prod_count].item_id_str = cnvtstring(ocir.item_id)
  FOOT REPORT
   stat = alterlist(prod_temp->prod_list,prod_count)
  WITH nocounter
 ;end select
 CALL clear_screen(0)
 CALL text(3,2,"Products available for remapping:")
 CALL text(5,67,"Total:  ")
 CALL text(5,75,cnvtstring(prod_count,4))
 CALL create_std_box(prod_count)
 CALL text(6,8,"Product")
 WHILE (cnt <= numsrow
  AND cnt <= maxcnt)
   SET holdstr60 = trim(prod_temp->prod_list[cnt].desc)
   SET holdstr20 = trim(prod_temp->prod_list[cnt].item_id_str)
   SET holdstr = concat(cnvtstring(cnt,4,0,r),"  ",holdstr60,"  ",holdstr20)
   CALL scrolltext(cnt,holdstr)
   SET cnt = (cnt+ 1)
 ENDWHILE
 SET cnt = 1
 SET arow = 1
 CALL text(23,1,"Select product to remap            (enter 000 to go back)")
 SET pick = 0
 WHILE (pick=0)
  CALL accept(23,30,"9999;S",cnt)
  CASE (curscroll)
   OF 0:
    IF (curaccept=0)
     CALL clear_screen(0)
     GO TO pharm_utilities_mode
    ELSEIF (cnvtint(curaccept) BETWEEN 1 AND maxcnt)
     SET pick = cnvtint(curaccept)
     CALL clear_screen(0)
     CALL remap_form_prod(prod_temp->prod_list[pick].item_id,prod_temp->prod_list[pick].desc)
    ELSE
     CALL clear_screen(0)
     GO TO pharm_utilities_mode
    ENDIF
   OF 1:
    IF (cnt < maxcnt)
     SET cnt = (cnt+ 1)
     SET holdstr60 = trim(prod_temp->prod_list[cnt].desc)
     SET holdstr20 = trim(prod_temp->prod_list[cnt].item_id_str)
     SET holdstr = concat(cnvtstring(cnt,4,0,r),"  ",holdstr60,"  ",holdstr20)
     CALL down_arrow(holdstr)
    ENDIF
   OF 2:
    IF (cnt > 1)
     SET cnt = (cnt - 1)
     SET holdstr60 = trim(prod_temp->prod_list[cnt].desc)
     SET holdstr20 = trim(prod_temp->prod_list[cnt].item_id_str)
     SET holdstr = concat(cnvtstring(cnt,4,0,r),"  ",holdstr60,"  ",holdstr20)
     CALL up_arrow(holdstr)
    ENDIF
   OF 3:
   OF 4:
   OF 6:
    IF (numsrow < maxcnt)
     SET cnt = ((cnt+ numsrow) - 1)
     IF (((cnt+ numsrow) > maxcnt))
      SET cnt = (maxcnt - numsrow)
     ENDIF
     SET arow = 1
     WHILE (arow <= numsrow)
       SET cnt = (cnt+ 1)
       SET holdstr60 = trim(prod_temp->prod_list[cnt].desc)
       SET holdstr20 = trim(prod_temp->prod_list[cnt].item_id_str)
       SET holdstr = concat(cnvtstring(cnt,4,0,r),"  ",holdstr60,"  ",holdstr20)
       CALL scrolltext(arow,holdstr)
       SET arow = (arow+ 1)
     ENDWHILE
     SET arow = 1
     SET cnt = ((cnt - numsrow)+ 1)
    ENDIF
   OF 5:
    IF (((cnt - numsrow) > 0))
     SET cnt = (cnt - numsrow)
    ELSE
     SET cnt = 1
    ENDIF
    SET tmp1 = cnt
    SET arow = 1
    WHILE (arow <= numsrow
     AND cnt < maxcnt)
      SET holdstr60 = trim(prod_temp->prod_list[cnt].desc)
      SET holdstr20 = trim(prod_temp->prod_list[cnt].item_id_str)
      SET holdstr = concat(cnvtstring(cnt,4,0,r),"  ",holdstr60,"  ",holdstr20)
      CALL scrolltext(arow,holdstr)
      SET cnt = (cnt+ 1)
      SET arow = (arow+ 1)
    ENDWHILE
    SET cnt = tmp1
    SET arow = 1
  ENDCASE
 ENDWHILE
 CALL clear_screen(0)
 CALL text(23,1,"Remap another product? (Y/N)   ")
 CALL accept(23,29,"C;CU","Y"
  WHERE curaccept IN ("Y", "N"))
 CASE (curaccept)
  OF "Y":
   GO TO remap_form_item
  OF "N":
   GO TO pharm_utilities_mode
 ENDCASE
 GO TO pharm_utilities_mode
#remap_form_item_exit
#powerplan_med_noncpoe
 CALL show_processing(0)
 SET cpharm = uar_get_code_by("MEANING",6000,"PHARMACY")
 SET corder = uar_get_code_by("MEANING",6003,"ORDER")
 SELECT
  powerplan_name = pcat.description, clinical_category = uar_get_code_display(pc.dcp_clin_cat_cd),
  clinical_sub_category = uar_get_code_display(pc.dcp_clin_sub_cat_cd),
  synonym = ocs.mnemonic, synonym_type = uar_get_code_display(ocs.mnemonic_type_cd), include_exclude
   = pc.include_ind,
  pc.pathway_comp_id, component_synonym_id = ocs.synonym_id, component_catalog_cd = ocs.catalog_cd
  FROM order_catalog_synonym ocs,
   pathway_comp pc,
   pw_cat_flex pcf,
   pathway_catalog pcat
  PLAN (pc
   WHERE pc.active_ind=1)
   JOIN (pcat
   WHERE pcat.pathway_catalog_id=pc.pathway_catalog_id
    AND pcat.active_ind=1
    AND pcat.pathway_catalog_id > 0)
   JOIN (pcf
   WHERE pcf.pathway_catalog_id=pc.pathway_catalog_id
    AND ((pcf.parent_entity_id=0) OR (pcf.parent_entity_id=cur_facility_cd)) )
   JOIN (ocs
   WHERE ocs.synonym_id=pc.parent_entity_id
    AND ocs.catalog_type_cd=cpharm
    AND  NOT (ocs.mnemonic_type_cd IN (
   (SELECT
    code_value
    FROM code_value
    WHERE code_set=6011
     AND cdf_meaning IN ("BRANDNAME", "DCP", "DISPDRUG", "GENERICTOP", "IVNAME",
    "PRIMARY", "TRADETOP")))))
  ORDER BY powerplan_name, clinical_category, clinical_sub_category,
   synonym
  WITH format = pcformat
 ;end select
 GO TO cs_pp_problem_mode
#powerplan_med_noncpoe_exit
#powerplan_med_vvoff
 CALL show_processing(0)
 SET cpharm = uar_get_code_by("MEANING",6000,"PHARMACY")
 SET corder = uar_get_code_by("MEANING",6003,"ORDER")
 FREE RECORD mylist2
 RECORD mylist2(
   1 vv[*]
     2 syn_id = f8
     2 vv_ind = c1
 )
 CALL load_current_vv(0)
 SELECT
  powerplan_name = pcat.description, clinical_category = uar_get_code_display(pc.dcp_clin_cat_cd),
  clinical_sub_category = uar_get_code_display(pc.dcp_clin_sub_cat_cd),
  synonym = ocs.mnemonic, synonym_type = uar_get_code_display(ocs.mnemonic_type_cd), virtual_view =
  mylist2->vv[d2.seq].vv_ind,
  include_exclude = pc.include_ind, pc.pathway_comp_id, component_synonym_id = ocs.synonym_id,
  component_catalog_cd = ocs.catalog_cd
  FROM order_catalog_synonym ocs,
   pathway_comp pc,
   pw_cat_flex pcf,
   pathway_catalog pcat,
   dummyt d1,
   (dummyt d2  WITH seq = value(size(mylist2->vv,5)))
  PLAN (pc
   WHERE pc.active_ind=1)
   JOIN (pcat
   WHERE pcat.pathway_catalog_id=pc.pathway_catalog_id
    AND pcat.active_ind=1
    AND pcat.pathway_catalog_id > 0)
   JOIN (pcf
   WHERE pcf.pathway_catalog_id=pc.pathway_catalog_id
    AND ((pcf.parent_entity_id=0) OR (pcf.parent_entity_id=cur_facility_cd)) )
   JOIN (ocs
   WHERE ocs.synonym_id=pc.parent_entity_id
    AND ocs.catalog_type_cd=cpharm)
   JOIN (d1)
   JOIN (d2
   WHERE (mylist2->vv[d2.seq].syn_id=ocs.synonym_id))
  ORDER BY powerplan_name, clinical_category, clinical_sub_category,
   synonym
  WITH outerjoin = d1, dontexist, format = pcformat
 ;end select
 GO TO cs_pp_problem_mode
#powerplan_med_vvoff_exit
#powerplan_med_noprod
 CALL show_processing(0)
 SET cpharm = uar_get_code_by("MEANING",6000,"PHARMACY")
 SET cprimary = uar_get_code_by("MEANING",6011,"PRIMARY")
 SET csystem = uar_get_code_by("MEANING",4062,"SYSTEM")
 SET csyspkgtyp = uar_get_code_by("MEANING",4062,"SYSPKGTYP")
 SET corderable = uar_get_code_by("MEANING",4063,"ORDERABLE")
 SET cinpatient = uar_get_code_by("MEANING",4500,"INPATIENT")
 SET cdesc = uar_get_code_by("MEANING",11000,"DESC")
 SET corder = uar_get_code_by("MEANING",6003,"ORDER")
 FREE RECORD mylist2
 RECORD mylist2(
   1 vv[*]
     2 syn_id = f8
     2 vv_ind = c1
 )
 CALL load_current_vv(0)
 FREE RECORD available_products
 RECORD available_products(
   1 products[*]
     2 item_id = f8
     2 catalog_cd = f8
 )
 SELECT INTO "nl:"
  md.item_id, product_desc = substring(1,50,mi.value), mfoi.*
  FROM medication_definition md,
   order_catalog_item_r ocir,
   item_definition id,
   med_def_flex mdf,
   med_flex_object_idx mfoi,
   med_identifier mi
  PLAN (md)
   JOIN (ocir
   WHERE ocir.item_id=md.item_id)
   JOIN (id
   WHERE id.item_id=ocir.item_id
    AND id.active_ind=1)
   JOIN (mdf
   WHERE mdf.item_id=md.item_id
    AND mdf.flex_type_cd=csyspkgtyp
    AND mdf.pharmacy_type_cd=cinpatient)
   JOIN (mfoi
   WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
    AND mfoi.flex_object_type_cd=corderable
    AND ((mfoi.parent_entity_id=0) OR (mfoi.parent_entity_id=cur_facility_cd)) )
   JOIN (mi
   WHERE mi.item_id=md.item_id
    AND mi.active_ind=1
    AND mi.primary_ind=1
    AND mi.med_product_id=0
    AND mi.med_identifier_type_cd=cdesc
    AND mi.pharmacy_type_cd=cinpatient)
  ORDER BY mi.value
  HEAD REPORT
   cnt = 0
  HEAD md.item_id
   cnt = (cnt+ 1), stat = alterlist(available_products->products,cnt), available_products->products[
   cnt].item_id = md.item_id,
   available_products->products[cnt].catalog_cd = ocir.catalog_cd
  WITH nullreport
 ;end select
 SELECT
  powerplan_name = pcat.description, clinical_category = uar_get_code_display(pc.dcp_clin_cat_cd),
  clinical_sub_category = uar_get_code_display(pc.dcp_clin_sub_cat_cd),
  synonym = ocs.mnemonic, synonym_type = uar_get_code_display(ocs.mnemonic_type_cd), virtual_view =
  mylist2->vv[d2.seq].vv_ind,
  include_exclude = pc.include_ind, pc.pathway_comp_id, component_synonym_id = ocs.synonym_id,
  component_catalog_cd = ocs.catalog_cd
  FROM order_catalog_synonym ocs,
   pathway_comp pc,
   pw_cat_flex pcf,
   pathway_catalog pcat,
   (dummyt d1  WITH seq = value(size(mylist2->vv,5))),
   dummyt d2,
   (dummyt d3  WITH seq = value(size(available_products->products,5)))
  PLAN (pc
   WHERE pc.active_ind=1)
   JOIN (pcat
   WHERE pcat.pathway_catalog_id=pc.pathway_catalog_id
    AND pcat.active_ind=1
    AND pcat.pathway_catalog_id > 0)
   JOIN (pcf
   WHERE pcf.pathway_catalog_id=pc.pathway_catalog_id
    AND ((pcf.parent_entity_id=0) OR (pcf.parent_entity_id=cur_facility_cd)) )
   JOIN (ocs
   WHERE ocs.synonym_id=pc.parent_entity_id
    AND ocs.catalog_type_cd=cpharm)
   JOIN (d1
   WHERE (mylist2->vv[d1.seq].syn_id=ocs.synonym_id))
   JOIN (d2)
   JOIN (d3
   WHERE (available_products->products[d3.seq].catalog_cd=ocs.catalog_cd))
  ORDER BY powerplan_name, clinical_category, clinical_sub_category,
   synonym
  WITH outerjoin = d2, dontexist, format = pcformat
 ;end select
 GO TO cs_pp_problem_mode
#powerplan_med_noprod_exit
#form_ivset
 CALL clear_screen(0)
 CALL show_processing(0)
 SET cdesc = uar_get_code_by("MEANING",11000,"DESC")
 SET csystem = uar_get_code_by("MEANING",4062,"SYSTEM")
 SET csyspkgtyp = uar_get_code_by("MEANING",4062,"SYSPKGTYP")
 DECLARE line = vc
 SELECT INTO "asc_form_ivsets.csv"
  set_item_id = mis.parent_item_id, set_name = substring(1,60,mi.value), ingred_item_id = mis
  .child_item_id,
  ingred_item_name = substring(1,45,mi2.value), ingred_strength = mod2.strength, ingred_strength_unit
   = substring(1,20,uar_get_code_display(mod2.strength_unit_cd)),
  ingred_volume = mod2.volume, ingred_volume_unit = substring(1,20,uar_get_code_display(mod2
    .volume_unit_cd)), set_route_cd = substring(1,20,uar_get_code_display(mod.route_cd)),
  set_frequency_cd = substring(1,30,uar_get_code_display(mod.frequency_cd)), set_infuse_over = mod
  .infuse_over, set_infuse_over_unit = substring(1,20,uar_get_code_display(mod.infuse_over_cd)),
  set_duration = mod.duration, set_duration_unit = substring(1,20,uar_get_code_display(mod
    .duration_unit_cd)), set_dispense_category = substring(1,30,uar_get_code_display(mod
    .dispense_category_cd)),
  default_format = evaluate(md.oe_format_flag,1,"Medication",2,"Continuous",
   3,"Intermittent"), med_ind = md.med_filter_ind, int_ind = md.intermittent_filter_ind,
  cont_ind = md.continuous_filter_ind, note1 = substring(1,300,lt1.long_text), note2 = substring(1,
   300,lt2.long_text)
  FROM med_ingred_set mis,
   med_def_flex mdf,
   med_flex_object_idx mfoi,
   med_oe_defaults mod,
   med_identifier mi,
   med_identifier mi2,
   med_def_flex mdf2,
   med_flex_object_idx mfoi2,
   med_flex_object_idx mfoi4,
   med_dispense md,
   med_def_flex mdf3,
   med_flex_object_idx mfoi3,
   med_oe_defaults mod2,
   item_definition id,
   medication_definition mdef,
   dummyt d1,
   long_text lt1,
   dummyt d2,
   long_text lt2
  PLAN (mis
   WHERE mis.sequence > 0)
   JOIN (id
   WHERE id.item_id=mis.parent_item_id
    AND id.active_ind=1)
   JOIN (mdef
   WHERE mdef.item_id=mis.parent_item_id
    AND mdef.med_type_flag=3)
   JOIN (mdf
   WHERE mis.parent_item_id=mdf.item_id
    AND mdf.sequence=0
    AND mdf.flex_type_cd=csystem)
   JOIN (mfoi
   WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
    AND mfoi.parent_entity_name="MED_OE_DEFAULTS")
   JOIN (mod
   WHERE mod.med_oe_defaults_id=mfoi.parent_entity_id)
   JOIN (mi
   WHERE mis.parent_item_id=mi.item_id
    AND mi.med_product_id=0
    AND mi.med_identifier_type_cd=cdesc
    AND mi.primary_ind=1)
   JOIN (mi2
   WHERE mis.child_item_id=mi2.item_id
    AND mi2.med_product_id=0
    AND mi2.med_identifier_type_cd=cdesc
    AND mi2.primary_ind=1)
   JOIN (mdf2
   WHERE mis.parent_item_id=mdf2.item_id
    AND mdf2.sequence=0
    AND mdf2.flex_type_cd=csyspkgtyp)
   JOIN (mfoi2
   WHERE mfoi2.med_def_flex_id=mdf2.med_def_flex_id
    AND mfoi2.parent_entity_name="MED_DISPENSE")
   JOIN (mfoi4
   WHERE mfoi4.med_def_flex_id=mdf2.med_def_flex_id
    AND mfoi4.flex_object_type_cd=corderable
    AND ((mfoi4.parent_entity_id=0) OR (mfoi4.parent_entity_id=cur_facility_cd)) )
   JOIN (md
   WHERE md.med_dispense_id=mfoi2.parent_entity_id)
   JOIN (mdf3
   WHERE mis.parent_item_id=mdf3.item_id
    AND mdf3.sequence=mis.sequence
    AND mdf3.sequence > 0
    AND mdf3.flex_type_cd=csyspkgtyp)
   JOIN (mfoi3
   WHERE mfoi3.med_def_flex_id=mdf3.med_def_flex_id
    AND mfoi3.parent_entity_name="MED_OE_DEFAULTS")
   JOIN (mod2
   WHERE mod2.med_oe_defaults_id=mfoi3.parent_entity_id)
   JOIN (d1)
   JOIN (lt1
   WHERE lt1.long_text_id=mod.comment1_id
    AND mod.comment1_id > 0)
   JOIN (d2)
   JOIN (lt2
   WHERE lt2.long_text_id=mod.comment2_id
    AND mod.comment2_id > 0)
  ORDER BY cnvtupper(mi.value), mis.sequence
  HEAD REPORT
   col 0, "SET_ID,SET_NAME,ROUTE,FREQUENCY,INFUSE OVER,INFUSE_OVER_UNIT,DURATION,DURATION_UNIT,",
   "DISPENSE_CATEGORY,DEFAULT_FORMAT,MED_IND,INT_IND,CONT_IND,NOTE1,NOTE2,",
   "INGRED_ITEM_ID,INGRED_ITEM_DESC,INGRED_STRENGTH,INGRED_STRENGTH_UNIT,INGRED_VOLUME,",
   "INGRED_VOLUME_UNIT", row + 1
  HEAD mis.parent_item_id
   line = concat('"',trim(cnvtstring(mis.parent_item_id)),'"',",",'"',
    trim(mi.value),'"',",",'"',trim(uar_get_code_display(mod.route_cd)),
    '"',",",'"',trim(uar_get_code_display(mod.frequency_cd)),'"',
    ",",'"',trim(cnvtstring(mod.infuse_over)),'"',",",
    '"',trim(uar_get_code_display(mod.infuse_over_cd)),'"',",",'"',
    trim(cnvtstring(mod.duration)),'"',",",'"',trim(uar_get_code_display(mod.duration_unit_cd)),
    '"',",",'"',trim(uar_get_code_display(mod.dispense_category_cd)),'"',
    ",",'"',trim(default_format),'"',",",
    '"',trim(cnvtstring(md.med_filter_ind)),'"',",",'"',
    trim(cnvtstring(md.intermittent_filter_ind)),'"',",",'"',trim(cnvtstring(md.continuous_filter_ind
      )),
    '"',",",'"',trim(lt1.long_text),'"',
    ",",'"',trim(lt2.long_text),'"',",",
    '"','"',",",'"','"',
    ",",'"','"',",",'"',
    '"',",",'"','"',",",
    '"','"'), col 0, line,
   row + 1
  DETAIL
   line = concat('"','"',",",'"','"',
    ",",'"','"',",",'"',
    '"',",",'"','"',",",
    '"','"',",",'"','"',
    ",",'"','"',",",'"',
    '"',",",'"','"',",",
    '"','"',",",'"','"',
    ",",'"','"',",",'"',
    '"',",",'"','"',",",
    '"',trim(cnvtstring(mi2.item_id)),'"',",",'"',
    trim(mi2.value),'"',",",'"',trim(cnvtstring(mod2.strength)),
    '"',",",'"',trim(uar_get_code_display(mod2.strength_unit_cd)),'"',
    ",",'"',trim(cnvtstring(mod2.volume)),'"',",",
    '"',trim(uar_get_code_display(mod2.volume_unit_cd)),'"'), col 0, line,
   row + 1
  WITH check, maxcol = 500, format = variable,
   nullreport, noformfeed, landscape,
   maxrow = 1, outerjoin = d1, outerjoin = d2
 ;end select
#form_ivset_exit
#form_ivset_scr
 CALL clear_screen(0)
 CALL show_processing(0)
 SET cdesc = uar_get_code_by("MEANING",11000,"DESC")
 SET csystem = uar_get_code_by("MEANING",4062,"SYSTEM")
 SET csyspkgtyp = uar_get_code_by("MEANING",4062,"SYSPKGTYP")
 SET corderable = uar_get_code_by("MEANING",4063,"ORDERABLE")
 SELECT
  set_item_id = mis.parent_item_id, set_name = substring(1,60,mi.value), ingred_item_id = mis
  .child_item_id,
  ingred_item_name = substring(1,45,mi2.value), ingred_strength = mod2.strength, ingred_strength_unit
   = substring(1,20,uar_get_code_display(mod2.strength_unit_cd)),
  ingred_volume = mod2.volume, ingred_volume_unit = substring(1,20,uar_get_code_display(mod2
    .volume_unit_cd)), set_route_cd = substring(1,20,uar_get_code_display(mod.route_cd)),
  set_frequency_cd = substring(1,30,uar_get_code_display(mod.frequency_cd)), set_infuse_over = mod
  .infuse_over, set_infuse_over_unit = substring(1,20,uar_get_code_display(mod.infuse_over_cd)),
  set_duration = mod.duration, set_duration_unit = substring(1,20,uar_get_code_display(mod
    .duration_unit_cd)), set_dispense_category = substring(1,30,uar_get_code_display(mod
    .dispense_category_cd)),
  default_format = evaluate(md.oe_format_flag,1,"Medication",2,"Continuous",
   3,"Intermittent"), med_ind = md.med_filter_ind, int_ind = md.intermittent_filter_ind,
  cont_ind = md.continuous_filter_ind, note1 = substring(1,300,lt1.long_text), note2 = substring(1,
   300,lt2.long_text)
  FROM med_ingred_set mis,
   med_def_flex mdf,
   med_flex_object_idx mfoi,
   med_oe_defaults mod,
   med_identifier mi,
   med_identifier mi2,
   med_def_flex mdf2,
   med_flex_object_idx mfoi2,
   med_flex_object_idx mfoi4,
   med_dispense md,
   med_def_flex mdf3,
   med_flex_object_idx mfoi3,
   med_oe_defaults mod2,
   item_definition id,
   medication_definition mdef,
   dummyt d1,
   long_text lt1,
   dummyt d2,
   long_text lt2
  PLAN (mis
   WHERE mis.sequence > 0)
   JOIN (id
   WHERE id.item_id=mis.parent_item_id
    AND id.active_ind=1)
   JOIN (mdef
   WHERE mdef.item_id=mis.parent_item_id
    AND mdef.med_type_flag=3)
   JOIN (mdf
   WHERE mis.parent_item_id=mdf.item_id
    AND mdf.sequence=0
    AND mdf.flex_type_cd=csystem)
   JOIN (mfoi
   WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
    AND mfoi.parent_entity_name="MED_OE_DEFAULTS")
   JOIN (mod
   WHERE mod.med_oe_defaults_id=mfoi.parent_entity_id)
   JOIN (mi
   WHERE mis.parent_item_id=mi.item_id
    AND mi.med_product_id=0
    AND mi.med_identifier_type_cd=cdesc
    AND mi.primary_ind=1)
   JOIN (mi2
   WHERE mis.child_item_id=mi2.item_id
    AND mi2.med_product_id=0
    AND mi2.med_identifier_type_cd=cdesc
    AND mi2.primary_ind=1)
   JOIN (mdf2
   WHERE mis.parent_item_id=mdf2.item_id
    AND mdf2.sequence=0
    AND mdf2.flex_type_cd=csyspkgtyp)
   JOIN (mfoi2
   WHERE mfoi2.med_def_flex_id=mdf2.med_def_flex_id
    AND mfoi2.parent_entity_name="MED_DISPENSE")
   JOIN (mfoi4
   WHERE mfoi4.med_def_flex_id=mdf2.med_def_flex_id
    AND mfoi4.flex_object_type_cd=corderable
    AND ((mfoi4.parent_entity_id=0) OR (mfoi4.parent_entity_id=cur_facility_cd)) )
   JOIN (md
   WHERE md.med_dispense_id=mfoi2.parent_entity_id)
   JOIN (mdf3
   WHERE mis.parent_item_id=mdf3.item_id
    AND mdf3.sequence=mis.sequence
    AND mdf3.sequence > 0
    AND mdf3.flex_type_cd=csyspkgtyp)
   JOIN (mfoi3
   WHERE mfoi3.med_def_flex_id=mdf3.med_def_flex_id
    AND mfoi3.parent_entity_name="MED_OE_DEFAULTS")
   JOIN (mod2
   WHERE mod2.med_oe_defaults_id=mfoi3.parent_entity_id)
   JOIN (d1)
   JOIN (lt1
   WHERE lt1.long_text_id=mod.comment1_id
    AND mod.comment1_id > 0)
   JOIN (d2)
   JOIN (lt2
   WHERE lt2.long_text_id=mod.comment2_id
    AND mod.comment2_id > 0)
  ORDER BY cnvtupper(mi.value), mis.sequence
  WITH outerjoin = d1, outerjoin = d2, format = pcformat
 ;end select
#form_ivset_scr_exit
#replace_syn_oef
 CALL clear_screen(0)
 CALL text(5,1,"Enter first character(s) of synonym for OEF change:   ")
 CALL accept(5,56,"P(30);CU","")
 SET syn_loc_string = cnvtupper(curaccept)
 FREE RECORD syn_temp
 RECORD syn_temp(
   1 syn_list[*]
     2 syn_id = f8
     2 synonym = vc
     2 type = vc
 )
 SET syn_count = 0
 SET cpharm = uar_get_code_by("MEANING",6000,"PHARMACY")
 SET corder = uar_get_code_by("MEANING",6003,"ORDER")
 SELECT DISTINCT INTO "nl:"
  ocs.synonym_id, synonym = ocs.mnemonic, synonym_type = evaluate(trim(uar_get_code_display(ocs
     .mnemonic_type_cd)),"Ancillary","NON-CPOE","Brand Name","BRAND",
   "Direct Care Provider","DCP","C - Dispensable Drug Names","C","Generic Name",
   "NON-CPOE","Y - Generic Products","NON-CPOE","M - Generic Miscellaneous Products","M",
   "E - IV Fluids and Nicknames","E","Outreach","NON-CPOE","PathLink",
   "NON-CPOE","Primary","PRIMARY","Rx Mnemonic","NON-CPOE",
   "Surgery Med","NON-CPOE","Z - Trade Products","NON-CPOE","N - Trade Miscellaneous Products",
   "N")
  FROM order_catalog_synonym ocs
  PLAN (ocs
   WHERE ocs.catalog_type_cd=cpharm
    AND cnvtupper(ocs.mnemonic)=patstring(build(syn_loc_string,"*"))
    AND ocs.mnemonic_type_cd IN (
   (SELECT
    code_value
    FROM code_value
    WHERE code_set=6011
     AND cdf_meaning IN ("BRANDNAME", "DCP", "DISPDRUG", "GENERICTOP", "IVNAME",
    "PRIMARY", "TRADETOP")))
    AND ocs.active_ind=1)
  ORDER BY cnvtupper(ocs.mnemonic), synonym_type
  HEAD REPORT
   syn_count = 0
  DETAIL
   syn_count = (syn_count+ 1)
   IF (mod(syn_count,10)=1)
    stat = alterlist(syn_temp->syn_list,(syn_count+ 9))
   ENDIF
   syn_temp->syn_list[syn_count].syn_id = ocs.synonym_id, syn_temp->syn_list[syn_count].synonym =
   trim(ocs.mnemonic), syn_temp->syn_list[syn_count].type = synonym_type
  FOOT REPORT
   stat = alterlist(syn_temp->syn_list,syn_count)
  WITH nocounter
 ;end select
 CALL clear_screen(0)
 CALL text(3,2,"Medication Synonyms:")
 CALL text(3,38,build(syn_loc_string,"*"))
 CALL text(5,67,"Total:  ")
 CALL text(5,75,cnvtstring(syn_count,4))
 CALL create_std_box(syn_count)
 CALL text(6,8,"Synonym")
 WHILE (cnt <= numsrow
  AND cnt <= maxcnt)
   SET holdstr60 = trim(syn_temp->syn_list[cnt].synonym)
   SET holdstr20 = fillstring(20," ")
   SET holdstr20 = trim(syn_temp->syn_list[cnt].type)
   SET holdstr = concat(cnvtstring(cnt,4,0,r)," ",holdstr60," ",holdstr20)
   CALL scrolltext(cnt,holdstr)
   SET cnt = (cnt+ 1)
 ENDWHILE
 SET cnt = 1
 SET arow = 1
 CALL text(23,1,"Select synonym for OEF change:         (enter 000 to go back)")
 SET pick = 0
 WHILE (pick=0)
  CALL accept(23,33,"9999;S",cnt)
  CASE (curscroll)
   OF 0:
    IF (curaccept=0)
     CALL clear_screen(0)
     GO TO pharm_utilities_mode
    ELSEIF (cnvtint(curaccept) BETWEEN 1 AND maxcnt)
     SET pick = cnvtint(curaccept)
     CALL clear_screen(0)
     CALL replace_syn_oef(syn_temp->syn_list[pick].syn_id,syn_temp->syn_list[pick].synonym)
    ELSE
     CALL clear_screen(0)
     GO TO pharm_utilities_mode
    ENDIF
   OF 1:
    IF (cnt < maxcnt)
     SET cnt = (cnt+ 1)
     SET holdstr60 = trim(syn_temp->syn_list[cnt].synonym)
     SET holdstr20 = fillstring(20," ")
     SET holdstr20 = trim(syn_temp->syn_list[cnt].type)
     SET holdstr = concat(cnvtstring(cnt,4,0,r)," ",holdstr60," ",holdstr20)
     CALL down_arrow(holdstr)
    ENDIF
   OF 2:
    IF (cnt > 1)
     SET cnt = (cnt - 1)
     SET holdstr60 = trim(syn_temp->syn_list[cnt].synonym)
     SET holdstr20 = fillstring(20," ")
     SET holdstr20 = trim(syn_temp->syn_list[cnt].type)
     SET holdstr = concat(cnvtstring(cnt,4,0,r)," ",holdstr60," ",holdstr20)
     CALL up_arrow(holdstr)
    ENDIF
   OF 3:
   OF 4:
   OF 6:
    IF (numsrow < maxcnt)
     SET cnt = ((cnt+ numsrow) - 1)
     IF (((cnt+ numsrow) > maxcnt))
      SET cnt = (maxcnt - numsrow)
     ENDIF
     SET arow = 1
     WHILE (arow <= numsrow)
       SET cnt = (cnt+ 1)
       SET holdstr60 = trim(syn_temp->syn_list[cnt].synonym)
       SET holdstr20 = fillstring(20," ")
       SET holdstr20 = trim(syn_temp->syn_list[cnt].type)
       SET holdstr = concat(cnvtstring(cnt,4,0,r)," ",holdstr60," ",holdstr20)
       CALL scrolltext(arow,holdstr)
       SET arow = (arow+ 1)
     ENDWHILE
     SET arow = 1
     SET cnt = ((cnt - numsrow)+ 1)
    ENDIF
   OF 5:
    IF (((cnt - numsrow) > 0))
     SET cnt = (cnt - numsrow)
    ELSE
     SET cnt = 1
    ENDIF
    SET tmp1 = cnt
    SET arow = 1
    WHILE (arow <= numsrow
     AND cnt < maxcnt)
      SET holdstr60 = trim(syn_temp->syn_list[cnt].synonym)
      SET holdstr20 = fillstring(20," ")
      SET holdstr20 = trim(syn_temp->syn_list[cnt].type)
      SET holdstr = concat(cnvtstring(cnt,4,0,r)," ",holdstr60," ",holdstr20)
      CALL scrolltext(arow,holdstr)
      SET cnt = (cnt+ 1)
      SET arow = (arow+ 1)
    ENDWHILE
    SET cnt = tmp1
    SET arow = 1
  ENDCASE
 ENDWHILE
 CALL clear_screen(0)
 CALL text(23,1,"Replace another OEF? (Y/N) ")
 CALL accept(23,29,"C;CU","N"
  WHERE curaccept IN ("Y", "N"))
 CASE (curaccept)
  OF "Y":
   GO TO replace_syn_oef
  OF "N":
   GO TO pharm_utilities_mode
 ENDCASE
 GO TO pharm_utilities_mode
#replace_syn_oef_exit
#syn_lookup_cpoe_use
 CALL clear_screen(0)
 CALL text(5,1,"Enter first character(s) of synonym for lookup:   ")
 CALL accept(5,52,"P(30);CU","")
 SET syn_loc_string = cnvtupper(curaccept)
 FREE RECORD syn_temp
 RECORD syn_temp(
   1 syn_list[*]
     2 syn_id = f8
     2 synonym = vc
     2 type = vc
 )
 SET syn_count = 0
 SET cpharm = uar_get_code_by("MEANING",6000,"PHARMACY")
 SET corder = uar_get_code_by("MEANING",6003,"ORDER")
 SELECT DISTINCT INTO "nl:"
  ocs.synonym_id, synonym = ocs.mnemonic, synonym_type = evaluate(trim(uar_get_code_display(ocs
     .mnemonic_type_cd)),"Ancillary","NON-CPOE","Brand Name","BRAND",
   "Direct Care Provider","DCP","C - Dispensable Drug Names","C","Generic Name",
   "NON-CPOE","Y - Generic Products","NON-CPOE","M - Generic Miscellaneous Products","M",
   "E - IV Fluids and Nicknames","E","Outreach","NON-CPOE","PathLink",
   "NON-CPOE","Primary","PRIMARY","Rx Mnemonic","NON-CPOE",
   "Surgery Med","NON-CPOE","Z - Trade Products","NON-CPOE","N - Trade Miscellaneous Products",
   "N")
  FROM order_catalog_synonym ocs
  PLAN (ocs
   WHERE ocs.catalog_type_cd=cpharm
    AND cnvtupper(ocs.mnemonic)=patstring(build(syn_loc_string,"*")))
  ORDER BY cnvtupper(ocs.mnemonic), synonym_type
  HEAD REPORT
   syn_count = 0
  DETAIL
   syn_count = (syn_count+ 1)
   IF (mod(syn_count,10)=1)
    stat = alterlist(syn_temp->syn_list,(syn_count+ 9))
   ENDIF
   syn_temp->syn_list[syn_count].syn_id = ocs.synonym_id, syn_temp->syn_list[syn_count].synonym =
   trim(ocs.mnemonic), syn_temp->syn_list[syn_count].type = synonym_type
  FOOT REPORT
   stat = alterlist(syn_temp->syn_list,syn_count)
  WITH nocounter
 ;end select
 CALL clear_screen(0)
 CALL text(3,2,"Medication Synonyms:")
 CALL text(3,38,build(syn_loc_string,"*"))
 CALL text(5,67,"Total:  ")
 CALL text(5,75,cnvtstring(syn_count,4))
 CALL create_std_box(syn_count)
 CALL text(6,8,"Synonym")
 WHILE (cnt <= numsrow
  AND cnt <= maxcnt)
   SET holdstr60 = trim(syn_temp->syn_list[cnt].synonym)
   SET holdstr20 = fillstring(20," ")
   SET holdstr20 = trim(syn_temp->syn_list[cnt].type)
   SET holdstr = concat(cnvtstring(cnt,4,0,r)," ",holdstr60," ",holdstr20)
   CALL scrolltext(cnt,holdstr)
   SET cnt = (cnt+ 1)
 ENDWHILE
 SET cnt = 1
 SET arow = 1
 CALL text(23,1,"Select synonym for lookup:         (enter 000 to go back)")
 SET pick = 0
 WHILE (pick=0)
  CALL accept(23,29,"9999;S",cnt)
  CASE (curscroll)
   OF 0:
    IF (curaccept=0)
     CALL clear_screen(0)
     GO TO pharm_data_lookup_mode
    ELSEIF (cnvtint(curaccept) BETWEEN 1 AND maxcnt)
     SET pick = cnvtint(curaccept)
     CALL clear_screen(0)
    ELSE
     CALL clear_screen(0)
     GO TO pharm_data_lookup_mode
    ENDIF
   OF 1:
    IF (cnt < maxcnt)
     SET cnt = (cnt+ 1)
     SET holdstr60 = trim(syn_temp->syn_list[cnt].synonym)
     SET holdstr20 = fillstring(20," ")
     SET holdstr20 = trim(syn_temp->syn_list[cnt].type)
     SET holdstr = concat(cnvtstring(cnt,4,0,r)," ",holdstr60," ",holdstr20)
     CALL down_arrow(holdstr)
    ENDIF
   OF 2:
    IF (cnt > 1)
     SET cnt = (cnt - 1)
     SET holdstr60 = trim(syn_temp->syn_list[cnt].synonym)
     SET holdstr20 = fillstring(20," ")
     SET holdstr20 = trim(syn_temp->syn_list[cnt].type)
     SET holdstr = concat(cnvtstring(cnt,4,0,r)," ",holdstr60," ",holdstr20)
     CALL up_arrow(holdstr)
    ENDIF
   OF 3:
   OF 4:
   OF 6:
    IF (numsrow < maxcnt)
     SET cnt = ((cnt+ numsrow) - 1)
     IF (((cnt+ numsrow) > maxcnt))
      SET cnt = (maxcnt - numsrow)
     ENDIF
     SET arow = 1
     WHILE (arow <= numsrow)
       SET cnt = (cnt+ 1)
       SET holdstr60 = trim(syn_temp->syn_list[cnt].synonym)
       SET holdstr20 = fillstring(20," ")
       SET holdstr20 = trim(syn_temp->syn_list[cnt].type)
       SET holdstr = concat(cnvtstring(cnt,4,0,r)," ",holdstr60," ",holdstr20)
       CALL scrolltext(arow,holdstr)
       SET arow = (arow+ 1)
     ENDWHILE
     SET arow = 1
     SET cnt = ((cnt - numsrow)+ 1)
    ENDIF
   OF 5:
    IF (((cnt - numsrow) > 0))
     SET cnt = (cnt - numsrow)
    ELSE
     SET cnt = 1
    ENDIF
    SET tmp1 = cnt
    SET arow = 1
    WHILE (arow <= numsrow
     AND cnt < maxcnt)
      SET holdstr60 = trim(syn_temp->syn_list[cnt].synonym)
      SET holdstr20 = fillstring(20," ")
      SET holdstr20 = trim(syn_temp->syn_list[cnt].type)
      SET holdstr = concat(cnvtstring(cnt,4,0,r)," ",holdstr60," ",holdstr20)
      CALL scrolltext(arow,holdstr)
      SET cnt = (cnt+ 1)
      SET arow = (arow+ 1)
    ENDWHILE
    SET cnt = tmp1
    SET arow = 1
  ENDCASE
 ENDWHILE
 CALL clear_screen(0)
 DECLARE response_txt = vc
 CALL video("R")
 CALL text(4,3," * This information is not facility-specific ")
 CALL text(6,3,"Is synonym in favorites?    ")
 SET response_val = cnvtreal(is_syn_in_favorites(syn_temp->syn_list[pick].syn_id))
 IF (response_val=0)
  SET response_txt = "Not Used"
 ELSEIF (response_val=1)
  SET response_txt = "Used, no sentences attached"
 ELSEIF (response_val=2)
  SET response_txt = "Used, with sentences attached"
 ELSE
  SET response_txt = cnvtstring(response_val)
 ENDIF
 CALL text(6,33,response_txt)
 CALL text(7,3,"Is synonym in folders?      ")
 SET response_val = cnvtreal(is_syn_in_folders(syn_temp->syn_list[pick].syn_id))
 IF (response_val=0)
  SET response_txt = "Not Used"
 ELSEIF (response_val=1)
  SET response_txt = "Used, no sentences attached"
 ELSEIF (response_val=2)
  SET response_txt "Used, with sentences attached" elsee
  SET response_txt = cnvtstring(response_val)
 ENDIF
 CALL text(7,33,response_txt)
 CALL text(8,3,"Is synonym in PowerPlans?   ")
 SET response_val = cnvtreal(is_syn_in_powerplans(syn_temp->syn_list[pick].syn_id))
 IF (response_val=0)
  SET response_txt = "Not Used"
 ELSEIF (response_val=1)
  SET response_txt = "Used, no sentences attached"
 ELSEIF (response_val=2)
  SET response_txt = "Used, with sentences attached"
 ELSE
  SET response_txt = cnvtstring(response_val)
 ENDIF
 CALL text(8,33,response_txt)
 CALL text(9,3,"Is synonym in CareSets?     ")
 SET response_val = cnvtreal(is_syn_in_careset(syn_temp->syn_list[pick].syn_id))
 IF (response_val=0)
  SET response_txt = "Not Used"
 ELSEIF (response_val=1)
  SET response_txt = "Used, no sentences attached"
 ELSEIF (response_val=2)
  SET response_txt = "Used, with sentences attached"
 ELSE
  SET response_txt = cnvtstring(response_val)
 ENDIF
 CALL text(9,33,response_txt)
 CALL text(10,3,"Is synonym in PowerOrders?  ")
 SET response_val = cnvtreal(is_syn_in_powerorders(syn_temp->syn_list[pick].syn_id))
 IF (response_val=0)
  SET response_txt = "Not Used"
 ELSEIF (response_val=1)
  SET response_txt = "Used, no sentences attached"
 ELSEIF (response_val=2)
  SET response_txt = "Used, with sentences attached"
 ELSE
  SET response_txt = cnvtstring(response_val)
 ENDIF
 CALL text(10,33,response_txt)
 CALL video("N")
 CALL text(14,3,"Would you like to review this synonym's use in CPOE? (Y/N) ")
 CALL accept(14,64,"C;CU","Y"
  WHERE curaccept IN ("Y", "N"))
 CASE (curaccept)
  OF "Y":
   CALL display_syn_cpoe_usage(syn_temp->syn_list[pick].syn_id)
 ENDCASE
 GO TO pharm_data_lookup_mode
#syn_lookup_cpoe_use_exit
#subroutines
 SUBROUTINE clear_screen(abc)
   IF (abc=0)
    CALL clear(1,1)
   ENDIF
 END ;Subroutine
 SUBROUTINE show_processing(x)
  CALL clear_screen(0)
  CALL text(23,1,"Processing...")
 END ;Subroutine
 SUBROUTINE count_sentence_details(first_detail_pos)
   DECLARE result = f8
   IF (first_detail_pos > 0
    AND size(details->details,5) >= first_detail_pos)
    SET result = 1
   ENDIF
   SET pos = 0
   SET search_loc = first_detail_pos
   SET sent_id = details->details[search_loc].os_id
   IF (search_loc != size(details->details,5)
    AND first_detail_pos > 0)
    SET search_loc = (search_loc+ 1)
    WHILE (search_loc <= size(details->details,5)
     AND (details->details[search_loc].os_id=sent_id))
     SET result = (result+ 1)
     SET search_loc = (search_loc+ 1)
    ENDWHILE
   ENDIF
   RETURN(result)
 END ;Subroutine
 SUBROUTINE find_sentence_pos(sent_id)
   DECLARE result = f8
   SET result = 0
   SET pos = 0
   SET search_loc = 0
   SET pos = locateval(search_loc,1,size(details->details,5),sent_id,details->details[search_loc].
    os_id)
   IF ((details->details[search_loc].os_id=sent_id))
    SET result = search_loc
   ELSE
    SET result = 0
   ENDIF
   RETURN(result)
 END ;Subroutine
 SUBROUTINE get_sentence_detail_value(detail_pos)
   SET text_result = "error"
   IF (detail_pos > 0
    AND size(details->details,5) >= detail_pos)
    SET text_result = details->details[detail_pos].field_value
   ENDIF
   RETURN(text_result)
 END ;Subroutine
 SUBROUTINE get_sentence_detail_type(detail_pos)
   DECLARE result = f8
   IF (detail_pos > 0
    AND size(details->details,5) >= detail_pos)
    SET result = details->details[detail_pos].oe_field_id
   ENDIF
   RETURN(result)
 END ;Subroutine
 SUBROUTINE down_arrow(str1)
   IF (arow=numsrow)
    CALL scrolldown(arow,arow,str1)
   ELSE
    SET arow = (arow+ 1)
    CALL scrolldown((arow - 1),arow,str1)
   ENDIF
 END ;Subroutine
 SUBROUTINE up_arrow(strup)
   IF (arow=1)
    CALL scrollup(arow,arow,strup)
   ELSE
    SET arow = (arow - 1)
    CALL scrollup((arow+ 1),arow,strup)
   ENDIF
 END ;Subroutine
 SUBROUTINE create_std_box(mxcnt)
   SET maxcnt = mxcnt
   SET cnt = 1
   SET holdstr = ""
   CALL box(srowoff,scoloff,((srowoff+ numsrow)+ 1),((scoloff+ numscol)+ 1))
   CALL scrollinit((srowoff+ 1),(scoloff+ 1),(srowoff+ numsrow),(scoloff+ numscol))
 END ;Subroutine
 SUBROUTINE remap_form_prod(prd_item_id,prd_desc)
   CALL clear_screen(0)
   CALL text(5,1,"Enter first character(s) of destination orderable:   ")
   CALL accept(5,55,"P(30);CU","")
   SET ord_loc_string = trim(cnvtupper(curaccept))
   FREE RECORD oc
   RECORD oc(
     1 qual[*]
       2 catalog_cd = f8
       2 orderable = vc
       2 ref = c1
       2 active = c1
   )
   SET ocknt = 0
   SELECT INTO "nl:"
    oc.catalog_cd, oc.primary_mnemonic, oc.active_ind,
    oc.cki
    FROM order_catalog oc
    WHERE oc.catalog_type_cd IN (
    (SELECT
     code_value
     FROM code_value
     WHERE code_set=6000
      AND active_ind=1
      AND cdf_meaning="PHARMACY"))
     AND oc.orderable_type_flag IN (0, 1)
     AND cnvtupper(oc.primary_mnemonic)=patstring(build(ord_loc_string,"*"))
    ORDER BY cnvtupper(oc.primary_mnemonic)
    HEAD REPORT
     ocknt = 0
    DETAIL
     ocknt = (ocknt+ 1)
     IF (mod(ocknt,10)=1)
      stat = alterlist(oc->qual,(ocknt+ 9))
     ENDIF
     oc->qual[ocknt].catalog_cd = oc.catalog_cd, oc->qual[ocknt].orderable = substring(1,65,oc
      .primary_mnemonic), oc->qual[ocknt].ref = "1",
     oc->qual[ocknt].active = "1"
     IF (textlen(trim(oc.cki))=0)
      oc->qual[ocknt].ref = "0"
     ENDIF
     IF (oc.active_ind=0)
      oc->qual[ocknt].active = "0"
     ENDIF
    FOOT REPORT
     stat = alterlist(oc->qual,ocknt)
    WITH nocounter
   ;end select
   CALL clear_screen(0)
   CALL text(3,2,"Map ")
   CALL text(3,7,prd_desc)
   CALL text(5,67,"Total:  ")
   CALL text(5,75,cnvtstring(ocknt,4))
   CALL create_std_box(ocknt)
   CALL text(6,8,"Orderable ")
   CALL text(6,75,"A|R")
   WHILE (cnt <= numsrow
    AND cnt <= maxcnt)
     SET holdstr65 = oc->qual[cnt].orderable
     SET holdstr_r = oc->qual[cnt].ref
     SET holdstr_a = oc->qual[cnt].active
     SET holdstr = concat(cnvtstring(cnt,4,0,r),"  ",holdstr65," ",holdstr_a,
      "|",holdstr_r)
     CALL scrolltext(cnt,holdstr)
     SET cnt = (cnt+ 1)
   ENDWHILE
   SET cnt = 1
   SET arow = 1
   CALL text(23,1,"Select new orderable for product        (enter 000 to go back)")
   SET pick = 0
   WHILE (pick=0)
    CALL accept(23,35,"9999;S",cnt)
    CASE (curscroll)
     OF 0:
      IF (curaccept=0)
       CALL clear_screen(0)
       GO TO pharm_utilities_mode
      ELSEIF (cnvtint(curaccept) BETWEEN 1 AND maxcnt)
       SET pick = cnvtint(curaccept)
       CALL clear_screen(0)
      ELSE
       CALL clear_screen(0)
       GO TO exit_program
      ENDIF
     OF 1:
      IF (cnt < maxcnt)
       SET cnt = (cnt+ 1)
       SET holdstr65 = oc->qual[cnt].orderable
       SET holdstr_r = oc->qual[cnt].ref
       SET holdstr_a = oc->qual[cnt].active
       SET holdstr = concat(cnvtstring(cnt,4,0,r),"  ",holdstr65," ",holdstr_a,
        "|",holdstr_r)
       CALL down_arrow(holdstr)
      ENDIF
     OF 2:
      IF (cnt > 1)
       SET cnt = (cnt - 1)
       SET holdstr65 = oc->qual[cnt].orderable
       SET holdstr_r = oc->qual[cnt].ref
       SET holdstr_a = oc->qual[cnt].active
       SET holdstr = concat(cnvtstring(cnt,4,0,r),"  ",holdstr65," ",holdstr_a,
        "|",holdstr_r)
       CALL up_arrow(holdstr)
      ENDIF
     OF 3:
     OF 4:
     OF 6:
      IF (numsrow < maxcnt)
       SET cnt = ((cnt+ numsrow) - 1)
       IF (((cnt+ numsrow) > maxcnt))
        SET cnt = (maxcnt - numsrow)
       ENDIF
       SET arow = 1
       WHILE (arow <= numsrow)
         SET cnt = (cnt+ 1)
         SET holdstr65 = oc->qual[cnt].orderable
         SET holdstr_r = oc->qual[cnt].ref
         SET holdstr_a = oc->qual[cnt].active
         SET holdstr = concat(cnvtstring(cnt,4,0,r),"  ",holdstr65," ",holdstr_a,
          "|",holdstr_r)
         CALL scrolltext(arow,holdstr)
         SET arow = (arow+ 1)
       ENDWHILE
       SET arow = 1
       SET cnt = ((cnt - numsrow)+ 1)
      ENDIF
     OF 5:
      IF (((cnt - numsrow) > 0))
       SET cnt = (cnt - numsrow)
      ELSE
       SET cnt = 1
      ENDIF
      SET tmp1 = cnt
      SET arow = 1
      WHILE (arow <= numsrow
       AND cnt < maxcnt)
        SET holdstr65 = oc->qual[cnt].orderable
        SET holdstr_r = oc->qual[cnt].ref
        SET holdstr_a = oc->qual[cnt].active
        SET holdstr = concat(cnvtstring(cnt,4,0,r),"  ",holdstr65," ",holdstr_a,
         "|",holdstr_r)
        CALL scrolltext(arow,holdstr)
        SET cnt = (cnt+ 1)
        SET arow = (arow+ 1)
      ENDWHILE
      SET cnt = tmp1
      SET arow = 1
    ENDCASE
   ENDWHILE
   CALL text(5,2,"Map the following items:")
   SET txt2 = " "
   SET txt2 = concat("Formulary product: ",prd_desc)
   SET txt = " "
   SET txt = concat("Orderable: ",oc->qual[pick].orderable)
   CALL text(7,2,txt2)
   CALL text(8,2,txt)
   CALL text(15,1,"Execute? (Y/N) ")
   CALL accept(15,19,"C;CU"
    WHERE curaccept IN ("Y", "N"))
   CASE (curaccept)
    OF "Y":
     UPDATE  FROM order_catalog_item_r
      SET catalog_cd = oc->qual[pick].catalog_cd, updt_task = - (2516)
      WHERE item_id=prd_item_id
     ;end update
     UPDATE  FROM order_catalog_synonym
      SET catalog_cd = oc->qual[pick].catalog_cd, updt_task = - (2516)
      WHERE item_id=prd_item_id
       AND mnemonic_type_cd IN (
      (SELECT
       code_value
       FROM code_value
       WHERE cdf_meaning="RXMNEMONIC"))
     ;end update
     DELETE  FROM synonym_item_r
      WHERE item_id=prd_item_id
     ;end delete
     UPDATE  FROM med_oe_defaults
      SET ord_as_synonym_id = 0, updt_task = - (2516)
      WHERE med_oe_defaults_id IN (
      (SELECT
       med_oe_defaults_id
       FROM medication_definition md,
        med_def_flex mdf,
        med_flex_object_idx mfoi,
        med_oe_defaults mod
       PLAN (md
        WHERE md.item_id=prd_item_id)
        JOIN (mdf
        WHERE mdf.item_id=md.item_id
         AND mdf.flex_type_cd IN (
        (SELECT
         code_value
         FROM code_value
         WHERE code_set=4062
          AND cdf_meaning="SYSTEM"
          AND active_ind=1)))
        JOIN (mfoi
        WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
         AND mfoi.parent_entity_name="MED_OE_DEFAULTS")
        JOIN (mod
        WHERE mod.med_oe_defaults_id=mfoi.parent_entity_id)
        ))
     ;end update
     COMMIT
    OF "N":
     GO TO pharm_utilities_mode
   ENDCASE
 END ;Subroutine
 SUBROUTINE cpoe_lookup_synsent(lookup_id,lookup_desc)
   CALL clear_screen(0)
   DECLARE syn_attribute_line = vc
   SET cpharm = uar_get_code_by("MEANING",6000,"PHARMACY")
   SET corder = uar_get_code_by("MEANING",6003,"ORDER")
   SELECT
    synonym = ocs.mnemonic, synonym_type = evaluate(trim(uar_get_code_display(ocs.mnemonic_type_cd)),
     "Ancillary","NON-CPOE","Brand Name","Brand",
     "Direct Care Provider","DCP","C - Dispensable Drug Names","C","Generic Name",
     "NON-CPOE","Y - Generic Products","NON-CPOE","M - Generic Miscellaneous Products","M",
     "E - IV Fluids and Nicknames","E","Outreach","NON-CPOE","PathLink",
     "NON-CPOE","Primary","Primary","Rx Mnemonic","NON-CPOE",
     "Surgery Med","NON-CPOE","Z - Trade Products","NON-CPOE","N - Trade Miscellaneous Products",
     "N"), oef = substring(1,30,oef.oe_format_name),
    sentence = substring(1,60,ocsr.order_sentence_disp_line), rxmask = evaluate(ocs.rx_mask,1,
     "Diluent",2,"Additive",
     4,"Medication",6,"Medication+Additive",16,
     "Sliding Scale",32,"Taper",concat(build(ocs.rx_mask),", Not Recommended"))
    FROM order_catalog_synonym ocs,
     order_catalog oc,
     ocs_facility_r ofr,
     ord_cat_sent_r ocsr,
     code_value cv,
     order_entry_format oef,
     order_sentence os,
     filter_entity_reltn fer,
     dummyt d1,
     dummyt d2,
     dummyt d3
    PLAN (ocs
     WHERE ocs.catalog_cd=lookup_id
      AND ocs.catalog_type_cd=cpharm
      AND ocs.mnemonic_type_cd IN (
     (SELECT
      code_value
      FROM code_value
      WHERE code_set=6011
       AND cdf_meaning IN ("BRANDNAME", "DCP", "DISPDRUG", "GENERICTOP", "IVNAME",
      "PRIMARY", "TRADETOP")))
      AND ocs.active_ind=1
      AND ((ocs.hide_flag=0) OR (ocs.hide_flag=null)) )
     JOIN (oc
     WHERE oc.catalog_cd=ocs.catalog_cd)
     JOIN (ofr
     WHERE ofr.synonym_id=ocs.synonym_id
      AND ((ofr.facility_cd=0) OR (ofr.facility_cd=cur_facility_cd)) )
     JOIN (cv
     WHERE cv.code_value=ocs.mnemonic_type_cd)
     JOIN (d1)
     JOIN (oef
     WHERE ocs.oe_format_id=oef.oe_format_id
      AND oef.action_type_cd=corder)
     JOIN (d2)
     JOIN (ocsr
     WHERE ocsr.synonym_id=outerjoin(ocs.synonym_id))
     JOIN (d3)
     JOIN (os
     WHERE ocsr.order_sentence_id=os.order_sentence_id
      AND os.usage_flag IN (0, 1))
     JOIN (fer
     WHERE fer.parent_entity_id=os.order_sentence_id
      AND fer.parent_entity_name="ORDER_SENTENCE"
      AND fer.filter_entity1_name="LOCATION"
      AND ((fer.filter_entity1_id=0) OR (fer.filter_entity1_id=cur_facility_cd)) )
    ORDER BY cnvtupper(ocs.mnemonic), ocsr.display_seq, cnvtupper(ocsr.order_sentence_disp_line)
    HEAD REPORT
     line = fillstring(120,"_"), row + 1, col 0,
     "Orderable: ", col 13, oc.primary_mnemonic,
     row + 1, col 0, "Facility: ",
     col 13, cur_facility_desc, row + 1,
     col 0, line, row + 2
    HEAD ocs.mnemonic
     syn_attribute_line = build2("(",build(synonym_type),")")
     IF (ocs.oe_format_id > 0)
      syn_attribute_line = build2(syn_attribute_line," ",build(oef))
     ELSE
      syn_attribute_line = build2(syn_attribute_line," ","<no OEF assigned>")
     ENDIF
     IF (ocs.rx_mask > 0)
      syn_attribute_line = build2(syn_attribute_line,", ",rxmask)
     ELSE
      syn_attribute_line = build2(syn_attribute_line,", ","<no Rx mask assigned>")
     ENDIF
     col 1, synonym, row + 1,
     col 1, syn_attribute_line, row + 2
    DETAIL
     IF (os.order_sentence_id > 0)
      col 3, "- ", sentence,
      row + 1
     ENDIF
    FOOT  ocs.mnemonic
     row + 1
    FOOT REPORT
     row + 2, col 5, "*** END OF REPORT ***"
    WITH outerjoin = d1, outerjoin = d2, outerjoin = d3
   ;end select
 END ;Subroutine
 SUBROUTINE remap_syn_sent(syn_id,syn_desc)
   CALL clear_screen(0)
   CALL text(5,1,"Enter first character(s) of destination orderable:   ")
   CALL accept(5,55,"P(30);CU","")
   SET ord_loc_string = trim(cnvtupper(curaccept))
   FREE RECORD oc
   RECORD oc(
     1 qual[*]
       2 catalog_cd = f8
       2 orderable = vc
       2 ref = c1
       2 active = c1
   )
   SET ocknt = 0
   SELECT INTO "nl:"
    oc.catalog_cd, oc.primary_mnemonic, oc.active_ind,
    oc.cki
    FROM order_catalog oc
    WHERE oc.catalog_type_cd IN (
    (SELECT
     code_value
     FROM code_value
     WHERE code_set=6000
      AND active_ind=1
      AND cdf_meaning="PHARMACY"))
     AND cnvtupper(oc.primary_mnemonic)=patstring(build(ord_loc_string,"*"))
    ORDER BY cnvtupper(oc.primary_mnemonic)
    HEAD REPORT
     ocknt = 0
    DETAIL
     ocknt = (ocknt+ 1)
     IF (mod(ocknt,10)=1)
      stat = alterlist(oc->qual,(ocknt+ 9))
     ENDIF
     oc->qual[ocknt].catalog_cd = oc.catalog_cd, oc->qual[ocknt].orderable = substring(1,65,oc
      .primary_mnemonic), oc->qual[ocknt].ref = "1",
     oc->qual[ocknt].active = "1"
     IF (textlen(trim(oc.cki))=0)
      oc->qual[ocknt].ref = "0"
     ENDIF
     IF (oc.active_ind=0)
      oc->qual[ocknt].active = "0"
     ENDIF
    FOOT REPORT
     stat = alterlist(oc->qual,ocknt)
    WITH nocounter
   ;end select
   CALL clear_screen(0)
   CALL text(3,2,"Map ")
   CALL text(3,7,syn_desc)
   CALL text(5,67,"Total:  ")
   CALL text(5,75,cnvtstring(ocknt,4))
   CALL create_std_box(ocknt)
   CALL text(6,8,"Orderable ")
   CALL text(6,75,"A|R")
   WHILE (cnt <= numsrow
    AND cnt <= maxcnt)
     SET holdstr65 = oc->qual[cnt].orderable
     SET holdstr_r = oc->qual[cnt].ref
     SET holdstr_a = oc->qual[cnt].active
     SET holdstr = concat(cnvtstring(cnt,4,0,r),"  ",holdstr65," ",holdstr_a,
      "|",holdstr_r)
     CALL scrolltext(cnt,holdstr)
     SET cnt = (cnt+ 1)
   ENDWHILE
   SET cnt = 1
   SET arow = 1
   CALL text(23,1,"Select new orderable for product        (enter 000 to go back)")
   SET pick = 0
   WHILE (pick=0)
    CALL accept(23,35,"9999;S",cnt)
    CASE (curscroll)
     OF 0:
      IF (curaccept=0)
       CALL clear_screen(0)
       GO TO pharm_utilities_mode
      ELSEIF (cnvtint(curaccept) BETWEEN 1 AND maxcnt)
       SET pick = cnvtint(curaccept)
       CALL clear_screen(0)
      ELSE
       CALL clear_screen(0)
       GO TO exit_program
      ENDIF
     OF 1:
      IF (cnt < maxcnt)
       SET cnt = (cnt+ 1)
       SET holdstr65 = oc->qual[cnt].orderable
       SET holdstr_r = oc->qual[cnt].ref
       SET holdstr_a = oc->qual[cnt].active
       SET holdstr = concat(cnvtstring(cnt,4,0,r),"  ",holdstr65," ",holdstr_a,
        "|",holdstr_r)
       CALL down_arrow(holdstr)
      ENDIF
     OF 2:
      IF (cnt > 1)
       SET cnt = (cnt - 1)
       SET holdstr65 = oc->qual[cnt].orderable
       SET holdstr_r = oc->qual[cnt].ref
       SET holdstr_a = oc->qual[cnt].active
       SET holdstr = concat(cnvtstring(cnt,4,0,r),"  ",holdstr65," ",holdstr_a,
        "|",holdstr_r)
       CALL up_arrow(holdstr)
      ENDIF
     OF 3:
     OF 4:
     OF 6:
      IF (numsrow < maxcnt)
       SET cnt = ((cnt+ numsrow) - 1)
       IF (((cnt+ numsrow) > maxcnt))
        SET cnt = (maxcnt - numsrow)
       ENDIF
       SET arow = 1
       WHILE (arow <= numsrow)
         SET cnt = (cnt+ 1)
         SET holdstr65 = oc->qual[cnt].orderable
         SET holdstr_r = oc->qual[cnt].ref
         SET holdstr_a = oc->qual[cnt].active
         SET holdstr = concat(cnvtstring(cnt,4,0,r),"  ",holdstr65," ",holdstr_a,
          "|",holdstr_r)
         CALL scrolltext(arow,holdstr)
         SET arow = (arow+ 1)
       ENDWHILE
       SET arow = 1
       SET cnt = ((cnt - numsrow)+ 1)
      ENDIF
     OF 5:
      IF (((cnt - numsrow) > 0))
       SET cnt = (cnt - numsrow)
      ELSE
       SET cnt = 1
      ENDIF
      SET tmp1 = cnt
      SET arow = 1
      WHILE (arow <= numsrow
       AND cnt < maxcnt)
        SET holdstr65 = oc->qual[cnt].orderable
        SET holdstr_r = oc->qual[cnt].ref
        SET holdstr_a = oc->qual[cnt].active
        SET holdstr = concat(cnvtstring(cnt,4,0,r),"  ",holdstr65," ",holdstr_a,
         "|",holdstr_r)
        CALL scrolltext(arow,holdstr)
        SET cnt = (cnt+ 1)
        SET arow = (arow+ 1)
      ENDWHILE
      SET cnt = tmp1
      SET arow = 1
    ENDCASE
   ENDWHILE
   SET dest_cat_cd = oc->qual[pick].catalog_cd
   SET dest_ord = oc->qual[pick].orderable
   IF (syn_id > 0
    AND dest_cat_cd > 0)
    CALL text(5,2,"Remap the following items:")
    SET txt2 = " "
    SET txt2 = concat("Synonym: ",syn_desc)
    SET txt = " "
    SET txt = concat("Orderable: ",dest_ord)
    CALL text(7,2,txt2)
    CALL text(8,2,txt)
    CALL text(15,1,"Execute? (Y/N) ")
    CALL accept(15,19,"C;CU","Y"
     WHERE curaccept IN ("Y", "N"))
    CASE (curaccept)
     OF "Y":
      CALL show_processing(0)
      SET prev_cat_cd = 0
      SELECT INTO "nl:"
       ocs.catalog_cd
       FROM order_catalog_synonym ocs
       WHERE ocs.synonym_id=syn_id
       DETAIL
        prev_cat_cd = ocs.catalog_cd
      ;end select
      UPDATE  FROM order_catalog_synonym ocs
       SET ocs.catalog_cd = dest_cat_cd, ocs.updt_task = - (2516)
       WHERE ocs.synonym_id=syn_id
        AND ocs.catalog_cd=prev_cat_cd
      ;end update
      UPDATE  FROM ord_cat_sent_r ocsr
       SET ocsr.catalog_cd = dest_cat_cd, ocsr.updt_task = - (2516)
       WHERE ocsr.synonym_id=syn_id
        AND ocsr.catalog_cd=prev_cat_cd
      ;end update
      UPDATE  FROM order_sentence os
       SET os.parent_entity2_id = dest_cat_cd, os.updt_task = - (2516)
       WHERE os.parent_entity_id=syn_id
        AND os.parent_entity2_id=prev_cat_cd
        AND os.parent_entity_name="ORDER_CATALOG_SYNONYM"
        AND os.parent_entity2_name="ORDER_CATALOG"
      ;end update
      DELETE  FROM synonym_item_r
       WHERE synonym_id=syn_id
      ;end delete
      UPDATE  FROM med_oe_defaults
       SET ord_as_synonym_id = 0, updt_task = - (2516)
       WHERE ord_as_synonym_id=syn_id
      ;end update
      COMMIT
     OF "N":
      GO TO pharm_utilities_mode
    ENDCASE
   ENDIF
 END ;Subroutine
 SUBROUTINE lookup_ord_by_mmdc(inc_mmdc,inc_lookback_days)
   DECLARE sentence_line = vc
   SET cpharm = uar_get_code_by("MEANING",6000,"PHARMACY")
   SET cpharm = uar_get_code_by("MEANING",6000,"PHARMACY")
   SET cprimary = uar_get_code_by("MEANING",6011,"PRIMARY")
   SET csystem = uar_get_code_by("MEANING",4062,"SYSTEM")
   SET csyspkgtyp = uar_get_code_by("MEANING",4062,"SYSPKGTYP")
   SET corderable = uar_get_code_by("MEANING",4063,"ORDERABLE")
   SET cinpatient = uar_get_code_by("MEANING",4500,"INPATIENT")
   SET cdesc = uar_get_code_by("MEANING",11000,"DESC")
   FREE RECORD available_products
   RECORD available_products(
     1 products[*]
       2 item_id = f8
       2 catalog_cd = f8
   )
   SELECT INTO "nl:"
    md.item_id, product_desc = substring(1,50,mi.value), mfoi.*
    FROM medication_definition md,
     order_catalog_item_r ocir,
     item_definition id,
     med_def_flex mdf,
     med_flex_object_idx mfoi,
     med_identifier mi
    PLAN (md)
     JOIN (ocir
     WHERE ocir.item_id=md.item_id)
     JOIN (id
     WHERE id.item_id=ocir.item_id
      AND id.active_ind=1)
     JOIN (mdf
     WHERE mdf.item_id=md.item_id
      AND mdf.flex_type_cd=csyspkgtyp
      AND mdf.pharmacy_type_cd=cinpatient)
     JOIN (mfoi
     WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
      AND mfoi.flex_object_type_cd=corderable
      AND ((mfoi.parent_entity_id=0) OR (mfoi.parent_entity_id=cur_facility_cd)) )
     JOIN (mi
     WHERE mi.item_id=md.item_id
      AND mi.active_ind=1
      AND mi.primary_ind=1
      AND mi.med_product_id=0
      AND mi.med_identifier_type_cd=cdesc
      AND mi.pharmacy_type_cd=cinpatient)
    ORDER BY mi.value
    HEAD REPORT
     cnt = 0
    HEAD md.item_id
     cnt = (cnt+ 1), stat = alterlist(available_products->products,cnt), available_products->
     products[cnt].item_id = md.item_id,
     available_products->products[cnt].catalog_cd = ocir.catalog_cd
    WITH nullreport
   ;end select
   FREE RECORD list
   RECORD list(
     1 orders[*]
       2 order_sentence = vc
       2 count = f8
   )
   SELECT INTO "nl:"
    o.order_id, order_name = substring(1,40,o.order_mnemonic), strengthdose = od1.oe_field_value,
    strengthdoseunit = uar_get_code_display(od2.oe_field_value), volumedose = od3.oe_field_value,
    volumedoseunit = uar_get_code_display(od4.oe_field_value),
    frequency = uar_get_code_display(od8.oe_field_value), route = uar_get_code_display(od5
     .oe_field_value), prn = od6.oe_field_value,
    prn_reason = uar_get_code_display(od7.oe_field_value)
    FROM orders o,
     encntr_domain ed,
     order_product op,
     (dummyt d  WITH seq = value(size(available_products->products,5))),
     order_detail od1,
     order_detail od2,
     order_detail od3,
     order_detail od4,
     order_detail od5,
     order_detail od6,
     order_detail od7,
     order_detail od8
    PLAN (o
     WHERE o.catalog_type_cd=cpharm
      AND o.orig_order_dt_tm > cnvtdatetime((curdate - inc_lookback_days),curtime3)
      AND o.orig_ord_as_flag=0
      AND o.template_order_flag IN (0, 1)
      AND o.cs_flag != 1)
     JOIN (ed
     WHERE ed.encntr_id=o.encntr_id
      AND ((cur_facility_cd=0) OR (ed.loc_facility_cd=cur_facility_cd)) )
     JOIN (op
     WHERE op.order_id=o.order_id
      AND op.item_id IN (
     (SELECT
      md.item_id
      FROM medication_definition md
      WHERE md.cki=concat("MUL.FRMLTN!",cnvtstring(inc_mmdc,4,0))))
      AND op.action_sequence=1)
     JOIN (d
     WHERE (available_products->products[d.seq].item_id=op.item_id))
     JOIN (od1
     WHERE od1.order_id=outerjoin(o.order_id)
      AND od1.oe_field_meaning=outerjoin("STRENGTHDOSE")
      AND op.action_sequence=od1.action_sequence)
     JOIN (od2
     WHERE od2.order_id=outerjoin(o.order_id)
      AND od2.oe_field_meaning=outerjoin("STRENGTHDOSEUNIT")
      AND op.action_sequence=od2.action_sequence)
     JOIN (od3
     WHERE od3.order_id=outerjoin(o.order_id)
      AND od3.oe_field_meaning=outerjoin("VOLUMEDOSE")
      AND op.action_sequence=od3.action_sequence)
     JOIN (od4
     WHERE od4.order_id=outerjoin(o.order_id)
      AND od4.oe_field_meaning=outerjoin("VOLUMEDOSEUNIT")
      AND op.action_sequence=od4.action_sequence)
     JOIN (od5
     WHERE od5.order_id=outerjoin(o.order_id)
      AND od5.oe_field_meaning=outerjoin("RXROUTE")
      AND op.action_sequence=od5.action_sequence)
     JOIN (od6
     WHERE od6.order_id=outerjoin(o.order_id)
      AND od6.oe_field_meaning=outerjoin("SCH/PRN"))
     JOIN (od7
     WHERE od7.order_id=outerjoin(o.order_id)
      AND od7.oe_field_meaning=outerjoin("PRNREASON"))
     JOIN (od8
     WHERE od8.order_id=outerjoin(o.order_id)
      AND od8.oe_field_meaning=outerjoin("FREQ"))
    HEAD REPORT
     cnt = 0, assigned = 0, col 0,
     "Orders:", row + 2, pos = 0,
     search_loc = 0
    HEAD o.order_id
     cnt = (cnt+ 1), sentence_line = "Error"
     IF (od1.oe_field_value > 0
      AND od2.oe_field_value > 0
      AND od3.oe_field_value > 0
      AND od4.oe_field_value > 0)
      sentence_line = concat(trim(cnvtstring(strengthdose,11,3))," ",trim(strengthdoseunit)," / ",
       trim(cnvtstring(volumedose,11,3)),
       " ",trim(volumedoseunit))
     ELSEIF (od1.oe_field_value > 0
      AND od2.oe_field_value > 0)
      sentence_line = concat(trim(cnvtstring(strengthdose,11,3)),trim(uar_get_code_display(
         strengthdoseunit)))
     ELSEIF (od3.oe_field_value > 0
      AND od4.oe_field_value > 0)
      vol = concat(trim(cnvtstring(volumedose,11,3)),trim(uar_get_code_display(volumedoseunit)))
     ENDIF
     IF (od8.oe_field_value > 0)
      sentence_line = concat(sentence_line,", ",trim(frequency))
     ENDIF
     sentence_line = concat(sentence_line,", ",route)
     IF (prn=1)
      sentence_line = concat(sentence_line,", ","PRN")
     ENDIF
     IF (od7.oe_field_value > 0)
      sentence_line = concat(sentence_line,", ","reason: ",trim(prn_reason))
     ENDIF
     IF (size(list->orders,5)=0)
      stat = alterlist(list->orders,1), list->orders[1].order_sentence = sentence_line, list->orders[
      1].count = 1,
      assigned = (assigned+ 1)
     ELSE
      pos = locateval(search_loc,1,size(list->orders,5),sentence_line,list->orders[search_loc].
       order_sentence)
      IF ((list->orders[search_loc].order_sentence=sentence_line)
       AND sentence_line != "Error")
       list->orders[search_loc].count = (list->orders[search_loc].count+ 1), assigned = (assigned+ 1)
      ELSE
       stat = alterlist(list->orders,(size(list->orders,5)+ 1)), list->orders[size(list->orders,5)].
       order_sentence = sentence_line, list->orders[size(list->orders,5)].count = 1,
       assigned = (assigned+ 1)
      ENDIF
     ENDIF
   ;end select
   SELECT
    sentence = substring(1,100,list->orders[d.seq].order_sentence), count = cnvtstring(list->orders[d
     .seq].count,3,0)
    FROM (dummyt d  WITH seq = value(size(list->orders,5)))
    ORDER BY list->orders[d.seq].count DESC
    HEAD REPORT
     line = fillstring(120,"-"), col 0, "Count:",
     col 10, "Sentence:", row + 1,
     col 0, line, row + 1
    DETAIL
     col 3, count, col 10,
     sentence, row + 1
   ;end select
 END ;Subroutine
 SUBROUTINE load_current_vv(x)
   SELECT DISTINCT INTO "nl:"
    ofr.synonym_id
    FROM ocs_facility_r ofr,
     order_catalog_synonym ocs,
     order_catalog oc
    PLAN (ofr)
     JOIN (ocs
     WHERE ofr.synonym_id=ocs.synonym_id
      AND ocs.active_ind=1
      AND ((ofr.facility_cd=cur_facility_cd) OR (ofr.facility_cd=0)) )
     JOIN (oc
     WHERE oc.catalog_cd=ocs.catalog_cd
      AND oc.orderable_type_flag IN (0, 1)
      AND oc.catalog_type_cd=cpharm)
    HEAD REPORT
     row_cnt = 0
    DETAIL
     row_cnt = (row_cnt+ 1), stat = alterlist(mylist2->vv,row_cnt), mylist2->vv[row_cnt].syn_id = ofr
     .synonym_id,
     mylist2->vv[row_cnt].vv_ind = "1"
    WITH nullreport
   ;end select
 END ;Subroutine
 SUBROUTINE find_sentence_pos_itm(inc_item_id,inc_sent)
   DECLARE result = f8
   SET result = 0
   SET pos = 0
   SET search_loc = 0
   SET start_loc = 1
   WHILE (start_loc <= size(list->orders,5)
    AND result=0)
    SET pos = locateval(search_loc,start_loc,size(list->orders,5),inc_item_id,list->orders[search_loc
     ].item_id)
    IF ((list->orders[search_loc].item_id=inc_item_id)
     AND trim(list->orders[search_loc].order_sentence)=trim(inc_sent))
     SET result = search_loc
    ELSE
     SET start_loc = (search_loc+ 1)
    ENDIF
   ENDWHILE
   RETURN(result)
 END ;Subroutine
 SUBROUTINE find_sentence_pos_mmdc(inc_mmdc,inc_sent)
   DECLARE result = f8
   SET result = 0
   SET pos = 0
   SET search_loc = 0
   SET start_loc = 1
   WHILE (start_loc <= size(list->orders,5)
    AND result=0)
    SET pos = locateval(search_loc,start_loc,size(list->orders,5),inc_mmdc,list->orders[search_loc].
     mmdc_cki)
    IF ((list->orders[search_loc].mmdc_cki=inc_mmdc)
     AND trim(list->orders[search_loc].order_sentence)=trim(inc_sent))
     SET result = search_loc
    ELSE
     SET start_loc = (search_loc+ 1)
    ENDIF
   ENDWHILE
   RETURN(result)
 END ;Subroutine
 SUBROUTINE replace_pp_syn(old_syn_id,old_syn_desc)
   CALL clear_screen(0)
   FREE RECORD syn_temp
   RECORD syn_temp(
     1 syn_list[*]
       2 syn_id = f8
       2 synonym = vc
       2 type = vc
       2 rx_mask = i4
   )
   SET syn_count = 0
   SET cpharm = uar_get_code_by("MEANING",6000,"PHARMACY")
   SET corder = uar_get_code_by("MEANING",6003,"ORDER")
   SET old_syn_rxmask = 0
   SET old_syn_oef = 0
   SELECT INTO "nl:"
    ocs.synonym_id, ocs.rx_mask, ocs.oe_format_id
    FROM order_catalog_synonym ocs
    WHERE ocs.synonym_id=old_syn_id
    DETAIL
     old_syn_rxmask = ocs.rx_mask, old_syn_oef = ocs.oe_format_id
    WITH nullreport
   ;end select
   SELECT INTO "nl:"
    ocs.synonym_id, synonym = ocs.mnemonic, synonym_type = evaluate(trim(uar_get_code_display(ocs
       .mnemonic_type_cd)),"Ancillary","NON-CPOE","Brand Name","BRAND",
     "Direct Care Provider","DCP","C - Dispensable Drug Names","C","Generic Name",
     "NON-CPOE","Y - Generic Products","NON-CPOE","M - Generic Miscellaneous Products","M",
     "E - IV Fluids and Nicknames","E","Outreach","NON-CPOE","PathLink",
     "NON-CPOE","Primary","PRIMARY","Rx Mnemonic","NON-CPOE",
     "Surgery Med","NON-CPOE","Z - Trade Products","NON-CPOE","N - Trade Miscellaneous Products",
     "N")
    FROM order_catalog_synonym ocs,
     ocs_facility_r ofr
    PLAN (ocs
     WHERE ocs.catalog_type_cd=cpharm
      AND ocs.catalog_cd IN (
     (SELECT
      catalog_cd
      FROM order_catalog_synonym
      WHERE synonym_id=old_syn_id))
      AND ocs.mnemonic_type_cd IN (
     (SELECT
      code_value
      FROM code_value
      WHERE code_set=6011
       AND cdf_meaning IN ("BRANDNAME", "DCP", "DISPDRUG", "GENERICTOP", "IVNAME",
      "PRIMARY", "TRADETOP")))
      AND ((ocs.hide_flag=0) OR (ocs.hide_flag=null))
      AND ocs.active_ind=1
      AND ocs.synonym_id != old_syn_id
      AND ocs.oe_format_id=old_syn_oef)
     JOIN (ofr
     WHERE ofr.synonym_id=ocs.synonym_id
      AND ((ofr.facility_cd=0) OR (ofr.facility_cd=cur_facility_cd)) )
    ORDER BY cnvtupper(ocs.mnemonic), synonym_type
    HEAD REPORT
     syn_count = 0
    DETAIL
     syn_count = (syn_count+ 1)
     IF (mod(syn_count,10)=1)
      stat = alterlist(syn_temp->syn_list,(syn_count+ 9))
     ENDIF
     syn_temp->syn_list[syn_count].syn_id = ocs.synonym_id, syn_temp->syn_list[syn_count].synonym =
     trim(ocs.mnemonic), syn_temp->syn_list[syn_count].type = synonym_type,
     syn_temp->syn_list[syn_count].rx_mask = ocs.rx_mask
    FOOT REPORT
     stat = alterlist(syn_temp->syn_list,syn_count)
    WITH nocounter
   ;end select
   CALL clear_screen(0)
   CALL text(3,2,"Medication synonyms available:")
   CALL text(5,67,"Total:  ")
   CALL text(5,75,cnvtstring(syn_count,4))
   CALL create_std_box(syn_count)
   CALL text(6,8,"Synonym")
   WHILE (cnt <= numsrow
    AND cnt <= maxcnt)
     SET holdstr60 = trim(syn_temp->syn_list[cnt].synonym)
     SET holdstr20 = fillstring(20," ")
     SET holdstr20 = trim(syn_temp->syn_list[cnt].type)
     SET holdstr = concat(cnvtstring(cnt,4,0,r)," ",holdstr60," ",holdstr20)
     CALL scrolltext(cnt,holdstr)
     SET cnt = (cnt+ 1)
   ENDWHILE
   SET cnt = 1
   SET arow = 1
   CALL text(23,1,"Select replacement synonym           (enter 000 to go back)")
   SET pick = 0
   WHILE (pick=0)
    CALL accept(23,32,"9999;S",cnt)
    CASE (curscroll)
     OF 0:
      IF (curaccept=0)
       CALL clear_screen(0)
       GO TO common_utilities_mode
      ELSEIF (cnvtint(curaccept) BETWEEN 1 AND maxcnt)
       SET pick = cnvtint(curaccept)
       CALL clear_screen(0)
      ELSE
       CALL clear_screen(0)
       GO TO common_utilities_mode
      ENDIF
     OF 1:
      IF (cnt < maxcnt)
       SET cnt = (cnt+ 1)
       SET holdstr60 = trim(syn_temp->syn_list[cnt].synonym)
       SET holdstr20 = fillstring(20," ")
       SET holdstr20 = trim(syn_temp->syn_list[cnt].type)
       SET holdstr = concat(cnvtstring(cnt,4,0,r)," ",holdstr60," ",holdstr20)
       CALL down_arrow(holdstr)
      ENDIF
     OF 2:
      IF (cnt > 1)
       SET cnt = (cnt - 1)
       SET holdstr60 = trim(syn_temp->syn_list[cnt].synonym)
       SET holdstr20 = fillstring(20," ")
       SET holdstr20 = trim(syn_temp->syn_list[cnt].type)
       SET holdstr = concat(cnvtstring(cnt,4,0,r)," ",holdstr60," ",holdstr20)
       CALL up_arrow(holdstr)
      ENDIF
     OF 3:
     OF 4:
     OF 6:
      IF (numsrow < maxcnt)
       SET cnt = ((cnt+ numsrow) - 1)
       IF (((cnt+ numsrow) > maxcnt))
        SET cnt = (maxcnt - numsrow)
       ENDIF
       SET arow = 1
       WHILE (arow <= numsrow)
         SET cnt = (cnt+ 1)
         SET holdstr60 = trim(syn_temp->syn_list[cnt].synonym)
         SET holdstr20 = fillstring(20," ")
         SET holdstr20 = trim(syn_temp->syn_list[cnt].type)
         SET holdstr = concat(cnvtstring(cnt,4,0,r)," ",holdstr60," ",holdstr20)
         CALL scrolltext(arow,holdstr)
         SET arow = (arow+ 1)
       ENDWHILE
       SET arow = 1
       SET cnt = ((cnt - numsrow)+ 1)
      ENDIF
     OF 5:
      IF (((cnt - numsrow) > 0))
       SET cnt = (cnt - numsrow)
      ELSE
       SET cnt = 1
      ENDIF
      SET tmp1 = cnt
      SET arow = 1
      WHILE (arow <= numsrow
       AND cnt < maxcnt)
        SET holdstr60 = trim(syn_temp->syn_list[cnt].synonym)
        SET holdstr20 = fillstring(20," ")
        SET holdstr20 = trim(syn_temp->syn_list[cnt].type)
        SET holdstr = concat(cnvtstring(cnt,4,0,r)," ",holdstr60," ",holdstr20)
        CALL scrolltext(arow,holdstr)
        SET cnt = (cnt+ 1)
        SET arow = (arow+ 1)
      ENDWHILE
      SET cnt = tmp1
      SET arow = 1
    ENDCASE
   ENDWHILE
   SET dest_syn_id = syn_temp->syn_list[pick].syn_id
   SET dest_syn_desc = syn_temp->syn_list[pick].synonym
   SET dest_syn_rxmask = syn_temp->syn_list[pick].rx_mask
   IF (compare_rx_masks(old_syn_rxmask,dest_syn_rxmask)=false)
    CALL clear_screen(0)
    CALL text(5,1,"RX mask on new synonym differs from existing synonym.")
    CALL text(7,2,concat("Existing synonym:  ",cnvtstring(old_syn_rxmask)))
    CALL text(8,2,concat("New synonym:       ",cnvtstring(dest_syn_rxmask)))
    CALL text(10,1,"Proceed with replacement? (Y/N)  ")
    CALL accept(10,35,"C;CU","N"
     WHERE curaccept IN ("Y", "N"))
    CASE (curaccept)
     OF "Y":
      SET continue_flag = true
     OF "N":
      SET continue_flag = false
    ENDCASE
   ELSE
    SET continue_flag = true
   ENDIF
   IF (dest_syn_id > 0
    AND old_syn_id > 0
    AND continue_flag=true)
    CALL clear_screen(0)
    CALL text(5,1,"Make this replacement in all PowerPlans? ")
    CALL text(7,1," * This replacement is NOT facility-specific ")
    CALL accept(5,48,"C;CU","Y"
     WHERE curaccept IN ("Y", "N"))
    IF (curaccept="Y")
     CALL clear_screen(0)
     CALL text(5,1,"Making the following PowerPlan synonym replacement:")
     CALL text(7,2,concat("Existing synonym:  ",old_syn_desc))
     CALL text(8,2,concat("New synonym:       ",dest_syn_desc))
     CALL text(10,1,"Execute? (Y/N) ")
     CALL accept(10,17,"C;CU","Y"
      WHERE curaccept IN ("Y", "N"))
     CASE (curaccept)
      OF "Y":
       UPDATE  FROM pathway_comp pc
        SET parent_entity_id = dest_syn_id, updt_task = - (2516)
        WHERE parent_entity_id=old_syn_id
        WITH nocounter
       ;end update
       COMMIT
      OF "N":
       GO TO common_utilities_mode
     ENDCASE
    ELSE
     CALL replace_specific_pp_syn(old_syn_id,dest_syn_id)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE replace_ivs_syn(old_syn_id,old_syn_desc)
   CALL clear_screen(0)
   FREE RECORD syn_temp
   RECORD syn_temp(
     1 syn_list[*]
       2 syn_id = f8
       2 synonym = vc
       2 type = vc
       2 rx_mask = i4
   )
   SET syn_count = 0
   SET cpharm = uar_get_code_by("MEANING",6000,"PHARMACY")
   SET corder = uar_get_code_by("MEANING",6003,"ORDER")
   SET old_syn_rxmask = 0
   SET old_syn_oef = 0
   SELECT INTO "nl:"
    ocs.synonym_id, ocs.rx_mask, ocs.oe_format_id
    FROM order_catalog_synonym ocs
    WHERE ocs.synonym_id=old_syn_id
    DETAIL
     old_syn_rxmask = ocs.rx_mask, old_syn_oef = ocs.oe_format_id
    WITH nullreport
   ;end select
   SELECT INTO "nl:"
    ocs.synonym_id, synonym = ocs.mnemonic, synonym_type = evaluate(trim(uar_get_code_display(ocs
       .mnemonic_type_cd)),"Ancillary","NON-CPOE","Brand Name","BRAND",
     "Direct Care Provider","DCP","C - Dispensable Drug Names","C","Generic Name",
     "NON-CPOE","Y - Generic Products","NON-CPOE","M - Generic Miscellaneous Products","M",
     "E - IV Fluids and Nicknames","E","Outreach","NON-CPOE","PathLink",
     "NON-CPOE","Primary","PRIMARY","Rx Mnemonic","NON-CPOE",
     "Surgery Med","NON-CPOE","Z - Trade Products","NON-CPOE","N - Trade Miscellaneous Products",
     "N")
    FROM order_catalog_synonym ocs
    PLAN (ocs
     WHERE ocs.catalog_type_cd=cpharm
      AND ocs.catalog_cd IN (
     (SELECT
      catalog_cd
      FROM order_catalog_synonym
      WHERE synonym_id=old_syn_id))
      AND ocs.mnemonic_type_cd IN (
     (SELECT
      code_value
      FROM code_value
      WHERE code_set=6011
       AND cdf_meaning IN ("BRANDNAME", "DCP", "DISPDRUG", "GENERICTOP", "IVNAME",
      "PRIMARY", "TRADETOP")))
      AND ocs.active_ind=1
      AND ocs.synonym_id != old_syn_id
      AND ocs.rx_mask IN (2, 6))
    ORDER BY cnvtupper(ocs.mnemonic), synonym_type
    HEAD REPORT
     syn_count = 0
    DETAIL
     syn_count = (syn_count+ 1)
     IF (mod(syn_count,10)=1)
      stat = alterlist(syn_temp->syn_list,(syn_count+ 9))
     ENDIF
     syn_temp->syn_list[syn_count].syn_id = ocs.synonym_id, syn_temp->syn_list[syn_count].synonym =
     trim(ocs.mnemonic), syn_temp->syn_list[syn_count].type = synonym_type,
     syn_temp->syn_list[syn_count].rx_mask = ocs.rx_mask
    FOOT REPORT
     stat = alterlist(syn_temp->syn_list,syn_count)
    WITH nocounter
   ;end select
   CALL clear_screen(0)
   CALL text(3,2,"Medication synonyms available:")
   CALL text(5,67,"Total:  ")
   CALL text(5,75,cnvtstring(syn_count,4))
   CALL create_std_box(syn_count)
   CALL text(6,8,"Synonym")
   WHILE (cnt <= numsrow
    AND cnt <= maxcnt)
     SET holdstr60 = trim(syn_temp->syn_list[cnt].synonym)
     SET holdstr20 = fillstring(20," ")
     SET holdstr20 = trim(syn_temp->syn_list[cnt].type)
     SET holdstr = concat(cnvtstring(cnt,4,0,r)," ",holdstr60," ",holdstr20)
     CALL scrolltext(cnt,holdstr)
     SET cnt = (cnt+ 1)
   ENDWHILE
   SET cnt = 1
   SET arow = 1
   CALL text(23,1,"Select replacement synonym           (enter 000 to go back)")
   SET pick = 0
   WHILE (pick=0)
    CALL accept(23,32,"9999;S",cnt)
    CASE (curscroll)
     OF 0:
      IF (curaccept=0)
       CALL clear_screen(0)
       GO TO common_utilities_mode
      ELSEIF (cnvtint(curaccept) BETWEEN 1 AND maxcnt)
       SET pick = cnvtint(curaccept)
       CALL clear_screen(0)
      ELSE
       CALL clear_screen(0)
       GO TO common_utilities_mode
      ENDIF
     OF 1:
      IF (cnt < maxcnt)
       SET cnt = (cnt+ 1)
       SET holdstr60 = trim(syn_temp->syn_list[cnt].synonym)
       SET holdstr20 = fillstring(20," ")
       SET holdstr20 = trim(syn_temp->syn_list[cnt].type)
       SET holdstr = concat(cnvtstring(cnt,4,0,r)," ",holdstr60," ",holdstr20)
       CALL down_arrow(holdstr)
      ENDIF
     OF 2:
      IF (cnt > 1)
       SET cnt = (cnt - 1)
       SET holdstr60 = trim(syn_temp->syn_list[cnt].synonym)
       SET holdstr20 = fillstring(20," ")
       SET holdstr20 = trim(syn_temp->syn_list[cnt].type)
       SET holdstr = concat(cnvtstring(cnt,4,0,r)," ",holdstr60," ",holdstr20)
       CALL up_arrow(holdstr)
      ENDIF
     OF 3:
     OF 4:
     OF 6:
      IF (numsrow < maxcnt)
       SET cnt = ((cnt+ numsrow) - 1)
       IF (((cnt+ numsrow) > maxcnt))
        SET cnt = (maxcnt - numsrow)
       ENDIF
       SET arow = 1
       WHILE (arow <= numsrow)
         SET cnt = (cnt+ 1)
         SET holdstr60 = trim(syn_temp->syn_list[cnt].synonym)
         SET holdstr20 = fillstring(20," ")
         SET holdstr20 = trim(syn_temp->syn_list[cnt].type)
         SET holdstr = concat(cnvtstring(cnt,4,0,r)," ",holdstr60," ",holdstr20)
         CALL scrolltext(arow,holdstr)
         SET arow = (arow+ 1)
       ENDWHILE
       SET arow = 1
       SET cnt = ((cnt - numsrow)+ 1)
      ENDIF
     OF 5:
      IF (((cnt - numsrow) > 0))
       SET cnt = (cnt - numsrow)
      ELSE
       SET cnt = 1
      ENDIF
      SET tmp1 = cnt
      SET arow = 1
      WHILE (arow <= numsrow
       AND cnt < maxcnt)
        SET holdstr60 = trim(syn_temp->syn_list[cnt].synonym)
        SET holdstr20 = fillstring(20," ")
        SET holdstr20 = trim(syn_temp->syn_list[cnt].type)
        SET holdstr = concat(cnvtstring(cnt,4,0,r)," ",holdstr60," ",holdstr20)
        CALL scrolltext(arow,holdstr)
        SET cnt = (cnt+ 1)
        SET arow = (arow+ 1)
      ENDWHILE
      SET cnt = tmp1
      SET arow = 1
    ENDCASE
   ENDWHILE
   SET dest_syn_id = syn_temp->syn_list[pick].syn_id
   SET dest_syn_desc = syn_temp->syn_list[pick].synonym
   SET dest_syn_rxmask = syn_temp->syn_list[pick].rx_mask
   IF (dest_syn_id > 0
    AND old_syn_id > 0)
    CALL clear_screen(0)
    CALL text(5,1,"Make this replacement in all IV Sets? ")
    CALL accept(5,45,"C;CU","Y"
     WHERE curaccept IN ("Y", "N"))
    IF (curaccept="Y")
     CALL clear_screen(0)
     CALL text(5,1,"Making the following IV Set synonym replacement:")
     CALL text(7,2,concat("Existing synonym:  ",old_syn_desc))
     CALL text(8,2,concat("New synonym:       ",dest_syn_desc))
     CALL text(10,1,"Execute? (Y/N) ")
     CALL accept(10,17,"C;CU","Y"
      WHERE curaccept IN ("Y", "N"))
     IF (curaccept="Y")
      UPDATE  FROM cs_component cs
       SET comp_id = dest_syn_id, updt_task = - (2516)
       WHERE comp_id=old_syn_id
       WITH nocounter
      ;end update
      COMMIT
     ELSE
      GO TO common_utilities_mode
     ENDIF
    ELSE
     CALL replace_specific_ivs_syn(old_syn_id,dest_syn_id)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE replace_cs_syn(old_syn_id,old_syn_desc)
   CALL clear_screen(0)
   FREE RECORD syn_temp
   RECORD syn_temp(
     1 syn_list[*]
       2 syn_id = f8
       2 synonym = vc
       2 type = vc
       2 rx_mask = i4
   )
   SET syn_count = 0
   SET cpharm = uar_get_code_by("MEANING",6000,"PHARMACY")
   SET corder = uar_get_code_by("MEANING",6003,"ORDER")
   SET old_syn_rxmask = 0
   SET old_syn_oef = 0
   SELECT INTO "nl:"
    ocs.synonym_id, ocs.rx_mask, ocs.oe_format_id
    FROM order_catalog_synonym ocs
    WHERE ocs.synonym_id=old_syn_id
    DETAIL
     old_syn_rxmask = ocs.rx_mask, old_syn_oef = ocs.oe_format_id
    WITH nullreport
   ;end select
   SELECT INTO "nl:"
    ocs.synonym_id, synonym = ocs.mnemonic, synonym_type = evaluate(trim(uar_get_code_display(ocs
       .mnemonic_type_cd)),"Ancillary","NON-CPOE","Brand Name","BRAND",
     "Direct Care Provider","DCP","C - Dispensable Drug Names","C","Generic Name",
     "NON-CPOE","Y - Generic Products","NON-CPOE","M - Generic Miscellaneous Products","M",
     "E - IV Fluids and Nicknames","E","Outreach","NON-CPOE","PathLink",
     "NON-CPOE","Primary","PRIMARY","Rx Mnemonic","NON-CPOE",
     "Surgery Med","NON-CPOE","Z - Trade Products","NON-CPOE","N - Trade Miscellaneous Products",
     "N")
    FROM order_catalog_synonym ocs,
     ocs_facility_r ofr
    PLAN (ocs
     WHERE ocs.catalog_type_cd=cpharm
      AND ocs.catalog_cd IN (
     (SELECT
      catalog_cd
      FROM order_catalog_synonym
      WHERE synonym_id=old_syn_id))
      AND ocs.mnemonic_type_cd IN (
     (SELECT
      code_value
      FROM code_value
      WHERE code_set=6011
       AND cdf_meaning IN ("BRANDNAME", "DCP", "DISPDRUG", "GENERICTOP", "IVNAME",
      "PRIMARY", "TRADETOP")))
      AND ((ocs.hide_flag=0) OR (ocs.hide_flag=null))
      AND ocs.active_ind=1
      AND ocs.synonym_id != old_syn_id
      AND ocs.oe_format_id=old_syn_oef)
     JOIN (ofr
     WHERE ofr.synonym_id=ocs.synonym_id
      AND ((ofr.facility_cd=0) OR (ofr.facility_cd=cur_facility_cd)) )
    ORDER BY cnvtupper(ocs.mnemonic), synonym_type
    HEAD REPORT
     syn_count = 0
    DETAIL
     syn_count = (syn_count+ 1)
     IF (mod(syn_count,10)=1)
      stat = alterlist(syn_temp->syn_list,(syn_count+ 9))
     ENDIF
     syn_temp->syn_list[syn_count].syn_id = ocs.synonym_id, syn_temp->syn_list[syn_count].synonym =
     trim(ocs.mnemonic), syn_temp->syn_list[syn_count].type = synonym_type,
     syn_temp->syn_list[syn_count].rx_mask = ocs.rx_mask
    FOOT REPORT
     stat = alterlist(syn_temp->syn_list,syn_count)
    WITH nocounter
   ;end select
   CALL clear_screen(0)
   CALL text(3,2,"Medication synonyms available:")
   CALL text(5,67,"Total:  ")
   CALL text(5,75,cnvtstring(syn_count,4))
   CALL create_std_box(syn_count)
   CALL text(6,8,"Synonym")
   WHILE (cnt <= numsrow
    AND cnt <= maxcnt)
     SET holdstr60 = trim(syn_temp->syn_list[cnt].synonym)
     SET holdstr20 = fillstring(20," ")
     SET holdstr20 = trim(syn_temp->syn_list[cnt].type)
     SET holdstr = concat(cnvtstring(cnt,4,0,r)," ",holdstr60," ",holdstr20)
     CALL scrolltext(cnt,holdstr)
     SET cnt = (cnt+ 1)
   ENDWHILE
   SET cnt = 1
   SET arow = 1
   CALL text(23,1,"Select replacement synonym           (enter 000 to go back)")
   SET pick = 0
   WHILE (pick=0)
    CALL accept(23,32,"9999;S",cnt)
    CASE (curscroll)
     OF 0:
      IF (curaccept=0)
       CALL clear_screen(0)
       GO TO common_utilities_mode
      ELSEIF (cnvtint(curaccept) BETWEEN 1 AND maxcnt)
       SET pick = cnvtint(curaccept)
       CALL clear_screen(0)
      ELSE
       CALL clear_screen(0)
       GO TO common_utilities_mode
      ENDIF
     OF 1:
      IF (cnt < maxcnt)
       SET cnt = (cnt+ 1)
       SET holdstr60 = trim(syn_temp->syn_list[cnt].synonym)
       SET holdstr20 = fillstring(20," ")
       SET holdstr20 = trim(syn_temp->syn_list[cnt].type)
       SET holdstr = concat(cnvtstring(cnt,4,0,r)," ",holdstr60," ",holdstr20)
       CALL down_arrow(holdstr)
      ENDIF
     OF 2:
      IF (cnt > 1)
       SET cnt = (cnt - 1)
       SET holdstr60 = trim(syn_temp->syn_list[cnt].synonym)
       SET holdstr20 = fillstring(20," ")
       SET holdstr20 = trim(syn_temp->syn_list[cnt].type)
       SET holdstr = concat(cnvtstring(cnt,4,0,r)," ",holdstr60," ",holdstr20)
       CALL up_arrow(holdstr)
      ENDIF
     OF 3:
     OF 4:
     OF 6:
      IF (numsrow < maxcnt)
       SET cnt = ((cnt+ numsrow) - 1)
       IF (((cnt+ numsrow) > maxcnt))
        SET cnt = (maxcnt - numsrow)
       ENDIF
       SET arow = 1
       WHILE (arow <= numsrow)
         SET cnt = (cnt+ 1)
         SET holdstr60 = trim(syn_temp->syn_list[cnt].synonym)
         SET holdstr20 = fillstring(20," ")
         SET holdstr20 = trim(syn_temp->syn_list[cnt].type)
         SET holdstr = concat(cnvtstring(cnt,4,0,r)," ",holdstr60," ",holdstr20)
         CALL scrolltext(arow,holdstr)
         SET arow = (arow+ 1)
       ENDWHILE
       SET arow = 1
       SET cnt = ((cnt - numsrow)+ 1)
      ENDIF
     OF 5:
      IF (((cnt - numsrow) > 0))
       SET cnt = (cnt - numsrow)
      ELSE
       SET cnt = 1
      ENDIF
      SET tmp1 = cnt
      SET arow = 1
      WHILE (arow <= numsrow
       AND cnt < maxcnt)
        SET holdstr60 = trim(syn_temp->syn_list[cnt].synonym)
        SET holdstr20 = fillstring(20," ")
        SET holdstr20 = trim(syn_temp->syn_list[cnt].type)
        SET holdstr = concat(cnvtstring(cnt,4,0,r)," ",holdstr60," ",holdstr20)
        CALL scrolltext(arow,holdstr)
        SET cnt = (cnt+ 1)
        SET arow = (arow+ 1)
      ENDWHILE
      SET cnt = tmp1
      SET arow = 1
    ENDCASE
   ENDWHILE
   SET dest_syn_id = syn_temp->syn_list[pick].syn_id
   SET dest_syn_desc = syn_temp->syn_list[pick].synonym
   SET dest_syn_rxmask = syn_temp->syn_list[pick].rx_mask
   IF (compare_rx_masks(old_syn_rxmask,dest_syn_rxmask)=false)
    CALL clear_screen(0)
    CALL text(5,1,"RX mask on new synonym differs from existing synonym.")
    CALL text(7,2,concat("Existing synonym:  ",cnvtstring(old_syn_rxmask)))
    CALL text(8,2,concat("New synonym:       ",cnvtstring(dest_syn_rxmask)))
    CALL text(10,1,"Proceed with replacement? (Y/N)  ")
    CALL accept(10,35,"C;CU","N"
     WHERE curaccept IN ("Y", "N"))
    CASE (curaccept)
     OF "Y":
      SET continue_flag = true
     OF "N":
      SET continue_flag = false
    ENDCASE
   ELSE
    SET continue_flag = true
   ENDIF
   IF (dest_syn_id > 0
    AND old_syn_id > 0
    AND continue_flag=true)
    CALL clear_screen(0)
    CALL text(5,1,"Make this replacement in all CareSets? ")
    CALL accept(5,46,"C;CU","Y"
     WHERE curaccept IN ("Y", "N"))
    IF (curaccept="Y")
     CALL clear_screen(0)
     CALL text(5,1,"Making the following CareSet synonym replacement:")
     CALL text(7,2,concat("Existing synonym:  ",old_syn_desc))
     CALL text(8,2,concat("New synonym:       ",dest_syn_desc))
     CALL text(10,1,"Execute? (Y/N) ")
     CALL accept(10,17,"C;CU","Y"
      WHERE curaccept IN ("Y", "N"))
     CASE (curaccept)
      OF "Y":
       UPDATE  FROM cs_component cs
        SET comp_id = dest_syn_id, updt_task = - (2516)
        WHERE comp_id=old_syn_id
        WITH nocounter
       ;end update
       COMMIT
      OF "N":
       GO TO common_utilities_mode
     ENDCASE
    ELSE
     CALL replace_specific_cs_syn(old_syn_id,dest_syn_id)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE compare_rx_masks(inc_rx_mask1,inc_rx_mask2)
   DECLARE result = i2
   SET result = true
   SET cur_flag_mask1 = false
   SET cur_flag_mask2 = false
   IF (inc_rx_mask1 >= 64)
    SET inc_rx_mask1 = (inc_rx_mask1 - 64)
    SET cur_flag_mask1 = true
   ENDIF
   IF (inc_rx_mask2 >= 64)
    SET inc_rx_mask2 = (inc_rx_mask2 - 64)
    SET cur_flag_mask2 = true
   ENDIF
   IF (cur_flag_mask1=true
    AND cur_flag_mask2=false)
    SET result = false
   ENDIF
   SET cur_flag_mask1 = false
   SET cur_flag_mask2 = false
   IF (result=true)
    IF (inc_rx_mask1 >= 32)
     SET inc_rx_mask1 = (inc_rx_mask1 - 32)
     SET cur_flag_mask1 = true
    ENDIF
    IF (inc_rx_mask2 >= 32)
     SET inc_rx_mask2 = (inc_rx_mask2 - 32)
     SET cur_flag_mask2 = true
    ENDIF
    IF (cur_flag_mask1=true
     AND cur_flag_mask2=false)
     SET result = false
    ENDIF
   ENDIF
   SET cur_flag_mask1 = false
   SET cur_flag_mask2 = false
   IF (result=true)
    IF (inc_rx_mask1 >= 16)
     SET inc_rx_mask1 = (inc_rx_mask1 - 16)
     SET cur_flag_mask1 = true
    ENDIF
    IF (inc_rx_mask2 >= 16)
     SET inc_rx_mask2 = (inc_rx_mask2 - 16)
     SET cur_flag_mask2 = true
    ENDIF
    IF (cur_flag_mask1=true
     AND cur_flag_mask2=false)
     SET result = false
    ENDIF
   ENDIF
   SET cur_flag_mask1 = false
   SET cur_flag_mask2 = false
   IF (result=true)
    IF (inc_rx_mask1 >= 8)
     SET inc_rx_mask1 = (inc_rx_mask1 - 8)
     SET cur_flag_mask1 = true
    ENDIF
    IF (inc_rx_mask2 >= 8)
     SET inc_rx_mask2 = (inc_rx_mask2 - 8)
     SET cur_flag_mask2 = true
    ENDIF
    IF (cur_flag_mask1=true
     AND cur_flag_mask2=false)
     SET result = false
    ENDIF
   ENDIF
   SET cur_flag_mask1 = false
   SET cur_flag_mask2 = false
   IF (result=true)
    IF (inc_rx_mask1 >= 4)
     SET inc_rx_mask1 = (inc_rx_mask1 - 4)
     SET cur_flag_mask1 = true
    ENDIF
    IF (inc_rx_mask2 >= 4)
     SET inc_rx_mask2 = (inc_rx_mask2 - 4)
     SET cur_flag_mask2 = true
    ENDIF
    IF (cur_flag_mask1=true
     AND cur_flag_mask2=false)
     SET result = false
    ENDIF
   ENDIF
   SET cur_flag_mask1 = false
   SET cur_flag_mask2 = false
   IF (result=true)
    IF (inc_rx_mask1 >= 2)
     SET inc_rx_mask1 = (inc_rx_mask1 - 2)
     SET cur_flag_mask1 = true
    ENDIF
    IF (inc_rx_mask2 >= 2)
     SET inc_rx_mask2 = (inc_rx_mask2 - 2)
     SET cur_flag_mask2 = true
    ENDIF
    IF (cur_flag_mask1=true
     AND cur_flag_mask2=false)
     SET result = false
    ENDIF
   ENDIF
   SET cur_flag_mask1 = false
   SET cur_flag_mask2 = false
   IF (result=true)
    IF (inc_rx_mask1 >= 1)
     SET inc_rx_mask1 = (inc_rx_mask1 - 1)
     SET cur_flag_mask1 = true
    ENDIF
    IF (inc_rx_mask2 >= 1)
     SET inc_rx_mask2 = (inc_rx_mask2 - 1)
     SET cur_flag_mask2 = true
    ENDIF
    IF (cur_flag_mask1=true
     AND cur_flag_mask2=false)
     SET result = false
    ENDIF
   ENDIF
   RETURN(result)
 END ;Subroutine
 SUBROUTINE num_to_str(inc_num)
   DECLARE cur_string = c15
   SET decimal_loc = 0
   SET cur_string = cnvtstring(inc_num,15,3)
   SET cur_pos = textlen(cnvtstring(inc_num,15,3))
   SET decimal_loc = findstring(".",cur_string,1)
   SET trim_flag = false
   SET trim_finished = false
   SET trim_pos = 0
   WHILE (cur_pos > 1
    AND cur_pos >= decimal_loc
    AND decimal_loc > 0
    AND trim_finished=false)
    IF (isnumeric(substring(cur_pos,1,cur_string))
     AND trim_finished=false)
     IF (substring(cur_pos,1,cur_string)="0"
      AND trim_finished=false)
      SET trim_flag = true
      SET trim_pos = cur_pos
     ELSE
      SET trim_finished = true
      SET trim_pos = cur_pos
     ENDIF
    ENDIF
    SET cur_pos = (cur_pos - 1)
   ENDWHILE
   IF (substring(trim_pos,1,cur_string)=".")
    SET trim_pos = (trim_pos - 1)
   ENDIF
   RETURN(substring(1,trim_pos,cur_string))
 END ;Subroutine
 SUBROUTINE replace_syn_oef(target_syn_id,old_syn_desc)
   CALL clear_screen(0)
   SET oef_count = 0
   FREE RECORD oef_temp
   RECORD oef_temp(
     1 oefs[*]
       2 oe_format_id = f8
       2 oe_format_name = vc
   )
   SET cpharm = uar_get_code_by("MEANING",6000,"PHARMACY")
   SET corder = uar_get_code_by("MEANING",6003,"ORDER")
   DECLARE old_syn_oef_name = vc
   DECLARE syn_name = vc
   SET old_syn_rxmask = 0
   SET old_syn_oef = 0
   SET old_syn_oef_name = ""
   SET syn_name = ""
   SELECT INTO "nl:"
    ocs.synonym_id, ocs.rx_mask, ocs.oe_format_id
    FROM order_catalog_synonym ocs
    WHERE ocs.synonym_id=target_syn_id
    DETAIL
     old_syn_rxmask = ocs.rx_mask, old_syn_oef = ocs.oe_format_id, syn_name = trim(substring(1,60,ocs
       .mnemonic))
    WITH nullreport
   ;end select
   SELECT INTO "nl:"
    oef.oe_format_id, oef.oe_format_name
    FROM order_entry_format oef
    WHERE oef.catalog_type_cd=cpharm
     AND oef.action_type_cd=corder
     AND oef.oe_format_id=old_syn_oef
    DETAIL
     old_syn_oef_name = trim(oef.oe_format_name)
    WITH nullreport
   ;end select
   SELECT INTO "nl:"
    oef.oe_format_id, oef.oe_format_name
    FROM order_entry_format oef
    WHERE oef.catalog_type_cd=cpharm
     AND oef.action_type_cd=corder
     AND trim(oef.oe_format_name) != "Primary Pharmacy"
     AND oef.oe_format_id != old_syn_oef
    ORDER BY cnvtupper(oef.oe_format_name)
    HEAD REPORT
     oef_count = 0
    DETAIL
     oef_count = (oef_count+ 1)
     IF (mod(oef_count,10)=1)
      stat = alterlist(oef_temp->oefs,(oef_count+ 9))
     ENDIF
     oef_temp->oefs[oef_count].oe_format_id = oef.oe_format_id, oef_temp->oefs[oef_count].
     oe_format_name = oef.oe_format_name
    FOOT REPORT
     stat = alterlist(oef_temp->oefs,oef_count)
    WITH nocounter
   ;end select
   CALL clear_screen(0)
   CALL video("R")
   CALL text(2,2," Selected Synonym: ")
   CALL text(2,23,trim(syn_name))
   CALL text(3,2,"      Current OEF: ")
   CALL text(3,23,trim(old_syn_oef_name))
   CALL text(5,67,"Total:  ")
   CALL text(5,75,cnvtstring(oef_count,4))
   CALL video("N")
   CALL create_std_box(oef_count)
   CALL text(6,8,"OEFs")
   WHILE (cnt <= numsrow
    AND cnt <= maxcnt)
     SET holdstr = substring(1,75,oef_temp->oefs[cnt].oe_format_name)
     CALL scrolltext(cnt,holdstr)
     SET cnt = (cnt+ 1)
   ENDWHILE
   SET cnt = 1
   SET arow = 1
   CALL text(23,1,"Select new OEF           (enter 000 to go back)")
   SET pick = 0
   WHILE (pick=0)
    CALL accept(23,20,"9999;S",cnt)
    CASE (curscroll)
     OF 0:
      IF (curaccept=0)
       CALL clear_screen(0)
       GO TO pharm_utilities_mode
      ELSEIF (cnvtint(curaccept) BETWEEN 1 AND maxcnt)
       SET pick = cnvtint(curaccept)
       CALL clear_screen(0)
      ELSE
       CALL clear_screen(0)
       GO TO pharm_utilities_mode
      ENDIF
     OF 1:
      IF (cnt < maxcnt)
       SET cnt = (cnt+ 1)
       SET holdstr = substring(1,75,oef_temp->oefs[cnt].oe_format_name)
       CALL down_arrow(holdstr)
      ENDIF
     OF 2:
      IF (cnt > 1)
       SET cnt = (cnt - 1)
       SET holdstr = substring(1,75,oef_temp->oefs[cnt].oe_format_name)
       CALL up_arrow(holdstr)
      ENDIF
     OF 3:
     OF 4:
     OF 6:
      IF (numsrow < maxcnt)
       SET cnt = ((cnt+ numsrow) - 1)
       IF (((cnt+ numsrow) > maxcnt))
        SET cnt = (maxcnt - numsrow)
       ENDIF
       SET arow = 1
       WHILE (arow <= numsrow)
         SET cnt = (cnt+ 1)
         SET holdstr = substring(1,75,oef_temp->oefs[cnt].oe_format_name)
         CALL scrolltext(arow,holdstr)
         SET arow = (arow+ 1)
       ENDWHILE
       SET arow = 1
       SET cnt = ((cnt - numsrow)+ 1)
      ENDIF
     OF 5:
      IF (((cnt - numsrow) > 0))
       SET cnt = (cnt - numsrow)
      ELSE
       SET cnt = 1
      ENDIF
      SET tmp1 = cnt
      SET arow = 1
      WHILE (arow <= numsrow
       AND cnt < maxcnt)
        SET holdstr = substring(1,75,oef_temp->oefs[cnt].oe_format_name)
        CALL scrolltext(arow,holdstr)
        SET cnt = (cnt+ 1)
        SET arow = (arow+ 1)
      ENDWHILE
      SET cnt = tmp1
      SET arow = 1
    ENDCASE
   ENDWHILE
   SET new_oef_id = oef_temp->oefs[pick].oe_format_id
   SET new_oef_name = oef_temp->oefs[pick].oe_format_name
   IF (new_oef_id > 0
    AND target_syn_id > 0)
    SET response_val = 0
    SET syn_rxmask = 0
    SET done_flag = 0
    SELECT INTO "nl:"
     ocs.rx_mask
     FROM order_catalog_synonym ocs
     WHERE ocs.synonym_id=target_syn_id
     DETAIL
      syn_rxmask = ocs.rx_mask
     WITH nocounter
    ;end select
    IF (syn_rxmask=1
     AND new_oef_name != "PHARMACY IV")
     SET warn_rxm1_ivoef = 1
    ELSE
     SET warn_rxm1_ivoef = 0
    ENDIF
    SET warn_favorite = cnvtreal(is_syn_in_favorites(target_syn_id))
    SET warn_usedinfolder = cnvtreal(is_syn_in_folders(target_syn_id))
    SET warn_usedinpowerplan = cnvtreal(is_syn_in_powerplans(target_syn_id))
    SET warn_usedincareset = cnvtreal(is_syn_in_careset(target_syn_id))
    SET warn_usedinpowerorders = cnvtreal(is_syn_in_powerorders(target_syn_id))
    IF (warn_rxm1_ivoef=1
     AND done_flag=0)
     CALL video("R")
     CALL text(3,3," * Warning! * ")
     CALL video("N")
     CALL text(5,3,"The selected synonym has been RX masked as a diluent, and the")
     CALL text(6,3,"OEF selected is not 'Pharmacy IV'. This may cause issues during")
     CALL text(7,3,"order entry.")
     CALL text(10,3,"Would you like to proceed? (Y/N) ")
     CALL accept(10,38,"C;CU","N"
      WHERE curaccept IN ("Y", "N"))
     CASE (curaccept)
      OF "N":
       SET done_flag = 1
     ENDCASE
    ENDIF
    IF (((warn_favorite=2) OR (((warn_usedinfolder=2) OR (((warn_usedinpowerplan=2) OR (((
    warn_usedincareset=2) OR (warn_usedinpowerorders=2)) )) )) ))
     AND done_flag=0)
     SET output_row = 3
     CALL clear_screen(0)
     CALL video("R")
     CALL text(output_row,3," * Warning! * ")
     SET output_row = (output_row+ 2)
     CALL video("N")
     CALL text(output_row,3,"The selected synonym is included in one or more CPOE locations.")
     SET output_row = (output_row+ 1)
     CALL text(output_row,3,"Existing order sentences may be adversely affected where sentence")
     SET output_row = (output_row+ 1)
     CALL text(output_row,3,"details are incompatible with the new Order Entry Format.")
     SET output_row = (output_row+ 2)
     IF (warn_favorite > 0)
      CALL text(output_row,7," - Favorites")
      SET output_row = (output_row+ 1)
     ENDIF
     IF (warn_usedinfolder > 0)
      CALL text(output_row,7," - Order Folders")
      SET output_row = (output_row+ 1)
     ENDIF
     IF (warn_usedinpowerplan > 0)
      CALL text(output_row,7," - PowerPlans")
      SET output_row = (output_row+ 1)
     ENDIF
     IF (warn_usedincareset > 0)
      CALL text(output_row,7," - CareSets")
      SET output_row = (output_row+ 1)
     ENDIF
     IF (warn_usedinpowerorders > 0)
      CALL text(output_row,7," - PowerOrders")
      SET output_row = (output_row+ 1)
     ENDIF
     CALL text(20,3,"Would you like to review this synonym's use in CPOE? (Y/N) ")
     CALL accept(20,64,"C;CU","Y"
      WHERE curaccept IN ("Y", "N"))
     CASE (curaccept)
      OF "Y":
       CALL display_syn_cpoe_usage(target_syn_id)
     ENDCASE
    ENDIF
    IF (done_flag=0)
     CALL clear_screen(0)
     CALL video("R")
     CALL text(3,3,"     Synonym: ")
     CALL text(3,18,trim(syn_name))
     CALL text(5,3," Current OEF: ")
     CALL text(5,18,trim(old_syn_oef_name))
     CALL text(6,3,"     New OEF: ")
     CALL text(6,18,trim(new_oef_name))
     CALL video("N")
     CALL text(10,3,"Change synonym OEF? (Y/N) ")
     CALL accept(10,30,"C;CU","N"
      WHERE curaccept IN ("Y", "N"))
     CASE (curaccept)
      OF "Y":
       UPDATE  FROM order_catalog_synonym ocs
        SET ocs.oe_format_id = new_oef_id
        WHERE ocs.synonym_id=target_syn_id
        WITH nocounter
       ;end update
       UPDATE  FROM order_sentence os
        SET os.oe_format_id = new_oef_id
        WHERE os.order_sentence_id IN (
        (SELECT
         order_sentence_id
         FROM ord_cat_sent_r
         WHERE synonym_id=target_syn_id))
         AND os.parent_entity_name="ORDER_CATALOG_SYNONYM"
         AND os.parent_entity_id=target_syn_id
        WITH nocounter
       ;end update
       COMMIT
     ENDCASE
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE is_syn_in_favorites(inc_syn_id)
   DECLARE response = i4
   SET response = 0
   SET cpharm = uar_get_code_by("MEANING",6000,"PHARMACY")
   SELECT INTO "nl:"
    value_type = evaluate(asl.list_type,2,"synonym",5,"IV favorite"), user = substring(1,60,p
     .name_full_formatted), catalog_type = uar_get_code_display(ocs.catalog_type_cd),
    activity_type = uar_get_code_display(ocs.activity_type_cd), ocs.synonym_id, synonym = substring(1,
     60,ocs.mnemonic),
    os.order_sentence_id, sentence = substring(1,150,os.order_sentence_display_line)
    FROM alt_sel_cat acat,
     alt_sel_list asl,
     person p,
     order_catalog_synonym ocs,
     order_sentence os
    PLAN (acat
     WHERE acat.owner_id > 0)
     JOIN (asl
     WHERE asl.alt_sel_category_id=acat.alt_sel_category_id
      AND asl.list_type IN (2, 5))
     JOIN (p
     WHERE p.person_id=acat.owner_id)
     JOIN (ocs
     WHERE asl.synonym_id=ocs.synonym_id
      AND ocs.catalog_type_cd=cpharm
      AND ocs.synonym_id=inc_syn_id)
     JOIN (os
     WHERE os.order_sentence_id=outerjoin(asl.order_sentence_id))
    ORDER BY ocs.synonym_id, os.order_sentence_id
    DETAIL
     IF (ocs.synonym_id > 0
      AND response=0)
      response = 1
      IF (os.order_sentence_id > 0
       AND response=1)
       response = 2
      ENDIF
     ENDIF
    WITH nullreport
   ;end select
   RETURN(response)
 END ;Subroutine
 SUBROUTINE is_syn_in_folders(inc_syn_id)
   DECLARE response = i4
   SET response = 0
   SET cpharm = uar_get_code_by("MEANING",6000,"PHARMACY")
   SELECT INTO "nl:"
    value_type = evaluate(asl.list_type,2,"synonym",5,"IV favorite"), user = substring(1,60,p
     .name_full_formatted), catalog_type = uar_get_code_display(ocs.catalog_type_cd),
    activity_type = uar_get_code_display(ocs.activity_type_cd), ocs.synonym_id, synonym = substring(1,
     60,ocs.mnemonic),
    os.order_sentence_id, sentence = substring(1,150,os.order_sentence_display_line)
    FROM alt_sel_cat acat,
     alt_sel_list asl,
     person p,
     order_catalog_synonym ocs,
     order_sentence os
    PLAN (acat
     WHERE acat.owner_id=0)
     JOIN (asl
     WHERE asl.alt_sel_category_id=acat.alt_sel_category_id
      AND asl.list_type IN (2, 5))
     JOIN (p
     WHERE p.person_id=acat.owner_id)
     JOIN (ocs
     WHERE asl.synonym_id=ocs.synonym_id
      AND ocs.catalog_type_cd=cpharm
      AND ocs.synonym_id=inc_syn_id)
     JOIN (os
     WHERE os.order_sentence_id=outerjoin(asl.order_sentence_id))
    ORDER BY ocs.synonym_id, os.order_sentence_id
    DETAIL
     IF (ocs.synonym_id > 0
      AND response=0)
      response = 1
      IF (os.order_sentence_id > 0
       AND response=1)
       response = 2
      ENDIF
     ENDIF
    WITH nullreport
   ;end select
   RETURN(response)
 END ;Subroutine
 SUBROUTINE is_syn_in_powerplans(inc_syn_id)
   DECLARE response = i4
   SET response = 0
   SET cpharm = uar_get_code_by("MEANING",6000,"PHARMACY")
   SELECT INTO "nl:"
    plan_name = pcat.description, ocs.catalog_cd, ocs.synonym_id,
    ocs.mnemonic, pcor.order_sentence_id, os.order_sentence_display_line
    FROM pathway_catalog pcat,
     pathway_comp pcmp,
     order_catalog_synonym ocs,
     pw_comp_os_reltn pcor,
     order_sentence os
    PLAN (pcat
     WHERE pcat.active_ind=1)
     JOIN (pcmp
     WHERE pcat.pathway_catalog_id=pcmp.pathway_catalog_id
      AND pcmp.sequence > 0)
     JOIN (ocs
     WHERE pcmp.parent_entity_id=ocs.synonym_id
      AND ocs.catalog_type_cd=cpharm
      AND ocs.synonym_id=inc_syn_id)
     JOIN (pcor
     WHERE pcor.pathway_comp_id=outerjoin(pcmp.pathway_comp_id))
     JOIN (os
     WHERE os.order_sentence_id=outerjoin(pcor.order_sentence_id))
    ORDER BY cnvtupper(pcat.description), cnvtupper(ocs.mnemonic)
    DETAIL
     IF (ocs.synonym_id > 0
      AND response=0)
      response = 1
      IF (os.order_sentence_id > 0
       AND response=1)
       response = 2
      ENDIF
     ENDIF
    WITH nullreport
   ;end select
   RETURN(response)
 END ;Subroutine
 SUBROUTINE is_syn_in_careset(inc_syn_id)
   DECLARE response = i4
   SET response = 0
   SET cpharm = uar_get_code_by("MEANING",6000,"PHARMACY")
   SELECT INTO "nl:"
    careset = substring(1,75,oc.primary_mnemonic), ocs.synonym_id, component = ocs.mnemonic,
    os.order_sentence_id, sentence = substring(1,75,os.order_sentence_display_line)
    FROM order_catalog_synonym ocs,
     cs_component csp,
     order_catalog oc,
     order_sentence os
    PLAN (oc
     WHERE oc.active_ind=1)
     JOIN (csp
     WHERE oc.catalog_cd=csp.catalog_cd
      AND oc.orderable_type_flag IN (6)
      AND csp.comp_id != 0)
     JOIN (ocs
     WHERE ocs.synonym_id=csp.comp_id
      AND ocs.catalog_type_cd=cpharm
      AND ocs.synonym_id=inc_syn_id)
     JOIN (os
     WHERE outerjoin(csp.order_sentence_id)=os.order_sentence_id)
    ORDER BY cnvtupper(oc.primary_mnemonic), cnvtupper(ocs.mnemonic)
    DETAIL
     IF (ocs.synonym_id > 0
      AND response=0)
      response = 1
      IF (os.order_sentence_id > 0
       AND response=1)
       response = 2
      ENDIF
     ENDIF
    WITH nullreport
   ;end select
   RETURN(response)
 END ;Subroutine
 SUBROUTINE is_syn_in_powerorders(inc_syn_id)
   DECLARE response = i4
   SET response = 0
   SET cpharm = uar_get_code_by("MEANING",6000,"PHARMACY")
   SELECT INTO "nl:"
    primary = substring(1,75,oc.primary_mnemonic), ocs.synonym_id, synonym = ocs.mnemonic,
    os.order_sentence_id, sentence = substring(1,75,os.order_sentence_display_line)
    FROM order_catalog oc,
     order_catalog_synonym ocs,
     ord_cat_sent_r ocsr,
     order_sentence os,
     dummyt d
    PLAN (oc
     WHERE oc.active_ind=1
      AND oc.orderable_type_flag IN (0, 1)
      AND oc.catalog_type_cd=cpharm)
     JOIN (ocs
     WHERE ocs.catalog_cd=oc.catalog_cd
      AND ocs.synonym_id=inc_syn_id
      AND ocs.active_ind=1
      AND ((ocs.hide_flag=null) OR (ocs.hide_flag=0))
      AND ocs.synonym_id IN (
     (SELECT
      synonym_id
      FROM ocs_facility_r))
      AND ocs.mnemonic_type_cd IN (
     (SELECT
      code_value
      FROM code_value
      WHERE code_set=6011
       AND cdf_meaning IN ("BRANDNAME", "DCP", "DISPDRUG", "GENERICTOP", "IVNAME",
      "PRIMARY", "TRADETOP"))))
     JOIN (d)
     JOIN (ocsr
     WHERE ocsr.synonym_id=ocs.synonym_id)
     JOIN (os
     WHERE ocsr.order_sentence_id=os.order_sentence_id
      AND os.usage_flag IN (0, 1))
    ORDER BY cnvtupper(oc.primary_mnemonic), cnvtupper(ocs.mnemonic)
    DETAIL
     IF (ocs.synonym_id > 0
      AND response=0)
      response = 1
      IF (os.order_sentence_id > 0
       AND response=1)
       response = 2
      ENDIF
     ENDIF
    WITH outerjoin = d, nullreport
   ;end select
   RETURN(response)
 END ;Subroutine
 SUBROUTINE display_syn_cpoe_usage(inc_syn_id)
   FREE RECORD syn_usage
   RECORD syn_usage(
     1 usage[*]
       2 location_type = vc
       2 location_name = vc
       2 synonym_name = vc
       2 sentence = vc
   )
   SET cpharm = uar_get_code_by("MEANING",6000,"PHARMACY")
   SELECT INTO "nl:"
    value_type = evaluate(asl.list_type,2,"synonym",5,"IV favorite"), user = substring(1,60,p
     .name_full_formatted), catalog_type = uar_get_code_display(ocs.catalog_type_cd),
    activity_type = uar_get_code_display(ocs.activity_type_cd), ocs.synonym_id, synonym = substring(1,
     60,ocs.mnemonic),
    os.order_sentence_id, sentence = substring(1,150,os.order_sentence_display_line)
    FROM alt_sel_cat acat,
     alt_sel_list asl,
     person p,
     order_catalog_synonym ocs,
     order_sentence os
    PLAN (acat
     WHERE acat.owner_id > 0)
     JOIN (asl
     WHERE asl.alt_sel_category_id=acat.alt_sel_category_id
      AND asl.list_type IN (2, 5))
     JOIN (p
     WHERE p.person_id=acat.owner_id)
     JOIN (ocs
     WHERE asl.synonym_id=ocs.synonym_id
      AND ocs.catalog_type_cd=cpharm
      AND ocs.synonym_id=inc_syn_id)
     JOIN (os
     WHERE os.order_sentence_id=outerjoin(asl.order_sentence_id))
    ORDER BY ocs.synonym_id, os.order_sentence_id
    HEAD REPORT
     cnt = size(syn_usage->usage,5)
    DETAIL
     cnt = (cnt+ 1), stat = alterlist(syn_usage->usage,cnt), syn_usage->usage[cnt].location_type =
     "Favorite",
     syn_usage->usage[cnt].location_name = trim(p.name_full_formatted), syn_usage->usage[cnt].
     synonym_name = trim(ocs.mnemonic), syn_usage->usage[cnt].sentence = trim(os
      .order_sentence_display_line)
    WITH nullreport
   ;end select
   SELECT INTO "nl:"
    value_type = evaluate(asl.list_type,2,"synonym",5,"IV favorite"), user = substring(1,60,p
     .name_full_formatted), catalog_type = uar_get_code_display(ocs.catalog_type_cd),
    activity_type = uar_get_code_display(ocs.activity_type_cd), ocs.synonym_id, synonym = substring(1,
     60,ocs.mnemonic),
    os.order_sentence_id, sentence = substring(1,150,os.order_sentence_display_line)
    FROM alt_sel_cat acat,
     alt_sel_list asl,
     person p,
     order_catalog_synonym ocs,
     order_sentence os
    PLAN (acat
     WHERE acat.owner_id=0)
     JOIN (asl
     WHERE asl.alt_sel_category_id=acat.alt_sel_category_id
      AND asl.list_type IN (2, 5))
     JOIN (p
     WHERE p.person_id=acat.owner_id)
     JOIN (ocs
     WHERE asl.synonym_id=ocs.synonym_id
      AND ocs.catalog_type_cd=cpharm
      AND ocs.synonym_id=inc_syn_id)
     JOIN (os
     WHERE os.order_sentence_id=outerjoin(asl.order_sentence_id))
    ORDER BY ocs.synonym_id, os.order_sentence_id
    HEAD REPORT
     cnt = size(syn_usage->usage,5)
    DETAIL
     cnt = (cnt+ 1), stat = alterlist(syn_usage->usage,cnt), syn_usage->usage[cnt].location_type =
     "Order Folder",
     syn_usage->usage[cnt].location_name = "", syn_usage->usage[cnt].synonym_name = trim(ocs.mnemonic
      ), syn_usage->usage[cnt].sentence = trim(os.order_sentence_display_line)
    WITH nullreport
   ;end select
   SELECT INTO "nl:"
    plan_name = pcat.description, ocs.catalog_cd, ocs.synonym_id,
    ocs.mnemonic, pcor.order_sentence_id, os.order_sentence_display_line
    FROM pathway_catalog pcat,
     pathway_comp pcmp,
     order_catalog_synonym ocs,
     pw_comp_os_reltn pcor,
     order_sentence os
    PLAN (pcat
     WHERE pcat.active_ind=1)
     JOIN (pcmp
     WHERE pcat.pathway_catalog_id=pcmp.pathway_catalog_id
      AND pcmp.sequence > 0)
     JOIN (ocs
     WHERE pcmp.parent_entity_id=ocs.synonym_id
      AND ocs.catalog_type_cd=cpharm
      AND ocs.synonym_id=inc_syn_id)
     JOIN (pcor
     WHERE pcor.pathway_comp_id=outerjoin(pcmp.pathway_comp_id))
     JOIN (os
     WHERE os.order_sentence_id=outerjoin(pcor.order_sentence_id))
    ORDER BY cnvtupper(pcat.description), cnvtupper(ocs.mnemonic)
    HEAD REPORT
     cnt = size(syn_usage->usage,5)
    DETAIL
     cnt = (cnt+ 1), stat = alterlist(syn_usage->usage,cnt), syn_usage->usage[cnt].location_type =
     "PowerPlan",
     syn_usage->usage[cnt].location_name = trim(pcat.description), syn_usage->usage[cnt].synonym_name
      = trim(ocs.mnemonic), syn_usage->usage[cnt].sentence = trim(os.order_sentence_display_line)
    WITH nullreport
   ;end select
   SELECT INTO "nl:"
    careset = substring(1,75,oc.primary_mnemonic), ocs.synonym_id, component = ocs.mnemonic,
    os.order_sentence_id, sentence = substring(1,75,os.order_sentence_display_line)
    FROM order_catalog_synonym ocs,
     cs_component csp,
     order_catalog oc,
     order_sentence os
    PLAN (oc
     WHERE oc.active_ind=1)
     JOIN (csp
     WHERE oc.catalog_cd=csp.catalog_cd
      AND oc.orderable_type_flag IN (6)
      AND csp.comp_id != 0)
     JOIN (ocs
     WHERE ocs.synonym_id=csp.comp_id
      AND ocs.catalog_type_cd=cpharm
      AND ocs.synonym_id=inc_syn_id)
     JOIN (os
     WHERE outerjoin(csp.order_sentence_id)=os.order_sentence_id)
    ORDER BY cnvtupper(oc.primary_mnemonic), cnvtupper(ocs.mnemonic)
    HEAD REPORT
     cnt = size(syn_usage->usage,5)
    DETAIL
     cnt = (cnt+ 1), stat = alterlist(syn_usage->usage,cnt), syn_usage->usage[cnt].location_type =
     "CareSet",
     syn_usage->usage[cnt].location_name = trim(oc.primary_mnemonic), syn_usage->usage[cnt].
     synonym_name = trim(ocs.mnemonic), syn_usage->usage[cnt].sentence = trim(os
      .order_sentence_display_line)
    WITH nullreport
   ;end select
   SELECT INTO "nl:"
    primary = substring(1,75,oc.primary_mnemonic), ocs.synonym_id, synonym = ocs.mnemonic,
    os.order_sentence_id, sentence = substring(1,75,os.order_sentence_display_line)
    FROM order_catalog oc,
     order_catalog_synonym ocs,
     ord_cat_sent_r ocsr,
     order_sentence os,
     dummyt d
    PLAN (oc
     WHERE oc.active_ind=1
      AND oc.orderable_type_flag IN (0, 1)
      AND oc.catalog_type_cd=cpharm)
     JOIN (ocs
     WHERE ocs.catalog_cd=oc.catalog_cd
      AND ocs.synonym_id=inc_syn_id
      AND ocs.active_ind=1
      AND ((ocs.hide_flag=null) OR (ocs.hide_flag=0))
      AND ocs.synonym_id IN (
     (SELECT
      synonym_id
      FROM ocs_facility_r))
      AND ocs.mnemonic_type_cd IN (
     (SELECT
      code_value
      FROM code_value
      WHERE code_set=6011
       AND cdf_meaning IN ("BRANDNAME", "DCP", "DISPDRUG", "GENERICTOP", "IVNAME",
      "PRIMARY", "TRADETOP"))))
     JOIN (d)
     JOIN (ocsr
     WHERE ocsr.synonym_id=ocs.synonym_id)
     JOIN (os
     WHERE ocsr.order_sentence_id=os.order_sentence_id
      AND os.usage_flag IN (0, 1))
    ORDER BY cnvtupper(oc.primary_mnemonic), cnvtupper(ocs.mnemonic)
    HEAD REPORT
     cnt = size(syn_usage->usage,5)
    DETAIL
     cnt = (cnt+ 1), stat = alterlist(syn_usage->usage,cnt), syn_usage->usage[cnt].location_type =
     "PowerOrders",
     syn_usage->usage[cnt].location_name = "", syn_usage->usage[cnt].synonym_name = trim(ocs.mnemonic
      ), syn_usage->usage[cnt].sentence = trim(os.order_sentence_display_line)
    WITH nullreport
   ;end select
   SELECT
    location_type = substring(1,30,syn_usage->usage[d.seq].location_type), location_name = substring(
     1,40,syn_usage->usage[d.seq].location_name), order_sentence = substring(1,100,syn_usage->usage[d
     .seq].sentence)
    FROM (dummyt d  WITH seq = size(syn_usage->usage,5))
    ORDER BY location_type, location_name, order_sentence
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE replace_specific_ivs_syn(replace_syn_id,new_syn_id)
   CALL clear_screen(0)
   FREE RECORD ivs_temp
   RECORD ivs_temp(
     1 ivs_list[*]
       2 ivs_cat_cd = f8
       2 ivs_name = vc
   )
   SET ivs_count = 0
   SET cpharm = uar_get_code_by("MEANING",6000,"PHARMACY")
   SET corder = uar_get_code_by("MEANING",6003,"ORDER")
   DECLARE ivs_name = vc
   SET ivs_cat_cd = 0
   SELECT INTO "nl:"
    oc.catalog_cd, oc.primary_mnemonic
    FROM order_catalog oc
    WHERE oc.catalog_cd IN (
    (SELECT
     catalog_cd
     FROM cs_component
     WHERE comp_id != 0
      AND comp_id=replace_syn_id))
     AND oc.active_ind=1
     AND oc.orderable_type_flag=8
    ORDER BY cnvtupper(oc.primary_mnemonic)
    HEAD REPORT
     ivs_count = 0
    DETAIL
     ivs_count = (ivs_count+ 1)
     IF (mod(ivs_count,10)=1)
      stat = alterlist(ivs_temp->ivs_list,(ivs_count+ 9))
     ENDIF
     ivs_temp->ivs_list[ivs_count].ivs_cat_cd = oc.catalog_cd, ivs_temp->ivs_list[ivs_count].ivs_name
      = oc.primary_mnemonic
    FOOT REPORT
     stat = alterlist(ivs_temp->ivs_list,ivs_count)
    WITH nocounter
   ;end select
   CALL clear_screen(0)
   CALL text(3,2,"Replace in which IV set?")
   CALL text(5,67,"Total:  ")
   CALL text(5,75,cnvtstring(ivs_count,4))
   CALL create_std_box(ivs_count)
   CALL text(6,8,"IV Sets")
   WHILE (cnt <= numsrow
    AND cnt <= maxcnt)
     SET holdstr = substring(1,75,ivs_temp->ivs_list[cnt].ivs_name)
     CALL scrolltext(cnt,holdstr)
     SET cnt = (cnt+ 1)
   ENDWHILE
   SET cnt = 1
   SET arow = 1
   CALL text(23,1,"Select IV Set for synonym replacement           (enter 000 to go back)")
   SET pick = 0
   WHILE (pick=0)
    CALL accept(23,43,"9999;S",cnt)
    CASE (curscroll)
     OF 0:
      IF (curaccept=0)
       CALL clear_screen(0)
       GO TO common_utilities_mode
      ELSEIF (cnvtint(curaccept) BETWEEN 1 AND maxcnt)
       SET pick = cnvtint(curaccept)
       CALL clear_screen(0)
      ELSE
       CALL clear_screen(0)
       GO TO common_utilities_mode
      ENDIF
     OF 1:
      IF (cnt < maxcnt)
       SET cnt = (cnt+ 1)
       SET holdstr = substring(1,75,ivs_temp->ivs_list[cnt].ivs_name)
       CALL down_arrow(holdstr)
      ENDIF
     OF 2:
      IF (cnt > 1)
       SET cnt = (cnt - 1)
       SET holdstr = substring(1,75,ivs_temp->ivs_list[cnt].ivs_name)
       CALL up_arrow(holdstr)
      ENDIF
     OF 3:
     OF 4:
     OF 6:
      IF (numsrow < maxcnt)
       SET cnt = ((cnt+ numsrow) - 1)
       IF (((cnt+ numsrow) > maxcnt))
        SET cnt = (maxcnt - numsrow)
       ENDIF
       SET arow = 1
       WHILE (arow <= numsrow)
         SET cnt = (cnt+ 1)
         SET holdstr = substring(1,75,ivs_temp->ivs_list[cnt].ivs_name)
         CALL scrolltext(arow,holdstr)
         SET arow = (arow+ 1)
       ENDWHILE
       SET arow = 1
       SET cnt = ((cnt - numsrow)+ 1)
      ENDIF
     OF 5:
      IF (((cnt - numsrow) > 0))
       SET cnt = (cnt - numsrow)
      ELSE
       SET cnt = 1
      ENDIF
      SET tmp1 = cnt
      SET arow = 1
      WHILE (arow <= numsrow
       AND cnt < maxcnt)
        SET holdstr = substring(1,75,ivs_temp->ivs_list[cnt].ivs_name)
        CALL scrolltext(arow,holdstr)
        SET cnt = (cnt+ 1)
        SET arow = (arow+ 1)
      ENDWHILE
      SET cnt = tmp1
      SET arow = 1
    ENDCASE
   ENDWHILE
   SET ivs_name = ivs_temp->ivs_list[pick].ivs_name
   SET ivs_cat_cd = ivs_temp->ivs_list[pick].ivs_cat_cd
   IF (ivs_cat_cd > 0)
    CALL clear_screen(0)
    CALL text(5,1,"Making the following IV Set synonym replacement:")
    CALL text(7,2,concat("IV Set:  ",ivs_name))
    CALL text(8,2,concat("Existing synonym:  ",old_syn_desc))
    CALL text(9,2,concat("New synonym:       ",dest_syn_desc))
    CALL text(11,1,"Execute? (Y/N) ")
    CALL accept(11,17,"C;CU","Y"
     WHERE curaccept IN ("Y", "N"))
    CASE (curaccept)
     OF "Y":
      UPDATE  FROM cs_component cs
       SET comp_id = new_syn_id, updt_task = - (2516)
       WHERE comp_id=replace_syn_id
        AND catalog_cd=ivs_cat_cd
       WITH nocounter
      ;end update
      COMMIT
     OF "N":
      GO TO common_utilities_mode
    ENDCASE
   ENDIF
 END ;Subroutine
 SUBROUTINE replace_specific_cs_syn(replace_syn_id,new_syn_id)
   CALL clear_screen(0)
   FREE RECORD cs_temp
   RECORD cs_temp(
     1 cs_list[*]
       2 cs_cat_cd = f8
       2 cs_name = vc
   )
   SET cs_count = 0
   SET cpharm = uar_get_code_by("MEANING",6000,"PHARMACY")
   SET corder = uar_get_code_by("MEANING",6003,"ORDER")
   DECLARE cs_name = vc
   SET cs_cat_cd = 0
   SELECT INTO "nl:"
    oc.catalog_cd, oc.primary_mnemonic
    FROM order_catalog oc
    WHERE oc.catalog_cd IN (
    (SELECT
     catalog_cd
     FROM cs_component
     WHERE comp_id != 0
      AND comp_id=replace_syn_id))
     AND oc.active_ind=1
     AND oc.orderable_type_flag=6
    ORDER BY cnvtupper(oc.primary_mnemonic)
    HEAD REPORT
     cs_count = 0
    DETAIL
     cs_count = (cs_count+ 1)
     IF (mod(cs_count,10)=1)
      stat = alterlist(cs_temp->cs_list,(cs_count+ 9))
     ENDIF
     cs_temp->cs_list[cs_count].cs_cat_cd = oc.catalog_cd, cs_temp->cs_list[cs_count].cs_name = oc
     .primary_mnemonic
    FOOT REPORT
     stat = alterlist(cs_temp->cs_list,cs_count)
    WITH nocounter
   ;end select
   CALL clear_screen(0)
   CALL text(3,2,"Replace in which CareSet?")
   CALL text(5,67,"Total:  ")
   CALL text(5,75,cnvtstring(cs_count,4))
   CALL create_std_box(cs_count)
   CALL text(6,8,"CareSets")
   WHILE (cnt <= numsrow
    AND cnt <= maxcnt)
     SET holdstr = substring(1,75,cs_temp->cs_list[cnt].cs_name)
     CALL scrolltext(cnt,holdstr)
     SET cnt = (cnt+ 1)
   ENDWHILE
   SET cnt = 1
   SET arow = 1
   CALL text(23,1,"Select CareSet for synonym replacement           (enter 000 to go back)")
   SET pick = 0
   WHILE (pick=0)
    CALL accept(23,44,"9999;S",cnt)
    CASE (curscroll)
     OF 0:
      IF (curaccept=0)
       CALL clear_screen(0)
       GO TO common_utilities_mode
      ELSEIF (cnvtint(curaccept) BETWEEN 1 AND maxcnt)
       SET pick = cnvtint(curaccept)
       CALL clear_screen(0)
      ELSE
       CALL clear_screen(0)
       GO TO common_utilities_mode
      ENDIF
     OF 1:
      IF (cnt < maxcnt)
       SET cnt = (cnt+ 1)
       SET holdstr = substring(1,75,cs_temp->cs_list[cnt].cs_name)
       CALL down_arrow(holdstr)
      ENDIF
     OF 2:
      IF (cnt > 1)
       SET cnt = (cnt - 1)
       SET holdstr = substring(1,75,cs_temp->cs_list[cnt].cs_name)
       CALL up_arrow(holdstr)
      ENDIF
     OF 3:
     OF 4:
     OF 6:
      IF (numsrow < maxcnt)
       SET cnt = ((cnt+ numsrow) - 1)
       IF (((cnt+ numsrow) > maxcnt))
        SET cnt = (maxcnt - numsrow)
       ENDIF
       SET arow = 1
       WHILE (arow <= numsrow)
         SET cnt = (cnt+ 1)
         SET holdstr = substring(1,75,cs_temp->cs_list[cnt].cs_name)
         CALL scrolltext(arow,holdstr)
         SET arow = (arow+ 1)
       ENDWHILE
       SET arow = 1
       SET cnt = ((cnt - numsrow)+ 1)
      ENDIF
     OF 5:
      IF (((cnt - numsrow) > 0))
       SET cnt = (cnt - numsrow)
      ELSE
       SET cnt = 1
      ENDIF
      SET tmp1 = cnt
      SET arow = 1
      WHILE (arow <= numsrow
       AND cnt < maxcnt)
        SET holdstr = substring(1,75,cs_temp->cs_list[cnt].cs_name)
        CALL scrolltext(arow,holdstr)
        SET cnt = (cnt+ 1)
        SET arow = (arow+ 1)
      ENDWHILE
      SET cnt = tmp1
      SET arow = 1
    ENDCASE
   ENDWHILE
   SET cs_name = cs_temp->cs_list[pick].cs_name
   SET cs_cat_cd = cs_temp->cs_list[pick].cs_cat_cd
   IF (cs_cat_cd > 0)
    CALL clear_screen(0)
    CALL text(5,1,"Making the following CareSet synonym replacement:")
    CALL text(7,2,concat("CareSet:  ",cs_name))
    CALL text(8,2,concat("Existing synonym:  ",old_syn_desc))
    CALL text(9,2,concat("New synonym:       ",dest_syn_desc))
    CALL text(11,1,"Execute? (Y/N) ")
    CALL accept(11,17,"C;CU","Y"
     WHERE curaccept IN ("Y", "N"))
    CASE (curaccept)
     OF "Y":
      UPDATE  FROM cs_component cs
       SET comp_id = new_syn_id, updt_task = - (2516)
       WHERE comp_id=replace_syn_id
        AND catalog_cd=cs_cat_cd
       WITH nocounter
      ;end update
      COMMIT
     OF "N":
      GO TO common_utilities_mode
    ENDCASE
   ENDIF
 END ;Subroutine
 SUBROUTINE replace_specific_pp_syn(replace_syn_id,new_syn_id)
   CALL clear_screen(0)
   FREE RECORD pp_temp
   RECORD pp_temp(
     1 pp_list[*]
       2 pp_cat_cd = f8
       2 pp_name = vc
   )
   SET pp_count = 0
   SET cpharm = uar_get_code_by("MEANING",6000,"PHARMACY")
   SET corder = uar_get_code_by("MEANING",6003,"ORDER")
   DECLARE pp_name = vc
   SET pp_cat_cd = 0
   SELECT INTO "nl:"
    pcat.pathway_catalog_id, pcat.description
    FROM pathway_catalog pcat
    WHERE pcat.active_ind=1
     AND pcat.pathway_catalog_id IN (
    (SELECT
     pathway_catalog_id
     FROM pathway_comp
     WHERE parent_entity_id=replace_syn_id))
    ORDER BY cnvtupper(pcat.description)
    HEAD REPORT
     pp_count = 0
    DETAIL
     pp_count = (pp_count+ 1)
     IF (mod(pp_count,10)=1)
      stat = alterlist(pp_temp->pp_list,(pp_count+ 9))
     ENDIF
     pp_temp->pp_list[pp_count].pp_cat_cd = pcat.pathway_catalog_id, pp_temp->pp_list[pp_count].
     pp_name = pcat.description
    FOOT REPORT
     stat = alterlist(pp_temp->pp_list,pp_count)
    WITH nocounter
   ;end select
   CALL clear_screen(0)
   CALL text(3,2,"Replace in which PowerPlan?")
   CALL text(5,67,"Total:  ")
   CALL text(5,75,cnvtstring(pp_count,4))
   CALL create_std_box(pp_count)
   CALL text(6,8,"PowerPlans")
   WHILE (cnt <= numsrow
    AND cnt <= maxcnt)
     SET holdstr = substring(1,75,pp_temp->pp_list[cnt].pp_name)
     CALL scrolltext(cnt,holdstr)
     SET cnt = (cnt+ 1)
   ENDWHILE
   SET cnt = 1
   SET arow = 1
   CALL text(23,1,"Select PowerPlan for synonym replacement           (enter 000 to go back)")
   SET pick = 0
   WHILE (pick=0)
    CALL accept(23,46,"9999;S",cnt)
    CASE (curscroll)
     OF 0:
      IF (curaccept=0)
       CALL clear_screen(0)
       GO TO common_utilities_mode
      ELSEIF (cnvtint(curaccept) BETWEEN 1 AND maxcnt)
       SET pick = cnvtint(curaccept)
       CALL clear_screen(0)
      ELSE
       CALL clear_screen(0)
       GO TO common_utilities_mode
      ENDIF
     OF 1:
      IF (cnt < maxcnt)
       SET cnt = (cnt+ 1)
       SET holdstr = substring(1,75,pp_temp->pp_list[cnt].pp_name)
       CALL down_arrow(holdstr)
      ENDIF
     OF 2:
      IF (cnt > 1)
       SET cnt = (cnt - 1)
       SET holdstr = substring(1,75,pp_temp->pp_list[cnt].pp_name)
       CALL up_arrow(holdstr)
      ENDIF
     OF 3:
     OF 4:
     OF 6:
      IF (numsrow < maxcnt)
       SET cnt = ((cnt+ numsrow) - 1)
       IF (((cnt+ numsrow) > maxcnt))
        SET cnt = (maxcnt - numsrow)
       ENDIF
       SET arow = 1
       WHILE (arow <= numsrow)
         SET cnt = (cnt+ 1)
         SET holdstr = substring(1,75,pp_temp->pp_list[cnt].pp_name)
         CALL scrolltext(arow,holdstr)
         SET arow = (arow+ 1)
       ENDWHILE
       SET arow = 1
       SET cnt = ((cnt - numsrow)+ 1)
      ENDIF
     OF 5:
      IF (((cnt - numsrow) > 0))
       SET cnt = (cnt - numsrow)
      ELSE
       SET cnt = 1
      ENDIF
      SET tmp1 = cnt
      SET arow = 1
      WHILE (arow <= numsrow
       AND cnt < maxcnt)
        SET holdstr = substring(1,75,pp_temp->pp_list[cnt].pp_name)
        CALL scrolltext(arow,holdstr)
        SET cnt = (cnt+ 1)
        SET arow = (arow+ 1)
      ENDWHILE
      SET cnt = tmp1
      SET arow = 1
    ENDCASE
   ENDWHILE
   SET pp_name = pp_temp->pp_list[pick].pp_name
   SET pp_cat_cd = pp_temp->pp_list[pick].pp_cat_cd
   IF (pp_cat_cd > 0)
    CALL clear_screen(0)
    CALL text(5,1,"Making the following PowerPlan synonym replacement:")
    CALL text(7,2,concat("PowerPlan:  ",pp_name))
    CALL text(8,2,concat("Existing synonym:  ",old_syn_desc))
    CALL text(9,2,concat("New synonym:       ",dest_syn_desc))
    CALL text(11,1,"Execute? (Y/N) ")
    CALL accept(11,17,"C;CU","Y"
     WHERE curaccept IN ("Y", "N"))
    CASE (curaccept)
     OF "Y":
      UPDATE  FROM pathway_comp pc
       SET parent_entity_id = new_syn_id, updt_task = - (2516)
       WHERE parent_entity_id=replace_syn_id
        AND pathway_catalog_id=pp_cat_cd
       WITH nocounter
      ;end update
      COMMIT
     OF "N":
      GO TO common_utilities_mode
    ENDCASE
   ENDIF
 END ;Subroutine
 SUBROUTINE strip_str_quotes(start_str)
   DECLARE start_str = vc
   DECLARE end_str = vc
   SET quote_loc = 0
   SET end_str = start_str
   WHILE (findstring(char(34),end_str) > 0)
    SET quote_loc = findstring(char(34),end_str)
    SET end_str = concat(substring(1,(quote_loc - 1),end_str),"'",substring((quote_loc+ 1),(textlen(
       start_str) - quote_loc),end_str))
   ENDWHILE
   SET end_str = trim(end_str)
   RETURN(end_str)
 END ;Subroutine
 SUBROUTINE add_link(inc_synonym_id,inc_item_id)
   SET array_size = (size(new_links->links,5)+ 1)
   SET stat = alterlist(new_links->links,array_size)
   SET new_links->links[array_size].item_id = inc_item_id
   SET new_links->links[array_size].synonym_id = inc_synonym_id
 END ;Subroutine
 SUBROUTINE facility_selection(inc_val)
   CALL clear_screen(0)
   FREE RECORD fac
   RECORD fac(
     1 qual[*]
       2 fac_id = f8
       2 fac_desc = vc
       2 active = c1
   )
   SET ocknt = 0
   SELECT INTO "nl:"
    cv.code_value, cv.description, active_ind = 1
    FROM code_value cv
    WHERE cv.code_set=220
     AND cv.cdf_meaning="FACILITY"
     AND cv.active_ind=1
    ORDER BY cnvtupper(cv.description)
    HEAD REPORT
     stat = alterlist(fac->qual,10), fac->qual[1].fac_id = 0.0, fac->qual[1].fac_desc = substring(1,
      65,"All Facilities"),
     fac->qual[1].active = "1", ocknt = 1
    DETAIL
     ocknt = (ocknt+ 1)
     IF (mod(ocknt,10)=1)
      stat = alterlist(fac->qual,(ocknt+ 9))
     ENDIF
     fac->qual[ocknt].fac_id = cv.code_value, fac->qual[ocknt].fac_desc = substring(1,65,cv
      .description), fac->qual[ocknt].active = "1"
     IF (cv.active_ind=0)
      fac->qual[ocknt].active = "0"
     ENDIF
    FOOT REPORT
     stat = alterlist(fac->qual,ocknt)
    WITH nocounter
   ;end select
   CALL clear_screen(0)
   CALL text(5,67,"Total:  ")
   CALL text(5,75,cnvtstring(ocknt,4))
   CALL create_std_box(ocknt)
   CALL text(6,8,"Facility ")
   CALL text(6,75,"A")
   WHILE (cnt <= numsrow
    AND cnt <= maxcnt)
     SET holdstr65 = fac->qual[cnt].fac_desc
     SET holdstr_a = fac->qual[cnt].active
     SET holdstr = concat(cnvtstring(cnt,4,0,r),"  ",holdstr65," ",holdstr_a)
     CALL scrolltext(cnt,holdstr)
     SET cnt = (cnt+ 1)
   ENDWHILE
   SET cnt = 1
   SET arow = 1
   CALL text(23,1,"Select new ordering facility       (enter 000 to go back)")
   SET pick = 0
   WHILE (pick=0)
    CALL accept(23,30,"9999;S",cnt)
    CASE (curscroll)
     OF 0:
      IF (curaccept=0)
       CALL clear_screen(0)
       GO TO pharm_utilities_mode
      ELSEIF (cnvtint(curaccept) BETWEEN 1 AND maxcnt)
       SET pick = cnvtint(curaccept)
       CALL clear_screen(0)
      ELSE
       CALL clear_screen(0)
       GO TO exit_program
      ENDIF
     OF 1:
      IF (cnt < maxcnt)
       SET cnt = (cnt+ 1)
       SET holdstr65 = fac->qual[cnt].fac_desc
       SET holdstr_a = fac->qual[cnt].active
       SET holdstr = concat(cnvtstring(cnt,4,0,r),"  ",holdstr65," ",holdstr_a)
       CALL down_arrow(holdstr)
      ENDIF
     OF 2:
      IF (cnt > 1)
       SET cnt = (cnt - 1)
       SET holdstr65 = fac->qual[cnt].fac_desc
       SET holdstr_a = fac->qual[cnt].active
       SET holdstr = concat(cnvtstring(cnt,4,0,r),"  ",holdstr65," ",holdstr_a)
       CALL up_arrow(holdstr)
      ENDIF
     OF 3:
     OF 4:
     OF 6:
      IF (numsrow < maxcnt)
       SET cnt = ((cnt+ numsrow) - 1)
       IF (((cnt+ numsrow) > maxcnt))
        SET cnt = (maxcnt - numsrow)
       ENDIF
       SET arow = 1
       WHILE (arow <= numsrow)
         SET cnt = (cnt+ 1)
         SET holdstr65 = fac->qual[cnt].fac_desc
         SET holdstr_a = fac->qual[cnt].active
         SET holdstr = concat(cnvtstring(cnt,4,0,r),"  ",holdstr65," ",holdstr_a)
         CALL scrolltext(arow,holdstr)
         SET arow = (arow+ 1)
       ENDWHILE
       SET arow = 1
       SET cnt = ((cnt - numsrow)+ 1)
      ENDIF
     OF 5:
      IF (((cnt - numsrow) > 0))
       SET cnt = (cnt - numsrow)
      ELSE
       SET cnt = 1
      ENDIF
      SET tmp1 = cnt
      SET arow = 1
      WHILE (arow <= numsrow
       AND cnt < maxcnt)
        SET holdstr65 = fac->qual[cnt].fac_desc
        SET holdstr_a = fac->qual[cnt].active
        SET holdstr = concat(cnvtstring(cnt,4,0,r),"  ",holdstr65," ",holdstr_a)
        CALL scrolltext(arow,holdstr)
        SET cnt = (cnt+ 1)
        SET arow = (arow+ 1)
      ENDWHILE
      SET cnt = tmp1
      SET arow = 1
    ENDCASE
   ENDWHILE
   SET cur_facility_cd = fac->qual[pick].fac_id
   SET cur_facility_desc = trim(fac->qual[pick].fac_desc)
 END ;Subroutine
 SUBROUTINE logging(msg)
   SELECT INTO "asc_cpoe_utilities.log"
    msg
    DETAIL
     col 0, msg, row + 1
    WITH nocounter, append, format = variable,
     noformfeed, maxcol = 132, maxrow = 1
   ;end select
 END ;Subroutine
#exit_program
 CALL clear_screen(0)
END GO
