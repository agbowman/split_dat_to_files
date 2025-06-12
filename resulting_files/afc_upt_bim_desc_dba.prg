CREATE PROGRAM afc_upt_bim_desc:dba
 PAINT
 SET width = 132
 SET modify = system
 CALL clear(1,1)
 CALL video(n)
 CALL video(n)
 SET message = nowindow
 EXECUTE cclseclogin
 RECORD billitemmods(
   1 bill_item_mod_qual = i2
   1 bill_item_mod[*]
     2 bill_item_mod_id = f8
     2 key7 = vc
 )
 SET ownercode = 0.0
 DECLARE bill_code = f8
 DECLARE code_set = i4
 DECLARE cdf_meaning = c12
 DECLARE cnt = i4
 SET code_set = 13019
 SET cdf_meaning = "BILL CODE"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,bill_code)
 SET help =
 SELECT INTO "nl:"
  c.code_value"#################;l", c.display
  FROM code_value c
  WHERE c.code_set=106
   AND c.active_ind=1
  ORDER BY c.display
  WITH nocounter
 ;end select
 CALL accept(5,10,"A(17);fCU;",0)
 SET ownercode = cnvtreal(curaccept)
 CALL video(n)
 SET count1 = 0
 SELECT INTO "nl:"
  bm.key7, b.ext_description
  FROM bill_item_modifier bm,
   bill_item b
  PLAN (b
   WHERE b.ext_owner_cd=ownercode
    AND b.active_ind=1)
   JOIN (bm
   WHERE bm.bill_item_id=b.bill_item_id
    AND bm.bill_item_type_cd=bill_code
    AND bm.active_ind=1)
  DETAIL
   count1 = (count1+ 1), stat = alterlist(billitemmods->bill_item_mod,count1), billitemmods->
   bill_item_mod[count1].bill_item_mod_id = bm.bill_item_mod_id,
   billitemmods->bill_item_mod[count1].key7 = b.ext_description
  WITH nocounter
 ;end select
 SET billitemmods->bill_item_mod_qual = count1
 UPDATE  FROM bill_item_modifier bm,
   (dummyt d1  WITH seq = value(billitemmods->bill_item_mod_qual))
  SET bm.key7 = billitemmods->bill_item_mod[d1.seq].key7
  PLAN (d1)
   JOIN (bm
   WHERE (bm.bill_item_mod_id=billitemmods->bill_item_mod[d1.seq].bill_item_mod_id))
  WITH nocounter
 ;end update
 CALL clear(1,1)
 CALL text(5,10,"************TYPE 'COMMIT GO' TO SAVE YOUR CHANGES***********")
END GO
