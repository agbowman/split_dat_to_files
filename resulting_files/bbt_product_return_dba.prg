CREATE PROGRAM bbt_product_return:dba
 DECLARE log_program_name = vc WITH protect, noconstant(curprog)
 IF (validate(glbsl_def,999)=999)
  CALL echo("Declaring GLBSL_DEF")
  DECLARE glbsl_def = i2 WITH protect, constant(1)
  DECLARE log_override_ind = i2 WITH protect, noconstant(0)
  SET log_override_ind = 0
  DECLARE log_level_error = i2 WITH protect, noconstant(0)
  DECLARE log_level_warning = i2 WITH protect, noconstant(1)
  DECLARE log_level_audit = i2 WITH protect, noconstant(2)
  DECLARE log_level_info = i2 WITH protect, noconstant(3)
  DECLARE log_level_debug = i2 WITH protect, noconstant(4)
  DECLARE hsys = h WITH protect, noconstant(0)
  DECLARE sysstat = i4 WITH protect, noconstant(0)
  DECLARE serrmsg = c132 WITH protect, noconstant(" ")
  DECLARE ierrcode = i4 WITH protect, noconstant(error(serrmsg,1))
  DECLARE glbsl_msg_default = i4 WITH protect, noconstant(0)
  DECLARE glbsl_msg_level = i4 WITH protect, noconstant(0)
  EXECUTE msgrtl
  SET glbsl_msg_default = uar_msgdefhandle()
  SET glbsl_msg_level = uar_msggetlevel(glbsl_msg_default)
  CALL uar_syscreatehandle(hsys,sysstat)
  DECLARE lglbslsubeventcnt = i4 WITH protect, noconstant(0)
  DECLARE iglbslloggingstat = i2 WITH protect, noconstant(0)
  DECLARE lglbslsubeventsize = i4 WITH protect, noconstant(0)
  DECLARE iglbslloglvloverrideind = i2 WITH protect, noconstant(0)
  DECLARE sglbsllogtext = vc WITH protect, noconstant("")
  DECLARE sglbsllogevent = vc WITH protect, noconstant("")
  DECLARE iglbslholdloglevel = i2 WITH protect, noconstant(0)
  DECLARE iglbslerroroccured = i2 WITH protect, noconstant(0)
  DECLARE lglbsluarmsgwritestat = i4 WITH protect, noconstant(0)
  DECLARE glbsl_info_domain = vc WITH protect, constant("PATHNET SCRIPT LOGGING")
  DECLARE glbsl_logging_on = c1 WITH protect, constant("L")
 ENDIF
 SELECT INTO "nl:"
  FROM dm_info dm
  PLAN (dm
   WHERE dm.info_domain=glbsl_info_domain
    AND dm.info_name=curprog)
  DETAIL
   IF (dm.info_char=glbsl_logging_on)
    log_override_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SUBROUTINE (log_message(logmsg=vc,loglvl=i4) =null)
   SET iglbslloglvloverrideind = 0
   SET sglbsllogtext = ""
   SET sglbsllogevent = ""
   SET sglbsllogtext = concat("{{Script::",value(log_program_name),"}} ",logmsg)
   IF (log_override_ind=0)
    SET iglbslholdloglevel = loglvl
   ELSE
    IF (glbsl_msg_level < loglvl)
     SET iglbslholdloglevel = glbsl_msg_level
     SET iglbslloglvloverrideind = 1
    ELSE
     SET iglbslholdloglevel = loglvl
    ENDIF
   ENDIF
   IF (iglbslloglvloverrideind=1)
    SET sglbsllogevent = "ScriptOverride"
   ELSE
    CASE (iglbslholdloglevel)
     OF log_level_error:
      SET sglbsllogevent = "ScriptError"
     OF log_level_warning:
      SET sglbsllogevent = "ScriptWarning"
     OF log_level_audit:
      SET sglbsllogevent = "ScriptAudit"
     OF log_level_info:
      SET sglbsllogevent = "ScriptInfo"
     OF log_level_debug:
      SET sglbsllogevent = "ScriptDebug"
    ENDCASE
   ENDIF
   SET lglbsluarmsgwritestat = uar_msgwrite(glbsl_msg_default,0,nullterm(sglbsllogevent),
    iglbslholdloglevel,nullterm(sglbsllogtext))
 END ;Subroutine
 SUBROUTINE (error_message(logstatusblockind=i2) =i2)
   SET iglbslerroroccured = 0
   SET ierrcode = error(serrmsg,0)
   WHILE (ierrcode > 0)
     SET iglbslerroroccured = 1
     CALL log_message(serrmsg,log_level_audit)
     IF (logstatusblockind=1)
      CALL populate_subeventstatus("EXECUTE","F","CCL SCRIPT",serrmsg)
     ENDIF
     SET ierrcode = error(serrmsg,0)
   ENDWHILE
   RETURN(iglbslerroroccured)
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value)) =i2)
   IF (validate(reply->status_data.status,"-1") != "-1")
    SET lglbslsubeventcnt = size(reply->status_data.subeventstatus,5)
    IF (lglbslsubeventcnt > 0)
     SET lglbslsubeventsize = size(trim(reply->status_data.subeventstatus[lglbslsubeventcnt].
       operationname))
     SET lglbslsubeventsize += size(trim(reply->status_data.subeventstatus[lglbslsubeventcnt].
       operationstatus))
     SET lglbslsubeventsize += size(trim(reply->status_data.subeventstatus[lglbslsubeventcnt].
       targetobjectname))
     SET lglbslsubeventsize += size(trim(reply->status_data.subeventstatus[lglbslsubeventcnt].
       targetobjectvalue))
    ELSE
     SET lglbslsubeventsize = 1
    ENDIF
    IF (lglbslsubeventsize > 0)
     SET lglbslsubeventcnt += 1
     SET iglbslloggingstat = alter(reply->status_data.subeventstatus,lglbslsubeventcnt)
    ENDIF
    SET reply->status_data.subeventstatus[lglbslsubeventcnt].operationname = substring(1,25,
     operationname)
    SET reply->status_data.subeventstatus[lglbslsubeventcnt].operationstatus = substring(1,1,
     operationstatus)
    SET reply->status_data.subeventstatus[lglbslsubeventcnt].targetobjectname = substring(1,25,
     targetobjectname)
    SET reply->status_data.subeventstatus[lglbslsubeventcnt].targetobjectvalue = targetobjectvalue
   ENDIF
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus_msg(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value),loglevel=i2(value)) =i2)
  CALL populate_subeventstatus(operationname,operationstatus,targetobjectname,targetobjectvalue)
  CALL log_message(targetobjectvalue,loglevel)
 END ;Subroutine
 SUBROUTINE (check_log_level(arg_log_level=i4) =i2)
   IF (((glbsl_msg_level >= arg_log_level) OR (log_override_ind=1)) )
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 RECORD pn_recovery_items(
   1 qual[*]
     2 pn_recovery_id = f8
     2 parent_entity_id = f8
     2 pn_recovery_child_id = f8
     2 child_entity_id = f8
     2 pn_recovery_detail_info[2]
       3 pn_recovery_detail_id = f8
     2 event_type_flag = i4
 )
 DECLARE g_sub_event_type_flag = i4 WITH public, noconstant(0)
 DECLARE g_sub_num_products = i4 WITH public, noconstant(0)
 SUBROUTINE (insert_pn_recovery_data(arg_ops_ind=i2) =i2)
   CALL log_message("Enter pn_populate_pn_recovery_tables.INC",log_level_debug)
   DECLARE pn_recovery_type_cd = f8 WITH public, noconstant(0.0)
   DECLARE pn_code_cnt = i4 WITH public, constant(1)
   DECLARE pn_recovery_type_cdf = c12 WITH public, constant("PRODUCT")
   DECLARE pn_recovery_type_codeset = i4 WITH public, constant(28600)
   DECLARE product_count = i4 WITH public, noconstant(0)
   DECLARE pn_item_count = i4 WITH public, noconstant(0)
   DECLARE parent_entity_name = c32 WITH public, constant("PRODUCT")
   DECLARE pn_recovery_id = f8 WITH public, noconstant(0.0)
   DECLARE child_entity_name = c32 WITH public, constant("PRODUCT_EVENT")
   DECLARE pn_recovery_child_id = f8 WITH public, noconstant(0.0)
   DECLARE first_pn_recovery_detail_id = f8 WITH public, noconstant(0.0)
   DECLARE second_pn_recovery_detail_id = f8 WITH public, noconstant(0.0)
   DECLARE detail_parent_entity_name = c32 WITH public, constant("PN_RECOVERY")
   DECLARE event_dt_tm = c40 WITH public, constant("EVENT_DT_TM")
   DECLARE product_event_type = c40 WITH public, constant("PRODUCT_EVENT_TYPE")
   CALL log_message(build("Initial number of products = ",g_sub_num_products),log_level_debug)
   IF (g_sub_num_products=0)
    CALL log_message("No products: skip PN_RECOVERY",log_level_debug)
    RETURN(2)
   ELSE
    SET stat = alterlist(pn_recovery_items->qual,g_sub_num_products)
    FOR (product_count = 1 TO g_sub_num_products)
      IF (((g_sub_event_type_flag=1
       AND validate(ops_request->productlist[product_count].status,"S")="S") OR (
      g_sub_event_type_flag=2
       AND validate(request->productlist[product_count].trans_prod_event_id,- (1.0)) > 0.0)) )
       SET pn_item_count += 1
       CALL log_message(build("pn_item_count = ",pn_item_count),log_level_debug)
       SELECT INTO "nl:"
        next_seq_nbr = seq(pathnet_recovery_seq,nextval)
        FROM dual
        DETAIL
         pn_recovery_id = next_seq_nbr
        WITH nocounter, format
       ;end select
       IF (error_message(1)=1)
        CALL log_message("ERROR producing unique PN_RECOVERY_ID",log_level_warning)
        RETURN(0)
       ENDIF
       IF (pn_recovery_id=0)
        CALL log_message("Failure to produce unique PN_RECOVERY_ID",log_level_warning)
        RETURN(0)
       ENDIF
       IF (arg_ops_ind=1)
        SET pn_recovery_items->qual[pn_item_count].parent_entity_id = ops_request->productlist[
        product_count].product_id
       ELSE
        SET pn_recovery_items->qual[pn_item_count].parent_entity_id = request->productlist[
        product_count].product_id
       ENDIF
       SET pn_recovery_items->qual[pn_item_count].pn_recovery_id = pn_recovery_id
       CALL log_message(build("parent_entity_id = ",pn_recovery_items->qual[pn_item_count].
         parent_entity_id),log_level_debug)
       CALL log_message(build("pn_recovery_id = ",pn_recovery_items->qual[pn_item_count].
         pn_recovery_id),log_level_debug)
       SELECT INTO "nl:"
        next_seq_nbr = seq(pathnet_recovery_seq,nextval)
        FROM dual
        DETAIL
         pn_recovery_child_id = next_seq_nbr
        WITH nocounter, format
       ;end select
       IF (error_message(1)=1)
        CALL log_message("ERROR producing unique PN_RECOVERY_CHILD_ID",log_level_warning)
        RETURN(0)
       ENDIF
       IF (pn_recovery_child_id=0)
        CALL log_message("Failure to produce unique PN_RECOVERY_CHILD_ID",log_level_warning)
        RETURN(0)
       ENDIF
       IF (g_sub_event_type_flag=1)
        SET pn_recovery_items->qual[pn_item_count].child_entity_id = reply->results[product_count].
        product_event_id
        CALL log_message(build("child_entity_id = ",pn_recovery_items->qual[product_count].
          child_entity_id),log_level_debug)
       ELSE
        SET pn_recovery_items->qual[pn_item_count].child_entity_id = request->productlist[
        product_count].trans_prod_event_id
        CALL log_message(build("child_entity_id = ",pn_recovery_items->qual[product_count].
          child_entity_id),log_level_debug)
       ENDIF
       SET pn_recovery_items->qual[pn_item_count].pn_recovery_child_id = pn_recovery_child_id
       CALL log_message(build("pn_recovery_child_id = ",pn_recovery_items->qual[pn_item_count].
         pn_recovery_child_id),log_level_debug)
       SELECT INTO "nl:"
        next_seq_nbr = seq(pathnet_recovery_seq,nextval)
        FROM dual
        DETAIL
         first_pn_recovery_detail_id = next_seq_nbr
        WITH nocounter, format
       ;end select
       IF (error_message(1)=1)
        CALL log_message("ERROR producing first unique PN_RECOVERY_DETAIL_ID",log_level_warning)
        RETURN(0)
       ENDIF
       IF (first_pn_recovery_detail_id=0)
        CALL log_message("Failure to produce first unique PN_RECOVERY_DETAIL_ID",log_level_warning)
        RETURN(0)
       ENDIF
       SET pn_recovery_items->qual[pn_item_count].pn_recovery_detail_info[1].pn_recovery_detail_id =
       first_pn_recovery_detail_id
       CALL log_message(build("first_pn_recovery_detail_id = ",pn_recovery_items->qual[pn_item_count]
         .pn_recovery_detail_info[1].pn_recovery_detail_id),log_level_debug)
       SELECT INTO "nl:"
        next_seq_nbr = seq(pathnet_recovery_seq,nextval)
        FROM dual
        DETAIL
         second_pn_recovery_detail_id = next_seq_nbr
        WITH nocounter, format
       ;end select
       IF (error_message(1)=1)
        CALL log_message("ERROR producing second unique PN_RECOVERY_DETAIL_ID",log_level_warning)
        RETURN(0)
       ENDIF
       IF (second_pn_recovery_detail_id=0)
        CALL log_message("Failure to produce second unique PN_RECOVERY_DETAIL_ID",log_level_warning)
        RETURN(0)
       ENDIF
       SET pn_recovery_items->qual[pn_item_count].pn_recovery_detail_info[2].pn_recovery_detail_id =
       second_pn_recovery_detail_id
       CALL log_message(build("second_pn_recovery_detail_id = ",pn_recovery_items->qual[pn_item_count
         ].pn_recovery_detail_info[2].pn_recovery_detail_id),log_level_debug)
       SET reply->results[product_count].pn_recovery_id = pn_recovery_items->qual[pn_item_count].
       pn_recovery_id
       IF (validate(reply->results[product_count].unreturned_qty,0) > 0)
        SET reply->results[product_count].event_type_flag = 3
        SET pn_recovery_items->qual[pn_item_count].event_type_flag = 3
       ELSE
        SET reply->results[product_count].event_type_flag = g_sub_event_type_flag
        SET pn_recovery_items->qual[pn_item_count].event_type_flag = g_sub_event_type_flag
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   IF (pn_item_count > 0)
    SET stat = alterlist(pn_recovery_items->qual,pn_item_count)
   ELSE
    CALL log_message("No products to process: skip PN_RECOVERY",log_level_debug)
    RETURN(2)
   ENDIF
   SET stat = uar_get_meaning_by_codeset(pn_recovery_type_codeset,pn_recovery_type_cdf,pn_code_cnt,
    pn_recovery_type_cd)
   IF (pn_recovery_type_cd=0.0)
    CALL log_message("Failure on PN_RECOVERY_TYPE_CD UAR",log_level_warning)
    CALL populate_subeventstatus("uar_get_meaning_by_codeset","F","recovery_type_cd",
     "Unable to retrieve code_value")
    RETURN(0)
   ENDIF
   INSERT  FROM (dummyt d  WITH seq = value(pn_item_count)),
     pn_recovery pr
    SET pr.pn_recovery_id = pn_recovery_items->qual[d.seq].pn_recovery_id, pr.parent_entity_name =
     parent_entity_name, pr.parent_entity_id = pn_recovery_items->qual[d.seq].parent_entity_id,
     pr.recovery_type_cd = pn_recovery_type_cd, pr.in_process_flag = 0, pr.expire_dt_tm =
     cnvtdatetime(sysdate),
     pr.failure_cnt = 0, pr.first_failure_dt_tm = null, pr.last_failure_dt_tm = null,
     pr.updt_dt_tm = cnvtdatetime(sysdate), pr.updt_id = reqinfo->updt_id, pr.updt_task = reqinfo->
     updt_task,
     pr.updt_applctx = reqinfo->updt_applctx, pr.updt_cnt = 0
    PLAN (d)
     JOIN (pr)
    WITH nocounter
   ;end insert
   IF (error_message(1)=1)
    CALL log_message("ERROR inserting into PN_RECOVERY table",log_level_warning)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    CALL log_message("Failure to insert into PN_RECOVERY table",log_level_warning)
    CALL populate_subeventstatus("INSERT","F","PN_RECOVERY TABLE",
     "Unable to insert pn_recovery record")
    RETURN(0)
   ENDIF
   INSERT  FROM (dummyt d  WITH seq = value(pn_item_count)),
     pn_recovery_child prc
    SET prc.pn_recovery_id = pn_recovery_items->qual[d.seq].pn_recovery_id, prc.pn_recovery_child_id
      = pn_recovery_items->qual[d.seq].pn_recovery_child_id, prc.child_entity_name =
     child_entity_name,
     prc.child_entity_id = pn_recovery_items->qual[d.seq].child_entity_id, prc.updt_dt_tm =
     cnvtdatetime(sysdate), prc.updt_id = reqinfo->updt_id,
     prc.updt_task = reqinfo->updt_task, prc.updt_applctx = reqinfo->updt_applctx, prc.updt_cnt = 0
    PLAN (d)
     JOIN (prc)
    WITH nocounter
   ;end insert
   IF (error_message(1)=1)
    CALL log_message("ERROR inserting into PN_RECOVERY_CHILD table",log_level_warning)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    CALL log_message("Failure to insert into PN_RECOVERY_CHILD table",log_level_warning)
    CALL populate_subeventstatus("INSERT","F","PN_RECOVERY_CHILD TABLE",
     "Unable to insert pn_recovery_child record")
    RETURN(0)
   ENDIF
   INSERT  FROM (dummyt d  WITH seq = value(pn_item_count)),
     pn_recovery_detail prd
    SET prd.pn_recovery_detail_id = pn_recovery_items->qual[d.seq].pn_recovery_detail_info[1].
     pn_recovery_detail_id, prd.parent_entity_name = detail_parent_entity_name, prd.parent_entity_id
      = pn_recovery_items->qual[d.seq].pn_recovery_id,
     prd.detail_mean = event_dt_tm, prd.detail_dt_tm = cnvtdatetime(sysdate), prd.updt_dt_tm =
     cnvtdatetime(sysdate),
     prd.updt_id = reqinfo->updt_id, prd.updt_task = reqinfo->updt_task, prd.updt_applctx = reqinfo->
     updt_applctx,
     prd.updt_cnt = 0, prd.detail_value =
     IF (curutc=1) curtimezoneapp
     ELSE 0
     ENDIF
    PLAN (d)
     JOIN (prd)
    WITH nocounter
   ;end insert
   IF (error_message(1)=1)
    CALL log_message("ERROR inserting first entry into PN_RECOVERY_DETAIL table",log_level_warning)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    CALL log_message("Failure to insert first entry into PN_RECOVERY_DETAIL table",log_level_warning)
    CALL populate_subeventstatus("INSERT","F","PN_RECOVERY_DETAIL TABLE",
     "Unable to insert first pn_recovery_detail record")
    RETURN(0)
   ENDIF
   INSERT  FROM (dummyt d  WITH seq = value(pn_item_count)),
     pn_recovery_detail prd
    SET prd.pn_recovery_detail_id = pn_recovery_items->qual[d.seq].pn_recovery_detail_info[2].
     pn_recovery_detail_id, prd.parent_entity_name = detail_parent_entity_name, prd.parent_entity_id
      = pn_recovery_items->qual[d.seq].pn_recovery_id,
     prd.detail_mean = product_event_type, prd.detail_value = pn_recovery_items->qual[d.seq].
     event_type_flag, prd.updt_dt_tm = cnvtdatetime(sysdate),
     prd.updt_id = reqinfo->updt_id, prd.updt_task = reqinfo->updt_task, prd.updt_applctx = reqinfo->
     updt_applctx,
     prd.updt_cnt = 0
    PLAN (d)
     JOIN (prd)
    WITH nocounter
   ;end insert
   IF (error_message(1)=1)
    CALL log_message("ERROR inserting second entry into PN_RECOVERY_DETAIL table",log_level_warning)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    CALL log_message("Failure to insert second entry into PN_RECOVERY_DETAIL table",log_level_warning
     )
    CALL populate_subeventstatus("INSERT","F","PN_RECOVERY_DETAIL TABLE",
     "Unable to insert second pn_recovery_detail record")
    RETURN(0)
   ENDIF
   CALL log_message("Successfully Exit pn_populate_pn_recovery_tables.INC",log_level_debug)
   RETURN(1)
 END ;Subroutine
 DECLARE return_to_stock = vc WITH protect, constant("RTS")
 DECLARE transfer_reason_cs = i4 WITH protect, constant(1617)
 DECLARE sys_moveincd = f8 WITH protect, constant(uar_get_code_by("MEANING",transfer_reason_cs,
   "SYS_MOVEIN"))
 DECLARE sys_moveoutcd = f8 WITH protect, constant(uar_get_code_by("MEANING",transfer_reason_cs,
   "SYS_MOVEOUT"))
 DECLARE sys_emeroutcd = f8 WITH protect, constant(uar_get_code_by("MEANING",transfer_reason_cs,
   "SYS_EMEROUT"))
 DECLARE sys_transoutcd = f8 WITH protect, constant(uar_get_code_by("MEANING",transfer_reason_cs,
   "SYS_TRANSOUT"))
 DECLARE populate_outbound_products(null) = null
 DECLARE send_system_rtn_stock_msg(null) = null
 FREE RECORD outbound_products
 RECORD outbound_products(
   1 message_name = vc
   1 products[*]
     2 product_id = f8
     2 person_id = f8
     2 device_id = f8
 )
 SUBROUTINE populate_outbound_products(null)
  DECLARE recsize = i4 WITH protect, noconstant(1)
  SELECT
   p.product_id
   FROM (dummyt d  WITH seq = value(nbr_to_update)),
    product p,
    product_event pe,
    bb_device_transfer b
   PLAN (d)
    JOIN (p
    WHERE (request->productlist[d.seq].product_id=p.product_id)
     AND p.interfaced_device_flag > 0)
    JOIN (pe
    WHERE p.product_id=pe.product_id)
    JOIN (b
    WHERE b.product_event_id=pe.product_event_id
     AND b.reason_cd IN (sys_moveincd, sys_moveoutcd, sys_emeroutcd, sys_transoutcd))
   ORDER BY p.product_id, pe.event_dt_tm DESC
   HEAD p.product_id
    stat = alterlist(outbound_products->products,recsize), outbound_products->products[recsize].
    product_id = p.product_id
    IF (b.reason_cd=sys_moveincd)
     outbound_products->products[recsize].device_id = b.to_device_id
    ELSE
     outbound_products->products[recsize].device_id = b.from_device_id
    ENDIF
    recsize += 1
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE send_system_rtn_stock_msg(null)
   SET outbound_products->message_name = return_to_stock
   EXECUTE bbt_send_products_outbound  WITH replace("REQUEST","OUTBOUND_PRODUCTS")
   FREE SET outbound_products
 END ;Subroutine
 SET log_program_name = "bbt_product_return"
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 results[1]
     2 product_id = f8
     2 person_id = f8
     2 encntr_id = f8
     2 status = c1
     2 err_process = vc
     2 err_message = vc
     2 pn_recovery_id = f8
     2 event_type_flag = i2
     2 transfused_dt_tm = dq8
     2 unreturned_qty = i4
     2 unreturned_iu = i4
     2 trans_order_id = f8
     2 trans_personnel_id = f8
 )
 RECORD partialreturnrequest(
   1 qual[*]
     2 product_id = f8
     2 product_type = vc
     2 trans_prod_event_id = f8
 )
 RECORD partialreturnreply(
   1 qual[*]
     2 product_id = f8
     2 unreturned_qty = i4
     2 unreturned_iu = i4
     2 trans_order_id = f8
     2 trans_personnel_id = f8
     2 encntr_id = f8
     2 person_id = f8
     2 transfused_dt_tm = dq8
 )
 CALL log_message("---BBT_PRODUCT_RETURN STARTING",log_level_debug)
 DECLARE bactiveautoflag = c1 WITH protect, noconstant("F")
 DECLARE bactivedirflag = c1 WITH protect, noconstant("F")
 DECLARE bdisponlyflag = c1 WITH protect, noconstant("F")
 DECLARE product_event_id = f8 WITH protect, noconstant(0.0)
 DECLARE dispense_return_id = f8 WITH protect, noconstant(0.0)
 DECLARE assign_release_id = f8 WITH protect, noconstant(0.0)
 DECLARE location_cd = f8 WITH protect, noconstant(0.0)
 DECLARE rtscallflag = i2 WITH protect, noconstant(0)
 SET count1 = 0
 SET count2 = 0
 SET partial_req_cnt = 0
 SET partial_rep_cnt = 0
 SET reply->status_data.status = "F"
 SET active_quar = "F"
 SET active_uncfrm = "F"
 SET error_process = "                                      "
 SET error_message = "                                      "
 SET success_cnt = 0
 SET failure_occured = "F"
 SET multiple_events = "F"
 SET this_id = 0.0
 SET nbr_quar_reasons = 0
 SET quantity_val = 0
 SET quantity_iu = 0
 SET unreturned_qty = 0
 SET unreturned_iu = 0
 SET gsub_product_event_status = "  "
 SET thistable = "    "
 SET emergency_dispense = "F"
 SET quar_event_type_cd = 0.0
 SET dispns_event_type_cd = 0.0
 SET assgn_event_type_cd = 0.0
 SET xmtch_event_type_cd = 0.0
 SET avail_event_type_cd = 0.0
 SET uncfrm_event_type_cd = 0.0
 DECLARE auto_event_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE dir_event_type_cd = f8 WITH protect, noconstant(0.0)
 SET cdf_meaning = fillstring(12," ")
 SET uar_failed = 0
 SET volume_val = 0
 SET iu_ind = 0
 SET cdf_meaning = "10"
 SET stat = uar_get_meaning_by_codeset(1610,nullterm(cdf_meaning),1,auto_event_type_cd)
 IF (stat=1)
  EXECUTE then
  SET uar_failed = 1
  GO TO skip_rest
 ENDIF
 SET cdf_meaning = "11"
 SET stat = uar_get_meaning_by_codeset(1610,nullterm(cdf_meaning),1,dir_event_type_cd)
 IF (stat=1)
  EXECUTE then
  SET uar_failed = 1
  GO TO skip_rest
 ENDIF
 SET cdf_meaning = "1"
 SET stat = uar_get_meaning_by_codeset(1610,nullterm(cdf_meaning),1,assgn_event_type_cd)
 IF (stat=1)
  EXECUTE then
  SET uar_failed = 1
  GO TO skip_rest
 ENDIF
 SET cdf_meaning = "2"
 SET stat = uar_get_meaning_by_codeset(1610,nullterm(cdf_meaning),1,quar_event_type_cd)
 IF (stat=1)
  EXECUTE then
  SET uar_failed = 1
  GO TO skip_rest
 ENDIF
 SET cdf_meaning = "3"
 SET stat = uar_get_meaning_by_codeset(1610,nullterm(cdf_meaning),1,xmtch_event_type_cd)
 IF (stat=1)
  EXECUTE then
  SET uar_failed = 1
  GO TO skip_rest
 ENDIF
 SET cdf_meaning = "4"
 SET stat = uar_get_meaning_by_codeset(1610,nullterm(cdf_meaning),1,dispns_event_type_cd)
 IF (stat=1)
  EXECUTE then
  SET uar_failed = 1
  GO TO skip_rest
 ENDIF
 SET cdf_meaning = "12"
 SET stat = uar_get_meaning_by_codeset(1610,nullterm(cdf_meaning),1,avail_event_type_cd)
 IF (stat=1)
  EXECUTE then
  SET uar_failed = 1
  GO TO skip_rest
 ENDIF
 SET cdf_meaning = "9"
 SET stat = uar_get_meaning_by_codeset(1610,nullterm(cdf_meaning),1,uncfrm_event_type_cd)
 IF (stat=1)
  EXECUTE then
  SET uar_failed = 1
  GO TO skip_rest
 ENDIF
#skip_rest
 IF (uar_failed=1)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "bbt_product_return"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "uar failed"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "F"
  GO TO exit_script
 ENDIF
 SET nbr_to_update = size(request->productlist,5)
 SET stat = alter(reply->results,nbr_to_update)
 SET stat = alter(reply->status_data.subeventstatus,nbr_to_update)
 IF (nbr_to_update > 0
  AND (request->frominterfaceflag=0))
  CALL populate_outbound_products(null)
  IF (size(outbound_products->products,5) > 0)
   SET rtscallflag = 1
  ELSE
   FREE SET outbound_products
  ENDIF
 ENDIF
 FOR (prod = 1 TO nbr_to_update)
   SET failure_occured = "F"
   SET active_quar = "F"
   SET active_uncfrm = "F"
   SET active_avail = "F"
   SET multiple_xm = "F"
   SET multiple_events = "F"
   SET emergency_dispense = "F"
   SET bactiveautoflag = "F"
   SET bactivedirflag = "F"
   SET bdisponlyflag = "F"
   SET this_id = request->productlist[prod].product_id
   SET count2 = (prod+ 1)
   IF (count2 <= nbr_to_update)
    FOR (count1 = count2 TO nbr_to_update)
      IF ((this_id=request->productlist[count1].product_id))
       SET multiple_events = "T"
      ENDIF
    ENDFOR
   ENDIF
   SELECT INTO "nl:"
    pe.product_event_id
    FROM product_event pe
    WHERE (pe.product_event_id=request->productlist[prod].trans_prod_event_id)
    DETAIL
     reply->results[prod].transfused_dt_tm = pe.event_dt_tm, reply->results[prod].trans_order_id = pe
     .order_id, reply->results[prod].trans_personnel_id = pe.event_prsnl_id
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    pe.product_event_id
    FROM product_event pe
    WHERE pe.active_ind=1
     AND (pe.product_id=request->productlist[prod].product_id)
    ORDER BY pe.product_id
    HEAD pe.product_id
     pr_cnt = 0
    DETAIL
     pr_cnt += 1
     IF (pe.event_type_cd=quar_event_type_cd)
      active_quar = "T"
     ELSEIF (pe.event_type_cd=uncfrm_event_type_cd)
      active_uncfrm = "T"
     ELSEIF (pe.event_type_cd=avail_event_type_cd)
      active_avail = "T"
     ELSEIF (pe.event_type_cd=xmtch_event_type_cd
      AND (pe.product_event_id != request->productlist[prod].assgn_prod_event_id))
      multiple_xm = "T"
     ELSEIF (pe.event_type_cd=auto_event_type_cd)
      bactiveautoflag = "T"
     ELSEIF (pe.event_type_cd=dir_event_type_cd)
      bactivedirflag = "T"
     ENDIF
    FOOT  pe.product_id
     IF (pe.event_type_cd=dispns_event_type_cd
      AND pr_cnt=1)
      bdisponlyflag = "T"
     ENDIF
    WITH counter
   ;end select
   SET nbr_quar_reasons = size(request->productlist[prod].quarlist,5)
   IF ((request->productlist[prod].quar_flag="T")
    AND failure_occured="F")
    FOR (quarcnt = 1 TO nbr_quar_reasons)
     CALL add_product_event(request->productlist[prod].product_id,0,0,0,0,
      quar_event_type_cd,cnvtdatetime(request->productlist[prod].return_dt_tm),reqinfo->updt_id,0,0,
      0,0,1,reqdata->active_status_cd,cnvtdatetime(sysdate),
      reqinfo->updt_id)
     IF (curqual=0)
      SET error_process = "add product_event"
      SET error_message = "quarantine product_event row not added"
      SET failure_occured = "T"
     ELSE
      INSERT  FROM quarantine qu
       SET qu.product_event_id = product_event_id, qu.product_id = request->productlist[prod].
        product_id, qu.quar_reason_cd = request->productlist[prod].quarlist[quarcnt].quar_reason_cd,
        qu.orig_quar_qty =
        IF ((request->productlist[prod].product_type="B")) 0
        ELSE request->productlist[prod].return_qty
        ENDIF
        , qu.cur_quar_qty =
        IF ((request->productlist[prod].product_type="B")) 0
        ELSE request->productlist[prod].return_qty
        ENDIF
        , qu.orig_quar_intl_units =
        IF ((request->productlist[prod].product_type="B")) 0
        ELSE request->productlist[prod].return_iu
        ENDIF
        ,
        qu.cur_quar_intl_units =
        IF ((request->productlist[prod].product_type="B")) 0
        ELSE request->productlist[prod].return_iu
        ENDIF
        , qu.updt_cnt = 0, qu.updt_dt_tm = cnvtdatetime(sysdate),
        qu.updt_id = reqinfo->updt_id, qu.updt_task = reqinfo->updt_task, qu.updt_applctx = reqinfo->
        updt_applctx,
        qu.active_ind = 1, qu.active_status_cd = reqdata->active_status_cd, qu.active_status_dt_tm =
        cnvtdatetime(sysdate),
        qu.active_status_prsnl_id = reqinfo->updt_id
       WITH counter
      ;end insert
      IF (curqual=0)
       SET error_process = "add quarantine"
       SET error_message = "quarantine event row not added"
       SET failure_occured = "T"
      ENDIF
     ENDIF
    ENDFOR
   ENDIF
   IF ((request->productlist[prod].transfuse_flag="T")
    AND failure_occured="F")
    IF ((request->productlist[prod].product_type != "B"))
     SELECT INTO "nl:"
      d.product_id, d.item_volume, pi.product_cd
      FROM derivative d,
       product_index pi
      PLAN (d
       WHERE (d.product_id=request->productlist[prod].product_id))
       JOIN (pi
       WHERE d.product_cd=pi.product_cd)
      DETAIL
       volume_val = d.item_volume, iu_ind = pi.intl_units_ind
      WITH nocounter
     ;end select
    ENDIF
    SELECT INTO "nl:"
     tr.product_id, tr.product_event_id
     FROM transfusion tr
     PLAN (tr
      WHERE (tr.product_event_id=request->productlist[prod].trans_prod_event_id)
       AND (tr.product_id=request->productlist[prod].product_id)
       AND (tr.updt_cnt=request->productlist[prod].trans_updt_cnt))
     DETAIL
      quantity_val = tr.cur_transfused_qty, quantity_iu = tr.transfused_intl_units
     WITH nocounter, forupdate(tr)
    ;end select
    IF (curqual=0)
     SET error_process = "lock transfusion"
     SET error_message = "transfusion not locked"
     SET failure_occured = "T"
    ELSE
     SET unreturned_qty = (quantity_val - request->productlist[prod].return_qty)
     SET unreturned_iu = (quantity_iu - request->productlist[prod].return_iu)
     SELECT INTO "nl:"
      pe.product_id, pe.product_event_id
      FROM product_event pe
      PLAN (pe
       WHERE (pe.product_event_id=request->productlist[prod].trans_prod_event_id)
        AND (pe.product_id=request->productlist[prod].product_id)
        AND (pe.updt_cnt=request->productlist[prod].trans_pe_updt_cnt))
      DETAIL
       request->productlist[prod].pd_prod_event_id = pe.related_product_event_id
      WITH nocounter, forupdate(pe)
     ;end select
     IF (curqual=0)
      SET error_process = "lock product_event"
      SET error_message = "product_event not locked"
      SET failure_occured = "T"
     ELSE
      UPDATE  FROM transfusion tr
       SET tr.cur_transfused_qty =
        IF ((request->productlist[prod].product_type="B")) 0
        ELSEIF ((quantity_val <= request->productlist[prod].return_qty)) 0
        ELSE (quantity_val - request->productlist[prod].return_qty)
        ENDIF
        , tr.transfused_intl_units =
        IF ((request->productlist[prod].product_type="B")) 0
        ELSE (quantity_iu - request->productlist[prod].return_iu)
        ENDIF
        , tr.transfused_vol =
        IF ((request->productlist[prod].product_type="B")) 0
        ELSE
         IF (iu_ind=0) ((quantity_val - request->productlist[prod].return_qty) * volume_val)
         ELSE (quantity_iu - request->productlist[prod].return_iu)
         ENDIF
        ENDIF
        ,
        tr.updt_cnt = (tr.updt_cnt+ 1), tr.updt_dt_tm = cnvtdatetime(sysdate), tr.updt_task = reqinfo
        ->updt_task,
        tr.updt_id = reqinfo->updt_id, tr.updt_applctx = reqinfo->updt_applctx, tr.active_ind =
        IF ((request->productlist[prod].product_type="B")) 0
        ELSEIF ((quantity_val <= request->productlist[prod].return_qty)) 0
        ELSE 1
        ENDIF
        ,
        tr.active_status_cd =
        IF ((request->productlist[prod].product_type="B")) reqdata->inactive_status_cd
        ELSEIF ((quantity_val <= request->productlist[prod].return_qty)) reqdata->inactive_status_cd
        ELSE reqdata->active_status_cd
        ENDIF
       PLAN (tr
        WHERE (tr.product_event_id=request->productlist[prod].trans_prod_event_id)
         AND (tr.product_id=request->productlist[prod].product_id)
         AND (tr.updt_cnt=request->productlist[prod].trans_updt_cnt))
       WITH counter
      ;end update
      IF (curqual=0)
       SET error_process = "update transfusion"
       SET error_message = "transfusion not updated"
       SET failure_occured = "T"
      ELSE
       UPDATE  FROM product_event pe
        SET pe.active_ind =
         IF ((request->productlist[prod].product_type="B")) 0
         ELSEIF ((quantity_val <= request->productlist[prod].return_qty)) 0
         ELSE 1
         ENDIF
         , pe.active_status_cd =
         IF ((quantity_val <= request->productlist[prod].return_qty)) reqdata->inactive_status_cd
         ELSE reqdata->active_status_cd
         ENDIF
         , pe.updt_cnt = (pe.updt_cnt+ 1),
         pe.updt_dt_tm = cnvtdatetime(sysdate), pe.updt_task = reqinfo->updt_task, pe.updt_id =
         reqinfo->updt_id,
         pe.updt_applctx = reqinfo->updt_applctx
        PLAN (pe
         WHERE (pe.product_event_id=request->productlist[prod].trans_prod_event_id)
          AND (pe.product_id=request->productlist[prod].product_id)
          AND (pe.updt_cnt=request->productlist[prod].trans_pe_updt_cnt))
        WITH counter
       ;end update
       IF (curqual=0)
        SET error_process = "update event"
        SET error_message = "transfusion product_event not updated"
        SET failure_occured = "T"
       ENDIF
      ENDIF
     ENDIF
    ENDIF
    IF ((request->productlist[prod].rel_assign_flag="F")
     AND (request->productlist[prod].rel_xmatch_flag="F")
     AND (request->productlist[prod].assgn_prod_event_id > 0)
     AND (request->productlist[prod].product_type="B")
     AND failure_occured="F")
     SELECT INTO "nl:"
      pe.product_event_id, a.product_event_id, xm.product_event_id,
      tablefrom = decode(a.seq,"asgn",xm.seq,"xmtc","unkn")
      FROM assign a,
       crossmatch xm,
       product_event pe,
       (dummyt d1  WITH seq = 1)
      PLAN (pe
       WHERE (pe.product_event_id=request->productlist[prod].assgn_prod_event_id)
        AND (pe.updt_cnt=request->productlist[prod].pe_as_updt_cnt))
       JOIN (d1
       WHERE d1.seq=1)
       JOIN (((a
       WHERE (a.product_event_id=request->productlist[prod].assgn_prod_event_id)
        AND (a.updt_cnt=request->productlist[prod].as_updt_cnt))
       ) ORJOIN ((xm
       WHERE (xm.product_event_id=request->productlist[prod].assgn_prod_event_id)
        AND (xm.updt_cnt=request->productlist[prod].as_updt_cnt))
       ))
      DETAIL
       IF (tablefrom="asgn")
        thistable = "asgn"
       ELSEIF (tablefrom="xmtc")
        thistable = "xmtc"
       ENDIF
      WITH nocounter
     ;end select
     IF (curqual=0)
      SET failure_occured = "T"
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[prod].operationname = "lock"
      SET reply->status_data.subeventstatus[prod].operationstatus = "F"
      SET error_process = "lock tables for update"
      SET error_message = "reinstate: unable to lock tables for update"
     ELSE
      UPDATE  FROM product_event pe
       SET pe.active_ind = 1, pe.active_status_cd = reqdata->active_status_cd, pe.updt_cnt = (pe
        .updt_cnt+ 1),
        pe.updt_dt_tm = cnvtdatetime(sysdate), pe.updt_task = reqinfo->updt_task, pe.updt_id =
        reqinfo->updt_id,
        pe.updt_applctx = reqinfo->updt_applctx
       PLAN (pe
        WHERE (pe.product_event_id=request->productlist[prod].assgn_prod_event_id)
         AND (pe.updt_cnt=request->productlist[prod].pe_as_updt_cnt))
       WITH counter
      ;end update
      IF (curqual=0)
       SET reply->status_data.status = "F"
       SET reply->status_data.subeventstatus[prod].operationname = "update"
       SET reply->status_data.subeventstatus[prod].operationstatus = "F"
       SET error_process = "update product event"
       SET error_message = "reinstate product_event for assign/xmatch not updated"
       SET failure_occured = "T"
      ELSEIF (thistable="asgn")
       UPDATE  FROM assign a
        SET a.updt_cnt = (a.updt_cnt+ 1), a.updt_dt_tm = cnvtdatetime(sysdate), a.updt_id = reqinfo->
         updt_id,
         a.updt_task = reqinfo->updt_task, a.updt_applctx = reqinfo->updt_applctx, a.active_ind = 1,
         a.active_status_cd = reqdata->active_status_cd
        WHERE (a.product_event_id=request->productlist[prod].assgn_prod_event_id)
         AND (a.updt_cnt=request->productlist[prod].as_updt_cnt)
        WITH nocounter
       ;end update
       IF (curqual=0)
        SET failure_occured = "T"
        SET reply->status_data.status = "F"
        SET reply->status_data.subeventstatus[prod].operationname = "chg"
        SET reply->status_data.subeventstatus[prod].operationstatus = "F"
        SET error_process = "reisntate assign"
        SET error_message = "unable to reistate assign"
       ENDIF
      ELSEIF (thistable="xmtc")
       UPDATE  FROM crossmatch xm
        SET xm.updt_cnt = (xm.updt_cnt+ 1), xm.updt_dt_tm = cnvtdatetime(sysdate), xm.updt_id =
         reqinfo->updt_id,
         xm.updt_task = reqinfo->updt_task, xm.updt_applctx = reqinfo->updt_applctx, xm.active_ind =
         1,
         xm.active_status_cd = reqdata->active_status_cd
        WHERE (xm.product_event_id=request->productlist[prod].assgn_prod_event_id)
         AND (xm.updt_cnt=request->productlist[prod].as_updt_cnt)
        WITH nocounter
       ;end update
       IF (curqual=0)
        SET failure_occured = "T"
        SET reply->status_data.status = "F"
        SET reply->status_data.subeventstatus[prod].operationname = "chg"
        SET reply->status_data.subeventstatus[prod].operationstatus = "F"
        SET error_process = "reinstate crossmatch"
        SET error_message = "unable to reinstate crossmatch"
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   IF ((request->productlist[prod].rel_assign_flag="T")
    AND failure_occured="F")
    SELECT INTO "nl:"
     a.product_id, a.product_event_id, pe.product_id,
     pe.product_event_id
     FROM assign a,
      product_event pe
     PLAN (a
      WHERE (a.product_event_id=request->productlist[prod].assgn_prod_event_id)
       AND (a.product_id=request->productlist[prod].product_id)
       AND (a.updt_cnt=request->productlist[prod].as_updt_cnt))
      JOIN (pe
      WHERE (pe.product_event_id=request->productlist[prod].assgn_prod_event_id)
       AND (pe.product_id=request->productlist[prod].product_id)
       AND pe.event_type_cd=assgn_event_type_cd
       AND (pe.updt_cnt=request->productlist[prod].pe_as_updt_cnt))
     DETAIL
      quantity_val = a.cur_assign_qty, quantity_iu = a.cur_assign_intl_units
     WITH nocounter
    ;end select
    IF (curqual != 0)
     SELECT INTO "nl:"
      a.product_id, a.product_event_id
      FROM assign a
      PLAN (a
       WHERE (a.product_event_id=request->productlist[prod].assgn_prod_event_id)
        AND (a.product_id=request->productlist[prod].product_id)
        AND (a.updt_cnt=request->productlist[prod].as_updt_cnt))
      WITH nocounter, forupdate(a)
     ;end select
     IF (curqual != 0)
      SELECT INTO "nl:"
       pe.product_id, pe.product_event_id
       FROM product_event pe
       PLAN (pe
        WHERE (pe.product_event_id=request->productlist[prod].assgn_prod_event_id)
         AND (pe.product_id=request->productlist[prod].product_id)
         AND pe.event_type_cd=assgn_event_type_cd
         AND (pe.updt_cnt=request->productlist[prod].pe_as_updt_cnt))
       WITH nocounter, forupdate(pe)
      ;end select
     ENDIF
    ENDIF
    IF (curqual=0)
     SET error_process = "lock assign/product_event"
     SET error_message = "assign/product_event not locked"
     SET failure_occured = "T"
    ELSE
     UPDATE  FROM assign a
      SET a.cur_assign_qty =
       IF ((request->productlist[prod].product_type="B")) 0
       ELSEIF ((quantity_val <= request->productlist[prod].return_qty)) 0
       ELSE (quantity_val - request->productlist[prod].return_qty)
       ENDIF
       , a.cur_assign_intl_units =
       IF ((request->productlist[prod].product_type="B")) 0
       ELSEIF ((quantity_val <= request->productlist[prod].return_iu)) 0
       ELSE (quantity_iu - request->productlist[prod].return_iu)
       ENDIF
       , a.updt_cnt = (a.updt_cnt+ 1),
       a.updt_dt_tm = cnvtdatetime(sysdate), a.updt_task = reqinfo->updt_task, a.updt_id = reqinfo->
       updt_id,
       a.updt_applctx = reqinfo->updt_applctx, a.active_ind =
       IF ((request->productlist[prod].product_type="B")) 0
       ELSEIF ((quantity_val <= request->productlist[prod].return_qty)) 0
       ELSE 1
       ENDIF
       , a.active_status_cd =
       IF ((request->productlist[prod].product_type="B")) reqdata->inactive_status_cd
       ELSEIF ((quantity_val <= request->productlist[prod].return_qty)) reqdata->inactive_status_cd
       ELSE reqdata->active_status_cd
       ENDIF
      PLAN (a
       WHERE (a.product_event_id=request->productlist[prod].assgn_prod_event_id)
        AND (a.product_id=request->productlist[prod].product_id)
        AND (a.updt_cnt=request->productlist[prod].as_updt_cnt))
      WITH counter
     ;end update
     IF (curqual=0)
      SET error_process = "update assign"
      SET error_message = "assign row not updated"
      SET failure_occured = "T"
     ELSE
      SELECT INTO "nl:"
       seqn = seq(pathnet_seq,nextval)
       FROM dual
       DETAIL
        assign_release_id = seqn
       WITH format, nocounter
      ;end select
      IF (curqual=0)
       SET error_process = "insert assign_release_id"
       SET error_message = "assign_release_id not generated"
       SET failure_occured = "T"
      ELSE
       INSERT  FROM assign_release ar
        SET ar.assign_release_id = assign_release_id, ar.product_event_id = request->productlist[prod
         ].assgn_prod_event_id, ar.release_reason_cd = request->productlist[prod].release_reason_cd,
         ar.release_dt_tm = cnvtdatetime(request->productlist[prod].return_dt_tm), ar
         .release_prsnl_id = reqinfo->updt_id, ar.release_qty =
         IF ((request->productlist[prod].product_type="B")) 0
         ELSE request->productlist[prod].return_qty
         ENDIF
         ,
         ar.release_intl_units =
         IF ((request->productlist[prod].product_type="B")) 0
         ELSE request->productlist[prod].return_iu
         ENDIF
         , ar.updt_cnt = 0, ar.updt_dt_tm = cnvtdatetime(sysdate),
         ar.updt_task = reqinfo->updt_task, ar.updt_id = reqinfo->updt_id, ar.updt_applctx = reqinfo
         ->updt_applctx,
         ar.active_ind = 1, ar.active_status_cd = reqdata->active_status_cd, ar.active_status_dt_tm
          = cnvtdatetime(sysdate),
         ar.active_status_prsnl_id = reqinfo->updt_id
        WITH nocounter
       ;end insert
       IF (curqual=0)
        SET error_process = "insert assign_release row"
        SET error_message = "assign_release row not updated"
        SET failure_occured = "T"
       ELSE
        UPDATE  FROM product_event pe
         SET pe.active_ind =
          IF ((request->productlist[prod].product_type="B")) 0
          ELSEIF ((quantity_val <= request->productlist[prod].return_qty)) 0
          ELSE 1
          ENDIF
          , pe.active_status_cd =
          IF ((request->productlist[prod].product_type="B")) reqdata->inactive_status_cd
          ELSEIF ((quantity_val <= request->productlist[prod].return_qty)) reqdata->
           inactive_status_cd
          ELSE reqdata->active_status_cd
          ENDIF
          , pe.active_status_dt_tm = cnvtdatetime(sysdate),
          pe.active_status_prsnl_id = reqinfo->updt_id, pe.updt_cnt = (pe.updt_cnt+ 1), pe.updt_dt_tm
           = cnvtdatetime(sysdate),
          pe.updt_task = reqinfo->updt_task, pe.updt_id = reqinfo->updt_id, pe.updt_applctx = reqinfo
          ->updt_applctx
         PLAN (pe
          WHERE (pe.product_event_id=request->productlist[prod].assgn_prod_event_id)
           AND (pe.product_id=request->productlist[prod].product_id)
           AND pe.event_type_cd=assgn_event_type_cd
           AND (pe.updt_cnt=request->productlist[prod].pe_as_updt_cnt))
         WITH counter
        ;end update
        IF (curqual=0)
         SET error_process = "update event"
         SET error_message = "assign product_event event row not updated"
         SET failure_occured = "T"
        ELSEIF (failure_occured="F"
         AND ((active_quar="F"
         AND active_uncfrm="F"
         AND multiple_xm="F"
         AND bactiveautoflag="F"
         AND bactivedirflag="F"
         AND (request->productlist[prod].product_type="B")) OR ((request->productlist[prod].
        product_type="D")))
         AND active_avail="F"
         AND (request->productlist[prod].quar_flag != "T"))
         CALL add_product_event(request->productlist[prod].product_id,0,0,0,0,
          avail_event_type_cd,cnvtdatetime(request->productlist[prod].return_dt_tm),reqinfo->updt_id,
          0,0,
          0,0,1,reqdata->active_status_cd,cnvtdatetime(sysdate),
          reqinfo->updt_id)
         IF (curqual=0)
          SET error_process = "add product_event"
          SET error_message = "available product_event row not added for assign"
          SET failure_occured = "T"
         ENDIF
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ELSEIF ((request->productlist[prod].rel_xmatch_flag="T")
    AND failure_occured="F")
    SELECT INTO "nl:"
     xm.product_id, xm.product_event_id
     FROM crossmatch xm
     PLAN (xm
      WHERE (xm.product_event_id=request->productlist[prod].assgn_prod_event_id)
       AND (xm.updt_cnt=request->productlist[prod].as_updt_cnt))
     DETAIL
      quantity_val = xm.crossmatch_qty
     WITH nocounter, forupdate(xm)
    ;end select
    IF (curqual=0)
     SET error_process = "lock crossmatch"
     SET error_message = "crossmatch not locked"
     SET failure_occured = "T"
    ELSE
     SELECT INTO "nl:"
      pe.product_id, pe.product_event_id
      FROM product_event pe
      PLAN (pe
       WHERE (pe.product_event_id=request->productlist[prod].assgn_prod_event_id)
        AND (pe.updt_cnt=request->productlist[prod].pe_as_updt_cnt))
      WITH nocounter, forupdate(pe)
     ;end select
     IF (curqual=0)
      SET error_process = "lock product_event"
      SET error_message = "product_event not locked"
      SET failure_occured = "T"
     ELSE
      UPDATE  FROM crossmatch xm
       SET xm.release_reason_cd = request->productlist[prod].release_reason_cd, xm.release_dt_tm =
        cnvtdatetime(request->productlist[prod].return_dt_tm), xm.release_prsnl_id = reqinfo->updt_id,
        xm.release_qty =
        IF ((request->productlist[prod].product_type="B")) 0
        ELSEIF ((quantity_val=request->productlist[prod].return_qty)) 0
        ELSE request->productlist[prod].return_qty
        ENDIF
        , xm.crossmatch_qty =
        IF ((request->productlist[prod].product_type="B")) 0
        ELSEIF ((quantity_val=request->productlist[prod].return_qty)) 0
        ELSE (quantity_val - request->productlist[prod].return_qty)
        ENDIF
        , xm.updt_cnt = (xm.updt_cnt+ 1),
        xm.updt_dt_tm = cnvtdatetime(sysdate), xm.updt_task = reqinfo->updt_task, xm.updt_id =
        reqinfo->updt_id,
        xm.updt_applctx = reqinfo->updt_applctx, xm.active_ind =
        IF ((request->productlist[prod].product_type="B")) 0
        ELSEIF ((quantity_val=request->productlist[prod].return_qty)) 0
        ELSE xm.active_ind
        ENDIF
        , xm.active_status_cd =
        IF ((request->productlist[prod].product_type="B")) reqdata->inactive_status_cd
        ELSEIF ((quantity_val=request->productlist[prod].return_qty)) reqdata->inactive_status_cd
        ELSE reqdata->active_status_cd
        ENDIF
       PLAN (xm
        WHERE (xm.product_event_id=request->productlist[prod].assgn_prod_event_id)
         AND (xm.product_id=request->productlist[prod].product_id)
         AND (xm.updt_cnt=request->productlist[prod].as_updt_cnt))
       WITH counter
      ;end update
      IF (curqual=0)
       SET error_process = "update crossmatch"
       SET error_message = "crossmatch not updated"
       SET failure_occured = "T"
      ELSE
       UPDATE  FROM product_event pe
        SET pe.active_ind =
         IF ((request->productlist[prod].product_type="B")) 0
         ELSEIF ((quantity_val=request->productlist[prod].return_qty)) 0
         ELSE 1
         ENDIF
         , pe.active_status_cd =
         IF ((request->productlist[prod].product_type="B")) reqdata->inactive_status_cd
         ELSEIF ((quantity_val=request->productlist[prod].return_qty)) reqdata->inactive_status_cd
         ELSE reqdata->active_status_cd
         ENDIF
         , pe.updt_cnt = (pe.updt_cnt+ 1),
         pe.updt_dt_tm = cnvtdatetime(sysdate), pe.updt_task = reqinfo->updt_task, pe.updt_id =
         reqinfo->updt_id,
         pe.updt_applctx = reqinfo->updt_applctx
        PLAN (pe
         WHERE (pe.product_event_id=request->productlist[prod].assgn_prod_event_id)
          AND (pe.product_id=request->productlist[prod].product_id)
          AND pe.event_type_cd=xmtch_event_type_cd
          AND (pe.updt_cnt=request->productlist[prod].pe_as_updt_cnt))
        WITH counter
       ;end update
       IF (curqual=0)
        SET error_process = "update event"
        SET error_message = "crossmatch product_event not updated"
        SET failure_occured = "T"
       ELSEIF (failure_occured="F"
        AND ((active_quar="F"
        AND active_uncfrm="F"
        AND multiple_xm="F"
        AND bactiveautoflag="F"
        AND bactivedirflag="F"
        AND (request->productlist[prod].product_type="B")) OR ((request->productlist[prod].
       product_type="D")))
        AND active_avail="F"
        AND (request->productlist[prod].quar_flag != "T"))
        CALL add_product_event(request->productlist[prod].product_id,0,0,0,0,
         avail_event_type_cd,cnvtdatetime(request->productlist[prod].return_dt_tm),reqinfo->updt_id,0,
         0,
         0,0,1,reqdata->active_status_cd,cnvtdatetime(sysdate),
         reqinfo->updt_id)
        IF (curqual=0)
         SET error_process = "add product_event"
         SET error_message = "available product_event row not added for crossmatch"
         SET failure_occured = "T"
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   IF ((((request->productlist[prod].transfuse_flag != "T")) OR ((request->productlist[prod].
   product_type="B")))
    AND failure_occured="F")
    SELECT INTO "nl:"
     pd.product_id, pd.product_event_id, pd.cur_dispense_qty
     FROM patient_dispense pd
     PLAN (pd
      WHERE (pd.product_event_id=request->productlist[prod].pd_prod_event_id)
       AND (pd.product_id=request->productlist[prod].product_id)
       AND (pd.updt_cnt=request->productlist[prod].pd_updt_cnt))
     DETAIL
      quantity_val = pd.cur_dispense_qty, quantity_iu = pd.cur_dispense_intl_units, location_cd = pd
      .dispense_from_locn_cd,
      emergency_dispense =
      IF (pd.unknown_patient_ind=1) "T"
      ELSE "F"
      ENDIF
     WITH nocounter, forupdate(pd)
    ;end select
    IF (curqual=0)
     SET error_process = "lock patient_dispense"
     SET error_message = "patient_dispense not locked"
     SET failure_occured = "T"
    ELSE
     SELECT INTO "nl:"
      pe.product_id, pe.product_event_id
      FROM product_event pe
      PLAN (pe
       WHERE (pe.product_event_id=request->productlist[prod].pd_prod_event_id)
        AND (pe.product_id=request->productlist[prod].product_id)
        AND pe.event_type_cd=dispns_event_type_cd
        AND (pe.updt_cnt=request->productlist[prod].pe_pd_updt_cnt))
      WITH nocounter, forupdate(pe)
     ;end select
     IF (curqual=0)
      SET error_process = "lock product_event"
      SET error_message = "product_event not locked"
      SET failure_occured = "T"
     ELSE
      UPDATE  FROM patient_dispense pd
       SET pd.dispense_status_flag = 3, pd.cur_dispense_qty =
        IF ((request->productlist[prod].product_type="B")) 0
        ELSEIF ((quantity_val <= request->productlist[prod].return_qty)) 0
        ELSE (pd.cur_dispense_qty - request->productlist[prod].return_qty)
        ENDIF
        , pd.cur_dispense_intl_units =
        IF ((request->productlist[prod].product_type="B")) 0
        ELSE (pd.cur_dispense_intl_units - request->productlist[prod].return_iu)
        ENDIF
        ,
        pd.updt_cnt = (pd.updt_cnt+ 1), pd.updt_dt_tm = cnvtdatetime(sysdate), pd.updt_task = reqinfo
        ->updt_task,
        pd.updt_id = reqinfo->updt_id, pd.updt_applctx = reqinfo->updt_applctx, pd.active_ind =
        IF ((request->productlist[prod].product_type="B")) 0
        ELSEIF ((quantity_val <= request->productlist[prod].return_qty)) 0
        ELSE 1
        ENDIF
        ,
        pd.active_status_cd =
        IF ((request->productlist[prod].product_type="B")) reqdata->inactive_status_cd
        ELSEIF ((quantity_val <= request->productlist[prod].return_qty)) reqdata->inactive_status_cd
        ELSE reqdata->active_status_cd
        ENDIF
       PLAN (pd
        WHERE (pd.product_event_id=request->productlist[prod].pd_prod_event_id)
         AND (pd.product_id=request->productlist[prod].product_id)
         AND (pd.updt_cnt=request->productlist[prod].pd_updt_cnt))
       WITH counter
      ;end update
      IF (curqual=0)
       SET error_process = "update patient_dispense"
       SET error_message = "patient_dispense not updated"
       SET failure_occured = "T"
      ELSE
       UPDATE  FROM product_event pe
        SET pe.updt_cnt = (pe.updt_cnt+ 1), pe.updt_dt_tm = cnvtdatetime(sysdate), pe.updt_task =
         reqinfo->updt_task,
         pe.updt_id = reqinfo->updt_id, pe.updt_applctx = reqinfo->updt_applctx, pe.active_ind =
         IF ((request->productlist[prod].product_type="B")) 0
         ELSEIF ((quantity_val <= request->productlist[prod].return_qty)) 0
         ELSE 1
         ENDIF
         ,
         pe.active_status_cd =
         IF ((request->productlist[prod].product_type="B")) reqdata->inactive_status_cd
         ELSEIF ((quantity_val <= request->productlist[prod].return_qty)) reqdata->inactive_status_cd
         ELSE reqdata->active_status_cd
         ENDIF
        PLAN (pe
         WHERE (pe.product_event_id=request->productlist[prod].pd_prod_event_id)
          AND (pe.product_id=request->productlist[prod].product_id)
          AND pe.event_type_cd=dispns_event_type_cd
          AND (pe.updt_cnt=request->productlist[prod].pe_pd_updt_cnt))
        WITH counter
       ;end update
       IF (curqual=0)
        SET error_process = "update event"
        SET error_message = "product_event not updated"
        SET failure_occured = "T"
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   IF (failure_occured="F")
    SELECT INTO "nl:"
     seqn = seq(pathnet_seq,nextval)
     FROM dual
     DETAIL
      dispense_return_id = seqn
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET error_process = "generate dispense_return_id"
     SET error_message = "dispense_return_id not generated"
     SET failure_occured = "T"
    ELSE
     INSERT  FROM dispense_return dr
      SET dr.product_event_id = request->productlist[prod].pd_prod_event_id, dr.dispense_return_id =
       dispense_return_id, dr.product_id = request->productlist[prod].product_id,
       dr.return_prsnl_id = reqinfo->updt_id, dr.return_qty = request->productlist[prod].return_qty,
       dr.return_intl_units = request->productlist[prod].return_iu,
       dr.return_dt_tm = cnvtdatetime(request->productlist[prod].return_dt_tm), dr.return_reason_cd
        = request->productlist[prod].return_reason_cd, dr.return_courier_id = request->productlist[
       prod].return_courier_id,
       dr.return_courier_text = request->productlist[prod].return_courier_text, dr.return_vis_insp_cd
        = request->productlist[prod].return_vis_insp_cd, dr.active_ind = 1,
       dr.active_status_cd = reqdata->active_status_cd, dr.active_status_dt_tm = cnvtdatetime(sysdate
        ), dr.active_status_prsnl_id = reqinfo->updt_id,
       dr.updt_cnt = 0, dr.updt_dt_tm = cnvtdatetime(sysdate), dr.updt_task = reqinfo->updt_task,
       dr.updt_id = reqinfo->updt_id, dr.updt_applctx = reqinfo->updt_applctx, dr
       .return_temperature_value = request->productlist[prod].return_temperature_value,
       dr.return_temperature_txt = request->productlist[prod].return_temperature_txt, dr
       .return_temperature_degree_cd = request->productlist[prod].return_temperature_degree_cd
      WITH counter
     ;end insert
     IF (curqual=0)
      SET error_process = "insert dispense_return"
      SET error_message = "dispense_return event row not added"
      SET failure_occured = "T"
     ELSE
      SET failure_occured = "F"
      IF ((request->productlist[prod].product_type="D")
       AND (request->productlist[prod].quar_flag != "T"))
       UPDATE  FROM derivative der
        SET der.cur_avail_qty = (der.cur_avail_qty+ request->productlist[prod].return_qty), der
         .cur_intl_units = (der.cur_intl_units+ request->productlist[prod].return_iu), der.updt_cnt
          =
         IF (multiple_events="F") (der.updt_cnt+ 1)
         ELSE der.updt_cnt
         ENDIF
         ,
         der.updt_dt_tm = cnvtdatetime(sysdate), der.updt_task = reqinfo->updt_task, der.updt_id =
         reqinfo->updt_id,
         der.updt_applctx = reqinfo->updt_applctx
        PLAN (der
         WHERE (der.product_id=request->productlist[prod].product_id)
          AND (der.updt_cnt=request->productlist[prod].der_updt_cnt))
        WITH counter
       ;end update
       IF (curqual=0)
        SET error_process = "updt derivative"
        SET error_message = "available qty not updated on derivative"
        SET failure_occured = "T"
       ELSEIF (active_avail="F"
        AND bactiveautoflag="F"
        AND bactivedirflag="F")
        CALL add_product_event(request->productlist[prod].product_id,0,0,0,0,
         avail_event_type_cd,cnvtdatetime(request->productlist[prod].return_dt_tm),reqinfo->updt_id,0,
         0,
         0,0,1,reqdata->active_status_cd,cnvtdatetime(sysdate),
         reqinfo->updt_id)
        IF (curqual=0)
         SET error_process = "add product_event"
         SET error_message = "available product_event row not added for assign"
         SET failure_occured = "T"
        ENDIF
       ENDIF
      ELSEIF ((request->productlist[prod].product_type="B")
       AND (request->productlist[prod].quar_flag != "T")
       AND (request->productlist[prod].rel_assign_flag="F")
       AND (request->productlist[prod].assgn_prod_event_id=0.0)
       AND active_quar="F"
       AND active_uncfrm="F"
       AND multiple_xm="F"
       AND ((emergency_dispense="T") OR (bdisponlyflag="T")) )
       CALL add_product_event(request->productlist[prod].product_id,0,0,0,0,
        avail_event_type_cd,cnvtdatetime(request->productlist[prod].return_dt_tm),reqinfo->updt_id,0,
        0,
        0,0,1,reqdata->active_status_cd,cnvtdatetime(sysdate),
        reqinfo->updt_id)
       IF (curqual=0)
        SET error_process = "add product_event"
        SET error_message = "available product_event row not added for assign"
        SET failure_occured = "T"
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   IF (failure_occured="F"
    AND multiple_events="F")
    SELECT INTO "nl:"
     p.product_id
     FROM product p
     PLAN (p
      WHERE (p.product_id=request->productlist[prod].product_id)
       AND (p.updt_cnt=request->productlist[prod].p_updt_cnt)
       AND p.locked_ind=1)
     WITH nocounter, forupdate(p)
    ;end select
    IF (curqual=0)
     SET error_process = "update product"
     SET error_message = "product not locked"
     SET failure_occured = "T"
    ELSE
     UPDATE  FROM product p
      SET p.locked_ind = 0, p.cur_inv_locn_cd = 0, p.interfaced_device_flag = 0,
       p.cur_dispense_device_id =
       IF ((request->frominterfaceflag > 0)) p.cur_dispense_device_id
       ELSE 0
       ENDIF
       , p.updt_cnt = (p.updt_cnt+ 1), p.updt_dt_tm = cnvtdatetime(sysdate),
       p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->
       updt_applctx
      PLAN (p
       WHERE (p.product_id=request->productlist[prod].product_id)
        AND (p.updt_cnt=request->productlist[prod].p_updt_cnt)
        AND p.locked_ind=1)
      WITH counter
     ;end update
     IF (curqual=0)
      SET error_process = "update product"
      SET error_message = "product not updated"
      SET failure_occured = "T"
     ENDIF
    ENDIF
   ENDIF
   IF ((request->productlist[prod].transfuse_flag="T")
    AND (request->productlist[prod].product_type="D")
    AND unreturned_qty > 0
    AND failure_occured="F")
    SET partial_req_cnt += 1
    SET stat = alterlist(partialreturnrequest->qual,partial_req_cnt)
    SET partialreturnrequest->qual[partial_req_cnt].product_id = request->productlist[prod].
    product_id
    SET partialreturnrequest->qual[partial_req_cnt].product_type = request->productlist[prod].
    product_type
    SET partialreturnrequest->qual[partial_req_cnt].trans_prod_event_id = request->productlist[prod].
    trans_prod_event_id
    SET partial_rep_cnt += 1
    SET stat = alterlist(partialreturnreply->qual,partial_rep_cnt)
    SET partialreturnreply->qual[partial_rep_cnt].product_id = request->productlist[prod].product_id
    SET partialreturnreply->qual[partial_rep_cnt].unreturned_qty = unreturned_qty
    SET partialreturnreply->qual[partial_rep_cnt].unreturned_iu = unreturned_iu
    SET partialreturnreply->qual[partial_rep_cnt].trans_order_id = reply->results[prod].
    trans_order_id
    SET partialreturnreply->qual[partial_rep_cnt].trans_personnel_id = reply->results[prod].
    trans_personnel_id
    SET partialreturnreply->qual[partial_rep_cnt].encntr_id = reply->results[prod].encntr_id
    SET partialreturnreply->qual[partial_rep_cnt].person_id = reply->results[prod].person_id
    SET partialreturnreply->qual[partial_rep_cnt].transfused_dt_tm = reply->results[prod].
    transfused_dt_tm
   ENDIF
   IF (failure_occured="F")
    SET reply->status_data.status = "S"
    SET reply->status_data.subeventstatus[prod].operationname = "Complete"
    SET reply->status_data.subeventstatus[prod].operationstatus = "S"
    SET reply->status_data.subeventstatus[prod].targetobjectname = "Tables Updated"
    SET reply->status_data.subeventstatus[prod].targetobjectvalue = "S"
    SET reply->results[prod].product_id = request->productlist[prod].product_id
    SET reply->results[prod].status = "S"
    SET reply->results[prod].err_process = "complete"
    SET reply->results[prod].err_message = "no errors"
    SET success_cnt += 1
   ENDIF
   IF (failure_occured="T")
    SET reply->status_data.subeventstatus[prod].operationname = error_process
    SET reply->status_data.subeventstatus[prod].operationstatus = "F"
    SET reply->status_data.subeventstatus[prod].targetobjectname = error_message
    SET reply->status_data.subeventstatus[prod].targetobjectvalue = "F"
    SET reply->results[prod].product_id = request->productlist[prod].product_id
    SET reply->results[prod].status = "F"
    SET reply->results[prod].err_process = error_process
    SET reply->results[prod].err_message = error_message
   ENDIF
 ENDFOR
 IF (rtscallflag=1)
  CALL send_system_rtn_stock_msg(null)
 ENDIF
 SET prod = size(request->productlist,5)
 SET nbr_to_append_req = size(partialreturnrequest->qual,5)
 SET nbr_to_append_rep = size(partialreturnreply->qual,5)
 IF (nbr_to_append_req > 0)
  SET stat = alter2(request->productlist,(prod+ nbr_to_append_req))
  SET stat = alter(reply->results,(prod+ nbr_to_append_req))
  FOR (count1 = 1 TO nbr_to_append_req)
    SET request->productlist[(prod+ count1)].product_id = partialreturnrequest->qual[count1].
    product_id
    SET request->productlist[(prod+ count1)].product_type = partialreturnrequest->qual[count1].
    product_type
    SET request->productlist[(prod+ count1)].trans_prod_event_id = partialreturnrequest->qual[count1]
    .trans_prod_event_id
    SET reply->results[(prod+ count1)].product_id = partialreturnreply->qual[count1].product_id
    SET reply->results[(prod+ count1)].unreturned_qty = partialreturnreply->qual[count1].
    unreturned_qty
    SET reply->results[(prod+ count1)].unreturned_iu = partialreturnreply->qual[count1].unreturned_iu
    SET reply->results[(prod+ count1)].trans_order_id = partialreturnreply->qual[count1].
    trans_order_id
    SET reply->results[(prod+ count1)].trans_personnel_id = partialreturnreply->qual[count1].
    trans_personnel_id
    SET reply->results[(prod+ count1)].encntr_id = partialreturnreply->qual[count1].encntr_id
    SET reply->results[(prod+ count1)].person_id = partialreturnreply->qual[count1].person_id
    SET reply->results[(prod+ count1)].transfused_dt_tm = partialreturnreply->qual[count1].
    transfused_dt_tm
  ENDFOR
 ENDIF
 IF ((reply->status_data.status != "F")
  AND success_cnt=nbr_to_update)
  SET g_sub_event_type_flag = 2
  SET g_sub_num_products = size(request->productlist,5)
  SET stat = insert_pn_recovery_data(0)
  IF (stat=1)
   SET reply->status_data.status = "S"
   SET reqinfo->commit_ind = 1
  ELSEIF (stat=2)
   SET reply->status_data.status = "S"
   SET reqinfo->commit_ind = 1
  ELSE
   SET reply->status_data.status = "F"
   SET reqinfo->commit_ind = 0
   GO TO exit_script
  ENDIF
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
 SUBROUTINE add_product_event_with_inventory_area_cd(sub_product_id,sub_person_id,sub_encntr_id,
  sub_order_id,sub_bb_result_id,sub_event_type_cd,sub_event_dt_tm,sub_event_prsnl_id,
  sub_event_status_flag,sub_override_ind,sub_override_reason_cd,sub_related_product_event_id,
  sub_active_ind,sub_active_status_cd,sub_active_status_dt_tm,sub_active_status_prsnl_id,sub_locn_cd)
   CALL echo(build(" PRODUCT_ID - ",sub_product_id," PERSON_ID - ",sub_person_id," ENCNTR_ID - ",
     sub_encntr_id," SUB_RODER_ID - ",sub_order_id," BB_RESULT_ID - ",sub_bb_result_id,
     " EVENT_TYPE_ID - ",sub_event_type_cd," EVENT_DT_TM_ID - ",sub_event_dt_tm," PRSNL_ID - ",
     sub_event_prsnl_id," EVENT_STATUS_FLAG - ",sub_event_status_flag," override_ind - ",
     sub_override_ind,
     " override_reason_cd - ",sub_override_reason_cd," related_pe_id - ",sub_related_product_event_id,
     " active_ind - ",
     sub_active_ind," active_status_cd - ",sub_active_status_cd," active_status_dt_tm - ",
     sub_active_status_dt_tm,
     " status_prsnl_id - ",sub_active_status_prsnl_id," inventoy_area_cd - ",sub_locn_cd))
   SET gsub_product_event_status = "  "
   SET product_event_id = 0.0
   SET sub_product_event_id = 0.0
   DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
   SET new_pathnet_seq = 0
   SELECT INTO "nl:"
    seqn = seq(pathnet_seq,nextval)
    FROM dual
    DETAIL
     new_pathnet_seq = seqn
    WITH format, nocounter
   ;end select
   IF (curqual=0)
    SET gsub_product_event_status = "FS"
   ELSE
    SET sub_product_event_id = new_pathnet_seq
    INSERT  FROM product_event pe
     SET pe.product_event_id = sub_product_event_id, pe.product_id = sub_product_id, pe.person_id =
      IF (sub_person_id=null) 0
      ELSE sub_person_id
      ENDIF
      ,
      pe.encntr_id =
      IF (sub_encntr_id=null) 0
      ELSE sub_encntr_id
      ENDIF
      , pe.order_id =
      IF (sub_order_id=null) 0
      ELSE sub_order_id
      ENDIF
      , pe.bb_result_id = sub_bb_result_id,
      pe.event_type_cd = sub_event_type_cd, pe.event_dt_tm = cnvtdatetime(sub_event_dt_tm), pe
      .event_prsnl_id = sub_event_prsnl_id,
      pe.event_status_flag = sub_event_status_flag, pe.override_ind = sub_override_ind, pe
      .override_reason_cd = sub_override_reason_cd,
      pe.related_product_event_id = sub_related_product_event_id, pe.active_ind = sub_active_ind, pe
      .active_status_cd = sub_active_status_cd,
      pe.active_status_dt_tm = cnvtdatetime(sub_active_status_dt_tm), pe.active_status_prsnl_id =
      sub_active_status_prsnl_id, pe.updt_cnt = 0,
      pe.updt_dt_tm = cnvtdatetime(sysdate), pe.updt_id = reqinfo->updt_id, pe.updt_task = reqinfo->
      updt_task,
      pe.updt_applctx = reqinfo->updt_applctx, pe.event_tz =
      IF (curutc=1) curtimezoneapp
      ELSE 0
      ENDIF
      , pe.inventory_area_cd = sub_locn_cd
     WITH nocounter
    ;end insert
    SET product_event_id = sub_product_event_id
    SET new_product_event_id = sub_product_event_id
    IF (curqual=0)
     SET gsub_product_event_status = "FA"
    ELSE
     SET gsub_product_event_status = "OK"
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE add_product_event(sub_product_id,sub_person_id,sub_encntr_id,sub_order_id,
  sub_bb_result_id,sub_event_type_cd,sub_event_dt_tm,sub_event_prsnl_id,sub_event_status_flag,
  sub_override_ind,sub_override_reason_cd,sub_related_product_event_id,sub_active_ind,
  sub_active_status_cd,sub_active_status_dt_tm,sub_active_status_prsnl_id)
   SET gsub_product_event_status = "  "
   SET product_event_id = 0.0
   SET sub_product_event_id = 0.0
   DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
   SET new_pathnet_seq = 0
   SELECT INTO "nl:"
    seqn = seq(pathnet_seq,nextval)
    FROM dual
    DETAIL
     new_pathnet_seq = seqn
    WITH format, nocounter
   ;end select
   IF (curqual=0)
    SET gsub_product_event_status = "FS"
   ELSE
    SET sub_product_event_id = new_pathnet_seq
    INSERT  FROM product_event pe
     SET pe.product_event_id = sub_product_event_id, pe.product_id = sub_product_id, pe.person_id =
      IF (sub_person_id=null) 0
      ELSE sub_person_id
      ENDIF
      ,
      pe.encntr_id =
      IF (sub_encntr_id=null) 0
      ELSE sub_encntr_id
      ENDIF
      , pe.order_id =
      IF (sub_order_id=null) 0
      ELSE sub_order_id
      ENDIF
      , pe.bb_result_id = sub_bb_result_id,
      pe.event_type_cd = sub_event_type_cd, pe.event_dt_tm = cnvtdatetime(sub_event_dt_tm), pe
      .event_prsnl_id = sub_event_prsnl_id,
      pe.event_status_flag = sub_event_status_flag, pe.override_ind = sub_override_ind, pe
      .override_reason_cd = sub_override_reason_cd,
      pe.related_product_event_id = sub_related_product_event_id, pe.active_ind = sub_active_ind, pe
      .active_status_cd = sub_active_status_cd,
      pe.active_status_dt_tm = cnvtdatetime(sub_active_status_dt_tm), pe.active_status_prsnl_id =
      sub_active_status_prsnl_id, pe.updt_cnt = 0,
      pe.updt_dt_tm = cnvtdatetime(sysdate), pe.updt_id = reqinfo->updt_id, pe.updt_task = reqinfo->
      updt_task,
      pe.updt_applctx = reqinfo->updt_applctx, pe.event_tz =
      IF (curutc=1) curtimezoneapp
      ELSE 0
      ENDIF
     WITH nocounter
    ;end insert
    SET product_event_id = sub_product_event_id
    SET new_product_event_id = sub_product_event_id
    IF (curqual=0)
     SET gsub_product_event_status = "FA"
    ELSE
     SET gsub_product_event_status = "OK"
    ENDIF
   ENDIF
 END ;Subroutine
 IF (success_cnt=0)
  SET reply->status_data.status = "F"
 ELSEIF (success_cnt < nbr_to_update)
  SET reply->status_data.status = "P"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 CALL log_message("---BBT_PRODUCT_RETURN ENDING",log_level_debug)
 CALL uar_sysdestroyhandle(hsys)
END GO
