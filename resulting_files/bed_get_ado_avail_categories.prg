CREATE PROGRAM bed_get_ado_avail_categories
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 category[*]
      2 category_id = f8
      2 category_name = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 SET cnt = 0
 SELECT INTO "nl:"
  FROM br_ado_category c
  PLAN (c
   WHERE c.br_ado_category_id > 0)
  ORDER BY c.category_name_key
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(reply->category,cnt), reply->category[cnt].category_id = c
   .br_ado_category_id,
   reply->category[cnt].category_name = c.category_name
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
