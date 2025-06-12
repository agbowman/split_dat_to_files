CREATE PROGRAM dm_rdm_update_prsnl_role_type:dba
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
 SET readme_data->status = "F"
 SET readme_data->message = "Readme failed: starting script dm_rdm_update_prsnl_role_type..."
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE end_time = vc WITH protected, constant("31-DEC-2100")
 UPDATE  FROM prsnl_role_type p
  SET p.end_effective_dt_tm = cnvtdatetime(sysdate)
  WHERE ((p.end_effective_dt_tm = null) OR (p.end_effective_dt_tm=cnvtdatetime(end_time)))
   AND p.active_ind=0
   AND p.prsnl_role_type_id=p.prev_prsnl_role_type_id
  WITH nocounter
 ;end update
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to update inactive rows from PRSNL_ROLE_TYPE: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 UPDATE  FROM prsnl_role_type p
  SET p.end_effective_dt_tm = cnvtdatetime(end_time)
  WHERE p.end_effective_dt_tm = null
   AND p.active_ind=1
   AND p.prsnl_role_type_id=p.prev_prsnl_role_type_id
   AND p.role_end_dt_tm > cnvtdatetime(sysdate)
  WITH nocounter
 ;end update
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to update active rows from PRSNL_ROLE_TYPE: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Readme performed all required tasks"
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
