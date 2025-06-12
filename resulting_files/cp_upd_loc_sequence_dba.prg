CREATE PROGRAM cp_upd_loc_sequence:dba
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
 DECLARE loc_cd = f8 WITH noconstant(0.0)
 DECLARE error_holder = i4 WITH noconstant(0)
 DECLARE error_code = i4
 DECLARE errmsg = vc
 DECLARE locationnamekey = vc WITH protect, constant("LOCATIONSEQUENCEPATIENTNAME")
 DECLARE nno_error = i2 WITH protect, constant(1)
 DECLARE nccl_error = i2 WITH protect, constant(2)
 DECLARE nupdate_cnt_error = i2 WITH protect, constant(3)
 DECLARE ngen_nbr_error = i2 WITH protect, constant(4)
 SELECT INTO "nl:"
  FROM code_value c
  WHERE c.display_key=locationnamekey
 ;end select
 IF (curqual=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM code_value c
  WHERE c.code_set=22011
   AND trim(c.cdf_meaning)="23"
  DETAIL
   loc_cd = c.code_value
 ;end select
 UPDATE  FROM code_value c
  SET c.display = "Location Seq/Provider Name/Patient Name", c.description =
   "Location Seq/Provider Name/Patient Name", c.definition =
   "Location Seq/Provider Name/Patient Name",
   c.display_key = "LOCATIONSEQPROVIDERNAMEPATIENTNAME"
  WHERE c.code_value=loc_cd
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET error_holder = nupdate_cnt_error
 ENDIF
#exit_script
 SET error_code = error(errmsg,0)
 IF (((error_code != 0) OR (error_holder != 0)) )
  SET readme_data->status = "F"
  SET readme_data->message = errmsg
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = "Success"
 ENDIF
 IF ((readme_data->message != "F"))
  COMMIT
 ELSE
  ROLLBACK
 ENDIF
 CALL echo(build("STATUS_README = ",readme_data->status))
 CALL echo(build("STATUS_MESSAGE = ",readme_data->message))
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
