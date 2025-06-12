CREATE PROGRAM ecf_end_effect_offset_cleanup:dba
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
 SET readme_data->message = "Readme failed: starting script ecf_end_effect_offset_cleanup..."
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE table_exists = vc WITH protect, noconstant("N")
 UPDATE  FROM nomenclature n
  SET n.end_effective_dt_tm = cnvtdatetime(cnvtdate(12312100),0)
  WHERE n.end_effective_dt_tm > cnvtdatetime(cnvtdate(12312100),0)
  WITH nocounter
 ;end update
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Update to nomenclature table failed.",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 UPDATE  FROM cmt_concept_reltn n
  SET n.end_effective_dt_tm = cnvtdatetime(cnvtdate(12312100),0)
  WHERE n.end_effective_dt_tm > cnvtdatetime(cnvtdate(12312100),0)
  WITH nocounter
 ;end update
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Update to cmt_concept_reltn table failed.",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 UPDATE  FROM cmt_cross_map n
  SET n.end_effective_dt_tm = cnvtdatetime(cnvtdate(12312100),0)
  WHERE n.end_effective_dt_tm > cnvtdatetime(cnvtdate(12312100),0)
  WITH nocounter
 ;end update
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Update to cmt_cross_map table failed.",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 UPDATE  FROM cmt_concept_extension n
  SET n.end_effective_dt_tm = cnvtdatetime(cnvtdate(12312100),0)
  WHERE n.end_effective_dt_tm > cnvtdatetime(cnvtdate(12312100),0)
  WITH nocounter
 ;end update
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Update to cmt_concept_extension table failed.",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  FROM dba_tables d
  WHERE d.table_name="cmt_icd10_normalize"
  DETAIL
   table_exists = "Y"
  WITH nocounter
 ;end select
 IF (table_exists="Y")
  UPDATE  FROM cmt_icd10_normalize n
   SET n.end_effective_dt_tm = cnvtdatetime(cnvtdate(12312100),0)
   WHERE n.end_effective_dt_tm > cnvtdatetime(cnvtdate(12312100),0)
   WITH nocounter
  ;end update
  IF (error(errmsg,0) > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Update to cmt_icd10_normalize table failed.",errmsg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
 ENDIF
 UPDATE  FROM cmt_concept n
  SET n.end_effective_dt_tm = cnvtdatetime(cnvtdate(12312100),0)
  WHERE n.end_effective_dt_tm > cnvtdatetime(cnvtdate(12312100),0)
  WITH nocounter
 ;end update
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Update to cmt_concept table failed.",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 UPDATE  FROM cmt_cross_map_load n
  SET n.end_effective_dt_tm = cnvtdatetime(cnvtdate(12312100),0)
  WHERE n.end_effective_dt_tm > cnvtdatetime(cnvtdate(12312100),0)
  WITH nocounter
 ;end update
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Update to cmt_cross_map_load table failed.",errmsg)
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
