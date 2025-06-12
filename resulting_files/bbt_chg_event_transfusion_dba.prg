CREATE PROGRAM bbt_chg_event_transfusion:dba
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
 SET log_program_name = "bbt_chg_event_transfusion"
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 results[1]
     2 product_event_id = f8
     2 dispense_event_id = f8
     2 product_id = f8
     2 status = c1
     2 err_process = vc
     2 err_message = vc
     2 pn_recovery_id = f8
     2 event_type_flag = i2
 )
 CALL log_message("---BBT_CHG_EVENT_TRANSFUSION STARTING",log_level_debug)
 DECLARE flex_get_error_ind = i2 WITH protect, noconstant(0)
 DECLARE flex_upd_error_flag = i2 WITH protect, noconstant(0)
 DECLARE flex_upd_error = i2 WITH protect, constant(1)
 DECLARE chg_event_transfuse_succss_cnt = i4 WITH protect, noconstant(0)
 DECLARE chg_event_transfuse_prod_cnt = i4 WITH protect, noconstant(0)
 DECLARE product_event_id = f8 WITH public, noconstant(0.0)
 SET nbr_to_add = cnvtint(size(request->productlist,5))
 SET error_process = "                                                         "
 SET error_message = "                                                         "
 SET count1 = 0
 SET count2 = 0
 SET success_cnt = 0
 SET chg_event_transfuse_succss_cnt = 0
 SET product_event_id = 0.0
 SET failure_occured = "F"
 SET pd_qty = 0
 SET pd_iu = 0
 SET as_qty = 0
 SET as_iu = 0
 SET thistable = "    "
 SET other_events = "F"
 SET this_prod_id = 0.0
 SET event_to_inactivate = "F"
 SET stat = alter(reply->results,nbr_to_add)
 SET stat = alter(reply->status_data.subeventstatus,nbr_to_add)
 SET reply->status_data.status = "F"
 SET code_cnt = 1
 SET transfused_event_type_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(1610,"7",code_cnt,transfused_event_type_cd)
 IF (transfused_event_type_cd=0.0)
  SET failure_occured = "T"
  SET reply->status_data.subeventstatus[prod].operationname = "uar_get_meaning_by_codeset"
  SET reply->status_data.subeventstatus[prod].operationstatus = "F"
  SET error_process = "transfused_event_type_cd"
  SET error_message = "unable to retrieve code_value"
 ENDIF
 CALL flexget_init(null)
 FOR (prod = 1 TO nbr_to_add)
   SET failure_occured = "F"
   SET product_event_id = 0.0
   SET pd_qty = 0
   SET pd_iu = 0
   SET as_qty = 0
   SET as_iu = 0
   SET other_events = "F"
   IF ((request->productlist[prod].from_interface_flag > 0))
    SELECT INTO "nl:"
     p.product_id
     FROM product p,
      product_category pc,
      product_index pi
     PLAN (p
      WHERE (p.product_id=request->productlist[prod].product_id))
      JOIN (pi
      WHERE pi.product_cd=p.product_cd
       AND pi.autologous_ind=0)
      JOIN (pc
      WHERE pc.product_cat_cd=pi.product_cat_cd
       AND pc.xmatch_required_ind=1)
     HEAD p.product_id
      IF ((request->productlist[prod].product_type="B"))
       CALL flexget_addperson(request->productlist[prod].person_id)
      ENDIF
     WITH nocounter
    ;end select
    IF (flexget_run(null)=1)
     SET flex_get_error_ind = 0
    ELSE
     SET flex_get_error_ind = 1
    ENDIF
    IF (flex_get_error_ind=1)
     SET failure_occured = "T"
     SET reply->status_data.subeventstatus[prod].operationname = "chk"
     SET reply->status_data.subeventstatus[prod].operationstatus = "F"
     SET error_process = "bbt_get_avail_flex_specs"
     SET error_message = "Expiration Check Failed"
    ENDIF
   ENDIF
   SET this_prod_id = request->productlist[prod].product_id
   SET count2 = (prod+ 1)
   IF (prod < nbr_to_add)
    FOR (count1 = count2 TO nbr_to_add)
      IF ((this_prod_id=request->productlist[count1].product_id))
       SET other_events = "T"
      ENDIF
    ENDFOR
   ENDIF
   CALL add_product_event(request->productlist[prod].product_id,request->productlist[prod].person_id,
    request->productlist[prod].encounter_id,0,0,
    transfused_event_type_cd,cnvtdatetime(request->productlist[prod].transfused_dt_tm),request->
    productlist[prod].event_prsnl_id,0,0,
    0,request->productlist[prod].pd_product_event_id,1,reqdata->active_status_cd,cnvtdatetime(sysdate
     ),
    reqinfo->updt_id)
   IF (curqual=0)
    SET failure_occured = "T"
    SET reply->status_data.subeventstatus[prod].operationname = "add"
    SET reply->status_data.subeventstatus[prod].operationstatus = "F"
    SET error_process = "transfuse product_event"
    SET error_message = "unable to add transfuse product event"
   ELSE
    SET reply->results[prod].product_event_id = product_event_id
    INSERT  FROM transfusion t
     SET t.product_event_id = product_event_id, t.product_id = request->productlist[prod].product_id,
      t.person_id = request->productlist[prod].person_id,
      t.bag_returned_ind = request->productlist[prod].bag_returned_ind, t.tag_returned_ind = request
      ->productlist[prod].tag_returned_ind, t.transfused_vol = request->productlist[prod].
      transfused_vol,
      t.orig_transfused_qty = request->productlist[prod].transfused_qty, t.cur_transfused_qty =
      request->productlist[prod].transfused_qty, t.transfused_intl_units = request->productlist[prod]
      .transfused_iu,
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
     SET error_message = "unable to add transfusion event"
    ENDIF
   ENDIF
   IF (failure_occured="F")
    SELECT INTO "nl:"
     pe.product_event_id
     FROM product_event pe
     PLAN (pe
      WHERE (pe.product_event_id=request->productlist[prod].pd_product_event_id)
       AND (pe.updt_cnt=request->productlist[prod].pe_pd_updt_cnt))
     WITH nocounter, forupdate(pe)
    ;end select
    IF (curqual != 0)
     SELECT INTO "nl:"
      pd.product_event_id
      FROM patient_dispense pd
      PLAN (pd
       WHERE (pd.product_event_id=request->productlist[prod].pd_product_event_id)
        AND (pd.updt_cnt=request->productlist[prod].pd_updt_cnt))
      DETAIL
       pd_qty = pd.cur_dispense_qty, pd_iu = pd.cur_dispense_intl_units
      WITH nocounter, forupdate(pd)
     ;end select
    ENDIF
    IF (curqual=0)
     SET failure_occured = "T"
     SET reply->status_data.subeventstatus[prod].operationname = "lock"
     SET reply->status_data.subeventstatus[prod].operationstatus = "F"
     SET error_process = "lock tables for update"
     SET error_message = "unable to lock tables for update"
     IF (thistable="unkn")
      SET error_process = "no xmatch/assign"
      SET error_message = "xmatch/assign information not found"
     ENDIF
    ELSE
     UPDATE  FROM product_event pe
      SET pe.updt_cnt = (pe.updt_cnt+ 1), pe.updt_dt_tm = cnvtdatetime(sysdate), pe.updt_id = reqinfo
       ->updt_id,
       pe.updt_task = reqinfo->updt_task, pe.updt_applctx = reqinfo->updt_applctx, pe.active_ind =
       IF ((request->productlist[prod].product_type="B")) 0
       ELSEIF ((pd_qty <= request->productlist[prod].transfused_qty)) 0
       ELSE 1
       ENDIF
       ,
       pe.active_status_cd =
       IF ((request->productlist[prod].product_type="B")) reqdata->inactive_status_cd
       ELSEIF ((pd_qty=request->productlist[prod].transfused_qty)) reqdata->inactive_status_cd
       ELSE reqdata->active_status_cd
       ENDIF
      WHERE (pe.product_event_id=request->productlist[prod].pd_product_event_id)
       AND (pe.updt_cnt=request->productlist[prod].pe_pd_updt_cnt)
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET failure_occured = "T"
      SET reply->status_data.subeventstatus[prod].operationname = "chg"
      SET reply->status_data.subeventstatus[prod].operationstatus = "F"
      SET error_process = "update product event dispense"
      SET error_message = "dispense product event row not updated"
     ELSE
      UPDATE  FROM patient_dispense pd
       SET pd.dispense_status_flag = 2, pd.cur_dispense_qty =
        IF ((request->productlist[prod].product_type="B")) 0
        ELSEIF ((pd_qty <= request->productlist[prod].transfused_qty)) 0
        ELSE (pd_qty - request->productlist[prod].transfused_qty)
        ENDIF
        , pd.cur_dispense_intl_units =
        IF ((request->productlist[prod].product_type="B")) 0
        ELSEIF ((pd_iu=request->productlist[prod].transfused_iu)) 0
        ELSE (pd_iu - request->productlist[prod].transfused_iu)
        ENDIF
        ,
        pd.updt_cnt = (pd.updt_cnt+ 1), pd.updt_dt_tm = cnvtdatetime(sysdate), pd.updt_id = reqinfo->
        updt_id,
        pd.updt_task = reqinfo->updt_task, pd.updt_applctx = reqinfo->updt_applctx, pd.active_ind =
        IF ((request->productlist[prod].product_type="B")) 0
        ELSEIF ((pd_qty <= request->productlist[prod].transfused_qty)) 0
        ELSE 1
        ENDIF
        ,
        pd.active_status_cd =
        IF ((request->productlist[prod].product_type="B")) reqdata->inactive_status_cd
        ELSEIF ((pd_qty <= request->productlist[prod].transfused_qty)) reqdata->inactive_status_cd
        ELSE reqdata->active_status_cd
        ENDIF
       WHERE (pd.product_event_id=request->productlist[prod].pd_product_event_id)
        AND (pd.updt_cnt=request->productlist[prod].pd_updt_cnt)
       WITH nocounter
      ;end update
      IF (curqual=0)
       SET failure_occured = "T"
       SET reply->status_data.subeventstatus[prod].operationname = "chg"
       SET reply->status_data.subeventstatus[prod].operationstatus = "F"
       SET error_process = "update patient dispense"
       SET error_message = "unable to update patient dispense table"
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   IF (failure_occured="F"
    AND (request->productlist[prod].xm_product_event_id > 0))
    SELECT INTO "nl:"
     pe.product_event_id, a.product_event_id, xm.product_event_id,
     tablefrom = decode(a.seq,"asgn",xm.seq,"xmtc","unkn")
     FROM assign a,
      crossmatch xm,
      product_event pe,
      (dummyt d1  WITH seq = 1)
     PLAN (pe
      WHERE (pe.product_event_id=request->productlist[prod].xm_product_event_id)
       AND (pe.updt_cnt=request->productlist[prod].pe_xm_updt_cnt))
      JOIN (d1
      WHERE d1.seq=1)
      JOIN (((a
      WHERE (a.product_event_id=request->productlist[prod].xm_product_event_id)
       AND (a.updt_cnt=request->productlist[prod].xm_updt_cnt))
      ) ORJOIN ((xm
      WHERE (xm.product_event_id=request->productlist[prod].xm_product_event_id)
       AND (xm.updt_cnt=request->productlist[prod].xm_updt_cnt))
      ))
     DETAIL
      IF (tablefrom="asgn")
       as_qty = a.cur_assign_qty, as_iu = a.cur_assign_intl_units, thistable = "asgn"
      ELSEIF (tablefrom="xmtc")
       as_qty = xm.crossmatch_qty, thistable = "xmtc"
      ENDIF
     WITH nocounter, dontcare = a, dontcare = xm
    ;end select
    IF (curqual != 0)
     SELECT INTO "nl:"
      pe.product_event_id
      FROM product_event pe
      PLAN (pe
       WHERE (pe.product_event_id=request->productlist[prod].xm_product_event_id)
        AND (pe.updt_cnt=request->productlist[prod].pe_xm_updt_cnt))
      WITH nocounter, forupdate(pe)
     ;end select
    ENDIF
    IF (curqual=0)
     SET failure_occured = "T"
     SET reply->status_data.subeventstatus[prod].operationname = "lock"
     SET reply->status_data.subeventstatus[prod].operationstatus = "F"
     SET error_process = "lock tables for update"
     SET error_message = "unable to lock product_event table for update"
    ELSEIF (thistable="asgn")
     UPDATE  FROM assign a
      SET a.cur_assign_qty =
       IF ((request->productlist[prod].product_type="B")) 0
       ELSEIF ((as_qty <= request->productlist[prod].transfused_qty)) 0
       ELSE (as_qty - request->productlist[prod].transfused_qty)
       ENDIF
       , a.cur_assign_intl_units =
       IF ((request->productlist[prod].product_type="B")) 0
       ELSEIF ((as_iu <= request->productlist[prod].transfused_iu)) 0
       ELSE (as_iu - request->productlist[prod].transfused_iu)
       ENDIF
       , a.updt_cnt = (a.updt_cnt+ 1),
       a.updt_dt_tm = cnvtdatetime(sysdate), a.updt_id = reqinfo->updt_id, a.updt_task = reqinfo->
       updt_task,
       a.updt_applctx = reqinfo->updt_applctx, a.active_ind =
       IF ((request->productlist[prod].product_type="B")) 0
       ELSEIF ((as_qty <= request->productlist[prod].transfused_qty)) 0
       ELSE 1
       ENDIF
       , a.active_status_cd =
       IF ((request->productlist[prod].product_type="B")) reqdata->inactive_status_cd
       ELSEIF ((as_qty <= request->productlist[prod].transfused_qty)) reqdata->inactive_status_cd
       ELSE reqdata->active_status_cd
       ENDIF
      WHERE (a.product_event_id=request->productlist[prod].xm_product_event_id)
       AND (a.updt_cnt=request->productlist[prod].xm_updt_cnt)
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET failure_occured = "T"
      SET reply->status_data.subeventstatus[prod].operationname = "chg"
      SET reply->status_data.subeventstatus[prod].operationstatus = "F"
      SET error_process = "update assign"
      SET error_message = "unable to update assign table"
     ELSE
      UPDATE  FROM product_event pe
       SET pe.updt_cnt = (pe.updt_cnt+ 1), pe.updt_dt_tm = cnvtdatetime(sysdate), pe.updt_id =
        reqinfo->updt_id,
        pe.updt_task = reqinfo->updt_task, pe.updt_applctx = reqinfo->updt_applctx, pe.active_ind =
        IF ((request->productlist[prod].product_type="B")) 0
        ELSEIF ((as_qty <= request->productlist[prod].transfused_qty)) 0
        ELSE 1
        ENDIF
        ,
        pe.active_status_cd =
        IF ((request->productlist[prod].product_type="B")) reqdata->inactive_status_cd
        ELSEIF ((as_qty <= request->productlist[prod].transfused_qty)) reqdata->inactive_status_cd
        ELSE reqdata->active_status_cd
        ENDIF
       WHERE (pe.product_event_id=request->productlist[prod].xm_product_event_id)
        AND (pe.updt_cnt=request->productlist[prod].pe_xm_updt_cnt)
       WITH nocounter
      ;end update
      IF (curqual=0)
       SET failure_occured = "T"
       SET reply->status_data.subeventstatus[prod].operationname = "chg"
       SET reply->status_data.subeventstatus[prod].operationstatus = "F"
       SET error_process = "update assign product event"
       SET error_message = "unable to update product event for assign"
      ENDIF
     ENDIF
    ELSEIF (thistable="xmtc")
     UPDATE  FROM crossmatch xm
      SET xm.crossmatch_qty =
       IF ((request->productlist[prod].product_type="B")) 0
       ELSEIF ((as_qty <= request->productlist[prod].transfused_qty)) 0
       ELSE (as_qty - request->productlist[prod].transfused_qty)
       ENDIF
       , xm.updt_cnt = (xm.updt_cnt+ 1), xm.updt_dt_tm = cnvtdatetime(sysdate),
       xm.updt_id = reqinfo->updt_id, xm.updt_task = reqinfo->updt_task, xm.updt_applctx = reqinfo->
       updt_applctx,
       xm.active_ind =
       IF ((request->productlist[prod].product_type="B")) 0
       ELSEIF ((as_qty=request->productlist[prod].transfused_qty)) 0
       ELSE 1
       ENDIF
       , xm.active_status_cd =
       IF ((request->productlist[prod].product_type="B")) reqdata->inactive_status_cd
       ELSEIF ((as_qty <= request->productlist[prod].transfused_qty)) reqdata->inactive_status_cd
       ELSE reqdata->active_status_cd
       ENDIF
      WHERE (xm.product_event_id=request->productlist[prod].xm_product_event_id)
       AND (xm.updt_cnt=request->productlist[prod].xm_updt_cnt)
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET failure_occured = "T"
      SET reply->status_data.subeventstatus[prod].operationname = "chg"
      SET reply->status_data.subeventstatus[prod].operationstatus = "F"
      SET error_process = "update crossmatch"
      SET error_message = "unable to update crossmatch table"
     ELSE
      UPDATE  FROM product_event pe
       SET pe.updt_cnt = (pe.updt_cnt+ 1), pe.updt_dt_tm = cnvtdatetime(sysdate), pe.updt_id =
        reqinfo->updt_id,
        pe.updt_task = reqinfo->updt_task, pe.updt_applctx = reqinfo->updt_applctx, pe.active_ind =
        IF ((request->productlist[prod].product_type="B")) 0
        ELSEIF ((as_qty <= request->productlist[prod].transfused_qty)) 0
        ELSE 1
        ENDIF
        ,
        pe.active_status_cd =
        IF ((request->productlist[prod].product_type="B")) reqdata->inactive_status_cd
        ELSEIF ((as_qty <= request->productlist[prod].transfused_qty)) reqdata->inactive_status_cd
        ELSE reqdata->active_status_cd
        ENDIF
       WHERE (pe.product_event_id=request->productlist[prod].xm_product_event_id)
        AND (pe.updt_cnt=request->productlist[prod].pe_xm_updt_cnt)
       WITH nocounter
      ;end update
      IF (curqual=0)
       SET failure_occured = "T"
       SET reply->status_data.subeventstatus[prod].operationname = "chg"
       SET reply->status_data.subeventstatus[prod].operationstatus = "F"
       SET error_process = "update crossmatch product event"
       SET error_message = "unable to update product event for xmatch"
      ENDIF
     ENDIF
    ELSE
     SET failure_occured = "T"
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[prod].operationname = "get"
     SET reply->status_data.subeventstatus[prod].operationstatus = "F"
     SET error_process = "get assign /crossmatch event"
     SET error_message = "unable to find assign or crossmatch event"
    ENDIF
   ENDIF
   IF (failure_occured="F"
    AND other_events="F")
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
     IF ((request->productlist[prod].from_interface_flag=0))
      SET error_process = "update product"
      SET error_message = "product not locked"
      SET failure_occured = "T"
     ENDIF
    ELSE
     UPDATE  FROM product p
      SET p.locked_ind = 0, p.interfaced_device_flag = 0, p.updt_cnt = (p.updt_cnt+ 1),
       p.updt_dt_tm = cnvtdatetime(sysdate), p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->
       updt_task,
       p.updt_applctx = reqinfo->updt_applctx
      PLAN (p
       WHERE (p.product_id=request->productlist[prod].product_id)
        AND (p.updt_cnt=request->productlist[prod].p_updt_cnt)
        AND p.locked_ind=1)
      WITH counter
     ;end update
     IF (curqual=0)
      IF ((request->productlist[prod].from_interface_flag=0))
       SET error_process = "update product"
       SET error_message = "product not unlocked"
       SET failure_occured = "T"
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   IF (failure_occured="F"
    AND (request->productlist[prod].from_interface_flag > 0))
    SET chg_event_transfuse_succss_cnt = success_cnt
    SET chg_event_transfuse_prod_cnt = prod
    SET reply->results[prod].product_id = request->productlist[prod].product_id
    SET reply->results[prod].status = "S"
    IF (flexupd_run(null)=0)
     SET flex_upd_error_flag = flex_upd_error
     SET failure_occured = "T"
     CALL log_message("flex update error",log_level_audit)
    ELSE
     SET stat = flexupd_printreports(null)
    ENDIF
    SET prod = chg_event_transfuse_prod_cnt
    SET success_cnt = chg_event_transfuse_succss_cnt
   ENDIF
   IF (failure_occured="F")
    SET success_cnt += 1
    SET reply->status_data.status = "S"
    SET reply->status_data.subeventstatus[prod].operationname = "Complete"
    SET reply->status_data.subeventstatus[prod].operationstatus = "S"
    SET reply->status_data.subeventstatus[prod].targetobjectname = "Tables Updated"
    SET reply->status_data.subeventstatus[prod].targetobjectvalue = "S"
    SET reply->results[prod].product_id = request->productlist[prod].product_id
    SET reply->results[prod].dispense_event_id = request->productlist[prod].pd_product_event_id
    SET reply->results[prod].status = "S"
    SET reply->results[prod].err_process = "complete"
    SET reply->results[prod].err_message = "no errors"
   ELSE
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
 IF ((reply->status_data.status != "F")
  AND success_cnt=nbr_to_add)
  SET g_sub_event_type_flag = 1
  SET g_sub_num_products = size(request->productlist,5)
  SET stat = insert_pn_recovery_data(0)
  IF (stat=1)
   SET reply->status_data.status = "S"
   SET reqinfo->commit_ind = 1
  ELSEIF (stat=2)
   SET reply->status_data.status = "S"
   SET reqinfo->commit_ind = 0
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
 ELSEIF (success_cnt < nbr_to_add)
  SET reply->status_data.status = "P"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 CALL log_message("---BBT_CHG_EVENT_TRANSFUSION ENDING",log_level_debug)
 CALL uar_sysdestroyhandle(hsys)
END GO
