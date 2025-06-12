CREATE PROGRAM dist_assist:dba
 PAINT
 EXECUTE cclseclogin
 SET width = 132
 SET modify = system
 SET pswdid = 0.0
 SELECT INTO "nl:"
  p.username, p.person_id
  FROM prsnl p
  WHERE p.username=curuser
  DETAIL
   pswdid = p.person_id
  WITH maxqual(p,1)
 ;end select
 DECLARE distribution_id_chosen = f8 WITH noconstant(0.0)
 DECLARE operations_id_chosen = f8 WITH noconstant(0.0)
 DECLARE encntr_id_chosen = f8 WITH noconstant(0.0)
 DECLARE person_id_chosen = f8 WITH noconstant(0.0)
 DECLARE order_doc_ind = i2 WITH noconstant(0.0)
 DECLARE order_doc_cd = f8
#initialize
 SET encntr_id_chosen = 0.0
 SET validate = 0
 DECLARE x = i4
 DECLARE y = i4
 SET parser_idx = 0
 SET cnt_ok = 0
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
 SET encounter_type_include = 0
 SET organization_include = 0
 SET providers_include = 0
 SET location_include = 0
 SET med_service_include = 0
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
 FOR (x = 1 TO 6)
  SET stat = alterlist(included_rec->qual,(x+ 1))
  SET included_rec->qual[x].included_flag = 99
 ENDFOR
 FREE RECORD location_rec
 RECORD location_rec(
   1 qual[*]
     2 location_cd = f8
 )
 FREE RECORD dist_encounter_types
 RECORD dist_encounter_types(
   1 qual[*]
     2 encounter_types = f8
 )
 FREE RECORD dist_org_ids
 RECORD dist_org_ids(
   1 qual[*]
     2 org_ids = f8
 )
 FREE RECORD dist_providers
 RECORD dist_providers(
   1 qual[*]
     2 providers = f8
     2 reltn_type_cd = f8
 )
 FREE RECORD dist_locations
 RECORD dist_locations(
   1 qual[*]
     2 locations = f8
 )
 FREE RECORD dist_med_services
 RECORD dist_med_services(
   1 qual[*]
     2 med_services = f8
 )
 SET meaning = fillstring(50,"")
 SET operations_id_chosen = 0.0
 SET meaning = fillstring(50,"")
 SET max_param_size = 0
 DECLARE p_1 = c5
 DECLARE p_1_meaning = c50
 DECLARE p_2 = c50
 DECLARE p_2_meaning = c50
 DECLARE p_3 = c50
 DECLARE p_3_meaning = c50
 DECLARE p_4 = c50
 DECLARE p_4_meaning = c50
 DECLARE p_5 = c50
 DECLARE p_5_meaning = c50
 DECLARE p_6[10] = c5
 DECLARE p_6_meaning_cnt = i4
 DECLARE p_7 = c5
 DECLARE p_7_meaning = c50
 DECLARE p_8 = c5
 DECLARE p_8_meaning = c50
 DECLARE p_9 = c20
 DECLARE p_9_meaning = c50
 DECLARE p_10 = c20
 DECLARE p_10_meaning = c50
 DECLARE p_12[15] = c20
 DECLARE p_12_meaning_cnt = i4
 DECLARE p_13[15] = c20
 DECLARE p_13_meaning_cnt = i4
 DECLARE p_14 = c20
 DECLARE p_14_meaning = c50
 DECLARE p_15 = c20
 DECLARE p_15_meaning = c50
 DECLARE p_16 = c5
 DECLARE p_16_meaning = c50
 DECLARE p_17 = c50
 DECLARE p_19 = c5
 DECLARE p_19_meaning = vc
 DECLARE p_20 = c5
 DECLARE p_20_meaning = vc WITH noconstant("")
 FREE RECORD prov_routing
 RECORD prov_routing(
   1 qual[*]
     2 prov_id = f8
     2 prov_name = c25
 )
 SET p_6_cnt = 0
 SET p_10_cnt = 0
 SET p_12_cnt = 0
 SET p_13_cnt = 0
 FREE RECORD p_6_meaning
 RECORD p_6_meaning(
   1 qual[*]
     2 p6_cd = f8
     2 p6_meaning = c20
 )
 FREE RECORD p_12_meaning
 RECORD p_12_meaning(
   1 qual[*]
     2 p12_meaning = c20
 )
 FREE RECORD p_13_meaning
 RECORD p_13_meaning(
   1 qual[*]
     2 p13_meaning = c20
 )
 SET stat = uar_get_meaning_by_codeset(333,"ORDERDOC",1,order_doc_cd)
 SET order_doc_ind = 0
 SET enc_prsnl_cnt = 0
 FREE RECORD enc_prsnl_rec
 RECORD enc_prsnl_rec(
   1 qual[*]
     2 prsnl_person_id = f8
     2 reltn_cd = c50
     2 prsnl_name = c50
 )
 SET pers_prsnl_cnt = 0
 FREE RECORD pers_prsnl_rec
 RECORD pers_prsnl_rec(
   1 qual[*]
     2 prsnl_person_id = f8
     2 reltn_cd = c50
     2 prsnl_name = c50
 )
 FREE RECORD distrun
 RECORD distrun(
   1 qual[*]
     2 count = i4
     2 server_name = c20
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
   distinct_cnt = (distinct_cnt+ 1)
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
 CALL text(2,30,"DISTRIBUTION ASSISTANT")
 CALL text(4,4,"01  Get Encounter Chart History.")
 CALL text(5,4,"02  Get Encounter Details.")
 CALL text(6,4,"03  Does Encounter Qualify for Distribution?")
 CALL text(7,4,"04  Get Distribution Details.")
 CALL text(8,4,"05  Get Operations Details.")
 CALL text(9,4,"06  Get Provider Relationships for Encounter / Person.")
 CALL text(10,4,"07  Run CD_LOG utility.")
 CALL text(11,4,"08  Get Distribution Run Date/Times.")
 CALL text(12,4,"09  Validate CHARTING_OPERATIONS table")
 CALL text(13,4,"10  Check Encounter for Activity")
 CALL text(14,4,"11  Check Distribution Execution Times")
 CALL text(15,4,"12  Check Encounter Activity w/ Chart Format")
 CALL text(16,4,"13  Retrieve Clinical Event Activity for Encounter / Person.")
 CALL text(17,4,"14  View Device Cross-Reference.")
 CALL text(18,4,"15  Cross-Encounter Law Tests.")
 CALL text(20,4,"99  Exit.")
 CALL text(23,4,"Select Option ? ")
 CALL accept(23,23,"99;",99
  WHERE curaccept IN (01, 02, 03, 04, 05,
  06, 07, 08, 09, 10,
  11, 12, 13, 14, 15,
  99))
 CALL clear(24,1)
 SET choice = curaccept
 EXECUTE FROM start_clear_screen TO end_clear_screen
 CASE (choice)
  OF 1:
   EXECUTE FROM begin_get_encntr_charts TO end_get_encntr_charts
  OF 2:
   EXECUTE FROM begin_get_encntr_details TO end_get_encntr_details
  OF 3:
   EXECUTE FROM begin_does_encntr_qualify TO end_does_encntr_qualify
  OF 4:
   EXECUTE FROM begin_get_distribution_details TO end_get_distribution_details
  OF 5:
   EXECUTE FROM begin_get_operations_details TO end_get_operations_details
  OF 6:
   EXECUTE FROM begin_get_reltns TO end_get_reltns
  OF 7:
   EXECUTE cd_log
  OF 8:
   EXECUTE FROM begin_get_dist_runs TO end_get_dist_runs
  OF 9:
   EXECUTE FROM begin_validate_co_table TO end_validate_co_table
  OF 10:
   EXECUTE FROM begin_activity_encntr TO end_activity_encntr
  OF 11:
   EXECUTE FROM begin_exec_time TO end_exec_time
  OF 12:
   EXECUTE FROM begin_chk_chart_format TO end_chk_chart_format
  OF 13:
   EXECUTE FROM begin_get_clinical_event TO end_get_clinical_event
  OF 14:
   EXECUTE FROM begin_devicexref TO end_devicexref
  OF 15:
   EXECUTE FROM begin_laws TO end_laws
  OF 99:
   GO TO exit_script
 ENDCASE
 GO TO initialize
#end_initial_accepts
#begin_get_encntr_charts
 EXECUTE FROM initialize TO end_initialize
 CALL clear(1,1)
 CALL box(2,1,23,110)
 CALL text(3,22,"*** GET ENCOUNTER CHART HISTORY ***")
 CALL text(5,4,"Choose an Encntr_id: ")
 CALL accept(5,30,"P(40);Cf"," ")
 SET encntr_id_chosen = cnvtreal(curaccept)
 SELECT INTO "mine"
  chart_request_id = format(cr.chart_request_id,"############;L"), scope_flag = format(cr.scope_flag,
   "#####;L"), person_id = format(cr.person_id,"############;L"),
  cr.dist_run_dt_tm, cr.dist_run_type_cd, run_type_cd = format(uar_get_code_display(cr
    .dist_run_type_cd),"####################;L"),
  run_dt_tm = format(cr.dist_run_dt_tm,";;Q"), reltn_cd = format(uar_get_code_display(cr
    .prsnl_person_r_cd),"####################;L")
  FROM chart_request cr
  WHERE cr.encntr_id=encntr_id_chosen
   AND cr.request_type=4
  ORDER BY cr.dist_run_dt_tm
  HEAD REPORT
   linex = fillstring(130,"-"), row + 1, col 18,
   "Encounter Chart History", col 50, "ENCNTR_ID # ",
   col 65, encntr_id_chosen, row + 1,
   col 18, "=======================", row + 2
  HEAD PAGE
   col 2, "CHART_REQUEST_ID", col 20,
   "SCOPE", col 26, "DISTR_ID",
   col 39, "RUN DATE/TIME", col 65,
   "RUN TYPE", col 90, "PRSNL_ID",
   col 105, "RELATIONSHIP TYPE", row + 1,
   col 2, "----------------", col 20,
   "-----", col 26, "--------",
   col 39, "-----------------------", col 65,
   "-------------------", col 90, "--------",
   col 105, "-----------------", row + 1
  DETAIL
   col 2, chart_request_id, col 20,
   scope_flag, col 22, cr.distribution_id,
   col 39, run_dt_tm, col 65,
   run_type_cd, col 90, cr.prsnl_person_id,
   col 105, reltn_cd, row + 1
  WITH nocounter
 ;end select
#end_get_encntr_charts
#begin_get_encntr_details
 EXECUTE FROM initialize TO end_initialize
 CALL clear(1,1)
 CALL box(2,1,23,110)
 CALL text(3,22,"*** GET ENCOUNTER DETAILS ***")
 CALL text(5,4,"Choose an Encntr_id: ")
 CALL accept(5,30,"P(40);Cf"," ")
 SET encntr_id_chosen = cnvtreal(curaccept)
 SELECT INTO "mine"
  e.person_id, person_id = format(p.name_full_formatted,"####################;L"), e.updt_dt_tm,
  updt_dt_tm = format(e.updt_dt_tm,";;Q;R"), e.create_dt_tm, create_dt_tm = format(e.create_dt_tm,
   ";;Q;R"),
  e.encntr_type_cd, encntr_type_cd = format(uar_get_code_display(e.encntr_type_cd),
   "####################;L"), e.encntr_status_cd,
  encntr_status_cd = format(uar_get_code_display(e.encntr_status_cd),"####################;L"), e
  .med_service_cd, med_service_cd = format(uar_get_code_display(e.med_service_cd),
   "####################;L"),
  e.location_cd, location_cd = format(uar_get_code_display(e.location_cd),"####################;L"),
  e.loc_facility_cd,
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
   "Encounter Details", col 50, "ENCNTR_ID # ",
   col 65, encntr_id_chosen, row + 1,
   col 18, "=================", row + 2
  HEAD PAGE
   row + 1
  DETAIL
   IF (e.encntr_id > 0)
    IF (e.disch_dt_tm > cnvtdatetime("01-jan-1800"))
     disch_ind = "* Discharged *"
    ELSE
     disch_ind = " "
    ENDIF
    col 2, "Person_Id: ", col 20,
    e.person_id, col 40, person_id,
    row + 1, col 2, "Updt_Dt_Tm: ",
    col 40, updt_dt_tm, row + 1,
    col 2, "Create_Dt_Tm: ", col 40,
    create_dt_tm, row + 1, col 2,
    "Encntr_Type_Cd: ", col 20, e.encntr_type_cd,
    col 40, encntr_type_cd, row + 1,
    col 2, "Encntr_Status_Cd: ", col 20,
    e.encntr_status_cd, col 40, encntr_status_cd,
    row + 1, col 2, "Med_Service_Cd: ",
    col 20, e.med_service_cd, col 40,
    med_service_cd, row + 1, col 2,
    "Location_Cd: ", col 20, e.location_cd,
    col 40, location_cd, row + 1,
    col 2, "Loc_Facility_Cd: ", col 20,
    e.loc_facility_cd, col 40, loc_facility_cd,
    row + 1, col 2, "Loc_Building_Cd: ",
    col 20, e.loc_building_cd, col 40,
    loc_building_cd, row + 1, col 2,
    "Loc_Nurse_Unit_Cd: ", col 20, e.loc_nurse_unit_cd,
    col 40, loc_nurse_unit_cd, row + 1,
    col 2, "Loc_Room_Cd: ", col 20,
    e.loc_room_cd, col 40, loc_room_cd,
    row + 1, col 2, "Loc_Bed_Cd: ",
    col 20, e.loc_bed_cd, col 40,
    loc_bed_cd, row + 1, col 2,
    "Disch_Dt_Tm: ", col 40, disch_dt_tm,
    col 65, disch_ind, row + 1,
    col 2, "Organization_Id: ", col 20,
    e.organization_id, col 40, organization_id,
    row + 1
   ENDIF
  WITH nocounter
 ;end select
#end_get_encntr_details
#begin_does_encntr_qualify
 EXECUTE FROM initialize TO end_initialize
 CALL clear(1,1)
 CALL box(2,1,23,110)
 CALL text(3,22,"*** DOES ENCOUNTER QUALIFY FOR DISTRIBUTION ***")
 CALL text(5,4,"Choose an Encntr_id: ")
 CALL accept(5,30,"P(40);Cf"," ")
 SET encntr_id_chosen = cnvtreal(curaccept)
 SET distribution_id_chosen = 0
 CALL text(7,4,"Choose a Distribution: ")
 CALL text(9,4,"Shift/F5 to see a list of distributions")
 SET help =
 SELECT DISTINCT INTO "nl:"
  cd.dist_descr
  FROM chart_distribution cd
  WHERE cd.distribution_id > 0
   AND cd.active_ind=1
  ORDER BY cd.dist_descr
  WITH nocounter
 ;end select
 CALL accept(10,4,"P(80);C")
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
     stat = alterlist(location_rec->qual,(location_cnt+ 1)), location_cnt = (location_cnt+ 1),
     location_rec->qual[location_cnt].location_cd = e.loc_facility_cd
    ENDIF
    IF (e.loc_building_cd > 0)
     stat = alterlist(location_rec->qual,(location_cnt+ 1)), location_cnt = (location_cnt+ 1),
     location_rec->qual[location_cnt].location_cd = e.loc_building_cd
    ENDIF
    IF (e.loc_nurse_unit_cd > 0)
     stat = alterlist(location_rec->qual,(location_cnt+ 1)), location_cnt = (location_cnt+ 1),
     location_rec->qual[location_cnt].location_cd = e.loc_nurse_unit_cd
    ENDIF
    IF (e.loc_room_cd > 0)
     stat = alterlist(location_rec->qual,(location_cnt+ 1)), location_cnt = (location_cnt+ 1),
     location_rec->qual[location_cnt].location_cd = e.loc_room_cd
    ENDIF
    IF (e.loc_bed_cd > 0)
     stat = alterlist(location_rec->qual,(location_cnt+ 1)), location_cnt = (location_cnt+ 1),
     location_rec->qual[location_cnt].location_cd = e.loc_bed_cd
    ENDIF
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
     prov_id_cnt = (prov_id_cnt+ 1), stat = alterlist(prov_id_chosen->qual,prov_id_cnt),
     prov_id_chosen->qual[prov_id_cnt].prov_id = cdfv.parent_entity_id
    ENDIF
   DETAIL
    IF (cdfv.type_flag=0)
     stat = alterlist(encntr_type_chosen->qual,(encntr_type_cd_cnt+ 1)), encntr_type_cd_cnt = (
     encntr_type_cd_cnt+ 1), encntr_type_chosen->qual[encntr_type_cd_cnt].encntr_type_cd = cdfv
     .parent_entity_id
    ELSEIF (cdfv.type_flag=1)
     stat = alterlist(org_id_chosen->qual,(org_id_cnt+ 1)), org_id_cnt = (org_id_cnt+ 1),
     org_id_chosen->qual[org_id_cnt].org_id = cdfv.parent_entity_id
    ELSEIF (cdfv.type_flag=2)
     prov_type_cnt = (prov_type_cnt+ 1), stat = alterlist(prov_id_chosen->qual[prov_id_cnt].
      prov_type_qual,prov_type_cnt), prov_id_chosen->qual[prov_id_cnt].prov_type_qual[prov_type_cnt].
     prov_type_cd = cdfv.reltn_type_cd
    ELSEIF (cdfv.type_flag=3)
     stat = alterlist(location_chosen->qual,(location_chosen_cnt+ 1)), location_chosen_cnt = (
     location_chosen_cnt+ 1), location_chosen->qual[location_chosen_cnt].location_cd = cdfv
     .parent_entity_id
    ELSEIF (cdfv.type_flag=4)
     stat = alterlist(med_service_chosen->qual,(med_service_cnt+ 1)), med_service_cnt = (
     med_service_cnt+ 1), med_service_chosen->qual[med_service_cnt].medical_service_cd = cdfv
     .parent_entity_id
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
    included_rec->qual[1].included_flag = 99, included_rec->qual[2].included_flag = 99, included_rec
    ->qual[3].included_flag = 99,
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
   SET p_index = (p_index+ 1)
   SET stat = alterlist(parser1->qual,p_index)
   SET parser1->qual[p_index].statement =
   ' select into "nl:" epr.encntr_id from encntr_prsnl_reltn epr'
   SET p_index = (p_index+ 1)
   SET stat = alterlist(parser1->qual,p_index)
   SET parser1->qual[p_index].statement = " plan epr where epr.encntr_id = encntr_id_chosen and"
   SET p_index = (p_index+ 1)
   SET stat = alterlist(parser1->qual,p_index)
   SET parser1->qual[p_index].statement = build(" epr.active_ind = 1 and ",
    " epr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3) and ")
   SET p_index = (p_index+ 1)
   SET stat = alterlist(parser1->qual,p_index)
   SET parser1->qual[p_index].statement =
   " epr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3) and ("
   FOR (x = 1 TO size_providers)
     SET size_relationships = size(prov_id_chosen->qual[x].prov_type_qual,5)
     SET p_index = (p_index+ 1)
     SET stat = alterlist(parser1->qual,p_index)
     SET parser1->qual[p_index].statement = build("(epr.prsnl_person_id = ",prov_id_chosen->qual[x].
      prov_id," and epr.encntr_prsnl_r_cd in (",prov_id_chosen->qual[x].prov_type_qual[1].
      prov_type_cd)
     IF (size_relationships=1)
      SET p_index = (p_index+ 1)
      SET stat = alterlist(parser1->qual,p_index)
      SET parser1->qual[p_index].statement = " ))"
     ENDIF
     IF (size_relationships > 1)
      FOR (y = 2 TO size_relationships)
        SET p_index = (p_index+ 1)
        SET stat = alterlist(parser1->qual,p_index)
        SET parser1->qual[p_index].statement = build(",",prov_id_chosen->qual[x].prov_type_qual[y].
         prov_type_cd)
        IF (y=size_relationships)
         SET p_index = (p_index+ 1)
         IF (x=size_providers)
          SET stat = alterlist(parser1->qual,p_index)
          SET parser1->qual[p_index].statement = ")))"
         ELSE
          SET stat = alterlist(parser1->qual,p_index)
          SET parser1->qual[p_index].statement = "))"
          SET p_index = (p_index+ 1)
          SET stat = alterlist(parser1->qual,p_index)
          SET parser1->qual[p_index].statement = " OR "
         ENDIF
        ENDIF
      ENDFOR
     ELSE
      IF (x=size_providers)
       SET p_index = (p_index+ 1)
       SET stat = alterlist(parser1->qual,p_index)
       SET parser1->qual[p_index].statement = ")"
      ELSE
       SET p_index = (p_index+ 1)
       SET stat = alterlist(parser1->qual,p_index)
       SET parser1->qual[p_index].statement = " OR "
      ENDIF
     ENDIF
   ENDFOR
   SET p_index = (p_index+ 1)
   SET stat = alterlist(parser1->qual,(p_index+ 5))
   SET parser1->qual[p_index].statement = "HEAD REPORT"
   SET p_index = (p_index+ 1)
   SET parser1->qual[p_index].statement = "  cnt_qualify = 0"
   SET p_index = (p_index+ 1)
   SET parser1->qual[p_index].statement = "DETAIL"
   SET p_index = (p_index+ 1)
   SET parser1->qual[p_index].statement = "  cnt_qualify = cnt_qualify + 1"
   SET p_index = (p_index+ 1)
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
   SET p_index = (p_index+ 1)
   SET stat = alterlist(parser1->qual,p_index)
   SET parser1->qual[p_index].statement =
   ' select into "nl:" ppr.person_id from person_prsnl_reltn ppr'
   SET p_index = (p_index+ 1)
   SET stat = alterlist(parser1->qual,p_index)
   SET parser1->qual[p_index].statement = " plan ppr where ppr.person_id = person_id_chosen and "
   SET p_index = (p_index+ 1)
   SET stat = alterlist(parser1->qual,p_index)
   SET parser1->qual[p_index].statement = build(" ppr.active_ind = 1 and ",
    " ppr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3) and ")
   SET p_index = (p_index+ 1)
   SET stat = alterlist(parser1->qual,p_index)
   SET parser1->qual[p_index].statement =
   " ppr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3) and ("
   FOR (x = 1 TO size_providers)
     SET size_relationships = size(prov_id_chosen->qual[x].prov_type_qual,5)
     SET p_index = (p_index+ 1)
     SET stat = alterlist(parser1->qual,p_index)
     SET parser1->qual[p_index].statement = build("(ppr.prsnl_person_id = ",prov_id_chosen->qual[x].
      prov_id," and ppr.person_prsnl_r_cd in (",prov_id_chosen->qual[x].prov_type_qual[1].
      prov_type_cd)
     IF (size_relationships=1)
      SET p_index = (p_index+ 1)
      SET stat = alterlist(parser1->qual,p_index)
      SET parser1->qual[p_index].statement = " ))"
     ENDIF
     IF (size_relationships > 1)
      FOR (y = 2 TO size_relationships)
        SET p_index = (p_index+ 1)
        SET stat = alterlist(parser1->qual,p_index)
        SET parser1->qual[p_index].statement = build(",",prov_id_chosen->qual[x].prov_type_qual[y].
         prov_type_cd)
        IF (y=size_relationships)
         SET p_index = (p_index+ 1)
         IF (x=size_providers)
          SET stat = alterlist(parser1->qual,p_index)
          SET parser1->qual[p_index].statement = ")))"
         ELSE
          SET stat = alterlist(parser1->qual,p_index)
          SET parser1->qual[p_index].statement = "))"
          SET p_index = (p_index+ 1)
          SET stat = alterlist(parser1->qual,p_index)
          SET parser1->qual[p_index].statement = " OR "
         ENDIF
        ENDIF
      ENDFOR
     ELSE
      IF (x=size_providers)
       SET p_index = (p_index+ 1)
       SET stat = alterlist(parser1->qual,p_index)
       SET parser1->qual[p_index].statement = ")"
      ELSE
       SET p_index = (p_index+ 1)
       SET stat = alterlist(parser1->qual,p_index)
       SET parser1->qual[p_index].statement = " OR "
      ENDIF
     ENDIF
   ENDFOR
   SET p_index = (p_index+ 1)
   SET stat = alterlist(parser1->qual,(p_index+ 5))
   SET parser1->qual[p_index].statement = "HEAD REPORT"
   SET p_index = (p_index+ 1)
   SET parser1->qual[p_index].statement = "  do_nothing = 0"
   SET p_index = (p_index+ 1)
   SET parser1->qual[p_index].statement = "DETAIL"
   SET p_index = (p_index+ 1)
   SET parser1->qual[p_index].statement = "  cnt_qualify = cnt_qualify + 1"
   SET p_index = (p_index+ 1)
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
   SET p_index = (p_index+ 1)
   SET stat = alterlist(parser1->qual,p_index)
   SET parser1->qual[p_index].statement =
   ' select into "nl:" opr.encntr_id from order_prsnl_reltn opr'
   SET p_index = (p_index+ 1)
   SET stat = alterlist(parser1->qual,p_index)
   SET parser1->qual[p_index].statement = " plan opr where opr.encntr_id = encntr_id_chosen and ("
   FOR (x = 1 TO size_providers)
     SET size_relationships = size(prov_id_chosen->qual[x].prov_type_qual,5)
     SET p_index = (p_index+ 1)
     SET stat = alterlist(parser1->qual,p_index)
     SET parser1->qual[p_index].statement = build("(opr.prsnl_person_id = ",prov_id_chosen->qual[x].
      prov_id," and opr.chart_prsnl_r_type_cd in (",prov_id_chosen->qual[x].prov_type_qual[1].
      prov_type_cd)
     IF (size_relationships=1)
      SET p_index = (p_index+ 1)
      SET stat = alterlist(parser1->qual,p_index)
      SET parser1->qual[p_index].statement = " ))"
     ENDIF
     IF (size_relationships > 1)
      FOR (y = 2 TO size_relationships)
        SET p_index = (p_index+ 1)
        SET stat = alterlist(parser1->qual,p_index)
        SET parser1->qual[p_index].statement = build(",",prov_id_chosen->qual[x].prov_type_qual[y].
         prov_type_cd)
        IF (y=size_relationships)
         SET p_index = (p_index+ 1)
         IF (x=size_providers)
          SET stat = alterlist(parser1->qual,p_index)
          SET parser1->qual[p_index].statement = ")))"
         ELSE
          SET stat = alterlist(parser1->qual,p_index)
          SET parser1->qual[p_index].statement = "))"
          SET p_index = (p_index+ 1)
          SET stat = alterlist(parser1->qual,p_index)
          SET parser1->qual[p_index].statement = " OR "
         ENDIF
        ENDIF
      ENDFOR
     ELSE
      IF (x=size_providers)
       SET p_index = (p_index+ 1)
       SET stat = alterlist(parser1->qual,p_index)
       SET parser1->qual[p_index].statement = ")"
      ELSE
       SET p_index = (p_index+ 1)
       SET stat = alterlist(parser1->qual,p_index)
       SET parser1->qual[p_index].statement = " OR "
      ENDIF
     ENDIF
   ENDFOR
   SET p_index = (p_index+ 1)
   SET stat = alterlist(parser1->qual,(p_index+ 5))
   SET parser1->qual[p_index].statement = "HEAD REPORT"
   SET p_index = (p_index+ 1)
   SET parser1->qual[p_index].statement = "  do_nothing = 0"
   SET p_index = (p_index+ 1)
   SET parser1->qual[p_index].statement = "DETAIL"
   SET p_index = (p_index+ 1)
   SET parser1->qual[p_index].statement = "  cnt_qualify = cnt_qualify + 1"
   SET p_index = (p_index+ 1)
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
    pass_rec->qual[6].get_out = 0, size1 = cnvtint(size(encntr_type_chosen->qual,5)), size2 = cnvtint
    (size(org_id_chosen->qual,5)),
    size4 = cnvtint(size(location_chosen->qual,5)), size_location = cnvtint(size(location_rec->qual,5
      )), size5 = cnvtint(size(med_service_chosen->qual,5)),
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
 ELSE
  SET pass_rec->qual[1].pass = 0
  SET pass_rec->qual[2].pass = 0
  SET pass_rec->qual[3].pass = 0
  SET pass_rec->qual[4].pass = 0
  SET pass_rec->qual[5].pass = 0
  SET pass_rec->qual[6].pass = 0
 ENDIF
 SELECT INTO "mine"
  dist_id = cd.distribution_id
  FROM chart_distribution cd
  WHERE cd.distribution_id=distribution_id_chosen
  HEAD REPORT
   row + 1, col 2, "Encntr_Id:",
   col 30, encntr_id_chosen, row + 1,
   col 2, "Distribution_Id:", col 30,
   dist_id, row + 3, col 5,
   "DOES ENCOUNTER QUALIFY FOR DISTRIBUTION?", row + 2
  DETAIL
   do_nothing = 0
  FOOT REPORT
   col 5, "Distribution Type: "
   IF ((pass_rec->qual[1].pass=1))
    col 35, "PASSED"
   ELSEIF ((pass_rec->qual[1].pass=0))
    col 35, "FAILED"
   ELSE
    col 35, " --- "
   ENDIF
   row + 1, col 5, "Encounter Type: "
   IF ((pass_rec->qual[2].pass=1))
    col 35, "PASSED"
   ELSEIF ((pass_rec->qual[2].pass=0))
    col 35, "FAILED"
   ELSE
    col 35, " --- "
   ENDIF
   row + 1, col 5, "Organization: "
   IF ((pass_rec->qual[3].pass=1))
    col 35, "PASSED"
   ELSEIF ((pass_rec->qual[3].pass=0))
    col 35, "FAILED"
   ELSE
    col 35, " --- "
   ENDIF
   row + 1, col 5, "Providers: "
   IF ((pass_rec->qual[4].pass=1))
    col 35, "PASSED"
   ELSEIF ((pass_rec->qual[4].pass=0))
    col 35, "FAILED"
   ELSE
    col 35, " --- "
   ENDIF
   row + 1, col 5, "Location: "
   IF ((pass_rec->qual[5].pass=1))
    col 35, "PASSED"
   ELSEIF ((pass_rec->qual[5].pass=0))
    col 35, "FAILED"
   ELSE
    col 35, " --- "
   ENDIF
   row + 1, col 5, "Medical Service: "
   IF ((pass_rec->qual[6].pass=1))
    col 35, "PASSED"
   ELSEIF ((pass_rec->qual[6].pass=0))
    col 35, "FAILED"
   ELSE
    col 35, " --- "
   ENDIF
   row + 2
  WITH nocounter
 ;end select
#end_does_encntr_qualify
#begin_get_distribution_details
 EXECUTE FROM initialize TO end_initialize
 CALL clear(1,1)
 CALL box(2,1,23,110)
 CALL text(3,22,"*** GET DISTRIBUTION DETAILS ***")
 SET distribution_id_chosen = 0.0
 CALL text(5,4,"Choose a Distribution: ")
 CALL text(7,4,"Shift/F5 to see a list of distributions")
 SET help =
 SELECT DISTINCT INTO "nl:"
  cd.dist_descr
  FROM chart_distribution cd
  WHERE cd.distribution_id > 0
   AND cd.active_ind=1
  ORDER BY cd.dist_descr
  WITH nocounter
 ;end select
 CALL accept(8,4,"P(80);C")
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
 SELECT INTO "nl:"
  FROM chart_dist_filter cdf
  WHERE cdf.distribution_id=distribution_id_chosen
  HEAD REPORT
   do_nothing = 0, encounter_type_include = 99, organization_include = 99,
   providers_include = 99, location_include = 99, med_service_include = 99
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
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM chart_dist_filter_value cdfv
  WHERE cdfv.distribution_id=distribution_id_chosen
  HEAD REPORT
   do_nothing = 0, dist_encounter_type_cnt = 0, dist_org_id_cnt = 0,
   dist_prov_cnt = 0, dist_location_cnt = 0, dist_med_service_cnt = 0
  DETAIL
   IF (cdfv.type_flag=0)
    dist_encounter_type_cnt = (dist_encounter_type_cnt+ 1), stat = alterlist(dist_encounter_types->
     qual,(dist_encounter_type_cnt+ 1)), dist_encounter_types->qual[dist_encounter_type_cnt].
    encounter_types = cdfv.parent_entity_id
   ELSEIF (cdfv.type_flag=1)
    dist_org_id_cnt = (dist_org_id_cnt+ 1), stat = alterlist(dist_org_ids->qual,(dist_org_id_cnt+ 1)),
    dist_org_ids->qual[dist_org_id_cnt].org_ids = cdfv.parent_entity_id
   ELSEIF (cdfv.type_flag=2)
    dist_prov_cnt = (dist_prov_cnt+ 1), stat = alterlist(dist_providers->qual,(dist_prov_cnt+ 1)),
    dist_providers->qual[dist_prov_cnt].providers = cdfv.parent_entity_id,
    dist_providers->qual[dist_prov_cnt].reltn_type_cd = cdfv.reltn_type_cd
   ELSEIF (cdfv.type_flag=3)
    dist_location_cnt = (dist_location_cnt+ 1), stat = alterlist(dist_locations->qual,(
     dist_location_cnt+ 1)), dist_locations->qual[dist_location_cnt].locations = cdfv
    .parent_entity_id
   ELSEIF (cdfv.type_flag=4)
    dist_med_service_cnt = (dist_med_service_cnt+ 1), stat = alterlist(dist_med_services->qual,(
     dist_med_service_cnt+ 1)), dist_med_services->qual[dist_med_service_cnt].med_services = cdfv
    .parent_entity_id
   ENDIF
  WITH nocounter
 ;end select
 SET size_1 = size(dist_encounter_types->qual,5)
 SET size_2 = size(dist_org_ids->qual,5)
 SET size_3 = size(dist_providers->qual,5)
 SET size_4 = size(dist_locations->qual,5)
 SET size_5 = size(dist_med_services->qual,5)
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
 SELECT
  dist_descr = format(cd.dist_descr,"############################################;L"), reader_group
   = format(cd.reader_group,"###########################################;L"), banner_page = format(cd
   .banner_page,"###########################################################################;L")
  FROM chart_distribution cd,
   chart_dist_filter_value cdfv
  PLAN (cd
   WHERE cd.distribution_id=distribution_id_chosen)
   JOIN (cdfv
   WHERE cdfv.distribution_id=cd.distribution_id)
  ORDER BY cdfv.type_flag, cdfv.key_sequence
  HEAD REPORT
   linex = fillstring(130,"-"), row + 1, col 5,
   " * * DISTRIBUTION DETAILS * *", row + 2, col 2,
   "Distribution_Id: ", col 35, cd.distribution_id,
   row + 1, col 2, "Distribution Description: ",
   col 35, dist_descr, row + 1,
   col 2, "Distribution Type: ", col 35,
   cd.dist_type
   IF (cd.dist_type=1)
    col 52, "Non-Discharged Only"
   ELSEIF (cd.dist_type=2)
    col 52, "Discharged Only"
   ELSE
    col 52, "Both"
   ENDIF
   row + 1, col 2, "Days Till Chart: ",
   col 35, cd.days_till_chart, row + 1,
   col 2, "Reader Group: ", col 35,
   reader_group, row + 1, col 2,
   "Cutoff Details:", row + 1, col 8,
   cd.cutoff_days, col 20, "DAYS"
   IF (cd.cutoff_and_or_ind=1)
    col 27, "AND"
   ELSEIF (cd.cutoff_and_or_ind=2)
    col 27, "OR"
   ENDIF
   col 30, cd.cutoff_pages, col 42,
   "PAGES", row + 1, col 2,
   "Banner Page: ", col 35, banner_page,
   row + 1, col 2, "Delete Old Distribution Flag: "
   IF (cd.delete_old_distr_flag > 0)
    col 35, cd.delete_old_distr_flag, col 40,
    "DAYS"
   ELSE
    col 35, "NOT ACTIVATED"
   ENDIF
   row + 1, col 2, "Advanced Lookback Options:",
   row + 1, col 4, "Initial distribution lookback:",
   max_lookback_dt_tm_str = format(cd.max_lookback_dt_tm,"@SHORTDATETIME"),
   first_qualification_dt_tm_str = format(cd.first_qualification_dt_tm,"@SHORTDATETIME"),
   absolute_qualification_dt_tm_str = format(cd.absolute_qualification_dt_tm,"@SHORTDATETIME"),
   row + 1
   IF (cd.max_lookback_ind=0)
    col 20, "Date: ", col + 1,
    max_lookback_dt_tm_str
   ELSE
    col 20, cd.max_lookback_days, col + 1,
    "Days"
   ENDIF
   row + 1, col 4, "First Qualification Lookback:",
   row + 1
   IF (cd.print_lookback_ind=0)
    col 20, "Date: ", col + 1,
    first_qualification_dt_tm_str
   ELSEIF (cd.print_lookback_ind=2)
    col 20, "Patient admit date"
   ELSEIF (cd.print_lookback_ind=1)
    col 20, "Previous distribution run"
   ELSE
    col 20, cd.first_qualification_days, col + 1,
    "Days"
   ENDIF
   row + 1, col 4, "Absolute Lookback:",
   row + 1
   IF (cd.absolute_lookback_ind=0)
    col 20, "Date: ", col + 1,
    absolute_qualification_dt_tm_str
   ELSE
    col 20, cd.absolute_qualification_days, col + 1,
    "Days"
   ENDIF
   row + 3, col 1, linex,
   row + 1, col 1, "Encounter Type",
   col 19, "Organization", col 37,
   "Providers", col 68, "Location",
   col 88, "Medical Service", row + 1
   IF (encounter_type_include=1)
    col 1, "(Include)"
   ELSEIF (encounter_type_include=0)
    col 1, "(Exclude)"
   ELSE
    col 1, " "
   ENDIF
   IF (organization_include=1)
    col 19, "(Include)"
   ELSEIF (organization_include=0)
    col 19, "(Exclude)"
   ELSE
    col 19, " "
   ENDIF
   IF (providers_include=1)
    col 37, "(Include)"
   ELSEIF (providers_include=0)
    col 37, "(Exclude)"
   ELSE
    col 37, " "
   ENDIF
   IF (location_include=1)
    col 68, "(Include)"
   ELSEIF (location_include=0)
    col 68, "(Exclude)"
   ELSE
    col 68, " "
   ENDIF
   IF (med_service_include=1)
    col 88, "(Include)"
   ELSEIF (med_service_include=0)
    col 88, "(Exclude)"
   ELSE
    col 88, " "
   ENDIF
   row + 1, col 1, "**************",
   col 19, "**************", col 37,
   "****************************", col 68, "**************",
   col 88, "**************", row + 1
  DETAIL
   do_nothing = 0
  FOOT REPORT
   FOR (x = 1 TO (max_size - 1))
     IF ((x <= (size_1 - 1)))
      col 0, dist_encounter_types->qual[x].encounter_types
     ENDIF
     IF ((x <= (size_2 - 1)))
      col 16, dist_org_ids->qual[x].org_ids
     ENDIF
     IF ((x <= (size_3 - 1)))
      col 34, dist_providers->qual[x].providers, col 47,
      " - ", col 50, dist_providers->qual[x].reltn_type_cd
     ENDIF
     IF ((x <= (size_4 - 1)))
      col 68, dist_locations->qual[x].locations
     ENDIF
     IF ((x <= (size_5 - 1)))
      col 88, dist_med_services->qual[x].med_services
     ENDIF
     row + 1
   ENDFOR
  WITH nocounter
 ;end select
#end_get_distribution_details
#begin_get_operations_details
 CALL clear(1,1)
 CALL box(2,1,23,110)
 CALL text(3,22,"*** GET OPERATIONS DETAILS ***")
 CALL text(5,4,"Choose an Operation: ")
 CALL text(7,4,"Shift/F5 to see a list of Operations")
 SET help =
 SELECT DISTINCT INTO "nl:"
  co.batch_name
  FROM charting_operations co
  WHERE co.active_ind=1
   AND co.charting_operations_id > 0
  ORDER BY co.batch_name
  WITH nocounter
 ;end select
 CALL accept(8,4,"P(80);C")
 SET help = off
 SET operations_name_chosen = fillstring(80," ")
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
   p_6_cnt = 1, p_12_cnt = 1, p_13_cnt = 1,
   p_6_meaning_cnt = 1, p_12_meaning_cnt = 1, p_13_meaning_cnt = 1
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
     IF (co.param="ALL")
      p_6[p_6_cnt] = "9999", p_6_cnt = (p_6_cnt+ 1)
     ELSE
      p_6[p_6_cnt] = co.param, p_6_cnt = (p_6_cnt+ 1)
     ENDIF
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
     p_12[p_12_cnt] = co.param,p_12_cnt = (p_12_cnt+ 1)
    OF 13:
     p_13[p_13_cnt] = co.param,p_13_cnt = (p_13_cnt+ 1)
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
     p_17 = substring(1,50,co.param)
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
      p_20_meaning = "Include Specific Providers"
     ELSEIF (cnvtint(p_20)=2)
      p_20_meaning = "Exclude Specific Providers"
     ENDIF
   ENDCASE
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  meaning = format(uar_get_code_display(cnvtreal(co.param)),"##################################;L")
  FROM charting_operations co
  WHERE co.param_type_flag IN (6, 12, 13)
   AND co.charting_operations_id=operations_id_chosen
   AND co.active_ind=1
  HEAD REPORT
   p_6_meaning_cnt = 0, p_12_meaning_cnt = 0, p_13_meaning_cnt = 0
  DETAIL
   IF (co.param_type_flag=6)
    p_6_meaning_cnt = (p_6_meaning_cnt+ 1)
    IF (mod(p_6_meaning_cnt,10)=1)
     stat = alterlist(p_6_meaning->qual,(p_6_meaning_cnt+ 9))
    ENDIF
    IF (meaning=" ")
     p_6_meaning->qual[p_6_meaning_cnt].p6_meaning = "ALL"
     IF (cnvtint(p_1)=4)
      order_doc_ind = 1
     ENDIF
    ELSE
     p_6_meaning->qual[p_6_meaning_cnt].p6_meaning = meaning
     IF (cnvtint(p_1)=4
      AND cnvtreal(co.param)=order_doc_cd)
      order_doc_ind = 1
     ENDIF
    ENDIF
   ELSEIF (co.param_type_flag=12)
    p_12_meaning_cnt = (p_12_meaning_cnt+ 1)
    IF (mod(p_12_meaning_cnt,10)=1)
     stat = alterlist(p_12_meaning->qual,(p_12_meaning_cnt+ 9))
    ENDIF
    p_12_meaning->qual[p_12_meaning_cnt].p12_meaning = meaning
   ELSEIF (co.param_type_flag=13)
    p_13_meaning_cnt = (p_13_meaning_cnt+ 1)
    IF (mod(p_13_meaning_cnt,10)=1)
     stat = alterlist(p_13_meaning->qual,(p_13_meaning_cnt+ 9))
    ENDIF
    p_13_meaning->qual[p_13_meaning_cnt].p13_meaning = meaning
   ENDIF
  WITH nocounter
 ;end select
 IF (p_6_meaning_cnt > 0)
  FOR (y = 1 TO p_6_meaning_cnt)
    IF ((p_6[y]="9999"))
     SET p_6_meaning->qual[y].p6_meaning = "ALL"
    ELSE
     SET p_6_meaning->qual[y].p6_meaning = uar_get_code_display(cnvtreal(p_6[y]))
    ENDIF
  ENDFOR
 ENDIF
 IF (p_12_meaning_cnt > 0)
  FOR (z = 1 TO p_12_meaning_cnt)
    SET p_12_meaning->qual[z].p12_meaning = uar_get_code_display(cnvtreal(p_12[z]))
  ENDFOR
 ENDIF
 IF (p_13_meaning_cnt > 0)
  FOR (w = 1 TO p_13_meaning_cnt)
    SET p_13_meaning->qual[w].p13_meaning = uar_get_code_display(cnvtreal(p_13[w]))
  ENDFOR
 ENDIF
 IF (cnvtint(p_20) > 0)
  SELECT INTO "nl:"
   cop.prsnl_id
   FROM charting_operations_prsnl cop,
    prsnl p
   PLAN (cop
    WHERE cop.charting_operations_id=operations_id_chosen)
    JOIN (p
    WHERE p.person_id=cop.prsnl_id
     AND p.active_ind=1
     AND p.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
     AND ((p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)) OR (p.end_effective_dt_tm=null)) )
   ORDER BY p.name_full_formatted
   HEAD REPORT
    nbr = 0
   DETAIL
    nbr = (nbr+ 1)
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
  WHERE ((cv.code_value=cnvtreal(p_3)) OR (((cv.code_value=cnvtreal(p_14)) OR (cv.code_value=cnvtreal
  (p_15))) ))
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
  FROM chart_format cf
  WHERE cf.chart_format_id=cnvtreal(p_4)
  HEAD REPORT
   do_nothing = 0
  DETAIL
   p_4_meaning = cf.chart_format_desc
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
  batch_name = substring(1,20,co.batch_name)
  FROM charting_operations co
  WHERE co.charting_operations_id=operations_id_chosen
   AND co.active_ind=1
  ORDER BY co.param_type_flag, co.sequence
  HEAD REPORT
   linex = fillstring(130,"-"), row + 1, col 5,
   " * * CHARTING OPERATIONS DETAILS * *", row + 2, col 2,
   "Charting Operations Id: ", col 30, operations_id_chosen,
   col 48, "|", col 55,
   batch_name, row + 2, col 2,
   "#1 - Chart Scope: ", col 35, p_1,
   col 48, "|", col 55,
   p_1_meaning, row + 1, col 2,
   "#2 - Distribution Id: ", col 35, p_2,
   col 48, "|", col 55,
   p_2_meaning, row + 1, col 2,
   "#3 - Run Type: ", col 35, p_3,
   col 48, "|", col 55,
   p_3_meaning, row + 1, col 2,
   "#4 - Chart Format: ", col 35, p_4,
   col 48, "|", col 55,
   p_4_meaning, row + 1, col 2,
   "#7 - Print Finals: ", col 35, p_7,
   col 48, "|", col 55,
   p_7_meaning, row + 1, col 2,
   "#8 - MCIS: ", col 35, p_8,
   col 48, "|", col 55,
   p_8_meaning, row + 1, col 2,
   "#9 - Distribution Routing: ", col 35, p_9,
   col 48, "|", col 55,
   p_9_meaning, row + 1, col 2,
   "#10 - Default Printer: ", col 35, p_10,
   col 48, "|", col 55,
   p_10_meaning, row + 1, col 2,
   "#14 - File Storage: ", col 35, p_14,
   col 48, "|", col 55,
   p_14_meaning, row + 1, col 2,
   "#15 - Sort Sequence: ", col 35, p_15,
   col 48, "|", col 55,
   p_15_meaning, row + 1, col 2,
   "#16 - Default Chart: ", col 35, p_16,
   col 48, "|", col 55,
   p_16_meaning, row + 1, col 2,
   "#17 - File Storage Path: ", col 35, p_17
   IF (order_doc_ind=1)
    row + 1, col 2, "#19 - Ordering Physician Copy: ",
    col 35, p_19, col 48,
    "|", col 55, p_19_meaning
   ENDIF
   row + 1, col 2, "#20 - Provider Routing: ",
   col 35, p_20, col 48,
   "|", col 55, p_20_meaning,
   row + 3, col 1, linex,
   row + 1, col 5, "#6 - Providers",
   col 40, "#12 - Activity Hold", col 75,
   "#13 - Order Status Hold", row + 1, col 5,
   "**************", col 40, "*******************",
   col 75, "***********************", row + 1
  DETAIL
   do_nothing = 0
  FOOT REPORT
   FOR (x = 1 TO max_param_size)
     IF (x <= p_6_cnt
      AND p_6_cnt > 0)
      col 5, p_6_meaning->qual[x].p6_meaning
     ENDIF
     IF (x <= p_12_cnt
      AND p_12_cnt > 0)
      col 40, p_12_meaning->qual[x].p12_meaning
     ENDIF
     IF (x <= p_13_cnt
      AND p_13_cnt > 0)
      col 75, p_13_meaning->qual[x].p13_meaning
     ENDIF
     row + 1
   ENDFOR
   IF (cnvtint(p_20) > 0)
    col 5, "#20 - ", p_20_meaning,
    row + 1, col 5, "*********************************"
    FOR (x = 1 TO size(prov_routing->qual,5))
      row + 1, col 5, prov_routing->qual[x].prov_name,
      x = (x+ 1)
      IF (x <= size(prov_routing->qual,5))
       col 32, prov_routing->qual[x].prov_name
      ENDIF
      x = (x+ 1)
      IF (x <= size(prov_routing->qual,5))
       col 60, prov_routing->qual[x].prov_name
      ENDIF
    ENDFOR
   ENDIF
  WITH nocounter
 ;end select
#end_get_operations_details
#begin_get_reltns
 EXECUTE FROM initialize TO end_initialize
 CALL clear(1,1)
 CALL box(2,1,23,110)
 CALL text(3,22,"*** GET PROVIDER RELATIONSHIPS - ANY SCOPE ***")
 CALL text(5,4,"Choose a Scope: ")
 CALL text(6,4,"1=Person, 2=Encounter, 4=Accession, 9=All")
 CALL accept(7,4,"99;",02
  WHERE curaccept IN (01, 02, 04, 09))
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
  CALL text(9,4,"Choose an Encntr_id:")
  CALL accept(9,30,"P(40);Cf"," ")
  SET encntr_id_chosen = cnvtreal(curaccept)
 ELSEIF (scope_chosen=9)
  CALL text(9,4,"Choose an Person_id:")
  CALL accept(9,30,"P(40);Cf"," ")
  SET person_id_chosen = cnvtreal(curaccept)
 ELSE
  CALL text(9,4,"Choose a Person_id:")
  CALL accept(9,30,"P(40);Cf"," ")
  SET person_id_chosen = cnvtreal(curaccept)
 ENDIF
 IF (scope_chosen=1)
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
   ORDER BY p.name_full_formatted
   HEAD REPORT
    do_nothing = 0, pers_prsnl_cnt = 1
   DETAIL
    IF (mod(pers_prsnl_cnt,10)=1)
     stat = alterlist(pers_prsnl_rec->qual,(pers_prsnl_cnt+ 9))
    ENDIF
    pers_prsnl_rec->qual[pers_prsnl_cnt].prsnl_person_id = ppr.prsnl_person_id, pers_prsnl_rec->qual[
    pers_prsnl_cnt].reltn_cd = cv.display, pers_prsnl_rec->qual[pers_prsnl_cnt].prsnl_name = p
    .name_full_formatted,
    pers_prsnl_cnt = (pers_prsnl_cnt+ 1)
   FOOT REPORT
    row + 1, col 2, "Person_id: ",
    col 15, person_id_chosen, row + 3,
    col 2, "Person-Level Providers", row + 1,
    col 2, "=========================", row + 2,
    col 8, "Prsnl_Id", col 20,
    "Provider Name", col 70, "Provider Relationship",
    row + 1, col 8, "--------",
    col 20, "-------------", col 70,
    "---------------------", row + 1
    FOR (x = 1 TO (pers_prsnl_cnt - 1))
      col 2, pers_prsnl_rec->qual[x].prsnl_person_id, col 20,
      pers_prsnl_rec->qual[x].prsnl_name, col 70, pers_prsnl_rec->qual[x].reltn_cd,
      row + 1
    ENDFOR
   WITH nocounter
  ;end select
 ELSEIF (scope_chosen=2)
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
   ORDER BY p.name_full_formatted
   HEAD REPORT
    do_nothing = 0, enc_prsnl_cnt = 1
   DETAIL
    IF (mod(enc_prsnl_cnt,10)=1)
     stat = alterlist(enc_prsnl_rec->qual,(enc_prsnl_cnt+ 9))
    ENDIF
    enc_prsnl_rec->qual[enc_prsnl_cnt].prsnl_person_id = epr.prsnl_person_id, enc_prsnl_rec->qual[
    enc_prsnl_cnt].reltn_cd = cv.display, enc_prsnl_rec->qual[enc_prsnl_cnt].prsnl_name = p
    .name_full_formatted,
    enc_prsnl_cnt = (enc_prsnl_cnt+ 1)
   FOOT REPORT
    row + 1, col 2, "Encounter_id: ",
    col 15, encntr_id_chosen, row + 3,
    col 2, "Encounter-Level Providers", row + 1,
    col 2, "=========================", row + 2,
    col 8, "Prsnl_Id", col 20,
    "Provider Name", col 70, "Provider Relationship",
    row + 1, col 8, "--------",
    col 20, "-------------", col 70,
    "---------------------", row + 1
    FOR (x = 1 TO (enc_prsnl_cnt - 1))
      col 2, enc_prsnl_rec->qual[x].prsnl_person_id, col 20,
      enc_prsnl_rec->qual[x].prsnl_name, col 70, enc_prsnl_rec->qual[x].reltn_cd,
      row + 1
    ENDFOR
   WITH nocounter
  ;end select
 ELSEIF (scope_chosen=4)
  SELECT INTO "mine"
   p.name_full_formatted
   FROM chart_prsnl_reltn cpr,
    code_value cv,
    prsnl p
   PLAN (cpr
    WHERE cpr.encntr_id=encntr_id_chosen
     AND cpr.scope=4)
    JOIN (cv
    WHERE cv.code_value=cpr.chart_prsnl_r_type_cd)
    JOIN (p
    WHERE p.person_id=cpr.prsnl_person_id)
   ORDER BY p.name_full_formatted
   HEAD REPORT
    do_nothing = 0, enc_prsnl_cnt = 1
   DETAIL
    IF (mod(enc_prsnl_cnt,10)=1)
     stat = alterlist(enc_prsnl_rec->qual,(enc_prsnl_cnt+ 9))
    ENDIF
    enc_prsnl_rec->qual[enc_prsnl_cnt].prsnl_person_id = cpr.prsnl_person_id, enc_prsnl_rec->qual[
    enc_prsnl_cnt].reltn_cd = cv.display, enc_prsnl_rec->qual[enc_prsnl_cnt].prsnl_name = p
    .name_full_formatted,
    enc_prsnl_cnt = (enc_prsnl_cnt+ 1)
   FOOT REPORT
    row + 1, col 2, "Encounter_id: ",
    col 15, encntr_id_chosen, row + 3,
    col 2, "Order-Level Providers", row + 1,
    col 2, "=========================", row + 2,
    col 8, "Prsnl_Id", col 20,
    "Provider Name", col 70, "Provider Relationship",
    row + 1, col 8, "--------",
    col 20, "-------------", col 70,
    "---------------------", row + 1
    FOR (x = 1 TO (enc_prsnl_cnt - 1))
      col 2, enc_prsnl_rec->qual[x].prsnl_person_id, col 20,
      enc_prsnl_rec->qual[x].prsnl_name, col 70, enc_prsnl_rec->qual[x].reltn_cd,
      row + 1
    ENDFOR
   WITH nocounter
  ;end select
 ELSEIF (scope_chosen=9)
  SELECT INTO "mine"
   p.name_full_formatted
   FROM chart_prsnl_reltn cpr,
    code_value cv,
    prsnl p
   PLAN (cpr
    WHERE cpr.person_id=person_id_chosen)
    JOIN (cv
    WHERE cv.code_value=cpr.chart_prsnl_r_type_cd)
    JOIN (p
    WHERE p.person_id=cpr.prsnl_person_id)
   ORDER BY p.name_full_formatted
   HEAD REPORT
    do_nothing = 0, enc_prsnl_cnt = 1
   DETAIL
    IF (mod(enc_prsnl_cnt,10)=1)
     stat = alterlist(enc_prsnl_rec->qual,(enc_prsnl_cnt+ 9))
    ENDIF
    enc_prsnl_rec->qual[enc_prsnl_cnt].prsnl_person_id = cpr.prsnl_person_id, enc_prsnl_rec->qual[
    enc_prsnl_cnt].reltn_cd = cv.display, enc_prsnl_rec->qual[enc_prsnl_cnt].prsnl_name = p
    .name_full_formatted,
    enc_prsnl_cnt = (enc_prsnl_cnt+ 1)
   FOOT REPORT
    row + 1, col 2, "Person_id: ",
    col 15, person_id_chosen, row + 3,
    col 2, "All-Level Providers", row + 1,
    col 2, "=========================", row + 2,
    col 8, "Prsnl_Id", col 20,
    "Provider Name", col 70, "Provider Relationship",
    row + 1, col 8, "--------",
    col 20, "-------------", col 70,
    "---------------------", row + 1
    FOR (x = 1 TO (enc_prsnl_cnt - 1))
      col 2, enc_prsnl_rec->qual[x].prsnl_person_id, col 20,
      enc_prsnl_rec->qual[x].prsnl_name, col 70, enc_prsnl_rec->qual[x].reltn_cd,
      row + 1
    ENDFOR
   WITH nocounter
  ;end select
 ENDIF
#end_get_reltns
#begin_get_dist_runs
 EXECUTE FROM initialize TO end_initialize
 CALL clear(1,1)
 CALL box(2,1,23,110)
 CALL text(3,22,"*** GET DISTRIBUTION RUN DATE/TIMES ***")
 SET distribution_id_chosen = 0.0
 CALL text(5,4,"Choose a Distribution: ")
 CALL text(7,4,"Shift/F5 to see a list of distributions")
 SET help =
 SELECT DISTINCT INTO "nl:"
  cd.dist_descr
  FROM chart_distribution cd
  WHERE cd.distribution_id > 0
   AND cd.active_ind=1
  ORDER BY cd.dist_descr
  WITH nocounter
 ;end select
 CALL accept(8,4,"P(80);C")
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
 SELECT INTO "nl:"
  cr.dist_run_dt_tm
  FROM chart_request cr
  WHERE cr.request_type=4
   AND cr.distribution_id=distribution_id_chosen
  ORDER BY cr.dist_run_dt_tm
  HEAD REPORT
   count_dist = 0
  HEAD cr.dist_run_dt_tm
   count_dist = (count_dist+ 1), stat = alterlist(distrun->qual,count_dist), distrun->qual[count_dist
   ].count = 0,
   distrun->qual[count_dist].server_name = cr.server_name
  DETAIL
   distrun->qual[count_dist].count = (distrun->qual[count_dist].count+ 1)
  WITH nocounter
 ;end select
 SELECT DISTINCT
  cr.distribution_id, cr.dist_run_type_cd, run_dt_tm = format(cr.dist_run_dt_tm,";;Q;R")
  FROM chart_request cr
  WHERE cr.distribution_id=distribution_id_chosen
  ORDER BY cr.dist_run_dt_tm
  HEAD REPORT
   cnt_dist = 0, linex = fillstring(130,"-"), row + 1,
   col 2, "Distribution_Id: ", col 35,
   distribution_id_chosen, row + 1, col 2,
   "Distribution Description: ", col 35, distribution_name_chosen,
   row + 2, run_type_cd = format(uar_get_code_display(cr.dist_run_type_cd),
    "#################################;L"), col 2,
   "Run Date/Time", col 30, "Run-Type",
   col 56, "Chart Format", col 85,
   "# Qual", col 95, "Chart Server",
   row + 1, col 2, "*************",
   col 30, "********", col 56,
   "************", col 85, "******",
   col 95, "************"
  DETAIL
   cnt_dist = (cnt_dist+ 1), row + 1, col 2,
   run_dt_tm, col 30, run_type_cd,
   col 53, cr.chart_format_id, col 80,
   distrun->qual[cnt_dist].count, col 95, distrun->qual[cnt_dist].server_name
  WITH nocounter, outerjoin = dtbl
 ;end select
#end_get_dist_runs
#begin_validate_co_table
 EXECUTE FROM initialize TO end_initialize
 SET final_cd = 0.0
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.cdf_meaning="FINAL"
   AND cv.code_set=22550
   AND cv.active_ind=1
  HEAD REPORT
   do_nothing = 0
  DETAIL
   final_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM charting_operations co
  WHERE co.active_ind=1
  ORDER BY co.charting_operations_id, co.param_type_flag, co.param,
   co.sequence
  HEAD REPORT
   ops_job_cnt = 0
  HEAD co.charting_operations_id
   ops_job_cnt = (ops_job_cnt+ 1), stat = alterlist(ops_job_rec->qual,ops_job_cnt), ops_job_rec->
   qual[ops_job_cnt].ops_job_id = co.charting_operations_id,
   ops_job_rec->qual[ops_job_cnt].ops_batch_name = co.batch_name, param_cnt = 1
  HEAD co.param_type_flag
   CASE (co.param_type_flag)
    OF 1:
     stat = alterlist(ops_job_rec->qual[ops_job_cnt].ops_job_params,param_cnt),ops_job_rec->qual[
     ops_job_cnt].ops_job_params[1].param_1 = cnvtint(co.param)
    OF 2:
     stat = alterlist(ops_job_rec->qual[ops_job_cnt].ops_job_params,param_cnt),ops_job_rec->qual[
     ops_job_cnt].ops_job_params[1].param_2 = cnvtint(co.param)
    OF 3:
     stat = alterlist(ops_job_rec->qual[ops_job_cnt].ops_job_params,param_cnt),ops_job_rec->qual[
     ops_job_cnt].ops_job_params[1].param_3 = cnvtint(co.param)
    OF 4:
     stat = alterlist(ops_job_rec->qual[ops_job_cnt].ops_job_params,param_cnt),ops_job_rec->qual[
     ops_job_cnt].ops_job_params[1].param_4 = cnvtint(co.param)
    OF 6:
     stat = alterlist(ops_job_rec->qual[ops_job_cnt].ops_job_params,param_cnt),ops_job_rec->qual[
     ops_job_cnt].ops_job_params[1].param_6 = cnvtint(co.param)
    OF 7:
     stat = alterlist(ops_job_rec->qual[ops_job_cnt].ops_job_params,param_cnt),ops_job_rec->qual[
     ops_job_cnt].ops_job_params[1].param_7 = cnvtint(co.param)
    OF 8:
     stat = alterlist(ops_job_rec->qual[ops_job_cnt].ops_job_params,param_cnt),ops_job_rec->qual[
     ops_job_cnt].ops_job_params[1].param_8 = cnvtint(co.param)
    OF 9:
     stat = alterlist(ops_job_rec->qual[ops_job_cnt].ops_job_params,param_cnt),ops_job_rec->qual[
     ops_job_cnt].ops_job_params[1].param_9 = cnvtint(co.param)
    OF 10:
     stat = alterlist(ops_job_rec->qual[ops_job_cnt].ops_job_params,param_cnt),ops_job_rec->qual[
     ops_job_cnt].ops_job_params[1].param_10 = cnvtint(co.param)
    OF 14:
     stat = alterlist(ops_job_rec->qual[ops_job_cnt].ops_job_params,param_cnt),ops_job_rec->qual[
     ops_job_cnt].ops_job_params[1].param_14 = cnvtint(co.param)
    OF 15:
     stat = alterlist(ops_job_rec->qual[ops_job_cnt].ops_job_params,param_cnt),ops_job_rec->qual[
     ops_job_cnt].ops_job_params[1].param_15 = cnvtint(co.param)
    OF 16:
     stat = alterlist(ops_job_rec->qual[ops_job_cnt].ops_job_params,param_cnt),ops_job_rec->qual[
     ops_job_cnt].ops_job_params[1].param_16 = cnvtint(co.param)
    OF 17:
     stat = alterlist(ops_job_rec->qual[ops_job_cnt].ops_job_params,param_cnt),ops_job_rec->qual[
     ops_job_cnt].ops_job_params[1].param_17 = cnvtint(co.param)
   ENDCASE
  WITH nocounter
 ;end select
 SET x = 0
 SET do_nothing = 0
 SET size_jobs = 0
 SET size_params = 0
 SET size_jobs = size(ops_job_rec->qual,5)
 SET error_cnt = 0
 SET is_okay = 0
 FOR (x = 1 TO size_jobs)
  SET size_params = size(ops_job_rec->qual[x].ops_job_params,5)
  FOR (y = 1 TO size_params)
    IF ((ops_job_rec->qual[x].ops_job_params[y].param_1=99))
     SET error_cnt = (error_cnt+ 1)
     SET stat = alterlist(error_rec->error_qual,error_cnt)
     SET error_rec->error_qual[error_cnt].error_ops_id = ops_job_rec->qual[x].ops_job_id
     SET error_rec->error_qual[error_cnt].error_batch_name = ops_job_rec->qual[x].ops_batch_name
     SET error_rec->error_qual[error_cnt].error_level = 1
     SET error_rec->error_qual[error_cnt].error_msg = "Missing param #1 (Scope)"
    ENDIF
    IF ((ops_job_rec->qual[x].ops_job_params[y].param_2=99))
     SET error_cnt = (error_cnt+ 1)
     SET stat = alterlist(error_rec->error_qual,error_cnt)
     SET error_rec->error_qual[error_cnt].error_ops_id = ops_job_rec->qual[x].ops_job_id
     SET error_rec->error_qual[error_cnt].error_batch_name = ops_job_rec->qual[x].ops_batch_name
     SET error_rec->error_qual[error_cnt].error_level = 1
     SET error_rec->error_qual[error_cnt].error_msg = "Missing param #2 (Distribution ID)"
    ENDIF
    SELECT INTO "nl:"
     FROM chart_distribution cd
     WHERE cd.distribution_id=cnvtreal(ops_job_rec->qual[x].ops_job_params[y].param_2)
     HEAD REPORT
      is_okay = 1
     WITH nocounter
    ;end select
    IF (is_okay != 1)
     SET error_cnt = (error_cnt+ 1)
     SET stat = alterlist(error_rec->error_qual,error_cnt)
     SET error_rec->error_qual[error_cnt].error_ops_id = ops_job_rec->qual[x].ops_job_id
     SET error_rec->error_qual[error_cnt].error_batch_name = ops_job_rec->qual[x].ops_batch_name
     SET error_rec->error_qual[error_cnt].error_level = 1
     SET error_rec->error_qual[error_cnt].error_msg = "Invalid Distribution Id"
    ENDIF
    SET is_okay = 0
    IF ((ops_job_rec->qual[x].ops_job_params[y].param_3=99))
     SET error_cnt = (error_cnt+ 1)
     SET stat = alterlist(error_rec->error_qual,error_cnt)
     SET error_rec->error_qual[error_cnt].error_ops_id = ops_job_rec->qual[x].ops_job_id
     SET error_rec->error_qual[error_cnt].error_batch_name = ops_job_rec->qual[x].ops_batch_name
     SET error_rec->error_qual[error_cnt].error_level = 1
     SET error_rec->error_qual[error_cnt].error_msg = "Missing param #3 (Run Type)"
    ENDIF
    SELECT INTO "nl:"
     FROM code_value cv
     WHERE cv.code_value=cnvtreal(ops_job_rec->qual[x].ops_job_params[y].param_3)
      AND cv.active_ind=1
      AND cv.code_set=22550
     HEAD REPORT
      is_okay = 1
     WITH nocounter
    ;end select
    IF (is_okay != 1)
     SET error_cnt = (error_cnt+ 1)
     SET stat = alterlist(error_rec->error_qual,error_cnt)
     SET error_rec->error_qual[error_cnt].error_ops_id = ops_job_rec->qual[x].ops_job_id
     SET error_rec->error_qual[error_cnt].error_batch_name = ops_job_rec->qual[x].ops_batch_name
     SET error_rec->error_qual[error_cnt].error_level = 1
     SET error_rec->error_qual[error_cnt].error_msg = "Invalid Run-Type"
    ENDIF
    SET is_okay = 0
    IF ((ops_job_rec->qual[x].ops_job_params[y].param_4=99))
     SET error_cnt = (error_cnt+ 1)
     SET stat = alterlist(error_rec->error_qual,error_cnt)
     SET error_rec->error_qual[error_cnt].error_ops_id = ops_job_rec->qual[x].ops_job_id
     SET error_rec->error_qual[error_cnt].error_batch_name = ops_job_rec->qual[x].ops_batch_name
     SET error_rec->error_qual[error_cnt].error_level = 1
     SET error_rec->error_qual[error_cnt].error_msg = "Missing param #4 (Chart Format)"
    ENDIF
    SELECT INTO "nl:"
     FROM chart_format cf
     WHERE cf.chart_format_id=cnvtreal(ops_job_rec->qual[x].ops_job_params[y].param_4)
      AND cf.active_ind=1
     HEAD REPORT
      is_okay = 1
     WITH nocounter
    ;end select
    IF (is_okay != 1)
     SET error_cnt = (error_cnt+ 1)
     SET stat = alterlist(error_rec->error_qual,error_cnt)
     SET error_rec->error_qual[error_cnt].error_ops_id = ops_job_rec->qual[x].ops_job_id
     SET error_rec->error_qual[error_cnt].error_batch_name = ops_job_rec->qual[x].ops_batch_name
     SET error_rec->error_qual[error_cnt].error_level = 1
     SET error_rec->error_qual[error_cnt].error_msg = "Invalid Chart Format"
    ENDIF
    SET is_okay = 0
    IF ((ops_job_rec->qual[x].ops_job_params[y].param_6=99))
     SET error_cnt = (error_cnt+ 1)
     SET stat = alterlist(error_rec->error_qual,error_cnt)
     SET error_rec->error_qual[error_cnt].error_ops_id = ops_job_rec->qual[x].ops_job_id
     SET error_rec->error_qual[error_cnt].error_batch_name = ops_job_rec->qual[x].ops_batch_name
     SET error_rec->error_qual[error_cnt].error_level = 3
     SET error_rec->error_qual[error_cnt].error_msg =
     "Missing param #6 (Providers) - Will default to Admitting Physician"
    ENDIF
    SET is_okay = 0
    IF ((ops_job_rec->qual[x].ops_job_params[y].param_7=99))
     SET error_cnt = (error_cnt+ 1)
     SET stat = alterlist(error_rec->error_qual,error_cnt)
     SET error_rec->error_qual[error_cnt].error_ops_id = ops_job_rec->qual[x].ops_job_id
     SET error_rec->error_qual[error_cnt].error_batch_name = ops_job_rec->qual[x].ops_batch_name
     SET error_rec->error_qual[error_cnt].error_level = 1
     SET error_rec->error_qual[error_cnt].error_msg = "Missing param #7 (Print Finals)"
    ENDIF
    IF ( NOT ((ops_job_rec->qual[x].ops_job_params[y].param_7 IN (0, 1, 2))))
     SET error_cnt = (error_cnt+ 1)
     SET stat = alterlist(error_rec->error_qual,error_cnt)
     SET error_rec->error_qual[error_cnt].error_ops_id = ops_job_rec->qual[x].ops_job_id
     SET error_rec->error_qual[error_cnt].error_batch_name = ops_job_rec->qual[x].ops_batch_name
     SET error_rec->error_qual[error_cnt].error_level = 1
     SET error_rec->error_qual[error_cnt].error_msg =
     "Invalid param #7 (Print Finals) - must be 0, 1, or 2"
    ENDIF
    SET is_okay = 0
    IF ((ops_job_rec->qual[x].ops_job_params[y].param_8=99))
     SET error_cnt = (error_cnt+ 1)
     SET stat = alterlist(error_rec->error_qual,error_cnt)
     SET error_rec->error_qual[error_cnt].error_ops_id = ops_job_rec->qual[x].ops_job_id
     SET error_rec->error_qual[error_cnt].error_batch_name = ops_job_rec->qual[x].ops_batch_name
     SET error_rec->error_qual[error_cnt].error_level = 1
     SET error_rec->error_qual[error_cnt].error_msg = "Missing param #8 (MCIS)"
    ENDIF
    IF ( NOT ((ops_job_rec->qual[x].ops_job_params[y].param_8 IN (0))))
     SET error_cnt = (error_cnt+ 1)
     SET stat = alterlist(error_rec->error_qual,error_cnt)
     SET error_rec->error_qual[error_cnt].error_ops_id = ops_job_rec->qual[x].ops_job_id
     SET error_rec->error_qual[error_cnt].error_batch_name = ops_job_rec->qual[x].ops_batch_name
     SET error_rec->error_qual[error_cnt].error_level = 2
     SET error_rec->error_qual[error_cnt].error_msg = "Invalid param #8 (MCIS) - must be 0"
    ENDIF
    SET is_okay = 0
    IF ((ops_job_rec->qual[x].ops_job_params[y].param_9=99))
     SET error_cnt = (error_cnt+ 1)
     SET stat = alterlist(error_rec->error_qual,error_cnt)
     SET error_rec->error_qual[error_cnt].error_ops_id = ops_job_rec->qual[x].ops_job_id
     SET error_rec->error_qual[error_cnt].error_batch_name = ops_job_rec->qual[x].ops_batch_name
     SET error_rec->error_qual[error_cnt].error_level = 1
     SET error_rec->error_qual[error_cnt].error_msg = "Missing param #9 (Routing Selection)"
    ENDIF
    IF ( NOT ((ops_job_rec->qual[x].ops_job_params[y].param_9 IN (0, 1, 2, 3, 4,
    5))))
     SET error_cnt = (error_cnt+ 1)
     SET stat = alterlist(error_rec->error_qual,error_cnt)
     SET error_rec->error_qual[error_cnt].error_ops_id = ops_job_rec->qual[x].ops_job_id
     SET error_rec->error_qual[error_cnt].error_batch_name = ops_job_rec->qual[x].ops_batch_name
     SET error_rec->error_qual[error_cnt].error_level = 1
     SET error_rec->error_qual[error_cnt].error_msg =
     "Invalid param #9 (Routing Selection) - must be 0, 1, 2, 3, 4, or 5"
    ENDIF
    SET is_okay = 0
    IF ((ops_job_rec->qual[x].ops_job_params[y].param_9 IN (3, 4)))
     IF ((ops_job_rec->qual[x].ops_job_params[y].param_1 != 4))
      SET error_cnt = (error_cnt+ 1)
      SET stat = alterlist(error_rec->error_qual,error_cnt)
      SET error_rec->error_qual[error_cnt].error_ops_id = ops_job_rec->qual[x].ops_job_id
      SET error_rec->error_qual[error_cnt].error_batch_name = ops_job_rec->qual[x].ops_batch_name
      SET error_rec->error_qual[error_cnt].error_level = 2
      SET error_rec->error_qual[error_cnt].error_msg =
      "Scope must be Accession for routing selection"
     ENDIF
    ENDIF
    SET is_okay = 0
    IF ((ops_job_rec->qual[x].ops_job_params[y].param_10=99))
     SET error_cnt = (error_cnt+ 1)
     SET stat = alterlist(error_rec->error_qual,error_cnt)
     SET error_rec->error_qual[error_cnt].error_ops_id = ops_job_rec->qual[x].ops_job_id
     SET error_rec->error_qual[error_cnt].error_batch_name = ops_job_rec->qual[x].ops_batch_name
     SET error_rec->error_qual[error_cnt].error_level = 1
     SET error_rec->error_qual[error_cnt].error_msg = "Missing param #10 (Printer)"
    ENDIF
    SELECT INTO "nl:"
     FROM output_dest od
     WHERE od.output_dest_cd=cnvtreal(ops_job_rec->qual[x].ops_job_params[y].param_10)
     HEAD REPORT
      is_okay = 1
     WITH nocounter
    ;end select
    IF (is_okay != 1)
     SET error_cnt = (error_cnt+ 1)
     SET stat = alterlist(error_rec->error_qual,error_cnt)
     SET error_rec->error_qual[error_cnt].error_ops_id = ops_job_rec->qual[x].ops_job_id
     SET error_rec->error_qual[error_cnt].error_batch_name = ops_job_rec->qual[x].ops_batch_name
     SET error_rec->error_qual[error_cnt].error_level = 2
     SET error_rec->error_qual[error_cnt].error_msg = "Invalid param #10 (Printer)"
    ENDIF
    SET is_okay = 0
    IF ((ops_job_rec->qual[x].ops_job_params[y].param_14=99))
     SET error_cnt = (error_cnt+ 1)
     SET stat = alterlist(error_rec->error_qual,error_cnt)
     SET error_rec->error_qual[error_cnt].error_ops_id = ops_job_rec->qual[x].ops_job_id
     SET error_rec->error_qual[error_cnt].error_batch_name = ops_job_rec->qual[x].ops_batch_name
     SET error_rec->error_qual[error_cnt].error_level = 1
     SET error_rec->error_qual[error_cnt].error_msg = "Missing param #14 (File-Storage)"
    ENDIF
    SELECT INTO "nl:"
     FROM code_value cv
     WHERE cv.code_value=cnvtreal(ops_job_rec->qual[x].ops_job_params[y].param_14)
      AND cv.active_ind=1
      AND cv.code_set=22549
     HEAD REPORT
      is_okay = 1
     WITH nocounter
    ;end select
    IF (is_okay != 1)
     SET error_cnt = (error_cnt+ 1)
     SET stat = alterlist(error_rec->error_qual,error_cnt)
     SET error_rec->error_qual[error_cnt].error_ops_id = ops_job_rec->qual[x].ops_job_id
     SET error_rec->error_qual[error_cnt].error_batch_name = ops_job_rec->qual[x].ops_batch_name
     SET error_rec->error_qual[error_cnt].error_level = 1
     SET error_rec->error_qual[error_cnt].error_msg = "Invalid param #14 (File-Storage)"
    ENDIF
    SET is_okay = 0
    IF ((ops_job_rec->qual[x].ops_job_params[y].param_15=99))
     SET error_cnt = (error_cnt+ 1)
     SET stat = alterlist(error_rec->error_qual,error_cnt)
     SET error_rec->error_qual[error_cnt].error_ops_id = ops_job_rec->qual[x].ops_job_id
     SET error_rec->error_qual[error_cnt].error_batch_name = ops_job_rec->qual[x].ops_batch_name
     SET error_rec->error_qual[error_cnt].error_level = 2
     SET error_rec->error_qual[error_cnt].error_msg = "Missing param #15 (Sort-sequence)"
    ENDIF
    SELECT INTO "nl:"
     FROM code_value cv
     WHERE cv.code_value=cnvtreal(ops_job_rec->qual[x].ops_job_params[y].param_15)
      AND cv.active_ind=1
      AND cv.code_set=22011
     HEAD REPORT
      is_okay = 1
     WITH nocounter
    ;end select
    IF (is_okay != 1)
     SET error_cnt = (error_cnt+ 1)
     SET stat = alterlist(error_rec->error_qual,error_cnt)
     SET error_rec->error_qual[error_cnt].error_ops_id = ops_job_rec->qual[x].ops_job_id
     SET error_rec->error_qual[error_cnt].error_batch_name = ops_job_rec->qual[x].ops_batch_name
     SET error_rec->error_qual[error_cnt].error_level = 2
     SET error_rec->error_qual[error_cnt].error_msg = "Invalid param #15 (Sort-sequence)"
    ENDIF
    SET is_okay = 0
    IF ((ops_job_rec->qual[x].ops_job_params[y].param_16=99))
     SET error_cnt = (error_cnt+ 1)
     SET stat = alterlist(error_rec->error_qual,error_cnt)
     SET error_rec->error_qual[error_cnt].error_ops_id = ops_job_rec->qual[x].ops_job_id
     SET error_rec->error_qual[error_cnt].error_batch_name = ops_job_rec->qual[x].ops_batch_name
     SET error_rec->error_qual[error_cnt].error_level = 1
     SET error_rec->error_qual[error_cnt].error_msg = "Missing param #16 (Default Chart)"
    ENDIF
    SET is_okay = 0
    IF ((ops_job_rec->qual[x].ops_job_params[y].param_17=99))
     SET error_cnt = (error_cnt+ 1)
     SET stat = alterlist(error_rec->error_qual,error_cnt)
     SET error_rec->error_qual[error_cnt].error_ops_id = ops_job_rec->qual[x].ops_job_id
     SET error_rec->error_qual[error_cnt].error_batch_name = ops_job_rec->qual[x].ops_batch_name
     SET error_rec->error_qual[error_cnt].error_level = 1
     SET error_rec->error_qual[error_cnt].error_msg = "Missing param #17 (File-Storage Location)"
    ENDIF
  ENDFOR
 ENDFOR
 SET size_errors = 0
 SET size_errors = size(error_rec->error_qual,5)
 SELECT
  co.charting_operations_id
  FROM charting_operations co
  HEAD REPORT
   row + 2, col 25, "CHARTING_OPERATIONS TABLE - VALIDATION SUMMARY",
   row + 2
  DETAIL
   do_nothing = 0
  FOOT REPORT
   col 1, "Error Level", col 16,
   "Id", col 31, "Batch Name",
   col 63, "Error Message", row + 1,
   col 1, "-----------", col 16,
   "-----------", col 31, "------------------------------",
   col 63, "--------------------------------------------------------------", row + 1
   FOR (x = 1 TO size_errors)
     CASE (error_rec->error_qual[x].error_level)
      OF 1:
       col 1,"ERROR"
      OF 2:
       col 1,"WARNING"
      OF 3:
       col 1,"INFO"
     ENDCASE
     col 9, error_rec->error_qual[x].error_ops_id, col 31,
     error_rec->error_qual[x].error_batch_name, col 63, error_rec->error_qual[x].error_msg,
     row + 1
   ENDFOR
  WITH nocounter
 ;end select
#end_validate_co_table
#begin_activity_encntr
 EXECUTE FROM initialize TO end_initialize
 CALL clear(1,1)
 CALL box(2,1,23,110)
 CALL text(3,22,"*** SEARCH FOR ACTIVITY ON ENCNTR ***")
 CALL text(5,4,"Choose an Encntr_Id: ")
 CALL accept(5,35,"P(40);Cf"," ")
 SET encntr_id_chosen = cnvtreal(curaccept)
 SET pending_flag = 0
 CALL text(7,4,"Choose a last_dist_run_dt_tm: ")
 CALL text(8,35,"Ex:  01-jan-2000")
 CALL accept(7,35,"P(40);Cf"," ")
 SET last_dist_run_dt_tm_string = curaccept
 SET last_dist_run_dt_tm = cnvtdatetime(curaccept)
 SELECT DISTINCT INTO "nl:"
  ce.encntr_id
  FROM clinical_event ce
  WHERE ce.clinsig_updt_dt_tm >= cnvtdatetime(last_dist_run_dt_tm)
  HEAD REPORT
   cp_encntr_cnt = 0
  DETAIL
   cp_encntr_cnt = (cp_encntr_cnt+ 1)
   IF (mod(cp_encntr_cnt,100)=1)
    stat = alterlist(cp_encntr->encntr_list,(cp_encntr_cnt+ 99))
   ENDIF
   cp_encntr->encntr_list[cp_encntr_cnt].encntr_id = ce.encntr_id
  WITH nocounter
 ;end select
 SET size_returned = size(cp_encntr->encntr_list,5)
 IF (size_returned > 0)
  FOR (x = 1 TO size_returned)
    IF ((cp_encntr->encntr_list[x].encntr_id=encntr_id_chosen)
     AND get_out=0)
     SET is_okay = 1
     SET get_out = 1
    ENDIF
  ENDFOR
  IF (is_okay=0)
   SET is_okay = 3
  ENDIF
 ELSE
  SET is_okay = 2
 ENDIF
 SELECT INTO "mine"
  FROM dual
  HEAD REPORT
   row + 1, col 20, "Search Results",
   row + 1, col 4, "Encntr_id:",
   col 25, encntr_id_chosen, row + 1,
   col 4, "Last Dist Run DT/TM:", col 25,
   last_dist_run_dt_tm_string, row + 3
  DETAIL
   do_nothing = 0
  FOOT REPORT
   row + 1, col 4, "Match on CE Activity ?"
   IF (is_okay=1)
    col 40, "YES"
   ELSEIF (is_okay=2)
    col 40, "NO", col 55,
    "No encounters found"
   ELSEIF (is_okay=3)
    col 40, "NO", col 55,
    "Encounters found, but no match"
   ENDIF
  WITH nocounter
 ;end select
#end_activity_encntr
#begin_exec_time
 EXECUTE FROM initialize TO end_initialize
 CALL clear(1,1)
 CALL box(2,1,23,110)
 CALL text(3,22,"*** EXECUTION TIMES FOR CP_PROCESS_DIST ***")
 CALL text(5,4,"Enter a Distribution_Id -OR- '0' for All")
 CALL accept(7,4,"P(40);Cf"," ")
 SET distribution_id_chosen = cnvtreal(curaccept)
 IF (distribution_id_chosen > 0)
  SELECT INTO "mine"
   cdl.message_text, cdl.distribution_id, exec_time = substring(24,3,cdl.message_text),
   distr_id = cdl.distribution_id, run_date = format(cdl.dist_run_dt_tm,"mm/dd/yyyy hh:mm:ss;;d"),
   run_type = uar_get_code_meaning(cdl.dist_run_type_cd)
   FROM chart_dist_log cdl
   WHERE cdl.distribution_id=distribution_id_chosen
    AND cdl.message_text="Total Execution Time =*"
   ORDER BY cdl.dist_run_dt_tm DESC
   HEAD REPORT
    row + 1, col 10, "DISTRIBUTION RUN-TIME SUMMARY",
    row + 2, col 10, "Distribution_Id:",
    col 30, distribution_id_chosen, row + 2,
    col 2, "Distribution_Id", col 20,
    "Execution Time", col 40, "Run Date",
    col 70, "Run Type", row + 1,
    col 2, "---------------", col 20,
    "--------------", col 40, "----------------",
    col 70, "--------"
   DETAIL
    row + 1, col 2, distr_id,
    col 20, exec_time, col 28,
    "MINUTES", col 40, run_date,
    col 70, run_type
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "mine"
   cdl.message_text, cdl.distribution_id, exec_time = substring(24,3,cdl.message_text),
   distr_id = cdl.distribution_id, run_date = format(cdl.dist_run_dt_tm,"mm/dd/yyyy hh:mm:ss;;d"),
   run_type = uar_get_code_meaning(cdl.dist_run_type_cd)
   FROM chart_dist_log cdl
   WHERE cdl.message_text="Total Execution Time =*"
   ORDER BY cdl.dist_run_dt_tm DESC
   HEAD REPORT
    row + 1, col 10, "DISTRIBUTION RUN-TIME SUMMARY",
    row + 2, col 10, "ALL DISTRIBUTIONS",
    row + 2, col 2, "Distribution_Id",
    col 20, "Execution Time", col 40,
    "Run Date", col 70, "Run Type",
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
#end_exec_time
#begin_chk_chart_format
 SET chart_format_chosen = fillstring(80," ")
 EXECUTE FROM initialize TO end_initialize
 CALL clear(1,1)
 CALL box(2,1,23,110)
 CALL text(3,22,"*** CHECK ENCOUNTER ACTIVITY W/ CHART_FORMAT ***")
 CALL text(5,4,"Enter an Encntr_Id")
 CALL accept(7,4,"P(40);Cf"," ")
 SET encntr_id_chosen = cnvtreal(curaccept)
 CALL text(9,4,"Choose a Chart Format: ")
 CALL text(11,4,"Shift/F5 to see a list of Chart Formats.")
 SET help =
 SELECT DISTINCT INTO "nl:"
  cf.chart_format_desc
  FROM chart_format cf
  WHERE cf.active_ind=1
  ORDER BY cf.chart_format_desc
  WITH nocounter
 ;end select
 CALL accept(12,4,"P(64);C")
 SET help = off
 SET chart_format_chosen = trim(curaccept)
 SET chart_format_id_chosen = 0.0
 SELECT INTO "nl:"
  cf.chart_format_id
  FROM chart_format cf
  WHERE cf.chart_format_desc=chart_format_chosen
  HEAD REPORT
   do_nothing = 0
  DETAIL
   chart_format_id_chosen = cf.chart_format_id
  WITH nocounter
 ;end select
 SET chart_format = fillstring(100," ")
 DECLARE dta_chart_format_id = f8 WITH noconstant(chart_format_id_chosen)
 DECLARE dta_chart_section_id = f8 WITH noconstant(0.0)
 DECLARE dta_get_ap_history = i2 WITH noconstant(0)
 DECLARE dta_check_ap_flag = i2 WITH noconstant(0)
 FREE RECORD dta_specific_event_cds
 RECORD dta_specific_event_cds(
   1 qual[*]
     2 event_cd = f8
 )
 FREE RECORD activity_rec
 RECORD activity_rec(
   1 activity[*]
     2 chart_section_id = f8
     2 section_seq = i4
     2 section_type_flag = i2
     2 chart_group_id = f8
     2 group_seq = i4
     2 zone = i4
     2 flex_type_flag = i2
     2 doc_type_flag = i2
     2 procedure_seq = i4
     2 procedure_type_flag = i2
     2 event_set_name = vc
     2 dcp_forms_ref_id = f8
     2 catalog_cd = f8
     2 event_cds[*]
       3 event_cd = f8
       3 task_assay_cd = f8
       3 suppressed_ind = i2
   1 parent_event_ids[*]
     2 parent_event_id = f8
   1 inerr_events[*]
     2 event_id = f8
 )
 DECLARE parser_clause = vc WITH private
 DECLARE hit_bbxm_section = i2 WITH noconstant(0)
 DECLARE added_ec_for_es_bbxm_section = i2 WITH noconstant(0)
 DECLARE bbproduct = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"BBPRODUCT")), protect
 IF (dta_chart_section_id > 0)
  SET parser_clause = build("cfs.chart_format_id = ",dta_chart_format_id,
   " and cfs.chart_section_id = ",dta_chart_section_id)
 ELSE
  SET parser_clause = build("cfs.chart_format_id = ",dta_chart_format_id)
 ENDIF
 IF (dta_get_ap_history=0)
  IF (size(dta_specific_event_cds->qual,5)=0)
   SELECT DISTINCT INTO "nl:"
    check = decode(esc.seq,"esc",cver.seq,"orc")
    FROM chart_form_sects cfs,
     chart_section cs,
     chart_group cg,
     chart_ap_format caf,
     chart_flex_format cff,
     chart_grp_evnt_set cges,
     v500_event_set_code esc,
     v500_event_set_explode ese,
     profile_task_r ptr,
     code_value_event_r cver,
     chart_grp_evnt_suppress cgess,
     chart_doc_format cdf,
     dummyt d1,
     dummyt d2
    PLAN (cfs
     WHERE parser(parser_clause))
     JOIN (cs
     WHERE cs.chart_section_id=cfs.chart_section_id)
     JOIN (cg
     WHERE cg.chart_section_id=cs.chart_section_id)
     JOIN (caf
     WHERE caf.chart_group_id=outerjoin(cg.chart_group_id))
     JOIN (cff
     WHERE cff.chart_group_id=outerjoin(cg.chart_group_id))
     JOIN (cges
     WHERE cges.chart_group_id=cg.chart_group_id)
     JOIN (cdf
     WHERE cdf.chart_group_id=outerjoin(cg.chart_group_id))
     JOIN (d1)
     JOIN (((esc
     WHERE cges.procedure_type_flag=0
      AND esc.event_set_name=cges.event_set_name)
     JOIN (ese
     WHERE ese.event_set_cd=esc.event_set_cd)
     ) ORJOIN ((d2)
     JOIN (ptr
     WHERE cges.procedure_type_flag=1
      AND ptr.catalog_cd=cges.order_catalog_cd
      AND ptr.catalog_cd > 0)
     JOIN (cgess
     WHERE cgess.chart_group_id=outerjoin(cges.chart_group_id)
      AND cgess.order_catalog_cd=outerjoin(ptr.catalog_cd)
      AND cgess.task_assay_cd=outerjoin(ptr.task_assay_cd))
     JOIN (cver
     WHERE ((cver.parent_cd=ptr.task_assay_cd) OR (cver.parent_cd=ptr.catalog_cd))
      AND cver.parent_cd > 0)
     ))
    ORDER BY cfs.cs_sequence_num, cg.cg_sequence, cges.zone,
     cges.event_set_seq, ese.event_cd, cver.event_cd
    HEAD REPORT
     activitycnt = 0, codecnt = 0
    HEAD cfs.cs_sequence_num
     IF (cs.section_type_flag=6
      AND cff.flex_type=0)
      hit_bbxm_section = 1, added_ec_for_es_bbxm_section = 0
     ENDIF
    HEAD cg.cg_sequence
     do_nothing = 0
    HEAD cges.zone
     do_nothing = 0
    HEAD cges.event_set_seq
     IF (((dta_check_ap_flag=1
      AND caf.ap_history_flag=0) OR (dta_check_ap_flag=0)) )
      activitycnt = (activitycnt+ 1)
      IF (mod(activitycnt,10)=1)
       stat = alterlist(activity_rec->activity[activitycnt],(activitycnt+ 9))
      ENDIF
      activity_rec->activity[activitycnt].chart_section_id = cfs.chart_section_id, activity_rec->
      activity[activitycnt].section_seq = cfs.cs_sequence_num, activity_rec->activity[activitycnt].
      section_type_flag = cs.section_type_flag,
      activity_rec->activity[activitycnt].chart_group_id = cg.chart_group_id, activity_rec->activity[
      activitycnt].group_seq = cg.cg_sequence, activity_rec->activity[activitycnt].zone = cges.zone,
      activity_rec->activity[activitycnt].procedure_seq = cges.event_set_seq, activity_rec->activity[
      activitycnt].procedure_type_flag = cges.procedure_type_flag, activity_rec->activity[activitycnt
      ].event_set_name = cges.event_set_name,
      activity_rec->activity[activitycnt].catalog_cd = cges.order_catalog_cd, activity_rec->activity[
      activitycnt].flex_type_flag = cff.flex_type, activity_rec->activity[activitycnt].doc_type_flag
       = cdf.doc_type_flag
     ENDIF
    DETAIL
     IF (((dta_check_ap_flag=1
      AND caf.ap_history_flag=0) OR (dta_check_ap_flag=0)) )
      IF (cgess.task_assay_cd=0
       AND cgess.event_cd=0)
       codecnt = (codecnt+ 1)
       IF (mod(codecnt,10)=1)
        stat = alterlist(activity_rec->activity[activitycnt].event_cds,(codecnt+ 9))
       ENDIF
       IF (check="esc")
        IF (hit_bbxm_section=0)
         activity_rec->activity[activitycnt].event_cds[codecnt].event_cd = ese.event_cd
        ELSE
         IF (added_ec_for_es_bbxm_section=0)
          activity_rec->activity[activitycnt].event_cds[codecnt].event_cd = bbproduct,
          added_ec_for_es_bbxm_section = 1
         ENDIF
        ENDIF
       ELSE
        IF (hit_bbxm_section=0)
         activity_rec->activity[activitycnt].event_cds[codecnt].event_cd = cver.event_cd
        ELSE
         activity_rec->activity[activitycnt].event_cds[codecnt].event_cd = bbproduct
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    FOOT  cges.event_set_seq
     IF (((dta_check_ap_flag=1
      AND caf.ap_history_flag=0) OR (dta_check_ap_flag=0)) )
      stat = alterlist(activity_rec->activity[activitycnt].event_cds,codecnt), codecnt = 0
     ENDIF
    FOOT  cges.zone
     do_nothing = 0
    FOOT  cg.cg_sequence
     do_nothing = 0
    FOOT  cfs.cs_sequence_num
     hit_bbxm_section = 0
    FOOT REPORT
     stat = alterlist(activity_rec->activity,activitycnt)
    WITH nocounter
   ;end select
  ELSE
   SELECT DISTINCT INTO "nl:"
    FROM chart_form_sects cfs,
     chart_section cs,
     chart_group cg,
     chart_grp_evnt_set cges,
     v500_event_set_code esc,
     v500_event_set_explode ese,
     chart_doc_format cdf,
     (dummyt d  WITH seq = value(size(dta_specific_event_cds->qual,5)))
    PLAN (d)
     JOIN (ese
     WHERE (ese.event_cd=dta_specific_event_cds->qual[d.seq].event_cd))
     JOIN (esc
     WHERE esc.event_set_cd=ese.event_set_cd)
     JOIN (cges
     WHERE cges.event_set_name=esc.event_set_name
      AND cges.procedure_type_flag=0)
     JOIN (cg
     WHERE cg.chart_group_id=cges.chart_group_id)
     JOIN (cdf
     WHERE cdf.chart_group_id=cges.chart_group_id)
     JOIN (cfs
     WHERE parser(parser_clause)
      AND cfs.chart_section_id=cg.chart_section_id)
     JOIN (cs
     WHERE cs.chart_section_id=cfs.chart_section_id)
    ORDER BY cfs.cs_sequence_num, cg.cg_sequence, cges.zone,
     cges.event_set_seq, ese.event_cd
    HEAD REPORT
     activitycnt = 0, codecnt = 0
    HEAD cfs.cs_sequence_num
     do_nothing = 0
    HEAD cg.cg_sequence
     do_nothing = 0
    HEAD cges.zone
     do_nothing = 0
    HEAD cges.event_set_seq
     activitycnt = (activitycnt+ 1)
     IF (mod(activitycnt,5)=1)
      stat = alterlist(activity_rec->activity[activitycnt],(activitycnt+ 4))
     ENDIF
     activity_rec->activity[activitycnt].chart_section_id = cfs.chart_section_id, activity_rec->
     activity[activitycnt].section_seq = cfs.cs_sequence_num, activity_rec->activity[activitycnt].
     section_type_flag = cs.section_type_flag,
     activity_rec->activity[activitycnt].chart_group_id = cg.chart_group_id, activity_rec->activity[
     activitycnt].group_seq = cg.cg_sequence, activity_rec->activity[activitycnt].zone = cges.zone,
     activity_rec->activity[activitycnt].procedure_seq = cges.event_set_seq, activity_rec->activity[
     activitycnt].procedure_type_flag = cges.procedure_type_flag, activity_rec->activity[activitycnt]
     .event_set_name = cges.event_set_name,
     activity_rec->activity[activitycnt].catalog_cd = cges.order_catalog_cd, activity_rec->activity[
     activitycnt].flex_type_flag = 0, activity_rec->activity[activitycnt].doc_type_flag = cdf
     .doc_type_flag
    DETAIL
     codecnt = (codecnt+ 1)
     IF (mod(codecnt,5)=1)
      stat = alterlist(activity_rec->activity[activitycnt].event_cds,(codecnt+ 4))
     ENDIF
     activity_rec->activity[activitycnt].event_cds[codecnt].event_cd = ese.event_cd
    FOOT  cges.event_set_seq
     stat = alterlist(activity_rec->activity[activitycnt].event_cds,codecnt), codecnt = 0
    FOOT  cges.zone
     do_nothing = 0
    FOOT  cg.cg_sequence
     do_nothing = 0
    FOOT  cfs.cs_sequence_num
     do_nothing = 0
    FOOT REPORT
     stat = alterlist(activity_rec->activity,activitycnt)
    WITH nocounter
   ;end select
  ENDIF
 ELSE
  SELECT DISTINCT INTO "nl:"
   check = decode(esc.seq,"esc",ptr.seq,"orc")
   FROM chart_format cf,
    chart_section cs,
    chart_form_sects cfs,
    chart_group cg,
    chart_ap_format caf,
    chart_grp_evnt_set cges,
    v500_event_set_code esc,
    v500_event_set_explode ese,
    profile_task_r ptr,
    code_value_event_r cver,
    dummyt d1,
    dummyt d2
   PLAN (cf
    WHERE cf.chart_format_id=dta_chart_format_id)
    JOIN (cs
    WHERE cs.section_type_flag=18)
    JOIN (cfs
    WHERE cfs.chart_format_id=cf.chart_format_id
     AND cfs.chart_section_id=cs.chart_section_id)
    JOIN (cg
    WHERE cg.chart_section_id=cfs.chart_section_id)
    JOIN (caf
    WHERE caf.chart_group_id=cg.chart_group_id
     AND caf.ap_history_flag=1)
    JOIN (cges
    WHERE cges.chart_group_id=cg.chart_group_id)
    JOIN (d1)
    JOIN (((esc
    WHERE cges.procedure_type_flag=0
     AND esc.event_set_name=cges.event_set_name)
    JOIN (ese
    WHERE ese.event_set_cd=esc.event_set_cd)
    ) ORJOIN ((d2)
    JOIN (ptr
    WHERE cges.procedure_type_flag=1
     AND ptr.catalog_cd=cges.order_catalog_cd
     AND ptr.catalog_cd > 0)
    JOIN (cver
    WHERE ((cver.parent_cd=ptr.task_assay_cd) OR (cver.parent_cd=ptr.catalog_cd))
     AND cver.parent_cd > 0)
    ))
   ORDER BY cfs.cs_sequence_num, cg.cg_sequence, cges.zone,
    cges.event_set_seq, ese.event_cd, cver.event_cd
   HEAD REPORT
    activitycnt = 0, codecnt = 0
   HEAD cfs.cs_sequence_num
    do_nothing = 0
   HEAD cg.cg_sequence
    do_nothing = 0
   HEAD cges.zone
    do_nothing = 0
   HEAD cges.event_set_seq
    activitycnt = (activitycnt+ 1)
    IF (mod(activitycnt,10)=1)
     stat = alterlist(activity_rec->activity[activitycnt],(activitycnt+ 9))
    ENDIF
    activity_rec->activity[activitycnt].chart_section_id = cfs.chart_section_id, activity_rec->
    activity[activitycnt].section_seq = cfs.cs_sequence_num, activity_rec->activity[activitycnt].
    section_type_flag = 18,
    activity_rec->activity[activitycnt].chart_group_id = cg.chart_group_id, activity_rec->activity[
    activitycnt].group_seq = cg.cg_sequence, activity_rec->activity[activitycnt].zone = cges.zone,
    activity_rec->activity[activitycnt].procedure_seq = cges.event_set_seq, activity_rec->activity[
    activitycnt].procedure_type_flag = cges.procedure_type_flag, activity_rec->activity[activitycnt].
    event_set_name = cges.event_set_name,
    activity_rec->activity[activitycnt].catalog_cd = cges.order_catalog_cd
   DETAIL
    codecnt = (codecnt+ 1)
    IF (mod(codecnt,10)=1)
     stat = alterlist(activity_rec->activity[activitycnt].event_cds,(codecnt+ 9))
    ENDIF
    IF (check="esc")
     activity_rec->activity[activitycnt].event_cds[codecnt].event_cd = ese.event_cd
    ELSE
     activity_rec->activity[activitycnt].event_cds[codecnt].event_cd = cver.event_cd
    ENDIF
   FOOT  cges.event_set_seq
    stat = alterlist(activity_rec->activity[activitycnt].event_cds,codecnt), codecnt = 0
   FOOT  cges.zone
    do_nothing = 0
   FOOT  cg.cg_sequence
    do_nothing = 0
   FOOT  cfs.cs_sequence_num
    do_nothing = 0
   FOOT REPORT
    stat = alterlist(activity_rec->activity,activitycnt)
   WITH nocounter
  ;end select
 ENDIF
 SELECT DISTINCT INTO "mine"
  chart_format = cf.chart_format_desc, check = activity_rec->activity[d2.seq].event_cds[d3.seq].
  event_cd
  FROM clinical_event ce,
   encounter e,
   chart_format cf,
   (dummyt d1  WITH seq = 1),
   (dummyt d2  WITH seq = value(size(activity_rec->activity,5))),
   (dummyt d3  WITH seq = 1)
  PLAN (e
   WHERE e.encntr_id=encntr_id_chosen)
   JOIN (ce
   WHERE ce.encntr_id=e.encntr_id
    AND ce.event_cd > 0
    AND ce.catalog_cd > 0)
   JOIN (cf
   WHERE cf.chart_format_id=chart_format_id_chosen)
   JOIN (d1)
   JOIN (d2
   WHERE maxrec(d3,size(activity_rec->activity[d2.seq].event_cds,5)))
   JOIN (d3
   WHERE (((activity_rec->activity[d2.seq].procedure_type_flag=0)
    AND (ce.event_cd=activity_rec->activity[d2.seq].event_cds[d3.seq].event_cd)) OR ((activity_rec->
   activity[d2.seq].procedure_type_flag=1)
    AND (ce.catalog_cd=activity_rec->activity[d2.seq].catalog_cd)
    AND (ce.event_cd=activity_rec->activity[d2.seq].event_cds[d3.seq].event_cd))) )
  ORDER BY ce.order_id, ce.event_cd, ce.catalog_cd
  HEAD REPORT
   cnt = 0, row + 2, col 20,
   "CHECK ACTIVITY W/ CHART_FORMAT", row + 2, col 2,
   "Chart_Format_Id: ", col 35, chart_format_id_chosen,
   row + 1, col 2, "Chart Format Descr: ",
   col 35, chart_format, row + 1,
   col 2, "Encntr_Id: ", col 35,
   encntr_id_chosen, row + 2, col 2,
   "CE - Order_id", col 20, "CE - Event_cd",
   col 40, "CE - Catalog_cd", col 65,
   "Match?", row + 1, col 2,
   "-------------", col 20, "-------------",
   col 40, "---------------", col 65,
   "------", row + 1
  DETAIL
   col 2, ce.order_id, col 20,
   ce.event_cd, col 40, ce.catalog_cd
   IF (check > 0)
    col 65, " + ", cnt = (cnt+ 1)
   ELSE
    col 65, " - "
   ENDIF
   row + 1
  FOOT REPORT
   row + 1, col 1, "************************"
   IF (cnt > 0)
    row + 1, col 2, "SUCCESSFUL"
   ELSE
    row + 1, col 2, "NO MATCH"
   ENDIF
   row + 1, col 1, "************************"
  WITH nocounter, outerjoin = d1
 ;end select
#end_chk_chart_format
#begin_get_clinical_event
 EXECUTE FROM initialize TO end_initialize
 SET encntr_id_chosen = 0.0
 SET person_id_chosen = 0.0
 SET order_id_chosen = 0.0
 SET accession_nbr_chosen = fillstring(20," ")
 CALL clear(1,1)
 CALL box(2,1,23,110)
 CALL text(3,22,"*** RETRIEVE CLINICAL EVENT ACTIVITY ***")
 CALL text(5,4,"Enter a Person_Id")
 CALL accept(7,4,"P(40);Cf"," ")
 SET person_id_chosen = cnvtreal(curaccept)
 CALL text(9,4,"Enter an Encntr_Id")
 CALL accept(11,4,"P(40);Cf"," ")
 SET encntr_id_chosen = cnvtreal(curaccept)
 CALL text(13,4,"Enter an Accession Nbr")
 CALL accept(15,4,"P(40);C"," ")
 SET accession_nbr_chosen = curaccept
 CALL text(17,4,"Enter an Order_Id")
 CALL accept(19,4,"P(40);Cf"," ")
 SET order_id_chosen = cnvtreal(curaccept)
 SET where_clause = fillstring(200," ")
 SET where_clause_cnt = 0
 IF (person_id_chosen > 0.0)
  SET where_clause_cnt = (where_clause_cnt+ 1)
  SET where_clause = "ce.person_id = person_id_chosen"
 ENDIF
 IF (encntr_id_chosen > 0.0)
  IF (where_clause_cnt > 0)
   SET where_clause = build(where_clause," and ce.encntr_id = encntr_id_chosen")
  ELSE
   SET where_clause_cnt = (where_clause_cnt+ 1)
   SET where_clause = "ce.encntr_id = encntr_id_chosen"
  ENDIF
 ENDIF
 IF (accession_nbr_chosen > " ")
  IF (where_clause_cnt > 0)
   SET where_clause = build(where_clause," and ce.accession_nbr = accession_nbr_chosen")
  ELSE
   SET where_clause_cnt = (where_clause_cnt+ 1)
   SET where_clause = "ce.accession_nbr = accession_nbr_chosen"
  ENDIF
 ENDIF
 IF (order_id_chosen > 0.0)
  IF (where_clause_cnt > 0)
   SET where_clause = build(where_clause," and ce.order_id = order_id_chosen")
  ELSE
   SET where_clause_cnt = (where_clause_cnt+ 1)
   SET where_clause = "ce.order_id = order_id_chosen"
  ENDIF
 ENDIF
 SELECT DISTINCT INTO "mine"
  person_id = ce.person_id, encntr_id = cnvtreal(ce.encntr_id), ce.accession_nbr,
  order_id = ce.order_id, clinsig_updt_dt_tm = format(ce.clinsig_updt_dt_tm,"mm/dd/yyyy hh:mm:ss;;d")
  FROM clinical_event ce
  WHERE parser(where_clause)
  ORDER BY ce.encntr_id, ce.accession_nbr, ce.order_id,
   ce.clinsig_updt_dt_tm
  HEAD REPORT
   row + 2, col 10, "* * * CLINICAL EVENT SUMMARY * * * ",
   row + 2
   IF (person_id_chosen > 0)
    col 2, "Person ID:", col 20,
    person_id_chosen, row + 1
   ENDIF
   IF (encntr_id_chosen > 0)
    col 2, "Encounter ID:", col 20,
    encntr_id_chosen, row + 1
   ENDIF
   IF (accession_nbr_chosen > "")
    col 2, "Accession Nbr:", col 20,
    accession_nbr_chosen, row + 1
   ENDIF
   IF (order_id_chosen > 0)
    col 2, "Order ID:", col 20,
    order_id_chosen, row + 1
   ENDIF
   row + 2, col 1, "Person Id",
   col 16, "Encounter Id", col 30,
   "Accession Nbr", col 53, "Order Id",
   col 64, "Clinically Significant Updt Dt/Tm", row + 1,
   col 1, "---------", col 16,
   "------------", col 30, "-------------",
   col 53, "--------", col 64,
   "---------------------------------"
  DETAIL
   row + 1, col 1, person_id,
   col 12, encntr_id, col 30,
   ce.accession_nbr, col 48, order_id,
   col 64, clinsig_updt_dt_tm
  WITH nocounter
 ;end select
#end_get_clinical_event
#begin_devicexref
 EXECUTE FROM initialize TO end_initialize
 SET type_chosen = 0
 CALL clear(1,1)
 CALL box(2,1,23,110)
 CALL text(3,22,"*** VIEW DEVICE CROSS-REFERENCE ASSOCIATIONS ***")
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
     code_value cv
    PLAN (dx
     WHERE dx.parent_entity_name="LOCATION")
     JOIN (cv
     WHERE cv.code_value=dx.parent_entity_id)
     JOIN (d
     WHERE d.device_cd=dx.device_cd)
    ORDER BY cv.display
    HEAD REPORT
     cnt = 0, row + 1, col 2,
     "Location", col 35, "Printer",
     col 60, "Device Cd", row + 1,
     col 2, "--------", col 35,
     "--------", col 60, "---------",
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
     WHERE p.person_id=dx.parent_entity_id)
     JOIN (d
     WHERE d.device_cd=dx.device_cd)
    ORDER BY p.name_full_formatted
    HEAD REPORT
     cnt = 0, row + 1, col 2,
     "Name", col 35, "Printer",
     col 60, "Device Cd", row + 1,
     col 2, "--------", col 35,
     "--------", col 60, "---------",
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
     WHERE o.organization_id=dx.parent_entity_id)
     JOIN (d
     WHERE d.device_cd=dx.device_cd)
    ORDER BY o.org_name
    HEAD REPORT
     cnt = 0, row + 1, col 2,
     "Organization", col 35, "Printer",
     col 60, "Device Cd", row + 1,
     col 2, "--------", col 35,
     "--------", col 60, "---------",
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
     device d
    PLAN (dx
     WHERE dx.parent_entity_name="SERVICE_RESOURCE")
     JOIN (cv
     WHERE cv.code_value=dx.parent_entity_id)
     JOIN (d
     WHERE d.device_cd=dx.device_cd)
    ORDER BY cv.display
    HEAD REPORT
     cnt = 0, row + 1, col 2,
     "Service Resource", col 35, "Printer",
     col 60, "Device Cd", row + 1,
     col 2, "--------", col 35,
     "--------", col 60, "---------",
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
  CALL text(9,4,"Shift/F5 to see a list of Printers")
  SET help =
  SELECT INTO "nl:"
   d.name
   FROM device d
   WHERE d.device_cd > 0
    AND d.device_type_cd IN (fax_type_cd, printer_type_cd)
   ORDER BY d.name
   WITH nocounter
  ;end select
  CALL accept(10,4,"P(50);C")
  SET help = off
  SET device_name_chosen = fillstring(50," ")
  SET device_name_chosen = trim(curaccept)
  SELECT DISTINCT INTO "nl:"
   FROM device d
   WHERE d.name=device_name_chosen
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
    cnt = (cnt+ 1), stat = alterlist(xref_rec->qual,cnt), xref_rec->qual[cnt].type = type,
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
#end_devicexref
#begin_laws
 SET person_id_chosen = 0.0
 CALL clear(1,1)
 CALL box(2,1,23,110)
 CALL text(5,4,"Choose a Person_Id: ")
 CALL accept(5,30,"P(40);Cf"," ")
 SET person_id_chosen = cnvtreal(curaccept)
 SET law_id_chosen = 0.0
 CALL text(7,4,"Choose a Law: ")
 CALL text(9,4,"Shift/F5 to see a list of Cross-Encounter laws")
 SET help =
 SELECT INTO "nl:"
  cl.law_descr
  FROM chart_law cl
  WHERE cl.law_id > 0
   AND cl.active_ind=1
  ORDER BY cl.law_descr
  WITH nocounter
 ;end select
 CALL accept(10,4,"P(80);C")
 SET help = off
 SET law_name_chosen = fillstring(80," ")
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
  e.encntr_id, d_string = format(e.disch_dt_tm,"mm/dd/yyyy hh:mm"), c_string = format(e.create_dt_tm,
   "mm/dd/yyyy hh:mm"),
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
   encntr_cnt = (encntr_cnt+ 1), stat = alterlist(encntr_rec->qual,encntr_cnt), encntr_rec->qual[
   encntr_cnt].encntr_id = e.encntr_id,
   encntr_rec->qual[encntr_cnt].disch_dt_tm = e.disch_dt_tm, encntr_rec->qual[encntr_cnt].
   create_dt_tm = e.create_dt_tm, encntr_rec->qual[encntr_cnt].encntr_type_cd = e.encntr_type_cd,
   encntr_rec->qual[encntr_cnt].encntr_type_cd_string = trim(e_type_string), encntr_rec->qual[
   encntr_cnt].organization_id = e.organization_id, encntr_rec->qual[encntr_cnt].organization_name =
   trim(o.org_name),
   stat = alterlist(encntr_rec->qual[encntr_cnt].locations,5), encntr_rec->qual[encntr_cnt].
   locations[1].location_cd = e.loc_facility_cd, encntr_rec->qual[encntr_cnt].locations[2].
   location_cd = e.loc_building_cd,
   encntr_rec->qual[encntr_cnt].locations[3].location_cd = e.loc_nurse_unit_cd, encntr_rec->qual[
   encntr_cnt].locations[4].location_cd = e.loc_room_cd, encntr_rec->qual[encntr_cnt].locations[5].
   location_cd = e.loc_bed_cd,
   encntr_rec->qual[encntr_cnt].med_service_cd = e.med_service_cd, encntr_rec->qual[encntr_cnt].
   locations[1].location_cd_string = trim(fac_string), encntr_rec->qual[encntr_cnt].locations[2].
   location_cd_string = trim(bld_string),
   encntr_rec->qual[encntr_cnt].locations[3].location_cd_string = trim(nu_string), encntr_rec->qual[
   encntr_cnt].locations[4].location_cd_string = trim(room_string), encntr_rec->qual[encntr_cnt].
   locations[5].location_cd_string = trim(bed_string),
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
  ppr.person_id, reltn_string = uar_get_code_display(ppr.person_prsnl_r_cd), ppr_name = build(trim(
    substring(1,10,p.name_last)),",",trim(substring(1,10,p.name_first)))
  FROM person_prsnl_reltn ppr,
   prsnl p
  PLAN (ppr
   WHERE (ppr.person_id=encntr_rec->person_id)
    AND ppr.active_ind=1
    AND ppr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ppr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND ppr.prsnl_person_id > 0)
   JOIN (p
   WHERE p.person_id=ppr.prsnl_person_id)
  HEAD REPORT
   prov_cnt = 0, size_encntr = 0, size_encntr = size(encntr_rec->qual,5),
   x = 0, y = 0, size_prov = 0
  DETAIL
   prov_cnt = (prov_cnt+ 1), stat = alterlist(encntr_rec->qual[1].providers,prov_cnt), encntr_rec->
   qual[1].providers[prov_cnt].provider_id = ppr.prsnl_person_id,
   encntr_rec->qual[1].providers[prov_cnt].reltn_type_cd = ppr.person_prsnl_r_cd, encntr_rec->qual[1]
   .providers[prov_cnt].provider_name = trim(ppr_name), encntr_rec->qual[1].providers[prov_cnt].
   reltn_type_cd_string = trim(reltn_string)
  FOOT REPORT
   IF (size_encntr > 1)
    FOR (x = 2 TO size_encntr)
     size_prov = size(encntr_rec->qual[1].providers,5),
     FOR (y = 1 TO size_prov)
       stat = alterlist(encntr_rec->qual[x].providers,size_prov), encntr_rec->qual[x].providers[y].
       provider_id = encntr_rec->qual[1].providers[y].provider_id, encntr_rec->qual[x].providers[y].
       reltn_type_cd = encntr_rec->qual[1].providers[y].reltn_type_cd,
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
    AND epr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND epr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND epr.prsnl_person_id > 0)
   JOIN (p
   WHERE p.person_id=epr.prsnl_person_id)
  HEAD REPORT
   prov_cnt = 0, orig_prov_cnt = 0
  HEAD d.seq
   prov_cnt = size(encntr_rec->qual[d.seq].providers,5), orig_prov_cnt = prov_cnt
  DETAIL
   prov_cnt = (prov_cnt+ 1), stat = alterlist(encntr_rec->qual[d.seq].providers,prov_cnt), encntr_rec
   ->qual[d.seq].providers[prov_cnt].provider_id = epr.prsnl_person_id,
   encntr_rec->qual[d.seq].providers[prov_cnt].reltn_type_cd = epr.encntr_prsnl_r_cd, encntr_rec->
   qual[d.seq].providers[prov_cnt].provider_name = trim(epr_name), encntr_rec->qual[d.seq].providers[
   prov_cnt].reltn_type_cd_string = trim(reltn_string)
  WITH nocounter
 ;end select
 SET size_encntr = 0
 SET size_encntr = size(encntr_rec->qual,5)
 SELECT INTO "nl:"
  opr.prsnl_person_id, opr_name = build(trim(substring(1,10,p.name_last)),",",trim(substring(1,10,p
     .name_first))), reltn_string = uar_get_code_display(opr.chart_prsnl_r_type_cd)
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
   prov_cnt = (prov_cnt+ 1), stat = alterlist(encntr_rec->qual[d.seq].providers,prov_cnt), encntr_rec
   ->qual[d.seq].providers[prov_cnt].provider_id = opr.prsnl_person_id,
   encntr_rec->qual[d.seq].providers[prov_cnt].reltn_type_cd = opr.chart_prsnl_r_type_cd, encntr_rec
   ->qual[d.seq].providers[prov_cnt].provider_name = trim(opr_name), encntr_rec->qual[d.seq].
   providers[prov_cnt].reltn_type_cd_string = trim(reltn_string)
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
   law_rec->law_id = cl.law_id, law_rec->law_descr = trim(cl.law_descr), law_rec->lookback_days = cl
   .lookback_days,
   law_rec->lookback_type_ind = cl.lookback_type_ind
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  clf.*
  FROM chart_law_filter clf
  WHERE (clf.law_id=law_rec->law_id)
  HEAD REPORT
   do_nothing = 0, law_rec->et_included_flag = 99, law_rec->org_included_flag = 99,
   law_rec->prov_included_flag = 99, law_rec->loc_included_flag = 99, law_rec->ms_included_flag = 99
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
    et_cnt = (et_cnt+ 1), stat = alterlist(law_rec->encntr_types,et_cnt), law_rec->encntr_types[
    et_cnt].encntr_type_cd = clfv.parent_entity_id,
    law_rec->encntr_types[et_cnt].encntr_type_cd_string = uar_get_code_display(clfv.parent_entity_id)
   ENDIF
   IF (clfv.type_flag=1)
    org_cnt = (org_cnt+ 1), stat = alterlist(law_rec->organizations,org_cnt), law_rec->organizations[
    org_cnt].organization_id = clfv.parent_entity_id,
    law_rec->organizations[org_cnt].organization_name = ""
   ENDIF
   IF (clfv.type_flag=2)
    prov_cnt = (prov_cnt+ 1), stat = alterlist(law_rec->providers,prov_cnt), law_rec->providers[
    prov_cnt].provider_id = clfv.parent_entity_id,
    law_rec->providers[prov_cnt].reltn_type_cd = clfv.reltn_type_cd, law_rec->providers[prov_cnt].
    provider_name = "", law_rec->providers[prov_cnt].reltn_type_cd_string = uar_get_code_display(clfv
     .reltn_type_cd)
   ENDIF
   IF (clfv.type_flag=3)
    loc_cnt = (loc_cnt+ 1), stat = alterlist(law_rec->locations,loc_cnt), law_rec->locations[loc_cnt]
    .location_cd = clfv.parent_entity_id,
    law_rec->locations[loc_cnt].location_cd_string = uar_get_code_display(clfv.parent_entity_id)
   ENDIF
   IF (clfv.type_flag=4)
    ms_cnt = (ms_cnt+ 1), stat = alterlist(law_rec->med_services,ms_cnt), law_rec->med_services[
    ms_cnt].med_service_cd = clfv.parent_entity_id,
    law_rec->med_services[ms_cnt].med_service_cd_string = uar_get_code_display(clfv.parent_entity_id)
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
   row + 1, col 20, "* * * ENCNTR / LAW TEST * * *",
   row + 2, col 2, "PERSON_ID: ",
   col 20, person_id_chosen";l", row + 1,
   col 2, "LAW_ID: ", col 20,
   law_id_chosen";l", row + 2, col 2,
   "ENCNTR_ID", col 17, "ENCNTR-TYPE",
   col 30, "CLIENT", col 38,
   "PROVIDER", col 48, "LOCATION",
   col 58, "MED-SERV", col 68,
   "CREATE DT/TM", col 86, "DISCHG DT/TM",
   col 103, "LAST CLIN_SIG DT/TM", row + 1,
   size_encntr = size(encntr_rec->qual,5), x = 0
  DETAIL
   do_nothing = 0
  FOOT REPORT
   FOR (x = 1 TO size_encntr)
     row + 1, col 2, encntr_rec->qual[x].encntr_id";l",
     col 17
     IF ((encntr_rec->qual[x].et_qual=1))
      "PASS"
     ELSEIF ((encntr_rec->qual[x].et_qual=0))
      "FAIL"
     ELSE
      " - "
     ENDIF
     col 30
     IF ((encntr_rec->qual[x].org_qual=1))
      "PASS"
     ELSEIF ((encntr_rec->qual[x].org_qual=0))
      "FAIL"
     ELSE
      " - "
     ENDIF
     col 38
     IF ((encntr_rec->qual[x].prov_qual=1))
      "PASS"
     ELSEIF ((encntr_rec->qual[x].prov_qual=0))
      "FAIL"
     ELSE
      " - "
     ENDIF
     col 48
     IF ((encntr_rec->qual[x].loc_qual=1))
      "PASS"
     ELSEIF ((encntr_rec->qual[x].loc_qual=0))
      "FAIL"
     ELSE
      " - "
     ENDIF
     col 58
     IF ((encntr_rec->qual[x].ms_qual=1))
      "PASS"
     ELSEIF ((encntr_rec->qual[x].ms_qual=0))
      "FAIL"
     ELSE
      " - "
     ENDIF
     col 68, encntr_rec->qual[x].create_dt_tm"@SHORTDATETIMENOSEC", col 86,
     encntr_rec->qual[x].disch_dt_tm"@SHORTDATETIMENOSEC", col 103, encntr_rec->qual[x].
     last_clinsig_updt_dt_tm"@SHORTDATETIMENOSEC"
   ENDFOR
   row + 5, col 20, "* * * SEE CONTINUED REPORT * * *",
   row + 17, col 2,
   "****************************************************************************************************",
   row + 3, col 20, "* * * ENCOUNTER SUMMARY * * *",
   row + 1, col 2, " PERSON_ID: ",
   person_id_chosen";l", "  --  ", encntr_rec->person_name,
   row + 1, size_encntr = 0, size_prov = 0,
   size_loc = 0, size_encntr = size(encntr_rec->qual,5), x = 0
   FOR (x = 1 TO size_encntr)
     row + 1, col 2, "------------------------------------",
     row + 1, col 2, "|  ENCNTR_ID:",
     col 20, encntr_rec->qual[x].encntr_id, col 37,
     "|", row + 1, col 2,
     "------------------------------------", row + 1, col 8,
     "CREATE_DT_TM: ", col 35, encntr_rec->qual[x].create_dt_tm"@SHORTDATETIMENOSEC",
     row + 1, col 8, "DISCH_DT_TM: ",
     col 35, encntr_rec->qual[x].disch_dt_tm"@SHORTDATETIMENOSEC", row + 1,
     col 8, "LAST CLINSIG_UPDT_DT_TM: ", col 35,
     encntr_rec->qual[x].last_clinsig_updt_dt_tm"@SHORTDATETIMENOSEC", row + 2, col 8,
     "ENCNTR-TYPE:", col 35, encntr_rec->qual[x].encntr_type_cd";l",
     " ( ", encntr_rec->qual[x].encntr_type_cd_string, " ) ",
     row + 2, col 8, "CLIENT:",
     col 35, encntr_rec->qual[x].organization_id";l", " ( ",
     encntr_rec->qual[x].organization_name, " ) ", row + 2,
     col 8, "PROVIDERS:", row + 1,
     col 8, "----------", size_prov = size(encntr_rec->qual[x].providers,5)
     FOR (y = 1 TO size_prov)
       row + 1, col 10, encntr_rec->qual[x].providers[y].provider_id";l",
       " ( ", encntr_rec->qual[x].providers[y].provider_name, " ) ",
       col 65, encntr_rec->qual[x].providers[y].reltn_type_cd";l", " ( ",
       encntr_rec->qual[x].providers[y].reltn_type_cd_string, " ) "
     ENDFOR
     row + 2, col 8, "LOCATIONS:",
     row + 1, col 8, "------------",
     size_loc = size(encntr_rec->qual[x].locations,5)
     FOR (y = 1 TO size_loc)
       IF ((encntr_rec->qual[x].locations[y].location_cd > 0))
        row + 1, col 10, encntr_rec->qual[x].locations[y].location_cd";l",
        " ( ", encntr_rec->qual[x].locations[y].location_cd_string, " ) "
       ENDIF
     ENDFOR
     row + 2, col 8, "MED-SERVICE:",
     col 35, encntr_rec->qual[x].med_service_cd";l", " ( ",
     encntr_rec->qual[x].med_service_cd_string, " ) ", row + 1,
     col 2,
     "--------------------------------------------------------------------------------------------------",
     row + 1
   ENDFOR
   row + 5, col 20, "* * * SEE CONTINUED REPORT * * *",
   row + 17, col 2,
   "****************************************************************************************************",
   row + 3, col 20, "* * * LAW SUMMARY * * *",
   row + 2, col 2, "LAW_ID: ",
   col 18, law_rec->law_id";l", " ( ",
   law_rec->law_descr, " ) ", row + 1,
   col 2, "LOOKBACK_DAYS: ", col 18,
   law_rec->lookback_days";l", col 25
   IF ((law_rec->lookback_type_ind=1))
    "( BY DISCHARGE DATE/TIME )"
   ELSEIF ((law_rec->lookback_type_ind=2))
    "( BY CLINICAL ACTIVITY DATE/TIME )"
   ENDIF
   row + 2, col 2, "ENCNTR-TYPES",
   col + 2
   IF ((law_rec->et_included_flag=1))
    " (INCLUDE)"
   ELSEIF ((law_rec->et_included_flag=0))
    " (EXCLUDE)"
   ENDIF
   row + 1, col 2, "-----------------------------------",
   size_et = size(law_rec->encntr_types,5)
   FOR (x = 1 TO size_et)
     row + 1, col 4, law_rec->encntr_types[x].encntr_type_cd";l",
     " ( ", law_rec->encntr_types[x].encntr_type_cd_string, " ) "
   ENDFOR
   row + 2, col 2, "CLIENTS",
   col + 2
   IF ((law_rec->org_included_flag=1))
    " (INCLUDE)"
   ELSEIF ((law_rec->org_included_flag=0))
    " (EXCLUDE)"
   ENDIF
   row + 1, col 2, "-----------------------------------",
   size_org = size(law_rec->organizations,5)
   FOR (x = 1 TO size_org)
     row + 1, col 4, law_rec->organizations[x].organization_id";l",
     " ( ", law_rec->organizations[x].organization_name, " ) "
   ENDFOR
   row + 2, col 2, "PROVIDERS",
   col + 2
   IF ((law_rec->prov_included_flag=1))
    " (INCLUDE)"
   ELSEIF ((law_rec->prov_included_flag=0))
    " (EXCLUDE)"
   ENDIF
   row + 1, col 2, "-----------------------------------",
   size_prov = size(law_rec->providers,5)
   FOR (x = 1 TO size_prov)
     row + 1, col 4, law_rec->providers[x].provider_id";l",
     " ( ", law_rec->providers[x].provider_name, " ) ",
     col 50, law_rec->providers[x].reltn_type_cd";l", " ( ",
     law_rec->providers[x].reltn_type_cd_string, " ) "
   ENDFOR
   row + 2, col 2, "LOCATIONS",
   col + 2
   IF ((law_rec->loc_included_flag=1))
    " (INCLUDE)"
   ELSEIF ((law_rec->loc_included_flag=0))
    " (EXCLUDE)"
   ENDIF
   row + 1, col 2, "-----------------------------------",
   size_loc = size(law_rec->locations,5)
   FOR (x = 1 TO size_loc)
     row + 1, col 4, law_rec->locations[x].location_cd";l",
     " ( ", law_rec->locations[x].location_cd_string, " ) "
   ENDFOR
   row + 2, col 2, "MED-SERVICE",
   col + 2
   IF ((law_rec->ms_included_flag=1))
    " (INCLUDE)"
   ELSEIF ((law_rec->ms_included_flag=0))
    " (EXCLUDE)"
   ENDIF
   row + 1, col 2, "-----------------------------------",
   size_ms = size(law_rec->med_services,5)
   FOR (x = 1 TO size_ms)
     row + 1, col 4, law_rec->med_services[x].med_service_cd";l",
     " ( ", law_rec->med_services[x].med_service_cd_string, " ) "
   ENDFOR
   col + 3, row + 2, "****************************** END OF REPORT ******************************"
  WITH nocounter
 ;end select
#end_laws
#start_clear_screen
 FOR (x = 3 TO 22)
   CALL clear(x,2,132)
 ENDFOR
#end_clear_screen
#exit_script
END GO
