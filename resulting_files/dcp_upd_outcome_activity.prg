CREATE PROGRAM dcp_upd_outcome_activity
 SET modify = predeclare
 RECORD outcome(
   1 outcome_activity_id = f8
   1 outcome_status_cd = f8
   1 outcome_status_dt_tm = dq8
   1 target_type_cd = f8
   1 start_dt_tm = dq8
   1 end_dt_tm = dq8
   1 last_action_seq = i4
   1 description = vc
   1 expectation = vc
   1 start_estimated_ind = i2
   1 end_estimated_ind = i2
 )
 DECLARE stat = i2 WITH noconstant(0)
 DECLARE cfailed = c1 WITH noconstant("F")
 DECLARE criteria = i4 WITH constant(value(size(request->criteria,5)))
 DECLARE query_outcome(id=f8) = null
 DECLARE lock_outcome_row(id=f8,updtcnt=i4) = null
 DECLARE stop_outcome(id=f8,updtcnt=i4,statuscd=f8) = null
 DECLARE update_outcome(id=f8,updtcnt=i4) = null
 DECLARE insert_outcome_action(id=f8) = null
 DECLARE report_failure(opname=vc,opstatus=c1,targetname=vc,targetvalue=vc) = null
 DECLARE disc_cd = f8 WITH constant(uar_get_code_by("MEANING",30182,"DISCONTINUED"))
 IF ((disc_cd=- (1)))
  CALL report_failure("VALIDATE","F","CODE_VALUE",
   "Failed to load code value for DISCONTINUED from codeset 30182")
  GO TO exit_script
 ENDIF
 DECLARE void_cd = f8 WITH constant(uar_get_code_by("MEANING",30182,"VOID"))
 IF ((void_cd=- (1)))
  CALL report_failure("VALIDATE","F","CODE_VALUE",
   "Failed to load code value for VOID from codeset 30182")
  GO TO exit_script
 ENDIF
 DECLARE canceled_cd = f8 WITH constant(uar_get_code_by("MEANING",30182,"CANCELED"))
 IF ((canceled_cd=- (1)))
  CALL report_failure("VALIDATE","F","CODE_VALUE",
   "Failed to load code value for CANCELED from codeset 30182")
  GO TO exit_script
 ENDIF
 CASE (request->outcomestatuscd)
  OF disc_cd:
   CALL stop_outcome(request->outcomeactid,request->updtcnt,disc_cd)
  OF void_cd:
   CALL stop_outcome(request->outcomeactid,request->updtcnt,void_cd)
  OF canceled_cd:
   CALL stop_outcome(request->outcomeactid,request->updtcnt,canceled_cd)
  ELSE
   CALL update_outcome(request->outcomeactid,request->updtcnt)
 ENDCASE
 CALL query_outcome(request->outcomeactid)
 CALL insert_outcome_action(request->outcomeactid)
 SUBROUTINE query_outcome(id)
  SELECT INTO "nl:"
   FROM outcome_activity oa,
    outcome_action oat
   PLAN (oa
    WHERE oa.outcome_activity_id=id)
    JOIN (oat
    WHERE oat.outcome_activity_id=outerjoin(oa.outcome_activity_id))
   ORDER BY oat.action_seq
   DETAIL
    outcome->outcome_activity_id = oa.outcome_activity_id, outcome->outcome_status_cd = oa
    .outcome_status_cd, outcome->outcome_status_dt_tm = cnvtdatetime(oa.outcome_status_dt_tm),
    outcome->target_type_cd = oa.target_type_cd, outcome->start_dt_tm = cnvtdatetime(oa.start_dt_tm),
    outcome->end_dt_tm = cnvtdatetime(oa.end_dt_tm),
    outcome->last_action_seq = oat.action_seq, outcome->description = trim(oa.description), outcome->
    expectation = trim(oa.expectation),
    outcome->start_estimated_ind = oa.start_estimated_ind, outcome->end_estimated_ind = oa
    .end_estimated_ind
   WITH nocounter
  ;end select
  IF (curqual=0)
   CALL report_failure("SELECT","F","DCP_UPD_OUTCOME_ACTIVITY",
    "QUERY_OUTCOME::Failed to load existing outcome_activity data")
   GO TO exit_script
  ENDIF
 END ;Subroutine
 SUBROUTINE insert_outcome_action(id)
  INSERT  FROM outcome_action oa
   SET oa.outcome_activity_id = outcome->outcome_activity_id, oa.action_seq = (outcome->
    last_action_seq+ 1), oa.outcome_status_cd = outcome->outcome_status_cd,
    oa.outcome_status_dt_tm = cnvtdatetime(outcome->outcome_status_dt_tm), oa.target_type_cd =
    outcome->target_type_cd, oa.start_dt_tm = cnvtdatetime(outcome->start_dt_tm),
    oa.end_dt_tm = cnvtdatetime(outcome->end_dt_tm), oa.action_dt_tm = cnvtdatetime(curdate,curtime3),
    oa.action_tz = request->usertz,
    oa.outcome_status_tz = request->patienttz, oa.start_tz =
    IF ((request->startdttm != null)) request->patienttz
    ENDIF
    , oa.end_tz =
    IF ((request->enddttm != null)) request->patienttz
    ENDIF
    ,
    oa.start_estimated_ind = outcome->start_estimated_ind, oa.end_estimated_ind = outcome->
    end_estimated_ind, oa.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    oa.updt_id = reqinfo->updt_id, oa.updt_task = reqinfo->updt_task, oa.updt_cnt = 0,
    oa.updt_applctx = reqinfo->updt_applctx
   WITH nocounter
  ;end insert
  IF (curqual=0)
   CALL report_failure("INSERT","F","DCP_UPD_OUTCOME_ACTIVITY",
    "INSERT_OUTCOME_ACTION::Failed to insert into OUTCOME_ACTION table")
   GO TO exit_script
  ENDIF
 END ;Subroutine
 SUBROUTINE lock_outcome_row(id,updtcnt)
   DECLARE updt_cnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    oa.*
    FROM outcome_activity oa
    WHERE oa.outcome_activity_id=id
    HEAD REPORT
     updt_cnt = oa.updt_cnt
    WITH forupdate(oa), nocounter
   ;end select
   IF (curqual=0)
    CALL report_failure("UPDATE","F","DCP_UPD_OUTCOME_ACTIVITY",
     "LOCK_OUTCOME_ROW::Unable to lock row on OUTCOME_ACTIVITY table")
    GO TO exit_script
   ENDIF
   IF (updt_cnt != updtcnt)
    CALL report_failure("UPDATE","F","DCP_UPD_OUTCOME_ACTIVITY",
     "LOCK_OUTCOME_ROW::Unable to update - OUTCOME has been changed by a different user")
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE update_outcome(id,updtcnt)
   DECLARE criteria_updt_cnt = i4 WITH protect, noconstant(0)
   CALL lock_outcome_row(id,updtcnt)
   UPDATE  FROM outcome_activity oa
    SET oa.description =
     IF ((request->description != null)) trim(request->description)
     ELSE oa.description
     ENDIF
     , oa.expectation =
     IF ((request->expectation != null)) trim(request->expectation)
     ELSE oa.expectation
     ENDIF
     , oa.outcome_status_cd = request->outcomestatuscd,
     oa.outcome_status_dt_tm = cnvtdatetime(curdate,curtime3), oa.start_dt_tm =
     IF ((request->startdttm != null)) cnvtdatetime(request->startdttm)
     ELSE oa.start_dt_tm
     ENDIF
     , oa.end_dt_tm =
     IF ((request->enddttm != null)) cnvtdatetime(request->enddttm)
     ELSE oa.end_dt_tm
     ENDIF
     ,
     oa.outcome_status_tz = request->patienttz, oa.start_tz =
     IF ((request->startdttm != null)) request->patienttz
     ELSE oa.start_tz
     ENDIF
     , oa.end_tz =
     IF ((request->enddttm != null)) request->patienttz
     ELSE oa.end_tz
     ENDIF
     ,
     oa.encntr_id =
     IF ((request->encntrid > 0)) request->encntrid
     ELSE oa.encntr_id
     ENDIF
     , oa.target_type_cd = request->targettypecd, oa.start_estimated_ind = request->startestimatedind,
     oa.end_estimated_ind = request->endestimatedind, oa.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     oa.updt_id = reqinfo->updt_id,
     oa.updt_task = reqinfo->updt_task, oa.updt_cnt = (oa.updt_cnt+ 1), oa.updt_applctx = reqinfo->
     updt_applctx
    WHERE oa.outcome_activity_id=id
   ;end update
   IF (curqual=0)
    CALL report_failure("UPDATE","F","DCP_UPD_OUTCOME_ACTIVITY",
     "UPDATE_OUTCOME::Failed to update row on OUTCOME_ACTIVITY table")
    GO TO exit_script
   ENDIF
   FOR (i = 1 TO criteria)
     SELECT INTO "nl:"
      oc.*
      FROM outcome_criteria oc
      WHERE (oc.outcome_criteria_id=request->criteria[i].outcomecriteriaid)
      HEAD REPORT
       criteria_updt_cnt = oc.updt_cnt
      WITH forupdate(oc), nocounter
     ;end select
     IF (curqual=0)
      CALL report_failure("UPDATE","F","DCP_UPD_OUTCOME_ACTIVITY",
       "UPDATE_OUTCOME::Unable to lock row on OUTCOME_CRITERIA table")
      GO TO exit_script
     ENDIF
     IF ((criteria_updt_cnt != request->criteria[i].updtcnt))
      CALL report_failure("UPDATE","F","DCP_UPD_OUTCOME_ACTIVITY",
       "UPDATE_OUTCOME::Unable to update - OUTCOME_CRITERIA has been changed by a different user")
      GO TO exit_script
     ENDIF
     UPDATE  FROM outcome_criteria oc
      SET oc.result_value = request->criteria[i].resultvalue, oc.result_unit_cd = request->criteria[i
       ].resultunitcd, oc.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       oc.updt_id = reqinfo->updt_id, oc.updt_task = reqinfo->updt_task, oc.updt_cnt = (oc.updt_cnt+
       1),
       oc.updt_applctx = reqinfo->updt_applctx
      WHERE (oc.outcome_criteria_id=request->criteria[i].outcomecriteriaid)
     ;end update
     IF (curqual=0)
      CALL report_failure("UPDATE","F","DCP_UPD_OUTCOME_ACTIVITY",
       "UPDATE_OUTCOME::Failed to update row on OUTCOME_CRITERIA table")
      GO TO exit_script
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE stop_outcome(id,updtcnt,statuscd)
   CALL lock_outcome_row(id,updtcnt)
   UPDATE  FROM outcome_activity oa
    SET oa.outcome_status_cd = statuscd, oa.outcome_status_dt_tm = cnvtdatetime(curdate,curtime3), oa
     .end_dt_tm =
     IF (statuscd=disc_cd) cnvtdatetime(curdate,curtime3)
     ELSE oa.end_dt_tm
     ENDIF
     ,
     oa.outcome_status_tz = request->patienttz, oa.end_tz =
     IF (statuscd=disc_cd) request->patienttz
     ELSE oa.end_tz
     ENDIF
     , oa.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     oa.updt_id = reqinfo->updt_id, oa.updt_task = reqinfo->updt_task, oa.updt_cnt = (oa.updt_cnt+ 1),
     oa.updt_applctx = reqinfo->updt_applctx
    WHERE oa.outcome_activity_id=id
   ;end update
   IF (curqual=0)
    CALL report_failure("UPDATE","F","DCP_UPD_OUTCOME_ACTIVITY",
     "STOP_OUTCOME::Failed to update row on OUTCOME_ACTIVITY table")
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE report_failure(opname,opstatus,targetname,targetvalue)
   SET cfailed = "T"
   SET stat = alterlist(reply->status_data.subeventstatus,(value(size(reply->status_data.
      subeventstatus,5))+ 1))
   SET reply->status_data.subeventstatus[1].operationname = trim(opname)
   SET reply->status_data.subeventstatus[1].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[1].targetobjectname = trim(targetname)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = trim(targetvalue)
 END ;Subroutine
#exit_script
 FREE RECORD outcome
 IF (cfailed="T")
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
