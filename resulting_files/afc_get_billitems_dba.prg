CREATE PROGRAM afc_get_billitems:dba
 RECORD reply(
   1 bill_item_qual = i4
   1 bill_item[*]
     2 bill_item_id = f8
     2 ext_description = vc
     2 ext_parent_reference_id = f8
     2 ext_parent_contributor_cd = f8
     2 ext_child_reference_id = f8
     2 ext_child_contributor_cd = f8
     2 ext_owner_cd = f8
     2 ext_short_desc = vc
     2 parent_qual_cd = f8
     2 physician_qual_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET countb = 0
 SELECT INTO "nl:"
  b.*
  FROM bill_item b
  WHERE (b.ext_owner_cd=request->ext_owner_code)
   AND b.active_ind=1
   AND b.careset_ind=null
  ORDER BY b.ext_child_reference_id DESC
  DETAIL
   countb = (countb+ 1), stat = alterlist(reply->bill_item,countb), reply->bill_item[countb].
   bill_item_id = b.bill_item_id,
   reply->bill_item[countb].ext_parent_reference_id = b.ext_parent_reference_id, reply->bill_item[
   countb].ext_child_reference_id = b.ext_child_reference_id, reply->bill_item[countb].
   ext_description = trim(b.ext_description)
  WITH nocounter
 ;end select
 SET reply->bill_item_qual = countb
 SET stat = alterlist(reply->bill_item,countb)
 IF (curqual != 0)
  SET reply->bill_item_qual = count
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.subeventstatus[1].operationname = "Select"
  SET reply->status_data.subeventstatus[1].operationstatus = "s"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "BILL_ITEM"
  SET reply->status_data.status = "Z"
 ENDIF
END GO
