CREATE PROGRAM act_get_therapeutic_categories:dba
 RECORD reply(
   1 qual[*]
     2 alt_sel_category_id = f8
     2 long_description = vc
     2 short_description = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE cnt = i4 WITH public, noconstant(0)
 SELECT INTO "nl:"
  FROM alt_sel_cat a
  PLAN (a
   WHERE a.ahfs_ind=1)
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(reply->qual,cnt), reply->qual[cnt].alt_sel_category_id = a
   .alt_sel_category_id,
   reply->qual[cnt].long_description = a.long_description, reply->qual[cnt].short_description = a
   .short_description
  WITH nocounter
 ;end select
 IF (cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
