CREATE PROGRAM at_rdm_init_condition_ad:dba
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
 DECLARE rdm_errcode = i4
 DECLARE rdm_errmsg = c132
 DECLARE errmsg = c132
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed:  Starting script at_rdm_init_condition_ad"
 UPDATE  FROM at_precondition
  SET pre_actiondetail_ind = 1
  WHERE pre_keyword_id != 0
 ;end update
 SET rdm_errmsg = fillstring(132," ")
 SET rdm_errcode = error(rdm_errmsg,1)
 IF (rdm_errcode != 0)
  SET errmsg = rdm_errmsg
  GO TO exit_program
 ELSE
  COMMIT
 ENDIF
 UPDATE  FROM at_postcondition
  SET pos_actiondetail_ind = 1
  WHERE pos_keyword_id != 0
 ;end update
 SET rdm_errmsg = fillstring(132," ")
 SET rdm_errcode = error(rdm_errmsg,1)
 IF (rdm_errcode != 0)
  SET errmsg = rdm_errmsg
  GO TO exit_program
 ELSE
  COMMIT
 ENDIF
 SET readme_data->status = "S"
#exit_program
 IF ((readme_data->status="F"))
  SET readme_data->message = errmsg
  ROLLBACK
 ELSEIF ((readme_data->status="S"))
  SET readme_data->message = "Successfully initialized AD fields for the AT condition tables."
 ENDIF
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
