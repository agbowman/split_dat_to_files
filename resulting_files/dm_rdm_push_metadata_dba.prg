CREATE PROGRAM dm_rdm_push_metadata:dba
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
 DECLARE dm_err_msg = vc WITH private, noconstant(fillstring(132," "))
 SET readme_data->status = "F"
 SET readme_data->message = "Fail: beginning of dm_rdm_push_metadata"
 UPDATE  FROM dm_columns_doc_local d
  SET d.root_entity_name = "SUMMARY_SECTION", d.root_entity_attr = "SECTION_ID"
  WHERE d.table_name="SECTION_ATTRIBUTE"
   AND d.column_name="SECTION_ID"
  WITH nocounter
 ;end update
 IF (error(dm_err_msg,0)=0)
  COMMIT
  SET readme_data->status = "S"
 ELSE
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("FAIL: ccl error-->",dm_err_msg)
  GO TO exit_program
 ENDIF
 UPDATE  FROM dm_columns_doc_local d
  SET d.root_entity_name = "SUMMARY_SECTION", d.root_entity_attr = "SECTION_ID"
  WHERE d.table_name="SECTION_SECTION_R"
   AND d.column_name="PARENT_ID"
  WITH nocounter
 ;end update
 IF (error(dm_err_msg,0)=0)
  COMMIT
  SET readme_data->status = "S"
 ELSE
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("FAIL: ccl error-->",dm_err_msg)
  GO TO exit_program
 ENDIF
 UPDATE  FROM dm_columns_doc_local d
  SET d.root_entity_name = "SUMMARY_SECTION", d.root_entity_attr = "SECTION_ID"
  WHERE d.table_name="SECTION_SECTION_R"
   AND d.column_name="CHILD_ID"
  WITH nocounter
 ;end update
 IF (error(dm_err_msg,0)=0)
  COMMIT
  SET readme_data->status = "S"
 ELSE
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("FAIL: ccl error-->",dm_err_msg)
  GO TO exit_program
 ENDIF
 UPDATE  FROM dm_columns_doc_local d
  SET d.root_entity_name = "TRACK_ACTION_LINK", d.root_entity_attr = "TRACK_ACTION_LINK_ID"
  WHERE d.table_name="TRACK_ACTION_LINK"
   AND d.column_name="TRACK_ACTION_LINK_ID"
  WITH nocounter
 ;end update
 IF (error(dm_err_msg,0)=0)
  COMMIT
  SET readme_data->status = "S"
 ELSE
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("FAIL: ccl error-->",dm_err_msg)
  GO TO exit_program
 ENDIF
 UPDATE  FROM dm_columns_doc_local d
  SET d.root_entity_name = "CHART_SECTION_DESC", d.root_entity_attr = "CHART_SECTION_DESC_ID"
  WHERE d.table_name="CHART_SECTION_DESC"
   AND d.column_name="CHART_SECTION_DESC_ID"
  WITH nocounter
 ;end update
 IF (error(dm_err_msg,0)=0)
  COMMIT
  SET readme_data->status = "S"
 ELSE
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("FAIL: ccl error-->",dm_err_msg)
  GO TO exit_program
 ENDIF
 UPDATE  FROM dm_columns_doc_local d
  SET d.root_entity_name = "DATA_SOURCE", d.root_entity_attr = "DATA_SOURCE_ID"
  WHERE d.table_name="DATA_SOURCE"
   AND d.column_name="DATA_SOURCE_ID"
  WITH nocounter
 ;end update
 IF (error(dm_err_msg,0)=0)
  COMMIT
  SET readme_data->status = "S"
 ELSE
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("FAIL: ccl error-->",dm_err_msg)
  GO TO exit_program
 ENDIF
 UPDATE  FROM dm_columns_doc_local d
  SET d.root_entity_name = "DCP_DEVICE_LOCATION", d.root_entity_attr = "DCP_DEVICE_LOCATION_ID"
  WHERE d.table_name="DCP_DEVICE_LOCATION"
   AND d.column_name="DCP_DEVICE_LOCATION_ID"
  WITH nocounter
 ;end update
 IF (error(dm_err_msg,0)=0)
  COMMIT
  SET readme_data->status = "S"
 ELSE
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("FAIL: ccl error-->",dm_err_msg)
 ENDIF
#exit_program
 IF ((readme_data->status="S"))
  SET readme_data->message = "SUCCESS: all necessary metadata pushed"
 ENDIF
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
