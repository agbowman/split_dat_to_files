CREATE PROGRAM dm_correct_obsolete_tables:dba
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
 DECLARE count = i2 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH public, noconstant("")
 FREE RECORD objects
 RECORD objects(
   1 list[*]
     2 table_name = vc
     2 exists_ind = i2
 )
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed:  Starting Script dm_correct_obsolete_tables.prg"
 SELECT INTO "NL:"
  d.info_domain, d.info_char
  FROM dm_info d
  WHERE d.info_domain="OBSOLETE_OBJECT_RENAMED"
   AND d.info_char="TABLE|*"
  HEAD REPORT
   count = 0
  DETAIL
   count = (count+ 1), stat = alterlist(objects->list,count), objects->list[count].table_name =
   substring(7,textlen(d.info_char),d.info_char)
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed selecting values from dm_info :",errmsg)
  GO TO exit_script
 ENDIF
 IF (count > 0)
  IF (currdb="ORACLE")
   SELECT INTO "NL:"
    FROM dm_info dm,
     (dummyt dt  WITH seq = value(count))
    PLAN (dt)
     JOIN (dm
     WHERE dm.info_domain="OBSOLETE_OBJECT"
      AND (dm.info_name=objects->list[dt.seq].table_name)
      AND dm.info_char="TABLE")
    DETAIL
     objects->list[dt.seq].exists_ind = 1
    WITH nocounter
   ;end select
   INSERT  FROM dm_info d,
     (dummyt dt  WITH seq = value(count))
    SET d.info_domain = "OBSOLETE_OBJECT", d.info_name = objects->list[dt.seq].table_name, d
     .info_char = "TABLE",
     d.info_date = cnvtdatetime(curdate,curtime3), d.updt_applctx = 4787, d.updt_dt_tm = cnvtdatetime
     (curdate,curtime3),
     d.updt_cnt = 0, d.updt_id = 4787, d.updt_task = reqinfo->updt_task
    PLAN (dt
     WHERE (objects->list[dt.seq].exists_ind=0))
     JOIN (d)
    WITH nocounter
   ;end insert
   IF (error(errmsg,0) > 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed inserting row into dm_info table :",errmsg)
    ROLLBACK
    GO TO exit_script
   ELSE
    COMMIT
   ENDIF
   SET readme_data->status = "S"
   SET readme_data->message = "Success: Completed correcting missed Obsolete Object rows."
   GO TO exit_script
  ELSEIF (currdb="DB2UDB")
   SET readme_data->status = "S"
   SET readme_data->message = "Auto-success for DB2 database"
   GO TO exit_script
  ENDIF
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = "Success: No obsolete rows left to correct "
  GO TO exit_script
 ENDIF
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
 FREE RECORD objects
END GO
