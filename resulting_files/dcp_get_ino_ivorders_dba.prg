CREATE PROGRAM dcp_get_ino_ivorders:dba
 SET modify = predeclare
 RECORD reply(
   1 orders[*]
     2 catalog_cd = f8
     2 catalog_type_cd = f8
     2 activity_type_cd = f8
     2 ref_text_mask = i4
     2 cki = vc
     2 order_id = f8
     2 order_mnemonic = vc
     2 encntr_id = f8
     2 person_id = f8
     2 orig_order_dt_tm = dq8
     2 orig_order_tz = i4
     2 order_status_cd = f8
     2 order_status_disp = c40
     2 order_status_desc = c60
     2 order_status_mean = vc
     2 last_action_sequence = i4
     2 core_action_sequence = i4
     2 display_line = vc
     2 med_order_type_cd = f8
     2 constant_ind = i2
     2 prn_ind = i2
     2 freq_type_flag = i2
     2 comment_type_mask = i4
     2 order_comment_text = vc
     2 current_start_dt_tm = dq8
     2 current_start_tz = i4
     2 projected_stop_dt_tm = dq8
     2 projected_stop_tz = i4
     2 stop_type_cd = f8
     2 template_order_flag = i2
     2 template_order_id = f8
     2 hna_order_mnemonic = vc
     2 ordered_as_mnemonic = vc
     2 orderable_type_flag = i2
     2 need_rx_verify_ind = i2
     2 need_nurse_review_ind = i2
     2 need_renew_ind = i2
     2 event_cd = f8
     2 order_provider_id = f8
     2 root_event_id = f8
     2 allow_chart_ind = i2
     2 iv_ind = i2
     2 protocol_order_id = f8
     2 plan_ind = i2
     2 warning_level_bit = i4
     2 total_bags_nbr = i4
     2 ivseq_ind = i2
     2 detail_qual[*]
       3 oe_field_display_value = vc
       3 oe_field_dt_tm_value = dq8
       3 oe_field_tz = i4
       3 oe_field_id = f8
       3 oe_field_meaning_id = f8
       3 oe_field_value = f8
     2 ingred_qual[*]
       3 hna_order_mnemonic = vc
       3 ordered_as_mnemonic = vc
       3 order_mnemonic = vc
       3 order_detail_display_line = vc
       3 ingredient_type_flag = i2
       3 comp_sequence = i4
       3 strength = f8
       3 strength_unit = f8
       3 volume = f8
       3 volume_unit = f8
       3 freetext_dose = vc
       3 freq_cd = f8
       3 catalog_cd = f8
       3 catalog_type_cd = f8
       3 synonym_id = f8
       3 event_cd = f8
       3 include_in_total_volume_flag = i2
       3 normalized_rate = f8
       3 normalized_rate_unit_cd = f8
       3 normalized_rate_unit_cd_disp = vc
       3 normalized_rate_unit_cd_desc = vc
       3 normalized_rate_unit_cd_mean = vc
       3 ingredient_rate_conversion_ind = i2
       3 display_additives_first_ind = i2
     2 verification_prsnl_id = f8
     2 verification_pos_cd = f8
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
       3 task_tz = i4
     2 need_rx_clin_review_flag = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET ino_temp
 RECORD ino_temp(
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
 FREE SET ivorders_with_rslts
 RECORD ivorders_with_rslts(
   1 order_cnt = i4
   1 orders[*]
     2 order_id = f8
 )
 FREE RECORD wv_protocol_list
 RECORD wv_protocol_list(
   1 orders[*]
     2 order_id = f8
 )
 RECORD temp(
   1 order_comments[*]
     2 order_id = f8
     2 orderindex = i4
   1 order_renews[*]
     2 catalog_cd = f8
     2 found = i2
     2 stop_type_cd = i4
     2 stop_duration = i4
     2 ordercnt = i4
     2 orders[*]
       3 orderindex = i4
   1 orderreviews[*]
     2 order_id = f8
     2 orderindex = i4
   1 catalogs[*]
     2 catalog_cd = f8
     2 stop_type_cd = f8
     2 stop_type_mean = vc
     2 stop_duration = i4
     2 stop_duration_unit_cd = f8
     2 cnt = i4
     2 qual[*]
       3 orderindex = i4
       3 ingredientindex = i4
 )
 DECLARE reportfailure(opname=vc,opstatus=vc,targetname=vc,targetvalue=vc) = null
 DECLARE fillsubeventstatus(opname=vc,opstatus=vc,objname=vc,objvalue=vc) = null
 SUBROUTINE reportfailure(opname,opstatus,targetname,targetvalue)
  SET reply->status_data.status = "F"
  CALL fillsubeventstatus(opname,opstatus,targetname,targetvalue)
 END ;Subroutine
 SUBROUTINE fillsubeventstatus(opname,opstatus,objname,objvalue)
   DECLARE dcp_substatus_cnt = i4 WITH protect, noconstant(size(reply->status_data.subeventstatus,5))
   SET dcp_substatus_cnt = (dcp_substatus_cnt+ 1)
   IF (dcp_substatus_cnt != 1)
    SET stat = alter(reply->status_data.subeventstatus,dcp_substatus_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].operationname = trim(opname)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].targetobjectname = trim(objname)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].targetobjectvalue = trim(objvalue)
 END ;Subroutine
 DECLARE loadinactiveorders(null) = null
 DECLARE loadactiveorders(null) = null
 DECLARE loadnonqualifyingorderswithresults(null) = null
 DECLARE loadorderingredients(null) = null
 DECLARE loadorderdetails(null) = null
 DECLARE loadordercomments(null) = null
 DECLARE loadorderactions(null) = null
 DECLARE loadtasks(null) = null
 DECLARE setmiscorderproperties(null) = null
 DECLARE evaluaterxverify(orderid=f8,action=i4,prsnlid=f8(ref),poscd=f8(ref)) = i2
 DECLARE populateverifyindicator(null) = null
 DECLARE populateivorderswithrslts(null) = null
 DECLARE loadprotocolandtemplateorders(null) = null
 DECLARE setsequenceindicator(null) = null
 DECLARE hard_stop_cd = f8 WITH constant(uar_get_code_by("MEANING",4009,"HARD"))
 DECLARE soft_stop_cd = f8 WITH constant(uar_get_code_by("MEANING",4009,"SOFT"))
 DECLARE canceled_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"CANCELED"))
 DECLARE completed_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"COMPLETED"))
 DECLARE deleted_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"DELETED"))
 DECLARE discontinued_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"DISCONTINUED"))
 DECLARE trans_cancel_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"TRANS/CANCEL"))
 DECLARE voidedwrslt_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"VOIDEDWRSLT"))
 DECLARE future_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"FUTURE"))
 DECLARE incomplete_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"INCOMPLETE"))
 DECLARE inprocess_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"INPROCESS"))
 DECLARE medstudent_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"MEDSTUDENT"))
 DECLARE ordered_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"ORDERED"))
 DECLARE pendingreview_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"PENDING REV"))
 DECLARE suspended_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"SUSPENDED"))
 DECLARE unscheduled_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"UNSCHEDULED"))
 DECLARE pending_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"PENDING"))
 DECLARE group_class_cd = f8 WITH constant(uar_get_code_by("MEANING",53,"GRP"))
 DECLARE pos_cd = f8 WITH constant(reqinfo->position_cd)
 DECLARE infuse_cd = f8 WITH constant(uar_get_code_by("MEANING",180,"INFUSE"))
 DECLARE bolus_cd = f8 WITH constant(uar_get_code_by("MEANING",180,"BOLUS"))
 DECLARE overdue_look_back = i4 WITH noconstant(10)
 DECLARE ordercnt = i4 WITH noconstant(0)
 DECLARE ordercommentcnt = i4 WITH noconstant(0)
 DECLARE renewcnt = i4 WITH noconstant(0)
 DECLARE encntr_cnt = i4 WITH noconstant(cnvtint(size(request->encntr_list,5)))
 DECLARE zero_ind = i2 WITH noconstant(0)
 DECLARE order_comment_cd = f8 WITH constant(uar_get_code_by("MEANING",14,"ORD COMMENT"))
 DECLARE order_comment_mask = i4 WITH constant(1)
 DECLARE oe_rate = i4 WITH constant(2043)
 DECLARE oe_rate_unit = i4 WITH constant(2044)
 DECLARE oe_site = i4 WITH constant(117)
 DECLARE oe_dispense_cat = i4 WITH constant(2007)
 DECLARE oe_freetext_rate = i4 WITH constant(2104)
 DECLARE pendingtaskcd = f8 WITH constant(uar_get_code_by("MEANING",79,"PENDING"))
 DECLARE userpositioncd = f8 WITH constant(reqinfo->position_cd)
 DECLARE order_action_type_cd = f8 WITH constant(uar_get_code_by("MEANING",6003,"ORDER"))
 DECLARE modify_action_type_cd = f8 WITH constant(uar_get_code_by("MEANING",6003,"MODIFY"))
 DECLARE activate_action_type_cd = f8 WITH constant(uar_get_code_by("MEANING",6003,"ACTIVATE"))
 DECLARE med_order_iv_type_cd = f8 WITH public, constant(uar_get_code_by("MEANING",18309,"IV"))
 DECLARE begin_dt_tm = dq8
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE serrormsg = vc WITH protect, noconstant("")
 DECLARE ierrorcode = i2 WITH protect, noconstant(0)
 DECLARE protocolcnt = i4 WITH noconstant(0)
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM name_value_prefs n
  WHERE n.pvc_name="OVERDUE_LOOK_BACK_DAYS"
  DETAIL
   overdue_look_back = cnvtint(n.pvc_value)
  WITH nocounter
 ;end select
 SET begin_dt_tm = cnvtdatetime((curdate - overdue_look_back),curtime)
 IF (cnvtdatetime(begin_dt_tm) > cnvtdatetime(request->start_dt_tm))
  SET begin_dt_tm = cnvtdatetime(request->start_dt_tm)
 ENDIF
 DECLARE encntr_in_clause = vc WITH noconstant(fillstring(5000," "))
 DECLARE encntr_iterator = i4 WITH noconstant(0)
 IF (encntr_cnt > 0)
  SET encntr_in_clause = build(
   "expand (encntr_iterator, 1,encntr_cnt, o.encntr_id+0,request->encntr_list[encntr_iterator].encntr_id)",
   " or o.encntr_id+0=0")
 ELSE
  SET encntr_in_clause = "0=0"
 ENDIF
 IF ((request->load_ivorders_with_rslts_flag=1))
  CALL populateivorderswithrslts(null)
 ENDIF
 CALL loadinactiveorders(null)
 CALL loadactiveorders(null)
 IF (protocolcnt > 0)
  CALL loadprotocolandtemplateorders(null)
 ENDIF
 CALL loadnonqualifyingorderswithresults(null)
 SET stat = alterlist(reply->orders,ordercnt)
 IF (ordercnt > 0)
  CALL loadorderingredients(null)
  CALL loadorderdetails(null)
  CALL loadordercomments(null)
  CALL setrenewalindicators(null)
  CALL loadorderactions(null)
  CALL populateverifyindicator(null)
  CALL loadtasks(null)
  CALL setmiscorderproperties(null)
  CALL setsequenceindicator(null)
 ELSEIF (ordercnt=0)
  SET zero_ind = 1
 ENDIF
 FREE RECORD temp
 GO TO exit_script
 SUBROUTINE loadinactiveorders(null)
   DECLARE renewindex = i4 WITH noconstant(0)
   DECLARE renewiterator = i4 WITH noconstant(0)
   SELECT INTO "nl:"
    o.order_id
    FROM orders o
    WHERE (o.person_id=request->person_id)
     AND o.order_status_cd IN (canceled_cd, completed_cd, deleted_cd, discontinued_cd,
    trans_cancel_cd,
    voidedwrslt_cd)
     AND o.template_order_flag IN (0, 1)
     AND ((o.projected_stop_dt_tm+ 0) >= cnvtdatetime(begin_dt_tm))
     AND ((o.orderable_type_flag+ 0) IN (0, 1, 8, 10, 11))
     AND parser(encntr_in_clause)
     AND ((o.current_start_dt_tm+ 0) <= cnvtdatetime(request->end_dt_tm))
     AND ((o.orig_ord_as_flag+ 0) IN (0, 5))
     AND ((o.med_order_type_cd+ 0)=med_order_iv_type_cd)
     AND ((o.template_order_id+ 0)=0)
    ORDER BY o.order_id
    HEAD o.order_id
     IF (o.current_start_dt_tm <= cnvtdatetime(request->end_dt_tm)
      AND ((o.projected_stop_dt_tm=null) OR (((o.projected_stop_dt_tm >= cnvtdatetime(request->
      start_dt_tm)) OR (o.stop_type_cd=soft_stop_cd)) )) )
      ordercnt = (ordercnt+ 1)
      IF (mod(ordercnt,10)=1)
       stat = alterlist(reply->orders,(ordercnt+ 9))
      ENDIF
      reply->orders[ordercnt].catalog_cd = o.catalog_cd, reply->orders[ordercnt].catalog_type_cd = o
      .catalog_type_cd, reply->orders[ordercnt].activity_type_cd = o.activity_type_cd,
      reply->orders[ordercnt].ref_text_mask = o.ref_text_mask, reply->orders[ordercnt].cki = o.cki,
      reply->orders[ordercnt].order_id = o.order_id,
      reply->orders[ordercnt].order_mnemonic = o.order_mnemonic, reply->orders[ordercnt].encntr_id =
      o.encntr_id, reply->orders[ordercnt].person_id = o.person_id,
      reply->orders[ordercnt].orig_order_dt_tm = o.orig_order_dt_tm, reply->orders[ordercnt].
      orig_order_tz = o.orig_order_tz, reply->orders[ordercnt].order_status_cd = o.order_status_cd,
      reply->orders[ordercnt].last_action_sequence = o.last_action_sequence, reply->orders[ordercnt].
      display_line = trim(o.clinical_display_line), reply->orders[ordercnt].med_order_type_cd = o
      .med_order_type_cd,
      reply->orders[ordercnt].constant_ind = o.constant_ind, reply->orders[ordercnt].prn_ind = o
      .prn_ind, reply->orders[ordercnt].freq_type_flag = o.freq_type_flag,
      reply->orders[ordercnt].comment_type_mask = o.comment_type_mask, reply->orders[ordercnt].
      current_start_dt_tm = o.current_start_dt_tm, reply->orders[ordercnt].current_start_tz = o
      .current_start_tz,
      reply->orders[ordercnt].projected_stop_dt_tm = o.projected_stop_dt_tm, reply->orders[ordercnt].
      projected_stop_tz = o.projected_stop_tz, reply->orders[ordercnt].stop_type_cd = o.stop_type_cd,
      reply->orders[ordercnt].template_order_flag = o.template_order_flag, reply->orders[ordercnt].
      hna_order_mnemonic = o.hna_order_mnemonic, reply->orders[ordercnt].ordered_as_mnemonic = o
      .ordered_as_mnemonic,
      reply->orders[ordercnt].orderable_type_flag = o.orderable_type_flag, reply->orders[ordercnt].
      need_rx_verify_ind = 0, reply->orders[ordercnt].need_rx_clin_review_flag = o
      .need_rx_clin_review_flag,
      reply->orders[ordercnt].need_nurse_review_ind = o.need_nurse_review_ind, reply->orders[ordercnt
      ].iv_ind = o.iv_ind, reply->orders[ordercnt].protocol_order_id = o.protocol_order_id,
      reply->orders[ordercnt].warning_level_bit = o.warning_level_bit
      IF (o.pathway_catalog_id > 0)
       reply->orders[ordercnt].plan_ind = 1
      ELSE
       reply->orders[ordercnt].plan_ind = 0
      ENDIF
      IF (band(o.comment_type_mask,order_comment_mask)=order_comment_mask)
       ordercommentcnt = (ordercommentcnt+ 1)
       IF (mod(ordercommentcnt,50)=1)
        stat = alterlist(temp->order_comments,(ordercommentcnt+ 49))
       ENDIF
       temp->order_comments[ordercommentcnt].order_id = o.order_id, temp->order_comments[
       ordercommentcnt].orderindex = ordercnt
      ENDIF
      renewindex = locateval(renewiterator,1,renewcnt,o.catalog_cd,temp->order_renews[renewiterator].
       catalog_cd)
      IF (renewindex <= 0)
       renewcnt = (renewcnt+ 1)
       IF (mod(renewcnt,10)=1)
        stat = alterlist(temp->order_renews,(renewcnt+ 9))
       ENDIF
       temp->order_renews[renewcnt].catalog_cd = o.catalog_cd, temp->order_renews[renewcnt].found = 0,
       temp->order_renews[renewcnt].ordercnt = 0
      ENDIF
      IF (o.protocol_order_id > 0)
       protocolcnt = (protocolcnt+ 1)
       IF (mod(protocolcnt,10)=1)
        stat = alterlist(wv_protocol_list->orders,(protocolcnt+ 9))
       ENDIF
       wv_protocol_list->orders[protocolcnt].order_id = o.protocol_order_id
      ENDIF
      temp->order_renews[renewcnt].ordercnt = (temp->order_renews[renewcnt].ordercnt+ 1), stat =
      alterlist(temp->order_renews[renewcnt].orders,temp->order_renews[renewcnt].ordercnt), temp->
      order_renews[renewcnt].orders[temp->order_renews[renewcnt].ordercnt].orderindex = ordercnt
     ENDIF
    WITH nocounter, orahint("index (o XIE18ORDERS)")
   ;end select
 END ;Subroutine
 SUBROUTINE loadactiveorders(null)
   DECLARE renewindex = i4 WITH noconstant(0)
   DECLARE renewiterator = i4 WITH noconstant(0)
   SELECT INTO "nl:"
    o.order_id
    FROM orders o
    WHERE (o.person_id=request->person_id)
     AND o.order_status_cd IN (future_cd, incomplete_cd, inprocess_cd, medstudent_cd, ordered_cd,
    pendingreview_cd, suspended_cd, unscheduled_cd, pending_cd)
     AND o.template_order_flag IN (0, 1)
     AND ((o.current_start_dt_tm+ 0) <= cnvtdatetime(request->end_dt_tm))
     AND ((o.orderable_type_flag+ 0) IN (0, 1, 8, 10, 11))
     AND parser(encntr_in_clause)
     AND ((o.orig_ord_as_flag+ 0) IN (0, 5))
     AND ((o.med_order_type_cd+ 0)=med_order_iv_type_cd)
     AND ((o.template_order_id+ 0)=0)
    ORDER BY o.order_id
    HEAD o.order_id
     IF (o.current_start_dt_tm <= cnvtdatetime(request->end_dt_tm)
      AND ((o.projected_stop_dt_tm=null) OR (((o.projected_stop_dt_tm >= cnvtdatetime(request->
      start_dt_tm)) OR (o.stop_type_cd=soft_stop_cd)) )) )
      ordercnt = (ordercnt+ 1)
      IF (mod(ordercnt,10)=1)
       stat = alterlist(reply->orders,(ordercnt+ 9))
      ENDIF
      reply->orders[ordercnt].catalog_cd = o.catalog_cd, reply->orders[ordercnt].catalog_type_cd = o
      .catalog_type_cd, reply->orders[ordercnt].activity_type_cd = o.activity_type_cd,
      reply->orders[ordercnt].ref_text_mask = o.ref_text_mask, reply->orders[ordercnt].cki = o.cki,
      reply->orders[ordercnt].order_id = o.order_id,
      reply->orders[ordercnt].order_mnemonic = o.order_mnemonic, reply->orders[ordercnt].encntr_id =
      o.encntr_id, reply->orders[ordercnt].person_id = o.person_id,
      reply->orders[ordercnt].orig_order_dt_tm = o.orig_order_dt_tm, reply->orders[ordercnt].
      orig_order_tz = o.orig_order_tz, reply->orders[ordercnt].order_status_cd = o.order_status_cd,
      reply->orders[ordercnt].last_action_sequence = o.last_action_sequence, reply->orders[ordercnt].
      display_line = trim(o.clinical_display_line), reply->orders[ordercnt].med_order_type_cd = o
      .med_order_type_cd,
      reply->orders[ordercnt].constant_ind = o.constant_ind, reply->orders[ordercnt].prn_ind = o
      .prn_ind, reply->orders[ordercnt].freq_type_flag = o.freq_type_flag,
      reply->orders[ordercnt].comment_type_mask = o.comment_type_mask, reply->orders[ordercnt].
      current_start_dt_tm = o.current_start_dt_tm, reply->orders[ordercnt].current_start_tz = o
      .current_start_tz,
      reply->orders[ordercnt].projected_stop_dt_tm = o.projected_stop_dt_tm, reply->orders[ordercnt].
      projected_stop_tz = o.projected_stop_tz, reply->orders[ordercnt].stop_type_cd = o.stop_type_cd,
      reply->orders[ordercnt].template_order_flag = o.template_order_flag, reply->orders[ordercnt].
      hna_order_mnemonic = o.hna_order_mnemonic, reply->orders[ordercnt].ordered_as_mnemonic = o
      .ordered_as_mnemonic,
      reply->orders[ordercnt].orderable_type_flag = o.orderable_type_flag, reply->orders[ordercnt].
      need_rx_verify_ind = 0, reply->orders[ordercnt].need_rx_clin_review_flag = o
      .need_rx_clin_review_flag,
      reply->orders[ordercnt].need_nurse_review_ind = o.need_nurse_review_ind, reply->orders[ordercnt
      ].iv_ind = o.iv_ind, reply->orders[ordercnt].protocol_order_id = o.protocol_order_id,
      reply->orders[ordercnt].warning_level_bit = o.warning_level_bit
      IF (o.pathway_catalog_id > 0)
       reply->orders[ordercnt].plan_ind = 1
      ELSE
       reply->orders[ordercnt].plan_ind = 0
      ENDIF
      IF (band(o.comment_type_mask,order_comment_mask)=order_comment_mask)
       ordercommentcnt = (ordercommentcnt+ 1)
       IF (mod(ordercommentcnt,50)=1)
        stat = alterlist(temp->order_comments,(ordercommentcnt+ 49))
       ENDIF
       temp->order_comments[ordercommentcnt].order_id = o.order_id, temp->order_comments[
       ordercommentcnt].orderindex = ordercnt
      ENDIF
      renewindex = locateval(renewiterator,1,renewcnt,o.catalog_cd,temp->order_renews[renewiterator].
       catalog_cd)
      IF (renewindex <= 0)
       renewcnt = (renewcnt+ 1)
       IF (mod(renewcnt,10)=1)
        stat = alterlist(temp->order_renews,(renewcnt+ 9))
       ENDIF
       temp->order_renews[renewcnt].catalog_cd = o.catalog_cd, temp->order_renews[renewcnt].found = 0,
       temp->order_renews[renewcnt].ordercnt = 0
      ENDIF
      IF (o.protocol_order_id > 0)
       protocolcnt = (protocolcnt+ 1)
       IF (mod(protocolcnt,10)=1)
        stat = alterlist(wv_protocol_list->orders,(protocolcnt+ 9))
       ENDIF
       wv_protocol_list->orders[protocolcnt].order_id = o.protocol_order_id
      ENDIF
      temp->order_renews[renewcnt].ordercnt = (temp->order_renews[renewcnt].ordercnt+ 1), stat =
      alterlist(temp->order_renews[renewcnt].orders,temp->order_renews[renewcnt].ordercnt), temp->
      order_renews[renewcnt].orders[temp->order_renews[renewcnt].ordercnt].orderindex = ordercnt
     ENDIF
    WITH nocounter, orahint("index (o XIE18ORDERS)")
   ;end select
 END ;Subroutine
 SUBROUTINE loadprotocolandtemplateorders(null)
   DECLARE renewindex = i4 WITH noconstant(0)
   DECLARE renewiterator = i4 WITH noconstant(0)
   DECLARE x = i4 WITH noconstant(0)
   DECLARE y = i4 WITH noconstant(0)
   DECLARE z = i4 WITH noconstant(0)
   DECLARE nstart = i4 WITH protect, noconstant(1)
   DECLARE nsize = i4 WITH protect, constant(50)
   DECLARE ntotal = i4 WITH protect, noconstant((ceil((cnvtreal(protocolcnt)/ nsize)) * nsize))
   DECLARE order_clause = vc WITH noconstant(fillstring(5000," "))
   SET stat = alterlist(wv_protocol_list->orders,ntotal)
   FOR (i = (protocolcnt+ 1) TO ntotal)
     SET wv_protocol_list->orders[i].order_id = wv_protocol_list->orders[protocolcnt].order_id
   ENDFOR
   SET order_clause = build("expand(z, 1, orderCnt, o.order_id+0, reply->orders[z].order_id)")
   SELECT INTO "nl:"
    o.order_id
    FROM orders o
    PLAN (o
     WHERE ((expand(x,nstart,(nstart+ (nsize - 1)),o.order_id,wv_protocol_list->orders[x].order_id)
      AND o.template_order_flag=7) OR (expand(y,nstart,(nstart+ (nsize - 1)),o.protocol_order_id,
      wv_protocol_list->orders[y].order_id)
      AND o.template_order_flag IN (0, 1)))
      AND parser(encntr_in_clause)
      AND  NOT (parser(order_clause)))
    ORDER BY o.order_id
    HEAD o.order_id
     ordercnt = (ordercnt+ 1)
     IF (mod(ordercnt,10)=1)
      stat = alterlist(reply->orders,(ordercnt+ 9))
     ENDIF
     reply->orders[ordercnt].catalog_cd = o.catalog_cd, reply->orders[ordercnt].catalog_type_cd = o
     .catalog_type_cd, reply->orders[ordercnt].activity_type_cd = o.activity_type_cd,
     reply->orders[ordercnt].ref_text_mask = o.ref_text_mask, reply->orders[ordercnt].cki = o.cki,
     reply->orders[ordercnt].order_id = o.order_id,
     reply->orders[ordercnt].order_mnemonic = o.order_mnemonic, reply->orders[ordercnt].encntr_id = o
     .encntr_id, reply->orders[ordercnt].person_id = o.person_id,
     reply->orders[ordercnt].orig_order_dt_tm = o.orig_order_dt_tm, reply->orders[ordercnt].
     orig_order_tz = o.orig_order_tz, reply->orders[ordercnt].order_status_cd = o.order_status_cd,
     reply->orders[ordercnt].last_action_sequence = o.last_action_sequence, reply->orders[ordercnt].
     display_line = trim(o.clinical_display_line), reply->orders[ordercnt].med_order_type_cd = o
     .med_order_type_cd,
     reply->orders[ordercnt].constant_ind = o.constant_ind, reply->orders[ordercnt].prn_ind = o
     .prn_ind, reply->orders[ordercnt].freq_type_flag = o.freq_type_flag,
     reply->orders[ordercnt].comment_type_mask = o.comment_type_mask, reply->orders[ordercnt].
     current_start_dt_tm = o.current_start_dt_tm, reply->orders[ordercnt].current_start_tz = o
     .current_start_tz,
     reply->orders[ordercnt].projected_stop_dt_tm = o.projected_stop_dt_tm, reply->orders[ordercnt].
     projected_stop_tz = o.projected_stop_tz, reply->orders[ordercnt].stop_type_cd = o.stop_type_cd,
     reply->orders[ordercnt].template_order_flag = o.template_order_flag, reply->orders[ordercnt].
     hna_order_mnemonic = o.hna_order_mnemonic, reply->orders[ordercnt].ordered_as_mnemonic = o
     .ordered_as_mnemonic,
     reply->orders[ordercnt].orderable_type_flag = o.orderable_type_flag, reply->orders[ordercnt].
     need_rx_verify_ind = 0, reply->orders[ordercnt].need_rx_clin_review_flag = o
     .need_rx_clin_review_flag,
     reply->orders[ordercnt].need_nurse_review_ind = o.need_nurse_review_ind, reply->orders[ordercnt]
     .iv_ind = o.iv_ind, reply->orders[ordercnt].protocol_order_id = o.protocol_order_id,
     reply->orders[ordercnt].warning_level_bit = o.warning_level_bit
     IF (o.pathway_catalog_id > 0)
      reply->orders[ordercnt].plan_ind = 1
     ELSE
      reply->orders[ordercnt].plan_ind = 0
     ENDIF
     IF (band(o.comment_type_mask,order_comment_mask)=order_comment_mask)
      ordercommentcnt = (ordercommentcnt+ 1)
      IF (mod(ordercommentcnt,50)=1)
       stat = alterlist(temp->order_comments,(ordercommentcnt+ 49))
      ENDIF
      temp->order_comments[ordercommentcnt].order_id = o.order_id, temp->order_comments[
      ordercommentcnt].orderindex = ordercnt
     ENDIF
     renewindex = locateval(renewiterator,1,renewcnt,o.catalog_cd,temp->order_renews[renewiterator].
      catalog_cd)
     IF (renewindex <= 0)
      renewcnt = (renewcnt+ 1)
      IF (mod(renewcnt,10)=1)
       stat = alterlist(temp->order_renews,(renewcnt+ 9))
      ENDIF
      temp->order_renews[renewcnt].catalog_cd = o.catalog_cd, temp->order_renews[renewcnt].found = 0,
      temp->order_renews[renewcnt].ordercnt = 0
     ENDIF
     temp->order_renews[renewcnt].ordercnt = (temp->order_renews[renewcnt].ordercnt+ 1), stat =
     alterlist(temp->order_renews[renewcnt].orders,temp->order_renews[renewcnt].ordercnt), temp->
     order_renews[renewcnt].orders[temp->order_renews[renewcnt].ordercnt].orderindex = ordercnt
    WITH nocounter, orahint("index (o XIE18ORDERS)")
   ;end select
 END ;Subroutine
 SUBROUTINE loadnonqualifyingorderswithresults(null)
   IF ((request->load_ivorders_with_rslts_flag=1)
    AND (ivorders_with_rslts->order_cnt > 0))
    DECLARE x = i4 WITH noconstant(0)
    DECLARE y = i4 WITH noconstant(0)
    DECLARE renewindex = i4 WITH noconstant(0)
    DECLARE renewiterator = i4 WITH noconstant(0)
    DECLARE nstart = i4 WITH protect, noconstant(1)
    DECLARE nsize = i4 WITH protect, constant(50)
    DECLARE ntotal = i4 WITH protect, noconstant((ceil((cnvtreal(ordercnt)/ nsize)) * nsize))
    SET stat = alterlist(reply->orders,ntotal)
    FOR (i = (ordercnt+ 1) TO ntotal)
      SET reply->orders[i].order_id = reply->orders[ordercnt].order_id
    ENDFOR
    SELECT INTO "nl:"
     o.order_id
     FROM (dummyt d1  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
      orders o
     PLAN (d1
      WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ nsize))))
      JOIN (o
      WHERE expand(x,1,ivorders_with_rslts->order_cnt,o.order_id,ivorders_with_rslts->orders[x].
       order_id)
       AND  NOT (expand(y,nstart,(nstart+ (nsize - 1)),o.order_id,reply->orders[y].order_id)))
     ORDER BY o.order_id
     HEAD o.order_id
      ordercnt = (ordercnt+ 1)
      IF (mod(ordercnt,10)=1)
       stat = alterlist(reply->orders,(ordercnt+ 9))
      ENDIF
      reply->orders[ordercnt].catalog_cd = o.catalog_cd, reply->orders[ordercnt].catalog_type_cd = o
      .catalog_type_cd, reply->orders[ordercnt].activity_type_cd = o.activity_type_cd,
      reply->orders[ordercnt].ref_text_mask = o.ref_text_mask, reply->orders[ordercnt].cki = o.cki,
      reply->orders[ordercnt].order_id = o.order_id,
      reply->orders[ordercnt].order_mnemonic = o.order_mnemonic, reply->orders[ordercnt].encntr_id =
      o.encntr_id, reply->orders[ordercnt].person_id = o.person_id,
      reply->orders[ordercnt].orig_order_dt_tm = o.orig_order_dt_tm, reply->orders[ordercnt].
      orig_order_tz = o.orig_order_tz, reply->orders[ordercnt].order_status_cd = o.order_status_cd,
      reply->orders[ordercnt].last_action_sequence = o.last_action_sequence, reply->orders[ordercnt].
      display_line = trim(o.clinical_display_line), reply->orders[ordercnt].med_order_type_cd = o
      .med_order_type_cd,
      reply->orders[ordercnt].constant_ind = o.constant_ind, reply->orders[ordercnt].prn_ind = o
      .prn_ind, reply->orders[ordercnt].freq_type_flag = o.freq_type_flag,
      reply->orders[ordercnt].comment_type_mask = o.comment_type_mask, reply->orders[ordercnt].
      current_start_dt_tm = o.current_start_dt_tm, reply->orders[ordercnt].current_start_tz = o
      .current_start_tz,
      reply->orders[ordercnt].projected_stop_dt_tm = o.projected_stop_dt_tm, reply->orders[ordercnt].
      projected_stop_tz = o.projected_stop_tz, reply->orders[ordercnt].stop_type_cd = o.stop_type_cd,
      reply->orders[ordercnt].template_order_flag = o.template_order_flag, reply->orders[ordercnt].
      hna_order_mnemonic = o.hna_order_mnemonic, reply->orders[ordercnt].ordered_as_mnemonic = o
      .ordered_as_mnemonic,
      reply->orders[ordercnt].orderable_type_flag = o.orderable_type_flag, reply->orders[ordercnt].
      need_rx_verify_ind = 0, reply->orders[ordercnt].need_rx_clin_review_flag = o
      .need_rx_clin_review_flag,
      reply->orders[ordercnt].need_nurse_review_ind = o.need_nurse_review_ind, reply->orders[ordercnt
      ].iv_ind = o.iv_ind, reply->orders[ordercnt].protocol_order_id = o.protocol_order_id,
      reply->orders[ordercnt].warning_level_bit = o.warning_level_bit
      IF (o.pathway_catalog_id > 0)
       reply->orders[ordercnt].plan_ind = 1
      ELSE
       reply->orders[ordercnt].plan_ind = 0
      ENDIF
      IF (band(o.comment_type_mask,order_comment_mask)=order_comment_mask)
       ordercommentcnt = (ordercommentcnt+ 1)
       IF (mod(ordercommentcnt,50)=1)
        stat = alterlist(temp->order_comments,(ordercommentcnt+ 49))
       ENDIF
       temp->order_comments[ordercommentcnt].order_id = o.order_id, temp->order_comments[
       ordercommentcnt].orderindex = ordercnt
      ENDIF
      renewindex = locateval(renewiterator,1,renewcnt,o.catalog_cd,temp->order_renews[renewiterator].
       catalog_cd)
      IF (renewindex <= 0)
       renewcnt = (renewcnt+ 1)
       IF (mod(renewcnt,10)=1)
        stat = alterlist(temp->order_renews,(renewcnt+ 9))
       ENDIF
       temp->order_renews[renewcnt].catalog_cd = o.catalog_cd, temp->order_renews[renewcnt].found = 0,
       temp->order_renews[renewcnt].ordercnt = 0
      ENDIF
      temp->order_renews[renewcnt].ordercnt = (temp->order_renews[renewcnt].ordercnt+ 1), stat =
      alterlist(temp->order_renews[renewcnt].orders,temp->order_renews[renewcnt].ordercnt), temp->
      order_renews[renewcnt].orders[temp->order_renews[renewcnt].ordercnt].orderindex = ordercnt
     WITH nocounter
    ;end select
    SET stat = alterlist(reply->orders,ordercnt)
   ENDIF
 END ;Subroutine
 SUBROUTINE setmiscorderproperties(null)
   DECLARE x = i4 WITH noconstant(0)
   DECLARE y = i4 WITH noconstant(0)
   DECLARE orderindex = i4 WITH noconstant(0)
   SELECT INTO "nl:"
    FROM clinical_event ce
    WHERE expand(x,1,ordercnt,ce.order_id,reply->orders[x].order_id)
     AND ce.parent_event_id=ce.event_id
     AND ce.event_class_cd=group_class_cd
    ORDER BY ce.order_id
    HEAD ce.order_id
     orderindex = locateval(y,1,ordercnt,ce.order_id,reply->orders[y].order_id)
    DETAIL
     reply->orders[orderindex].root_event_id = ce.parent_event_id
    WITH nocounter
   ;end select
   SET x = 0
   FOR (x = 1 TO ordercnt)
     SELECT INTO "nl:"
      FROM code_value_event_r cver
      WHERE (cver.parent_cd=reply->orders[x].catalog_cd)
      DETAIL
       reply->orders[x].event_cd = cver.event_cd
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      FROM order_task_xref otx,
       order_task ot
      PLAN (otx
       WHERE (otx.catalog_cd=reply->orders[x].catalog_cd))
       JOIN (ot
       WHERE ot.reference_task_id=otx.reference_task_id
        AND ot.allpositionchart_ind=1
        AND ot.reference_task_id > 0)
      DETAIL
       reply->orders[x].allow_chart_ind = 1
      WITH nocounter
     ;end select
     IF ((reply->orders[x].allow_chart_ind=0))
      SELECT INTO "nl:"
       FROM order_task_xref otx,
        order_task_position_xref otpx
       PLAN (otx
        WHERE (otx.catalog_cd=reply->orders[x].catalog_cd))
        JOIN (otpx
        WHERE otpx.reference_task_id=otx.reference_task_id
         AND otpx.position_cd=pos_cd
         AND otpx.reference_task_id > 0)
       DETAIL
        reply->orders[x].allow_chart_ind = 1
       WITH nocounter
      ;end select
     ENDIF
   ENDFOR
   SET x = 0
   SET y = 0
   SET orderindex = 0
   SELECT INTO "nl:"
    FROM order_action oa
    WHERE expand(x,1,ordercnt,oa.order_id,reply->orders[x].order_id)
    ORDER BY oa.order_id
    HEAD oa.order_id
     orderindex = locateval(y,1,ordercnt,oa.order_id,reply->orders[y].order_id)
    DETAIL
     IF (oa.action_sequence=1)
      reply->orders[orderindex].order_provider_id = oa.order_provider_id
     ENDIF
     IF (oa.core_ind=1
      AND (reply->orders[orderindex].core_action_sequence < oa.action_sequence)
      AND oa.action_type_cd IN (order_action_type_cd, modify_action_type_cd, activate_action_type_cd)
      AND oa.action_rejected_ind=0)
      reply->orders[orderindex].core_action_sequence = oa.action_sequence
     ENDIF
    WITH nocounter
   ;end select
   SET x = 0
   SET y = 0
   SET orderindex = 0
   SELECT INTO "nl:"
    FROM order_iv_info oiv
    WHERE expand(x,1,ordercnt,oiv.order_id,reply->orders[x].order_id)
    ORDER BY oiv.order_id
    HEAD oiv.order_id
     orderindex = locateval(y,1,ordercnt,oiv.order_id,reply->orders[y].order_id)
    DETAIL
     reply->orders[orderindex].total_bags_nbr = oiv.total_bags_nbr
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE loadorderactions(null)
   DECLARE order_cnt = i4 WITH noconstant(0), protected
   DECLARE action_cnt = i4 WITH noconstant(0), protected
   DECLARE orders_cnt = i4 WITH noconstant(ordercnt), protected
   DECLARE expandx = i4 WITH noconstant(0), protected
   DECLARE pos = i4 WITH noconstant(0), protected
   DECLARE nstart = i4 WITH protect, noconstant(1)
   DECLARE nsize = i4 WITH protect, constant(50)
   DECLARE iordercnt = i4 WITH protect, noconstant(size(reply->orders,5))
   DECLARE ntotal = i4 WITH protect, noconstant((ceil((cnvtreal(orders_cnt)/ nsize)) * nsize))
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
      stat = alterlist(ino_temp->orders,(order_cnt+ 99))
     ENDIF
     ino_temp->orders[order_cnt].order_id = oa.order_id, action_cnt = 0, verify_ind = 1,
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
      stat = alterlist(ino_temp->orders[order_cnt].actions,(action_cnt+ 9))
     ENDIF
     ino_temp->orders[order_cnt].actions[action_cnt].action_sequence = oa.action_sequence, ino_temp->
     orders[order_cnt].actions[action_cnt].prsnl_id = p.person_id, ino_temp->orders[order_cnt].
     actions[action_cnt].position_cd = p.position_cd,
     ino_temp->orders[order_cnt].actions[action_cnt].verify_ind = verify_ind
    FOOT  oa.order_id
     ino_temp->orders[order_cnt].action_cnt = action_cnt, stat = alterlist(ino_temp->orders[order_cnt
      ].actions,action_cnt)
    FOOT REPORT
     ino_temp->order_cnt = order_cnt, stat = alterlist(ino_temp->orders,order_cnt)
    WITH nocounter
   ;end select
   SET stat = alterlist(reply->orders,iordercnt)
 END ;Subroutine
 SUBROUTINE populateverifyindicator(null)
   DECLARE orders_cnt = i4 WITH constant(ordercnt), private
   DECLARE x = i4 WITH noconstant(0), private
   DECLARE prsnlid = f8 WITH noconstant(0.0), protected
   DECLARE poscd = f8 WITH noconstant(0.0), protected
   FOR (x = 1 TO orders_cnt)
    SET reply->orders[x].need_rx_verify_ind = evaluaterxverify(reply->orders[x].order_id,- (1),
     prsnlid,poscd)
    IF ((reply->orders[x].need_rx_verify_ind != 0))
     SET reply->orders[x].verification_prsnl_id = prsnlid
     SET reply->orders[x].verification_pos_cd = poscd
    ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE evaluaterxverify(orderid,action,prsnlid,positioncd)
   DECLARE x = i4 WITH noconstant(0), private
   DECLARE y = i4 WITH noconstant(0), private
   DECLARE verifyind = i4 WITH noconstant(0), private
   SET prsnlid = 0.0
   SET positioncd = 0.0
   FOR (x = 1 TO ino_temp->order_cnt)
     IF ((ino_temp->orders[x].order_id=orderid))
      IF (action < 0)
       SET verifyind = ino_temp->orders[x].actions[1].verify_ind
       SET prsnlid = ino_temp->orders[x].actions[1].prsnl_id
       SET positioncd = ino_temp->orders[x].actions[1].position_cd
      ELSE
       FOR (y = 1 TO ino_temp->orders[x].action_cnt)
         IF ((ino_temp->orders[x].actions[y].action_sequence=action))
          SET verifyind = ino_temp->orders[x].actions[y].verify_ind
          SET prsnlid = ino_temp->orders[x].actions[y].prsnl_id
          SET positioncd = ino_temp->orders[x].actions[y].position_cd
          SET y = (ino_temp->orders[x].action_cnt+ 1)
         ELSEIF ((ino_temp->orders[x].actions[y].action_sequence=action))
          SET y = (ino_temp->orders[x].action_cnt+ 1)
         ENDIF
       ENDFOR
      ENDIF
      SET x = (ino_temp->order_cnt+ 1)
     ELSEIF ((ino_temp->orders[x].order_id > orderid))
      SET x = (ino_temp->order_cnt+ 1)
     ENDIF
   ENDFOR
   RETURN(verifyind)
 END ;Subroutine
 SUBROUTINE loadtasks(null)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(ordercnt)),
     orders o,
     task_activity ta,
     order_task ot,
     order_task_position_xref otpx
    PLAN (d)
     JOIN (o
     WHERE (o.order_id=reply->orders[d.seq].order_id))
     JOIN (ta
     WHERE outerjoin(o.order_id)=ta.order_id
      AND outerjoin(pendingtaskcd)=ta.task_status_cd)
     JOIN (ot
     WHERE outerjoin(ta.reference_task_id)=ot.reference_task_id)
     JOIN (otpx
     WHERE outerjoin(ot.reference_task_id)=otpx.reference_task_id
      AND outerjoin(userpositioncd)=otpx.position_cd)
    ORDER BY d.seq, o.order_id, ta.task_id
    HEAD d.seq
     ct_cnt = size(reply->orders[d.seq].tasks,5)
     IF (ct_cnt > 0)
      mod_cnt = ((5 - mod(ct_cnt,5))+ ct_cnt), stat = alterlist(reply->orders[d.seq].tasks,mod_cnt)
     ENDIF
    HEAD ta.task_id
     IF (ta.task_id > 0)
      ct_cnt = (ct_cnt+ 1)
      IF (mod(ct_cnt,5)=1)
       stat = alterlist(reply->orders[d.seq].tasks,(ct_cnt+ 4))
      ENDIF
      reply->orders[d.seq].tasks[ct_cnt].task_id = ta.task_id, reply->orders[d.seq].tasks[ct_cnt].
      order_id = ta.order_id, reply->orders[d.seq].tasks[ct_cnt].task_status_cd = ta.task_status_cd,
      reply->orders[d.seq].tasks[ct_cnt].task_class_cd = ta.task_class_cd, reply->orders[d.seq].
      tasks[ct_cnt].task_activity_cd = ta.task_activity_cd, reply->orders[d.seq].tasks[ct_cnt].
      careset_id = ta.careset_id,
      reply->orders[d.seq].tasks[ct_cnt].iv_ind = ta.iv_ind, reply->orders[d.seq].tasks[ct_cnt].
      tpn_ind = ta.tpn_ind, reply->orders[d.seq].tasks[ct_cnt].task_dt_tm = ta.task_dt_tm,
      reply->orders[d.seq].tasks[ct_cnt].dcp_forms_ref_id = ot.dcp_forms_ref_id
      IF (cnvtdatetime(curdate,curtime) > cnvtdatetime(ta.task_dt_tm))
       reply->orders[d.seq].tasks[ct_cnt].task_dt_tm = cnvtdatetime(curdate,curtime)
      ENDIF
      reply->orders[d.seq].tasks[ct_cnt].updt_cnt = ta.updt_cnt, reply->orders[d.seq].tasks[ct_cnt].
      event_id = ta.event_id
      IF (((ot.allpositionchart_ind=1) OR (otpx.position_cd=userpositioncd)) )
       reply->orders[d.seq].tasks[ct_cnt].priv_ind = 1
      ELSE
       reply->orders[d.seq].tasks[ct_cnt].priv_ind = 0
      ENDIF
      reply->orders[d.seq].tasks[ct_cnt].reference_task_id = ta.reference_task_id, reply->orders[d
      .seq].tasks[ct_cnt].task_type_cd = ta.task_type_cd, reply->orders[d.seq].tasks[ct_cnt].
      description = ot.task_description,
      reply->orders[d.seq].tasks[ct_cnt].chart_not_done_ind = ot.chart_not_cmplt_ind, reply->orders[d
      .seq].tasks[ct_cnt].quick_chart_ind = ot.quick_chart_ind, reply->orders[d.seq].tasks[ct_cnt].
      event_cd = ot.event_cd,
      reply->orders[d.seq].tasks[ct_cnt].reschedule_time = ot.reschedule_time, reply->orders[d.seq].
      tasks[ct_cnt].task_priority_cd = ta.task_priority_cd, reply->orders[d.seq].tasks[ct_cnt].
      task_tz = ta.task_tz
     ENDIF
    FOOT  d.seq
     stat = alterlist(reply->orders[d.seq].tasks,ct_cnt)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE populateivorderswithrslts(null)
   DECLARE countloc = i2 WITH noconstant(0), protect
   DECLARE x = i2 WITH noconstant(0), protect
   SELECT
    IF (encntr_cnt > 0)
     PLAN (ce
      WHERE (ce.person_id=request->person_id)
       AND cnvtdatetime(request->start_dt_tm) < ce.event_end_dt_tm
       AND cnvtdatetime(request->end_dt_tm) > ce.event_end_dt_tm
       AND expand(x,1,encntr_cnt,(ce.encntr_id+ 0),request->encntr_list[x].encntr_id)
       AND ce.order_id > 0.0)
      JOIN (cmr
      WHERE cmr.event_id=ce.event_id
       AND cmr.iv_event_cd IN (infuse_cd, bolus_cd))
    ELSE
     PLAN (ce
      WHERE (ce.person_id=request->person_id)
       AND cnvtdatetime(request->start_dt_tm) < ce.event_end_dt_tm
       AND cnvtdatetime(request->end_dt_tm) > ce.event_end_dt_tm
       AND ce.order_id > 0.0)
      JOIN (cmr
      WHERE cmr.event_id=ce.event_id
       AND cmr.iv_event_cd IN (infuse_cd, bolus_cd))
    ENDIF
    INTO "nl:"
    ce.order_id
    FROM clinical_event ce,
     ce_med_result cmr
    ORDER BY ce.order_id
    HEAD REPORT
     countloc = 0
    HEAD ce.order_id
     countloc = (countloc+ 1)
     IF (mod(countloc,10)=1)
      stat = alterlist(ivorders_with_rslts->orders,(countloc+ 9))
     ENDIF
     ivorders_with_rslts->orders[countloc].order_id = ce.order_id
    FOOT REPORT
     stat = alterlist(ivorders_with_rslts->orders,countloc), ivorders_with_rslts->order_cnt =
     countloc
    WITH nocounter, nullreport
   ;end select
 END ;Subroutine
 SUBROUTINE loadorderingredients(null)
   DECLARE orderiterator = i4 WITH noconstant(0)
   DECLARE orderlocator = i4 WITH noconstant(0)
   DECLARE orderindex = i4 WITH noconstant(0)
   DECLARE ingredientcnt = i4 WITH noconstant(0)
   DECLARE ingredientindex = i4 WITH noconstant(0)
   DECLARE catalogcnt = i4 WITH noconstant(0)
   DECLARE cataloglocator = i4 WITH noconstant(0)
   DECLARE catalogindex = i4 WITH noconstant(0)
   DECLARE renewiterator = i4 WITH noconstant(0)
   DECLARE renewindex = i4 WITH noconstant(0)
   DECLARE nstart = i4 WITH protect, noconstant(1)
   DECLARE nsize = i4 WITH protect, constant(50)
   DECLARE iordercnt = i4 WITH protect, noconstant(size(reply->orders,5))
   DECLARE ntotal = i4 WITH protect, noconstant((ceil((cnvtreal(ordercnt)/ nsize)) * nsize))
   SET stat = alterlist(reply->orders,ntotal)
   FOR (i = (ordercnt+ 1) TO ntotal)
     SET reply->orders[i].order_id = reply->orders[ordercnt].order_id
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
     order_ingredient oi,
     order_catalog oc,
     order_catalog_synonym ocs
    PLAN (d1
     WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ nsize))))
     JOIN (oi
     WHERE expand(orderiterator,nstart,(nstart+ (nsize - 1)),oi.order_id,reply->orders[orderiterator]
      .order_id)
      AND (oi.action_sequence=
     (SELECT
      max(oi2.action_sequence)
      FROM order_ingredient oi2
      WHERE oi2.order_id=oi.order_id)))
     JOIN (oc
     WHERE oc.catalog_cd=oi.catalog_cd)
     JOIN (ocs
     WHERE ocs.synonym_id=oi.synonym_id)
    ORDER BY oi.order_id, oi.comp_sequence
    HEAD oi.order_id
     ingredientcnt = 0, orderindex = locateval(orderlocator,1,ordercnt,oi.order_id,reply->orders[
      orderlocator].order_id)
    DETAIL
     ingredientcnt = (ingredientcnt+ 1)
     IF (mod(ingredientcnt,5)=1)
      stat = alterlist(reply->orders[orderindex].ingred_qual,(ingredientcnt+ 4))
     ENDIF
     reply->orders[orderindex].ingred_qual[ingredientcnt].hna_order_mnemonic = oi.hna_order_mnemonic,
     reply->orders[orderindex].ingred_qual[ingredientcnt].ordered_as_mnemonic = oi
     .ordered_as_mnemonic, reply->orders[orderindex].ingred_qual[ingredientcnt].order_mnemonic = oi
     .order_mnemonic,
     reply->orders[orderindex].ingred_qual[ingredientcnt].order_detail_display_line = oi
     .order_detail_display_line, reply->orders[orderindex].ingred_qual[ingredientcnt].
     ingredient_type_flag = oi.ingredient_type_flag, reply->orders[orderindex].ingred_qual[
     ingredientcnt].comp_sequence = oi.comp_sequence,
     reply->orders[orderindex].ingred_qual[ingredientcnt].strength = oi.strength, reply->orders[
     orderindex].ingred_qual[ingredientcnt].strength_unit = oi.strength_unit, reply->orders[
     orderindex].ingred_qual[ingredientcnt].volume = oi.volume,
     reply->orders[orderindex].ingred_qual[ingredientcnt].volume_unit = oi.volume_unit, reply->
     orders[orderindex].ingred_qual[ingredientcnt].freetext_dose = oi.freetext_dose, reply->orders[
     orderindex].ingred_qual[ingredientcnt].freq_cd = oi.freq_cd,
     reply->orders[orderindex].ingred_qual[ingredientcnt].catalog_cd = oi.catalog_cd, reply->orders[
     orderindex].ingred_qual[ingredientcnt].catalog_type_cd = oi.catalog_type_cd, reply->orders[
     orderindex].ingred_qual[ingredientcnt].synonym_id = oi.synonym_id,
     reply->orders[orderindex].ingred_qual[ingredientcnt].include_in_total_volume_flag = oi
     .include_in_total_volume_flag, reply->orders[orderindex].ingred_qual[ingredientcnt].
     normalized_rate = oi.normalized_rate, reply->orders[orderindex].ingred_qual[ingredientcnt].
     normalized_rate_unit_cd = oi.normalized_rate_unit_cd,
     reply->orders[orderindex].ingred_qual[ingredientcnt].ingredient_rate_conversion_ind = ocs
     .ingredient_rate_conversion_ind, reply->orders[orderindex].ingred_qual[ingredientcnt].
     display_additives_first_ind = ocs.display_additives_first_ind, catalogindex = locateval(
      cataloglocator,1,catalogcnt,oi.catalog_cd,temp->catalogs[cataloglocator].catalog_cd)
     IF (catalogindex=0)
      catalogcnt = (catalogcnt+ 1)
      IF (mod(catalogcnt,10)=1)
       stat = alterlist(temp->catalogs,(catalogcnt+ 9))
      ENDIF
      temp->catalogs[catalogcnt].catalog_cd = oi.catalog_cd, temp->catalogs[catalogcnt].stop_type_cd
       = oc.stop_type_cd, temp->catalogs[catalogcnt].stop_duration = oc.stop_duration,
      temp->catalogs[catalogcnt].stop_duration_unit_cd = oc.stop_duration_unit_cd, temp->catalogs[
      catalogcnt].cnt = 0, catalogindex = catalogcnt,
      renewindex = locateval(renewiterator,1,renewcnt,oi.catalog_cd,temp->order_renews[renewiterator]
       .catalog_cd)
      IF (renewindex <= 0)
       renewcnt = (renewcnt+ 1)
       IF (mod(renewcnt,10)=1)
        stat = alterlist(temp->order_renews,(renewcnt+ 9))
       ENDIF
       temp->order_renews[renewcnt].catalog_cd = oi.catalog_cd, temp->order_renews[renewcnt].found =
       0, temp->order_renews[renewcnt].ordercnt = 0
      ENDIF
     ENDIF
     temp->catalogs[catalogindex].cnt = (temp->catalogs[catalogindex].cnt+ 1)
     IF (mod(temp->catalogs[catalogindex].cnt,3)=1)
      stat = alterlist(temp->catalogs[catalogindex].qual,(temp->catalogs[catalogindex].cnt+ 2))
     ENDIF
     temp->catalogs[catalogindex].qual[temp->catalogs[catalogindex].cnt].orderindex = orderindex,
     temp->catalogs[catalogindex].qual[temp->catalogs[catalogindex].cnt].ingredientindex =
     ingredientcnt
    FOOT  oi.order_id
     stat = alterlist(reply->orders[orderindex].ingred_qual,ingredientcnt)
    WITH nocounter
   ;end select
   SET stat = alterlist(reply->orders,iordercnt)
   IF (catalogcnt > 0)
    DECLARE icatcnt = i4 WITH protect, noconstant(size(temp->catalogs,5))
    SET nstart = 1
    SET ntotal = (ceil((cnvtreal(catalogcnt)/ nsize)) * nsize)
    SET stat = alterlist(temp->catalogs,ntotal)
    FOR (i = (catalogcnt+ 1) TO ntotal)
      SET temp->catalogs[i].catalog_cd = temp->catalogs[catalogcnt].catalog_cd
    ENDFOR
    SELECT INTO "nl"
     FROM (dummyt d1  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
      code_value_event_r cvr
     PLAN (d1
      WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ nsize))))
      JOIN (cvr
      WHERE expand(orderiterator,nstart,(nstart+ (nsize - 1)),cvr.parent_cd,temp->catalogs[
       orderiterator].catalog_cd))
     DETAIL
      catalogindex = locateval(cataloglocator,1,catalogcnt,cvr.parent_cd,temp->catalogs[
       cataloglocator].catalog_cd)
      FOR (x = 1 TO temp->catalogs[catalogindex].cnt)
        orderindex = temp->catalogs[catalogindex].qual[x].orderindex, ingredientindex = temp->
        catalogs[catalogindex].qual[x].ingredientindex, reply->orders[orderindex].ingred_qual[
        ingredientindex].event_cd = cvr.event_cd
      ENDFOR
     WITH nocounter
    ;end select
    SET stat = alterlist(temp->catalogs,icatcnt)
   ENDIF
 END ;Subroutine
 SUBROUTINE loadorderdetails(null)
   DECLARE orderiterator = i4 WITH noconstant(0)
   DECLARE orderlocator = i4 WITH noconstant(0)
   DECLARE orderindex = i4 WITH noconstant(0)
   DECLARE detailcnt = i4 WITH noconstant(0)
   DECLARE detailindex = i4 WITH noconstant(0)
   DECLARE nstart = i4 WITH protect, noconstant(1)
   DECLARE nsize = i4 WITH protect, constant(50)
   DECLARE iordercnt = i4 WITH protect, noconstant(size(reply->orders,5))
   DECLARE ntotal = i4 WITH protect, noconstant((ceil((cnvtreal(ordercnt)/ nsize)) * nsize))
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
     WHERE expand(orderiterator,nstart,(nstart+ (nsize - 1)),od.order_id,reply->orders[orderiterator]
      .order_id)
      AND (od.action_sequence=
     (SELECT
      max(od2.action_sequence)
      FROM order_detail od2
      WHERE od2.order_id=od.order_id
       AND od2.oe_field_id=od.oe_field_id))
      AND od.oe_field_meaning_id IN (oe_rate, oe_rate_unit, oe_site, oe_dispense_cat,
     oe_freetext_rate))
    ORDER BY od.order_id, od.oe_field_id
    HEAD od.order_id
     detailcnt = 0, orderindex = locateval(orderlocator,1,ordercnt,od.order_id,reply->orders[
      orderlocator].order_id)
    DETAIL
     detailcnt = (detailcnt+ 1)
     IF (mod(detailcnt,5)=1)
      stat = alterlist(reply->orders[orderindex].detail_qual,(detailcnt+ 4))
     ENDIF
     reply->orders[orderindex].detail_qual[detailcnt].oe_field_display_value = od
     .oe_field_display_value, reply->orders[orderindex].detail_qual[detailcnt].oe_field_dt_tm_value
      = od.oe_field_dt_tm_value, reply->orders[orderindex].detail_qual[detailcnt].oe_field_tz = od
     .oe_field_tz,
     reply->orders[orderindex].detail_qual[detailcnt].oe_field_id = od.oe_field_id, reply->orders[
     orderindex].detail_qual[detailcnt].oe_field_meaning_id = od.oe_field_meaning_id, reply->orders[
     orderindex].detail_qual[detailcnt].oe_field_value = od.oe_field_value
    FOOT  od.order_id
     stat = alterlist(reply->orders[orderindex].detail_qual,detailcnt)
    WITH nocounter
   ;end select
   SET stat = alterlist(reply->orders,iordercnt)
 END ;Subroutine
 SUBROUTINE setrenewalindicators(null)
   IF (renewcnt > 0)
    DECLARE x = i4 WITH noconstant(0)
    DECLARE y = i4 WITH noconstant(0)
    DECLARE z = i4 WITH noconstant(0)
    DECLARE catalogcnt = i4 WITH noconstant(0)
    DECLARE notificationperiod = i4 WITH noconstant(0)
    DECLARE current_dt_tm = dq8 WITH noconstant(cnvtdatetime(curdate,curtime))
    DECLARE renewdttm = dq8 WITH noconstant(current_dt_tm)
    DECLARE orderindex = i4 WITH noconstant(0)
    DECLARE catalogindex = i4 WITH noconstant(0)
    DECLARE default_renew_dt_tm = dq8 WITH noconstant(current_dt_tm)
    DECLARE nstart = i4 WITH protect, noconstant(1)
    DECLARE nsize = i4 WITH protect, constant(50)
    DECLARE iordercnt = i4 WITH protect, noconstant(size(temp->order_renews,5))
    DECLARE ntotal = i4 WITH protect, noconstant((ceil((cnvtreal(renewcnt)/ nsize)) * nsize))
    SELECT INTO "nl:"
     FROM renew_notification_period rnp
     WHERE rnp.stop_type_cd=0
      AND rnp.stop_duration=0
      AND rnp.stop_duration_unit_cd=0
     DETAIL
      default_renew_dt_tm = cnvtlookahead(build(cnvtint(rnp.notification_period),"h"),cnvtdatetime(
        current_dt_tm))
     WITH nocounter
    ;end select
    SET stat = alterlist(temp->order_renews,ntotal)
    FOR (i = (renewcnt+ 1) TO ntotal)
      SET temp->order_renews[i].catalog_cd = temp->order_renews[renewcnt].catalog_cd
    ENDFOR
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
      order_catalog oc,
      renew_notification_period rnp
     PLAN (d1
      WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ nsize))))
      JOIN (oc
      WHERE expand(x,nstart,(nstart+ (nsize - 1)),oc.catalog_cd,temp->order_renews[x].catalog_cd)
       AND oc.stop_duration > 0
       AND oc.stop_type_cd > 0.0)
      JOIN (rnp
      WHERE rnp.stop_type_cd=oc.stop_type_cd
       AND rnp.stop_duration=oc.stop_duration
       AND rnp.stop_duration_unit_cd=oc.stop_duration_unit_cd)
     DETAIL
      catalogindex = locateval(y,1,renewcnt,oc.catalog_cd,temp->order_renews[y].catalog_cd), temp->
      order_renews[catalogindex].found = 1, notificationperiod = cnvtint(rnp.notification_period),
      renewdttm = cnvtlookahead(build(notificationperiod,"h"),cnvtdatetime(current_dt_tm))
      FOR (z = 1 TO temp->order_renews[catalogindex].ordercnt)
       y = temp->order_renews[catalogindex].orders[z].orderindex,
       IF ((reply->orders[y].projected_stop_dt_tm < cnvtdatetime(renewdttm)))
        IF ((reply->orders[y].stop_type_cd=hard_stop_cd))
         reply->orders[y].need_renew_ind = 2
        ELSEIF ((reply->orders[y].stop_type_cd=soft_stop_cd))
         reply->orders[y].need_renew_ind = 1
        ENDIF
       ENDIF
      ENDFOR
     WITH nocounter
    ;end select
    SET stat = alterlist(temp->order_renews,iordercnt)
    FOR (catalogindex = 1 TO renewcnt)
      IF ((temp->order_renews[catalogindex].found=0))
       FOR (z = 1 TO temp->order_renews[catalogindex].ordercnt)
        SET y = temp->order_renews[catalogindex].orders[z].orderindex
        IF ((reply->orders[y].projected_stop_dt_tm < cnvtdatetime(default_renew_dt_tm)))
         IF ((reply->orders[y].stop_type_cd=hard_stop_cd))
          SET reply->orders[y].need_renew_ind = 2
         ELSEIF ((reply->orders[y].stop_type_cd=soft_stop_cd))
          SET reply->orders[y].need_renew_ind = 1
         ENDIF
        ENDIF
       ENDFOR
      ENDIF
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE loadordercomments(null)
   IF (ordercommentcnt > 0)
    DECLARE x = i4 WITH noconstant(0)
    DECLARE y = i4 WITH noconstant(0)
    DECLARE nstart = i4 WITH protect, noconstant(1)
    DECLARE nsize = i4 WITH protect, constant(50)
    DECLARE icommentcnt = i4 WITH protect, noconstant(size(temp->order_comments,5))
    DECLARE ntotal = i4 WITH protect, noconstant((ceil((cnvtreal(ordercommentcnt)/ nsize)) * nsize))
    SET stat = alterlist(temp->order_comments,ntotal)
    FOR (i = (ordercommentcnt+ 1) TO ntotal)
      SET temp->order_comments[i].order_id = temp->order_comments[ordercommentcnt].order_id
    ENDFOR
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
      order_comment oc,
      long_text lt
     PLAN (d1
      WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ nsize))))
      JOIN (oc
      WHERE expand(x,nstart,(nstart+ (nsize - 1)),oc.order_id,temp->order_comments[x].order_id)
       AND oc.comment_type_cd=order_comment_cd
       AND (oc.action_sequence=
      (SELECT
       max(oc2.action_sequence)
       FROM order_comment oc2
       WHERE oc2.order_id=oc.order_id
        AND oc2.comment_type_cd=order_comment_cd)))
      JOIN (lt
      WHERE lt.long_text_id=oc.long_text_id)
     ORDER BY oc.order_id, oc.action_sequence
     HEAD oc.order_id
      oidx = locateval(y,1,ordercommentcnt,oc.order_id,temp->order_comments[y].order_id), oidx = temp
      ->order_comments[oidx].orderindex
     DETAIL
      reply->orders[oidx].order_comment_text = lt.long_text
     WITH nocounter
    ;end select
    SET stat = alterlist(temp->order_comments,icommentcnt)
   ENDIF
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
#exit_script
 SET ierrorcode = error(serrormsg,1)
 IF (ierrorcode != 0)
  CALL echo("*********************************")
  CALL echo(build("ERROR MESSAGE : ",serrormsg))
  CALL echo("*********************************")
  CALL reportfailure("ERROR","F","dcp_get_ino_ivorders",serrormsg)
 ELSEIF (zero_ind=1)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
