CREATE PROGRAM bed_get_legacy_sr:dba
 FREE SET reply
 RECORD reply(
   1 sr_list[*]
     2 sr_display = c40
     2 sr_active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET count = 0
 SET tot_count = 0
 SET reply->status_data.status = "Z"
 SELECT INTO "NL:"
  FROM br_legacy_sr b
  ORDER BY b.service_resource
  HEAD REPORT
   stat = alterlist(reply->sr_list,20)
  DETAIL
   tot_count = (tot_count+ 1), count = (count+ 1)
   IF (count > 20)
    stat = alterlist(reply->sr_list[tot_count],(tot_count+ 20)), count = 1
   ENDIF
   reply->sr_list[tot_count].sr_display = b.service_resource, reply->sr_list[tot_count].sr_active_ind
    = b.active_ind
  FOOT REPORT
   stat = alterlist(reply->sr_list,tot_count)
  WITH nocounter
 ;end select
#enditnow
 IF (tot_count > 0)
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
