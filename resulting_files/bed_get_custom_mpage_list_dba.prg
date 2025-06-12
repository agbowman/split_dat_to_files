CREATE PROGRAM bed_get_custom_mpage_list:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 views[*]
      2 id = f8
      2 display = vc
      2 identifier = vc
      2 layout_flag = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE error_flag = vc
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET vcnt = 0
 SELECT INTO "nl:"
  FROM br_datamart_category c
  WHERE c.category_mean="VB_*"
   AND c.category_type_flag=1
  ORDER BY c.category_name
  DETAIL
   vcnt = (vcnt+ 1), stat = alterlist(reply->views,vcnt), reply->views[vcnt].id = c
   .br_datamart_category_id,
   reply->views[vcnt].display = c.category_name, reply->views[vcnt].identifier = c.category_mean,
   reply->views[vcnt].layout_flag = c.layout_flag
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
