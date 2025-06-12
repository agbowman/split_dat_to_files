CREATE PROGRAM dm_readme_steps:dba
 SET env_name = cnvtupper( $1)
 SET before_after_flag =  $2 WITH nocounter
 SELECT
  d.process_id
  FROM dm_pkt_setup_process dsp,
   dm_pkt_com_file_env cfe,
   dm_environment e
  WHERE e.environment_name=env_name
   AND cfe.environment_id=e.environment_id
   AND cfe.process_id=dsp.process_id
   AND cfe.before_after_flag=before_after_flag
   AND cfe.instance_nbr=dsp.instance_nbr
  ORDER BY dsp.com_file_name, dsp.process_id
  HEAD REPORT
   row + 1, col 15, "Readme steps to be run for ",
   env_name, row + 1, row + 1,
   col 1, "com_file_name", col 25,
   "proc_id", col 35, "run_after",
   col 45, "owner_email", col 65,
   "description", row + 1
  DETAIL
   exp1 = cnvtstring(dsp.process_id), exp2 = cnvtstring(dsp.run_after_process_id), row + 1,
   col 1, cfe.com_file_name, col 25,
   exp1, col 35, exp2,
   col 45, dsp.owner_email, col 65,
   dsp.description
  WITH nocounter, maxcol = 185
 ;end select
END GO
