CREATE PROGRAM cp_add_pend_fg_to_ops:dba
 RECORD reply(
   1 reply_list[*]
     2 charting_operations_id = f8
     2 batch_name = vc
     2 batch_name_key = vc
     2 active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET count1 = 0
 SET count2 = 0
 SET active_cd = 0.0
 SET inactive_cd = 0.0
 SET successful_cnt = 0
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
  SET co.sequence = (co.sequence+ 2)
  WHERE co.param_type_flag=6
 ;end update
 SELECT DISTINCT INTO "nl:"
  c.charting_operations_id, c.batch_name, c.batch_name_key,
  c.active_ind
  FROM charting_operations c
  HEAD REPORT
   count1 = 0, stat = alterlist(reply->reply_list,1)
  DETAIL
   count1 += 1
   IF (mod(count1,10)=1)
    stat = alterlist(reply->reply_list,(count1+ 9))
   ENDIF
   reply->reply_list[count1].charting_operations_id = c.charting_operations_id, reply->reply_list[
   count1].batch_name = c.batch_name, reply->reply_list[count1].batch_name_key = c.batch_name_key,
   reply->reply_list[count1].active_ind = c.active_ind
  FOOT REPORT
   stat = alterlist(reply->reply_list,count1)
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
   SET c.charting_operations_id = reply->reply_list[cntindex].charting_operations_id, c.sequence = 7,
    c.batch_name = reply->reply_list[cntindex].batch_name,
    c.batch_name_key = reply->reply_list[cntindex].batch_name_key, c.param_type_flag = 7, c.param =
    "0",
    c.active_ind = reply->reply_list[cntindex].active_ind, c.active_status_cd =
    IF ((reply->reply_list[cntindex].active_ind=1)) active_cd
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
 IF (successful_cnt > 0)
  SET reply->status_data.status = "S"
  COMMIT
 ELSE
  ROLLBACK
 ENDIF
END GO
