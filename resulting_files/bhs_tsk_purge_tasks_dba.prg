CREATE PROGRAM bhs_tsk_purge_tasks:dba
 FREE RECORD internal
 RECORD internal(
   1 all_rule_qual[*]
     2 task_status_flag = f8
     2 task_type_cd = vc
     2 patient_status_flag = i2
     2 active_ind = i2
     2 retention_days = i4
     2 task_status_null = i2
     2 active_status_null = i2
     2 patient_status_null = i2
 )
 RECORD reply(
   1 file_name = c100
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
   1 ccl_error_msg = c132
   1 request_id = f8
 )
 RECORD tmp(
   1 qual[*]
     2 task_id = f8
 )
 RECORD tsk_err(
   1 tsk_errmsg = c132
   1 tsk_errcode = i4
 )
 RECORD active_status(
   1 qual[*]
     2 code_value = f8
 )
 RECORD finalized_status(
   1 qual[*]
     2 code_value = f8
 )
 RECORD dropped_status(
   1 qual[*]
     2 code_value = f8
 )
 DECLARE init_val = i4
 DECLARE num_to_purge = i4
 SET rule_cnt = 0
 SET currentdttm = cnvtdatetime(curdate,curtime)
 SET select_encntr = 0
 SET purge_task_ind = 0
 DECLARE active_filter = i4 WITH protect, constant(2)
 DECLARE dropped_filter = i4 WITH protect, constant(1)
 DECLARE finalized_filter = i4 WITH protect, constant(0)
 DECLARE active_value = i4 WITH protect, constant(4)
 DECLARE dropped_value = i4 WITH protect, constant(2)
 DECLARE finalized_value = i4 WITH protect, constant(1)
 DECLARE failed_purge = c1
 SET stat = alterlist(active_status->qual,10)
 SET stat = alterlist(dropped_status->qual,10)
 SET stat = alterlist(finalized_status->qual,10)
 SELECT INTO "nl:"
  cve.code_value
  FROM code_value_extension cve
  WHERE cve.code_set=79
   AND cve.field_name="PurgeStatus"
  HEAD REPORT
   active_cnt = 0, dropped_cnt = 0, finalized_cnt = 0
  DETAIL
   extension = cnvtint(cve.field_value)
   IF (band(extension,active_value))
    active_cnt = (active_cnt+ 1)
    IF (active_cnt > size(active_status->qual,5))
     stat = alterlist(active_status->qual,(active_cnt+ 10))
    ENDIF
    active_status->qual[active_cnt].code_value = cve.code_value
   ENDIF
   IF (band(extension,dropped_value))
    dropped_cnt = (dropped_cnt+ 1)
    IF (dropped_cnt > size(dropped_status->qual,5))
     stat = alterlist(dropped_status->qual,(dropped_cnt+ 10))
    ENDIF
    dropped_status->qual[dropped_cnt].code_value = cve.code_value
   ENDIF
   IF (band(extension,finalized_value))
    finalized_cnt = (finalized_cnt+ 1)
    IF (finalized_cnt > size(finalized_status->qual,5))
     stat = alterlist(finalized_status->qual,(finalized_cnt+ 10))
    ENDIF
    finalized_status->qual[finalized_cnt].code_value = cve.code_value
   ENDIF
  FOOT REPORT
   stat = alterlist(active_status->qual,active_cnt), stat = alterlist(dropped_status->qual,
    dropped_cnt), stat = alterlist(finalized_status->qual,finalized_cnt)
  WITH nocounter
 ;end select
 SELECT DISTINCT INTO "nl:"
  p.task_status_flag, p.patient_status_flag, p.purge_active_flag,
  p.retention_days, task_null = nullind(p.task_status_flag), purge_null = nullind(p.purge_active_flag
   ),
  pat_null = nullind(p.patient_status_flag)
  FROM tl_purge_criteria p
  WHERE p.active_ind=1
   AND p.tl_purge_id > 0
   AND p.retention_days >= 15
   AND ((p.task_status_flag != null) OR (((p.patient_status_flag != null) OR (((p.purge_active_flag
   != null) OR (p.task_type_cd != null)) )) ))
  DETAIL
   rule_cnt = (rule_cnt+ 1)
   IF (rule_cnt > size(internal->all_rule_qual,5))
    stat = alterlist(internal->all_rule_qual,(rule_cnt+ 10))
   ENDIF
   internal->all_rule_qual[rule_cnt].task_status_flag =
   IF (p.task_status_flag=null) null
   ELSE p.task_status_flag
   ENDIF
   , internal->all_rule_qual[rule_cnt].patient_status_flag =
   IF (p.patient_status_flag=null) null
   ELSE p.patient_status_flag
   ENDIF
   , internal->all_rule_qual[rule_cnt].active_ind =
   IF (p.purge_active_flag=null) null
   ELSE p.purge_active_flag
   ENDIF
   ,
   internal->all_rule_qual[rule_cnt].retention_days = p.retention_days, internal->all_rule_qual[
   rule_cnt].task_status_null = task_null, internal->all_rule_qual[rule_cnt].active_status_null =
   purge_null,
   internal->all_rule_qual[rule_cnt].patient_status_null = pat_null
  FOOT REPORT
   stat = alterlist(internal->all_rule_qual,rule_cnt)
  WITH nocounter
 ;end select
 IF (rule_cnt=0)
  SET failed_purge = "T"
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "READ"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TL_PURGE_CRITERIA"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "UNABLE TO RETRIEVE PURGE RULES"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  p.task_type_cd
  FROM tl_purge_criteria p,
   (dummyt d  WITH seq = value(size(internal->all_rule_qual,5)))
  PLAN (d)
   JOIN (p
   WHERE (((internal->all_rule_qual[d.seq].task_status_null=1)
    AND p.task_status_flag=null) OR ((internal->all_rule_qual[d.seq].task_status_null != 1)
    AND (p.task_status_flag=internal->all_rule_qual[d.seq].task_status_flag)))
    AND (((internal->all_rule_qual[d.seq].patient_status_null=1)
    AND p.patient_status_flag=null) OR ((internal->all_rule_qual[d.seq].patient_status_null != 1)
    AND (p.patient_status_flag=internal->all_rule_qual[d.seq].patient_status_flag)))
    AND (((internal->all_rule_qual[d.seq].active_status_null=1)
    AND p.purge_active_flag=null) OR ((internal->all_rule_qual[d.seq].active_status_null != 1)
    AND (p.purge_active_flag=internal->all_rule_qual[d.seq].active_ind)))
    AND (p.retention_days=internal->all_rule_qual[d.seq].retention_days)
    AND p.tl_purge_id > 0)
  ORDER BY d.seq
  HEAD d.seq
   first = "Y", null_added = 0
  DETAIL
   IF (p.task_type_cd IN (null, 0)
    AND null_added=0)
    rule_cnt = (rule_cnt+ 1), stat = alterlist(internal->all_rule_qual,rule_cnt), internal->
    all_rule_qual[rule_cnt].task_status_flag = internal->all_rule_qual[d.seq].task_status_flag,
    internal->all_rule_qual[rule_cnt].patient_status_flag = internal->all_rule_qual[d.seq].
    patient_status_flag, internal->all_rule_qual[rule_cnt].active_ind = internal->all_rule_qual[d.seq
    ].active_ind, internal->all_rule_qual[rule_cnt].retention_days = internal->all_rule_qual[d.seq].
    retention_days,
    internal->all_rule_qual[rule_cnt].active_status_null = internal->all_rule_qual[d.seq].
    active_status_null, internal->all_rule_qual[rule_cnt].patient_status_null = internal->
    all_rule_qual[d.seq].patient_status_null, internal->all_rule_qual[rule_cnt].task_status_null =
    internal->all_rule_qual[d.seq].task_status_null,
    null_added = 1
   ELSE
    IF (first="Y")
     internal->all_rule_qual[d.seq].task_type_cd = concat("(",trim(cnvtstring(p.task_type_cd),3)),
     first = "N"
    ELSE
     internal->all_rule_qual[d.seq].task_type_cd = concat(trim(internal->all_rule_qual[d.seq].
       task_type_cd,3),",",trim(cnvtstring(p.task_type_cd),3))
    ENDIF
   ENDIF
  FOOT  d.seq
   IF (textlen(internal->all_rule_qual[d.seq].task_type_cd) > 0)
    internal->all_rule_qual[d.seq].task_type_cd = concat(trim(internal->all_rule_qual[d.seq].
      task_type_cd,3),")")
   ENDIF
  WITH nocounter
 ;end select
 RECORD wc(
   1 ta_where_clause = vc
   1 tr_where_clause = vc
   1 e_where_clause = vc
 )
 FOR (x = 1 TO rule_cnt)
   SET wc->ta_where_clause = ""
   SET wc->tr_where_clause = ""
   SET wc->e_where_clause = ""
   SET select_encntr = 0
   SET wc->e_where_clause = " e.encntr_id = ta.encntr_id"
   IF (textlen(internal->all_rule_qual[x].task_type_cd) > 0)
    SET wc->tr_where_clause = concat(" ta.task_type_cd > 0 and ta.task_type_cd in ",trim(internal->
      all_rule_qual[x].task_type_cd,3)," ")
   ELSE
    SET wc->tr_where_clause = " ta.task_type_cd + 0 > 0 "
   ENDIF
   IF ((internal->all_rule_qual[x].task_status_null != 1))
    IF (textlen(internal->all_rule_qual[x].task_type_cd) > 0)
     SET wc->ta_where_clause = " ta.task_status_cd + 0 in ("
    ELSE
     SET wc->ta_where_clause = " ta.task_status_cd in ("
    ENDIF
    CALL echo(build("TASK_STATUS_FLAG::",internal->all_rule_qual[x].task_status_flag))
    CALL echo("case statement")
    CASE (internal->all_rule_qual[x].task_status_flag)
     OF finalized_filter:
      FOR (y = 1 TO value(size(finalized_status->qual,5)))
        IF (y=1)
         SET wc->ta_where_clause = concat(wc->ta_where_clause,cnvtstring(finalized_status->qual[y].
           code_value))
        ELSE
         SET wc->ta_where_clause = concat(wc->ta_where_clause,",",cnvtstring(finalized_status->qual[y
           ].code_value))
        ENDIF
      ENDFOR
     OF dropped_filter:
      FOR (y = 1 TO value(size(dropped_status->qual,5)))
        IF (y=1)
         SET wc->ta_where_clause = concat(wc->ta_where_clause,cnvtstring(dropped_status->qual[y].
           code_value))
        ELSE
         SET wc->ta_where_clause = concat(wc->ta_where_clause,",",cnvtstring(dropped_status->qual[y].
           code_value))
        ENDIF
      ENDFOR
     OF active_filter:
      FOR (y = 1 TO value(size(active_status->qual,5)))
        IF (y=1)
         SET wc->ta_where_clause = concat(wc->ta_where_clause,cnvtstring(active_status->qual[y].
           code_value))
        ELSE
         SET wc->ta_where_clause = concat(wc->ta_where_clause,",",cnvtstring(active_status->qual[y].
           code_value))
        ENDIF
      ENDFOR
    ENDCASE
    SET wc->ta_where_clause = concat(wc->ta_where_clause,")")
   ENDIF
   IF ((internal->all_rule_qual[x].patient_status_null=1))
    IF (textlen(trim(wc->ta_where_clause,3)) > 0)
     SET wc->ta_where_clause = concat(wc->ta_where_clause,
      " and datetimediff(cnvtdatetime(currentdttm), ta.updt_dt_tm) ",
      ">= internal->all_rule_qual[x].retention_days")
    ELSE
     SET wc->ta_where_clause =
     " datetimediff(cnvtdatetime(currentdttm),ta.updt_dt_tm) >= internal->all_rule_qual[x].retention_days "
    ENDIF
   ELSE
    IF ((internal->all_rule_qual[x].patient_status_flag=0))
     SET wc->e_where_clause = concat(wc->e_where_clause," and e.disch_dt_tm != NULL")
     SET wc->e_where_clause = concat(wc->e_where_clause,
      " and datetimediff(cnvtdatetime(currentdttm), e.disch_dt_tm) ",
      ">= internal->all_rule_qual[x].retention_days")
     SET select_encntr = 1
    ELSE
     IF (textlen(trim(wc->ta_where_clause,3)) > 0)
      SET wc->ta_where_clause = concat(wc->ta_where_clause,
       " and datetimediff(cnvtdatetime(currentdttm), ta.updt_dt_tm) ",
       ">= internal->all_rule_qual[x].retention_days")
     ELSE
      SET wc->ta_where_clause =
      " datetimediff(cnvtdatetime(currentdttm),ta.updt_dt_tm) >= internal->all_rule_qual[x].retention_days "
     ENDIF
     SET select_encntr = 2
    ENDIF
   ENDIF
   IF ((internal->all_rule_qual[x].active_status_null != 1))
    IF ((internal->all_rule_qual[x].active_ind=1))
     IF (textlen(trim(wc->ta_where_clause,3)) > 0)
      SET wc->ta_where_clause = concat(wc->ta_where_clause," and ta.active_ind = 1")
     ELSE
      SET wc->ta_where_clause = concat(wc->ta_where_clause," ta.active_ind = 1")
     ENDIF
    ELSEIF ((internal->all_rule_qual[x].active_ind=0))
     IF (textlen(trim(wc->ta_where_clause,3)) > 0)
      SET wc->ta_where_clause = concat(wc->ta_where_clause," and ta.active_ind = 0")
     ELSE
      SET wc->ta_where_clause = concat(wc->ta_where_clause," ta.active_ind= 0")
     ENDIF
    ENDIF
   ENDIF
   IF (select_encntr=1)
    IF (textlen(trim(wc->ta_where_clause,3)) > 0)
     SET wc->ta_where_clause = concat(trim(wc->ta_where_clause,3)," and ",trim(wc->e_where_clause,3))
    ELSE
     SET wc->ta_where_clause = trim(wc->e_where_clause,3)
    ENDIF
    CALL echo("entering tast_activity and encounter select")
    CALL echo(build("WC -> TR_WHERE_CLAUSE:",wc->tr_where_clause))
    CALL echo(build("WC -> TA_WHERE_CLAUSE:",wc->ta_where_clause))
    SELECT INTO "nl:"
     ta.task_id
     FROM task_activity ta,
      encounter e
     WHERE parser(wc->tr_where_clause)
      AND parser(wc->ta_where_clause)
     HEAD REPORT
      cnt = 0
     DETAIL
      cnt = (cnt+ 1), stat = alterlist(tmp->qual,cnt), tmp->qual[cnt].task_id = ta.task_id
     WITH nocounter
    ;end select
   ENDIF
   IF (select_encntr=2)
    SELECT INTO "nl:"
     ta.task_id
     FROM task_activity ta,
      encounter e
     WHERE parser(wc->tr_where_clause)
      AND parser(wc->ta_where_clause)
      AND ta.encntr_id=e.encntr_id
      AND e.disch_dt_tm=null
     HEAD REPORT
      cnt = 0
     DETAIL
      cnt = (cnt+ 1), stat = alterlist(tmp->qual,cnt), tmp->qual[cnt].task_id = ta.task_id
     WITH nocounter
    ;end select
   ENDIF
   IF (select_encntr=0)
    SELECT INTO "nl:"
     ta.task_id
     FROM task_activity ta
     WHERE parser(wc->tr_where_clause)
      AND parser(wc->ta_where_clause)
     HEAD REPORT
      cnt = 0
     DETAIL
      cnt = (cnt+ 1), stat = alterlist(tmp->qual,cnt), tmp->qual[cnt].task_id = ta.task_id
     WITH nocounter
    ;end select
   ENDIF
   SET init_val = 0
   SET num_to_purge = 50000
   IF (num_to_purge > size(tmp->qual,5))
    SET num_to_purge = size(tmp->qual,5)
   ENDIF
   IF (num_to_purge > 0)
    SET del_val = 1
    WHILE (del_val > 0)
      DELETE  FROM task_action t,
        (dummyt d  WITH seq = value(num_to_purge))
       SET t.seq = 1
       PLAN (d)
        JOIN (t
        WHERE (t.task_id=tmp->qual[(d.seq+ init_val)].task_id))
       WITH nocounter, maxcommit(1000)
      ;end delete
      SET tsk_err->tsk_errcode = error(tsk_err->tsk_errmsg,0)
      IF ((tsk_err->tsk_errcode != 0))
       SET failed_purge = "T"
       ROLLBACK
       GO TO exit_script
      ELSE
       COMMIT
      ENDIF
      DELETE  FROM task_reltn t,
        (dummyt d  WITH seq = value(num_to_purge))
       SET t.seq = 1
       PLAN (d)
        JOIN (t
        WHERE (((t.task_id=tmp->qual[(d.seq+ init_val)].task_id)) OR ((t.prereq_task_id=tmp->qual[(d
        .seq+ init_val)].task_id))) )
       WITH nocounter, maxcommit(1000)
      ;end delete
      SET tsk_err->tsk_errcode = error(tsk_err->tsk_errmsg,0)
      IF ((tsk_err->tsk_errcode != 0))
       SET failed_purge = "T"
       ROLLBACK
       GO TO exit_script
      ELSE
       COMMIT
      ENDIF
      DELETE  FROM task_activity_assignment t,
        (dummyt d  WITH seq = value(num_to_purge))
       SET t.seq = 1
       PLAN (d)
        JOIN (t
        WHERE (t.task_id=tmp->qual[(d.seq+ init_val)].task_id))
       WITH nocounter, maxcommit(1000)
      ;end delete
      SET tsk_err->tsk_errcode = error(tsk_err->tsk_errmsg,0)
      IF ((tsk_err->tsk_errcode != 0))
       SET failed_purge = "T"
       ROLLBACK
       GO TO exit_script
      ELSE
       COMMIT
      ENDIF
      DELETE  FROM task_activity t,
        (dummyt d  WITH seq = value(num_to_purge))
       SET t.seq = 1
       PLAN (d)
        JOIN (t
        WHERE (t.task_id=tmp->qual[(d.seq+ init_val)].task_id))
       WITH nocounter, maxcommit(1000)
      ;end delete
      SET tsk_err->tsk_errcode = error(tsk_err->tsk_errmsg,0)
      IF ((tsk_err->tsk_errcode != 0))
       SET failed_purge = "T"
       ROLLBACK
       GO TO exit_script
      ELSE
       COMMIT
      ENDIF
      IF (((init_val+ num_to_purge)=size(tmp->qual,5)))
       SET del_val = 0
      ELSE
       SET del_val = 1
       SET init_val = (init_val+ num_to_purge)
       IF (((size(tmp->qual,5) - init_val) < num_to_purge))
        SET num_to_purge = (size(tmp->qual,5) - init_val)
       ENDIF
      ENDIF
    ENDWHILE
   ENDIF
 ENDFOR
 FREE RECORD active_status
 FREE RECORD dropped_status
 FREE RECORD finalized_status
 SET scriptversion = "05/02/06"
#exit_script
 IF (failed_purge="T")
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
