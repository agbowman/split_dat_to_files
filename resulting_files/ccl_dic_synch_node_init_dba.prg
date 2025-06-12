CREATE PROGRAM ccl_dic_synch_node_init:dba
 PROMPT
  "Enter value to assign to ccl_synch_data.export_only_ind (0:export/import, 1:export)(1): " = 1,
  "Enter value to assign to ccl_synch_data.object_purge_days(1): " = 1,
  "Enter value to assign ccl_synch_data.backup_purge_days(1):    " = 1,
  "Enter number of days in the past to init date for(0):         " = 0
 IF (( $1 > 1))
  CALL echo("Export_Only_Ind must be set to 0 or 1")
  GO TO exit_program
 ENDIF
 EXECUTE oragen3 "ccl_synch_cmp"
 EXECUTE oragen3 "ccl_synch_data"
 EXECUTE oragen3 "ccl_synch_objects"
 EXECUTE oragen3 "ccl_synch_backup"
 EXECUTE oragen3 "ccl_synch_audit"
 DECLARE ccl_node = c20
 DECLARE synch_data_id = f8
 DECLARE last_export_date = i4
 DECLARE last_export_time = i4
 SET last_export_begin_dt_tm = cnvtdatetime((curdate -  $4),curtime3)
 SET export_begin_dt_tm = cnvtdatetime((curdate -  $4),curtime3)
 SET export_end_dt_tm = cnvtdatetime((curdate -  $4),curtime3)
 SET ccl_node = cnvtupper(logical("JOU_INSTANCE"))
 DELETE  FROM ccl_synch_cmp c
  WHERE c.node_name=ccl_node
 ;end delete
 DELETE  FROM ccl_synch_data c
  WHERE c.node_name=ccl_node
 ;end delete
 INSERT  FROM ccl_synch_data c
  SET c.ccl_synch_data_id = seq(ccl_dic_synch_seq,nextval), c.node_name = ccl_node, c
   .import_begin_dt_tm = cnvtdatetime(export_begin_dt_tm),
   c.import_end_dt_tm = cnvtdatetime(export_begin_dt_tm), c.export_begin_dt_tm = cnvtdatetime(
    export_begin_dt_tm), c.export_end_dt_tm = cnvtdatetime(export_begin_dt_tm),
   c.export_only_ind =  $1, c.object_purge_days =  $2, c.backup_purge_days =  $3,
   c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->
   updt_task,
   c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt = 0
  WITH nocounter
 ;end insert
 IF (curqual > 0)
  COMMIT
 ENDIF
#exit_program
END GO
