CREATE PROGRAM dm_prsnl_cmb_omf_encntr_st:dba
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
 DECLARE new_cmb_last_updt = f8
 DECLARE errormsg = c132
 DECLARE errorcode = i4
 SET errormsg = " "
 SET errorcode = 0
 SET new_cmb_last_updt = 0.0
 EXECUTE dm_dbimport "cer_install:dm_prsnl_cmb_omf_encntr_st.csv", "dm_dm_cmb_exception_import", 10
 IF ((readme_data->status="F"))
  SET readme_data->message = "cer_install:dm_prsnl_cmb_omf_encntr_st.csv was not found"
  GO TO end_program
 ENDIF
 SET readme_data->status = "F"
 SELECT INTO "nl:"
  FROM dm_cmb_exception dce
  WHERE dce.operation_type="COMBINE"
   AND dce.parent_entity="PRSNL"
   AND dce.child_entity="OMF_ENCNTR_ST"
  WITH nocounter
 ;end select
 IF (curqual <= 0)
  GO TO end_program
 ENDIF
 SELECT INTO "nl:"
  FROM dm_cmb_exception dce
  WHERE dce.operation_type="COMBINE"
   AND dce.parent_entity="PERSON"
   AND dce.child_entity="DCP_ERROR_LOG"
  WITH nocounter
 ;end select
 IF (curqual <= 0)
  GO TO end_program
 ENDIF
 SELECT INTO "nl:"
  FROM dm_cmb_exception dce
  WHERE dce.operation_type="COMBINE"
   AND dce.parent_entity="ENCOUNTER"
   AND dce.child_entity="DCP_ERROR_LOG"
  WITH nocounter
 ;end select
 IF (curqual <= 0)
  GO TO end_program
 ENDIF
 SELECT INTO "nl:"
  FROM dm_cmb_exception dce
  WHERE dce.operation_type="COMBINE"
   AND dce.parent_entity="ENCOUNTER"
   AND dce.child_entity="DM_COMBINE_QUEUE"
  WITH nocounter
 ;end select
 IF (curqual <= 0)
  GO TO end_program
 ENDIF
 SELECT INTO "nl:"
  FROM dm_info d
  WHERE d.info_domain="DATA MANAGEMENT"
   AND d.info_name="USERLASTUPDT"
  DETAIL
   new_cmb_last_updt = datetimeadd(d.info_date,- (2))
  WITH nocounter
 ;end select
 IF (curqual > 0
  AND new_cmb_last_updt > 0.0)
  UPDATE  FROM dm_info i
   SET i.info_date = cnvtdatetime(new_cmb_last_updt)
   WHERE i.info_domain="DATA MANAGEMENT"
    AND i.info_name IN ("CMB_LAST_UPDT2", "CMB_LAST_UPDT")
   WITH nocounter
  ;end update
  CALL echo("Update made to DM_INFO")
 ENDIF
 SET errorcode = error(errormsg,1)
 IF (errorcode > 0)
  CALL echo("Update to DM_INFO failed")
  GO TO end_program
 ENDIF
 SET readme_data->status = "S"
#end_program
 IF ((readme_data->status="F"))
  SET readme_data->message = concat("ERROR: dm_cmb_exception import failed. - ",errormsg)
  ROLLBACK
 ELSE
  SET readme_data->message = "SUCCESS: all rows imported into dm_cmb_exception"
  COMMIT
 ENDIF
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
