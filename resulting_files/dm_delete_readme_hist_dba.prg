CREATE PROGRAM dm_delete_readme_hist:dba
 SET env_name = cnvtupper( $1)
 SET env_id = 0.0
 SELECT INTO "nl:"
  e.environment_id
  FROM dm_environment e
  WHERE e.environment_name=env_name
  DETAIL
   env_id = e.environment_id
  WITH nocounter
 ;end select
 IF (env_id=0.0)
  CALL echo(" ")
  CALL echo("ENVIRONMENT SPECIFIED DOES NOT EXIST.")
  CALL echo(" ")
  GO TO exit_script
 ENDIF
 DELETE  FROM dm_pkt_setup_proc_hist h
  WHERE h.environment_id=env_id
 ;end delete
 IF (validate(dcoh_calling_script,"DM_COPY_OCD_HIST")="DM_COPY_OCD_HIST")
  CALL echo(build("Nbr of Rev Readmes Deleted :",curqual))
 ELSE
  COMMIT
 ENDIF
#exit_script
END GO
