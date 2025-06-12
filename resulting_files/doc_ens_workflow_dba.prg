CREATE PROGRAM doc_ens_workflow:dba
 SUBROUTINE scdgetuniqueid(null)
   DECLARE unique_id = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    next_seq = seq(scd_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     unique_id = cnvtreal(next_seq)
    WITH format, nocounter
   ;end select
   IF (curqual=0)
    SET failed = 1
    CALL cps_add_error(cps_select,cps_script_fail,"Getting INSERT IDS",cps_select_msg,0,
     0,0)
   ENDIF
   RETURN(unique_id)
 END ;Subroutine
 SUBROUTINE scdgetuniqueactivityid(null)
   DECLARE unique_id = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    next_seq = seq(scd_act_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     unique_id = cnvtreal(next_seq)
    WITH format, nocounter
   ;end select
   IF (curqual=0)
    SET failed = 1
    CALL cps_add_error(cps_select,cps_script_fail,"Getting INSERT IDS",cps_select_msg,0,
     0,0)
   ENDIF
   RETURN(unique_id)
 END ;Subroutine
 DECLARE cps_lock = i4 WITH public, constant(100)
 DECLARE cps_no_seq = i4 WITH public, constant(101)
 DECLARE cps_updt_cnt = i4 WITH public, constant(102)
 DECLARE cps_insuf_data = i4 WITH public, constant(103)
 DECLARE cps_update = i4 WITH public, constant(104)
 DECLARE cps_insert = i4 WITH public, constant(105)
 DECLARE cps_delete = i4 WITH public, constant(106)
 DECLARE cps_select = i4 WITH public, constant(107)
 DECLARE cps_auth = i4 WITH public, constant(108)
 DECLARE cps_inval_data = i4 WITH public, constant(109)
 DECLARE cps_ens_note_story_not_locked = i4 WITH public, constant(110)
 DECLARE cps_lock_msg = c33 WITH public, constant("Failed to lock all requested rows")
 DECLARE cps_no_seq_msg = c34 WITH public, constant("Failed to get next sequence number")
 DECLARE cps_updt_cnt_msg = c28 WITH public, constant("Failed to match update count")
 DECLARE cps_insuf_data_msg = c38 WITH public, constant("Request did not supply sufficient data")
 DECLARE cps_update_msg = c24 WITH public, constant("Failed on update request")
 DECLARE cps_insert_msg = c24 WITH public, constant("Failed on insert request")
 DECLARE cps_delete_msg = c24 WITH public, constant("Failed on delete request")
 DECLARE cps_select_msg = c24 WITH public, constant("Failed on select request")
 DECLARE cps_auth_msg = c34 WITH public, constant("Failed on authorization of request")
 DECLARE cps_inval_data_msg = c35 WITH public, constant("Request contained some invalid data")
 DECLARE cps_success = i4 WITH public, constant(0)
 DECLARE cps_success_info = i4 WITH public, constant(1)
 DECLARE cps_success_warn = i4 WITH public, constant(2)
 DECLARE cps_deadlock = i4 WITH public, constant(3)
 DECLARE cps_script_fail = i4 WITH public, constant(4)
 DECLARE cps_sys_fail = i4 WITH public, constant(5)
 SUBROUTINE cps_add_error(cps_errcode,severity_level,supp_err_txt,def_msg,idx1,idx2,idx3)
   SET reply->cps_error.cnt += 1
   SET errcnt = reply->cps_error.cnt
   SET stat = alterlist(reply->cps_error.data,errcnt)
   SET reply->cps_error.data[errcnt].code = cps_errcode
   SET reply->cps_error.data[errcnt].severity_level = severity_level
   SET reply->cps_error.data[errcnt].supp_err_txt = supp_err_txt
   SET reply->cps_error.data[errcnt].def_msg = def_msg
   SET reply->cps_error.data[errcnt].row_data.lvl_1_idx = idx1
   SET reply->cps_error.data[errcnt].row_data.lvl_2_idx = idx2
   SET reply->cps_error.data[errcnt].row_data.lvl_3_idx = idx3
 END ;Subroutine
 DECLARE validaterequest(null) = null WITH protect
 DECLARE checkoneventrepstatus(null) = null WITH protect
 DECLARE processworkflow(null) = null WITH protect
 DECLARE processcomponent(icomponentidx) = null WITH protect
 DECLARE processoutput(ioutputidx) = null WITH protect
 DECLARE insertcomponent(icomponentidx) = null WITH protect
 DECLARE updatecomponent(icomponentidx,iwkfcomponentid) = null WITH protect
 DECLARE insertoutput(ioutputidx) = null WITH protect
 DECLARE updateoutput(ioutputidx) = null WITH protect
 DECLARE g_failure = c1 WITH public, noconstant("F")
 DECLARE today_dt_tm = f8 WITH protect, constant(cnvtdatetime(sysdate))
 DECLARE eno_change = i4 WITH protect, constant(1)
 DECLARE eskip = i4 WITH protect, constant(2)
 DECLARE fcomponentid = f8 WITH public, noconstant(0)
 DECLARE foutputid = f8 WITH private, noconstant(0)
 DECLARE entityid = f8 WITH public, noconstant(0)
 IF (validate(reply)=0)
  RECORD reply(
    1 component[*]
      2 wkf_component_id = f8
      2 component_concept = vc
      2 component_entity_id = f8
      2 component_reference_number = vc
    1 output[*]
      2 wkf_output_id = f8
      2 output_type_cd = f8
      2 output_entity_id = f8
      2 output_reference_number = vc
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
    1 cps_error
      2 cnt = i4
      2 data[*]
        3 code = i4
        3 severity_level = i4
        3 supp_err_txt = c32
        3 def_msg = vc
        3 row_data
          4 lvl_1_idx = i4
          4 lvl_2_idx = i4
          4 lvl_3_idx = i4
  )
 ENDIF
 IF (validate(reply->status_data.status)=0)
  CALL cps_add_error(cps_insuf_data,cps_script_fail,"reply doesn't contain status block",
   cps_insuf_data_msg,0,
   0,0)
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "F"
 CALL validaterequest(null)
 IF (g_failure="T")
  GO TO exit_script
 ENDIF
 CALL checkoneventrepstatus(null)
 IF (((g_failure="T") OR (g_failure="Z")) )
  GO TO exit_script
 ENDIF
 CALL processworkflow(null)
 IF (g_failure="T")
  GO TO exit_script
 ENDIF
 DECLARE request_component_count = i4 WITH protect, constant(size(request->component,5))
 SET stat = alterlist(reply->component,request_component_count)
 DECLARE icomponentidx = i4 WITH private, noconstant(0)
 FOR (icomponentidx = 1 TO request_component_count)
  CALL processcomponent(icomponentidx)
  IF (g_failure="T")
   GO TO exit_script
  ENDIF
 ENDFOR
 DECLARE request_output_count = i4 WITH protect, constant(size(request->output,5))
 SET stat = alterlist(reply->output,request_output_count)
 DECLARE ioutputidx = i4 WITH private, noconstant(0)
 FOR (ioutputidx = 1 TO request_output_count)
  CALL processoutput(ioutputidx)
  IF (g_failure="T")
   GO TO exit_script
  ENDIF
 ENDFOR
 SUBROUTINE validaterequest(null)
   IF (validate(request->wkf_workflow_id)=0)
    SET g_failure = "T"
    CALL cps_add_error(cps_inval_data,cps_script_fail,"ERROR: Invalid Request",
     "request->wkf_workflow_id doesn't exist",0,
     0,0)
    RETURN
   ENDIF
   IF (validate(request->component)=0)
    SET g_failure = "T"
    CALL cps_add_error(cps_inval_data,cps_script_fail,"ERROR: Invalid Request",
     "request->component doesn't exist",0,
     0,0)
    RETURN
   ENDIF
   IF (validate(request->output)=0)
    SET g_failure = "T"
    CALL cps_add_error(cps_inval_data,cps_script_fail,"ERROR: Invalid Request",
     "request->output doesn't exist",0,
     0,0)
    RETURN
   ENDIF
 END ;Subroutine
 SUBROUTINE checkoneventrepstatus(null)
   IF (validate(event_rep) != 0)
    DECLARE reply_ce_count = i4 WITH protect, constant(size(event_rep->rb_list,5))
    IF (reply_ce_count=0)
     SET g_failure = "T"
     CALL cps_add_error(cps_inval_data,cps_script_fail,"No events on the reply",cps_inval_data_msg,0,
      0,0)
     RETURN
    ENDIF
    IF ((event_rep->sb[1].statuscd != 0.0))
     SET g_failure = "T"
     CALL cps_add_error(cps_inval_data,cps_script_fail,"sb.statusCd != 0.0",cps_inval_data_msg,0,
      0,0)
     RETURN
    ELSE
     DECLARE reply_substatus_count = i4 WITH protect, constant(size(event_rep->sb.substatuslist,5))
     DECLARE idx = i2 WITH protect, noconstant(0)
     DECLARE substatuscdidx = i4 WITH protect, noconstant(0)
     SET substatuscdidx = locateval(idx,1,reply_substatus_count,eno_change,event_rep->sb[1].
      substatuslist[idx].substatuscd)
     IF (0 != substatuscdidx)
      SET g_failure = "Z"
      RETURN
     ENDIF
     SET idx = 0
     SET substatuscdidx = locateval(idx,1,reply_substatus_count,eskip,event_rep->sb[1].substatuslist[
      idx].substatuscd)
     IF (0 != substatuscdidx)
      SET g_failure = "T"
      CALL cps_add_error(cps_inval_data,cps_script_fail,"Subevent status of SKIP(2)",
       cps_inval_data_msg,0,
       0,0)
      RETURN
     ENDIF
    ENDIF
    IF ((event_rep->sb[1].severitycd > 2))
     SET g_failure = "T"
     CALL cps_add_error(cps_inval_data,cps_script_fail,"sb.severityCd > 2",cps_inval_data_msg,0,
      0,0)
     RETURN
    ENDIF
   ELSE
    SET g_failure = "T"
    CALL cps_add_error(cps_inval_data,cps_script_fail,"Failed to VALIDATE(event_rep)",
     cps_inval_data_msg,0,
     0,0)
    RETURN
   ENDIF
 END ;Subroutine
 SUBROUTINE processworkflow(null)
  IF ((request->end_dt_tm=cnvtdatetime(null)))
   UPDATE  FROM wkf_workflow w
    SET w.service_dt_tm = cnvtdatetime(request->service_dt_tm), w.service_tz = request->service_tz, w
     .updt_cnt = (w.updt_cnt+ 1),
     w.updt_dt_tm = cnvtdatetime(today_dt_tm), w.updt_id = reqinfo->updt_id, w.updt_task = reqinfo->
     updt_task,
     w.updt_applctx = reqinfo->updt_applctx
    WHERE (w.wkf_workflow_id=request->wkf_workflow_id)
    WITH nocounter
   ;end update
  ELSE
   UPDATE  FROM wkf_workflow w
    SET w.service_dt_tm = cnvtdatetime(request->service_dt_tm), w.service_tz = request->service_tz, w
     .end_dt_tm = cnvtdatetime(request->end_dt_tm),
     w.updt_cnt = (w.updt_cnt+ 1), w.updt_dt_tm = cnvtdatetime(today_dt_tm), w.updt_id = reqinfo->
     updt_id,
     w.updt_task = reqinfo->updt_task, w.updt_applctx = reqinfo->updt_applctx
    WHERE (w.wkf_workflow_id=request->wkf_workflow_id)
    WITH nocounter
   ;end update
  ENDIF
  IF (curqual != 1)
   SET g_failure = "T"
   CALL cps_add_error(cps_update,cps_script_fail,"UPDATE WKF_WORKFLOW",cps_update_msg,0,
    0,0)
   RETURN
  ENDIF
 END ;Subroutine
 SUBROUTINE processcomponent(icomponentidx)
   IF ((request->component[icomponentidx].wkf_component_id=0.0))
    DECLARE icomponentid = f8 WITH protect, noconstant(0)
    DECLARE icomponententityid = f8 WITH protect, noconstant(0)
    DECLARE scomponententityname = vc WITH protect, noconstant("")
    SELECT INTO "nl:"
     FROM wkf_component wfc
     PLAN (wfc
      WHERE (wfc.wkf_workflow_id=request->wkf_workflow_id)
       AND (wfc.component_concept=request->component[icomponentidx].component_concept))
     DETAIL
      icomponentid = wfc.wkf_component_id, icomponententityid = wfc.component_entity_id,
      scomponententityname = wfc.component_entity_name
     WITH nocounter
    ;end select
    IF (icomponentid=0.0)
     CALL insertcomponent(icomponentidx)
    ELSE
     IF ((request->component[icomponentidx].component_entity_id=0.0))
      SET entityid = getentityid(request->component[icomponentidx].component_reference_number,request
       ->component[icomponentidx].component_entity_name)
     ELSE
      SET entityid = request->component[icomponentidx].component_entity_id
     ENDIF
     IF (((icomponententityid=0.0) OR (((scomponententityname="") OR (((entityid !=
     icomponententityid) OR ((request->component[icomponentidx].component_entity_name !=
     scomponententityname))) )) )) )
      SET g_failure = "T"
      CALL cps_add_error(cps_inval_data,cps_script_fail,"ERROR: UPDATE COMPONENT ENTITY",
       "Unable to change ComponentEntityId or ComponentEntityName",0,
       0,0)
      GO TO exit_script
     ENDIF
     CALL updatecomponent(icomponentidx,icomponentid)
    ENDIF
   ELSE
    CALL updatecomponent(icomponentidx,request->component[icomponentidx].wkf_component_id)
   ENDIF
 END ;Subroutine
 SUBROUTINE processoutput(ioutputidx)
   IF ((request->output[ioutputidx].wkf_output_id=0.0))
    CALL insertoutput(ioutputidx)
   ELSE
    CALL updateoutput(ioutputidx)
   ENDIF
 END ;Subroutine
 SUBROUTINE insertcomponent(icomponentidx)
   SET fcomponentid = scdgetuniqueactivityid(null)
   IF ((request->component[icomponentidx].component_entity_id=0.0))
    SET entityid = getentityid(request->component[icomponentidx].component_reference_number,request->
     component[icomponentidx].component_entity_name)
   ELSE
    SET entityid = request->component[icomponentidx].component_entity_id
   ENDIF
   INSERT  FROM wkf_component wc
    SET wc.wkf_component_id = fcomponentid, wc.wkf_workflow_id = request->wkf_workflow_id, wc
     .component_concept = request->component[icomponentidx].component_concept,
     wc.component_entity_name = request->component[icomponentidx].component_entity_name, wc
     .component_entity_id = entityid, wc.updt_cnt = 1,
     wc.updt_dt_tm = cnvtdatetime(today_dt_tm), wc.updt_id = reqinfo->updt_id, wc.updt_task = reqinfo
     ->updt_task,
     wc.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual != 1)
    SET g_failure = "T"
    CALL cps_add_error(cps_update,cps_script_fail,"INSERT WKF_COMPONENT",cps_update_msg,0,
     0,0)
    RETURN
   ENDIF
   SET reply->component[icomponentidx].wkf_component_id = fcomponentid
   SET reply->component[icomponentidx].component_concept = request->component[icomponentidx].
   component_concept
   SET reply->component[icomponentidx].component_entity_id = entityid
   SET reply->component[icomponentidx].component_reference_number = request->component[icomponentidx]
   .component_reference_number
 END ;Subroutine
 SUBROUTINE updatecomponent(icomponentidx,iwkfcomponentid)
   UPDATE  FROM wkf_component wc
    SET wc.wkf_workflow_id = request->wkf_workflow_id, wc.component_concept = request->component[
     icomponentidx].component_concept, wc.component_entity_name = request->component[icomponentidx].
     component_entity_name,
     wc.component_entity_id = request->component[icomponentidx].component_entity_id, wc.updt_cnt = (
     wc.updt_cnt+ 1), wc.updt_dt_tm = cnvtdatetime(today_dt_tm),
     wc.updt_id = reqinfo->updt_id, wc.updt_task = reqinfo->updt_task, wc.updt_applctx = reqinfo->
     updt_applctx
    WHERE wc.wkf_component_id=iwkfcomponentid
    WITH nocounter
   ;end update
   IF (curqual != 1)
    SET g_failure = "T"
    CALL cps_add_error(cps_update,cps_script_fail,"UPDATE WKF_COMPONENT",cps_update_msg,0,
     0,0)
    RETURN
   ENDIF
   SET reply->component[icomponentidx].wkf_component_id = request->component[icomponentidx].
   wkf_component_id
   SET reply->component[icomponentidx].component_concept = request->component[icomponentidx].
   component_concept
   SET reply->component[icomponentidx].component_entity_id = request->component[icomponentidx].
   component_entity_id
   SET reply->component[icomponentidx].component_reference_number = request->component[icomponentidx]
   .component_reference_number
 END ;Subroutine
 SUBROUTINE insertoutput(ioutputidx)
   SET foutputid = scdgetuniqueactivityid(null)
   IF ((request->output[ioutputidx].output_entity_id=0.0))
    SET entityid = getentityid(request->output[ioutputidx].output_reference_number,request->output[
     ioutputidx].output_entity_name)
   ELSE
    SET entityid = request->output[ioutputidx].output_entity_id
   ENDIF
   INSERT  FROM wkf_output wo
    SET wo.wkf_output_id = foutputid, wo.wkf_workflow_id = request->wkf_workflow_id, wo
     .output_type_cd = request->output[ioutputidx].output_type_cd,
     wo.output_entity_name = request->output[ioutputidx].output_entity_name, wo.output_entity_id =
     entityid, wo.updt_cnt = 1,
     wo.updt_dt_tm = cnvtdatetime(today_dt_tm), wo.updt_id = reqinfo->updt_id, wo.updt_task = reqinfo
     ->updt_task,
     wo.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual != 1)
    SET g_failure = "T"
    CALL cps_add_error(cps_update,cps_script_fail,"INSERT WKF_OUTPUT",cps_update_msg,0,
     0,0)
    RETURN
   ENDIF
   SET reply->output[ioutputidx].wkf_output_id = foutputid
   SET reply->output[ioutputidx].output_type_cd = request->output[ioutputidx].output_type_cd
   SET reply->output[ioutputidx].output_entity_id = entityid
   SET reply->output[ioutputidx].output_reference_number = request->output[ioutputidx].
   output_reference_number
 END ;Subroutine
 SUBROUTINE updateoutput(ioutputidx)
   UPDATE  FROM wkf_output wo
    SET wo.wkf_workflow_id = request->wkf_workflow_id, wo.output_type_cd = request->output[ioutputidx
     ].output_type_cd, wo.output_entity_name = request->output[ioutputidx].output_entity_name,
     wo.output_entity_id = request->output[ioutputidx].output_entity_id, wo.updt_cnt = (wo.updt_cnt+
     1), wo.updt_dt_tm = cnvtdatetime(today_dt_tm),
     wo.updt_id = reqinfo->updt_id, wo.updt_task = reqinfo->updt_task, wo.updt_applctx = reqinfo->
     updt_applctx
    WHERE (wo.wkf_output_id=request->output[ioutputidx].wkf_output_id)
    WITH nocounter
   ;end update
   IF (curqual != 1)
    SET g_failure = "T"
    CALL cps_add_error(cps_update,cps_script_fail,"UPDATE wkf_output",cps_update_msg,0,
     0,0)
    RETURN
   ENDIF
   SET reply->output[ioutputidx].wkf_output_id = request->output[ioutputidx].wkf_output_id
   SET reply->output[ioutputidx].output_type_cd = request->output[ioutputidx].output_type_cd
   SET reply->output[ioutputidx].output_entity_id = request->output[ioutputidx].output_entity_id
   SET reply->output[ioutputidx].output_reference_number = request->output[ioutputidx].
   output_reference_number
 END ;Subroutine
 SUBROUTINE (getentityid(reference_nbr=vc,entity_name=vc) =f8 WITH protect)
   DECLARE idx = i4 WITH private, noconstant(0)
   DECLARE rblistidx = i4 WITH private, noconstant(0)
   DECLARE reply_ce_count = i4 WITH protect, constant(size(event_rep->rb_list,5))
   SET rblistidx = locateval(idx,1,reply_ce_count,reference_nbr,event_rep->rb_list[idx].reference_nbr
    )
   IF (rblistidx=0)
    SET g_failure = "T"
    CALL cps_add_error(cps_inval_data,cps_script_fail,"EntityID Lookup Failure",concat(
      "GetEntityId failed for ",reference_nbr),0,
     0,0)
   ENDIF
   IF (entity_name="CE_RESULT_SET_LINK")
    RETURN(event_rep->rb_list[rblistidx].result_set_link_list[1].result_set_id)
   ELSE
    RETURN(event_rep->rb_list[rblistidx].event_id)
   ENDIF
 END ;Subroutine
#exit_script
 IF (g_failure="T")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
  CALL echorecord(request,"doc_ens_worflow_failure_log",1)
  CALL echorecord(reply,"doc_ens_worflow_failure_log",1)
  IF (validate(event_rep) != 0)
   CALL echorecord(event_rep,"doc_ens_worflow_failure_log",1)
  ENDIF
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
