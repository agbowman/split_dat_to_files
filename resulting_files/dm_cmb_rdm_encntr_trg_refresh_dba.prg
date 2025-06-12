CREATE PROGRAM dm_cmb_rdm_encntr_trg_refresh:dba
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
 SET readme_data->message = "Readme failed: starting script dm_cmb_rdm_encntr_trg_refresh..."
 DECLARE errmsg = vc WITH protect, noconstant("")
 FREE RECORD ct_error
 RECORD ct_error(
   1 message = vc
   1 err_ind = i2
 )
 SELECT INTO "nl:"
  FROM user_source us
  WHERE us.name="TRG_PCMB1_0077_ENCOUNTER"
   AND cnvtlower(us.text)="*select pc.person_combine_id into eci*"
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Unable to query user_source for TRG_PCMB1_0077_ENCOUNTER: ",
   errmsg)
  GO TO exit_script
 ENDIF
 IF (curqual=0)
  EXECUTE dm2_combine_triggers "ENCOUNTER"
  IF ((ct_error->err_ind > 0))
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed to create person combine trigger for table Encounter: ",
    ct_error->message)
   GO TO exit_script
  ELSE
   SET readme_data->message = "Success: Combine trigger for encounter table was updated"
  ENDIF
 ELSE
  SET readme_data->message = "Success: Combine trigger update for encounter table already found"
 ENDIF
 SET readme_data->status = "S"
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
