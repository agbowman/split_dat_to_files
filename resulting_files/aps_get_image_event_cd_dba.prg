CREATE PROGRAM aps_get_image_event_cd:dba
 RECORD reply(
   1 image_event_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD event(
   1 qual[1]
     2 parent_cd = f8
     2 event_cd = f8
 )
 SET reply->status_data.status = "F"
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET code_set = 0
 SET code_set = 73
 SET cdf_meaning = "APS02"
 EXECUTE cpm_get_cd_for_cdf
 SET event->qual[1].parent_cd = code_value
 EXECUTE aps_get_event_codes
 SET reply->image_event_cd = event->qual[1].event_cd
 SET reply->status_data.status = "S"
END GO
