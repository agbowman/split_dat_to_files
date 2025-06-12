CREATE PROGRAM dcp_ens_pregnancy_edd:dba
 SET modify = predeclare
 RECORD reply(
   1 edds[*]
     2 edd_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD rdcpenspregnancyedd
 RECORD rdcpenspregnancyedd(
   1 parent_entity_id = f8
   1 parent_entity_name = vc
   1 entity_activity_type_cd = f8
 )
 FREE RECORD edd_copies
 RECORD edd_copies(
   1 edds[*]
     2 pregnancy_estimate_id = f8
     2 pregnancy_id = f8
     2 status_flag = i2
     2 method_cd = f8
     2 method_dt_tm = dq8
     2 method_tz = i4
     2 descriptor_cd = f8
     2 descriptor_txt = vc
     2 descriptor_flag = i2
     2 edd_comment = vc
     2 edd_comment_id = f8
     2 author_id = f8
     2 crown_rump_length = f8
     2 biparietal_diameter = f8
     2 head_circumference = f8
     2 est_gest_age_days = i4
     2 est_delivery_dt_tm = dq8
     2 est_delivery_tz = i4
     2 confirmation_cd = f8
     2 prev_preg_estimate_id = f8
     2 active_ind = i2
     2 entered_dt_tm = dq8
     2 org_id = f8
     2 new_status_flag = i2
     2 new_pregnancy_estimate_id = f8
 )
 FREE RECORD comment_copies
 RECORD comment_copies(
   1 comment[*]
     2 long_text_id = f8
     2 parent_entity_id = f8
     2 long_text = vc
     2 active_status_cd = f8
     2 new_long_text_id = f8
 )
 FREE RECORD detail_copies
 RECORD detail_copies(
   1 details[*]
     2 lmp_symptoms_txt = vc
     2 pregnancy_test_dt_tm = dq8
     2 contraception_ind = i2
     2 contraception_duration = i4
     2 breastfeeding_ind = i2
     2 menarche_age = i4
     2 menstrual_freq = i4
     2 prior_menses_dt_tm = dq8
     2 pregnancy_detail_id = f8
     2 new_pregnancy_detail_id = f8
     2 pregnancy_estimate_id = f8
 )
 DECLARE insertconstraintedds(null) = null WITH protect
 DECLARE deactivateconstraintedds(null) = null WITH protect
 DECLARE performconstraintactions(ridx) = null WITH protect
 DECLARE adddeletededdtorequest(null) = null WITH protect
 DECLARE failure_ind = i2 WITH protect, noconstant(false)
 DECLARE new_mode_ind = i2 WITH protect, noconstant(true)
 DECLARE prev_edd_id = f8 WITH protect, noconstant(0.0)
 DECLARE comment_id = f8 WITH protect, noconstant(0.0)
 DECLARE edd_size = i2 WITH protect, constant(size(request->edds,5))
 DECLARE idx = i2 WITH protect, noconstant(0)
 DECLARE status = i4 WITH protect, noconstant(0)
 DECLARE inactivestatuscode = f8 WITH constant(uar_get_code_by("MEANING",48,"INACTIVE")), protect
 DECLARE activestatuscode = f8 WITH constant(uar_get_code_by("MEANING",48,"ACTIVE")), protect
 DECLARE current_timestamp = dq8 WITH constant(cnvtdatetime(sysdate)), protect
 DECLARE script_version = c12 WITH private, noconstant(fillstring(12," "))
 DECLARE debug_ind = i2 WITH protect, noconstant(0)
 DECLARE update_edd = i2 WITH protect, constant(0)
 DECLARE initial_edd = i2 WITH protect, constant(1)
 DECLARE auth_edd = i2 WITH protect, constant(2)
 DECLARE final_edd = i2 WITH protect, constant(3)
 DECLARE initial_final_edd = i2 WITH protect, constant(4)
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE errcode = i4 WITH protect, noconstant(0)
 SUBROUTINE (checkactivepregnancy(argpersonid=f8) =f8)
   RETURN(checkactivepregnancyorg(argpersonid,0,0))
 END ;Subroutine
 SUBROUTINE (checkactivepregnancyorg(argpersonid=f8,argencntrid=f8,argorgsecoverride=i2) =f8)
   CALL echo("[TRACE]: CheckActivePregnancy")
   DECLARE retval = f8 WITH noconstant(0.0), private
   RECORD actchkrequest(
     1 patient_id = f8
     1 encntr_id = f8
     1 org_sec_override = i2
   )
   SET actchkrequest->patient_id = argpersonid
   SET actchkrequest->encntr_id = argencntrid
   SET actchkrequest->org_sec_override = argorgsecoverride
   EXECUTE dcp_chk_active_preg  WITH replace("REQUEST",actchkrequest), replace("REPLY",actchkreply)
   IF ((actchkreply->status_data.status="F"))
    CALL echo("[FAIL]: DCP_CHK_ACTIVE_PREG failed")
   ELSEIF ((actchkreply->status_data.status="Z"))
    SET retval = 0.0
   ELSE
    CALL echo("[TRACE]: Active Pregnancy found for patient")
    SET retval = actchkreply->pregnancy_id
   ENDIF
   RETURN(retval)
 END ;Subroutine
 DECLARE request_check_method = i2 WITH constant(validate(request->edds[idx].method_tz))
 DECLARE request_check_edd = i2 WITH constant(validate(request->edds[idx].est_delivery_tz))
 SET reply->status_data.status = "F"
 SET status = alterlist(reply->edds,edd_size)
 IF (validate(request->debug_ind)=1)
  IF ((request->debug_ind=1))
   SET debug_ind = 1
   CALL echo("*DEBUG MODE - ON - DCP_ENS_PREGNANCY_EDD*")
  ENDIF
 ENDIF
 CALL validaterequest(null)
 FOR (idx = 1 TO edd_size)
   CALL getensuremode(null)
   IF (new_mode_ind=false)
    CALL deactivateoldedd(null)
   ENDIF
   IF ((request->edds[idx].delete_ind=false))
    CALL performconstraintactions(idx)
   ELSE
    CALL adddeletededdtorequest(null)
   ENDIF
   CALL ensureedddata(null)
 ENDFOR
 CALL updatetracking(0)
#failure
 SET errcode = error(errmsg,1)
 IF (errcode > 0)
  SET failure_ind = true
 ENDIF
 IF (failure_ind=true)
  CALL echo("*Ensure Pregnancy EDD Script failed*")
  SET reqinfo->commit_ind = false
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = true
 ENDIF
 CALL echorecord(reply)
 SUBROUTINE validaterequest(null)
   DECLARE initialind = i2 WITH noconstant(false)
   DECLARE finalind = i2 WITH noconstant(false)
   DECLARE authind = i2 WITH noconstant(false)
   IF ((((request->patient_id <= 0.0)) OR ((request->pregnancy_id <= 0.0))) )
    SET failure_ind = true
    CALL echo("[FAIL]: No person_id or pregnancy_id found")
    GO TO failure
   ENDIF
   DECLARE pregid = f8 WITH noconstant(0.0), public
   SET pregid = checkactivepregnancyorg(request->patient_id,request->encntr_id,request->
    org_sec_override)
   IF (pregid <= 0.0)
    SET failure_ind = true
    CALL echo("[FAIL]: Given pregnancy was not found, or not active")
    GO TO failure
   ENDIF
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = size(request->edds,5))
    HEAD REPORT
     idx = 0
    DETAIL
     idx += 1
     IF ((((request->edds[idx].status_flag=1)) OR ((request->edds[idx].status_flag=4))) )
      IF (initialind=true)
       failure_ind = true
      ENDIF
      initialind = true
     ENDIF
     IF ((request->edds[idx].status_flag=2))
      IF (authind=true)
       failure_ind = true
      ENDIF
      authind = true
     ENDIF
     IF ((((request->edds[idx].status_flag=3)) OR ((request->edds[idx].status_flag=4))) )
      IF (finalind=true)
       failure_ind = true
      ENDIF
      finalind = true
     ENDIF
    WITH nocounter
   ;end select
   IF (failure_ind=true)
    CALL echo("[FAIL]: Request violates EDD constraints")
    GO TO failure
   ENDIF
 END ;Subroutine
 SUBROUTINE getensuremode(null)
   IF ((request->edds[idx].edd_id > 0.0))
    SET new_mode_ind = false
   ELSE
    SET new_mode_ind = true
   ENDIF
 END ;Subroutine
 SUBROUTINE deactivateoldedd(null)
   SELECT INTO "nl:"
    FROM pregnancy_estimate pe
    WHERE (pe.pregnancy_estimate_id=request->edds[idx].edd_id)
     AND pe.active_ind=1
    DETAIL
     prev_edd_id = pe.pregnancy_estimate_id, updtcnt = pe.updt_cnt, stat = alterlist(edd_copies->edds,
      1),
     edd_copies->edds[1].pregnancy_estimate_id = pe.pregnancy_estimate_id, edd_copies->edds[1].
     status_flag = pe.status_flag, edd_copies->edds[1].method_cd = pe.method_cd,
     edd_copies->edds[1].method_dt_tm = pe.method_dt_tm, edd_copies->edds[1].method_tz = pe.method_tz,
     edd_copies->edds[1].descriptor_cd = pe.descriptor_cd,
     edd_copies->edds[1].descriptor_txt = pe.descriptor_txt, edd_copies->edds[1].descriptor_flag = pe
     .descriptor_flag, edd_copies->edds[1].edd_comment_id = pe.edd_comment_id,
     edd_copies->edds[1].author_id = pe.author_id, edd_copies->edds[1].crown_rump_length = pe
     .crown_rump_length, edd_copies->edds[1].biparietal_diameter = pe.biparietal_diameter,
     edd_copies->edds[1].head_circumference = pe.head_circumference, edd_copies->edds[1].
     est_gest_age_days = pe.est_gest_age_days, edd_copies->edds[1].est_delivery_dt_tm = pe
     .est_delivery_dt_tm,
     edd_copies->edds[1].est_delivery_tz = pe.est_delivery_tz, edd_copies->edds[1].confirmation_cd =
     pe.confirmation_cd
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL echo("[FAIL]: Active previous edd was not found during deactivate")
    SET failure_ind = true
    GO TO failure
   ENDIF
   UPDATE  FROM pregnancy_estimate pe
    SET pe.active_ind = 0, pe.updt_dt_tm = cnvtdatetime(current_timestamp), pe.updt_applctx = reqinfo
     ->updt_applctx,
     pe.updt_cnt = (pe.updt_cnt+ 1), pe.updt_task = reqinfo->updt_task
    WHERE (pe.pregnancy_estimate_id=request->edds[idx].edd_id)
    WITH nocounter
   ;end update
   UPDATE  FROM long_text lt
    SET lt.active_ind = 0, lt.active_status_cd = inactivestatuscode, lt.updt_dt_tm = cnvtdatetime(
      current_timestamp),
     lt.updt_applctx = reqinfo->updt_applctx, lt.updt_cnt = (lt.updt_cnt+ 1), lt.updt_task = reqinfo
     ->updt_task
    WHERE lt.parent_entity_id=prev_edd_id
     AND lt.parent_entity_name="PREGNANCY_ESTIMATE"
    WITH nocounter
   ;end update
   UPDATE  FROM pregnancy_detail pd
    SET pd.active_ind = 0, pd.updt_dt_tm = cnvtdatetime(current_timestamp), pd.updt_applctx = reqinfo
     ->updt_applctx,
     pd.updt_cnt = (pd.updt_cnt+ 1), pd.updt_task = reqinfo->updt_task, pd.end_effective_dt_tm =
     cnvtdatetime(current_timestamp)
    WHERE pd.pregnancy_estimate_id=prev_edd_id
     AND pd.active_ind=1
    WITH nocounter
   ;end update
 END ;Subroutine
 SUBROUTINE ensureedddata(null)
   DECLARE newpregseq = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    j = seq(pregnancy_seq,nextval)
    FROM dual
    DETAIL
     newpregseq = cnvtreal(j)
    WITH nocounter
   ;end select
   SET reply->edds[idx].edd_id = newpregseq
   DECLARE newcommentid = f8 WITH noconstant(0.0)
   IF (textlen(request->edds[idx].edd_comment_txt) > 0)
    SELECT INTO "nl:"
     j = seq(long_data_seq,nextval)
     FROM dual
     DETAIL
      newcommentid = cnvtreal(j)
     WITH nocounter
    ;end select
    INSERT  FROM long_text lt
     SET lt.long_text_id = newcommentid, lt.parent_entity_id = newpregseq, lt.parent_entity_name =
      "PREGNANCY_ESTIMATE",
      lt.long_text = request->edds[idx].edd_comment_txt, lt.active_ind = 1, lt.active_status_cd =
      activestatuscode,
      lt.active_status_dt_tm = cnvtdatetime(current_timestamp), lt.active_status_prsnl_id = reqinfo->
      updt_id, lt.updt_id = reqinfo->updt_id,
      lt.updt_dt_tm = cnvtdatetime(current_timestamp), lt.updt_applctx = reqinfo->updt_applctx, lt
      .updt_cnt = 0,
      lt.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
   ENDIF
   INSERT  FROM pregnancy_estimate pe
    SET pe.pregnancy_estimate_id = newpregseq, pe.pregnancy_id = request->pregnancy_id, pe
     .prev_preg_estimate_id = prev_edd_id,
     pe.status_flag = request->edds[idx].status_flag, pe.method_cd = request->edds[idx].method_cd, pe
     .confirmation_cd = request->edds[idx].confirmation_cd,
     pe.descriptor_cd = request->edds[idx].descriptor_cd, pe.descriptor_txt = request->edds[idx].
     descriptor_txt, pe.descriptor_flag = request->edds[idx].descriptor_flag,
     pe.edd_comment_id = newcommentid, pe.entered_dt_tm = cnvtdatetime(current_timestamp), pe
     .method_dt_tm = cnvtdatetime(request->edds[idx].method_dt_tm),
     pe.crown_rump_length = request->edds[idx].crown_rump_length, pe.biparietal_diameter = request->
     edds[idx].biparietal_diameter, pe.head_circumference = request->edds[idx].head_circumference,
     pe.est_gest_age_days = request->edds[idx].est_gest_age, pe.est_delivery_dt_tm = cnvtdatetime(
      request->edds[idx].est_delivery_dt_tm), pe.author_id = request->edds[idx].author_id,
     pe.active_ind =
     IF ((request->edds[idx].delete_ind=0)) 1
     ELSE 0
     ENDIF
     , pe.updt_id = reqinfo->updt_id, pe.updt_dt_tm = cnvtdatetime(current_timestamp),
     pe.updt_applctx = reqinfo->updt_applctx, pe.updt_cnt = 0, pe.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   IF (request_check_method=1
    AND request_check_edd=1)
    UPDATE  FROM pregnancy_estimate pe
     SET pe.method_tz = request->edds[idx].method_tz, pe.est_delivery_tz = request->edds[idx].
      est_delivery_tz
     WHERE pe.pregnancy_estimate_id=newpregseq
     WITH nocounter
    ;end update
   ENDIF
   IF (size(request->edds[idx].details,5) > 0)
    DECLARE newdetailseq = f8 WITH noconstant(0.0)
    SELECT INTO "nl:"
     j = seq(pregnancy_seq,nextval)
     FROM dual
     DETAIL
      newdetailseq = cnvtreal(j)
     WITH nocounter
    ;end select
    INSERT  FROM pregnancy_detail pd
     SET pd.pregnancy_detail_id = newdetailseq, pd.pregnancy_estimate_id = newpregseq, pd
      .lmp_symptoms_txt = request->edds[idx].details[1].lmp_symptoms_txt,
      pd.pregnancy_test_dt_tm = cnvtdatetime(request->edds[idx].details[1].pregnancy_test_dt_tm), pd
      .contraception_ind = request->edds[idx].details[1].contraception_ind, pd.contraception_duration
       = request->edds[idx].details[1].contraception_duration,
      pd.breastfeeding_ind = request->edds[idx].details[1].breastfeeding_ind, pd.menarche_age =
      request->edds[idx].details[1].menarche_age, pd.menstrual_freq = request->edds[idx].details[1].
      menstrual_freq,
      pd.prior_menses_dt_tm = cnvtdatetime(request->edds[idx].details[1].prior_menses_dt_tm), pd
      .updt_id = reqinfo->updt_id, pd.active_ind = 1,
      pd.updt_dt_tm = cnvtdatetime(current_timestamp), pd.updt_applctx = reqinfo->updt_applctx, pd
      .updt_cnt = 1,
      pd.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
   ENDIF
   SET prev_edd_id = 0.0
 END ;Subroutine
 SUBROUTINE performconstraintactions(ridx)
   IF (debug_ind=1)
    CALL echo("***Entering PerformConstraintActions***")
   ENDIF
   DECLARE requeststatus = i2 WITH noconstant(request->edds[ridx].status_flag)
   DECLARE new_status_flag = i2 WITH noconstant(- (1)), protect
   DECLARE e_idx = i4 WITH noconstant(0), protect
   DECLARE c_idx = i4 WITH noconstant(0), protect
   DECLARE d_idx = i4 WITH noconstant(0), protect
   SELECT INTO "nl:"
    FROM pregnancy_estimate pe,
     long_text lt,
     pregnancy_detail pd
    PLAN (pe
     WHERE (pe.pregnancy_id=request->pregnancy_id)
      AND pe.active_ind=1)
     JOIN (lt
     WHERE (lt.long_text_id= Outerjoin(pe.edd_comment_id)) )
     JOIN (pd
     WHERE (pd.pregnancy_estimate_id= Outerjoin(pe.pregnancy_estimate_id)) )
    HEAD pe.pregnancy_estimate_id
     new_status_flag = - (1)
     IF (requeststatus=initial_edd)
      IF (pe.status_flag=initial_final_edd)
       new_status_flag = final_edd
      ELSEIF (pe.status_flag=initial_edd)
       new_status_flag = update_edd
      ENDIF
     ENDIF
     IF (requeststatus=auth_edd
      AND pe.status_flag=auth_edd)
      new_status_flag = update_edd
     ENDIF
     IF (requeststatus=final_edd)
      IF (pe.status_flag=initial_final_edd)
       new_status_flag = initial_edd
      ELSEIF (pe.status_flag=final_edd)
       new_status_flag = update_edd
      ENDIF
     ENDIF
     IF (requeststatus=initial_final_edd
      AND ((pe.status_flag=initial_final_edd) OR (((pe.status_flag=final_edd) OR (pe.status_flag=
     initial_edd)) )) )
      new_status_flag = update_edd
     ENDIF
     IF (debug_ind=1)
      CALL echo(build2("Request status: ",requeststatus)),
      CALL echo(build2("pregnancy_estimate_id: ",pe.pregnancy_estimate_id)),
      CALL echo(build2("Old status:",pe.status_flag)),
      CALL echo(build2("New status: ",new_status_flag))
     ENDIF
     IF ((new_status_flag > - (1)))
      e_idx = (size(edd_copies->edds,5)+ 1), status = alterlist(edd_copies->edds,e_idx), edd_copies->
      edds[e_idx].pregnancy_estimate_id = pe.pregnancy_estimate_id,
      edd_copies->edds[e_idx].author_id = pe.author_id, edd_copies->edds[e_idx].biparietal_diameter
       = pe.biparietal_diameter, edd_copies->edds[e_idx].crown_rump_length = pe.crown_rump_length,
      edd_copies->edds[e_idx].head_circumference = pe.head_circumference, edd_copies->edds[e_idx].
      confirmation_cd = pe.confirmation_cd, edd_copies->edds[e_idx].descriptor_cd = pe.descriptor_cd,
      edd_copies->edds[e_idx].descriptor_flag = pe.descriptor_flag, edd_copies->edds[e_idx].
      descriptor_txt = pe.descriptor_txt, edd_copies->edds[e_idx].entered_dt_tm = pe.entered_dt_tm,
      edd_copies->edds[e_idx].est_delivery_dt_tm = pe.est_delivery_dt_tm, edd_copies->edds[e_idx].
      est_gest_age_days = pe.est_gest_age_days, edd_copies->edds[e_idx].method_cd = pe.method_cd,
      edd_copies->edds[e_idx].method_dt_tm = pe.method_dt_tm, edd_copies->edds[e_idx].method_tz = pe
      .method_tz, edd_copies->edds[e_idx].est_delivery_tz = pe.est_delivery_tz,
      edd_copies->edds[e_idx].pregnancy_id = pe.pregnancy_id, edd_copies->edds[e_idx].
      prev_preg_estimate_id = pe.prev_preg_estimate_id, edd_copies->edds[e_idx].status_flag = pe
      .status_flag,
      edd_copies->edds[e_idx].edd_comment_id = pe.edd_comment_id, edd_copies->edds[e_idx].
      new_status_flag = new_status_flag
      IF (pe.edd_comment_id > 0)
       c_idx = (size(comment_copies->comment,5)+ 1), status = alterlist(comment_copies->comment,c_idx
        ), comment_copies->comment[c_idx].long_text_id = lt.long_text_id,
       comment_copies->comment[c_idx].parent_entity_id = lt.parent_entity_id, comment_copies->
       comment[c_idx].long_text = lt.long_text, comment_copies->comment[c_idx].active_status_cd = lt
       .active_status_cd
      ENDIF
      IF (pd.pregnancy_detail_id > 0)
       d_idx = (size(detail_copies->details,5)+ 1), status = alterlist(detail_copies->details,d_idx),
       detail_copies->details[d_idx].breastfeeding_ind = pd.breastfeeding_ind,
       detail_copies->details[d_idx].contraception_ind = pd.contraception_ind, detail_copies->
       details[d_idx].contraception_duration = pd.contraception_duration, detail_copies->details[
       d_idx].lmp_symptoms_txt = pd.lmp_symptoms_txt,
       detail_copies->details[d_idx].menarche_age = pd.menarche_age, detail_copies->details[d_idx].
       menstrual_freq = pd.menstrual_freq, detail_copies->details[d_idx].pregnancy_detail_id = pd
       .pregnancy_detail_id,
       detail_copies->details[d_idx].pregnancy_estimate_id = pd.pregnancy_estimate_id, detail_copies
       ->details[d_idx].pregnancy_test_dt_tm = pd.pregnancy_test_dt_tm, detail_copies->details[d_idx]
       .prior_menses_dt_tm = pd.prior_menses_dt_tm
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (debug_ind=1)
    CALL echorecord(edd_copies)
    CALL echorecord(comment_copies)
    CALL echorecord(detail_copies)
   ENDIF
   IF (size(edd_copies->edds,5) > 0)
    CALL deactivateconstraintedds(null)
    CALL insertconstraintedds(null)
   ENDIF
 END ;Subroutine
 SUBROUTINE (updatetracking(param=i2) =null WITH protect)
   DECLARE dentityactivitycd = f8 WITH constant(uar_get_code_by("MEANING",28620,"TRACKINGUPDT"))
   SET rdcpenspregnancyedd->entity_activity_type_cd = dentityactivitycd
   SET rdcpenspregnancyedd->parent_entity_name = "PERSON"
   SET rdcpenspregnancyedd->parent_entity_id = request->patient_id
   SET modify = nopredeclare
   EXECUTE trkfn_upd_activity_count  WITH replace("REQUEST",rdcpenspregnancyedd), replace("REPLY",
    reply)
   SET modify = predeclare
 END ;Subroutine
 SUBROUTINE deactivateconstraintedds(null)
   IF (debug_ind=1)
    CALL echo("***Entering DeactivateConstraintEDDs***")
   ENDIF
   UPDATE  FROM pregnancy_estimate pe,
     (dummyt d  WITH seq = value(size(edd_copies->edds,5)))
    SET pe.active_ind = 0, pe.updt_dt_tm = cnvtdatetime(current_timestamp), pe.updt_applctx = reqinfo
     ->updt_applctx,
     pe.updt_cnt = (pe.updt_cnt+ 1), pe.updt_task = reqinfo->updt_task
    PLAN (d)
     JOIN (pe
     WHERE (pe.pregnancy_estimate_id=edd_copies->edds[d.seq].pregnancy_estimate_id))
    WITH nocounter
   ;end update
   IF (size(comment_copies->comment,5) > 0)
    UPDATE  FROM long_text lt,
      (dummyt d  WITH seq = value(size(comment_copies->comment,5)))
     SET lt.active_ind = 0, lt.active_status_cd = inactivestatuscode, lt.updt_dt_tm = cnvtdatetime(
       current_timestamp),
      lt.updt_applctx = reqinfo->updt_applctx, lt.updt_cnt = (lt.updt_cnt+ 1), lt.updt_task = reqinfo
      ->updt_task
     PLAN (d)
      JOIN (lt
      WHERE (lt.parent_entity_id=comment_copies->comment[d.seq].parent_entity_id))
     WITH nocounter
    ;end update
   ENDIF
   IF (size(detail_copies->details,5) > 0)
    UPDATE  FROM pregnancy_detail pd,
      (dummyt d  WITH seq = value(size(detail_copies->details,5)))
     SET pd.active_ind = 0, pd.updt_dt_tm = cnvtdatetime(current_timestamp), pd.updt_applctx =
      reqinfo->updt_applctx,
      pd.updt_cnt = (pd.updt_cnt+ 1), pd.updt_task = reqinfo->updt_task, pd.end_effective_dt_tm =
      cnvtdatetime(current_timestamp)
     PLAN (d)
      JOIN (pd
      WHERE (pd.pregnancy_detail_id=detail_copies->details[d.seq].pregnancy_detail_id))
     WITH nocounter
    ;end update
   ENDIF
   SUBROUTINE insertconstraintedds(null)
     IF (debug_ind=1)
      CALL echo("***Entering InsertConstraintEDDs***")
     ENDIF
     IF (debug_ind=1)
      CALL echorecord(edd_copies)
      CALL echorecord(comment_copies)
      CALL echorecord(detail_copies)
     ENDIF
     DECLARE new_preg_seq = f8 WITH noconstant(0.0), protect
     DECLARE new_lt_seq = f8 WITH noconstant(0.0), protect
     DECLARE new_detail_seq = f8 WITH noconstant(0.0), protect
     DECLARE comment_idx = i4 WITH noconstant(0), protect
     DECLARE edd_idx = i4 WITH noconstant(0), protect
     DECLARE new_pregnancy_estimate_id = f8 WITH noconstant(0.0), protect
     DECLARE new_parent_entity_id = f8 WITH noconstant(0.0), protect
     DECLARE num = i4 WITH noconstant(0), protect
     DECLARE start = i4 WITH noconstant(1), protect
     FOR (e_idx = 1 TO size(edd_copies->edds,5))
       SELECT INTO "nl:"
        j = seq(pregnancy_seq,nextval)
        FROM dual
        DETAIL
         new_preg_seq = j
        WITH nocounter
       ;end select
       SET edd_copies->edds[e_idx].new_pregnancy_estimate_id = new_preg_seq
       SET num = 0
       SET start = 1
       SET comment_idx = locateval(num,start,size(comment_copies->comment,5),edd_copies->edds[e_idx].
        edd_comment_id,comment_copies->comment[num].long_text_id)
       IF (comment_idx > 0)
        SELECT INTO "nl:"
         j = seq(long_data_seq,nextval)
         FROM dual
         DETAIL
          new_lt_seq = j
         WITH nocounter
        ;end select
        SET comment_copies->comment[comment_idx].new_long_text_id = new_lt_seq
       ENDIF
       INSERT  FROM pregnancy_estimate pe
        SET pe.active_ind = 1, pe.author_id = edd_copies->edds[e_idx].author_id, pe
         .biparietal_diameter = edd_copies->edds[e_idx].biparietal_diameter,
         pe.confirmation_cd = edd_copies->edds[e_idx].confirmation_cd, pe.crown_rump_length =
         edd_copies->edds[e_idx].crown_rump_length, pe.descriptor_cd = edd_copies->edds[e_idx].
         descriptor_cd,
         pe.descriptor_flag = edd_copies->edds[e_idx].descriptor_flag, pe.descriptor_txt = edd_copies
         ->edds[e_idx].descriptor_txt, pe.edd_comment_id = new_lt_seq,
         pe.entered_dt_tm = cnvtdatetime(current_timestamp), pe.est_delivery_dt_tm = cnvtdatetime(
          edd_copies->edds[e_idx].est_delivery_dt_tm), pe.est_gest_age_days = edd_copies->edds[e_idx]
         .est_gest_age_days,
         pe.head_circumference = edd_copies->edds[e_idx].head_circumference, pe.method_cd =
         edd_copies->edds[e_idx].method_cd, pe.method_dt_tm = cnvtdatetime(edd_copies->edds[e_idx].
          method_dt_tm),
         pe.pregnancy_estimate_id = edd_copies->edds[e_idx].new_pregnancy_estimate_id, pe
         .pregnancy_id = edd_copies->edds[e_idx].pregnancy_id, pe.prev_preg_estimate_id = edd_copies
         ->edds[e_idx].pregnancy_estimate_id,
         pe.status_flag = edd_copies->edds[e_idx].new_status_flag, pe.updt_applctx = reqinfo->
         updt_applctx, pe.updt_dt_tm = cnvtdatetime(current_timestamp),
         pe.updt_id = reqinfo->updt_id, pe.updt_task = reqinfo->updt_task, pe.updt_cnt = 0
        WITH nocounter
       ;end insert
       UPDATE  FROM pregnancy_estimate pe
        SET pe.method_tz = edd_copies->edds[e_idx].method_tz, pe.est_delivery_tz = edd_copies->edds[
         e_idx].est_delivery_tz
        WHERE (pe.pregnancy_estimate_id=edd_copies->edds[e_idx].new_pregnancy_estimate_id)
        WITH nocounter
       ;end update
     ENDFOR
     FOR (c_idx = 1 TO size(comment_copies->comment,5))
       SET num = 0
       SET start = 1
       SET edd_idx = locateval(num,start,size(edd_copies->edds,5),comment_copies->comment[c_idx].
        parent_entity_id,edd_copies->edds[num].pregnancy_estimate_id)
       IF (edd_idx > 0)
        SET new_parent_entity_id = edd_copies->edds[edd_idx].new_pregnancy_estimate_id
       ENDIF
       INSERT  FROM long_text lt
        SET lt.active_ind = 1, lt.active_status_cd = activestatuscode, lt.active_status_dt_tm =
         cnvtdatetime(current_timestamp),
         lt.active_status_prsnl_id = reqinfo->updt_id, lt.long_text = comment_copies->comment[c_idx].
         long_text, lt.long_text_id = comment_copies->comment[c_idx].new_long_text_id,
         lt.parent_entity_id = new_parent_entity_id, lt.parent_entity_name = "PREGNANCY_ESTIMATE", lt
         .updt_applctx = reqinfo->updt_applctx,
         lt.updt_cnt = 0, lt.updt_dt_tm = cnvtdatetime(current_timestamp), lt.updt_id = reqinfo->
         updt_id,
         lt.updt_task = reqinfo->updt_task
        WITH nocounter
       ;end insert
     ENDFOR
     FOR (d_idx = 1 TO size(detail_copies->details,5))
       SELECT INTO "nl:"
        j = seq(pregnancy_seq,nextval)
        FROM dual
        DETAIL
         new_detail_seq = j
        WITH nocounter
       ;end select
       SET detail_copies->details[d_idx].new_pregnancy_detail_id = new_detail_seq
       SET num = 0
       SET start = 1
       SET edd_idx = locateval(num,start,size(edd_copies->edds,5),detail_copies->details[d_idx].
        pregnancy_estimate_id,edd_copies->edds[num].pregnancy_estimate_id)
       IF (edd_idx > 0)
        SET new_pregnancy_estimate_id = edd_copies->edds[edd_idx].new_pregnancy_estimate_id
       ENDIF
       INSERT  FROM pregnancy_detail pd
        SET pd.active_ind = 1, pd.breastfeeding_ind = detail_copies->details[d_idx].breastfeeding_ind,
         pd.contraception_duration = detail_copies->details[d_idx].contraception_duration,
         pd.contraception_ind = detail_copies->details[d_idx].contraception_ind, pd.lmp_symptoms_txt
          = detail_copies->details[d_idx].lmp_symptoms_txt, pd.menarche_age = detail_copies->details[
         d_idx].menarche_age,
         pd.menstrual_freq = detail_copies->details[d_idx].menstrual_freq, pd.pregnancy_detail_id =
         detail_copies->details[d_idx].new_pregnancy_detail_id, pd.pregnancy_estimate_id =
         new_pregnancy_estimate_id,
         pd.pregnancy_test_dt_tm = cnvtdatetime(detail_copies->details[d_idx].pregnancy_test_dt_tm),
         pd.prior_menses_dt_tm = cnvtdatetime(detail_copies->details[d_idx].prior_menses_dt_tm), pd
         .updt_applctx = reqinfo->updt_applctx,
         pd.updt_dt_tm = cnvtdatetime(current_timestamp), pd.updt_id = reqinfo->updt_id, pd.updt_task
          = reqinfo->updt_task,
         pd.updt_cnt = 0
        WITH nocounter
       ;end insert
     ENDFOR
   END ;Subroutine
 END ;Subroutine
 SUBROUTINE adddeletededdtorequest(null)
   SET request->edds[idx].edd_id = edd_copies->edds[1].pregnancy_estimate_id
   SET request->edds[idx].status_flag = edd_copies->edds[1].status_flag
   SET request->edds[idx].method_cd = edd_copies->edds[1].method_cd
   SET request->edds[idx].method_dt_tm = edd_copies->edds[1].method_dt_tm
   IF (request_check_method=1
    AND request_check_edd=1)
    SET request->edds[idx].method_tz = edd_copies->edds[1].method_tz
    SET request->edds[idx].est_delivery_tz = edd_copies->edds[1].est_delivery_tz
   ENDIF
   SET request->edds[idx].descriptor_cd = edd_copies->edds[1].descriptor_cd
   SET request->edds[idx].descriptor_txt = edd_copies->edds[1].descriptor_txt
   SET request->edds[idx].descriptor_flag = edd_copies->edds[1].descriptor_flag
   SET request->edds[idx].author_id = edd_copies->edds[1].author_id
   SET request->edds[idx].crown_rump_length = edd_copies->edds[1].crown_rump_length
   SET request->edds[idx].biparietal_diameter = edd_copies->edds[1].biparietal_diameter
   SET request->edds[idx].head_circumference = edd_copies->edds[1].head_circumference
   SET request->edds[idx].est_gest_age = edd_copies->edds[1].est_gest_age_days
   SET request->edds[idx].est_delivery_dt_tm = edd_copies->edds[1].est_delivery_dt_tm
   SET request->edds[idx].confirmation_cd = edd_copies->edds[1].confirmation_cd
   SET request->edds[idx].delete_ind = 1
 END ;Subroutine
 SET script_version = "002 04/01/10"
 SET modify = nopredeclare
END GO
