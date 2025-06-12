CREATE PROGRAM cp_add_file_path_param:dba
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
 SET successful_cnt = 0
 SET count1 = 0
 FREE SET temp_rec
 RECORD temp_rec(
   1 temp_list[*]
     2 charting_operations_id = f8
     2 sequence = i4
     2 batch_name = vc
     2 batch_name_key = vc
     2 has_17 = i2
     2 highest_seq = i4
     2 active_ind = i2
 )
 SET successful_cnt = 0
 SET active_cd = 0.0
 SET inactive_cd = 0.0
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.cdf_meaning IN ("ACTIVE", "INACTIVE")
   AND cv.code_set=48
  HEAD REPORT
   do_nothing = 0
  DETAIL
   IF (cv.cdf_meaning="ACITVE")
    active_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="INACTIVE")
    inactive_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 DELETE  FROM charting_operations c
  WHERE c.param_type_flag=17
   AND c.active_ind=0
  WITH nocounter
 ;end delete
 SELECT INTO "nl:"
  co.charting_operations_id
  FROM charting_operations co
  PLAN (co)
  ORDER BY co.charting_operations_id, co.sequence
  HEAD REPORT
   count1 = 0
  HEAD co.charting_operations_id
   do_nothing = 0, count1 += 1, stat = alterlist(temp_rec->temp_list,count1),
   temp_rec->temp_list[count1].highest_seq = 0, temp_rec->temp_list[count1].has_17 = 0
  DETAIL
   do_nothing = 0
   IF ((co.sequence > temp_rec->temp_list[count1].highest_seq))
    temp_rec->temp_list[count1].highest_seq = co.sequence
   ENDIF
   IF (co.param_type_flag=17
    AND co.active_ind=1)
    temp_rec->temp_list[count1].has_17 = 1
   ENDIF
  FOOT  co.charting_operations_id
   temp_rec->temp_list[count1].charting_operations_id = co.charting_operations_id, temp_rec->
   temp_list[count1].sequence = co.sequence, temp_rec->temp_list[count1].batch_name = co.batch_name,
   temp_rec->temp_list[count1].batch_name_key = co.batch_name_key, temp_rec->temp_list[count1].
   active_ind = co.active_ind
  WITH nocounter
 ;end select
 SET x = 0
 FOR (x = 1 TO count1)
   IF ((temp_rec->temp_list[x].has_17=0))
    CALL insert_param_in_ops(x)
   ENDIF
 ENDFOR
 SUBROUTINE insert_param_in_ops(index)
  INSERT  FROM charting_operations c
   SET c.charting_operations_id = temp_rec->temp_list[index].charting_operations_id, c.sequence = (
    temp_rec->temp_list[index].highest_seq+ 1), c.batch_name = temp_rec->temp_list[index].batch_name,
    c.batch_name_key = temp_rec->temp_list[index].batch_name_key, c.param_type_flag = 17, c.param =
    " ",
    c.active_ind =
    IF ((temp_rec->temp_list[index].active_ind=1)) 1
    ELSE 0
    ENDIF
    , c.active_status_cd =
    IF ((temp_rec->temp_list[index].active_ind=1)) active_cd
    ELSE inactive_cd
    ENDIF
    , c.active_status_dt_tm = cnvtdatetime(sysdate),
    c.active_status_prsnl_id = 0.0, c.updt_cnt = 0, c.updt_dt_tm = cnvtdatetime(sysdate),
    c.updt_id = 0.0, c.updt_task = 0, c.updt_applctx = 0
   WITH nocounter
  ;end insert
  IF (curqual > 0)
   SET successful_cnt += 1
  ENDIF
 END ;Subroutine
#exit_script
 SET errormsg = fillstring(256,"")
 SET error_check = error(errormsg,0)
 IF (error_check != 0)
  ROLLBACK
  SET readme_data->message = "Errors in cp_add_file_path_param - FAILURE"
  SET readme_data->status = "F"
  EXECUTE dm_readme_status
  CALL echo("FAILURE")
  COMMIT
 ELSE
  COMMIT
  SET readme_data->message =
  "Successfully added file-storage path to charting_operations table - SUCCESSFUL"
  SET readme_data->status = "S"
  EXECUTE dm_readme_status
  CALL echo("COMMIT")
  COMMIT
 ENDIF
END GO
