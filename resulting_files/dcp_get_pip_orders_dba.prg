CREATE PROGRAM dcp_get_pip_orders:dba
 SET modify = predeclare
 FREE RECORD reply
 RECORD reply(
   1 run_dt_tm = dq8
   1 person_list[*]
     2 person_id = f8
     2 order_list[*]
       3 encntr_id = f8
       3 order_id = f8
       3 catalog_cd = f8
       3 catalog_type_cd = f8
       3 activity_type_cd = f8
       3 notify_display_line = vc
       3 order_mnemonic = vc
       3 hna_order_mnemonic = vc
       3 ordered_as_mnemonic = vc
       3 med_order_type_cd = f8
       3 need_rx_verify_ind = i2
       3 need_nurse_review_ind = i2
       3 need_doctor_cosign_ind = i2
       3 need_physician_validate_ind = i2
       3 order_status_cd = f8
       3 iv_ind = i2
       3 constant_ind = i2
       3 order_comment_ind = i2
       3 comment_type_mask = i4
       3 order_comment_text = vc
       3 updt_dt_tm = dq8
       3 updt_id = f8
       3 last_updt_prsnlid = f8
       3 last_action_sequence = i4
       3 additive_cnt = i4
       3 orig_order_dt_tm = dq8
       3 orig_order_tz = i4
       3 plan_ind = i2
       3 protocol_order_id = f8
       3 clin_updt_dt_tm = dq8
       3 clin_updt_tz = i4
       3 detail_list[*]
         4 oe_field_id = f8
         4 oe_field_value = f8
         4 oe_field_meaning = vc
         4 oe_field_meaning_id = f8
         4 oe_field_dt_tm_value = dq8
         4 oe_field_tz = i4
       3 action_list[*]
         4 action_sequence = i4
         4 action_type_cd = f8
         4 action_personnel_id = f8
         4 action_dt_tm = dq8
         4 action_tz = i4
       3 review_list[*]
         4 review_prsnl_id = f8
         4 review_type_flag = i2
         4 reviewed_status_flag = i2
         4 review_dt_tm = dq8
         4 review_tz = i4
         4 review_sequence = i4
         4 action_sequence = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET reply->run_dt_tm = cnvtdatetime(curdate,curtime3)
 DECLARE rep_cnt = i4 WITH protect, noconstant(0)
 DECLARE order_cnt = i4 WITH protect, noconstant(0)
 DECLARE detail_cnt = i4 WITH protect, noconstant(0)
 DECLARE req_cnt = i4 WITH protect, noconstant(size(request->person_list,5))
 DECLARE action_cnt = i4 WITH protect, noconstant(0)
 DECLARE order_comment_mask = i4 WITH protect, constant(1)
 DECLARE prescription_order = i4 WITH protect, constant(1)
 DECLARE historical_order = i4 WITH protect, constant(2)
 DECLARE protocol_order = i4 WITH protect, constant(7)
 DECLARE script_version = c12 WITH private, noconstant(fillstring(12," "))
 DECLARE debug_ind = i2 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE view_order_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",25651,"VIEWORDER"))
 DECLARE order_comment_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",14,"ORD COMMENT"))
 IF (validate(request->debug_ind)=1)
  IF ((request->debug_ind=1))
   SET debug_ind = 1
   CALL echo("*DEBUG MODE - ON - DCP_GET_PIP_ORDERS*")
  ENDIF
 ENDIF
 SET stat = alterlist(reply->person_list,req_cnt)
 SELECT INTO "nl:"
  o.order_id
  FROM (dummyt d  WITH seq = value(req_cnt)),
   orders o,
   order_action oa,
   (dummyt d2  WITH seq = 1),
   order_detail od
  PLAN (d)
   JOIN (o
   WHERE (o.person_id=request->person_list[d.seq].person_id)
    AND ((o.template_order_id+ 0)=0)
    AND o.template_order_flag != protocol_order
    AND o.updt_dt_tm >= cnvtdatetime(request->beg_dt_tm)
    AND  NOT (o.orig_ord_as_flag IN (prescription_order, historical_order)))
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.action_dt_tm > cnvtdatetime(request->beg_dt_tm)
    AND (oa.action_dt_tm >
   (SELECT
    nullval(max(dal.parent_entity_dt_tm),cnvtdatetime(request->beg_dt_tm))
    FROM dcp_activity_log dal
    WHERE (dal.prsnl_id=request->prsnl_id)
     AND dal.parent_entity_id=oa.order_id
     AND dal.activity_type_cd=view_order_cd)))
   JOIN (d2)
   JOIN (od
   WHERE od.order_id=o.order_id
    AND od.oe_field_meaning_id IN (43, 127, 141))
  ORDER BY o.person_id, o.order_id, oa.action_sequence,
   od.oe_field_meaning_id, od.action_sequence DESC
  HEAD o.person_id
   rep_cnt = (rep_cnt+ 1), reply->person_list[rep_cnt].person_id = o.person_id, order_cnt = 0
  HEAD o.order_id
   IF (band(o.cs_flag,1) != 1)
    action_cnt = 0, detail_cnt = 0, order_cnt = (order_cnt+ 1),
    stat = alterlist(reply->person_list[rep_cnt].order_list,order_cnt), reply->person_list[rep_cnt].
    order_list[order_cnt].encntr_id = o.encntr_id, reply->person_list[rep_cnt].order_list[order_cnt].
    order_id = o.order_id,
    reply->person_list[rep_cnt].order_list[order_cnt].catalog_cd = o.catalog_cd, reply->person_list[
    rep_cnt].order_list[order_cnt].catalog_type_cd = o.catalog_type_cd, reply->person_list[rep_cnt].
    order_list[order_cnt].activity_type_cd = o.activity_type_cd,
    reply->person_list[rep_cnt].order_list[order_cnt].med_order_type_cd = o.med_order_type_cd, reply
    ->person_list[rep_cnt].order_list[order_cnt].need_rx_verify_ind = o.need_rx_verify_ind, reply->
    person_list[rep_cnt].order_list[order_cnt].need_nurse_review_ind = o.need_nurse_review_ind,
    reply->person_list[rep_cnt].order_list[order_cnt].need_doctor_cosign_ind = o
    .need_doctor_cosign_ind, reply->person_list[rep_cnt].order_list[order_cnt].
    need_physician_validate_ind = o.need_physician_validate_ind, reply->person_list[rep_cnt].
    order_list[order_cnt].order_status_cd = o.order_status_cd,
    reply->person_list[rep_cnt].order_list[order_cnt].updt_id = o.updt_id, reply->person_list[rep_cnt
    ].order_list[order_cnt].updt_dt_tm = cnvtdatetime(o.updt_dt_tm), reply->person_list[rep_cnt].
    order_list[order_cnt].last_action_sequence = o.last_action_sequence,
    reply->person_list[rep_cnt].order_list[order_cnt].notify_display_line =
    IF (trim(o.clinical_display_line) > " ") o.clinical_display_line
    ELSE o.order_detail_display_line
    ENDIF
    , reply->person_list[rep_cnt].order_list[order_cnt].hna_order_mnemonic = o.hna_order_mnemonic,
    reply->person_list[rep_cnt].order_list[order_cnt].order_mnemonic = o.order_mnemonic,
    reply->person_list[rep_cnt].order_list[order_cnt].ordered_as_mnemonic = o.ordered_as_mnemonic,
    reply->person_list[rep_cnt].order_list[order_cnt].iv_ind = o.iv_ind, reply->person_list[rep_cnt].
    order_list[order_cnt].constant_ind = o.constant_ind,
    reply->person_list[rep_cnt].order_list[order_cnt].order_comment_ind = o.order_comment_ind, reply
    ->person_list[rep_cnt].order_list[order_cnt].comment_type_mask = o.comment_type_mask, reply->
    person_list[rep_cnt].order_list[order_cnt].orig_order_dt_tm = o.orig_order_dt_tm,
    reply->person_list[rep_cnt].order_list[order_cnt].orig_order_tz = o.orig_order_tz, reply->
    person_list[rep_cnt].order_list[order_cnt].clin_updt_dt_tm = o.clin_relevant_updt_dt_tm, reply->
    person_list[rep_cnt].order_list[order_cnt].clin_updt_tz = o.clin_relevant_updt_tz
    IF (o.pathway_catalog_id > 0)
     reply->person_list[rep_cnt].order_list[order_cnt].plan_ind = 1
    ELSE
     reply->person_list[rep_cnt].order_list[order_cnt].plan_ind = 0
    ENDIF
    reply->person_list[rep_cnt].order_list[order_cnt].protocol_order_id = o.protocol_order_id
   ENDIF
  HEAD oa.action_sequence
   IF (band(o.cs_flag,1) != 1)
    IF (o.last_action_sequence=oa.action_sequence)
     reply->person_list[rep_cnt].order_list[order_cnt].last_updt_prsnlid = oa.action_personnel_id
    ENDIF
    action_cnt = (action_cnt+ 1)
    IF (mod(action_cnt,3)=1)
     stat = alterlist(reply->person_list[rep_cnt].order_list[order_cnt].action_list,(action_cnt+ 2))
    ENDIF
    reply->person_list[rep_cnt].order_list[order_cnt].action_list[action_cnt].action_sequence = oa
    .action_sequence, reply->person_list[rep_cnt].order_list[order_cnt].action_list[action_cnt].
    action_type_cd = oa.action_type_cd, reply->person_list[rep_cnt].order_list[order_cnt].
    action_list[action_cnt].action_personnel_id = oa.action_personnel_id,
    reply->person_list[rep_cnt].order_list[order_cnt].action_list[action_cnt].action_dt_tm = oa
    .action_dt_tm, reply->person_list[rep_cnt].order_list[order_cnt].action_list[action_cnt].
    action_tz = oa.action_tz
   ENDIF
  DETAIL
   IF (band(o.cs_flag,1) != 1)
    IF (od.order_id > 0
     AND ((detail_cnt=0) OR ((reply->person_list[rep_cnt].order_list[order_cnt].detail_list[
    detail_cnt].oe_field_meaning_id != od.oe_field_meaning_id))) )
     detail_cnt = (detail_cnt+ 1), stat = alterlist(reply->person_list[rep_cnt].order_list[order_cnt]
      .detail_list,detail_cnt), reply->person_list[rep_cnt].order_list[order_cnt].detail_list[
     detail_cnt].oe_field_id = od.oe_field_id,
     reply->person_list[rep_cnt].order_list[order_cnt].detail_list[detail_cnt].oe_field_value = od
     .oe_field_value, reply->person_list[rep_cnt].order_list[order_cnt].detail_list[detail_cnt].
     oe_field_meaning = od.oe_field_meaning, reply->person_list[rep_cnt].order_list[order_cnt].
     detail_list[detail_cnt].oe_field_meaning_id = od.oe_field_meaning_id,
     reply->person_list[rep_cnt].order_list[order_cnt].detail_list[detail_cnt].oe_field_dt_tm_value
      = od.oe_field_dt_tm_value, reply->person_list[rep_cnt].order_list[order_cnt].detail_list[
     detail_cnt].oe_field_tz = validate(od.oe_field_tz,0)
    ENDIF
   ENDIF
  FOOT  o.order_id
   IF (mod(action_cnt,3) > 0
    AND order_cnt > 0)
    stat = alterlist(reply->person_list[rep_cnt].order_list[order_cnt].action_list,action_cnt)
   ENDIF
  WITH nocounter, outerjoin = d2
 ;end select
 SET stat = alterlist(reply->person_list,rep_cnt)
 SUBROUTINE getcommenttext(person_idx)
   IF (debug_ind=1)
    CALL echo("*Entering GetCommentText subroutine*")
   ENDIF
   DECLARE ord_cnt = i4 WITH private, constant(size(reply->person_list[person_idx].order_list,5))
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(ord_cnt)),
     order_comment oc,
     long_text lt
    PLAN (d
     WHERE band(reply->person_list[person_idx].order_list[d.seq].comment_type_mask,order_comment_mask
      )=order_comment_mask)
     JOIN (oc
     WHERE (oc.order_id=reply->person_list[person_idx].order_list[d.seq].order_id)
      AND oc.comment_type_cd=order_comment_cd
      AND (oc.action_sequence=
     (SELECT
      max(oc2.action_sequence)
      FROM order_comment oc2
      WHERE oc2.order_id=oc.order_id
       AND oc2.comment_type_cd=order_comment_cd)))
     JOIN (lt
     WHERE lt.long_text_id=oc.long_text_id)
    ORDER BY d.seq
    HEAD d.seq
     reply->person_list[person_idx].order_list[d.seq].order_comment_text = lt.long_text
    WITH nocounter
   ;end select
   IF (debug_ind=1)
    CALL echo("*Leaving GetCommentText subroutine*")
   ENDIF
 END ;Subroutine
 SUBROUTINE getadditivecount(person_idx)
   IF (debug_ind=1)
    CALL echo("*Entering GetAdditiveCount subroutine*")
   ENDIF
   DECLARE ord_cnt = i4 WITH private, constant(size(reply->person_list[person_idx].order_list,5))
   DECLARE add_cnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(ord_cnt)),
     order_ingredient oi
    PLAN (d
     WHERE (reply->person_list[person_idx].order_list[d.seq].med_order_type_cd > 0))
     JOIN (oi
     WHERE (oi.order_id=reply->person_list[person_idx].order_list[d.seq].order_id)
      AND (oi.action_sequence=
     (SELECT
      max(oi2.action_sequence)
      FROM order_ingredient oi2
      WHERE oi2.order_id=oi.order_id))
      AND ((oi.ingredient_type_flag=1) OR (oi.ingredient_type_flag=3)) )
    ORDER BY d.seq
    HEAD d.seq
     add_cnt = 0
    DETAIL
     add_cnt = (add_cnt+ 1)
    FOOT  d.seq
     reply->person_list[person_idx].order_list[d.seq].additive_cnt = add_cnt
    WITH nocounter
   ;end select
   IF (debug_ind=1)
    CALL echo("*Leaving GetAdditiveCount subroutine*")
   ENDIF
 END ;Subroutine
 SUBROUTINE getlastreviewonorder(person_idx)
   IF (debug_ind=1)
    CALL echo("*Entering GetLastReviewOnOrder subroutine*")
   ENDIF
   DECLARE numx = i4 WITH protect, noconstant(0)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE loc_idx = i4 WITH protect, noconstant(0)
   DECLARE ord_cnt = i4 WITH protect, constant(size(reply->person_list[person_idx].order_list,5))
   SELECT INTO "nl:"
    FROM order_review orev
    WHERE expand(numx,1,ord_cnt,orev.order_id,reply->person_list[person_idx].order_list[numx].
     order_id)
    ORDER BY orev.order_id, orev.review_type_flag, orev.updt_dt_tm DESC
    HEAD orev.order_id
     icnt = 0, idx = locateval(loc_idx,1,ord_cnt,orev.order_id,reply->person_list[person_idx].
      order_list[loc_idx].order_id)
    HEAD orev.review_type_flag
     IF (idx > 0)
      icnt = (icnt+ 1), stat = alterlist(reply->person_list[person_idx].order_list[idx].review_list,
       icnt), reply->person_list[person_idx].order_list[idx].review_list[icnt].review_prsnl_id = orev
      .review_personnel_id,
      reply->person_list[person_idx].order_list[idx].review_list[icnt].review_type_flag = orev
      .review_type_flag, reply->person_list[person_idx].order_list[idx].review_list[icnt].
      reviewed_status_flag = orev.reviewed_status_flag, reply->person_list[person_idx].order_list[idx
      ].review_list[icnt].review_dt_tm = orev.review_dt_tm,
      reply->person_list[person_idx].order_list[idx].review_list[icnt].review_tz = orev.review_tz,
      reply->person_list[person_idx].order_list[idx].review_list[icnt].review_sequence = orev
      .review_sequence, reply->person_list[person_idx].order_list[idx].review_list[icnt].
      action_sequence = orev.action_sequence
     ENDIF
    WITH nocounter, expand = 1
   ;end select
   IF (debug_ind=1)
    CALL echo("*Leaving GetLastReviewOnOrder subroutine*")
   ENDIF
 END ;Subroutine
 FOR (i = 1 TO rep_cnt)
   CALL getcommenttext(i)
   CALL getadditivecount(i)
   CALL getlastreviewonorder(i)
 ENDFOR
 IF (rep_cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET script_version = "012 01/10/14"
 IF (debug_ind=1)
  CALL echorecord(request)
  CALL echorecord(reply)
  CALL echo(build("Script Version: ",script_version))
 ENDIF
 SET modify = nopredeclare
END GO
