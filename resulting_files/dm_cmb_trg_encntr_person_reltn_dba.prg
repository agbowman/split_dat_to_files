CREATE PROGRAM dm_cmb_trg_encntr_person_reltn:dba
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
 DECLARE v_cmb_trg_cnt = i4
 SET v_cmb_trg_cnt = 0
 SET readme_data->status = "F"
 SET readme_data->message = "Begin DM_CMB_TRG_ENCNTR_PERSON_RELTN"
 EXECUTE dm2_combine_triggers "ENCNTR_PERSON_RELTN"
 EXECUTE dm2_combine_triggers "OMF_ENCNTR_ST"
 SELECT INTO "nl:"
  FROM user_triggers ut
  WHERE ut.table_name IN ("OMF_ENCNTR_ST", "ENCNTR_PERSON_RELTN")
   AND ut.trigger_name="TRG*PCMB*"
  DETAIL
   v_cmb_trg_cnt = (v_cmb_trg_cnt+ 1)
  WITH nocounter
 ;end select
 IF (v_cmb_trg_cnt >= 2)
  SET readme_data->status = "S"
  SET readme_data->message = "SUCCESS: trigger created successfully"
 ELSE
  SET readme_data->message = "FAIL: trigger not created"
 ENDIF
 IF ((readme_data->readme_id > 0))
  EXECUTE dm_readme_status
 ELSE
  CALL echorecord(readme_data)
 ENDIF
END GO
