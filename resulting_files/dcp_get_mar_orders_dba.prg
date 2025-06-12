CREATE PROGRAM dcp_get_mar_orders:dba
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
     2 ivseq_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET martemp
 RECORD martemp(
   1 responsetaskorders[*]
     2 index = i4
 )
 FREE RECORD sac_def_pos_req
 RECORD sac_def_pos_req(
   1 personnel_id = f8
 )
 FREE RECORD sac_def_pos_list_req
 RECORD sac_def_pos_list_req(
   1 personnels[*]
     2 personnel_id = f8
 )
 FREE RECORD sac_def_pos_rep
 RECORD sac_def_pos_rep(
   1 position_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD sac_def_pos_list_rep
 RECORD sac_def_pos_list_rep(
   1 personnels[*]
     2 personnel_id = f8
     2 personnel_found = i2
     2 position_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD sac_cur_pos_rep
 RECORD sac_cur_pos_rep(
   1 position_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE getdefaultposition(null) = i2
 DECLARE getmultipledefaultpositions(null) = i2
 DECLARE getcurrentposition(null) = i2
 EXECUTE sacrtl
 SUBROUTINE getdefaultposition(null)
   DECLARE stat = i2 WITH protect
   SET stat = initrec(sac_def_pos_rep)
   SET sac_def_pos_rep->status_data.subeventstatus[1].operationname = "GetDefaultPosition"
   SET sac_def_pos_rep->status_data.subeventstatus[1].targetobjectname = "POSITION_CD"
   SELECT INTO "nl:"
    p.position_cd
    FROM prsnl p
    WHERE (p.person_id=sac_def_pos_req->personnel_id)
    DETAIL
     sac_def_pos_rep->position_cd = p.position_cd
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET sac_def_pos_rep->status_data.status = "Z"
    SET sac_def_pos_rep->status_data.subeventstatus[1].operationstatus = "Z"
    SET sac_def_pos_rep->status_data.subeventstatus[1].targetobjectvalue = build2("Personnel ID of ",
     cnvtstring(sac_def_pos_req->personnel_id,17)," does not exist.")
    RETURN(0)
   ENDIF
   IF ((sac_def_pos_rep->position_cd < 0))
    SET sac_def_pos_rep->status_data.status = "F"
    SET sac_def_pos_rep->status_data.subeventstatus[1].operationstatus = "F"
    SET sac_def_pos_rep->status_data.subeventstatus[1].targetobjectvalue = build2(
     "Invalid POSITION_CD of ",cnvtstring(sac_def_pos_rep->position_cd,17),". Value is less than 0.")
    RETURN(0)
   ENDIF
   SET sac_def_pos_rep->status_data.status = "S"
   SET sac_def_pos_rep->status_data.subeventstatus[1].operationstatus = "S"
   RETURN(1)
 END ;Subroutine
 SUBROUTINE getmultipledefaultpositions(null)
   DECLARE stat = i2 WITH protect
   SET stat = initrec(sac_def_pos_list_rep)
   SET sac_def_pos_list_rep->status_data.subeventstatus[1].operationname =
   "GetMultipleDefaultPositions"
   SET sac_def_pos_list_rep->status_data.subeventstatus[1].targetobjectname = "POSITION_CD"
   DECLARE prsnl_list_size = i4 WITH protect
   SET prsnl_list_size = size(sac_def_pos_list_req->personnels,5)
   IF (prsnl_list_size=0)
    SET sac_def_pos_list_rep->status_data.status = "F"
    SET sac_def_pos_list_rep->status_data.subeventstatus[1].operationstatus = "F"
    SET sac_def_pos_list_rep->status_data.subeventstatus[1].targetobjectvalue = build2(
     "No personnel IDs set in request list of size ",cnvtstring(prsnl_list_size))
    RETURN(0)
   ENDIF
   SET stat = alterlist(sac_def_pos_list_rep->personnels,prsnl_list_size)
   FOR (x = 1 TO prsnl_list_size)
     SET sac_def_pos_list_rep->personnels[x].personnel_id = sac_def_pos_list_req->personnels[x].
     personnel_id
     SET sac_def_pos_list_rep->personnels[x].personnel_found = 0
     SET sac_def_pos_list_rep->personnels[x].position_cd = - (1)
   ENDFOR
   DECLARE prsnl_idx = i4 WITH protect
   DECLARE expand_idx = i4 WITH protect
   DECLARE actual_idx = i4 WITH protect
   SELECT INTO "nl:"
    p.position_cd
    FROM prsnl p
    WHERE expand(prsnl_idx,1,prsnl_list_size,p.person_id,sac_def_pos_list_req->personnels[prsnl_idx].
     personnel_id)
    DETAIL
     actual_idx = locateval(expand_idx,1,prsnl_list_size,p.person_id,sac_def_pos_list_rep->
      personnels[expand_idx].personnel_id), sac_def_pos_list_rep->personnels[actual_idx].
     personnel_found = 1, sac_def_pos_list_rep->personnels[actual_idx].position_cd = p.position_cd
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET sac_def_pos_list_rep->status_data.status = "Z"
    SET sac_def_pos_list_rep->status_data.subeventstatus[1].operationstatus = "Z"
    SET sac_def_pos_list_rep->status_data.subeventstatus[1].targetobjectvalue = build2(
     "No personnels found in request list of size ",cnvtstring(prsnl_list_size))
    RETURN(0)
   ENDIF
   SET sac_def_pos_list_rep->status_data.status = "S"
   SET sac_def_pos_list_rep->status_data.subeventstatus[1].operationstatus = "S"
   RETURN(1)
 END ;Subroutine
 SUBROUTINE getcurrentposition(null)
   DECLARE stat = i2 WITH protect
   SET stat = initrec(sac_cur_pos_rep)
   SET sac_cur_pos_rep->status_data.subeventstatus[1].operationname = "GetCurrentPosition"
   SET sac_cur_pos_rep->status_data.subeventstatus[1].targetobjectname = "POSITION_CD"
   SET sac_cur_pos_rep->status_data.status = "F"
   SET sac_cur_pos_rep->status_data.subeventstatus[1].operationstatus = "F"
   DECLARE hpositionhandle = i4 WITH protect, noconstant(0)
   DECLARE clearhandle = i4 WITH protect, noconstant(0)
   SET hpositionhandle = uar_sacgetcurrentpositions()
   IF (hpositionhandle=0)
    CALL echo("Get Position failed: Unable to get the position handle.")
    SET sac_cur_pos_rep->status_data.subeventstatus[1].targetobjectvalue =
    "Get Current Position Failed: Unable to get the position handle."
    SET clearhandle = uar_sacclosehandle(hpositionhandle)
    RETURN(0)
   ENDIF
   DECLARE positioncnt = i4 WITH protect, noconstant(0)
   SET positioncnt = uar_srvgetitemcount(hpositionhandle,nullterm("Positions"))
   IF (positioncnt != 1)
    CALL echo("Get Position failed: Position count was not exactly 1.")
    SET sac_cur_pos_rep->status_data.subeventstatus[1].targetobjectvalue = build2(
     "Get Current Position Failed: ",cnvtstring(positioncnt,1)," positions returned.")
    SET clearhandle = uar_sacclosehandle(hpositionhandle)
    RETURN(0)
   ENDIF
   DECLARE hpositionlisthandle = i4 WITH protect, noconstant(0)
   SET hpositionlisthandle = uar_srvgetitem(hpositionhandle,nullterm("Positions"),0)
   IF (hpositionlisthandle=0)
    CALL echo("Get Position item failed: Unable to retrieve current position.")
    SET sac_cur_pos_rep->status_data.subeventstatus[1].targetobjectvalue =
    "Get Current Position Failed: Unable to retrieve current position."
    SET clearhandle = uar_sacclosehandle(hpositionlisthandle)
    SET clearhandle = uar_sacclosehandle(hpositionhandle)
    RETURN(0)
   ENDIF
   SET sac_cur_pos_rep->position_cd = uar_srvgetdouble(hpositionlisthandle,nullterm("PositionCode"))
   SET sac_cur_pos_rep->status_data.status = "S"
   SET sac_cur_pos_rep->status_data.subeventstatus[1].operationstatus = "S"
   SET clearhandle = uar_sacclosehandle(hpositionlisthandle)
   SET clearhandle = uar_sacclosehandle(hpositionhandle)
   RETURN(1)
 END ;Subroutine
 DECLARE initialize(null) = null
 DECLARE loadorders(null) = null
 DECLARE loadmissingorders(null) = null
 DECLARE loadorderactions(null) = null
 DECLARE loadordercomments(null) = null
 DECLARE loadresponsetaskinfo(null) = null
 DECLARE setrenewalindicators(null) = null
 DECLARE loadcatalogeventcodes(null) = null
 DECLARE loaddtas(null) = null
 DECLARE settaperindicator(null) = null
 DECLARE totaltime = f8 WITH noconstant(cnvtdatetime(sysdate))
 DECLARE last_mod = c12 WITH private, noconstant(fillstring(12," "))
 DECLARE order_cnt = i4 WITH noconstant(0)
 DECLARE missing_order_cnt = i4 WITH noconstant(0)
 DECLARE encntr_cnt = i4 WITH noconstant(0)
 DECLARE response_cnt = i4 WITH noconstant(0)
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE debug_ind = i2 WITH protect, noconstant(0)
 DECLARE search_from_dt_tm = q8
 DECLARE current_dt_tm = q8
 DECLARE renew_look_back = i4 WITH noconstant(24)
 DECLARE default_renew_look_back = i4 WITH noconstant(24)
 DECLARE default_renew_dt_tm = q8
 DECLARE interval = vc
 DECLARE error_msg = vc WITH protect, noconstant("")
 DECLARE error_cd = i2 WITH protect, noconstant(0)
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
 CALL initialize(null)
 IF (missing_order_cnt > 0)
  CALL loadmissingorders(null)
 ELSE
  CALL loadorders(null)
 ENDIF
 IF (order_cnt > 0)
  CALL loadorderactions(null)
  CALL setrenewalindicators(null)
  CALL loadcatalogeventcodes(null)
  CALL loaddtas(null)
  CALL loadordercomments(null)
  IF (response_cnt > 0)
   CALL loadresponsetaskinfo(null)
  ENDIF
  CALL settaperindicator(null)
 ENDIF
 IF (debug_ind=1)
  CALL echo("*********************************")
  CALL echo(build("Total Time = ",datetimediff(cnvtdatetime(sysdate),totaltime,5)))
  CALL echo("*********************************")
 ELSE
  FREE RECORD martemp
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
   CALL echo("********Initialize********")
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
      AND rnp.stop_duration=0
      AND rnp.stop_duration_unit_cd=0)
    DETAIL
     default_renew_look_back = cnvtint(rnp.notification_period)
    WITH nocounter
   ;end select
   SET interval = build(default_renew_look_back,"h")
   SET default_renew_dt_tm = cnvtlookahead(interval,cnvtdatetime(current_dt_tm))
   IF (debug_ind=1)
    CALL echo(build("********Initialize Time = ",datetimediff(cnvtdatetime(sysdate),initializetime,5)
      ))
   ENDIF
 END ;Subroutine
 SUBROUTINE loadorders(null)
   CALL echo("********LoadOrders********")
   DECLARE loadordertime = f8 WITH protect, noconstant(cnvtdatetime(sysdate))
   DECLARE iterator = i4 WITH protect, noconstant(0)
   DECLARE encntr_in_clause = vc WITH protect, noconstant(fillstring(100," "))
   IF (encntr_cnt > 0)
    SET encntr_in_clause =
    "expand (iterator, 1, encntr_cnt, o.encntr_id+0, request->encntr_list[iterator].encntr_id)"
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
      AND ((o.catalog_type_cd+ 0)=pharmacy_cd)
      AND ((o.template_order_id+ 0)=0)
      AND o.template_order_flag IN (0, 1)
      AND ((o.orderable_type_flag+ 0) IN (0, 1, 8, 10, 11))
      AND parser(encntr_in_clause)
      AND ((o.orig_ord_as_flag+ 0) IN (0, 5))
      AND ((o.order_status_cd IN (future_cd, incomplete_cd, inprocess_cd, medstudent_cd, ordered_cd,
     pending_cd, pending_rev_cd, suspended_cd, unscheduled_cd)) OR (o.order_status_cd IN (cancel_cd,
     completed_cd, deleted_cd, discontinued_cd, trans_cancel_cd,
     voided_wrslt_cd)
      AND ((o.projected_stop_dt_tm+ 0) >= cnvtdatetime(search_from_dt_tm))
      AND ((o.current_start_dt_tm+ 0) <= cnvtdatetime(request->end_dt_tm)))) )
     JOIN (oi
     WHERE oi.order_id=o.order_id)
     JOIN (oc
     WHERE oc.catalog_cd=oi.catalog_cd)
     JOIN (ocs
     WHERE ocs.synonym_id=oi.synonym_id)
    ORDER BY o.order_id, oi.action_sequence DESC, oi.comp_sequence
    HEAD REPORT
     IF (debug_ind=1)
      CALL echo(build("********LoadOrders Query Time = ",datetimediff(cnvtdatetime(sysdate),
        loadordertime,5)))
     ENDIF
     order_cnt = 0
    HEAD o.order_id
     max_oi_action_seq = oi.action_sequence, ingcnt = 0, addorder = 0
     IF (o.order_status_cd IN (cancel_cd, completed_cd, deleted_cd, discontinued_cd, trans_cancel_cd,
     voided_wrslt_cd))
      IF (((o.projected_stop_dt_tm=null) OR (((o.projected_stop_dt_tm >= cnvtdatetime(request->
       start_dt_tm)) OR (o.stop_type_cd=soft_stop_cd)) )) )
       addorder = 1
      ENDIF
     ELSE
      addorder = 1
     ENDIF
     IF (addorder=1)
      order_cnt += 1
      IF (mod(order_cnt,20)=1)
       stat = alterlist(reply->orders,(order_cnt+ 19))
      ENDIF
      reply->orders[order_cnt].order_id = o.order_id, reply->orders[order_cnt].encntr_id = o
      .encntr_id, reply->orders[order_cnt].person_id = o.person_id,
      reply->orders[order_cnt].order_status_cd = o.order_status_cd, reply->orders[order_cnt].
      display_line = trim(o.clinical_display_line), reply->orders[order_cnt].order_mnemonic = o
      .order_mnemonic,
      reply->orders[order_cnt].hna_order_mnemonic = o.hna_order_mnemonic, reply->orders[order_cnt].
      ordered_as_mnemonic = o.ordered_as_mnemonic, reply->orders[order_cnt].catalog_cd = o.catalog_cd,
      reply->orders[order_cnt].catalog_type_cd = o.catalog_type_cd, reply->orders[order_cnt].
      activity_type_cd = o.activity_type_cd, reply->orders[order_cnt].comment_type_mask = o
      .comment_type_mask,
      reply->orders[order_cnt].constant_ind = o.constant_ind, reply->orders[order_cnt].prn_ind = o
      .prn_ind, reply->orders[order_cnt].iv_ind = o.iv_ind,
      reply->orders[order_cnt].need_nurse_review_ind = o.need_nurse_review_ind, reply->orders[
      order_cnt].med_order_type_cd = o.med_order_type_cd, reply->orders[order_cnt].link_nbr = o
      .link_nbr,
      reply->orders[order_cnt].link_type_flag = o.link_type_flag, reply->orders[order_cnt].
      last_action_sequence = o.last_action_sequence, reply->orders[order_cnt].core_action_sequence =
      o.template_core_action_sequence,
      reply->orders[order_cnt].freq_type_flag = o.freq_type_flag, reply->orders[order_cnt].
      current_start_dt_tm = o.current_start_dt_tm, reply->orders[order_cnt].current_start_tz = o
      .current_start_tz,
      reply->orders[order_cnt].projected_stop_dt_tm = o.projected_stop_dt_tm, reply->orders[order_cnt
      ].projected_stop_tz = o.projected_stop_tz, reply->orders[order_cnt].stop_type_cd = o
      .stop_type_cd,
      reply->orders[order_cnt].orderable_type_flag = o.orderable_type_flag, reply->orders[order_cnt].
      template_order_flag = o.template_order_flag
      IF (o.pathway_catalog_id > 0)
       reply->orders[order_cnt].plan_ind = 1
      ELSE
       reply->orders[order_cnt].plan_ind = 0
      ENDIF
      reply->orders[order_cnt].taper_ind = 0, reply->orders[order_cnt].ivseq_ind = 0
      IF (o.order_status_cd IN (cancel_cd, completed_cd, deleted_cd, discontinued_cd, trans_cancel_cd,
      voided_wrslt_cd))
       reply->orders[order_cnt].need_renew_ind = 0
      ELSE
       renew_dt_tm = default_renew_dt_tm
       IF (o.stop_type_cd=hard_stop_cd
        AND o.projected_stop_dt_tm < cnvtdatetime(renew_dt_tm))
        reply->orders[order_cnt].need_renew_ind = 2
       ELSEIF (o.stop_type_cd=soft_stop_cd
        AND o.projected_stop_dt_tm < cnvtdatetime(renew_dt_tm))
        reply->orders[order_cnt].need_renew_ind = 1
       ELSE
        reply->orders[order_cnt].need_renew_ind = 0
       ENDIF
      ENDIF
      IF (o.med_order_type_cd != iv_cd)
       response_cnt += 1
       IF (mod(response_cnt,10)=1)
        stat = alterlist(martemp->responsetaskorders,(response_cnt+ 9))
       ENDIF
       martemp->responsetaskorders[response_cnt].index = order_cnt
      ENDIF
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
       ingcnt += 1
       IF (mod(ingcnt,5)=1)
        stat = alterlist(reply->orders[order_cnt].order_ingredient,(ingcnt+ 4))
       ENDIF
       reply->orders[order_cnt].order_ingredient[ingcnt].catalog_cd = oc.catalog_cd, reply->orders[
       order_cnt].order_ingredient[ingcnt].primary_mnemonic = oc.primary_mnemonic, reply->orders[
       order_cnt].order_ingredient[ingcnt].ingredient_type_flag = oi.ingredient_type_flag,
       reply->orders[order_cnt].order_ingredient[ingcnt].ref_text_mask = oc.ref_text_mask, reply->
       orders[order_cnt].order_ingredient[ingcnt].cki = oc.cki, reply->orders[order_cnt].
       order_ingredient[ingcnt].action_sequence = oi.action_sequence,
       reply->orders[order_cnt].order_ingredient[ingcnt].comp_sequence = oi.comp_sequence, reply->
       orders[order_cnt].order_ingredient[ingcnt].synonym_id = oi.synonym_id, reply->orders[order_cnt
       ].order_ingredient[ingcnt].ordered_as_mnemonic = oi.ordered_as_mnemonic,
       reply->orders[order_cnt].order_ingredient[ingcnt].order_mnemonic = oi.order_mnemonic, reply->
       orders[order_cnt].order_ingredient[ingcnt].hna_order_mnemonic = oi.hna_order_mnemonic, reply->
       orders[order_cnt].order_ingredient[ingcnt].strength = oi.strength,
       reply->orders[order_cnt].order_ingredient[ingcnt].strength_unit = oi.strength_unit, reply->
       orders[order_cnt].order_ingredient[ingcnt].volume = oi.volume, reply->orders[order_cnt].
       order_ingredient[ingcnt].volume_unit = oi.volume_unit,
       reply->orders[order_cnt].order_ingredient[ingcnt].freetext_dose = oi.freetext_dose, reply->
       orders[order_cnt].order_ingredient[ingcnt].clinically_significant_flag = oi
       .clinically_significant_flag, reply->orders[order_cnt].order_ingredient[ingcnt].
       ingredient_rate_conversion_ind = ocs.ingredient_rate_conversion_ind,
       reply->orders[order_cnt].order_ingredient[ingcnt].freq_cd = oi.freq_cd, reply->orders[
       order_cnt].order_ingredient[ingcnt].normalized_rate = oi.normalized_rate, reply->orders[
       order_cnt].order_ingredient[ingcnt].normalized_rate_unit_cd = oi.normalized_rate_unit_cd,
       reply->orders[order_cnt].order_ingredient[ingcnt].concentration = oi.concentration, reply->
       orders[order_cnt].order_ingredient[ingcnt].concentration_unit_cd = oi.concentration_unit_cd,
       reply->orders[order_cnt].order_ingredient[ingcnt].last_admin_disp_basis_flag = ocs
       .last_admin_disp_basis_flag,
       reply->orders[order_cnt].order_ingredient[ingcnt].med_interval_warn_flag = ocs
       .med_interval_warn_flag
       IF (validate(ocs.display_additives_first_ind))
        reply->orders[order_cnt].order_ingredient[ingcnt].display_additives_first_ind = ocs
        .display_additives_first_ind
       ENDIF
       IF (oi.action_sequence=max_oi_action_seq)
        reply->orders[order_cnt].order_ingredient[ingcnt].active_ind = 1
       ELSE
        reply->orders[order_cnt].order_ingredient[ingcnt].active_ind = 0
       ENDIF
      ENDIF
     ENDIF
    FOOT  o.order_id
     IF (addorder=1)
      stat = alterlist(reply->orders[order_cnt].order_ingredient,ingcnt)
     ENDIF
    FOOT REPORT
     stat = alterlist(reply->orders,order_cnt)
    WITH nocounter, orahint("index (o XIE18ORDERS)")
   ;end select
   IF (debug_ind=1)
    CALL echo(build("********LoadOrders Time = ",datetimediff(cnvtdatetime(sysdate),loadordertime,5))
     )
    CALL echo(build("********order_cnt = ",order_cnt))
   ENDIF
 END ;Subroutine
 SUBROUTINE loadmissingorders(null)
   CALL echo("********LoadMissingOrders********")
   DECLARE loadmissingordertime = f8 WITH protect, noconstant(cnvtdatetime(sysdate))
   DECLARE iterator = i4 WITH protect, noconstant(0)
   DECLARE nstart = i4 WITH protect, noconstant(1)
   DECLARE nsize = i4 WITH protect, constant(50)
   DECLARE iordercnt = i4 WITH protect, noconstant(size(request->order_list,5))
   DECLARE ntotal = i4 WITH protect, noconstant((ceil((cnvtreal(missing_order_cnt)/ nsize)) * nsize))
   SET stat = alterlist(request->order_list,ntotal)
   FOR (i = (missing_order_cnt+ 1) TO ntotal)
     SET request->order_list[i].order_id = request->order_list[missing_order_cnt].order_id
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
     orders o,
     order_ingredient oi,
     order_catalog oc,
     order_catalog_synonym ocs
    PLAN (d1
     WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ nsize))))
     JOIN (o
     WHERE expand(iterator,nstart,(nstart+ (nsize - 1)),o.order_id,request->order_list[iterator].
      order_id))
     JOIN (oi
     WHERE oi.order_id=o.order_id)
     JOIN (oc
     WHERE oc.catalog_cd=oi.catalog_cd)
     JOIN (ocs
     WHERE ocs.synonym_id=oi.synonym_id)
    ORDER BY o.order_id, oi.action_sequence DESC, oi.comp_sequence
    HEAD REPORT
     IF (debug_ind=1)
      CALL echo(build("********LoadMissingOrders Query Time = ",datetimediff(cnvtdatetime(sysdate),
        loadmissingordertime,5)))
     ENDIF
     order_cnt = 0
    HEAD o.order_id
     max_oi_action_seq = oi.action_sequence, ingcnt = 0, order_cnt += 1
     IF (mod(order_cnt,20)=1)
      stat = alterlist(reply->orders,(order_cnt+ 19))
     ENDIF
     reply->orders[order_cnt].order_id = o.order_id, reply->orders[order_cnt].encntr_id = o.encntr_id,
     reply->orders[order_cnt].person_id = o.person_id,
     reply->orders[order_cnt].order_status_cd = o.order_status_cd, reply->orders[order_cnt].
     display_line = trim(o.clinical_display_line), reply->orders[order_cnt].order_mnemonic = o
     .order_mnemonic,
     reply->orders[order_cnt].hna_order_mnemonic = o.hna_order_mnemonic, reply->orders[order_cnt].
     ordered_as_mnemonic = o.ordered_as_mnemonic, reply->orders[order_cnt].catalog_cd = o.catalog_cd,
     reply->orders[order_cnt].catalog_type_cd = o.catalog_type_cd, reply->orders[order_cnt].
     activity_type_cd = o.activity_type_cd, reply->orders[order_cnt].comment_type_mask = o
     .comment_type_mask,
     reply->orders[order_cnt].constant_ind = o.constant_ind, reply->orders[order_cnt].prn_ind = o
     .prn_ind, reply->orders[order_cnt].iv_ind = o.iv_ind,
     reply->orders[order_cnt].need_nurse_review_ind = o.need_nurse_review_ind, reply->orders[
     order_cnt].med_order_type_cd = o.med_order_type_cd, reply->orders[order_cnt].link_nbr = o
     .link_nbr,
     reply->orders[order_cnt].link_type_flag = o.link_type_flag, reply->orders[order_cnt].
     last_action_sequence = o.last_action_sequence, reply->orders[order_cnt].core_action_sequence = o
     .template_core_action_sequence,
     reply->orders[order_cnt].freq_type_flag = o.freq_type_flag, reply->orders[order_cnt].
     current_start_dt_tm = o.current_start_dt_tm, reply->orders[order_cnt].current_start_tz = o
     .current_start_tz,
     reply->orders[order_cnt].projected_stop_dt_tm = o.projected_stop_dt_tm, reply->orders[order_cnt]
     .projected_stop_tz = o.projected_stop_tz, reply->orders[order_cnt].stop_type_cd = o.stop_type_cd,
     reply->orders[order_cnt].orderable_type_flag = o.orderable_type_flag, reply->orders[order_cnt].
     template_order_flag = o.template_order_flag
     IF (o.pathway_catalog_id > 0)
      reply->orders[order_cnt].plan_ind = 1
     ELSE
      reply->orders[order_cnt].plan_ind = 0
     ENDIF
     reply->orders[order_cnt].taper_ind = 0, reply->orders[order_cnt].ivseq_ind = 0
     IF (o.order_status_cd IN (cancel_cd, completed_cd, deleted_cd, discontinued_cd, trans_cancel_cd,
     voided_wrslt_cd))
      reply->orders[order_cnt].need_renew_ind = 0
     ELSE
      renew_dt_tm = default_renew_dt_tm
      IF (o.stop_type_cd=hard_stop_cd
       AND o.projected_stop_dt_tm < cnvtdatetime(renew_dt_tm))
       reply->orders[order_cnt].need_renew_ind = 2
      ELSEIF (o.stop_type_cd=soft_stop_cd
       AND o.projected_stop_dt_tm < cnvtdatetime(renew_dt_tm))
       reply->orders[order_cnt].need_renew_ind = 1
      ELSE
       reply->orders[order_cnt].need_renew_ind = 0
      ENDIF
     ENDIF
     IF (o.med_order_type_cd != iv_cd)
      response_cnt += 1
      IF (mod(response_cnt,10)=1)
       stat = alterlist(martemp->responsetaskorders,(response_cnt+ 9))
      ENDIF
      martemp->responsetaskorders[response_cnt].index = order_cnt
     ENDIF
    DETAIL
     addingredient = 1
     FOR (i = 1 TO ingcnt)
       IF ((reply->orders[order_cnt].order_ingredient[i].catalog_cd=oc.catalog_cd)
        AND (reply->orders[order_cnt].order_ingredient[i].action_sequence != oi.action_sequence))
        i = (ingcnt+ 1), addingredient = 0
       ENDIF
     ENDFOR
     IF (addingredient=1)
      ingcnt += 1
      IF (mod(ingcnt,5)=1)
       stat = alterlist(reply->orders[order_cnt].order_ingredient,(ingcnt+ 4))
      ENDIF
      reply->orders[order_cnt].order_ingredient[ingcnt].catalog_cd = oc.catalog_cd, reply->orders[
      order_cnt].order_ingredient[ingcnt].primary_mnemonic = oc.primary_mnemonic, reply->orders[
      order_cnt].order_ingredient[ingcnt].ingredient_type_flag = oi.ingredient_type_flag,
      reply->orders[order_cnt].order_ingredient[ingcnt].ref_text_mask = oc.ref_text_mask, reply->
      orders[order_cnt].order_ingredient[ingcnt].cki = oc.cki, reply->orders[order_cnt].
      order_ingredient[ingcnt].action_sequence = oi.action_sequence,
      reply->orders[order_cnt].order_ingredient[ingcnt].comp_sequence = oi.comp_sequence, reply->
      orders[order_cnt].order_ingredient[ingcnt].synonym_id = oi.synonym_id, reply->orders[order_cnt]
      .order_ingredient[ingcnt].ordered_as_mnemonic = oi.ordered_as_mnemonic,
      reply->orders[order_cnt].order_ingredient[ingcnt].order_mnemonic = oi.order_mnemonic, reply->
      orders[order_cnt].order_ingredient[ingcnt].hna_order_mnemonic = oi.hna_order_mnemonic, reply->
      orders[order_cnt].order_ingredient[ingcnt].strength = oi.strength,
      reply->orders[order_cnt].order_ingredient[ingcnt].strength_unit = oi.strength_unit, reply->
      orders[order_cnt].order_ingredient[ingcnt].volume = oi.volume, reply->orders[order_cnt].
      order_ingredient[ingcnt].volume_unit = oi.volume_unit,
      reply->orders[order_cnt].order_ingredient[ingcnt].freetext_dose = oi.freetext_dose, reply->
      orders[order_cnt].order_ingredient[ingcnt].clinically_significant_flag = oi
      .clinically_significant_flag, reply->orders[order_cnt].order_ingredient[ingcnt].
      ingredient_rate_conversion_ind = ocs.ingredient_rate_conversion_ind,
      reply->orders[order_cnt].order_ingredient[ingcnt].freq_cd = oi.freq_cd, reply->orders[order_cnt
      ].order_ingredient[ingcnt].normalized_rate = oi.normalized_rate, reply->orders[order_cnt].
      order_ingredient[ingcnt].normalized_rate_unit_cd = oi.normalized_rate_unit_cd,
      reply->orders[order_cnt].order_ingredient[ingcnt].concentration = oi.concentration, reply->
      orders[order_cnt].order_ingredient[ingcnt].concentration_unit_cd = oi.concentration_unit_cd,
      reply->orders[order_cnt].order_ingredient[ingcnt].last_admin_disp_basis_flag = ocs
      .last_admin_disp_basis_flag,
      reply->orders[order_cnt].order_ingredient[ingcnt].med_interval_warn_flag = ocs
      .med_interval_warn_flag
      IF (validate(ocs.display_additives_first_ind))
       reply->orders[order_cnt].order_ingredient[ingcnt].display_additives_first_ind = ocs
       .display_additives_first_ind
      ENDIF
      IF (oi.action_sequence=max_oi_action_seq)
       reply->orders[order_cnt].order_ingredient[ingcnt].active_ind = 1
      ELSE
       reply->orders[order_cnt].order_ingredient[ingcnt].active_ind = 0
      ENDIF
     ENDIF
    FOOT  o.order_id
     stat = alterlist(reply->orders[order_cnt].order_ingredient,ingcnt)
    FOOT REPORT
     stat = alterlist(reply->orders,order_cnt)
    WITH nocounter
   ;end select
   SET stat = alterlist(request->order_list,iordercnt)
   IF (debug_ind=1)
    CALL echo(build("********LoadMissingOrders Time = ",datetimediff(cnvtdatetime(sysdate),
       loadmissingordertime,5)))
   ENDIF
 END ;Subroutine
 SUBROUTINE loadorderactions(null)
   CALL echo("********LoadOrderActions********")
   DECLARE loadorderactionstime = f8 WITH protect, noconstant(cnvtdatetime(sysdate))
   DECLARE actioncnt = i4 WITH protect, noconstant(0)
   DECLARE oit = i4 WITH protect, noconstant(0)
   DECLARE odit = i4 WITH protect, noconstant(0)
   DECLARE iterator = i4 WITH protect, noconstant(0)
   DECLARE nstart = i4 WITH protect, noconstant(1)
   DECLARE nsize = i4 WITH protect, constant(50)
   DECLARE iordercnt = i4 WITH protect, noconstant(size(reply->orders,5))
   DECLARE ntotal = i4 WITH protect, noconstant((ceil((cnvtreal(order_cnt)/ nsize)) * nsize))
   DECLARE currentpositioncd = f8 WITH protect, noconstant(0)
   SET currentpositioncd = getcurrentposition(null)
   IF (currentpositioncd)
    IF (debug_ind)
     CALL echo(build("User's current position is ",sac_cur_pos_rep->position_cd))
    ENDIF
    SET currentpositioncd = sac_cur_pos_rep->position_cd
   ELSE
    IF (debug_ind)
     CALL echo(build("Default position lookup failed with status ",sac_cur_pos_rep->status_data.
       status))
    ENDIF
    SET currentpositioncd = 0.0
   ENDIF
   SET stat = alterlist(reply->orders,ntotal)
   FOR (i = (order_cnt+ 1) TO ntotal)
     SET reply->orders[i].order_id = reply->orders[order_cnt].order_id
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
     order_action oa,
     order_detail od,
     prsnl p
    PLAN (d1
     WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ nsize))))
     JOIN (oa
     WHERE expand(iterator,nstart,(nstart+ (nsize - 1)),oa.order_id,reply->orders[iterator].order_id)
     )
     JOIN (od
     WHERE od.order_id=oa.order_id
      AND od.oe_field_meaning_id IN (57, 117, 141, 2043, 2050,
     2056, 2057, 2058, 2059, 2063))
     JOIN (p
     WHERE p.person_id=oa.action_personnel_id)
    ORDER BY oa.order_id, oa.action_sequence DESC, od.action_sequence DESC,
     od.detail_sequence
    HEAD REPORT
     IF (debug_ind=1)
      CALL echo(build("********LoadOrderActions Query Time = ",datetimediff(cnvtdatetime(sysdate),
        loadorderactionstime,5)))
     ENDIF
    HEAD oa.order_id
     actioncnt = 0, detailcnt = 0, oidx = locateval(oit,1,order_cnt,oa.order_id,reply->orders[oit].
      order_id)
    HEAD oa.action_sequence
     IF (oidx > 0)
      detailcnt = 0, actioncnt += 1
      IF (mod(actioncnt,3)=1)
       stat = alterlist(reply->orders[oidx].order_actions,(actioncnt+ 2))
      ENDIF
      reply->orders[oidx].order_actions[actioncnt].action_sequence = oa.action_sequence, reply->
      orders[oidx].order_actions[actioncnt].action_dt_tm = oa.action_dt_tm, reply->orders[oidx].
      order_actions[actioncnt].action_tz = oa.action_tz,
      reply->orders[oidx].order_actions[actioncnt].action_type_cd = oa.action_type_cd, reply->orders[
      oidx].order_actions[actioncnt].prn_ind = oa.prn_ind, reply->orders[oidx].order_actions[
      actioncnt].constant_ind = oa.constant_ind,
      reply->orders[oidx].order_actions[actioncnt].core_ind = oa.core_ind
      CASE (oa.needs_verify_ind)
       OF oa_no_verify_needed:
        reply->orders[oidx].order_actions[actioncnt].need_rx_verify_ind = o_verified
       OF oa_verify_needed:
        reply->orders[oidx].order_actions[actioncnt].need_rx_verify_ind = o_needs_review
       OF oa_superceded:
        reply->orders[oidx].order_actions[actioncnt].need_rx_verify_ind = o_needs_review
       OF oa_verified:
        reply->orders[oidx].order_actions[actioncnt].need_rx_verify_ind = o_verified
       OF oa_rejected:
        reply->orders[oidx].order_actions[actioncnt].need_rx_verify_ind = o_rejected
       OF oa_reviewed:
        reply->orders[oidx].order_actions[actioncnt].need_rx_verify_ind = o_verified
      ENDCASE
      IF (oa.need_clin_review_flag=0)
       CASE (oa.needs_verify_ind)
        OF oa_no_verify_needed:
         reply->orders[oidx].order_actions[actioncnt].need_rx_clin_review_flag = clinreviewflag_dna
        OF oa_verify_needed:
         reply->orders[oidx].order_actions[actioncnt].need_rx_clin_review_flag =
         clinreviewflag_needs_review
        OF oa_superceded:
         reply->orders[oidx].order_actions[actioncnt].need_rx_clin_review_flag =
         clinreviewflag_superceded
        OF oa_verified:
         reply->orders[oidx].order_actions[actioncnt].need_rx_clin_review_flag =
         clinreviewflag_reviewed
        OF oa_rejected:
         reply->orders[oidx].order_actions[actioncnt].need_rx_clin_review_flag =
         clinreviewflag_rejected
        OF oa_reviewed:
         reply->orders[oidx].order_actions[actioncnt].need_rx_clin_review_flag =
         clinreviewflag_reviewed
       ENDCASE
      ELSE
       reply->orders[oidx].order_actions[actioncnt].need_rx_clin_review_flag = oa
       .need_clin_review_flag
      ENDIF
      IF ( NOT ((reply->orders[oidx].order_actions[actioncnt].need_rx_clin_review_flag IN (
      clinreviewflag_reviewed, clinreviewflag_dna))))
       reply->orders[oidx].order_actions[actioncnt].verification_prsnl_id = p.person_id, reply->
       orders[oidx].order_actions[actioncnt].verification_pos_cd = currentpositioncd
      ENDIF
     ELSE
      CALL echo(build(
       "********LoadOrderActions - Unable to locate this order_id in the order list******** ",oa
       .order_id))
     ENDIF
    DETAIL
     IF (oidx > 0
      AND od.action_sequence <= oa.action_sequence)
      odidx = locateval(odit,1,detailcnt,od.oe_field_meaning_id,reply->orders[oidx].order_actions[
       actioncnt].order_details[odit].oe_field_meaning_id)
      IF (odidx <= 0)
       detailcnt += 1
       IF (mod(detailcnt,10)=1)
        stat = alterlist(reply->orders[oidx].order_actions[actioncnt].order_details,(detailcnt+ 9))
       ENDIF
       reply->orders[oidx].order_actions[actioncnt].order_details[detailcnt].action_sequence = od
       .action_sequence, reply->orders[oidx].order_actions[actioncnt].order_details[detailcnt].
       oe_field_id = od.oe_field_id, reply->orders[oidx].order_actions[actioncnt].order_details[
       detailcnt].oe_field_meaning = od.oe_field_meaning,
       reply->orders[oidx].order_actions[actioncnt].order_details[detailcnt].oe_field_meaning_id = od
       .oe_field_meaning_id, reply->orders[oidx].order_actions[actioncnt].order_details[detailcnt].
       oe_field_value = od.oe_field_value, reply->orders[oidx].order_actions[actioncnt].
       order_details[detailcnt].oe_field_display_value = od.oe_field_display_value,
       reply->orders[oidx].order_actions[actioncnt].order_details[detailcnt].oe_field_dt_tm = od
       .oe_field_dt_tm_value, reply->orders[oidx].order_actions[actioncnt].order_details[detailcnt].
       oe_field_tz = od.oe_field_tz
      ENDIF
     ENDIF
    FOOT  oa.action_sequence
     IF (oidx > 0
      AND actioncnt > 0)
      stat = alterlist(reply->orders[oidx].order_actions[actioncnt].order_details,detailcnt)
     ENDIF
    FOOT  oa.order_id
     IF (oidx > 0)
      stat = alterlist(reply->orders[oidx].order_actions,actioncnt), actionidx = locateval(iterator,1,
       actioncnt,reply->orders[oidx].last_action_sequence,reply->orders[oidx].order_actions[iterator]
       .action_sequence)
      IF (actionidx > 0)
       verifyind = reply->orders[oidx].order_actions[actionidx].need_rx_verify_ind, reviewflag =
       reply->orders[oidx].order_actions[actionidx].need_rx_clin_review_flag, prsnlid = reply->
       orders[oidx].order_actions[actionidx].verification_prsnl_id,
       positioncd = reply->orders[oidx].order_actions[actionidx].verification_pos_cd
      ELSE
       verifyind = reply->orders[oidx].order_actions[1].need_rx_verify_ind, reviewflag = reply->
       orders[oidx].order_actions[1].need_rx_clin_review_flag, prsnlid = reply->orders[oidx].
       order_actions[1].verification_prsnl_id,
       positioncd = reply->orders[oidx].order_actions[1].verification_pos_cd
      ENDIF
      reply->orders[oidx].need_rx_verify_ind = verifyind, reply->orders[oidx].
      need_rx_clin_review_flag = reviewflag
      IF ( NOT (reviewflag IN (clinreviewflag_reviewed, clinreviewflag_dna)))
       reply->orders[oidx].verification_prsnl_id = prsnlid, reply->orders[oidx].verification_pos_cd
        = positioncd
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   SET stat = alterlist(reply->orders,iordercnt)
   IF (debug_ind=1)
    CALL echo(build("********LoadOrderActions Time = ",datetimediff(cnvtdatetime(sysdate),
       loadorderactionstime,5)))
   ENDIF
 END ;Subroutine
 SUBROUTINE loaddtas(null)
   CALL echo("********LoadDTAs********")
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
    WITH nocounter
   ;end select
   SET stat = alterlist(reply->orders,iordercnt)
   IF (debug_ind=1)
    CALL echo(build("********LoadDTAs Time = ",datetimediff(cnvtdatetime(sysdate),loaddtastime,5)))
   ENDIF
 END ;Subroutine
 SUBROUTINE loadordercomments(null)
   CALL echo("********LoadOrderComments********")
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
     WITH nocounter
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
   CALL echo("********LoadResponseTaskInfo********")
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
    WITH nocounter
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
   CALL echo("********SetRenewalIndicators********")
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
     WITH nocounter
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
 SUBROUTINE loadcatalogeventcodes(null)
   CALL echo("********LoadCatalogEventCodes********")
   DECLARE loadcatalogeventcodestime = f8 WITH protect, noconstant(cnvtdatetime(sysdate))
   DECLARE iterator = i4 WITH protect, noconstant(0)
   DECLARE oit = i4 WITH protect, noconstant(0)
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
     code_value_event_r cver
    PLAN (d1
     WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ nsize))))
     JOIN (oi
     WHERE expand(iterator,nstart,(nstart+ (nsize - 1)),oi.order_id,reply->orders[iterator].order_id)
     )
     JOIN (cver
     WHERE cver.parent_cd=oi.catalog_cd)
    ORDER BY oi.order_id, oi.catalog_cd
    HEAD REPORT
     IF (debug_ind=1)
      CALL echo(build("********LoadCatalogEventCodes Query Time = ",datetimediff(cnvtdatetime(sysdate
         ),loadcatalogeventcodestime,5)))
     ENDIF
    HEAD oi.order_id
     oidx = locateval(oit,1,order_cnt,oi.order_id,reply->orders[oit].order_id), ingredcnt = size(
      reply->orders[oidx].order_ingredient,5)
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
   SET stat = alterlist(reply->orders,iordercnt)
   IF (debug_ind=1)
    CALL echo(build("********LoadCatalogEventCodes Time = ",datetimediff(cnvtdatetime(sysdate),
       loadcatalogeventcodestime,5)))
   ENDIF
 END ;Subroutine
 SUBROUTINE settaperindicator(null)
   CALL echo("********SetTaperIndicator********")
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
     ENDIF
    WITH nocounter
   ;end select
   SET stat = alterlist(reply->orders,iordercnt)
   IF (debug_ind=1)
    CALL echo(build("********SetTaperIndicator Time = ",datetimediff(cnvtdatetime(sysdate),
       settaperindicatortime,5)))
   ENDIF
 END ;Subroutine
 SET last_mod = "013 08/10/2020"
 SET modify = nopredeclare
END GO
