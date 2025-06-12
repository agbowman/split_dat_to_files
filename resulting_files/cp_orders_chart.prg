CREATE PROGRAM cp_orders_chart
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
 SET log_program_name = "CP_ORDERS_CHART"
 RECORD reply(
   1 qual[*]
     2 drawn_dt_tm = dq8
     2 drawn_tz = i4
     2 mnemonic = vc
     2 full_name = vc
     2 order_status = vc
     2 cancel_reason = vc
     2 order_id = f8
     2 orig_order_prov = f8
     2 curr_order_prov = f8
     2 all_order_prov[*]
       3 provider_id = f8
       3 action_dt_tm = dq8
       3 action_tz = i4
     2 dept_status = vc
     2 activity_type_cd = f8
     2 catalog_type_cd = f8
     2 catalog_cd = f8
     2 orig_order_action_dt_tm = dq8
     2 orig_order_action_tz = i4
     2 curr_order_action_dt_tm = dq8
     2 curr_order_action_tz = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE canc_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"CANCELED")), protect
 DECLARE pend_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"PENDING REV")), protect
 DECLARE comp_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"COMPLETED")), protect
 DECLARE disc_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"DISCONTINUED")), protect
 DECLARE numlines = i4 WITH noconstant(0), protect
 DECLARE dept_filter_flag = f8 WITH noconstant(0.0), protect
 DECLARE actv_filter_flag = f8 WITH noconstant(1.0), protect
 DECLARE idx = i4 WITH noconstant(0)
 DECLARE idx2 = i4 WITH noconstant(0)
 DECLARE idx3 = i4 WITH noconstant(0)
 DECLARE idxstart = i4 WITH noconstant(1)
 DECLARE noptimizedtotal = i4
 DECLARE nrecordsize = i4
 DECLARE where_clause = vc WITH noconstant("")
 DECLARE person_level_scope = i4 WITH constant(1)
 DECLARE xencntr_level_scope = i4 WITH constant(5)
 DECLARE all_order_type = i4 WITH constant(0)
 DECLARE cancelled_order_type = i4 WITH constant(1)
 DECLARE pending_order_type = i4 WITH constant(2)
 DECLARE increment_rec = i4 WITH constant(10)
 DECLARE bind_cnt = i4 WITH constant(50)
 DECLARE buildwhereclause(null) = null
 DECLARE getallorders(null) = null
 DECLARE getcancelledorders(null) = null
 DECLARE getpendingorders(null) = null
 DECLARE getorderingproviders(null) = null
 FREE RECORD order_flat_rec
 RECORD order_flat_rec(
   1 order_cnt = i4
   1 qual[*]
     2 order_id = f8
     2 rec_seq = i4
 )
 CALL log_message("Begin script: cp_orders_chart",log_level_debug)
 SET reply->status_data.status = "F"
 CALL buildwhereclause(null)
 CASE (request->order_type)
  OF all_order_type:
   CALL getallorders(null)
  OF cancelled_order_type:
   CALL getcancelledorders(null)
  OF pending_order_type:
   CALL getpendingorders(null)
 ENDCASE
 IF ((order_flat_rec->order_cnt > 0))
  CALL getorderingproviders(null)
 ENDIF
 SET stat = alterlist(reply->qual,numlines)
 SET reply->status_data.status = "S"
 SUBROUTINE getorderingproviders(null)
   CALL log_message("In GetOrderingProviders()",log_level_debug)
   DECLARE i = i4 WITH noconstant(0), protect
   DECLARE loc_order = i4 WITH noconstant(0), protect
   DECLARE activate_cd = f8 WITH constant(uar_get_code_by("MEANING",6003,"ACTIVATE")), protect
   DECLARE modify_cd = f8 WITH constant(uar_get_code_by("MEANING",6003,"MODIFY")), protect
   DECLARE order_cd = f8 WITH constant(uar_get_code_by("MEANING",6003,"ORDER")), protect
   DECLARE renew_cd = f8 WITH constant(uar_get_code_by("MEANING",6003,"RENEW")), protect
   DECLARE resume_cd = f8 WITH constant(uar_get_code_by("MEANING",6003,"RESUME")), protect
   DECLARE stud_activate_cd = f8 WITH constant(uar_get_code_by("MEANING",6003,"STUDACTIVATE")),
   protect
   SET idxstart = 1
   SET idxstart2 = 1
   SET nrecordsize = order_flat_rec->order_cnt
   SET noptimizedtotal = (ceil((cnvtreal(nrecordsize)/ bind_cnt)) * bind_cnt)
   SET stat = alterlist(order_flat_rec->qual,noptimizedtotal)
   FOR (i = (nrecordsize+ 1) TO noptimizedtotal)
    SET order_flat_rec->qual[i].order_id = order_flat_rec->qual[nrecordsize].order_id
    SET order_flat_rec->qual[i].rec_seq = order_flat_rec->qual[nrecordsize].rec_seq
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     order_action oa
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (oa
     WHERE expand(idx,idxstart,((idxstart+ bind_cnt) - 1),oa.order_id,order_flat_rec->qual[idx].
      order_id,
      bind_cnt)
      AND oa.order_id > 0
      AND oa.action_type_cd IN (order_cd, activate_cd, modify_cd, renew_cd, resume_cd,
     stud_activate_cd)
      AND oa.action_rejected_ind=0
      AND oa.order_provider_id > 0)
    ORDER BY oa.order_id, oa.action_sequence DESC
    HEAD oa.order_id
     loc_order = locateval(idx2,1,order_flat_rec->order_cnt,oa.order_id,order_flat_rec->qual[idx2].
      order_id)
     WHILE (loc_order != 0)
       qual_rec = order_flat_rec->qual[loc_order].rec_seq, reply->qual[qual_rec].curr_order_prov = oa
       .order_provider_id, reply->qual[qual_rec].curr_order_action_dt_tm = oa.action_dt_tm,
       reply->qual[qual_rec].curr_order_action_tz = validate(oa.action_tz,0), loc_order = locateval(
        idx2,(loc_order+ 1),order_flat_rec->order_cnt,oa.order_id,order_flat_rec->qual[idx2].order_id
        )
     ENDWHILE
    DETAIL
     loc_order = locateval(idx2,1,order_flat_rec->order_cnt,oa.order_id,order_flat_rec->qual[idx2].
      order_id)
     WHILE (loc_order != 0)
       qual_rec = order_flat_rec->qual[loc_order].rec_seq
       IF (locateval(idx3,1,size(reply->qual[qual_rec].all_order_prov,5),oa.order_provider_id,reply->
        qual[qual_rec].all_order_prov[idx3].provider_id)=0)
        x = (size(reply->qual[qual_rec].all_order_prov,5)+ 1), stat = alterlist(reply->qual[qual_rec]
         .all_order_prov,x), reply->qual[qual_rec].all_order_prov[x].provider_id = oa
        .order_provider_id,
        reply->qual[qual_rec].all_order_prov[x].action_dt_tm = oa.action_dt_tm, reply->qual[qual_rec]
        .all_order_prov[x].action_tz = validate(oa.action_tz,0)
       ENDIF
       loc_order = locateval(idx2,(loc_order+ 1),order_flat_rec->order_cnt,oa.order_id,order_flat_rec
        ->qual[idx2].order_id)
     ENDWHILE
    FOOT  oa.order_id
     loc_order = locateval(idx2,1,order_flat_rec->order_cnt,oa.order_id,order_flat_rec->qual[idx2].
      order_id)
     WHILE (loc_order != 0)
       qual_rec = order_flat_rec->qual[loc_order].rec_seq, reply->qual[qual_rec].orig_order_prov = oa
       .order_provider_id, reply->qual[qual_rec].orig_order_action_dt_tm = oa.action_dt_tm,
       reply->qual[qual_rec].orig_order_action_tz = validate(oa.action_tz,0), loc_order = locateval(
        idx2,(loc_order+ 1),order_flat_rec->order_cnt,oa.order_id,order_flat_rec->qual[idx2].order_id
        )
     ENDWHILE
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE (addordertoflatrec(dorderid=f8(val),nindex=i4(val)) =null)
   IF (dorderid > 0)
    SET idxstart = 1
    IF (locateval(idx,idxstart,order_flat_rec->order_cnt,dorderid,order_flat_rec->qual[idx].order_id,
     nindex,order_flat_rec->qual[idx].rec_seq)=0)
     SET order_flat_rec->order_cnt += 1
     SET stat = alterlist(order_flat_rec->qual,order_flat_rec->order_cnt)
     SET order_flat_rec->qual[order_flat_rec->order_cnt].order_id = dorderid
     SET order_flat_rec->qual[order_flat_rec->order_cnt].rec_seq = nindex
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE buildwhereclause(null)
   CALL log_message("In BuildWhereClause()",log_level_debug)
   DECLARE encntr_nbr = i4 WITH constant(size(request->encntr_list,5)), protect
   DECLARE encntr_clause = vc WITH noconstant(""), protect
   CASE (request->scope_flag)
    OF person_level_scope:
     SET where_clause = "o.person_id = request->person_id"
    OF xencntr_level_scope:
     SET where_clause = "o.person_id = request->person_id"
     IF (encntr_nbr > 0)
      FOR (x = 1 TO encntr_nbr)
        IF (x=1)
         SET encntr_clause = build("o.encntr_id in (",request->encntr_list[x].encntr_ids)
        ELSE
         SET encntr_clause = build(encntr_clause,", ",request->encntr_list[x].encntr_ids)
        ENDIF
      ENDFOR
      SET encntr_clause = build(encntr_clause,")")
      SET where_clause = concat(where_clause," and ",encntr_clause)
     ENDIF
    ELSE
     SET where_clause = "o.person_id = request->person_id and o.encntr_id = request->encntr_id"
   ENDCASE
   CALL log_message(build("Where Clause: ",where_clause),log_level_debug)
 END ;Subroutine
 SUBROUTINE getallorders(null)
   CALL log_message("In GetAllOrders()",log_level_debug)
   SELECT
    IF ((request->order_seq_flag=0))
     ORDER BY o.current_start_dt_tm, oc.description
    ELSE
     ORDER BY oc.description, o.current_start_dt_tm
    ENDIF
    INTO "nl:"
    o.current_start_dt_tm, oc.description
    FROM orders o,
     order_catalog oc,
     chart_ord_sum_filter cf1,
     chart_ord_sum_filter cf2
    PLAN (o
     WHERE parser(where_clause))
     JOIN (oc
     WHERE o.catalog_cd=oc.catalog_cd
      AND oc.bill_only_ind=0)
     JOIN (cf1
     WHERE (cf1.chart_group_id=request->chart_group_id)
      AND cf1.filter_type_flag=dept_filter_flag
      AND cf1.filter_cd=o.dept_status_cd)
     JOIN (cf2
     WHERE (cf2.chart_group_id=request->chart_group_id)
      AND cf2.filter_type_flag=actv_filter_flag
      AND cf2.filter_cd=o.activity_type_cd)
    HEAD REPORT
     numlines = 0
    DETAIL
     numlines += 1
     IF (numlines > size(reply->qual,5))
      stat = alterlist(reply->qual,((numlines+ increment_rec) - 1))
     ENDIF
     reply->qual[numlines].drawn_dt_tm = cnvtdatetime(o.current_start_dt_tm), reply->qual[numlines].
     drawn_tz = validate(o.current_start_tz,0), reply->qual[numlines].mnemonic = o.order_mnemonic,
     reply->qual[numlines].full_name = oc.description, reply->qual[numlines].order_status =
     uar_get_code_display(o.order_status_cd), reply->qual[numlines].dept_status =
     uar_get_code_display(o.dept_status_cd),
     reply->qual[numlines].order_id = o.order_id, reply->qual[numlines].activity_type_cd = o
     .activity_type_cd, reply->qual[numlines].catalog_cd = o.catalog_cd,
     reply->qual[numlines].catalog_type_cd = o.catalog_type_cd,
     CALL addordertoflatrec(o.order_id,numlines)
    FOOT REPORT
     stat = alterlist(reply->qual,numlines)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"ORDERS","GETALLORDERS",1,1)
 END ;Subroutine
 SUBROUTINE getcancelledorders(null)
   CALL log_message("In GetCancelledOrders()",log_level_debug)
   SELECT
    IF ((request->order_seq_flag=0))
     ORDER BY o.current_start_dt_tm, oc.description
    ELSE
     ORDER BY oc.description, o.current_start_dt_tm
    ENDIF
    INTO "nl:"
    o.current_start_dt_tm, oc.description
    FROM orders o,
     order_detail od,
     order_catalog oc,
     chart_ord_sum_filter cf1
    PLAN (o
     WHERE parser(where_clause)
      AND ((o.order_status_cd+ 0)=canc_cd)
      AND ((o.order_id+ 0) > 0))
     JOIN (oc
     WHERE o.catalog_cd=oc.catalog_cd
      AND oc.bill_only_ind=0)
     JOIN (cf1
     WHERE (cf1.chart_group_id=request->chart_group_id)
      AND cf1.filter_type_flag=actv_filter_flag
      AND cf1.filter_cd=o.activity_type_cd)
     JOIN (od
     WHERE (od.order_id= Outerjoin(o.order_id))
      AND (od.oe_field_meaning= Outerjoin("CANCELREASON")) )
    HEAD REPORT
     numlines = 0
    DETAIL
     numlines += 1
     IF (numlines > size(reply->qual,5))
      stat = alterlist(reply->qual,((numlines+ increment_rec) - 1))
     ENDIF
     reply->qual[numlines].drawn_dt_tm = cnvtdatetime(o.current_start_dt_tm), reply->qual[numlines].
     drawn_tz = validate(o.current_start_tz,0), reply->qual[numlines].mnemonic = o.order_mnemonic,
     reply->qual[numlines].full_name = oc.description, reply->qual[numlines].cancel_reason = od
     .oe_field_display_value, reply->qual[numlines].activity_type_cd = o.activity_type_cd,
     reply->qual[numlines].catalog_cd = o.catalog_cd, reply->qual[numlines].catalog_type_cd = o
     .catalog_type_cd,
     CALL addordertoflatrec(o.order_id,numlines)
    FOOT REPORT
     stat = alterlist(reply->qual,numlines)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"ORDERS","GETCANCELLEDORDERS",1,1)
 END ;Subroutine
 SUBROUTINE getpendingorders(null)
   CALL log_message("In GetPendingOrders()",log_level_debug)
   SELECT
    IF ((request->order_seq_flag=0))
     ORDER BY o.current_start_dt_tm, oc.description
    ELSE
     ORDER BY oc.description, o.current_start_dt_tm
    ENDIF
    INTO "nl:"
    o.current_start_dt_tm, oc.description
    FROM orders o,
     order_catalog oc,
     chart_ord_sum_filter cf1,
     chart_ord_sum_filter cf2
    PLAN (o
     WHERE parser(where_clause)
      AND  NOT (((o.order_status_cd+ 0) IN (canc_cd, comp_cd, disc_cd))))
     JOIN (oc
     WHERE o.catalog_cd=oc.catalog_cd
      AND oc.bill_only_ind=0)
     JOIN (cf1
     WHERE (cf1.chart_group_id=request->chart_group_id)
      AND cf1.filter_type_flag=dept_filter_flag
      AND cf1.filter_cd=o.dept_status_cd)
     JOIN (cf2
     WHERE (cf2.chart_group_id=request->chart_group_id)
      AND cf2.filter_type_flag=actv_filter_flag
      AND cf2.filter_cd=o.activity_type_cd)
    HEAD REPORT
     numlines = 0
    DETAIL
     numlines += 1
     IF (numlines > size(reply->qual,5))
      stat = alterlist(reply->qual,((numlines+ increment_rec) - 1))
     ENDIF
     reply->qual[numlines].drawn_dt_tm = cnvtdatetime(o.current_start_dt_tm), reply->qual[numlines].
     drawn_tz = validate(o.current_start_tz,0), reply->qual[numlines].mnemonic = o.order_mnemonic,
     reply->qual[numlines].full_name = oc.description, reply->qual[numlines].order_status =
     uar_get_code_display(o.order_status_cd), reply->qual[numlines].dept_status =
     uar_get_code_display(o.dept_status_cd),
     reply->qual[numlines].activity_type_cd = o.activity_type_cd, reply->qual[numlines].catalog_cd =
     o.catalog_cd, reply->qual[numlines].catalog_type_cd = o.catalog_type_cd,
     CALL addordertoflatrec(o.order_id,numlines)
    FOOT REPORT
     stat = alterlist(reply->qual,numlines)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"ORDERS","GETPENDINGORDERS",1,1)
 END ;Subroutine
#exit_script
 CALL log_message("Exiting script: cp_orders_chart",log_level_debug)
END GO
