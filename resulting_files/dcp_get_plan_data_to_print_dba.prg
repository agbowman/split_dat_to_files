CREATE PROGRAM dcp_get_plan_data_to_print:dba
 DECLARE hplanqueryapp = i4 WITH noconstant(0)
 DECLARE hplanquerytask = i4 WITH noconstant(0)
 DECLARE hplanquerystep = i4 WITH noconstant(0)
 DECLARE houtcomequeryapp = i4 WITH noconstant(0)
 DECLARE houtcomequerytask = i4 WITH noconstant(0)
 DECLARE houtcomequerystep = i4 WITH noconstant(0)
 DECLARE hplanserverreply = i4 WITH noconstant(0)
 DECLARE houtcomeserverreply = i4 WITH noconstant(0)
 DECLARE high = i4 WITH noconstant(0)
 DECLARE start = i4 WITH noconstant(0)
 DECLARE stop = i4 WITH noconstant(0)
 DECLARE cscriptfailed = c1 WITH noconstant("F")
 DECLARE report_script_failure(opname=vc,opstatus=c1,targetname=vc,targetvalue=vc) = null
 EXECUTE crmrtl
 EXECUTE srvrtl
 RECORD date_temp(
   1 dt1 = dq8
 )
 RECORD outcomes(
   1 list[*]
     2 act_pw_comp_id = f8
     2 outcome_activity_id = f8
     2 phase_idx = i4
     2 comp_idx = i4
 )
 RECORD variances(
   1 list[*]
     2 event_id = f8
     2 var_idx = i4
 )
 DECLARE outcome_comp_cd = f8 WITH constant(uar_get_code_by("MEANING",16750,"RESULT OUTCO"))
 DECLARE intervention_cd = f8 WITH constant(uar_get_code_by("MEANING",30320,"INTERVENTION"))
 DECLARE interventndp_cd = f8 WITH constant(uar_get_code_by("MEANING",30320,"INTERVENTNDP"))
 DECLARE outcome_voided_cd = f8 WITH constant(uar_get_code_by("MEANING",30182,"VOID"))
 DECLARE outcome_canceled_cd = f8 WITH constant(uar_get_code_by("MEANING",30182,"CANCELED"))
 DECLARE planqueryappid = i4 WITH protect, constant(601540)
 DECLARE planquerytaskid = i4 WITH protect, constant(601540)
 DECLARE actplanqueryreqid = i4 WITH protect, constant(601543)
 DECLARE outcomequeryappid = i4 WITH protect, constant(601530)
 DECLARE outcomequerytaskid = i4 WITH protect, constant(601530)
 DECLARE outcomequeryreqid = i4 WITH protect, constant(601532)
 DECLARE create_handles(idx=i2) = i2
 DECLARE cleanup_handles(idx=i2) = i2
 DECLARE get_phases_comps_variances(idx=i2) = i4
 DECLARE unpack_phases_comps_actions(hreply=i4) = c1
 DECLARE get_outcome_results(start_idx=i2,stop_idx=i2) = i4
 DECLARE unpack_outcome_results(hreply=i4,start_idx=i2,stop_idx=i2) = c1
 DECLARE unpack_outcome_result(hresult=i4,phase_idx=i4,comp_idx=i4,label_idx=i4,result_idx=i4) = c1
 DECLARE add_variances_to_result(phase_idx=i4,comp_idx=i4,label_idx=i4,result_idx=i4) = c1
 DECLARE unpack_variances(hreply=i4) = c1
 DECLARE check_server_reply_status(hreply=i4,servername=vc) = i2
 DECLARE unpack_log_info(hreply=i4) = c1
 SET reply->status_data.status = "S"
 IF (create_handles(0))
  SET hplanserverreply = get_phases_comps_variances(0)
  IF (check_server_reply_status(hplanserverreply,nullterm(" DCP Query Plans Server")))
   CALL unpack_phases_comps_actions(hplanserverreply)
   CALL unpack_log_info(hplanserverreply)
  ELSE
   GO TO exit_script
  ENDIF
  SET start = 1
  SET high = value(size(outcomes->list,5))
  IF (high <= 0)
   GO TO exit_script
  ELSEIF (high <= 10)
   SET stop = high
  ELSE
   SET stop = 10
  ENDIF
  WHILE (start <= stop)
    SET iret = uar_crmbeginapp(outcomequeryappid,houtcomequeryapp)
    IF (iret != 0)
     CALL echo(build2("uar_crm_begin_app failed for appId = ",build(outcomequeryappid)))
     CALL report_script_failure("EXECUTE","F","DCP_GET_PLAN_DATA_TO_PRINT",build2(
       "Failed to create application handle for appId = ",build(outcomequeryappid)))
     GO TO exit_script
    ENDIF
    SET iret = uar_crmbegintask(houtcomequeryapp,outcomequerytaskid,houtcomequerytask)
    IF (iret != 0)
     CALL echo(build2("uar_crm_begin_task failed for taskId = ",build(outcomequerytaskid)))
     CALL report_script_failure("EXECUTE","F","DCP_GET_PLAN_DATA_TO_PRINT",build2(
       "Failed to create task handle for taskId = ",build(outcomequerytaskid)))
     GO TO exit_script
    ENDIF
    SET iret = uar_crmbeginreq(houtcomequerytask,"",outcomequeryreqid,houtcomequerystep)
    IF (iret != 0)
     CALL echo(build2("uar_crm_begin_Request failed for reqId = ",build(outcomequeryreqid)))
     CALL report_script_failure("EXECUTE","F","DCP_GET_PLAN_DATA_TO_PRINT",build2(
       "Failed to create request handle for reqId = ",build(outcomequeryreqid)))
     GO TO exit_script
    ENDIF
    SET houtcomeserverreply = get_outcome_results(start,stop)
    IF (check_server_reply_status(houtcomeserverreply,nullterm(" DCP Query Outcome Server")))
     IF (uar_srvgetitemcount(houtcomeserverreply,"variances") > 0)
      CALL unpack_variances(houtcomeserverreply)
     ENDIF
     CALL unpack_outcome_results(houtcomeserverreply,start,stop)
    ELSE
     GO TO exit_script
    ENDIF
    SET start = (stop+ 1)
    IF ((high <= (stop+ 10)))
     SET stop = high
    ELSE
     SET stop = (stop+ 10)
    ENDIF
    SET houtcomeserverreply = 0
    IF (houtcomequerystep)
     CALL uar_crmendreq(houtcomequerystep)
    ENDIF
    IF (houtcomequerytask)
     CALL uar_crmendtask(houtcomequerytask)
    ENDIF
    IF (houtcomequeryapp)
     CALL uar_crmendapp(houtcomequeryapp)
    ENDIF
  ENDWHILE
 ELSE
  GO TO exit_script
 ENDIF
#exit_script
 CALL cleanup_handles(0)
 IF (cscriptfailed="T")
  SET reply->status_data.status = "F"
 ENDIF
 SUBROUTINE get_phases_comps_variances(idx)
   DECLARE hrequest = i4 WITH private, noconstant(0)
   DECLARE hreply = i4 WITH private, noconstant(0)
   DECLARE hexceptionlist = i4 WITH private, noconstant(0)
   DECLARE ncurrentitem = i4 WITH private, noconstant(0)
   DECLARE plan_type_include_list_cnt = i4 WITH private, constant(value(size(request->
      plantypeincludelist,5)))
   DECLARE plan_type_exclude_list_cnt = i4 WITH private, constant(value(size(request->
      plantypeexcludelist,5)))
   SET hrequest = uar_crmgetrequest(hplanquerystep)
   IF (hrequest)
    SET srvstat = uar_srvsetdouble(hrequest,"personId",request->person_id)
    SET srvstat = uar_srvsetdouble(hrequest,"encntrId",request->encntr_id)
    SET srvstat = uar_srvsetstring(hrequest,"queryMode",request->querymode)
    FOR (ncurrentitem = 1 TO plan_type_include_list_cnt)
     SET hexceptionlist = uar_srvadditem(hrequest,"planTypeIncludeList")
     IF (hexceptionlist)
      SET srvstat = uar_srvsetdouble(hexceptionlist,"pathway_type_cd",request->plantypeincludelist[
       ncurrentitem].pathway_type_cd)
     ENDIF
    ENDFOR
    FOR (ncurrentitem = 1 TO plan_type_exclude_list_cnt)
     SET hexceptionlist = uar_srvadditem(hrequest,"planTypeExcludeList")
     IF (hexceptionlist)
      SET srvstat = uar_srvsetdouble(hexceptionlist,"pathway_type_cd",request->plantypeexcludelist[
       ncurrentitem].pathway_type_cd)
     ENDIF
    ENDFOR
   ENDIF
   IF (debug=1)
    CALL echo(build2("Request ",build(actplanqueryreqid)," (Step_QueryActPhaseList)"))
    SET test = uar_oen_dump_object(hrequest)
   ENDIF
   SET iret = uar_crmperform(hplanquerystep)
   SET hreply = uar_crmgetreply(hplanquerystep)
   IF (debug=1)
    CALL echo(build2("Reply ",build(actplanqueryreqid)," (Step_QueryActPhaseList)"))
    SET test = uar_oen_dump_object(hreply)
   ENDIF
   RETURN(hreply)
 END ;Subroutine
 SUBROUTINE create_handles(idx)
   SET iret = uar_crmbeginapp(planqueryappid,hplanqueryapp)
   IF (iret != 0)
    CALL echo(build2("uar_crm_begin_app failed for appId = ",build(planqueryappid)))
    CALL report_script_failure("EXECUTE","F","DCP_GET_PLAN_DATA_TO_PRINT",build2(
      "Failed to create application handle for appId = ",build(planqueryappid)))
    RETURN(0)
   ENDIF
   SET iret = uar_crmbegintask(hplanqueryapp,planquerytaskid,hplanquerytask)
   IF (iret != 0)
    CALL echo(build2("uar_crm_begin_task failed for taskId = ",build(planquerytaskid)))
    CALL report_script_failure("EXECUTE","F","DCP_GET_PLAN_DATA_TO_PRINT",build2(
      "Failed to create task handle for taskId = ",build(planquerytaskid)))
    RETURN(0)
   ENDIF
   SET iret = uar_crmbeginreq(hplanquerytask,"",actplanqueryreqid,hplanquerystep)
   IF (iret != 0)
    CALL echo(build2("uar_crm_begin_Request failed for reqId = ",build(actplanqueryreqid)))
    CALL report_script_failure("EXECUTE","F","DCP_GET_PLAN_DATA_TO_PRINT",build2(
      "Failed to create request handle for reqId = ",build(actplanqueryreqid)))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE cleanup_handles(idx)
   IF (hplanquerystep)
    CALL uar_crmendreq(hplanquerystep)
   ENDIF
   IF (hplanquerytask)
    CALL uar_crmendtask(hplanquerytask)
   ENDIF
   IF (hplanqueryapp)
    CALL uar_crmendapp(hplanqueryapp)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE check_server_reply_status(hreply,servername)
   IF (hreply <= 0)
    RETURN(0)
   ENDIF
   DECLARE istatus = i2 WITH protect, noconstant(0)
   DECLARE hstatus = i4 WITH protect, noconstant(0)
   DECLARE status = c1 WITH protect, noconstant("F")
   DECLARE errmsg = vc WITH protect, noconstant(fillstring(100," "))
   IF (hreply)
    SET hstatus = uar_srvgetstruct(hreply,"status_data")
    IF (hstatus)
     SET status = uar_srvgetstringptr(hstatus,"status")
    ENDIF
    IF (status="S")
     SET istatus = 1
    ELSE
     SET errormsg = build2("Call to ",servername," failed.  Please, check server status in SCP.")
     CALL report_script_failure("EXECUTE","F","DCP_GET_PLAN_DATA_TO_PRINT",trim(errormsg))
    ENDIF
   ENDIF
   RETURN(istatus)
 END ;Subroutine
 SUBROUTINE unpack_log_info(hreply)
   DECLARE loginfocnt = i4 WITH protect, constant(uar_srvgetitemcount(hreply,"log_info"))
   DECLARE hloginfo = i4 WITH protect, noconstant(0)
   SET stat = alterlist(data->log_info,loginfocnt)
   FOR (i = 1 TO loginfocnt)
     SET hloginfo = uar_srvgetitem(hreply,"log_info",(i - 1))
     SET data->log_info[i].log_level = uar_srvgetshort(hloginfo,"log_level")
     SET data->log_info[i].log_message = uar_srvgetstringptr(hloginfo,"log_message")
   ENDFOR
   RETURN("S")
 END ;Subroutine
 SUBROUTINE unpack_phases_comps_actions(hreply)
   DECLARE phasecnt = i4 WITH protect, constant(uar_srvgetitemcount(hreply,"phases"))
   DECLARE compcnt = i4 WITH protect, noconstant(0)
   DECLARE outcnt = i4 WITH protect, noconstant(0)
   DECLARE actcnt = i4 WITH protect, noconstant(0)
   DECLARE hphase = i4 WITH protect, noconstant(0)
   DECLARE hcomp = i4 WITH protect, noconstant(0)
   DECLARE haction = i4 WITH protect, noconstant(0)
   SET stat = alterlist(data->phases,phasecnt)
   FOR (i = 1 TO phasecnt)
     SET hphase = uar_srvgetitem(hreply,"phases",(i - 1))
     SET data->phases[i].pw_group_nbr = uar_srvgetdouble(hphase,"pw_group_nbr")
     SET data->phases[i].pw_type_mean = uar_srvgetstringptr(hphase,"pw_type_mean")
     SET data->phases[i].pw_group_desc = uar_srvgetstringptr(hphase,"pw_group_desc")
     SET stat = uar_srvgetdate2(hphase,"pw_start_dt_tm",date_temp)
     SET data->phases[i].pw_start_dt_tm = cnvtdatetime(date_temp->dt1)
     SET data->phases[i].pw_start_tz = uar_srvgetlong(hphase,"pw_start_tz")
     SET data->phases[i].pathway_id = uar_srvgetdouble(hphase,"pathway_id")
     SET data->phases[i].pw_status_cd = uar_srvgetdouble(hphase,"pw_status_cd")
     SET data->phases[i].description = uar_srvgetstringptr(hphase,"description")
     SET data->phases[i].type_mean = uar_srvgetstringptr(hphase,"type_mean")
     SET stat = uar_srvgetdate2(hphase,"start_dt_tm",date_temp)
     SET data->phases[i].start_dt_tm = cnvtdatetime(date_temp->dt1)
     SET data->phases[i].start_tz = uar_srvgetlong(hphase,"start_tz")
     SET stat = uar_srvgetdate2(hphase,"calc_end_dt_tm",date_temp)
     SET data->phases[i].calc_end_dt_tm = cnvtdatetime(date_temp->dt1)
     SET data->phases[i].calc_end_tz = uar_srvgetlong(hphase,"calc_end_tz")
     SET stat = uar_srvgetdate2(hphase,"order_dt_tm",date_temp)
     SET data->phases[i].order_dt_tm = cnvtdatetime(date_temp->dt1)
     SET data->phases[i].order_tz = uar_srvgetlong(hphase,"order_tz")
     SET data->phases[i].sequence = uar_srvgetlong(hphase,"sequence")
     SET data->phases[i].parent_phase_desc = uar_srvgetstringptr(hphase,"parent_phase_desc")
     SET data->phases[i].treatment_schedule_desc = uar_srvgetstringptr(hphase,
      "treatment_schedule_desc")
     SET compcnt = uar_srvgetitemcount(hphase,"comps")
     SET stat = alterlist(data->phases[i].comps,compcnt)
     FOR (j = 1 TO compcnt)
       SET hcomp = uar_srvgetitem(hphase,"comps",(j - 1))
       SET data->phases[i].comps[j].act_pw_comp_id = uar_srvgetdouble(hcomp,"act_pw_comp_id")
       SET data->phases[i].comps[j].dcp_clin_cat_cd = uar_srvgetdouble(hcomp,"dcp_clin_cat_cd")
       SET data->phases[i].comps[j].dcp_clin_sub_cat_cd = uar_srvgetdouble(hcomp,
        "dcp_clin_sub_cat_cd")
       SET data->phases[i].comps[j].comp_type_cd = uar_srvgetdouble(hcomp,"comp_type_cd")
       SET data->phases[i].comps[j].comp_status_cd = uar_srvgetdouble(hcomp,"comp_status_cd")
       SET data->phases[i].comps[j].sequence = uar_srvgetlong(hcomp,"sequence")
       SET data->phases[i].comps[j].linked_to_tf_ind = uar_srvgetshort(hcomp,"linked_to_tf_ind")
       SET data->phases[i].comps[j].parent_entity_id = uar_srvgetdouble(hcomp,"parent_entity_id")
       SET data->phases[i].comps[j].outcome_description = uar_srvgetstringptr(hcomp,
        "outcome_description")
       SET data->phases[i].comps[j].outcome_expectation = uar_srvgetstringptr(hcomp,
        "outcome_expectation")
       SET data->phases[i].comps[j].outcome_type_cd = uar_srvgetdouble(hcomp,"outcome_type_cd")
       IF ((data->phases[i].comps[j].outcome_type_cd != intervention_cd)
        AND (data->phases[i].comps[j].outcome_type_cd != interventndp_cd))
        SET data->phases[i].comps[j].sort_idx = 0
       ELSE
        SET data->phases[i].comps[j].sort_idx = 1
       ENDIF
       SET data->phases[i].comps[j].outcome_status_cd = uar_srvgetdouble(hcomp,"outcome_status_cd")
       SET data->phases[i].comps[j].target_type_cd = uar_srvgetdouble(hcomp,"target_type_cd")
       SET stat = uar_srvgetdate2(hcomp,"outcome_start_dt_tm",date_temp)
       SET data->phases[i].comps[j].outcome_start_dt_tm = cnvtdatetime(date_temp->dt1)
       SET data->phases[i].comps[j].outcome_start_tz = uar_srvgetlong(hcomp,"outcome_start_tz")
       SET stat = uar_srvgetdate2(hcomp,"outcome_end_dt_tm",date_temp)
       SET data->phases[i].comps[j].outcome_end_dt_tm = cnvtdatetime(date_temp->dt1)
       SET data->phases[i].comps[j].outcome_end_tz = uar_srvgetlong(hcomp,"outcome_end_tz")
       IF ((data->phases[i].comps[j].comp_type_cd=outcome_comp_cd)
        AND (data->phases[i].comps[j].parent_entity_id > 0)
        AND (data->phases[i].comps[j].outcome_status_cd > 0)
        AND (data->phases[i].comps[j].outcome_status_cd != outcome_voided_cd)
        AND (data->phases[i].comps[j].outcome_status_cd != outcome_canceled_cd))
        SET data->phases[i].comps[j].outcome_valid_flag = 1
        SET outcnt = (outcnt+ 1)
        IF (outcnt > value(size(outcomes->list,5)))
         SET stat = alterlist(outcomes->list,(outcnt+ 50))
        ENDIF
        SET outcomes->list[outcnt].act_pw_comp_id = data->phases[i].comps[j].act_pw_comp_id
        SET outcomes->list[outcnt].outcome_activity_id = data->phases[i].comps[j].parent_entity_id
        SET outcomes->list[outcnt].phase_idx = i
        SET outcomes->list[outcnt].comp_idx = j
       ELSE
        SET data->phases[i].comps[j].outcome_valid_flag = 0
       ENDIF
     ENDFOR
     SET actcnt = uar_srvgetitemcount(hphase,"actions")
     SET stat = alterlist(data->phases[i].actions,actcnt)
     FOR (k = 1 TO actcnt)
       SET haction = uar_srvgetitem(hphase,"actions",(k - 1))
       SET data->phases[i].actions[k].action_type_cd = uar_srvgetdouble(haction,"action_type_cd")
       SET stat = uar_srvgetdate2(haction,"action_dt_tm",date_temp)
       SET data->phases[i].actions[k].action_dt_tm = cnvtdatetime(date_temp->dt1)
       SET data->phases[i].actions[k].action_tz = uar_srvgetlong(haction,"action_tz")
       SET data->phases[i].actions[k].action_prsnl_id = uar_srvgetdouble(haction,"action_prsnl_id")
       SET data->phases[i].actions[k].action_prsnl_disp = uar_srvgetstringptr(haction,
        "action_prsnl_disp")
       SET data->phases[i].actions[k].pw_action_seq = uar_srvgetlong(haction,"pw_action_seq")
       SET data->phases[i].actions[k].pw_status_cd = uar_srvgetdouble(haction,"pw_status_cd")
     ENDFOR
   ENDFOR
   SET stat = alterlist(outcomes->list,outcnt)
   RETURN("S")
 END ;Subroutine
 SUBROUTINE get_outcome_results(start_idx,stop_idx)
   DECLARE hrequest = i4 WITH private, noconstant(0)
   DECLARE hreply = i4 WITH private, noconstant(0)
   DECLARE hitem = i4 WITH private, noconstant(0)
   SET hrequest = uar_crmgetrequest(houtcomequerystep)
   IF (hrequest)
    SET srvstat = uar_srvsetdouble(hrequest,"personId",request->person_id)
    FOR (i = start_idx TO stop_idx)
     SET hitem = uar_srvadditem(hrequest,"outcomeIdList")
     IF (hitem)
      SET srvstat = uar_srvsetdouble(hitem,"outcomeActId",outcomes->list[i].outcome_activity_id)
     ENDIF
    ENDFOR
    SET srvstat = uar_srvsetshort(hrequest,"loadActiveVarianceInd",1)
    SET srvstat = uar_srvsetshort(hrequest,"loadInactiveVarianceInd",1)
   ENDIF
   IF (debug=1)
    CALL echo(build2("Request ",build(outcomequeryreqid)," (dcp_s",build(outcomequeryreqid),")"))
    SET test = uar_oen_dump_object(hrequest)
   ENDIF
   SET iret = uar_crmperform(houtcomequerystep)
   SET hreply = uar_crmgetreply(houtcomequerystep)
   IF (debug=1)
    CALL echo(build2("Reply ",build(outcomequeryreqid)," (dcp_s",build(outcomequeryreqid),")"))
    SET test = uar_oen_dump_object(hreply)
   ENDIF
   RETURN(hreply)
 END ;Subroutine
 SUBROUTINE unpack_outcome_results(hreply,start_idx,stop_idx)
   DECLARE outcnt = i4 WITH private, constant(uar_srvgetitemcount(hreply,"outcomes"))
   DECLARE rescnt = i4 WITH private, noconstant(0)
   DECLARE houtcome = i4 WITH private, noconstant(0)
   DECLARE hresult = i4 WITH private, noconstant(0)
   DECLARE idx = i4 WITH private, noconstant(0)
   DECLARE pidx = i4 WITH private, noconstant(0)
   DECLARE cidx = i4 WITH private, noconstant(0)
   DECLARE outcomeactid = f8 WITH private, noconstant(0.0)
   DECLARE ddynamiclabelid = f8 WITH private, noconstant(0.0)
   DECLARE slabelname = vc WITH private
   DECLARE nnum = i4 WITH private, noconstant(0)
   DECLARE nlabelcnt = i4 WITH private, noconstant(0)
   DECLARE lidx = i4 WITH private, noconstant(0)
   DECLARE ridx = i4 WITH private, noconstant(0)
   FOR (i = 1 TO outcnt)
     SET houtcome = uar_srvgetitem(hreply,"outcomes",(i - 1))
     SET outcomeactid = uar_srvgetdouble(houtcome,"outcomeActId")
     SET idx = locateval(idx,start_idx,stop_idx,outcomeactid,outcomes->list[idx].outcome_activity_id)
     SET pidx = outcomes->list[idx].phase_idx
     SET cidx = outcomes->list[idx].comp_idx
     SET data->phases[pidx].comps[cidx].nomen_string_flag = uar_srvgetshort(houtcome,
      "nomenStringFlag")
     SET rescnt = uar_srvgetitemcount(houtcome,"results")
     SET nlabelcnt = 1
     SET stat = alterlist(data->phases[pidx].comps[cidx].labels,nlabelcnt)
     FOR (j = 1 TO rescnt)
       SET hresult = uar_srvgetitem(houtcome,"results",(j - 1))
       SET dcedynamiclabelid = uar_srvgetdouble(hresult,"ceDynamicLabelId")
       SET slabelname = uar_srvgetstringptr(hresult,"labelName")
       SET lidx = 0
       SET ridx = 0
       IF (nlabelcnt > 0)
        SET nnum = 0
        SET lidx = locateval(nnum,1,nlabelcnt,dcedynamiclabelid,data->phases[pidx].comps[cidx].
         labels[nnum].ce_dynamic_label_id)
       ENDIF
       IF (lidx <= 0)
        SET nlabelcnt = (nlabelcnt+ 1)
        SET stat = alterlist(data->phases[pidx].comps[cidx].labels,nlabelcnt)
        SET lidx = nlabelcnt
        SET data->phases[pidx].comps[cidx].labels[lidx].ce_dynamic_label_id = dcedynamiclabelid
        SET data->phases[pidx].comps[cidx].labels[lidx].label_name = slabelname
       ENDIF
       SET ridx = size(data->phases[pidx].comps[cidx].labels[lidx].results,5)
       SET ridx = (ridx+ 1)
       SET stat = alterlist(data->phases[pidx].comps[cidx].labels[lidx].results,ridx)
       IF (unpack_outcome_result(hresult,pidx,cidx,lidx,ridx)="S")
        CALL add_variances_to_result(pidx,cidx,lidx,ridx)
       ENDIF
     ENDFOR
   ENDFOR
   RETURN("S")
 END ;Subroutine
 SUBROUTINE unpack_outcome_result(hresult,phase_idx,comp_idx,label_idx,result_idx)
   IF (((hreply <= 0) OR (((phase_idx <= 0) OR (((comp_idx <= 0) OR (((label_idx <= 0) OR (result_idx
    <= 0)) )) )) )) )
    RETURN("F")
   ENDIF
   IF (phase_idx > value(size(data->phases,5)))
    RETURN("F")
   ELSEIF (comp_idx > value(size(data->phases[phase_idx].comps,5)))
    RETURN("F")
   ELSEIF (label_idx > value(size(data->phases[phase_idx].comps[comp_idx].labels,5)))
    RETURN("F")
   ELSEIF (result_idx > value(size(data->phases[phase_idx].comps[comp_idx].labels[label_idx].results,
     5)))
    RETURN("F")
   ENDIF
   SET data->phases[phase_idx].comps[comp_idx].labels[label_idx].results[result_idx].met_ind =
   uar_srvgetshort(hresult,"metInd")
   SET data->phases[phase_idx].comps[comp_idx].labels[label_idx].results[result_idx].event_id =
   uar_srvgetdouble(hresult,"eventId")
   SET stat = uar_srvgetdate2(hresult,"eventEndDtTm",date_temp)
   SET data->phases[phase_idx].comps[comp_idx].labels[label_idx].results[result_idx].event_end_dt_tm
    = cnvtdatetime(date_temp->dt1)
   SET data->phases[phase_idx].comps[comp_idx].labels[label_idx].results[result_idx].event_end_tz =
   uar_srvgetlong(hresult,"eventEndTZ")
   SET data->phases[phase_idx].comps[comp_idx].labels[label_idx].results[result_idx].result_val =
   uar_srvgetstringptr(hresult,"resultVal")
   SET data->phases[phase_idx].comps[comp_idx].labels[label_idx].results[result_idx].
   result_units_disp = uar_srvgetstringptr(hresult,"resultUnitsDisp")
   SET stat = uar_srvgetdate2(hresult,"performDtTm",date_temp)
   SET data->phases[phase_idx].comps[comp_idx].labels[label_idx].results[result_idx].perform_dt_tm =
   cnvtdatetime(date_temp->dt1)
   SET data->phases[phase_idx].comps[comp_idx].labels[label_idx].results[result_idx].perform_tz =
   uar_srvgetlong(hresult,"performTZ")
   SET data->phases[phase_idx].comps[comp_idx].labels[label_idx].results[result_idx].
   perform_prsnl_name = uar_srvgetstringptr(hresult,"performPrsnlName")
   SET data->phases[phase_idx].comps[comp_idx].labels[label_idx].results[result_idx].
   preferred_nomen_disp = uar_srvgetstringptr(hresult,"preferredNomenDisp")
   SET data->phases[phase_idx].comps[comp_idx].labels[label_idx].results[result_idx].
   nomen_string_flag = uar_srvgetshort(hresult,"nomenStringFlag")
   RETURN("S")
 END ;Subroutine
 SUBROUTINE add_variances_to_result(phase_idx,comp_idx,label_idx,result_idx)
   IF (((phase_idx <= 0) OR (((comp_idx <= 0) OR (((label_idx <= 0) OR (result_idx <= 0)) )) )) )
    RETURN("F")
   ENDIF
   IF (phase_idx > value(size(data->phases,5)))
    RETURN("F")
   ELSEIF (comp_idx > value(size(data->phases[phase_idx].comps,5)))
    RETURN("F")
   ELSEIF (label_idx > value(size(data->phases[phase_idx].comps[comp_idx].labels,5)))
    RETURN("F")
   ELSEIF (result_idx > value(size(data->phases[phase_idx].comps[comp_idx].labels[label_idx].results,
     5)))
    RETURN("F")
   ENDIF
   DECLARE idx = i4 WITH private, noconstant(0)
   DECLARE num = i4 WITH private, noconstant(0)
   DECLARE resultvarianceidx = i4 WITH private, noconstant(0)
   DECLARE variance_count = i4 WITH private, constant(value(size(data->variances,5)))
   DECLARE dpathwayid = f8 WITH private, noconstant(0.0)
   DECLARE dactpwcompid = f8 WITH private, noconstant(0.0)
   DECLARE deventid = f8 WITH private, noconstant(0.0)
   SET dpathwayid = data->phases[phase_idx].pathway_id
   SET dactpwcompid = data->phases[phase_idx].comps[comp_idx].act_pw_comp_id
   SET deventid = data->phases[phase_idx].comps[comp_idx].labels[label_idx].results[result_idx].
   event_id
   SET resultvarianceidx = size(data->phases[phase_idx].comps[comp_idx].labels[label_idx].results[
    result_idx].variances,5)
   SET idx = locateval(num,1,variance_count,dpathwayid,data->variances[num].pathway_id,
    dactpwcompid,data->variances[num].parent_entity_id,deventid,data->variances[num].event_id)
   WHILE (idx > 0)
     SET resultvarianceidx = (resultvarianceidx+ 1)
     SET stat = alterlist(data->phases[phase_idx].comps[comp_idx].labels[label_idx].results[
      result_idx].variances,resultvarianceidx)
     SET data->phases[phase_idx].comps[comp_idx].labels[label_idx].results[result_idx].variances[
     resultvarianceidx].variance_idx = idx
     SET data->phases[phase_idx].comps[comp_idx].labels[label_idx].results[result_idx].variances[
     resultvarianceidx].variance_reltn_id = data->variances[idx].variance_reltn_id
     IF (idx < variance_count)
      SET idx = locateval(num,(idx+ 1),variance_count,dpathwayid,data->variances[num].pathway_id,
       dactpwcompid,data->variances[num].parent_entity_id,deventid,data->variances[num].event_id)
     ELSE
      SET idx = 0
     ENDIF
   ENDWHILE
   RETURN("S")
 END ;Subroutine
 SUBROUTINE unpack_variances(hreply)
   IF (hreply <= 0)
    RETURN("F")
   ENDIF
   DECLARE variance_size = i4 WITH private, constant(value(size(data->variances,5)))
   DECLARE variance_count = i4 WITH private, constant(uar_srvgetitemcount(hreply,"variances"))
   DECLARE hvariance = i4 WITH private, noconstant(0)
   DECLARE num = i4 WITH private, noconstant(0)
   DECLARE idx = i4 WITH private, noconstant(0)
   DECLARE failedcnt = i4 WITH private, noconstant(0)
   DECLARE i = i4 WITH private, noconstant(0)
   DECLARE dvariancereltnid = f8 WITH private, noconstant(0.0)
   IF (variance_count > 0)
    SET stat = alterlist(data->variances,(variance_size+ variance_count))
   ENDIF
   SET idx = variance_size
   FOR (i = 1 TO variance_count)
     SET hvariance = uar_srvgetitem(hreply,"variances",(i - 1))
     SET dvariancereltnid = uar_srvgetdouble(hvariance,"variance_reltn_id")
     IF (locateval(num,1,(variance_count+ variance_size),dvariancereltnid,data->variances[num].
      variance_reltn_id)=0)
      SET idx = (idx+ 1)
      SET data->variances[idx].variance_reltn_id = uar_srvgetdouble(hvariance,"variance_reltn_id")
      SET data->variances[idx].parent_entity_id = uar_srvgetdouble(hvariance,"parent_entity_id")
      SET data->variances[idx].pathway_id = uar_srvgetdouble(hvariance,"pathway_id")
      SET data->variances[idx].event_id = uar_srvgetdouble(hvariance,"event_id")
      SET data->variances[idx].variance_type_cd = uar_srvgetdouble(hvariance,"variance_type_cd")
      SET data->variances[idx].active_ind = uar_srvgetshort(hvariance,"active_ind")
      SET data->variances[idx].action_cd = uar_srvgetdouble(hvariance,"action_cd")
      SET data->variances[idx].action_text = uar_srvgetstringptr(hvariance,"action_text")
      SET data->variances[idx].reason_cd = uar_srvgetdouble(hvariance,"reason_cd")
      SET data->variances[idx].reason_text = uar_srvgetstringptr(hvariance,"reason_text")
      SET data->variances[idx].note_text = uar_srvgetstringptr(hvariance,"note_text")
      SET data->variances[idx].chart_prsnl_name = uar_srvgetstringptr(hvariance,"chart_prsnl_name")
      SET stat = uar_srvgetdate2(hvariance,"chart_dt_tm",date_temp)
      SET data->variances[idx].chart_dt_tm = cnvtdatetime(date_temp->dt1)
      SET data->variances[idx].chart_tz = uar_srvgetlong(hvariance,"chart_tz")
      SET data->variances[idx].unchart_prsnl_name = uar_srvgetstringptr(hvariance,
       "unchart_prsnl_name")
      SET stat = uar_srvgetdate2(hvariance,"unchart_dt_tm",date_temp)
      SET data->variances[idx].unchart_dt_tm = cnvtdatetime(date_temp->dt1)
      SET data->variances[idx].unchart_tz = uar_srvgetlong(hvariance,"unchart_tz")
     ELSE
      SET failedcnt = (failedcnt+ 1)
     ENDIF
   ENDFOR
   IF (failedcnt > 0)
    SET stat = alterlist(data->variances,((variance_size+ variance_count) - failedcnt))
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE report_script_failure(opname,opstatus,targetname,targetvalue)
   DECLARE cnt = i4 WITH protect, noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
   SET cscriptfailed = "T"
   SET cnt = size(reply->status_data.subeventstatus,5)
   IF (((cnt != 1) OR (cnt=1
    AND (reply->status_data.subeventstatus[1].operationstatus != null))) )
    SET cnt = (cnt+ 1)
    SET stat = alter(reply->status_data.subeventstatus,value(cnt))
   ENDIF
   SET reply->status_data.subeventstatus[cnt].operationname = trim(opname)
   SET reply->status_data.subeventstatus[cnt].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[cnt].targetobjectname = trim(targetname)
   SET reply->status_data.subeventstatus[cnt].targetobjectvalue = trim(targetvalue)
 END ;Subroutine
END GO
