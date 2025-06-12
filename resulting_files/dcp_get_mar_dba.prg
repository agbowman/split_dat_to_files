CREATE PROGRAM dcp_get_mar:dba
 SET modify = predeclare
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
     2 need_rx_clin_review_flag = i2
     2 need_nurse_review_ind = i2
     2 med_order_type_cd = f8
     2 med_order_type_disp = vc
     2 med_order_type_mean = vc
     2 need_renew_ind = i2
     2 last_action_sequence = i4
     2 core_action_sequence = i4
     2 freq_type_flag = i2
     2 current_start_dt_tm = dq8
     2 current_start_tz = i4
     2 projected_stop_dt_tm = dq8
     2 projected_stop_tz = i4
     2 stop_type_cd = f8
     2 stop_type_disp = vc
     2 stop_type_mean = vc
     2 orderable_type_flag = i2
     2 template_order_flag = i2
     2 iv_ind = i2
     2 link_nbr = f8
     2 link_type_flag = i2
     2 event_cd = f8
     2 order_ingredient[*]
       3 event_cd = f8
       3 event_cd_disp = vc
       3 event_cd_desc = vc
       3 event_cd_mean = vc
       3 catalog_cd = f8
       3 catalog_cd_disp = vc
       3 primary_mnemonic = vc
       3 ingredient_type_flag = i2
       3 ref_text_mask = i4
       3 cki = vc
       3 active_ind = i2
       3 action_sequence = i4
       3 comp_sequence = i4
       3 synonym_id = f8
       3 order_mnemonic = vc
       3 hna_order_mnemonic = vc
       3 ordered_as_mnemonic = vc
       3 strength = f8
       3 strength_unit = f8
       3 volume = f8
       3 volume_unit = f8
       3 freetext_dose = vc
       3 ingredientrateconversionind = i2
       3 clinically_significant_flag = i2
       3 freq_cd = f8
       3 normalized_rate = f8
       3 normalized_rate_unit_cd = f8
       3 normalized_rate_unit_cd_disp = vc
       3 normalized_rate_unit_cd_desc = vc
       3 normalized_rate_unit_cd_mean = vc
       3 concentration = f8
       3 concentration_unit_cd = f8
       3 concentration_unit_cd_disp = vc
       3 concentration_unit_cd_desc = vc
       3 concentration_unit_cd_mean = vc
       3 discretes[*]
         4 event_cd = f8
         4 event_cd_disp = vc
         4 event_cd_desc = vc
         4 event_cd_mean = vc
     2 order_details[*]
       3 action_sequence = i4
       3 detail_sequence = i4
       3 oe_field_id = f8
       3 oe_field_meaning = vc
       3 oe_field_meaning_id = f8
       3 oe_field_value = f8
       3 oe_field_display_value = vc
       3 oe_field_dt_tm = dq8
       3 oe_field_tz = i4
     2 child_orders[*]
       3 order_id = f8
       3 encntr_id = f8
       3 catalog_cd = f8
       3 catalog_type_cd = f8
       3 core_action_sequence = i4
       3 need_rx_verify_ind = i2
       3 need_rx_clin_review_flag = i2
       3 need_nurse_review_ind = i2
       3 prn_ind = i2
       3 constant_ind = i2
       3 med_order_type_cd = f8
       3 hide_flag = i2
       3 current_start_dt_tm = dq8
       3 current_start_tz = i4
       3 link_nbr = f8
       3 link_type_flag = i2
       3 freq_type_flag = i2
       3 order_details[*]
         4 action_sequence = i4
         4 detail_sequence = i4
         4 oe_field_id = f8
         4 oe_field_meaning = vc
         4 oe_field_meaning_id = f8
         4 oe_field_value = f8
         4 oe_field_display_value = vc
         4 oe_field_dt_tm = dq8
         4 oe_field_tz = i4
       3 verification_prsnl_id = f8
       3 verification_pos_cd = f8
     2 tasks[*]
       3 task_id = f8
       3 order_id = f8
       3 task_status_cd = f8
       3 task_status_disp = vc
       3 task_status_mean = vc
       3 task_class_cd = f8
       3 task_class_disp = vc
       3 task_class_mean = vc
       3 task_activity_cd = f8
       3 task_activity_disp = vc
       3 task_activity_mean = vc
       3 careset_id = f8
       3 iv_ind = i2
       3 tpn_ind = i2
       3 task_dt_tm = dq8
       3 updt_cnt = i4
       3 event_id = f8
       3 priv_ind = i2
       3 reference_task_id = f8
       3 task_type_cd = f8
       3 task_type_disp = vc
       3 task_type_mean = vc
       3 description = vc
       3 chart_not_done_ind = i2
       3 quick_chart_ind = i2
       3 event_cd = f8
       3 reschedule_time = i4
       3 dcp_forms_ref_id = f8
       3 task_priority_cd = f8
       3 task_priority_disp = vc
       3 task_priority_mean = vc
       3 task_tz = i4
       3 last_action_sequence = i4
     2 response_task_info[*]
       3 response_task_reference_id = f8
       3 response_task_description = vc
       3 response_event_cd = f8
     2 verification_prsnl_id = f8
     2 verification_pos_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET mar_temp
 RECORD mar_temp(
   1 order_cnt = i4
   1 orders[*]
     2 order_id = f8
     2 action_cnt = i4
     2 actions[*]
       3 action_sequence = i4
       3 verify_ind = i2
       3 clin_review_flag = i2
       3 prsnl_id = f8
       3 position_cd = f8
     2 details[*]
       3 action_sequence = i4
       3 oe_field_meaning_id = f8
   1 prns[*]
     2 order_index = i4
   1 missing_order_cnt = i4
   1 missing_orders[*]
     2 order_id = f8
 )
 DECLARE initialize(null) = null
 DECLARE loadinactiveorders(null) = null
 DECLARE loadactiveorders(null) = null
 DECLARE loadorderactions(startexpand=i4,endexpand=i4) = null
 DECLARE loadchildorders(null) = null
 DECLARE loadtasks(null) = null
 DECLARE populateverifyindicator(null) = null
 DECLARE loadresponsetaskinfo(null) = null
 DECLARE loadordercomments(null) = null
 DECLARE setrenewalindicators(null) = null
 DECLARE loaddtas(null) = null
 DECLARE loadcatalogeventcodes(null) = null
 DECLARE loadmissingorders(null) = null
 DECLARE last_mod = c3 WITH private, noconstant("000")
 SET reply->status_data.status = "F"
 DECLARE ordercount = i4 WITH noconstant(0)
 DECLARE encntr_cnt = i4 WITH noconstant(0)
 SET encntr_cnt = cnvtint(size(request->encntr_list,5))
 DECLARE prncnt = i4 WITH noconstant(0)
 DECLARE pharmacy_cd = f8 WITH constant(uar_get_code_by("MEANING",6000,"PHARMACY"))
 DECLARE hard_stop_cd = f8 WITH constant(uar_get_code_by("MEANING",4009,"HARD"))
 DECLARE soft_stop_cd = f8 WITH constant(uar_get_code_by("MEANING",4009,"SOFT"))
 DECLARE canceled_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"CANCELED"))
 DECLARE completed_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"COMPLETED"))
 DECLARE deleted_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"DELETED"))
 DECLARE discontinued_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"DISCONTINUED"))
 DECLARE trans_cancel_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"TRANS/CANCEL"))
 DECLARE voidedwrslt_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"VOIDEDWRSLT"))
 DECLARE pendingtaskcd = f8 WITH constant(uar_get_code_by("MEANING",79,"PENDING"))
 DECLARE overduetaskcd = f8 WITH constant(uar_get_code_by("MEANING",79,"OVERDUE"))
 DECLARE inprocesstaskcd = f8 WITH constant(uar_get_code_by("MEANING",79,"INPROCESS"))
 DECLARE pendingvaltaskcd = f8 WITH constant(uar_get_code_by("MEANING",79,"VALIDATION"))
 DECLARE inerrortaskcd = f8 WITH constant(uar_get_code_by("MEANING",79,"INERROR"))
 DECLARE completetaskcd = f8 WITH constant(uar_get_code_by("MEANING",79,"COMPLETE"))
 DECLARE renew_look_back = i4 WITH noconstant(24)
 DECLARE default_renew_look_back = i4 WITH noconstant(24)
 DECLARE userpositioncd = f8 WITH constant(reqinfo->position_cd)
 DECLARE prncd = f8 WITH constant(uar_get_code_by("MEANING",6025,"PRN"))
 DECLARE continuouscd = f8 WITH constant(uar_get_code_by("MEANING",6025,"CONT"))
 DECLARE nonscheduledcd = f8 WITH constant(uar_get_code_by("MEANING",6025,"NSCH"))
 DECLARE ivcd = f8 WITH constant(uar_get_code_by("MEANING",18309,"IV"))
 DECLARE begin_dt_tm = q8
 DECLARE stop_dt_tm = q8
 DECLARE current_dt_tm = q8
 DECLARE interval = vc
 DECLARE default_renew_dt_tm = q8
 DECLARE oidx = i4 WITH noconstant(0)
 DECLARE childcnt = i4 WITH noconstant(0)
 DECLARE detailcnt = i4 WITH noconstant(0)
 DECLARE idx = i4 WITH noconstant(0)
 DECLARE stat = i2 WITH noconstant(0)
 DECLARE exam = i2 WITH protect, noconstant(0)
 DECLARE icompoundchild = i2 WITH protect, constant(5)
 SET begin_dt_tm = cnvtdatetime(request->start_dt_tm)
 SET stop_dt_tm = cnvtdatetime(request->end_dt_tm)
 IF ((request->overdue_look_back > 0))
  SET begin_dt_tm = cnvtdatetime((curdate - request->overdue_look_back),curtime)
  IF (cnvtdatetime(begin_dt_tm) > cnvtdatetime(request->start_dt_tm))
   SET begin_dt_tm = cnvtdatetime(request->start_dt_tm)
  ENDIF
  IF (cnvtdatetime(curdate,curtime3) > cnvtdatetime(request->end_dt_tm))
   SET stop_dt_tm = cnvtdatetime(curdate,curtime3)
  ENDIF
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
 CALL initialize(null)
 CALL loadinactiveorders(null)
 CALL loadactiveorders(null)
 IF (ordercount > 0)
  CALL loadorderactions(1,ordercount)
  CALL loadchildorders(null)
 ENDIF
 CALL loadtasks(null)
 IF (ordercount > 0)
  CALL setrenewalindicators(null)
  CALL loadcatalogeventcodes(null)
  CALL loaddtas(null)
  CALL populateverifyindicator(null)
  CALL loadordercomments(null)
  IF (prncnt > 0)
   CALL loadresponsetaskinfo(null)
  ENDIF
 ENDIF
 IF (ordercount=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SUBROUTINE loadchildorders(null)
   DECLARE x = i4 WITH noconstant(0)
   DECLARE y = i4 WITH noconstant(0)
   SELECT INTO "nl:"
    FROM orders o
    PLAN (o
     WHERE expand(x,1,ordercount,o.template_order_id,reply->orders[x].order_id)
      AND ((o.current_start_dt_tm <= cnvtdatetime(request->end_dt_tm)
      AND o.projected_stop_dt_tm >= cnvtdatetime(request->start_dt_tm)) OR (o.current_start_dt_tm <=
     cnvtdatetime(request->end_dt_tm)
      AND o.projected_stop_dt_tm <= o.current_start_dt_tm)) )
    ORDER BY o.template_order_id, o.order_id
    HEAD o.template_order_id
     idx = locateval(y,1,ordercount,o.template_order_id,reply->orders[y].order_id), co_cnt = 0
    HEAD o.order_id
     co_cnt = (co_cnt+ 1)
     IF (mod(co_cnt,5)=1)
      stat = alterlist(reply->orders[idx].child_orders,(co_cnt+ 4))
     ENDIF
     reply->orders[idx].child_orders[co_cnt].order_id = o.order_id, reply->orders[idx].child_orders[
     co_cnt].encntr_id = o.encntr_id, reply->orders[idx].child_orders[co_cnt].catalog_cd = o
     .catalog_cd,
     reply->orders[idx].child_orders[co_cnt].catalog_type_cd = o.catalog_type_cd, reply->orders[idx].
     child_orders[co_cnt].core_action_sequence = o.template_core_action_sequence, reply->orders[idx].
     child_orders[co_cnt].need_nurse_review_ind = o.need_nurse_review_ind,
     reply->orders[idx].child_orders[co_cnt].prn_ind = o.prn_ind, reply->orders[idx].child_orders[
     co_cnt].constant_ind = o.constant_ind, reply->orders[idx].child_orders[co_cnt].med_order_type_cd
      = o.med_order_type_cd,
     reply->orders[idx].child_orders[co_cnt].hide_flag = o.hide_flag, reply->orders[idx].
     child_orders[co_cnt].current_start_dt_tm = o.current_start_dt_tm, reply->orders[idx].
     child_orders[co_cnt].current_start_tz = o.current_start_tz,
     reply->orders[idx].child_orders[co_cnt].link_nbr = o.link_nbr, reply->orders[idx].child_orders[
     co_cnt].link_type_flag = o.link_type_flag, reply->orders[idx].child_orders[co_cnt].
     freq_type_flag = o.freq_type_flag
    FOOT  o.template_order_id
     stat = alterlist(reply->orders[idx].child_orders,co_cnt)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE loadtasks(null)
   DECLARE x = i4 WITH noconstant(0)
   DECLARE y = i4 WITH noconstant(0)
   DECLARE z = i4 WITH noconstant(0)
   DECLARE i = i4 WITH noconstant(0)
   DECLARE j = i4 WITH noconstant(0)
   DECLARE k = i4 WITH noconstant(0)
   DECLARE cnt1 = i4 WITH noconstant(0), protected
   DECLARE cnt2 = i4 WITH noconstant(0), protected
   DECLARE cnt3 = i4 WITH noconstant(0), protected
   DECLARE inactive_order_cnt = i4 WITH noconstant(0), protected
   DECLARE person_clause = vc WITH noconstant(fillstring(100," "))
   DECLARE ordidx = i4 WITH noconstant(0), protected
   DECLARE cidx = i4 WITH noconstant(0), protected
   DECLARE mc_idx = i4 WITH noconstant(0), protected
   DECLARE mt_idx = i4 WITH noconstant(0), protected
   DECLARE child_order_id = f8 WITH noconstant(0.0), protected
   IF (encntr_cnt > 0)
    SET person_clause = "expand (x, 1, encntr_cnt, ta.encntr_id, request->encntr_list[x].encntr_id)"
   ELSE
    SET person_clause = "ta.person_id = request->person_id"
   ENDIF
   RECORD tasktemp(
     1 cnt = i4
     1 qual[*]
       2 reference_task_id = f8
       2 item_cnt = i4
       2 items[*]
         3 order_index = i4
         3 task_index = i4
     1 ordercnt = i4
     1 orders[*]
       2 order_index = i4
       2 order_id = f8
       2 detailcnt = i4
       2 details[*]
         3 action_sequence = i4
         3 detail_sequence = i4
         3 oe_field_id = f8
         3 oe_field_meaning = vc
         3 oe_field_meaning_id = f8
         3 oe_field_value = f8
         3 oe_field_display_value = vc
         3 oe_field_dt_tm = dq8
         3 oe_field_tz = i4
   )
   RECORD inactive_orders(
     1 qual[*]
       2 order_id = f8
   )
   SELECT INTO "nl:"
    sort_task_status = evaluate(ta.task_status_cd,pendingtaskcd,1,overduetaskcd,2,
     inprocesstaskcd,3,pendingvaltaskcd,4,completetaskcd,
     5,inerrortaskcd,6)
    FROM task_activity ta,
     orders o,
     order_task ot
    PLAN (ta
     WHERE parser(person_clause)
      AND ta.task_status_cd IN (pendingtaskcd, overduetaskcd, inprocesstaskcd, pendingvaltaskcd,
     completetaskcd,
     inerrortaskcd))
     JOIN (o
     WHERE o.order_id=ta.order_id
      AND o.catalog_type_cd=pharmacy_cd
      AND o.orig_ord_as_flag IN (0, 5))
     JOIN (ot
     WHERE ta.reference_task_id=ot.reference_task_id)
    ORDER BY o.template_order_id, sort_task_status, o.order_id,
     ta.task_id
    HEAD o.template_order_id
     IF ( NOT (ta.task_status_cd IN (completetaskcd, inerrortaskcd)))
      IF (o.template_order_id > 0)
       idx = locateval(i,1,ordercount,o.template_order_id,reply->orders[i].order_id)
       IF (idx <= 0)
        mar_temp->missing_order_cnt = (mar_temp->missing_order_cnt+ 1), stat = alterlist(mar_temp->
         missing_orders,mar_temp->missing_order_cnt), mar_temp->missing_orders[mar_temp->
        missing_order_cnt].order_id = o.template_order_id,
        ordercount = (ordercount+ 1), stat = alterlist(reply->orders,ordercount), idx = ordercount,
        reply->orders[idx].order_id = o.template_order_id
       ENDIF
       taskcnt = 0, tasktemp->ordercnt = (tasktemp->ordercnt+ 1)
       IF (mod(tasktemp->ordercnt,100)=1)
        stat = alterlist(tasktemp->orders,(tasktemp->ordercnt+ 99))
       ENDIF
       tasktemp->orders[tasktemp->ordercnt].order_id = o.template_order_id, tasktemp->orders[tasktemp
       ->ordercnt].order_index = idx
      ENDIF
     ENDIF
    HEAD o.order_id
     IF ( NOT (ta.task_status_cd IN (completetaskcd, inerrortaskcd)))
      IF (o.template_order_id=0)
       idx = locateval(i,1,ordercount,o.order_id,reply->orders[i].order_id)
       IF (idx <= 0)
        mar_temp->missing_order_cnt = (mar_temp->missing_order_cnt+ 1), stat = alterlist(mar_temp->
         missing_orders,mar_temp->missing_order_cnt), mar_temp->missing_orders[mar_temp->
        missing_order_cnt].order_id = o.order_id,
        ordercount = (ordercount+ 1), stat = alterlist(reply->orders,ordercount), idx = ordercount,
        reply->orders[idx].order_id = o.order_id
       ENDIF
       taskcnt = 0, tasktemp->ordercnt = (tasktemp->ordercnt+ 1)
       IF (mod(tasktemp->ordercnt,100)=1)
        stat = alterlist(tasktemp->orders,(tasktemp->ordercnt+ 99))
       ENDIF
       tasktemp->orders[tasktemp->ordercnt].order_id = o.order_id, tasktemp->orders[tasktemp->
       ordercnt].order_index = idx
      ELSE
       ordidx = locateval(j,1,ordercount,o.template_order_id,reply->orders[j].order_id), cidx = 0,
       childcnt = size(reply->orders[ordidx].child_orders,5),
       cidx = locateval(i,1,childcnt,o.order_id,reply->orders[ordidx].child_orders[i].order_id)
       IF (cidx <= 0
        AND ta.task_dt_tm >= cnvtdatetime(begin_dt_tm)
        AND ta.task_dt_tm <= cnvtdatetime(stop_dt_tm))
        co_cnt = size(reply->orders[ordidx].child_orders,5), co_cnt = (co_cnt+ 1), stat = alterlist(
         reply->orders[ordidx].child_orders,co_cnt),
        reply->orders[ordidx].child_orders[co_cnt].order_id = o.order_id, reply->orders[ordidx].
        child_orders[co_cnt].encntr_id = o.encntr_id, reply->orders[ordidx].child_orders[co_cnt].
        catalog_cd = o.catalog_cd,
        reply->orders[ordidx].child_orders[co_cnt].catalog_type_cd = o.catalog_type_cd, reply->
        orders[ordidx].child_orders[co_cnt].core_action_sequence = o.template_core_action_sequence,
        reply->orders[ordidx].child_orders[co_cnt].need_nurse_review_ind = o.need_nurse_review_ind,
        reply->orders[ordidx].child_orders[co_cnt].prn_ind = o.prn_ind, reply->orders[ordidx].
        child_orders[co_cnt].constant_ind = o.constant_ind, reply->orders[ordidx].child_orders[co_cnt
        ].med_order_type_cd = o.med_order_type_cd,
        reply->orders[ordidx].child_orders[co_cnt].hide_flag = o.hide_flag, reply->orders[ordidx].
        child_orders[co_cnt].current_start_dt_tm = o.current_start_dt_tm, reply->orders[ordidx].
        child_orders[co_cnt].current_start_tz = o.current_start_tz,
        reply->orders[ordidx].child_orders[co_cnt].link_nbr = o.link_nbr, reply->orders[ordidx].
        child_orders[co_cnt].link_type_flag = o.link_type_flag, reply->orders[ordidx].child_orders[
        co_cnt].freq_type_flag = o.freq_type_flag
       ENDIF
      ENDIF
     ENDIF
    HEAD ta.task_id
     IF (ta.task_status_cd IN (completetaskcd, inerrortaskcd)
      AND o.hide_flag=1)
      inactive_order_cnt = size(inactive_orders->qual,5), inactive_order_cnt = (inactive_order_cnt+ 1
      ), stat = alterlist(inactive_orders->qual,inactive_order_cnt),
      inactive_orders->qual[inactive_order_cnt].order_id = o.order_id
     ENDIF
     IF (ta.task_status_cd IN (pendingvaltaskcd))
      reply->orders[idx].child_orders[cidx].hide_flag = 0
     ENDIF
    DETAIL
     IF (((ta.task_class_cd IN (prncd, continuouscd, nonscheduledcd)) OR (ta.task_dt_tm >=
     cnvtdatetime(begin_dt_tm)
      AND ta.task_dt_tm <= cnvtdatetime(stop_dt_tm)))
      AND  NOT (ta.task_status_cd IN (completetaskcd, inerrortaskcd)))
      IF (size(reply->orders[idx].tasks,5) > 0
       AND taskcnt=0)
       taskcnt = (size(reply->orders[idx].tasks,5)+ 1)
      ELSE
       taskcnt = (taskcnt+ 1)
      ENDIF
      IF (taskcnt > size(reply->orders[idx].tasks,5))
       stat = alterlist(reply->orders[idx].tasks,(taskcnt+ 9))
      ENDIF
      reply->orders[idx].tasks[taskcnt].task_id = ta.task_id, reply->orders[idx].tasks[taskcnt].
      order_id = ta.order_id, reply->orders[idx].tasks[taskcnt].task_status_cd = ta.task_status_cd,
      reply->orders[idx].tasks[taskcnt].task_class_cd = ta.task_class_cd, reply->orders[idx].tasks[
      taskcnt].task_activity_cd = ta.task_activity_cd, reply->orders[idx].tasks[taskcnt].careset_id
       = ta.careset_id,
      reply->orders[idx].tasks[taskcnt].iv_ind = ta.iv_ind, reply->orders[idx].tasks[taskcnt].tpn_ind
       = ta.tpn_ind, reply->orders[idx].tasks[taskcnt].task_dt_tm = ta.task_dt_tm,
      reply->orders[idx].tasks[taskcnt].dcp_forms_ref_id = ot.dcp_forms_ref_id
      IF (ta.task_class_cd IN (prncd, continuouscd, nonscheduledcd)
       AND ta.task_status_cd=pendingtaskcd)
       IF (cnvtdatetime(curdate,curtime) > cnvtdatetime(ta.task_dt_tm))
        reply->orders[idx].tasks[taskcnt].task_dt_tm = cnvtdatetime(curdate,curtime)
       ENDIF
      ENDIF
      reply->orders[idx].tasks[taskcnt].updt_cnt = ta.updt_cnt, reply->orders[idx].tasks[taskcnt].
      event_id = ta.event_id
      IF (ot.allpositionchart_ind=1)
       reply->orders[idx].tasks[taskcnt].priv_ind = 1
      ELSE
       reply->orders[idx].tasks[taskcnt].priv_ind = 0, qidx = locateval(i,1,tasktemp->cnt,ta
        .reference_task_id,tasktemp->qual[i].reference_task_id)
       IF (qidx=0)
        tasktemp->cnt = (tasktemp->cnt+ 1)
        IF (mod(tasktemp->cnt,10)=1)
         stat = alterlist(tasktemp->qual,(tasktemp->cnt+ 9))
        ENDIF
        tasktemp->qual[tasktemp->cnt].reference_task_id = ta.reference_task_id, qidx = tasktemp->cnt
       ENDIF
       tasktemp->qual[qidx].item_cnt = (tasktemp->qual[qidx].item_cnt+ 1)
       IF (mod(tasktemp->qual[qidx].item_cnt,10)=1)
        stat = alterlist(tasktemp->qual[qidx].items,(tasktemp->qual[qidx].item_cnt+ 9))
       ENDIF
       tasktemp->qual[qidx].items[tasktemp->qual[qidx].item_cnt].order_index = idx, tasktemp->qual[
       qidx].items[tasktemp->qual[qidx].item_cnt].task_index = taskcnt
      ENDIF
      reply->orders[idx].tasks[taskcnt].reference_task_id = ta.reference_task_id, reply->orders[idx].
      tasks[taskcnt].task_type_cd = ta.task_type_cd, reply->orders[idx].tasks[taskcnt].description =
      ot.task_description,
      reply->orders[idx].tasks[taskcnt].chart_not_done_ind = ot.chart_not_cmplt_ind, reply->orders[
      idx].tasks[taskcnt].quick_chart_ind = ot.quick_chart_ind, reply->orders[idx].tasks[taskcnt].
      event_cd = ot.event_cd,
      reply->orders[idx].tasks[taskcnt].reschedule_time = ot.reschedule_time, reply->orders[idx].
      tasks[taskcnt].task_priority_cd = ta.task_priority_cd, reply->orders[idx].tasks[taskcnt].
      task_tz = ta.task_tz,
      reply->orders[idx].tasks[taskcnt].last_action_sequence = o.last_action_sequence
     ENDIF
    FOOT  o.order_id
     IF (o.template_order_id=0.0
      AND idx > 0
      AND taskcnt > 0)
      stat = alterlist(reply->orders[idx].tasks,taskcnt)
     ENDIF
    FOOT  o.template_order_id
     IF (o.template_order_id > 0
      AND idx > 0
      AND taskcnt > 0)
      stat = alterlist(reply->orders[idx].tasks,taskcnt)
     ENDIF
    WITH nocounter
   ;end select
   IF ((tasktemp->cnt > 0))
    CALL echo("****************************order task position xref**************************")
    SELECT INTO "nl:"
     FROM order_task_position_xref otpx
     PLAN (otpx
      WHERE expand(x,1,tasktemp->cnt,otpx.reference_task_id,tasktemp->qual[x].reference_task_id)
       AND otpx.position_cd=userpositioncd)
     DETAIL
      idx = locateval(i,1,tasktemp->cnt,otpx.reference_task_id,tasktemp->qual[i].reference_task_id)
      FOR (j = 1 TO tasktemp->qual[idx].item_cnt)
        reply->orders[tasktemp->qual[idx].items[j].order_index].tasks[tasktemp->qual[idx].items[j].
        task_index].priv_ind = 1
      ENDFOR
     WITH nocounter
    ;end select
   ENDIF
   IF ((mar_temp->missing_order_cnt > 0))
    CALL loadmissingorders(null)
   ENDIF
   IF ((tasktemp->ordercnt > 0))
    SELECT INTO "nl:"
     FROM order_detail od
     PLAN (od
      WHERE expand(x,1,tasktemp->ordercnt,od.order_id,tasktemp->orders[x].order_id)
       AND od.oe_field_meaning_id IN (57, 117, 141, 2043, 2050,
      2056, 2057, 2058, 2059, 2063))
     ORDER BY od.order_id, od.action_sequence
     HEAD od.order_id
      idx = locateval(i,1,tasktemp->ordercnt,od.order_id,tasktemp->orders[i].order_id), oidx =
      tasktemp->orders[idx].order_index, detailcnt = 0,
      detailcnt2 = 0
     DETAIL
      detailcnt = (detailcnt+ 1)
      IF (mod(detailcnt,6)=1)
       stat = alterlist(tasktemp->orders[idx].details,(detailcnt+ 5))
      ENDIF
      tasktemp->orders[idx].details[detailcnt].action_sequence = od.action_sequence, tasktemp->
      orders[idx].details[detailcnt].detail_sequence = od.detail_sequence, tasktemp->orders[idx].
      details[detailcnt].oe_field_id = od.oe_field_id,
      tasktemp->orders[idx].details[detailcnt].oe_field_meaning = od.oe_field_meaning, tasktemp->
      orders[idx].details[detailcnt].oe_field_meaning_id = od.oe_field_meaning_id, tasktemp->orders[
      idx].details[detailcnt].oe_field_value = od.oe_field_value,
      tasktemp->orders[idx].details[detailcnt].oe_field_display_value = od.oe_field_display_value,
      tasktemp->orders[idx].details[detailcnt].oe_field_dt_tm = od.oe_field_dt_tm_value, tasktemp->
      orders[idx].details[detailcnt].oe_field_tz = od.oe_field_tz,
      idx2 = locateval(i,1,detailcnt2,od.oe_field_meaning_id,reply->orders[oidx].order_details[i].
       oe_field_meaning_id)
      IF (idx2 <= 0)
       detailcnt2 = (detailcnt2+ 1), idx2 = detailcnt2
       IF (mod(detailcnt2,6)=1)
        stat = alterlist(reply->orders[oidx].order_details,(detailcnt2+ 5))
       ENDIF
      ENDIF
      reply->orders[oidx].order_details[idx2].action_sequence = od.action_sequence, reply->orders[
      oidx].order_details[idx2].detail_sequence = od.detail_sequence, reply->orders[oidx].
      order_details[idx2].oe_field_id = od.oe_field_id,
      reply->orders[oidx].order_details[idx2].oe_field_meaning = od.oe_field_meaning, reply->orders[
      oidx].order_details[idx2].oe_field_meaning_id = od.oe_field_meaning_id, reply->orders[oidx].
      order_details[idx2].oe_field_value = od.oe_field_value,
      reply->orders[oidx].order_details[idx2].oe_field_display_value = od.oe_field_display_value,
      reply->orders[oidx].order_details[idx2].oe_field_dt_tm = od.oe_field_dt_tm_value, reply->
      orders[oidx].order_details[idx2].oe_field_tz = od.oe_field_tz
     FOOT  od.order_id
      stat = alterlist(reply->orders[oidx].order_details,detailcnt2), tasktemp->orders[idx].detailcnt
       = detailcnt
     WITH nocounter
    ;end select
    FOR (x = 1 TO tasktemp->ordercnt)
      SET oidx = tasktemp->orders[x].order_index
      SET childcnt = size(reply->orders[oidx].child_orders,5)
      FOR (y = 1 TO childcnt)
        SET detailcnt = 0
        FOR (z = 1 TO tasktemp->orders[x].detailcnt)
          IF ((reply->orders[oidx].child_orders[y].core_action_sequence >= tasktemp->orders[x].
          details[z].action_sequence))
           SET idx = 0
           SET idx = locateval(i,1,detailcnt,tasktemp->orders[x].details[z].oe_field_meaning_id,reply
            ->orders[oidx].child_orders[y].order_details[i].oe_field_meaning_id)
           IF (idx <= 0)
            SET detailcnt = (detailcnt+ 1)
            SET idx = detailcnt
            IF (mod(detailcnt,6)=1)
             SET stat = alterlist(reply->orders[oidx].child_orders[y].order_details,(detailcnt+ 5))
            ENDIF
           ENDIF
           SET reply->orders[oidx].child_orders[y].order_details[idx].detail_sequence = tasktemp->
           orders[x].details[z].detail_sequence
           SET reply->orders[oidx].child_orders[y].order_details[idx].oe_field_id = tasktemp->orders[
           x].details[z].oe_field_id
           SET reply->orders[oidx].child_orders[y].order_details[idx].oe_field_meaning = tasktemp->
           orders[x].details[z].oe_field_meaning
           SET reply->orders[oidx].child_orders[y].order_details[idx].oe_field_meaning_id = tasktemp
           ->orders[x].details[z].oe_field_meaning_id
           SET reply->orders[oidx].child_orders[y].order_details[idx].oe_field_value = tasktemp->
           orders[x].details[z].oe_field_value
           SET reply->orders[oidx].child_orders[y].order_details[idx].oe_field_display_value =
           tasktemp->orders[x].details[z].oe_field_display_value
           SET reply->orders[oidx].child_orders[y].order_details[idx].oe_field_dt_tm = tasktemp->
           orders[x].details[z].oe_field_dt_tm
           SET reply->orders[oidx].child_orders[y].order_details[idx].oe_field_tz = tasktemp->orders[
           x].details[z].oe_field_tz
          ENDIF
        ENDFOR
        SET stat = alterlist(reply->orders[oidx].child_orders[y].order_details,detailcnt)
      ENDFOR
    ENDFOR
   ENDIF
   FOR (cnt1 = 1 TO size(inactive_orders->qual,5))
    SET child_order_id = inactive_orders->qual[cnt1].order_id
    FOR (cnt2 = 1 TO size(reply->orders,5))
      FOR (cnt3 = 1 TO size(reply->orders[cnt2].child_orders,5))
        IF ((child_order_id=reply->orders[cnt2].child_orders[cnt3].order_id))
         SET reply->orders[cnt2].child_orders[cnt3].hide_flag = 0
        ENDIF
      ENDFOR
    ENDFOR
   ENDFOR
   FREE RECORD tasktemp
   FREE RECORD inactive_orders
 END ;Subroutine
 SUBROUTINE loadorderactions(startexpand,endexpand)
   DECLARE order_cnt = i4 WITH noconstant(0), protected
   DECLARE action_cnt = i4 WITH noconstant(0), protected
   DECLARE expandx = i4 WITH noconstant(0), protected
   DECLARE oa_no_verify_needed = i2 WITH protect, constant(0)
   DECLARE oa_needs_verify = i2 WITH protect, constant(1)
   DECLARE oa_superceded = i2 WITH protect, constant(2)
   DECLARE oa_verified = i2 WITH protect, constant(3)
   DECLARE oa_rejected = i2 WITH protect, constant(4)
   DECLARE oa_reviewed = i2 WITH protect, constant(5)
   DECLARE o_verified = i2 WITH protect, constant(0)
   DECLARE o_needs_review = i2 WITH protect, constant(1)
   DECLARE o_rejected = i2 WITH protect, constant(2)
   DECLARE clinreviewflag_unset = i2 WITH protect, constant(0)
   DECLARE clinreviewflag_needs_review = i2 WITH protect, constant(1)
   DECLARE clinreviewflag_reviewed = i2 WITH protect, constant(2)
   DECLARE clinreviewflag_rejected = i2 WITH protect, constant(3)
   DECLARE clinreviewflag_dna = i2 WITH protect, constant(4)
   DECLARE clinreviewflag_superceded = i2 WITH protect, constant(5)
   SELECT INTO "nl:"
    FROM order_action oa,
     prsnl p
    PLAN (oa
     WHERE expand(expandx,startexpand,endexpand,oa.order_id,reply->orders[expandx].order_id))
     JOIN (p
     WHERE p.person_id=oa.action_personnel_id)
    ORDER BY oa.order_id, oa.action_sequence DESC
    HEAD REPORT
     order_cnt = mar_temp->order_cnt, action_cnt = 0
    HEAD oa.order_id
     order_cnt = (order_cnt+ 1)
     IF (order_cnt > size(mar_temp->orders,5))
      stat = alterlist(mar_temp->orders,(order_cnt+ 99))
     ENDIF
     mar_temp->orders[order_cnt].order_id = oa.order_id, action_cnt = 0
    DETAIL
     action_cnt = (action_cnt+ 1)
     IF (mod(action_cnt,10)=1)
      stat = alterlist(mar_temp->orders[order_cnt].actions,(action_cnt+ 9))
     ENDIF
     mar_temp->orders[order_cnt].actions[action_cnt].action_sequence = oa.action_sequence, mar_temp->
     orders[order_cnt].actions[action_cnt].prsnl_id = p.person_id, mar_temp->orders[order_cnt].
     actions[action_cnt].position_cd = p.position_cd
     CASE (oa.needs_verify_ind)
      OF oa_no_verify_needed:
       mar_temp->orders[order_cnt].actions[action_cnt].verify_ind = o_verified
      OF oa_needs_verify:
       mar_temp->orders[order_cnt].actions[action_cnt].verify_ind = o_needs_review
      OF oa_superceded:
       mar_temp->orders[order_cnt].actions[action_cnt].verify_ind = o_needs_review
      OF oa_verified:
       mar_temp->orders[order_cnt].actions[action_cnt].verify_ind = o_verified
      OF oa_rejected:
       mar_temp->orders[order_cnt].actions[action_cnt].verify_ind = o_rejected
      OF oa_reviewed:
       mar_temp->orders[order_cnt].actions[action_cnt].verify_ind = o_verified
     ENDCASE
     IF (oa.need_clin_review_flag=0)
      CASE (oa.needs_verify_ind)
       OF oa_no_verify_needed:
        mar_temp->orders[order_cnt].actions[action_cnt].clin_review_flag = clinreviewflag_dna
       OF oa_needs_verify:
        mar_temp->orders[order_cnt].actions[action_cnt].clin_review_flag =
        clinreviewflag_needs_review
       OF oa_superceded:
        mar_temp->orders[order_cnt].actions[action_cnt].clin_review_flag = clinreviewflag_superceded
       OF oa_verified:
        mar_temp->orders[order_cnt].actions[action_cnt].clin_review_flag = clinreviewflag_reviewed
       OF oa_rejected:
        mar_temp->orders[order_cnt].actions[action_cnt].clin_review_flag = clinreviewflag_rejected
       OF oa_reviewed:
        mar_temp->orders[order_cnt].actions[action_cnt].clin_review_flag = clinreviewflag_reviewed
      ENDCASE
     ELSE
      mar_temp->orders[order_cnt].actions[action_cnt].clin_review_flag = oa.need_clin_review_flag
     ENDIF
    FOOT  oa.order_id
     mar_temp->orders[order_cnt].action_cnt = action_cnt, stat = alterlist(mar_temp->orders[order_cnt
      ].actions,action_cnt)
    FOOT REPORT
     mar_temp->order_cnt = order_cnt, stat = alterlist(mar_temp->orders,order_cnt)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE populateverifyindicator(null)
   DECLARE x = i4 WITH noconstant(0), private
   DECLARE y = i4 WITH noconstant(0), private
   DECLARE prsnlid = f8 WITH noconstant(0.0), protected
   DECLARE positioncd = f8 WITH noconstant(0.0), protected
   DECLARE verifyind = i4 WITH noconstant(0), protected
   DECLARE reviewflag = i4 WITH noconstant(0), protected
   DECLARE orderidx = i4 WITH noconstant(0), protected
   DECLARE lorderidx = i4 WITH noconstant(0), protected
   DECLARE actionidx = i4 WITH noconstant(0), protected
   DECLARE lactionidx = i4 WITH noconstant(0), protected
   FOR (x = 1 TO size(reply->orders,5))
    SET orderidx = locateval(lorderidx,1,mar_temp->order_cnt,reply->orders[x].order_id,mar_temp->
     orders[lorderidx].order_id)
    IF (orderidx > 0)
     SET actionidx = locateval(lactionidx,1,mar_temp->orders[orderidx].action_cnt,reply->orders[x].
      last_action_sequence,mar_temp->orders[orderidx].actions[lactionidx].action_sequence)
     IF (actionidx > 0)
      SET verifyind = mar_temp->orders[orderidx].actions[actionidx].verify_ind
      SET reviewflag = mar_temp->orders[orderidx].actions[actionidx].clin_review_flag
      SET prsnlid = mar_temp->orders[orderidx].actions[actionidx].prsnl_id
      SET positioncd = mar_temp->orders[orderidx].actions[actionidx].position_cd
     ELSE
      SET verifyind = mar_temp->orders[orderidx].actions[1].verify_ind
      SET reviewflag = mar_temp->orders[orderidx].actions[1].clin_review_flag
      SET prsnlid = mar_temp->orders[orderidx].actions[1].prsnl_id
      SET positioncd = mar_temp->orders[orderidx].actions[1].position_cd
     ENDIF
     SET reply->orders[x].need_rx_verify_ind = verifyind
     SET reply->orders[x].need_rx_clin_review_flag = reviewflag
     IF ( NOT (reviewflag IN (2, 4)))
      SET reply->orders[x].verification_prsnl_id = prsnlid
      SET reply->orders[x].verification_pos_cd = positioncd
     ENDIF
     FOR (y = 1 TO size(reply->orders[x].child_orders,5))
       SET actionidx = locateval(lactionidx,1,mar_temp->orders[orderidx].action_cnt,reply->orders[x].
        child_orders[y].core_action_sequence,mar_temp->orders[orderidx].actions[lactionidx].
        action_sequence)
       IF (actionidx > 0)
        SET verifyind = mar_temp->orders[orderidx].actions[actionidx].verify_ind
        SET reviewflag = mar_temp->orders[orderidx].actions[actionidx].clin_review_flag
        SET prsnlid = mar_temp->orders[orderidx].actions[actionidx].prsnl_id
        SET positioncd = mar_temp->orders[orderidx].actions[actionidx].position_cd
       ELSE
        SET verifyind = mar_temp->orders[orderidx].actions[1].verify_ind
        SET reviewflag = mar_temp->orders[orderidx].actions[1].clin_review_flag
        SET prsnlid = mar_temp->orders[orderidx].actions[1].prsnl_id
        SET positioncd = mar_temp->orders[orderidx].actions[1].position_cd
       ENDIF
       SET reply->orders[x].child_orders[y].need_rx_verify_ind = verifyind
       SET reply->orders[x].child_orders[y].need_rx_clin_review_flag = reviewflag
       IF ( NOT (reviewflag IN (2, 4)))
        SET reply->orders[x].child_orders[y].verification_prsnl_id = prsnlid
        SET reply->orders[x].child_orders[y].verification_pos_cd = positioncd
       ENDIF
     ENDFOR
    ELSE
     CALL echo(build("PopulateVerifyIndicator - order not found in MAR_TEMP. order_id=",reply->
       orders[x].order_id))
    ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE loadresponsetaskinfo(null)
   DECLARE x = i4 WITH noconstant(0)
   DECLARE y = i4 WITH noconstant(0)
   DECLARE rcnt = i4 WITH noconstant(0)
   DECLARE responsetasks = i4 WITH noconstant(0)
   RECORD response_temp(
     1 qual[*]
       2 catalog_cd = f8
       2 reference_task_id = f8
       2 task_description = vc
       2 event_cd = f8
   )
   SET stat = alterlist(response_temp->qual,prncnt)
   SELECT INTO "nl:"
    FROM order_task_xref otxr,
     order_task_response otr,
     order_task ot
    PLAN (otxr
     WHERE expand(x,1,prncnt,otxr.catalog_cd,reply->orders[mar_temp->prns[x].order_index].catalog_cd)
     )
     JOIN (otr
     WHERE otr.reference_task_id=otxr.reference_task_id)
     JOIN (ot
     WHERE ot.reference_task_id=otr.response_task_id)
    DETAIL
     rcnt = (rcnt+ 1)
     IF (rcnt > prncnt)
      stat = alterlist(response_temp->qual,rcnt)
     ENDIF
     response_temp->qual[rcnt].catalog_cd = otxr.catalog_cd, response_temp->qual[rcnt].
     reference_task_id = otr.reference_task_id, response_temp->qual[rcnt].task_description = ot
     .task_description,
     response_temp->qual[rcnt].event_cd = ot.event_cd
    WITH nocounter
   ;end select
   FOR (y = 1 TO prncnt)
    SET responsetasks = 0
    FOR (x = 1 TO rcnt)
      IF ((reply->orders[mar_temp->prns[y].order_index].catalog_cd=response_temp->qual[x].catalog_cd)
      )
       SET responsetasks = (responsetasks+ 1)
       SET stat = alterlist(reply->orders[mar_temp->prns[y].order_index].response_task_info,
        responsetasks)
       SET reply->orders[mar_temp->prns[y].order_index].response_task_info[responsetasks].
       response_task_reference_id = response_temp->qual[x].reference_task_id
       SET reply->orders[mar_temp->prns[y].order_index].response_task_info[responsetasks].
       response_task_description = response_temp->qual[x].task_description
       SET reply->orders[mar_temp->prns[y].order_index].response_task_info[responsetasks].
       response_event_cd = response_temp->qual[x].event_cd
      ENDIF
    ENDFOR
   ENDFOR
 END ;Subroutine
 SUBROUTINE loadordercomments(null)
   DECLARE x = i4 WITH noconstant(0)
   DECLARE tempcnt = i4 WITH noconstant(0)
   DECLARE order_comment_cd = f8 WITH constant(uar_get_code_by("MEANING",14,"ORD COMMENT"))
   DECLARE order_comment_mask = i4 WITH constant(1)
   RECORD commenttemp(
     1 qual[*]
       2 index = i4
   )
   SET stat = alterlist(commenttemp->qual,ordercount)
   FOR (x = 1 TO ordercount)
     IF (band(reply->orders[x].comment_type_mask,order_comment_mask)=order_comment_mask)
      SET tempcnt = (tempcnt+ 1)
      SET commenttemp->qual[tempcnt].index = x
     ENDIF
   ENDFOR
   IF (tempcnt > 0)
    SELECT INTO "nl:"
     FROM order_comment oc,
      long_text lt
     PLAN (oc
      WHERE expand(x,1,tempcnt,oc.order_id,reply->orders[commenttemp->qual[x].index].order_id)
       AND oc.comment_type_cd=order_comment_cd)
      JOIN (lt
      WHERE lt.long_text_id=oc.long_text_id)
     ORDER BY oc.order_id, oc.action_sequence
     HEAD oc.order_id
      idx = 0
      FOR (y = 1 TO tempcnt)
        IF ((reply->orders[commenttemp->qual[y].index].order_id=oc.order_id))
         idx = commenttemp->qual[y].index, y = (tempcnt+ 1)
        ENDIF
      ENDFOR
     FOOT  oc.order_id
      reply->orders[idx].order_comment_text = lt.long_text
     WITH nocounter
    ;end select
   ENDIF
   FREE RECORD commenttemp
 END ;Subroutine
 SUBROUTINE loadinactiveorders(null)
   DECLARE x = i4 WITH noconstant(0)
   DECLARE encntr_in_clause = vc WITH noconstant(fillstring(100," "))
   IF (encntr_cnt > 0)
    SET encntr_in_clause =
    "expand (x, 1, encntr_cnt, o.encntr_id, request->encntr_list[x].encntr_id)"
   ELSE
    SET encntr_in_clause = "0=0"
   ENDIF
   SELECT INTO "nl:"
    FROM orders o,
     order_ingredient oi,
     order_catalog oc,
     order_catalog_synonym ocs
    PLAN (o
     WHERE (o.person_id=request->person_id)
      AND o.projected_stop_dt_tm >= cnvtdatetime(begin_dt_tm)
      AND o.catalog_type_cd=pharmacy_cd
      AND ((o.template_order_id+ 0)=0)
      AND ((o.order_status_cd+ 0) IN (canceled_cd, completed_cd, deleted_cd, discontinued_cd,
     trans_cancel_cd,
     voidedwrslt_cd))
      AND ((o.template_order_flag+ 0) IN (0, 1, 4))
      AND ((o.orderable_type_flag+ 0) IN (0, 1, 8, 10, 11))
      AND parser(encntr_in_clause)
      AND o.current_start_dt_tm <= cnvtdatetime(request->end_dt_tm)
      AND o.orig_ord_as_flag IN (0, 5))
     JOIN (oi
     WHERE o.order_id=oi.order_id)
     JOIN (oc
     WHERE oc.catalog_cd=oi.catalog_cd)
     JOIN (ocs
     WHERE ocs.synonym_id=oi.synonym_id
      AND ocs.active_ind=1)
    ORDER BY o.order_id, oi.action_sequence DESC, oi.comp_sequence
    HEAD REPORT
     ordercount = 0
    HEAD o.order_id
     max_sequence = oi.action_sequence, ingcnt = 0, addorder = 0
     IF (((o.template_order_flag IN (1, 0)
      AND ((o.projected_stop_dt_tm=null) OR (((o.projected_stop_dt_tm >= cnvtdatetime(request->
      start_dt_tm)) OR (o.stop_type_cd=soft_stop_cd)) )) ) OR (o.template_order_flag=4
      AND ((o.projected_stop_dt_tm=null) OR (o.projected_stop_dt_tm >= cnvtdatetime(request->
      start_dt_tm))) )) )
      addorder = 1, ordercount = (ordercount+ 1)
      IF (mod(ordercount,20)=1)
       stat = alterlist(reply->orders,(ordercount+ 19))
      ENDIF
      reply->orders[ordercount].order_id = o.order_id, reply->orders[ordercount].encntr_id = o
      .encntr_id, reply->orders[ordercount].person_id = o.person_id,
      reply->orders[ordercount].order_status_cd = o.order_status_cd, reply->orders[ordercount].
      display_line = trim(o.clinical_display_line), reply->orders[ordercount].order_mnemonic = o
      .order_mnemonic,
      reply->orders[ordercount].hna_order_mnemonic = o.hna_order_mnemonic, reply->orders[ordercount].
      ordered_as_mnemonic = o.ordered_as_mnemonic, reply->orders[ordercount].catalog_cd = o
      .catalog_cd,
      reply->orders[ordercount].comment_type_mask = o.comment_type_mask, reply->orders[ordercount].
      constant_ind = o.constant_ind, reply->orders[ordercount].prn_ind = o.prn_ind,
      reply->orders[ordercount].ingredient_ind = o.ingredient_ind, reply->orders[ordercount].
      need_nurse_review_ind = o.need_nurse_review_ind, reply->orders[ordercount].med_order_type_cd =
      o.med_order_type_cd,
      reply->orders[ordercount].link_nbr = o.link_nbr, reply->orders[ordercount].link_type_flag = o
      .link_type_flag, reply->orders[ordercount].need_renew_ind = 0,
      reply->orders[ordercount].last_action_sequence = o.last_action_sequence, reply->orders[
      ordercount].core_action_sequence = o.template_core_action_sequence, reply->orders[ordercount].
      freq_type_flag = o.freq_type_flag,
      reply->orders[ordercount].current_start_dt_tm = o.current_start_dt_tm, reply->orders[ordercount
      ].current_start_tz = o.current_start_tz, reply->orders[ordercount].projected_stop_dt_tm = o
      .projected_stop_dt_tm,
      reply->orders[ordercount].projected_stop_tz = o.projected_stop_tz, reply->orders[ordercount].
      stop_type_cd = o.stop_type_cd, reply->orders[ordercount].orderable_type_flag = o
      .orderable_type_flag,
      reply->orders[ordercount].template_order_flag = o.template_order_flag, reply->orders[ordercount
      ].iv_ind = o.iv_ind
      IF (o.prn_ind > 0)
       prncnt = (prncnt+ 1)
       IF (mod(prncnt,10)=1)
        stat = alterlist(mar_temp->prns,(prncnt+ 9))
       ENDIF
       mar_temp->prns[prncnt].order_index = ordercount
      ENDIF
     ENDIF
    DETAIL
     IF (addorder > 0)
      IF (oc.catalog_cd=o.catalog_cd)
       reply->orders[ordercount].catalog_cd = oc.catalog_cd, reply->orders[ordercount].
       catalog_type_cd = oc.catalog_type_cd, reply->orders[ordercount].activity_type_cd = oc
       .activity_type_cd
      ENDIF
      addingredient = 1
      FOR (i = 1 TO ingcnt)
        IF ((reply->orders[ordercount].order_ingredient[i].catalog_cd=oc.catalog_cd)
         AND (oi.action_sequence != reply->orders[ordercount].order_ingredient[i].action_sequence))
         i = (ingcnt+ 1), addingredient = 0
        ENDIF
      ENDFOR
      IF (addingredient)
       ingcnt = (ingcnt+ 1)
       IF (mod(ingcnt,5)=1)
        stat = alterlist(reply->orders[ordercount].order_ingredient,(ingcnt+ 4))
       ENDIF
       reply->orders[ordercount].order_ingredient[ingcnt].catalog_cd = oc.catalog_cd, reply->orders[
       ordercount].order_ingredient[ingcnt].primary_mnemonic = oc.primary_mnemonic, reply->orders[
       ordercount].order_ingredient[ingcnt].ingredient_type_flag = oi.ingredient_type_flag,
       reply->orders[ordercount].order_ingredient[ingcnt].ref_text_mask = oc.ref_text_mask, reply->
       orders[ordercount].order_ingredient[ingcnt].cki = oc.cki, reply->orders[ordercount].
       order_ingredient[ingcnt].action_sequence = oi.action_sequence,
       reply->orders[ordercount].order_ingredient[ingcnt].comp_sequence = oi.comp_sequence, reply->
       orders[ordercount].order_ingredient[ingcnt].synonym_id = oi.synonym_id, reply->orders[
       ordercount].order_ingredient[ingcnt].ordered_as_mnemonic = oi.ordered_as_mnemonic,
       reply->orders[ordercount].order_ingredient[ingcnt].order_mnemonic = oi.order_mnemonic, reply->
       orders[ordercount].order_ingredient[ingcnt].hna_order_mnemonic = oi.hna_order_mnemonic, reply
       ->orders[ordercount].order_ingredient[ingcnt].strength = oi.strength,
       reply->orders[ordercount].order_ingredient[ingcnt].strength_unit = oi.strength_unit, reply->
       orders[ordercount].order_ingredient[ingcnt].volume = oi.volume, reply->orders[ordercount].
       order_ingredient[ingcnt].volume_unit = oi.volume_unit,
       reply->orders[ordercount].order_ingredient[ingcnt].freetext_dose = oi.freetext_dose, reply->
       orders[ordercount].order_ingredient[ingcnt].clinically_significant_flag = oi
       .clinically_significant_flag, reply->orders[ordercount].order_ingredient[ingcnt].
       ingredientrateconversionind = ocs.ingredient_rate_conversion_ind,
       reply->orders[ordercount].order_ingredient[ingcnt].freq_cd = oi.freq_cd, reply->orders[
       ordercount].order_ingredient[ingcnt].normalized_rate = oi.normalized_rate, reply->orders[
       ordercount].order_ingredient[ingcnt].normalized_rate_unit_cd = oi.normalized_rate_unit_cd,
       reply->orders[ordercount].order_ingredient[ingcnt].concentration = oi.concentration, reply->
       orders[ordercount].order_ingredient[ingcnt].concentration_unit_cd = oi.concentration_unit_cd
       IF (oi.action_sequence=max_sequence)
        reply->orders[ordercount].order_ingredient[ingcnt].active_ind = 1
       ELSE
        reply->orders[ordercount].order_ingredient[ingcnt].active_ind = 0
       ENDIF
      ENDIF
     ENDIF
    FOOT  o.order_id
     IF (addorder > 0)
      stat = alterlist(reply->orders[ordercount].order_ingredient,ingcnt)
     ENDIF
    FOOT REPORT
     stat = alterlist(reply->orders,ordercount)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE loadactiveorders(null)
   DECLARE ordersz = i4 WITH noconstant(ordercount)
   DECLARE x = i4 WITH noconstant(0)
   DECLARE encntr_in_clause = vc WITH noconstant(fillstring(100," "))
   IF (encntr_cnt > 0)
    SET encntr_in_clause =
    "expand (x, 1, encntr_cnt, o.encntr_id, request->encntr_list[x].encntr_id)"
   ELSE
    SET encntr_in_clause = "0=0"
   ENDIF
   SELECT INTO "nl:"
    FROM orders o,
     order_ingredient oi,
     order_catalog oc,
     order_catalog_synonym ocs
    PLAN (o
     WHERE (o.person_id=request->person_id)
      AND o.catalog_type_cd=pharmacy_cd
      AND  NOT (((o.order_status_cd+ 0) IN (canceled_cd, completed_cd, deleted_cd, discontinued_cd,
     trans_cancel_cd,
     voidedwrslt_cd)))
      AND ((o.template_order_id+ 0)=0)
      AND ((o.template_order_flag+ 0) IN (0, 1, 4))
      AND ((o.orderable_type_flag+ 0) IN (0, 1, 8, 10, 11))
      AND parser(encntr_in_clause)
      AND o.orig_ord_as_flag IN (0, 5))
     JOIN (oi
     WHERE o.order_id=oi.order_id)
     JOIN (oc
     WHERE oc.catalog_cd=oi.catalog_cd)
     JOIN (ocs
     WHERE ocs.synonym_id=oi.synonym_id
      AND ocs.active_ind=1)
    ORDER BY o.order_id, oi.action_sequence DESC, oi.comp_sequence
    HEAD o.order_id
     max_sequence = oi.action_sequence, ingcnt = 0, ordercount = (ordercount+ 1)
     IF (ordercount > ordersz)
      ordersz = (ordersz+ 19), stat = alterlist(reply->orders,ordersz)
     ENDIF
     reply->orders[ordercount].order_id = o.order_id, reply->orders[ordercount].encntr_id = o
     .encntr_id, reply->orders[ordercount].person_id = o.person_id,
     reply->orders[ordercount].order_status_cd = o.order_status_cd, reply->orders[ordercount].
     display_line = trim(o.clinical_display_line), reply->orders[ordercount].order_mnemonic = o
     .order_mnemonic,
     reply->orders[ordercount].hna_order_mnemonic = o.hna_order_mnemonic, reply->orders[ordercount].
     ordered_as_mnemonic = o.ordered_as_mnemonic, reply->orders[ordercount].catalog_cd = o.catalog_cd,
     reply->orders[ordercount].comment_type_mask = o.comment_type_mask, reply->orders[ordercount].
     constant_ind = o.constant_ind, reply->orders[ordercount].prn_ind = o.prn_ind,
     reply->orders[ordercount].ingredient_ind = o.ingredient_ind, reply->orders[ordercount].
     need_nurse_review_ind = o.need_nurse_review_ind, reply->orders[ordercount].med_order_type_cd = o
     .med_order_type_cd,
     reply->orders[ordercount].link_nbr = o.link_nbr, reply->orders[ordercount].link_type_flag = o
     .link_type_flag, renew_dt_tm = default_renew_dt_tm
     IF (o.stop_type_cd=hard_stop_cd
      AND o.projected_stop_dt_tm < cnvtdatetime(renew_dt_tm))
      reply->orders[ordercount].need_renew_ind = 2
     ELSEIF (o.stop_type_cd=soft_stop_cd
      AND o.projected_stop_dt_tm < cnvtdatetime(renew_dt_tm))
      reply->orders[ordercount].need_renew_ind = 1
     ELSE
      reply->orders[ordercount].need_renew_ind = 0
     ENDIF
     reply->orders[ordercount].last_action_sequence = o.last_action_sequence, reply->orders[
     ordercount].core_action_sequence = o.template_core_action_sequence, reply->orders[ordercount].
     freq_type_flag = o.freq_type_flag,
     reply->orders[ordercount].current_start_dt_tm = o.current_start_dt_tm, reply->orders[ordercount]
     .current_start_tz = o.current_start_tz, reply->orders[ordercount].projected_stop_dt_tm = o
     .projected_stop_dt_tm,
     reply->orders[ordercount].projected_stop_tz = o.projected_stop_tz, reply->orders[ordercount].
     stop_type_cd = o.stop_type_cd, reply->orders[ordercount].orderable_type_flag = o
     .orderable_type_flag,
     reply->orders[ordercount].template_order_flag = o.template_order_flag, reply->orders[ordercount]
     .iv_ind = o.iv_ind
     IF (o.prn_ind > 0)
      prncnt = (prncnt+ 1)
      IF (mod(prncnt,10)=1)
       stat = alterlist(mar_temp->prns,(prncnt+ 9))
      ENDIF
      mar_temp->prns[prncnt].order_index = ordercount
     ENDIF
    DETAIL
     IF (oc.catalog_cd=o.catalog_cd)
      reply->orders[ordercount].catalog_cd = oc.catalog_cd, reply->orders[ordercount].catalog_type_cd
       = oc.catalog_type_cd, reply->orders[ordercount].activity_type_cd = oc.activity_type_cd
     ENDIF
     addingredient = 1
     FOR (i = 1 TO ingcnt)
       IF ((reply->orders[ordercount].order_ingredient[i].catalog_cd=oc.catalog_cd)
        AND (oi.action_sequence != reply->orders[ordercount].order_ingredient[i].action_sequence))
        i = (ingcnt+ 1), addingredient = 0
       ENDIF
     ENDFOR
     IF (addingredient)
      ingcnt = (ingcnt+ 1)
      IF (mod(ingcnt,5)=1)
       stat = alterlist(reply->orders[ordercount].order_ingredient,(ingcnt+ 4))
      ENDIF
      reply->orders[ordercount].order_ingredient[ingcnt].catalog_cd = oc.catalog_cd, reply->orders[
      ordercount].order_ingredient[ingcnt].primary_mnemonic = oc.primary_mnemonic, reply->orders[
      ordercount].order_ingredient[ingcnt].ingredient_type_flag = oi.ingredient_type_flag,
      reply->orders[ordercount].order_ingredient[ingcnt].ref_text_mask = oc.ref_text_mask, reply->
      orders[ordercount].order_ingredient[ingcnt].cki = oc.cki, reply->orders[ordercount].
      order_ingredient[ingcnt].action_sequence = oi.action_sequence,
      reply->orders[ordercount].order_ingredient[ingcnt].comp_sequence = oi.comp_sequence, reply->
      orders[ordercount].order_ingredient[ingcnt].synonym_id = oi.synonym_id, reply->orders[
      ordercount].order_ingredient[ingcnt].ordered_as_mnemonic = oi.ordered_as_mnemonic,
      reply->orders[ordercount].order_ingredient[ingcnt].order_mnemonic = oi.order_mnemonic, reply->
      orders[ordercount].order_ingredient[ingcnt].hna_order_mnemonic = oi.hna_order_mnemonic, reply->
      orders[ordercount].order_ingredient[ingcnt].strength = oi.strength,
      reply->orders[ordercount].order_ingredient[ingcnt].strength_unit = oi.strength_unit, reply->
      orders[ordercount].order_ingredient[ingcnt].volume = oi.volume, reply->orders[ordercount].
      order_ingredient[ingcnt].volume_unit = oi.volume_unit,
      reply->orders[ordercount].order_ingredient[ingcnt].freetext_dose = oi.freetext_dose, reply->
      orders[ordercount].order_ingredient[ingcnt].clinically_significant_flag = oi
      .clinically_significant_flag, reply->orders[ordercount].order_ingredient[ingcnt].
      ingredientrateconversionind = ocs.ingredient_rate_conversion_ind,
      reply->orders[ordercount].order_ingredient[ingcnt].freq_cd = oi.freq_cd, reply->orders[
      ordercount].order_ingredient[ingcnt].normalized_rate = oi.normalized_rate, reply->orders[
      ordercount].order_ingredient[ingcnt].normalized_rate_unit_cd = oi.normalized_rate_unit_cd,
      reply->orders[ordercount].order_ingredient[ingcnt].concentration = oi.concentration, reply->
      orders[ordercount].order_ingredient[ingcnt].concentration_unit_cd = oi.concentration_unit_cd
      IF (oi.action_sequence=max_sequence)
       reply->orders[ordercount].order_ingredient[ingcnt].active_ind = 1
      ELSE
       reply->orders[ordercount].order_ingredient[ingcnt].active_ind = 0
      ENDIF
     ENDIF
    FOOT  o.order_id
     stat = alterlist(reply->orders[ordercount].order_ingredient,ingcnt)
    FOOT REPORT
     stat = alterlist(reply->orders,ordercount)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE initialize(null)
   SET ordercount = 0
 END ;Subroutine
 SUBROUTINE setrenewalindicators(null)
   DECLARE x = i4 WITH noconstant(0)
   DECLARE y = i4 WITH noconstant(0)
   DECLARE catalogcnt = i4 WITH noconstant(0)
   RECORD renewtemp(
     1 qual[*]
       2 catalog_cd = f8
   )
   SET stat = alterlist(renewtemp->qual,ordercount)
   FOR (x = 1 TO ordercount)
     IF ((((reply->orders[x].stop_type_cd=hard_stop_cd)) OR ((reply->orders[x].stop_type_cd=
     soft_stop_cd))) )
      SET catalogcnt = (catalogcnt+ 1)
      SET renewtemp->qual[catalogcnt].catalog_cd = reply->orders[x].catalog_cd
     ENDIF
   ENDFOR
   IF (catalogcnt > 0)
    SELECT INTO "nl:"
     FROM order_catalog oc,
      renew_notification_period rnp
     PLAN (oc
      WHERE expand(x,1,catalogcnt,oc.catalog_cd,renewtemp->qual[x].catalog_cd))
      JOIN (rnp
      WHERE rnp.stop_type_cd=oc.stop_type_cd
       AND rnp.stop_duration=oc.stop_duration
       AND rnp.stop_duration_unit_cd=oc.stop_duration_unit_cd)
     DETAIL
      IF (rnp.stop_duration > 0
       AND rnp.stop_duration_unit_cd > 0)
       renew_look_back = cnvtint(rnp.notification_period), interval = build(renew_look_back,"h"),
       renew_dt_tm = cnvtlookahead(interval,cnvtdatetime(current_dt_tm))
       FOR (y = 1 TO ordercount)
         IF ((reply->orders[y].catalog_cd=oc.catalog_cd))
          IF ((reply->orders[y].projected_stop_dt_tm < cnvtdatetime(renew_dt_tm)))
           IF ((reply->orders[y].stop_type_cd=hard_stop_cd))
            reply->orders[y].need_renew_ind = 2
           ELSEIF ((reply->orders[y].stop_type_cd=soft_stop_cd))
            reply->orders[y].need_renew_ind = 1
           ENDIF
          ENDIF
         ENDIF
       ENDFOR
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   FREE RECORD renewtemp
 END ;Subroutine
 SUBROUTINE loaddtas(null)
   DECLARE x = i4 WITH noconstant(0)
   DECLARE y = i4 WITH noconstant(0)
   SELECT INTO "nl:"
    FROM order_ingredient oi,
     order_task_xref otxr,
     task_discrete_r tdr,
     discrete_task_assay dta
    PLAN (oi
     WHERE expand(x,1,ordercount,oi.order_id,reply->orders[x].order_id)
      AND oi.ingredient_type_flag != icompoundchild)
     JOIN (otxr
     WHERE otxr.catalog_cd=oi.catalog_cd)
     JOIN (tdr
     WHERE otxr.reference_task_id=tdr.reference_task_id)
     JOIN (dta
     WHERE tdr.task_assay_cd=dta.task_assay_cd
      AND dta.event_cd > 0)
    ORDER BY oi.order_id, oi.catalog_cd, tdr.sequence
    HEAD oi.order_id
     oidx = locateval(y,1,ordercount,oi.order_id,reply->orders[y].order_id), ingredcnt = size(reply->
      orders[oidx].order_ingredient,5)
    HEAD oi.catalog_cd
     cidx = locateval(y,1,ingredcnt,oi.catalog_cd,reply->orders[oidx].order_ingredient[y].catalog_cd),
     dtacnt = 0
    DETAIL
     IF ((reply->orders[oidx].med_order_type_cd != ivcd))
      dtacnt = (dtacnt+ 1)
      IF (mod(dtacnt,5)=1)
       stat = alterlist(reply->orders[oidx].order_ingredient[cidx].discretes,(dtacnt+ 4))
      ENDIF
      reply->orders[oidx].order_ingredient[cidx].discretes[dtacnt].event_cd = dta.event_cd
     ENDIF
    FOOT  oi.catalog_cd
     stat = alterlist(reply->orders[oidx].order_ingredient[cidx].discretes,dtacnt)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE loadcatalogeventcodes(null)
   DECLARE x = i4 WITH noconstant(0)
   DECLARE y = i4 WITH noconstant(0)
   SELECT INTO "nl:"
    FROM order_ingredient oi,
     code_value_event_r cver
    PLAN (oi
     WHERE expand(x,1,ordercount,oi.order_id,reply->orders[x].order_id))
     JOIN (cver
     WHERE cver.parent_cd=oi.catalog_cd)
    ORDER BY oi.order_id, oi.catalog_cd
    HEAD oi.order_id
     oidx = locateval(y,1,ordercount,oi.order_id,reply->orders[y].order_id), ingredcnt = size(reply->
      orders[oidx].order_ingredient,5)
    DETAIL
     FOR (i = 1 TO ingredcnt)
      IF ((reply->orders[oidx].catalog_cd=oi.catalog_cd))
       reply->orders[oidx].event_cd = cver.event_cd
      ENDIF
      ,
      IF ((reply->orders[oidx].order_ingredient[i].catalog_cd=oi.catalog_cd))
       reply->orders[oidx].order_ingredient[i].event_cd = cver.event_cd
      ENDIF
     ENDFOR
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE loadmissingorders(null)
   DECLARE ordersz = i4 WITH noconstant(ordercount)
   SELECT INTO "nl:"
    FROM orders o,
     order_ingredient oi,
     order_catalog oc,
     order_catalog_synonym ocs
    PLAN (o
     WHERE expand(x,1,mar_temp->missing_order_cnt,o.order_id,mar_temp->missing_orders[x].order_id))
     JOIN (oi
     WHERE o.order_id=oi.order_id)
     JOIN (oc
     WHERE oc.catalog_cd=oi.catalog_cd)
     JOIN (ocs
     WHERE ocs.synonym_id=oi.synonym_id
      AND ocs.active_ind=1)
    ORDER BY o.template_order_id, o.order_id, oi.action_sequence DESC,
     oi.comp_sequence
    HEAD o.order_id
     max_sequence = oi.action_sequence, ingcnt = 0, idx = locateval(y,1,ordercount,o.order_id,reply->
      orders[y].order_id),
     reply->orders[idx].order_id = o.order_id, reply->orders[idx].encntr_id = o.encntr_id, reply->
     orders[idx].person_id = o.person_id,
     reply->orders[idx].order_status_cd = o.order_status_cd, reply->orders[idx].display_line = trim(o
      .clinical_display_line), reply->orders[idx].order_mnemonic = o.order_mnemonic,
     reply->orders[idx].hna_order_mnemonic = o.hna_order_mnemonic, reply->orders[idx].
     ordered_as_mnemonic = o.ordered_as_mnemonic, reply->orders[idx].catalog_cd = o.catalog_cd,
     reply->orders[idx].comment_type_mask = o.comment_type_mask, reply->orders[idx].constant_ind = o
     .constant_ind, reply->orders[idx].prn_ind = o.prn_ind,
     reply->orders[idx].ingredient_ind = o.ingredient_ind, reply->orders[idx].need_nurse_review_ind
      = o.need_nurse_review_ind, reply->orders[idx].med_order_type_cd = o.med_order_type_cd,
     reply->orders[idx].link_nbr = o.link_nbr, reply->orders[idx].link_type_flag = o.link_type_flag,
     renew_dt_tm = default_renew_dt_tm
     IF (o.stop_type_cd=hard_stop_cd
      AND o.projected_stop_dt_tm < cnvtdatetime(renew_dt_tm))
      reply->orders[idx].need_renew_ind = 2
     ELSEIF (o.stop_type_cd=soft_stop_cd
      AND o.projected_stop_dt_tm < cnvtdatetime(renew_dt_tm))
      reply->orders[idx].need_renew_ind = 1
     ELSE
      reply->orders[idx].need_renew_ind = 0
     ENDIF
     reply->orders[idx].last_action_sequence = o.last_action_sequence, reply->orders[idx].
     core_action_sequence = o.template_core_action_sequence, reply->orders[idx].freq_type_flag = o
     .freq_type_flag,
     reply->orders[idx].current_start_dt_tm = o.current_start_dt_tm, reply->orders[idx].
     current_start_tz = o.current_start_tz, reply->orders[idx].projected_stop_dt_tm = o
     .projected_stop_dt_tm,
     reply->orders[idx].projected_stop_tz = o.projected_stop_tz, reply->orders[idx].stop_type_cd = o
     .stop_type_cd, reply->orders[idx].orderable_type_flag = o.orderable_type_flag,
     reply->orders[idx].template_order_flag = o.template_order_flag, reply->orders[idx].iv_ind = o
     .iv_ind
     IF (o.prn_ind > 0)
      prncnt = (prncnt+ 1)
      IF (mod(prncnt,10)=1)
       stat = alterlist(mar_temp->prns,(prncnt+ 9))
      ENDIF
      mar_temp->prns[prncnt].order_index = ordercount
     ENDIF
    DETAIL
     IF (oc.catalog_cd=o.catalog_cd)
      reply->orders[idx].catalog_cd = oc.catalog_cd, reply->orders[idx].catalog_type_cd = oc
      .catalog_type_cd, reply->orders[idx].activity_type_cd = oc.activity_type_cd
     ENDIF
     addingredient = 1
     FOR (i = 1 TO ingcnt)
       IF ((reply->orders[idx].order_ingredient[i].catalog_cd=oc.catalog_cd)
        AND (reply->orders[idx].order_ingredient[i].action_sequence != oi.action_sequence))
        i = (ingcnt+ 1), addingredient = 0
       ENDIF
     ENDFOR
     IF (addingredient)
      ingcnt = (ingcnt+ 1)
      IF (mod(ingcnt,5)=1)
       stat = alterlist(reply->orders[idx].order_ingredient,(ingcnt+ 4))
      ENDIF
      reply->orders[idx].order_ingredient[ingcnt].catalog_cd = oc.catalog_cd, reply->orders[idx].
      order_ingredient[ingcnt].primary_mnemonic = oc.primary_mnemonic, reply->orders[idx].
      order_ingredient[ingcnt].ingredient_type_flag = oi.ingredient_type_flag,
      reply->orders[idx].order_ingredient[ingcnt].ref_text_mask = oc.ref_text_mask, reply->orders[idx
      ].order_ingredient[ingcnt].cki = oc.cki, reply->orders[idx].order_ingredient[ingcnt].
      action_sequence = oi.action_sequence,
      reply->orders[idx].order_ingredient[ingcnt].comp_sequence = oi.comp_sequence, reply->orders[idx
      ].order_ingredient[ingcnt].synonym_id = oi.synonym_id, reply->orders[idx].order_ingredient[
      ingcnt].ordered_as_mnemonic = oi.ordered_as_mnemonic,
      reply->orders[idx].order_ingredient[ingcnt].order_mnemonic = oi.order_mnemonic, reply->orders[
      idx].order_ingredient[ingcnt].hna_order_mnemonic = oi.hna_order_mnemonic, reply->orders[idx].
      order_ingredient[ingcnt].strength = oi.strength,
      reply->orders[idx].order_ingredient[ingcnt].strength_unit = oi.strength_unit, reply->orders[idx
      ].order_ingredient[ingcnt].volume = oi.volume, reply->orders[idx].order_ingredient[ingcnt].
      volume_unit = oi.volume_unit,
      reply->orders[idx].order_ingredient[ingcnt].freetext_dose = oi.freetext_dose, reply->orders[idx
      ].order_ingredient[ingcnt].clinically_significant_flag = oi.clinically_significant_flag, reply
      ->orders[idx].order_ingredient[ingcnt].ingredientrateconversionind = ocs
      .ingredient_rate_conversion_ind,
      reply->orders[idx].order_ingredient[ingcnt].freq_cd = oi.freq_cd, reply->orders[idx].
      order_ingredient[ingcnt].normalized_rate = oi.normalized_rate, reply->orders[idx].
      order_ingredient[ingcnt].normalized_rate_unit_cd = oi.normalized_rate_unit_cd,
      reply->orders[idx].order_ingredient[ingcnt].concentration = oi.concentration, reply->orders[idx
      ].order_ingredient[ingcnt].concentration_unit_cd = oi.concentration_unit_cd
      IF (oi.action_sequence=max_sequence)
       reply->orders[idx].order_ingredient[ingcnt].active_ind = 1
      ELSE
       reply->orders[idx].order_ingredient[ingcnt].active_ind = 0
      ENDIF
     ENDIF
    FOOT  o.order_id
     stat = alterlist(reply->orders[idx].order_ingredient,ingcnt)
    WITH nocounter
   ;end select
   CALL loadorderactions(((ordercount - mar_temp->missing_order_cnt)+ 1),ordercount)
 END ;Subroutine
 SET last_mod = "040"
 SET modify = nopredeclare
END GO
