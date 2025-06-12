CREATE PROGRAM aps_chk_primitive_event_set:dba
 RECORD reply(
   1 event_qual[*]
     2 event_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE suppress_non_primitive_events_ind = i2 WITH noconstant(0)
 SET reply->status_data.status = "F"
 SET stat = alterlist(reply->event_qual,0)
 SELECT INTO "nl:"
  di.info_number
  FROM dm_info di
  WHERE di.info_domain="ANATOMIC PATHOLOGY"
   AND di.info_name="SUPPRESS NON-PRIMITIVE EVENTS"
  DETAIL
   suppress_non_primitive_events_ind = di.info_number
  WITH nocounter
 ;end select
 IF (suppress_non_primitive_events_ind=0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "DM_INFO"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(size(request->event_qual,5))),
   v500_event_set_explode ese
  PLAN (d1)
   JOIN (ese
   WHERE (ese.event_cd=request->event_qual[d1.seq].event_cd))
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->event_qual,(cnt+ 9))
   ENDIF
   reply->event_qual[cnt].event_cd = request->event_qual[d1.seq].event_cd
  FOOT REPORT
   stat = alterlist(reply->event_qual,cnt)
  WITH outerjoin = d1, dontexist
 ;end select
 SET reply->status_data.status = "S"
#exit_script
END GO
