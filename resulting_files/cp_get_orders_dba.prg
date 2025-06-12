CREATE PROGRAM cp_get_orders:dba
 RECORD reply(
   1 orders[*]
     2 order_id = f8
     2 activity_type_cd = f8
     2 activity_type_disp = vc
     2 catalog_cd = f8
     2 catalog_disp = vc
     2 catalog_type_cd = f8
     2 catalog_type_disp = vc
     2 clinical_display_line = vc
     2 current_start_dt_tm = dq8
     2 current_start_tz = i4
     2 dept_status_cd = f8
     2 dept_status_disp = vc
     2 discontinue_effective_dt_tm = dq8
     2 discontinue_effective_tz = i4
     2 hna_order_mnemonic = vc
     2 med_order_type_cd = f8
     2 med_order_type_disp = vc
     2 ordered_as_mnemonic = vc
     2 order_detail_display_line = vc
     2 order_mnemonic = vc
     2 order_status_cd = f8
     2 order_status_disp = vc
     2 orig_order_dt_tm = dq8
     2 orig_order_tz = i4
     2 orig_ord_as_flag = i2
     2 last_update_provider_id = f8
     2 ingredient_list = vc
     2 actions[*]
       3 action_dt_tm = dq8
       3 action_tz = i4
       3 action_personnel_id = f8
       3 action_type_cd = f8
       3 action_type_disp = vc
       3 clinical_display_line = vc
       3 communication_type_cd = f8
       3 communication_type_disp = vc
       3 dept_status_cd = f8
       3 dept_status_disp = vc
       3 order_detail_display_line = vc
       3 order_dt_tm = dq8
       3 order_tz = i4
       3 order_provider_id = f8
       3 order_status_cd = f8
       3 order_status_disp = vc
       3 simplified_display_line = vc
       3 supervising_provider_id = f8
     2 details[*]
       3 display_line = vc
       3 cancel_reason = vc
     2 comments[*]
       3 comment_text = vc
     2 review[*]
       3 review_prsnl[*]
         4 provider_id = f8
         4 proxy_personnel_id = f8
         4 proxy_reason_cd = f8
         4 proxy_reason_disp = vc
         4 reject_reason_cd = f8
         4 reject_reason_disp = vc
         4 reviewed_status_flag = i2
         4 review_dt_tm = dq8
         4 review_tz = i4
         4 review_personnel_id = f8
         4 review_type_flag = i2
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
 DECLARE log_program_name = vc WITH protect, noconstant("")
 DECLARE log_override_ind = i2 WITH protect, noconstant(0)
 SET log_program_name = curprog
 SET log_override_ind = 0
 DECLARE log_level_error = i2 WITH protect, noconstant(0)
 DECLARE log_level_warning = i2 WITH protect, noconstant(1)
 DECLARE log_level_audit = i2 WITH protect, noconstant(2)
 DECLARE log_level_info = i2 WITH protect, noconstant(3)
 DECLARE log_level_debug = i2 WITH protect, noconstant(4)
 DECLARE hsys = i4 WITH protect, noconstant(0)
 DECLARE sysstat = i4 WITH protect, noconstant(0)
 DECLARE serrmsg = c132 WITH protect, noconstant(" ")
 DECLARE ierrcode = i4 WITH protect, noconstant(error(serrmsg,1))
 DECLARE crsl_msg_default = h WITH protect, noconstant(0)
 DECLARE crsl_msg_level = h WITH protect, noconstant(0)
 EXECUTE msgrtl
 SET crsl_msg_default = uar_msgdefhandle()
 SET crsl_msg_level = uar_msggetlevel(crsl_msg_default)
 DECLARE lcrslsubeventcnt = i4 WITH protect, noconstant(0)
 DECLARE icrslloggingstat = i2 WITH protect, noconstant(0)
 DECLARE lcrslsubeventsize = i4 WITH protect, noconstant(0)
 DECLARE icrslloglvloverrideind = i2 WITH protect, noconstant(0)
 DECLARE scrsllogtext = vc WITH protect, noconstant("")
 DECLARE scrsllogevent = vc WITH protect, noconstant("")
 DECLARE icrslholdloglevel = i2 WITH protect, noconstant(0)
 DECLARE icrslerroroccured = i2 WITH protect, noconstant(0)
 DECLARE lcrsluarmsgwritestat = i4 WITH protect, noconstant(0)
 DECLARE crsl_info_domain = vc WITH protect, constant("CLINRPT SCRIPT LOGGING")
 DECLARE crsl_logging_on = c1 WITH protect, constant("L")
 SELECT INTO "nl:"
  FROM dm_info dm
  PLAN (dm
   WHERE dm.info_domain=crsl_info_domain
    AND dm.info_name=curprog)
  DETAIL
   IF (dm.info_char=crsl_logging_on)
    log_override_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SUBROUTINE (log_message(logmsg=vc,loglvl=i4) =null)
   SET icrslloglvloverrideind = 0
   SET scrsllogtext = ""
   SET scrsllogevent = ""
   SET scrsllogtext = concat("{{Script::",value(log_program_name),"}} ",logmsg)
   IF (log_override_ind=0)
    SET icrslholdloglevel = loglvl
   ELSE
    IF (crsl_msg_level < loglvl)
     SET icrslholdloglevel = crsl_msg_level
     SET icrslloglvloverrideind = 1
    ELSE
     SET icrslholdloglevel = loglvl
    ENDIF
   ENDIF
   IF (icrslloglvloverrideind=1)
    SET scrsllogevent = "Script_Override"
   ELSE
    CASE (icrslholdloglevel)
     OF log_level_error:
      SET scrsllogevent = "Script_Error"
     OF log_level_warning:
      SET scrsllogevent = "Script_Warning"
     OF log_level_audit:
      SET scrsllogevent = "Script_Audit"
     OF log_level_info:
      SET scrsllogevent = "Script_Info"
     OF log_level_debug:
      SET scrsllogevent = "Script_Debug"
    ENDCASE
   ENDIF
   SET lcrsluarmsgwritestat = uar_msgwrite(crsl_msg_default,0,nullterm(scrsllogevent),
    icrslholdloglevel,nullterm(scrsllogtext))
   CALL echo(logmsg)
 END ;Subroutine
 SUBROUTINE (error_message(logstatusblockind=i2) =i2)
   SET icrslerroroccured = 0
   SET ierrcode = error(serrmsg,0)
   WHILE (ierrcode > 0)
     SET icrslerroroccured = 1
     SET reply->status_data.status = "F"
     CALL log_message(serrmsg,log_level_audit)
     IF (logstatusblockind=1)
      CALL populate_subeventstatus("EXECUTE","F","CCL SCRIPT",serrmsg)
     ENDIF
     SET ierrcode = error(serrmsg,0)
   ENDWHILE
   RETURN(icrslerroroccured)
 END ;Subroutine
 SUBROUTINE (error_and_zero_check(qualnum=i4,opname=vc,logmsg=vc,errorforceexit=i2,zeroforceexit=i2
  ) =i2)
   SET icrslerroroccured = 0
   SET ierrcode = error(serrmsg,0)
   WHILE (ierrcode > 0)
     SET icrslerroroccured = 1
     CALL log_message(serrmsg,log_level_audit)
     CALL populate_subeventstatus(opname,"F",serrmsg,logmsg)
     SET ierrcode = error(serrmsg,0)
   ENDWHILE
   IF (icrslerroroccured=1
    AND errorforceexit=1)
    SET reply->status_data.status = "F"
    GO TO exit_script
   ENDIF
   IF (qualnum=0
    AND zeroforceexit=1)
    SET reply->status_data.status = "Z"
    CALL populate_subeventstatus(opname,"Z","No records qualified",logmsg)
    GO TO exit_script
   ENDIF
   RETURN(icrslerroroccured)
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value)) =i2)
   IF (validate(reply->status_data.status,"-1") != "-1")
    SET lcrslsubeventcnt = size(reply->status_data.subeventstatus,5)
    SET lcrslsubeventsize = size(trim(reply->status_data.subeventstatus[lcrslsubeventcnt].
      operationname))
    SET lcrslsubeventsize += size(trim(reply->status_data.subeventstatus[lcrslsubeventcnt].
      operationstatus))
    SET lcrslsubeventsize += size(trim(reply->status_data.subeventstatus[lcrslsubeventcnt].
      targetobjectname))
    SET lcrslsubeventsize += size(trim(reply->status_data.subeventstatus[lcrslsubeventcnt].
      targetobjectvalue))
    IF (lcrslsubeventsize > 0)
     SET lcrslsubeventcnt += 1
     SET icrslloggingstat = alter(reply->status_data.subeventstatus,lcrslsubeventcnt)
    ENDIF
    SET reply->status_data.subeventstatus[lcrslsubeventcnt].operationname = substring(1,25,
     operationname)
    SET reply->status_data.subeventstatus[lcrslsubeventcnt].operationstatus = substring(1,1,
     operationstatus)
    SET reply->status_data.subeventstatus[lcrslsubeventcnt].targetobjectname = substring(1,25,
     targetobjectname)
    SET reply->status_data.subeventstatus[lcrslsubeventcnt].targetobjectvalue = targetobjectvalue
   ENDIF
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus_msg(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value),loglevel=i2(value)) =i2)
  CALL populate_subeventstatus(operationname,operationstatus,targetobjectname,targetobjectvalue)
  CALL log_message(targetobjectvalue,loglevel)
 END ;Subroutine
 SUBROUTINE (check_log_level(arg_log_level=i4) =i2)
   IF (((crsl_msg_level >= arg_log_level) OR (log_override_ind=1)) )
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SET log_program_name = "CP_GET_ORDERS"
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
 DECLARE everybag_cd = f8
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
 SET stat = uar_get_meaning_by_codeset(4004,"EVERYBAG",1,everybag_cd)
 DECLARE action_begin_dt_tm = q8
 DECLARE action_end_dt_tm = q8
 DECLARE order_suppress_meds_rx_bitpos = i2 WITH constant(0)
 DECLARE order_suppress_meds_hx_bitpos = i2 WITH constant(1)
 DECLARE order_suppress_meds_sat_bitpos = i2 WITH constant(2)
 DECLARE order_suppress_meds_rx = i2 WITH constant(1)
 DECLARE order_suppress_meds_hx = i2 WITH constant(2)
 DECLARE order_suppress_meds_sat = i2 WITH constant(5)
 DECLARE order_suppress_meds_none = i2 WITH constant(- (1))
 DECLARE ordersuppress1 = i2 WITH noconstant(order_suppress_meds_none)
 DECLARE ordersuppress2 = i2 WITH noconstant(order_suppress_meds_none)
 DECLARE ordersuppress3 = i2 WITH noconstant(order_suppress_meds_none)
 DECLARE order_sort_last_action = i2 WITH constant(0)
 DECLARE order_sort_mnemonic = i2 WITH constant(1)
 DECLARE order_sort_orig_order = i2 WITH constant(2)
 DECLARE bind_cnt = i4 WITH constant(50)
 DECLARE i = i4 WITH noconstant(0)
 DECLARE idx = i4 WITH noconstant(0)
 DECLARE idx2 = i4 WITH noconstant(0)
 DECLARE idxstart = i4 WITH noconstant(1)
 DECLARE noptimizedtotal = i4
 DECLARE nrecordsize = i4
 DECLARE buildclauses(null) = null
 DECLARE getprelimorders(null) = null
 DECLARE getorders(null) = null
 CALL log_message("Begin script cp_get_orders",log_level_debug)
 SET reply->status_data.status = "F"
 CALL buildclauses(null)
 CALL getprelimorders(null)
 IF (order_cnt > 0)
  CALL getorders(null)
 ENDIF
 SET reply->status_data.status = "S"
 SUBROUTINE buildclauses(null)
   CALL log_message("In BuildClauses()",log_level_debug)
   CASE (request->scope_flag)
    OF 1:
     SET scope_clause = build("o1.person_id = ",request->person_id)
    OF 2:
     SET scope_clause = build("o1.person_id = ",request->person_id," AND o1.encntr_id = ",request->
      encntr_id)
    OF 3:
     SET scope_clause = build("o1.person_id+0 =",request->person_id," AND o1.encntr_id+0 = ",request
      ->encntr_id," AND o1.order_id IN",
      " (SELECT order_id FROM chart_request_order"," WHERE chart_request_id = request->request_id)")
    OF 4:
     SET scope_clause = build("o1.order_id = aor.order_id"," AND o1.person_id+0 = ",request->
      person_id," AND o1.encntr_id+0 = ",request->encntr_id)
    OF 5:
     SET scope_clause = build("o1.person_id =",request->person_id," AND o1.encntr_id IN",
      " (SELECT encntr_id FROM chart_request_encntr"," WHERE chart_request_id = request->request_id)"
      )
    ELSE
     SET reply->status_data.status = "Z"
     SET reply->status_data.operationname = "Case"
     SET reply->status_data.operationstatus = "Z"
     SET reply->status_data.targetobjectname = "Scope"
     SET reply->status_data.targetobjectvalue = "Scope not supported"
     GO TO exit_script
   ENDCASE
   IF ((request->qual_on_date=1))
    IF ((request->begin_dt_tm > 0))
     SET action_begin_dt_tm = cnvtdatetime(request->begin_dt_tm)
    ELSE
     SET action_begin_dt_tm = cnvtdatetime("01-Jan-1800")
    ENDIF
    IF ((request->end_dt_tm > 0))
     SET action_end_dt_tm = cnvtdatetime(request->end_dt_tm)
    ELSE
     SET action_end_dt_tm = cnvtdatetime("31-Dec-2100 23:59:59.99")
    ENDIF
   ELSE
    SET action_begin_dt_tm = cnvtdatetime("01-Jan-1800")
    SET action_end_dt_tm = cnvtdatetime("31-Dec-2100 23:59:59.99")
   ENDIF
   IF ((request->suppress_meds_flag > 0))
    IF (btest(request->suppress_meds_flag,order_suppress_meds_rx_bitpos))
     SET ordersuppress1 = order_suppress_meds_rx
    ENDIF
    IF (btest(request->suppress_meds_flag,order_suppress_meds_hx_bitpos))
     SET ordersuppress2 = order_suppress_meds_hx
    ENDIF
    IF (btest(request->suppress_meds_flag,order_suppress_meds_sat_bitpos))
     SET ordersuppress3 = order_suppress_meds_sat
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE getprelimorders(null)
   CALL log_message("In GetPrelimOrders()",log_level_debug)
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
       order_cnt += 1
       IF (mod(order_cnt,10)=1)
        stat = alterlist(orders->qual,(order_cnt+ 9))
       ENDIF
       orders->qual[order_cnt].order_id = o1.order_id
      ENDIF
     WITH nocounter
    ;end select
    CALL error_and_zero_check(curqual,"GetPrelimOrders Accession","CP_GET_ORDERS",1,1)
   ELSE
    SELECT
     IF ((request->sort_order_ind=order_sort_orig_order))
      ORDER BY o1.orig_order_dt_tm, o1.order_id
     ELSEIF ((request->sort_order_ind=order_sort_mnemonic))
      ORDER BY ord_mnemon, o1.order_id
     ELSE
      ORDER BY oa.action_dt_tm, o1.order_id
     ENDIF
     DISTINCT INTO "nl:"
     o1.order_id, ord_mnemon = cnvtupper(trim(o1.order_mnemonic))
     FROM orders o1,
      order_action oa
     PLAN (o1
      WHERE parser(scope_clause)
       AND ((o1.order_id+ 0) > 0)
       AND ((o1.template_order_id+ 0)=0)
       AND  NOT (o1.orig_ord_as_flag IN (ordersuppress1, ordersuppress2, ordersuppress3)))
      JOIN (oa
      WHERE oa.order_id=o1.order_id
       AND oa.core_ind=1
       AND ((oa.action_dt_tm+ 0) BETWEEN cnvtdatetime(action_begin_dt_tm) AND cnvtdatetime(
       action_end_dt_tm))
       AND  NOT (oa.action_type_cd IN (add_alias_cd, clear_cd, collection_cd, complete_cd,
      demogchange_cd,
      statuschange_cd, undo_cd)))
     DETAIL
      IF (order_cnt=0)
       IF ( NOT (request->orderset_exclude_ind
        AND band(o1.cs_flag,orderset_name)))
        order_cnt += 1
        IF (mod(order_cnt,10)=1)
         stat = alterlist(orders->qual,(order_cnt+ 9))
        ENDIF
        orders->qual[order_cnt].order_id = o1.order_id
       ENDIF
      ELSEIF (locateval(idx2,1,order_cnt,o1.order_id,orders->qual[idx2].order_id)=0)
       IF ( NOT (request->orderset_exclude_ind
        AND band(o1.cs_flag,orderset_name)))
        order_cnt += 1
        IF (mod(order_cnt,10)=1)
         stat = alterlist(orders->qual,(order_cnt+ 9))
        ENDIF
        orders->qual[order_cnt].order_id = o1.order_id
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    CALL error_and_zero_check(curqual,"GetPrelimOrders","CP_GET_ORDERS",1,1)
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
      order_cnt += 1
      IF (mod(order_cnt,10)=1)
       stat = alterlist(orders->qual,(order_cnt+ 9))
      ENDIF
      orders->qual[order_cnt].order_id = aor.order_id
     WITH nocounter
    ;end select
    CALL error_and_zero_check(curqual,"CE_LINKED_RESULT","CP_GET_ORDERS",1,0)
   ENDIF
   SET stat = alterlist(orders->qual,order_cnt)
 END ;Subroutine
 SUBROUTINE getorders(null)
   CALL log_message("In GetOrders()",log_level_debug)
   SET nrecordsize = order_cnt
   SET noptimizedtotal = (ceil((cnvtreal(nrecordsize)/ bind_cnt)) * bind_cnt)
   SET stat = alterlist(orders->qual,noptimizedtotal)
   FOR (i = (nrecordsize+ 1) TO noptimizedtotal)
     SET orders->qual[i].order_id = orders->qual[nrecordsize].order_id
   ENDFOR
   SELECT INTO "nl:"
    FROM orders o,
     (dummyt d1  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt))))
    PLAN (d1
     WHERE initarray(idxstart,evaluate(d1.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (o
     WHERE expand(idx,idxstart,((idxstart+ bind_cnt) - 1),o.order_id,orders->qual[idx].order_id,
      bind_cnt))
    ORDER BY o.order_id
    HEAD REPORT
     stat = alterlist(reply->orders,order_cnt)
    HEAD o.order_id
     orderidx = locateval(idx2,1,order_cnt,o.order_id,orders->qual[idx2].order_id), reply->orders[
     orderidx].order_id = o.order_id, reply->orders[orderidx].activity_type_cd = o.activity_type_cd,
     reply->orders[orderidx].catalog_cd = o.catalog_cd, reply->orders[orderidx].catalog_type_cd = o
     .catalog_type_cd, reply->orders[orderidx].clinical_display_line = trim(o.clinical_display_line),
     reply->orders[orderidx].current_start_dt_tm = cnvtdatetime(o.current_start_dt_tm), reply->
     orders[orderidx].current_start_tz = o.current_start_tz, reply->orders[orderidx].dept_status_cd
      = o.dept_status_cd,
     reply->orders[orderidx].discontinue_effective_dt_tm = cnvtdatetime(o.discontinue_effective_dt_tm
      ), reply->orders[orderidx].discontinue_effective_tz = o.discontinue_effective_tz, reply->
     orders[orderidx].hna_order_mnemonic = trim(o.hna_order_mnemonic),
     reply->orders[orderidx].med_order_type_cd = o.med_order_type_cd, reply->orders[orderidx].
     ordered_as_mnemonic = trim(o.ordered_as_mnemonic), reply->orders[orderidx].
     order_detail_display_line = trim(o.order_detail_display_line),
     reply->orders[orderidx].order_mnemonic = trim(o.order_mnemonic), reply->orders[orderidx].
     order_status_cd = o.order_status_cd, reply->orders[orderidx].orig_order_dt_tm = cnvtdatetime(o
      .orig_order_dt_tm),
     reply->orders[orderidx].orig_order_tz = o.orig_order_tz, reply->orders[orderidx].
     orig_ord_as_flag = o.orig_ord_as_flag, reply->orders[orderidx].last_update_provider_id = o
     .last_update_provider_id
    DETAIL
     do_nothing = 0
    FOOT REPORT
     do_nothing = 0
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"ORDERS","CP_GET_ORDERS",1,1)
   SELECT INTO "nl:"
    FROM order_action oa,
     (dummyt d1  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt))))
    PLAN (d1
     WHERE initarray(idxstart,evaluate(d1.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (oa
     WHERE expand(idx,idxstart,((idxstart+ bind_cnt) - 1),oa.order_id,orders->qual[idx].order_id,
      bind_cnt))
    ORDER BY oa.order_id, oa.action_sequence
    HEAD REPORT
     my_order_idx = 0, my_action_cnt = 0
    HEAD oa.order_id
     my_order_idx = locateval(idx2,1,order_cnt,oa.order_id,reply->orders[idx2].order_id),
     my_action_cnt = 0
    HEAD oa.action_sequence
     my_action_cnt += 1, stat = alterlist(reply->orders[my_order_idx].actions,my_action_cnt)
    DETAIL
     reply->orders[my_order_idx].actions[my_action_cnt].action_dt_tm = cnvtdatetime(oa.action_dt_tm),
     reply->orders[my_order_idx].actions[my_action_cnt].action_tz = oa.action_tz, reply->orders[
     my_order_idx].actions[my_action_cnt].action_personnel_id = oa.action_personnel_id,
     reply->orders[my_order_idx].actions[my_action_cnt].action_type_cd = oa.action_type_cd, reply->
     orders[my_order_idx].actions[my_action_cnt].clinical_display_line = trim(oa
      .clinical_display_line), reply->orders[my_order_idx].actions[my_action_cnt].
     communication_type_cd = oa.communication_type_cd,
     reply->orders[my_order_idx].actions[my_action_cnt].dept_status_cd = oa.dept_status_cd, reply->
     orders[my_order_idx].actions[my_action_cnt].order_detail_display_line = trim(oa
      .order_detail_display_line), reply->orders[my_order_idx].actions[my_action_cnt].order_dt_tm =
     oa.order_dt_tm,
     reply->orders[my_order_idx].actions[my_action_cnt].order_tz = oa.order_tz, reply->orders[
     my_order_idx].actions[my_action_cnt].order_provider_id = oa.order_provider_id, reply->orders[
     my_order_idx].actions[my_action_cnt].order_status_cd = oa.order_status_cd,
     reply->orders[my_order_idx].actions[my_action_cnt].simplified_display_line = trim(oa
      .simplified_display_line), reply->orders[my_order_idx].actions[my_action_cnt].
     supervising_provider_id = oa.supervising_provider_id
    FOOT  oa.action_sequence
     do_nothing = 0
    FOOT  oa.order_id
     do_nothing = 0
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"ORDER_ACTION","CP_GET_ORDERS",1,1)
   SELECT INTO "nl:"
    FROM order_detail od,
     (dummyt d1  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt))))
    PLAN (d1
     WHERE initarray(idxstart,evaluate(d1.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (od
     WHERE expand(idx,idxstart,((idxstart+ bind_cnt) - 1),od.order_id,orders->qual[idx].order_id,
      bind_cnt)
      AND  NOT (od.oe_field_meaning_id IN (125, 2071, 2094)))
    ORDER BY od.order_id, od.action_sequence, od.detail_sequence
    HEAD REPORT
     my_order_idx = 0, my_action_total = 0
    HEAD od.order_id
     my_order_idx = locateval(idx2,1,order_cnt,od.order_id,reply->orders[idx2].order_id),
     my_action_total = size(reply->orders[idx2].actions,5), stat = alterlist(reply->orders[
      my_order_idx].details,my_action_total),
     detail_cnt = 0, lastfieldid = 0.0
    HEAD od.action_sequence
     reply->orders[my_order_idx].details[od.action_sequence].display_line = ""
    DETAIL
     IF (od.oe_field_meaning_id=1105)
      reply->orders[my_order_idx].details[od.action_sequence].cancel_reason = concat(reply->orders[
       my_order_idx].details[od.action_sequence].cancel_reason,trim(od.oe_field_display_value))
     ENDIF
     IF (trim(od.oe_field_display_value) > "")
      detail_cnt += 1
      IF (detail_cnt=1)
       reply->orders[my_order_idx].details[od.action_sequence].display_line = trim(od
        .oe_field_display_value)
      ELSEIF (od.oe_field_meaning_id=lastfieldid)
       reply->orders[my_order_idx].details[od.action_sequence].display_line = concat(trim(reply->
         orders[my_order_idx].details[od.action_sequence].display_line)," | ",trim(od
         .oe_field_display_value))
      ELSE
       reply->orders[my_order_idx].details[od.action_sequence].display_line = concat(trim(reply->
         orders[my_order_idx].details[od.action_sequence].display_line),", ",trim(od
         .oe_field_display_value))
      ENDIF
     ENDIF
     lastfieldid = od.oe_field_meaning_id
    FOOT  od.action_sequence
     lastfieldid = 0.0, detail_cnt = 0
    FOOT  od.order_id
     do_nothing = 0
    FOOT REPORT
     do_nothing = 0
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"ORDER_DETAIL","CP_GET_ORDERS",1,0)
   SELECT INTO "nl:"
    FROM order_comment oc,
     long_text lt,
     (dummyt d1  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt))))
    PLAN (d1
     WHERE initarray(idxstart,evaluate(d1.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (oc
     WHERE expand(idx,idxstart,((idxstart+ bind_cnt) - 1),oc.order_id,orders->qual[idx].order_id,
      bind_cnt)
      AND oc.comment_type_cd=order_cmnt_cd)
     JOIN (lt
     WHERE lt.long_text_id=oc.long_text_id
      AND lt.long_text_id > 0)
    ORDER BY oc.order_id, oc.action_sequence
    HEAD REPORT
     my_order_idx = 0, my_action_total = 0, my_comment_cnt = 0
    HEAD oc.order_id
     my_order_idx = locateval(idx2,1,order_cnt,oc.order_id,reply->orders[idx2].order_id),
     my_action_total = size(reply->orders[idx2].actions,5), stat = alterlist(reply->orders[
      my_order_idx].comments,my_action_total)
    DETAIL
     reply->orders[my_order_idx].comments[oc.action_sequence].comment_text = lt.long_text
    FOOT  oc.order_id
     do_nothing = 0
    FOOT REPORT
     do_nothing = 0
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"ORDER_COMMENT","CP_GET_ORDERS",1,0)
   SELECT INTO "nl:"
    FROM order_review orv,
     (dummyt d1  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt))))
    PLAN (d1
     WHERE initarray(idxstart,evaluate(d1.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (orv
     WHERE expand(idx,idxstart,((idxstart+ bind_cnt) - 1),orv.order_id,orders->qual[idx].order_id,
      bind_cnt))
    ORDER BY orv.order_id, orv.action_sequence, orv.review_sequence
    HEAD REPORT
     my_order_idx = 0, my_action_total = 0
    HEAD orv.order_id
     my_order_idx = locateval(idx2,1,order_cnt,orv.order_id,reply->orders[idx2].order_id),
     my_action_total = size(reply->orders[idx2].actions,5), stat = alterlist(reply->orders[
      my_order_idx].review,my_action_total)
    HEAD orv.action_sequence
     my_review_cnt = 0
    HEAD orv.review_sequence
     do_nothing = 0
    DETAIL
     my_review_cnt += 1, stat = alterlist(reply->orders[my_order_idx].review[orv.action_sequence].
      review_prsnl,my_review_cnt), reply->orders[my_order_idx].review[orv.action_sequence].
     review_prsnl[my_review_cnt].provider_id = orv.provider_id,
     reply->orders[my_order_idx].review[orv.action_sequence].review_prsnl[my_review_cnt].
     proxy_personnel_id = orv.proxy_personnel_id, reply->orders[my_order_idx].review[orv
     .action_sequence].review_prsnl[my_review_cnt].proxy_reason_cd = orv.proxy_reason_cd, reply->
     orders[my_order_idx].review[orv.action_sequence].review_prsnl[my_review_cnt].reject_reason_cd =
     orv.reject_reason_cd,
     reply->orders[my_order_idx].review[orv.action_sequence].review_prsnl[my_review_cnt].
     reviewed_status_flag = orv.reviewed_status_flag, reply->orders[my_order_idx].review[orv
     .action_sequence].review_prsnl[my_review_cnt].review_dt_tm = cnvtdatetime(orv.review_dt_tm),
     reply->orders[my_order_idx].review[orv.action_sequence].review_prsnl[my_review_cnt].review_tz =
     orv.review_tz,
     reply->orders[my_order_idx].review[orv.action_sequence].review_prsnl[my_review_cnt].
     review_personnel_id = orv.review_personnel_id, reply->orders[my_order_idx].review[orv
     .action_sequence].review_prsnl[my_review_cnt].review_type_flag = orv.review_type_flag
    FOOT  orv.review_sequence
     do_nothing = 0
    FOOT  orv.action_sequence
     do_nothing = 0
    FOOT  orv.order_id
     do_nothing = 0
    FOOT REPORT
     do_nothing = 0
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"ORDER_REVIEW","CP_GET_ORDERS",1,0)
 END ;Subroutine
#exit_script
 CALL log_message("Leaving script cp_get_orders",log_level_debug)
 CALL echorecord(reply)
END GO
