CREATE PROGRAM cpm_srv_exp_set_dm_info:dba
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
 RECORD request(
   1 info_domain = c80
   1 info_name = c200
   1 info_date = dq8
   1 info_char = c255
   1 info_number = f8
   1 info_long_id = f8
 )
 RECORD reply(
   1 error_ind = i4
   1 error_msg = c255
 )
 SET request->info_domain = "EXPEDITE SERVER"
 SET request->info_name = "INSTALLED"
 SET request->info_date = cnvtdatetime(curdate,curtime)
 EXECUTE dm_ins_upt_dm_info
 IF ((reply->error_ind=1))
  SET readme_data->status = "F"
  SET readme_data->message = reply->error_msg
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = "Dm_info table update successfully."
 ENDIF
 EXECUTE dm_readme_status
END GO
