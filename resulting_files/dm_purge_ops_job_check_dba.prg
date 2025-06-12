CREATE PROGRAM dm_purge_ops_job_check:dba
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
 DECLARE v_ops_job_id = f8 WITH noconstant(0.0)
 SELECT INTO "nl:"
  oj.ops_job_id
  FROM ops_job oj
  WHERE oj.name="DM Purge"
  DETAIL
   v_ops_job_id = oj.ops_job_id
  WITH nocounter
 ;end select
 IF (v_ops_job_id=0.0)
  SET readme_data->status = "F"
  SET readme_data->message = 'Did not find ops_job.name = "DM Purge"'
 ELSE
  SELECT INTO "nl:"
   "x"
   FROM dual
   WHERE  EXISTS (
   (SELECT
    "x"
    FROM ops_job_step ojs
    WHERE ojs.ops_job_id=v_ops_job_id))
  ;end select
  IF (curqual=0)
   SET readme_data->status = "F"
   SET readme_data->message = concat("Did not find ops_job_step for ops_job_id = ",cnvtstring(
     v_ops_job_id))
  ELSE
   SET readme_data->status = "S"
   SET readme_data->message = concat("Readme completed.  The ops_job ",
    'and ops_job_step tables have rows for "DM Purge".')
  ENDIF
 ENDIF
 EXECUTE dm_readme_status
END GO
