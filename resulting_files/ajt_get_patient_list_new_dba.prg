CREATE PROGRAM ajt_get_patient_list_new:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Patient List" = "",
  "Print Options"
  WITH outdev, patlist, printoptions
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
 FREE RECORD dgp_request
 RECORD dgp_request(
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
 DECLARE selection = i4
 FOR (i = 1 TO size(dgapl_reply->patient_lists,5))
   IF ((dgapl_reply->patient_lists[i].patient_list_id=cnvtreal( $PATLIST)))
    SET selection = i
    SET i = (size(dgapl_reply->patient_lists,5)+ 1)
   ENDIF
 ENDFOR
 SET dgp_request->patient_list_id = dgapl_reply->patient_lists[selection].patient_list_id
 SET dgp_request->patient_list_type_cd = dgapl_reply->patient_lists[selection].patient_list_type_cd
 SET num_arguments = size(dgapl_reply->patient_lists[selection].arguments,5)
 SET stat = alterlist(dgp_request->arguments,num_arguments)
 FOR (i = 1 TO num_arguments)
   SET dgp_request->arguments[i].argument_name = dgapl_reply->patient_lists[selection].arguments[i].
   argument_name
   SET dgp_request->arguments[i].argument_value = dgapl_reply->patient_lists[selection].arguments[i].
   argument_value
   SET dgp_request->arguments[i].parent_entity_name = dgapl_reply->patient_lists[selection].
   arguments[i].parent_entity_name
   SET dgp_request->arguments[i].parent_entity_id = dgapl_reply->patient_lists[selection].arguments[i
   ].parent_entity_id
 ENDFOR
 SET num_filters = size(dgapl_reply->patient_lists[selection].encntr_type_filters,5)
 SET stat = alterlist(dgp_request->encntr_type_filters,num_filters)
 FOR (i = 1 TO num_filters)
  SET dgp_request->encntr_type_filters[i].encntr_type_cd = dgapl_reply->patient_lists[selection].
  encntr_type_filters[i].encntr_type_cd
  SET dgp_request->encntr_type_filters[i].encntr_class_cd = dgapl_reply->patient_lists[selection].
  encntr_type_filters[i].encntr_class_cd
 ENDFOR
 SET dgp_reply->status_data.status = "F"
 DECLARE listtype = vc WITH constant(uar_get_code_meaning(dgp_request->patient_list_type_cd))
 DECLARE encntr_org_sec_ind = i2 WITH noconstant(0)
 DECLARE confid_ind = i2 WITH noconstant(0)
 DECLARE logstatistics(seconds=f8) = null
 DECLARE begin_time = f8 WITH noconstant(cnvtdatetime(curdate,curtime3))
 DECLARE finish_time = f8 WITH noconstant(cnvtdatetime(curdate,curtime3))
 CALL echo(build("LISTTYPE:",listtype))
 CASE (listtype)
  OF "CUSTOM":
   EXECUTE dcp_get_pl_custom  WITH replace(request,dgp_request)
  OF "CARETEAM":
   EXECUTE bhs_dcp_get_pl_careteam  WITH replace(request,dgp_request)
  OF "LOCATION":
   EXECUTE dcp_get_pl_location  WITH replace(request,dgp_request)
  OF "LOCATIONGRP":
   EXECUTE dcp_get_pl_location_grp  WITH replace(request,dgp_request)
  OF "VRELTN":
   EXECUTE dcp_get_pl_visit_reltn  WITH replace(request,dgp_request)
  OF "LRELTN":
   EXECUTE dcp_get_pl_lifetime_reltn  WITH replace(request,dgp_request)
  OF "PROVIDERGRP":
   EXECUTE bhs_dcp_get_pl_provider_group  WITH replace(request,dgp_request)
  OF "SERVICE":
   EXECUTE dcp_get_pl_service  WITH replace(request,dgp_request)
  OF "ASSIGNMENT":
   EXECUTE dcp_get_pl_asgmt  WITH replace(request,dgp_request)
  OF "ANC_ASGMT":
   EXECUTE dcp_get_pl_ancillary_asgmt  WITH replace(request,dgp_request)
  OF "QUERY":
   EXECUTE dcp_get_pl_query  WITH replace(request,dgp_request)
  OF "SCHEDULE":
   EXECUTE dcp_get_pl_schedule  WITH replace(request,dgp_request)
  ELSE
   GO TO error
 ENDCASE
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
 )
 SET drd_request->person_cnt = 0
 SET stat = alterlist(drd_request->person,0)
 SET drd_request->prsnl_cnt = 1
 SET stat = alterlist(drd_request->prsnl,1)
 SET drd_request->prsnl[1].prsnl_id = reqinfo->updt_id
 SET drd_request->nv_cnt = 1
 SET stat = alterlist(drd_request->nv,1)
 SET drd_request->visit_cnt = size(dgp_reply->patients,5)
 SET stat = alterlist(drd_request->visit,size(dgp_reply->patients,5))
 FOR (i = 1 TO drd_request->visit_cnt)
   SET drd_request->visit[i].encntr_id = dgp_reply->patients[i].encntr_id
 ENDFOR
 SET drd_request->nv[1].pvc_name = "LISTNAME"
 SET drd_request->nv[1].pvc_value = dgapl_reply->patient_lists[selection].name
 SET drd_request->output_device =  $OUTDEV
 IF (( $PRINTOPTIONS IN (1, 2)))
  SET req2->printcpt4codes = 1
 ELSE
  SET req2->printcpt4codes = 0
 ENDIF
 SET req2->fromccl = 1
 IF (( $PRINTOPTIONS IN (1, 3)))
  CALL echo("PRINTING STICKY NOTES")
  SET drd_request->script_name = "bhs_ma_pvpatlist_sn"
  EXECUTE bhs_ma_pvpatlist_sn  WITH replace(request,drd_request)
 ELSEIF (( $PRINTOPTIONS IN (2, 4)))
  CALL echo("NOT PRINTING STICKY NOTES")
  SET drd_request->script_name = "bhs_ma_pvpatlist"
  EXECUTE bhs_ma_pvpatlist  WITH replace(request,drd_request)
 ELSEIF (( $PRINTOPTIONS=5))
  CALL echo("PRINTING ROUNDS REPORT")
  SET drd_request->script_name = "dab_rounds_6"
  EXECUTE dab_rounds_6  WITH replace(request,drd_request)
 ENDIF
#error
 SET script_version = "06/14/05 Adam Trahan"
END GO
