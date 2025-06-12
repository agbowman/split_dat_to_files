CREATE PROGRAM dcp_rdm_personalized_plans:dba
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
 SET readme_data->message = "Readme failed: starting script dcp_rdm_personalized_plans..."
 DECLARE errmsg = vc WITH protect, noconstant("")
 RDB update pathway_catalog pc set pc . pathway_uuid = sys_guid ( ) where pc . pathway_uuid <= " "
 END ;Rdb
 IF (error(errmsg,0) != 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to update PATHWAY_CATALOG: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 RDB update pathway_comp pc set pc . pathway_uuid = sys_guid ( ) where pc . pathway_uuid <= " "
 END ;Rdb
 IF (error(errmsg,0) != 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to update PATHWAY_COMP: ",errmsg)
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
