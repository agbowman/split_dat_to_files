CREATE PROGRAM bhs_him_prod_analysis_det_ngrp
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
 DECLARE _rem__date_stamp__task_created__ = i4 WITH noconstant(1), protect
 DECLARE _remcellname22 = i4 WITH noconstant(1), protect
 DECLARE _remcellname21 = i4 WITH noconstant(1), protect
 DECLARE _remcellname17 = i4 WITH noconstant(1), protect
 DECLARE _remcellname16 = i4 WITH noconstant(1), protect
 DECLARE _remcellname15 = i4 WITH noconstant(1), protect
 DECLARE _bcontfieldname013 = i2 WITH noconstant(0), protect
 DECLARE _rem__date_stamp__task_created__ = i4 WITH noconstant(1), protect
 DECLARE _remcellname60 = i4 WITH noconstant(1), protect
 DECLARE _remcellname59 = i4 WITH noconstant(1), protect
 DECLARE _remcellname56 = i4 WITH noconstant(1), protect
 DECLARE _remcellname55 = i4 WITH noconstant(1), protect
 DECLARE _remcellname54 = i4 WITH noconstant(1), protect
 DECLARE _bcontfieldname020 = i2 WITH noconstant(0), protect
 DECLARE _remtask_hist_task_create_dt_tm01 = i4 WITH noconstant(1), protect
 DECLARE _remtatcreatetofinalrowone = i4 WITH noconstant(1), protect
 DECLARE _remtatdischargetofinalrowone = i4 WITH noconstant(1), protect
 DECLARE _remlosdisplayrowone = i4 WITH noconstant(1), protect
 DECLARE _remdichargedaterowone = i4 WITH noconstant(1), protect
 DECLARE _rempatienttyperowone = i4 WITH noconstant(1), protect
 DECLARE _remfinrowone = i4 WITH noconstant(1), protect
 DECLARE _remmrnrowone = i4 WITH noconstant(1), protect
 DECLARE _rempatientnamerowone = i4 WITH noconstant(1), protect
 DECLARE _bcontfieldname021 = i2 WITH noconstant(0), protect
 DECLARE _remtask_hist_task_create_dt_tm__ = i4 WITH noconstant(1), protect
 DECLARE _remtatcreatetofinalrowtwo = i4 WITH noconstant(1), protect
 DECLARE _remtatdischargetofinalrowtwo = i4 WITH noconstant(1), protect
 DECLARE _remlosdisplayrowtwo = i4 WITH noconstant(1), protect
 DECLARE _remdichargedaterowtwo = i4 WITH noconstant(1), protect
 DECLARE _rempatienttyperowtwo = i4 WITH noconstant(1), protect
 DECLARE _remfinrowtwo = i4 WITH noconstant(1), protect
 DECLARE _remmrnrowtwo = i4 WITH noconstant(1), protect
 DECLARE _rempatientnamerowtwo = i4 WITH noconstant(1), protect
 DECLARE _bcontfieldname022 = i2 WITH noconstant(0), protect
 DECLARE _remcellname45 = i4 WITH noconstant(1), protect
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
   SELECT INTO "nl:"
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
     task_queue_cd, task_hist_task_create_dt_tm
    HEAD REPORT
     _d0 = patient_name, _d1 = disch_dt_tm, _d2 = los_days,
     _d3 = tat_create_to_final, _d4 = tat_discharge_to_final, _d5 = mrn,
     _d6 = fin, _d7 = user_name, _d8 = patient_type_name,
     _d9 = task_queue_name, _d10 = user_username, _d11 = task_hist_task_create_dt_tm,
     _fenddetail = (rptreport->m_pagewidth - rptreport->m_marginbottom), daterange =
     getdaterangedisplay(dates,him_dash), totalchartsperorganization = 0,
     totalchartsperuser = 0, totalchartsperqueue = 0, totallengthofstay = 0,
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
     dummy_val = fieldname012(rpt_render), _bcontfieldname013 = 0, dummy_val = fieldname013(
      rpt_render,((rptreport->m_pagewidth - rptreport->m_marginbottom) - _yoffset),_bcontfieldname013
      )
    HEAD user_name
     _fdrawheight = fieldname016(rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = fieldname016(rpt_render)
    HEAD user_id
     usernamedisplay = user_name, totalchartsperuser = 0, _fdrawheight = fieldname017(rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = fieldname017(rpt_render)
    HEAD task_queue_name
     taskqueuedisplay = task_queue_name, totalchartsperqueue = 0, totallengthofstay = 0,
     rowcount = 0, _fdrawheight = fieldname018(rpt_calcheight)
     IF (_fdrawheight > 0)
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight += fieldname019(rpt_calcheight)
      ENDIF
     ENDIF
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = fieldname018(rpt_render), _fdrawheight = fieldname019(rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = fieldname019(rpt_render)
    HEAD task_queue_cd
     _bcontfieldname020 = 0, bfirsttime = 1
     WHILE (((_bcontfieldname020=1) OR (bfirsttime=1)) )
       _bholdcontinue = _bcontfieldname020, _fdrawheight = fieldname020(rpt_calcheight,(_fenddetail
         - _yoffset),_bholdcontinue)
       IF (((_yoffset+ _fdrawheight) > _fenddetail))
        BREAK
       ELSEIF (_bholdcontinue=1
        AND _bcontfieldname020=0)
        BREAK
       ENDIF
       dummy_val = fieldname020(rpt_render,(_fenddetail - _yoffset),_bcontfieldname020), bfirsttime
        = 0
     ENDWHILE
    HEAD task_hist_task_create_dt_tm
     row + 0
    DETAIL
     patientnamerowone = patient_name
     IF (dataqualcount > 0)
      totalchartsperorganization += 1, totalchartsperuser += 1, totalchartsperqueue += 1,
      totallengthofstay += los_days, rowcount += 1
     ENDIF
     losdisplayrowone = trim(build(los_days),3), patientnamerowtwo = patient_name, losdisplayrowtwo
      = trim(build(los_days),3),
     _bcontfieldname021 = 0, bfirsttime = 1
     WHILE (((_bcontfieldname021=1) OR (bfirsttime=1)) )
       _bholdcontinue = _bcontfieldname021, _fdrawheight = fieldname021(rpt_calcheight,(_fenddetail
         - _yoffset),_bholdcontinue)
       IF (((_bholdcontinue=1) OR (_fdrawheight > 0)) )
        IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
         _bholdcontinue = 0, _fdrawheight += fieldname022(rpt_calcheight,((_fenddetail - _yoffset) -
          _fdrawheight),_bholdcontinue)
         IF (_bholdcontinue=1)
          _fdrawheight = (_fenddetail+ 1)
         ENDIF
        ENDIF
       ENDIF
       IF (((_yoffset+ _fdrawheight) > _fenddetail))
        BREAK
       ELSEIF (_bholdcontinue=1
        AND _bcontfieldname021=0)
        BREAK
       ENDIF
       dummy_val = fieldname021(rpt_render,(_fenddetail - _yoffset),_bcontfieldname021), bfirsttime
        = 0
     ENDWHILE
     _bcontfieldname022 = 0, bfirsttime = 1
     WHILE (((_bcontfieldname022=1) OR (bfirsttime=1)) )
       _bholdcontinue = _bcontfieldname022, _fdrawheight = fieldname022(rpt_calcheight,(_fenddetail
         - _yoffset),_bholdcontinue)
       IF (((_yoffset+ _fdrawheight) > _fenddetail))
        BREAK
       ELSEIF (_bholdcontinue=1
        AND _bcontfieldname022=0)
        BREAK
       ENDIF
       dummy_val = fieldname022(rpt_render,(_fenddetail - _yoffset),_bcontfieldname022), bfirsttime
        = 0
     ENDWHILE
    FOOT  task_hist_task_create_dt_tm
     row + 0
    FOOT  task_queue_cd
     totalchartsperqueuedisplay = build(totalchartsperqueue), totallosdisplay = build(
      totallengthofstay), _bcontfieldname024 = 0,
     bfirsttime = 1
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
     totalchartsperuserdisplay = build(totalchartsperuser), _fdrawheight = fieldname025(
      rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = fieldname025(rpt_render)
    FOOT  user_name
     row + 0
    FOOT REPORT
     _fdrawheight = fieldname027(rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      CALL pagebreak(0)
     ENDIF
     dummy_val = fieldname027(rpt_render)
    WITH nullreport, nocounter, memsort
   ;end select
 END ;Subroutine
 SUBROUTINE (mainhtml(ndummy=i2) =null WITH protect)
  DECLARE rpt_pageofpage = vc WITH noconstant("Page 1 of 1"), protect
  SELECT INTO "nl:"
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
    task_queue_cd, task_hist_task_create_dt_tm
   HEAD REPORT
    _d0 = patient_name, _d1 = disch_dt_tm, _d2 = los_days,
    _d3 = tat_create_to_final, _d4 = tat_discharge_to_final, _d5 = mrn,
    _d6 = fin, _d7 = user_name, _d8 = patient_type_name,
    _d9 = task_queue_name, _d10 = user_username, _d11 = task_hist_task_create_dt_tm,
    _htmlfileinfo->file_buf = build2("<STYLE>",
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
     " border-style: none none solid none;"," padding: 0.000in 0.000in 0.000in 0.200in;",
     " font:  bold 10pt Times;"," "," color: #000000;"," "," text-align: left;",
     " vertical-align: bottom;}",".FieldName0131 { border-width: 0.014in; border-color: #000000;",
     " border-style: none none solid none;"," padding: 0.000in 0.000in 0.000in 0.000in;",
     " font:  bold 10pt Times;",
     " "," color: #000000;"," "," text-align: right;"," vertical-align: bottom;}",
     ".FieldName0133 { border-width: 0.014in; border-color: #000000;",
     " border-style: none none solid none;"," padding: 0.000in 0.000in 0.000in 0.100in;",
     " font:  bold 10pt Times;"," ",
     " color: #000000;"," "," text-align: left;"," vertical-align: bottom;}",
     ".FieldName0134 { border-width: 0.014in; border-color: #000000;",
     " border-style: none none solid none;"," padding: 0.000in 0.000in 0.000in 0.000in;",
     " font:  bold 10pt Times;"," "," color: #000000;",
     " "," text-align: center;"," vertical-align: bottom;}",
     ".FieldName0135 { border-width: 0.014in; border-color: #000000;",
     " border-style: none none solid none;",
     " padding: 0.000in 0.000in 0.000in 0.000in;"," font:  bold 10pt Times;"," "," color: #000000;",
     " ",
     " text-align: right;"," vertical-align: bottom;}",
     ".FieldName0136 { border-width: 0.014in; border-color: #000000;",
     " border-style: none none solid none;"," padding: 0.000in 0.000in 0.000in 0.100in;",
     " font:  bold 10pt Times;"," "," color: #000000;"," "," text-align: right;",
     " vertical-align: bottom;}",".FieldName0160 { border-width: 0.014in; border-color: #000000;",
     " border-style: none none none none;"," padding: 0.000in 0.000in 0.000in 0.000in;",
     " font:  bold 10pt Times;",
     " "," color: #000000;"," "," text-align: left;"," vertical-align: middle;}",
     ".FieldName0172 { border-width: 0.014in; border-color: #000000;",
     " border-style: none none none none;"," padding: 0.000in 0.000in 0.000in 0.000in;",
     " font:  bold 10pt Times;"," ",
     " color: #000000;"," "," text-align: right;"," vertical-align: middle;}",
     ".FieldName0180 { border-width: 0.014in; border-color: #000000;",
     " border-style: none none none none;"," padding: 0.000in 0.000in 0.000in 0.100in;",
     " font:  bold 10pt Times;"," "," color: #000000;",
     " "," text-align: left;"," vertical-align: middle;}",
     ".FieldName0203 { border-width: 0.014in; border-color: #000000;",
     " border-style: none none solid none;",
     " padding: 0.000in 0.000in 0.000in 0.000in;"," font:  bold 10pt Times;"," "," color: #000000;",
     " ",
     " text-align: center;"," vertical-align: bottom;}",
     ".FieldName0210 { border-width: 0.014in; border-color: #000000;",
     " border-style: none none none none;"," padding: 0.000in 0.000in 0.000in 0.200in;",
     " font:   10pt Times;"," "," color: #000000;"," "," text-align: left;",
     " vertical-align: middle;}",".FieldName0211 { border-width: 0.014in; border-color: #000000;",
     " border-style: none none none none;"," padding: 0.000in 0.000in 0.000in 0.000in;",
     " font:   10pt Times;",
     " "," color: #000000;"," "," text-align: right;"," vertical-align: middle;}",
     ".FieldName0214 { border-width: 0.014in; border-color: #000000;",
     " border-style: none none none none;"," padding: 0.000in 0.000in 0.000in 0.000in;",
     " font:   10pt Times;"," ",
     " color: #000000;"," "," text-align: center;"," vertical-align: middle;}",
     ".FieldName0215 { border-width: 0.014in; border-color: #000000;",
     " border-style: none none none none;"," padding: 0.000in 0.050in 0.000in 0.000in;",
     " font:   10pt Times;"," "," color: #000000;",
     " "," text-align: right;"," vertical-align: middle;}",
     ".FieldName0216 { border-width: 0.014in; border-color: #000000;",
     " border-style: none none none none;",
     " padding: 0.000in 0.000in 0.000in 0.100in;"," font:   10pt Times;"," "," color: #000000;"," ",
     " text-align: right;"," vertical-align: middle;}",
     ".FieldName0220 { border-width: 0.014in; border-color: #000000;",
     " border-style: none none none none;"," padding: 0.000in 0.000in 0.000in 0.200in;",
     " font:   10pt Times;"," "," color: #000000;"," background: #e8e8e8;"," text-align: left;",
     " vertical-align: middle;}",".FieldName0221 { border-width: 0.014in; border-color: #000000;",
     " border-style: none none none none;"," padding: 0.000in 0.000in 0.000in 0.000in;",
     " font:   10pt Times;",
     " "," color: #000000;"," background: #e8e8e8;"," text-align: right;"," vertical-align: middle;}",
     ".FieldName0224 { border-width: 0.014in; border-color: #000000;",
     " border-style: none none none none;"," padding: 0.000in 0.000in 0.000in 0.000in;",
     " font:   10pt Times;"," ",
     " color: #000000;"," background: #e8e8e8;"," text-align: center;"," vertical-align: middle;}",
     ".FieldName0225 { border-width: 0.014in; border-color: #000000;",
     " border-style: none none none none;"," padding: 0.000in 0.050in 0.000in 0.000in;",
     " font:   10pt Times;"," "," color: #000000;",
     " background: #e8e8e8;"," text-align: right;"," vertical-align: middle;}",
     ".FieldName0226 { border-width: 0.014in; border-color: #000000;",
     " border-style: none none none none;",
     " padding: 0.000in 0.000in 0.000in 0.100in;"," font:   10pt Times;"," "," color: #000000;",
     " background: #e8e8e8;",
     " text-align: right;"," vertical-align: middle;}",
     ".FieldName0230 { border-width: 0.014in; border-color: #000000;",
     " border-style: none none none none;"," padding: 0.000in 0.000in 0.000in 0.200in;",
     " font:  bold 10pt Times;"," "," color: #000000;"," background: #ffffff;"," text-align: right;",
     " vertical-align: middle;}",".FieldName0240 { border-width: 0.014in; border-color: #000000;",
     " border-style: none none none none;"," padding: 0.000in 0.000in 0.000in 0.100in;",
     " font:  bold 10pt Times;",
     " "," color: #000000;"," background: #ffff80;"," text-align: left;"," vertical-align: middle;}",
     ".FieldName0241 { border-width: 0.014in; border-color: #000000;",
     " border-style: none none none none;"," padding: 0.000in 0.000in 0.000in 0.000in;",
     " font:   10pt Times;"," ",
     " color: #000000;"," background: #ffff80;"," text-align: left;"," vertical-align: middle;}",
     ".FieldName0242 { border-width: 0.014in; border-color: #000000;",
     " border-style: none none none none;"," padding: 0.000in 0.000in 0.000in 0.200in;",
     " font:  bold 10pt Times;"," "," color: #000000;",
     " background: #ffff80;"," text-align: right;"," vertical-align: middle;}",
     ".FieldName0243 { border-width: 0.014in; border-color: #000000;",
     " border-style: none none none none;",
     " padding: 0.000in 0.000in 0.000in 0.000in;"," font:   10pt Times;"," "," color: #000000;",
     " background: #ffff80;",
     " text-align: center;"," vertical-align: middle;}",
     ".FieldName0250 { border-width: 0.014in; border-color: #000000;",
     " border-style: none none none none;"," padding: 0.000in 0.000in 0.000in 0.000in;",
     " font:  bold 10pt Times;"," "," color: #000000;"," background: #ffff80;"," text-align: left;",
     " vertical-align: middle;}",".FieldName0270 { border-width: 0.025in; border-color: #000000;",
     " border-style: none none none none;"," padding: 0.000in 0.000in 0.000in 0.000in;",
     " font:  bold 10pt Times;",
     " "," color: #000000;"," "," text-align: center;"," vertical-align: middle;}",
     "</STYLE>"), _htmlfilestat = cclio("WRITE",_htmlfileinfo), _htmlfileinfo->file_buf =
    "<table width='100%'><caption>",
    _htmlfilestat = cclio("WRITE",_htmlfileinfo), _htmlfileinfo->file_buf = build2(
     "<colgroup span=19>","<col width=94/>","<col width=12/>","<col width=44/>","<col width=27/>",
     "<col width=70/>","<col width=41/>","<col width=6/>","<col width=30/>","<col width=51/>",
     "<col width=19/>","<col width=35/>","<col width=7/>","<col width=97/>","<col width=1/>",
     "<col width=67/>","<col width=74/>","<col width=50/>","<col width=124/>","<col width=135/>",
     "</colgroup>"), _htmlfilestat = cclio("WRITE",_htmlfileinfo),
    daterange = getdaterangedisplay(dates,him_dash), totalchartsperorganization = 0,
    totalchartsperuser = 0,
    totalchartsperqueue = 0, totallengthofstay = 0, rowcount = 0,
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
    _htmlfileinfo->file_buf = "</thead>", _htmlfilestat = cclio("WRITE",_htmlfileinfo), _htmlfileinfo
    ->file_buf = "<tbody>",
    _htmlfilestat = cclio("WRITE",_htmlfileinfo)
   HEAD user_name
    dummy_val = fieldname016html(0)
   HEAD user_id
    usernamedisplay = user_name, totalchartsperuser = 0, dummy_val = fieldname017html(0)
   HEAD task_queue_name
    taskqueuedisplay = task_queue_name, totalchartsperqueue = 0, totallengthofstay = 0,
    rowcount = 0, dummy_val = fieldname018html(0), dummy_val = fieldname019html(0)
   HEAD task_queue_cd
    dummy_val = fieldname020html(0)
   DETAIL
    patientnamerowone = patient_name
    IF (dataqualcount > 0)
     totalchartsperorganization += 1, totalchartsperuser += 1, totalchartsperqueue += 1,
     totallengthofstay += los_days, rowcount += 1
    ENDIF
    losdisplayrowone = trim(build(los_days),3), patientnamerowtwo = patient_name, losdisplayrowtwo =
    trim(build(los_days),3),
    dummy_val = fieldname021html(0), dummy_val = fieldname022html(0)
   FOOT  task_queue_cd
    totalchartsperqueuedisplay = build(totalchartsperqueue), totallosdisplay = build(
     totallengthofstay), dummy_val = fieldname024html(0)
   FOOT  user_id
    totalchartsperuserdisplay = build(totalchartsperuser), dummy_val = fieldname025html(0)
   FOOT REPORT
    _htmlfileinfo->file_buf = "</tbody>", _htmlfilestat = cclio("WRITE",_htmlfileinfo), _htmlfileinfo
    ->file_buf = "<tfoot>",
    _htmlfilestat = cclio("WRITE",_htmlfileinfo), dummy_val = fieldname027html(0), _htmlfileinfo->
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
  SET _htmlfileinfo->file_buf = build2("<tr>","<td class='FieldName000' colspan='19'>",cclbuildhlink(
    him_program_name,him_render_params,him_window,"Printer Friendly Version"),"</td>","</tr>")
  SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
 END ;Subroutine
 SUBROUTINE (fieldname01(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname01abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (fieldname01abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.440000), private
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
    SET rptsd->m_height = 0.438
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
  SET _htmlfileinfo->file_buf = build2("<tr>","<td class='FieldName010' colspan='19'>",
   uar_i18ngetmessage(_hi18nhandle,"BHS_HIM_PROD_ANALYSIS_DET_NGRP_CellName0",
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
       "FieldName02_CellName1",build2("Detailed Report",char(0))),char(0)))
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
  SET _htmlfileinfo->file_buf = build2("<tr>","<td class='FieldName020' colspan='19'>",
   uar_i18ngetmessage(_hi18nhandle,"BHS_HIM_PROD_ANALYSIS_DET_NGRP_CellName1","Detailed Report"),
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
  SET _htmlfileinfo->file_buf = build2("<tr>","<td class='FieldName030' colspan='19'>",daterange,
   "</td>","</tr>")
  SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
 END ;Subroutine
 SUBROUTINE (fieldname04(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname04abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (fieldname04abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.190000), private
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
    SET rptsd->m_height = 0.188
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
  SET _htmlfileinfo->file_buf = build2("<tr>","<td class='FieldName040' colspan='19'>",blank,"</td>",
   "</tr>")
  SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
 END ;Subroutine
 SUBROUTINE (fieldname05(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname05abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (fieldname05abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
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
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(vctodaydatetime,char(0)))
    SET rptsd->m_flags = 256
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.188
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
  SET _htmlfileinfo->file_buf = build2("<tr>","<td class='FieldName050' colspan='3'>",i18ndateprinted,
   "</td>","<td class='FieldName051' colspan='16'>",
   vctodaydatetime,"</td>","</tr>")
  SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
 END ;Subroutine
 SUBROUTINE (fieldname06(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname06abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (fieldname06abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.170000), private
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
    SET rptsd->m_height = 0.178
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
    SET rptsd->m_height = 0.178
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
  SET _htmlfileinfo->file_buf = build2("<tr>","<td class='FieldName050' colspan='3'>",i18nuserprinted,
   "</td>","<td class='FieldName051' colspan='16'>",
   vcuser,"</td>","</tr>")
  SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
 END ;Subroutine
 SUBROUTINE (fieldname07(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname07abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (fieldname07abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.170000), private
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
    SET rptsd->m_height = 0.178
    SET _oldfont = uar_rptsetfont(_hreport,_times100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.178
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
  SET _htmlfileinfo->file_buf = build2("<tr>","<td class='FieldName050' colspan='3'>",
   i18npromptsfilters,"</td>","<td class='FieldName071' colspan='16'>",
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
   DECLARE sectionheight = f8 WITH noconstant(0.240000), private
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
    SET _htmlfileinfo->file_buf = build2("<tr>","<td class='FieldName040' colspan='3'>","","</td>",
     "<td class='FieldName050' colspan='3'>",
     i18nfacilities,"</td>","<td class='FieldName082' colspan='13'>",facilitylist,"</td>",
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
  SET _htmlfileinfo->file_buf = build2("<tr>","<td class='FieldName040' colspan='3'>","","</td>",
   "<td class='FieldName050' colspan='3'>",
   uar_i18ngetmessage(_hi18nhandle,"BHS_HIM_PROD_ANALYSIS_DET_NGRP_CellName5","User Name(s):"),
   "</td>","<td class='FieldName082' colspan='13'>",userlist,"</td>",
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
   DECLARE sectionheight = f8 WITH noconstant(0.200000), private
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
  SET _htmlfileinfo->file_buf = build2("<tr>","<td class='FieldName040' colspan='3'>","","</td>",
   "<td class='FieldName050' colspan='3'>",
   uar_i18ngetmessage(_hi18nhandle,"BHS_HIM_PROD_ANALYSIS_DET_NGRP_CellName7","Task Queue(s):"),
   "</td>","<td class='FieldName082' colspan='13'>",taskqueuelist,"</td>",
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
  SET _htmlfileinfo->file_buf = build2("<tr>","<td class='FieldName040' colspan='3'>","","</td>",
   "<td class='FieldName050' colspan='3'>",
   i18ndaterange,"</td>","<td class='FieldName071' colspan='13'>",getdaterangedisplay(dates,
    him_prompt),"</td>",
   "</tr>")
  SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
 END ;Subroutine
 SUBROUTINE (fieldname012(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname012abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (fieldname012abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.170000), private
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
    SET rptsd->m_height = 0.167
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
    SET _htmlfileinfo->file_buf = build2("<tr>","<td class='FieldName0120' colspan='19'>",
     rpt_pageofpage,"</td>","</tr>")
    SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
   ENDIF
 END ;Subroutine
 SUBROUTINE (fieldname013(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname013abs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (fieldname013abs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =f8 WITH
  protect)
   DECLARE sectionheight = f8 WITH noconstant(0.380000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight___date_stamp__task_created__ = f8 WITH noconstant(0.0), private
   DECLARE drawheight_cellname22 = f8 WITH noconstant(0.0), private
   DECLARE drawheight_cellname21 = f8 WITH noconstant(0.0), private
   DECLARE drawheight_cellname17 = f8 WITH noconstant(0.0), private
   DECLARE drawheight_cellname16 = f8 WITH noconstant(0.0), private
   DECLARE drawheight_cellname15 = f8 WITH noconstant(0.0), private
   DECLARE ____date_stamp__task_created__ = vc WITH noconstant(build(uar_i18ngetmessage(_hi18nhandle,
      "FieldName013___Date_Stamp__Task_Created__",build2("Date Stamp (Task Created)",char(0))),char(0
      ))), protect
   DECLARE __cellname22 = vc WITH noconstant(build(uar_i18ngetmessage(_hi18nhandle,
      "FieldName013_CellName22",build2("TAT Task (Create to Final)",char(0))),char(0))), protect
   DECLARE __cellname21 = vc WITH noconstant(build(uar_i18ngetmessage(_hi18nhandle,
      "FieldName013_CellName21",build2("TAT (Discharge to Final)",char(0))),char(0))), protect
   DECLARE __cellname17 = vc WITH noconstant(build(uar_i18ngetmessage(_hi18nhandle,
      "FieldName013_CellName17",build2("LOS (Days)",char(0))),char(0))), protect
   DECLARE __cellname16 = vc WITH noconstant(build(uar_i18ngetmessage(_hi18nhandle,
      "FieldName013_CellName16",build2("Discharge Date",char(0))),char(0))), protect
   DECLARE __cellname15 = vc WITH noconstant(build(uar_i18ngetmessage(_hi18nhandle,
      "FieldName013_CellName15",build2("Patient Type",char(0))),char(0))), protect
   IF ( NOT (rowcount > 0))
    RETURN(0.0)
   ENDIF
   IF (bcontinue=0)
    SET _rem__date_stamp__task_created__ = 1
    SET _remcellname22 = 1
    SET _remcellname21 = 1
    SET _remcellname17 = 1
    SET _remcellname16 = 1
    SET _remcellname15 = 1
   ENDIF
   SET rptsd->m_flags = 1093
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.100
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 8.490)
   SET rptsd->m_width = 1.511
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdrem__date_stamp__task_created__ = _rem__date_stamp__task_created__
   IF (_rem__date_stamp__task_created__ > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _rem__date_stamp__task_created__,((size(____date_stamp__task_created__) -
       _rem__date_stamp__task_created__)+ 1),____date_stamp__task_created__)))
    SET drawheight___date_stamp__task_created__ = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _rem__date_stamp__task_created__ = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_rem__date_stamp__task_created__,((size(
        ____date_stamp__task_created__) - _rem__date_stamp__task_created__)+ 1),
       ____date_stamp__task_created__)))))
     SET _rem__date_stamp__task_created__ += rptsd->m_drawlength
    ELSE
     SET _rem__date_stamp__task_created__ = 0
    ENDIF
    SET growsum += _rem__date_stamp__task_created__
   ENDIF
   SET rptsd->m_flags = 1093
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.100
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 7.250)
   SET rptsd->m_width = 1.240
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
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
   SET rptsd->m_x = (offsetx+ 6.011)
   SET rptsd->m_width = 1.240
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
   SET rptsd->m_x = (offsetx+ 5.334)
   SET rptsd->m_width = 0.678
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
   SET rptsd->m_flags = 1045
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 4.365)
   SET rptsd->m_width = 0.969
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremcellname16 = _remcellname16
   IF (_remcellname16 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remcellname16,((size(
        __cellname16) - _remcellname16)+ 1),__cellname16)))
    SET drawheight_cellname16 = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remcellname16 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remcellname16,((size(__cellname16) -
       _remcellname16)+ 1),__cellname16)))))
     SET _remcellname16 += rptsd->m_drawlength
    ELSE
     SET _remcellname16 = 0
    ENDIF
    SET growsum += _remcellname16
   ENDIF
   SET rptsd->m_flags = 1061
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.100
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 3.240)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremcellname15 = _remcellname15
   IF (_remcellname15 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remcellname15,((size(
        __cellname15) - _remcellname15)+ 1),__cellname15)))
    SET drawheight_cellname15 = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remcellname15 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remcellname15,((size(__cellname15) -
       _remcellname15)+ 1),__cellname15)))))
     SET _remcellname15 += rptsd->m_drawlength
    ELSE
     SET _remcellname15 = 0
    ENDIF
    SET growsum += _remcellname15
   ENDIF
   SET rptsd->m_flags = 1092
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.100
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 8.490)
   SET rptsd->m_width = 1.511
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render
    AND _holdrem__date_stamp__task_created__ > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _holdrem__date_stamp__task_created__,((size(____date_stamp__task_created__) -
       _holdrem__date_stamp__task_created__)+ 1),____date_stamp__task_created__)))
   ELSE
    SET _rem__date_stamp__task_created__ = _holdrem__date_stamp__task_created__
   ENDIF
   SET rptsd->m_flags = 1092
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.100
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 7.250)
   SET rptsd->m_width = 1.240
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
   SET rptsd->m_x = (offsetx+ 6.011)
   SET rptsd->m_width = 1.240
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
   SET rptsd->m_x = (offsetx+ 5.334)
   SET rptsd->m_width = 0.678
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render
    AND _holdremcellname17 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremcellname17,((size(
        __cellname17) - _holdremcellname17)+ 1),__cellname17)))
   ELSE
    SET _remcellname17 = _holdremcellname17
   ENDIF
   SET rptsd->m_flags = 1044
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 4.365)
   SET rptsd->m_width = 0.969
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render
    AND _holdremcellname16 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremcellname16,((size(
        __cellname16) - _holdremcellname16)+ 1),__cellname16)))
   ELSE
    SET _remcellname16 = _holdremcellname16
   ENDIF
   SET rptsd->m_flags = 1060
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.100
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 3.240)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render
    AND _holdremcellname15 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremcellname15,((size(
        __cellname15) - _holdremcellname15)+ 1),__cellname15)))
   ELSE
    SET _remcellname15 = _holdremcellname15
   ENDIF
   SET rptsd->m_flags = 1088
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.469)
   SET rptsd->m_width = 0.771
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(uar_i18ngetmessage(_hi18nhandle,
       "FieldName013_CellName14",build2("FIN",char(0))),char(0)))
   ENDIF
   SET rptsd->m_flags = 1088
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.771)
   SET rptsd->m_width = 0.698
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(uar_i18ngetmessage(_hi18nhandle,
       "FieldName013_CellName13",build2("MRN",char(0))),char(0)))
   ENDIF
   SET rptsd->m_flags = 1056
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.200
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.771
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(uar_i18ngetmessage(_hi18nhandle,
       "FieldName013_CellName12",build2("Patient Name",char(0))),char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.771),offsety,(offsetx+ 1.771),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.469),offsety,(offsetx+ 2.469),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.240),offsety,(offsetx+ 3.240),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.365),offsety,(offsetx+ 4.365),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.333),offsety,(offsetx+ 5.333),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.010),offsety,(offsetx+ 6.010),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.250),offsety,(offsetx+ 7.250),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.490),offsety,(offsetx+ 8.490),(offsety+
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
 SUBROUTINE (fieldname013html(dummy=i2) =null WITH protect)
   IF (rowcount > 0)
    SET _htmlfileinfo->file_buf = build2("<tr>","<td class='FieldName0130' colspan='4'>",
     uar_i18ngetmessage(_hi18nhandle,"BHS_HIM_PROD_ANALYSIS_DET_NGRP_CellName12","Patient Name"),
     "</td>","<td class='FieldName0131' colspan='1'>",
     uar_i18ngetmessage(_hi18nhandle,"BHS_HIM_PROD_ANALYSIS_DET_NGRP_CellName13","MRN"),"</td>",
     "<td class='FieldName0131' colspan='3'>",uar_i18ngetmessage(_hi18nhandle,
      "BHS_HIM_PROD_ANALYSIS_DET_NGRP_CellName14","FIN"),"</td>",
     "<td class='FieldName0133' colspan='4'>",uar_i18ngetmessage(_hi18nhandle,
      "BHS_HIM_PROD_ANALYSIS_DET_NGRP_CellName15","Patient Type"),"</td>",
     "<td class='FieldName0134' colspan='1'>",uar_i18ngetmessage(_hi18nhandle,
      "BHS_HIM_PROD_ANALYSIS_DET_NGRP_CellName16","Discharge Date"),
     "</td>","<td class='FieldName0135' colspan='2'>",uar_i18ngetmessage(_hi18nhandle,
      "BHS_HIM_PROD_ANALYSIS_DET_NGRP_CellName17","LOS (Days)"),"</td>",
     "<td class='FieldName0136' colspan='2'>",
     uar_i18ngetmessage(_hi18nhandle,"BHS_HIM_PROD_ANALYSIS_DET_NGRP_CellName21",
      "TAT (Discharge to Final)"),"</td>","<td class='FieldName0136' colspan='1'>",uar_i18ngetmessage
     (_hi18nhandle,"BHS_HIM_PROD_ANALYSIS_DET_NGRP_CellName22","TAT Task (Create to Final)"),"</td>",
     "<td class='FieldName0136' colspan='1'>","Date Stamp (Task Created)","</td>","</tr>")
    SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
   ENDIF
 END ;Subroutine
 SUBROUTINE (fieldname016(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname016abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (fieldname016abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.170000), private
   IF ( NOT (0))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 256
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdleftborder
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 10.001
    SET rptsd->m_height = 0.167
    SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(uar_i18ngetmessage(_hi18nhandle,
       "FieldName016_CellName25",build2("",char(0))),char(0)))
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
   DECLARE sectionheight = f8 WITH noconstant(0.190000), private
   DECLARE __user_username_ = vc WITH noconstant(build(user_username,char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 256
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 4.292)
    SET rptsd->m_width = 5.709
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_times100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__user_username_)
    SET rptsd->m_flags = 320
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 3.750)
    SET rptsd->m_width = 0.542
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(uar_i18ngetmessage(_hi18nhandle,
       "FieldName017_field017c",build2("User ID:",char(0))),char(0)))
    SET rptsd->m_flags = 256
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.938)
    SET rptsd->m_width = 2.813
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(usernamedisplay,char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdleftborder
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.938
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(uar_i18ngetmessage(_hi18nhandle,
       "FieldName017_CellName23",build2("User Name:",char(0))),char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.938),offsety,(offsetx+ 0.938),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.750),offsety,(offsetx+ 3.750),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.292),offsety,(offsetx+ 4.292),(offsety+
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
  SET _htmlfileinfo->file_buf = build2("<tr>","<td class='FieldName0160' colspan='1'>",
   uar_i18ngetmessage(_hi18nhandle,"BHS_HIM_PROD_ANALYSIS_DET_NGRP_CellName23","User Name:"),"</td>",
   "<td class='FieldName071' colspan='8'>",
   usernamedisplay,"</td>","<td class='FieldName0172' colspan='2'>",uar_i18ngetmessage(_hi18nhandle,
    "BHS_HIM_PROD_ANALYSIS_DET_NGRP_field017c","User ID:"),"</td>",
   "<td class='FieldName071' colspan='8'>",user_username,"</td>","</tr>")
  SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
 END ;Subroutine
 SUBROUTINE (fieldname018(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname018abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (fieldname018abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.110000), private
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
    SET rptsd->m_height = 0.115
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
   IF (0)
    EXECUTE NULL ;noop
   ENDIF
 END ;Subroutine
 SUBROUTINE (fieldname019(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname019abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (fieldname019abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.190000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 256
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 1.063)
    SET rptsd->m_width = 8.938
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_times100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(taskqueuedisplay,char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdleftborder
    SET rptsd->m_paddingwidth = 0.100
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.063
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(uar_i18ngetmessage(_hi18nhandle,
       "FieldName019_CellName24",build2("Task Queue:",char(0))),char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.063),offsety,(offsetx+ 1.063),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (fieldname019html(dummy=i2) =null WITH protect)
  SET _htmlfileinfo->file_buf = build2("<tr>","<td class='FieldName0180' colspan='2'>",
   uar_i18ngetmessage(_hi18nhandle,"BHS_HIM_PROD_ANALYSIS_DET_NGRP_CellName24","Task Queue:"),"</td>",
   "<td class='FieldName071' colspan='17'>",
   taskqueuedisplay,"</td>","</tr>")
  SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
 END ;Subroutine
 SUBROUTINE (fieldname020(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname020abs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (fieldname020abs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =f8 WITH
  protect)
   DECLARE sectionheight = f8 WITH noconstant(0.320000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight___date_stamp__task_created__ = f8 WITH noconstant(0.0), private
   DECLARE drawheight_cellname60 = f8 WITH noconstant(0.0), private
   DECLARE drawheight_cellname59 = f8 WITH noconstant(0.0), private
   DECLARE drawheight_cellname56 = f8 WITH noconstant(0.0), private
   DECLARE drawheight_cellname55 = f8 WITH noconstant(0.0), private
   DECLARE drawheight_cellname54 = f8 WITH noconstant(0.0), private
   DECLARE ____date_stamp__task_created__ = vc WITH noconstant(build(uar_i18ngetmessage(_hi18nhandle,
      "FieldName020___Date_Stamp__Task_Created__",build2("Date Stamp (Task Created)",char(0))),char(0
      ))), protect
   DECLARE __cellname60 = vc WITH noconstant(build(uar_i18ngetmessage(_hi18nhandle,
      "FieldName020_CellName60",build2("TAT Task (Create to Final)",char(0))),char(0))), protect
   DECLARE __cellname59 = vc WITH noconstant(build(uar_i18ngetmessage(_hi18nhandle,
      "FieldName020_CellName59",build2("TAT (Discharge to Final)",char(0))),char(0))), protect
   DECLARE __cellname56 = vc WITH noconstant(build(uar_i18ngetmessage(_hi18nhandle,
      "FieldName020_CellName56",build2("LOS (Days)",char(0))),char(0))), protect
   DECLARE __cellname55 = vc WITH noconstant(build(uar_i18ngetmessage(_hi18nhandle,
      "FieldName020_CellName55",build2("Discharge Date",char(0))),char(0))), protect
   DECLARE __cellname54 = vc WITH noconstant(build(uar_i18ngetmessage(_hi18nhandle,
      "FieldName020_CellName54",build2("Patient Type",char(0))),char(0))), protect
   IF (bcontinue=0)
    SET _rem__date_stamp__task_created__ = 1
    SET _remcellname60 = 1
    SET _remcellname59 = 1
    SET _remcellname56 = 1
    SET _remcellname55 = 1
    SET _remcellname54 = 1
   ENDIF
   SET rptsd->m_flags = 1093
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.100
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 8.490)
   SET rptsd->m_width = 1.511
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdrem__date_stamp__task_created__ = _rem__date_stamp__task_created__
   IF (_rem__date_stamp__task_created__ > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _rem__date_stamp__task_created__,((size(____date_stamp__task_created__) -
       _rem__date_stamp__task_created__)+ 1),____date_stamp__task_created__)))
    SET drawheight___date_stamp__task_created__ = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _rem__date_stamp__task_created__ = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_rem__date_stamp__task_created__,((size(
        ____date_stamp__task_created__) - _rem__date_stamp__task_created__)+ 1),
       ____date_stamp__task_created__)))))
     SET _rem__date_stamp__task_created__ += rptsd->m_drawlength
    ELSE
     SET _rem__date_stamp__task_created__ = 0
    ENDIF
    SET growsum += _rem__date_stamp__task_created__
   ENDIF
   SET rptsd->m_flags = 1093
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.100
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 7.250)
   SET rptsd->m_width = 1.240
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
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
   SET rptsd->m_x = (offsetx+ 6.011)
   SET rptsd->m_width = 1.240
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
   SET rptsd->m_x = (offsetx+ 5.334)
   SET rptsd->m_width = 0.678
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
   SET rptsd->m_flags = 1045
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 4.365)
   SET rptsd->m_width = 0.969
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremcellname55 = _remcellname55
   IF (_remcellname55 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remcellname55,((size(
        __cellname55) - _remcellname55)+ 1),__cellname55)))
    SET drawheight_cellname55 = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remcellname55 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remcellname55,((size(__cellname55) -
       _remcellname55)+ 1),__cellname55)))))
     SET _remcellname55 += rptsd->m_drawlength
    ELSE
     SET _remcellname55 = 0
    ENDIF
    SET growsum += _remcellname55
   ENDIF
   SET rptsd->m_flags = 1045
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.100
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 3.240)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremcellname54 = _remcellname54
   IF (_remcellname54 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remcellname54,((size(
        __cellname54) - _remcellname54)+ 1),__cellname54)))
    SET drawheight_cellname54 = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remcellname54 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remcellname54,((size(__cellname54) -
       _remcellname54)+ 1),__cellname54)))))
     SET _remcellname54 += rptsd->m_drawlength
    ELSE
     SET _remcellname54 = 0
    ENDIF
    SET growsum += _remcellname54
   ENDIF
   SET rptsd->m_flags = 1092
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.100
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 8.490)
   SET rptsd->m_width = 1.511
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render
    AND _holdrem__date_stamp__task_created__ > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _holdrem__date_stamp__task_created__,((size(____date_stamp__task_created__) -
       _holdrem__date_stamp__task_created__)+ 1),____date_stamp__task_created__)))
   ELSE
    SET _rem__date_stamp__task_created__ = _holdrem__date_stamp__task_created__
   ENDIF
   SET rptsd->m_flags = 1092
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.100
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 7.250)
   SET rptsd->m_width = 1.240
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
   SET rptsd->m_x = (offsetx+ 6.011)
   SET rptsd->m_width = 1.240
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
   SET rptsd->m_x = (offsetx+ 5.334)
   SET rptsd->m_width = 0.678
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render
    AND _holdremcellname56 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremcellname56,((size(
        __cellname56) - _holdremcellname56)+ 1),__cellname56)))
   ELSE
    SET _remcellname56 = _holdremcellname56
   ENDIF
   SET rptsd->m_flags = 1044
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 4.365)
   SET rptsd->m_width = 0.969
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render
    AND _holdremcellname55 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremcellname55,((size(
        __cellname55) - _holdremcellname55)+ 1),__cellname55)))
   ELSE
    SET _remcellname55 = _holdremcellname55
   ENDIF
   SET rptsd->m_flags = 1044
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.100
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 3.240)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render
    AND _holdremcellname54 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremcellname54,((size(
        __cellname54) - _holdremcellname54)+ 1),__cellname54)))
   ELSE
    SET _remcellname54 = _holdremcellname54
   ENDIF
   SET rptsd->m_flags = 1088
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.469)
   SET rptsd->m_width = 0.771
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(uar_i18ngetmessage(_hi18nhandle,
       "FieldName020_CellName53",build2("FIN",char(0))),char(0)))
   ENDIF
   SET rptsd->m_flags = 1088
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.771)
   SET rptsd->m_width = 0.698
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(uar_i18ngetmessage(_hi18nhandle,
       "FieldName020_CellName52",build2("MRN",char(0))),char(0)))
   ENDIF
   SET rptsd->m_flags = 1056
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.200
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.771
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(uar_i18ngetmessage(_hi18nhandle,
       "FieldName020_CellName47",build2("Patient Name",char(0))),char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.771),offsety,(offsetx+ 1.771),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.469),offsety,(offsetx+ 2.469),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.240),offsety,(offsetx+ 3.240),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.365),offsety,(offsetx+ 4.365),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.333),offsety,(offsetx+ 5.333),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.010),offsety,(offsetx+ 6.010),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.250),offsety,(offsetx+ 7.250),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.490),offsety,(offsetx+ 8.490),(offsety+
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
 SUBROUTINE (fieldname020html(dummy=i2) =null WITH protect)
  SET _htmlfileinfo->file_buf = build2("<tr>","<td class='FieldName0130' colspan='4'>",
   uar_i18ngetmessage(_hi18nhandle,"BHS_HIM_PROD_ANALYSIS_DET_NGRP_CellName47","Patient Name"),
   "</td>","<td class='FieldName0131' colspan='1'>",
   uar_i18ngetmessage(_hi18nhandle,"BHS_HIM_PROD_ANALYSIS_DET_NGRP_CellName52","MRN"),"</td>",
   "<td class='FieldName0131' colspan='3'>",uar_i18ngetmessage(_hi18nhandle,
    "BHS_HIM_PROD_ANALYSIS_DET_NGRP_CellName53","FIN"),"</td>",
   "<td class='FieldName0203' colspan='4'>",uar_i18ngetmessage(_hi18nhandle,
    "BHS_HIM_PROD_ANALYSIS_DET_NGRP_CellName54","Patient Type"),"</td>",
   "<td class='FieldName0134' colspan='1'>",uar_i18ngetmessage(_hi18nhandle,
    "BHS_HIM_PROD_ANALYSIS_DET_NGRP_CellName55","Discharge Date"),
   "</td>","<td class='FieldName0135' colspan='2'>",uar_i18ngetmessage(_hi18nhandle,
    "BHS_HIM_PROD_ANALYSIS_DET_NGRP_CellName56","LOS (Days)"),"</td>",
   "<td class='FieldName0136' colspan='2'>",
   uar_i18ngetmessage(_hi18nhandle,"BHS_HIM_PROD_ANALYSIS_DET_NGRP_CellName59",
    "TAT (Discharge to Final)"),"</td>","<td class='FieldName0136' colspan='1'>",uar_i18ngetmessage(
    _hi18nhandle,"BHS_HIM_PROD_ANALYSIS_DET_NGRP_CellName60","TAT Task (Create to Final)"),"</td>",
   "<td class='FieldName0136' colspan='1'>","Date Stamp (Task Created)","</td>","</tr>")
  SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
 END ;Subroutine
 SUBROUTINE (fieldname021(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname021abs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (fieldname021abs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =f8 WITH
  protect)
   DECLARE sectionheight = f8 WITH noconstant(0.220000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_task_hist_task_create_dt_tm01 = f8 WITH noconstant(0.0), private
   DECLARE drawheight_tatcreatetofinalrowone = f8 WITH noconstant(0.0), private
   DECLARE drawheight_tatdischargetofinalrowone = f8 WITH noconstant(0.0), private
   DECLARE drawheight_losdisplayrowone = f8 WITH noconstant(0.0), private
   DECLARE drawheight_dichargedaterowone = f8 WITH noconstant(0.0), private
   DECLARE drawheight_patienttyperowone = f8 WITH noconstant(0.0), private
   DECLARE drawheight_finrowone = f8 WITH noconstant(0.0), private
   DECLARE drawheight_mrnrowone = f8 WITH noconstant(0.0), private
   DECLARE drawheight_patientnamerowone = f8 WITH noconstant(0.0), private
   DECLARE __task_hist_task_create_dt_tm01 = vc WITH noconstant(build(format(
      task_hist_task_create_dt_tm,"mm/dd/yyyy hh:mm;;Q"),char(0))), protect
   DECLARE __tatcreatetofinalrowone = vc WITH noconstant(build(cnvtminstodayshoursmins(
      tat_create_to_final),char(0))), protect
   DECLARE __tatdischargetofinalrowone = vc WITH noconstant(build(cnvtminstodayshoursmins(
      tat_discharge_to_final),char(0))), protect
   DECLARE __losdisplayrowone = vc WITH noconstant(build(losdisplayrowone,char(0))), protect
   DECLARE __dichargedaterowone = vc WITH noconstant(build(
     IF (disch_dt_tm != null) format(cnvtdatetime(disch_dt_tm),"@SHORTDATE;;Q")
     ELSE "--"
     ENDIF
     ,char(0))), protect
   DECLARE __patienttyperowone = vc WITH noconstant(build(patient_type_name,char(0))), protect
   DECLARE __finrowone = vc WITH noconstant(build(trim(fin,3),char(0))), protect
   DECLARE __mrnrowone = vc WITH noconstant(build(trim(mrn,3),char(0))), protect
   DECLARE __patientnamerowone = vc WITH noconstant(build(patientnamerowone,char(0))), protect
   IF ( NOT (mod(rowcount,2)=1))
    RETURN(0.0)
   ENDIF
   IF (bcontinue=0)
    SET _remtask_hist_task_create_dt_tm01 = 1
    SET _remtatcreatetofinalrowone = 1
    SET _remtatdischargetofinalrowone = 1
    SET _remlosdisplayrowone = 1
    SET _remdichargedaterowone = 1
    SET _rempatienttyperowone = 1
    SET _remfinrowone = 1
    SET _remmrnrowone = 1
    SET _rempatientnamerowone = 1
   ENDIF
   SET rptsd->m_flags = 325
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.100
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 8.490)
   SET rptsd->m_width = 1.511
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times100)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremtask_hist_task_create_dt_tm01 = _remtask_hist_task_create_dt_tm01
   IF (_remtask_hist_task_create_dt_tm01 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _remtask_hist_task_create_dt_tm01,((size(__task_hist_task_create_dt_tm01) -
       _remtask_hist_task_create_dt_tm01)+ 1),__task_hist_task_create_dt_tm01)))
    SET drawheight_task_hist_task_create_dt_tm01 = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remtask_hist_task_create_dt_tm01 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remtask_hist_task_create_dt_tm01,((size(
        __task_hist_task_create_dt_tm01) - _remtask_hist_task_create_dt_tm01)+ 1),
       __task_hist_task_create_dt_tm01)))))
     SET _remtask_hist_task_create_dt_tm01 += rptsd->m_drawlength
    ELSE
     SET _remtask_hist_task_create_dt_tm01 = 0
    ENDIF
    SET growsum += _remtask_hist_task_create_dt_tm01
   ENDIF
   SET rptsd->m_flags = 325
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.100
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 7.250)
   SET rptsd->m_width = 1.240
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
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
   SET rptsd->m_x = (offsetx+ 6.011)
   SET rptsd->m_width = 1.240
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
   SET rptsd->m_padding = rpt_sdrightborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 5.334)
   SET rptsd->m_width = 0.678
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremlosdisplayrowone = _remlosdisplayrowone
   IF (_remlosdisplayrowone > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlosdisplayrowone,((
       size(__losdisplayrowone) - _remlosdisplayrowone)+ 1),__losdisplayrowone)))
    SET drawheight_losdisplayrowone = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlosdisplayrowone = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlosdisplayrowone,((size(
        __losdisplayrowone) - _remlosdisplayrowone)+ 1),__losdisplayrowone)))))
     SET _remlosdisplayrowone += rptsd->m_drawlength
    ELSE
     SET _remlosdisplayrowone = 0
    ENDIF
    SET growsum += _remlosdisplayrowone
   ENDIF
   SET rptsd->m_flags = 277
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 4.365)
   SET rptsd->m_width = 0.969
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremdichargedaterowone = _remdichargedaterowone
   IF (_remdichargedaterowone > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remdichargedaterowone,((
       size(__dichargedaterowone) - _remdichargedaterowone)+ 1),__dichargedaterowone)))
    SET drawheight_dichargedaterowone = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remdichargedaterowone = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remdichargedaterowone,((size(
        __dichargedaterowone) - _remdichargedaterowone)+ 1),__dichargedaterowone)))))
     SET _remdichargedaterowone += rptsd->m_drawlength
    ELSE
     SET _remdichargedaterowone = 0
    ENDIF
    SET growsum += _remdichargedaterowone
   ENDIF
   SET rptsd->m_flags = 293
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.200
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 3.240)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdrempatienttyperowone = _rempatienttyperowone
   IF (_rempatienttyperowone > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_rempatienttyperowone,((
       size(__patienttyperowone) - _rempatienttyperowone)+ 1),__patienttyperowone)))
    SET drawheight_patienttyperowone = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _rempatienttyperowone = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_rempatienttyperowone,((size(
        __patienttyperowone) - _rempatienttyperowone)+ 1),__patienttyperowone)))))
     SET _rempatienttyperowone += rptsd->m_drawlength
    ELSE
     SET _rempatienttyperowone = 0
    ENDIF
    SET growsum += _rempatienttyperowone
   ENDIF
   SET rptsd->m_flags = 325
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.469)
   SET rptsd->m_width = 0.771
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremfinrowone = _remfinrowone
   IF (_remfinrowone > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfinrowone,((size(
        __finrowone) - _remfinrowone)+ 1),__finrowone)))
    SET drawheight_finrowone = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remfinrowone = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfinrowone,((size(__finrowone) -
       _remfinrowone)+ 1),__finrowone)))))
     SET _remfinrowone += rptsd->m_drawlength
    ELSE
     SET _remfinrowone = 0
    ENDIF
    SET growsum += _remfinrowone
   ENDIF
   SET rptsd->m_flags = 325
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.771)
   SET rptsd->m_width = 0.698
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremmrnrowone = _remmrnrowone
   IF (_remmrnrowone > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remmrnrowone,((size(
        __mrnrowone) - _remmrnrowone)+ 1),__mrnrowone)))
    SET drawheight_mrnrowone = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remmrnrowone = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remmrnrowone,((size(__mrnrowone) -
       _remmrnrowone)+ 1),__mrnrowone)))))
     SET _remmrnrowone += rptsd->m_drawlength
    ELSE
     SET _remmrnrowone = 0
    ENDIF
    SET growsum += _remmrnrowone
   ENDIF
   SET rptsd->m_flags = 293
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.200
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.771
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdrempatientnamerowone = _rempatientnamerowone
   IF (_rempatientnamerowone > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_rempatientnamerowone,((
       size(__patientnamerowone) - _rempatientnamerowone)+ 1),__patientnamerowone)))
    SET drawheight_patientnamerowone = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _rempatientnamerowone = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_rempatientnamerowone,((size(
        __patientnamerowone) - _rempatientnamerowone)+ 1),__patientnamerowone)))))
     SET _rempatientnamerowone += rptsd->m_drawlength
    ELSE
     SET _rempatientnamerowone = 0
    ENDIF
    SET growsum += _rempatientnamerowone
   ENDIF
   SET rptsd->m_flags = 324
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.100
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 8.490)
   SET rptsd->m_width = 1.511
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render
    AND _holdremtask_hist_task_create_dt_tm01 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _holdremtask_hist_task_create_dt_tm01,((size(__task_hist_task_create_dt_tm01) -
       _holdremtask_hist_task_create_dt_tm01)+ 1),__task_hist_task_create_dt_tm01)))
   ELSE
    SET _remtask_hist_task_create_dt_tm01 = _holdremtask_hist_task_create_dt_tm01
   ENDIF
   SET rptsd->m_flags = 324
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.100
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 7.250)
   SET rptsd->m_width = 1.240
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
   SET rptsd->m_x = (offsetx+ 6.011)
   SET rptsd->m_width = 1.240
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
   SET rptsd->m_padding = rpt_sdrightborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 5.334)
   SET rptsd->m_width = 0.678
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render
    AND _holdremlosdisplayrowone > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremlosdisplayrowone,(
       (size(__losdisplayrowone) - _holdremlosdisplayrowone)+ 1),__losdisplayrowone)))
   ELSE
    SET _remlosdisplayrowone = _holdremlosdisplayrowone
   ENDIF
   SET rptsd->m_flags = 276
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 4.365)
   SET rptsd->m_width = 0.969
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render
    AND _holdremdichargedaterowone > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremdichargedaterowone,
       ((size(__dichargedaterowone) - _holdremdichargedaterowone)+ 1),__dichargedaterowone)))
   ELSE
    SET _remdichargedaterowone = _holdremdichargedaterowone
   ENDIF
   SET rptsd->m_flags = 292
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.200
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 3.240)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render
    AND _holdrempatienttyperowone > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdrempatienttyperowone,
       ((size(__patienttyperowone) - _holdrempatienttyperowone)+ 1),__patienttyperowone)))
   ELSE
    SET _rempatienttyperowone = _holdrempatienttyperowone
   ENDIF
   SET rptsd->m_flags = 324
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.469)
   SET rptsd->m_width = 0.771
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render
    AND _holdremfinrowone > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfinrowone,((size(
        __finrowone) - _holdremfinrowone)+ 1),__finrowone)))
   ELSE
    SET _remfinrowone = _holdremfinrowone
   ENDIF
   SET rptsd->m_flags = 324
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.771)
   SET rptsd->m_width = 0.698
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render
    AND _holdremmrnrowone > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremmrnrowone,((size(
        __mrnrowone) - _holdremmrnrowone)+ 1),__mrnrowone)))
   ELSE
    SET _remmrnrowone = _holdremmrnrowone
   ENDIF
   SET rptsd->m_flags = 292
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.200
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.771
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render
    AND _holdrempatientnamerowone > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdrempatientnamerowone,
       ((size(__patientnamerowone) - _holdrempatientnamerowone)+ 1),__patientnamerowone)))
   ELSE
    SET _rempatientnamerowone = _holdrempatientnamerowone
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.771),offsety,(offsetx+ 1.771),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.469),offsety,(offsetx+ 2.469),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.240),offsety,(offsetx+ 3.240),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.365),offsety,(offsetx+ 4.365),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.333),offsety,(offsetx+ 5.333),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.010),offsety,(offsetx+ 6.010),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.250),offsety,(offsetx+ 7.250),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.490),offsety,(offsetx+ 8.490),(offsety+
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
 SUBROUTINE (fieldname021html(dummy=i2) =null WITH protect)
   IF (mod(rowcount,2)=1)
    SET _htmlfileinfo->file_buf = build2("<tr>","<td class='FieldName0210' colspan='4'>",
     patientnamerowone,"</td>","<td class='FieldName0211' colspan='1'>",
     trim(mrn,3),"</td>","<td class='FieldName0211' colspan='3'>",trim(fin,3),"</td>",
     "<td class='FieldName0210' colspan='4'>",patient_type_name,"</td>",
     "<td class='FieldName0214' colspan='1'>",
     IF (disch_dt_tm != null) format(cnvtdatetime(disch_dt_tm),"@SHORTDATE;;Q")
     ELSE "--"
     ENDIF
     ,
     "</td>","<td class='FieldName0215' colspan='2'>",losdisplayrowone,"</td>",
     "<td class='FieldName0216' colspan='2'>",
     cnvtminstodayshoursmins(tat_discharge_to_final),"</td>","<td class='FieldName0216' colspan='1'>",
     cnvtminstodayshoursmins(tat_create_to_final),"</td>",
     "<td class='FieldName0216' colspan='1'>",format(task_hist_task_create_dt_tm,
      "mm/dd/yyyy hh:mm;;Q"),"</td>","</tr>")
    SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
   ENDIF
 END ;Subroutine
 SUBROUTINE (fieldname022(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname022abs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (fieldname022abs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =f8 WITH
  protect)
   DECLARE sectionheight = f8 WITH noconstant(0.240000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_task_hist_task_create_dt_tm__ = f8 WITH noconstant(0.0), private
   DECLARE drawheight_tatcreatetofinalrowtwo = f8 WITH noconstant(0.0), private
   DECLARE drawheight_tatdischargetofinalrowtwo = f8 WITH noconstant(0.0), private
   DECLARE drawheight_losdisplayrowtwo = f8 WITH noconstant(0.0), private
   DECLARE drawheight_dichargedaterowtwo = f8 WITH noconstant(0.0), private
   DECLARE drawheight_patienttyperowtwo = f8 WITH noconstant(0.0), private
   DECLARE drawheight_finrowtwo = f8 WITH noconstant(0.0), private
   DECLARE drawheight_mrnrowtwo = f8 WITH noconstant(0.0), private
   DECLARE drawheight_patientnamerowtwo = f8 WITH noconstant(0.0), private
   DECLARE __task_hist_task_create_dt_tm__ = vc WITH noconstant(build(format(
      task_hist_task_create_dt_tm,"mm/dd/yyyy hh:mm;;Q"),char(0))), protect
   DECLARE __tatcreatetofinalrowtwo = vc WITH noconstant(build(cnvtminstodayshoursmins(
      tat_create_to_final),char(0))), protect
   DECLARE __tatdischargetofinalrowtwo = vc WITH noconstant(build(cnvtminstodayshoursmins(
      tat_discharge_to_final),char(0))), protect
   DECLARE __losdisplayrowtwo = vc WITH noconstant(build(losdisplayrowtwo,char(0))), protect
   DECLARE __dichargedaterowtwo = vc WITH noconstant(build(
     IF (disch_dt_tm != null) format(cnvtdatetime(disch_dt_tm),"@SHORTDATE;;Q")
     ELSE "--"
     ENDIF
     ,char(0))), protect
   DECLARE __patienttyperowtwo = vc WITH noconstant(build(patient_type_name,char(0))), protect
   DECLARE __finrowtwo = vc WITH noconstant(build(trim(fin,3),char(0))), protect
   DECLARE __mrnrowtwo = vc WITH noconstant(build(trim(mrn,3),char(0))), protect
   DECLARE __patientnamerowtwo = vc WITH noconstant(build(patientnamerowtwo,char(0))), protect
   IF ( NOT (mod(rowcount,2)=0))
    RETURN(0.0)
   ENDIF
   IF (bcontinue=0)
    SET _remtask_hist_task_create_dt_tm__ = 1
    SET _remtatcreatetofinalrowtwo = 1
    SET _remtatdischargetofinalrowtwo = 1
    SET _remlosdisplayrowtwo = 1
    SET _remdichargedaterowtwo = 1
    SET _rempatienttyperowtwo = 1
    SET _remfinrowtwo = 1
    SET _remmrnrowtwo = 1
    SET _rempatientnamerowtwo = 1
   ENDIF
   SET rptsd->m_flags = 325
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.100
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 8.490)
   SET rptsd->m_width = 1.511
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times100)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremtask_hist_task_create_dt_tm__ = _remtask_hist_task_create_dt_tm__
   IF (_remtask_hist_task_create_dt_tm__ > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _remtask_hist_task_create_dt_tm__,((size(__task_hist_task_create_dt_tm__) -
       _remtask_hist_task_create_dt_tm__)+ 1),__task_hist_task_create_dt_tm__)))
    SET drawheight_task_hist_task_create_dt_tm__ = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remtask_hist_task_create_dt_tm__ = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remtask_hist_task_create_dt_tm__,((size(
        __task_hist_task_create_dt_tm__) - _remtask_hist_task_create_dt_tm__)+ 1),
       __task_hist_task_create_dt_tm__)))))
     SET _remtask_hist_task_create_dt_tm__ += rptsd->m_drawlength
    ELSE
     SET _remtask_hist_task_create_dt_tm__ = 0
    ENDIF
    SET growsum += _remtask_hist_task_create_dt_tm__
   ENDIF
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(232,232,232))
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET rptsd->m_flags = 325
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.100
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 7.250)
   SET rptsd->m_width = 1.240
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
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
   SET rptsd->m_x = (offsetx+ 6.011)
   SET rptsd->m_width = 1.240
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
   SET rptsd->m_padding = rpt_sdrightborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 5.334)
   SET rptsd->m_width = 0.678
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremlosdisplayrowtwo = _remlosdisplayrowtwo
   IF (_remlosdisplayrowtwo > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlosdisplayrowtwo,((
       size(__losdisplayrowtwo) - _remlosdisplayrowtwo)+ 1),__losdisplayrowtwo)))
    SET drawheight_losdisplayrowtwo = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlosdisplayrowtwo = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlosdisplayrowtwo,((size(
        __losdisplayrowtwo) - _remlosdisplayrowtwo)+ 1),__losdisplayrowtwo)))))
     SET _remlosdisplayrowtwo += rptsd->m_drawlength
    ELSE
     SET _remlosdisplayrowtwo = 0
    ENDIF
    SET growsum += _remlosdisplayrowtwo
   ENDIF
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(232,232,232))
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET rptsd->m_flags = 277
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 4.365)
   SET rptsd->m_width = 0.969
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremdichargedaterowtwo = _remdichargedaterowtwo
   IF (_remdichargedaterowtwo > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remdichargedaterowtwo,((
       size(__dichargedaterowtwo) - _remdichargedaterowtwo)+ 1),__dichargedaterowtwo)))
    SET drawheight_dichargedaterowtwo = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remdichargedaterowtwo = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remdichargedaterowtwo,((size(
        __dichargedaterowtwo) - _remdichargedaterowtwo)+ 1),__dichargedaterowtwo)))))
     SET _remdichargedaterowtwo += rptsd->m_drawlength
    ELSE
     SET _remdichargedaterowtwo = 0
    ENDIF
    SET growsum += _remdichargedaterowtwo
   ENDIF
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(232,232,232))
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET rptsd->m_flags = 293
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.200
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 3.240)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdrempatienttyperowtwo = _rempatienttyperowtwo
   IF (_rempatienttyperowtwo > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_rempatienttyperowtwo,((
       size(__patienttyperowtwo) - _rempatienttyperowtwo)+ 1),__patienttyperowtwo)))
    SET drawheight_patienttyperowtwo = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _rempatienttyperowtwo = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_rempatienttyperowtwo,((size(
        __patienttyperowtwo) - _rempatienttyperowtwo)+ 1),__patienttyperowtwo)))))
     SET _rempatienttyperowtwo += rptsd->m_drawlength
    ELSE
     SET _rempatienttyperowtwo = 0
    ENDIF
    SET growsum += _rempatienttyperowtwo
   ENDIF
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(232,232,232))
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET rptsd->m_flags = 325
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.469)
   SET rptsd->m_width = 0.771
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremfinrowtwo = _remfinrowtwo
   IF (_remfinrowtwo > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfinrowtwo,((size(
        __finrowtwo) - _remfinrowtwo)+ 1),__finrowtwo)))
    SET drawheight_finrowtwo = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remfinrowtwo = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfinrowtwo,((size(__finrowtwo) -
       _remfinrowtwo)+ 1),__finrowtwo)))))
     SET _remfinrowtwo += rptsd->m_drawlength
    ELSE
     SET _remfinrowtwo = 0
    ENDIF
    SET growsum += _remfinrowtwo
   ENDIF
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(232,232,232))
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET rptsd->m_flags = 325
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.771)
   SET rptsd->m_width = 0.698
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremmrnrowtwo = _remmrnrowtwo
   IF (_remmrnrowtwo > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remmrnrowtwo,((size(
        __mrnrowtwo) - _remmrnrowtwo)+ 1),__mrnrowtwo)))
    SET drawheight_mrnrowtwo = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remmrnrowtwo = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remmrnrowtwo,((size(__mrnrowtwo) -
       _remmrnrowtwo)+ 1),__mrnrowtwo)))))
     SET _remmrnrowtwo += rptsd->m_drawlength
    ELSE
     SET _remmrnrowtwo = 0
    ENDIF
    SET growsum += _remmrnrowtwo
   ENDIF
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(232,232,232))
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET rptsd->m_flags = 293
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.200
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.771
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdrempatientnamerowtwo = _rempatientnamerowtwo
   IF (_rempatientnamerowtwo > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_rempatientnamerowtwo,((
       size(__patientnamerowtwo) - _rempatientnamerowtwo)+ 1),__patientnamerowtwo)))
    SET drawheight_patientnamerowtwo = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _rempatientnamerowtwo = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_rempatientnamerowtwo,((size(
        __patientnamerowtwo) - _rempatientnamerowtwo)+ 1),__patientnamerowtwo)))))
     SET _rempatientnamerowtwo += rptsd->m_drawlength
    ELSE
     SET _rempatientnamerowtwo = 0
    ENDIF
    SET growsum += _rempatientnamerowtwo
   ENDIF
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(232,232,232))
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET rptsd->m_flags = 324
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.100
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 8.490)
   SET rptsd->m_width = 1.511
   SET rptsd->m_height = sectionheight
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(232,232,232))
   IF (ncalc=rpt_render
    AND _holdremtask_hist_task_create_dt_tm__ > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _holdremtask_hist_task_create_dt_tm__,((size(__task_hist_task_create_dt_tm__) -
       _holdremtask_hist_task_create_dt_tm__)+ 1),__task_hist_task_create_dt_tm__)))
   ELSE
    SET _remtask_hist_task_create_dt_tm__ = _holdremtask_hist_task_create_dt_tm__
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET rptsd->m_flags = 324
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.100
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 7.250)
   SET rptsd->m_width = 1.240
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
   SET rptsd->m_x = (offsetx+ 6.011)
   SET rptsd->m_width = 1.240
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
   SET rptsd->m_padding = rpt_sdrightborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 5.334)
   SET rptsd->m_width = 0.678
   SET rptsd->m_height = sectionheight
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(232,232,232))
   IF (ncalc=rpt_render
    AND _holdremlosdisplayrowtwo > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremlosdisplayrowtwo,(
       (size(__losdisplayrowtwo) - _holdremlosdisplayrowtwo)+ 1),__losdisplayrowtwo)))
   ELSE
    SET _remlosdisplayrowtwo = _holdremlosdisplayrowtwo
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET rptsd->m_flags = 276
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 4.365)
   SET rptsd->m_width = 0.969
   SET rptsd->m_height = sectionheight
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(232,232,232))
   IF (ncalc=rpt_render
    AND _holdremdichargedaterowtwo > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremdichargedaterowtwo,
       ((size(__dichargedaterowtwo) - _holdremdichargedaterowtwo)+ 1),__dichargedaterowtwo)))
   ELSE
    SET _remdichargedaterowtwo = _holdremdichargedaterowtwo
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET rptsd->m_flags = 292
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.200
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 3.240)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = sectionheight
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(232,232,232))
   IF (ncalc=rpt_render
    AND _holdrempatienttyperowtwo > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdrempatienttyperowtwo,
       ((size(__patienttyperowtwo) - _holdrempatienttyperowtwo)+ 1),__patienttyperowtwo)))
   ELSE
    SET _rempatienttyperowtwo = _holdrempatienttyperowtwo
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET rptsd->m_flags = 324
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.469)
   SET rptsd->m_width = 0.771
   SET rptsd->m_height = sectionheight
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(232,232,232))
   IF (ncalc=rpt_render
    AND _holdremfinrowtwo > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfinrowtwo,((size(
        __finrowtwo) - _holdremfinrowtwo)+ 1),__finrowtwo)))
   ELSE
    SET _remfinrowtwo = _holdremfinrowtwo
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET rptsd->m_flags = 324
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.771)
   SET rptsd->m_width = 0.698
   SET rptsd->m_height = sectionheight
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(232,232,232))
   IF (ncalc=rpt_render
    AND _holdremmrnrowtwo > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremmrnrowtwo,((size(
        __mrnrowtwo) - _holdremmrnrowtwo)+ 1),__mrnrowtwo)))
   ELSE
    SET _remmrnrowtwo = _holdremmrnrowtwo
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET rptsd->m_flags = 292
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.200
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.771
   SET rptsd->m_height = sectionheight
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(232,232,232))
   IF (ncalc=rpt_render
    AND _holdrempatientnamerowtwo > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdrempatientnamerowtwo,
       ((size(__patientnamerowtwo) - _holdrempatientnamerowtwo)+ 1),__patientnamerowtwo)))
   ELSE
    SET _rempatientnamerowtwo = _holdrempatientnamerowtwo
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.771),offsety,(offsetx+ 1.771),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.469),offsety,(offsetx+ 2.469),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.240),offsety,(offsetx+ 3.240),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.365),offsety,(offsetx+ 4.365),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.333),offsety,(offsetx+ 5.333),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.010),offsety,(offsetx+ 6.010),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.250),offsety,(offsetx+ 7.250),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.490),offsety,(offsetx+ 8.490),(offsety+
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
 SUBROUTINE (fieldname022html(dummy=i2) =null WITH protect)
   IF (mod(rowcount,2)=0)
    SET _htmlfileinfo->file_buf = build2("<tr>","<td class='FieldName0220' colspan='4'>",
     patientnamerowtwo,"</td>","<td class='FieldName0221' colspan='1'>",
     trim(mrn,3),"</td>","<td class='FieldName0221' colspan='3'>",trim(fin,3),"</td>",
     "<td class='FieldName0220' colspan='4'>",patient_type_name,"</td>",
     "<td class='FieldName0224' colspan='1'>",
     IF (disch_dt_tm != null) format(cnvtdatetime(disch_dt_tm),"@SHORTDATE;;Q")
     ELSE "--"
     ENDIF
     ,
     "</td>","<td class='FieldName0225' colspan='2'>",losdisplayrowtwo,"</td>",
     "<td class='FieldName0226' colspan='2'>",
     cnvtminstodayshoursmins(tat_discharge_to_final),"</td>","<td class='FieldName0226' colspan='1'>",
     cnvtminstodayshoursmins(tat_create_to_final),"</td>",
     "<td class='FieldName0226' colspan='1'>",format(task_hist_task_create_dt_tm,
      "mm/dd/yyyy hh:mm;;Q"),"</td>","</tr>")
    SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
   ENDIF
 END ;Subroutine
 SUBROUTINE (fieldname023(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname023abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (fieldname023abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.110000), private
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
    SET rptsd->m_height = 0.115
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
 SUBROUTINE (fieldname023html(dummy=i2) =null WITH protect)
  SET _htmlfileinfo->file_buf = build2("<tr>","<td class='FieldName0230' colspan='19'>","","</td>",
   "</tr>")
  SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
 END ;Subroutine
 SUBROUTINE (fieldname024(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname024abs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (fieldname024abs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =f8 WITH
  protect)
   DECLARE sectionheight = f8 WITH noconstant(0.190000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_cellname45 = f8 WITH noconstant(0.0), private
   DECLARE __cellname45 = vc WITH noconstant(build(concat(uar_i18ngetmessage(i18nhandlehim,
       "TOTALCHARTSANALYZED","Total # of Charts Analyzed in "),trim(task_queue_name,3)," Task Queue",
      ": "),char(0))), protect
   IF (bcontinue=0)
    SET _remcellname45 = 1
   ENDIF
   SET rptsd->m_flags = 293
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.100
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 2.938
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremcellname45 = _remcellname45
   IF (_remcellname45 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remcellname45,((size(
        __cellname45) - _remcellname45)+ 1),__cellname45)))
    SET drawheight_cellname45 = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remcellname45 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remcellname45,((size(__cellname45) -
       _remcellname45)+ 1),__cellname45)))))
     SET _remcellname45 += rptsd->m_drawlength
    ELSE
     SET _remcellname45 = 0
    ENDIF
    SET growsum += _remcellname45
   ENDIF
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(255,255,128))
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.200
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 6.750)
   SET rptsd->m_width = 3.251
   SET rptsd->m_height = sectionheight
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(255,255,128))
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET rptsd->m_flags = 272
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 5.344)
   SET rptsd->m_width = 1.407
   SET rptsd->m_height = sectionheight
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(255,255,128))
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(totallosdisplay,char(0)))
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.200
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 3.938)
   SET rptsd->m_width = 1.407
   SET rptsd->m_height = sectionheight
   SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(255,255,128))
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(uar_i18ngetmessage(_hi18nhandle,
       "FieldName024_CellName46",build2("Total LOS:",char(0))),char(0)))
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET rptsd->m_flags = 288
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.938)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = sectionheight
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(255,255,128))
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(totalchartsperqueuedisplay,char(0)))
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET rptsd->m_flags = 292
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.100
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 2.938
   SET rptsd->m_height = sectionheight
   SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(255,255,128))
   IF (ncalc=rpt_render
    AND _holdremcellname45 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremcellname45,((size(
        __cellname45) - _holdremcellname45)+ 1),__cellname45)))
   ELSE
    SET _remcellname45 = _holdremcellname45
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.938),offsety,(offsetx+ 2.938),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.938),offsety,(offsetx+ 3.938),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.344),offsety,(offsetx+ 5.344),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.750),offsety,(offsetx+ 6.750),(offsety+
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
  SET _htmlfileinfo->file_buf = build2("<tr>","<td class='FieldName0240' colspan='7'>",concat(
    uar_i18ngetmessage(i18nhandlehim,"TOTALCHARTSANALYZED","Total # of Charts Analyzed in "),trim(
     task_queue_name,3)," Task Queue",": "),"</td>","<td class='FieldName0241' colspan='3'>",
   totalchartsperqueuedisplay,"</td>","<td class='FieldName0242' colspan='4'>",uar_i18ngetmessage(
    _hi18nhandle,"BHS_HIM_PROD_ANALYSIS_DET_NGRP_CellName46","Total LOS:"),"</td>",
   "<td class='FieldName0243' colspan='2'>",totallosdisplay,"</td>",
   "<td class='FieldName0242' colspan='3'>","",
   "</td>","</tr>")
  SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
 END ;Subroutine
 SUBROUTINE (fieldname025(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname025abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (fieldname025abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.220000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 288
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 3.938)
    SET rptsd->m_width = 6.063
    SET rptsd->m_height = 0.219
    SET _oldfont = uar_rptsetfont(_hreport,_times100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(255,255,128))
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
    SET oldbackcolor = uar_rptresetbackcolor(_hreport)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 2.938)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.219
    SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(255,255,128))
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(totalchartsperuserdisplay,char(0)))
    SET oldbackcolor = uar_rptresetbackcolor(_hreport)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.938
    SET rptsd->m_height = 0.219
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(255,255,128))
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(uar_i18ngetmessage(_hi18nhandle,
       "FieldName025_CellName48",build2("Total # of Charts Analyzed - All Task Queues:",char(0))),
      char(0)))
    SET oldbackcolor = uar_rptresetbackcolor(_hreport)
    SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.938),offsety,(offsetx+ 2.938),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.938),offsety,(offsetx+ 3.938),(offsety+
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
  SET _htmlfileinfo->file_buf = build2("<tr>","<td class='FieldName0250' colspan='7'>",
   uar_i18ngetmessage(_hi18nhandle,"BHS_HIM_PROD_ANALYSIS_DET_NGRP_CellName48",
    "Total # of Charts Analyzed - All Task Queues:"),"</td>","<td class='FieldName0241' colspan='3'>",
   totalchartsperuserdisplay,"</td>","<td class='FieldName0241' colspan='9'>","","</td>",
   "</tr>")
  SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
 END ;Subroutine
 SUBROUTINE (fieldname027(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname027abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (fieldname027abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.450000), private
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
    SET rptsd->m_height = 0.448
    SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen25s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(uar_i18ngetmessage(_hi18nhandle,
       "FieldName027_EndOfReport",build2("**END OF REPORT**",char(0))),char(0)))
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
 SUBROUTINE (fieldname027html(dummy=i2) =null WITH protect)
  SET _htmlfileinfo->file_buf = build2("<tr>","<td class='FieldName0270' colspan='19'>",
   uar_i18ngetmessage(_hi18nhandle,"BHS_HIM_PROD_ANALYSIS_DET_NGRP_EndOfReport","**END OF REPORT**"),
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
     SET rptreport->m_reportname = "BHS_HIM_PROD_ANALYSIS_DET_NGRP"
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
