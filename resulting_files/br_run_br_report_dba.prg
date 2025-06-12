CREATE PROGRAM br_run_br_report:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_run_br_report.prg> script"
 DECLARE errmsg = vc WITH protect, noconstant("")
 DELETE  FROM br_report br
  PLAN (br
   WHERE ((cnvtupper(trim(br.program_name)) IN ("BED_AUD_CORE_CHG_SERV", "BED_AUD_AP_ORC_MATCH",
   "BED_AUD_BB_DISPLAYS", "BED_AUD_FN_DEF_RELTN", "BED_AUD_BB_CDF_ISSUES",
   "BED_AUD_BB_1606_PC_COMPARE", "BED_AUD_BB_ORC_MATCH", "BED_AUD_LAB_ORC_DTA",
   "BED_AUD_LAB_COLLECTIONS", "BED_AUD_WORK_RTG",
   "BED_AUD_DOC_BLD_REC", "BED_AUD_EMAR_BLD_REC", "BED_AUD_IVIEW_BLD_REC", "BED_AUD_MARSUM_BLD_REC",
   "BED_AUD_MEDREC_BLD_REC",
   "BED_AUD_ORDERS_BLD_REC", "BED_AUD_IVIEW_DESIGN_REPORT", "BED_AUD_UNAUTH_ENCOUNTERS",
   "BED_AUD_UNAUTH_HEALTH_PLANS", "BED_AUD_UNAUTH_ORGANIZATIONS",
   "BED_AUD_UNAUTH_PHYSICIANS", "BED_AUD_UNAUTH_CODE_VALUES", "BED_AUD_LAB_ORC_INCMPLT",
   "BED_AUD_DTA_INFO")) OR (cnvtupper(trim(br.program_name))="BED_AUD_VV*")) )
  WITH nocounter
 ;end delete
 IF (error(errmsg,1) != 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Readme Failed: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 EXECUTE dm_dbimport "cer_install:report_tbl.csv", "br_report_table_config", 5000
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
