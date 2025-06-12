CREATE PROGRAM cpmnotify_dcp_ord:dba
 SET modify = predeclare
 FREE RECORD reply
 RECORD reply(
   1 run_dt_tm = dq8
   1 overlay_ind = i2
   1 entity_list[*]
     2 entity_id = f8
     2 datalist[*]
       3 order_id = f8
       3 encntr_id = f8
       3 catalog_cd = f8
       3 catalog_type_cd = f8
       3 activity_type_cd = f8
       3 med_order_type_cd = f8
       3 need_rx_verify_ind = i2
       3 need_nurse_review_ind = i2
       3 need_doctor_cosign_ind = i2
       3 need_physician_validate_ind = i2
       3 order_status_cd = f8
       3 notify_display_line = vc
       3 hna_order_mnemonic = vc
       3 order_mnemonic = vc
       3 ordered_as_mnemonic = vc
       3 iv_ind = i2
       3 constant_ind = i2
       3 order_comment_ind = i2
       3 comment_type_mask = i4
       3 order_comment_text = vc
       3 updt_dt_tm = dq8
       3 updt_id = f8
       3 last_updt_prsnlid = f8
       3 last_action_sequence = i4
       3 orig_order_dt_tm = dq8
       3 orig_order_tz = i4
       3 orig_ord_as_flag = i2
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
 FREE RECORD temp
 RECORD temp(
   1 qual[*]
     2 person_id = f8
     2 person_idx = i4
     2 order_id = f8
     2 order_idx = i4
 )
 DECLARE initialize(null) = null
 DECLARE identifyorders(null) = null
 DECLARE loadordercomments(order_cnt=i4) = null
 DECLARE loadorderdetails(order_cnt=i4) = null
 DECLARE loadorderreviews(order_cnt=i4) = null
 DECLARE protocol_order = i4 WITH protect, constant(7)
 DECLARE order_cnt = i4 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE overlapping_interval = i4 WITH protect, noconstant(0)
 DECLARE overlapping_last_run_dt_tm = dq8 WITH protect, noconstant
 DECLARE start_time = dq8 WITH protect, noconstant(cnvtdatetime(curdate,curtime3))
 DECLARE temp_time = dq8 WITH protect, noconstant
 DECLARE debug_ind = i2 WITH protect, noconstant(0)
 DECLARE error_code = i2 WITH protect, noconstant(0)
 DECLARE error_msg = vc WITH protect, noconstant("")
 DECLARE script_version = c12 WITH private, noconstant(fillstring(12," "))
 IF (validate(request->debug_ind)=1)
  IF ((request->debug_ind=1))
   SET debug_ind = 1
   CALL echo("*DEBUG MODE - ON - CPMNOTIFY_DCP_ORD*")
  ENDIF
 ENDIF
 CALL initialize(null)
 CALL identifyorders(null)
 SET order_cnt = size(temp->qual,5)
 IF (order_cnt > 0)
  DECLARE o_exp_max_cnt = i4 WITH protect, constant(200)
  DECLARE o_exp_chunk_cnt = i4 WITH protect, constant(ceil(((order_cnt * 1.0)/ o_exp_max_cnt)))
  DECLARE o_exp_max_size = i4 WITH protect, constant((o_exp_chunk_cnt * o_exp_max_cnt))
  SET stat = alterlist(temp->qual,o_exp_max_size)
  FOR (x = (order_cnt+ 1) TO o_exp_max_size)
    SET temp->qual[x].order_id = temp->qual[order_cnt].order_id
  ENDFOR
  CALL loadordercomments(order_cnt)
  CALL loadorderdetails(order_cnt)
  CALL loadorderreviews(order_cnt)
 ENDIF
 IF (order_cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 SET error_code = error(error_msg,1)
 IF (error_code != 0)
  SET reply->status_data.status = "F"
  CALL echo(build("ERROR: ",error_msg))
 ENDIF
 SUBROUTINE initialize(null)
   SET overlapping_interval = cnvtint(datetimediff(cnvtdatetime(curdate,curtime3),request->
     last_run_dt_tm,5))
   SET overlapping_last_run_dt_tm = cnvtlookbehind(build(cnvtstring(overlapping_interval),",S"),
    request->last_run_dt_tm)
   SET reply->run_dt_tm = cnvtdatetime(curdate,curtime3)
   SET reply->status_data.status = "F"
   IF (debug_ind=1)
    CALL echo("*******************************************************")
    CALL echo(build("Last Run Dt Tm: ",format(request->last_run_dt_tm,";;q")))
    CALL echo(build("Overlapping Interval: ",overlapping_interval," seconds."))
    CALL echo(build("Overlapping Last Run Dt Tm: ",format(overlapping_last_run_dt_tm,";;q")))
    CALL echo("*******************************************************")
   ENDIF
 END ;Subroutine
 SUBROUTINE identifyorders(null)
   IF (debug_ind=1)
    SET temp_time = cnvtdatetime(curdate,curtime3)
    CALL echo("*Entering IdentifyOrders subroutine*")
   ENDIF
   DECLARE entity_cnt = i4 WITH protect, noconstant(size(request->entity_list,5))
   DECLARE expand_idx = i4 WITH protect, noconstant(0)
   DECLARE expand_start = i4 WITH protect, noconstant(1)
   DECLARE expand_max_cnt = i4 WITH protect, constant(100)
   DECLARE expand_chunk_cnt = i4 WITH protect, constant(ceil(((entity_cnt * 1.0)/ expand_max_cnt)))
   DECLARE expand_max_size = i4 WITH protect, constant((expand_chunk_cnt * expand_max_cnt))
   DECLARE order_cnt = i4 WITH protect, noconstant(0)
   DECLARE p_cnt = i4 WITH protect, noconstant(0)
   DECLARE o_cnt = i4 WITH protect, noconstant(0)
   DECLARE a_cnt = i4 WITH protect, noconstant(0)
   DECLARE include_order = i2 WITH protect, noconstant(0)
   SET stat = alterlist(request->entity_list,expand_max_size)
   FOR (x = (entity_cnt+ 1) TO expand_max_size)
     SET request->entity_list[x].entity_id = request->entity_list[entity_cnt].entity_id
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(expand_chunk_cnt)),
     orders o,
     order_action oa
    PLAN (d1
     WHERE assign(expand_start,evaluate(d1.seq,1,1,(expand_start+ expand_max_cnt))))
     JOIN (o
     WHERE expand(expand_idx,expand_start,((expand_start+ expand_max_cnt) - 1),o.person_id,request->
      entity_list[expand_idx].entity_id)
      AND o.updt_dt_tm >= cnvtdatetime(overlapping_last_run_dt_tm)
      AND ((o.template_order_id+ 0)=0)
      AND o.template_order_flag != protocol_order)
     JOIN (oa
     WHERE oa.order_id=o.order_id)
    ORDER BY o.person_id, o.order_id, oa.action_sequence
    HEAD o.person_id
     stat = alterlist(reply->entity_list,entity_cnt), p_cnt = (p_cnt+ 1), reply->entity_list[p_cnt].
     entity_id = o.person_id,
     o_cnt = 0
    HEAD o.order_id
     IF (debug_ind=1)
      CALL echo("*******************************************************"),
      CALL echo(build("Order Updt Dt Tm: ",format(o.updt_dt_tm,";;q"))),
      CALL echo("*******************************************************")
     ENDIF
     include_order = 0
     IF (band(o.cs_flag,1) != 1)
      include_order = 1, a_cnt = 0, o_cnt = (o_cnt+ 1)
      IF (mod(o_cnt,20)=1)
       stat = alterlist(reply->entity_list[p_cnt].datalist,(o_cnt+ 19))
      ENDIF
      reply->entity_list[p_cnt].datalist[o_cnt].order_id = o.order_id, reply->entity_list[p_cnt].
      datalist[o_cnt].encntr_id = o.encntr_id, reply->entity_list[p_cnt].datalist[o_cnt].catalog_cd
       = o.catalog_cd,
      reply->entity_list[p_cnt].datalist[o_cnt].catalog_type_cd = o.catalog_type_cd, reply->
      entity_list[p_cnt].datalist[o_cnt].activity_type_cd = o.activity_type_cd, reply->entity_list[
      p_cnt].datalist[o_cnt].med_order_type_cd = o.med_order_type_cd,
      reply->entity_list[p_cnt].datalist[o_cnt].need_rx_verify_ind = o.need_rx_verify_ind, reply->
      entity_list[p_cnt].datalist[o_cnt].need_nurse_review_ind = o.need_nurse_review_ind, reply->
      entity_list[p_cnt].datalist[o_cnt].need_doctor_cosign_ind = o.need_doctor_cosign_ind,
      reply->entity_list[p_cnt].datalist[o_cnt].need_physician_validate_ind = o
      .need_physician_validate_ind, reply->entity_list[p_cnt].datalist[o_cnt].order_status_cd = o
      .order_status_cd, reply->entity_list[p_cnt].datalist[o_cnt].updt_id = o.updt_id,
      reply->entity_list[p_cnt].datalist[o_cnt].updt_dt_tm = cnvtdatetime(o.updt_dt_tm), reply->
      entity_list[p_cnt].datalist[o_cnt].last_action_sequence = o.last_action_sequence, reply->
      entity_list[p_cnt].datalist[o_cnt].notify_display_line =
      IF (trim(o.clinical_display_line) > " ") o.clinical_display_line
      ELSE o.order_detail_display_line
      ENDIF
      ,
      reply->entity_list[p_cnt].datalist[o_cnt].hna_order_mnemonic = o.hna_order_mnemonic, reply->
      entity_list[p_cnt].datalist[o_cnt].order_mnemonic = o.order_mnemonic, reply->entity_list[p_cnt]
      .datalist[o_cnt].ordered_as_mnemonic = o.ordered_as_mnemonic,
      reply->entity_list[p_cnt].datalist[o_cnt].iv_ind = o.iv_ind, reply->entity_list[p_cnt].
      datalist[o_cnt].constant_ind = o.constant_ind, reply->entity_list[p_cnt].datalist[o_cnt].
      order_comment_ind = o.order_comment_ind,
      reply->entity_list[p_cnt].datalist[o_cnt].comment_type_mask = o.comment_type_mask, reply->
      entity_list[p_cnt].datalist[o_cnt].orig_order_dt_tm = o.orig_order_dt_tm, reply->entity_list[
      p_cnt].datalist[o_cnt].orig_order_tz = o.orig_order_tz,
      reply->entity_list[p_cnt].datalist[o_cnt].orig_ord_as_flag = o.orig_ord_as_flag, reply->
      entity_list[p_cnt].datalist[o_cnt].clin_updt_dt_tm = o.clin_relevant_updt_dt_tm, reply->
      entity_list[p_cnt].datalist[o_cnt].clin_updt_tz = o.clin_relevant_updt_tz
      IF (o.pathway_catalog_id > 0)
       reply->entity_list[p_cnt].datalist[o_cnt].plan_ind = 1
      ELSE
       reply->entity_list[p_cnt].datalist[o_cnt].plan_ind = 0
      ENDIF
      reply->entity_list[p_cnt].datalist[o_cnt].protocol_order_id = o.protocol_order_id, order_cnt =
      (order_cnt+ 1)
      IF (mod(order_cnt,100)=1)
       stat = alterlist(temp->qual,(order_cnt+ 99))
      ENDIF
      temp->qual[order_cnt].order_id = o.order_id, temp->qual[order_cnt].order_idx = o_cnt, temp->
      qual[order_cnt].person_id = o.person_id,
      temp->qual[order_cnt].person_idx = p_cnt
     ENDIF
    HEAD oa.action_sequence
     IF (debug_ind=1)
      CALL echo("*******************************************************"),
      CALL echo(build("Order Action Dt Tm: ",format(oa.action_dt_tm,";;q"))),
      CALL echo("*******************************************************")
     ENDIF
     IF (include_order > 0
      AND oa.action_dt_tm >= cnvtdatetime(overlapping_last_run_dt_tm))
      IF (o.last_action_sequence=oa.action_sequence)
       reply->entity_list[p_cnt].datalist[o_cnt].last_updt_prsnlid = oa.action_personnel_id
      ENDIF
      a_cnt = (a_cnt+ 1)
      IF (mod(a_cnt,5)=1)
       stat = alterlist(reply->entity_list[p_cnt].datalist[o_cnt].action_list,(a_cnt+ 4))
      ENDIF
      reply->entity_list[p_cnt].datalist[o_cnt].action_list[a_cnt].action_sequence = oa
      .action_sequence, reply->entity_list[p_cnt].datalist[o_cnt].action_list[a_cnt].action_type_cd
       = oa.action_type_cd, reply->entity_list[p_cnt].datalist[o_cnt].action_list[a_cnt].
      action_personnel_id = oa.action_personnel_id,
      reply->entity_list[p_cnt].datalist[o_cnt].action_list[a_cnt].action_dt_tm = oa.action_dt_tm,
      reply->entity_list[p_cnt].datalist[o_cnt].action_list[a_cnt].action_tz = oa.action_tz
     ENDIF
    FOOT  o.order_id
     IF (include_order > 0)
      stat = alterlist(reply->entity_list[p_cnt].datalist[o_cnt].action_list,a_cnt)
     ENDIF
    FOOT  o.person_id
     stat = alterlist(reply->entity_list[p_cnt].datalist,o_cnt)
     IF (o_cnt=0)
      p_cnt = (p_cnt - 1)
     ENDIF
    FOOT REPORT
     stat = alterlist(temp->qual,order_cnt), stat = alterlist(reply->entity_list,p_cnt)
    WITH nocounter
   ;end select
   IF (debug_ind=1)
    CALL echo("*Leaving IdentifyOrders subroutine*")
    CALL echo("*******************************************************")
    CALL echo(build("Time for loading orders = ",datetimediff(cnvtdatetime(curdate,curtime3),
       temp_time,5)," seconds."))
    CALL echo("*******************************************************")
   ENDIF
 END ;Subroutine
 SUBROUTINE loadordercomments(order_cnt)
   IF (debug_ind=1)
    SET temp_time = cnvtdatetime(curdate,curtime3)
    CALL echo("*Entering LoadOrderComments subroutine*")
   ENDIF
   DECLARE o_exp_idx = i4 WITH protect, noconstant(0)
   DECLARE o_exp_start = i4 WITH protect, noconstant(1)
   DECLARE o_loc_idx = i4 WITH protect, noconstant(0)
   DECLARE p_idx = i4 WITH protect, noconstant(0)
   DECLARE o_idx = i4 WITH protect, noconstant(0)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE order_comment_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",14,"ORD COMMENT")
    )
   DECLARE order_comment_mask = i4 WITH protect, constant(1)
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(o_exp_chunk_cnt)),
     order_comment oc,
     long_text lt
    PLAN (d1
     WHERE assign(o_exp_start,evaluate(d1.seq,1,1,(o_exp_start+ o_exp_max_cnt))))
     JOIN (oc
     WHERE expand(o_exp_idx,o_exp_start,((o_exp_start+ o_exp_max_cnt) - 1),oc.order_id,temp->qual[
      o_exp_idx].order_id)
      AND oc.comment_type_cd=order_comment_cd
      AND (oc.action_sequence=
     (SELECT
      max(oc2.action_sequence)
      FROM order_comment oc2
      WHERE oc2.order_id=oc.order_id
       AND oc2.comment_type_cd=order_comment_cd)))
     JOIN (lt
     WHERE lt.long_text_id=oc.long_text_id)
    ORDER BY oc.order_id
    HEAD oc.order_id
     idx = locateval(o_loc_idx,1,order_cnt,oc.order_id,temp->qual[o_loc_idx].order_id)
     IF (idx > 0)
      p_idx = temp->qual[o_loc_idx].person_idx, o_idx = temp->qual[o_loc_idx].order_idx
     ENDIF
     reply->entity_list[p_idx].datalist[o_idx].order_comment_text = lt.long_text
    WITH nocounter
   ;end select
   IF (debug_ind=1)
    CALL echo("*Leaving LoadOrderComments subroutine*")
    CALL echo("*******************************************************")
    CALL echo(build("Time for loading order comments = ",datetimediff(cnvtdatetime(curdate,curtime3),
       temp_time,5)," seconds."))
    CALL echo("*******************************************************")
   ENDIF
 END ;Subroutine
 SUBROUTINE loadorderdetails(order_cnt)
   IF (debug_ind=1)
    SET temp_time = cnvtdatetime(curdate,curtime3)
    CALL echo("*Entering LoadOrderDetails subroutine*")
   ENDIF
   DECLARE o_exp_idx = i4 WITH protect, noconstant(0)
   DECLARE o_exp_start = i4 WITH protect, noconstant(1)
   DECLARE o_loc_idx = i4 WITH protect, noconstant(0)
   DECLARE p_idx = i4 WITH protect, noconstant(0)
   DECLARE o_idx = i4 WITH protect, noconstant(0)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE detail_cnt = i4 WITH protect, noconstant(0)
   DECLARE last_detail = f8 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(o_exp_chunk_cnt)),
     order_detail od
    PLAN (d1
     WHERE assign(o_exp_start,evaluate(d1.seq,1,1,(o_exp_start+ o_exp_max_cnt))))
     JOIN (od
     WHERE expand(o_exp_idx,o_exp_start,((o_exp_start+ o_exp_max_cnt) - 1),od.order_id,temp->qual[
      o_exp_idx].order_id)
      AND od.oe_field_meaning_id IN (43, 127, 141))
    ORDER BY od.order_id, od.oe_field_meaning_id, od.action_sequence
    HEAD REPORT
     idx = 0
    HEAD od.order_id
     idx = locateval(o_loc_idx,1,order_cnt,od.order_id,temp->qual[o_loc_idx].order_id)
     IF (idx > 0)
      p_idx = temp->qual[o_loc_idx].person_idx, o_idx = temp->qual[o_loc_idx].order_idx
     ENDIF
     detail_cnt = 0, last_detail = 0, stat = alterlist(reply->entity_list[p_idx].datalist[o_idx].
      detail_list,3)
    DETAIL
     IF (od.oe_field_meaning_id != last_detail)
      last_detail = od.oe_field_meaning_id, detail_cnt = (detail_cnt+ 1)
     ENDIF
     reply->entity_list[p_idx].datalist[o_idx].detail_list[detail_cnt].oe_field_id = od.oe_field_id,
     reply->entity_list[p_idx].datalist[o_idx].detail_list[detail_cnt].oe_field_value = od
     .oe_field_value, reply->entity_list[p_idx].datalist[o_idx].detail_list[detail_cnt].
     oe_field_meaning = od.oe_field_meaning,
     reply->entity_list[p_idx].datalist[o_idx].detail_list[detail_cnt].oe_field_meaning_id = od
     .oe_field_meaning_id, reply->entity_list[p_idx].datalist[o_idx].detail_list[detail_cnt].
     oe_field_dt_tm_value = od.oe_field_dt_tm_value
    FOOT  od.order_id
     stat = alterlist(reply->entity_list[p_idx].datalist[o_idx].detail_list,detail_cnt)
    WITH nocounter
   ;end select
   IF (debug_ind=1)
    CALL echo("*Leaving LoadOrderDetails subroutine*")
    CALL echo("*******************************************************")
    CALL echo(build("Time for loading order details = ",datetimediff(cnvtdatetime(curdate,curtime3),
       temp_time,5)," seconds."))
    CALL echo("*******************************************************")
   ENDIF
 END ;Subroutine
 SUBROUTINE loadorderreviews(order_cnt)
   IF (debug_ind=1)
    SET temp_time = cnvtdatetime(curdate,curtime3)
    CALL echo("*Entering LoadOrderReviews subroutine*")
   ENDIF
   DECLARE numx = i4 WITH protect, noconstant(0)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE pidx = i4 WITH protect, noconstant(0)
   DECLARE oidx = i4 WITH protect, noconstant(0)
   DECLARE loc_idx = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM order_review orev
    WHERE expand(numx,1,order_cnt,orev.order_id,temp->qual[numx].order_id)
    ORDER BY orev.order_id, orev.review_type_flag, orev.updt_dt_tm DESC
    HEAD orev.order_id
     icnt = 0, idx = locateval(loc_idx,1,order_cnt,orev.order_id,temp->qual[loc_idx].order_id)
     IF (idx > 0)
      pidx = temp->qual[idx].person_idx, oidx = temp->qual[idx].order_idx
     ENDIF
    HEAD orev.review_type_flag
     IF (pidx > 0
      AND oidx > 0)
      icnt = (icnt+ 1), stat = alterlist(reply->entity_list[pidx].datalist[oidx].review_list,icnt),
      reply->entity_list[pidx].datalist[oidx].review_list[icnt].review_prsnl_id = orev
      .review_personnel_id,
      reply->entity_list[pidx].datalist[oidx].review_list[icnt].review_type_flag = orev
      .review_type_flag, reply->entity_list[pidx].datalist[oidx].review_list[icnt].
      reviewed_status_flag = orev.reviewed_status_flag, reply->entity_list[pidx].datalist[oidx].
      review_list[icnt].review_dt_tm = orev.review_dt_tm,
      reply->entity_list[pidx].datalist[oidx].review_list[icnt].review_tz = orev.review_tz, reply->
      entity_list[pidx].datalist[oidx].review_list[icnt].review_sequence = orev.review_sequence,
      reply->entity_list[pidx].datalist[oidx].review_list[icnt].action_sequence = orev
      .action_sequence
     ENDIF
    WITH nocounter, expand = 1
   ;end select
   IF (debug_ind=1)
    CALL echo("*Leaving LoadOrderReviews subroutine*")
    CALL echo("*******************************************************")
    CALL echo(build("Time for loading order reviews = ",datetimediff(cnvtdatetime(curdate,curtime3),
       temp_time,5)," seconds."))
    CALL echo("*******************************************************")
   ENDIF
 END ;Subroutine
 IF (debug_ind=1)
  CALL echorecord(request)
  CALL echorecord(temp)
  CALL echorecord(reply)
  CALL echo("*******************************************************")
  CALL echo(build("Total Order Cnt: ",order_cnt))
  CALL echo(build("Total Run Time = ",datetimediff(cnvtdatetime(curdate,curtime3),start_time,5),
    " seconds."))
  CALL echo("*******************************************************")
 ENDIF
 FREE RECORD temp
 SET script_version = "011 02/14/11"
 CALL echo(build("Script Version: ",script_version))
 SET modify = nopredeclare
END GO
