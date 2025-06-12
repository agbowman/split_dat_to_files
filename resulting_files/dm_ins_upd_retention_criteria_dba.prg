CREATE PROGRAM dm_ins_upd_retention_criteria:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 IF ((request->criteriatype="A"))
  IF ((((request->action_type="Remove")) OR ((request->action_type="Update"))) )
   UPDATE  FROM dm_retention_criteria drc
    SET drc.active_ind = 0, drc.end_effective_dt_tm = cnvtdatetime(curdate,curtime3)
    WHERE (drc.organization_id=request->organization_id)
     AND (drc.encntr_type_cd=request->encntr_type_cd)
     AND drc.active_ind=1
    WITH nocounter
   ;end update
   UPDATE  FROM dm_retention_criteria drc
    SET drc.active_ind = 0, drc.end_effective_dt_tm = cnvtdatetime(curdate,curtime3)
    WHERE (drc.organization_id=request->organization_id)
     AND (drc.encntr_type_cd=request->encntr_type_cd)
     AND drc.active_ind=1
     AND (drc.retention_criteria_id=request->parent_ret_criteria_id)
    WITH nocounter
   ;end update
  ENDIF
  SET next_seq_val = 0
  SELECT INTO "nl:"
   y = seq(dm_retention_criteria_seq,nextval)
   FROM dual
   DETAIL
    next_seq_val = cnvtreal(y)
   WITH nocounter
  ;end select
  IF ((((request->action_type="Add")) OR ((request->action_type="Update"))) )
   INSERT  FROM dm_retention_criteria drc
    SET drc.retention_criteria_id = next_seq_val, drc.criteria_type_cd = request->p_criteria_type_cd,
     drc.retention_days = 0,
     drc.organization_id = request->organization_id, drc.encntr_type_cd = request->encntr_type_cd,
     drc.event_cd = request->event_cd,
     drc.parent_ret_criteria_id = 0, drc.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), drc
     .end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
     drc.apply_ind = 0, drc.active_ind = 1
    WITH nocounter
   ;end insert
   SET next_seq_value = 0
   SELECT INTO "nl:"
    z = seq(dm_retention_criteria_seq,nextval)
    FROM dual
    DETAIL
     next_seq_value = cnvtreal(z)
    WITH nocounter
   ;end select
   INSERT  FROM dm_retention_criteria drc
    SET drc.retention_criteria_id = next_seq_value, drc.criteria_type_cd = request->criteria_type_cd,
     drc.retention_days = request->retention_days,
     drc.organization_id = request->organization_id, drc.encntr_type_cd = request->encntr_type_cd,
     drc.event_cd = request->event_cd,
     drc.parent_ret_criteria_id = next_seq_val, drc.beg_effective_dt_tm = cnvtdatetime(curdate,
      curtime3), drc.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
     drc.active_ind = 1, drc.apply_ind = 0
    WITH nocounter
   ;end insert
  ENDIF
 ENDIF
 IF ((request->criteriatype="P"))
  IF ((((request->action_type="Remove")) OR ((request->action_type="Update"))) )
   UPDATE  FROM dm_retention_criteria drc
    SET drc.active_ind = 0, drc.end_effective_dt_tm = cnvtdatetime(curdate,curtime3)
    WHERE (drc.organization_id=request->organization_id)
     AND (drc.event_cd=request->event_cd)
     AND drc.active_ind=1
    WITH nocounter
   ;end update
  ENDIF
  SET next_seq_val = 0
  SELECT INTO "nl:"
   y = seq(dm_retention_criteria_seq,nextval)
   FROM dual
   DETAIL
    next_seq_val = cnvtreal(y)
   WITH nocounter
  ;end select
  IF ((((request->action_type="Add")) OR ((request->action_type="Update"))) )
   INSERT  FROM dm_retention_criteria drc
    SET drc.retention_criteria_id = next_seq_val, drc.criteria_type_cd = request->p_criteria_type_cd,
     drc.retention_days = 0,
     drc.organization_id = request->organization_id, drc.encntr_type_cd = request->encntr_type_cd,
     drc.event_cd = request->event_cd,
     drc.parent_ret_criteria_id = 0, drc.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), drc
     .end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
     drc.active_ind = 1, drc.apply_ind = 0
    WITH nocounter
   ;end insert
   SET next_seq_value = 0
   SELECT INTO "nl:"
    z = seq(dm_retention_criteria_seq,nextval)
    FROM dual
    DETAIL
     next_seq_value = cnvtreal(z)
    WITH nocounter
   ;end select
   INSERT  FROM dm_retention_criteria drc
    SET drc.retention_criteria_id = next_seq_value, drc.criteria_type_cd = request->criteria_type_cd,
     drc.retention_days = request->retention_days,
     drc.organization_id = request->organization_id, drc.encntr_type_cd = request->encntr_type_cd,
     drc.event_cd = request->event_cd,
     drc.parent_ret_criteria_id = next_seq_val, drc.beg_effective_dt_tm = cnvtdatetime(curdate,
      curtime3), drc.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
     drc.active_ind = 1, drc.apply_ind = 0
    WITH nocounter
   ;end insert
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
 COMMIT
END GO
