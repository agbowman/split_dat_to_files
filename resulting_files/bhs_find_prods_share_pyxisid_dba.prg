CREATE PROGRAM bhs_find_prods_share_pyxisid:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 RECORD temp(
   1 qual[*]
     2 chargen = vc
     2 itemscnt = i4
     2 items[*]
       3 itemid = f8
       3 desc = vc
 )
 SET qualcnt = 0
 SET itemscnt = 0
 SET itemsmaxcnt = 0
 SELECT DISTINCT
  m.item_id, m1.item_id
  FROM med_identifier m,
   med_identifier m1
  PLAN (m
   WHERE m.med_identifier_type_cd=3106
    AND m.active_ind=1
    AND m.med_product_id=0
    AND m.primary_ind=1)
   JOIN (m1
   WHERE m1.med_identifier_type_cd=3106
    AND m1.value_key=m.value_key
    AND m1.active_ind=1
    AND m1.item_id != m.item_id
    AND m1.med_product_id=0
    AND m1.primary_ind=1)
  ORDER BY m.value_key
  HEAD m.value_key
   qualcnt = (qualcnt+ 1), stat = alterlist(temp->qual,qualcnt), temp->qual[qualcnt].chargen = m1
   .value_key,
   itemscnt = 1, stat = alterlist(temp->qual[qualcnt].items,itemscnt), temp->qual[qualcnt].items[
   itemscnt].itemid = m.item_id
  DETAIL
   itemscnt = (itemscnt+ 1), stat = alterlist(temp->qual[qualcnt].items,itemscnt), temp->qual[qualcnt
   ].items[itemscnt].itemid = m1.item_id,
   temp->qual[qualcnt].itemscnt = itemscnt
   IF (itemscnt > itemsmaxcnt)
    itemsmaxcnt = itemscnt
   ENDIF
  WITH nocounter
 ;end select
 CALL echorecord(temp)
 SELECT DISTINCT INTO  $OUTDEV
  chargenumber = substring(0,14,temp->qual[d.seq].chargen), item_id = temp->qual[d.seq].items[d1.seq]
  .itemid, genericname = replace(m.value,char(13),"")
  FROM med_identifier m,
   (dummyt d  WITH seq = qualcnt),
   (dummyt d1  WITH seq = itemsmaxcnt)
  PLAN (d)
   JOIN (d1
   WHERE (d1.seq <= temp->qual[d.seq].itemscnt))
   JOIN (m
   WHERE (m.item_id=temp->qual[d.seq].items[d1.seq].itemid)
    AND m.med_identifier_type_cd=3098
    AND m.active_ind=1
    AND m.med_product_id=0
    AND m.primary_ind=1)
  ORDER BY chargenumber, item_id
  WITH nocounter, format
 ;end select
END GO
