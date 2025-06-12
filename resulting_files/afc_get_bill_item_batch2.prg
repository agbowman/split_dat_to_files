CREATE PROGRAM afc_get_bill_item_batch2
 SELECT
  IF ((request->item_type="P"))
   WHERE b.ext_parent_reference_id != 0
    AND b.ext_child_reference_id=0
    AND  $1
    AND b.active_ind=1
  ELSEIF ((request->item_type="A"))
   WHERE b.ext_parent_reference_id != 0
    AND b.ext_child_reference_id=0
    AND ((b.ext_owner_cd != add_on_owner_code) OR (b.ext_owner_cd=0))
    AND b.active_ind=1
  ELSEIF ((request->item_type="C"))
   WHERE  $2
    AND  $5
    AND b.ext_child_reference_id != 0
    AND b.active_ind=1
  ELSEIF ((request->item_type="S"))
   WHERE  $2
    AND b.ext_child_reference_id=0
    AND b.active_ind=1
  ELSEIF ((request->item_type="D"))
   WHERE b.ext_parent_reference_id=0
    AND b.ext_child_reference_id != 0
    AND b.active_ind=1
  ELSEIF ((request->item_type="O"))
   WHERE  $3
    AND b.ext_parent_reference_id=0
    AND b.active_ind=1
  ELSE
  ENDIF
  INTO "nl:"
  b.ext_owner_cd, b.bill_item_id, b.ext_parent_reference_id,
  b.ext_parent_contributor_cd, b.ext_child_reference_id, b.ext_child_contributor_cd,
  b.ext_description
  FROM bill_item b
  DETAIL
   count1 = (count1+ 1), stat = alterlist(reply->bill_item,count1), reply->bill_item[count1].
   bill_item_id = b.bill_item_id,
   reply->bill_item[count1].ext_parent_reference_id = b.ext_parent_reference_id, reply->bill_item[
   count1].ext_parent_contributor_cd = b.ext_parent_contributor_cd, reply->bill_item[count1].
   ext_child_reference_id = b.ext_child_reference_id,
   reply->bill_item[count1].ext_child_contributor_cd = b.ext_child_contributor_cd
   IF (trim(b.ext_description)=" ")
    reply->bill_item[count1].ext_description = "BLANK"
   ELSE
    reply->bill_item[count1].ext_description = trim(b.ext_description)
   ENDIF
   reply->bill_item[count1].ext_owner_cd = b.ext_owner_cd, reply->bill_item[count1].careset_ind = b
   .careset_ind
  WITH nocounter
 ;end select
 SET reply->bill_item_qual = count1
 IF (curqual != 0)
  SET curqual1 = curqual
 ELSE
  GO TO endprogram
 ENDIF
 SET count1 = 0
 SELECT
  IF ((request->item_type="P"))
   PLAN (b
    WHERE b.ext_parent_reference_id != 0
     AND b.ext_child_reference_id=0
     AND  $1)
    JOIN (bm
    WHERE bm.bill_item_id=b.bill_item_id
     AND bm.active_ind=1
     AND bm.end_effective_dt_tm >= cnvtdatetime(request->current_effective_dt_tm))
  ELSEIF ((request->item_type="A"))
   PLAN (b
    WHERE b.ext_parent_reference_id != 0
     AND b.ext_child_reference_id=0
     AND ((b.ext_owner_cd != add_on_owner_code) OR (b.ext_owner_cd=0)) )
    JOIN (bm
    WHERE bm.bill_item_id=b.bill_item_id
     AND bm.active_ind=1
     AND bm.end_effective_dt_tm >= cnvtdatetime(request->current_effective_dt_tm))
  ELSEIF ((request->item_type="C"))
   PLAN (b
    WHERE  $2
     AND  $5
     AND b.ext_child_reference_id != 0
     AND b.active_ind=1)
    JOIN (bm
    WHERE bm.bill_item_id=b.bill_item_id
     AND bm.active_ind=1
     AND bm.end_effective_dt_tm >= cnvtdatetime(request->current_effective_dt_tm))
  ELSEIF ((request->item_type="S"))
   PLAN (b
    WHERE  $2
     AND b.ext_child_reference_id=0
     AND b.active_ind=1)
    JOIN (bm
    WHERE bm.bill_item_id=b.bill_item_id
     AND bm.active_ind=1
     AND bm.end_effective_dt_tm >= cnvtdatetime(request->current_effective_dt_tm))
  ELSEIF ((request->item_type="D"))
   PLAN (b
    WHERE b.ext_parent_reference_id=0
     AND b.ext_child_reference_id != 0
     AND b.active_ind=1)
    JOIN (bm
    WHERE bm.bill_item_id=b.bill_item_id
     AND bm.active_ind=1
     AND bm.end_effective_dt_tm >= cnvtdatetime(request->current_effective_dt_tm))
  ELSEIF ((request->item_type="O"))
   PLAN (b
    WHERE  $3
     AND b.ext_parent_reference_id=0
     AND b.active_ind=1)
    JOIN (bm
    WHERE bm.bill_item_id=b.bill_item_id
     AND bm.active_ind=1
     AND bm.end_effective_dt_tm >= cnvtdatetime(request->current_effective_dt_tm))
  ELSE
  ENDIF
  INTO "nl:"
  bm.*, b.*
  FROM bill_item_modifier bm,
   bill_item b
  DETAIL
   count1 = (count1+ 1), stat = alterlist(reply->bill_item_mod,count1), reply->bill_item_mod[count1].
   bill_item_id = bm.bill_item_id,
   reply->bill_item_mod[count1].bill_item_type_cd = bm.bill_item_type_cd
   IF (bm.bill_item_type_cd=charge_point_schedule)
    reply->bill_item_mod[count1].bill_item_mod_id = bm.bill_item_mod_id, reply->bill_item_mod[count1]
    .sched = bm.key1_id, reply->bill_item_mod[count1].charge_point = bm.key2_id,
    reply->bill_item_mod[count1].key3_id = bm.key3_id, reply->bill_item_mod[count1].charge_level_cd
     = bm.key4_id
   ELSEIF (bm.bill_item_type_cd=bill_code_schedule)
    reply->bill_item_mod[count1].bill_item_mod_id = bm.bill_item_mod_id, reply->bill_item_mod[count1]
    .bill_code_type_cd = cnvtreal(bm.key1_id), reply->bill_item_mod[count1].bill_code = bm.key6,
    reply->bill_item_mod[count1].priority = bm.key2_id, reply->bill_item_mod[count1].description = bm
    .key7
   ENDIF
   IF (cnvtdatetime(bm.beg_effective_dt_tm) <= cnvtdatetime(request->current_effective_dt_tm)
    AND cnvtdatetime(bm.end_effective_dt_tm) >= cnvtdatetime(request->current_effective_dt_tm))
    reply->bill_item_mod[count1].current_ind = 1
   ENDIF
   reply->bill_item_mod[count1].key5_id = bm.key5_id, reply->bill_item_mod[count1].key8 = bm.key8,
   reply->bill_item_mod[count1].key9 = bm.key9,
   reply->bill_item_mod[count1].key10 = bm.key10, reply->bill_item_mod[count1].active_ind = bm
   .active_ind, reply->bill_item_mod[count1].active_status_cd = bm.active_status_cd,
   reply->bill_item_mod[count1].active_status_dt_tm = bm.active_status_dt_tm, reply->bill_item_mod[
   count1].active_status_prsnl_id = bm.active_status_prsnl_id, reply->bill_item_mod[count1].updt_cnt
    = bm.updt_cnt,
   reply->bill_item_mod[count1].beg_effective_dt_tm = cnvtdatetime(bm.beg_effective_dt_tm), reply->
   bill_item_mod[count1].end_effective_dt_tm = cnvtdatetime(bm.end_effective_dt_tm)
  WITH nocounter
 ;end select
 SET reply->bill_item_mod_qual = count1
 IF ((request->price_sched_count >= 1))
  SET count1 = 0
  SELECT
   IF ((request->item_type="P"))
    PLAN (b
     WHERE b.ext_parent_reference_id != 0
      AND b.ext_child_reference_id=0
      AND  $1)
     JOIN (p1
     WHERE p1.bill_item_id=b.bill_item_id
      AND  $4
      AND p1.active_ind=1
      AND p1.end_effective_dt_tm >= cnvtdatetime(request->current_effective_dt_tm))
     JOIN (p2
     WHERE p2.price_sched_id=p1.price_sched_id
      AND p2.active_ind=1
      AND p2.end_effective_dt_tm >= cnvtdatetime(request->current_effective_dt_tm))
   ELSEIF ((request->item_type="A"))
    PLAN (b
     WHERE b.ext_parent_reference_id != 0
      AND b.ext_child_reference_id=0
      AND ((b.ext_owner_cd != add_on_owner_code) OR (b.ext_owner_cd=0)) )
     JOIN (p1
     WHERE p1.bill_item_id=b.bill_item_id
      AND  $4
      AND p1.active_ind=1
      AND p1.end_effective_dt_tm >= cnvtdatetime(request->current_effective_dt_tm))
     JOIN (p2
     WHERE p2.price_sched_id=p1.price_sched_id
      AND p2.active_ind=1
      AND p2.end_effective_dt_tm >= cnvtdatetime(request->current_effective_dt_tm))
   ELSEIF ((request->item_type="C"))
    PLAN (b
     WHERE  $2
      AND  $5
      AND b.ext_child_reference_id != 0
      AND b.active_ind=1)
     JOIN (p1
     WHERE p1.bill_item_id=b.bill_item_id
      AND  $4
      AND p1.active_ind=1
      AND p1.end_effective_dt_tm >= cnvtdatetime(request->current_effective_dt_tm))
     JOIN (p2
     WHERE p2.price_sched_id=p1.price_sched_id
      AND p2.active_ind=1
      AND p2.end_effective_dt_tm >= cnvtdatetime(request->current_effective_dt_tm))
   ELSEIF ((request->item_type="S"))
    PLAN (b
     WHERE  $2
      AND b.ext_child_reference_id=0
      AND b.active_ind=1)
     JOIN (p1
     WHERE p1.bill_item_id=b.bill_item_id
      AND  $4
      AND p1.active_ind=1
      AND p1.end_effective_dt_tm >= cnvtdatetime(request->current_effective_dt_tm))
     JOIN (p2
     WHERE p2.price_sched_id=p1.price_sched_id
      AND p2.active_ind=1
      AND p2.end_effective_dt_tm >= cnvtdatetime(request->current_effective_dt_tm))
   ELSEIF ((request->item_type="D"))
    PLAN (b
     WHERE b.ext_parent_reference_id=0
      AND b.ext_child_reference_id != 0
      AND b.active_ind=1)
     JOIN (p1
     WHERE p1.bill_item_id=b.bill_item_id
      AND  $4
      AND p1.active_ind=1
      AND p1.end_effective_dt_tm >= cnvtdatetime(request->current_effective_dt_tm))
     JOIN (p2
     WHERE p2.price_sched_id=p1.price_sched_id
      AND p2.active_ind=1
      AND p2.end_effective_dt_tm >= cnvtdatetime(request->current_effective_dt_tm))
   ELSEIF ((request->item_type="O"))
    PLAN (b
     WHERE  $3
      AND b.ext_parent_reference_id=0
      AND b.active_ind=1)
     JOIN (p1
     WHERE p1.bill_item_id=b.bill_item_id
      AND  $4
      AND p1.active_ind=1
      AND p1.end_effective_dt_tm >= cnvtdatetime(request->current_effective_dt_tm))
     JOIN (p2
     WHERE p2.price_sched_id=p1.price_sched_id
      AND p2.active_ind=1
      AND p2.end_effective_dt_tm >= cnvtdatetime(request->current_effective_dt_tm))
   ELSE
   ENDIF
   INTO "nl:"
   b.*, p1.*, p2.*
   FROM bill_item b,
    price_sched_items p1,
    price_sched p2
   DETAIL
    count1 = (count1+ 1), stat = alterlist(reply->price_sched,count1), reply->price_sched[count1].
    bill_item_id = p1.bill_item_id,
    reply->price_sched[count1].price_sched_id = p1.price_sched_id, reply->price_sched[count1].
    price_sched_items_id = p1.price_sched_items_id, reply->price_sched[count1].price = p1.price,
    reply->price_sched[count1].active_ind = p1.active_ind, reply->price_sched[count1].charge_level_cd
     = p1.charge_level_cd
    IF (cnvtdatetime(p1.beg_effective_dt_tm) <= cnvtdatetime(request->current_effective_dt_tm)
     AND cnvtdatetime(p1.end_effective_dt_tm) >= cnvtdatetime(request->current_effective_dt_tm))
     reply->price_sched[count1].current_ind = 1
    ENDIF
    reply->price_sched[count1].beg_effective_dt_tm = cnvtdatetime(p1.beg_effective_dt_tm), reply->
    price_sched[count1].end_effective_dt_tm = cnvtdatetime(p1.end_effective_dt_tm)
   WITH nocounter
  ;end select
  SET reply->price_sched_qual = count1
 ENDIF
#endprogram
 IF (curqual1 != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.subeventstatus[1].operationname = "Select"
  SET reply->status_data.subeventstatus[1].operationstatus = "s"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "BILL_ITEM"
  SET reply->status_data.status = "Z"
 ENDIF
END GO
