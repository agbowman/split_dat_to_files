CREATE PROGRAM bb_upd_exceptions:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
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
 DECLARE next_pathnet_seq(pathnet_seq_dummy) = f8
 DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
 SUBROUTINE next_pathnet_seq(pathnet_seq_dummy)
   SET new_pathnet_seq = 0.0
   SELECT INTO "nl:"
    seqn = seq(pathnet_seq,nextval)
    FROM dual
    DETAIL
     new_pathnet_seq = seqn
    WITH format, nocounter
   ;end select
   RETURN(new_pathnet_seq)
 END ;Subroutine
 SUBROUTINE (updateedncomplete(ednid=f8(value),ednproductid=f8(value),productid=f8(value),
  edncompleteind=i2(value)) =i2)
   UPDATE  FROM bb_edn_product bep
    SET bep.product_complete_ind = 1, bep.product_id = productid, bep.updt_applctx = reqinfo->
     updt_applctx,
     bep.updt_dt_tm = cnvtdatetime(sysdate), bep.updt_id = reqinfo->updt_id, bep.updt_task = reqinfo
     ->updt_task,
     bep.person_id = 0.0
    WHERE bep.bb_edn_product_id=ednproductid
    WITH nocounter
   ;end update
   IF (curqual != 1)
    CALL log_message("Error updating BB_EDN_PRODUCT table.",log_level_error)
    RETURN(1)
   ENDIF
   IF (edncompleteind=1)
    UPDATE  FROM bb_edn_admin bea
     SET bea.edn_complete_ind = 1, bea.updt_applctx = reqinfo->updt_applctx, bea.updt_dt_tm =
      cnvtdatetime(sysdate),
      bea.updt_id = reqinfo->updt_id, bea.updt_task = reqinfo->updt_task
     WHERE bea.bb_edn_admin_id=ednid
    ;end update
    IF (curqual != 1)
     CALL log_message("Error updating BB_EDN_ADMIN table.",log_level_error)
     RETURN(1)
    ENDIF
   ENDIF
   RETURN(0)
 END ;Subroutine
 SET reply->status_data.status = "F"
 DECLARE script_name = c17 WITH constant("bb_upd_exceptions")
 DECLARE insert_ind = i2 WITH constant(1)
 DECLARE update_ind = i2 WITH constant(2)
 DECLARE exception_cs = i4 WITH constant(14072)
 DECLARE edn_missing_cdf = c11 WITH constant("EDN_MISSING")
 DECLARE override_reason_mean = c20 WITH project, noconstant("")
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE serrormsg = vc WITH protect, noconstant("")
 DECLARE errmsg = c132 WITH protect, noconstant(fillstring(132," "))
 DECLARE error_check = i2 WITH protect, noconstant(error(errmsg,1))
 DECLARE i_idx = i4 WITH protect, noconstant(0)
 DECLARE dexceptionid = f8 WITH protect, noconstant(0.0)
 FOR (i_idx = 1 TO size(request->exception_list,5))
  IF ((request->exception_list[i_idx].exception_type_cd=0.0))
   SET request->exception_list[i_idx].exception_type_cd = uar_get_code_by("MEANING",exception_cs,
    nullterm(request->exception_list[i_idx].exception_type_cdf))
   IF ((request->exception_list[i_idx].exception_type_cd <= 0.0))
    CALL errorhandler("F","uar_get_code_by",build("Unable to retrieve the exception type code value:",
      request->exception_list[i_idx].exception_type_cdf))
   ENDIF
  ENDIF
  IF ((request->exception_list[i_idx].save_flag=insert_ind))
   SET dexceptionid = next_pathnet_seq(0)
   INSERT  FROM bb_exception be
    SET be.active_ind = request->exception_list[i_idx].active_ind, be.active_status_cd = reqdata->
     active_status_cd, be.active_status_dt_tm = cnvtdatetime(sysdate),
     be.active_status_prsnl_id = reqinfo->updt_id, be.default_expire_dt_tm = cnvtdatetime(request->
      exception_list[i_idx].default_expire_dt_tm), be.donation_ident = request->exception_list[i_idx]
     .donation_ident,
     be.donor_contact_id = request->exception_list[i_idx].donor_contact_id, be.donor_contact_type_cd
      = request->exception_list[i_idx].donor_contact_type_cd, be.event_type_cd = request->
     exception_list[i_idx].event_type_cd,
     be.exception_dt_tm =
     IF (cnvtdatetime(request->exception_list[i_idx].exception_dt_tm)=0) cnvtdatetime(sysdate)
     ELSE cnvtdatetime(request->exception_list[i_idx].exception_dt_tm)
     ENDIF
     , be.exception_id = dexceptionid, be.exception_prsnl_id =
     IF ((request->exception_list[i_idx].exception_prsnl_id > 0.0)) request->exception_list[i_idx].
      exception_prsnl_id
     ELSE reqinfo->updt_id
     ENDIF
     ,
     be.exception_type_cd = request->exception_list[i_idx].exception_type_cd, be.from_abo_cd =
     request->exception_list[i_idx].from_abo_cd, be.from_rh_cd = request->exception_list[i_idx].
     from_rh_cd,
     be.ineligible_until_dt_tm = cnvtdatetime(request->exception_list[i_idx].ineligible_until_dt_tm),
     be.order_id = request->exception_list[i_idx].order_id, be.override_reason_cd = request->
     exception_list[i_idx].override_reason_cd,
     be.perform_result_id = request->exception_list[i_idx].perform_result_id, be.person_abo_cd =
     request->exception_list[i_idx].person_abo_cd, be.person_id = request->exception_list[i_idx].
     person_id,
     be.person_rh_cd = request->exception_list[i_idx].person_rh_cd, be.procedure_cd = request->
     exception_list[i_idx].procedure_cd, be.product_abo_cd = request->exception_list[i_idx].
     product_abo_cd,
     be.product_event_id = request->exception_list[i_idx].product_event_id, be.product_rh_cd =
     request->exception_list[i_idx].product_rh_cd, be.result_id = request->exception_list[i_idx].
     result_id,
     be.review_by_prsnl_id = request->exception_list[i_idx].review_by_prsnl_id, be.review_doc_id =
     request->exception_list[i_idx].review_doc_id, be.review_dt_tm = cnvtdatetime(request->
      exception_list[i_idx].review_dt_tm),
     be.review_status_cd = request->exception_list[i_idx].review_status_cd, be.to_abo_cd = request->
     exception_list[i_idx].to_abo_cd, be.to_rh_cd = request->exception_list[i_idx].to_rh_cd,
     be.updt_applctx = reqinfo->updt_applctx, be.updt_cnt = 0, be.updt_dt_tm = cnvtdatetime(sysdate),
     be.updt_id = reqinfo->updt_id, be.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   SET error_check = error(errmsg,0)
   IF (error_check != 0)
    CALL errorhandler("F","Insert BB_EXCEPTION",errmsg)
   ENDIF
   IF (validate(request->exception_list[i_idx].discrepancy.bb_edn_id) > 0.0)
    SET override_reason_mean = uar_get_code_meaning(request->exception_list[i_idx].discrepancy.
     override_reason_cd)
    IF (trim(override_reason_mean)=trim(edn_missing_cdf))
     SELECT INTO "nl:"
      next_seq_nbr = seq(pathnet_seq,nextval)
      FROM dual
      DETAIL
       request->exception_list[i_idx].discrepancy.bb_edn_product_id = next_seq_nbr
      WITH nocounter
     ;end select
     INSERT  FROM bb_edn_product bep
      SET bep.bb_edn_product_id = request->exception_list[i_idx].discrepancy.bb_edn_product_id, bep
       .bb_edn_admin_id = request->exception_list[i_idx].discrepancy.bb_edn_id, bep.product_id =
       request->exception_list[i_idx].discrepancy.product_id,
       bep.product_complete_ind = 1, bep.product_type_txt = request->exception_list[i_idx].
       discrepancy.edn_product_type_txt, bep.updt_applctx = reqinfo->updt_applctx,
       bep.updt_dt_tm = cnvtdatetime(sysdate), bep.updt_id = reqinfo->updt_id, bep.updt_task =
       reqinfo->updt_task,
       bep.updt_cnt = 0
     ;end insert
     SET error_check = error(errmsg,0)
     IF (error_check != 0)
      CALL errorhandler("F","Insert BB_EDN_PRODUCT",errmsg)
     ENDIF
    ENDIF
    INSERT  FROM bb_edn_dscrpncy_ovrd bedo
     SET bedo.bb_edn_dscrpncy_ovrd_id = seq(pathnet_seq,nextval), bedo.exception_id = dexceptionid,
      bedo.bb_edn_admin_id = request->exception_list[i_idx].discrepancy.bb_edn_id,
      bedo.bb_edn_product_id = request->exception_list[i_idx].discrepancy.bb_edn_product_id, bedo
      .product_id = request->exception_list[i_idx].discrepancy.product_id, bedo.edn_product_nbr_ident
       = request->exception_list[i_idx].discrepancy.edn_product_nbr,
      bedo.product_cd = request->exception_list[i_idx].discrepancy.product_cd, bedo.ovrd_reason_cd =
      request->exception_list[i_idx].discrepancy.override_reason_cd, bedo.updt_applctx = reqinfo->
      updt_applctx,
      bedo.updt_dt_tm = cnvtdatetime(sysdate), bedo.updt_id = reqinfo->updt_id, bedo.updt_task =
      reqinfo->updt_task
    ;end insert
    SET error_check = error(errmsg,0)
    IF (error_check != 0)
     CALL errorhandler("F","Insert BB_EDN_DSCRPNCY_OVRD",errmsg)
    ENDIF
    IF (updateedncomplete(request->exception_list[i_idx].discrepancy.bb_edn_id,request->
     exception_list[i_idx].discrepancy.bb_edn_product_id,request->exception_list[i_idx].discrepancy.
     product_id,request->exception_list[i_idx].discrepancy.edn_complete_ind)=1)
     SET error_check = error(serrormsg,0)
     IF (error_check != 0)
      CALL errorhandler("F","UpdateEDNComplete",errmsg)
     ENDIF
    ENDIF
   ENDIF
  ELSEIF ((request->exception_list[i_idx].save_flag=update_ind))
   SELECT INTO "nl:"
    FROM bb_exception be
    WHERE (be.exception_id=request->exception_list[i_idx].exception_id)
     AND (be.updt_cnt=request->exception_list[i_idx].updt_cnt)
    WITH nocounter, forupdate(be)
   ;end select
   IF (curqual=0)
    CALL errorhandler("F","Lock BB_EXCEPTION",build(
      "Unable to lock the BB_EXCEPTION row for update: ",request->exception_list[i_idx].exception_id)
     )
   ENDIF
   UPDATE  FROM bb_exception be
    SET be.active_ind = request->exception_list[i_idx].active_ind, be.active_status_cd =
     IF ((request->exception_list[i_idx].active_ind=1)) reqdata->active_status_cd
     ELSE reqdata->inactive_status_cd
     ENDIF
     , be.default_expire_dt_tm = cnvtdatetime(request->exception_list[i_idx].default_expire_dt_tm),
     be.donation_ident = request->exception_list[i_idx].donation_ident, be.donor_contact_id = request
     ->exception_list[i_idx].donor_contact_id, be.donor_contact_type_cd = request->exception_list[
     i_idx].donor_contact_type_cd,
     be.event_type_cd = request->exception_list[i_idx].event_type_cd, be.exception_dt_tm =
     cnvtdatetime(request->exception_list[i_idx].exception_dt_tm), be.exception_prsnl_id =
     IF ((request->exception_list[i_idx].exception_prsnl_id > 0.0)) request->exception_list[i_idx].
      exception_prsnl_id
     ELSE reqinfo->updt_id
     ENDIF
     ,
     be.exception_type_cd = request->exception_list[i_idx].exception_type_cd, be.from_abo_cd =
     request->exception_list[i_idx].from_abo_cd, be.from_rh_cd = request->exception_list[i_idx].
     from_rh_cd,
     be.ineligible_until_dt_tm = cnvtdatetime(request->exception_list[i_idx].ineligible_until_dt_tm),
     be.order_id = request->exception_list[i_idx].order_id, be.override_reason_cd = request->
     exception_list[i_idx].override_reason_cd,
     be.perform_result_id = request->exception_list[i_idx].perform_result_id, be.person_abo_cd =
     request->exception_list[i_idx].person_abo_cd, be.person_id = request->exception_list[i_idx].
     person_id,
     be.person_rh_cd = request->exception_list[i_idx].person_rh_cd, be.procedure_cd = request->
     exception_list[i_idx].procedure_cd, be.product_abo_cd = request->exception_list[i_idx].
     product_abo_cd,
     be.product_event_id = request->exception_list[i_idx].product_event_id, be.product_rh_cd =
     request->exception_list[i_idx].product_rh_cd, be.result_id = request->exception_list[i_idx].
     result_id,
     be.review_by_prsnl_id = request->exception_list[i_idx].review_by_prsnl_id, be.review_doc_id =
     request->exception_list[i_idx].review_doc_id, be.review_dt_tm = cnvtdatetime(request->
      exception_list[i_idx].review_dt_tm),
     be.review_status_cd = request->exception_list[i_idx].review_status_cd, be.to_abo_cd = request->
     exception_list[i_idx].to_abo_cd, be.to_rh_cd = request->exception_list[i_idx].to_rh_cd,
     be.updt_applctx = reqinfo->updt_applctx, be.updt_cnt = (be.updt_cnt+ 1), be.updt_dt_tm =
     cnvtdatetime(sysdate),
     be.updt_id = reqinfo->updt_id, be.updt_task = reqinfo->updt_task
    WHERE (be.exception_id=request->exception_list[i_idx].exception_id)
     AND (be.updt_cnt=request->exception_list[i_idx].updt_cnt)
    WITH nocounter
   ;end update
   SET error_check = error(errmsg,0)
   IF (error_check != 0)
    CALL errorhandler("F","Update BB_EXCEPTION",errmsg)
   ENDIF
  ENDIF
 ENDFOR
 GO TO set_status
 SUBROUTINE (errorhandler(operationstatus=c1,targetobjectname=vc,targetobjectvalue=vc) =null)
   DECLARE error_cnt = i2 WITH private, noconstant(0)
   SET error_cnt = size(reply->status_data.subeventstatus,5)
   IF (((error_cnt > 1) OR (error_cnt=1
    AND (reply->status_data.subeventstatus[error_cnt].operationstatus != ""))) )
    SET error_cnt += 1
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[error_cnt].operationname = script_name
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = operationstatus
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = targetobjectname
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = targetobjectvalue
   SET reqinfo->commit_ind = 0
   GO TO exit_script
 END ;Subroutine
#set_status
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#exit_script
END GO
