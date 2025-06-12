CREATE PROGRAM dcp_upd_trial_plan_reltn:dba
 FREE RECORD reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD copy
 RECORD copy(
   1 active_ind = i2
   1 beg_effective_dt_tm = dq8
   1 end_effective_dt_tm = dq8
   1 minimum_enrollment_status_flag = i2
   1 ordering_policy_flag = i2
   1 pathway_catalog_id = f8
   1 prev_pw_pt_reltn_id = f8
   1 prot_master_id = f8
   1 pw_pt_reltn_id = f8
   1 require_override_reason_ind = i2
   1 sequence = i4
 )
 DECLARE cstatus = c1 WITH protect, noconstant("Z")
 DECLARE cretstatus = c1 WITH protect, noconstant("Z")
 DECLARE ddate = dq8 WITH protect
 DECLARE dcurrentdate = dq8 WITH protect
 DECLARE ntrialplanreltncount = i4 WITH constant(value(size(request->trial_plan_reltn,5))), protect
 DECLARE insert_pt_pw_reltn(i=i4) = c1
 DECLARE remove_pt_pw_reltn(i=i4) = c1
 DECLARE update_pt_pw_reltn(i=i4) = c1
 DECLARE insert_pt_pw_reltn_copy(i=i4) = c1
 DECLARE report_failure(opname=vc,opstatus=c1,targetname=vc,targetvalue=vc) = null
 SET dcurrentdate = cnvtdatetime(curdate,curtime3)
 FOR (i = 1 TO ntrialplanreltncount)
   IF ((request->trial_plan_reltn[i].action_flag=1))
    SET cstatus = insert_pt_pw_reltn(i)
    IF (cstatus="F")
     CALL report_failure("INSERT","F","DCP_UPD_TRIAL_PLAN_RELTN",
      "Unable to insert PW_PT_RELTN record")
     GO TO exit_script
    ENDIF
   ELSEIF ((request->trial_plan_reltn[i].action_flag=2))
    SET cstatus = remove_pt_pw_reltn(i)
    IF (cstatus="F")
     CALL report_failure("REMOVE","F","DCP_UPD_TRIAL_PLAN_RELTN",
      "Unable to remove PW_PT_RELTN record")
     GO TO exit_script
    ENDIF
   ELSEIF ((request->trial_plan_reltn[i].action_flag=3))
    SET cstatus = update_pt_pw_reltn(i)
    IF (cstatus="F")
     CALL report_failure("MODIFY","F","DCP_UPD_TRIAL_PLAN_RELTN",
      "Unable to modify PW_PT_RELTN record")
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
 SUBROUTINE insert_pt_pw_reltn(i)
   SET copy->pw_pt_reltn_id = 0.00
   SELECT INTO "n1:"
    FROM pw_pt_reltn ppr
    WHERE (ppr.prot_master_id=request->trial_plan_reltn[i].prot_master_id)
     AND (ppr.pathway_catalog_id=request->trial_plan_reltn[i].pathway_catalog_id)
     AND ppr.end_effective_dt_tm=cnvtdatetime("31-Dec-2100")
    DETAIL
     copy->active_ind = ppr.active_ind, copy->beg_effective_dt_tm = ppr.beg_effective_dt_tm, copy->
     end_effective_dt_tm = ppr.end_effective_dt_tm,
     copy->minimum_enrollment_status_flag = ppr.minimum_enrollment_status_flag, copy->
     ordering_policy_flag = ppr.ordering_policy_flag, copy->pathway_catalog_id = ppr
     .pathway_catalog_id,
     copy->prev_pw_pt_reltn_id = ppr.prev_pw_pt_reltn_id, copy->prot_master_id = ppr.prot_master_id,
     copy->pw_pt_reltn_id = ppr.pw_pt_reltn_id,
     copy->require_override_reason_ind = ppr.require_override_reason_ind, copy->sequence = ppr
     .sequence
    WITH nocounter
   ;end select
   IF ((copy->pw_pt_reltn_id != 0.00))
    SET cretstatus = insert_pt_pw_reltn_copy(i)
    IF (cretstatus="F")
     RETURN("F")
    ENDIF
    SELECT INTO "n1:"
     ppr.*
     FROM pw_pt_reltn ppr
     WHERE (ppr.pw_pt_reltn_id=copy->pw_pt_reltn_id)
     WITH forupdate(ppr), nocounter
    ;end select
    IF (curqual=0)
     CALL report_failure("INSERT","F","DCP_UPD_TRIAL_PLAN_RELTN","Unable to lock PW_PT_RELTN record")
     RETURN("F")
    ENDIF
    UPDATE  FROM pw_pt_reltn ppr
     SET ppr.active_ind = 1, ppr.beg_effective_dt_tm = cnvtdatetime(dcurrentdate), ppr.sequence =
      request->trial_plan_reltn[i].sequence,
      ppr.minimum_enrollment_status_flag = request->trial_plan_reltn[i].
      minimum_enrollment_status_flag, ppr.ordering_policy_flag = request->trial_plan_reltn[i].
      ordering_policy_flag, ppr.require_override_reason_ind = request->trial_plan_reltn[i].
      require_override_reason_flag,
      ppr.updt_applctx = reqinfo->updt_applctx, ppr.updt_cnt = (ppr.updt_cnt+ 1), ppr.updt_dt_tm =
      cnvtdatetime(dcurrentdate),
      ppr.updt_id = reqinfo->updt_id, ppr.updt_task = reqinfo->updt_task
     WHERE (ppr.pw_pt_reltn_id=copy->pw_pt_reltn_id)
    ;end update
    IF (curqual=0)
     RETURN("F")
    ENDIF
    SET copy->pw_pt_reltn_id = 0.00
   ELSE
    INSERT  FROM pw_pt_reltn ppr
     SET ppr.pw_pt_reltn_id = seq(reference_seq,nextval), ppr.prev_pw_pt_reltn_id = seq(reference_seq,
       nextval), ppr.prot_master_id = request->trial_plan_reltn[i].prot_master_id,
      ppr.pathway_catalog_id = request->trial_plan_reltn[i].pathway_catalog_id, ppr
      .beg_effective_dt_tm = cnvtdatetime(dcurrentdate), ppr.end_effective_dt_tm = cnvtdatetime(
       "31-Dec-2100"),
      ppr.sequence = request->trial_plan_reltn[i].sequence, ppr.active_ind = 1, ppr
      .minimum_enrollment_status_flag = request->trial_plan_reltn[i].minimum_enrollment_status_flag,
      ppr.ordering_policy_flag = request->trial_plan_reltn[i].ordering_policy_flag, ppr
      .require_override_reason_ind = request->trial_plan_reltn[i].require_override_reason_flag, ppr
      .updt_applctx = reqinfo->updt_applctx,
      ppr.updt_cnt = 0, ppr.updt_dt_tm = cnvtdatetime(dcurrentdate), ppr.updt_id = reqinfo->updt_id,
      ppr.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
    IF (curqual=0)
     RETURN("F")
    ENDIF
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE remove_pt_pw_reltn(i)
   SELECT INTO "n1:"
    FROM pw_pt_reltn ppr
    WHERE (ppr.pw_pt_reltn_id=request->trial_plan_reltn[i].pw_pt_reltn_id)
    DETAIL
     copy->active_ind = ppr.active_ind, copy->beg_effective_dt_tm = ppr.beg_effective_dt_tm, copy->
     end_effective_dt_tm = ppr.end_effective_dt_tm,
     copy->minimum_enrollment_status_flag = ppr.minimum_enrollment_status_flag, copy->
     ordering_policy_flag = ppr.ordering_policy_flag, copy->pathway_catalog_id = ppr
     .pathway_catalog_id,
     copy->prev_pw_pt_reltn_id = ppr.prev_pw_pt_reltn_id, copy->prot_master_id = ppr.prot_master_id,
     copy->pw_pt_reltn_id = ppr.pw_pt_reltn_id,
     copy->require_override_reason_ind = ppr.require_override_reason_ind, copy->sequence = ppr
     .sequence
    WITH nocounter
   ;end select
   IF (curqual <= 0)
    RETURN("F")
   ENDIF
   SET cretstatus = insert_pt_pw_reltn_copy(i)
   SET copy->pw_pt_reltn_id = 0.00
   IF (cretstatus="F")
    RETURN("F")
   ENDIF
   SELECT INTO "n1:"
    ppr.*
    FROM pw_pt_reltn ppr
    WHERE (ppr.pw_pt_reltn_id=request->trial_plan_reltn[i].pw_pt_reltn_id)
    WITH forupdate(ppr), nocounter
   ;end select
   IF (curqual=0)
    CALL report_failure("REMOVE","F","DCP_UPD_TRIAL_PLAN_RELTN","Unable to lock PW_PT_RELTN record")
    RETURN("F")
   ENDIF
   UPDATE  FROM pw_pt_reltn ppr
    SET ppr.active_ind = 0, ppr.beg_effective_dt_tm = cnvtdatetime(dcurrentdate), ppr.updt_applctx =
     reqinfo->updt_applctx,
     ppr.updt_cnt = (ppr.updt_cnt+ 1), ppr.updt_dt_tm = cnvtdatetime(dcurrentdate), ppr.updt_id =
     reqinfo->updt_id,
     ppr.updt_task = reqinfo->updt_task
    WHERE (ppr.pw_pt_reltn_id=request->trial_plan_reltn[i].pw_pt_reltn_id)
   ;end update
   IF (curqual=0)
    RETURN("F")
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE update_pt_pw_reltn(i)
   SELECT INTO "n1:"
    FROM pw_pt_reltn ppr
    WHERE (ppr.pw_pt_reltn_id=request->trial_plan_reltn[i].pw_pt_reltn_id)
    DETAIL
     copy->active_ind = ppr.active_ind, copy->beg_effective_dt_tm = ppr.beg_effective_dt_tm, copy->
     end_effective_dt_tm = ppr.end_effective_dt_tm,
     copy->minimum_enrollment_status_flag = ppr.minimum_enrollment_status_flag, copy->
     ordering_policy_flag = ppr.ordering_policy_flag, copy->pathway_catalog_id = ppr
     .pathway_catalog_id,
     copy->prev_pw_pt_reltn_id = ppr.prev_pw_pt_reltn_id, copy->prot_master_id = ppr.prot_master_id,
     copy->pw_pt_reltn_id = ppr.pw_pt_reltn_id,
     copy->require_override_reason_ind = ppr.require_override_reason_ind, copy->sequence = ppr
     .sequence
    WITH nocounter
   ;end select
   IF (curqual <= 0)
    RETURN("F")
   ENDIF
   SET cretstatus = insert_pt_pw_reltn_copy(i)
   SET copy->pw_pt_reltn_id = 0.00
   IF (cretstatus="F")
    RETURN("F")
   ENDIF
   SELECT INTO "n1:"
    ppr.*
    FROM pw_pt_reltn ppr
    WHERE (ppr.pw_pt_reltn_id=request->trial_plan_reltn[i].pw_pt_reltn_id)
    WITH forupdate(ppr), nocounter
   ;end select
   IF (curqual=0)
    CALL report_failure("MODIFY","F","DCP_UPD_TRIAL_PLAN_RELTN","Unable to lock PW_PT_RELTN record")
    RETURN("F")
   ENDIF
   UPDATE  FROM pw_pt_reltn ppr
    SET ppr.beg_effective_dt_tm = cnvtdatetime(dcurrentdate), ppr.minimum_enrollment_status_flag =
     request->trial_plan_reltn[i].minimum_enrollment_status_flag, ppr.ordering_policy_flag = request
     ->trial_plan_reltn[i].ordering_policy_flag,
     ppr.require_override_reason_ind = request->trial_plan_reltn[i].require_override_reason_flag, ppr
     .sequence = request->trial_plan_reltn[i].sequence, ppr.updt_applctx = reqinfo->updt_applctx,
     ppr.updt_cnt = (ppr.updt_cnt+ 1), ppr.updt_dt_tm = cnvtdatetime(dcurrentdate), ppr.updt_id =
     reqinfo->updt_id,
     ppr.updt_task = reqinfo->updt_task
    WHERE (ppr.pw_pt_reltn_id=request->trial_plan_reltn[i].pw_pt_reltn_id)
   ;end update
   IF (curqual=0)
    RETURN("F")
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE insert_pt_pw_reltn_copy(i)
   INSERT  FROM pw_pt_reltn ppr
    SET ppr.pw_pt_reltn_id = seq(reference_seq,nextval), ppr.prev_pw_pt_reltn_id = copy->
     pw_pt_reltn_id, ppr.prot_master_id = copy->prot_master_id,
     ppr.pathway_catalog_id = copy->pathway_catalog_id, ppr.end_effective_dt_tm = cnvtdatetime(
      dcurrentdate), ppr.active_ind = copy->active_ind,
     ppr.beg_effective_dt_tm = cnvtdatetime(copy->beg_effective_dt_tm), ppr
     .minimum_enrollment_status_flag = copy->minimum_enrollment_status_flag, ppr.ordering_policy_flag
      = copy->ordering_policy_flag,
     ppr.require_override_reason_ind = copy->require_override_reason_ind, ppr.sequence = copy->
     sequence, ppr.updt_applctx = reqinfo->updt_applctx,
     ppr.updt_cnt = 0, ppr.updt_dt_tm = cnvtdatetime(dcurrentdate), ppr.updt_id = reqinfo->updt_id,
     ppr.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   IF (curqual=0)
    RETURN("F")
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE report_failure(opname,opstatus,targetname,targetvalue)
   DECLARE cnt = i4 WITH protect, noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
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
#exit_script
 IF (cstatus="S")
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
 SET reply->status_data.status = cstatus
END GO
