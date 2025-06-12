CREATE PROGRAM bsc_get_mar_orders:dba
 SET modify = predeclare
 RECORD reply(
   1 orders[*]
     2 order_id = f8
     2 encntr_id = f8
     2 person_id = f8
     2 order_status_cd = f8
     2 order_status_disp = vc
     2 order_status_mean = vc
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
     2 verification_prsnl_id = f8
     2 verification_pos_cd = f8
     2 plan_ind = i2
     2 taper_ind = i2
     2 protocol_order_id = f8
     2 dosing_method_flag = i2
     2 warning_level_bit = i4
     2 pathway_id = f8
     2 pathway_desc = vc
     2 ivseq_ind = i2
     2 updt_dt_tm = dq8
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
       3 ingredient_rate_conversion_ind = i2
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
       3 display_additives_first_ind = i2
       3 last_admin_disp_basis_flag = i2
       3 med_interval_warn_flag = i2
       3 include_in_total_volume_flag = i2
     2 order_actions[*]
       3 action_sequence = i4
       3 action_dt_tm = dq8
       3 action_tz = i4
       3 action_type_cd = f8
       3 action_type_disp = vc
       3 action_type_mean = vc
       3 need_rx_verify_ind = i2
       3 need_rx_clin_review_flag = i2
       3 verification_prsnl_id = f8
       3 verification_pos_cd = f8
       3 prn_ind = i2
       3 constant_ind = i2
       3 core_ind = i2
       3 order_details[*]
         4 action_sequence = i4
         4 oe_field_id = f8
         4 oe_field_meaning = vc
         4 oe_field_meaning_id = f8
         4 oe_field_value = f8
         4 oe_field_display_value = vc
         4 oe_field_dt_tm = dq8
         4 oe_field_tz = i4
     2 response_task_info[*]
       3 response_task_reference_id = f8
       3 response_task_description = vc
       3 response_event_cd = f8
     2 protocol_order_ind = i2
     2 template_order_list[*]
       3 order_id = f8
       3 start_dt_tm = dq8
       3 end_dt_tm = dq8
       3 encntr_id = f8
       3 order_status_cd = f8
       3 last_action_sequence = i4
       3 core_action_sequence = i4
       3 treatment_period_description = vc
       3 corrupted_dot_found = i4
     2 order_details[*]
       3 action_sequence = i4
       3 oe_field_id = f8
       3 oe_field_meaning = vc
       3 oe_field_meaning_id = f8
       3 oe_field_value = f8
       3 oe_field_display_value = vc
       3 oe_field_dt_tm = dq8
       3 oe_field_tz = i4
     2 applicable_fields_bit = i4
     2 finished_bags_cnt = i4
     2 total_bags_nbr = i4
     2 order_iv_info_updt_cnt = i4
     2 reschedule_ind = i2
     2 corrupt_protocol_ord_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD martemp
 RECORD martemp(
   1 responsetaskorders[*]
     2 index = i4
 )
 FREE RECORD missingorders
 RECORD missingorders(
   1 order_list[*]
     2 order_id = f8
 )
 FREE RECORD protocolorders
 RECORD protocolorders(
   1 order_list[*]
     2 order_id = f8
 )
 FREE RECORD temporderids
 RECORD temporderids(
   1 order_list[*]
     2 order_id = f8
     2 catalog_list[*]
       3 catalog_cd = f8
   1 catalog_list[*]
     2 catalog_cd = f8
 )
 FREE RECORD protocolanddotorders
 RECORD protocolanddotorders(
   1 dot_ord_list[*]
     2 protocol_ord_id = f8
     2 uncorrupted_dot_cnt = i4
     2 dots[*]
       3 dot_ord_id = f8
       3 uncorrupted_dots = i2
       3 end_dt_tm = dq8
       3 treat_period_desc = vc
 )
 FREE RECORD dotorders
 RECORD dotorders(
   1 dot_ord_list[*]
     2 protocol_ord_id = f8
     2 dot_ord_id = f8
 )
 DECLARE initialize(null) = null
 DECLARE loadmissingorders(null) = null
 DECLARE loadordercomments(null) = null
 DECLARE loadresponsetaskinfo(null) = null
 DECLARE setrenewalindicators(null) = null
 DECLARE getcatalogevents(null) = null
 DECLARE loadcatalogeventcodes(null) = null
 DECLARE loaddtas(null) = null
 DECLARE settaperindicator(null) = null
 DECLARE prepareloadmissingorders(null) = null
 DECLARE prepareloadtreatmentorders(null) = null
 DECLARE gettemplateordersforprotocol(null) = null
 DECLARE loaddotorderforprotocol(null) = null
 DECLARE loadtreatmentdescfordotorders(null) = null
 DECLARE populatereplyfordotorder(null) = null
 DECLARE updateuncorrupteddotorderscount(null) = null
 DECLARE loadorderdetails(null) = null
 DECLARE populateorderreply(null) = null
 DECLARE isreschedulable(null) = null
 DECLARE totaltime = f8 WITH noconstant(cnvtdatetime(sysdate))
 DECLARE last_mod = c12 WITH private, noconstant(fillstring(12," "))
 DECLARE order_cnt = i4 WITH noconstant(0)
 DECLARE missing_order_cnt = i4 WITH noconstant(0)
 DECLARE encntr_cnt = i4 WITH noconstant(0)
 DECLARE response_cnt = i4 WITH noconstant(0)
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE debug_ind = i2 WITH protect, noconstant(0)
 DECLARE search_from_dt_tm = dq8
 DECLARE current_dt_tm = dq8
 DECLARE renew_look_back = i4 WITH noconstant(24)
 DECLARE default_renew_look_back = i4 WITH noconstant(24)
 DECLARE default_renew_dt_tm = dq8
 DECLARE interval = vc
 DECLARE error_msg = vc WITH protect, noconstant("")
 DECLARE error_cd = i2 WITH protect, noconstant(0)
 DECLARE protocol_found_ind = i2 WITH protect, noconstant(0)
 DECLARE protocol_order_cnt = i4 WITH protect, noconstant(0)
 DECLARE ordercount = i4 WITH protect, noconstant(0)
 DECLARE proordcount = i4 WITH protect, noconstant(0)
 DECLARE pharmacy_cd = f8 WITH constant(uar_get_code_by("MEANING",6000,"PHARMACY"))
 DECLARE hard_stop_cd = f8 WITH constant(uar_get_code_by("MEANING",4009,"HARD"))
 DECLARE soft_stop_cd = f8 WITH constant(uar_get_code_by("MEANING",4009,"SOFT"))
 DECLARE order_comment_cd = f8 WITH constant(uar_get_code_by("MEANING",14,"ORD COMMENT"))
 DECLARE iv_cd = f8 WITH constant(uar_get_code_by("MEANING",18309,"IV"))
 DECLARE cancel_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"CANCELED"))
 DECLARE completed_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"COMPLETED"))
 DECLARE deleted_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"DELETED"))
 DECLARE discontinued_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"DISCONTINUED"))
 DECLARE trans_cancel_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"TRANS/CANCEL"))
 DECLARE voided_wrslt_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"VOIDEDWRSLT"))
 DECLARE future_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"FUTURE"))
 DECLARE incomplete_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"INCOMPLETE"))
 DECLARE inprocess_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"INPROCESS"))
 DECLARE medstudent_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"MEDSTUDENT"))
 DECLARE ordered_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"ORDERED"))
 DECLARE pending_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"PENDING"))
 DECLARE pending_rev_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"PENDING REV"))
 DECLARE suspended_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"SUSPENDED"))
 DECLARE unscheduled_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"UNSCHEDULED"))
 DECLARE ivsequence_cd = f8 WITH constant(uar_get_code_by("MEANING",30183,"IVSEQUENCE"))
 DECLARE compound_child = i2 WITH constant(5)
 DECLARE o_verified = i2 WITH constant(0)
 DECLARE o_needs_review = i2 WITH constant(1)
 DECLARE o_rejected = i2 WITH constant(2)
 DECLARE oa_no_verify_needed = i2 WITH constant(0)
 DECLARE oa_verify_needed = i2 WITH constant(1)
 DECLARE oa_superceded = i2 WITH constant(2)
 DECLARE oa_verified = i2 WITH constant(3)
 DECLARE oa_rejected = i2 WITH constant(4)
 DECLARE oa_reviewed = i2 WITH constant(5)
 DECLARE clinreviewflag_unset = i2 WITH constant(0)
 DECLARE clinreviewflag_needs_review = i2 WITH constant(1)
 DECLARE clinreviewflag_reviewed = i2 WITH constant(2)
 DECLARE clinreviewflag_rejected = i2 WITH constant(3)
 DECLARE clinreviewflag_dna = i2 WITH constant(4)
 DECLARE clinreviewflag_superceded = i2 WITH constant(5)
 DECLARE itmpordcnt = i4 WITH protect, noconstant(0)
 CALL initialize(null)
 IF (missing_order_cnt > 0)
  IF ((request->enable_protocol_ind=1))
   CALL prepareloadmissingorders(null)
   IF (protocol_order_cnt > 0)
    CALL prepareloadtreatmentorders(null)
   ENDIF
  ENDIF
  CALL loadmissingorders(null)
 ELSE
  IF ((request->load_active_flag > 0))
   CALL loadorders((request->load_active_flag - 1))
  ELSE
   CALL loadorders(1)
   CALL loadorders(0)
  ENDIF
  IF (protocol_order_cnt > 0
   AND (request->enable_protocol_ind=1))
   CALL prepareloadtreatmentorders(null)
  ENDIF
  IF (missing_order_cnt > 0)
   CALL loadmissingorders(null)
  ENDIF
 ENDIF
 IF (protocol_found_ind > 0)
  CALL gettemplateordersforprotocol(null)
  CALL loaddotorderforprotocol(null)
  CALL populatereplyfordotorder(null)
 ENDIF
 IF (order_cnt > 0)
  CALL setrenewalindicators(null)
  CALL getcatalogevents(null)
  CALL loadcatalogeventcodes(null)
  CALL loaddtas(null)
  CALL loadordercomments(null)
  IF (response_cnt > 0)
   CALL loadresponsetaskinfo(null)
  ENDIF
  CALL settaperindicator(null)
  CALL loadorderdetails(null)
 ENDIF
 CALL isreschedulable(null)
 IF (debug_ind=1)
  CALL echo("*********************************")
  CALL echo(build("Total Time = ",datetimediff(cnvtdatetime(sysdate),totaltime,5)))
  CALL echo("*********************************")
 ELSE
  FREE RECORD martemp
  FREE RECORD temporderids
 ENDIF
 IF (order_cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET error_cd = error(error_msg,1)
 IF (error_cd != 0)
  CALL echo("*********************************")
  CALL echo(build("ERROR MESSAGE : ",error_msg))
  CALL echo("*********************************")
  SET reply->status_data.status = "F"
 ENDIF
 SUBROUTINE initialize(null)
   IF (debug_ind=1)
    CALL echo("********Initialize********")
   ENDIF
   DECLARE initializetime = f8 WITH protect, noconstant(cnvtdatetime(sysdate))
   SET order_cnt = 0
   SET missing_order_cnt = size(request->order_list,5)
   SET encntr_cnt = size(request->encntr_list,5)
   SET current_dt_tm = cnvtdatetime(curdate,curtime)
   SET reply->status_data.status = "F"
   IF (request->debug_ind)
    SET debug_ind = request->debug_ind
   ELSE
    SET debug_ind = 0
   ENDIF
   IF (missing_order_cnt > 0)
    SET stat = alterlist(missingorders->order_list,missing_order_cnt)
    SET stat = moverec(request->order_list,missingorders->order_list)
   ENDIF
   IF (missing_order_cnt=0)
    SET search_from_dt_tm = cnvtdatetime(request->start_dt_tm)
    IF ((request->overdue_look_back > 0))
     SET search_from_dt_tm = cnvtdatetime((curdate - request->overdue_look_back),curtime)
     IF (cnvtdatetime(search_from_dt_tm) > cnvtdatetime(request->start_dt_tm))
      SET search_from_dt_tm = cnvtdatetime(request->start_dt_tm)
     ENDIF
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    FROM renew_notification_period rnp
    PLAN (rnp
     WHERE rnp.stop_type_cd=0
      AND rnp.stop_duration=1
      AND rnp.stop_duration_unit_cd=0)
    DETAIL
     default_renew_look_back = cnvtint(rnp.notification_period)
    WITH nocounter
   ;end select
   SET interval = build(default_renew_look_back,"h")
   SET default_renew_dt_tm = cnvtlookahead(interval,cnvtdatetime(current_dt_tm))
   CALL printdebug(build("********Initialize Time = ",datetimediff(cnvtdatetime(sysdate),
      initializetime,5)))
 END ;Subroutine
 SUBROUTINE (loadorders(active_ind=i2) =null)
   IF (debug_ind=1)
    CALL echo("********LoadOrders********")
   ENDIF
   DECLARE loadordertime = f8 WITH protect, noconstant(cnvtdatetime(sysdate))
   DECLARE iterator = i4 WITH protect, noconstant(0)
   DECLARE encntr_in_clause = vc WITH protect, noconstant(fillstring(100," "))
   DECLARE locit = i4 WITH protect, noconstant(0)
   DECLARE propos = i4 WITH protect, noconstant(0)
   DECLARE proidx = i4 WITH protect, noconstant(0)
   IF (encntr_cnt > 0
    AND active_ind > 0)
    CALL printdebug("Load active from encounter list")
   ELSEIF (encntr_cnt > 0)
    CALL printdebug("Load inactive from encounter list")
   ELSEIF (active_ind > 0)
    CALL printdebug("Load active without encounter list")
   ELSE
    CALL printdebug("Load inactive without encounter list")
   ENDIF
   SELECT
    IF (encntr_cnt > 0
     AND active_ind > 0)
     PLAN (o
      WHERE (o.person_id=request->person_id)
       AND ((o.catalog_type_cd+ 0)=pharmacy_cd)
       AND ((o.template_order_id+ 0)=0)
       AND o.template_order_flag IN (0, 1, 7)
       AND ((o.orderable_type_flag+ 0) IN (0, 1, 8, 10, 11,
      13))
       AND expand(iterator,1,encntr_cnt,(o.encntr_id+ 0),request->encntr_list[iterator].encntr_id)
       AND ((o.orig_ord_as_flag+ 0) IN (0, 5))
       AND o.order_status_cd IN (future_cd, incomplete_cd, inprocess_cd, medstudent_cd, ordered_cd,
      pending_cd, pending_rev_cd, suspended_cd, unscheduled_cd))
      JOIN (oi
      WHERE oi.order_id=o.order_id)
      JOIN (oc
      WHERE oc.catalog_cd=oi.catalog_cd)
      JOIN (ocs
      WHERE ocs.synonym_id=oi.synonym_id)
      JOIN (oiv
      WHERE (oiv.order_id= Outerjoin(oi.order_id)) )
    ELSEIF (encntr_cnt > 0)
     PLAN (o
      WHERE (o.person_id=request->person_id)
       AND o.catalog_type_cd=pharmacy_cd
       AND ((o.template_order_id+ 0)=0)
       AND o.template_order_flag IN (0, 1, 7)
       AND ((o.orderable_type_flag+ 0) IN (0, 1, 8, 10, 11,
      13))
       AND expand(iterator,1,encntr_cnt,(o.encntr_id+ 0),request->encntr_list[iterator].encntr_id)
       AND ((o.orig_ord_as_flag+ 0) IN (0, 5))
       AND ((o.order_status_cd+ 0) IN (cancel_cd, completed_cd, deleted_cd, discontinued_cd,
      trans_cancel_cd,
      voided_wrslt_cd))
       AND o.projected_stop_dt_tm >= cnvtdatetime(search_from_dt_tm)
       AND ((o.current_start_dt_tm+ 0) <= cnvtdatetime(request->end_dt_tm)))
      JOIN (oi
      WHERE oi.order_id=o.order_id)
      JOIN (oc
      WHERE oc.catalog_cd=oi.catalog_cd)
      JOIN (ocs
      WHERE ocs.synonym_id=oi.synonym_id)
      JOIN (oiv
      WHERE (oiv.order_id= Outerjoin(oi.order_id)) )
    ELSEIF (active_ind > 0)
     PLAN (o
      WHERE (o.person_id=request->person_id)
       AND ((o.catalog_type_cd+ 0)=pharmacy_cd)
       AND ((o.template_order_id+ 0)=0)
       AND o.template_order_flag IN (0, 1, 7)
       AND ((o.orderable_type_flag+ 0) IN (0, 1, 8, 10, 11,
      13))
       AND ((o.orig_ord_as_flag+ 0) IN (0, 5))
       AND o.order_status_cd IN (future_cd, incomplete_cd, inprocess_cd, medstudent_cd, ordered_cd,
      pending_cd, pending_rev_cd, suspended_cd, unscheduled_cd))
      JOIN (oi
      WHERE oi.order_id=o.order_id)
      JOIN (oc
      WHERE oc.catalog_cd=oi.catalog_cd)
      JOIN (ocs
      WHERE ocs.synonym_id=oi.synonym_id)
      JOIN (oiv
      WHERE (oiv.order_id= Outerjoin(oi.order_id)) )
    ELSE
     PLAN (o
      WHERE (o.person_id=request->person_id)
       AND o.catalog_type_cd=pharmacy_cd
       AND ((o.template_order_id+ 0)=0)
       AND o.template_order_flag IN (0, 1, 7)
       AND ((o.orderable_type_flag+ 0) IN (0, 1, 8, 10, 11,
      13))
       AND ((o.orig_ord_as_flag+ 0) IN (0, 5))
       AND ((o.order_status_cd+ 0) IN (cancel_cd, completed_cd, deleted_cd, discontinued_cd,
      trans_cancel_cd,
      voided_wrslt_cd))
       AND o.projected_stop_dt_tm >= cnvtdatetime(search_from_dt_tm)
       AND ((o.current_start_dt_tm+ 0) <= cnvtdatetime(request->end_dt_tm)))
      JOIN (oi
      WHERE oi.order_id=o.order_id)
      JOIN (oc
      WHERE oc.catalog_cd=oi.catalog_cd)
      JOIN (ocs
      WHERE ocs.synonym_id=oi.synonym_id)
      JOIN (oiv
      WHERE (oiv.order_id= Outerjoin(oi.order_id)) )
    ENDIF
    INTO "nl:"
    FROM orders o,
     order_ingredient oi,
     order_catalog oc,
     order_catalog_synonym ocs,
     order_iv_info oiv
    ORDER BY o.protocol_order_id DESC, o.order_id DESC, oi.action_sequence DESC,
     oi.comp_sequence
    HEAD REPORT
     CALL printdebug(build("********LoadOrders Query Time = ",datetimediff(cnvtdatetime(sysdate),
       loadordertime,5)))
    HEAD o.protocol_order_id
     CALL printdebug(build("Protocol Order id = ",o.protocol_order_id))
    HEAD o.order_id
     max_oi_action_seq = oi.action_sequence, ingcnt = 0, addorder = 0
     IF (o.template_order_flag=7
      AND (request->enable_protocol_ind=1))
      propos = locateval(proidx,1,size(protocolorders->order_list,5),o.order_id,protocolorders->
       order_list[proidx].order_id)
      IF (propos=0)
       addorder = 1, protocol_order_cnt += 1
       IF (size(protocolorders->order_list,5) < protocol_order_cnt)
        stat = alterlist(protocolorders->order_list,(protocol_order_cnt+ 9))
       ENDIF
       protocolorders->order_list[protocol_order_cnt].order_id = o.order_id
      ENDIF
     ELSEIF (o.protocol_order_id > 0
      AND (request->enable_protocol_ind=1))
      IF (locateval(locit,1,order_cnt,o.protocol_order_id,reply->orders[locit].order_id)=0)
       IF (((missing_order_cnt=0) OR ((missingorders->order_list[missing_order_cnt].order_id != o
       .protocol_order_id))) )
        missing_order_cnt += 1
        IF (size(missingorders->order_list,5) < missing_order_cnt)
         stat = alterlist(missingorders->order_list,(missing_order_cnt+ 19))
        ENDIF
        missingorders->order_list[missing_order_cnt].order_id = o.protocol_order_id,
        protocol_order_cnt += 1
        IF (size(protocolorders->order_list,5) < protocol_order_cnt)
         stat = alterlist(protocolorders->order_list,(protocol_order_cnt+ 9))
        ENDIF
        protocolorders->order_list[protocol_order_cnt].order_id = o.protocol_order_id
       ENDIF
      ENDIF
     ELSEIF (o.order_status_cd IN (cancel_cd, completed_cd, deleted_cd, discontinued_cd,
     trans_cancel_cd,
     voided_wrslt_cd))
      IF (((o.projected_stop_dt_tm=null) OR (((o.projected_stop_dt_tm >= cnvtdatetime(request->
       start_dt_tm)) OR (o.stop_type_cd=soft_stop_cd)) )) )
       addorder = 1
      ENDIF
     ELSE
      addorder = 1
     ENDIF
     IF (addorder=1)
      CALL populateorderreply(null)
     ENDIF
    DETAIL
     IF (addorder=1)
      addingredient = 1
      FOR (i = 1 TO ingcnt)
        IF ((reply->orders[order_cnt].order_ingredient[i].catalog_cd=oc.catalog_cd)
         AND (reply->orders[order_cnt].order_ingredient[i].action_sequence != oi.action_sequence))
         i = (ingcnt+ 1), addingredient = 0
        ENDIF
      ENDFOR
      IF (addingredient=1)
       CALL populateorderingredientreply(ingcnt)
      ENDIF
     ENDIF
    FOOT  o.order_id
     IF (addorder=1)
      stat = alterlist(reply->orders[order_cnt].order_ingredient,ingcnt)
     ENDIF
    FOOT REPORT
     stat = alterlist(reply->orders,order_cnt), stat = alterlist(missingorders->order_list,
      missing_order_cnt), stat = alterlist(protocolorders->order_list,protocol_order_cnt)
    WITH nocounter, expand = 2
   ;end select
   CALL printdebug(build("********LoadOrders Time = ",datetimediff(cnvtdatetime(sysdate),
      loadordertime,5)))
   CALL printdebug(build("********order_cnt = ",order_cnt))
 END ;Subroutine
 SUBROUTINE loadmissingorders(null)
   IF (debug_ind=1)
    CALL echo("********LoadMissingOrders********")
    CALL echorecord(missingorders)
   ENDIF
   DECLARE encntrit = i4 WITH protect, noconstant(0)
   DECLARE loadmissingordertime = f8 WITH protect, noconstant(cnvtdatetime(sysdate))
   DECLARE iterator = i4 WITH protect, noconstant(0)
   DECLARE nstart = i4 WITH protect, noconstant(1)
   DECLARE nsize = i4 WITH protect, constant(50)
   DECLARE iordercnt = i4 WITH protect, noconstant(size(missingorders->order_list,5))
   DECLARE ntotal = i4 WITH protect, noconstant((ceil((cnvtreal(missing_order_cnt)/ nsize)) * nsize))
   SET stat = alterlist(missingorders->order_list,ntotal)
   FOR (i = (missing_order_cnt+ 1) TO ntotal)
     SET missingorders->order_list[i].order_id = missingorders->order_list[missing_order_cnt].
     order_id
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
     orders o,
     order_ingredient oi,
     order_catalog oc,
     order_catalog_synonym ocs,
     order_iv_info oiv
    PLAN (d1
     WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ nsize))))
     JOIN (o
     WHERE expand(iterator,nstart,(nstart+ (nsize - 1)),o.order_id,missingorders->order_list[iterator
      ].order_id)
      AND (((request->person_id=o.person_id)) OR (o.template_order_flag=7)) )
     JOIN (oi
     WHERE oi.order_id=o.order_id)
     JOIN (oc
     WHERE oc.catalog_cd=oi.catalog_cd)
     JOIN (ocs
     WHERE ocs.synonym_id=oi.synonym_id)
     JOIN (oiv
     WHERE (oiv.order_id= Outerjoin(oi.order_id)) )
    ORDER BY o.order_id, oi.action_sequence DESC, oi.comp_sequence
    HEAD REPORT
     IF (debug_ind=1)
      CALL echo(build("********LoadMissingOrders Query Time = ",datetimediff(cnvtdatetime(sysdate),
        loadmissingordertime,5)))
     ENDIF
    HEAD o.order_id
     max_oi_action_seq = oi.action_sequence, ingcnt = 0, addorder = 0,
     CALL populateorderreply(null)
    DETAIL
     addingredient = 1
     FOR (i = 1 TO ingcnt)
       IF ((reply->orders[order_cnt].order_ingredient[i].catalog_cd=oc.catalog_cd)
        AND (reply->orders[order_cnt].order_ingredient[i].action_sequence != oi.action_sequence))
        i = (ingcnt+ 1), addingredient = 0
       ENDIF
     ENDFOR
     IF (addingredient=1)
      CALL populateorderingredientreply(ingcnt)
     ENDIF
    FOOT  o.order_id
     stat = alterlist(reply->orders[order_cnt].order_ingredient,ingcnt)
    FOOT REPORT
     stat = alterlist(reply->orders,order_cnt)
    WITH nocounter, expand = 2
   ;end select
   SET stat = alterlist(missingorders->order_list,iordercnt)
   IF (debug_ind=1)
    CALL echo(build("********LoadMissingOrders Time = ",datetimediff(cnvtdatetime(sysdate),
       loadmissingordertime,5)))
   ENDIF
 END ;Subroutine
 SUBROUTINE loaddtas(null)
   IF (debug_ind=1)
    CALL echo("********LoadDTAs********")
   ENDIF
   DECLARE loaddtastime = f8 WITH protect, noconstant(cnvtdatetime(sysdate))
   DECLARE x = i4 WITH noconstant(0)
   DECLARE y = i4 WITH noconstant(0)
   DECLARE nstart = i4 WITH protect, noconstant(1)
   DECLARE nsize = i4 WITH protect, constant(50)
   DECLARE iordercnt = i4 WITH protect, noconstant(size(reply->orders,5))
   DECLARE ntotal = i4 WITH protect, noconstant((ceil((cnvtreal(order_cnt)/ nsize)) * nsize))
   SET stat = alterlist(reply->orders,ntotal)
   FOR (i = (order_cnt+ 1) TO ntotal)
     SET reply->orders[i].order_id = reply->orders[order_cnt].order_id
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
     order_ingredient oi,
     order_task_xref otxr,
     task_discrete_r tdr,
     discrete_task_assay dta
    PLAN (d1
     WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ nsize))))
     JOIN (oi
     WHERE expand(x,nstart,(nstart+ (nsize - 1)),oi.order_id,reply->orders[x].order_id)
      AND ((oi.ingredient_type_flag+ 0) != compound_child))
     JOIN (otxr
     WHERE otxr.catalog_cd=oi.catalog_cd)
     JOIN (tdr
     WHERE otxr.reference_task_id=tdr.reference_task_id
      AND tdr.view_only_ind != 1)
     JOIN (dta
     WHERE tdr.task_assay_cd=dta.task_assay_cd
      AND ((dta.event_cd+ 0) > 0))
    ORDER BY oi.order_id, oi.catalog_cd, tdr.sequence
    HEAD REPORT
     IF (debug_ind=1)
      CALL echo(build("********LoadDTAs Query Time = ",datetimediff(cnvtdatetime(sysdate),
        loaddtastime,5)))
     ENDIF
    HEAD oi.order_id
     oidx = locateval(y,1,order_cnt,oi.order_id,reply->orders[y].order_id), ingredcnt = size(reply->
      orders[oidx].order_ingredient,5)
    HEAD oi.catalog_cd
     cidx = locateval(y,1,ingredcnt,oi.catalog_cd,reply->orders[oidx].order_ingredient[y].catalog_cd),
     dtacnt = 0
    DETAIL
     IF ((reply->orders[oidx].med_order_type_cd != iv_cd))
      dtacnt += 1
      IF (mod(dtacnt,5)=1)
       stat = alterlist(reply->orders[oidx].order_ingredient[cidx].discretes,(dtacnt+ 4))
      ENDIF
      reply->orders[oidx].order_ingredient[cidx].discretes[dtacnt].event_cd = dta.event_cd
     ENDIF
    FOOT  oi.catalog_cd
     stat = alterlist(reply->orders[oidx].order_ingredient[cidx].discretes,dtacnt)
    WITH nocounter, expand = 2
   ;end select
   SET stat = alterlist(reply->orders,iordercnt)
   IF (debug_ind=1)
    CALL echo(build("********LoadDTAs Time = ",datetimediff(cnvtdatetime(sysdate),loaddtastime,5)))
   ENDIF
 END ;Subroutine
 SUBROUTINE loadordercomments(null)
   IF (debug_ind=1)
    CALL echo("********LoadOrderComments********")
   ENDIF
   DECLARE loadordercommentstime = f8 WITH protect, noconstant(cnvtdatetime(sysdate))
   DECLARE x = i4 WITH protect, noconstant(0)
   DECLARE tempcnt = i4 WITH protect, noconstant(0)
   DECLARE order_comment_mask = i4 WITH protect, constant(1)
   RECORD commenttemp(
     1 qual[*]
       2 index = i4
   )
   SET stat = alterlist(commenttemp->qual,order_cnt)
   FOR (x = 1 TO order_cnt)
     IF (band(reply->orders[x].comment_type_mask,order_comment_mask)=order_comment_mask)
      SET tempcnt += 1
      SET commenttemp->qual[tempcnt].index = x
     ENDIF
   ENDFOR
   IF (tempcnt > 0)
    DECLARE y = i4 WITH protect, noconstant(0)
    DECLARE nstart = i4 WITH protect, noconstant(1)
    DECLARE nsize = i4 WITH protect, constant(50)
    DECLARE iordercnt = i4 WITH protect, noconstant(size(commenttemp->qual,5))
    DECLARE ntotal = i4 WITH protect, noconstant((ceil((cnvtreal(tempcnt)/ nsize)) * nsize))
    SET stat = alterlist(commenttemp->qual,ntotal)
    FOR (i = (tempcnt+ 1) TO ntotal)
      SET commenttemp->qual[i].index = commenttemp->qual[tempcnt].index
    ENDFOR
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
      order_comment oc,
      long_text lt
     PLAN (d1
      WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ nsize))))
      JOIN (oc
      WHERE expand(x,nstart,(nstart+ (nsize - 1)),oc.order_id,reply->orders[commenttemp->qual[x].
       index].order_id)
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
     WITH nocounter, expand = 2
    ;end select
    SET stat = alterlist(commenttemp->qual,iordercnt)
   ENDIF
   IF (debug_ind=1)
    CALL echo(build("********LoadOrderComments Time = ",datetimediff(cnvtdatetime(sysdate),
       loadordercommentstime,5)))
   ELSE
    FREE RECORD commenttemp
   ENDIF
 END ;Subroutine
 SUBROUTINE loadresponsetaskinfo(null)
   IF (debug_ind=1)
    CALL echo("********LoadResponseTaskInfo********")
   ENDIF
   DECLARE loadresponsetaskinfotime = f8 WITH protect, noconstant(cnvtdatetime(sysdate))
   DECLARE x = i4 WITH protect, noconstant(0)
   DECLARE rcnt = i4 WITH protect, noconstant(0)
   DECLARE oidx = i4 WITH protect, noconstant(0)
   DECLARE nstart = i4 WITH protect, noconstant(1)
   DECLARE nsize = i4 WITH protect, constant(50)
   DECLARE iordercnt = i4 WITH protect, noconstant(size(martemp->responsetaskorders,5))
   DECLARE ntotal = i4 WITH protect, noconstant((ceil((cnvtreal(response_cnt)/ nsize)) * nsize))
   RECORD response_temp(
     1 qual[*]
       2 catalog_cd = f8
       2 reference_task_id = f8
       2 task_description = vc
       2 event_cd = f8
       2 qualification_flag = i2
   )
   SET stat = alterlist(response_temp->qual,response_cnt)
   SET stat = alterlist(martemp->responsetaskorders,ntotal)
   FOR (i = (response_cnt+ 1) TO ntotal)
     SET martemp->responsetaskorders[i].index = martemp->responsetaskorders[response_cnt].index
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
     order_task_xref otxr,
     order_task_response otr,
     order_task ot
    PLAN (d1
     WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ nsize))))
     JOIN (otxr
     WHERE expand(x,nstart,(nstart+ (nsize - 1)),otxr.catalog_cd,reply->orders[martemp->
      responsetaskorders[x].index].catalog_cd))
     JOIN (otr
     WHERE otr.reference_task_id=otxr.reference_task_id)
     JOIN (ot
     WHERE ot.reference_task_id=otr.response_task_id)
    DETAIL
     rcnt += 1
     IF (rcnt > response_cnt)
      stat = alterlist(response_temp->qual,rcnt)
     ENDIF
     response_temp->qual[rcnt].catalog_cd = otxr.catalog_cd, response_temp->qual[rcnt].
     reference_task_id = otr.reference_task_id, response_temp->qual[rcnt].task_description = ot
     .task_description,
     response_temp->qual[rcnt].event_cd = ot.event_cd, response_temp->qual[rcnt].qualification_flag
      = otr.qualification_flag
    WITH nocounter, expand = 2
   ;end select
   SET stat = alterlist(martemp->responsetaskorders,iordercnt)
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = response_cnt),
     (dummyt d2  WITH seq = rcnt)
    PLAN (d1)
     JOIN (d2
     WHERE (reply->orders[martemp->responsetaskorders[d1.seq].index].catalog_cd=response_temp->qual[
     d2.seq].catalog_cd))
    ORDER BY d1.seq
    HEAD d1.seq
     oidx = martemp->responsetaskorders[d1.seq].index, x = 0
    DETAIL
     IF ((((reply->orders[oidx].prn_ind > 0)) OR ((response_temp->qual[d2.seq].qualification_flag=1)
     )) )
      x += 1, stat = alterlist(reply->orders[oidx].response_task_info,x), reply->orders[oidx].
      response_task_info[x].response_task_reference_id = response_temp->qual[d2.seq].
      reference_task_id,
      reply->orders[oidx].response_task_info[x].response_task_description = response_temp->qual[d2
      .seq].task_description, reply->orders[oidx].response_task_info[x].response_event_cd =
      response_temp->qual[d2.seq].event_cd
     ENDIF
    WITH nocounter
   ;end select
   IF (debug_ind=1)
    CALL echo(build("********LoadResponseTaskInfo Time = ",datetimediff(cnvtdatetime(sysdate),
       loadresponsetaskinfotime,5)))
   ELSE
    FREE RECORD response_temp
   ENDIF
 END ;Subroutine
 SUBROUTINE setrenewalindicators(null)
   IF (debug_ind=1)
    CALL echo("********SetRenewalIndicators********")
   ENDIF
   DECLARE setrenewalindicatorstime = f8 WITH protect, noconstant(cnvtdatetime(sysdate))
   DECLARE x = i4 WITH protect, noconstant(0)
   DECLARE catalogcnt = i4 WITH protect, noconstant(0)
   RECORD renewtemp(
     1 qual[*]
       2 catalog_cd = f8
   )
   SET stat = alterlist(renewtemp->qual,order_cnt)
   FOR (x = 1 TO order_cnt)
     IF ((((reply->orders[x].stop_type_cd=hard_stop_cd)) OR ((reply->orders[x].stop_type_cd=
     soft_stop_cd))) )
      SET catalogcnt += 1
      SET renewtemp->qual[catalogcnt].catalog_cd = reply->orders[x].catalog_cd
     ENDIF
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
      IF (rnp.stop_duration > 0
       AND rnp.stop_duration_unit_cd > 0)
       renew_look_back = cnvtint(rnp.notification_period), interval = build(renew_look_back,"h"),
       renew_dt_tm = cnvtlookahead(interval,cnvtdatetime(current_dt_tm))
       FOR (y = 1 TO order_cnt)
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
     WITH nocounter, expand = 2
    ;end select
    SET stat = alterlist(renewtemp->qual,iordercnt)
   ENDIF
   IF (debug_ind=1)
    CALL echo(build("********SetRenewalIndicators Time = ",datetimediff(cnvtdatetime(sysdate),
       setrenewalindicatorstime,5)))
   ELSE
    FREE RECORD renewtemp
   ENDIF
 END ;Subroutine
 SUBROUTINE getcatalogevents(null)
   IF (debug_ind=1)
    CALL echo("********GetCatalogEvents********")
   ENDIF
   DECLARE getcatalogeventscodestime = f8 WITH protect, noconstant(cnvtdatetime(sysdate))
   DECLARE iterator = i4 WITH protect, noconstant(0)
   DECLARE icatevent = i4 WITH protect, noconstant(0)
   DECLARE icatidx = i4 WITH protect, noconstant(0)
   DECLARE icnt = i4 WITH protect, noconstant(0)
   DECLARE idetcnt = i4 WITH protect, noconstant(0)
   DECLARE nstart = i4 WITH protect, noconstant(1)
   DECLARE nsize = i4 WITH protect, constant(50)
   DECLARE iordercnt = i4 WITH protect, noconstant(size(reply->orders,5))
   DECLARE ntotal = i4 WITH protect, noconstant((ceil((cnvtreal(order_cnt)/ nsize)) * nsize))
   SET stat = alterlist(temporderids->order_list,iordercnt)
   SET stat = alterlist(reply->orders,ntotal)
   FOR (i = (order_cnt+ 1) TO ntotal)
     SET reply->orders[i].order_id = reply->orders[order_cnt].order_id
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
     order_ingredient oi
    PLAN (d1
     WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ nsize))))
     JOIN (oi
     WHERE expand(iterator,nstart,(nstart+ (nsize - 1)),oi.order_id,reply->orders[iterator].order_id)
     )
    ORDER BY oi.order_id, oi.catalog_cd
    HEAD REPORT
     itmpordcnt = 0, icnt = 0
     IF (debug_ind=1)
      CALL echo(build("********GetCatalogEvents Query Time = ",datetimediff(cnvtdatetime(sysdate),
        getcatalogeventscodestime,5)))
     ENDIF
    HEAD oi.order_id
     itmpordcnt += 1, temporderids->order_list[itmpordcnt].order_id = oi.order_id, idetcnt = 0
    HEAD oi.catalog_cd
     icatidx = locateval(icatevent,1,size(temporderids->catalog_list,5),oi.catalog_cd,temporderids->
      catalog_list[icatevent].catalog_cd)
     IF (icatidx=0)
      icnt += 1
      IF (mod(icnt,10)=1)
       stat = alterlist(temporderids->catalog_list,(icnt+ 9))
      ENDIF
      temporderids->catalog_list[icnt].catalog_cd = oi.catalog_cd
     ENDIF
     idetcnt += 1
     IF (mod(idetcnt,10)=1)
      stat = alterlist(temporderids->order_list[itmpordcnt].catalog_list,(idetcnt+ 9))
     ENDIF
     temporderids->order_list[itmpordcnt].catalog_list[idetcnt].catalog_cd = oi.catalog_cd
    FOOT  oi.order_id
     stat = alterlist(temporderids->order_list[itmpordcnt].catalog_list,idetcnt)
    FOOT REPORT
     stat = alterlist(temporderids->catalog_list,icnt)
    WITH nocounter, expand = 2
   ;end select
   SET stat = alterlist(reply->orders,iordercnt)
   IF (debug_ind=1)
    CALL echo(build("********GetCatalogEvents Time = ",datetimediff(cnvtdatetime(sysdate),
       getcatalogeventscodestime,5)))
   ENDIF
 END ;Subroutine
 SUBROUTINE loadcatalogeventcodes(null)
   IF (debug_ind=1)
    CALL echo("********LoadCatalogEventCodes********")
   ENDIF
   DECLARE loadcatalogeventcodes = f8 WITH protect, noconstant(cnvtdatetime(sysdate))
   DECLARE icatalogcnt = i4 WITH protect, noconstant(size(temporderids->catalog_list,5))
   DECLARE iexpand = i4 WITH protect, noconstant(0)
   DECLARE icat = i4 WITH protect, noconstant(0)
   DECLARE icatidx = i2 WITH protect, noconstant(0)
   DECLARE iord = i4 WITH protect, noconstant(0)
   DECLARE iordidx = i2 WITH protect, noconstant(0)
   DECLARE ingcnt = i4 WITH protect, noconstant(0)
   DECLARE ordcnt = i4 WITH protect, noconstant(0)
   DECLARE szcatlogcnt = i4 WITH protect, noconstant(0)
   DECLARE loc_orderid = f8 WITH protect, noconstant(0)
   DECLARE ix = i4 WITH protect, noconstant(0)
   DECLARE ingredcount = i4 WITH protect, noconstant(0)
   DECLARE nstart = i4 WITH protect, noconstant(1)
   DECLARE nsize = i4 WITH protect, constant(10)
   DECLARE ntotal = i4 WITH protect, noconstant((ceil((cnvtreal(icatalogcnt)/ nsize)) * nsize))
   SET stat = alterlist(temporderids->catalog_list,ntotal)
   FOR (ix = (icatalogcnt+ 1) TO ntotal)
     SET temporderids->catalog_list[ix].catalog_cd = temporderids->catalog_list[icatalogcnt].
     catalog_cd
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
     code_value_event_r cver
    PLAN (d1
     WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ nsize))))
     JOIN (cver
     WHERE expand(iexpand,nstart,(nstart+ (nsize - 1)),cver.parent_cd,temporderids->catalog_list[
      iexpand].catalog_cd))
    ORDER BY cver.parent_cd
    HEAD REPORT
     IF (debug_ind=1)
      CALL echo(build("********LoadCatalogEventCodes Query Time = ",datetimediff(cnvtdatetime(sysdate
         ),loadcatalogeventcodes,5)))
     ENDIF
    HEAD cver.parent_cd
     FOR (ordcnt = 1 TO size(temporderids->order_list,5))
       szcatlogcnt = 0, szcatlogcnt = size(temporderids->order_list[ordcnt].catalog_list,5),
       loc_orderid = temporderids->order_list[ordcnt].order_id,
       icatidx = locateval(icat,1,szcatlogcnt,cver.parent_cd,temporderids->order_list[ordcnt].
        catalog_list[icat].catalog_cd)
       IF (icatidx > 0)
        iordidx = locateval(iord,1,order_cnt,loc_orderid,reply->orders[iord].order_id)
        IF (iordidx > 0)
         ingredcount = size(reply->orders[iordidx].order_ingredient,5)
         FOR (ingcnt = 1 TO ingredcount)
          IF ((reply->orders[iordidx].catalog_cd=cver.parent_cd))
           reply->orders[iordidx].event_cd = cver.event_cd
          ENDIF
          ,
          IF ((reply->orders[iordidx].order_ingredient[ingcnt].catalog_cd=cver.parent_cd))
           IF ((reply->orders[iordidx].order_ingredient[ingcnt].event_cd=0))
            reply->orders[iordidx].order_ingredient[ingcnt].event_cd = cver.event_cd
           ENDIF
          ENDIF
         ENDFOR
        ENDIF
       ENDIF
     ENDFOR
    WITH nocounter, expand = 2
   ;end select
   IF (debug_ind=1)
    CALL echo(build("********LoadCatalogEventCodes Time = ",datetimediff(cnvtdatetime(sysdate),
       loadcatalogeventcodes,5)))
   ENDIF
 END ;Subroutine
 SUBROUTINE settaperindicator(null)
   IF (debug_ind=1)
    CALL echo("********SetTaperIndicator********")
   ENDIF
   DECLARE settaperindicatortime = f8 WITH protect, noconstant(cnvtdatetime(sysdate))
   DECLARE oidx = i4 WITH protect, noconstant(0)
   DECLARE oit = i4 WITH protect, noconstant(0)
   DECLARE lidx = i4 WITH protect, noconstant(0)
   DECLARE nstart = i4 WITH protect, noconstant(1)
   DECLARE nsize = i4 WITH protect, constant(50)
   DECLARE iordercnt = i4 WITH protect, noconstant(size(reply->orders,5))
   DECLARE ntotal = i4 WITH protect, noconstant((ceil((cnvtreal(order_cnt)/ nsize)) * nsize))
   SET stat = alterlist(reply->orders,ntotal)
   FOR (i = (order_cnt+ 1) TO ntotal)
     SET reply->orders[i].order_id = reply->orders[order_cnt].order_id
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
     act_pw_comp apc,
     pathway pw
    PLAN (d1
     WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ nsize))))
     JOIN (apc
     WHERE expand(lidx,nstart,(nstart+ (nsize - 1)),apc.parent_entity_id,reply->orders[lidx].order_id
      )
      AND apc.parent_entity_name="ORDERS"
      AND apc.active_ind=1)
     JOIN (pw
     WHERE pw.pathway_id=apc.pathway_id)
    ORDER BY apc.parent_entity_id
    HEAD REPORT
     IF (debug_ind=1)
      CALL echo(build("********SetTaperIndicator Query Time = ",datetimediff(cnvtdatetime(sysdate),
        settaperindicatortime,5)))
     ENDIF
    HEAD apc.parent_entity_id
     oidx = locateval(oit,1,order_cnt,apc.parent_entity_id,reply->orders[oit].order_id)
     IF (oidx >= 0)
      IF (trim(pw.type_mean)="TAPERPLAN")
       reply->orders[oidx].taper_ind = 1
      ENDIF
      IF (pw.pathway_type_cd=ivsequence_cd)
       reply->orders[oidx].ivseq_ind = 1
      ENDIF
      reply->orders[oidx].pathway_id = pw.pathway_id, reply->orders[oidx].pathway_desc = pw
      .description
     ENDIF
    WITH nocounter, expand = 2
   ;end select
   SET stat = alterlist(reply->orders,iordercnt)
   CALL printdebug(build("********SetTaperIndicator Time = ",datetimediff(cnvtdatetime(sysdate),
      settaperindicatortime,5)))
 END ;Subroutine
 SUBROUTINE (printdebug(msg=vc) =null)
   IF (debug_ind > 0)
    CALL echo(msg)
   ENDIF
 END ;Subroutine
 SUBROUTINE prepareloadmissingorders(null)
   IF (debug_ind=1)
    CALL echo("********PrepareLoadMissingOrders********")
   ENDIF
   DECLARE setprepareloadmissingorders = f8 WITH protect, noconstant(cnvtdatetime(sysdate))
   DECLARE ordit = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM orders o
    WHERE expand(ordit,1,missing_order_cnt,o.order_id,missingorders->order_list[ordit].order_id)
    HEAD REPORT
     missing_order_cnt = 0
    DETAIL
     missing_order_cnt += 1
     IF (missing_order_cnt > size(missingorders->order_list,5))
      stat = alterlist(missingorders->order_list,(missing_order_cnt+ 19))
     ENDIF
     IF (o.protocol_order_id > 0)
      missingorders->order_list[missing_order_cnt].order_id = o.protocol_order_id, protocol_order_cnt
       += 1
      IF (size(protocolorders->order_list,5) < protocol_order_cnt)
       stat = alterlist(protocolorders->order_list,(protocol_order_cnt+ 9))
      ENDIF
      protocolorders->order_list[protocol_order_cnt].order_id = o.protocol_order_id
     ELSEIF (o.template_order_flag=7)
      missingorders->order_list[missing_order_cnt].order_id = o.order_id, protocol_order_cnt += 1
      IF (size(protocolorders->order_list,5) < protocol_order_cnt)
       stat = alterlist(protocolorders->order_list,(protocol_order_cnt+ 9))
      ENDIF
      protocolorders->order_list[protocol_order_cnt].order_id = o.order_id
     ELSE
      missingorders->order_list[missing_order_cnt].order_id = o.order_id
     ENDIF
    FOOT REPORT
     stat = alterlist(protocolorders->order_list,protocol_order_cnt), stat = alterlist(missingorders
      ->order_list,missing_order_cnt)
    WITH nocounter, expand = 2
   ;end select
   CALL printdebug(build("********PrepareLoadMissingOrders Time = ",datetimediff(cnvtdatetime(sysdate
       ),setprepareloadmissingorders,5)))
 END ;Subroutine
 SUBROUTINE prepareloadtreatmentorders(null)
   IF (debug_ind=1)
    CALL echo("********PrepareLoadTreatmentOrders********")
    CALL echorecord(protocolorders)
   ENDIF
   DECLARE prepareloadtreatmentorders = f8 WITH protect, noconstant(cnvtdatetime(sysdate))
   DECLARE iterator = i4 WITH protect, noconstant(0)
   DECLARE nstart = i4 WITH protect, noconstant(1)
   DECLARE nsize = i4 WITH protect, constant(50)
   DECLARE ntotal = i4 WITH protect, noconstant((ceil((cnvtreal(protocol_order_cnt)/ nsize)) * nsize)
    )
   DECLARE protoit = i4 WITH protect, noconstant(0)
   SET stat = alterlist(protocolorders->order_list,ntotal)
   FOR (i = (protocol_order_cnt+ 1) TO ntotal)
     SET protocolorders->order_list[i].order_id = protocolorders->order_list[protocol_order_cnt].
     order_id
   ENDFOR
   SELECT
    IF (encntr_cnt > 0)
     PLAN (d1
      WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ nsize))))
      JOIN (o
      WHERE expand(protoit,nstart,(nstart+ (nsize - 1)),o.protocol_order_id,protocolorders->
       order_list[protoit].order_id)
       AND expand(iterator,1,encntr_cnt,(o.encntr_id+ 0),request->encntr_list[iterator].encntr_id)
       AND o.template_order_flag IN (0, 1)
       AND ((o.template_order_id+ 0)=0))
    ELSE
     PLAN (d1
      WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ nsize))))
      JOIN (o
      WHERE expand(protoit,nstart,(nstart+ (nsize - 1)),o.protocol_order_id,protocolorders->
       order_list[protoit].order_id)
       AND o.template_order_flag IN (0, 1)
       AND ((o.template_order_id+ 0)=0))
    ENDIF
    INTO "nl:"
    FROM (dummyt d1  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
     orders o
    ORDER BY o.order_id
    HEAD REPORT
     CALL printdebug(build("********PrepareLoadTreatmentOrders Query Time = ",datetimediff(
       cnvtdatetime(sysdate),prepareloadtreatmentorders,5)))
    HEAD o.order_id
     missing_order_cnt += 1
     IF (missing_order_cnt > size(missingorders->order_list,5))
      stat = alterlist(missingorders->order_list,(missing_order_cnt+ 9))
     ENDIF
     missingorders->order_list[missing_order_cnt].order_id = o.order_id
    WITH nocounter, expand = 2
   ;end select
   SET stat = alterlist(missingorders->order_list,missing_order_cnt)
   CALL printdebug(build("********PrepareLoadTreatmentOrders Time = ",datetimediff(cnvtdatetime(
       sysdate),prepareloadtreatmentorders,5)))
 END ;Subroutine
 SUBROUTINE gettemplateordersforprotocol(null)
   IF (debug_ind=1)
    CALL echo("********GetTemplateOrdersForProtocol********")
   ENDIF
   DECLARE settemplateordersforprotocol = f8 WITH protect, noconstant(cnvtdatetime(sysdate))
   DECLARE iterator = i4 WITH protect, noconstant(0)
   DECLARE encntrit = i4 WITH protect, noconstant(0)
   DECLARE ordit = i4 WITH protect, noconstant(0)
   DECLARE locit = i4 WITH protect, noconstant(0)
   DECLARE protoidx = i4 WITH protect, noconstant(0)
   DECLARE temp_cnt = i4 WITH protect, noconstant(0)
   DECLARE nstart = i4 WITH protect, noconstant(1)
   DECLARE nsize = i4 WITH protect, constant(50)
   DECLARE iordercnt = i4 WITH protect, noconstant(size(reply->orders,5))
   DECLARE ntotal = i4 WITH protect, noconstant((ceil((cnvtreal(order_cnt)/ nsize)) * nsize))
   DECLARE dotordcnt = i4 WITH protect, noconstant(0)
   SET stat = alterlist(reply->orders,ntotal)
   FOR (i = (order_cnt+ 1) TO ntotal)
     SET reply->orders[i].order_id = reply->orders[order_cnt].order_id
   ENDFOR
   SELECT
    IF (encntr_cnt > 0)
     PLAN (d1
      WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ nsize))))
      JOIN (o
      WHERE expand(ordit,nstart,(nstart+ (nsize - 1)),o.protocol_order_id,reply->orders[ordit].
       order_id)
       AND expand(iterator,1,encntr_cnt,(o.encntr_id+ 0),request->encntr_list[iterator].encntr_id)
       AND ((o.template_order_id+ 0)=0))
    ELSE
     PLAN (d1
      WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ nsize))))
      JOIN (o
      WHERE expand(ordit,nstart,(nstart+ (nsize - 1)),o.protocol_order_id,reply->orders[ordit].
       order_id)
       AND ((o.template_order_id+ 0)=0))
    ENDIF
    INTO "nl:"
    FROM (dummyt d1  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
     orders o
    ORDER BY o.protocol_order_id, o.order_id
    HEAD REPORT
     proordcount = 0,
     CALL printdebug(build("********GetTemplateOrdersForProtocol Query Time = ",datetimediff(
       cnvtdatetime(sysdate),settemplateordersforprotocol,5)))
    HEAD o.protocol_order_id
     proordcount += 1
     IF (mod(proordcount,10)=1)
      stat = alterlist(protocolanddotorders->dot_ord_list,(proordcount+ 9))
     ENDIF
     protocolanddotorders->dot_ord_list[proordcount].protocol_ord_id = o.protocol_order_id
    HEAD o.order_id
     IF ((((o.person_id=request->person_id)) OR ((request->person_id=0))) )
      protoidx = locateval(locit,1,order_cnt,o.protocol_order_id,reply->orders[locit].order_id)
      IF (protoidx > 0)
       temp_cnt = (size(reply->orders[protoidx].template_order_list,5)+ 1), stat = alterlist(reply->
        orders[protoidx].template_order_list,temp_cnt), reply->orders[protoidx].template_order_list[
       temp_cnt].order_id = o.order_id,
       reply->orders[protoidx].template_order_list[temp_cnt].start_dt_tm = o.current_start_dt_tm,
       reply->orders[protoidx].template_order_list[temp_cnt].order_status_cd = o.order_status_cd,
       reply->orders[protoidx].template_order_list[temp_cnt].encntr_id = o.encntr_id,
       reply->orders[protoidx].template_order_list[temp_cnt].last_action_sequence = o
       .last_action_sequence, reply->orders[protoidx].template_order_list[temp_cnt].
       core_action_sequence = o.last_core_action_sequence
      ENDIF
      protoidx = locateval(locit,1,proordcount,o.protocol_order_id,protocolanddotorders->
       dot_ord_list[locit].protocol_ord_id)
      IF (protoidx > 0)
       dotordcnt = (size(protocolanddotorders->dot_ord_list[protoidx].dots,5)+ 1), stat = alterlist(
        protocolanddotorders->dot_ord_list[protoidx].dots,dotordcnt), protocolanddotorders->
       dot_ord_list[protoidx].dots[dotordcnt].dot_ord_id = o.order_id
      ENDIF
     ENDIF
    FOOT REPORT
     stat = alterlist(protocolanddotorders->dot_ord_list,proordcount)
    WITH nocounter, expand = 2
   ;end select
   SET stat = alterlist(reply->orders,order_cnt)
   CALL printdebug(build("********GetTemplateOrdersForProtocol Time = ",datetimediff(cnvtdatetime(
       sysdate),settemplateordersforprotocol,5)))
 END ;Subroutine
 SUBROUTINE loadorderdetails(null)
   IF (debug_ind=1)
    CALL echo("********LoadOrderDetails********")
   ENDIF
   DECLARE loadorderdetails = f8 WITH protect, noconstant(cnvtdatetime(sysdate))
   DECLARE ordit = i4 WITH protect, noconstant(0)
   DECLARE orderidx = i4 WITH protect, noconstant(0)
   DECLARE detail_cnt = i4 WITH protect, noconstant(0)
   DECLARE locit = i4 WITH protect, noconstant(0)
   DECLARE nstart = i4 WITH protect, noconstant(1)
   DECLARE nsize = i4 WITH protect, constant(50)
   DECLARE ntotal = i4 WITH protect, noconstant((ceil((cnvtreal(order_cnt)/ nsize)) * nsize))
   SET stat = alterlist(reply->orders,ntotal)
   FOR (i = (order_cnt+ 1) TO ntotal)
    SET reply->orders[i].order_id = reply->orders[order_cnt].order_id
    SET reply->orders[i].last_action_sequence = reply->orders[order_cnt].last_action_sequence
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
     order_detail od
    PLAN (d1
     WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ nsize))))
     JOIN (od
     WHERE expand(ordit,nstart,(nstart+ (nsize - 1)),od.order_id,reply->orders[ordit].order_id)
      AND od.detail_sequence > 0)
    ORDER BY od.order_id, od.oe_field_meaning_id, od.action_sequence DESC
    HEAD REPORT
     CALL printdebug(build("********LoadOrderDetails Query Time = ",datetimediff(cnvtdatetime(sysdate
        ),loadorderdetails,5)))
    HEAD od.order_id
     detail_cnt = 0, orderidx = locateval(locit,1,order_cnt,od.order_id,reply->orders[locit].order_id
      )
    HEAD od.oe_field_meaning_id
     IF (orderidx > 0)
      detail_cnt += 1, stat = alterlist(reply->orders[orderidx].order_details,detail_cnt), reply->
      orders[orderidx].order_details[detail_cnt].action_sequence = od.action_sequence,
      reply->orders[orderidx].order_details[detail_cnt].oe_field_display_value = od
      .oe_field_display_value, reply->orders[orderidx].order_details[detail_cnt].oe_field_dt_tm = od
      .oe_field_dt_tm_value, reply->orders[orderidx].order_details[detail_cnt].oe_field_id = od
      .oe_field_id,
      reply->orders[orderidx].order_details[detail_cnt].oe_field_meaning = od.oe_field_meaning, reply
      ->orders[orderidx].order_details[detail_cnt].oe_field_meaning_id = od.oe_field_meaning_id,
      reply->orders[orderidx].order_details[detail_cnt].oe_field_tz = od.oe_field_tz,
      reply->orders[orderidx].order_details[detail_cnt].oe_field_value = od.oe_field_value
     ENDIF
    WITH nocounter, expand = 2
   ;end select
   SET stat = alterlist(reply->orders,order_cnt)
   CALL printdebug(build("********LoadOrderDetails Time = ",datetimediff(cnvtdatetime(sysdate),
      loadorderdetails,5)))
 END ;Subroutine
 SUBROUTINE populateorderreply(null)
   CALL printdebug("********LoadOrderDetails********")
   DECLARE renew_dt_tm = dq8 WITH protect, noconstant(0)
   SET order_cnt += 1
   IF (size(reply->orders,5) < order_cnt)
    SET stat = alterlist(reply->orders,(order_cnt+ 19))
   ENDIF
   SET reply->orders[order_cnt].order_id = o.order_id
   SET reply->orders[order_cnt].encntr_id = o.encntr_id
   SET reply->orders[order_cnt].person_id = o.person_id
   IF ((request->enable_protocol_ind=1))
    SET reply->orders[order_cnt].protocol_order_id = o.protocol_order_id
   ELSE
    SET reply->orders[order_cnt].protocol_order_id = 0.0
   ENDIF
   SET reply->orders[order_cnt].applicable_fields_bit = oiv.applicable_fields_bit
   SET reply->orders[order_cnt].finished_bags_cnt = oiv.finished_bags_cnt
   SET reply->orders[order_cnt].total_bags_nbr = oiv.total_bags_nbr
   SET reply->orders[order_cnt].order_iv_info_updt_cnt = oiv.updt_cnt
   SET reply->orders[order_cnt].order_status_cd = o.order_status_cd
   SET reply->orders[order_cnt].display_line = trim(o.clinical_display_line)
   SET reply->orders[order_cnt].order_mnemonic = o.order_mnemonic
   SET reply->orders[order_cnt].hna_order_mnemonic = o.hna_order_mnemonic
   SET reply->orders[order_cnt].ordered_as_mnemonic = o.ordered_as_mnemonic
   SET reply->orders[order_cnt].catalog_cd = o.catalog_cd
   SET reply->orders[order_cnt].catalog_type_cd = o.catalog_type_cd
   SET reply->orders[order_cnt].activity_type_cd = o.activity_type_cd
   SET reply->orders[order_cnt].comment_type_mask = o.comment_type_mask
   SET reply->orders[order_cnt].constant_ind = o.constant_ind
   SET reply->orders[order_cnt].prn_ind = o.prn_ind
   SET reply->orders[order_cnt].iv_ind = o.iv_ind
   SET reply->orders[order_cnt].need_nurse_review_ind = o.need_nurse_review_ind
   SET reply->orders[order_cnt].med_order_type_cd = o.med_order_type_cd
   SET reply->orders[order_cnt].link_nbr = o.link_nbr
   SET reply->orders[order_cnt].link_type_flag = o.link_type_flag
   SET reply->orders[order_cnt].last_action_sequence = o.last_action_sequence
   SET reply->orders[order_cnt].core_action_sequence = o.last_core_action_sequence
   SET reply->orders[order_cnt].freq_type_flag = o.freq_type_flag
   SET reply->orders[order_cnt].current_start_dt_tm = o.current_start_dt_tm
   SET reply->orders[order_cnt].current_start_tz = o.current_start_tz
   SET reply->orders[order_cnt].projected_stop_dt_tm = o.projected_stop_dt_tm
   SET reply->orders[order_cnt].projected_stop_tz = o.projected_stop_tz
   SET reply->orders[order_cnt].stop_type_cd = o.stop_type_cd
   SET reply->orders[order_cnt].orderable_type_flag = o.orderable_type_flag
   SET reply->orders[order_cnt].template_order_flag = o.template_order_flag
   SET reply->orders[order_cnt].need_rx_verify_ind = o.need_rx_verify_ind
   SET reply->orders[order_cnt].dosing_method_flag = o.dosing_method_flag
   SET reply->orders[order_cnt].warning_level_bit = o.warning_level_bit
   SET reply->orders[order_cnt].updt_dt_tm = o.updt_dt_tm
   IF (o.need_rx_clin_review_flag=clinreviewflag_unset)
    CASE (o.need_rx_verify_ind)
     OF o_verified:
      SET reply->orders[order_cnt].need_rx_clin_review_flag = clinreviewflag_reviewed
     OF o_needs_review:
      SET reply->orders[order_cnt].need_rx_clin_review_flag = clinreviewflag_needs_review
     OF o_rejected:
      SET reply->orders[order_cnt].need_rx_clin_review_flag = clinreviewflag_rejected
    ENDCASE
   ELSE
    SET reply->orders[order_cnt].need_rx_clin_review_flag = o.need_rx_clin_review_flag
   ENDIF
   IF (o.template_order_flag=7
    AND (request->enable_protocol_ind=1))
    SET protocol_found_ind = 1
    SET reply->orders[order_cnt].protocol_order_ind = 1
   ELSE
    SET reply->orders[order_cnt].protocol_order_ind = 0
   ENDIF
   IF (o.pathway_catalog_id > 0)
    SET reply->orders[order_cnt].plan_ind = 1
   ELSE
    SET reply->orders[order_cnt].plan_ind = 0
   ENDIF
   SET reply->orders[order_cnt].taper_ind = 0
   SET reply->orders[order_cnt].ivseq_ind = 0
   IF (o.order_status_cd IN (cancel_cd, completed_cd, deleted_cd, discontinued_cd, trans_cancel_cd,
   voided_wrslt_cd))
    SET reply->orders[order_cnt].need_renew_ind = 0
   ELSE
    SET renew_dt_tm = default_renew_dt_tm
    IF (o.stop_type_cd=hard_stop_cd
     AND o.projected_stop_dt_tm < cnvtdatetime(renew_dt_tm))
     SET reply->orders[order_cnt].need_renew_ind = 2
    ELSEIF (o.stop_type_cd=soft_stop_cd
     AND o.projected_stop_dt_tm < cnvtdatetime(renew_dt_tm))
     SET reply->orders[order_cnt].need_renew_ind = 1
    ELSE
     SET reply->orders[order_cnt].need_renew_ind = 0
    ENDIF
   ENDIF
   IF (o.med_order_type_cd != iv_cd)
    SET response_cnt += 1
    IF (mod(response_cnt,10)=1)
     SET stat = alterlist(martemp->responsetaskorders,(response_cnt+ 9))
    ENDIF
    SET martemp->responsetaskorders[response_cnt].index = order_cnt
   ENDIF
 END ;Subroutine
 SUBROUTINE (populateorderingredientreply(ingcnt=i4(ref)) =null)
   CALL printdebug("********PopulateOrderIngredientReply********")
   SET ingcnt += 1
   IF (mod(ingcnt,5)=1)
    SET stat = alterlist(reply->orders[order_cnt].order_ingredient,(ingcnt+ 4))
   ENDIF
   SET reply->orders[order_cnt].order_ingredient[ingcnt].catalog_cd = oc.catalog_cd
   SET reply->orders[order_cnt].order_ingredient[ingcnt].primary_mnemonic = oc.primary_mnemonic
   SET reply->orders[order_cnt].order_ingredient[ingcnt].ingredient_type_flag = oi
   .ingredient_type_flag
   SET reply->orders[order_cnt].order_ingredient[ingcnt].ref_text_mask = oc.ref_text_mask
   SET reply->orders[order_cnt].order_ingredient[ingcnt].cki = oc.cki
   SET reply->orders[order_cnt].order_ingredient[ingcnt].action_sequence = oi.action_sequence
   SET reply->orders[order_cnt].order_ingredient[ingcnt].comp_sequence = oi.comp_sequence
   SET reply->orders[order_cnt].order_ingredient[ingcnt].synonym_id = oi.synonym_id
   SET reply->orders[order_cnt].order_ingredient[ingcnt].ordered_as_mnemonic = oi.ordered_as_mnemonic
   SET reply->orders[order_cnt].order_ingredient[ingcnt].order_mnemonic = oi.order_mnemonic
   SET reply->orders[order_cnt].order_ingredient[ingcnt].hna_order_mnemonic = oi.hna_order_mnemonic
   SET reply->orders[order_cnt].order_ingredient[ingcnt].strength = oi.strength
   SET reply->orders[order_cnt].order_ingredient[ingcnt].strength_unit = oi.strength_unit
   SET reply->orders[order_cnt].order_ingredient[ingcnt].volume = oi.volume
   SET reply->orders[order_cnt].order_ingredient[ingcnt].volume_unit = oi.volume_unit
   SET reply->orders[order_cnt].order_ingredient[ingcnt].freetext_dose = oi.freetext_dose
   SET reply->orders[order_cnt].order_ingredient[ingcnt].clinically_significant_flag = oi
   .clinically_significant_flag
   SET reply->orders[order_cnt].order_ingredient[ingcnt].ingredient_rate_conversion_ind = ocs
   .ingredient_rate_conversion_ind
   SET reply->orders[order_cnt].order_ingredient[ingcnt].freq_cd = oi.freq_cd
   SET reply->orders[order_cnt].order_ingredient[ingcnt].normalized_rate = oi.normalized_rate
   SET reply->orders[order_cnt].order_ingredient[ingcnt].normalized_rate_unit_cd = oi
   .normalized_rate_unit_cd
   SET reply->orders[order_cnt].order_ingredient[ingcnt].concentration = oi.concentration
   SET reply->orders[order_cnt].order_ingredient[ingcnt].concentration_unit_cd = oi
   .concentration_unit_cd
   SET reply->orders[order_cnt].order_ingredient[ingcnt].last_admin_disp_basis_flag = ocs
   .last_admin_disp_basis_flag
   SET reply->orders[order_cnt].order_ingredient[ingcnt].med_interval_warn_flag = ocs
   .med_interval_warn_flag
   SET reply->orders[order_cnt].order_ingredient[ingcnt].include_in_total_volume_flag = oi
   .include_in_total_volume_flag
   IF (validate(ocs.display_additives_first_ind))
    SET reply->orders[order_cnt].order_ingredient[ingcnt].display_additives_first_ind = ocs
    .display_additives_first_ind
   ENDIF
   IF (oi.action_sequence=max_oi_action_seq)
    SET reply->orders[order_cnt].order_ingredient[ingcnt].active_ind = 1
   ELSE
    SET reply->orders[order_cnt].order_ingredient[ingcnt].active_ind = 0
   ENDIF
 END ;Subroutine
 SUBROUTINE isreschedulable(null)
   CALL printdebug("********IsReschedulable********")
   DECLARE iindex = i4 WITH protect, noconstant(0)
   DECLARE iindexvalue = i4 WITH protect, noconstant(0)
   DECLARE ipos = i4 WITH protect, noconstant(0)
   DECLARE inum = i4 WITH protect, noconstant(0)
   DECLARE totcount = i4 WITH protect, noconstant(0)
   DECLARE task_pending_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",79,"PENDING"))
   FREE RECORD ordertemp
   RECORD ordertemp(
     1 qual[*]
       2 order_id = f8
   )
   SELECT
    IF (encntr_cnt > 0
     AND encntr_cnt <= 100)
     PLAN (ta
      WHERE expand(iindex,1,encntr_cnt,ta.encntr_id,request->encntr_list[iindex].encntr_id)
       AND ta.task_dt_tm BETWEEN cnvtdatetime(sysdate) AND cnvtdatetime("31-DEC-2100 00:00:00.00")
       AND ta.task_status_cd=task_pending_cd)
      JOIN (o
      WHERE o.order_id=ta.order_id
       AND o.order_status_cd=ordered_cd
       AND ta.task_dt_tm=o.current_start_dt_tm)
    ELSE
     PLAN (ta
      WHERE (ta.person_id=request->person_id)
       AND ta.task_dt_tm BETWEEN cnvtdatetime(sysdate) AND cnvtdatetime("31-DEC-2100 00:00:00.00")
       AND ta.task_status_cd=task_pending_cd)
      JOIN (o
      WHERE o.order_id=ta.order_id
       AND o.order_status_cd=ordered_cd
       AND ta.task_dt_tm=o.current_start_dt_tm)
    ENDIF
    INTO "nl:"
    FROM orders o,
     task_activity ta
    HEAD REPORT
     ordercount = 0
    HEAD o.protocol_order_id
     ordercount += 1
     IF (size(ordertemp->qual,5) < ordercount)
      stat = alterlist(ordertemp->qual,(ordercount+ 49))
     ENDIF
     ordertemp->qual[ordercount].order_id = o.protocol_order_id
    HEAD o.template_order_id
     ordercount += 1
     IF (size(ordertemp->qual,5) < ordercount)
      stat = alterlist(ordertemp->qual,(ordercount+ 49))
     ENDIF
     ordertemp->qual[ordercount].order_id = o.template_order_id
    HEAD o.order_id
     IF (o.template_order_id=0)
      ordercount += 1
      IF (size(ordertemp->qual,5) < ordercount)
       stat = alterlist(ordertemp->qual,(ordercount+ 49))
      ENDIF
      ordertemp->qual[ordercount].order_id = o.order_id
     ENDIF
    FOOT REPORT
     stat = alterlist(ordertemp->qual,ordercount)
    WITH nocounter, expand = 2
   ;end select
   FOR (iindexvalue = 1 TO size(reply->orders,5))
    SET ipos = locateval(inum,1,ordercount,reply->orders[iindexvalue].order_id,ordertemp->qual[inum].
     order_id)
    IF (ipos > 0)
     SET reply->orders[iindexvalue].reschedule_ind = 1
    ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE loaddotorderforprotocol(null)
   IF (debug_ind=1)
    CALL echo("********Entering  - LoadDotOrderForProtocol********")
   ENDIF
   DECLARE dotcnt = i4 WITH protect, noconstant(0)
   DECLARE proordit = i4 WITH protect, noconstant(0)
   DECLARE proordidx = i4 WITH protect, noconstant(0)
   DECLARE proordid = f8 WITH protect, noconstant(0)
   DECLARE dorordid = f8 WITH protect, noconstant(0)
   DECLARE sizeprodotordlist = i4 WITH protect, noconstant(size(protocolanddotorders->dot_ord_list,5)
    )
   IF (sizeprodotordlist > 0)
    FOR (x = 1 TO size(protocolanddotorders->dot_ord_list,5))
     SET proordid = protocolanddotorders->dot_ord_list[x].protocol_ord_id
     FOR (y = 1 TO size(protocolanddotorders->dot_ord_list[x].dots,5))
      SET dorordid = protocolanddotorders->dot_ord_list[x].dots[y].dot_ord_id
      IF (dorordid > 0)
       SET dotcnt += 1
       SET stat = alterlist(dotorders->dot_ord_list,dotcnt)
       SET dotorders->dot_ord_list[dotcnt].protocol_ord_id = proordid
       SET dotorders->dot_ord_list[dotcnt].dot_ord_id = dorordid
      ENDIF
     ENDFOR
    ENDFOR
    CALL loadtreatmentdescfordotorders(0)
   ENDIF
   IF (debug_ind=1)
    CALL echo("********Leaving - LoadDotOrderForProtocol********")
   ENDIF
 END ;Subroutine
 SUBROUTINE loadtreatmentdescfordotorders(null)
   IF (debug_ind=1)
    CALL echo("********Entering - LoadTreatmentDescForDotOrders********")
   ENDIF
   DECLARE dotidx = i4 WITH protect, noconstant(0)
   DECLARE dotpos = i4 WITH protect, noconstant(0)
   DECLARE proidx = i4 WITH protect, noconstant(0)
   DECLARE propos = i4 WITH protect, noconstant(0)
   DECLARE pordid = f8 WITH protect, noconstant(0)
   DECLARE prolistsize = i4 WITH protect, noconstant(0)
   DECLARE dotlistsize = i4 WITH protect, noconstant(0)
   DECLARE dotordlistsize = i4 WITH protect, noconstant(size(dotorders->dot_ord_list,5))
   IF (dotordlistsize > 0)
    SELECT INTO "nl:"
     FROM act_pw_comp apc,
      pathway pw
     PLAN (apc
      WHERE expand(dotidx,1,dotordlistsize,apc.parent_entity_id,dotorders->dot_ord_list[dotidx].
       dot_ord_id)
       AND apc.parent_entity_name="ORDERS")
      JOIN (pw
      WHERE pw.pathway_id=apc.pathway_id)
     HEAD apc.parent_entity_id
      dotpos = locateval(dotidx,1,dotordlistsize,apc.parent_entity_id,dotorders->dot_ord_list[dotidx]
       .dot_ord_id)
      IF (dotpos > 0)
       pordid = dotorders->dot_ord_list[dotpos].protocol_ord_id, prolistsize = size(
        protocolanddotorders->dot_ord_list,5), propos = locateval(proidx,1,prolistsize,pordid,
        protocolanddotorders->dot_ord_list[proidx].protocol_ord_id)
       IF (propos > 0)
        dotlistsize = size(protocolanddotorders->dot_ord_list[propos].dots,5), dotpos = locateval(
         dotidx,1,dotlistsize,apc.parent_entity_id,protocolanddotorders->dot_ord_list[propos].dots[
         dotidx].dot_ord_id)
        IF (dotpos > 0)
         protocolanddotorders->dot_ord_list[propos].dots[dotidx].uncorrupted_dots = 1,
         protocolanddotorders->dot_ord_list[propos].dots[dotidx].end_dt_tm = pw.calc_end_dt_tm,
         protocolanddotorders->dot_ord_list[propos].dots[dotidx].treat_period_desc = pw.description
        ENDIF
       ENDIF
      ENDIF
     WITH nocounter, expand = 2
    ;end select
   ENDIF
   IF (debug_ind=1)
    CALL echo("********Leaving - LoadTreatmentDescForDotOrders********")
   ENDIF
 END ;Subroutine
 SUBROUTINE populatereplyfordotorder(null)
   IF (debug_ind=1)
    CALL echo("********Entering - PopulateReplyForDotOrder********")
   ENDIF
   DECLARE protoid = f8 WITH protect, noconstant(0)
   DECLARE propos = i4 WITH protect, noconstant(0)
   DECLARE proidx = i4 WITH protect, noconstant(0)
   DECLARE dorordid = f8 WITH protect, noconstant(0)
   DECLARE dotpos = i4 WITH protect, noconstant(0)
   DECLARE dotidx = i4 WITH protect, noconstant(0)
   DECLARE sizereplydot = i4 WITH protect, noconstant(0)
   DECLARE sizereplypro = i4 WITH protect, noconstant(0)
   DECLARE sizeproordlist = i4 WITH protect, noconstant(size(protocolanddotorders->dot_ord_list,5))
   IF (sizeproordlist > 0)
    CALL updateuncorrupteddotorderscount(0)
    FOR (x = 1 TO size(protocolanddotorders->dot_ord_list,5))
      SET protoid = protocolanddotorders->dot_ord_list[x].protocol_ord_id
      SET sizereplypro = size(reply->orders,5)
      SET propos = locateval(proidx,1,sizereplypro,protoid,reply->orders[proidx].order_id)
      IF (propos > 0)
       FOR (y = 1 TO size(protocolanddotorders->dot_ord_list[x].dots,5))
         SET dorordid = protocolanddotorders->dot_ord_list[x].dots[y].dot_ord_id
         SET sizereplydot = size(reply->orders[propos].template_order_list,5)
         SET dotpos = locateval(dotidx,1,sizereplydot,dorordid,reply->orders[propos].
          template_order_list[dotidx].order_id)
         IF (dotpos > 0)
          IF ((sizereplydot=protocolanddotorders->dot_ord_list[x].uncorrupted_dot_cnt))
           SET reply->orders[propos].template_order_list[dotpos].corrupted_dot_found = 0
           SET reply->orders[propos].template_order_list[dotpos].end_dt_tm = protocolanddotorders->
           dot_ord_list[x].dots[y].end_dt_tm
           SET reply->orders[propos].template_order_list[dotpos].treatment_period_description =
           protocolanddotorders->dot_ord_list[x].dots[y].treat_period_desc
          ELSE
           SET reply->orders[propos].corrupt_protocol_ord_ind = 1
           IF ((protocolanddotorders->dot_ord_list[x].dots[y].uncorrupted_dots=1))
            SET reply->orders[propos].template_order_list[dotpos].end_dt_tm = protocolanddotorders->
            dot_ord_list[x].dots[y].end_dt_tm
            SET reply->orders[propos].template_order_list[dotpos].treatment_period_description =
            protocolanddotorders->dot_ord_list[x].dots[y].treat_period_desc
            SET reply->orders[propos].template_order_list[dotpos].corrupted_dot_found = 1
           ELSE
            SET reply->orders[propos].template_order_list[dotpos].corrupted_dot_found = 2
           ENDIF
          ENDIF
         ENDIF
       ENDFOR
      ENDIF
    ENDFOR
   ENDIF
   IF (debug_ind=1)
    CALL echo("********Leaving - PopulateReplyForDotOrder********")
   ENDIF
 END ;Subroutine
 SUBROUTINE updateuncorrupteddotorderscount(null)
   IF (debug_ind=1)
    CALL echo("********Entering - UpdateUnCorruptedDotOrdersCount********")
   ENDIF
   DECLARE uncorrputdotordcnt = i4 WITH protect, noconstant(0)
   DECLARE dotcnt = i4 WITH protect, noconstant(0)
   DECLARE dorordid = f8 WITH protect, noconstant(0)
   FOR (x = 1 TO size(protocolanddotorders->dot_ord_list,5))
     SET dotcnt = 0
     FOR (y = 1 TO size(protocolanddotorders->dot_ord_list[x].dots,5))
       SET dorordid = protocolanddotorders->dot_ord_list[x].dots[y].dot_ord_id
       SET uncorrputdotordcnt = protocolanddotorders->dot_ord_list[x].dots[y].uncorrupted_dots
       IF (uncorrputdotordcnt=1)
        SET dotcnt += 1
       ENDIF
     ENDFOR
     SET protocolanddotorders->dot_ord_list[x].uncorrupted_dot_cnt = dotcnt
   ENDFOR
   IF (debug_ind=1)
    CALL echo("********Leaving - UpdateUnCorruptedDotOrdersCount********")
   ENDIF
 END ;Subroutine
 IF (debug_ind=1)
  CALL echorecord(reply)
 ENDIF
 SET last_mod = "019 01/06/20"
 SET modify = nopredeclare
END GO
