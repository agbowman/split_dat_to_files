CREATE PROGRAM bhs_him_prod_analysis_sum_ngrp
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Facility(ies)" = 0,
  "Start Date Range (Analysis Date)" = "CURDATE",
  "End Date Range (Analysis date)" = "CURDATE",
  "User Name(s)" = 0,
  "Task Queue(s)" = 0
  WITH outdev, organizations, startdaterange,
  enddaterange, usernames, taskqueues
 EXECUTE reportrtl
 IF (validate(i18nuar_def,999)=999)
  CALL echo("Declaring i18nuar_def")
  DECLARE i18nuar_def = i2 WITH persist
  SET i18nuar_def = 1
  DECLARE uar_i18nlocalizationinit(p1=i4,p2=vc,p3=vc,p4=f8) = i4 WITH persist
  DECLARE uar_i18ngetmessage(p1=i4,p2=vc,p3=vc) = vc WITH persist
  DECLARE uar_i18nbuildmessage() = vc WITH persist
  DECLARE uar_i18ngethijridate(imonth=i2(val),iday=i2(val),iyear=i2(val),sdateformattype=vc(ref)) =
  c50 WITH image_axp = "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar =
  "uar_i18nGetHijriDate",
  persist
  DECLARE uar_i18nbuildfullformatname(sfirst=vc(ref),slast=vc(ref),smiddle=vc(ref),sdegree=vc(ref),
   stitle=vc(ref),
   sprefix=vc(ref),ssuffix=vc(ref),sinitials=vc(ref),soriginal=vc(ref)) = c250 WITH image_axp =
  "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar = "i18nBuildFullFormatName",
  persist
  DECLARE uar_i18ngetarabictime(ctime=vc(ref)) = c20 WITH image_axp = "shri18nuar", image_aix =
  "libi18n_locale.a(libi18n_locale.o)", uar = "i18n_GetArabicTime",
  persist
 ENDIF
 DECLARE i1multifacilitylogicind = i1 WITH noconstant(0), protect
 DECLARE i2multifacilitylogicind = i2 WITH noconstant(0), protect
 DECLARE f8daterangeadd = f8 WITH constant(0.99998842592592592592592592592593), protect
 DECLARE i18nallfacilities = vc WITH noconstant(""), protect
 SET i18nhandlehim = 0
 SET lretval = uar_i18nlocalizationinit(i18nhandlehim,curprog,"",curcclrev)
 SET i18nallfacilities = uar_i18ngetmessage(i18nhandlehim,"HIM_PRMPT_KEY_0","All Facilities")
 SELECT INTO "nl:"
  FROM him_system_params h
  WHERE h.beg_effective_dt_tm <= cnvtdatetime(sysdate)
   AND h.end_effective_dt_tm >= cnvtdatetime(sysdate)
   AND h.active_ind=1
  HEAD REPORT
   i2multifacilitylogicind = h.facility_logic_ind
  DETAIL
   row + 0
  WITH nocounter
 ;end select
 IF (i2multifacilitylogicind != 0)
  SET i1multifacilitylogicind = 1
 ELSE
  SELECT INTO "nl:"
   sec_ind = cnvtint(d.info_number)
   FROM dm_info d
   WHERE d.info_domain="SECURITY"
    AND d.info_name="SEC_ORG_RELTN"
   DETAIL
    i1multifacilitylogicind = sec_ind
   WITH nocounter
  ;end select
  IF (i1multifacilitylogicind != 0)
   SET i1multifacilitylogicind = 1
  ENDIF
 ENDIF
 SUBROUTINE (getdatafromprompt(parameternumber=i1,data=vc(ref)) =null WITH protect)
   SET inputnum = parameternumber
   SET ctype = reflect(parameter(inputnum,0))
   SET parnum = 0
   SET nstop = cnvtint(substring(2,19,ctype))
   IF (nstop > 0)
    CASE (substring(1,1,ctype))
     OF "C":
      SET vcparameterdata = parameter(inputnum,parnum)
      IF (vcparameterdata != "")
       SET stat = alterlist(data->qual,1)
       SET data->qual[1].item_name = vcparameterdata
      ENDIF
     OF "F":
      SET f8parameterdata = parameter(inputnum,parnum)
      IF (f8parameterdata != 0)
       SET stat = alterlist(data->qual,1)
       SET data->qual[1].item_id = f8parameterdata
      ENDIF
     OF "I":
      SET i4parameterdata = parameter(inputnum,parnum)
      IF (i4parameterdata != 0)
       SET stat = alterlist(data->qual,1)
       SET data->qual[1].item_id = i4parameterdata
      ENDIF
     OF "L":
      SET stat = alterlist(data->qual,nstop)
      WHILE (parnum < nstop)
       SET parnum += 1
       SET data->qual[parnum].item_id = parameter(inputnum,parnum)
      ENDWHILE
     ELSE
      SET nothing = null
    ENDCASE
   ENDIF
 END ;Subroutine
 SUBROUTINE (fillqualwithfacilitynames(organizations=vc(ref)) =null WITH protect)
   CALL himgetnamesfromtable(organizations,"organization","org_name","organization_id")
 END ;Subroutine
 SUBROUTINE (himgetnamesforcodevalues(data=vc(ref)) =null WITH protect)
   FOR (index = 1 TO size(data->qual,5))
     SET data->qual[index].item_name = uar_get_code_display(data->qual[index].item_id)
   ENDFOR
 END ;Subroutine
 SUBROUTINE (himgetnamesfromtable(data=vc(ref),tablename=vc,name=vc,id=vc) =null WITH protect)
   DECLARE i4datacount = i4 WITH noconstant(size(data->qual,5)), protect
   DECLARE i4dataindex = i4 WITH noconstant(0), protect
   CALL parser(build2('select into "nl:"'," DATA_NAME = substring(1,200,d.",name,")",",DATA_ID = d.",
     id," "," from ",tablename," d ",
     " where ","expand(i4DataIndex, 1, i4DataCount,","d.",id,", data->qual[i4DataIndex].item_id)",
     " order DATA_NAME, DATA_ID "," head report ","		i4DataIndex = 0 "," head DATA_ID ",
     " i4DataIndex = i4DataIndex + 1 ",
     " data->qual[i4DataIndex].item_name = DATA_NAME "," data->qual[i4DataIndex].item_id = DATA_ID ",
     " detail row+0 with noCounter go"))
 END ;Subroutine
 SUBROUTINE (himrendernodatareport(datasize=i4,outputdevice=vc) =i1 WITH protect)
   IF (datasize=0)
    EXECUTE reportrtl
    SELECT INTO  $OUTDEV
     FROM dual d
     HEAD REPORT
      col 0, "No data found."
     WITH nocounter
    ;end select
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 DECLARE i4userqualindex = i4 WITH protect, noconstant(0)
 FREE RECORD organizations
 RECORD organizations(
   1 qual[*]
     2 item_id = f8
     2 item_name = vc
 )
 FREE RECORD dates
 RECORD dates(
   1 beginning_date = dq8
   1 ending_date = dq8
 )
 FREE RECORD task_queues
 RECORD task_queues(
   1 qual[*]
     2 item_id = f8
     2 item_name = vc
 )
 FREE RECORD users
 RECORD users(
   1 qual[*]
     2 item_id = f8
     2 item_name = vc
 )
 FREE RECORD data
 RECORD data(
   1 qual[*]
     2 patient_name = vc
     2 patient_id = f8
     2 patient_type_cd = f8
     2 disch_dt_tm = dq8
     2 los_days = i4
     2 chart_status_ind = i1
     2 tat_create_to_final = i4
     2 tat_discharge_to_final = i4
     2 mrn = vc
     2 fin = vc
     2 user_name = vc
     2 user_id = f8
     2 encntr_id = f8
     2 organization_name = vc
     2 organization_id = f8
     2 task_queue_cd = f8
     2 task_hist_active_ind = i2
     2 task_hist_active_status_cd = f8
     2 task_hist_active_status_dt_tm = dq8
     2 task_hist_active_status_prsnl_id = f8
     2 task_hist_beg_effective_dt_tm = dq8
     2 task_hist_encntr_id = f8
     2 task_hist_end_effective_dt_tm = dq8
     2 task_hist_location_cd = f8
     2 task_hist_person_id = f8
     2 task_hist_task_activity_history_id = f8
     2 task_hist_task_class_cd = f8
     2 task_hist_task_completed_dt_tm = dq8
     2 task_hist_task_completed_prsnl_id = f8
     2 task_hist_task_create_dt_tm = dq8
     2 task_hist_task_dt_tm = dq8
     2 task_hist_task_id = f8
     2 task_hist_task_status_cd = f8
     2 task_hist_task_type_cd = f8
     2 task_hist_updt_dt_tm = dq8
     2 task_hist_updt_id = f8
     2 task_hist_updt_task = i4
     2 person_abs_birth_dt_tm = dq8
     2 person_active_ind = i2
     2 person_active_status_cd = f8
     2 person_active_status_dt_tm = dq8
     2 person_active_status_prsnl_id = f8
     2 person_archive_env_id = f8
     2 person_archive_status_cd = f8
     2 person_archive_status_dt_tm = dq8
     2 person_autopsy_cd = f8
     2 person_beg_effective_dt_tm = dq8
     2 person_birth_dt_cd = f8
     2 person_birth_dt_tm = dq8
     2 person_birth_prec_flag = i2
     2 person_birth_tz = i4
     2 person_cause_of_death = vc
     2 person_cause_of_death_cd = f8
     2 person_citizenship_cd = f8
     2 person_conception_dt_tm = dq8
     2 person_confid_level_cd = f8
     2 person_contributor_system_cd = f8
     2 person_create_dt_tm = dq8
     2 person_create_prsnl_id = f8
     2 person_data_status_cd = f8
     2 person_data_status_dt_tm = dq8
     2 person_data_status_prsnl_id = f8
     2 person_deceased_cd = f8
     2 person_deceased_dt_tm = dq8
     2 person_deceased_source_cd = f8
     2 person_end_effective_dt_tm = dq8
     2 person_ethnic_grp_cd = f8
     2 person_ft_entity_id = f8
     2 person_ft_entity_name = c32
     2 person_language_cd = f8
     2 person_language_dialect_cd = f8
     2 person_last_accessed_dt_tm = dq8
     2 person_last_encntr_dt_tm = dq8
     2 person_marital_type_cd = f8
     2 person_military_base_location = vc
     2 person_military_rank_cd = f8
     2 person_military_service_cd = f8
     2 person_mother_maiden_name = vc
     2 person_name_first = vc
     2 person_name_first_key = vc
     2 person_name_first_key_nls = vc
     2 person_name_first_phonetic = c8
     2 person_name_first_synonym_id = f8
     2 person_name_full_formatted = vc
     2 person_name_last = vc
     2 person_name_last_key = vc
     2 person_name_last_key_nls = vc
     2 person_name_last_phonetic = c8
     2 person_name_middle = vc
     2 person_name_middle_key = vc
     2 person_name_middle_key_nls = vc
     2 person_name_phonetic = c8
     2 person_nationality_cd = f8
     2 person_next_restore_dt_tm = dq8
     2 person_person_id = f8
     2 person_person_type_cd = f8
     2 person_race_cd = f8
     2 person_religion_cd = f8
     2 person_sex_age_change_ind = i2
     2 person_sex_cd = f8
     2 person_species_cd = f8
     2 person_updt_dt_tm = dq8
     2 person_updt_id = f8
     2 person_updt_task = i4
     2 person_vet_military_status_cd = f8
     2 person_vip_cd = f8
     2 user_active_ind = i2
     2 user_active_status_cd = f8
     2 user_active_status_dt_tm = dq8
     2 user_active_status_prsnl_id = f8
     2 user_beg_effective_dt_tm = dq8
     2 user_contributor_system_cd = f8
     2 user_create_dt_tm = dq8
     2 user_create_prsnl_id = f8
     2 user_data_status_cd = f8
     2 user_data_status_dt_tm = dq8
     2 user_data_status_prsnl_id = f8
     2 user_data_status_prsnl_id = f8
     2 user_email = vc
     2 user_end_effective_dt_tm = dq8
     2 user_end_effective_dt_tm = dq8
     2 user_ft_entity_id = f8
     2 user_ft_entity_name = c32
     2 user_ft_entity_name = c32
     2 user_ft_entity_name = c32
     2 user_name_first = vc
     2 user_name_first_key = vc
     2 user_name_first_key_nls = vc
     2 user_name_full_formatted = vc
     2 user_name_last = vc
     2 user_name_last_key = vc
     2 user_name_last_key_nls = vc
     2 user_password = vc
     2 user_person_id = f8
     2 user_physician_ind = i2
     2 user_physician_status_cd = f8
     2 user_position_cd = f8
     2 user_prim_assign_loc_cd = f8
     2 user_prsnl_type_cd = f8
     2 user_prsnl_type_cd = f8
     2 user_prsnl_type_cd = f8
     2 user_prsnl_type_cd = f8
     2 user_prsnl_type_cd = f8
     2 user_updt_dt_tm = dq8
     2 user_updt_id = f8
     2 user_updt_task = i4
     2 user_username = vc
     2 encntr_accommodation_cd = f8
     2 encntr_accommodation_reason_cd = f8
     2 encntr_accommodation_request_cd = f8
     2 encntr_accomp_by_cd = f8
     2 encntr_active_ind = i2
     2 encntr_active_status_cd = f8
     2 encntr_active_status_dt_tm = dq8
     2 encntr_active_status_prsnl_id = f8
     2 encntr_admit_mode_cd = f8
     2 encntr_admit_src_cd = f8
     2 encntr_admit_type_cd = f8
     2 encntr_admit_with_medication_cd = f8
     2 encntr_alc_decomp_dt_tm = dq8
     2 encntr_alc_reason_cd = f8
     2 encntr_alt_lvl_care_cd = f8
     2 encntr_alt_lvl_care_dt_tm = dq8
     2 encntr_ambulatory_cond_cd = f8
     2 encntr_archive_dt_tm_act = dq8
     2 encntr_archive_dt_tm_est = dq8
     2 encntr_arrive_dt_tm = dq8
     2 encntr_assign_to_loc_dt_tm = dq8
     2 encntr_bbd_procedure_cd = f8
     2 encntr_beg_effective_dt_tm = dq8
     2 encntr_chart_complete_dt_tm = dq8
     2 encntr_confid_level_cd = f8
     2 encntr_contract_status_cd = f8
     2 encntr_contributor_system_cd = f8
     2 encntr_courtesy_cd = f8
     2 encntr_create_dt_tm = dq8
     2 encntr_create_prsnl_id = f8
     2 encntr_data_status_cd = f8
     2 encntr_data_status_dt_tm = dq8
     2 encntr_data_status_prsnl_id = f8
     2 encntr_depart_dt_tm = dq8
     2 encntr_diet_type_cd = f8
     2 encntr_disch_disposition_cd = f8
     2 encntr_disch_dt_tm = dq8
     2 encntr_disch_to_loctn_cd = f8
     2 encntr_doc_rcvd_dt_tm = dq8
     2 encntr_encntr_class_cd = f8
     2 encntr_encntr_complete_dt_tm = dq8
     2 encntr_encntr_financial_id = f8
     2 encntr_encntr_id = f8
     2 encntr_encntr_status_cd = f8
     2 encntr_encntr_type_cd = f8
     2 encntr_encntr_type_class_cd = f8
     2 encntr_end_effective_dt_tm = dq8
     2 encntr_est_arrive_dt_tm = dq8
     2 encntr_est_depart_dt_tm = dq8
     2 encntr_est_length_of_stay = i4
     2 encntr_financial_class_cd = f8
     2 encntr_guarantor_type_cd = f8
     2 encntr_info_given_by = c100
     2 encntr_inpatient_admit_dt_tm = dq8
     2 encntr_isolation_cd = f8
     2 encntr_location_cd = f8
     2 encntr_loc_bed_cd = f8
     2 encntr_loc_building_cd = f8
     2 encntr_loc_facility_cd = f8
     2 encntr_loc_nurse_unit_cd = f8
     2 encntr_loc_room_cd = f8
     2 encntr_loc_temp_cd = f8
     2 encntr_med_service_cd = f8
     2 encntr_mental_category_cd = f8
     2 encntr_mental_health_dt_tm = dq8
     2 encntr_organization_id = f8
     2 encntr_parent_ret_criteria_id = f8
     2 encntr_patient_classification_cd = f8
     2 encntr_pa_current_status_cd = f8
     2 encntr_pa_current_status_dt_tm = dq8
     2 encntr_person_id = f8
     2 encntr_placement_auth_prsnl_id = f8
     2 encntr_preadmit_testing_cd = f8
     2 encntr_pre_reg_dt_tm = dq8
     2 encntr_pre_reg_prsnl_id = f8
     2 encntr_program_service_cd = f8
     2 encntr_psychiatric_status_cd = f8
     2 encntr_purge_dt_tm_act = dq8
     2 encntr_purge_dt_tm_est = dq8
     2 encntr_readmit_cd = f8
     2 encntr_reason_for_visit = vc
     2 encntr_referral_rcvd_dt_tm = dq8
     2 encntr_referring_comment = vc
     2 encntr_refer_facility_cd = f8
     2 encntr_region_cd = f8
     2 encntr_reg_dt_tm = dq8
     2 encntr_reg_prsnl_id = f8
     2 encntr_result_accumulation_dt_tm = dq8
     2 encntr_safekeeping_cd = f8
     2 encntr_security_access_cd = f8
     2 encntr_service_category_cd = f8
     2 encntr_sitter_required_cd = f8
     2 encntr_specialty_unit_cd = f8
     2 encntr_trauma_cd = f8
     2 encntr_trauma_dt_tm = dq8
     2 encntr_triage_cd = f8
     2 encntr_triage_dt_tm = dq8
     2 encntr_updt_dt_tm = dq8
     2 encntr_updt_id = f8
     2 encntr_updt_task = i4
     2 encntr_valuables_cd = f8
     2 encntr_vip_cd = f8
     2 encntr_visitor_status_cd = f8
     2 encntr_zero_balance_dt_tm = dq8
     2 encntr_fin_active_ind = i2
     2 encntr_fin_active_status_cd = f8
     2 encntr_fin_active_status_dt_tm = dq8
     2 encntr_fin_active_status_prsnl_id = f8
     2 encntr_fin_alias = vc
     2 encntr_fin_alias_pool_cd = f8
     2 encntr_fin_assign_authority_sys_cd = f8
     2 encntr_fin_beg_effective_dt_tm = dq8
     2 encntr_fin_check_digit = i4
     2 encntr_fin_check_digit_method_cd = f8
     2 encntr_fin_contributor_system_cd = f8
     2 encntr_fin_data_status_cd = f8
     2 encntr_fin_data_status_dt_tm = dq8
     2 encntr_fin_data_status_prsnl_id = f8
     2 encntr_fin_encntr_alias_id = f8
     2 encntr_fin_encntr_alias_type_cd = f8
     2 encntr_fin_encntr_id = f8
     2 encntr_fin_end_effective_dt_tm = dq8
     2 encntr_fin_updt_dt_tm = dq8
     2 encntr_fin_updt_id = f8
     2 encntr_fin_updt_task = i4
     2 encntr_mrn_active_ind = i2
     2 encntr_mrn_active_status_cd = f8
     2 encntr_mrn_active_status_dt_tm = dq8
     2 encntr_mrn_active_status_prsnl_id = f8
     2 encntr_mrn_alias = vc
     2 encntr_mrn_alias_pool_cd = f8
     2 encntr_mrn_assign_authority_sys_cd = f8
     2 encntr_mrn_beg_effective_dt_tm = dq8
     2 encntr_mrn_check_digit = i4
     2 encntr_mrn_check_digit_method_cd = f8
     2 encntr_mrn_contributor_system_cd = f8
     2 encntr_mrn_data_status_cd = f8
     2 encntr_mrn_data_status_dt_tm = dq8
     2 encntr_mrn_data_status_prsnl_id = f8
     2 encntr_mrn_encntr_alias_id = f8
     2 encntr_mrn_encntr_alias_type_cd = f8
     2 encntr_mrn_encntr_id = f8
     2 encntr_mrn_end_effective_dt_tm = dq8
     2 encntr_mrn_updt_dt_tm = dq8
     2 encntr_mrn_updt_id = f8
     2 encntr_mrn_updt_task = i4
     2 org_active_ind = i2
     2 org_active_status_cd = f8
     2 org_active_status_dt_tm = dq8
     2 org_active_status_prsnl_id = f8
     2 org_beg_effective_dt_tm = dq8
     2 org_contributor_source_cd = f8
     2 org_contributor_system_cd = f8
     2 org_data_status_cd = f8
     2 org_data_status_dt_tm = dq8
     2 org_data_status_prsnl_id = f8
     2 org_end_effective_dt_tm = dq8
     2 org_federal_tax_id_nbr = vc
     2 org_ft_entity_id = f8
     2 org_ft_entity_name = c32
     2 org_organization_id = f8
     2 org_org_class_cd = f8
     2 org_org_name = vc
     2 org_org_name_key = vc
     2 org_org_name_key_nls = vc
     2 org_org_status_cd = f8
     2 org_updt_dt_tm = dq8
     2 org_updt_id = f8
     2 org_updt_task = i4
 )
 IF (i1multifacilitylogicind)
  CALL getdatafromprompt(2,organizations)
  CALL himgetnamesfromtable(organizations,"organization","org_name","organization_id")
 ENDIF
 SET dates->beginning_date = cnvtdatetime( $STARTDATERANGE)
 SET dates->ending_date = datetimeadd(cnvtdatetime( $ENDDATERANGE),f8daterangeadd)
 CALL getdatafromprompt(5,users)
 CALL himgetnamesfromtable(users,"prsnl","name_full_formatted","person_id")
 CALL getdatafromprompt(6,task_queues)
 CALL himgetnamesforcodevalues(task_queues)
 EXECUTE him_mak_prod_analysis_driver
 IF (himrendernodatareport(size(data->qual,5), $OUTDEV))
  RETURN
 ENDIF
 DECLARE crlf = c2 WITH constant(concat(char(13),char(10))), protect
 DECLARE space = c1 WITH constant(char(9)), protect
 DECLARE him_program_name = vc WITH constant(request->program_name), protect
 DECLARE him_window = i1 WITH constant(1), protect
 DECLARE him_render_params = vc WITH constant(
  IF (findstring(",",request->params)) build("mine",substring(findstring(",",request->params),textlen
     (request->params),replace(request->params,'"',"^",0)))
  ELSE "mine"
  ENDIF
  ), protect
 DECLARE him_prompt = i1 WITH constant(0), protect
 DECLARE him_dash = i1 WITH constant(1), protect
 DECLARE vctodaydatetime = vc WITH noconstant(""), protect
 DECLARE vcuser = vc WITH noconstant("                "), protect
 DECLARE i18ndateprinted = vc WITH noconstant(""), protect
 DECLARE i18nuserprinted = vc WITH noconstant(""), protect
 DECLARE i18npromptsfilters = vc WITH noconstant(""), protect
 DECLARE i18nfacilities = vc WITH noconstant(""), protect
 DECLARE i18ndaterange = vc WITH noconstant(""), protect
 DECLARE i18nto = vc WITH noconstant(""), protect
 DECLARE i18nfrom = vc WITH noconstant(""), protect
 DECLARE i18nrequestlocation = vc WITH noconstant(""), protect
 EXECUTE reportrtl
 SET vctodaydatetime = format(cnvtdatetime(sysdate),"@SHORTDATETIME;;Q")
 SET i18ndateprinted = uar_i18ngetmessage(i18nhandlehim,"HIM_LYT_KEY_0","Date Printed:")
 SET i18nuserprinted = uar_i18ngetmessage(i18nhandlehim,"HIM_LYT_KEY_1","User Who Printed:")
 SET i18npromptsfilters = uar_i18ngetmessage(i18nhandlehim,"HIM_LYT_KEY_2","Prompts/Filters:")
 SET i18nfacilities = uar_i18ngetmessage(i18nhandlehim,"HIM_LYT_KEY_3","Facility(ies):")
 SET i18ndaterange = uar_i18ngetmessage(i18nhandlehim,"HIM_LYT_KEY_4","Date Range:")
 SET i18nfrom = uar_i18ngetmessage(i18nhandlehim,"HIM_LYT_KEY_5","From")
 SET i18nto = uar_i18ngetmessage(i18nhandlehim,"HIM_LYT_KEY_6","To")
 SET i18nrequestlocation = uar_i18ngetmessage(i18nhandlehim,"HIM_LYT_KEY_7","Requesting Location:")
 SELECT INTO "nl:"
  FROM prsnl p
  WHERE (p.person_id=reqinfo->updt_id)
   AND p.active_ind=1
  DETAIL
   vcuser = p.name_full_formatted
  WITH nocounter, maxqual(p,1)
 ;end select
 SUBROUTINE (getdaterangedisplay(dates=vc(ref),type=i1) =vc WITH protect)
   DECLARE vcfilterdaterange = vc WITH noconstant(""), private
   CASE (type)
    OF him_prompt:
     IF (cnvtdate(dates->beginning_date) > 0
      AND cnvtdate(dates->ending_date) > 0)
      SET vcfilterdaterange = build2(i18nfrom," ",format(dates->beginning_date,"@SHORTDATE;;Q")," ",
       " ",
       i18nto," ",format(dates->ending_date,"@SHORTDATE;;Q"))
     ELSE
      SET vcfilterdaterange = uar_i18ngetmessage(i18nhandlehim,"NORANGE1","No Range")
     ENDIF
    OF him_dash:
     IF (cnvtdate(dates->beginning_date) > 0
      AND cnvtdate(dates->ending_date) > 0)
      SET vcfilterdaterange = build2(format(dates->beginning_date,"@SHORTDATE;;Q")," -  ",format(
        dates->ending_date,"@SHORTDATE;;Q"))
     ELSE
      SET vcfilterdaterange = uar_i18ngetmessage(i18nhandlehim,"NORANGE2","NO RANGE")
     ENDIF
    ELSE
     SET vcfilterdaterange = uar_i18ngetmessage(i18nhandlehim,"NODATESFOUND","No Dates Found")
   ENDCASE
   RETURN(vcfilterdaterange)
 END ;Subroutine
 SUBROUTINE (cnvtminstodayshoursmins(mins=i4) =vc WITH protect)
   DECLARE hours = i4 WITH noconstant(0), protect
   DECLARE days = i4 WITH noconstant(0), protect
   DECLARE vctime = vc WITH noconstant(""), protect
   SET days = (mins/ (60 * 24))
   IF (days < 1)
    SET mins = mod(mins,(60 * 24))
    SET hours = (mins/ 60)
    SET mins = mod(mins,60)
    SET vctime = build2(format(hours,"##;P0")," hrs ",format(mins,"##;P0")," mins")
   ELSE
    SET vctime = build2(days," days ")
   ENDIF
   RETURN(vctime)
 END ;Subroutine
 SUBROUTINE (makelistofqualitemnames(data=vc(ref),default=vc) =vc WITH protect)
   DECLARE i4linecount = i4 WITH noconstant(1), protect
   DECLARE i4qualcount = i4 WITH noconstant(size(data->qual,5)), protect
   DECLARE i4count = i4 WITH noconstant(1), protect
   DECLARE list = vc WITH noconstant(" "), protect
   IF (i4qualcount=0)
    SET list = default
   ELSE
    FOR (i4count = 1 TO i4qualcount)
      IF (i4count=i4qualcount)
       IF (size(trim(data->qual[i4count].item_name,3)) > 0)
        SET list = build2(list,trim(data->qual[i4count].item_name,3))
       ENDIF
      ELSE
       IF (size(trim(data->qual[i4count].item_name,3)) > 0)
        SET list = build2(list,trim(data->qual[i4count].item_name,3),"; ")
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   RETURN(list)
 END ;Subroutine
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE main(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE initializereport(dummy) = null WITH protect
 IF (validate(_bsubreport) != 1)
  DECLARE _bsubreport = i1 WITH noconstant(0), protect
 ENDIF
 IF (_bsubreport=0)
  DECLARE _hreport = h WITH noconstant(0), protect
  DECLARE _yoffset = f8 WITH noconstant(0.0), protect
  DECLARE _xoffset = f8 WITH noconstant(0.0), protect
  RECORD _htmlfileinfo(
    1 file_desc = i4
    1 file_name = vc
    1 file_buf = vc
    1 file_offset = i4
    1 file_dir = i4
  ) WITH protect
  SET _htmlfileinfo->file_desc = 0
  DECLARE _htmlfilestat = i4 WITH noconstant(0), protect
  DECLARE _bgeneratehtml = i1 WITH noconstant(evaluate(validate(request->output_device,"N"),"MINE",1,
    '"MINE"',1,
    0)), protect
 ENDIF
 DECLARE _hi18nhandle = i4 WITH noconstant(0), protect
 DECLARE rpt_render = i2 WITH constant(0), protect
 DECLARE _crlf = vc WITH constant(concat(char(13),char(10))), protect
 DECLARE rpt_calcheight = i2 WITH constant(1), protect
 DECLARE _yshift = f8 WITH noconstant(0.0), protect
 DECLARE _xshift = f8 WITH noconstant(0.0), protect
 DECLARE _sendto = vc WITH noconstant( $OUTDEV), protect
 DECLARE _rpterr = i2 WITH noconstant(0), protect
 DECLARE _rptstat = i2 WITH noconstant(0), protect
 DECLARE _oldfont = i4 WITH noconstant(0), protect
 DECLARE _oldpen = i4 WITH noconstant(0), protect
 DECLARE _dummyfont = i4 WITH noconstant(0), protect
 DECLARE _dummypen = i4 WITH noconstant(0), protect
 DECLARE _fdrawheight = f8 WITH noconstant(0.0), protect
 DECLARE _rptpage = h WITH noconstant(0), protect
 DECLARE _diotype = i2 WITH noconstant(8), protect
 DECLARE _outputtype = i2 WITH noconstant(rpt_pdf), protect
 DECLARE _remfacilitylist = i4 WITH noconstant(1), protect
 DECLARE _bholdcontinue = i2 WITH noconstant(0), protect
 DECLARE _bcontfieldname08 = i2 WITH noconstant(0), protect
 DECLARE _remuserlist = i4 WITH noconstant(1), protect
 DECLARE _bcontfieldname09 = i2 WITH noconstant(0), protect
 DECLARE _remtaskqueuelist = i4 WITH noconstant(1), protect
 DECLARE _bcontfieldname010 = i2 WITH noconstant(0), protect
 DECLARE _remcellname22 = i4 WITH noconstant(1), protect
 DECLARE _remcellname21 = i4 WITH noconstant(1), protect
 DECLARE _remcellname17 = i4 WITH noconstant(1), protect
 DECLARE _remcellname14 = i4 WITH noconstant(1), protect
 DECLARE _bcontfieldname014 = i2 WITH noconstant(0), protect
 DECLARE _remcellname60 = i4 WITH noconstant(1), protect
 DECLARE _remcellname59 = i4 WITH noconstant(1), protect
 DECLARE _remcellname56 = i4 WITH noconstant(1), protect
 DECLARE _bcontfieldname019 = i2 WITH noconstant(0), protect
 DECLARE _remtatcreatetofinalrowone = i4 WITH noconstant(1), protect
 DECLARE _remtatdischargetofinalrowone = i4 WITH noconstant(1), protect
 DECLARE _remavglosdisplayrowone = i4 WITH noconstant(1), protect
 DECLARE _remtotalchartsrowone = i4 WITH noconstant(1), protect
 DECLARE _remtaskqueuerowone = i4 WITH noconstant(1), protect
 DECLARE _remuser_username_ = i4 WITH noconstant(1), protect
 DECLARE _remusernamerowone = i4 WITH noconstant(1), protect
 DECLARE _bcontfieldname023 = i2 WITH noconstant(0), protect
 DECLARE _remtatcreatetofinalrowtwo = i4 WITH noconstant(1), protect
 DECLARE _remtatdischargetofinalrowtwo = i4 WITH noconstant(1), protect
 DECLARE _remavglosdisplayrowtwo = i4 WITH noconstant(1), protect
 DECLARE _remtotalchartsrowtwo = i4 WITH noconstant(1), protect
 DECLARE _remtaskqueuerowtwo = i4 WITH noconstant(1), protect
 DECLARE _remuser_username02 = i4 WITH noconstant(1), protect
 DECLARE _remusernamerowtwo = i4 WITH noconstant(1), protect
 DECLARE _bcontfieldname024 = i2 WITH noconstant(0), protect
 DECLARE _times12b8289918 = i4 WITH noconstant(0), protect
 DECLARE _times12bi10485760 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _times10b0 = i4 WITH noconstant(0), protect
 DECLARE _times10bi255 = i4 WITH noconstant(0), protect
 DECLARE _pen25s0c0 = i4 WITH noconstant(0), protect
 DECLARE _pen0s0c0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
 SUBROUTINE (cclbuildhlink(vcprogname=vc,vcparams=vc,nwindow=i2,vcdescription=vc) =vc WITH protect)
   DECLARE vcreturn = vc WITH private, noconstant(vcdescription)
   IF ((_htmlfileinfo->file_desc != 0))
    SET vcreturn = build(^<a href='javascript:CCLLINK("^,vcprogname,'","',vcparams,'",',
     nwindow,")'>",vcdescription,"</a>")
   ENDIF
   RETURN(vcreturn)
 END ;Subroutine
 SUBROUTINE (cclbuildapplink(nmode=i2,vcappname=vc,vcparams=vc,vcdescription=vc) =vc WITH protect)
   DECLARE vcreturn = vc WITH private, noconstant(vcdescription)
   IF ((_htmlfileinfo->file_desc != 0))
    SET vcreturn = build("<a href='javascript:APPLINK(",nmode,',"',vcappname,'","',
     vcparams,^")'>^,vcdescription,"</a>")
   ENDIF
   RETURN(vcreturn)
 END ;Subroutine
 SUBROUTINE (cclbuildweblink(vcaddress=vc,nmode=i2,vcdescription=vc) =vc WITH protect)
   DECLARE vcreturn = vc WITH private, noconstant(vcdescription)
   IF ((_htmlfileinfo->file_desc != 0))
    IF (nmode=1)
     SET vcreturn = build("<a href='",vcaddress,"'>",vcdescription,"</a>")
    ELSE
     SET vcreturn = build("<a href='",vcaddress,"' target='_blank'>",vcdescription,"</a>")
    ENDIF
   ENDIF
   RETURN(vcreturn)
 END ;Subroutine
 SUBROUTINE main(dummy)
   SELECT
    IF (size(data->qual,5)=0)
     FROM (dummyt d  WITH seq = value(size(data->qual,5))),
      organization o
     PLAN (d
      WHERE d.seq > 0)
      JOIN (o
      WHERE o.organization_id=0
       AND o.organization_id != 0)
    ELSE
    ENDIF
    INTO "nl:"
    patient_name = substring(1,100,data->qual[d.seq].patient_name), patient_id = data->qual[d.seq].
    patient_id, patient_type_cd = data->qual[d.seq].patient_type_cd,
    disch_dt_tm = data->qual[d.seq].disch_dt_tm, los_days = data->qual[d.seq].los_days,
    tat_create_to_final = data->qual[d.seq].tat_create_to_final,
    tat_discharge_to_final = data->qual[d.seq].tat_discharge_to_final, mrn = substring(1,100,data->
     qual[d.seq].mrn), fin = substring(1,100,data->qual[d.seq].fin),
    user_name = substring(1,100,data->qual[d.seq].user_name), user_id = data->qual[d.seq].user_id,
    organization_name = substring(1,100,data->qual[d.seq].organization_name),
    organization_id = data->qual[d.seq].organization_id, task_queue_cd = data->qual[d.seq].
    task_queue_cd, patient_type_name = uar_get_code_display(cnvtreal(data->qual[d.seq].
      patient_type_cd)),
    encntr_id = data->qual[d.seq].encntr_id, task_queue_name = uar_get_code_display(cnvtreal(data->
      qual[d.seq].task_queue_cd)), person_abs_birth_dt_tm = data->qual[d.seq].person_abs_birth_dt_tm,
    person_active_ind = data->qual[d.seq].person_active_ind, person_active_status_cd = data->qual[d
    .seq].person_active_status_cd, person_active_status_dt_tm = data->qual[d.seq].
    person_active_status_dt_tm,
    person_active_status_prsnl_id = data->qual[d.seq].person_active_status_prsnl_id,
    person_archive_env_id = data->qual[d.seq].person_archive_env_id, person_archive_status_cd = data
    ->qual[d.seq].person_archive_status_cd,
    person_archive_status_dt_tm = data->qual[d.seq].person_archive_status_dt_tm, person_autopsy_cd =
    data->qual[d.seq].person_autopsy_cd, person_beg_effective_dt_tm = data->qual[d.seq].
    person_beg_effective_dt_tm,
    person_birth_dt_cd = data->qual[d.seq].person_birth_dt_cd, person_birth_dt_tm = data->qual[d.seq]
    .person_birth_dt_tm, person_birth_prec_flag = data->qual[d.seq].person_birth_prec_flag,
    person_birth_tz = data->qual[d.seq].person_birth_tz, person_cause_of_death = substring(1,100,data
     ->qual[d.seq].person_cause_of_death), person_cause_of_death_cd = data->qual[d.seq].
    person_cause_of_death_cd,
    person_citizenship_cd = data->qual[d.seq].person_citizenship_cd, person_conception_dt_tm = data->
    qual[d.seq].person_conception_dt_tm, person_confid_level_cd = data->qual[d.seq].
    person_confid_level_cd,
    person_contributor_system_cd = data->qual[d.seq].person_contributor_system_cd,
    person_create_dt_tm = data->qual[d.seq].person_create_dt_tm, person_create_prsnl_id = data->qual[
    d.seq].person_create_prsnl_id,
    person_data_status_cd = data->qual[d.seq].person_data_status_cd, person_data_status_dt_tm = data
    ->qual[d.seq].person_data_status_dt_tm, person_data_status_prsnl_id = data->qual[d.seq].
    person_data_status_prsnl_id,
    person_deceased_cd = data->qual[d.seq].person_deceased_cd, person_deceased_dt_tm = data->qual[d
    .seq].person_deceased_dt_tm, person_deceased_source_cd = data->qual[d.seq].
    person_deceased_source_cd,
    person_end_effective_dt_tm = data->qual[d.seq].person_end_effective_dt_tm, person_ethnic_grp_cd
     = data->qual[d.seq].person_ethnic_grp_cd, person_ft_entity_id = data->qual[d.seq].
    person_ft_entity_id,
    person_ft_entity_name = substring(1,32,data->qual[d.seq].person_ft_entity_name),
    person_language_cd = data->qual[d.seq].person_language_cd, person_language_dialect_cd = data->
    qual[d.seq].person_language_dialect_cd,
    person_last_accessed_dt_tm = data->qual[d.seq].person_last_accessed_dt_tm,
    person_last_encntr_dt_tm = data->qual[d.seq].person_last_encntr_dt_tm, person_marital_type_cd =
    data->qual[d.seq].person_marital_type_cd,
    person_military_base_location = substring(1,100,data->qual[d.seq].person_military_base_location),
    person_military_rank_cd = data->qual[d.seq].person_military_rank_cd, person_military_service_cd
     = data->qual[d.seq].person_military_service_cd,
    person_mother_maiden_name = substring(1,100,data->qual[d.seq].person_mother_maiden_name),
    person_name_first = substring(1,200,data->qual[d.seq].person_name_first), person_name_first_key
     = substring(1,100,data->qual[d.seq].person_name_first_key),
    person_name_first_key_nls = substring(1,202,data->qual[d.seq].person_name_first_key_nls),
    person_name_first_phonetic = substring(1,8,data->qual[d.seq].person_name_first_phonetic),
    person_name_first_synonym_id = data->qual[d.seq].person_name_first_synonym_id,
    person_name_full_formatted = substring(1,100,data->qual[d.seq].person_name_full_formatted),
    person_name_last = substring(1,200,data->qual[d.seq].person_name_last), person_name_last_key =
    substring(1,100,data->qual[d.seq].person_name_last_key),
    person_name_last_key_nls = substring(1,202,data->qual[d.seq].person_name_last_key_nls),
    person_name_last_phonetic = substring(1,8,data->qual[d.seq].person_name_last_phonetic),
    person_name_middle = substring(1,200,data->qual[d.seq].person_name_middle),
    person_name_middle_key = substring(1,100,data->qual[d.seq].person_name_middle_key),
    person_name_middle_key_nls = substring(1,202,data->qual[d.seq].person_name_middle_key_nls),
    person_name_phonetic = substring(1,8,data->qual[d.seq].person_name_phonetic),
    person_nationality_cd = data->qual[d.seq].person_nationality_cd, person_next_restore_dt_tm = data
    ->qual[d.seq].person_next_restore_dt_tm, person_person_id = data->qual[d.seq].person_person_id,
    person_person_type_cd = data->qual[d.seq].person_person_type_cd, person_race_cd = data->qual[d
    .seq].person_race_cd, person_religion_cd = data->qual[d.seq].person_religion_cd,
    person_sex_age_change_ind = data->qual[d.seq].person_sex_age_change_ind, person_sex_cd = data->
    qual[d.seq].person_sex_cd, person_species_cd = data->qual[d.seq].person_species_cd,
    person_updt_dt_tm = data->qual[d.seq].person_updt_dt_tm, person_updt_id = data->qual[d.seq].
    person_updt_id, person_updt_task = data->qual[d.seq].person_updt_task,
    person_vet_military_status_cd = data->qual[d.seq].person_vet_military_status_cd, person_vip_cd =
    data->qual[d.seq].person_vip_cd, org_active_ind = data->qual[d.seq].org_active_ind,
    org_active_status_cd = data->qual[d.seq].org_active_status_cd, org_active_status_dt_tm = data->
    qual[d.seq].org_active_status_dt_tm, org_active_status_prsnl_id = data->qual[d.seq].
    org_active_status_prsnl_id,
    org_beg_effective_dt_tm = data->qual[d.seq].org_beg_effective_dt_tm, org_contributor_source_cd =
    data->qual[d.seq].org_contributor_source_cd, org_contributor_system_cd = data->qual[d.seq].
    org_contributor_system_cd,
    org_data_status_cd = data->qual[d.seq].org_data_status_cd, org_data_status_dt_tm = data->qual[d
    .seq].org_data_status_dt_tm, org_data_status_prsnl_id = data->qual[d.seq].
    org_data_status_prsnl_id,
    org_end_effective_dt_tm = data->qual[d.seq].org_end_effective_dt_tm, org_federal_tax_id_nbr =
    substring(1,100,data->qual[d.seq].org_federal_tax_id_nbr), org_ft_entity_id = data->qual[d.seq].
    org_ft_entity_id,
    org_ft_entity_name = substring(1,32,data->qual[d.seq].org_ft_entity_name), org_organization_id =
    data->qual[d.seq].org_organization_id, org_org_class_cd = data->qual[d.seq].org_org_class_cd,
    org_org_name = substring(1,100,data->qual[d.seq].org_org_name), org_org_name_key = substring(1,
     100,data->qual[d.seq].org_org_name_key), org_org_name_key_nls = substring(1,202,data->qual[d.seq
     ].org_org_name_key_nls),
    org_org_status_cd = data->qual[d.seq].org_org_status_cd, org_updt_dt_tm = data->qual[d.seq].
    org_updt_dt_tm, org_updt_id = data->qual[d.seq].org_updt_id,
    org_updt_task = data->qual[d.seq].org_updt_task, encntr_accommodation_cd = data->qual[d.seq].
    encntr_accommodation_cd, encntr_accommodation_reason_cd = data->qual[d.seq].
    encntr_accommodation_reason_cd,
    encntr_accommodation_request_cd = data->qual[d.seq].encntr_accommodation_request_cd,
    encntr_accomp_by_cd = data->qual[d.seq].encntr_accomp_by_cd, encntr_active_ind = data->qual[d.seq
    ].encntr_active_ind,
    encntr_active_status_cd = data->qual[d.seq].encntr_active_status_cd, encntr_active_status_dt_tm
     = data->qual[d.seq].encntr_active_status_dt_tm, encntr_active_status_prsnl_id = data->qual[d.seq
    ].encntr_active_status_prsnl_id,
    encntr_admit_mode_cd = data->qual[d.seq].encntr_admit_mode_cd, encntr_admit_src_cd = data->qual[d
    .seq].encntr_admit_src_cd, encntr_admit_type_cd = data->qual[d.seq].encntr_admit_type_cd,
    encntr_admit_with_medication_cd = data->qual[d.seq].encntr_admit_with_medication_cd,
    encntr_alc_decomp_dt_tm = data->qual[d.seq].encntr_alc_decomp_dt_tm, encntr_alc_reason_cd = data
    ->qual[d.seq].encntr_alc_reason_cd,
    encntr_alt_lvl_care_cd = data->qual[d.seq].encntr_alt_lvl_care_cd, encntr_alt_lvl_care_dt_tm =
    data->qual[d.seq].encntr_alt_lvl_care_dt_tm, encntr_ambulatory_cond_cd = data->qual[d.seq].
    encntr_ambulatory_cond_cd,
    encntr_archive_dt_tm_act = data->qual[d.seq].encntr_archive_dt_tm_act, encntr_archive_dt_tm_est
     = data->qual[d.seq].encntr_archive_dt_tm_est, encntr_arrive_dt_tm = data->qual[d.seq].
    encntr_arrive_dt_tm,
    encntr_assign_to_loc_dt_tm = data->qual[d.seq].encntr_assign_to_loc_dt_tm,
    encntr_bbd_procedure_cd = data->qual[d.seq].encntr_bbd_procedure_cd, encntr_beg_effective_dt_tm
     = data->qual[d.seq].encntr_beg_effective_dt_tm,
    encntr_chart_complete_dt_tm = data->qual[d.seq].encntr_chart_complete_dt_tm,
    encntr_confid_level_cd = data->qual[d.seq].encntr_confid_level_cd, encntr_contract_status_cd =
    data->qual[d.seq].encntr_contract_status_cd,
    encntr_contributor_system_cd = data->qual[d.seq].encntr_contributor_system_cd, encntr_courtesy_cd
     = data->qual[d.seq].encntr_courtesy_cd, encntr_create_dt_tm = data->qual[d.seq].
    encntr_create_dt_tm,
    encntr_create_prsnl_id = data->qual[d.seq].encntr_create_prsnl_id, encntr_data_status_cd = data->
    qual[d.seq].encntr_data_status_cd, encntr_data_status_dt_tm = data->qual[d.seq].
    encntr_data_status_dt_tm,
    encntr_data_status_prsnl_id = data->qual[d.seq].encntr_data_status_prsnl_id, encntr_depart_dt_tm
     = data->qual[d.seq].encntr_depart_dt_tm, encntr_diet_type_cd = data->qual[d.seq].
    encntr_diet_type_cd,
    encntr_disch_disposition_cd = data->qual[d.seq].encntr_disch_disposition_cd, encntr_disch_dt_tm
     = data->qual[d.seq].encntr_disch_dt_tm, encntr_disch_to_loctn_cd = data->qual[d.seq].
    encntr_disch_to_loctn_cd,
    encntr_doc_rcvd_dt_tm = data->qual[d.seq].encntr_doc_rcvd_dt_tm, encntr_encntr_class_cd = data->
    qual[d.seq].encntr_encntr_class_cd, encntr_encntr_complete_dt_tm = data->qual[d.seq].
    encntr_encntr_complete_dt_tm,
    encntr_encntr_financial_id = data->qual[d.seq].encntr_encntr_financial_id, encntr_encntr_id =
    data->qual[d.seq].encntr_encntr_id, encntr_encntr_status_cd = data->qual[d.seq].
    encntr_encntr_status_cd,
    encntr_encntr_type_cd = data->qual[d.seq].encntr_encntr_type_cd, encntr_encntr_type_class_cd =
    data->qual[d.seq].encntr_encntr_type_class_cd, encntr_end_effective_dt_tm = data->qual[d.seq].
    encntr_end_effective_dt_tm,
    encntr_est_arrive_dt_tm = data->qual[d.seq].encntr_est_arrive_dt_tm, encntr_est_depart_dt_tm =
    data->qual[d.seq].encntr_est_depart_dt_tm, encntr_est_length_of_stay = data->qual[d.seq].
    encntr_est_length_of_stay,
    encntr_financial_class_cd = data->qual[d.seq].encntr_financial_class_cd, encntr_guarantor_type_cd
     = data->qual[d.seq].encntr_guarantor_type_cd, encntr_info_given_by = substring(1,100,data->qual[
     d.seq].encntr_info_given_by),
    encntr_inpatient_admit_dt_tm = data->qual[d.seq].encntr_inpatient_admit_dt_tm,
    encntr_isolation_cd = data->qual[d.seq].encntr_isolation_cd, encntr_location_cd = data->qual[d
    .seq].encntr_location_cd,
    encntr_loc_bed_cd = data->qual[d.seq].encntr_loc_bed_cd, encntr_loc_building_cd = data->qual[d
    .seq].encntr_loc_building_cd, encntr_loc_facility_cd = data->qual[d.seq].encntr_loc_facility_cd,
    encntr_loc_nurse_unit_cd = data->qual[d.seq].encntr_loc_nurse_unit_cd, encntr_loc_room_cd = data
    ->qual[d.seq].encntr_loc_room_cd, encntr_loc_temp_cd = data->qual[d.seq].encntr_loc_temp_cd,
    encntr_med_service_cd = data->qual[d.seq].encntr_med_service_cd, encntr_mental_category_cd = data
    ->qual[d.seq].encntr_mental_category_cd, encntr_mental_health_dt_tm = data->qual[d.seq].
    encntr_mental_health_dt_tm,
    encntr_organization_id = data->qual[d.seq].encntr_organization_id, encntr_parent_ret_criteria_id
     = data->qual[d.seq].encntr_parent_ret_criteria_id, encntr_patient_classification_cd = data->
    qual[d.seq].encntr_patient_classification_cd,
    encntr_pa_current_status_cd = data->qual[d.seq].encntr_pa_current_status_cd,
    encntr_pa_current_status_dt_tm = data->qual[d.seq].encntr_pa_current_status_dt_tm,
    encntr_person_id = data->qual[d.seq].encntr_person_id,
    encntr_placement_auth_prsnl_id = data->qual[d.seq].encntr_placement_auth_prsnl_id,
    encntr_preadmit_testing_cd = data->qual[d.seq].encntr_preadmit_testing_cd, encntr_pre_reg_dt_tm
     = data->qual[d.seq].encntr_pre_reg_dt_tm,
    encntr_pre_reg_prsnl_id = data->qual[d.seq].encntr_pre_reg_prsnl_id, encntr_program_service_cd =
    data->qual[d.seq].encntr_program_service_cd, encntr_psychiatric_status_cd = data->qual[d.seq].
    encntr_psychiatric_status_cd,
    encntr_purge_dt_tm_act = data->qual[d.seq].encntr_purge_dt_tm_act, encntr_purge_dt_tm_est = data
    ->qual[d.seq].encntr_purge_dt_tm_est, encntr_readmit_cd = data->qual[d.seq].encntr_readmit_cd,
    encntr_reason_for_visit = substring(1,255,data->qual[d.seq].encntr_reason_for_visit),
    encntr_referral_rcvd_dt_tm = data->qual[d.seq].encntr_referral_rcvd_dt_tm,
    encntr_referring_comment = substring(1,100,data->qual[d.seq].encntr_referring_comment),
    encntr_refer_facility_cd = data->qual[d.seq].encntr_refer_facility_cd, encntr_region_cd = data->
    qual[d.seq].encntr_region_cd, encntr_reg_dt_tm = data->qual[d.seq].encntr_reg_dt_tm,
    encntr_reg_prsnl_id = data->qual[d.seq].encntr_reg_prsnl_id, encntr_result_accumulation_dt_tm =
    data->qual[d.seq].encntr_result_accumulation_dt_tm, encntr_safekeeping_cd = data->qual[d.seq].
    encntr_safekeeping_cd,
    encntr_security_access_cd = data->qual[d.seq].encntr_security_access_cd,
    encntr_service_category_cd = data->qual[d.seq].encntr_service_category_cd,
    encntr_sitter_required_cd = data->qual[d.seq].encntr_sitter_required_cd,
    encntr_specialty_unit_cd = data->qual[d.seq].encntr_specialty_unit_cd, encntr_trauma_cd = data->
    qual[d.seq].encntr_trauma_cd, encntr_trauma_dt_tm = data->qual[d.seq].encntr_trauma_dt_tm,
    encntr_triage_cd = data->qual[d.seq].encntr_triage_cd, encntr_triage_dt_tm = data->qual[d.seq].
    encntr_triage_dt_tm, encntr_updt_dt_tm = data->qual[d.seq].encntr_updt_dt_tm,
    encntr_updt_id = data->qual[d.seq].encntr_updt_id, encntr_updt_task = data->qual[d.seq].
    encntr_updt_task, encntr_valuables_cd = data->qual[d.seq].encntr_valuables_cd,
    encntr_vip_cd = data->qual[d.seq].encntr_vip_cd, encntr_visitor_status_cd = data->qual[d.seq].
    encntr_visitor_status_cd, encntr_zero_balance_dt_tm = data->qual[d.seq].encntr_zero_balance_dt_tm,
    encntr_mrn_active_ind = data->qual[d.seq].encntr_mrn_active_ind, encntr_mrn_active_status_cd =
    data->qual[d.seq].encntr_mrn_active_status_cd, encntr_mrn_active_status_dt_tm = data->qual[d.seq]
    .encntr_mrn_active_status_dt_tm,
    encntr_mrn_active_status_prsnl_id = data->qual[d.seq].encntr_mrn_active_status_prsnl_id,
    encntr_mrn_alias = substring(1,200,data->qual[d.seq].encntr_mrn_alias), encntr_mrn_alias_pool_cd
     = data->qual[d.seq].encntr_mrn_alias_pool_cd,
    encntr_mrn_assign_authority_sys_cd = data->qual[d.seq].encntr_mrn_assign_authority_sys_cd,
    encntr_mrn_beg_effective_dt_tm = data->qual[d.seq].encntr_mrn_beg_effective_dt_tm,
    encntr_mrn_check_digit = data->qual[d.seq].encntr_mrn_check_digit,
    encntr_mrn_check_digit_method_cd = data->qual[d.seq].encntr_mrn_check_digit_method_cd,
    encntr_mrn_contributor_system_cd = data->qual[d.seq].encntr_mrn_contributor_system_cd,
    encntr_mrn_data_status_cd = data->qual[d.seq].encntr_mrn_data_status_cd,
    encntr_mrn_data_status_dt_tm = data->qual[d.seq].encntr_mrn_data_status_dt_tm,
    encntr_mrn_data_status_prsnl_id = data->qual[d.seq].encntr_mrn_data_status_prsnl_id,
    encntr_mrn_encntr_alias_id = data->qual[d.seq].encntr_mrn_encntr_alias_id,
    encntr_mrn_encntr_alias_type_cd = data->qual[d.seq].encntr_mrn_encntr_alias_type_cd,
    encntr_mrn_encntr_id = data->qual[d.seq].encntr_mrn_encntr_id, encntr_mrn_end_effective_dt_tm =
    data->qual[d.seq].encntr_mrn_end_effective_dt_tm,
    encntr_mrn_updt_dt_tm = data->qual[d.seq].encntr_mrn_updt_dt_tm, encntr_mrn_updt_id = data->qual[
    d.seq].encntr_mrn_updt_id, encntr_mrn_updt_task = data->qual[d.seq].encntr_mrn_updt_task,
    encntr_fin_active_ind = data->qual[d.seq].encntr_fin_active_ind, encntr_fin_active_status_cd =
    data->qual[d.seq].encntr_fin_active_status_cd, encntr_fin_active_status_dt_tm = data->qual[d.seq]
    .encntr_fin_active_status_dt_tm,
    encntr_fin_active_status_prsnl_id = data->qual[d.seq].encntr_fin_active_status_prsnl_id,
    encntr_fin_alias = substring(1,200,data->qual[d.seq].encntr_fin_alias), encntr_fin_alias_pool_cd
     = data->qual[d.seq].encntr_fin_alias_pool_cd,
    encntr_fin_assign_authority_sys_cd = data->qual[d.seq].encntr_fin_assign_authority_sys_cd,
    encntr_fin_beg_effective_dt_tm = data->qual[d.seq].encntr_fin_beg_effective_dt_tm,
    encntr_fin_check_digit = data->qual[d.seq].encntr_fin_check_digit,
    encntr_fin_check_digit_method_cd = data->qual[d.seq].encntr_fin_check_digit_method_cd,
    encntr_fin_contributor_system_cd = data->qual[d.seq].encntr_fin_contributor_system_cd,
    encntr_fin_data_status_cd = data->qual[d.seq].encntr_fin_data_status_cd,
    encntr_fin_data_status_dt_tm = data->qual[d.seq].encntr_fin_data_status_dt_tm,
    encntr_fin_data_status_prsnl_id = data->qual[d.seq].encntr_fin_data_status_prsnl_id,
    encntr_fin_encntr_alias_id = data->qual[d.seq].encntr_fin_encntr_alias_id,
    encntr_fin_encntr_alias_type_cd = data->qual[d.seq].encntr_fin_encntr_alias_type_cd,
    encntr_fin_encntr_id = data->qual[d.seq].encntr_fin_encntr_id, encntr_fin_end_effective_dt_tm =
    data->qual[d.seq].encntr_fin_end_effective_dt_tm,
    encntr_fin_updt_dt_tm = data->qual[d.seq].encntr_fin_updt_dt_tm, encntr_fin_updt_id = data->qual[
    d.seq].encntr_fin_updt_id, encntr_fin_updt_task = data->qual[d.seq].encntr_fin_updt_task,
    user_active_ind = data->qual[d.seq].user_active_ind, user_active_status_cd = data->qual[d.seq].
    user_active_status_cd, user_active_status_dt_tm = data->qual[d.seq].user_active_status_dt_tm,
    user_active_status_prsnl_id = data->qual[d.seq].user_active_status_prsnl_id,
    user_beg_effective_dt_tm = data->qual[d.seq].user_beg_effective_dt_tm, user_contributor_system_cd
     = data->qual[d.seq].user_contributor_system_cd,
    user_create_dt_tm = data->qual[d.seq].user_create_dt_tm, user_create_prsnl_id = data->qual[d.seq]
    .user_create_prsnl_id, user_data_status_cd = data->qual[d.seq].user_data_status_cd,
    user_data_status_dt_tm = data->qual[d.seq].user_data_status_dt_tm, user_data_status_prsnl_id =
    data->qual[d.seq].user_data_status_prsnl_id, user_email = substring(1,100,data->qual[d.seq].
     user_email),
    user_end_effective_dt_tm = data->qual[d.seq].user_end_effective_dt_tm, user_ft_entity_id = data->
    qual[d.seq].user_ft_entity_id, user_ft_entity_name = substring(1,32,data->qual[d.seq].
     user_ft_entity_name),
    user_name_first = substring(1,200,data->qual[d.seq].user_name_first), user_name_first_key =
    substring(1,100,data->qual[d.seq].user_name_first_key), user_name_first_key_nls = substring(1,202,
     data->qual[d.seq].user_name_first_key_nls),
    user_name_full_formatted = substring(1,100,data->qual[d.seq].user_name_full_formatted),
    user_name_last = substring(1,200,data->qual[d.seq].user_name_last), user_name_last_key =
    substring(1,100,data->qual[d.seq].user_name_last_key),
    user_name_last_key_nls = substring(1,202,data->qual[d.seq].user_name_last_key_nls), user_password
     = substring(1,100,data->qual[d.seq].user_password), user_person_id = data->qual[d.seq].
    user_person_id,
    user_physician_ind = data->qual[d.seq].user_physician_ind, user_physician_status_cd = data->qual[
    d.seq].user_physician_status_cd, user_position_cd = data->qual[d.seq].user_position_cd,
    user_prim_assign_loc_cd = data->qual[d.seq].user_prim_assign_loc_cd, user_prsnl_type_cd = data->
    qual[d.seq].user_prsnl_type_cd, user_updt_dt_tm = data->qual[d.seq].user_updt_dt_tm,
    user_updt_id = data->qual[d.seq].user_updt_id, user_updt_task = data->qual[d.seq].user_updt_task,
    user_username = substring(1,50,data->qual[d.seq].user_username),
    task_hist_active_ind = data->qual[d.seq].task_hist_active_ind, task_hist_active_status_cd = data
    ->qual[d.seq].task_hist_active_status_cd, task_hist_active_status_dt_tm = data->qual[d.seq].
    task_hist_active_status_dt_tm,
    task_hist_active_status_prsnl_id = data->qual[d.seq].task_hist_active_status_prsnl_id,
    task_hist_beg_effective_dt_tm = data->qual[d.seq].task_hist_beg_effective_dt_tm,
    task_hist_encntr_id = data->qual[d.seq].task_hist_encntr_id,
    task_hist_end_effective_dt_tm = data->qual[d.seq].task_hist_end_effective_dt_tm,
    task_hist_location_cd = data->qual[d.seq].task_hist_location_cd, task_hist_person_id = data->
    qual[d.seq].task_hist_person_id,
    task_hist_task_activity_history_id = data->qual[d.seq].task_hist_task_activity_history_id,
    task_hist_task_class_cd = data->qual[d.seq].task_hist_task_class_cd,
    task_hist_task_completed_dt_tm = data->qual[d.seq].task_hist_task_completed_dt_tm,
    task_hist_task_completed_prsnl_id = data->qual[d.seq].task_hist_task_completed_prsnl_id,
    task_hist_task_create_dt_tm = data->qual[d.seq].task_hist_task_create_dt_tm, task_hist_task_dt_tm
     = data->qual[d.seq].task_hist_task_dt_tm,
    task_hist_task_id = data->qual[d.seq].task_hist_task_id, task_hist_task_status_cd = data->qual[d
    .seq].task_hist_task_status_cd, task_hist_task_type_cd = data->qual[d.seq].task_hist_task_type_cd,
    task_hist_updt_dt_tm = data->qual[d.seq].task_hist_updt_dt_tm, task_hist_updt_id = data->qual[d
    .seq].task_hist_updt_id, task_hist_updt_task = data->qual[d.seq].task_hist_updt_task
    FROM (dummyt d  WITH seq = value(size(data->qual,5)))
    WHERE d.seq > 0
    ORDER BY user_name, user_id, task_queue_name,
     task_queue_cd, patient_type_name, patient_type_cd
    HEAD REPORT
     _d0 = los_days, _d1 = tat_create_to_final, _d2 = tat_discharge_to_final,
     _d3 = fin, _d4 = user_name, _d5 = task_queue_name,
     _d6 = user_username, _fenddetail = (rptreport->m_pagewidth - rptreport->m_marginbottom),
     daterange = getdaterangedisplay(dates,him_dash),
     totalchartsperorganization = 0, totaltatperorganization = 0, avgtatperorganization = 0,
     totaltattaskperorganization = 0, avgtattaskperorganization = 0, totalchartsperuser = 0,
     totaltatperuser = 0, avgtatperuser = 0, totaltattaskperuser = 0,
     avgtattaskperuser = 0, totalchartsperqueue = 0, totallengthofstayperqueue = 0,
     avglengthofstayperqueue = 0, totaltatperqueue = 0, avgtatperqueue = 0,
     totaltattaskperqueue = 0, avgtattaskperqueue = 0, detailcount = 0,
     rowcount = 0, dataqualcount = size(data->qual,5), blank = "",
     allfacilities = uar_i18ngetmessage(i18nhandlehim,"ALLFACILITIES","All Facilities"), facilitylist
      = makelistofqualitemnames(organizations,allfacilities), allusers = uar_i18ngetmessage(
      i18nhandlehim,"ALLUSERS","All Users"),
     userlist = makelistofqualitemnames(users,allusers), alltaskqueues = uar_i18ngetmessage(
      i18nhandlehim,"ALLTASKQUEUES","All Task Queues"), taskqueuelist = makelistofqualitemnames(
      task_queues,alltaskqueues),
     _fdrawheight = fieldname00(rpt_calcheight)
     IF (_fdrawheight > 0)
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight += fieldname01(rpt_calcheight)
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight += fieldname02(rpt_calcheight)
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight += fieldname03(rpt_calcheight)
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight += fieldname04(rpt_calcheight)
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight += fieldname05(rpt_calcheight)
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight += fieldname06(rpt_calcheight)
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight += fieldname07(rpt_calcheight)
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _bholdcontinue = 0, _fdrawheight += fieldname08(rpt_calcheight,((_fenddetail - _yoffset) -
        _fdrawheight),_bholdcontinue)
       IF (_bholdcontinue=1)
        _fdrawheight = (_fenddetail+ 1)
       ENDIF
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _bholdcontinue = 0, _fdrawheight += fieldname09(rpt_calcheight,((_fenddetail - _yoffset) -
        _fdrawheight),_bholdcontinue)
       IF (_bholdcontinue=1)
        _fdrawheight = (_fenddetail+ 1)
       ENDIF
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _bholdcontinue = 0, _fdrawheight += fieldname010(rpt_calcheight,((_fenddetail - _yoffset) -
        _fdrawheight),_bholdcontinue)
       IF (_bholdcontinue=1)
        _fdrawheight = (_fenddetail+ 1)
       ENDIF
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight += fieldname011(rpt_calcheight)
      ENDIF
     ENDIF
     IF (((_yoffset+ _fdrawheight) > (rptreport->m_pagewidth - rptreport->m_marginbottom)))
      CALL pagebreak(0)
     ENDIF
     dummy_val = fieldname00(rpt_render), _fdrawheight = fieldname01(rpt_calcheight)
     IF (_fdrawheight > 0)
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight += fieldname02(rpt_calcheight)
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight += fieldname03(rpt_calcheight)
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight += fieldname04(rpt_calcheight)
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight += fieldname05(rpt_calcheight)
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight += fieldname06(rpt_calcheight)
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight += fieldname07(rpt_calcheight)
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _bholdcontinue = 0, _fdrawheight += fieldname08(rpt_calcheight,((_fenddetail - _yoffset) -
        _fdrawheight),_bholdcontinue)
       IF (_bholdcontinue=1)
        _fdrawheight = (_fenddetail+ 1)
       ENDIF
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _bholdcontinue = 0, _fdrawheight += fieldname09(rpt_calcheight,((_fenddetail - _yoffset) -
        _fdrawheight),_bholdcontinue)
       IF (_bholdcontinue=1)
        _fdrawheight = (_fenddetail+ 1)
       ENDIF
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _bholdcontinue = 0, _fdrawheight += fieldname010(rpt_calcheight,((_fenddetail - _yoffset) -
        _fdrawheight),_bholdcontinue)
       IF (_bholdcontinue=1)
        _fdrawheight = (_fenddetail+ 1)
       ENDIF
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight += fieldname011(rpt_calcheight)
      ENDIF
     ENDIF
     IF (((_yoffset+ _fdrawheight) > (rptreport->m_pagewidth - rptreport->m_marginbottom)))
      CALL pagebreak(0)
     ENDIF
     dummy_val = fieldname01(rpt_render), _fdrawheight = fieldname02(rpt_calcheight)
     IF (_fdrawheight > 0)
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight += fieldname03(rpt_calcheight)
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight += fieldname04(rpt_calcheight)
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight += fieldname05(rpt_calcheight)
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight += fieldname06(rpt_calcheight)
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight += fieldname07(rpt_calcheight)
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _bholdcontinue = 0, _fdrawheight += fieldname08(rpt_calcheight,((_fenddetail - _yoffset) -
        _fdrawheight),_bholdcontinue)
       IF (_bholdcontinue=1)
        _fdrawheight = (_fenddetail+ 1)
       ENDIF
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _bholdcontinue = 0, _fdrawheight += fieldname09(rpt_calcheight,((_fenddetail - _yoffset) -
        _fdrawheight),_bholdcontinue)
       IF (_bholdcontinue=1)
        _fdrawheight = (_fenddetail+ 1)
       ENDIF
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _bholdcontinue = 0, _fdrawheight += fieldname010(rpt_calcheight,((_fenddetail - _yoffset) -
        _fdrawheight),_bholdcontinue)
       IF (_bholdcontinue=1)
        _fdrawheight = (_fenddetail+ 1)
       ENDIF
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight += fieldname011(rpt_calcheight)
      ENDIF
     ENDIF
     IF (((_yoffset+ _fdrawheight) > (rptreport->m_pagewidth - rptreport->m_marginbottom)))
      CALL pagebreak(0)
     ENDIF
     dummy_val = fieldname02(rpt_render), _fdrawheight = fieldname03(rpt_calcheight)
     IF (_fdrawheight > 0)
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight += fieldname04(rpt_calcheight)
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight += fieldname05(rpt_calcheight)
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight += fieldname06(rpt_calcheight)
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight += fieldname07(rpt_calcheight)
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _bholdcontinue = 0, _fdrawheight += fieldname08(rpt_calcheight,((_fenddetail - _yoffset) -
        _fdrawheight),_bholdcontinue)
       IF (_bholdcontinue=1)
        _fdrawheight = (_fenddetail+ 1)
       ENDIF
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _bholdcontinue = 0, _fdrawheight += fieldname09(rpt_calcheight,((_fenddetail - _yoffset) -
        _fdrawheight),_bholdcontinue)
       IF (_bholdcontinue=1)
        _fdrawheight = (_fenddetail+ 1)
       ENDIF
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _bholdcontinue = 0, _fdrawheight += fieldname010(rpt_calcheight,((_fenddetail - _yoffset) -
        _fdrawheight),_bholdcontinue)
       IF (_bholdcontinue=1)
        _fdrawheight = (_fenddetail+ 1)
       ENDIF
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight += fieldname011(rpt_calcheight)
      ENDIF
     ENDIF
     IF (((_yoffset+ _fdrawheight) > (rptreport->m_pagewidth - rptreport->m_marginbottom)))
      CALL pagebreak(0)
     ENDIF
     dummy_val = fieldname03(rpt_render), _fdrawheight = fieldname04(rpt_calcheight)
     IF (_fdrawheight > 0)
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight += fieldname05(rpt_calcheight)
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight += fieldname06(rpt_calcheight)
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight += fieldname07(rpt_calcheight)
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _bholdcontinue = 0, _fdrawheight += fieldname08(rpt_calcheight,((_fenddetail - _yoffset) -
        _fdrawheight),_bholdcontinue)
       IF (_bholdcontinue=1)
        _fdrawheight = (_fenddetail+ 1)
       ENDIF
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _bholdcontinue = 0, _fdrawheight += fieldname09(rpt_calcheight,((_fenddetail - _yoffset) -
        _fdrawheight),_bholdcontinue)
       IF (_bholdcontinue=1)
        _fdrawheight = (_fenddetail+ 1)
       ENDIF
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _bholdcontinue = 0, _fdrawheight += fieldname010(rpt_calcheight,((_fenddetail - _yoffset) -
        _fdrawheight),_bholdcontinue)
       IF (_bholdcontinue=1)
        _fdrawheight = (_fenddetail+ 1)
       ENDIF
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight += fieldname011(rpt_calcheight)
      ENDIF
     ENDIF
     IF (((_yoffset+ _fdrawheight) > (rptreport->m_pagewidth - rptreport->m_marginbottom)))
      CALL pagebreak(0)
     ENDIF
     dummy_val = fieldname04(rpt_render), _fdrawheight = fieldname05(rpt_calcheight)
     IF (_fdrawheight > 0)
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight += fieldname06(rpt_calcheight)
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight += fieldname07(rpt_calcheight)
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _bholdcontinue = 0, _fdrawheight += fieldname08(rpt_calcheight,((_fenddetail - _yoffset) -
        _fdrawheight),_bholdcontinue)
       IF (_bholdcontinue=1)
        _fdrawheight = (_fenddetail+ 1)
       ENDIF
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _bholdcontinue = 0, _fdrawheight += fieldname09(rpt_calcheight,((_fenddetail - _yoffset) -
        _fdrawheight),_bholdcontinue)
       IF (_bholdcontinue=1)
        _fdrawheight = (_fenddetail+ 1)
       ENDIF
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _bholdcontinue = 0, _fdrawheight += fieldname010(rpt_calcheight,((_fenddetail - _yoffset) -
        _fdrawheight),_bholdcontinue)
       IF (_bholdcontinue=1)
        _fdrawheight = (_fenddetail+ 1)
       ENDIF
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight += fieldname011(rpt_calcheight)
      ENDIF
     ENDIF
     IF (((_yoffset+ _fdrawheight) > (rptreport->m_pagewidth - rptreport->m_marginbottom)))
      CALL pagebreak(0)
     ENDIF
     dummy_val = fieldname05(rpt_render), _fdrawheight = fieldname06(rpt_calcheight)
     IF (_fdrawheight > 0)
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight += fieldname07(rpt_calcheight)
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _bholdcontinue = 0, _fdrawheight += fieldname08(rpt_calcheight,((_fenddetail - _yoffset) -
        _fdrawheight),_bholdcontinue)
       IF (_bholdcontinue=1)
        _fdrawheight = (_fenddetail+ 1)
       ENDIF
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _bholdcontinue = 0, _fdrawheight += fieldname09(rpt_calcheight,((_fenddetail - _yoffset) -
        _fdrawheight),_bholdcontinue)
       IF (_bholdcontinue=1)
        _fdrawheight = (_fenddetail+ 1)
       ENDIF
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _bholdcontinue = 0, _fdrawheight += fieldname010(rpt_calcheight,((_fenddetail - _yoffset) -
        _fdrawheight),_bholdcontinue)
       IF (_bholdcontinue=1)
        _fdrawheight = (_fenddetail+ 1)
       ENDIF
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight += fieldname011(rpt_calcheight)
      ENDIF
     ENDIF
     IF (((_yoffset+ _fdrawheight) > (rptreport->m_pagewidth - rptreport->m_marginbottom)))
      CALL pagebreak(0)
     ENDIF
     dummy_val = fieldname06(rpt_render), _fdrawheight = fieldname07(rpt_calcheight)
     IF (_fdrawheight > 0)
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _bholdcontinue = 0, _fdrawheight += fieldname08(rpt_calcheight,((_fenddetail - _yoffset) -
        _fdrawheight),_bholdcontinue)
       IF (_bholdcontinue=1)
        _fdrawheight = (_fenddetail+ 1)
       ENDIF
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _bholdcontinue = 0, _fdrawheight += fieldname09(rpt_calcheight,((_fenddetail - _yoffset) -
        _fdrawheight),_bholdcontinue)
       IF (_bholdcontinue=1)
        _fdrawheight = (_fenddetail+ 1)
       ENDIF
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _bholdcontinue = 0, _fdrawheight += fieldname010(rpt_calcheight,((_fenddetail - _yoffset) -
        _fdrawheight),_bholdcontinue)
       IF (_bholdcontinue=1)
        _fdrawheight = (_fenddetail+ 1)
       ENDIF
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight += fieldname011(rpt_calcheight)
      ENDIF
     ENDIF
     IF (((_yoffset+ _fdrawheight) > (rptreport->m_pagewidth - rptreport->m_marginbottom)))
      CALL pagebreak(0)
     ENDIF
     dummy_val = fieldname07(rpt_render), _bcontfieldname08 = 0, bfirsttime = 1
     WHILE (((_bcontfieldname08=1) OR (bfirsttime=1)) )
       _bholdcontinue = _bcontfieldname08, _fdrawheight = fieldname08(rpt_calcheight,((rptreport->
        m_pagewidth - rptreport->m_marginbottom) - _yoffset),_bholdcontinue)
       IF (((_bholdcontinue=1) OR (_fdrawheight > 0)) )
        IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
         _bholdcontinue = 0, _fdrawheight += fieldname09(rpt_calcheight,((_fenddetail - _yoffset) -
          _fdrawheight),_bholdcontinue)
         IF (_bholdcontinue=1)
          _fdrawheight = (_fenddetail+ 1)
         ENDIF
        ENDIF
        IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
         _bholdcontinue = 0, _fdrawheight += fieldname010(rpt_calcheight,((_fenddetail - _yoffset) -
          _fdrawheight),_bholdcontinue)
         IF (_bholdcontinue=1)
          _fdrawheight = (_fenddetail+ 1)
         ENDIF
        ENDIF
        IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
         _fdrawheight += fieldname011(rpt_calcheight)
        ENDIF
       ENDIF
       IF (((_yoffset+ _fdrawheight) > (rptreport->m_pagewidth - rptreport->m_marginbottom)))
        CALL pagebreak(0)
       ELSEIF (_bholdcontinue=1
        AND _bcontfieldname08=0)
        CALL pagebreak(0)
       ENDIF
       dummy_val = fieldname08(rpt_render,((rptreport->m_pagewidth - rptreport->m_marginbottom) -
        _yoffset),_bcontfieldname08), bfirsttime = 0
     ENDWHILE
     _bcontfieldname09 = 0, bfirsttime = 1
     WHILE (((_bcontfieldname09=1) OR (bfirsttime=1)) )
       _bholdcontinue = _bcontfieldname09, _fdrawheight = fieldname09(rpt_calcheight,((rptreport->
        m_pagewidth - rptreport->m_marginbottom) - _yoffset),_bholdcontinue)
       IF (((_bholdcontinue=1) OR (_fdrawheight > 0)) )
        IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
         _bholdcontinue = 0, _fdrawheight += fieldname010(rpt_calcheight,((_fenddetail - _yoffset) -
          _fdrawheight),_bholdcontinue)
         IF (_bholdcontinue=1)
          _fdrawheight = (_fenddetail+ 1)
         ENDIF
        ENDIF
        IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
         _fdrawheight += fieldname011(rpt_calcheight)
        ENDIF
       ENDIF
       IF (((_yoffset+ _fdrawheight) > (rptreport->m_pagewidth - rptreport->m_marginbottom)))
        CALL pagebreak(0)
       ELSEIF (_bholdcontinue=1
        AND _bcontfieldname09=0)
        CALL pagebreak(0)
       ENDIF
       dummy_val = fieldname09(rpt_render,((rptreport->m_pagewidth - rptreport->m_marginbottom) -
        _yoffset),_bcontfieldname09), bfirsttime = 0
     ENDWHILE
     _bcontfieldname010 = 0, bfirsttime = 1
     WHILE (((_bcontfieldname010=1) OR (bfirsttime=1)) )
       _bholdcontinue = _bcontfieldname010, _fdrawheight = fieldname010(rpt_calcheight,((rptreport->
        m_pagewidth - rptreport->m_marginbottom) - _yoffset),_bholdcontinue)
       IF (((_bholdcontinue=1) OR (_fdrawheight > 0)) )
        IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
         _fdrawheight += fieldname011(rpt_calcheight)
        ENDIF
       ENDIF
       IF (((_yoffset+ _fdrawheight) > (rptreport->m_pagewidth - rptreport->m_marginbottom)))
        CALL pagebreak(0)
       ELSEIF (_bholdcontinue=1
        AND _bcontfieldname010=0)
        CALL pagebreak(0)
       ENDIF
       dummy_val = fieldname010(rpt_render,((rptreport->m_pagewidth - rptreport->m_marginbottom) -
        _yoffset),_bcontfieldname010), bfirsttime = 0
     ENDWHILE
     _fdrawheight = fieldname011(rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > (rptreport->m_pagewidth - rptreport->m_marginbottom)))
      CALL pagebreak(0)
     ENDIF
     dummy_val = fieldname011(rpt_render)
    HEAD PAGE
     IF (curpage > 1)
      dummy_val = pagebreak(0)
     ENDIF
     dummy_val = fieldname012(rpt_render), dummy_val = fieldname013(rpt_render), _bcontfieldname014
      = 0,
     dummy_val = fieldname014(rpt_render,((rptreport->m_pagewidth - rptreport->m_marginbottom) -
      _yoffset),_bcontfieldname014)
    HEAD user_name
     usernamehead = "", totalchartsperuser = 0, totaltatperuser = 0,
     avgtatperuser = 0, totaltattaskperuser = 0, avgtattaskperuser = 0,
     _fdrawheight = fieldname016(rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = fieldname016(rpt_render)
    HEAD user_id
     _fdrawheight = fieldname017(rpt_calcheight)
     IF (_fdrawheight > 0)
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight += fieldname018(rpt_calcheight)
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _bholdcontinue = 0, _fdrawheight += fieldname019(rpt_calcheight,((_fenddetail - _yoffset) -
        _fdrawheight),_bholdcontinue)
       IF (_bholdcontinue=1)
        _fdrawheight = (_fenddetail+ 1)
       ENDIF
      ENDIF
     ENDIF
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = fieldname017(rpt_render), _fdrawheight = fieldname018(rpt_calcheight)
     IF (_fdrawheight > 0)
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _bholdcontinue = 0, _fdrawheight += fieldname019(rpt_calcheight,((_fenddetail - _yoffset) -
        _fdrawheight),_bholdcontinue)
       IF (_bholdcontinue=1)
        _fdrawheight = (_fenddetail+ 1)
       ENDIF
      ENDIF
     ENDIF
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = fieldname018(rpt_render), _bcontfieldname019 = 0, bfirsttime = 1
     WHILE (((_bcontfieldname019=1) OR (bfirsttime=1)) )
       _bholdcontinue = _bcontfieldname019, _fdrawheight = fieldname019(rpt_calcheight,(_fenddetail
         - _yoffset),_bholdcontinue)
       IF (((_yoffset+ _fdrawheight) > _fenddetail))
        BREAK
       ELSEIF (_bholdcontinue=1
        AND _bcontfieldname019=0)
        BREAK
       ENDIF
       dummy_val = fieldname019(rpt_render,(_fenddetail - _yoffset),_bcontfieldname019), bfirsttime
        = 0
     ENDWHILE
    HEAD task_queue_name
     _fdrawheight = fieldname020(rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = fieldname020(rpt_render)
    HEAD task_queue_cd
     taskqueuehead = "", totalchartsperqueue = 0, totallengthofstayperqueue = 0,
     avglengthofstayperqueue = 0, totaltatperqueue = 0, avgtatperqueue = 0,
     totaltattaskperqueue = 0, avgtattaskperqueue = 0, rowcount = 0,
     _fdrawheight = fieldname021(rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = fieldname021(rpt_render)
    HEAD patient_type_name
     row + 0
    HEAD patient_type_cd
     row + 0
    DETAIL
     detailblankrow = "", totalchartsperorganization += 1, totaltatperorganization +=
     tat_discharge_to_final,
     totaltattaskperorganization += tat_create_to_final, totalchartsperuser += 1, totaltatperuser +=
     tat_discharge_to_final,
     totaltattaskperuser += tat_create_to_final, totalchartsperqueue += 1, totallengthofstayperqueue
      += los_days,
     totaltatperqueue += tat_discharge_to_final, totaltattaskperqueue += tat_create_to_final,
     detailcount += 1,
     _fdrawheight = fieldname022(rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = fieldname022(rpt_render)
    FOOT  patient_type_cd
     row + 0
    FOOT  patient_type_name
     row + 0
    FOOT  task_queue_cd
     usernamerowone = user_name, rowcount += 1, totalchartsrowone = build(totalchartsperqueue),
     avglosdisplayrowone = trim(build(los_days),3), usernamerowtwo = user_name, totalchartsrowtwo =
     build(totalchartsperqueue),
     avglosdisplayrowtwo = trim(build(los_days),3), _bcontfieldname023 = 0, bfirsttime = 1
     WHILE (((_bcontfieldname023=1) OR (bfirsttime=1)) )
       _bholdcontinue = _bcontfieldname023, _fdrawheight = fieldname023(rpt_calcheight,(_fenddetail
         - _yoffset),_bholdcontinue)
       IF (((_bholdcontinue=1) OR (_fdrawheight > 0)) )
        IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
         _bholdcontinue = 0, _fdrawheight += fieldname024(rpt_calcheight,((_fenddetail - _yoffset) -
          _fdrawheight),_bholdcontinue)
         IF (_bholdcontinue=1)
          _fdrawheight = (_fenddetail+ 1)
         ENDIF
        ENDIF
       ENDIF
       IF (((_yoffset+ _fdrawheight) > _fenddetail))
        BREAK
       ELSEIF (_bholdcontinue=1
        AND _bcontfieldname023=0)
        BREAK
       ENDIF
       dummy_val = fieldname023(rpt_render,(_fenddetail - _yoffset),_bcontfieldname023), bfirsttime
        = 0
     ENDWHILE
     _bcontfieldname024 = 0, bfirsttime = 1
     WHILE (((_bcontfieldname024=1) OR (bfirsttime=1)) )
       _bholdcontinue = _bcontfieldname024, _fdrawheight = fieldname024(rpt_calcheight,(_fenddetail
         - _yoffset),_bholdcontinue)
       IF (((_yoffset+ _fdrawheight) > _fenddetail))
        BREAK
       ELSEIF (_bholdcontinue=1
        AND _bcontfieldname024=0)
        BREAK
       ENDIF
       dummy_val = fieldname024(rpt_render,(_fenddetail - _yoffset),_bcontfieldname024), bfirsttime
        = 0
     ENDWHILE
    FOOT  task_queue_name
     row + 0
    FOOT  user_id
     totalchartsperuserdisplay = build(totalchartsperuser)
     IF (totalchartsperuser > 0)
      avgtatperuserdisplay = build(cnvtminstodayshoursmins((totaltatperuser/ totalchartsperuser)))
     ELSE
      avgtatperuserdisplay = build(cnvtminstodayshoursmins(0))
     ENDIF
     IF (totalchartsperuser > 0)
      avgtattaskperuserdisplay = build(cnvtminstodayshoursmins((totaltattaskperuser/
        totalchartsperuser)))
     ELSE
      avgtattaskperuserdisplay = build(cnvtminstodayshoursmins(0))
     ENDIF
     _fdrawheight = fieldname025(rpt_calcheight)
     IF (_fdrawheight > 0)
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight += fieldname026(rpt_calcheight)
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight += fieldname027(rpt_calcheight)
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight += fieldname028(rpt_calcheight)
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight += fieldname029(rpt_calcheight)
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight += fieldname030(rpt_calcheight)
      ENDIF
     ENDIF
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = fieldname025(rpt_render), _fdrawheight = fieldname026(rpt_calcheight)
     IF (_fdrawheight > 0)
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight += fieldname027(rpt_calcheight)
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight += fieldname028(rpt_calcheight)
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight += fieldname029(rpt_calcheight)
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight += fieldname030(rpt_calcheight)
      ENDIF
     ENDIF
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = fieldname026(rpt_render), _fdrawheight = fieldname027(rpt_calcheight)
     IF (_fdrawheight > 0)
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight += fieldname028(rpt_calcheight)
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight += fieldname029(rpt_calcheight)
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight += fieldname030(rpt_calcheight)
      ENDIF
     ENDIF
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = fieldname027(rpt_render), _fdrawheight = fieldname028(rpt_calcheight)
     IF (_fdrawheight > 0)
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight += fieldname029(rpt_calcheight)
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight += fieldname030(rpt_calcheight)
      ENDIF
     ENDIF
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = fieldname028(rpt_render), _fdrawheight = fieldname029(rpt_calcheight)
     IF (_fdrawheight > 0)
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight += fieldname030(rpt_calcheight)
      ENDIF
     ENDIF
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = fieldname029(rpt_render), _fdrawheight = fieldname030(rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = fieldname030(rpt_render)
    FOOT  user_name
     row + 0
    FOOT REPORT
     _fdrawheight = fieldname036(rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      CALL pagebreak(0)
     ENDIF
     dummy_val = fieldname036(rpt_render)
    WITH nullreport, nocounter, memsort
   ;end select
 END ;Subroutine
 SUBROUTINE (mainhtml(ndummy=i2) =null WITH protect)
  DECLARE rpt_pageofpage = vc WITH noconstant("Page 1 of 1"), protect
  SELECT
   IF (size(data->qual,5)=0)
    FROM (dummyt d  WITH seq = value(size(data->qual,5))),
     organization o
    PLAN (d
     WHERE d.seq > 0)
     JOIN (o
     WHERE o.organization_id=0
      AND o.organization_id != 0)
   ELSE
   ENDIF
   INTO "nl:"
   patient_name = substring(1,100,data->qual[d.seq].patient_name), patient_id = data->qual[d.seq].
   patient_id, patient_type_cd = data->qual[d.seq].patient_type_cd,
   disch_dt_tm = data->qual[d.seq].disch_dt_tm, los_days = data->qual[d.seq].los_days,
   tat_create_to_final = data->qual[d.seq].tat_create_to_final,
   tat_discharge_to_final = data->qual[d.seq].tat_discharge_to_final, mrn = substring(1,100,data->
    qual[d.seq].mrn), fin = substring(1,100,data->qual[d.seq].fin),
   user_name = substring(1,100,data->qual[d.seq].user_name), user_id = data->qual[d.seq].user_id,
   organization_name = substring(1,100,data->qual[d.seq].organization_name),
   organization_id = data->qual[d.seq].organization_id, task_queue_cd = data->qual[d.seq].
   task_queue_cd, patient_type_name = uar_get_code_display(cnvtreal(data->qual[d.seq].patient_type_cd
     )),
   encntr_id = data->qual[d.seq].encntr_id, task_queue_name = uar_get_code_display(cnvtreal(data->
     qual[d.seq].task_queue_cd)), person_abs_birth_dt_tm = data->qual[d.seq].person_abs_birth_dt_tm,
   person_active_ind = data->qual[d.seq].person_active_ind, person_active_status_cd = data->qual[d
   .seq].person_active_status_cd, person_active_status_dt_tm = data->qual[d.seq].
   person_active_status_dt_tm,
   person_active_status_prsnl_id = data->qual[d.seq].person_active_status_prsnl_id,
   person_archive_env_id = data->qual[d.seq].person_archive_env_id, person_archive_status_cd = data->
   qual[d.seq].person_archive_status_cd,
   person_archive_status_dt_tm = data->qual[d.seq].person_archive_status_dt_tm, person_autopsy_cd =
   data->qual[d.seq].person_autopsy_cd, person_beg_effective_dt_tm = data->qual[d.seq].
   person_beg_effective_dt_tm,
   person_birth_dt_cd = data->qual[d.seq].person_birth_dt_cd, person_birth_dt_tm = data->qual[d.seq].
   person_birth_dt_tm, person_birth_prec_flag = data->qual[d.seq].person_birth_prec_flag,
   person_birth_tz = data->qual[d.seq].person_birth_tz, person_cause_of_death = substring(1,100,data
    ->qual[d.seq].person_cause_of_death), person_cause_of_death_cd = data->qual[d.seq].
   person_cause_of_death_cd,
   person_citizenship_cd = data->qual[d.seq].person_citizenship_cd, person_conception_dt_tm = data->
   qual[d.seq].person_conception_dt_tm, person_confid_level_cd = data->qual[d.seq].
   person_confid_level_cd,
   person_contributor_system_cd = data->qual[d.seq].person_contributor_system_cd, person_create_dt_tm
    = data->qual[d.seq].person_create_dt_tm, person_create_prsnl_id = data->qual[d.seq].
   person_create_prsnl_id,
   person_data_status_cd = data->qual[d.seq].person_data_status_cd, person_data_status_dt_tm = data->
   qual[d.seq].person_data_status_dt_tm, person_data_status_prsnl_id = data->qual[d.seq].
   person_data_status_prsnl_id,
   person_deceased_cd = data->qual[d.seq].person_deceased_cd, person_deceased_dt_tm = data->qual[d
   .seq].person_deceased_dt_tm, person_deceased_source_cd = data->qual[d.seq].
   person_deceased_source_cd,
   person_end_effective_dt_tm = data->qual[d.seq].person_end_effective_dt_tm, person_ethnic_grp_cd =
   data->qual[d.seq].person_ethnic_grp_cd, person_ft_entity_id = data->qual[d.seq].
   person_ft_entity_id,
   person_ft_entity_name = substring(1,32,data->qual[d.seq].person_ft_entity_name),
   person_language_cd = data->qual[d.seq].person_language_cd, person_language_dialect_cd = data->
   qual[d.seq].person_language_dialect_cd,
   person_last_accessed_dt_tm = data->qual[d.seq].person_last_accessed_dt_tm,
   person_last_encntr_dt_tm = data->qual[d.seq].person_last_encntr_dt_tm, person_marital_type_cd =
   data->qual[d.seq].person_marital_type_cd,
   person_military_base_location = substring(1,100,data->qual[d.seq].person_military_base_location),
   person_military_rank_cd = data->qual[d.seq].person_military_rank_cd, person_military_service_cd =
   data->qual[d.seq].person_military_service_cd,
   person_mother_maiden_name = substring(1,100,data->qual[d.seq].person_mother_maiden_name),
   person_name_first = substring(1,200,data->qual[d.seq].person_name_first), person_name_first_key =
   substring(1,100,data->qual[d.seq].person_name_first_key),
   person_name_first_key_nls = substring(1,202,data->qual[d.seq].person_name_first_key_nls),
   person_name_first_phonetic = substring(1,8,data->qual[d.seq].person_name_first_phonetic),
   person_name_first_synonym_id = data->qual[d.seq].person_name_first_synonym_id,
   person_name_full_formatted = substring(1,100,data->qual[d.seq].person_name_full_formatted),
   person_name_last = substring(1,200,data->qual[d.seq].person_name_last), person_name_last_key =
   substring(1,100,data->qual[d.seq].person_name_last_key),
   person_name_last_key_nls = substring(1,202,data->qual[d.seq].person_name_last_key_nls),
   person_name_last_phonetic = substring(1,8,data->qual[d.seq].person_name_last_phonetic),
   person_name_middle = substring(1,200,data->qual[d.seq].person_name_middle),
   person_name_middle_key = substring(1,100,data->qual[d.seq].person_name_middle_key),
   person_name_middle_key_nls = substring(1,202,data->qual[d.seq].person_name_middle_key_nls),
   person_name_phonetic = substring(1,8,data->qual[d.seq].person_name_phonetic),
   person_nationality_cd = data->qual[d.seq].person_nationality_cd, person_next_restore_dt_tm = data
   ->qual[d.seq].person_next_restore_dt_tm, person_person_id = data->qual[d.seq].person_person_id,
   person_person_type_cd = data->qual[d.seq].person_person_type_cd, person_race_cd = data->qual[d.seq
   ].person_race_cd, person_religion_cd = data->qual[d.seq].person_religion_cd,
   person_sex_age_change_ind = data->qual[d.seq].person_sex_age_change_ind, person_sex_cd = data->
   qual[d.seq].person_sex_cd, person_species_cd = data->qual[d.seq].person_species_cd,
   person_updt_dt_tm = data->qual[d.seq].person_updt_dt_tm, person_updt_id = data->qual[d.seq].
   person_updt_id, person_updt_task = data->qual[d.seq].person_updt_task,
   person_vet_military_status_cd = data->qual[d.seq].person_vet_military_status_cd, person_vip_cd =
   data->qual[d.seq].person_vip_cd, org_active_ind = data->qual[d.seq].org_active_ind,
   org_active_status_cd = data->qual[d.seq].org_active_status_cd, org_active_status_dt_tm = data->
   qual[d.seq].org_active_status_dt_tm, org_active_status_prsnl_id = data->qual[d.seq].
   org_active_status_prsnl_id,
   org_beg_effective_dt_tm = data->qual[d.seq].org_beg_effective_dt_tm, org_contributor_source_cd =
   data->qual[d.seq].org_contributor_source_cd, org_contributor_system_cd = data->qual[d.seq].
   org_contributor_system_cd,
   org_data_status_cd = data->qual[d.seq].org_data_status_cd, org_data_status_dt_tm = data->qual[d
   .seq].org_data_status_dt_tm, org_data_status_prsnl_id = data->qual[d.seq].org_data_status_prsnl_id,
   org_end_effective_dt_tm = data->qual[d.seq].org_end_effective_dt_tm, org_federal_tax_id_nbr =
   substring(1,100,data->qual[d.seq].org_federal_tax_id_nbr), org_ft_entity_id = data->qual[d.seq].
   org_ft_entity_id,
   org_ft_entity_name = substring(1,32,data->qual[d.seq].org_ft_entity_name), org_organization_id =
   data->qual[d.seq].org_organization_id, org_org_class_cd = data->qual[d.seq].org_org_class_cd,
   org_org_name = substring(1,100,data->qual[d.seq].org_org_name), org_org_name_key = substring(1,100,
    data->qual[d.seq].org_org_name_key), org_org_name_key_nls = substring(1,202,data->qual[d.seq].
    org_org_name_key_nls),
   org_org_status_cd = data->qual[d.seq].org_org_status_cd, org_updt_dt_tm = data->qual[d.seq].
   org_updt_dt_tm, org_updt_id = data->qual[d.seq].org_updt_id,
   org_updt_task = data->qual[d.seq].org_updt_task, encntr_accommodation_cd = data->qual[d.seq].
   encntr_accommodation_cd, encntr_accommodation_reason_cd = data->qual[d.seq].
   encntr_accommodation_reason_cd,
   encntr_accommodation_request_cd = data->qual[d.seq].encntr_accommodation_request_cd,
   encntr_accomp_by_cd = data->qual[d.seq].encntr_accomp_by_cd, encntr_active_ind = data->qual[d.seq]
   .encntr_active_ind,
   encntr_active_status_cd = data->qual[d.seq].encntr_active_status_cd, encntr_active_status_dt_tm =
   data->qual[d.seq].encntr_active_status_dt_tm, encntr_active_status_prsnl_id = data->qual[d.seq].
   encntr_active_status_prsnl_id,
   encntr_admit_mode_cd = data->qual[d.seq].encntr_admit_mode_cd, encntr_admit_src_cd = data->qual[d
   .seq].encntr_admit_src_cd, encntr_admit_type_cd = data->qual[d.seq].encntr_admit_type_cd,
   encntr_admit_with_medication_cd = data->qual[d.seq].encntr_admit_with_medication_cd,
   encntr_alc_decomp_dt_tm = data->qual[d.seq].encntr_alc_decomp_dt_tm, encntr_alc_reason_cd = data->
   qual[d.seq].encntr_alc_reason_cd,
   encntr_alt_lvl_care_cd = data->qual[d.seq].encntr_alt_lvl_care_cd, encntr_alt_lvl_care_dt_tm =
   data->qual[d.seq].encntr_alt_lvl_care_dt_tm, encntr_ambulatory_cond_cd = data->qual[d.seq].
   encntr_ambulatory_cond_cd,
   encntr_archive_dt_tm_act = data->qual[d.seq].encntr_archive_dt_tm_act, encntr_archive_dt_tm_est =
   data->qual[d.seq].encntr_archive_dt_tm_est, encntr_arrive_dt_tm = data->qual[d.seq].
   encntr_arrive_dt_tm,
   encntr_assign_to_loc_dt_tm = data->qual[d.seq].encntr_assign_to_loc_dt_tm, encntr_bbd_procedure_cd
    = data->qual[d.seq].encntr_bbd_procedure_cd, encntr_beg_effective_dt_tm = data->qual[d.seq].
   encntr_beg_effective_dt_tm,
   encntr_chart_complete_dt_tm = data->qual[d.seq].encntr_chart_complete_dt_tm,
   encntr_confid_level_cd = data->qual[d.seq].encntr_confid_level_cd, encntr_contract_status_cd =
   data->qual[d.seq].encntr_contract_status_cd,
   encntr_contributor_system_cd = data->qual[d.seq].encntr_contributor_system_cd, encntr_courtesy_cd
    = data->qual[d.seq].encntr_courtesy_cd, encntr_create_dt_tm = data->qual[d.seq].
   encntr_create_dt_tm,
   encntr_create_prsnl_id = data->qual[d.seq].encntr_create_prsnl_id, encntr_data_status_cd = data->
   qual[d.seq].encntr_data_status_cd, encntr_data_status_dt_tm = data->qual[d.seq].
   encntr_data_status_dt_tm,
   encntr_data_status_prsnl_id = data->qual[d.seq].encntr_data_status_prsnl_id, encntr_depart_dt_tm
    = data->qual[d.seq].encntr_depart_dt_tm, encntr_diet_type_cd = data->qual[d.seq].
   encntr_diet_type_cd,
   encntr_disch_disposition_cd = data->qual[d.seq].encntr_disch_disposition_cd, encntr_disch_dt_tm =
   data->qual[d.seq].encntr_disch_dt_tm, encntr_disch_to_loctn_cd = data->qual[d.seq].
   encntr_disch_to_loctn_cd,
   encntr_doc_rcvd_dt_tm = data->qual[d.seq].encntr_doc_rcvd_dt_tm, encntr_encntr_class_cd = data->
   qual[d.seq].encntr_encntr_class_cd, encntr_encntr_complete_dt_tm = data->qual[d.seq].
   encntr_encntr_complete_dt_tm,
   encntr_encntr_financial_id = data->qual[d.seq].encntr_encntr_financial_id, encntr_encntr_id = data
   ->qual[d.seq].encntr_encntr_id, encntr_encntr_status_cd = data->qual[d.seq].
   encntr_encntr_status_cd,
   encntr_encntr_type_cd = data->qual[d.seq].encntr_encntr_type_cd, encntr_encntr_type_class_cd =
   data->qual[d.seq].encntr_encntr_type_class_cd, encntr_end_effective_dt_tm = data->qual[d.seq].
   encntr_end_effective_dt_tm,
   encntr_est_arrive_dt_tm = data->qual[d.seq].encntr_est_arrive_dt_tm, encntr_est_depart_dt_tm =
   data->qual[d.seq].encntr_est_depart_dt_tm, encntr_est_length_of_stay = data->qual[d.seq].
   encntr_est_length_of_stay,
   encntr_financial_class_cd = data->qual[d.seq].encntr_financial_class_cd, encntr_guarantor_type_cd
    = data->qual[d.seq].encntr_guarantor_type_cd, encntr_info_given_by = substring(1,100,data->qual[d
    .seq].encntr_info_given_by),
   encntr_inpatient_admit_dt_tm = data->qual[d.seq].encntr_inpatient_admit_dt_tm, encntr_isolation_cd
    = data->qual[d.seq].encntr_isolation_cd, encntr_location_cd = data->qual[d.seq].
   encntr_location_cd,
   encntr_loc_bed_cd = data->qual[d.seq].encntr_loc_bed_cd, encntr_loc_building_cd = data->qual[d.seq
   ].encntr_loc_building_cd, encntr_loc_facility_cd = data->qual[d.seq].encntr_loc_facility_cd,
   encntr_loc_nurse_unit_cd = data->qual[d.seq].encntr_loc_nurse_unit_cd, encntr_loc_room_cd = data->
   qual[d.seq].encntr_loc_room_cd, encntr_loc_temp_cd = data->qual[d.seq].encntr_loc_temp_cd,
   encntr_med_service_cd = data->qual[d.seq].encntr_med_service_cd, encntr_mental_category_cd = data
   ->qual[d.seq].encntr_mental_category_cd, encntr_mental_health_dt_tm = data->qual[d.seq].
   encntr_mental_health_dt_tm,
   encntr_organization_id = data->qual[d.seq].encntr_organization_id, encntr_parent_ret_criteria_id
    = data->qual[d.seq].encntr_parent_ret_criteria_id, encntr_patient_classification_cd = data->qual[
   d.seq].encntr_patient_classification_cd,
   encntr_pa_current_status_cd = data->qual[d.seq].encntr_pa_current_status_cd,
   encntr_pa_current_status_dt_tm = data->qual[d.seq].encntr_pa_current_status_dt_tm,
   encntr_person_id = data->qual[d.seq].encntr_person_id,
   encntr_placement_auth_prsnl_id = data->qual[d.seq].encntr_placement_auth_prsnl_id,
   encntr_preadmit_testing_cd = data->qual[d.seq].encntr_preadmit_testing_cd, encntr_pre_reg_dt_tm =
   data->qual[d.seq].encntr_pre_reg_dt_tm,
   encntr_pre_reg_prsnl_id = data->qual[d.seq].encntr_pre_reg_prsnl_id, encntr_program_service_cd =
   data->qual[d.seq].encntr_program_service_cd, encntr_psychiatric_status_cd = data->qual[d.seq].
   encntr_psychiatric_status_cd,
   encntr_purge_dt_tm_act = data->qual[d.seq].encntr_purge_dt_tm_act, encntr_purge_dt_tm_est = data->
   qual[d.seq].encntr_purge_dt_tm_est, encntr_readmit_cd = data->qual[d.seq].encntr_readmit_cd,
   encntr_reason_for_visit = substring(1,255,data->qual[d.seq].encntr_reason_for_visit),
   encntr_referral_rcvd_dt_tm = data->qual[d.seq].encntr_referral_rcvd_dt_tm,
   encntr_referring_comment = substring(1,100,data->qual[d.seq].encntr_referring_comment),
   encntr_refer_facility_cd = data->qual[d.seq].encntr_refer_facility_cd, encntr_region_cd = data->
   qual[d.seq].encntr_region_cd, encntr_reg_dt_tm = data->qual[d.seq].encntr_reg_dt_tm,
   encntr_reg_prsnl_id = data->qual[d.seq].encntr_reg_prsnl_id, encntr_result_accumulation_dt_tm =
   data->qual[d.seq].encntr_result_accumulation_dt_tm, encntr_safekeeping_cd = data->qual[d.seq].
   encntr_safekeeping_cd,
   encntr_security_access_cd = data->qual[d.seq].encntr_security_access_cd,
   encntr_service_category_cd = data->qual[d.seq].encntr_service_category_cd,
   encntr_sitter_required_cd = data->qual[d.seq].encntr_sitter_required_cd,
   encntr_specialty_unit_cd = data->qual[d.seq].encntr_specialty_unit_cd, encntr_trauma_cd = data->
   qual[d.seq].encntr_trauma_cd, encntr_trauma_dt_tm = data->qual[d.seq].encntr_trauma_dt_tm,
   encntr_triage_cd = data->qual[d.seq].encntr_triage_cd, encntr_triage_dt_tm = data->qual[d.seq].
   encntr_triage_dt_tm, encntr_updt_dt_tm = data->qual[d.seq].encntr_updt_dt_tm,
   encntr_updt_id = data->qual[d.seq].encntr_updt_id, encntr_updt_task = data->qual[d.seq].
   encntr_updt_task, encntr_valuables_cd = data->qual[d.seq].encntr_valuables_cd,
   encntr_vip_cd = data->qual[d.seq].encntr_vip_cd, encntr_visitor_status_cd = data->qual[d.seq].
   encntr_visitor_status_cd, encntr_zero_balance_dt_tm = data->qual[d.seq].encntr_zero_balance_dt_tm,
   encntr_mrn_active_ind = data->qual[d.seq].encntr_mrn_active_ind, encntr_mrn_active_status_cd =
   data->qual[d.seq].encntr_mrn_active_status_cd, encntr_mrn_active_status_dt_tm = data->qual[d.seq].
   encntr_mrn_active_status_dt_tm,
   encntr_mrn_active_status_prsnl_id = data->qual[d.seq].encntr_mrn_active_status_prsnl_id,
   encntr_mrn_alias = substring(1,200,data->qual[d.seq].encntr_mrn_alias), encntr_mrn_alias_pool_cd
    = data->qual[d.seq].encntr_mrn_alias_pool_cd,
   encntr_mrn_assign_authority_sys_cd = data->qual[d.seq].encntr_mrn_assign_authority_sys_cd,
   encntr_mrn_beg_effective_dt_tm = data->qual[d.seq].encntr_mrn_beg_effective_dt_tm,
   encntr_mrn_check_digit = data->qual[d.seq].encntr_mrn_check_digit,
   encntr_mrn_check_digit_method_cd = data->qual[d.seq].encntr_mrn_check_digit_method_cd,
   encntr_mrn_contributor_system_cd = data->qual[d.seq].encntr_mrn_contributor_system_cd,
   encntr_mrn_data_status_cd = data->qual[d.seq].encntr_mrn_data_status_cd,
   encntr_mrn_data_status_dt_tm = data->qual[d.seq].encntr_mrn_data_status_dt_tm,
   encntr_mrn_data_status_prsnl_id = data->qual[d.seq].encntr_mrn_data_status_prsnl_id,
   encntr_mrn_encntr_alias_id = data->qual[d.seq].encntr_mrn_encntr_alias_id,
   encntr_mrn_encntr_alias_type_cd = data->qual[d.seq].encntr_mrn_encntr_alias_type_cd,
   encntr_mrn_encntr_id = data->qual[d.seq].encntr_mrn_encntr_id, encntr_mrn_end_effective_dt_tm =
   data->qual[d.seq].encntr_mrn_end_effective_dt_tm,
   encntr_mrn_updt_dt_tm = data->qual[d.seq].encntr_mrn_updt_dt_tm, encntr_mrn_updt_id = data->qual[d
   .seq].encntr_mrn_updt_id, encntr_mrn_updt_task = data->qual[d.seq].encntr_mrn_updt_task,
   encntr_fin_active_ind = data->qual[d.seq].encntr_fin_active_ind, encntr_fin_active_status_cd =
   data->qual[d.seq].encntr_fin_active_status_cd, encntr_fin_active_status_dt_tm = data->qual[d.seq].
   encntr_fin_active_status_dt_tm,
   encntr_fin_active_status_prsnl_id = data->qual[d.seq].encntr_fin_active_status_prsnl_id,
   encntr_fin_alias = substring(1,200,data->qual[d.seq].encntr_fin_alias), encntr_fin_alias_pool_cd
    = data->qual[d.seq].encntr_fin_alias_pool_cd,
   encntr_fin_assign_authority_sys_cd = data->qual[d.seq].encntr_fin_assign_authority_sys_cd,
   encntr_fin_beg_effective_dt_tm = data->qual[d.seq].encntr_fin_beg_effective_dt_tm,
   encntr_fin_check_digit = data->qual[d.seq].encntr_fin_check_digit,
   encntr_fin_check_digit_method_cd = data->qual[d.seq].encntr_fin_check_digit_method_cd,
   encntr_fin_contributor_system_cd = data->qual[d.seq].encntr_fin_contributor_system_cd,
   encntr_fin_data_status_cd = data->qual[d.seq].encntr_fin_data_status_cd,
   encntr_fin_data_status_dt_tm = data->qual[d.seq].encntr_fin_data_status_dt_tm,
   encntr_fin_data_status_prsnl_id = data->qual[d.seq].encntr_fin_data_status_prsnl_id,
   encntr_fin_encntr_alias_id = data->qual[d.seq].encntr_fin_encntr_alias_id,
   encntr_fin_encntr_alias_type_cd = data->qual[d.seq].encntr_fin_encntr_alias_type_cd,
   encntr_fin_encntr_id = data->qual[d.seq].encntr_fin_encntr_id, encntr_fin_end_effective_dt_tm =
   data->qual[d.seq].encntr_fin_end_effective_dt_tm,
   encntr_fin_updt_dt_tm = data->qual[d.seq].encntr_fin_updt_dt_tm, encntr_fin_updt_id = data->qual[d
   .seq].encntr_fin_updt_id, encntr_fin_updt_task = data->qual[d.seq].encntr_fin_updt_task,
   user_active_ind = data->qual[d.seq].user_active_ind, user_active_status_cd = data->qual[d.seq].
   user_active_status_cd, user_active_status_dt_tm = data->qual[d.seq].user_active_status_dt_tm,
   user_active_status_prsnl_id = data->qual[d.seq].user_active_status_prsnl_id,
   user_beg_effective_dt_tm = data->qual[d.seq].user_beg_effective_dt_tm, user_contributor_system_cd
    = data->qual[d.seq].user_contributor_system_cd,
   user_create_dt_tm = data->qual[d.seq].user_create_dt_tm, user_create_prsnl_id = data->qual[d.seq].
   user_create_prsnl_id, user_data_status_cd = data->qual[d.seq].user_data_status_cd,
   user_data_status_dt_tm = data->qual[d.seq].user_data_status_dt_tm, user_data_status_prsnl_id =
   data->qual[d.seq].user_data_status_prsnl_id, user_email = substring(1,100,data->qual[d.seq].
    user_email),
   user_end_effective_dt_tm = data->qual[d.seq].user_end_effective_dt_tm, user_ft_entity_id = data->
   qual[d.seq].user_ft_entity_id, user_ft_entity_name = substring(1,32,data->qual[d.seq].
    user_ft_entity_name),
   user_name_first = substring(1,200,data->qual[d.seq].user_name_first), user_name_first_key =
   substring(1,100,data->qual[d.seq].user_name_first_key), user_name_first_key_nls = substring(1,202,
    data->qual[d.seq].user_name_first_key_nls),
   user_name_full_formatted = substring(1,100,data->qual[d.seq].user_name_full_formatted),
   user_name_last = substring(1,200,data->qual[d.seq].user_name_last), user_name_last_key = substring
   (1,100,data->qual[d.seq].user_name_last_key),
   user_name_last_key_nls = substring(1,202,data->qual[d.seq].user_name_last_key_nls), user_password
    = substring(1,100,data->qual[d.seq].user_password), user_person_id = data->qual[d.seq].
   user_person_id,
   user_physician_ind = data->qual[d.seq].user_physician_ind, user_physician_status_cd = data->qual[d
   .seq].user_physician_status_cd, user_position_cd = data->qual[d.seq].user_position_cd,
   user_prim_assign_loc_cd = data->qual[d.seq].user_prim_assign_loc_cd, user_prsnl_type_cd = data->
   qual[d.seq].user_prsnl_type_cd, user_updt_dt_tm = data->qual[d.seq].user_updt_dt_tm,
   user_updt_id = data->qual[d.seq].user_updt_id, user_updt_task = data->qual[d.seq].user_updt_task,
   user_username = substring(1,50,data->qual[d.seq].user_username),
   task_hist_active_ind = data->qual[d.seq].task_hist_active_ind, task_hist_active_status_cd = data->
   qual[d.seq].task_hist_active_status_cd, task_hist_active_status_dt_tm = data->qual[d.seq].
   task_hist_active_status_dt_tm,
   task_hist_active_status_prsnl_id = data->qual[d.seq].task_hist_active_status_prsnl_id,
   task_hist_beg_effective_dt_tm = data->qual[d.seq].task_hist_beg_effective_dt_tm,
   task_hist_encntr_id = data->qual[d.seq].task_hist_encntr_id,
   task_hist_end_effective_dt_tm = data->qual[d.seq].task_hist_end_effective_dt_tm,
   task_hist_location_cd = data->qual[d.seq].task_hist_location_cd, task_hist_person_id = data->qual[
   d.seq].task_hist_person_id,
   task_hist_task_activity_history_id = data->qual[d.seq].task_hist_task_activity_history_id,
   task_hist_task_class_cd = data->qual[d.seq].task_hist_task_class_cd,
   task_hist_task_completed_dt_tm = data->qual[d.seq].task_hist_task_completed_dt_tm,
   task_hist_task_completed_prsnl_id = data->qual[d.seq].task_hist_task_completed_prsnl_id,
   task_hist_task_create_dt_tm = data->qual[d.seq].task_hist_task_create_dt_tm, task_hist_task_dt_tm
    = data->qual[d.seq].task_hist_task_dt_tm,
   task_hist_task_id = data->qual[d.seq].task_hist_task_id, task_hist_task_status_cd = data->qual[d
   .seq].task_hist_task_status_cd, task_hist_task_type_cd = data->qual[d.seq].task_hist_task_type_cd,
   task_hist_updt_dt_tm = data->qual[d.seq].task_hist_updt_dt_tm, task_hist_updt_id = data->qual[d
   .seq].task_hist_updt_id, task_hist_updt_task = data->qual[d.seq].task_hist_updt_task
   FROM (dummyt d  WITH seq = value(size(data->qual,5)))
   WHERE d.seq > 0
   ORDER BY user_name, user_id, task_queue_name,
    task_queue_cd, patient_type_name, patient_type_cd
   HEAD REPORT
    _d0 = los_days, _d1 = tat_create_to_final, _d2 = tat_discharge_to_final,
    _d3 = fin, _d4 = user_name, _d5 = task_queue_name,
    _d6 = user_username, _htmlfileinfo->file_buf = build2("<STYLE>",
     "table {border-collapse: collapse; empty-cells: show;  border: 0.000in none #000000;  }",
     ".FieldName000 { border-width: 0.014in; border-color: #000000;",
     " border-style: none none none none;"," padding: 0.000in 0.000in 0.000in 0.000in;",
     " font: italic bold 10pt Times;"," "," color: #ff0000;"," background: #ffffff;",
     " text-align: left;",
     " vertical-align: bottom;}",".FieldName010 { border-width: 0.014in; border-color: #000000;",
     " border-style: solid solid none solid;"," padding: 0.000in 0.000in 0.000in 0.000in;",
     " font: italic bold 12pt Times;",
     " "," color: #0000a0;"," "," text-align: center;"," vertical-align: bottom;}",
     ".FieldName020 { border-width: 0.014in; border-color: #000000;",
     " border-style: none solid none solid;"," padding: 0.000in 0.000in 0.000in 0.000in;",
     " font: italic bold 12pt Times;"," ",
     " color: #0000a0;"," "," text-align: center;"," vertical-align: middle;}",
     ".FieldName030 { border-width: 0.014in; border-color: #000000;",
     " border-style: none solid solid solid;"," padding: 0.000in 0.000in 0.000in 0.000in;",
     " font:  bold 12pt Times;"," "," color: #7e7e7e;",
     " "," text-align: center;"," vertical-align: middle;}",
     ".FieldName040 { border-width: 0.014in; border-color: #000000;",
     " border-style: none none none none;",
     " padding: 0.000in 0.000in 0.000in 0.000in;"," font:   10pt Times;"," "," color: #000000;"," ",
     " text-align: left;"," vertical-align: top;}",
     ".FieldName050 { border-width: 0.014in; border-color: #000000;",
     " border-style: none none none none;"," padding: 0.000in 0.000in 0.000in 0.000in;",
     " font:  bold 10pt Times;"," "," color: #000000;"," "," text-align: left;",
     " vertical-align: middle;}",".FieldName051 { border-width: 0.014in; border-color: #000000;",
     " border-style: none none none none;"," padding: 0.000in 0.000in 0.000in 0.000in;",
     " font:   10pt Times;",
     " "," color: #000000;"," "," text-align: left;"," vertical-align: middle;}",
     ".FieldName071 { border-width: 0.014in; border-color: #000000;",
     " border-style: none none none none;"," padding: 0.000in 0.000in 0.000in 0.000in;",
     " font:   10pt Times;"," ",
     " color: #000000;"," "," text-align: left;"," vertical-align: middle;}",
     ".FieldName082 { border-width: 0.014in; border-color: #000000;",
     " border-style: none none none none;"," padding: 0.000in 0.000in 0.000in 0.000in;",
     " font:   10pt Times;"," "," color: #000000;",
     " "," text-align: left;"," vertical-align: middle;}",
     ".FieldName0120 { border-width: 0.014in; border-color: #000000;",
     " border-style: none none none none;",
     " padding: 0.000in 0.000in 0.000in 0.000in;"," font:  bold 10pt Times;"," "," color: #000000;",
     " ",
     " text-align: right;"," vertical-align: top;}",
     ".FieldName0130 { border-width: 0.014in; border-color: #000000;",
     " border-style: none none none none;"," padding: 0.000in 0.000in 0.000in 0.000in;",
     " font:  bold 10pt Times;"," "," color: #000000;"," "," text-align: left;",
     " vertical-align: bottom;}",".FieldName0131 { border-width: 0.014in; border-color: #000000;",
     " border-style: none none none none;"," padding: 0.000in 0.000in 0.000in 0.000in;",
     " font:  bold 10pt Times;",
     " "," color: #000000;"," "," text-align: right;"," vertical-align: bottom;}",
     ".FieldName0140 { border-width: 0.014in; border-color: #000000;",
     " border-style: none none solid none;"," padding: 0.000in 0.000in 0.000in 0.000in;",
     " font:  bold 10pt Times;"," ",
     " color: #000000;"," "," text-align: left;"," vertical-align: bottom;}",
     ".FieldName0141 { border-width: 0.014in; border-color: #000000;",
     " border-style: none none solid none;"," padding: 0.000in 0.000in 0.000in 0.000in;",
     " font:  bold 10pt Times;"," "," color: #000000;",
     " "," text-align: right;"," vertical-align: bottom;}",
     ".FieldName0142 { border-width: 0.014in; border-color: #000000;",
     " border-style: none none solid none;",
     " padding: 0.000in 0.000in 0.000in 0.000in;"," font:  bold 10pt Times;"," "," color: #000000;",
     " ",
     " text-align: right;"," vertical-align: bottom;}",
     ".FieldName0144 { border-width: 0.014in; border-color: #000000;",
     " border-style: none none solid none;"," padding: 0.000in 0.000in 0.000in 0.100in;",
     " font:  bold 10pt Times;"," "," color: #000000;"," "," text-align: right;",
     " vertical-align: bottom;}",".FieldName0145 { border-width: 0.014in; border-color: #000000;",
     " border-style: none none solid none;"," padding: 0.000in 0.000in 0.000in 0.000in;",
     " font:  bold 10pt Times;",
     " "," color: #000000;"," "," text-align: right;"," vertical-align: bottom;}",
     ".FieldName0170 { border-width: 0.014in; border-color: #000000;",
     " border-style: none none none none;"," padding: 0.000in 0.000in 0.000in 0.100in;",
     " font:  bold 10pt Times;"," ",
     " color: #000000;"," "," text-align: left;"," vertical-align: middle;}",
     ".FieldName0220 { border-width: 0.014in; border-color: #000000;",
     " border-style: none none none none;"," padding: 0.000in 0.000in 0.000in 0.000in;",
     " font:   10pt Times;"," "," color: #000000;",
     " "," text-align: left;"," vertical-align: bottom;}",
     ".FieldName0230 { border-width: 0.014in; border-color: #000000;",
     " border-style: none none none none;",
     " padding: 0.000in 0.000in 0.000in 0.000in;"," font:   10pt Times;"," "," color: #000000;"," ",
     " text-align: left;"," vertical-align: middle;}",
     ".FieldName0232 { border-width: 0.014in; border-color: #000000;",
     " border-style: none none none none;"," padding: 0.000in 0.000in 0.000in 0.000in;",
     " font:   10pt Times;"," "," color: #000000;"," "," text-align: right;",
     " vertical-align: middle;}",".FieldName0235 { border-width: 0.014in; border-color: #000000;",
     " border-style: none none none none;"," padding: 0.000in 0.000in 0.000in 0.100in;",
     " font:   10pt Times;",
     " "," color: #000000;"," "," text-align: right;"," vertical-align: middle;}",
     ".FieldName0240 { border-width: 0.014in; border-color: #000000;",
     " border-style: none none none none;"," padding: 0.000in 0.000in 0.000in 0.000in;",
     " font:   10pt Times;"," ",
     " color: #000000;"," background: #e8e8e8;"," text-align: left;"," vertical-align: middle;}",
     ".FieldName0242 { border-width: 0.014in; border-color: #000000;",
     " border-style: none none none none;"," padding: 0.000in 0.000in 0.000in 0.000in;",
     " font:   10pt Times;"," "," color: #000000;",
     " background: #e8e8e8;"," text-align: right;"," vertical-align: middle;}",
     ".FieldName0245 { border-width: 0.014in; border-color: #000000;",
     " border-style: none none none none;",
     " padding: 0.000in 0.000in 0.000in 0.100in;"," font:   10pt Times;"," "," color: #000000;",
     " background: #e8e8e8;",
     " text-align: right;"," vertical-align: middle;}",
     ".FieldName0250 { border-width: 0.014in; border-color: #000000;",
     " border-style: none none none none;"," padding: 0.000in 0.000in 0.000in 0.200in;",
     " font:  bold 10pt Times;"," "," color: #000000;"," background: #ffffff;"," text-align: right;",
     " vertical-align: middle;}",".FieldName0260 { border-width: 0.014in; border-color: #000000;",
     " border-style: none none none none;"," padding: 0.000in 0.000in 0.000in 0.000in;",
     " font:  bold 10pt Times;",
     " "," color: #000000;"," background: #ffff80;"," text-align: left;"," vertical-align: middle;}",
     ".FieldName0270 { border-width: 0.014in; border-color: #000000;",
     " border-style: none none none none;"," padding: 0.000in 0.000in 0.000in 0.200in;",
     " font:  bold 10pt Times;"," ",
     " color: #000000;"," background: #ffff80;"," text-align: left;"," vertical-align: middle;}",
     ".FieldName0271 { border-width: 0.014in; border-color: #000000;",
     " border-style: none none none none;"," padding: 0.000in 0.000in 0.000in 0.000in;",
     " font:   10pt Times;"," "," color: #000000;",
     " background: #ffff80;"," text-align: right;"," vertical-align: middle;}",
     ".FieldName0272 { border-width: 0.014in; border-color: #000000;",
     " border-style: none none none none;",
     " padding: 0.000in 0.000in 0.000in 0.000in;"," font:   10pt Times;"," "," color: #000000;",
     " background: #ffff80;",
     " text-align: left;"," vertical-align: middle;}",
     ".FieldName0360 { border-width: 0.025in; border-color: #000000;",
     " border-style: none none none none;"," padding: 0.000in 0.000in 0.000in 0.000in;",
     " font:  bold 10pt Times;"," "," color: #000000;"," "," text-align: center;",
     " vertical-align: middle;}","</STYLE>"), _htmlfilestat = cclio("WRITE",_htmlfileinfo),
    _htmlfileinfo->file_buf = "<table width='100%'><caption>", _htmlfilestat = cclio("WRITE",
     _htmlfileinfo), _htmlfileinfo->file_buf = build2("<colgroup span=10>","<col width=102/>",
     "<col width=48/>","<col width=25/>","<col width=75/>",
     "<col width=38/>","<col width=112/>","<col width=25/>","<col width=163/>","<col width=212/>",
     "<col width=184/>","</colgroup>"),
    _htmlfilestat = cclio("WRITE",_htmlfileinfo), daterange = getdaterangedisplay(dates,him_dash),
    totalchartsperorganization = 0,
    totaltatperorganization = 0, avgtatperorganization = 0, totaltattaskperorganization = 0,
    avgtattaskperorganization = 0, totalchartsperuser = 0, totaltatperuser = 0,
    avgtatperuser = 0, totaltattaskperuser = 0, avgtattaskperuser = 0,
    totalchartsperqueue = 0, totallengthofstayperqueue = 0, avglengthofstayperqueue = 0,
    totaltatperqueue = 0, avgtatperqueue = 0, totaltattaskperqueue = 0,
    avgtattaskperqueue = 0, detailcount = 0, rowcount = 0,
    dataqualcount = size(data->qual,5), blank = "", allfacilities = uar_i18ngetmessage(i18nhandlehim,
     "ALLFACILITIES","All Facilities"),
    facilitylist = makelistofqualitemnames(organizations,allfacilities), allusers =
    uar_i18ngetmessage(i18nhandlehim,"ALLUSERS","All Users"), userlist = makelistofqualitemnames(
     users,allusers),
    alltaskqueues = uar_i18ngetmessage(i18nhandlehim,"ALLTASKQUEUES","All Task Queues"),
    taskqueuelist = makelistofqualitemnames(task_queues,alltaskqueues), _htmlfileinfo->file_buf =
    "<thead>",
    _htmlfilestat = cclio("WRITE",_htmlfileinfo), dummy_val = fieldname00html(0), dummy_val =
    fieldname01html(0),
    dummy_val = fieldname02html(0), dummy_val = fieldname03html(0), dummy_val = fieldname04html(0),
    dummy_val = fieldname05html(0), dummy_val = fieldname06html(0), dummy_val = fieldname07html(0),
    dummy_val = fieldname08html(0), dummy_val = fieldname09html(0), dummy_val = fieldname010html(0),
    dummy_val = fieldname011html(0), dummy_val = fieldname012html(0), dummy_val = fieldname013html(0),
    dummy_val = fieldname014html(0), _htmlfileinfo->file_buf = "</thead>", _htmlfilestat = cclio(
     "WRITE",_htmlfileinfo),
    _htmlfileinfo->file_buf = "<tbody>", _htmlfilestat = cclio("WRITE",_htmlfileinfo)
   HEAD user_name
    usernamehead = "", totalchartsperuser = 0, totaltatperuser = 0,
    avgtatperuser = 0, totaltattaskperuser = 0, avgtattaskperuser = 0,
    dummy_val = fieldname016html(0)
   HEAD user_id
    dummy_val = fieldname017html(0), dummy_val = fieldname018html(0), dummy_val = fieldname019html(0)
   HEAD task_queue_name
    dummy_val = fieldname020html(0)
   HEAD task_queue_cd
    taskqueuehead = "", totalchartsperqueue = 0, totallengthofstayperqueue = 0,
    avglengthofstayperqueue = 0, totaltatperqueue = 0, avgtatperqueue = 0,
    totaltattaskperqueue = 0, avgtattaskperqueue = 0, rowcount = 0,
    dummy_val = fieldname021html(0)
   DETAIL
    detailblankrow = "", totalchartsperorganization += 1, totaltatperorganization +=
    tat_discharge_to_final,
    totaltattaskperorganization += tat_create_to_final, totalchartsperuser += 1, totaltatperuser +=
    tat_discharge_to_final,
    totaltattaskperuser += tat_create_to_final, totalchartsperqueue += 1, totallengthofstayperqueue
     += los_days,
    totaltatperqueue += tat_discharge_to_final, totaltattaskperqueue += tat_create_to_final,
    detailcount += 1,
    dummy_val = fieldname022html(0)
   FOOT  task_queue_cd
    usernamerowone = user_name, rowcount += 1, totalchartsrowone = build(totalchartsperqueue),
    avglosdisplayrowone = trim(build(los_days),3), usernamerowtwo = user_name, totalchartsrowtwo =
    build(totalchartsperqueue),
    avglosdisplayrowtwo = trim(build(los_days),3), dummy_val = fieldname023html(0), dummy_val =
    fieldname024html(0)
   FOOT  user_id
    totalchartsperuserdisplay = build(totalchartsperuser)
    IF (totalchartsperuser > 0)
     avgtatperuserdisplay = build(cnvtminstodayshoursmins((totaltatperuser/ totalchartsperuser)))
    ELSE
     avgtatperuserdisplay = build(cnvtminstodayshoursmins(0))
    ENDIF
    IF (totalchartsperuser > 0)
     avgtattaskperuserdisplay = build(cnvtminstodayshoursmins((totaltattaskperuser/
       totalchartsperuser)))
    ELSE
     avgtattaskperuserdisplay = build(cnvtminstodayshoursmins(0))
    ENDIF
    dummy_val = fieldname025html(0), dummy_val = fieldname026html(0), dummy_val = fieldname027html(0),
    dummy_val = fieldname028html(0), dummy_val = fieldname029html(0), dummy_val = fieldname030html(0)
   FOOT REPORT
    _htmlfileinfo->file_buf = "</tbody>", _htmlfilestat = cclio("WRITE",_htmlfileinfo), _htmlfileinfo
    ->file_buf = "<tfoot>",
    _htmlfilestat = cclio("WRITE",_htmlfileinfo), dummy_val = fieldname036html(0), _htmlfileinfo->
    file_buf = "</tfoot>",
    _htmlfilestat = cclio("WRITE",_htmlfileinfo), _htmlfileinfo->file_buf = "</table>", _htmlfilestat
     = cclio("WRITE",_htmlfileinfo)
   WITH nullreport, nocounter, memsort
  ;end select
 END ;Subroutine
 SUBROUTINE pagebreak(dummy)
   SET _rptpage = uar_rptendpage(_hreport)
   SET _rptpage = uar_rptstartpage(_hreport)
   SET _yoffset = rptreport->m_margintop
 END ;Subroutine
 SUBROUTINE (finalizereport(ssendreport=vc) =null WITH protect)
   IF (_bsubreport=0)
    IF (_htmlfileinfo->file_desc)
     SET _htmlfileinfo->file_buf = "</html>"
     SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
     SET _htmlfilestat = cclio("CLOSE",_htmlfileinfo)
    ELSE
     SET _rptpage = uar_rptendpage(_hreport)
     SET _rptstat = uar_rptendreport(_hreport)
     DECLARE sfilename = vc WITH noconstant(trim(ssendreport)), private
     DECLARE bprint = i2 WITH noconstant(0), private
     IF (textlen(sfilename) > 0)
      SET bprint = checkqueue(sfilename)
      IF (bprint)
       EXECUTE cpm_create_file_name "RPT", "PS"
       SET sfilename = cpm_cfn_info->file_name_path
      ENDIF
     ENDIF
     SET _rptstat = uar_rptprinttofile(_hreport,nullterm(sfilename))
     IF (bprint)
      SET spool value(sfilename) value(ssendreport) WITH deleted
     ENDIF
     DECLARE _errorfound = i2 WITH noconstant(0), protect
     DECLARE _errcnt = i2 WITH noconstant(0), protect
     SET _errorfound = uar_rptfirsterror(_hreport,rpterror)
     WHILE (_errorfound=rpt_errorfound
      AND _errcnt < 512)
       SET _errcnt += 1
       SET stat = alterlist(rpterrors->errors,_errcnt)
       SET rpterrors->errors[_errcnt].m_severity = rpterror->m_severity
       SET rpterrors->errors[_errcnt].m_text = rpterror->m_text
       SET rpterrors->errors[_errcnt].m_source = rpterror->m_source
       SET _errorfound = uar_rptnexterror(_hreport,rpterror)
     ENDWHILE
     SET _rptstat = uar_rptdestroyreport(_hreport)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (fieldname00(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname00abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (fieldname00abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.110000), private
   DECLARE __cellname19 = vc WITH noconstant(build(cclbuildhlink(him_program_name,him_render_params,
      him_window,"Printer Friendly Version"),char(0))), protect
   IF ( NOT (_bgeneratehtml))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 1056
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 10.001
    SET rptsd->m_height = 0.115
    SET _oldfont = uar_rptsetfont(_hreport,_times10bi255)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET oldbackcolor = uar_rptsetbackcolor(_hreport,rpt_white)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cellname19)
    SET oldbackcolor = uar_rptresetbackcolor(_hreport)
    SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (fieldname00html(dummy=i2) =null WITH protect)
   IF (_bgeneratehtml)
    SET _htmlfileinfo->file_buf = build2("<tr>","<td class='FieldName000' colspan='10'>",
     cclbuildhlink(him_program_name,him_render_params,him_window,"Printer Friendly Version"),"</td>",
     "</tr>")
    SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
   ENDIF
 END ;Subroutine
 SUBROUTINE (fieldname01(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname01abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (fieldname01abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.400000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 1040
    SET rptsd->m_borders = bor(bor(rpt_sdtopborder,rpt_sdleftborder),rpt_sdrightborder)
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 10.001
    SET rptsd->m_height = 0.396
    SET _oldfont = uar_rptsetfont(_hreport,_times12bi10485760)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(uar_i18ngetmessage(_hi18nhandle,
       "FieldName01_CellName0",build2("Deficiency Analysis Productivity Report",char(0))),char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (fieldname01html(dummy=i2) =null WITH protect)
  SET _htmlfileinfo->file_buf = build2("<tr>","<td class='FieldName010' colspan='10'>",
   uar_i18ngetmessage(_hi18nhandle,"BHS_HIM_PROD_ANALYSIS_SUM_NGRP_CellName0",
    "Deficiency Analysis Productivity Report"),"</td>","</tr>")
  SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
 END ;Subroutine
 SUBROUTINE (fieldname02(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname02abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (fieldname02abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.290000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 272
    SET rptsd->m_borders = bor(rpt_sdleftborder,rpt_sdrightborder)
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 10.001
    SET rptsd->m_height = 0.292
    SET _oldfont = uar_rptsetfont(_hreport,_times12bi10485760)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(uar_i18ngetmessage(_hi18nhandle,
       "FieldName02_CellName1",build2("Summary Report",char(0))),char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (fieldname02html(dummy=i2) =null WITH protect)
  SET _htmlfileinfo->file_buf = build2("<tr>","<td class='FieldName020' colspan='10'>",
   uar_i18ngetmessage(_hi18nhandle,"BHS_HIM_PROD_ANALYSIS_SUM_NGRP_CellName1","Summary Report"),
   "</td>","</tr>")
  SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
 END ;Subroutine
 SUBROUTINE (fieldname03(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname03abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (fieldname03abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.290000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 272
    SET rptsd->m_borders = bor(bor(rpt_sdbottomborder,rpt_sdleftborder),rpt_sdrightborder)
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 10.001
    SET rptsd->m_height = 0.292
    SET _oldfont = uar_rptsetfont(_hreport,_times12b8289918)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(daterange,char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (fieldname03html(dummy=i2) =null WITH protect)
  SET _htmlfileinfo->file_buf = build2("<tr>","<td class='FieldName030' colspan='10'>",daterange,
   "</td>","</tr>")
  SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
 END ;Subroutine
 SUBROUTINE (fieldname04(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname04abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (fieldname04abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.130000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 10.001
    SET rptsd->m_height = 0.126
    SET _oldfont = uar_rptsetfont(_hreport,_times100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(blank,char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (fieldname04html(dummy=i2) =null WITH protect)
  SET _htmlfileinfo->file_buf = build2("<tr>","<td class='FieldName040' colspan='10'>",blank,"</td>",
   "</tr>")
  SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
 END ;Subroutine
 SUBROUTINE (fieldname05(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname05abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (fieldname05abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.200000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 288
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 1.501)
    SET rptsd->m_width = 8.501
    SET rptsd->m_height = 0.198
    SET _oldfont = uar_rptsetfont(_hreport,_times100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(vctodaydatetime,char(0)))
    SET rptsd->m_flags = 256
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.198
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(i18ndateprinted,char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.500),offsety,(offsetx+ 1.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (fieldname05html(dummy=i2) =null WITH protect)
  SET _htmlfileinfo->file_buf = build2("<tr>","<td class='FieldName050' colspan='2'>",i18ndateprinted,
   "</td>","<td class='FieldName051' colspan='8'>",
   vctodaydatetime,"</td>","</tr>")
  SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
 END ;Subroutine
 SUBROUTINE (fieldname06(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname06abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (fieldname06abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.190000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 288
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 1.501)
    SET rptsd->m_width = 8.501
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_times100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(vcuser,char(0)))
    SET rptsd->m_flags = 256
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(i18nuserprinted,char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.500),offsety,(offsetx+ 1.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (fieldname06html(dummy=i2) =null WITH protect)
  SET _htmlfileinfo->file_buf = build2("<tr>","<td class='FieldName050' colspan='2'>",i18nuserprinted,
   "</td>","<td class='FieldName051' colspan='8'>",
   vcuser,"</td>","</tr>")
  SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
 END ;Subroutine
 SUBROUTINE (fieldname07(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname07abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (fieldname07abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.190000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 256
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 1.501)
    SET rptsd->m_width = 8.501
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_times100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(i18npromptsfilters,char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.500),offsety,(offsetx+ 1.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (fieldname07html(dummy=i2) =null WITH protect)
  SET _htmlfileinfo->file_buf = build2("<tr>","<td class='FieldName050' colspan='2'>",
   i18npromptsfilters,"</td>","<td class='FieldName071' colspan='8'>",
   "","</td>","</tr>")
  SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
 END ;Subroutine
 SUBROUTINE (fieldname08(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname08abs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (fieldname08abs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =f8 WITH
  protect)
   DECLARE sectionheight = f8 WITH noconstant(0.190000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_facilitylist = f8 WITH noconstant(0.0), private
   DECLARE __facilitylist = vc WITH noconstant(build(facilitylist,char(0))), protect
   IF ( NOT (i1multifacilitylogicind))
    RETURN(0.0)
   ENDIF
   IF (bcontinue=0)
    SET _remfacilitylist = 1
   ENDIF
   SET rptsd->m_flags = 261
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.876)
   SET rptsd->m_width = 7.125
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times100)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremfacilitylist = _remfacilitylist
   IF (_remfacilitylist > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfacilitylist,((size(
        __facilitylist) - _remfacilitylist)+ 1),__facilitylist)))
    SET drawheight_facilitylist = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remfacilitylist = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfacilitylist,((size(__facilitylist) -
       _remfacilitylist)+ 1),__facilitylist)))))
     SET _remfacilitylist += rptsd->m_drawlength
    ELSE
     SET _remfacilitylist = 0
    ENDIF
    SET growsum += _remfacilitylist
   ENDIF
   SET rptsd->m_flags = 260
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.876)
   SET rptsd->m_width = 7.125
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render
    AND _holdremfacilitylist > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfacilitylist,((
       size(__facilitylist) - _holdremfacilitylist)+ 1),__facilitylist)))
   ELSE
    SET _remfacilitylist = _holdremfacilitylist
   ENDIF
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.501)
   SET rptsd->m_width = 1.375
   SET rptsd->m_height = sectionheight
   SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(i18nfacilities,char(0)))
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = sectionheight
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.500),offsety,(offsetx+ 1.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.875),offsety,(offsetx+ 2.875),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
   ENDIF
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (fieldname08html(dummy=i2) =null WITH protect)
   IF (i1multifacilitylogicind)
    SET _htmlfileinfo->file_buf = build2("<tr>","<td class='FieldName040' colspan='2'>","","</td>",
     "<td class='FieldName050' colspan='3'>",
     i18nfacilities,"</td>","<td class='FieldName082' colspan='5'>",facilitylist,"</td>",
     "</tr>")
    SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
   ENDIF
 END ;Subroutine
 SUBROUTINE (fieldname09(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname09abs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (fieldname09abs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =f8 WITH
  protect)
   DECLARE sectionheight = f8 WITH noconstant(0.190000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_userlist = f8 WITH noconstant(0.0), private
   DECLARE __userlist = vc WITH noconstant(build(userlist,char(0))), protect
   IF (bcontinue=0)
    SET _remuserlist = 1
   ENDIF
   SET rptsd->m_flags = 261
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.876)
   SET rptsd->m_width = 7.125
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times100)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremuserlist = _remuserlist
   IF (_remuserlist > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remuserlist,((size(
        __userlist) - _remuserlist)+ 1),__userlist)))
    SET drawheight_userlist = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remuserlist = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remuserlist,((size(__userlist) -
       _remuserlist)+ 1),__userlist)))))
     SET _remuserlist += rptsd->m_drawlength
    ELSE
     SET _remuserlist = 0
    ENDIF
    SET growsum += _remuserlist
   ENDIF
   SET rptsd->m_flags = 260
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.876)
   SET rptsd->m_width = 7.125
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render
    AND _holdremuserlist > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremuserlist,((size(
        __userlist) - _holdremuserlist)+ 1),__userlist)))
   ELSE
    SET _remuserlist = _holdremuserlist
   ENDIF
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.501)
   SET rptsd->m_width = 1.375
   SET rptsd->m_height = sectionheight
   SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(uar_i18ngetmessage(_hi18nhandle,
       "FieldName09_CellName5",build2("User Name(s):",char(0))),char(0)))
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = sectionheight
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.500),offsety,(offsetx+ 1.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.875),offsety,(offsetx+ 2.875),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
   ENDIF
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (fieldname09html(dummy=i2) =null WITH protect)
  SET _htmlfileinfo->file_buf = build2("<tr>","<td class='FieldName040' colspan='2'>","","</td>",
   "<td class='FieldName050' colspan='3'>",
   uar_i18ngetmessage(_hi18nhandle,"BHS_HIM_PROD_ANALYSIS_SUM_NGRP_CellName5","User Name(s):"),
   "</td>","<td class='FieldName082' colspan='5'>",userlist,"</td>",
   "</tr>")
  SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
 END ;Subroutine
 SUBROUTINE (fieldname010(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname010abs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (fieldname010abs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =f8 WITH
  protect)
   DECLARE sectionheight = f8 WITH noconstant(0.220000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_taskqueuelist = f8 WITH noconstant(0.0), private
   DECLARE __taskqueuelist = vc WITH noconstant(build(taskqueuelist,char(0))), protect
   IF (bcontinue=0)
    SET _remtaskqueuelist = 1
   ENDIF
   SET rptsd->m_flags = 261
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.876)
   SET rptsd->m_width = 7.125
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times100)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremtaskqueuelist = _remtaskqueuelist
   IF (_remtaskqueuelist > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remtaskqueuelist,((size(
        __taskqueuelist) - _remtaskqueuelist)+ 1),__taskqueuelist)))
    SET drawheight_taskqueuelist = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remtaskqueuelist = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remtaskqueuelist,((size(__taskqueuelist)
        - _remtaskqueuelist)+ 1),__taskqueuelist)))))
     SET _remtaskqueuelist += rptsd->m_drawlength
    ELSE
     SET _remtaskqueuelist = 0
    ENDIF
    SET growsum += _remtaskqueuelist
   ENDIF
   SET rptsd->m_flags = 260
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.876)
   SET rptsd->m_width = 7.125
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render
    AND _holdremtaskqueuelist > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremtaskqueuelist,((
       size(__taskqueuelist) - _holdremtaskqueuelist)+ 1),__taskqueuelist)))
   ELSE
    SET _remtaskqueuelist = _holdremtaskqueuelist
   ENDIF
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.501)
   SET rptsd->m_width = 1.375
   SET rptsd->m_height = sectionheight
   SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(uar_i18ngetmessage(_hi18nhandle,
       "FieldName010_CellName7",build2("Task Queue(s):",char(0))),char(0)))
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = sectionheight
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.500),offsety,(offsetx+ 1.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.875),offsety,(offsetx+ 2.875),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
   ENDIF
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (fieldname010html(dummy=i2) =null WITH protect)
  SET _htmlfileinfo->file_buf = build2("<tr>","<td class='FieldName040' colspan='2'>","","</td>",
   "<td class='FieldName050' colspan='3'>",
   uar_i18ngetmessage(_hi18nhandle,"BHS_HIM_PROD_ANALYSIS_SUM_NGRP_CellName7","Task Queue(s):"),
   "</td>","<td class='FieldName082' colspan='5'>",taskqueuelist,"</td>",
   "</tr>")
  SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
 END ;Subroutine
 SUBROUTINE (fieldname011(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname011abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (fieldname011abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.190000), private
   DECLARE __daterangeprompts = vc WITH noconstant(build(getdaterangedisplay(dates,him_prompt),char(0
      ))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 256
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 2.876)
    SET rptsd->m_width = 7.125
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_times100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__daterangeprompts)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 1.501)
    SET rptsd->m_width = 1.375
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(i18ndaterange,char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.500),offsety,(offsetx+ 1.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.875),offsety,(offsetx+ 2.875),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (fieldname011html(dummy=i2) =null WITH protect)
  SET _htmlfileinfo->file_buf = build2("<tr>","<td class='FieldName040' colspan='2'>","","</td>",
   "<td class='FieldName050' colspan='3'>",
   i18ndaterange,"</td>","<td class='FieldName071' colspan='5'>",getdaterangedisplay(dates,him_prompt
    ),"</td>",
   "</tr>")
  SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
 END ;Subroutine
 SUBROUTINE (fieldname012(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname012abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (fieldname012abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.190000), private
   IF ( NOT (negate(_bgeneratehtml)))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 576
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 10.001
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(rpt_pageofpage,char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (fieldname012html(dummy=i2) =null WITH protect)
   IF (negate(_bgeneratehtml))
    SET _htmlfileinfo->file_buf = build2("<tr>","<td class='FieldName0120' colspan='10'>",
     rpt_pageofpage,"</td>","</tr>")
    SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
   ENDIF
 END ;Subroutine
 SUBROUTINE (fieldname013(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname013abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (fieldname013abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.190000), private
   IF ( NOT (rowcount > 0))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 1088
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 1.751)
    SET rptsd->m_width = 8.251
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
    SET rptsd->m_flags = 1056
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.750
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.750),offsety,(offsetx+ 1.750),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (fieldname013html(dummy=i2) =null WITH protect)
   IF (rowcount > 0)
    SET _htmlfileinfo->file_buf = build2("<tr>","<td class='FieldName0130' colspan='3'>","","</td>",
     "<td class='FieldName0131' colspan='7'>",
     "","</td>","</tr>")
    SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
   ENDIF
 END ;Subroutine
 SUBROUTINE (fieldname014(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname014abs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (fieldname014abs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =f8 WITH
  protect)
   DECLARE sectionheight = f8 WITH noconstant(0.200000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_cellname22 = f8 WITH noconstant(0.0), private
   DECLARE drawheight_cellname21 = f8 WITH noconstant(0.0), private
   DECLARE drawheight_cellname17 = f8 WITH noconstant(0.0), private
   DECLARE drawheight_cellname14 = f8 WITH noconstant(0.0), private
   DECLARE __cellname22 = vc WITH noconstant(build(uar_i18ngetmessage(_hi18nhandle,
      "FieldName014_CellName22",build2("Avg TAT Task (Create to Final)",char(0))),char(0))), protect
   DECLARE __cellname21 = vc WITH noconstant(build(uar_i18ngetmessage(_hi18nhandle,
      "FieldName014_CellName21",build2("Avg TAT (Discharge to Final)",char(0))),char(0))), protect
   DECLARE __cellname17 = vc WITH noconstant(build(uar_i18ngetmessage(_hi18nhandle,
      "FieldName014_CellName17",build2("Avg LOS (Days)",char(0))),char(0))), protect
   DECLARE __cellname14 = vc WITH noconstant(build(uar_i18ngetmessage(_hi18nhandle,
      "FieldName014_CellName14",build2("Total Charts Analyzed",char(0))),char(0))), protect
   IF ( NOT (rowcount > 0))
    RETURN(0.0)
   ENDIF
   IF (bcontinue=0)
    SET _remcellname22 = 1
    SET _remcellname21 = 1
    SET _remcellname17 = 1
    SET _remcellname14 = 1
   ENDIF
   SET rptsd->m_flags = 1093
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.100
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 8.001)
   SET rptsd->m_width = 2.001
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremcellname22 = _remcellname22
   IF (_remcellname22 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remcellname22,((size(
        __cellname22) - _remcellname22)+ 1),__cellname22)))
    SET drawheight_cellname22 = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remcellname22 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remcellname22,((size(__cellname22) -
       _remcellname22)+ 1),__cellname22)))))
     SET _remcellname22 += rptsd->m_drawlength
    ELSE
     SET _remcellname22 = 0
    ENDIF
    SET growsum += _remcellname22
   ENDIF
   SET rptsd->m_flags = 1093
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.100
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 5.875)
   SET rptsd->m_width = 2.126
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremcellname21 = _remcellname21
   IF (_remcellname21 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remcellname21,((size(
        __cellname21) - _remcellname21)+ 1),__cellname21)))
    SET drawheight_cellname21 = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remcellname21 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remcellname21,((size(__cellname21) -
       _remcellname21)+ 1),__cellname21)))))
     SET _remcellname21 += rptsd->m_drawlength
    ELSE
     SET _remcellname21 = 0
    ENDIF
    SET growsum += _remcellname21
   ENDIF
   SET rptsd->m_flags = 1093
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 4.250)
   SET rptsd->m_width = 1.625
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremcellname17 = _remcellname17
   IF (_remcellname17 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remcellname17,((size(
        __cellname17) - _remcellname17)+ 1),__cellname17)))
    SET drawheight_cellname17 = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remcellname17 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remcellname17,((size(__cellname17) -
       _remcellname17)+ 1),__cellname17)))))
     SET _remcellname17 += rptsd->m_drawlength
    ELSE
     SET _remcellname17 = 0
    ENDIF
    SET growsum += _remcellname17
   ENDIF
   SET rptsd->m_flags = 1093
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.876)
   SET rptsd->m_width = 1.375
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremcellname14 = _remcellname14
   IF (_remcellname14 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remcellname14,((size(
        __cellname14) - _remcellname14)+ 1),__cellname14)))
    SET drawheight_cellname14 = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remcellname14 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remcellname14,((size(__cellname14) -
       _remcellname14)+ 1),__cellname14)))))
     SET _remcellname14 += rptsd->m_drawlength
    ELSE
     SET _remcellname14 = 0
    ENDIF
    SET growsum += _remcellname14
   ENDIF
   SET rptsd->m_flags = 1092
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.100
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 8.001)
   SET rptsd->m_width = 2.001
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render
    AND _holdremcellname22 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremcellname22,((size(
        __cellname22) - _holdremcellname22)+ 1),__cellname22)))
   ELSE
    SET _remcellname22 = _holdremcellname22
   ENDIF
   SET rptsd->m_flags = 1092
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.100
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 5.875)
   SET rptsd->m_width = 2.126
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render
    AND _holdremcellname21 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremcellname21,((size(
        __cellname21) - _holdremcellname21)+ 1),__cellname21)))
   ELSE
    SET _remcellname21 = _holdremcellname21
   ENDIF
   SET rptsd->m_flags = 1092
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 4.250)
   SET rptsd->m_width = 1.625
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render
    AND _holdremcellname17 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremcellname17,((size(
        __cellname17) - _holdremcellname17)+ 1),__cellname17)))
   ELSE
    SET _remcellname17 = _holdremcellname17
   ENDIF
   SET rptsd->m_flags = 1092
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.876)
   SET rptsd->m_width = 1.375
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render
    AND _holdremcellname14 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremcellname14,((size(
        __cellname14) - _holdremcellname14)+ 1),__cellname14)))
   ELSE
    SET _remcellname14 = _holdremcellname14
   ENDIF
   SET rptsd->m_flags = 1088
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.751)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(uar_i18ngetmessage(_hi18nhandle,
       "FieldName014_CellName13",build2("Task Queue",char(0))),char(0)))
   ENDIF
   SET rptsd->m_flags = 1056
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.200
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.750
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(uar_i18ngetmessage(_hi18nhandle,
       "FieldName014_CellName12",build2("User Name",char(0))),char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.750),offsety,(offsetx+ 1.750),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.875),offsety,(offsetx+ 2.875),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.250),offsety,(offsetx+ 4.250),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.875),offsety,(offsetx+ 5.875),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.000),offsety,(offsetx+ 8.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
   ENDIF
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (fieldname014html(dummy=i2) =null WITH protect)
   IF (rowcount > 0)
    SET _htmlfileinfo->file_buf = build2("<tr>","<td class='FieldName0140' colspan='3'>",
     uar_i18ngetmessage(_hi18nhandle,"BHS_HIM_PROD_ANALYSIS_SUM_NGRP_CellName12","User Name"),"</td>",
     "<td class='FieldName0141' colspan='2'>",
     uar_i18ngetmessage(_hi18nhandle,"BHS_HIM_PROD_ANALYSIS_SUM_NGRP_CellName13","Task Queue"),
     "</td>","<td class='FieldName0142' colspan='2'>",uar_i18ngetmessage(_hi18nhandle,
      "BHS_HIM_PROD_ANALYSIS_SUM_NGRP_CellName14","Total Charts Analyzed"),"</td>",
     "<td class='FieldName0142' colspan='1'>",uar_i18ngetmessage(_hi18nhandle,
      "BHS_HIM_PROD_ANALYSIS_SUM_NGRP_CellName17","Avg LOS (Days)"),"</td>",
     "<td class='FieldName0144' colspan='1'>",uar_i18ngetmessage(_hi18nhandle,
      "BHS_HIM_PROD_ANALYSIS_SUM_NGRP_CellName21","Avg TAT (Discharge to Final)"),
     "</td>","<td class='FieldName0145' colspan='1'>",uar_i18ngetmessage(_hi18nhandle,
      "BHS_HIM_PROD_ANALYSIS_SUM_NGRP_CellName22","Avg TAT Task (Create to Final)"),"</td>","</tr>")
    SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
   ENDIF
 END ;Subroutine
 SUBROUTINE (fieldname016(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname016abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (fieldname016abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.190000), private
   IF ( NOT (0))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 256
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 10.001
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_times100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(usernamehead,char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (fieldname016html(dummy=i2) =null WITH protect)
   IF (0)
    EXECUTE NULL ;noop
   ENDIF
 END ;Subroutine
 SUBROUTINE (fieldname017(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname017abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (fieldname017abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.130000), private
   IF ( NOT (0))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 256
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdleftborder
    SET rptsd->m_paddingwidth = 0.100
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 10.001
    SET rptsd->m_height = 0.136
    SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (fieldname017html(dummy=i2) =null WITH protect)
   IF (0)
    EXECUTE NULL ;noop
   ENDIF
 END ;Subroutine
 SUBROUTINE (fieldname018(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname018abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (fieldname018abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.130000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 1056
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 10.001
    SET rptsd->m_height = 0.136
    SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (fieldname018html(dummy=i2) =null WITH protect)
  SET _htmlfileinfo->file_buf = build2("<tr>","<td class='FieldName0130' colspan='10'>","","</td>",
   "</tr>")
  SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
 END ;Subroutine
 SUBROUTINE (fieldname019(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname019abs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (fieldname019abs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =f8 WITH
  protect)
   DECLARE sectionheight = f8 WITH noconstant(0.200000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_cellname60 = f8 WITH noconstant(0.0), private
   DECLARE drawheight_cellname59 = f8 WITH noconstant(0.0), private
   DECLARE drawheight_cellname56 = f8 WITH noconstant(0.0), private
   DECLARE __cellname60 = vc WITH noconstant(build(uar_i18ngetmessage(_hi18nhandle,
      "FieldName019_CellName60",build2("Avg TAT Task (Create to Final)",char(0))),char(0))), protect
   DECLARE __cellname59 = vc WITH noconstant(build(uar_i18ngetmessage(_hi18nhandle,
      "FieldName019_CellName59",build2("Avg TAT (Discharge to Final)",char(0))),char(0))), protect
   DECLARE __cellname56 = vc WITH noconstant(build(uar_i18ngetmessage(_hi18nhandle,
      "FieldName019_CellName56",build2("Avg LOS (Days)",char(0))),char(0))), protect
   IF (bcontinue=0)
    SET _remcellname60 = 1
    SET _remcellname59 = 1
    SET _remcellname56 = 1
   ENDIF
   SET rptsd->m_flags = 1093
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.100
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 8.001)
   SET rptsd->m_width = 2.001
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremcellname60 = _remcellname60
   IF (_remcellname60 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remcellname60,((size(
        __cellname60) - _remcellname60)+ 1),__cellname60)))
    SET drawheight_cellname60 = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remcellname60 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remcellname60,((size(__cellname60) -
       _remcellname60)+ 1),__cellname60)))))
     SET _remcellname60 += rptsd->m_drawlength
    ELSE
     SET _remcellname60 = 0
    ENDIF
    SET growsum += _remcellname60
   ENDIF
   SET rptsd->m_flags = 1093
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.100
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 5.875)
   SET rptsd->m_width = 2.126
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremcellname59 = _remcellname59
   IF (_remcellname59 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remcellname59,((size(
        __cellname59) - _remcellname59)+ 1),__cellname59)))
    SET drawheight_cellname59 = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remcellname59 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remcellname59,((size(__cellname59) -
       _remcellname59)+ 1),__cellname59)))))
     SET _remcellname59 += rptsd->m_drawlength
    ELSE
     SET _remcellname59 = 0
    ENDIF
    SET growsum += _remcellname59
   ENDIF
   SET rptsd->m_flags = 1093
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 4.250)
   SET rptsd->m_width = 1.625
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremcellname56 = _remcellname56
   IF (_remcellname56 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remcellname56,((size(
        __cellname56) - _remcellname56)+ 1),__cellname56)))
    SET drawheight_cellname56 = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remcellname56 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remcellname56,((size(__cellname56) -
       _remcellname56)+ 1),__cellname56)))))
     SET _remcellname56 += rptsd->m_drawlength
    ELSE
     SET _remcellname56 = 0
    ENDIF
    SET growsum += _remcellname56
   ENDIF
   SET rptsd->m_flags = 1092
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.100
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 8.001)
   SET rptsd->m_width = 2.001
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render
    AND _holdremcellname60 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremcellname60,((size(
        __cellname60) - _holdremcellname60)+ 1),__cellname60)))
   ELSE
    SET _remcellname60 = _holdremcellname60
   ENDIF
   SET rptsd->m_flags = 1092
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.100
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 5.875)
   SET rptsd->m_width = 2.126
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render
    AND _holdremcellname59 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremcellname59,((size(
        __cellname59) - _holdremcellname59)+ 1),__cellname59)))
   ELSE
    SET _remcellname59 = _holdremcellname59
   ENDIF
   SET rptsd->m_flags = 1092
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 4.250)
   SET rptsd->m_width = 1.625
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render
    AND _holdremcellname56 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremcellname56,((size(
        __cellname56) - _holdremcellname56)+ 1),__cellname56)))
   ELSE
    SET _remcellname56 = _holdremcellname56
   ENDIF
   SET rptsd->m_flags = 1088
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.876)
   SET rptsd->m_width = 1.375
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(uar_i18ngetmessage(_hi18nhandle,
       "FieldName019_CellName53",build2("Total Charts Analyzed",char(0))),char(0)))
   ENDIF
   SET rptsd->m_flags = 1088
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.751)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(uar_i18ngetmessage(_hi18nhandle,
       "FieldName019_CellName52",build2("Task Queue",char(0))),char(0)))
   ENDIF
   SET rptsd->m_flags = 1056
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.200
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.021)
   SET rptsd->m_width = 0.730
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(uar_i18ngetmessage(_hi18nhandle,
       "FieldName019_User_ID",build2("User ID",char(0))),char(0)))
   ENDIF
   SET rptsd->m_flags = 1056
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.200
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.021
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(uar_i18ngetmessage(_hi18nhandle,
       "FieldName019_CellName47",build2("User Name",char(0))),char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.021),offsety,(offsetx+ 1.021),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.750),offsety,(offsetx+ 1.750),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.875),offsety,(offsetx+ 2.875),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.250),offsety,(offsetx+ 4.250),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.875),offsety,(offsetx+ 5.875),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.000),offsety,(offsetx+ 8.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
   ENDIF
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (fieldname019html(dummy=i2) =null WITH protect)
  SET _htmlfileinfo->file_buf = build2("<tr>","<td class='FieldName0140' colspan='1'>",
   uar_i18ngetmessage(_hi18nhandle,"BHS_HIM_PROD_ANALYSIS_SUM_NGRP_CellName47","User Name"),"</td>",
   "<td class='FieldName0140' colspan='2'>",
   uar_i18ngetmessage(_hi18nhandle,"BHS_HIM_PROD_ANALYSIS_SUM_NGRP_User_ID","User ID"),"</td>",
   "<td class='FieldName0141' colspan='2'>",uar_i18ngetmessage(_hi18nhandle,
    "BHS_HIM_PROD_ANALYSIS_SUM_NGRP_CellName52","Task Queue"),"</td>",
   "<td class='FieldName0141' colspan='2'>",uar_i18ngetmessage(_hi18nhandle,
    "BHS_HIM_PROD_ANALYSIS_SUM_NGRP_CellName53","Total Charts Analyzed"),"</td>",
   "<td class='FieldName0142' colspan='1'>",uar_i18ngetmessage(_hi18nhandle,
    "BHS_HIM_PROD_ANALYSIS_SUM_NGRP_CellName56","Avg LOS (Days)"),
   "</td>","<td class='FieldName0144' colspan='1'>",uar_i18ngetmessage(_hi18nhandle,
    "BHS_HIM_PROD_ANALYSIS_SUM_NGRP_CellName59","Avg TAT (Discharge to Final)"),"</td>",
   "<td class='FieldName0144' colspan='1'>",
   uar_i18ngetmessage(_hi18nhandle,"BHS_HIM_PROD_ANALYSIS_SUM_NGRP_CellName60",
    "Avg TAT Task (Create to Final)"),"</td>","</tr>")
  SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
 END ;Subroutine
 SUBROUTINE (fieldname020(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname020abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (fieldname020abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.130000), private
   IF ( NOT (0))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 256
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 10.001
    SET rptsd->m_height = 0.126
    SET _oldfont = uar_rptsetfont(_hreport,_times100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (fieldname020html(dummy=i2) =null WITH protect)
   IF (0)
    EXECUTE NULL ;noop
   ENDIF
 END ;Subroutine
 SUBROUTINE (fieldname021(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname021abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (fieldname021abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.130000), private
   IF ( NOT (0))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 256
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 10.001
    SET rptsd->m_height = 0.126
    SET _oldfont = uar_rptsetfont(_hreport,_times100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(taskqueuehead,char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (fieldname021html(dummy=i2) =null WITH protect)
   IF (0)
    EXECUTE NULL ;noop
   ENDIF
 END ;Subroutine
 SUBROUTINE (fieldname022(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname022abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (fieldname022abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.130000), private
   IF ( NOT (0))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 1056
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 10.001
    SET rptsd->m_height = 0.126
    SET _oldfont = uar_rptsetfont(_hreport,_times100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(detailblankrow,char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (fieldname022html(dummy=i2) =null WITH protect)
   IF (0)
    EXECUTE NULL ;noop
   ENDIF
 END ;Subroutine
 SUBROUTINE (fieldname023(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname023abs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (fieldname023abs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =f8 WITH
  protect)
   DECLARE sectionheight = f8 WITH noconstant(0.240000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_tatcreatetofinalrowone = f8 WITH noconstant(0.0), private
   DECLARE drawheight_tatdischargetofinalrowone = f8 WITH noconstant(0.0), private
   DECLARE drawheight_avglosdisplayrowone = f8 WITH noconstant(0.0), private
   DECLARE drawheight_totalchartsrowone = f8 WITH noconstant(0.0), private
   DECLARE drawheight_taskqueuerowone = f8 WITH noconstant(0.0), private
   DECLARE drawheight_user_username_ = f8 WITH noconstant(0.0), private
   DECLARE drawheight_usernamerowone = f8 WITH noconstant(0.0), private
   DECLARE __tatcreatetofinalrowone = vc WITH noconstant(build(cnvtminstodayshoursmins(
      tat_create_to_final),char(0))), protect
   DECLARE __tatdischargetofinalrowone = vc WITH noconstant(build(cnvtminstodayshoursmins(
      tat_discharge_to_final),char(0))), protect
   DECLARE __avglosdisplayrowone = vc WITH noconstant(build(avglosdisplayrowone,char(0))), protect
   DECLARE __totalchartsrowone = vc WITH noconstant(build(totalchartsrowone,char(0))), protect
   DECLARE __taskqueuerowone = vc WITH noconstant(build(task_queue_name,char(0))), protect
   DECLARE __user_username_ = vc WITH noconstant(build(user_username,char(0))), protect
   DECLARE __usernamerowone = vc WITH noconstant(build(usernamerowone,char(0))), protect
   IF ( NOT (mod(rowcount,2)=1))
    RETURN(0.0)
   ENDIF
   IF (bcontinue=0)
    SET _remtatcreatetofinalrowone = 1
    SET _remtatdischargetofinalrowone = 1
    SET _remavglosdisplayrowone = 1
    SET _remtotalchartsrowone = 1
    SET _remtaskqueuerowone = 1
    SET _remuser_username_ = 1
    SET _remusernamerowone = 1
   ENDIF
   SET rptsd->m_flags = 325
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.100
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 8.001)
   SET rptsd->m_width = 2.001
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times100)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremtatcreatetofinalrowone = _remtatcreatetofinalrowone
   IF (_remtatcreatetofinalrowone > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remtatcreatetofinalrowone,
       ((size(__tatcreatetofinalrowone) - _remtatcreatetofinalrowone)+ 1),__tatcreatetofinalrowone)))
    SET drawheight_tatcreatetofinalrowone = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remtatcreatetofinalrowone = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remtatcreatetofinalrowone,((size(
        __tatcreatetofinalrowone) - _remtatcreatetofinalrowone)+ 1),__tatcreatetofinalrowone)))))
     SET _remtatcreatetofinalrowone += rptsd->m_drawlength
    ELSE
     SET _remtatcreatetofinalrowone = 0
    ENDIF
    SET growsum += _remtatcreatetofinalrowone
   ENDIF
   SET rptsd->m_flags = 325
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.100
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 5.875)
   SET rptsd->m_width = 2.126
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremtatdischargetofinalrowone = _remtatdischargetofinalrowone
   IF (_remtatdischargetofinalrowone > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _remtatdischargetofinalrowone,((size(__tatdischargetofinalrowone) -
       _remtatdischargetofinalrowone)+ 1),__tatdischargetofinalrowone)))
    SET drawheight_tatdischargetofinalrowone = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remtatdischargetofinalrowone = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remtatdischargetofinalrowone,((size(
        __tatdischargetofinalrowone) - _remtatdischargetofinalrowone)+ 1),__tatdischargetofinalrowone
       )))))
     SET _remtatdischargetofinalrowone += rptsd->m_drawlength
    ELSE
     SET _remtatdischargetofinalrowone = 0
    ENDIF
    SET growsum += _remtatdischargetofinalrowone
   ENDIF
   SET rptsd->m_flags = 325
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 4.250)
   SET rptsd->m_width = 1.625
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremavglosdisplayrowone = _remavglosdisplayrowone
   IF (_remavglosdisplayrowone > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remavglosdisplayrowone,((
       size(__avglosdisplayrowone) - _remavglosdisplayrowone)+ 1),__avglosdisplayrowone)))
    SET drawheight_avglosdisplayrowone = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remavglosdisplayrowone = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remavglosdisplayrowone,((size(
        __avglosdisplayrowone) - _remavglosdisplayrowone)+ 1),__avglosdisplayrowone)))))
     SET _remavglosdisplayrowone += rptsd->m_drawlength
    ELSE
     SET _remavglosdisplayrowone = 0
    ENDIF
    SET growsum += _remavglosdisplayrowone
   ENDIF
   SET rptsd->m_flags = 325
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.876)
   SET rptsd->m_width = 1.375
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremtotalchartsrowone = _remtotalchartsrowone
   IF (_remtotalchartsrowone > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remtotalchartsrowone,((
       size(__totalchartsrowone) - _remtotalchartsrowone)+ 1),__totalchartsrowone)))
    SET drawheight_totalchartsrowone = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remtotalchartsrowone = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remtotalchartsrowone,((size(
        __totalchartsrowone) - _remtotalchartsrowone)+ 1),__totalchartsrowone)))))
     SET _remtotalchartsrowone += rptsd->m_drawlength
    ELSE
     SET _remtotalchartsrowone = 0
    ENDIF
    SET growsum += _remtotalchartsrowone
   ENDIF
   SET rptsd->m_flags = 325
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.751)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremtaskqueuerowone = _remtaskqueuerowone
   IF (_remtaskqueuerowone > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remtaskqueuerowone,((size
       (__taskqueuerowone) - _remtaskqueuerowone)+ 1),__taskqueuerowone)))
    SET drawheight_taskqueuerowone = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remtaskqueuerowone = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remtaskqueuerowone,((size(
        __taskqueuerowone) - _remtaskqueuerowone)+ 1),__taskqueuerowone)))))
     SET _remtaskqueuerowone += rptsd->m_drawlength
    ELSE
     SET _remtaskqueuerowone = 0
    ENDIF
    SET growsum += _remtaskqueuerowone
   ENDIF
   SET rptsd->m_flags = 293
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.200
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.021)
   SET rptsd->m_width = 0.730
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremuser_username_ = _remuser_username_
   IF (_remuser_username_ > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remuser_username_,((size(
        __user_username_) - _remuser_username_)+ 1),__user_username_)))
    SET drawheight_user_username_ = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remuser_username_ = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remuser_username_,((size(__user_username_
        ) - _remuser_username_)+ 1),__user_username_)))))
     SET _remuser_username_ += rptsd->m_drawlength
    ELSE
     SET _remuser_username_ = 0
    ENDIF
    SET growsum += _remuser_username_
   ENDIF
   SET rptsd->m_flags = 293
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.200
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.021
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremusernamerowone = _remusernamerowone
   IF (_remusernamerowone > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remusernamerowone,((size(
        __usernamerowone) - _remusernamerowone)+ 1),__usernamerowone)))
    SET drawheight_usernamerowone = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remusernamerowone = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remusernamerowone,((size(__usernamerowone
        ) - _remusernamerowone)+ 1),__usernamerowone)))))
     SET _remusernamerowone += rptsd->m_drawlength
    ELSE
     SET _remusernamerowone = 0
    ENDIF
    SET growsum += _remusernamerowone
   ENDIF
   SET rptsd->m_flags = 324
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.100
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 8.001)
   SET rptsd->m_width = 2.001
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render
    AND _holdremtatcreatetofinalrowone > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _holdremtatcreatetofinalrowone,((size(__tatcreatetofinalrowone) -
       _holdremtatcreatetofinalrowone)+ 1),__tatcreatetofinalrowone)))
   ELSE
    SET _remtatcreatetofinalrowone = _holdremtatcreatetofinalrowone
   ENDIF
   SET rptsd->m_flags = 324
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.100
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 5.875)
   SET rptsd->m_width = 2.126
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render
    AND _holdremtatdischargetofinalrowone > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _holdremtatdischargetofinalrowone,((size(__tatdischargetofinalrowone) -
       _holdremtatdischargetofinalrowone)+ 1),__tatdischargetofinalrowone)))
   ELSE
    SET _remtatdischargetofinalrowone = _holdremtatdischargetofinalrowone
   ENDIF
   SET rptsd->m_flags = 324
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 4.250)
   SET rptsd->m_width = 1.625
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render
    AND _holdremavglosdisplayrowone > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _holdremavglosdisplayrowone,((size(__avglosdisplayrowone) - _holdremavglosdisplayrowone)+ 1),
       __avglosdisplayrowone)))
   ELSE
    SET _remavglosdisplayrowone = _holdremavglosdisplayrowone
   ENDIF
   SET rptsd->m_flags = 324
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.876)
   SET rptsd->m_width = 1.375
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render
    AND _holdremtotalchartsrowone > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremtotalchartsrowone,
       ((size(__totalchartsrowone) - _holdremtotalchartsrowone)+ 1),__totalchartsrowone)))
   ELSE
    SET _remtotalchartsrowone = _holdremtotalchartsrowone
   ENDIF
   SET rptsd->m_flags = 324
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.751)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render
    AND _holdremtaskqueuerowone > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremtaskqueuerowone,((
       size(__taskqueuerowone) - _holdremtaskqueuerowone)+ 1),__taskqueuerowone)))
   ELSE
    SET _remtaskqueuerowone = _holdremtaskqueuerowone
   ENDIF
   SET rptsd->m_flags = 292
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.200
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.021)
   SET rptsd->m_width = 0.730
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render
    AND _holdremuser_username_ > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremuser_username_,((
       size(__user_username_) - _holdremuser_username_)+ 1),__user_username_)))
   ELSE
    SET _remuser_username_ = _holdremuser_username_
   ENDIF
   SET rptsd->m_flags = 292
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.200
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.021
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render
    AND _holdremusernamerowone > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremusernamerowone,((
       size(__usernamerowone) - _holdremusernamerowone)+ 1),__usernamerowone)))
   ELSE
    SET _remusernamerowone = _holdremusernamerowone
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.021),offsety,(offsetx+ 1.021),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.750),offsety,(offsetx+ 1.750),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.875),offsety,(offsetx+ 2.875),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.250),offsety,(offsetx+ 4.250),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.875),offsety,(offsetx+ 5.875),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.000),offsety,(offsetx+ 8.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
   ENDIF
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (fieldname023html(dummy=i2) =null WITH protect)
   IF (mod(rowcount,2)=1)
    SET _htmlfileinfo->file_buf = build2("<tr>","<td class='FieldName0230' colspan='1'>",
     usernamerowone,"</td>","<td class='FieldName0230' colspan='2'>",
     user_username,"</td>","<td class='FieldName0232' colspan='2'>",task_queue_name,"</td>",
     "<td class='FieldName0232' colspan='2'>",totalchartsrowone,"</td>",
     "<td class='FieldName0232' colspan='1'>",avglosdisplayrowone,
     "</td>","<td class='FieldName0235' colspan='1'>",cnvtminstodayshoursmins(tat_discharge_to_final),
     "</td>","<td class='FieldName0235' colspan='1'>",
     cnvtminstodayshoursmins(tat_create_to_final),"</td>","</tr>")
    SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
   ENDIF
 END ;Subroutine
 SUBROUTINE (fieldname024(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname024abs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (fieldname024abs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =f8 WITH
  protect)
   DECLARE sectionheight = f8 WITH noconstant(0.240000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_tatcreatetofinalrowtwo = f8 WITH noconstant(0.0), private
   DECLARE drawheight_tatdischargetofinalrowtwo = f8 WITH noconstant(0.0), private
   DECLARE drawheight_avglosdisplayrowtwo = f8 WITH noconstant(0.0), private
   DECLARE drawheight_totalchartsrowtwo = f8 WITH noconstant(0.0), private
   DECLARE drawheight_taskqueuerowtwo = f8 WITH noconstant(0.0), private
   DECLARE drawheight_user_username02 = f8 WITH noconstant(0.0), private
   DECLARE drawheight_usernamerowtwo = f8 WITH noconstant(0.0), private
   DECLARE __tatcreatetofinalrowtwo = vc WITH noconstant(build(cnvtminstodayshoursmins(
      tat_create_to_final),char(0))), protect
   DECLARE __tatdischargetofinalrowtwo = vc WITH noconstant(build(cnvtminstodayshoursmins(
      tat_discharge_to_final),char(0))), protect
   DECLARE __avglosdisplayrowtwo = vc WITH noconstant(build(avglosdisplayrowtwo,char(0))), protect
   DECLARE __totalchartsrowtwo = vc WITH noconstant(build(totalchartsrowtwo,char(0))), protect
   DECLARE __taskqueuerowtwo = vc WITH noconstant(build(task_queue_name,char(0))), protect
   DECLARE __user_username02 = vc WITH noconstant(build(user_username,char(0))), protect
   DECLARE __usernamerowtwo = vc WITH noconstant(build(usernamerowtwo,char(0))), protect
   IF ( NOT (mod(rowcount,2)=0))
    RETURN(0.0)
   ENDIF
   IF (bcontinue=0)
    SET _remtatcreatetofinalrowtwo = 1
    SET _remtatdischargetofinalrowtwo = 1
    SET _remavglosdisplayrowtwo = 1
    SET _remtotalchartsrowtwo = 1
    SET _remtaskqueuerowtwo = 1
    SET _remuser_username02 = 1
    SET _remusernamerowtwo = 1
   ENDIF
   SET rptsd->m_flags = 325
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.100
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 8.001)
   SET rptsd->m_width = 2.001
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times100)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremtatcreatetofinalrowtwo = _remtatcreatetofinalrowtwo
   IF (_remtatcreatetofinalrowtwo > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remtatcreatetofinalrowtwo,
       ((size(__tatcreatetofinalrowtwo) - _remtatcreatetofinalrowtwo)+ 1),__tatcreatetofinalrowtwo)))
    SET drawheight_tatcreatetofinalrowtwo = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remtatcreatetofinalrowtwo = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remtatcreatetofinalrowtwo,((size(
        __tatcreatetofinalrowtwo) - _remtatcreatetofinalrowtwo)+ 1),__tatcreatetofinalrowtwo)))))
     SET _remtatcreatetofinalrowtwo += rptsd->m_drawlength
    ELSE
     SET _remtatcreatetofinalrowtwo = 0
    ENDIF
    SET growsum += _remtatcreatetofinalrowtwo
   ENDIF
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(232,232,232))
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET rptsd->m_flags = 325
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.100
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 5.875)
   SET rptsd->m_width = 2.126
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremtatdischargetofinalrowtwo = _remtatdischargetofinalrowtwo
   IF (_remtatdischargetofinalrowtwo > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _remtatdischargetofinalrowtwo,((size(__tatdischargetofinalrowtwo) -
       _remtatdischargetofinalrowtwo)+ 1),__tatdischargetofinalrowtwo)))
    SET drawheight_tatdischargetofinalrowtwo = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remtatdischargetofinalrowtwo = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remtatdischargetofinalrowtwo,((size(
        __tatdischargetofinalrowtwo) - _remtatdischargetofinalrowtwo)+ 1),__tatdischargetofinalrowtwo
       )))))
     SET _remtatdischargetofinalrowtwo += rptsd->m_drawlength
    ELSE
     SET _remtatdischargetofinalrowtwo = 0
    ENDIF
    SET growsum += _remtatdischargetofinalrowtwo
   ENDIF
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(232,232,232))
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET rptsd->m_flags = 325
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 4.250)
   SET rptsd->m_width = 1.625
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremavglosdisplayrowtwo = _remavglosdisplayrowtwo
   IF (_remavglosdisplayrowtwo > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remavglosdisplayrowtwo,((
       size(__avglosdisplayrowtwo) - _remavglosdisplayrowtwo)+ 1),__avglosdisplayrowtwo)))
    SET drawheight_avglosdisplayrowtwo = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remavglosdisplayrowtwo = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remavglosdisplayrowtwo,((size(
        __avglosdisplayrowtwo) - _remavglosdisplayrowtwo)+ 1),__avglosdisplayrowtwo)))))
     SET _remavglosdisplayrowtwo += rptsd->m_drawlength
    ELSE
     SET _remavglosdisplayrowtwo = 0
    ENDIF
    SET growsum += _remavglosdisplayrowtwo
   ENDIF
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(232,232,232))
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET rptsd->m_flags = 325
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.876)
   SET rptsd->m_width = 1.375
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremtotalchartsrowtwo = _remtotalchartsrowtwo
   IF (_remtotalchartsrowtwo > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remtotalchartsrowtwo,((
       size(__totalchartsrowtwo) - _remtotalchartsrowtwo)+ 1),__totalchartsrowtwo)))
    SET drawheight_totalchartsrowtwo = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remtotalchartsrowtwo = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remtotalchartsrowtwo,((size(
        __totalchartsrowtwo) - _remtotalchartsrowtwo)+ 1),__totalchartsrowtwo)))))
     SET _remtotalchartsrowtwo += rptsd->m_drawlength
    ELSE
     SET _remtotalchartsrowtwo = 0
    ENDIF
    SET growsum += _remtotalchartsrowtwo
   ENDIF
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(232,232,232))
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET rptsd->m_flags = 325
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.751)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremtaskqueuerowtwo = _remtaskqueuerowtwo
   IF (_remtaskqueuerowtwo > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remtaskqueuerowtwo,((size
       (__taskqueuerowtwo) - _remtaskqueuerowtwo)+ 1),__taskqueuerowtwo)))
    SET drawheight_taskqueuerowtwo = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remtaskqueuerowtwo = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remtaskqueuerowtwo,((size(
        __taskqueuerowtwo) - _remtaskqueuerowtwo)+ 1),__taskqueuerowtwo)))))
     SET _remtaskqueuerowtwo += rptsd->m_drawlength
    ELSE
     SET _remtaskqueuerowtwo = 0
    ENDIF
    SET growsum += _remtaskqueuerowtwo
   ENDIF
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(232,232,232))
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET rptsd->m_flags = 293
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.200
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.021)
   SET rptsd->m_width = 0.730
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremuser_username02 = _remuser_username02
   IF (_remuser_username02 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remuser_username02,((size
       (__user_username02) - _remuser_username02)+ 1),__user_username02)))
    SET drawheight_user_username02 = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remuser_username02 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remuser_username02,((size(
        __user_username02) - _remuser_username02)+ 1),__user_username02)))))
     SET _remuser_username02 += rptsd->m_drawlength
    ELSE
     SET _remuser_username02 = 0
    ENDIF
    SET growsum += _remuser_username02
   ENDIF
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(232,232,232))
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET rptsd->m_flags = 293
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.200
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.021
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremusernamerowtwo = _remusernamerowtwo
   IF (_remusernamerowtwo > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remusernamerowtwo,((size(
        __usernamerowtwo) - _remusernamerowtwo)+ 1),__usernamerowtwo)))
    SET drawheight_usernamerowtwo = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remusernamerowtwo = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remusernamerowtwo,((size(__usernamerowtwo
        ) - _remusernamerowtwo)+ 1),__usernamerowtwo)))))
     SET _remusernamerowtwo += rptsd->m_drawlength
    ELSE
     SET _remusernamerowtwo = 0
    ENDIF
    SET growsum += _remusernamerowtwo
   ENDIF
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(232,232,232))
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET rptsd->m_flags = 324
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.100
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 8.001)
   SET rptsd->m_width = 2.001
   SET rptsd->m_height = sectionheight
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(232,232,232))
   IF (ncalc=rpt_render
    AND _holdremtatcreatetofinalrowtwo > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _holdremtatcreatetofinalrowtwo,((size(__tatcreatetofinalrowtwo) -
       _holdremtatcreatetofinalrowtwo)+ 1),__tatcreatetofinalrowtwo)))
   ELSE
    SET _remtatcreatetofinalrowtwo = _holdremtatcreatetofinalrowtwo
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET rptsd->m_flags = 324
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.100
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 5.875)
   SET rptsd->m_width = 2.126
   SET rptsd->m_height = sectionheight
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(232,232,232))
   IF (ncalc=rpt_render
    AND _holdremtatdischargetofinalrowtwo > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _holdremtatdischargetofinalrowtwo,((size(__tatdischargetofinalrowtwo) -
       _holdremtatdischargetofinalrowtwo)+ 1),__tatdischargetofinalrowtwo)))
   ELSE
    SET _remtatdischargetofinalrowtwo = _holdremtatdischargetofinalrowtwo
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET rptsd->m_flags = 324
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 4.250)
   SET rptsd->m_width = 1.625
   SET rptsd->m_height = sectionheight
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(232,232,232))
   IF (ncalc=rpt_render
    AND _holdremavglosdisplayrowtwo > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _holdremavglosdisplayrowtwo,((size(__avglosdisplayrowtwo) - _holdremavglosdisplayrowtwo)+ 1),
       __avglosdisplayrowtwo)))
   ELSE
    SET _remavglosdisplayrowtwo = _holdremavglosdisplayrowtwo
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET rptsd->m_flags = 324
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.876)
   SET rptsd->m_width = 1.375
   SET rptsd->m_height = sectionheight
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(232,232,232))
   IF (ncalc=rpt_render
    AND _holdremtotalchartsrowtwo > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremtotalchartsrowtwo,
       ((size(__totalchartsrowtwo) - _holdremtotalchartsrowtwo)+ 1),__totalchartsrowtwo)))
   ELSE
    SET _remtotalchartsrowtwo = _holdremtotalchartsrowtwo
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET rptsd->m_flags = 324
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.751)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = sectionheight
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(232,232,232))
   IF (ncalc=rpt_render
    AND _holdremtaskqueuerowtwo > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremtaskqueuerowtwo,((
       size(__taskqueuerowtwo) - _holdremtaskqueuerowtwo)+ 1),__taskqueuerowtwo)))
   ELSE
    SET _remtaskqueuerowtwo = _holdremtaskqueuerowtwo
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET rptsd->m_flags = 292
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.200
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.021)
   SET rptsd->m_width = 0.730
   SET rptsd->m_height = sectionheight
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(232,232,232))
   IF (ncalc=rpt_render
    AND _holdremuser_username02 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremuser_username02,((
       size(__user_username02) - _holdremuser_username02)+ 1),__user_username02)))
   ELSE
    SET _remuser_username02 = _holdremuser_username02
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET rptsd->m_flags = 292
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.200
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.021
   SET rptsd->m_height = sectionheight
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(232,232,232))
   IF (ncalc=rpt_render
    AND _holdremusernamerowtwo > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremusernamerowtwo,((
       size(__usernamerowtwo) - _holdremusernamerowtwo)+ 1),__usernamerowtwo)))
   ELSE
    SET _remusernamerowtwo = _holdremusernamerowtwo
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.021),offsety,(offsetx+ 1.021),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.750),offsety,(offsetx+ 1.750),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.875),offsety,(offsetx+ 2.875),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.250),offsety,(offsetx+ 4.250),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.875),offsety,(offsetx+ 5.875),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.000),offsety,(offsetx+ 8.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
   ENDIF
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (fieldname024html(dummy=i2) =null WITH protect)
   IF (mod(rowcount,2)=0)
    SET _htmlfileinfo->file_buf = build2("<tr>","<td class='FieldName0240' colspan='1'>",
     usernamerowtwo,"</td>","<td class='FieldName0240' colspan='2'>",
     user_username,"</td>","<td class='FieldName0242' colspan='2'>",task_queue_name,"</td>",
     "<td class='FieldName0242' colspan='2'>",totalchartsrowtwo,"</td>",
     "<td class='FieldName0242' colspan='1'>",avglosdisplayrowtwo,
     "</td>","<td class='FieldName0245' colspan='1'>",cnvtminstodayshoursmins(tat_discharge_to_final),
     "</td>","<td class='FieldName0245' colspan='1'>",
     cnvtminstodayshoursmins(tat_create_to_final),"</td>","</tr>")
    SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
   ENDIF
 END ;Subroutine
 SUBROUTINE (fieldname025(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname025abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (fieldname025abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.130000), private
   IF ( NOT (0))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 320
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdleftborder
    SET rptsd->m_paddingwidth = 0.200
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 10.001
    SET rptsd->m_height = 0.126
    SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET oldbackcolor = uar_rptsetbackcolor(_hreport,rpt_white)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
    SET oldbackcolor = uar_rptresetbackcolor(_hreport)
    SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (fieldname025html(dummy=i2) =null WITH protect)
   IF (0)
    EXECUTE NULL ;noop
   ENDIF
 END ;Subroutine
 SUBROUTINE (fieldname026(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname026abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (fieldname026abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.220000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 288
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 10.001
    SET rptsd->m_height = 0.219
    SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(255,255,128))
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(uar_i18ngetmessage(_hi18nhandle,
       "FieldName026_CellName48",build2("Totals for All Task Queues:",char(0))),char(0)))
    SET oldbackcolor = uar_rptresetbackcolor(_hreport)
    SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (fieldname026html(dummy=i2) =null WITH protect)
  SET _htmlfileinfo->file_buf = build2("<tr>","<td class='FieldName0260' colspan='10'>",
   uar_i18ngetmessage(_hi18nhandle,"BHS_HIM_PROD_ANALYSIS_SUM_NGRP_CellName48",
    "Totals for All Task Queues:"),"</td>","</tr>")
  SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
 END ;Subroutine
 SUBROUTINE (fieldname027(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname027abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (fieldname027abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.220000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 288
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 6.000
    SET rptsd->m_height = 0.219
    SET _oldfont = uar_rptsetfont(_hreport,_times100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(255,255,128))
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
    SET oldbackcolor = uar_rptresetbackcolor(_hreport)
    SET rptsd->m_flags = 320
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 2.501)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.219
    SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(255,255,128))
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(totalchartsperuserdisplay,char(0)))
    SET oldbackcolor = uar_rptresetbackcolor(_hreport)
    SET rptsd->m_flags = 288
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdleftborder
    SET rptsd->m_paddingwidth = 0.200
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.501
    SET rptsd->m_height = 0.219
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(255,255,128))
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(uar_i18ngetmessage(_hi18nhandle,
       "FieldName027_CellName72",build2("Total # of Charts Analyzed:",char(0))),char(0)))
    SET oldbackcolor = uar_rptresetbackcolor(_hreport)
    SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.500),offsety,(offsetx+ 2.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.000),offsety,(offsetx+ 4.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (fieldname027html(dummy=i2) =null WITH protect)
  SET _htmlfileinfo->file_buf = build2("<tr>","<td class='FieldName0270' colspan='4'>",
   uar_i18ngetmessage(_hi18nhandle,"BHS_HIM_PROD_ANALYSIS_SUM_NGRP_CellName72",
    "Total # of Charts Analyzed:"),"</td>","<td class='FieldName0271' colspan='2'>",
   totalchartsperuserdisplay,"</td>","<td class='FieldName0272' colspan='4'>","","</td>",
   "</tr>")
  SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
 END ;Subroutine
 SUBROUTINE (fieldname028(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname028abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (fieldname028abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.220000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 288
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 6.000
    SET rptsd->m_height = 0.219
    SET _oldfont = uar_rptsetfont(_hreport,_times100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(255,255,128))
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
    SET oldbackcolor = uar_rptresetbackcolor(_hreport)
    SET rptsd->m_flags = 320
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 2.501)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.219
    SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(255,255,128))
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(avgtatperuserdisplay,char(0)))
    SET oldbackcolor = uar_rptresetbackcolor(_hreport)
    SET rptsd->m_flags = 288
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdleftborder
    SET rptsd->m_paddingwidth = 0.200
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.501
    SET rptsd->m_height = 0.219
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(255,255,128))
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(uar_i18ngetmessage(_hi18nhandle,
       "FieldName028_CellName49",build2("Avg TAT (Discharge to Final):",char(0))),char(0)))
    SET oldbackcolor = uar_rptresetbackcolor(_hreport)
    SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.500),offsety,(offsetx+ 2.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.000),offsety,(offsetx+ 4.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (fieldname028html(dummy=i2) =null WITH protect)
  SET _htmlfileinfo->file_buf = build2("<tr>","<td class='FieldName0270' colspan='4'>",
   uar_i18ngetmessage(_hi18nhandle,"BHS_HIM_PROD_ANALYSIS_SUM_NGRP_CellName49",
    "Avg TAT (Discharge to Final):"),"</td>","<td class='FieldName0271' colspan='2'>",
   avgtatperuserdisplay,"</td>","<td class='FieldName0272' colspan='4'>","","</td>",
   "</tr>")
  SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
 END ;Subroutine
 SUBROUTINE (fieldname029(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname029abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (fieldname029abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.220000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 288
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 6.000
    SET rptsd->m_height = 0.230
    SET _oldfont = uar_rptsetfont(_hreport,_times100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(255,255,128))
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
    SET oldbackcolor = uar_rptresetbackcolor(_hreport)
    SET rptsd->m_flags = 320
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 2.501)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.230
    SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(255,255,128))
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(avgtattaskperuserdisplay,char(0)))
    SET oldbackcolor = uar_rptresetbackcolor(_hreport)
    SET rptsd->m_flags = 288
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdleftborder
    SET rptsd->m_paddingwidth = 0.200
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.501
    SET rptsd->m_height = 0.230
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(255,255,128))
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(uar_i18ngetmessage(_hi18nhandle,
       "FieldName029_CellName9",build2("Avg TAT Task (Create to Final):",char(0))),char(0)))
    SET oldbackcolor = uar_rptresetbackcolor(_hreport)
    SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.500),offsety,(offsetx+ 2.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.000),offsety,(offsetx+ 4.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (fieldname029html(dummy=i2) =null WITH protect)
  SET _htmlfileinfo->file_buf = build2("<tr>","<td class='FieldName0270' colspan='4'>",
   uar_i18ngetmessage(_hi18nhandle,"BHS_HIM_PROD_ANALYSIS_SUM_NGRP_CellName9",
    "Avg TAT Task (Create to Final):"),"</td>","<td class='FieldName0271' colspan='2'>",
   avgtattaskperuserdisplay,"</td>","<td class='FieldName0272' colspan='4'>","","</td>",
   "</tr>")
  SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
 END ;Subroutine
 SUBROUTINE (fieldname030(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname030abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (fieldname030abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.110000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 288
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 10.001
    SET rptsd->m_height = 0.115
    SET _oldfont = uar_rptsetfont(_hreport,_times100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (fieldname030html(dummy=i2) =null WITH protect)
  SET _htmlfileinfo->file_buf = build2("<tr>","<td class='FieldName051' colspan='10'>","","</td>",
   "</tr>")
  SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
 END ;Subroutine
 SUBROUTINE (fieldname036(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname036abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (fieldname036abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.270000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 272
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 10.001
    SET rptsd->m_height = 0.271
    SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen25s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(uar_i18ngetmessage(_hi18nhandle,
       "FieldName036_EndOfReport",build2("**END OF REPORT**",char(0))),char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (fieldname036html(dummy=i2) =null WITH protect)
  SET _htmlfileinfo->file_buf = build2("<tr>","<td class='FieldName0360' colspan='10'>",
   uar_i18ngetmessage(_hi18nhandle,"BHS_HIM_PROD_ANALYSIS_SUM_NGRP_EndOfReport","**END OF REPORT**"),
   "</td>","</tr>")
  SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   IF (_bsubreport=0)
    IF (_bgeneratehtml=1)
     SET _htmlfileinfo->file_name = _sendto
     SET _htmlfileinfo->file_buf = "w+b"
     SET _htmlfilestat = cclio("OPEN",_htmlfileinfo)
     SET _htmlfileinfo->file_buf = "<html><head><META content=CCLLINK,APPLINK name=discern /></head>"
     SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
    ELSE
     SET rptreport->m_recsize = 104
     SET rptreport->m_reportname = "BHS_HIM_PROD_ANALYSIS_SUM_NGRP"
     SET rptreport->m_pagewidth = 8.50
     SET rptreport->m_pageheight = 11.00
     SET rptreport->m_orientation = rpt_landscape
     SET rptreport->m_marginleft = 0.50
     SET rptreport->m_marginright = 0.50
     SET rptreport->m_margintop = 0.50
     SET rptreport->m_marginbottom = 0.50
     SET rptreport->m_horzprintoffset = _xshift
     SET rptreport->m_vertprintoffset = _yshift
     SET rptreport->m_dioflag = 0
     SET rptreport->m_needsnotonaskharabic = 0
     SELECT INTO "NL:"
      p_printer_type_cdf = uar_get_code_meaning(p.printer_type_cd)
      FROM output_dest o,
       device d,
       printer p
      PLAN (o
       WHERE cnvtupper(o.name)=cnvtupper(trim(_sendto)))
       JOIN (d
       WHERE d.device_cd=o.device_cd)
       JOIN (p
       WHERE p.device_cd=d.device_cd)
      DETAIL
       CASE (cnvtint(p_printer_type_cdf))
        OF 8:
        OF 26:
        OF 29:
         _outputtype = rpt_postscript,_xdiv = 72,_ydiv = 72
        OF 16:
        OF 20:
        OF 24:
         _outputtype = rpt_zebra,_xdiv = 203,_ydiv = 203
        OF 42:
         _outputtype = rpt_zebra300,_xdiv = 300,_ydiv = 300
        OF 43:
         _outputtype = rpt_zebra600,_xdiv = 600,_ydiv = 600
        OF 32:
        OF 18:
        OF 19:
        OF 27:
        OF 31:
         _outputtype = rpt_intermec,_xdiv = 203,_ydiv = 203
        OF 45:
         _outputtype = rpt_intermec_dp203,_xdiv = 203,_ydiv = 203
        OF 46:
         _outputtype = rpt_intermec_dp300,_xdiv = 300,_ydiv = 300
        ELSE
         _xdiv = 1,_ydiv = 1
       ENDCASE
       _diotype = cnvtint(p_printer_type_cdf), _sendto = d.name
       IF (_xdiv > 1)
        rptreport->m_horzprintoffset = (cnvtreal(o.label_xpos)/ _xdiv)
       ENDIF
       IF (_xdiv > 1)
        rptreport->m_vertprintoffset = (cnvtreal(o.label_ypos)/ _ydiv)
       ENDIF
      WITH nocounter
     ;end select
     SET _yoffset = rptreport->m_margintop
     SET _xoffset = rptreport->m_marginleft
     SET _hreport = uar_rptcreatereport(rptreport,_outputtype,rpt_inches)
     SET _rpterr = uar_rptseterrorlevel(_hreport,rpt_error)
     SET _rptstat = uar_rptstartreport(_hreport)
     SET _rptpage = uar_rptstartpage(_hreport)
    ENDIF
   ENDIF
   CALL _createfonts(0)
   CALL _createpens(0)
 END ;Subroutine
 SUBROUTINE (section(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
  IF (ncalc=rpt_render)
   CALL __main(0)
  ENDIF
  RETURN(_yoffset)
 END ;Subroutine
 SUBROUTINE (fieldname0html(dummy=i2) =null WITH public)
   CALL mainhtml(0)
 END ;Subroutine
 SUBROUTINE _createfonts(dummy)
   SET rptfont->m_recsize = 62
   SET rptfont->m_fontname = rpt_times
   SET rptfont->m_pointsize = 10
   SET rptfont->m_bold = rpt_off
   SET rptfont->m_italic = rpt_off
   SET rptfont->m_underline = rpt_off
   SET rptfont->m_strikethrough = rpt_off
   SET rptfont->m_rgbcolor = rpt_black
   SET _times100 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_bold = rpt_on
   SET rptfont->m_italic = rpt_on
   SET rptfont->m_rgbcolor = rpt_red
   SET _times10bi255 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 12
   SET rptfont->m_rgbcolor = uar_rptencodecolor(0,0,160)
   SET _times12bi10485760 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_italic = rpt_off
   SET rptfont->m_rgbcolor = uar_rptencodecolor(126,126,126)
   SET _times12b8289918 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 10
   SET rptfont->m_rgbcolor = rpt_black
   SET _times10b0 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penwidth = 0.000
   SET _pen0s0c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penwidth = 0.025
   SET _pen25s0c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 SET _lretval = uar_i18nlocalizationinit(_hi18nhandle,curprog,"",curcclrev)
 CALL initializereport(0)
 SET _bishtml = validate(_htmlfileinfo->file_desc,0)
 IF (_bishtml=0)
  CALL main(0)
 ELSE
  CALL mainhtml(0)
 ENDIF
 CALL finalizereport(_sendto)
END GO
