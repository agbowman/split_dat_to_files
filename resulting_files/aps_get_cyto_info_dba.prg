CREATE PROGRAM aps_get_cyto_info:dba
 RECORD reply(
   1 cyto_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  crc.catalog_cd
  FROM cyto_report_control crc,
   prefix_report_r prr
  PLAN (prr
   WHERE (request->catalog_cd=prr.catalog_cd)
    AND (request->prefix_id=prr.prefix_id))
   JOIN (crc
   WHERE (request->catalog_cd=crc.catalog_cd)
    AND prr.primary_ind=1)
  HEAD REPORT
   IF (crc.catalog_cd > 0)
    reply->cyto_ind = 1
   ELSE
    reply->cyto_ind = 0
   ENDIF
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  GO TO end_report
 ENDIF
#end_report
END GO
