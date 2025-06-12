CREATE PROGRAM dm_fix_ih_obs_objects:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 SET readme_data->status = "F"
 FREE SET obs_list
 RECORD obs_list(
   1 inhouse_flag = i2
   1 cnt = i4
   1 qual[*]
     2 name = vc
 )
 SET errmsg = fillstring(132," ")
 SET errcode = 0
 SET errcode = error(errmsg,1)
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="DATA MANAGEMENT"
   AND di.info_name="INHOUSE DOMAIN"
  DETAIL
   obs_list->inhouse_flag = 1
  WITH nocounter
 ;end select
 IF (obs_list->inhouse_flag)
  CALL echo("******************")
  CALL echo("This is an INHOUSE domain hence attempting to execute this Readme.")
  CALL echo("******************")
  SELECT INTO "nl:"
   dtc.table_name
   FROM dm_tables_doc dtc
   WHERE dtc.drop_ind=1
    AND  NOT ( EXISTS (
   (SELECT
    "x"
    FROM dm_info di
    WHERE di.info_domain="OBSOLETE_OBJECT"
     AND di.info_name=dtc.table_name
     AND di.info_char="TABLE")))
   ORDER BY dtc.table_name
   HEAD REPORT
    obs_list->cnt = 0, stat = alterlist(obs_list->qual,obs_list->cnt)
   DETAIL
    obs_list->cnt = (obs_list->cnt+ 1), stat = alterlist(obs_list->qual,obs_list->cnt), obs_list->
    qual[obs_list->cnt].name = cnvtupper(dtc.table_name)
   WITH nocounter
  ;end select
  IF (obs_list->cnt)
   CALL echo("******************")
   CALL echo("Found TABLES that need to be inserted in DM_INFO from DM_TABLES_DOC.")
   CALL echo("******************")
   CALL echorecord(obs_list)
   INSERT  FROM dm_info d,
     (dummyt d1  WITH seq = value(obs_list->cnt))
    SET d.info_domain = "OBSOLETE_OBJECT", d.info_name = obs_list->qual[d1.seq].name, d.info_char =
     "TABLE",
     d.info_date = cnvtdatetime(curdate,curtime3), d.updt_applctx = 1676, d.updt_dt_tm = cnvtdatetime
     (curdate,curtime3),
     d.updt_cnt = 0, d.updt_id = 1676, d.updt_task = 1676
    PLAN (d1)
     JOIN (d)
    WITH nocounter
   ;end insert
   SET errcode = 0
   SET errcode = error(errmsg,0)
   IF (errcode)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = "Readme Failed.  Failed to insert Table Information in DM_INFO."
    CALL echo("******************")
    CALL echo("Readme Failed.  Failed to insert Table Information in DM_INFO.")
    CALL echo("******************")
    GO TO exit_script
   ELSE
    COMMIT
    SET readme_data->status = "S"
    SET readme_data->message = "Readme Success.  Successfully inserted Table Information in DM_INFO."
    CALL echo("******************")
    CALL echo("Readme Success.  Successfully inserted Table Information in DM_INFO.")
    CALL echo("******************")
   ENDIF
  ENDIF
  SELECT INTO "nl:"
   dic.index_name
   FROM dm_indexes_doc dic
   WHERE dic.drop_ind=1
    AND  NOT ( EXISTS (
   (SELECT
    "x"
    FROM dm_info di
    WHERE di.info_domain="OBSOLETE_OBJECT"
     AND di.info_name=dic.index_name
     AND di.info_char="INDEX")))
   ORDER BY dic.index_name
   HEAD REPORT
    obs_list->cnt = 0, stat = alterlist(obs_list->qual,obs_list->cnt)
   DETAIL
    obs_list->cnt = (obs_list->cnt+ 1), stat = alterlist(obs_list->qual,obs_list->cnt), obs_list->
    qual[obs_list->cnt].name = cnvtupper(dic.index_name)
   WITH nocounter
  ;end select
  IF (obs_list->cnt)
   CALL echo("******************")
   CALL echo("Found INDEXES that need to be inserted in DM_INFO from DM_INDEXES_DOC.")
   CALL echo("******************")
   CALL echorecord(obs_list)
   INSERT  FROM dm_info d,
     (dummyt d1  WITH seq = value(obs_list->cnt))
    SET d.info_domain = "OBSOLETE_OBJECT", d.info_name = obs_list->qual[d1.seq].name, d.info_char =
     "INDEX",
     d.info_date = cnvtdatetime(curdate,curtime3), d.updt_applctx = 1676, d.updt_dt_tm = cnvtdatetime
     (curdate,curtime3),
     d.updt_cnt = 0, d.updt_id = 1676, d.updt_task = 1676
    PLAN (d1)
     JOIN (d)
    WITH nocounter
   ;end insert
   SET errcode = 0
   SET errcode = error(errmsg,0)
   IF (errcode)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = "Readme Failed.  Failed to insert Index Information in DM_INFO."
    CALL echo("******************")
    CALL echo("Readme Failed.  Failed to insert Index Information in DM_INFO.")
    CALL echo("******************")
    GO TO exit_script
   ELSE
    COMMIT
    SET readme_data->status = "S"
    SET readme_data->message = "Readme Success.  Successfully inserted Index Information in DM_INFO."
    CALL echo("******************")
    CALL echo("Readme Success.  Successfully inserted Index Information in DM_INFO.")
    CALL echo("******************")
   ENDIF
  ENDIF
  SET readme_data->status = "S"
  SET readme_data->message =
  "Readme Success.  Successfully synched Table/Index Information in DM_INFO."
  CALL echo("******************")
  CALL echo("Readme Success.  Successfully synched Table/Index Information in DM_INFO.")
  CALL echo("******************")
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = "Readme Success.  Auto-Success if executed on a client site."
  CALL echo("******************")
  CALL echo("Readme Success.  Auto-Success if executed on a client site.")
  CALL echo("******************")
 ENDIF
#exit_script
 EXECUTE dm_readme_status
END GO
