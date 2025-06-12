CREATE PROGRAM dm_ocd_import_req:dba
 FREE SET status
 RECORD status(
   1 qual[*]
     2 exist = i1
 )
 SET stat = alterlist(status->qual,atr->atr_count)
 SET new_cache_col_ind = 0
 SELECT INTO "nl:"
  FROM user_tab_columns u
  WHERE u.table_name="REQUEST"
   AND u.column_name IN ("CACHEGRACE", "CACHESTALE", "CACHETRIM")
  WITH nocounter
 ;end select
 IF (curqual=3)
  SET new_cache_col_ind = 1
 ENDIF
 CALL echo("Importing Requests into clinical tables...")
 SELECT INTO "nl:"
  r.request_number
  FROM request r,
   (dummyt d  WITH seq = value(atr->atr_count))
  PLAN (d)
   JOIN (r
   WHERE (r.request_number=atr->atr_list[d.seq].request_number))
  DETAIL
   status->qual[d.seq].exist = 1
  WITH nocounter
 ;end select
 CALL echo("  Updating existing Requests into clinical tables...")
 UPDATE  FROM request r,
   (dummyt d  WITH seq = value(atr->atr_count))
  SET r.seq = 1, r.description = atr->atr_list[d.seq].description, r.text = atr->atr_list[d.seq].text,
   r.request_name = atr->atr_list[d.seq].request_name, r.epilog_script = atr->atr_list[d.seq].
   epilog_script, r.prolog_script = atr->atr_list[d.seq].prolog_script,
   r.write_to_que_ind = atr->atr_list[d.seq].write_to_que_ind, r.updt_dt_tm = cnvtdatetime(curdate,
    curtime3), r.updt_task = reqinfo->updt_task,
   r.updt_id = 0.0, r.updt_cnt = 0, r.updt_applctx = 0
  PLAN (d
   WHERE (status->qual[d.seq].exist=1)
    AND (atr->atr_list[d.seq].deleted_ind != 1))
   JOIN (r
   WHERE (r.request_number=atr->atr_list[d.seq].request_number))
  WITH nocounter
 ;end update
 CALL echo("  Inserting new Requests into clinical tables...")
 IF (new_cache_col_ind=1)
  INSERT  FROM request r,
    (dummyt d  WITH seq = value(atr->atr_count))
   SET r.seq = 1, r.request_number = atr->atr_list[d.seq].request_number, r.description = atr->
    atr_list[d.seq].description,
    r.text = atr->atr_list[d.seq].text, r.request_name = atr->atr_list[d.seq].request_name, r
    .epilog_script = atr->atr_list[d.seq].epilog_script,
    r.prolog_script = atr->atr_list[d.seq].prolog_script, r.write_to_que_ind = atr->atr_list[d.seq].
    write_to_que_ind, r.cachetime = atr->atr_list[d.seq].cachetime,
    r.active_ind = atr->atr_list[d.seq].active_ind, r.active_dt_tm =
    IF ((atr->atr_list[d.seq].active_dt_tm > 0)) cnvtdatetime(atr->atr_list[d.seq].active_dt_tm)
    ELSE null
    ENDIF
    , r.inactive_dt_tm =
    IF ((atr->atr_list[d.seq].inactive_dt_tm > 0)) cnvtdatetime(atr->atr_list[d.seq].inactive_dt_tm)
    ELSE null
    ENDIF
    ,
    r.cachegrace = atr->atr_list[d.seq].cachegrace, r.cachestale = atr->atr_list[d.seq].cachestale, r
    .cachetrim = atr->atr_list[d.seq].cachetrim,
    r.updt_dt_tm = cnvtdatetime(curdate,curtime3), r.updt_task = reqinfo->updt_task, r.updt_id = 0.0,
    r.updt_cnt = 0, r.updt_applctx = 0
   PLAN (d
    WHERE (status->qual[d.seq].exist=0)
     AND (atr->atr_list[d.seq].deleted_ind != 1))
    JOIN (r)
   WITH nocounter
  ;end insert
 ELSE
  INSERT  FROM request r,
    (dummyt d  WITH seq = value(atr->atr_count))
   SET r.seq = 1, r.request_number = atr->atr_list[d.seq].request_number, r.description = atr->
    atr_list[d.seq].description,
    r.text = atr->atr_list[d.seq].text, r.request_name = atr->atr_list[d.seq].request_name, r
    .epilog_script = atr->atr_list[d.seq].epilog_script,
    r.prolog_script = atr->atr_list[d.seq].prolog_script, r.write_to_que_ind = atr->atr_list[d.seq].
    write_to_que_ind, r.cachetime = atr->atr_list[d.seq].cachetime,
    r.active_ind = atr->atr_list[d.seq].active_ind, r.active_dt_tm =
    IF ((atr->atr_list[d.seq].active_dt_tm > 0)) cnvtdatetime(atr->atr_list[d.seq].active_dt_tm)
    ELSE null
    ENDIF
    , r.inactive_dt_tm =
    IF ((atr->atr_list[d.seq].inactive_dt_tm > 0)) cnvtdatetime(atr->atr_list[d.seq].inactive_dt_tm)
    ELSE null
    ENDIF
    ,
    r.updt_dt_tm = cnvtdatetime(curdate,curtime3), r.updt_task = reqinfo->updt_task, r.updt_id = 0.0,
    r.updt_cnt = 0, r.updt_applctx = 0
   PLAN (d
    WHERE (status->qual[d.seq].exist=0)
     AND (atr->atr_list[d.seq].deleted_ind != 1))
    JOIN (r)
   WITH nocounter
  ;end insert
 ENDIF
 COMMIT
END GO
