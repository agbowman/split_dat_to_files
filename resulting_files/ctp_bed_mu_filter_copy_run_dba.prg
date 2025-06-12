CREATE PROGRAM ctp_bed_mu_filter_copy_run:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "File Name" = "cer_install:ctp_bed_mu_filter_cp.csv",
  "Import Script" = "ctp_bed_mu_filter_copy_imp",
  "Batch Size" = 10000
  WITH outdev, filename, import_script,
  batch_size
 SET modify = filestream
 RECORD RUN::import(
   1 run_dt_tm = dq8
   1 file_name = vc
   1 script_name = vc
   1 log_file = vc
   1 logical = vc
   1 batch_size = i4
   1 sequence_id = f8
   1 rows_processed = i4
   1 rows_with_errors = i4
   1 error = i2
 ) WITH protect
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
 ) WITH protect
 DECLARE RUN::doc_link = vc WITH protect, constant("https://wiki.ucern.com/x/CudbWg")
 DECLARE RUN::log_file_name = vc WITH protect, constant("ctp_bed_mu_filter_copy_log_")
 DECLARE tab = c1 WITH protect, constant(char(9))
 DECLARE max_batch_size = i4 WITH protect, constant(10000)
 DECLARE success = i1 WITH protect, constant(0)
 DECLARE file_not_found = i1 WITH protect, constant(1)
 DECLARE object_not_found = i1 WITH protect, constant(2)
 DECLARE table_def_error = i1 WITH protect, constant(3)
 DECLARE insert_tracking_err = i1 WITH protect, constant(4)
 DECLARE update_tracking_err = i1 WITH protect, constant(5)
 DECLARE table_def_prg_err = i1 WITH protect, constant(6)
 DECLARE version_error = i1 WITH protect, constant(7)
 DECLARE row_limit_error = i1 WITH protect, constant(8)
 DECLARE group_sec_error = i1 WITH protect, constant(9)
 DECLARE error_status = i1 WITH protect, noconstant(0)
 DECLARE RUN::debug_on = i1 WITH protect, noconstant(0)
 IF (validate(ctp_bed_mu_filter_copy_import_debug))
  SET RUN::debug_on = true
 ENDIF
 IF (findfile(trim( $FILENAME,3)))
  SET run::import->file_name = trim( $FILENAME,3)
 ELSE
  SET error_status = file_not_found
  GO TO status_message
 ENDIF
 IF (checkprg(trim(cnvtupper( $IMPORT_SCRIPT),3)))
  SET run::import->script_name = trim(cnvtupper( $IMPORT_SCRIPT),3)
 ELSE
  SET error_status = object_not_found
  GO TO status_message
 ENDIF
 IF (cnvtint( $BATCH_SIZE) BETWEEN 1 AND max_batch_size)
  SET run::import->batch_size = cnvtint( $BATCH_SIZE)
 ELSE
  SET run::import->batch_size = max_batch_size
 ENDIF
 SET run::import->run_dt_tm = cnvtdatetime(sysdate)
 SET run::import->logical = "ccluserdir:"
 SET run::import->log_file = build(RUN::log_file_name,format(curdate,"YYYYMMDD;;d"),"_",format(
   curtime3,"HHMMSSCC;3;m"),".log")
 EXECUTE dm_dbimport run::import->file_name, run::import->script_name, run::import->batch_size
#status_message
 IF (error_status != success)
  SET run::import->error = true
 ENDIF
#exit_script
 SET last_mod = "000 12/01/16 rv5893 Initial Release"
END GO
