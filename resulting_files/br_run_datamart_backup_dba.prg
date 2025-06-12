CREATE PROGRAM br_run_datamart_backup:dba
 FREE RECORD backuprequest
 RECORD backuprequest(
   1 tables[17]
     2 table_name = vc
     2 temp_tbl_prefix = vc
     2 temp_tbl_suffix = vc
 )
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
 SET readme_data->message = "Readme Failed: Starting <br_run_datamart_backup.prg> script"
 SET backuprequest->tables[1].temp_tbl_prefix = "TMP_BR_DMC"
 SET backuprequest->tables[1].temp_tbl_suffix = "_BKUP"
 SET backuprequest->tables[1].table_name = "BR_DATAMART_CATEGORY"
 SET backuprequest->tables[2].temp_tbl_prefix = "TMP_BR_DMD"
 SET backuprequest->tables[2].temp_tbl_suffix = "_BKUP"
 SET backuprequest->tables[2].table_name = "BR_DATAMART_DEFAULT"
 SET backuprequest->tables[3].temp_tbl_prefix = "TMP_BR_DMDD"
 SET backuprequest->tables[3].temp_tbl_suffix = "_BKUP"
 SET backuprequest->tables[3].table_name = "BR_DATAMART_DEFAULT_DETAIL"
 SET backuprequest->tables[4].temp_tbl_prefix = "TMP_BR_DMF"
 SET backuprequest->tables[4].temp_tbl_suffix = "_BKUP"
 SET backuprequest->tables[4].table_name = "BR_DATAMART_FILTER"
 SET backuprequest->tables[5].temp_tbl_prefix = "TMP_BR_DMFC"
 SET backuprequest->tables[5].temp_tbl_suffix = "_BKUP"
 SET backuprequest->tables[5].table_name = "BR_DATAMART_FILTER_CATEGORY"
 SET backuprequest->tables[6].temp_tbl_prefix = "TMP_BR_DMFD"
 SET backuprequest->tables[6].temp_tbl_suffix = "_BKUP"
 SET backuprequest->tables[6].table_name = "BR_DATAMART_FILTER_DETAIL"
 SET backuprequest->tables[7].temp_tbl_prefix = "TMP_BR_DMFX"
 SET backuprequest->tables[7].temp_tbl_suffix = "_BKUP"
 SET backuprequest->tables[7].table_name = "BR_DATAMART_FLEX"
 SET backuprequest->tables[8].temp_tbl_prefix = "TMP_BR_DMR"
 SET backuprequest->tables[8].temp_tbl_suffix = "_BKUP"
 SET backuprequest->tables[8].table_name = "BR_DATAMART_REPORT"
 SET backuprequest->tables[9].temp_tbl_prefix = "TMP_BR_DMRD"
 SET backuprequest->tables[9].temp_tbl_suffix = "_BKUP"
 SET backuprequest->tables[9].table_name = "BR_DATAMART_REPORT_DEFAULT"
 SET backuprequest->tables[10].temp_tbl_prefix = "TMP_BR_DMRFR"
 SET backuprequest->tables[10].temp_tbl_suffix = "_BKUP"
 SET backuprequest->tables[10].table_name = "BR_DATAMART_REPORT_FILTER_R"
 SET backuprequest->tables[11].temp_tbl_prefix = "TMP_BR_DMT"
 SET backuprequest->tables[11].temp_tbl_suffix = "_BKUP"
 SET backuprequest->tables[11].table_name = "BR_DATAMART_TEXT"
 SET backuprequest->tables[12].temp_tbl_prefix = "TMP_BR_DMV"
 SET backuprequest->tables[12].temp_tbl_suffix = "_BKUP"
 SET backuprequest->tables[12].table_name = "BR_DATAMART_VALUE"
 SET backuprequest->tables[13].temp_tbl_prefix = "TMP_BR_DMM"
 SET backuprequest->tables[13].temp_tbl_suffix = "_BKUP"
 SET backuprequest->tables[13].table_name = "BR_DATAM_MAPPING_TYPE"
 SET backuprequest->tables[14].temp_tbl_prefix = "TMP_BR_DMRL"
 SET backuprequest->tables[14].temp_tbl_suffix = "_BKUP"
 SET backuprequest->tables[14].table_name = "BR_DATAM_REPORT_LAYOUT"
 SET backuprequest->tables[15].temp_tbl_prefix = "TMP_BR_DMVS"
 SET backuprequest->tables[15].temp_tbl_suffix = "_BKUP"
 SET backuprequest->tables[15].table_name = "BR_DATAM_VAL_SET"
 SET backuprequest->tables[16].temp_tbl_prefix = "TMP_BR_DMVSI"
 SET backuprequest->tables[16].temp_tbl_suffix = "_BKUP"
 SET backuprequest->tables[16].table_name = "BR_DATAM_VAL_SET_ITEM"
 SET backuprequest->tables[17].temp_tbl_prefix = "TMP_BR_DMVSIM"
 SET backuprequest->tables[17].temp_tbl_suffix = "_BKUP"
 SET backuprequest->tables[17].table_name = "BR_DATAM_VAL_SET_ITEM_MEAS"
 EXECUTE br_create_backup  WITH replace("REQUEST",backuprequest)
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
