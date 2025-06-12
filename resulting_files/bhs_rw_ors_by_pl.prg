CREATE PROGRAM bhs_rw_ors_by_pl
 PROMPT
  "OUTPUT: " = "MINE",
  "Patient List: " = 0.00
  WITH outdev, patlistid
 FREE RECORD rw_request_lists
 RECORD rw_request_lists(
   1 prsnl_id = f8
 )
 IF ((reqinfo->updt_id <= 0.00))
  CALL echo("No PRSNL_ID found. Exiting Script")
  GO TO exit_script
 ELSE
  SET rw_request_lists->prsnl_id = reqinfo->updt_id
 ENDIF
 FREE RECORD rw_reply_lists
 RECORD rw_reply_lists(
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
 CALL echo("Executing DCP_GET_AVAILABLE_PAT_LISTS")
 EXECUTE dcp_get_available_pat_lists  WITH replace(request,rw_request_lists), replace(reply,
  rw_reply_lists)
 CALL echo("DCP_GET_AVAILABLE_PAT_LISTS Complete")
 DECLARE tmp_pl = i4 WITH noconstant(1)
 DECLARE tmp_pl2 = i4 WITH noconstant(0)
 SET tmp_pl2 = locateval(tmp_pl,1,size(rw_reply_lists->patient_lists,5), $PATLISTID,rw_reply_lists->
  patient_lists[tmp_pl].patient_list_id)
 CALL echorecord(rw_reply_lists)
 IF ((rw_reply_lists->patient_lists[tmp_pl].patient_list_id !=  $PATLISTID))
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   DETAIL
    row 5, col 50, "Invalid Patient List ID. Exiting Script"
   WITH nocounter
  ;end select
  GO TO exit_script
 ENDIF
 FREE RECORD request
 RECORD request(
   1 patient_list_id = f8
   1 patient_list_type_cd = f8
   1 best_encntr_flag = i4
   1 arguments[*]
     2 argument_name = vc
     2 argument_value = vc
     2 parent_entity_name = vc
     2 parent_entity_id = f8
   1 encntr_type_filters[*]
     2 encntr_type_cd = f8
     2 encntr_class_cd = f8
 )
 FREE RECORD rw_reply_list
 RECORD rw_reply_list(
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
 SET request->patient_list_id = rw_reply_lists->patient_lists[tmp_pl].patient_list_id
 SET request->patient_list_type_cd = rw_reply_lists->patient_lists[tmp_pl].patient_list_type_cd
 DECLARE a_cnt = i4 WITH noconstant(0)
 DECLARE etf_cnt = i4 WITH noconstant(0)
 FOR (a = 1 TO size(rw_reply_lists->patient_lists[tmp_pl].arguments,5))
   IF ( NOT ((rw_reply_lists->patient_lists[tmp_pl].arguments[a].argument_name IN ("encntr_type",
   "encntr_class"))))
    SET a_cnt = (size(request->arguments,5)+ 1)
    SET stat = alterlist(request->arguments,a_cnt)
    SET request->arguments[a_cnt].argument_name = rw_reply_lists->patient_lists[tmp_pl].arguments[a].
    argument_name
    SET request->arguments[a_cnt].argument_value = rw_reply_lists->patient_lists[tmp_pl].arguments[a]
    .argument_value
    SET request->arguments[a_cnt].parent_entity_name = rw_reply_lists->patient_lists[tmp_pl].
    arguments[a].parent_entity_name
    SET request->arguments[a_cnt].parent_entity_id = rw_reply_lists->patient_lists[tmp_pl].arguments[
    a].parent_entity_id
   ELSE
    SET etf_cnt = (size(request->encntr_type_filters,5)+ 1)
    SET stat = alterlist(request->encntr_type_filters,etf_cnt)
    IF ((rw_reply_lists->patient_lists[tmp_pl].arguments[a].argument_name="encntr_type"))
     SET request->encntr_type_filters[etf_cnt].encntr_type_cd = rw_reply_lists->patient_lists[tmp_pl]
     .arguments[a].parent_entity_id
    ELSE
     SET request->encntr_type_filters[etf_cnt].encntr_class_cd = rw_reply_lists->patient_lists[tmp_pl
     ].arguments[a].parent_entity_id
    ENDIF
   ENDIF
 ENDFOR
 FOR (f = 1 TO size(rw_reply_lists->patient_lists[tmp_pl].encntr_type_filters,5))
   SET etf_cnt = (size(request->encntr_type_filters,5)+ 1)
   SET stat = alterlist(request->encntr_type_filters,etf_cnt)
   SET request->encntr_type_filters[etf_cnt].encntr_type_cd = rw_reply_lists->patient_lists[tmp_pl].
   encntr_type_filters[f].encntr_type_cd
   SET request->encntr_type_filters[etf_cnt].encntr_class_cd = rw_reply_lists->patient_lists[tmp_pl].
   encntr_type_filters[f].encntr_class_cd
 ENDFOR
 CALL echo("DCP_GET_PATIENT_LIST Executing")
 DECLARE listtype = vc WITH constant(uar_get_code_meaning(request->patient_list_type_cd))
 CALL echo(build2("LISTTYPE = ",listtype))
 CASE (listtype)
  OF "ANC_ASGMT":
   EXECUTE dcp_get_pl_ancillary_asgmt  WITH replace(reply,rw_reply_list)
  OF "ASSIGNMENT":
   EXECUTE dcp_get_pl_asgmt  WITH replace(reply,rw_reply_list)
  OF "CARETEAM":
   EXECUTE dcp_get_pl_careteam2  WITH replace(reply,rw_reply_list)
  OF "CUSTOM":
   EXECUTE dcp_get_pl_custom2  WITH replace(reply,rw_reply_list)
  OF "LOCATION":
   EXECUTE dcp_get_pl_location  WITH replace(reply,rw_reply_list)
  OF "LOCATIONGRP":
   EXECUTE dcp_get_pl_location_grp  WITH replace(reply,rw_reply_list)
  OF "LRELTN":
   EXECUTE dcp_get_pl_lifetime_reltn  WITH replace(reply,rw_reply_list)
  OF "PROVIDERGRP":
   EXECUTE dcp_get_pl_provider_group2  WITH replace(reply,rw_reply_list)
  OF "QUERY":
   EXECUTE dcp_get_pl_query  WITH replace(reply,rw_reply_list)
  OF "RELTN":
   EXECUTE dcp_get_pl_reltn  WITH replace(reply,rw_reply_list)
  OF "SCHEDULE":
   EXECUTE dcp_get_pl_schedule  WITH replace(reply,rw_reply_list)
  OF "SERVICE":
   EXECUTE dcp_get_pl_service  WITH replace(reply,rw_reply_list)
  OF "VRELTN":
   EXECUTE dcp_get_pl_visit_reltn  WITH replace(reply,rw_reply_list)
  ELSE
   GO TO exit_script
 ENDCASE
 CALL echorecord(rw_reply_list)
 CALL echo("DCP_GET_PATIENT_LIST Completed")
 FREE RECORD rw_request
 RECORD rw_request(
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
 SET rw_request->output_device =  $OUTDEV
 SET rw_request->prsnl_cnt = 1
 SET stat = alterlist(rw_request->prsnl,1)
 SET rw_request->prsnl[1].prsnl_id = reqinfo->updt_id
 SET rw_request->nv_cnt = 1
 SET stat = alterlist(rw_request->nv,1)
 SET rw_request->nv[1].pvc_name = "LISTNAME"
 SET rw_request->nv[1].pvc_value = rw_reply_lists->patient_lists[tmp_pl].name
 FOR (v = 1 TO size(rw_reply_list->patients,5))
   IF ((rw_reply_list->patients[v].encntr_id > 0.00))
    SET rw_request->visit_cnt = (rw_request->visit_cnt+ 1)
    SET stat = alterlist(rw_request->visit,rw_request->visit_cnt)
    SET rw_request->visit[rw_request->visit_cnt].encntr_id = rw_reply_list->patients[v].encntr_id
   ENDIF
 ENDFOR
 CALL echo("Executing BHS_RW_ORS_REPORT")
 EXECUTE bhs_rw_ors_report  WITH replace(request,rw_request)
 CALL echo("BHS_RW_ORS_REPORT Complete")
#exit_script
 DECLARE errmsg = c130
 DECLARE errcode = i4 WITH noconstant(error(errmsg,1))
 IF (errcode != 0)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   DETAIL
    row 5, col 0, "ERRORS:",
    row + 1
    WHILE (errcode != 0)
      row + 1, col 0, errmsg,
      errcode = error(errmsg,0)
    ENDWHILE
   WITH nocounter, append
  ;end select
 ENDIF
END GO
