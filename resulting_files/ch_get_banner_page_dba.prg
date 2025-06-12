CREATE PROGRAM ch_get_banner_page:dba
 RECORD reply(
   1 banner_page = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  c.banner_page
  FROM chart_distribution c
  WHERE (c.distribution_id=request->distribution_id)
  DETAIL
   reply->banner_page = c.banner_page
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
