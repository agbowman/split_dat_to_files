CREATE PROGRAM dcp_upd_forms_activity:dba
 IF (validate(reply)=0)
  RECORD reply(
    1 activity_form_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET failed = "F"
 SET reply->status_data.status = "F"
 SET now = cnvtdatetime(sysdate)
 DECLARE activityformid = f8 WITH public, noconstant(request->form_activity_id)
 DECLARE compcnt = i4 WITH noconstant(0), protect
 DECLARE prsnlcnt = i4 WITH noconstant(0), protect
 SET compcnt = size(request->component,5)
 SET prsnlcnt = size(request->prsnl,5)
 DECLARE forms_activity_exist = i2 WITH noconstant(1)
 DECLARE clincd = f8 WITH noconstant(uar_get_code_by("MEANING",18189,nullterm("CLINCALEVENT")))
 IF (clincd=0)
  GO TO exit_script
 ENDIF
 DECLARE seteventidforcomponent(dummyvar) = i2
 DECLARE stat = i4 WITH noconstant(0), protect
 DECLARE dummy_void = i2 WITH constant(0)
 DECLARE retval = i2 WITH noconstant(0)
 DECLARE x = i4 WITH noconstant(0), protect
 DECLARE provcd = f8 WITH noconstant(uar_get_code_by("MEANING",18189,nullterm("CHARGEPROV")))
 DECLARE loccd = f8 WITH noconstant(uar_get_code_by("MEANING",18189,nullterm("CHARGELOC")))
 DECLARE diag_entry = f8 WITH noconstant(uar_get_code_by("MEANING",18189,nullterm("CHARGEDIAG")))
 DECLARE cpt_entry = f8 WITH noconstant(uar_get_code_by("MEANING",18189,nullterm("CHARGECPT")))
 IF (size(reply->status_data.subeventstatus,5)=0)
  SET stat = alterlist(reply->status_data.subeventstatus,1)
 ENDIF
 IF ((request->form_activity_id=0.0))
  SELECT INTO "nl:"
   j = seq(carenet_seq,nextval)
   FROM dual
   DETAIL
    activityformid = cnvtreal(j)
   WITH format, nocounter
  ;end select
  SET forms_activity_exist = 1
 ELSE
  SELECT INTO "nl:"
   dfa.dcp_forms_activity_id
   FROM dcp_forms_activity dfa
   WHERE dfa.dcp_forms_activity_id=activityformid
   DETAIL
    forms_activity_exist = 0
   WITH nocounter
  ;end select
 ENDIF
 SET retval = seteventidforcomponent(dummy_void)
 IF (retval=0)
  SET reply->status_data.subeventstatus[1].targetobjectname = "Clinical Event Server"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "insert/update"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "4-unable"
  SET failed = "T"
  GO TO exit_script
 ENDIF
 IF (forms_activity_exist=1)
  CALL echo(build("Assigning FORM_ACTIVITY_ID = ",activityformid))
  INSERT  FROM dcp_forms_activity a
   SET a.dcp_forms_activity_id = activityformid, a.dcp_forms_ref_id = request->form_reference_id, a
    .person_id = request->person_id,
    a.encntr_id = request->encntr_id, a.task_id = request->task_id, a.form_dt_tm = cnvtdatetime(
     request->form_dt_tm),
    a.form_tz = request->form_tz, a.beg_activity_dt_tm = cnvtdatetime(now), a.last_activity_dt_tm =
    cnvtdatetime(now),
    a.form_status_cd = request->form_status_cd, a.flags = request->flags, a.description = request->
    description,
    a.active_ind = 1, a.version_dt_tm = cnvtdatetime(request->version_dt_tm), a.updt_dt_tm =
    cnvtdatetime(sysdate),
    a.updt_id = reqinfo->updt_id, a.updt_task = reqinfo->updt_task, a.updt_applctx = reqinfo->
    updt_applctx,
    a.updt_cnt = 0
   WITH nocounter
  ;end insert
 ELSE
  SET activityformid = request->form_activity_id
  IF (checkactivitylock(request->form_activity_id)=0)
   SET reply->status_data.subeventstatus[1].targetobjectname = "Clinical Event Server"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].operationname = "insert/update"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "4-unable - LOCK WAS NOT FOUND"
   SET failed = "T"
   GO TO exit_script
  ENDIF
  UPDATE  FROM dcp_forms_activity a
   SET a.form_status_cd = request->form_status_cd, a.flags = request->flags, a.form_dt_tm =
    cnvtdatetime(request->form_dt_tm),
    a.form_tz = request->form_tz, a.last_activity_dt_tm = cnvtdatetime(now), a.lock_prsnl_id = 0,
    a.lock_create_dt_tm = null, a.active_ind = 1, a.updt_dt_tm = cnvtdatetime(sysdate),
    a.updt_id = reqinfo->updt_id, a.updt_task = reqinfo->updt_task, a.updt_applctx = reqinfo->
    updt_applctx,
    a.updt_cnt = (a.updt_cnt+ 1)
   WHERE dcp_forms_activity_id=activityformid
   WITH nocounter
  ;end update
 ENDIF
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].targetobjectname = "DCP_forms_actvitiy table"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "insert/update"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "4-unable"
  SET failed = "T"
  GO TO exit_script
 ENDIF
 CALL echo(build("FORM_ACTIVITY_ID = ",activityformid))
 DELETE  FROM dcp_forms_activity_comp comp
  WHERE (comp.dcp_forms_activity_id=request->form_activity_id)
   AND comp.component_cd IN (provcd, loccd, diag_entry, cpt_entry)
 ;end delete
 COMMIT
 CALL echo("Adding components...")
 FOR (x = 1 TO compcnt)
  SELECT INTO "nl:"
   FROM dcp_forms_activity_comp comp
   WHERE comp.dcp_forms_activity_id=activityformid
    AND ((comp.parent_entity_id+ 0)=request->component[x].parent_entity_id)
    AND ((comp.component_cd+ 0)=request->component[x].component_cd)
   WITH nocounter, orahintcbo("index (comp XFK1DCP_FORMS_ACTIVITY_COMP)")
  ;end select
  IF (curqual=0)
   INSERT  FROM dcp_forms_activity_comp comp
    SET comp.dcp_forms_activity_comp_id = seq(carenet_seq,nextval), comp.dcp_forms_activity_id =
     activityformid, comp.parent_entity_name = request->component[x].parent_entity_name,
     comp.parent_entity_id = request->component[x].parent_entity_id, comp.component_cd = request->
     component[x].component_cd, comp.updt_dt_tm = cnvtdatetime(sysdate),
     comp.updt_id = reqinfo->updt_id, comp.updt_task = reqinfo->updt_task, comp.updt_applctx =
     reqinfo->updt_applctx,
     comp.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET reply->status_data.subeventstatus[1].targetobjectname = "DCP_forms_activity_comp table"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].operationname = "insert/update"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "4-unable"
    SET failed = "T"
    GO TO exit_script
   ENDIF
  ENDIF
 ENDFOR
 DECLARE app_tz = i4 WITH noconstant(0)
 IF (curutc=0)
  SET app_tz = 0
 ELSE
  SET app_tz = curtimezoneapp
 ENDIF
 CALL echo("Adding prsnl...")
 FOR (x = 1 TO prsnlcnt)
  SELECT INTO "nl:"
   FROM dcp_forms_activity_prsnl prsnl
   WHERE prsnl.dcp_forms_activity_id=activityformid
    AND ((prsnl.prsnl_id+ 0)=request->prsnl[x].prsnl_id)
    AND ((prsnl.activity_dt_tm+ 0)=cnvtdatetime(request->prsnl[x].activity_dt_tm))
    AND ((prsnl.proxy_id+ 0)=request->prsnl[x].proxy_id)
   WITH nocounter
  ;end select
  IF (curqual=0)
   IF ((request->prsnl[x].prsnl_ft="")
    AND (request->prsnl[x].prsnl_id != 0))
    SELECT INTO "nl:"
     FROM prsnl p
     WHERE (p.person_id=request->prsnl[x].prsnl_id)
     DETAIL
      request->prsnl[x].prsnl_ft = p.name_full_formatted
     WITH nocounter
    ;end select
   ENDIF
   INSERT  FROM dcp_forms_activity_prsnl prsnl
    SET prsnl.dcp_forms_activity_prsnl_id = seq(carenet_seq,nextval), prsnl.dcp_forms_activity_id =
     activityformid, prsnl.prsnl_id = request->prsnl[x].prsnl_id,
     prsnl.prsnl_ft = request->prsnl[x].prsnl_ft, prsnl.proxy_id = request->prsnl[x].proxy_id, prsnl
     .activity_dt_tm = cnvtdatetime(request->prsnl[x].activity_dt_tm),
     prsnl.activity_tz = app_tz, prsnl.updt_dt_tm = cnvtdatetime(sysdate), prsnl.updt_id = reqinfo->
     updt_id,
     prsnl.updt_task = reqinfo->updt_task, prsnl.updt_applctx = reqinfo->updt_applctx, prsnl.updt_cnt
      = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET reply->status_data.subeventstatus[1].targetobjectname = "DCP_forms_activity_prsnl table"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].operationname = "insert/update"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "4-unable"
    SET failed = "T"
    GO TO exit_script
   ENDIF
  ENDIF
 ENDFOR
#exit_script
 IF (failed="F")
  SET reply->activity_form_id = activityformid
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ELSE
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ENDIF
 CALL echo(build("status: ",reply->status_data.status))
 SET modify = hipaa
 EXECUTE cclaudit 0, "Maintain Encounter", "Structured Clinical Documents",
 "System Object", "Report", "DCP FORMS",
 "Amendment", reply->activity_form_id, ""
 IF ((request->encntr_id != 0))
  EXECUTE cclaudit 0, "Maintain Encounter", "Structured Clinical Documents",
  "Encounter", "Patient", "Encounter",
  "Access/Use", request->encntr_id, ""
 ELSE
  EXECUTE cclaudit 0, "Maintain Encounter", "Structured Clinical Documents",
  "Person", "Patient", "Patient",
  "Access/Use", request->person_id, ""
 ENDIF
 SUBROUTINE seteventidforcomponent(dummyvar)
  IF (validate(event_rep,0))
   IF ((event_rep->sb.severitycd > 2))
    RETURN(0)
   ENDIF
   DECLARE eventid = f8 WITH noconstant(0.0)
   DECLARE event_cnt = i4 WITH noconstant(0)
   DECLARE found_value = i2 WITH noconstant(0)
   SET event_cnt = size(event_rep->rb_list,5)
   IF (event_cnt=0)
    RETURN(0)
   ENDIF
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(event_cnt))
    PLAN (d1
     WHERE (((event_rep->rb_list[d1.seq].event_id=event_rep->rb_list[d1.seq].parent_event_id)) OR ((
     event_rep->rb_list[d1.seq].reference_nbr=request->reference_nbr))) )
    DETAIL
     IF (found_value=0)
      eventid = event_rep->rb_list[d1.seq].event_id, found_value = 1
     ENDIF
    WITH nocounter, outerjoin = d1
   ;end select
   SET found_value = 0
   DECLARE comp_cnt = i4 WITH noconstant(size(request->component,5))
   IF (comp_cnt=0)
    RETURN
   ENDIF
   SELECT INTO "nl:"
    FROM (dummyt d2  WITH seq = value(comp_cnt))
    PLAN (d2
     WHERE (request->component[d2.seq].parent_entity_name="CLINICAL_EVENT")
      AND (request->component[d2.seq].component_cd=clincd))
    DETAIL
     IF ((request->component[d2.seq].parent_entity_id=0))
      request->component[d2.seq].parent_entity_id = eventid
     ENDIF
    WITH nocounter, outerjoin = d2
   ;end select
  ENDIF
  RETURN(1)
 END ;Subroutine
 SUBROUTINE (checkactivitylock(argactivityid=f8) =i2)
  FOR (x = 1 TO prsnlcnt)
    DECLARE prsnlid = f8 WITH noconstant(0.0)
    IF ((request->prsnl[x].proxy_id > 0))
     SET prsnlid = request->prsnl[x].proxy_id
    ELSE
     SET prsnlid = request->prsnl[x].prsnl_id
    ENDIF
    SELECT INTO "nl:"
     FROM dcp_forms_activity fa
     WHERE fa.dcp_forms_activity_id=argactivityid
      AND fa.lock_prsnl_id=prsnlid
      AND fa.active_ind=1
     WITH nocounter
    ;end select
    IF (curqual > 0)
     CALL echo("lock found for prsnl")
     RETURN(1)
    ENDIF
  ENDFOR
  RETURN(0)
 END ;Subroutine
END GO
