CREATE PROGRAM bhs_cust_him_defic_by_phys_det:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Facility(ies)" = 0,
  "Physician(s)" = 0,
  "Chart Age" = "All Chart Ages",
  "Deficiency Age" = "All Deficiencies",
  "Positions" = 0
  WITH outdev, organizations, physicians,
  ms_chartage, ms_defage, position
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
  "uar_i18ngethijridate",
  persist
  DECLARE uar_i18nbuildfullformatname(sfirst=vc(ref),slast=vc(ref),smiddle=vc(ref),sdegree=vc(ref),
   stitle=vc(ref),
   sprefix=vc(ref),ssuffix=vc(ref),sinitials=vc(ref),soriginal=vc(ref)) = c250 WITH image_axp =
  "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar = "i18nbuildfullformatname",
  persist
  DECLARE uar_i18ngetarabictime(ctime=vc(ref)) = c20 WITH image_axp = "shri18nuar", image_aix =
  "libi18n_locale.a(libi18n_locale.o)", uar = "i18n_getarabictime",
  persist
 ENDIF
 DECLARE fillqualwithfacilitynames(organizations=vc(ref)) = null WITH protect
 DECLARE himgetnamesforcodevalues(data=vc(ref)) = null WITH protect
 DECLARE himgetnamesfromtable(data=vc(ref),tablename=vc,name=vc,id=vc) = null WITH protect
 DECLARE getdatafromprompt(parameternumber=i1,data=vc(ref)) = null WITH protect
 DECLARE himrendernodatareport(datasize=i4,outputdevice=vc) = i1 WITH protect
 DECLARE i1multifacilitylogicind = i1 WITH noconstant(0), protect
 DECLARE i2multifacilitylogicind = i2 WITH noconstant(0), protect
 DECLARE f8daterangeadd = f8 WITH constant(0.99998842592592592592592592592593), protect
 DECLARE i18nallfacilities = vc WITH noconstant(""), protect
 SET i18nhandlehim = 0
 SET lretval = uar_i18nlocalizationinit(i18nhandlehim,curprog,"",curcclrev)
 SET i18nallfacilities = uar_i18ngetmessage(i18nhandlehim,"HIM_PRMPT_KEY_0","All Facilities")
 SELECT INTO "nl:"
  FROM him_system_params h
  WHERE h.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND h.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
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
 SUBROUTINE getdatafromprompt(parameternumber,data)
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
       SET parnum = (parnum+ 1)
       SET data->qual[parnum].item_id = parameter(inputnum,parnum)
      ENDWHILE
     ELSE
      SET nothing = null
    ENDCASE
   ENDIF
 END ;Subroutine
 SUBROUTINE fillqualwithfacilitynames(organizations)
   CALL himgetnamesfromtable(organizations,"organization","org_name","organization_id")
 END ;Subroutine
 SUBROUTINE himgetnamesforcodevalues(data)
   FOR (index = 1 TO size(data->qual,5))
     SET data->qual[index].item_name = uar_get_code_display(data->qual[index].item_id)
   ENDFOR
 END ;Subroutine
 SUBROUTINE himgetnamesfromtable(data,tablename,name,id)
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
 SUBROUTINE himrendernodatareport(datasize,outputdevice)
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
 DECLARE him_render_params_excel = vc WITH constant(
  IF (findstring(",",request->params)) build("minE",substring(findstring(",",request->params),textlen
     (request->params),replace(request->params,'"',"^",0)))
  ELSE "minE"
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
 DECLARE makelistofqualitemnames(data=vc(ref),default=vc) = vc WITH protect
 DECLARE getdaterangedisplay(dates=vc(ref),type=i1) = vc WITH protect
 DECLARE cnvtminstodayshoursmins(mins=i4) = vc WITH protect
 EXECUTE reportrtl
 SET vctodaydatetime = format(cnvtdatetime(curdate,curtime3),"@SHORTDATETIME;;Q")
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
 SUBROUTINE getdaterangedisplay(dates,type)
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
      SET vcfilterdaterange = build2(format(dates->beginning_date,"@SHORTDATE;;Q")," - ",format(dates
        ->ending_date,"@SHORTDATE;;Q"))
     ELSE
      SET vcfilterdaterange = uar_i18ngetmessage(i18nhandlehim,"NORANGE2","NO RANGE")
     ENDIF
    ELSE
     SET vcfilterdaterange = uar_i18ngetmessage(i18nhandlehim,"NODATESFOUND","No Dates Found")
   ENDCASE
   RETURN(vcfilterdaterange)
 END ;Subroutine
 SUBROUTINE cnvtminstodayshoursmins(mins)
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
 SUBROUTINE makelistofqualitemnames(data,default)
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
 FREE RECORD organizations
 RECORD organizations(
   1 qual[*]
     2 item_id = f8
     2 item_name = vc
 )
 FREE RECORD physicians
 RECORD physicians(
   1 qual[*]
     2 item_id = f8
     2 item_name = vc
 )
 FREE RECORD positions
 RECORD positions(
   1 cnt = i4
   1 qual[*]
     2 item_id = f8
     2 item_name = vc
 )
 IF (substring(1,1,reflect(parameter(6,0))) != "C")
  SELECT INTO "nl:"
   FROM code_value cv
   WHERE (cv.code_value= $POSITION)
   HEAD REPORT
    positions->cnt = 0
   DETAIL
    IF (cv.code_value > 0)
     positions->cnt = (positions->cnt+ 1), stat = alterlist(positions->qual,positions->cnt),
     positions->qual[positions->cnt].item_id = cv.code_value,
     positions->qual[positions->cnt].item_name = cv.display
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 CALL echoxml(request,"al_test_positions.txt")
 FREE RECORD data
 RECORD data(
   1 qual[*]
     2 patient_name = vc
     2 patient_id = f8
     2 patient_type_cd = f8
     2 organization_name = vc
     2 organization_id = f8
     2 mrn = vc
     2 fin = vc
     2 physician_name = vc
     2 physician_id = f8
     2 encntr_id = f8
     2 chart_alloc_dt_tm = dq8
     2 chart_age = i4
     2 disch_dt_tm = dq8
     2 location = vc
     2 patient_abs_birth_dt_tm = dq8
     2 patient_active_ind = i2
     2 patient_active_status_cd = f8
     2 patient_active_status_dt_tm = dq8
     2 patient_active_status_prsnl_id = f8
     2 patient_archive_env_id = f8
     2 patient_archive_status_cd = f8
     2 patient_archive_status_dt_tm = dq8
     2 patient_autopsy_cd = f8
     2 patient_beg_effective_dt_tm = dq8
     2 patient_birth_dt_cd = f8
     2 patient_birth_dt_tm = dq8
     2 patient_birth_prec_flag = i2
     2 patient_birth_tz = i4
     2 patient_cause_of_death = vc
     2 patient_cause_of_death_cd = f8
     2 patient_citizenship_cd = f8
     2 patient_conception_dt_tm = dq8
     2 patient_confid_level_cd = f8
     2 patient_contributor_system_cd = f8
     2 patient_create_dt_tm = dq8
     2 patient_create_prsnl_id = f8
     2 patient_data_status_cd = f8
     2 patient_data_status_dt_tm = dq8
     2 patient_data_status_prsnl_id = f8
     2 patient_deceased_cd = f8
     2 patient_deceased_dt_tm = dq8
     2 patient_deceased_source_cd = f8
     2 patient_end_effective_dt_tm = dq8
     2 patient_ethnic_grp_cd = f8
     2 patient_ft_entity_id = f8
     2 patient_ft_entity_name = c32
     2 patient_language_cd = f8
     2 patient_language_dialect_cd = f8
     2 patient_last_accessed_dt_tm = dq8
     2 patient_last_encntr_dt_tm = dq8
     2 patient_marital_type_cd = f8
     2 patient_military_base_location = vc
     2 patient_military_rank_cd = f8
     2 patient_military_service_cd = f8
     2 patient_mother_maiden_name = vc
     2 patient_name_first = vc
     2 patient_name_first_key = vc
     2 patient_name_first_key_nls = vc
     2 patient_name_first_phonetic = c8
     2 patient_name_first_synonym_id = f8
     2 patient_name_full_formatted = vc
     2 patient_name_last = vc
     2 patient_name_last_key = vc
     2 patient_name_last_key_nls = vc
     2 patient_name_last_phonetic = c8
     2 patient_name_middle = vc
     2 patient_name_middle_key = vc
     2 patient_name_middle_key_nls = vc
     2 patient_name_phonetic = c8
     2 patient_nationality_cd = f8
     2 patient_next_restore_dt_tm = dq8
     2 patient_person_id = f8
     2 patient_person_type_cd = f8
     2 patient_race_cd = f8
     2 patient_religion_cd = f8
     2 patient_sex_age_change_ind = i2
     2 patient_sex_cd = f8
     2 patient_species_cd = f8
     2 patient_updt_dt_tm = dq8
     2 patient_updt_id = f8
     2 patient_updt_task = i4
     2 patient_vet_military_status_cd = f8
     2 patient_vip_cd = f8
     2 physician_active_ind = i2
     2 physician_active_status_cd = f8
     2 physician_active_status_dt_tm = dq8
     2 physician_active_status_prsnl_id = f8
     2 physician_beg_effective_dt_tm = dq8
     2 physician_contributor_system_cd = f8
     2 physician_create_dt_tm = dq8
     2 physician_create_prsnl_id = f8
     2 physician_data_status_cd = f8
     2 physician_data_status_dt_tm = dq8
     2 physician_data_status_prsnl_id = f8
     2 physician_email = vc
     2 physician_end_effective_dt_tm = dq8
     2 physician_ft_entity_id = f8
     2 physician_ft_entity_name = c32
     2 physician_name_first = vc
     2 physician_name_first_key = vc
     2 physician_name_first_key_nls = vc
     2 physician_name_full_formatted = vc
     2 physician_name_last = vc
     2 physician_name_last_key = vc
     2 physician_name_last_key_nls = vc
     2 physician_password = vc
     2 physician_person_id = f8
     2 physician_physician_ind = i2
     2 physician_physician_status_cd = f8
     2 physician_position_cd = f8
     2 physician_prim_assign_loc_cd = f8
     2 physician_prsnl_type_cd = f8
     2 physician_updt_dt_tm = dq8
     2 physician_updt_id = f8
     2 physician_updt_task = i4
     2 physician_username = vc
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
     2 him_visit_abstract_complete_ind = i2
     2 him_visit_active_ind = i2
     2 him_visit_active_status_cd = f8
     2 him_visit_active_status_dt_tm = dq8
     2 him_visit_active_status_prsnl_id = f8
     2 him_visit_allocation_dt_flag = i2
     2 him_visit_allocation_dt_modifier = i4
     2 him_visit_allocation_dt_tm = dq8
     2 him_visit_beg_effective_dt_tm = dq8
     2 him_visit_chart_process_id = f8
     2 him_visit_chart_status_cd = f8
     2 him_visit_chart_status_dt_tm = dq8
     2 him_visit_encntr_id = f8
     2 him_visit_end_effective_dt_tm = dq8
     2 him_visit_person_id = f8
     2 him_visit_updt_dt_tm = dq8
     2 him_visit_updt_id = f8
     2 him_visit_updt_task = i4
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
     2 defic_qual[*]
       3 deficiency_name = vc
       3 status = vc
       3 alloc_dt_tm = dq8
       3 defic_age = i4
       3 event_id = f8
       3 order_id = f8
       3 action_sequence = i4
       3 deficiency_flag = i2
       3 doc_qual[*]
         4 him_event_action_type_cd = f8
         4 him_event_action_status_cd = f8
         4 him_event_allocation_dt_tm = dq8
         4 him_event_beg_effective_dt_tm = dq8
         4 him_event_completed_dt_tm = dq8
         4 him_event_encntr_id = f8
         4 him_event_end_effective_dt_tm = dq8
         4 him_event_event_cd = f8
         4 him_event_event_id = f8
         4 him_event_him_event_allocation_id = f8
         4 him_event_prsnl_id = f8
         4 him_event_request_dt_tm = dq8
         4 him_event_updt_dt_tm = dq8
         4 him_event_updt_id = f8
         4 him_event_updt_task = f8
         4 him_event_active_status_cd = f8
         4 him_event_active_dt_tm = dq8
         4 him_event_active_ind = i2
         4 him_event_active_status_cd = f8
         4 him_event_active_status_prsnl_id = f8
         4 him_event_active_status_dt_tm = dq8
       3 order_qual[*]
         4 orders_active_ind = i4
         4 orders_active_status_cd = f8
         4 orders_active_status_dt_tm = dq8
         4 orders_active_status_prsnl_id = f8
         4 orders_activity_type_cd = f8
         4 orders_ad_hoc_order_flag = i4
         4 orders_catalog_cd = f8
         4 orders_catalog_type_cd = f8
         4 orders_cki = vc
         4 orders_clinical_display_line = vc
         4 orders_comment_type_mask = i4
         4 orders_constant_ind = i4
         4 orders_contributor_system_cd = f8
         4 orders_cs_flag = i4
         4 orders_cs_order_id = f8
         4 orders_current_start_dt_tm = dq8
         4 orders_current_start_tz = i4
         4 orders_dcp_clin_cat_cd = f8
         4 orders_dept_misc_line = vc
         4 orders_dept_status_cd = f8
         4 orders_discontinue_effective_dt_tm = dq8
         4 orders_discontinue_effective_tz = i4
         4 orders_discontinue_ind = i4
         4 orders_discontinue_type_cd = f8
         4 orders_encntr_financial_id = f8
         4 orders_encntr_id = f8
         4 orders_eso_new_order_ind = i4
         4 orders_frequency_id = f8
         4 orders_freq_type_flag = i4
         4 orders_group_order_flag = i4
         4 orders_group_order_id = f8
         4 orders_hide_flag = i4
         4 orders_hna_order_mnemonic = vc
         4 orders_incomplete_order_ind = i4
         4 orders_ingredient_ind = i4
         4 orders_interest_dt_tm = dq8
         4 orders_interval_ind = i4
         4 orders_iv_ind = i4
         4 orders_last_action_sequence = i4
         4 orders_last_core_action_sequence = i4
         4 orders_last_ingred_action_sequence = i4
         4 orders_last_update_provider_id = f8
         4 orders_link_nbr = f8
         4 orders_link_order_flag = i4
         4 orders_link_order_id = f8
         4 orders_link_type_flag = i4
         4 orders_med_order_type_cd = f8
         4 orders_modified_start_dt_tm = dq8
         4 orders_need_doctor_cosign_ind = i4
         4 orders_need_nurse_review_ind = i4
         4 orders_need_physician_validate_ind = i4
         4 orders_need_rx_verify_ind = i4
         4 orders_oe_format_id = f8
         4 orders_orderable_type_flag = i4
         4 orders_ordered_as_mnemonic = vc
         4 orders_order_comment_ind = i4
         4 orders_order_detail_display_line = vc
         4 orders_order_id = f8
         4 orders_order_mnemonic = vc
         4 orders_order_status_cd = f8
         4 orders_orig_order_convs_seq = i4
         4 orders_orig_order_dt_tm = dq8
         4 orders_orig_order_tz = i4
         4 orders_orig_ord_as_flag = i4
         4 orders_override_flag = i4
         4 orders_pathway_catalog_id = f8
         4 orders_person_id = f8
         4 orders_prn_ind = i4
         4 orders_product_id = f8
         4 orders_projected_stop_dt_tm = dq8
         4 orders_projected_stop_tz = i4
         4 orders_ref_text_mask = i4
         4 orders_remaining_dose_cnt = i4
         4 orders_resume_effective_dt_tm = dq8
         4 orders_resume_effective_tz = i4
         4 orders_resume_ind = i4
         4 orders_rx_mask = i4
         4 orders_sch_state_cd = f8
         4 orders_soft_stop_dt_tm = dq8
         4 orders_soft_stop_tz = i4
         4 orders_status_dt_tm = dq8
         4 orders_status_prsnl_id = f8
         4 orders_stop_type_cd = f8
         4 orders_suspend_effective_dt_tm = dq8
         4 orders_suspend_effective_tz = i4
         4 orders_suspend_ind = i4
         4 orders_synonym_id = f8
         4 orders_template_core_action_sequence = i4
         4 orders_template_order_flag = i4
         4 orders_template_order_id = f8
         4 orders_updt_dt_tm = dq8
         4 orders_updt_id = f8
         4 orders_updt_task = i4
         4 orders_valid_dose_dt_tm = dq8
         4 order_review_action_sequence = i4
         4 order_review_dept_cd = f8
         4 order_review_digital_signature_ident = vc
         4 order_review_location_cd = f8
         4 order_review_order_id = f8
         4 order_review_provider_id = f8
         4 order_review_proxy_personnel_id = f8
         4 order_review_proxy_reason_cd = f8
         4 order_review_reject_reason_cd = f8
         4 order_review_reviewed_status_flag = i2
         4 order_review_review_dt_tm = dq8
         4 order_review_review_personnel_id = f8
         4 order_review_review_reqd_ind = i2
         4 order_review_review_sequence = i4
         4 order_review_review_type_flag = i2
         4 order_review_review_tz = i4
         4 order_review_updt_dt_tm = dq8
         4 order_review_updt_id = f8
         4 order_review_updt_task = i4
         4 order_notif_action_sequence = i4
         4 order_notif_caused_by_flag = i2
         4 order_notif_from_prsnl_id = f8
         4 order_notif_notification_comment = vc
         4 order_notif_notification_dt_tm = dq8
         4 order_notif_notification_reason_cd = f8
         4 order_notif_notification_status_flag = i2
         4 order_notif_notification_type_flag = i2
         4 order_notif_notification_tz = i4
         4 order_notif_order_id = f8
         4 order_notif_order_notification_id = f8
         4 order_notif_parent_order_notification_id = f8
         4 order_notif_status_change_dt_tm = dq8
         4 order_notif_status_change_tz = i4
         4 order_notif_to_prsnl_id = f8
         4 order_notif_updt_dt_tm = dq8
         4 order_notif_updt_id = f8
         4 order_notif_updt_task = i4
   1 max_defic_qual_count = i4
 )
 IF (i1multifacilitylogicind)
  CALL getdatafromprompt(2,organizations)
  CALL himgetnamesfromtable(organizations,"organization","org_name","organization_id")
 ENDIF
 CALL getdatafromprompt(3,physicians)
 CALL himgetnamesfromtable(physicians,"prsnl","name_full_formatted","person_id")
 EXECUTE him_mak_defic_by_phys_driver
 IF (himrendernodatareport(size(data->qual,5), $OUTDEV))
  RETURN
 ENDIF
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE cclbuildhlink(vcprog=vc,vcparams=vc,nviewtype=i2,vcdescription=vc) = vc WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
 DECLARE section(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE fieldname00(ncalc=i2) = f8 WITH protect
 DECLARE fieldname00abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE fieldname01(ncalc=i2) = f8 WITH protect
 DECLARE fieldname01abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE fieldname02(ncalc=i2) = f8 WITH protect
 DECLARE fieldname02abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE fieldname03(ncalc=i2) = f8 WITH protect
 DECLARE fieldname03abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE fieldname04(ncalc=i2) = f8 WITH protect
 DECLARE fieldname04abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE fieldname05(ncalc=i2) = f8 WITH protect
 DECLARE fieldname05abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE fieldname06(ncalc=i2) = f8 WITH protect
 DECLARE fieldname06abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE fieldname07(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE fieldname07abs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE fieldnamechartage(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE fieldnamechartageabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8
 WITH protect
 DECLARE fieldnamedeficiencyage(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE fieldnamedeficiencyabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8
 WITH protect
 DECLARE fieldnameposition(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE fieldnamepositionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8
 WITH protect
 DECLARE fieldname08(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE fieldname08abs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE fieldname09(ncalc=i2) = f8 WITH protect
 DECLARE fieldname09abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE fieldname010(ncalc=i2) = f8 WITH protect
 DECLARE fieldname010abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE fieldname011(ncalc=i2) = f8 WITH protect
 DECLARE fieldname011abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE fieldname012(ncalc=i2) = f8 WITH protect
 DECLARE fieldname012abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE fieldname013(ncalc=i2) = f8 WITH protect
 DECLARE fieldname013abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE fieldname014(ncalc=i2) = f8 WITH protect
 DECLARE fieldname014abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE fieldname015(ncalc=i2) = f8 WITH protect
 DECLARE fieldname015abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE fieldname016(ncalc=i2) = f8 WITH protect
 DECLARE fieldname016abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE fieldname017(ncalc=i2) = f8 WITH protect
 DECLARE fieldname017abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE fieldname018(ncalc=i2) = f8 WITH protect
 DECLARE fieldname018abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE fieldname019(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE fieldname019abs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE fieldname020(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE fieldname020abs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE fieldname021(ncalc=i2) = f8 WITH protect
 DECLARE fieldname021abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE fieldname022(ncalc=i2) = f8 WITH protect
 DECLARE fieldname022abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE fieldname023(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE fieldname023abs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE fieldname024(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE fieldname024abs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE fieldname025(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE fieldname025abs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE fieldname026(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE fieldname026abs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE fieldname027(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE fieldname027abs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE fieldname028(ncalc=i2) = f8 WITH protect
 DECLARE fieldname028abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE fieldname029(ncalc=i2) = f8 WITH protect
 DECLARE fieldname029abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE fieldname0html(ndummy=i2) = null WITH protect
 DECLARE sectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE initializereport(dummy) = null WITH protect
 DECLARE genexcel(null) = null WITH protect
 DECLARE _hreport = i4 WITH noconstant(0), protect
 DECLARE _yoffset = f8 WITH noconstant(0.0), protect
 DECLARE _xoffset = f8 WITH noconstant(0.0), protect
 DECLARE _htmlfilehandle = i4 WITH noconstant(0), protect
 DECLARE _htmlfilestat = i4 WITH noconstant(0), protect
 DECLARE _vcwriteln = vc WITH protect
 DECLARE _bgeneratehtml = i1 WITH noconstant(evaluate(validate(request->output_device,"N"),"MINE",1,
   '"MINE"',1,
   0)), protect
 DECLARE ml_generateexcel = i2 WITH noconstant(evaluate(validate(request->output_device,"N"),"minE",1,
   '"minE"',1,
   0)), protect
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
 DECLARE _rptpage = i4 WITH noconstant(0), protect
 DECLARE _outputtype = i2 WITH noconstant(rpt_pdf), protect
 DECLARE _bholdcontinue = i2 WITH noconstant(0), protect
 DECLARE _bcontsection = i2 WITH noconstant(0), protect
 DECLARE _remfacilitylist = i2 WITH noconstant(1), protect
 DECLARE _bcontfieldname07 = i2 WITH noconstant(0), protect
 DECLARE _remphysicianlist = i2 WITH noconstant(1), protect
 DECLARE _bcontfieldname08 = i2 WITH noconstant(0), protect
 DECLARE _rempatientnameone = i2 WITH noconstant(1), protect
 DECLARE _remmrndisplayrowone = i2 WITH noconstant(1), protect
 DECLARE _remfindisplayrowone = i2 WITH noconstant(1), protect
 DECLARE _remdischrowone = i2 WITH noconstant(1), protect
 DECLARE _remcellname69 = i2 WITH noconstant(1), protect
 DECLARE _remcellname70 = i2 WITH noconstant(1), protect
 DECLARE _remdeficageone = i2 WITH noconstant(1), protect
 DECLARE _remchartageone = i2 WITH noconstant(1), protect
 DECLARE _remlocationone = i2 WITH noconstant(1), protect
 DECLARE _bcontfieldname019 = i2 WITH noconstant(0), protect
 DECLARE _rempatientnametwo = i2 WITH noconstant(1), protect
 DECLARE _remmrndisplayrowtwo = i2 WITH noconstant(1), protect
 DECLARE _remfindisplayrowtwo = i2 WITH noconstant(1), protect
 DECLARE _remdischrowtwo = i2 WITH noconstant(1), protect
 DECLARE _remcellname72 = i2 WITH noconstant(1), protect
 DECLARE _remcellname73 = i2 WITH noconstant(1), protect
 DECLARE _remdeficagetwo = i2 WITH noconstant(1), protect
 DECLARE _remchartagetwo = i2 WITH noconstant(1), protect
 DECLARE _remlocationtwo = i2 WITH noconstant(1), protect
 DECLARE _bcontfieldname020 = i2 WITH noconstant(0), protect
 DECLARE _remphystotaldef = i2 WITH noconstant(1), protect
 DECLARE _remphystotaldefic = i2 WITH noconstant(1), protect
 DECLARE _bcontfieldname023 = i2 WITH noconstant(0), protect
 DECLARE _remcellname6 = i2 WITH noconstant(1), protect
 DECLARE _remcellname7 = i2 WITH noconstant(1), protect
 DECLARE _remcellname10 = i2 WITH noconstant(1), protect
 DECLARE _bcontfieldname024 = i2 WITH noconstant(0), protect
 DECLARE _remorganizationtotal = i2 WITH noconstant(1), protect
 DECLARE _remcellname78 = i2 WITH noconstant(1), protect
 DECLARE _remorgtotaldefic = i2 WITH noconstant(1), protect
 DECLARE _bcontfieldname025 = i2 WITH noconstant(0), protect
 DECLARE _remcellname23 = i2 WITH noconstant(1), protect
 DECLARE _bcontfieldname026 = i2 WITH noconstant(0), protect
 DECLARE _remorganizationtotal0 = i2 WITH noconstant(1), protect
 DECLARE _remgrandtotaldefic95 = i2 WITH noconstant(1), protect
 DECLARE _remcellname102 = i2 WITH noconstant(1), protect
 DECLARE _bcontfieldname027 = i2 WITH noconstant(0), protect
 DECLARE _times12bi10485760 = i4 WITH noconstant(0), protect
 DECLARE _times10b0 = i4 WITH noconstant(0), protect
 DECLARE _times11b0 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _times10bi255 = i4 WITH noconstant(0), protect
 DECLARE _pen0s0c0 = i4 WITH noconstant(0), protect
 DECLARE _pen20s0c0 = i4 WITH noconstant(0), protect
 DECLARE _pen25s0c0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
 DECLARE _pen15s0c0 = i4 WITH noconstant(0), protect
 DECLARE statuscomplete = f8 WITH constant(uar_get_code_by("MEANING",14172,"COMPLETE")), protect
 DECLARE ml_bcontfieldnamechartage = i2 WITH noconstant(0), protect
 DECLARE ml_chartagelist = i2 WITH noconstant(1), protect
 DECLARE ml_holdchartagelist = i2 WITH protect, noconstant(0)
 DECLARE ml_bcontfieldnamedeficiencyage = i2 WITH noconstant(0), protect
 DECLARE ml_deficiencyagelist = i2 WITH noconstant(1), protect
 DECLARE ml_holddeficiencyagelist = i2 WITH protect, noconstant(0)
 DECLARE ml_bcontfieldnameposition = i2 WITH noconstant(0), protect
 DECLARE ml_positionlist = i2 WITH noconstant(1), protect
 DECLARE ml_holdpositionlist = i2 WITH protect, noconstant(0)
 DECLARE ms_chartage_clause = vc WITH protect, noconstant("1=1")
 DECLARE ms_deficiencyage_clause = vc WITH protect, noconstant("1=1")
 DECLARE ms_position_clause = vc WITH protect, noconstant("1=1")
 DECLARE ml_position_loop = i4 WITH protect, noconstant(0)
 IF (trim( $MS_CHARTAGE,3)="Chart Age < 15 Days")
  SET ms_chartage_clause = "data->qual[d.seq]->CHART_AGE < 15"
 ELSEIF (trim( $MS_CHARTAGE,3)="Chart Age < 30 Days")
  SET ms_chartage_clause = "data->qual[d.seq]->CHART_AGE < 30"
 ELSEIF (trim( $MS_CHARTAGE,3)="Chart Age > 31 Days")
  SET ms_chartage_clause = "data->qual[d.seq]->CHART_AGE > 31"
 ENDIF
 IF (trim( $MS_DEFAGE,3)="Deficiency Age < 15 Days")
  SET ms_deficiencyage_clause = "(data->qual[d.seq]->defic_qual[ddefic.seq]->DEFIC_AGE/24)< 15"
 ELSEIF (trim( $MS_DEFAGE,3)="Deficiency Age < 30 Days")
  SET ms_deficiencyage_clause = "(data->qual[d.seq]->defic_qual[ddefic.seq]->DEFIC_AGE/24)< 30"
 ELSEIF (trim( $MS_DEFAGE,3)="Deficiency Age > 31 Days")
  SET ms_deficiencyage_clause = "(data->qual[d.seq]->defic_qual[ddefic.seq]->DEFIC_AGE/24)> 31"
 ENDIF
 IF ((positions->cnt > 0))
  SET ms_position_clause = "data->qual[d.seq]->PHYSICIAN_POSITION_CD in("
  FOR (ml_position_loop = 1 TO positions->cnt)
    SET ms_position_clause = concat(ms_position_clause,trim(cnvtstring(positions->qual[
       ml_position_loop].item_id,20),3))
    IF (ml_position_loop > 1
     AND (ml_position_loop != positions->cnt))
     SET ms_position_clause = concat(ms_position_clause,",")
    ENDIF
    IF ((ml_position_loop=positions->cnt))
     SET ms_position_clause = concat(ms_position_clause,")")
    ENDIF
  ENDFOR
 ENDIF
 SUBROUTINE cclbuildhlink(vcprogname,vcparams,nwindow,vcdescription)
   DECLARE vcreturn = vc WITH private, noconstant(vcdescription)
   IF (_htmlfilehandle != 0)
    SET vcreturn = build(^<a href='javascript:CCLLINK("^,vcprogname,'","',vcparams,'",',
     nwindow,")'>",vcdescription,"</a>")
   ENDIF
   RETURN(vcreturn)
 END ;Subroutine
 SUBROUTINE pagebreak(dummy)
   SET _rptpage = uar_rptendpage(_hreport)
   SET _rptpage = uar_rptstartpage(_hreport)
   SET _yoffset = rptreport->m_margintop
 END ;Subroutine
 SUBROUTINE finalizereport(ssendreport)
   IF (_htmlfilehandle)
    SET _htmlfilestat = uar_fwrite("</html>",1,7,_htmlfilehandle)
    SET _htmlfilestat = uar_fclose(_htmlfilehandle)
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
      SET _errcnt = (_errcnt+ 1)
      SET stat = alterlist(rpterrors->errors,_errcnt)
      SET rpterrors->errors[_errcnt].m_severity = rpterror->m_severity
      SET rpterrors->errors[_errcnt].m_text = rpterror->m_text
      SET rpterrors->errors[_errcnt].m_source = rpterror->m_source
      SET _errorfound = uar_rptnexterror(_hreport,rpterror)
    ENDWHILE
    SET _rptstat = uar_rptdestroyreport(_hreport)
   ENDIF
 END ;Subroutine
 SUBROUTINE section(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sectionabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE fieldname00(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname00abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE fieldname00abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.121530), private
   IF ( NOT (_bgeneratehtml))
    RETURN(0.0)
   ENDIF
   SET rptsd->m_flags = 1056
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 10.000
   SET rptsd->m_height = 0.122
   SET _oldfont = uar_rptsetfont(_hreport,_times10bi255)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,rpt_white)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(cclbuildhlink(
        him_program_name,him_render_params,him_window,"Printer Friendly Version"),char(0))))
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE fieldname01(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname01abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE fieldname01abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.472461), private
   SET rptsd->m_flags = 1040
   SET rptsd->m_borders = bor(bor(rpt_sdtopborder,rpt_sdleftborder),rpt_sdrightborder)
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 10.000
   SET rptsd->m_height = 0.472
   SET _oldfont = uar_rptsetfont(_hreport,_times12bi10485760)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(uar_i18ngetmessage(
        _hi18nhandle,"Section_CellName0",build2("Deficiency Reporting by Physician",char(0))),char(0)
       )))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE fieldname02(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname02abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE fieldname02abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.403378), private
   SET rptsd->m_flags = 528
   SET rptsd->m_borders = bor(bor(rpt_sdbottomborder,rpt_sdleftborder),rpt_sdrightborder)
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 10.000
   SET rptsd->m_height = 0.403
   SET _oldfont = uar_rptsetfont(_hreport,_times12bi10485760)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(uar_i18ngetmessage(
        _hi18nhandle,"Section_CellName81",build2("Detailed Report",char(0))),char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE fieldname03(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname03abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE fieldname03abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.118449), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 10.000
   SET rptsd->m_height = 0.118
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(blank,char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE fieldname04(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname04abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE fieldname04abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.222083), private
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.375
   SET rptsd->m_height = 0.222
   SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(i18ndateprinted,char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.375)
   SET rptsd->m_width = 8.625
   SET rptsd->m_height = 0.222
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(vctodaydatetime,char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.375),offsety,(offsetx+ 1.375),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE fieldname05(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname05abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE fieldname05abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.227513), private
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.375
   SET rptsd->m_height = 0.228
   SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(i18nuserprinted,char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 288
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.375)
   SET rptsd->m_width = 8.625
   SET rptsd->m_height = 0.228
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(vcuser,char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.375),offsety,(offsetx+ 1.375),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE fieldname06(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname06abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE fieldname06abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.195004), private
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.375
   SET rptsd->m_height = 0.195
   SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(i18npromptsfilters,char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.375)
   SET rptsd->m_width = 8.625
   SET rptsd->m_height = 0.195
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,"")
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.375),offsety,(offsetx+ 1.375),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE fieldname07(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname07abs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE fieldname07abs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.235434), private
   DECLARE growsum = i4 WITH noconstant(0), private
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
   SET rptsd->m_x = (offsetx+ 3.438)
   SET rptsd->m_width = 6.563
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremfacilitylist = _remfacilitylist
   IF (_remfacilitylist > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfacilitylist,((size(
        nullterm(build2(facilitylist,char(0)))) - _remfacilitylist)+ 1),nullterm(build2(facilitylist,
         char(0))))))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remfacilitylist = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfacilitylist,((size(nullterm(build2(
          facilitylist,char(0)))) - _remfacilitylist)+ 1),nullterm(build2(facilitylist,char(0))))))))
     SET _remfacilitylist = (_remfacilitylist+ rptsd->m_drawlength)
    ELSE
     SET _remfacilitylist = 0
    ENDIF
    SET growsum = (growsum+ _remfacilitylist)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.375
   SET rptsd->m_height = sectionheight
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF (bcontinue=0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,"")
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.375)
   SET rptsd->m_width = 2.062
   SET rptsd->m_height = sectionheight
   SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF (bcontinue=0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(i18nfacilities,char(0))))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 260
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 3.438)
   SET rptsd->m_width = 6.563
   SET rptsd->m_height = sectionheight
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF (_holdremfacilitylist > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfacilitylist,((
        size(nullterm(build2(facilitylist,char(0)))) - _holdremfacilitylist)+ 1),nullterm(build2(
          facilitylist,char(0))))))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ELSE
    SET _remfacilitylist = _holdremfacilitylist
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.375),offsety,(offsetx+ 1.375),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.438),offsety,(offsetx+ 3.438),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE fieldname08(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname08abs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE fieldname08abs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.214106), private
   DECLARE growsum = i4 WITH noconstant(0), private
   IF (bcontinue=0)
    SET _remphysicianlist = 1
   ENDIF
   SET rptsd->m_flags = 261
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 3.438)
   SET rptsd->m_width = 6.563
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremphysicianlist = _remphysicianlist
   IF (_remphysicianlist > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remphysicianlist,((size(
        nullterm(build2(physicianlist,char(0)))) - _remphysicianlist)+ 1),nullterm(build2(
         physicianlist,char(0))))))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remphysicianlist = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remphysicianlist,((size(nullterm(build2(
          physicianlist,char(0)))) - _remphysicianlist)+ 1),nullterm(build2(physicianlist,char(0)))))
     )))
     SET _remphysicianlist = (_remphysicianlist+ rptsd->m_drawlength)
    ELSE
     SET _remphysicianlist = 0
    ENDIF
    SET growsum = (growsum+ _remphysicianlist)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.375
   SET rptsd->m_height = sectionheight
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF (bcontinue=0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,"")
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.375)
   SET rptsd->m_width = 2.062
   SET rptsd->m_height = sectionheight
   SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF (bcontinue=0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(uar_i18ngetmessage(
         _hi18nhandle,"Section_CellName4",build2("Physician(s):",char(0))),char(0))))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 260
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 3.438)
   SET rptsd->m_width = 6.563
   SET rptsd->m_height = sectionheight
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF (_holdremphysicianlist > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremphysicianlist,((
        size(nullterm(build2(physicianlist,char(0)))) - _holdremphysicianlist)+ 1),nullterm(build2(
          physicianlist,char(0))))))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ELSE
    SET _remphysicianlist = _holdremphysicianlist
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.375),offsety,(offsetx+ 1.375),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.438),offsety,(offsetx+ 3.438),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE fieldnamechartage(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldnamechartageabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE fieldnamechartageabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.235434), private
   DECLARE growsum = i4 WITH noconstant(0), private
   IF ( NOT (i1multifacilitylogicind))
    RETURN(0.0)
   ENDIF
   IF (bcontinue=0)
    SET ml_chartagelist = 1
   ENDIF
   SET rptsd->m_flags = 261
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 3.438)
   SET rptsd->m_width = 6.563
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET ml_holdchartagelist = ml_chartagelist
   IF (ml_chartagelist > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(ml_chartagelist,((size(
        nullterm(build2(chartagelist,char(0)))) - ml_chartagelist)+ 1),nullterm(build2(chartagelist,
         char(0))))))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET ml_chartagelist = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(ml_chartagelist,((size(nullterm(build2(
          chartagelist,char(0)))) - ml_chartagelist)+ 1),nullterm(build2(chartagelist,char(0))))))))
     SET ml_chartagelist = (ml_chartagelist+ rptsd->m_drawlength)
    ELSE
     SET ml_chartagelist = 0
    ENDIF
    SET growsum = (growsum+ ml_chartagelist)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.375
   SET rptsd->m_height = sectionheight
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF (bcontinue=0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,"")
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.375)
   SET rptsd->m_width = 2.062
   SET rptsd->m_height = sectionheight
   SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF (bcontinue=0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2("Chart Age:",char(0))))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 260
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 3.438)
   SET rptsd->m_width = 6.563
   SET rptsd->m_height = sectionheight
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF (ml_holdchartagelist > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(ml_holdchartagelist,((
        size(nullterm(build2(chartagelist,char(0)))) - ml_holdchartagelist)+ 1),nullterm(build2(
          chartagelist,char(0))))))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ELSE
    SET ml_chartagelist = ml_holdchartagelist
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.375),offsety,(offsetx+ 1.375),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.438),offsety,(offsetx+ 3.438),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE fieldnamedeficiencyage(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldnamedeficiencyageabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE fieldnamedeficiencyageabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.235434), private
   DECLARE growsum = i4 WITH noconstant(0), private
   IF ( NOT (i1multifacilitylogicind))
    RETURN(0.0)
   ENDIF
   IF (bcontinue=0)
    SET ml_deficiencyagelist = 1
   ENDIF
   SET rptsd->m_flags = 261
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 3.438)
   SET rptsd->m_width = 6.563
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET ml_holddeficiencyagelist = ml_deficiencyagelist
   IF (ml_deficiencyagelist > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(ml_deficiencyagelist,((
       size(nullterm(build2(deficiencyagelist,char(0)))) - ml_deficiencyagelist)+ 1),nullterm(build2(
         deficiencyagelist,char(0))))))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET ml_deficiencyagelist = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(ml_deficiencyagelist,((size(nullterm(
         build2(deficiencyagelist,char(0)))) - ml_deficiencyagelist)+ 1),nullterm(build2(
         deficiencyagelist,char(0))))))))
     SET ml_deficiencyagelist = (ml_deficiencyagelist+ rptsd->m_drawlength)
    ELSE
     SET ml_deficiencyagelist = 0
    ENDIF
    SET growsum = (growsum+ ml_deficiencyagelist)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.375
   SET rptsd->m_height = sectionheight
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF (bcontinue=0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,"")
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.375)
   SET rptsd->m_width = 2.062
   SET rptsd->m_height = sectionheight
   SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF (bcontinue=0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2("Deficiency Age:",char(0))))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 260
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 3.438)
   SET rptsd->m_width = 6.563
   SET rptsd->m_height = sectionheight
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF (ml_holddeficiencyagelist > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(ml_holddeficiencyagelist,
        ((size(nullterm(build2(deficiencyagelist,char(0)))) - ml_holddeficiencyagelist)+ 1),nullterm(
         build2(deficiencyagelist,char(0))))))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ELSE
    SET ml_deficiencyagelist = ml_holddeficiencyagelist
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.375),offsety,(offsetx+ 1.375),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.438),offsety,(offsetx+ 3.438),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE fieldnameposition(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldnamepositionabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE fieldnamepositionabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.235434), private
   DECLARE growsum = i4 WITH noconstant(0), private
   IF ( NOT (i1multifacilitylogicind))
    RETURN(0.0)
   ENDIF
   IF (bcontinue=0)
    SET ml_positionlist = 1
   ENDIF
   SET rptsd->m_flags = 261
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 3.438)
   SET rptsd->m_width = 6.563
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET ml_holdpositionlist = ml_positionlist
   IF (ml_positionlist > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(ml_positionlist,((size(
        nullterm(build2(positionlist,char(0)))) - ml_positionlist)+ 1),nullterm(build2(positionlist,
         char(0))))))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET ml_positionlist = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(ml_positionlist,((size(nullterm(build2(
          positionlist,char(0)))) - ml_positionlist)+ 1),nullterm(build2(positionlist,char(0))))))))
     SET ml_positionlist = (ml_positionlist+ rptsd->m_drawlength)
    ELSE
     SET ml_positionlist = 0
    ENDIF
    SET growsum = (growsum+ ml_positionlist)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.375
   SET rptsd->m_height = sectionheight
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF (bcontinue=0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,"")
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.375)
   SET rptsd->m_width = 2.062
   SET rptsd->m_height = sectionheight
   SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF (bcontinue=0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2("Positions:",char(0))))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 260
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 3.438)
   SET rptsd->m_width = 6.563
   SET rptsd->m_height = sectionheight
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF (ml_holdpositionlist > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(ml_holdpositionlist,((
        size(nullterm(build2(positionlist,char(0)))) - ml_holdpositionlist)+ 1),nullterm(build2(
          positionlist,char(0))))))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ELSE
    SET ml_positionlist = ml_holdpositionlist
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.375),offsety,(offsetx+ 1.375),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.438),offsety,(offsetx+ 3.438),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE fieldname09(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname09abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE fieldname09abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.238356), private
   IF ( NOT (negate(_bgeneratehtml)))
    RETURN(0.0)
   ENDIF
   SET rptsd->m_flags = 576
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 10.000
   SET rptsd->m_height = 0.238
   SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(pageofpage,char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE fieldname010(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname010abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE fieldname010abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.202218), private
   IF ( NOT (rowcount > 1))
    RETURN(0.0)
   ENDIF
   SET rptsd->m_flags = 1056
   SET rptsd->m_borders = rpt_sdtopborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.200
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.375
   SET rptsd->m_height = 0.202
   SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(uar_i18ngetmessage(
        _hi18nhandle,"Section_CellName27",build2("Patient",char(0))),char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 1088
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.375)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = 0.202
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,"")
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.375)
   SET rptsd->m_width = 0.875
   SET rptsd->m_height = 0.202
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,"")
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 1056
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.200
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 3.250)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.202
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(uar_i18ngetmessage(
        _hi18nhandle,"Section_CellName53",build2("Discharge",char(0))),char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 4.375)
   SET rptsd->m_width = 1.312
   SET rptsd->m_height = 0.202
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,"")
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 5.688)
   SET rptsd->m_width = 1.188
   SET rptsd->m_height = 0.202
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,"")
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 6.875)
   SET rptsd->m_width = 0.875
   SET rptsd->m_height = 0.202
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(uar_i18ngetmessage(
        _hi18nhandle,"Section_CellName24",build2("Deficiency",char(0))),char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 7.750)
   SET rptsd->m_width = 0.875
   SET rptsd->m_height = 0.202
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(uar_i18ngetmessage(
        _hi18nhandle,"Section_CellName5",build2("Chart",char(0))),char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_paddingwidth = 0.200
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 8.625)
   SET rptsd->m_width = 1.375
   SET rptsd->m_height = 0.202
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,"")
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.375),offsety,(offsetx+ 1.375),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.375),offsety,(offsetx+ 2.375),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.250),offsety,(offsetx+ 3.250),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.375),offsety,(offsetx+ 4.375),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.688),offsety,(offsetx+ 5.688),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.875),offsety,(offsetx+ 6.875),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.750),offsety,(offsetx+ 7.750),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.625),offsety,(offsetx+ 8.625),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE fieldname011(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname011abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE fieldname011abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.185109), private
   IF ( NOT (rowcount > 1))
    RETURN(0.0)
   ENDIF
   SET rptsd->m_flags = 1056
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.200
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.375
   SET rptsd->m_height = 0.185
   SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(uar_i18ngetmessage(
        _hi18nhandle,"Section_CellName33",build2("Name",char(0))),char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.375)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = 0.185
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(uar_i18ngetmessage(
        _hi18nhandle,"Section_CellName31",build2("MRN",char(0))),char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.375)
   SET rptsd->m_width = 0.875
   SET rptsd->m_height = 0.185
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(uar_i18ngetmessage(
        _hi18nhandle,"Section_CellName32",build2("FIN",char(0))),char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.200
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 3.250)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.185
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(uar_i18ngetmessage(
        _hi18nhandle,"Section_CellName54",build2("Date",char(0))),char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 4.375)
   SET rptsd->m_width = 1.312
   SET rptsd->m_height = 0.185
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(uar_i18ngetmessage(
        _hi18nhandle,"Section_CellName66",build2("Deficiency",char(0))),char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 5.688)
   SET rptsd->m_width = 1.188
   SET rptsd->m_height = 0.185
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(uar_i18ngetmessage(
        _hi18nhandle,"Section_CellName29",build2("Status",char(0))),char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 6.875)
   SET rptsd->m_width = 0.875
   SET rptsd->m_height = 0.185
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(uar_i18ngetmessage(
        _hi18nhandle,"Section_CellName8",build2("Age",char(0))),char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 7.750)
   SET rptsd->m_width = 0.875
   SET rptsd->m_height = 0.185
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(uar_i18ngetmessage(
        _hi18nhandle,"Section_CellName217",build2("Age",char(0))),char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_paddingwidth = 0.200
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 8.625)
   SET rptsd->m_width = 1.375
   SET rptsd->m_height = 0.185
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(uar_i18ngetmessage(
        _hi18nhandle,"Section_CellName203",build2("Location",char(0))),char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.375),offsety,(offsetx+ 1.375),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.375),offsety,(offsetx+ 2.375),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.250),offsety,(offsetx+ 3.250),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.375),offsety,(offsetx+ 4.375),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.688),offsety,(offsetx+ 5.688),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.875),offsety,(offsetx+ 6.875),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.750),offsety,(offsetx+ 7.750),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.625),offsety,(offsetx+ 8.625),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE fieldname012(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname012abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE fieldname012abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.121592), private
   IF ( NOT (0))
    RETURN(0.0)
   ENDIF
   SET rptsd->m_flags = 1056
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 10.000
   SET rptsd->m_height = 0.122
   SET _oldfont = uar_rptsetfont(_hreport,_times11b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen15s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,"")
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE fieldname013(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname013abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE fieldname013abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.232931), private
   SET rptsd->m_flags = 1056
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 10.000
   SET rptsd->m_height = 0.233
   SET _oldfont = uar_rptsetfont(_hreport,_times11b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen15s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(organization,char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE fieldname014(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname014abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE fieldname014abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.124581), private
   IF ( NOT (0))
    RETURN(0.0)
   ENDIF
   SET rptsd->m_flags = 1056
   SET rptsd->m_borders = rpt_sdtopborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.200
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = 0.125
   SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,"")
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.250)
   SET rptsd->m_width = 8.750
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,"")
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.250),offsety,(offsetx+ 1.250),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE fieldname015(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname015abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE fieldname015abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.222083), private
   SET rptsd->m_flags = 1056
   SET rptsd->m_borders = rpt_sdtopborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.200
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = 0.222
   SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(uar_i18ngetmessage(
        _hi18nhandle,"Section_physicianDisplay",build2("Physician:",char(0))),char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.250)
   SET rptsd->m_width = 8.750
   SET rptsd->m_height = 0.222
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(physicianname,char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.250),offsety,(offsetx+ 1.250),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE fieldname016(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname016abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE fieldname016abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.215711), private
   SET rptsd->m_flags = 1056
   SET rptsd->m_borders = rpt_sdtopborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.200
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.375
   SET rptsd->m_height = 0.216
   SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(uar_i18ngetmessage(
        _hi18nhandle,"Section_CellName49",build2("Patient",char(0))),char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 1088
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.375)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = 0.216
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,"")
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.375)
   SET rptsd->m_width = 0.875
   SET rptsd->m_height = 0.216
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,"")
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 1056
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.200
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 3.250)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.216
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(uar_i18ngetmessage(
        _hi18nhandle,"Section_CellName216",build2("Discharge",char(0))),char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 4.375)
   SET rptsd->m_width = 1.312
   SET rptsd->m_height = 0.216
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,"")
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 5.688)
   SET rptsd->m_width = 1.188
   SET rptsd->m_height = 0.216
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,"")
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 6.875)
   SET rptsd->m_width = 0.875
   SET rptsd->m_height = 0.216
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(uar_i18ngetmessage(
        _hi18nhandle,"Section_CellName211",build2("Deficiency",char(0))),char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 7.750)
   SET rptsd->m_width = 0.875
   SET rptsd->m_height = 0.216
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(uar_i18ngetmessage(
        _hi18nhandle,"Section_CellName219",build2("Chart",char(0))),char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_paddingwidth = 0.200
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 8.625)
   SET rptsd->m_width = 1.375
   SET rptsd->m_height = 0.216
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,"")
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.375),offsety,(offsetx+ 1.375),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.375),offsety,(offsetx+ 2.375),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.250),offsety,(offsetx+ 3.250),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.375),offsety,(offsetx+ 4.375),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.688),offsety,(offsetx+ 5.688),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.875),offsety,(offsetx+ 6.875),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.750),offsety,(offsetx+ 7.750),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.625),offsety,(offsetx+ 8.625),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE fieldname017(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname017abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE fieldname017abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.187624), private
   SET rptsd->m_flags = 1056
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.200
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.375
   SET rptsd->m_height = 0.188
   SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(uar_i18ngetmessage(
        _hi18nhandle,"Section_CellName41",build2("Name",char(0))),char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.375)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(uar_i18ngetmessage(
        _hi18nhandle,"Section_CellName39",build2("MRN",char(0))),char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.375)
   SET rptsd->m_width = 0.875
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(uar_i18ngetmessage(
        _hi18nhandle,"Section_CellName40",build2("FIN",char(0))),char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.200
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 3.250)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(uar_i18ngetmessage(
        _hi18nhandle,"Section_CellName215",build2("Date",char(0))),char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 4.375)
   SET rptsd->m_width = 1.312
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(uar_i18ngetmessage(
        _hi18nhandle,"Section_CellName214",build2("Deficiency",char(0))),char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 5.688)
   SET rptsd->m_width = 1.188
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(uar_i18ngetmessage(
        _hi18nhandle,"Section_CellName213",build2("Status",char(0))),char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 6.875)
   SET rptsd->m_width = 0.875
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(uar_i18ngetmessage(
        _hi18nhandle,"Section_CellName212",build2("Age",char(0))),char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 7.750)
   SET rptsd->m_width = 0.875
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(uar_i18ngetmessage(
        _hi18nhandle,"Section_CellName218",build2("Age",char(0))),char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_paddingwidth = 0.200
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 8.625)
   SET rptsd->m_width = 1.375
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(uar_i18ngetmessage(
        _hi18nhandle,"Section_CellName220",build2("Location",char(0))),char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.375),offsety,(offsetx+ 1.375),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.375),offsety,(offsetx+ 2.375),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.250),offsety,(offsetx+ 3.250),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.375),offsety,(offsetx+ 4.375),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.688),offsety,(offsetx+ 5.688),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.875),offsety,(offsetx+ 6.875),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.750),offsety,(offsetx+ 7.750),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.625),offsety,(offsetx+ 8.625),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE fieldname018(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname018abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE fieldname018abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.113252), private
   IF ( NOT (0))
    RETURN(0.0)
   ENDIF
   SET rptsd->m_flags = 288
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.200
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 10.000
   SET rptsd->m_height = 0.113
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(blank2,char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE fieldname019(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname019abs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE fieldname019abs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.210705), private
   DECLARE growsum = i4 WITH noconstant(0), private
   IF ( NOT (mod(rowcount,2)=1))
    RETURN(0.0)
   ENDIF
   IF (bcontinue=0)
    SET _rempatientnameone = 1
    SET _remmrndisplayrowone = 1
    SET _remfindisplayrowone = 1
    SET _remdischrowone = 1
    SET _remcellname69 = 1
    SET _remcellname70 = 1
    SET _remdeficageone = 1
    SET _remchartageone = 1
    SET _remlocationone = 1
   ENDIF
   SET rptsd->m_flags = 293
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.200
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.375
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdrempatientnameone = _rempatientnameone
   IF (_rempatientnameone > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_rempatientnameone,((size(
        nullterm(build2(patientnameone,char(0)))) - _rempatientnameone)+ 1),nullterm(build2(
         patientnameone,char(0))))))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y))
     AND displayind)
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _rempatientnameone = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_rempatientnameone,((size(nullterm(build2(
          patientnameone,char(0)))) - _rempatientnameone)+ 1),nullterm(build2(patientnameone,char(0))
        ))))))
     SET _rempatientnameone = (_rempatientnameone+ rptsd->m_drawlength)
    ELSE
     SET _rempatientnameone = 0
    ENDIF
    SET growsum = (growsum+ _rempatientnameone)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 293
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.375)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremmrndisplayrowone = _remmrndisplayrowone
   IF (_remmrndisplayrowone > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remmrndisplayrowone,((
       size(nullterm(build2(mrndisplayrowone,char(0)))) - _remmrndisplayrowone)+ 1),nullterm(build2(
         mrndisplayrowone,char(0))))))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y))
     AND displayind)
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remmrndisplayrowone = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remmrndisplayrowone,((size(nullterm(
         build2(mrndisplayrowone,char(0)))) - _remmrndisplayrowone)+ 1),nullterm(build2(
         mrndisplayrowone,char(0))))))))
     SET _remmrndisplayrowone = (_remmrndisplayrowone+ rptsd->m_drawlength)
    ELSE
     SET _remmrndisplayrowone = 0
    ENDIF
    SET growsum = (growsum+ _remmrndisplayrowone)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 293
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.375)
   SET rptsd->m_width = 0.875
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremfindisplayrowone = _remfindisplayrowone
   IF (_remfindisplayrowone > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfindisplayrowone,((
       size(nullterm(build2(fin,char(0)))) - _remfindisplayrowone)+ 1),nullterm(build2(fin,char(0))))
      ))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y))
     AND displayind)
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remfindisplayrowone = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfindisplayrowone,((size(nullterm(
         build2(fin,char(0)))) - _remfindisplayrowone)+ 1),nullterm(build2(fin,char(0))))))))
     SET _remfindisplayrowone = (_remfindisplayrowone+ rptsd->m_drawlength)
    ELSE
     SET _remfindisplayrowone = 0
    ENDIF
    SET growsum = (growsum+ _remfindisplayrowone)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 293
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.200
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 3.250)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremdischrowone = _remdischrowone
   IF (_remdischrowone > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remdischrowone,((size(
        nullterm(build2(format(disch_dt_tm,"@SHORTDATE"),char(0)))) - _remdischrowone)+ 1),nullterm(
        build2(format(disch_dt_tm,"@SHORTDATE"),char(0))))))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y))
     AND displayind)
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remdischrowone = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remdischrowone,((size(nullterm(build2(
          format(disch_dt_tm,"@SHORTDATE"),char(0)))) - _remdischrowone)+ 1),nullterm(build2(format(
          disch_dt_tm,"@SHORTDATE"),char(0))))))))
     SET _remdischrowone = (_remdischrowone+ rptsd->m_drawlength)
    ELSE
     SET _remdischrowone = 0
    ENDIF
    SET growsum = (growsum+ _remdischrowone)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 293
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 4.375)
   SET rptsd->m_width = 1.312
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremcellname69 = _remcellname69
   IF (_remcellname69 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remcellname69,((size(
        nullterm(build2(deficiency_name,char(0)))) - _remcellname69)+ 1),nullterm(build2(
         deficiency_name,char(0))))))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remcellname69 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remcellname69,((size(nullterm(build2(
          deficiency_name,char(0)))) - _remcellname69)+ 1),nullterm(build2(deficiency_name,char(0))))
      ))))
     SET _remcellname69 = (_remcellname69+ rptsd->m_drawlength)
    ELSE
     SET _remcellname69 = 0
    ENDIF
    SET growsum = (growsum+ _remcellname69)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 293
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 5.688)
   SET rptsd->m_width = 1.188
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremcellname70 = _remcellname70
   IF (_remcellname70 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remcellname70,((size(
        nullterm(build2(deficiency_status,char(0)))) - _remcellname70)+ 1),nullterm(build2(
         deficiency_status,char(0))))))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remcellname70 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remcellname70,((size(nullterm(build2(
          deficiency_status,char(0)))) - _remcellname70)+ 1),nullterm(build2(deficiency_status,char(0
          ))))))))
     SET _remcellname70 = (_remcellname70+ rptsd->m_drawlength)
    ELSE
     SET _remcellname70 = 0
    ENDIF
    SET growsum = (growsum+ _remcellname70)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 293
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 6.875)
   SET rptsd->m_width = 0.875
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremdeficageone = _remdeficageone
   IF (_remdeficageone > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remdeficageone,((size(
        nullterm(build2(deficageone,char(0)))) - _remdeficageone)+ 1),nullterm(build2(deficageone,
         char(0))))))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remdeficageone = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remdeficageone,((size(nullterm(build2(
          deficageone,char(0)))) - _remdeficageone)+ 1),nullterm(build2(deficageone,char(0))))))))
     SET _remdeficageone = (_remdeficageone+ rptsd->m_drawlength)
    ELSE
     SET _remdeficageone = 0
    ENDIF
    SET growsum = (growsum+ _remdeficageone)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 293
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 7.750)
   SET rptsd->m_width = 0.875
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremchartageone = _remchartageone
   IF (_remchartageone > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remchartageone,((size(
        nullterm(build2(chartageone,char(0)))) - _remchartageone)+ 1),nullterm(build2(chartageone,
         char(0))))))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y))
     AND displayind)
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remchartageone = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remchartageone,((size(nullterm(build2(
          chartageone,char(0)))) - _remchartageone)+ 1),nullterm(build2(chartageone,char(0))))))))
     SET _remchartageone = (_remchartageone+ rptsd->m_drawlength)
    ELSE
     SET _remchartageone = 0
    ENDIF
    SET growsum = (growsum+ _remchartageone)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 293
   SET rptsd->m_paddingwidth = 0.200
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 8.625)
   SET rptsd->m_width = 1.375
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremlocationone = _remlocationone
   IF (_remlocationone > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlocationone,((size(
        nullterm(build2(locationone,char(0)))) - _remlocationone)+ 1),nullterm(build2(locationone,
         char(0))))))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y))
     AND displayind)
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlocationone = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlocationone,((size(nullterm(build2(
          locationone,char(0)))) - _remlocationone)+ 1),nullterm(build2(locationone,char(0))))))))
     SET _remlocationone = (_remlocationone+ rptsd->m_drawlength)
    ELSE
     SET _remlocationone = 0
    ENDIF
    SET growsum = (growsum+ _remlocationone)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 292
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.375
   SET rptsd->m_height = sectionheight
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF (_holdrempatientnameone > 0)
     IF (displayind)
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdrempatientnameone,(
         (size(nullterm(build2(patientnameone,char(0)))) - _holdrempatientnameone)+ 1),nullterm(
          build2(patientnameone,char(0))))))
     ELSE
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
     ENDIF
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ELSE
    SET _rempatientnameone = _holdrempatientnameone
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 292
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.375)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = sectionheight
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF (_holdremmrndisplayrowone > 0)
     IF (displayind)
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremmrndisplayrowone,
         ((size(nullterm(build2(mrndisplayrowone,char(0)))) - _holdremmrndisplayrowone)+ 1),nullterm(
          build2(mrndisplayrowone,char(0))))))
     ELSE
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
     ENDIF
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ELSE
    SET _remmrndisplayrowone = _holdremmrndisplayrowone
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 292
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.375)
   SET rptsd->m_width = 0.875
   SET rptsd->m_height = sectionheight
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF (_holdremfindisplayrowone > 0)
     IF (displayind)
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfindisplayrowone,
         ((size(nullterm(build2(fin,char(0)))) - _holdremfindisplayrowone)+ 1),nullterm(build2(fin,
           char(0))))))
     ELSE
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
     ENDIF
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ELSE
    SET _remfindisplayrowone = _holdremfindisplayrowone
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 292
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.200
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 3.250)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = sectionheight
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF (_holdremdischrowone > 0)
     IF (displayind)
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremdischrowone,((
         size(nullterm(build2(format(disch_dt_tm,"@SHORTDATE"),char(0)))) - _holdremdischrowone)+ 1),
         nullterm(build2(format(disch_dt_tm,"@SHORTDATE"),char(0))))))
     ELSE
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
     ENDIF
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ELSE
    SET _remdischrowone = _holdremdischrowone
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 292
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 4.375)
   SET rptsd->m_width = 1.312
   SET rptsd->m_height = sectionheight
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF (_holdremcellname69 > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremcellname69,((size
        (nullterm(build2(deficiency_name,char(0)))) - _holdremcellname69)+ 1),nullterm(build2(
          deficiency_name,char(0))))))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ELSE
    SET _remcellname69 = _holdremcellname69
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 292
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 5.688)
   SET rptsd->m_width = 1.188
   SET rptsd->m_height = sectionheight
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF (_holdremcellname70 > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremcellname70,((size
        (nullterm(build2(deficiency_status,char(0)))) - _holdremcellname70)+ 1),nullterm(build2(
          deficiency_status,char(0))))))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ELSE
    SET _remcellname70 = _holdremcellname70
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 292
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 6.875)
   SET rptsd->m_width = 0.875
   SET rptsd->m_height = sectionheight
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF (_holdremdeficageone > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremdeficageone,((
        size(nullterm(build2(deficageone,char(0)))) - _holdremdeficageone)+ 1),nullterm(build2(
          deficageone,char(0))))))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ELSE
    SET _remdeficageone = _holdremdeficageone
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 292
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 7.750)
   SET rptsd->m_width = 0.875
   SET rptsd->m_height = sectionheight
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF (_holdremchartageone > 0)
     IF (displayind)
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremchartageone,((
         size(nullterm(build2(chartageone,char(0)))) - _holdremchartageone)+ 1),nullterm(build2(
           chartageone,char(0))))))
     ELSE
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
     ENDIF
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ELSE
    SET _remchartageone = _holdremchartageone
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 292
   SET rptsd->m_paddingwidth = 0.200
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 8.625)
   SET rptsd->m_width = 1.375
   SET rptsd->m_height = sectionheight
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF (_holdremlocationone > 0)
     IF (displayind)
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremlocationone,((
         size(nullterm(build2(locationone,char(0)))) - _holdremlocationone)+ 1),nullterm(build2(
           locationone,char(0))))))
     ELSE
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
     ENDIF
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ELSE
    SET _remlocationone = _holdremlocationone
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.375),offsety,(offsetx+ 1.375),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.375),offsety,(offsetx+ 2.375),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.250),offsety,(offsetx+ 3.250),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.375),offsety,(offsetx+ 4.375),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.688),offsety,(offsetx+ 5.688),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.875),offsety,(offsetx+ 6.875),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.750),offsety,(offsetx+ 7.750),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.625),offsety,(offsetx+ 8.625),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE fieldname020(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname020abs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE fieldname020abs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.232931), private
   DECLARE growsum = i4 WITH noconstant(0), private
   IF ( NOT (mod(rowcount,2)=0))
    RETURN(0.0)
   ENDIF
   IF (bcontinue=0)
    SET _rempatientnametwo = 1
    SET _remmrndisplayrowtwo = 1
    SET _remfindisplayrowtwo = 1
    SET _remdischrowtwo = 1
    SET _remcellname72 = 1
    SET _remcellname73 = 1
    SET _remdeficagetwo = 1
    SET _remchartagetwo = 1
    SET _remlocationtwo = 1
   ENDIF
   SET rptsd->m_flags = 293
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.200
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.375
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdrempatientnametwo = _rempatientnametwo
   IF (_rempatientnametwo > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_rempatientnametwo,((size(
        nullterm(build2(patient_name,char(0)))) - _rempatientnametwo)+ 1),nullterm(build2(
         patient_name,char(0))))))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y))
     AND displayind)
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _rempatientnametwo = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_rempatientnametwo,((size(nullterm(build2(
          patient_name,char(0)))) - _rempatientnametwo)+ 1),nullterm(build2(patient_name,char(0))))))
    ))
     SET _rempatientnametwo = (_rempatientnametwo+ rptsd->m_drawlength)
    ELSE
     SET _rempatientnametwo = 0
    ENDIF
    SET growsum = (growsum+ _rempatientnametwo)
   ENDIF
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(232,232,232))
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 293
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.375)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremmrndisplayrowtwo = _remmrndisplayrowtwo
   IF (_remmrndisplayrowtwo > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remmrndisplayrowtwo,((
       size(nullterm(build2(mrn,char(0)))) - _remmrndisplayrowtwo)+ 1),nullterm(build2(mrn,char(0))))
      ))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y))
     AND displayind)
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remmrndisplayrowtwo = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remmrndisplayrowtwo,((size(nullterm(
         build2(mrn,char(0)))) - _remmrndisplayrowtwo)+ 1),nullterm(build2(mrn,char(0))))))))
     SET _remmrndisplayrowtwo = (_remmrndisplayrowtwo+ rptsd->m_drawlength)
    ELSE
     SET _remmrndisplayrowtwo = 0
    ENDIF
    SET growsum = (growsum+ _remmrndisplayrowtwo)
   ENDIF
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(232,232,232))
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 293
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.375)
   SET rptsd->m_width = 0.875
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremfindisplayrowtwo = _remfindisplayrowtwo
   IF (_remfindisplayrowtwo > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfindisplayrowtwo,((
       size(nullterm(build2(fin,char(0)))) - _remfindisplayrowtwo)+ 1),nullterm(build2(fin,char(0))))
      ))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y))
     AND displayind)
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remfindisplayrowtwo = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfindisplayrowtwo,((size(nullterm(
         build2(fin,char(0)))) - _remfindisplayrowtwo)+ 1),nullterm(build2(fin,char(0))))))))
     SET _remfindisplayrowtwo = (_remfindisplayrowtwo+ rptsd->m_drawlength)
    ELSE
     SET _remfindisplayrowtwo = 0
    ENDIF
    SET growsum = (growsum+ _remfindisplayrowtwo)
   ENDIF
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(232,232,232))
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 293
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.200
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 3.250)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremdischrowtwo = _remdischrowtwo
   IF (_remdischrowtwo > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remdischrowtwo,((size(
        nullterm(build2(format(disch_dt_tm,"@SHORTDATE"),char(0)))) - _remdischrowtwo)+ 1),nullterm(
        build2(format(disch_dt_tm,"@SHORTDATE"),char(0))))))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y))
     AND displayind)
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remdischrowtwo = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remdischrowtwo,((size(nullterm(build2(
          format(disch_dt_tm,"@SHORTDATE"),char(0)))) - _remdischrowtwo)+ 1),nullterm(build2(format(
          disch_dt_tm,"@SHORTDATE"),char(0))))))))
     SET _remdischrowtwo = (_remdischrowtwo+ rptsd->m_drawlength)
    ELSE
     SET _remdischrowtwo = 0
    ENDIF
    SET growsum = (growsum+ _remdischrowtwo)
   ENDIF
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(232,232,232))
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 293
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 4.375)
   SET rptsd->m_width = 1.312
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremcellname72 = _remcellname72
   IF (_remcellname72 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remcellname72,((size(
        nullterm(build2(deficiency_name,char(0)))) - _remcellname72)+ 1),nullterm(build2(
         deficiency_name,char(0))))))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remcellname72 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remcellname72,((size(nullterm(build2(
          deficiency_name,char(0)))) - _remcellname72)+ 1),nullterm(build2(deficiency_name,char(0))))
      ))))
     SET _remcellname72 = (_remcellname72+ rptsd->m_drawlength)
    ELSE
     SET _remcellname72 = 0
    ENDIF
    SET growsum = (growsum+ _remcellname72)
   ENDIF
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(232,232,232))
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 293
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 5.688)
   SET rptsd->m_width = 1.188
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremcellname73 = _remcellname73
   IF (_remcellname73 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remcellname73,((size(
        nullterm(build2(deficiency_status,char(0)))) - _remcellname73)+ 1),nullterm(build2(
         deficiency_status,char(0))))))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remcellname73 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remcellname73,((size(nullterm(build2(
          deficiency_status,char(0)))) - _remcellname73)+ 1),nullterm(build2(deficiency_status,char(0
          ))))))))
     SET _remcellname73 = (_remcellname73+ rptsd->m_drawlength)
    ELSE
     SET _remcellname73 = 0
    ENDIF
    SET growsum = (growsum+ _remcellname73)
   ENDIF
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(232,232,232))
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 293
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 6.875)
   SET rptsd->m_width = 0.875
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremdeficagetwo = _remdeficagetwo
   IF (_remdeficagetwo > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remdeficagetwo,((size(
        nullterm(build2(deficagetwo,char(0)))) - _remdeficagetwo)+ 1),nullterm(build2(deficagetwo,
         char(0))))))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remdeficagetwo = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remdeficagetwo,((size(nullterm(build2(
          deficagetwo,char(0)))) - _remdeficagetwo)+ 1),nullterm(build2(deficagetwo,char(0))))))))
     SET _remdeficagetwo = (_remdeficagetwo+ rptsd->m_drawlength)
    ELSE
     SET _remdeficagetwo = 0
    ENDIF
    SET growsum = (growsum+ _remdeficagetwo)
   ENDIF
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(232,232,232))
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 293
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 7.750)
   SET rptsd->m_width = 0.875
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremchartagetwo = _remchartagetwo
   IF (_remchartagetwo > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remchartagetwo,((size(
        nullterm(build2(chartagetwo,char(0)))) - _remchartagetwo)+ 1),nullterm(build2(chartagetwo,
         char(0))))))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y))
     AND displayind)
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remchartagetwo = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remchartagetwo,((size(nullterm(build2(
          chartagetwo,char(0)))) - _remchartagetwo)+ 1),nullterm(build2(chartagetwo,char(0))))))))
     SET _remchartagetwo = (_remchartagetwo+ rptsd->m_drawlength)
    ELSE
     SET _remchartagetwo = 0
    ENDIF
    SET growsum = (growsum+ _remchartagetwo)
   ENDIF
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(232,232,232))
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 293
   SET rptsd->m_paddingwidth = 0.200
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 8.625)
   SET rptsd->m_width = 1.375
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremlocationtwo = _remlocationtwo
   IF (_remlocationtwo > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlocationtwo,((size(
        nullterm(build2(locationtwo,char(0)))) - _remlocationtwo)+ 1),nullterm(build2(locationtwo,
         char(0))))))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y))
     AND displayind)
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlocationtwo = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlocationtwo,((size(nullterm(build2(
          locationtwo,char(0)))) - _remlocationtwo)+ 1),nullterm(build2(locationtwo,char(0))))))))
     SET _remlocationtwo = (_remlocationtwo+ rptsd->m_drawlength)
    ELSE
     SET _remlocationtwo = 0
    ENDIF
    SET growsum = (growsum+ _remlocationtwo)
   ENDIF
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(232,232,232))
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 292
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.375
   SET rptsd->m_height = sectionheight
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(232,232,232))
   IF (ncalc=rpt_render)
    IF (_holdrempatientnametwo > 0)
     IF (displayind)
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdrempatientnametwo,(
         (size(nullterm(build2(patient_name,char(0)))) - _holdrempatientnametwo)+ 1),nullterm(build2(
           patient_name,char(0))))))
     ELSE
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
     ENDIF
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ELSE
    SET _rempatientnametwo = _holdrempatientnametwo
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 292
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.375)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = sectionheight
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(232,232,232))
   IF (ncalc=rpt_render)
    IF (_holdremmrndisplayrowtwo > 0)
     IF (displayind)
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremmrndisplayrowtwo,
         ((size(nullterm(build2(mrn,char(0)))) - _holdremmrndisplayrowtwo)+ 1),nullterm(build2(mrn,
           char(0))))))
     ELSE
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
     ENDIF
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ELSE
    SET _remmrndisplayrowtwo = _holdremmrndisplayrowtwo
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 292
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.375)
   SET rptsd->m_width = 0.875
   SET rptsd->m_height = sectionheight
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(232,232,232))
   IF (ncalc=rpt_render)
    IF (_holdremfindisplayrowtwo > 0)
     IF (displayind)
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfindisplayrowtwo,
         ((size(nullterm(build2(fin,char(0)))) - _holdremfindisplayrowtwo)+ 1),nullterm(build2(fin,
           char(0))))))
     ELSE
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
     ENDIF
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ELSE
    SET _remfindisplayrowtwo = _holdremfindisplayrowtwo
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 292
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.200
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 3.250)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = sectionheight
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(232,232,232))
   IF (ncalc=rpt_render)
    IF (_holdremdischrowtwo > 0)
     IF (displayind)
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremdischrowtwo,((
         size(nullterm(build2(format(disch_dt_tm,"@SHORTDATE"),char(0)))) - _holdremdischrowtwo)+ 1),
         nullterm(build2(format(disch_dt_tm,"@SHORTDATE"),char(0))))))
     ELSE
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
     ENDIF
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ELSE
    SET _remdischrowtwo = _holdremdischrowtwo
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 292
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 4.375)
   SET rptsd->m_width = 1.312
   SET rptsd->m_height = sectionheight
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(232,232,232))
   IF (ncalc=rpt_render)
    IF (_holdremcellname72 > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremcellname72,((size
        (nullterm(build2(deficiency_name,char(0)))) - _holdremcellname72)+ 1),nullterm(build2(
          deficiency_name,char(0))))))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ELSE
    SET _remcellname72 = _holdremcellname72
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 292
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 5.688)
   SET rptsd->m_width = 1.188
   SET rptsd->m_height = sectionheight
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(232,232,232))
   IF (ncalc=rpt_render)
    IF (_holdremcellname73 > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremcellname73,((size
        (nullterm(build2(deficiency_status,char(0)))) - _holdremcellname73)+ 1),nullterm(build2(
          deficiency_status,char(0))))))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ELSE
    SET _remcellname73 = _holdremcellname73
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 292
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 6.875)
   SET rptsd->m_width = 0.875
   SET rptsd->m_height = sectionheight
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(232,232,232))
   IF (ncalc=rpt_render)
    IF (_holdremdeficagetwo > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremdeficagetwo,((
        size(nullterm(build2(deficagetwo,char(0)))) - _holdremdeficagetwo)+ 1),nullterm(build2(
          deficagetwo,char(0))))))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ELSE
    SET _remdeficagetwo = _holdremdeficagetwo
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 292
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 7.750)
   SET rptsd->m_width = 0.875
   SET rptsd->m_height = sectionheight
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(232,232,232))
   IF (ncalc=rpt_render)
    IF (_holdremchartagetwo > 0)
     IF (displayind)
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremchartagetwo,((
         size(nullterm(build2(chartagetwo,char(0)))) - _holdremchartagetwo)+ 1),nullterm(build2(
           chartagetwo,char(0))))))
     ELSE
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
     ENDIF
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ELSE
    SET _remchartagetwo = _holdremchartagetwo
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 292
   SET rptsd->m_paddingwidth = 0.200
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 8.625)
   SET rptsd->m_width = 1.375
   SET rptsd->m_height = sectionheight
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(232,232,232))
   IF (ncalc=rpt_render)
    IF (_holdremlocationtwo > 0)
     IF (displayind)
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremlocationtwo,((
         size(nullterm(build2(locationtwo,char(0)))) - _holdremlocationtwo)+ 1),nullterm(build2(
           locationtwo,char(0))))))
     ELSE
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
     ENDIF
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ELSE
    SET _remlocationtwo = _holdremlocationtwo
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.375),offsety,(offsetx+ 1.375),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.375),offsety,(offsetx+ 2.375),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.250),offsety,(offsetx+ 3.250),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.375),offsety,(offsetx+ 4.375),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.688),offsety,(offsetx+ 5.688),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.875),offsety,(offsetx+ 6.875),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.750),offsety,(offsetx+ 7.750),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.625),offsety,(offsetx+ 8.625),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE fieldname021(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname021abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE fieldname021abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.224309), private
   IF ( NOT (0))
    RETURN(0.0)
   ENDIF
   SET rptsd->m_flags = 288
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 10.000
   SET rptsd->m_height = 0.224
   SET _oldpen = uar_rptsetpen(_hreport,_pen25s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(blank3,char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE fieldname022(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname022abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE fieldname022abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.118578), private
   SET rptsd->m_flags = 272
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.200
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 10.000
   SET rptsd->m_height = 0.119
   SET _oldpen = uar_rptsetpen(_hreport,_pen25s0c0)
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,rpt_white)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,"")
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE fieldname023(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname023abs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE fieldname023abs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.229678), private
   DECLARE growsum = i4 WITH noconstant(0), private
   IF (bcontinue=0)
    SET _remphystotaldef = 1
    SET _remphystotaldefic = 1
   ENDIF
   SET rptsd->m_flags = 293
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.312
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen25s0c0)
   SET _holdremphystotaldef = _remphystotaldef
   IF (_remphystotaldef > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remphystotaldef,((size(
        nullterm(build2(uar_i18ngetmessage(_hi18nhandle,"Section_physTotalDef",build2(
            "Total Deficiencies:",char(0))),char(0)))) - _remphystotaldef)+ 1),nullterm(build2(
         uar_i18ngetmessage(_hi18nhandle,"Section_physTotalDef",build2("Total Deficiencies:",char(0))
          ),char(0))))))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remphystotaldef = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remphystotaldef,((size(nullterm(build2(
          uar_i18ngetmessage(_hi18nhandle,"Section_physTotalDef",build2("Total Deficiencies:",char(0)
            )),char(0)))) - _remphystotaldef)+ 1),nullterm(build2(uar_i18ngetmessage(_hi18nhandle,
          "Section_physTotalDef",build2("Total Deficiencies:",char(0))),char(0))))))))
     SET _remphystotaldef = (_remphystotaldef+ rptsd->m_drawlength)
    ELSE
     SET _remphystotaldef = 0
    ENDIF
    SET growsum = (growsum+ _remphystotaldef)
   ENDIF
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(255,255,128))
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 325
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.312)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen25s0c0)
   SET _holdremphystotaldefic = _remphystotaldefic
   IF (_remphystotaldefic > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remphystotaldefic,((size(
        nullterm(build2(phystotaldefic,char(0)))) - _remphystotaldefic)+ 1),nullterm(build2(
         phystotaldefic,char(0))))))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remphystotaldefic = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remphystotaldefic,((size(nullterm(build2(
          phystotaldefic,char(0)))) - _remphystotaldefic)+ 1),nullterm(build2(phystotaldefic,char(0))
        ))))))
     SET _remphystotaldefic = (_remphystotaldefic+ rptsd->m_drawlength)
    ELSE
     SET _remphystotaldefic = 0
    ENDIF
    SET growsum = (growsum+ _remphystotaldefic)
   ENDIF
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(255,255,128))
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 292
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.312
   SET rptsd->m_height = sectionheight
   SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen25s0c0)
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(255,255,128))
   IF (ncalc=rpt_render)
    IF (_holdremphystotaldef > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremphystotaldef,((
        size(nullterm(build2(uar_i18ngetmessage(_hi18nhandle,"Section_physTotalDef",build2(
             "Total Deficiencies:",char(0))),char(0)))) - _holdremphystotaldef)+ 1),nullterm(build2(
          uar_i18ngetmessage(_hi18nhandle,"Section_physTotalDef",build2("Total Deficiencies:",char(0)
            )),char(0))))))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ELSE
    SET _remphystotaldef = _holdremphystotaldef
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 324
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.312)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = sectionheight
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen25s0c0)
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(255,255,128))
   IF (ncalc=rpt_render)
    IF (_holdremphystotaldefic > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremphystotaldefic,((
        size(nullterm(build2(phystotaldefic,char(0)))) - _holdremphystotaldefic)+ 1),nullterm(build2(
          phystotaldefic,char(0))))))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ELSE
    SET _remphystotaldefic = _holdremphystotaldefic
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 288
   SET rptsd->m_paddingwidth = 0.200
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.438)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = sectionheight
   SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen25s0c0)
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(255,255,128))
   IF (ncalc=rpt_render)
    IF (bcontinue=0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(uar_i18ngetmessage(
         _hi18nhandle,"Section_CellName86",build2("Total Charts:",char(0))),char(0))))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 320
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 3.437)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = sectionheight
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen25s0c0)
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(255,255,128))
   IF (ncalc=rpt_render)
    IF (bcontinue=0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(phys_chart_cnt,char(0))))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 272
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 4.563)
   SET rptsd->m_width = 5.438
   SET rptsd->m_height = sectionheight
   SET _dummypen = uar_rptsetpen(_hreport,_pen25s0c0)
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(255,255,128))
   IF (ncalc=rpt_render)
    IF (bcontinue=0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,"")
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.312),offsety,(offsetx+ 1.312),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.438),offsety,(offsetx+ 2.438),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.437),offsety,(offsetx+ 3.437),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.563),offsety,(offsetx+ 4.563),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE fieldname024(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname024abs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE fieldname024abs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.123498), private
   DECLARE growsum = i4 WITH noconstant(0), private
   IF (bcontinue=0)
    SET _remcellname6 = 1
    SET _remcellname7 = 1
    SET _remcellname10 = 1
   ENDIF
   SET rptsd->m_flags = 293
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 2.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times11b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen25s0c0)
   SET _holdremcellname6 = _remcellname6
   IF (_remcellname6 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remcellname6,((size("")
        - _remcellname6)+ 1),"")))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remcellname6 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remcellname6,((size("") - _remcellname6)
       + 1),"")))))
     SET _remcellname6 = (_remcellname6+ rptsd->m_drawlength)
    ELSE
     SET _remcellname6 = 0
    ENDIF
    SET growsum = (growsum+ _remcellname6)
   ENDIF
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,rpt_white)
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 293
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.000)
   SET rptsd->m_width = 1.688
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummypen = uar_rptsetpen(_hreport,_pen25s0c0)
   SET _holdremcellname7 = _remcellname7
   IF (_remcellname7 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remcellname7,((size("")
        - _remcellname7)+ 1),"")))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remcellname7 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remcellname7,((size("") - _remcellname7)
       + 1),"")))))
     SET _remcellname7 = (_remcellname7+ rptsd->m_drawlength)
    ELSE
     SET _remcellname7 = 0
    ENDIF
    SET growsum = (growsum+ _remcellname7)
   ENDIF
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,rpt_white)
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 325
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 4.938)
   SET rptsd->m_width = 1.563
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen25s0c0)
   SET _holdremcellname10 = _remcellname10
   IF (_remcellname10 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remcellname10,((size("")
        - _remcellname10)+ 1),"")))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remcellname10 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remcellname10,((size("") - _remcellname10
       )+ 1),"")))))
     SET _remcellname10 = (_remcellname10+ rptsd->m_drawlength)
    ELSE
     SET _remcellname10 = 0
    ENDIF
    SET growsum = (growsum+ _remcellname10)
   ENDIF
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,rpt_white)
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 292
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 2.000
   SET rptsd->m_height = sectionheight
   SET _dummyfont = uar_rptsetfont(_hreport,_times11b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen25s0c0)
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,rpt_white)
   IF (ncalc=rpt_render)
    IF (_holdremcellname6 > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremcellname6,((size(
         "") - _holdremcellname6)+ 1),"")))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ELSE
    SET _remcellname6 = _holdremcellname6
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 292
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.000)
   SET rptsd->m_width = 1.688
   SET rptsd->m_height = sectionheight
   SET _dummypen = uar_rptsetpen(_hreport,_pen25s0c0)
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,rpt_white)
   IF (ncalc=rpt_render)
    IF (_holdremcellname7 > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremcellname7,((size(
         "") - _holdremcellname7)+ 1),"")))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ELSE
    SET _remcellname7 = _holdremcellname7
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 288
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 3.688)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = sectionheight
   SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen25s0c0)
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,rpt_white)
   IF (ncalc=rpt_render)
    IF (bcontinue=0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,"")
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 324
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 4.938)
   SET rptsd->m_width = 1.563
   SET rptsd->m_height = sectionheight
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen25s0c0)
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,rpt_white)
   IF (ncalc=rpt_render)
    IF (_holdremcellname10 > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremcellname10,((size
        ("") - _holdremcellname10)+ 1),"")))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ELSE
    SET _remcellname10 = _holdremcellname10
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 288
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.200
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 6.500)
   SET rptsd->m_width = 1.062
   SET rptsd->m_height = sectionheight
   SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen25s0c0)
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,rpt_white)
   IF (ncalc=rpt_render)
    IF (bcontinue=0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,"")
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 272
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 7.562)
   SET rptsd->m_width = 2.438
   SET rptsd->m_height = sectionheight
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen25s0c0)
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,rpt_white)
   IF (ncalc=rpt_render)
    IF (bcontinue=0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,"")
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.000),offsety,(offsetx+ 2.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.688),offsety,(offsetx+ 3.688),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.938),offsety,(offsetx+ 4.938),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.500),offsety,(offsetx+ 6.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.562),offsety,(offsetx+ 7.562),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE fieldname025(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname025abs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE fieldname025abs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.229678), private
   DECLARE growsum = i4 WITH noconstant(0), private
   IF (bcontinue=0)
    SET _remorganizationtotal = 1
    SET _remcellname78 = 1
    SET _remorgtotaldefic = 1
   ENDIF
   SET rptsd->m_flags = 293
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 2.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times11b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen25s0c0)
   SET _holdremorganizationtotal = _remorganizationtotal
   IF (_remorganizationtotal > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remorganizationtotal,((
       size(nullterm(build2(
          IF (i1multifacilitylogicind) build2(uar_i18ngetmessage(i18nhandlehim,"TOTALFORORG",
             "Total for "),trim(organization_name,3),": ")
          ELSE build2(uar_i18ngetmessage(i18nhandlehim,"TOTAL","Total:"))
          ENDIF
          ,char(0)))) - _remorganizationtotal)+ 1),nullterm(build2(
         IF (i1multifacilitylogicind) build2(uar_i18ngetmessage(i18nhandlehim,"TOTALFORORG",
            "Total for "),trim(organization_name,3),": ")
         ELSE build2(uar_i18ngetmessage(i18nhandlehim,"TOTAL","Total:"))
         ENDIF
         ,char(0))))))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remorganizationtotal = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remorganizationtotal,((size(nullterm(
         build2(
          IF (i1multifacilitylogicind) build2(uar_i18ngetmessage(i18nhandlehim,"TOTALFORORG",
             "Total for "),trim(organization_name,3),": ")
          ELSE build2(uar_i18ngetmessage(i18nhandlehim,"TOTAL","Total:"))
          ENDIF
          ,char(0)))) - _remorganizationtotal)+ 1),nullterm(build2(
         IF (i1multifacilitylogicind) build2(uar_i18ngetmessage(i18nhandlehim,"TOTALFORORG",
            "Total for "),trim(organization_name,3),": ")
         ELSE build2(uar_i18ngetmessage(i18nhandlehim,"TOTAL","Total:"))
         ENDIF
         ,char(0))))))))
     SET _remorganizationtotal = (_remorganizationtotal+ rptsd->m_drawlength)
    ELSE
     SET _remorganizationtotal = 0
    ENDIF
    SET growsum = (growsum+ _remorganizationtotal)
   ENDIF
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(255,255,128))
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 293
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.000)
   SET rptsd->m_width = 1.688
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummypen = uar_rptsetpen(_hreport,_pen25s0c0)
   SET _holdremcellname78 = _remcellname78
   IF (_remcellname78 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remcellname78,((size("")
        - _remcellname78)+ 1),"")))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remcellname78 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remcellname78,((size("") - _remcellname78
       )+ 1),"")))))
     SET _remcellname78 = (_remcellname78+ rptsd->m_drawlength)
    ELSE
     SET _remcellname78 = 0
    ENDIF
    SET growsum = (growsum+ _remcellname78)
   ENDIF
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(255,255,128))
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 325
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 4.938)
   SET rptsd->m_width = 1.563
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen25s0c0)
   SET _holdremorgtotaldefic = _remorgtotaldefic
   IF (_remorgtotaldefic > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remorgtotaldefic,((size(
        nullterm(build2(orgtotaldefic,char(0)))) - _remorgtotaldefic)+ 1),nullterm(build2(
         orgtotaldefic,char(0))))))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remorgtotaldefic = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remorgtotaldefic,((size(nullterm(build2(
          orgtotaldefic,char(0)))) - _remorgtotaldefic)+ 1),nullterm(build2(orgtotaldefic,char(0)))))
     )))
     SET _remorgtotaldefic = (_remorgtotaldefic+ rptsd->m_drawlength)
    ELSE
     SET _remorgtotaldefic = 0
    ENDIF
    SET growsum = (growsum+ _remorgtotaldefic)
   ENDIF
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(255,255,128))
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 292
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 2.000
   SET rptsd->m_height = sectionheight
   SET _dummyfont = uar_rptsetfont(_hreport,_times11b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen25s0c0)
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(255,255,128))
   IF (ncalc=rpt_render)
    IF (_holdremorganizationtotal > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremorganizationtotal,
        ((size(nullterm(build2(
           IF (i1multifacilitylogicind) build2(uar_i18ngetmessage(i18nhandlehim,"TOTALFORORG",
              "Total for "),trim(organization_name,3),": ")
           ELSE build2(uar_i18ngetmessage(i18nhandlehim,"TOTAL","Total:"))
           ENDIF
           ,char(0)))) - _holdremorganizationtotal)+ 1),nullterm(build2(
          IF (i1multifacilitylogicind) build2(uar_i18ngetmessage(i18nhandlehim,"TOTALFORORG",
             "Total for "),trim(organization_name,3),": ")
          ELSE build2(uar_i18ngetmessage(i18nhandlehim,"TOTAL","Total:"))
          ENDIF
          ,char(0))))))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ELSE
    SET _remorganizationtotal = _holdremorganizationtotal
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 292
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.000)
   SET rptsd->m_width = 1.688
   SET rptsd->m_height = sectionheight
   SET _dummypen = uar_rptsetpen(_hreport,_pen25s0c0)
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(255,255,128))
   IF (ncalc=rpt_render)
    IF (_holdremcellname78 > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremcellname78,((size
        ("") - _holdremcellname78)+ 1),"")))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ELSE
    SET _remcellname78 = _holdremcellname78
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 288
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 3.688)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = sectionheight
   SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen25s0c0)
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(255,255,128))
   IF (ncalc=rpt_render)
    IF (bcontinue=0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(uar_i18ngetmessage(
         _hi18nhandle,"Section_CellName21",build2("Total Deficiencies:",char(0))),char(0))))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 324
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 4.938)
   SET rptsd->m_width = 1.563
   SET rptsd->m_height = sectionheight
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen25s0c0)
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(255,255,128))
   IF (ncalc=rpt_render)
    IF (_holdremorgtotaldefic > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremorgtotaldefic,((
        size(nullterm(build2(orgtotaldefic,char(0)))) - _holdremorgtotaldefic)+ 1),nullterm(build2(
          orgtotaldefic,char(0))))))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ELSE
    SET _remorgtotaldefic = _holdremorgtotaldefic
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 288
   SET rptsd->m_paddingwidth = 0.200
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 6.500)
   SET rptsd->m_width = 1.062
   SET rptsd->m_height = sectionheight
   SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen25s0c0)
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(255,255,128))
   IF (ncalc=rpt_render)
    IF (bcontinue=0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(uar_i18ngetmessage(
         _hi18nhandle,"Section_CellName89",build2("Total Charts:",char(0))),char(0))))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 320
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 7.562)
   SET rptsd->m_width = 1.438
   SET rptsd->m_height = sectionheight
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen25s0c0)
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(255,255,128))
   IF (ncalc=rpt_render)
    IF (bcontinue=0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(org_chart_cnt,char(0))))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 272
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 9.000)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = sectionheight
   SET _dummypen = uar_rptsetpen(_hreport,_pen25s0c0)
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(255,255,128))
   IF (ncalc=rpt_render)
    IF (bcontinue=0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,"")
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.000),offsety,(offsetx+ 2.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.688),offsety,(offsetx+ 3.688),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.938),offsety,(offsetx+ 4.938),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.500),offsety,(offsetx+ 6.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.562),offsety,(offsetx+ 7.562),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 9.000),offsety,(offsetx+ 9.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE fieldname026(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname026abs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE fieldname026abs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.115288), private
   DECLARE growsum = i4 WITH noconstant(0), private
   IF (bcontinue=0)
    SET _remcellname23 = 1
   ENDIF
   SET rptsd->m_flags = 293
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 10.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times11b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen20s0c0)
   SET _holdremcellname23 = _remcellname23
   IF (_remcellname23 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remcellname23,((size("")
        - _remcellname23)+ 1),"")))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remcellname23 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remcellname23,((size("") - _remcellname23
       )+ 1),"")))))
     SET _remcellname23 = (_remcellname23+ rptsd->m_drawlength)
    ELSE
     SET _remcellname23 = 0
    ENDIF
    SET growsum = (growsum+ _remcellname23)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 292
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 10.000
   SET rptsd->m_height = sectionheight
   SET _dummypen = uar_rptsetpen(_hreport,_pen20s0c0)
   IF (ncalc=rpt_render)
    IF (_holdremcellname23 > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremcellname23,((size
        ("") - _holdremcellname23)+ 1),"")))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ELSE
    SET _remcellname23 = _holdremcellname23
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE fieldname027(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname027abs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE fieldname027abs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.229235), private
   DECLARE growsum = i4 WITH noconstant(0), private
   IF ( NOT (i1multifacilitylogicind))
    RETURN(0.0)
   ENDIF
   IF (bcontinue=0)
    SET _remorganizationtotal0 = 1
    SET _remgrandtotaldefic95 = 1
    SET _remcellname102 = 1
   ENDIF
   SET rptsd->m_flags = 293
   SET rptsd->m_borders = rpt_sdtopborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 3.688
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times11b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen20s0c0)
   SET _holdremorganizationtotal0 = _remorganizationtotal0
   IF (_remorganizationtotal0 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remorganizationtotal0,((
       size(nullterm(build2(uar_i18ngetmessage(_hi18nhandle,"Section_organizationTotal0",build2(
            "Grand Total For Facilities:",char(0))),char(0)))) - _remorganizationtotal0)+ 1),nullterm
       (build2(uar_i18ngetmessage(_hi18nhandle,"Section_organizationTotal0",build2(
           "Grand Total For Facilities:",char(0))),char(0))))))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remorganizationtotal0 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remorganizationtotal0,((size(nullterm(
         build2(uar_i18ngetmessage(_hi18nhandle,"Section_organizationTotal0",build2(
            "Grand Total For Facilities:",char(0))),char(0)))) - _remorganizationtotal0)+ 1),nullterm
       (build2(uar_i18ngetmessage(_hi18nhandle,"Section_organizationTotal0",build2(
           "Grand Total For Facilities:",char(0))),char(0))))))))
     SET _remorganizationtotal0 = (_remorganizationtotal0+ rptsd->m_drawlength)
    ELSE
     SET _remorganizationtotal0 = 0
    ENDIF
    SET growsum = (growsum+ _remorganizationtotal0)
   ENDIF
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(255,255,128))
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 325
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 4.938)
   SET rptsd->m_width = 1.563
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen20s0c0)
   SET _holdremgrandtotaldefic95 = _remgrandtotaldefic95
   IF (_remgrandtotaldefic95 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remgrandtotaldefic95,((
       size(nullterm(build2(total_def_cnt,char(0)))) - _remgrandtotaldefic95)+ 1),nullterm(build2(
         total_def_cnt,char(0))))))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remgrandtotaldefic95 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remgrandtotaldefic95,((size(nullterm(
         build2(total_def_cnt,char(0)))) - _remgrandtotaldefic95)+ 1),nullterm(build2(total_def_cnt,
         char(0))))))))
     SET _remgrandtotaldefic95 = (_remgrandtotaldefic95+ rptsd->m_drawlength)
    ELSE
     SET _remgrandtotaldefic95 = 0
    ENDIF
    SET growsum = (growsum+ _remgrandtotaldefic95)
   ENDIF
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(255,255,128))
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 325
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 9.000)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummypen = uar_rptsetpen(_hreport,_pen20s0c0)
   SET _holdremcellname102 = _remcellname102
   IF (_remcellname102 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remcellname102,((size("")
        - _remcellname102)+ 1),"")))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remcellname102 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remcellname102,((size("") -
       _remcellname102)+ 1),"")))))
     SET _remcellname102 = (_remcellname102+ rptsd->m_drawlength)
    ELSE
     SET _remcellname102 = 0
    ENDIF
    SET growsum = (growsum+ _remcellname102)
   ENDIF
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(255,255,128))
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 292
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 3.688
   SET rptsd->m_height = sectionheight
   SET _dummyfont = uar_rptsetfont(_hreport,_times11b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen20s0c0)
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(255,255,128))
   IF (ncalc=rpt_render)
    IF (_holdremorganizationtotal0 > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
        _holdremorganizationtotal0,((size(nullterm(build2(uar_i18ngetmessage(_hi18nhandle,
            "Section_organizationTotal0",build2("Grand Total For Facilities:",char(0))),char(0)))) -
        _holdremorganizationtotal0)+ 1),nullterm(build2(uar_i18ngetmessage(_hi18nhandle,
           "Section_organizationTotal0",build2("Grand Total For Facilities:",char(0))),char(0))))))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ELSE
    SET _remorganizationtotal0 = _holdremorganizationtotal0
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 288
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 3.688)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = sectionheight
   SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen20s0c0)
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(255,255,128))
   IF (ncalc=rpt_render)
    IF (bcontinue=0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(uar_i18ngetmessage(
         _hi18nhandle,"Section_CellName94",build2("Total Deficiencies:",char(0))),char(0))))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 324
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 4.938)
   SET rptsd->m_width = 1.563
   SET rptsd->m_height = sectionheight
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen20s0c0)
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(255,255,128))
   IF (ncalc=rpt_render)
    IF (_holdremgrandtotaldefic95 > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremgrandtotaldefic95,
        ((size(nullterm(build2(total_def_cnt,char(0)))) - _holdremgrandtotaldefic95)+ 1),nullterm(
         build2(total_def_cnt,char(0))))))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ELSE
    SET _remgrandtotaldefic95 = _holdremgrandtotaldefic95
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 288
   SET rptsd->m_paddingwidth = 0.200
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 6.500)
   SET rptsd->m_width = 1.062
   SET rptsd->m_height = sectionheight
   SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen20s0c0)
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(255,255,128))
   IF (ncalc=rpt_render)
    IF (bcontinue=0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(uar_i18ngetmessage(
         _hi18nhandle,"Section_CellName101",build2("Total Charts:",char(0))),char(0))))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 320
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 7.562)
   SET rptsd->m_width = 1.438
   SET rptsd->m_height = sectionheight
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen20s0c0)
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(255,255,128))
   IF (ncalc=rpt_render)
    IF (bcontinue=0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(total_chart_cnt,char(0))))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 324
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 9.000)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = sectionheight
   SET _dummypen = uar_rptsetpen(_hreport,_pen20s0c0)
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(255,255,128))
   IF (ncalc=rpt_render)
    IF (_holdremcellname102 > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremcellname102,((
        size("") - _holdremcellname102)+ 1),"")))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ELSE
    SET _remcellname102 = _holdremcellname102
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.688),offsety,(offsetx+ 3.688),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.938),offsety,(offsetx+ 4.938),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.500),offsety,(offsetx+ 6.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.562),offsety,(offsetx+ 7.562),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 9.000),offsety,(offsetx+ 9.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE fieldname028(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname028abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE fieldname028abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.116665), private
   IF ( NOT ( NOT (i1multifacilitylogicind)))
    RETURN(0.0)
   ENDIF
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdtopborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 10.000
   SET rptsd->m_height = 0.117
   SET _oldfont = uar_rptsetfont(_hreport,_times11b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen15s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,"")
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE fieldname029(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fieldname029abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE fieldname029abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.266019), private
   SET rptsd->m_flags = 272
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 10.000
   SET rptsd->m_height = 0.266
   SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen20s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(uar_i18ngetmessage(
        _hi18nhandle,"Section_CellName44",build2("**END OF REPORT**",char(0))),char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE fieldname0html(ndummy)
  DECLARE rpt_pageofpage = vc WITH noconstant("page 1 of 1"), protect
  SELECT
   patient_id = data->qual[d.seq].patient_id, patient_name = substring(1,100,data->qual[d.seq].
    patient_name), alpha_patient_name = substring(1,100,cnvtupper(data->qual[d.seq].patient_name)),
   patient_type_cd = data->qual[d.seq].patient_type_cd, organization_name = substring(1,100,data->
    qual[d.seq].organization_name), organization_id = data->qual[d.seq].organization_id,
   mrn = substring(1,100,data->qual[d.seq].mrn), fin = substring(1,100,data->qual[d.seq].fin),
   encntr_id = data->qual[d.seq].encntr_id,
   physician_name = substring(1,100,data->qual[d.seq].physician_name), physician_id = data->qual[d
   .seq].physician_id, location = substring(1,100,data->qual[d.seq].location),
   disch_dt_tm = data->qual[d.seq].disch_dt_tm, sort_disch_dt_tm =
   IF ((data->qual[d.seq].disch_dt_tm != null)) data->qual[d.seq].disch_dt_tm
   ELSE cnvtdatetime("31-DEC-2100 00:00:00.00")
   ENDIF
   , chart_age = data->qual[d.seq].chart_age,
   deficiency_name = substring(1,100,build(data->qual[d.seq].defic_qual[ddefic.seq].deficiency_name)),
   deficiency_age = data->qual[d.seq].defic_qual[ddefic.seq].defic_age, deficiency_status = substring
   (1,30,build(data->qual[d.seq].defic_qual[ddefic.seq].status)),
   physician_active_ind = data->qual[d.seq].physician_active_ind, physician_active_status_cd = data->
   qual[d.seq].physician_active_status_cd, physician_active_status_dt_tm = data->qual[d.seq].
   physician_active_status_dt_tm,
   physician_active_status_prsnl_id = data->qual[d.seq].physician_active_status_prsnl_id,
   physician_beg_effective_dt_tm = data->qual[d.seq].physician_beg_effective_dt_tm,
   physician_contributor_system_cd = data->qual[d.seq].physician_contributor_system_cd,
   physician_create_dt_tm = data->qual[d.seq].physician_create_dt_tm, physician_create_prsnl_id =
   data->qual[d.seq].physician_create_prsnl_id, physician_data_status_cd = data->qual[d.seq].
   physician_data_status_cd,
   physician_data_status_dt_tm = data->qual[d.seq].physician_data_status_dt_tm,
   physician_data_status_prsnl_id = data->qual[d.seq].physician_data_status_prsnl_id, physician_email
    = substring(1,100,data->qual[d.seq].physician_email),
   physician_end_effective_dt_tm = data->qual[d.seq].physician_end_effective_dt_tm,
   physician_ft_entity_id = data->qual[d.seq].physician_ft_entity_id, physician_ft_entity_name =
   substring(1,32,data->qual[d.seq].physician_ft_entity_name),
   physician_name_first = substring(1,200,data->qual[d.seq].physician_name_first),
   physician_name_first_key = substring(1,100,data->qual[d.seq].physician_name_first_key),
   physician_name_first_key_nls = substring(1,202,data->qual[d.seq].physician_name_first_key_nls),
   physician_name_full_formatted = substring(1,100,data->qual[d.seq].physician_name_full_formatted),
   physician_name_last = substring(1,200,data->qual[d.seq].physician_name_last),
   physician_name_last_key = substring(1,100,data->qual[d.seq].physician_name_last_key),
   physician_name_last_key_nls = substring(1,202,data->qual[d.seq].physician_name_last_key_nls),
   physician_password = substring(1,100,data->qual[d.seq].physician_password), physician_person_id =
   data->qual[d.seq].physician_person_id,
   physician_physician_ind = data->qual[d.seq].physician_physician_ind, physician_physician_status_cd
    = data->qual[d.seq].physician_physician_status_cd, physician_position_cd = data->qual[d.seq].
   physician_position_cd,
   physician_prim_assign_loc_cd = data->qual[d.seq].physician_prim_assign_loc_cd,
   physician_prsnl_type_cd = data->qual[d.seq].physician_prsnl_type_cd, physician_updt_dt_tm = data->
   qual[d.seq].physician_updt_dt_tm,
   physician_updt_id = data->qual[d.seq].physician_updt_id, physician_updt_task = data->qual[d.seq].
   physician_updt_task, physician_username = substring(1,50,data->qual[d.seq].physician_username),
   patient_abs_birth_dt_tm = data->qual[d.seq].patient_abs_birth_dt_tm, patient_active_ind = data->
   qual[d.seq].patient_active_ind, patient_active_status_cd = data->qual[d.seq].
   patient_active_status_cd,
   patient_active_status_dt_tm = data->qual[d.seq].patient_active_status_dt_tm,
   patient_active_status_prsnl_id = data->qual[d.seq].patient_active_status_prsnl_id,
   patient_archive_env_id = data->qual[d.seq].patient_archive_env_id,
   patient_archive_status_cd = data->qual[d.seq].patient_archive_status_cd,
   patient_archive_status_dt_tm = data->qual[d.seq].patient_archive_status_dt_tm, patient_autopsy_cd
    = data->qual[d.seq].patient_autopsy_cd,
   patient_beg_effective_dt_tm = data->qual[d.seq].patient_beg_effective_dt_tm, patient_birth_dt_cd
    = data->qual[d.seq].patient_birth_dt_cd, patient_birth_dt_tm = data->qual[d.seq].
   patient_birth_dt_tm,
   patient_birth_prec_flag = data->qual[d.seq].patient_birth_prec_flag, patient_birth_tz = data->
   qual[d.seq].patient_birth_tz, patient_cause_of_death = substring(1,100,data->qual[d.seq].
    patient_cause_of_death),
   patient_cause_of_death_cd = data->qual[d.seq].patient_cause_of_death_cd, patient_citizenship_cd =
   data->qual[d.seq].patient_citizenship_cd, patient_conception_dt_tm = data->qual[d.seq].
   patient_conception_dt_tm,
   patient_confid_level_cd = data->qual[d.seq].patient_confid_level_cd, patient_contributor_system_cd
    = data->qual[d.seq].patient_contributor_system_cd, patient_create_dt_tm = data->qual[d.seq].
   patient_create_dt_tm,
   patient_create_prsnl_id = data->qual[d.seq].patient_create_prsnl_id, patient_data_status_cd = data
   ->qual[d.seq].patient_data_status_cd, patient_data_status_dt_tm = data->qual[d.seq].
   patient_data_status_dt_tm,
   patient_data_status_prsnl_id = data->qual[d.seq].patient_data_status_prsnl_id, patient_deceased_cd
    = data->qual[d.seq].patient_deceased_cd, patient_deceased_dt_tm = data->qual[d.seq].
   patient_deceased_dt_tm,
   patient_deceased_source_cd = data->qual[d.seq].patient_deceased_source_cd,
   patient_end_effective_dt_tm = data->qual[d.seq].patient_end_effective_dt_tm, patient_ethnic_grp_cd
    = data->qual[d.seq].patient_ethnic_grp_cd,
   patient_ft_entity_id = data->qual[d.seq].patient_ft_entity_id, patient_ft_entity_name = substring(
    1,32,data->qual[d.seq].patient_ft_entity_name), patient_language_cd = data->qual[d.seq].
   patient_language_cd,
   patient_language_dialect_cd = data->qual[d.seq].patient_language_dialect_cd,
   patient_last_accessed_dt_tm = data->qual[d.seq].patient_last_accessed_dt_tm,
   patient_last_encntr_dt_tm = data->qual[d.seq].patient_last_encntr_dt_tm,
   patient_marital_type_cd = data->qual[d.seq].patient_marital_type_cd,
   patient_military_base_location = substring(1,100,data->qual[d.seq].patient_military_base_location),
   patient_military_rank_cd = data->qual[d.seq].patient_military_rank_cd,
   patient_military_service_cd = data->qual[d.seq].patient_military_service_cd,
   patient_mother_maiden_name = substring(1,100,data->qual[d.seq].patient_mother_maiden_name),
   patient_name_first = substring(1,200,data->qual[d.seq].patient_name_first),
   patient_name_first_key = substring(1,100,data->qual[d.seq].patient_name_first_key),
   patient_name_first_key_nls = substring(1,202,data->qual[d.seq].patient_name_first_key_nls),
   patient_name_first_phonetic = substring(1,8,data->qual[d.seq].patient_name_first_phonetic),
   patient_name_first_synonym_id = data->qual[d.seq].patient_name_first_synonym_id,
   patient_name_full_formatted = substring(1,100,data->qual[d.seq].patient_name_full_formatted),
   patient_name_last = substring(1,200,data->qual[d.seq].patient_name_last),
   patient_name_last_key = substring(1,100,data->qual[d.seq].patient_name_last_key),
   patient_name_last_key_nls = substring(1,202,data->qual[d.seq].patient_name_last_key_nls),
   patient_name_last_phonetic = substring(1,8,data->qual[d.seq].patient_name_last_phonetic),
   patient_name_middle = substring(1,200,data->qual[d.seq].patient_name_middle),
   patient_name_middle_key = substring(1,100,data->qual[d.seq].patient_name_middle_key),
   patient_name_middle_key_nls = substring(1,202,data->qual[d.seq].patient_name_middle_key_nls),
   patient_name_phonetic = substring(1,8,data->qual[d.seq].patient_name_phonetic),
   patient_nationality_cd = data->qual[d.seq].patient_nationality_cd, patient_next_restore_dt_tm =
   data->qual[d.seq].patient_next_restore_dt_tm,
   patient_person_id = data->qual[d.seq].patient_person_id, patient_person_type_cd = data->qual[d.seq
   ].patient_person_type_cd, patient_race_cd = data->qual[d.seq].patient_race_cd,
   patient_religion_cd = data->qual[d.seq].patient_religion_cd, patient_sex_age_change_ind = data->
   qual[d.seq].patient_sex_age_change_ind, patient_sex_cd = data->qual[d.seq].patient_sex_cd,
   patient_species_cd = data->qual[d.seq].patient_species_cd, patient_updt_dt_tm = data->qual[d.seq].
   patient_updt_dt_tm, patient_updt_id = data->qual[d.seq].patient_updt_id,
   patient_updt_task = data->qual[d.seq].patient_updt_task, patient_vet_military_status_cd = data->
   qual[d.seq].patient_vet_military_status_cd, patient_vip_cd = data->qual[d.seq].patient_vip_cd,
   encntr_accommodation_cd = data->qual[d.seq].encntr_accommodation_cd,
   encntr_accommodation_reason_cd = data->qual[d.seq].encntr_accommodation_reason_cd,
   encntr_accommodation_request_cd = data->qual[d.seq].encntr_accommodation_request_cd,
   encntr_accomp_by_cd = data->qual[d.seq].encntr_accomp_by_cd, encntr_active_ind = data->qual[d.seq]
   .encntr_active_ind, encntr_active_status_cd = data->qual[d.seq].encntr_active_status_cd,
   encntr_active_status_dt_tm = data->qual[d.seq].encntr_active_status_dt_tm,
   encntr_active_status_prsnl_id = data->qual[d.seq].encntr_active_status_prsnl_id,
   encntr_admit_mode_cd = data->qual[d.seq].encntr_admit_mode_cd,
   encntr_admit_src_cd = data->qual[d.seq].encntr_admit_src_cd, encntr_admit_type_cd = data->qual[d
   .seq].encntr_admit_type_cd, encntr_admit_with_medication_cd = data->qual[d.seq].
   encntr_admit_with_medication_cd,
   encntr_alc_decomp_dt_tm = data->qual[d.seq].encntr_alc_decomp_dt_tm, encntr_alc_reason_cd = data->
   qual[d.seq].encntr_alc_reason_cd, encntr_alt_lvl_care_cd = data->qual[d.seq].
   encntr_alt_lvl_care_cd,
   encntr_alt_lvl_care_dt_tm = data->qual[d.seq].encntr_alt_lvl_care_dt_tm, encntr_ambulatory_cond_cd
    = data->qual[d.seq].encntr_ambulatory_cond_cd, encntr_archive_dt_tm_act = data->qual[d.seq].
   encntr_archive_dt_tm_act,
   encntr_archive_dt_tm_est = data->qual[d.seq].encntr_archive_dt_tm_est, encntr_arrive_dt_tm = data
   ->qual[d.seq].encntr_arrive_dt_tm, encntr_assign_to_loc_dt_tm = data->qual[d.seq].
   encntr_assign_to_loc_dt_tm,
   encntr_bbd_procedure_cd = data->qual[d.seq].encntr_bbd_procedure_cd, encntr_beg_effective_dt_tm =
   data->qual[d.seq].encntr_beg_effective_dt_tm, encntr_chart_complete_dt_tm = data->qual[d.seq].
   encntr_chart_complete_dt_tm,
   encntr_confid_level_cd = data->qual[d.seq].encntr_confid_level_cd, encntr_contract_status_cd =
   data->qual[d.seq].encntr_contract_status_cd, encntr_contributor_system_cd = data->qual[d.seq].
   encntr_contributor_system_cd,
   encntr_courtesy_cd = data->qual[d.seq].encntr_courtesy_cd, encntr_create_dt_tm = data->qual[d.seq]
   .encntr_create_dt_tm, encntr_create_prsnl_id = data->qual[d.seq].encntr_create_prsnl_id,
   encntr_data_status_cd = data->qual[d.seq].encntr_data_status_cd, encntr_data_status_dt_tm = data->
   qual[d.seq].encntr_data_status_dt_tm, encntr_data_status_prsnl_id = data->qual[d.seq].
   encntr_data_status_prsnl_id,
   encntr_depart_dt_tm = data->qual[d.seq].encntr_depart_dt_tm, encntr_diet_type_cd = data->qual[d
   .seq].encntr_diet_type_cd, encntr_disch_disposition_cd = data->qual[d.seq].
   encntr_disch_disposition_cd,
   encntr_disch_dt_tm = data->qual[d.seq].encntr_disch_dt_tm, encntr_disch_to_loctn_cd = data->qual[d
   .seq].encntr_disch_to_loctn_cd, encntr_doc_rcvd_dt_tm = data->qual[d.seq].encntr_doc_rcvd_dt_tm,
   encntr_encntr_class_cd = data->qual[d.seq].encntr_encntr_class_cd, encntr_encntr_complete_dt_tm =
   data->qual[d.seq].encntr_encntr_complete_dt_tm, encntr_encntr_financial_id = data->qual[d.seq].
   encntr_encntr_financial_id,
   encntr_encntr_id = data->qual[d.seq].encntr_encntr_id, encntr_encntr_status_cd = data->qual[d.seq]
   .encntr_encntr_status_cd, encntr_encntr_type_cd = data->qual[d.seq].encntr_encntr_type_cd,
   encntr_encntr_type_class_cd = data->qual[d.seq].encntr_encntr_type_class_cd,
   encntr_end_effective_dt_tm = data->qual[d.seq].encntr_end_effective_dt_tm, encntr_est_arrive_dt_tm
    = data->qual[d.seq].encntr_est_arrive_dt_tm,
   encntr_est_depart_dt_tm = data->qual[d.seq].encntr_est_depart_dt_tm, encntr_est_length_of_stay =
   data->qual[d.seq].encntr_est_length_of_stay, encntr_financial_class_cd = data->qual[d.seq].
   encntr_financial_class_cd,
   encntr_guarantor_type_cd = data->qual[d.seq].encntr_guarantor_type_cd, encntr_info_given_by =
   substring(1,100,data->qual[d.seq].encntr_info_given_by), encntr_inpatient_admit_dt_tm = data->
   qual[d.seq].encntr_inpatient_admit_dt_tm,
   encntr_isolation_cd = data->qual[d.seq].encntr_isolation_cd, encntr_location_cd = data->qual[d.seq
   ].encntr_location_cd, encntr_loc_bed_cd = data->qual[d.seq].encntr_loc_bed_cd,
   encntr_loc_building_cd = data->qual[d.seq].encntr_loc_building_cd, encntr_loc_facility_cd = data->
   qual[d.seq].encntr_loc_facility_cd, encntr_loc_nurse_unit_cd = data->qual[d.seq].
   encntr_loc_nurse_unit_cd,
   encntr_loc_room_cd = data->qual[d.seq].encntr_loc_room_cd, encntr_loc_temp_cd = data->qual[d.seq].
   encntr_loc_temp_cd, encntr_med_service_cd = data->qual[d.seq].encntr_med_service_cd,
   encntr_mental_category_cd = data->qual[d.seq].encntr_mental_category_cd,
   encntr_mental_health_dt_tm = data->qual[d.seq].encntr_mental_health_dt_tm, encntr_organization_id
    = data->qual[d.seq].encntr_organization_id,
   encntr_parent_ret_criteria_id = data->qual[d.seq].encntr_parent_ret_criteria_id,
   encntr_patient_classification_cd = data->qual[d.seq].encntr_patient_classification_cd,
   encntr_pa_current_status_cd = data->qual[d.seq].encntr_pa_current_status_cd,
   encntr_pa_current_status_dt_tm = data->qual[d.seq].encntr_pa_current_status_dt_tm,
   encntr_person_id = data->qual[d.seq].encntr_person_id, encntr_placement_auth_prsnl_id = data->
   qual[d.seq].encntr_placement_auth_prsnl_id,
   encntr_preadmit_testing_cd = data->qual[d.seq].encntr_preadmit_testing_cd, encntr_pre_reg_dt_tm =
   data->qual[d.seq].encntr_pre_reg_dt_tm, encntr_pre_reg_prsnl_id = data->qual[d.seq].
   encntr_pre_reg_prsnl_id,
   encntr_program_service_cd = data->qual[d.seq].encntr_program_service_cd,
   encntr_psychiatric_status_cd = data->qual[d.seq].encntr_psychiatric_status_cd,
   encntr_purge_dt_tm_act = data->qual[d.seq].encntr_purge_dt_tm_act,
   encntr_purge_dt_tm_est = data->qual[d.seq].encntr_purge_dt_tm_est, encntr_readmit_cd = data->qual[
   d.seq].encntr_readmit_cd, encntr_reason_for_visit = substring(1,255,data->qual[d.seq].
    encntr_reason_for_visit),
   encntr_referral_rcvd_dt_tm = data->qual[d.seq].encntr_referral_rcvd_dt_tm,
   encntr_referring_comment = substring(1,100,data->qual[d.seq].encntr_referring_comment),
   encntr_refer_facility_cd = data->qual[d.seq].encntr_refer_facility_cd,
   encntr_region_cd = data->qual[d.seq].encntr_region_cd, encntr_reg_dt_tm = data->qual[d.seq].
   encntr_reg_dt_tm, encntr_reg_prsnl_id = data->qual[d.seq].encntr_reg_prsnl_id,
   encntr_result_accumulation_dt_tm = data->qual[d.seq].encntr_result_accumulation_dt_tm,
   encntr_safekeeping_cd = data->qual[d.seq].encntr_safekeeping_cd, encntr_security_access_cd = data
   ->qual[d.seq].encntr_security_access_cd,
   encntr_service_category_cd = data->qual[d.seq].encntr_service_category_cd,
   encntr_sitter_required_cd = data->qual[d.seq].encntr_sitter_required_cd, encntr_specialty_unit_cd
    = data->qual[d.seq].encntr_specialty_unit_cd,
   encntr_trauma_cd = data->qual[d.seq].encntr_trauma_cd, encntr_trauma_dt_tm = data->qual[d.seq].
   encntr_trauma_dt_tm, encntr_triage_cd = data->qual[d.seq].encntr_triage_cd,
   encntr_triage_dt_tm = data->qual[d.seq].encntr_triage_dt_tm, encntr_updt_dt_tm = data->qual[d.seq]
   .encntr_updt_dt_tm, encntr_updt_id = data->qual[d.seq].encntr_updt_id,
   encntr_updt_task = data->qual[d.seq].encntr_updt_task, encntr_valuables_cd = data->qual[d.seq].
   encntr_valuables_cd, encntr_vip_cd = data->qual[d.seq].encntr_vip_cd,
   encntr_visitor_status_cd = data->qual[d.seq].encntr_visitor_status_cd, encntr_zero_balance_dt_tm
    = data->qual[d.seq].encntr_zero_balance_dt_tm, encntr_mrn_active_ind = data->qual[d.seq].
   encntr_mrn_active_ind,
   encntr_mrn_active_status_cd = data->qual[d.seq].encntr_mrn_active_status_cd,
   encntr_mrn_active_status_dt_tm = data->qual[d.seq].encntr_mrn_active_status_dt_tm,
   encntr_mrn_active_status_prsnl_id = data->qual[d.seq].encntr_mrn_active_status_prsnl_id,
   encntr_mrn_alias = substring(1,200,data->qual[d.seq].encntr_mrn_alias), encntr_mrn_alias_pool_cd
    = data->qual[d.seq].encntr_mrn_alias_pool_cd, encntr_mrn_assign_authority_sys_cd = data->qual[d
   .seq].encntr_mrn_assign_authority_sys_cd,
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
   data->qual[d.seq].encntr_mrn_end_effective_dt_tm, encntr_mrn_updt_dt_tm = data->qual[d.seq].
   encntr_mrn_updt_dt_tm,
   encntr_mrn_updt_id = data->qual[d.seq].encntr_mrn_updt_id, encntr_mrn_updt_task = data->qual[d.seq
   ].encntr_mrn_updt_task, encntr_fin_active_ind = data->qual[d.seq].encntr_fin_active_ind,
   encntr_fin_active_status_cd = data->qual[d.seq].encntr_fin_active_status_cd,
   encntr_fin_active_status_dt_tm = data->qual[d.seq].encntr_fin_active_status_dt_tm,
   encntr_fin_active_status_prsnl_id = data->qual[d.seq].encntr_fin_active_status_prsnl_id,
   encntr_fin_alias = substring(1,200,data->qual[d.seq].encntr_fin_alias), encntr_fin_alias_pool_cd
    = data->qual[d.seq].encntr_fin_alias_pool_cd, encntr_fin_assign_authority_sys_cd = data->qual[d
   .seq].encntr_fin_assign_authority_sys_cd,
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
   data->qual[d.seq].encntr_fin_end_effective_dt_tm, encntr_fin_updt_dt_tm = data->qual[d.seq].
   encntr_fin_updt_dt_tm,
   encntr_fin_updt_id = data->qual[d.seq].encntr_fin_updt_id, encntr_fin_updt_task = data->qual[d.seq
   ].encntr_fin_updt_task, org_active_ind = data->qual[d.seq].org_active_ind,
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
   org_updt_task = data->qual[d.seq].org_updt_task, him_visit_abstract_complete_ind = data->qual[d
   .seq].him_visit_abstract_complete_ind, him_visit_active_ind = data->qual[d.seq].
   him_visit_active_ind,
   him_visit_active_status_cd = data->qual[d.seq].him_visit_active_status_cd,
   him_visit_active_status_dt_tm = data->qual[d.seq].him_visit_active_status_dt_tm,
   him_visit_active_status_prsnl_id = data->qual[d.seq].him_visit_active_status_prsnl_id,
   him_visit_allocation_dt_flag = data->qual[d.seq].him_visit_allocation_dt_flag,
   him_visit_allocation_dt_modifier = data->qual[d.seq].him_visit_allocation_dt_modifier,
   him_visit_allocation_dt_tm = data->qual[d.seq].him_visit_allocation_dt_tm,
   him_visit_beg_effective_dt_tm = data->qual[d.seq].him_visit_beg_effective_dt_tm,
   him_visit_chart_process_id = data->qual[d.seq].him_visit_chart_process_id,
   him_visit_chart_status_cd = data->qual[d.seq].him_visit_chart_status_cd,
   him_visit_chart_status_dt_tm = data->qual[d.seq].him_visit_chart_status_dt_tm, him_visit_encntr_id
    = data->qual[d.seq].him_visit_encntr_id, him_visit_end_effective_dt_tm = data->qual[d.seq].
   him_visit_end_effective_dt_tm,
   him_visit_person_id = data->qual[d.seq].him_visit_person_id, him_visit_updt_dt_tm = data->qual[d
   .seq].him_visit_updt_dt_tm, him_visit_updt_id = data->qual[d.seq].him_visit_updt_id,
   him_visit_updt_task = data->qual[d.seq].him_visit_updt_task, order_notif_action_sequence =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].order_notif_action_sequence)
   ELSE ""
   ENDIF
   , order_notif_caused_by_flag =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].order_notif_caused_by_flag)
   ELSE ""
   ENDIF
   ,
   order_notif_from_prsnl_id =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].order_notif_from_prsnl_id)
   ELSE ""
   ENDIF
   , order_notif_notification_comment =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) substring(1,255,data->qual[d.seq
     ].defic_qual[ddefic.seq].order_qual[1].order_notif_notification_comment)
   ELSE ""
   ENDIF
   , order_notif_notification_dt_tm =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].order_notif_notification_dt_tm)
   ELSE ""
   ENDIF
   ,
   order_notif_notification_reason_cd =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].order_notif_notification_reason_cd)
   ELSE ""
   ENDIF
   , order_notif_notification_status_flag =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].order_notif_notification_status_flag)
   ELSE ""
   ENDIF
   , order_notif_notification_type_flag =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].order_notif_notification_type_flag)
   ELSE ""
   ENDIF
   ,
   order_notif_notification_tz =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].order_notif_notification_tz)
   ELSE ""
   ENDIF
   , order_notif_order_id =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].order_notif_order_id)
   ELSE ""
   ENDIF
   , order_notif_order_notification_id =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].order_notif_order_notification_id)
   ELSE ""
   ENDIF
   ,
   order_notif_parent_order_notification_id =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].order_notif_parent_order_notification_id)
   ELSE ""
   ENDIF
   , order_notif_status_change_dt_tm =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].order_notif_status_change_dt_tm)
   ELSE ""
   ENDIF
   , order_notif_status_change_tz =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].order_notif_status_change_tz)
   ELSE ""
   ENDIF
   ,
   order_notif_to_prsnl_id =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].order_notif_to_prsnl_id)
   ELSE ""
   ENDIF
   , order_notif_updt_dt_tm =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].order_notif_updt_dt_tm)
   ELSE ""
   ENDIF
   , order_notif_updt_id =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].order_notif_updt_id)
   ELSE ""
   ENDIF
   ,
   order_notif_updt_task =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].order_notif_updt_task)
   ELSE ""
   ENDIF
   , order_review_action_sequence =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].order_review_action_sequence)
   ELSE ""
   ENDIF
   , order_review_dept_cd =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].order_review_dept_cd)
   ELSE ""
   ENDIF
   ,
   order_review_digital_signature_ident =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) substring(1,64,data->qual[d.seq]
     .defic_qual[ddefic.seq].order_qual[1].order_review_digital_signature_ident)
   ELSE ""
   ENDIF
   , order_review_location_cd =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].order_review_location_cd)
   ELSE ""
   ENDIF
   , order_review_order_id =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].order_review_order_id)
   ELSE ""
   ENDIF
   ,
   order_review_provider_id =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].order_review_provider_id)
   ELSE ""
   ENDIF
   , order_review_proxy_personnel_id =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].order_review_proxy_personnel_id)
   ELSE ""
   ENDIF
   , order_review_proxy_reason_cd =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].order_review_proxy_reason_cd)
   ELSE ""
   ENDIF
   ,
   order_review_reject_reason_cd =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].order_review_reject_reason_cd)
   ELSE ""
   ENDIF
   , order_review_reviewed_status_flag =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].order_review_reviewed_status_flag)
   ELSE ""
   ENDIF
   , order_review_review_dt_tm =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].order_review_review_dt_tm)
   ELSE ""
   ENDIF
   ,
   order_review_review_personnel_id =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].order_review_review_personnel_id)
   ELSE ""
   ENDIF
   , order_review_review_reqd_ind =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].order_review_review_reqd_ind)
   ELSE ""
   ENDIF
   , order_review_review_sequence =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].order_review_review_sequence)
   ELSE ""
   ENDIF
   ,
   order_review_review_type_flag =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].order_review_review_type_flag)
   ELSE ""
   ENDIF
   , order_review_review_tz =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].order_review_review_tz)
   ELSE ""
   ENDIF
   , order_review_updt_dt_tm =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].order_review_updt_dt_tm)
   ELSE ""
   ENDIF
   ,
   order_review_updt_id =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].order_review_updt_id)
   ELSE ""
   ENDIF
   , order_review_updt_task =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].order_review_updt_task)
   ELSE ""
   ENDIF
   , orders_active_ind =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_active_ind)
   ELSE ""
   ENDIF
   ,
   orders_active_status_cd =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_active_status_cd)
   ELSE ""
   ENDIF
   , orders_active_status_dt_tm =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_active_status_dt_tm)
   ELSE ""
   ENDIF
   , orders_active_status_prsnl_id =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_active_status_prsnl_id)
   ELSE ""
   ENDIF
   ,
   orders_activity_type_cd =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_activity_type_cd)
   ELSE ""
   ENDIF
   , orders_ad_hoc_order_flag =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_ad_hoc_order_flag)
   ELSE ""
   ENDIF
   , orders_catalog_cd =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_catalog_cd)
   ELSE ""
   ENDIF
   ,
   orders_catalog_type_cd =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_catalog_type_cd)
   ELSE ""
   ENDIF
   , orders_cki =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) substring(1,255,data->qual[d.seq
     ].defic_qual[ddefic.seq].order_qual[1].orders_cki)
   ELSE ""
   ENDIF
   , orders_clinical_display_line =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) substring(1,255,data->qual[d.seq
     ].defic_qual[ddefic.seq].order_qual[1].orders_clinical_display_line)
   ELSE ""
   ENDIF
   ,
   orders_comment_type_mask =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_comment_type_mask)
   ELSE ""
   ENDIF
   , orders_constant_ind =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_constant_ind)
   ELSE ""
   ENDIF
   , orders_contributor_system_cd =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_contributor_system_cd)
   ELSE ""
   ENDIF
   ,
   orders_cs_flag =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_cs_flag)
   ELSE ""
   ENDIF
   , orders_cs_order_id =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_cs_order_id)
   ELSE ""
   ENDIF
   , orders_current_start_dt_tm =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_current_start_dt_tm)
   ELSE ""
   ENDIF
   ,
   orders_current_start_tz =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_current_start_tz)
   ELSE ""
   ENDIF
   , orders_dcp_clin_cat_cd =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_dcp_clin_cat_cd)
   ELSE ""
   ENDIF
   , orders_dept_misc_line =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) substring(1,255,data->qual[d.seq
     ].defic_qual[ddefic.seq].order_qual[1].orders_dept_misc_line)
   ELSE ""
   ENDIF
   ,
   orders_dept_status_cd =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_dept_status_cd)
   ELSE ""
   ENDIF
   , orders_discontinue_effective_dt_tm =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_discontinue_effective_dt_tm)
   ELSE ""
   ENDIF
   , orders_discontinue_effective_tz =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_discontinue_effective_tz)
   ELSE ""
   ENDIF
   ,
   orders_discontinue_ind =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_discontinue_ind)
   ELSE ""
   ENDIF
   , orders_discontinue_type_cd =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_discontinue_type_cd)
   ELSE ""
   ENDIF
   , orders_encntr_financial_id =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_encntr_financial_id)
   ELSE ""
   ENDIF
   ,
   orders_encntr_id =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_encntr_id)
   ELSE ""
   ENDIF
   , orders_eso_new_order_ind =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_eso_new_order_ind)
   ELSE ""
   ENDIF
   , orders_frequency_id =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_frequency_id)
   ELSE ""
   ENDIF
   ,
   orders_freq_type_flag =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_freq_type_flag)
   ELSE ""
   ENDIF
   , orders_group_order_flag =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_group_order_flag)
   ELSE ""
   ENDIF
   , orders_group_order_id =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_group_order_id)
   ELSE ""
   ENDIF
   ,
   orders_hide_flag =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_hide_flag)
   ELSE ""
   ENDIF
   , orders_hna_order_mnemonic =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) substring(1,100,data->qual[d.seq
     ].defic_qual[ddefic.seq].order_qual[1].orders_hna_order_mnemonic)
   ELSE ""
   ENDIF
   , orders_incomplete_order_ind =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_incomplete_order_ind)
   ELSE ""
   ENDIF
   ,
   orders_ingredient_ind =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_ingredient_ind)
   ELSE ""
   ENDIF
   , orders_interest_dt_tm =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_interest_dt_tm)
   ELSE ""
   ENDIF
   , orders_interval_ind =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_interval_ind)
   ELSE ""
   ENDIF
   ,
   orders_iv_ind =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_iv_ind)
   ELSE ""
   ENDIF
   , orders_last_action_sequence =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_last_action_sequence)
   ELSE ""
   ENDIF
   , orders_last_core_action_sequence =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_last_core_action_sequence)
   ELSE ""
   ENDIF
   ,
   orders_last_ingred_action_sequence =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_last_ingred_action_sequence)
   ELSE ""
   ENDIF
   , orders_last_update_provider_id =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_last_update_provider_id)
   ELSE ""
   ENDIF
   , orders_link_nbr =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_link_nbr)
   ELSE ""
   ENDIF
   ,
   orders_link_order_flag =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_link_order_flag)
   ELSE ""
   ENDIF
   , orders_link_order_id =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_link_order_id)
   ELSE ""
   ENDIF
   , orders_link_type_flag =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_link_type_flag)
   ELSE ""
   ENDIF
   ,
   orders_med_order_type_cd =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_med_order_type_cd)
   ELSE ""
   ENDIF
   , orders_modified_start_dt_tm =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_modified_start_dt_tm)
   ELSE ""
   ENDIF
   , orders_need_doctor_cosign_ind =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_need_doctor_cosign_ind)
   ELSE ""
   ENDIF
   ,
   orders_need_nurse_review_ind =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_need_nurse_review_ind)
   ELSE ""
   ENDIF
   , orders_need_physician_validate_ind =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_need_physician_validate_ind)
   ELSE ""
   ENDIF
   , orders_need_rx_verify_ind =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_need_rx_verify_ind)
   ELSE ""
   ENDIF
   ,
   orders_oe_format_id =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_oe_format_id)
   ELSE ""
   ENDIF
   , orders_orderable_type_flag =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_orderable_type_flag)
   ELSE ""
   ENDIF
   , orders_ordered_as_mnemonic =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) substring(1,100,data->qual[d.seq
     ].defic_qual[ddefic.seq].order_qual[1].orders_ordered_as_mnemonic)
   ELSE ""
   ENDIF
   ,
   orders_order_comment_ind =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_order_comment_ind)
   ELSE ""
   ENDIF
   , orders_order_detail_display_line =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) substring(1,255,data->qual[d.seq
     ].defic_qual[ddefic.seq].order_qual[1].orders_order_detail_display_line)
   ELSE ""
   ENDIF
   , orders_order_id =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_order_id)
   ELSE ""
   ENDIF
   ,
   orders_order_mnemonic =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) substring(1,100,data->qual[d.seq
     ].defic_qual[ddefic.seq].order_qual[1].orders_order_mnemonic)
   ELSE ""
   ENDIF
   , orders_order_status_cd =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_order_status_cd)
   ELSE ""
   ENDIF
   , orders_orig_order_convs_seq =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_orig_order_convs_seq)
   ELSE ""
   ENDIF
   ,
   orders_orig_order_dt_tm =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_orig_order_dt_tm)
   ELSE ""
   ENDIF
   , orders_orig_order_tz =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_orig_order_tz)
   ELSE ""
   ENDIF
   , orders_orig_ord_as_flag =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_orig_ord_as_flag)
   ELSE ""
   ENDIF
   ,
   orders_override_flag =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_override_flag)
   ELSE ""
   ENDIF
   , orders_pathway_catalog_id =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_pathway_catalog_id)
   ELSE ""
   ENDIF
   , orders_person_id =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_person_id)
   ELSE ""
   ENDIF
   ,
   orders_prn_ind =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_prn_ind)
   ELSE ""
   ENDIF
   , orders_product_id =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_product_id)
   ELSE ""
   ENDIF
   , orders_projected_stop_dt_tm =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_projected_stop_dt_tm)
   ELSE ""
   ENDIF
   ,
   orders_projected_stop_tz =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_projected_stop_tz)
   ELSE ""
   ENDIF
   , orders_ref_text_mask =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_ref_text_mask)
   ELSE ""
   ENDIF
   , orders_remaining_dose_cnt =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_remaining_dose_cnt)
   ELSE ""
   ENDIF
   ,
   orders_resume_effective_dt_tm =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_resume_effective_dt_tm)
   ELSE ""
   ENDIF
   , orders_resume_effective_tz =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_resume_effective_tz)
   ELSE ""
   ENDIF
   , orders_resume_ind =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_resume_ind)
   ELSE ""
   ENDIF
   ,
   orders_rx_mask =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_rx_mask)
   ELSE ""
   ENDIF
   , orders_sch_state_cd =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_sch_state_cd)
   ELSE ""
   ENDIF
   , orders_soft_stop_dt_tm =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_soft_stop_dt_tm)
   ELSE ""
   ENDIF
   ,
   orders_soft_stop_tz =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_soft_stop_tz)
   ELSE ""
   ENDIF
   , orders_status_dt_tm =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_status_dt_tm)
   ELSE ""
   ENDIF
   , orders_status_prsnl_id =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_status_prsnl_id)
   ELSE ""
   ENDIF
   ,
   orders_stop_type_cd =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_stop_type_cd)
   ELSE ""
   ENDIF
   , orders_suspend_effective_dt_tm =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_suspend_effective_dt_tm)
   ELSE ""
   ENDIF
   , orders_suspend_effective_tz =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_suspend_effective_tz)
   ELSE ""
   ENDIF
   ,
   orders_suspend_ind =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_suspend_ind)
   ELSE ""
   ENDIF
   , orders_synonym_id =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_synonym_id)
   ELSE ""
   ENDIF
   , orders_template_core_action_sequence =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_template_core_action_sequence)
   ELSE ""
   ENDIF
   ,
   orders_template_order_flag =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_template_order_flag)
   ELSE ""
   ENDIF
   , orders_template_order_id =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_template_order_id)
   ELSE ""
   ENDIF
   , orders_updt_dt_tm =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_updt_dt_tm)
   ELSE ""
   ENDIF
   ,
   orders_updt_id =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_updt_id)
   ELSE ""
   ENDIF
   , orders_updt_task =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_updt_task)
   ELSE ""
   ENDIF
   , orders_valid_dose_dt_tm =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].order_qual[1].orders_valid_dose_dt_tm)
   ELSE ""
   ENDIF
   ,
   him_event_action_status_cd =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=1)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].doc_qual[1].him_event_action_status_cd)
   ELSE ""
   ENDIF
   , him_event_action_type_cd =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=1)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].doc_qual[1].him_event_action_type_cd)
   ELSE ""
   ENDIF
   , him_event_active_ind =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=1)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].doc_qual[1].him_event_active_ind)
   ELSE ""
   ENDIF
   ,
   him_event_active_status_cd =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=1)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].doc_qual[1].him_event_active_status_cd)
   ELSE ""
   ENDIF
   , him_event_active_status_dt_tm =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=1)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].doc_qual[1].him_event_active_status_dt_tm)
   ELSE ""
   ENDIF
   , him_event_active_status_prsnl_id =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=1)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].doc_qual[1].him_event_active_status_prsnl_id)
   ELSE ""
   ENDIF
   ,
   him_event_allocation_dt_tm =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=1)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].doc_qual[1].him_event_allocation_dt_tm)
   ELSE ""
   ENDIF
   , him_event_beg_effective_dt_tm =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=1)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].doc_qual[1].him_event_beg_effective_dt_tm)
   ELSE ""
   ENDIF
   , him_event_completed_dt_tm =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=1)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].doc_qual[1].him_event_completed_dt_tm)
   ELSE ""
   ENDIF
   ,
   him_event_encntr_id =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=1)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].doc_qual[1].him_event_encntr_id)
   ELSE ""
   ENDIF
   , him_event_end_effective_dt_tm =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=1)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].doc_qual[1].him_event_end_effective_dt_tm)
   ELSE ""
   ENDIF
   , him_event_event_cd =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=1)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].doc_qual[1].him_event_event_cd)
   ELSE ""
   ENDIF
   ,
   him_event_event_id =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=1)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].doc_qual[1].him_event_event_id)
   ELSE ""
   ENDIF
   , him_event_him_event_allocation_id =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=1)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].doc_qual[1].him_event_him_event_allocation_id)
   ELSE ""
   ENDIF
   , him_event_prsnl_id =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=1)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].doc_qual[1].him_event_prsnl_id)
   ELSE ""
   ENDIF
   ,
   him_event_request_dt_tm =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=1)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].doc_qual[1].him_event_request_dt_tm)
   ELSE ""
   ENDIF
   , him_event_updt_dt_tm =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=1)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].doc_qual[1].him_event_updt_dt_tm)
   ELSE ""
   ENDIF
   , him_event_updt_id =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=1)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].doc_qual[1].him_event_updt_id)
   ELSE ""
   ENDIF
   ,
   him_event_updt_task =
   IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=1)) build(data->qual[d.seq].
     defic_qual[ddefic.seq].doc_qual[1].him_event_updt_task)
   ELSE ""
   ENDIF
   FROM (dummyt d  WITH seq = value(size(data->qual,5))),
    (dummyt ddefic  WITH seq = value(data->max_defic_qual_count))
   PLAN (d
    WHERE d.seq > 0
     AND parser(ms_chartage_clause)
     AND parser(ms_position_clause))
    JOIN (ddefic
    WHERE ddefic.seq <= size(data->qual[d.seq].defic_qual,5)
     AND parser(ms_deficiencyage_clause))
   ORDER BY organization_name, organization_id, physician_name,
    physician_id, sort_disch_dt_tm, alpha_patient_name,
    encntr_id, deficiency_name, deficiency_status
   HEAD REPORT
    _vcwriteln = build2("<STYLE>",
     "table {border-collapse: collapse; empty-cells: show;  border: 0.000in none #000000;}",
     ".FieldName000 { border-width: 0.014in; border-color: #000000;",
     " border-style: none none none none;"," padding: 0.000in 0.000in 0.000in 0.000in;",
     " font: italic bold 10pt Times;"," "," color: #ff0000;"," background: #ffffff;",
     " text-align: left;",
     " vertical-align: bottom;}",".FieldName010 { border-width: 0.014in; border-color: #000000;",
     " border-style: solid solid none solid;"," padding: 0.000in 0.000in 0.000in 0.000in;",
     " font: italic bold 12pt Times;",
     " "," color: #0000a0;"," "," text-align: center;"," vertical-align: bottom;}",
     ".FieldName020 { border-width: 0.014in; border-color: #000000;",
     " border-style: none solid solid solid;"," padding: 0.000in 0.000in 0.000in 0.000in;",
     " font: italic bold 12pt Times;"," ",
     " color: #0000a0;"," "," text-align: center;"," vertical-align: top;}",
     ".FieldName030 { border-width: 0.014in; border-color: #000000;",
     " border-style: none none none none;"," padding: 0.000in 0.000in 0.000in 0.000in;",
     " font:   10pt Times;"," "," color: #000000;",
     " "," text-align: left;"," vertical-align: top;}",
     ".FieldName040 { border-width: 0.014in; border-color: #000000;",
     " border-style: none none none none;",
     " padding: 0.000in 0.000in 0.000in 0.000in;"," font:  bold 10pt Times;"," "," color: #000000;",
     " ",
     " text-align: left;"," vertical-align: middle;}",
     ".FieldName051 { border-width: 0.014in; border-color: #000000;",
     " border-style: none none none none;"," padding: 0.000in 0.000in 0.000in 0.000in;",
     " font:   10pt Times;"," "," color: #000000;"," "," text-align: left;",
     " vertical-align: middle;}",".FieldName072 { border-width: 0.014in; border-color: #000000;",
     " border-style: none none none none;"," padding: 0.000in 0.000in 0.000in 0.000in;",
     " font:   10pt Times;",
     " "," color: #000000;"," "," text-align: left;"," vertical-align: middle;}",
     ".FieldName090 { border-width: 0.014in; border-color: #000000;",
     " border-style: none none none none;"," padding: 0.000in 0.000in 0.000in 0.000in;",
     " font:  bold 10pt Times;"," ",
     " color: #000000;"," "," text-align: right;"," vertical-align: top;}",
     ".FieldName0100 { border-width: 0.014in; border-color: #000000;",
     " border-style: solid none none none;"," padding: 0.000in 0.000in 0.000in 0.000in;",
     " font:  bold 10pt Times;"," "," color: #000000;",
     " "," text-align: left;"," vertical-align: bottom;}",
     ".FieldName0101 { border-width: 0.014in; border-color: #000000;",
     " border-style: solid none none none;",
     " padding: 0.000in 0.000in 0.000in 0.000in;"," font:  bold 10pt Times;"," "," color: #000000;",
     " ",
     " text-align: right;"," vertical-align: bottom;}",
     ".FieldName0103 { border-width: 0.014in; border-color: #000000;",
     " border-style: solid none none none;"," padding: 0.000in 0.000in 0.000in 0.200in;",
     " font:  bold 10pt Times;"," "," color: #000000;"," "," text-align: left;",
     " vertical-align: bottom;}",".FieldName0104 { border-width: 0.014in; border-color: #000000;",
     " border-style: solid none none none;"," padding: 0.000in 0.000in 0.000in 0.000in;",
     " font:  bold 10pt Times;",
     " "," color: #000000;"," "," text-align: left;"," vertical-align: bottom;}",
     ".FieldName0110 { border-width: 0.014in; border-color: #000000;",
     " border-style: none none solid none;"," padding: 0.000in 0.000in 0.000in 0.000in;",
     " font:  bold 10pt Times;"," ",
     " color: #000000;"," "," text-align: left;"," vertical-align: bottom;}",
     ".FieldName0111 { border-width: 0.014in; border-color: #000000;",
     " border-style: none none solid none;"," padding: 0.000in 0.000in 0.000in 0.000in;",
     " font:  bold 10pt Times;"," "," color: #000000;",
     " "," text-align: left;"," vertical-align: bottom;}",
     ".FieldName0113 { border-width: 0.014in; border-color: #000000;",
     " border-style: none none solid none;",
     " padding: 0.000in 0.000in 0.000in 0.200in;"," font:  bold 10pt Times;"," "," color: #000000;",
     " ",
     " text-align: left;"," vertical-align: bottom;}",
     ".FieldName0120 { border-width: 0.015in; border-color: #000000;",
     " border-style: none none solid none;"," padding: 0.000in 0.000in 0.000in 0.000in;",
     " font:  bold 11pt Times;"," "," color: #000000;"," "," text-align: left;",
     " vertical-align: bottom;}",".FieldName0141 { border-width: 0.014in; border-color: #000000;",
     " border-style: solid none none none;"," padding: 0.000in 0.000in 0.000in 0.000in;",
     " font:  bold 10pt Times;",
     " "," color: #000000;"," "," text-align: left;"," vertical-align: bottom;}",
     ".FieldName0180 { border-width: 0.014in; border-color: #000000;",
     " border-style: none none none none;"," padding: 0.000in 0.000in 0.000in 0.200in;",
     " font:   10pt Times;"," ",
     " color: #000000;"," "," text-align: left;"," vertical-align: middle;}",
     ".FieldName0190 { border-width: 0.014in; border-color: #000000;",
     " border-style: none none none none;"," padding: 0.000in 0.000in 0.000in 0.000in;",
     " font:   10pt Times;"," "," color: #000000;",
     " "," text-align: left;"," vertical-align: middle;}",
     ".FieldName0191 { border-width: 0.014in; border-color: #000000;",
     " border-style: none none none none;",
     " padding: 0.000in 0.000in 0.000in 0.000in;"," font:   10pt Times;"," "," color: #000000;"," ",
     " text-align: left;"," vertical-align: middle;}",
     ".FieldName0193 { border-width: 0.014in; border-color: #000000;",
     " border-style: none none none none;"," padding: 0.000in 0.000in 0.000in 0.200in;",
     " font:   10pt Times;"," "," color: #000000;"," "," text-align: left;",
     " vertical-align: middle;}",".FieldName0200 { border-width: 0.014in; border-color: #000000;",
     " border-style: none none none none;"," padding: 0.000in 0.000in 0.000in 0.000in;",
     " font:   10pt Times;",
     " "," color: #000000;"," background: #e8e8e8;"," text-align: left;"," vertical-align: middle;}",
     ".FieldName0201 { border-width: 0.014in; border-color: #000000;",
     " border-style: none none none none;"," padding: 0.000in 0.000in 0.000in 0.000in;",
     " font:   10pt Times;"," ",
     " color: #000000;"," background: #e8e8e8;"," text-align: left;"," vertical-align: middle;}",
     ".FieldName0203 { border-width: 0.014in; border-color: #000000;",
     " border-style: none none none none;"," padding: 0.000in 0.000in 0.000in 0.200in;",
     " font:   10pt Times;"," "," color: #000000;",
     " background: #e8e8e8;"," text-align: left;"," vertical-align: middle;}",
     ".FieldName0210 { border-width: 0.025in; border-color: #000000;",
     " border-style: none none none none;",
     " padding: 0.000in 0.000in 0.000in 0.000in;"," font:   10pt Times;"," "," color: #000000;"," ",
     " text-align: left;"," vertical-align: middle;}",
     ".FieldName0220 { border-width: 0.025in; border-color: #000000;",
     " border-style: none none none none;"," padding: 0.000in 0.000in 0.000in 0.200in;",
     " font:   10pt Times;"," "," color: #000000;"," background: #ffffff;"," text-align: center;",
     " vertical-align: middle;}",".FieldName0230 { border-width: 0.025in; border-color: #000000;",
     " border-style: none none none none;"," padding: 0.000in 0.000in 0.000in 0.000in;",
     " font:  bold 10pt Times;",
     " "," color: #000000;"," background: #ffff80;"," text-align: left;"," vertical-align: middle;}",
     ".FieldName0231 { border-width: 0.025in; border-color: #000000;",
     " border-style: none none none none;"," padding: 0.000in 0.000in 0.000in 0.000in;",
     " font:   10pt Times;"," ",
     " color: #000000;"," background: #ffff80;"," text-align: right;"," vertical-align: middle;}",
     ".FieldName0232 { border-width: 0.025in; border-color: #000000;",
     " border-style: none none none none;"," padding: 0.000in 0.000in 0.000in 0.200in;",
     " font:  bold 10pt Times;"," "," color: #000000;",
     " background: #ffff80;"," text-align: left;"," vertical-align: middle;}",
     ".FieldName0233 { border-width: 0.025in; border-color: #000000;",
     " border-style: none none none none;",
     " padding: 0.000in 0.000in 0.000in 0.200in;"," font:   10pt Times;"," "," color: #000000;",
     " background: #ffff80;",
     " text-align: right;"," vertical-align: middle;}",
     ".FieldName0234 { border-width: 0.025in; border-color: #000000;",
     " border-style: none none none none;"," padding: 0.000in 0.000in 0.000in 0.200in;",
     " font:   10pt Times;"," "," color: #000000;"," background: #ffff80;"," text-align: center;",
     " vertical-align: middle;}",".FieldName0240 { border-width: 0.025in; border-color: #000000;",
     " border-style: none none none none;"," padding: 0.000in 0.000in 0.000in 0.000in;",
     " font:  bold 11pt Times;",
     " "," color: #000000;"," background: #ffffff;"," text-align: left;"," vertical-align: middle;}",
     ".FieldName0242 { border-width: 0.025in; border-color: #000000;",
     " border-style: none none none none;"," padding: 0.000in 0.000in 0.000in 0.000in;",
     " font:  bold 10pt Times;"," ",
     " color: #000000;"," background: #ffffff;"," text-align: left;"," vertical-align: middle;}",
     ".FieldName0243 { border-width: 0.025in; border-color: #000000;",
     " border-style: none none none none;"," padding: 0.000in 0.000in 0.000in 0.000in;",
     " font:   10pt Times;"," "," color: #000000;",
     " background: #ffffff;"," text-align: right;"," vertical-align: middle;}",
     ".FieldName0244 { border-width: 0.025in; border-color: #000000;",
     " border-style: none none none none;",
     " padding: 0.000in 0.000in 0.000in 0.000in;"," font:  bold 10pt Times;"," "," color: #000000;",
     " background: #ffffff;",
     " text-align: left;"," vertical-align: middle;}",
     ".FieldName0245 { border-width: 0.025in; border-color: #000000;",
     " border-style: none none none none;"," padding: 0.000in 0.000in 0.000in 0.000in;",
     " font:   10pt Times;"," "," color: #000000;"," background: #ffffff;"," text-align: center;",
     " vertical-align: middle;}",".FieldName0250 { border-width: 0.025in; border-color: #000000;",
     " border-style: none none none none;"," padding: 0.000in 0.000in 0.000in 0.000in;",
     " font:  bold 11pt Times;",
     " "," color: #000000;"," background: #ffff80;"," text-align: left;"," vertical-align: middle;}",
     ".FieldName0252 { border-width: 0.025in; border-color: #000000;",
     " border-style: none none none none;"," padding: 0.000in 0.000in 0.000in 0.000in;",
     " font:  bold 10pt Times;"," ",
     " color: #000000;"," background: #ffff80;"," text-align: left;"," vertical-align: middle;}",
     ".FieldName0255 { border-width: 0.025in; border-color: #000000;",
     " border-style: none none none none;"," padding: 0.000in 0.000in 0.000in 0.000in;",
     " font:   10pt Times;"," "," color: #000000;",
     " background: #ffff80;"," text-align: right;"," vertical-align: middle;}",
     ".FieldName0256 { border-width: 0.025in; border-color: #000000;",
     " border-style: none none none none;",
     " padding: 0.000in 0.000in 0.000in 0.000in;"," font:   10pt Times;"," "," color: #000000;",
     " background: #ffff80;",
     " text-align: center;"," vertical-align: middle;}",
     ".FieldName0260 { border-width: 0.020in; border-color: #000000;",
     " border-style: none none none none;"," padding: 0.000in 0.000in 0.000in 0.000in;",
     " font:  bold 11pt Times;"," "," color: #000000;"," "," text-align: left;",
     " vertical-align: middle;}",".FieldName0270 { border-width: 0.020in; border-color: #000000;",
     " border-style: solid none none none;"," padding: 0.000in 0.000in 0.000in 0.000in;",
     " font:  bold 11pt Times;",
     " "," color: #000000;"," background: #ffff80;"," text-align: left;"," vertical-align: middle;}",
     ".FieldName0271 { border-width: 0.020in; border-color: #000000;",
     " border-style: solid none none none;"," padding: 0.000in 0.000in 0.000in 0.000in;",
     " font:  bold 10pt Times;"," ",
     " color: #000000;"," background: #ffff80;"," text-align: left;"," vertical-align: middle;}",
     ".FieldName0272 { border-width: 0.020in; border-color: #000000;",
     " border-style: solid none none none;"," padding: 0.000in 0.000in 0.000in 0.000in;",
     " font:   10pt Times;"," "," color: #000000;",
     " background: #ffff80;"," text-align: right;"," vertical-align: middle;}",
     ".FieldName0273 { border-width: 0.020in; border-color: #000000;",
     " border-style: solid none none none;",
     " padding: 0.000in 0.000in 0.000in 0.200in;"," font:  bold 10pt Times;"," "," color: #000000;",
     " background: #ffff80;",
     " text-align: left;"," vertical-align: middle;}",
     ".FieldName0274 { border-width: 0.020in; border-color: #000000;",
     " border-style: solid none none none;"," padding: 0.000in 0.000in 0.000in 0.000in;",
     " font:   10pt Times;"," "," color: #000000;"," background: #ffff80;"," text-align: right;",
     " vertical-align: middle;}",".FieldName0280 { border-width: 0.015in; border-color: #000000;",
     " border-style: solid none none none;"," padding: 0.000in 0.000in 0.000in 0.000in;",
     " font:  bold 11pt Times;",
     " "," color: #000000;"," "," text-align: left;"," vertical-align: middle;}",
     ".FieldName0290 { border-width: 0.020in; border-color: #000000;",
     " border-style: none none none none;"," padding: 0.000in 0.000in 0.000in 0.000in;",
     " font:  bold 10pt Times;"," ",
     " color: #000000;"," "," text-align: center;"," vertical-align: middle;}","</STYLE>"),
    _htmlfilestat = uar_fwrite(_vcwriteln,1,textlen(_vcwriteln),_htmlfilehandle), _vcwriteln =
    "<table width='100%'><caption><thead>",
    _htmlfilestat = uar_fwrite(_vcwriteln,1,textlen(_vcwriteln),_htmlfilehandle)
    IF (_bgeneratehtml)
     _vcwriteln = build2("<tr>","<td width='100.000%'"," class='FieldName000' colspan='20'>",
      cclbuildhlink(him_program_name,him_render_params,him_window,"Printer Friendly Version"),"</td>",
      "</tr>"), _htmlfilestat = uar_fwrite(_vcwriteln,1,textlen(_vcwriteln),_htmlfilehandle),
     _vcwriteln = build2("<tr>","<td width='100.000%'"," class='FieldName000' colspan='20'>",
      cclbuildhlink(him_program_name,him_render_params_excel,him_window,"Excel Version"),"</td>",
      "</tr>"),
     _htmlfilestat = uar_fwrite(_vcwriteln,1,textlen(_vcwriteln),_htmlfilehandle)
    ENDIF
    _vcwriteln = build2("<tr>","<td width='100.000%'"," class='FieldName010' colspan='20'>",
     uar_i18ngetmessage(_hi18nhandle,"HIM_MAK_DEFIC_BY_PHYS_DET_LYT_CellName0",
      "Deficiency Reporting by Physician"),"</td>",
     "</tr>"), _htmlfilestat = uar_fwrite(_vcwriteln,1,textlen(_vcwriteln),_htmlfilehandle),
    _vcwriteln = build2("<tr>","<td width='100.000%'"," class='FieldName020' colspan='20'>",
     uar_i18ngetmessage(_hi18nhandle,"HIM_MAK_DEFIC_BY_PHYS_DET_LYT_CellName81","Detailed Report"),
     "</td>",
     "</tr>"),
    _htmlfilestat = uar_fwrite(_vcwriteln,1,textlen(_vcwriteln),_htmlfilehandle), rowcount = 0, blank
     = "",
    total_chart_cnt = 0, total_def_cnt = 0, _vcwriteln = build2("<tr>","<td width='100.000%'",
     " class='FieldName030' colspan='20'>",blank,"</td>",
     "</tr>"),
    _htmlfilestat = uar_fwrite(_vcwriteln,1,textlen(_vcwriteln),_htmlfilehandle), _vcwriteln = build2
    ("<tr>","<td width='13.750%'"," class='FieldName040' colspan='3'>",i18ndateprinted,"</td>",
     "<td width='86.250%'"," class='FieldName030' colspan='17'>",vctodaydatetime,"</td>","</tr>"),
    _htmlfilestat = uar_fwrite(_vcwriteln,1,textlen(_vcwriteln),_htmlfilehandle),
    _vcwriteln = build2("<tr>","<td width='13.750%'"," class='FieldName040' colspan='3'>",
     i18nuserprinted,"</td>",
     "<td width='86.250%'"," class='FieldName051' colspan='17'>",vcuser,"</td>","</tr>"),
    _htmlfilestat = uar_fwrite(_vcwriteln,1,textlen(_vcwriteln),_htmlfilehandle), _vcwriteln = build2
    ("<tr>","<td width='13.750%'"," class='FieldName040' colspan='3'>",i18npromptsfilters,"</td>",
     "<td width='86.250%'"," class='FieldName030' colspan='17'>","","</td>","</tr>"),
    _htmlfilestat = uar_fwrite(_vcwriteln,1,textlen(_vcwriteln),_htmlfilehandle), allfacilities =
    uar_i18ngetmessage(i18nhandlehim,"ALLFACILITIES","All Facilities"), facilitylist =
    makelistofqualitemnames(organizations,allfacilities)
    IF (i1multifacilitylogicind)
     _vcwriteln = build2("<tr>","<td width='13.750%'"," class='FieldName030' colspan='3'>","",
      "</td>",
      "<td width='20.625%'"," class='FieldName040' colspan='5'>",i18nfacilities,"</td>",
      "<td width='65.625%'",
      " class='FieldName072' colspan='12'>",facilitylist,"</td>","</tr>"), _htmlfilestat = uar_fwrite
     (_vcwriteln,1,textlen(_vcwriteln),_htmlfilehandle)
    ENDIF
    allphysicians = uar_i18ngetmessage(i18nhandlehim,"ALLPHYSICIANS","All Physicians"), physicianlist
     = makelistofqualitemnames(physicians,allphysicians), allpositions = "All Positions",
    positionlist = makelistofqualitemnames(positions,allpositions), _vcwriteln = build2("<tr>",
     "<td width='13.750%'"," class='FieldName030' colspan='3'>","","</td>",
     "<td width='20.625%'"," class='FieldName040' colspan='5'>",uar_i18ngetmessage(_hi18nhandle,
      "HIM_MAK_DEFIC_BY_PHYS_DET_LYT_CellName4","Physician(s):"),"</td>","<td width='65.625%'",
     " class='FieldName072' colspan='12'>",physicianlist,"</td>","</tr>"), _htmlfilestat = uar_fwrite
    (_vcwriteln,1,textlen(_vcwriteln),_htmlfilehandle),
    _vcwriteln = build2("<tr>","<td width='13.750%'"," class='FieldName030' colspan='3'>","","</td>",
     "<td width='20.625%'"," class='FieldName040' colspan='5'>",uar_i18ngetmessage(_hi18nhandle,
      "HIM_MAK_DEFIC_BY_PHYS_DET_LYT_CellName4","Chart Age:"),"</td>","<td width='65.625%'",
     " class='FieldName072' colspan='12'>", $MS_CHARTAGE,"</td>","</tr>"), _htmlfilestat = uar_fwrite
    (_vcwriteln,1,textlen(_vcwriteln),_htmlfilehandle), _vcwriteln = build2("<tr>",
     "<td width='13.750%'"," class='FieldName030' colspan='3'>","","</td>",
     "<td width='20.625%'"," class='FieldName040' colspan='5'>",uar_i18ngetmessage(_hi18nhandle,
      "HIM_MAK_DEFIC_BY_PHYS_DET_LYT_CellName4","Deficiency Age:"),"</td>","<td width='65.625%'",
     " class='FieldName072' colspan='12'>", $MS_DEFAGE,"</td>","</tr>"),
    _htmlfilestat = uar_fwrite(_vcwriteln,1,textlen(_vcwriteln),_htmlfilehandle), _vcwriteln = build2
    ("<tr>","<td width='13.750%'"," class='FieldName030' colspan='3'>","","</td>",
     "<td width='20.625%'"," class='FieldName040' colspan='5'>",uar_i18ngetmessage(_hi18nhandle,
      "HIM_MAK_DEFIC_BY_PHYS_DET_LYT_CellName4","Positions:"),"</td>","<td width='65.625%'",
     " class='FieldName072' colspan='12'>",positionlist,"</td>","</tr>"), _htmlfilestat = uar_fwrite(
     _vcwriteln,1,textlen(_vcwriteln),_htmlfilehandle),
    pageofpage = rpt_pageofpage
    IF (negate(_bgeneratehtml))
     _vcwriteln = build2("<tr>","<td width='100.000%'"," class='FieldName090' colspan='20'>",
      pageofpage,"</td>",
      "</tr>"), _htmlfilestat = uar_fwrite(_vcwriteln,1,textlen(_vcwriteln),_htmlfilehandle)
    ENDIF
    IF (rowcount > 1)
     _vcwriteln = build2("<tr>","<td width='13.750%'"," class='FieldName0100' colspan='3'>",
      uar_i18ngetmessage(_hi18nhandle,"HIM_MAK_DEFIC_BY_PHYS_DET_LYT_CellName27","Patient"),"</td>",
      "<td width='10.000%'"," class='FieldName0101' colspan='2'>","","</td>","<td width='8.750%'",
      " class='FieldName0101' colspan='2'>","","</td>","<td width='11.250%'",
      " class='FieldName0103' colspan='3'>",
      uar_i18ngetmessage(_hi18nhandle,"HIM_MAK_DEFIC_BY_PHYS_DET_LYT_CellName53","Discharge"),"</td>",
      "<td width='13.125%'"," class='FieldName0104' colspan='3'>","",
      "</td>","<td width='11.875%'"," class='FieldName0104' colspan='2'>","","</td>",
      "<td width='8.750%'"," class='FieldName0104' colspan='2'>",uar_i18ngetmessage(_hi18nhandle,
       "HIM_MAK_DEFIC_BY_PHYS_DET_LYT_CellName24","Deficiency"),"</td>","<td width='8.750%'",
      " class='FieldName0104' colspan='1'>",uar_i18ngetmessage(_hi18nhandle,
       "HIM_MAK_DEFIC_BY_PHYS_DET_LYT_CellName5","Chart"),"</td>","<td width='13.750%'",
      " class='FieldName0100' colspan='2'>",
      "","</td>","</tr>"), _htmlfilestat = uar_fwrite(_vcwriteln,1,textlen(_vcwriteln),
      _htmlfilehandle)
    ENDIF
    IF (rowcount > 1)
     _vcwriteln = build2("<tr>","<td width='13.750%'"," class='FieldName0110' colspan='3'>",
      uar_i18ngetmessage(_hi18nhandle,"HIM_MAK_DEFIC_BY_PHYS_DET_LYT_CellName33","Name"),"</td>",
      "<td width='10.000%'"," class='FieldName0111' colspan='2'>",uar_i18ngetmessage(_hi18nhandle,
       "HIM_MAK_DEFIC_BY_PHYS_DET_LYT_CellName31","MRN"),"</td>","<td width='8.750%'",
      " class='FieldName0111' colspan='2'>",uar_i18ngetmessage(_hi18nhandle,
       "HIM_MAK_DEFIC_BY_PHYS_DET_LYT_CellName32","FIN"),"</td>","<td width='11.250%'",
      " class='FieldName0113' colspan='3'>",
      uar_i18ngetmessage(_hi18nhandle,"HIM_MAK_DEFIC_BY_PHYS_DET_LYT_CellName54","Date"),"</td>",
      "<td width='13.125%'"," class='FieldName0111' colspan='3'>",uar_i18ngetmessage(_hi18nhandle,
       "HIM_MAK_DEFIC_BY_PHYS_DET_LYT_CellName66","Deficiency"),
      "</td>","<td width='11.875%'"," class='FieldName0111' colspan='2'>",uar_i18ngetmessage(
       _hi18nhandle,"HIM_MAK_DEFIC_BY_PHYS_DET_LYT_CellName29","Status"),"</td>",
      "<td width='8.750%'"," class='FieldName0111' colspan='2'>",uar_i18ngetmessage(_hi18nhandle,
       "HIM_MAK_DEFIC_BY_PHYS_DET_LYT_CellName8","Age"),"</td>","<td width='8.750%'",
      " class='FieldName0111' colspan='1'>",uar_i18ngetmessage(_hi18nhandle,
       "HIM_MAK_DEFIC_BY_PHYS_DET_LYT_CellName217","Age"),"</td>","<td width='13.750%'",
      " class='FieldName0110' colspan='2'>",
      uar_i18ngetmessage(_hi18nhandle,"HIM_MAK_DEFIC_BY_PHYS_DET_LYT_CellName203","Location"),"</td>",
      "</tr>"), _htmlfilestat = uar_fwrite(_vcwriteln,1,textlen(_vcwriteln),_htmlfilehandle)
    ENDIF
    _vcwriteln = "</thead><tbody>", _htmlfilestat = uar_fwrite(_vcwriteln,1,textlen(_vcwriteln),
     _htmlfilehandle)
   HEAD organization_name
    IF (0)
     _vcwriteln = build2("<tr>","<td width='100.000%'"," class='FieldName0120' colspan='20'>","",
      "</td>",
      "</tr>"), _htmlfilestat = uar_fwrite(_vcwriteln,1,textlen(_vcwriteln),_htmlfilehandle)
    ENDIF
   HEAD organization_id
    organization = organization_name, org_def_cnt = 0, org_chart_cnt = 0,
    _vcwriteln = build2("<tr>","<td width='100.000%'"," class='FieldName0120' colspan='20'>",
     organization,"</td>",
     "</tr>"), _htmlfilestat = uar_fwrite(_vcwriteln,1,textlen(_vcwriteln),_htmlfilehandle)
   HEAD physician_name
    IF (0)
     _vcwriteln = build2("<tr>","<td width='12.500%'"," class='FieldName0103' colspan='1'>","",
      "</td>",
      "<td width='87.500%'"," class='FieldName0141' colspan='19'>","","</td>","</tr>"),
     _htmlfilestat = uar_fwrite(_vcwriteln,1,textlen(_vcwriteln),_htmlfilehandle)
    ENDIF
   HEAD physician_id
    physicianname = physician_name, phys_def_cnt = 0, phys_chart_cnt = 0,
    _vcwriteln = build2("<tr>","<td width='12.500%'"," class='FieldName0103' colspan='1'>",
     uar_i18ngetmessage(_hi18nhandle,"HIM_MAK_DEFIC_BY_PHYS_DET_LYT_physicianDisplay","Physician:"),
     "</td>",
     "<td width='87.500%'"," class='FieldName0141' colspan='19'>",physicianname,"</td>","</tr>"),
    _htmlfilestat = uar_fwrite(_vcwriteln,1,textlen(_vcwriteln),_htmlfilehandle), _vcwriteln = build2
    ("<tr>","<td width='13.750%'"," class='FieldName0100' colspan='3'>",uar_i18ngetmessage(
      _hi18nhandle,"HIM_MAK_DEFIC_BY_PHYS_DET_LYT_CellName49","Patient"),"</td>",
     "<td width='10.000%'"," class='FieldName0101' colspan='2'>","","</td>","<td width='8.750%'",
     " class='FieldName0101' colspan='2'>","","</td>","<td width='11.250%'",
     " class='FieldName0103' colspan='3'>",
     uar_i18ngetmessage(_hi18nhandle,"HIM_MAK_DEFIC_BY_PHYS_DET_LYT_CellName216","Discharge"),"</td>",
     "<td width='13.125%'"," class='FieldName0104' colspan='3'>","",
     "</td>","<td width='11.875%'"," class='FieldName0104' colspan='2'>","","</td>",
     "<td width='8.750%'"," class='FieldName0104' colspan='2'>",uar_i18ngetmessage(_hi18nhandle,
      "HIM_MAK_DEFIC_BY_PHYS_DET_LYT_CellName211","Deficiency"),"</td>","<td width='8.750%'",
     " class='FieldName0104' colspan='1'>",uar_i18ngetmessage(_hi18nhandle,
      "HIM_MAK_DEFIC_BY_PHYS_DET_LYT_CellName219","Chart"),"</td>","<td width='13.750%'",
     " class='FieldName0100' colspan='2'>",
     "","</td>","</tr>"),
    _htmlfilestat = uar_fwrite(_vcwriteln,1,textlen(_vcwriteln),_htmlfilehandle), _vcwriteln = build2
    ("<tr>","<td width='13.750%'"," class='FieldName0110' colspan='3'>",uar_i18ngetmessage(
      _hi18nhandle,"HIM_MAK_DEFIC_BY_PHYS_DET_LYT_CellName41","Name"),"</td>",
     "<td width='10.000%'"," class='FieldName0111' colspan='2'>",uar_i18ngetmessage(_hi18nhandle,
      "HIM_MAK_DEFIC_BY_PHYS_DET_LYT_CellName39","MRN"),"</td>","<td width='8.750%'",
     " class='FieldName0111' colspan='2'>",uar_i18ngetmessage(_hi18nhandle,
      "HIM_MAK_DEFIC_BY_PHYS_DET_LYT_CellName40","FIN"),"</td>","<td width='11.250%'",
     " class='FieldName0113' colspan='3'>",
     uar_i18ngetmessage(_hi18nhandle,"HIM_MAK_DEFIC_BY_PHYS_DET_LYT_CellName215","Date"),"</td>",
     "<td width='13.125%'"," class='FieldName0111' colspan='3'>",uar_i18ngetmessage(_hi18nhandle,
      "HIM_MAK_DEFIC_BY_PHYS_DET_LYT_CellName214","Deficiency"),
     "</td>","<td width='11.875%'"," class='FieldName0111' colspan='2'>",uar_i18ngetmessage(
      _hi18nhandle,"HIM_MAK_DEFIC_BY_PHYS_DET_LYT_CellName213","Status"),"</td>",
     "<td width='8.750%'"," class='FieldName0111' colspan='2'>",uar_i18ngetmessage(_hi18nhandle,
      "HIM_MAK_DEFIC_BY_PHYS_DET_LYT_CellName212","Age"),"</td>","<td width='8.750%'",
     " class='FieldName0111' colspan='1'>",uar_i18ngetmessage(_hi18nhandle,
      "HIM_MAK_DEFIC_BY_PHYS_DET_LYT_CellName218","Age"),"</td>","<td width='13.750%'",
     " class='FieldName0110' colspan='2'>",
     uar_i18ngetmessage(_hi18nhandle,"HIM_MAK_DEFIC_BY_PHYS_DET_LYT_CellName220","Location"),"</td>",
     "</tr>"), _htmlfilestat = uar_fwrite(_vcwriteln,1,textlen(_vcwriteln),_htmlfilehandle)
   HEAD encntr_id
    blank2 = "", displayind = 1, phys_chart_cnt = (phys_chart_cnt+ 1),
    previousencntrid = 0.0
    IF (0)
     _vcwriteln = build2("<tr>","<td width='100.000%'"," class='FieldName0180' colspan='20'>",blank2,
      "</td>",
      "</tr>"), _htmlfilestat = uar_fwrite(_vcwriteln,1,textlen(_vcwriteln),_htmlfilehandle)
    ENDIF
   DETAIL
    patientnameone = patient_name, phys_def_cnt = (phys_def_cnt+ 1), rowcount = (rowcount+ 1),
    mrndisplayrowone = mrn
    IF (deficiency_age > 0)
     num_hours = mod(deficiency_age,24), num_days = (deficiency_age/ 24), deficageone =
     uar_i18nbuildmessage(i18nhandlehim,"DeficAge","%1 Days %2 Hours","ii",num_days,
      num_hours)
    ELSE
     deficageone = "--"
    ENDIF
    IF (chart_age > 0)
     chartageone = uar_i18nbuildmessage(i18nhandlehim,"ChartAge","%1 Days","i",chart_age)
    ELSE
     chartageone = "--"
    ENDIF
    locationone =
    IF (size(trim(location)) > 0) location
    ELSE build("--")
    ENDIF
    IF (mod(rowcount,2)=1)
     _vcwriteln = build2("<tr>"," "), _htmlfilestat = uar_fwrite(_vcwriteln,1,textlen(_vcwriteln),
      _htmlfilehandle)
     IF (displayind)
      _vcwriteln = build2("<td width='13.750%'"," class='FieldName0190' colspan='3'>",patientnameone,
       "</td>"," ")
     ELSE
      _vcwriteln = build2("<td width='13.750%'"," class='FieldName0190' colspan='3'>","","</td>")
     ENDIF
     _htmlfilestat = uar_fwrite(_vcwriteln,1,textlen(_vcwriteln),_htmlfilehandle), _vcwriteln =
     build2(" "), _htmlfilestat = uar_fwrite(_vcwriteln,1,textlen(_vcwriteln),_htmlfilehandle)
     IF (displayind)
      _vcwriteln = build2("<td width='10.000%'"," class='FieldName0191' colspan='2'>",
       mrndisplayrowone,"</td>"," ")
     ELSE
      _vcwriteln = build2("<td width='10.000%'"," class='FieldName0191' colspan='2'>","","</td>")
     ENDIF
     _htmlfilestat = uar_fwrite(_vcwriteln,1,textlen(_vcwriteln),_htmlfilehandle), _vcwriteln =
     build2(" "), _htmlfilestat = uar_fwrite(_vcwriteln,1,textlen(_vcwriteln),_htmlfilehandle)
     IF (displayind)
      _vcwriteln = build2("<td width='8.750%'"," class='FieldName0191' colspan='2'>",fin,"</td>"," "
       )
     ELSE
      _vcwriteln = build2("<td width='8.750%'"," class='FieldName0191' colspan='2'>","","</td>")
     ENDIF
     _htmlfilestat = uar_fwrite(_vcwriteln,1,textlen(_vcwriteln),_htmlfilehandle), _vcwriteln =
     build2(" "), _htmlfilestat = uar_fwrite(_vcwriteln,1,textlen(_vcwriteln),_htmlfilehandle)
     IF (displayind)
      _vcwriteln = build2("<td width='11.250%'"," class='FieldName0193' colspan='3'>",format(
        disch_dt_tm,"@SHORTDATE"),"</td>"," ")
     ELSE
      _vcwriteln = build2("<td width='11.250%'"," class='FieldName0193' colspan='3'>","","</td>")
     ENDIF
     _htmlfilestat = uar_fwrite(_vcwriteln,1,textlen(_vcwriteln),_htmlfilehandle), _vcwriteln =
     build2("<td width='13.125%'"," class='FieldName0191' colspan='3'>",deficiency_name,"</td>",
      "<td width='11.875%'",
      " class='FieldName0191' colspan='2'>",deficiency_status,"</td>","<td width='8.750%'",
      " class='FieldName0191' colspan='2'>",
      deficageone,"</td>"," "), _htmlfilestat = uar_fwrite(_vcwriteln,1,textlen(_vcwriteln),
      _htmlfilehandle)
     IF (displayind)
      _vcwriteln = build2("<td width='8.750%'"," class='FieldName0191' colspan='1'>",chartageone,
       "</td>"," ")
     ELSE
      _vcwriteln = build2("<td width='8.750%'"," class='FieldName0191' colspan='1'>","","</td>")
     ENDIF
     _htmlfilestat = uar_fwrite(_vcwriteln,1,textlen(_vcwriteln),_htmlfilehandle), _vcwriteln =
     build2(" "), _htmlfilestat = uar_fwrite(_vcwriteln,1,textlen(_vcwriteln),_htmlfilehandle)
     IF (displayind)
      _vcwriteln = build2("<td width='13.750%'"," class='FieldName0190' colspan='2'>",locationone,
       "</td>"," ")
     ELSE
      _vcwriteln = build2("<td width='13.750%'"," class='FieldName0190' colspan='2'>","","</td>")
     ENDIF
     _htmlfilestat = uar_fwrite(_vcwriteln,1,textlen(_vcwriteln),_htmlfilehandle), _vcwriteln =
     build2("</tr>"), _htmlfilestat = uar_fwrite(_vcwriteln,1,textlen(_vcwriteln),_htmlfilehandle)
    ENDIF
    IF (deficiency_age > 0)
     num_hours = mod(deficiency_age,24), num_days = (deficiency_age/ 24), deficagetwo =
     uar_i18nbuildmessage(i18nhandlehim,"DeficAge","%1 Days %2 Hours","ii",num_days,
      num_hours)
    ELSE
     deficagetwo = "--"
    ENDIF
    IF (chart_age > 0)
     chartagetwo = uar_i18nbuildmessage(i18nhandlehim,"ChartAge","%1 Days","i",chart_age)
    ELSE
     chartagetwo = "--"
    ENDIF
    locationtwo =
    IF (size(trim(location)) > 0) location
    ELSE build("--")
    ENDIF
    IF (mod(rowcount,2)=0)
     _vcwriteln = build2("<tr>"," "), _htmlfilestat = uar_fwrite(_vcwriteln,1,textlen(_vcwriteln),
      _htmlfilehandle)
     IF (displayind)
      _vcwriteln = build2("<td width='13.750%'"," class='FieldName0200' colspan='3'>",patient_name,
       "</td>"," ")
     ELSE
      _vcwriteln = build2("<td width='13.750%'"," class='FieldName0200' colspan='3'>","","</td>")
     ENDIF
     _htmlfilestat = uar_fwrite(_vcwriteln,1,textlen(_vcwriteln),_htmlfilehandle), _vcwriteln =
     build2(" "), _htmlfilestat = uar_fwrite(_vcwriteln,1,textlen(_vcwriteln),_htmlfilehandle)
     IF (displayind)
      _vcwriteln = build2("<td width='10.000%'"," class='FieldName0201' colspan='2'>",mrn,"</td>",
       " ")
     ELSE
      _vcwriteln = build2("<td width='10.000%'"," class='FieldName0201' colspan='2'>","","</td>")
     ENDIF
     _htmlfilestat = uar_fwrite(_vcwriteln,1,textlen(_vcwriteln),_htmlfilehandle), _vcwriteln =
     build2(" "), _htmlfilestat = uar_fwrite(_vcwriteln,1,textlen(_vcwriteln),_htmlfilehandle)
     IF (displayind)
      _vcwriteln = build2("<td width='8.750%'"," class='FieldName0201' colspan='2'>",fin,"</td>"," "
       )
     ELSE
      _vcwriteln = build2("<td width='8.750%'"," class='FieldName0201' colspan='2'>","","</td>")
     ENDIF
     _htmlfilestat = uar_fwrite(_vcwriteln,1,textlen(_vcwriteln),_htmlfilehandle), _vcwriteln =
     build2(" "), _htmlfilestat = uar_fwrite(_vcwriteln,1,textlen(_vcwriteln),_htmlfilehandle)
     IF (displayind)
      _vcwriteln = build2("<td width='11.250%'"," class='FieldName0203' colspan='3'>",format(
        disch_dt_tm,"@SHORTDATE"),"</td>"," ")
     ELSE
      _vcwriteln = build2("<td width='11.250%'"," class='FieldName0203' colspan='3'>","","</td>")
     ENDIF
     _htmlfilestat = uar_fwrite(_vcwriteln,1,textlen(_vcwriteln),_htmlfilehandle), _vcwriteln =
     build2("<td width='13.125%'"," class='FieldName0201' colspan='3'>",deficiency_name,"</td>",
      "<td width='11.875%'",
      " class='FieldName0201' colspan='2'>",deficiency_status,"</td>","<td width='8.750%'",
      " class='FieldName0201' colspan='2'>",
      deficagetwo,"</td>"," "), _htmlfilestat = uar_fwrite(_vcwriteln,1,textlen(_vcwriteln),
      _htmlfilehandle)
     IF (displayind)
      _vcwriteln = build2("<td width='8.750%'"," class='FieldName0201' colspan='1'>",chartagetwo,
       "</td>"," ")
     ELSE
      _vcwriteln = build2("<td width='8.750%'"," class='FieldName0201' colspan='1'>","","</td>")
     ENDIF
     _htmlfilestat = uar_fwrite(_vcwriteln,1,textlen(_vcwriteln),_htmlfilehandle), _vcwriteln =
     build2(" "), _htmlfilestat = uar_fwrite(_vcwriteln,1,textlen(_vcwriteln),_htmlfilehandle)
     IF (displayind)
      _vcwriteln = build2("<td width='13.750%'"," class='FieldName0200' colspan='2'>",locationtwo,
       "</td>"," ")
     ELSE
      _vcwriteln = build2("<td width='13.750%'"," class='FieldName0200' colspan='2'>","","</td>")
     ENDIF
     _htmlfilestat = uar_fwrite(_vcwriteln,1,textlen(_vcwriteln),_htmlfilehandle), _vcwriteln =
     build2("</tr>"), _htmlfilestat = uar_fwrite(_vcwriteln,1,textlen(_vcwriteln),_htmlfilehandle)
    ENDIF
    blank3 = ""
    IF (((previousencntrid=encntr_id) OR (_bgeneratehtml=1)) )
     displayind = 0
    ENDIF
    previousencntrid = encntr_id
    IF (0)
     _vcwriteln = build2("<tr>","<td width='100.000%'"," class='FieldName0210' colspan='20'>",blank3,
      "</td>",
      "</tr>"), _htmlfilestat = uar_fwrite(_vcwriteln,1,textlen(_vcwriteln),_htmlfilehandle)
    ENDIF
   FOOT  physician_id
    _vcwriteln = build2("<tr>","<td width='100.000%'"," class='FieldName0220' colspan='20'>","",
     "</td>",
     "</tr>"), _htmlfilestat = uar_fwrite(_vcwriteln,1,textlen(_vcwriteln),_htmlfilehandle),
    phystotaldefic = phys_def_cnt,
    org_def_cnt = (org_def_cnt+ phys_def_cnt), org_chart_cnt = (org_chart_cnt+ phys_chart_cnt),
    _vcwriteln = build2("<tr>","<td width='13.125%'"," class='FieldName0230' colspan='2'>",
     uar_i18ngetmessage(_hi18nhandle,"HIM_MAK_DEFIC_BY_PHYS_DET_LYT_physTotalDef",
      "Total Deficiencies:"),"</td>",
     "<td width='11.250%'"," class='FieldName0231' colspan='4'>",phystotaldefic,"</td>",
     "<td width='10.000%'",
     " class='FieldName0232' colspan='2'>",uar_i18ngetmessage(_hi18nhandle,
      "HIM_MAK_DEFIC_BY_PHYS_DET_LYT_CellName86","Total Charts:"),"</td>","<td width='11.250%'",
     " class='FieldName0233' colspan='3'>",
     phys_chart_cnt,"</td>","<td width='54.375%'"," class='FieldName0234' colspan='9'>","",
     "</td>","</tr>"),
    _htmlfilestat = uar_fwrite(_vcwriteln,1,textlen(_vcwriteln),_htmlfilehandle)
   FOOT  organization_id
    _vcwriteln = build2("<tr>","<td width='20.000%'"," class='FieldName0240' colspan='4'>","",
     "</td>",
     "<td width='16.875%'"," class='FieldName0240' colspan='5'>","","</td>","<td width='12.500%'",
     " class='FieldName0242' colspan='3'>","","</td>","<td width='15.625%'",
     " class='FieldName0243' colspan='2'>",
     "","</td>","<td width='10.625%'"," class='FieldName0244' colspan='2'>","",
     "</td>","<td width='24.375%'"," class='FieldName0245' colspan='4'>","","</td>",
     "</tr>"), _htmlfilestat = uar_fwrite(_vcwriteln,1,textlen(_vcwriteln),_htmlfilehandle),
    orgtotaldefic = org_def_cnt,
    total_def_cnt = (total_def_cnt+ org_def_cnt), total_chart_cnt = (total_chart_cnt+ org_chart_cnt),
    _vcwriteln = build2("<tr>","<td width='20.000%'"," class='FieldName0250' colspan='4'>",
     IF (i1multifacilitylogicind) build2(uar_i18ngetmessage(i18nhandlehim,"TOTALFORORG","Total for "),
       trim(organization_name,3),": ")
     ELSE build2(uar_i18ngetmessage(i18nhandlehim,"TOTAL","Total:"))
     ENDIF
     ,"</td>",
     "<td width='16.875%'"," class='FieldName0250' colspan='5'>","","</td>","<td width='12.500%'",
     " class='FieldName0252' colspan='3'>",uar_i18ngetmessage(_hi18nhandle,
      "HIM_MAK_DEFIC_BY_PHYS_DET_LYT_CellName21","Total Deficiencies:"),"</td>",
     "<td width='15.625%'"," class='FieldName0231' colspan='2'>",
     orgtotaldefic,"</td>","<td width='10.625%'"," class='FieldName0232' colspan='2'>",
     uar_i18ngetmessage(_hi18nhandle,"HIM_MAK_DEFIC_BY_PHYS_DET_LYT_CellName89","Total Charts:"),
     "</td>","<td width='14.375%'"," class='FieldName0255' colspan='3'>",org_chart_cnt,"</td>",
     "<td width='10.000%'"," class='FieldName0256' colspan='1'>","","</td>","</tr>"),
    _htmlfilestat = uar_fwrite(_vcwriteln,1,textlen(_vcwriteln),_htmlfilehandle)
   FOOT REPORT
    _vcwriteln = "</tbody><tfoot>", _htmlfilestat = uar_fwrite(_vcwriteln,1,textlen(_vcwriteln),
     _htmlfilehandle), _vcwriteln = "</tfoot>",
    _htmlfilestat = uar_fwrite(_vcwriteln,1,textlen(_vcwriteln),_htmlfilehandle), _vcwriteln = build2
    ("<tr>","<td width='100.000%'"," class='FieldName0260' colspan='20'>","","</td>",
     "</tr>"), _htmlfilestat = uar_fwrite(_vcwriteln,1,textlen(_vcwriteln),_htmlfilehandle)
    IF (i1multifacilitylogicind)
     _vcwriteln = build2("<tr>","<td width='36.875%'"," class='FieldName0270' colspan='9'>",
      uar_i18ngetmessage(_hi18nhandle,"HIM_MAK_DEFIC_BY_PHYS_DET_LYT_organizationTotal0",
       "Grand Total For Facilities:"),"</td>",
      "<td width='12.500%'"," class='FieldName0271' colspan='3'>",uar_i18ngetmessage(_hi18nhandle,
       "HIM_MAK_DEFIC_BY_PHYS_DET_LYT_CellName94","Total Deficiencies:"),"</td>",
      "<td width='15.625%'",
      " class='FieldName0272' colspan='2'>",total_def_cnt,"</td>","<td width='10.625%'",
      " class='FieldName0273' colspan='2'>",
      uar_i18ngetmessage(_hi18nhandle,"HIM_MAK_DEFIC_BY_PHYS_DET_LYT_CellName101","Total Charts:"),
      "</td>","<td width='14.375%'"," class='FieldName0274' colspan='3'>",total_chart_cnt,
      "</td>","<td width='10.000%'"," class='FieldName0272' colspan='1'>","","</td>",
      "</tr>"), _htmlfilestat = uar_fwrite(_vcwriteln,1,textlen(_vcwriteln),_htmlfilehandle)
    ENDIF
    IF ( NOT (i1multifacilitylogicind))
     _vcwriteln = build2("<tr>","<td width='100.000%'"," class='FieldName0280' colspan='20'>","",
      "</td>",
      "</tr>"), _htmlfilestat = uar_fwrite(_vcwriteln,1,textlen(_vcwriteln),_htmlfilehandle)
    ENDIF
    _vcwriteln = build2("<tr>","<td width='100.000%'"," class='FieldName0290' colspan='20'>",
     uar_i18ngetmessage(_hi18nhandle,"HIM_MAK_DEFIC_BY_PHYS_DET_LYT_CellName44","**END OF REPORT**"),
     "</td>",
     "</tr>"), _htmlfilestat = uar_fwrite(_vcwriteln,1,textlen(_vcwriteln),_htmlfilehandle),
    _vcwriteln = "</table>",
    _htmlfilestat = uar_fwrite(_vcwriteln,1,textlen(_vcwriteln),_htmlfilehandle)
   WITH nullreport, nocounter, memsort
  ;end select
 END ;Subroutine
 SUBROUTINE sectionabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(7.500000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   IF (ncalc=rpt_calcheight)
    RETURN(sectionheight)
   ENDIF
   SET _oldpen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET _yoffset = (offsety+ 0.000)
   SET _fholdoffsety = (_yoffset - offsety)
   SELECT
    patient_id = data->qual[d.seq].patient_id, patient_name = substring(1,100,data->qual[d.seq].
     patient_name), alpha_patient_name = substring(1,100,cnvtupper(data->qual[d.seq].patient_name)),
    patient_type_cd = data->qual[d.seq].patient_type_cd, organization_name = substring(1,100,data->
     qual[d.seq].organization_name), organization_id = data->qual[d.seq].organization_id,
    mrn = substring(1,100,data->qual[d.seq].mrn), fin = substring(1,100,data->qual[d.seq].fin),
    encntr_id = data->qual[d.seq].encntr_id,
    physician_name = substring(1,100,data->qual[d.seq].physician_name), physician_id = data->qual[d
    .seq].physician_id, location = substring(1,100,data->qual[d.seq].location),
    disch_dt_tm = data->qual[d.seq].disch_dt_tm, sort_disch_dt_tm =
    IF ((data->qual[d.seq].disch_dt_tm != null)) data->qual[d.seq].disch_dt_tm
    ELSE cnvtdatetime("31-DEC-2100 00:00:00.00")
    ENDIF
    , chart_age = data->qual[d.seq].chart_age,
    deficiency_name = substring(1,100,build(data->qual[d.seq].defic_qual[ddefic.seq].deficiency_name)
     ), deficiency_age = data->qual[d.seq].defic_qual[ddefic.seq].defic_age, deficiency_status =
    substring(1,30,build(data->qual[d.seq].defic_qual[ddefic.seq].status)),
    physician_active_ind = data->qual[d.seq].physician_active_ind, physician_active_status_cd = data
    ->qual[d.seq].physician_active_status_cd, physician_active_status_dt_tm = data->qual[d.seq].
    physician_active_status_dt_tm,
    physician_active_status_prsnl_id = data->qual[d.seq].physician_active_status_prsnl_id,
    physician_beg_effective_dt_tm = data->qual[d.seq].physician_beg_effective_dt_tm,
    physician_contributor_system_cd = data->qual[d.seq].physician_contributor_system_cd,
    physician_create_dt_tm = data->qual[d.seq].physician_create_dt_tm, physician_create_prsnl_id =
    data->qual[d.seq].physician_create_prsnl_id, physician_data_status_cd = data->qual[d.seq].
    physician_data_status_cd,
    physician_data_status_dt_tm = data->qual[d.seq].physician_data_status_dt_tm,
    physician_data_status_prsnl_id = data->qual[d.seq].physician_data_status_prsnl_id,
    physician_email = substring(1,100,data->qual[d.seq].physician_email),
    physician_end_effective_dt_tm = data->qual[d.seq].physician_end_effective_dt_tm,
    physician_ft_entity_id = data->qual[d.seq].physician_ft_entity_id, physician_ft_entity_name =
    substring(1,32,data->qual[d.seq].physician_ft_entity_name),
    physician_name_first = substring(1,200,data->qual[d.seq].physician_name_first),
    physician_name_first_key = substring(1,100,data->qual[d.seq].physician_name_first_key),
    physician_name_first_key_nls = substring(1,202,data->qual[d.seq].physician_name_first_key_nls),
    physician_name_full_formatted = substring(1,100,data->qual[d.seq].physician_name_full_formatted),
    physician_name_last = substring(1,200,data->qual[d.seq].physician_name_last),
    physician_name_last_key = substring(1,100,data->qual[d.seq].physician_name_last_key),
    physician_name_last_key_nls = substring(1,202,data->qual[d.seq].physician_name_last_key_nls),
    physician_password = substring(1,100,data->qual[d.seq].physician_password), physician_person_id
     = data->qual[d.seq].physician_person_id,
    physician_physician_ind = data->qual[d.seq].physician_physician_ind,
    physician_physician_status_cd = data->qual[d.seq].physician_physician_status_cd,
    physician_position_cd = data->qual[d.seq].physician_position_cd,
    physician_prim_assign_loc_cd = data->qual[d.seq].physician_prim_assign_loc_cd,
    physician_prsnl_type_cd = data->qual[d.seq].physician_prsnl_type_cd, physician_updt_dt_tm = data
    ->qual[d.seq].physician_updt_dt_tm,
    physician_updt_id = data->qual[d.seq].physician_updt_id, physician_updt_task = data->qual[d.seq].
    physician_updt_task, physician_username = substring(1,50,data->qual[d.seq].physician_username),
    patient_abs_birth_dt_tm = data->qual[d.seq].patient_abs_birth_dt_tm, patient_active_ind = data->
    qual[d.seq].patient_active_ind, patient_active_status_cd = data->qual[d.seq].
    patient_active_status_cd,
    patient_active_status_dt_tm = data->qual[d.seq].patient_active_status_dt_tm,
    patient_active_status_prsnl_id = data->qual[d.seq].patient_active_status_prsnl_id,
    patient_archive_env_id = data->qual[d.seq].patient_archive_env_id,
    patient_archive_status_cd = data->qual[d.seq].patient_archive_status_cd,
    patient_archive_status_dt_tm = data->qual[d.seq].patient_archive_status_dt_tm, patient_autopsy_cd
     = data->qual[d.seq].patient_autopsy_cd,
    patient_beg_effective_dt_tm = data->qual[d.seq].patient_beg_effective_dt_tm, patient_birth_dt_cd
     = data->qual[d.seq].patient_birth_dt_cd, patient_birth_dt_tm = data->qual[d.seq].
    patient_birth_dt_tm,
    patient_birth_prec_flag = data->qual[d.seq].patient_birth_prec_flag, patient_birth_tz = data->
    qual[d.seq].patient_birth_tz, patient_cause_of_death = substring(1,100,data->qual[d.seq].
     patient_cause_of_death),
    patient_cause_of_death_cd = data->qual[d.seq].patient_cause_of_death_cd, patient_citizenship_cd
     = data->qual[d.seq].patient_citizenship_cd, patient_conception_dt_tm = data->qual[d.seq].
    patient_conception_dt_tm,
    patient_confid_level_cd = data->qual[d.seq].patient_confid_level_cd,
    patient_contributor_system_cd = data->qual[d.seq].patient_contributor_system_cd,
    patient_create_dt_tm = data->qual[d.seq].patient_create_dt_tm,
    patient_create_prsnl_id = data->qual[d.seq].patient_create_prsnl_id, patient_data_status_cd =
    data->qual[d.seq].patient_data_status_cd, patient_data_status_dt_tm = data->qual[d.seq].
    patient_data_status_dt_tm,
    patient_data_status_prsnl_id = data->qual[d.seq].patient_data_status_prsnl_id,
    patient_deceased_cd = data->qual[d.seq].patient_deceased_cd, patient_deceased_dt_tm = data->qual[
    d.seq].patient_deceased_dt_tm,
    patient_deceased_source_cd = data->qual[d.seq].patient_deceased_source_cd,
    patient_end_effective_dt_tm = data->qual[d.seq].patient_end_effective_dt_tm,
    patient_ethnic_grp_cd = data->qual[d.seq].patient_ethnic_grp_cd,
    patient_ft_entity_id = data->qual[d.seq].patient_ft_entity_id, patient_ft_entity_name = substring
    (1,32,data->qual[d.seq].patient_ft_entity_name), patient_language_cd = data->qual[d.seq].
    patient_language_cd,
    patient_language_dialect_cd = data->qual[d.seq].patient_language_dialect_cd,
    patient_last_accessed_dt_tm = data->qual[d.seq].patient_last_accessed_dt_tm,
    patient_last_encntr_dt_tm = data->qual[d.seq].patient_last_encntr_dt_tm,
    patient_marital_type_cd = data->qual[d.seq].patient_marital_type_cd,
    patient_military_base_location = substring(1,100,data->qual[d.seq].patient_military_base_location
     ), patient_military_rank_cd = data->qual[d.seq].patient_military_rank_cd,
    patient_military_service_cd = data->qual[d.seq].patient_military_service_cd,
    patient_mother_maiden_name = substring(1,100,data->qual[d.seq].patient_mother_maiden_name),
    patient_name_first = substring(1,200,data->qual[d.seq].patient_name_first),
    patient_name_first_key = substring(1,100,data->qual[d.seq].patient_name_first_key),
    patient_name_first_key_nls = substring(1,202,data->qual[d.seq].patient_name_first_key_nls),
    patient_name_first_phonetic = substring(1,8,data->qual[d.seq].patient_name_first_phonetic),
    patient_name_first_synonym_id = data->qual[d.seq].patient_name_first_synonym_id,
    patient_name_full_formatted = substring(1,100,data->qual[d.seq].patient_name_full_formatted),
    patient_name_last = substring(1,200,data->qual[d.seq].patient_name_last),
    patient_name_last_key = substring(1,100,data->qual[d.seq].patient_name_last_key),
    patient_name_last_key_nls = substring(1,202,data->qual[d.seq].patient_name_last_key_nls),
    patient_name_last_phonetic = substring(1,8,data->qual[d.seq].patient_name_last_phonetic),
    patient_name_middle = substring(1,200,data->qual[d.seq].patient_name_middle),
    patient_name_middle_key = substring(1,100,data->qual[d.seq].patient_name_middle_key),
    patient_name_middle_key_nls = substring(1,202,data->qual[d.seq].patient_name_middle_key_nls),
    patient_name_phonetic = substring(1,8,data->qual[d.seq].patient_name_phonetic),
    patient_nationality_cd = data->qual[d.seq].patient_nationality_cd, patient_next_restore_dt_tm =
    data->qual[d.seq].patient_next_restore_dt_tm,
    patient_person_id = data->qual[d.seq].patient_person_id, patient_person_type_cd = data->qual[d
    .seq].patient_person_type_cd, patient_race_cd = data->qual[d.seq].patient_race_cd,
    patient_religion_cd = data->qual[d.seq].patient_religion_cd, patient_sex_age_change_ind = data->
    qual[d.seq].patient_sex_age_change_ind, patient_sex_cd = data->qual[d.seq].patient_sex_cd,
    patient_species_cd = data->qual[d.seq].patient_species_cd, patient_updt_dt_tm = data->qual[d.seq]
    .patient_updt_dt_tm, patient_updt_id = data->qual[d.seq].patient_updt_id,
    patient_updt_task = data->qual[d.seq].patient_updt_task, patient_vet_military_status_cd = data->
    qual[d.seq].patient_vet_military_status_cd, patient_vip_cd = data->qual[d.seq].patient_vip_cd,
    encntr_accommodation_cd = data->qual[d.seq].encntr_accommodation_cd,
    encntr_accommodation_reason_cd = data->qual[d.seq].encntr_accommodation_reason_cd,
    encntr_accommodation_request_cd = data->qual[d.seq].encntr_accommodation_request_cd,
    encntr_accomp_by_cd = data->qual[d.seq].encntr_accomp_by_cd, encntr_active_ind = data->qual[d.seq
    ].encntr_active_ind, encntr_active_status_cd = data->qual[d.seq].encntr_active_status_cd,
    encntr_active_status_dt_tm = data->qual[d.seq].encntr_active_status_dt_tm,
    encntr_active_status_prsnl_id = data->qual[d.seq].encntr_active_status_prsnl_id,
    encntr_admit_mode_cd = data->qual[d.seq].encntr_admit_mode_cd,
    encntr_admit_src_cd = data->qual[d.seq].encntr_admit_src_cd, encntr_admit_type_cd = data->qual[d
    .seq].encntr_admit_type_cd, encntr_admit_with_medication_cd = data->qual[d.seq].
    encntr_admit_with_medication_cd,
    encntr_alc_decomp_dt_tm = data->qual[d.seq].encntr_alc_decomp_dt_tm, encntr_alc_reason_cd = data
    ->qual[d.seq].encntr_alc_reason_cd, encntr_alt_lvl_care_cd = data->qual[d.seq].
    encntr_alt_lvl_care_cd,
    encntr_alt_lvl_care_dt_tm = data->qual[d.seq].encntr_alt_lvl_care_dt_tm,
    encntr_ambulatory_cond_cd = data->qual[d.seq].encntr_ambulatory_cond_cd, encntr_archive_dt_tm_act
     = data->qual[d.seq].encntr_archive_dt_tm_act,
    encntr_archive_dt_tm_est = data->qual[d.seq].encntr_archive_dt_tm_est, encntr_arrive_dt_tm = data
    ->qual[d.seq].encntr_arrive_dt_tm, encntr_assign_to_loc_dt_tm = data->qual[d.seq].
    encntr_assign_to_loc_dt_tm,
    encntr_bbd_procedure_cd = data->qual[d.seq].encntr_bbd_procedure_cd, encntr_beg_effective_dt_tm
     = data->qual[d.seq].encntr_beg_effective_dt_tm, encntr_chart_complete_dt_tm = data->qual[d.seq].
    encntr_chart_complete_dt_tm,
    encntr_confid_level_cd = data->qual[d.seq].encntr_confid_level_cd, encntr_contract_status_cd =
    data->qual[d.seq].encntr_contract_status_cd, encntr_contributor_system_cd = data->qual[d.seq].
    encntr_contributor_system_cd,
    encntr_courtesy_cd = data->qual[d.seq].encntr_courtesy_cd, encntr_create_dt_tm = data->qual[d.seq
    ].encntr_create_dt_tm, encntr_create_prsnl_id = data->qual[d.seq].encntr_create_prsnl_id,
    encntr_data_status_cd = data->qual[d.seq].encntr_data_status_cd, encntr_data_status_dt_tm = data
    ->qual[d.seq].encntr_data_status_dt_tm, encntr_data_status_prsnl_id = data->qual[d.seq].
    encntr_data_status_prsnl_id,
    encntr_depart_dt_tm = data->qual[d.seq].encntr_depart_dt_tm, encntr_diet_type_cd = data->qual[d
    .seq].encntr_diet_type_cd, encntr_disch_disposition_cd = data->qual[d.seq].
    encntr_disch_disposition_cd,
    encntr_disch_dt_tm = data->qual[d.seq].encntr_disch_dt_tm, encntr_disch_to_loctn_cd = data->qual[
    d.seq].encntr_disch_to_loctn_cd, encntr_doc_rcvd_dt_tm = data->qual[d.seq].encntr_doc_rcvd_dt_tm,
    encntr_encntr_class_cd = data->qual[d.seq].encntr_encntr_class_cd, encntr_encntr_complete_dt_tm
     = data->qual[d.seq].encntr_encntr_complete_dt_tm, encntr_encntr_financial_id = data->qual[d.seq]
    .encntr_encntr_financial_id,
    encntr_encntr_id = data->qual[d.seq].encntr_encntr_id, encntr_encntr_status_cd = data->qual[d.seq
    ].encntr_encntr_status_cd, encntr_encntr_type_cd = data->qual[d.seq].encntr_encntr_type_cd,
    encntr_encntr_type_class_cd = data->qual[d.seq].encntr_encntr_type_class_cd,
    encntr_end_effective_dt_tm = data->qual[d.seq].encntr_end_effective_dt_tm,
    encntr_est_arrive_dt_tm = data->qual[d.seq].encntr_est_arrive_dt_tm,
    encntr_est_depart_dt_tm = data->qual[d.seq].encntr_est_depart_dt_tm, encntr_est_length_of_stay =
    data->qual[d.seq].encntr_est_length_of_stay, encntr_financial_class_cd = data->qual[d.seq].
    encntr_financial_class_cd,
    encntr_guarantor_type_cd = data->qual[d.seq].encntr_guarantor_type_cd, encntr_info_given_by =
    substring(1,100,data->qual[d.seq].encntr_info_given_by), encntr_inpatient_admit_dt_tm = data->
    qual[d.seq].encntr_inpatient_admit_dt_tm,
    encntr_isolation_cd = data->qual[d.seq].encntr_isolation_cd, encntr_location_cd = data->qual[d
    .seq].encntr_location_cd, encntr_loc_bed_cd = data->qual[d.seq].encntr_loc_bed_cd,
    encntr_loc_building_cd = data->qual[d.seq].encntr_loc_building_cd, encntr_loc_facility_cd = data
    ->qual[d.seq].encntr_loc_facility_cd, encntr_loc_nurse_unit_cd = data->qual[d.seq].
    encntr_loc_nurse_unit_cd,
    encntr_loc_room_cd = data->qual[d.seq].encntr_loc_room_cd, encntr_loc_temp_cd = data->qual[d.seq]
    .encntr_loc_temp_cd, encntr_med_service_cd = data->qual[d.seq].encntr_med_service_cd,
    encntr_mental_category_cd = data->qual[d.seq].encntr_mental_category_cd,
    encntr_mental_health_dt_tm = data->qual[d.seq].encntr_mental_health_dt_tm, encntr_organization_id
     = data->qual[d.seq].encntr_organization_id,
    encntr_parent_ret_criteria_id = data->qual[d.seq].encntr_parent_ret_criteria_id,
    encntr_patient_classification_cd = data->qual[d.seq].encntr_patient_classification_cd,
    encntr_pa_current_status_cd = data->qual[d.seq].encntr_pa_current_status_cd,
    encntr_pa_current_status_dt_tm = data->qual[d.seq].encntr_pa_current_status_dt_tm,
    encntr_person_id = data->qual[d.seq].encntr_person_id, encntr_placement_auth_prsnl_id = data->
    qual[d.seq].encntr_placement_auth_prsnl_id,
    encntr_preadmit_testing_cd = data->qual[d.seq].encntr_preadmit_testing_cd, encntr_pre_reg_dt_tm
     = data->qual[d.seq].encntr_pre_reg_dt_tm, encntr_pre_reg_prsnl_id = data->qual[d.seq].
    encntr_pre_reg_prsnl_id,
    encntr_program_service_cd = data->qual[d.seq].encntr_program_service_cd,
    encntr_psychiatric_status_cd = data->qual[d.seq].encntr_psychiatric_status_cd,
    encntr_purge_dt_tm_act = data->qual[d.seq].encntr_purge_dt_tm_act,
    encntr_purge_dt_tm_est = data->qual[d.seq].encntr_purge_dt_tm_est, encntr_readmit_cd = data->
    qual[d.seq].encntr_readmit_cd, encntr_reason_for_visit = substring(1,255,data->qual[d.seq].
     encntr_reason_for_visit),
    encntr_referral_rcvd_dt_tm = data->qual[d.seq].encntr_referral_rcvd_dt_tm,
    encntr_referring_comment = substring(1,100,data->qual[d.seq].encntr_referring_comment),
    encntr_refer_facility_cd = data->qual[d.seq].encntr_refer_facility_cd,
    encntr_region_cd = data->qual[d.seq].encntr_region_cd, encntr_reg_dt_tm = data->qual[d.seq].
    encntr_reg_dt_tm, encntr_reg_prsnl_id = data->qual[d.seq].encntr_reg_prsnl_id,
    encntr_result_accumulation_dt_tm = data->qual[d.seq].encntr_result_accumulation_dt_tm,
    encntr_safekeeping_cd = data->qual[d.seq].encntr_safekeeping_cd, encntr_security_access_cd = data
    ->qual[d.seq].encntr_security_access_cd,
    encntr_service_category_cd = data->qual[d.seq].encntr_service_category_cd,
    encntr_sitter_required_cd = data->qual[d.seq].encntr_sitter_required_cd, encntr_specialty_unit_cd
     = data->qual[d.seq].encntr_specialty_unit_cd,
    encntr_trauma_cd = data->qual[d.seq].encntr_trauma_cd, encntr_trauma_dt_tm = data->qual[d.seq].
    encntr_trauma_dt_tm, encntr_triage_cd = data->qual[d.seq].encntr_triage_cd,
    encntr_triage_dt_tm = data->qual[d.seq].encntr_triage_dt_tm, encntr_updt_dt_tm = data->qual[d.seq
    ].encntr_updt_dt_tm, encntr_updt_id = data->qual[d.seq].encntr_updt_id,
    encntr_updt_task = data->qual[d.seq].encntr_updt_task, encntr_valuables_cd = data->qual[d.seq].
    encntr_valuables_cd, encntr_vip_cd = data->qual[d.seq].encntr_vip_cd,
    encntr_visitor_status_cd = data->qual[d.seq].encntr_visitor_status_cd, encntr_zero_balance_dt_tm
     = data->qual[d.seq].encntr_zero_balance_dt_tm, encntr_mrn_active_ind = data->qual[d.seq].
    encntr_mrn_active_ind,
    encntr_mrn_active_status_cd = data->qual[d.seq].encntr_mrn_active_status_cd,
    encntr_mrn_active_status_dt_tm = data->qual[d.seq].encntr_mrn_active_status_dt_tm,
    encntr_mrn_active_status_prsnl_id = data->qual[d.seq].encntr_mrn_active_status_prsnl_id,
    encntr_mrn_alias = substring(1,200,data->qual[d.seq].encntr_mrn_alias), encntr_mrn_alias_pool_cd
     = data->qual[d.seq].encntr_mrn_alias_pool_cd, encntr_mrn_assign_authority_sys_cd = data->qual[d
    .seq].encntr_mrn_assign_authority_sys_cd,
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
    data->qual[d.seq].encntr_mrn_end_effective_dt_tm, encntr_mrn_updt_dt_tm = data->qual[d.seq].
    encntr_mrn_updt_dt_tm,
    encntr_mrn_updt_id = data->qual[d.seq].encntr_mrn_updt_id, encntr_mrn_updt_task = data->qual[d
    .seq].encntr_mrn_updt_task, encntr_fin_active_ind = data->qual[d.seq].encntr_fin_active_ind,
    encntr_fin_active_status_cd = data->qual[d.seq].encntr_fin_active_status_cd,
    encntr_fin_active_status_dt_tm = data->qual[d.seq].encntr_fin_active_status_dt_tm,
    encntr_fin_active_status_prsnl_id = data->qual[d.seq].encntr_fin_active_status_prsnl_id,
    encntr_fin_alias = substring(1,200,data->qual[d.seq].encntr_fin_alias), encntr_fin_alias_pool_cd
     = data->qual[d.seq].encntr_fin_alias_pool_cd, encntr_fin_assign_authority_sys_cd = data->qual[d
    .seq].encntr_fin_assign_authority_sys_cd,
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
    data->qual[d.seq].encntr_fin_end_effective_dt_tm, encntr_fin_updt_dt_tm = data->qual[d.seq].
    encntr_fin_updt_dt_tm,
    encntr_fin_updt_id = data->qual[d.seq].encntr_fin_updt_id, encntr_fin_updt_task = data->qual[d
    .seq].encntr_fin_updt_task, org_active_ind = data->qual[d.seq].org_active_ind,
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
    org_updt_task = data->qual[d.seq].org_updt_task, him_visit_abstract_complete_ind = data->qual[d
    .seq].him_visit_abstract_complete_ind, him_visit_active_ind = data->qual[d.seq].
    him_visit_active_ind,
    him_visit_active_status_cd = data->qual[d.seq].him_visit_active_status_cd,
    him_visit_active_status_dt_tm = data->qual[d.seq].him_visit_active_status_dt_tm,
    him_visit_active_status_prsnl_id = data->qual[d.seq].him_visit_active_status_prsnl_id,
    him_visit_allocation_dt_flag = data->qual[d.seq].him_visit_allocation_dt_flag,
    him_visit_allocation_dt_modifier = data->qual[d.seq].him_visit_allocation_dt_modifier,
    him_visit_allocation_dt_tm = data->qual[d.seq].him_visit_allocation_dt_tm,
    him_visit_beg_effective_dt_tm = data->qual[d.seq].him_visit_beg_effective_dt_tm,
    him_visit_chart_process_id = data->qual[d.seq].him_visit_chart_process_id,
    him_visit_chart_status_cd = data->qual[d.seq].him_visit_chart_status_cd,
    him_visit_chart_status_dt_tm = data->qual[d.seq].him_visit_chart_status_dt_tm,
    him_visit_encntr_id = data->qual[d.seq].him_visit_encntr_id, him_visit_end_effective_dt_tm = data
    ->qual[d.seq].him_visit_end_effective_dt_tm,
    him_visit_person_id = data->qual[d.seq].him_visit_person_id, him_visit_updt_dt_tm = data->qual[d
    .seq].him_visit_updt_dt_tm, him_visit_updt_id = data->qual[d.seq].him_visit_updt_id,
    him_visit_updt_task = data->qual[d.seq].him_visit_updt_task, order_notif_action_sequence =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].order_notif_action_sequence)
    ELSE ""
    ENDIF
    , order_notif_caused_by_flag =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].order_notif_caused_by_flag)
    ELSE ""
    ENDIF
    ,
    order_notif_from_prsnl_id =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].order_notif_from_prsnl_id)
    ELSE ""
    ENDIF
    , order_notif_notification_comment =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) substring(1,255,data->qual[d
      .seq].defic_qual[ddefic.seq].order_qual[1].order_notif_notification_comment)
    ELSE ""
    ENDIF
    , order_notif_notification_dt_tm =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].order_notif_notification_dt_tm)
    ELSE ""
    ENDIF
    ,
    order_notif_notification_reason_cd =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].order_notif_notification_reason_cd)
    ELSE ""
    ENDIF
    , order_notif_notification_status_flag =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].order_notif_notification_status_flag)
    ELSE ""
    ENDIF
    , order_notif_notification_type_flag =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].order_notif_notification_type_flag)
    ELSE ""
    ENDIF
    ,
    order_notif_notification_tz =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].order_notif_notification_tz)
    ELSE ""
    ENDIF
    , order_notif_order_id =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].order_notif_order_id)
    ELSE ""
    ENDIF
    , order_notif_order_notification_id =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].order_notif_order_notification_id)
    ELSE ""
    ENDIF
    ,
    order_notif_parent_order_notification_id =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].order_notif_parent_order_notification_id)
    ELSE ""
    ENDIF
    , order_notif_status_change_dt_tm =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].order_notif_status_change_dt_tm)
    ELSE ""
    ENDIF
    , order_notif_status_change_tz =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].order_notif_status_change_tz)
    ELSE ""
    ENDIF
    ,
    order_notif_to_prsnl_id =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].order_notif_to_prsnl_id)
    ELSE ""
    ENDIF
    , order_notif_updt_dt_tm =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].order_notif_updt_dt_tm)
    ELSE ""
    ENDIF
    , order_notif_updt_id =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].order_notif_updt_id)
    ELSE ""
    ENDIF
    ,
    order_notif_updt_task =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].order_notif_updt_task)
    ELSE ""
    ENDIF
    , order_review_action_sequence =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].order_review_action_sequence)
    ELSE ""
    ENDIF
    , order_review_dept_cd =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].order_review_dept_cd)
    ELSE ""
    ENDIF
    ,
    order_review_digital_signature_ident =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) substring(1,64,data->qual[d.seq
      ].defic_qual[ddefic.seq].order_qual[1].order_review_digital_signature_ident)
    ELSE ""
    ENDIF
    , order_review_location_cd =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].order_review_location_cd)
    ELSE ""
    ENDIF
    , order_review_order_id =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].order_review_order_id)
    ELSE ""
    ENDIF
    ,
    order_review_provider_id =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].order_review_provider_id)
    ELSE ""
    ENDIF
    , order_review_proxy_personnel_id =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].order_review_proxy_personnel_id)
    ELSE ""
    ENDIF
    , order_review_proxy_reason_cd =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].order_review_proxy_reason_cd)
    ELSE ""
    ENDIF
    ,
    order_review_reject_reason_cd =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].order_review_reject_reason_cd)
    ELSE ""
    ENDIF
    , order_review_reviewed_status_flag =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].order_review_reviewed_status_flag)
    ELSE ""
    ENDIF
    , order_review_review_dt_tm =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].order_review_review_dt_tm)
    ELSE ""
    ENDIF
    ,
    order_review_review_personnel_id =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].order_review_review_personnel_id)
    ELSE ""
    ENDIF
    , order_review_review_reqd_ind =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].order_review_review_reqd_ind)
    ELSE ""
    ENDIF
    , order_review_review_sequence =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].order_review_review_sequence)
    ELSE ""
    ENDIF
    ,
    order_review_review_type_flag =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].order_review_review_type_flag)
    ELSE ""
    ENDIF
    , order_review_review_tz =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].order_review_review_tz)
    ELSE ""
    ENDIF
    , order_review_updt_dt_tm =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].order_review_updt_dt_tm)
    ELSE ""
    ENDIF
    ,
    order_review_updt_id =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].order_review_updt_id)
    ELSE ""
    ENDIF
    , order_review_updt_task =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].order_review_updt_task)
    ELSE ""
    ENDIF
    , orders_active_ind =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_active_ind)
    ELSE ""
    ENDIF
    ,
    orders_active_status_cd =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_active_status_cd)
    ELSE ""
    ENDIF
    , orders_active_status_dt_tm =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_active_status_dt_tm)
    ELSE ""
    ENDIF
    , orders_active_status_prsnl_id =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_active_status_prsnl_id)
    ELSE ""
    ENDIF
    ,
    orders_activity_type_cd =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_activity_type_cd)
    ELSE ""
    ENDIF
    , orders_ad_hoc_order_flag =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_ad_hoc_order_flag)
    ELSE ""
    ENDIF
    , orders_catalog_cd =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_catalog_cd)
    ELSE ""
    ENDIF
    ,
    orders_catalog_type_cd =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_catalog_type_cd)
    ELSE ""
    ENDIF
    , orders_cki =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) substring(1,255,data->qual[d
      .seq].defic_qual[ddefic.seq].order_qual[1].orders_cki)
    ELSE ""
    ENDIF
    , orders_clinical_display_line =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) substring(1,255,data->qual[d
      .seq].defic_qual[ddefic.seq].order_qual[1].orders_clinical_display_line)
    ELSE ""
    ENDIF
    ,
    orders_comment_type_mask =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_comment_type_mask)
    ELSE ""
    ENDIF
    , orders_constant_ind =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_constant_ind)
    ELSE ""
    ENDIF
    , orders_contributor_system_cd =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_contributor_system_cd)
    ELSE ""
    ENDIF
    ,
    orders_cs_flag =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_cs_flag)
    ELSE ""
    ENDIF
    , orders_cs_order_id =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_cs_order_id)
    ELSE ""
    ENDIF
    , orders_current_start_dt_tm =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_current_start_dt_tm)
    ELSE ""
    ENDIF
    ,
    orders_current_start_tz =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_current_start_tz)
    ELSE ""
    ENDIF
    , orders_dcp_clin_cat_cd =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_dcp_clin_cat_cd)
    ELSE ""
    ENDIF
    , orders_dept_misc_line =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) substring(1,255,data->qual[d
      .seq].defic_qual[ddefic.seq].order_qual[1].orders_dept_misc_line)
    ELSE ""
    ENDIF
    ,
    orders_dept_status_cd =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_dept_status_cd)
    ELSE ""
    ENDIF
    , orders_discontinue_effective_dt_tm =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_discontinue_effective_dt_tm)
    ELSE ""
    ENDIF
    , orders_discontinue_effective_tz =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_discontinue_effective_tz)
    ELSE ""
    ENDIF
    ,
    orders_discontinue_ind =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_discontinue_ind)
    ELSE ""
    ENDIF
    , orders_discontinue_type_cd =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_discontinue_type_cd)
    ELSE ""
    ENDIF
    , orders_encntr_financial_id =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_encntr_financial_id)
    ELSE ""
    ENDIF
    ,
    orders_encntr_id =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_encntr_id)
    ELSE ""
    ENDIF
    , orders_eso_new_order_ind =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_eso_new_order_ind)
    ELSE ""
    ENDIF
    , orders_frequency_id =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_frequency_id)
    ELSE ""
    ENDIF
    ,
    orders_freq_type_flag =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_freq_type_flag)
    ELSE ""
    ENDIF
    , orders_group_order_flag =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_group_order_flag)
    ELSE ""
    ENDIF
    , orders_group_order_id =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_group_order_id)
    ELSE ""
    ENDIF
    ,
    orders_hide_flag =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_hide_flag)
    ELSE ""
    ENDIF
    , orders_hna_order_mnemonic =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) substring(1,100,data->qual[d
      .seq].defic_qual[ddefic.seq].order_qual[1].orders_hna_order_mnemonic)
    ELSE ""
    ENDIF
    , orders_incomplete_order_ind =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_incomplete_order_ind)
    ELSE ""
    ENDIF
    ,
    orders_ingredient_ind =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_ingredient_ind)
    ELSE ""
    ENDIF
    , orders_interest_dt_tm =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_interest_dt_tm)
    ELSE ""
    ENDIF
    , orders_interval_ind =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_interval_ind)
    ELSE ""
    ENDIF
    ,
    orders_iv_ind =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_iv_ind)
    ELSE ""
    ENDIF
    , orders_last_action_sequence =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_last_action_sequence)
    ELSE ""
    ENDIF
    , orders_last_core_action_sequence =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_last_core_action_sequence)
    ELSE ""
    ENDIF
    ,
    orders_last_ingred_action_sequence =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_last_ingred_action_sequence)
    ELSE ""
    ENDIF
    , orders_last_update_provider_id =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_last_update_provider_id)
    ELSE ""
    ENDIF
    , orders_link_nbr =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_link_nbr)
    ELSE ""
    ENDIF
    ,
    orders_link_order_flag =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_link_order_flag)
    ELSE ""
    ENDIF
    , orders_link_order_id =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_link_order_id)
    ELSE ""
    ENDIF
    , orders_link_type_flag =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_link_type_flag)
    ELSE ""
    ENDIF
    ,
    orders_med_order_type_cd =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_med_order_type_cd)
    ELSE ""
    ENDIF
    , orders_modified_start_dt_tm =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_modified_start_dt_tm)
    ELSE ""
    ENDIF
    , orders_need_doctor_cosign_ind =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_need_doctor_cosign_ind)
    ELSE ""
    ENDIF
    ,
    orders_need_nurse_review_ind =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_need_nurse_review_ind)
    ELSE ""
    ENDIF
    , orders_need_physician_validate_ind =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_need_physician_validate_ind)
    ELSE ""
    ENDIF
    , orders_need_rx_verify_ind =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_need_rx_verify_ind)
    ELSE ""
    ENDIF
    ,
    orders_oe_format_id =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_oe_format_id)
    ELSE ""
    ENDIF
    , orders_orderable_type_flag =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_orderable_type_flag)
    ELSE ""
    ENDIF
    , orders_ordered_as_mnemonic =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) substring(1,100,data->qual[d
      .seq].defic_qual[ddefic.seq].order_qual[1].orders_ordered_as_mnemonic)
    ELSE ""
    ENDIF
    ,
    orders_order_comment_ind =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_order_comment_ind)
    ELSE ""
    ENDIF
    , orders_order_detail_display_line =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) substring(1,255,data->qual[d
      .seq].defic_qual[ddefic.seq].order_qual[1].orders_order_detail_display_line)
    ELSE ""
    ENDIF
    , orders_order_id =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_order_id)
    ELSE ""
    ENDIF
    ,
    orders_order_mnemonic =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) substring(1,100,data->qual[d
      .seq].defic_qual[ddefic.seq].order_qual[1].orders_order_mnemonic)
    ELSE ""
    ENDIF
    , orders_order_status_cd =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_order_status_cd)
    ELSE ""
    ENDIF
    , orders_orig_order_convs_seq =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_orig_order_convs_seq)
    ELSE ""
    ENDIF
    ,
    orders_orig_order_dt_tm =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_orig_order_dt_tm)
    ELSE ""
    ENDIF
    , orders_orig_order_tz =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_orig_order_tz)
    ELSE ""
    ENDIF
    , orders_orig_ord_as_flag =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_orig_ord_as_flag)
    ELSE ""
    ENDIF
    ,
    orders_override_flag =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_override_flag)
    ELSE ""
    ENDIF
    , orders_pathway_catalog_id =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_pathway_catalog_id)
    ELSE ""
    ENDIF
    , orders_person_id =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_person_id)
    ELSE ""
    ENDIF
    ,
    orders_prn_ind =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_prn_ind)
    ELSE ""
    ENDIF
    , orders_product_id =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_product_id)
    ELSE ""
    ENDIF
    , orders_projected_stop_dt_tm =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_projected_stop_dt_tm)
    ELSE ""
    ENDIF
    ,
    orders_projected_stop_tz =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_projected_stop_tz)
    ELSE ""
    ENDIF
    , orders_ref_text_mask =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_ref_text_mask)
    ELSE ""
    ENDIF
    , orders_remaining_dose_cnt =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_remaining_dose_cnt)
    ELSE ""
    ENDIF
    ,
    orders_resume_effective_dt_tm =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_resume_effective_dt_tm)
    ELSE ""
    ENDIF
    , orders_resume_effective_tz =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_resume_effective_tz)
    ELSE ""
    ENDIF
    , orders_resume_ind =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_resume_ind)
    ELSE ""
    ENDIF
    ,
    orders_rx_mask =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_rx_mask)
    ELSE ""
    ENDIF
    , orders_sch_state_cd =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_sch_state_cd)
    ELSE ""
    ENDIF
    , orders_soft_stop_dt_tm =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_soft_stop_dt_tm)
    ELSE ""
    ENDIF
    ,
    orders_soft_stop_tz =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_soft_stop_tz)
    ELSE ""
    ENDIF
    , orders_status_dt_tm =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_status_dt_tm)
    ELSE ""
    ENDIF
    , orders_status_prsnl_id =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_status_prsnl_id)
    ELSE ""
    ENDIF
    ,
    orders_stop_type_cd =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_stop_type_cd)
    ELSE ""
    ENDIF
    , orders_suspend_effective_dt_tm =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_suspend_effective_dt_tm)
    ELSE ""
    ENDIF
    , orders_suspend_effective_tz =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_suspend_effective_tz)
    ELSE ""
    ENDIF
    ,
    orders_suspend_ind =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_suspend_ind)
    ELSE ""
    ENDIF
    , orders_synonym_id =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_synonym_id)
    ELSE ""
    ENDIF
    , orders_template_core_action_sequence =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_template_core_action_sequence)
    ELSE ""
    ENDIF
    ,
    orders_template_order_flag =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_template_order_flag)
    ELSE ""
    ENDIF
    , orders_template_order_id =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_template_order_id)
    ELSE ""
    ENDIF
    , orders_updt_dt_tm =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_updt_dt_tm)
    ELSE ""
    ENDIF
    ,
    orders_updt_id =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_updt_id)
    ELSE ""
    ENDIF
    , orders_updt_task =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_updt_task)
    ELSE ""
    ENDIF
    , orders_valid_dose_dt_tm =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=2)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].order_qual[1].orders_valid_dose_dt_tm)
    ELSE ""
    ENDIF
    ,
    him_event_action_status_cd =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=1)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].doc_qual[1].him_event_action_status_cd)
    ELSE ""
    ENDIF
    , him_event_action_type_cd =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=1)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].doc_qual[1].him_event_action_type_cd)
    ELSE ""
    ENDIF
    , him_event_active_ind =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=1)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].doc_qual[1].him_event_active_ind)
    ELSE ""
    ENDIF
    ,
    him_event_active_status_cd =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=1)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].doc_qual[1].him_event_active_status_cd)
    ELSE ""
    ENDIF
    , him_event_active_status_dt_tm =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=1)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].doc_qual[1].him_event_active_status_dt_tm)
    ELSE ""
    ENDIF
    , him_event_active_status_prsnl_id =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=1)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].doc_qual[1].him_event_active_status_prsnl_id)
    ELSE ""
    ENDIF
    ,
    him_event_allocation_dt_tm =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=1)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].doc_qual[1].him_event_allocation_dt_tm)
    ELSE ""
    ENDIF
    , him_event_beg_effective_dt_tm =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=1)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].doc_qual[1].him_event_beg_effective_dt_tm)
    ELSE ""
    ENDIF
    , him_event_completed_dt_tm =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=1)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].doc_qual[1].him_event_completed_dt_tm)
    ELSE ""
    ENDIF
    ,
    him_event_encntr_id =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=1)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].doc_qual[1].him_event_encntr_id)
    ELSE ""
    ENDIF
    , him_event_end_effective_dt_tm =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=1)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].doc_qual[1].him_event_end_effective_dt_tm)
    ELSE ""
    ENDIF
    , him_event_event_cd =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=1)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].doc_qual[1].him_event_event_cd)
    ELSE ""
    ENDIF
    ,
    him_event_event_id =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=1)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].doc_qual[1].him_event_event_id)
    ELSE ""
    ENDIF
    , him_event_him_event_allocation_id =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=1)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].doc_qual[1].him_event_him_event_allocation_id)
    ELSE ""
    ENDIF
    , him_event_prsnl_id =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=1)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].doc_qual[1].him_event_prsnl_id)
    ELSE ""
    ENDIF
    ,
    him_event_request_dt_tm =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=1)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].doc_qual[1].him_event_request_dt_tm)
    ELSE ""
    ENDIF
    , him_event_updt_dt_tm =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=1)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].doc_qual[1].him_event_updt_dt_tm)
    ELSE ""
    ENDIF
    , him_event_updt_id =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=1)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].doc_qual[1].him_event_updt_id)
    ELSE ""
    ENDIF
    ,
    him_event_updt_task =
    IF ((data->qual[d.seq].defic_qual[ddefic.seq].deficiency_flag=1)) build(data->qual[d.seq].
      defic_qual[ddefic.seq].doc_qual[1].him_event_updt_task)
    ELSE ""
    ENDIF
    FROM (dummyt d  WITH seq = value(size(data->qual,5))),
     (dummyt ddefic  WITH seq = value(data->max_defic_qual_count))
    PLAN (d
     WHERE d.seq > 0
      AND parser(ms_chartage_clause)
      AND parser(ms_position_clause))
     JOIN (ddefic
     WHERE ddefic.seq <= size(data->qual[d.seq].defic_qual,5)
      AND parser(ms_deficiencyage_clause))
    ORDER BY organization_name, organization_id, physician_name,
     physician_id, sort_disch_dt_tm, alpha_patient_name,
     encntr_id, deficiency_name, deficiency_status
    HEAD REPORT
     _d0 = patient_name, _d1 = organization_name, _d2 = mrn,
     _d3 = fin, _d4 = encntr_id, _d5 = physician_name,
     _d6 = location, _d7 = disch_dt_tm, _d8 = chart_age,
     _d9 = deficiency_name, _d10 = deficiency_age, _d11 = deficiency_status,
     _fenddetail = (rptreport->m_pagewidth - rptreport->m_marginbottom), rowcount = 0, blank = "",
     total_chart_cnt = 0, total_def_cnt = 0, allfacilities = uar_i18ngetmessage(i18nhandlehim,
      "ALLFACILITIES","All Facilities"),
     facilitylist = makelistofqualitemnames(organizations,allfacilities), allphysicians =
     uar_i18ngetmessage(i18nhandlehim,"ALLPHYSICIANS","All Physicians"), physicianlist =
     makelistofqualitemnames(physicians,allphysicians),
     chartagelist =  $MS_CHARTAGE, deficiencyagelist =  $MS_DEFAGE, allpositions = "All Positions",
     positionlist = makelistofqualitemnames(positions,allpositions), _bcontfieldname07 = 0,
     _bcontfieldname08 = 0,
     ml_bcontfieldnamechartage = 0, ml_bcontfieldnamedeficiencyage = 0, ml_bcontfieldnameposition = 0,
     _fdrawheight = fieldname00(rpt_calcheight)
     IF ((_fenddetail > (_yoffset+ _fdrawheight)))
      _fdrawheight = (_fdrawheight+ fieldname01(rpt_calcheight))
     ENDIF
     IF ((_fenddetail > (_yoffset+ _fdrawheight)))
      _fdrawheight = (_fdrawheight+ fieldname02(rpt_calcheight))
     ENDIF
     IF ((_fenddetail > (_yoffset+ _fdrawheight)))
      _fdrawheight = (_fdrawheight+ fieldname03(rpt_calcheight))
     ENDIF
     IF ((_fenddetail > (_yoffset+ _fdrawheight)))
      _fdrawheight = (_fdrawheight+ fieldname04(rpt_calcheight))
     ENDIF
     IF ((_fenddetail > (_yoffset+ _fdrawheight)))
      _fdrawheight = (_fdrawheight+ fieldname05(rpt_calcheight))
     ENDIF
     IF ((_fenddetail > (_yoffset+ _fdrawheight)))
      _fdrawheight = (_fdrawheight+ fieldname06(rpt_calcheight))
     ENDIF
     IF ((_fenddetail > (_yoffset+ _fdrawheight)))
      _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ fieldname07(rpt_calcheight,((_fenddetail -
       _yoffset) - _fdrawheight),_bholdcontinue))
      IF (_bholdcontinue=1)
       _fdrawheight = (_fenddetail+ 1)
      ENDIF
     ENDIF
     IF ((_fenddetail > (_yoffset+ _fdrawheight)))
      _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ fieldname08(rpt_calcheight,((_fenddetail -
       _yoffset) - _fdrawheight),_bholdcontinue))
      IF (_bholdcontinue=1)
       _fdrawheight = (_fenddetail+ 1)
      ENDIF
     ENDIF
     IF ((_fenddetail > (_yoffset+ _fdrawheight)))
      _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ fieldnamechartage(rpt_calcheight,((
       _fenddetail - _yoffset) - _fdrawheight),_bholdcontinue))
      IF (_bholdcontinue=1)
       _fdrawheight = (_fenddetail+ 1)
      ENDIF
     ENDIF
     IF ((_fenddetail > (_yoffset+ _fdrawheight)))
      _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ fieldnamedeficiencyage(rpt_calcheight,((
       _fenddetail - _yoffset) - _fdrawheight),_bholdcontinue))
      IF (_bholdcontinue=1)
       _fdrawheight = (_fenddetail+ 1)
      ENDIF
     ENDIF
     IF ((_fenddetail > (_yoffset+ _fdrawheight)))
      _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ fieldnameposition(rpt_calcheight,((
       _fenddetail - _yoffset) - _fdrawheight),_bholdcontinue))
      IF (_bholdcontinue=1)
       _fdrawheight = (_fenddetail+ 1)
      ENDIF
     ENDIF
     IF (((_yoffset+ _fdrawheight) > (rptreport->m_pagewidth - rptreport->m_marginbottom)))
      _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),_yoffset,(offsetx+ 10.000),_yoffset),
      CALL pagebreak(rpt_render), offsety = _yoffset
     ENDIF
     dummy_val = fieldname00(rpt_render), _fdrawheight = fieldname01(rpt_calcheight)
     IF ((_fenddetail > (_yoffset+ _fdrawheight)))
      _fdrawheight = (_fdrawheight+ fieldname02(rpt_calcheight))
     ENDIF
     IF ((_fenddetail > (_yoffset+ _fdrawheight)))
      _fdrawheight = (_fdrawheight+ fieldname03(rpt_calcheight))
     ENDIF
     IF ((_fenddetail > (_yoffset+ _fdrawheight)))
      _fdrawheight = (_fdrawheight+ fieldname04(rpt_calcheight))
     ENDIF
     IF ((_fenddetail > (_yoffset+ _fdrawheight)))
      _fdrawheight = (_fdrawheight+ fieldname05(rpt_calcheight))
     ENDIF
     IF ((_fenddetail > (_yoffset+ _fdrawheight)))
      _fdrawheight = (_fdrawheight+ fieldname06(rpt_calcheight))
     ENDIF
     IF ((_fenddetail > (_yoffset+ _fdrawheight)))
      _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ fieldname07(rpt_calcheight,((_fenddetail -
       _yoffset) - _fdrawheight),_bholdcontinue))
      IF (_bholdcontinue=1)
       _fdrawheight = (_fenddetail+ 1)
      ENDIF
     ENDIF
     IF ((_fenddetail > (_yoffset+ _fdrawheight)))
      _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ fieldname08(rpt_calcheight,((_fenddetail -
       _yoffset) - _fdrawheight),_bholdcontinue))
      IF (_bholdcontinue=1)
       _fdrawheight = (_fenddetail+ 1)
      ENDIF
     ENDIF
     IF ((_fenddetail > (_yoffset+ _fdrawheight)))
      _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ fieldnamechartage(rpt_calcheight,((
       _fenddetail - _yoffset) - _fdrawheight),_bholdcontinue))
      IF (_bholdcontinue=1)
       _fdrawheight = (_fenddetail+ 1)
      ENDIF
     ENDIF
     IF ((_fenddetail > (_yoffset+ _fdrawheight)))
      _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ fieldnamedeficiencyage(rpt_calcheight,((
       _fenddetail - _yoffset) - _fdrawheight),_bholdcontinue))
      IF (_bholdcontinue=1)
       _fdrawheight = (_fenddetail+ 1)
      ENDIF
     ENDIF
     IF ((_fenddetail > (_yoffset+ _fdrawheight)))
      _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ fieldnameposition(rpt_calcheight,((
       _fenddetail - _yoffset) - _fdrawheight),_bholdcontinue))
      IF (_bholdcontinue=1)
       _fdrawheight = (_fenddetail+ 1)
      ENDIF
     ENDIF
     IF (((_yoffset+ _fdrawheight) > (rptreport->m_pagewidth - rptreport->m_marginbottom)))
      _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),_yoffset,(offsetx+ 10.000),_yoffset),
      CALL pagebreak(rpt_render), offsety = _yoffset
     ENDIF
     dummy_val = fieldname01(rpt_render), _fdrawheight = fieldname02(rpt_calcheight)
     IF ((_fenddetail > (_yoffset+ _fdrawheight)))
      _fdrawheight = (_fdrawheight+ fieldname03(rpt_calcheight))
     ENDIF
     IF ((_fenddetail > (_yoffset+ _fdrawheight)))
      _fdrawheight = (_fdrawheight+ fieldname04(rpt_calcheight))
     ENDIF
     IF ((_fenddetail > (_yoffset+ _fdrawheight)))
      _fdrawheight = (_fdrawheight+ fieldname05(rpt_calcheight))
     ENDIF
     IF ((_fenddetail > (_yoffset+ _fdrawheight)))
      _fdrawheight = (_fdrawheight+ fieldname06(rpt_calcheight))
     ENDIF
     IF ((_fenddetail > (_yoffset+ _fdrawheight)))
      _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ fieldname07(rpt_calcheight,((_fenddetail -
       _yoffset) - _fdrawheight),_bholdcontinue))
      IF (_bholdcontinue=1)
       _fdrawheight = (_fenddetail+ 1)
      ENDIF
     ENDIF
     IF ((_fenddetail > (_yoffset+ _fdrawheight)))
      _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ fieldname08(rpt_calcheight,((_fenddetail -
       _yoffset) - _fdrawheight),_bholdcontinue))
      IF (_bholdcontinue=1)
       _fdrawheight = (_fenddetail+ 1)
      ENDIF
     ENDIF
     IF ((_fenddetail > (_yoffset+ _fdrawheight)))
      _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ fieldnamechartage(rpt_calcheight,((
       _fenddetail - _yoffset) - _fdrawheight),_bholdcontinue))
      IF (_bholdcontinue=1)
       _fdrawheight = (_fenddetail+ 1)
      ENDIF
     ENDIF
     IF ((_fenddetail > (_yoffset+ _fdrawheight)))
      _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ fieldnamedeficiencyage(rpt_calcheight,((
       _fenddetail - _yoffset) - _fdrawheight),_bholdcontinue))
      IF (_bholdcontinue=1)
       _fdrawheight = (_fenddetail+ 1)
      ENDIF
     ENDIF
     IF ((_fenddetail > (_yoffset+ _fdrawheight)))
      _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ fieldnameposition(rpt_calcheight,((
       _fenddetail - _yoffset) - _fdrawheight),_bholdcontinue))
      IF (_bholdcontinue=1)
       _fdrawheight = (_fenddetail+ 1)
      ENDIF
     ENDIF
     IF (((_yoffset+ _fdrawheight) > (rptreport->m_pagewidth - rptreport->m_marginbottom)))
      _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),_yoffset,(offsetx+ 10.000),_yoffset),
      CALL pagebreak(rpt_render), offsety = _yoffset
     ENDIF
     dummy_val = fieldname02(rpt_render), _fdrawheight = fieldname03(rpt_calcheight)
     IF ((_fenddetail > (_yoffset+ _fdrawheight)))
      _fdrawheight = (_fdrawheight+ fieldname04(rpt_calcheight))
     ENDIF
     IF ((_fenddetail > (_yoffset+ _fdrawheight)))
      _fdrawheight = (_fdrawheight+ fieldname05(rpt_calcheight))
     ENDIF
     IF ((_fenddetail > (_yoffset+ _fdrawheight)))
      _fdrawheight = (_fdrawheight+ fieldname06(rpt_calcheight))
     ENDIF
     IF ((_fenddetail > (_yoffset+ _fdrawheight)))
      _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ fieldname07(rpt_calcheight,((_fenddetail -
       _yoffset) - _fdrawheight),_bholdcontinue))
      IF (_bholdcontinue=1)
       _fdrawheight = (_fenddetail+ 1)
      ENDIF
     ENDIF
     IF ((_fenddetail > (_yoffset+ _fdrawheight)))
      _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ fieldname08(rpt_calcheight,((_fenddetail -
       _yoffset) - _fdrawheight),_bholdcontinue))
      IF (_bholdcontinue=1)
       _fdrawheight = (_fenddetail+ 1)
      ENDIF
     ENDIF
     IF ((_fenddetail > (_yoffset+ _fdrawheight)))
      _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ fieldnamechartage(rpt_calcheight,((
       _fenddetail - _yoffset) - _fdrawheight),_bholdcontinue))
      IF (_bholdcontinue=1)
       _fdrawheight = (_fenddetail+ 1)
      ENDIF
     ENDIF
     IF ((_fenddetail > (_yoffset+ _fdrawheight)))
      _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ fieldnamedeficiencyage(rpt_calcheight,((
       _fenddetail - _yoffset) - _fdrawheight),_bholdcontinue))
      IF (_bholdcontinue=1)
       _fdrawheight = (_fenddetail+ 1)
      ENDIF
     ENDIF
     IF ((_fenddetail > (_yoffset+ _fdrawheight)))
      _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ fieldnameposition(rpt_calcheight,((
       _fenddetail - _yoffset) - _fdrawheight),_bholdcontinue))
      IF (_bholdcontinue=1)
       _fdrawheight = (_fenddetail+ 1)
      ENDIF
     ENDIF
     IF (((_yoffset+ _fdrawheight) > (rptreport->m_pagewidth - rptreport->m_marginbottom)))
      _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),_yoffset,(offsetx+ 10.000),_yoffset),
      CALL pagebreak(rpt_render), offsety = _yoffset
     ENDIF
     dummy_val = fieldname03(rpt_render), _fdrawheight = fieldname04(rpt_calcheight)
     IF ((_fenddetail > (_yoffset+ _fdrawheight)))
      _fdrawheight = (_fdrawheight+ fieldname05(rpt_calcheight))
     ENDIF
     IF ((_fenddetail > (_yoffset+ _fdrawheight)))
      _fdrawheight = (_fdrawheight+ fieldname06(rpt_calcheight))
     ENDIF
     IF ((_fenddetail > (_yoffset+ _fdrawheight)))
      _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ fieldname07(rpt_calcheight,((_fenddetail -
       _yoffset) - _fdrawheight),_bholdcontinue))
      IF (_bholdcontinue=1)
       _fdrawheight = (_fenddetail+ 1)
      ENDIF
     ENDIF
     IF ((_fenddetail > (_yoffset+ _fdrawheight)))
      _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ fieldname08(rpt_calcheight,((_fenddetail -
       _yoffset) - _fdrawheight),_bholdcontinue))
      IF (_bholdcontinue=1)
       _fdrawheight = (_fenddetail+ 1)
      ENDIF
     ENDIF
     IF ((_fenddetail > (_yoffset+ _fdrawheight)))
      _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ fieldnamechartage(rpt_calcheight,((
       _fenddetail - _yoffset) - _fdrawheight),_bholdcontinue))
      IF (_bholdcontinue=1)
       _fdrawheight = (_fenddetail+ 1)
      ENDIF
     ENDIF
     IF ((_fenddetail > (_yoffset+ _fdrawheight)))
      _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ fieldnamedeficiencyage(rpt_calcheight,((
       _fenddetail - _yoffset) - _fdrawheight),_bholdcontinue))
      IF (_bholdcontinue=1)
       _fdrawheight = (_fenddetail+ 1)
      ENDIF
     ENDIF
     IF ((_fenddetail > (_yoffset+ _fdrawheight)))
      _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ fieldnameposition(rpt_calcheight,((
       _fenddetail - _yoffset) - _fdrawheight),_bholdcontinue))
      IF (_bholdcontinue=1)
       _fdrawheight = (_fenddetail+ 1)
      ENDIF
     ENDIF
     IF (((_yoffset+ _fdrawheight) > (rptreport->m_pagewidth - rptreport->m_marginbottom)))
      _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),_yoffset,(offsetx+ 10.000),_yoffset),
      CALL pagebreak(rpt_render), offsety = _yoffset
     ENDIF
     dummy_val = fieldname04(rpt_render), _fdrawheight = fieldname05(rpt_calcheight)
     IF ((_fenddetail > (_yoffset+ _fdrawheight)))
      _fdrawheight = (_fdrawheight+ fieldname06(rpt_calcheight))
     ENDIF
     IF ((_fenddetail > (_yoffset+ _fdrawheight)))
      _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ fieldname07(rpt_calcheight,((_fenddetail -
       _yoffset) - _fdrawheight),_bholdcontinue))
      IF (_bholdcontinue=1)
       _fdrawheight = (_fenddetail+ 1)
      ENDIF
     ENDIF
     IF ((_fenddetail > (_yoffset+ _fdrawheight)))
      _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ fieldname08(rpt_calcheight,((_fenddetail -
       _yoffset) - _fdrawheight),_bholdcontinue))
      IF (_bholdcontinue=1)
       _fdrawheight = (_fenddetail+ 1)
      ENDIF
     ENDIF
     IF ((_fenddetail > (_yoffset+ _fdrawheight)))
      _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ fieldnamechartage(rpt_calcheight,((
       _fenddetail - _yoffset) - _fdrawheight),_bholdcontinue))
      IF (_bholdcontinue=1)
       _fdrawheight = (_fenddetail+ 1)
      ENDIF
     ENDIF
     IF ((_fenddetail > (_yoffset+ _fdrawheight)))
      _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ fieldnamedeficiencyage(rpt_calcheight,((
       _fenddetail - _yoffset) - _fdrawheight),_bholdcontinue))
      IF (_bholdcontinue=1)
       _fdrawheight = (_fenddetail+ 1)
      ENDIF
     ENDIF
     IF ((_fenddetail > (_yoffset+ _fdrawheight)))
      _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ fieldnameposition(rpt_calcheight,((
       _fenddetail - _yoffset) - _fdrawheight),_bholdcontinue))
      IF (_bholdcontinue=1)
       _fdrawheight = (_fenddetail+ 1)
      ENDIF
     ENDIF
     IF (((_yoffset+ _fdrawheight) > (rptreport->m_pagewidth - rptreport->m_marginbottom)))
      _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),_yoffset,(offsetx+ 10.000),_yoffset),
      CALL pagebreak(rpt_render), offsety = _yoffset
     ENDIF
     dummy_val = fieldname05(rpt_render), _fdrawheight = fieldname06(rpt_calcheight)
     IF ((_fenddetail > (_yoffset+ _fdrawheight)))
      _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ fieldname07(rpt_calcheight,((_fenddetail -
       _yoffset) - _fdrawheight),_bholdcontinue))
      IF (_bholdcontinue=1)
       _fdrawheight = (_fenddetail+ 1)
      ENDIF
     ENDIF
     IF ((_fenddetail > (_yoffset+ _fdrawheight)))
      _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ fieldname08(rpt_calcheight,((_fenddetail -
       _yoffset) - _fdrawheight),_bholdcontinue))
      IF (_bholdcontinue=1)
       _fdrawheight = (_fenddetail+ 1)
      ENDIF
     ENDIF
     IF ((_fenddetail > (_yoffset+ _fdrawheight)))
      _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ fieldnamechartage(rpt_calcheight,((
       _fenddetail - _yoffset) - _fdrawheight),_bholdcontinue))
      IF (_bholdcontinue=1)
       _fdrawheight = (_fenddetail+ 1)
      ENDIF
     ENDIF
     IF ((_fenddetail > (_yoffset+ _fdrawheight)))
      _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ fieldnamedeficiencyage(rpt_calcheight,((
       _fenddetail - _yoffset) - _fdrawheight),_bholdcontinue))
      IF (_bholdcontinue=1)
       _fdrawheight = (_fenddetail+ 1)
      ENDIF
     ENDIF
     IF ((_fenddetail > (_yoffset+ _fdrawheight)))
      _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ fieldnameposition(rpt_calcheight,((
       _fenddetail - _yoffset) - _fdrawheight),_bholdcontinue))
      IF (_bholdcontinue=1)
       _fdrawheight = (_fenddetail+ 1)
      ENDIF
     ENDIF
     IF (((_yoffset+ _fdrawheight) > (rptreport->m_pagewidth - rptreport->m_marginbottom)))
      _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),_yoffset,(offsetx+ 10.000),_yoffset),
      CALL pagebreak(rpt_render), offsety = _yoffset
     ENDIF
     dummy_val = fieldname06(rpt_render), bfirsttime = 1
     WHILE (((_bcontfieldname07=1) OR (bfirsttime=1)) )
       _bholdcontinue = _bcontfieldname07, _fdrawheight = fieldname07(rpt_calcheight,((rptreport->
        m_pagewidth - rptreport->m_marginbottom) - _yoffset),_bholdcontinue)
       IF ((_fenddetail > (_yoffset+ _fdrawheight)))
        _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ fieldname08(rpt_calcheight,((_fenddetail -
         _yoffset) - _fdrawheight),_bholdcontinue))
        IF (_bholdcontinue=1)
         _fdrawheight = (_fenddetail+ 1)
        ENDIF
       ENDIF
       IF (((_yoffset+ _fdrawheight) > (rptreport->m_pagewidth - rptreport->m_marginbottom)))
        _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),_yoffset,(offsetx+ 10.000),_yoffset),
        CALL pagebreak(rpt_render), offsety = _yoffset
       ELSEIF (_bholdcontinue=1
        AND _bcontfieldname07=0)
        _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),_yoffset,(offsetx+ 10.000),_yoffset),
        CALL pagebreak(rpt_render), offsety = _yoffset
       ENDIF
       dummy_val = fieldname07(rpt_render,((rptreport->m_pagewidth - rptreport->m_marginbottom) -
        _yoffset),_bcontfieldname07), bfirsttime = 0
     ENDWHILE
     bfirsttime = 1
     WHILE (((_bcontfieldname08=1) OR (bfirsttime=1)) )
       _bholdcontinue = _bcontfieldname08, _fdrawheight = fieldname08(rpt_calcheight,((rptreport->
        m_pagewidth - rptreport->m_marginbottom) - _yoffset),_bholdcontinue)
       IF (((_yoffset+ _fdrawheight) > (rptreport->m_pagewidth - rptreport->m_marginbottom)))
        _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),_yoffset,(offsetx+ 10.000),_yoffset),
        CALL pagebreak(rpt_render), offsety = _yoffset
       ELSEIF (_bholdcontinue=1
        AND _bcontfieldname08=0)
        _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),_yoffset,(offsetx+ 10.000),_yoffset),
        CALL pagebreak(rpt_render), offsety = _yoffset
       ENDIF
       dummy_val = fieldname08(rpt_render,((rptreport->m_pagewidth - rptreport->m_marginbottom) -
        _yoffset),_bcontfieldname08), bfirsttime = 0
     ENDWHILE
     bfirsttime = 1
     WHILE (((ml_bcontfieldnamechartage=1) OR (bfirsttime=1)) )
       _bholdcontinue = ml_bcontfieldnamechartage, _fdrawheight = fieldnamechartage(rpt_calcheight,((
        rptreport->m_pagewidth - rptreport->m_marginbottom) - _yoffset),_bholdcontinue)
       IF (((_yoffset+ _fdrawheight) > (rptreport->m_pagewidth - rptreport->m_marginbottom)))
        _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),_yoffset,(offsetx+ 10.000),_yoffset),
        CALL pagebreak(rpt_render), offsety = _yoffset
       ELSEIF (_bholdcontinue=1
        AND ml_bcontfieldnamechartage=0)
        _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),_yoffset,(offsetx+ 10.000),_yoffset),
        CALL pagebreak(rpt_render), offsety = _yoffset
       ENDIF
       dummy_val = fieldnamechartage(rpt_render,((rptreport->m_pagewidth - rptreport->m_marginbottom)
         - _yoffset),ml_bcontfieldnamechartage), bfirsttime = 0
     ENDWHILE
     bfirsttime = 1
     WHILE (((ml_bcontfieldnamedeficiencyage=1) OR (bfirsttime=1)) )
       _bholdcontinue = ml_bcontfieldnamedeficiencyage, _fdrawheight = fieldnamedeficiencyage(
        rpt_calcheight,((rptreport->m_pagewidth - rptreport->m_marginbottom) - _yoffset),
        _bholdcontinue)
       IF (((_yoffset+ _fdrawheight) > (rptreport->m_pagewidth - rptreport->m_marginbottom)))
        _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),_yoffset,(offsetx+ 10.000),_yoffset),
        CALL pagebreak(rpt_render), offsety = _yoffset
       ELSEIF (_bholdcontinue=1
        AND ml_bcontfieldnamedeficiencyage=0)
        _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),_yoffset,(offsetx+ 10.000),_yoffset),
        CALL pagebreak(rpt_render), offsety = _yoffset
       ENDIF
       dummy_val = fieldnamedeficiencyage(rpt_render,((rptreport->m_pagewidth - rptreport->
        m_marginbottom) - _yoffset),ml_bcontfieldnamedeficiencyage), bfirsttime = 0
     ENDWHILE
     bfirsttime = 1
     WHILE (((ml_bcontfieldnameposition=1) OR (bfirsttime=1)) )
       _bholdcontinue = ml_bcontfieldnameposition, _fdrawheight = fieldnameposition(rpt_calcheight,((
        rptreport->m_pagewidth - rptreport->m_marginbottom) - _yoffset),_bholdcontinue)
       IF (((_yoffset+ _fdrawheight) > (rptreport->m_pagewidth - rptreport->m_marginbottom)))
        _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),_yoffset,(offsetx+ 10.000),_yoffset),
        CALL pagebreak(rpt_render), offsety = _yoffset
       ELSEIF (_bholdcontinue=1
        AND ml_bcontfieldnameposition=0)
        _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),_yoffset,(offsetx+ 10.000),_yoffset),
        CALL pagebreak(rpt_render), offsety = _yoffset
       ENDIF
       dummy_val = fieldnameposition(rpt_render,((rptreport->m_pagewidth - rptreport->m_marginbottom)
         - _yoffset),ml_bcontfieldnameposition), bfirsttime = 0
     ENDWHILE
    HEAD PAGE
     IF (curpage > 1)
      _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),_yoffset,(offsetx+ 10.000),_yoffset),
      dummy_val = pagebreak(rpt_render), offsety = _yoffset
     ENDIF
     pageofpage = rpt_pageofpage, dummy_val = fieldname09(rpt_render), dummy_val = fieldname010(
      rpt_render),
     dummy_val = fieldname011(rpt_render)
    HEAD organization_name
     _fdrawheight = fieldname012(rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = fieldname012(rpt_render)
    HEAD organization_id
     organization = organization_name, org_def_cnt = 0, org_chart_cnt = 0,
     _fdrawheight = fieldname013(rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = fieldname013(rpt_render)
    HEAD physician_name
     _fdrawheight = fieldname014(rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = fieldname014(rpt_render)
    HEAD physician_id
     physicianname = physician_name, phys_def_cnt = 0, phys_chart_cnt = 0,
     _fdrawheight = fieldname015(rpt_calcheight)
     IF ((_fenddetail > (_yoffset+ _fdrawheight)))
      _fdrawheight = (_fdrawheight+ fieldname016(rpt_calcheight))
     ENDIF
     IF ((_fenddetail > (_yoffset+ _fdrawheight)))
      _fdrawheight = (_fdrawheight+ fieldname017(rpt_calcheight))
     ENDIF
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = fieldname015(rpt_render), _fdrawheight = fieldname016(rpt_calcheight)
     IF ((_fenddetail > (_yoffset+ _fdrawheight)))
      _fdrawheight = (_fdrawheight+ fieldname017(rpt_calcheight))
     ENDIF
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = fieldname016(rpt_render), _fdrawheight = fieldname017(rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = fieldname017(rpt_render)
    HEAD encntr_id
     blank2 = "", displayind = 1, phys_chart_cnt = (phys_chart_cnt+ 1),
     previousencntrid = 0.0, _fdrawheight = fieldname018(rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = fieldname018(rpt_render)
    DETAIL
     patientnameone = patient_name, phys_def_cnt = (phys_def_cnt+ 1), rowcount = (rowcount+ 1),
     mrndisplayrowone = mrn
     IF (deficiency_age > 0)
      num_hours = mod(deficiency_age,24), num_days = (deficiency_age/ 24), deficageone =
      uar_i18nbuildmessage(i18nhandlehim,"DeficAge","%1 Days %2 Hours","ii",num_days,
       num_hours)
     ELSE
      deficageone = "--"
     ENDIF
     IF (chart_age > 0)
      chartageone = uar_i18nbuildmessage(i18nhandlehim,"ChartAge","%1 Days","i",chart_age)
     ELSE
      chartageone = "--"
     ENDIF
     locationone =
     IF (size(trim(location)) > 0) location
     ELSE build("--")
     ENDIF
     IF (deficiency_age > 0)
      num_hours = mod(deficiency_age,24), num_days = (deficiency_age/ 24), deficagetwo =
      uar_i18nbuildmessage(i18nhandlehim,"DeficAge","%1 Days %2 Hours","ii",num_days,
       num_hours)
     ELSE
      deficagetwo = "--"
     ENDIF
     IF (chart_age > 0)
      chartagetwo = uar_i18nbuildmessage(i18nhandlehim,"ChartAge","%1 Days","i",chart_age)
     ELSE
      chartagetwo = "--"
     ENDIF
     locationtwo =
     IF (size(trim(location)) > 0) location
     ELSE build("--")
     ENDIF
     , blank3 = ""
     IF (((previousencntrid=encntr_id) OR (_bgeneratehtml=1)) )
      displayind = 0
     ENDIF
     previousencntrid = encntr_id, _bcontfieldname019 = 0, _bcontfieldname020 = 0,
     bfirsttime = 1
     WHILE (((_bcontfieldname019=1) OR (bfirsttime=1)) )
       _bholdcontinue = _bcontfieldname019, _fdrawheight = fieldname019(rpt_calcheight,(_fenddetail
         - _yoffset),_bholdcontinue)
       IF ((_fenddetail > (_yoffset+ _fdrawheight)))
        _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ fieldname020(rpt_calcheight,((_fenddetail
          - _yoffset) - _fdrawheight),_bholdcontinue))
        IF (_bholdcontinue=1)
         _fdrawheight = (_fenddetail+ 1)
        ENDIF
       ENDIF
       IF ((_fenddetail > (_yoffset+ _fdrawheight)))
        _fdrawheight = (_fdrawheight+ fieldname021(rpt_calcheight))
       ENDIF
       IF (((_yoffset+ _fdrawheight) > _fenddetail))
        BREAK
       ELSEIF (_bholdcontinue=1
        AND _bcontfieldname019=0)
        BREAK
       ENDIF
       dummy_val = fieldname019(rpt_render,(_fenddetail - _yoffset),_bcontfieldname019), bfirsttime
        = 0
     ENDWHILE
     bfirsttime = 1
     WHILE (((_bcontfieldname020=1) OR (bfirsttime=1)) )
       _bholdcontinue = _bcontfieldname020, _fdrawheight = fieldname020(rpt_calcheight,(_fenddetail
         - _yoffset),_bholdcontinue)
       IF ((_fenddetail > (_yoffset+ _fdrawheight)))
        _fdrawheight = (_fdrawheight+ fieldname021(rpt_calcheight))
       ENDIF
       IF (((_yoffset+ _fdrawheight) > _fenddetail))
        BREAK
       ELSEIF (_bholdcontinue=1
        AND _bcontfieldname020=0)
        BREAK
       ENDIF
       dummy_val = fieldname020(rpt_render,(_fenddetail - _yoffset),_bcontfieldname020), bfirsttime
        = 0
     ENDWHILE
     _fdrawheight = fieldname021(rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = fieldname021(rpt_render)
    FOOT  physician_id
     phystotaldefic = phys_def_cnt, org_def_cnt = (org_def_cnt+ phys_def_cnt), org_chart_cnt = (
     org_chart_cnt+ phys_chart_cnt),
     _bcontfieldname023 = 0, _fdrawheight = fieldname022(rpt_calcheight)
     IF ((_fenddetail > (_yoffset+ _fdrawheight)))
      _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ fieldname023(rpt_calcheight,((_fenddetail -
       _yoffset) - _fdrawheight),_bholdcontinue))
      IF (_bholdcontinue=1)
       _fdrawheight = (_fenddetail+ 1)
      ENDIF
     ENDIF
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = fieldname022(rpt_render), bfirsttime = 1
     WHILE (((_bcontfieldname023=1) OR (bfirsttime=1)) )
       _bholdcontinue = _bcontfieldname023, _fdrawheight = fieldname023(rpt_calcheight,(_fenddetail
         - _yoffset),_bholdcontinue)
       IF (((_yoffset+ _fdrawheight) > _fenddetail))
        BREAK
       ELSEIF (_bholdcontinue=1
        AND _bcontfieldname023=0)
        BREAK
       ENDIF
       dummy_val = fieldname023(rpt_render,(_fenddetail - _yoffset),_bcontfieldname023), bfirsttime
        = 0
     ENDWHILE
    FOOT  organization_id
     orgtotaldefic = org_def_cnt, total_def_cnt = (total_def_cnt+ org_def_cnt), total_chart_cnt = (
     total_chart_cnt+ org_chart_cnt),
     _bcontfieldname024 = 0, _bcontfieldname025 = 0, bfirsttime = 1
     WHILE (((_bcontfieldname024=1) OR (bfirsttime=1)) )
       _bholdcontinue = _bcontfieldname024, _fdrawheight = fieldname024(rpt_calcheight,(_fenddetail
         - _yoffset),_bholdcontinue)
       IF ((_fenddetail > (_yoffset+ _fdrawheight)))
        _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ fieldname025(rpt_calcheight,((_fenddetail
          - _yoffset) - _fdrawheight),_bholdcontinue))
        IF (_bholdcontinue=1)
         _fdrawheight = (_fenddetail+ 1)
        ENDIF
       ENDIF
       IF (((_yoffset+ _fdrawheight) > _fenddetail))
        BREAK
       ELSEIF (_bholdcontinue=1
        AND _bcontfieldname024=0)
        BREAK
       ENDIF
       dummy_val = fieldname024(rpt_render,(_fenddetail - _yoffset),_bcontfieldname024), bfirsttime
        = 0
     ENDWHILE
     bfirsttime = 1
     WHILE (((_bcontfieldname025=1) OR (bfirsttime=1)) )
       _bholdcontinue = _bcontfieldname025, _fdrawheight = fieldname025(rpt_calcheight,(_fenddetail
         - _yoffset),_bholdcontinue)
       IF (((_yoffset+ _fdrawheight) > _fenddetail))
        BREAK
       ELSEIF (_bholdcontinue=1
        AND _bcontfieldname025=0)
        BREAK
       ENDIF
       dummy_val = fieldname025(rpt_render,(_fenddetail - _yoffset),_bcontfieldname025), bfirsttime
        = 0
     ENDWHILE
    FOOT REPORT
     _bcontfieldname026 = 0, _bcontfieldname027 = 0, bfirsttime = 1
     WHILE (((_bcontfieldname026=1) OR (bfirsttime=1)) )
       _bholdcontinue = _bcontfieldname026, _fdrawheight = fieldname026(rpt_calcheight,(_fenddetail
         - _yoffset),_bholdcontinue)
       IF ((_fenddetail > (_yoffset+ _fdrawheight)))
        _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ fieldname027(rpt_calcheight,((_fenddetail
          - _yoffset) - _fdrawheight),_bholdcontinue))
        IF (_bholdcontinue=1)
         _fdrawheight = (_fenddetail+ 1)
        ENDIF
       ENDIF
       IF ((_fenddetail > (_yoffset+ _fdrawheight)))
        _fdrawheight = (_fdrawheight+ fieldname028(rpt_calcheight))
       ENDIF
       IF ((_fenddetail > (_yoffset+ _fdrawheight)))
        _fdrawheight = (_fdrawheight+ fieldname029(rpt_calcheight))
       ENDIF
       IF (((_yoffset+ _fdrawheight) > _fenddetail))
        _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),_yoffset,(offsetx+ 10.000),_yoffset),
        CALL pagebreak(rpt_render), offsety = _yoffset
       ELSEIF (_bholdcontinue=1
        AND _bcontfieldname026=0)
        _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),_yoffset,(offsetx+ 10.000),_yoffset),
        CALL pagebreak(rpt_render), offsety = _yoffset
       ENDIF
       dummy_val = fieldname026(rpt_render,(_fenddetail - _yoffset),_bcontfieldname026), bfirsttime
        = 0
     ENDWHILE
     bfirsttime = 1
     WHILE (((_bcontfieldname027=1) OR (bfirsttime=1)) )
       _bholdcontinue = _bcontfieldname027, _fdrawheight = fieldname027(rpt_calcheight,(_fenddetail
         - _yoffset),_bholdcontinue)
       IF ((_fenddetail > (_yoffset+ _fdrawheight)))
        _fdrawheight = (_fdrawheight+ fieldname028(rpt_calcheight))
       ENDIF
       IF ((_fenddetail > (_yoffset+ _fdrawheight)))
        _fdrawheight = (_fdrawheight+ fieldname029(rpt_calcheight))
       ENDIF
       IF (((_yoffset+ _fdrawheight) > _fenddetail))
        _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),_yoffset,(offsetx+ 10.000),_yoffset),
        CALL pagebreak(rpt_render), offsety = _yoffset
       ELSEIF (_bholdcontinue=1
        AND _bcontfieldname027=0)
        _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),_yoffset,(offsetx+ 10.000),_yoffset),
        CALL pagebreak(rpt_render), offsety = _yoffset
       ENDIF
       dummy_val = fieldname027(rpt_render,(_fenddetail - _yoffset),_bcontfieldname027), bfirsttime
        = 0
     ENDWHILE
     _fdrawheight = fieldname028(rpt_calcheight)
     IF ((_fenddetail > (_yoffset+ _fdrawheight)))
      _fdrawheight = (_fdrawheight+ fieldname029(rpt_calcheight))
     ENDIF
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),_yoffset,(offsetx+ 10.000),_yoffset),
      CALL pagebreak(rpt_render), offsety = _yoffset
     ENDIF
     dummy_val = fieldname028(rpt_render), _fdrawheight = fieldname029(rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),_yoffset,(offsetx+ 10.000),_yoffset),
      CALL pagebreak(rpt_render), offsety = _yoffset
     ENDIF
     dummy_val = fieldname029(rpt_render)
    WITH nullreport, nocounter, memsort
   ;end select
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE genexcel(null)
   SELECT INTO  $OUTDEV
    organization_name = substring(1,100,data->qual[d.seq].organization_name), physician_name =
    substring(1,100,data->qual[d.seq].physician_name), mrn = substring(1,100,data->qual[d.seq].mrn),
    fin = substring(1,100,data->qual[d.seq].fin), patient_name = substring(1,100,data->qual[d.seq].
     patient_name), patient_type = uar_get_code_display(data->qual[d.seq].patient_type_cd),
    disch_dt_tm = format(data->qual[d.seq].disch_dt_tm,";;q"), chart_age = data->qual[d.seq].
    chart_age, deficiency_name = substring(1,100,build(data->qual[d.seq].defic_qual[ddefic.seq].
      deficiency_name)),
    deficiency_status = substring(1,30,build(data->qual[d.seq].defic_qual[ddefic.seq].status))
    FROM (dummyt d  WITH seq = value(size(data->qual,5))),
     (dummyt ddefic  WITH seq = value(data->max_defic_qual_count))
    PLAN (d
     WHERE d.seq > 0
      AND parser(ms_chartage_clause)
      AND parser(ms_position_clause))
     JOIN (ddefic
     WHERE ddefic.seq <= size(data->qual[d.seq].defic_qual,5)
      AND parser(ms_deficiencyage_clause))
    ORDER BY organization_name, physician_name, patient_name,
     deficiency_name, deficiency_status
    WITH format, separator = " ", nocounter,
     memsort
   ;end select
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   IF (_bgeneratehtml=1)
    SET _htmlfilehandle = uar_fopen(nullterm(_sendto),"w+b")
    SET _htmlfilestat = uar_fwrite("<html>",1,6,_htmlfilehandle)
    SET _vcwriteln = concat("<head><script language=javascript>  ",
     "function CCLLINK(program,param,nViewerType)",'  {var sXMLParams = "<params>";',
     ^  sXMLParams += '<param value="' + param + '"  type="N"/>';^,'  sXMLParams += "</params>";',
     "  var outputHTML = top.getGeneratedOutputPage(program, 'MINE', sXMLParams, '', '',nViewerType);",
     "  if(nViewerType != 1) {var outputWin = window.open('about:blank', '', 'location=no,menubar=no,",
     "resizable=yes,scrollbars=yes,status=yes,titlebar=yes,toolbar=no');",
     "  outputWin.document.write( outputHTML);","  outputWin.focus();",
     "  } else{document.write( outputHTML);}  ","}</script></head>")
    SET _htmlfilestat = uar_fwrite(_vcwriteln,1,textlen(_vcwriteln),_htmlfilehandle)
   ELSEIF (ml_generateexcel=0)
    SET rptreport->m_recsize = 100
    SET rptreport->m_reportname = "HIM_MAK_DEFIC_BY_PHYS_DET_LYT"
    SET rptreport->m_pagewidth = 8.50
    SET rptreport->m_pageheight = 11.00
    SET rptreport->m_orientation = rpt_landscape
    SET rptreport->m_marginleft = 0.50
    SET rptreport->m_marginright = 0.50
    SET rptreport->m_margintop = 0.50
    SET rptreport->m_marginbottom = 0.50
    SET rptreport->m_horzprintoffset = _xshift
    SET rptreport->m_vertprintoffset = _yshift
    SELECT INTO "nl:"
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
   CALL _createfonts(0)
   CALL _createpens(0)
 END ;Subroutine
 SUBROUTINE _createfonts(dummy)
   SET rptfont->m_recsize = 50
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
   SET rptfont->m_pointsize = 10
   SET rptfont->m_italic = rpt_off
   SET rptfont->m_rgbcolor = rpt_black
   SET _times10b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 11
   SET _times11b0 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penwidth = 0.000
   SET _pen0s0c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penwidth = 0.015
   SET _pen15s0c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penwidth = 0.025
   SET _pen25s0c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penwidth = 0.020
   SET _pen20s0c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 SET _lretval = uar_i18nlocalizationinit(_hi18nhandle,curprog,"",curcclrev)
 CALL initializereport(0)
 SET _fenddetail = (rptreport->m_pagewidth - rptreport->m_marginbottom)
 SET _bishtml = validate(_htmlfilehandle)
 IF (_bishtml=1)
  SET _bishtml = _htmlfilehandle
 ENDIF
 IF (_bishtml=0)
  IF (ml_generateexcel=0)
   SET bfirsttime = 1
   WHILE (((_bcontsection=1) OR (bfirsttime=1)) )
     SET _bholdcontinue = _bcontsection
     SET _fdrawheight = section(rpt_calcheight,(_fenddetail - _yoffset),_bholdcontinue)
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      CALL pagebreak(0)
     ELSEIF (_bholdcontinue=1
      AND _bcontsection=0)
      CALL pagebreak(0)
     ENDIF
     SET dummy_val = section(rpt_render,(_fenddetail - _yoffset),_bcontsection)
     SET bfirsttime = 0
   ENDWHILE
  ELSE
   CALL genexcel(null)
  ENDIF
 ELSE
  CALL fieldname0html(0)
 ENDIF
 CALL finalizereport(_sendto)
END GO
