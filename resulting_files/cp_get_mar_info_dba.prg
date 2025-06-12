CREATE PROGRAM cp_get_mar_info:dba
 RECORD reply(
   1 scheduled_orders[*]
     2 template_order_id = f8
     2 orig_order_dt_tm = dq8
     2 orig_order_tz = i4
     2 mnemonic = vc
     2 ordered_as_mnemonic = vc
     2 hna_mnemonic = vc
     2 voided_ind = i2
     2 core_actions[*]
       3 order_id = f8
       3 action_seq = i4
       3 action = c40
       3 action_dt_tm = dq8
       3 action_tz = i4
       3 clinical_display_line = vc
       3 detail_value = f8
       3 detail_assigned = i2
     2 admins[*]
       3 order_id = f8
       3 parent_event_id = f8
       3 event_id = f8
       3 verified_dt_tm = dq8
       3 verified_tz = i4
       3 verified_prsnl_id = f8
       3 valid_from_dt_tm = dq8
       3 event_title_text = vc
       3 event_end_dt_tm = dq8
       3 event_end_tz = i4
       3 result_status_meaning = c12
       3 result_status_display = c40
       3 not_given_reason = vc
       3 admin_start_dt_tm = dq8
       3 admin_start_tz = i4
       3 dosage_value = f8
       3 dosage_unit = c40
       3 site = c40
       3 admin_by_id = f8
       3 route = c40
       3 vital_signs[*]
         4 event_id = f8
         4 vital_sign = c40
         4 value = vc
         4 unit = c40
         4 normalcy_cd = f8
       3 comments[*]
         4 comment_type = c40
         4 text = vc
         4 commenter_id = f8
         4 note_dt_tm = dq8
         4 format = c12
   1 unscheduled_orders[*]
     2 template_order_id = f8
     2 orig_order_dt_tm = dq8
     2 orig_order_tz = i4
     2 mnemonic = vc
     2 ordered_as_mnemonic = vc
     2 hna_mnemonic = vc
     2 voided_ind = i2
     2 core_actions[*]
       3 order_id = f8
       3 action_seq = i4
       3 action = c40
       3 action_dt_tm = dq8
       3 action_tz = i4
       3 clinical_display_line = vc
       3 detail_value = f8
       3 detail_assigned = i2
     2 admins[*]
       3 order_id = f8
       3 parent_event_id = f8
       3 event_id = f8
       3 verified_dt_tm = dq8
       3 verified_tz = i4
       3 verified_prsnl_id = f8
       3 valid_from_dt_tm = dq8
       3 event_title_text = vc
       3 event_end_dt_tm = dq8
       3 event_end_tz = i4
       3 result_status_meaning = c12
       3 result_status_display = c40
       3 not_given_reason = vc
       3 admin_start_dt_tm = dq8
       3 admin_start_tz = i4
       3 dosage_value = f8
       3 dosage_unit = c40
       3 site = c40
       3 admin_by_id = f8
       3 route = c40
       3 vital_signs[*]
         4 event_id = f8
         4 vital_sign = c40
         4 value = vc
         4 unit = c40
         4 normalcy_cd = f8
       3 comments[*]
         4 comment_type = c40
         4 text = vc
         4 commenter_id = f8
         4 note_dt_tm = dq8
         4 format = c12
   1 prn_orders[*]
     2 template_order_id = f8
     2 orig_order_dt_tm = dq8
     2 orig_order_tz = i4
     2 mnemonic = vc
     2 ordered_as_mnemonic = vc
     2 hna_mnemonic = vc
     2 voided_ind = i2
     2 core_actions[*]
       3 order_id = f8
       3 action_seq = i4
       3 action = c40
       3 action_dt_tm = dq8
       3 action_tz = i4
       3 clinical_display_line = vc
       3 detail_value = f8
       3 detail_assigned = i2
     2 admins[*]
       3 order_id = f8
       3 parent_event_id = f8
       3 event_id = f8
       3 verified_dt_tm = dq8
       3 verified_tz = i4
       3 verified_prsnl_id = f8
       3 valid_from_dt_tm = dq8
       3 event_title_text = vc
       3 event_end_dt_tm = dq8
       3 event_end_tz = i4
       3 result_status_meaning = c12
       3 result_status_display = c40
       3 not_given_reason = vc
       3 admin_start_dt_tm = dq8
       3 admin_start_tz = i4
       3 dosage_value = f8
       3 dosage_unit = c40
       3 site = c40
       3 admin_by_id = f8
       3 route = c40
       3 vital_signs[*]
         4 event_id = f8
         4 vital_sign = c40
         4 value = vc
         4 unit = c40
         4 normalcy_cd = f8
       3 comments[*]
         4 comment_type = c40
         4 text = vc
         4 commenter_id = f8
         4 note_dt_tm = dq8
         4 format = c12
   1 continuous_orders[*]
     2 order_id = f8
     2 orig_order_dt_tm = dq8
     2 orig_order_tz = i4
     2 mnemonic = vc
     2 ordered_as_mnemonic = vc
     2 hna_mnemonic = vc
     2 voided_ind = i2
     2 core_actions[*]
       3 action_seq = i4
       3 action_dt_tm = dq8
       3 action_tz = i4
       3 action = c40
       3 clinical_display_line = vc
     2 admins[*]
       3 parent_event_id = f8
       3 event_id = f8
       3 verified_dt_tm = dq8
       3 verified_tz = i4
       3 verified_prsnl_id = f8
       3 valid_from_dt_tm = dq8
       3 event_title_text = vc
       3 event_end_dt_tm = dq8
       3 event_end_tz = i4
       3 result_status_meaning = c12
       3 result_status_display = c40
       3 not_given_reason = vc
       3 iv_event_meaning = c12
       3 iv_event_display = c40
       3 admin_start_dt_tm = dq8
       3 admin_start_tz = i4
       3 init_dosage = f8
       3 admin_dosage = f8
       3 dosage_unit = c40
       3 initial_volume = f8
       3 infusion_rate = f8
       3 infusion_unit = c40
       3 site = c40
       3 admin_by_id = f8
       3 route = c40
       3 comments[*]
         4 comment_type = c40
         4 text = vc
         4 commenter_id = f8
         4 note_dt_tm = dq8
         4 format = c12
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD pharmacy_orders(
   1 qual[*]
     2 order_id = f8
     2 is_sched = i2
     2 is_unsched = i2
     2 is_prn = i2
     2 is_cont = i2
     2 is_parent = i2
     2 is_invalid = i2
 )
 RECORD non_continuous_meds(
   1 qual[*]
     2 is_sched = i2
     2 is_unsched = i2
     2 is_prn = i2
     2 template_order_id = f8
     2 orig_order_dt_tm = dq8
     2 orig_order_tz = i4
     2 mnemonic = vc
     2 ordered_as_mnemonic = vc
     2 hna_mnemonic = vc
     2 voided_ind = i2
     2 core_actions[*]
       3 order_id = f8
       3 action_seq = i4
       3 action = c40
       3 action_dt_tm = dq8
       3 action_tz = i4
       3 clinical_display_line = vc
       3 detail_value = f8
       3 detail_assigned = i2
     2 admins[*]
       3 order_id = f8
       3 parent_event_id = f8
       3 event_id = f8
       3 subtable_bit_map = i4
       3 verified_dt_tm = dq8
       3 verified_tz = i4
       3 verified_prsnl_id = f8
       3 valid_from_dt_tm = dq8
       3 event_title_text = vc
       3 event_end_dt_tm = dq8
       3 event_end_tz = i4
       3 result_status_meaning = c12
       3 result_status_display = c40
       3 from_ccr = i2
       3 not_given_reason = vc
       3 admin_start_dt_tm = dq8
       3 admin_start_tz = i4
       3 dosage_value = f8
       3 dosage_unit = c40
       3 site = c40
       3 admin_by_id = f8
       3 route = c40
       3 vital_signs[*]
         4 event_id = f8
         4 vital_sign = c40
         4 value = vc
         4 unit = c40
         4 normalcy_cd = f8
       3 comments[*]
         4 comment_type = c40
         4 text = vc
         4 commenter_id = f8
         4 note_dt_tm = dq8
         4 format = c12
 )
 RECORD continuous_meds(
   1 qual[*]
     2 order_id = f8
     2 orig_order_dt_tm = dq8
     2 orig_order_tz = i4
     2 mnemonic = vc
     2 ordered_as_mnemonic = vc
     2 hna_mnemonic = vc
     2 voided_ind = i2
     2 core_actions[*]
       3 action_seq = i4
       3 action_dt_tm = dq8
       3 action_tz = i4
       3 action = c40
       3 clinical_display_line = vc
     2 admins[*]
       3 parent_event_id = f8
       3 event_id = f8
       3 subtable_bit_map = i4
       3 verified_dt_tm = dq8
       3 verified_tz = i4
       3 verified_prsnl_id = f8
       3 valid_from_dt_tm = dq8
       3 event_title_text = vc
       3 event_end_dt_tm = dq8
       3 event_end_tz = i4
       3 result_status_meaning = c12
       3 result_status_display = c40
       3 from_ccr = i2
       3 not_given_reason = vc
       3 iv_event_meaning = c12
       3 iv_event_display = c40
       3 admin_start_dt_tm = dq8
       3 admin_start_tz = i4
       3 init_dosage = f8
       3 admin_dosage = f8
       3 dosage_unit = c40
       3 initial_volume = f8
       3 infusion_rate = f8
       3 infusion_unit = c40
       3 site = c40
       3 admin_by_id = f8
       3 route = c40
       3 comments[*]
         4 comment_type = c40
         4 text = vc
         4 commenter_id = f8
         4 note_dt_tm = dq8
         4 format = c12
 )
 DECLARE pharmacy_cd = f8
 DECLARE iv_type_cd = f8
 DECLARE med_type_cd = f8
 DECLARE num_type_cd = f8
 DECLARE not_done_cd = f8
 DECLARE voided_cd = f8
 DECLARE begin_bag_cd = f8
 DECLARE site_chg_cd = f8
 DECLARE rate_chg_cd = f8
 DECLARE pain_rspns_cd = f8
 DECLARE med_reason_cd = f8
 DECLARE result_cmnt_cd = f8
 DECLARE compress_cd = f8
 DECLARE scope_clause = vc
 DECLARE date_clause = vc
 DECLARE noncontmedcnt = i4
 DECLARE assignscopeclause(null) = null
 DECLARE assigndateclause(null) = null
 DECLARE getqualifyingorders(null) = null
 DECLARE getnoncontinuousmeds1(null) = null
 DECLARE getnoncontinuousmeds2(null) = null
 DECLARE getvoidedindfornoncontinuousmeds(null) = null
 DECLARE getcontinuousmeds(null) = null
 DECLARE getvitalsigns(null) = null
 DECLARE getcomments(null) = null
 DECLARE getschedvsprnfield(null) = null
 DECLARE expanddetails(null) = null
 DECLARE populatereply(null) = null
 DECLARE checkforerror(qual_num=i4,op_name=vc,force_exit=i2) = null
 SET reply->status_data.status = "F"
 SET errmsg = fillstring(132," ")
 SET stat = uar_get_meaning_by_codeset(6000,"PHARMACY",1,pharmacy_cd)
 SET stat = uar_get_meaning_by_codeset(18309,"IV",1,iv_type_cd)
 SET stat = uar_get_meaning_by_codeset(53,"MED",1,med_type_cd)
 SET stat = uar_get_meaning_by_codeset(53,"NUM",1,num_type_cd)
 SET stat = uar_get_meaning_by_codeset(8,"NOT DONE",1,not_done_cd)
 SET stat = uar_get_meaning_by_codeset(6004,"VOIDEDWRSLT",1,voided_cd)
 SET stat = uar_get_meaning_by_codeset(180,"BEGIN",1,begin_bag_cd)
 SET stat = uar_get_meaning_by_codeset(180,"RATECHG",1,rate_chg_cd)
 SET stat = uar_get_meaning_by_codeset(180,"SITECHG",1,site_chg_cd)
 SET stat = uar_get_meaning_by_codeset(14,"RES COMMENT",1,result_cmnt_cd)
 SET stat = uar_get_meaning_by_codeset(14,"RESPONSETO",1,pain_rspns_cd)
 SET stat = uar_get_meaning_by_codeset(14,"REASONFOR",1,med_reason_cd)
 SET stat = uar_get_meaning_by_codeset(120,"OCFCOMP",1,compress_cd)
 CALL assignscopeclause(null)
 CALL assigndateclause(null)
 CALL getqualifyingorders(null)
 CALL getnoncontinuousmeds1(null)
 CALL getnoncontinuousmeds2(null)
 SET stat = alterlist(non_continuous_meds->qual,noncontmedcnt)
 CALL getvoidedindfornoncontinuousmeds(null)
 CALL getcontinuousmeds(null)
 FREE RECORD pharmacy_orders
 CALL getvitalsigns(null)
 CALL getcomments(null)
 CALL getschedvsprnfield(null)
 CALL expanddetails(null)
 CALL populatereply(null)
 IF (size(reply->scheduled_orders,5)=0
  AND size(reply->unscheduled_orders,5)=0
  AND size(reply->prn_orders,5)=0
  AND size(reply->continuous_orders,5)=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SUBROUTINE assignscopeclause(null)
  CASE (request->scope_flag)
   OF 1:
    SET scope_clause = build("o.person_id =",request->person_id)
   OF 2:
    SET scope_clause = build("o.person_id =",request->person_id," AND o.encntr_id =",request->
     encntr_id)
   OF 5:
    SET scope_clause = build("o.person_id =",request->person_id," AND o.encntr_id IN",
     " (SELECT encntr_id FROM chart_request_encntr"," WHERE chart_request_id = request->request_id)")
   ELSE
    SET reply->status_data.status = "Z"
    SET reply->status_data.operationname = "Case"
    SET reply->status_data.operationstatus = "Z"
    SET reply->status_data.targetobjectname = "Scope"
    SET reply->status_data.targetobjectvalue = "Scope not supported"
    GO TO exit_script
  ENDCASE
  CALL echo(concat("Scope Clause: ",scope_clause))
 END ;Subroutine
 SUBROUTINE assigndateclause(null)
  IF ((request->qual_on_date=1))
   SET date_clause = "o.orig_order_dt_tm BETWEEN"
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
   SET date_clause = concat("o.orig_order_dt_tm BETWEEN CNVTDATETIME('01-Jan-1800')",
    " AND CNVTDATETIME('31-Dec-2100 23:59:59.59')")
  ENDIF
  CALL echo(concat("Date Clause: ",date_clause))
 END ;Subroutine
 SUBROUTINE getqualifyingorders(null)
   CALL echo("In GetQualifyingOrders")
   SELECT INTO "nl:"
    FROM orders o
    WHERE parser(scope_clause)
     AND parser(date_clause)
     AND o.catalog_type_cd=pharmacy_cd
    ORDER BY o.template_order_id, o.order_id
    HEAD REPORT
     ordercnt = 0
    HEAD o.template_order_id
     IF (o.template_order_id > 0)
      ordercnt = (ordercnt+ 1)
      IF (mod(ordercnt,10)=1)
       stat = alterlist(pharmacy_orders->qual,(ordercnt+ 9))
      ENDIF
      pharmacy_orders->qual[ordercnt].order_id = o.template_order_id, pharmacy_orders->qual[ordercnt]
      .is_parent = 1
     ENDIF
    DETAIL
     IF (o.template_order_id=0)
      ordercnt = (ordercnt+ 1)
      IF (mod(ordercnt,10)=1)
       stat = alterlist(pharmacy_orders->qual,(ordercnt+ 9))
      ENDIF
      pharmacy_orders->qual[ordercnt].order_id = o.order_id, pharmacy_orders->qual[ordercnt].
      is_parent = 0
     ENDIF
     IF (o.prn_ind=1)
      pharmacy_orders->qual[ordercnt].is_prn = 1
     ELSEIF (o.med_order_type_cd=iv_type_cd)
      pharmacy_orders->qual[ordercnt].is_cont = 1
     ELSEIF (o.freq_type_flag=5)
      pharmacy_orders->qual[ordercnt].is_unsched = 1
     ELSEIF (o.iv_ind=0)
      pharmacy_orders->qual[ordercnt].is_sched = 1
     ELSE
      pharmacy_orders->qual[ordercnt].is_invalid = 1
     ENDIF
    FOOT REPORT
     stat = alterlist(pharmacy_orders->qual,ordercnt)
    WITH nocounter
   ;end select
   CALL checkforerror(curqual,"GetQualifyingOrders",1)
 END ;Subroutine
 SUBROUTINE getnoncontinuousmeds1(null)
   CALL echo("In GetNonContinuousMeds1")
   SELECT
    IF ((request->sort_order_ind=1))
     ORDER BY template_order_id DESC, oa.action_sequence DESC, ce.event_end_dt_tm DESC,
      ce.event_id DESC, 0
    ELSE
     ORDER BY template_order_id, oa.action_sequence, ce.event_end_dt_tm,
      ce.event_id, 0
    ENDIF
    DISTINCT INTO "nl:"
    check = decode(cmr.seq,"cmr",ccr.seq,"ccr",csr.seq,
     "csr"), template_order_id = pharmacy_orders->qual[d1.seq].order_id
    FROM orders o,
     order_action oa,
     clinical_event ce,
     ce_med_result cmr,
     ce_coded_result ccr,
     ce_string_result csr,
     (dummyt d1  WITH seq = value(size(pharmacy_orders->qual,5))),
     dummyt d2,
     dummyt d3,
     dummyt d4
    PLAN (d1
     WHERE (pharmacy_orders->qual[d1.seq].is_invalid=0)
      AND (pharmacy_orders->qual[d1.seq].is_cont=0)
      AND (pharmacy_orders->qual[d1.seq].is_parent=1))
     JOIN (o
     WHERE (o.template_order_id=pharmacy_orders->qual[d1.seq].order_id))
     JOIN (oa
     WHERE oa.order_id=o.template_order_id
      AND oa.core_ind=1)
     JOIN (ce
     WHERE ce.order_id=o.order_id
      AND (ce.person_id=request->person_id)
      AND ce.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100")
      AND ce.event_class_cd=med_type_cd
      AND ce.publish_flag=1)
     JOIN (d2)
     JOIN (((cmr
     WHERE cmr.event_id=ce.event_id
      AND cmr.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100"))
     ) ORJOIN ((d3)
     JOIN (((ccr
     WHERE ccr.event_id=ce.event_id
      AND ce.result_status_cd=not_done_cd
      AND ccr.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100"))
     ) ORJOIN ((d4)
     JOIN (csr
     WHERE csr.event_id=ce.event_id
      AND ce.result_status_cd=not_done_cd
      AND csr.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100"))
     )) ))
    HEAD REPORT
     actioncnt = 0, admincnt = 0
    HEAD template_order_id
     noncontmedcnt = (noncontmedcnt+ 1)
     IF (mod(noncontmedcnt,10)=1)
      stat = alterlist(non_continuous_meds->qual,(noncontmedcnt+ 9))
     ENDIF
     non_continuous_meds->qual[noncontmedcnt].is_sched = pharmacy_orders->qual[d1.seq].is_sched,
     non_continuous_meds->qual[noncontmedcnt].is_unsched = pharmacy_orders->qual[d1.seq].is_unsched,
     non_continuous_meds->qual[noncontmedcnt].is_prn = pharmacy_orders->qual[d1.seq].is_prn,
     non_continuous_meds->qual[noncontmedcnt].template_order_id = template_order_id,
     non_continuous_meds->qual[noncontmedcnt].orig_order_dt_tm = o.orig_order_dt_tm,
     non_continuous_meds->qual[noncontmedcnt].orig_order_tz = validate(o.orig_order_tz,0),
     non_continuous_meds->qual[noncontmedcnt].mnemonic = o.order_mnemonic, non_continuous_meds->qual[
     noncontmedcnt].ordered_as_mnemonic = o.ordered_as_mnemonic, non_continuous_meds->qual[
     noncontmedcnt].hna_mnemonic = o.hna_order_mnemonic
    HEAD oa.action_sequence
     actioncnt = (actioncnt+ 1)
     IF (mod(actioncnt,5)=1)
      stat = alterlist(non_continuous_meds->qual[noncontmedcnt].core_actions,(actioncnt+ 4))
     ENDIF
     non_continuous_meds->qual[noncontmedcnt].core_actions[actioncnt].order_id = oa.order_id,
     non_continuous_meds->qual[noncontmedcnt].core_actions[actioncnt].action_seq = oa.action_sequence,
     non_continuous_meds->qual[noncontmedcnt].core_actions[actioncnt].action_dt_tm = oa.action_dt_tm,
     non_continuous_meds->qual[noncontmedcnt].core_actions[actioncnt].action_tz = validate(oa
      .action_tz,0), non_continuous_meds->qual[noncontmedcnt].core_actions[actioncnt].action =
     uar_get_code_display(oa.action_type_cd), non_continuous_meds->qual[noncontmedcnt].core_actions[
     actioncnt].clinical_display_line = oa.clinical_display_line
    DETAIL
     IF (actioncnt=1)
      admincnt = (admincnt+ 1)
      IF (mod(admincnt,10)=1)
       stat = alterlist(non_continuous_meds->qual[noncontmedcnt].admins,(admincnt+ 9))
      ENDIF
      non_continuous_meds->qual[noncontmedcnt].admins[admincnt].order_id = o.order_id,
      non_continuous_meds->qual[noncontmedcnt].admins[admincnt].parent_event_id = ce.parent_event_id,
      non_continuous_meds->qual[noncontmedcnt].admins[admincnt].event_id = ce.event_id,
      non_continuous_meds->qual[noncontmedcnt].admins[admincnt].verified_dt_tm = ce.verified_dt_tm,
      non_continuous_meds->qual[noncontmedcnt].admins[admincnt].verified_tz = validate(ce.verified_tz,
       0), non_continuous_meds->qual[noncontmedcnt].admins[admincnt].verified_prsnl_id = ce
      .verified_prsnl_id,
      non_continuous_meds->qual[noncontmedcnt].admins[admincnt].valid_from_dt_tm = ce
      .valid_from_dt_tm, non_continuous_meds->qual[noncontmedcnt].admins[admincnt].event_title_text
       = ce.event_title_text, non_continuous_meds->qual[noncontmedcnt].admins[admincnt].
      event_end_dt_tm = ce.event_end_dt_tm,
      non_continuous_meds->qual[noncontmedcnt].admins[admincnt].event_end_tz = validate(ce
       .event_end_tz,0), non_continuous_meds->qual[noncontmedcnt].admins[admincnt].
      result_status_meaning = uar_get_code_meaning(ce.result_status_cd), non_continuous_meds->qual[
      noncontmedcnt].admins[admincnt].result_status_display = uar_get_code_display(ce
       .result_status_cd),
      non_continuous_meds->qual[noncontmedcnt].admins[admincnt].admin_by_id = ce.performed_prsnl_id
      IF (check="cmr")
       non_continuous_meds->qual[noncontmedcnt].admins[admincnt].admin_start_dt_tm = cmr
       .admin_start_dt_tm, non_continuous_meds->qual[noncontmedcnt].admins[admincnt].admin_start_tz
        = validate(cmr.admin_start_tz,0), non_continuous_meds->qual[noncontmedcnt].admins[admincnt].
       dosage_unit = uar_get_code_display(cmr.dosage_unit_cd),
       non_continuous_meds->qual[noncontmedcnt].admins[admincnt].dosage_value = cmr.admin_dosage,
       non_continuous_meds->qual[noncontmedcnt].admins[admincnt].site = uar_get_code_display(cmr
        .admin_site_cd), non_continuous_meds->qual[noncontmedcnt].admins[admincnt].route =
       uar_get_code_display(cmr.admin_route_cd)
      ELSEIF (check="ccr")
       non_continuous_meds->qual[noncontmedcnt].admins[admincnt].not_given_reason =
       uar_get_code_display(ccr.result_cd), non_continuous_meds->qual[noncontmedcnt].admins[admincnt]
       .from_ccr = 1
      ELSE
       IF ((non_continuous_meds->qual[noncontmedcnt].admins[admincnt].from_ccr != 1))
        non_continuous_meds->qual[noncontmedcnt].admins[admincnt].not_given_reason = csr
        .string_result_text
       ENDIF
      ENDIF
     ENDIF
    FOOT  template_order_id
     stat = alterlist(non_continuous_meds->qual[noncontmedcnt].admins,admincnt), stat = alterlist(
      non_continuous_meds->qual[noncontmedcnt].core_actions,actioncnt), admincnt = 0,
     actioncnt = 0
    FOOT REPORT
     do_nothing = 0
    WITH nocounter
   ;end select
   CALL checkforerror(curqual,"GetNonContinuousMeds1",0)
 END ;Subroutine
 SUBROUTINE getnoncontinuousmeds2(null)
   CALL echo("In GetNonContinuousMeds2")
   SELECT
    IF ((request->sort_order_ind=1))
     ORDER BY order_id DESC, oa.action_sequence DESC, ce.event_end_dt_tm DESC,
      ce.event_id DESC, 0
    ELSE
     ORDER BY order_id, oa.action_sequence, ce.event_end_dt_tm,
      ce.event_id, 0
    ENDIF
    DISTINCT INTO "nl:"
    check = decode(cmr.seq,"cmr",ccr.seq,"ccr",csr.seq,
     "csr"), order_id = pharmacy_orders->qual[d1.seq].order_id
    FROM orders o,
     order_action oa,
     clinical_event ce,
     ce_med_result cmr,
     ce_coded_result ccr,
     ce_string_result csr,
     (dummyt d1  WITH seq = value(size(pharmacy_orders->qual,5))),
     dummyt d2,
     dummyt d3,
     dummyt d4
    PLAN (d1
     WHERE (pharmacy_orders->qual[d1.seq].is_invalid=0)
      AND (pharmacy_orders->qual[d1.seq].is_cont=0)
      AND (pharmacy_orders->qual[d1.seq].is_parent=0))
     JOIN (o
     WHERE (o.order_id=pharmacy_orders->qual[d1.seq].order_id))
     JOIN (oa
     WHERE oa.order_id=o.order_id
      AND oa.core_ind=1)
     JOIN (ce
     WHERE ce.order_id=oa.order_id
      AND (ce.person_id=request->person_id)
      AND ce.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100")
      AND ce.event_class_cd=med_type_cd
      AND ce.publish_flag=1)
     JOIN (d2)
     JOIN (((cmr
     WHERE cmr.event_id=ce.event_id
      AND cmr.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100"))
     ) ORJOIN ((d3)
     JOIN (((ccr
     WHERE ccr.event_id=ce.event_id
      AND ce.result_status_cd=not_done_cd
      AND ccr.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100"))
     ) ORJOIN ((d4)
     JOIN (csr
     WHERE csr.event_id=ce.event_id
      AND ce.result_status_cd=not_done_cd
      AND csr.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100"))
     )) ))
    HEAD REPORT
     actioncnt = 0, admincnt = 0
    HEAD order_id
     noncontmedcnt = (noncontmedcnt+ 1)
     IF (mod(noncontmedcnt,10)=1)
      stat = alterlist(non_continuous_meds->qual,(noncontmedcnt+ 9))
     ENDIF
     non_continuous_meds->qual[noncontmedcnt].is_sched = pharmacy_orders->qual[d1.seq].is_sched,
     non_continuous_meds->qual[noncontmedcnt].is_unsched = pharmacy_orders->qual[d1.seq].is_unsched,
     non_continuous_meds->qual[noncontmedcnt].is_prn = pharmacy_orders->qual[d1.seq].is_prn,
     non_continuous_meds->qual[noncontmedcnt].template_order_id = order_id, non_continuous_meds->
     qual[noncontmedcnt].orig_order_dt_tm = o.orig_order_dt_tm, non_continuous_meds->qual[
     noncontmedcnt].orig_order_tz = validate(o.orig_order_tz,0),
     non_continuous_meds->qual[noncontmedcnt].mnemonic = o.order_mnemonic, non_continuous_meds->qual[
     noncontmedcnt].ordered_as_mnemonic = o.ordered_as_mnemonic, non_continuous_meds->qual[
     noncontmedcnt].hna_mnemonic = o.hna_order_mnemonic
    HEAD oa.action_sequence
     actioncnt = (actioncnt+ 1)
     IF (mod(actioncnt,5)=1)
      stat = alterlist(non_continuous_meds->qual[noncontmedcnt].core_actions,(actioncnt+ 4))
     ENDIF
     non_continuous_meds->qual[noncontmedcnt].core_actions[actioncnt].order_id = oa.order_id,
     non_continuous_meds->qual[noncontmedcnt].core_actions[actioncnt].action_seq = oa.action_sequence,
     non_continuous_meds->qual[noncontmedcnt].core_actions[actioncnt].action_dt_tm = oa.action_dt_tm,
     non_continuous_meds->qual[noncontmedcnt].core_actions[actioncnt].action_tz = validate(oa
      .action_tz,0), non_continuous_meds->qual[noncontmedcnt].core_actions[actioncnt].action =
     uar_get_code_display(oa.action_type_cd), non_continuous_meds->qual[noncontmedcnt].core_actions[
     actioncnt].clinical_display_line = oa.clinical_display_line
    DETAIL
     IF (actioncnt=1)
      admincnt = (admincnt+ 1)
      IF (mod(admincnt,10)=1)
       stat = alterlist(non_continuous_meds->qual[noncontmedcnt].admins,(admincnt+ 9))
      ENDIF
      non_continuous_meds->qual[noncontmedcnt].admins[admincnt].order_id = o.order_id,
      non_continuous_meds->qual[noncontmedcnt].admins[admincnt].parent_event_id = ce.parent_event_id,
      non_continuous_meds->qual[noncontmedcnt].admins[admincnt].event_id = ce.event_id,
      non_continuous_meds->qual[noncontmedcnt].admins[admincnt].verified_dt_tm = ce.verified_dt_tm,
      non_continuous_meds->qual[noncontmedcnt].admins[admincnt].verified_tz = validate(ce.verified_tz,
       0), non_continuous_meds->qual[noncontmedcnt].admins[admincnt].verified_prsnl_id = ce
      .verified_prsnl_id,
      non_continuous_meds->qual[noncontmedcnt].admins[admincnt].valid_from_dt_tm = ce
      .valid_from_dt_tm, non_continuous_meds->qual[noncontmedcnt].admins[admincnt].event_title_text
       = ce.event_title_text, non_continuous_meds->qual[noncontmedcnt].admins[admincnt].
      event_end_dt_tm = ce.event_end_dt_tm,
      non_continuous_meds->qual[noncontmedcnt].admins[admincnt].event_end_tz = validate(ce
       .event_end_tz,0), non_continuous_meds->qual[noncontmedcnt].admins[admincnt].
      result_status_meaning = uar_get_code_meaning(ce.result_status_cd), non_continuous_meds->qual[
      noncontmedcnt].admins[admincnt].result_status_display = uar_get_code_display(ce
       .result_status_cd),
      non_continuous_meds->qual[noncontmedcnt].admins[admincnt].admin_by_id = ce.performed_prsnl_id
      IF (check="cmr")
       non_continuous_meds->qual[noncontmedcnt].admins[admincnt].admin_start_dt_tm = cmr
       .admin_start_dt_tm, non_continuous_meds->qual[noncontmedcnt].admins[admincnt].admin_start_tz
        = validate(cmr.admin_start_tz,0), non_continuous_meds->qual[noncontmedcnt].admins[admincnt].
       dosage_unit = uar_get_code_display(cmr.dosage_unit_cd),
       non_continuous_meds->qual[noncontmedcnt].admins[admincnt].dosage_value = cmr.admin_dosage,
       non_continuous_meds->qual[noncontmedcnt].admins[admincnt].site = uar_get_code_display(cmr
        .admin_site_cd), non_continuous_meds->qual[noncontmedcnt].admins[admincnt].route =
       uar_get_code_display(cmr.admin_route_cd)
      ELSEIF (check="ccr")
       non_continuous_meds->qual[noncontmedcnt].admins[admincnt].not_given_reason =
       uar_get_code_display(ccr.result_cd), non_continuous_meds->qual[noncontmedcnt].admins[admincnt]
       .from_ccr = 1
      ELSE
       IF ((non_continuous_meds->qual[noncontmedcnt].admins[admincnt].from_ccr != 1))
        non_continuous_meds->qual[noncontmedcnt].admins[admincnt].not_given_reason = csr
        .string_result_text
       ENDIF
      ENDIF
     ENDIF
    FOOT  oa.action_sequence
     do_nothing = 0
    FOOT  order_id
     stat = alterlist(non_continuous_meds->qual[noncontmedcnt].admins,admincnt), stat = alterlist(
      non_continuous_meds->qual[noncontmedcnt].core_actions,actioncnt), admincnt = 0,
     actioncnt = 0
    FOOT REPORT
     do_nothing = 0
    WITH nocounter
   ;end select
   CALL checkforerror(curqual,"GetNonContinuousMeds2",0)
 END ;Subroutine
 SUBROUTINE getvoidedindfornoncontinuousmeds(null)
  CALL echo("In GetVoidedIndForNonContinuousMeds")
  IF (size(non_continuous_meds->qual,5) > 0)
   SELECT INTO "nl:"
    FROM orders o,
     (dummyt d1  WITH seq = value(size(non_continuous_meds->qual,5)))
    PLAN (d1)
     JOIN (o
     WHERE (o.order_id=non_continuous_meds->qual[d1.seq].template_order_id)
      AND o.order_status_cd=voided_cd)
    ORDER BY d1.seq
    DETAIL
     non_continuous_meds->qual[d1.seq].voided_ind = 1
    WITH nocounter
   ;end select
   CALL checkforerror(curqual,"GetVoidedIndForNonContinuousMeds",0)
  ENDIF
 END ;Subroutine
 SUBROUTINE getcontinuousmeds(null)
   CALL echo("In GetContinuousMeds")
   SELECT
    IF ((request->sort_order_ind=1))
     ORDER BY o.order_id DESC, oa.action_sequence DESC, ce.event_end_dt_tm DESC,
      cmr.admin_start_dt_tm DESC, ce.event_id
    ELSE
     ORDER BY o.order_id, oa.action_sequence, ce.event_end_dt_tm,
      cmr.admin_start_dt_tm, ce.event_id
    ENDIF
    DISTINCT INTO "nl:"
    check = decode(cmr.seq,"cmr",ccr.seq,"ccr",csr.seq,
     "csr"), cdf_meaning = uar_get_code_meaning(ce.event_cd)
    FROM orders o,
     order_action oa,
     clinical_event ce,
     ce_med_result cmr,
     ce_coded_result ccr,
     ce_string_result csr,
     (dummyt d1  WITH seq = value(size(pharmacy_orders->qual,5))),
     dummyt d2,
     dummyt d3,
     dummyt d4
    PLAN (d1
     WHERE (pharmacy_orders->qual[d1.seq].is_invalid=0)
      AND (pharmacy_orders->qual[d1.seq].is_cont=1))
     JOIN (o
     WHERE (o.order_id=pharmacy_orders->qual[d1.seq].order_id))
     JOIN (oa
     WHERE oa.order_id=o.order_id
      AND oa.core_ind=1)
     JOIN (ce
     WHERE ce.order_id=oa.order_id
      AND (ce.person_id=request->person_id)
      AND ce.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100")
      AND ce.event_class_cd=med_type_cd
      AND ce.publish_flag=1)
     JOIN (d2)
     JOIN (((cmr
     WHERE cmr.event_id=ce.event_id
      AND cmr.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100")
      AND cmr.iv_event_cd > 0)
     ) ORJOIN ((d3)
     JOIN (((ccr
     WHERE ccr.event_id=ce.event_id
      AND ce.result_status_cd=not_done_cd
      AND ccr.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100"))
     ) ORJOIN ((d4)
     JOIN (csr
     WHERE csr.event_id=ce.event_id
      AND ce.result_status_cd=not_done_cd
      AND csr.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100"))
     )) ))
    HEAD REPORT
     ordercnt = 0, actioncnt = 0, admincnt = 0
    HEAD o.order_id
     ordercnt = (ordercnt+ 1)
     IF (mod(ordercnt,10)=1)
      stat = alterlist(continuous_meds->qual,(ordercnt+ 9))
     ENDIF
     continuous_meds->qual[ordercnt].order_id = o.order_id, continuous_meds->qual[ordercnt].
     orig_order_dt_tm = o.orig_order_dt_tm, continuous_meds->qual[ordercnt].orig_order_tz = validate(
      o.orig_order_tz,0),
     continuous_meds->qual[ordercnt].mnemonic = o.order_mnemonic, continuous_meds->qual[ordercnt].
     ordered_as_mnemonic = o.ordered_as_mnemonic, continuous_meds->qual[ordercnt].hna_mnemonic = o
     .hna_order_mnemonic
     IF (o.order_status_cd=voided_cd)
      continuous_meds->qual[ordercnt].voided_ind = 1
     ENDIF
    HEAD oa.action_sequence
     actioncnt = (actioncnt+ 1)
     IF (mod(actioncnt,5)=1)
      stat = alterlist(continuous_meds->qual[ordercnt].core_actions,(actioncnt+ 4))
     ENDIF
     continuous_meds->qual[ordercnt].core_actions[actioncnt].action_seq = oa.action_sequence,
     continuous_meds->qual[ordercnt].core_actions[actioncnt].action_dt_tm = oa.action_dt_tm,
     continuous_meds->qual[ordercnt].core_actions[actioncnt].action_tz = validate(oa.action_tz,0),
     continuous_meds->qual[ordercnt].core_actions[actioncnt].action = uar_get_code_display(oa
      .action_type_cd), continuous_meds->qual[ordercnt].core_actions[actioncnt].clinical_display_line
      = oa.clinical_display_line
    DETAIL
     IF (actioncnt=1)
      admincnt = (admincnt+ 1)
      IF (mod(admincnt,10)=1)
       stat = alterlist(continuous_meds->qual[ordercnt].admins,(admincnt+ 9))
      ENDIF
      continuous_meds->qual[ordercnt].admins[admincnt].parent_event_id = ce.parent_event_id,
      continuous_meds->qual[ordercnt].admins[admincnt].event_id = ce.event_id, continuous_meds->qual[
      ordercnt].admins[admincnt].verified_dt_tm = ce.verified_dt_tm,
      continuous_meds->qual[ordercnt].admins[admincnt].verified_tz = validate(ce.verified_tz,0),
      continuous_meds->qual[ordercnt].admins[admincnt].verified_prsnl_id = ce.verified_prsnl_id,
      continuous_meds->qual[ordercnt].admins[admincnt].valid_from_dt_tm = ce.valid_from_dt_tm,
      continuous_meds->qual[ordercnt].admins[admincnt].event_title_text = ce.event_title_text,
      continuous_meds->qual[ordercnt].admins[admincnt].event_end_dt_tm = ce.event_end_dt_tm,
      continuous_meds->qual[ordercnt].admins[admincnt].event_end_tz = validate(ce.event_end_tz,0),
      continuous_meds->qual[ordercnt].admins[admincnt].result_status_meaning = uar_get_code_meaning(
       ce.result_status_cd), continuous_meds->qual[ordercnt].admins[admincnt].result_status_display
       = uar_get_code_display(ce.result_status_cd), continuous_meds->qual[ordercnt].admins[admincnt].
      admin_by_id = ce.performed_prsnl_id
      IF (check="cmr")
       continuous_meds->qual[ordercnt].admins[admincnt].iv_event_meaning = uar_get_code_meaning(cmr
        .iv_event_cd), continuous_meds->qual[ordercnt].admins[admincnt].iv_event_display =
       uar_get_code_display(cmr.iv_event_cd), continuous_meds->qual[ordercnt].admins[admincnt].
       admin_start_dt_tm = cmr.admin_start_dt_tm,
       continuous_meds->qual[ordercnt].admins[admincnt].admin_start_tz = validate(cmr.admin_start_tz,
        0), continuous_meds->qual[ordercnt].admins[admincnt].init_dosage = cmr.initial_dosage,
       continuous_meds->qual[ordercnt].admins[admincnt].admin_dosage = cmr.admin_dosage,
       continuous_meds->qual[ordercnt].admins[admincnt].dosage_unit = uar_get_code_display(cmr
        .dosage_unit_cd), continuous_meds->qual[ordercnt].admins[admincnt].initial_volume = cmr
       .initial_volume, continuous_meds->qual[ordercnt].admins[admincnt].infusion_rate = cmr
       .infusion_rate,
       continuous_meds->qual[ordercnt].admins[admincnt].infusion_unit = uar_get_code_display(cmr
        .infusion_unit_cd), continuous_meds->qual[ordercnt].admins[admincnt].site =
       uar_get_code_display(cmr.admin_site_cd), continuous_meds->qual[ordercnt].admins[admincnt].
       route = uar_get_code_display(cmr.admin_route_cd)
      ELSEIF (check="ccr")
       continuous_meds->qual[ordercnt].admins[admincnt].not_given_reason = uar_get_code_display(ccr
        .result_cd), continuous_meds->qual[ordercnt].admins[admincnt].from_ccr = 1
      ELSE
       IF ((continuous_meds->qual[ordercnt].admins[admincnt].from_ccr != 1))
        continuous_meds->qual[ordercnt].admins[admincnt].not_given_reason = csr.string_result_text
       ENDIF
      ENDIF
     ENDIF
    FOOT  oa.action_sequence
     do_nothing = 0
    FOOT  o.order_id
     stat = alterlist(continuous_meds->qual[ordercnt].core_actions,actioncnt), stat = alterlist(
      continuous_meds->qual[ordercnt].admins,admincnt), actioncnt = 0,
     admincnt = 0
    FOOT REPORT
     stat = alterlist(continuous_meds->qual,ordercnt)
    WITH nocounter
   ;end select
   CALL checkforerror(curqual,"GetContinuousMeds",0)
 END ;Subroutine
 SUBROUTINE getvitalsigns(null)
  CALL echo("In GetVitalSigns")
  IF (size(non_continuous_meds->qual,5) > 0)
   SELECT INTO "nl:"
    FROM clinical_event ce1,
     clinical_event ce2,
     (dummyt d1  WITH seq = value(size(non_continuous_meds->qual,5))),
     (dummyt d2  WITH seq = 1)
    PLAN (d1
     WHERE maxrec(d2,size(non_continuous_meds->qual[d1.seq].admins,5)))
     JOIN (d2)
     JOIN (ce1
     WHERE (ce1.parent_event_id=non_continuous_meds->qual[d1.seq].admins[d2.seq].parent_event_id)
      AND ce1.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100")
      AND ce1.publish_flag=1)
     JOIN (ce2
     WHERE ce2.parent_event_id=ce1.event_id
      AND ce2.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100")
      AND ce2.event_class_cd=num_type_cd
      AND ce2.publish_flag=1)
    ORDER BY d1.seq, d2.seq, ce2.event_id
    HEAD d1.seq
     vitalsigncnt = 0
    HEAD d2.seq
     do_nothing = 0
    DETAIL
     vitalsigncnt = (vitalsigncnt+ 1)
     IF (mod(vitalsigncnt,5)=1)
      stat = alterlist(non_continuous_meds->qual[d1.seq].admins[d2.seq].vital_signs,(vitalsigncnt+ 4)
       )
     ENDIF
     non_continuous_meds->qual[d1.seq].admins[d2.seq].vital_signs[vitalsigncnt].event_id = ce2
     .event_id, non_continuous_meds->qual[d1.seq].admins[d2.seq].vital_signs[vitalsigncnt].vital_sign
      = uar_get_code_display(ce2.event_cd), non_continuous_meds->qual[d1.seq].admins[d2.seq].
     vital_signs[vitalsigncnt].value = ce2.result_val,
     non_continuous_meds->qual[d1.seq].admins[d2.seq].vital_signs[vitalsigncnt].unit =
     uar_get_code_display(ce2.result_units_cd), non_continuous_meds->qual[d1.seq].admins[d2.seq].
     vital_signs[vitalsigncnt].normalcy_cd = ce2.normalcy_cd
    FOOT  d2.seq
     stat = alterlist(non_continuous_meds->qual[d1.seq].admins[d2.seq].vital_signs,vitalsigncnt),
     vitalsigncnt = 0
    FOOT  d1.seq
     do_nothing = 0
    WITH nocounter
   ;end select
   CALL checkforerror(curqual,"GetVitalSigns",0)
  ENDIF
 END ;Subroutine
 SUBROUTINE getcomments(null)
  CALL echo("In GetComments")
  IF (size(non_continuous_meds->qual,5) > 0)
   SELECT INTO "nl:"
    blength = size(trim(lb.long_blob))
    FROM ce_event_note cen,
     long_blob lb,
     (dummyt d1  WITH seq = value(size(non_continuous_meds->qual,5))),
     (dummyt d2  WITH seq = 1)
    PLAN (d1
     WHERE maxrec(d2,size(non_continuous_meds->qual[d1.seq].admins,5)))
     JOIN (d2
     WHERE btest(non_continuous_meds->qual[d1.seq].admins[d2.seq].subtable_bit_map,1)=1)
     JOIN (cen
     WHERE (cen.event_id=non_continuous_meds->qual[d1.seq].admins[d2.seq].event_id)
      AND cen.note_type_cd IN (pain_rspns_cd, med_reason_cd, result_cmnt_cd)
      AND cen.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100"))
     JOIN (lb
     WHERE lb.parent_entity_id=cen.ce_event_note_id)
    ORDER BY d1.seq, d2.seq, cen.note_type_cd
    HEAD d1.seq
     commentcnt = 0, blob_out = fillstring(65536," "), blob_ret_len = 0
    HEAD d2.seq
     do_nothing = 0
    DETAIL
     commentcnt = (commentcnt+ 1)
     IF (mod(commentcnt,5)=1)
      stat = alterlist(non_continuous_meds->qual[d1.seq].admins[d2.seq].comments,(commentcnt+ 4))
     ENDIF
     non_continuous_meds->qual[d1.seq].admins[d2.seq].comments[commentcnt].comment_type =
     uar_get_code_display(cen.note_type_cd), non_continuous_meds->qual[d1.seq].admins[d2.seq].
     comments[commentcnt].commenter_id = cen.note_prsnl_id, non_continuous_meds->qual[d1.seq].admins[
     d2.seq].comments[commentcnt].format = uar_get_code_meaning(cen.note_format_cd)
     IF (cen.compression_cd=compress_cd)
      CALL uar_ocf_uncompress(lb.long_blob,blength,blob_out,65536,blob_ret_len), non_continuous_meds
      ->qual[d1.seq].admins[d2.seq].comments[commentcnt].text = substring(1,blob_ret_len,blob_out)
     ELSE
      blob_out = substring(1,(blength - 8),lb.long_blob), non_continuous_meds->qual[d1.seq].admins[d2
      .seq].comments[commentcnt].text = blob_out
     ENDIF
    FOOT  d2.seq
     stat = alterlist(non_continuous_meds->qual[d1.seq].admins[d2.seq].comments,commentcnt),
     commentcnt = 0
    FOOT  d1.seq
     do_nothing = 0
    WITH nocounter
   ;end select
   CALL checkforerror(curqual,"GetComments-NonContinuous",0)
  ELSEIF (size(continuous_meds->qual,5) > 0)
   SELECT INTO "nl:"
    blength = size(trim(lb.long_blob))
    FROM ce_event_note cen,
     long_blob lb,
     (dummyt d1  WITH seq = value(size(continuous_meds->qual,5))),
     (dummyt d2  WITH seq = 1)
    PLAN (d1
     WHERE maxrec(d2,size(continuous_meds->qual[d1.seq].admins,5)))
     JOIN (d2
     WHERE btest(continuous_meds->qual[d1.seq].admins[d2.seq].subtable_bit_map,1)=1)
     JOIN (cen
     WHERE (cen.event_id=continuous_meds->qual[d1.seq].admins[d2.seq].event_id)
      AND cen.note_type_cd IN (pain_rspns_cd, med_reason_cd, result_cmnt_cd)
      AND cen.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100"))
     JOIN (lb
     WHERE lb.parent_entity_id=cen.ce_event_note_id)
    ORDER BY cen.note_type_cd
    HEAD d1.seq
     commentcnt = 0, blob_out = fillstring(65536," "), blob_ret_len = 0
    HEAD d2.seq
     do_nothing = 0
    DETAIL
     commentcnt = (commentcnt+ 1)
     IF (mod(commentcnt,5)=1)
      stat = alterlist(continuous_meds->qual[d1.seq].admins[d2.seq].comments,(commentcnt+ 4))
     ENDIF
     continuous_meds->qual[d1.seq].admins[d2.seq].comments[commentcnt].comment_type =
     uar_get_code_display(cen.note_type_cd), continuous_meds->qual[d1.seq].admins[d2.seq].comments[
     commentcnt].commenter_id = cen.note_prsnl_id, continuous_meds->qual[d1.seq].admins[d2.seq].
     comments[commentcnt].format = uar_get_code_meaning(cen.note_format_cd)
     IF (cen.compression_cd=compress_cd)
      CALL uar_ocf_uncompress(lb.long_blob,blength,blob_out,65536,blob_ret_len), continuous_meds->
      qual[d1.seq].admins[d2.seq].comments[commentcnt].text = substring(1,blob_ret_len,blob_out)
     ELSE
      blob_out = substring(1,(blength - 8),lb.long_blob), continuous_meds->qual[d1.seq].admins[d2.seq
      ].comments[commentcnt].text = blob_out
     ENDIF
    FOOT  d2.seq
     stat = alterlist(continuous_meds->qual[d1.seq].admins[d2.seq].comments,commentcnt), commentcnt
      = 0
    FOOT  d1.seq
     do_nothing = 0
    WITH nocounter
   ;end select
   CALL checkforerror(curqual,"GetComments-Continuous",0)
  ENDIF
 END ;Subroutine
 SUBROUTINE getschedvsprnfield(null)
  CALL echo("In GetSchedVsPRNField")
  IF (size(non_continuous_meds->qual,5) > 0)
   SELECT INTO "nl:"
    FROM order_detail od,
     (dummyt d1  WITH seq = value(size(non_continuous_meds->qual,5))),
     (dummyt d2  WITH seq = 1)
    PLAN (d1
     WHERE maxrec(d2,size(non_continuous_meds->qual[d1.seq].core_actions,5)))
     JOIN (d2)
     JOIN (od
     WHERE (od.order_id=non_continuous_meds->qual[d1.seq].core_actions[d2.seq].order_id)
      AND (od.action_sequence=non_continuous_meds->qual[d1.seq].core_actions[d2.seq].action_seq)
      AND od.oe_field_meaning_id=2037)
    ORDER BY d1.seq, d2.seq
    DETAIL
     non_continuous_meds->qual[d1.seq].core_actions[d2.seq].detail_value = od.oe_field_value,
     non_continuous_meds->qual[d1.seq].core_actions[d2.seq].detail_assigned = 1
    WITH nocounter
   ;end select
   CALL checkforerror(curqual,"GetSchedVsPRNField",0)
  ENDIF
 END ;Subroutine
 SUBROUTINE expanddetails(null)
  CALL echo("In ExpandDetails")
  IF (size(non_continuous_meds->qual,5) > 0)
   SELECT INTO "nl:"
    FROM order_detail od,
     (dummyt d1  WITH seq = value(size(non_continuous_meds->qual,5))),
     (dummyt d2  WITH seq = 1)
    PLAN (d1
     WHERE maxrec(d2,size(non_continuous_meds->qual[d1.seq].core_actions,5)))
     JOIN (d2
     WHERE ((size(non_continuous_meds->qual[d1.seq].core_actions[d2.seq].clinical_display_line,1) >
     250) OR (size(non_continuous_meds->qual[d1.seq].core_actions[d2.seq].clinical_display_line,1)=0
     )) )
     JOIN (od
     WHERE (od.order_id=non_continuous_meds->qual[d1.seq].core_actions[d2.seq].order_id)
      AND (od.action_sequence=non_continuous_meds->qual[d1.seq].core_actions[d2.seq].action_seq)
      AND  NOT (od.oe_field_meaning_id IN (125, 2071, 2094)))
    ORDER BY d1.seq, d2.seq, od.detail_sequence
    HEAD REPORT
     detailcnt = 0, lastfieldid = 0.0
    HEAD d1.seq
     do_nothing = 0
    HEAD d2.seq
     non_continuous_meds->qual[d1.seq].core_actions[d2.seq].clinical_display_line = ""
    DETAIL
     IF ( NOT (od.oe_field_display_value IN (" ", "")))
      detailcnt = (detailcnt+ 1)
      IF (detailcnt=1)
       non_continuous_meds->qual[d1.seq].core_actions[d2.seq].clinical_display_line = trim(od
        .oe_field_display_value)
      ELSEIF (od.oe_field_meaning_id=lastfieldid)
       non_continuous_meds->qual[d1.seq].core_actions[d2.seq].clinical_display_line = concat(trim(
         non_continuous_meds->qual[d1.seq].core_actions[d2.seq].clinical_display_line)," | ",trim(od
         .oe_field_display_value))
      ELSE
       non_continuous_meds->qual[d1.seq].core_actions[d2.seq].clinical_display_line = concat(trim(
         non_continuous_meds->qual[d1.seq].core_actions[d2.seq].clinical_display_line),", ",trim(od
         .oe_field_display_value))
      ENDIF
     ENDIF
     lastfieldid = od.oe_field_meaning_id
    FOOT  d2.seq
     lastfieldid = 0.0, detailcnt = 0
    FOOT  d1.seq
     do_nothing = 0
    FOOT REPORT
     do_nothing = 0
    WITH nocounter
   ;end select
   CALL checkforerror(curqual,"ExpandDetails-NonContinuous",0)
  ELSEIF (size(continuous_meds->qual,5) > 0)
   SELECT INTO "nl:"
    FROM order_detail od,
     (dummyt d1  WITH seq = value(size(continuous_meds->qual,5))),
     (dummyt d2  WITH seq = 1)
    PLAN (d1
     WHERE maxrec(d2,size(continuous_meds->qual[d1.seq].core_actions,5)))
     JOIN (d2
     WHERE ((size(continuous_meds->qual[d1.seq].core_actions[d2.seq].clinical_display_line,1) > 250)
      OR (size(continuous_meds->qual[d1.seq].core_actions[d2.seq].clinical_display_line,1)=0)) )
     JOIN (od
     WHERE (od.order_id=continuous_meds->qual[d1.seq].order_id)
      AND (od.action_sequence=continuous_meds->qual[d1.seq].core_actions[d2.seq].action_seq)
      AND  NOT (od.oe_field_meaning_id IN (125, 2071, 2094)))
    ORDER BY d1.seq, d2.seq, od.detail_sequence
    HEAD REPORT
     detailcnt = 0, lastfieldid = 0.0
    HEAD d1.seq
     do_nothing = 0
    HEAD d2.seq
     continuous_meds->qual[d1.seq].core_actions[d2.seq].clinical_display_line = ""
    DETAIL
     IF ( NOT (od.oe_field_display_value IN (" ", "")))
      detailcnt = (detailcnt+ 1)
      IF (detailcnt=1)
       continuous_meds->qual[d1.seq].core_actions[d2.seq].clinical_display_line = trim(od
        .oe_field_display_value)
      ELSEIF (od.oe_field_meaning_id=lastfieldid)
       continuous_meds->qual[d1.seq].core_actions[d2.seq].clinical_display_line = concat(trim(
         continuous_meds->qual[d1.seq].core_actions[d2.seq].clinical_display_line)," | ",trim(od
         .oe_field_display_value))
      ELSE
       continuous_meds->qual[d1.seq].core_actions[d2.seq].clinical_display_line = concat(trim(
         continuous_meds->qual[d1.seq].core_actions[d2.seq].clinical_display_line),", ",trim(od
         .oe_field_display_value))
      ENDIF
     ENDIF
     lastfieldid = od.oe_field_meaning_id
    FOOT  d2.seq
     lastfieldid = 0.0, detailcnt = 0
    FOOT  d1.seq
     do_nothing = 0
    FOOT REPORT
     do_nothing = 0
    WITH nocounter
   ;end select
   CALL checkforerror(curqual,"ExpandDetails-Continuous",0)
  ENDIF
 END ;Subroutine
 SUBROUTINE populatereply(null)
   CALL echo("In PopulateReply")
   SET totalmedcnt = size(non_continuous_meds->qual,5)
   SET schedmedcnt = 0
   SET unschedmedcnt = 0
   SET prnmedcnt = 0
   FOR (med = 1 TO totalmedcnt)
     IF ((non_continuous_meds->qual[med].is_sched=1))
      SET schedmedcnt = (schedmedcnt+ 1)
     ELSEIF ((non_continuous_meds->qual[med].is_unsched=1))
      SET unschedmedcnt = (unschedmedcnt+ 1)
     ELSEIF ((non_continuous_meds->qual[med].is_prn=1))
      SET prnmedcnt = (prnmedcnt+ 1)
     ENDIF
   ENDFOR
   SET stat = alterlist(reply->scheduled_orders,schedmedcnt)
   SET stat = alterlist(reply->unscheduled_orders,unschedmedcnt)
   SET stat = alterlist(reply->prn_orders,prnmedcnt)
   SET schedmed = 0
   SET unschedmed = 0
   SET prnmed = 0
   FOR (med = 1 TO totalmedcnt)
     SET actioncnt = size(non_continuous_meds->qual[med].core_actions,5)
     SET admincnt = size(non_continuous_meds->qual[med].admins,5)
     IF ((non_continuous_meds->qual[med].is_sched=1))
      SET schedmed = (schedmed+ 1)
      SET reply->scheduled_orders[schedmed].template_order_id = non_continuous_meds->qual[med].
      template_order_id
      SET reply->scheduled_orders[schedmed].orig_order_dt_tm = non_continuous_meds->qual[med].
      orig_order_dt_tm
      SET reply->scheduled_orders[schedmed].orig_order_tz = non_continuous_meds->qual[med].
      orig_order_tz
      SET reply->scheduled_orders[schedmed].mnemonic = non_continuous_meds->qual[med].mnemonic
      SET reply->scheduled_orders[schedmed].ordered_as_mnemonic = non_continuous_meds->qual[med].
      ordered_as_mnemonic
      SET reply->scheduled_orders[schedmed].hna_mnemonic = non_continuous_meds->qual[med].
      hna_mnemonic
      SET reply->scheduled_orders[schedmed].voided_ind = non_continuous_meds->qual[med].voided_ind
      SET stat = alterlist(reply->scheduled_orders[schedmed].core_actions,actioncnt)
      FOR (action = 1 TO actioncnt)
        SET reply->scheduled_orders[schedmed].core_actions[action].order_id = non_continuous_meds->
        qual[med].core_actions[action].order_id
        SET reply->scheduled_orders[schedmed].core_actions[action].action_seq = non_continuous_meds->
        qual[med].core_actions[action].action_seq
        SET reply->scheduled_orders[schedmed].core_actions[action].action = non_continuous_meds->
        qual[med].core_actions[action].action
        SET reply->scheduled_orders[schedmed].core_actions[action].action_dt_tm = non_continuous_meds
        ->qual[med].core_actions[action].action_dt_tm
        SET reply->scheduled_orders[schedmed].core_actions[action].action_tz = non_continuous_meds->
        qual[med].core_actions[action].action_tz
        SET reply->scheduled_orders[schedmed].core_actions[action].clinical_display_line =
        non_continuous_meds->qual[med].core_actions[action].clinical_display_line
        SET reply->scheduled_orders[schedmed].core_actions[action].detail_value = non_continuous_meds
        ->qual[med].core_actions[action].detail_value
        SET reply->scheduled_orders[schedmed].core_actions[action].detail_assigned =
        non_continuous_meds->qual[med].core_actions[action].detail_assigned
      ENDFOR
      SET stat = alterlist(reply->scheduled_orders[schedmed].admins,admincnt)
      FOR (admin = 1 TO admincnt)
        SET reply->scheduled_orders[schedmed].admins[admin].order_id = non_continuous_meds->qual[med]
        .admins[admin].order_id
        SET reply->scheduled_orders[schedmed].admins[admin].parent_event_id = non_continuous_meds->
        qual[med].admins[admin].parent_event_id
        SET reply->scheduled_orders[schedmed].admins[admin].event_id = non_continuous_meds->qual[med]
        .admins[admin].event_id
        SET reply->scheduled_orders[schedmed].admins[admin].verified_dt_tm = non_continuous_meds->
        qual[med].admins[admin].verified_dt_tm
        SET reply->scheduled_orders[schedmed].admins[admin].verified_tz = non_continuous_meds->qual[
        med].admins[admin].verified_tz
        SET reply->scheduled_orders[schedmed].admins[admin].verified_prsnl_id = non_continuous_meds->
        qual[med].admins[admin].verified_prsnl_id
        SET reply->scheduled_orders[schedmed].admins[admin].valid_from_dt_tm = non_continuous_meds->
        qual[med].admins[admin].valid_from_dt_tm
        SET reply->scheduled_orders[schedmed].admins[admin].event_title_text = non_continuous_meds->
        qual[med].admins[admin].event_title_text
        SET reply->scheduled_orders[schedmed].admins[admin].event_end_dt_tm = non_continuous_meds->
        qual[med].admins[admin].event_end_dt_tm
        SET reply->scheduled_orders[schedmed].admins[admin].event_end_tz = non_continuous_meds->qual[
        med].admins[admin].event_end_tz
        SET reply->scheduled_orders[schedmed].admins[admin].result_status_meaning =
        non_continuous_meds->qual[med].admins[admin].result_status_meaning
        SET reply->scheduled_orders[schedmed].admins[admin].result_status_display =
        non_continuous_meds->qual[med].admins[admin].result_status_display
        SET reply->scheduled_orders[schedmed].admins[admin].not_given_reason = non_continuous_meds->
        qual[med].admins[admin].not_given_reason
        SET reply->scheduled_orders[schedmed].admins[admin].admin_start_dt_tm = non_continuous_meds->
        qual[med].admins[admin].admin_start_dt_tm
        SET reply->scheduled_orders[schedmed].admins[admin].admin_start_tz = non_continuous_meds->
        qual[med].admins[admin].admin_start_tz
        SET reply->scheduled_orders[schedmed].admins[admin].dosage_value = non_continuous_meds->qual[
        med].admins[admin].dosage_value
        SET reply->scheduled_orders[schedmed].admins[admin].dosage_unit = non_continuous_meds->qual[
        med].admins[admin].dosage_unit
        SET reply->scheduled_orders[schedmed].admins[admin].site = non_continuous_meds->qual[med].
        admins[admin].site
        SET reply->scheduled_orders[schedmed].admins[admin].admin_by_id = non_continuous_meds->qual[
        med].admins[admin].admin_by_id
        SET reply->scheduled_orders[schedmed].admins[admin].route = non_continuous_meds->qual[med].
        admins[admin].route
        SET vitalsigncnt = size(non_continuous_meds->qual[med].admins[admin].vital_signs,5)
        SET stat = alterlist(reply->scheduled_orders[schedmed].admins[admin].vital_signs,vitalsigncnt
         )
        FOR (vitalsign = 1 TO vitalsigncnt)
          SET reply->scheduled_orders[schedmed].admins[admin].vital_signs[vitalsign].event_id =
          non_continuous_meds->qual[med].admins[admin].vital_signs[vitalsign].event_id
          SET reply->scheduled_orders[schedmed].admins[admin].vital_signs[vitalsign].vital_sign =
          non_continuous_meds->qual[med].admins[admin].vital_signs[vitalsign].vital_sign
          SET reply->scheduled_orders[schedmed].admins[admin].vital_signs[vitalsign].value =
          non_continuous_meds->qual[med].admins[admin].vital_signs[vitalsign].value
          SET reply->scheduled_orders[schedmed].admins[admin].vital_signs[vitalsign].unit =
          non_continuous_meds->qual[med].admins[admin].vital_signs[vitalsign].unit
          SET reply->scheduled_orders[schedmed].admins[admin].vital_signs[vitalsign].normalcy_cd =
          non_continuous_meds->qual[med].admins[admin].vital_signs[vitalsign].normalcy_cd
        ENDFOR
        SET commentcnt = size(non_continuous_meds->qual[med].admins[admin].comments,5)
        SET stat = alterlist(reply->scheduled_orders[schedmed].admins[admin].comments,commentcnt)
        FOR (comment = 1 TO commentcnt)
          SET reply->scheduled_orders[schedmed].admins[admin].comments[comment].comment_type =
          non_continuous_meds->qual[med].admins[admin].comments[comment].comment_type
          SET reply->scheduled_orders[schedmed].admins[admin].comments[comment].text =
          non_continuous_meds->qual[med].admins[admin].comments[comment].text
          SET reply->scheduled_orders[schedmed].admins[admin].comments[comment].commenter_id =
          non_continuous_meds->qual[med].admins[admin].comments[comment].commenter_id
          SET reply->scheduled_orders[schedmed].admins[admin].comments[comment].note_dt_tm =
          non_continuous_meds->qual[med].admins[admin].comments[comment].note_dt_tm
          SET reply->scheduled_orders[schedmed].admins[admin].comments[comment].format =
          non_continuous_meds->qual[med].admins[admin].comments[comment].format
        ENDFOR
      ENDFOR
     ELSEIF ((non_continuous_meds->qual[med].is_unsched=1))
      SET unschedmed = (unschedmed+ 1)
      SET reply->unscheduled_orders[unschedmed].template_order_id = non_continuous_meds->qual[med].
      template_order_id
      SET reply->unscheduled_orders[unschedmed].orig_order_dt_tm = non_continuous_meds->qual[med].
      orig_order_dt_tm
      SET reply->unscheduled_orders[unschedmed].orig_order_tz = non_continuous_meds->qual[med].
      orig_order_tz
      SET reply->unscheduled_orders[unschedmed].mnemonic = non_continuous_meds->qual[med].mnemonic
      SET reply->unscheduled_orders[unschedmed].ordered_as_mnemonic = non_continuous_meds->qual[med].
      ordered_as_mnemonic
      SET reply->unscheduled_orders[unschedmed].hna_mnemonic = non_continuous_meds->qual[med].
      hna_mnemonic
      SET reply->unscheduled_orders[unschedmed].voided_ind = non_continuous_meds->qual[med].
      voided_ind
      SET stat = alterlist(reply->unscheduled_orders[unschedmed].core_actions,actioncnt)
      FOR (action = 1 TO actioncnt)
        SET reply->unscheduled_orders[unschedmed].core_actions[action].order_id = non_continuous_meds
        ->qual[med].core_actions[action].order_id
        SET reply->unscheduled_orders[unschedmed].core_actions[action].action_seq =
        non_continuous_meds->qual[med].core_actions[action].action_seq
        SET reply->unscheduled_orders[unschedmed].core_actions[action].action = non_continuous_meds->
        qual[med].core_actions[action].action
        SET reply->unscheduled_orders[unschedmed].core_actions[action].action_dt_tm =
        non_continuous_meds->qual[med].core_actions[action].action_dt_tm
        SET reply->unscheduled_orders[unschedmed].core_actions[action].action_tz =
        non_continuous_meds->qual[med].core_actions[action].action_tz
        SET reply->unscheduled_orders[unschedmed].core_actions[action].clinical_display_line =
        non_continuous_meds->qual[med].core_actions[action].clinical_display_line
        SET reply->unscheduled_orders[unschedmed].core_actions[action].detail_value =
        non_continuous_meds->qual[med].core_actions[action].detail_value
        SET reply->unscheduled_orders[unschedmed].core_actions[action].detail_assigned =
        non_continuous_meds->qual[med].core_actions[action].detail_assigned
      ENDFOR
      SET stat = alterlist(reply->unscheduled_orders[unschedmed].admins,admincnt)
      FOR (admin = 1 TO admincnt)
        SET reply->unscheduled_orders[unschedmed].admins[admin].order_id = non_continuous_meds->qual[
        med].admins[admin].order_id
        SET reply->unscheduled_orders[unschedmed].admins[admin].parent_event_id = non_continuous_meds
        ->qual[med].admins[admin].parent_event_id
        SET reply->unscheduled_orders[unschedmed].admins[admin].event_id = non_continuous_meds->qual[
        med].admins[admin].event_id
        SET reply->unscheduled_orders[unschedmed].admins[admin].verified_dt_tm = non_continuous_meds
        ->qual[med].admins[admin].verified_dt_tm
        SET reply->unscheduled_orders[unschedmed].admins[admin].verified_tz = non_continuous_meds->
        qual[med].admins[admin].verified_tz
        SET reply->unscheduled_orders[unschedmed].admins[admin].verified_prsnl_id =
        non_continuous_meds->qual[med].admins[admin].verified_prsnl_id
        SET reply->unscheduled_orders[unschedmed].admins[admin].valid_from_dt_tm =
        non_continuous_meds->qual[med].admins[admin].valid_from_dt_tm
        SET reply->unscheduled_orders[unschedmed].admins[admin].event_title_text =
        non_continuous_meds->qual[med].admins[admin].event_title_text
        SET reply->unscheduled_orders[unschedmed].admins[admin].event_end_dt_tm = non_continuous_meds
        ->qual[med].admins[admin].event_end_dt_tm
        SET reply->unscheduled_orders[unschedmed].admins[admin].event_end_tz = non_continuous_meds->
        qual[med].admins[admin].event_end_tz
        SET reply->unscheduled_orders[unschedmed].admins[admin].result_status_meaning =
        non_continuous_meds->qual[med].admins[admin].result_status_meaning
        SET reply->unscheduled_orders[unschedmed].admins[admin].result_status_display =
        non_continuous_meds->qual[med].admins[admin].result_status_display
        SET reply->unscheduled_orders[unschedmed].admins[admin].not_given_reason =
        non_continuous_meds->qual[med].admins[admin].not_given_reason
        SET reply->unscheduled_orders[unschedmed].admins[admin].admin_start_dt_tm =
        non_continuous_meds->qual[med].admins[admin].admin_start_dt_tm
        SET reply->unscheduled_orders[unschedmed].admins[admin].admin_start_tz = non_continuous_meds
        ->qual[med].admins[admin].admin_start_tz
        SET reply->unscheduled_orders[unschedmed].admins[admin].dosage_value = non_continuous_meds->
        qual[med].admins[admin].dosage_value
        SET reply->unscheduled_orders[unschedmed].admins[admin].dosage_unit = non_continuous_meds->
        qual[med].admins[admin].dosage_unit
        SET reply->unscheduled_orders[unschedmed].admins[admin].site = non_continuous_meds->qual[med]
        .admins[admin].site
        SET reply->unscheduled_orders[unschedmed].admins[admin].admin_by_id = non_continuous_meds->
        qual[med].admins[admin].admin_by_id
        SET reply->unscheduled_orders[unschedmed].admins[admin].route = non_continuous_meds->qual[med
        ].admins[admin].route
        SET vitalsigncnt = size(non_continuous_meds->qual[med].admins[admin].vital_signs,5)
        SET stat = alterlist(reply->unscheduled_orders[unschedmed].admins[admin].vital_signs,
         vitalsigncnt)
        FOR (vitalsign = 1 TO vitalsigncnt)
          SET reply->unscheduled_orders[unschedmed].admins[admin].vital_signs[vitalsign].event_id =
          non_continuous_meds->qual[med].admins[admin].vital_signs[vitalsign].event_id
          SET reply->unscheduled_orders[unschedmed].admins[admin].vital_signs[vitalsign].vital_sign
           = non_continuous_meds->qual[med].admins[admin].vital_signs[vitalsign].vital_sign
          SET reply->unscheduled_orders[unschedmed].admins[admin].vital_signs[vitalsign].value =
          non_continuous_meds->qual[med].admins[admin].vital_signs[vitalsign].value
          SET reply->unscheduled_orders[unschedmed].admins[admin].vital_signs[vitalsign].unit =
          non_continuous_meds->qual[med].admins[admin].vital_signs[vitalsign].unit
          SET reply->unscheduled_orders[unschedmed].admins[admin].vital_signs[vitalsign].normalcy_cd
           = non_continuous_meds->qual[med].admins[admin].vital_signs[vitalsign].normalcy_cd
        ENDFOR
        SET commentcnt = size(non_continuous_meds->qual[med].admins[admin].comments,5)
        SET stat = alterlist(reply->unscheduled_orders[unschedmed].admins[admin].comments,commentcnt)
        FOR (comment = 1 TO commentcnt)
          SET reply->unscheduled_orders[unschedmed].admins[admin].comments[comment].comment_type =
          non_continuous_meds->qual[med].admins[admin].comments[comment].comment_type
          SET reply->unscheduled_orders[unschedmed].admins[admin].comments[comment].text =
          non_continuous_meds->qual[med].admins[admin].comments[comment].text
          SET reply->unscheduled_orders[unschedmed].admins[admin].comments[comment].commenter_id =
          non_continuous_meds->qual[med].admins[admin].comments[comment].commenter_id
          SET reply->unscheduled_orders[unschedmed].admins[admin].comments[comment].note_dt_tm =
          non_continuous_meds->qual[med].admins[admin].comments[comment].note_dt_tm
          SET reply->unscheduled_orders[unschedmed].admins[admin].comments[comment].format =
          non_continuous_meds->qual[med].admins[admin].comments[comment].format
        ENDFOR
      ENDFOR
     ELSEIF ((non_continuous_meds->qual[med].is_prn=1))
      SET prnmed = (prnmed+ 1)
      SET reply->prn_orders[prnmed].template_order_id = non_continuous_meds->qual[med].
      template_order_id
      SET reply->prn_orders[prnmed].orig_order_dt_tm = non_continuous_meds->qual[med].
      orig_order_dt_tm
      SET reply->prn_orders[prnmed].orig_order_tz = non_continuous_meds->qual[med].orig_order_tz
      SET reply->prn_orders[prnmed].mnemonic = non_continuous_meds->qual[med].mnemonic
      SET reply->prn_orders[prnmed].ordered_as_mnemonic = non_continuous_meds->qual[med].
      ordered_as_mnemonic
      SET reply->prn_orders[prnmed].hna_mnemonic = non_continuous_meds->qual[med].hna_mnemonic
      SET reply->prn_orders[prnmed].voided_ind = non_continuous_meds->qual[med].voided_ind
      SET stat = alterlist(reply->prn_orders[prnmed].core_actions,actioncnt)
      FOR (action = 1 TO actioncnt)
        SET reply->prn_orders[prnmed].core_actions[action].order_id = non_continuous_meds->qual[med].
        core_actions[action].order_id
        SET reply->prn_orders[prnmed].core_actions[action].action_seq = non_continuous_meds->qual[med
        ].core_actions[action].action_seq
        SET reply->prn_orders[prnmed].core_actions[action].action = non_continuous_meds->qual[med].
        core_actions[action].action
        SET reply->prn_orders[prnmed].core_actions[action].action_dt_tm = non_continuous_meds->qual[
        med].core_actions[action].action_dt_tm
        SET reply->prn_orders[prnmed].core_actions[action].action_tz = non_continuous_meds->qual[med]
        .core_actions[action].action_tz
        SET reply->prn_orders[prnmed].core_actions[action].clinical_display_line =
        non_continuous_meds->qual[med].core_actions[action].clinical_display_line
        SET reply->prn_orders[prnmed].core_actions[action].detail_value = non_continuous_meds->qual[
        med].core_actions[action].detail_value
        SET reply->prn_orders[prnmed].core_actions[action].detail_assigned = non_continuous_meds->
        qual[med].core_actions[action].detail_assigned
      ENDFOR
      SET stat = alterlist(reply->prn_orders[prnmed].admins,admincnt)
      FOR (admin = 1 TO admincnt)
        SET reply->prn_orders[prnmed].admins[admin].order_id = non_continuous_meds->qual[med].admins[
        admin].order_id
        SET reply->prn_orders[prnmed].admins[admin].parent_event_id = non_continuous_meds->qual[med].
        admins[admin].parent_event_id
        SET reply->prn_orders[prnmed].admins[admin].event_id = non_continuous_meds->qual[med].admins[
        admin].event_id
        SET reply->prn_orders[prnmed].admins[admin].verified_dt_tm = non_continuous_meds->qual[med].
        admins[admin].verified_dt_tm
        SET reply->prn_orders[prnmed].admins[admin].verified_tz = non_continuous_meds->qual[med].
        admins[admin].verified_tz
        SET reply->prn_orders[prnmed].admins[admin].verified_prsnl_id = non_continuous_meds->qual[med
        ].admins[admin].verified_prsnl_id
        SET reply->prn_orders[prnmed].admins[admin].valid_from_dt_tm = non_continuous_meds->qual[med]
        .admins[admin].valid_from_dt_tm
        SET reply->prn_orders[prnmed].admins[admin].event_title_text = non_continuous_meds->qual[med]
        .admins[admin].event_title_text
        SET reply->prn_orders[prnmed].admins[admin].event_end_dt_tm = non_continuous_meds->qual[med].
        admins[admin].event_end_dt_tm
        SET reply->prn_orders[prnmed].admins[admin].event_end_tz = non_continuous_meds->qual[med].
        admins[admin].event_end_tz
        SET reply->prn_orders[prnmed].admins[admin].result_status_meaning = non_continuous_meds->
        qual[med].admins[admin].result_status_meaning
        SET reply->prn_orders[prnmed].admins[admin].result_status_display = non_continuous_meds->
        qual[med].admins[admin].result_status_display
        SET reply->prn_orders[prnmed].admins[admin].not_given_reason = non_continuous_meds->qual[med]
        .admins[admin].not_given_reason
        SET reply->prn_orders[prnmed].admins[admin].admin_start_dt_tm = non_continuous_meds->qual[med
        ].admins[admin].admin_start_dt_tm
        SET reply->prn_orders[prnmed].admins[admin].admin_start_tz = non_continuous_meds->qual[med].
        admins[admin].admin_start_tz
        SET reply->prn_orders[prnmed].admins[admin].dosage_value = non_continuous_meds->qual[med].
        admins[admin].dosage_value
        SET reply->prn_orders[prnmed].admins[admin].dosage_unit = non_continuous_meds->qual[med].
        admins[admin].dosage_unit
        SET reply->prn_orders[prnmed].admins[admin].site = non_continuous_meds->qual[med].admins[
        admin].site
        SET reply->prn_orders[prnmed].admins[admin].admin_by_id = non_continuous_meds->qual[med].
        admins[admin].admin_by_id
        SET reply->prn_orders[prnmed].admins[admin].route = non_continuous_meds->qual[med].admins[
        admin].route
        SET vitalsigncnt = size(non_continuous_meds->qual[med].admins[admin].vital_signs,5)
        SET stat = alterlist(reply->prn_orders[prnmed].admins[admin].vital_signs,vitalsigncnt)
        FOR (vitalsign = 1 TO vitalsigncnt)
          SET reply->prn_orders[prnmed].admins[admin].vital_signs[vitalsign].event_id =
          non_continuous_meds->qual[med].admins[admin].vital_signs[vitalsign].event_id
          SET reply->prn_orders[prnmed].admins[admin].vital_signs[vitalsign].vital_sign =
          non_continuous_meds->qual[med].admins[admin].vital_signs[vitalsign].vital_sign
          SET reply->prn_orders[prnmed].admins[admin].vital_signs[vitalsign].value =
          non_continuous_meds->qual[med].admins[admin].vital_signs[vitalsign].value
          SET reply->prn_orders[prnmed].admins[admin].vital_signs[vitalsign].unit =
          non_continuous_meds->qual[med].admins[admin].vital_signs[vitalsign].unit
          SET reply->prn_orders[prnmed].admins[admin].vital_signs[vitalsign].normalcy_cd =
          non_continuous_meds->qual[med].admins[admin].vital_signs[vitalsign].normalcy_cd
        ENDFOR
        SET commentcnt = size(non_continuous_meds->qual[med].admins[admin].comments,5)
        SET stat = alterlist(reply->prn_orders[prnmed].admins[admin].comments,commentcnt)
        FOR (comment = 1 TO commentcnt)
          SET reply->prn_orders[prnmed].admins[admin].comments[comment].comment_type =
          non_continuous_meds->qual[med].admins[admin].comments[comment].comment_type
          SET reply->prn_orders[prnmed].admins[admin].comments[comment].text = non_continuous_meds->
          qual[med].admins[admin].comments[comment].text
          SET reply->prn_orders[prnmed].admins[admin].comments[comment].commenter_id =
          non_continuous_meds->qual[med].admins[admin].comments[comment].commenter_id
          SET reply->prn_orders[prnmed].admins[admin].comments[comment].note_dt_tm =
          non_continuous_meds->qual[med].admins[admin].comments[comment].note_dt_tm
          SET reply->prn_orders[prnmed].admins[admin].comments[comment].format = non_continuous_meds
          ->qual[med].admins[admin].comments[comment].format
        ENDFOR
      ENDFOR
     ENDIF
   ENDFOR
   FREE RECORD non_continuous_meds
   SET totalmedcnt = size(continuous_meds->qual,5)
   SET stat = alterlist(reply->continuous_orders,totalmedcnt)
   FOR (med = 1 TO totalmedcnt)
     SET actioncnt = size(continuous_meds->qual[med].core_actions,5)
     SET admincnt = size(continuous_meds->qual[med].admins,5)
     SET reply->continuous_orders[med].order_id = continuous_meds->qual[med].order_id
     SET reply->continuous_orders[med].orig_order_dt_tm = continuous_meds->qual[med].orig_order_dt_tm
     SET reply->continuous_orders[med].orig_order_tz = continuous_meds->qual[med].orig_order_tz
     SET reply->continuous_orders[med].mnemonic = continuous_meds->qual[med].mnemonic
     SET reply->continuous_orders[med].ordered_as_mnemonic = continuous_meds->qual[med].
     ordered_as_mnemonic
     SET reply->continuous_orders[med].hna_mnemonic = continuous_meds->qual[med].hna_mnemonic
     SET reply->continuous_orders[med].voided_ind = continuous_meds->qual[med].voided_ind
     SET stat = alterlist(reply->continuous_orders[med].core_actions,actioncnt)
     FOR (action = 1 TO actioncnt)
       SET reply->continuous_orders[med].core_actions[action].action_seq = continuous_meds->qual[med]
       .core_actions[action].action_seq
       SET reply->continuous_orders[med].core_actions[action].action = continuous_meds->qual[med].
       core_actions[action].action
       SET reply->continuous_orders[med].core_actions[action].action_dt_tm = continuous_meds->qual[
       med].core_actions[action].action_dt_tm
       SET reply->continuous_orders[med].core_actions[action].action_tz = continuous_meds->qual[med].
       core_actions[action].action_tz
       SET reply->continuous_orders[med].core_actions[action].clinical_display_line = continuous_meds
       ->qual[med].core_actions[action].clinical_display_line
     ENDFOR
     SET stat = alterlist(reply->continuous_orders[med].admins,admincnt)
     FOR (admin = 1 TO admincnt)
       SET reply->continuous_orders[med].admins[admin].parent_event_id = continuous_meds->qual[med].
       admins[admin].parent_event_id
       SET reply->continuous_orders[med].admins[admin].event_id = continuous_meds->qual[med].admins[
       admin].event_id
       SET reply->continuous_orders[med].admins[admin].verified_dt_tm = continuous_meds->qual[med].
       admins[admin].verified_dt_tm
       SET reply->continuous_orders[med].admins[admin].verified_tz = continuous_meds->qual[med].
       admins[admin].verified_tz
       SET reply->continuous_orders[med].admins[admin].verified_prsnl_id = continuous_meds->qual[med]
       .admins[admin].verified_prsnl_id
       SET reply->continuous_orders[med].admins[admin].valid_from_dt_tm = continuous_meds->qual[med].
       admins[admin].valid_from_dt_tm
       SET reply->continuous_orders[med].admins[admin].event_title_text = continuous_meds->qual[med].
       admins[admin].event_title_text
       SET reply->continuous_orders[med].admins[admin].event_end_dt_tm = continuous_meds->qual[med].
       admins[admin].event_end_dt_tm
       SET reply->continuous_orders[med].admins[admin].event_end_tz = continuous_meds->qual[med].
       admins[admin].event_end_tz
       SET reply->continuous_orders[med].admins[admin].result_status_meaning = continuous_meds->qual[
       med].admins[admin].result_status_meaning
       SET reply->continuous_orders[med].admins[admin].result_status_display = continuous_meds->qual[
       med].admins[admin].result_status_display
       SET reply->continuous_orders[med].admins[admin].not_given_reason = continuous_meds->qual[med].
       admins[admin].not_given_reason
       SET reply->continuous_orders[med].admins[admin].iv_event_meaning = continuous_meds->qual[med].
       admins[admin].iv_event_meaning
       SET reply->continuous_orders[med].admins[admin].iv_event_display = continuous_meds->qual[med].
       admins[admin].iv_event_display
       SET reply->continuous_orders[med].admins[admin].admin_start_dt_tm = continuous_meds->qual[med]
       .admins[admin].admin_start_dt_tm
       SET reply->continuous_orders[med].admins[admin].admin_start_tz = continuous_meds->qual[med].
       admins[admin].admin_start_tz
       SET reply->continuous_orders[med].admins[admin].init_dosage = continuous_meds->qual[med].
       admins[admin].init_dosage
       SET reply->continuous_orders[med].admins[admin].admin_dosage = continuous_meds->qual[med].
       admins[admin].admin_dosage
       SET reply->continuous_orders[med].admins[admin].dosage_unit = continuous_meds->qual[med].
       admins[admin].dosage_unit
       SET reply->continuous_orders[med].admins[admin].initial_volume = continuous_meds->qual[med].
       admins[admin].initial_volume
       SET reply->continuous_orders[med].admins[admin].infusion_rate = continuous_meds->qual[med].
       admins[admin].infusion_rate
       SET reply->continuous_orders[med].admins[admin].infusion_unit = continuous_meds->qual[med].
       admins[admin].infusion_unit
       SET reply->continuous_orders[med].admins[admin].site = continuous_meds->qual[med].admins[admin
       ].site
       SET reply->continuous_orders[med].admins[admin].admin_by_id = continuous_meds->qual[med].
       admins[admin].admin_by_id
       SET reply->continuous_orders[med].admins[admin].route = continuous_meds->qual[med].admins[
       admin].route
       SET commentcnt = size(continuous_meds->qual[med].admins[admin].comments,5)
       SET stat = alterlist(reply->continuous_orders[med].admins[admin].comments,commentcnt)
       FOR (comment = 1 TO commentcnt)
         SET reply->continuous_orders[med].admins[admin].comments[comment].comment_type =
         continuous_meds->qual[med].admins[admin].comments[comment].comment_type
         SET reply->continuous_orders[med].admins[admin].comments[comment].text = continuous_meds->
         qual[med].admins[admin].comments[comment].text
         SET reply->continuous_orders[med].admins[admin].comments[comment].commenter_id =
         continuous_meds->qual[med].admins[admin].comments[comment].commenter_id
         SET reply->continuous_orders[med].admins[admin].comments[comment].note_dt_tm =
         continuous_meds->qual[med].admins[admin].comments[comment].note_dt_tm
         SET reply->continuous_orders[med].admins[admin].comments[comment].format = continuous_meds->
         qual[med].admins[admin].comments[comment].format
       ENDFOR
     ENDFOR
   ENDFOR
   FREE RECORD continuous_meds
 END ;Subroutine
 SUBROUTINE checkforerror(qual_num,op_name,force_exit)
   IF (qual_num=0)
    SET errorcode = error(errmsg,0)
    IF (errorcode != 0)
     SET reply->status_data.status = "F"
     SET reply->status_data.operationname = op_name
     SET reply->status_data.operationstatus = "F"
     SET reply->status_data.targetobjectname = "ErrorMessage"
     SET reply->status_data.targetobjectvalue = errmsg
     GO TO exit_script
    ELSEIF (force_exit=1)
     SET reply->status_data.status = "Z"
     SET reply->status_data.operationname = op_name
     SET reply->status_data.operationstatus = "Z"
     SET reply->status_data.targetobjectname = "Qualifications"
     SET reply->status_data.targetobjectvalue = "No matching records"
     GO TO exit_script
    ENDIF
   ENDIF
 END ;Subroutine
#exit_script
END GO
