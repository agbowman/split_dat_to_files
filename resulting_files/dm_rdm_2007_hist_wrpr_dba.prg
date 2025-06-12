CREATE PROGRAM dm_rdm_2007_hist_wrpr:dba
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
 SET hist_2007_load_version = "000"
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed: Starting script - dm_rdm_2007_hist_wrpr.prg..."
 EXECUTE dm_dbimport "cer_install:hist2007lst.csv", "dm_rdm_2007_hist_load", 1000
END GO
