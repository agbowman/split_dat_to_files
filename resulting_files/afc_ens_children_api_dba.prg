CREATE PROGRAM afc_ens_children_api:dba
 RECORD holdreq(
   1 nbr_of_recs = i2
   1 qual[*]
     2 action = i2
     2 ext_id = f8
     2 ext_contributor_cd = f8
     2 ext_owner_cd = f8
     2 child_qual = i2
     2 children[*]
       3 ext_id = f8
       3 ext_contributor_cd = f8
       3 ext_description = c100
       3 ext_short_desc = c50
 )
 IF (validate(reply->status_data.status,"Z")="Z")
  FREE SET reply
  RECORD reply(
    1 bill_item_qual = i4
    1 bill_item[*]
      2 bill_item_id = f8
    1 qual[*]
      2 bill_item_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c20
        3 targetobjectname = c15
        3 targetobjectvalue = vc
  )
 ENDIF
 SET psub = 0
 SET ttlpsub = request->nbr_of_recs
 CALL echo("Initialize")
 CALL initialize("init")
 SET billcodecd = 0.0
 SET code_value = 0.0
 SET cdf_meaning = "BILL CODE"
 SET code_set = 13019
 EXECUTE cpm_get_cd_for_cdf
 SET billcodecd = code_value
 GO TO initialize_request
#after_init_request
 FOR (psub = 1 TO ttlpsub)
  CALL echo(concat("============  qual[",cnvtstring(psub),"]  ============="))
  IF ((holdreq->qual[psub].ext_id != 0))
   IF ((holdreq->qual[psub].action=1))
    CALL echo("call Add Children")
    CALL add_children("dummy")
   ELSE
    IF ((holdreq->qual[psub].action=3))
     CALL echo("call Delete Children")
     CALL delete_children("dummy")
    ENDIF
   ENDIF
  ENDIF
 ENDFOR
 GO TO end_program
 SUBROUTINE delete_children(str)
   SET count1 = 0
   SET request->bill_item_qual = count1
   SELECT INTO "nl:"
    b.bill_item_id, b.active_status_cd, b.ext_description,
    b.ext_short_desc, b.ext_child_reference_id
    FROM bill_item b,
     (dummyt d1  WITH seq = value(holdreq->qual[psub].child_qual))
    PLAN (d1)
     JOIN (b
     WHERE (b.ext_child_reference_id=holdreq->qual[psub].children[d1.seq].ext_id)
      AND (b.ext_child_contributor_cd=holdreq->qual[psub].children[d1.seq].ext_contributor_cd)
      AND (b.ext_parent_reference_id=holdreq->qual[psub].ext_id)
      AND (b.ext_parent_contributor_cd=holdreq->qual[psub].ext_contributor_cd)
      AND b.active_ind=1)
    DETAIL
     count1 = (count1+ 1), stat = alterlist(request->bill_item,count1), request->bill_item_qual =
     count1,
     request->bill_item[count1].bill_item_id = b.bill_item_id
    WITH nocounter
   ;end select
   IF ((request->bill_item_qual > 0))
    SET action_begin = 1
    SET action_end = request->bill_item_qual
    CALL echo("Execute AFC_DEL_BILL_ITEM")
    EXECUTE afc_del_bill_item
   ENDIF
 END ;Subroutine
 SUBROUTINE add_children(str)
   CALL echo("Add_Children")
   SET count1 = 0
   SET request->bill_item_qual = count1
   SELECT INTO "nl:"
    d2.seq, holdreq->qual[psub].children[d2.seq].ext_description, holdreq->qual[psub].children[d2.seq
    ].ext_short_desc,
    b.bill_item_id, b.ext_description, b.ext_short_desc
    FROM bill_item b,
     (dummyt d2  WITH seq = value(holdreq->qual[psub].child_qual))
    PLAN (d2)
     JOIN (b
     WHERE b.active_ind=1
      AND (b.ext_parent_reference_id=holdreq->qual[psub].ext_id)
      AND (b.ext_parent_contributor_cd=holdreq->qual[psub].ext_contributor_cd)
      AND (b.ext_child_reference_id=holdreq->qual[psub].children[d2.seq].ext_id)
      AND (b.ext_child_contributor_cd=holdreq->qual[psub].children[d2.seq].ext_contributor_cd))
    DETAIL
     IF ((holdreq->qual[psub].children[d2.seq].ext_id != 0))
      count1 = (count1+ 1), stat = alterlist(request->bill_item,count1), request->bill_item_qual =
      count1,
      request->bill_item[count1].ext_owner_cd = holdreq->qual[psub].ext_owner_cd, request->bill_item[
      count1].ext_parent_reference_id = holdreq->qual[psub].ext_id, request->bill_item[count1].
      ext_parent_contributor_cd = holdreq->qual[psub].ext_contributor_cd,
      request->bill_item[count1].ext_child_reference_id = holdreq->qual[psub].children[d2.seq].ext_id,
      request->bill_item[count1].ext_child_contributor_cd = holdreq->qual[psub].children[d2.seq].
      ext_contributor_cd, request->bill_item[count1].ext_description = holdreq->qual[psub].children[
      d2.seq].ext_description,
      request->bill_item[count1].ext_short_desc = holdreq->qual[psub].children[d2.seq].ext_short_desc,
      request->bill_item[count1].parent_qual_ind = 0, request->bill_item[count1].active_ind_ind = 1,
      request->bill_item[count1].active_ind = 1
     ENDIF
    WITH outerjoin = d2, dontexist, nocounter
   ;end select
   CALL echo("here 1")
   IF ((request->bill_item_qual > 0))
    SELECT INTO "nl:"
     d1.seq
     FROM bill_item b,
      (dummyt d1  WITH seq = value(request->bill_item_qual))
     PLAN (d1)
      JOIN (b
      WHERE (b.ext_parent_reference_id=request->bill_item[d1.seq].ext_child_reference_id)
       AND (b.ext_parent_contributor_cd=request->bill_item[d1.seq].ext_child_contributor_cd)
       AND b.ext_child_reference_id=0
       AND b.ext_child_contributor_cd=0)
     DETAIL
      request->bill_item[d1.seq].parent_qual_ind = 1
     WITH nocounter
    ;end select
   ENDIF
   CALL echo("here 2")
   IF ((request->bill_item_qual > 0))
    SET action_begin = 1
    SET action_end = request->bill_item_qual
    CALL echo("Execute AFC_ADD_BILL_ITEM")
    EXECUTE afc_add_bill_item
   ENDIF
   SET count1 = 0
   SET request->bill_item_qual = count1
   SELECT INTO "nl:"
    d2.seq, holdreq->qual[psub].children[d2.seq].ext_description, holdreq->qual[psub].children[d2.seq
    ].ext_short_desc,
    b.bill_item_id, b.ext_description, b.ext_short_desc
    FROM bill_item b,
     (dummyt d2  WITH seq = value(holdreq->qual[psub].child_qual))
    PLAN (d2)
     JOIN (b
     WHERE b.active_ind=1
      AND ((b.ext_parent_reference_id=0
      AND b.ext_parent_contributor_cd=0
      AND (b.ext_child_reference_id=holdreq->qual[psub].children[d2.seq].ext_id)
      AND (b.ext_child_contributor_cd=holdreq->qual[psub].children[d2.seq].ext_contributor_cd)) OR ((
     b.ext_parent_reference_id=holdreq->qual[psub].children[d2.seq].ext_id)
      AND (b.ext_parent_contributor_cd=holdreq->qual[psub].children[d2.seq].ext_contributor_cd)
      AND b.ext_child_reference_id=0
      AND b.ext_child_contributor_cd=0)) )
    DETAIL
     IF ((holdreq->qual[psub].children[d2.seq].ext_id != 0))
      count1 = (count1+ 1), stat = alterlist(request->bill_item,count1), request->bill_item_qual =
      count1,
      request->bill_item[count1].ext_owner_cd = holdreq->qual[psub].ext_owner_cd, request->bill_item[
      count1].ext_parent_reference_id = 0.0, request->bill_item[count1].ext_parent_contributor_cd =
      0.0,
      request->bill_item[count1].ext_child_reference_id = holdreq->qual[psub].children[d2.seq].ext_id,
      request->bill_item[count1].ext_child_contributor_cd = holdreq->qual[psub].children[d2.seq].
      ext_contributor_cd, request->bill_item[count1].ext_description = holdreq->qual[psub].children[
      d2.seq].ext_description,
      request->bill_item[count1].ext_short_desc = holdreq->qual[psub].children[d2.seq].ext_short_desc,
      request->bill_item[count1].parent_qual_ind = 0, request->bill_item[count1].active_ind_ind = 1,
      request->bill_item[count1].active_ind = 1
     ENDIF
    WITH outerjoin = d2, dontexist, nocounter
   ;end select
   IF ((request->bill_item_qual > 0))
    SET action_begin = 1
    SET action_end = request->bill_item_qual
    EXECUTE afc_add_bill_item
   ENDIF
 END ;Subroutine
 SUBROUTINE initialize(str)
   SET reply->status_data.status = "F"
   SET stat = alterlist(holdreq->qual,request->nbr_of_recs)
   FOR (psub = 1 TO request->nbr_of_recs)
     SET holdreq->qual[psub].action = request->qual[psub].action
     SET holdreq->qual[psub].ext_id = request->qual[psub].ext_id
     SET holdreq->qual[psub].ext_owner_cd = request->qual[psub].ext_owner_cd
     SET holdreq->qual[psub].ext_contributor_cd = request->qual[psub].ext_contributor_cd
     SET holdreq->qual[psub].child_qual = request->qual[psub].child_qual
     SET stat = alterlist(holdreq->qual[psub].children,request->qual[psub].child_qual)
     FOR (i = 1 TO request->qual[psub].child_qual)
       IF ((request->qual[psub].children[i].ext_id=0))
        SET holdreq->qual[psub].children[i].ext_id = 0.0
       ELSE
        SET holdreq->qual[psub].children[i].ext_id = request->qual[psub].children[i].ext_id
       ENDIF
       IF ((request->qual[psub].children[i].ext_contributor_cd=0))
        SET holdreq->qual[psub].children[i].ext_contributor_cd = 0.0
       ELSE
        SET holdreq->qual[psub].children[i].ext_contributor_cd = request->qual[psub].children[i].
        ext_contributor_cd
       ENDIF
       SET holdreq->qual[psub].children[i].ext_description = request->qual[psub].children[i].
       ext_description
       SET holdreq->qual[psub].children[i].ext_short_desc = request->qual[psub].children[i].
       ext_short_desc
     ENDFOR
   ENDFOR
 END ;Subroutine
#initialize_request
 FREE SET request
 RECORD request(
   1 bill_item_qual = i2
   1 bill_item[*]
     2 bill_item_id = f8
     2 active_ind_ind = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 ext_parent_reference_id = f8
     2 ext_parent_contributor_cd = f8
     2 ext_child_reference_id = f8
     2 ext_child_contributor_cd = f8
     2 ext_description = c100
     2 ext_short_desc = c50
     2 ext_owner_cd = f8
     2 charge_point_cd = f8
     2 parent_qual_ind = f8
     2 physician_qual_cd = f8
     2 careset_ind = i2
   1 price_sched_items_qual = i2
   1 price_sched_items[*]
     2 action_type = vc
     2 price_sched_id = f8
     2 bill_item_id = f8
     2 price_sched_items_id = f8
     2 price_ind = i2
     2 price = f8
     2 percent_revenue = i4
     2 charge_level_cd = f8
     2 interval_template_cd = f8
     2 detail_charge_ind_ind = i2
     2 detail_charge_ind = i2
     2 active_ind_ind = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm_ind = i2
     2 end_effective_dt_tm = dq8
   1 bill_item_modifier_qual = i2
   1 bill_item_modifier[*]
     2 action_type = vc
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
     2 active_ind_ind = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
 )
 SET parent_id = - (1)
 GO TO after_init_request
#end_program
END GO
