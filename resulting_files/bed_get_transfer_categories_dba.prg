CREATE PROGRAM bed_get_transfer_categories:dba
 FREE SET reply
 RECORD reply(
   1 transfer_categories[*]
     2 id = f8
     2 name = vc
     2 active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET tcnt = 0
 SELECT INTO "nl:"
  FROM dcp_cf_trans_cat d
  PLAN (d
   WHERE (d.cf_transfer_type_cd=request->transfer_type_code_value))
  ORDER BY d.cf_category_name
  DETAIL
   tcnt = (tcnt+ 1), stat = alterlist(reply->transfer_categories,tcnt), reply->transfer_categories[
   tcnt].id = d.dcp_cf_trans_cat_id,
   reply->transfer_categories[tcnt].name = d.cf_category_name, reply->transfer_categories[tcnt].
   active_ind = d.active_ind
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
