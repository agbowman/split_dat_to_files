CREATE PROGRAM afc_get_bill_items_for_org:dba
 DECLARE afc_get_bill_items_for_org_ver = vc
 SET afc_get_bill_items_for_org_ver = "001"
 RECORD reply(
   1 bill_item_qual = i2
   1 bill_item[*]
     2 cs_org_reltn_id = f8
     2 bill_item_id = f8
     2 ext_parent_reference_id = f8
     2 ext_parent_contributor_cd = f8
     2 ext_description = vc
     2 ext_owner_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 DECLARE code_set = i4
 DECLARE cdf_meaning = c12
 DECLARE billitem = f8
 SET code_set = 26078
 SET cdf_meaning = "BILL_ITEM"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,billitem)
 CALL echo(billitem)
 CALL echo(request->org_id)
 SET count1 = 1
 SELECT INTO "nl:"
  b.bill_item_id
  FROM cs_org_reltn cor,
   bill_item b
  PLAN (cor
   WHERE (cor.organization_id=request->org_id)
    AND cor.cs_org_reltn_type_cd=billitem
    AND cor.active_ind=1)
   JOIN (b
   WHERE b.bill_item_id=cor.key1_id
    AND b.active_ind=1)
  ORDER BY b.ext_description DESC
  DETAIL
   reply->bill_item_qual = count1, stat = alterlist(reply->bill_item,count1), reply->bill_item[count1
   ].cs_org_reltn_id = cor.cs_org_reltn_id,
   reply->bill_item[count1].bill_item_id = b.bill_item_id, reply->bill_item[count1].
   ext_parent_reference_id = b.ext_parent_reference_id, reply->bill_item[count1].
   ext_parent_contributor_cd = b.ext_parent_contributor_cd,
   reply->bill_item[count1].ext_description = b.ext_description, reply->bill_item[count1].
   ext_owner_cd = b.ext_owner_cd, count1 = (count1+ 1)
  WITH nocounter
 ;end select
 CALL echorecord(reply)
END GO
