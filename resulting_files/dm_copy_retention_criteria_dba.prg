CREATE PROGRAM dm_copy_retention_criteria:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF ((request->criteriatype="A"))
  UPDATE  FROM dm_retention_criteria d1
   SET d1.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), d1.active_ind = 0
   WHERE (d1.organization_id=request->to_org_id)
    AND (d1.criteria_type_cd=request->criteria_type_cd)
    AND d1.active_ind=1
   WITH nocounter
  ;end update
  UPDATE  FROM dm_retention_criteria d1
   SET d1.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), d1.active_ind = 0
   WHERE (d1.organization_id=request->to_org_id)
    AND (d1.criteria_type_cd=request->p_criteria_type_cd)
    AND d1.active_ind=1
   WITH nocounter
  ;end update
  INSERT  FROM dm_retention_criteria d1
   (d1.retention_criteria_id, d1.criteria_type_cd, d1.retention_days,
   d1.organization_id, d1.encntr_type_cd, d1.event_cd,
   d1.beg_effective_dt_tm, d1.end_effective_dt_tm, d1.active_ind,
   d1.apply_ind, d1.parent_ret_criteria_id)(SELECT
    seq(dm_retention_criteria_seq,nextval), d2.criteria_type_cd, d2.retention_days,
    request->to_org_id, d2.encntr_type_cd, d2.event_cd,
    cnvtdatetime(curdate,curtime3), cnvtdatetime("31-dec-2100"), d2.active_ind,
    1, 0
    FROM dm_retention_criteria d2
    WHERE (d2.organization_id=request->from_org_id)
     AND (d2.criteria_type_cd=request->p_criteria_type_cd)
     AND d2.active_ind=1)
  ;end insert
  INSERT  FROM dm_retention_criteria d1
   (d1.retention_criteria_id, d1.criteria_type_cd, d1.retention_days,
   d1.organization_id, d1.encntr_type_cd, d1.event_cd,
   d1.beg_effective_dt_tm, d1.end_effective_dt_tm, d1.active_ind,
   d1.apply_ind, d1.parent_ret_criteria_id)(SELECT
    seq(dm_retention_criteria_seq,nextval), d2.criteria_type_cd, d2.retention_days,
    request->to_org_id, d2.encntr_type_cd, d2.event_cd,
    cnvtdatetime(curdate,curtime3), cnvtdatetime("31-dec-2100"), d2.active_ind,
    1, d3.retention_criteria_id
    FROM dm_retention_criteria d2,
     dm_retention_criteria d3
    WHERE (d2.organization_id=request->from_org_id)
     AND (d2.criteria_type_cd=request->criteria_type_cd)
     AND d2.active_ind=1
     AND d3.encntr_type_cd=d2.encntr_type_cd
     AND (d3.organization_id=request->to_org_id)
     AND (d3.criteria_type_cd=request->p_criteria_type_cd)
     AND d3.active_ind=1)
  ;end insert
 ENDIF
 IF ((request->criteriatype="P"))
  UPDATE  FROM dm_retention_criteria d1
   SET d1.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), d1.active_ind = 0
   WHERE (d1.organization_id=request->to_org_id)
    AND (d1.criteria_type_cd=request->criteria_type_cd)
    AND d1.active_ind=1
   WITH nocounter
  ;end update
  UPDATE  FROM dm_retention_criteria d1
   SET d1.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), d1.active_ind = 0
   WHERE (d1.organization_id=request->to_org_id)
    AND (d1.criteria_type_cd=request->p_criteria_type_cd)
    AND d1.active_ind=1
   WITH nocounter
  ;end update
  INSERT  FROM dm_retention_criteria d1
   (d1.retention_criteria_id, d1.criteria_type_cd, d1.retention_days,
   d1.organization_id, d1.encntr_type_cd, d1.event_cd,
   d1.beg_effective_dt_tm, d1.end_effective_dt_tm, d1.active_ind,
   d1.apply_ind, d1.parent_ret_criteria_id)(SELECT
    seq(dm_retention_criteria_seq,nextval), d2.criteria_type_cd, d2.retention_days,
    request->to_org_id, d2.encntr_type_cd, d2.event_cd,
    cnvtdatetime(curdate,curtime3), cnvtdatetime("31-dec-2100"), d2.active_ind,
    0, 0
    FROM dm_retention_criteria d2
    WHERE (d2.organization_id=request->from_org_id)
     AND (d2.criteria_type_cd=request->p_criteria_type_cd)
     AND d2.active_ind=1)
  ;end insert
  INSERT  FROM dm_retention_criteria d1
   (d1.retention_criteria_id, d1.criteria_type_cd, d1.retention_days,
   d1.organization_id, d1.encntr_type_cd, d1.event_cd,
   d1.beg_effective_dt_tm, d1.end_effective_dt_tm, d1.active_ind,
   d1.apply_ind, d1.parent_ret_criteria_id)(SELECT
    seq(dm_retention_criteria_seq,nextval), d2.criteria_type_cd, d2.retention_days,
    request->to_org_id, d2.encntr_type_cd, d2.event_cd,
    cnvtdatetime(curdate,curtime3), cnvtdatetime("31-dec-2100"), d2.active_ind,
    0, d3.retention_criteria_id
    FROM dm_retention_criteria d2,
     dm_retention_criteria d3
    WHERE (d2.organization_id=request->from_org_id)
     AND (d2.criteria_type_cd=request->criteria_type_cd)
     AND d2.active_ind=1
     AND d3.event_cd=d2.event_cd
     AND (d3.organization_id=request->to_org_id)
     AND (d3.criteria_type_cd=request->p_criteria_type_cd)
     AND d3.active_ind=1)
  ;end insert
 ENDIF
 IF (curqual > 0)
  COMMIT
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
END GO
