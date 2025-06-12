CREATE PROGRAM br_run_drop_dmart_backup
 FREE RECORD droprequest
 RECORD droprequest(
   1 temp_tbl_pattern = vc
 )
 SET droprequest->temp_tbl_pattern = "TMP_BR_DM*_BKUP"
 EXECUTE br_drop_backup  WITH replace("REQUEST",droprequest)
END GO
