CREATE PROGRAM dcp_get_working_view_orders:dba
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
     2 order_ingredient[*]
       3 event_cd = f8
       3 event_cd_disp = vc
       3 event_cd_desc = vc
       3 event_cd_mean = vc
       3 catalog_cd = f8
       3 catalog_cd_disp = vc
       3 primary_mnemonic = vc
       3 hna_order_mnemonic = vc
       3 ordered_as_mnemonic = vc
       3 ingredient_type_flag = i2
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
       3 oe_field_meaning_id = f8
       3 oe_field_id = f8
       3 oe_field_value = f8
   1 non_iv_orders[*]
     2 order_id = f8
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
 FREE SET wv_temp
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
 DECLARE loadorderactions(null) = null
 DECLARE evaluaterxverify(orderid=f8,action=i4,prsnlid=f8(ref),poscd=f8(ref)) = i2
 DECLARE populateverifyindicator(null) = null
 DECLARE setrenewalindicators(null) = null
 DECLARE loadcatalogeventcodes(null) = null
 DECLARE loadorderdetails(null) = null
 DECLARE setexistingorderclause(null) = null
 SET reply->status_data.status = "F"
 DECLARE order_comment_cd = f8 WITH constant(uar_get_code_by("MEANING",14,"ORD COMMENT"))
 DECLARE order_comment_mask = i4 WITH constant(1)
 DECLARE ordercnt = i2 WITH noconstant(0)
 DECLARE protocolcnt = i2 WITH noconstant(0)
 DECLARE ingredcnt = i2 WITH noconstant(0)
 DECLARE reflistcnt = i2 WITH noconstant(0)
 DECLARE reftasklistcnt = i2 WITH noconstant(0)
 DECLARE eventcdlistcnt = i2 WITH noconstant(0)
 DECLARE medswithtaskscnt = i2 WITH noconstant(0)
 DECLARE non_iv_order_cnt = i2 WITH noconstant(0)
 DECLARE taskcnt = i2 WITH noconstant(0)
 DECLARE addorder = i2 WITH noconstant(0)
 DECLARE addingredient = i2 WITH noconstant(0)
 DECLARE bhastitratableingred = i2 WITH noconstant(0)
 DECLARE zero_ind = i2 WITH noconstant(0)
 DECLARE encntr_cnt = i4 WITH constant(cnvtint(size(request->encntr_list,5)))
 DECLARE order_status_cnt = i4 WITH constant(cnvtint(size(request->order_status_list,5)))
 DECLARE event_cd_cnt = i4 WITH constant(cnvtint(size(request->event_cd_list,5)))
 DECLARE haseventcdineventcdlist = i2 WITH noconstant(0)
 DECLARE alleventcdineventcdlist = i2 WITH noconstant(0)
 DECLARE event_cd_counter = i2 WITH noconstant(0)
 DECLARE max_sequence = i4 WITH noconstant(0)
 DECLARE seq_counter = i4 WITH noconstant(0)
 DECLARE orders_with_tasks_clause = vc WITH noconstant(fillstring(5000," "))
 DECLARE order_clause = vc WITH noconstant(fillstring(5000," "))
 DECLARE order_it = i4 WITH noconstant(0)
 DECLARE everybag_cd = f8 WITH constant(uar_get_code_by("MEANING",4004,"EVERYBAG"))
 DECLARE lab_cd = f8 WITH constant(uar_get_code_by("MEANING",6000,"GENERAL LAB"))
 DECLARE pharmacy_cd = f8 WITH constant(uar_get_code_by("MEANING",6000,"PHARMACY"))
 DECLARE hard_stop_cd = f8 WITH constant(uar_get_code_by("MEANING",4009,"HARD"))
 DECLARE soft_stop_cd = f8 WITH constant(uar_get_code_by("MEANING",4009,"SOFT"))
 DECLARE canceled_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"CANCELED"))
 DECLARE completed_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"COMPLETED"))
 DECLARE deleted_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"DELETED"))
 DECLARE discontinued_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"DISCONTINUED"))
 DECLARE trans_cancel_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"TRANS/CANCEL"))
 DECLARE voidedwrslt_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"VOIDEDWRSLT"))
 DECLARE future_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"FUTURE"))
 DECLARE med_stud_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"MEDSTUDENT"))
 DECLARE renew_look_back = i4 WITH noconstant(24)
 DECLARE default_renew_look_back = i4 WITH noconstant(24)
 DECLARE order_action_type_cd = f8 WITH constant(uar_get_code_by("MEANING",6003,"ORDER"))
 DECLARE modify_action_type_cd = f8 WITH constant(uar_get_code_by("MEANING",6003,"MODIFY"))
 DECLARE activate_action_type_cd = f8 WITH constant(uar_get_code_by("MEANING",6003,"ACTIVATE"))
 DECLARE err_msg = c42 WITH constant("Unable to retrieve valid UAR Code Value(s)")
 DECLARE med_order_iv_type_cd = f8 WITH public, constant(uar_get_code_by("MEANING",18309,"IV"))
 IF (((everybag_cd <= 0) OR (((lab_cd <= 0) OR (((pharmacy_cd <= 0) OR (((hard_stop_cd <= 0) OR (((
 soft_stop_cd <= 0) OR (((canceled_cd <= 0) OR (((completed_cd <= 0) OR (((deleted_cd <= 0) OR (((
 discontinued_cd <= 0) OR (((trans_cancel_cd <= 0) OR (((voidedwrslt_cd <= 0) OR (((future_cd <= 0)
  OR (((med_stud_cd <= 0) OR (((order_action_type_cd <= 0) OR (((modify_action_type_cd <= 0) OR (
 activate_action_type_cd <= 0)) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )
  CALL log_status("UAR_GET_CODE_BY","F","CODE_VALUE",err_msg)
  SET reply->status_data.status = "F"
  GO TO uar_failed
 ENDIF
 DECLARE dstarttime = f8 WITH protect, noconstant(cnvtdatetime(curdate,curtime3))
 DECLARE dtemptime = f8 WITH protect, noconstant(cnvtdatetime(curdate,curtime3))
 DECLARE idebugind = i2 WITH protect, noconstant(0)
 DECLARE slastmod = c14 WITH protect, noconstant("008 12/10/2009")
 RECORD medswithtasks_rec(
   1 orders[*]
     2 order_id = f8
 )
 FREE RECORD wv_protocol_list
 RECORD wv_protocol_list(
   1 orders[*]
     2 order_id = f8
 )
 IF (validate(request->debug_ind))
  IF ((request->debug_ind > 0))
   CALL echo("Debugging Enabled")
   SET idebugind = request->debug_ind
  ENDIF
 ENDIF
 IF (idebugind=2)
  CALL echorecord(request)
 ENDIF
 SET begin_dt_tm = cnvtdatetime(request->start_dt_tm)
 IF (idebugind > 0)
  CALL echo(build("begin_dt_tm = ",format(begin_dt_tm,";;Q")))
 ENDIF
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
 DECLARE catalog_clause = vc WITH noconstant(fillstring(5000," "))
 IF (event_cd_cnt=0)
  SET catalog_clause = " o.catalog_type_cd = pharmacy_cd"
 ELSEIF (event_cd_cnt > 0
  AND (request->only_load_lab_orders=1))
  SET catalog_clause = " o.catalog_type_cd = lab_cd"
 ELSEIF (event_cd_cnt > 0
  AND (request->only_load_lab_orders=0))
  SET catalog_clause = " o.catalog_type_cd != lab_cd"
 ENDIF
 IF (idebugind > 0)
  CALL echo(build("catalog_clause = ",catalog_clause))
 ENDIF
 DECLARE encntr_in_clause = vc WITH noconstant(fillstring(5000," "))
 DECLARE encntr_it = i4 WITH noconstant(0)
 IF (encntr_cnt > 0)
  SET encntr_in_clause = build(
   "expand (encntr_it, 1, encntr_cnt, o.encntr_id, request->encntr_list[encntr_it].encntr_id)",
   " or o.encntr_id=0")
 ELSE
  SET encntr_in_clause = "0=0"
 ENDIF
 IF (idebugind > 0)
  CALL echo(build("encntr_in_clause = ",encntr_in_clause))
 ENDIF
 DECLARE order_status_in_clause = vc WITH noconstant(fillstring(5000," "))
 IF (order_status_cnt > 0)
  SET order_status_in_clause = concat(" o.order_status_cd in (",trim(cnvtstring(request->
     order_status_list[1].order_status_cd)))
  FOR (cnt = 2 TO order_status_cnt)
    SET order_status_in_clause = concat(trim(order_status_in_clause),",",trim(cnvtstring(request->
       order_status_list[cnt].order_status_cd)))
  ENDFOR
  SET order_status_in_clause = concat(trim(order_status_in_clause),")")
 ELSEIF (order_status_cnt=0)
  SET order_status_in_clause = concat(trim(order_status_in_clause),"0=0")
 ENDIF
 IF (idebugind > 0)
  CALL echo(build("order_status_in_clause = ",order_status_in_clause))
 ENDIF
 SET orders_with_tasks_clause = concat(trim(orders_with_tasks_clause),"0=0")
 SET dtemptime = cnvtdatetime(curdate,curtime3)
 SELECT
  IF (event_cd_cnt=0)
   PLAN (o
    WHERE (request->start_dt_tm != request->end_dt_tm)
     AND (o.person_id=request->person_id)
     AND o.projected_stop_dt_tm >= cnvtdatetime(begin_dt_tm)
     AND parser(catalog_clause)
     AND ((o.template_order_id+ 0)=0)
     AND ((o.order_status_cd+ 0) IN (canceled_cd, completed_cd, discontinued_cd, voidedwrslt_cd))
     AND ((o.template_order_flag+ 0) IN (0, 1, 4))
     AND ((o.orderable_type_flag+ 0) IN (0, 1, 8, 10, 11))
     AND parser(encntr_in_clause)
     AND ((o.current_start_dt_tm <= cnvtdatetime(request->end_dt_tm)) OR ((request->end_dt_tm=0)))
     AND o.orig_ord_as_flag IN (0, 5)
     AND o.med_order_type_cd=med_order_iv_type_cd)
    JOIN (oi
    WHERE o.order_id=oi.order_id
     AND o.last_ingred_action_sequence=oi.action_sequence
     AND oi.freq_cd=everybag_cd)
    JOIN (ocs
    WHERE oi.synonym_id=ocs.synonym_id)
    JOIN (oc
    WHERE oi.catalog_cd=oc.catalog_cd)
  ELSE
   PLAN (o
    WHERE (request->start_dt_tm != request->end_dt_tm)
     AND (o.person_id=request->person_id)
     AND o.projected_stop_dt_tm >= cnvtdatetime(begin_dt_tm)
     AND parser(catalog_clause)
     AND ((o.template_order_id+ 0)=0)
     AND ((o.order_status_cd+ 0) IN (canceled_cd, completed_cd, discontinued_cd, voidedwrslt_cd))
     AND ((o.template_order_flag+ 0) IN (0, 1, 4))
     AND ((o.orderable_type_flag+ 0) IN (0, 1, 8, 10, 11))
     AND parser(encntr_in_clause)
     AND ((o.current_start_dt_tm <= cnvtdatetime(request->end_dt_tm)) OR ((request->end_dt_tm=0)))
     AND o.orig_ord_as_flag IN (0, 5)
     AND o.med_order_type_cd != med_order_iv_type_cd)
    JOIN (oi
    WHERE outerjoin(o.order_id)=oi.order_id
     AND outerjoin(o.last_ingred_action_sequence)=oi.action_sequence)
    JOIN (ocs
    WHERE outerjoin(oi.synonym_id)=ocs.synonym_id)
    JOIN (oc
    WHERE outerjoin(oi.catalog_cd)=oc.catalog_cd)
  ENDIF
  INTO "nl:"
  o.order_id
  FROM orders o,
   order_ingredient oi,
   order_catalog_synonym ocs,
   order_catalog oc
  ORDER BY o.order_id, oi.synonym_id, oi.action_sequence DESC
  HEAD REPORT
   ordercnt = 0
  HEAD o.order_id
   addorder = 0, ingredcnt = 0, bhastitratableingred = 0
   IF (((parser(order_status_in_clause)) OR (o.protocol_order_id > 0))
    AND ((o.template_order_flag IN (1, 0)
    AND ((o.current_start_dt_tm <= cnvtdatetime(request->end_dt_tm)) OR ((request->end_dt_tm=0)))
    AND ((o.projected_stop_dt_tm=null) OR (((o.projected_stop_dt_tm >= cnvtdatetime(request->
    start_dt_tm)) OR (o.stop_type_cd=soft_stop_cd)) )) ) OR (o.template_order_flag=4
    AND ((o.current_start_dt_tm <= cnvtdatetime(request->end_dt_tm)) OR ((request->end_dt_tm=0)))
    AND ((o.projected_stop_dt_tm=null) OR (o.projected_stop_dt_tm >= cnvtdatetime(request->
    start_dt_tm))) )) )
    addorder = 1, ordercnt = (ordercnt+ 1)
    IF (ordercnt > size(reply->orders,5))
     stat = alterlist(reply->orders,(ordercnt+ 5))
    ENDIF
    reply->orders[ordercnt].order_id = o.order_id, reply->orders[ordercnt].encntr_id = o.encntr_id,
    reply->orders[ordercnt].person_id = o.person_id,
    reply->orders[ordercnt].order_status_cd = o.order_status_cd, reply->orders[ordercnt].display_line
     = trim(o.clinical_display_line), reply->orders[ordercnt].order_mnemonic = o.order_mnemonic,
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
    reply->orders[ordercnt].warning_level_bit = o.warning_level_bit
    IF (o.pathway_catalog_id > 0)
     reply->orders[ordercnt].plan_ind = 1
    ELSE
     reply->orders[ordercnt].plan_ind = 0
    ENDIF
    IF (o.protocol_order_id > 0)
     protocolcnt = (protocolcnt+ 1)
     IF (mod(protocolcnt,10)=1)
      stat = alterlist(wv_protocol_list->orders,(protocolcnt+ 9))
     ENDIF
     wv_protocol_list->orders[protocolcnt].order_id = o.protocol_order_id
    ENDIF
   ENDIF
  HEAD oi.synonym_id
   addingredient = 0
   IF (addorder > 0
    AND oi.synonym_id > 0)
    addingredient = 1
    IF (oc.catalog_cd=o.catalog_cd)
     reply->orders[ordercnt].catalog_cd = oc.catalog_cd, reply->orders[ordercnt].catalog_type_cd = oc
     .catalog_type_cd, reply->orders[ordercnt].activity_type_cd = oc.activity_type_cd
    ENDIF
    ingredcnt = (ingredcnt+ 1)
    IF (ingredcnt > size(reply->orders[ordercnt].order_ingredient,5))
     stat = alterlist(reply->orders[ordercnt].order_ingredient,(ingredcnt+ 5))
    ENDIF
    IF (oi.action_sequence > max_sequence)
     max_sequence = oi.action_sequence
    ENDIF
    reply->orders[ordercnt].order_ingredient[ingredcnt].catalog_cd = oc.catalog_cd, reply->orders[
    ordercnt].order_ingredient[ingredcnt].primary_mnemonic = oc.primary_mnemonic, reply->orders[
    ordercnt].order_ingredient[ingredcnt].hna_order_mnemonic = oi.hna_order_mnemonic,
    reply->orders[ordercnt].order_ingredient[ingredcnt].ordered_as_mnemonic = oi.ordered_as_mnemonic,
    reply->orders[ordercnt].order_ingredient[ingredcnt].ingredient_type_flag = oi
    .ingredient_type_flag, reply->orders[ordercnt].order_ingredient[ingredcnt].ref_text_mask = oc
    .ref_text_mask,
    reply->orders[ordercnt].order_ingredient[ingredcnt].cki = oc.cki, reply->orders[ordercnt].
    order_ingredient[ingredcnt].action_sequence = oi.action_sequence, reply->orders[ordercnt].
    order_ingredient[ingredcnt].comp_sequence = oi.comp_sequence,
    reply->orders[ordercnt].order_ingredient[ingredcnt].synonym_id = oi.synonym_id, reply->orders[
    ordercnt].order_ingredient[ingredcnt].include_in_total_volume_flag = oi
    .include_in_total_volume_flag, reply->orders[ordercnt].order_ingredient[ingredcnt].freq_cd = oi
    .freq_cd,
    reply->orders[ordercnt].order_ingredient[ingredcnt].strength = oi.strength, reply->orders[
    ordercnt].order_ingredient[ingredcnt].strength_unit = oi.strength_unit, reply->orders[ordercnt].
    order_ingredient[ingredcnt].volume = oi.volume,
    reply->orders[ordercnt].order_ingredient[ingredcnt].volume_unit = oi.volume_unit, reply->orders[
    ordercnt].order_ingredient[ingredcnt].normalized_rate = oi.normalized_rate, reply->orders[
    ordercnt].order_ingredient[ingredcnt].normalized_rate_unit_cd = oi.normalized_rate_unit_cd,
    reply->orders[ordercnt].order_ingredient[ingredcnt].ingredient_rate_conversion_ind = ocs
    .ingredient_rate_conversion_ind, reply->orders[ordercnt].order_ingredient[ingredcnt].witness_flag
     = ocs.witness_flag
    IF (validate(ocs.display_additives_first_ind))
     reply->orders[ordercnt].order_ingredient[ingredcnt].display_additives_first_ind = ocs
     .display_additives_first_ind
    ENDIF
    IF (ocs.ingredient_rate_conversion_ind=1)
     bhastitratableingred = 1
    ENDIF
   ENDIF
  FOOT  oi.synonym_id
   IF (addorder > 0
    AND oi.synonym_id > 0)
    stat = alterlist(reply->orders[ordercnt].order_ingredient,ingredcnt)
   ENDIF
  FOOT  o.order_id
   IF (event_cd_cnt=0
    AND addingredient != 0
    AND ordercnt >= 1
    AND bhastitratableingred=0)
    stat = alterlist(reply->orders[ordercnt].order_ingredient,0), stat = alterlist(reply->orders,(
     ordercnt - 1)), ordercnt = (ordercnt - 1)
   ELSE
    stat = alterlist(reply->orders,ordercnt)
    IF (addorder=1)
     FOR (seq_counter = 1 TO ingredcnt)
       IF ((reply->orders[ordercnt].order_ingredient[seq_counter].action_sequence=max_sequence))
        reply->orders[ordercnt].order_ingredient[seq_counter].active_ind = 1
       ELSE
        reply->orders[ordercnt].order_ingredient[seq_counter].active_ind = 0
       ENDIF
     ENDFOR
    ENDIF
   ENDIF
   IF (size(medswithtasks_rec->orders,5)=0)
    stat = alterlist(medswithtasks_rec->orders,1), medswithtasks_rec->orders[1].order_id = 0
   ENDIF
   max_sequence = 0
  WITH check
 ;end select
 IF (idebugind > 0)
  CALL echo("*******************************************************")
  CALL echo(build("Time for loading inactive orders = ",datetimediff(cnvtdatetime(curdate,curtime3),
     dtemptime,5)))
  CALL echo("*******************************************************")
 ENDIF
 SET dtemptime = cnvtdatetime(curdate,curtime3)
 SELECT
  IF (event_cd_cnt=0)
   PLAN (o
    WHERE (o.person_id=request->person_id)
     AND parser(catalog_clause)
     AND (((request->start_dt_tm != request->end_dt_tm)
     AND  NOT (((o.order_status_cd+ 0) IN (canceled_cd, completed_cd, deleted_cd, discontinued_cd,
    trans_cancel_cd,
    voidedwrslt_cd)))) OR ((request->start_dt_tm=request->end_dt_tm)
     AND  NOT (((o.order_status_cd+ 0) IN (canceled_cd, completed_cd, deleted_cd, discontinued_cd,
    trans_cancel_cd,
    voidedwrslt_cd, med_stud_cd, future_cd)))))
     AND ((o.template_order_id+ 0)=0)
     AND ((o.template_order_flag+ 0) IN (0, 1, 4))
     AND ((o.orderable_type_flag+ 0) IN (0, 1, 8, 10, 11))
     AND parser(encntr_in_clause)
     AND ((o.current_start_dt_tm <= cnvtdatetime(request->end_dt_tm)) OR ((request->end_dt_tm=0)))
     AND o.orig_ord_as_flag IN (0, 5)
     AND o.med_order_type_cd=med_order_iv_type_cd)
    JOIN (oi
    WHERE o.order_id=oi.order_id
     AND o.last_ingred_action_sequence=oi.action_sequence
     AND oi.freq_cd=everybag_cd)
    JOIN (ocs
    WHERE oi.synonym_id=ocs.synonym_id)
    JOIN (oc
    WHERE oi.catalog_cd=oc.catalog_cd)
  ELSE
   PLAN (o
    WHERE (o.person_id=request->person_id)
     AND parser(catalog_clause)
     AND (((request->start_dt_tm != request->end_dt_tm)
     AND  NOT (((o.order_status_cd+ 0) IN (canceled_cd, completed_cd, deleted_cd, discontinued_cd,
    trans_cancel_cd,
    voidedwrslt_cd)))) OR ((request->start_dt_tm=request->end_dt_tm)
     AND  NOT (((o.order_status_cd+ 0) IN (canceled_cd, completed_cd, deleted_cd, discontinued_cd,
    trans_cancel_cd,
    voidedwrslt_cd, med_stud_cd, future_cd)))))
     AND ((o.template_order_id+ 0)=0)
     AND ((o.template_order_flag+ 0) IN (0, 1, 4))
     AND ((o.orderable_type_flag+ 0) IN (0, 1, 8, 10, 11))
     AND parser(encntr_in_clause)
     AND ((o.current_start_dt_tm <= cnvtdatetime(request->end_dt_tm)) OR ((request->end_dt_tm=0)))
     AND o.orig_ord_as_flag IN (0, 5)
     AND o.med_order_type_cd != med_order_iv_type_cd)
    JOIN (oi
    WHERE outerjoin(o.order_id)=oi.order_id
     AND outerjoin(o.last_ingred_action_sequence)=oi.action_sequence)
    JOIN (ocs
    WHERE outerjoin(oi.synonym_id)=ocs.synonym_id)
    JOIN (oc
    WHERE outerjoin(oi.catalog_cd)=oc.catalog_cd)
  ENDIF
  INTO "nl:"
  o.order_id
  FROM orders o,
   order_ingredient oi,
   order_catalog_synonym ocs,
   order_catalog oc
  ORDER BY o.order_id, oi.synonym_id, oi.comp_sequence,
   oi.action_sequence DESC
  HEAD o.order_id
   addorder = 0, ingredcnt = 0, bhastitratableingred = 0
   IF (((parser(order_status_in_clause)) OR (o.protocol_order_id > 0))
    AND ((o.template_order_flag IN (1, 0)
    AND ((o.current_start_dt_tm <= cnvtdatetime(request->end_dt_tm)) OR ((request->end_dt_tm=0)))
    AND ((o.projected_stop_dt_tm=null) OR (((o.projected_stop_dt_tm >= cnvtdatetime(request->
    start_dt_tm)) OR (o.stop_type_cd=soft_stop_cd)) )) ) OR (o.template_order_flag=4
    AND ((o.current_start_dt_tm <= cnvtdatetime(request->end_dt_tm)) OR ((request->end_dt_tm=0)))
    AND ((o.projected_stop_dt_tm=null) OR (o.projected_stop_dt_tm >= cnvtdatetime(request->
    start_dt_tm))) )) )
    addorder = 1, ordercnt = (ordercnt+ 1)
    IF (ordercnt > size(reply->orders,5))
     stat = alterlist(reply->orders,(ordercnt+ 5))
    ENDIF
    reply->orders[ordercnt].order_id = o.order_id, reply->orders[ordercnt].encntr_id = o.encntr_id,
    reply->orders[ordercnt].person_id = o.person_id,
    reply->orders[ordercnt].order_status_cd = o.order_status_cd, reply->orders[ordercnt].display_line
     = trim(o.clinical_display_line), reply->orders[ordercnt].order_mnemonic = o.order_mnemonic,
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
    reply->orders[ordercnt].warning_level_bit = o.warning_level_bit
    IF (o.pathway_catalog_id > 0)
     reply->orders[ordercnt].plan_ind = 1
    ELSE
     reply->orders[ordercnt].plan_ind = 0
    ENDIF
    IF (o.protocol_order_id > 0)
     protocolcnt = (protocolcnt+ 1)
     IF (mod(protocolcnt,10)=1)
      stat = alterlist(wv_protocol_list->orders,(protocolcnt+ 9))
     ENDIF
     wv_protocol_list->orders[protocolcnt].order_id = o.protocol_order_id
    ENDIF
   ENDIF
  HEAD oi.synonym_id
   addingredient = 0
   IF (addorder > 0)
    IF (oc.catalog_cd=o.catalog_cd)
     reply->orders[ordercnt].catalog_cd = oc.catalog_cd, reply->orders[ordercnt].catalog_type_cd = oc
     .catalog_type_cd, reply->orders[ordercnt].activity_type_cd = oc.activity_type_cd
    ENDIF
    IF (oi.synonym_id > 0)
     addingredient = 1
    ENDIF
    IF (oi.action_sequence > max_sequence)
     max_sequence = oi.action_sequence
    ENDIF
   ENDIF
  HEAD oi.comp_sequence
   IF (addingredient > 0)
    ingredcnt = (ingredcnt+ 1)
    IF (ingredcnt > size(reply->orders[ordercnt].order_ingredient,5))
     stat = alterlist(reply->orders[ordercnt].order_ingredient,(ingredcnt+ 5))
    ENDIF
    reply->orders[ordercnt].order_ingredient[ingredcnt].catalog_cd = oc.catalog_cd, reply->orders[
    ordercnt].order_ingredient[ingredcnt].primary_mnemonic = oc.primary_mnemonic, reply->orders[
    ordercnt].order_ingredient[ingredcnt].hna_order_mnemonic = oi.hna_order_mnemonic,
    reply->orders[ordercnt].order_ingredient[ingredcnt].ordered_as_mnemonic = oi.ordered_as_mnemonic,
    reply->orders[ordercnt].order_ingredient[ingredcnt].ingredient_type_flag = oi
    .ingredient_type_flag, reply->orders[ordercnt].order_ingredient[ingredcnt].ref_text_mask = oc
    .ref_text_mask,
    reply->orders[ordercnt].order_ingredient[ingredcnt].cki = oc.cki, reply->orders[ordercnt].
    order_ingredient[ingredcnt].action_sequence = oi.action_sequence, reply->orders[ordercnt].
    order_ingredient[ingredcnt].comp_sequence = oi.comp_sequence,
    reply->orders[ordercnt].order_ingredient[ingredcnt].synonym_id = oi.synonym_id, reply->orders[
    ordercnt].order_ingredient[ingredcnt].include_in_total_volume_flag = oi
    .include_in_total_volume_flag, reply->orders[ordercnt].order_ingredient[ingredcnt].freq_cd = oi
    .freq_cd,
    reply->orders[ordercnt].order_ingredient[ingredcnt].strength = oi.strength, reply->orders[
    ordercnt].order_ingredient[ingredcnt].strength_unit = oi.strength_unit, reply->orders[ordercnt].
    order_ingredient[ingredcnt].volume = oi.volume,
    reply->orders[ordercnt].order_ingredient[ingredcnt].volume_unit = oi.volume_unit, reply->orders[
    ordercnt].order_ingredient[ingredcnt].normalized_rate = oi.normalized_rate, reply->orders[
    ordercnt].order_ingredient[ingredcnt].normalized_rate_unit_cd = oi.normalized_rate_unit_cd,
    reply->orders[ordercnt].order_ingredient[ingredcnt].ingredient_rate_conversion_ind = ocs
    .ingredient_rate_conversion_ind, reply->orders[ordercnt].order_ingredient[ingredcnt].witness_flag
     = ocs.witness_flag
    IF (validate(ocs.display_additives_first_ind))
     reply->orders[ordercnt].order_ingredient[ingredcnt].display_additives_first_ind = ocs
     .display_additives_first_ind
    ENDIF
    IF (ocs.ingredient_rate_conversion_ind=1)
     bhastitratableingred = 1
    ENDIF
   ENDIF
  FOOT  oi.comp_sequence
   IF (addingredient > 0)
    stat = alterlist(reply->orders[ordercnt].order_ingredient,ingredcnt)
   ENDIF
  FOOT  o.order_id
   IF (event_cd_cnt=0
    AND addingredient != 0
    AND ordercnt >= 1
    AND bhastitratableingred=0)
    stat = alterlist(reply->orders[ordercnt].order_ingredient,0), stat = alterlist(reply->orders,(
     ordercnt - 1)), ordercnt = (ordercnt - 1)
   ELSE
    stat = alterlist(reply->orders,ordercnt)
    IF (addorder=1)
     FOR (seq_counter = 1 TO ingredcnt)
       IF ((reply->orders[ordercnt].order_ingredient[seq_counter].action_sequence=max_sequence))
        reply->orders[ordercnt].order_ingredient[seq_counter].active_ind = 1
       ELSE
        reply->orders[ordercnt].order_ingredient[seq_counter].active_ind = 0
       ENDIF
     ENDFOR
    ENDIF
   ENDIF
   IF (size(medswithtasks_rec->orders,5)=0)
    stat = alterlist(medswithtasks_rec->orders,1), medswithtasks_rec->orders[1].order_id = 0
   ENDIF
   max_sequence = 0
  WITH check
 ;end select
 IF (idebugind > 0)
  CALL echo("*******************************************************")
  CALL echo(build("Time for loading active orders = ",datetimediff(cnvtdatetime(curdate,curtime3),
     dtemptime,5)))
  CALL echo("*******************************************************")
 ENDIF
 IF (ordercnt=0)
  SET zero_ind = 1
  GO TO exit_script
 ENDIF
 IF (protocolcnt > 0)
  SET dtemptime = cnvtdatetime(curdate,curtime3)
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
  SELECT
   IF (event_cd_cnt=0)
    PLAN (o
     WHERE ((expand(x,nstart,(nstart+ (nsize - 1)),(o.order_id+ 0),wv_protocol_list->orders[x].
      order_id)
      AND o.template_order_flag=7) OR (expand(y,nstart,(nstart+ (nsize - 1)),(o.protocol_order_id+ 0),
      wv_protocol_list->orders[y].order_id)
      AND o.template_order_flag IN (0, 1, 4)))
      AND parser(encntr_in_clause)
      AND  NOT (parser(order_clause)))
     JOIN (oi
     WHERE o.order_id=oi.order_id
      AND o.last_ingred_action_sequence=oi.action_sequence
      AND oi.freq_cd=everybag_cd)
     JOIN (ocs
     WHERE oi.synonym_id=ocs.synonym_id)
     JOIN (oc
     WHERE oi.catalog_cd=oc.catalog_cd)
   ELSE
    PLAN (o
     WHERE ((expand(x,nstart,(nstart+ (nsize - 1)),(o.order_id+ 0),wv_protocol_list->orders[x].
      order_id)
      AND o.template_order_flag=7) OR (expand(y,nstart,(nstart+ (nsize - 1)),(o.protocol_order_id+ 0),
      wv_protocol_list->orders[y].order_id)
      AND o.template_order_flag IN (0, 1, 4)))
      AND parser(encntr_in_clause)
      AND  NOT (parser(order_clause)))
     JOIN (oi
     WHERE outerjoin(o.order_id)=oi.order_id
      AND outerjoin(o.last_ingred_action_sequence)=oi.action_sequence)
     JOIN (ocs
     WHERE outerjoin(oi.synonym_id)=ocs.synonym_id)
     JOIN (oc
     WHERE outerjoin(oi.catalog_cd)=oc.catalog_cd)
   ENDIF
   INTO "nl:"
   o.order_id
   FROM orders o,
    order_ingredient oi,
    order_catalog_synonym ocs,
    order_catalog oc
   ORDER BY o.order_id, oi.synonym_id, oi.comp_sequence,
    oi.action_sequence DESC
   HEAD o.order_id
    ordercnt = (ordercnt+ 1)
    IF (ordercnt > size(reply->orders,5))
     stat = alterlist(reply->orders,(ordercnt+ 5))
    ENDIF
    reply->orders[ordercnt].order_id = o.order_id, reply->orders[ordercnt].encntr_id = o.encntr_id,
    reply->orders[ordercnt].person_id = o.person_id,
    reply->orders[ordercnt].order_status_cd = o.order_status_cd, reply->orders[ordercnt].display_line
     = trim(o.clinical_display_line), reply->orders[ordercnt].order_mnemonic = o.order_mnemonic,
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
    reply->orders[ordercnt].warning_level_bit = o.warning_level_bit
    IF (o.pathway_catalog_id > 0)
     reply->orders[ordercnt].plan_ind = 1
    ELSE
     reply->orders[ordercnt].plan_ind = 0
    ENDIF
   HEAD oi.synonym_id
    IF (oc.catalog_cd=o.catalog_cd)
     reply->orders[ordercnt].catalog_cd = oc.catalog_cd, reply->orders[ordercnt].catalog_type_cd = oc
     .catalog_type_cd, reply->orders[ordercnt].activity_type_cd = oc.activity_type_cd
    ENDIF
    IF (oi.action_sequence > max_sequence)
     max_sequence = oi.action_sequence
    ENDIF
   HEAD oi.comp_sequence
    ingredcnt = (ingredcnt+ 1)
    IF (ingredcnt > size(reply->orders[ordercnt].order_ingredient,5))
     stat = alterlist(reply->orders[ordercnt].order_ingredient,(ingredcnt+ 5))
    ENDIF
    reply->orders[ordercnt].order_ingredient[ingredcnt].catalog_cd = oc.catalog_cd, reply->orders[
    ordercnt].order_ingredient[ingredcnt].primary_mnemonic = oc.primary_mnemonic, reply->orders[
    ordercnt].order_ingredient[ingredcnt].hna_order_mnemonic = oi.hna_order_mnemonic,
    reply->orders[ordercnt].order_ingredient[ingredcnt].ordered_as_mnemonic = oi.ordered_as_mnemonic,
    reply->orders[ordercnt].order_ingredient[ingredcnt].ingredient_type_flag = oi
    .ingredient_type_flag, reply->orders[ordercnt].order_ingredient[ingredcnt].ref_text_mask = oc
    .ref_text_mask,
    reply->orders[ordercnt].order_ingredient[ingredcnt].cki = oc.cki, reply->orders[ordercnt].
    order_ingredient[ingredcnt].action_sequence = oi.action_sequence, reply->orders[ordercnt].
    order_ingredient[ingredcnt].comp_sequence = oi.comp_sequence,
    reply->orders[ordercnt].order_ingredient[ingredcnt].synonym_id = oi.synonym_id, reply->orders[
    ordercnt].order_ingredient[ingredcnt].include_in_total_volume_flag = oi
    .include_in_total_volume_flag, reply->orders[ordercnt].order_ingredient[ingredcnt].freq_cd = oi
    .freq_cd,
    reply->orders[ordercnt].order_ingredient[ingredcnt].strength = oi.strength, reply->orders[
    ordercnt].order_ingredient[ingredcnt].strength_unit = oi.strength_unit, reply->orders[ordercnt].
    order_ingredient[ingredcnt].volume = oi.volume,
    reply->orders[ordercnt].order_ingredient[ingredcnt].volume_unit = oi.volume_unit, reply->orders[
    ordercnt].order_ingredient[ingredcnt].normalized_rate = oi.normalized_rate, reply->orders[
    ordercnt].order_ingredient[ingredcnt].normalized_rate_unit_cd = oi.normalized_rate_unit_cd,
    reply->orders[ordercnt].order_ingredient[ingredcnt].ingredient_rate_conversion_ind = ocs
    .ingredient_rate_conversion_ind, reply->orders[ordercnt].order_ingredient[ingredcnt].witness_flag
     = ocs.witness_flag
    IF (validate(ocs.display_additives_first_ind))
     reply->orders[ordercnt].order_ingredient[ingredcnt].display_additives_first_ind = ocs
     .display_additives_first_ind
    ENDIF
    IF (ocs.ingredient_rate_conversion_ind=1)
     bhastitratableingred = 1
    ENDIF
   FOOT  oi.comp_sequence
    stat = alterlist(reply->orders[ordercnt].order_ingredient,ingredcnt)
   FOOT  o.order_id
    IF (event_cd_cnt=0
     AND addingredient != 0
     AND ordercnt >= 1
     AND bhastitratableingred=0)
     stat = alterlist(reply->orders[ordercnt].order_ingredient,0), stat = alterlist(reply->orders,(
      ordercnt - 1)), ordercnt = (ordercnt - 1)
    ELSE
     stat = alterlist(reply->orders,ordercnt)
     FOR (seq_counter = 1 TO ingredcnt)
       IF ((reply->orders[ordercnt].order_ingredient[seq_counter].action_sequence=max_sequence))
        reply->orders[ordercnt].order_ingredient[seq_counter].active_ind = 1
       ELSE
        reply->orders[ordercnt].order_ingredient[seq_counter].active_ind = 0
       ENDIF
     ENDFOR
    ENDIF
    IF (size(medswithtasks_rec->orders,5)=0)
     stat = alterlist(medswithtasks_rec->orders,1), medswithtasks_rec->orders[1].order_id = 0
    ENDIF
    max_sequence = 0
   WITH check
  ;end select
  IF (idebugind > 0)
   CALL echo("*******************************************************")
   CALL echo(build("Time for loading protocol and other template orders = ",datetimediff(cnvtdatetime
      (curdate,curtime3),dtemptime,5)))
   CALL echo("*******************************************************")
  ENDIF
 ENDIF
 CALL loadorderactions(null)
 CALL populateverifyindicator(null)
 CALL setrenewalindicators(null)
 CALL loadcatalogeventcodes(null)
 CALL loadorderdetails(null)
 IF (size(reply->orders,5) > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(size(reply->orders,5))),
    order_comment oc,
    long_text lt
   PLAN (d
    WHERE band(reply->orders[d.seq].comment_type_mask,order_comment_mask)=order_comment_mask)
    JOIN (oc
    WHERE (oc.order_id=reply->orders[d.seq].order_id)
     AND oc.comment_type_cd=order_comment_cd
     AND (oc.action_sequence=
    (SELECT
     max(oc2.action_sequence)
     FROM order_comment oc2
     WHERE oc2.order_id=oc.order_id
      AND oc2.comment_type_cd=order_comment_cd)))
    JOIN (lt
    WHERE lt.long_text_id=oc.long_text_id)
   DETAIL
    reply->orders[d.seq].order_comment_text = lt.long_text
   WITH nocounter
  ;end select
 ENDIF
 IF (event_cd_cnt > 0)
  SET dtemptime = cnvtdatetime(curdate,curtime3)
  IF (size(reply->orders,5) > 0)
   SET bcatalogcdfoundinreflist = 0
   SET beventcdfoundinrequest = 0
   SET ordercnt = 0
   SET ireflistindex = 0
   IF ((request->only_load_lab_orders=0))
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(size(reply->orders,5))),
      code_value_event_r cver
     PLAN (d
      WHERE (reply->orders[d.seq].catalog_type_cd=pharmacy_cd))
      JOIN (cver
      WHERE (reply->orders[d.seq].catalog_cd=cver.parent_cd))
     ORDER BY d.seq, cver.event_cd
     HEAD REPORT
      reflistcnt = 0
     HEAD d.seq
      haseventcdineventcdlist = 0, reftasklistcnt = 0, eventcdlistcnt = 0,
      bcatalogcdfoundinreflist = 0
      FOR (ireflistindex = 1 TO reflistcnt)
        IF ((reply->orders[d.seq].catalog_cd=reply->reference_list[ireflistindex].catalog_cd))
         bcatalogcdfoundinreflist = 1, BREAK
        ENDIF
      ENDFOR
      IF (bcatalogcdfoundinreflist=0)
       reflistcnt = (reflistcnt+ 1)
       IF (mod(reflistcnt,10)=1)
        stat = alterlist(reply->reference_list,(reflistcnt+ 9))
       ENDIF
       reply->reference_list[reflistcnt].catalog_cd = reply->orders[d.seq].catalog_cd
      ENDIF
     HEAD cver.event_cd
      IF (haseventcdineventcdlist=0)
       FOR (cnt = 1 TO event_cd_cnt)
         IF ((cver.event_cd=request->event_cd_list[cnt].event_cd))
          haseventcdineventcdlist = 1, BREAK
         ENDIF
       ENDFOR
      ENDIF
      IF (bcatalogcdfoundinreflist=0)
       IF (reftasklistcnt=0)
        reftasklistcnt = (reftasklistcnt+ 1), stat = alterlist(reply->reference_list[reflistcnt].
         ref_task_list,reftasklistcnt)
       ENDIF
       eventcdlistcnt = (eventcdlistcnt+ 1)
       IF (mod(eventcdlistcnt,10)=1)
        stat = alterlist(reply->reference_list[reflistcnt].ref_task_list[reftasklistcnt].
         event_code_list,(eventcdlistcnt+ 9))
       ENDIF
       reply->reference_list[reflistcnt].ref_task_list[reftasklistcnt].event_code_list[eventcdlistcnt
       ].event_cd = cver.event_cd
      ENDIF
     FOOT  d.seq
      IF (haseventcdineventcdlist=1)
       non_iv_order_cnt = (non_iv_order_cnt+ 1)
       IF (mod(non_iv_order_cnt,10)=1)
        stat = alterlist(reply->non_iv_orders,(non_iv_order_cnt+ 9))
       ENDIF
       reply->non_iv_orders[non_iv_order_cnt].order_id = reply->orders[d.seq].order_id
      ENDIF
      IF (reftasklistcnt > 0)
       stat = alterlist(reply->reference_list[reflistcnt].ref_task_list[reftasklistcnt].
        event_code_list,eventcdlistcnt)
      ENDIF
     FOOT REPORT
      stat = alterlist(reply->non_iv_orders,non_iv_order_cnt), stat = alterlist(reply->reference_list,
       reflistcnt)
     WITH nocounter
    ;end select
   ENDIF
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(reply->orders,5))),
     order_task_xref otx,
     task_discrete_r tdr,
     discrete_task_assay dta
    PLAN (d
     WHERE (reply->orders[d.seq].catalog_type_cd != pharmacy_cd))
     JOIN (otx
     WHERE (reply->orders[d.seq].catalog_cd=otx.catalog_cd))
     JOIN (tdr
     WHERE otx.reference_task_id=tdr.reference_task_id)
     JOIN (dta
     WHERE tdr.task_assay_cd=dta.task_assay_cd)
    ORDER BY d.seq, otx.reference_task_id, tdr.task_assay_cd
    HEAD REPORT
     IF (reflistcnt > 0)
      stat = alterlist(reply->reference_list,(reflistcnt+ 9))
     ENDIF
     IF (non_iv_order_cnt > 0)
      stat = alterlist(reply->non_iv_orders,(non_iv_order_cnt+ 9))
     ENDIF
    HEAD d.seq
     haseventcdineventcdlist = 0, alleventcdineventcdlist = 1, reftasklistcnt = 0,
     bcatalogcdfoundinreflist = 0
     FOR (ireflistindex = 1 TO reflistcnt)
       IF ((reply->orders[d.seq].catalog_cd=reply->reference_list[ireflistindex].catalog_cd))
        bcatalogcdfoundinreflist = 1, BREAK
       ENDIF
     ENDFOR
     IF (bcatalogcdfoundinreflist=0)
      reflistcnt = (reflistcnt+ 1)
      IF (mod(reflistcnt,10)=1)
       stat = alterlist(reply->reference_list,(reflistcnt+ 9))
      ENDIF
      reply->reference_list[reflistcnt].catalog_cd = reply->orders[d.seq].catalog_cd
     ENDIF
    HEAD otx.reference_task_id
     eventcdlistcnt = 0
     IF (bcatalogcdfoundinreflist=0)
      reftasklistcnt = (reftasklistcnt+ 1)
      IF (mod(reftasklistcnt,10)=1)
       stat = alterlist(reply->reference_list[reflistcnt].ref_task_list,(reftasklistcnt+ 9))
      ENDIF
      reply->reference_list[reflistcnt].ref_task_list[reftasklistcnt].reference_task_id = otx
      .reference_task_id
     ENDIF
    HEAD tdr.task_assay_cd
     IF (bcatalogcdfoundinreflist=0)
      eventcdlistcnt = (eventcdlistcnt+ 1)
      IF (mod(eventcdlistcnt,10)=1)
       stat = alterlist(reply->reference_list[ireflistindex].ref_task_list[reftasklistcnt].
        event_code_list,(eventcdlistcnt+ 9))
      ENDIF
      reply->reference_list[reflistcnt].ref_task_list[reftasklistcnt].event_code_list[eventcdlistcnt]
      .event_cd = dta.event_cd, reply->reference_list[reflistcnt].ref_task_list[reftasklistcnt].
      event_code_list[eventcdlistcnt].task_assay_cd = dta.task_assay_cd, reply->reference_list[
      reflistcnt].ref_task_list[reftasklistcnt].event_code_list[eventcdlistcnt].required_ind = tdr
      .required_ind
     ENDIF
     beventcdfoundinrequest = 0
     FOR (cnt = 1 TO event_cd_cnt)
       IF ((dta.event_cd=request->event_cd_list[cnt].event_cd))
        haseventcdineventcdlist = 1, beventcdfoundinrequest = 1, BREAK
       ENDIF
     ENDFOR
     IF (beventcdfoundinrequest=0)
      alleventcdineventcdlist = 0
     ENDIF
    FOOT  otx.reference_task_id
     IF (bcatalogcdfoundinreflist=0)
      IF (reftasklistcnt > 0)
       stat = alterlist(reply->reference_list[reflistcnt].ref_task_list[reftasklistcnt].
        event_code_list,eventcdlistcnt)
      ENDIF
     ENDIF
    FOOT  d.seq
     medswithtaskscnt = (medswithtaskscnt+ 1)
     IF (mod(medswithtaskscnt,10)=1)
      stat = alterlist(medswithtasks_rec->orders,(medswithtaskscnt+ 9))
     ENDIF
     medswithtasks_rec->orders[medswithtaskscnt].order_id = reply->orders[d.seq].order_id
     IF ((((reply->orders[d.seq].catalog_type_cd=lab_cd)
      AND haseventcdineventcdlist=1) OR ((reply->orders[d.seq].catalog_type_cd != lab_cd)
      AND alleventcdineventcdlist=1
      AND haseventcdineventcdlist=1)) )
      non_iv_order_cnt = (non_iv_order_cnt+ 1)
      IF (mod(non_iv_order_cnt,10)=1)
       stat = alterlist(reply->non_iv_orders,(non_iv_order_cnt+ 9))
      ENDIF
      reply->non_iv_orders[non_iv_order_cnt].order_id = reply->orders[d.seq].order_id
     ENDIF
     IF (bcatalogcdfoundinreflist=0)
      IF (reflistcnt > 0)
       stat = alterlist(reply->reference_list[reflistcnt].ref_task_list,reftasklistcnt)
      ENDIF
     ENDIF
    FOOT REPORT
     stat = alterlist(reply->reference_list,reflistcnt), stat = alterlist(reply->non_iv_orders,
      non_iv_order_cnt), stat = alterlist(medswithtasks_rec->orders,medswithtaskscnt),
     ordercnt = size(medswithtasks_rec->orders,5)
     IF (ordercnt > 0)
      orders_with_tasks_clause = concat(" reply->orders[d.seq].order_id not in (",trim(cnvtstring(
         medswithtasks_rec->orders[1].order_id)))
      FOR (cnt = 2 TO ordercnt)
        orders_with_tasks_clause = concat(trim(orders_with_tasks_clause),",",trim(cnvtstring(
           medswithtasks_rec->orders[cnt].order_id)))
      ENDFOR
      orders_with_tasks_clause = concat(trim(orders_with_tasks_clause),")")
     ELSE
      orders_with_tasks_clause = concat(trim(orders_with_tasks_clause)," 0=0")
     ENDIF
    WITH nocounter
   ;end select
   IF ((request->only_load_lab_orders=0))
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(size(reply->orders,5))),
      profile_task_r ptr,
      discrete_task_assay dta
     PLAN (d
      WHERE (reply->orders[d.seq].catalog_type_cd != pharmacy_cd)
       AND (reply->orders[d.seq].catalog_type_cd != lab_cd)
       AND parser(orders_with_tasks_clause))
      JOIN (ptr
      WHERE (reply->orders[d.seq].catalog_cd=ptr.catalog_cd))
      JOIN (dta
      WHERE ptr.task_assay_cd=dta.task_assay_cd)
     ORDER BY d.seq, ptr.reference_task_id, dta.event_cd
     HEAD REPORT
      IF (reflistcnt > 0)
       stat = alterlist(reply->reference_list,(reflistcnt+ 9))
      ENDIF
      IF (non_iv_order_cnt > 0)
       stat = alterlist(reply->non_iv_orders,(non_iv_order_cnt+ 9))
      ENDIF
     HEAD d.seq
      haseventcdineventcdlist = 0, alleventcdineventcdlist = 1, reftasklistcnt = 0,
      bcatalogcdfoundinreflist = 0
      FOR (ireflistindex = 1 TO reflistcnt)
        IF ((reply->orders[d.seq].catalog_cd=reply->reference_list[ireflistindex].catalog_cd))
         bcatalogcdfoundinreflist = 1, BREAK
        ENDIF
      ENDFOR
      IF (bcatalogcdfoundinreflist=0)
       reflistcnt = (reflistcnt+ 1)
       IF (mod(reflistcnt,10)=1)
        stat = alterlist(reply->reference_list,(reflistcnt+ 9))
       ENDIF
       reply->reference_list[reflistcnt].catalog_cd = reply->orders[d.seq].catalog_cd
      ENDIF
     HEAD ptr.reference_task_id
      IF (bcatalogcdfoundinreflist=0)
       eventcdlistcnt = 0, reftasklistcnt = (reftasklistcnt+ 1)
       IF (mod(reftasklistcnt,10)=1)
        stat = alterlist(reply->reference_list[reflistcnt].ref_task_list,(reftasklistcnt+ 9))
       ENDIF
       reply->reference_list[reflistcnt].ref_task_list[reftasklistcnt].reference_task_id = ptr
       .reference_task_id
      ENDIF
     HEAD dta.event_cd
      IF (alleventcdineventcdlist=1)
       beventcdfoundinrequest = 0
       FOR (cnt = 1 TO event_cd_cnt)
         IF ((dta.event_cd=request->event_cd_list[cnt].event_cd))
          haseventcdineventcdlist = 1, beventcdfoundinrequest = 1, BREAK
         ENDIF
       ENDFOR
       IF (beventcdfoundinrequest=0)
        alleventcdineventcdlist = 0
       ENDIF
      ENDIF
      IF (bcatalogcdfoundinreflist=0)
       eventcdlistcnt = (eventcdlistcnt+ 1)
       IF (mod(eventcdlistcnt,10)=1)
        stat = alterlist(reply->reference_list[reflistcnt].ref_task_list[reftasklistcnt].
         event_code_list,(eventcdlistcnt+ 9))
       ENDIF
       reply->reference_list[reflistcnt].ref_task_list[reftasklistcnt].event_code_list[eventcdlistcnt
       ].event_cd = dta.event_cd, reply->reference_list[reflistcnt].ref_task_list[reftasklistcnt].
       event_code_list[eventcdlistcnt].task_assay_cd = dta.task_assay_cd
      ENDIF
     FOOT  ptr.reference_task_id
      IF (bcatalogcdfoundinreflist=0)
       IF (reftasklistcnt > 0)
        stat = alterlist(reply->reference_list[reflistcnt].ref_task_list[reftasklistcnt].
         event_code_list,eventcdlistcnt)
       ENDIF
      ENDIF
     FOOT  d.seq
      IF (haseventcdineventcdlist=1
       AND alleventcdineventcdlist=1)
       non_iv_order_cnt = (non_iv_order_cnt+ 1)
       IF (mod(non_iv_order_cnt,10)=1)
        stat = alterlist(reply->non_iv_orders,(non_iv_order_cnt+ 9))
       ENDIF
       reply->non_iv_orders[non_iv_order_cnt].order_id = reply->orders[d.seq].order_id
      ENDIF
      IF (bcatalogcdfoundinreflist=0)
       stat = alterlist(reply->reference_list[reflistcnt].ref_task_list,reftasklistcnt)
      ENDIF
     FOOT REPORT
      stat = alterlist(reply->non_iv_orders,non_iv_order_cnt), stat = alterlist(reply->reference_list,
       reflistcnt)
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(size(reply->orders,5))),
      profile_task_r ptr,
      code_value_event_r cver
     PLAN (d
      WHERE (reply->orders[d.seq].catalog_type_cd != pharmacy_cd)
       AND (reply->orders[d.seq].catalog_type_cd=lab_cd)
       AND parser(orders_with_tasks_clause))
      JOIN (ptr
      WHERE (reply->orders[d.seq].catalog_cd=ptr.catalog_cd))
      JOIN (cver
      WHERE ptr.task_assay_cd=cver.parent_cd)
     ORDER BY d.seq, ptr.reference_task_id, cver.event_cd
     HEAD REPORT
      IF (reflistcnt > 0)
       stat = alterlist(reply->reference_list,(reflistcnt+ 9))
      ENDIF
      IF (non_iv_order_cnt > 0)
       stat = alterlist(reply->non_iv_orders,(non_iv_order_cnt+ 9))
      ENDIF
     HEAD d.seq
      haseventcdineventcdlist = 0, reftasklistcnt = 0, eventcdlistcnt = 0,
      bcatalogcdfoundinreflist = 0
      FOR (ireflistindex = 1 TO reflistcnt)
        IF ((reply->orders[d.seq].catalog_cd=reply->reference_list[ireflistindex].catalog_cd))
         bcatalogcdfoundinreflist = 1, BREAK
        ENDIF
      ENDFOR
      IF (bcatalogcdfoundinreflist=0)
       reflistcnt = (reflistcnt+ 1)
       IF (mod(reflistcnt,10)=1)
        stat = alterlist(reply->reference_list,(reflistcnt+ 9))
       ENDIF
       reply->reference_list[reflistcnt].catalog_cd = reply->orders[d.seq].catalog_cd
      ENDIF
     HEAD ptr.reference_task_id
      IF (bcatalogcdfoundinreflist=0)
       eventcdlistcnt = 0, reftasklistcnt = (reftasklistcnt+ 1)
       IF (mod(reftasklistcnt,10)=1)
        stat = alterlist(reply->reference_list[reflistcnt].ref_task_list,(reftasklistcnt+ 9))
       ENDIF
       reply->reference_list[reflistcnt].ref_task_list[reftasklistcnt].reference_task_id = ptr
       .reference_task_id
      ENDIF
     HEAD cver.event_cd
      IF (haseventcdineventcdlist=0)
       FOR (cnt = 1 TO event_cd_cnt)
         IF ((cver.event_cd=request->event_cd_list[cnt].event_cd))
          haseventcdineventcdlist = 1, BREAK
         ENDIF
       ENDFOR
      ENDIF
      IF (bcatalogcdfoundinreflist=0
       AND reftasklistcnt > 0)
       eventcdlistcnt = (eventcdlistcnt+ 1)
       IF (mod(eventcdlistcnt,10)=1)
        stat = alterlist(reply->reference_list[reflistcnt].ref_task_list[reftasklistcnt].
         event_code_list,(eventcdlistcnt+ 9))
       ENDIF
       reply->reference_list[reflistcnt].ref_task_list[reftasklistcnt].event_code_list[eventcdlistcnt
       ].event_cd = cver.event_cd
      ENDIF
     FOOT  ptr.reference_task_id
      IF (bcatalogcdfoundinreflist=0)
       IF (reftasklistcnt > 0)
        stat = alterlist(reply->reference_list[reflistcnt].ref_task_list[reftasklistcnt].
         event_code_list,eventcdlistcnt)
       ENDIF
      ENDIF
     FOOT  d.seq
      IF (haseventcdineventcdlist=1)
       non_iv_order_cnt = (non_iv_order_cnt+ 1)
       IF (mod(non_iv_order_cnt,10)=1)
        stat = alterlist(reply->non_iv_orders,(non_iv_order_cnt+ 9))
       ENDIF
       reply->non_iv_orders[non_iv_order_cnt].order_id = reply->orders[d.seq].order_id
      ENDIF
      IF (bcatalogcdfoundinreflist=0)
       IF (reftasklistcnt > 0)
        stat = alterlist(reply->reference_list[reflistcnt].ref_task_list[reftasklistcnt].
         event_code_list,eventcdlistcnt)
       ENDIF
      ENDIF
     FOOT REPORT
      stat = alterlist(reply->non_iv_orders,non_iv_order_cnt), stat = alterlist(reply->reference_list,
       reflistcnt)
     WITH nocounter
    ;end select
   ENDIF
  ENDIF
  IF (idebugind > 0)
   CALL echo("*******************************************************")
   CALL echo(build("Time to retrieve event code list for each non-IV order = ",datetimediff(
      cnvtdatetime(curdate,curtime3),dtemptime,5)))
   CALL echo("*******************************************************")
  ENDIF
 ENDIF
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
    AND oa.action_type_cd IN (order_action_type_cd, modify_action_type_cd, activate_action_type_cd)
    AND oa.action_rejected_ind=0)
    reply->orders[d.seq].core_action_sequence = oa.action_sequence
   ENDIF
  WITH nocounter
 ;end select
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
          IF ((reply->orders[y].stop_type_cd=hard_stop_cd))
           reply->orders[y].need_renew_ind = 2
          ELSEIF ((reply->orders[y].stop_type_cd=soft_stop_cd))
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
      reply->orders[iorderposidx].order_detail[0].oe_field_value = od.oe_field_value
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
#exit_script
 IF (zero_ind=1)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF (idebugind > 0)
  CALL echo("*******************************************************")
  CALL echo(build("Last Mod = ",slastmod))
  CALL echo("*******************************************************")
  CALL echo("*******************************************************")
  CALL echo(build("Total Time = ",datetimediff(cnvtdatetime(curdate,curtime3),dstarttime,5)))
  CALL echo("*******************************************************")
  IF (idebugind=2)
   CALL echorecord(reply)
  ENDIF
 ENDIF
#uar_failed
END GO
