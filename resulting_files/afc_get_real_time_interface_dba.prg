CREATE PROGRAM afc_get_real_time_interface:dba
 RECORD reply(
   1 interface_file_qual = i2
   1 interface_file[*]
     2 interface_file_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET count1 = 0
 SET stat = alterlist(reply->interface_file,count1)
 SELECT INTO "nl:"
  i.*
  FROM interface_file i
  WHERE i.realtime_ind=1
   AND i.active_ind=1
  DETAIL
   count1 = (count1+ 1), stat = alterlist(reply->interface_file,count1), reply->interface_file[count1
   ].interface_file_id = i.interface_file_id,
   CALL echo(concat("interface_file_id: ",cnvtstring(i.interface_file_id)))
  WITH nocounter
 ;end select
 SET reply->interface_file_qual = count1
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "Select"
  SET reply->status_data.subeventstatus[1].operationstatus = "s"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "INTERFACE_FILE"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
