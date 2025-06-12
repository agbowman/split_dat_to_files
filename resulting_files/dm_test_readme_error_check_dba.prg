CREATE PROGRAM dm_test_readme_error_check:dba
 SET env_name = cnvtupper( $1)
 SET proc_id =  $2
 SET env_id = 0
 SELECT INTO "nl:"
  d.environment_id
  FROM dm_environment d
  WHERE d.environment_name=env_name
  DETAIL
   env_id = d.environment_id
  WITH nocounter
 ;end select
 SELECT
  p.*
  FROM dm_pkt_setup_proc_log p
  WHERE p.process_id=proc_id
   AND p.environment_id=env_id
 ;end select
END GO
