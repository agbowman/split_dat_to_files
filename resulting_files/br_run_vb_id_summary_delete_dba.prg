CREATE PROGRAM br_run_vb_id_summary_delete:dba
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
 SET readme_data->message = "Readme failed: starting script br_run_vb_id_summary_delete..."
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE kb_category_mean = vc WITH protect, constant("MP_VB_ID_SUMMARY")
 DELETE  FROM br_datamart_report_filter_r b
  WHERE (b.br_datamart_filter_id=
  (SELECT
   b2.br_datamart_filter_id
   FROM br_datamart_filter b2,
    br_datamart_category b3
   WHERE b3.category_mean=kb_category_mean
    AND b2.br_datamart_category_id=b3.br_datamart_category_id))
 ;end delete
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to delete from bedrock br_datamart_report_filter_r table: ",errmsg)
  GO TO exit_script
 ENDIF
 DELETE  FROM br_datamart_default b
  WHERE (b.br_datamart_filter_id=
  (SELECT
   b2.br_datamart_filter_id
   FROM br_datamart_filter b2,
    br_datamart_category b3
   WHERE b3.category_mean=kb_category_mean
    AND b2.br_datamart_category_id=b3.br_datamart_category_id))
 ;end delete
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to delete from bedrock br_datamart_default table: ",
   errmsg)
  GO TO exit_script
 ENDIF
 DELETE  FROM br_datamart_value b
  WHERE (b.br_datamart_category_id=
  (SELECT
   b3.br_datamart_category_id
   FROM br_datamart_category b3
   WHERE b3.category_mean=kb_category_mean))
 ;end delete
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to delete from bedrock br_datamart_value table: ",errmsg)
  GO TO exit_script
 ENDIF
 DELETE  FROM br_datamart_text b
  WHERE (b.br_datamart_category_id=
  (SELECT
   b2.br_datamart_category_id
   FROM br_datamart_category b2
   WHERE b2.category_mean=kb_category_mean))
 ;end delete
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to delete from bedrock br_datamart_text table: ",errmsg)
  GO TO exit_script
 ENDIF
 DELETE  FROM br_datam_report_layout b
  WHERE b.br_datamart_report_id IN (
  (SELECT
   b2.br_datamart_report_id
   FROM br_datamart_report b2
   WHERE b2.br_datamart_category_id IN (
   (SELECT
    b3.br_datamart_category_id
    FROM br_datamart_category b3
    WHERE b3.category_mean=kb_category_mean))))
 ;end delete
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to delete from bedrock br_datam_report_layout table: ",
   errmsg)
  GO TO exit_script
 ENDIF
 DELETE  FROM br_datamart_report_default b
  WHERE b.br_datamart_report_id IN (
  (SELECT
   b2.br_datamart_report_id
   FROM br_datamart_report b2
   WHERE b2.br_datamart_category_id IN (
   (SELECT
    b3.br_datamart_category_id
    FROM br_datamart_category b3
    WHERE b3.category_mean=kb_category_mean))))
 ;end delete
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to delete from bedrock br_datamart_report_default table: ",errmsg)
  GO TO exit_script
 ENDIF
 DELETE  FROM br_datamart_report b
  WHERE (b.br_datamart_category_id=
  (SELECT
   b2.br_datamart_category_id
   FROM br_datamart_category b2
   WHERE b2.category_mean=kb_category_mean))
 ;end delete
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to delete from bedrock br_datamart_report table: ",errmsg
   )
  GO TO exit_script
 ENDIF
 DELETE  FROM br_datamart_filter_detail b3
  WHERE (b3.br_datamart_filter_id=
  (SELECT
   b3.br_datamart_filter_id
   FROM br_datamart_category b2,
    br_datamart_filter b3
   WHERE b3.br_datamart_category_id=b2.br_datamart_category_id
    AND b2.category_mean=kb_category_mean))
 ;end delete
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to delete from bedrock br_datamart_filter_detail table: ",
   errmsg)
  GO TO exit_script
 ENDIF
 DELETE  FROM br_datam_val_set_item_meas
  WHERE br_datam_val_set_item_id IN (
  (SELECT
   br_datam_val_set_item_id
   FROM br_datam_val_set_item
   WHERE br_datam_val_set_id IN (
   (SELECT
    br_datam_val_set_id
    FROM br_datam_val_set
    WHERE (br_datamart_category_id=
    (SELECT
     b2.br_datamart_category_id
     FROM br_datamart_category b2
     WHERE b2.category_mean=kb_category_mean))))))
 ;end delete
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to delete from bedrock br_datam_val_set_item_meas table: ",errmsg)
  GO TO exit_script
 ENDIF
 DELETE  FROM br_datam_val_set_item
  WHERE br_datam_val_set_id IN (
  (SELECT
   br_datam_val_set_id
   FROM br_datam_val_set
   WHERE (br_datamart_category_id=
   (SELECT
    b2.br_datamart_category_id
    FROM br_datamart_category b2
    WHERE b2.category_mean=kb_category_mean))))
 ;end delete
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to delete from bedrock br_datam_val_set_item table: ",
   errmsg)
  GO TO exit_script
 ENDIF
 DELETE  FROM br_datamart_filter b
  WHERE (b.br_datamart_category_id=
  (SELECT
   b2.br_datamart_category_id
   FROM br_datamart_category b2
   WHERE b2.category_mean=kb_category_mean))
 ;end delete
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to delete from bedrock br_datamart_filter table: ",errmsg
   )
  GO TO exit_script
 ENDIF
 DELETE  FROM br_datam_val_set
  WHERE (br_datamart_category_id=
  (SELECT
   b2.br_datamart_category_id
   FROM br_datamart_category b2
   WHERE b2.category_mean=kb_category_mean))
 ;end delete
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to delete from bedrock br_datam_val_set table: ",errmsg)
  GO TO exit_script
 ENDIF
 DELETE  FROM mp_viewpoint_reltn b
  WHERE (b.br_datamart_category_id=
  (SELECT
   b2.br_datamart_category_id
   FROM br_datamart_category b2
   WHERE b2.category_mean=kb_category_mean))
 ;end delete
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to delete from bedrock mp_viewpoint_reltn table: ",errmsg
   )
  GO TO exit_script
 ENDIF
 DELETE  FROM br_datam_mapping_type b
  WHERE (b.br_datamart_category_id=
  (SELECT
   b2.br_datamart_category_id
   FROM br_datamart_category b2
   WHERE b2.category_mean=kb_category_mean))
 ;end delete
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to delete from bedrock br_datam_mapping_type table: ",
   errmsg)
  GO TO exit_script
 ENDIF
 DELETE  FROM br_datamart_category
  WHERE category_mean=kb_category_mean
 ;end delete
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to delete from bedrock br_datamart_category table: ",
   errmsg)
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
