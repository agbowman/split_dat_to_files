CREATE PROGRAM bbd_rdm_updt_disp_wrap_14115
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
 SET readme_data->message = "Readme Failed: Starting bbd_rdm_updt_disp_wrap_14115."
 DECLARE csv1 = vc WITH public, noconstant("bbd_rdm_updt_disp_14115.csv")
 DECLARE csvtotal = i4 WITH public, noconstant(1)
 DECLARE rdm_current_status = c1 WITH public, noconstant("F")
 DECLARE dirandcsv1 = vc WITH public, noconstant(" ")
 IF (checkprg("RDM_GLOBAL_OMF"))
  EXECUTE rdm_global_omf csvtotal
  IF (rdm_current_status="F")
   GO TO end_now
  ENDIF
 ENDIF
 SET dirandcsv1 = concat("cer_install:",csv1)
 EXECUTE dm_dbimport dirandcsv1, "bbd_rdm_updt_code_values", 1000
#end_now
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
