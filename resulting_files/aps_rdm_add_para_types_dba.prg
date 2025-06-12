CREATE PROGRAM aps_rdm_add_para_types:dba
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
 DECLARE records_to_insert = i4 WITH constant(1), protect
 DECLARE num_records = i4 WITH noconstant(0), protect
 DECLARE cki_source = vc WITH constant("CAP_ECC_F"), protect
 DECLARE cki_apspec = vc WITH constant("APSPEC"), protect
 DECLARE countrecords() = i2
 DECLARE errmsg = vc WITH protect, noconstant("")
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed without processing"
 SET num_records = countrecords(null)
 IF (num_records=records_to_insert)
  SET readme_data->status = "S"
  SET readme_data->message = "Data already imported!"
 ELSE
  EXECUTE dm_dbimport "cer_install:aps_scd_paragraphs.csv", "cps_imp_scd_para_type", 1000
  IF ((readme_data->status="F"))
   GO TO exit_script
  ENDIF
  SET num_records = countrecords(null)
  IF (num_records != records_to_insert)
   SET readme_data->status = "F"
   SET readme_data->message = build(records_to_insert,
    " record should have been imported from the .csv file.  Import Failed!")
  ELSE
   SET readme_data->status = "S"
   SET readme_data->message = "Successful import!"
  ENDIF
 ENDIF
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
 COMMIT
 SUBROUTINE countrecords(null)
   DECLARE cnt = i4 WITH noconstant(0), protect
   SELECT INTO "nl:"
    FROM scr_paragraph_type pt
    WHERE pt.cki_source=cki_source
     AND pt.cki_identifier=cki_apspec
    FOOT REPORT
     cnt = count(pt.scr_paragraph_type_id)
    WITH nocounter
   ;end select
   IF (error(errmsg,0) > 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed in CountRecords subroutine",errmsg)
    RETURN(0)
   ENDIF
   RETURN(cnt)
 END ;Subroutine
END GO
