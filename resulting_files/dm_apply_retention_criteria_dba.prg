CREATE PROGRAM dm_apply_retention_criteria:dba
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c8
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
    1 ops_event = c100
  )
 ENDIF
 SET reply->status_data.status = "S"
 SET dm_overall_status = "S"
 RECORD dm_request(
   1 enc[*]
     2 encntr_id = f8
     2 org_id = f8
     2 encntr_type = f8
     2 encntr_complete_dt_tm = dq8
     2 archive_dt_tm = dq8
   1 enc_cnt = i4
   1 aenccomplete_days = f8
   1 parent_criteria_id = f8
   1 process_type = vc
 )
 SET dm_request->process_type = "OPS_BATCH_APPLY"
 SET dm_emsg = fillstring(100," ")
 SET trace = errorclear
 SET dm_cemsg = fillstring(132," ")
 SET dm_ecode = 0
 RECORD dm_criteria(
   1 parent[*]
     2 parent_criteria_id = f8
     2 org_id = f8
     2 encntr_type_cd = f8
 )
 SET parent_cnt = 0
 IF (validate(dm_pa_codes->crit_type.aenccomplete_cd,1)=1)
  SET trace = recpersist
  RECORD dm_pa_codes(
    1 crit_type[1]
      2 aenccomplete_cd = f8
      2 archparent_cd = f8
    1 action[1]
      2 set_arch_dt_tm_cd = f8
      2 next_action_cd = f8
      2 failed_set_arch_dt_tm_cd = f8
  )
  SET trace = norecpersist
  EXECUTE dm_get_pa_codes
 ENDIF
 SELECT INTO "nl:"
  drc.organization_id
  FROM dm_retention_criteria drc
  WHERE (drc.criteria_type_cd=dm_pa_codes->crit_type[1].archparent_cd)
   AND drc.active_ind=1
   AND drc.apply_ind=1
  DETAIL
   parent_cnt = (parent_cnt+ 1), stat = alterlist(dm_criteria->parent,parent_cnt), dm_criteria->
   parent[parent_cnt].parent_criteria_id = drc.retention_criteria_id,
   dm_criteria->parent[parent_cnt].org_id = drc.organization_id, dm_criteria->parent[parent_cnt].
   encntr_type_cd = drc.encntr_type_cd
  WITH nocounter
 ;end select
 FOR (forcnt = 1 TO parent_cnt)
   SET more_rows = 1
   SET dm_request->parent_criteria_id = 0
   SET dm_request->aenccomplete_days = 0
   SET dm_request->parent_criteria_id = dm_criteria->parent[forcnt].parent_criteria_id
   SELECT INTO "nl:"
    d.retention_days
    FROM dm_retention_criteria d
    WHERE (d.parent_ret_criteria_id=dm_criteria->parent[forcnt].parent_criteria_id)
     AND d.active_ind=1
     AND (d.criteria_type_cd=dm_pa_codes->crit_type[1].aenccomplete_cd)
    DETAIL
     dm_request->aenccomplete_days = d.retention_days
    WITH nocounter
   ;end select
   SET reply->status_data.status = "S"
   WHILE (more_rows > 0
    AND (reply->status_data.status="S"))
     SET more_rows = 0
     SET stat = alterlist(dm_request->enc,0)
     SET dm_request->enc_cnt = 0
     SELECT
      IF ((dm_criteria->parent[forcnt].org_id=0))
       WHERE e.organization_id > 0
        AND (e.encntr_type_cd=dm_criteria->parent[forcnt].encntr_type_cd)
        AND e.archive_dt_tm_act=cnvtdatetime("31-dec-2100")
        AND (e.parent_ret_criteria_id != dm_criteria->parent[forcnt].parent_criteria_id)
        AND e.encntr_complete_dt_tm < cnvtdatetime("31-dec-2100")
        AND  NOT ( EXISTS (
       (SELECT
        "x"
        FROM dm_retention_criteria d
        WHERE d.organization_id=e.organization_id
         AND d.encntr_type_cd=e.encntr_type_cd
         AND (d.criteria_type_cd=dm_pa_codes->crit_type[1].archparent_cd)
         AND d.active_ind=1)))
        AND sqlpassthru("rownum < 2501")
      ELSEIF ((dm_criteria->parent[forcnt].org_id > 0))
       WHERE (e.organization_id=dm_criteria->parent[forcnt].org_id)
        AND (e.encntr_type_cd=dm_criteria->parent[forcnt].encntr_type_cd)
        AND e.archive_dt_tm_act=cnvtdatetime("31-dec-2100")
        AND (e.parent_ret_criteria_id != dm_criteria->parent[forcnt].parent_criteria_id)
        AND e.encntr_complete_dt_tm < cnvtdatetime("31-dec-2100")
        AND sqlpassthru("rownum < 2501")
      ELSE
      ENDIF
      INTO "nl:"
      e.encntr_id
      FROM encounter e
      DETAIL
       dm_request->enc_cnt = (dm_request->enc_cnt+ 1), stat = alterlist(dm_request->enc,dm_request->
        enc_cnt), dm_request->enc[dm_request->enc_cnt].encntr_id = e.encntr_id,
       dm_request->enc[dm_request->enc_cnt].org_id = e.organization_id, dm_request->enc[dm_request->
       enc_cnt].encntr_type = e.encntr_type_cd, dm_request->enc[dm_request->enc_cnt].
       encntr_complete_dt_tm = e.encntr_complete_dt_tm
      WITH nocounter
     ;end select
     IF ((dm_request->enc_cnt=2500))
      SET more_rows = 1
     ENDIF
     IF ((dm_request->enc_cnt > 0))
      EXECUTE dm_set_archive_dt_tm
     ENDIF
   ENDWHILE
   IF (more_rows=0
    AND (reply->status_data.status="S"))
    UPDATE  FROM dm_retention_criteria
     SET apply_ind = 0, last_apply_dt_tm = cnvtdatetime(curdate,curtime3)
     WHERE (((retention_criteria_id=dm_request->parent_criteria_id)) OR ((parent_ret_criteria_id=
     dm_request->parent_criteria_id)))
     WITH nocounter
    ;end update
    COMMIT
   ELSEIF ((reply->status_data.status="F")
    AND dm_overall_status="S")
    SET dm_overall_status = "F"
   ENDIF
 ENDFOR
 IF (dm_overall_status="F")
  SET reply->status_data.status = "F"
  SET reply->ops_event = dm_emsg
 ENDIF
END GO
