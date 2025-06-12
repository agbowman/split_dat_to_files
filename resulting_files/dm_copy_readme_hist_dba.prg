CREATE PROGRAM dm_copy_readme_hist:dba
 SET from_env_name = cnvtupper( $1)
 SET from_env_id = 0.0
 SET to_env_name = cnvtupper( $2)
 SET to_env_id = 0.0
 SELECT INTO "nl:"
  e.environment_id
  FROM dm_environment e
  WHERE e.environment_name IN (from_env_name, to_env_name)
  DETAIL
   IF (e.environment_name=from_env_name)
    from_env_id = e.environment_id
   ELSEIF (e.environment_name=to_env_name)
    to_env_id = e.environment_id
   ENDIF
  WITH nocounter
 ;end select
 IF (from_env_id=0.0)
  CALL echo(" ")
  CALL echo("'FROM' ENVIRONMENT DOES NOT EXIST.")
  CALL echo(" ")
  GO TO exit_script
 ENDIF
 IF (to_env_id=0.0)
  CALL echo(" ")
  CALL echo("'TO' ENVIRONMENT DOES NOT EXIST.")
  CALL echo(" ")
  GO TO exit_script
 ENDIF
 INSERT  FROM dm_pkt_setup_proc_hist
  (process_id, environment_id, success_ind,
  create_dt_tm, updt_dt_tm, updt_cnt)(SELECT
   h.process_id, to_env_id, h.success_ind,
   h.create_dt_tm, h.updt_dt_tm, h.updt_cnt
   FROM dm_pkt_setup_proc_hist h
   WHERE h.environment_id=from_env_id)
 ;end insert
 IF (validate(dcoh_calling_script,"DM_COPY_OCD_HIST")="DM_COPY_OCD_HIST")
  CALL echo(build("Nbr of Rev Readmes Inserted :",curqual))
 ELSE
  COMMIT
 ENDIF
#exit_script
END GO
