CREATE PROGRAM bbd_upd_lab_results:dba
 RECORD reply(
   1 event_dt_tm = dq8
   1 event_tz = i4
   1 orders[*]
     2 order_id = f8
     2 assays_cnt = i4
     2 assays[*]
       3 task_assay_cd = f8
       3 result_id = f8
       3 perform_dt_tm = dq8
       3 perform_tz = i4
       3 perform_result_id = f8
       3 parent_perform_result_id = f8
       3 updt_id = f8
       3 result_updt_cnt = i4
       3 perform_result_updt_cnt = i4
       3 order_cell_updt_cnt = i4
       3 result_key = f8
       3 perform_result_key = f8
       3 product_id = f8
       3 bb_result_id = f8
       3 result_status_cd = f8
       3 result_status_disp = vc
       3 result_status_mean = vc
       3 interp_data_id = f8
       3 cell_id = f8
       3 product_new_aborh_updt_cnt = i4
       3 product_new_abo_cd = f8
       3 product_new_abo_disp = c15
       3 product_new_abo_mean = c12
       3 product_new_rh_cd = f8
       3 product_new_rh_disp = c15
       3 product_new_rh_mean = c12
       3 new_abo_cd = f8
       3 new_abo_disp = c15
       3 new_abo_mean = c12
       3 new_rh_cd = f8
       3 new_rh_disp = c15
       3 new_rh_mean = c12
   1 opposite_found_person_id = f8
   1 opposite_found_product_id = f8
   1 opposite_found_order_id = f8
   1 opposite_found_assay_id = f8
   1 opposite_found_prfrm_rslt_key = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE subevent_add(op_name=vc(value),op_status=vc(value),obj_name=vc(value),obj_value=vc(value))
  = null WITH protect
 SUBROUTINE subevent_add(op_name,op_status,obj_name,obj_value)
   DECLARE se_itm = i4 WITH protect, noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
   SET se_itm = size(reply->status_data.subeventstatus,5)
   SET stat = alter(reply->status_data.subeventstatus,(se_itm+ 1))
   SET reply->status_data.subeventstatus[se_itm].operationname = cnvtupper(substring(1,25,trim(
      op_name)))
   SET reply->status_data.subeventstatus[se_itm].operationstatus = cnvtupper(substring(1,1,trim(
      op_status)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectname = cnvtupper(substring(1,25,trim(
      obj_name)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectvalue = obj_value
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
  DECLARE hsys = i4 WITH protect, noconstant(0)
  DECLARE sysstat = i4 WITH protect, noconstant(0)
  DECLARE serrmsg = c132 WITH protect, noconstant(" ")
  DECLARE ierrcode = i4 WITH protect, noconstant(error(serrmsg,1))
  DECLARE glbsl_msg_default = i4 WITH protect, noconstant(0)
  DECLARE glbsl_msg_level = i4 WITH protect, noconstant(0)
  EXECUTE msgrtl
  SET glbsl_msg_default = uar_msgdefhandle()
  SET glbsl_msg_level = uar_msggetlevel(glbsl_msg_default)
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
 DECLARE log_message(logmsg=vc,loglvl=i4) = null
 SUBROUTINE log_message(logmsg,loglvl)
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
 DECLARE error_message(logstatusblockind=i2) = i2
 SUBROUTINE error_message(logstatusblockind)
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
 DECLARE populate_subeventstatus(operationname=vc(value),operationstatus=vc(value),targetobjectname=
  vc(value),targetobjectvalue=vc(value)) = i2
 SUBROUTINE populate_subeventstatus(operationname,operationstatus,targetobjectname,targetobjectvalue)
   IF (validate(reply->status_data.status,"-1") != "-1")
    SET lglbslsubeventcnt = size(reply->status_data.subeventstatus,5)
    IF (lglbslsubeventcnt > 0)
     SET lglbslsubeventsize = size(trim(reply->status_data.subeventstatus[lglbslsubeventcnt].
       operationname))
     SET lglbslsubeventsize = (lglbslsubeventsize+ size(trim(reply->status_data.subeventstatus[
       lglbslsubeventcnt].operationstatus)))
     SET lglbslsubeventsize = (lglbslsubeventsize+ size(trim(reply->status_data.subeventstatus[
       lglbslsubeventcnt].targetobjectname)))
     SET lglbslsubeventsize = (lglbslsubeventsize+ size(trim(reply->status_data.subeventstatus[
       lglbslsubeventcnt].targetobjectvalue)))
    ELSE
     SET lglbslsubeventsize = 1
    ENDIF
    IF (lglbslsubeventsize > 0)
     SET lglbslsubeventcnt = (lglbslsubeventcnt+ 1)
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
 DECLARE populate_subeventstatus_msg(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value),loglevel=i2(value)) = i2
 SUBROUTINE populate_subeventstatus_msg(operationname,operationstatus,targetobjectname,
  targetobjectvalue,loglevel)
  CALL populate_subeventstatus(operationname,operationstatus,targetobjectname,targetobjectvalue)
  CALL log_message(targetobjectvalue,loglevel)
 END ;Subroutine
 DECLARE check_log_level(arg_log_level=i4) = i2
 SUBROUTINE check_log_level(arg_log_level)
   IF (((glbsl_msg_level >= arg_log_level) OR (log_override_ind=1)) )
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SET log_program_name = "bbd_upd_lab_results"
 RECORD rh_a_rec(
   1 antigenlist[*]
     2 antigen_cd = f8
     2 post_to_donor_ind = i2
     2 opposite_cd = f8
 )
 RECORD current(
   1 system_dt_tm = dq8
 )
 RECORD modproductlist(
   1 product[*]
     2 product_id = f8
     2 product_nbr = vc
     2 lock_ind = i2
     2 bp_updt_cnt = i2
     2 drawn_event_id = f8
     2 drawn_updt_cnt = i2
     2 tested_event_id = f8
     2 tested_updt_cnt = i2
     2 quarantined_event_id = f8
     2 quarantined_updt_cnt = i2
     2 biohazard_ind = i2
     2 donation_type_mean = c12
 )
 RECORD review_maintain_rep(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 EXECUTE gm_donor_aborh7810_def "I"
 DECLARE gm_i_donor_aborh7810_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) = i2
 DECLARE gm_i_donor_aborh7810_dq8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) = i2
 DECLARE gm_i_donor_aborh7810_i2(icol_name=vc,ival=i2,iqual=i4,null_ind=i2) = i2
 SUBROUTINE gm_i_donor_aborh7810_f8(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_donor_aborh7810_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_donor_aborh7810_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "person_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_donor_aborh7810_req->qual[iqual].person_id = ival
     SET gm_i_donor_aborh7810_req->person_idi = 1
    OF "abo_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_donor_aborh7810_req->qual[iqual].abo_cd = ival
     SET gm_i_donor_aborh7810_req->abo_cdi = 1
    OF "rh_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_donor_aborh7810_req->qual[iqual].rh_cd = ival
     SET gm_i_donor_aborh7810_req->rh_cdi = 1
    OF "contributor_system_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_donor_aborh7810_req->qual[iqual].contributor_system_cd = ival
     SET gm_i_donor_aborh7810_req->contributor_system_cdi = 1
    OF "active_status_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_donor_aborh7810_req->qual[iqual].active_status_cd = ival
     SET gm_i_donor_aborh7810_req->active_status_cdi = 1
    OF "active_status_prsnl_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_donor_aborh7810_req->qual[iqual].active_status_prsnl_id = ival
     SET gm_i_donor_aborh7810_req->active_status_prsnl_idi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_i_donor_aborh7810_i2(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_donor_aborh7810_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_donor_aborh7810_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "active_ind":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_donor_aborh7810_req->qual[iqual].active_ind = ival
     SET gm_i_donor_aborh7810_req->active_indi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_i_donor_aborh7810_dq8(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_donor_aborh7810_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_donor_aborh7810_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "verified_dt_tm":
     SET gm_i_donor_aborh7810_req->qual[iqual].verified_dt_tm = cnvtdatetime(ival)
     SET gm_i_donor_aborh7810_req->verified_dt_tmi = 1
    OF "active_status_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_donor_aborh7810_req->qual[iqual].active_status_dt_tm = cnvtdatetime(ival)
     SET gm_i_donor_aborh7810_req->active_status_dt_tmi = 1
    OF "updt_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_donor_aborh7810_req->qual[iqual].updt_dt_tm = cnvtdatetime(ival)
     SET gm_i_donor_aborh7810_req->updt_dt_tmi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 EXECUTE gm_donor_aborh7810_def "U"
 DECLARE gm_u_donor_aborh7810_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_donor_aborh7810_dq8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_donor_aborh7810_i2(icol_name=vc,ival=i2,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_donor_aborh7810_i4(icol_name=vc,ival=i4,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 SUBROUTINE gm_u_donor_aborh7810_f8(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_donor_aborh7810_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_donor_aborh7810_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "donor_aborh_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_donor_aborh7810_req->donor_aborh_idf = 1
     SET gm_u_donor_aborh7810_req->qual[iqual].donor_aborh_id = ival
     IF (wq_ind=1)
      SET gm_u_donor_aborh7810_req->donor_aborh_idw = 1
     ENDIF
    OF "person_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_donor_aborh7810_req->person_idf = 1
     SET gm_u_donor_aborh7810_req->qual[iqual].person_id = ival
     IF (wq_ind=1)
      SET gm_u_donor_aborh7810_req->person_idw = 1
     ENDIF
    OF "abo_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_donor_aborh7810_req->abo_cdf = 1
     SET gm_u_donor_aborh7810_req->qual[iqual].abo_cd = ival
     IF (wq_ind=1)
      SET gm_u_donor_aborh7810_req->abo_cdw = 1
     ENDIF
    OF "rh_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_donor_aborh7810_req->rh_cdf = 1
     SET gm_u_donor_aborh7810_req->qual[iqual].rh_cd = ival
     IF (wq_ind=1)
      SET gm_u_donor_aborh7810_req->rh_cdw = 1
     ENDIF
    OF "contributor_system_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_donor_aborh7810_req->contributor_system_cdf = 1
     SET gm_u_donor_aborh7810_req->qual[iqual].contributor_system_cd = ival
     IF (wq_ind=1)
      SET gm_u_donor_aborh7810_req->contributor_system_cdw = 1
     ENDIF
    OF "active_status_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_donor_aborh7810_req->active_status_cdf = 1
     SET gm_u_donor_aborh7810_req->qual[iqual].active_status_cd = ival
     IF (wq_ind=1)
      SET gm_u_donor_aborh7810_req->active_status_cdw = 1
     ENDIF
    OF "active_status_prsnl_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_donor_aborh7810_req->active_status_prsnl_idf = 1
     SET gm_u_donor_aborh7810_req->qual[iqual].active_status_prsnl_id = ival
     IF (wq_ind=1)
      SET gm_u_donor_aborh7810_req->active_status_prsnl_idw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_u_donor_aborh7810_i2(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_donor_aborh7810_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_donor_aborh7810_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "active_ind":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_donor_aborh7810_req->active_indf = 1
     SET gm_u_donor_aborh7810_req->qual[iqual].active_ind = ival
     IF (wq_ind=1)
      SET gm_u_donor_aborh7810_req->active_indw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_u_donor_aborh7810_i4(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_donor_aborh7810_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_donor_aborh7810_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "updt_cnt":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_donor_aborh7810_req->updt_cntf = 1
     SET gm_u_donor_aborh7810_req->qual[iqual].updt_cnt = ival
     IF (wq_ind=1)
      SET gm_u_donor_aborh7810_req->updt_cntw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_u_donor_aborh7810_dq8(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_donor_aborh7810_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_donor_aborh7810_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "verified_dt_tm":
     IF (null_ind=1)
      SET gm_u_donor_aborh7810_req->verified_dt_tmf = 2
     ELSE
      SET gm_u_donor_aborh7810_req->verified_dt_tmf = 1
     ENDIF
     SET gm_u_donor_aborh7810_req->qual[iqual].verified_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_donor_aborh7810_req->verified_dt_tmw = 1
     ENDIF
    OF "active_status_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_donor_aborh7810_req->active_status_dt_tmf = 1
     SET gm_u_donor_aborh7810_req->qual[iqual].active_status_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_donor_aborh7810_req->active_status_dt_tmw = 1
     ENDIF
    OF "updt_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_donor_aborh7810_req->updt_dt_tmf = 1
     SET gm_u_donor_aborh7810_req->qual[iqual].updt_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_donor_aborh7810_req->updt_dt_tmw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 EXECUTE gm_person_aborh_r0793_def "I"
 DECLARE gm_i_person_aborh_r0793_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) = i2
 DECLARE gm_i_person_aborh_r0793_i2(icol_name=vc,ival=i2,iqual=i4,null_ind=i2) = i2
 DECLARE gm_i_person_aborh_r0793_dq8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) = i2
 SUBROUTINE gm_i_person_aborh_r0793_f8(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_person_aborh_r0793_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_person_aborh_r0793_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "person_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_person_aborh_r0793_req->qual[iqual].person_id = ival
     SET gm_i_person_aborh_r0793_req->person_idi = 1
    OF "encntr_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_person_aborh_r0793_req->qual[iqual].encntr_id = ival
     SET gm_i_person_aborh_r0793_req->encntr_idi = 1
    OF "result_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_person_aborh_r0793_req->qual[iqual].result_id = ival
     SET gm_i_person_aborh_r0793_req->result_idi = 1
    OF "result_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_person_aborh_r0793_req->qual[iqual].result_cd = ival
     SET gm_i_person_aborh_r0793_req->result_cdi = 1
    OF "active_status_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_person_aborh_r0793_req->qual[iqual].active_status_cd = ival
     SET gm_i_person_aborh_r0793_req->active_status_cdi = 1
    OF "active_status_prsnl_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_person_aborh_r0793_req->qual[iqual].active_status_prsnl_id = ival
     SET gm_i_person_aborh_r0793_req->active_status_prsnl_idi = 1
    OF "contributor_system_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_person_aborh_r0793_req->qual[iqual].contributor_system_cd = ival
     SET gm_i_person_aborh_r0793_req->contributor_system_cdi = 1
    OF "container_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_person_aborh_r0793_req->qual[iqual].container_id = ival
     SET gm_i_person_aborh_r0793_req->container_idi = 1
    OF "person_aborh_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_person_aborh_r0793_req->qual[iqual].person_aborh_id = ival
     SET gm_i_person_aborh_r0793_req->person_aborh_idi = 1
    OF "specimen_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_person_aborh_r0793_req->qual[iqual].specimen_id = ival
     SET gm_i_person_aborh_r0793_req->specimen_idi = 1
    OF "donor_aborh_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_person_aborh_r0793_req->qual[iqual].donor_aborh_id = ival
     SET gm_i_person_aborh_r0793_req->donor_aborh_idi = 1
    OF "standard_aborh_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_person_aborh_r0793_req->qual[iqual].standard_aborh_cd = ival
     SET gm_i_person_aborh_r0793_req->standard_aborh_cdi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_i_person_aborh_r0793_i2(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_person_aborh_r0793_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_person_aborh_r0793_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "active_ind":
     SET gm_i_person_aborh_r0793_req->qual[iqual].active_ind = ival
     SET gm_i_person_aborh_r0793_req->active_indi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_i_person_aborh_r0793_dq8(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_person_aborh_r0793_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_person_aborh_r0793_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "active_status_dt_tm":
     SET gm_i_person_aborh_r0793_req->qual[iqual].active_status_dt_tm = cnvtdatetime(ival)
     SET gm_i_person_aborh_r0793_req->active_status_dt_tmi = 1
    OF "updt_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_person_aborh_r0793_req->qual[iqual].updt_dt_tm = cnvtdatetime(ival)
     SET gm_i_person_aborh_r0793_req->updt_dt_tmi = 1
    OF "drawn_dt_tm":
     SET gm_i_person_aborh_r0793_req->qual[iqual].drawn_dt_tm = cnvtdatetime(ival)
     SET gm_i_person_aborh_r0793_req->drawn_dt_tmi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 EXECUTE gm_donor_antibo7811_def "I"
 DECLARE gm_i_donor_antibo7811_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) = i2
 DECLARE gm_i_donor_antibo7811_i4(icol_name=vc,ival=i4,iqual=i4,null_ind=i2) = i2
 DECLARE gm_i_donor_antibo7811_i2(icol_name=vc,ival=i2,iqual=i4,null_ind=i2) = i2
 DECLARE gm_i_donor_antibo7811_dq8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) = i2
 SUBROUTINE gm_i_donor_antibo7811_f8(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_donor_antibo7811_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_donor_antibo7811_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "encntr_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_donor_antibo7811_req->qual[iqual].encntr_id = ival
     SET gm_i_donor_antibo7811_req->encntr_idi = 1
    OF "antibody_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_donor_antibo7811_req->qual[iqual].antibody_cd = ival
     SET gm_i_donor_antibo7811_req->antibody_cdi = 1
    OF "result_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_donor_antibo7811_req->qual[iqual].result_id = ival
     SET gm_i_donor_antibo7811_req->result_idi = 1
    OF "contributor_system_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_donor_antibo7811_req->qual[iqual].contributor_system_cd = ival
     SET gm_i_donor_antibo7811_req->contributor_system_cdi = 1
    OF "active_status_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_donor_antibo7811_req->qual[iqual].active_status_cd = ival
     SET gm_i_donor_antibo7811_req->active_status_cdi = 1
    OF "active_status_prsnl_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_donor_antibo7811_req->qual[iqual].active_status_prsnl_id = ival
     SET gm_i_donor_antibo7811_req->active_status_prsnl_idi = 1
    OF "person_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_donor_antibo7811_req->qual[iqual].person_id = ival
     SET gm_i_donor_antibo7811_req->person_idi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_i_donor_antibo7811_i2(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_donor_antibo7811_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_donor_antibo7811_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "active_ind":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_donor_antibo7811_req->qual[iqual].active_ind = ival
     SET gm_i_donor_antibo7811_req->active_indi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_i_donor_antibo7811_i4(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_donor_antibo7811_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_donor_antibo7811_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "bb_result_nbr":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_donor_antibo7811_req->qual[iqual].bb_result_nbr = ival
     SET gm_i_donor_antibo7811_req->bb_result_nbri = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_i_donor_antibo7811_dq8(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_donor_antibo7811_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_donor_antibo7811_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "active_status_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_donor_antibo7811_req->qual[iqual].active_status_dt_tm = cnvtdatetime(ival)
     SET gm_i_donor_antibo7811_req->active_status_dt_tmi = 1
    OF "updt_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_donor_antibo7811_req->qual[iqual].updt_dt_tm = cnvtdatetime(ival)
     SET gm_i_donor_antibo7811_req->updt_dt_tmi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 EXECUTE gm_donor_antige7812_def "I"
 DECLARE gm_i_donor_antige7812_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) = i2
 DECLARE gm_i_donor_antige7812_i4(icol_name=vc,ival=i4,iqual=i4,null_ind=i2) = i2
 DECLARE gm_i_donor_antige7812_i2(icol_name=vc,ival=i2,iqual=i4,null_ind=i2) = i2
 DECLARE gm_i_donor_antige7812_dq8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) = i2
 SUBROUTINE gm_i_donor_antige7812_f8(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_donor_antige7812_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_donor_antige7812_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "encntr_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_donor_antige7812_req->qual[iqual].encntr_id = ival
     SET gm_i_donor_antige7812_req->encntr_idi = 1
    OF "antigen_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_donor_antige7812_req->qual[iqual].antigen_cd = ival
     SET gm_i_donor_antige7812_req->antigen_cdi = 1
    OF "result_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_donor_antige7812_req->qual[iqual].result_id = ival
     SET gm_i_donor_antige7812_req->result_idi = 1
    OF "contributor_system_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_donor_antige7812_req->qual[iqual].contributor_system_cd = ival
     SET gm_i_donor_antige7812_req->contributor_system_cdi = 1
    OF "donor_rh_phenotype_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_donor_antige7812_req->qual[iqual].donor_rh_phenotype_id = ival
     SET gm_i_donor_antige7812_req->donor_rh_phenotype_idi = 1
    OF "active_status_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_donor_antige7812_req->qual[iqual].active_status_cd = ival
     SET gm_i_donor_antige7812_req->active_status_cdi = 1
    OF "active_status_prsnl_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_donor_antige7812_req->qual[iqual].active_status_prsnl_id = ival
     SET gm_i_donor_antige7812_req->active_status_prsnl_idi = 1
    OF "person_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_donor_antige7812_req->qual[iqual].person_id = ival
     SET gm_i_donor_antige7812_req->person_idi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_i_donor_antige7812_i2(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_donor_antige7812_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_donor_antige7812_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "active_ind":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_donor_antige7812_req->qual[iqual].active_ind = ival
     SET gm_i_donor_antige7812_req->active_indi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_i_donor_antige7812_i4(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_donor_antige7812_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_donor_antige7812_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "bb_result_nbr":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_donor_antige7812_req->qual[iqual].bb_result_nbr = ival
     SET gm_i_donor_antige7812_req->bb_result_nbri = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_i_donor_antige7812_dq8(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_donor_antige7812_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_donor_antige7812_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "active_status_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_donor_antige7812_req->qual[iqual].active_status_dt_tm = cnvtdatetime(ival)
     SET gm_i_donor_antige7812_req->active_status_dt_tmi = 1
    OF "updt_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_donor_antige7812_req->qual[iqual].updt_dt_tm = cnvtdatetime(ival)
     SET gm_i_donor_antige7812_req->updt_dt_tmi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 EXECUTE gm_donor_antige7812_def "U"
 DECLARE gm_u_donor_antige7812_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_donor_antige7812_i4(icol_name=vc,ival=i4,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_donor_antige7812_i2(icol_name=vc,ival=i2,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_donor_antige7812_dq8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 SUBROUTINE gm_u_donor_antige7812_f8(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_donor_antige7812_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_donor_antige7812_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "donor_antigen_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_donor_antige7812_req->donor_antigen_idf = 1
     SET gm_u_donor_antige7812_req->qual[iqual].donor_antigen_id = ival
     IF (wq_ind=1)
      SET gm_u_donor_antige7812_req->donor_antigen_idw = 1
     ENDIF
    OF "encntr_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_donor_antige7812_req->encntr_idf = 1
     SET gm_u_donor_antige7812_req->qual[iqual].encntr_id = ival
     IF (wq_ind=1)
      SET gm_u_donor_antige7812_req->encntr_idw = 1
     ENDIF
    OF "antigen_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_donor_antige7812_req->antigen_cdf = 1
     SET gm_u_donor_antige7812_req->qual[iqual].antigen_cd = ival
     IF (wq_ind=1)
      SET gm_u_donor_antige7812_req->antigen_cdw = 1
     ENDIF
    OF "result_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_donor_antige7812_req->result_idf = 1
     SET gm_u_donor_antige7812_req->qual[iqual].result_id = ival
     IF (wq_ind=1)
      SET gm_u_donor_antige7812_req->result_idw = 1
     ENDIF
    OF "contributor_system_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_donor_antige7812_req->contributor_system_cdf = 1
     SET gm_u_donor_antige7812_req->qual[iqual].contributor_system_cd = ival
     IF (wq_ind=1)
      SET gm_u_donor_antige7812_req->contributor_system_cdw = 1
     ENDIF
    OF "donor_rh_phenotype_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_donor_antige7812_req->donor_rh_phenotype_idf = 1
     SET gm_u_donor_antige7812_req->qual[iqual].donor_rh_phenotype_id = ival
     IF (wq_ind=1)
      SET gm_u_donor_antige7812_req->donor_rh_phenotype_idw = 1
     ENDIF
    OF "active_status_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_donor_antige7812_req->active_status_cdf = 1
     SET gm_u_donor_antige7812_req->qual[iqual].active_status_cd = ival
     IF (wq_ind=1)
      SET gm_u_donor_antige7812_req->active_status_cdw = 1
     ENDIF
    OF "active_status_prsnl_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_donor_antige7812_req->active_status_prsnl_idf = 1
     SET gm_u_donor_antige7812_req->qual[iqual].active_status_prsnl_id = ival
     IF (wq_ind=1)
      SET gm_u_donor_antige7812_req->active_status_prsnl_idw = 1
     ENDIF
    OF "person_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_donor_antige7812_req->person_idf = 1
     SET gm_u_donor_antige7812_req->qual[iqual].person_id = ival
     IF (wq_ind=1)
      SET gm_u_donor_antige7812_req->person_idw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_u_donor_antige7812_i2(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_donor_antige7812_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_donor_antige7812_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "active_ind":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_donor_antige7812_req->active_indf = 1
     SET gm_u_donor_antige7812_req->qual[iqual].active_ind = ival
     IF (wq_ind=1)
      SET gm_u_donor_antige7812_req->active_indw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_u_donor_antige7812_i4(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_donor_antige7812_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_donor_antige7812_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "bb_result_nbr":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_donor_antige7812_req->bb_result_nbrf = 1
     SET gm_u_donor_antige7812_req->qual[iqual].bb_result_nbr = ival
     IF (wq_ind=1)
      SET gm_u_donor_antige7812_req->bb_result_nbrw = 1
     ENDIF
    OF "updt_cnt":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_donor_antige7812_req->updt_cntf = 1
     SET gm_u_donor_antige7812_req->qual[iqual].updt_cnt = ival
     IF (wq_ind=1)
      SET gm_u_donor_antige7812_req->updt_cntw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_u_donor_antige7812_dq8(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_donor_antige7812_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_donor_antige7812_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "active_status_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_donor_antige7812_req->active_status_dt_tmf = 1
     SET gm_u_donor_antige7812_req->qual[iqual].active_status_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_donor_antige7812_req->active_status_dt_tmw = 1
     ENDIF
    OF "updt_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_donor_antige7812_req->updt_dt_tmf = 1
     SET gm_u_donor_antige7812_req->qual[iqual].updt_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_donor_antige7812_req->updt_dt_tmw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SET gm_i_donor_aborh7810_req->allow_partial_ind = 0
 SET gm_i_donor_aborh7810_req->person_idi = 1
 SET gm_i_donor_aborh7810_req->abo_cdi = 1
 SET gm_i_donor_aborh7810_req->rh_cdi = 1
 SET gm_i_donor_aborh7810_req->active_indi = 1
 SET gm_i_donor_aborh7810_req->active_status_cdi = 1
 SET gm_i_donor_aborh7810_req->active_status_dt_tmi = 1
 SET gm_i_donor_aborh7810_req->active_status_prsnl_idi = 1
 SET gm_i_donor_aborh7810_req->contributor_system_cdi = 1
 SET gm_i_donor_aborh7810_req->verified_dt_tmi = 1
 DECLARE add_donor_aborh(sub_person_id=f8,sub_abo_cd=f8,sub_rh_cd=f8,sub_active_ind=i2,
  sub_active_status_cd=f8,
  sub_active_status_dt_tm=f8,sub_active_status_prsnl_id=f8,sub_verified_dt_tm=f8,
  sub_contributor_system_cd=f8,sub_donor_aborh_id=f8(ref)) = i2
 SUBROUTINE add_donor_aborh(sub_person_id,sub_abo_cd,sub_rh_cd,sub_active_ind,sub_active_status_cd,
  sub_active_status_dt_tm,sub_active_status_prsnl_id,sub_verified_dt_tm,sub_contributor_system_cd,
  sub_donor_aborh_id)
   SET stat = alterlist(gm_i_donor_aborh7810_req->qual,1)
   SET gm_i_donor_aborh7810_req->qual[1].person_id = sub_person_id
   SET gm_i_donor_aborh7810_req->qual[1].abo_cd = sub_abo_cd
   SET gm_i_donor_aborh7810_req->qual[1].rh_cd = sub_rh_cd
   SET gm_i_donor_aborh7810_req->qual[1].active_ind = sub_active_ind
   SET gm_i_donor_aborh7810_req->qual[1].active_status_cd = sub_active_status_cd
   SET gm_i_donor_aborh7810_req->qual[1].active_status_dt_tm = cnvtdatetime(sub_active_status_dt_tm)
   SET gm_i_donor_aborh7810_req->qual[1].active_status_prsnl_id = sub_active_status_prsnl_id
   SET gm_i_donor_aborh7810_req->qual[1].verified_dt_tm = cnvtdatetime(sub_verified_dt_tm)
   SET gm_i_donor_aborh7810_req->qual[1].contributor_system_cd = sub_contributor_system_cd
   EXECUTE gm_i_donor_aborh7810  WITH replace(request,gm_i_donor_aborh7810_req), replace(reply,
    gm_i_donor_aborh7810_rep)
   IF ((gm_i_donor_aborh7810_rep->status_data.status="F"))
    CALL echo("Insert into donor_aborh table failed.")
    RETURN(0)
   ELSEIF ((gm_i_donor_aborh7810_rep->status_data.status="S"))
    CALL echo("Insert into donor_aborh table success.")
    SET stat = alterlist(gm_i_donor_aborh7810_rep->qual,1)
    SET sub_donor_aborh_id = gm_i_donor_aborh7810_rep->qual[1].donor_aborh_id
    IF (sub_donor_aborh_id=0)
     RETURN(2)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SET gm_u_donor_aborh7810_req->allow_partial_ind = 0
 SET gm_u_donor_aborh7810_req->force_updt_ind = 0
 SET gm_u_donor_aborh7810_req->donor_aborh_idw = 1
 SET gm_u_donor_aborh7810_req->active_indf = 1
 SET gm_u_donor_aborh7810_req->active_status_cdf = 1
 DECLARE chg_donor_aborh(sub_person_id=f8,sub_abo_cd=f8,sub_rh_cd=f8,sub_active_ind=i2,
  sub_active_status_cd=f8,
  sub_updt_cnt=i4) = i2
 SUBROUTINE chg_donor_aborh(sub_person_id,sub_abo_cd,sub_rh_cd,sub_active_ind,sub_active_status_cd,
  sub_updt_cnt)
   SET stat = alterlist(gm_u_donor_aborh7810_req->qual,1)
   IF (stat=0)
    CALL echo("can not size request structure")
    RETURN(0)
   ENDIF
   SELECT INTO "nl:"
    FROM donor_aborh da
    WHERE da.person_id=sub_person_id
     AND ((da.abo_cd+ 0)=sub_abo_cd)
     AND ((da.rh_cd+ 0)=sub_rh_cd)
     AND da.active_ind=1
     AND da.updt_cnt=sub_updt_cnt
    DETAIL
     gm_u_donor_aborh7810_req->qual[1].donor_aborh_id = da.donor_aborh_id, gm_u_donor_aborh7810_req->
     qual[1].updt_cnt = da.updt_cnt
    WITH nocounter
   ;end select
   IF (curqual=0)
    RETURN(2)
   ENDIF
   SET gm_u_donor_aborh7810_req->qual[1].active_ind = sub_active_ind
   SET gm_u_donor_aborh7810_req->qual[1].active_status_cd = sub_active_status_cd
   EXECUTE gm_u_donor_aborh7810  WITH replace(request,gm_u_donor_aborh7810_req), replace(reply,
    gm_u_donor_aborh7810_rep)
   IF ((gm_u_donor_aborh7810_rep->status_data.status="F"))
    CALL echo("Update donor_aborh table failed.")
    RETURN(0)
   ELSEIF ((gm_u_donor_aborh7810_rep->status_data.status="S"))
    CALL echo("Update donor_aborh table success.")
   ENDIF
   RETURN(1)
 END ;Subroutine
 DECLARE add_donor_aborh_result(sub_specimen_id=f8,sub_container_id=f8,sub_drawn_dt_tm=f8,
  sub_person_aborh_id=f8,sub_person_id=f8,
  sub_encntr_id=f8,sub_result_id=f8,sub_result_cd=f8,sub_active_ind=i2,sub_active_status_cd=f8,
  sub_active_status_dt_tm=f8,sub_active_status_prsnl_id=f8,sub_contributor_system_cd=f8,
  sub_donor_aborh_id=f8) = i2
 SUBROUTINE add_donor_aborh_result(sub_specimen_id,sub_container_id,sub_drawn_dt_tm,
  sub_person_aborh_id,sub_person_id,sub_encntr_id,sub_result_id,sub_result_cd,sub_active_ind,
  sub_active_status_cd,sub_active_status_dt_tm,sub_active_status_prsnl_id,sub_contributor_system_cd,
  sub_donor_aborh_id)
   DECLARE person_aborh_rs_id = f8 WITH protect, private, noconstant(0.0)
   DECLARE result_codeset = i4 WITH protect, noconstant(0)
   DECLARE standard_aborh_cd = f8 WITH protect, noconstant(0.0)
   DECLARE lstandardaborhcodeset = i4 WITH protect, constant(1640)
   DECLARE lresultaborhcodeset = i4 WITH protect, constant(1643)
   DECLARE caborh_cd = c8 WITH protect, constant("ABORH_cd")
   DECLARE specimen_id_text = c11 WITH protect, constant("specimen_id")
   DECLARE container_id_text = c12 WITH protect, constant("container_id")
   DECLARE drawn_dt_tm_text = c11 WITH protect, constant("drawn_dt_tm")
   DECLARE person_aborh_id_text = c15 WITH protect, constant("person_aborh_id")
   DECLARE person_id_text = c9 WITH protect, constant("person_id")
   DECLARE encntr_id_text = c9 WITH protect, constant("encntr_id")
   DECLARE result_id_text = c9 WITH protect, constant("result_id")
   DECLARE result_cd_text = c9 WITH protect, constant("result_cd")
   DECLARE active_ind_text = c10 WITH protect, constant("active_ind")
   DECLARE active_status_cd_text = c16 WITH protect, constant("active_status_cd")
   DECLARE active_status_dt_tm_text = c19 WITH protect, constant("active_status_dt_tm")
   DECLARE active_status_prsnl_id_text = c22 WITH protect, constant("active_status_prsnl_id")
   DECLARE donor_aborh_id_text = c14 WITH protect, constant("donor_aborh_id")
   DECLARE standard_aborh_cd_text = c17 WITH protect, constant("standard_aborh_cd")
   DECLARE sub_contributor_system_cd_text = c25 WITH protect, constant("sub_contributor_system_cd")
   SET result_codeset = uar_get_code_set(sub_result_cd)
   IF (result_codeset=lstandardaborhcodeset)
    SET standard_aborh_cd = sub_result_cd
   ELSE
    SELECT INTO "nl:"
     cve.code_value, cve.field_name, cve.field_value
     FROM code_value_extension cve
     WHERE cve.code_value=sub_result_cd
      AND cve.field_name=caborh_cd
     DETAIL
      standard_aborh_cd = cnvtreal(trim(cve.field_value))
     WITH nocounter
    ;end select
   ENDIF
   SET result_codeset = uar_get_code_set(standard_aborh_cd)
   IF (result_codeset=lstandardaborhcodeset)
    CALL gm_i_person_aborh_r0793_f8(specimen_id_text,sub_specimen_id,1,0)
    CALL gm_i_person_aborh_r0793_f8(container_id_text,sub_container_id,1,0)
    CALL gm_i_person_aborh_r0793_dq8(drawn_dt_tm_text,sub_drawn_dt_tm,1,0)
    CALL gm_i_person_aborh_r0793_f8(person_aborh_id_text,sub_person_aborh_id,1,0)
    CALL gm_i_person_aborh_r0793_f8(person_id_text,sub_person_id,1,0)
    CALL gm_i_person_aborh_r0793_f8(encntr_id_text,sub_encntr_id,1,0)
    CALL gm_i_person_aborh_r0793_f8(result_id_text,sub_result_id,1,0)
    CALL gm_i_person_aborh_r0793_f8(result_cd_text,sub_result_cd,1,0)
    CALL gm_i_person_aborh_r0793_i2(active_ind_text,sub_active_ind,1,0)
    CALL gm_i_person_aborh_r0793_f8(active_status_cd_text,sub_active_status_cd,1,0)
    CALL gm_i_person_aborh_r0793_dq8(active_status_dt_tm_text,sub_active_status_dt_tm,1,0)
    CALL gm_i_person_aborh_r0793_f8(active_status_prsnl_id_text,sub_active_status_prsnl_id,1,0)
    CALL gm_i_person_aborh_r0793_f8(donor_aborh_id_text,sub_donor_aborh_id,1,0)
    CALL gm_i_person_aborh_r0793_f8(sub_contributor_system_cd_text,sub_contributor_system_cd,1,0)
    CALL gm_i_person_aborh_r0793_f8(standard_aborh_cd_text,standard_aborh_cd,1,0)
    EXECUTE gm_i_person_aborh_r0793  WITH replace(request,gm_i_person_aborh_r0793_req), replace(reply,
     gm_i_person_aborh_r0793_rep)
    IF ((gm_i_person_aborh_r0793_rep->status_data.status="F"))
     CALL echo("Insert into person_aborh_result table failed.")
     RETURN(0)
    ELSEIF ((gm_i_person_aborh_r0793_rep->status_data.status="S"))
     CALL echo("Insert into person_aborh_result table success.")
     SET stat = alterlist(gm_i_person_aborh_r0793_rep->qual,1)
     SET person_aborh_rs_id = gm_i_person_aborh_r0793_rep->qual[1].person_aborh_rs_id
     IF (person_aborh_rs_id=0)
      RETURN(2)
     ENDIF
    ENDIF
    RETURN(1)
   ELSE
    CALL echo("Result_cd's corresponding Standard_ABORH_CD not found on code set 1640")
    RETURN(0)
   ENDIF
 END ;Subroutine
 SET gm_i_donor_antibo7811_req->allow_partial_ind = 0
 SET gm_i_donor_antibo7811_req->person_idi = 1
 SET gm_i_donor_antibo7811_req->encntr_idi = 1
 SET gm_i_donor_antibo7811_req->antibody_cdi = 1
 SET gm_i_donor_antibo7811_req->result_idi = 1
 SET gm_i_donor_antibo7811_req->bb_result_nbri = 1
 SET gm_i_donor_antibo7811_req->active_indi = 1
 SET gm_i_donor_antibo7811_req->active_status_cdi = 1
 SET gm_i_donor_antibo7811_req->active_status_dt_tmi = 1
 SET gm_i_donor_antibo7811_req->active_status_prsnl_idi = 1
 SET gm_i_donor_antibo7811_req->contributor_system_cdi = 1
 DECLARE add_donor_antibody(sub_person_id=f8,sub_encntr_id=f8,sub_antibody_cd=f8,sub_result_id=f8,
  sub_bb_result_nbr=f8,
  sub_active_ind=i2,sub_active_status_cd=f8,sub_active_status_dt_tm=f8,sub_active_status_prsnl_id=f8,
  sub_contributor_system_cd=f8) = i2
 SUBROUTINE add_donor_antibody(sub_person_id,sub_encntr_id,sub_antibody_cd,sub_result_id,
  sub_bb_result_nbr,sub_active_ind,sub_active_status_cd,sub_active_status_dt_tm,
  sub_active_status_prsnl_id,sub_contributor_system_cd)
   DECLARE donor_antibody_id = f8 WITH private, noconstant(0.0)
   SET stat = alterlist(gm_i_donor_antibo7811_req->qual,1)
   IF (stat=0)
    CALL echo("can not size request structure")
    RETURN(0)
   ENDIF
   SET gm_i_donor_antibo7811_req->qual[1].person_id = sub_person_id
   SET gm_i_donor_antibo7811_req->qual[1].encntr_id = sub_encntr_id
   SET gm_i_donor_antibo7811_req->qual[1].antibody_cd = sub_antibody_cd
   SET gm_i_donor_antibo7811_req->qual[1].result_id = sub_result_id
   SET gm_i_donor_antibo7811_req->qual[1].bb_result_nbr = sub_bb_result_nbr
   SET gm_i_donor_antibo7811_req->qual[1].active_ind = sub_active_ind
   SET gm_i_donor_antibo7811_req->qual[1].active_status_cd = sub_active_status_cd
   SET gm_i_donor_antibo7811_req->qual[1].active_status_dt_tm = cnvtdatetime(sub_active_status_dt_tm)
   SET gm_i_donor_antibo7811_req->qual[1].active_status_prsnl_id = sub_active_status_prsnl_id
   SET gm_i_donor_antibo7811_req->qual[1].contributor_system_cd = sub_contributor_system_cd
   EXECUTE gm_i_donor_antibo7811  WITH replace(request,gm_i_donor_antibo7811_req), replace(reply,
    gm_i_donor_antibo7811_rep)
   IF ((gm_i_donor_antibo7811_rep->status_data.status="F"))
    CALL echo("Insert into donor_antibody table failed.")
    RETURN(0)
   ELSEIF ((gm_i_donor_antibo7811_rep->status_data.status="S"))
    CALL echo("Insert into donor_antibody table success.")
    SET donor_antibody_id = gm_i_donor_antibo7811_rep->qual[1].donor_antibody_id
    IF (donor_antibody_id=0)
     RETURN(2)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SET gm_i_donor_antige7812_req->allow_partial_ind = 0
 SET gm_i_donor_antige7812_req->person_idi = 1
 SET gm_i_donor_antige7812_req->encntr_idi = 1
 SET gm_i_donor_antige7812_req->antigen_cdi = 1
 SET gm_i_donor_antige7812_req->result_idi = 1
 SET gm_i_donor_antige7812_req->bb_result_nbri = 1
 SET gm_i_donor_antige7812_req->donor_rh_phenotype_idi = 1
 SET gm_i_donor_antige7812_req->active_indi = 1
 SET gm_i_donor_antige7812_req->active_status_dt_tmi = 1
 SET gm_i_donor_antige7812_req->active_status_prsnl_idi = 1
 SET gm_i_donor_antige7812_req->contributor_system_cdi = 1
 DECLARE add_donor_antigen(sub_person_id=f8,sub_encntr_id=f8,sub_antigen_cd=f8,sub_result_id=f8,
  sub_bb_result_nbr=f8,
  sub_donor_rh_phenotype_id=f8,sub_active_ind=i2,sub_active_status_cd=f8,sub_active_status_dt_tm=f8,
  sub_active_status_prsnl_id=f8,
  sub_contributor_system_cd=f8) = i2
 SUBROUTINE add_donor_antigen(sub_person_id,sub_encntr_id,sub_antigen_cd,sub_result_id,
  sub_bb_result_nbr,sub_donor_rh_phenotype_id,sub_active_ind,sub_active_status_cd,
  sub_active_status_dt_tm,sub_active_status_prsnl_id,sub_contributor_system_cd)
   DECLARE donor_antigen_id = f8 WITH private, noconstant(0.0)
   SET stat = alterlist(gm_i_donor_antige7812_req->qual,1)
   SET gm_i_donor_antige7812_req->qual[1].person_id = sub_person_id
   SET gm_i_donor_antige7812_req->qual[1].encntr_id = sub_encntr_id
   SET gm_i_donor_antige7812_req->qual[1].antigen_cd = sub_antigen_cd
   SET gm_i_donor_antige7812_req->qual[1].result_id = sub_result_id
   SET gm_i_donor_antige7812_req->qual[1].bb_result_nbr = sub_bb_result_nbr
   SET gm_i_donor_antige7812_req->qual[1].contributor_system_cd = sub_contributor_system_cd
   SET gm_i_donor_antige7812_req->qual[1].donor_rh_phenotype_id = sub_donor_rh_phenotype_id
   SET gm_i_donor_antige7812_req->qual[1].active_ind = sub_active_ind
   SET gm_i_donor_antige7812_req->qual[1].active_status_cd = sub_active_status_cd
   SET gm_i_donor_antige7812_req->qual[1].active_status_dt_tm = cnvtdatetime(sub_active_status_dt_tm)
   SET gm_i_donor_antige7812_req->qual[1].active_status_prsnl_id = sub_active_status_prsnl_id
   EXECUTE gm_i_donor_antige7812  WITH replace(request,gm_i_donor_antige7812_req), replace(reply,
    gm_i_donor_antige7812_rep)
   IF ((gm_i_donor_antige7812_rep->status_data.status="F"))
    CALL echo("Insert into donor_antigen table failed.")
    RETURN(0)
   ELSEIF ((gm_i_donor_antige7812_rep->status_data.status="S"))
    CALL echo("Insert into donor_antigen table success.")
    SET donor_antigen_id = gm_i_donor_antige7812_rep->qual[1].donor_antigen_id
    IF (donor_antigen_id=0)
     RETURN(2)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SET gm_u_donor_antige7812_req->allow_partial_ind = 0
 SET gm_u_donor_antige7812_req->force_updt_ind = 0
 SET gm_u_donor_antige7812_req->donor_antigen_idw = 1
 SET gm_u_donor_antige7812_req->active_indf = 1
 SET gm_u_donor_antige7812_req->active_status_cdf = 1
 DECLARE chg_donor_antigen_by_key(sub_donor_antigen_id=f8,sub_updt_cnt=i4,sub_active_ind=i2,
  sub_active_status_cd=f8) = i2
 SUBROUTINE chg_donor_antigen_by_key(sub_donor_antigen_id,sub_updt_cnt,sub_active_ind,
  sub_active_status_cd)
   SET stat = alterlist(gm_u_donor_antige7812_req->qual,1)
   SELECT INTO "nl:"
    FROM donor_antigen da
    WHERE da.donor_antigen_id=sub_donor_antigen_id
     AND da.updt_cnt=sub_updt_cnt
    DETAIL
     gm_u_donor_antige7812_req->qual[1].donor_antigen_id = da.donor_antigen_id,
     gm_u_donor_antige7812_req->qual[1].updt_cnt = da.updt_cnt
    WITH nocounter
   ;end select
   IF (curqual=0)
    RETURN(2)
   ENDIF
   SET gm_u_donor_antige7812_req->qual[1].active_ind = sub_active_ind
   SET gm_u_donor_antige7812_req->qual[1].active_status_cd = sub_active_status_cd
   EXECUTE gm_u_donor_antige7812  WITH replace(request,gm_u_donor_antige7812_req), replace(reply,
    gm_u_donor_antige7812_rep)
   IF ((gm_u_donor_antige7812_rep->status_data.status="F"))
    CALL echo("Update donor_antigen table failed.")
    RETURN(0)
   ELSEIF ((gm_u_donor_antige7812_rep->status_data.status="S"))
    CALL echo("Update donor_antigen table success.")
   ENDIF
   RETURN(1)
 END ;Subroutine
 SET current->system_dt_tm = cnvtdatetime(curdate,curtime3)
 IF ((request->use_req_dt_tm_ind=1))
  SET reply->event_dt_tm = cnvtdatetime(request->event_dt_tm)
 ELSE
  SET request->event_dt_tm = cnvtdatetime(current->system_dt_tm)
  SET reply->event_dt_tm = cnvtdatetime(current->system_dt_tm)
 ENDIF
 IF (curutc=1)
  SET reply->event_tz = curtimezoneapp
 ELSE
  SET reply->event_tz = 0
 ENDIF
 DECLARE result_status_codeset = i4 WITH public, constant(1901)
 DECLARE result_status_in_review_cdf = c12 WITH public, constant("INREVIEW")
 DECLARE result_status_old_in_rev_cdf = c12 WITH public, constant("OLDINREVIEW")
 SET result_status_performed_disp = "            "
 DECLARE result_type_text_cd = f8
 DECLARE result_type_alpha_cd = f8
 DECLARE result_type_interp_cd = f8
 DECLARE result_type_numeric_cd = f8
 DECLARE result_type_date_cd = f8
 DECLARE result_type_freetext_cd = f8
 DECLARE result_type_calc_cd = f8
 DECLARE result_status_pending_cd = f8
 DECLARE result_status_in_lab_cd = f8
 DECLARE result_status_performed_cd = f8
 DECLARE result_status_old_perf_cd = f8
 DECLARE result_status_verified_cd = f8
 DECLARE result_status_old_verf_cd = f8
 DECLARE result_status_corrected_cd = f8
 DECLARE result_status_in_review_cd = f8 WITH public, noconstant(0.0)
 DECLARE result_status_old_in_rev_cd = f8 WITH public, noconstant(0.0)
 DECLARE disposed_cd = f8
 DECLARE quarantined_cd = f8
 DECLARE drawn_cd = f8
 DECLARE tested_cd = f8
 DECLARE verified_cd = f8 WITH noconstant(0.0)
 DECLARE available_cd = f8 WITH noconstant(0.0)
 DECLARE elig_active_cd = f8
 DECLARE elig_permanent_cd = f8
 DECLARE elig_temp_cd = f8
 DECLARE elig_deferred_cd = f8
 SET cv_required_recs = 24
 DECLARE cv_cnt = i4
 DECLARE rh_cnt = i4
 DECLARE antigen_exists = c1
 DECLARE opposite_exists = c1
 DECLARE nbr_of_orders = i4
 DECLARE nbr_of_assays = i4
 DECLARE nbr_of_result_comments = i4
 DECLARE nbr_of_donors = i4
 DECLARE nbr_of_deferral_reas = i4
 DECLARE nbr_of_family = i4
 DECLARE oidx = i4
 DECLARE aidx = i4
 DECLARE rcidx = i4
 DECLARE cntr = i4
 DECLARE rh_a_cnt = i4
 DECLARE rh_a = i4
 DECLARE didx = i4
 DECLARE ridx = i4
 DECLARE midx = i4
 DECLARE parent_perf_result_id = f8
 DECLARE curr_result_status_cd = f8
 DECLARE curr_parent_perf_result_id = f8
 DECLARE hold_product_id = f8
 DECLARE mod_product_id = f8
 DECLARE mod_locked_ind = i2
 DECLARE hold_control_cell = f8
 DECLARE last_action_seq = i4
 DECLARE order_cell_prev_update = c1
 DECLARE last_event_seq = i4
 DECLARE result_event_type_cd = f8
 DECLARE result_event_reason = vc
 DECLARE product_event_id = f8
 DECLARE sub_product_event_id = f8
 DECLARE re_event_type_cd = f8
 DECLARE perf_result_seq = f8
 DECLARE new_rh_phenotype_id = f8
 DECLARE new_person_rh_phenotype_id = f8
 DECLARE new_product_rh_phenotype_id = f8
 DECLARE bb_rh_phenotype_id = f8
 DECLARE long_text_seq = f8
 DECLARE donor_aborh_id = f8 WITH protect, noconstant(0.0)
 DECLARE verified_event_id = f8 WITH noconstant(0.0)
 DECLARE tested_event_id = f8 WITH noconstant(0.0)
 SET status_count = 0
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE opposite_found_ind = i2 WITH protect, noconstant(0)
 DECLARE post_to_donor_ind = i2 WITH protect, noconstant(0)
 DECLARE special_testing_code_set = i4 WITH protect, constant(1612)
 DECLARE gsub_bbd_rh_phenotype_status = c2 WITH protect, noconstant(fillstring(2,"  "))
 DECLARE old_donor_antigen_id = f8 WITH protect, noconstant(0.0)
 DECLARE product_aborh_to_no_type = c1 WITH protect, noconstant(fillstring(1," "))
 DECLARE exception_status = c2 WITH protect, noconstant(fillstring(2,"  "))
 DECLARE sdonationtypemean = c12 WITH protect, noconstant("")
 DECLARE ldonation_type_cs = i4 WITH protect, constant(4548)
 DECLARE ddonation_type_cv = f8 WITH protect, noconstant(0.0)
 DECLARE svol_auto = c12 WITH protect, constant("VOL_AUTO")
 DECLARE svol_dir = c12 WITH protect, constant("VOL_DIR")
 DECLARE svol_auto_hzd = c12 WITH protect, constant("VOL_AUTO_HZD")
 DECLARE svol_dir_hzd = c12 WITH protect, constant("VOL_DIR_HZD")
 DECLARE svol_dir_xo = c12 WITH protect, constant("VOL_DIR_XO")
 DECLARE spd_dir = c12 WITH protect, constant("PD_DIR")
 SET rh_test_only = " "
 SET abo_test_only = " "
 SET abo_rh_test = " "
 SET write_aborh_result = " "
 SET gsub_donor_aborh_status = "  "
 SET gsub_donor_rh_phenotype_status = "  "
 SET gsub_donor_aborh_inact_status = "  "
 SET gsub_aborh_result_status = "  "
 SET gsub_donor_antibody_status = "  "
 SET gsub_donor_antigen_status = "  "
 SET gsub_special_testing_status = "  "
 SET gsub_spc_tst_result_status = "  "
 SET gsub_rh_phenotype_status = "  "
 SET product_rh_test_only = " "
 SET product_abo_test_only = " "
 SET product_abo_rh_test = " "
 SET write_result = " "
 SET current_updated_ind = 0
 SET gsub_blood_product_status = "  "
 SET gsub_abo_testing_status = "  "
 SET gsub_person_donor_status = "  "
 SET gsub_donor_elig_status = "  "
 SET gsub_bbd_deferral_reason_status = "  "
 SET mod_product_id = 0.0
 SET mod_locked_ind = 0
 DECLARE new_result_ind = i2 WITH protect, noconstant(0)
 DECLARE nnew_results_cnt = i4 WITH protect, noconstant(0)
 DECLARE nnew_results_idx = i4 WITH protect, noconstant(0)
 RECORD newresults(
   1 qual[*]
     2 oidx = i4
     2 aidx = i4
 )
 DECLARE nreplysubevent_cnt = i4 WITH protect, noconstant(0)
 DECLARE nreplysubevent_idx = i4 WITH protect, noconstant(0)
#script
 SET reply->status_data.status = "F"
 SET sub_product_event_id = 0.0
 SET re_event_type_cd = 0.0
 IF ((request->result_text_ind=1))
  SET cv_cnt = 1
  SET stat = uar_get_meaning_by_codeset(289,"1",cv_cnt,result_type_text_cd)
 ENDIF
 IF ((request->result_alpha_ind=1))
  SET cv_cnt = 1
  SET stat = uar_get_meaning_by_codeset(289,"2",cv_cnt,result_type_alpha_cd)
 ENDIF
 IF ((request->result_interp_ind=1))
  SET cv_cnt = 1
  SET stat = uar_get_meaning_by_codeset(289,"4",cv_cnt,result_type_interp_cd)
 ENDIF
 IF ((request->result_numeric_ind=1))
  SET cv_cnt = 1
  SET stat = uar_get_meaning_by_codeset(289,"3",cv_cnt,result_type_numeric_cd)
 ENDIF
 IF ((request->result_date_ind=1))
  SET cv_cnt = 1
  SET stat = uar_get_meaning_by_codeset(289,"6",cv_cnt,result_type_date_cd)
 ENDIF
 IF ((request->result_freetext_ind=1))
  SET cv_cnt = 1
  SET stat = uar_get_meaning_by_codeset(289,"7",cv_cnt,result_type_freetext_cd)
 ENDIF
 IF ((request->result_calc_ind=1))
  SET cv_cnt = 1
  SET stat = uar_get_meaning_by_codeset(289,"8",cv_cnt,result_type_calc_cd)
 ENDIF
 SET cv_cnt = 1
 SET stat = uar_get_meaning_by_codeset(1901,"PENDING",cv_cnt,result_status_pending_cd)
 SET cv_cnt = 1
 SET stat = uar_get_meaning_by_codeset(1901,"INLAB",cv_cnt,result_status_in_lab_cd)
 SET cv_cnt = 1
 SET stat = uar_get_meaning_by_codeset(1901,"OLDVERIFIED",cv_cnt,result_status_old_verf_cd)
 SET cv_cnt = 1
 SET stat = uar_get_meaning_by_codeset(1901,"VERIFIED",cv_cnt,result_status_verified_cd)
 SET cv_cnt = 1
 SET stat = uar_get_meaning_by_codeset(1901,"CORRECTED",cv_cnt,result_status_corrected_cd)
 SET stat = uar_get_meaning_by_codeset(result_status_codeset,result_status_in_review_cdf,1,
  result_status_in_review_cd)
 IF (result_status_in_review_cd=0.0)
  SET failed = "T"
  CALL subevent_add("UAR","F",result_status_codeset,"result_status_in_review_cd")
  GO TO exit_script
 ENDIF
 SET stat = uar_get_meaning_by_codeset(result_status_codeset,result_status_old_in_rev_cdf,1,
  result_status_old_in_rev_cd)
 IF (result_status_old_in_rev_cd=0.0)
  SET failed = "T"
  CALL subevent_add("UAR","F",result_status_codeset,"result_status_old_in_rev_cd")
  GO TO exit_script
 ENDIF
 IF ((request->disposed_ind=1))
  SET cv_cnt = 1
  SET stat = uar_get_meaning_by_codeset(1610,"5",cv_cnt,disposed_cd)
 ENDIF
 SET cv_cnt = 1
 SET stat = uar_get_meaning_by_codeset(1610,"2",cv_cnt,quarantined_cd)
 SET cv_cnt = 1
 SET stat = uar_get_meaning_by_codeset(1610,"20",cv_cnt,drawn_cd)
 SET cv_cnt = 1
 SET stat = uar_get_meaning_by_codeset(1610,"21",cv_cnt,tested_cd)
 SET stat = uar_get_meaning_by_codeset(1610,"23",1,verified_cd)
 SET stat = uar_get_meaning_by_codeset(1610,"12",1,available_cd)
 SET cv_cnt = 1
 SET stat = uar_get_meaning_by_codeset(14237,"GOOD",cv_cnt,elig_active_cd)
 SET cv_cnt = 1
 SET stat = uar_get_meaning_by_codeset(14237,"PERMNENT",cv_cnt,elig_deferred_cd)
 SET cv_cnt = 1
 SET stat = uar_get_meaning_by_codeset(14237,"TEMP",cv_cnt,elig_temp_cd)
 SELECT INTO "nl:"
  c.display
  FROM code_value c
  WHERE c.code_set=1901
   AND c.cdf_meaning="PERFORMED"
   AND c.active_ind=1
  DETAIL
   result_status_performed_cd = c.code_value, result_status_performed_disp = c.display
  WITH nocounter
 ;end select
 IF (((result_type_text_cd=0
  AND (request->result_text_ind=1)) OR (((result_type_alpha_cd=0
  AND (request->result_alpha_ind=1)) OR (((result_type_interp_cd=0
  AND (request->result_interp_ind=1)) OR (((result_type_numeric_cd=0
  AND (request->result_numeric_ind=1)) OR (((result_type_date_cd=0
  AND (request->result_date_ind=1)) OR (((result_type_freetext_cd=0
  AND (request->result_freetext_ind=1)) OR (((result_type_calc_cd=0
  AND (request->result_calc_ind=1)) OR (((result_status_pending_cd=0) OR (((result_status_in_lab_cd=0
 ) OR (((result_status_performed_cd=0) OR (((result_status_performed_disp="") OR (((
 result_status_old_verf_cd=0) OR (((result_status_verified_cd=0) OR (((result_status_corrected_cd=0)
  OR (((disposed_cd=0
  AND (request->disposed_ind=1)) OR (((quarantined_cd=0) OR (((drawn_cd=0) OR (((tested_cd=0) OR (((
 verified_cd=0) OR (((available_cd=0) OR (((elig_active_cd=0) OR (((elig_deferred_cd=0) OR (
 elig_temp_cd=0)) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )
  SET failed = "T"
  SET status_count = (status_count+ 1)
  IF (status_count > 1)
   SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
  ENDIF
  SET reply->status_data.subeventstatus[status_count].operationname = "SELECT"
  SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
  SET reply->status_data.subeventstatus[status_count].targetobjectname = "Code value"
  SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
  "Unable to retrieve result type, status codes, product events"
  GO TO exit_script
 ENDIF
 SET nbr_of_orders = size(request->orders,5)
 FOR (oidx = 1 TO nbr_of_orders)
  SET nbr_of_assays = size(request->orders[oidx].assays,5)
  FOR (aidx = 1 TO nbr_of_assays)
    IF ((request->orders[oidx].assays[aidx].result_id=0.0))
     SELECT INTO "nl:"
      next_seq_nbr = seq(pathnet_seq,nextval)
      FROM dual
      DETAIL
       request->orders[oidx].assays[aidx].result_id = next_seq_nbr
      WITH nocounter
     ;end select
     IF (((error_message(1) > 0) OR ((request->orders[oidx].assays[aidx].result_id=0.0))) )
      SET failed = "T"
      SET aidx = (nbr_of_assays+ 1)
      SET oidx = (nbr_of_orders+ 1)
      GO TO exit_script
     ENDIF
     SET nnew_results_cnt = (nnew_results_cnt+ 1)
     IF (nnew_results_cnt > size(newresults->qual,5))
      SET stat = alterlist(newresults->qual,(nnew_results_cnt+ 10))
     ENDIF
     SET newresults->qual[nnew_results_cnt].oidx = oidx
     SET newresults->qual[nnew_results_cnt].aidx = aidx
    ENDIF
  ENDFOR
 ENDFOR
 IF (nnew_results_cnt > 0)
  SET stat = alterlist(newresults->qual,nnew_results_cnt)
 ENDIF
 FREE SET pcs_interceptor_request
 FREE SET pcs_interceptor_reply
 RECORD pcs_interceptor_request(
   1 write_review_items_ind = i2
   1 review_queue_ind = i2
   1 manual_route_hierarchy_id = f8
   1 general_level_request
     2 event_personnel_id = f8
     2 orders[*]
       3 order_id = f8
       3 catalog_cd = f8
       3 person_id = f8
       3 encntr_id = f8
       3 activity_type_mean = c12
       3 assays[*]
         4 result_id = f8
         4 task_assay_cd = f8
         4 result_status_cd = f8
         4 chartable_flag = i2
         4 service_resource_cd = f8
         4 normal_cd = f8
         4 critical_cd = f8
         4 review_cd = f8
         4 linear_cd = f8
         4 feasible_cd = f8
         4 delta_cd = f8
         4 dilution_factor = f8
         4 resource_error_codes = vc
         4 result_type_cd = f8
         4 notify_cd = f8
         4 curr_aborh_diff_from_hist_ind = i2
         4 auto_verify_code_cnt = i4
         4 auto_verify_codes[*]
           5 auto_verify_cd = f8
   1 micro_level_request
     2 orders[*]
       3 order_id = f8
       3 tasks[1]
         4 tech_id = f8
         4 task_log_id = f8
         4 organism_cd = f8
         4 task_class_flag = i4
         4 type_flag = i4
         4 task_cd = f8
         4 positive_ind = i2
         4 report_footnotes[*]
           5 new_ind = i2
         4 susceptibilities[*]
           5 abnormal_ind = i2
           5 status_cd = f8
           5 antibiotic_cd = f8
           5 detail_cd = f8
           5 result_cd = f8
           5 result_numeric = f8
           5 chg_ind = i2
           5 delta_failed_ind = i2
           5 panel_cd = f8
         4 reports[*]
           5 abnormal_ind = i2
           5 group_id = f8
           5 response_cd = f8
 ) WITH persist
 RECORD pcs_interceptor_reply(
   1 review_items[*]
     2 review_id = f8
     2 parent_entity_name = c30
     2 parent_entity_id = f8
     2 order_id = f8
     2 review_criteria_id = f8
     2 review_status_cd = f8
     2 pending_dt_tm = dq8
     2 route_pref_flag = i4
     2 hierarchy_id = f8
     2 in_review_ind = i2
     2 micro_task_type_cd = f8
     2 queue_assignments[*]
       3 queue_review_id = f8
       3 queue_id = f8
       3 review_id = f8
       3 order_id = f8
       3 review_level_seq = i4
       3 review_type_cd = f8
       3 pending_dt_tm = dq8
       3 review_status_cd = f8
     2 qualifying_criteria[*]
       3 qualifying_criteria_id = f8
       3 review_id = f8
       3 criteria_id = f8
       3 sub_criteria_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH persist
 DECLARE lnum_assays = i4 WITH protect, noconstant(0)
 DECLARE lassay_idx = i4 WITH protect, noconstant(0)
 DECLARE lorders_idx = i4 WITH protect, noconstant(0)
 DECLARE lloadsubevent_idx = i4 WITH protect, noconstant(0)
 DECLARE lloadsubevent_cnt = i4 WITH protect, noconstant(0)
 DECLARE lloadstat = i4 WITH protect, noconstant(0)
 DECLARE lpcs_order_cnt = i4 WITH protect, noconstant(0)
 DECLARE lpcs_assay_cnt = i4 WITH protect, noconstant(0)
 DECLARE lnum_request_orders = i4 WITH protect, constant(value(size(request->orders,5)))
 DECLARE shold_log_program = c40 WITH protect, constant(log_program_name)
 DECLARE sbb_activity_type_cdf = c12 WITH protect, constant("BB")
 DECLARE sbb_donor_activity_type_cdf = c12 WITH protect, constant("BBDONOR")
 DECLARE sbb_donor_prod_activity_type_cdf = c12 WITH protect, constant("BBDONORPROD")
 IF (load_interceptor_request(0)=0)
  SET pcs_interceptor_reply->status_data.status = "F"
 ENDIF
 CALL log_message(build("Num Orders in Interceptor Request--->",lpcs_order_cnt),log_level_debug)
 IF (lpcs_order_cnt > 0)
  EXECUTE pcs_interceptor  WITH replace(request,pcs_interceptor_request), replace(reply,
   pcs_interceptor_reply)
  SET log_program_name = shold_log_program
 ELSE
  GO TO exit_load_interceptor
 ENDIF
 SET lreview_item_cnt = size(pcs_interceptor_reply->review_items,5)
 IF ((pcs_interceptor_reply->status_data.status="S")
  AND lreview_item_cnt > 0)
  RECORD pcs_upd_review_items_reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
  CALL log_message("Execute pcs_upd_review_items script",log_level_debug)
  EXECUTE pcs_upd_review_items  WITH replace(request,pcs_interceptor_reply), replace(reply,
   pcs_upd_review_items_reply)
  SET log_program_name = shold_log_program
  SET pcs_interceptor_reply->status_data.status = pcs_upd_review_items_reply->status_data.status
  IF ((pcs_upd_review_items_reply->status_data.status="F"))
   SET lloadsubevent_cnt = size(pcs_upd_review_items_reply->status_data.subeventstatus,5)
   IF (lloadsubevent_cnt > 0)
    SET nstat = alter(pcs_interceptor_reply->status_data.subeventstatus,lloadsubevent_cnt)
    FOR (lloadsubevent_idx = 1 TO lloadsubevent_cnt)
      SET pcs_interceptor_reply->status_data.subeventstatus[lloadsubevent_idx].operationname =
      pcs_upd_review_items_reply->status_data.subeventstatus[lloadsubevent_idx].operationname
      SET pcs_interceptor_reply->status_data.subeventstatus[lloadsubevent_idx].operationstatus =
      pcs_upd_review_items_reply->status_data.subeventstatus[lloadsubevent_idx].operationstatus
      SET pcs_interceptor_reply->status_data.subeventstatus[lloadsubevent_idx].targetobjectname =
      pcs_upd_review_items_reply->status_data.subeventstatus[lloadsubevent_idx].targetobjectname
      SET pcs_interceptor_reply->status_data.subeventstatus[lloadsubevent_idx].targetobjectvalue =
      pcs_upd_review_items_reply->status_data.subeventstatus[lloadsubevent_idx].targetobjectvalue
    ENDFOR
   ENDIF
   GO TO exit_load_interceptor
  ENDIF
  IF ((pcs_interceptor_reply->status_data.status="S")
   AND (pcs_upd_review_items_reply->status_data.status="S"))
   IF (validate(request->orders[1].activity_type_mean,"ZZZZZZZZZ") != "ZZZZZZZZZ")
    IF ((request->orders[1].activity_type_mean IN (sbb_activity_type_cdf, sbb_donor_activity_type_cdf
    )))
     IF (evaluate_interceptor_bld_reply(0)=0)
      SET pcs_interceptor_reply->status_data.status = "F"
     ENDIF
    ELSEIF ((request->orders[1].activity_type_mean=sbb_donor_prod_activity_type_cdf))
     IF (evaluate_interceptor_don_reply(0)=0)
      SET pcs_interceptor_reply->status_data.status = "F"
     ENDIF
    ELSE
     IF (evaluate_interceptor_reply(0)=0)
      SET pcs_interceptor_reply->status_data.status = "F"
     ENDIF
    ENDIF
   ELSE
    IF (evaluate_interceptor_reply(0)=0)
     SET pcs_interceptor_reply->status_data.status = "F"
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 DECLARE load_interceptor_request() = i2
 SUBROUTINE load_interceptor_request(null)
   DECLARE lav_code_idx = i4 WITH protect, noconstant(0)
   DECLARE nreview_required_ind = i2 WITH protect, noconstant(0)
   DECLARE nreference_lab_ind = i2 WITH protect, noconstant(0)
   DECLARE lreview_item_cnt = i4 WITH protect, noconstant(0)
   DECLARE lauto_verify_code_cnt = i4 WITH protect, noconstant(0)
   DECLARE ninvalid_bld_order_ind = i2 WITH protect, noconstant(0)
   DECLARE ninvalid_bld_assay_ind = i2 WITH protect, noconstant(0)
   DECLARE sbld_order_process_mean = c12 WITH protect, noconstant(fillstring(12," "))
   DECLARE sbld_result_process_mean = c12 WITH protect, noconstant(fillstring(12," "))
   SET curalias pcs_interceptor pcs_interceptor_request->general_level_request
   SET pcs_interceptor_request->write_review_items_ind = 1
   SET pcs_interceptor_request->manual_route_hierarchy_id = validate(request->
    manual_route_hierarchy_id,0.0)
   SET pcs_interceptor_request->review_queue_ind = validate(request->review_queue_ind,0)
   SET pcs_interceptor->event_personnel_id = request->event_personnel_id
   FOR (lorders_idx = 1 TO lnum_request_orders)
     SET nreview_required_ind = 0
     SELECT INTO "nl:"
      tr.order_id
      FROM test_reviewer tr
      PLAN (tr
       WHERE (tr.order_id=request->orders[lorders_idx].order_id))
      HEAD REPORT
       nreview_required_ind = 1
      WITH nocounter
     ;end select
     IF (validate(request->orders[lorders_idx].assays[1].interface_flag,- (1))=2)
      SET nreference_lab_ind = 1
     ELSE
      SET nreference_lab_ind = 0
     ENDIF
     SET ninvalid_bld_order_ind = 0
     IF (validate(request->orders[lorders_idx].bb_processing_mean,"ZZZZZZZZZ") != "ZZZZZZZZZ")
      SET sbld_order_process_mean = request->orders[lorders_idx].bb_processing_mean
      IF (((sbld_order_process_mean="XM") OR (sbld_order_process_mean="PRODUCT ABO")) )
       SET ninvalid_bld_order_ind = 1
      ENDIF
     ENDIF
     IF (nreview_required_ind=0
      AND nreference_lab_ind=0
      AND ninvalid_bld_order_ind=0)
      SET lnum_assays = size(request->orders[lorders_idx].assays,5)
      SET lpcs_assay_cnt = 0
      FOR (lassay_idx = 1 TO lnum_assays)
        SET ninvalid_bld_assay_ind = 0
        IF (validate(request->orders[lorders_idx].assays[lassay_idx].bb_result_processing_mean,
         "ZZZZZZZZZ") != "ZZZZZZZZZ")
         SET sbld_result_process_mean = request->orders[lorders_idx].assays[lassay_idx].
         bb_result_processing_mean
         IF (sbld_result_process_mean="TEST PHASE")
          SET ninvalid_bld_assay_ind = 1
         ENDIF
        ENDIF
        IF (uar_get_code_meaning(request->orders[lorders_idx].assays[lassay_idx].result_status_cd)
         IN ("VERIFIED", "AUTOVERIFIED", "CORRECTED")
         AND ninvalid_bld_assay_ind=0)
         SET lpcs_assay_cnt = (lpcs_assay_cnt+ 1)
         IF (lpcs_assay_cnt=1)
          SET lpcs_order_cnt = (lpcs_order_cnt+ 1)
          IF (lpcs_order_cnt > size(pcs_interceptor->orders,5))
           SET lloadstat = alterlist(pcs_interceptor->orders,(lpcs_order_cnt+ 10))
          ENDIF
          SET lloadstat = alterlist(pcs_interceptor->orders[lpcs_order_cnt].assays,lnum_assays)
          SET pcs_interceptor->orders[lpcs_order_cnt].order_id = request->orders[lorders_idx].
          order_id
          SET pcs_interceptor->orders[lpcs_order_cnt].catalog_cd = request->orders[lorders_idx].
          catalog_cd
          SET pcs_interceptor->orders[lpcs_order_cnt].person_id = request->orders[lorders_idx].
          person_id
          SET pcs_interceptor->orders[lpcs_order_cnt].encntr_id = request->orders[lorders_idx].
          encntr_id
          SET pcs_interceptor->orders[lpcs_order_cnt].activity_type_mean = ""
          IF (validate(request->orders[lorders_idx].activity_type_mean,"ZZZZZZZZZ") != "ZZZZZZZZZ")
           SET pcs_interceptor->orders[lpcs_order_cnt].activity_type_mean = request->orders[
           lorders_idx].activity_type_mean
          ENDIF
          IF (trim(pcs_interceptor->orders[lpcs_order_cnt].activity_type_mean)="")
           SELECT INTO "nl:"
            o.activity_type_cd
            FROM orders o
            PLAN (o
             WHERE (o.order_id=pcs_interceptor->orders[lpcs_order_cnt].order_id))
            DETAIL
             pcs_interceptor->orders[lpcs_order_cnt].activity_type_mean = uar_get_code_meaning(o
              .activity_type_cd)
            WITH nocounter
           ;end select
          ENDIF
         ENDIF
         SET pcs_interceptor->orders[lpcs_order_cnt].assays[lpcs_assay_cnt].result_id = request->
         orders[lorders_idx].assays[lassay_idx].result_id
         SET pcs_interceptor->orders[lpcs_order_cnt].assays[lpcs_assay_cnt].task_assay_cd = request->
         orders[lorders_idx].assays[lassay_idx].task_assay_cd
         SET pcs_interceptor->orders[lpcs_order_cnt].assays[lpcs_assay_cnt].result_status_cd =
         request->orders[lorders_idx].assays[lassay_idx].result_status_cd
         SET pcs_interceptor->orders[lpcs_order_cnt].assays[lpcs_assay_cnt].chartable_flag = validate
         (request->orders[lorders_idx].assays[lassay_idx].chartable_flag,0)
         SET pcs_interceptor->orders[lpcs_order_cnt].assays[lpcs_assay_cnt].service_resource_cd =
         request->orders[lorders_idx].assays[lassay_idx].service_resource_cd
         SET pcs_interceptor->orders[lpcs_order_cnt].assays[lpcs_assay_cnt].normal_cd = request->
         orders[lorders_idx].assays[lassay_idx].normal_cd
         SET pcs_interceptor->orders[lpcs_order_cnt].assays[lpcs_assay_cnt].critical_cd = request->
         orders[lorders_idx].assays[lassay_idx].critical_cd
         SET pcs_interceptor->orders[lpcs_order_cnt].assays[lpcs_assay_cnt].review_cd = request->
         orders[lorders_idx].assays[lassay_idx].review_cd
         SET pcs_interceptor->orders[lpcs_order_cnt].assays[lpcs_assay_cnt].linear_cd = validate(
          request->orders[lorders_idx].assays[lassay_idx].linear_cd,0.0)
         SET pcs_interceptor->orders[lpcs_order_cnt].assays[lpcs_assay_cnt].feasible_cd = validate(
          request->orders[lorders_idx].assays[lassay_idx].feasible_cd,0.0)
         SET pcs_interceptor->orders[lpcs_order_cnt].assays[lpcs_assay_cnt].delta_cd = request->
         orders[lorders_idx].assays[lassay_idx].delta_cd
         SET pcs_interceptor->orders[lpcs_order_cnt].assays[lpcs_assay_cnt].dilution_factor = request
         ->orders[lorders_idx].assays[lassay_idx].dilution_factor
         SET pcs_interceptor->orders[lpcs_order_cnt].assays[lpcs_assay_cnt].resource_error_codes =
         request->orders[lorders_idx].assays[lassay_idx].resource_error_codes
         SET pcs_interceptor->orders[lpcs_order_cnt].assays[lpcs_assay_cnt].result_type_cd = request
         ->orders[lorders_idx].assays[lassay_idx].result_type_cd
         SET pcs_interceptor->orders[lpcs_order_cnt].assays[lpcs_assay_cnt].
         curr_aborh_diff_from_hist_ind = validate(request->orders[lorders_idx].assays[lassay_idx].
          curr_aborh_diff_from_hist_ind,0)
         SET pcs_interceptor->orders[lpcs_order_cnt].assays[lpcs_assay_cnt].notify_cd = validate(
          request->orders[lorders_idx].assays[lassay_idx].notify_cd,0.0)
         IF (validate(request->orders[lorders_idx].assays[lassay_idx].auto_verify_codes[1].
          auto_verify_cd,0.0) > 0.0)
          SET lauto_verify_code_cnt = size(request->orders[lorders_idx].assays[lassay_idx].
           auto_verify_codes,5)
          SET pcs_interceptor->orders[lpcs_order_cnt].assays[lpcs_assay_cnt].auto_verify_code_cnt =
          lauto_verify_code_cnt
          SET lloadstat = alterlist(pcs_interceptor->orders[lpcs_order_cnt].assays[lpcs_assay_cnt].
           auto_verify_codes,lauto_verify_code_cnt)
          FOR (lav_code_idx = 1 TO lauto_verify_code_cnt)
            SET pcs_interceptor->orders[lpcs_order_cnt].assays[lpcs_assay_cnt].auto_verify_codes[
            lav_code_idx].auto_verify_cd = request->orders[lorders_idx].assays[lassay_idx].
            auto_verify_codes[lav_code_idx].auto_verify_cd
          ENDFOR
         ENDIF
        ENDIF
      ENDFOR
      IF (lpcs_assay_cnt > 0)
       SET lloadstat = alterlist(pcs_interceptor->orders[lpcs_order_cnt].assays,lpcs_assay_cnt)
      ENDIF
     ENDIF
   ENDFOR
   IF (lpcs_order_cnt > 0)
    SET lloadstat = alterlist(pcs_interceptor->orders,lpcs_order_cnt)
   ENDIF
   SET curalias pcs_interceptor off
   IF (error_message(1) > 0)
    RETURN(0)
   ELSE
    RETURN(1)
   ENDIF
 END ;Subroutine
 DECLARE evaluate_interceptor_reply() = i2
 SUBROUTINE evaluate_interceptor_reply(null)
   CALL log_message("called Evaluate_Interceptor_Reply",log_level_debug)
   DECLARE norder_level_route_ind = i2 WITH protect, noconstant(0)
   DECLARE dresult_status_review_cd = f8 WITH protect, noconstant(0.0)
   DECLARE dresult_status_corr_in_review_cd = f8 WITH protect, noconstant(0.0)
   DECLARE code_set = i4 WITH protect, noconstant(0)
   DECLARE cdf_meaning = c12 WITH protect, noconstant(fillstring(12," "))
   DECLARE code_value = f8 WITH protect, noconstant(0.0)
   DECLARE levalorderidx = i4 WITH protect, noconstant(0)
   SET code_set = 1901
   SET cdf_meaning = "INREVIEW"
   SET code_value = 0.0
   EXECUTE cpm_get_cd_for_cdf
   SET dresult_status_review_cd = code_value
   SET code_set = 1901
   SET cdf_meaning = "CORRINREV"
   SET code_value = 0.0
   EXECUTE cpm_get_cd_for_cdf
   SET dresult_status_corr_in_review_cd = code_value
   IF (error_message(1) > 0)
    RETURN(0)
   ENDIF
   IF (dresult_status_review_cd=0.0)
    RETURN(0)
   ENDIF
   IF (dresult_status_corr_in_review_cd=0.0)
    RETURN(0)
   ENDIF
   SELECT INTO "nl:"
    d1.seq
    FROM (dummyt d1  WITH seq = value(lreview_item_cnt))
    PLAN (d1
     WHERE (pcs_interceptor_reply->review_items[d1.seq].in_review_ind=1))
    DETAIL
     IF ((pcs_interceptor_reply->review_items[d1.seq].parent_entity_name="ORDERS"))
      norder_level_route_ind = 1
     ELSE
      norder_level_route_ind = 0
     ENDIF
     FOR (levalorderidx = 1 TO lnum_request_orders)
       IF ((request->orders[levalorderidx].order_id=pcs_interceptor_reply->review_items[d1.seq].
       order_id))
        lnum_assays = size(request->orders[levalorderidx].assays,5)
        FOR (lassay_idx = 1 TO lnum_assays)
          IF (((norder_level_route_ind=1) OR (norder_level_route_ind=0
           AND (request->orders[levalorderidx].assays[lassay_idx].result_id=pcs_interceptor_reply->
          review_items[d1.seq].parent_entity_id))) )
           IF (uar_get_code_meaning(request->orders[levalorderidx].assays[lassay_idx].
            result_status_cd)="CORRECTED")
            request->orders[levalorderidx].assays[lassay_idx].result_status_cd =
            dresult_status_corr_in_review_cd, request->orders[levalorderidx].assays[lassay_idx].
            result_status_disp = uar_get_code_display(dresult_status_corr_in_review_cd)
           ELSE
            request->orders[levalorderidx].complete_ind = 0, request->orders[levalorderidx].assays[
            lassay_idx].result_status_cd = dresult_status_review_cd, request->orders[levalorderidx].
            assays[lassay_idx].result_status_disp = uar_get_code_display(dresult_status_review_cd)
           ENDIF
          ENDIF
        ENDFOR
       ENDIF
     ENDFOR
    WITH nocounter
   ;end select
   IF (error_message(1) > 0)
    RETURN(0)
   ELSE
    RETURN(1)
   ENDIF
 END ;Subroutine
 DECLARE evaluate_interceptor_bld_reply() = i2
 SUBROUTINE evaluate_interceptor_bld_reply(null)
   CALL log_message("called Evaluate_Interceptor_Bld_Reply",log_level_debug)
   DECLARE norder_level_route_ind = i2 WITH protect, noconstant(0)
   DECLARE dresult_status_review_cd = f8 WITH protect, noconstant(0.0)
   DECLARE dresult_status_corr_in_review_cd = f8 WITH protect, noconstant(0.0)
   DECLARE code_set = i4 WITH protect, noconstant(0)
   DECLARE cdf_meaning = c12 WITH protect, noconstant(fillstring(12," "))
   DECLARE code_value = f8 WITH protect, noconstant(0.0)
   DECLARE levalorderidx = i4 WITH protect, noconstant(0)
   SET code_set = 1901
   SET cdf_meaning = "INREVIEW"
   SET code_value = 0.0
   EXECUTE cpm_get_cd_for_cdf
   SET dresult_status_review_cd = code_value
   SET code_set = 1901
   SET cdf_meaning = "CORRINREV"
   SET code_value = 0.0
   EXECUTE cpm_get_cd_for_cdf
   SET dresult_status_corr_in_review_cd = code_value
   IF (error_message(1) > 0)
    RETURN(0)
   ENDIF
   IF (dresult_status_review_cd=0.0)
    RETURN(0)
   ENDIF
   IF (dresult_status_corr_in_review_cd=0.0)
    RETURN(0)
   ENDIF
   SELECT INTO "nl:"
    d1.seq
    FROM (dummyt d1  WITH seq = value(lreview_item_cnt))
    PLAN (d1
     WHERE (pcs_interceptor_reply->review_items[d1.seq].in_review_ind=1))
    DETAIL
     IF ((pcs_interceptor_reply->review_items[d1.seq].parent_entity_name="ORDERS"))
      norder_level_route_ind = 1
     ELSE
      norder_level_route_ind = 0
     ENDIF
     FOR (levalorderidx = 1 TO lnum_request_orders)
       IF ((request->orders[levalorderidx].order_id=pcs_interceptor_reply->review_items[d1.seq].
       order_id))
        lnum_assays = size(request->orders[levalorderidx].assays,5)
        FOR (lassay_idx = 1 TO lnum_assays)
          IF (((norder_level_route_ind=1) OR (norder_level_route_ind=0
           AND (request->orders[levalorderidx].assays[lassay_idx].result_id=pcs_interceptor_reply->
          review_items[d1.seq].parent_entity_id))) )
           IF (uar_get_code_meaning(request->orders[levalorderidx].assays[lassay_idx].
            result_status_cd)="CORRECTED")
            IF ((request->orders[levalorderidx].assays[lassay_idx].bb_result_processing_mean !=
            "TEST PHASE"))
             request->orders[levalorderidx].assays[lassay_idx].result_status_cd =
             dresult_status_corr_in_review_cd, request->orders[levalorderidx].assays[lassay_idx].
             result_status_disp = uar_get_code_display(dresult_status_corr_in_review_cd)
            ENDIF
           ELSE
            IF ((request->orders[levalorderidx].assays[lassay_idx].bb_result_processing_mean !=
            "TEST PHASE"))
             request->orders[levalorderidx].complete_ind = 0, request->orders[levalorderidx].assays[
             lassay_idx].result_status_cd = dresult_status_review_cd, request->orders[levalorderidx].
             assays[lassay_idx].result_status_disp = uar_get_code_display(dresult_status_review_cd)
            ENDIF
           ENDIF
           IF ((request->orders[levalorderidx].assays[lassay_idx].aborh_verify_yn="Y"))
            request->orders[levalorderidx].assays[lassay_idx].aborh_verify_yn = "N"
           ENDIF
           IF ((request->orders[levalorderidx].assays[lassay_idx].antibody_verify_yn="Y"))
            request->orders[levalorderidx].assays[lassay_idx].antibody_verify_yn = "N"
           ENDIF
           IF ((request->orders[levalorderidx].assays[lassay_idx].antigen_verify_yn="Y"))
            request->orders[levalorderidx].assays[lassay_idx].antigen_verify_yn = "N"
           ENDIF
           IF ((request->orders[levalorderidx].assays[lassay_idx].rh_phenotype_verify_yn="Y"))
            request->orders[levalorderidx].assays[lassay_idx].rh_phenotype_verify_yn = "N"
           ENDIF
           IF ((request->orders[levalorderidx].assays[lassay_idx].special_testing_verify_yn="Y"))
            request->orders[levalorderidx].assays[lassay_idx].special_testing_verify_yn = "N"
           ENDIF
           IF ((request->orders[levalorderidx].assays[lassay_idx].product_rh_phenotype_verify_yn="Y")
           )
            request->orders[levalorderidx].assays[lassay_idx].product_rh_phenotype_verify_yn = "N"
           ENDIF
          ENDIF
        ENDFOR
       ENDIF
     ENDFOR
    WITH nocounter
   ;end select
   IF (error_message(1) > 0)
    RETURN(0)
   ELSE
    RETURN(1)
   ENDIF
 END ;Subroutine
 DECLARE evaluate_interceptor_don_reply() = i2
 SUBROUTINE evaluate_interceptor_don_reply(null)
   CALL log_message("called Evaluate_Interceptor_Don_Reply",log_level_debug)
   DECLARE norder_level_route_ind = i2 WITH protect, noconstant(0)
   DECLARE dresult_status_review_cd = f8 WITH protect, noconstant(0.0)
   DECLARE dresult_status_corr_in_review_cd = f8 WITH protect, noconstant(0.0)
   DECLARE code_set = i4 WITH protect, noconstant(0)
   DECLARE cdf_meaning = c12 WITH protect, noconstant(fillstring(12," "))
   DECLARE code_value = f8 WITH protect, noconstant(0.0)
   DECLARE levalorderidx = i4 WITH protect, noconstant(0)
   SET code_set = 1901
   SET cdf_meaning = "INREVIEW"
   SET code_value = 0.0
   EXECUTE cpm_get_cd_for_cdf
   SET dresult_status_review_cd = code_value
   SET code_set = 1901
   SET cdf_meaning = "CORRINREV"
   SET code_value = 0.0
   EXECUTE cpm_get_cd_for_cdf
   SET dresult_status_corr_in_review_cd = code_value
   IF (error_message(1) > 0)
    RETURN(0)
   ENDIF
   IF (dresult_status_review_cd=0.0)
    RETURN(0)
   ENDIF
   IF (dresult_status_corr_in_review_cd=0.0)
    RETURN(0)
   ENDIF
   SELECT INTO "nl:"
    d1.seq
    FROM (dummyt d1  WITH seq = value(lreview_item_cnt))
    PLAN (d1
     WHERE (pcs_interceptor_reply->review_items[d1.seq].in_review_ind=1))
    DETAIL
     IF ((pcs_interceptor_reply->review_items[d1.seq].parent_entity_name="ORDERS"))
      norder_level_route_ind = 1
     ELSE
      norder_level_route_ind = 0
     ENDIF
     FOR (levalorderidx = 1 TO lnum_request_orders)
       IF ((request->orders[levalorderidx].order_id=pcs_interceptor_reply->review_items[d1.seq].
       order_id))
        lnum_assays = size(request->orders[levalorderidx].assays,5)
        FOR (lassay_idx = 1 TO lnum_assays)
          IF (((norder_level_route_ind=1) OR (norder_level_route_ind=0
           AND (request->orders[levalorderidx].assays[lassay_idx].result_id=pcs_interceptor_reply->
          review_items[d1.seq].parent_entity_id))) )
           IF (uar_get_code_meaning(request->orders[levalorderidx].assays[lassay_idx].
            result_status_cd)="CORRECTED")
            request->orders[levalorderidx].assays[lassay_idx].result_status_cd =
            dresult_status_corr_in_review_cd, request->orders[levalorderidx].assays[lassay_idx].
            result_status_disp = uar_get_code_display(dresult_status_corr_in_review_cd)
           ELSE
            request->orders[levalorderidx].complete_ind = 0, request->orders[levalorderidx].assays[
            lassay_idx].result_status_cd = dresult_status_review_cd, request->orders[levalorderidx].
            assays[lassay_idx].result_status_disp = uar_get_code_display(dresult_status_review_cd)
           ENDIF
           IF ((request->orders[levalorderidx].assays[lassay_idx].antigen_verify_yn="Y"))
            request->orders[levalorderidx].assays[lassay_idx].antigen_verify_yn = "N"
           ENDIF
           IF ((request->orders[levalorderidx].assays[lassay_idx].donor_rh_phenotype_verify_yn="Y"))
            request->orders[levalorderidx].assays[lassay_idx].donor_rh_phenotype_verify_yn = "N"
           ENDIF
           IF ((request->orders[levalorderidx].assays[lassay_idx].special_testing_verify_yn="Y"))
            request->orders[levalorderidx].assays[lassay_idx].special_testing_verify_yn = "N"
           ENDIF
           IF ((request->orders[levalorderidx].assays[lassay_idx].product_rh_phenotype_verify_yn="Y")
           )
            request->orders[levalorderidx].assays[lassay_idx].product_rh_phenotype_verify_yn = "N"
           ENDIF
           IF (validate(request->orders[levalorderidx].assays[lassay_idx].add_product_tested_yn,
            "ZZZZZZZZZ") != "ZZZZZZZZZ")
            IF ((request->orders[levalorderidx].assays[lassay_idx].add_product_tested_yn="Y"))
             request->orders[levalorderidx].assays[lassay_idx].add_product_tested_yn = "N"
            ENDIF
           ENDIF
           IF (validate(request->orders[levalorderidx].assays[lassay_idx].inact_product_drawn_yn,
            "ZZZZZZZZZ") != "ZZZZZZZZZ")
            IF ((request->orders[levalorderidx].assays[lassay_idx].inact_product_drawn_yn="Y"))
             request->orders[levalorderidx].assays[lassay_idx].inact_product_drawn_yn = "N"
            ENDIF
           ENDIF
          ENDIF
        ENDFOR
       ENDIF
     ENDFOR
    WITH nocounter
   ;end select
   IF (error_message(1) > 0)
    RETURN(0)
   ELSE
    RETURN(1)
   ENDIF
 END ;Subroutine
#exit_load_interceptor
 SET reply->status_data.status = pcs_interceptor_reply->status_data.status
 SET lloadsubevent_cnt = size(pcs_interceptor_reply->status_data.subeventstatus,5)
 IF ((pcs_interceptor_reply->status_data.status="F")
  AND lloadsubevent_cnt > 0)
  SET lloadstat = alter(reply->status_data.subeventstatus,lloadsubevent_cnt)
  FOR (lloadsubevent_idx = 1 TO lloadsubevent_cnt)
    SET reply->status_data.subeventstatus[lloadsubevent_idx].operationname = pcs_interceptor_reply->
    status_data.subeventstatus[lloadsubevent_idx].operationname
    SET reply->status_data.subeventstatus[lloadsubevent_idx].operationstatus = pcs_interceptor_reply
    ->status_data.subeventstatus[lloadsubevent_idx].operationstatus
    SET reply->status_data.subeventstatus[lloadsubevent_idx].targetobjectname = pcs_interceptor_reply
    ->status_data.subeventstatus[lloadsubevent_idx].targetobjectname
    SET reply->status_data.subeventstatus[lloadsubevent_idx].targetobjectvalue =
    pcs_interceptor_reply->status_data.subeventstatus[lloadsubevent_idx].targetobjectvalue
  ENDFOR
 ENDIF
 IF ((reply->status_data.status="F"))
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "F"
 SET nbr_of_orders = size(request->orders,5)
 SET stat = alterlist(reply->orders,nbr_of_orders)
 SET hold_product_id = 0.0
 SET hold_control_cell = 0.0
 SET order_cell_prev_update = "N"
 FOR (oidx = 1 TO nbr_of_orders)
   SET nbr_of_assays = request->orders[oidx].assays_cnt
   SET reply->orders[oidx].order_id = request->orders[oidx].order_id
   SET reply->orders[oidx].assays_cnt = nbr_of_assays
   SET stat = alterlist(reply->orders[oidx].assays,nbr_of_assays)
   FOR (aidx = 1 TO nbr_of_assays)
     SET new_result_ind = 0
     FOR (nnew_results_idx = 1 TO nnew_results_cnt)
       IF ((newresults->qual[nnew_results_idx].oidx=oidx)
        AND (newresults->qual[nnew_results_idx].aidx=aidx))
        SET new_result_ind = 1
       ELSEIF ((newresults->qual[nnew_results_idx].oidx >= oidx)
        AND (newresults->qual[nnew_results_idx].aidx > aidx))
        SET nnew_results_idx = (nnew_results_cnt+ 1)
       ENDIF
     ENDFOR
     CALL log_message(build("aidx -->",aidx),log_level_debug)
     CALL log_message(build("new_result_ind -->",new_result_ind),log_level_debug)
     IF ((request->use_req_dt_tm_ind=1))
      SET reply->orders[oidx].assays[aidx].perform_dt_tm = cnvtdatetime(request->orders[oidx].assays[
       aidx].perform_dt_tm)
     ELSE
      SET request->orders[oidx].assays[aidx].perform_dt_tm = cnvtdatetime(current->system_dt_tm)
      SET reply->orders[oidx].assays[aidx].perform_dt_tm = cnvtdatetime(current->system_dt_tm)
     ENDIF
     IF ((request->orders[oidx].assays[aidx].next_row_ind=1))
      SET hold_product_id = 0.0
      SET hold_control_cell = 0.0
      SET order_cell_prev_update = "N"
     ENDIF
     SET reply->orders[oidx].assays[aidx].task_assay_cd = request->orders[oidx].assays[aidx].
     task_assay_cd
     SET reply->orders[oidx].assays[aidx].updt_id = reqinfo->updt_id
     SET reply->orders[oidx].assays[aidx].result_key = request->orders[oidx].assays[aidx].result_key
     IF (curutc=1)
      SET reply->orders[oidx].assays[aidx].perform_tz = curtimezoneapp
     ELSE
      SET reply->orders[oidx].assays[aidx].perform_tz = 0
     ENDIF
     SET reply->orders[oidx].assays[aidx].perform_result_key = request->orders[oidx].assays[aidx].
     perform_result_key
     SET reply->orders[oidx].assays[aidx].result_status_cd = request->orders[oidx].assays[aidx].
     result_status_cd
     IF ((request->orders[oidx].assays[aidx].bb_control_cell_cd > 0))
      IF ((request->orders[oidx].assays[aidx].bb_result_id > 0))
       SET bb_result_seq = request->orders[oidx].assays[aidx].bb_result_id
      ELSEIF ((((request->orders[oidx].assays[aidx].bb_control_cell_cd != hold_control_cell)) OR ((
      request->orders[oidx].assays[aidx].next_row_ind=1))) )
       SET bb_result_seq = 0.0
      ENDIF
     ELSEIF ((request->orders[oidx].assays[aidx].product_id > 0))
      IF ((request->orders[oidx].assays[aidx].bb_result_id > 0))
       SET bb_result_seq = request->orders[oidx].assays[aidx].bb_result_id
      ELSEIF ((((request->orders[oidx].assays[aidx].product_id != hold_product_id)) OR ((request->
      orders[oidx].assays[aidx].next_row_ind=1))) )
       SET bb_result_seq = 0.0
      ENDIF
     ELSE
      SET bb_result_seq = 0.0
     ENDIF
     IF (((new_result_ind=0) OR ((request->orders[oidx].assays[aidx].perform_result_id > 0.0))) )
      IF (process_updated_result(0)=0)
       GO TO exit_script
      ENDIF
     ENDIF
     IF (new_result_ind=1
      AND (request->orders[oidx].assays[aidx].perform_result_id=0.0))
      IF (process_new_result(0)=0)
       GO TO exit_script
      ENDIF
     ENDIF
     SET reply->orders[oidx].assays[aidx].bb_result_id = bb_result_seq
     SET nbr_of_deferral_reas = size(request->deferral_reasons,5)
     FOR (ridx = 1 TO nbr_of_deferral_reas)
       IF ((request->deferral_reasons[ridx].row_col=request->orders[oidx].assays[aidx].row_col))
        SET request->deferral_reasons[ridx].result_id = reply->orders[oidx].assays[aidx].result_id
       ENDIF
     ENDFOR
     IF ((request->orders[oidx].assays[aidx].product_id > 0))
      SET reply->orders[oidx].assays[aidx].product_id = request->orders[oidx].assays[aidx].product_id
     ELSE
      SET reply->orders[oidx].assays[aidx].product_id = request->orders[oidx].assays[aidx].
      bb_control_cell_cd
     ENDIF
     SET reply->orders[oidx].assays[aidx].cell_id = request->orders[oidx].assays[aidx].cell_id
     IF ((((request->orders[oidx].assays[aidx].bb_control_cell_cd != hold_control_cell)) OR ((request
     ->orders[oidx].assays[aidx].next_row_ind=1))) )
      SET hold_control_cell = request->orders[oidx].assays[aidx].bb_control_cell_cd
     ENDIF
     IF ((((request->orders[oidx].assays[aidx].product_id != hold_product_id)) OR ((request->orders[
     oidx].assays[aidx].next_row_ind=1))) )
      SET hold_product_id = request->orders[oidx].assays[aidx].product_id
     ENDIF
     IF (order_cell_prev_update="Y")
      SET reply->orders[oidx].assays[aidx].order_cell_updt_cnt = (request->orders[oidx].assays[aidx].
      order_cell_updt_cnt+ 1)
     ELSE
      SET reply->orders[oidx].assays[aidx].order_cell_updt_cnt = request->orders[oidx].assays[aidx].
      order_cell_updt_cnt
     ENDIF
     IF ((mod_product_id != request->orders[oidx].assays[aidx].product_id))
      SET mod_product_id = request->orders[oidx].assays[aidx].product_id
      CALL get_mod_family(mod_product_id)
      IF (mod_locked_ind=1)
       SET failed = "T"
       SET status_count = (status_count+ 1)
       IF (status_count > 1)
        SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
       ENDIF
       SET reply->status_data.subeventstatus[status_count].operationname = "Retrieve"
       SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
       SET reply->status_data.subeventstatus[status_count].targetobjectname = "Product"
       SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
       "Unable to update all products related to the current product since one or more were locked."
       GO TO exit_script
      ENDIF
      SET nbr_of_family = size(modproductlist->product,5)
     ENDIF
     FOR (midx = 1 TO nbr_of_family)
       SET ddonation_type_cv = 0.0
       IF ((modproductlist->product[midx].donation_type_mean IN (svol_auto, svol_dir, svol_dir_xo,
       spd_dir))
        AND (modproductlist->product[midx].biohazard_ind=1))
        IF ((modproductlist->product[midx].donation_type_mean=svol_auto))
         SET ddonation_type_cv = uar_get_code_by("MEANING",ldonation_type_cs,nullterm(svol_auto_hzd))
        ELSEIF ((modproductlist->product[midx].donation_type_mean IN (svol_dir, svol_dir_xo, spd_dir)
        ))
         SET ddonation_type_cv = uar_get_code_by("MEANING",ldonation_type_cs,nullterm(svol_dir_hzd))
        ENDIF
        SELECT
         p.product_id
         FROM product p
         WHERE (p.product_id=modproductlist->product[midx].product_id)
         WITH nocounter, forupdate(p)
        ;end select
        UPDATE  FROM product p
         SET p.donation_type_cd = ddonation_type_cv
         WHERE (p.product_id=modproductlist->product[midx].product_id)
         WITH nocounter
        ;end update
       ENDIF
       IF ((request->orders[oidx].assays[aidx].next_row_ind=1))
        IF ((request->orders[oidx].assays[aidx].add_product_tested_yn="Y"))
         SET product_event_id = 0.0
         SET sub_product_event_id = 0.0
         SET re_event_type_cd = tested_cd
         SET gsub_product_event_status = "  "
         CALL add_product_event(modproductlist->product[midx].product_id,0,0,request->orders[oidx].
          order_id,0,
          tested_cd,cnvtdatetime(request->event_dt_tm),request->event_personnel_id,0,0,
          0,0,1,reqdata->active_status_cd,cnvtdatetime(current->system_dt_tm),
          request->event_personnel_id)
         SET sub_product_event_id = product_event_id
         IF (gsub_product_event_status="FS")
          SET failed = "T"
          SET status_count = (status_count+ 1)
          IF (status_count > 1)
           SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
          ENDIF
          SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
          SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
          SET reply->status_data.subeventstatus[status_count].targetobjectname = "Product Event"
          SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
          "Unable to insert tested product event due to product event id"
          GO TO exit_script
         ELSEIF (gsub_product_event_status="FA")
          SET failed = "T"
          SET status_count = (status_count+ 1)
          IF (status_count > 1)
           SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
          ENDIF
          SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
          SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
          SET reply->status_data.subeventstatus[status_count].targetobjectname = "Product Event"
          SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
          "Unable to insert tested product event"
          GO TO exit_script
         ENDIF
         IF ((((modproductlist->product[midx].drawn_event_id > 0.0)) OR ((request->orders[oidx].
         assays[aidx].inact_product_drawn_yn="Y"))) )
          SET cur_updt_cnt = 0
          IF ((modproductlist->product[midx].drawn_event_id > 0.0))
           SELECT INTO "nl:"
            p.product_event_id
            FROM product_event p
            WHERE (p.product_event_id=modproductlist->product[midx].drawn_event_id)
            DETAIL
             cur_updt_cnt = p.updt_cnt
            WITH nocounter, forupdate(p)
           ;end select
          ELSE
           SELECT INTO "nl:"
            p.product_event_id
            FROM product_event p
            WHERE (p.product_event_id=request->orders[oidx].assays[aidx].drawn_prod_event_id)
            DETAIL
             cur_updt_cnt = p.updt_cnt
            WITH nocounter, forupdate(p)
           ;end select
          ENDIF
          IF (curqual=0)
           SET failed = "T"
           SET status_count = (status_count+ 1)
           IF (status_count > 1)
            SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
           ENDIF
           SET reply->status_data.subeventstatus[status_count].operationname = "SELECT"
           SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
           SET reply->status_data.subeventstatus[status_count].targetobjectname = "Product Event"
           SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
           "Unable to lock product event for drawn state"
          ELSEIF ((cur_updt_cnt != request->orders[oidx].assays[aidx].drawn_state_updt_cnt))
           SET failed = "T"
           SET status_count = (status_count+ 1)
           IF (status_count > 1)
            SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
           ENDIF
           SET reply->status_data.subeventstatus[status_count].operationname = "SELECT"
           SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
           SET reply->status_data.subeventstatus[status_count].targetobjectname = "Product Event"
           SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
           "Update conflict on product event for drawn state"
          ELSE
           IF ((modproductlist->product[midx].drawn_event_id > 0.0))
            UPDATE  FROM product_event pe
             SET pe.bb_result_id = 0, pe.active_ind = 0, pe.active_status_cd = reqdata->
              active_status_cd,
              pe.updt_cnt = (pe.updt_cnt+ 1), pe.updt_dt_tm = cnvtdatetime(curdate,curtime3), pe
              .updt_id = reqinfo->updt_id,
              pe.updt_task = reqinfo->updt_task, pe.updt_applctx = reqinfo->updt_applctx
             WHERE (pe.product_event_id=modproductlist->product[midx].drawn_event_id)
              AND (pe.updt_cnt=modproductlist->product[midx].drawn_updt_cnt)
             WITH nocounter
            ;end update
           ELSE
            UPDATE  FROM product_event pe
             SET pe.bb_result_id = 0, pe.active_ind = 0, pe.active_status_cd = reqdata->
              active_status_cd,
              pe.updt_cnt = (pe.updt_cnt+ 1), pe.updt_dt_tm = cnvtdatetime(curdate,curtime3), pe
              .updt_id = reqinfo->updt_id,
              pe.updt_task = reqinfo->updt_task, pe.updt_applctx = reqinfo->updt_applctx
             WHERE (pe.product_event_id=request->orders[oidx].assays[aidx].drawn_prod_event_id)
              AND (pe.updt_cnt=request->orders[oidx].assays[aidx].drawn_state_updt_cnt)
             WITH nocounter
            ;end update
           ENDIF
           IF (curqual=0)
            SET failed = "T"
            SET status_count = (status_count+ 1)
            IF (status_count > 1)
             SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
            ENDIF
            SET reply->status_data.subeventstatus[status_count].operationname = "CHANGE"
            SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
            SET reply->status_data.subeventstatus[status_count].targetobjectname = "Product Event"
            SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
            "Unable to update product event for drawn state"
           ENDIF
          ENDIF
         ENDIF
         SET verified_event_id = 0.0
         SET tested_event_id = 0.0
         SELECT INTO "nl:"
          pe.product_id
          FROM product_event pe
          WHERE (pe.product_id=modproductlist->product[midx].product_id)
           AND pe.event_type_cd=verified_cd
           AND pe.active_ind=1
          DETAIL
           verified_event_id = pe.product_event_id
          WITH nocounter, forupdate(pe)
         ;end select
         IF (verified_event_id > 0)
          UPDATE  FROM product_event pe
           SET pe.active_ind = 0, pe.active_status_cd = reqdata->inactive_status_cd, pe.updt_cnt = (
            pe.updt_cnt+ 1),
            pe.updt_dt_tm = cnvtdatetime(curdate,curtime3), pe.updt_id = reqinfo->updt_id, pe
            .updt_task = reqinfo->updt_task,
            pe.updt_applctx = reqinfo->updt_applctx
           WHERE pe.product_event_id=verified_event_id
           WITH nocounter
          ;end update
          SELECT INTO "nl:"
           pe.product_id
           FROM product_event pe
           WHERE (pe.product_id=modproductlist->product[midx].product_id)
            AND pe.event_type_cd=tested_cd
            AND pe.active_ind=1
           DETAIL
            tested_event_id = pe.product_event_id
           WITH nocounter, forupdate(pe)
          ;end select
          IF (tested_event_id > 0)
           UPDATE  FROM product_event pe
            SET pe.active_ind = 0, pe.active_status_cd = reqdata->inactive_status_cd, pe.updt_cnt = (
             pe.updt_cnt+ 1),
             pe.updt_dt_tm = cnvtdatetime(curdate,curtime3), pe.updt_id = reqinfo->updt_id, pe
             .updt_task = reqinfo->updt_task,
             pe.updt_applctx = reqinfo->updt_applctx
            WHERE pe.product_event_id=tested_event_id
            WITH nocounter
           ;end update
           SET product_event_id = 0.0
           SET sub_product_event_id = 0.0
           SET re_event_type_cd = tested_cd
           SET gsub_product_event_status = "  "
           CALL add_product_event(modproductlist->product[midx].product_id,0,0,0,0,
            available_cd,cnvtdatetime(request->event_dt_tm),request->event_personnel_id,0,0,
            0,0,1,reqdata->active_status_cd,cnvtdatetime(current->system_dt_tm),
            request->event_personnel_id)
           SET sub_product_event_id = product_event_id
           IF (gsub_product_event_status="FS")
            SET failed = "T"
            SET status_count = (status_count+ 1)
            IF (status_count > 1)
             SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
            ENDIF
            SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
            SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
            SET reply->status_data.subeventstatus[status_count].targetobjectname = "Product Event"
            SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
            "Unable to insert available product event due to product event id"
            GO TO exit_script
           ELSEIF (gsub_product_event_status="FA")
            SET failed = "T"
            SET status_count = (status_count+ 1)
            IF (status_count > 1)
             SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
            ENDIF
            SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
            SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
            SET reply->status_data.subeventstatus[status_count].targetobjectname = "Product Event"
            SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
            "Unable to insert available product event"
            GO TO exit_script
           ENDIF
          ENDIF
         ENDIF
        ENDIF
        IF ((request->orders[oidx].assays[aidx].add_product_disposed_yn="Y"))
         SET product_event_id = 0.0
         SET sub_product_event_id = 0.0
         SET re_event_type_cd = disposed_cd
         SET gsub_product_event_status = "  "
         CALL add_product_event(modproductlist->product[midx].product_id,0,0,request->orders[oidx].
          order_id,0,
          disposed_cd,cnvtdatetime(request->event_dt_tm),request->event_personnel_id,0,
          IF ((request->orders[oidx].assays[aidx].except_cnt > 0)) 1
          ELSE 0
          ENDIF
          ,
          IF ((request->orders[oidx].assays[aidx].except_cnt > 0)) request->orders[oidx].assays[aidx]
           .exceptlist[1].override_reason_cd
          ELSE 0
          ENDIF
          ,0,1,reqdata->active_status_cd,cnvtdatetime(current->system_dt_tm),
          request->event_personnel_id)
         SET sub_product_event_id = product_event_id
         IF (gsub_product_event_status="FS")
          SET failed = "T"
          SET status_count = (status_count+ 1)
          IF (status_count > 1)
           SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
          ENDIF
          SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
          SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
          SET reply->status_data.subeventstatus[status_count].targetobjectname = "Product Event"
          SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
          "Unable to insert disposed product event due to product event id"
          GO TO exit_script
         ELSEIF (gsub_product_event_status="FA")
          SET failed = "T"
          SET status_count = (status_count+ 1)
          IF (status_count > 1)
           SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
          ENDIF
          SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
          SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
          SET reply->status_data.subeventstatus[status_count].targetobjectname = "Product Event"
          SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
          "Unable to insert dipsosed product event"
          GO TO exit_script
         ENDIF
         INSERT  FROM disposition d
          SET d.product_event_id = sub_product_event_id, d.product_id = modproductlist->product[midx]
           .product_id, d.reason_cd = request->orders[oidx].assays[aidx].dispose_reason_cd,
           d.disposed_qty = 0, d.disposed_intl_units = 0, d.updt_cnt = 0,
           d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_id = reqinfo->updt_id, d.updt_task
            = reqinfo->updt_task,
           d.updt_applctx = reqinfo->updt_applctx, d.active_ind = 1, d.active_status_cd = reqdata->
           active_status_cd,
           d.active_status_dt_tm = cnvtdatetime(curdate,curtime3), d.active_status_prsnl_id = reqinfo
           ->updt_id
          WITH nocounter
         ;end insert
        ENDIF
        IF ((request->orders[oidx].assays[aidx].add_product_quar_yn="Y"))
         SET product_event_id = 0.0
         SET sub_product_event_id = 0.0
         SET re_event_type_cd = quarantined_cd
         SET gsub_product_event_status = "  "
         CALL add_product_event(modproductlist->product[midx].product_id,0,0,request->orders[oidx].
          order_id,0,
          quarantined_cd,cnvtdatetime(request->event_dt_tm),request->event_personnel_id,0,
          IF ((request->orders[oidx].assays[aidx].except_cnt > 0)) 1
          ELSE 0
          ENDIF
          ,
          IF ((request->orders[oidx].assays[aidx].except_cnt > 0)) request->orders[oidx].assays[aidx]
           .exceptlist[1].override_reason_cd
          ELSE 0
          ENDIF
          ,0,1,reqdata->active_status_cd,cnvtdatetime(current->system_dt_tm),
          request->event_personnel_id)
         SET sub_product_event_id = product_event_id
         IF (gsub_product_event_status="FS")
          SET failed = "T"
          SET status_count = (status_count+ 1)
          IF (status_count > 1)
           SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
          ENDIF
          SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
          SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
          SET reply->status_data.subeventstatus[status_count].targetobjectname = "Product Event"
          SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
          "Unable to insert quarantine product event due to product event id"
          GO TO exit_script
         ELSEIF (gsub_product_event_status="FA")
          SET failed = "T"
          SET status_count = (status_count+ 1)
          IF (status_count > 1)
           SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
          ENDIF
          SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
          SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
          SET reply->status_data.subeventstatus[status_count].targetobjectname = "Product Event"
          SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
          "Unable to insert quarantine product event"
          GO TO exit_script
         ENDIF
         INSERT  FROM quarantine qu
          SET qu.product_event_id = sub_product_event_id, qu.product_id = modproductlist->product[
           midx].product_id, qu.quar_reason_cd = request->orders[oidx].assays[aidx].
           quarantine_reason_cd,
           qu.orig_quar_qty = 0, qu.cur_quar_qty = 0, qu.orig_quar_intl_units = 0,
           qu.cur_quar_intl_units = 0, qu.updt_cnt = 0, qu.updt_dt_tm = cnvtdatetime(curdate,curtime3
            ),
           qu.updt_id = reqinfo->updt_id, qu.updt_task = reqinfo->updt_task, qu.updt_applctx =
           reqinfo->updt_applctx,
           qu.active_ind = 1, qu.active_status_cd = reqdata->active_status_cd, qu.active_status_dt_tm
            = cnvtdatetime(curdate,curtime3),
           qu.active_status_prsnl_id = reqinfo->updt_id
          WITH nocounter
         ;end insert
        ENDIF
       ENDIF
       IF ((request->orders[oidx].assays[aidx].product_aborh_verify_yn="Y")
        AND (request->orders[oidx].assays[aidx].bb_result_code_set_cd > 0))
        IF (update_product_aborh(0)=1)
         IF ((request->orders[oidx].assays[aidx].upd_blood_product_yn="Y"))
          SET reply->orders[oidx].assays[aidx].product_new_abo_cd = request->orders[oidx].assays[aidx
          ].product_new_abo_cd
          SET reply->orders[oidx].assays[aidx].product_new_rh_cd = request->orders[oidx].assays[aidx]
          .product_new_rh_cd
          SET reply->orders[oidx].assays[aidx].product_new_aborh_updt_cnt = (request->orders[oidx].
          assays[aidx].blood_product_updt_cnt+ 1)
         ENDIF
        ELSE
         IF (gsub_blood_product_status="FL")
          SET failed = "T"
          SET status_count = (status_count+ 1)
          IF (status_count > 1)
           SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
          ENDIF
          SET reply->status_data.subeventstatus[status_count].operationname = "SELECT"
          SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
          SET reply->status_data.subeventstatus[status_count].targetobjectname = "BLOOD_PRODUCT"
          SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
          "Unable to lock blood_product"
         ELSEIF (gsub_blood_product_status="FU")
          SET failed = "T"
          SET status_count = (status_count+ 1)
          IF (status_count > 1)
           SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
          ENDIF
          SET reply->status_data.subeventstatus[status_count].operationname = "UPDATE"
          SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
          SET reply->status_data.subeventstatus[status_count].targetobjectname = "BLOOD_PRODUCT"
          SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
          "Unable to update blood product"
         ENDIF
         IF (gsub_abo_testing_status="FA")
          SET failed = "T"
          SET status_count = (status_count+ 1)
          IF (status_count > 1)
           SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
          ENDIF
          SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
          SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
          SET reply->status_data.subeventstatus[status_count].targetobjectname = "ABO_TESTING"
          SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
          "Unable to insert row in ABO_TESTING"
         ELSEIF (gsub_abo_testing_status="FS")
          SET failed = "T"
          SET status_count = (status_count+ 1)
          IF (status_count > 1)
           SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
          ENDIF
          SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
          SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
          SET reply->status_data.subeventstatus[status_count].targetobjectname = "Ab Testing"
          SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
          "Unable to insert aborh result due to next sequence number"
         ENDIF
         GO TO exit_script
        ENDIF
       ENDIF
       IF ((request->orders[oidx].assays[aidx].aborh_verify_yn="Y")
        AND (request->orders[oidx].assays[aidx].bb_result_code_set_cd > 0)
        AND (modproductlist->product[midx].product_id=mod_product_id))
        SET donor_aborh_id = 0.0
        IF (update_donor_aborh(0)=1)
         IF ((request->orders[oidx].assays[aidx].upd_don_hist_aborh_yn="Y"))
          SET reply->orders[oidx].assays[aidx].new_abo_cd = request->orders[oidx].assays[aidx].
          new_abo_cd
          SET reply->orders[oidx].assays[aidx].new_rh_cd = request->orders[oidx].assays[aidx].
          new_rh_cd
         ENDIF
        ELSE
         IF (gsub_donor_aborh_status="FS")
          SET failed = "T"
          SET status_count = (status_count+ 1)
          IF (status_count > 1)
           SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
          ENDIF
          SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
          SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
          SET reply->status_data.subeventstatus[status_count].targetobjectname = "Donor Aborh"
          SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
          "Unable to insert donor_aborh due to aborh id"
         ELSEIF (gsub_donor_aborh_status="FA")
          SET failed = "T"
          SET status_count = (status_count+ 1)
          IF (status_count > 1)
           SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
          ENDIF
          SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
          SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
          SET reply->status_data.subeventstatus[status_count].targetobjectname = "Donor Aborh"
          SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
          "Unable to insert donor aborh"
         ENDIF
         IF (gsub_donor_aborh_inact_status="FL")
          SET failed = "T"
          SET status_count = (status_count+ 1)
          IF (status_count > 1)
           SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
          ENDIF
          SET reply->status_data.subeventstatus[status_count].operationname = "LOCK"
          SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
          SET reply->status_data.subeventstatus[status_count].targetobjectname = "Donor Aborh"
          SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
          "Unable to lock donor_aborh for update"
         ELSEIF (gsub_donor_aborh_inact_status="FU")
          SET failed = "T"
          SET status_count = (status_count+ 1)
          IF (status_count > 1)
           SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
          ENDIF
          SET reply->status_data.subeventstatus[status_count].operationname = "CHANGE"
          SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
          SET reply->status_data.subeventstatus[status_count].targetobjectname = "Donor Aborh"
          SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
          "Unable to inactivate donor aborh"
         ENDIF
         IF (gsub_aborh_result_status="FP")
          SET failed = "T"
          SET status_count = (status_count+ 1)
          IF (status_count > 1)
           SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
          ENDIF
          SET reply->status_data.subeventstatus[status_count].operationname = "select"
          SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
          SET reply->status_data.subeventstatus[status_count].targetobjectname = "Donor Aborh"
          SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
          "Unable to find active person record on donor_aborh"
         ELSEIF (gsub_aborh_result_status="FS")
          SET failed = "T"
          SET status_count = (status_count+ 1)
          IF (status_count > 1)
           SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
          ENDIF
          SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
          SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
          SET reply->status_data.subeventstatus[status_count].targetobjectname = "Aborh Result"
          SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
          "Unable to insert aborh result due to next sequence number"
         ELSEIF (gsub_aborh_result_status="FA")
          SET failed = "T"
          SET status_count = (status_count+ 1)
          IF (status_count > 1)
           SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
          ENDIF
          SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
          SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
          SET reply->status_data.subeventstatus[status_count].targetobjectname = "Aborh Result"
          SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
          "Unable to insert aborh result"
         ENDIF
         GO TO exit_script
        ENDIF
       ENDIF
       IF ((request->orders[oidx].assays[aidx].product_rh_phenotype_verify_yn="Y")
        AND (request->orders[oidx].assays[aidx].nomenclature_id > 0)
        AND (modproductlist->product[midx].product_id=mod_product_id))
        SET new_special_testing_id = 0.0
        IF ((request->orders[oidx].assays[aidx].upd_product_rh_phenotype_yn="Y"))
         IF ((request->orders[oidx].assays[aidx].product_rh_phenotype_id > 0))
          CALL chg_product_rh_phenotype(request->orders[oidx].assays[aidx].product_rh_phenotype_id,
           request->orders[oidx].assays[aidx].product_rh_phenotype_updt_cnt,0,reqdata->
           inactive_status_cd)
          IF (gsub_rh_phenotype_status="FL")
           SET failed = "T"
           SET status_count = (status_count+ 1)
           IF (status_count > 1)
            SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
           ENDIF
           SET reply->status_data.subeventstatus[status_count].operationname = "SELECT forupdate"
           SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
           SET reply->status_data.subeventstatus[status_count].targetobjectname =
           "product_rh_phenotype"
           SET reply->status_data.subeventstatus[status_count].targetobjectvalue = concat(
            "Lock product_rh_phenotype row for update failed for product_rh_phenotype_id = ",
            cnvtstring(request->orders[oidx].assays[aidx].product_rh_phenotype_id),", updt_id = ",
            cnvtstring(request->orders[oidx].assays[aidx].product_rh_phenotype_updt_cnt),
            ", order_id =",
            cnvtstring(request->orders[oidx].order_id))
           GO TO exit_script
          ELSEIF (gsub_rh_phenotype_status="FU")
           SET failed = "T"
           SET status_count = (status_count+ 1)
           IF (status_count > 1)
            SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
           ENDIF
           SET reply->status_data.subeventstatus[status_count].operationname = "UPDATE"
           SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
           SET reply->status_data.subeventstatus[status_count].targetobjectname =
           "product_rh_phenotype"
           SET reply->status_data.subeventstatus[status_count].targetobjectvalue = concat(
            "Update into product_rh_phenotype failed product_rh_phenotype_id = ",cnvtstring(request->
             orders[oidx].assays[aidx].product_rh_phenotype_id),", updt_id = ",cnvtstring(request->
             orders[oidx].assays[aidx].product_rh_phenotype_updt_cnt),", order_id =",
            cnvtstring(request->orders[oidx].order_id))
           GO TO exit_script
          ENDIF
          SET rh_a_cnt = request->orders[oidx].assays[aidx].product_rh_antigen_cnt
          FOR (rh_a = 1 TO rh_a_cnt)
           CALL chg_special_testing_by_key(request->orders[oidx].assays[aidx].product_rh_antigenlist[
            rh_a].table_id,request->orders[oidx].assays[aidx].product_rh_antigenlist[rh_a].updt_cnt,0,
            reqdata->inactive_status_cd)
           IF (gsub_rh_phenotype_status="FL")
            SET failed = "T"
            SET status_count = (status_count+ 1)
            IF (status_count > 1)
             SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
            ENDIF
            SET reply->status_data.subeventstatus[status_count].operationname = "SELECT forupdate"
            SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
            SET reply->status_data.subeventstatus[status_count].targetobjectname = "special_testing"
            SET reply->status_data.subeventstatus[status_count].targetobjectvalue = concat(
             "Lock special_testing row for update failed for special_testing_id = ",cnvtstring(
              request->orders[oidx].assays[aidx].product_rh_antigenlist[rh_a].table_id),
             ", updt_cnt = ",cnvtstring(request->orders[oidx].assays[aidx].product_rh_antigenlist[
              rh_a].updt_cnt),", order_id = ",
             cnvtstring(request->orders[oidx].order_id))
            GO TO exit_script
           ELSEIF (gsub_rh_phenotype_status="FU")
            SET failed = "T"
            SET status_count = (status_count+ 1)
            IF (status_count > 1)
             SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
            ENDIF
            SET reply->status_data.subeventstatus[status_count].operationname = "UPDATE"
            SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
            SET reply->status_data.subeventstatus[status_count].targetobjectname = "special_testing"
            SET reply->status_data.subeventstatus[status_count].targetobjectvalue = concat(
             "Update into special_testing failed for special_testing_id = ",cnvtstring(request->
              orders[oidx].assays[aidx].product_rh_antigenlist[rh_a].table_id),", updt_cnt = ",
             cnvtstring(request->orders[oidx].assays[aidx].product_rh_antigenlist[rh_a].updt_cnt),
             ", order_id = ",
             cnvtstring(request->orders[oidx].order_id))
            GO TO exit_script
           ENDIF
          ENDFOR
         ENDIF
         SET gsub_bbd_rh_phenotype_status = "  "
         SET rh_a_cnt = size(rh_a_rec->antigenlist,5)
         IF (rh_a_cnt > 0)
          FOR (rh_a = 1 TO rh_a_cnt)
            SET rh_a_rec->antigenlist[rh_a].antigen_cd = 0.0
            SET rh_a_rec->antigenlist[rh_a].opposite_cd = 0.0
            SET rh_a_rec->antigenlist[rh_a].post_to_donor_ind = 0
          ENDFOR
          SET stat = alterlist(rh_a_rec->antigenlist,0)
         ENDIF
         CALL bbd_get_rh_phenotype_antigens(request->orders[oidx].assays[aidx].nomenclature_id)
         IF (gsub_bbd_rh_phenotype_status != "OK")
          SET failed = "T"
          SET status_count = (status_count+ 1)
          IF (status_count > 1)
           SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
          ENDIF
          SET reply->status_data.subeventstatus[status_count].operationname = "SELECT"
          SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
          SET reply->status_data.subeventstatus[status_count].targetobjectname = "bb_rh_phenotype"
          SET reply->status_data.subeventstatus[status_count].targetobjectvalue = concat(
           "rh_phenotype select failed for nomenclature_id = ",cnvtstring(request->orders[oidx].
            assays[aidx].nomenclature_id),", for order_id = ",cnvtstring(request->orders[oidx].
            order_id),".  No results added/updated.")
          GO TO exit_script
         ENDIF
         SET rh_cnt = 0
         SET rh_a_cnt = size(rh_a_rec->antigenlist,5)
         SELECT INTO "nl:"
          FROM code_value cv,
           code_value_extension cve,
           (dummyt d  WITH seq = value(rh_a_cnt))
          PLAN (d)
           JOIN (cv
           WHERE (cv.code_value=rh_a_rec->antigenlist[d.seq].antigen_cd)
            AND cv.code_set=special_testing_code_set
            AND ((cv.cdf_meaning="-") OR (cv.cdf_meaning="+"))
            AND cv.active_ind=1)
           JOIN (cve
           WHERE cve.code_value=cv.code_value
            AND cve.field_name="Opposite")
          HEAD cve.code_value
           rh_cnt = (rh_cnt+ 1)
          DETAIL
           IF (cve.field_name="Opposite")
            rh_a_rec->antigenlist[rh_cnt].opposite_cd = cnvtreal(cve.field_value)
           ENDIF
          WITH nocounter
         ;end select
         IF (rh_a_cnt != rh_cnt)
          SET failed = "T"
          SET status_count = (status_count+ 1)
          IF (status_count > 1)
           SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
          ENDIF
          SET reply->status_data.subeventstatus[status_count].operationname = "SELECT"
          SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
          SET reply->status_data.subeventstatus[status_count].targetobjectname =
          "code_value_extension"
          SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
          "Could not load opposites or posting to donor indicator.  No results added/updated."
          GO TO exit_script
         ENDIF
         SET opposite_found_ind = 0
         SELECT INTO "nl:"
          FROM special_testing st,
           (dummyt d  WITH seq = value(rh_a_cnt))
          PLAN (d
           WHERE (rh_a_rec->antigenlist[d.seq].opposite_cd > 0.0))
           JOIN (st
           WHERE (st.product_id=modproductlist->product[midx].product_id)
            AND (st.special_testing_cd=rh_a_rec->antigenlist[d.seq].opposite_cd)
            AND st.active_ind=1)
          DETAIL
           opposite_found_ind = 1
          WITH nocounter
         ;end select
         IF (opposite_found_ind=1)
          SET reply->opposite_found_product_id = modproductlist->product[midx].product_id
          SET reply->opposite_found_order_id = request->orders[oidx].order_id
          SET reply->opposite_found_assay_id = request->orders[oidx].assays[aidx].task_assay_cd
          SET reply->opposite_found_prfrm_rslt_key = request->orders[oidx].assays[aidx].
          perform_result_key
          SET failed = "T"
          SET reply->status_data.status = "Z"
          SET status_count = (status_count+ 1)
          IF (status_count > 1)
           SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
          ENDIF
          SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
          SET reply->status_data.subeventstatus[status_count].operationstatus = "Z"
          SET reply->status_data.subeventstatus[status_count].targetobjectname = "Special Testing"
          SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
          "Unable to insert special testing because opposite already exists on product."
          GO TO exit_script
         ENDIF
         SET gsub_rh_phenotype_status = "  "
         CALL add_product_rh_phenotype(request->orders[oidx].assays[aidx].product_id,request->orders[
          oidx].assays[aidx].nomenclature_id,1,reqdata->active_status_cd,cnvtdatetime(curdate,
           curtime3),
          reqinfo->updt_id)
         IF (gsub_rh_phenotype_status="FZ")
          SET failed = "T"
          SET status_count = (status_count+ 1)
          IF (status_count > 1)
           SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
          ENDIF
          SET reply->status_data.subeventstatus[status_count].operationname = "SELECT"
          SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
          SET reply->status_data.subeventstatus[status_count].targetobjectname =
          "bb_rh_phenotype product1"
          SET reply->status_data.subeventstatus[status_count].targetobjectvalue = concat(
           "No rows exist on bb_rh_phenotype for resulted nomenclature_id for order_id = ",cnvtstring
           (request->orders[oidx].order_id),".  Could not retrieve rh_phenotype_id")
          GO TO exit_script
         ELSEIF (gsub_rh_phenotype_status="FM")
          SET failed = "T"
          SET status_count = (status_count+ 1)
          IF (status_count > 1)
           SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
          ENDIF
          SET reply->status_data.subeventstatus[status_count].operationname = "SELECT"
          SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
          SET reply->status_data.subeventstatus[status_count].targetobjectname =
          "bb_rh_phenotype product2"
          SET reply->status_data.subeventstatus[status_count].targetobjectvalue = concat(
           "Multiple bb_rh_phenotype rows found for resulted nomenclature_id for order_id = ",
           cnvtstring(request->orders[oidx].order_id),".  Could not retrieve rh_phenotype_id")
          GO TO exit_script
         ELSEIF (gsub_rh_phenotype_status="FF")
          SET failed = "T"
          SET status_count = (status_count+ 1)
          IF (status_count > 1)
           SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
          ENDIF
          SET reply->status_data.subeventstatus[status_count].operationname = "SELECT"
          SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
          SET reply->status_data.subeventstatus[status_count].targetobjectname =
          "bb_rh_phenotype product3"
          SET reply->status_data.subeventstatus[status_count].targetobjectvalue = concat(
           "CCL error.  Select failed on bb_rh_phenotype table ",
           "for resulted nomenclature_id for order_id = ",cnvtstring(request->orders[oidx].order_id),
           ".  Could not retrieve rh_phenotype_id")
          GO TO exit_script
         ELSEIF (gsub_rh_phenotype_status="FS")
          SET failed = "T"
          SET status_count = (status_count+ 1)
          IF (status_count > 1)
           SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
          ENDIF
          SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
          SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
          SET reply->status_data.subeventstatus[status_count].targetobjectname =
          "product_rh_phenotype"
          SET reply->status_data.subeventstatus[status_count].targetobjectvalue = concat(
           "Could not insert product_rh_phenotype row--get next pathnet_seq",
           "for id failed for order_id = ",cnvtstring(request->orders[oidx].order_id))
          GO TO exit_script
         ELSEIF (gsub_rh_phenotype_status="FA")
          SET failed = "T"
          SET status_count = (status_count+ 1)
          IF (status_count > 1)
           SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
          ENDIF
          SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
          SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
          SET reply->status_data.subeventstatus[status_count].targetobjectname =
          "product_rh_phenotype"
          SET reply->status_data.subeventstatus[status_count].targetobjectvalue = concat(
           "Insert product_rh_phenotype row failed for order_id = ",cnvtstring(request->orders[oidx].
            order_id))
          GO TO exit_script
         ELSEIF (gsub_rh_phenotype_status != "OK")
          SET failed = "T"
          SET status_count = (status_count+ 1)
          IF (status_count > 1)
           SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
          ENDIF
          SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
          SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
          SET reply->status_data.subeventstatus[status_count].targetobjectname =
          "product_rh_phenotype"
          SET reply->status_data.subeventstatus[status_count].targetobjectvalue = concat(
           "Could not insert product_rh_phenotype row due to invalid insert status (",
           gsub_rh_phenotype_status,") for order_id = ",cnvtstring(request->orders[oidx].order_id))
          GO TO exit_script
         ENDIF
         SET new_product_rh_phenotype_id = new_rh_phenotype_id
         SET gsub_rh_phenotype_status = "  "
         CALL get_rh_phenotype_antigens(bb_rh_phenotype_id)
         IF (gsub_rh_phenotype_status != "OK")
          SET failed = "T"
          SET status_count = (status_count+ 1)
          IF (status_count > 1)
           SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
          ENDIF
          SET reply->status_data.subeventstatus[status_count].operationname = "SELECT"
          SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
          SET reply->status_data.subeventstatus[status_count].targetobjectname =
          "product_rh_phenotype"
          SET reply->status_data.subeventstatus[status_count].targetobjectvalue = concat(
           "rh_phenotype select failed for nomenclature_id = ",cnvtstring(request->orders[oidx].
            assays[aidx].nomenclature_id),", for order_id = ",cnvtstring(request->orders[oidx].
            order_id),".  No results added/updated.")
          GO TO exit_script
         ENDIF
         SET rh_a_cnt = size(rh_a_rec->antigenlist,5)
         FOR (rh_a = 1 TO rh_a_cnt)
           SET gsub_special_testing_status = "  "
           CALL add_special_testing(modproductlist->product[midx].product_id,rh_a_rec->antigenlist[
            rh_a].antigen_cd,1,new_product_rh_phenotype_id,1,
            reqdata->active_status_cd,cnvtdatetime(curdate,curtime3),reqinfo->updt_id,"N")
           IF (gsub_special_testing_status="FS")
            SET failed = "T"
            SET status_count = (status_count+ 1)
            IF (status_count > 1)
             SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
            ENDIF
            SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
            SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
            SET reply->status_data.subeventstatus[status_count].targetobjectname = "special_testing"
            SET reply->status_data.subeventstatus[status_count].targetobjectvalue = concat(
             "Could not insert special_testing row--get next pathnet_seq for id failed ",
             "for order_id = ",cnvtstring(request->orders[oidx].order_id))
            GO TO exit_script
           ELSEIF (gsub_special_testing_status="FA")
            SET failed = "T"
            SET status_count = (status_count+ 1)
            IF (status_count > 1)
             SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
            ENDIF
            SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
            SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
            SET reply->status_data.subeventstatus[status_count].targetobjectname = "special_testing"
            SET reply->status_data.subeventstatus[status_count].targetobjectvalue = concat(
             "Insert special_testing row failed for order_id = ",cnvtstring(request->orders[oidx].
              order_id))
            GO TO exit_script
           ELSEIF (gsub_special_testing_status != "OK")
            SET failed = "T"
            SET status_count = (status_count+ 1)
            IF (status_count > 1)
             SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
            ENDIF
            SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
            SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
            SET reply->status_data.subeventstatus[status_count].targetobjectname = "special_testing"
            SET reply->status_data.subeventstatus[status_count].targetobjectvalue = concat(
             "Could not insert special_testing row due to invalid insert status (",
             gsub_special_testing_status,") for order_id = ",cnvtstring(request->orders[oidx].
              order_id))
            GO TO exit_script
           ENDIF
           CALL add_special_testing_result(new_special_testing_id,modproductlist->product[midx].
            product_id,reply->orders[oidx].assays[aidx].result_id,0.0,1,
            reqdata->active_status_cd,cnvtdatetime(current->system_dt_tm),request->event_personnel_id
            )
           IF (gsub_spc_tst_result_status != "OK")
            IF (gsub_spc_tst_result_status="FA")
             SET failed = "T"
             SET status_count = (status_count+ 1)
             IF (status_count > 1)
              SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
             ENDIF
             SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
             SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
             SET reply->status_data.subeventstatus[status_count].targetobjectname =
             "Special Testing Result"
             SET reply->status_data.subeventstatus[status_count].targetobjectvalue = concat(
              "Insert special_testing_result row failed for order_id = ",cnvtstring(request->orders[
               oidx].order_id),", product_id = ",request->orders[oidx].assays[aidx].product_id)
             SET failed = "T"
             SET status_count = (status_count+ 1)
             IF (status_count > 1)
              SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
             ENDIF
            ELSE
             SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
             SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
             SET reply->status_data.subeventstatus[status_count].targetobjectname =
             "Special Testing Result"
             SET reply->status_data.subeventstatus[status_count].targetobjectvalue = concat(
              "Insert special_testing_result row failed for order_id = ",cnvtstring(request->orders[
               oidx].order_id),", product_id = ",request->orders[oidx].assays[aidx].product_id)
            ENDIF
            GO TO exit_script
           ENDIF
         ENDFOR
        ENDIF
       ENDIF
       IF ((request->orders[oidx].assays[aidx].donor_rh_phenotype_verify_yn="Y")
        AND (request->orders[oidx].assays[aidx].nomenclature_id > 0)
        AND (modproductlist->product[midx].product_id=mod_product_id))
        IF ((request->orders[oidx].assays[aidx].upd_product_rh_phenotype_yn="Y"))
         IF ((request->orders[oidx].assays[aidx].product_rh_phenotype_id > 0))
          SET rh_a_cnt = request->orders[oidx].assays[aidx].product_rh_antigen_cnt
          FOR (rh_a = 1 TO rh_a_cnt)
            SET antigen_exist_ind = 0
            SET old_donor_antigen_id = 0.0
            SELECT INTO "nl:"
             FROM special_testing_result str,
              special_testing st,
              donor_antigen da
             PLAN (str
              WHERE (str.special_testing_id=request->orders[oidx].assays[aidx].
              product_rh_antigenlist[rh_a].table_id))
              JOIN (st
              WHERE st.special_testing_id=str.special_testing_id)
              JOIN (da
              WHERE (da.person_id=request->orders[oidx].person_id)
               AND da.result_id=str.result_id
               AND da.antigen_cd=st.special_testing_cd)
             DETAIL
              old_donor_antigen_id = da.donor_antigen_id
             WITH nocounter
            ;end select
            IF (curqual > 0)
             SET antigen_exist_ind = 1
            ENDIF
            IF (antigen_exist_ind=1)
             SET stat = chg_donor_antigen_by_key(old_donor_antigen_id,request->orders[oidx].assays[
              aidx].product_rh_antigenlist[rh_a].updt_cnt,0,reqdata->inactive_status_cd)
             IF (stat=1)
              SET gsub_donor_rh_phenotype_status = "OK"
             ELSEIF (stat=2)
              SET gsub_donor_rh_phenotype_status = "FL"
             ELSE
              SET gsub_donor_rh_phenotype_status = "FU"
             ENDIF
             IF (gsub_donor_rh_phenotype_status="FL")
              SET failed = "T"
              SET status_count = (status_count+ 1)
              IF (status_count > 1)
               SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
              ENDIF
              SET reply->status_data.subeventstatus[status_count].operationname = "SELECT forupdate"
              SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
              SET reply->status_data.subeventstatus[status_count].targetobjectname = "donor_antigen"
              SET reply->status_data.subeventstatus[status_count].targetobjectvalue = concat(
               "Lock donor_antigen row for update failed for donor_antigen_id = ",cnvtstring(request
                ->orders[oidx].assays[aidx].rh_antigenlist[rh_a].table_id),", updt_cnt = ",cnvtstring
               (request->orders[oidx].assays[aidx].rh_antigenlist[rh_a].updt_cnt),", order_id = ",
               cnvtstring(request->orders[oidx].order_id))
              GO TO exit_script
             ELSEIF (gsub_donor_rh_phenotype_status="FU")
              SET failed = "T"
              SET status_count = (status_count+ 1)
              IF (status_count > 1)
               SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
              ENDIF
              SET reply->status_data.subeventstatus[status_count].operationname = "UPDATE"
              SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
              SET reply->status_data.subeventstatus[status_count].targetobjectname =
              "donor_rh_phenotype"
              SET reply->status_data.subeventstatus[status_count].targetobjectvalue = concat(
               "Update into donor_antigen failed for donor_antigen_id = ",cnvtstring(request->orders[
                oidx].assays[aidx].rh_antigenlist[rh_a].table_id),", updt_cnt = ",cnvtstring(request
                ->orders[oidx].assays[aidx].rh_antigenlist[rh_a].updt_cnt),", order_id = ",
               cnvtstring(request->orders[oidx].order_id))
              GO TO exit_script
             ENDIF
            ENDIF
          ENDFOR
         ENDIF
         SET gsub_rh_phenotype_status = "  "
         SET rh_a_cnt = size(rh_a_rec->antigenlist,5)
         IF (rh_a_cnt > 0)
          FOR (rh_a = 1 TO rh_a_cnt)
            SET rh_a_rec->antigenlist[rh_a].antigen_cd = 0.0
            SET rh_a_rec->antigenlist[rh_a].opposite_cd = 0.0
            SET rh_a_rec->antigenlist[rh_a].post_to_donor_ind = 0
          ENDFOR
          SET stat = alterlist(rh_a_rec->antigenlist,0)
         ENDIF
         CALL get_rh_phenotype_antigens(bb_rh_phenotype_id)
         IF (gsub_rh_phenotype_status != "OK")
          SET failed = "T"
          SET status_count = (status_count+ 1)
          IF (status_count > 1)
           SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
          ENDIF
          SET reply->status_data.subeventstatus[status_count].operationname = "SELECT"
          SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
          SET reply->status_data.subeventstatus[status_count].targetobjectname = "bb_rh_phenotype"
          SET reply->status_data.subeventstatus[status_count].targetobjectvalue = concat(
           "rh_phenotype select failed for nomenclature_id = ",cnvtstring(request->orders[oidx].
            assays[aidx].nomenclature_id),", for order_id = ",cnvtstring(request->orders[oidx].
            order_id),".  No results added/updated.")
          GO TO exit_script
         ENDIF
         SET rh_cnt = 0
         SET rh_a_cnt = size(rh_a_rec->antigenlist,5)
         SELECT INTO "nl:"
          FROM code_value cv,
           code_value_extension cve,
           (dummyt d  WITH seq = value(rh_a_cnt))
          PLAN (d)
           JOIN (cv
           WHERE (cv.code_value=rh_a_rec->antigenlist[d.seq].antigen_cd)
            AND cv.code_set=special_testing_code_set
            AND ((cv.cdf_meaning="-") OR (cv.cdf_meaning="+"))
            AND cv.active_ind=1)
           JOIN (cve
           WHERE cve.code_value=cv.code_value
            AND ((cve.field_name="Opposite") OR (cve.field_name="PostToDonor")) )
          HEAD cve.code_value
           rh_cnt = (rh_cnt+ 1)
          DETAIL
           IF (cve.field_name="Opposite")
            rh_a_rec->antigenlist[rh_cnt].opposite_cd = cnvtreal(cve.field_value)
           ENDIF
           IF (cve.field_name="PostToDonor")
            rh_a_rec->antigenlist[rh_cnt].post_to_donor_ind = cnvtint(cve.field_value)
           ENDIF
          WITH nocounter
         ;end select
         IF (rh_a_cnt != rh_cnt)
          SET failed = "T"
          SET status_count = (status_count+ 1)
          IF (status_count > 1)
           SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
          ENDIF
          SET reply->status_data.subeventstatus[status_count].operationname = "SELECT"
          SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
          SET reply->status_data.subeventstatus[status_count].targetobjectname =
          "code_value_extension"
          SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
          "Could not load opposites or posting to donor indicator.  No results added/updated."
          GO TO exit_script
         ENDIF
         SET rh_a_cnt = size(rh_a_rec->antigenlist,5)
         FOR (rh_a = 1 TO rh_a_cnt)
           IF ((rh_a_rec->antigenlist[rh_a].post_to_donor_ind=1))
            SET opposite_found_ind = 0
            SELECT INTO "nl:"
             FROM encounter e,
              donor_antigen da,
              (dummyt d  WITH seq = value(rh_a_cnt))
             PLAN (d
              WHERE (rh_a_rec->antigenlist[d.seq].opposite_cd > 0.0))
              JOIN (e
              WHERE (e.person_id=request->orders[oidx].person_id))
              JOIN (da
              WHERE da.encntr_id=e.encntr_id
               AND (da.antigen_cd=rh_a_rec->antigenlist[d.seq].opposite_cd)
               AND da.active_ind=1)
             DETAIL
              opposite_found_ind = 1
             WITH nocounter
            ;end select
            IF (opposite_found_ind=1)
             SET reply->opposite_found_person_id = request->orders[oidx].person_id
             SET reply->opposite_found_order_id = request->orders[oidx].order_id
             SET reply->opposite_found_assay_id = request->orders[oidx].assays[aidx].task_assay_cd
             SET reply->opposite_found_prfrm_rslt_key = request->orders[oidx].assays[aidx].
             perform_result_key
             SET failed = "T"
             SET reply->status_data.status = "Z"
             SET status_count = (status_count+ 1)
             IF (status_count > 1)
              SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
             ENDIF
             SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
             SET reply->status_data.subeventstatus[status_count].operationstatus = "Z"
             SET reply->status_data.subeventstatus[status_count].targetobjectname = "Donor Antigen"
             SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
             "Unable to insert donor antigen because opposite already exists on donor."
             GO TO exit_script
            ENDIF
            SET gsub_donor_antigen_status = "  "
            SET stat = add_donor_antigen(request->orders[oidx].person_id,request->orders[oidx].
             encntr_id,rh_a_rec->antigenlist[rh_a].antigen_cd,reply->orders[oidx].assays[aidx].
             result_id,bb_result_seq,
             0.0,1,reqdata->active_status_cd,cnvtdatetime(curdate,curtime3),reqinfo->updt_id,
             reqdata->contributor_system_cd)
            IF (stat=1)
             SET gsub_donor_antigen_status = "OK"
            ELSEIF (stat=0)
             SET gsub_donor_antigen_status = "FA"
            ELSE
             SET gsub_donor_antigen_status = "FS"
            ENDIF
            IF (gsub_donor_antigen_status="FS")
             SET failed = "T"
             SET status_count = (status_count+ 1)
             IF (status_count > 1)
              SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
             ENDIF
             SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
             SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
             SET reply->status_data.subeventstatus[status_count].targetobjectname = "donor_antigen"
             SET reply->status_data.subeventstatus[status_count].targetobjectvalue = concat(
              "Could not insert donor_antigen row--get next pathnet_seq for id failed ",
              "for order_id = ",cnvtstring(request->orders[oidx].order_id))
             GO TO exit_script
            ELSEIF (gsub_donor_antigen_status="FA")
             SET failed = "T"
             SET status_count = (status_count+ 1)
             IF (status_count > 1)
              SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
             ENDIF
             SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
             SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
             SET reply->status_data.subeventstatus[status_count].targetobjectname = "donor_antigen"
             SET reply->status_data.subeventstatus[status_count].targetobjectvalue = concat(
              "Insert donor_antigen row failed for order_id = ",cnvtstring(request->orders[oidx].
               order_id))
             GO TO exit_script
            ELSEIF (gsub_donor_antigen_status != "OK")
             SET failed = "T"
             SET status_count = (status_count+ 1)
             IF (status_count > 1)
              SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
             ENDIF
             SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
             SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
             SET reply->status_data.subeventstatus[status_count].targetobjectname = "donor_antigen"
             SET reply->status_data.subeventstatus[status_count].targetobjectvalue = concat(
              "Could not insert donor_antigen row due to invalid insert status (",
              gsub_donor_antigen_status,") for order_id = ",cnvtstring(request->orders[oidx].order_id
               ))
             GO TO exit_script
            ENDIF
           ENDIF
         ENDFOR
        ENDIF
       ENDIF
       IF ((request->orders[oidx].assays[aidx].special_testing_verify_yn="Y")
        AND (request->orders[oidx].assays[aidx].bb_result_code_set_cd > 0))
        SET new_special_testing_id = 0.0
        SET gsub_special_testing_status = "  "
        SET gsub_spc_tst_result_status = "  "
        SET opposite_found_ind = 0
        SELECT INTO "nl:"
         FROM special_testing st,
          code_value cv,
          code_value_extension cve
         PLAN (st
          WHERE (st.product_id=modproductlist->product[midx].product_id)
           AND st.active_ind=1)
          JOIN (cv
          WHERE cv.code_set=1612
           AND cv.code_value=st.special_testing_cd
           AND ((cv.cdf_meaning="-") OR (cv.cdf_meaning="+")) )
          JOIN (cve
          WHERE cve.code_set=cv.code_set
           AND cve.code_value=cv.code_value
           AND cve.field_name="Opposite")
         HEAD REPORT
          found_ind = 0
         DETAIL
          IF ((cnvtreal(cve.field_value)=request->orders[oidx].assays[aidx].bb_result_code_set_cd))
           found_ind = 1
          ENDIF
         FOOT REPORT
          opposite_found_ind = found_ind
         WITH nocounter
        ;end select
        IF (opposite_found_ind=1)
         SET reply->opposite_found_product_id = modproductlist->product[midx].product_id
         SET reply->opposite_found_order_id = request->orders[oidx].order_id
         SET reply->opposite_found_assay_id = request->orders[oidx].assays[aidx].task_assay_cd
         SET reply->opposite_found_prfrm_rslt_key = request->orders[oidx].assays[aidx].
         perform_result_key
         SET failed = "T"
         SET reply->status_data.status = "Z"
         SET status_count = (status_count+ 1)
         IF (status_count > 1)
          SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
         ENDIF
         SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
         SET reply->status_data.subeventstatus[status_count].operationstatus = "Z"
         SET reply->status_data.subeventstatus[status_count].targetobjectname = "Special Testing"
         SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
         "Unable to insert special testing because opposite already exists on product."
         GO TO exit_script
        ELSE
         CALL add_special_testing(modproductlist->product[midx].product_id,request->orders[oidx].
          assays[aidx].bb_result_code_set_cd,1,0.0,1,
          reqdata->active_status_cd,cnvtdatetime(current->system_dt_tm),request->event_personnel_id,
          "Y")
         IF (gsub_special_testing_status != "OK")
          IF (gsub_special_testing_status="FS")
           SET failed = "T"
           SET status_count = (status_count+ 1)
           IF (status_count > 1)
            SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
           ENDIF
           SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
           SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
           SET reply->status_data.subeventstatus[status_count].targetobjectname = "Special Testing"
           SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
           "Unable to insert special testing due to special testing id"
          ELSEIF (gsub_special_testing_status="FA")
           SET failed = "T"
           SET status_count = (status_count+ 1)
           IF (status_count > 1)
            SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
           ENDIF
           SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
           SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
           SET reply->status_data.subeventstatus[status_count].targetobjectname = "Special_testing"
           SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
           "Unable to insert special testing"
          ELSEIF (gsub_special_testing_status="FL")
           SET failed = "T"
           SET status_count = (status_count+ 1)
           IF (status_count > 1)
            SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
           ENDIF
           SET reply->status_data.subeventstatus[status_count].operationname = "LOCK"
           SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
           SET reply->status_data.subeventstatus[status_count].targetobjectname = "Special Testing"
           SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
           "Unable to lock special testing for update"
          ELSEIF (gsub_special_testing_status="FU")
           SET failed = "T"
           SET status_count = (status_count+ 1)
           IF (status_count > 1)
            SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
           ENDIF
           SET reply->status_data.subeventstatus[status_count].operationname = "CHANGE"
           SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
           SET reply->status_data.subeventstatus[status_count].targetobjectname = "Special Testing"
           SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
           "Unable to mark confirmed on Special Testing"
          ENDIF
          GO TO exit_script
         ENDIF
         CALL add_special_testing_result(new_special_testing_id,modproductlist->product[midx].
          product_id,reply->orders[oidx].assays[aidx].result_id,bb_result_seq,1,
          reqdata->active_status_cd,cnvtdatetime(current->system_dt_tm),request->event_personnel_id)
         IF (gsub_spc_tst_result_status != "OK")
          IF (gsub_spc_tst_result_status="FA")
           SET failed = "T"
           SET status_count = (status_count+ 1)
           IF (status_count > 1)
            SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
           ENDIF
           SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
           SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
           SET reply->status_data.subeventstatus[status_count].targetobjectname =
           "Special Testing Result"
           SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
           "Unable to insert special Testing Result"
          ENDIF
          GO TO exit_script
         ENDIF
        ENDIF
       ENDIF
       IF ((request->orders[oidx].assays[aidx].antigen_verify_yn="Y")
        AND (request->orders[oidx].assays[aidx].bb_result_code_set_cd > 0)
        AND (modproductlist->product[midx].product_id=mod_product_id))
        SET post_to_donor_ind = 0
        SELECT INTO "nl:"
         FROM code_value cv,
          code_value_extension cve
         PLAN (cv
          WHERE cv.code_set=1612
           AND (cv.code_value=request->orders[oidx].assays[aidx].bb_result_code_set_cd)
           AND cv.active_ind=1)
          JOIN (cve
          WHERE cve.code_set=cv.code_set
           AND cve.code_value=cv.code_value
           AND cve.field_name="PostToDonor")
         DETAIL
          post_to_donor_ind = cnvtint(cve.field_value)
         WITH nocounter
        ;end select
        IF (curqual=0)
         SET failed = "T"
         SET status_count = (status_count+ 1)
         IF (status_count > 1)
          SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
         ENDIF
         SET reply->status_data.subeventstatus[status_count].operationname = "SELECT"
         SET reply->status_data.subeventstatus[status_count].operationstatus = "Z"
         SET reply->status_data.subeventstatus[status_count].targetobjectname =
         "code_value_extension 2"
         SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
         "Could not load posting to donor indicator.  No donor antigen added."
        ENDIF
        IF (post_to_donor_ind=1)
         SET opposite_found_ind = 0
         SELECT INTO "nl:"
          FROM encounter e,
           donor_antigen da,
           code_value cv,
           code_value_extension cve
          PLAN (e
           WHERE (e.person_id=request->orders[oidx].person_id))
           JOIN (da
           WHERE da.encntr_id=e.encntr_id
            AND da.active_ind=1)
           JOIN (cv
           WHERE cv.code_set=1612
            AND cv.code_value=da.antigen_cd
            AND ((cv.cdf_meaning="-") OR (cv.cdf_meaning="+"))
            AND cv.active_ind=1)
           JOIN (cve
           WHERE cve.code_set=cv.code_set
            AND cve.code_value=cv.code_value
            AND cve.field_name="Opposite")
          DETAIL
           IF ((cnvtreal(cve.field_value)=request->orders[oidx].assays[aidx].bb_result_code_set_cd))
            opposite_found_ind = 1
           ENDIF
          WITH nocounter
         ;end select
         IF (opposite_found_ind=1)
          SET reply->opposite_found_person_id = request->orders[oidx].person_id
          SET reply->opposite_found_order_id = request->orders[oidx].order_id
          SET reply->opposite_found_assay_id = request->orders[oidx].assays[aidx].task_assay_cd
          SET reply->opposite_found_prfrm_rslt_key = request->orders[oidx].assays[aidx].
          perform_result_key
          SET failed = "T"
          SET status_count = (status_count+ 1)
          SET reply->status_data.status = "Z"
          IF (status_count > 1)
           SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
          ENDIF
          SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
          SET reply->status_data.subeventstatus[status_count].operationstatus = "Z"
          SET reply->status_data.subeventstatus[status_count].targetobjectname = "Donor Antigen"
          SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
          "Unable to insert donor antigen because opposite already exists on donor."
          GO TO exit_script
         ENDIF
         SET gsub_donor_antigen_status = "  "
         SET stat = add_donor_antigen(request->orders[oidx].person_id,request->orders[oidx].encntr_id,
          request->orders[oidx].assays[aidx].bb_result_code_set_cd,reply->orders[oidx].assays[aidx].
          result_id,bb_result_seq,
          0.0,1,reqdata->active_status_cd,cnvtdatetime(curdate,curtime3),reqinfo->updt_id,
          reqdata->contributor_system_cd)
         IF (stat=1)
          SET gsub_donor_antigen_status = "OK"
         ELSEIF (stat=0)
          SET gsub_donor_antigen_status = "FA"
         ELSE
          SET gsub_donor_antigen_status = "FS"
         ENDIF
         IF (gsub_donor_antigen_status="FS")
          SET failed = "T"
          SET status_count = (status_count+ 1)
          IF (status_count > 1)
           SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
          ENDIF
          SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
          SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
          SET reply->status_data.subeventstatus[status_count].targetobjectname = "donor_antigen"
          SET reply->status_data.subeventstatus[status_count].targetobjectvalue = concat(
           "Could not insert donor_antigen row--get next pathnet_seq for id failed ",
           "for order_id = ",cnvtstring(request->orders[oidx].order_id))
          GO TO exit_script
         ELSEIF (gsub_donor_antigen_status="FA")
          SET failed = "T"
          SET status_count = (status_count+ 1)
          IF (status_count > 1)
           SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
          ENDIF
          SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
          SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
          SET reply->status_data.subeventstatus[status_count].targetobjectname = "donor_antigen"
          SET reply->status_data.subeventstatus[status_count].targetobjectvalue = concat(
           "Insert donor_antigen row failed for order_id = ",cnvtstring(request->orders[oidx].
            order_id))
          GO TO exit_script
         ELSEIF (gsub_donor_antigen_status != "OK")
          SET failed = "T"
          SET status_count = (status_count+ 1)
          IF (status_count > 1)
           SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
          ENDIF
          SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
          SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
          SET reply->status_data.subeventstatus[status_count].targetobjectname = "donor_antigen"
          SET reply->status_data.subeventstatus[status_count].targetobjectvalue = concat(
           "Could not insert donor_antigen row due to invalid insert status (",
           gsub_donor_antigen_status,") for order_id = ",cnvtstring(request->orders[oidx].order_id))
          GO TO exit_script
         ENDIF
        ENDIF
       ENDIF
       IF ((request->orders[oidx].assays[aidx].antibody_verify_yn="Y")
        AND (request->orders[oidx].assays[aidx].bb_result_code_set_cd > 0)
        AND (modproductlist->product[midx].product_id=mod_product_id))
        SET gsub_donor_antibody_status = "  "
        SET stat = add_donor_antibody(request->orders[oidx].person_id,request->orders[oidx].encntr_id,
         request->orders[oidx].assays[aidx].bb_result_code_set_cd,reply->orders[oidx].assays[aidx].
         result_id,bb_result_seq,
         1,reqdata->active_status_cd,cnvtdatetime(current->system_dt_tm),request->event_personnel_id,
         reqdata->contributor_system_cd)
        IF (stat=1)
         SET gsub_donor_antibody_status = "OK"
        ELSEIF (stat=0)
         SET gsub_donor_antibody_status = "FA"
        ELSE
         SET gsub_donor_antibody_status = "FS"
        ENDIF
        IF (gsub_donor_antibody_status != "OK")
         IF (gsub_donor_antibody_status="FS")
          SET failed = "T"
          SET status_count = (status_count+ 1)
          IF (status_count > 1)
           SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
          ENDIF
          SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
          SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
          SET reply->status_data.subeventstatus[status_count].targetobjectname = "Donor Antibody"
          SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
          "Unable to insert person antibody due to sequence number"
         ELSEIF (gsub_donor_antibody_status="FA")
          SET failed = "T"
          SET status_count = (status_count+ 1)
          IF (status_count > 1)
           SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
          ENDIF
          SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
          SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
          SET reply->status_data.subeventstatus[status_count].targetobjectname = "Person Antibody"
          SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
          "Unable to insert person antibody"
         ENDIF
         GO TO exit_script
        ENDIF
       ENDIF
       IF ((request->review_queue_ind=0))
        SET nbr_of_excepts = request->orders[oidx].assays[aidx].except_cnt
        SET cntr = 0
        IF (nbr_of_excepts > 0)
         FOR (cntr = 1 TO nbr_of_excepts)
           SET exception_status = "I"
           SET bb_exception_id = 0.0
           IF ((request->orders[oidx].assays[aidx].result_status_cd != result_status_in_review_cd))
            CALL add_bbd_exception(sub_product_event_id,request->orders[oidx].assays[aidx].
             exceptlist[cntr].exception_type_mean,request->orders[oidx].assays[aidx].exceptlist[cntr]
             .override_reason_cd,re_event_type_cd,request->orders[oidx].assays[aidx].result_id,
             perf_result_seq,request->orders[oidx].assays[aidx].exceptlist[cntr].from_abo_cd,request
             ->orders[oidx].assays[aidx].exceptlist[cntr].from_rh_cd,request->orders[oidx].assays[
             aidx].exceptlist[cntr].to_abo_cd,request->orders[oidx].assays[aidx].exceptlist[cntr].
             to_rh_cd,
             request->orders[oidx].assays[aidx].exceptlist[cntr].person_id)
            IF (exception_status="F")
             SET failed = "T"
             SET status_count = (status_count+ 1)
             IF (status_count > 1)
              SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
             ENDIF
             SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
             SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
             SET reply->status_data.subeventstatus[status_count].targetobjectname = "BB EXCEPTION"
             SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
             "Unable to insert exception"
             GO TO exit_script
            ENDIF
           ELSE
            CALL add_bbd_inactive_exception(sub_product_event_id,request->orders[oidx].assays[aidx].
             exceptlist[cntr].exception_type_mean,request->orders[oidx].assays[aidx].exceptlist[cntr]
             .override_reason_cd,re_event_type_cd,request->orders[oidx].assays[aidx].result_id,
             perf_result_seq,request->orders[oidx].assays[aidx].exceptlist[cntr].from_abo_cd,request
             ->orders[oidx].assays[aidx].exceptlist[cntr].from_rh_cd,request->orders[oidx].assays[
             aidx].exceptlist[cntr].to_abo_cd,request->orders[oidx].assays[aidx].exceptlist[cntr].
             to_rh_cd,
             request->orders[oidx].assays[aidx].exceptlist[cntr].person_id)
            IF (exception_status="F")
             SET failed = "T"
             SET status_count = (status_count+ 1)
             IF (status_count > 1)
              SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
             ENDIF
             SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
             SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
             SET reply->status_data.subeventstatus[status_count].targetobjectname = "BB EXCEPTION"
             SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
             "Unable to insert exception"
             GO TO exit_script
            ELSEIF (exception_status="FU")
             SET failed = "T"
             SET status_count = (status_count+ 1)
             IF (status_count > 1)
              SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
             ENDIF
             SET reply->status_data.subeventstatus[status_count].operationname = "UAR"
             SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
             SET reply->status_data.subeventstatus[status_count].targetobjectname = "BB EXCEPTION"
             SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
             "Unable to get exception_type_cd"
             GO TO exit_script
            ENDIF
           ENDIF
         ENDFOR
        ENDIF
       ELSEIF ((request->review_queue_ind=1))
        SET nbr_of_excepts = request->orders[oidx].assays[aidx].except_cnt
        SET cntr = 0
        IF (nbr_of_excepts > 0)
         FOR (cntr = 1 TO nbr_of_excepts)
           SET exception_status = "I"
           SET bb_exception_id = 0.0
           CALL activate_bbd_exception(request->orders[oidx].assays[aidx].exceptlist[cntr].
            exception_id,request->orders[oidx].assays[aidx].exceptlist[cntr].updt_cnt)
           IF (exception_status="FL")
            SET failed = "T"
            SET status_count = (status_count+ 1)
            IF (status_count > 1)
             SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
            ENDIF
            SET reply->status_data.subeventstatus[status_count].operationname = "LOCK"
            SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
            SET reply->status_data.subeventstatus[status_count].targetobjectname = "BB EXCEPTION"
            SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
            "Unable to lock exception"
            GO TO exit_script
           ENDIF
           IF (exception_status="F")
            SET failed = "T"
            SET status_count = (status_count+ 1)
            IF (status_count > 1)
             SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
            ENDIF
            SET reply->status_data.subeventstatus[status_count].operationname = "UPDATE"
            SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
            SET reply->status_data.subeventstatus[status_count].targetobjectname = "BB EXCEPTION"
            SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
            "Unable to update exception"
            GO TO exit_script
           ENDIF
         ENDFOR
        ENDIF
       ENDIF
     ENDFOR
   ENDFOR
 ENDFOR
 SET nbr_of_donors = size(request->donors,5)
#person_donor_start
 FOR (didx = 1 TO nbr_of_donors)
  IF ((request->donors[didx].updt_person_donor_ind=1))
   CALL update_person_donor(request->donors[didx].person_id,1,request->donors[didx].
    updt_eligibility_ind,request->donors[didx].eligibility_cd,request->donors[didx].
    updt_defer_until_ind,
    request->donors[didx].elig_defer_dt_tm,request->donors[didx].person_donor_updt_cnt,request->
    donors[didx].elig_for_reinstate_ind,request->donors[didx].updt_elig_for_reinstate_ind_yn,request
    ->donors[didx].reinstated_ind,
    request->donors[didx].updt_reinstated_ind_yn,cnvtdatetime(current->system_dt_tm),request->
    event_personnel_id,reqinfo->updt_task,reqinfo->updt_applctx)
   IF (gsub_person_donor_status="FL")
    SET failed = "T"
    SET status_count = (status_count+ 1)
    IF (status_count > 1)
     SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
    ENDIF
    SET reply->status_data.subeventstatus[status_count].operationname = "UPDATE"
    SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
    SET reply->status_data.subeventstatus[status_count].targetobjectname = "Person Donor"
    SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
    "Unable to update person_donor due to lock_ind"
    GO TO exit_script
   ELSEIF (gsub_person_donor_status="UF")
    SET failed = "T"
    SET status_count = (status_count+ 1)
    IF (status_count > 1)
     SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
    ENDIF
    SET reply->status_data.subeventstatus[status_count].operationname = "UPDATE"
    SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
    SET reply->status_data.subeventstatus[status_count].targetobjectname = "Person Donor"
    SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
    "Unable to update person_donor"
    GO TO exit_script
   ENDIF
  ENDIF
  IF ((request->donors[didx].updt_bbd_eligibility_ind=1))
   CALL update_donor_eligibility(request->donors[didx].eligibility_id,0,request->donors[didx].
    contact_id,0,request->donors[didx].person_id,
    request->donors[didx].updt_eligibility_ind,request->donors[didx].eligibility_cd,request->donors[
    didx].updt_elig_until_ind,cnvtdatetime(request->donors[didx].elig_defer_dt_tm),request->donors[
    didx].eligibility_updt_cnt,
    cnvtdatetime(current->system_dt_tm),request->event_personnel_id,reqinfo->updt_task,reqinfo->
    updt_applctx)
   IF (gsub_person_donor_status="FL")
    SET failed = "T"
    SET status_count = (status_count+ 1)
    IF (status_count > 1)
     SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
    ENDIF
    SET reply->status_data.subeventstatus[status_count].operationname = "SELECT"
    SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
    SET reply->status_data.subeventstatus[status_count].targetobjectname = "Donor Eligibility"
    SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
    "Unable to update bbd_donor_eligibility due to locking for update"
    GO TO exit_script
   ELSEIF (gsub_person_donor_status="UF")
    SET failed = "T"
    SET status_count = (status_count+ 1)
    IF (status_count > 1)
     SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
    ENDIF
    SET reply->status_data.subeventstatus[status_count].operationname = "UPDATE"
    SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
    SET reply->status_data.subeventstatus[status_count].targetobjectname = "BBD Donor Eligibility"
    SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
    "Unable to add bbd_donor_eligibility"
    GO TO exit_script
   ENDIF
  ENDIF
 ENDFOR
 SET nbr_of_deferral_reas = size(request->deferral_reasons,5)
 FOR (ridx = 1 TO nbr_of_deferral_reas)
  CALL add_bbd_deferral_reason(request->deferral_reasons[ridx].eligibility_id,request->
   deferral_reasons[ridx].contact_id,request->deferral_reasons[ridx].person_id,request->
   deferral_reasons[ridx].elig_reason_cd,request->deferral_reasons[ridx].eligible_dt_tm,
   request->deferral_reasons[ridx].result_id,1,reqdata->active_status_cd,cnvtdatetime(current->
    system_dt_tm),request->event_personnel_id)
  IF (gsub_bbd_deferral_reason_status="FS")
   SET failed = "T"
   SET status_count = (status_count+ 1)
   IF (status_count > 1)
    SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
   ENDIF
   SET reply->status_data.subeventstatus[status_count].operationname = "SELECT"
   SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
   SET reply->status_data.subeventstatus[status_count].targetobjectname = "PathNet Sequence"
   SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
   "Unable to update bbd_donor_eligibility due to sequence generation"
   GO TO exit_script
  ELSEIF (gsub_bbd_deferral_reason_status="FA")
   SET failed = "T"
   SET status_count = (status_count+ 1)
   IF (status_count > 1)
    SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
   ENDIF
   SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
   SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
   SET reply->status_data.subeventstatus[status_count].targetobjectname = "BBD Deferral Reason"
   SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
   "Unable to add bbd_deferral_reason"
   GO TO exit_script
  ENDIF
 ENDFOR
 SET reply->status_data.status = "S"
 GO TO exit_script
 DECLARE process_new_result(none) = i4
 SUBROUTINE process_new_result(none)
   IF (insert_result(0)=0)
    SET failed = "T"
    SET status_count = (status_count+ 1)
    IF (status_count > 1)
     SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
    ENDIF
    SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
    SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
    SET reply->status_data.subeventstatus[status_count].targetobjectname = "Result"
    SET reply->status_data.subeventstatus[status_count].targetobjectvalue = "Unable to insert result"
    RETURN(0)
   ENDIF
   SET reply->orders[oidx].assays[aidx].result_id = request->orders[oidx].assays[aidx].result_id
   SET reply->orders[oidx].assays[aidx].result_updt_cnt = 0
   IF (insert_perform_result(request->orders[oidx].assays[aidx].result_id,0.0)=0)
    SET failed = "T"
    SET status_count = (status_count+ 1)
    IF (status_count > 1)
     SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
    ENDIF
    SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
    SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
    SET reply->status_data.subeventstatus[status_count].targetobjectname = "Perform Result"
    SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
    "Unable to insert perform result"
    RETURN(0)
   ENDIF
   SET reply->orders[oidx].assays[aidx].perform_result_id = perf_result_seq
   SET reply->orders[oidx].assays[aidx].parent_perform_result_id = 0.0
   SET reply->orders[oidx].assays[aidx].perform_result_updt_cnt = 0
   SET nbr_of_result_comments = request->orders[oidx].assays[aidx].result_comment_cnt
   IF (nbr_of_result_comments > 0
    AND (request->orders[oidx].assays[aidx].result_status_cd IN (result_status_performed_cd,
   result_status_in_review_cd, result_status_verified_cd, result_status_corrected_cd)))
    FOR (rcidx = 1 TO nbr_of_result_comments)
      IF (insert_result_comment(request->orders[oidx].assays[aidx].result_id)=0)
       RETURN(0)
      ENDIF
    ENDFOR
   ENDIF
   IF ((request->orders[oidx].assays[aidx].result_status_cd=result_status_verified_cd))
    SET result_event_type_cd = result_status_performed_cd
    IF (insert_result_event(request->orders[oidx].assays[aidx].result_id,perf_result_seq,
     result_event_type_cd,result_status_performed_disp)=0)
     SET failed = "T"
     SET status_count = (status_count+ 1)
     IF (status_count > 1)
      SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
     ENDIF
     SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
     SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
     SET reply->status_data.subeventstatus[status_count].targetobjectname = "Result Event"
     SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
     "Unable to insert result event - perform"
     RETURN(0)
    ENDIF
   ENDIF
   SET result_event_type_cd = request->orders[oidx].assays[aidx].result_status_cd
   SET result_event_reason = request->orders[oidx].assays[aidx].result_status_disp
   IF (insert_result_event(request->orders[oidx].assays[aidx].result_id,perf_result_seq,
    result_event_type_cd,result_event_reason)=0)
    SET failed = "T"
    SET status_count = (status_count+ 1)
    IF (status_count > 1)
     SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
    ENDIF
    SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
    SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
    SET reply->status_data.subeventstatus[status_count].targetobjectname = "Result Event"
    SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
    "Unable to insert result event"
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 DECLARE process_updated_result(none1) = i4
 SUBROUTINE process_updated_result(none1)
   IF (update_result(request->orders[oidx].assays[aidx].result_id)=0)
    RETURN(0)
   ENDIF
   SET reply->orders[oidx].assays[aidx].result_id = request->orders[oidx].assays[aidx].result_id
   SET reply->orders[oidx].assays[aidx].result_updt_cnt = (request->orders[oidx].assays[aidx].
   result_updt_cnt+ 1)
   SET perf_result_seq = request->orders[oidx].assays[aidx].perform_result_id
   IF (perf_result_seq=0.0)
    IF (insert_perform_result(request->orders[oidx].assays[aidx].result_id,0.0)=0)
     SET failed = "T"
     SET status_count = (status_count+ 1)
     IF (status_count > 1)
      SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
     ENDIF
     SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
     SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
     SET reply->status_data.subeventstatus[status_count].targetobjectname = "Perform Result"
     SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
     "Unable to insert perform result"
     RETURN(0)
    ENDIF
    SET reply->orders[oidx].assays[aidx].perform_result_id = perf_result_seq
    SET reply->orders[oidx].assays[aidx].parent_perform_result_id = 0.0
    SET reply->orders[oidx].assays[aidx].perform_result_updt_cnt = 0
   ELSE
    IF ((request->orders[oidx].assays[aidx].result_status_cd IN (result_status_performed_cd,
    result_status_in_review_cd, result_status_verified_cd)))
     IF (read_perform_result(request->orders[oidx].assays[aidx].result_id,perf_result_seq)=0)
      SET failed = "T"
      SET status_count = (status_count+ 1)
      IF (status_count > 1)
       SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
      ENDIF
      SET reply->status_data.subeventstatus[status_count].operationname = "SELECT"
      SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
      SET reply->status_data.subeventstatus[status_count].targetobjectname = "Perform Result"
      SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
      "Unable to retrieve perform result"
      RETURN(0)
     ENDIF
     IF (curr_result_status_cd IN (result_status_performed_cd, result_status_in_review_cd)
      AND (request->orders[oidx].assays[aidx].result_status_cd IN (result_status_performed_cd,
     result_status_in_review_cd, result_status_verified_cd))
      AND (request->orders[oidx].assays[aidx].perform_ind > 0))
      IF (curr_result_status_cd=result_status_performed_cd)
       IF (update_perform_result(request->orders[oidx].assays[aidx].result_id,perf_result_seq,
        result_status_old_perf_cd)=0)
        RETURN(0)
       ENDIF
      ELSEIF (curr_result_status_cd=result_status_in_review_cd)
       IF (update_perform_result(request->orders[oidx].assays[aidx].result_id,perf_result_seq,
        result_status_old_in_rev_cd)=0)
        RETURN(0)
       ENDIF
      ENDIF
      SET parent_perf_result_id = perf_result_seq
      IF (insert_perform_result(request->orders[oidx].assays[aidx].result_id,parent_perf_result_id)=0
      )
       SET failed = "T"
       SET status_count = (status_count+ 1)
       IF (status_count > 1)
        SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
       ENDIF
       SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
       SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
       SET reply->status_data.subeventstatus[status_count].targetobjectname = "Perform Result"
       SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
       "Unable to insert perform result"
       RETURN(0)
      ENDIF
      SET reply->orders[oidx].assays[aidx].perform_result_id = perf_result_seq
      SET reply->orders[oidx].assays[aidx].parent_perform_result_id = parent_perf_result_id
      SET reply->orders[oidx].assays[aidx].perform_result_updt_cnt = 0
     ENDIF
     IF (curr_result_status_cd=result_status_verified_cd
      AND (request->orders[oidx].assays[aidx].result_status_cd=result_status_verified_cd)
      AND (request->orders[oidx].assays[aidx].perform_ind > 0))
      IF (update_perform_result(request->orders[oidx].assays[aidx].result_id,perf_result_seq,
       result_status_old_verf_cd)=0)
       RETURN(0)
      ENDIF
      SET parent_perf_result_id = perf_result_seq
      IF (insert_perform_result(request->orders[oidx].assays[aidx].result_id,parent_perf_result_id)=0
      )
       SET failed = "T"
       SET status_count = (status_count+ 1)
       IF (status_count > 1)
        SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
       ENDIF
       SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
       SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
       SET reply->status_data.subeventstatus[status_count].targetobjectname = "Perform Result"
       SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
       "Unable to insert perform result"
       RETURN(0)
      ENDIF
      SET reply->orders[oidx].assays[aidx].perform_result_id = perf_result_seq
      SET reply->orders[oidx].assays[aidx].parent_perform_result_id = parent_perf_result_id
      SET reply->orders[oidx].assays[aidx].perform_result_updt_cnt = 0
     ENDIF
     IF (curr_result_status_cd IN (result_status_performed_cd, result_status_in_review_cd)
      AND (request->orders[oidx].assays[aidx].result_status_cd IN (result_status_verified_cd,
     result_status_in_review_cd))
      AND (request->orders[oidx].assays[aidx].perform_ind=0))
      IF ((request->orders[oidx].assays[aidx].result_status_cd=result_status_verified_cd))
       IF (update_perform_result(request->orders[oidx].assays[aidx].result_id,perf_result_seq,
        result_status_verified_cd)=0)
        RETURN(0)
       ENDIF
      ELSE
       IF (update_perform_result(request->orders[oidx].assays[aidx].result_id,perf_result_seq,
        result_status_in_review_cd)=0)
        RETURN(0)
       ENDIF
      ENDIF
      SET reply->orders[oidx].assays[aidx].perform_result_id = perf_result_seq
      SET reply->orders[oidx].assays[aidx].parent_perform_result_id = curr_parent_perf_result_id
      SET reply->orders[oidx].assays[aidx].perform_result_updt_cnt = (request->orders[oidx].assays[
      aidx].perform_result_updt_cnt+ 1)
     ENDIF
    ENDIF
   ENDIF
   SET nbr_of_result_comments = request->orders[oidx].assays[aidx].result_comment_cnt
   IF (nbr_of_result_comments > 0
    AND (request->orders[oidx].assays[aidx].result_status_cd IN (result_status_performed_cd,
   result_status_in_review_cd, result_status_verified_cd, result_status_corrected_cd)))
    FOR (rcidx = 1 TO nbr_of_result_comments)
      IF (insert_result_comment(request->orders[oidx].assays[aidx].result_id)=0)
       RETURN(0)
      ENDIF
    ENDFOR
   ENDIF
   SET result_event_type_cd = request->orders[oidx].assays[aidx].result_status_cd
   SET result_event_reason = request->orders[oidx].assays[aidx].result_status_disp
   IF (insert_result_event(request->orders[oidx].assays[aidx].result_id,perf_result_seq,
    result_event_type_cd,result_event_reason)=0)
    SET failed = "T"
    SET status_count = (status_count+ 1)
    IF (status_count > 1)
     SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
    ENDIF
    SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
    SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
    SET reply->status_data.subeventstatus[status_count].targetobjectname = "Result Event"
    SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
    "Unable to insert result event"
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 DECLARE bb_result_seq = f8
 DECLARE insert_result(none2) = i4
 SUBROUTINE insert_result(none2)
   IF ((request->orders[oidx].assays[aidx].bb_control_cell_cd != 0))
    IF ((((request->orders[oidx].assays[aidx].bb_control_cell_cd != hold_control_cell)) OR ((request
    ->orders[oidx].assays[aidx].next_row_ind=1))) )
     IF ((request->orders[oidx].assays[aidx].bb_result_id <= 0))
      SELECT INTO "nl:"
       next_seq_nbr = seq(pathnet_seq,nextval)
       FROM dual
       DETAIL
        bb_result_seq = next_seq_nbr
       WITH nocounter
      ;end select
      IF ((request->orders[oidx].assays[aidx].order_cell_id > 0))
       IF (update_bb_order_cell(bb_result_seq)=0)
        RETURN(0)
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ELSEIF ((request->orders[oidx].assays[aidx].product_id != 0))
    IF ((((request->orders[oidx].assays[aidx].product_id != hold_product_id)) OR ((request->orders[
    oidx].assays[aidx].next_row_ind=1))) )
     IF ((request->orders[oidx].assays[aidx].bb_result_id <= 0))
      SELECT INTO "nl:"
       next_seq_nbr = seq(pathnet_seq,nextval)
       FROM dual
       DETAIL
        bb_result_seq = next_seq_nbr
       WITH nocounter
      ;end select
      IF ((request->orders[oidx].assays[aidx].order_cell_id > 0))
       IF (update_bb_order_cell(bb_result_seq)=0)
        RETURN(0)
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ELSE
    SET bb_result_seq = 0.0
   ENDIF
   INSERT  FROM result r
    SET r.result_id = request->orders[oidx].assays[aidx].result_id, r.bb_result_id = bb_result_seq, r
     .order_id = request->orders[oidx].order_id,
     r.catalog_cd = request->orders[oidx].catalog_cd, r.task_assay_cd = request->orders[oidx].assays[
     aidx].task_assay_cd, r.call_back_ind = request->orders[oidx].assays[aidx].call_back_ind,
     r.result_status_cd = request->orders[oidx].assays[aidx].result_status_cd, r.chartable_flag = 0,
     r.security_level_cd = request->orders[oidx].assays[aidx].security_level_cd,
     r.repeat_number = request->orders[oidx].assays[aidx].repeat_number, r.bb_control_cell_cd =
     request->orders[oidx].assays[aidx].bb_control_cell_cd, r.person_id = 0,
     r.bb_group_id = request->orders[oidx].assays[aidx].bb_group_id, r.lot_information_id = request->
     orders[oidx].assays[aidx].lot_information_id, r.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     r.updt_id = reqinfo->updt_id, r.updt_task = reqinfo->updt_task, r.updt_applctx = reqinfo->
     updt_applctx,
     r.updt_cnt = 0
    PLAN (r)
    WITH nocounter
   ;end insert
   RETURN(curqual)
 END ;Subroutine
 DECLARE update_result(arg_result_id) = i4
 SUBROUTINE update_result(arg_result_id)
   SET return_value = 0
   SET cur_updt_cnt = 0
   SELECT INTO "nl:"
    r.result_id
    FROM result r
    WHERE r.result_id=arg_result_id
    DETAIL
     cur_updt_cnt = r.updt_cnt
    WITH nocounter, forupdate(r)
   ;end select
   IF (curqual=0)
    SET failed = "T"
    SET status_count = (status_count+ 1)
    IF (status_count > 1)
     SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
    ENDIF
    SET reply->status_data.subeventstatus[status_count].operationname = "CHANGE"
    SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
    SET reply->status_data.subeventstatus[status_count].targetobjectname = "Result"
    SET reply->status_data.subeventstatus[status_count].targetobjectvalue = "Unable to lock result"
    SET return_value = 0
   ELSEIF ((cur_updt_cnt != request->orders[oidx].assays[aidx].result_updt_cnt))
    SET failed = "T"
    SET status_count = (status_count+ 1)
    IF (status_count > 1)
     SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
    ENDIF
    SET reply->status_data.subeventstatus[status_count].operationname = "CHANGE"
    SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
    SET reply->status_data.subeventstatus[status_count].targetobjectname = "Result"
    SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
    "Update conflict on result"
    SET return_value = 0
   ELSE
    UPDATE  FROM result r
     SET r.call_back_ind = request->orders[oidx].assays[aidx].call_back_ind, r.result_status_cd =
      request->orders[oidx].assays[aidx].result_status_cd, r.chartable_flag = 0,
      r.security_level_cd = request->orders[oidx].assays[aidx].security_level_cd, r.repeat_number =
      request->orders[oidx].assays[aidx].repeat_number, r.bb_group_id = request->orders[oidx].assays[
      aidx].bb_group_id,
      r.lot_information_id = request->orders[oidx].assays[aidx].lot_information_id, r.updt_dt_tm =
      cnvtdatetime(curdate,curtime3), r.updt_id = reqinfo->updt_id,
      r.updt_task = reqinfo->updt_task, r.updt_applctx = reqinfo->updt_applctx, r.updt_cnt = (r
      .updt_cnt+ 1)
     PLAN (r
      WHERE r.result_id=arg_result_id
       AND (r.updt_cnt=request->orders[oidx].assays[aidx].result_updt_cnt))
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET failed = "T"
     SET status_count = (status_count+ 1)
     IF (status_count > 1)
      SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
     ENDIF
     SET reply->status_data.subeventstatus[status_count].operationname = "CHANGE"
     SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
     SET reply->status_data.subeventstatus[status_count].targetobjectname = "Result"
     SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
     "Unable to update result"
     SET return_value = 0
    ELSE
     SET return_value = 1
    ENDIF
   ENDIF
   RETURN(return_value)
 END ;Subroutine
 DECLARE perf_result_seq = f8
 DECLARE insert_perform_result(arg_result_id,arg_parent_perf_rslt_id) = i4
 SUBROUTINE insert_perform_result(arg_result_id,arg_parent_perf_rslt_id)
   IF ((request->orders[oidx].assays[aidx].result_type_cd IN (result_type_freetext_cd,
   result_type_text_cd, result_type_interp_cd))
    AND (request->orders[oidx].assays[aidx].rtf_text > " "))
    IF (read_long_data_seq(0)=0)
     RETURN(0)
    ENDIF
   ELSE
    SET long_text_seq = 0.0
   ENDIF
   SELECT INTO "nl:"
    next_seq_nbr = seq(pathnet_seq,nextval)
    FROM dual
    DETAIL
     perf_result_seq = next_seq_nbr
    WITH nocounter
   ;end select
   INSERT  FROM perform_result pr
    SET pr.perform_result_id = perf_result_seq, pr.result_id = arg_result_id, pr
     .parent_perform_result_id = arg_parent_perf_rslt_id,
     pr.container_id = request->orders[oidx].assays[aidx].container_id, pr.service_resource_cd =
     request->orders[oidx].assays[aidx].service_resource_cd, pr.perform_personnel_id = request->
     orders[oidx].assays[aidx].perform_personnel_id,
     pr.perform_dt_tm = cnvtdatetime(request->orders[oidx].assays[aidx].perform_dt_tm), pr
     .result_status_cd = request->orders[oidx].assays[aidx].result_status_cd, pr.result_type_cd =
     request->orders[oidx].assays[aidx].result_type_cd,
     pr.nomenclature_id = request->orders[oidx].assays[aidx].nomenclature_id, pr.result_code_set_cd
      =
     IF ((request->orders[oidx].assays[aidx].bb_result_code_set_cd > 0.0)) request->orders[oidx].
      assays[aidx].bb_result_code_set_cd
     ELSE 0
     ENDIF
     , pr.result_value_alpha =
     IF ((request->orders[oidx].assays[aidx].result_type_cd IN (result_type_text_cd,
     result_type_alpha_cd, result_type_interp_cd))) request->orders[oidx].assays[aidx].
      result_value_alpha
     ELSE null
     ENDIF
     ,
     pr.result_value_numeric =
     IF ((request->orders[oidx].assays[aidx].result_type_cd IN (result_type_numeric_cd,
     result_type_calc_cd, result_type_interp_cd))) request->orders[oidx].assays[aidx].
      result_value_numeric
     ELSE null
     ENDIF
     , pr.numeric_raw_value =
     IF ((request->orders[oidx].assays[aidx].result_type_cd IN (result_type_numeric_cd,
     result_type_calc_cd, result_type_interp_cd))) request->orders[oidx].assays[aidx].
      numeric_raw_value
     ELSE null
     ENDIF
     , pr.less_great_flag =
     IF ((request->orders[oidx].assays[aidx].less_great_flag IN (0, 1, 2))) request->orders[oidx].
      assays[aidx].less_great_flag
     ELSE null
     ENDIF
     ,
     pr.result_value_dt_tm =
     IF ((request->orders[oidx].assays[aidx].result_type_cd=result_type_date_cd)) cnvtdatetime(
       request->orders[oidx].assays[aidx].result_value_dt_tm)
     ELSE null
     ENDIF
     , pr.long_text_id = long_text_seq, pr.ascii_text =
     IF ((request->orders[oidx].assays[aidx].result_type_cd IN (result_type_freetext_cd,
     result_type_text_cd))) request->orders[oidx].assays[aidx].ascii_text
     ELSE null
     ENDIF
     ,
     pr.reference_range_factor_id = request->orders[oidx].assays[aidx].reference_range_factor_id, pr
     .normal_cd = request->orders[oidx].assays[aidx].normal_cd, pr.critical_cd = request->orders[oidx
     ].assays[aidx].critical_cd,
     pr.review_cd = request->orders[oidx].assays[aidx].review_cd, pr.delta_cd = request->orders[oidx]
     .assays[aidx].delta_cd, pr.notify_cd = request->orders[oidx].assays[aidx].notify_cd,
     pr.units_cd = request->orders[oidx].assays[aidx].units_cd, pr.normal_low = request->orders[oidx]
     .assays[aidx].normal_low, pr.normal_high = request->orders[oidx].assays[aidx].normal_high,
     pr.normal_alpha =
     IF (trim(request->orders[oidx].assays[aidx].normal_alpha) > " ") request->orders[oidx].assays[
      aidx].normal_alpha
     ELSE null
     ENDIF
     , pr.dilution_factor = request->orders[oidx].assays[aidx].dilution_factor, pr
     .resource_error_codes = request->orders[oidx].assays[aidx].resource_error_codes,
     pr.equation_id = request->orders[oidx].assays[aidx].equation_id, pr.multiplex_resource_cd =
     request->orders[oidx].assays[aidx].multiplex_resource_cd, pr.interp_override_ind = request->
     orders[oidx].assays[aidx].interp_override_ind,
     pr.updt_dt_tm = cnvtdatetime(curdate,curtime3), pr.updt_id = reqinfo->updt_id, pr.updt_task =
     reqinfo->updt_task,
     pr.updt_applctx = reqinfo->updt_applctx, pr.updt_cnt = 0, pr.perform_tz =
     IF (curutc=1) curtimezoneapp
     ELSE 0
     ENDIF
    PLAN (pr)
    WITH nocounter
   ;end insert
   IF (curqual=0)
    RETURN(0)
   ENDIF
   IF (long_text_seq > 0.0)
    INSERT  FROM long_text lt
     SET lt.long_text_id = long_text_seq, lt.parent_entity_name = "PERFORM_RESULT", lt
      .parent_entity_id = perf_result_seq,
      lt.long_text = request->orders[oidx].assays[aidx].rtf_text, lt.active_ind = 1, lt
      .active_status_cd = reqdata->active_status_cd,
      lt.active_status_dt_tm = cnvtdatetime(current->system_dt_tm), lt.active_status_prsnl_id =
      request->orders[oidx].assays[aidx].perform_personnel_id, lt.updt_dt_tm = cnvtdatetime(curdate,
       curtime3),
      lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->
      updt_applctx,
      lt.updt_cnt = 0
     PLAN (lt)
     WITH nocounter
    ;end insert
    IF (curqual=0)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 DECLARE update_perform_result(arg_result_id,arg_perf_result_id,arg_result_status_cd) = i4
 SUBROUTINE update_perform_result(arg_result_id,arg_perf_result_id,arg_result_status_cd)
   SET return_value = 0
   SET cur_updt_cnt = 0
   SELECT INTO "nl:"
    r.perform_result_id
    FROM perform_result r
    WHERE r.perform_result_id=perf_result_seq
     AND r.result_id=arg_result_id
    DETAIL
     cur_updt_cnt = r.updt_cnt
    WITH nocounter, forupdate(r)
   ;end select
   IF (curqual=0)
    SET failed = "T"
    SET status_count = (status_count+ 1)
    IF (status_count > 1)
     SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
    ENDIF
    SET reply->status_data.subeventstatus[status_count].operationname = "CHANGE"
    SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
    SET reply->status_data.subeventstatus[status_count].targetobjectname = "Perform Result"
    SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
    "Unable to lock perform result"
    SET return_value = 0
   ELSEIF ((cur_updt_cnt != request->orders[oidx].assays[aidx].perform_result_updt_cnt))
    SET failed = "T"
    SET status_count = (status_count+ 1)
    IF (status_count > 1)
     SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
    ENDIF
    SET reply->status_data.subeventstatus[status_count].operationname = "CHANGE"
    SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
    SET reply->status_data.subeventstatus[status_count].targetobjectname = "Perform Result"
    SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
    "Update conflict on perform result"
    SET return_value = 0
   ELSE
    UPDATE  FROM perform_result pr
     SET pr.result_status_cd = arg_result_status_cd, pr.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      pr.updt_id = reqinfo->updt_id,
      pr.updt_task = reqinfo->updt_task, pr.updt_applctx = reqinfo->updt_applctx, pr.updt_cnt = (pr
      .updt_cnt+ 1)
     WHERE pr.perform_result_id=arg_perf_result_id
      AND pr.result_id=arg_result_id
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET failed = "T"
     SET status_count = (status_count+ 1)
     IF (status_count > 1)
      SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
     ENDIF
     SET reply->status_data.subeventstatus[status_count].operationname = "CHANGE"
     SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
     SET reply->status_data.subeventstatus[status_count].targetobjectname = "Perform Result"
     SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
     "Unable to update perform result"
     SET return_value = 0
    ELSE
     SET return_value = 1
    ENDIF
   ENDIF
   RETURN(return_value)
 END ;Subroutine
 DECLARE read_perform_result(arg_result_id,arg_perf_result_id) = i4
 SUBROUTINE read_perform_result(arg_result_id,arg_perf_result_id)
   SET curr_result_status_cd = 0.0
   SET curr_parent_perf_result_id = 0.0
   SELECT INTO "nl:"
    pr.result_status_cd, pr.parent_perform_result_id
    FROM perform_result pr
    PLAN (pr
     WHERE pr.perform_result_id=arg_perf_result_id
      AND pr.result_id=arg_result_id)
    DETAIL
     curr_result_status_cd = pr.result_status_cd, curr_parent_perf_result_id = pr
     .parent_perform_result_id
    WITH nocounter
   ;end select
   RETURN(curqual)
 END ;Subroutine
 DECLARE insert_result_event(arg_result_id,arg_perf_result_id,arg_event_type_cd,arg_event_reason) =
 i4
 SUBROUTINE insert_result_event(arg_result_id,arg_perf_result_id,arg_event_type_cd,arg_event_reason)
   SET last_event_seq = 0
   SELECT INTO "nl:"
    re.result_id, re.event_sequence
    FROM result_event re
    PLAN (re
     WHERE re.result_id=arg_result_id
      AND re.perform_result_id=arg_perf_result_id)
    ORDER BY re.event_sequence DESC
    HEAD re.result_id
     last_event_seq = re.event_sequence
    WITH nocounter
   ;end select
   INSERT  FROM result_event re
    SET re.result_id = arg_result_id, re.perform_result_id = arg_perf_result_id, re.event_sequence =
     (last_event_seq+ 1),
     re.event_dt_tm = cnvtdatetime(request->event_dt_tm), re.event_personnel_id = request->
     event_personnel_id, re.event_reason = arg_event_reason,
     re.signature_line_ind = request->orders[oidx].assays[aidx].signature_line_ind, re
     .called_back_ind = request->orders[oidx].assays[aidx].call_back_ind, re.event_type_cd =
     arg_event_type_cd,
     re.updt_dt_tm = cnvtdatetime(curdate,curtime3), re.updt_id = reqinfo->updt_id, re.updt_task =
     reqinfo->updt_task,
     re.updt_applctx = reqinfo->updt_applctx, re.updt_cnt = 0
    PLAN (re)
    WITH nocounter
   ;end insert
   IF (curqual=0)
    RETURN(0)
   ENDIF
 END ;Subroutine
 DECLARE insert_result_comment(arg_result_id) = i4
 SUBROUTINE insert_result_comment(arg_result_id)
   SET long_text_seq = 0.0
   IF (read_long_data_seq(0)=0)
    RETURN(0)
   ENDIF
   SET last_action_seq = 0
   SELECT INTO "nl:"
    rc.result_id, rc.action_sequence
    FROM result_comment rc
    PLAN (rc
     WHERE rc.result_id=arg_result_id
      AND (rc.comment_type_cd=request->orders[oidx].assays[aidx].result_comment[rcidx].
     comment_type_cd))
    ORDER BY rc.action_sequence DESC
    HEAD rc.result_id
     last_action_seq = rc.action_sequence
    WITH nocounter
   ;end select
   INSERT  FROM result_comment rc
    SET rc.result_id = arg_result_id, rc.action_sequence = (last_action_seq+ 1), rc.comment_type_cd
      = request->orders[oidx].assays[aidx].result_comment[rcidx].comment_type_cd,
     rc.long_text_id = long_text_seq, rc.comment_prsnl_id = request->orders[oidx].assays[aidx].
     result_comment[rcidx].comment_prsnl_id, rc.comment_dt_tm = cnvtdatetime(current->system_dt_tm),
     rc.updt_dt_tm = cnvtdatetime(curdate,curtime3), rc.updt_id = reqinfo->updt_id, rc.updt_task =
     reqinfo->updt_task,
     rc.updt_applctx = reqinfo->updt_applctx, rc.updt_cnt = 0, rc.comment_tz =
     IF (curutc=1) curtimezoneapp
     ELSE 0
     ENDIF
    PLAN (rc)
    WITH nocounter
   ;end insert
   IF (curqual=0)
    RETURN(0)
   ENDIF
   INSERT  FROM long_text lt
    SET lt.long_text_id = long_text_seq, lt.parent_entity_name = "RESULT_COMMENT", lt
     .parent_entity_id = arg_result_id,
     lt.long_text = request->orders[oidx].assays[aidx].result_comment[rcidx].comment_text, lt
     .active_ind = 1, lt.active_status_cd = reqdata->active_status_cd,
     lt.active_status_dt_tm = cnvtdatetime(current->system_dt_tm), lt.active_status_prsnl_id =
     request->event_personnel_id, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->
     updt_applctx,
     lt.updt_cnt = 0
    PLAN (lt)
    WITH nocounter
   ;end insert
   IF (curqual=0)
    RETURN(0)
   ENDIF
   RETURN(curqual)
 END ;Subroutine
 DECLARE long_text_seq = f8
 DECLARE read_long_data_seq(none3) = i4
 SUBROUTINE read_long_data_seq(none3)
   SET long_text_seq = 0.0
   SELECT INTO "nl:"
    next_seq_nbr = seq(long_data_seq,nextval)
    FROM dual
    DETAIL
     long_text_seq = next_seq_nbr
    WITH nocounter
   ;end select
   RETURN(curqual)
 END ;Subroutine
 DECLARE update_donor_aborh(none4) = i4
 SUBROUTINE update_donor_aborh(none4)
   IF ((request->orders[oidx].assays[aidx].upd_don_hist_aborh_yn="Y"))
    SET rh_test_only = "N"
    SET abo_test_only = "N"
    SET abo_rh_test = "N"
    SET write_aborh_result = "N"
    IF ((request->orders[oidx].assays[aidx].new_abo_cd=0))
     SET rh_test_only = "Y"
    ELSE
     IF ((request->orders[oidx].assays[aidx].new_rh_cd=0))
      SET abo_test_only = "Y"
     ELSE
      SET abo_rh_test = "Y"
     ENDIF
    ENDIF
    IF (rh_test_only="Y")
     IF ((request->orders[oidx].assays[aidx].new_rh_cd=request->orders[oidx].assays[aidx].orig_rh_cd)
     )
      SET write_aborh_result = "Y"
     ELSE
      SET gsub_donor_aborh_status = "  "
      SET gsub_donor_aborh_inact_status = " "
      IF ((request->orders[oidx].assays[aidx].orig_rh_cd=0))
       IF ((request->orders[oidx].assays[aidx].orig_abo_cd=0))
        SET stat = add_donor_aborh(request->orders[oidx].person_id,request->orders[oidx].assays[aidx]
         .orig_abo_cd,request->orders[oidx].assays[aidx].new_rh_cd,1,reqdata->active_status_cd,
         cnvtdatetime(current->system_dt_tm),request->event_personnel_id,cnvtdatetime(request->
          event_dt_tm),reqdata->contributor_system_cd,donor_aborh_id)
        IF (stat=1)
         SET gsub_donor_aborh_status = "OK"
        ELSEIF (stat=0)
         SET gsub_donor_aborh_status = "FA"
         RETURN(0)
        ELSE
         SET gsub_donor_aborh_status = "FS"
         RETURN(0)
        ENDIF
        SET write_aborh_result = "Y"
       ELSE
        SET stat = chg_donor_aborh(request->orders[oidx].person_id,request->orders[oidx].assays[aidx]
         .orig_abo_cd,request->orders[oidx].assays[aidx].orig_rh_cd,0,reqdata->inactive_status_cd,
         request->orders[oidx].assays[aidx].person_aborh_updt_cnt)
        IF (stat=1)
         SET gsub_donor_aborh_inact_status = "OK"
        ELSEIF (stat=2)
         SET gsub_donor_aborh_inact_status = "FL"
         RETURN(0)
        ELSE
         SET gsub_donor_aborh_inact_status = "FU"
         RETURN(0)
        ENDIF
        SET stat = add_donor_aborh(request->orders[oidx].person_id,request->orders[oidx].assays[aidx]
         .orig_abo_cd,request->orders[oidx].assays[aidx].new_rh_cd,1,reqdata->active_status_cd,
         cnvtdatetime(current->system_dt_tm),request->event_personnel_id,cnvtdatetime(request->
          event_dt_tm),reqdata->contributor_system_cd,donor_aborh_id)
        IF (stat=1)
         SET gsub_donor_aborh_status = "OK"
        ELSEIF (stat=0)
         SET gsub_donor_aborh_status = "FA"
         RETURN(0)
        ELSE
         SET gsub_donor_aborh_status = "FS"
         RETURN(0)
        ENDIF
        SET write_aborh_result = "Y"
       ENDIF
      ELSE
       SET stat = chg_donor_aborh(request->orders[oidx].person_id,request->orders[oidx].assays[aidx].
        orig_abo_cd,request->orders[oidx].assays[aidx].orig_rh_cd,0,reqdata->inactive_status_cd,
        request->orders[oidx].assays[aidx].person_aborh_updt_cnt)
       IF (stat=1)
        SET gsub_donor_aborh_inact_status = "OK"
       ELSEIF (stat=2)
        SET gsub_donor_aborh_inact_status = "FL"
        RETURN(0)
       ELSE
        SET gsub_donor_aborh_inact_status = "FU"
        RETURN(0)
       ENDIF
       SET stat = add_donor_aborh(request->orders[oidx].person_id,request->orders[oidx].assays[aidx].
        orig_abo_cd,request->orders[oidx].assays[aidx].new_rh_cd,1,reqdata->active_status_cd,
        cnvtdatetime(current->system_dt_tm),request->event_personnel_id,cnvtdatetime(request->
         event_dt_tm),reqdata->contributor_system_cd,donor_aborh_id)
       IF (stat=1)
        SET gsub_donor_aborh_status = "OK"
       ELSEIF (stat=0)
        SET gsub_donor_aborh_status = "FA"
        RETURN(0)
       ELSE
        SET gsub_donor_aborh_status = "FS"
        RETURN(0)
       ENDIF
       SET write_aborh_result = "Y"
      ENDIF
     ENDIF
    ELSEIF (abo_test_only="Y")
     SET gsub_donor_aborh_status = "  "
     SET gsub_donor_aborh_inact_status = " "
     IF ((request->orders[oidx].assays[aidx].new_abo_cd=request->orders[oidx].assays[aidx].
     orig_abo_cd))
      SET write_aborh_result = "Y"
     ELSE
      IF ((request->orders[oidx].assays[aidx].orig_abo_cd=0))
       IF ((request->orders[oidx].assays[aidx].orig_rh_cd=0))
        SET stat = add_donor_aborh(request->orders[oidx].person_id,request->orders[oidx].assays[aidx]
         .new_abo_cd,request->orders[oidx].assays[aidx].orig_rh_cd,1,reqdata->active_status_cd,
         cnvtdatetime(current->system_dt_tm),request->event_personnel_id,cnvtdatetime(request->
          event_dt_tm),reqdata->contributor_system_cd,donor_aborh_id)
        IF (stat=1)
         SET gsub_donor_aborh_status = "OK"
        ELSEIF (stat=0)
         SET gsub_donor_aborh_status = "FA"
         RETURN(0)
        ELSE
         SET gsub_donor_aborh_status = "FS"
         RETURN(0)
        ENDIF
        SET write_aborh_result = "Y"
       ELSE
        SET stat = chg_donor_aborh(request->orders[oidx].person_id,request->orders[oidx].assays[aidx]
         .orig_abo_cd,request->orders[oidx].assays[aidx].orig_rh_cd,0,reqdata->inactive_status_cd,
         request->orders[oidx].assays[aidx].person_aborh_updt_cnt)
        IF (stat=1)
         SET gsub_donor_aborh_inact_status = "OK"
        ELSEIF (stat=2)
         SET gsub_donor_aborh_inact_status = "FL"
         RETURN(0)
        ELSE
         SET gsub_donor_aborh_inact_status = "FU"
         RETURN(0)
        ENDIF
        SET stat = add_donor_aborh(request->orders[oidx].person_id,request->orders[oidx].assays[aidx]
         .new_abo_cd,request->orders[oidx].assays[aidx].orig_rh_cd,1,reqdata->active_status_cd,
         cnvtdatetime(current->system_dt_tm),request->event_personnel_id,cnvtdatetime(request->
          event_dt_tm),reqdata->contributor_system_cd,donor_aborh_id)
        IF (stat=1)
         SET gsub_donor_aborh_status = "OK"
        ELSEIF (stat=0)
         SET gsub_donor_aborh_status = "FA"
         RETURN(0)
        ELSE
         SET gsub_donor_aborh_status = "FS"
         RETURN(0)
        ENDIF
        SET write_aborh_result = "Y"
       ENDIF
      ELSE
       SET stat = chg_donor_aborh(request->orders[oidx].person_id,request->orders[oidx].assays[aidx].
        orig_abo_cd,request->orders[oidx].assays[aidx].orig_rh_cd,0,reqdata->inactive_status_cd,
        request->orders[oidx].assays[aidx].person_aborh_updt_cnt)
       IF (stat=1)
        SET gsub_donor_aborh_inact_status = "OK"
       ELSEIF (stat=2)
        SET gsub_donor_aborh_inact_status = "FL"
        RETURN(0)
       ELSE
        SET gsub_donor_aborh_inact_status = "FU"
        RETURN(0)
       ENDIF
       SET stat = add_donor_aborh(request->orders[oidx].person_id,request->orders[oidx].assays[aidx].
        new_abo_cd,request->orders[oidx].assays[aidx].new_rh_cd,1,reqdata->active_status_cd,
        cnvtdatetime(current->system_dt_tm),request->event_personnel_id,cnvtdatetime(request->
         event_dt_tm),reqdata->contributor_system_cd,donor_aborh_id)
       IF (stat=1)
        SET gsub_donor_aborh_status = "OK"
       ELSEIF (stat=0)
        SET gsub_donor_aborh_status = "FA"
        RETURN(0)
       ELSE
        SET gsub_donor_aborh_status = "FS"
        RETURN(0)
       ENDIF
       SET write_aborh_result = "Y"
      ENDIF
     ENDIF
    ELSEIF (abo_rh_test="Y")
     SET gsub_donor_aborh_status = "  "
     SET gsub_donor_aborh_inact_status = " "
     IF ((request->orders[oidx].assays[aidx].orig_abo_cd=0)
      AND (request->orders[oidx].assays[aidx].orig_rh_cd=0))
      SET write_aborh_result = "Y"
      SET stat = add_donor_aborh(request->orders[oidx].person_id,request->orders[oidx].assays[aidx].
       new_abo_cd,request->orders[oidx].assays[aidx].new_rh_cd,1,reqdata->active_status_cd,
       cnvtdatetime(current->system_dt_tm),request->event_personnel_id,cnvtdatetime(request->
        event_dt_tm),reqdata->contributor_system_cd,donor_aborh_id)
      IF (stat=1)
       SET gsub_donor_aborh_status = "OK"
      ELSEIF (stat=0)
       SET gsub_donor_aborh_status = "FA"
       RETURN(0)
      ELSE
       SET gsub_donor_aborh_status = "FS"
       RETURN(0)
      ENDIF
     ELSE
      IF ((request->orders[oidx].assays[aidx].new_abo_cd=request->orders[oidx].assays[aidx].
      orig_abo_cd))
       IF ((request->orders[oidx].assays[aidx].new_rh_cd=request->orders[oidx].assays[aidx].
       orig_rh_cd))
        SET write_aborh_result = "Y"
       ELSE
        SET stat = chg_donor_aborh(request->orders[oidx].person_id,request->orders[oidx].assays[aidx]
         .orig_abo_cd,request->orders[oidx].assays[aidx].orig_rh_cd,0,reqdata->inactive_status_cd,
         request->orders[oidx].assays[aidx].person_aborh_updt_cnt)
        IF (stat=1)
         SET gsub_donor_aborh_inact_status = "OK"
        ELSEIF (stat=2)
         SET gsub_donor_aborh_inact_status = "FL"
         RETURN(0)
        ELSE
         SET gsub_donor_aborh_inact_status = "FU"
         RETURN(0)
        ENDIF
        SET stat = add_donor_aborh(request->orders[oidx].person_id,request->orders[oidx].assays[aidx]
         .new_abo_cd,request->orders[oidx].assays[aidx].new_rh_cd,1,reqdata->active_status_cd,
         cnvtdatetime(current->system_dt_tm),request->event_personnel_id,cnvtdatetime(request->
          event_dt_tm),reqdata->contributor_system_cd,donor_aborh_id)
        IF (stat=1)
         SET gsub_donor_aborh_status = "OK"
        ELSEIF (stat=0)
         SET gsub_donor_aborh_status = "FA"
         RETURN(0)
        ELSE
         SET gsub_donor_aborh_status = "FS"
         RETURN(0)
        ENDIF
        SET write_aborh_result = "Y"
       ENDIF
      ELSE
       SET stat = chg_donor_aborh(request->orders[oidx].person_id,request->orders[oidx].assays[aidx].
        orig_abo_cd,request->orders[oidx].assays[aidx].orig_rh_cd,0,reqdata->inactive_status_cd,
        request->orders[oidx].assays[aidx].person_aborh_updt_cnt)
       IF (stat=1)
        SET gsub_donor_aborh_inact_status = "OK"
       ELSEIF (stat=2)
        SET gsub_donor_aborh_inact_status = "FL"
        RETURN(0)
       ELSE
        SET gsub_donor_aborh_inact_status = "FU"
        RETURN(0)
       ENDIF
       SET stat = add_donor_aborh(request->orders[oidx].person_id,request->orders[oidx].assays[aidx].
        new_abo_cd,request->orders[oidx].assays[aidx].new_rh_cd,1,reqdata->active_status_cd,
        cnvtdatetime(current->system_dt_tm),request->event_personnel_id,cnvtdatetime(request->
         event_dt_tm),reqdata->contributor_system_cd,donor_aborh_id)
       IF (stat=1)
        SET gsub_donor_aborh_status = "OK"
       ELSEIF (stat=0)
        SET gsub_donor_aborh_status = "FA"
        RETURN(0)
       ELSE
        SET gsub_donor_aborh_status = "FS"
        RETURN(0)
       ENDIF
       SET write_aborh_result = "Y"
      ENDIF
     ENDIF
    ENDIF
   ELSE
    IF ((request->orders[oidx].assays[aidx].upd_don_hist_aborh_yn="N"))
     SET write_aborh_result = "Y"
    ENDIF
   ENDIF
   SET gsub_aborh_result_status = "  "
   IF (write_aborh_result="Y")
    SET write_aborh_result = "N"
    SET stat = add_donor_aborh_result(0.0,0.0,cnvtdatetime(request->orders[oidx].assays[aidx].
      drawn_dt_tm),0.0,request->orders[oidx].person_id,
     request->orders[oidx].encntr_id,reply->orders[oidx].assays[aidx].result_id,request->orders[oidx]
     .assays[aidx].bb_result_code_set_cd,1,reqdata->active_status_cd,
     cnvtdatetime(current->system_dt_tm),request->event_personnel_id,reqdata->contributor_system_cd,
     donor_aborh_id)
    IF (stat=1)
     SET gsub_aborh_result_status = "OK"
    ELSEIF (stat=0)
     SET gsub_aborh_result_status = "FA"
     RETURN(0)
    ELSE
     SET gsub_aborh_result_status = "FS"
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 DECLARE update_product_aborh(none5) = i4
 SUBROUTINE update_product_aborh(none5)
   IF ((request->orders[oidx].assays[aidx].upd_blood_product_yn="Y"))
    SET current_updated_ind = 1
    SET product_rh_test_only = "N"
    SET product_abo_test_only = "N"
    SET product_abo_rh_test = "N"
    SET product_aborh_to_no_type = "N"
    SET write_result = "N"
    IF ((request->orders[oidx].assays[aidx].product_new_abo_cd=0)
     AND (request->orders[oidx].assays[aidx].product_new_rh_cd=0))
     SET product_aborh_to_no_type = "Y"
    ELSEIF ((request->orders[oidx].assays[aidx].product_new_abo_cd=0))
     SET product_rh_test_only = "Y"
    ELSE
     IF ((request->orders[oidx].assays[aidx].product_new_rh_cd=0))
      SET product_abo_test_only = "Y"
     ELSE
      SET product_abo_rh_test = "Y"
     ENDIF
    ENDIF
    IF (product_rh_test_only="Y")
     IF ((request->orders[oidx].assays[aidx].product_new_rh_cd=request->orders[oidx].assays[aidx].
     product_orig_rh_cd))
      SET write_result = "Y"
     ELSE
      SET gsub_blood_product_status = "  "
      CALL upd_blood_product(modproductlist->product[midx].product_id,request->orders[oidx].assays[
       aidx].product_orig_abo_cd,request->orders[oidx].assays[aidx].product_new_rh_cd,1,
       IF ((modproductlist->product[midx].product_id=mod_product_id)) request->orders[oidx].assays[
        aidx].blood_product_updt_cnt
       ELSE modproductlist->product[midx].bp_updt_cnt
       ENDIF
       ,
       1)
      IF (gsub_blood_product_status != "OK")
       RETURN(0)
      ENDIF
      SET write_result = "Y"
     ENDIF
    ELSEIF (product_abo_test_only="Y")
     SET gsub_blood_product_status = "  "
     IF ((request->orders[oidx].assays[aidx].product_new_abo_cd=request->orders[oidx].assays[aidx].
     product_orig_abo_cd))
      SET write_result = "Y"
     ELSE
      IF ((request->orders[oidx].assays[aidx].product_orig_abo_cd=0))
       CALL upd_blood_product(modproductlist->product[midx].product_id,request->orders[oidx].assays[
        aidx].product_new_abo_cd,request->orders[oidx].assays[aidx].product_orig_rh_cd,1,
        IF ((modproductlist->product[midx].product_id=mod_product_id)) request->orders[oidx].assays[
         aidx].blood_product_updt_cnt
        ELSE modproductlist->product[midx].bp_updt_cnt
        ENDIF
        ,
        1)
       IF (gsub_blood_product_status != "OK")
        RETURN(0)
       ENDIF
       SET write_result = "Y"
      ELSE
       CALL upd_blood_product(modproductlist->product[midx].product_id,request->orders[oidx].assays[
        aidx].product_new_abo_cd,request->orders[oidx].assays[aidx].product_new_rh_cd,1,
        IF ((modproductlist->product[midx].product_id=mod_product_id)) request->orders[oidx].assays[
         aidx].blood_product_updt_cnt
        ELSE modproductlist->product[midx].bp_updt_cnt
        ENDIF
        ,
        1)
       IF (gsub_blood_product_status != "OK")
        RETURN(0)
       ENDIF
       SET write_result = "Y"
      ENDIF
     ENDIF
    ELSEIF (product_abo_rh_test="Y")
     SET gsub_blood_product_status = "  "
     IF ((request->orders[oidx].assays[aidx].product_orig_abo_cd=0)
      AND (request->orders[oidx].assays[aidx].product_orig_rh_cd=0))
      CALL upd_blood_product(modproductlist->product[midx].product_id,request->orders[oidx].assays[
       aidx].product_new_abo_cd,request->orders[oidx].assays[aidx].product_new_rh_cd,1,
       IF ((modproductlist->product[midx].product_id=mod_product_id)) request->orders[oidx].assays[
        aidx].blood_product_updt_cnt
       ELSE modproductlist->product[midx].bp_updt_cnt
       ENDIF
       ,
       1)
      IF (gsub_blood_product_status != "OK")
       RETURN(0)
      ENDIF
      SET write_result = "Y"
     ELSE
      IF ((request->orders[oidx].assays[aidx].product_new_abo_cd=request->orders[oidx].assays[aidx].
      product_orig_abo_cd))
       IF ((request->orders[oidx].assays[aidx].product_new_rh_cd=request->orders[oidx].assays[aidx].
       product_orig_rh_cd))
        SET write_result = "Y"
       ELSE
        CALL upd_blood_product(modproductlist->product[midx].product_id,request->orders[oidx].assays[
         aidx].product_new_abo_cd,request->orders[oidx].assays[aidx].product_new_rh_cd,1,
         IF ((modproductlist->product[midx].product_id=mod_product_id)) request->orders[oidx].assays[
          aidx].blood_product_updt_cnt
         ELSE modproductlist->product[midx].bp_updt_cnt
         ENDIF
         ,
         1)
        IF (gsub_blood_product_status != "OK")
         RETURN(0)
        ENDIF
        SET write_result = "Y"
       ENDIF
      ELSE
       CALL upd_blood_product(modproductlist->product[midx].product_id,request->orders[oidx].assays[
        aidx].product_new_abo_cd,request->orders[oidx].assays[aidx].product_new_rh_cd,1,
        IF ((modproductlist->product[midx].product_id=mod_product_id)) request->orders[oidx].assays[
         aidx].blood_product_updt_cnt
        ELSE modproductlist->product[midx].bp_updt_cnt
        ENDIF
        ,
        1)
       IF (gsub_blood_product_status != "OK")
        RETURN(0)
       ENDIF
       SET write_result = "Y"
      ENDIF
     ENDIF
    ELSEIF (product_aborh_to_no_type="Y")
     SET gsub_blood_product_status = "  "
     CALL upd_blood_product(modproductlist->product[midx].product_id,request->orders[oidx].assays[
      aidx].product_new_abo_cd,request->orders[oidx].assays[aidx].product_new_rh_cd,1,
      IF ((modproductlist->product[midx].product_id=mod_product_id)) request->orders[oidx].assays[
       aidx].blood_product_updt_cnt
      ELSE modproductlist->product[midx].bp_updt_cnt
      ENDIF
      ,
      1)
     IF (gsub_blood_product_status != "OK")
      RETURN(0)
     ENDIF
     SET write_result = "Y"
    ENDIF
   ELSE
    IF ((request->orders[oidx].assays[aidx].upd_blood_product_yn="N"))
     SET write_result = "Y"
     SET current_updated_ind = 0
    ENDIF
   ENDIF
   IF (write_result="Y")
    SET write_result = "N"
    CALL add_abo_testing(modproductlist->product[midx].product_id,reply->orders[oidx].assays[aidx].
     result_id,request->orders[oidx].assays[aidx].product_new_abo_cd,request->orders[oidx].assays[
     aidx].product_new_rh_cd,0,
     current_updated_ind,1,reqdata->active_status_cd,cnvtdatetime(current->system_dt_tm),request->
     event_personnel_id)
    IF (gsub_abo_testing_status != "OK")
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 DECLARE update_bb_order_cell(arg_bb_result_id) = i4
 SUBROUTINE update_bb_order_cell(arg_bb_result_id)
   SET return_value = 0
   SET cur_updt_cnt = 0
   SELECT INTO "nl:"
    oc.order_cell_id
    FROM bb_order_cell oc
    WHERE (oc.order_cell_id=request->orders[oidx].assays[aidx].order_cell_id)
     AND (oc.order_id=request->orders[oidx].order_id)
    DETAIL
     cur_updt_cnt = oc.updt_cnt
    WITH nocounter, forupdate(oc)
   ;end select
   IF (curqual=0)
    SET failed = "T"
    SET status_count = (status_count+ 1)
    IF (status_count > 1)
     SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
    ENDIF
    SET reply->status_data.subeventstatus[status_count].operationname = "CHANGE"
    SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
    SET reply->status_data.subeventstatus[status_count].targetobjectname = "BB Order Cell"
    SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
    "Unable to lock BB Order Cell"
    SET return_value = 0
   ELSEIF ((cur_updt_cnt != request->orders[oidx].assays[aidx].order_cell_updt_cnt))
    SET failed = "T"
    SET status_count = (status_count+ 1)
    IF (status_count > 1)
     SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
    ENDIF
    SET reply->status_data.subeventstatus[status_count].operationname = "CHANGE"
    SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
    SET reply->status_data.subeventstatus[status_count].targetobjectname = "BB Order Cell"
    SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
    "Update conflict on BB Order Cell"
    SET return_value = 0
   ELSE
    UPDATE  FROM bb_order_cell oc
     SET oc.bb_result_id = arg_bb_result_id, oc.updt_dt_tm = cnvtdatetime(curdate,curtime3), oc
      .updt_id = reqinfo->updt_id,
      oc.updt_task = reqinfo->updt_task, oc.updt_applctx = reqinfo->updt_applctx, oc.updt_cnt = (oc
      .updt_cnt+ 1)
     WHERE (oc.order_cell_id=request->orders[oidx].assays[aidx].order_cell_id)
      AND (oc.order_id=request->orders[oidx].order_id)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET failed = "T"
     SET status_count = (status_count+ 1)
     IF (status_count > 1)
      SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
     ENDIF
     SET reply->status_data.subeventstatus[status_count].operationname = "CHANGE"
     SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
     SET reply->status_data.subeventstatus[status_count].targetobjectname = "BB Order Cell"
     SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
     "Unable to update BB Order Cell"
     SET return_value = 0
    ELSE
     SET return_value = 1
     SET order_cell_prev_update = "Y"
     SET reply->orders[oidx].assays[aidx].order_cell_updt_cnt = (request->orders[oidx].assays[aidx].
     order_cell_updt_cnt+ 1)
    ENDIF
   ENDIF
   RETURN(return_value)
 END ;Subroutine
 DECLARE execute_maintain_review_items(none=i2) = i2
 SUBROUTINE execute_maintain_review_items(none)
   EXECUTE pcs_maintain_review_items  WITH replace(request,request), replace(reply,
    review_maintain_rep)
   IF ((review_maintain_rep->status_data.status != "S"))
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = review_maintain_rep->status_data.
    subeventstatus[1].operationname
    SET reply->status_data.subeventstatus[1].operationstatus = review_maintain_rep->status_data.
    subeventstatus[1].operationstatus
    SET reply->status_data.subeventstatus[1].targetobjectname = review_maintain_rep->status_data.
    subeventstatus[1].targetobjectname
    SET reply->status_data.subeventstatus[1].targetobjectvalue = review_maintain_rep->status_data.
    subeventstatus[1].targetobjectvalue
    RETURN(0)
   ENDIF
   RETURN(1)
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
      pe.updt_dt_tm = cnvtdatetime(curdate,curtime3), pe.updt_id = reqinfo->updt_id, pe.updt_task =
      reqinfo->updt_task,
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
 SUBROUTINE add_bbd_exception(prod_event_id,exception_type_mean,sub_override_reason_cd,
  sub_event_type_cd,sub_result_id,sub_perform_result_id,sub_from_abo_cd,sub_from_rh_cd,sub_to_abo_cd,
  sub_to_rh_cd,sub_person_id)
   SET exception_status = "I"
   DECLARE sub_exception_type_cd = f8 WITH protect, noconstant(0.0)
   DECLARE bb_exception_id = f8 WITH protect, noconstant(0.0)
   DECLARE except_type_mean = c12
   SET except_type_mean = fillstring(12," ")
   SET except_type_mean = exception_type_mean
   SET stat = uar_get_meaning_by_codeset(14072,nullterm(except_type_mean),1,sub_exception_type_cd)
   IF (sub_exception_type_cd=0.0)
    SET exception_status = "FU"
   ELSE
    DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
    SET new_pathnet_seq = 0
    SELECT INTO "nl:"
     seqn = seq(pathnet_seq,nextval)
     FROM dual
     DETAIL
      new_pathnet_seq = seqn
     WITH format, nocounter
    ;end select
    SET bb_exception_id = new_pathnet_seq
    INSERT  FROM bb_exception b
     SET b.exception_id = bb_exception_id, b.product_event_id = prod_event_id, b.exception_type_cd =
      sub_exception_type_cd,
      b.event_type_cd = sub_event_type_cd, b.from_abo_cd = sub_from_abo_cd, b.from_rh_cd =
      sub_from_rh_cd,
      b.to_abo_cd = sub_to_abo_cd, b.to_rh_cd = sub_to_rh_cd, b.override_reason_cd =
      sub_override_reason_cd,
      b.result_id = sub_result_id, b.perform_result_id = sub_perform_result_id, b.updt_cnt = 0,
      b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_task =
      reqinfo->updt_task,
      b.updt_applctx = reqinfo->updt_applctx, b.active_ind = 1, b.active_status_cd = reqdata->
      active_status_cd,
      b.active_status_dt_tm = cnvtdatetime(curdate,curtime3), b.active_status_prsnl_id = reqinfo->
      updt_id, b.person_id = sub_person_id,
      b.donor_contact_id = 0.0, b.donor_contact_type_cd = 0.0, b.exception_dt_tm = cnvtdatetime(
       curdate,curtime3)
     WITH counter
    ;end insert
    IF (curqual=0)
     SET exception_status = "F"
    ELSE
     SET exception_status = "S"
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE add_reqs_exception(sub_special_testing_cd,sub_requirement_cd)
   DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
   SET new_pathnet_seq = 0
   SELECT INTO "nl:"
    seqn = seq(pathnet_seq,nextval)
    FROM dual
    DETAIL
     new_pathnet_seq = seqn
    WITH format, nocounter
   ;end select
   INSERT  FROM bb_reqs_exception b
    SET b.reqs_exception_id = new_pathnet_seq, b.exception_id = bb_exception_id, b.special_testing_cd
      = sub_special_testing_cd,
     b.requirement_cd = sub_requirement_cd, b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(curdate,
      curtime3),
     b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->
     updt_applctx,
     b.active_ind = 1, b.active_status_cd = reqdata->active_status_cd, b.active_status_dt_tm =
     cnvtdatetime(curdate,curtime3),
     b.active_status_prsnl_id = reqinfo->updt_id
    WITH counter
   ;end insert
   IF (curqual=0)
    SET exception_status = "F"
   ELSE
    SET exception_status = "S"
   ENDIF
 END ;Subroutine
 SUBROUTINE add_autodir_reqs_exception(sub_product_id)
   DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
   SET new_pathnet_seq = 0
   SELECT INTO "nl:"
    seqn = seq(pathnet_seq,nextval)
    FROM dual
    DETAIL
     new_pathnet_seq = seqn
    WITH format, nocounter
   ;end select
   DECLARE sub_bb_exception_id = f8 WITH protect, noconstant(0.0)
   SET sub_bb_exception_id = bb_exception_id
   INSERT  FROM bb_autodir_exception b
    SET b.bb_autodir_exc_id = new_pathnet_seq, b.bb_exception_id = sub_bb_exception_id, b.product_id
      = sub_product_id,
     b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id,
     b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx, b.active_ind = 1,
     b.active_status_cd = reqdata->active_status_cd, b.active_status_dt_tm = cnvtdatetime(curdate,
      curtime3), b.active_status_prsnl_id = reqinfo->updt_id
    WITH counter
   ;end insert
   IF (curqual=0)
    SET exception_status = "F"
   ELSE
    SET exception_status = "S"
   ENDIF
 END ;Subroutine
 DECLARE add_bbd_inactive_exception(prod_event_id,exception_type_mean,sub_override_reason_cd,
  sub_event_type_cd,sub_result_id,
  sub_perform_result_id,sub_from_abo_cd,sub_from_rh_cd,sub_to_abo_cd,sub_to_rh_cd,
  sub_person_id) = null
 SUBROUTINE add_bbd_inactive_exception(prod_event_id,exception_type_mean,sub_override_reason_cd,
  sub_event_type_cd,sub_result_id,sub_perform_result_id,sub_from_abo_cd,sub_from_rh_cd,sub_to_abo_cd,
  sub_to_rh_cd,sub_person_id)
   SET exception_status = "I"
   DECLARE sub_exception_type_cd = f8 WITH protect, noconstant(0.0)
   DECLARE bb_exception_id = f8 WITH protect, noconstant(0.0)
   DECLARE except_type_mean = c12
   SET except_type_mean = fillstring(12," ")
   SET except_type_mean = exception_type_mean
   SET stat = uar_get_meaning_by_codeset(14072,nullterm(except_type_mean),1,sub_exception_type_cd)
   IF (sub_exception_type_cd=0.0)
    SET exception_status = "FU"
   ELSE
    DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
    SET new_pathnet_seq = 0
    SELECT INTO "nl:"
     seqn = seq(pathnet_seq,nextval)
     FROM dual
     DETAIL
      new_pathnet_seq = seqn
     WITH format, nocounter
    ;end select
    SET bb_exception_id = new_pathnet_seq
    INSERT  FROM bb_exception b
     SET b.exception_id = bb_exception_id, b.product_event_id = prod_event_id, b.exception_type_cd =
      sub_exception_type_cd,
      b.event_type_cd = sub_event_type_cd, b.from_abo_cd = sub_from_abo_cd, b.from_rh_cd =
      sub_from_rh_cd,
      b.to_abo_cd = sub_to_abo_cd, b.to_rh_cd = sub_to_rh_cd, b.override_reason_cd =
      sub_override_reason_cd,
      b.result_id = sub_result_id, b.perform_result_id = sub_perform_result_id, b.updt_cnt = 0,
      b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_task =
      reqinfo->updt_task,
      b.updt_applctx = reqinfo->updt_applctx, b.active_ind = 0, b.active_status_cd = reqdata->
      active_status_cd,
      b.active_status_dt_tm = cnvtdatetime(curdate,curtime3), b.active_status_prsnl_id = reqinfo->
      updt_id, b.person_id = sub_person_id,
      b.donor_contact_id = 0.0, b.donor_contact_type_cd = 0.0, b.exception_dt_tm = cnvtdatetime(
       curdate,curtime3)
     WITH counter
    ;end insert
    IF (curqual=0)
     SET exception_status = "F"
    ELSE
     SET exception_status = "S"
    ENDIF
   ENDIF
 END ;Subroutine
 DECLARE activate_bbd_exception(sub_exception_id=f8,sub_updt_cnt=i4) = null
 SUBROUTINE activate_bbd_exception(sub_exception_id,sub_updt_cnt)
   SET exception_status = "I"
   SELECT INTO "nl:"
    b.exception_id
    FROM bb_exception b
    WHERE b.exception_id=sub_exception_id
     AND b.active_ind=0
     AND b.updt_cnt=sub_updt_cnt
    WITH nocounter, forupdate(b)
   ;end select
   IF (curqual=0)
    SET exception_status = "FL"
   ENDIF
   IF (curqual=1)
    UPDATE  FROM bb_exception b
     SET b.active_ind = 1, b.active_status_cd = reqdata->active_status_cd, b.updt_cnt = (b.updt_cnt+
      1),
      b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_task =
      reqinfo->updt_task,
      b.updt_applctx = reqinfo->updt_applctx
     WHERE b.exception_id=sub_exception_id
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET exception_status = "F"
    ELSE
     SET exception_status = "S"
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE add_special_testing(sub_product_id,sub_special_testing_cd,sub_confirmed_ind,
  sub_rh_phenotype_id,sub_active_ind,sub_active_status_cd,sub_active_status_dt_tm,
  sub_active_status_prsnl_id,sub_check_for_duplicate_yn)
   SET gsub_special_testing_status = "  "
   SET new_special_testing_id = 0.0
   SET confirmed_ind = 0
   IF (sub_check_for_duplicate_yn="Y")
    SELECT INTO "nl:"
     s.special_testing_id, s.product_id, s.special_testing_cd,
     s.confirmed_ind
     FROM special_testing s
     WHERE s.product_id=sub_product_id
      AND s.special_testing_cd=sub_special_testing_cd
      AND s.active_ind=1
     DETAIL
      new_special_testing_id = s.special_testing_id, confirmed_ind = s.confirmed_ind
     WITH nocounter
    ;end select
   ENDIF
   IF (((curqual=0) OR (sub_check_for_duplicate_yn != "Y")) )
    SET new_special_testing_id = next_pathnet_seq(0)
    IF (curqual=0)
     SET gsub_special_testing_status = "FS"
    ELSE
     INSERT  FROM special_testing s
      SET s.special_testing_id = new_special_testing_id, s.product_id = sub_product_id, s
       .special_testing_cd = sub_special_testing_cd,
       s.confirmed_ind = sub_confirmed_ind, s.product_rh_phenotype_id = sub_rh_phenotype_id, s
       .active_ind = sub_active_ind,
       s.active_status_cd = sub_active_status_cd, s.active_status_dt_tm = cnvtdatetime(
        sub_active_status_dt_tm), s.active_status_prsnl_id = sub_active_status_prsnl_id,
       s.updt_dt_tm = cnvtdatetime(curdate,curtime3), s.updt_id = reqinfo->updt_id, s.updt_cnt = 0,
       s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET gsub_special_testing_status = "FA"
     ELSE
      SET gsub_special_testing_status = "OK"
     ENDIF
    ENDIF
   ELSE
    IF (confirmed_ind=1)
     SET gsub_special_testing_status = "OK"
    ELSE
     SELECT INTO "nl:"
      s.special_testing_id
      FROM special_testing s
      WHERE s.special_testing_id=new_special_testing_id
      WITH nocounter, forupdate(s)
     ;end select
     IF (curqual=0)
      SET gsub_special_testing_status = "FL"
     ELSE
      UPDATE  FROM special_testing s
       SET s.confirmed_ind = sub_confirmed_ind, s.updt_cnt = (s.updt_cnt+ 1), s.updt_dt_tm =
        cnvtdatetime(curdate,curtime3),
        s.updt_id = reqinfo->updt_id, s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo->
        updt_applctx
       WHERE s.special_testing_id=new_special_testing_id
       WITH nocounter
      ;end update
      IF (curqual=0)
       SET gsub_special_testing_status = "FU"
      ELSE
       SET gsub_special_testing_status = "OK"
      ENDIF
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE add_special_testing_result(sub_special_testing_id,sub_product_id,sub_result_id,
  sub_bb_result_id,sub_active_ind,sub_active_status_cd,sub_active_status_dt_tm,
  sub_active_status_prsnl_id)
   SET gsub_spc_tst_result_status = "  "
   INSERT  FROM special_testing_result str
    SET str.special_testing_id = sub_special_testing_id, str.product_id = sub_product_id, str
     .result_id = sub_result_id,
     str.bb_result_id = sub_bb_result_id, str.active_ind = sub_active_ind, str.active_status_cd =
     sub_active_status_cd,
     str.active_status_dt_tm = cnvtdatetime(sub_active_status_dt_tm), str.active_status_prsnl_id =
     sub_active_status_prsnl_id, str.updt_cnt = 0,
     str.updt_dt_tm = cnvtdatetime(curdate,curtime3), str.updt_id = reqinfo->updt_id, str.updt_task
      = reqinfo->updt_task,
     str.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET gsub_spc_tst_result_status = "FA"
   ELSE
    SET gsub_spc_tst_result_status = "OK"
   ENDIF
 END ;Subroutine
 SUBROUTINE upd_blood_product(sub_product_id,sub_abo_cd,sub_rh_cd,sub_active_ind,sub_updt_cnt,
  sub_lock_forupdate_ind)
   SET gsub_blood_product_status = "  "
   IF (sub_lock_forupdate_ind=1)
    SELECT INTO "nl:"
     p.product_id
     FROM blood_product p
     WHERE p.product_id=sub_product_id
      AND p.active_ind=1
      AND p.updt_cnt=sub_updt_cnt
     WITH nocounter, forupdate(p)
    ;end select
    IF (curqual=0)
     SET gsub_blood_product_status = "FL"
    ENDIF
   ENDIF
   IF (((sub_lock_forupdate_ind=0) OR (sub_lock_forupdate_ind=1
    AND curqual > 0)) )
    UPDATE  FROM blood_product p
     SET p.cur_abo_cd = sub_abo_cd, p.cur_rh_cd = sub_rh_cd, p.updt_cnt = (p.updt_cnt+ 1),
      p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id = reqinfo->updt_id, p.updt_task =
      reqinfo->updt_task,
      p.updt_applctx = reqinfo->updt_applctx
     WHERE p.product_id=sub_product_id
      AND p.updt_cnt=sub_updt_cnt
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET gsub_blood_product_status = "FU"
    ELSE
     SET gsub_blood_product_status = "OK"
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE add_abo_testing(sub_product_id,sub_result_id,sub_abo_cd,sub_rh_cd,sub_product_event_id,
  sub_current_updated_ind,sub_active_ind,sub_active_status_cd,sub_active_status_dt_tm,
  sub_active_status_prsnl_id)
   SET gsub_abo_testing_status = "  "
   SET unique_id = 0.0
   SET unique_id = next_pathnet_seq(0)
   IF (curqual > 0)
    INSERT  FROM abo_testing a
     SET a.abo_testing_id = unique_id, a.product_id = sub_product_id, a.result_id = sub_result_id,
      a.abo_group_cd = sub_abo_cd, a.rh_type_cd = sub_rh_cd, a.product_event_id =
      sub_product_event_id,
      a.current_updated_ind = sub_current_updated_ind, a.active_ind = sub_active_ind, a
      .active_status_cd = sub_active_status_cd,
      a.active_status_dt_tm = cnvtdatetime(sub_active_status_dt_tm), a.active_status_prsnl_id =
      sub_active_status_prsnl_id, a.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      a.updt_id = reqinfo->updt_id, a.updt_cnt = 0, a.updt_task = reqinfo->updt_task,
      a.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET gsub_abo_testing_status = "FA"
    ELSE
     SET gsub_abo_testing_status = "OK"
    ENDIF
   ELSE
    SET gsub_abo_testing_status = "FS"
   ENDIF
 END ;Subroutine
 SUBROUTINE bbd_get_rh_phenotype_antigens(sub_nomenclature_id)
   SET gsub_bbd_rh_phenotype_status = "  "
   SET select_ok_ind = 0
   SET rh_a_cnt = 0
   SET stat = alterlist(rh_a_rec->antigenlist,0)
   SELECT INTO "nl:"
    brp.fr_nomenclature_id, brpt.special_testing_cd
    FROM bb_rh_phenotype brp,
     bb_rh_pheno_testing brpt
    PLAN (brp
     WHERE ((brp.fr_nomenclature_id=sub_nomenclature_id) OR (brp.w_nomenclature_id=
     sub_nomenclature_id))
      AND brp.active_ind=1)
     JOIN (brpt
     WHERE brpt.rh_phenotype_id=brp.rh_phenotype_id
      AND brpt.active_ind=1)
    HEAD REPORT
     select_ok_ind = 0, rh_a_cnt = 0
    DETAIL
     rh_a_cnt = (rh_a_cnt+ 1), stat = alterlist(rh_a_rec->antigenlist,rh_a_cnt), rh_a_rec->
     antigenlist[rh_a_cnt].antigen_cd = brpt.special_testing_cd
    FOOT REPORT
     select_ok_ind = 1
    WITH nocounter
   ;end select
   IF (select_ok_ind != 1)
    SET gsub_bbd_rh_phenotype_status = "FF"
   ELSE
    SET gsub_bbd_rh_phenotype_status = "OK"
   ENDIF
 END ;Subroutine
 SUBROUTINE get_rh_phenotype_antigens(sub_rh_phenotype_id)
   SET gsub_rh_phenotype_status = "  "
   SET select_ok_ind = 0
   SET rh_a_cnt = 0
   SET stat = alterlist(rh_a_rec->antigenlist,0)
   SET stat = alterlist(rh_a_rec->antigenlist,10)
   SELECT INTO "nl:"
    brpt.special_testing_cd
    FROM bb_rh_pheno_testing brpt
    WHERE brpt.rh_phenotype_id=sub_rh_phenotype_id
     AND brpt.active_ind=1
    HEAD REPORT
     select_ok_ind = 0, rh_a_cnt = 0
    DETAIL
     rh_a_cnt = (rh_a_cnt+ 1)
     IF (mod(rh_a_cnt,10)=1
      AND rh_a_cnt != 1)
      stat = alterlist(rh_a_rec->antigenlist,(rh_a_cnt+ 9))
     ENDIF
     rh_a_rec->antigenlist[rh_a_cnt].antigen_cd = brpt.special_testing_cd
    FOOT REPORT
     stat = alterlist(rh_a_rec->antigenlist,rh_a_cnt), select_ok_ind = 1
    WITH nocounter, nullreport
   ;end select
   IF (select_ok_ind != 1)
    SET gsub_rh_phenotype_status = "FF"
   ELSE
    SET gsub_rh_phenotype_status = "OK"
   ENDIF
 END ;Subroutine
 SUBROUTINE bbd_get_rh_phenotype_antigens(sub_nomenclature_id)
   SET gsub_bbd_rh_phenotype_status = "  "
   SET select_ok_ind = 0
   SET rh_a_cnt = 0
   SET stat = alterlist(rh_a_rec->antigenlist,0)
   SELECT INTO "nl:"
    brp.fr_nomenclature_id, brpt.special_testing_cd
    FROM bb_rh_phenotype brp,
     bb_rh_pheno_testing brpt
    PLAN (brp
     WHERE ((brp.fr_nomenclature_id=sub_nomenclature_id) OR (brp.w_nomenclature_id=
     sub_nomenclature_id))
      AND brp.active_ind=1)
     JOIN (brpt
     WHERE brpt.rh_phenotype_id=brp.rh_phenotype_id
      AND brpt.active_ind=1)
    HEAD REPORT
     select_ok_ind = 0, rh_a_cnt = 0
    DETAIL
     rh_a_cnt = (rh_a_cnt+ 1), stat = alterlist(rh_a_rec->antigenlist,rh_a_cnt), rh_a_rec->
     antigenlist[rh_a_cnt].antigen_cd = brpt.special_testing_cd
    FOOT REPORT
     select_ok_ind = 1
    WITH nocounter
   ;end select
   IF (select_ok_ind != 1)
    SET gsub_bbd_rh_phenotype_status = "FF"
   ELSE
    SET gsub_bbd_rh_phenotype_status = "OK"
   ENDIF
 END ;Subroutine
 SUBROUTINE add_product_rh_phenotype(sub_product_id,sub_nomenclature_id,sub_active_ind,
  sub_active_status_cd,sub_active_status_dt_tm,sub_active_status_prsnl_id)
   SET gsub_rh_phenotype_status = "  "
   SET bb_rh_phenotype_id = 0.0
   SET select_ok_ind = 0
   SET brp_qual_cnt = 0
   SELECT INTO "nl:"
    brp.rh_phenotype_id
    FROM bb_rh_phenotype brp
    WHERE ((brp.fr_nomenclature_id=sub_nomenclature_id) OR (brp.w_nomenclature_id=sub_nomenclature_id
    ))
     AND brp.active_ind=1
    HEAD REPORT
     select_ok_ind = 0, brp_qual_cnt = 0
    DETAIL
     brp_qual_cnt = (brp_qual_cnt+ 1), bb_rh_phenotype_id = brp.rh_phenotype_id
    FOOT REPORT
     select_ok_ind = 1
    WITH nocounter, nullreport
   ;end select
   IF (select_ok_ind=1)
    IF (brp_qual_cnt=0)
     SET gsub_rh_phenotype_status = "FZ"
    ELSEIF (brp_qual_cnt > 1)
     SET gsub_rh_phenotype_status = "FM"
    ENDIF
   ELSE
    SET gsub_rh_phenotype_status = "FF"
   ENDIF
   IF (trim(gsub_rh_phenotype_status)="")
    SET new_rh_phenotype_id = 0.0
    SET new_rh_phenotype_id = next_pathnet_seq(0)
    IF (curqual=0)
     SET gsub_rh_phenotype_status = "FS"
    ELSE
     INSERT  FROM product_rh_phenotype prp
      SET prp.product_rh_phenotype_id = new_rh_phenotype_id, prp.product_id = sub_product_id, prp
       .rh_phenotype_id = bb_rh_phenotype_id,
       prp.nomenclature_id = sub_nomenclature_id, prp.updt_cnt = 0, prp.updt_dt_tm = cnvtdatetime(
        curdate,curtime3),
       prp.updt_id = reqinfo->updt_id, prp.updt_task = reqinfo->updt_task, prp.updt_applctx = reqinfo
       ->updt_applctx,
       prp.active_ind = sub_active_ind, prp.active_status_cd = sub_active_status_cd, prp
       .active_status_dt_tm = cnvtdatetime(sub_active_status_dt_tm),
       prp.active_status_prsnl_id = sub_active_status_prsnl_id
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET gsub_rh_phenotype_status = "FA"
     ELSE
      SET gsub_rh_phenotype_status = "OK"
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE chg_product_rh_phenotype(sub_rh_phenotype_id,sub_updt_cnt,sub_active_ind,
  sub_active_status_cd)
   SET gsub_rh_phenotype_status = "  "
   SELECT INTO "nl:"
    prp.product_rh_phenotype_id
    FROM product_rh_phenotype prp
    WHERE prp.product_rh_phenotype_id=sub_rh_phenotype_id
     AND prp.updt_cnt=sub_updt_cnt
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET gsub_rh_phenotype_status = "FL"
   ELSE
    UPDATE  FROM product_rh_phenotype prp
     SET prp.updt_cnt = (prp.updt_cnt+ 1), prp.updt_dt_tm = cnvtdatetime(curdate,curtime3), prp
      .updt_id = reqinfo->updt_id,
      prp.updt_task = reqinfo->updt_task, prp.updt_applctx = reqinfo->updt_applctx, prp.active_ind =
      sub_active_ind,
      prp.active_status_cd = sub_active_status_cd
     WHERE prp.product_rh_phenotype_id=sub_rh_phenotype_id
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET gsub_rh_phenotype_status = "FU"
    ELSE
     SET gsub_rh_phenotype_status = "OK"
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE chg_special_testing_by_key(sub_special_testing_id,sub_updt_cnt,sub_active_ind,
  sub_active_status_cd)
   SET gsub_rh_phenotype_status = "  "
   SELECT INTO "nl:"
    st.special_testing_id
    FROM special_testing st
    WHERE st.special_testing_id=sub_special_testing_id
     AND st.updt_cnt=sub_updt_cnt
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET gsub_rh_phenotype_status = "FL"
   ELSE
    UPDATE  FROM special_testing st
     SET st.updt_cnt = (st.updt_cnt+ 1), st.updt_dt_tm = cnvtdatetime(curdate,curtime3), st.updt_id
       = reqinfo->updt_id,
      st.updt_cnt = 0, st.updt_task = reqinfo->updt_task, st.updt_applctx = reqinfo->updt_applctx,
      st.active_ind = sub_active_ind, st.active_status_cd = sub_active_status_cd
     WHERE st.special_testing_id=sub_special_testing_id
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET gsub_rh_phenotype_status = "FU"
    ELSE
     SET gsub_rh_phenotype_status = "OK"
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE update_person_donor(sub_person_id,sub_lock_ind,sub_eligibility_type_ind,
  sub_eligibility_type_cd,sub_defer_until_ind,sub_defer_until_dt_tm,sub_updt_cnt,
  sub_elig_for_reinstate_ind,sub_elig_for_reinstate_yn,sub_reinstated_ind,sub_reinstated_yn,
  sub_current_dt_tm,sub_updt_id,sub_updt_task,sub_updt_applctx)
   SET gsub_person_donor_status = "  "
   SELECT INTO "nl:"
    p.*
    FROM person_donor p
    PLAN (p
     WHERE p.person_id=sub_person_id
      AND p.lock_ind=sub_lock_ind
      AND p.updt_cnt=sub_updt_cnt)
    WITH nocounter, forupdate(p)
   ;end select
   IF (curqual=0)
    SET gsub_person_donor_status = "FL"
   ELSE
    UPDATE  FROM person_donor p
     SET p.eligibility_type_cd =
      IF (sub_eligibility_type_ind=1) sub_eligibility_type_cd
      ELSE p.eligibility_type_cd
      ENDIF
      , p.defer_until_dt_tm =
      IF (sub_defer_until_ind=1)
       IF (((datetimecmp(sub_defer_until_dt_tm,p.defer_until_dt_tm) < 1) OR (p.defer_until_dt_tm=null
       )) ) cnvtdatetime(sub_defer_until_dt_tm)
       ELSE p.defer_until_dt_tm
       ENDIF
      ELSE p.defer_until_dt_tm
      ENDIF
      , p.elig_for_reinstate_ind =
      IF (sub_elig_for_reinstate_yn="Y") sub_elig_for_reinstate_ind
      ELSE p.elig_for_reinstate_ind
      ENDIF
      ,
      p.updt_cnt = (p.updt_cnt+ 1), p.updt_dt_tm = cnvtdatetime(sub_current_dt_tm)
     PLAN (p
      WHERE p.person_id=sub_person_id
       AND p.updt_cnt=sub_updt_cnt)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET gsub_person_donor_status = "FA"
    ELSE
     SET gsub_person_donor_status = "OK"
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE update_donor_eligibility(sub_eligibility_id,sub_updt_contact_ind,sub_contact_id,
  sub_updt_person_ind,sub_person_id,sub_eligibility_type_ind,sub_eligibility_type_cd,sub_eligible_ind,
  sub_eligible_dt_tm,sub_updt_cnt,sub_current_dt_tm,sub_updt_id,sub_updt_task,sub_updt_applctx)
   SET gsub_donor_elig_status = "  "
   SELECT INTO "nl:"
    bde.*
    FROM bbd_donor_eligibility bde
    PLAN (bde
     WHERE bde.eligibility_id=sub_eligibility_id
      AND bde.updt_cnt=sub_updt_cnt)
    WITH nocounter, forupdate(bde)
   ;end select
   IF (curqual=0)
    SET gsub_donor_elig_status = "FL"
   ELSE
    UPDATE  FROM bbd_donor_eligibility bde
     SET bde.contact_id =
      IF (sub_updt_contact_ind=1) sub_contact_id
      ELSE bde.contact_id
      ENDIF
      , bde.person_id =
      IF (sub_updt_person_ind=1) sub_person_id
      ELSE bde.person_id
      ENDIF
      , bde.eligibility_type_cd =
      IF (sub_eligibility_type_ind=1) sub_eligibility_type_cd
      ELSE bde.eligibility_type_cd
      ENDIF
      ,
      bde.eligible_dt_tm =
      IF (sub_eligible_ind=1) cnvtdatetime(sub_eligible_dt_tm)
      ELSE bde.eligible_dt_tm
      ENDIF
      , bde.updt_cnt = (bde.updt_cnt+ 1), bde.updt_dt_tm = cnvtdatetime(sub_current_dt_tm),
      bde.updt_id = sub_updt_id, bde.updt_task = sub_updt_task, bde.updt_applctx = sub_updt_applctx
     PLAN (bde
      WHERE bde.eligibility_id=sub_eligibility_id
       AND bde.updt_cnt=sub_updt_cnt)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET gsub_donor_elig_status = "UF"
    ELSE
     SET gsub_donor_elig_status = "OK"
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE add_bbd_deferral_reason(sub_eligibility_id,sub_contact_id,sub_person_id,sub_reason_cd,
  sub_elig_dt_tm,sub_result_id,sub_active_ind,sub_active_status_cd,sub_current_dt_tm,
  sub_active_status_prsnl_id)
   SET gsub_bbd_deferral_reason_status = "  "
   DECLARE sub_deferral_reason_id = f8 WITH protect, noconstant(0.0)
   SET deferral_reason_id = next_pathnet_seq(0)
   SET sub_deferral_reason_id = deferral_reason_id
   IF (curqual=0)
    SET gsub_bbd_deferral_reason_status = "FS"
   ELSE
    INSERT  FROM bbd_deferral_reason bdr
     SET bdr.deferral_reason_id = sub_deferral_reason_id, bdr.eligibility_id = sub_eligibility_id,
      bdr.contact_id = sub_contact_id,
      bdr.person_id = sub_person_id, bdr.reason_cd = sub_reason_cd, bdr.eligible_dt_tm = null,
      bdr.occurred_dt_tm = null, bdr.calc_elig_dt_tm = cnvtdatetime(sub_elig_dt_tm), bdr.active_ind
       = sub_active_ind,
      bdr.active_status_cd = sub_active_status_cd, bdr.active_status_dt_tm = cnvtdatetime(
       sub_current_dt_tm), bdr.active_status_prsnl_id = sub_active_status_prsnl_id,
      bdr.updt_cnt = 0, bdr.updt_dt_tm = cnvtdatetime(sub_current_dt_tm), bdr.updt_id = reqinfo->
      updt_id,
      bdr.updt_task = reqinfo->updt_task, bdr.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET gsub_bbd_deferral_reason_status = "FA"
    ELSE
     SET gsub_bbd_deferral_reason_status = "OK"
    ENDIF
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
 SUBROUTINE get_mod_family(sub_product_id)
   SET ncurrentcount = 1
   SET nlastcount = 0
   SET ntemp = 0
   SET nchildren = 1
   SET nroot = 1
   SET stat = alterlist(modproductlist->product,0)
   SET stat = alterlist(modproductlist->product,ncurrentcount)
   SET modified_product_id = sub_product_id
   WHILE (nroot=1)
    SET nroot = 0
    SELECT INTO "nl:"
     p.product_id, p.modified_product_id
     FROM product p
     PLAN (p
      WHERE p.product_id=modified_product_id)
     DETAIL
      IF (p.modified_product_id > 0.0)
       modified_product_id = p.modified_product_id, nroot = 1
      ELSE
       nroot = 0
      ENDIF
      modproductlist->product[ncurrentcount].donation_type_mean = uar_get_code_meaning(p
       .donation_type_cd)
     WITH nocounter
    ;end select
   ENDWHILE
   SET modproductlist->product[ncurrentcount].product_id = modified_product_id
   SET modproductlist->product[ncurrentcount].biohazard_ind = request->orders[oidx].assays[aidx].
   biohazard_ind
   WHILE (nchildren=1)
     SET nchildren = 0
     SELECT INTO "nl:"
      p.product_id, p.modified_product_id, p.modified_product_ind,
      p.locked_ind, b.updt_cnt, pe.event_type_cd,
      pe.product_event_id, pe.updt_cnt
      FROM (dummyt d1  WITH seq = value(ncurrentcount)),
       product p,
       blood_product b,
       (dummyt d2  WITH seq = 1),
       product_event pe
      PLAN (d1
       WHERE d1.seq > nlastcount
        AND d1.seq <= ncurrentcount)
       JOIN (p
       WHERE (p.modified_product_id=modproductlist->product[d1.seq].product_id))
       JOIN (b
       WHERE b.product_id=p.product_id)
       JOIN (d2)
       JOIN (pe
       WHERE pe.product_id=b.product_id
        AND pe.event_type_cd IN (drawn_cd, tested_cd, quarantined_cd)
        AND pe.active_ind=1)
      ORDER BY p.product_id
      HEAD REPORT
       ntemp = ncurrentcount
      HEAD p.product_id
       ncurrentcount = (ncurrentcount+ 1), stat = alterlist(modproductlist->product,ncurrentcount),
       modproductlist->product[ncurrentcount].product_id = p.product_id,
       modproductlist->product[ncurrentcount].product_nbr = p.product_nbr, modproductlist->product[
       ncurrentcount].lock_ind = p.locked_ind, modproductlist->product[ncurrentcount].bp_updt_cnt = b
       .updt_cnt,
       modproductlist->product[ncurrentcount].donation_type_mean = trim(uar_get_code_meaning(p
         .donation_type_cd)), modproductlist->product[ncurrentcount].biohazard_ind = request->orders[
       oidx].assays[aidx].biohazard_ind
       IF (p.locked_ind=1)
        mod_locked_ind = 1
       ENDIF
       IF (p.modified_product_ind=1)
        nchildren = 1
       ENDIF
      DETAIL
       IF (pe.event_type_cd=drawn_cd)
        modproductlist->product[ncurrentcount].drawn_event_id = pe.product_event_id, modproductlist->
        product[ncurrentcount].drawn_updt_cnt = pe.updt_cnt
       ENDIF
       IF (pe.event_type_cd=tested_cd)
        modproductlist->product[ncurrentcount].tested_event_id = pe.product_event_id, modproductlist
        ->product[ncurrentcount].tested_updt_cnt = pe.updt_cnt
       ENDIF
       IF (pe.event_type_cd=quarantined_cd)
        modproductlist->product[ncurrentcount].quarantined_event_id = pe.product_event_id,
        modproductlist->product[ncurrentcount].quarantined_updt_cnt = pe.updt_cnt
       ENDIF
      FOOT  p.product_id
       row + 0
      WITH nocounter, outerjoin = d2
     ;end select
     SET nlastcount = ntemp
   ENDWHILE
 END ;Subroutine
#exit_script
 IF ((reply->status_data.status != "F")
  AND size(request->review_items,5) > 0)
  CALL execute_maintain_review_items(0)
 ENDIF
 FREE RECORD gm_i_donor_aborh7810_req
 FREE RECORD gm_i_donor_aborh7810_rep
 FREE RECORD gm_u_donor_aborh7810_req
 FREE RECORD gm_u_donor_aborh7810_rep
 FREE RECORD gm_i_donor_antibo7811_req
 FREE RECORD gm_i_donor_antibo7811_rep
 FREE RECORD gm_i_donor_antige7812_req
 FREE RECORD gm_i_donor_antige7812_rep
 FREE RECORD gm_u_donor_antige7812_req
 FREE RECORD gm_u_donor_antige7812_rep
 FREE RECORD gm_i_person_aborh_r0793_req
 FREE RECORD gm_i_person_aborh_r0793_rep
 FREE SET rh_a_rec
 FREE SET current
 FREE SET modproductlist
 SET reqinfo->commit_ind = 0
 IF ((((reply->status_data.status="F")) OR ((reply->status_data.status="Z"))) )
  SET reqinfo->commit_ind = 0
 ELSE
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
