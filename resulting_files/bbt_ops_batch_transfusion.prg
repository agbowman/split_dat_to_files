CREATE PROGRAM bbt_ops_batch_transfusion
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
 IF (validate(bbt_get_pref_def,999)=999)
  DECLARE bbt_get_pref_def = i2 WITH protect, constant(1)
  RECORD prefvalues(
    1 prefs[*]
      2 value = vc
  )
  RECORD flexspectransparams(
    1 params[*]
      2 index = i4
      2 transfusionstartrange = i4
      2 transfusionendrange = i4
      2 specimenexpiration = i4
  )
  RECORD encounterlocations(
    1 locs[*]
      2 encfacilitycd = f8
  )
  DECLARE pref_level_bb = i2 WITH public, constant(1)
  DECLARE pref_level_flex = i2 WITH public, constant(2)
  DECLARE flex_spec_group = vc WITH protect, constant("flexible specimen")
  DECLARE pref_flex_spec_yes = vc WITH protect, constant("YES")
  DECLARE pref_flex_spec_no = vc WITH protect, constant("NO")
  DECLARE prefentryexists = i2 WITH protect, noconstant(0)
  DECLARE statbbpref = i2 WITH protect, noconstant(0)
 ENDIF
 SUBROUTINE (bbtgetencounterlocations(facility_code=f8(value),level_flag=i2(value)) =i2)
   DECLARE index = i2 WITH protect, noconstant(0)
   DECLARE loccnt = i2 WITH protect, noconstant(0)
   DECLARE prefcount = i2 WITH protect, noconstant(0)
   DECLARE flexprefentry = vc WITH protect, constant("patient encounter locations")
   SET statbbpref = initrec(encounterlocations)
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    flexprefentry)
   IF ((statbbpref=- (1)))
    IF (prefentryexists=1)
     RETURN(1)
    ELSE
     RETURN(- (1))
    ENDIF
   ENDIF
   SET prefcount = size(prefvalues->prefs,5)
   IF (prefcount=0)
    RETURN(1)
   ENDIF
   FOR (index = 1 TO prefcount)
     IF (cnvtreal(prefvalues->prefs[index].value) > 0.0)
      SET loccnt += 1
      IF (size(encounterlocations->locs,5) < loccnt)
       SET stat = alterlist(encounterlocations->locs,(loccnt+ 9))
      ENDIF
      SET encounterlocations->locs[loccnt].encfacilitycd = cnvtreal(prefvalues->prefs[index].value)
     ENDIF
   ENDFOR
   SET stat = alterlist(encounterlocations->locs,loccnt)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (bbtgethistoricinfopreference(facility_code=f8(value)) =i2)
   DECLARE historical_demog_ind = i2 WITH protect, noconstant(0)
   DECLARE testing_facility_cd = f8 WITH protect, noconstant(0.0)
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   DECLARE prefentry = vc WITH protect, constant("print historical demographics")
   DECLARE code_set = i4 WITH protect, constant(20790)
   DECLARE historycd = f8 WITH protect, constant(uar_get_code_by("MEANING",code_set,"HISTORY"))
   IF ((historycd=- (1)))
    RETURN(0)
   ENDIF
   SELECT INTO "nl:"
    FROM code_value_extension cve
    WHERE cve.code_value=historycd
     AND cve.field_name="OPTION"
     AND cve.code_set=code_set
    DETAIL
     IF (trim(cve.field_value,3)="1")
      historical_demog_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (historical_demog_ind=0)
    RETURN(0)
   ENDIF
   SET testing_facility_cd = bbtgetbbtestingfacility(facility_code)
   IF ((testing_facility_cd=- (1)))
    CALL log_message("Error getting BB transfusion service facility preference.",log_level_error)
    RETURN(- (1))
   ENDIF
   IF (testing_facility_cd=0.0)
    SET testing_facility_cd = facility_code
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(testing_facility_cd,32,2)),"","","",prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",
      testing_facility_cd)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("PrefEntry- ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    testing_facility_cd)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value="Yes"))
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetcustompacklistpreference(facility_code=f8(value)) =vc)
   DECLARE testing_facility_cd = f8 WITH protect, noconstant(0.0)
   DECLARE prefentry = vc WITH protect, constant("custom packing list program name")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET testing_facility_cd = bbtgetbbtestingfacility(facility_code)
   IF ((testing_facility_cd=- (1)))
    CALL log_message("Error getting BB transfusion service facility preference.",log_level_error)
    RETURN(- (1))
   ENDIF
   IF (testing_facility_cd=0.0)
    SET testing_facility_cd = facility_code
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(testing_facility_cd,32,2)),"","","",prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",
      testing_facility_cd)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN("")
   ENDIF
   SET strlogmessage = build("PrefEntry- ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    testing_facility_cd)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value=trim("")))
    RETURN("")
   ELSE
    RETURN(trim(prefvalues->prefs[1].value))
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetrequiredcourierdispenseassignpreference(facility_code=f8(value)) =i2)
   DECLARE testing_facility_cd = f8 WITH protect, noconstant(0.0)
   DECLARE prefentry = vc WITH protect, constant("require dispense courier")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET testing_facility_cd = bbtgetbbtestingfacility(facility_code)
   IF ((testing_facility_cd=- (1)))
    CALL log_message("Error getting BB transfusion service facility preference.",log_level_error)
    RETURN(- (1))
   ENDIF
   IF (testing_facility_cd=0.0)
    SET testing_facility_cd = facility_code
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(testing_facility_cd,32,2)),"","","",prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",
      testing_facility_cd)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN("")
   ENDIF
   SET strlogmessage = build("PrefEntry- ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    testing_facility_cd)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value=trim("")))
    RETURN("")
   ELSE
    RETURN(trim(prefvalues->prefs[1].value))
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetrequiredcourierreturnproductspreference(facility_code=f8(value)) =i2)
   DECLARE testing_facility_cd = f8 WITH protect, noconstant(0.0)
   DECLARE prefentry = vc WITH protect, constant("require return courier")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET testing_facility_cd = bbtgetbbtestingfacility(facility_code)
   IF ((testing_facility_cd=- (1)))
    CALL log_message("Error getting BB transfusion service facility preference.",log_level_error)
    RETURN(- (1))
   ENDIF
   IF (testing_facility_cd=0.0)
    SET testing_facility_cd = facility_code
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(testing_facility_cd,32,2)),"","","",prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",
      testing_facility_cd)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN("")
   ENDIF
   SET strlogmessage = build("PrefEntry- ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    testing_facility_cd)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value=trim("")))
    RETURN("")
   ELSE
    RETURN(trim(prefvalues->prefs[1].value))
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetinterfaceddevicespreference(facility_code=f8(value)) =i2)
   DECLARE prefentry = vc WITH protect, constant("uses interfaced devices")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","","",prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(0)
   ENDIF
   SET strlogmessage = build("PrefEntry- ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value="1"))
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetbbtestingfacility(facility_code=f8(value)) =f8)
   RETURN(bbtgetflexspectestingfacility(facility_code))
 END ;Subroutine
 SUBROUTINE (bbtgetflexspectestingfacility(facility_code=f8(value)) =f8)
   DECLARE prefentry = vc WITH protect, constant("transfusion service facility")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF ((((statbbpref=- (1))) OR (size(prefvalues->prefs,5) > 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("PrefEntry- ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(prefvalues->prefs,5)=1)
    IF (size(trim(prefvalues->prefs[1].value)) > 0)
     SET strlogmessage = build("PrefEntry- ",prefentry,":",prefvalues->prefs[1].value,
      ",Facility Code:",
      facility_code)
     CALL log_message(strlogmessage,log_level_debug)
     RETURN(cnvtreal(trim(prefvalues->prefs[1].value,3)))
    ELSE
     RETURN(0.0)
    ENDIF
   ELSE
    RETURN(0.0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetflexspecenableflexexpiration(facility_code=f8(value)) =i2)
   DECLARE prefentry = vc WITH protect, constant("enable flex expiration")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF ((((statbbpref=- (1))) OR (size(prefvalues->prefs,5) > 1)) )
    SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
    CALL log_message(strlogmessage,log_level_error)
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(prefvalues->prefs,5)=1)
    IF ((prefvalues->prefs[1].value="1"))
     RETURN(1)
    ELSE
     RETURN(0)
    ENDIF
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetflexspecdefclinsigantibodyparams(facility_code=f8(value)) =i2)
   DECLARE prefentry = vc WITH protect, constant("def clin sig antibody params")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value="1"))
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetflexspecxmalloexpunits(facility_code=f8(value)) =i4)
   DECLARE prefentry = vc WITH protect, constant("xm allogeneic expire units")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(trim(prefvalues->prefs[1].value)) > 0)
    RETURN(cnvtint(trim(prefvalues->prefs[1].value,3)))
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetflexspecxmautoexpunits(facility_code=f8(value)) =i4)
   DECLARE prefentry = vc WITH protect, constant("xm autologous expire units")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(trim(prefvalues->prefs[1].value)) > 0)
    RETURN(cnvtint(trim(prefvalues->prefs[1].value,3)))
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetflexspecmaxspecexpunits(facility_code=f8(value)) =i4)
   DECLARE prefentry = vc WITH protect, constant("max specimen expire units")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(trim(prefvalues->prefs[1].value)) > 0)
    RETURN(cnvtint(trim(prefvalues->prefs[1].value,3)))
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetflexspecclinsigantibodiesexpunits(facility_code=f8(value)) =i4)
   DECLARE prefentry = vc WITH protect, constant("clin sig antibodies exp units")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(trim(prefvalues->prefs[1].value)) > 0)
    RETURN(cnvtint(trim(prefvalues->prefs[1].value,3)))
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetflexspecextendtransfoverride(facility_code=f8(value)) =i2)
   DECLARE prefentry = vc WITH protect, constant("extend transf override")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(trim(prefvalues->prefs[1].value)) > 0)
    IF (cnvtupper(trim(prefvalues->prefs[1].value,3))=cnvtupper(pref_flex_spec_yes))
     RETURN(1)
    ELSEIF (cnvtupper(trim(prefvalues->prefs[1].value,3))=cnvtupper(pref_flex_spec_no))
     RETURN(0)
    ELSE
     RETURN(1)
    ENDIF
   ELSE
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetflexspeccalcposttransfspecsfromdawndt(facility_code=f8(value)) =i2)
   DECLARE prefentry = vc WITH protect, constant("calc post transf specs from drawn dt")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(trim(prefvalues->prefs[1].value)) > 0)
    IF (cnvtupper(trim(prefvalues->prefs[1].value,3))=cnvtupper(pref_flex_spec_yes))
     RETURN(1)
    ELSEIF (cnvtupper(trim(prefvalues->prefs[1].value,3))=cnvtupper(pref_flex_spec_no))
     RETURN(0)
    ELSE
     RETURN(0)
    ENDIF
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetflexspecexpunittypemean(facility_code=f8(value)) =c12)
   DECLARE prefentry = vc WITH protect, constant("flex spec expiration unit type")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN("")
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(trim(prefvalues->prefs[1].value)) > 0)
    RETURN(trim(prefvalues->prefs[1].value,3))
   ELSE
    RETURN("")
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetflexspecxmtagsprinter(facility_code=f8(value)) =vc)
   DECLARE prefentry = vc WITH protect, constant("xm tags printer")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN("")
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   RETURN(trim(prefvalues->prefs[1].value))
 END ;Subroutine
 SUBROUTINE (bbtgetflexspecexceptionrptprinter(facility_code=f8(value)) =vc)
   DECLARE prefentry = vc WITH protect, constant("exception rpt printer")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN("")
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   RETURN(trim(prefvalues->prefs[1].value))
 END ;Subroutine
 SUBROUTINE (bbtgetflexspectransfusionparameters(facility_code=f8(value)) =i2)
   DECLARE index = i2 WITH protect, noconstant(0)
   DECLARE prefcount = i2 WITH protect, noconstant(0)
   DECLARE strposhold = i2 WITH protect, noconstant(0)
   DECLARE strprevposhold = i2 WITH protect, noconstant(0)
   DECLARE strsize = i2 WITH protect, noconstant(0)
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   DECLARE maxparamitems = i2 WITH protect, constant(4)
   DECLARE prefentry = vc WITH protect, constant("transfusion parameters")
   SET statbbpref = initrec(flexspectransparams)
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   SET prefcount = size(prefvalues->prefs,5)
   IF (((statbbpref != 1) OR (prefcount < 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET statbbpref = alterlist(flexspectransparams->params,prefcount)
   FOR (index = 1 TO prefcount)
     SET strsize = 0
     SET strsize = size(prefvalues->prefs[index].value)
     SET strposhold = findstring(",",prefvalues->prefs[index].value)
     SET flexspectransparams->params[index].index = cnvtint(substring(1,(strposhold - 1),prefvalues->
       prefs[index].value))
     SET strprevposhold = strposhold
     SET strposhold = findstring(",",prefvalues->prefs[index].value,(strprevposhold+ 1))
     SET flexspectransparams->params[index].transfusionstartrange = cnvtint(substring((strprevposhold
       + 1),((strposhold - strprevposhold) - 1),prefvalues->prefs[index].value))
     SET strprevposhold = strposhold
     SET strposhold = findstring(",",prefvalues->prefs[index].value,(strprevposhold+ 1))
     SET flexspectransparams->params[index].transfusionendrange = cnvtint(substring((strprevposhold+
       1),((strposhold - strprevposhold) - 1),prefvalues->prefs[index].value))
     SET flexspectransparams->params[index].specimenexpiration = cnvtint(substring((strposhold+ 1),(
       strsize - strposhold),prefvalues->prefs[index].value))
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (getbbpreference(sfacilityctx=vc,spositionctx=vc,suserctx=vc,ssubgroup=vc,sprefentry=vc
  ) =i2)
   DECLARE success_ind = i2 WITH protect, noconstant(0)
   DECLARE hpref = i4 WITH protect, noconstant(0)
   DECLARE hgroup = i4 WITH protect, noconstant(0)
   DECLARE hsection = i4 WITH protect, noconstant(0)
   DECLARE hgroup2 = i4 WITH protect, noconstant(0)
   DECLARE hsubgroup = i4 WITH protect, noconstant(0)
   DECLARE hsubgroup2 = i4 WITH protect, noconstant(0)
   DECLARE hval = i4 WITH protect, noconstant(0)
   DECLARE hattr = i4 WITH protect, noconstant(0)
   DECLARE hentry = i4 WITH protect, noconstant(0)
   DECLARE idxentry = i4 WITH protect, noconstant(0)
   DECLARE idxattr = i4 WITH protect, noconstant(0)
   DECLARE idxval = i4 WITH protect, noconstant(0)
   DECLARE subgroupcount = i4 WITH protect, noconstant(0)
   DECLARE namelen = i4 WITH protect, noconstant(255)
   DECLARE entryname = c255 WITH protect, noconstant(fillstring(255," "))
   DECLARE entrycount = i4 WITH protect, noconstant(0)
   DECLARE attrcount = i4 WITH protect, noconstant(0)
   DECLARE valcount = i4 WITH protect, noconstant(0)
   DECLARE valname = c255 WITH protect, noconstant(fillstring(255," "))
   DECLARE subgroupexists = i2 WITH protect, noconstant(0)
   EXECUTE prefrtl
   SET statbbpref = initrec(prefvalues)
   SET prefentryexists = 0
   SET hpref = uar_prefcreateinstance(0)
   IF (hpref=0)
    CALL log_message("Bad hPref, try logging in",log_level_error)
    RETURN(- (1))
   ENDIF
   SET statbbpref = uar_prefaddcontext(hpref,"default","system")
   IF (statbbpref != 1)
    CALL uar_prefdestroyinstance(hpref)
    CALL log_message("Bad default context",log_level_error)
    RETURN(- (1))
   ENDIF
   IF (size(nullterm(sfacilityctx)) > 0)
    SET statbbpref = uar_prefaddcontext(hpref,"facility",nullterm(sfacilityctx))
    IF (statbbpref != 1)
     CALL uar_prefdestroyinstance(hpref)
     CALL log_message("Bad facility context",log_level_error)
     RETURN(- (1))
    ENDIF
   ENDIF
   IF (size(nullterm(spositionctx)) > 0)
    SET statbbpref = uar_prefaddcontext(hpref,"position",nullterm(spositionctx))
    IF (statbbpref != 1)
     CALL uar_prefdestroyinstance(hpref)
     CALL log_message("Bad position context",log_level_error)
     RETURN(- (1))
    ENDIF
   ENDIF
   IF (size(nullterm(suserctx)) > 0)
    SET statbbpref = uar_prefaddcontext(hpref,"user",nullterm(suserctx))
    IF (statbbpref != 1)
     CALL uar_prefdestroyinstance(hpref)
     CALL log_message("Bad user context",log_level_error)
     RETURN(- (1))
    ENDIF
   ENDIF
   SET statbbpref = uar_prefsetsection(hpref,"module")
   IF (statbbpref != 1)
    CALL uar_prefdestroyinstance(hpref)
    CALL log_message("Bad section",log_level_error)
    RETURN(- (1))
   ENDIF
   SET hgroup = uar_prefcreategroup()
   SET statbbpref = uar_prefsetgroupname(hgroup,"blood bank")
   IF (statbbpref != 1)
    CALL uar_prefdestroygroup(hgroup)
    CALL uar_prefdestroyinstance(hpref)
    CALL log_message("Bad group name",log_level_error)
    RETURN(- (1))
   ENDIF
   SET statbbpref = uar_prefaddgroup(hpref,hgroup)
   IF (statbbpref != 1)
    CALL uar_prefdestroygroup(hgroup)
    CALL uar_prefdestroyinstance(hpref)
    CALL log_message("Error adding group",log_level_error)
    RETURN(- (1))
   ENDIF
   IF (size(nullterm(ssubgroup)) > 0)
    SET subgroupexists = 1
    SET hsubgroup = uar_prefaddsubgroup(hgroup,nullterm(ssubgroup))
    IF (hsubgroup <= 0)
     CALL uar_prefdestroygroup(hgroup)
     CALL uar_prefdestroyinstance(hpref)
     CALL log_message("Error adding sub group",log_level_error)
     RETURN(- (1))
    ENDIF
   ENDIF
   SET statbbpref = uar_prefperform(hpref)
   IF (statbbpref != 1)
    CALL uar_prefdestroygroup(hgroup)
    CALL uar_prefdestroyinstance(hpref)
    CALL log_message("Error performing preference query",log_level_error)
    RETURN(- (1))
   ENDIF
   SET hsection = uar_prefgetsectionbyname(hpref,"module")
   SET hgroup2 = uar_prefgetgroupbyname(hsection,"blood bank")
   IF (subgroupexists=1)
    SET hsubgroup2 = uar_prefgetsubgroup(hgroup2,0)
    IF (hsubgroup2 <= 0)
     CALL uar_prefdestroysection(hsection)
     CALL uar_prefdestroygroup(hgroup2)
     CALL uar_prefdestroygroup(hgroup)
     CALL uar_prefdestroyinstance(hpref)
     CALL log_message("Error obtaining sub group",log_level_error)
     RETURN(- (1))
    ENDIF
    SET hgroup2 = hsubgroup2
   ENDIF
   SET entrycount = 0
   SET statbbpref = uar_prefgetgroupentrycount(hgroup2,entrycount)
   IF (statbbpref != 1)
    CALL uar_prefdestroysection(hsection)
    CALL uar_prefdestroygroup(hgroup2)
    CALL uar_prefdestroygroup(hgroup)
    CALL uar_prefdestroyinstance(hpref)
    CALL log_message("Error getting group entry count",log_level_error)
    RETURN(- (1))
   ENDIF
   IF (entrycount <= 0)
    CALL uar_prefdestroysection(hsection)
    CALL uar_prefdestroygroup(hgroup2)
    CALL uar_prefdestroygroup(hgroup)
    CALL uar_prefdestroyinstance(hpref)
    CALL log_message("Preferences not found",log_level_error)
    RETURN(0)
   ENDIF
   FOR (idxentry = 0 TO (entrycount - 1))
     SET hentry = uar_prefgetgroupentry(hgroup2,idxentry)
     SET namelen = 255
     SET entryname = fillstring(255," ")
     SET statbbpref = uar_prefgetentryname(hentry,entryname,namelen)
     IF (statbbpref != 1)
      CALL uar_prefdestroyentry(hentry)
      CALL uar_prefdestroysection(hsection)
      CALL uar_prefdestroygroup(hgroup2)
      CALL uar_prefdestroygroup(hgroup)
      CALL uar_prefdestroyinstance(hpref)
      CALL log_message("Error getting entry name",log_level_error)
      RETURN(- (1))
     ENDIF
     IF (nullterm(entryname)=nullterm(sprefentry))
      SET prefentryexists = 1
      SET attrcount = 0
      SET statbbpref = uar_prefgetentryattrcount(hentry,attrcount)
      IF (((statbbpref != 1) OR (attrcount=0)) )
       CALL uar_prefdestroyentry(hentry)
       CALL uar_prefdestroysection(hsection)
       CALL uar_prefdestroygroup(hgroup2)
       CALL uar_prefdestroygroup(hgroup)
       CALL uar_prefdestroyinstance(hpref)
       CALL log_message("Bad entryAttrCount",log_level_error)
       RETURN(- (1))
      ENDIF
      FOR (idxattr = 0 TO (attrcount - 1))
        SET hattr = uar_prefgetentryattr(hentry,idxattr)
        DECLARE attrname = c255
        SET namelen = 255
        SET statbbpref = uar_prefgetattrname(hattr,attrname,namelen)
        IF (nullterm(attrname)="prefvalue")
         SET valcount = 0
         SET statbbpref = uar_prefgetattrvalcount(hattr,valcount)
         SET idxval = 0
         SET statbbpref = alterlist(prefvalues->prefs,valcount)
         FOR (idxval = 0 TO (valcount - 1))
           SET valname = fillstring(255," ")
           SET namelen = 255
           SET hval = uar_prefgetattrval(hattr,valname,namelen,idxval)
           SET prefvalues->prefs[(idxval+ 1)].value = nullterm(valname)
         ENDFOR
         IF (hattr > 0)
          CALL uar_prefdestroyattr(hattr)
         ENDIF
         IF (hentry > 0)
          CALL uar_prefdestroyentry(hentry)
         ENDIF
         IF (hsection > 0)
          CALL uar_prefdestroysection(hsection)
         ENDIF
         IF (hgroup2 > 0)
          CALL uar_prefdestroygroup(hgroup2)
         ENDIF
         IF (hgroup > 0)
          CALL uar_prefdestroygroup(hgroup)
         ENDIF
         IF (hpref > 0)
          CALL uar_prefdestroyinstance(hpref)
         ENDIF
         RETURN(1)
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
   IF (hattr > 0)
    CALL uar_prefdestroyattr(hattr)
   ENDIF
   IF (hentry > 0)
    CALL uar_prefdestroyentry(hentry)
   ENDIF
   IF (hsection > 0)
    CALL uar_prefdestroysection(hsection)
   ENDIF
   IF (hgroup2 > 0)
    CALL uar_prefdestroygroup(hgroup2)
   ENDIF
   IF (hgroup > 0)
    CALL uar_prefdestroygroup(hgroup)
   ENDIF
   IF (hpref > 0)
    CALL uar_prefdestroyinstance(hpref)
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (bbtgetxmtagpreference(facility_code=f8(value)) =vc)
   DECLARE testing_facility_cd = f8 WITH protect, noconstant(0.0)
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   DECLARE prefentry = vc WITH protect, constant("crossmatch tag program name")
   SET testing_facility_cd = bbtgetbbtestingfacility(facility_code)
   IF ((testing_facility_cd=- (1)))
    CALL log_message("Error getting BB transfusion service facility preference.",log_level_error)
    RETURN(- (1))
   ENDIF
   IF (testing_facility_cd=0.0)
    SET testing_facility_cd = facility_code
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(testing_facility_cd,32,2)),"","","",prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",
      testing_facility_cd)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN("")
   ENDIF
   SET strlogmessage = build("PrefEntry- ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    testing_facility_cd)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value=trim("")))
    RETURN("")
   ELSE
    RETURN(trim(prefvalues->prefs[1].value))
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetcomponenttagpreference(facility_code=f8(value)) =vc)
   DECLARE testing_facility_cd = f8 WITH protect, noconstant(0.0)
   DECLARE prefentry = vc WITH protect, constant("component tag program name")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET testing_facility_cd = bbtgetbbtestingfacility(facility_code)
   IF ((testing_facility_cd=- (1)))
    CALL log_message("Error getting BB transfusion service facility preference.",log_level_error)
    RETURN(- (1))
   ENDIF
   IF (testing_facility_cd=0.0)
    SET testing_facility_cd = facility_code
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(testing_facility_cd,32,2)),"","","",prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",
      testing_facility_cd)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN("")
   ENDIF
   SET strlogmessage = build("PrefEntry- ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    testing_facility_cd)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value=trim("")))
    RETURN("")
   ELSE
    RETURN(trim(prefvalues->prefs[1].value))
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetemergencytagpreference(facility_code=f8(value)) =vc)
   DECLARE testing_facility_cd = f8 WITH protect, noconstant(0.0)
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   DECLARE prefentry = vc WITH protect, constant("emergency tag program name")
   SET testing_facility_cd = bbtgetbbtestingfacility(facility_code)
   IF ((testing_facility_cd=- (1)))
    CALL log_message("Error getting BB transfusion service facility preference.",log_level_error)
    RETURN(- (1))
   ENDIF
   IF (testing_facility_cd=0.0)
    SET testing_facility_cd = facility_code
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(testing_facility_cd,32,2)),"","","",prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",
      testing_facility_cd)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN("")
   ENDIF
   SET strlogmessage = build("PrefEntry- ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    testing_facility_cd)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value=trim("")))
    RETURN("")
   ELSE
    RETURN(trim(prefvalues->prefs[1].value))
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetflexfilterbyfacility(facility_code=f8(value)) =i2)
   DECLARE prefentry = vc WITH protect, constant("filter specimens by facility")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   DECLARE flex_on_ind = i2 WITH protect, noconstant(0)
   SET flex_on_ind = bbtgetflexspecenableflexexpiration(facility_code)
   IF (flex_on_ind=0)
    RETURN(0)
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(trim(prefvalues->prefs[1].value)) > 0)
    IF (cnvtupper(trim(prefvalues->prefs[1].value,3))=cnvtupper(pref_flex_spec_yes))
     RETURN(1)
    ENDIF
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (bbtdispgetproductorderassocpreference(facility_code=f8(value)) =vc)
   DECLARE testing_facility_cd = f8 WITH protect, noconstant(0.0)
   DECLARE prefentry = vc WITH protect, constant("associate to prod orders on dispense")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET testing_facility_cd = bbtgetbbtestingfacility(facility_code)
   IF ((testing_facility_cd=- (1)))
    CALL log_message("Error getting BB transfusion service facility preference.",log_level_error)
    RETURN("")
   ENDIF
   IF (testing_facility_cd=0.0)
    SET testing_facility_cd = facility_code
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(testing_facility_cd,32,2)),"","","",prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",
      testing_facility_cd)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN("")
   ENDIF
   SET strlogmessage = build("PrefEntry- ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    testing_facility_cd)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value=trim("")))
    RETURN("")
   ELSE
    IF (trim(prefvalues->prefs[1].value)="1")
     RETURN("Yes")
    ELSE
     RETURN("No")
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetflexspecahgxmatch(facility_code=f8(value)) =vc)
   DECLARE prefentry = vc WITH protect, constant("ahg crossmatch")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN("")
   ENDIF
   SET strlogmessage = build("PrefEntry- ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value=trim("")))
    RETURN("")
   ELSE
    IF (trim(prefvalues->prefs[1].value)="1")
     RETURN("Yes")
    ELSE
     RETURN("No")
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetaborhdiscrepancy(facility_code=f8(value)) =vc)
   DECLARE prefentry = vc WITH protect, constant("abo discrepancy")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN("")
   ENDIF
   SET strlogmessage = build("PrefEntry- ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value=trim("")))
    RETURN("")
   ELSE
    IF (trim(prefvalues->prefs[1].value)="1")
     RETURN("Yes")
    ELSE
     RETURN("No")
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetflexspecneonatedaysdefined(facility_code=f8(value)) =i4)
   DECLARE prefentry = vc WITH protect, constant("neonate day spec override")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(trim(prefvalues->prefs[1].value)) > 0)
    RETURN(cnvtint(trim(prefvalues->prefs[1].value,3)))
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetflexexpiredspecimenexpirationovrd(facility_code=f8(value)) =i2)
   DECLARE prefentry = vc WITH protect, constant("extend expired specimen expiration")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET flex_on_ind = bbtgetflexspecenableflexexpiration(facility_code)
   IF (flex_on_ind=0)
    RETURN(0)
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(trim(prefvalues->prefs[1].value)) > 0)
    IF (cnvtupper(trim(prefvalues->prefs[1].value,3))=cnvtupper(pref_flex_spec_yes))
     RETURN(1)
    ENDIF
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (bbtgetdisponcurrentaborh(facility_code=f8(value)) =i2)
   DECLARE prefentry = vc WITH protect, constant("dispense based on current aborh")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   DECLARE flex_on_ind = i2 WITH protect, noconstant(0)
   SET flex_on_ind = bbtgetflexspecenableflexexpiration(facility_code)
   IF (flex_on_ind=0)
    RETURN(0)
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(trim(prefvalues->prefs[1].value)) > 0)
    IF (cnvtupper(trim(prefvalues->prefs[1].value,3))=cnvtupper(pref_flex_spec_yes))
     RETURN(1)
    ENDIF
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (bbtgetdisponsecondaborh(facility_code=f8(value)) =i2)
   DECLARE prefentry = vc WITH protect, constant("dispense based on two aborh")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   DECLARE flex_on_ind = i2 WITH protect, noconstant(0)
   SET flex_on_ind = bbtgetflexspecenableflexexpiration(facility_code)
   IF (flex_on_ind=0)
    RETURN(0)
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(trim(prefvalues->prefs[1].value)) > 0)
    IF (cnvtupper(trim(prefvalues->prefs[1].value,3))=cnvtupper(pref_flex_spec_yes))
     RETURN(1)
    ENDIF
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (bbtgetflexexpiredspecimenneonatedischarge(facility_code=f8(value)) =i2)
   DECLARE prefentry = vc WITH protect, constant("extend neonate specimen discharge")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET flex_on_ind = bbtgetflexspecenableflexexpiration(facility_code)
   IF (flex_on_ind=0)
    RETURN(0)
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_debug)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(trim(prefvalues->prefs[1].value)) > 0)
    IF (cnvtupper(trim(prefvalues->prefs[1].value,3))=cnvtupper(pref_flex_spec_yes))
     RETURN(1)
    ENDIF
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (bbtcorrectcommentpromptpreference(facility_code=f8(value)) =vc)
   DECLARE testing_facility_cd = f8 WITH protect, noconstant(0.0)
   DECLARE prefentry = vc WITH protect, constant("result comment prompt")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET testing_facility_cd = bbtgetbbtestingfacility(facility_code)
   IF ((testing_facility_cd=- (1)))
    CALL log_message("Error getting BB transfusion service facility preference.",log_level_error)
    RETURN("")
   ENDIF
   IF (testing_facility_cd=0.0)
    SET testing_facility_cd = facility_code
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(testing_facility_cd,32,2)),"","","",prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",
      testing_facility_cd)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN("")
   ENDIF
   SET strlogmessage = build("PrefEntry- ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    testing_facility_cd)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value=trim("")))
    RETURN("")
   ELSE
    IF (trim(prefvalues->prefs[1].value)="1")
     RETURN("Yes")
    ELSE
     RETURN("No")
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE bbtprintdispenseencounteridentifier(facility_code)
   DECLARE prefentry = vc WITH protect, constant("print dispense encounter identifier")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","","",prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_debug)
    ENDIF
    RETURN(0)
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value="1"))
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetsamplevalidityorderspreference(facility_code=f8(value)) =vc)
   DECLARE testing_facility_cd = f8 WITH protect, noconstant(0.0)
   DECLARE prefentry = vc WITH protect, constant("sample validity qualifying orders")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   DECLARE strpref = vc WITH protect, noconstant("")
   SET testing_facility_cd = bbtgetbbtestingfacility(facility_code)
   IF ((testing_facility_cd=- (1)))
    CALL log_message("Error getting BB transfusion service facility preference.",log_level_error)
    RETURN(- (1))
   ENDIF
   IF (testing_facility_cd=0.0)
    SET testing_facility_cd = facility_code
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(testing_facility_cd,32,2)),"","","",prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) < 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",
      testing_facility_cd)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN("")
   ENDIF
   FOR (index = 1 TO size(prefvalues->prefs,5))
     IF (strpref="")
      SET strpref = concat(strpref,prefvalues->prefs[index].value)
     ELSE
      SET strpref = concat(strpref,",",prefvalues->prefs[index].value)
     ENDIF
   ENDFOR
   SET strlogmessage = build("PrefEntry- ",prefentry," : ",strpref,",Facility Code:",
    testing_facility_cd)
   CALL log_message(strlogmessage,log_level_debug)
   RETURN(strpref)
 END ;Subroutine
 SUBROUTINE bbtgetbbidtagpreference(facility_code)
   DECLARE prefentry = vc WITH protect, constant("disp bbid 2d tags")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","","",prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_debug)
    ENDIF
    RETURN(0)
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value="1"))
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetprodtagverifypreference(facility_code=f8(value)) =vc)
   DECLARE prefentry = vc WITH protect, constant("product tag verification")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","","",prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_debug)
    ENDIF
    RETURN(0)
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value="1"))
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 RECORD tag_req(
   1 debug_ind = i2
   1 tag_type = c20
   1 sub_tag_type = c20
   1 taglist[*]
     2 product_event_id = f8
   1 facility_cd = f8
 )
 RECORD tag_reply(
   1 rpt_filename = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE printtags(null) = i2
 DECLARE nproducteventcnt = i4 WITH protect, noconstant(0)
 DECLARE sprintqueue = vc WITH protect
 SUBROUTINE (addtagevent(product_event_id=f8(value)) =null)
   DECLARE stat = i2 WITH protect, noconstant(0)
   SET nproducteventcnt += 1
   SET stat = alterlist(tag_req->taglist,nproducteventcnt)
   SET tag_req->taglist[nproducteventcnt].product_event_id = product_event_id
 END ;Subroutine
 SUBROUTINE (initxmtagrequest(facility_cd=f8(value),printer_name=vc(value)) =null)
   DECLARE lstat = i4 WITH protect, noconstant(0)
   SET lstat = initrec(tag_req)
   SET lstat = initrec(tag_reply)
   SET nproducteventcnt = 0
   SET tag_req->debug_ind = 0
   SET tag_req->tag_type = "CROSSMATCH"
   SET tag_req->sub_tag_type = "REPRINT"
   SET tag_req->facility_cd = facility_cd
   SET sprintqueue = printer_name
 END ;Subroutine
 SUBROUTINE printtags(null)
   DECLARE ntagsok = i2 WITH protect, noconstant(0)
   IF (nproducteventcnt=0)
    SET ntagsok = 1
    CALL log_message("No tags to print",log_level_debug)
   ELSE
    CALL log_message("Calling bbt_tag_print_cntrl",log_level_debug)
    EXECUTE bbt_tag_print_ctrl  WITH replace("REQUEST","TAG_REQ"), replace("REPLY","TAG_REPLY")
    IF ((tag_reply->status_data.status != "S"))
     CALL populate_subeventstatus_msg(log_program_name,"F","Script Call","bbt_tag_print_cntrl failed",
      log_level_audit)
    ELSE
     IF (checkqueue(sprintqueue)=1)
      SET spool value(build("CER_PRINT:",tag_reply->rpt_filename)) value(sprintqueue)
      SET ntagsok = 1
     ELSE
      CALL log_message(build("Invalid Tag Queue",sprintqueue),log_level_debug)
     ENDIF
    ENDIF
   ENDIF
   RETURN(ntagsok)
 END ;Subroutine
 RECORD exception_request(
   1 beg_dt_tm = dq8
   1 end_dt_tm = dq8
   1 printer_name = vc
   1 batch_selection = c100
   1 output_dist = c100
   1 ops_date = dq8
   1 cur_owner_area_cd = f8
   1 cur_inv_area_cd = f8
   1 exception_type_cd = f8
   1 called_from_script_ind = i2
   1 address_location_cd = f8
   1 facility_cd = f8
   1 exception_ids[*]
     2 exception_id = f8
   1 null_ind = i2
 )
 RECORD exception_reply(
   1 rpt_list[*]
     2 rpt_filename = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE initexception(beg_dt_tm=dq8(value),end_dt_tm=dq8(value),printer_name=vc(value),
  exception_type_cd=f8(value),address_location_cd=f8(value),
  facility_cd=f8(value)) = null
 DECLARE printexeptions(null) = i2
 DECLARE nexceptioncnt = i4 WITH protect, noconstant(0)
 SUBROUTINE (addexception(exception_id=f8(value)) =null)
   DECLARE lstat = i4 WITH protect, noconstant(0)
   SET nexceptioncnt += 1
   SET lstat = alterlist(exception_request->exception_ids,nexceptioncnt)
   SET exception_request->exception_ids[nexceptioncnt].exception_id = exception_id
 END ;Subroutine
 SUBROUTINE initexceptionsrequest(beg_dt_tm,end_dt_tm,printer_name,exception_type_cd,
  address_location_cd,facility_cd)
   DECLARE lstat = i4 WITH protect, noconstant(0)
   SET lstat = initrec(exception_request)
   SET lstat = initrec(exception_reply)
   SET nexceptioncnt = 0
   SET exception_request->printer_name = printer_name
   SET exception_request->exception_type_cd = exception_type_cd
   SET exception_request->address_location_cd = address_location_cd
   SET exception_request->facility_cd = facility_cd
   SET exception_request->beg_dt_tm = beg_dt_tm
   SET exception_request->end_dt_tm = end_dt_tm
 END ;Subroutine
 SUBROUTINE printexceptions(null)
   DECLARE nexceptsok = i2 WITH protect, noconstant(0)
   IF (nexceptioncnt=0)
    SET nexceptsok = 1
    CALL log_message("No exceptions to print",log_level_debug)
   ELSE
    CALL log_message("Calling bbt_rpt_exception",log_level_debug)
    EXECUTE bbt_rpt_exception  WITH replace("REQUEST","EXCEPTION_REQUEST"), replace("REPLY",
     "EXCEPTION_REPLY")
    IF ((exception_reply->rpt_list[1].rpt_filename=""))
     CALL populate_subeventstatus_msg(log_program_name,"F","Script Call","bbt_rpt_exception failed",
      log_level_audit)
    ELSE
     IF (checkqueue(exception_request->printer_name)=1)
      SET spool value(exception_reply->rpt_list[1].rpt_filename) value(exception_request->
       printer_name)
      SET nexceptsok = 1
     ELSE
      CALL log_message(build("Invalid Report Queue",exception_request->printer_name),log_level_debug)
     ENDIF
    ENDIF
   ENDIF
   RETURN(nexceptsok)
 END ;Subroutine
 RECORD flexupdrequest(
   1 override_reason_cd = f8
   1 override_reason_mean = c12
   1 lock_prods_ind = i2
   1 persons[*]
     2 person_id = f8
     2 specimens[*]
       3 accession = c20
       3 specimen_id = f8
       3 facility_cd = f8
       3 encntr_id = f8
       3 testing_facility_cd = f8
       3 override_id = f8
       3 override_mean = c12
       3 drawn_dt_tm = dq8
       3 old_expire_dt_tm = dq8
       3 new_expire_dt_tm = dq8
       3 orders[*]
         4 order_id = f8
         4 products[*]
           5 product_id = f8
           5 product_event_id = f8
           5 product_type_cd = f8
           5 product_type_disp = vc
           5 old_xm_expire_dt_tm = dq8
 )
 RECORD flexupdreply(
   1 persons[*]
     2 person_id = f8
     2 specimens[*]
       3 specimen_id = f8
       3 drawn_dt_tm = dq8
       3 encntr_id = f8
       3 facility_cd = f8
       3 testing_facility_cd = f8
       3 accession = c20
       3 old_expire_dt_tm = dq8
       3 new_expire_dt_tm = dq8
       3 update_status_flag = i2
       3 new_override_id = f8
       3 orders[*]
         4 order_id = f8
         4 products[*]
           5 product_id = f8
           5 old_product_event_id = f8
           5 new_product_event_id = f8
           5 product_type_cd = f8
           5 product_type_disp = vc
           5 xm_status_flag = i2
           5 new_xm_expire_dt_tm = dq8
           5 old_xm_expire_dt_tm = dq8
       3 exception_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE flexupd_printreports(null) = i2
 DECLARE upd_stat_no_upd = i2 WITH protect, constant(0)
 DECLARE upd_stat_shortened = i2 WITH protect, constant(1)
 DECLARE upd_stat_lengthened = i2 WITH protect, constant(2)
 DECLARE upd_stat_expired = i2 WITH protect, constant(3)
 DECLARE upd_stat_error = i2 WITH protect, constant(4)
 DECLARE spec_ovrd_except_mean = c12 WITH protect, constant("FLEXSPEC")
 DECLARE spec_ovrd_except_cs = i4 WITH protect, constant(14072)
 DECLARE spec_ovrd_except_cd = f8 WITH protect, noconstant(0.0)
 SUBROUTINE flexupd_printreports(null)
   DECLARE nprintok = i2 WITH protect, noconstant(0)
   DECLARE nerrorfound = i2 WITH protect, noconstant(0)
   DECLARE stat = i4 WITH protect, noconstant(0)
   DECLARE personidx = i4 WITH protect, noconstant(0)
   DECLARE personcnt = i4 WITH protect, noconstant(0)
   DECLARE specimenidx = i4 WITH protect, noconstant(0)
   DECLARE specimencnt = i4 WITH protect, noconstant(0)
   DECLARE orderidx = i4 WITH protect, noconstant(0)
   DECLARE ordercnt = i4 WITH protect, noconstant(0)
   DECLARE productidx = i4 WITH protect, noconstant(0)
   DECLARE productcnt = i4 WITH protect, noconstant(0)
   DECLARE lasttestfaccd = f8 WITH protect, noconstant(0.0)
   DECLARE sexceptprinter = vc WITH protect, noconstant(" ")
   DECLARE stagprinter = vc WITH protect, noconstant(" ")
   DECLARE facilitychgind = i2 WITH protect, noconstant(0)
   DECLARE inittestfaccd = i2 WITH protect, noconstant(0)
   SET curalias flexspec flexupdreply->persons[personidx].specimens[specimenidx]
   SET spec_ovrd_except_cd = uar_get_code_by("MEANING",spec_ovrd_except_cs,nullterm(
     spec_ovrd_except_mean))
   IF (spec_ovrd_except_cd=0.0)
    CALL log_message("specimen override exception cd not found",log_level_audit)
    SET nerrorfound = 1
   ELSE
    SET personcnt = cnvtint(size(flexupdreply->persons,5))
    SET personidx = 1
    WHILE (personidx <= personcnt
     AND nerrorfound=0)
      SET specimencnt = cnvtint(size(flexupdreply->persons[personidx].specimens,5))
      SET specimenidx = 1
      WHILE (specimenidx <= specimencnt
       AND nerrorfound=0)
       IF ((flexspec->update_status_flag != upd_stat_no_upd))
        IF (inittestfaccd=0)
         SET inittestfaccd = 1
         SET facilitychgind = 1
        ELSEIF ((lasttestfaccd != flexspec->testing_facility_cd))
         IF (printexceptions(null)=0)
          SET nerrorfound = 1
         ELSE
          IF (printtags(null)=0)
           SET nerrorfound = 1
          ELSE
           SET facilitychgind = 1
          ENDIF
         ENDIF
        ELSE
         SET facilitychgind = 0
        ENDIF
        IF (nerrorfound=0)
         IF (facilitychgind=1)
          SET stagprinter = bbtgetflexspecxmtagsprinter(flexspec->testing_facility_cd)
          IF (size(trim(stagprinter))=0)
           SET nerrorfound = 1
          ELSE
           CALL initxmtagrequest(flexspec->testing_facility_cd,stagprinter)
           SET sexceptprinter = bbtgetflexspecexceptionrptprinter(flexspec->testing_facility_cd)
           IF (size(trim(sexceptprinter))=0)
            SET nerrorfound = 1
           ELSE
            CALL initexceptionsrequest(cnvtdatetime((curdate - 1),000000),cnvtdatetime(curdate,235999
              ),sexceptprinter,spec_ovrd_except_cd,flexspec->testing_facility_cd,
             0.0)
            SET lasttestfaccd = flexspec->testing_facility_cd
           ENDIF
          ENDIF
         ENDIF
        ENDIF
        IF (nerrorfound=0)
         CALL addexception(flexspec->exception_id)
         SET ordercnt = cnvtint(size(flexspec->orders,5))
         FOR (orderidx = 1 TO ordercnt)
          SET productcnt = cnvtint(size(flexspec->orders[orderidx].products,5))
          FOR (productidx = 1 TO productcnt)
            IF ((flexspec->orders[orderidx].products[productidx].xm_status_flag=upd_stat_shortened))
             CALL addtagevent(flexspec->orders[orderidx].products[productidx].new_product_event_id)
            ENDIF
          ENDFOR
         ENDFOR
        ENDIF
       ENDIF
       SET specimenidx += 1
      ENDWHILE
      SET personidx += 1
    ENDWHILE
    IF (nerrorfound=0)
     IF (printexceptions(null)=1)
      IF (printtags(null)=1)
       SET nprintok = 1
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   SET curalias flexspec off
   RETURN(nprintok)
 END ;Subroutine
 SUBROUTINE (determineexpandtotal(lactualsize=i4,lexpandsize=i4) =i4 WITH protect, noconstant(0))
   RETURN((ceil((cnvtreal(lactualsize)/ lexpandsize)) * lexpandsize))
 END ;Subroutine
 SUBROUTINE (determineexpandsize(lrecordsize=i4,lmaximumsize=i4) =i4 WITH protect, noconstant(0))
   DECLARE lreturn = i4 WITH protect, noconstant(0)
   IF (lrecordsize <= 1)
    SET lreturn = 1
   ELSEIF (lrecordsize <= 10)
    SET lreturn = 10
   ELSEIF (lrecordsize <= 500)
    SET lreturn = 50
   ELSE
    SET lreturn = 100
   ENDIF
   IF (lmaximumsize < lreturn)
    SET lreturn = lmaximumsize
   ENDIF
   RETURN(lreturn)
 END ;Subroutine
 RECORD getflexrequest(
   1 alert_ind = c1
   1 personlist[*]
     2 person_id = f8
     2 filter_encntr_id = f8
     2 encntr_facility_cd = f8
   1 facility_cd = f8
   1 app_key = c10
 )
 RECORD getflexreply(
   1 historical_demog_ind = i2
   1 personlist[*]
     2 alert_flag = c1
     2 person_id = f8
     2 new_sample_dt_tm = dq8
     2 name_full_formatted = c40
     2 specimen[*]
       3 specimen_id = f8
       3 encntr_id = f8
       3 override_id = f8
       3 override_cd = f8
       3 override_disp = vc
       3 override_mean = c12
       3 drawn_dt_tm = dq8
       3 unformatted_accession = c20
       3 accession = c20
       3 expire_dt_tm = dq8
       3 flex_on_ind = i2
       3 flex_max = i4
       3 flex_days_hrs_mean = c12
       3 historical_name = c40
       3 encntr_facility_cd = f8
       3 testing_facility_cd = f8
       3 orders[*]
         4 order_id = f8
         4 order_mnemonic = vc
         4 status = c40
         4 products[*]
           5 product_nbr_display = vc
           5 product_id = f8
           5 product_event_id = f8
           5 product_type_cd = f8
           5 product_type_disp = vc
           5 locked_ind = i2
           5 crossmatch_expire_dt_tm = dq8
           5 updt_applctx = f8
         4 order_status_cd = f8
         4 order_status_disp = vc
         4 order_status_mean = c12
         4 catalog_cd = f8
         4 catalog_disp = vc
         4 catalog_mean = c12
         4 phase_group_cd = f8
         4 phase_group_disp = vc
         4 phase_group_mean = c12
         4 encntr_id = f8
       3 max_expire_dt_tm = dq8
       3 max_expire_flag = i2
       3 is_expired_flag = i2
       3 assoc_neo_disch_encntr = i2
     2 active_specimen_exists = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD getflexlockedproducts(
   1 qual[*]
     2 product_id = f8
 )
 SUBROUTINE (lockflexproducts(lockind=i2(value)) =i2)
   DECLARE personcount = i4 WITH protect, noconstant(0)
   DECLARE personidx = i4 WITH protect, noconstant(0)
   DECLARE specimencount = i4 WITH protect, noconstant(0)
   DECLARE specimenidx = i4 WITH protect, noconstant(0)
   DECLARE orderscount = i4 WITH protect, noconstant(0)
   DECLARE ordersidx = i4 WITH protect, noconstant(0)
   DECLARE productscount = i4 WITH protect, noconstant(0)
   DECLARE productsidx = i4 WITH protect, noconstant(0)
   DECLARE qualcount = i4 WITH protect, noconstant(0)
   DECLARE qualidx = i4 WITH protect, noconstant(0)
   DECLARE stat = i4 WITH protect, noconstant(0)
   DECLARE actualsize = i4 WITH protect, noconstant(0)
   DECLARE expandsize = i4 WITH protect, noconstant(0)
   DECLARE expandtotal = i4 WITH protect, noconstant(0)
   DECLARE expandstart = i4 WITH protect, noconstant(1)
   IF (lockind=1)
    SET stat = initrec(getflexlockedproducts)
    SET personcount = size(getflexreply->personlist,5)
    FOR (personidx = 1 TO personcount)
     SET specimencount = size(getflexreply->personlist[personidx].specimen,5)
     FOR (specimenidx = 1 TO specimencount)
      SET orderscount = size(getflexreply->personlist[personidx].specimen[specimenidx].orders,5)
      FOR (ordersidx = 1 TO orderscount)
       SET productscount = size(getflexreply->personlist[personidx].specimen[specimenidx].orders[
        ordersidx].products,5)
       FOR (productsidx = 1 TO productscount)
         SET qualcount += 1
         IF (qualcount > size(getflexlockedproducts->qual,5))
          SET stat = alterlist(getflexlockedproducts->qual,(qualcount+ 9))
         ENDIF
         SET getflexlockedproducts->qual[qualcount].product_id = getflexreply->personlist[personidx].
         specimen[specimenidx].orders[ordersidx].products[productsidx].product_id
       ENDFOR
      ENDFOR
     ENDFOR
    ENDFOR
    SET stat = alterlist(getflexlockedproducts->qual,qualcount)
   ENDIF
   SET expandstart = 1
   SET actualsize = size(getflexlockedproducts->qual,5)
   IF (actualsize=0)
    RETURN(1)
   ENDIF
   SET expandsize = determineexpandsize(actualsize,100)
   SET expandtotal = determineexpandtotal(actualsize,expandsize)
   SET stat = alterlist(getflexlockedproducts->qual,expandtotal)
   FOR (productsidx = (actualsize+ 1) TO expandtotal)
     SET getflexlockedproducts->qual[productsidx].product_id = getflexlockedproducts->qual[actualsize
     ].product_id
   ENDFOR
   SELECT INTO "nl:"
    p.*
    FROM (dummyt d  WITH seq = value((expandtotal/ expandsize))),
     product p
    PLAN (d
     WHERE assign(expandstart,evaluate(d.seq,1,1,(expandstart+ expandsize))))
     JOIN (p
     WHERE expand(productsidx,expandstart,((expandstart+ expandsize) - 1),p.product_id,
      getflexlockedproducts->qual[productsidx].product_id))
    WITH nocounter, forupdate(p)
   ;end select
   SET stat = alterlist(getflexlockedproducts->qual,actualsize)
   IF (curqual != actualsize)
    RETURN(- (1))
   ENDIF
   SET expandstart = 1
   SET actualsize = size(getflexlockedproducts->qual,5)
   SET expandsize = determineexpandsize(actualsize,100)
   SET expandtotal = determineexpandtotal(actualsize,expandsize)
   SET stat = alterlist(getflexlockedproducts->qual,expandtotal)
   FOR (productsidx = (actualsize+ 1) TO expandtotal)
     SET getflexlockedproducts->qual[productsidx].product_id = getflexlockedproducts->qual[actualsize
     ].product_id
   ENDFOR
   UPDATE  FROM (dummyt d  WITH seq = value((expandtotal/ expandsize))),
     product p
    SET p.locked_ind = lockind, p.updt_cnt = (p.updt_cnt+ 1), p.updt_dt_tm = cnvtdatetime(sysdate),
     p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->
     updt_applctx
    PLAN (d
     WHERE assign(expandstart,evaluate(d.seq,1,1,(expandstart+ expandsize))))
     JOIN (p
     WHERE expand(productsidx,expandstart,((expandstart+ expandsize) - 1),p.product_id,
      getflexlockedproducts->qual[productsidx].product_id))
    WITH nocounter
   ;end update
   SET stat = alterlist(getflexlockedproducts->qual,actualsize)
   IF (curqual != actualsize)
    RETURN(- (1))
   ENDIF
   RETURN(1)
 END ;Subroutine
 DECLARE flexget_init(null) = null
 DECLARE flexget_run(null) = i2
 DECLARE flexupd_run(null) = i2
 DECLARE flexgetpersoncnt = i4 WITH protect, noconstant(0)
 SUBROUTINE flexget_init(null)
   DECLARE lstat = i4 WITH protect, noconstant(0)
   SET lstat = initrec(getflexrequest)
   SET lstat = initrec(getflexreply)
   SET lstat = initrec(flexupdrequest)
   SET lstat = initrec(flexupdreply)
   SET flexgetpersoncnt = 0
   SET getflexrequest->alert_ind = "N"
 END ;Subroutine
 SUBROUTINE (flexget_addperson(person_id=f8(value)) =null)
   DECLARE lstat = i4 WITH protect, noconstant(0)
   DECLARE lpersonidx = i4 WITH protect, noconstant(0)
   DECLARE lpersonnum = i4 WITH protect, noconstant(0)
   SET lpersonidx = locateval(lpersonnum,1,flexgetpersoncnt,person_id,getflexrequest->personlist[
    lpersonnum].person_id)
   IF (lpersonidx=0)
    SET flexgetpersoncnt += 1
    IF (flexgetpersoncnt > size(getflexrequest->personlist,5))
     SET lstat = alterlist(getflexrequest->personlist,(flexgetpersoncnt+ 19))
    ENDIF
    SET getflexrequest->personlist[flexgetpersoncnt].person_id = person_id
   ENDIF
 END ;Subroutine
 SUBROUTINE flexget_run(null)
   DECLARE lstat = i4 WITH protect, noconstant(0)
   DECLARE nflexgetok = i2 WITH protect, noconstant(0)
   IF (flexgetpersoncnt=0)
    SET nflexgetok = 1
    CALL log_message("No persons to get",log_level_debug)
   ELSE
    SET lstat = alterlist(getflexrequest->personlist,flexgetpersoncnt)
    CALL log_message("Calling bbt_get_avail_flex_specs",log_level_debug)
    EXECUTE bbt_get_avail_flex_specs  WITH replace("REQUEST","GETFLEXREQUEST"), replace("REPLY",
     "GETFLEXREPLY")
    SET modify = nopredeclare
    IF ((getflexreply->status_data.status="F"))
     CALL populate_subeventstatus_msg(log_program_name,"F","Script Call",
      "bbt_get_avail_flex_specs failed",log_level_audit)
    ELSEIF ((getflexreply->status_data.status="Z"))
     CALL log_message("No current specimens",log_level_debug)
     SET nflexgetok = 1
    ELSE
     SET nflexgetok = 1
    ENDIF
   ENDIF
   RETURN(nflexgetok)
 END ;Subroutine
 SUBROUTINE (flexprodtransfused(product_id=f8(value)) =i2)
   DECLARE lprodidx = i4 WITH protect, noconstant(0)
   DECLARE lprodnum = i4 WITH protect, noconstant(0)
   IF (validate(ops_request))
    SET lprodidx = locateval(lprodnum,1,size(ops_request->productlist,5),product_id,ops_request->
     productlist[lprodnum].product_id)
    IF (lprodidx=0)
     RETURN(0)
    ELSE
     IF ((ops_request->productlist[lprodidx].status="S"))
      RETURN(1)
     ELSE
      RETURN(0)
     ENDIF
    ENDIF
   ELSE
    IF (validate(reply->results))
     SET lprodidx = locateval(lprodnum,1,size(reply->results,5),product_id,reply->results[lprodnum].
      product_id)
     IF (lprodidx=0)
      RETURN(0)
     ELSE
      IF ((reply->results[lprodidx].status="S"))
       RETURN(1)
      ELSE
       RETURN(0)
      ENDIF
     ENDIF
    ELSE
     RETURN(0)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE flexupd_run(null)
   DECLARE lstat = i4 WITH protect, noconstant(0)
   DECLARE sys_trans_mean = c12 WITH protect, constant("SYS_TRANS")
   DECLARE ovrd_reason_cs = i4 WITH protect, constant(1621)
   DECLARE sys_trans_ovrd_cd = f8 WITH protect, noconstant(0.0)
   DECLARE updpersonind = i2 WITH protect, noconstant(0)
   DECLARE lavailpersoncnt = i4 WITH protect, noconstant(0)
   DECLARE lavailpersonidx = i4 WITH protect, noconstant(0)
   DECLARE lavailspeccnt = i4 WITH protect, noconstant(0)
   DECLARE lavailspecidx = i4 WITH protect, noconstant(0)
   DECLARE lavailordercnt = i4 WITH protect, noconstant(0)
   DECLARE lavailorderidx = i4 WITH protect, noconstant(0)
   DECLARE lavailprodcnt = i4 WITH protect, noconstant(0)
   DECLARE lavailprodidx = i4 WITH protect, noconstant(0)
   DECLARE lupdspeccnt = i4 WITH protect, noconstant(0)
   DECLARE lupdprodcnt = i4 WITH protect, noconstant(0)
   DECLARE nflexrunok = i2 WITH protect, noconstant(0)
   SET lavailpersoncnt = size(getflexreply->personlist,5)
   IF (lavailpersoncnt=0)
    SET nflexrunok = 1
   ELSE
    IF (validate(flex_patient_out->person_id,0.0) > 0.0)
     SET lstat = initrec(flex_patient_out)
    ENDIF
    SET sys_trans_ovrd_cd = uar_get_code_by("MEANING",ovrd_reason_cs,nullterm(sys_trans_mean))
    IF (sys_trans_ovrd_cd=0.0)
     SET uar_error = "Failed to retrieve sys_trans override reason"
     CALL populate_subeventstatus_msg(log_program_name,"F","uar_failed",uar_error,log_level_audit)
    ELSE
     SET flexupdrequest->override_reason_cd = sys_trans_ovrd_cd
     SET flexupdrequest->override_reason_mean = sys_trans_mean
     SET flexupdrequest->lock_prods_ind = 0
     SET curalias availspec getflexreply->personlist[lavailpersonidx].specimen[lavailspecidx]
     SET curalias availprod getflexreply->personlist[lavailpersonidx].specimen[lavailspecidx].orders[
     lavailorderidx].products[lavailprodidx]
     SET curalias updspec flexupdrequest->persons[lavailpersonidx].specimens[lupdspeccnt]
     SET curalias updprod flexupdrequest->persons[lavailpersonidx].specimens[lupdspeccnt].orders[
     lavailorderidx].products[lupdprodcnt]
     SET lstat = alterlist(flexupdrequest->persons,lavailpersoncnt)
     FOR (lavailpersonidx = 1 TO lavailpersoncnt)
       SET flexupdrequest->persons[lavailpersonidx].person_id = getflexreply->personlist[
       lavailpersonidx].person_id
       SET lupdspeccnt = 0
       SET lavailspeccnt = size(getflexreply->personlist[lavailpersonidx].specimen,5)
       FOR (lavailspecidx = 1 TO lavailspeccnt)
         IF ((availspec->flex_on_ind=1))
          SET updpersonind = 1
          SET lupdspeccnt += 1
          SET lstat = alterlist(flexupdrequest->persons[lavailpersonidx].specimens,lupdspeccnt)
          SET updspec->accession = availspec->accession
          SET updspec->specimen_id = availspec->specimen_id
          SET updspec->facility_cd = availspec->encntr_facility_cd
          SET updspec->encntr_id = availspec->encntr_id
          SET updspec->testing_facility_cd = availspec->testing_facility_cd
          SET updspec->override_id = availspec->override_id
          SET updspec->override_mean = availspec->override_mean
          SET updspec->drawn_dt_tm = availspec->drawn_dt_tm
          SET updspec->old_expire_dt_tm = availspec->expire_dt_tm
          SET lavailordercnt = size(getflexreply->personlist[lavailpersonidx].specimen[lavailspecidx]
           .orders,5)
          SET lstat = alterlist(flexupdrequest->persons[lavailpersonidx].specimens[lupdspeccnt].
           orders,lavailordercnt)
          FOR (lavailorderidx = 1 TO lavailordercnt)
            SET updspec->orders[lavailorderidx].order_id = availspec->orders[lavailorderidx].order_id
            SET lupdprodcnt = 0
            SET lavailprodcnt = size(getflexreply->personlist[lavailpersonidx].specimen[lavailspecidx
             ].orders[lavailorderidx].products,5)
            FOR (lavailprodidx = 1 TO lavailprodcnt)
              IF (flexprodtransfused(availprod->product_id)=0)
               SET lupdprodcnt += 1
               SET lstat = alterlist(flexupdrequest->persons[lavailpersonidx].specimens[lupdspeccnt].
                orders[lavailorderidx].products,(lupdprodcnt+ 9))
               SET updprod->product_id = availprod->product_id
               SET updprod->product_event_id = availprod->product_event_id
               SET updprod->product_type_cd = availprod->product_type_cd
               SET updprod->old_xm_expire_dt_tm = availprod->crossmatch_expire_dt_tm
              ENDIF
            ENDFOR
            SET lstat = alterlist(flexupdrequest->persons[lavailpersonidx].specimens[lupdspeccnt].
             orders[lavailorderidx].products,lupdprodcnt)
          ENDFOR
         ENDIF
       ENDFOR
     ENDFOR
     SET curalias availspec off
     SET curalias availprod off
     SET curalias updspec off
     SET curalias updprod off
     IF (updpersonind=0)
      SET nflexrunok = 1
     ELSE
      EXECUTE bbt_upd_flex_expiration  WITH replace("REQUEST","FLEXUPDREQUEST"), replace("REPLY",
       "FLEXUPDREPLY")
      IF (trim(flexupdreply->status_data.status)="S")
       SET nflexrunok = 1
      ELSE
       CALL populate_subeventstatus_msg(log_program_name,"F","Script Call",
        "bbt_upd_flex_expiration failed",log_level_audit)
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   RETURN(nflexrunok)
 END ;Subroutine
 SET log_program_name = "bbt_ops_batch_transfusion"
 RECORD ops_request(
   1 productlist[*]
     2 product_nbr = c20
     2 product_type = c1
     2 product_id = f8
     2 person_id = f8
     2 encounter_id = f8
     2 event_prsnl_id = f8
     2 bag_returned_ind = i2
     2 tag_returned_ind = i2
     2 transfused_vol = i4
     2 transfused_iu = i4
     2 transfused_qty = i4
     2 transfused_dt_tm = dq8
     2 transfused_tz = i4
     2 order_id = f8
     2 p_updt_cnt = i4
     2 pd_product_event_id = f8
     2 pd_updt_cnt = i4
     2 pe_pd_updt_cnt = i4
     2 dispense_to_locn_cd = f8
     2 events_to_release = i4
     2 eventlist[*]
       3 xm_product_event_id = f8
       3 pe_xm_updt_cnt = i4
       3 xm_updt_cnt = i4
       3 event_type = c2
     2 status = c1
     2 err_message = c25
     2 need_to_unlock_ind = i2
     2 flex_prod_ind = i2
 )
 RECORD reply(
   1 rpt_list[*]
     2 rpt_filename = vc
   1 ltransfused_product_cnt = i4
   1 results[*]
     2 batch_transfuse_ind = c1
     2 product_event_id = f8
     2 pd_product_event_id = f8
     2 product_type = c1
     2 product_id = f8
     2 person_id = f8
     2 encounter_id = f8
     2 event_prsnl_id = f8
     2 transfused_iu = i4
     2 transfused_qty = i4
     2 transfused_vol = i4
     2 transfused_dt_tm = dq8
     2 transfused_tz = i4
     2 order_id = f8
     2 status = c1
     2 pn_recovery_id = f8
     2 event_type_flag = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF (validate(i18nuar_def,999)=999)
  CALL echo("Declaring i18nuar_def")
  DECLARE i18nuar_def = i2 WITH persist
  SET i18nuar_def = 1
  DECLARE uar_i18nlocalizationinit(p1=i4,p2=vc,p3=vc,p4=f8) = i4 WITH persist
  DECLARE uar_i18ngetmessage(p1=i4,p2=vc,p3=vc) = vc WITH persist
  DECLARE uar_i18nbuildmessage() = vc WITH persist
  DECLARE uar_i18ngethijridate(imonth=i2(val),iday=i2(val),iyear=i2(val),sdateformattype=vc(ref)) =
  c50 WITH image_axp = "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar =
  "uar_i18nGetHijriDate",
  persist
  DECLARE uar_i18nbuildfullformatname(sfirst=vc(ref),slast=vc(ref),smiddle=vc(ref),sdegree=vc(ref),
   stitle=vc(ref),
   sprefix=vc(ref),ssuffix=vc(ref),sinitials=vc(ref),soriginal=vc(ref)) = c250 WITH image_axp =
  "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar = "i18nBuildFullFormatName",
  persist
  DECLARE uar_i18ngetarabictime(ctime=vc(ref)) = c20 WITH image_axp = "shri18nuar", image_aix =
  "libi18n_locale.a(libi18n_locale.o)", uar = "i18n_GetArabicTime",
  persist
 ENDIF
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 RECORD ops_captions(
   1 rpt_batch_transfusion = vc
   1 as_of_date = vc
   1 report_update = vc
   1 report_only = vc
   1 as_of_time = vc
   1 blood_bank_owner = vc
   1 inventory_area = vc
   1 grp = vc
   1 unit_number = vc
   1 current = vc
   1 patient_name = vc
   1 transfuse = vc
   1 type = vc
   1 medical_number = vc
   1 location = vc
   1 accession_number = vc
   1 product = vc
   1 status = vc
   1 date_time = vc
   1 report_id = vc
   1 rpt_page = vc
   1 printed = vc
   1 message = vc
   1 end_of_report = vc
   1 rpt_no_dispensed = vc
   1 serial_number = vc
 )
 SET ops_captions->rpt_batch_transfusion = uar_i18ngetmessage(i18nhandle,"rpt_batch_transfusion",
  "B A T C H    T R A N S F U S I O N    R E P O R T")
 SET ops_captions->as_of_date = uar_i18ngetmessage(i18nhandle,"as_of_date","As of Date:")
 SET ops_captions->report_update = uar_i18ngetmessage(i18nhandle,"report_update","(Report/Update)")
 SET ops_captions->report_only = uar_i18ngetmessage(i18nhandle,"report_only","Report Only")
 SET ops_captions->as_of_time = uar_i18ngetmessage(i18nhandle,"as_of_time","As of Time:")
 SET ops_captions->blood_bank_owner = uar_i18ngetmessage(i18nhandle,"blood_bank_owner",
  "Blood Bank Owner: ")
 SET ops_captions->inventory_area = uar_i18ngetmessage(i18nhandle,"inventory_area","Inventory Area: "
  )
 SET ops_captions->grp = uar_i18ngetmessage(i18nhandle,"grp","GRP/")
 SET ops_captions->unit_number = uar_i18ngetmessage(i18nhandle,"unit_number","UNIT NUMBER/")
 SET ops_captions->current = uar_i18ngetmessage(i18nhandle,"current","CURRENT")
 SET ops_captions->patient_name = uar_i18ngetmessage(i18nhandle,"patient_name","PATIENT NAME")
 SET ops_captions->transfuse = uar_i18ngetmessage(i18nhandle,"transfuse","TRANSFUSE*")
 SET ops_captions->type = uar_i18ngetmessage(i18nhandle,"type","TYPE")
 SET ops_captions->medical_number = uar_i18ngetmessage(i18nhandle,"medical_number","MEDICAL NUMBER")
 SET ops_captions->location = uar_i18ngetmessage(i18nhandle,"location","LOCATION")
 SET ops_captions->accession_number = uar_i18ngetmessage(i18nhandle,"accession_number",
  "ACCESSION NUMBER/")
 SET ops_captions->product = uar_i18ngetmessage(i18nhandle,"product","PRODUCT")
 SET ops_captions->status = uar_i18ngetmessage(i18nhandle,"status","STATUS")
 SET ops_captions->date_time = uar_i18ngetmessage(i18nhandle,"date_time","DATE TIME")
 SET ops_captions->report_id = uar_i18ngetmessage(i18nhandle,"report_id",
  "Report ID: BBT_OPS_BATCH_TRANSFUSION")
 SET ops_captions->rpt_page = uar_i18ngetmessage(i18nhandle,"rpt_page","Page:")
 SET ops_captions->printed = uar_i18ngetmessage(i18nhandle,"printed","Printed:")
 SET ops_captions->message = uar_i18ngetmessage(i18nhandle,"message",
  "*If Dispensed, the transfuse date and time will reflect the calculated transfused date and time as defined in the database."
  )
 SET ops_captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report",
  "* * * End of Report * * *")
 SET ops_captions->rpt_no_dispensed = uar_i18ngetmessage(i18nhandle,"rpt_no_dispensed",
  " * * * No dispensed units to transfuse at this time * * *")
 SET ops_captions->serial_number = uar_i18ngetmessage(i18nhandle,"serial_number","SERIAL NUMBER")
 SET log_override_ind = 0
 SELECT INTO "nl:"
  dm.info_char
  FROM dm_info dm
  WHERE dm.info_domain="PATHNET BLOOD BANK"
   AND dm.info_name="OVERRIDE BBT_OPS_BATCH_TRANSFUSION"
  DETAIL
   IF (dm.info_char="L")
    log_override_ind = 1
   ELSE
    log_override_ind = 0
   ENDIF
  WITH nocounter
 ;end select
 CALL log_message("---BBT_OPS_BATCH_TRANSFUSION STARTING",log_level_debug)
 CALL log_message(build("batch_selection:",request->batch_selection),log_level_debug)
 DECLARE product_event_id = f8 WITH public, noconstant(0.0)
 DECLARE dproducteventid = f8 WITH protect, noconstant(0.0)
 DECLARE flex_get_error_ind = i2 WITH protect, noconstant(0)
 DECLARE flex_upd_error_flag = i2 WITH protect, noconstant(0)
 DECLARE flex_upd_error = i2 WITH protect, constant(1)
 DECLARE insert_bb_tables_cnt = i4 WITH protect, noconstant(0)
 IF (trim(request->batch_selection) > " ")
  SET temp_string = cnvtupper(trim(request->batch_selection))
  SET mode_selection = fillstring(6," ")
  CALL check_mode_opt("bbt_ops_batch_transfusion")
  IF (mode_selection="UPDATE")
   SET batch_field = mode_selection
  ELSEIF (mode_selection="REPORT")
   SET batch_field = mode_selection
  ELSE
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "bbt_ops_batch_transfusion"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "no mode selection"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "no correct mode selection in string"
   GO TO exit_script
  ENDIF
  CALL check_location_cd("bbt_ops_batch_transfusion")
  CALL check_owner_cd("bbt_ops_batch_transfusion.prg")
  CALL check_inventory_cd("bbt_ops_batch_transfusion.prg")
 ELSE
  SET batch_field = "REPORT"
  SET request->address_location_cd = 0.0
 ENDIF
 SUBROUTINE check_opt_date_passed(script_name)
   SET ddmmyy_flag = 0
   SET dd_flag = 0
   SET mm_flag = 0
   SET yy_flag = 0
   SET dayentered = 0
   SET monthentered = 0
   SET yearentered = 0
   SET temp_pos = 0
   SET temp_pos = cnvtint(value(findstring("DAY[",temp_string)))
   IF (temp_pos > 0)
    SET day_string = substring((temp_pos+ 4),size(temp_string),temp_string)
    SET day_pos = cnvtint(value(findstring("]",day_string)))
    IF (day_pos > 0)
     SET day_nbr = substring(1,(day_pos - 1),day_string)
     IF (trim(day_nbr) > " ")
      SET ddmmyy_flag += 1
      SET dd_flag = 1
      SET dayentered = cnvtreal(day_nbr)
     ELSE
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].targetobjectname = "parse DAY value"
     ENDIF
    ELSE
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "parse DAY value"
    ENDIF
   ENDIF
   IF ((reply->status_data.status != "F"))
    SET temp_pos = 0
    SET temp_pos = cnvtint(value(findstring("MONTH[",temp_string)))
    IF (temp_pos > 0)
     SET month_string = substring((temp_pos+ 6),size(temp_string),temp_string)
     SET month_pos = cnvtint(value(findstring("]",month_string)))
     IF (month_pos > 0)
      SET month_nbr = substring(1,(month_pos - 1),month_string)
      IF (trim(month_nbr) > " ")
       SET ddmmyy_flag += 1
       SET mm_flag = 1
       SET monthentered = cnvtreal(month_nbr)
      ELSE
       SET reply->status_data.status = "F"
       SET reply->status_data.subeventstatus[1].targetobjectname = "parse MONTH value"
      ENDIF
     ELSE
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].targetobjectname = "parse MONTH value"
     ENDIF
    ENDIF
   ENDIF
   IF ((reply->status_data.status != "F"))
    SET temp_pos = 0
    SET temp_pos = cnvtint(value(findstring("YEAR[",temp_string)))
    IF (temp_pos > 0)
     SET year_string = substring((temp_pos+ 5),size(temp_string),temp_string)
     SET year_pos = cnvtint(value(findstring("]",year_string)))
     IF (year_pos > 0)
      SET year_nbr = substring(1,(year_pos - 1),year_string)
      IF (trim(year_nbr) > " ")
       SET ddmmyy_flag += 1
       SET yy_flag = 1
       SET yearentered = cnvtreal(year_nbr)
      ELSE
       SET reply->status_data.status = "F"
       SET reply->status_data.subeventstatus[1].targetobjectname = "parse YEAR value"
      ENDIF
     ELSE
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].targetobjectname = "parse YEAR value"
     ENDIF
    ENDIF
   ENDIF
   IF (ddmmyy_flag > 1)
    SET reply->status_data.subeventstatus[1].operationname = script_name
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "parse DAY or MONTH or YEAR value"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "multi date selection"
    GO TO exit_script
   ENDIF
   IF ((reply->status_data.status="F"))
    SET reply->status_data.subeventstatus[1].operationname = script_name
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
    GO TO exit_script
   ENDIF
   IF (dd_flag=1)
    IF (dayentered > 0)
     SET interval = build(abs(dayentered),"d")
     SET request->ops_date = cnvtdatetime(cnvtdate2(format(request->ops_date,"mm/dd/yyyy;;d"),
       "mm/dd/yyyy"),0000)
     SET begday = cnvtlookahead(interval,request->ops_date)
     SET request->ops_date = cnvtdatetime(cnvtdate2(format(request->ops_date,"mm/dd/yyyy;;d"),
       "mm/dd/yyyy"),235959)
     SET endday = cnvtlookahead(interval,request->ops_date)
    ELSE
     SET interval = build(abs(dayentered),"d")
     SET request->ops_date = cnvtdatetime(cnvtdate2(format(request->ops_date,"mm/dd/yyyy;;d"),
       "mm/dd/yyyy"),0000)
     SET begday = cnvtlookbehind(interval,request->ops_date)
     SET request->ops_date = cnvtdatetime(cnvtdate2(format(request->ops_date,"mm/dd/yyyy;;d"),
       "mm/dd/yyyy"),235959)
     SET endday = cnvtlookbehind(interval,request->ops_date)
    ENDIF
   ELSEIF (mm_flag=1)
    IF (monthentered > 0)
     SET interval = build(abs(monthentered),"m")
     SET request->ops_date = cnvtdatetime(cnvtdate2(format(request->ops_date,"mm/dd/yyyy;;d"),
       "mm/dd/yyyy"),0000)
     SET smonth = cnvtstring(month(request->ops_date))
     SET sday = "01"
     SET syear = cnvtstring(year(request->ops_date))
     SET sdateall = concat(smonth,sday,syear)
     SET begday = cnvtlookahead(interval,cnvtdatetime(cnvtdate(sdateall),0))
     SET endday = cnvtlookahead("1m",cnvtdatetime(cnvtdate(begday),235959))
     SET endday = cnvtlookbehind("1d",endday)
    ELSE
     SET interval = build(abs(monthentered),"m")
     SET request->ops_date = cnvtdatetime(cnvtdate2(format(request->ops_date,"mm/dd/yyyy;;d"),
       "mm/dd/yyyy"),0000)
     SET smonth = cnvtstring(month(request->ops_date))
     SET sday = "01"
     SET syear = cnvtstring(year(request->ops_date))
     SET sdateall = concat(smonth,sday,syear)
     SET begday = cnvtlookbehind(interval,cnvtdatetime(cnvtdate(sdateall),0))
     SET endday = cnvtlookahead("1m",cnvtdatetime(cnvtdate(begday),235959))
     SET endday = cnvtlookbehind("1d",endday)
    ENDIF
   ELSEIF (yy_flag=1)
    IF (yearentered > 0)
     SET interval = build(abs(yearentered),"y")
     SET request->ops_date = cnvtdatetime(cnvtdate2(format(request->ops_date,"mm/dd/yyyy;;d"),
       "mm/dd/yyyy"),0000)
     SET smonth = "01"
     SET sday = "01"
     SET syear = cnvtstring(year(request->ops_date))
     SET sdateall = concat(smonth,sday,syear)
     SET begday = cnvtlookahead(interval,cnvtdatetime(cnvtdate(sdateall),0))
     SET endday = cnvtlookahead("1y",cnvtdatetime(cnvtdate(begday),235959))
     SET endday = cnvtlookbehind("1d",endday)
    ELSE
     SET interval = build(abs(yearentered),"y")
     SET request->ops_date = cnvtdatetime(cnvtdate2(format(request->ops_date,"mm/dd/yyyy;;d"),
       "mm/dd/yyyy"),0000)
     SET smonth = "01"
     SET sday = "01"
     SET syear = cnvtstring(year(request->ops_date))
     SET sdateall = concat(smonth,sday,syear)
     SET begday = cnvtlookbehind(interval,cnvtdatetime(cnvtdate(sdateall),0))
     SET endday = cnvtlookahead("1y",cnvtdatetime(cnvtdate(begday),235959))
     SET endday = cnvtlookbehind("1d",endday)
    ENDIF
   ELSE
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = script_name
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "parse DAY or MONTH or YEAR value"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "NO date selection"
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE check_bb_organization(script_name)
   DECLARE norgpos = i2 WITH protect, noconstant(0)
   DECLARE ntemppos = i2 WITH protect, noconstant(0)
   DECLARE ncodeset = i4 WITH protect, constant(278)
   DECLARE sorgname = vc WITH protect, noconstant(fillstring(132,""))
   DECLARE sorgstring = vc WITH protect, noconstant(fillstring(132,""))
   DECLARE dbbmanufcd = f8 WITH protect, noconstant(0.0)
   DECLARE dbbsupplcd = f8 WITH protect, noconstant(0.0)
   DECLARE dbbclientcd = f8 WITH protect, noconstant(0.0)
   SET stat = uar_get_meaning_by_codeset(ncodeset,"BBMANUF",1,dbbmanufcd)
   SET stat = uar_get_meaning_by_codeset(ncodeset,"BBSUPPL",1,dbbsupplcd)
   SET stat = uar_get_meaning_by_codeset(ncodeset,"BBCLIENT",1,dbbclientcd)
   SET ntemppos = cnvtint(value(findstring("ORG[",temp_string)))
   IF (ntemppos > 0)
    SET sorgstring = substring((ntemppos+ 4),size(temp_string),temp_string)
    SET norgpos = cnvtint(value(findstring("]",sorgstring)))
    IF (norgpos > 0)
     SET sorgname = substring(1,(norgpos - 1),sorgstring)
     IF (trim(sorgname) > " ")
      SELECT INTO "nl:"
       FROM org_type_reltn ot,
        organization o
       PLAN (ot
        WHERE ot.org_type_cd IN (dbbmanufcd, dbbsupplcd, dbbclientcd)
         AND ot.active_ind=1)
        JOIN (o
        WHERE o.org_name_key=trim(cnvtupper(sorgname))
         AND o.active_ind=1)
       DETAIL
        request->organization_id = o.organization_id
       WITH nocounter
      ;end select
     ENDIF
    ENDIF
   ELSE
    SET request->organization_id = 0.0
   ENDIF
 END ;Subroutine
 SUBROUTINE check_owner_cd(script_name)
   SET temp_pos = 0
   SET temp_pos = cnvtint(value(findstring("OWN[",temp_string)))
   IF (temp_pos > 0)
    SET own_string = substring((temp_pos+ 4),size(temp_string),temp_string)
    SET own_pos = cnvtint(value(findstring("]",own_string)))
    IF (own_pos > 0)
     SET own_area = substring(1,(own_pos - 1),own_string)
     IF (trim(own_area) > " ")
      SET request->cur_owner_area_cd = cnvtreal(own_area)
     ELSE
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationname = script_name
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
      SET reply->status_data.subeventstatus[1].targetobjectname = "parse owner area code value"
      GO TO exit_script
     ENDIF
    ELSE
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = script_name
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
     SET reply->status_data.subeventstatus[1].targetobjectname = "parse owner area code value"
     GO TO exit_script
    ENDIF
   ELSE
    SET request->cur_owner_area_cd = 0.0
   ENDIF
 END ;Subroutine
 SUBROUTINE check_inventory_cd(script_name)
   SET temp_pos = 0
   SET temp_pos = cnvtint(value(findstring("INV[",temp_string)))
   IF (temp_pos > 0)
    SET inv_string = substring((temp_pos+ 4),size(temp_string),temp_string)
    SET inv_pos = cnvtint(value(findstring("]",inv_string)))
    IF (inv_pos > 0)
     SET inv_area = substring(1,(inv_pos - 1),inv_string)
     IF (trim(inv_area) > " ")
      SET request->cur_inv_area_cd = cnvtreal(inv_area)
     ELSE
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationname = script_name
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
      SET reply->status_data.subeventstatus[1].targetobjectname = "parse inventory area code value"
      GO TO exit_script
     ENDIF
    ELSE
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = script_name
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
     SET reply->status_data.subeventstatus[1].targetobjectname = "parse inventory area code value"
     GO TO exit_script
    ENDIF
   ELSE
    SET request->cur_inv_area_cd = 0.0
   ENDIF
 END ;Subroutine
 SUBROUTINE check_location_cd(script_name)
   SET temp_pos = 0
   SET temp_pos = cnvtint(value(findstring("LOC[",temp_string)))
   IF (temp_pos > 0)
    SET loc_string = substring((temp_pos+ 4),size(temp_string),temp_string)
    SET loc_pos = cnvtint(value(findstring("]",loc_string)))
    IF (loc_pos > 0)
     SET location_cd = substring(1,(loc_pos - 1),loc_string)
     IF (trim(location_cd) > " ")
      SET request->address_location_cd = cnvtreal(location_cd)
     ELSE
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationname = script_name
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
      SET reply->status_data.subeventstatus[1].targetobjectname = "parse location code value"
      GO TO exit_script
     ENDIF
    ELSE
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = script_name
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
     SET reply->status_data.subeventstatus[1].targetobjectname = "parse location code value"
     GO TO exit_script
    ENDIF
   ELSE
    SET request->address_location_cd = 0.0
   ENDIF
 END ;Subroutine
 SUBROUTINE check_sort_opt(script_name)
   SET temp_pos = 0
   SET temp_pos = cnvtint(value(findstring("SORT[",temp_string)))
   IF (temp_pos > 0)
    SET sort_string = substring((temp_pos+ 5),size(temp_string),temp_string)
    SET sort_pos = cnvtint(value(findstring("]",sort_string)))
    IF (sort_pos > 0)
     SET sort_selection = substring(1,(sort_pos - 1),sort_string)
    ELSE
     SET sort_selection = " "
    ENDIF
   ELSE
    SET sort_selection = " "
   ENDIF
 END ;Subroutine
 SUBROUTINE check_mode_opt(script_name)
   SET temp_pos = 0
   SET temp_pos = cnvtint(value(findstring("MODE[",temp_string)))
   IF (temp_pos > 0)
    SET mode_string = substring((temp_pos+ 5),size(temp_string),temp_string)
    SET mode_pos = cnvtint(value(findstring("]",mode_string)))
    IF (mode_pos > 0)
     SET mode_selection = substring(1,(mode_pos - 1),mode_string)
    ELSE
     SET mode_selection = " "
    ENDIF
   ELSE
    SET mode_selection = " "
   ENDIF
 END ;Subroutine
 SUBROUTINE check_rangeofdays_opt(script_name)
   SET temp_pos = 0
   SET temp_pos = cnvtint(value(findstring("RANGEOFDAYS[",temp_string)))
   IF (temp_pos > 0)
    SET next_string = substring((temp_pos+ 12),size(temp_string),temp_string)
    SET next_pos = cnvtint(value(findstring("]",next_string)))
    SET days_look_ahead = cnvtint(trim(substring(1,(next_pos - 1),next_string)))
    IF (days_look_ahead > 0)
     SET days_look_ahead = days_look_ahead
    ELSE
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = script_name
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "no value in string"
     SET reply->status_data.subeventstatus[1].targetobjectname = "parse look ahead days"
     GO TO exit_script
    ENDIF
   ELSE
    SET days_look_ahead = 0
   ENDIF
 END ;Subroutine
 SUBROUTINE check_hrs_opt(script_name)
   SET temp_pos = 0
   SET temp_pos = cnvtint(value(findstring("HRS[",temp_string)))
   IF (temp_pos > 0)
    SET hrs_string = substring((temp_pos+ 4),size(temp_string),temp_string)
    SET hrs_pos = cnvtint(value(findstring("]",hrs_string)))
    IF (hrs_pos > 0)
     SET num_hrs = substring(1,(hrs_pos - 1),hrs_string)
     IF (trim(num_hrs) > " ")
      IF (cnvtint(trim(num_hrs)) > 0)
       SET hoursentered = cnvtreal(num_hrs)
      ELSE
       SET reply->status_data.status = "F"
       SET reply->status_data.subeventstatus[1].operationname = script_name
       SET reply->status_data.subeventstatus[1].operationstatus = "F"
       SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
       SET reply->status_data.subeventstatus[1].targetobjectname = "parse number of hours"
       GO TO exit_script
      ENDIF
     ELSE
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationname = script_name
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
      SET reply->status_data.subeventstatus[1].targetobjectname = "parse number of hours"
      GO TO exit_script
     ENDIF
    ELSE
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = script_name
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
     SET reply->status_data.subeventstatus[1].targetobjectname = "parse number of hours"
     GO TO exit_script
    ENDIF
   ELSE
    SET hoursentered = 0
   ENDIF
 END ;Subroutine
 SUBROUTINE check_svc_opt(script_name)
   SET temp_pos = 0
   SET temp_pos = cnvtint(value(findstring("SVC[",temp_string)))
   IF (temp_pos > 0)
    SET svc_string = substring((temp_pos+ 4),size(temp_string),temp_string)
    SET svc_pos = cnvtint(value(findstring("]",svc_string)))
    SET parm_string = fillstring(100," ")
    SET parm_string = substring(1,(svc_pos - 1),svc_string)
    SET ptr = 1
    SET back_ptr = 1
    SET param_idx = 1
    SET nbr_of_services = size(trim(parm_string))
    SET flag_exit_loop = 0
    FOR (param_idx = 1 TO nbr_of_services)
      SET ptr = findstring(",",parm_string,back_ptr)
      IF (ptr=0)
       SET ptr = (nbr_of_services+ 1)
       SET flag_exit_loop = 1
      ENDIF
      SET parm_len = (ptr - back_ptr)
      SET stat = alterlist(ops_params->qual,param_idx)
      SET ops_params->qual[param_idx].param = trim(substring(back_ptr,value(parm_len),parm_string),3)
      SET back_ptr = (ptr+ 1)
      SET stat = alterlist(request->qual,param_idx)
      SET request->qual[param_idx].service_resource_cd = cnvtreal(ops_params->qual[param_idx].param)
      IF (flag_exit_loop=1)
       SET param_idx = nbr_of_services
      ENDIF
    ENDFOR
   ELSE
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = script_name
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
    SET reply->status_data.subeventstatus[1].targetobjectname = "parse service resource"
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE check_donation_location(script_name)
   SET temp_pos = 0
   SET temp_pos = cnvtint(value(findstring("DLOC[",temp_string)))
   IF (temp_pos > 0)
    SET loc_string = substring((temp_pos+ 5),size(temp_string),temp_string)
    SET loc_pos = cnvtint(value(findstring("]",loc_string)))
    IF (loc_pos > 0)
     SET location_cd = substring(1,(loc_pos - 1),loc_string)
     IF (trim(location_cd) > " ")
      SET request->donation_location_cd = cnvtreal(trim(location_cd))
     ELSE
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationname = script_name
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
      SET reply->status_data.subeventstatus[1].targetobjectname = "parse donation location"
      GO TO exit_script
     ENDIF
    ELSE
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = script_name
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
     SET reply->status_data.subeventstatus[1].targetobjectname = "parse donation location"
     GO TO exit_script
    ENDIF
   ELSE
    SET request->donation_location_cd = 0.0
   ENDIF
 END ;Subroutine
 SUBROUTINE check_null_report(script_name)
   SET temp_pos = 0
   SET temp_pos = cnvtint(value(findstring("NULLRPT[",temp_string)))
   IF (temp_pos > 0)
    SET null_string = substring((temp_pos+ 8),size(temp_string),temp_string)
    SET null_pos = cnvtint(value(findstring("]",null_string)))
    IF (null_pos > 0)
     SET null_selection = substring(1,(null_pos - 1),null_string)
     IF (trim(null_selection)="Y")
      SET request->null_ind = 1
     ELSE
      SET request->null_ind = 0
     ENDIF
    ELSE
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = script_name
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "no value in string"
     SET reply->status_data.subeventstatus[1].targetobjectname = "parse null report indicator"
     GO TO exit_script
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE check_outcome_cd(script_name)
   SET temp_pos = 0
   SET temp_pos = cnvtint(value(findstring("OUTCOME[",temp_string)))
   IF (temp_pos > 0)
    SET outcome_string = substring((temp_pos+ 8),size(temp_string),temp_string)
    SET loc_pos = cnvtint(value(findstring("]",outcome_string)))
    IF (loc_pos > 0)
     SET outcome_cd = substring(1,(loc_pos - 1),outcome_string)
     IF (trim(outcome_cd) > " ")
      SET request->outcome_cd = cnvtreal(outcome_cd)
     ELSE
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationname = script_name
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
      SET reply->status_data.subeventstatus[1].targetobjectname = "parse outcome code value"
      GO TO exit_script
     ENDIF
    ELSE
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = script_name
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
     SET reply->status_data.subeventstatus[1].targetobjectname = "parse outcome code value"
     GO TO exit_script
    ENDIF
   ELSE
    SET request->outcome_cd = 0.0
   ENDIF
 END ;Subroutine
 SUBROUTINE (check_facility_cd(script_name=vc) =null)
   SET temp_pos = 0
   SET temp_pos = cnvtint(value(findstring("FACILITY[",temp_string)))
   IF (temp_pos > 0)
    SET loc_string = substring((temp_pos+ 9),size(temp_string),temp_string)
    SET loc_pos = cnvtint(value(findstring("]",loc_string)))
    IF (loc_pos > 0)
     SET facility_cd = substring(1,(loc_pos - 1),loc_string)
     IF (trim(facility_cd) > " ")
      SET request->facility_cd = cnvtreal(facility_cd)
     ELSE
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationname = script_name
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = "no facility code value in string"
      SET reply->status_data.subeventstatus[1].targetobjectname = "parse facility code value"
      GO TO exit_script
     ENDIF
    ELSE
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = script_name
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "no facility code value in string"
     SET reply->status_data.subeventstatus[1].targetobjectname = "parse facility code value"
     GO TO exit_script
    ENDIF
   ELSE
    SET request->facility_cd = 0.0
   ENDIF
 END ;Subroutine
 SUBROUTINE (check_exception_type_cd(script_name=vc) =null)
   SET temp_pos = 0
   SET temp_pos = cnvtint(value(findstring("EXCEPT[",temp_string)))
   IF (temp_pos > 0)
    SET loc_string = substring((temp_pos+ 7),size(temp_string),temp_string)
    SET loc_pos = cnvtint(value(findstring("]",loc_string)))
    IF (loc_pos > 0)
     SET exception_type_cd = substring(1,(loc_pos - 1),loc_string)
     IF (trim(exception_type_cd) > " ")
      IF (trim(exception_type_cd)="ALL")
       SET request->exception_type_cd = 0.0
      ELSE
       SET request->exception_type_cd = cnvtreal(exception_type_cd)
      ENDIF
     ELSE
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationname = script_name
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectvalue =
      "no exception type code value in string"
      SET reply->status_data.subeventstatus[1].targetobjectname = "parse exception type code value"
      GO TO exit_script
     ENDIF
    ELSE
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = script_name
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "no exception type code value in string"
     SET reply->status_data.subeventstatus[1].targetobjectname = "parse exception type code value"
     GO TO exit_script
    ENDIF
   ELSE
    SET request->exception_type_cd = 0.0
   ENDIF
 END ;Subroutine
 SUBROUTINE check_misc_functionality(param_name)
   SET temp_pos = 0
   SET status_param = ""
   SET temp_str = concat(param_name,"[")
   SET temp_pos = cnvtint(value(findstring(temp_str,temp_string)))
   IF (temp_pos > 0)
    SET status_string = substring((temp_pos+ textlen(temp_str)),size(temp_string),temp_string)
    SET status_pos = cnvtint(value(findstring("]",status_string)))
    IF (status_pos > 0)
     SET status_param = substring(1,(status_pos - 1),status_string)
     IF (trim(status_param) > " ")
      SET ops_param_status = cnvtint(status_param)
     ENDIF
    ENDIF
   ENDIF
   RETURN
 END ;Subroutine
 DECLARE get_code_value(sub_code_set,sub_cdf_meaning) = f8
 SUBROUTINE get_code_value(sub_code_set,sub_cdf_meaning)
   SET gsub_code_value = 0.0
   SET cdf_meaning = fillstring(12," ")
   SET cdf_meaning = sub_cdf_meaning
   SET stat = uar_get_meaning_by_codeset(sub_code_set,cdf_meaning,1,gsub_code_value)
   RETURN(gsub_code_value)
 END ;Subroutine
 SET stat = alterlist(reply->results,1)
 SET reply->status_data.status = "S"
 SET reply->results[1].batch_transfuse_ind = "Y"
 SET calc_trnfs_dt_tm = cnvtdatetime(sysdate)
 SET calc_disp_dt_tm = cnvtdatetime(sysdate)
 SET ops_nbr_to_update = 0
 SET count1 = 0
 SET count2 = 0
 SET error_process = "                                       "
 SET error_message = "                                       "
 SET ops_bat_success_cnt = 0
 SET product_event_id = 0.0
 SET failure_occured = "F"
 SET pd_qty = 0
 SET as_qty = 0
 SET thistable = "    "
 SET this_prod_id = 0.0
 SET other_events = "F"
 SET pref_doc_vol_trnf = " "
 SET pref_dflt_disp_vl = " "
 SET pref_trnf_vol_req = " "
 SET pref_doc_tag_rtrn = " "
 SET pref_dflt_tag_rtrn = " "
 SET pref_doc_bag_rtrn = " "
 SET pref_dflt_bag_rtrn = " "
 SET pref_trans_hrs = 0
 SET pref_transf_time = 0
 DECLARE pref_allow_cool_ind = i2
 DECLARE pref_allow_ref_ind = i2
 SET pref_allow_cool_ind = 0
 SET pref_allow_ref_ind = 0
 SET ans_always_val = 0
 SET ans_sometimes_val = 0
 SET ans_days_val = 0
 SET ans_never_val = 0
 SET ans_yes_val = 0
 SET ans_no_val = 0
 SET ans_hours_val = 0
 SET quest_doc_vol_transf = 0
 SET quest_dflt_disp_vl = 0
 SET quest_doc_tag_rtrn = 0
 SET quest_dflt_tag_rtrn = 0
 SET quest_doc_bag_rtrn = 0
 SET quest_dflt_bag_rtrn = 0
 SET quest_trnf_vol_req = 0
 SET quest_transf_hrs = 0
 SET quest_transf_time = 0
 SET mrn_code_val = 0.0
 SET reply->ltransfused_product_cnt = 0
 DECLARE quest_allow_cool_cd = f8
 DECLARE quest_allow_ref_cd = f8
 SET quest_allow_cool_cd = 0.0
 SET quest_allow_ref_cd = 0.0
 SET mrn_code_val = get_code_value(319,"MRN")
 IF (mrn_code_val=0)
  SET failure_occured = "T"
  SET reply->status_data.status = "F"
  SET error_process = "get codevalues"
  SET error_message = "fail on MRN codevalue"
 ENDIF
 SET ans_always_val = get_code_value(1659,"A")
 SET ans_sometimes_val = get_code_value(1659,"S")
 SET ans_days_val = get_code_value(1659,"D")
 SET ans_never_val = get_code_value(1659,"NEVER")
 SET ans_yes_val = get_code_value(1659,"Y")
 SET ans_no_val = get_code_value(1659,"N")
 SET ans_hours_val = get_code_value(1659,"H")
 IF (0.0 IN (ans_always_val, ans_sometimes_val, ans_days_val, ans_never_val, ans_yes_val,
 ans_no_val, ans_hours_val))
  SET failure_occured = "T"
  SET reply->status_data.status = "F"
  SET error_process = "get codevalues"
  SET error_message = "fail on get answers codevalues"
 ENDIF
 SET quest_doc_vol_transf = get_code_value(1661,"DOC VOL TRNF")
 SET quest_dflt_disp_vl = get_code_value(1661,"DFLT DISP VL")
 SET quest_doc_tag_rtrn = get_code_value(1661,"DOC TAG RTRN")
 SET quest_dflt_tag_rtrn = get_code_value(1661,"DFLT TAG RET")
 SET quest_doc_bag_rtrn = get_code_value(1661,"DOC BAG RTRN")
 SET quest_dflt_bag_rtrn = get_code_value(1661,"DFLT BAG RET")
 SET quest_trnf_vol_req = get_code_value(1661,"TRNF VOL REQ")
 SET quest_transf_hrs = get_code_value(1661,"TRANSF HRS")
 SET quest_transf_time = get_code_value(1661,"TRANSF TIME")
 SET quest_allow_cool_cd = get_code_value(1661,"TRANSF INC C")
 SET quest_allow_ref_cd = get_code_value(1661,"TRANSF INC R")
 IF (0.0 IN (quest_doc_vol_transf, quest_dflt_disp_vl, quest_doc_tag_rtrn, quest_dflt_tag_rtrn,
 quest_doc_bag_rtrn,
 quest_dflt_bag_rtrn, quest_trnf_vol_req, quest_transf_hrs, quest_transf_time, quest_allow_cool_cd,
 quest_allow_ref_cd))
  SET failure_occured = "T"
  SET reply->status_data.status = "F"
  SET error_process = "get codevalues"
  SET error_message = "fail on get question codevalues"
 ENDIF
 SET assign_event_type_cd = 0.0
 SET xmatch_event_type_cd = 0.0
 SET dispensed_event_type_cd = 0.0
 SET dispensed_event_disp = fillstring(40," ")
 SET transfused_event_type_cd = 0.0
 SET transfused_event_disp = fillstring(40," ")
 SET reply->status_data.status = "S"
 SET assign_event_type_cd = get_code_value(1610,"1")
 SET xmatch_event_type_cd = get_code_value(1610,"3")
 SET dispensed_event_type_cd = get_code_value(1610,"4")
 SET transfused_event_type_cd = get_code_value(1610,"7")
 SET dispensed_event_disp = uar_get_code_display(dispensed_event_type_cd)
 SET transfused_event_disp = uar_get_code_display(transfused_event_type_cd)
 IF (0.0 IN (assign_event_type_cd, xmatch_event_type_cd, dispensed_event_type_cd,
 transfused_event_type_cd))
  SET failure_occured = "T"
  SET reply->status_data.status = "F"
  SET error_process = "get codevalues"
  SET error_message = "fail on get product event codevalues"
 ENDIF
 SELECT INTO "nl:"
  a.question_cd, a.answer
  FROM answer a
  WHERE a.question_cd IN (quest_doc_vol_transf, quest_dflt_disp_vl, quest_doc_tag_rtrn,
  quest_dflt_tag_rtrn, quest_doc_bag_rtrn,
  quest_dflt_bag_rtrn, quest_trnf_vol_req, quest_transf_hrs, quest_transf_time, quest_allow_cool_cd,
  quest_allow_ref_cd)
   AND a.active_ind=1
  DETAIL
   IF (a.question_cd=quest_doc_vol_transf)
    IF (cnvtint(a.answer)=ans_yes_val)
     pref_doc_vol_trnf = "Y"
    ELSE
     pref_doc_vol_trnf = "N"
    ENDIF
   ELSEIF (a.question_cd=quest_dflt_disp_vl)
    IF (cnvtint(a.answer)=ans_yes_val)
     pref_dflt_disp_vl = "Y"
    ELSE
     pref_dflt_disp_vl = "N"
    ENDIF
   ELSEIF (a.question_cd=quest_trnf_vol_req)
    IF (cnvtint(a.answer)=ans_yes_val)
     pref_trnf_vol_req = "Y"
    ELSE
     pref_trnf_vol_req = "N"
    ENDIF
   ELSEIF (a.question_cd=quest_dflt_tag_rtrn)
    IF (cnvtint(a.answer)=ans_yes_val)
     pref_dflt_tag_rtrn = "Y"
    ELSE
     pref_dflt_tag_rtrn = "N"
    ENDIF
   ELSEIF (a.question_cd=quest_doc_tag_rtrn)
    IF (cnvtint(a.answer)=ans_yes_val)
     pref_doc_tag_rtrn = "Y"
    ELSE
     pref_doc_tag_rtrn = "N"
    ENDIF
   ELSEIF (a.question_cd=quest_dflt_bag_rtrn)
    IF (cnvtint(a.answer)=ans_yes_val)
     pref_dflt_bag_rtrn = "Y"
    ELSE
     pref_dflt_bag_rtrn = "N"
    ENDIF
   ELSEIF (a.question_cd=quest_doc_bag_rtrn)
    IF (cnvtint(a.answer)=ans_yes_val)
     pref_doc_bag_rtrn = "Y"
    ELSE
     pref_doc_bag_rtrn = "N"
    ENDIF
   ELSEIF (a.question_cd=quest_transf_hrs)
    pref_trans_hrs = cnvtint(a.answer)
   ELSEIF (a.question_cd=quest_transf_time)
    pref_transf_time = cnvtint(a.answer)
   ELSEIF (a.question_cd=quest_allow_cool_cd)
    IF (cnvtint(a.answer)=ans_yes_val)
     pref_allow_cool_ind = 1
    ENDIF
   ELSEIF (a.question_cd=quest_allow_ref_cd)
    IF (cnvtint(a.answer)=ans_yes_val)
     pref_allow_ref_ind = 1
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET failure_occured = "T"
  SET reply->status_data.status = "F"
  SET error_process = "get codevalues"
  SET error_message = "fail on getting preference answeres"
 ENDIF
 SELECT INTO "nl:"
  pe.product_id, pe.product_event_id, pe.event_type_cd,
  pe.person_id, p.product_id, p.locked_ind,
  b.product_id, d.product_id, pd.product_event_id,
  pd.product_id, prod_table = decode(b.seq,"b",d.seq,"d","x")
  FROM product p,
   blood_product b,
   derivative d,
   product_event pe,
   patient_dispense pd,
   product_category pc,
   product_index pi,
   (dummyt d2  WITH seq = 1)
  PLAN (pd
   WHERE pd.active_ind=1
    AND pd.person_id > 0.0)
   JOIN (pe
   WHERE pe.active_ind=1
    AND pd.product_event_id=pe.product_event_id
    AND pe.person_id=pd.person_id)
   JOIN (p
   WHERE pe.product_id=p.product_id
    AND p.active_ind=1
    AND (((request->cur_owner_area_cd > 0.0)
    AND (request->cur_owner_area_cd=p.cur_owner_area_cd)) OR ((request->cur_owner_area_cd=0.0)))
    AND (((request->cur_inv_area_cd > 0.0)
    AND (request->cur_inv_area_cd=p.cur_inv_area_cd)) OR ((request->cur_inv_area_cd=0.0))) )
   JOIN (pi
   WHERE pi.product_cd=p.product_cd)
   JOIN (pc
   WHERE pc.product_cat_cd=pi.product_cat_cd)
   JOIN (d2
   WHERE d2.seq=1)
   JOIN (((b
   WHERE b.product_id=p.product_id)
   ) ORJOIN ((d
   WHERE d.product_id=p.product_id)
   ))
  ORDER BY pd.product_event_id, pe.person_id, p.product_id
  HEAD REPORT
   count1 = 0, allow_product_ind = 0
  HEAD pd.product_event_id
   allow_product_ind = 0
   IF (((pd.device_id=0.0) OR (pd.device_id=null))
    AND ((pd.dispense_cooler_id=0.0) OR (pd.dispense_cooler_id=null))
    AND ((trim(pd.dispense_cooler_text,3) <= " ") OR (pd.dispense_cooler_text=null)) )
    allow_product_ind = 1
   ELSEIF (pd.device_id > 0.0)
    IF (pref_allow_ref_ind=1)
     allow_product_ind = 1
    ENDIF
   ELSEIF (((pd.dispense_cooler_id > 0) OR (trim(pd.dispense_cooler_text,3) > "")) )
    IF (pref_allow_cool_ind=1)
     allow_product_ind = 1
    ENDIF
   ENDIF
   IF (allow_product_ind=1)
    count1 += 1, stat = alterlist(ops_request->productlist,count1)
   ENDIF
  DETAIL
   IF (allow_product_ind=1)
    calc_disp_dt_tm = datetimeadd(pe.event_dt_tm,(pref_trans_hrs/ 24.0))
    IF (cnvtdatetime(calc_disp_dt_tm) <= cnvtdatetime(request->ops_date))
     calc_trnfs_dt_tm = datetimeadd(pe.event_dt_tm,((pref_transf_time/ 24.0)/ 60.0)), ops_request->
     productlist[count1].product_type =
     IF (prod_table="d") "D"
     ELSE "B"
     ENDIF
     , ops_request->productlist[count1].product_nbr = build(b.supplier_prefix,p.product_nbr," ",p
      .product_sub_nbr),
     ops_request->productlist[count1].product_id = p.product_id, ops_request->productlist[count1].
     person_id = pd.person_id, ops_request->productlist[count1].encounter_id = pe.encntr_id,
     ops_request->productlist[count1].event_prsnl_id = reqinfo->updt_id, ops_request->productlist[
     count1].transfused_vol =
     IF (prod_table="d")
      IF (d.item_volume=0) pd.cur_dispense_intl_units
      ELSE (d.item_volume * pd.cur_dispense_qty)
      ENDIF
     ELSE b.cur_volume
     ENDIF
     , ops_request->productlist[count1].transfused_iu =
     IF (prod_table="d") pd.cur_dispense_intl_units
     ELSE 0
     ENDIF
     ,
     ops_request->productlist[count1].transfused_qty =
     IF (prod_table="d") pd.cur_dispense_qty
     ELSE 0
     ENDIF
     , ops_request->productlist[count1].transfused_dt_tm = cnvtdatetime(calc_trnfs_dt_tm),
     ops_request->productlist[count1].transfused_tz =
     IF (curutc=1) pe.event_tz
     ELSE 0
     ENDIF
     ,
     ops_request->productlist[count1].order_id = 0, ops_request->productlist[count1].p_updt_cnt = p
     .updt_cnt, ops_request->productlist[count1].pd_product_event_id = pd.product_event_id,
     ops_request->productlist[count1].pd_updt_cnt = pd.updt_cnt, ops_request->productlist[count1].
     pe_pd_updt_cnt = pe.updt_cnt, ops_request->productlist[count1].bag_returned_ind =
     IF (pref_dflt_bag_rtrn="Y") 1
     ELSE 0
     ENDIF
     ,
     ops_request->productlist[count1].tag_returned_ind =
     IF (pref_dflt_tag_rtrn="Y") 1
     ELSE 0
     ENDIF
     , ops_request->productlist[count1].dispense_to_locn_cd = pd.dispense_to_locn_cd, ops_request->
     productlist[count1].events_to_release = 0,
     row + 1, ops_request->productlist[count1].flex_prod_ind =
     IF (prod_table != "d"
      AND pi.autologous_ind=0
      AND pc.xmatch_required_ind=1) 1
     ELSE 0
     ENDIF
     , ops_request->productlist[count1].status = "S",
     ops_request->productlist[count1].err_message = ""
    ELSE
     count1 -= 1
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(ops_request->productlist,count1)
 IF (count1=0)
  SET reply->status_data.status = "Z"
  GO TO generate_report
 ENDIF
 FOR (prod = 1 TO count1)
   IF ((ops_request->productlist[prod].product_type="B"))
    SELECT INTO "nl:"
     pe.product_event_id, pe.product_id, ag.product_event_id,
     xm.product_event_id, xm_assg = decode(xm.seq,"xm",ag.seq,"ag","xx")
     FROM product_event pe,
      crossmatch xm,
      assign ag,
      (dummyt dt  WITH seq = 1)
     PLAN (pe
      WHERE (pe.product_id=ops_request->productlist[prod].product_id)
       AND pe.active_ind=1
       AND ((pe.event_type_cd=assign_event_type_cd) OR (pe.event_type_cd=xmatch_event_type_cd)) )
      JOIN (dt
      WHERE dt.seq=1)
      JOIN (((xm
      WHERE xm.product_event_id=pe.product_event_id
       AND xm.active_ind=1)
      ) ORJOIN ((ag
      WHERE ag.product_event_id=pe.product_event_id
       AND ag.active_ind=1)
      ))
     ORDER BY pe.product_id, pe.product_event_id
     HEAD pe.product_id
      count2 = 0
     HEAD pe.product_event_id
      count2 += 1, ops_request->productlist[prod].events_to_release = count2, stat = alterlist(
       ops_request->productlist[prod].eventlist,count2)
     DETAIL
      ops_request->productlist[prod].eventlist[count2].xm_product_event_id = pe.product_event_id,
      ops_request->productlist[prod].eventlist[count2].pe_xm_updt_cnt = pe.updt_cnt, ops_request->
      productlist[prod].eventlist[count2].xm_updt_cnt =
      IF (xm_assg="xm") xm.updt_cnt
      ELSEIF (xm_assg="ag") ag.updt_cnt
      ELSE 0
      ENDIF
      ,
      ops_request->productlist[prod].eventlist[count2].event_type =
      IF (xm_assg="xm") "XM"
      ELSEIF (xm_assg="ag") "AG"
      ELSE "  "
      ENDIF
      , ops_request->productlist[prod].order_id =
      IF (xm_assg="xm") pe.order_id
      ENDIF
     WITH nocounter, outerjoin(dt)
    ;end select
   ENDIF
 ENDFOR
 IF (cnvtupper(batch_field)="UPDATE")
  SET ops_nbr_to_update = cnvtint(size(ops_request->productlist,5))
  SET stat = alterlist(reply->results,ops_nbr_to_update)
  IF (ops_nbr_to_update > 0)
   SET reply->results[1].batch_transfuse_ind = "Y"
  ENDIF
  CALL flexget_init(null)
  SET stat = alter(reply->status_data.subeventstatus,ops_nbr_to_update)
  FOR (prod = 1 TO ops_nbr_to_update)
   UPDATE  FROM product p
    SET p.locked_ind = 1, p.updt_cnt = (p.updt_cnt+ 1), p.updt_dt_tm = cnvtdatetime(sysdate),
     p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->
     updt_applctx
    PLAN (p
     WHERE (p.product_id=ops_request->productlist[prod].product_id)
      AND (p.updt_cnt=ops_request->productlist[prod].p_updt_cnt)
      AND ((p.locked_ind = null) OR (p.locked_ind=0)) )
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET ops_request->productlist[prod].status = "F"
    SET error_process = "bbt_ops_batch_transfusion"
    SET error_message = "Unable to lock product"
    IF ((ops_request->productlist[prod].product_type="D"))
     FOR (count1 = 1 TO prod)
       IF ((ops_request->productlist[count1].product_id=ops_request->productlist[prod].product_id))
        SELECT INTO "nl:"
         p.product_id
         FROM product p
         WHERE (p.product_id=ops_request->productlist[count1].product_id)
          AND p.locked_ind=1
         DETAIL
          IF ((p.updt_id=reqinfo->updt_id)
           AND (p.updt_task=reqinfo->updt_task)
           AND (p.updt_applctx=reqinfo->updt_applctx))
           ops_request->productlist[prod].p_updt_cnt = p.updt_cnt, ops_request->productlist[prod].
           status = "S", error_process = "bbt_ops_batch_transfusion",
           error_message = "Unable to lock product"
          ENDIF
         WITH nocounter
        ;end select
       ENDIF
     ENDFOR
    ELSE
     SET ops_request->productlist[prod].status = "F"
     SET ops_request->productlist[prod].err_message = "Unable to lock product"
     SET error_process = "bbt_ops_batch_transfusion"
     SET error_message = "Unable to lock product"
    ENDIF
   ELSE
    SET ops_request->productlist[prod].p_updt_cnt += 1
    SET ops_request->productlist[prod].need_to_unlock_ind = 1
    COMMIT
    IF ((ops_request->productlist[prod].flex_prod_ind=1))
     CALL flexget_addperson(ops_request->productlist[prod].person_id)
    ENDIF
   ENDIF
  ENDFOR
  IF (flexget_run(null)=1)
   IF (lockflexproducts(1)=1)
    COMMIT
    SET flex_get_error_ind = 0
   ELSE
    SET flex_get_error_ind = 1
   ENDIF
  ELSE
   SET flex_get_error_ind = 1
  ENDIF
  SET ops_nbr_to_update = cnvtint(size(ops_request->productlist,5))
  FOR (prod = 1 TO ops_nbr_to_update)
    SET failure_occured = "F"
    SET product_event_id = 0.0
    SET pd_qty = 0
    SET as_qty = 0
    SET thistable = "unkn"
    IF (flex_get_error_ind=1)
     IF ((ops_request->productlist[prod].flex_prod_ind=1))
      IF ((ops_request->productlist[prod].status != "F"))
       SET ops_request->productlist[prod].status = "F"
       SET error_message = "Expiration Check Failed"
       SET ops_request->productlist[prod].err_message = error_message
       SET reply->status_data.subeventstatus[prod].targetobjectvalue = error_message
       SET error_process = "bbt_get_avail_flex_specs"
       SET failure_occured = "T"
       SET reply->status_data.subeventstatus[prod].operationname = "chk"
       SET reply->status_data.subeventstatus[prod].operationstatus = "F"
       SET reply->status_data.status = "F"
      ENDIF
     ELSE
      IF ((ops_request->productlist[prod].status != "F"))
       SET ops_request->productlist[prod].status = "F"
       SET error_message = ""
       SET ops_request->productlist[prod].err_message = error_message
       SET reply->status_data.subeventstatus[prod].targetobjectvalue = error_message
       SET error_process = "bbt_get_avail_flex_specs"
       SET failure_occured = "T"
       SET reply->status_data.subeventstatus[prod].operationname = "chk"
       SET reply->status_data.subeventstatus[prod].operationstatus = "F"
       SET reply->status_data.status = "F"
      ENDIF
     ENDIF
    ENDIF
    IF ((ops_request->productlist[prod].status != "F"))
     CALL add_product_event(ops_request->productlist[prod].product_id,ops_request->productlist[prod].
      person_id,ops_request->productlist[prod].encounter_id,0,0,
      transfused_event_type_cd,cnvtdatetime(ops_request->productlist[prod].transfused_dt_tm),
      ops_request->productlist[prod].event_prsnl_id,0,0,
      0,ops_request->productlist[prod].pd_product_event_id,1,reqdata->active_status_cd,cnvtdatetime(
       sysdate),
      reqinfo->updt_id)
     IF (curqual=0)
      SET failure_occured = "T"
      SET reply->status_data.subeventstatus[prod].operationname = "add"
      SET reply->status_data.subeventstatus[prod].operationstatus = "F"
      SET error_process = "transfuse product_event"
      SET error_message = "fail on add transfuse product event"
      SET reply->status_data.subeventstatus[prod].targetobjectvalue = error_message
     ELSE
      INSERT  FROM transfusion t
       SET t.product_event_id = product_event_id, t.product_id = ops_request->productlist[prod].
        product_id, t.person_id = ops_request->productlist[prod].person_id,
        t.bag_returned_ind = ops_request->productlist[prod].bag_returned_ind, t.tag_returned_ind =
        ops_request->productlist[prod].tag_returned_ind, t.transfused_vol = ops_request->productlist[
        prod].transfused_vol,
        t.orig_transfused_qty = ops_request->productlist[prod].transfused_qty, t.cur_transfused_qty
         = ops_request->productlist[prod].transfused_qty, t.transfused_intl_units = ops_request->
        productlist[prod].transfused_iu,
        t.updt_cnt = 0, t.updt_dt_tm = cnvtdatetime(sysdate), t.updt_id = reqinfo->updt_id,
        t.updt_task = reqinfo->updt_task, t.updt_applctx = reqinfo->updt_applctx, t.active_ind = 1,
        t.active_status_cd = reqdata->active_status_cd, t.active_status_dt_tm = cnvtdatetime(sysdate),
        t.active_status_prsnl_id = reqinfo->updt_id
       WITH counter
      ;end insert
      IF (curqual=0)
       SET failure_occured = "T"
       SET reply->status_data.subeventstatus[prod].operationname = "add"
       SET reply->status_data.subeventstatus[prod].operationstatus = "F"
       SET error_process = "add transfusion"
       SET error_message = "fail on add to transfusion table"
       SET reply->status_data.subeventstatus[prod].targetobjectvalue = error_message
      ENDIF
     ENDIF
    ELSE
     SET failure_occured = "T"
    ENDIF
    IF (failure_occured="F"
     AND (ops_request->productlist[prod].status != "F"))
     SELECT INTO "nl:"
      pe.product_event_id, pd.product_event_id
      FROM patient_dispense pd,
       product_event pe
      PLAN (pe
       WHERE (pe.product_event_id=ops_request->productlist[prod].pd_product_event_id)
        AND (pe.updt_cnt=ops_request->productlist[prod].pe_pd_updt_cnt))
       JOIN (pd
       WHERE pe.product_event_id=pd.product_event_id
        AND (pd.updt_cnt=ops_request->productlist[prod].pd_updt_cnt))
      DETAIL
       pd_qty = pd.cur_dispense_qty, dproducteventid = pe.product_event_id
      WITH nocounter
     ;end select
     IF (curqual=0)
      SET failure_occured = "T"
      SET reply->status_data.subeventstatus[prod].operationname = "lock"
      SET reply->status_data.subeventstatus[prod].operationstatus = "F"
      SET error_process = "lock tables for update"
      SET error_message = "fail lock patient_dispense/product_event"
      SET reply->status_data.subeventstatus[prod].targetobjectvalue = error_message
     ELSE
      SELECT INTO "nl"
       FROM patient_dispense pd
       WHERE pd.product_event_id=dproducteventid
       WITH nocounter, forupdate(pd)
      ;end select
      SELECT INTO "nl"
       FROM product_event pe
       WHERE pe.product_event_id=dproducteventid
       WITH nocounter, forupdate(pe)
      ;end select
      UPDATE  FROM product_event pe
       SET pe.updt_cnt = (pe.updt_cnt+ 1), pe.updt_dt_tm = cnvtdatetime(sysdate), pe.updt_id =
        reqinfo->updt_id,
        pe.updt_task = reqinfo->updt_task, pe.updt_applctx = reqinfo->updt_applctx, pe.active_ind =
        IF ((ops_request->productlist[prod].product_type="B")) 0
        ELSEIF ((pd_qty=ops_request->productlist[prod].transfused_qty)) 0
        ELSE 1
        ENDIF
        ,
        pe.active_status_cd =
        IF ((ops_request->productlist[prod].product_type="B")) reqdata->inactive_status_cd
        ELSEIF ((pd_qty=ops_request->productlist[prod].transfused_qty)) reqdata->inactive_status_cd
        ELSE reqdata->active_status_cd
        ENDIF
       WHERE (pe.product_event_id=ops_request->productlist[prod].pd_product_event_id)
        AND (pe.updt_cnt=ops_request->productlist[prod].pe_pd_updt_cnt)
       WITH nocounter
      ;end update
      IF (curqual=0)
       SET failure_occured = "T"
       SET reply->status_data.subeventstatus[prod].operationname = "chg"
       SET reply->status_data.subeventstatus[prod].operationstatus = "F"
       SET error_process = "update product event dispense"
       SET error_message = "fail on product_event update"
       SET reply->status_data.subeventstatus[prod].targetobjectvalue = error_message
      ELSE
       UPDATE  FROM patient_dispense pd
        SET pd.dispense_status_flag = 2, pd.cur_dispense_qty =
         IF ((ops_request->productlist[prod].product_type="B")) 0
         ELSEIF ((pd_qty=ops_request->productlist[prod].transfused_qty)) 0
         ELSE (pd_qty - ops_request->productlist[prod].transfused_qty)
         ENDIF
         , pd.updt_cnt = (pd.updt_cnt+ 1),
         pd.updt_dt_tm = cnvtdatetime(sysdate), pd.updt_id = reqinfo->updt_id, pd.updt_task = reqinfo
         ->updt_task,
         pd.updt_applctx = reqinfo->updt_applctx, pd.active_ind =
         IF ((ops_request->productlist[prod].product_type="B")) 0
         ELSEIF ((pd_qty=ops_request->productlist[prod].transfused_qty)) 0
         ELSE 1
         ENDIF
         , pd.active_status_cd =
         IF ((ops_request->productlist[prod].product_type="B")) reqdata->inactive_status_cd
         ELSEIF ((pd_qty=ops_request->productlist[prod].transfused_qty)) reqdata->inactive_status_cd
         ELSE reqdata->active_status_cd
         ENDIF
        WHERE (pd.product_event_id=ops_request->productlist[prod].pd_product_event_id)
         AND (pd.updt_cnt=ops_request->productlist[prod].pd_updt_cnt)
        WITH nocounter
       ;end update
       IF (curqual=0)
        SET failure_occured = "T"
        SET reply->status_data.subeventstatus[prod].operationname = "chg"
        SET reply->status_data.subeventstatus[prod].operationstatus = "F"
        SET error_process = "update patient dispense"
        SET error_message = "fail on  patient dispense update"
        SET reply->status_data.subeventstatus[prod].targetobjectvalue = error_message
       ENDIF
      ENDIF
     ENDIF
    ENDIF
    IF (failure_occured="F"
     AND (ops_request->productlist[prod].product_type="B")
     AND (ops_request->productlist[prod].events_to_release > 0))
     FOR (count2 = 1 TO ops_request->productlist[prod].events_to_release)
      IF (failure_occured="F"
       AND (ops_request->productlist[prod].eventlist[count2].event_type="AG"))
       UPDATE  FROM assign a
        SET a.updt_cnt = (a.updt_cnt+ 1), a.updt_dt_tm = cnvtdatetime(sysdate), a.updt_id = reqinfo->
         updt_id,
         a.updt_task = reqinfo->updt_task, a.updt_applctx = reqinfo->updt_applctx, a.active_ind = 0,
         a.active_status_cd = reqdata->inactive_status_cd
        WHERE (a.product_event_id=ops_request->productlist[prod].eventlist[count2].
        xm_product_event_id)
         AND (a.updt_cnt=ops_request->productlist[prod].eventlist[count2].xm_updt_cnt)
        WITH nocounter
       ;end update
       IF (curqual=0)
        SET failure_occured = "T"
        SET reply->status_data.subeventstatus[prod].operationname = "chg"
        SET reply->status_data.subeventstatus[prod].operationstatus = "F"
        SET error_process = "update assign"
        SET error_message = "fail on assign update"
        SET reply->status_data.subeventstatus[prod].targetobjectvalue = error_message
       ENDIF
      ELSEIF (failure_occured="F"
       AND (ops_request->productlist[prod].eventlist[count2].event_type="XM"))
       UPDATE  FROM crossmatch xm
        SET xm.updt_cnt = (xm.updt_cnt+ 1), xm.updt_dt_tm = cnvtdatetime(sysdate), xm.updt_id =
         reqinfo->updt_id,
         xm.updt_task = reqinfo->updt_task, xm.updt_applctx = reqinfo->updt_applctx, xm.active_ind =
         0,
         xm.active_status_cd = reqdata->inactive_status_cd
        WHERE (xm.product_event_id=ops_request->productlist[prod].eventlist[count2].
        xm_product_event_id)
         AND (xm.updt_cnt=ops_request->productlist[prod].eventlist[count2].xm_updt_cnt)
        WITH nocounter
       ;end update
       IF (curqual=0)
        SET failure_occured = "T"
        SET reply->status_data.subeventstatus[prod].operationname = "chg"
        SET reply->status_data.subeventstatus[prod].operationstatus = "F"
        SET error_process = "update crossmatch"
        SET error_message = "fail on crossmatch update"
        SET reply->status_data.subeventstatus[prod].targetobjectvalue = error_message
       ENDIF
      ENDIF
      IF (failure_occured="F"
       AND (ops_request->productlist[prod].eventlist[count2].event_type != "  "))
       UPDATE  FROM product_event pe
        SET pe.updt_cnt = (pe.updt_cnt+ 1), pe.updt_dt_tm = cnvtdatetime(sysdate), pe.updt_id =
         reqinfo->updt_id,
         pe.updt_task = reqinfo->updt_task, pe.updt_applctx = reqinfo->updt_applctx, pe.active_ind =
         0,
         pe.active_status_cd = reqdata->inactive_status_cd
        WHERE (pe.product_event_id=ops_request->productlist[prod].eventlist[count2].
        xm_product_event_id)
         AND (pe.updt_cnt=ops_request->productlist[prod].eventlist[count2].pe_xm_updt_cnt)
        WITH nocounter
       ;end update
       IF (curqual=0)
        SET failure_occured = "T"
        SET reply->status_data.subeventstatus[prod].operationname = "chg"
        SET reply->status_data.subeventstatus[prod].operationstatus = "F"
        SET error_process = "update assign product event"
        SET error_message = "fail on update product_event"
        SET reply->status_data.subeventstatus[prod].targetobjectvalue = error_message
       ENDIF
      ENDIF
     ENDFOR
    ENDIF
    IF (failure_occured="T")
     SET reply->results[prod].status = "F"
     SET ops_request->productlist[prod].status = "F"
     SET ops_request->productlist[prod].err_message = error_message
    ELSE
     SET insert_bb_tables_cnt += 1
    ENDIF
    SET reply->results[prod].product_id = ops_request->productlist[prod].product_id
    SET reply->results[prod].product_event_id = product_event_id
  ENDFOR
  IF (failure_occured="F")
   IF (flexupd_run(null)=0)
    SET flex_upd_error_flag = flex_upd_error
    SET failure_occured = "T"
    SET reply->status_data.status = "F"
    CALL log_message("flex update error",log_level_audit)
   ELSE
    SET stat = flexupd_printreports(null)
   ENDIF
  ENDIF
  FOR (prod = 1 TO ops_nbr_to_update)
   SET failure_occured = "F"
   IF ((ops_request->productlist[prod].status != "F"))
    IF (flex_upd_error_flag > 0
     AND (ops_request->productlist[prod].flex_prod_ind=1))
     SET failure_occured = "T"
     IF (flex_upd_error_flag=flex_upd_error)
      SET error_message = "Expiration Updates Failed"
     ENDIF
     SET reply->status_data.subeventstatus[prod].operationname = "FlexUpd"
     SET reply->status_data.subeventstatus[prod].operationstatus = "F"
     SET reply->status_data.subeventstatus[prod].targetobjectvalue = error_message
     SET error_process = error_message
     SET reply->results[prod].status = "F"
     SET ops_request->productlist[prod].status = "F"
     SET ops_request->productlist[prod].err_message = error_message
    ELSE
     SET ops_bat_success_cnt += 1
     SET ops_request->productlist[prod].status = "S"
     SET reply->results[prod].batch_transfuse_ind = "Y"
     IF ((ops_request->productlist[prod].err_message < " "))
      SET ops_request->productlist[prod].err_message = ""
     ENDIF
     SET reply->ltransfused_product_cnt += 1
     SET reply->results[prod].product_type = ops_request->productlist[prod].product_type
     SET reply->results[prod].person_id = ops_request->productlist[prod].person_id
     SET reply->results[prod].encounter_id = ops_request->productlist[prod].encounter_id
     SET reply->results[prod].event_prsnl_id = ops_request->productlist[prod].event_prsnl_id
     SET reply->results[prod].transfused_iu = ops_request->productlist[prod].transfused_iu
     SET reply->results[prod].transfused_qty = ops_request->productlist[prod].transfused_qty
     SET reply->results[prod].transfused_vol = ops_request->productlist[prod].transfused_vol
     SET reply->results[prod].transfused_dt_tm = ops_request->productlist[prod].transfused_dt_tm
     SET reply->results[prod].transfused_tz = ops_request->productlist[prod].transfused_tz
     SET reply->results[prod].pd_product_event_id = ops_request->productlist[prod].
     pd_product_event_id
     SET reply->results[prod].product_id = ops_request->productlist[prod].product_id
     SET reply->results[prod].status = "S"
    ENDIF
   ENDIF
  ENDFOR
 ENDIF
 IF (ops_bat_success_cnt=insert_bb_tables_cnt
  AND (reply->status_data.status != "F")
  AND (reply->status_data.status != "Z"))
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL log_message(build("ops_bat_success_cnt =",ops_bat_success_cnt),log_level_debug)
 CALL log_message(build("reply status =",reply->status_data.status),log_level_debug)
 IF ((reply->status_data.status != "F")
  AND (reply->status_data.status != "Z")
  AND cnvtupper(batch_field)="UPDATE")
  SET g_sub_event_type_flag = 1
  SET g_sub_num_products = size(ops_request->productlist,5)
  IF (ops_bat_success_cnt=insert_bb_tables_cnt)
   SET stat = insert_pn_recovery_data(1)
   IF (stat=1)
    SET reply->status_data.status = "S"
    SET reqinfo->commit_ind = 1
   ELSEIF (stat=2)
    SET reply->status_data.status = "S"
    SET reqinfo->commit_ind = 1
   ELSE
    SET reply->status_data.status = "F"
    SET reqinfo->commit_ind = 0
   ENDIF
  ELSE
   SET reqinfo->commit_ind = 0
   FOR (i = 1 TO g_sub_num_products)
     SET ops_request->productlist[i].status = "F"
   ENDFOR
  ENDIF
  IF ((reqinfo->commit_ind=0))
   CALL log_message("Error found, rolling back",log_level_info)
   ROLLBACK
  ENDIF
 ELSE
  SET reqinfo->commit_ind = 0
  SET g_sub_num_products = size(ops_request->productlist,5)
  IF (ops_bat_success_cnt != insert_bb_tables_cnt)
   FOR (i = 1 TO g_sub_num_products)
     SET ops_request->productlist[i].status = "F"
   ENDFOR
  ENDIF
  ROLLBACK
 ENDIF
 IF (size(ops_request->productlist,5) > 0)
  UPDATE  FROM (dummyt d  WITH seq = value(size(ops_request->productlist,5))),
    product p
   SET p.locked_ind = 0, p.updt_cnt = (p.updt_cnt+ 1), p.updt_dt_tm = cnvtdatetime(sysdate),
    p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->
    updt_applctx
   PLAN (d)
    JOIN (p
    WHERE (p.product_id=ops_request->productlist[d.seq].product_id)
     AND (p.updt_cnt=ops_request->productlist[d.seq].p_updt_cnt)
     AND (ops_request->productlist[d.seq].need_to_unlock_ind=1))
   WITH nocounter
  ;end update
 ENDIF
 CALL log_message("Success found, commit",log_level_debug)
 SET stat = lockflexproducts(0)
 IF ((stat=- (1)))
  CALL log_message("Unlock Flex Failed",log_level_debug)
 ENDIF
 COMMIT
#generate_report
 SET sub_get_location_name = fillstring(25," ")
 SET sub_get_location_address1 = fillstring(100," ")
 SET sub_get_location_address2 = fillstring(100," ")
 SET sub_get_location_address3 = fillstring(100," ")
 SET sub_get_location_address4 = fillstring(100," ")
 SET sub_get_location_citystatezip = fillstring(100," ")
 SET sub_get_location_country = fillstring(100," ")
 IF ((request->address_location_cd != 0))
  SET addr_type_cd = 0.0
  SET code_cnt = 1
  SET stat = uar_get_meaning_by_codeset(212,"BUSINESS",code_cnt,addr_type_cd)
  IF (addr_type_cd=0.0)
   SET sub_get_location_name = "<<INFORMATION NOT FOUND>>"
  ELSE
   SELECT INTO "nl:"
    a.street_addr, a.street_addr2, a.street_addr3,
    a.street_addr4, a.city, a.state,
    a.zipcode, a.country, l.location_cd
    FROM address a
    WHERE a.active_ind=1
     AND a.address_type_cd=addr_type_cd
     AND a.parent_entity_name="LOCATION"
     AND (a.parent_entity_id=request->address_location_cd)
    DETAIL
     sub_get_location_name = uar_get_code_display(request->address_location_cd),
     sub_get_location_address1 = a.street_addr, sub_get_location_address2 = a.street_addr2,
     sub_get_location_address3 = a.street_addr3, sub_get_location_address4 = a.street_addr4,
     sub_get_location_citystatezip = concat(trim(a.city),", ",trim(a.state),"  ",trim(a.zipcode)),
     sub_get_location_country = a.country
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET sub_get_location_name = "<<INFORMATION NOT FOUND>>"
   ENDIF
  ENDIF
 ELSE
  SET sub_get_location_name = "<<INFORMATION NOT FOUND>>"
 ENDIF
 SET person_chg = "F"
 SET abo = "  "
 SET rh = "   "
 SET number = "                    "
 SET sub_number = fillstring(5," ")
 SET abo_rh = "      "
 SET med_num = "                   "
 SET pat_name = "                     "
 SET prod_num = "                         "
 SET states = "                    "
 SET location = "                   "
 SET line = fillstring(125,"_")
 SET quantity = "Quantity: "
 SET quantity_disp = "              "
 SET cur_owner_area_disp = fillstring(40," ")
 SET cur_inv_area_disp = fillstring(40," ")
 SET count1 = cnvtint(size(ops_request->productlist,5))
 SET count2 = 1
 IF (count1 > 1)
  SET count2 = count1
 ENDIF
 SET select_ok_ind = 0
 SET rpt_cnt = 0
 IF (trim(request->batch_selection) > " ")
  CALL check_owner_cd("bbt_ops_batch_transfusion.prg")
  CALL check_inventory_cd("bbt_ops_batch_transfusion.prg")
 ENDIF
 EXECUTE cpm_create_file_name_logical "bbt_batch_trans", "txt", "x"
 SELECT INTO cpm_cfn_info->file_name_logical
  per.person_id, per.name_full_formatted, ea.encntr_id,
  ea.alias, ea.alias_pool_cd, alias_mrn = decode(ea.seq,substring(1,20,cnvtalias(ea.alias,ea
     .alias_pool_cd)),fillstring(20," ")),
  pd.product_event_id, p.product_id, p.cur_inv_area_cd,
  p.cur_owner_area_cd, p.serial_number_txt, bp.product_cd,
  bp.cur_abo_cd, bp.cur_rh_cd, c_accession = cnvtacc(ord.accession),
  abo_disp = uar_get_code_display(bp.cur_abo_cd), rh_disp = uar_get_code_display(bp.cur_rh_cd),
  prod_disp = uar_get_code_display(p.product_cd)
  FROM product p,
   (dummyt d_bp  WITH seq = 1),
   blood_product bp,
   patient_dispense pd,
   (dummyt d_ea  WITH seq = 1),
   encntr_alias ea,
   (dummyt d_ord  WITH seq = 1),
   accession_order_r ord,
   person per,
   (dummyt d_ar  WITH seq = value(count2))
  PLAN (d_ar)
   JOIN (pd
   WHERE (pd.product_event_id=ops_request->productlist[d_ar.seq].pd_product_event_id))
   JOIN (p
   WHERE (p.product_id=ops_request->productlist[d_ar.seq].product_id)
    AND (((request->cur_owner_area_cd > 0.0)
    AND (request->cur_owner_area_cd=p.cur_owner_area_cd)) OR ((request->cur_owner_area_cd=0.0)))
    AND (((request->cur_inv_area_cd > 0.0)
    AND (request->cur_inv_area_cd=p.cur_inv_area_cd)) OR ((request->cur_inv_area_cd=0.0))) )
   JOIN (per
   WHERE (per.person_id=ops_request->productlist[d_ar.seq].person_id))
   JOIN (d_ea
   WHERE d_ea.seq=1)
   JOIN (ea
   WHERE (ops_request->productlist[d_ar.seq].encounter_id=ea.encntr_id)
    AND ea.active_ind=1
    AND ea.encntr_alias_type_cd=mrn_code_val
    AND ea.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ea.end_effective_dt_tm >= cnvtdatetime(sysdate))
   JOIN (d_bp
   WHERE d_bp.seq=1)
   JOIN (bp
   WHERE p.product_id=bp.product_id)
   JOIN (d_ord
   WHERE d_ord.seq=1)
   JOIN (ord
   WHERE (ord.order_id=ops_request->productlist[d_ar.seq].order_id)
    AND ord.primary_flag=0)
  ORDER BY p.cur_owner_area_cd, p.cur_inv_area_cd, per.name_full_formatted,
   per.person_id, p.product_id
  HEAD REPORT
   IF (count1 > 0)
    cur_owner_area_cd_hd = p.cur_owner_area_cd, cur_inv_area_cd_hd = p.cur_inv_area_cd,
    cur_owner_area_disp = uar_get_code_display(cur_owner_area_cd_hd),
    cur_inv_area_disp = uar_get_code_display(cur_inv_area_cd_hd), select_ok_ind = 0
   ENDIF
  HEAD PAGE
   CALL center(ops_captions->rpt_batch_transfusion,1,125), col 107, ops_captions->as_of_date,
   col 119, request->ops_date"@DATECONDENSED;;d", row + 1
   IF (cnvtupper(batch_field)="UPDATE")
    CALL center(ops_captions->report_update,1,125)
   ELSE
    CALL center(ops_captions->report_only,1,125)
   ENDIF
   col 107, ops_captions->as_of_time, col 119,
   request->ops_date"@TIMENOSECONDS;;M", inc_i18nhandle = 0, inc_h = uar_i18nlocalizationinit(
    inc_i18nhandle,curprog,"",curcclrev),
   row 0
   IF (sub_get_location_name="<<INFORMATION NOT FOUND>>")
    inc_info_not_found = uar_i18ngetmessage(inc_i18nhandle,"inc_information_not_found",
     "<<INFORMATION NOT FOUND>>"), col 1, inc_info_not_found
   ELSE
    col 1, sub_get_location_name
   ENDIF
   row + 1
   IF (sub_get_location_name != "<<INFORMATION NOT FOUND>>")
    IF (sub_get_location_address1 != " ")
     col 1, sub_get_location_address1, row + 1
    ENDIF
    IF (sub_get_location_address2 != " ")
     col 1, sub_get_location_address2, row + 1
    ENDIF
    IF (sub_get_location_address3 != " ")
     col 1, sub_get_location_address3, row + 1
    ENDIF
    IF (sub_get_location_address4 != " ")
     col 1, sub_get_location_address4, row + 1
    ENDIF
    IF (sub_get_location_citystatezip != ",   ")
     col 1, sub_get_location_citystatezip, row + 1
    ENDIF
    IF (sub_get_location_country != " ")
     col 1, sub_get_location_country, row + 1
    ENDIF
   ENDIF
   row + 1, col 1, ops_captions->blood_bank_owner,
   col 19, cur_owner_area_disp, row + 1,
   col 1, ops_captions->inventory_area, col 19,
   cur_inv_area_disp, row + 3,
   CALL center(ops_captions->grp,1,7),
   CALL center(ops_captions->unit_number,56,80),
   CALL center(ops_captions->current,102,111),
   CALL center(ops_captions->patient_name,28,54),
   CALL center(ops_captions->transfuse,113,125), row + 1,
   CALL center(ops_captions->type,1,7),
   CALL center(ops_captions->medical_number,8,27),
   CALL center(ops_captions->location,28,54),
   CALL center(ops_captions->accession_number,56,80),
   CALL center(ops_captions->product,82,100),
   CALL center(ops_captions->status,102,111),
   CALL center(ops_captions->date_time,113,125),
   row + 1,
   CALL center(ops_captions->serial_number,56,80), row + 1,
   col 1, "------", col 8,
   "-------------------", col 28, "---------------------------",
   col 56, "-------------------------", col 82,
   "-------------------", col 102, "----------",
   col 113, "-------------"
  HEAD p.cur_owner_area_cd
   IF (p.cur_owner_area_cd != cur_owner_area_cd_hd
    AND count1 > 0)
    cur_owner_area_disp = uar_get_code_display(p.cur_owner_area_cd), cur_owner_area_cd_hd = p
    .cur_owner_area_cd, cur_inv_area_disp = uar_get_code_display(p.cur_inv_area_cd),
    cur_inv_area_cd_hd = p.cur_inv_area_cd, BREAK
   ENDIF
  HEAD p.cur_inv_area_cd
   IF (p.cur_inv_area_cd != cur_inv_area_cd_hd
    AND count1 > 0)
    cur_inv_area_disp = uar_get_code_display(p.cur_inv_area_cd), cur_inv_area_cd_hd = p
    .cur_inv_area_cd, BREAK
   ENDIF
  HEAD pd.product_event_id
   IF (count1 > 0)
    locn_disp = uar_get_code_display(ops_request->productlist[d_ar.seq].dispense_to_locn_cd)
   ENDIF
  HEAD per.person_id
   IF (row > 58)
    BREAK
   ENDIF
   med_num = trim(alias_mrn), pat_name = per.name_full_formatted
  HEAD p.product_id
   IF (row >= 54)
    BREAK
   ENDIF
   IF ((ops_request->productlist[d_ar.seq].product_id > 0.0))
    row + 1, abo_rh = concat(trim(abo_disp)," ",trim(rh_disp)), number = p.product_nbr,
    sub_number = p.product_sub_nbr, location = locn_disp, prod_num = concat(trim(bp.supplier_prefix,3
      ),trim(number,3)," ",trim(sub_number,3))
    IF ((ops_request->productlist[d_ar.seq].status="S")
     AND cnvtupper(batch_field)="UPDATE")
     states = trim(transfused_event_disp)
    ELSE
     states = trim(dispensed_event_disp)
     IF ((ops_request->productlist[d_ar.seq].err_message > " "))
      row + 1, col 90, ops_request->productlist[d_ar.seq].err_message,
      row- (1)
     ENDIF
    ENDIF
    col 1, abo_rh, col 8,
    med_num, col 28, pat_name,
    col 56, prod_num, col 82,
    prod_disp, col 102, states,
    col 113, ops_request->productlist[d_ar.seq].transfused_dt_tm"@DATETIMECONDENSED;;d", row + 1
    IF ((ops_request->productlist[d_ar.seq].product_type="D"))
     quantity_disp = concat(quantity,cnvtstring(ops_request->productlist[d_ar.seq].transfused_qty)),
     col 1, quantity_disp
    ENDIF
    col 28, location, col 56,
    c_accession
    IF (p.serial_number_txt != null)
     row + 1, col 56, p.serial_number_txt
    ENDIF
    IF (row >= 57)
     BREAK
    ENDIF
   ELSEIF (count1 <= 1)
    IF (row >= 57)
     BREAK
    ENDIF
    row + 1,
    CALL center(ops_captions->rpt_no_dispensed,1,125)
   ENDIF
  DETAIL
   row + 0
  FOOT PAGE
   row 59, col 1, line,
   row + 1, col 1, ops_captions->report_id,
   col 60, ops_captions->rpt_page, col 67,
   curpage"###", col 103, ops_captions->printed,
   col 112, curdate"@DATECONDENSED;;d", col 121,
   curtime"@TIMENOSECONDS;;M", row + 1, col 1,
   ops_captions->message
  FOOT REPORT
   row 62, col 53, ops_captions->end_of_report,
   select_ok_ind = 1
  WITH nocounter, outerjoin(d_ord), dontcare = ea,
   dontcare = bp, maxrow = 63, compress,
   nolandscape, nullreport
 ;end select
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
 SET rpt_cnt += 1
 SET stat = alterlist(reply->rpt_list,rpt_cnt)
 SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
 SET spool value(reply->rpt_list[rpt_cnt].rpt_filename) value(request->output_dist)
 IF (select_ok_ind=1
  AND (reply->status_data.status != "Z")
  AND (reply->status_data.status != "F"))
  SET reply->status_data.status = "S"
 ELSEIF ((reply->status_data.status="Z"))
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
#exit_script
 CALL log_message("---BBT_OPS_BATCH_TRANSFUSION ENDING",log_level_debug)
 CALL uar_sysdestroyhandle(hsys)
END GO
