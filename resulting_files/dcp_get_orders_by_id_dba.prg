CREATE PROGRAM dcp_get_orders_by_id:dba
 SET modify = predeclare
 FREE RECORD reply
 RECORD reply(
   1 orders[*]
     2 order_id = f8
     2 encntr_id = f8
     2 person_id = f8
     2 order_status_cd = f8
     2 display_line = vc
     2 order_mnemonic = vc
     2 hna_order_mnemonic = vc
     2 ordered_as_mnemonic = vc
     2 catalog_cd = f8
     2 catalog_type_cd = f8
     2 activity_type_cd = f8
     2 comment_type_mask = i4
     2 order_comment_text = vc
     2 constant_ind = i2
     2 prn_ind = i2
     2 ingredient_ind = i2
     2 need_rx_verify_ind = i2
     2 need_nurse_review_ind = i2
     2 med_order_type_cd = f8
     2 need_renew_ind = i2
     2 core_action_sequence = i4
     2 freq_type_flag = i2
     2 current_start_dt_tm = dq8
     2 current_start_tz = i4
     2 projected_stop_dt_tm = dq8
     2 projected_stop_tz = i4
     2 stop_type_cd = f8
     2 orderable_type_flag = i2
     2 template_order_flag = i2
     2 iv_ind = i2
     2 ref_text_mask = i4
     2 cki = vc
     2 orig_order_dt_tm = dq8
     2 orig_order_tz = i4
     2 order_provider_id = f8
     2 plan_ind = i2
     2 protocol_order_id = f8
     2 warning_level_bit = i4
     2 total_bags_nbr = i4
     2 ivseq_ind = i2
     2 order_ingredient[*]
       3 event_cd = f8
       3 catalog_cd = f8
       3 catalog_type_cd = f8
       3 order_mnemonic = vc
       3 primary_mnemonic = vc
       3 hna_order_mnemonic = vc
       3 ordered_as_mnemonic = vc
       3 ingredient_type_flag = i2
       3 order_detail_display_line = vc
       3 ref_text_mask = i4
       3 cki = vc
       3 active_ind = i2
       3 action_sequence = i4
       3 comp_sequence = i4
       3 synonym_id = f8
       3 include_in_total_volume_flag = i2
       3 freq_cd = f8
       3 strength = f8
       3 strength_unit = f8
       3 volume = f8
       3 volume_unit = f8
       3 freetext_dose = vc
       3 ingredient_rate_conversion_ind = i2
       3 witness_flag = i2
       3 normalized_rate = f8
       3 normalized_rate_unit_cd = f8
       3 normalized_rate_unit_cd_disp = vc
       3 normalized_rate_unit_cd_desc = vc
       3 normalized_rate_unit_cd_mean = vc
       3 display_additives_first_ind = i2
     2 verification_prsnl_id = f8
     2 verification_pos_cd = f8
     2 need_rx_clin_review_flag = i2
     2 last_action_sequence = i4
     2 order_detail[*]
       3 oe_field_display_value = vc
       3 oe_field_dt_tm_value = dq8
       3 oe_field_tz = i4
       3 oe_field_id = f8
       3 oe_field_meaning_id = f8
       3 oe_field_value = f8
   1 reference_list[*]
     2 catalog_cd = f8
     2 ref_task_list[*]
       3 reference_task_id = f8
       3 event_code_list[*]
         4 event_cd = f8
         4 task_assay_cd = f8
         4 required_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE stat = i4 WITH noconstant(0)
 DECLARE log_status(operationname=vc,operationstatus=vc,targetobjectname=vc,targetobjectvalue=vc) =
 null
 DECLARE log_count = i4 WITH noconstant(0)
 SUBROUTINE log_status(operationname,operationstatus,targetobjectname,targetobjectvalue)
   IF ( NOT (validate(reply,0)))
    RETURN
   ENDIF
   SET log_count = size(reply->status_data.subeventstatus,5)
   IF (log_count=1)
    IF (trim(reply->status_data.subeventstatus[1].targetobjectname) > "")
     SET log_count = (log_count+ 1)
    ENDIF
   ELSE
    SET log_count = (log_count+ 1)
   ENDIF
   SET stat = alter(reply->status_data.subeventstatus,log_count)
   SET reply->status_data.subeventstatus[log_count].operationname = operationname
   SET reply->status_data.subeventstatus[log_count].operationstatus = operationstatus
   SET reply->status_data.subeventstatus[log_count].targetobjectname = targetobjectname
   SET reply->status_data.subeventstatus[log_count].targetobjectvalue = targetobjectvalue
 END ;Subroutine
 FREE RECORD wv_temp
 RECORD wv_temp(
   1 order_cnt = i4
   1 orders[*]
     2 order_id = f8
     2 action_cnt = i4
     2 actions[*]
       3 action_sequence = i4
       3 verify_ind = i2
       3 prsnl_id = f8
       3 position_cd = f8
 )
 FREE RECORD wv_protocol_list
 RECORD wv_protocol_list(
   1 orders[*]
     2 order_id = f8
 )
 DECLARE populateordercomments(null) = null
 DECLARE loadorderactions(null) = null
 DECLARE evaluaterxverify(orderid=f8,action=i4,prsnlid=f8(ref),poscd=f8(ref)) = i2
 DECLARE populateverifyindicator(null) = null
 DECLARE setrenewalindicators(null) = null
 DECLARE setencnterlist(null) = null
 DECLARE loadcatalogeventcodes(null) = null
 DECLARE setdefaultrenewdttm(null) = null
 DECLARE loadorderdetails(null) = null
 DECLARE setexistingorderclause(null) = null
 DECLARE loadivprotocolorders(null) = null
 DECLARE setsequenceindicator(null) = null
 DECLARE order_comment_mask = i4 WITH constant(1)
 DECLARE ordercnt = i2 WITH noconstant(0)
 DECLARE ingredcnt = i2 WITH noconstant(0)
 DECLARE protocolcnt = i2 WITH noconstant(0)
 DECLARE seq_counter = i4 WITH noconstant(0)
 DECLARE encntr_it = i4 WITH noconstant(0)
 DECLARE encntr_in_clause = vc WITH noconstant(fillstring(5000," "))
 DECLARE order_clause = vc WITH noconstant(fillstring(5000," "))
 DECLARE order_it = i4 WITH noconstant(0)
 DECLARE renew_look_back = i4 WITH noconstant(24)
 DECLARE default_renew_look_back = i4 WITH noconstant(24)
 DECLARE err_msg = c42 WITH constant("Unable to retrieve valid UAR Code Value(s)")
 DECLARE dstarttime = f8 WITH protect, noconstant(cnvtdatetime(curdate,curtime3))
 DECLARE dtemptime = f8 WITH protect, noconstant(cnvtdatetime(curdate,curtime3))
 DECLARE idebugind = i2 WITH protect, noconstant(0)
 DECLARE current_dt_tm = dq8 WITH protect
 DECLARE default_renew_dt_tm = dq8 WITH protect
 DECLARE order_comment = f8 WITH constant(uar_get_code_by("MEANING",14,"ORD COMMENT"))
 DECLARE everybag = f8 WITH constant(uar_get_code_by("MEANING",4004,"EVERYBAG"))
 DECLARE lab = f8 WITH constant(uar_get_code_by("MEANING",6000,"GENERAL LAB"))
 DECLARE pharmacy = f8 WITH constant(uar_get_code_by("MEANING",6000,"PHARMACY"))
 DECLARE hard_stop = f8 WITH constant(uar_get_code_by("MEANING",4009,"HARD"))
 DECLARE soft_stop = f8 WITH constant(uar_get_code_by("MEANING",4009,"SOFT"))
 DECLARE ordered = f8 WITH constant(uar_get_code_by("MEANING",6004,"ORDERED"))
 DECLARE pending = f8 WITH constant(uar_get_code_by("MEANING",6004,"PENDING"))
 DECLARE suspended = f8 WITH constant(uar_get_code_by("MEANING",6004,"SUSPENDED"))
 DECLARE incomplete = f8 WITH constant(uar_get_code_by("MEANING",6004,"INCOMPLETE"))
 DECLARE inprocess = f8 WITH constant(uar_get_code_by("MEANING",6004,"INPROCESS"))
 DECLARE unscheduled = f8 WITH constant(uar_get_code_by("MEANING",6004,"UNSCHEDULED"))
 DECLARE canceled = f8 WITH constant(uar_get_code_by("MEANING",6004,"CANCELED"))
 DECLARE completed = f8 WITH constant(uar_get_code_by("MEANING",6004,"COMPLETED"))
 DECLARE deleted = f8 WITH constant(uar_get_code_by("MEANING",6004,"DELETED"))
 DECLARE discontinued = f8 WITH constant(uar_get_code_by("MEANING",6004,"DISCONTINUED"))
 DECLARE voidedwrslt = f8 WITH constant(uar_get_code_by("MEANING",6004,"VOIDEDWRSLT"))
 DECLARE future = f8 WITH constant(uar_get_code_by("MEANING",6004,"FUTURE"))
 DECLARE medstudent = f8 WITH constant(uar_get_code_by("MEANING",6004,"MEDSTUDENT"))
 DECLARE pending_rev = f8 WITH constant(uar_get_code_by("MEANING",6004,"PENDING REV"))
 DECLARE transcancel = f8 WITH constant(uar_get_code_by("MEANING",6004,"TRANS/CANCEL"))
 DECLARE order_action = f8 WITH constant(uar_get_code_by("MEANING",6003,"ORDER"))
 DECLARE modify_action = f8 WITH constant(uar_get_code_by("MEANING",6003,"MODIFY"))
 DECLARE activate_action = f8 WITH constant(uar_get_code_by("MEANING",6003,"ACTIVATE"))
 DECLARE iv_med_order = f8 WITH public, constant(uar_get_code_by("MEANING",18309,"IV"))
 DECLARE none = i2 WITH constant(0)
 DECLARE template = i2 WITH constant(1)
 DECLARE protocol = i2 WITH constant(7)
 DECLARE normal_zero = i2 WITH constant(0)
 DECLARE normal_one = i2 WITH constant(1)
 DECLARE multi_ingred = i2 WITH constant(8)
 DECLARE free_text = i2 WITH constant(10)
 DECLARE tpn = i2 WITH constant(11)
 DECLARE normal_order = i2 WITH constant(0)
 DECLARE satellite_med = i2 WITH constant(5)
 IF (((everybag <= 0) OR (((lab <= 0) OR (((pharmacy <= 0) OR (((hard_stop <= 0) OR (((soft_stop <= 0
 ) OR (((canceled <= 0) OR (((completed <= 0) OR (((deleted <= 0) OR (((discontinued <= 0) OR (((
 voidedwrslt <= 0) OR (((future <= 0) OR (((medstudent <= 0) OR (((order_action <= 0) OR (((
 modify_action <= 0) OR (activate_action <= 0)) )) )) )) )) )) )) )) )) )) )) )) )) )) )
  CALL log_status("UAR_GET_CODE_BY","F","CODE_VALUE",err_msg)
  SET reply->status_data.status = "F"
  GO TO uar_failed
 ENDIF
 IF (validate(request->debug_ind))
  IF ((request->debug_ind > 0))
   CALL echo("Debugging Enabled")
   SET idebugind = request->debug_ind
  ENDIF
 ENDIF
 IF (idebugind=2)
  CALL echorecord(request)
 ENDIF
 SET reply->status_data.status = "F"
 SUBROUTINE setdefaultrenewdttm(null)
   SELECT INTO "nl:"
    FROM renew_notification_period rnp
    PLAN (rnp
     WHERE rnp.stop_type_cd=0
      AND rnp.stop_duration=0
      AND rnp.stop_duration_unit_cd=0)
    DETAIL
     default_renew_look_back = cnvtint(rnp.notification_period)
    WITH nocounter
   ;end select
   SET current_dt_tm = cnvtdatetime(curdate,curtime)
   SET interval = build(default_renew_look_back,"h")
   SET default_renew_dt_tm = cnvtlookahead(interval,cnvtdatetime(current_dt_tm))
 END ;Subroutine
 SUBROUTINE setencounterinclause(null)
  IF (encntr_cnt > 0)
   SET encntr_in_clause = build(
    "expand (encntr_it, 1, encntr_cnt, o.encntr_id+0, request->encntr_list[encntr_it].encntr_id)",
    " or o.encntr_id+0=0")
  ELSE
   SET encntr_in_clause = "0=0"
  ENDIF
  IF (idebugind > 0)
   CALL echo(build("encntr_in_clause = ",encntr_in_clause))
  ENDIF
 END ;Subroutine
 SUBROUTINE setexistingorderclause(null)
  IF (ordercnt > 0)
   SET order_clause = build(
    "expand(order_it, 1, orderCnt, o.order_id+0, reply->orders[order_it].order_id)")
  ELSE
   SET order_clause = "1=0"
  ENDIF
  IF (idebugind > 0)
   CALL echo(build("order_clause = ",order_clause))
  ENDIF
 END ;Subroutine
 SUBROUTINE populateordercomments(null)
   IF (size(reply->orders,5) > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(size(reply->orders,5))),
      order_comment oc,
      long_text lt
     PLAN (d
      WHERE band(reply->orders[d.seq].comment_type_mask,order_comment_mask)=order_comment_mask)
      JOIN (oc
      WHERE (oc.order_id=reply->orders[d.seq].order_id)
       AND oc.comment_type_cd=order_comment
       AND (oc.action_sequence=
      (SELECT
       max(oc2.action_sequence)
       FROM order_comment oc2
       WHERE oc2.order_id=oc.order_id
        AND oc2.comment_type_cd=order_comment)))
      JOIN (lt
      WHERE lt.long_text_id=oc.long_text_id)
     DETAIL
      reply->orders[d.seq].order_comment_text = lt.long_text
     WITH nocounter
    ;end select
   ENDIF
 END ;Subroutine
 SUBROUTINE loadcoreactionsequence(null)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(reply->orders,5))),
     order_action oa
    PLAN (d)
     JOIN (oa
     WHERE (oa.order_id=reply->orders[d.seq].order_id))
    DETAIL
     IF (oa.action_sequence=1)
      reply->orders[d.seq].order_provider_id = oa.order_provider_id
     ENDIF
     IF (oa.core_ind=1
      AND (reply->orders[d.seq].core_action_sequence < oa.action_sequence)
      AND oa.action_type_cd IN (order_action, modify_action, activate_action)
      AND oa.action_rejected_ind=0)
      reply->orders[d.seq].core_action_sequence = oa.action_sequence
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE loadorderactions(null)
   DECLARE order_cnt = i4 WITH noconstant(0), protected
   DECLARE action_cnt = i4 WITH noconstant(0), protected
   DECLARE orders_cnt = i4 WITH noconstant(size(reply->orders,5)), protected
   DECLARE expandx = i4 WITH noconstant(0), protected
   DECLARE pos = i4 WITH noconstant(0), protected
   DECLARE nstart = i4 WITH protect, noconstant(1)
   DECLARE nsize = i4 WITH protect, constant(50)
   DECLARE iordercnt = i4 WITH protect, noconstant(size(reply->orders,5))
   DECLARE ntotal = i4 WITH protect, noconstant((ceil((cnvtreal(orders_cnt)/ nsize)) * nsize))
   DECLARE dfuncstarttime = f8 WITH protect, noconstant(cnvtdatetime(curdate,curtime3))
   SET stat = alterlist(reply->orders,ntotal)
   FOR (i = (orders_cnt+ 1) TO ntotal)
     SET reply->orders[i].order_id = reply->orders[orders_cnt].order_id
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
     order_action oa,
     prsnl p
    PLAN (d1
     WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ nsize))))
     JOIN (oa
     WHERE expand(expandx,nstart,(nstart+ (nsize - 1)),oa.order_id,reply->orders[expandx].order_id))
     JOIN (p
     WHERE p.person_id=oa.action_personnel_id)
    ORDER BY oa.order_id, oa.action_sequence DESC
    HEAD REPORT
     order_cnt = 0, action_cnt = 0
    HEAD oa.order_id
     order_cnt = (order_cnt+ 1)
     IF (mod(order_cnt,100)=1)
      stat = alterlist(wv_temp->orders,(order_cnt+ 99))
     ENDIF
     wv_temp->orders[order_cnt].order_id = oa.order_id, action_cnt = 0, verify_ind = 1,
     pos = locateval(expandx,1,size(reply->orders,5),oa.order_id,reply->orders[expandx].order_id)
    DETAIL
     IF ((reply->orders[pos].need_rx_clin_review_flag > 0))
      CASE (reply->orders[pos].need_rx_clin_review_flag)
       OF 2:
        verify_ind = 0
       OF 4:
        verify_ind = 0
       OF 1:
        verify_ind = 1
       OF 3:
        verify_ind = 2
      ENDCASE
     ELSE
      CASE (oa.needs_verify_ind)
       OF 0:
        verify_ind = 0
       OF 3:
        verify_ind = 0
       OF 5:
        verify_ind = 0
       OF 1:
        verify_ind = 1
       OF 4:
        verify_ind = 2
      ENDCASE
     ENDIF
     action_cnt = (action_cnt+ 1)
     IF (mod(action_cnt,10)=1)
      stat = alterlist(wv_temp->orders[order_cnt].actions,(action_cnt+ 9))
     ENDIF
     wv_temp->orders[order_cnt].actions[action_cnt].action_sequence = oa.action_sequence, wv_temp->
     orders[order_cnt].actions[action_cnt].prsnl_id = p.person_id, wv_temp->orders[order_cnt].
     actions[action_cnt].position_cd = p.position_cd,
     wv_temp->orders[order_cnt].actions[action_cnt].verify_ind = verify_ind
    FOOT  oa.order_id
     wv_temp->orders[order_cnt].action_cnt = action_cnt, stat = alterlist(wv_temp->orders[order_cnt].
      actions,action_cnt)
    FOOT REPORT
     wv_temp->order_cnt = order_cnt, stat = alterlist(wv_temp->orders,order_cnt)
    WITH nocounter
   ;end select
   SET stat = alterlist(reply->orders,iordercnt)
   IF (idebugind > 0)
    CALL echo("*******************************************************")
    CALL echo(build("LoadOrderActions Time = ",datetimediff(cnvtdatetime(curdate,curtime3),
       dfuncstarttime,5)))
    CALL echo("*******************************************************")
   ENDIF
 END ;Subroutine
 SUBROUTINE populateverifyindicator(null)
   DECLARE orders_cnt = i4 WITH constant(size(reply->orders,5)), private
   DECLARE x = i4 WITH noconstant(0), private
   DECLARE prsnlid = f8 WITH noconstant(0.0), protected
   DECLARE poscd = f8 WITH noconstant(0.0), protected
   DECLARE dfuncstarttime = f8 WITH protect, noconstant(cnvtdatetime(curdate,curtime3))
   FOR (x = 1 TO orders_cnt)
    SET reply->orders[x].need_rx_verify_ind = evaluaterxverify(reply->orders[x].order_id,- (1),
     prsnlid,poscd)
    IF ((reply->orders[x].need_rx_verify_ind != 0))
     SET reply->orders[x].verification_prsnl_id = prsnlid
     SET reply->orders[x].verification_pos_cd = poscd
    ENDIF
   ENDFOR
   IF (idebugind > 0)
    CALL echo("*******************************************************")
    CALL echo(build("PopulateVerifyIndicator Time = ",datetimediff(cnvtdatetime(curdate,curtime3),
       dfuncstarttime,5)))
    CALL echo("*******************************************************")
   ENDIF
 END ;Subroutine
 SUBROUTINE evaluaterxverify(orderid,action,prsnlid,positioncd)
   DECLARE x = i4 WITH noconstant(0), private
   DECLARE y = i4 WITH noconstant(0), private
   DECLARE verifyind = i4 WITH noconstant(0), private
   SET prsnlid = 0.0
   SET positioncd = 0.0
   FOR (x = 1 TO wv_temp->order_cnt)
     IF ((wv_temp->orders[x].order_id=orderid))
      IF (action < 0)
       SET verifyind = wv_temp->orders[x].actions[1].verify_ind
       SET prsnlid = wv_temp->orders[x].actions[1].prsnl_id
       SET positioncd = wv_temp->orders[x].actions[1].position_cd
      ELSE
       FOR (y = 1 TO wv_temp->orders[x].action_cnt)
         IF ((wv_temp->orders[x].actions[y].action_sequence=action))
          SET verifyind = wv_temp->orders[x].actions[y].verify_ind
          SET prsnlid = wv_temp->orders[x].actions[y].prsnl_id
          SET positioncd = wv_temp->orders[x].actions[y].position_cd
          SET y = (wv_temp->orders[x].action_cnt+ 1)
         ELSEIF ((wv_temp->orders[x].actions[y].action_sequence=action))
          SET y = (wv_temp->orders[x].action_cnt+ 1)
         ENDIF
       ENDFOR
      ENDIF
      SET x = (wv_temp->order_cnt+ 1)
     ELSEIF ((wv_temp->orders[x].order_id > orderid))
      SET x = (wv_temp->order_cnt+ 1)
     ENDIF
   ENDFOR
   RETURN(verifyind)
 END ;Subroutine
 SUBROUTINE setrenewalindicators(null)
   CALL echo("********SetRenewalIndicators********")
   DECLARE x = i4 WITH protect, noconstant(0)
   DECLARE catalogcnt = i4 WITH protect, noconstant(0)
   DECLARE dfuncstarttime = f8 WITH protect, noconstant(cnvtdatetime(curdate,curtime3))
   RECORD renewtemp(
     1 qual[*]
       2 catalog_cd = f8
   )
   SET stat = alterlist(renewtemp->qual,ordercnt)
   FOR (x = 1 TO ordercnt)
    SET catalogcnt = (catalogcnt+ 1)
    SET renewtemp->qual[catalogcnt].catalog_cd = reply->orders[x].catalog_cd
   ENDFOR
   IF (catalogcnt > 0)
    DECLARE y = i4 WITH protect, noconstant(0)
    DECLARE nstart = i4 WITH protect, noconstant(1)
    DECLARE nsize = i4 WITH protect, constant(50)
    DECLARE iordercnt = i4 WITH protect, noconstant(size(renewtemp->qual,5))
    DECLARE ntotal = i4 WITH protect, noconstant((ceil((cnvtreal(catalogcnt)/ nsize)) * nsize))
    SET stat = alterlist(renewtemp->qual,ntotal)
    FOR (i = (catalogcnt+ 1) TO ntotal)
      SET renewtemp->qual[i].catalog_cd = renewtemp->qual[catalogcnt].catalog_cd
    ENDFOR
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
      order_catalog oc,
      renew_notification_period rnp
     PLAN (d1
      WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ nsize))))
      JOIN (oc
      WHERE expand(x,nstart,(nstart+ (nsize - 1)),oc.catalog_cd,renewtemp->qual[x].catalog_cd))
      JOIN (rnp
      WHERE rnp.stop_type_cd=oc.stop_type_cd
       AND rnp.stop_duration=oc.stop_duration
       AND rnp.stop_duration_unit_cd=oc.stop_duration_unit_cd)
     DETAIL
      IF (rnp.stop_type_cd > 0
       AND rnp.stop_duration > 0
       AND rnp.stop_duration_unit_cd > 0)
       renew_look_back = cnvtint(rnp.notification_period), interval = build(renew_look_back,"h"),
       renew_dt_tm = cnvtlookahead(interval,cnvtdatetime(current_dt_tm))
      ELSE
       renew_dt_tm = default_renew_dt_tm
      ENDIF
      FOR (y = 1 TO ordercnt)
        IF ((reply->orders[y].catalog_cd=oc.catalog_cd))
         IF ((reply->orders[y].projected_stop_dt_tm < cnvtdatetime(renew_dt_tm)))
          IF ((reply->orders[y].stop_type_cd=hard_stop))
           reply->orders[y].need_renew_ind = 2
          ELSEIF ((reply->orders[y].stop_type_cd=soft_stop))
           reply->orders[y].need_renew_ind = 1
          ELSE
           reply->orders[y].need_renew_ind = 0
          ENDIF
         ELSE
          reply->orders[y].need_renew_ind = 0
         ENDIF
        ENDIF
      ENDFOR
     WITH nocounter
    ;end select
    SET stat = alterlist(renewtemp->qual,iordercnt)
   ENDIF
   FREE RECORD renewtemp
   IF (idebugind > 0)
    CALL echo("*******************************************************")
    CALL echo(build("SetRenewalIndicators Time = ",datetimediff(cnvtdatetime(curdate,curtime3),
       dfuncstarttime,5)))
    CALL echo("*******************************************************")
   ENDIF
 END ;Subroutine
 SUBROUTINE loadcatalogeventcodes(null)
   CALL echo("********LoadCatalogEventCodes********")
   DECLARE iterator = i4 WITH protect, noconstant(0)
   DECLARE oit = i4 WITH protect, noconstant(0)
   DECLARE oidx = i4 WITH protect, noconstant(0)
   DECLARE nstart = i4 WITH protect, noconstant(1)
   DECLARE nsize = i4 WITH protect, constant(50)
   DECLARE iordercnt = i4 WITH protect, noconstant(size(reply->orders,5))
   DECLARE ntotal = i4 WITH protect, noconstant((ceil((cnvtreal(ordercnt)/ nsize)) * nsize))
   DECLARE dfuncstarttime = f8 WITH protect, noconstant(cnvtdatetime(curdate,curtime3))
   SET stat = alterlist(reply->orders,ntotal)
   FOR (i = (ordercnt+ 1) TO ntotal)
     SET reply->orders[i].order_id = reply->orders[ordercnt].order_id
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
     order_ingredient oi,
     code_value_event_r cver
    PLAN (d1
     WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ nsize))))
     JOIN (oi
     WHERE expand(iterator,nstart,(nstart+ (nsize - 1)),oi.order_id,reply->orders[iterator].order_id)
     )
     JOIN (cver
     WHERE cver.parent_cd=oi.catalog_cd)
    ORDER BY oi.order_id, oi.catalog_cd
    HEAD oi.order_id
     oidx = locateval(oit,1,ordercnt,oi.order_id,reply->orders[oit].order_id), ingredcnt = size(reply
      ->orders[oidx].order_ingredient,5)
    DETAIL
     FOR (i = 1 TO ingredcnt)
       IF ((reply->orders[oidx].order_ingredient[i].catalog_cd=oi.catalog_cd))
        reply->orders[oidx].order_ingredient[i].event_cd = cver.event_cd
       ENDIF
     ENDFOR
    WITH nocounter
   ;end select
   SET stat = alterlist(reply->orders,iordercnt)
   IF (idebugind > 0)
    CALL echo("*******************************************************")
    CALL echo(build("LoadCatalogEventCodes Time = ",datetimediff(cnvtdatetime(curdate,curtime3),
       dfuncstarttime,5)))
    CALL echo("*******************************************************")
   ENDIF
 END ;Subroutine
 SUBROUTINE loadorderdetails(null)
   CALL echo("********LoadOrderDetails********")
   DECLARE iterator = i4 WITH protect, noconstant(0)
   DECLARE ode = i4 WITH protect, noconstant(0)
   DECLARE iorderposidx = i4 WITH protect, noconstant(0)
   DECLARE iodposidx = i4 WITH protect, noconstant(0)
   DECLARE nstart = i4 WITH protect, noconstant(1)
   DECLARE nsize = i4 WITH protect, constant(50)
   DECLARE iordercnt = i4 WITH protect, noconstant(size(reply->orders,5))
   DECLARE ntotal = i4 WITH protect, noconstant((ceil((cnvtreal(ordercnt)/ nsize)) * nsize))
   DECLARE dfuncstarttime = f8 WITH protect, noconstant(cnvtdatetime(curdate,curtime3))
   DECLARE oe_rxroute = i4 WITH constant(2050)
   SET stat = alterlist(reply->orders,ntotal)
   FOR (i = (ordercnt+ 1) TO ntotal)
     SET reply->orders[i].order_id = reply->orders[ordercnt].order_id
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
     order_detail od
    PLAN (d1
     WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ nsize))))
     JOIN (od
     WHERE expand(iterator,nstart,(nstart+ (nsize - 1)),od.order_id,reply->orders[iterator].order_id)
      AND od.oe_field_meaning_id IN (oe_rxroute))
    ORDER BY od.order_id, od.action_sequence
    HEAD od.order_id
     iorderposidx = locateval(ode,1,ordercnt,od.order_id,reply->orders[ode].order_id)
    DETAIL
     IF (od.order_id > 0
      AND iorderposidx != 0)
      stat = alterlist(reply->orders[iorderposidx].order_detail,1), reply->orders[iorderposidx].
      order_detail[0].oe_field_meaning_id = od.oe_field_meaning_id, reply->orders[iorderposidx].
      order_detail[0].oe_field_id = od.oe_field_id,
      reply->orders[iorderposidx].order_detail[0].oe_field_value = od.oe_field_value, reply->orders[
      iorderposidx].order_detail[0].oe_field_display_value = od.oe_field_display_value, reply->
      orders[iorderposidx].order_detail[0].oe_field_dt_tm_value = od.oe_field_dt_tm_value,
      reply->orders[iorderposidx].order_detail[0].oe_field_tz = od.oe_field_tz
     ENDIF
    WITH nocounter
   ;end select
   SET stat = alterlist(reply->orders,iordercnt)
   IF (idebugind > 0)
    CALL echo("*******************************************************")
    CALL echo(build("LoadOrderDetails Time = ",datetimediff(cnvtdatetime(curdate,curtime3),
       dfuncstarttime,5)))
    CALL echo("*******************************************************")
   ENDIF
 END ;Subroutine
 SUBROUTINE loadivprotocolorders(null)
   CALL echo("********LoadIVProtocolOrders********")
   DECLARE x = i4 WITH noconstant(0)
   DECLARE y = i4 WITH noconstant(0)
   DECLARE z = i4 WITH noconstant(0)
   DECLARE nstart = i4 WITH protect, noconstant(1)
   DECLARE nsize = i4 WITH protect, constant(50)
   DECLARE ntotal = i4 WITH protect, noconstant((ceil((cnvtreal(protocolcnt)/ nsize)) * nsize))
   SET stat = alterlist(wv_protocol_list->orders,ntotal)
   FOR (i = (protocolcnt+ 1) TO ntotal)
     SET wv_protocol_list->orders[i].order_id = wv_protocol_list->orders[protocolcnt].order_id
   ENDFOR
   CALL setexistingorderclause(null)
   SELECT INTO "nl:"
    o.order_id
    FROM orders o,
     order_ingredient oi,
     order_catalog_synonym ocs,
     order_catalog oc,
     order_iv_info oiv
    PLAN (o
     WHERE (o.person_id=request->person_id)
      AND ((expand(x,nstart,(nstart+ (nsize - 1)),(o.order_id+ 0),wv_protocol_list->orders[x].
      order_id)
      AND o.template_order_flag=protocol) OR (expand(y,nstart,(nstart+ (nsize - 1)),(o
      .protocol_order_id+ 0),wv_protocol_list->orders[y].order_id)
      AND o.template_order_flag IN (none, template)))
      AND ((parser(encntr_in_clause)) OR (o.encntr_id=0))
      AND  NOT (parser(order_clause)))
     JOIN (oi
     WHERE o.order_id=oi.order_id
      AND o.last_ingred_action_sequence=oi.action_sequence)
     JOIN (ocs
     WHERE oi.synonym_id=ocs.synonym_id)
     JOIN (oc
     WHERE oi.catalog_cd=oc.catalog_cd)
     JOIN (oiv
     WHERE outerjoin(o.order_id)=oiv.order_id)
    ORDER BY o.order_id, oi.synonym_id, oi.comp_sequence,
     oi.action_sequence DESC
    HEAD o.order_id
     ingredcnt = 0, ordercnt = (ordercnt+ 1)
     IF (ordercnt > size(reply->orders,5))
      stat = alterlist(reply->orders,(ordercnt+ 5))
     ENDIF
     reply->orders[ordercnt].order_id = o.order_id, reply->orders[ordercnt].encntr_id = o.encntr_id,
     reply->orders[ordercnt].person_id = o.person_id,
     reply->orders[ordercnt].order_status_cd = o.order_status_cd, reply->orders[ordercnt].
     display_line = trim(o.clinical_display_line), reply->orders[ordercnt].order_mnemonic = o
     .order_mnemonic,
     reply->orders[ordercnt].hna_order_mnemonic = o.hna_order_mnemonic, reply->orders[ordercnt].
     ordered_as_mnemonic = o.ordered_as_mnemonic, reply->orders[ordercnt].catalog_cd = o.catalog_cd,
     reply->orders[ordercnt].catalog_type_cd = o.catalog_type_cd, reply->orders[ordercnt].
     comment_type_mask = o.comment_type_mask, reply->orders[ordercnt].constant_ind = o.constant_ind,
     reply->orders[ordercnt].prn_ind = o.prn_ind, reply->orders[ordercnt].ingredient_ind = o
     .ingredient_ind, reply->orders[ordercnt].need_rx_verify_ind = 0,
     reply->orders[ordercnt].need_rx_clin_review_flag = o.need_rx_clin_review_flag, reply->orders[
     ordercnt].need_nurse_review_ind = o.need_nurse_review_ind, reply->orders[ordercnt].
     med_order_type_cd = o.med_order_type_cd,
     reply->orders[ordercnt].freq_type_flag = o.freq_type_flag, reply->orders[ordercnt].
     current_start_dt_tm = o.current_start_dt_tm, reply->orders[ordercnt].current_start_tz = o
     .current_start_tz,
     reply->orders[ordercnt].projected_stop_dt_tm = o.projected_stop_dt_tm, reply->orders[ordercnt].
     projected_stop_tz = o.projected_stop_tz, reply->orders[ordercnt].stop_type_cd = o.stop_type_cd,
     reply->orders[ordercnt].orderable_type_flag = o.orderable_type_flag, reply->orders[ordercnt].
     template_order_flag = o.template_order_flag, reply->orders[ordercnt].iv_ind = o.iv_ind,
     reply->orders[ordercnt].ref_text_mask = o.ref_text_mask, reply->orders[ordercnt].cki = o.cki,
     reply->orders[ordercnt].orig_order_dt_tm = o.orig_order_dt_tm,
     reply->orders[ordercnt].orig_order_tz = o.orig_order_tz, reply->orders[ordercnt].
     last_action_sequence = o.last_action_sequence, reply->orders[ordercnt].protocol_order_id = o
     .protocol_order_id,
     reply->orders[ordercnt].warning_level_bit = o.warning_level_bit, reply->orders[ordercnt].
     total_bags_nbr = oiv.total_bags_nbr
     IF (o.pathway_catalog_id > 0)
      reply->orders[ordercnt].plan_ind = 1
     ELSE
      reply->orders[ordercnt].plan_ind = 0
     ENDIF
    HEAD oi.synonym_id
     addingredient = 0
     IF (oc.catalog_cd=o.catalog_cd)
      reply->orders[ordercnt].catalog_cd = oc.catalog_cd, reply->orders[ordercnt].catalog_type_cd =
      oc.catalog_type_cd, reply->orders[ordercnt].activity_type_cd = oc.activity_type_cd
     ENDIF
     IF (oi.synonym_id > 0)
      addingredient = 1
     ENDIF
     IF (oi.action_sequence > max_sequence)
      max_sequence = oi.action_sequence
     ENDIF
    HEAD oi.comp_sequence
     IF (addingredient > 0)
      ingredcnt = (ingredcnt+ 1)
      IF (ingredcnt > size(reply->orders[ordercnt].order_ingredient,5))
       stat = alterlist(reply->orders[ordercnt].order_ingredient,(ingredcnt+ 5))
      ENDIF
      reply->orders[ordercnt].order_ingredient[ingredcnt].catalog_cd = oc.catalog_cd, reply->orders[
      ordercnt].order_ingredient[ingredcnt].catalog_type_cd = oi.catalog_type_cd, reply->orders[
      ordercnt].order_ingredient[ingredcnt].primary_mnemonic = oc.primary_mnemonic,
      reply->orders[ordercnt].order_ingredient[ingredcnt].hna_order_mnemonic = oi.hna_order_mnemonic,
      reply->orders[ordercnt].order_ingredient[ingredcnt].ordered_as_mnemonic = oi
      .ordered_as_mnemonic, reply->orders[ordercnt].order_ingredient[ingredcnt].order_mnemonic = oi
      .order_mnemonic,
      reply->orders[ordercnt].order_ingredient[ingredcnt].order_detail_display_line = oi
      .order_detail_display_line, reply->orders[ordercnt].order_ingredient[ingredcnt].
      ingredient_type_flag = oi.ingredient_type_flag, reply->orders[ordercnt].order_ingredient[
      ingredcnt].ref_text_mask = oc.ref_text_mask,
      reply->orders[ordercnt].order_ingredient[ingredcnt].freetext_dose = oi.freetext_dose, reply->
      orders[ordercnt].order_ingredient[ingredcnt].cki = oc.cki, reply->orders[ordercnt].
      order_ingredient[ingredcnt].action_sequence = oi.action_sequence,
      reply->orders[ordercnt].order_ingredient[ingredcnt].comp_sequence = oi.comp_sequence, reply->
      orders[ordercnt].order_ingredient[ingredcnt].synonym_id = oi.synonym_id, reply->orders[ordercnt
      ].order_ingredient[ingredcnt].include_in_total_volume_flag = oi.include_in_total_volume_flag,
      reply->orders[ordercnt].order_ingredient[ingredcnt].freq_cd = oi.freq_cd, reply->orders[
      ordercnt].order_ingredient[ingredcnt].strength = oi.strength, reply->orders[ordercnt].
      order_ingredient[ingredcnt].strength_unit = oi.strength_unit,
      reply->orders[ordercnt].order_ingredient[ingredcnt].volume = oi.volume, reply->orders[ordercnt]
      .order_ingredient[ingredcnt].volume_unit = oi.volume_unit, reply->orders[ordercnt].
      order_ingredient[ingredcnt].normalized_rate = oi.normalized_rate,
      reply->orders[ordercnt].order_ingredient[ingredcnt].normalized_rate_unit_cd = oi
      .normalized_rate_unit_cd, reply->orders[ordercnt].order_ingredient[ingredcnt].
      ingredient_rate_conversion_ind = ocs.ingredient_rate_conversion_ind, reply->orders[ordercnt].
      order_ingredient[ingredcnt].witness_flag = ocs.witness_flag,
      reply->orders[ordercnt].order_ingredient[ingredcnt].display_additives_first_ind = ocs
      .display_additives_first_ind
     ENDIF
     IF (((ocs.ingredient_rate_conversion_ind=1
      AND oi.freq_cd=everybag) OR ((request->titratable_only_ind=0))) )
      bhastitratableingred = 1
     ENDIF
    FOOT  oi.comp_sequence
     IF (addingredient > 0)
      stat = alterlist(reply->orders[ordercnt].order_ingredient,ingredcnt)
     ENDIF
    FOOT  o.order_id
     IF (addingredient != 0
      AND bhastitratableingred=0
      AND ordercnt >= 1)
      stat = alterlist(reply->orders[ordercnt].order_ingredient,0), stat = alterlist(reply->orders,(
       ordercnt - 1)), ordercnt = (ordercnt - 1)
     ELSE
      stat = alterlist(reply->orders,ordercnt)
     ENDIF
     FOR (seq_counter = 1 TO ingredcnt)
       IF ((reply->orders[ordercnt].order_ingredient[seq_counter].action_sequence=max_sequence))
        reply->orders[ordercnt].order_ingredient[seq_counter].active_ind = 1
       ELSE
        reply->orders[ordercnt].order_ingredient[seq_counter].active_ind = 0
       ENDIF
     ENDFOR
     max_sequence = 0
    WITH check
   ;end select
 END ;Subroutine
 SUBROUTINE setsequenceindicator(null)
   CALL echo("********SetSequenceIndicator********")
   IF (ordercnt <= 0)
    RETURN
   ENDIF
   DECLARE iordercnt = i4 WITH protect, noconstant(0)
   RECORD ordersrec(
     1 orders[*]
       2 order_id = f8
   )
   SET stat = alterlist(ordersrec->orders,ordercnt)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(ordercnt))
    WHERE (reply->orders[d.seq].order_id > 0)
    HEAD REPORT
     iordercnt = 0
    DETAIL
     iordercnt = (iordercnt+ 1), ordersrec->orders[iordercnt].order_id = reply->orders[d.seq].
     order_id
    WITH nocounter
   ;end select
   SET stat = alterlist(ordersrec->orders,iordercnt)
   DECLARE oidx = i4 WITH protect, noconstant(0)
   DECLARE oit = i4 WITH protect, noconstant(0)
   DECLARE lidx = i4 WITH protect, noconstant(0)
   DECLARE nstart = i4 WITH protect, noconstant(1)
   DECLARE nsize = i4 WITH protect, constant(50)
   DECLARE ntotal = i4 WITH protect, noconstant((ceil((cnvtreal(iordercnt)/ nsize)) * nsize))
   DECLARE ivsequence_cd = f8 WITH constant(uar_get_code_by("MEANING",30183,"IVSEQUENCE"))
   SET stat = alterlist(ordersrec->orders,ntotal)
   FOR (i = (iordercnt+ 1) TO ntotal)
     SET ordersrec->orders[i].order_id = ordersrec->orders[iordercnt].order_id
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
     act_pw_comp apc,
     pathway pw
    PLAN (d1
     WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ nsize))))
     JOIN (apc
     WHERE expand(lidx,nstart,(nstart+ (nsize - 1)),apc.parent_entity_id,ordersrec->orders[lidx].
      order_id)
      AND apc.parent_entity_name="ORDERS"
      AND apc.active_ind=1)
     JOIN (pw
     WHERE pw.pathway_id=apc.pathway_id)
    ORDER BY apc.parent_entity_id
    HEAD apc.parent_entity_id
     oidx = locateval(oit,1,ordercnt,apc.parent_entity_id,reply->orders[oit].order_id)
    DETAIL
     IF (oidx >= 0
      AND pw.pathway_type_cd=ivsequence_cd)
      reply->orders[oidx].ivseq_ind = 1
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 DECLARE loadorders(null) = null
 DECLARE loadprotocolorders(null) = null
 DECLARE max_sequence = i4 WITH noconstant(0)
 SET reply->status_data.status = "F"
 CALL loadorders(null)
 IF (protocolcnt > 0)
  CALL loadprotocolorders(null)
 ENDIF
 IF (ordercnt > 0)
  CALL setdefaultrenewdttm(null)
  CALL setrenewalindicators(null)
  CALL loadorderactions(null)
  CALL populateverifyindicator(null)
  CALL loadcatalogeventcodes(null)
  CALL populateordercomments(null)
  CALL loadcoreactionsequence(null)
  CALL setsequenceindicator(null)
  CALL loadorderdetails(null)
 ENDIF
 GO TO exit_script
 SUBROUTINE loadorders(null)
   DECLARE reqordcnt = i4 WITH constant(cnvtint(size(request->orders,5)))
   DECLARE x = i4 WITH noconstant(0)
   DECLARE naddingredient = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    o.order_id
    FROM orders o,
     order_ingredient oi,
     order_catalog_synonym ocs,
     order_catalog oc,
     order_iv_info oiv
    PLAN (o
     WHERE expand(x,1,reqordcnt,o.order_id,request->orders[x].order_id))
     JOIN (oi
     WHERE o.order_id=oi.order_id
      AND o.last_ingred_action_sequence=oi.action_sequence)
     JOIN (ocs
     WHERE oi.synonym_id=ocs.synonym_id)
     JOIN (oc
     WHERE oi.catalog_cd=oc.catalog_cd)
     JOIN (oiv
     WHERE outerjoin(o.order_id)=oiv.order_id)
    ORDER BY o.order_id, oi.synonym_id, oi.comp_sequence,
     oi.action_sequence DESC
    HEAD o.order_id
     ingredcnt = 0, ordercnt = (ordercnt+ 1)
     IF (ordercnt > size(reply->orders,5))
      stat = alterlist(reply->orders,(ordercnt+ 5))
     ENDIF
     reply->orders[ordercnt].order_id = o.order_id, reply->orders[ordercnt].encntr_id = o.encntr_id,
     reply->orders[ordercnt].person_id = o.person_id,
     reply->orders[ordercnt].order_status_cd = o.order_status_cd, reply->orders[ordercnt].
     display_line = trim(o.clinical_display_line), reply->orders[ordercnt].order_mnemonic = o
     .order_mnemonic,
     reply->orders[ordercnt].hna_order_mnemonic = o.hna_order_mnemonic, reply->orders[ordercnt].
     ordered_as_mnemonic = o.ordered_as_mnemonic, reply->orders[ordercnt].catalog_cd = o.catalog_cd,
     reply->orders[ordercnt].catalog_type_cd = o.catalog_type_cd, reply->orders[ordercnt].
     comment_type_mask = o.comment_type_mask, reply->orders[ordercnt].constant_ind = o.constant_ind,
     reply->orders[ordercnt].prn_ind = o.prn_ind, reply->orders[ordercnt].ingredient_ind = o
     .ingredient_ind, reply->orders[ordercnt].need_rx_verify_ind = 0,
     reply->orders[ordercnt].need_rx_clin_review_flag = o.need_rx_clin_review_flag, reply->orders[
     ordercnt].need_nurse_review_ind = o.need_nurse_review_ind, reply->orders[ordercnt].
     med_order_type_cd = o.med_order_type_cd,
     reply->orders[ordercnt].freq_type_flag = o.freq_type_flag, reply->orders[ordercnt].
     current_start_dt_tm = o.current_start_dt_tm, reply->orders[ordercnt].current_start_tz = o
     .current_start_tz,
     reply->orders[ordercnt].projected_stop_dt_tm = o.projected_stop_dt_tm, reply->orders[ordercnt].
     projected_stop_tz = o.projected_stop_tz, reply->orders[ordercnt].stop_type_cd = o.stop_type_cd,
     reply->orders[ordercnt].orderable_type_flag = o.orderable_type_flag, reply->orders[ordercnt].
     template_order_flag = o.template_order_flag, reply->orders[ordercnt].iv_ind = o.iv_ind,
     reply->orders[ordercnt].ref_text_mask = o.ref_text_mask, reply->orders[ordercnt].cki = o.cki,
     reply->orders[ordercnt].orig_order_dt_tm = o.orig_order_dt_tm,
     reply->orders[ordercnt].orig_order_tz = o.orig_order_tz, reply->orders[ordercnt].
     last_action_sequence = o.last_action_sequence, reply->orders[ordercnt].total_bags_nbr = oiv
     .total_bags_nbr,
     reply->orders[ordercnt].protocol_order_id = o.protocol_order_id, reply->orders[ordercnt].
     warning_level_bit = o.warning_level_bit
     IF (o.pathway_catalog_id > 0)
      reply->orders[ordercnt].plan_ind = 1
     ELSE
      reply->orders[ordercnt].plan_ind = 0
     ENDIF
     IF (((o.protocol_order_id > 0) OR (o.template_order_flag=protocol)) )
      protocolcnt = (protocolcnt+ 1)
      IF (mod(protocolcnt,10)=1)
       stat = alterlist(wv_protocol_list->orders,(protocolcnt+ 9))
      ENDIF
      IF (o.protocol_order_id > 0)
       wv_protocol_list->orders[protocolcnt].order_id = o.protocol_order_id
      ELSE
       wv_protocol_list->orders[protocolcnt].order_id = o.order_id
      ENDIF
     ENDIF
    HEAD oi.synonym_id
     naddingredient = 0
     IF (oc.catalog_cd=o.catalog_cd)
      reply->orders[ordercnt].catalog_cd = oc.catalog_cd, reply->orders[ordercnt].catalog_type_cd =
      oc.catalog_type_cd, reply->orders[ordercnt].activity_type_cd = oc.activity_type_cd
     ENDIF
     IF (oi.synonym_id > 0)
      naddingredient = 1
     ENDIF
     IF (oi.action_sequence > max_sequence)
      max_sequence = oi.action_sequence
     ENDIF
    HEAD oi.comp_sequence
     IF (naddingredient > 0)
      ingredcnt = (ingredcnt+ 1)
      IF (ingredcnt > size(reply->orders[ordercnt].order_ingredient,5))
       stat = alterlist(reply->orders[ordercnt].order_ingredient,(ingredcnt+ 5))
      ENDIF
      reply->orders[ordercnt].order_ingredient[ingredcnt].catalog_cd = oc.catalog_cd, reply->orders[
      ordercnt].order_ingredient[ingredcnt].catalog_type_cd = oi.catalog_type_cd, reply->orders[
      ordercnt].order_ingredient[ingredcnt].primary_mnemonic = oc.primary_mnemonic,
      reply->orders[ordercnt].order_ingredient[ingredcnt].hna_order_mnemonic = oi.hna_order_mnemonic,
      reply->orders[ordercnt].order_ingredient[ingredcnt].ordered_as_mnemonic = oi
      .ordered_as_mnemonic, reply->orders[ordercnt].order_ingredient[ingredcnt].order_mnemonic = oi
      .order_mnemonic,
      reply->orders[ordercnt].order_ingredient[ingredcnt].order_detail_display_line = oi
      .order_detail_display_line, reply->orders[ordercnt].order_ingredient[ingredcnt].
      ingredient_type_flag = oi.ingredient_type_flag, reply->orders[ordercnt].order_ingredient[
      ingredcnt].ref_text_mask = oc.ref_text_mask,
      reply->orders[ordercnt].order_ingredient[ingredcnt].freetext_dose = oi.freetext_dose, reply->
      orders[ordercnt].order_ingredient[ingredcnt].cki = oc.cki, reply->orders[ordercnt].
      order_ingredient[ingredcnt].action_sequence = oi.action_sequence,
      reply->orders[ordercnt].order_ingredient[ingredcnt].comp_sequence = oi.comp_sequence, reply->
      orders[ordercnt].order_ingredient[ingredcnt].synonym_id = oi.synonym_id, reply->orders[ordercnt
      ].order_ingredient[ingredcnt].include_in_total_volume_flag = oi.include_in_total_volume_flag,
      reply->orders[ordercnt].order_ingredient[ingredcnt].freq_cd = oi.freq_cd, reply->orders[
      ordercnt].order_ingredient[ingredcnt].strength = oi.strength, reply->orders[ordercnt].
      order_ingredient[ingredcnt].strength_unit = oi.strength_unit,
      reply->orders[ordercnt].order_ingredient[ingredcnt].volume = oi.volume, reply->orders[ordercnt]
      .order_ingredient[ingredcnt].volume_unit = oi.volume_unit, reply->orders[ordercnt].
      order_ingredient[ingredcnt].normalized_rate = oi.normalized_rate,
      reply->orders[ordercnt].order_ingredient[ingredcnt].normalized_rate_unit_cd = oi
      .normalized_rate_unit_cd, reply->orders[ordercnt].order_ingredient[ingredcnt].
      ingredient_rate_conversion_ind = ocs.ingredient_rate_conversion_ind, reply->orders[ordercnt].
      order_ingredient[ingredcnt].witness_flag = ocs.witness_flag,
      reply->orders[ordercnt].order_ingredient[ingredcnt].normalized_rate = oi.normalized_rate, reply
      ->orders[ordercnt].order_ingredient[ingredcnt].normalized_rate_unit_cd = oi
      .normalized_rate_unit_cd, reply->orders[ordercnt].order_ingredient[ingredcnt].
      ingredient_rate_conversion_ind = ocs.ingredient_rate_conversion_ind
     ENDIF
    FOOT  oi.comp_sequence
     IF (naddingredient > 0)
      stat = alterlist(reply->orders[ordercnt].order_ingredient,ingredcnt)
     ENDIF
    FOOT  o.order_id
     stat = alterlist(reply->orders,ordercnt)
     FOR (seq_counter = 1 TO ingredcnt)
       IF ((reply->orders[ordercnt].order_ingredient[seq_counter].action_sequence=max_sequence))
        reply->orders[ordercnt].order_ingredient[seq_counter].active_ind = 1
       ELSE
        reply->orders[ordercnt].order_ingredient[seq_counter].active_ind = 0
       ENDIF
     ENDFOR
     max_sequence = 0
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE loadprotocolorders(null)
   DECLARE x = i4 WITH noconstant(0)
   DECLARE y = i4 WITH noconstant(0)
   DECLARE z = i4 WITH noconstant(0)
   DECLARE nstart = i4 WITH protect, noconstant(1)
   DECLARE nsize = i4 WITH protect, constant(50)
   DECLARE ntotal = i4 WITH protect, noconstant((ceil((cnvtreal(protocolcnt)/ nsize)) * nsize))
   DECLARE naddingredient = i4 WITH protect, noconstant(0)
   SET stat = alterlist(wv_protocol_list->orders,ntotal)
   FOR (i = (protocolcnt+ 1) TO ntotal)
     SET wv_protocol_list->orders[i].order_id = wv_protocol_list->orders[protocolcnt].order_id
   ENDFOR
   CALL setexistingorderclause(null)
   SELECT INTO "nl:"
    o.order_id
    FROM orders o,
     order_ingredient oi,
     order_catalog_synonym ocs,
     order_catalog oc,
     order_iv_info oiv
    PLAN (o
     WHERE ((expand(x,nstart,(nstart+ (nsize - 1)),(o.order_id+ 0),wv_protocol_list->orders[x].
      order_id)) OR (expand(y,nstart,(nstart+ (nsize - 1)),(o.protocol_order_id+ 0),wv_protocol_list
      ->orders[y].order_id)))
      AND  NOT (parser(order_clause)))
     JOIN (oi
     WHERE o.order_id=oi.order_id
      AND o.last_ingred_action_sequence=oi.action_sequence)
     JOIN (ocs
     WHERE oi.synonym_id=ocs.synonym_id)
     JOIN (oc
     WHERE oi.catalog_cd=oc.catalog_cd)
     JOIN (oiv
     WHERE outerjoin(o.order_id)=oiv.order_id)
    ORDER BY o.order_id, oi.synonym_id, oi.comp_sequence,
     oi.action_sequence DESC
    HEAD o.order_id
     ingredcnt = 0, ordercnt = (ordercnt+ 1)
     IF (ordercnt > size(reply->orders,5))
      stat = alterlist(reply->orders,(ordercnt+ 5))
     ENDIF
     reply->orders[ordercnt].order_id = o.order_id, reply->orders[ordercnt].encntr_id = o.encntr_id,
     reply->orders[ordercnt].person_id = o.person_id,
     reply->orders[ordercnt].order_status_cd = o.order_status_cd, reply->orders[ordercnt].
     display_line = trim(o.clinical_display_line), reply->orders[ordercnt].order_mnemonic = o
     .order_mnemonic,
     reply->orders[ordercnt].hna_order_mnemonic = o.hna_order_mnemonic, reply->orders[ordercnt].
     ordered_as_mnemonic = o.ordered_as_mnemonic, reply->orders[ordercnt].catalog_cd = o.catalog_cd,
     reply->orders[ordercnt].catalog_type_cd = o.catalog_type_cd, reply->orders[ordercnt].
     comment_type_mask = o.comment_type_mask, reply->orders[ordercnt].constant_ind = o.constant_ind,
     reply->orders[ordercnt].prn_ind = o.prn_ind, reply->orders[ordercnt].ingredient_ind = o
     .ingredient_ind, reply->orders[ordercnt].need_rx_verify_ind = 0,
     reply->orders[ordercnt].need_rx_clin_review_flag = o.need_rx_clin_review_flag, reply->orders[
     ordercnt].need_nurse_review_ind = o.need_nurse_review_ind, reply->orders[ordercnt].
     med_order_type_cd = o.med_order_type_cd,
     reply->orders[ordercnt].freq_type_flag = o.freq_type_flag, reply->orders[ordercnt].
     current_start_dt_tm = o.current_start_dt_tm, reply->orders[ordercnt].current_start_tz = o
     .current_start_tz,
     reply->orders[ordercnt].projected_stop_dt_tm = o.projected_stop_dt_tm, reply->orders[ordercnt].
     projected_stop_tz = o.projected_stop_tz, reply->orders[ordercnt].stop_type_cd = o.stop_type_cd,
     reply->orders[ordercnt].orderable_type_flag = o.orderable_type_flag, reply->orders[ordercnt].
     template_order_flag = o.template_order_flag, reply->orders[ordercnt].iv_ind = o.iv_ind,
     reply->orders[ordercnt].ref_text_mask = o.ref_text_mask, reply->orders[ordercnt].cki = o.cki,
     reply->orders[ordercnt].orig_order_dt_tm = o.orig_order_dt_tm,
     reply->orders[ordercnt].orig_order_tz = o.orig_order_tz, reply->orders[ordercnt].
     last_action_sequence = o.last_action_sequence, reply->orders[ordercnt].protocol_order_id = o
     .protocol_order_id,
     reply->orders[ordercnt].warning_level_bit = o.warning_level_bit, reply->orders[ordercnt].
     total_bags_nbr = oiv.total_bags_nbr
     IF (o.pathway_catalog_id > 0)
      reply->orders[ordercnt].plan_ind = 1
     ELSE
      reply->orders[ordercnt].plan_ind = 0
     ENDIF
    HEAD oi.synonym_id
     naddingredient = 0
     IF (oc.catalog_cd=o.catalog_cd)
      reply->orders[ordercnt].catalog_cd = oc.catalog_cd, reply->orders[ordercnt].catalog_type_cd =
      oc.catalog_type_cd, reply->orders[ordercnt].activity_type_cd = oc.activity_type_cd
     ENDIF
     IF (oi.synonym_id > 0)
      naddingredient = 1
     ENDIF
     IF (oi.action_sequence > max_sequence)
      max_sequence = oi.action_sequence
     ENDIF
    HEAD oi.comp_sequence
     IF (naddingredient > 0)
      ingredcnt = (ingredcnt+ 1)
      IF (ingredcnt > size(reply->orders[ordercnt].order_ingredient,5))
       stat = alterlist(reply->orders[ordercnt].order_ingredient,(ingredcnt+ 5))
      ENDIF
      reply->orders[ordercnt].order_ingredient[ingredcnt].catalog_cd = oc.catalog_cd, reply->orders[
      ordercnt].order_ingredient[ingredcnt].catalog_type_cd = oi.catalog_type_cd, reply->orders[
      ordercnt].order_ingredient[ingredcnt].primary_mnemonic = oc.primary_mnemonic,
      reply->orders[ordercnt].order_ingredient[ingredcnt].hna_order_mnemonic = oi.hna_order_mnemonic,
      reply->orders[ordercnt].order_ingredient[ingredcnt].ordered_as_mnemonic = oi
      .ordered_as_mnemonic, reply->orders[ordercnt].order_ingredient[ingredcnt].order_mnemonic = oi
      .order_mnemonic,
      reply->orders[ordercnt].order_ingredient[ingredcnt].order_detail_display_line = oi
      .order_detail_display_line, reply->orders[ordercnt].order_ingredient[ingredcnt].
      ingredient_type_flag = oi.ingredient_type_flag, reply->orders[ordercnt].order_ingredient[
      ingredcnt].ref_text_mask = oc.ref_text_mask,
      reply->orders[ordercnt].order_ingredient[ingredcnt].freetext_dose = oi.freetext_dose, reply->
      orders[ordercnt].order_ingredient[ingredcnt].cki = oc.cki, reply->orders[ordercnt].
      order_ingredient[ingredcnt].action_sequence = oi.action_sequence,
      reply->orders[ordercnt].order_ingredient[ingredcnt].comp_sequence = oi.comp_sequence, reply->
      orders[ordercnt].order_ingredient[ingredcnt].synonym_id = oi.synonym_id, reply->orders[ordercnt
      ].order_ingredient[ingredcnt].include_in_total_volume_flag = oi.include_in_total_volume_flag,
      reply->orders[ordercnt].order_ingredient[ingredcnt].freq_cd = oi.freq_cd, reply->orders[
      ordercnt].order_ingredient[ingredcnt].strength = oi.strength, reply->orders[ordercnt].
      order_ingredient[ingredcnt].strength_unit = oi.strength_unit,
      reply->orders[ordercnt].order_ingredient[ingredcnt].volume = oi.volume, reply->orders[ordercnt]
      .order_ingredient[ingredcnt].volume_unit = oi.volume_unit, reply->orders[ordercnt].
      order_ingredient[ingredcnt].normalized_rate = oi.normalized_rate,
      reply->orders[ordercnt].order_ingredient[ingredcnt].normalized_rate_unit_cd = oi
      .normalized_rate_unit_cd, reply->orders[ordercnt].order_ingredient[ingredcnt].
      ingredient_rate_conversion_ind = ocs.ingredient_rate_conversion_ind, reply->orders[ordercnt].
      order_ingredient[ingredcnt].witness_flag = ocs.witness_flag,
      reply->orders[ordercnt].order_ingredient[ingredcnt].normalized_rate = oi.normalized_rate, reply
      ->orders[ordercnt].order_ingredient[ingredcnt].normalized_rate_unit_cd = oi
      .normalized_rate_unit_cd, reply->orders[ordercnt].order_ingredient[ingredcnt].
      ingredient_rate_conversion_ind = ocs.ingredient_rate_conversion_ind
     ENDIF
    FOOT  oi.comp_sequence
     IF (naddingredient > 0)
      stat = alterlist(reply->orders[ordercnt].order_ingredient,ingredcnt)
     ENDIF
    FOOT  o.order_id
     stat = alterlist(reply->orders,ordercnt)
     FOR (seq_counter = 1 TO ingredcnt)
       IF ((reply->orders[ordercnt].order_ingredient[seq_counter].action_sequence=max_sequence))
        reply->orders[ordercnt].order_ingredient[seq_counter].active_ind = 1
       ELSE
        reply->orders[ordercnt].order_ingredient[seq_counter].active_ind = 0
       ENDIF
     ENDFOR
     max_sequence = 0
    WITH nocounter
   ;end select
 END ;Subroutine
#exit_script
 IF (ordercnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 SET modify = nopredeclare
END GO
