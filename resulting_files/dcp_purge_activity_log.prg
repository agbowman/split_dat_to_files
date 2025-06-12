CREATE PROGRAM dcp_purge_activity_log
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 logs[*]
     2 activity_log_id = f8
 )
 SET dal_count = 0
 SET dal_del = 0
 SET buffer_check = 0
 SET purge_day = cnvtint(request->batch_selection)
 IF (purge_day < 3)
  SET purge_day = 14
 ENDIF
 SET interval = build(abs(purge_day),"D")
 SET cutoff_day = cnvtlookbehind(interval,cnvtdatetime(curdate,curtime3))
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  dal.activity_log_id
  FROM dcp_activity_log dal
  WHERE dal.activity_dt_tm < cnvtdatetime(cutoff_day)
   AND dal.activity_log_id > 0
  ORDER BY dal.activity_log_id
  HEAD REPORT
   dal_count = 0
  DETAIL
   dal_count = (dal_count+ 1), stat = alterlist(temp->logs,dal_count), temp->logs[dal_count].
   activity_log_id = dal.activity_log_id
  WITH nocounter
 ;end select
 SET dal_cnt = dal_count
 FOR (dal_del = 1 TO dal_cnt)
   SET buffer_check = mod(dal_del,1000)
   IF (buffer_check=0)
    COMMIT
   ENDIF
   DELETE  FROM dcp_activity_log dal
    WHERE (dal.activity_log_id=temp->logs[dal_del].activity_log_id)
    WITH nocounter
   ;end delete
 ENDFOR
 IF (dal_count=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF (dal_cnt=0)
  ROLLBACK
 ELSE
  COMMIT
 ENDIF
END GO
