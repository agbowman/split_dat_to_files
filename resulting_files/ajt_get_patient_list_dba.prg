CREATE PROGRAM ajt_get_patient_list:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Patient List" = "",
  "Print Options" = 0,
  "Display nurse and case manager" = 0
  WITH outdev, patlist, printoptions,
  dispnurse
 DECLARE ml_debug_flag = i4 WITH protect, constant(validate(bhs_debug_flag,0))
 IF (ml_debug_flag > 1)
  CALL echo("Start of script ajt_get_patient_list")
 ENDIF
 DECLARE ms_print_pt_w_cpt_sticky = i4 WITH protect, constant(1)
 DECLARE ms_print_pt_w_cpt = i4 WITH protect, constant(2)
 DECLARE ms_print_pt_w_sticky = i4 WITH protect, constant(3)
 DECLARE ms_print_pt_w_sticky_vitals = i4 WITH protect, constant(8)
 DECLARE ms_print_pt_only = i4 WITH protect, constant(4)
 DECLARE ms_print_rounds_rpt = i4 WITH protect, constant(5)
 DECLARE ms_print_rounds_rpt_1_per_page = i4 WITH protect, constant(7)
 DECLARE ms_print_clin_sum_downtime = i4 WITH protect, constant(6)
 DECLARE my_cnt = i4 WITH protect, noconstant(0)
 SET displaynurse =  $DISPNURSE
 FREE RECORD dgapl_request
 RECORD dgapl_request(
   1 prsnl_id = f8
 )
 SET dgapl_request->prsnl_id = reqinfo->updt_id
 RECORD dgapl_reply(
   1 patient_lists[*]
     2 patient_list_id = f8
     2 name = vc
     2 description = vc
     2 patient_list_type_cd = f8
     2 owner_id = f8
     2 list_access_cd = f8
     2 arguments[*]
       3 argument_name = vc
       3 argument_value = vc
       3 parent_entity_name = vc
       3 parent_entity_id = f8
     2 encntr_type_filters[*]
       3 encntr_type_cd = f8
       3 encntr_class_cd = f8
     2 proxies[*]
       3 prsnl_id = f8
       3 prsnl_group_id = f8
       3 list_access_cd = f8
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 EXECUTE dcp_get_available_pat_lists  WITH replace(request,dgapl_request), replace(reply,dgapl_reply)
 RECORD dgp_reply(
   1 patient_list_id = f8
   1 name = vc
   1 description = vc
   1 patient_list_type_cd = f8
   1 owner_id = f8
   1 prsnl_access_cd = f8
   1 execution_dt_tm = dq8
   1 execution_status_cd = f8
   1 execution_status_disp = vc
   1 arguments[*]
     2 argument_name = vc
     2 argument_value = vc
     2 parent_entity_name = vc
     2 parent_entity_id = f8
   1 encntr_type_filters[*]
     2 encntr_type_cd = f8
   1 patients[*]
     2 person_id = f8
     2 person_name = vc
     2 encntr_id = f8
     2 priority = i4
     2 active_ind = i2
     2 filter_ind = i2
     2 responsible_prsnl_id = f8
     2 responsible_prsnl_name = vc
     2 responsible_reltn_cd = f8
     2 responsible_reltn_disp = vc
     2 responsible_reltn_id = f8
     2 responsible_reltn_flag = i2
     2 organization_id = f8
     2 confid_level_cd = f8
     2 confid_level = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD request
 RECORD request(
   1 patient_list_id = f8
   1 patient_list_type_cd = f8
   1 best_encntr_flag = i2
   1 arguments[*]
     2 argument_name = vc
     2 argument_value = vc
     2 parent_entity_name = vc
     2 parent_entity_id = f8
   1 encntr_type_filters[*]
     2 encntr_type_cd = f8
     2 encntr_class_cd = f8
   1 patient_list_name = vc
   1 mv_flag = i2
   1 rmv_pl_rows_flag = i2
 )
 DECLARE selection = i4
 FOR (i = 1 TO size(dgapl_reply->patient_lists,5))
   IF ((dgapl_reply->patient_lists[i].patient_list_id=cnvtreal( $PATLIST)))
    SET selection = i
    SET i = (size(dgapl_reply->patient_lists,5)+ 1)
   ENDIF
 ENDFOR
 SET request->patient_list_id = dgapl_reply->patient_lists[selection].patient_list_id
 SET request->patient_list_type_cd = dgapl_reply->patient_lists[selection].patient_list_type_cd
 SET num_arguments = size(dgapl_reply->patient_lists[selection].arguments,5)
 CALL echo(num_arguments)
 SET stat = alterlist(request->arguments,num_arguments)
 FOR (i = 1 TO num_arguments)
  IF ((dgapl_reply->patient_lists[selection].arguments[i].argument_name="disch_mins"))
   CALL echo("disch_mins found")
   SET request->arguments[i].argument_name = "patient_status_flag"
   SET request->arguments[i].argument_value = "3"
  ELSE
   SET request->arguments[i].argument_name = dgapl_reply->patient_lists[selection].arguments[i].
   argument_name
   SET request->arguments[i].argument_value = dgapl_reply->patient_lists[selection].arguments[i].
   argument_value
   SET request->arguments[i].parent_entity_name = dgapl_reply->patient_lists[selection].arguments[i].
   parent_entity_name
   SET request->arguments[i].parent_entity_id = dgapl_reply->patient_lists[selection].arguments[i].
   parent_entity_id
  ENDIF
  IF ((request->arguments[i].argument_name="encntr_type"))
   CALL echo("encntr_type found")
   SET my_cnt = (my_cnt+ 1)
   SET stat = alterlist(dgapl_reply->patient_lists[selection].encntr_type_filters,my_cnt)
   SET dgapl_reply->patient_lists[selection].encntr_type_filters[my_cnt].encntr_type_cd = dgapl_reply
   ->patient_lists[selection].arguments[i].parent_entity_id
  ENDIF
 ENDFOR
 SET num_filters = size(dgapl_reply->patient_lists[selection].encntr_type_filters,5)
 SET stat = alterlist(request->encntr_type_filters,num_filters)
 FOR (i = 1 TO num_filters)
  SET request->encntr_type_filters[i].encntr_type_cd = dgapl_reply->patient_lists[selection].
  encntr_type_filters[i].encntr_type_cd
  SET request->encntr_type_filters[i].encntr_class_cd = dgapl_reply->patient_lists[selection].
  encntr_type_filters[i].encntr_class_cd
 ENDFOR
 SET dgp_reply->status_data.status = "F"
 DECLARE listtype = vc WITH constant(uar_get_code_meaning(request->patient_list_type_cd))
 DECLARE encntr_org_sec_ind = i2 WITH noconstant(0)
 DECLARE confid_ind = i2 WITH noconstant(0)
 DECLARE logstatistics(seconds=f8) = null
 DECLARE begin_time = f8 WITH noconstant(cnvtdatetime(curdate,curtime3))
 DECLARE finish_time = f8 WITH noconstant(cnvtdatetime(curdate,curtime3))
 SET request->patient_list_name = dgapl_reply->patient_lists[1].name
 SET request->mv_flag = - (1)
 SET request->rmv_pl_rows_flag = 0
 CALL echo(build2("ListType:",listtype))
 CALL echorecord(request)
 CALL echo("")
 CALL echo("")
 CASE (listtype)
  OF "CUSTOM":
   EXECUTE dcp_get_pl_custom  WITH replace(reply,dgp_reply)
  OF "CARETEAM":
   EXECUTE bhs_dcp_get_pl_careteam2
  OF "LOCATION":
   EXECUTE dcp_get_pl_location  WITH replace(reply,dgp_reply)
  OF "LOCATIONGRP":
   EXECUTE dcp_get_pl_location_grp replace(reply,dgp_reply)
  OF "VRELTN":
   EXECUTE dcp_get_pl_visit_reltn  WITH replace(reply,dgp_reply)
  OF "LRELTN":
   EXECUTE dcp_get_pl_lifetime_reltn  WITH replace(reply,dgp_reply)
  OF "SERVICE":
   EXECUTE dcp_get_pl_service  WITH replace(reply,dgp_reply)
  OF "ASSIGNMENT":
   EXECUTE dcp_get_pl_asgmt  WITH replace(reply,dgp_reply)
  OF "ANC_ASGMT":
   EXECUTE dcp_get_pl_ancillary_asgmt  WITH replace(reply,dgp_reply)
  OF "QUERY":
   EXECUTE dcp_get_pl_query  WITH replace(reply,dgp_reply)
  OF "SCHEDULE":
   EXECUTE dcp_get_pl_schedule  WITH replace(reply,dgp_reply)
  OF "PROVIDERGRP":
   SET do_nothing = 1
  ELSE
   GO TO error
 ENDCASE
 CALL echorecord(request)
 CALL echorecord(dgp_reply)
 FREE RECORD drd_request
 RECORD drd_request(
   1 output_device = vc
   1 script_name = vc
   1 person_cnt = i4
   1 person[*]
     2 person_id = f8
   1 visit_cnt = i4
   1 visit[*]
     2 encntr_id = f8
     2 sort_order = i4
   1 prsnl_cnt = i4
   1 prsnl[*]
     2 prsnl_id = f8
   1 nv_cnt = i4
   1 nv[*]
     2 pvc_name = vc
     2 pvc_value = vc
   1 batch_selection = vc
 )
 FREE RECORD req2
 RECORD req2(
   1 fromccl = i4
   1 printcpt4codes = i4
   1 chestpainobs = i4
   1 pagebreak = i4
 )
 IF (listtype="PROVIDERGRP")
  FREE RECORD reply
  RECORD reply(
    1 patient_list_id = f8
    1 name = vc
    1 description = vc
    1 patient_list_type_cd = f8
    1 owner_id = f8
    1 prsnl_access_cd = f8
    1 execution_dt_tm = dq8
    1 execution_status_cd = f8
    1 execution_status_disp = vc
    1 arguments[*]
      2 argument_name = vc
      2 argument_value = vc
      2 parent_entity_name = vc
      2 parent_entity_id = f8
    1 encntr_type_filters[*]
      2 encntr_type_cd = f8
    1 patients[*]
      2 person_id = f8
      2 person_name = vc
      2 encntr_id = f8
      2 priority = i4
      2 active_ind = i2
      2 filter_ind = i2
      2 responsible_prsnl_id = f8
      2 responsible_prsnl_name = vc
      2 responsible_reltn_cd = f8
      2 responsible_reltn_disp = vc
      2 responsible_reltn_id = f8
      2 responsible_reltn_flag = i2
      2 organization_id = f8
      2 confid_level_cd = f8
      2 confid_level_disp = c40
      2 confid_level = i4
      2 birthdate = dq8
      2 birth_tz = i4
      2 end_effective_dt_tm = dq8
      2 service_cd = f8
      2 service_disp = c40
      2 gender_cd = f8
      2 gender_disp = c40
      2 temp_location_cd = f8
      2 temp_location_disp = c40
      2 vip_cd = f8
      2 visit_reason = vc
      2 visitor_status_cd = f8
      2 visitor_status_disp = c40
      2 deceased_date = dq8
      2 deceased_tz = i4
      2 remove_ind = i4
      2 remove_dt_tm = dq8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
  EXECUTE dcp_get_pl_provider_group2
  SET drd_request->visit_cnt = size(reply->patients,5)
  SET stat = alterlist(drd_request->visit,size(reply->patients,5))
  FOR (i = 1 TO drd_request->visit_cnt)
    SET drd_request->visit[i].encntr_id = reply->patients[i].encntr_id
  ENDFOR
  FREE RECORD reply
 ENDIF
 SET drd_request->person_cnt = 0
 SET stat = alterlist(drd_request->person,0)
 SET drd_request->prsnl_cnt = 1
 SET stat = alterlist(drd_request->prsnl,1)
 SET drd_request->prsnl[1].prsnl_id = reqinfo->updt_id
 SET drd_request->nv_cnt = 1
 SET stat = alterlist(drd_request->nv,1)
 IF (listtype != "PROVIDERGRP")
  SET drd_request->visit_cnt = size(dgp_reply->patients,5)
  SET stat = alterlist(drd_request->visit,size(dgp_reply->patients,5))
  FOR (i = 1 TO drd_request->visit_cnt)
    SET drd_request->visit[i].encntr_id = dgp_reply->patients[i].encntr_id
  ENDFOR
 ENDIF
 SET drd_request->nv[1].pvc_name = "LISTNAME"
 SET drd_request->nv[1].pvc_value = dgapl_reply->patient_lists[selection].name
 SET drd_request->output_device =  $OUTDEV
 IF (( $PRINTOPTIONS IN (ms_print_pt_w_cpt_sticky, ms_print_pt_w_cpt)))
  SET req2->printcpt4codes = 1
 ELSE
  SET req2->printcpt4codes = 0
 ENDIF
 SET req2->fromccl = 1
 IF (( $PRINTOPTIONS IN (ms_print_pt_w_cpt_sticky, ms_print_pt_w_cpt, ms_print_pt_w_sticky,
 ms_print_pt_w_sticky_vitals, ms_print_rounds_rpt)))
  SET req2->chestpainobs = 1
 ELSE
  SET req2->chestpainobs = 0
 ENDIF
 IF (( $PRINTOPTIONS IN (ms_print_pt_w_cpt_sticky, ms_print_pt_w_sticky)))
  CALL echo("PRINTING STICKY NOTES")
  CALL echorecord(drd_request)
  SET drd_request->script_name = "bhs_ma_pvpatlist_sn"
  EXECUTE bhs_ma_pvpatlist_sn  WITH replace(request,drd_request), replace(req2,req2)
 ELSEIF (( $PRINTOPTIONS IN (ms_print_pt_w_cpt, ms_print_pt_only)))
  CALL echo("NOT PRINTING STICKY NOTES")
  SET drd_request->script_name = "bhs_ma_pvpatlist"
  EXECUTE bhs_ma_pvpatlist  WITH replace(request,drd_request), replace(req2,req2)
 ELSEIF (( $PRINTOPTIONS IN (ms_print_pt_w_sticky_vitals)))
  CALL echo("printing Sticky with Vitals")
  SET drd_request->script_name = "bhs_ma_pvpatlist_sn_vital"
  EXECUTE bhs_ma_pvpatlist_sn_vital  WITH replace(request,drd_request), replace(req2,req2)
 ELSEIF (( $PRINTOPTIONS IN (ms_print_rounds_rpt, ms_print_rounds_rpt_1_per_page)))
  IF (( $PRINTOPTIONS=ms_print_rounds_rpt))
   SET req2->pagebreak = 1
  ELSE
   SET req2->pagebreak = 2
  ENDIF
  CALL echo("PRINTING ROUNDS REPORT")
  SET drd_request->script_name = "bhs_rounds_report_v2"
  EXECUTE bhs_rounds_report_v2  WITH replace(request,drd_request)
 ELSEIF (( $PRINTOPTIONS=ms_print_clin_sum_downtime))
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(size(drd_request->visit,5))),
    encounter e,
    person p
   PLAN (d)
    JOIN (e
    WHERE (e.encntr_id=drd_request->visit[d.seq].encntr_id))
    JOIN (p
    WHERE p.person_id=e.person_id)
   ORDER BY p.name_full_formatted
   HEAD REPORT
    sort_order = 0
   HEAD p.person_id
    sort_order = (sort_order+ 1), drd_request->visit[d.seq].sort_order = sort_order
   WITH nocounter
  ;end select
  FREE RECORD clinsum
  RECORD clinsum(
    1 output_device = vc
    1 visit[1]
      2 encntr_id = f8
  )
  FOR (i = 1 TO size(drd_request->visit,5))
    FOR (j = 1 TO size(drd_request->visit,5))
      IF ((drd_request->visit[j].sort_order=i))
       CALL echo(drd_request->visit[j].encntr_id)
       SET clinsum->output_device =  $OUTDEV
       SET clinsum->visit[1].encntr_id = drd_request->visit[j].encntr_id
       EXECUTE bhs_dt_clin_sum2  WITH replace(request,clinsum)
      ENDIF
    ENDFOR
  ENDFOR
 ENDIF
#error
 IF (ml_debug_flag > 1)
  CALL echo("End of script ajt_get_patient_list")
 ENDIF
 SET last_mod =
 "002 07/21/17 sh013356 SR 416374187 Filter out by encounter types since the standard script doesnt"
END GO
