CREATE PROGRAM dm_ea_cleanup:dba
 PROMPT
  "Hours to Keep (2)?" = 2,
  "Max rows to purge between commits (5000)?" = 5000
  WITH hourstokeep, commitrows
 DECLARE lookbehindstring = vc
 DECLARE latestupdatetime = f8
 SET lookbehindstring = concat(trim(cnvtstring( $HOURSTOKEEP)),",H")
 SET latestupdatetime = cnvtlookbehind(lookbehindstring)
 DECLARE trigger_cnt = i4
 DECLARE trigger_idx = i4
 DECLARE total_rows_purged = i4
 DECLARE records_were_purged = i2
 SET records_were_purged = 0
 RECORD trigger_list(
   1 trigger[*]
     2 parent_name = vc
 )
 DECLARE new_purge_flag = i2
 SET new_purge_flag = 0
 SELECT INTO "nl:"
  dpt.template_nbr
  FROM dm_purge_template dpt
  WHERE dpt.template_nbr=123
   AND dpt.feature_nbr=39453
  DETAIL
   new_purge_flag = 1
  WITH nocounter
 ;end select
 IF (new_purge_flag=1)
  UPDATE  FROM dm_purge_template dpt
   SET dpt.active_ind = 0
   WHERE dpt.template_nbr=123
    AND dpt.feature_nbr=22597
  ;end update
  COMMIT
 ENDIF
 CALL echo("Determining active triggers")
 SELECT INTO "nl:"
  *
  FROM dm_entity_activity_trigger deat
  WHERE deat.active_ind=1
  DETAIL
   IF (trigger_cnt=0)
    trigger_cnt = (trigger_cnt+ 1)
   ELSE
    IF ( NOT (expand(trigger_idx,1,trigger_cnt,deat.parent_name,trigger_list->trigger[trigger_idx].
     parent_name)))
     trigger_cnt = (trigger_cnt+ 1)
    ENDIF
   ENDIF
   stat = alterlist(trigger_list->trigger,trigger_cnt), trigger_list->trigger[trigger_cnt].
   parent_name = deat.parent_name
  WITH nocounter
 ;end select
 SET trigger_cnt = (trigger_cnt+ 1)
 SET stat = alterlist(trigger_list->trigger,trigger_cnt)
 SET trigger_list->trigger[trigger_cnt].parent_name = "DM_ENTITY_ACTIVITY"
 CALL echo("Starting the dm_entity_activity purge")
 RECORD purge_list(
   1 ea_record[*]
     2 id = f8
 )
 SET total_rows_purged = 0
 DECLARE done = i2
 DECLARE purge_cnt = i4
 DECLARE purge_idx = i4
 SET done = 0
 WHILE (done=0)
   CALL echo("Reading purge rows")
   SET purge_cnt = 0
   SELECT INTO "nl:"
    FROM dm_entity_activity dea
    WHERE dea.updt_dt_tm < cnvtdatetime(latestupdatetime)
     AND ((dea.entity_activity_id+ 0) != 0)
     AND ((dea.parent_entity_id+ 0) != 0)
    HEAD REPORT
     purge_cnt = 0
    DETAIL
     purge_cnt = (purge_cnt+ 1)
     IF (purge_cnt > size(purge_list->ea_record,5))
      stat = alterlist(purge_list->ea_record,(purge_cnt+ 1000))
     ENDIF
     purge_list->ea_record[purge_cnt].id = dea.entity_activity_id
    FOOT REPORT
     stat = alterlist(purge_list->ea_record,purge_cnt)
    WITH maxqual(dea, $COMMITROWS), nocounter
   ;end select
   CALL echo(build2("Purging ",purge_cnt," dm_entity_activity rows"))
   IF (purge_cnt > 0)
    DELETE  FROM dm_entity_activity dea
     WHERE expand(purge_idx,1,purge_cnt,dea.entity_activity_id,purge_list->ea_record[purge_idx].id)
     WITH nocounter
    ;end delete
    SET total_rows_purged = (total_rows_purged+ purge_cnt)
    UPDATE  FROM dm_entity_activity ea
     SET ea.updt_dt_tm = sysdate, ea.updt_id = reqinfo->updt_id, ea.updt_cnt = (ea.updt_cnt+ 1),
      ea.updt_applctx = reqinfo->updt_applctx, ea.updt_task = reqinfo->updt_task
     WHERE ea.parent_entity_name="DM_ENTITY_ACTIVITY"
      AND ea.parent_entity_id=0
     WITH nocounter
    ;end update
    IF (curqual=0)
     INSERT  FROM dm_entity_activity ea
      SET ea.entity_activity_id = seq(dm_clinical_seq,nextval), ea.parent_entity_name =
       "DM_ENTITY_ACTIVITY", ea.parent_entity_id = 0,
       ea.updt_dt_tm = sysdate, ea.updt_id = reqinfo->updt_id, ea.updt_cnt = 0,
       ea.updt_applctx = reqinfo->updt_applctx, ea.updt_task = reqinfo->updt_task
      WITH nocounter
     ;end insert
     SET records_were_purged = 1
    ENDIF
    COMMIT
    CALL echo("Committed")
    CALL echo(build2(total_rows_purged," dm_entity_activity_records purged so far"))
    CALL echo("")
    CALL echo("")
   ELSE
    SET done = 1
   ENDIF
 ENDWHILE
 CALL echo("Purging remaining rows not associated to active triggers")
 SET done = 0
 WHILE (done=0)
   SET purge_cnt = 0
   SELECT
    IF (trigger_cnt > 0)INTO "nl:"
     FROM dm_entity_activity dea
     WHERE  NOT (expand(trigger_idx,1,trigger_cnt,dea.parent_entity_name,trigger_list->trigger[
      trigger_cnt].parent_name))
      AND ((dea.entity_activity_id+ 0) != 0)
      AND dea.parent_entity_id != 0
    ELSE INTO "nl:"
     FROM dm_entity_activity dea
     WHERE ((dea.entity_activity_id+ 0) != 0)
    ENDIF
    HEAD REPORT
     purge_cnt = 0
    DETAIL
     purge_cnt = (purge_cnt+ 1)
     IF (purge_cnt > size(purge_list->ea_record,5))
      stat = alterlist(purge_list->ea_record,(purge_cnt+ 1000))
     ENDIF
     purge_list->ea_record[purge_cnt].id = dea.entity_activity_id
    FOOT REPORT
     stat = alterlist(purge_list->ea_record,purge_cnt)
    WITH maxqual(dea, $COMMITROWS), nocounter
   ;end select
   CALL echo(build2("Purging ",purge_cnt," dm_entity_activity rows"))
   IF (purge_cnt > 0)
    DELETE  FROM dm_entity_activity dea
     WHERE expand(purge_idx,1,purge_cnt,dea.entity_activity_id,purge_list->ea_record[purge_idx].id)
     WITH nocounter
    ;end delete
    SET records_were_purged = 1
    SET total_rows_purged = (total_rows_purged+ purge_cnt)
    UPDATE  FROM dm_entity_activity ea
     SET ea.updt_dt_tm = sysdate, ea.updt_id = reqinfo->updt_id, ea.updt_cnt = (ea.updt_cnt+ 1),
      ea.updt_applctx = reqinfo->updt_applctx, ea.updt_task = reqinfo->updt_task
     WHERE ea.parent_entity_name="DM_ENTITY_ACTIVITY"
      AND ea.parent_entity_id=0
     WITH nocounter
    ;end update
    IF (curqual=0)
     INSERT  FROM dm_entity_activity ea
      SET ea.entity_activity_id = seq(dm_clinical_seq,nextval), ea.parent_entity_name =
       "DM_ENTITY_ACTIVITY", ea.parent_entity_id = 0,
       ea.updt_dt_tm = sysdate, ea.updt_id = reqinfo->updt_id, ea.updt_cnt = 0,
       ea.updt_applctx = reqinfo->updt_applctx, ea.updt_task = reqinfo->updt_task
      WITH nocounter
     ;end insert
    ENDIF
    COMMIT
    CALL echo("Committed")
    CALL echo(build2(total_rows_purged," dm_entity_activity_records purged so far"))
    CALL echo("")
    CALL echo("")
   ELSE
    SET done = 1
   ENDIF
 ENDWHILE
END GO
