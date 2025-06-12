CREATE PROGRAM cp_add_mcis_ind_to_ops:dba
 FREE SET temp_rec
 RECORD temp_rec(
   1 temp_list[*]
     2 charting_operations_id = f8
     2 batch_name = vc
     2 batch_name_key = vc
     2 active_ind = i2
 )
 SET failed = "F"
 SET count1 = 0
 SET count2 = 0
 SET active_cd = 0.0
 SET inactive_cd = 0.0
 SET successful_cnt = 0
 SELECT INTO "nl:"
  co.param_type_flag
  FROM charting_operations co
  WHERE co.param_type_flag=8
  WITH nocounter
 ;end select
 IF (curqual > 0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  PLAN (c
   WHERE c.code_set=48
    AND c.cdf_meaning IN ("ACTIVE", "INACTIVE"))
  DETAIL
   IF (c.cdf_meaning="ACTIVE")
    active_cd = c.code_value
   ENDIF
   IF (c.cdf_meaning="INACTIVE")
    inactive_cd = c.code_value
   ENDIF
  WITH nocounter
 ;end select
 UPDATE  FROM charting_operations co
  SET co.sequence = (co.sequence+ 1)
  WHERE co.param_type_flag=6
 ;end update
 SELECT INTO "nl:"
  c.charting_operations_id, c.batch_name, c.batch_name_key,
  c.active_ind
  FROM charting_operations c
  WHERE c.param_type_flag=1
  ORDER BY c.charting_operations_id
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 += 1, stat = alterlist(temp_rec->temp_list,count1), temp_rec->temp_list[count1].
   charting_operations_id = c.charting_operations_id,
   temp_rec->temp_list[count1].batch_name = c.batch_name, temp_rec->temp_list[count1].batch_name_key
    = c.batch_name_key, temp_rec->temp_list[count1].active_ind = c.active_ind
  WITH nocounter
 ;end select
 IF (count1 > 0)
  SET count2 = 1
  WHILE (count2 <= count1)
   CALL insert_param_in_ops(count2)
   SET count2 += 1
  ENDWHILE
 ENDIF
 SUBROUTINE insert_param_in_ops(cntindex)
  INSERT  FROM charting_operations c
   SET c.charting_operations_id = temp_rec->temp_list[cntindex].charting_operations_id, c.sequence =
    8, c.batch_name = temp_rec->temp_list[cntindex].batch_name,
    c.batch_name_key = temp_rec->temp_list[cntindex].batch_name_key, c.param_type_flag = 8, c.param
     = "0",
    c.active_ind = temp_rec->temp_list[cntindex].active_ind, c.active_status_cd =
    IF ((temp_rec->temp_list[cntindex].active_ind=1)) active_cd
    ELSE inactive_cd
    ENDIF
    , c.active_status_dt_tm = cnvtdatetime(sysdate),
    c.active_status_prsnl_id = 0.0, c.updt_cnt = 0, c.updt_dt_tm = cnvtdatetime(sysdate),
    c.updt_id = 0.0, c.updt_task = 0, c.updt_applctx = 0
  ;end insert
  IF (curqual > 0)
   SET successful_cnt += 1
  ENDIF
 END ;Subroutine
#exit_script
 IF (successful_cnt=count1)
  COMMIT
 ELSE
  ROLLBACK
 ENDIF
END GO
