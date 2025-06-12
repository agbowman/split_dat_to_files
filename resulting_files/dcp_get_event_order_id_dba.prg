CREATE PROGRAM dcp_get_event_order_id:dba
 FREE RECORD reply
 RECORD reply(
   1 event_id_cnt = i4
   1 event_id_list[*]
     2 event_id = f8
     2 order_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE index = i4 WITH protect, noconstant(0)
 DECLARE t1 = i4 WITH protect, noconstant(0)
 SET reply->event_id_cnt = size(request->event_id_list,5)
 SET reply->status_data.status = "F"
 SET stat = alterlist(reply->event_id_list,reply->event_id_cnt)
 SELECT INTO "nl"
  FROM clinical_event ce,
   (dummyt d  WITH seq = reply->event_id_cnt)
  PLAN (d)
   JOIN (ce
   WHERE (ce.event_id=request->event_id_list[d.seq].event_id)
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00"))
  HEAD REPORT
   count = 0
  DETAIL
   reply->event_id_list[d.seq].order_id = ce.order_id, reply->event_id_list[d.seq].event_id = ce
   .event_id, count = (count+ 1),
   reply->event_id_cnt = count
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->event_id_list,reply->event_id_cnt)
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
