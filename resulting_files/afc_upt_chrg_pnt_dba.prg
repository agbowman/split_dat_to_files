CREATE PROGRAM afc_upt_chrg_pnt:dba
 RECORD requestfromvb(
   1 owner_ind = i2
   1 ext_owner_cd = f8
   1 bill_item_id = f8
   1 bill_item_type_cd = f8
   1 key1_id = f8
   1 key2_id = f8
   1 key3_id = f8
   1 key4_id = f8
   1 level_ind = i2
 )
 SET requestfromvb->owner_ind = request->owner_ind
 SET requestfromvb->ext_owner_cd = request->ext_owner_cd
 SET requestfromvb->bill_item_id = request->bill_item_id
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
     2 ext_owner_cd = f8
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
 SET count = 0
 IF ((requestfromvb->owner_ind=1))
  SELECT
   IF ((requestfromvb->level_ind=1))INTO "nl:"
    bim.*
    FROM bill_item_modifier bim
    WHERE (bim.bill_item_type_cd=requestfromvb->bill_item_type_cd)
     AND (bim.key1_id=requestfromvb->key1_id)
     AND bim.active_ind=1
     AND bim.bill_item_id IN (
    (SELECT
     bill_item_id
     FROM bill_item
     WHERE (ext_owner_cd=requestfromvb->ext_owner_cd)
      AND ext_parent_reference_id != 0
      AND active_ind=1))
   ELSEIF ((requestfromvb->level_ind=2))INTO "nl:"
    bim.*
    FROM bill_item_modifier bim
    WHERE (bim.bill_item_type_cd=requestfromvb->bill_item_type_cd)
     AND (bim.key1_id=requestfromvb->key1_id)
     AND bim.active_ind=1
     AND bim.bill_item_id IN (
    (SELECT
     bill_item_id
     FROM bill_item
     WHERE (ext_owner_cd=requestfromvb->ext_owner_cd)
      AND ext_child_reference_id=0
      AND active_ind=1))
   ELSEIF ((requestfromvb->level_ind=3))INTO "nl:"
    bim.*
    FROM bill_item_modifier bim
    WHERE (bim.bill_item_type_cd=requestfromvb->bill_item_type_cd)
     AND (bim.key1_id=requestfromvb->key1_id)
     AND bim.active_ind=1
     AND bim.bill_item_id IN (
    (SELECT
     bill_item_id
     FROM bill_item
     WHERE (ext_owner_cd=requestfromvb->ext_owner_cd)
      AND ext_parent_reference_id != 0
      AND ext_child_reference_id != 0
      AND active_ind=1))
   ELSEIF ((requestfromvb->level_ind=4))INTO "nl:"
    bim.*
    FROM bill_item_modifier bim
    WHERE (bim.bill_item_type_cd=requestfromvb->bill_item_type_cd)
     AND (bim.key1_id=requestfromvb->key1_id)
     AND bim.active_ind=1
     AND bim.bill_item_id IN (
    (SELECT
     bill_item_id
     FROM bill_item
     WHERE (ext_owner_cd=requestfromvb->ext_owner_cd)
      AND ext_parent_contributor_cd=0
      AND ext_parent_reference_id=0
      AND active_ind=1))
   ELSE
   ENDIF
   DETAIL
    count = (count+ 1), stat = alterlist(ensbimrequest->bill_item_modifier,count), ensbimrequest->
    bill_item_modifier[count].action_type = "UPT",
    ensbimrequest->bill_item_modifier[count].bill_item_mod_id = bim.bill_item_mod_id, ensbimrequest->
    bill_item_modifier[count].bill_item_id = bim.bill_item_id, ensbimrequest->bill_item_modifier[
    count].bill_item_type_cd = bim.bill_item_type_cd,
    ensbimrequest->bill_item_modifier[count].key1_id = bim.key1_id, ensbimrequest->
    bill_item_modifier[count].key2_id = requestfromvb->key2_id, ensbimrequest->bill_item_modifier[
    count].key3_id = requestfromvb->key3_id,
    ensbimrequest->bill_item_modifier[count].key4_id = requestfromvb->key4_id, ensbimrequest->
    bill_item_modifier[count].key5_id = bim.key5_id, ensbimrequest->bill_item_modifier[count].key6 =
    bim.key6,
    ensbimrequest->bill_item_modifier[count].key7 = bim.key7, ensbimrequest->bill_item_modifier[count
    ].key8 = bim.key8, ensbimrequest->bill_item_modifier[count].key9 = bim.key9,
    ensbimrequest->bill_item_modifier[count].key10 = bim.key10, ensbimrequest->bill_item_modifier[
    count].key11 = bim.key11, ensbimrequest->bill_item_modifier[count].key12 = bim.key12,
    ensbimrequest->bill_item_modifier[count].key13 = bim.key13, ensbimrequest->bill_item_modifier[
    count].key14 = bim.key14, ensbimrequest->bill_item_modifier[count].key15 = bim.key15,
    ensbimrequest->bill_item_modifier[count].active_ind_ind = 1, ensbimrequest->bill_item_modifier[
    count].active_ind = bim.active_ind, ensbimrequest->bill_item_modifier[count].active_status_cd =
    bim.active_status_cd,
    ensbimrequest->bill_item_modifier[count].active_status_dt_tm = bim.active_status_dt_tm,
    ensbimrequest->bill_item_modifier[count].active_status_prsnl_id = bim.active_status_prsnl_id,
    ensbimrequest->bill_item_modifier[count].beg_effective_dt_tm = bim.beg_effective_dt_tm,
    ensbimrequest->bill_item_modifier[count].end_effective_dt_tm = bim.end_effective_dt_tm
   WITH nocounter
  ;end select
  SET ensbimrequest->bill_item_modifier_qual = count
 ELSEIF ((requestfromvb->owner_ind=0))
  SELECT INTO "nl:"
   bim.*
   FROM bill_item_modifier bim
   WHERE (bim.bill_item_id=requestfromvb->bill_item_id)
    AND (bim.bill_item_type_cd=requestfromvb->bill_item_type_cd)
    AND (bim.key1_id=requestfromvb->key1_id)
    AND bim.active_ind=1
   DETAIL
    count = (count+ 1), stat = alterlist(ensbimrequest->bill_item_modifier,count), ensbimrequest->
    bill_item_modifier[count].action_type = "UPT",
    ensbimrequest->bill_item_modifier[count].bill_item_mod_id = bim.bill_item_mod_id, ensbimrequest->
    bill_item_modifier[count].bill_item_id = bim.bill_item_id, ensbimrequest->bill_item_modifier[
    count].bill_item_type_cd = bim.bill_item_type_cd,
    ensbimrequest->bill_item_modifier[count].key1_id = bim.key1_id, ensbimrequest->
    bill_item_modifier[count].key2_id = requestfromvb->key2_id, ensbimrequest->bill_item_modifier[
    count].key3_id = requestfromvb->key3_id,
    ensbimrequest->bill_item_modifier[count].key4_id = requestfromvb->key4_id, ensbimrequest->
    bill_item_modifier[count].key5_id = bim.key5_id, ensbimrequest->bill_item_modifier[count].key6 =
    bim.key6,
    ensbimrequest->bill_item_modifier[count].key7 = bim.key7, ensbimrequest->bill_item_modifier[count
    ].key8 = bim.key8, ensbimrequest->bill_item_modifier[count].key9 = bim.key9,
    ensbimrequest->bill_item_modifier[count].key10 = bim.key10, ensbimrequest->bill_item_modifier[
    count].key11 = bim.key11, ensbimrequest->bill_item_modifier[count].key12 = bim.key12,
    ensbimrequest->bill_item_modifier[count].key13 = bim.key13, ensbimrequest->bill_item_modifier[
    count].key14 = bim.key14, ensbimrequest->bill_item_modifier[count].key15 = bim.key15,
    ensbimrequest->bill_item_modifier[count].active_ind_ind = 1, ensbimrequest->bill_item_modifier[
    count].active_ind = bim.active_ind, ensbimrequest->bill_item_modifier[count].active_status_cd =
    bim.active_status_cd,
    ensbimrequest->bill_item_modifier[count].active_status_dt_tm = bim.active_status_dt_tm,
    ensbimrequest->bill_item_modifier[count].active_status_prsnl_id = bim.active_status_prsnl_id,
    ensbimrequest->bill_item_modifier[count].beg_effective_dt_tm = bim.beg_effective_dt_tm,
    ensbimrequest->bill_item_modifier[count].end_effective_dt_tm = bim.end_effective_dt_tm
   WITH nocounter
  ;end select
  SET ensbimrequest->bill_item_modifier_qual = count
  IF ((ensbimrequest->bill_item_modifier_qual=0))
   SET count = (count+ 1)
   SET stat = alterlist(ensbimrequest->bill_item_modifier,count)
   SET ensbimrequest->bill_item_modifier[count].action_type = "ADD"
   SET ensbimrequest->bill_item_modifier[count].bill_item_id = requestfromvb->bill_item_id
   SET ensbimrequest->bill_item_modifier[count].bill_item_type_cd = requestfromvb->bill_item_type_cd
   SET ensbimrequest->bill_item_modifier[count].key1_id = requestfromvb->key1_id
   SET ensbimrequest->bill_item_modifier[count].key2_id = requestfromvb->key2_id
   SET ensbimrequest->bill_item_modifier[count].key3_id = requestfromvb->key3_id
   SET ensbimrequest->bill_item_modifier[count].key4_id = requestfromvb->key4_id
   SET ensbimrequest->bill_item_modifier[count].active_ind_ind = 1
   SET ensbimrequest->bill_item_modifier[count].active_ind = 1
   SET ensbimrequest->bill_item_modifier[count].beg_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensbimrequest->bill_item_modifier[count].end_effective_dt_tm = cnvtdatetime(
    "31-DEC-2100 23:59:59:59")
  ENDIF
  SET ensbimrequest->bill_item_modifier_qual = count
 ENDIF
 FOR (x = 1 TO size(ensbimrequest->bill_item_modifier_qual,5))
   SET action_begin = x
   SET action_end = x
   CASE (ensbimrequest->bill_item_modifier[x].action_type)
    OF "ADD":
     EXECUTE afc_add_bill_item_modifier  WITH replace(request,ensbimrequest)
    OF "UPT":
     EXECUTE afc_upt_bill_item_modifier  WITH replace(request,ensbimrequest)
    ELSE
     CALL echo("Unknown action_type: ",0)
     CALL echo(enspsirequest->price_sched_items[x].action_type)
   ENDCASE
 ENDFOR
 FREE SET requestfromvb
 FREE SET tempbillitems
END GO
