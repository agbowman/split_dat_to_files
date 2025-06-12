CREATE PROGRAM dms_get_event:dba
 CALL echo("<==================== Entering DMS_GET_EVENT Script ====================>")
 SET modify = predeclare
 CALL echorecord(request)
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 qual[*]
      2 event_ref_id = f8
      2 event_key = vc
      2 event_display = vc
      2 event_reason_ref_id = f8
      2 event_reason_key = vc
      2 event_reason_display = vc
      2 event_detail = vc
      2 event_comment = vc
      2 created_by_id = f8
      2 event_dt_tm = dq8
      2 event_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE SET qualcount
 DECLARE qualcount = i4 WITH noconstant(0)
 DECLARE idsize = i4 WITH noconstant(size(request->dms_event_ids,5))
 DECLARE num = i4 WITH noconstant(0)
 SET reply->status_data.status = "F"
 SELECT
  IF ((request->dms_media_instance_id > 0))
   PLAN (dme
    WHERE (dme.dms_media_instance_id=request->dms_media_instance_id))
    JOIN (dm1
    WHERE dm1.dms_ref_id=dme.dms_event_ref_id)
    JOIN (dm2
    WHERE dm2.dms_ref_id=dme.dms_reason_ref_id)
    JOIN (lt
    WHERE lt.long_text_id=dme.long_text_id)
  ELSE
   PLAN (dme
    WHERE expand(num,1,idsize,dme.dms_event_id,request->dms_event_ids[num].id))
    JOIN (dm1
    WHERE dm1.dms_ref_id=dme.dms_event_ref_id)
    JOIN (dm2
    WHERE dm2.dms_ref_id=dme.dms_reason_ref_id)
    JOIN (lt
    WHERE lt.long_text_id=dme.long_text_id)
  ENDIF
  INTO "nl:"
  dme.*, lt.long_text, lt.long_text_id
  FROM dms_event dme,
   dms_ref dm1,
   dms_ref dm2,
   long_text lt
  ORDER BY dme.event_dt_tm
  HEAD REPORT
   qualcount = 0
  DETAIL
   qualcount += 1
   IF (mod(qualcount,10)=1)
    stat = alterlist(reply->qual,(qualcount+ 9))
   ENDIF
   reply->qual[qualcount].event_id = dme.dms_event_id, reply->qual[qualcount].event_ref_id = dm1
   .dms_ref_id
   IF (dm1.dms_ref_id != 0.0)
    reply->qual[qualcount].event_key = dm1.ref_key, reply->qual[qualcount].event_display = dm1
    .display
   ENDIF
   reply->qual[qualcount].event_reason_ref_id = dm2.dms_ref_id
   IF (dm2.dms_ref_id != 0.0)
    reply->qual[qualcount].event_reason_key = dm2.ref_key, reply->qual[qualcount].
    event_reason_display = dm2.display
   ENDIF
   reply->qual[qualcount].event_comment = dme.event_comment, reply->qual[qualcount].event_dt_tm = dme
   .event_dt_tm, reply->qual[qualcount].created_by_id = dme.created_by_id
   IF (dme.long_text_id > 0)
    reply->qual[qualcount].event_detail = lt.long_text
   ELSE
    reply->qual[qualcount].event_detail = dme.event_detail
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->qual,qualcount)
  WITH nocounter
 ;end select
 IF (curqual <= 0)
  SET reply->status_data.status = "Z"
  GO TO end_script
 ENDIF
 SET reply->status_data.status = "S"
#end_script
 CALL echorecord(reply)
 CALL echo("<==================== Exiting DMS_GET_EVENTS Script ====================>")
END GO
