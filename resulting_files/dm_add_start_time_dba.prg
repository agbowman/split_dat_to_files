CREATE PROGRAM dm_add_start_time:dba
 SET process_id =  $1
 SET env_id =  $2
 SELECT INTO "nl:"
  a.*
  FROM dm_pkt_setup_proc_log a
  WHERE a.process_id=process_id
   AND a.environment_id=env_id
  WITH nocounter
 ;end select
 IF (curqual > 0)
  UPDATE  FROM dm_pkt_setup_proc_log spl
   SET spl.start_dt_tm = cnvtdatetime(curdate,curtime3), spl.success_ind = null, spl.error_msg = null,
    spl.updt_dt_tm = cnvtdatetime("31-DEC-2100")
   WHERE spl.process_id=process_id
    AND spl.environment_id=env_id
   WITH nocounter
  ;end update
 ELSE
  INSERT  FROM dm_pkt_setup_proc_log spl
   SET spl.process_id = process_id, spl.environment_id = env_id, spl.create_dt_tm = cnvtdatetime(
     curdate,curtime3),
    spl.start_dt_tm = cnvtdatetime(curdate,curtime3), spl.updt_dt_tm = cnvtdatetime("31-DEC-2100")
   WITH nocounter
  ;end insert
 ENDIF
 COMMIT
END GO
