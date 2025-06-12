CREATE PROGRAM bed_get_patcare_depts:dba
 FREE SET reply
 RECORD reply(
   1 departments[*]
     2 name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 SELECT INTO "nl:"
  FROM br_oc_work b
  PLAN (b
   WHERE  NOT (b.catalog_type IN ("LABORATORY", "RADIOLOGY", "SURGERY", "PHARMACY")))
  ORDER BY b.catalog_type
  HEAD b.catalog_type
   cnt = (cnt+ 1), stat = alterlist(reply->departments,cnt), reply->departments[cnt].name = b
   .catalog_type
  WITH nocounter
 ;end select
 CALL echorecord(reply)
#exit_script
 IF (cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
