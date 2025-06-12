CREATE PROGRAM bhs_hand_over_pat_list_test:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Patient List" = "",
  "Print Options" = 0
  WITH outdev, patlist, printoptions
 FREE RECORD output
 RECORD output(
   1 name = vc
   1 room = vc
 )
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
 DECLARE begin_time = f8 WITH noconstant(cnvtdatetime(curdate,curtime3))
 DECLARE finish_time = f8 WITH noconstant(cnvtdatetime(curdate,curtime3))
 CALL echo(build("ListType:",listtype))
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
 CALL echorecord(dgp_reply)
 DECLARE prsnl = vc
 DECLARE patientlist = vc
 DECLARE todoitems = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"TODOITEMS")), protect
 SELECT INTO "NL:"
  FROM prsnl p
  WHERE (p.person_id=reqinfo->updt_id)
  DETAIL
   prsnl = trim(p.name_full_formatted,3)
  WITH nocounter
 ;end select
 SELECT
  d.name
  FROM dcp_patient_list d
  WHERE (d.patient_list_id=request->patient_list_id)
  DETAIL
   patientlist = d.name
  WITH nocounter
 ;end select
 EXECUTE reportrtl
 SET d0 = initializereport(0)
 SELECT INTO "NL:"
  p.person_id, ce.event_cd, p.name_full_formatted,
  room = uar_get_code_display(e.loc_room_cd), ce.result_val
  FROM encounter e,
   person p,
   clinical_event ce,
   (dummyt d  WITH seq = value(size(dgp_reply->patients,5)))
  PLAN (d)
   JOIN (e
   WHERE (e.encntr_id=dgp_reply->patients[d.seq].encntr_id))
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (ce
   WHERE ce.encntr_id=outerjoin(e.encntr_id)
    AND ce.event_cd=outerjoin(todoitems)
    AND ce.valid_until_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3))
    AND ce.updt_dt_tm >= outerjoin(datetimeadd(cnvtdatetime(curdate,curtime3),- (2))))
  ORDER BY p.person_id, ce.updt_dt_tm DESC
  HEAD REPORT
   d0 = headreport(rpt_render)
  HEAD PAGE
   d0 = headpage(rpt_render)
  HEAD p.person_id
   f1 = p.name_full_formatted, f2 = room, d0 = headpersonid(rpt_render)
  HEAD ce.event_cd
   f3 = ce.result_val, d0 = persondetail(rpt_render)
  WITH nocounter, format, separator = " "
 ;end select
 SET d0 = finalizereport( $OUTDEV)
END GO
