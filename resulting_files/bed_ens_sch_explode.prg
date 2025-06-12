CREATE PROGRAM bed_ens_sch_explode
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET batch_freq_request
 RECORD batch_freq_request(
   1 call_echo_ind = i2
   1 qual_cnt = i4
   1 qual[*]
     2 frequency_id = f8
     2 freq_type_cd = f8
     2 freq_type_meaning = c12
     2 freq_state_cd = f8
     2 freq_state_meaning = c12
     2 beg_dt_tm = dq8
     2 end_dt_tm = dq8
     2 end_type_cd = f8
     2 end_type_meaning = c12
     2 next_dt_tm = dq8
     2 max_dt_tm = dq8
     2 max_occurance = i4
     2 occurance = i4
     2 apply_range = i4
     2 interval = i4
     2 weekdays = c7
     2 days_of_week = c10
     2 day_string = c31
     2 week_string = c6
     2 month_string = c12
     2 counter = i4
     2 units = i4
     2 units_cd = f8
     2 units_meaning = c12
     2 freq_pattern_cd = f8
     2 freq_pattern_meaning = c12
     2 pattern_option = i4
     2 parent_table = vc
     2 parent_id = f8
     2 ref_freq_id = f8
     2 commit_size = i4
 )
 SET tempreply->status_data.status = "F"
 SET error_flag = "Y"
 DECLARE error_msg = vc
 SET tempreply->bypass_ind = 0
 SET batch_freq_request->qual_cnt = size(frequency_list,5)
 SET stat = alterlist(batch_freq_request->qual,batch_freq_request->qual_cnt)
 FOR (i = 1 TO batch_freq_request->qual_cnt)
   SET batch_freq_request->qual[i].frequency_id = request->frequency_list[i].frequency_id
 ENDFOR
 EXECUTE sch_batch_freq
 SET error_flag = "N"
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->error_msg = error_msg
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
