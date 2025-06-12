CREATE PROGRAM cv_get_res_stat_fro_ce:dba
 RECORD reply(
   1 event_hist_list[*]
     2 event_id = f8
     2 valid_until_dt_tm = dq8
     2 result_status_cd = f8
     2 event_end_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET result_cnt = 0
 SET count = 0
 SELECT INTO "nl:"
  ce.event_id, ce.valid_until_dt_tm, ce.result_status_cd,
  ce.event_end_dt_tm
  FROM clinical_event ce,
   (dummyt t  WITH seq = value(size(request->rec,5)))
  PLAN (t)
   JOIN (ce
   WHERE (ce.event_id=request->rec[t.seq].event_id))
  DETAIL
   result_cnt = (result_cnt+ 1)
   IF (result_cnt > size(reply->event_hist_list,5))
    stat = alterlist(reply->event_hist_list,(result_cnt+ 5))
   ENDIF
   reply->event_hist_list[result_cnt].event_id = ce.event_id, reply->event_hist_list[result_cnt].
   valid_until_dt_tm = ce.valid_until_dt_tm, reply->event_hist_list[result_cnt].result_status_cd = ce
   .result_status_cd,
   reply->event_hist_list[result_cnt].event_end_dt_tm = ce.event_end_dt_tm
  FOOT REPORT
   result_size = alterlist(reply->event_hist_list,result_cnt)
  WITH nocounter
 ;end select
 FOR (count = 1 TO result_cnt)
   CALL echo(build("Record No.: ",count))
   CALL echo(build("This is the result_status_cd: ",reply->event_hist_list[count].result_status_cd))
   CALL echo(build("This is the valid until date time: ",format(reply->event_hist_list[count].
      valid_until_dt_tm,";;Q")))
   CALL echo(build("This is the event end date time: ",format(reply->event_hist_list[count].
      event_end_dt_tm,";;Q")))
   CALL echo(build("This is the valid event_id: ",reply->event_hist_list[count].event_id))
 ENDFOR
 IF (result_cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#exit_script
END GO
