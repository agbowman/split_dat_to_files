CREATE PROGRAM dcp_get_printer_banner:dba
 RECORD reply(
   1 banner_ind = i2
   1 device_name = vc
   1 data_status_ind = i2
   1 publish_level = i4
   1 event_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "S"
 DECLARE inprogress = i4 WITH private, constant(1)
 DECLARE transcribed = i4 WITH private, constant(2)
 DECLARE authenticated = i4 WITH private, constant(4)
 SET reply->event_cd = request->event_cd
 SELECT INTO "nl:"
  FROM note_type nt
  WHERE (nt.event_cd=request->event_cd)
  HEAD REPORT
   reply->device_name = nt.device_name, reply->banner_ind = nt.banner_ind, reply->data_status_ind =
   nt.data_status_ind,
   reply->publish_level = nt.publish_level
  WITH nocounter
 ;end select
 IF (((curqual=0) OR ((((reply->publish_level < inprogress)) OR ((reply->publish_level >
 authenticated))) )) )
  SET reply->publish_level = transcribed
 ENDIF
 IF (curqual=0)
  SET reply->banner_ind = 1
  SET reply->device_name = ""
  SET reply->data_status_ind = 0
 ENDIF
END GO
