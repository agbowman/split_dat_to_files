CREATE PROGRAM cp_get_orders_depricated:dba
 RECORD reply(
   1 actions[*]
     2 template_order_id = f8
     2 order_id = f8
     2 med_order_type_cd = f8
     2 order_mnemonic = vc
     2 order_physician_id = f8
     2 catalog_type_cd = f8
     2 order_type_disp = c40
     2 order_type_desc = c60
     2 order_type_mean = c12
     2 order_placer_id = f8
     2 action_sequence = i4
     2 action_cd = f8
     2 action_disp = c40
     2 action_desc = c60
     2 action_mean = c12
     2 action_dt_tm = dq8
     2 action_tz = i4
     2 order_status_cd = f8
     2 order_status_disp = c40
     2 order_status_desc = c60
     2 order_status_mean = c12
     2 clinical_display_line = vc
     2 comments[*]
       3 comment = vc
       3 comment_dt_tm = dq8
     2 reviews[*]
       3 reviewer_id = f8
       3 review_dt_tm = dq8
       3 review_tz = i4
       3 review_status_flag = i4
       3 review_type_flag = i4
     2 activity_type_cd = f8
     2 catalog_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD orders(
   1 qual[*]
     2 order_id = f8
 )
 SET reply->status_data.status = "F"
 SET errmsg = fillstring(132," ")
 DECLARE scope_clause = vc
 DECLARE date_clause = vc
 DECLARE order_cnt = i4
 DECLARE add_alias_cd = f8
 DECLARE clear_cd = f8
 DECLARE collection_cd = f8
 DECLARE complete_cd = f8
 DECLARE demogchange_cd = f8
 DECLARE statuschange_cd = f8
 DECLARE undo_cd = f8
 DECLARE order_cmnt_cd = f8
 DECLARE iv_type_cd = f8
 DECLARE orderset_name = i2 WITH constant(1)
 SET stat = uar_get_meaning_by_codeset(6003,"ADD ALIAS",1,add_alias_cd)
 SET stat = uar_get_meaning_by_codeset(6003,"CLEAR",1,clear_cd)
 SET stat = uar_get_meaning_by_codeset(6003,"COLLECTION",1,collection_cd)
 SET stat = uar_get_meaning_by_codeset(6003,"COMPLETE",1,complete_cd)
 SET stat = uar_get_meaning_by_codeset(6003,"DEMOGCHANGE",1,demogchange_cd)
 SET stat = uar_get_meaning_by_codeset(6003,"STATUSCHANGE",1,statuschange_cd)
 SET stat = uar_get_meaning_by_codeset(6003,"UNDO",1,undo_cd)
 SET stat = uar_get_meaning_by_codeset(14,"ORD COMMENT",1,order_cmnt_cd)
 SET stat = uar_get_meaning_by_codeset(18309,"IV",1,iv_type_cd)
 CASE (request->scope_flag)
  OF 1:
   SET scope_clause = build("o1.person_id = ",request->person_id)
  OF 2:
   SET scope_clause = build("o1.person_id = ",request->person_id," AND o1.encntr_id = ",request->
    encntr_id)
  OF 3:
   SET scope_clause = build("o1.person_id+0 =",request->person_id," AND o1.encntr_id+0 = ",request->
    encntr_id," AND o1.order_id IN",
    " (SELECT order_id FROM chart_request_order"," WHERE chart_request_id = request->request_id)")
  OF 4:
   SET scope_clause = build("o1.order_id = aor.order_id"," AND o1.person_id+0 = ",request->person_id,
    " AND o1.encntr_id+0 = ",request->encntr_id)
  OF 5:
   SET scope_clause = build("o1.person_id =",request->person_id," AND o1.encntr_id IN",
    " (SELECT encntr_id FROM chart_request_encntr"," WHERE chart_request_id = request->request_id)")
  ELSE
   SET reply->status_data.status = "Z"
   SET reply->status_data.operationname = "Case"
   SET reply->status_data.operationstatus = "Z"
   SET reply->status_data.targetobjectname = "Scope"
   SET reply->status_data.targetobjectvalue = "Scope not supported"
   GO TO exit_script
 ENDCASE
 IF ((request->qual_on_date=1))
  SET date_clause = "oa.action_dt_tm BETWEEN"
  IF ((request->begin_dt_tm > 0))
   SET date_clause = concat(date_clause," CNVTDATETIME(request->begin_dt_tm) AND")
  ELSE
   SET date_clause = concat(date_clause," CNVTDATETIME('01-Jan-1800') AND")
  ENDIF
  IF ((request->end_dt_tm > 0))
   SET date_clause = concat(date_clause," CNVTDATETIME(request->end_dt_tm)")
  ELSE
   SET date_clause = concat(date_clause," CNVTDATETIME('31-Dec-2100 23:59:59.99')")
  ENDIF
 ELSE
  SET date_clause =
  "oa.action_dt_tm BETWEEN CNVTDATETIME('01-Jan-1800') AND CNVTDATETIME('31-Dec-2100 23:59:59.59')"
 ENDIF
 IF ((request->scope_flag=4))
  SELECT DISTINCT INTO "nl:"
   o1.order_id
   FROM accession_order_r aor,
    orders o1
   PLAN (aor
    WHERE (aor.accession=request->accession_nbr))
    JOIN (o1
    WHERE parser(scope_clause)
     AND o1.order_id > 0)
   ORDER BY o1.order_id
   DETAIL
    IF ( NOT (request->orderset_exclude_ind
     AND band(o1.cs_flag,orderset_name)))
     order_cnt = (order_cnt+ 1)
     IF (mod(order_cnt,10)=1)
      stat = alterlist(orders->qual,(order_cnt+ 9))
     ENDIF
     orders->qual[order_cnt].order_id = o1.order_id
    ENDIF
   WITH nocounter
  ;end select
 ELSE
  SELECT DISTINCT INTO "nl:"
   o1.order_id, o2.order_id
   FROM orders o1,
    orders o2
   PLAN (o1
    WHERE parser(scope_clause)
     AND ((o1.order_id+ 0) > 0)
     AND ((o1.template_order_id+ 0)=0))
    JOIN (o2
    WHERE o2.template_order_id=outerjoin(o1.order_id)
     AND o2.last_action_sequence > outerjoin(o1.last_action_sequence))
   ORDER BY o1.order_id, o2.order_id
   HEAD o1.order_id
    IF ( NOT (request->orderset_exclude_ind
     AND band(o1.cs_flag,orderset_name)))
     order_cnt = (order_cnt+ 1)
     IF (mod(order_cnt,10)=1)
      stat = alterlist(orders->qual,(order_cnt+ 9))
     ENDIF
     orders->qual[order_cnt].order_id = o1.order_id
    ENDIF
   DETAIL
    IF ( NOT (request->orderset_exclude_ind
     AND band(o1.cs_flag,orderset_name)))
     IF (o2.order_id > 0)
      order_cnt = (order_cnt+ 1)
      IF (mod(order_cnt,10)=1)
       stat = alterlist(orders->qual,(order_cnt+ 9))
      ENDIF
      orders->qual[order_cnt].order_id = o2.order_id
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->scope_flag=4))
  SELECT DISTINCT INTO "nl:"
   aor.order_id
   FROM ce_linked_result clr1,
    ce_linked_result clr2,
    accession_order_r aor
   PLAN (clr1
    WHERE (clr1.accession_nbr=request->accession_nbr))
    JOIN (clr2
    WHERE clr2.linked_event_id=clr1.linked_event_id
     AND clr2.event_id != clr1.event_id)
    JOIN (aor
    WHERE aor.accession=clr2.accession_nbr
     AND (aor.accession != request->accession_nbr))
   DETAIL
    order_cnt = (order_cnt+ 1)
    IF (mod(order_cnt,10)=1)
     stat = alterlist(orders->qual,(order_cnt+ 9))
    ENDIF
    orders->qual[order_cnt].order_id = aor.order_id
   WITH nocounter
  ;end select
 ENDIF
 SET stat = alterlist(orders->qual,order_cnt)
 SELECT
  IF ((request->sort_order_ind=1))
   ORDER BY oa.action_dt_tm DESC, o.order_id DESC, orv.review_type_flag,
    orv.review_sequence DESC, oc.comment_dt_tm DESC
  ELSE
   ORDER BY oa.action_dt_tm, o.order_id, orv.review_type_flag,
    orv.review_sequence DESC, oc.comment_dt_tm DESC
  ENDIF
  INTO "nl:"
  side = decode(oc.seq,"Com",orv.seq,"Rev","XXX")
  FROM orders o,
   order_action oa,
   order_review orv,
   order_comment oc,
   long_text lt,
   (dummyt d0  WITH seq = value(order_cnt)),
   dummyt d1,
   dummyt d2
  PLAN (d0)
   JOIN (o
   WHERE (o.order_id=orders->qual[d0.seq].order_id))
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND parser(date_clause)
    AND oa.core_ind=1
    AND  NOT (oa.action_type_cd IN (add_alias_cd, clear_cd, collection_cd, complete_cd,
   demogchange_cd,
   statuschange_cd, undo_cd)))
   JOIN (((d1)
   JOIN (orv
   WHERE orv.order_id=oa.order_id
    AND orv.action_sequence=oa.action_sequence)
   ) ORJOIN ((d2)
   JOIN (oc
   WHERE oc.order_id=oa.order_id
    AND oc.action_sequence=oa.action_sequence
    AND oc.comment_type_cd=order_cmnt_cd)
   JOIN (lt
   WHERE lt.long_text_id=oc.long_text_id)
   ))
  HEAD REPORT
   actioncnt = 0, commentcnt = 0, reviewcnt = 0
  HEAD oa.action_dt_tm
   do_nothing = 0
  HEAD o.order_id
   IF ((((request->scope_flag != 4)
    AND ((o.template_order_id=0) OR (o.template_order_id > 0
    AND oa.action_sequence=o.last_action_sequence)) ) OR ((request->scope_flag=4))) )
    actioncnt = (actioncnt+ 1)
    IF (mod(actioncnt,15)=1)
     stat = alterlist(reply->actions,(actioncnt+ 14))
    ENDIF
    reply->actions[actioncnt].template_order_id = o.template_order_id, reply->actions[actioncnt].
    order_id = o.order_id, reply->actions[actioncnt].med_order_type_cd = o.med_order_type_cd,
    reply->actions[actioncnt].order_mnemonic = o.order_mnemonic, reply->actions[actioncnt].
    catalog_type_cd = o.catalog_type_cd, reply->actions[actioncnt].order_placer_id = oa
    .action_personnel_id,
    reply->actions[actioncnt].order_physician_id = oa.order_provider_id, reply->actions[actioncnt].
    action_sequence = oa.action_sequence, reply->actions[actioncnt].action_cd = oa.action_type_cd,
    reply->actions[actioncnt].action_disp = uar_get_code_display(oa.action_type_cd), reply->actions[
    actioncnt].action_dt_tm = oa.action_dt_tm, reply->actions[actioncnt].action_tz = validate(oa
     .action_tz,0),
    reply->actions[actioncnt].order_status_cd = o.order_status_cd, reply->actions[actioncnt].
    clinical_display_line = oa.clinical_display_line, reply->actions[actioncnt].activity_type_cd = o
    .activity_type_cd,
    reply->actions[actioncnt].catalog_cd = o.catalog_cd
   ENDIF
  HEAD orv.review_type_flag
   IF ((((request->scope_flag != 4)
    AND ((o.template_order_id=0) OR (o.template_order_id > 0
    AND oa.action_sequence=o.last_action_sequence)) ) OR ((request->scope_flag=4))) )
    IF (side="Rev")
     reviewcnt = (reviewcnt+ 1)
     IF (mod(reviewcnt,5)=1)
      stat = alterlist(reply->actions[actioncnt].reviews,(reviewcnt+ 4))
     ENDIF
     reply->actions[actioncnt].reviews[reviewcnt].review_status_flag = orv.reviewed_status_flag,
     reply->actions[actioncnt].reviews[reviewcnt].review_type_flag = orv.review_type_flag, reply->
     actions[actioncnt].reviews[reviewcnt].reviewer_id =
     IF (orv.review_personnel_id > 0) orv.review_personnel_id
     ELSE orv.provider_id
     ENDIF
     ,
     reply->actions[actioncnt].reviews[reviewcnt].review_dt_tm = orv.review_dt_tm, reply->actions[
     actioncnt].reviews[reviewcnt].review_tz = validate(orv.review_tz,0)
    ENDIF
   ENDIF
  DETAIL
   IF ((((request->scope_flag != 4)
    AND ((o.template_order_id=0) OR (o.template_order_id > 0
    AND oa.action_sequence=o.last_action_sequence)) ) OR ((request->scope_flag=4))) )
    IF (side="Com")
     commentcnt = (commentcnt+ 1)
     IF (mod(commentcnt,5)=1)
      stat = alterlist(reply->actions[actioncnt].comments,(commentcnt+ 4))
     ENDIF
     reply->actions[actioncnt].comments[commentcnt].comment = lt.long_text, reply->actions[actioncnt]
     .comments[commentcnt].comment_dt_tm = oc.updt_dt_tm
    ENDIF
   ENDIF
  FOOT  orv.review_type_flag
   do_nothing = 0
  FOOT  o.order_id
   IF ((((request->scope_flag != 4)
    AND ((o.template_order_id=0) OR (o.template_order_id > 0
    AND oa.action_sequence=o.last_action_sequence)) ) OR ((request->scope_flag=4))) )
    stat = alterlist(reply->actions[actioncnt].reviews,reviewcnt), stat = alterlist(reply->actions[
     actioncnt].comments,commentcnt), reviewcnt = 0,
    commentcnt = 0
   ENDIF
  FOOT  oa.action_dt_tm
   do_nothing = 0
  FOOT REPORT
   stat = alterlist(reply->actions,actioncnt)
  WITH nocounter, memsort, outerjoin = d1
 ;end select
 FREE RECORD orders
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.operationname = "Select"
  SET reply->status_data.operationstatus = "F"
  SET errorcode = error(errmsg,0)
  IF (errorcode != 0)
   SET reply->status_data.targetobjectname = "ErrorMessage"
   SET reply->status_data.targetobjectvalue = errmsg
  ELSE
   SET reply->status_data.targetobjectname = "Qualifications"
   SET reply->status_data.targetobjectvalue = "No matching records"
  ENDIF
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM order_detail od,
   (dummyt d  WITH seq = value(size(reply->actions,5)))
  PLAN (d
   WHERE ((size(reply->actions[d.seq].clinical_display_line,1) > 250) OR (size(reply->actions[d.seq].
    clinical_display_line,1)=0)) )
   JOIN (od
   WHERE (od.order_id=reply->actions[d.seq].order_id)
    AND (od.action_sequence=reply->actions[d.seq].action_sequence)
    AND  NOT (od.oe_field_meaning_id IN (125, 2071, 2094)))
  ORDER BY d.seq, od.detail_sequence
  HEAD REPORT
   detailcnt = 0, lastfieldid = 0.0
  HEAD d.seq
   reply->actions[d.seq].clinical_display_line = ""
  DETAIL
   IF ( NOT (od.oe_field_display_value IN (" ", "")))
    detailcnt = (detailcnt+ 1)
    IF (detailcnt=1)
     reply->actions[d.seq].clinical_display_line = trim(od.oe_field_display_value)
    ELSEIF (od.oe_field_meaning_id=lastfieldid)
     reply->actions[d.seq].clinical_display_line = concat(trim(reply->actions[d.seq].
       clinical_display_line)," | ",trim(od.oe_field_display_value))
    ELSE
     reply->actions[d.seq].clinical_display_line = concat(trim(reply->actions[d.seq].
       clinical_display_line),", ",trim(od.oe_field_display_value))
    ENDIF
   ENDIF
   lastfieldid = od.oe_field_meaning_id
  FOOT  d.seq
   lastfieldid = 0.0, detailcnt = 0
  FOOT REPORT
   do_nothing = 0
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM order_ingredient oi,
   (dummyt d  WITH seq = value(size(reply->actions,5)))
  PLAN (d
   WHERE (reply->actions[d.seq].med_order_type_cd=iv_type_cd))
   JOIN (oi
   WHERE (oi.order_id=reply->actions[d.seq].order_id)
    AND (oi.action_sequence=reply->actions[d.seq].action_sequence))
  ORDER BY d.seq, oi.comp_sequence
  HEAD REPORT
   ingredientcnt = 0
  HEAD d.seq
   reply->actions[d.seq].order_mnemonic = ""
  DETAIL
   ingredientcnt = (ingredientcnt+ 1)
   IF (ingredientcnt=1)
    reply->actions[d.seq].order_mnemonic = trim(oi.order_mnemonic)
   ELSE
    reply->actions[d.seq].order_mnemonic = concat(trim(reply->actions[d.seq].order_mnemonic)," + ",
     trim(oi.order_mnemonic))
   ENDIF
  FOOT  d.seq
   ingredientcnt = 0
  FOOT REPORT
   do_nothing = 0
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
#exit_script
 CALL echorecord(reply)
END GO
