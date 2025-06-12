CREATE PROGRAM dcp_upd_outcome_schedule:dba
 SET modify = predeclare
 RECORD outcome_data(
   1 list[*]
     2 outcome_activity_id = f8
     2 last_action_seq = i4
     2 outcome_status_cd = f8
     2 outcome_status_dt_tm = dq8
     2 outcome_status_tz = i4
     2 target_type_cd = f8
     2 start_estimated_ind = i2
     2 end_estimated_ind = i2
     2 old
       3 start_dt_tm = dq8
       3 start_tz = i4
       3 end_dt_tm = dq8
       3 end_tz = i4
     2 new
       3 start_dt_tm = dq8
       3 start_tz = i4
       3 end_dt_tm = dq8
       3 end_tz = i4
 )
 DECLARE time_unit_cd_days = f8 WITH protect, constant(uar_get_code_by("MEANING",340,"DAYS"))
 DECLARE time_unit_cd_hours = f8 WITH protect, constant(uar_get_code_by("MEANING",340,"HOURS"))
 DECLARE time_unit_cd_minutes = f8 WITH protect, constant(uar_get_code_by("MEANING",340,"MINUTES"))
 DECLARE l_outcome_count = i4 WITH protect, constant(value(size(request->outcomes,5)))
 DECLARE l_batch_size = i4 WITH protect, constant(20)
 DECLARE l_loop_count = i4 WITH protect, constant(value(ceil((cnvtreal(l_outcome_count)/ cnvtreal(
     l_batch_size)))))
 DECLARE l_outcome_size = i4 WITH protect, constant(value((l_batch_size * l_loop_count)))
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE lstart = i4 WITH protect, noconstant(1)
 DECLARE isubeventstatuscount = i4 WITH protect, noconstant(0)
 DECLARE isubeventstatussize = i4 WITH protect, noconstant(value(size(reply->status_data.
    subeventstatus,5)))
 DECLARE lactiontz = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "S"
 IF (l_outcome_count < 1)
  CALL set_script_status("Z","BEGIN","Z","dcp_upd_outcome_schedule","The outcome list was empty.")
  GO TO exit_script
 ENDIF
 IF (curutc=1)
  SET lactiontz = curtimezonesys
 ENDIF
 SET stat = alterlist(outcome_data->list,l_outcome_size)
 FOR (idx = 1 TO l_outcome_count)
   SET outcome_data->list[idx].outcome_activity_id = request->outcomes[idx].outcome_activity_id
   SET outcome_data->list[idx].new.start_dt_tm = cnvtdatetime(request->outcomes[idx].start_dt_tm)
   SET outcome_data->list[idx].new.start_tz = request->outcomes[idx].start_tz
   SET outcome_data->list[idx].new.end_dt_tm = cnvtdatetime(request->outcomes[idx].end_dt_tm)
   SET outcome_data->list[idx].new.end_tz = request->outcomes[idx].end_tz
 ENDFOR
 FOR (idx = (l_outcome_count+ 1) TO l_outcome_size)
   SET outcome_data->list[idx].outcome_activity_id = outcome_data->list[l_outcome_count].
   outcome_activity_id
 ENDFOR
 SET lstart = 1
 SELECT INTO "nl:"
  oa.outcome_activity_id, oat.action_seq
  FROM (dummyt d  WITH seq = value(l_loop_count)),
   outcome_activity oa,
   outcome_action oat
  PLAN (d
   WHERE initarray(lstart,evaluate(d.seq,1,1,(lstart+ l_batch_size))))
   JOIN (oa
   WHERE expand(idx,lstart,(lstart+ (l_batch_size - 1)),oa.outcome_activity_id,outcome_data->list[idx
    ].outcome_activity_id))
   JOIN (oat
   WHERE oat.outcome_activity_id=oa.outcome_activity_id)
  ORDER BY oa.outcome_activity_id, oat.action_seq DESC
  HEAD REPORT
   idx = 0
  HEAD oa.outcome_activity_id
   idx = locateval(idx,1,l_outcome_count,oa.outcome_activity_id,outcome_data->list[idx].
    outcome_activity_id)
   IF (idx > 0)
    outcome_data->list[idx].last_action_seq = oat.action_seq, outcome_data->list[idx].
    outcome_status_cd = oa.outcome_status_cd, outcome_data->list[idx].outcome_status_dt_tm =
    cnvtdatetime(oa.outcome_status_dt_tm),
    outcome_data->list[idx].outcome_status_tz = oa.outcome_status_tz, outcome_data->list[idx].
    target_type_cd = oa.target_type_cd, outcome_data->list[idx].start_estimated_ind = oa
    .start_estimated_ind,
    outcome_data->list[idx].end_estimated_ind = oa.end_estimated_ind, outcome_data->list[idx].old.
    start_dt_tm = cnvtdatetime(oa.start_dt_tm), outcome_data->list[idx].old.start_tz = oa.start_tz,
    outcome_data->list[idx].old.end_dt_tm = cnvtdatetime(oa.end_dt_tm), outcome_data->list[idx].old.
    end_tz = oa.end_tz
   ENDIF
  WITH forupdatewait(oa), nocounter
 ;end select
 IF (curqual=0)
  CALL set_script_status("F","SELECT","F","dcp_upd_outcome_schedule",
   "Failed to lock rows on the outcome_activity table.")
  GO TO exit_script
 ENDIF
 UPDATE  FROM (dummyt d  WITH seq = value(l_outcome_count)),
   outcome_activity oa
  SET oa.start_dt_tm = cnvtdatetime(outcome_data->list[d.seq].new.start_dt_tm), oa.start_tz =
   outcome_data->list[d.seq].new.start_tz, oa.start_estimated_ind = 0,
   oa.end_dt_tm = cnvtdatetime(outcome_data->list[d.seq].new.end_dt_tm), oa.end_tz = outcome_data->
   list[d.seq].new.end_tz, oa.end_estimated_ind = 0,
   oa.updt_dt_tm = cnvtdatetime(sysdate), oa.updt_id = request->personnel_id, oa.updt_task = 601520,
   oa.updt_cnt = (oa.updt_cnt+ 1), oa.updt_applctx = 600005
  PLAN (d)
   JOIN (oa
   WHERE (oa.outcome_activity_id=outcome_data->list[d.seq].outcome_activity_id))
  WITH nocounter
 ;end update
 IF (curqual=0)
  CALL set_script_status("F","UPDATE","F","dcp_upd_outcome_schedule",
   "Failed to update rows on the outcome_activity table.")
  GO TO exit_script
 ENDIF
 INSERT  FROM (dummyt d  WITH seq = value(l_outcome_count)),
   outcome_action oa
  SET oa.outcome_activity_id = outcome_data->list[d.seq].outcome_activity_id, oa.action_seq = (
   outcome_data->list[d.seq].last_action_seq+ 1), oa.outcome_status_cd = outcome_data->list[d.seq].
   outcome_status_cd,
   oa.outcome_status_dt_tm = cnvtdatetime(outcome_data->list[d.seq].outcome_status_dt_tm), oa
   .outcome_status_tz = outcome_data->list[d.seq].outcome_status_tz, oa.target_type_cd = outcome_data
   ->list[d.seq].target_type_cd,
   oa.action_dt_tm = cnvtdatetime(sysdate), oa.action_tz = lactiontz, oa.start_dt_tm = cnvtdatetime(
    outcome_data->list[d.seq].new.start_dt_tm),
   oa.start_tz = outcome_data->list[d.seq].new.start_tz, oa.start_estimated_ind = outcome_data->list[
   d.seq].start_estimated_ind, oa.end_dt_tm = cnvtdatetime(outcome_data->list[d.seq].new.end_dt_tm),
   oa.end_tz = outcome_data->list[d.seq].new.end_tz, oa.end_estimated_ind = outcome_data->list[d.seq]
   .end_estimated_ind, oa.updt_dt_tm = cnvtdatetime(sysdate),
   oa.updt_id = request->personnel_id, oa.updt_task = 601520, oa.updt_cnt = 0,
   oa.updt_applctx = 600005
  PLAN (d
   WHERE (outcome_data->list[d.seq].outcome_status_dt_tm != null))
   JOIN (oa
   WHERE (oa.outcome_activity_id=outcome_data->list[d.seq].outcome_activity_id))
  WITH nocounter
 ;end insert
 IF (curqual=0)
  CALL set_script_status("F","INSERT","F","dcp_upd_outcome_schedule",
   "Failed to insert rows into the outcome_action table.")
  GO TO exit_script
 ENDIF
 SUBROUTINE (set_script_status(cstatus=c1,soperationname=vc,coperationstatus=c1,stargetobjectname=vc,
  stargetobjectvalue=vc) =null)
   IF ((reply->status_data.status="S"))
    SET reply->status_data.status = cstatus
   ELSEIF (cstatus="F")
    SET reply->status_data.status = cstatus
   ENDIF
   SET isubeventstatuscount += 1
   IF (isubeventstatuscount > isubeventstatussize)
    SET isubeventstatussize += 1
    SET stat = alterlist(reply->status_data.subeventstatus,isubeventstatussize)
   ENDIF
   SET reply->status_data.subeventstatus[isubeventstatuscount].operationname = substring(1,25,trim(
     soperationname))
   SET reply->status_data.subeventstatus[isubeventstatuscount].operationstatus = trim(
    coperationstatus)
   SET reply->status_data.subeventstatus[isubeventstatuscount].targetobjectname = substring(1,25,trim
    (stargetobjectname))
   SET reply->status_data.subeventstatus[isubeventstatuscount].targetobjectvalue = trim(
    stargetobjectvalue)
 END ;Subroutine
#exit_script
 FREE RECORD outcome_data
END GO
