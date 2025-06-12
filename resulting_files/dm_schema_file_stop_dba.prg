CREATE PROGRAM dm_schema_file_stop:dba
 IF (validate(ddl_log->env_id,0)=0)
  GO TO end_program
 ENDIF
 UPDATE  FROM dm_ocd_log d
  SET d.status = "COMPLETE", d.end_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_dt_tm =
   cnvtdatetime(curdate,curtime3)
  WHERE (d.environment_id=ddl_log->env_id)
   AND (d.ocd=ddl_log->ocd)
   AND d.project_type="SCHEMA DDL"
   AND (d.project_name=ddl_log->ddl_file)
  WITH nocounter
 ;end update
 COMMIT
#end_program
END GO
