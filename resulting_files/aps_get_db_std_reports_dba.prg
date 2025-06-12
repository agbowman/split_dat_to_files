CREATE PROGRAM aps_get_db_std_reports:dba
 RECORD reply(
   1 qual[10]
     2 catalog_cd = f8
     2 description = vc
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
 SET failed = "F"
 SET x = 0
 SET err_cnt = 0
 SELECT INTO "nl:"
  oc.catalog_cd, oc.description
  FROM cyto_report_control crc,
   order_catalog oc
  PLAN (crc
   WHERE crc.catalog_cd != 0.0)
   JOIN (oc
   WHERE crc.catalog_cd=oc.catalog_cd)
  HEAD REPORT
   x = 0
  DETAIL
   x = (x+ 1)
   IF (mod(x,10)=1
    AND x != 1)
    stat = alter(reply->qual,(x+ 9))
   ENDIF
   reply->qual[x].catalog_cd = oc.catalog_cd, reply->qual[x].description = oc.description
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET err_cnt = (err_cnt+ 1)
  SET reply->status_data.subeventstatus[err_cnt].operationname = "SELECT"
  SET reply->status_data.subeventstatus[err_cnt].operationstatus = "Z"
  SET reply->status_data.subeventstatus[err_cnt].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[err_cnt].targetobjectvalue = "ORDER_CATALOG"
 ELSE
  SET stat = alter(reply->qual,x)
 ENDIF
#exit_script
 IF (failed="F")
  IF (x=0)
   SET reply->status_data.status = "Z"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
END GO
