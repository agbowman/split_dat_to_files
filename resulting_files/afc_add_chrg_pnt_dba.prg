CREATE PROGRAM afc_add_chrg_pnt:dba
 RECORD requestfromvb(
   1 ext_owner_cd = f8
   1 bill_item_type_cd = f8
   1 key1_id = f8
   1 key2_id = f8
   1 key3_id = f8
   1 key4_id = f8
   1 level_ind = i2
 )
 SET requestfromvb->ext_owner_cd = request->ext_owner_cd
 SET requestfromvb->bill_item_type_cd = request->bill_item_type_cd
 SET requestfromvb->key1_id = request->key1_id
 SET requestfromvb->key2_id = request->key2_id
 SET requestfromvb->key3_id = request->key3_id
 SET requestfromvb->key4_id = request->key4_id
 SET requestfromvb->level_ind = request->level_ind
 RECORD tempbillitems(
   1 bill_item_qual = i4
   1 qual[*]
     2 bill_item_id = f8
     2 updt_ind = i2
 )
 RECORD ensbimrequest(
   1 bill_item_modifier_qual = i2
   1 bill_item_modifier[*]
     2 action_type = c3
     2 bill_item_mod_id = f8
     2 bill_item_id = f8
     2 bill_item_type_cd = f8
     2 key1_id = f8
     2 key2_id = f8
     2 key3_id = f8
     2 key4_id = f8
     2 key5_id = f8
     2 key6 = vc
     2 key7 = vc
     2 key8 = vc
     2 key9 = vc
     2 key10 = vc
     2 key11 = vc
     2 key12 = vc
     2 key13 = vc
     2 key14 = vc
     2 key15 = vc
     2 key11_id = f8
     2 key12_id = f8
     2 key13_id = f8
     2 key14_id = f8
     2 key15_id = f8
     2 bim1_int = f8
     2 bim2_int = f8
     2 bim_ind = i2
     2 bim1_ind = i2
     2 bim1_nbr = f8
     2 active_ind_ind = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 updt_cnt = i2
 )
 SET countt = 0
 SELECT
  IF ((requestfromvb->level_ind=1))INTO "nl:"
   b.*
   FROM bill_item b
   WHERE (b.ext_owner_cd=requestfromvb->ext_owner_cd)
    AND b.ext_parent_reference_id != 0
    AND b.active_ind=1
  ELSEIF ((requestfromvb->level_ind=2))INTO "nl:"
   b.*
   FROM bill_item b
   WHERE (b.ext_owner_cd=requestfromvb->ext_owner_cd)
    AND b.ext_child_reference_id=0
    AND b.active_ind=1
  ELSEIF ((requestfromvb->level_ind=3))INTO "nl:"
   b.*
   FROM bill_item b
   WHERE (b.ext_owner_cd=requestfromvb->ext_owner_cd)
    AND b.ext_parent_reference_id != 0
    AND b.ext_child_reference_id != 0
    AND b.active_ind=1
  ELSEIF ((requestfromvb->level_ind=4))INTO "nl:"
   b.*
   FROM bill_item b
   WHERE (b.ext_owner_cd=requestfromvb->ext_owner_cd)
    AND b.ext_parent_reference_id=0
    AND b.ext_parent_contributor_cd=0
    AND b.active_ind=1
  ELSE
  ENDIF
  DETAIL
   countt = (countt+ 1), stat = alterlist(tempbillitems->qual,countt), tempbillitems->qual[countt].
   bill_item_id = b.bill_item_id
  WITH nocounter
 ;end select
 SET tempbillitems->bill_item_qual = countt
 CALL echo(build("Qual is: ",tempbillitems->bill_item_qual))
 SELECT INTO "nl:"
  bim.*
  FROM (dummyt d1  WITH seq = value(tempbillitems->bill_item_qual)),
   bill_item_modifier bim
  PLAN (d1)
   JOIN (bim
   WHERE bim.active_ind=1
    AND (bim.key1_id=requestfromvb->key1_id)
    AND (bim.bill_item_id=tempbillitems->qual[d1.seq].bill_item_id))
  DETAIL
   tempbillitems->qual[d1.seq].updt_ind = 1
  WITH nocounter
 ;end select
 SET count = 0
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(tempbillitems->bill_item_qual))
  WHERE (tempbillitems->qual[d1.seq].updt_ind=0)
  ORDER BY tempbillitems->qual[d1.seq].bill_item_id
  DETAIL
   count = (count+ 1), stat = alterlist(ensbimrequest->bill_item_modifier,count), ensbimrequest->
   bill_item_modifier[count].action_type = "ADD",
   ensbimrequest->bill_item_modifier[count].bill_item_id = tempbillitems->qual[d1.seq].bill_item_id,
   ensbimrequest->bill_item_modifier[count].bill_item_type_cd = requestfromvb->bill_item_type_cd,
   ensbimrequest->bill_item_modifier[count].key1_id = requestfromvb->key1_id,
   ensbimrequest->bill_item_modifier[count].key2_id = requestfromvb->key2_id, ensbimrequest->
   bill_item_modifier[count].key3_id = requestfromvb->key3_id, ensbimrequest->bill_item_modifier[
   count].key4_id = requestfromvb->key4_id,
   ensbimrequest->bill_item_modifier[count].active_ind_ind = 1, ensbimrequest->bill_item_modifier[
   count].active_ind = 1, ensbimrequest->bill_item_modifier[count].beg_effective_dt_tm = cnvtdatetime
   (curdate,curtime3),
   ensbimrequest->bill_item_modifier[count].end_effective_dt_tm = cnvtdatetime(
    "31-DEC-2100 23:59:59:59")
  WITH nocounter
 ;end select
 SET ensbimrequest->bill_item_modifier_qual = count
 EXECUTE afc_add_bill_item_modifier  WITH replace(request,ensbimrequest)
 FREE SET requestfromvb
 FREE SET tempbillitems
END GO
