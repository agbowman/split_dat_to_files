CREATE PROGRAM bed_get_rx_dispcat:dba
 FREE SET reply
 RECORD reply(
   1 dispense_categories[*]
     2 code_value = f8
     2 display = vc
     2 description = vc
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
  FROM dispense_category d,
   code_value c
  PLAN (d
   WHERE (d.order_type_flag=request->order_type_flag))
   JOIN (c
   WHERE c.code_value=d.dispense_category_cd
    AND c.active_ind=1)
  ORDER BY c.display
  HEAD c.display
   cnt = (cnt+ 1), stat = alterlist(reply->dispense_categories,cnt), reply->dispense_categories[cnt].
   code_value = c.code_value,
   reply->dispense_categories[cnt].display = c.display, reply->dispense_categories[cnt].description
    = c.description
  WITH nocounter
 ;end select
 CALL echorecord(reply)
#exit_script
 SET reply->status_data.status = "S"
END GO
