CREATE PROGRAM bed_get_of_category:dba
 FREE SET reply
 RECORD reply(
   1 category_id = f8
   1 category_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET failed = "N"
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM alt_sel_cat c
  PLAN (c
   WHERE c.long_description="INPTCATEGORY")
  DETAIL
   reply->category_id = c.alt_sel_category_id, reply->category_name = c.short_description
  WITH nocounter
 ;end select
 IF (ierrcode > 0)
  SET failed = "Y"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="Y")
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
