CREATE PROGRAM dcp_del_pw_dm_info:dba
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
 SET dcp_info_ind = 0
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="DATA MANAGEMENT"
   AND di.info_name="PATHWAYS"
  DETAIL
   dcp_info_ind = 1
  WITH nocounter
 ;end select
 IF (dcp_info_ind=1)
  DELETE  FROM dm_info
   WHERE info_domain="DATA MANAGEMENT"
    AND info_name="PATHWAYS"
   WITH nocounter
  ;end delete
  COMMIT
  SELECT INTO "nl:"
   FROM dm_info di
   WHERE di.info_domain="DATA MANAGEMENT"
    AND di.info_name="PATHWAYS"
   WITH nocounter
  ;end select
  IF (curqual > 0)
   SET readme_data->message = "Delete from dm_info table failed"
   GO TO exit_script
  ENDIF
  SET readme_data->status = "S"
  SET readme_data->message = "Dm_info row deleted successfully"
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = "Dm_info previously removed"
 ENDIF
#exit_script
 EXECUTE dm_readme_status
END GO
