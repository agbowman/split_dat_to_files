CREATE PROGRAM dm2_gather_stats:dba
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
 DECLARE dgs_table_cnt = i4 WITH protect, noconstant(0)
 DECLARE dgs_item_cnt = i4 WITH protect, noconstant(0)
 DECLARE dgs_rdb_command = vc WITH protect, noconstant(" ")
 DECLARE dgs_error_msg = vc WITH protect, noconstant(" ")
 DECLARE global_count = i4 WITH protect, noconstant(0)
 DECLARE dgs_max_count = i4 WITH protect, noconstant(300)
 DECLARE dgs_global_ind = i2 WITH protect, noconstant(0)
 DECLARE dgsv_level = i2 WITH protect, noconstant(0)
 DECLARE dgsv_loc = i2 WITH protect, noconstant(0)
 DECLARE dgsv_prev_loc = i2 WITH protect, noconstant(0)
 DECLARE dgsv_loop = i2 WITH protect, noconstant(0)
 DECLARE dgsv_len = i2 WITH protect, noconstant(0)
 DECLARE dgs_errmsg = vc WITH protect, noconstant(" ")
 DECLARE dgs_errcode = i4 WITH protect, noconstant(0)
 SET dgs_errmsg = fillstring(132," ")
 SET dgs_errcode = 0
 FREE RECORD dgs_table_stats
 RECORD dgs_table_stats(
   1 stats_cnt[*]
     2 tabname = vc
     2 monitoring = vc
     2 lock = i4
 )
 FREE RECORD dgs_dm2_rdbms_version
 RECORD dgs_dm2_rdbms_version(
   1 version = vc
   1 level1 = i2
 )
 SET readme_data->status = "F"
 SET readme_data->message = "Beginning dm2_gather_stats."
 IF (currdb="ORACLE")
  SET dgs_dm2_rdbms_version->level1 = 0
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = "Auto-Sucess: Program can only be run on an Oracle database."
  CALL echo("Auto-Sucess: Program can only be run on an Oracle database.")
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  FROM product_component_version p
  WHERE cnvtupper(p.product)="ORACLE*"
  DETAIL
   dgs_dm2_rdbms_version->version = p.version
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET readme_data->status = "F"
  SET readme_data->message =
  "ERROR: Product component version not found in PRODUCT_COMPONENT_VERSION table."
  GO TO exit_program
 ENDIF
 WHILE (dgsv_loop=0)
   SET dgsv_level = (dgsv_level+ 1)
   SET dgsv_loc = 0
   SET dgsv_prev_loc = dgsv_loc
   SET dgsv_loc = findstring(".",dgs_dm2_rdbms_version->version,(dgsv_prev_loc+ 1),0)
   IF (dgsv_loc > 0)
    SET dgsv_len = ((dgsv_loc - dgsv_prev_loc) - 1)
    CASE (dgsv_level)
     OF 1:
      SET dgs_dm2_rdbms_version->level1 = cnvtint(substring(1,dgsv_len,dgs_dm2_rdbms_version->version
        ))
     ELSE
      SET dgsv_loop = 1
    ENDCASE
   ELSE
    IF (dgsv_level=1)
     SET readme_data->status = "F"
     SET readme_data->message =
     "ERROR: Product component version not in expected format in the PRODUCT_COMPONENT_VERSION table."
     GO TO exit_program
    ENDIF
    SET dgsv_loop = 1
   ENDIF
 ENDWHILE
 IF ((dgs_dm2_rdbms_version->level1 < 8))
  SET readme_data->status = "F"
  SET readme_data->message =
  "ERROR: This program can only be executed on an Oracle 8i database or higher."
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  u.table_name, u.monitoring
  FROM user_tables u
  WHERE  NOT (u.tablespace_name IN ("MISC", "TEMP"))
  ORDER BY u.table_name
  HEAD REPORT
   dgs_table_cnt = 0, stat = alterlist(dgs_table_stats->stats_cnt,dgs_table_cnt)
  DETAIL
   dgs_table_cnt = (dgs_table_cnt+ 1)
   IF (mod(dgs_table_cnt,50)=1)
    stat = alterlist(dgs_table_stats->stats_cnt,(dgs_table_cnt+ 49))
   ENDIF
   dgs_table_stats->stats_cnt[dgs_table_cnt].tabname = trim(cnvtupper(u.table_name)), dgs_table_stats
   ->stats_cnt[dgs_table_cnt].monitoring = trim(cnvtupper(u.monitoring))
  FOOT REPORT
   stat = alterlist(dgs_table_stats->stats_cnt,dgs_table_cnt)
  WITH nocounter
 ;end select
 IF (dgs_table_cnt=0)
  SET readme_data->status = "F"
  SET readme_data->message = "ERROR: Could not get list of tables from USER_TABLES."
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  FROM v$lock v,
   all_objects o,
   v$session s,
   (dummyt d  WITH seq = value(dgs_table_cnt))
  PLAN (o
   WHERE o.owner != "SYS"
    AND o.object_name != "V$*")
   JOIN (v
   WHERE v.id1=o.object_id)
   JOIN (s
   WHERE v.sid=s.sid)
   JOIN (d
   WHERE (o.object_name=dgs_table_stats->stats_cnt[d.seq].tabname))
  DETAIL
   dgs_table_stats->stats_cnt[d.seq].lock = 1
  WITH nocounter
 ;end select
 CALL echo("Turning table level monitoring on for all tables...")
 SET global_count = 1
 WHILE (global_count <= dgs_max_count)
  FOR (dgs_item_count = 1 TO dgs_table_cnt)
    IF ((dgs_table_stats->stats_cnt[dgs_item_count].monitoring="NO"))
     IF ((dgs_table_stats->stats_cnt[dgs_item_count].lock < global_count)
      AND (dgs_table_stats->stats_cnt[dgs_item_count].lock != - (1)))
      CALL parser(concat("RDB alter table ",trim(dgs_table_stats->stats_cnt[dgs_item_count].tabname),
        " monitoring go"),1)
      SET dgs_errcode = error(dgs_errmsg,1)
      IF (dgs_errcode
       AND findstring("ORA-00054",dgs_errmsg))
       SET dgs_table_stats->stats_cnt[dgs_item_count].lock = (global_count+ 1)
       SET dgs_global_ind = 1
      ELSE
       SET dgs_table_stats->stats_cnt[dgs_item_count].lock = - (1)
       SET dgs_global_ind = 0
      ENDIF
     ELSEIF ((dgs_table_stats->stats_cnt[dgs_item_count].lock != - (1)))
      SET dgs_global_ind = 1
      SELECT INTO "nl:"
       FROM v$lock v,
        all_objects o,
        v$session s
       PLAN (o
        WHERE o.owner != "SYS"
         AND o.object_name != "V$*"
         AND (o.object_name=dgs_table_stats->stats_cnt[dgs_item_count].tabname))
        JOIN (v
        WHERE v.id1=o.object_id)
        JOIN (s
        WHERE v.sid=s.sid)
       DETAIL
        dgs_table_stats->stats_cnt[dgs_item_count].lock = (global_count+ 1)
       WITH nocounter
      ;end select
      CALL echo(concat("Attempting to free up the table: ",dgs_table_stats->stats_cnt[dgs_item_count]
        .tabname," (Attempt ",trim(cnvtstring(global_count))," of ",
        trim(cnvtstring(dgs_max_count)),".)"))
     ENDIF
    ENDIF
  ENDFOR
  SET global_count = (global_count+ 1)
 ENDWHILE
 SET dgs_item_count = 0
 IF (dgs_global_ind=1)
  DELETE  FROM dm_info di
   WHERE di.info_domain="DM2_GATHER_STATS"
   WITH nocounter
  ;end delete
  SET dgs_errcode = error(dgs_errmsg,1)
  IF (dgs_errcode)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = "ERROR: Could not delete from DM_INFO table."
   GO TO exit_program
  ELSE
   COMMIT
  ENDIF
  FOR (dgs_item_count = 1 TO dgs_table_cnt)
    IF ((dgs_table_stats->stats_cnt[dgs_item_count].lock != - (1)))
     INSERT  FROM dm_info di
      SET di.info_domain = "DM2_GATHER_STATS", di.info_name = dgs_table_stats->stats_cnt[
       dgs_item_count].tabname, di.info_char =
       "Could not turn MONITORING on for this table via Readme 3455."
      WITH nocounter
     ;end insert
     SET dgs_errcode = error(dgs_errmsg,1)
     IF (dgs_errcode)
      ROLLBACK
      SET readme_data->status = "F"
      SET readme_data->message = "ERROR: Could not insert into the DM_INFO table."
      GO TO exit_program
     ELSE
      COMMIT
     ENDIF
    ENDIF
  ENDFOR
 ENDIF
 IF ((dgs_dm2_rdbms_version->level1 >= 9))
  CALL echo(
   "Gathering Schema Level Statistics for all tables.  This process can take at least an hour.")
  SET dgs_rdb_command = concat('RDB ASIS(" begin DBMS_STATS.GATHER_SCHEMA_STATS(',"ownname=> '",trim(
    currdbuser),"' ,estimate_percent=> dbms_stats.auto_sample_size,",
   ^method_opt=> 'for all indexed columns size skewonly',block_sample=> true); end;") go^)
  CALL parser(dgs_rdb_command,1)
  SET dgs_errcode = error(dgs_errmsg,1)
  IF (dgs_errcode)
   SET readme_data->status = "F"
   SET readme_data->message = "ERROR: Could not gather statistics on all tables in USER_TABLES."
   GO TO exit_program
  ENDIF
 ELSE
  FOR (dgs_item_cnt = 1 TO dgs_table_cnt)
    SET dgs_rdb_command = concat('RDB ASIS(" begin DBMS_STATS.GATHER_TABLE_STATS(',"ownname=> '",trim
     (currdbuser),"' ,tabname=> '",trim(dgs_table_stats->stats_cnt[dgs_item_cnt].tabname),
     ^',estimate_percent=> 15 ); end;") go^)
    CALL parser(dgs_rdb_command,1)
    SET dgs_errcode = error(dgs_errmsg,1)
    IF (dgs_errcode)
     SET readme_data->status = "F"
     SET readme_data->message = concat("ERROR: Could not gather statistics on table ",dgs_table_stats
      ->stats_cnt[dgs_item_cnt].tabname,"in USER_TABLES..")
     GO TO exit_program
    ENDIF
    CALL echo(concat("Statistics analyzed for ",dgs_table_stats->stats_cnt[dgs_item_cnt].tabname,
      " table."))
  ENDFOR
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message =
 "Successfully ran statistics and set table monitoring 'ON' on all tables."
#exit_program
 FREE RECORD dgs_table_stats
 FREE RECORD dgs_dm2_rdbms_version
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
