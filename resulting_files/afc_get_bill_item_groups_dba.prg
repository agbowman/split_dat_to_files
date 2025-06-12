CREATE PROGRAM afc_get_bill_item_groups:dba
 RECORD reply(
   1 bill_item_groups_qual = i2
   1 bill_item_groups[*]
     2 bill_item_groups_id = f8
     2 bill_item_id = f8
     2 ext_description = vc
     2 group_name = vc
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET count1 = 0
 SET stat = alterlist(reply->bill_item_groups,count1)
 SELECT INTO "nl:"
  b.*
  FROM bill_item_groups b
  WHERE b.active_ind=1
  DETAIL
   count1 = (count1+ 1), stat = alterlist(reply->bill_item_groups,count1), reply->bill_item_groups[
   count1].bill_item_groups_id = b.bill_item_groups_id,
   reply->bill_item_groups[count1].bill_item_id = b.bill_item_id, reply->bill_item_groups[count1].
   ext_description = b.ext_description, reply->bill_item_groups[count1].group_name = b.group_name,
   reply->bill_item_groups[count1].beg_effective_dt_tm = b.beg_effective_dt_tm, reply->
   bill_item_groups[count1].end_effective_dt_tm = b.end_effective_dt_tm
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->bill_item_groups,count1)
 SET reply->bill_item_groups_qual = count1
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "Select"
  SET reply->status_data.subeventstatus[1].operationstatus = "s"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "BILL_ITEM_GROUPS"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
