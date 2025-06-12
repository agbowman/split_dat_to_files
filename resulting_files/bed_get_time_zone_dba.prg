CREATE PROGRAM bed_get_time_zone:dba
 FREE SET reply
 RECORD reply(
   1 tzlist[*]
     2 tz_id = f8
     2 description = c100
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET tot_count = 0
 SET count = 0
 SET stat = alterlist(reply->tzlist,50)
 SET region = fillstring(100," ")
 SELECT INTO "NL:"
  FROM br_client b
  DETAIL
   region = b.region
  WITH nocounter
 ;end select
 IF (region="    *")
  SET region = "USA"
 ENDIF
 SELECT INTO "NL:"
  FROM br_time_zone b
  WHERE b.active_ind=1
   AND b.region=region
  ORDER BY b.sequence
  DETAIL
   tot_count = (tot_count+ 1), count = (count+ 1)
   IF (count > 50)
    stat = alterlist(reply->tzlist,(tot_count+ 50)), count = 1
   ENDIF
   reply->tzlist[tot_count].description = b.description, reply->tzlist[tot_count].tz_id = b
   .time_zone_id
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->tzlist,tot_count)
 IF (tot_count=0)
  SET reply->status_data.status = "Z"
 ENDIF
 IF (tot_count > 0)
  SET reply->status_data.status = "S"
 ENDIF
 GO TO exit_script
#exit_script
END GO
