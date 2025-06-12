CREATE PROGRAM afc_get_price_sched_interval:dba
 RECORD reply(
   1 item_interval_qual = i2
   1 interval_qual[*]
     2 item_interval_id = f8
     2 price = f8
     2 interval_template_cd = f8
     2 parent_entity_id = f8
     2 interval_id = f8
     2 beg_value = f8
     2 end_value = f8
     2 unit_type_cd = f8
     2 calc_type_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 CALL echo(concat("Template Code: ",cnvtstring(request->interval_template_cd,17,2)))
 CALL echo(concat("price_sched_item_id: ",cnvtstring(request->parent_entity_id,17,2)))
 SET code_set = 48
 SET cdf_meaning = "ACTIVE"
 SELECT INTO "nl:"
  i.interval_id, i.interval_template_cd, it.item_interval_id
  FROM item_interval_table it,
   interval_table i,
   dummyt d1
  PLAN (i
   WHERE (i.interval_template_cd=request->interval_template_cd)
    AND i.active_ind=1)
   JOIN (d1)
   JOIN (it
   WHERE (it.parent_entity_id=request->parent_entity_id)
    AND (it.interval_template_cd=request->interval_template_cd)
    AND it.interval_id=i.interval_id
    AND it.active_ind=1)
  ORDER BY i.beg_value
  DETAIL
   count1 = (count1+ 1), stat = alterlist(reply->interval_qual,count1), reply->interval_qual[count1].
   interval_id = i.interval_id,
   reply->interval_qual[count1].beg_value = i.beg_value, reply->interval_qual[count1].end_value = i
   .end_value, reply->interval_qual[count1].unit_type_cd = i.unit_type_cd,
   reply->interval_qual[count1].calc_type_cd = i.calc_type_cd, reply->interval_qual[count1].
   item_interval_id = it.item_interval_id, reply->interval_qual[count1].price = it.price,
   reply->interval_qual[count1].interval_template_cd = it.interval_template_cd, reply->interval_qual[
   count1].parent_entity_id = it.parent_entity_id
  WITH nocounter, outerjoin = d1
 ;end select
 SET reply->item_interval_qual = count1
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "Select"
  SET reply->status_data.subeventstatus[1].operationstatus = "s"
  SET reply->status_data.subeventstatus[1].targetobjectname = "Table"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "ITEM_INTERVAL_TABLE"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
