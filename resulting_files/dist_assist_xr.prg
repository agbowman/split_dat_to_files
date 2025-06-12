CREATE PROGRAM dist_assist_xr
 PAINT
 EXECUTE cclseclogin
 IF ((xxcclseclogin->loggedin != 1))
  GO TO exit_script
 ENDIF
 SET width = 132
 SET modify = system
 DECLARE distribution_id_chosen = f8 WITH noconstant(0.0)
 DECLARE operations_id_chosen = f8 WITH noconstant(0.0)
 DECLARE encntr_id_chosen = f8 WITH noconstant(0.0)
 DECLARE person_id_chosen = f8 WITH noconstant(0.0)
 DECLARE order_doc_ind = i2 WITH noconstant(0.0)
 DECLARE accession_nbr_chosen = vc WITH noconstant(" ")
 DECLARE distribution_name_chosen = vc WITH noconstant(" ")
 DECLARE device_name_chosen = vc WITH noconstant(" ")
 DECLARE operations_name_chosen = vc WITH noconstant(" ")
 DECLARE law_name_chosen = vc WITH noconstant(" ")
 DECLARE provider_value = vc WITH noconstant(" ")
 DECLARE order_doc_cd = f8 WITH noconstant(0.0)
 DECLARE order_cd = f8 WITH noconstant(0.0)
 DECLARE activate_cd = f8 WITH noconstant(0.0)
 DECLARE modify_cd = f8 WITH noconstant(0.0)
 DECLARE renew_cd = f8 WITH noconstant(0.0)
 DECLARE resume_cd = f8 WITH noconstant(0.0)
 DECLARE stud_activate_cd = f8 WITH noconstant(0.0)
 DECLARE x = i4
 DECLARE y = i4
 DECLARE is_logical_domain_enabled_ind = i2 WITH noconstant(0)
 DECLARE multitenancy = i2 WITH noconstant(0)
 DECLARE personnel_logical_domain_id = f8 WITH noconstant(0.0)
 DECLARE invalid_logical_domain_message = vc WITH noconstant("Invalid entry for Logical Domain")
 DECLARE no_destinations_found = vc WITH noconstant("No Cross-references found for this destination")
 DECLARE oe_field_meaning_id_ccprovider = i4 WITH constant(3589)
 DECLARE oe_field_meaning_id_consultdoc = i4 WITH constant(2)
#initialize
 SET encntr_id_chosen = 0.0
 SET order_doc_ind = 0
 SET stat = uar_get_meaning_by_codeset(333,"ORDERDOC",1,order_doc_cd)
 SET stat = uar_get_meaning_by_codeset(6003,"ORDER",1,order_cd)
 SET stat = uar_get_meaning_by_codeset(6003,"RENEW",1,renew_cd)
 SET stat = uar_get_meaning_by_codeset(6003,"ACTIVATE",1,activate_cd)
 SET stat = uar_get_meaning_by_codeset(6003,"MODIFY",1,modify_cd)
 SET stat = uar_get_meaning_by_codeset(6003,"RESUME",1,resume_cd)
 SET stat = uar_get_meaning_by_codeset(6003,"STUDACTIVATE",1,stud_activate_cd)
 DECLARE getdistributiondetails(null) = null WITH protect
 DECLARE getoperationdetails(null) = null WITH protect
 DECLARE validatedistributionqualificationforencounter(null) = null WITH protect
 DECLARE validateencounteractivityforreporttemplate(null) = null WITH protect
 DECLARE validatecrossencounterlawqualificationforperson(null) = null WITH protect
 DECLARE getproviderrelationship(null) = null WITH protect
 DECLARE getencounterdetails(null) = null WITH protect
 DECLARE getdistributionreporthistorybyencounter(null) = null WITH protect
 DECLARE getdistributionrundatetimes(null) = null WITH protect
 DECLARE getdistributionexecutiontimes(null) = null WITH protect
 DECLARE getdevicecrossreference(null) = null WITH protect
 DECLARE can_user_access_this_encounter(null) = i2 WITH protect
 DECLARE can_user_access_this_person(null) = i2 WITH protect
 DECLARE can_user_access_this_acc(null) = i2 WITH protect
 DECLARE display_invalid_logical_domain_message(null) = null WITH protect
 DECLARE getdestinationroutingassociations(null) = null WITH protect
 SELECT INTO "nl:"
  d.info_number
  FROM dm_info d
  WHERE d.info_domain="CLINICAL REPORTING XR"
   AND d.info_name="Enable Logical Domain XR Dist"
  HEAD REPORT
   is_logical_domain_enabled_ind = d.info_number
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  p.logical_domain_id
  FROM prsnl p
  WHERE (p.person_id=reqinfo->updt_id)
  DETAIL
   personnel_logical_domain_id = p.logical_domain_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  ld.logical_domain_id
  FROM logical_domain ld
  WHERE ld.active_ind=1
  WITH nocounter
 ;end select
 IF (curqual > 1)
  SET multitenancy = 1
 ENDIF
 FREE RECORD pass_rec
 RECORD pass_rec(
   1 qual[*]
     2 pass = i2
     2 get_out = i2
 )
 SET stat = alterlist(pass_rec->qual,6)
 FOR (x = 1 TO 6)
   SET pass_rec->qual[x].pass = 1
 ENDFOR
 FREE RECORD enc_hist_pass_rec
 RECORD enc_hist_pass_rec(
   1 qual[*]
     2 loc_facility = i2
     2 loc_facility_passed = i2
     2 loc_building = i2
     2 loc_building_passed = i2
     2 loc_nurse_unit = i2
     2 loc_nurse_unit_passed = i2
     2 loc_room = i2
     2 loc_room_passed = i2
     2 loc_bed = i2
     2 loc_bed_passed = i2
     2 med_service = i2
     2 med_service_passed = i2
     2 encntr_type = i2
     2 encntr_type_passed = i2
     2 organization = i2
     2 organization_passed = i2
     2 dist_type = i2
     2 provider = i2
     2 provider_pass_ind = i2
 )
 DECLARE size1 = i4
 DECLARE size2 = i4
 DECLARE size3 = i4
 DECLARE size4 = i4
 DECLARE size5 = i4
 DECLARE size6 = i4
 DECLARE size_1 = i4
 DECLARE size_2 = i4
 DECLARE size_3 = i4
 DECLARE size_4 = i4
 DECLARE size_5 = i4
 DECLARE size_6 = i4
 DECLARE encounter_type_include = i2
 DECLARE organization_include = i2
 DECLARE providers_include = i2
 DECLARE location_include = i2
 DECLARE med_service_include = i2
 DECLARE contributor_sys_include = i2
 FREE RECORD encntr_type_chosen
 RECORD encntr_type_chosen(
   1 qual[*]
     2 encntr_type_cd = f8
 )
 FREE RECORD org_id_chosen
 RECORD org_id_chosen(
   1 qual[*]
     2 org_id = f8
 )
 FREE RECORD location_chosen
 RECORD location_chosen(
   1 qual[*]
     2 location_cd = f8
 )
 FREE RECORD prov_id_chosen
 RECORD prov_id_chosen(
   1 qual[*]
     2 prov_id = f8
     2 prov_type_qual[*]
       3 prov_type_cd = f8
 )
 FREE RECORD assigned_prov_rec
 RECORD assigned_prov_rec(
   1 qual[*]
     2 provider_id = f8
     2 provider_type_qual[*]
       3 provider_type_cd = f8
 )
 FREE RECORD med_service_chosen
 RECORD med_service_chosen(
   1 qual[*]
     2 medical_service_cd = f8
 )
 FREE RECORD included_rec
 RECORD included_rec(
   1 qual[*]
     2 included_flag = i2
 )
 SET stat = alterlist(included_rec->qual,6)
 FOR (x = 1 TO 6)
   SET included_rec->qual[x].included_flag = 99
 ENDFOR
 FREE RECORD location_rec
 RECORD location_rec(
   1 qual[*]
     2 location_cd = f8
 )
 FREE RECORD encntr_hist_rec
 RECORD encntr_hist_loc_rec(
   1 qual[*]
     2 loc_facility_cd = f8
     2 loc_building_cd = f8
     2 loc_nurse_unit_cd = f8
     2 loc_room_cd = f8
     2 loc_bed_cd = f8
     2 med_service_cd = f8
     2 encntr_type_cd = f8
     2 organization_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
 )
 FREE RECORD encntr_prsnl_rec
 RECORD encntr_prsnl_rec(
   1 qual[*]
     2 prsnl_person_id = f8
     2 encntr_prsnl_r_cd = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
 )
 FREE RECORD person_prsnl_rec
 RECORD person_prsnl_rec(
   1 qual[*]
     2 prsnl_person_id = f8
     2 person_prsnl_r_cd = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
 )
 FREE RECORD dist_encounter_types
 RECORD dist_encounter_types(
   1 qual[*]
     2 encounter_type_cd = f8
     2 encounter_type_cd_desc = vc
 )
 FREE RECORD dist_org_ids
 RECORD dist_org_ids(
   1 qual[*]
     2 org_id = f8
     2 org_desc = vc
 )
 FREE RECORD dist_providers
 RECORD dist_providers(
   1 qual[*]
     2 provider_id = f8
     2 reltn_type_cd = f8
     2 provider_name = vc
 )
 FREE RECORD dist_locations
 RECORD dist_locations(
   1 qual[*]
     2 location_cd = f8
     2 loc_cd_desc = vc
 )
 FREE RECORD dist_med_services
 RECORD dist_med_services(
   1 qual[*]
     2 med_service_cd = f8
     2 med_service_cd_desc = vc
 )
 FREE RECORD dist_contrib_system
 RECORD dist_contrib_system(
   1 qual[*]
     2 contributor_system_cd = f8
     2 contributor_system_cd_desc = vc
 )
 SET meaning = fillstring(50,"")
 SET operations_id_chosen = 0.0
 SET meaning = fillstring(50,"")
 SET max_param_size = 0
 DECLARE cutoff_and_or_ind_text = c5
 DECLARE p_1 = vc
 DECLARE p_1_meaning = vc
 DECLARE p_2 = vc
 DECLARE p_2_meaning = vc
 DECLARE p_3 = vc
 DECLARE p_3_meaning = vc
 DECLARE p_4 = vc
 DECLARE p_4_meaning = vc
 DECLARE p_5 = vc
 DECLARE p_5_meaning = vc
 DECLARE p_6_display_cnt = i4
 DECLARE p_6_has_doc_author = i2
 DECLARE p_6_has_doc_reviewer = i2
 DECLARE p_7 = vc
 DECLARE p_7_meaning = vc
 DECLARE p_8 = vc
 DECLARE p_8_meaning = vc
 DECLARE p_9 = vc
 DECLARE p_9_meaning = vc
 DECLARE p_10 = vc
 DECLARE p_10_meaning = vc
 DECLARE p_25 = vc
 DECLARE p_25_meaning = vc
 DECLARE p_12_display_cnt = i4
 DECLARE p_13_display_cnt = i4
 DECLARE p_14 = vc
 DECLARE p_14_meaning = vc
 DECLARE p_15 = vc
 DECLARE p_15_meaning = vc
 DECLARE p_16 = vc
 DECLARE p_16_meaning = vc
 DECLARE p_17 = vc
 DECLARE p_18 = vc
 DECLARE p_18_meaning = vc
 DECLARE p_19 = vc
 DECLARE p_19_meaning = vc
 DECLARE p_20 = vc
 DECLARE p_20_meaning = vc WITH noconstant("")
 DECLARE p_21 = vc
 DECLARE p_21_meaning = vc
 DECLARE p_22 = vc
 DECLARE p_22_meaning = vc
 DECLARE p_23 = vc
 DECLARE p_23_meaning = vc
 DECLARE p_24 = vc
 DECLARE p_6_value = vc
 DECLARE p_12_value = vc
 DECLARE p_13_value = vc
 FREE RECORD prov_routing
 RECORD prov_routing(
   1 qual[*]
     2 prov_id = f8
     2 prov_name = vc
 )
 SET p_6_cnt = 0
 SET p_6_has_doc_author = 0
 SET p_6_has_doc_reviewer = 0
 SET p_10_cnt = 0
 SET p_12_cnt = 0
 SET p_13_cnt = 0
 FREE RECORD p_6_display
 RECORD p_6_display(
   1 qual[*]
     2 p6_cd = f8
     2 p6_display = vc
 )
 FREE RECORD p_12_display
 RECORD p_12_display(
   1 qual[*]
     2 p12_cd = f8
     2 p12_display = vc
 )
 FREE RECORD p_13_display
 RECORD p_13_display(
   1 qual[*]
     2 p13_cd = f8
     2 p13_display = vc
 )
 SET enc_prsnl_cnt = 0
 FREE RECORD enc_prsnl_rec
 RECORD enc_prsnl_rec(
   1 qual[*]
     2 prsnl_person_id = f8
     2 reltn_cd = vc
     2 prsnl_name = vc
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
 )
 SET pers_prsnl_cnt = 0
 FREE RECORD pers_prsnl_rec
 RECORD pers_prsnl_rec(
   1 qual[*]
     2 prsnl_person_id = f8
     2 reltn_cd = vc
     2 prsnl_name = vc
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
 )
 SET consulting_prsnl_cnt = 0
 FREE RECORD consulting_prsnl_rec
 RECORD consulting_prsnl_rec(
   1 qual[*]
     2 prsnl_person_id = f8
     2 prsnl_name = vc
     2 reltn_cd = vc
     2 order_id = f8
 )
 SET ordering_prsnl_cnt = 0
 FREE RECORD ordering_prsnl_rec
 RECORD ordering_prsnl_rec(
   1 qual[*]
     2 prsnl_person_id = f8
     2 prsnl_name = vc
     2 reltn_cd = vc
     2 order_id = f8
 )
 FREE RECORD distrun
 RECORD distrun(
   1 qual[*]
     2 count = i4
     2 server_name = vc
 )
 FREE RECORD ops_job_rec
 RECORD ops_job_rec(
   1 qual[*]
     2 ops_job_id = f8
     2 ops_batch_name = vc
     2 ops_job_params[*]
       3 param_1 = f8
       3 param_2 = f8
       3 param_3 = f8
       3 param_4 = f8
       3 param_6 = f8
       3 param_7 = f8
       3 param_8 = f8
       3 param_9 = f8
       3 param_10 = f8
       3 param_14 = f8
       3 param_15 = f8
       3 param_16 = f8
       3 param_17 = f8
 )
 SET distinct_cnt = 0
 SELECT DISTINCT INTO "nl:"
  co.charting_operations_id
  FROM charting_operations co
  WHERE co.active_ind=1
  HEAD REPORT
   do_nothing = 0
  DETAIL
   distinct_cnt += 1
  WITH nocounter
 ;end select
 FOR (x = 1 TO distinct_cnt)
   SET stat = alterlist(ops_job_rec->qual,x)
   SET ops_job_rec->qual[x].ops_job_id = 99
   SET stat = alterlist(ops_job_rec->qual[x].ops_job_params,1)
   SET ops_job_rec->qual[x].ops_job_params[1].param_1 = 99
   SET ops_job_rec->qual[x].ops_job_params[1].param_2 = 99
   SET ops_job_rec->qual[x].ops_job_params[1].param_3 = 99
   SET ops_job_rec->qual[x].ops_job_params[1].param_4 = 99
   SET ops_job_rec->qual[x].ops_job_params[1].param_6 = 99
   SET ops_job_rec->qual[x].ops_job_params[1].param_7 = 99
   SET ops_job_rec->qual[x].ops_job_params[1].param_8 = 99
   SET ops_job_rec->qual[x].ops_job_params[1].param_9 = 99
   SET ops_job_rec->qual[x].ops_job_params[1].param_10 = 99
   SET ops_job_rec->qual[x].ops_job_params[1].param_14 = 99
   SET ops_job_rec->qual[x].ops_job_params[1].param_15 = 99
   SET ops_job_rec->qual[x].ops_job_params[1].param_16 = 99
   SET ops_job_rec->qual[x].ops_job_params[1].param_17 = 99
 ENDFOR
 FREE RECORD error_rec
 RECORD error_rec(
   1 error_qual[*]
     2 error_ops_id = f8
     2 error_batch_name = vc
     2 error_level = i2
     2 error_msg = c60
 )
 SET is_okay = 0
 SET get_out = 0
 SET size_returned = 0
 SET activity_type = 0
 SET last_dist_run_dt_tm_string = fillstring(20," ")
 FREE RECORD cp_encntr
 RECORD cp_encntr(
   1 encntr_list[*]
     2 encntr_id = f8
 )
#end_initialize
#start_initial_accepts
 SET message = window
 CALL clear(1,1)
 CALL video(n)
 CALL box(1,1,24,110)
 CALL text(2,30,"Distribution Assistance")
 CALL text(4,4,"1   View Distribution Details")
 CALL text(5,4,"2   View Operations Details")
 CALL text(6,4,"3   Validate Distribution Qualification for Encounter")
 CALL text(7,4,"4   Validate Encounter Activity with Report Template")
 CALL text(8,4,"5   Validate Cross-Encounter Law Qualification for Person")
 CALL text(9,4,"6   View Provider Relationship")
 CALL text(10,4,"7   View Encounter Details")
 CALL text(11,4,"8   View Distribution Report History by Encounter")
 CALL text(12,4,"9   View Distribution Log")
 CALL text(13,4,"10  View Distribution Run Date/Times")
 CALL text(14,4,"11  View Distribution Execution Times")
 CALL text(15,4,"12  View Destination Routing Associations (Clinical Reporting workflows)")
 CALL text(16,4,"13  View Device Cross-Reference (workflows outside of Clinical Reporting)")
 CALL text(20,4,"99  Exit.")
 CALL text(23,4,"Select Option ? ")
 CALL accept(23,23,"99;",99
  WHERE curaccept IN (01, 02, 03, 04, 05,
  06, 07, 08, 09, 10,
  11, 12, 13, 99))
 CALL clear(24,1)
 SET choice = curaccept
 EXECUTE FROM start_clear_screen TO end_clear_screen
 CASE (choice)
  OF 1:
   CALL getdistributiondetails(null)
  OF 2:
   CALL getoperationdetails(null)
  OF 3:
   CALL validatedistributionqualificationforencounter(null)
  OF 4:
   CALL validateencounteractivityforreporttemplate(null)
  OF 5:
   CALL validatecrossencounterlawqualificationforperson(null)
  OF 6:
   CALL getproviderrelationship(null)
  OF 7:
   CALL getencounterdetails(null)
  OF 8:
   CALL getdistributionreporthistorybyencounter(null)
  OF 9:
   EXECUTE cd_log_xr is_logical_domain_enabled_ind, personnel_logical_domain_id
  OF 10:
   CALL getdistributionrundatetimes(null)
  OF 11:
   CALL getdistributionexecutiontimes(null)
  OF 12:
   CALL getdestinationroutingassociations(null)
  OF 13:
   CALL getdevicecrossreference(null)
  OF 99:
   GO TO exit_script
 ENDCASE
 GO TO initialize
#end_initial_accepts
 SUBROUTINE getdistributiondetails(null)
   CALL clear(1,1)
   CALL box(2,1,23,110)
   CALL text(3,22,"*** View Distribution Details ***")
   CALL text(5,4,"Select a Distribution: ")
   CALL text(7,4,"SHIFT/F5 to see a list of distributions")
   DECLARE enc_type = vc WITH noconstant(" ")
   DECLARE organization = vc WITH noconstant(" ")
   DECLARE location = vc WITH noconstant(" ")
   DECLARE med_service = vc WITH noconstant(" ")
   DECLARE formatted_value = vc WITH noconstant(" ")
   DECLARE provider = vc WITH noconstant(" ")
   DECLARE contributor_system = vc WITH noconstant(" ")
   SET distribution_id_chosen = 0.0
   IF (is_logical_domain_enabled_ind=1)
    SET where_clause = build2(
     "cd.distribution_id > 0 and cd.active_ind = 1 and cd.logical_domain_id = personnel_logical_domain_id"
     )
   ELSE
    SET where_clause = build2("cd.distribution_id > 0 and cd.active_ind = 1")
   ENDIF
   SET help =
   SELECT DISTINCT INTO "nl:"
    cd.dist_descr
    FROM chart_distribution cd
    WHERE parser(where_clause)
    ORDER BY cnvtupper(cd.dist_descr)
    WITH nocounter
   ;end select
   CALL accept(8,4,"P(80);C")
   SET help = off
   SET distribution_name_chosen = trim(curaccept)
   SELECT DISTINCT INTO "nl:"
    FROM chart_distribution cd
    WHERE cd.dist_descr=distribution_name_chosen
    HEAD REPORT
     do_nothing = 0
    DETAIL
     distribution_id_chosen = cd.distribution_id
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM chart_dist_filter cdf
    WHERE cdf.distribution_id=distribution_id_chosen
    HEAD REPORT
     do_nothing = 0, encounter_type_include = 99, organization_include = 99,
     providers_include = 99, location_include = 99, med_service_include = 99,
     contributor_sys_include = 99
    DETAIL
     IF (cdf.type_flag=0)
      IF (cdf.included_flag=1)
       encounter_type_include = 1
      ELSE
       encounter_type_include = 0
      ENDIF
     ELSEIF (cdf.type_flag=1)
      IF (cdf.included_flag=1)
       organization_include = 1
      ELSE
       organization_include = 0
      ENDIF
     ELSEIF (cdf.type_flag=2)
      IF (cdf.included_flag=1)
       providers_include = 1
      ELSE
       providers_include = 0
      ENDIF
     ELSEIF (cdf.type_flag=3)
      IF (cdf.included_flag=1)
       location_include = 1
      ELSE
       location_include = 0
      ENDIF
     ELSEIF (cdf.type_flag=4)
      IF (cdf.included_flag=1)
       med_service_include = 1
      ELSE
       med_service_include = 0
      ENDIF
     ELSEIF (cdf.type_flag=5)
      IF (cdf.included_flag=1)
       contributor_sys_include = 1
      ELSE
       contributor_sys_include = 0
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM chart_dist_filter_value cdfv
    WHERE cdfv.distribution_id=distribution_id_chosen
    ORDER BY cnvtupper(cdfv.description)
    HEAD REPORT
     do_nothing = 0, dist_encounter_type_cnt = 0, dist_org_id_cnt = 0,
     dist_prov_cnt = 0, dist_location_cnt = 0, dist_med_service_cnt = 0,
     dist_contrib_sys_cnt = 0
    DETAIL
     IF (cdfv.type_flag=0)
      dist_encounter_type_cnt += 1, stat = alterlist(dist_encounter_types->qual,(
       dist_encounter_type_cnt+ 1)), dist_encounter_types->qual[dist_encounter_type_cnt].
      encounter_type_cd = cdfv.parent_entity_id,
      dist_encounter_types->qual[dist_encounter_type_cnt].encounter_type_cd_desc = cdfv.description
     ELSEIF (cdfv.type_flag=1)
      dist_org_id_cnt += 1, stat = alterlist(dist_org_ids->qual,(dist_org_id_cnt+ 1)), dist_org_ids->
      qual[dist_org_id_cnt].org_id = cdfv.parent_entity_id,
      dist_org_ids->qual[dist_org_id_cnt].org_desc = cdfv.description
     ELSEIF (cdfv.type_flag=2)
      dist_prov_cnt += 1, stat = alterlist(dist_providers->qual,(dist_prov_cnt+ 1)), dist_providers->
      qual[dist_prov_cnt].provider_id = cdfv.parent_entity_id,
      dist_providers->qual[dist_prov_cnt].reltn_type_cd = cdfv.reltn_type_cd, dist_providers->qual[
      dist_prov_cnt].provider_name = cdfv.description
     ELSEIF (cdfv.type_flag=3)
      dist_location_cnt += 1, stat = alterlist(dist_locations->qual,(dist_location_cnt+ 1)),
      dist_locations->qual[dist_location_cnt].location_cd = cdfv.parent_entity_id,
      dist_locations->qual[dist_location_cnt].loc_cd_desc = cdfv.description
     ELSEIF (cdfv.type_flag=4)
      dist_med_service_cnt += 1, stat = alterlist(dist_med_services->qual,(dist_med_service_cnt+ 1)),
      dist_med_services->qual[dist_med_service_cnt].med_service_cd = cdfv.parent_entity_id,
      dist_med_services->qual[dist_med_service_cnt].med_service_cd_desc = cdfv.description
     ELSEIF (cdfv.type_flag=5)
      dist_contrib_sys_cnt += 1, stat = alterlist(dist_contrib_system->qual,(dist_contrib_sys_cnt+ 1)
       ), dist_contrib_system->qual[dist_contrib_sys_cnt].contributor_system_cd = cdfv
      .parent_entity_id,
      dist_contrib_system->qual[dist_contrib_sys_cnt].contributor_system_cd_desc = cdfv.description
     ENDIF
    WITH nocounter
   ;end select
   SET size_1 = size(dist_encounter_types->qual,5)
   SET size_2 = size(dist_org_ids->qual,5)
   SET size_3 = size(dist_providers->qual,5)
   SET size_4 = size(dist_locations->qual,5)
   SET size_5 = size(dist_med_services->qual,5)
   SET size_6 = size(dist_contrib_system->qual,5)
   SET max_size = 0
   IF (size_1 > max_size)
    SET max_size = size_1
   ENDIF
   IF (size_2 > max_size)
    SET max_size = size_2
   ENDIF
   IF (size_3 > max_size)
    SET max_size = size_3
   ENDIF
   IF (size_4 > max_size)
    SET max_size = size_4
   ENDIF
   IF (size_5 > max_size)
    SET max_size = size_5
   ENDIF
   IF (size_6 > max_size)
    SET max_size = size_6
   ENDIF
   SELECT
    dist_descr = format(cd.dist_descr,"############################################;L"), reader_group
     = format(cd.reader_group,"###########################################;L"), updt_dt_tm = format(
     cd.updt_dt_tm,";;Q")
    FROM chart_distribution cd,
     chart_dist_filter_value cdfv
    PLAN (cd
     WHERE cd.distribution_id=distribution_id_chosen
      AND cd.active_ind=1)
     JOIN (cdfv
     WHERE cdfv.distribution_id=cd.distribution_id)
    ORDER BY cdfv.type_flag, cdfv.key_sequence
    HEAD REPORT
     linex = fillstring(130,"-"), row + 1, col 5,
     " * * DISTRIBUTION DETAILS * *", row + 2, col 2,
     "Distribution ID: ", col 50, cd.distribution_id,
     col 80, dist_descr, row + 1,
     col 2, "Update Date/Time: ", col 80,
     updt_dt_tm, row + 1, col 2,
     "Distribution Type: ", col 43, cd.dist_type,
     col 80
     IF (cd.dist_type=1)
      "Non-Discharged Only"
     ELSEIF (cd.dist_type=2)
      "Discharged Only"
     ELSE
      "Both"
     ENDIF
     row + 1, col 2, "Days Till Chart: ",
     col 71, cd.days_till_chart, row + 1,
     col 2, "Reader Group: ", col 80,
     reader_group, row + 1, col 2,
     "Cutoff Details:", cutoff_days_value = cd.cutoff_days, cutoff_pages_value = cd.cutoff_pages,
     cutoff_days = build2(cutoff_days_value," ","DAYS"), cutoff_pages = build2(cutoff_pages_value," ",
      "PAGES")
     IF (1=cd.cutoff_and_or_ind)
      cutoff_and_or_ind_text = "AND"
     ELSEIF (cd.cutoff_and_or_ind=2)
      cutoff_and_or_ind_text = "OR"
     ENDIF
     cutoff_details = build2(cutoff_days," ",cutoff_and_or_ind_text," ",cutoff_pages), col 70
     IF (cd.cutoff_and_or_ind > 0)
      cutoff_days, col + 1, cutoff_and_or_ind_text,
      col + 1, cutoff_pages
     ELSE
      ""
     ENDIF
     row + 1, col 2, "Advanced Lookback Options:",
     row + 1, col 4, "Initial distribution lookback:",
     max_lookback_dt_tm_str = format(cd.max_lookback_dt_tm,"@SHORTDATE"),
     first_qualification_dt_tm_str = format(cd.first_qualification_dt_tm,"@SHORTDATE"),
     absolute_qualification_dt_tm_str = format(cd.absolute_qualification_dt_tm,"@SHORTDATE")
     IF (cd.max_lookback_ind=0)
      col 80, "Date: ", col + 1,
      max_lookback_dt_tm_str
     ELSE
      col 70, cd.max_lookback_days, col + 1,
      "Days"
     ENDIF
     row + 1, col 4, "First Qualification Lookback:"
     IF (cd.print_lookback_ind=0)
      col 80, "Date: ", col + 1,
      first_qualification_dt_tm_str
     ELSEIF (cd.print_lookback_ind=2)
      col 80, "Patient admit date"
     ELSEIF (cd.print_lookback_ind=1)
      col 80, "Previous distribution run"
     ELSE
      col 71, cd.first_qualification_days, col + 1,
      "Days"
     ENDIF
     row + 1, col 4, "Absolute Lookback:"
     IF (cd.absolute_lookback_ind=0)
      col 80, "Date: ", col + 1,
      absolute_qualification_dt_tm_str
     ELSE
      col 71, cd.absolute_qualification_days, col + 1,
      "Days"
     ENDIF
     row + 3, col 1, linex,
     row + 1, col 1, "Encounter Type",
     col 30, "Organization", col 70,
     "Location", col 110, "Medical Service",
     row + 1
     IF (encounter_type_include=1)
      col 1, "(Include)"
     ELSEIF (encounter_type_include=0)
      col 1, "(Exclude)"
     ELSE
      col 1, " "
     ENDIF
     IF (organization_include=1)
      col 30, "(Include)"
     ELSEIF (organization_include=0)
      col 30, "(Exclude)"
     ELSE
      col 30, " "
     ENDIF
     IF (location_include=1)
      col 70, "(Include)"
     ELSEIF (location_include=0)
      col 70, "(Exclude)"
     ELSE
      col 70, " "
     ENDIF
     IF (med_service_include=1)
      col 110, "(Include)"
     ELSEIF (med_service_include=0)
      col 110, "(Exclude)"
     ELSE
      col 110, " "
     ENDIF
     row + 1, col 1, "**************",
     col 30, "**************", col 70,
     "**************", col 110, "**************",
     row + 1
    DETAIL
     do_nothing = 0
    FOOT REPORT
     FOR (x = 1 TO (max_size - 1))
       IF ((x <= (size_1 - 1)))
        enc_type = build(dist_encounter_types->qual[x].encounter_type_cd_desc,"(",format(
          dist_encounter_types->qual[x].encounter_type_cd,"############;L"),")"), col 1, enc_type
       ENDIF
       IF ((x <= (size_2 - 1)))
        organization = build(dist_org_ids->qual[x].org_desc,"(",format(dist_org_ids->qual[x].org_id,
          "############;L"),")"), col 30, organization
       ENDIF
       IF ((x <= (size_4 - 1)))
        location = build(dist_locations->qual[x].loc_cd_desc,"(",format(dist_locations->qual[x].
          location_cd,"############;L"),")"), col 70, location
       ENDIF
       IF ((x <= (size_5 - 1)))
        med_service = build(dist_med_services->qual[x].med_service_cd_desc,"(",format(
          dist_med_services->qual[x].med_service_cd,"############;L"),")"), col 110, med_service
       ENDIF
       row + 1
     ENDFOR
     row + 1, col 1, "Providers",
     col 70, "Results Contributor System", row + 1
     IF (providers_include=1)
      col 1, "(Include)"
     ELSEIF (providers_include=0)
      col 1, "(Exclude)"
     ELSE
      col 1, " "
     ENDIF
     IF (contributor_sys_include=1)
      col 70, "(Include)"
     ELSEIF (contributor_sys_include=0)
      col 70, "(Exclude)"
     ELSE
      col 70, " "
     ENDIF
     row + 1, col 1, "**************",
     col 70, "**************", row + 1
     FOR (x = 1 TO (max_size - 1))
       IF ((x <= (size_3 - 1)))
        provider_id = format(dist_providers->qual[x].provider_id,"############;L"), provider_reltn_cd
         = format(dist_providers->qual[x].reltn_type_cd,"############;L"), provider_reltn_desc =
        uar_get_code_display(dist_providers->qual[x].reltn_type_cd),
        provider = build(dist_providers->qual[x].provider_name,"(",provider_id,")"),
        provider_relation = build(provider_reltn_desc,"(",provider_reltn_cd,")"), formatted_value =
        build(provider,"-",provider_relation),
        col 1, formatted_value
       ENDIF
       IF ((x <= (size_6 - 1)))
        contributor_system = build(dist_contrib_system->qual[x].contributor_system_cd_desc,"(",format
         (dist_contrib_system->qual[x].contributor_system_cd,"############;L"),")"), col 70,
        contributor_system
       ENDIF
       row + 1
     ENDFOR
    WITH nocounter, maxcol = 300
   ;end select
 END ;Subroutine
 SUBROUTINE getoperationdetails(null)
   CALL clear(1,1)
   CALL box(2,1,23,110)
   CALL text(3,22,"*** View Operation Details ***")
   CALL text(5,4,"Choose an Operation: ")
   CALL text(7,4,"SHIFT/F5 to see a list of operations")
   IF (is_logical_domain_enabled_ind=1)
    SET where_clause = build2(
     "co.active_ind = 1 and co.charting_operations_id > 0 and co.logical_domain_id = personnel_logical_domain_id"
     )
   ELSE
    SET where_clause = build2("co.active_ind = 1 and co.charting_operations_id > 0")
   ENDIF
   SET help =
   SELECT DISTINCT INTO "nl:"
    co.batch_name
    FROM charting_operations co
    WHERE parser(where_clause)
    ORDER BY cnvtupper(co.batch_name)
    WITH nocounter
   ;end select
   CALL accept(8,4,"P(80);C")
   SET help = off
   SET operations_name_chosen = trim(curaccept)
   SELECT DISTINCT INTO "nl:"
    FROM charting_operations co
    WHERE co.batch_name=operations_name_chosen
     AND co.active_ind=1
    HEAD REPORT
     do_nothing = 0
    DETAIL
     operations_id_chosen = co.charting_operations_id
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    co.param
    FROM charting_operations co
    WHERE co.charting_operations_id=operations_id_chosen
     AND co.active_ind=1
    ORDER BY co.param_type_flag, co.param, co.sequence
    HEAD REPORT
     p_6_cnt = 0, p_6_has_doc_author = 0, p_6_has_doc_reviewer = 0,
     p_12_cnt = 0, p_13_cnt = 0
    DETAIL
     CASE (co.param_type_flag)
      OF 1:
       p_1 = co.param,
       IF (cnvtint(p_1)=4)
        p_1_meaning = "ACCESSION"
       ELSEIF (cnvtint(p_1)=2)
        p_1_meaning = "ENCOUNTER"
       ELSEIF (cnvtint(p_1)=5)
        p_1_meaning = "CROSS ENCOUNTER"
       ELSEIF (cnvtint(p_1)=1)
        p_1_meaning = "PERSON"
       ELSEIF (cnvtint(p_1)=6)
        p_1_meaning = "DOCUMENT"
       ENDIF
      OF 2:
       p_2 = co.param
      OF 3:
       p_3 = co.param
      OF 4:
       p_4 = co.param
      OF 6:
       IF (co.param="Author")
        p_6_has_doc_author = 1
       ELSEIF (co.param="Reviewer")
        p_6_has_doc_reviewer = 1
       ENDIF
       ,p_6_cnt += 1
      OF 7:
       p_7 = co.param,
       IF (cnvtint(p_7) IN (0, 1))
        p_7_meaning = "ON"
       ELSE
        p_7_meaning = "OFF"
       ENDIF
      OF 8:
       p_8 = co.param,
       IF (cnvtint(p_8)=1)
        p_8_meaning = "ON"
       ELSE
        p_8_meaning = "OFF"
       ENDIF
      OF 9:
       p_9 = co.param,
       IF (cnvtint(p_9)=0)
        p_9_meaning = "ASSIGNED DEVICE"
       ELSEIF (cnvtint(p_9)=1)
        p_9_meaning = "ORGANIZATION CLIENT"
       ELSEIF (cnvtint(p_9)=2)
        p_9_meaning = "PATIENT LOCATION"
       ELSEIF (cnvtint(p_9)=3)
        p_9_meaning = "ORDER LOCATION"
       ELSEIF (cnvtint(p_9)=4)
        p_9_meaning = "PATIENT LOCATION AT TIME OF ORDER"
       ELSEIF (cnvtint(p_9)=5)
        p_9_meaning = "COPIES TO PROVIDER TYPES"
       ENDIF
      OF 10:
       p_10 = co.param
      OF 12:
       p_12_cnt += 1
      OF 13:
       p_13_cnt += 1
      OF 14:
       p_14 = co.param
      OF 15:
       p_15 = co.param
      OF 16:
       p_16 = co.param,
       IF (cnvtint(p_16)=1)
        p_16_meaning = "ON"
       ELSE
        p_16_meaning = "OFF"
       ENDIF
      OF 17:
       p_17 = truncate_with_ellipsis(co.param,50)
      OF 18:
       p_18 = co.param
      OF 19:
       p_19 = co.param,
       IF (cnvtint(p_19)=0)
        p_19_meaning = "Original Ordering Physician"
       ELSEIF (cnvtint(p_19)=1)
        p_19_meaning = "Current Ordering Physician"
       ELSEIF (cnvtint(p_19)=2)
        p_19_meaning = "Original & Current Ordering Physician"
       ELSEIF (cnvtint(p_19)=3)
        p_19_meaning = "All Ordering Physician"
       ENDIF
      OF 20:
       p_20 = co.param,
       IF (cnvtint(p_20)=1)
        p_20_meaning = "Include"
       ELSEIF (((cnvtint(p_20)=2) OR (cnvtint(p_20)=3)) )
        p_20_meaning = "Exclude"
       ENDIF
      OF 21:
       p_21 = co.param
      OF 22:
       p_22 = co.param,
       IF (cnvtint(p_22)=1)
        p_22_meaning = "ON"
       ELSE
        p_22_meaning = "OFF"
       ENDIF
      OF 23:
       p_23 = co.param
      OF 24:
       p_24 = truncate_with_ellipsis(co.param,50)
      OF 25:
       p_25 = co.param
     ENDCASE
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    co.param_type_flag, code_value = cnvtreal(co.param), detail_display = uar_get_code_display(
     cnvtreal(co.param)),
    detail_display_sort = cnvtupper(uar_get_code_display(cnvtreal(co.param)))
    FROM charting_operations co
    WHERE co.param_type_flag IN (6, 12, 13)
     AND co.charting_operations_id=operations_id_chosen
     AND co.active_ind=1
     AND operator(co.param,"regexplike","^[1-9][0-9]+$")
    ORDER BY detail_display_sort, code_value
    HEAD REPORT
     stat = alterlist(p_6_display->qual,p_6_cnt), stat = alterlist(p_12_display->qual,p_12_cnt), stat
      = alterlist(p_13_display->qual,p_13_cnt),
     p_6_display_cnt = (p_6_has_doc_author+ p_6_has_doc_reviewer), p_12_display_cnt = 0,
     p_13_display_cnt = 0
    DETAIL
     IF (co.param_type_flag=6)
      p_6_display_cnt += 1, p_6_display->qual[p_6_display_cnt].p6_cd = code_value, p_6_display->qual[
      p_6_display_cnt].p6_display = detail_display
      IF (cnvtint(p_1)=4
       AND ((p_6_has_doc_author=1) OR (((p_6_has_doc_reviewer=1) OR (code_value=order_doc_cd)) )) )
       order_doc_ind = 1
      ENDIF
     ELSEIF (co.param_type_flag=12)
      p_12_display_cnt += 1, p_12_display->qual[p_12_display_cnt].p12_cd = code_value, p_12_display->
      qual[p_12_display_cnt].p12_display = detail_display
     ELSEIF (co.param_type_flag=13)
      p_13_display_cnt += 1, p_13_display->qual[p_13_display_cnt].p13_cd = code_value, p_13_display->
      qual[p_13_display_cnt].p13_display = detail_display
     ENDIF
    WITH nocounter
   ;end select
   DECLARE where_clause_ops_prsnl1 = vc WITH noconstant(" ")
   DECLARE where_clause_ops_prsnl2 = vc WITH noconstant(" ")
   SET where_clause_ops_prsnl1 =
"cop.charting_operations_id = operations_id_chosen or (cnvtint(p_20) = 3 and not (multitenancy = 1 and is_logical_domain_en\
abled_ind = 0) and cop.charting_operations_id = 0 and cop.charting_operations_prsnl_id != 0)\
"
   SET where_clause_ops_prsnl2 =
"p.person_id = cop.prsnl_id and p.active_ind = 1 and ((p.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3) and (p.end_ef\
fective_dt_tm > cnvtdatetime(curdate,curtime3) or p.end_effective_dt_tm = NULL)) or (cnvtint(p_20) = 3 and cop.charting_op\
erations_id = 0 and p.logical_domain_id = personnel_logical_domain_id))\
"
   IF (cnvtint(p_20) > 0)
    SELECT DISTINCT INTO "nl:"
     cop.prsnl_id
     FROM charting_operations_prsnl cop,
      prsnl p
     PLAN (cop
      WHERE parser(where_clause_ops_prsnl1))
      JOIN (p
      WHERE parser(where_clause_ops_prsnl2))
     ORDER BY cnvtupper(p.name_full_formatted)
     HEAD REPORT
      nbr = 0
     DETAIL
      nbr += 1
      IF (mod(nbr,10)=1)
       stat = alterlist(prov_routing->qual,(nbr+ 9))
      ENDIF
      prov_routing->qual[nbr].prov_id = cop.prsnl_id, prov_routing->qual[nbr].prov_name = p
      .name_full_formatted
     FOOT REPORT
      stat = alterlist(prov_routing->qual,nbr)
     WITH nocounter
    ;end select
   ENDIF
   SELECT DISTINCT INTO "nl:"
    FROM chart_distribution cd
    WHERE cd.distribution_id=cnvtreal(p_2)
    HEAD REPORT
     do_nothing = 0
    DETAIL
     p_2_meaning = cd.dist_descr
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE ((cv.code_value=cnvtreal(p_3)) OR (((cv.code_value=cnvtreal(p_14)) OR (cv.code_value=
    cnvtreal(p_15))) ))
    HEAD REPORT
     do_nothing = 0
    DETAIL
     IF (cv.code_set=22550)
      p_3_meaning = cv.display
     ELSEIF (cv.code_set=22549)
      p_14_meaning = cv.display
     ELSEIF (cv.code_set=22011)
      p_15_meaning = cv.display
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM cr_report_template crt
    WHERE crt.template_id=cnvtreal(p_4)
    HEAD REPORT
     do_nothing = 0
    DETAIL
     p_4_meaning = crt.template_name
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM output_dest od
    WHERE od.output_dest_cd=cnvtreal(p_10)
    HEAD REPORT
     do_nothing = 0
    DETAIL
     p_10_meaning = od.name
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM organization o
    WHERE o.organization_id=cnvtreal(p_25)
     AND o.active_ind=1
     AND o.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND o.end_effective_dt_tm >= cnvtdatetime(sysdate)
    HEAD REPORT
     do_nothing = 0
    DETAIL
     p_25_meaning = o.org_name
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM chart_route cr
    WHERE cr.chart_route_id=cnvtreal(p_21)
    HEAD REPORT
     do_nothing = 0
    DETAIL
     p_21_meaning = cr.route_name
    WITH nocounter
   ;end select
   SELECT DISTINCT INTO "nl:"
    FROM chart_law cl
    WHERE cl.law_id=cnvtreal(p_18)
    HEAD REPORT
     do_nothing = 0
    DETAIL
     p_18_meaning = cl.law_descr
    WITH nocounter
   ;end select
   SELECT DISTINCT INTO "nl:"
    FROM cr_mask cm
    WHERE cm.cr_mask_id=cnvtreal(p_23)
    HEAD REPORT
     do_nothing = 0
    DETAIL
     p_23_meaning = truncate_with_ellipsis(cm.cr_mask_text,60)
    WITH nocounter
   ;end select
   IF (p_6_cnt > max_param_size)
    SET max_param_size = p_6_cnt
   ENDIF
   IF (p_12_cnt > max_param_size)
    SET max_param_size = p_12_cnt
   ENDIF
   IF (p_13_cnt > max_param_size)
    SET max_param_size = p_13_cnt
   ENDIF
   SELECT INTO "mine"
    batch_name = substring(1,20,co.batch_name), updt_dt_tm = format(co.updt_dt_tm,";;Q")
    FROM charting_operations co
    WHERE co.charting_operations_id=operations_id_chosen
     AND co.active_ind=1
    ORDER BY co.param_type_flag, co.sequence
    HEAD REPORT
     linex = fillstring(130,"-"), row + 1, col 5,
     " * * OPERATIONS DETAILS * *", row + 2, col 2,
     "Operation: ", col 35, operations_id_chosen,
     col 65, batch_name, row + 1,
     col 2, "Update Date/Time: ", col 40,
     updt_dt_tm, row + 2, col 2,
     "#1 - Scope: ", col 40, p_1,
     col 65, p_1_meaning, row + 1,
     col 2, "#2 - Associated Distribution: ", col 40,
     p_2, col 65, p_2_meaning,
     row + 1, col 2, "#3 - Run Type: ",
     col 40, p_3, col 65,
     p_3_meaning, row + 1, col 2,
     "#4 - Report Template: ", val = size(trim(p_4_meaning),1)
     IF (val > 0)
      col 40, p_4, col 65,
      p_4_meaning
     ELSE
      col 40, "This operation is associated to a chart format"
     ENDIF
     row + 1, col 2, "#7 - Verified Only: ",
     col 40, p_7, col 65,
     p_7_meaning, row + 1, col 2,
     "#9 - Route Destination: ", col 40, p_9,
     col 65, p_9_meaning, row + 1,
     col 2, "#10 - Default Device: ", col 40,
     p_10, col 65, p_10_meaning,
     row + 1, col 2, "#25 - Sending Organization: ",
     col 40, p_25, col 65,
     p_25_meaning, row + 1, col 2,
     "#15 - Sort Sequence: ", col 40, p_15,
     col 65, p_15_meaning, row + 1,
     col 2, "#21 - Chart Route: ", col 40,
     p_21, col 65, p_21_meaning,
     row + 1, col 2, "#16 - Default Chart: ",
     col 40, p_16, col 65,
     p_16_meaning, row + 1, col 2,
     "#22 - Exclude Expired Relationships: ", col 40, p_22,
     col 65, p_22_meaning, row + 1,
     col 2, "#18 - Associated Law: ", col 40,
     p_18, col 65, p_18_meaning,
     row + 1, col 2, "#14 - File Storage: ",
     col 40, p_14, col 65,
     p_14_meaning, row + 1, col 2,
     "#23 - Filename Mask: ", col 40, p_23,
     col 65, p_23_meaning, row + 1,
     col 2, "#17 - Network File Destination Path: ", col 40,
     p_17, row + 1, col 2,
     "#24 - FTP Destination Path: ", col 40, p_24
     IF (order_doc_ind=1)
      row + 1, col 2, "#19 - Ordering Physician Copy: ",
      col 40, p_19, col 65,
      p_19_meaning
     ENDIF
     row + 3, col 1, linex,
     row + 1, col 5, "#6 - Provider Relationships",
     col 40, "#12 - Activity Hold", col 75,
     "#13 - Order Status Hold", row + 1, col 5,
     "***********************", col 40, "*******************",
     col 75, "***********************", row + 1
    DETAIL
     do_nothing = 0
    FOOT REPORT
     FOR (x = 1 TO max_param_size)
       IF (x <= p_6_cnt
        AND p_6_cnt > 0)
        IF ((x <= (p_6_has_doc_author+ p_6_has_doc_reviewer)))
         IF (p_6_has_doc_author=1
          AND x=1)
          col 5, "Author"
         ELSE
          col 5, "Reviewer"
         ENDIF
        ELSEIF ((p_6_display->qual[x].p6_cd != 0))
         p_6_value = build(p_6_display->qual[x].p6_display,"(",format(p_6_display->qual[x].p6_cd,";L"
           ),")"), col 5, p_6_value
        ENDIF
       ENDIF
       IF (x <= p_12_cnt
        AND p_12_cnt > 0
        AND (p_12_display->qual[x].p12_cd != 0))
        p_12_value = build(p_12_display->qual[x].p12_display,"(",format(p_12_display->qual[x].p12_cd,
          ";L"),")"), col 40, p_12_value
       ENDIF
       IF (x <= p_13_cnt
        AND p_13_cnt > 0
        AND (p_13_display->qual[x].p13_cd != 0))
        p_13_value = build(p_13_display->qual[x].p13_display,"(",format(p_13_display->qual[x].p13_cd,
          ";L"),")"), col 75, p_13_value
       ENDIF
       row + 1
     ENDFOR
     row + 1
     IF (cnvtint(p_20) > 0)
      providers_selected_cnt = size(prov_routing->qual,5), p_20_meaning_value = build("(",
       p_20_meaning,")"), col 5,
      "#20 - Specific Providers", row + 1, col 5,
      p_20_meaning_value, row + 1, col 5,
      "*********************************"
      FOR (x = 1 TO providers_selected_cnt)
        provider_value = build(prov_routing->qual[x].prov_name,"(",format(prov_routing->qual[x].
          prov_id,"############;L"),")"), row + 1, col 5,
        provider_value
      ENDFOR
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE validatedistributionqualificationforencounter(null)
   CALL clear(1,1)
   CALL box(2,1,23,110)
   CALL text(3,22,"*** Validate Distribution Qualification for Encounter  ***")
   CALL text(5,4,"Enter an Encntr_id: ")
   CALL accept(5,30,"P(40);Cf"," ")
   SET encntr_id_chosen = cnvtreal(curaccept)
   IF (can_user_access_this_encounter(null)=1)
    SET distribution_id_chosen = 0.0
    CALL text(9,4,"SHIFT/F5 to see a list of distributions")
    IF (is_logical_domain_enabled_ind=1)
     SET where_clause = build2(
      "cd.distribution_id > 0 and cd.active_ind = 1 and cd.logical_domain_id = personnel_logical_domain_id"
      )
    ELSE
     SET where_clause = build2("cd.distribution_id > 0 and cd.active_ind = 1")
    ENDIF
    SET help =
    SELECT DISTINCT INTO "nl:"
     cd.dist_descr
     FROM chart_distribution cd
     WHERE parser(where_clause)
     ORDER BY cnvtupper(cd.dist_descr)
     WITH nocounter
    ;end select
    CALL accept(10,4,"P(80);C")
    SET help = off
    SET distribution_name_chosen = trim(curaccept)
    SELECT DISTINCT INTO "nl:"
     FROM chart_distribution cd
     WHERE cd.dist_descr=distribution_name_chosen
     HEAD REPORT
      do_nothing = 0
     DETAIL
      distribution_id_chosen = cd.distribution_id
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM encounter e
     WHERE e.encntr_id=encntr_id_chosen
     HEAD REPORT
      is_okay = 0
     DETAIL
      is_okay = 1
     WITH nocounter
    ;end select
    IF (is_okay > 0)
     SELECT INTO "nl:"
      FROM chart_distribution cd
      WHERE cd.distribution_id=distribution_id_chosen
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      e.loc_facility_cd, e.loc_building_cd, e.loc_nurse_unit_cd,
      e.loc_room_cd, e.loc_bed_cd
      FROM encounter e
      WHERE e.encntr_id=encntr_id_chosen
      HEAD REPORT
       location_cnt = 0
      DETAIL
       IF (e.loc_facility_cd > 0)
        stat = alterlist(location_rec->qual,(location_cnt+ 1)), location_cnt += 1, location_rec->
        qual[location_cnt].location_cd = e.loc_facility_cd
       ENDIF
       IF (e.loc_building_cd > 0)
        stat = alterlist(location_rec->qual,(location_cnt+ 1)), location_cnt += 1, location_rec->
        qual[location_cnt].location_cd = e.loc_building_cd
       ENDIF
       IF (e.loc_nurse_unit_cd > 0)
        stat = alterlist(location_rec->qual,(location_cnt+ 1)), location_cnt += 1, location_rec->
        qual[location_cnt].location_cd = e.loc_nurse_unit_cd
       ENDIF
       IF (e.loc_room_cd > 0)
        stat = alterlist(location_rec->qual,(location_cnt+ 1)), location_cnt += 1, location_rec->
        qual[location_cnt].location_cd = e.loc_room_cd
       ENDIF
       IF (e.loc_bed_cd > 0)
        stat = alterlist(location_rec->qual,(location_cnt+ 1)), location_cnt += 1, location_rec->
        qual[location_cnt].location_cd = e.loc_bed_cd
       ENDIF
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      elh.loc_facility_cd, elh.loc_building_cd, elh.loc_nurse_unit_cd,
      elh.loc_room_cd, elh.loc_bed_cd, elh.med_service_cd,
      elh.encntr_type_cd, elh.organization_id, elh.beg_effective_dt_tm,
      elh.end_effective_dt_tm
      FROM encntr_loc_hist elh
      WHERE elh.encntr_id=encntr_id_chosen
      ORDER BY elh.beg_effective_dt_tm, elh.end_effective_dt_tm
      HEAD REPORT
       do_nothing = 0, stat = alterlist(encntr_hist_loc_rec->qual,10), hist_count = 0
      DETAIL
       hist_count += 1
       IF (mod(hist_count,10)=1
        AND hist_count > 10)
        stat = alterlist(encntr_hist_loc_rec->qual,(hist_count+ 9))
       ENDIF
       encntr_hist_loc_rec->qual[hist_count].loc_facility_cd = elh.loc_facility_cd,
       encntr_hist_loc_rec->qual[hist_count].loc_building_cd = elh.loc_building_cd,
       encntr_hist_loc_rec->qual[hist_count].loc_nurse_unit_cd = elh.loc_nurse_unit_cd,
       encntr_hist_loc_rec->qual[hist_count].loc_room_cd = elh.loc_room_cd, encntr_hist_loc_rec->
       qual[hist_count].loc_bed_cd = elh.loc_bed_cd, encntr_hist_loc_rec->qual[hist_count].
       med_service_cd = elh.med_service_cd,
       encntr_hist_loc_rec->qual[hist_count].encntr_type_cd = elh.encntr_type_cd, encntr_hist_loc_rec
       ->qual[hist_count].organization_id = elh.organization_id, encntr_hist_loc_rec->qual[hist_count
       ].beg_effective_dt_tm = elh.beg_effective_dt_tm,
       encntr_hist_loc_rec->qual[hist_count].end_effective_dt_tm = elh.end_effective_dt_tm
      FOOT REPORT
       stat = alterlist(encntr_hist_loc_rec->qual,hist_count)
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      FROM chart_dist_filter_value cdfv
      WHERE cdfv.distribution_id=distribution_id_chosen
      ORDER BY cdfv.type_flag, cdfv.key_sequence
      HEAD REPORT
       encntr_type_cd_cnt = 0, org_id_cnt = 0, prov_id_cnt = 0,
       location_chosen_cnt = 0, med_service_cnt = 0, prov_type_cnt = 0
      HEAD cdfv.parent_entity_id
       IF (cdfv.type_flag=2)
        prov_id_cnt += 1, stat = alterlist(prov_id_chosen->qual,prov_id_cnt), prov_id_chosen->qual[
        prov_id_cnt].prov_id = cdfv.parent_entity_id
       ENDIF
      DETAIL
       IF (cdfv.type_flag=0)
        stat = alterlist(encntr_type_chosen->qual,(encntr_type_cd_cnt+ 1)), encntr_type_cd_cnt += 1,
        encntr_type_chosen->qual[encntr_type_cd_cnt].encntr_type_cd = cdfv.parent_entity_id
       ELSEIF (cdfv.type_flag=1)
        stat = alterlist(org_id_chosen->qual,(org_id_cnt+ 1)), org_id_cnt += 1, org_id_chosen->qual[
        org_id_cnt].org_id = cdfv.parent_entity_id
       ELSEIF (cdfv.type_flag=2)
        prov_type_cnt += 1, stat = alterlist(prov_id_chosen->qual[prov_id_cnt].prov_type_qual,
         prov_type_cnt), prov_id_chosen->qual[prov_id_cnt].prov_type_qual[prov_type_cnt].prov_type_cd
         = cdfv.reltn_type_cd
       ELSEIF (cdfv.type_flag=3)
        stat = alterlist(location_chosen->qual,(location_chosen_cnt+ 1)), location_chosen_cnt += 1,
        location_chosen->qual[location_chosen_cnt].location_cd = cdfv.parent_entity_id
       ELSEIF (cdfv.type_flag=4)
        stat = alterlist(med_service_chosen->qual,(med_service_cnt+ 1)), med_service_cnt += 1,
        med_service_chosen->qual[med_service_cnt].medical_service_cd = cdfv.parent_entity_id
       ENDIF
      WITH nocounter
     ;end select
     SELECT DISTINCT INTO "nl:"
      dist_type = cd.dist_type
      FROM chart_distribution cd,
       encounter e
      PLAN (cd
       WHERE cd.distribution_id=distribution_id_chosen)
       JOIN (e
       WHERE e.encntr_id=encntr_id_chosen)
      ORDER BY cd.distribution_id
      HEAD REPORT
       pass_rec->qual[1].pass = 1, pass_rec->qual[1].get_out = 0, linex = fillstring(130,"-")
      DETAIL
       IF (dist_type=1)
        IF (e.disch_dt_tm > cnvtdatetime("01-jan-1800")
         AND (pass_rec->qual[1].get_out=0))
         pass_rec->qual[1].pass = 0, pass_rec->qual[1].get_out = 1
        ELSE
         pass_rec->qual[1].pass = 1, pass_rec->qual[1].get_out = 1
        ENDIF
       ELSEIF (dist_type=2)
        IF (e.disch_dt_tm > cnvtdatetime("01-jan-1800")
         AND (pass_rec->qual[1].get_out=0))
         pass_rec->qual[1].pass = 1, pass_rec->qual[1].get_out = 1
        ELSE
         pass_rec->qual[1].pass = 0, pass_rec->qual[1].get_out = 1
        ENDIF
       ELSEIF (dist_type=3)
        pass_rec->qual[1].pass = 1, pass_rec->qual[1].get_out = 1
       ENDIF
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      FROM chart_dist_filter cdf
      WHERE cdf.distribution_id=distribution_id_chosen
      ORDER BY cdf.type_flag
      HEAD REPORT
       included_rec->qual[1].included_flag = 99, included_rec->qual[2].included_flag = 99,
       included_rec->qual[3].included_flag = 99,
       included_rec->qual[4].included_flag = 99, included_rec->qual[5].included_flag = 99
      DETAIL
       IF (cdf.type_flag=0)
        IF (cdf.included_flag=1)
         included_rec->qual[1].included_flag = 1
        ELSE
         included_rec->qual[1].included_flag = 0
        ENDIF
       ELSEIF (cdf.type_flag=1)
        IF (cdf.included_flag=1)
         included_rec->qual[2].included_flag = 1
        ELSE
         included_rec->qual[2].included_flag = 0
        ENDIF
       ELSEIF (cdf.type_flag=2)
        IF (cdf.included_flag=1)
         included_rec->qual[3].included_flag = 1
        ELSE
         included_rec->qual[3].included_flag = 0
        ENDIF
       ELSEIF (cdf.type_flag=3)
        IF (cdf.included_flag=1)
         included_rec->qual[4].included_flag = 1
        ELSE
         included_rec->qual[4].included_flag = 0
        ENDIF
       ELSEIF (cdf.type_flag=4)
        IF (cdf.included_flag=1)
         included_rec->qual[5].included_flag = 1
        ELSE
         included_rec->qual[5].included_flag = 0
        ENDIF
       ENDIF
      WITH nocounter
     ;end select
     SET size_relationships = 0
     SET size_providers = 0
     SET size_providers = size(prov_id_chosen->qual,5)
     SET person_id_chosen = 0.0
     SELECT INTO "nl:"
      e.person_id
      FROM encounter e
      WHERE e.encntr_id=encntr_id_chosen
      HEAD REPORT
       do_nothing = 0
      DETAIL
       person_id_chosen = e.person_id
      WITH nocounter
     ;end select
     IF (size_providers > 0)
      FREE RECORD parser1
      RECORD parser1(
        1 qual[*]
          2 statement = vc
      )
      SET cnt_qualify = 0
      SET p_index = 0
      SET p_index += 1
      SET stat = alterlist(parser1->qual,p_index)
      SET parser1->qual[p_index].statement =
      ' select into "nl:" epr.encntr_id from encntr_prsnl_reltn epr'
      SET p_index += 1
      SET stat = alterlist(parser1->qual,p_index)
      SET parser1->qual[p_index].statement = " plan epr where epr.encntr_id = encntr_id_chosen and"
      SET p_index += 1
      SET stat = alterlist(parser1->qual,p_index)
      SET parser1->qual[p_index].statement = build(" epr.active_ind = 1 and ",
       " epr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3) and ")
      SET p_index += 1
      SET stat = alterlist(parser1->qual,p_index)
      SET parser1->qual[p_index].statement =
      " epr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3) and ("
      FOR (x = 1 TO size_providers)
        SET size_relationships = size(prov_id_chosen->qual[x].prov_type_qual,5)
        SET p_index += 1
        SET stat = alterlist(parser1->qual,p_index)
        SET parser1->qual[p_index].statement = build("(epr.prsnl_person_id = ",prov_id_chosen->qual[x
         ].prov_id," and epr.encntr_prsnl_r_cd in (",prov_id_chosen->qual[x].prov_type_qual[1].
         prov_type_cd)
        IF (size_relationships=1)
         SET p_index += 1
         SET stat = alterlist(parser1->qual,p_index)
         SET parser1->qual[p_index].statement = " ))"
        ENDIF
        IF (size_relationships > 1)
         FOR (y = 2 TO size_relationships)
           SET p_index += 1
           SET stat = alterlist(parser1->qual,p_index)
           SET parser1->qual[p_index].statement = build(",",prov_id_chosen->qual[x].prov_type_qual[y]
            .prov_type_cd)
           IF (y=size_relationships)
            SET p_index += 1
            IF (x=size_providers)
             SET stat = alterlist(parser1->qual,p_index)
             SET parser1->qual[p_index].statement = ")))"
            ELSE
             SET stat = alterlist(parser1->qual,p_index)
             SET parser1->qual[p_index].statement = "))"
             SET p_index += 1
             SET stat = alterlist(parser1->qual,p_index)
             SET parser1->qual[p_index].statement = " OR "
            ENDIF
           ENDIF
         ENDFOR
        ELSE
         IF (x=size_providers)
          SET p_index += 1
          SET stat = alterlist(parser1->qual,p_index)
          SET parser1->qual[p_index].statement = ")"
         ELSE
          SET p_index += 1
          SET stat = alterlist(parser1->qual,p_index)
          SET parser1->qual[p_index].statement = " OR "
         ENDIF
        ENDIF
      ENDFOR
      SET p_index += 1
      SET stat = alterlist(parser1->qual,(p_index+ 5))
      SET parser1->qual[p_index].statement = "HEAD REPORT"
      SET p_index += 1
      SET parser1->qual[p_index].statement = "  cnt_qualify = 0"
      SET p_index += 1
      SET parser1->qual[p_index].statement = "DETAIL"
      SET p_index += 1
      SET parser1->qual[p_index].statement = "  cnt_qualify = cnt_qualify + 1"
      SET p_index += 1
      SET parser1->qual[p_index].statement = "WITH nocounter go"
      FOR (x = 1 TO p_index)
        CALL echo(parser1->qual[x].statement)
      ENDFOR
      FOR (x = 1 TO p_index)
        CALL parser(parser1->qual[x].statement)
      ENDFOR
      FREE SET parser1
      FREE RECORD parser1
      RECORD parser1(
        1 qual[*]
          2 statement = vc
      )
      SET p_index = 0
      SET p_index += 1
      SET stat = alterlist(parser1->qual,p_index)
      SET parser1->qual[p_index].statement =
      ' select into "nl:" ppr.person_id from person_prsnl_reltn ppr'
      SET p_index += 1
      SET stat = alterlist(parser1->qual,p_index)
      SET parser1->qual[p_index].statement = " plan ppr where ppr.person_id = person_id_chosen and "
      SET p_index += 1
      SET stat = alterlist(parser1->qual,p_index)
      SET parser1->qual[p_index].statement = build(" ppr.active_ind = 1 and ",
       " ppr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3) and ")
      SET p_index += 1
      SET stat = alterlist(parser1->qual,p_index)
      SET parser1->qual[p_index].statement =
      " ppr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3) and ("
      FOR (x = 1 TO size_providers)
        SET size_relationships = size(prov_id_chosen->qual[x].prov_type_qual,5)
        SET p_index += 1
        SET stat = alterlist(parser1->qual,p_index)
        SET parser1->qual[p_index].statement = build("(ppr.prsnl_person_id = ",prov_id_chosen->qual[x
         ].prov_id," and ppr.person_prsnl_r_cd in (",prov_id_chosen->qual[x].prov_type_qual[1].
         prov_type_cd)
        IF (size_relationships=1)
         SET p_index += 1
         SET stat = alterlist(parser1->qual,p_index)
         SET parser1->qual[p_index].statement = " ))"
        ENDIF
        IF (size_relationships > 1)
         FOR (y = 2 TO size_relationships)
           SET p_index += 1
           SET stat = alterlist(parser1->qual,p_index)
           SET parser1->qual[p_index].statement = build(",",prov_id_chosen->qual[x].prov_type_qual[y]
            .prov_type_cd)
           IF (y=size_relationships)
            SET p_index += 1
            IF (x=size_providers)
             SET stat = alterlist(parser1->qual,p_index)
             SET parser1->qual[p_index].statement = ")))"
            ELSE
             SET stat = alterlist(parser1->qual,p_index)
             SET parser1->qual[p_index].statement = "))"
             SET p_index += 1
             SET stat = alterlist(parser1->qual,p_index)
             SET parser1->qual[p_index].statement = " OR "
            ENDIF
           ENDIF
         ENDFOR
        ELSE
         IF (x=size_providers)
          SET p_index += 1
          SET stat = alterlist(parser1->qual,p_index)
          SET parser1->qual[p_index].statement = ")"
         ELSE
          SET p_index += 1
          SET stat = alterlist(parser1->qual,p_index)
          SET parser1->qual[p_index].statement = " OR "
         ENDIF
        ENDIF
      ENDFOR
      SET p_index += 1
      SET stat = alterlist(parser1->qual,(p_index+ 5))
      SET parser1->qual[p_index].statement = "HEAD REPORT"
      SET p_index += 1
      SET parser1->qual[p_index].statement = "  do_nothing = 0"
      SET p_index += 1
      SET parser1->qual[p_index].statement = "DETAIL"
      SET p_index += 1
      SET parser1->qual[p_index].statement = "  cnt_qualify = cnt_qualify + 1"
      SET p_index += 1
      SET parser1->qual[p_index].statement = "WITH nocounter go"
      FOR (x = 1 TO p_index)
        CALL echo(parser1->qual[x].statement)
      ENDFOR
      FOR (x = 1 TO p_index)
        CALL parser(parser1->qual[x].statement)
      ENDFOR
      FREE SET parser1
      FREE RECORD parser1
      RECORD parser1(
        1 qual[*]
          2 statement = vc
      )
      SET p_index = 0
      SET p_index += 1
      SET stat = alterlist(parser1->qual,p_index)
      SET parser1->qual[p_index].statement =
      ' select into "nl:" opr.encntr_id from order_prsnl_reltn opr'
      SET p_index += 1
      SET stat = alterlist(parser1->qual,p_index)
      SET parser1->qual[p_index].statement = " plan opr where opr.encntr_id = encntr_id_chosen and ("
      FOR (x = 1 TO size_providers)
        SET size_relationships = size(prov_id_chosen->qual[x].prov_type_qual,5)
        SET p_index += 1
        SET stat = alterlist(parser1->qual,p_index)
        SET parser1->qual[p_index].statement = build("(opr.prsnl_person_id = ",prov_id_chosen->qual[x
         ].prov_id," and opr.chart_prsnl_r_type_cd in (",prov_id_chosen->qual[x].prov_type_qual[1].
         prov_type_cd)
        IF (size_relationships=1)
         SET p_index += 1
         SET stat = alterlist(parser1->qual,p_index)
         SET parser1->qual[p_index].statement = " ))"
        ENDIF
        IF (size_relationships > 1)
         FOR (y = 2 TO size_relationships)
           SET p_index += 1
           SET stat = alterlist(parser1->qual,p_index)
           SET parser1->qual[p_index].statement = build(",",prov_id_chosen->qual[x].prov_type_qual[y]
            .prov_type_cd)
           IF (y=size_relationships)
            SET p_index += 1
            IF (x=size_providers)
             SET stat = alterlist(parser1->qual,p_index)
             SET parser1->qual[p_index].statement = ")))"
            ELSE
             SET stat = alterlist(parser1->qual,p_index)
             SET parser1->qual[p_index].statement = "))"
             SET p_index += 1
             SET stat = alterlist(parser1->qual,p_index)
             SET parser1->qual[p_index].statement = " OR "
            ENDIF
           ENDIF
         ENDFOR
        ELSE
         IF (x=size_providers)
          SET p_index += 1
          SET stat = alterlist(parser1->qual,p_index)
          SET parser1->qual[p_index].statement = ")"
         ELSE
          SET p_index += 1
          SET stat = alterlist(parser1->qual,p_index)
          SET parser1->qual[p_index].statement = " OR "
         ENDIF
        ENDIF
      ENDFOR
      SET p_index += 1
      SET stat = alterlist(parser1->qual,(p_index+ 5))
      SET parser1->qual[p_index].statement = "HEAD REPORT"
      SET p_index += 1
      SET parser1->qual[p_index].statement = "  do_nothing = 0"
      SET p_index += 1
      SET parser1->qual[p_index].statement = "DETAIL"
      SET p_index += 1
      SET parser1->qual[p_index].statement = "  cnt_qualify = cnt_qualify + 1"
      SET p_index += 1
      SET parser1->qual[p_index].statement = "WITH nocounter go"
      FOR (x = 1 TO p_index)
        CALL echo(parser1->qual[x].statement)
      ENDFOR
      FOR (x = 1 TO p_index)
        CALL parser(parser1->qual[x].statement)
      ENDFOR
      CALL echo(build("cnt_qualify = ",cnt_qualify))
      IF ((included_rec->qual[3].included_flag=1))
       IF (cnt_qualify > 0)
        SET pass_rec->qual[4].pass = 1
        SET pass_rec->qual[4].get_out = 1
       ELSE
        SET pass_rec->qual[4].pass = 0
        SET pass_rec->qual[4].get_out = 1
       ENDIF
      ELSEIF ((included_rec->qual[3].included_flag=0))
       IF (cnt_qualify > 0)
        SET pass_rec->qual[4].pass = 0
        SET pass_rec->qual[4].get_out = 1
       ELSE
        SET pass_rec->qual[4].pass = 1
        SET pass_rec->qual[4].get_out = 1
       ENDIF
      ELSEIF ( NOT ((included_rec->qual[3].included_flag IN (0, 1))))
       SET pass_rec->qual[4].pass = 99
       SET pass_rec->qual[4].get_out = 1
      ENDIF
     ELSE
      SET pass_rec->qual[4].pass = 99
      SET pass_rec->qual[4].get_out = 1
     ENDIF
     SELECT INTO "nl:"
      FROM chart_dist_filter cdf,
       encounter e
      PLAN (cdf
       WHERE cdf.distribution_id=distribution_id_chosen)
       JOIN (e
       WHERE e.encntr_id=encntr_id_chosen)
      ORDER BY cdf.type_flag
      HEAD REPORT
       cnt_ok = 0, linex = fillstring(130,"-"), pass_rec->qual[1].get_out = 0,
       pass_rec->qual[2].get_out = 0, pass_rec->qual[3].get_out = 0, pass_rec->qual[5].get_out = 66,
       pass_rec->qual[6].get_out = 0, size1 = cnvtint(size(encntr_type_chosen->qual,5)), size2 =
       cnvtint(size(org_id_chosen->qual,5)),
       size4 = cnvtint(size(location_chosen->qual,5)), size_location = cnvtint(size(location_rec->
         qual,5)), size5 = cnvtint(size(med_service_chosen->qual,5)),
       pass_rec->qual[2].pass = 99, pass_rec->qual[3].pass = 99, pass_rec->qual[5].pass = 99,
       pass_rec->qual[6].pass = 99
      DETAIL
       IF (cdf.type_flag=0)
        pass_rec->qual[2].pass = 99
        IF ((included_rec->qual[1].included_flag=1))
         pass_rec->qual[2].pass = 0
         FOR (x = 1 TO size1)
           IF ((encntr_type_chosen->qual[x].encntr_type_cd=e.encntr_type_cd)
            AND (pass_rec->qual[2].get_out=0))
            pass_rec->qual[2].pass = 1, pass_rec->qual[2].get_out = 1
           ELSE
            do_nothing = 0
           ENDIF
         ENDFOR
        ELSEIF ((included_rec->qual[1].included_flag=0))
         pass_rec->qual[2].pass = 0
         FOR (x = 1 TO size1)
           IF ((encntr_type_chosen->qual[x].encntr_type_cd != e.encntr_type_cd)
            AND (pass_rec->qual[2].get_out=0))
            pass_rec->qual[2].pass = 1
           ELSE
            pass_rec->qual[2].pass = 0, pass_rec->qual[2].get_out = 1
           ENDIF
         ENDFOR
        ELSE
         pass_rec->qual[2].pass = 99
        ENDIF
       ELSEIF (cdf.type_flag=1)
        pass_rec->qual[3].pass = 99
        IF ((included_rec->qual[2].included_flag=1))
         pass_rec->qual[3].pass = 0
         FOR (x = 1 TO size2)
           IF ((org_id_chosen->qual[x].org_id=e.organization_id)
            AND (pass_rec->qual[3].get_out=0))
            pass_rec->qual[3].pass = 1, pass_rec->qual[3].get_out = 1
           ELSE
            do_nothing = 0
           ENDIF
         ENDFOR
        ELSEIF ((included_rec->qual[2].included_flag=0))
         FOR (x = 1 TO size2)
           IF ((org_id_chosen->qual[x].org_id != e.organization_id)
            AND (pass_rec->qual[3].get_out=0))
            pass_rec->qual[3].pass = 1
           ELSE
            pass_rec->qual[3].pass = 0, pass_rec->qual[3].get_out = 1
           ENDIF
         ENDFOR
        ELSE
         pass_rec->qual[3].pass = 99
        ENDIF
       ELSEIF (cdf.type_flag=3)
        pass_rec->qual[5].pass = 0
        IF ((included_rec->qual[4].included_flag=1))
         FOR (x = 1 TO size4)
           FOR (y = 1 TO size_location)
             IF ((location_chosen->qual[x].location_cd=location_rec->qual[y].location_cd)
              AND (pass_rec->qual[5].get_out > 2))
              pass_rec->qual[5].pass = 1, pass_rec->qual[5].get_out = 3
             ELSE
              IF ((pass_rec->qual[5].get_out != 3))
               pass_rec->qual[5].pass = 0
              ENDIF
             ENDIF
           ENDFOR
         ENDFOR
        ELSEIF ((included_rec->qual[4].included_flag=0))
         FOR (x = 1 TO size4)
           FOR (y = 1 TO size_location)
             IF ((location_chosen->qual[x].location_cd != location_rec->qual[y].location_cd)
              AND (pass_rec->qual[5].get_out > 2))
              IF ((pass_rec->qual[5].get_out != 3))
               pass_rec->qual[5].pass = 1
              ENDIF
             ELSE
              pass_rec->qual[5].pass = 0, pass_rec->qual[5].get_out = 3
             ENDIF
           ENDFOR
         ENDFOR
        ELSE
         pass_rec->qual[5].pass = 99
        ENDIF
       ELSEIF (cdf.type_flag=4)
        pass_rec->qual[6].pass = 99
        IF ((included_rec->qual[5].included_flag=1))
         pass_rec->qual[6].pass = 0
         FOR (x = 1 TO size5)
           IF ((med_service_chosen->qual[x].medical_service_cd=e.med_service_cd)
            AND (pass_rec->qual[6].get_out=0))
            pass_rec->qual[6].pass = 1, pass_rec->qual[6].get_out = 1
           ELSE
            do_nothing = 0
           ENDIF
         ENDFOR
        ELSEIF ((included_rec->qual[5].included_flag=0))
         pass_rec->qual[6].pass = 0
         FOR (x = 1 TO size5)
           IF ((med_service_chosen->qual[x].medical_service_cd != e.med_service_cd)
            AND (pass_rec->qual[6].get_out=0))
            pass_rec->qual[6].pass = 1
           ELSE
            pass_rec->qual[6].pass = 0, pass_rec->qual[6].get_out = 1
           ENDIF
         ENDFOR
        ELSE
         pass_rec->qual[6].pass = 99
        ENDIF
       ENDIF
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      FROM chart_dist_filter cdf,
       encntr_loc_hist elh,
       encounter e,
       chart_distribution cd
      PLAN (cdf
       WHERE cdf.distribution_id=distribution_id_chosen)
       JOIN (elh
       WHERE elh.encntr_id=encntr_id_chosen)
       JOIN (e
       WHERE e.encntr_id=encntr_id_chosen)
       JOIN (cd
       WHERE cd.distribution_id=distribution_id_chosen)
      ORDER BY cdf.type_flag
      HEAD REPORT
       size1 = cnvtint(size(encntr_type_chosen->qual,5)), size2 = cnvtint(size(org_id_chosen->qual,5)
        ), size4 = cnvtint(size(location_chosen->qual,5)),
       size5 = cnvtint(size(med_service_chosen->qual,5)), enc_hist_count = cnvtint(size(
         encntr_hist_loc_rec->qual,5)), stat = alterlist(enc_hist_pass_rec->qual,enc_hist_count)
      DETAIL
       FOR (y = 1 TO enc_hist_count)
         hist_begin_dt_tm = encntr_hist_loc_rec->qual[y].beg_effective_dt_tm, hist_end_dt_tm =
         encntr_hist_loc_rec->qual[y].end_effective_dt_tm
         IF (cd.dist_type=1)
          IF (e.disch_dt_tm > hist_begin_dt_tm
           AND e.disch_dt_tm < hist_end_dt_tm)
           enc_hist_pass_rec->qual[y].dist_type = 1
          ELSE
           enc_hist_pass_rec->qual[y].dist_type = 0
          ENDIF
         ELSEIF (cd.dist_type=2)
          IF (e.disch_dt_tm > hist_end_dt_tm)
           enc_hist_pass_rec->qual[y].dist_type = 1
          ELSE
           enc_hist_pass_rec->qual[y].dist_type = 0
          ENDIF
         ELSEIF (cd.dist_type=3)
          enc_hist_pass_rec->qual[y].dist_type = 1
         ENDIF
       ENDFOR
       FOR (x = 1 TO enc_hist_count)
         IF (size1=0)
          enc_hist_pass_rec->qual[x].encntr_type = 99
         ENDIF
         IF (size2=0)
          enc_hist_pass_rec->qual[x].organization = 99
         ENDIF
         IF (size4=0)
          enc_hist_pass_rec->qual[x].loc_facility = 99
         ENDIF
         IF (size5=0)
          enc_hist_pass_rec->qual[x].med_service = 99
         ENDIF
         IF (cdf.type_flag=0)
          IF ((included_rec->qual[1].included_flag=1))
           FOR (y = 1 TO size1)
             IF ((encntr_type_chosen->qual[y].encntr_type_cd=encntr_hist_loc_rec->qual[x].
             encntr_type_cd))
              enc_hist_pass_rec->qual[x].encntr_type = 1, enc_hist_pass_rec->qual[x].
              encntr_type_passed = 3
             ELSE
              IF ((enc_hist_pass_rec->qual[x].encntr_type_passed != 3))
               enc_hist_pass_rec->qual[x].encntr_type = 0
              ENDIF
             ENDIF
           ENDFOR
          ELSEIF ((included_rec->qual[1].included_flag=0))
           FOR (y = 1 TO size1)
             IF ((encntr_type_chosen->qual[y].encntr_type_cd != encntr_hist_loc_rec->qual[x].
             encntr_type_cd))
              IF ((enc_hist_pass_rec->qual[x].encntr_type_passed != 3))
               enc_hist_pass_rec->qual[x].encntr_type = 1
              ENDIF
             ELSE
              enc_hist_pass_rec->qual[x].encntr_type = 0, enc_hist_pass_rec->qual[x].
              encntr_type_passed = 3
             ENDIF
           ENDFOR
          ELSE
           enc_hist_pass_rec->qual[x].encntr_type = 99
          ENDIF
         ELSEIF (cdf.type_flag=1)
          IF ((included_rec->qual[2].included_flag=1))
           FOR (y = 1 TO size2)
             IF ((org_id_chosen->qual[y].org_id=encntr_hist_loc_rec->qual[x].organization_id))
              enc_hist_pass_rec->qual[x].organization = 1, enc_hist_pass_rec->qual[x].
              organization_passed = 3
             ELSE
              IF ((enc_hist_pass_rec->qual[x].organization_passed != 3))
               enc_hist_pass_rec->qual[x].organization = 0
              ENDIF
             ENDIF
           ENDFOR
          ELSEIF ((included_rec->qual[2].included_flag=0))
           FOR (y = 1 TO size2)
             IF ((org_id_chosen->qual[y].org_id != encntr_hist_loc_rec->qual[x].organization_id))
              IF ((enc_hist_pass_rec->qual[x].organization_passed != 3))
               enc_hist_pass_rec->qual[x].organization = 1
              ENDIF
             ELSE
              enc_hist_pass_rec->qual[x].organization = 0, enc_hist_pass_rec->qual[x].
              organization_passed = 3
             ENDIF
           ENDFOR
          ELSE
           enc_hist_pass_rec->qual[x].organization = 99
          ENDIF
         ELSEIF (cdf.type_flag=3)
          IF ((included_rec->qual[4].included_flag=1))
           FOR (y = 1 TO size4)
             IF ((location_chosen->qual[y].location_cd=encntr_hist_loc_rec->qual[x].loc_facility_cd))
              enc_hist_pass_rec->qual[x].loc_facility = 1, enc_hist_pass_rec->qual[x].
              loc_facility_passed = 3
             ELSE
              IF ((enc_hist_pass_rec->qual[x].loc_facility_passed != 3))
               enc_hist_pass_rec->qual[x].loc_facility = 0
              ENDIF
             ENDIF
           ENDFOR
          ELSEIF ((included_rec->qual[4].included_flag=0))
           FOR (y = 1 TO size4)
             IF ((location_chosen->qual[y].location_cd != encntr_hist_loc_rec->qual[x].
             loc_facility_cd))
              IF ((enc_hist_pass_rec->qual[x].loc_facility_passed != 3))
               enc_hist_pass_rec->qual[x].loc_facility = 1
              ENDIF
             ELSE
              enc_hist_pass_rec->qual[x].loc_facility = 0, enc_hist_pass_rec->qual[x].
              loc_facility_passed = 3
             ENDIF
           ENDFOR
          ELSE
           enc_hist_pass_rec->qual[x].loc_facility = 99
          ENDIF
         ELSEIF (cdf.type_flag=4)
          IF ((included_rec->qual[5].included_flag=1))
           FOR (y = 1 TO size5)
             IF ((med_service_chosen->qual[y].medical_service_cd=encntr_hist_loc_rec->qual[x].
             med_service_cd))
              enc_hist_pass_rec->qual[x].med_service = 1, enc_hist_pass_rec->qual[x].
              med_service_passed = 3
             ELSE
              IF ((enc_hist_pass_rec->qual[x].med_service_passed != 3))
               enc_hist_pass_rec->qual[x].med_service = 0
              ENDIF
             ENDIF
           ENDFOR
          ELSEIF ((included_rec->qual[5].included_flag=0))
           FOR (y = 1 TO size5)
             IF ((med_service_chosen->qual[y].medical_service_cd != encntr_hist_loc_rec->qual[x].
             med_service_cd))
              IF ((enc_hist_pass_rec->qual[x].med_service_passed != 3))
               enc_hist_pass_rec->qual[x].med_service = 1
              ENDIF
             ELSE
              enc_hist_pass_rec->qual[x].med_service = 0, enc_hist_pass_rec->qual[x].
              med_service_passed = 3
             ENDIF
           ENDFOR
          ELSE
           enc_hist_pass_rec->qual[x].med_service = 99
          ENDIF
         ENDIF
       ENDFOR
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      epr.prsnl_person_id, epr.beg_effective_dt_tm, epr.end_effective_dt_tm,
      epr.encntr_prsnl_r_cd
      FROM (dummyt d1  WITH seq = value(size(prov_id_chosen->qual,5))),
       (dummyt d2  WITH seq = 1),
       encntr_prsnl_reltn_history epr
      PLAN (d1
       WHERE maxrec(d2,size(prov_id_chosen->qual[d1.seq].prov_type_qual,5)))
       JOIN (d2)
       JOIN (epr
       WHERE epr.encntr_id=encntr_id_chosen
        AND epr.active_ind=1
        AND (epr.prsnl_person_id=prov_id_chosen->qual[d1.seq].prov_id)
        AND (epr.encntr_prsnl_r_cd=prov_id_chosen->qual[d1.seq].prov_type_qual[d2.seq].prov_type_cd))
      ORDER BY epr.beg_effective_dt_tm, epr.end_effective_dt_tm
      HEAD REPORT
       do_nothing = 0, enc_prsnl_cnt = 1
      DETAIL
       IF (mod(enc_prsnl_cnt,10)=1)
        stat = alterlist(encntr_prsnl_rec->qual,(enc_prsnl_cnt+ 9))
       ENDIF
       encntr_prsnl_rec->qual[enc_prsnl_cnt].prsnl_person_id = epr.prsnl_person_id, encntr_prsnl_rec
       ->qual[enc_prsnl_cnt].encntr_prsnl_r_cd = epr.encntr_prsnl_r_cd, encntr_prsnl_rec->qual[
       enc_prsnl_cnt].beg_effective_dt_tm = epr.beg_effective_dt_tm,
       encntr_prsnl_rec->qual[enc_prsnl_cnt].end_effective_dt_tm = epr.end_effective_dt_tm,
       enc_prsnl_cnt += 1
      FOOT REPORT
       stat = alterlist(encntr_prsnl_rec->qual,enc_prsnl_cnt)
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      ppr.prsnl_person_id, ppr.beg_effective_dt_tm, ppr.end_effective_dt_tm,
      ppr.person_prsnl_r_cd
      FROM (dummyt d1  WITH seq = value(size(prov_id_chosen->qual,5))),
       (dummyt d2  WITH seq = 1),
       person_prsnl_reltn_history ppr
      PLAN (d1
       WHERE maxrec(d2,size(prov_id_chosen->qual[d1.seq].prov_type_qual,5)))
       JOIN (d2)
       JOIN (ppr
       WHERE ppr.person_id=person_id_chosen
        AND ppr.active_ind=1
        AND (ppr.prsnl_person_id=prov_id_chosen->qual[d1.seq].prov_id)
        AND (ppr.person_prsnl_r_cd=prov_id_chosen->qual[d1.seq].prov_type_qual[d2.seq].prov_type_cd))
      ORDER BY ppr.beg_effective_dt_tm, ppr.end_effective_dt_tm
      HEAD REPORT
       do_nothing = 0, person_prsnl_cnt = 1
      DETAIL
       IF (mod(person_prsnl_cnt,10)=1)
        stat = alterlist(person_prsnl_rec->qual,(person_prsnl_cnt+ 9))
       ENDIF
       person_prsnl_rec->qual[person_prsnl_cnt].prsnl_person_id = ppr.prsnl_person_id,
       person_prsnl_rec->qual[person_prsnl_cnt].person_prsnl_r_cd = ppr.person_prsnl_r_cd,
       person_prsnl_rec->qual[person_prsnl_cnt].beg_effective_dt_tm = ppr.beg_effective_dt_tm,
       person_prsnl_rec->qual[person_prsnl_cnt].end_effective_dt_tm = ppr.end_effective_dt_tm,
       person_prsnl_cnt += 1
      FOOT REPORT
       stat = alterlist(person_prsnl_rec->qual,person_prsnl_cnt)
      WITH nocounter
     ;end select
    ENDIF
    SET encntr_prsnl_qualified = 0
    SET person_prsnl_qualified = 0
    SET enc_hist_size = 0
    SET encntr_prsnl_size = 0
    SET person_prsnl_size = 0
    SET enc_hist_size = size(encntr_hist_loc_rec->qual,5)
    SET encntr_prsnl_size = size(encntr_prsnl_rec->qual,5)
    SET person_prsnl_size = size(person_prsnl_rec->qual,5)
    SET size6 = size(prov_id_chosen->qual,5)
    FOR (x = 1 TO enc_hist_size)
      IF (size6 > 0)
       SET hist_begin_dt_tm = encntr_hist_loc_rec->qual[x].beg_effective_dt_tm
       SET hist_end_dt_tm = encntr_hist_loc_rec->qual[x].end_effective_dt_tm
       FOR (y = 1 TO encntr_prsnl_size)
         IF ((encntr_prsnl_rec->qual[y].prsnl_person_id > 0))
          SET encntr_prsnl_begin_dt_tm = encntr_prsnl_rec->qual[y].beg_effective_dt_tm
          SET encntr_prsnl_end_dt_tm = encntr_prsnl_rec->qual[y].end_effective_dt_tm
          IF (((encntr_prsnl_begin_dt_tm > hist_begin_dt_tm
           AND encntr_prsnl_begin_dt_tm < hist_end_dt_tm) OR (encntr_prsnl_end_dt_tm >
          hist_begin_dt_tm
           AND encntr_prsnl_end_dt_tm < hist_end_dt_tm)) )
           SET encntr_prsnl_qualified += 1
          ENDIF
         ENDIF
       ENDFOR
       FOR (z = 1 TO person_prsnl_size)
         IF ((person_prsnl_rec->qual[z].prsnl_person_id > 0))
          SET person_prsnl_begin_dt_tm = person_prsnl_rec->qual[z].beg_effective_dt_tm
          SET person_prsnl_end_dt_tm = person_prsnl_rec->qual[z].end_effective_dt_tm
          IF (((person_prsnl_begin_dt_tm > hist_begin_dt_tm
           AND person_prsnl_begin_dt_tm < hist_end_dt_tm) OR (person_prsnl_end_dt_tm >
          hist_begin_dt_tm
           AND person_prsnl_end_dt_tm < hist_end_dt_tm)) )
           SET person_prsnl_qualified += 1
          ENDIF
         ENDIF
       ENDFOR
       IF ((included_rec->qual[3].included_flag=1))
        IF (((encntr_prsnl_qualified > 0) OR (person_prsnl_qualified > 0)) )
         SET enc_hist_pass_rec->qual[x].provider = 1
        ENDIF
       ELSEIF ((included_rec->qual[3].included_flag=0))
        IF (encntr_prsnl_qualified=0
         AND person_prsnl_qualified=0)
         SET enc_hist_pass_rec->qual[x].provider = 1
        ENDIF
       ENDIF
      ELSE
       SET enc_hist_pass_rec->qual[x].provider = 99
      ENDIF
    ENDFOR
    SELECT INTO "mine"
     dist_id = cd.distribution_id, effective_from = format(e.beg_effective_dt_tm,";;Q"), effective_to
      = format(e.end_effective_dt_tm,";;Q")
     FROM chart_distribution cd,
      encounter e
     PLAN (cd
      WHERE cd.distribution_id=distribution_id_chosen)
      JOIN (e
      WHERE e.encntr_id=encntr_id_chosen)
     HEAD REPORT
      enc_hist_count = cnvtint(size(encntr_hist_loc_rec->qual,5)), row + 1, col 2,
      "Encounter ID:", col 30, encntr_id_chosen,
      row + 1, col 2, "Distribution ID:",
      col 30, dist_id, row + 3,
      col 5, "Does Encounter Qualify for Distribution", row + 2
     HEAD PAGE
      col 2, "EffectiveFrom", col 27,
      "EffectiveTo", col 51, "DistributionType",
      col 70, "EncounterType", col 85,
      "Organization", col 105, "Locations",
      col 120, "Medical Service", col 140,
      "Providers", row + 1, col 2,
      "--------------", col 27, "------------",
      col 51, "-----------------", col 70,
      "------------", col 85, "------------",
      col 105, "---------", col 120,
      "--------------", col 140, "---------",
      row + 1
     DETAIL
      col 2, effective_from, col 27,
      effective_to, col 51
      IF ((pass_rec->qual[1].pass=1))
       "PASSED"
      ELSEIF ((pass_rec->qual[1].pass=0))
       "FAILED"
      ELSE
       " --- "
      ENDIF
      col 70
      IF ((pass_rec->qual[2].pass=1))
       "PASSED"
      ELSEIF ((pass_rec->qual[2].pass=0))
       "FAILED"
      ELSE
       " --- "
      ENDIF
      col 85
      IF ((pass_rec->qual[3].pass=1))
       "PASSED"
      ELSEIF ((pass_rec->qual[3].pass=0))
       "FAILED"
      ELSE
       " --- "
      ENDIF
      col 105
      IF ((pass_rec->qual[5].pass=1))
       "PASSED"
      ELSEIF ((pass_rec->qual[5].pass=0))
       "FAILED"
      ELSE
       " --- "
      ENDIF
      col 120
      IF ((pass_rec->qual[6].pass=1))
       "PASSED"
      ELSEIF ((pass_rec->qual[6].pass=0))
       "FAILED"
      ELSE
       " --- "
      ENDIF
      col 140
      IF ((pass_rec->qual[4].pass=1))
       "PASSED"
      ELSEIF ((pass_rec->qual[4].pass=0))
       "FAILED"
      ELSE
       " --- "
      ENDIF
      FOR (x = 1 TO enc_hist_count)
        row + 1, begin_dt_tm = format(encntr_hist_loc_rec->qual[x].beg_effective_dt_tm,";;Q"),
        end_dt_tm = format(encntr_hist_loc_rec->qual[x].end_effective_dt_tm,";;Q"),
        col 2, begin_dt_tm, col 27,
        end_dt_tm, col 51
        IF ((enc_hist_pass_rec->qual[x].dist_type=1))
         "PASSED"
        ELSEIF ((enc_hist_pass_rec->qual[x].dist_type=0))
         "FAILED"
        ELSE
         " --- "
        ENDIF
        col 70
        IF ((enc_hist_pass_rec->qual[x].encntr_type=1))
         "PASSED"
        ELSEIF ((enc_hist_pass_rec->qual[x].encntr_type=0))
         "FAILED"
        ELSE
         " --- "
        ENDIF
        col 85
        IF ((enc_hist_pass_rec->qual[x].organization=1))
         "PASSED"
        ELSEIF ((enc_hist_pass_rec->qual[x].organization=0))
         "FAILED"
        ELSE
         " --- "
        ENDIF
        col 105
        IF ((enc_hist_pass_rec->qual[x].loc_facility=1))
         "PASSED"
        ELSEIF ((enc_hist_pass_rec->qual[x].loc_facility=0))
         "FAILED"
        ELSE
         " --- "
        ENDIF
        col 120
        IF ((enc_hist_pass_rec->qual[x].med_service=1))
         "PASSED"
        ELSEIF ((enc_hist_pass_rec->qual[x].med_service=0))
         "FAILED"
        ELSE
         " --- "
        ENDIF
        col 140
        IF ((enc_hist_pass_rec->qual[x].provider=1))
         "PASSED"
        ELSEIF ((enc_hist_pass_rec->qual[x].provider=0))
         "FAILED"
        ELSE
         " --- "
        ENDIF
      ENDFOR
     WITH nocounter, maxcol = 1000
    ;end select
   ELSE
    CALL display_invalid_logical_domain_message(null)
   ENDIF
 END ;Subroutine
 SUBROUTINE validateencounteractivityforreporttemplate(null)
   FREE RECORD template_publish_hist
   RECORD template_publish_hist(
     1 qual[*]
       2 publish_dt_tm = dq8
   )
   CALL clear(1,1)
   CALL box(2,1,23,110)
   CALL text(3,22,"*** Validate Encounter Activity With Report Template***")
   CALL text(5,4,"Choose a Scope: ")
   CALL text(6,4,"2=Encounter, 4=Accession")
   CALL accept(7,4,"99;",02
    WHERE curaccept IN (02, 04))
   SET encntr_id_chosen = 0.0
   SET scope_chosen = 0
   SET report_template_chosen = fillstring(80," ")
   SET dist_date = cnvtdatetime(sysdate)
   SET scope_chosen = cnvtint(curaccept)
   IF (scope_chosen=2)
    CALL text(9,4,"Enter an Encntr_id:")
    CALL accept(9,30,"P(40);Cf"," ")
    SET encntr_id_chosen = cnvtreal(curaccept)
    SET where_clause = "ce.encntr_id = encntr_id_chosen and ce.event_cd > 0 and ce.catalog_cd > 0"
    SET title = "VALIDATE ENCOUNTER ACTIVITY WITH REPORT TEMPLATE"
   ELSE
    CALL text(9,4,"Enter an Accession:")
    CALL accept(10,4,"P(40);C"," ")
    SET accession_nbr_chosen = curaccept
    SET where_clause =
    "ce.accession_nbr = accession_nbr_chosen and ce.event_cd > 0 and ce.catalog_cd > 0"
    SET title = "VALIDATE ACCESSION ACTIVITY WITH REPORT TEMPLATE"
   ENDIF
   IF (((scope_chosen=2
    AND can_user_access_this_encounter(null)=1) OR (scope_chosen=4
    AND can_user_access_this_acc(null)=1)) )
    CALL text(15,4,"Select a Report Template: ")
    CALL text(16,4,"SHIFT/F5 to see a list of Report Templates")
    SET help =
    SELECT DISTINCT INTO "nl:"
     crt.template_name
     FROM cr_report_template crt
     WHERE crt.active_ind=1
     ORDER BY cnvtupper(crt.template_name)
     WITH nocounter
    ;end select
    CALL accept(17,4,"P(64);C")
    SET help = off
    SET report_template_chosen = trim(curaccept)
    SET report_template_id_chosen = 0.0
    SELECT INTO "nl:"
     crt.report_template_id
     FROM cr_report_template crt
     WHERE crt.template_name=report_template_chosen
      AND crt.active_ind=1
     HEAD REPORT
      do_nothing = 0
     DETAIL
      report_template_id_chosen = crt.report_template_id
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     ctp.publish_dt_tm
     FROM cr_template_publish ctp
     WHERE ctp.template_id=report_template_id_chosen
     ORDER BY ctp.publish_dt_tm DESC
     HEAD REPORT
      do_nothing = 0, cnt = 0
     DETAIL
      cnt += 1, stat = alterlist(template_publish_hist->qual,cnt), template_publish_hist->qual[cnt].
      publish_dt_tm = ctp.publish_dt_tm
     WITH nocounter
    ;end select
    DECLARE template_id = f8 WITH constant(report_template_id_chosen)
    DECLARE template_publish_dt_tm = q8 WITH constant(template_publish_hist->qual[1].publish_dt_tm)
    FREE RECORD activity_rec
    RECORD activity_rec(
      1 activity[*]
        2 procedure_type_flag = i2
        2 event_set_name = vc
        2 catalog_cd = f8
        2 event_cds[*]
          3 event_cd = f8
        2 content_type_mean = vc
    )
    FREE RECORD temp_activity_rec
    RECORD temp_activity_rec(
      1 activity[*]
        2 procedure_type_flag = i2
        2 event_set_name = vc
        2 catalog_cd = f8
        2 content_type_mean = vc
    )
    FREE RECORD temp_request
    RECORD temp_request(
      1 cr_report_templates[*]
        2 report_template_id = f8
        2 report_template_publish_dt_tm = dq8
      1 cr_report_sections[*]
        2 report_section_id = f8
      1 cr_report_static_regions[*]
        2 report_static_region_id = f8
    )
    DECLARE activitycnt = i4 WITH noconstant(0)
    SET stat = alterlist(temp_request->cr_report_templates,1)
    SET temp_request->cr_report_templates[1].report_template_id = template_id
    SET temp_request->cr_report_templates[1].report_template_publish_dt_tm = cnvtdatetime(
     template_publish_dt_tm)
    FREE RECORD temp_reply
    RECORD temp_reply(
      1 template_version
        2 item[*]
          3 version_id = f8
          3 xml_detail = vc
      1 section_version
        2 item[*]
          3 version_id = f8
          3 xml_detail = vc
      1 static_region_version
        2 item[*]
          3 version_id = f8
          3 xml_detail = vc
      1 status_data
        2 status = c1
        2 subeventstatus[1]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
    )
    DECLARE lnumofsects = i4 WITH noconstant(0)
    DECLARE procedure_node = c11 WITH constant("procedure")
    DECLARE section_node = c9 WITH constant("section")
    DECLARE code_attr = c6 WITH constant("code")
    DECLARE type_attr = c6 WITH constant("type")
    DECLARE uid_attr = vc WITH constant("uid")
    DECLARE content_type_attr = vc WITH constant("content-type")
    DECLARE lproccnt = i4 WITH noconstant(0)
    DECLARE contenttype = vc WITH noconstant("")
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = size(temp_request->cr_report_templates,5)),
      cr_template_publish cpt,
      cr_template_snapshot cts,
      cr_report_section crs
     PLAN (d)
      JOIN (cpt
      WHERE (cpt.template_id=temp_request->cr_report_templates[d.seq].report_template_id)
       AND cpt.beg_effective_dt_tm <= cnvtdatetime(temp_request->cr_report_templates[d.seq].
       report_template_publish_dt_tm)
       AND cpt.end_effective_dt_tm > cnvtdatetime(temp_request->cr_report_templates[d.seq].
       report_template_publish_dt_tm))
      JOIN (cts
      WHERE cts.template_id=cpt.template_id
       AND cts.beg_effective_dt_tm <= cpt.publish_dt_tm
       AND cts.end_effective_dt_tm > cpt.publish_dt_tm
       AND cts.section_id > 0)
      JOIN (crs
      WHERE crs.section_id=cts.section_id
       AND crs.beg_effective_dt_tm <= cpt.publish_dt_tm
       AND crs.end_effective_dt_tm > cpt.publish_dt_tm
       AND crs.active_ind > 0)
     HEAD REPORT
      cnt = 0
     DETAIL
      cnt += 1
      IF (mod(cnt,10)=1)
       stat = alterlist(temp_request->cr_report_sections[cnt],(cnt+ 9))
      ENDIF
      temp_request->cr_report_sections[cnt].report_section_id = crs.report_section_id
     FOOT REPORT
      stat = alterlist(temp_request->cr_report_sections,cnt)
     WITH nocounter
    ;end select
    SET temp_request->cr_report_templates[1].report_template_id = 0
    SET stat = alterlist(temp_request->cr_report_templates,0)
    EXECUTE cr_get_report_long_text  WITH replace(request,temp_request), replace(reply,temp_reply)
    SET lnumofsects = size(temp_reply->section_version.item,5)
    DECLARE uar_xml_closefile(filehandle=i4(ref)) = null
    DECLARE uar_xml_getroot(filehandle=i4(ref),nodehandle=i4(ref)) = i4
    DECLARE uar_xml_getchildcount(nodehandle=i4(ref)) = i4
    DECLARE uar_xml_getchildnode(nodehandle=i4(ref),nodeno=i4(ref),childnode=i4(ref)) = i4
    DECLARE uar_xml_getnodename(nodehandle=i4(ref)) = vc
    DECLARE uar_xml_getnodecontent(nodehandle=i4(ref)) = vc
    DECLARE uar_xml_getattrbypos(nodehandle=i4(ref),ndx=i4(ref),attributehandle=i4(ref)) = i4
    DECLARE uar_xml_getattrname(attributehandle=i4(ref)) = vc
    DECLARE uar_xml_getattrvalue(attributehandle=i4(ref)) = vc
    DECLARE uar_xml_getattrcount(nodehandle=i4(ref)) = i4
    DECLARE hfile = i4 WITH private
    DECLARE hroot = i4 WITH private
    DECLARE srpt = vc WITH notrim
    FOR (x = 1 TO lnumofsects)
      SET stat = 0
      SET stat = uar_xml_parsestring(nullterm(temp_reply->section_version.item[x].xml_detail),hfile)
      IF (stat=1)
       IF (uar_xml_getroot(hfile,hroot)=1)
        CALL importnode(hroot)
       ENDIF
      ELSE
       SET srpt = concat("File [",temp_reply->section_version.item[x].version_id,
        "] not found, Error Code = ",cnvtstring(stat))
      ENDIF
      CALL uar_xml_closefile(hfile)
    ENDFOR
    SET stat = alterlist(temp_activity_rec->activity,lproccnt)
    SUBROUTINE importnode(hparent)
      DECLARE hattr = i4 WITH private
      DECLARE hchild = i4 WITH private
      DECLARE nodecount = i4 WITH private
      DECLARE attrcount = i4 WITH private
      DECLARE sattname = vc WITH private
      DECLARE sattvalue = vc WITH private
      DECLARE snodename = vc WITH private
      DECLARE chnode = i4 WITH private
      IF (hparent=0)
       RETURN
      ENDIF
      SET nodecount = uar_xml_getchildcount(hparent)
      SET attrcount = uar_xml_getattrcount(hparent)
      SET snodename = trim(uar_xml_getnodename(hparent))
      IF (attrcount > 0
       AND snodename=section_node)
       SET contenttype = ""
       FOR (at = 0 TO (attrcount - 1))
        SET stat = uar_xml_getattrbypos(hparent,at,hattr)
        IF (stat=1)
         SET sattname = trim(uar_xml_getattrname(hattr))
         IF (sattname=content_type_attr)
          SET contenttype = trim(uar_xml_getattrvalue(hattr))
          SET at = attrcount
         ENDIF
        ENDIF
       ENDFOR
      ELSEIF (attrcount > 0
       AND snodename=procedure_node)
       SET lproccnt += 1
       IF (mod(lproccnt,10)=1)
        SET stat = alterlist(temp_activity_rec->activity[lproccnt],(lproccnt+ 9))
       ENDIF
       SET temp_activity_rec->activity[lproccnt].content_type_mean = contenttype
       FOR (at = 0 TO (attrcount - 1))
        SET stat = uar_xml_getattrbypos(hparent,at,hattr)
        IF (stat=1)
         SET sattname = trim(uar_xml_getattrname(hattr))
         SET sattvalue = trim(uar_xml_getattrvalue(hattr))
         CASE (sattname)
          OF type_attr:
           IF (sattvalue="event-set")
            SET temp_activity_rec->activity[lproccnt].procedure_type_flag = 0
           ELSEIF (sattvalue="orderable")
            SET temp_activity_rec->activity[lproccnt].procedure_type_flag = 1
           ELSEIF (sattvalue="ap-report-component")
            SET temp_activity_rec->activity[lproccnt].procedure_type_flag = 2
           ELSE
            SET temp_activity_rec->activity[lproccnt].procedure_type_flag = - (1)
           ENDIF
          OF uid_attr:
           SET temp_activity_rec->activity[lproccnt].event_set_name = replace_escaped_xml(sattvalue)
          OF code_attr:
           SET temp_activity_rec->activity[lproccnt].catalog_cd = cnvtreal(sattvalue)
         ENDCASE
        ENDIF
       ENDFOR
      ENDIF
      IF (nodecount > 0)
       FOR (chnode = 0 TO (nodecount - 1))
        SET stat = uar_xml_getchildnode(hparent,chnode,hchild)
        IF (stat=1)
         CALL importnode(hchild)
        ENDIF
       ENDFOR
      ENDIF
    END ;Subroutine
    SUBROUTINE (replace_escaped_xml(xmlstring=vc) =vc)
      DECLARE __tmpstring = vc WITH protect
      SET __tmpstring = nullterm(xmlstring)
      SET __tmpstring = replace(__tmpstring,"&apos;",char(39),0)
      SET __tmpstring = replace(__tmpstring,"&quot;",char(34),0)
      SET __tmpstring = replace(__tmpstring,"&gt;",">",0)
      SET __tmpstring = replace(__tmpstring,"&lt;","<",0)
      SET __tmpstring = replace(__tmpstring,"&amp;","&",0)
      RETURN(nullterm(__tmpstring))
    END ;Subroutine
    IF (size(temp_activity_rec->activity,5) > 0)
     SELECT DISTINCT INTO "nl:"
      content_type = temp_activity_rec->activity[d.seq].content_type_mean, esc.event_set_cd, ese
      .event_cd
      FROM (dummyt d  WITH seq = size(temp_activity_rec->activity,5)),
       v500_event_set_code esc,
       v500_event_set_explode ese
      PLAN (d
       WHERE (temp_activity_rec->activity[d.seq].procedure_type_flag=0))
       JOIN (esc
       WHERE (esc.event_set_name=temp_activity_rec->activity[d.seq].event_set_name))
       JOIN (ese
       WHERE ese.event_set_cd=esc.event_set_cd)
      ORDER BY content_type, ese.event_set_cd, ese.event_cd
      HEAD REPORT
       activitycnt = 0, codecnt = 0
      HEAD content_type
       do_nothing = 0
      HEAD ese.event_set_cd
       IF (ese.event_set_cd > 0)
        activitycnt += 1
        IF (mod(activitycnt,10)=1)
         stat = alterlist(activity_rec->activity[activitycnt],(activitycnt+ 9))
        ENDIF
        activity_rec->activity[activitycnt].procedure_type_flag = 0, activity_rec->activity[
        activitycnt].event_set_name = esc.event_set_name, activity_rec->activity[activitycnt].
        content_type_mean = temp_activity_rec->activity[d.seq].content_type_mean
       ENDIF
      DETAIL
       codecnt += 1
       IF (mod(codecnt,10)=1)
        stat = alterlist(activity_rec->activity[activitycnt].event_cds,(codecnt+ 9))
       ENDIF
       activity_rec->activity[activitycnt].event_cds[codecnt].event_cd = ese.event_cd
      FOOT  ese.event_set_cd
       IF (ese.event_set_cd > 0)
        stat = alterlist(activity_rec->activity[activitycnt].event_cds,codecnt), codecnt = 0
       ENDIF
      WITH nocounter
     ;end select
     SELECT DISTINCT INTO "nl:"
      content_type = temp_activity_rec->activity[d.seq].content_type_mean, cver.parent_cd, cver
      .event_cd
      FROM (dummyt d  WITH seq = size(temp_activity_rec->activity,5)),
       code_value_event_r cver
      PLAN (d
       WHERE (temp_activity_rec->activity[d.seq].procedure_type_flag=2)
        AND (temp_activity_rec->activity[d.seq].content_type_mean="AP"))
       JOIN (cver
       WHERE (cver.parent_cd=temp_activity_rec->activity[d.seq].catalog_cd)
        AND cver.parent_cd > 0)
      ORDER BY cver.parent_cd, cver.event_cd
      HEAD cver.parent_cd
       activitycnt += 1
       IF (mod(activitycnt,10)=1)
        stat = alterlist(activity_rec->activity[activitycnt],(activitycnt+ 9))
       ENDIF
       activity_rec->activity[activitycnt].procedure_type_flag = 0, activity_rec->activity[
       activitycnt].catalog_cd = cver.parent_cd, activity_rec->activity[activitycnt].
       content_type_mean = temp_activity_rec->activity[d.seq].content_type_mean
      DETAIL
       stat = alterlist(activity_rec->activity[activitycnt].event_cds,1), activity_rec->activity[
       activitycnt].event_cds[1].event_cd = cver.event_cd
      WITH nocounter
     ;end select
     SELECT DISTINCT INTO "nl:"
      content_type = temp_activity_rec->activity[d.seq].content_type_mean, cver.parent_cd, cver
      .event_cd
      FROM (dummyt d  WITH seq = size(temp_activity_rec->activity,5)),
       profile_task_r ptr,
       code_value_event_r cver
      PLAN (d
       WHERE (temp_activity_rec->activity[d.seq].procedure_type_flag=1))
       JOIN (ptr
       WHERE (ptr.catalog_cd=temp_activity_rec->activity[d.seq].catalog_cd)
        AND ptr.catalog_cd > 0)
       JOIN (cver
       WHERE ((cver.parent_cd=ptr.task_assay_cd) OR (cver.parent_cd=ptr.catalog_cd))
        AND cver.parent_cd > 0)
      ORDER BY content_type, cver.parent_cd, cver.event_cd
      HEAD REPORT
       codecnt = 0
      HEAD content_type
       do_nothing = 0
      HEAD cver.parent_cd
       IF (cver.parent_cd > 0)
        activitycnt += 1
        IF (mod(activitycnt,10)=1)
         stat = alterlist(activity_rec->activity[activitycnt],(activitycnt+ 9))
        ENDIF
        activity_rec->activity[activitycnt].procedure_type_flag = 1, activity_rec->activity[
        activitycnt].catalog_cd = ptr.catalog_cd, activity_rec->activity[activitycnt].
        content_type_mean = temp_activity_rec->activity[d.seq].content_type_mean
       ENDIF
      DETAIL
       codecnt += 1
       IF (mod(codecnt,10)=1)
        stat = alterlist(activity_rec->activity[activitycnt].event_cds,(codecnt+ 9))
       ENDIF
       activity_rec->activity[activitycnt].event_cds[codecnt].event_cd = cver.event_cd
      FOOT  cver.parent_cd
       IF (cver.parent_cd > 0)
        stat = alterlist(activity_rec->activity[activitycnt].event_cds,codecnt), codecnt = 0
       ENDIF
      WITH nocounter
     ;end select
     SET stat = alterlist(activity_rec->activity,activitycnt)
    ENDIF
    SELECT DISTINCT INTO "mine"
     report_template = crt.template_name, check = activity_rec->activity[d2.seq].event_cds[d3.seq].
     event_cd, content_type_mean = activity_rec->activity[d2.seq].content_type_mean
     FROM clinical_event ce,
      cr_report_template crt,
      (dummyt d1  WITH seq = 1),
      (dummyt d2  WITH seq = value(size(activity_rec->activity,5))),
      (dummyt d3  WITH seq = 1)
     PLAN (ce
      WHERE parser(where_clause))
      JOIN (crt
      WHERE crt.report_template_id=report_template_id_chosen)
      JOIN (d1)
      JOIN (d2
      WHERE maxrec(d3,size(activity_rec->activity[d2.seq].event_cds,5)))
      JOIN (d3
      WHERE (((activity_rec->activity[d2.seq].procedure_type_flag=0)
       AND (ce.event_cd=activity_rec->activity[d2.seq].event_cds[d3.seq].event_cd)) OR ((activity_rec
      ->activity[d2.seq].procedure_type_flag=1)
       AND (ce.catalog_cd=activity_rec->activity[d2.seq].catalog_cd)
       AND (ce.event_cd=activity_rec->activity[d2.seq].event_cds[d3.seq].event_cd))) )
     ORDER BY ce.order_id, ce.event_cd
     HEAD REPORT
      cnt = 0, row + 2, col 20,
      title, row + 2, col 2,
      "Report Template: ", col 40, report_template,
      row + 1
      IF (scope_chosen=2)
       encntr = format(encntr_id_chosen,"############;L"), col 2, "Encounter ID: ",
       col 40, encntr
      ELSE
       col 2, "Accession: ", col 40,
       accession_nbr_chosen
      ENDIF
      row + 2, col 2, "CE - Event_id",
      col 20, "CE - Order_id", col 40,
      "CE - Event_cd", col 80, "CLINSIG_UPDT_DT_TM",
      col 110, "Result Status", col 140,
      "Match", row + 1, col 2,
      "-------------", col 20, "-------------",
      col 40, "---------------", col 80,
      "-----------------", col 110, "--------------",
      col 140, "-----", row + 1
     DETAIL
      col 2, ce.event_id, col 20,
      ce.order_id, event_cd = format(ce.event_cd,"############;L"), event_display = build(
       uar_get_code_display(ce.event_cd),"(",event_cd,")"),
      col 40, event_display, clinsig_updt_dt_tm = format(ce.clinsig_updt_dt_tm,";;Q"),
      col 80, clinsig_updt_dt_tm, result_status_cd_display = build(uar_get_code_display(ce
        .result_status_cd)),
      col 110, result_status_cd_display, col 140
      IF (check > 0)
       " Y ", cnt += 1
      ELSE
       " N "
      ENDIF
      row + 1
     WITH nocounter, outerjoin = d1, maxcol = 200
    ;end select
   ELSE
    CALL display_invalid_logical_domain_message(null)
   ENDIF
 END ;Subroutine
 SUBROUTINE validatecrossencounterlawqualificationforperson(null)
   SET person_id_chosen = 0.0
   CALL clear(1,1)
   CALL box(2,1,23,110)
   CALL text(3,22,"*** Validate Cross-Encounter Law Qualification for Person ***")
   CALL text(5,4,"Enter an Person_id: ")
   CALL accept(5,30,"P(40);Cf"," ")
   SET person_id_chosen = cnvtreal(curaccept)
   IF (can_user_access_this_person(null)=1)
    SET law_id_chosen = 0.0
    CALL text(7,4,"Select a Cross-Encounter Law: ")
    CALL text(9,4,"SHIFT/F5 to see a list of cross- encounter laws")
    IF (is_logical_domain_enabled_ind=1)
     SET where_clause = build2(
      "cl.law_id > 0 and cl.active_ind = 1 and cl.logical_domain_id = personnel_logical_domain_id")
    ELSE
     SET where_clause = build2("cl.law_id > 0 and cl.active_ind = 1")
    ENDIF
    SET help =
    SELECT INTO "nl:"
     cl.law_descr
     FROM chart_law cl
     WHERE parser(where_clause)
     ORDER BY cnvtupper(cl.law_descr)
     WITH nocounter
    ;end select
    CALL accept(10,4,"P(80);C")
    SET help = off
    SET law_name_chosen = trim(curaccept)
    SELECT DISTINCT INTO "nl:"
     FROM chart_law cl
     WHERE cl.law_descr=law_name_chosen
     HEAD REPORT
      law_id_chosen = cl.law_id
     WITH nocounter
    ;end select
    IF (curqual=0)
     CALL echo("no law_found")
     GO TO exit_script
    ENDIF
    FREE RECORD encntr_rec
    RECORD encntr_rec(
      1 person_id = f8
      1 person_name = vc
      1 qual[*]
        2 encntr_id = f8
        2 encntr_type_cd = f8
        2 encntr_type_cd_string = vc
        2 organization_id = f8
        2 organization_name = vc
        2 providers[*]
          3 provider_id = f8
          3 reltn_type_cd = f8
          3 provider_name = vc
          3 reltn_type_cd_string = vc
        2 locations[*]
          3 location_cd = f8
          3 location_cd_string = vc
        2 med_service_cd = f8
        2 med_service_cd_string = vc
        2 et_qual = i2
        2 org_qual = i2
        2 prov_qual = i2
        2 loc_qual = i2
        2 ms_qual = i2
        2 disch_dt_tm = dq8
        2 create_dt_tm = dq8
        2 last_clinsig_updt_dt_tm = dq8
    )
    SELECT INTO "nl:"
     name_string = build(trim(substring(1,40,p.name_last)),",",trim(substring(1,40,p.name_first)))
     FROM person p
     WHERE p.person_id=person_id_chosen
     HEAD REPORT
      encntr_rec->person_name = trim(name_string)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     e.encntr_id, d_string = format(e.disch_dt_tm,"mm/dd/yyyy hh:mm"), c_string = format(e
      .create_dt_tm,"mm/dd/yyyy hh:mm"),
     e_type_string = uar_get_code_display(e.encntr_type_cd), fac_string = uar_get_code_display(e
      .loc_facility_cd), bld_string = uar_get_code_display(e.loc_building_cd),
     nu_string = uar_get_code_display(e.loc_nurse_unit_cd), room_string = uar_get_code_display(e
      .loc_room_cd), bed_string = uar_get_code_display(e.loc_bed_cd),
     ms_string = uar_get_code_display(e.med_service_cd)
     FROM encounter e,
      organization o
     PLAN (e
      WHERE e.person_id=person_id_chosen)
      JOIN (o
      WHERE o.organization_id=e.organization_id)
     HEAD REPORT
      encntr_cnt = 0, encntr_rec->person_id = e.person_id
     DETAIL
      encntr_cnt += 1, stat = alterlist(encntr_rec->qual,encntr_cnt), encntr_rec->qual[encntr_cnt].
      encntr_id = e.encntr_id,
      encntr_rec->qual[encntr_cnt].disch_dt_tm = e.disch_dt_tm, encntr_rec->qual[encntr_cnt].
      create_dt_tm = e.create_dt_tm, encntr_rec->qual[encntr_cnt].encntr_type_cd = e.encntr_type_cd,
      encntr_rec->qual[encntr_cnt].encntr_type_cd_string = trim(e_type_string), encntr_rec->qual[
      encntr_cnt].organization_id = e.organization_id, encntr_rec->qual[encntr_cnt].organization_name
       = trim(o.org_name),
      stat = alterlist(encntr_rec->qual[encntr_cnt].locations,5), encntr_rec->qual[encntr_cnt].
      locations[1].location_cd = e.loc_facility_cd, encntr_rec->qual[encntr_cnt].locations[2].
      location_cd = e.loc_building_cd,
      encntr_rec->qual[encntr_cnt].locations[3].location_cd = e.loc_nurse_unit_cd, encntr_rec->qual[
      encntr_cnt].locations[4].location_cd = e.loc_room_cd, encntr_rec->qual[encntr_cnt].locations[5]
      .location_cd = e.loc_bed_cd,
      encntr_rec->qual[encntr_cnt].med_service_cd = e.med_service_cd, encntr_rec->qual[encntr_cnt].
      locations[1].location_cd_string = trim(fac_string), encntr_rec->qual[encntr_cnt].locations[2].
      location_cd_string = trim(bld_string),
      encntr_rec->qual[encntr_cnt].locations[3].location_cd_string = trim(nu_string), encntr_rec->
      qual[encntr_cnt].locations[4].location_cd_string = trim(room_string), encntr_rec->qual[
      encntr_cnt].locations[5].location_cd_string = trim(bed_string),
      encntr_rec->qual[encntr_cnt].med_service_cd_string = trim(ms_string)
     WITH nocounter
    ;end select
    IF (curqual=0)
     CALL echo("no encntrs found")
     GO TO exit_script
    ENDIF
    SET encntr_cnt = 0
    SET encntr_cnt = size(encntr_rec->qual,5)
    SELECT INTO "nl:"
     ce.*
     FROM clinical_event ce,
      (dummyt d  WITH seq = value(encntr_cnt))
     PLAN (d)
      JOIN (ce
      WHERE (ce.person_id=encntr_rec->person_id)
       AND (ce.encntr_id=encntr_rec->qual[d.seq].encntr_id))
     ORDER BY d.seq, ce.clinsig_updt_dt_tm DESC
     HEAD REPORT
      latest_date = cnvtdatetime("01-Jan-1800")
     HEAD d.seq
      IF (ce.clinsig_updt_dt_tm > latest_date)
       latest_date = ce.clinsig_updt_dt_tm
      ENDIF
     FOOT  d.seq
      encntr_rec->qual[d.seq].last_clinsig_updt_dt_tm = latest_date, latest_date = cnvtdatetime(
       "01-Jan-1800")
     FOOT REPORT
      do_nothing = 0
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     ppr.person_id, reltn_string = uar_get_code_display(ppr.person_prsnl_r_cd), ppr_name = build(trim
      (substring(1,10,p.name_last)),",",trim(substring(1,10,p.name_first)))
     FROM person_prsnl_reltn ppr,
      prsnl p
     PLAN (ppr
      WHERE (ppr.person_id=encntr_rec->person_id)
       AND ppr.active_ind=1
       AND ppr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND ppr.end_effective_dt_tm >= cnvtdatetime(sysdate)
       AND ppr.prsnl_person_id > 0)
      JOIN (p
      WHERE p.person_id=ppr.prsnl_person_id)
     HEAD REPORT
      prov_cnt = 0, size_encntr = 0, size_encntr = size(encntr_rec->qual,5),
      x = 0, y = 0, size_prov = 0
     DETAIL
      prov_cnt += 1, stat = alterlist(encntr_rec->qual[1].providers,prov_cnt), encntr_rec->qual[1].
      providers[prov_cnt].provider_id = ppr.prsnl_person_id,
      encntr_rec->qual[1].providers[prov_cnt].reltn_type_cd = ppr.person_prsnl_r_cd, encntr_rec->
      qual[1].providers[prov_cnt].provider_name = trim(ppr_name), encntr_rec->qual[1].providers[
      prov_cnt].reltn_type_cd_string = trim(reltn_string)
     FOOT REPORT
      IF (size_encntr > 1)
       FOR (x = 2 TO size_encntr)
        size_prov = size(encntr_rec->qual[1].providers,5),
        FOR (y = 1 TO size_prov)
          stat = alterlist(encntr_rec->qual[x].providers,size_prov), encntr_rec->qual[x].providers[y]
          .provider_id = encntr_rec->qual[1].providers[y].provider_id, encntr_rec->qual[x].providers[
          y].reltn_type_cd = encntr_rec->qual[1].providers[y].reltn_type_cd,
          encntr_rec->qual[x].providers[y].provider_name = trim(ppr_name), encntr_rec->qual[x].
          providers[y].reltn_type_cd_string = uar_get_code_display(encntr_rec->qual[x].providers[y].
           reltn_type_cd)
        ENDFOR
       ENDFOR
      ENDIF
     WITH nocounter
    ;end select
    SET size_encntr = 0
    SET size_encntr = size(encntr_rec->qual,5)
    SELECT INTO "nl:"
     epr.encntr_id, epr_name = build(trim(substring(1,10,p.name_last)),",",trim(substring(1,10,p
        .name_first))), reltn_string = uar_get_code_display(epr.encntr_prsnl_r_cd)
     FROM encntr_prsnl_reltn epr,
      (dummyt d  WITH seq = value(size_encntr)),
      prsnl p
     PLAN (d)
      JOIN (epr
      WHERE (epr.encntr_id=encntr_rec->qual[d.seq].encntr_id)
       AND epr.active_ind=1
       AND epr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND epr.end_effective_dt_tm >= cnvtdatetime(sysdate)
       AND epr.prsnl_person_id > 0)
      JOIN (p
      WHERE p.person_id=epr.prsnl_person_id)
     HEAD REPORT
      prov_cnt = 0, orig_prov_cnt = 0
     HEAD d.seq
      prov_cnt = size(encntr_rec->qual[d.seq].providers,5), orig_prov_cnt = prov_cnt
     DETAIL
      prov_cnt += 1, stat = alterlist(encntr_rec->qual[d.seq].providers,prov_cnt), encntr_rec->qual[d
      .seq].providers[prov_cnt].provider_id = epr.prsnl_person_id,
      encntr_rec->qual[d.seq].providers[prov_cnt].reltn_type_cd = epr.encntr_prsnl_r_cd, encntr_rec->
      qual[d.seq].providers[prov_cnt].provider_name = trim(epr_name), encntr_rec->qual[d.seq].
      providers[prov_cnt].reltn_type_cd_string = trim(reltn_string)
     WITH nocounter
    ;end select
    SET size_encntr = 0
    SET size_encntr = size(encntr_rec->qual,5)
    SELECT INTO "nl:"
     opr.prsnl_person_id, opr_name = build(trim(substring(1,10,p.name_last)),",",trim(substring(1,10,
        p.name_first))), reltn_string = uar_get_code_display(opr.chart_prsnl_r_type_cd)
     FROM order_prsnl_reltn opr,
      (dummyt d  WITH seq = value(size_encntr)),
      prsnl p
     PLAN (d)
      JOIN (opr
      WHERE (opr.encntr_id=encntr_rec->qual[d.seq].encntr_id)
       AND (opr.person_id=encntr_rec->person_id)
       AND opr.prsnl_person_id > 0)
      JOIN (p
      WHERE p.person_id=opr.prsnl_person_id)
     HEAD REPORT
      prov_cnt = 0, orig_prov_cnt = 0
     HEAD d.seq
      prov_cnt = size(encntr_rec->qual[d.seq].providers,5), orig_prov_cnt = prov_cnt
     DETAIL
      prov_cnt += 1, stat = alterlist(encntr_rec->qual[d.seq].providers,prov_cnt), encntr_rec->qual[d
      .seq].providers[prov_cnt].provider_id = opr.prsnl_person_id,
      encntr_rec->qual[d.seq].providers[prov_cnt].reltn_type_cd = opr.chart_prsnl_r_type_cd,
      encntr_rec->qual[d.seq].providers[prov_cnt].provider_name = trim(opr_name), encntr_rec->qual[d
      .seq].providers[prov_cnt].reltn_type_cd_string = trim(reltn_string)
     WITH nocounter
    ;end select
    FREE RECORD law_rec
    RECORD law_rec(
      1 law_id = f8
      1 law_descr = vc
      1 lookback_days = i4
      1 lookback_type_ind = i2
      1 et_included_flag = i2
      1 org_included_flag = i2
      1 prov_included_flag = i2
      1 loc_included_flag = i2
      1 ms_included_flag = i2
      1 encntr_types[*]
        2 encntr_type_cd = f8
        2 encntr_type_cd_string = vc
      1 organizations[*]
        2 organization_id = f8
        2 organization_name = vc
      1 providers[*]
        2 provider_id = f8
        2 reltn_type_cd = f8
        2 provider_name = vc
        2 reltn_type_cd_string = vc
      1 locations[*]
        2 location_cd = f8
        2 location_cd_string = vc
      1 med_services[*]
        2 med_service_cd = f8
        2 med_service_cd_string = vc
    )
    SELECT INTO "nl:"
     cl.*
     FROM chart_law cl
     WHERE cl.law_id=law_id_chosen
     HEAD REPORT
      law_rec->law_id = cl.law_id, law_rec->law_descr = trim(cl.law_descr), law_rec->lookback_days =
      cl.lookback_days,
      law_rec->lookback_type_ind = cl.lookback_type_ind
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     clf.*
     FROM chart_law_filter clf
     WHERE (clf.law_id=law_rec->law_id)
     HEAD REPORT
      do_nothing = 0, law_rec->et_included_flag = 99, law_rec->org_included_flag = 99,
      law_rec->prov_included_flag = 99, law_rec->loc_included_flag = 99, law_rec->ms_included_flag =
      99
     DETAIL
      IF (clf.type_flag=0)
       law_rec->et_included_flag = clf.included_flag
      ENDIF
      IF (clf.type_flag=1)
       law_rec->org_included_flag = clf.included_flag
      ENDIF
      IF (clf.type_flag=2)
       law_rec->prov_included_flag = clf.included_flag
      ENDIF
      IF (clf.type_flag=3)
       law_rec->loc_included_flag = clf.included_flag
      ENDIF
      IF (clf.type_flag=4)
       law_rec->ms_included_flag = clf.included_flag
      ENDIF
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     clfv.*
     FROM chart_law_filter_value clfv
     WHERE (clfv.law_id=law_rec->law_id)
     ORDER BY clfv.type_flag, clfv.parent_entity_id
     HEAD REPORT
      et_cnt = 0, org_cnt = 0, prov_cnt = 0,
      loc_cnt = 0, ms_cnt = 0
     DETAIL
      IF (clfv.type_flag=0)
       et_cnt += 1, stat = alterlist(law_rec->encntr_types,et_cnt), law_rec->encntr_types[et_cnt].
       encntr_type_cd = clfv.parent_entity_id,
       law_rec->encntr_types[et_cnt].encntr_type_cd_string = uar_get_code_display(clfv
        .parent_entity_id)
      ENDIF
      IF (clfv.type_flag=1)
       org_cnt += 1, stat = alterlist(law_rec->organizations,org_cnt), law_rec->organizations[org_cnt
       ].organization_id = clfv.parent_entity_id,
       law_rec->organizations[org_cnt].organization_name = ""
      ENDIF
      IF (clfv.type_flag=2)
       prov_cnt += 1, stat = alterlist(law_rec->providers,prov_cnt), law_rec->providers[prov_cnt].
       provider_id = clfv.parent_entity_id,
       law_rec->providers[prov_cnt].reltn_type_cd = clfv.reltn_type_cd, law_rec->providers[prov_cnt].
       provider_name = "", law_rec->providers[prov_cnt].reltn_type_cd_string = uar_get_code_display(
        clfv.reltn_type_cd)
      ENDIF
      IF (clfv.type_flag=3)
       loc_cnt += 1, stat = alterlist(law_rec->locations,loc_cnt), law_rec->locations[loc_cnt].
       location_cd = clfv.parent_entity_id,
       law_rec->locations[loc_cnt].location_cd_string = uar_get_code_display(clfv.parent_entity_id)
      ENDIF
      IF (clfv.type_flag=4)
       ms_cnt += 1, stat = alterlist(law_rec->med_services,ms_cnt), law_rec->med_services[ms_cnt].
       med_service_cd = clfv.parent_entity_id,
       law_rec->med_services[ms_cnt].med_service_cd_string = uar_get_code_display(clfv
        .parent_entity_id)
      ENDIF
     WITH nocounter
    ;end select
    SET size_encntr = 0
    SET size_encntr = size(encntr_rec->qual,5)
    IF ((law_rec->et_included_flag != 99))
     SET found_et = 0
     SET orig_found_et = 0
    ELSE
     SET found_et = 99
     SET orig_found_et = 99
    ENDIF
    IF ((law_rec->org_included_flag != 99))
     SET found_org = 0
     SET orig_found_org = 0
    ELSE
     SET found_org = 99
     SET orig_found_org = 99
    ENDIF
    IF ((law_rec->prov_included_flag != 99))
     SET found_prov = 0
     SET orig_found_prov = 0
    ELSE
     SET found_prov = 99
     SET orig_found_prov = 99
    ENDIF
    IF ((law_rec->loc_included_flag != 99))
     SET found_loc = 0
     SET orig_found_loc = 0
    ELSE
     SET found_loc = 99
     SET orig_found_loc = 99
    ENDIF
    IF ((law_rec->ms_included_flag != 99))
     SET found_ms = 0
     SET orig_found_ms = 0
    ELSE
     SET found_ms = 99
     SET orig_found_ms = 99
    ENDIF
    SET size_et = 0
    SET size_org = 0
    SET size_prov = 0
    SET size_loc = 0
    SET size_ms = 0
    SET size_e_prov = 0
    SET size_e_loc = 0
    SET p = 0
    SET z = 0
    SET size_et = size(law_rec->encntr_types,5)
    SET size_org = size(law_rec->organizations,5)
    SET size_prov = size(law_rec->providers,5)
    SET size_loc = size(law_rec->locations,5)
    SET size_ms = size(law_rec->med_services,5)
    FOR (x = 1 TO size_encntr)
      FOR (y = 1 TO size_et)
        IF ((encntr_rec->qual[x].encntr_type_cd=law_rec->encntr_types[y].encntr_type_cd))
         SET found_et = 1
         CALL echo("found_et = 1")
         CALL echo(build("e_rec = ",encntr_rec->qual[x].encntr_type_cd," / law_rec = ",law_rec->
           encntr_types[y].encntr_type_cd))
         SET y = size_et
        ENDIF
      ENDFOR
      CALL echo(build("et_included_flag = ",law_rec->et_included_flag))
      IF ((law_rec->et_included_flag=99))
       SET encntr_rec->qual[x].et_qual = 99
      ELSEIF ((law_rec->et_included_flag=0))
       IF (found_et=0)
        SET encntr_rec->qual[x].et_qual = 1
       ELSE
        SET encntr_rec->qual[x].et_qual = 0
       ENDIF
      ELSE
       IF (found_et=1)
        SET encntr_rec->qual[x].et_qual = 1
       ELSE
        SET encntr_rec->qual[x].et_qual = 0
       ENDIF
      ENDIF
      SET found_et = orig_found_et
    ENDFOR
    FOR (x = 1 TO size_encntr)
      FOR (y = 1 TO size_org)
        IF ((encntr_rec->qual[x].organization_id=law_rec->organizations[y].organization_id))
         SET found_org = 1
         SET y = size_org
        ENDIF
      ENDFOR
      IF ((law_rec->org_included_flag=99))
       SET encntr_rec->qual[x].org_qual = 99
      ELSEIF ((law_rec->org_included_flag=0))
       IF (found_org=0)
        SET encntr_rec->qual[x].org_qual = 1
       ELSE
        SET encntr_rec->qual[x].org_qual = 0
       ENDIF
      ELSE
       IF (found_org=1)
        SET encntr_rec->qual[x].org_qual = 1
       ELSE
        SET encntr_rec->qual[x].org_qual = 0
       ENDIF
      ENDIF
      SET found_org = orig_found_org
    ENDFOR
    FOR (x = 1 TO size_encntr)
      SET size_e_prov = size(encntr_rec->qual[x].providers,5)
      FOR (p = 1 TO size_e_prov)
       FOR (y = 1 TO size_prov)
         IF ((encntr_rec->qual[x].providers[p].provider_id=law_rec->providers[y].provider_id)
          AND (encntr_rec->qual[x].providers[p].reltn_type_cd=law_rec->providers[y].reltn_type_cd))
          SET found_prov = 1
          SET y = size_prov
         ENDIF
       ENDFOR
       IF (found_prov=1)
        SET p = size_e_prov
       ENDIF
      ENDFOR
      IF ((law_rec->prov_included_flag=99))
       SET encntr_rec->qual[x].prov_qual = 99
      ELSEIF ((law_rec->prov_included_flag=0))
       IF (found_prov=0)
        SET encntr_rec->qual[x].prov_qual = 1
       ELSE
        SET encntr_rec->qual[x].prov_qual = 0
       ENDIF
      ELSE
       IF (found_prov=1)
        SET encntr_rec->qual[x].prov_qual = 1
       ELSE
        SET encntr_rec->qual[x].prov_qual = 0
       ENDIF
      ENDIF
      SET found_prov = orig_found_prov
    ENDFOR
    FOR (x = 1 TO size_encntr)
      SET size_e_loc = size(encntr_rec->qual[x].locations,5)
      FOR (z = 1 TO size_e_loc)
       FOR (y = 1 TO size_loc)
         IF ((encntr_rec->qual[x].locations[z].location_cd=law_rec->locations[y].location_cd))
          SET found_loc = 1
          SET y = size_loc
         ENDIF
       ENDFOR
       IF (found_loc=1)
        SET z = size_e_loc
       ENDIF
      ENDFOR
      IF ((law_rec->loc_included_flag=99))
       SET encntr_rec->qual[x].loc_qual = 99
      ELSEIF ((law_rec->loc_included_flag=0))
       IF (found_loc=0)
        SET encntr_rec->qual[x].loc_qual = 1
       ELSE
        SET encntr_rec->qual[x].loc_qual = 0
       ENDIF
      ELSE
       IF (found_loc=1)
        SET encntr_rec->qual[x].loc_qual = 1
       ELSE
        SET encntr_rec->qual[x].loc_qual = 0
       ENDIF
      ENDIF
      SET found_loc = orig_found_loc
    ENDFOR
    FOR (x = 1 TO size_encntr)
      FOR (y = 1 TO size_ms)
        IF ((encntr_rec->qual[x].med_service_cd=law_rec->med_services[y].med_service_cd))
         SET found_ms = 1
         SET y = size_ms
        ENDIF
      ENDFOR
      IF ((law_rec->ms_included_flag=99))
       SET encntr_rec->qual[x].ms_qual = 99
      ELSEIF ((law_rec->ms_included_flag=0))
       IF (found_ms=0)
        SET encntr_rec->qual[x].ms_qual = 1
       ELSE
        SET encntr_rec->qual[x].ms_qual = 0
       ENDIF
      ELSE
       IF (found_ms=1)
        SET encntr_rec->qual[x].ms_qual = 1
       ELSE
        SET encntr_rec->qual[x].ms_qual = 0
       ENDIF
      ENDIF
      SET found_ms = orig_found_ms
    ENDFOR
    SET size_orgs = size(law_rec->organizations,5)
    IF (size_orgs > 0)
     SELECT INTO "nl:"
      o.org_name
      FROM organization o,
       (dummyt d  WITH seq = value(size_orgs))
      PLAN (d)
       JOIN (o
       WHERE (o.organization_id=law_rec->organizations[d.seq].organization_id))
      HEAD REPORT
       do_nothing = 0
      DETAIL
       law_rec->organizations[d.seq].organization_name = trim(o.org_name)
      WITH nocounter
     ;end select
    ENDIF
    SET size_prov = size(law_rec->providers,5)
    SELECT INTO "nl:"
     name_string = build(trim(substring(1,10,p.name_last)),",",trim(substring(1,10,p.name_first)))
     FROM (dummyt d  WITH seq = value(size_prov)),
      prsnl p
     PLAN (d)
      JOIN (p
      WHERE (p.person_id=law_rec->providers[d.seq].provider_id))
     HEAD REPORT
      do_nothing = 0
     DETAIL
      law_rec->providers[d.seq].provider_name = trim(name_string)
     WITH nocounter
    ;end select
    SELECT INTO "mine"
     cl.*
     FROM chart_law cl
     WHERE cl.law_id=law_id_chosen
     HEAD REPORT
      row + 2, col 2, "Person ID:",
      col 40, person_id_chosen";l", row + 1,
      col 2, "Cross Encounter Law ID:", col 40,
      law_id_chosen";l", row + 2, col 2,
      "Encounter ID", col 17, "Create Date/Time",
      col 40, "Discharged Date/Time", col 70,
      "Last Clin Sig Date/Time", col 100, "Encounter Type",
      col 120, "Organization", col 140,
      "Location", col 160, "Medical Service",
      col 180, "Providers", row + 1,
      col 2, "-------------", col 17,
      "----------------", col 40, "-------------------",
      col 70, "----------------------", col 100,
      "--------------", col 120, "--------------",
      col 140, "--------------", col 160,
      "--------------", col 180, "----------",
      row + 1, size_encntr = size(encntr_rec->qual,5), x = 0
     DETAIL
      do_nothing = 0
     FOOT REPORT
      FOR (x = 1 TO size_encntr)
        row + 1, col 2, encntr_rec->qual[x].encntr_id";l",
        col 17, encntr_rec->qual[x].create_dt_tm"@SHORTDATETIME", col 40,
        encntr_rec->qual[x].disch_dt_tm"@SHORTDATETIME", col 70, encntr_rec->qual[x].
        last_clinsig_updt_dt_tm"@SHORTDATETIME",
        col 100
        IF ((encntr_rec->qual[x].et_qual=1))
         "PASSED"
        ELSEIF ((encntr_rec->qual[x].et_qual=0))
         "FAILED"
        ELSE
         " --- "
        ENDIF
        col 120
        IF ((encntr_rec->qual[x].org_qual=1))
         "PASSED"
        ELSEIF ((encntr_rec->qual[x].org_qual=0))
         "FAILED"
        ELSE
         " --- "
        ENDIF
        col 140
        IF ((encntr_rec->qual[x].loc_qual=1))
         "PASSED"
        ELSEIF ((encntr_rec->qual[x].loc_qual=0))
         "FAILED"
        ELSE
         " --- "
        ENDIF
        col 160
        IF ((encntr_rec->qual[x].ms_qual=1))
         "PASSED"
        ELSEIF ((encntr_rec->qual[x].ms_qual=0))
         "FAILED"
        ELSE
         " --- "
        ENDIF
        col 180
        IF ((encntr_rec->qual[x].prov_qual=1))
         "PASSED"
        ELSEIF ((encntr_rec->qual[x].prov_qual=0))
         "FAILED"
        ELSE
         " --- "
        ENDIF
      ENDFOR
     WITH nocounter, maxcol = 250
    ;end select
   ELSE
    CALL display_invalid_logical_domain_message(null)
   ENDIF
 END ;Subroutine
 SUBROUTINE getproviderrelationship(null)
   CALL clear(1,1)
   CALL box(2,1,23,110)
   CALL text(3,22,"*** View Provider Relationship ***")
   CALL text(5,4,"Select Scope: ")
   CALL text(6,4,"1=Person, 2=Encounter, 4=Accession")
   CALL accept(7,4,"99;",02
    WHERE curaccept IN (01, 02, 04))
   SET person_id_chosen = 0.0
   SET encntr_id_chosen = 0.0
   SET scope_chosen = 0
   SET scope_chosen = cnvtint(curaccept)
   IF (scope_chosen=1)
    CALL text(9,4,"Choose a Person_id:")
    CALL accept(9,30,"P(40);Cf"," ")
    SET person_id_chosen = cnvtreal(curaccept)
   ELSEIF (scope_chosen=2)
    CALL text(9,4,"Choose an Encntr_id:")
    CALL accept(9,30,"P(40);Cf"," ")
    SET encntr_id_chosen = cnvtreal(curaccept)
   ELSEIF (scope_chosen=4)
    CALL text(9,4,"Enter an Accession Number:")
    CALL accept(15,4,"P(40);C"," ")
    SET accession_nbr_chosen = curaccept
   ELSE
    CALL text(9,4,"Choose a Person_id:")
    CALL accept(9,30,"P(40);Cf"," ")
    SET person_id_chosen = cnvtreal(curaccept)
   ENDIF
   IF (scope_chosen=1)
    IF (can_user_access_this_person(null)=1)
     SELECT INTO "mine"
      p.name_full_formatted
      FROM person_prsnl_reltn ppr,
       code_value cv,
       prsnl p
      PLAN (ppr
       WHERE ppr.person_id=person_id_chosen)
       JOIN (cv
       WHERE cv.code_value=ppr.person_prsnl_r_cd)
       JOIN (p
       WHERE p.person_id=ppr.prsnl_person_id)
      ORDER BY cnvtupper(p.name_full_formatted)
      HEAD REPORT
       do_nothing = 0, pers_prsnl_cnt = 1
      DETAIL
       IF (mod(pers_prsnl_cnt,10)=1)
        stat = alterlist(pers_prsnl_rec->qual,(pers_prsnl_cnt+ 9))
       ENDIF
       pers_prsnl_rec->qual[pers_prsnl_cnt].prsnl_person_id = ppr.prsnl_person_id, pers_prsnl_rec->
       qual[pers_prsnl_cnt].reltn_cd = cv.display, pers_prsnl_rec->qual[pers_prsnl_cnt].prsnl_name =
       p.name_full_formatted,
       pers_prsnl_rec->qual[pers_prsnl_cnt].beg_effective_dt_tm = ppr.beg_effective_dt_tm,
       pers_prsnl_rec->qual[pers_prsnl_cnt].end_effective_dt_tm = ppr.end_effective_dt_tm,
       pers_prsnl_cnt += 1
      FOOT REPORT
       row + 1, col 2, "Person ID: ",
       col 15, person_id_chosen, row + 3,
       col 2, "Person-Level Providers", row + 1,
       col 2, "=========================", row + 2,
       col 2, "Personnel ID", col 20,
       "Provider Name", col 45, "Provider Relationship",
       col 70, "Effective From", col 100,
       "Effective To", row + 1, col 2,
       "--------", col 20, "-------------",
       col 45, "---------------------", col 70,
       "--------------", col 100, "-------------",
       row + 1
       FOR (x = 1 TO (pers_prsnl_cnt - 1))
         effective_from = format(pers_prsnl_rec->qual[x].beg_effective_dt_tm,";;Q"), effective_to =
         format(pers_prsnl_rec->qual[x].end_effective_dt_tm,";;Q"), col 2,
         pers_prsnl_rec->qual[x].prsnl_person_id, col 20, pers_prsnl_rec->qual[x].prsnl_name,
         col 45, pers_prsnl_rec->qual[x].reltn_cd, col 70,
         effective_from, col 100
         IF ((pers_prsnl_rec->qual[x].end_effective_dt_tm >= cnvtdatetime(sysdate)))
          "Current"
         ELSE
          effective_to
         ENDIF
         row + 1
       ENDFOR
      WITH nocounter
     ;end select
    ELSE
     SELECT INTO "mine"
      FROM dummyt
      FOOT REPORT
       row + 2, col 40, invalid_logical_domain_message
      WITH nocounter
     ;end select
    ENDIF
   ELSEIF (scope_chosen=2)
    IF (can_user_access_this_encounter(null)=1)
     SELECT INTO "nl:"
      e.person_id
      FROM encounter e
      WHERE e.encntr_id=encntr_id_chosen
      HEAD REPORT
       person_id_chosen = e.person_id
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      p.name_full_formatted
      FROM person_prsnl_reltn ppr,
       code_value cv,
       prsnl p
      PLAN (ppr
       WHERE ppr.person_id=person_id_chosen)
       JOIN (cv
       WHERE cv.code_value=ppr.person_prsnl_r_cd)
       JOIN (p
       WHERE p.person_id=ppr.prsnl_person_id)
      ORDER BY cnvtupper(p.name_full_formatted)
      HEAD REPORT
       do_nothing = 0, pers_prsnl_cnt = 1
      DETAIL
       IF (mod(pers_prsnl_cnt,10)=1)
        stat = alterlist(pers_prsnl_rec->qual,(pers_prsnl_cnt+ 9))
       ENDIF
       pers_prsnl_rec->qual[pers_prsnl_cnt].prsnl_person_id = ppr.prsnl_person_id, pers_prsnl_rec->
       qual[pers_prsnl_cnt].reltn_cd = cv.display, pers_prsnl_rec->qual[pers_prsnl_cnt].prsnl_name =
       p.name_full_formatted,
       pers_prsnl_rec->qual[pers_prsnl_cnt].beg_effective_dt_tm = ppr.beg_effective_dt_tm,
       pers_prsnl_rec->qual[pers_prsnl_cnt].end_effective_dt_tm = ppr.end_effective_dt_tm,
       pers_prsnl_cnt += 1
      WITH nocounter
     ;end select
     SELECT INTO "mine"
      p.name_full_formatted
      FROM encntr_prsnl_reltn epr,
       code_value cv,
       prsnl p
      PLAN (epr
       WHERE epr.encntr_id=encntr_id_chosen)
       JOIN (cv
       WHERE cv.code_value=epr.encntr_prsnl_r_cd)
       JOIN (p
       WHERE p.person_id=epr.prsnl_person_id)
      ORDER BY cnvtupper(p.name_full_formatted)
      HEAD REPORT
       do_nothing = 0, enc_prsnl_cnt = 1
      DETAIL
       IF (mod(enc_prsnl_cnt,10)=1)
        stat = alterlist(enc_prsnl_rec->qual,(enc_prsnl_cnt+ 9))
       ENDIF
       enc_prsnl_rec->qual[enc_prsnl_cnt].prsnl_person_id = epr.prsnl_person_id, enc_prsnl_rec->qual[
       enc_prsnl_cnt].reltn_cd = cv.display, enc_prsnl_rec->qual[enc_prsnl_cnt].prsnl_name = p
       .name_full_formatted,
       enc_prsnl_rec->qual[enc_prsnl_cnt].beg_effective_dt_tm = epr.beg_effective_dt_tm,
       enc_prsnl_rec->qual[enc_prsnl_cnt].end_effective_dt_tm = epr.end_effective_dt_tm,
       enc_prsnl_cnt += 1
      FOOT REPORT
       row + 1, col 2, "Encounter ID: ",
       col 15, encntr_id_chosen, row + 3,
       col 2, "Person-Level Providers", row + 1,
       col 2, "=========================", row + 2,
       col 2, "Personnel ID", col 20,
       "Provider Name", col 45, "Provider Relationship",
       col 70, "Effective From", col 100,
       "Effective To", row + 1, col 2,
       "--------", col 20, "-------------",
       col 45, "---------------------", col 70,
       "--------------", col 100, "-------------",
       row + 1
       FOR (x = 1 TO (pers_prsnl_cnt - 1))
         effective_from = format(pers_prsnl_rec->qual[x].beg_effective_dt_tm,";;Q"), effective_to =
         format(pers_prsnl_rec->qual[x].end_effective_dt_tm,";;Q"), col 2,
         pers_prsnl_rec->qual[x].prsnl_person_id, col 20, pers_prsnl_rec->qual[x].prsnl_name,
         col 45, pers_prsnl_rec->qual[x].reltn_cd, col 70,
         effective_from, col 100
         IF ((pers_prsnl_rec->qual[x].end_effective_dt_tm >= cnvtdatetime(sysdate)))
          "Current"
         ELSE
          effective_to
         ENDIF
         row + 1
       ENDFOR
       row + 3, col 2, "Encounter-Level Providers",
       row + 1, col 2, "=========================",
       row + 1, col 2, "Personnel ID",
       col 20, "Provider Name", col 45,
       "Provider Relationship", col 70, "Effective From",
       col 100, "Effective To", row + 1,
       col 2, "--------", col 20,
       "-------------", col 45, "---------------------",
       col 70, "--------------", col 100,
       "-------------", row + 1
       FOR (x = 1 TO (enc_prsnl_cnt - 1))
         effective_from = format(enc_prsnl_rec->qual[x].beg_effective_dt_tm,";;Q"), effective_to =
         format(enc_prsnl_rec->qual[x].end_effective_dt_tm,";;Q"), col 2,
         enc_prsnl_rec->qual[x].prsnl_person_id, col 20, enc_prsnl_rec->qual[x].prsnl_name,
         col 45, enc_prsnl_rec->qual[x].reltn_cd, col 70,
         effective_from, col 100
         IF ((enc_prsnl_rec->qual[x].end_effective_dt_tm >= cnvtdatetime(sysdate)))
          "Current"
         ELSE
          effective_to
         ENDIF
         row + 1
       ENDFOR
      WITH nocounter
     ;end select
    ELSE
     SELECT INTO "mine"
      FROM dummyt
      FOOT REPORT
       row + 2, col 40, invalid_logical_domain_message
      WITH nocounter
     ;end select
    ENDIF
   ELSEIF (scope_chosen=4)
    IF (can_user_access_this_acc(null)=1)
     SELECT INTO "nl:"
      o.encntr_id, p.person_id
      FROM accession_order_r ar,
       orders o,
       encounter e,
       person p
      PLAN (ar
       WHERE ar.accession=accession_nbr_chosen)
       JOIN (o
       WHERE o.order_id=ar.order_id)
       JOIN (e
       WHERE e.encntr_id=o.encntr_id)
       JOIN (p
       WHERE p.person_id=e.person_id)
      GROUP BY o.encntr_id, p.person_id
      HEAD REPORT
       person_id_chosen = p.person_id, encntr_id_chosen = o.encntr_id
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      p.name_full_formatted
      FROM person_prsnl_reltn ppr,
       code_value cv,
       prsnl p
      PLAN (ppr
       WHERE ppr.person_id=person_id_chosen)
       JOIN (cv
       WHERE cv.code_value=ppr.person_prsnl_r_cd)
       JOIN (p
       WHERE p.person_id=ppr.prsnl_person_id)
      ORDER BY cnvtupper(p.name_full_formatted)
      HEAD REPORT
       do_nothing = 0, pers_prsnl_cnt = 1
      DETAIL
       IF (mod(pers_prsnl_cnt,10)=1)
        stat = alterlist(pers_prsnl_rec->qual,(pers_prsnl_cnt+ 9))
       ENDIF
       pers_prsnl_rec->qual[pers_prsnl_cnt].prsnl_person_id = ppr.prsnl_person_id, pers_prsnl_rec->
       qual[pers_prsnl_cnt].reltn_cd = cv.display, pers_prsnl_rec->qual[pers_prsnl_cnt].prsnl_name =
       p.name_full_formatted,
       pers_prsnl_rec->qual[pers_prsnl_cnt].beg_effective_dt_tm = ppr.beg_effective_dt_tm,
       pers_prsnl_rec->qual[pers_prsnl_cnt].end_effective_dt_tm = ppr.end_effective_dt_tm,
       pers_prsnl_cnt += 1
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      p.name_full_formatted
      FROM encntr_prsnl_reltn epr,
       code_value cv,
       prsnl p
      PLAN (epr
       WHERE epr.encntr_id=encntr_id_chosen)
       JOIN (cv
       WHERE cv.code_value=epr.encntr_prsnl_r_cd)
       JOIN (p
       WHERE p.person_id=epr.prsnl_person_id)
      ORDER BY cnvtupper(p.name_full_formatted)
      HEAD REPORT
       do_nothing = 0, enc_prsnl_cnt = 1
      DETAIL
       IF (mod(enc_prsnl_cnt,10)=1)
        stat = alterlist(enc_prsnl_rec->qual,(enc_prsnl_cnt+ 9))
       ENDIF
       enc_prsnl_rec->qual[enc_prsnl_cnt].prsnl_person_id = epr.prsnl_person_id, enc_prsnl_rec->qual[
       enc_prsnl_cnt].reltn_cd = cv.display, enc_prsnl_rec->qual[enc_prsnl_cnt].prsnl_name = p
       .name_full_formatted,
       enc_prsnl_rec->qual[enc_prsnl_cnt].beg_effective_dt_tm = epr.beg_effective_dt_tm,
       enc_prsnl_rec->qual[enc_prsnl_cnt].end_effective_dt_tm = epr.end_effective_dt_tm,
       enc_prsnl_cnt += 1
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      od.oe_field_value, od.oe_field_meaning, od.oe_field_display_value,
      od.order_id
      FROM accession_order_r ar,
       order_detail od
      PLAN (ar
       WHERE ar.accession=accession_nbr_chosen)
       JOIN (od
       WHERE od.order_id=ar.order_id
        AND od.oe_field_meaning_id IN (oe_field_meaning_id_ccprovider, oe_field_meaning_id_consultdoc
       ))
      GROUP BY od.oe_field_value, od.oe_field_meaning, od.oe_field_display_value,
       od.order_id
      ORDER BY od.oe_field_display_value
      HEAD REPORT
       do_nothing = 0, consulting_prsnl_cnt = 1
      DETAIL
       IF (mod(consulting_prsnl_cnt,10)=1)
        stat = alterlist(consulting_prsnl_rec->qual,(consulting_prsnl_cnt+ 9))
       ENDIF
       consulting_prsnl_rec->qual[consulting_prsnl_cnt].prsnl_person_id = od.oe_field_value,
       consulting_prsnl_rec->qual[consulting_prsnl_cnt].reltn_cd = od.oe_field_meaning,
       consulting_prsnl_rec->qual[consulting_prsnl_cnt].prsnl_name = od.oe_field_display_value,
       consulting_prsnl_rec->qual[consulting_prsnl_cnt].order_id = od.order_id, consulting_prsnl_cnt
        += 1
      WITH nocounter
     ;end select
     SELECT INTO "mine"
      p.person_id, oa.action_type_cd, p.name_full_formatted,
      oa.order_id
      FROM accession_order_r ar,
       order_action oa,
       prsnl p
      PLAN (ar
       WHERE ar.accession=accession_nbr_chosen)
       JOIN (oa
       WHERE oa.order_id=ar.order_id
        AND oa.action_type_cd IN (order_cd, activate_cd, modify_cd, renew_cd, resume_cd,
       stud_activate_cd)
        AND oa.action_rejected_ind=0)
       JOIN (p
       WHERE p.person_id=oa.order_provider_id)
      GROUP BY p.person_id, oa.action_type_cd, p.name_full_formatted,
       oa.order_id
      ORDER BY cnvtupper(p.name_full_formatted)
      HEAD REPORT
       do_nothing = 0, ordering_prsnl_cnt = 1
      DETAIL
       stat = alterlist(ordering_prsnl_rec->qual,(ordering_prsnl_cnt+ 9)), ordering_prsnl_rec->qual[
       ordering_prsnl_cnt].prsnl_person_id = p.person_id, ordering_prsnl_rec->qual[ordering_prsnl_cnt
       ].reltn_cd = "Ordering Physician",
       ordering_prsnl_rec->qual[ordering_prsnl_cnt].prsnl_name = p.name_full_formatted,
       ordering_prsnl_rec->qual[ordering_prsnl_cnt].order_id = oa.order_id, ordering_prsnl_cnt += 1
      FOOT REPORT
       row + 1, col 2, "Accession:",
       col 15, accession_nbr_chosen, row + 3,
       col 2, "Person-Level Providers", row + 1,
       col 2, "=========================", row + 1,
       col 8, "Personnel ID", col 30,
       "Provider Name", col 60, "Provider Relationship",
       row + 1, col 8, "--------",
       col 30, "-------------", col 60,
       "---------------------", row + 1
       FOR (x = 1 TO (pers_prsnl_cnt - 1))
         effective_from = format(pers_prsnl_rec->qual[x].beg_effective_dt_tm,";;Q"), effective_to =
         format(pers_prsnl_rec->qual[x].end_effective_dt_tm,";;Q"), col 5,
         pers_prsnl_rec->qual[x].prsnl_person_id, col 30, pers_prsnl_rec->qual[x].prsnl_name,
         col 60, pers_prsnl_rec->qual[x].reltn_cd, row + 1
       ENDFOR
       row + 3, col 2, "Encounter-Level Providers",
       row + 1, col 2, "=========================",
       row + 1, col 8, "Personnel ID",
       col 30, "Provider Name", col 60,
       "Provider Relationship", row + 1, col 8,
       "--------", col 30, "-------------",
       col 60, "---------------------", row + 1
       FOR (x = 1 TO (enc_prsnl_cnt - 1))
         effective_from = format(enc_prsnl_rec->qual[x].beg_effective_dt_tm,";;Q"), effective_to =
         format(enc_prsnl_rec->qual[x].end_effective_dt_tm,";;Q"), col 5,
         enc_prsnl_rec->qual[x].prsnl_person_id, col 30, enc_prsnl_rec->qual[x].prsnl_name,
         col 60, enc_prsnl_rec->qual[x].reltn_cd, row + 1
       ENDFOR
       row + 3, col 2, "Order-Level Providers",
       row + 1, col 2, "=========================",
       row + 2, col 8, "Personnel ID",
       col 30, "Provider Name", col 60,
       "Provider Relationship", col 100, "Order ID",
       row + 1, col 8, "--------",
       col 30, "-------------", col 60,
       "---------------------", col 100, "--------",
       row + 1
       FOR (x = 1 TO (consulting_prsnl_cnt - 1))
         col 5, consulting_prsnl_rec->qual[x].prsnl_person_id, col 30,
         consulting_prsnl_rec->qual[x].prsnl_name, col 60, consulting_prsnl_rec->qual[x].reltn_cd,
         col 100, consulting_prsnl_rec->qual[x].order_id, row + 1
       ENDFOR
       FOR (x = 1 TO (ordering_prsnl_cnt - 1))
         col 5, ordering_prsnl_rec->qual[x].prsnl_person_id, col 30,
         ordering_prsnl_rec->qual[x].prsnl_name, col 60, ordering_prsnl_rec->qual[x].reltn_cd,
         col 100, ordering_prsnl_rec->qual[x].order_id, row + 1
       ENDFOR
      WITH nocounter, maxcol = 200
     ;end select
    ELSE
     CALL display_invalid_logical_domain_message(null)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE getencounterdetails(null)
   SET encntr_id_chosen = 0.0
   CALL clear(1,1)
   CALL box(2,1,23,110)
   CALL text(3,22,"*** View Encounter Details ***")
   CALL text(5,4,"Enter an Encntr_id: ")
   CALL accept(5,30,"P(40);Cf"," ")
   SET encntr_id_chosen = cnvtreal(curaccept)
   IF (can_user_access_this_encounter(null)=1)
    SELECT INTO "mine"
     e.person_id, person_id = format(p.name_full_formatted,"####################;L"), e.updt_dt_tm,
     updt_dt_tm = format(e.updt_dt_tm,";;Q;R"), e.create_dt_tm, create_dt_tm = format(e.create_dt_tm,
      ";;Q;R"),
     e.encntr_type_cd, encntr_type_cd = format(uar_get_code_display(e.encntr_type_cd),
      "####################;L"), e.encntr_status_cd,
     encntr_status_cd = format(uar_get_code_display(e.encntr_status_cd),"####################;L"), e
     .med_service_cd, med_service_cd = format(uar_get_code_display(e.med_service_cd),
      "####################;L"),
     e.location_cd, location_cd = format(uar_get_code_display(e.location_cd),"####################;L"
      ), e.loc_facility_cd,
     loc_facility_cd = format(uar_get_code_display(e.loc_facility_cd),"####################;L"), e
     .loc_building_cd, loc_building_cd = format(uar_get_code_display(e.loc_building_cd),
      "####################;L"),
     e.loc_nurse_unit_cd, loc_nurse_unit_cd = format(uar_get_code_display(e.loc_nurse_unit_cd),
      "####################;L"), e.loc_room_cd,
     loc_room_cd = format(uar_get_code_display(e.loc_room_cd),"####################;L"), e.loc_bed_cd,
     loc_bed_cd = format(uar_get_code_display(e.loc_bed_cd),"####################;L"),
     e.disch_dt_tm, disch_dt_tm = format(e.disch_dt_tm,";;Q;R"), e.organization_id,
     organization_id = format(o.org_name,"#####################;L")
     FROM encounter e,
      organization o,
      person p
     PLAN (e
      WHERE e.encntr_id=encntr_id_chosen)
      JOIN (o
      WHERE o.organization_id=e.organization_id)
      JOIN (p
      WHERE p.person_id=e.person_id)
     HEAD REPORT
      row + 1, linex = fillstring(130,"-"), col 18,
      "Encounter Details", col 50, "Encounter ID: ",
      col 65, encntr_id_chosen, row + 1,
      col 18, "-----------------", row + 2
     HEAD PAGE
      row + 1
     DETAIL
      IF (e.encntr_id > 0)
       IF (e.disch_dt_tm > cnvtdatetime("01-jan-1800"))
        disch_ind = "* Discharged *"
       ELSE
        disch_ind = " "
       ENDIF
       col 2, "Person: ", col 20,
       e.person_id, col 40, person_id,
       row + 1, col 2, "Update Date/Time: ",
       col 40, updt_dt_tm, row + 1,
       col 2, "Create Date/Time: ", col 40,
       create_dt_tm, row + 1, col 2,
       "Encounter Type: ", col 20, e.encntr_type_cd,
       col 40, encntr_type_cd, row + 1,
       col 2, "Encounter Status: ", col 20,
       e.encntr_status_cd, col 40, encntr_status_cd,
       row + 1, col 2, "Medical Service: ",
       col 20, e.med_service_cd, col 40,
       med_service_cd, row + 1, col 2,
       "Location: ", col 20, e.location_cd,
       col 40, location_cd, row + 1,
       col 2, "Facility: ", col 20,
       e.loc_facility_cd, col 40, loc_facility_cd,
       row + 1, col 2, "Building: ",
       col 20, e.loc_building_cd, col 40,
       loc_building_cd, row + 1, col 2,
       "Nurse Unit: ", col 20, e.loc_nurse_unit_cd,
       col 40, loc_nurse_unit_cd, row + 1,
       col 2, "Room: ", col 20,
       e.loc_room_cd, col 40, loc_room_cd,
       row + 1, col 2, "Bed: ",
       col 20, e.loc_bed_cd, col 40,
       loc_bed_cd, row + 1, col 2,
       "Discharge Date/Time: ", col 40, disch_dt_tm,
       col 65, disch_ind, row + 1,
       col 2, "Organization: ", col 20,
       e.organization_id, col 40, organization_id,
       row + 1
      ENDIF
     WITH nocounter
    ;end select
   ELSE
    CALL display_invalid_logical_domain_message(null)
   ENDIF
 END ;Subroutine
 SUBROUTINE getdistributionreporthistorybyencounter(null)
   CALL clear(1,1)
   CALL box(2,1,23,110)
   CALL text(3,22,"*** View Distribution Report History by Encounter ***")
   CALL text(5,4,"Enter an Encntr_id: ")
   CALL accept(5,30,"P(40);Cf"," ")
   SET encntr_id_chosen = cnvtreal(curaccept)
   DECLARE dist_name = vc WITH noconstant(" ")
   DECLARE prsnl_name = vc WITH noconstant(" ")
   IF (can_user_access_this_encounter(null)=1)
    SELECT INTO "mine"
     report_request_id = format(cr.report_request_id,"############;L"), scope_flag = format(cr
      .scope_flag,"#####;L"), cr.dist_run_dt_tm,
     cr.dist_run_type_cd, run_type_cd = format(uar_get_code_display(cr.dist_run_type_cd),
      "####################;L"), run_dt_tm = format(cr.dist_run_dt_tm,";;Q"),
     reltn_cd = format(uar_get_code_display(cr.provider_reltn_cd),"####################;L")
     FROM cr_report_request cr,
      chart_distribution cd,
      prsnl p
     PLAN (cr
      WHERE cr.encntr_id=encntr_id_chosen
       AND cr.request_type_flag=4)
      JOIN (cd
      WHERE cd.distribution_id=cr.distribution_id)
      JOIN (p
      WHERE p.person_id=cr.provider_prsnl_id)
     ORDER BY cr.report_request_id
     HEAD REPORT
      linex = fillstring(130,"-"), row + 1, col 18,
      "Encounter Report History", col 50, "Encounter ID: ",
      col 65, encntr_id_chosen, row + 1,
      col 18, "-----------------------", row + 2
     HEAD PAGE
      col 2, "Request ID", col 15,
      "Scope", col 30, "Distribution",
      col 70, "Run Date/Time", col 100,
      "Run Type", col 120, "Receiving Personnel",
      col 170, "Relationship Type", row + 1,
      col 2, "----------", col 15,
      "---------", col 30, "------------",
      col 70, "-----------------------", col 100,
      "----------", col 120, "-------------------",
      col 170, "-----------------", row + 1
     DETAIL
      col 2, report_request_id, col 15
      IF (cr.scope_flag=1)
       "Person"
      ELSEIF (cr.scope_flag=2)
       "Encounter"
      ELSEIF (cr.scope_flag=4)
       "Accession"
      ELSEIF (cr.scope_flag=5)
       "Cross-Encounter"
      ELSEIF (cr.scope_flag=6)
       "Document"
      ENDIF
      dist_name = build(cd.dist_descr,"(",format(cr.distribution_id,";L"),")"), col 30, dist_name,
      col 70, run_dt_tm, col 100,
      run_type_cd, prsnl_name = build(p.name_full_formatted,"(",format(cr.provider_prsnl_id,";L"),")"
       ), col 120,
      prsnl_name, col 170, reltn_cd,
      row + 1
     WITH nocounter, maxcol = 500
    ;end select
   ELSE
    CALL display_invalid_logical_domain_message(null)
   ENDIF
 END ;Subroutine
 SUBROUTINE getdistributionrundatetimes(null)
   CALL clear(1,1)
   CALL box(2,1,23,110)
   CALL text(3,22,"*** View Distribution Run Date/Times ***")
   SET distribution_id_chosen = 0.0
   CALL text(5,4,"Select a Distribution: ")
   CALL text(7,4,"SHIFT/F5 to see a list of distributions")
   IF (is_logical_domain_enabled_ind=1)
    SET where_clause = build2(
     "cd.distribution_id > 0 and cd.active_ind = 1 and cd.logical_domain_id = personnel_logical_domain_id"
     )
   ELSE
    SET where_clause = build2("cd.distribution_id > 0 and cd.active_ind = 1")
   ENDIF
   SET help =
   SELECT DISTINCT INTO "nl:"
    cd.dist_descr
    FROM chart_distribution cd
    WHERE parser(where_clause)
    ORDER BY cnvtupper(cd.dist_descr)
    WITH nocounter
   ;end select
   CALL accept(8,4,"P(80);C")
   SET help = off
   SET distribution_name_chosen = trim(curaccept)
   SELECT DISTINCT INTO "nl:"
    FROM chart_distribution cd
    WHERE cd.dist_descr=distribution_name_chosen
    HEAD REPORT
     do_nothing = 0
    DETAIL
     distribution_id_chosen = cd.distribution_id
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    cr.dist_run_dt_tm
    FROM cr_report_request cr
    WHERE cr.request_type_flag=4
     AND cr.distribution_id=distribution_id_chosen
     AND cr.report_request_id=cr.parent_request_id
    ORDER BY cr.dist_run_dt_tm
    HEAD REPORT
     count_dist = 0
    HEAD cr.dist_run_dt_tm
     count_dist += 1, stat = alterlist(distrun->qual,count_dist), distrun->qual[count_dist].count = 0,
     distrun->qual[count_dist].server_name = cr.server_full_name
    DETAIL
     distrun->qual[count_dist].count += 1
    WITH nocounter
   ;end select
   SELECT DISTINCT
    cr.distribution_id, cr.dist_run_type_cd, run_dt_tm = format(cr.dist_run_dt_tm,";;Q;R")
    FROM cr_report_request cr,
     cr_report_template ct
    PLAN (cr
     WHERE cr.distribution_id=distribution_id_chosen
      AND cr.report_request_id=cr.parent_request_id)
     JOIN (ct
     WHERE ct.template_id=cr.template_id)
    ORDER BY cr.dist_run_dt_tm
    HEAD REPORT
     cnt_dist = 0, linex = fillstring(130,"-"), row + 1,
     col 2, "Distribution: ", col 20,
     distribution_id_chosen, col 40, distribution_name_chosen,
     row + 2, run_type_cd = format(uar_get_code_display(cr.dist_run_type_cd),
      "#################################;L"), col 2,
     "Run Date/Time", col 30, "Run Type",
     col 56, "Report Template", col 85,
     "# Qual", col 95, "Server Name",
     row + 1, col 2, "*************",
     col 30, "********", col 56,
     "************", col 85, "******",
     col 95, "************"
    DETAIL
     cnt_dist += 1, row + 1, col 2,
     run_dt_tm, col 30, run_type_cd,
     col 56, ct.template_name, col 80,
     distrun->qual[cnt_dist].count, col 95, distrun->qual[cnt_dist].server_name
    WITH nocounter, outerjoin = dtbl, maxcol = 250
   ;end select
 END ;Subroutine
 SUBROUTINE getdistributionexecutiontimes(null)
   CALL clear(1,1)
   CALL box(2,1,23,109)
   CALL text(1,25,"*** View Distribution Execuation Times ***")
   CALL text(4,2,"Select a Distribution or Leave Empty")
   CALL text(5,2,"  SHIFT/F5 to see a list of Batch Names")
   SET distribution_id_chosen = 0.0
   IF (is_logical_domain_enabled_ind=1)
    SET where_clause = build2(
     "cd.distribution_id > 0 and cd.active_ind = 1 and cd.logical_domain_id = personnel_logical_domain_id"
     )
   ELSE
    SET where_clause = build2("cd.distribution_id > 0 and cd.active_ind = 1")
   ENDIF
   SET help =
   SELECT DISTINCT INTO "nl:"
    cd.dist_descr
    FROM chart_distribution cd
    WHERE parser(where_clause)
    ORDER BY cnvtupper(cd.dist_descr)
    WITH nocounter
   ;end select
   CALL accept(6,6,"P(100);C"," ")
   SET help = off
   SET distribution_name_chosen = fillstring(80," ")
   SET distribution_name_chosen = trim(curaccept)
   SELECT DISTINCT INTO "nl:"
    FROM chart_distribution cd
    WHERE cd.dist_descr=distribution_name_chosen
    HEAD REPORT
     do_nothing = 0
    DETAIL
     distribution_id_chosen = cd.distribution_id
    WITH nocounter
   ;end select
   IF (distribution_id_chosen > 0)
    SELECT INTO "mine"
     cdl.message_text, cdl.distribution_id, exec_time = substring(24,3,cdl.message_text),
     distr_id = cdl.distribution_id, run_date = format(cdl.dist_run_dt_tm,"mm/dd/yyyy hh:mm:ss;;d"),
     run_type = uar_get_code_meaning(cdl.dist_run_type_cd)
     FROM chart_dist_log cdl,
      chart_distribution cd
     PLAN (cdl
      WHERE cdl.distribution_id=distribution_id_chosen
       AND cdl.message_text="Total Execution Time =*")
      JOIN (cd
      WHERE cd.distribution_id=cdl.distribution_id)
     ORDER BY cdl.dist_run_dt_tm DESC
     HEAD REPORT
      row + 1, col 2, "Distribution Execution Summary",
      row + 2, dist_desc = build(cd.dist_descr,"(",format(cd.distribution_id,";l"),")"), col 2,
      dist_desc, row + 2, col 2,
      "Distribution ID", col 20, "Execution Time",
      col 40, "Run Date/Time", col 70,
      "Run Type", row + 1, col 2,
      "---------------", col 20, "--------------",
      col 40, "----------------", col 70,
      "--------"
     DETAIL
      row + 1, col 2, distr_id,
      col 20, exec_time, col 28,
      "MINUTES", col 40, run_date,
      col 70, run_type
     WITH nocounter
    ;end select
   ELSE
    IF (is_logical_domain_enabled_ind=1)
     SELECT INTO "mine"
      cdl.message_text, cdl.distribution_id, exec_time = substring(24,3,cdl.message_text),
      distr_id = cdl.distribution_id, run_date = format(cdl.dist_run_dt_tm,"mm/dd/yyyy hh:mm:ss;;d"),
      run_type = uar_get_code_meaning(cdl.dist_run_type_cd)
      FROM chart_dist_log cdl,
       chart_distribution cd
      PLAN (cdl
       WHERE cdl.message_text="Total Execution Time =*")
       JOIN (cd
       WHERE cd.distribution_id=cdl.distribution_id
        AND cd.logical_domain_id=personnel_logical_domain_id)
      ORDER BY cdl.dist_run_dt_tm DESC
      HEAD REPORT
       row + 1, col 2, "Distribution Execution Summary",
       row + 2, col 2, "All Distributions",
       row + 2, col 2, "Distribution ID",
       col 20, "Execution Time", col 40,
       "Run Date/Time", col 70, "Run Type",
       row + 1, col 2, "---------------",
       col 20, "--------------", col 40,
       "----------------", col 70, "--------"
      DETAIL
       row + 1, col 2, distr_id,
       col 20, exec_time, col 28,
       "MINUTES", col 40, run_date,
       col 70, run_type
      WITH nocounter
     ;end select
    ELSEIF (is_logical_domain_enabled_ind=0)
     SELECT INTO "mine"
      cdl.message_text, cdl.distribution_id, exec_time = substring(24,3,cdl.message_text),
      distr_id = cdl.distribution_id, run_date = format(cdl.dist_run_dt_tm,"mm/dd/yyyy hh:mm:ss;;d"),
      run_type = uar_get_code_meaning(cdl.dist_run_type_cd)
      FROM chart_dist_log cdl
      WHERE cdl.message_text="Total Execution Time =*"
      ORDER BY cdl.dist_run_dt_tm DESC
      HEAD REPORT
       row + 1, col 2, "Distribution Execution Summary",
       row + 2, col 2, "All Distributions",
       row + 2, col 2, "Distribution ID",
       col 20, "Execution Time", col 40,
       "Run Date/Time", col 70, "Run Type",
       row + 1, col 2, "---------------",
       col 20, "--------------", col 40,
       "----------------", col 70, "--------"
      DETAIL
       row + 1, col 2, distr_id,
       col 20, exec_time, col 28,
       "MINUTES", col 40, run_date,
       col 70, run_type
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE getdevicecrossreference(null)
   SET type_chosen = 0
   CALL clear(1,1)
   CALL box(2,1,23,110)
   CALL text(3,22,"*** VIEW DEVICE CROSS-REFERENCE ASSOCIATIONS ***")
   CALL text(4,5,"(Device Cross -Reference is used for workflows outside of Clinical Reporting)")
   CALL text(5,4,"For Entity to Printer, Type 'E' / For Printer to Entity, Type 'P'")
   CALL accept(5,76,"p(1);c","E"
    WHERE cnvtupper(curaccept) IN ("E", "P"))
   CALL text(6,4,
    "--------------------------------------------------------------------------------------------")
   IF (cnvtupper(curaccept)="E")
    CALL text(7,4,"Enter Type of Association:")
    CALL text(8,4,"1=Locations, 2=Providers, 3=Organizations, 4=Organization Resource")
    CALL accept(9,4,"99;",99
     WHERE curaccept IN (01, 02, 03, 04, 99))
    SET type_chosen = cnvtint(curaccept)
    IF (type_chosen=1)
     SELECT INTO "mine"
      dx.parent_entity_id, dx.parent_entity_name, dx.device_cd,
      d.name
      FROM device_xref dx,
       device d,
       code_value cv,
       location l,
       organization o
      PLAN (dx
       WHERE dx.parent_entity_name="LOCATION")
       JOIN (cv
       WHERE cv.code_value=dx.parent_entity_id)
       JOIN (d
       WHERE d.device_cd=dx.device_cd)
       JOIN (l
       WHERE l.location_cd=dx.parent_entity_id)
       JOIN (o
       WHERE o.organization_id=l.organization_id
        AND o.logical_domain_id=personnel_logical_domain_id)
      ORDER BY cnvtupper(cv.display)
      HEAD REPORT
       cnt = 0, row + 1, col 2,
       "Location", col 35, "Device",
       col 60, "Device Code", row + 1,
       col 2, "---------", col 35,
       "--------", col 60, "-----------",
       row + 1
      DETAIL
       col 2, cv.display, col 35,
       d.name, col 55, d.device_cd,
       row + 1
      WITH nocounter
     ;end select
    ENDIF
    IF (type_chosen=2)
     SELECT INTO "mine"
      dx.parent_entity_id, dx.parent_entity_name, dx.device_cd,
      p.name_full_formatted, d.name
      FROM device_xref dx,
       prsnl p,
       device d
      PLAN (dx
       WHERE dx.parent_entity_name="PRSNL")
       JOIN (p
       WHERE p.person_id=dx.parent_entity_id
        AND p.logical_domain_id=personnel_logical_domain_id)
       JOIN (d
       WHERE d.device_cd=dx.device_cd)
      ORDER BY cnvtupper(p.name_full_formatted)
      HEAD REPORT
       cnt = 0, row + 1, col 2,
       "Name", col 35, "Device",
       col 60, "Device Code", row + 1,
       col 2, "-------", col 35,
       "--------", col 60, "-----------",
       row + 1
      DETAIL
       col 2, p.name_full_formatted, col 35,
       d.name, col 55, d.device_cd,
       row + 1
      WITH nocounter
     ;end select
    ENDIF
    IF (type_chosen=3)
     SELECT INTO "mine"
      dx.parent_entity_id, dx.parent_entity_name, dx.device_cd,
      o.org_name, d.name
      FROM device_xref dx,
       organization o,
       device d
      PLAN (dx
       WHERE dx.parent_entity_name="ORGANIZATION")
       JOIN (o
       WHERE o.organization_id=dx.parent_entity_id
        AND o.logical_domain_id=personnel_logical_domain_id)
       JOIN (d
       WHERE d.device_cd=dx.device_cd)
      ORDER BY cnvtupper(o.org_name)
      HEAD REPORT
       cnt = 0, row + 1, col 2,
       "Organization", col 35, "Device",
       col 60, "Device Code", row + 1,
       col 2, "-----------", col 35,
       "--------", col 60, "-----------",
       row + 1
      DETAIL
       col 2, o.org_name, col 35,
       d.name, col 55, d.device_cd,
       row + 1
      WITH nocounter
     ;end select
    ENDIF
    IF (type_chosen=4)
     SELECT INTO "mine"
      dx.parent_entity_id, dx.parent_entity_name, dx.device_cd,
      cv.code_value, d.name
      FROM device_xref dx,
       code_value cv,
       device d,
       service_resource sr,
       organization o
      PLAN (dx
       WHERE dx.parent_entity_name="SERVICE_RESOURCE")
       JOIN (cv
       WHERE cv.code_value=dx.parent_entity_id)
       JOIN (d
       WHERE d.device_cd=dx.device_cd)
       JOIN (sr
       WHERE sr.service_resource_cd=dx.parent_entity_id)
       JOIN (o
       WHERE o.organization_id=sr.organization_id
        AND o.logical_domain_id=personnel_logical_domain_id)
      ORDER BY cnvtupper(cv.display)
      HEAD REPORT
       cnt = 0, row + 1, col 2,
       "Service Resource", col 35, "Device",
       col 60, "Device Code", row + 1,
       col 2, "----------------", col 35,
       "--------", col 60, "-----------",
       row + 1
      DETAIL
       col 2, cv.display, col 35,
       d.name, col 55, d.device_cd,
       row + 1
      WITH nocounter
     ;end select
    ENDIF
   ELSEIF (cnvtupper(curaccept)="P")
    SET fax_type_cd = 0.0
    SET printer_type_cd = 0.0
    SET stat = uar_get_meaning_by_codeset(3000,"FAX",1,fax_type_cd)
    SET stat = uar_get_meaning_by_codeset(3000,"PRINTER",1,printer_type_cd)
    SET device_cd_chosen = 0.0
    CALL text(7,4,"Choose a Printer: ")
    CALL text(9,4,"SHIFT/F5 to see a list of Printers")
    SET help =
    SELECT INTO "nl:"
     d.name
     FROM device d,
      location l,
      organization o
     PLAN (d
      WHERE d.device_cd > 0
       AND d.device_type_cd IN (fax_type_cd, printer_type_cd))
      JOIN (l
      WHERE l.location_cd=d.location_cd)
      JOIN (o
      WHERE o.organization_id=l.organization_id
       AND o.logical_domain_id=personnel_logical_domain_id)
     ORDER BY cnvtupper(d.name)
     WITH nocounter
    ;end select
    CALL accept(10,4,"P(50);C")
    SET help = off
    SET device_name_chosen = trim(curaccept)
    SELECT DISTINCT INTO "nl:"
     FROM device d,
      location l,
      organization o
     PLAN (d
      WHERE d.name=device_name_chosen)
      JOIN (l
      WHERE l.location_cd=d.location_cd)
      JOIN (o
      WHERE o.organization_id=l.organization_id
       AND o.logical_domain_id=personnel_logical_domain_id)
     HEAD REPORT
      device_cd_chosen = d.device_cd
     WITH nocounter
    ;end select
    FREE RECORD xref_rec
    RECORD xref_rec(
      1 qual[*]
        2 type = c1
        2 parent_entity_id = f8
        2 description = vc
    )
    SELECT INTO "nl:"
     type =
     IF (dx.parent_entity_name="PRSNL") "P"
     ELSEIF (dx.parent_entity_name="LOCATION") "L"
     ELSEIF (dx.parent_entity_name="ORGANIZATION") "O"
     ELSEIF (dx.parent_entity_name="SERVICE_RESOURCE") "S"
     ENDIF
     FROM device_xref dx
     WHERE dx.device_cd=device_cd_chosen
      AND dx.parent_entity_name IN ("PRSNL", "LOCATION", "ORGANIZATION", "SERVICE_RESOURCE")
     ORDER BY type, dx.parent_entity_id
     HEAD REPORT
      cnt = 0
     DETAIL
      cnt += 1, stat = alterlist(xref_rec->qual,cnt), xref_rec->qual[cnt].type = type,
      xref_rec->qual[cnt].parent_entity_id = dx.parent_entity_id
      IF (type IN ("S", "L"))
       xref_rec->qual[cnt].description = uar_get_code_display(dx.parent_entity_id)
      ELSE
       xref_rec->qual[cnt].description = " "
      ENDIF
     WITH nocounter
    ;end select
    SET cnt1 = 0
    SET cnt1 = size(xref_rec->qual,5)
    IF (cnt1 > 0)
     SELECT INTO "nl:"
      name = build(trim(substring(1,10,p.name_last)),",",trim(substring(1,10,p.name_first)))
      FROM prsnl p,
       (dummyt d  WITH seq = value(cnt1))
      PLAN (d
       WHERE (xref_rec->qual[d.seq].type="P"))
       JOIN (p
       WHERE (p.person_id=xref_rec->qual[d.seq].parent_entity_id))
      HEAD REPORT
       do_nothing = 0
      DETAIL
       xref_rec->qual[d.seq].description = name
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      name = trim(o.org_name)
      FROM organization o,
       (dummyt d  WITH seq = value(cnt1))
      PLAN (d
       WHERE (xref_rec->qual[d.seq].type="O"))
       JOIN (o
       WHERE (o.organization_id=xref_rec->qual[d.seq].parent_entity_id))
      HEAD REPORT
       do_nothing = 0
      DETAIL
       xref_rec->qual[d.seq].description = name
      WITH nocounter
     ;end select
    ELSE
     CALL echo("no xrefs found - exiting")
    ENDIF
    SELECT INTO "mine"
     dx.*
     FROM device_xref dx
     WHERE dx.device_cd > 0
     HEAD REPORT
      row + 1, col 20, "PRINTER TO ENTITY REPORT (DEVICE CROSS-REFERENCE)",
      x = 0, prev_type = fillstring(1," "), row + 1,
      col 2, "DEVICE_CD: ", device_cd_chosen,
      " ( ", device_name_chosen, " ) "
     DETAIL
      do_nothing = 0
     FOOT REPORT
      IF (cnt1=0)
       row + 1, col 2, "No Cross-references found for this printer"
      ELSE
       row + 2, col 2, "TYPE",
       col 30, "DESCRIPTION", row + 1,
       col 2, "----", col 30,
       "--------------------------------", row + 1, prev_type = "Z"
       FOR (x = 1 TO cnt1)
         IF ((prev_type=xref_rec->qual[x].type))
          row + 1
         ELSE
          row + 2
         ENDIF
         col 2
         IF ((xref_rec->qual[x].type="P"))
          "PRSNL"
         ELSEIF ((xref_rec->qual[x].type="L"))
          "LOCATION"
         ELSEIF ((xref_rec->qual[x].type="O"))
          "ORGANIZATION"
         ELSEIF ((xref_rec->qual[x].type="S"))
          "SERVICE RESOURCE"
         ENDIF
         col 30, xref_rec->qual[x].description, prev_type = xref_rec->qual[x].type
       ENDFOR
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
 END ;Subroutine
 SUBROUTINE getdestinationroutingassociations(null)
   SET type_chosen = 0
   DECLARE email = vc WITH noconstant("")
   DECLARE destination = vc WITH noconstant("")
   DECLARE email_delimeter = vc WITH constant("@OUTPUT_DEST@SECURE_EMAIL")
   DECLARE entity_display = vc WITH noconstant("")
   CALL clear(1,1)
   CALL box(2,1,23,110)
   CALL text(3,22,"*** VIEW DESTINATION ROUTING ASSOCIATIONS ***")
   CALL text(4,5,"(Destination Routing Associations is used for Clinical Reporting workflows)")
   CALL text(6,4,"For Entity to Destination, Type 'E' / For Destination to Entity, Type 'D'")
   CALL accept(6,80,"p(1);c","E"
    WHERE cnvtupper(curaccept) IN ("E", "D"))
   CALL text(7,4,
    "--------------------------------------------------------------------------------------------")
   IF (cnvtupper(curaccept)="E")
    CALL text(8,4,"Enter Type of Association:")
    CALL text(9,4,"1=Locations, 2=Providers, 3=Organizations, 4=Service Resources")
    CALL accept(10,4,"99;",99
     WHERE curaccept IN (01, 02, 03, 04, 99))
    SET type_chosen = cnvtint(curaccept)
    IF (type_chosen=1)
     SELECT INTO "mine"
      cdx.parent_entity_id, cdx.parent_entity_name, cdx.device_cd,
      d.name
      FROM cr_destination_xref cdx,
       device d,
       location l,
       organization o
      PLAN (cdx
       WHERE cdx.parent_entity_name="LOCATION")
       JOIN (l
       WHERE l.location_cd=cdx.parent_entity_id)
       JOIN (d
       WHERE d.device_cd=cdx.device_cd)
       JOIN (o
       WHERE o.organization_id=l.organization_id
        AND o.logical_domain_id=personnel_logical_domain_id)
      ORDER BY cnvtupper(uar_get_code_display(cdx.parent_entity_id))
      HEAD REPORT
       cnt = 0, row + 1, col 2,
       "Location", col 60, "Destination",
       row + 1, col 2, "---------",
       col 60, "--------", row + 1
      DETAIL
       entity_display = build(uar_get_code_display(cdx.parent_entity_id)," (",format(cdx
         .parent_entity_id,"############;L"),")"), col 2, entity_display
       IF (cdx.device_cd=0
        AND size(trim(cdx.dms_service_identifier)) > 0)
        end_pos = findstring(email_delimeter,trim(cdx.dms_service_identifier)), email = substring(1,(
         end_pos - 1),trim(cdx.dms_service_identifier)), col 60,
        email
       ELSE
        destination = build(d.name," (",format(d.device_cd,"############;L"),")"), col 60,
        destination
       ENDIF
       row + 1
      WITH nocounter
     ;end select
    ENDIF
    IF (type_chosen=2)
     SELECT INTO "mine"
      cdx.parent_entity_id, cdx.parent_entity_name, cdx.device_cd,
      p.name_full_formatted, d.name
      FROM cr_destination_xref cdx,
       prsnl p,
       device d
      PLAN (cdx
       WHERE cdx.parent_entity_name="PRSNL")
       JOIN (p
       WHERE p.person_id=cdx.parent_entity_id
        AND p.logical_domain_id=personnel_logical_domain_id)
       JOIN (d
       WHERE d.device_cd=cdx.device_cd)
      ORDER BY cnvtupper(p.name_full_formatted)
      HEAD REPORT
       cnt = 0, row + 1, col 2,
       "Name", col 60, "Destination",
       row + 1, col 2, "-------",
       col 60, "--------", row + 1
      DETAIL
       entity_display = build(p.name_full_formatted," (",format(cdx.parent_entity_id,"############;L"
         ),")"), col 2, entity_display
       IF (cdx.device_cd=0
        AND size(trim(cdx.dms_service_identifier)) > 0)
        end_pos = findstring(email_delimeter,trim(cdx.dms_service_identifier)), email = substring(1,(
         end_pos - 1),trim(cdx.dms_service_identifier)), col 60,
        email
       ELSE
        destination = build(d.name," (",format(d.device_cd,"############;L"),")"), col 60,
        destination
       ENDIF
       row + 1
      WITH nocounter
     ;end select
    ENDIF
    IF (type_chosen=3)
     SELECT INTO "mine"
      cdx.parent_entity_id, cdx.parent_entity_name, cdx.device_cd,
      o.org_name, d.name
      FROM cr_destination_xref cdx,
       organization o,
       device d
      PLAN (cdx
       WHERE cdx.parent_entity_name="ORGANIZATION")
       JOIN (o
       WHERE o.organization_id=cdx.parent_entity_id
        AND o.logical_domain_id=personnel_logical_domain_id)
       JOIN (d
       WHERE d.device_cd=cdx.device_cd)
      ORDER BY cnvtupper(o.org_name)
      HEAD REPORT
       cnt = 0, row + 1, col 2,
       "Organization", col 60, "Destination",
       row + 1, col 2, "-----------",
       col 60, "--------", row + 1
      DETAIL
       entity_display = build(o.org_name," (",format(cdx.parent_entity_id,"############;L"),")"), col
        2, entity_display
       IF (cdx.device_cd=0
        AND size(trim(cdx.dms_service_identifier)) > 0)
        end_pos = findstring(email_delimeter,trim(cdx.dms_service_identifier)), email = substring(1,(
         end_pos - 1),trim(cdx.dms_service_identifier)), col 60,
        email
       ELSE
        destination = build(d.name," (",format(d.device_cd,"############;L"),")"), col 60,
        destination
       ENDIF
       row + 1
      WITH nocounter
     ;end select
    ENDIF
    IF (type_chosen=4)
     SELECT INTO "mine"
      cdx.parent_entity_id, cdx.parent_entity_name, cdx.device_cd,
      d.name
      FROM cr_destination_xref cdx,
       device d,
       service_resource sr,
       organization o
      PLAN (cdx
       WHERE cdx.parent_entity_name="SERVICE_RESOURCE")
       JOIN (sr
       WHERE sr.service_resource_cd=cdx.parent_entity_id)
       JOIN (o
       WHERE o.organization_id=sr.organization_id
        AND o.logical_domain_id=personnel_logical_domain_id)
       JOIN (d
       WHERE d.device_cd=cdx.device_cd)
      ORDER BY cnvtupper(uar_get_code_display(cdx.parent_entity_id))
      HEAD REPORT
       cnt = 0, row + 1, col 2,
       "Service Resource", col 60, "Device",
       row + 1, col 2, "----------------",
       col 60, "--------", row + 1
      DETAIL
       entity_display = build(uar_get_code_display(cdx.parent_entity_id)," (",format(cdx
         .parent_entity_id,"############;L"),")"), col 2, entity_display
       IF (cdx.device_cd=0
        AND size(trim(cdx.dms_service_identifier)) > 0)
        end_pos = findstring(email_delimeter,trim(cdx.dms_service_identifier)), email = substring(1,(
         end_pos - 1),trim(cdx.dms_service_identifier)), col 60,
        email
       ELSE
        destination = build(d.name," (",format(d.device_cd,"############;L"),")"), col 60,
        destination
       ENDIF
       row + 1
      WITH nocounter
     ;end select
    ENDIF
   ELSEIF (cnvtupper(curaccept)="D")
    CALL text(8,4,"Destination Type of Association:")
    CALL text(9,4,"1=Fax, 2=Printer, 3=Secure Email")
    CALL accept(10,4,"99;",99
     WHERE curaccept IN (01, 02, 03, 99))
    SET type_chosen = cnvtint(curaccept)
    IF (type_chosen IN (1, 2))
     SET fax_type_cd = 0.0
     SET printer_type_cd = 0.0
     SET stat = uar_get_meaning_by_codeset(3000,"FAX",1,fax_type_cd)
     SET stat = uar_get_meaning_by_codeset(3000,"PRINTER",1,printer_type_cd)
     SET choose_text = "Select a Destination:"
     SET list_text = "SHIFT/F5 to see a list of Destinations"
     SET table_heading = "DESTINATION TO ENTITY REPORT"
     IF (type_chosen=1)
      SET where_clause = build2("d.device_cd > 0 and d.device_type_cd = fax_type_cd")
     ELSEIF (type_chosen=2)
      SET where_clause = build2("d.device_cd > 0 and d.device_type_cd = printer_type_cd")
     ENDIF
     SET device_cd_chosen = 0.0
     CALL text(12,4,choose_text)
     CALL text(13,4,list_text)
     SET help =
     SELECT INTO "nl:"
      d.name
      FROM device d,
       location l,
       organization o
      PLAN (d
       WHERE parser(where_clause))
       JOIN (l
       WHERE l.location_cd=d.location_cd)
       JOIN (o
       WHERE o.organization_id=l.organization_id
        AND o.logical_domain_id=personnel_logical_domain_id)
      ORDER BY cnvtupper(d.name)
      WITH nocounter
     ;end select
     CALL accept(14,4,"P(50);C")
     SET help = off
     SET device_name_chosen = trim(curaccept)
     SELECT DISTINCT INTO "nl:"
      FROM device d,
       location l,
       organization o
      PLAN (d
       WHERE parser(where_clause)
        AND d.name=device_name_chosen)
       JOIN (l
       WHERE l.location_cd=d.location_cd)
       JOIN (o
       WHERE o.organization_id=l.organization_id
        AND o.logical_domain_id=personnel_logical_domain_id)
      HEAD REPORT
       device_cd_chosen = d.device_cd
      WITH nocounter
     ;end select
     FREE RECORD destinations
     RECORD destinations(
       1 qual[*]
         2 parent_entity_id = f8
         2 parent_entity_type = vc
         2 parent_entity_disp_name = vc
         2 dms_service_identifier = vc
     )
     IF (device_cd_chosen > 0)
      SELECT INTO "nl:"
       FROM cr_destination_xref cdx
       WHERE cdx.device_cd=device_cd_chosen
        AND cdx.parent_entity_name IN ("PRSNL", "LOCATION", "ORGANIZATION", "SERVICE_RESOURCE")
       HEAD REPORT
        cnt = 0
       DETAIL
        cnt += 1, stat = alterlist(destinations->qual,cnt), destinations->qual[cnt].parent_entity_id
         = cdx.parent_entity_id,
        destinations->qual[cnt].parent_entity_type = cdx.parent_entity_name
        IF (cdx.parent_entity_name IN ("LOCATION", "SERVICE_RESOURCE"))
         destinations->qual[cnt].parent_entity_disp_name = uar_get_code_display(cdx.parent_entity_id)
        ELSE
         destinations->qual[cnt].parent_entity_disp_name = ""
        ENDIF
       WITH nocounter
      ;end select
     ENDIF
     SET nbr_of_records = 0
     SET nbr_of_records = size(destinations->qual,5)
     IF (nbr_of_records > 0)
      SELECT INTO "nl:"
       FROM prsnl p,
        (dummyt d  WITH seq = value(nbr_of_records))
       PLAN (d
        WHERE (destinations->qual[d.seq].parent_entity_type="PRSNL"))
        JOIN (p
        WHERE (p.person_id=destinations->qual[d.seq].parent_entity_id))
       HEAD REPORT
        do_nothing = 0
       DETAIL
        destinations->qual[d.seq].parent_entity_disp_name = trim(p.name_full_formatted)
       WITH nocounter
      ;end select
      SELECT INTO "nl:"
       FROM organization o,
        (dummyt d  WITH seq = value(nbr_of_records))
       PLAN (d
        WHERE (destinations->qual[d.seq].parent_entity_type="ORGANIZATION"))
        JOIN (o
        WHERE (o.organization_id=destinations->qual[d.seq].parent_entity_id))
       HEAD REPORT
        do_nothing = 0
       DETAIL
        destinations->qual[d.seq].parent_entity_disp_name = trim(o.org_name)
       WITH nocounter
      ;end select
      SELECT
       entity_type = destinations->qual[d.seq].parent_entity_type, entity_disp_name = cnvtupper(
        destinations->qual[d.seq].parent_entity_disp_name)
       FROM (dummyt d  WITH seq = value(nbr_of_records))
       ORDER BY entity_type, entity_disp_name
       HEAD REPORT
        row + 1, col 20, table_heading,
        row + 1, col 2, "DESTINATION: ",
        device_name_chosen, " ( ", device_cd_chosen,
        " ) "
       DETAIL
        row + 1, col 2, destinations->qual[d.seq].parent_entity_type,
        entity_name = destinations->qual[d.seq].parent_entity_disp_name, entity_display = build(
         entity_name," (",format(destinations->qual[d.seq].parent_entity_id,"############;L"),")"),
        col 30,
        entity_display, row + 1
       WITH nocounter
      ;end select
     ELSE
      CALL display_no_destination_found_message(null)
     ENDIF
    ELSEIF (type_chosen=3)
     SET secure_email_type_cd = 0.0
     SET stat = uar_get_meaning_by_codeset(4636013,"SECURE_EMAIL",1,secure_email_type_cd)
     FREE RECORD destinations
     RECORD destinations(
       1 qual[*]
         2 parent_entity_id = f8
         2 parent_entity_type = vc
         2 parent_entity_disp_name = vc
         2 dms_service_identifier = vc
     )
     SELECT INTO "nl:"
      e_id = cdx1.parent_entity_id, e_type = cdx1.parent_entity_name, e_disp_name = o1.org_name,
      e_email = cdx1.dms_service_identifier
      FROM cr_destination_xref cdx1,
       organization o1
      PLAN (cdx1
       WHERE cdx1.destination_type_cd=secure_email_type_cd
        AND cdx1.parent_entity_name="ORGANIZATION")
       JOIN (o1
       WHERE o1.organization_id=cdx1.parent_entity_id
        AND ((o1.logical_domain_id=personnel_logical_domain_id) UNION (
       (SELECT
        e_id = cdx2.parent_entity_id, e_type = cdx2.parent_entity_name, e_disp_name = p2
        .name_full_formatted,
        e_email = cdx2.dms_service_identifier
        FROM cr_destination_xref cdx2,
         prsnl p2
        WHERE cdx2.destination_type_cd=secure_email_type_cd
         AND cdx2.parent_entity_name="PRSNL"
         AND p2.person_id=cdx2.parent_entity_id
         AND ((p2.logical_domain_id=personnel_logical_domain_id) UNION (
        (SELECT
         e_id = cdx3.parent_entity_id, e_type = cdx3.parent_entity_name, e_disp_name = "",
         e_email = cdx3.dms_service_identifier
         FROM cr_destination_xref cdx3,
          location l3,
          organization o3
         WHERE cdx3.destination_type_cd=secure_email_type_cd
          AND cdx3.parent_entity_name="LOCATION"
          AND l3.location_cd=cdx3.parent_entity_id
          AND o3.organization_id=l3.organization_id
          AND ((o3.logical_domain_id=personnel_logical_domain_id) UNION (
         (SELECT
          e_id = cdx4.parent_entity_id, e_type = cdx4.parent_entity_name, e_disp_name = "",
          e_email = cdx4.dms_service_identifier
          FROM cr_destination_xref cdx4,
           service_resource s4,
           organization o4
          WHERE cdx4.destination_type_cd=secure_email_type_cd
           AND cdx4.parent_entity_name="SERVICE_RESOURCE"
           AND s4.service_resource_cd=cdx4.parent_entity_id
           AND o4.organization_id=s4.organization_id
           AND o4.logical_domain_id=personnel_logical_domain_id))) ))) ))) )
      HEAD REPORT
       cnt = 0
      DETAIL
       cnt += 1, stat = alterlist(destinations->qual,cnt), destinations->qual[cnt].parent_entity_id
        = e_id,
       destinations->qual[cnt].parent_entity_type = e_type
       IF (size(trim(e_email)) > 0)
        end_pos = findstring(email_delimeter,trim(e_email)), destinations->qual[cnt].
        dms_service_identifier = substring(1,(end_pos - 1),trim(e_email))
       ENDIF
       IF (e_type IN ("LOCATION", "SERVICE_RESOURCE"))
        destinations->qual[cnt].parent_entity_disp_name = uar_get_code_display(e_id)
       ELSE
        destinations->qual[cnt].parent_entity_disp_name = e_disp_name
       ENDIF
      WITH nocounter, rdbunion
     ;end select
     SET no_of_records = 0
     SET no_of_records = size(destinations->qual,5)
     IF (no_of_records > 0)
      SELECT
       entity_type = destinations->qual[d.seq].parent_entity_type, entity_disp_name = cnvtupper(
        destinations->qual[d.seq].parent_entity_disp_name), entity_email = trim(destinations->qual[d
        .seq].dms_service_identifier)
       FROM (dummyt d  WITH seq = value(no_of_records))
       ORDER BY entity_type, entity_disp_name, entity_email
       HEAD REPORT
        row + 1, col 20, "SECURE EMAIL DESTINATION ASSOCIATIONS",
        row + 1
       HEAD entity_type
        row + 2
        IF ((destinations->qual[d.seq].parent_entity_type="LOCATION"))
         col 2, "Destinations Associated to Locations"
        ELSEIF ((destinations->qual[d.seq].parent_entity_type="ORGANIZATION"))
         col 2, "Destinations Associated to Oragnizations"
        ELSEIF ((destinations->qual[d.seq].parent_entity_type="PRSNL"))
         col 2, "Destinations Associated to Personnel"
        ELSEIF ((destinations->qual[d.seq].parent_entity_type="SERVICE_RESOURCE"))
         col 2, "Destinations Associated to Service Resources"
        ENDIF
        row + 2, col 2, "ENTITY NAME",
        col 60, "EMAIL ADDRESS", row + 1,
        col 2, "-----------", col 60,
        "-------------", row + 1
       DETAIL
        entity_name = destinations->qual[d.seq].parent_entity_disp_name, entity_display = build(
         entity_name," (",format(destinations->qual[d.seq].parent_entity_id,"############;L"),")"),
        col 2,
        entity_display, col 60, destinations->qual[d.seq].dms_service_identifier,
        row + 1
       WITH nocounter
      ;end select
     ELSE
      CALL display_no_destination_found_message(null)
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE can_user_access_this_encounter(null)
   DECLARE ret_var = i2
   SELECT INTO "nl:"
    FROM encounter e,
     person p
    PLAN (e
     WHERE e.encntr_id=encntr_id_chosen)
     JOIN (p
     WHERE p.person_id=e.person_id)
    DETAIL
     IF (p.logical_domain_id=personnel_logical_domain_id)
      ret_var = 1
     ELSE
      ret_var = 0
     ENDIF
    WITH nocounter
   ;end select
   RETURN(ret_var)
 END ;Subroutine
 SUBROUTINE (truncate_with_ellipsis(string=vc,max_length=i2) =vc WITH protect)
   DECLARE ret_var = vc WITH protect
   DECLARE string_trimmed = vc WITH protect
   SET string_trimmed = trim(string)
   IF (textlen(string_trimmed) <= max_length)
    SET ret_var = string_trimmed
   ELSE
    SET ret_var = build2(substring(1,(max_length - 3),string_trimmed),"...")
   ENDIF
   RETURN(ret_var)
 END ;Subroutine
 SUBROUTINE can_user_access_this_person(null)
   DECLARE ret_var = i2
   SELECT INTO "nl:"
    FROM person p
    WHERE p.person_id=person_id_chosen
    DETAIL
     IF (p.logical_domain_id=personnel_logical_domain_id)
      ret_var = 1
     ELSE
      ret_var = 0
     ENDIF
    WITH nocounter
   ;end select
   RETURN(ret_var)
 END ;Subroutine
 SUBROUTINE can_user_access_this_acc(null)
   DECLARE ret_var = i2
   SELECT INTO "nl:"
    FROM accession_order_r ar,
     orders o,
     person p
    PLAN (ar
     WHERE ar.accession=accession_nbr_chosen)
     JOIN (o
     WHERE o.order_id=ar.order_id)
     JOIN (p
     WHERE p.person_id=o.person_id)
    DETAIL
     IF (p.logical_domain_id=personnel_logical_domain_id)
      ret_var = 1
     ELSE
      ret_var = 0
     ENDIF
    WITH nocounter
   ;end select
   RETURN(ret_var)
 END ;Subroutine
 SUBROUTINE display_invalid_logical_domain_message(null)
   SELECT INTO "mine"
    FROM dummyt
    FOOT REPORT
     row + 2, col 40, invalid_logical_domain_message
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE display_no_destination_found_message(null)
   SELECT INTO "mine"
    FROM dummyt
    FOOT REPORT
     row + 2, col 40, no_destinations_found
    WITH nocounter
   ;end select
 END ;Subroutine
#start_clear_screen
 FOR (x = 3 TO 23)
   CALL clear(x,2,132)
 ENDFOR
#end_clear_screen
#exit_script
END GO
