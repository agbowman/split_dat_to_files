CREATE PROGRAM bhs_mp_wklist_print_drvr:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select Care Team:" = 0,
  "Patient List" = "",
  "Select encounters to print:" = 0,
  "Select report type:" = ""
  WITH outdev, f_care_team_id, patlist,
  f_rpt_encs, s_rpt_type
 FREE RECORD print_options
 RECORD print_options(
   1 cust_print_ccl = vc
   1 cust_print_fe = vc
   1 list_name = vc
   1 logical_domain_id = f8
   1 print_style = vc
   1 user_context
     2 user_id = f8
     2 position_cd = f8
     2 username = vc
   1 qual[*]
     2 person_id = f8
     2 encntr_id = f8
     2 ppr_cd = f8
     2 pat_age = vc
     2 care_team_id = f8
 ) WITH protect
 DECLARE jsontxt = vc
 DECLARE ml_loop = i4 WITH protect, noconstant(0)
 DECLARE ml_pcnt = i4 WITH protect, noconstant(0)
 DECLARE mf_care_team_id = f8 WITH protect, noconstant( $F_CARE_TEAM_ID)
 DECLARE ml_ndx = i4 WITH protect, noconstant(0)
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 FREE RECORD dgapl_request
 RECORD dgapl_request(
   1 prsnl_id = f8
 )
 SET dgapl_request->prsnl_id = reqinfo->updt_id
 FREE RECORD dgapl_reply
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
 SET request->patient_list_id = dgapl_reply->patient_lists[selection].patient_list_id
 SET request->patient_list_type_cd = dgapl_reply->patient_lists[selection].patient_list_type_cd
 SET num_arguments = size(dgapl_reply->patient_lists[selection].arguments,5)
 SET stat = alterlist(request->arguments,num_arguments)
 FOR (i = 1 TO num_arguments)
   SET request->arguments[i].argument_name = dgapl_reply->patient_lists[selection].arguments[i].
   argument_name
   SET request->arguments[i].argument_value = dgapl_reply->patient_lists[selection].arguments[i].
   argument_value
   SET request->arguments[i].parent_entity_name = dgapl_reply->patient_lists[selection].arguments[i].
   parent_entity_name
   SET request->arguments[i].parent_entity_id = dgapl_reply->patient_lists[selection].arguments[i].
   parent_entity_id
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
 DECLARE begin_time = f8 WITH noconstant(cnvtdatetime(sysdate))
 DECLARE finish_time = f8 WITH noconstant(cnvtdatetime(sysdate))
 DECLARE pagebreak = vc WITH noconstant(" "), public
 CALL echo(build("ListType:",listtype))
 SET ccldminfo->sec_org_reltn = 0
 SET ccldminfo->sec_confid = 0
 CASE (listtype)
  OF "CUSTOM":
   EXECUTE dcp_get_pl_custom  WITH replace(reply,dgp_reply)
  OF "CARETEAM":
   EXECUTE bhs_dcp_get_pl_careteam2
  OF "LOCATION":
   SET ml_ndx = 0
   SELECT DISTINCT INTO "nl:"
    e.encntr_id
    FROM encntr_domain ed,
     encounter e
    PLAN (ed
     WHERE ed.end_effective_dt_tm > cnvtdatetime(curdate,curtime)
      AND expand(ml_ndx,1,size(request->arguments,5),ed.loc_nurse_unit_cd,request->arguments[ml_ndx].
      parent_entity_id))
     JOIN (e
     WHERE ed.encntr_id=e.encntr_id)
    ORDER BY e.encntr_id
    HEAD REPORT
     ml_cnt = 0
    DETAIL
     ml_cnt += 1, stat = alterlist(dgp_reply->patients,ml_cnt), dgp_reply->patients[ml_cnt].encntr_id
      = e.encntr_id
    WITH nocounter
   ;end select
  OF "LOCATIONGRP":
   EXECUTE dcp_get_pl_location_grp  WITH replace(reply,dgp_reply)
  OF "VRELTN":
   EXECUTE dcp_get_pl_visit_reltn  WITH replace(reply,dgp_reply)
  OF "LRELTN":
   EXECUTE dcp_get_pl_lifetime_reltn  WITH replace(reply,dgp_reply)
  OF "PROVIDERGRP":
   EXECUTE dcp_get_pl_provider_group  WITH replace(reply,dgp_reply)
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
  ELSE
   GO TO error
 ENDCASE
 SET print_options->list_name = dgapl_reply->patient_lists[selection].name
 SELECT INTO "nl:"
  FROM prsnl pr
  PLAN (pr
   WHERE (pr.person_id=reqinfo->updt_id))
  HEAD REPORT
   print_options->user_context.user_id = pr.person_id, print_options->user_context.position_cd = pr
   .position_cd, print_options->user_context.username = build(pr.username)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM encounter e
  PLAN (e
   WHERE (e.encntr_id= $F_RPT_ENCS))
  HEAD REPORT
   ml_pcnt = 0
  DETAIL
   ml_pcnt += 1, p0 = alterlist(print_options->qual,ml_pcnt), print_options->qual[ml_pcnt].
   care_team_id = mf_care_team_id,
   print_options->qual[ml_pcnt].encntr_id = e.encntr_id
  WITH nocounter
 ;end select
 CASE ( $S_RPT_TYPE)
  OF "Resident":
   SET print_options->cust_print_ccl = "bhs_mp_wklist_cust_print"
  OF "OB":
   SET print_options->cust_print_ccl = "bhs_mp_ob_wklist_cust_print"
 ENDCASE
 SET jsontxt = cnvtrectojson(print_options)
 CASE ( $S_RPT_TYPE)
  OF "Resident":
   EXECUTE bhs_mp_wklist_cust_print  $OUTDEV, value(jsontxt)
  OF "OB":
   EXECUTE bhs_mp_ob_wklist_cust_print  $OUTDEV, value(jsontxt)
 ENDCASE
#exit_script
END GO
