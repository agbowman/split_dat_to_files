CREATE PROGRAM dm2_und_dflt_rows_pathmicro:dba
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
#start_script
 SET readme_data->status = "F"
 EXECUTE dm2_undo_default_rows "MIC_RPT_PARAMS"
 EXECUTE dm2_undo_default_rows "MIC_STAT_SYSTEM_PREF"
 EXECUTE dm2_undo_default_rows "MIC_VALID_CODED_RESPONSE"
 EXECUTE dm2_undo_default_rows "LABEL_PRINTER_DEF"
 SELECT
  IF (currdb="ORACLE")
   FROM dm2_user_triggers ut
   WHERE ut.table_name IN ("MIC_RPT_PARAMS", "MIC_STAT_SYSTEM_PREF", "MIC_VALID_CODED_RESPONSE",
   "LABEL_PRINTER_DEF")
    AND ut.trigger_name="TRG*_DR_UPDT_DEL*"
  ELSE
   FROM dm2_user_triggers ut
   WHERE ut.table_name IN ("MIC_RPT_PARAMS", "MIC_STAT_SYSTEM_PREF", "MIC_VALID_CODED_RESPONSE",
   "LABEL_PRINTER_DEF")
    AND ((ut.trigger_name="TRG*_DRDEL*") OR (ut.trigger_name="TRG*_DRUPD*"))
  ENDIF
  INTO "NL:"
 ;end select
 IF (curqual != 0)
  SET readme_data->status = "F"
 ENDIF
 SELECT INTO "NL:"
  mrp.criteria_id
  FROM mic_rpt_params mrp
  WHERE mrp.criteria_id=0
 ;end select
 IF (curqual != 0)
  SET readme_data->status = "F"
 ENDIF
 SELECT INTO "NL:"
  msp.service_resource_cd
  FROM mic_stat_system_pref msp
  WHERE msp.service_resource_cd=0
 ;end select
 IF (curqual != 0)
  SET readme_data->status = "F"
 ENDIF
 SELECT INTO "NL:"
  mvr.valid_response_id
  FROM mic_valid_coded_response mvr
  WHERE mvr.valid_response_id=0
 ;end select
 IF (curqual != 0)
  SET readme_data->status = "F"
 ENDIF
 SELECT INTO "NL:"
  lpd.key_id
  FROM label_printer_def lpd
  WHERE lpd.key_id=0
 ;end select
 IF (curqual != 0)
  SET readme_data->status = "F"
 ENDIF
 SELECT INTO "nl:"
  FROM dm_tables_doc d
  WHERE d.default_row_ind=1
   AND d.table_name IN ("MIC_RPT_PARAMS", "MIC_STAT_SYSTEM_PREF", "MIC_VALID_CODED_RESPONSE",
  "LABEL_PRINTER_DEF")
  WITH nocounter
 ;end select
 IF (curqual != 0)
  SET readme_data->status = "F"
 ELSE
  SET readme_data->status = "S"
 ENDIF
#exit_script
 IF ((readme_data->status="F"))
  ROLLBACK
  SET readme_data->message = "Execution failed - see log message for more details."
 ELSE
  COMMIT
  SET readme_data->status = "S"
  SET readme_data->message = "Execution Successful."
 ENDIF
 EXECUTE dm_readme_status
END GO
