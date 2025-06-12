CREATE PROGRAM dcp_get_event_hist:dba
 RECORD reply(
   1 event_hist_list[*]
     2 event_id = f8
     2 valid_until_dt_tm = dq8
     2 valid_from_dt_tm = dq8
     2 event_end_tz = i4
     2 event_class_cd = f8
     2 event_class_disp = c40
     2 event_class_desc = c60
     2 event_class_mean = vc
     2 event_cd = f8
     2 event_disp = c40
     2 event_desc = c60
     2 event_mean = vc
     2 event_tag = vc
     2 result_val = vc
     2 result_status_cd = f8
     2 result_status_disp = c40
     2 result_status_desc = c60
     2 result_status_mean = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count = 0
 IF ((((request->event_id=0)) OR ((request->event_id=null))) )
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  ce.event_id, ce.valid_from_dt_tm, ce.valid_until_dt_tm,
  ce.event_class_cd, ce.event_cd, ce.event_tag,
  ce.result_val, ce.result_status_cd
  FROM clinical_event ce
  WHERE (ce.event_id=request->event_id)
   AND (ce.view_level >= request->view_level)
   AND (ce.publish_flag=request->publish_flag)
  ORDER BY ce.valid_from_dt_tm DESC
  DETAIL
   count = (count+ 1)
   IF (count > size(reply->event_hist_list,5))
    stat = alterlist(reply->event_hist_list,(count+ 5))
   ENDIF
   reply->event_hist_list[count].event_id = ce.event_id, reply->event_hist_list[count].
   valid_from_dt_tm = ce.valid_from_dt_tm, reply->event_hist_list[count].valid_until_dt_tm = ce
   .valid_until_dt_tm,
   reply->event_hist_list[count].event_end_tz = validate(ce.event_end_tz,0), reply->event_hist_list[
   count].event_class_cd = ce.event_class_cd, reply->event_hist_list[count].event_cd = ce.event_cd,
   reply->event_hist_list[count].event_tag = ce.event_tag, reply->event_hist_list[count].result_val
    = ce.result_val, reply->event_hist_list[count].result_status_cd = ce.result_status_cd
  FOOT REPORT
   stat = alterlist(reply->event_hist_list,count)
  WITH nocounter
 ;end select
 IF (count > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
#exit_script
END GO
