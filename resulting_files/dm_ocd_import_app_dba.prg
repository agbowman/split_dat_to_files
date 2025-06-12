CREATE PROGRAM dm_ocd_import_app:dba
 FREE SET status
 RECORD status(
   1 qual[*]
     2 exist = i1
 )
 SET stat = alterlist(status->qual,atr->atr_count)
 CALL echo("Importing Applications into clinical tables...")
 SELECT INTO "nl:"
  a.application_number
  FROM application a,
   (dummyt d  WITH seq = value(atr->atr_count))
  PLAN (d)
   JOIN (a
   WHERE (a.application_number=atr->atr_list[d.seq].application_number))
  DETAIL
   status->qual[d.seq].exist = 1
  WITH nocounter
 ;end select
 CALL echo("  Updating existing Applications into clinical tables...")
 UPDATE  FROM application a,
   (dummyt d  WITH seq = value(atr->atr_count))
  SET a.seq = 1, a.owner = atr->atr_list[d.seq].owner, a.description = atr->atr_list[d.seq].
   description,
   a.object_name = atr->atr_list[d.seq].object_name, a.disable_cache_ind = atr->atr_list[d.seq].
   disable_cache_ind, a.text = atr->atr_list[d.seq].text,
   a.common_application_ind = atr->atr_list[d.seq].common_application_ind, a.updt_dt_tm =
   cnvtdatetime(curdate,curtime3), a.updt_task = reqinfo->updt_task,
   a.updt_id = 0.0, a.updt_cnt = 0, a.updt_applctx = 0
  PLAN (d
   WHERE (status->qual[d.seq].exist=1)
    AND (atr->atr_list[d.seq].deleted_ind != 1))
   JOIN (a
   WHERE (a.application_number=atr->atr_list[d.seq].application_number))
  WITH nocounter
 ;end update
 CALL echo("  Inserting new Applications into clinical tables...")
 INSERT  FROM application a,
   (dummyt d  WITH seq = value(atr->atr_count))
  SET a.seq = 1, a.application_number = atr->atr_list[d.seq].application_number, a.description = atr
   ->atr_list[d.seq].description,
   a.owner = atr->atr_list[d.seq].owner, a.log_access_ind = atr->atr_list[d.seq].log_access_ind, a
   .direct_access_ind = atr->atr_list[d.seq].direct_access_ind,
   a.application_ini_ind = atr->atr_list[d.seq].application_ini_ind, a.log_level = 0, a
   .request_log_level = 0,
   a.min_version_required = atr->atr_list[d.seq].min_version_required, a.object_name = atr->atr_list[
   d.seq].object_name, a.last_localized_dt_tm =
   IF ((atr->atr_list[d.seq].last_localized_dt_tm > 0)) cnvtdatetime(atr->atr_list[d.seq].
     last_localized_dt_tm)
   ELSE null
   ENDIF
   ,
   a.active_ind = atr->atr_list[d.seq].active_ind, a.active_dt_tm =
   IF ((atr->atr_list[d.seq].active_dt_tm > 0)) cnvtdatetime(atr->atr_list[d.seq].active_dt_tm)
   ELSE null
   ENDIF
   , a.inactive_dt_tm =
   IF ((atr->atr_list[d.seq].inactive_dt_tm > 0)) cnvtdatetime(atr->atr_list[d.seq].inactive_dt_tm)
   ELSE null
   ENDIF
   ,
   a.disable_cache_ind = atr->atr_list[d.seq].disable_cache_ind, a.text = atr->atr_list[d.seq].text,
   a.common_application_ind = atr->atr_list[d.seq].common_application_ind,
   a.updt_dt_tm = cnvtdatetime(curdate,curtime3), a.updt_task = reqinfo->updt_task, a.updt_id = 0.0,
   a.updt_cnt = 0, a.updt_applctx = 0
  PLAN (d
   WHERE (status->qual[d.seq].exist=0)
    AND (atr->atr_list[d.seq].deleted_ind != 1))
   JOIN (a)
  WITH nocounter
 ;end insert
 IF (currdb="ORACLE")
  SELECT INTO "nl:"
   t.table_name
   FROM user_tables t
   WHERE t.table_name="OCD_INSTALL_LOG"
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = 1)
   WITH nocounter
  ;end select
 ENDIF
 IF (curqual
  AND validate(ocd_number,0))
  FOR (app_cnt = 1 TO atr->atr_count)
    IF ((status->qual[app_cnt].exist=0))
     DELETE  FROM ocd_install_log l
      WHERE l.component_type="APPLICATION"
       AND l.end_state=trim(cnvtstring(atr->atr_list[app_cnt].application_number),3)
      WITH nocounter
     ;end delete
     SET atr_log_id = 0.0
     SELECT INTO "nl:"
      y = seq(dm_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       atr_log_id = y
      WITH nocounter
     ;end select
     INSERT  FROM ocd_install_log l
      SET l.log_id = atr_log_id, l.install_dt_tm = cnvtdatetime(curdate,curtime3), l.ocd = ocd_number,
       l.component_type = "APPLICATION", l.end_state = trim(cnvtstring(atr->atr_list[app_cnt].
         application_number),3), l.update_ind = 0
      WITH nocounter
     ;end insert
    ENDIF
  ENDFOR
 ENDIF
 COMMIT
END GO
