CREATE PROGRAM afc_get_bill_item_for_synonym:dba
 SET afc_get_bill_item_for_synonym_vrsn = "127817.000"
 RECORD reply(
   1 batch_charge_entry_seq = f8
   1 ref_cont_cd_inquiry = f8
   1 bill_item_qual = i2
   1 bill_items[*]
     2 bill_item_id = f8
     2 ext_description = vc
     2 display_flag = i2
     2 ext_short_desc = vc
     2 ext_parent_reference_id = f8
     2 ext_parent_contributor_cd = f8
     2 ext_child_reference_id = f8
     2 ext_child_contributor_cd = f8
     2 ext_owner_cd = f8
     2 misc_ind = i2
 )
 DECLARE 26078_bill_item = f8
 SET stat = uar_get_meaning_by_codeset(26078,"BILL_ITEM",1,26078_bill_item)
 SET stat = uar_get_meaning_by_codeset(13016,"INQUIRY",1,reply->ref_cont_cd_inquiry)
 DECLARE searchstring = vc WITH protect, constant(concat(cnvtupper(trim(request->mnemonic)),"*"))
 SET count1 = 0
 SELECT DISTINCT INTO "nl:"
  FROM order_catalog_synonym o,
   bill_item b
  PLAN (o
   WHERE o.mnemonic_key_cap=patstring(searchstring)
    AND o.active_ind=1)
   JOIN (b
   WHERE b.ext_parent_reference_id=o.catalog_cd
    AND b.ext_child_reference_id=0
    AND b.active_ind=1)
  DETAIL
   count1 = (count1+ 1), stat = alterlist(reply->bill_items,count1), reply->bill_items[count1].
   bill_item_id = b.bill_item_id,
   reply->bill_items[count1].ext_description = b.ext_description, reply->bill_items[count1].
   ext_short_desc = b.ext_short_desc, reply->bill_items[count1].ext_parent_reference_id = b
   .ext_parent_reference_id,
   reply->bill_items[count1].ext_parent_contributor_cd = b.ext_parent_contributor_cd, reply->
   bill_items[count1].ext_child_reference_id = b.ext_child_reference_id, reply->bill_items[count1].
   ext_child_contributor_cd = b.ext_child_contributor_cd,
   reply->bill_items[count1].ext_owner_cd = b.ext_owner_cd, reply->bill_items[count1].misc_ind = b
   .misc_ind
  WITH nocounter
 ;end select
 SET reply->bill_item_qual = count1
 CALL echo(build("reply->bill_item_qual: ",count1))
 SET ibisec = 0
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="CHARGE SERVICES"
   AND di.info_name="BILL ITEM SECURITY"
   AND di.info_char="Y"
  DETAIL
   CALL echo("Bill Item Security = 1"), ibisec = 1
  WITH nocounter
 ;end select
 IF (ibisec=1
  AND (reply->bill_item_qual > 0))
  CALL echo("security is on")
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(reply->bill_item_qual)),
    prsnl_org_reltn por,
    cs_org_reltn cor
   PLAN (d1)
    JOIN (por
    WHERE (por.person_id=reqinfo->updt_id)
     AND por.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND por.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     AND por.active_ind=1)
    JOIN (cor
    WHERE cor.organization_id=por.organization_id
     AND cor.cs_org_reltn_type_cd=26078_bill_item
     AND cor.key1_entity_name="BILL_ITEM"
     AND (cor.key1_id=reply->bill_items[d1.seq].bill_item_id)
     AND cor.active_ind=1)
   DETAIL
    reply->bill_items[count1].display_flag = 1
   WITH nocounter
  ;end select
 ELSEIF ((reply->bill_item_qual > 0))
  CALL echo("security is off")
  FOR (count1 = 1 TO reply->bill_item_qual)
    SET reply->bill_items[count1].display_flag = 1
  ENDFOR
 ENDIF
 IF ((reply->bill_item_qual > 0))
  SELECT INTO "nl:"
   y = seq(batch_charge_entry_seq,nextval)"##################;rp0"
   FROM dual
   DETAIL
    reply->batch_charge_entry_seq = cnvtreal(y)
   WITH format, counter
  ;end select
 ENDIF
 CALL echorecord(reply)
END GO
