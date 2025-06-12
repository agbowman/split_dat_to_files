CREATE PROGRAM bbt_chg_results_correct:dba
 SUBROUTINE (subevent_add(op_name=vc(value),op_status=vc(value),obj_name=vc(value),obj_value=vc(value
   )) =null WITH protect)
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
 SET log_program_name = "bbt_chg_results_correct"
 RECORD reply(
   1 event_dt_tm = dq8
   1 event_tz = i4
   1 orders[*]
     2 order_id = f8
     2 assays_cnt = i4
     2 pn_recovery_id = f8
     2 assays[*]
       3 task_assay_cd = f8
       3 result_id = f8
       3 perform_result_id = f8
       3 perform_dt_tm = dq8
       3 perform_tz = i4
       3 parent_perform_result_id = f8
       3 updt_id = f8
       3 result_updt_cnt = i4
       3 perform_result_updt_cnt = i4
       3 result_key = f8
       3 perform_result_key = f8
       3 product_id = f8
       3 xm_prod_event_id = f8
       3 bb_result_id = f8
       3 result_status_cd = f8
       3 result_status_disp = vc
       3 result_status_mean = vc
       3 interp_data_id = f8
       3 new_abo_cd = f8
       3 new_abo_disp = c15
       3 new_abo_mean = c12
       3 new_rh_cd = f8
       3 new_rh_disp = c15
       3 new_rh_mean = c12
       3 new_aborh_updt_cnt = i4
       3 image_cnt = i4
       3 images[*]
         4 blob_ref_id = f8
         4 blob_handle = vc
         4 storage_cd = f8
         4 format_cd = f8
         4 blob_title = vc
         4 sequence_nbr = i4
         4 publish_flag = i2
         4 valid_from_dt_tm = dq8
         4 valid_until_dt_tm = dq8
         4 delete_ind = i2
         4 key_value = i4
   1 opposite_found_product_id = f8
   1 opposite_found_person_id = f8
   1 opposite_found_order_id = f8
   1 opposite_found_assay_id = f8
   1 opposite_found_prfrm_rslt_key = f8
   1 err_accession = c20
   1 err_catalog_cd = f8
   1 err_catalog_disp = vc
   1 err_catalog_mean = c12
   1 err_patient_order_ind = i2
   1 err_person_product_id = f8
   1 err_pat_aborh_upd_conflict_ind = i2
   1 err_pat_aborh_ind = i2
   1 err_prod_aborh_ind = i2
   1 pn_recovery_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD rh_a_rec(
   1 antigenlist[*]
     2 antigen_cd = f8
     2 opposite_cd = f8
 )
 RECORD pe_xm_rec(
   1 pe_xm[*]
     2 product_event_id = f8
     2 status = i4
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
 EXECUTE gm_person_aborh_r0793_def "I"
 SUBROUTINE (gm_i_person_aborh_r0793_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) =i2)
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
 SUBROUTINE (gm_i_person_aborh_r0793_i2(icol_name=vc,ival=i2,iqual=i4,null_ind=i2) =i2)
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
 SUBROUTINE (gm_i_person_aborh_r0793_dq8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) =i2)
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
 EXECUTE gm_person_aborh_r0793_def "U"
 SUBROUTINE (gm_u_person_aborh_r0793_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2,wq_ind=i2) =i2)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_person_aborh_r0793_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_person_aborh_r0793_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "person_aborh_rs_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_person_aborh_r0793_req->person_aborh_rs_idf = 1
     SET gm_u_person_aborh_r0793_req->qual[iqual].person_aborh_rs_id = ival
     IF (wq_ind=1)
      SET gm_u_person_aborh_r0793_req->person_aborh_rs_idw = 1
     ENDIF
    OF "person_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_person_aborh_r0793_req->person_idf = 1
     SET gm_u_person_aborh_r0793_req->qual[iqual].person_id = ival
     IF (wq_ind=1)
      SET gm_u_person_aborh_r0793_req->person_idw = 1
     ENDIF
    OF "encntr_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_person_aborh_r0793_req->encntr_idf = 1
     SET gm_u_person_aborh_r0793_req->qual[iqual].encntr_id = ival
     IF (wq_ind=1)
      SET gm_u_person_aborh_r0793_req->encntr_idw = 1
     ENDIF
    OF "result_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_person_aborh_r0793_req->result_idf = 1
     SET gm_u_person_aborh_r0793_req->qual[iqual].result_id = ival
     IF (wq_ind=1)
      SET gm_u_person_aborh_r0793_req->result_idw = 1
     ENDIF
    OF "result_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_person_aborh_r0793_req->result_cdf = 1
     SET gm_u_person_aborh_r0793_req->qual[iqual].result_cd = ival
     IF (wq_ind=1)
      SET gm_u_person_aborh_r0793_req->result_cdw = 1
     ENDIF
    OF "active_status_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_person_aborh_r0793_req->active_status_cdf = 1
     SET gm_u_person_aborh_r0793_req->qual[iqual].active_status_cd = ival
     IF (wq_ind=1)
      SET gm_u_person_aborh_r0793_req->active_status_cdw = 1
     ENDIF
    OF "active_status_prsnl_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_person_aborh_r0793_req->active_status_prsnl_idf = 1
     SET gm_u_person_aborh_r0793_req->qual[iqual].active_status_prsnl_id = ival
     IF (wq_ind=1)
      SET gm_u_person_aborh_r0793_req->active_status_prsnl_idw = 1
     ENDIF
    OF "contributor_system_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_person_aborh_r0793_req->contributor_system_cdf = 1
     SET gm_u_person_aborh_r0793_req->qual[iqual].contributor_system_cd = ival
     IF (wq_ind=1)
      SET gm_u_person_aborh_r0793_req->contributor_system_cdw = 1
     ENDIF
    OF "container_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_person_aborh_r0793_req->container_idf = 1
     SET gm_u_person_aborh_r0793_req->qual[iqual].container_id = ival
     IF (wq_ind=1)
      SET gm_u_person_aborh_r0793_req->container_idw = 1
     ENDIF
    OF "person_aborh_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_person_aborh_r0793_req->person_aborh_idf = 1
     SET gm_u_person_aborh_r0793_req->qual[iqual].person_aborh_id = ival
     IF (wq_ind=1)
      SET gm_u_person_aborh_r0793_req->person_aborh_idw = 1
     ENDIF
    OF "specimen_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_person_aborh_r0793_req->specimen_idf = 1
     SET gm_u_person_aborh_r0793_req->qual[iqual].specimen_id = ival
     IF (wq_ind=1)
      SET gm_u_person_aborh_r0793_req->specimen_idw = 1
     ENDIF
    OF "donor_aborh_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_person_aborh_r0793_req->donor_aborh_idf = 1
     SET gm_u_person_aborh_r0793_req->qual[iqual].donor_aborh_id = ival
     IF (wq_ind=1)
      SET gm_u_person_aborh_r0793_req->donor_aborh_idw = 1
     ENDIF
    OF "standard_aborh_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_person_aborh_r0793_req->standard_aborh_cdf = 1
     SET gm_u_person_aborh_r0793_req->qual[iqual].standard_aborh_cd = ival
     IF (wq_ind=1)
      SET gm_u_person_aborh_r0793_req->standard_aborh_cdw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (gm_u_person_aborh_r0793_i2(icol_name=vc,ival=i2,iqual=i4,null_ind=i2,wq_ind=i2) =i2)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_person_aborh_r0793_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_person_aborh_r0793_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "active_ind":
     IF (null_ind=1)
      SET gm_u_person_aborh_r0793_req->active_indf = 2
     ELSE
      SET gm_u_person_aborh_r0793_req->active_indf = 1
     ENDIF
     SET gm_u_person_aborh_r0793_req->qual[iqual].active_ind = ival
     IF (wq_ind=1)
      SET gm_u_person_aborh_r0793_req->active_indw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (gm_u_person_aborh_r0793_i4(icol_name=vc,ival=i4,iqual=i4,null_ind=i2,wq_ind=i2) =i2)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_person_aborh_r0793_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_person_aborh_r0793_req->qual,iqual)
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
     SET gm_u_person_aborh_r0793_req->updt_cntf = 1
     SET gm_u_person_aborh_r0793_req->qual[iqual].updt_cnt = ival
     IF (wq_ind=1)
      SET gm_u_person_aborh_r0793_req->updt_cntw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (gm_u_person_aborh_r0793_dq8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2,wq_ind=i2) =i2)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_person_aborh_r0793_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_person_aborh_r0793_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "active_status_dt_tm":
     IF (null_ind=1)
      SET gm_u_person_aborh_r0793_req->active_status_dt_tmf = 2
     ELSE
      SET gm_u_person_aborh_r0793_req->active_status_dt_tmf = 1
     ENDIF
     SET gm_u_person_aborh_r0793_req->qual[iqual].active_status_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_person_aborh_r0793_req->active_status_dt_tmw = 1
     ENDIF
    OF "updt_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_person_aborh_r0793_req->updt_dt_tmf = 1
     SET gm_u_person_aborh_r0793_req->qual[iqual].updt_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_person_aborh_r0793_req->updt_dt_tmw = 1
     ENDIF
    OF "drawn_dt_tm":
     IF (null_ind=1)
      SET gm_u_person_aborh_r0793_req->drawn_dt_tmf = 2
     ELSE
      SET gm_u_person_aborh_r0793_req->drawn_dt_tmf = 1
     ENDIF
     SET gm_u_person_aborh_r0793_req->qual[iqual].drawn_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_person_aborh_r0793_req->drawn_dt_tmw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 EXECUTE gm_person_rh_phen2989_def "I"
 SUBROUTINE (gm_i_person_rh_phen2989_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) =i2)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_person_rh_phen2989_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_person_rh_phen2989_req->qual,iqual)
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
     SET gm_i_person_rh_phen2989_req->qual[iqual].person_id = ival
     SET gm_i_person_rh_phen2989_req->person_idi = 1
    OF "encntr_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_person_rh_phen2989_req->qual[iqual].encntr_id = ival
     SET gm_i_person_rh_phen2989_req->encntr_idi = 1
    OF "result_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_person_rh_phen2989_req->qual[iqual].result_id = ival
     SET gm_i_person_rh_phen2989_req->result_idi = 1
    OF "nomenclature_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_person_rh_phen2989_req->qual[iqual].nomenclature_id = ival
     SET gm_i_person_rh_phen2989_req->nomenclature_idi = 1
    OF "person_rh_phenotype_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_person_rh_phen2989_req->qual[iqual].person_rh_phenotype_id = ival
     SET gm_i_person_rh_phen2989_req->person_rh_phenotype_idi = 1
    OF "active_status_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_person_rh_phen2989_req->qual[iqual].active_status_cd = ival
     SET gm_i_person_rh_phen2989_req->active_status_cdi = 1
    OF "active_status_prsnl_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_person_rh_phen2989_req->qual[iqual].active_status_prsnl_id = ival
     SET gm_i_person_rh_phen2989_req->active_status_prsnl_idi = 1
    OF "donor_rh_phenotype_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_person_rh_phen2989_req->qual[iqual].donor_rh_phenotype_id = ival
     SET gm_i_person_rh_phen2989_req->donor_rh_phenotype_idi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (gm_i_person_rh_phen2989_i2(icol_name=vc,ival=i2,iqual=i4,null_ind=i2) =i2)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_person_rh_phen2989_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_person_rh_phen2989_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "active_ind":
     SET gm_i_person_rh_phen2989_req->qual[iqual].active_ind = ival
     SET gm_i_person_rh_phen2989_req->active_indi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (gm_i_person_rh_phen2989_dq8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) =i2)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_person_rh_phen2989_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_person_rh_phen2989_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "updt_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_person_rh_phen2989_req->qual[iqual].updt_dt_tm = cnvtdatetime(ival)
     SET gm_i_person_rh_phen2989_req->updt_dt_tmi = 1
    OF "active_status_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_person_rh_phen2989_req->qual[iqual].active_status_dt_tm = cnvtdatetime(ival)
     SET gm_i_person_rh_phen2989_req->active_status_dt_tmi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
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
 SUBROUTINE (add_bb_exception(sub_person_id=f8,sub_order_id=f8,sub_exception_prsnl_id=f8,
  exception_dt_tm=dq8,prod_event_id=f8,exception_type_mean=vc,sub_override_reason_cd=f8,
  sub_event_type_cd=f8,sub_result_id=f8,sub_perform_result_id=f8,sub_from_abo_cd=f8,sub_from_rh_cd=f8,
  sub_to_abo_cd=f8,sub_to_rh_cd=f8,sub_default_expiration_dt_tm=dq8) =null)
   SET exception_status = "I"
   SET sub_exception_type_cd = 0.0
   DECLARE sub_bb_exception_id = f8 WITH protect, noconstant(0.0)
   DECLARE except_type_mean = c12
   SET except_type_mean = fillstring(12," ")
   SET except_type_mean = exception_type_mean
   SET stat = uar_get_meaning_by_codeset(14072,nullterm(except_type_mean),1,sub_exception_type_cd)
   DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
   SET new_pathnet_seq = 0
   SELECT INTO "nl:"
    seqn = seq(pathnet_seq,nextval)
    FROM dual
    DETAIL
     new_pathnet_seq = seqn
    WITH format, nocounter
   ;end select
   SET sub_bb_exception_id = new_pathnet_seq
   INSERT  FROM bb_exception b
    SET b.exception_id = sub_bb_exception_id, b.product_event_id = prod_event_id, b.exception_type_cd
      = sub_exception_type_cd,
     b.event_type_cd = sub_event_type_cd, b.from_abo_cd = sub_from_abo_cd, b.from_rh_cd =
     sub_from_rh_cd,
     b.to_abo_cd = sub_to_abo_cd, b.to_rh_cd = sub_to_rh_cd, b.override_reason_cd =
     sub_override_reason_cd,
     b.result_id = sub_result_id, b.perform_result_id = sub_perform_result_id, b.updt_cnt = 0,
     b.updt_dt_tm = cnvtdatetime(sysdate), b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->
     updt_task,
     b.updt_applctx = reqinfo->updt_applctx, b.active_ind = 1, b.active_status_cd = reqdata->
     active_status_cd,
     b.active_status_dt_tm = cnvtdatetime(sysdate), b.active_status_prsnl_id = reqinfo->updt_id, b
     .donor_contact_id = 0.0,
     b.donor_contact_type_cd = 0.0, b.order_id = sub_order_id, b.exception_prsnl_id =
     sub_exception_prsnl_id,
     b.exception_dt_tm = cnvtdatetime(exception_dt_tm), b.person_id = sub_person_id, b
     .default_expire_dt_tm = cnvtdatetime(sub_default_expiration_dt_tm)
    WITH counter
   ;end insert
   SET bb_exception_id = sub_bb_exception_id
   IF (curqual=0)
    SET exception_status = "F"
   ELSE
    SET exception_status = "S"
   ENDIF
 END ;Subroutine
 SUBROUTINE (add_tag_mismatch_exception(tag_product_nbr=vc,tag_div_chars=vc,tag_product_type_cd=f8) =
  null)
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
   INSERT  FROM bb_tag_verify_excpn tv
    SET tv.bb_tag_verify_excpn_id = new_pathnet_seq, tv.exception_id = sub_bb_exception_id, tv
     .tag_product_sub_nbr_txt = tag_div_chars,
     tv.tag_product_nbr_txt = tag_product_nbr, tv.tag_product_type_cd = tag_product_type_cd, tv
     .updt_id = reqinfo->updt_id,
     tv.updt_task = reqinfo->updt_task, tv.updt_applctx = reqinfo->updt_applctx, tv.updt_cnt = 0
    WITH counter
   ;end insert
   IF (curqual=0)
    SET exception_status = "F"
   ELSE
    SET exception_status = "S"
   ENDIF
 END ;Subroutine
 SUBROUTINE (add_invd_prod_ord_exception(product_order_id=f8) =null)
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
   INSERT  FROM bb_invld_prod_ord_exceptn b
    SET b.bb_invld_prod_ord_exceptn_id = new_pathnet_seq, b.exception_id = sub_bb_exception_id, b
     .product_order_id = product_order_id,
     b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(sysdate), b.updt_id = reqinfo->updt_id,
     b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx
    WITH counter
   ;end insert
   IF (curqual=0)
    SET exception_status = "F"
   ELSE
    SET exception_status = "S"
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
   DECLARE sub_bb_exception_id = f8 WITH protect, noconstant(0.0)
   SET sub_bb_exception_id = bb_exception_id
   INSERT  FROM bb_reqs_exception b
    SET b.reqs_exception_id = new_pathnet_seq, b.exception_id = sub_bb_exception_id, b
     .special_testing_cd = sub_special_testing_cd,
     b.requirement_cd = sub_requirement_cd, b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(sysdate),
     b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->
     updt_applctx,
     b.active_ind = 1, b.active_status_cd = reqdata->active_status_cd, b.active_status_dt_tm =
     cnvtdatetime(sysdate),
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
     b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(sysdate), b.updt_id = reqinfo->updt_id,
     b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx, b.active_ind = 1,
     b.active_status_cd = reqdata->active_status_cd, b.active_status_dt_tm = cnvtdatetime(sysdate), b
     .active_status_prsnl_id = reqinfo->updt_id
    WITH counter
   ;end insert
   IF (curqual=0)
    SET exception_status = "F"
   ELSE
    SET exception_status = "S"
   ENDIF
 END ;Subroutine
 SUBROUTINE (add_bb_inactive_exception(sub_person_id=f8,sub_order_id=f8,sub_exception_prsnl_id=f8,
  exception_dt_tm=dq8,prod_event_id=f8,exception_type_mean=vc,sub_override_reason_cd=f8,
  sub_event_type_cd=f8,sub_result_id=f8,sub_perform_result_id=f8,sub_from_abo_cd=f8,sub_from_rh_cd=f8,
  sub_to_abo_cd=f8,sub_to_rh_cd=f8,sub_default_expiration_dt_tm=dq8) =null)
   SET exception_status = "I"
   DECLARE sub_exception_type_cd = f8 WITH protect, noconstant(0.0)
   DECLARE sub_bb_exception_id = f8 WITH protect, noconstant(0.0)
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
    SET sub_bb_exception_id = new_pathnet_seq
    INSERT  FROM bb_exception b
     SET b.exception_id = sub_bb_exception_id, b.product_event_id = prod_event_id, b
      .exception_type_cd = sub_exception_type_cd,
      b.event_type_cd = sub_event_type_cd, b.from_abo_cd = sub_from_abo_cd, b.from_rh_cd =
      sub_from_rh_cd,
      b.to_abo_cd = sub_to_abo_cd, b.to_rh_cd = sub_to_rh_cd, b.override_reason_cd =
      sub_override_reason_cd,
      b.result_id = sub_result_id, b.perform_result_id = sub_perform_result_id, b.updt_cnt = 0,
      b.updt_dt_tm = cnvtdatetime(sysdate), b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->
      updt_task,
      b.updt_applctx = reqinfo->updt_applctx, b.active_ind = 0, b.active_status_cd = reqdata->
      inactive_status_cd,
      b.active_status_dt_tm = cnvtdatetime(sysdate), b.active_status_prsnl_id = reqinfo->updt_id, b
      .donor_contact_id = 0.0,
      b.donor_contact_type_cd = 0.0, b.order_id = sub_order_id, b.exception_prsnl_id =
      sub_exception_prsnl_id,
      b.exception_dt_tm = cnvtdatetime(exception_dt_tm), b.person_id = sub_person_id, b
      .default_expire_dt_tm = cnvtdatetime(sub_default_expiration_dt_tm)
     WITH counter
    ;end insert
    SET bb_exception_id = sub_bb_exception_id
    IF (curqual=0)
     SET exception_status = "F"
    ELSE
     SET exception_status = "S"
    ENDIF
   ENDIF
 END ;Subroutine
 DECLARE add_inactive_reqs_exception(sub_special_testing_cd,sub_requirement_cd) = null
 SUBROUTINE add_inactive_reqs_exception(sub_special_testing_cd,sub_requirement_cd)
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
   INSERT  FROM bb_reqs_exception b
    SET b.reqs_exception_id = new_pathnet_seq, b.exception_id = sub_bb_exception_id, b
     .special_testing_cd = sub_special_testing_cd,
     b.requirement_cd = sub_requirement_cd, b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(sysdate),
     b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->
     updt_applctx,
     b.active_ind = 0, b.active_status_cd = reqdata->inactive_status_cd, b.active_status_dt_tm =
     cnvtdatetime(sysdate),
     b.active_status_prsnl_id = reqinfo->updt_id
    WITH counter
   ;end insert
   IF (curqual=0)
    SET exception_status = "F"
   ELSE
    SET exception_status = "S"
   ENDIF
 END ;Subroutine
 SUBROUTINE (activate_bb_exception(sub_exception_id=f8,updt_cnt=i4) =null)
   SET exception_status = "I"
   SELECT INTO "nl:"
    b.exception_id
    FROM bb_exception b
    WHERE b.exception_id=sub_exception_id
     AND b.active_ind=0
     AND b.updt_cnt=updt_cnt
    WITH nocounter, forupdate(b)
   ;end select
   IF (curqual=0)
    SET exception_status = "FL"
   ENDIF
   IF (curqual=1)
    UPDATE  FROM bb_exception b
     SET b.active_ind = 1, b.active_status_cd = reqdata->active_status_cd, b.updt_cnt = (b.updt_cnt+
      1),
      b.updt_dt_tm = cnvtdatetime(sysdate), b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->
      updt_task,
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
 SUBROUTINE add_person_aborh(sub_person_id,sub_abo_cd,sub_rh_cd,sub_active_ind,sub_active_status_cd,
  sub_active_status_dt_tm,sub_active_status_prsnl_id,sub_last_verified_dt_tm)
   SET gsub_person_aborh_status = "  "
   SET person_aborh_id = next_pathnet_seq(0)
   IF (curqual=0)
    SET gsub_person_aborh_status = "FS"
   ELSE
    INSERT  FROM person_aborh pa
     SET pa.person_aborh_id = person_aborh_id, pa.person_id = sub_person_id, pa.abo_cd = sub_abo_cd,
      pa.rh_cd = sub_rh_cd, pa.active_ind = sub_active_ind, pa.active_status_cd =
      sub_active_status_cd,
      pa.active_status_dt_tm = cnvtdatetime(sub_active_status_dt_tm), pa.active_status_prsnl_id =
      sub_active_status_prsnl_id, pa.begin_effective_dt_tm = cnvtdatetime(sysdate),
      pa.end_effective_dt_tm = cnvtdatetime("31-DEC-2100:00:00:00.00"), pa.updt_cnt = 0, pa
      .updt_dt_tm = cnvtdatetime(sysdate),
      pa.updt_id = reqinfo->updt_id, pa.updt_task = reqinfo->updt_task, pa.updt_applctx = reqinfo->
      updt_applctx,
      pa.last_verified_dt_tm = cnvtdatetime(sub_last_verified_dt_tm)
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET gsub_person_aborh_status = "FA"
    ELSE
     SET gsub_person_aborh_status = "OK"
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE chg_person_aborh(sub_person_id,sub_abo_cd,sub_rh_cd,sub_active_ind,sub_active_status_cd,
  sub_updt_cnt,sub_lock_forupdate_ind)
   SET gsub_person_aborh_inact_status = "  "
   SET person_aborh_id = 0.0
   IF (sub_lock_forupdate_ind=1)
    SELECT INTO "nl:"
     pa.person_aborh_id
     FROM person_aborh pa
     WHERE pa.person_id=sub_person_id
      AND pa.abo_cd=sub_abo_cd
      AND pa.rh_cd=sub_rh_cd
      AND pa.active_ind=1
      AND pa.updt_cnt=sub_updt_cnt
     DETAIL
      person_aborh_id = pa.person_aborh_id
     WITH nocounter, forupdate(pa)
    ;end select
    IF (curqual=0)
     SET gsub_person_aborh_inact_status = "FL"
    ENDIF
   ENDIF
   IF (((sub_lock_forupdate_ind=0) OR (sub_lock_forupdate_ind=1
    AND curqual > 0)) )
    UPDATE  FROM person_aborh pa
     SET pa.active_ind = sub_active_ind, pa.active_status_cd = sub_active_status_cd, pa
      .end_effective_dt_tm = cnvtdatetime(sysdate),
      pa.updt_cnt = (pa.updt_cnt+ 1), pa.updt_dt_tm = cnvtdatetime(sysdate), pa.updt_id = reqinfo->
      updt_id,
      pa.updt_task = reqinfo->updt_task, pa.updt_applctx = reqinfo->updt_applctx
     WHERE pa.person_aborh_id=person_aborh_id
      AND pa.updt_cnt=sub_updt_cnt
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET gsub_person_aborh_inact_status = "FU"
    ELSE
     SET gsub_person_aborh_inact_status = "OK"
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE add_aborh_result(sub_specimen_id,sub_container_id,sub_drawn_dt_tm,sub_person_aborh_id,
  sub_person_id,sub_encntr_id,sub_result_id,sub_result_cd,sub_active_ind,sub_active_status_cd,
  sub_active_status_dt_tm,sub_active_status_prsnl_id)
   SET gsub_aborh_result_status = "  "
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
   DECLARE standard_aborh_cd_text = c17 WITH protect, constant("standard_aborh_cd")
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
    SET stat = alterlist(gm_i_person_aborh_r0793_req->qual,1)
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
    CALL gm_i_person_aborh_r0793_f8(standard_aborh_cd_text,standard_aborh_cd,1,0)
    EXECUTE gm_i_person_aborh_r0793  WITH replace(request,gm_i_person_aborh_r0793_req), replace(reply,
     gm_i_person_aborh_r0793_rep)
    IF ((gm_i_person_aborh_r0793_rep->status_data.status="F"))
     CALL echo("Insert into person_aborh_result table failed.")
     SET gsub_aborh_result_status = "FA"
    ELSEIF ((gm_i_person_aborh_r0793_rep->status_data.status="S"))
     CALL echo("Insert into person_aborh_result table success.")
     SET gsub_aborh_result_status = "OK"
     SET stat = alterlist(gm_i_person_aborh_r0793_rep->qual,1)
     SET person_aborh_rs_id = gm_i_person_aborh_r0793_rep->qual[1].person_aborh_rs_id
     IF (person_aborh_rs_id=0)
      SET gsub_aborh_result_status = "FA"
     ENDIF
    ENDIF
   ELSE
    CALL echo("Result_cd's corresponding Standard_ABORH_CD not found on code set 1640")
    SET gsub_aborh_result_status = "FV"
   ENDIF
 END ;Subroutine
 SUBROUTINE chg_aborh_result(sub_person_id,sub_encntr_id,sub_result_id,sub_result_cd,sub_active_ind,
  sub_active_status_cd,sub_updt_cnt,sub_lock_forupdate_ind)
   DECLARE sub_person_aborh_rs_id = f8 WITH protect, noconstant(0.0)
   SET gsub_inactive_aborh_rsl_status = "  "
   SET sub_person_aborh_rs_id = 0
   IF (sub_lock_forupdate_ind=1)
    SELECT INTO "nl:"
     pa.person_aborh_rs_id
     FROM person_aborh_result pa
     WHERE pa.result_id=sub_result_id
      AND pa.result_cd=sub_result_cd
      AND pa.person_id=sub_person_id
      AND pa.encntr_id=sub_encntr_id
      AND pa.active_ind=1
      AND pa.updt_cnt=sub_updt_cnt
     DETAIL
      sub_person_aborh_rs_id = pa.person_aborh_rs_id
     WITH nocounter, forupdate(pa)
    ;end select
    IF (curqual=0)
     SET gsub_inactive_aborh_rsl_status = "FL"
    ENDIF
   ENDIF
   IF (((sub_lock_forupdate_ind=0) OR (sub_lock_forupdate_ind=1
    AND curqual > 0)) )
    UPDATE  FROM person_aborh_result pa
     SET pa.active_ind = sub_active_ind, pa.active_status_cd = sub_active_status_cd, pa.updt_cnt = (
      pa.updt_cnt+ 1),
      pa.updt_dt_tm = cnvtdatetime(sysdate), pa.updt_id = reqinfo->updt_id, pa.updt_task = reqinfo->
      updt_task,
      pa.updt_applctx = reqinfo->updt_applctx
     WHERE pa.person_aborh_rs_id=sub_person_aborh_rs_id
      AND pa.updt_cnt=sub_updt_cnt
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET gsub_inactive_aborh_rsl_status = "FU"
    ELSE
     SET gsub_inactive_aborh_rsl_status = "OK"
    ENDIF
   ENDIF
   SUBROUTINE (chg_aborh_result_2(sub_person_id=f8,sub_encntr_id=f8,sub_result_id=f8,sub_active_ind=
    i2,sub_active_status_cd=f8) =null)
     SET gsub_inactive_aborh_rsl_status = "  "
     DECLARE dperson_aborh_rs_id = f8 WITH protect, noconstant(0.0)
     SELECT INTO "nl:"
      pa.person_aborh_rs_id
      FROM person_aborh_result pa
      WHERE pa.result_id=sub_result_id
       AND pa.person_id=sub_person_id
       AND pa.encntr_id=sub_encntr_id
       AND pa.active_ind=1
      DETAIL
       dperson_aborh_rs_id = pa.person_aborh_rs_id
      WITH nocounter, forupdate(pa)
     ;end select
     IF (curqual=0)
      SET gsub_inactive_aborh_rsl_status = "FL"
     ENDIF
     IF (curqual > 0)
      UPDATE  FROM person_aborh_result pa
       SET pa.active_ind = sub_active_ind, pa.active_status_cd = sub_active_status_cd, pa.updt_cnt =
        (pa.updt_cnt+ 1),
        pa.updt_dt_tm = cnvtdatetime(sysdate), pa.updt_id = reqinfo->updt_id, pa.updt_task = reqinfo
        ->updt_task,
        pa.updt_applctx = reqinfo->updt_applctx
       WHERE pa.person_aborh_rs_id=dperson_aborh_rs_id
       WITH nocounter
      ;end update
      IF (curqual=0)
       SET gsub_inactive_aborh_rsl_status = "FU"
      ELSE
       SET gsub_inactive_aborh_rsl_status = "OK"
      ENDIF
     ENDIF
   END ;Subroutine
 END ;Subroutine
 SUBROUTINE add_person_antibody(sub_person_id,sub_encntr_id,sub_antibody_cd,sub_result_id,
  sub_bb_result_id,sub_active_ind,sub_active_status_cd,sub_active_status_dt_tm,
  sub_active_status_prsnl_id)
   SET gsub_person_antibody_status = "  "
   SET unique_id = 0.0
   SET unique_id = next_pathnet_seq(0)
   IF (curqual=0)
    SET gsub_person_antibody_status = "FS"
   ELSE
    INSERT  FROM person_antibody p
     SET p.person_id = sub_person_id, p.person_antibody_id = unique_id, p.antibody_cd =
      sub_antibody_cd,
      p.encntr_id = sub_encntr_id, p.result_id = sub_result_id, p.bb_result_id = sub_bb_result_id,
      p.active_ind = sub_active_ind, p.active_status_cd = sub_active_status_cd, p.active_status_dt_tm
       = cnvtdatetime(sub_active_status_dt_tm),
      p.active_status_prsnl_id = sub_active_status_prsnl_id, p.updt_dt_tm = cnvtdatetime(sysdate), p
      .updt_id = reqinfo->updt_id,
      p.updt_cnt = 0, p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET gsub_person_antibody_status = "FA"
    ELSE
     SET gsub_person_antibody_status = "OK"
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE chg_person_antibody(sub_person_id,sub_encntr_id,sub_antibody_cd,sub_result_id,
  sub_bb_result_id,sub_active_ind,sub_active_status_cd,sub_updt_cnt,sub_lock_forupdate_ind)
   SET gsub_inactive_prs_antibody_status = "  "
   IF (sub_lock_forupdate_ind=1)
    SELECT INTO "nl:"
     pa.person_id, pa.antibody_cd, pa.encntr_id,
     pa.result_id, pa.bb_result_id
     FROM person_antibody pa
     WHERE pa.person_id=sub_person_id
      AND pa.antibody_cd=sub_antibody_cd
      AND pa.active_ind=1
      AND pa.encntr_id=sub_encntr_id
      AND pa.result_id=sub_result_id
      AND pa.bb_result_id=sub_bb_result_id
      AND pa.updt_cnt=sub_updt_cnt
     WITH nocounter, forupdate(pa)
    ;end select
    IF (curqual=0)
     SET gsub_inactive_prs_antibody_status = "FL"
    ENDIF
   ENDIF
   IF (((sub_lock_forupdate_ind=0) OR (sub_lock_forupdate_ind=1
    AND curqual > 0)) )
    UPDATE  FROM person_antibody pa
     SET pa.active_ind = sub_active_ind, pa.active_status_cd = sub_active_status_cd, pa.updt_cnt = (
      pa.updt_cnt+ 1),
      pa.updt_dt_tm = cnvtdatetime(sysdate), pa.removed_prsnl_id = reqinfo->updt_id, pa.removed_dt_tm
       = cnvtdatetime(sysdate),
      pa.updt_id = reqinfo->updt_id, pa.updt_task = reqinfo->updt_task, pa.updt_applctx = reqinfo->
      updt_applctx
     WHERE pa.person_id=sub_person_id
      AND pa.antibody_cd=sub_antibody_cd
      AND pa.active_ind=1
      AND pa.encntr_id=sub_encntr_id
      AND pa.result_id=sub_result_id
      AND pa.bb_result_id=sub_bb_result_id
      AND pa.updt_cnt=sub_updt_cnt
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET gsub_inactive_prs_antibody_status = "FU"
    ELSE
     SET gsub_inactive_prs_antibody_status = "OK"
    ENDIF
   ENDIF
   SUBROUTINE (chg_person_antibody_2(sub_person_id=f8,sub_encntr_id=f8,sub_result_id=f8,
    sub_bb_result_id=f8,sub_active_ind=i2,sub_active_status_cd=f8) =null)
     SET gsub_inactive_prs_antibody_status = "  "
     DECLARE dperson_antibody_id = f8 WITH protect, noconstant(0.0)
     SELECT INTO "nl:"
      pa.result_id, pa.bb_result_id
      FROM person_antibody pa
      WHERE pa.person_id=sub_person_id
       AND pa.active_ind=1
       AND pa.encntr_id=sub_encntr_id
       AND pa.result_id=sub_result_id
       AND pa.bb_result_id=sub_bb_result_id
      DETAIL
       dperson_antibody_id = pa.person_antibody_id
      WITH nocounter, forupdate(pa)
     ;end select
     IF (curqual=0)
      SET gsub_inactive_prs_antibody_status = "FL"
     ENDIF
     IF (curqual > 0)
      UPDATE  FROM person_antibody pa
       SET pa.active_ind = sub_active_ind, pa.active_status_cd = sub_active_status_cd, pa.updt_cnt =
        (pa.updt_cnt+ 1),
        pa.updt_dt_tm = cnvtdatetime(sysdate), pa.removed_prsnl_id = reqinfo->updt_id, pa
        .removed_dt_tm = cnvtdatetime(sysdate),
        pa.updt_id = reqinfo->updt_id, pa.updt_task = reqinfo->updt_task, pa.updt_applctx = reqinfo->
        updt_applctx
       WHERE pa.person_antibody_id=dperson_antibody_id
       WITH nocounter
      ;end update
      IF (curqual=0)
       SET gsub_inactive_prs_antibody_status = "FU"
      ELSE
       SET gsub_inactive_prs_antibody_status = "OK"
      ENDIF
     ENDIF
   END ;Subroutine
 END ;Subroutine
 SUBROUTINE add_person_antigen(sub_person_id,sub_encntr_id,sub_antigen_cd,sub_result_id,
  sub_bb_result_id,sub_rh_phenotype_id,sub_active_ind,sub_active_status_cd,sub_active_status_dt_tm,
  sub_active_status_prsnl_id)
   SET gsub_person_antigen_status = "  "
   SET unique_id = 0.0
   SET unique_id = next_pathnet_seq(0)
   IF (curqual=0)
    SET gsub_person_antigen_status = "FS"
   ELSE
    INSERT  FROM person_antigen p
     SET p.person_antigen_id = unique_id, p.person_id = sub_person_id, p.antigen_cd = sub_antigen_cd,
      p.encntr_id = sub_encntr_id, p.result_id = sub_result_id, p.bb_result_id = sub_bb_result_id,
      p.person_rh_phenotype_id = sub_rh_phenotype_id, p.active_ind = sub_active_ind, p
      .active_status_cd = sub_active_status_cd,
      p.active_status_dt_tm = cnvtdatetime(sub_active_status_dt_tm), p.active_status_prsnl_id =
      sub_active_status_prsnl_id, p.updt_dt_tm = cnvtdatetime(sysdate),
      p.updt_id = reqinfo->updt_id, p.updt_cnt = 0, p.updt_task = reqinfo->updt_task,
      p.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET gsub_person_antigen_status = "FA"
    ELSE
     SET gsub_person_antigen_status = "OK"
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE chg_person_antigen(sub_person_id,sub_encntr_id,sub_antigen_cd,sub_result_id,
  sub_bb_result_id,sub_active_ind,sub_active_status_cd,sub_updt_cnt,sub_lock_forupdate_ind)
   SET gsub_inactive_prs_antigen_status = "  "
   IF (sub_lock_forupdate_ind=1)
    SELECT INTO "nl:"
     pa.person_id, pa.antigen_cd
     FROM person_antigen pa
     WHERE pa.person_id=sub_person_id
      AND pa.antigen_cd=sub_antigen_cd
      AND pa.active_ind=1
      AND pa.encntr_id=sub_encntr_id
      AND pa.result_id=sub_result_id
      AND pa.bb_result_id=sub_bb_result_id
      AND pa.updt_cnt=sub_updt_cnt
     WITH nocounter, forupdate(pa)
    ;end select
    IF (curqual=0)
     SET gsub_inactive_prs_antigen_status = "FL"
    ENDIF
   ENDIF
   IF (((sub_lock_forupdate_ind=0) OR (sub_lock_forupdate_ind=1
    AND curqual > 0)) )
    UPDATE  FROM person_antigen pa
     SET pa.active_ind = sub_active_ind, pa.active_status_cd = sub_active_status_cd, pa.updt_cnt = (
      pa.updt_cnt+ 1),
      pa.updt_dt_tm = cnvtdatetime(sysdate), pa.updt_id = reqinfo->updt_id, pa.removed_dt_tm =
      cnvtdatetime(sysdate),
      pa.removed_prsnl_id = reqinfo->updt_id, pa.updt_task = reqinfo->updt_task, pa.updt_applctx =
      reqinfo->updt_applctx
     WHERE pa.person_id=sub_person_id
      AND pa.antigen_cd=sub_antigen_cd
      AND pa.active_ind=1
      AND pa.encntr_id=sub_encntr_id
      AND pa.result_id=sub_result_id
      AND pa.bb_result_id=sub_bb_result_id
      AND pa.updt_cnt=sub_updt_cnt
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET gsub_inactive_prs_antigen_status = "FU"
    ELSE
     SET gsub_inactive_prs_antigen_status = "OK"
    ENDIF
   ENDIF
   SUBROUTINE (chg_person_antigen_2(sub_person_id=f8,sub_encntr_id=f8,sub_result_id=f8,
    sub_bb_result_id=f8,sub_active_ind=i2,sub_active_status_cd=f8) =null)
     SET gsub_inactive_prs_antigen_status = "  "
     DECLARE dperson_antigen_id = f8 WITH protect, noconstant(0.0)
     SELECT INTO "nl:"
      pa.person_id, pa.antigen_cd
      FROM person_antigen pa
      WHERE pa.person_id=sub_person_id
       AND pa.active_ind=1
       AND pa.encntr_id=sub_encntr_id
       AND pa.result_id=sub_result_id
       AND pa.bb_result_id=sub_bb_result_id
      DETAIL
       dperson_antigen_id = pa.person_antigen_id
      WITH nocounter, forupdate(pa)
     ;end select
     IF (curqual=0)
      SET gsub_inactive_prs_antigen_status = "FL"
     ENDIF
     IF (curqual > 0)
      UPDATE  FROM person_antigen pa
       SET pa.active_ind = sub_active_ind, pa.active_status_cd = sub_active_status_cd, pa.updt_cnt =
        (pa.updt_cnt+ 1),
        pa.updt_dt_tm = cnvtdatetime(sysdate), pa.updt_id = reqinfo->updt_id, pa.removed_prsnl_id =
        reqinfo->updt_id,
        pa.removed_dt_tm = cnvtdatetime(sysdate), pa.updt_task = reqinfo->updt_task, pa.updt_applctx
         = reqinfo->updt_applctx
       WHERE pa.person_antigen_id=dperson_antigen_id
       WITH nocounter
      ;end update
      IF (curqual=0)
       SET gsub_inactive_prs_antigen_status = "FU"
      ELSE
       SET gsub_inactive_prs_antigen_status = "OK"
      ENDIF
     ENDIF
   END ;Subroutine
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
       s.updt_dt_tm = cnvtdatetime(sysdate), s.updt_id = reqinfo->updt_id, s.updt_cnt = 0,
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
        cnvtdatetime(sysdate),
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
 SUBROUTINE chg_special_testing(sub_product_id,sub_special_testing_cd,sub_active_ind,
  sub_active_status_cd,sub_updt_cnt,sub_lock_forupdate_ind)
   SET gsub_inactive_spcl_tst_status = "  "
   SET orig_special_testing_id = 0
   IF (sub_lock_forupdate_ind=1)
    SELECT INTO "nl:"
     s.special_testing_id
     FROM special_testing s
     WHERE s.product_id=sub_product_id
      AND s.special_testing_cd=sub_special_testing_cd
      AND s.active_ind=1
      AND s.updt_cnt=sub_updt_cnt
     DETAIL
      orig_special_testing_id = s.special_testing_id
     WITH nocounter, forupdate(s)
    ;end select
    IF (curqual=0)
     SET gsub_inactive_spcl_tst_status = "FL"
    ENDIF
   ENDIF
   IF (((sub_lock_forupdate_ind=0) OR (sub_lock_forupdate_ind=1
    AND curqual > 0)) )
    UPDATE  FROM special_testing s
     SET s.active_ind = sub_active_ind, s.active_status_cd = sub_active_status_cd, s.updt_cnt = (s
      .updt_cnt+ 1),
      s.updt_dt_tm = cnvtdatetime(sysdate), s.updt_id = reqinfo->updt_id, s.updt_task = reqinfo->
      updt_task,
      s.updt_applctx = reqinfo->updt_applctx
     WHERE s.special_testing_id=orig_special_testing_id
      AND s.updt_cnt=sub_updt_cnt
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET gsub_inactive_spcl_tst_status = "FU"
    ELSE
     SET gsub_inactive_spcl_tst_status = "OK"
    ENDIF
   ENDIF
   SUBROUTINE (chg_special_testing_2(sub_special_testing_id=f8,sub_active_ind=i2,sub_active_status_cd
    =f8) =null)
     SET gsub_inactive_spcl_tst_status = "  "
     SELECT INTO "nl:"
      s.special_testing_id
      FROM special_testing s
      WHERE s.special_testing_id=gdspecial_testing_id
      WITH nocounter, forupdate(s)
     ;end select
     IF (curqual=0)
      SET gsub_inactive_spcl_tst_status = "FL"
     ENDIF
     IF (curqual > 0)
      UPDATE  FROM special_testing s
       SET s.active_ind = sub_active_ind, s.active_status_cd = sub_active_status_cd, s.updt_cnt = (s
        .updt_cnt+ 1),
        s.updt_dt_tm = cnvtdatetime(sysdate), s.updt_id = reqinfo->updt_id, s.updt_task = reqinfo->
        updt_task,
        s.updt_applctx = reqinfo->updt_applctx
       WHERE s.special_testing_id=gdspecial_testing_id
       WITH nocounter
      ;end update
      IF (curqual=0)
       SET gsub_inactive_spcl_tst_status = "FU"
      ELSE
       SET gsub_inactive_spcl_tst_status = "OK"
      ENDIF
     ENDIF
   END ;Subroutine
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
     str.updt_dt_tm = cnvtdatetime(sysdate), str.updt_id = reqinfo->updt_id, str.updt_task = reqinfo
     ->updt_task,
     str.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET gsub_spc_tst_result_status = "FA"
   ELSE
    SET gsub_spc_tst_result_status = "OK"
   ENDIF
 END ;Subroutine
 SUBROUTINE chg_special_testing_result(sub_special_testing_id,sub_product_id,sub_result_id,
  sub_bb_result_id,sub_active_ind,sub_active_status_cd,sub_updt_cnt,sub_lock_forupdate_ind,
  sub_special_testing_cd,sub_spcl_tst_updt_cnt)
   SET gsub_inactive_spc_tst_rsl_status = "  "
   IF (sub_special_testing_id=0.0)
    SELECT INTO "nl:"
     s.special_testing_id
     FROM special_testing s
     WHERE s.product_id=sub_product_id
      AND s.special_testing_cd=sub_special_testing_cd
      AND s.active_ind=1
      AND s.updt_cnt=sub_spcl_tst_updt_cnt
     DETAIL
      sub_special_testing_id = s.special_testing_id, orig_special_testing_id = s.special_testing_id
     WITH nocounter
    ;end select
   ENDIF
   IF (sub_lock_forupdate_ind=1)
    SELECT INTO "nl:"
     s.special_testing_id
     FROM special_testing_result s
     WHERE s.special_testing_id=sub_special_testing_id
      AND s.product_id=sub_product_id
      AND s.result_id=sub_result_id
      AND s.bb_result_id=sub_bb_result_id
      AND s.active_ind=1
      AND s.updt_cnt=sub_updt_cnt
     WITH nocounter, forupdate(s)
    ;end select
    IF (curqual=0)
     SET gsub_inactive_spc_tst_rsl_status = "FL"
    ENDIF
   ENDIF
   IF (((sub_lock_forupdate_ind=0) OR (sub_lock_forupdate_ind=1
    AND curqual > 0)) )
    UPDATE  FROM special_testing_result s
     SET s.active_ind = sub_active_ind, s.active_status_cd = sub_active_status_cd, s.updt_cnt = (s
      .updt_cnt+ 1),
      s.updt_dt_tm = cnvtdatetime(sysdate), s.updt_id = reqinfo->updt_id, s.updt_task = reqinfo->
      updt_task,
      s.updt_applctx = reqinfo->updt_applctx
     WHERE s.special_testing_id=sub_special_testing_id
      AND s.product_id=sub_product_id
      AND s.result_id=sub_result_id
      AND s.bb_result_id=sub_bb_result_id
      AND s.active_ind=1
      AND s.updt_cnt=sub_updt_cnt
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET gsub_inactive_spc_tst_rsl_status = "FU"
    ELSE
     SET gsub_inactive_spc_tst_rsl_status = "OK"
    ENDIF
   ENDIF
   IF ((request->orders[oidx].assays[aidx].upd_prod_spcl_tst_yn="N"))
    SELECT INTO "nl:"
     s.special_testing_id
     FROM special_testing_result s
     WHERE s.special_testing_id=sub_special_testing_id
      AND s.product_id=sub_product_id
      AND s.active_ind=1
     WITH nocounter, forupdate(s)
    ;end select
    IF (curqual=0)
     UPDATE  FROM special_testing s
      SET s.active_ind = sub_active_ind, s.active_status_cd = sub_active_status_cd, s.updt_cnt = (s
       .updt_cnt+ 1),
       s.updt_dt_tm = cnvtdatetime(sysdate), s.updt_id = reqinfo->updt_id, s.updt_task = reqinfo->
       updt_task,
       s.updt_applctx = reqinfo->updt_applctx
      WHERE s.special_testing_id=sub_special_testing_id
      WITH nocounter
     ;end update
    ENDIF
   ENDIF
   SUBROUTINE (chg_special_testing_result_2(sub_product_id=f8,sub_result_id=f8,sub_bb_result_id=f8,
    sub_active_ind=i2,sub_active_status_cd=f8) =null)
     SET gsub_inactive_spc_tst_rsl_status = "  "
     SELECT INTO "nl:"
      s.special_testing_id
      FROM special_testing_result s
      WHERE s.product_id=sub_product_id
       AND s.result_id=sub_result_id
       AND s.bb_result_id=sub_bb_result_id
       AND s.active_ind=1
      DETAIL
       gdspecial_testing_id = s.special_testing_id
      WITH nocounter, forupdate(s)
     ;end select
     IF (curqual=0)
      SET gsub_inactive_spc_tst_rsl_status = "FL"
     ENDIF
     IF (curqual > 0)
      UPDATE  FROM special_testing_result s
       SET s.active_ind = sub_active_ind, s.active_status_cd = sub_active_status_cd, s.updt_cnt = (s
        .updt_cnt+ 1),
        s.updt_dt_tm = cnvtdatetime(sysdate), s.updt_id = reqinfo->updt_id, s.updt_task = reqinfo->
        updt_task,
        s.updt_applctx = reqinfo->updt_applctx
       WHERE s.special_testing_id=gdspecial_testing_id
       WITH nocounter
      ;end update
      IF (curqual=0)
       SET gsub_inactive_spc_tst_rsl_status = "FU"
      ELSE
       SET gsub_inactive_spc_tst_rsl_status = "OK"
      ENDIF
     ENDIF
   END ;Subroutine
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
      p.updt_dt_tm = cnvtdatetime(sysdate), p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->
      updt_task,
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
      sub_active_status_prsnl_id, a.updt_dt_tm = cnvtdatetime(sysdate),
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
 SUBROUTINE add_person_rh_phenotype(sub_person_id,sub_nomenclature_id,sub_active_ind,
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
     brp_qual_cnt += 1, bb_rh_phenotype_id = brp.rh_phenotype_id
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
     INSERT  FROM person_rh_phenotype prp
      SET prp.person_rh_phenotype_id = new_rh_phenotype_id, prp.person_id = sub_person_id, prp
       .rh_phenotype_id = bb_rh_phenotype_id,
       prp.nomenclature_id = sub_nomenclature_id, prp.updt_cnt = 0, prp.updt_dt_tm = cnvtdatetime(
        sysdate),
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
 SUBROUTINE chg_person_rh_phenotype(sub_rh_phenotype_id,sub_updt_cnt,sub_active_ind,
  sub_active_status_cd)
   SET gsub_rh_phenotype_status = "  "
   SELECT INTO "nl:"
    prp.person_rh_phenotype_id
    FROM person_rh_phenotype prp
    WHERE prp.person_rh_phenotype_id=sub_rh_phenotype_id
     AND prp.updt_cnt=sub_updt_cnt
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET gsub_rh_phenotype_status = "FL"
   ELSE
    UPDATE  FROM person_rh_phenotype prp
     SET prp.updt_cnt = (prp.updt_cnt+ 1), prp.updt_dt_tm = cnvtdatetime(sysdate), prp.updt_id =
      reqinfo->updt_id,
      prp.updt_task = reqinfo->updt_task, prp.updt_applctx = reqinfo->updt_applctx, prp.active_ind =
      sub_active_ind,
      prp.active_status_cd = sub_active_status_cd
     WHERE prp.person_rh_phenotype_id=sub_rh_phenotype_id
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET gsub_rh_phenotype_status = "FU"
    ELSE
     SET gsub_rh_phenotype_status = "OK"
    ENDIF
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
     rh_a_cnt += 1, stat = alterlist(rh_a_rec->antigenlist,rh_a_cnt), rh_a_rec->antigenlist[rh_a_cnt]
     .antigen_cd = brpt.special_testing_cd
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
     rh_a_cnt += 1
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
 SUBROUTINE add_person_rh_pheno_result(sub_person_id,sub_encntr_id,sub_nomenclature_id,
  sub_rh_phenotype_id,sub_result_id,sub_active_ind,sub_active_status_cd,sub_active_status_dt_tm,
  sub_active_status_prsnl_id)
   SET gsub_rh_phenotype_status = "  "
   SET new_rh_phenotype_id = 0.0
   SET new_rh_phenotype_id = next_pathnet_seq(0)
   IF (curqual=0)
    SET gsub_rh_phenotype_status = "FS"
   ELSE
    INSERT  FROM person_rh_pheno_result prpr
     SET prpr.person_rh_pheno_rs_id = new_rh_phenotype_id, prpr.person_id = sub_person_id, prpr
      .encntr_id = sub_encntr_id,
      prpr.nomenclature_id = sub_nomenclature_id, prpr.person_rh_phenotype_id = sub_rh_phenotype_id,
      prpr.result_id = sub_result_id,
      prpr.updt_cnt = 0, prpr.updt_dt_tm = cnvtdatetime(sysdate), prpr.updt_id = reqinfo->updt_id,
      prpr.updt_cnt = 0, prpr.updt_task = reqinfo->updt_task, prpr.updt_applctx = reqinfo->
      updt_applctx,
      prpr.active_ind = sub_active_ind, prpr.active_status_cd = sub_active_status_cd, prpr
      .active_status_dt_tm = cnvtdatetime(sub_active_status_dt_tm),
      prpr.active_status_prsnl_id = sub_active_status_prsnl_id
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET gsub_rh_phenotype_status = "FA"
    ELSE
     SET gsub_rh_phenotype_status = "OK"
    ENDIF
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
     brp_qual_cnt += 1, bb_rh_phenotype_id = brp.rh_phenotype_id
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
        sysdate),
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
     SET prp.updt_cnt = (prp.updt_cnt+ 1), prp.updt_dt_tm = cnvtdatetime(sysdate), prp.updt_id =
      reqinfo->updt_id,
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
     SET st.updt_cnt = (st.updt_cnt+ 1), st.updt_dt_tm = cnvtdatetime(sysdate), st.updt_id = reqinfo
      ->updt_id,
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
 SUBROUTINE chg_person_antigen_by_key(sub_person_antigen_id,sub_updt_cnt,sub_active_ind,
  sub_active_status_cd)
   SET gsub_rh_phenotype_status = "  "
   SELECT INTO "nl:"
    pa.person_antigen_id
    FROM person_antigen pa
    WHERE pa.person_antigen_id=sub_person_antigen_id
     AND pa.updt_cnt=sub_updt_cnt
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET gsub_rh_phenotype_status = "FL"
   ELSE
    UPDATE  FROM person_antigen pa
     SET pa.updt_cnt = (pa.updt_cnt+ 1), pa.updt_dt_tm = cnvtdatetime(sysdate), pa.updt_id = reqinfo
      ->updt_id,
      pa.updt_cnt = 0, pa.updt_task = reqinfo->updt_task, pa.updt_applctx = reqinfo->updt_applctx,
      pa.removed_dt_tm = cnvtdatetime(sysdate), pa.removed_prsnl_id = reqinfo->updt_id, pa.active_ind
       = sub_active_ind,
      pa.active_status_cd = sub_active_status_cd
     WHERE pa.person_antigen_id=sub_person_antigen_id
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET gsub_rh_phenotype_status = "FU"
    ELSE
     SET gsub_rh_phenotype_status = "OK"
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE chg_person_rh_pheno_result(sub_rh_pheno_rs_id,sub_updt_cnt,sub_active_ind,
  sub_active_status_cd)
   SET gsub_rh_phenotype_status = "  "
   SELECT INTO "nl:"
    prpr.person_rh_pheno_rs_id
    FROM person_rh_pheno_result prpr
    WHERE prpr.person_rh_pheno_rs_id=sub_rh_pheno_rs_id
     AND prpr.updt_cnt=sub_updt_cnt
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET gsub_rh_phenotype_status = "FL"
   ELSE
    UPDATE  FROM person_rh_pheno_result prpr
     SET prpr.updt_cnt = (prpr.updt_cnt+ 1), prpr.updt_dt_tm = cnvtdatetime(sysdate), prpr.updt_id =
      reqinfo->updt_id,
      prpr.updt_task = reqinfo->updt_task, prpr.updt_applctx = reqinfo->updt_applctx, prpr.active_ind
       = sub_active_ind,
      prpr.active_status_cd = sub_active_status_cd
     WHERE prpr.person_rh_pheno_rs_id=sub_rh_pheno_rs_id
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET gsub_rh_phenotype_status = "FU"
    ELSE
     SET gsub_rh_phenotype_status = "OK"
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
 RECORD current(
   1 system_dt_tm = dq8
 )
 SET current->system_dt_tm = cnvtdatetime(sysdate)
 IF ((request->use_req_dt_tm_ind=1))
  SET reply->event_dt_tm = cnvtdatetime(request->event_dt_tm)
 ELSE
  SET request->event_dt_tm = cnvtdatetime(current->system_dt_tm)
  SET reply->event_dt_tm = cnvtdatetime(current->system_dt_tm)
 ENDIF
 SET select_ok_ind = 0
 DECLARE failed = c1 WITH protected, noconstant("F")
 DECLARE result_type_codeset = i4 WITH public, constant(289)
 DECLARE result_type_text_cdf = c12 WITH public, constant("1")
 DECLARE result_type_alpha_cdf = c12 WITH public, constant("2")
 DECLARE result_type_numeric_cdf = c12 WITH public, constant("3")
 DECLARE result_type_interp_cdf = c12 WITH public, constant("4")
 DECLARE result_type_date_cdf = c12 WITH public, constant("6")
 DECLARE result_type_freetext_cdf = c12 WITH public, constant("7")
 DECLARE result_type_calc_cdf = c12 WITH public, constant("8")
 DECLARE result_type_date_time_cdf = c12 WITH public, constant("11")
 DECLARE result_status_codeset = i4 WITH public, constant(1901)
 DECLARE result_status_verified_cdf = c12 WITH public, constant("VERIFIED")
 DECLARE result_status_old_verf_cdf = c12 WITH public, constant("OLDVERIFIED")
 DECLARE result_status_corrected_cdf = c12 WITH public, constant("CORRECTED")
 DECLARE result_status_old_corr_cdf = c12 WITH public, constant("OLDCORRECTED")
 DECLARE result_status_corr_in_review_cdf = c12 WITH public, constant("CORRINREV")
 DECLARE result_status_old_corr_in_review_cdf = c12 WITH public, constant("OLDCORRINREV")
 DECLARE product_state_codeset = i4 WITH public, constant(1610)
 DECLARE crossmatch_cdf = c12 WITH public, constant("3")
 DECLARE confirmed_cdf = c12 WITH public, constant("19")
 DECLARE available_cdf = c12 WITH public, constant("12")
 DECLARE unconfirmed_cdf = c12 WITH public, constant("9")
 DECLARE xm_order_processing_mean = c12 WITH public, constant("XM")
 DECLARE bbidnbr_result_processing_mean = c12 WITH public, constant("BB ID NBR")
 DECLARE xm_reason_processing_mean = c12 WITH public, constant("REASON")
 DECLARE special_testing_code_set = i4 WITH protect, constant(1612)
 DECLARE result_type_text_cd = f8
 DECLARE result_type_alpha_cd = f8
 DECLARE result_type_interp_cd = f8
 DECLARE result_type_numeric_cd = f8
 DECLARE result_type_date_cd = f8
 DECLARE result_type_freetext_cd = f8
 DECLARE result_type_calc_cd = f8
 DECLARE result_type_date_time_cd = f8
 DECLARE result_status_verified_cd = f8
 DECLARE result_status_old_verf_cd = f8
 DECLARE result_status_corrected_cd = f8
 DECLARE result_status_old_corr_cd = f8
 DECLARE result_status_corr_in_review_cd = f8 WITH public, noconstant(0.0)
 DECLARE result_status_old_corr_in_rev_cd = f8 WITH public, noconstant(0.0)
 DECLARE crossmatch_cd = f8
 DECLARE confirmed_cd = f8
 DECLARE available_cd = f8
 DECLARE unconfirmed_cd = f8
 SET cv_required_recs = 16
 DECLARE cv_cnt = i4
 DECLARE pe_xm_cnt = i4
 SET result_status_verified_disp = "            "
 DECLARE nbr_of_orders = i4
 DECLARE nbr_of_assays = i4
 DECLARE nbr_of_result_comments = i4
 DECLARE oidx = i4
 DECLARE aidx = i4
 DECLARE rcidx = i4
 DECLARE nbr_of_treqs = i4
 DECLARE treq_idx = i4
 DECLARE xm_active_ind = i2
 DECLARE xm_active_cd = f8
 DECLARE nbr_of_auto_dirs = i4
 DECLARE auto_dir_idx = i4
 DECLARE new_special_testing_id = f8
 DECLARE rh_a_cnt = i4
 DECLARE rh_a = i4
 DECLARE new_rh_phenotype_id = f8
 DECLARE new_person_rh_phenotype_id = f8
 DECLARE new_product_rh_phenotype_id = f8
 DECLARE bb_rh_phenotype_id = f8
 DECLARE parent_perf_result_id = f8
 DECLARE curr_result_status_cd = f8
 DECLARE hold_product_id = f8
 DECLARE hold_control_cell = f8
 DECLARE last_action_seq = i4
 DECLARE perf_result_seq = f8
 DECLARE bb_result_seq = f8
 DECLARE in_progress_prev_update = c1
 DECLARE order_cell_prev_update = c1
 DECLARE conf_product_event_id = f8
 DECLARE person_aborh_id = f8
 DECLARE long_text_seq = f8
 DECLARE temp_person_id = f8
 SET status_count = 0
 DECLARE excep_prod_event_id = f8
 DECLARE excep_prod_event_type_cd = f8
 DECLARE pn_recovery_type_cd = f8 WITH public, noconstant(0.0)
 DECLARE pn_recovery_type_cdf = c12 WITH public, constant("PNRESULT    ")
 DECLARE pn_recovery_type_codeset = i4 WITH public, constant(28600)
 DECLARE pn_recovery_info_domain = vc WITH public, constant("PATHNET")
 DECLARE pn_recovery_info_name = vc WITH public, constant("BB_RESULT_RECOVERY")
 DECLARE bb_id_nbr = vc WITH protect, noconstant("")
 DECLARE xm_reason_cd = f8 WITH protect, noconstant(0.0)
 SET rh_test_only = " "
 SET abo_test_only = " "
 SET abo_rh_test = " "
 SET write_aborh_result = " "
 SET gsub_person_aborh_status = "  "
 SET gsub_person_aborh_inact_status = "  "
 SET gsub_inactive_aborh_rsl_status = "  "
 SET gsub_aborh_result_status = "  "
 SET gsub_person_antibody_status = "  "
 SET gsub_inactive_prs_antibody_status = "  "
 SET gsub_person_antigen_status = "  "
 SET gsub_inactive_prs_antigen_status = "  "
 SET gsub_special_testing_status = "  "
 SET gsub_inactive_spcl_tst_status = "  "
 SET gsub_spc_tst_result_status = "  "
 SET gsub_inactive_spc_tst_rsl_status = "  "
 SET product_rh_test_only = " "
 SET product_abo_test_only = " "
 SET product_abo_rh_test = " "
 SET write_result = " "
 SET current_updated_ind = 0
 SET gsub_blood_product_status = "  "
 SET gsub_abo_testing_status = "  "
 SET gsub_rh_phenotype_status = "  "
 SET pat_aborh_upd_conflict_ind = 0
 DECLARE stat = i2 WITH protected, noconstant(0)
 DECLARE gsub_bbd_rh_phenotype_status = c2 WITH protect, noconstant(fillstring(2,"  "))
 DECLARE gdspecial_testing_id = f8 WITH protect, noconstant(0.0)
 DECLARE exception_status = c2 WITH protect, noconstant(fillstring(2,"  "))
#script
 SET reply->status_data.status = "F"
 SET stat = uar_get_meaning_by_codeset(result_type_codeset,result_type_text_cdf,1,result_type_text_cd
  )
 IF (result_type_text_cd=0.0)
  SET failed = "T"
  CALL subevent_add("UAR","F",result_type_codeset,"result_type_text_cd")
 ENDIF
 SET stat = uar_get_meaning_by_codeset(result_type_codeset,result_type_alpha_cdf,1,
  result_type_alpha_cd)
 IF (result_type_alpha_cd=0.0)
  SET failed = "T"
  CALL subevent_add("UAR","F",result_type_codeset,"result_type_alpha_cd")
 ENDIF
 SET stat = uar_get_meaning_by_codeset(result_type_codeset,result_type_interp_cdf,1,
  result_type_interp_cd)
 IF (result_type_interp_cd=0.0)
  SET failed = "T"
  CALL subevent_add("UAR","F",result_type_codeset,"result_type_interp_cd")
 ENDIF
 SET stat = uar_get_meaning_by_codeset(result_type_codeset,result_type_numeric_cdf,1,
  result_type_numeric_cd)
 IF (result_type_numeric_cd=0.0)
  SET failed = "T"
  CALL subevent_add("UAR","F",result_type_codeset,"result_type_numeric_cd")
 ENDIF
 SET stat = uar_get_meaning_by_codeset(result_type_codeset,result_type_date_cdf,1,result_type_date_cd
  )
 IF (result_type_date_cd=0.0)
  SET failed = "T"
  CALL subevent_add("UAR","F",result_type_codeset,"result_type_date_cd")
 ENDIF
 SET stat = uar_get_meaning_by_codeset(result_type_codeset,result_type_freetext_cdf,1,
  result_type_freetext_cd)
 IF (result_type_freetext_cd=0.0)
  SET failed = "T"
  CALL subevent_add("UAR","F",result_type_codeset,"result_type_freetext_cd")
 ENDIF
 SET stat = uar_get_meaning_by_codeset(result_type_codeset,result_type_calc_cdf,1,result_type_calc_cd
  )
 IF (result_type_calc_cd=0.0)
  SET failed = "T"
  CALL subevent_add("UAR","F",result_type_codeset,"result_type_calc_cd")
 ENDIF
 SET stat = uar_get_meaning_by_codeset(result_type_codeset,result_type_date_time_cdf,1,
  result_type_date_time_cd)
 IF (result_type_date_time_cd=0.0)
  SET failed = "T"
  CALL subevent_add("UAR","F",result_type_codeset,"result_type_date_time_cd")
 ENDIF
 SET stat = uar_get_meaning_by_codeset(result_status_codeset,result_status_old_verf_cdf,1,
  result_status_old_verf_cd)
 IF (result_status_old_verf_cd=0.0)
  SET failed = "T"
  CALL subevent_add("UAR","F",result_status_codeset,"result_status_old_verf_cd")
 ENDIF
 SET stat = uar_get_meaning_by_codeset(result_status_codeset,result_status_verified_cdf,1,
  result_status_verified_cd)
 IF (result_status_verified_cd=0.0)
  SET failed = "T"
  CALL subevent_add("UAR","F",result_status_codeset,"result_status_verified_cd")
 ENDIF
 SET stat = uar_get_meaning_by_codeset(result_status_codeset,result_status_corrected_cdf,1,
  result_status_corrected_cd)
 IF (result_status_corrected_cd=0.0)
  SET failed = "T"
  CALL subevent_add("UAR","F",result_status_codeset,"result_status_corrected_cd")
 ENDIF
 SET stat = uar_get_meaning_by_codeset(result_status_codeset,result_status_old_corr_cdf,1,
  result_status_old_corr_cd)
 IF (result_status_old_corr_cd=0.0)
  SET failed = "T"
  CALL subevent_add("UAR","F",result_status_codeset,"result_status_old_corr_cd")
 ENDIF
 SET stat = uar_get_meaning_by_codeset(result_status_codeset,result_status_corr_in_review_cdf,1,
  result_status_corr_in_review_cd)
 IF (result_status_corr_in_review_cd=0.0)
  SET failed = "T"
  CALL subevent_add("UAR","F",result_status_codeset,"result_status_corr_in_review_cd")
 ENDIF
 SET stat = uar_get_meaning_by_codeset(result_status_codeset,result_status_old_corr_in_review_cdf,1,
  result_status_old_corr_in_rev_cd)
 IF (result_status_old_corr_in_rev_cd=0.0)
  SET failed = "T"
  CALL subevent_add("UAR","F",result_status_codeset,"result_status_old_corr_in_rev_cd")
 ENDIF
 SET stat = uar_get_meaning_by_codeset(product_state_codeset,crossmatch_cdf,1,crossmatch_cd)
 IF (crossmatch_cd=0.0)
  SET failed = "T"
  CALL subevent_add("UAR","F",product_state_codeset,"crossmatch_cd")
 ENDIF
 SET stat = uar_get_meaning_by_codeset(product_state_codeset,confirmed_cdf,1,confirmed_cd)
 IF (confirmed_cd=0.0)
  SET failed = "T"
  CALL subevent_add("UAR","F",product_state_codeset,"confirmed_cd")
 ENDIF
 SET stat = uar_get_meaning_by_codeset(product_state_codeset,available_cdf,1,available_cd)
 IF (available_cd=0.0)
  SET failed = "T"
  CALL subevent_add("UAR","F",product_state_codeset,"available_cd")
 ENDIF
 SET stat = uar_get_meaning_by_codeset(product_state_codeset,unconfirmed_cdf,1,unconfirmed_cd)
 IF (unconfirmed_cd=0.0)
  SET failed = "T"
  CALL subevent_add("UAR","F",product_state_codeset,"unconfirmed_cd")
 ENDIF
 SET stat = uar_get_meaning_by_codeset(pn_recovery_type_codeset,pn_recovery_type_cdf,1,
  pn_recovery_type_cd)
 IF (pn_recovery_type_cd=0.0)
  SET failed = "T"
  CALL subevent_add("UAR","F",pn_recovery_type_codeset,"pn_recovery_type_cd")
 ENDIF
 IF (failed="T")
  GO TO exit_script
 ENDIF
 SET reply->pn_recovery_ind = 1
 SELECT INTO "nl:"
  dm.info_domain
  FROM dm_info dm
  PLAN (dm
   WHERE dm.info_domain=pn_recovery_info_domain
    AND dm.info_name=pn_recovery_info_name)
  DETAIL
   reply->pn_recovery_ind = 0
  WITH nocounter
 ;end select
 IF ((validate(ens_orderserver,- (1))=- (1)))
  CALL echo("Declaring netting constants")
  DECLARE ens_collections = i2 WITH constant(0), persist
  DECLARE ens_orderserver = i2 WITH constant(1), persist
  DECLARE ens_servererror = i2 WITH constant(2), persist
  DECLARE ens_success = i2 WITH constant(4), persist
  DECLARE ens_canceled = i2 WITH constant(8), persist
  DECLARE ens_genericerror = i2 WITH constant(150), persist
  DECLARE ens_inprocess = i2 WITH constant(500), persist
  DECLARE ens_orderduped = i2 WITH constant(501), persist
  DECLARE ens_alreadyprocessed = i2 WITH constant(502), persist
  DECLARE ens_noresources = i2 WITH constant(503), persist
  DECLARE ens_containernetting = i2 WITH constant(504), persist
  DECLARE ens_invalidorderstatus = i2 WITH constant(505), persist
  DECLARE enpf_default = i2 WITH constant(0), persist
  DECLARE enpf_accession = i2 WITH constant(1), persist
  DECLARE enpf_noaccession = i2 WITH constant(50), persist
  DECLARE enpf_esi = i2 WITH constant(51), persist
  DECLARE enpf_server = i2 WITH constant(60), persist
  DECLARE enpf_collections = i2 WITH constant(100), persist
  DECLARE enpf_transfer = i2 WITH constant(125), persist
  DECLARE ecs_pending = i2 WITH constant(0), persist
  DECLARE ecs_collected = i2 WITH constant(1), persist
  DECLARE ecs_missedonhold = i2 WITH constant(2), persist
  DECLARE ecs_missedrecollect = i2 WITH constant(3), persist
  DECLARE ecs_missedrescheduled = i2 WITH constant(4), persist
  DECLARE ecs_missedcanceled = i2 WITH constant(5), persist
  DECLARE ecs_missedomitted = i2 WITH constant(6), persist
  DECLARE ecs_inactive = i2 WITH constant(7), persist
  DECLARE eppf_department = i2 WITH constant(0), persist
  DECLARE eppf_cerner = i2 WITH constant(1), persist
  DECLARE eppf_esi = i2 WITH constant(2), persist
  DECLARE eppf_missrescheduled = i2 WITH constant(150), persist
  DECLARE eppf_missnotrescheduled = i2 WITH constant(175), persist
  DECLARE eppf_netted = i2 WITH constant(200), persist
  DECLARE egwof_donotgroup = i2 WITH constant(0), persist
  DECLARE egwof_grouptime = i2 WITH constant(1), persist
  DECLARE egwof_groupkeeptime = i2 WITH constant(2), persist
  DECLARE esf_pending = i2 WITH constant(0), persist
  DECLARE esf_inlab = i2 WITH constant(1), persist
  DECLARE esf_endstatus = i2 WITH constant(2), persist
  DECLARE eprf_noroutereeval = i2 WITH constant(0), persist
  DECLARE eprf_routereevaleligible = i2 WITH constant(1), persist
  DECLARE eprf_patientlocreeval = i2 WITH constant(2), persist
  DECLARE eprf_loginlocreeval = i2 WITH constant(3), persist
  DECLARE eocipf_usecollclass = i2 WITH constant(0), persist
  DECLARE eocipf_printcontid = i2 WITH constant(1), persist
  DECLARE eocipf_noprintcontid = i2 WITH constant(2), persist
  DECLARE eetf_noexception = i2 WITH constant(0), persist
  DECLARE eetf_fcontnotmatched = i2 WITH constant(1), persist
  DECLARE eetf_fcontnotused = i2 WITH constant(2), persist
  DECLARE eetf_existcontconflict = i2 WITH constant(3), persist
  DECLARE eetf_barcodeconflict = i2 WITH constant(4), persist
  DECLARE eetf_collclassspechndl = i2 WITH constant(5), persist
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
   DECLARE pcs_returned_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",29161,"RETURNED"))
   DECLARE pcs_performed_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",1901,"PERFORMED")
    )
   DECLARE pcs_no_auto_verify_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",1903,"112"))
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
         SET lpcs_assay_cnt += 1
         IF (lpcs_assay_cnt=1)
          SET lpcs_order_cnt += 1
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
        ELSEIF (uar_get_code_meaning(request->orders[lorders_idx].assays[lassay_idx].result_status_cd
         ) IN ("PERFORMED"))
         CALL log_message("Start perform_interfaced_result",log_level_debug)
         DECLARE instrument_flag = i2 WITH protect, noconstant(0)
         DECLARE manual_review_flag = i2 WITH protect, noconstant(0)
         DECLARE auto_verify_flag = i2 WITH protect, noconstant(0)
         DECLARE lrevidx = i4 WITH protect, noconstant(0)
         DECLARE product_type_val = f8 WITH protect, noconstant(0)
         DECLARE assay_service_resource_cd = f8 WITH protect, noconstant(0)
         SELECT INTO "nl:"
          FROM pcs_review_item pri1
          WHERE (pri1.order_id=request->orders[lorders_idx].order_id)
          DETAIL
           IF (pri1.hierarchy_id > 0
            AND pri1.review_criteria_id=0)
            manual_review_flag = 1
           ENDIF
          WITH nocounter
         ;end select
         SELECT INTO "nl:"
          FROM perform_result pr,
           auto_verify_code avc,
           pcs_review_item ri,
           pcs_review_criteria prc,
           dummyt d
          PLAN (d)
           JOIN (pr
           WHERE (pr.result_id=request->orders[lorders_idx].assays[lassay_idx].result_id))
           JOIN (avc
           WHERE pr.perform_result_id=avc.parent_entity_id)
           JOIN (ri
           WHERE ri.parent_entity_id=pr.result_id)
           JOIN (prc
           WHERE prc.hierarchy_id=ri.hierarchy_id)
          DETAIL
           IF (avc.auto_verify_cd=pcs_no_auto_verify_cd
            AND ri.review_criteria_id > 0)
            auto_verify_flag = 1
           ENDIF
          WITH nocounter
         ;end select
         SET instrument_flag = request->orders[lorders_idx].assays[lassay_idx].interface_flag
         IF (((instrument_flag
          AND manual_review_flag) OR (auto_verify_flag
          AND instrument_flag)) )
          CALL log_message(build("inside update block--->",instrument_flag),log_level_debug)
          UPDATE  FROM pcs_review_item pri
           SET pri.review_status_cd = pcs_returned_cd
           WHERE (pri.parent_entity_id=request->orders[lorders_idx].assays[lassay_idx].result_id)
          ;end update
          SELECT INTO "nl:"
           FROM pcs_review_item p
           WHERE (p.parent_entity_id=request->orders[lorders_idx].assays[lassay_idx].result_id)
           DETAIL
            product_type_val = p.review_id
           WITH nocounter
          ;end select
          UPDATE  FROM pcs_queue_assignment pqa
           SET pqa.review_status_cd = pcs_returned_cd
           WHERE pqa.review_id=product_type_val
          ;end update
          UPDATE  FROM perform_result pr
           SET pr.result_status_cd = pcs_performed_cd
           WHERE (pr.result_id=request->orders[lorders_idx].assays[lassay_idx].result_id)
          ;end update
          UPDATE  FROM result r
           SET r.result_status_cd = pcs_performed_cd
           WHERE (r.result_id=request->orders[lorders_idx].assays[lassay_idx].result_id)
          ;end update
          SET assay_service_resource_cd = 0
          SELECT INTO "nl:"
           FROM order_procedure_exception ope
           WHERE (ope.task_assay_cd=request->orders[lorders_idx].assays[lassay_idx].task_assay_cd)
            AND (ope.order_id=request->orders[lorders_idx].order_id)
           DETAIL
            assay_service_resource_cd = ope.service_resource_cd
           WITH nocounter
          ;end select
          UPDATE  FROM order_serv_res_container osrc
           SET osrc.status_flag = esf_inlab, osrc.updt_dt_tm = cnvtdatetime(curdate,curtime), osrc
            .updt_id = reqinfo->updt_id,
            osrc.updt_cnt = (osrc.updt_cnt+ 1), osrc.updt_task = reqinfo->updt_task, osrc
            .updt_applctx = reqinfo->updt_applctx
           PLAN (osrc
            WHERE (osrc.order_id=request->orders[lorders_idx].order_id)
             AND osrc.status_flag=esf_endstatus
             AND osrc.container_id IN (
            (SELECT
             ocr.container_id
             FROM order_container_r ocr
             WHERE (ocr.order_id=request->orders[lorders_idx].order_id)
              AND ocr.collection_status_flag IN (ecs_pending, ecs_collected, ecs_missedonhold,
             ecs_missedrecollect)))
             AND ((assay_service_resource_cd=0) OR (osrc.service_resource_cd=
            assay_service_resource_cd)) )
          ;end update
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
 SET product_event_id = 0.0
 SET re_event_type_cd = 0.0
 SET result_seq = 0.0
 SET order_update_complete = "N"
 FOR (oidx = 1 TO nbr_of_orders)
   SET nbr_of_assays = request->orders[oidx].assays_cnt
   SET reply->orders[oidx].order_id = request->orders[oidx].order_id
   SET reply->orders[oidx].assays_cnt = nbr_of_assays
   SET stat = alterlist(reply->orders[oidx].assays,nbr_of_assays)
   SET bb_id_nbr = ""
   SET xm_reason_cd = 0.0
   FOR (aidx = 1 TO nbr_of_assays)
     IF (textlen(request->orders[oidx].assays[aidx].rtf_text) > 32000)
      SET failed = "T"
      CALL subevent_add("RTF_TEXT","F","long_text","Long text exceeds 32,000 characters.")
      GO TO exit_script
     ENDIF
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
     ENDIF
     SET reply->orders[oidx].assays[aidx].task_assay_cd = request->orders[oidx].assays[aidx].
     task_assay_cd
     SET reply->orders[oidx].assays[aidx].updt_id = reqinfo->updt_id
     SET reply->orders[oidx].assays[aidx].result_key = request->orders[oidx].assays[aidx].result_key
     SET reply->orders[oidx].assays[aidx].perform_result_key = request->orders[oidx].assays[aidx].
     perform_result_key
     SET reply->orders[oidx].assays[aidx].result_status_cd = request->orders[oidx].assays[aidx].
     result_status_cd
     IF ((request->orders[oidx].assays[aidx].bb_result_id > 0))
      SET bb_result_seq = request->orders[oidx].assays[aidx].bb_result_id
     ELSE
      SET bb_result_seq = 0.0
     ENDIF
     IF (process_updated_result(0)=0)
      GO TO exit_script
     ENDIF
     SET reply->orders[oidx].assays[aidx].bb_result_id = bb_result_seq
     IF ((request->orders[oidx].assays[aidx].product_id > 0))
      SET reply->orders[oidx].assays[aidx].product_id = request->orders[oidx].assays[aidx].product_id
     ELSE
      SET reply->orders[oidx].assays[aidx].product_id = request->orders[oidx].assays[aidx].
      bb_control_cell_cd
     ENDIF
     IF ((((request->orders[oidx].assays[aidx].bb_control_cell_cd != hold_control_cell)) OR ((request
     ->orders[oidx].assays[aidx].next_row_ind=1))) )
      SET hold_control_cell = request->orders[oidx].assays[aidx].bb_control_cell_cd
     ENDIF
     IF ((request->orders[oidx].donor_ind=0))
      IF ((request->orders[oidx].bb_processing_mean=xm_order_processing_mean))
       IF ((request->orders[oidx].assays[aidx].bb_result_processing_mean=
       bbidnbr_result_processing_mean))
        SET bb_id_nbr = request->orders[oidx].assays[aidx].ascii_text
       ELSEIF ((request->orders[oidx].assays[aidx].bb_result_processing_mean=
       xm_reason_processing_mean))
        SET xm_reason_cd = request->orders[oidx].assays[aidx].bb_result_code_set_cd
       ENDIF
      ENDIF
      IF ((request->orders[oidx].assays[aidx].inprogress_prod_event_id > 0)
       AND (request->orders[oidx].assays[aidx].product_aborh_verify_yn != "Y"))
       IF ((((request->orders[oidx].assays[aidx].product_id != hold_product_id)) OR ((request->
       orders[oidx].assays[aidx].crossmatch_verify_yn="Y"))) )
        IF (update_crossmatch(0)=0)
         GO TO exit_script
        ENDIF
       ENDIF
      ELSEIF ((request->orders[oidx].assays[aidx].aborh_verify_yn="Y")
       AND (request->orders[oidx].assays[aidx].bb_result_code_set_cd > 0))
       SET person_aborh_id = 0.0
       IF (update_patient_aborh(0)=1)
        SET reply->orders[oidx].assays[aidx].new_abo_cd = request->orders[oidx].assays[aidx].
        new_abo_cd
        SET reply->orders[oidx].assays[aidx].new_rh_cd = request->orders[oidx].assays[aidx].new_rh_cd
        SET reply->orders[oidx].assays[aidx].new_aborh_updt_cnt = (request->orders[oidx].assays[aidx]
        .person_aborh_updt_cnt+ 1)
       ELSE
        IF (gsub_person_aborh_status="FS")
         SET failed = "T"
         SET status_count += 1
         IF (status_count > 1)
          SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
         ENDIF
         SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
         SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
         SET reply->status_data.subeventstatus[status_count].targetobjectname = "Person Aborh"
         SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
         "Unable to insert person_aborh due to aborh id"
        ELSEIF (gsub_person_aborh_status="FA")
         SET failed = "T"
         SET status_count += 1
         IF (status_count > 1)
          SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
         ENDIF
         SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
         SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
         SET reply->status_data.subeventstatus[status_count].targetobjectname = "Person Aborh"
         SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
         "Unable to insert person aborh"
        ENDIF
        IF (gsub_person_aborh_inact_status="FL")
         SET failed = "T"
         SET status_count += 1
         IF (status_count > 1)
          SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
         ENDIF
         SET reply->status_data.subeventstatus[status_count].operationname = "LOCK"
         SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
         SET reply->status_data.subeventstatus[status_count].targetobjectname = "Person Aborh"
         SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
         "Unable to lock person_aborh for update"
        ELSEIF (gsub_person_aborh_inact_status="FU")
         SET failed = "T"
         SET status_count += 1
         IF (status_count > 1)
          SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
         ENDIF
         SET reply->status_data.subeventstatus[status_count].operationname = "CHANGE"
         SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
         SET reply->status_data.subeventstatus[status_count].targetobjectname = "Person Aborh"
         SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
         "Unable to inactivate person aborh"
        ENDIF
        IF (gsub_inactive_aborh_rsl_status="FL")
         SET failed = "T"
         SET status_count += 1
         IF (status_count > 1)
          SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
         ENDIF
         SET reply->status_data.subeventstatus[status_count].operationname = "LOCK"
         SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
         SET reply->status_data.subeventstatus[status_count].targetobjectname = "Person Aborh Result"
         SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
         "Unable to lock person_aborh_result for update"
        ELSEIF (gsub_inactive_aborh_rsl_status="FU")
         SET failed = "T"
         SET status_count += 1
         IF (status_count > 1)
          SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
         ENDIF
         SET reply->status_data.subeventstatus[status_count].operationname = "CHANGE"
         SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
         SET reply->status_data.subeventstatus[status_count].targetobjectname = "Person Aborh Result"
         SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
         "Unable to inactivate person aborh result"
        ENDIF
        IF (gsub_aborh_result_status="FP")
         SET failed = "T"
         SET status_count += 1
         IF (status_count > 1)
          SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
         ENDIF
         SET reply->status_data.subeventstatus[status_count].operationname = "select"
         SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
         SET reply->status_data.subeventstatus[status_count].targetobjectname = "Person Aborh"
         SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
         "Unable to find active person record on person_aborh"
        ELSEIF (gsub_aborh_result_status="FS")
         SET failed = "T"
         SET status_count += 1
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
         SET status_count += 1
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
      ELSEIF ((request->orders[oidx].assays[aidx].antibody_verify_yn="Y")
       AND (request->orders[oidx].assays[aidx].bb_result_code_set_cd > 0))
       SET gsub_person_antibody_status = "  "
       SET gsub_inactive_prs_antibody_status = "  "
       IF ((request->review_queue_ind=0))
        CALL chg_person_antibody(request->orders[oidx].person_id,request->orders[oidx].encntr_id,
         request->orders[oidx].assays[aidx].orig_result_code_set_cd,reply->orders[oidx].assays[aidx].
         result_id,bb_result_seq,
         0,reqdata->active_status_cd,request->orders[oidx].assays[aidx].person_antibody_updt_cnt,1)
        IF (gsub_inactive_prs_antibody_status != "OK")
         IF (gsub_inactive_prs_antibody_status="FL")
          SET failed = "T"
          SET status_count += 1
          IF (status_count > 1)
           SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
          ENDIF
          SET reply->status_data.subeventstatus[status_count].operationname = "LOCK"
          SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
          SET reply->status_data.subeventstatus[status_count].targetobjectname = "Person Antibody"
          SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
          "Unable to lock person_antibody for update"
         ELSEIF (gsub_inactive_prs_antibody_status="FU")
          SET failed = "T"
          SET status_count += 1
          IF (status_count > 1)
           SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
          ENDIF
          SET reply->status_data.subeventstatus[status_count].operationname = "CHANGE"
          SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
          SET reply->status_data.subeventstatus[status_count].targetobjectname = "Person Antibody"
          SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
          "Unable to inactivate person antibody"
         ENDIF
         GO TO exit_script
        ENDIF
       ELSEIF ((request->review_queue_ind=1))
        CALL chg_person_antibody_2(request->orders[oidx].person_id,request->orders[oidx].encntr_id,
         reply->orders[oidx].assays[aidx].result_id,bb_result_seq,0,
         reqdata->active_status_cd)
        IF (gsub_inactive_prs_antibody_status != "OK")
         IF (gsub_inactive_prs_antibody_status="FL")
          SET failed = "T"
          SET status_count += 1
          IF (status_count > 1)
           SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
          ENDIF
          SET reply->status_data.subeventstatus[status_count].operationname = "LOCK"
          SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
          SET reply->status_data.subeventstatus[status_count].targetobjectname = "Person Antibody"
          SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
          "Unable to lock person_antibody for update"
         ELSEIF (gsub_inactive_prs_antibody_status="FU")
          SET failed = "T"
          SET status_count += 1
          IF (status_count > 1)
           SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
          ENDIF
          SET reply->status_data.subeventstatus[status_count].operationname = "CHANGE"
          SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
          SET reply->status_data.subeventstatus[status_count].targetobjectname = "Person Antibody"
          SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
          "Unable to inactivate person antibody"
         ENDIF
         GO TO exit_script
        ENDIF
       ENDIF
       CALL add_person_antibody(request->orders[oidx].person_id,request->orders[oidx].encntr_id,
        request->orders[oidx].assays[aidx].bb_result_code_set_cd,reply->orders[oidx].assays[aidx].
        result_id,bb_result_seq,
        1,reqdata->active_status_cd,cnvtdatetime(current->system_dt_tm),request->event_personnel_id)
       IF (gsub_person_antibody_status != "OK")
        IF (gsub_person_antibody_status="FA")
         SET failed = "T"
         SET status_count += 1
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
      ELSEIF ((request->orders[oidx].assays[aidx].antigen_verify_yn="Y")
       AND (request->orders[oidx].assays[aidx].bb_result_code_set_cd > 0))
       SET gsub_person_antigen_status = "  "
       SET gsub_inactive_prs_antigen_status = "  "
       IF ((request->review_queue_ind=0))
        CALL chg_person_antigen(request->orders[oidx].person_id,request->orders[oidx].encntr_id,
         request->orders[oidx].assays[aidx].orig_result_code_set_cd,reply->orders[oidx].assays[aidx].
         result_id,bb_result_seq,
         0,reqdata->active_status_cd,request->orders[oidx].assays[aidx].person_antigen_updt_cnt,1)
        IF (gsub_inactive_prs_antigen_status != "OK")
         IF (gsub_inactive_prs_antigen_status="FL")
          SET failed = "T"
          SET status_count += 1
          IF (status_count > 1)
           SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
          ENDIF
          SET reply->status_data.subeventstatus[status_count].operationname = "LOCK"
          SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
          SET reply->status_data.subeventstatus[status_count].targetobjectname = "Person Antigen"
          SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
          "Unable to lock person_antigen for update"
         ELSEIF (gsub_inactive_prs_antigen_status="FU")
          SET failed = "T"
          SET status_count += 1
          IF (status_count > 1)
           SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
          ENDIF
          SET reply->status_data.subeventstatus[status_count].operationname = "CHANGE"
          SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
          SET reply->status_data.subeventstatus[status_count].targetobjectname = "Person Antigen"
          SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
          "Unable to inactivate person antigen"
         ENDIF
         GO TO exit_script
        ENDIF
       ELSEIF ((request->review_queue_ind=1))
        CALL chg_person_antigen_2(request->orders[oidx].person_id,request->orders[oidx].encntr_id,
         reply->orders[oidx].assays[aidx].result_id,bb_result_seq,0,
         reqdata->active_status_cd)
        IF (gsub_inactive_prs_antigen_status != "OK")
         IF (gsub_inactive_prs_antigen_status="FL")
          SET failed = "T"
          SET status_count += 1
          IF (status_count > 1)
           SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
          ENDIF
          SET reply->status_data.subeventstatus[status_count].operationname = "LOCK"
          SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
          SET reply->status_data.subeventstatus[status_count].targetobjectname = "Person Antigen"
          SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
          "Unable to lock person_antigen for update"
         ELSEIF (gsub_inactive_prs_antigen_status="FU")
          SET failed = "T"
          SET status_count += 1
          IF (status_count > 1)
           SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
          ENDIF
          SET reply->status_data.subeventstatus[status_count].operationname = "CHANGE"
          SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
          SET reply->status_data.subeventstatus[status_count].targetobjectname = "Person Antigen"
          SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
          "Unable to inactivate person antigen"
         ENDIF
         GO TO exit_script
        ENDIF
       ENDIF
       CALL add_person_antigen(request->orders[oidx].person_id,request->orders[oidx].encntr_id,
        request->orders[oidx].assays[aidx].bb_result_code_set_cd,reply->orders[oidx].assays[aidx].
        result_id,bb_result_seq,
        0,1,reqdata->active_status_cd,cnvtdatetime(current->system_dt_tm),request->event_personnel_id
        )
       IF (gsub_person_antigen_status != "OK")
        IF (gsub_person_antigen_status="FA")
         SET failed = "T"
         SET status_count += 1
         IF (status_count > 1)
          SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
         ENDIF
         SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
         SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
         SET reply->status_data.subeventstatus[status_count].targetobjectname = "Person Antigen"
         SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
         "Unable to insert person antigen"
        ENDIF
        GO TO exit_script
       ENDIF
      ELSEIF ((request->orders[oidx].assays[aidx].special_testing_verify_yn="Y")
       AND (request->orders[oidx].assays[aidx].bb_result_code_set_cd > 0))
       SET orig_special_testing_id = 0.0
       SET new_special_testing_id = 0.0
       SET gsub_special_testing_status = "  "
       SET gsub_inactive_spcl_tst_status = "  "
       SET gsub_spc_tst_result_status = "  "
       SET gsub_inactive_spc_tst_rsl_status = "  "
       SET sub_product_id = 0.0
       IF ((request->orders[oidx].assays[aidx].product_test_special_test_yn="Y"))
        SET sub_product_id = request->orders[oidx].person_id
       ELSE
        SET sub_product_id = request->orders[oidx].assays[aidx].product_id
       ENDIF
       SET opposite_found_ind = 0
       SELECT INTO "nl:"
        st.product_id, st.special_testing_cd, st.active_ind,
        str.result_id, cv.code_value, cv.code_set,
        cv.cdf_meaning, cve.code_set, cve.code_value,
        cve.field_name, cve.field_value
        FROM special_testing st,
         special_testing_result str,
         code_value cv,
         code_value_extension cve
        PLAN (st
         WHERE st.product_id=sub_product_id
          AND st.active_ind=1)
         JOIN (cv
         WHERE cv.code_set=1612
          AND cv.code_value=st.special_testing_cd
          AND ((cv.cdf_meaning="-") OR (cv.cdf_meaning="+")) )
         JOIN (cve
         WHERE cve.code_set=cv.code_set
          AND cve.code_value=cv.code_value
          AND cve.field_name="Opposite")
         JOIN (str
         WHERE (str.special_testing_id= Outerjoin(st.special_testing_id)) )
        HEAD REPORT
         found_ind = 0
        DETAIL
         IF ((cnvtreal(cve.field_value)=request->orders[oidx].assays[aidx].bb_result_code_set_cd))
          IF ((reply->orders[oidx].assays[aidx].result_id != str.result_id))
           found_ind = 1
          ENDIF
         ENDIF
        FOOT REPORT
         opposite_found_ind = found_ind
        WITH nocounter
       ;end select
       IF (opposite_found_ind=1)
        SET reply->opposite_found_product_id = sub_product_id
        IF ((request->orders[oidx].assays[aidx].product_test_special_test_yn != "Y"))
         SET reply->opposite_found_person_id = request->orders[oidx].person_id
        ENDIF
        SET reply->opposite_found_order_id = request->orders[oidx].order_id
        SET reply->opposite_found_assay_id = request->orders[oidx].assays[aidx].task_assay_cd
        SET reply->opposite_found_prfrm_rslt_key = request->orders[oidx].assays[aidx].
        perform_result_key
        SET failed = "T"
        SET reply->status_data.status = "Z"
        SET status_count += 1
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
        IF ((request->review_queue_ind=0))
         CALL chg_special_testing_result(orig_special_testing_id,sub_product_id,reply->orders[oidx].
          assays[aidx].result_id,reply->orders[oidx].assays[aidx].bb_result_id,0,
          reqdata->active_status_cd,request->orders[oidx].assays[aidx].spcl_tst_rsl_updt_cnt,1,
          request->orders[oidx].assays[aidx].orig_result_code_set_cd,request->orders[oidx].assays[
          aidx].special_testing_updt_cnt)
         IF (gsub_inactive_spc_tst_rsl_status != "OK")
          IF (gsub_inactive_spcl_tst_status="FL")
           SET failed = "T"
           SET status_count += 1
           IF (status_count > 1)
            SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
           ENDIF
           SET reply->status_data.subeventstatus[status_count].operationname = "LOCK"
           SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
           SET reply->status_data.subeventstatus[status_count].targetobjectname = "Special Testing"
           SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
           "Unable to lock special_testing for update"
          ELSEIF (gsub_inactive_spcl_tst_status="FU")
           SET failed = "T"
           SET status_count += 1
           IF (status_count > 1)
            SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
           ENDIF
           SET reply->status_data.subeventstatus[status_count].operationname = "CHANGE"
           SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
           SET reply->status_data.subeventstatus[status_count].targetobjectname = "Special Testing"
           SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
           "Unable to inactivate special testing"
          ENDIF
          GO TO exit_script
         ENDIF
        ELSEIF ((request->review_queue_ind=1))
         CALL chg_special_testing_result_2(sub_product_id,reply->orders[oidx].assays[aidx].result_id,
          reply->orders[oidx].assays[aidx].bb_result_id,0,reqdata->active_status_cd)
         IF (gsub_inactive_spc_tst_rsl_status != "OK")
          IF (gsub_inactive_spcl_tst_status="FL")
           SET failed = "T"
           SET status_count += 1
           IF (status_count > 1)
            SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
           ENDIF
           SET reply->status_data.subeventstatus[status_count].operationname = "LOCK"
           SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
           SET reply->status_data.subeventstatus[status_count].targetobjectname = "Special Testing"
           SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
           "Unable to lock special_testing for update"
          ELSEIF (gsub_inactive_spcl_tst_status="FU")
           SET failed = "T"
           SET status_count += 1
           IF (status_count > 1)
            SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
           ENDIF
           SET reply->status_data.subeventstatus[status_count].operationname = "CHANGE"
           SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
           SET reply->status_data.subeventstatus[status_count].targetobjectname = "Special Testing"
           SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
           "Unable to inactivate special testing"
          ENDIF
          GO TO exit_script
         ENDIF
        ENDIF
        IF ((request->orders[oidx].assays[aidx].upd_prod_spcl_tst_yn="Y"))
         IF ((request->review_queue_ind=0))
          CALL chg_special_testing(sub_product_id,request->orders[oidx].assays[aidx].
           orig_result_code_set_cd,0,reqdata->active_status_cd,request->orders[oidx].assays[aidx].
           special_testing_updt_cnt,
           1)
          IF (gsub_inactive_spcl_tst_status != "OK")
           IF (gsub_inactive_spcl_tst_status="FL")
            SET failed = "T"
            SET status_count += 1
            IF (status_count > 1)
             SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
            ENDIF
            SET reply->status_data.subeventstatus[status_count].operationname = "LOCK"
            SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
            SET reply->status_data.subeventstatus[status_count].targetobjectname = "Special Testing"
            SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
            "Unable to lock special_testing for update"
           ELSEIF (gsub_inactive_spcl_tst_status="FU")
            SET failed = "T"
            SET status_count += 1
            IF (status_count > 1)
             SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
            ENDIF
            SET reply->status_data.subeventstatus[status_count].operationname = "CHANGE"
            SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
            SET reply->status_data.subeventstatus[status_count].targetobjectname = "Special Testing"
            SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
            "Unable to inactivate special testing"
           ENDIF
           GO TO exit_script
          ENDIF
         ELSEIF ((request->review_queue_ind=1))
          CALL chg_special_testing_2(gdspecial_testing_id,0,reqdata->inactive_status_cd)
          IF (gsub_inactive_spcl_tst_status != "OK")
           IF (gsub_inactive_spcl_tst_status="FL")
            SET failed = "T"
            SET status_count += 1
            IF (status_count > 1)
             SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
            ENDIF
            SET reply->status_data.subeventstatus[status_count].operationname = "LOCK"
            SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
            SET reply->status_data.subeventstatus[status_count].targetobjectname = "Special Testing"
            SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
            "Unable to lock special_testing for update"
           ELSEIF (gsub_inactive_spcl_tst_status="FU")
            SET failed = "T"
            SET status_count += 1
            IF (status_count > 1)
             SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
            ENDIF
            SET reply->status_data.subeventstatus[status_count].operationname = "CHANGE"
            SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
            SET reply->status_data.subeventstatus[status_count].targetobjectname = "Special Testing"
            SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
            "Unable to inactivate special testing"
           ENDIF
           GO TO exit_script
          ENDIF
         ENDIF
        ENDIF
       ENDIF
      ELSEIF ((request->orders[oidx].assays[aidx].product_aborh_verify_yn="Y")
       AND (request->orders[oidx].assays[aidx].bb_result_code_set_cd > 0))
       IF (update_product_aborh(0)=1)
        SET reply->orders[oidx].assays[aidx].new_abo_cd = request->orders[oidx].assays[aidx].
        product_new_abo_cd
        SET reply->orders[oidx].assays[aidx].new_rh_cd = request->orders[oidx].assays[aidx].
        product_new_rh_cd
        SET reply->orders[oidx].assays[aidx].new_aborh_updt_cnt = (request->orders[oidx].assays[aidx]
        .blood_product_updt_cnt+ 1)
       ELSE
        IF (gsub_blood_product_status="FL")
         SET failed = "T"
         SET status_count += 1
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
         SET status_count += 1
         IF (status_count > 1)
          SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
         ENDIF
         SET reply->status_data.subeventstatus[status_count].operationname = "UPDATE"
         SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
         SET reply->status_data.subeventstatus[status_count].targetobjectname = "BLOOD_PRODUCT"
         SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
         "Unable to update blood product"
        ENDIF
        GO TO exit_script
       ENDIF
      ELSEIF ((request->orders[oidx].assays[aidx].rh_phenotype_verify_yn="Y")
       AND (request->orders[oidx].assays[aidx].nomenclature_id > 0))
       IF ((request->orders[oidx].assays[aidx].upd_rh_phenotype_yn="Y"))
        IF ((request->orders[oidx].assays[aidx].rh_phenotype_id > 0))
         CALL chg_person_rh_phenotype(request->orders[oidx].assays[aidx].rh_phenotype_id,request->
          orders[oidx].assays[aidx].rh_phenotype_updt_cnt,0,reqdata->inactive_status_cd)
         IF (gsub_rh_phenotype_status="FL")
          SET failed = "T"
          SET status_count += 1
          IF (status_count > 1)
           SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
          ENDIF
          SET reply->status_data.subeventstatus[status_count].operationname = "SELECT forupdate"
          SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
          SET reply->status_data.subeventstatus[status_count].targetobjectname =
          "person_rh_phenotype"
          SET reply->status_data.subeventstatus[status_count].targetobjectvalue = concat(
           "Lock person_rh_phenotype row for update failed for person_rh_phenotype_id = ",cnvtstring(
            request->orders[oidx].assays[aidx].rh_phenotype_id,32,2),", updt_id = ",cnvtstring(
            request->orders[oidx].assays[aidx].rh_phenotype_updt_cnt),", order_id =",
           cnvtstring(request->orders[oidx].order_id,32,2))
          GO TO exit_script
         ELSEIF (gsub_rh_phenotype_status="FU")
          SET failed = "T"
          SET status_count += 1
          IF (status_count > 1)
           SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
          ENDIF
          SET reply->status_data.subeventstatus[status_count].operationname = "UPDATE"
          SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
          SET reply->status_data.subeventstatus[status_count].targetobjectname =
          "person_rh_phenotype"
          SET reply->status_data.subeventstatus[status_count].targetobjectvalue = concat(
           "Update into person_rh_phenotype failed person_rh_phenotype_id = ",cnvtstring(request->
            orders[oidx].assays[aidx].rh_phenotype_id,32,2),", updt_id = ",cnvtstring(request->
            orders[oidx].assays[aidx].rh_phenotype_updt_cnt),", order_id =",
           cnvtstring(request->orders[oidx].order_id,32,2))
          GO TO exit_script
         ELSEIF (gsub_rh_phenotype_status != "OK")
          SET failed = "T"
          SET status_count += 1
          IF (status_count > 1)
           SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
          ENDIF
          SET reply->status_data.subeventstatus[status_count].operationname = "UPDATE"
          SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
          SET reply->status_data.subeventstatus[status_count].targetobjectname =
          "person_rh_phenotype"
          SET reply->status_data.subeventstatus[status_count].targetobjectvalue = concat(
           "Update into person_rh_phenotype failed. Invalid status (",trim(gsub_rh_phenotype_status),
           ") person_rh_phenotype_id = ",cnvtstring(request->orders[oidx].assays[aidx].
            rh_phenotype_id,32,2),", updt_id = ",
           cnvtstring(request->orders[oidx].assays[aidx].rh_phenotype_updt_cnt),", order_id =",
           cnvtstring(request->orders[oidx].order_id,32,2))
          GO TO exit_script
         ENDIF
         IF ((request->orders[oidx].assays[aidx].person_rh_pheno_rs_id > 0))
          CALL chg_person_rh_pheno_result(request->orders[oidx].assays[aidx].person_rh_pheno_rs_id,
           request->orders[oidx].assays[aidx].person_rh_pheno_rs_updt_cnt,0,reqdata->
           inactive_status_cd)
          IF (gsub_rh_phenotype_status="FL")
           SET failed = "T"
           SET status_count += 1
           IF (status_count > 1)
            SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
           ENDIF
           SET reply->status_data.subeventstatus[status_count].operationname = "SELECT forupdate"
           SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
           SET reply->status_data.subeventstatus[status_count].targetobjectname =
           "person_rh_pheno_result"
           SET reply->status_data.subeventstatus[status_count].targetobjectvalue = concat(
            "Lock person_rh_pheno_result row for update failed for person_rh_pheno_rs_id = ",
            cnvtstring(request->orders[oidx].assays[aidx].person_rh_pheno_rs_id,32,2),", updt_id = ",
            cnvtstring(request->orders[oidx].assays[aidx].rh_phenotype_updt_cnt),", order_id =",
            cnvtstring(request->orders[oidx].order_id,32,2))
           GO TO exit_script
          ELSEIF (gsub_rh_phenotype_status="FU")
           SET failed = "T"
           SET status_count += 1
           IF (status_count > 1)
            SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
           ENDIF
           SET reply->status_data.subeventstatus[status_count].operationname = "UPDATE"
           SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
           SET reply->status_data.subeventstatus[status_count].targetobjectname =
           "person_rh_pheno_result"
           SET reply->status_data.subeventstatus[status_count].targetobjectvalue = concat(
            "Update into person_rh_pheno_result failed person_rh_pheno_rs_id = ",cnvtstring(request->
             orders[oidx].assays[aidx].person_rh_pheno_rs_id,32,2),", updt_id = ",cnvtstring(request
             ->orders[oidx].assays[aidx].rh_phenotype_updt_cnt),", order_id =",
            cnvtstring(request->orders[oidx].order_id,32,2))
           GO TO exit_script
          ELSEIF (gsub_rh_phenotype_status != "OK")
           SET failed = "T"
           SET status_count += 1
           IF (status_count > 1)
            SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
           ENDIF
           SET reply->status_data.subeventstatus[status_count].operationname = "UPDATE"
           SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
           SET reply->status_data.subeventstatus[status_count].targetobjectname =
           "person_rh_pheno_result"
           SET reply->status_data.subeventstatus[status_count].targetobjectvalue = concat(
            "Update into person_rh_pheno_result failed. Invalid status (",trim(
             gsub_rh_phenotype_status),") person_rh_pheno_rs_id = ",cnvtstring(request->orders[oidx].
             assays[aidx].person_rh_pheno_rs_id,32,2),", updt_id = ",
            cnvtstring(request->orders[oidx].assays[aidx].rh_phenotype_updt_cnt),", order_id =",
            cnvtstring(request->orders[oidx].order_id,32,2))
           GO TO exit_script
          ENDIF
         ENDIF
         SET rh_a_cnt = request->orders[oidx].assays[aidx].rh_antigen_cnt
         FOR (rh_a = 1 TO rh_a_cnt)
          CALL chg_person_antigen_by_key(request->orders[oidx].assays[aidx].rh_antigenlist[rh_a].
           table_id,request->orders[oidx].assays[aidx].rh_antigenlist[rh_a].updt_cnt,0,reqdata->
           inactive_status_cd)
          IF (gsub_rh_phenotype_status="FL")
           SET failed = "T"
           SET status_count += 1
           IF (status_count > 1)
            SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
           ENDIF
           SET reply->status_data.subeventstatus[status_count].operationname = "SELECT forupdate"
           SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
           SET reply->status_data.subeventstatus[status_count].targetobjectname = "person_antigen"
           SET reply->status_data.subeventstatus[status_count].targetobjectvalue = concat(
            "Lock person_antigen row for update failed for person_antigen_id = ",cnvtstring(request->
             orders[oidx].assays[aidx].rh_antigenlist[rh_a].table_id,32,2),", updt_cnt = ",cnvtstring
            (request->orders[oidx].assays[aidx].rh_antigenlist[rh_a].updt_cnt),", order_id = ",
            cnvtstring(request->orders[oidx].order_id,32,2))
           GO TO exit_script
          ELSEIF (gsub_rh_phenotype_status="FU")
           SET failed = "T"
           SET status_count += 1
           IF (status_count > 1)
            SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
           ENDIF
           SET reply->status_data.subeventstatus[status_count].operationname = "UPDATE"
           SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
           SET reply->status_data.subeventstatus[status_count].targetobjectname = "person_antigen"
           SET reply->status_data.subeventstatus[status_count].targetobjectvalue = concat(
            "Update into person_antigen failed for person_antigen_id = ",cnvtstring(request->orders[
             oidx].assays[aidx].rh_antigenlist[rh_a].table_id,32,2),", updt_cnt = ",cnvtstring(
             request->orders[oidx].assays[aidx].rh_antigenlist[rh_a].updt_cnt),", order_id = ",
            cnvtstring(request->orders[oidx].order_id,32,2))
           GO TO exit_script
          ELSEIF (gsub_rh_phenotype_status != "OK")
           SET failed = "T"
           SET status_count += 1
           IF (status_count > 1)
            SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
           ENDIF
           SET reply->status_data.subeventstatus[status_count].operationname = "UPDATE"
           SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
           SET reply->status_data.subeventstatus[status_count].targetobjectname = "person_antigen"
           SET reply->status_data.subeventstatus[status_count].targetobjectvalue = concat(
            "Update into person_antigen failed.  Invalid status (",trim(gsub_rh_phenotype_status),
            ") for person_antigen_id = ",cnvtstring(request->orders[oidx].assays[aidx].
             rh_antigenlist[rh_a].table_id,32,2),", updt_cnt = ",
            cnvtstring(request->orders[oidx].assays[aidx].rh_antigenlist[rh_a].updt_cnt),
            ", order_id = ",cnvtstring(request->orders[oidx].order_id,32,2))
           GO TO exit_script
          ENDIF
         ENDFOR
        ENDIF
        SET gsub_rh_phenotype_status = "  "
        CALL add_person_rh_phenotype(request->orders[oidx].person_id,request->orders[oidx].assays[
         aidx].nomenclature_id,1,reqdata->active_status_cd,cnvtdatetime(sysdate),
         reqinfo->updt_id)
        IF (gsub_rh_phenotype_status="FZ")
         SET failed = "T"
         SET status_count += 1
         IF (status_count > 1)
          SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
         ENDIF
         SET reply->status_data.subeventstatus[status_count].operationname = "SELECT"
         SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
         SET reply->status_data.subeventstatus[status_count].targetobjectname = "bb_rh_phenotype"
         SET reply->status_data.subeventstatus[status_count].targetobjectvalue = concat(
          "No rows exist on bb_rh_phenotype for resulted nomenclature_id for order_id = ",cnvtstring(
           request->orders[oidx].order_id,32,2),".  Could not retrieve rh_phenotype_id")
         GO TO exit_script
        ELSEIF (gsub_rh_phenotype_status="FM")
         SET failed = "T"
         SET status_count += 1
         IF (status_count > 1)
          SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
         ENDIF
         SET reply->status_data.subeventstatus[status_count].operationname = "SELECT"
         SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
         SET reply->status_data.subeventstatus[status_count].targetobjectname = "bb_rh_phenotype"
         SET reply->status_data.subeventstatus[status_count].targetobjectvalue = concat(
          "Multiple bb_rh_phenotype rows found for resulted nomenclature_id for order_id = ",
          cnvtstring(request->orders[oidx].order_id,32,2),".  Could not retrieve rh_phenotype_id")
         GO TO exit_script
        ELSEIF (gsub_rh_phenotype_status="FF")
         SET failed = "T"
         SET status_count += 1
         IF (status_count > 1)
          SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
         ENDIF
         SET reply->status_data.subeventstatus[status_count].operationname = "SELECT"
         SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
         SET reply->status_data.subeventstatus[status_count].targetobjectname = "bb_rh_phenotype"
         SET reply->status_data.subeventstatus[status_count].targetobjectvalue = concat(
          "CCL error.  Select failed on bb_rh_phenotype table ",
          "for resulted nomenclature_id for order_id = ",cnvtstring(request->orders[oidx].order_id,32,
           2),".  Could not retrieve rh_phenotype_id")
         GO TO exit_script
        ELSEIF (gsub_rh_phenotype_status="FS")
         SET failed = "T"
         SET status_count += 1
         IF (status_count > 1)
          SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
         ENDIF
         SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
         SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
         SET reply->status_data.subeventstatus[status_count].targetobjectname = "person_rh_phenotype"
         SET reply->status_data.subeventstatus[status_count].targetobjectvalue = concat(
          "Could not insert person_rh_phenotype row--get next pathnet_seq",
          " for id failed for order_id = ",cnvtstring(request->orders[oidx].order_id,32,2))
         GO TO exit_script
        ELSEIF (gsub_rh_phenotype_status="FA")
         SET failed = "T"
         SET status_count += 1
         IF (status_count > 1)
          SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
         ENDIF
         SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
         SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
         SET reply->status_data.subeventstatus[status_count].targetobjectname = "person_rh_phenotype"
         SET reply->status_data.subeventstatus[status_count].targetobjectvalue = concat(
          "Insert person_rh_phenotype row failed for order_id = ",cnvtstring(request->orders[oidx].
           order_id,32,2))
         GO TO exit_script
        ELSEIF (gsub_rh_phenotype_status != "OK")
         SET failed = "T"
         SET status_count += 1
         IF (status_count > 1)
          SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
         ENDIF
         SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
         SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
         SET reply->status_data.subeventstatus[status_count].targetobjectname = "person_rh_phenotype"
         SET reply->status_data.subeventstatus[status_count].targetobjectvalue = concat(
          "Could not insert person_rh_phenotype row due to invalid insert status (",trim(
           gsub_rh_phenotype_status),") for order_id = ",cnvtstring(request->orders[oidx].order_id,32,
           2))
         GO TO exit_script
        ENDIF
        SET new_person_rh_phenotype_id = new_rh_phenotype_id
        SET gsub_rh_phenotype_status = "  "
        CALL get_rh_phenotype_antigens(bb_rh_phenotype_id)
        IF (gsub_rh_phenotype_status != "OK")
         SET failed = "T"
         SET status_count += 1
         IF (status_count > 1)
          SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
         ENDIF
         SET reply->status_data.subeventstatus[status_count].operationname = "SELECT"
         SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
         SET reply->status_data.subeventstatus[status_count].targetobjectname = "bb_rh_phenotype"
         SET reply->status_data.subeventstatus[status_count].targetobjectvalue = concat(
          "rh_phenotype select failed for nomenclature_id = ",cnvtstring(request->orders[oidx].
           assays[aidx].nomenclature_id,32,2),", for order_id = ",cnvtstring(request->orders[oidx].
           order_id,32,2),".  No results added/updated.")
         GO TO exit_script
        ENDIF
        SET rh_a_cnt = size(rh_a_rec->antigenlist,5)
        FOR (rh_a = 1 TO rh_a_cnt)
          SET gsub_person_antigen_status = "  "
          CALL add_person_antigen(request->orders[oidx].person_id,request->orders[oidx].encntr_id,
           rh_a_rec->antigenlist[rh_a].antigen_cd,reply->orders[oidx].assays[aidx].result_id,0,
           new_person_rh_phenotype_id,1,reqdata->active_status_cd,cnvtdatetime(sysdate),reqinfo->
           updt_id)
          IF (gsub_person_antigen_status="FS")
           SET failed = "T"
           SET status_count += 1
           IF (status_count > 1)
            SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
           ENDIF
           SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
           SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
           SET reply->status_data.subeventstatus[status_count].targetobjectname = "person_antigen"
           SET reply->status_data.subeventstatus[status_count].targetobjectvalue = concat(
            "Could not insert person_antigen row--get next pathnet_seq for id failed ",
            "for order_id = ",cnvtstring(request->orders[oidx].order_id,32,2))
           GO TO exit_script
          ELSEIF (gsub_person_antigen_status="FA")
           SET failed = "T"
           SET status_count += 1
           IF (status_count > 1)
            SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
           ENDIF
           SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
           SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
           SET reply->status_data.subeventstatus[status_count].targetobjectname = "person_antigen"
           SET reply->status_data.subeventstatus[status_count].targetobjectvalue = concat(
            "Insert person_antigen row failed for order_id = ",cnvtstring(request->orders[oidx].
             order_id,32,2))
           GO TO exit_script
          ELSEIF (gsub_person_antigen_status != "OK")
           SET failed = "T"
           SET status_count += 1
           IF (status_count > 1)
            SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
           ENDIF
           SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
           SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
           SET reply->status_data.subeventstatus[status_count].targetobjectname = "person_antigen"
           SET reply->status_data.subeventstatus[status_count].targetobjectvalue = concat(
            "Could not insert person_antigen row due to invalid insert status (",trim(
             gsub_person_antigen_status),") for order_id = ",cnvtstring(request->orders[oidx].
             order_id,32,2))
           GO TO exit_script
          ENDIF
        ENDFOR
       ENDIF
       CALL add_person_rh_pheno_result(request->orders[oidx].person_id,request->orders[oidx].
        encntr_id,request->orders[oidx].assays[aidx].nomenclature_id,new_person_rh_phenotype_id,reply
        ->orders[oidx].assays[aidx].result_id,
        1,reqdata->active_status_cd,cnvtdatetime(sysdate),reqinfo->updt_id)
       IF (gsub_rh_phenotype_status="FS")
        SET failed = "T"
        SET status_count += 1
        IF (status_count > 1)
         SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
        ENDIF
        SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
        SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
        SET reply->status_data.subeventstatus[status_count].targetobjectname =
        "person_rh_pheno_result"
        SET reply->status_data.subeventstatus[status_count].targetobjectvalue = concat(
         "Could not insert person_rh_pheno_result row--get next pathnet_seq for id failed ",
         "for order_id = ",cnvtstring(request->orders[oidx].order_id,32,2))
        GO TO exit_script
       ELSEIF (gsub_rh_phenotype_status="FA")
        SET failed = "T"
        SET status_count += 1
        IF (status_count > 1)
         SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
        ENDIF
        SET reply->status_data.subeventstatus[status_count].operationname = "UPDATE"
        SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
        SET reply->status_data.subeventstatus[status_count].targetobjectname =
        "person_rh_pheno_result"
        SET reply->status_data.subeventstatus[status_count].targetobjectvalue = concat(
         "Insert person_rh_pheno_result row failed for order_id = ",cnvtstring(request->orders[oidx].
          order_id,32,2))
        GO TO exit_script
       ELSEIF (gsub_rh_phenotype_status != "OK")
        SET failed = "T"
        SET status_count += 1
        IF (status_count > 1)
         SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
        ENDIF
        SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
        SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
        SET reply->status_data.subeventstatus[status_count].targetobjectname =
        "person_rh_pheno_result"
        SET reply->status_data.subeventstatus[status_count].targetobjectvalue = concat(
         "Could not insert person_rh_pheno_result row due to invalid insert status (",trim(
          gsub_rh_phenotype_status),") for order_id = ",cnvtstring(request->orders[oidx].order_id,32,
          2))
        GO TO exit_script
       ENDIF
      ELSEIF ((request->orders[oidx].assays[aidx].product_rh_phenotype_verify_yn="Y")
       AND (request->orders[oidx].assays[aidx].nomenclature_id > 0))
       SET new_special_testing_id = 0.0
       SET gsub_special_testing_status = "  "
       SET gsub_inactive_spcl_tst_status = "  "
       SET gsub_spc_tst_result_status = "  "
       SET gsub_inactive_spc_tst_rsl_status = "  "
       IF ((request->orders[oidx].assays[aidx].upd_rh_phenotype_yn="Y"))
        IF ((request->orders[oidx].assays[aidx].rh_phenotype_id > 0))
         CALL chg_product_rh_phenotype(request->orders[oidx].assays[aidx].rh_phenotype_id,request->
          orders[oidx].assays[aidx].rh_phenotype_updt_cnt,0,reqdata->inactive_status_cd)
         IF (gsub_rh_phenotype_status="FL")
          SET failed = "T"
          SET status_count += 1
          IF (status_count > 1)
           SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
          ENDIF
          SET reply->status_data.subeventstatus[status_count].operationname = "SELECT forupdate"
          SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
          SET reply->status_data.subeventstatus[status_count].targetobjectname =
          "product_rh_phenotype"
          SET reply->status_data.subeventstatus[status_count].targetobjectvalue = concat(
           "Lock product_rh_phenotype row for update failed for product_rh_phenotype_id = ",
           cnvtstring(request->orders[oidx].assays[aidx].rh_phenotype_id,32,2),", updt_id = ",
           cnvtstring(request->orders[oidx].assays[aidx].rh_phenotype_updt_cnt),", order_id =",
           cnvtstring(request->orders[oidx].order_id,32,2))
          GO TO exit_script
         ELSEIF (gsub_rh_phenotype_status="FU")
          SET failed = "T"
          SET status_count += 1
          IF (status_count > 1)
           SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
          ENDIF
          SET reply->status_data.subeventstatus[status_count].operationname = "UPDATE"
          SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
          SET reply->status_data.subeventstatus[status_count].targetobjectname =
          "product_rh_phenotype"
          SET reply->status_data.subeventstatus[status_count].targetobjectvalue = concat(
           "Update into product_rh_phenotype failed product_rh_phenotype_id = ",cnvtstring(request->
            orders[oidx].assays[aidx].rh_phenotype_id,32,2),", updt_id = ",cnvtstring(request->
            orders[oidx].assays[aidx].rh_phenotype_updt_cnt),", order_id =",
           cnvtstring(request->orders[oidx].order_id,32,2))
          GO TO exit_script
         ENDIF
         SET rh_a_cnt = request->orders[oidx].assays[aidx].rh_antigen_cnt
         FOR (rh_a = 1 TO rh_a_cnt)
           CALL chg_special_testing_by_key(request->orders[oidx].assays[aidx].rh_antigenlist[rh_a].
            table_id,request->orders[oidx].assays[aidx].rh_antigenlist[rh_a].updt_cnt,0,reqdata->
            inactive_status_cd)
           IF (gsub_rh_phenotype_status="FL")
            SET failed = "T"
            SET status_count += 1
            IF (status_count > 1)
             SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
            ENDIF
            SET reply->status_data.subeventstatus[status_count].operationname = "SELECT forupdate"
            SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
            SET reply->status_data.subeventstatus[status_count].targetobjectname = "special_testing"
            SET reply->status_data.subeventstatus[status_count].targetobjectvalue = concat(
             "Lock special_testing row for update failed for special_testing_id = ",cnvtstring(
              request->orders[oidx].assays[aidx].rh_antigenlist[rh_a].table_id,32,2),", updt_cnt = ",
             cnvtstring(request->orders[oidx].assays[aidx].rh_antigenlist[rh_a].updt_cnt),
             ", order_id = ",
             cnvtstring(request->orders[oidx].order_id,32,2))
            GO TO exit_script
           ELSEIF (gsub_rh_phenotype_status="FU")
            SET failed = "T"
            SET status_count += 1
            IF (status_count > 1)
             SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
            ENDIF
            SET reply->status_data.subeventstatus[status_count].operationname = "UPDATE"
            SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
            SET reply->status_data.subeventstatus[status_count].targetobjectname = "special_testing"
            SET reply->status_data.subeventstatus[status_count].targetobjectvalue = concat(
             "Update into special_testing failed for special_testing_id = ",cnvtstring(request->
              orders[oidx].assays[aidx].rh_antigenlist[rh_a].table_id,32,2),", updt_cnt = ",
             cnvtstring(request->orders[oidx].assays[aidx].rh_antigenlist[rh_a].updt_cnt),
             ", order_id = ",
             cnvtstring(request->orders[oidx].order_id,32,2))
            GO TO exit_script
           ELSEIF (gsub_rh_phenotype_status != "OK")
            SET failed = "T"
            SET status_count += 1
            IF (status_count > 1)
             SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
            ENDIF
            SET reply->status_data.subeventstatus[status_count].operationname = "UPDATE"
            SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
            SET reply->status_data.subeventstatus[status_count].targetobjectname = "special_testing"
            SET reply->status_data.subeventstatus[status_count].targetobjectvalue = concat(
             "Update into special_testing failed.  Invalid file status (",trim(
              gsub_rh_phenotype_status),") for special_testing_id = ",cnvtstring(request->orders[oidx
              ].assays[aidx].rh_antigenlist[rh_a].table_id,32,2),", updt_cnt = ",
             cnvtstring(request->orders[oidx].assays[aidx].rh_antigenlist[rh_a].updt_cnt),
             ", order_id = ",cnvtstring(request->orders[oidx].order_id,32,2))
            GO TO exit_script
           ENDIF
           CALL chg_special_testing_result(request->orders[oidx].assays[aidx].rh_antigenlist[rh_a].
            table_id,request->orders[oidx].person_id,reply->orders[oidx].assays[aidx].result_id,0.0,0,
            reqdata->inactive_status_cd,request->orders[oidx].assays[aidx].rh_antigenlist[rh_a].
            spcl_tst_rsl_updt_cnt,1,0.0,0)
           IF (gsub_inactive_spc_tst_rsl_status != "OK")
            IF (gsub_inactive_spcl_tst_status="FL")
             SET failed = "T"
             SET status_count += 1
             IF (status_count > 1)
              SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
             ENDIF
             SET reply->status_data.subeventstatus[status_count].operationname = "LOCK"
             SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
             SET reply->status_data.subeventstatus[status_count].targetobjectname = "Special Testing"
             SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
             "Unable to lock special_testing for update"
            ELSEIF (gsub_inactive_spcl_tst_status="FU")
             SET failed = "T"
             SET status_count += 1
             IF (status_count > 1)
              SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
             ENDIF
             SET reply->status_data.subeventstatus[status_count].operationname = "CHANGE"
             SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
             SET reply->status_data.subeventstatus[status_count].targetobjectname = "Special Testing"
             SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
             "Unable to inactivate special testing"
            ELSE
             SET failed = "T"
             SET status_count += 1
             IF (status_count > 1)
              SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
             ENDIF
             SET reply->status_data.subeventstatus[status_count].operationname = "CHANGE"
             SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
             SET reply->status_data.subeventstatus[status_count].targetobjectname = "Special Testing"
             SET reply->status_data.subeventstatus[status_count].targetobjectvalue = concat(
              "Unable to inactivate special testing--Invalid status: ",trim(
               gsub_inactive_spcl_tst_status))
            ENDIF
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
         ENDFOR
         SET stat = alterlist(rh_a_rec->antigenlist,0)
        ENDIF
        CALL bbd_get_rh_phenotype_antigens(request->orders[oidx].assays[aidx].nomenclature_id)
        IF (gsub_bbd_rh_phenotype_status != "OK")
         SET failed = "T"
         SET status_count += 1
         IF (status_count > 1)
          SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
         ENDIF
         SET reply->status_data.subeventstatus[status_count].operationname = "SELECT"
         SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
         SET reply->status_data.subeventstatus[status_count].targetobjectname = "bb_rh_phenotype"
         SET reply->status_data.subeventstatus[status_count].targetobjectvalue = concat(
          "rh_phenotype select failed for nomenclature_id = ",cnvtstring(request->orders[oidx].
           assays[aidx].nomenclature_id,32,2),", for order_id = ",cnvtstring(request->orders[oidx].
           order_id,32,2),".  No results added/updated.")
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
          rh_cnt += 1
         DETAIL
          rh_a_rec->antigenlist[rh_cnt].opposite_cd = cnvtreal(cve.field_value)
         WITH nocounter
        ;end select
        IF (rh_a_cnt != rh_cnt)
         SET failed = "T"
         SET status_count += 1
         IF (status_count > 1)
          SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
         ENDIF
         SET reply->status_data.subeventstatus[status_count].operationname = "SELECT"
         SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
         SET reply->status_data.subeventstatus[status_count].targetobjectname =
         "code_value_extension"
         SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
         "Could not load opposites or posting rh phenotype.  No results added/updated."
         GO TO exit_script
        ENDIF
        IF ((request->orders[oidx].assays[aidx].product_rh_phenotype_verify_yn="Y"))
         SET sub_product_id = request->orders[oidx].person_id
        ELSE
         SET sub_product_id = request->orders[oidx].assays[aidx].product_id
        ENDIF
        SET opposite_found_ind = 0
        SELECT INTO "nl:"
         FROM special_testing st,
          (dummyt d  WITH seq = value(rh_a_cnt))
         PLAN (d
          WHERE (rh_a_rec->antigenlist[d.seq].opposite_cd > 0.0))
          JOIN (st
          WHERE st.product_id=sub_product_id
           AND (st.special_testing_cd=rh_a_rec->antigenlist[d.seq].opposite_cd)
           AND st.active_ind=1)
         DETAIL
          opposite_found_ind = 1
         WITH nocounter
        ;end select
        IF (opposite_found_ind=1)
         SET reply->opposite_found_product_id = sub_product_id
         SET reply->opposite_found_order_id = request->orders[oidx].order_id
         SET reply->opposite_found_assay_id = request->orders[oidx].assays[aidx].task_assay_cd
         SET reply->opposite_found_prfrm_rslt_key = request->orders[oidx].assays[aidx].
         perform_result_key
         SET failed = "T"
         SET reply->status_data.status = "Z"
         SET status_count += 1
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
        CALL add_product_rh_phenotype(request->orders[oidx].person_id,request->orders[oidx].assays[
         aidx].nomenclature_id,1,reqdata->active_status_cd,cnvtdatetime(sysdate),
         reqinfo->updt_id)
        IF (gsub_rh_phenotype_status="FZ")
         SET failed = "T"
         SET status_count += 1
         IF (status_count > 1)
          SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
         ENDIF
         SET reply->status_data.subeventstatus[status_count].operationname = "SELECT"
         SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
         SET reply->status_data.subeventstatus[status_count].targetobjectname = "bb_rh_phenotype"
         SET reply->status_data.subeventstatus[status_count].targetobjectvalue = concat(
          "No rows exist on bb_rh_phenotype for resulted nomenclature_id for order_id = ",cnvtstring(
           request->orders[oidx].order_id,32,2),".  Could not retrieve rh_phenotype_id")
         GO TO exit_script
        ELSEIF (gsub_rh_phenotype_status="FM")
         SET failed = "T"
         SET status_count += 1
         IF (status_count > 1)
          SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
         ENDIF
         SET reply->status_data.subeventstatus[status_count].operationname = "SELECT"
         SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
         SET reply->status_data.subeventstatus[status_count].targetobjectname = "bb_rh_phenotype"
         SET reply->status_data.subeventstatus[status_count].targetobjectvalue = concat(
          "Multiple bb_rh_phenotype rows found for resulted nomenclature_id for order_id = ",
          cnvtstring(request->orders[oidx].order_id,32,2),".  Could not retrieve rh_phenotype_id")
         GO TO exit_script
        ELSEIF (gsub_rh_phenotype_status="FF")
         SET failed = "T"
         SET status_count += 1
         IF (status_count > 1)
          SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
         ENDIF
         SET reply->status_data.subeventstatus[status_count].operationname = "SELECT"
         SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
         SET reply->status_data.subeventstatus[status_count].targetobjectname = "bb_rh_phenotype"
         SET reply->status_data.subeventstatus[status_count].targetobjectvalue = concat(
          "CCL error.  Select failed on bb_rh_phenotype table ",
          "for resulted nomenclature_id for order_id = ",cnvtstring(request->orders[oidx].order_id,32,
           2),".  Could not retrieve rh_phenotype_id")
         GO TO exit_script
        ELSEIF (gsub_rh_phenotype_status="FS")
         SET failed = "T"
         SET status_count += 1
         IF (status_count > 1)
          SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
         ENDIF
         SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
         SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
         SET reply->status_data.subeventstatus[status_count].targetobjectname =
         "product_rh_phenotype"
         SET reply->status_data.subeventstatus[status_count].targetobjectvalue = concat(
          "Could not insert product_rh_phenotype row--get next pathnet_seq",
          "for id failed for order_id = ",cnvtstring(request->orders[oidx].order_id,32,2))
         GO TO exit_script
        ELSEIF (gsub_rh_phenotype_status="FA")
         SET failed = "T"
         SET status_count += 1
         IF (status_count > 1)
          SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
         ENDIF
         SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
         SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
         SET reply->status_data.subeventstatus[status_count].targetobjectname =
         "product_rh_phenotype"
         SET reply->status_data.subeventstatus[status_count].targetobjectvalue = concat(
          "Insert product_rh_phenotype row failed for order_id = ",cnvtstring(request->orders[oidx].
           order_id,32,2))
         GO TO exit_script
        ELSEIF (gsub_rh_phenotype_status != "OK")
         SET failed = "T"
         SET status_count += 1
         IF (status_count > 1)
          SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
         ENDIF
         SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
         SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
         SET reply->status_data.subeventstatus[status_count].targetobjectname =
         "product_rh_phenotype"
         SET reply->status_data.subeventstatus[status_count].targetobjectvalue = concat(
          "Could not insert product_rh_phenotype row due to invalid insert status (",trim(
           gsub_rh_phenotype_status),") for order_id = ",cnvtstring(request->orders[oidx].order_id,32,
           2))
         GO TO exit_script
        ENDIF
        SET new_product_rh_phenotype_id = new_rh_phenotype_id
        SET gsub_rh_phenotype_status = "  "
        CALL get_rh_phenotype_antigens(bb_rh_phenotype_id)
        IF (gsub_rh_phenotype_status != "OK")
         SET failed = "T"
         SET status_count += 1
         IF (status_count > 1)
          SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
         ENDIF
         SET reply->status_data.subeventstatus[status_count].operationname = "SELECT"
         SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
         SET reply->status_data.subeventstatus[status_count].targetobjectname =
         "product_rh_phenotype"
         SET reply->status_data.subeventstatus[status_count].targetobjectvalue = concat(
          "rh_phenotype select failed for nomenclature_id = ",cnvtstring(request->orders[oidx].
           assays[aidx].nomenclature_id,32,2),", for order_id = ",cnvtstring(request->orders[oidx].
           order_id,32,2),".  No results added/updated.")
         GO TO exit_script
        ENDIF
        SET rh_a_cnt = size(rh_a_rec->antigenlist,5)
        FOR (rh_a = 1 TO rh_a_cnt)
          SET gsub_special_testing_status = "  "
          SET new_special_testing_id = 0.0
          CALL add_special_testing(request->orders[oidx].person_id,rh_a_rec->antigenlist[rh_a].
           antigen_cd,1,new_product_rh_phenotype_id,1,
           reqdata->active_status_cd,cnvtdatetime(sysdate),reqinfo->updt_id,"N")
          IF (gsub_special_testing_status="FS")
           SET failed = "T"
           SET status_count += 1
           IF (status_count > 1)
            SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
           ENDIF
           SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
           SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
           SET reply->status_data.subeventstatus[status_count].targetobjectname = "special_testing"
           SET reply->status_data.subeventstatus[status_count].targetobjectvalue = concat(
            "Could not insert special_testing row--get next pathnet_seq for id failed ",
            "for order_id = ",cnvtstring(request->orders[oidx].order_id,32,2))
           GO TO exit_script
          ELSEIF (gsub_special_testing_status="FA")
           SET failed = "T"
           SET status_count += 1
           IF (status_count > 1)
            SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
           ENDIF
           SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
           SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
           SET reply->status_data.subeventstatus[status_count].targetobjectname = "special_testing"
           SET reply->status_data.subeventstatus[status_count].targetobjectvalue = concat(
            "Insert special_testing row failed for order_id = ",cnvtstring(request->orders[oidx].
             order_id,32,2))
           GO TO exit_script
          ELSEIF (gsub_special_testing_status != "OK")
           SET failed = "T"
           SET status_count += 1
           IF (status_count > 1)
            SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
           ENDIF
           SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
           SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
           SET reply->status_data.subeventstatus[status_count].targetobjectname = "special_testing"
           SET reply->status_data.subeventstatus[status_count].targetobjectvalue = concat(
            "Could not insert special_testing row due to invalid insert status (",trim(
             gsub_special_testing_status),") for order_id = ",cnvtstring(request->orders[oidx].
             order_id,32,2))
           GO TO exit_script
          ENDIF
          CALL add_special_testing_result(new_special_testing_id,request->orders[oidx].person_id,
           reply->orders[oidx].assays[aidx].result_id,bb_result_seq,1,
           reqdata->active_status_cd,cnvtdatetime(current->system_dt_tm),request->event_personnel_id)
          IF (gsub_spc_tst_result_status != "OK")
           IF (gsub_spc_tst_result_status="FA")
            SET failed = "T"
            SET status_count += 1
            IF (status_count > 1)
             SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
            ENDIF
            SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
            SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
            SET reply->status_data.subeventstatus[status_count].targetobjectname =
            "Special Testing Result"
            SET reply->status_data.subeventstatus[status_count].targetobjectvalue = concat(
             "Insert special_testing_result row failed for order_id = ",cnvtstring(request->orders[
              oidx].order_id,32,2),", product_id = ",cnvtstring(request->orders[oidx].person_id,32,2)
             )
            SET failed = "T"
            SET status_count += 1
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
              oidx].order_id,32,2),", product_id = ",cnvtstring(request->orders[oidx].person_id,32,2)
             )
           ENDIF
           GO TO exit_script
          ENDIF
        ENDFOR
       ENDIF
      ENDIF
     ENDIF
     IF ((request->review_queue_ind=0))
      SET nbr_of_excepts = request->orders[oidx].assays[aidx].except_cnt
      SET cntr = 0
      IF (nbr_of_excepts > 0)
       FOR (cntr = 1 TO nbr_of_excepts)
         SET exception_status = "I"
         SET bb_exception_id = 0.0
         SET temp_person_id = 0.0
         SET excep_prod_event_id = product_event_id
         SET excep_prod_event_type_cd = re_event_type_cd
         IF ((request->orders[oidx].patient_order_ind=1))
          SET temp_person_id = request->orders[oidx].person_id
          IF (temp_person_id > 0
           AND (request->orders[oidx].assays[aidx].exceptlist[cntr].exception_type_mean="INCXM")
           AND (request->orders[oidx].assays[aidx].crossmatch_verify_yn="N"))
           SELECT INTO "nl:"
            FROM product_event pe
            WHERE (request->orders[oidx].assays[aidx].product_id > 0)
             AND (pe.product_id=request->orders[oidx].assays[aidx].product_id)
             AND pe.person_id=temp_person_id
             AND pe.event_type_cd=crossmatch_cd
             AND pe.active_ind=1
            DETAIL
             excep_prod_event_id = pe.product_event_id
            WITH nocounter
           ;end select
           SET excep_prod_event_type_cd = crossmatch_cd
          ENDIF
         ENDIF
         IF ((request->orders[oidx].assays[aidx].result_status_cd != result_status_corr_in_review_cd)
         )
          CALL add_bb_exception(temp_person_id,request->orders[oidx].order_id,request->
           event_personnel_id,cnvtdatetime(request->event_dt_tm),excep_prod_event_id,
           request->orders[oidx].assays[aidx].exceptlist[cntr].exception_type_mean,request->orders[
           oidx].assays[aidx].exceptlist[cntr].override_reason_cd,excep_prod_event_type_cd,result_seq,
           perf_result_seq,
           request->orders[oidx].assays[aidx].exceptlist[cntr].from_abo_cd,request->orders[oidx].
           assays[aidx].exceptlist[cntr].from_rh_cd,request->orders[oidx].assays[aidx].exceptlist[
           cntr].to_abo_cd,request->orders[oidx].assays[aidx].exceptlist[cntr].to_rh_cd,cnvtdatetime(
            request->orders[oidx].assays[aidx].specimen_expire_dt_tm))
          IF (exception_status="F")
           SET failed = "T"
           SET status_count += 1
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
          SET nbr_of_treqs = request->orders[oidx].assays[aidx].exceptlist[cntr].req_cnt
          IF (nbr_of_treqs > 0)
           SET treq_idx = 0
           FOR (treq_idx = 1 TO nbr_of_treqs)
            CALL add_reqs_exception(request->orders[oidx].assays[aidx].exceptlist[cntr].req_list[
             treq_idx].special_testing_cd,request->orders[oidx].assays[aidx].exceptlist[cntr].
             req_list[treq_idx].requirement_cd)
            IF (exception_status="F")
             SET failed = "T"
             SET status_count += 1
             IF (status_count > 1)
              SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
             ENDIF
             SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
             SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
             SET reply->status_data.subeventstatus[status_count].targetobjectname =
             "BB REQS EXCEPTION"
             SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
             "Unable to ins req except"
             GO TO exit_script
            ENDIF
           ENDFOR
          ENDIF
          SET nbr_of_auto_dirs = 0
          SET nbr_of_auto_dirs = request->orders[oidx].assays[aidx].exceptlist[cntr].auto_dir_cnt
          IF (nbr_of_auto_dirs > 0)
           SET auto_dir_idx = 0
           FOR (auto_dir_idx = 1 TO nbr_of_auto_dirs)
            CALL add_autodir_reqs_exception(request->orders[oidx].assays[aidx].exceptlist[cntr].
             auto_dir_list[auto_dir_idx].product_id)
            IF (exception_status="F")
             SET failed = "T"
             SET status_count += 1
             IF (status_count > 1)
              SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
             ENDIF
             SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
             SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
             SET reply->status_data.subeventstatus[status_count].targetobjectname =
             "bb_autodir_exception"
             SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
             "Unable to ins AUTO DIR except"
             GO TO exit_script
            ENDIF
           ENDFOR
          ENDIF
         ELSE
          CALL add_bb_inactive_exception(temp_person_id,request->orders[oidx].order_id,request->
           event_personnel_id,cnvtdatetime(request->event_dt_tm),excep_prod_event_id,
           request->orders[oidx].assays[aidx].exceptlist[cntr].exception_type_mean,request->orders[
           oidx].assays[aidx].exceptlist[cntr].override_reason_cd,excep_prod_event_type_cd,request->
           orders[oidx].assays[aidx].result_id,perf_result_seq,
           request->orders[oidx].assays[aidx].exceptlist[cntr].from_abo_cd,request->orders[oidx].
           assays[aidx].exceptlist[cntr].from_rh_cd,request->orders[oidx].assays[aidx].exceptlist[
           cntr].to_abo_cd,request->orders[oidx].assays[aidx].exceptlist[cntr].to_rh_cd,cnvtdatetime(
            request->orders[oidx].assays[aidx].specimen_expire_dt_tm))
          IF (exception_status="F")
           SET failed = "T"
           SET status_count += 1
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
           SET status_count += 1
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
         CALL activate_bb_exception(request->orders[oidx].assays[aidx].exceptlist[cntr].exception_id,
          request->orders[oidx].assays[aidx].exceptlist[cntr].updt_cnt)
         IF (exception_status="FL")
          SET failed = "T"
          SET status_count += 1
          IF (status_count > 1)
           SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
          ENDIF
          SET reply->status_data.subeventstatus[status_count].operationname = "Lock"
          SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
          SET reply->status_data.subeventstatus[status_count].targetobjectname = "BB EXCEPTION"
          SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
          "Unable to lock exception"
          GO TO exit_script
         ELSEIF (exception_status="F")
          SET failed = "T"
          SET status_count += 1
          IF (status_count > 1)
           SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
          ENDIF
          SET reply->status_data.subeventstatus[status_count].operationname = "Update"
          SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
          SET reply->status_data.subeventstatus[status_count].targetobjectname = "BB EXCEPTION"
          SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
          "Unable to update exception"
          GO TO exit_script
         ENDIF
       ENDFOR
      ENDIF
     ENDIF
     IF ((request->orders[oidx].assays[aidx].result_status_cd IN (result_status_verified_cd,
     result_status_corrected_cd))
      AND (reply->pn_recovery_ind=1)
      AND (request->orders[oidx].patient_order_ind=1))
      IF (insert_pn_recovery_data(0)=0)
       GO TO exit_script
      ENDIF
     ENDIF
   ENDFOR
   IF (((size(trim(bb_id_nbr)) > 0) OR (xm_reason_cd > 0.0)) )
    IF (update_crossmatch_bbidnbr_or_xm_reason(request->orders[oidx].order_id,bb_id_nbr,xm_reason_cd)
    =0)
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
 FOR (oidx = 1 TO nbr_of_orders)
   SET nbr_of_assays = request->orders[oidx].assays_cnt
   SET stat = alterlist(reply->orders[oidx].assays,nbr_of_assays)
   FOR (aidx = 1 TO nbr_of_assays)
     IF ((request->orders[oidx].assays[aidx].special_testing_verify_yn="Y")
      AND (request->orders[oidx].assays[aidx].bb_result_code_set_cd > 0))
      SET orig_special_testing_id = 0.0
      SET new_special_testing_id = 0.0
      SET gsub_special_testing_status = "  "
      SET gsub_inactive_spcl_tst_status = "  "
      SET gsub_spc_tst_result_status = "  "
      SET gsub_inactive_spc_tst_rsl_status = "  "
      SET sub_product_id = 0.0
      IF ((request->orders[oidx].assays[aidx].product_test_special_test_yn="Y"))
       SET sub_product_id = request->orders[oidx].person_id
      ELSE
       SET sub_product_id = request->orders[oidx].assays[aidx].product_id
      ENDIF
      IF ((request->orders[oidx].assays[aidx].bb_result_id > 0))
       SET bb_result_seq = request->orders[oidx].assays[aidx].bb_result_id
      ELSE
       SET bb_result_seq = 0.0
      ENDIF
      SET opposite_found_ind = 0
      SELECT INTO "nl:"
       st.product_id, st.special_testing_cd, st.active_ind,
       str.result_id, cv.code_value, cv.code_set,
       cv.cdf_meaning, cve.code_set, cve.code_value,
       cve.field_name, cve.field_value
       FROM special_testing st,
        special_testing_result str,
        code_value cv,
        code_value_extension cve
       PLAN (st
        WHERE st.product_id=sub_product_id
         AND st.active_ind=1)
        JOIN (cv
        WHERE cv.code_set=1612
         AND cv.code_value=st.special_testing_cd
         AND ((cv.cdf_meaning="-") OR (cv.cdf_meaning="+")) )
        JOIN (cve
        WHERE cve.code_set=cv.code_set
         AND cve.code_value=cv.code_value
         AND cve.field_name="Opposite")
        JOIN (str
        WHERE (str.special_testing_id= Outerjoin(st.special_testing_id)) )
       HEAD REPORT
        found_ind = 0
       DETAIL
        IF ((cnvtreal(cve.field_value)=request->orders[oidx].assays[aidx].bb_result_code_set_cd))
         IF ((reply->orders[oidx].assays[aidx].result_id != str.result_id))
          found_ind = 1
         ENDIF
        ENDIF
       FOOT REPORT
        opposite_found_ind = found_ind
       WITH nocounter
      ;end select
      IF (opposite_found_ind=1)
       SET reply->opposite_found_product_id = sub_product_id
       SET reply->opposite_found_person_id = request->orders[oidx].person_id
       SET reply->opposite_found_order_id = request->orders[oidx].order_id
       SET reply->opposite_found_assay_id = request->orders[oidx].assays[aidx].task_assay_cd
       SET reply->opposite_found_prfrm_rslt_key = request->orders[oidx].assays[aidx].
       perform_result_key
       SET failed = "T"
       SET reply->status_data.status = "Z"
       SET status_count += 1
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
       CALL add_special_testing(sub_product_id,request->orders[oidx].assays[aidx].
        bb_result_code_set_cd,1,0.0,1,
        reqdata->active_status_cd,cnvtdatetime(current->system_dt_tm),request->event_personnel_id,"Y"
        )
       IF (gsub_special_testing_status != "OK")
        IF (gsub_special_testing_status="FS")
         SET failed = "T"
         SET status_count += 1
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
         SET status_count += 1
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
         SET status_count += 1
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
         SET status_count += 1
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
       CALL add_special_testing_result(new_special_testing_id,sub_product_id,reply->orders[oidx].
        assays[aidx].result_id,bb_result_seq,1,
        reqdata->active_status_cd,cnvtdatetime(current->system_dt_tm),request->event_personnel_id)
       IF (gsub_spc_tst_result_status != "OK")
        IF (gsub_spc_tst_result_status="FA")
         SET failed = "T"
         SET status_count += 1
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
   ENDFOR
 ENDFOR
 SET order_update_complete = "Y"
 SET reply->status_data.status = "S"
 GO TO exit_script
 DECLARE process_updated_result() = i4
 SUBROUTINE process_updated_result(null)
   SET result_seq = request->orders[oidx].assays[aidx].result_id
   IF (update_result(result_seq)=0)
    RETURN(0)
   ENDIF
   SET reply->orders[oidx].assays[aidx].result_id = result_seq
   SET reply->orders[oidx].assays[aidx].result_updt_cnt = (request->orders[oidx].assays[aidx].
   result_updt_cnt+ 1)
   SET perf_result_seq = request->orders[oidx].assays[aidx].perform_result_id
   IF ((request->orders[oidx].assays[aidx].image_cnt > 0))
    IF (insert_images(0)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF (read_perform_result(result_seq,perf_result_seq)=0)
    SET failed = "T"
    SET status_count += 1
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
   IF (curr_result_status_cd=result_status_verified_cd)
    IF (update_perform_result(result_seq,perf_result_seq,result_status_old_verf_cd)=0)
     RETURN(0)
    ENDIF
   ELSEIF (curr_result_status_cd=result_status_corrected_cd)
    IF (update_perform_result(result_seq,perf_result_seq,result_status_old_corr_cd)=0)
     RETURN(0)
    ENDIF
   ELSEIF (curr_result_status_cd=result_status_corr_in_review_cd)
    IF (update_perform_result(result_seq,perf_result_seq,result_status_old_corr_in_rev_cd)=0)
     RETURN(0)
    ENDIF
   ENDIF
   SET parent_perf_result_id = perf_result_seq
   IF (insert_perform_result(result_seq,parent_perf_result_id)=0)
    SET failed = "T"
    SET status_count += 1
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
   SET nbr_of_result_comments = request->orders[oidx].assays[aidx].result_comment_cnt
   IF (nbr_of_result_comments > 0
    AND (request->orders[oidx].assays[aidx].result_status_cd IN (result_status_verified_cd,
   result_status_corr_in_review_cd, result_status_corrected_cd)))
    FOR (rcidx = 1 TO nbr_of_result_comments)
      IF (insert_result_comment(result_seq)=0)
       RETURN(0)
      ENDIF
    ENDFOR
   ENDIF
   IF (insert_result_event(result_seq,perf_result_seq)=0)
    SET failed = "T"
    SET status_count += 1
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
 DECLARE update_result(arg_result_id) = i4
 SUBROUTINE update_result(arg_result_id)
   SET return_value = 0
   SET cur_updt_cnt = 0
   SELECT INTO "nl:"
    r.*
    FROM result r
    WHERE r.result_id=result_seq
    DETAIL
     cur_updt_cnt = r.updt_cnt
    WITH nocounter, forupdate(r)
   ;end select
   IF (curqual=0)
    SET failed = "T"
    SET status_count += 1
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
    SET status_count += 1
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
      request->orders[oidx].assays[aidx].result_status_cd, r.chartable_flag = request->orders[oidx].
      assays[aidx].chartable_flag,
      r.security_level_cd = request->orders[oidx].assays[aidx].security_level_cd, r.repeat_number =
      request->orders[oidx].assays[aidx].repeat_number, r.updt_dt_tm = cnvtdatetime(sysdate),
      r.updt_id = reqinfo->updt_id, r.updt_task = reqinfo->updt_task, r.updt_applctx = reqinfo->
      updt_applctx,
      r.updt_cnt = (r.updt_cnt+ 1)
     PLAN (r
      WHERE r.result_id=arg_result_id
       AND (r.updt_cnt=request->orders[oidx].assays[aidx].result_updt_cnt))
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET failed = "T"
     SET status_count += 1
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
     pr.perform_dt_tm = cnvtdatetime(request->event_dt_tm), pr.result_status_cd = request->orders[
     oidx].assays[aidx].result_status_cd, pr.result_type_cd = request->orders[oidx].assays[aidx].
     result_type_cd,
     pr.nomenclature_id = request->orders[oidx].assays[aidx].nomenclature_id, pr.result_code_set_cd
      =
     IF ((request->orders[oidx].assays[aidx].bb_result_code_set_cd > 0)) request->orders[oidx].
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
     ELSEIF ((request->orders[oidx].assays[aidx].result_type_cd=result_type_date_time_cd))
      cnvtdatetime(request->orders[oidx].assays[aidx].result_value_dt_tm)
     ELSE null
     ENDIF
     , pr.long_text_id = long_text_seq, pr.ascii_text =
     IF ((request->orders[oidx].assays[aidx].ascii_text > " ")) request->orders[oidx].assays[aidx].
      ascii_text
     ELSE null
     ENDIF
     ,
     pr.reference_range_factor_id = request->orders[oidx].assays[aidx].reference_range_factor_id, pr
     .normal_cd = request->orders[oidx].assays[aidx].normal_cd, pr.critical_cd = request->orders[oidx
     ].assays[aidx].critical_cd,
     pr.review_cd = request->orders[oidx].assays[aidx].review_cd, pr.delta_cd = request->orders[oidx]
     .assays[aidx].delta_cd, pr.units_cd = request->orders[oidx].assays[aidx].units_cd,
     pr.notify_cd = request->orders[oidx].assays[aidx].notify_cd, pr.normal_low = request->orders[
     oidx].assays[aidx].normal_low, pr.normal_high = request->orders[oidx].assays[aidx].normal_high,
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
     pr.updt_dt_tm = cnvtdatetime(sysdate), pr.updt_id = reqinfo->updt_id, pr.updt_task = reqinfo->
     updt_task,
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
      request->orders[oidx].assays[aidx].perform_personnel_id, lt.updt_dt_tm = cnvtdatetime(sysdate),
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
 DECLARE insert_images(none) = i4
 SUBROUTINE insert_images(none)
   DECLARE ncnt = i2 WITH protect, noconstant(0)
   DECLARE i = i4 WITH protect, noconstant(0)
   DECLARE lerrorcode = i4 WITH protect, noconstant(0)
   DECLARE serrormessage = vc WITH protect, noconstant(" ")
   SELECT INTO "nl:"
    FROM blob_reference br,
     (dummyt d  WITH seq = value(request->orders[oidx].assays[aidx].image_cnt))
    PLAN (d
     WHERE (request->orders[oidx].assays[aidx].images[d.seq].blob_ref_id > 0.0))
     JOIN (br
     WHERE (br.blob_ref_id=request->orders[oidx].assays[aidx].images[d.seq].blob_ref_id))
    WITH forupdate(br)
   ;end select
   SET lerrorcode = error(serrormessage,0)
   IF (lerrorcode > 0)
    SET reply->status_data.subeventstatus[1].operationname = "lock failed"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "blob_reference"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "locking blob_reference failed"
    RETURN(0)
   ENDIF
   DELETE  FROM blob_reference br,
     (dummyt d  WITH seq = value(request->orders[oidx].assays[aidx].image_cnt))
    SET br.seq = 1
    PLAN (d
     WHERE (request->orders[oidx].assays[aidx].images[d.seq].blob_ref_id > 0.0)
      AND (request->orders[oidx].assays[aidx].images[d.seq].delete_ind=1)
      AND (request->orders[oidx].assays[aidx].result_status_cd IN (result_status_verified_cd)))
     JOIN (br
     WHERE (br.blob_ref_id=request->orders[oidx].assays[aidx].images[d.seq].blob_ref_id)
      AND (br.parent_entity_id=request->orders[oidx].assays[aidx].result_id))
    WITH nocounter
   ;end delete
   SET lerrorcode = error(serrormessage,0)
   IF (lerrorcode > 0)
    SET reply->status_data.subeventstatus[1].operationname = "delete failed"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "blob_reference"
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "deleting from blob_reference failed"
    RETURN(0)
   ENDIF
   UPDATE  FROM blob_reference br,
     (dummyt d  WITH seq = value(request->orders[oidx].assays[aidx].image_cnt))
    SET br.blob_handle = request->orders[oidx].assays[aidx].images[d.seq].blob_handle, br.storage_cd
      = request->orders[oidx].assays[aidx].images[d.seq].storage_cd, br.format_cd = request->orders[
     oidx].assays[aidx].images[d.seq].format_cd,
     br.blob_title = request->orders[oidx].assays[aidx].images[d.seq].blob_title, br.sequence_nbr =
     request->orders[oidx].assays[aidx].images[d.seq].sequence_nbr, br.publish_flag = request->
     orders[oidx].assays[aidx].images[d.seq].publish_flag,
     br.valid_until_dt_tm =
     IF ((request->orders[oidx].assays[aidx].images[d.seq].delete_ind=0)) cnvtdatetime("31-DEC-2100")
     ELSE cnvtdatetime(sysdate)
     ENDIF
     , br.parent_entity_name = "RESULT", br.parent_entity_id = request->orders[oidx].assays[aidx].
     result_id,
     br.updt_dt_tm = cnvtdatetime(sysdate), br.updt_id = reqinfo->updt_id, br.updt_task = reqinfo->
     updt_task,
     br.updt_applctx = reqinfo->updt_applctx, br.updt_cnt = (br.updt_cnt+ 1)
    PLAN (d
     WHERE (request->orders[oidx].assays[aidx].images[d.seq].blob_ref_id > 0.0)
      AND (((request->orders[oidx].assays[aidx].images[d.seq].delete_ind=0)) OR ((request->orders[
     oidx].assays[aidx].images[d.seq].delete_ind=1)
      AND  NOT ((request->orders[oidx].assays[aidx].result_status_cd IN (result_status_verified_cd)))
     )) )
     JOIN (br
     WHERE (br.blob_ref_id=request->orders[oidx].assays[aidx].images[d.seq].blob_ref_id))
    WITH nocounter
   ;end update
   SET lerrorcode = error(serrormessage,0)
   IF (lerrorcode > 0)
    SET reply->status_data.subeventstatus[1].operationname = "update failed"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "blob_reference"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "update of blob_reference failed"
    RETURN(0)
   ENDIF
   RECORD m_dm2_seq_stat(
     1 n_status = i4
     1 s_error_msg = vc
   ) WITH protect
   RECORD new_ids(
     1 qual[*]
       2 id = f8
   )
   RECORD ids(
     1 qual[*]
       2 id = f8
   )
   FOR (i = 1 TO request->orders[oidx].assays[aidx].image_cnt)
     IF ((request->orders[oidx].assays[aidx].images[i].blob_ref_id=0.0))
      SET ncnt += 1
     ENDIF
   ENDFOR
   SET stat = alterlist(ids->qual,request->orders[oidx].assays[aidx].image_cnt)
   EXECUTE dm2_dar_get_bulk_seq "new_ids->qual", ncnt, "id",
   1, "reference_seq"
   SET ncnt = 0
   FOR (i = 1 TO request->orders[oidx].assays[aidx].image_cnt)
     IF ((request->orders[oidx].assays[aidx].images[i].blob_ref_id=0.0))
      SET ncnt += 1
      SET ids->qual[i].id = new_ids->qual[ncnt].id
      SET request->orders[oidx].assays[aidx].images[i].blob_ref_id = ids->qual[i].id
      SET request->orders[oidx].assays[aidx].images[i].valid_from_dt_tm = cnvtdatetime(sysdate)
      SET request->orders[oidx].assays[aidx].images[i].valid_until_dt_tm = cnvtdatetime("31-DEC-2100"
       )
     ENDIF
   ENDFOR
   CALL echorecord(new_ids)
   CALL echorecord(ids)
   INSERT  FROM blob_reference br,
     (dummyt d  WITH seq = value(size(ids->qual,5)))
    SET br.blob_ref_id = request->orders[oidx].assays[aidx].images[d.seq].blob_ref_id, br.blob_handle
      = request->orders[oidx].assays[aidx].images[d.seq].blob_handle, br.storage_cd = request->
     orders[oidx].assays[aidx].images[d.seq].storage_cd,
     br.format_cd = request->orders[oidx].assays[aidx].images[d.seq].format_cd, br.blob_title =
     request->orders[oidx].assays[aidx].images[d.seq].blob_title, br.sequence_nbr = request->orders[
     oidx].assays[aidx].images[d.seq].sequence_nbr,
     br.publish_flag = request->orders[oidx].assays[aidx].images[d.seq].publish_flag, br
     .parent_entity_name = "RESULT", br.parent_entity_id = request->orders[oidx].assays[aidx].
     result_id,
     br.valid_from_dt_tm = cnvtdatetime(request->orders[oidx].assays[aidx].images[d.seq].
      valid_from_dt_tm), br.valid_until_dt_tm = cnvtdatetime(request->orders[oidx].assays[aidx].
      images[d.seq].valid_until_dt_tm), br.updt_dt_tm = cnvtdatetime(sysdate),
     br.updt_id = reqinfo->updt_id, br.updt_task = reqinfo->updt_task, br.updt_applctx = reqinfo->
     updt_applctx,
     br.updt_cnt = 0
    PLAN (d
     WHERE (ids->qual[d.seq].id > 0.0))
     JOIN (br)
    WITH nocounter
   ;end insert
   SET lerrorcode = error(serrormessage,0)
   IF (lerrorcode > 0)
    SET reply->status_data.subeventstatus[1].operationname = "insert failed"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "blob_reference"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "insert into blob_reference failed"
    RETURN(0)
   ENDIF
   SET reply->orders[oidx].assays[aidx].image_cnt = request->orders[oidx].assays[aidx].image_cnt
   SET stat = alterlist(reply->orders[oidx].assays[aidx].images,reply->orders[oidx].assays[aidx].
    image_cnt)
   FOR (i = 1 TO reply->orders[oidx].assays[aidx].image_cnt)
     SET reply->orders[oidx].assays[aidx].images[i].blob_ref_id = request->orders[oidx].assays[aidx].
     images[i].blob_ref_id
     SET reply->orders[oidx].assays[aidx].images[i].blob_handle = request->orders[oidx].assays[aidx].
     images[i].blob_handle
     SET reply->orders[oidx].assays[aidx].images[i].storage_cd = request->orders[oidx].assays[aidx].
     images[i].storage_cd
     SET reply->orders[oidx].assays[aidx].images[i].format_cd = request->orders[oidx].assays[aidx].
     images[i].format_cd
     SET reply->orders[oidx].assays[aidx].images[i].blob_title = request->orders[oidx].assays[aidx].
     images[i].blob_title
     SET reply->orders[oidx].assays[aidx].images[i].sequence_nbr = request->orders[oidx].assays[aidx]
     .images[i].sequence_nbr
     SET reply->orders[oidx].assays[aidx].images[i].publish_flag = request->orders[oidx].assays[aidx]
     .images[i].publish_flag
     SET reply->orders[oidx].assays[aidx].images[i].valid_from_dt_tm = request->orders[oidx].assays[
     aidx].images[i].valid_from_dt_tm
     SET reply->orders[oidx].assays[aidx].images[i].valid_until_dt_tm = request->orders[oidx].assays[
     aidx].images[i].valid_until_dt_tm
     SET reply->orders[oidx].assays[aidx].images[i].delete_ind = request->orders[oidx].assays[aidx].
     images[i].delete_ind
     SET reply->orders[oidx].assays[aidx].images[i].key_value = request->orders[oidx].assays[aidx].
     images[i].key_value
   ENDFOR
   FREE SET m_dm2_seq_stat
   FREE SET new_ids
   FREE SET ids
   RETURN(1)
 END ;Subroutine
 DECLARE update_perform_result(arg_result_id,arg_perf_result_id,arg_result_status_cd) = i4
 SUBROUTINE update_perform_result(arg_result_id,arg_perf_result_id,arg_result_status_cd)
   SET return_value = 0
   SET cur_updt_cnt = 0
   SELECT INTO "nl:"
    r.*
    FROM perform_result r
    WHERE r.perform_result_id=perf_result_seq
    DETAIL
     cur_updt_cnt = r.updt_cnt
    WITH nocounter, forupdate(r)
   ;end select
   IF (curqual=0)
    SET failed = "T"
    SET status_count += 1
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
    SET status_count += 1
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
     SET pr.result_status_cd = arg_result_status_cd, pr.updt_dt_tm = cnvtdatetime(sysdate), pr
      .updt_id = reqinfo->updt_id,
      pr.updt_task = reqinfo->updt_task, pr.updt_applctx = reqinfo->updt_applctx, pr.updt_cnt = (pr
      .updt_cnt+ 1)
     PLAN (pr
      WHERE pr.perform_result_id=arg_perf_result_id
       AND pr.result_id=arg_result_id)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET failed = "T"
     SET status_count += 1
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
 DECLARE insert_result_event(arg_result_id,arg_perf_result_id) = i4
 SUBROUTINE insert_result_event(arg_result_id,arg_perf_result_id)
  INSERT  FROM result_event re
   SET re.result_id = arg_result_id, re.perform_result_id = arg_perf_result_id, re.event_sequence = 1,
    re.event_dt_tm = cnvtdatetime(request->event_dt_tm), re.event_personnel_id = request->
    event_personnel_id, re.event_reason = request->orders[oidx].assays[aidx].result_status_disp,
    re.signature_line_ind = request->orders[oidx].assays[aidx].signature_line_ind, re.called_back_ind
     = request->orders[oidx].assays[aidx].call_back_ind, re.event_type_cd = request->orders[oidx].
    assays[aidx].result_status_cd,
    re.updt_dt_tm = cnvtdatetime(sysdate), re.updt_id = reqinfo->updt_id, re.updt_task = reqinfo->
    updt_task,
    re.updt_applctx = reqinfo->updt_applctx, re.updt_cnt = 0
   PLAN (re)
   WITH nocounter
  ;end insert
  RETURN(curqual)
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
    ORDER BY rc.result_id, rc.action_sequence DESC
    HEAD rc.result_id
     last_action_seq = rc.action_sequence
    WITH nocounter
   ;end select
   INSERT  FROM result_comment rc
    SET rc.result_id = arg_result_id, rc.action_sequence = (last_action_seq+ 1), rc.comment_type_cd
      = request->orders[oidx].assays[aidx].result_comment[rcidx].comment_type_cd,
     rc.long_text_id = long_text_seq, rc.comment_prsnl_id = request->orders[oidx].assays[aidx].
     result_comment[rcidx].comment_prsnl_id, rc.comment_dt_tm = cnvtdatetime(current->system_dt_tm),
     rc.updt_dt_tm = cnvtdatetime(sysdate), rc.updt_id = reqinfo->updt_id, rc.updt_task = reqinfo->
     updt_task,
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
     request->event_personnel_id, lt.updt_dt_tm = cnvtdatetime(sysdate),
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
 DECLARE read_long_data_seq() = i4
 SUBROUTINE read_long_data_seq(null)
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
 DECLARE update_patient_aborh() = i4
 SUBROUTINE update_patient_aborh(null)
   IF ((request->orders[oidx].assays[aidx].upd_pat_hist_aborh_yn="Y"))
    SET pa_rec_cnt = 0
    SET pa_updt_cnt = 0
    SET pa_abo_cd = 0.0
    SET pa_rh_cd = 0.0
    SET pa_person_aborh_id = 0.0
    SELECT
     pa.person_aborh_id
     FROM person_aborh pa
     WHERE (pa.person_id=request->orders[oidx].person_id)
      AND pa.active_ind=1
     DETAIL
      pa_rec_cnt += 1, pa_updt_cnt = pa.updt_cnt, pa_abo_cd = pa.abo_cd,
      pa_rh_cd = pa.rh_cd, pa_person_aborh_id = pa.person_aborh_id
     WITH nocounter
    ;end select
    IF (pa_rec_cnt=0)
     IF ((((request->orders[oidx].assays[aidx].orig_abo_cd > 0)) OR ((((request->orders[oidx].assays[
     aidx].orig_rh_cd > 0)) OR ((((request->orders[oidx].assays[aidx].person_aborh_id > 0)) OR ((
     request->orders[oidx].assays[aidx].person_aborh_updt_cnt > 0))) )) )) )
      SET failed = "T"
      SET status_count += 1
      IF (status_count > 1)
       SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
      ENDIF
      SET reply->status_data.subeventstatus[status_count].operationname = "Update Patient ABORh"
      SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
      SET reply->status_data.subeventstatus[status_count].targetobjectname = "bbt_upd_lab_results"
      SET reply->status_data.subeventstatus[status_count].targetobjectvalue = concat(
       "Cannot update patient ABO/Rh for Accession :",request->orders[oidx].accession,
       ".  Patient ABO/Rh has changed since procedure retrieved.  No active Person_Aborh row.")
      RETURN(0)
     ENDIF
    ELSEIF (pa_rec_cnt=1)
     IF ((((pa_person_aborh_id != request->orders[oidx].assays[aidx].person_aborh_id)) OR ((
     pa_updt_cnt != request->orders[oidx].assays[aidx].person_aborh_updt_cnt))) )
      SET failed = "T"
      SET status_count += 1
      IF (status_count > 1)
       SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
      ENDIF
      SET pat_aborh_upd_conflict_ind = 1
      SET reply->status_data.subeventstatus[status_count].operationname = "Update Patient ABORh"
      SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
      SET reply->status_data.subeventstatus[status_count].targetobjectname = "bbt_upd_lab_results"
      SET reply->status_data.subeventstatus[status_count].targetobjectvalue = concat(
       "Cannot update patient ABO/Rh for Accession :",request->orders[oidx].accession,
       ".  Patient ABO/Rh has changed since procedure retrieved.  Current patient ABO/Rh different",
       " than when procedure retrieved.")
      RETURN(0)
     ENDIF
    ELSEIF (pa_rec_cnt > 1)
     SET failed = "T"
     SET status_count += 1
     IF (status_count > 1)
      SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
     ENDIF
     SET reply->status_data.subeventstatus[status_count].operationname = "Update Patient ABORh"
     SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
     SET reply->status_data.subeventstatus[status_count].targetobjectname = "bbt_upd_lab_results"
     SET reply->status_data.subeventstatus[status_count].targetobjectvalue = concat(
      "Cannot update patient ABO/Rh for Accession :",request->orders[oidx].accession,
      ".  Multiple active Person_Aborh rows.")
     RETURN(0)
    ENDIF
    SET rh_test_only = "N"
    SET abo_test_only = "N"
    SET abo_rh_test = "N"
    SET write_aborh_result = "N"
    IF ((((request->orders[oidx].assays[aidx].new_abo_cd > 0)) OR ((request->orders[oidx].assays[aidx
    ].new_rh_cd > 0))) )
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
      IF ((request->orders[oidx].assays[aidx].new_rh_cd=request->orders[oidx].assays[aidx].orig_rh_cd
      ))
       SET write_aborh_result = "Y"
      ELSE
       SET gsub_person_aborh_status = "  "
       SET gsub_person_aborh_inact_status = " "
       IF ((request->orders[oidx].assays[aidx].orig_rh_cd=0))
        IF ((request->orders[oidx].assays[aidx].orig_abo_cd=0))
         CALL add_person_aborh(request->orders[oidx].person_id,request->orders[oidx].assays[aidx].
          orig_abo_cd,request->orders[oidx].assays[aidx].new_rh_cd,1,reqdata->active_status_cd,
          cnvtdatetime(current->system_dt_tm),request->event_personnel_id,cnvtdatetime(request->
           event_dt_tm))
         IF (gsub_person_aborh_status != "OK")
          RETURN(0)
         ENDIF
         SET write_aborh_result = "Y"
        ELSE
         CALL chg_person_aborh(request->orders[oidx].person_id,request->orders[oidx].assays[aidx].
          orig_abo_cd,request->orders[oidx].assays[aidx].orig_rh_cd,0,reqdata->active_status_cd,
          request->orders[oidx].assays[aidx].person_aborh_updt_cnt,1)
         IF (gsub_person_aborh_inact_status != "OK")
          RETURN(0)
         ENDIF
         CALL add_person_aborh(request->orders[oidx].person_id,request->orders[oidx].assays[aidx].
          orig_abo_cd,request->orders[oidx].assays[aidx].new_rh_cd,1,reqdata->active_status_cd,
          cnvtdatetime(current->system_dt_tm),request->event_personnel_id,cnvtdatetime(request->
           event_dt_tm))
         IF (gsub_person_aborh_status != "OK")
          RETURN(0)
         ENDIF
         SET write_aborh_result = "Y"
        ENDIF
       ELSE
        CALL chg_person_aborh(request->orders[oidx].person_id,request->orders[oidx].assays[aidx].
         orig_abo_cd,request->orders[oidx].assays[aidx].orig_rh_cd,0,reqdata->active_status_cd,
         request->orders[oidx].assays[aidx].person_aborh_updt_cnt,1)
        IF (gsub_person_aborh_inact_status != "OK")
         RETURN(0)
        ENDIF
        CALL add_person_aborh(request->orders[oidx].person_id,request->orders[oidx].assays[aidx].
         orig_abo_cd,request->orders[oidx].assays[aidx].new_rh_cd,1,reqdata->active_status_cd,
         cnvtdatetime(current->system_dt_tm),request->event_personnel_id,cnvtdatetime(request->
          event_dt_tm))
        IF (gsub_person_aborh_status != "OK")
         RETURN(0)
        ENDIF
        SET write_aborh_result = "Y"
       ENDIF
      ENDIF
     ELSEIF (abo_test_only="Y")
      SET gsub_person_aborh_status = "  "
      SET gsub_person_aborh_inact_status = " "
      IF ((request->orders[oidx].assays[aidx].new_abo_cd=request->orders[oidx].assays[aidx].
      orig_abo_cd))
       SET write_aborh_result = "Y"
      ELSE
       IF ((request->orders[oidx].assays[aidx].orig_abo_cd=0))
        IF ((request->orders[oidx].assays[aidx].orig_rh_cd=0))
         CALL add_person_aborh(request->orders[oidx].person_id,request->orders[oidx].assays[aidx].
          new_abo_cd,request->orders[oidx].assays[aidx].orig_rh_cd,1,reqdata->active_status_cd,
          cnvtdatetime(current->system_dt_tm),request->event_personnel_id,cnvtdatetime(request->
           event_dt_tm))
         IF (gsub_person_aborh_status != "OK")
          RETURN(0)
         ENDIF
         SET write_aborh_result = "Y"
        ELSE
         CALL chg_person_aborh(request->orders[oidx].person_id,request->orders[oidx].assays[aidx].
          orig_abo_cd,request->orders[oidx].assays[aidx].orig_rh_cd,0,reqdata->active_status_cd,
          request->orders[oidx].assays[aidx].person_aborh_updt_cnt,1)
         IF (gsub_person_aborh_inact_status != "OK")
          RETURN(0)
         ENDIF
         CALL add_person_aborh(request->orders[oidx].person_id,request->orders[oidx].assays[aidx].
          new_abo_cd,request->orders[oidx].assays[aidx].orig_rh_cd,1,reqdata->active_status_cd,
          cnvtdatetime(current->system_dt_tm),request->event_personnel_id,cnvtdatetime(request->
           event_dt_tm))
         IF (gsub_person_aborh_status != "OK")
          RETURN(0)
         ENDIF
         SET write_aborh_result = "Y"
        ENDIF
       ELSE
        CALL chg_person_aborh(request->orders[oidx].person_id,request->orders[oidx].assays[aidx].
         orig_abo_cd,request->orders[oidx].assays[aidx].orig_rh_cd,0,reqdata->active_status_cd,
         request->orders[oidx].assays[aidx].person_aborh_updt_cnt,1)
        IF (gsub_person_aborh_inact_status != "OK")
         RETURN(0)
        ENDIF
        CALL add_person_aborh(request->orders[oidx].person_id,request->orders[oidx].assays[aidx].
         new_abo_cd,request->orders[oidx].assays[aidx].new_rh_cd,1,reqdata->active_status_cd,
         cnvtdatetime(current->system_dt_tm),request->event_personnel_id,cnvtdatetime(request->
          event_dt_tm))
        IF (gsub_person_aborh_status != "OK")
         RETURN(0)
        ENDIF
        SET write_aborh_result = "Y"
       ENDIF
      ENDIF
     ELSEIF (abo_rh_test="Y")
      SET gsub_person_aborh_status = "  "
      SET gsub_person_aborh_inact_status = " "
      IF ((request->orders[oidx].assays[aidx].orig_abo_cd=0)
       AND (request->orders[oidx].assays[aidx].orig_rh_cd=0))
       SET write_aborh_result = "Y"
       CALL add_person_aborh(request->orders[oidx].person_id,request->orders[oidx].assays[aidx].
        new_abo_cd,request->orders[oidx].assays[aidx].new_rh_cd,1,reqdata->active_status_cd,
        cnvtdatetime(current->system_dt_tm),request->event_personnel_id,cnvtdatetime(request->
         event_dt_tm))
       IF (gsub_person_aborh_status != "OK")
        RETURN(0)
       ENDIF
      ELSE
       IF ((request->orders[oidx].assays[aidx].new_abo_cd=request->orders[oidx].assays[aidx].
       orig_abo_cd))
        IF ((request->orders[oidx].assays[aidx].new_rh_cd=request->orders[oidx].assays[aidx].
        orig_rh_cd))
         SET write_aborh_result = "Y"
        ELSE
         CALL chg_person_aborh(request->orders[oidx].person_id,request->orders[oidx].assays[aidx].
          orig_abo_cd,request->orders[oidx].assays[aidx].orig_rh_cd,0,reqdata->active_status_cd,
          request->orders[oidx].assays[aidx].person_aborh_updt_cnt,1)
         IF (gsub_person_aborh_inact_status != "OK")
          RETURN(0)
         ENDIF
         CALL add_person_aborh(request->orders[oidx].person_id,request->orders[oidx].assays[aidx].
          new_abo_cd,request->orders[oidx].assays[aidx].new_rh_cd,1,reqdata->active_status_cd,
          cnvtdatetime(current->system_dt_tm),request->event_personnel_id,cnvtdatetime(request->
           event_dt_tm))
         IF (gsub_person_aborh_status != "OK")
          RETURN(0)
         ENDIF
         SET write_aborh_result = "Y"
        ENDIF
       ELSE
        CALL chg_person_aborh(request->orders[oidx].person_id,request->orders[oidx].assays[aidx].
         orig_abo_cd,request->orders[oidx].assays[aidx].orig_rh_cd,0,reqdata->active_status_cd,
         request->orders[oidx].assays[aidx].person_aborh_updt_cnt,1)
        IF (gsub_person_aborh_inact_status != "OK")
         RETURN(0)
        ENDIF
        CALL add_person_aborh(request->orders[oidx].person_id,request->orders[oidx].assays[aidx].
         new_abo_cd,request->orders[oidx].assays[aidx].new_rh_cd,1,reqdata->active_status_cd,
         cnvtdatetime(current->system_dt_tm),request->event_personnel_id,cnvtdatetime(request->
          event_dt_tm))
        IF (gsub_person_aborh_status != "OK")
         RETURN(0)
        ENDIF
        SET write_aborh_result = "Y"
       ENDIF
      ENDIF
     ENDIF
    ELSE
     SET write_aborh_result = "Y"
     SELECT
      person_aborh_id
      FROM person_aborh pa
      WHERE (pa.person_aborh_id=request->orders[oidx].assays[aidx].person_aborh_id)
      WITH forupdate(pa)
     ;end select
     IF (curqual=0)
      SET gsub_person_aborh_inact_status = "FU"
      RETURN(0)
     ENDIF
     UPDATE  FROM person_aborh pa
      SET pa.updt_cnt = (pa.updt_cnt+ 1), pa.updt_dt_tm = cnvtdatetime(sysdate), pa.updt_id = reqinfo
       ->updt_id,
       pa.updt_task = reqinfo->updt_task, pa.updt_applctx = reqinfo->updt_applctx, pa
       .last_verified_dt_tm = cnvtdatetime(request->event_dt_tm)
      WHERE (pa.person_aborh_id=request->orders[oidx].assays[aidx].person_aborh_id)
       AND (pa.updt_cnt=request->orders[oidx].assays[aidx].person_aborh_updt_cnt)
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET gsub_person_aborh_inact_status = "FU"
      RETURN(0)
     ENDIF
    ENDIF
   ELSE
    IF ((request->orders[oidx].assays[aidx].upd_pat_hist_aborh_yn="N"))
     SET write_aborh_result = "Y"
    ENDIF
   ENDIF
   SET gsub_inactive_aborh_rsl_status = "  "
   IF (write_aborh_result="Y")
    SET write_aborh_result = "N"
    IF ((request->review_queue_ind=0))
     CALL chg_aborh_result(request->orders[oidx].person_id,request->orders[oidx].encntr_id,reply->
      orders[oidx].assays[aidx].result_id,request->orders[oidx].assays[aidx].orig_result_code_set_cd,
      0,
      reqdata->active_status_cd,request->orders[oidx].assays[aidx].aborh_result_updt_cnt,1)
     IF (gsub_inactive_aborh_rsl_status != "OK")
      RETURN(0)
     ENDIF
    ELSEIF ((request->review_queue_ind=1))
     CALL chg_aborh_result_2(request->orders[oidx].person_id,request->orders[oidx].encntr_id,reply->
      orders[oidx].assays[aidx].result_id,0,reqdata->active_status_cd)
     IF (gsub_inactive_aborh_rsl_status != "OK")
      RETURN(0)
     ENDIF
    ENDIF
    SET gsub_aborh_result_status = "  "
    CALL add_aborh_result(request->orders[oidx].assays[aidx].specimen_id,request->orders[oidx].
     assays[aidx].container_id,request->orders[oidx].assays[aidx].drawn_dt_tm,person_aborh_id,request
     ->orders[oidx].person_id,
     request->orders[oidx].encntr_id,reply->orders[oidx].assays[aidx].result_id,request->orders[oidx]
     .assays[aidx].bb_result_code_set_cd,1,reqdata->active_status_cd,
     cnvtdatetime(current->system_dt_tm),request->event_personnel_id)
    IF (gsub_aborh_result_status != "OK")
     GO TO exit_script
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 DECLARE update_product_aborh() = i4
 SUBROUTINE update_product_aborh(null)
   SET sub_product_id = request->orders[oidx].person_id
   IF ((request->orders[oidx].assays[aidx].upd_blood_product_yn="Y"))
    SET current_updated_ind = 1
    SET product_rh_test_only = "N"
    SET product_abo_test_only = "N"
    SET product_abo_rh_test = "N"
    SET write_result = "N"
    IF ((request->orders[oidx].assays[aidx].product_new_abo_cd=0))
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
      CALL upd_blood_product(sub_product_id,request->orders[oidx].assays[aidx].product_orig_abo_cd,
       request->orders[oidx].assays[aidx].product_new_rh_cd,1,request->orders[oidx].assays[aidx].
       blood_product_updt_cnt,
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
       CALL upd_blood_product(sub_product_id,request->orders[oidx].assays[aidx].product_new_abo_cd,
        request->orders[oidx].assays[aidx].product_orig_rh_cd,1,request->orders[oidx].assays[aidx].
        blood_product_updt_cnt,
        1)
       IF (gsub_blood_product_status != "OK")
        RETURN(0)
       ENDIF
       SET write_result = "Y"
      ELSE
       CALL upd_blood_product(sub_product_id,request->orders[oidx].assays[aidx].product_new_abo_cd,
        request->orders[oidx].assays[aidx].product_new_rh_cd,1,request->orders[oidx].assays[aidx].
        blood_product_updt_cnt,
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
      CALL upd_blood_product(sub_product_id,request->orders[oidx].assays[aidx].product_new_abo_cd,
       request->orders[oidx].assays[aidx].product_new_rh_cd,1,request->orders[oidx].assays[aidx].
       blood_product_updt_cnt,
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
        CALL upd_blood_product(sub_product_id,request->orders[oidx].assays[aidx].product_new_abo_cd,
         request->orders[oidx].assays[aidx].product_new_rh_cd,1,request->orders[oidx].assays[aidx].
         blood_product_updt_cnt,
         1)
        IF (gsub_blood_product_status != "OK")
         RETURN(0)
        ENDIF
        SET write_result = "Y"
       ENDIF
      ELSE
       CALL upd_blood_product(sub_product_id,request->orders[oidx].assays[aidx].product_new_abo_cd,
        request->orders[oidx].assays[aidx].product_new_rh_cd,1,request->orders[oidx].assays[aidx].
        blood_product_updt_cnt,
        1)
       IF (gsub_blood_product_status != "OK")
        RETURN(0)
       ENDIF
       SET write_result = "Y"
      ENDIF
     ENDIF
    ENDIF
   ELSE
    IF ((request->orders[oidx].assays[aidx].upd_blood_product_yn="N"))
     SET write_result = "Y"
     SET current_updated_ind = 0
    ENDIF
   ENDIF
   SET conf_product_event_id = 0.0
   IF ((request->orders[oidx].assays[aidx].upd_product_conf_yn="Y"))
    SET product_event_id = 0.0
    SET re_event_type_cd = confirmed_cd
    SET gsub_product_event_status = "  "
    CALL add_product_event(sub_product_id,0,0,request->orders[oidx].order_id,0,
     confirmed_cd,cnvtdatetime(request->orders[oidx].assays[1].perform_dt_tm),request->
     event_personnel_id,0,
     IF ((request->orders[oidx].assays[aidx].except_cnt > 0)) 1
     ELSE 0
     ENDIF
     ,
     IF ((request->orders[oidx].assays[aidx].except_cnt > 0)) request->orders[oidx].assays[aidx].
      exceptlist[1].override_reason_cd
     ELSE 0
     ENDIF
     ,0,0,reqdata->active_status_cd,cnvtdatetime(current->system_dt_tm),
     request->event_personnel_id)
    SET conf_product_event_id = product_event_id
    IF (gsub_product_event_status="FS")
     SET failed = "T"
     SET status_count += 1
     IF (status_count > 1)
      SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
     ENDIF
     SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
     SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
     SET reply->status_data.subeventstatus[status_count].targetobjectname = "Product Event"
     SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
     "Unable to insert confirmed product event due to product event id"
     RETURN(0)
    ELSEIF (gsub_product_event_status="FA")
     SET failed = "T"
     SET status_count += 1
     IF (status_count > 1)
      SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
     ENDIF
     SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
     SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
     SET reply->status_data.subeventstatus[status_count].targetobjectname = "Product Event"
     SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
     "Unable to insert confirmed product event"
     RETURN(0)
    ENDIF
   ENDIF
   IF ((request->orders[oidx].assays[aidx].upd_product_unconf_yn="Y"))
    IF (update_in_progress(0,0)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((request->orders[oidx].assays[aidx].inact_product_avail_yn="Y"))
    IF (update_in_progress(0,0)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((request->orders[oidx].assays[aidx].upd_product_avail_yn="Y"))
    SET product_event_id = 0.0
    SET re_event_type_cd = available_cd
    SET gsub_product_event_status = "  "
    CALL add_product_event(sub_product_id,0,0,0,0,
     available_cd,cnvtdatetime(request->orders[oidx].assays[1].perform_dt_tm),request->
     event_personnel_id,0,0,
     0,0,1,reqdata->active_status_cd,cnvtdatetime(current->system_dt_tm),
     request->event_personnel_id)
    IF (gsub_product_event_status="FS")
     SET failed = "T"
     SET status_count += 1
     IF (status_count > 1)
      SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
     ENDIF
     SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
     SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
     SET reply->status_data.subeventstatus[status_count].targetobjectname = "Product Event"
     SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
     "Unable to insert available product event due to product event id"
     RETURN(0)
    ELSEIF (gsub_product_event_status="FA")
     SET failed = "T"
     SET status_count += 1
     IF (status_count > 1)
      SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
     ENDIF
     SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
     SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
     SET reply->status_data.subeventstatus[status_count].targetobjectname = "Product Event"
     SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
     "Unable to insert available product event"
     RETURN(0)
    ENDIF
   ENDIF
   IF ((request->orders[oidx].assays[aidx].add_product_unconf_yn="Y"))
    SET product_event_id = 0.0
    SET re_event_type_cd = unconfirmed_cd
    SET gsub_product_event_status = "  "
    CALL add_product_event(sub_product_id,0,0,0,0,
     unconfirmed_cd,cnvtdatetime(request->orders[oidx].assays[1].perform_dt_tm),request->
     event_personnel_id,0,0,
     0,0,1,reqdata->active_status_cd,cnvtdatetime(current->system_dt_tm),
     request->event_personnel_id)
    IF (gsub_product_event_status="FS")
     SET failed = "T"
     SET status_count += 1
     IF (status_count > 1)
      SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
     ENDIF
     SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
     SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
     SET reply->status_data.subeventstatus[status_count].targetobjectname = "Product Event"
     SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
     "Unable to insert unconfirmed product event due to product event id"
     RETURN(0)
    ELSEIF (gsub_product_event_status="FA")
     SET failed = "T"
     SET status_count += 1
     IF (status_count > 1)
      SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
     ENDIF
     SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
     SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
     SET reply->status_data.subeventstatus[status_count].targetobjectname = "Product Event"
     SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
     "Unable to insert unconfirmed product event"
     RETURN(0)
    ENDIF
   ENDIF
   SET gsub_abo_testing_status = "  "
   SET product_event_id = conf_product_event_id
   IF (write_result="Y")
    SET write_result = "N"
    IF (inactivate_abo_testing(0)=0)
     GO TO exit_script
    ENDIF
    CALL add_abo_testing(sub_product_id,reply->orders[oidx].assays[aidx].result_id,request->orders[
     oidx].assays[aidx].product_new_abo_cd,request->orders[oidx].assays[aidx].product_new_rh_cd,
     conf_product_event_id,
     current_updated_ind,1,reqdata->active_status_cd,cnvtdatetime(current->system_dt_tm),request->
     event_personnel_id)
    IF (gsub_abo_testing_status != "OK")
     IF (gsub_abo_testing_status="FA")
      SET failed = "T"
      SET status_count += 1
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
      SET status_count += 1
      IF (status_count > 1)
       SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
      ENDIF
      SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
      SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
      SET reply->status_data.subeventstatus[status_count].targetobjectname = "Ab Testing"
      SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
      "Unable to insert aborh result due to next sequence number"
     ENDIF
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (update_available(dproductid=f8) =i4)
   SET return_value = 0
   SET dprod_event_id = 0.0
   SELECT INTO "nl:"
    p.*
    FROM product_event p
    WHERE p.product_id=dproductid
     AND p.event_type_cd=available_cd
     AND p.active_ind=1
    DETAIL
     dprod_event_id = p.product_event_id
    WITH nocounter, forupdate(p)
   ;end select
   IF (curqual=0)
    SET return_value = 1
   ELSE
    UPDATE  FROM product_event pe
     SET pe.active_ind = 0, pe.active_status_cd = reqdata->active_status_cd, pe.updt_cnt = (pe
      .updt_cnt+ 1),
      pe.updt_dt_tm = cnvtdatetime(sysdate), pe.updt_id = reqinfo->updt_id, pe.updt_task = reqinfo->
      updt_task,
      pe.updt_applctx = reqinfo->updt_applctx
     WHERE pe.product_event_id=dprod_event_id
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET failed = "T"
     SET status_count += 1
     IF (status_count > 1)
      SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
     ENDIF
     SET reply->status_data.subeventstatus[status_count].operationname = "CHANGE"
     SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
     SET reply->status_data.subeventstatus[status_count].targetobjectname = "Product Event"
     SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
     "Unable to update available product event"
     SET return_value = 0
    ELSE
     SET return_value = 1
    ENDIF
   ENDIF
   RETURN(return_value)
 END ;Subroutine
 DECLARE inactivate_abo_testing() = i4
 SUBROUTINE inactivate_abo_testing(null)
   SET return_value = 0
   SET cur_updt_cnt = 0
   SELECT INTO "nl:"
    at.product_id
    FROM abo_testing at
    WHERE at.product_id=sub_product_id
     AND (at.result_id=reply->orders[oidx].assays[aidx].result_id)
     AND at.active_ind=1
    DETAIL
     cur_updt_cnt = at.updt_cnt
    WITH nocounter, forupdate(at)
   ;end select
   IF (curqual=0)
    SET failed = "T"
    SET status_count += 1
    IF (status_count > 1)
     SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
    ENDIF
    SET reply->status_data.subeventstatus[status_count].operationname = "CHANGE"
    SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
    SET reply->status_data.subeventstatus[status_count].targetobjectname = "Abo Testing"
    SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
    "Unable to lock abo testing"
    SET return_value = 0
   ELSEIF ((cur_updt_cnt != request->orders[oidx].assays[aidx].abo_testing_upd_cnt))
    SET failed = "T"
    SET status_count += 1
    IF (status_count > 1)
     SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
    ENDIF
    SET reply->status_data.subeventstatus[status_count].operationname = "CHANGE"
    SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
    SET reply->status_data.subeventstatus[status_count].targetobjectname = "Abo Testing"
    SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
    "Update conflict on abo testing"
    SET return_value = 0
   ELSE
    UPDATE  FROM abo_testing at
     SET at.active_ind = 0, at.active_status_cd = reqdata->active_status_cd, at.updt_cnt = (at
      .updt_cnt+ 1),
      at.updt_dt_tm = cnvtdatetime(sysdate), at.updt_id = reqinfo->updt_id, at.updt_task = reqinfo->
      updt_task,
      at.updt_applctx = reqinfo->updt_applctx
     WHERE at.product_id=sub_product_id
      AND (at.result_id=reply->orders[oidx].assays[aidx].result_id)
      AND at.active_ind=1
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET failed = "T"
     SET status_count += 1
     IF (status_count > 1)
      SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
     ENDIF
     SET reply->status_data.subeventstatus[status_count].operationname = "CHANGE"
     SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
     SET reply->status_data.subeventstatus[status_count].targetobjectname = "Abo Testing"
     SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
     "Unable to update abo testing"
     SET return_value = 0
    ELSE
     SET return_value = 1
    ENDIF
   ENDIF
   RETURN(return_value)
 END ;Subroutine
 DECLARE update_crossmatch() = i4
 SUBROUTINE update_crossmatch(null)
   SET hold_product_id = request->orders[oidx].assays[aidx].product_id
   IF ((request->orders[oidx].assays[aidx].crossmatch_verify_yn="Y"))
    IF ((request->orders[oidx].assays[aidx].update_to_xm_yn="Y"))
     IF (update_available(hold_product_id)=0)
      RETURN(0)
     ENDIF
     SET product_event_id = 0.0
     SET re_event_type_cd = crossmatch_cd
     IF ((request->orders[oidx].assays[aidx].xm_inactive_ind=0))
      SET xm_active_ind = 1
      SET xm_active_cd = reqdata->active_status_cd
     ELSE
      SET xm_active_ind = 0
      SET xm_active_cd = reqdata->inactive_status_cd
     ENDIF
     SET gsub_product_event_status = "  "
     CALL add_product_event(request->orders[oidx].assays[aidx].product_id,request->orders[oidx].
      person_id,request->orders[oidx].encntr_id,request->orders[oidx].order_id,bb_result_seq,
      crossmatch_cd,cnvtdatetime(request->orders[oidx].assays[1].perform_dt_tm),request->
      event_personnel_id,0,
      IF ((request->orders[oidx].assays[aidx].except_cnt > 0)) 1
      ELSE 0
      ENDIF
      ,
      IF ((request->orders[oidx].assays[aidx].except_cnt > 0)) request->orders[oidx].assays[aidx].
       exceptlist[1].override_reason_cd
      ELSE 0
      ENDIF
      ,0,xm_active_ind,xm_active_cd,cnvtdatetime(current->system_dt_tm),
      request->event_personnel_id)
     IF (gsub_product_event_status="FS")
      SET failed = "T"
      SET status_count += 1
      IF (status_count > 1)
       SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
      ENDIF
      SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
      SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
      SET reply->status_data.subeventstatus[status_count].targetobjectname = "Product Event"
      SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
      "Unable to insert product event due to product event id"
      RETURN(0)
     ELSEIF (gsub_product_event_status="FA")
      SET failed = "T"
      SET status_count += 1
      IF (status_count > 1)
       SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
      ENDIF
      SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
      SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
      SET reply->status_data.subeventstatus[status_count].targetobjectname = "Product Event"
      SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
      "Unable to insert product event"
      RETURN(0)
     ENDIF
     SET reply->orders[oidx].assays[aidx].xm_prod_event_id = product_event_id
     IF (insert_crossmatch(product_event_id,xm_active_ind,xm_active_cd)=0)
      SET failed = "T"
      SET status_count += 1
      IF (status_count > 1)
       SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
      ENDIF
      SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
      SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
      SET reply->status_data.subeventstatus[status_count].targetobjectname = "Crossmatch"
      SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
      "Unable to insert crossmatch"
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (update_crossmatch_bbidnbr_or_xm_reason(sub_ucb_order_id=f8,sub_ucb_bb_id_nbr=vc,
  sub_ucb_xm_reason_cd=f8) =i4)
   SET pe_xm_cnt = 0
   SET stat = alterlist(pe_xm_rec->pe_xm,0)
   SET select_ok_ind = 0
   SELECT INTO "nl:"
    pe.product_event_id
    FROM product_event pe,
     crossmatch xm
    PLAN (pe
     WHERE pe.order_id=sub_ucb_order_id
      AND pe.order_id > 0
      AND pe.order_id != null
      AND pe.product_event_id > 0
      AND pe.product_event_id != null)
     JOIN (xm
     WHERE xm.product_event_id=pe.product_event_id)
    HEAD REPORT
     select_ok_ind = 0
    DETAIL
     pe_xm_cnt += 1, stat = alterlist(pe_xm_rec->pe_xm,pe_xm_cnt), pe_xm_rec->pe_xm[pe_xm_cnt].
     product_event_id = pe.product_event_id
    FOOT REPORT
     select_ok_ind = 1
    WITH nocounter, forupdate(xm), nullreport
   ;end select
   IF (select_ok_ind=1)
    IF (pe_xm_cnt > 0)
     UPDATE  FROM crossmatch xm,
       (dummyt d_xm  WITH seq = value(pe_xm_cnt))
      SET xm.bb_id_nbr =
       IF (size(trim(sub_ucb_bb_id_nbr))=0) xm.bb_id_nbr
       ELSE sub_ucb_bb_id_nbr
       ENDIF
       , xm.xm_reason_cd =
       IF (sub_ucb_xm_reason_cd=0.0) xm.xm_reason_cd
       ELSE sub_ucb_xm_reason_cd
       ENDIF
       , xm.updt_cnt = (xm.updt_cnt+ 1),
       xm.updt_dt_tm = cnvtdatetime(sysdate), xm.updt_id = reqinfo->updt_id, xm.updt_task = reqinfo->
       updt_task,
       xm.updt_applctx = reqinfo->updt_applctx
      PLAN (d_xm)
       JOIN (xm
       WHERE (xm.product_event_id=pe_xm_rec->pe_xm[d_xm.seq].product_event_id))
      WITH nocounter, status(pe_xm_rec->pe_xm[d_xm.seq].status)
     ;end update
     IF (curqual > 0)
      FOR (pe_xm = 1 TO pe_xm_cnt)
        IF ((pe_xm_rec->pe_xm[pe_xm].status != 1))
         SET failed = "T"
         SET status_count += 1
         IF (status_count > 1)
          SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
         ENDIF
         SET reply->status_data.subeventstatus[status_count].operationname = "UPDATE CROSSMATCH"
         SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
         SET reply->status_data.subeventstatus[status_count].targetobjectname = "CROSSMATCH"
         SET reply->status_data.subeventstatus[status_count].targetobjectvalue = concat(
          "Unable to update CROSSMATCH row for Bb_Id_Nbr and Reason for Crossmatch","Order_id = ",
          cnvtstring(sub_ucb_order_id,32,2),".  Product_Event_Id = ",cnvtstring(pe_xm_rex->pe_xm[
           pe_xm].product_event_id,32,2))
         RETURN(0)
        ENDIF
      ENDFOR
      RETURN(1)
     ELSE
      SET failed = "T"
      SET status_count += 1
      IF (status_count > 1)
       SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
      ENDIF
      SET reply->status_data.subeventstatus[status_count].operationname = "UPDATE CROSSMATCH"
      SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
      SET reply->status_data.subeventstatus[status_count].targetobjectname = "CROSSMATCH"
      SET reply->status_data.subeventstatus[status_count].targetobjectvalue = concat(
       "Unable to update CROSSMATCH row for Bb_Id_Nbr and Reason for Crossmatch ","Order_id = ",
       cnvtstring(sub_ucb_order_id,32,2))
      RETURN(0)
     ENDIF
    ELSE
     RETURN(1)
    ENDIF
   ELSE
    SET failed = "T"
    SET status_count += 1
    IF (status_count > 1)
     SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
    ENDIF
    SET reply->status_data.subeventstatus[status_count].operationname = "SELECT PRODUCT_EVENT"
    SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
    SET reply->status_data.subeventstatus[status_count].targetobjectname = "PRODUCT_EVENT"
    SET reply->status_data.subeventstatus[status_count].targetobjectvalue = concat(
     "Script Error:PRODUCT_EVENT select for crossmatches encountered errors","Order_id = ",cnvtstring
     (sub_ucb_order_id,32,2))
    RETURN(0)
   ENDIF
 END ;Subroutine
 DECLARE update_in_progress(arg_bb_result_id,arg_active_ind) = i4
 SUBROUTINE update_in_progress(arg_bb_result_id,arg_active_ind)
   SET return_value = 0
   SET cur_updt_cnt = 0
   SELECT INTO "nl:"
    p.*
    FROM product_event p
    WHERE (p.product_event_id=request->orders[oidx].assays[aidx].inprogress_prod_event_id)
    DETAIL
     cur_updt_cnt = p.updt_cnt
    WITH nocounter, forupdate(p)
   ;end select
   IF (curqual=0)
    SET failed = "T"
    SET status_count += 1
    IF (status_count > 1)
     SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
    ENDIF
    SET reply->status_data.subeventstatus[status_count].operationname = "CHANGE"
    SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
    SET reply->status_data.subeventstatus[status_count].targetobjectname = "Product Event"
    SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
    "Unable to lock product event"
    SET return_value = 0
   ELSEIF ((cur_updt_cnt != request->orders[oidx].assays[aidx].prod_state_updt_cnt))
    SET failed = "T"
    SET status_count += 1
    IF (status_count > 1)
     SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
    ENDIF
    SET reply->status_data.subeventstatus[status_count].operationname = "CHANGE"
    SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
    SET reply->status_data.subeventstatus[status_count].targetobjectname = "Product Event"
    IF ((request->orders[oidx].assays[aidx].upd_product_unconf_yn="Y"))
     SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
     "Update conflict on product event for unconfirmed"
    ELSEIF ((request->orders[oidx].assays[aidx].inact_product_avail_yn="Y"))
     SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
     "Update conflict on product event for available"
    ELSE
     SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
     "Update conflict on product event for inprogress"
    ENDIF
    SET return_value = 0
   ELSE
    UPDATE  FROM product_event pe
     SET pe.bb_result_id = arg_bb_result_id, pe.active_ind = arg_active_ind, pe.active_status_cd =
      reqdata->active_status_cd,
      pe.updt_cnt = (pe.updt_cnt+ 1), pe.updt_dt_tm = cnvtdatetime(sysdate), pe.updt_id = reqinfo->
      updt_id,
      pe.updt_task = reqinfo->updt_task, pe.updt_applctx = reqinfo->updt_applctx, pe.event_tz =
      IF (curutc=1
       AND arg_active_ind=1) curtimezoneapp
      ELSE 0
      ENDIF
     WHERE (pe.product_event_id=request->orders[oidx].assays[aidx].inprogress_prod_event_id)
      AND (pe.updt_cnt=request->orders[oidx].assays[aidx].prod_state_updt_cnt)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET failed = "T"
     SET status_count += 1
     IF (status_count > 1)
      SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
     ENDIF
     SET reply->status_data.subeventstatus[status_count].operationname = "CHANGE"
     SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
     SET reply->status_data.subeventstatus[status_count].targetobjectname = "Product Event"
     SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
     "Unable to update product event"
     SET return_value = 0
    ELSE
     SET return_value = 1
    ENDIF
   ENDIF
   RETURN(return_value)
 END ;Subroutine
 SUBROUTINE (insert_crossmatch(arg_product_event_id=f8,arg_xm_active_ind=i2,arg_xm_status_cd=f8) =i4)
  INSERT  FROM crossmatch c
   SET c.product_event_id = arg_product_event_id, c.product_id = request->orders[oidx].assays[aidx].
    product_id, c.person_id = request->orders[oidx].person_id,
    c.crossmatch_qty = 0, c.release_dt_tm = null, c.release_prsnl_id = 0,
    c.release_reason_cd = 0, c.release_qty = 0, c.crossmatch_exp_dt_tm = cnvtdatetime(request->
     orders[oidx].assays[aidx].crossmatch_expire_dt_tm),
    c.bb_id_nbr = request->orders[oidx].assays[aidx].bb_id_nbr, c.reinstate_reason_cd = 0, c
    .xm_reason_cd = request->orders[oidx].assays[aidx].xm_reason_cd,
    c.active_ind = arg_xm_active_ind, c.active_status_cd = arg_xm_status_cd, c.active_status_dt_tm =
    cnvtdatetime(current->system_dt_tm),
    c.active_status_prsnl_id = request->event_personnel_id, c.updt_dt_tm = cnvtdatetime(sysdate), c
    .updt_id = reqinfo->updt_id,
    c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt = 0
   PLAN (c)
   WITH nocounter
  ;end insert
  RETURN(curqual)
 END ;Subroutine
 DECLARE insert_pn_recovery_data() = i4
 SUBROUTINE insert_pn_recovery_data(null)
   DECLARE sub_pn_recovery_child_id = f8 WITH public, noconstant(0.0)
   DECLARE sub_pn_recovery_detail_id = f8 WITH public, noconstant(0.0)
   DECLARE pn_dtl_cnt = i4 WITH public, noconstant(0)
   DECLARE detail_parent_entity_name = vc WITH public, noconstant("")
   DECLARE detail_parent_entity_id = f8 WITH public, noconstant(0.0)
   DECLARE sub_detail_mean = vc WITH public, noconstant("")
   DECLARE sub_detail_value = i4 WITH public, noconstant(0)
   DECLARE sub_detail_desc = vc WITH public, noconstant("")
   IF ((reply->orders[oidx].pn_recovery_id=0.0))
    SELECT INTO "nl:"
     next_seq_nbr = seq(pathnet_recovery_seq,nextval)
     FROM dual
     DETAIL
      reply->orders[oidx].pn_recovery_id = next_seq_nbr
     WITH nocounter
    ;end select
    IF ((reply->orders[oidx].pn_recovery_id=0.0))
     RETURN(0)
    ENDIF
    INSERT  FROM pn_recovery pr
     SET pr.pn_recovery_id = reply->orders[oidx].pn_recovery_id, pr.parent_entity_name = "ORDERS", pr
      .parent_entity_id = reply->orders[oidx].order_id,
      pr.recovery_type_cd = pn_recovery_type_cd, pr.in_process_flag = 0, pr.expire_dt_tm =
      cnvtdatetime(sysdate),
      pr.failure_cnt = 0, pr.first_failure_dt_tm = null, pr.last_failure_dt_tm = null,
      pr.updt_dt_tm = cnvtdatetime(sysdate), pr.updt_id = reqinfo->updt_id, pr.updt_task = reqinfo->
      updt_task,
      pr.updt_applctx = reqinfo->updt_applctx, pr.updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET reply->status_data.subeventstatus[1].operationname = "INSERT"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "PN_RECOVERY TABLE"
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Unable to insert pn_recovery record"
     RETURN(0)
    ENDIF
    FOR (pn_dtl_cnt = 1 TO 3)
      SELECT INTO "nl:"
       next_seq_nbr = seq(pathnet_recovery_seq,nextval)
       FROM dual
       DETAIL
        sub_pn_recovery_detail_id = next_seq_nbr
       WITH nocounter
      ;end select
      IF (sub_pn_recovery_detail_id=0)
       RETURN(0)
      ENDIF
      CASE (pn_dtl_cnt)
       OF 1:
        SET sub_detail_mean = "EVENT_DT_TM"
        SET detail_parent_entity_name = "PN_RECOVERY"
        SET detail_parent_entity_id = reply->orders[oidx].pn_recovery_id
        IF (curutc=1)
         SET sub_detail_value = curtimezoneapp
        ELSE
         SET sub_detail_value = 0
        ENDIF
       OF 2:
        SET sub_detail_mean = "COMPLETE_IND"
        SET detail_parent_entity_name = "PN_RECOVERY"
        SET detail_parent_entity_id = reply->orders[oidx].pn_recovery_id
        SET sub_detail_value = request->orders[oidx].complete_ind
       OF 3:
        SET sub_detail_mean = "DO_NOT_CHART"
        SET detail_parent_entity_name = "PN_RECOVERY"
        SET detail_parent_entity_id = reply->orders[oidx].pn_recovery_id
        SET sub_detail_value = 0
      ENDCASE
      INSERT  FROM pn_recovery_detail prd
       SET prd.pn_recovery_detail_id = sub_pn_recovery_detail_id, prd.parent_entity_name =
        detail_parent_entity_name, prd.parent_entity_id = detail_parent_entity_id,
        prd.detail_mean = sub_detail_mean, prd.detail_dt_tm = cnvtdatetime(reply->event_dt_tm), prd
        .detail_value = sub_detail_value,
        prd.updt_dt_tm = cnvtdatetime(sysdate), prd.updt_id = reqinfo->updt_id, prd.updt_task =
        reqinfo->updt_task,
        prd.updt_applctx = reqinfo->updt_applctx, prd.updt_cnt = 0
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET reply->status_data.subeventstatus[1].operationname = "INSERT"
       SET reply->status_data.subeventstatus[1].operationstatus = "F"
       SET reply->status_data.subeventstatus[1].targetobjectname = "PN_RECOVERY_DETAIL TABLE"
       SET reply->status_data.subeventstatus[1].targetobjectvalue =
       "Unable to insert pn_recovery_detail record"
       RETURN(0)
      ENDIF
    ENDFOR
   ENDIF
   SELECT INTO "nl:"
    next_seq_nbr = seq(pathnet_recovery_seq,nextval)
    FROM dual
    DETAIL
     sub_pn_recovery_child_id = next_seq_nbr
    WITH nocounter
   ;end select
   IF (sub_pn_recovery_child_id=0)
    RETURN(0)
   ENDIF
   INSERT  FROM pn_recovery_child prc
    SET prc.pn_recovery_id = reply->orders[oidx].pn_recovery_id, prc.pn_recovery_child_id =
     sub_pn_recovery_child_id, prc.child_entity_name = "PERFORM_RESULT",
     prc.child_entity_id = reply->orders[oidx].assays[aidx].perform_result_id, prc.updt_dt_tm =
     cnvtdatetime(sysdate), prc.updt_id = reqinfo->updt_id,
     prc.updt_task = reqinfo->updt_task, prc.updt_applctx = reqinfo->updt_applctx, prc.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "PN_RECOVERY_CHILD TABLE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Unable to insert pn_recovery_child record"
    RETURN(0)
   ENDIF
   FOR (pn_dtl_cnt = 1 TO 8)
     SELECT INTO "nl:"
      next_seq_nbr = seq(pathnet_recovery_seq,nextval)
      FROM dual
      DETAIL
       sub_pn_recovery_detail_id = next_seq_nbr
      WITH nocounter
     ;end select
     IF (sub_pn_recovery_detail_id=0)
      RETURN(0)
     ENDIF
     CASE (pn_dtl_cnt)
      OF 1:
       SET sub_detail_mean = "EVENT_SEQUENCE"
       SET detail_parent_entity_name = "PN_RECOVERY_CHILD"
       SET detail_parent_entity_id = sub_pn_recovery_child_id
       SET sub_detail_value = 1
       SET sub_detail_desc = ""
      OF 2:
       SET sub_detail_mean = "MAX_DIGITS"
       SET detail_parent_entity_name = "PN_RECOVERY_CHILD"
       SET detail_parent_entity_id = sub_pn_recovery_child_id
       SET sub_detail_value = request->orders[oidx].assays[aidx].max_digits
       SET sub_detail_desc = ""
      OF 3:
       SET sub_detail_mean = "MIN_DIGITS"
       SET detail_parent_entity_name = "PN_RECOVERY_CHILD"
       SET detail_parent_entity_id = sub_pn_recovery_child_id
       SET sub_detail_value = request->orders[oidx].assays[aidx].min_digits
       SET sub_detail_desc = ""
      OF 4:
       SET sub_detail_mean = "MIN_DEC_PLACES"
       SET detail_parent_entity_name = "PN_RECOVERY_CHILD"
       SET detail_parent_entity_id = sub_pn_recovery_child_id
       SET sub_detail_value = request->orders[oidx].assays[aidx].min_decimal_places
       SET sub_detail_desc = ""
      OF 5:
       SET sub_detail_mean = "ANTIBODY_VERIFY"
       SET detail_parent_entity_name = "PN_RECOVERY_CHILD"
       SET detail_parent_entity_id = sub_pn_recovery_child_id
       SET sub_detail_value = 0
       SET sub_detail_desc = request->orders[oidx].assays[aidx].antibody_verify_yn
      OF 6:
       SET sub_detail_mean = "ANTIGEN_VERIFY"
       SET detail_parent_entity_name = "PN_RECOVERY_CHILD"
       SET detail_parent_entity_id = sub_pn_recovery_child_id
       SET sub_detail_value = 0
       SET sub_detail_desc = request->orders[oidx].assays[aidx].antigen_verify_yn
      OF 7:
       SET sub_detail_mean = "SPEC_TESTING_VERIFY"
       SET detail_parent_entity_name = "PN_RECOVERY_CHILD"
       SET detail_parent_entity_id = sub_pn_recovery_child_id
       SET sub_detail_value = 0
       SET sub_detail_desc = request->orders[oidx].assays[aidx].special_testing_verify_yn
      OF 8:
       SET sub_detail_mean = "PRODUCT_ID"
       SET detail_parent_entity_name = "PN_RECOVERY_CHILD"
       SET detail_parent_entity_id = sub_pn_recovery_child_id
       SET sub_detail_value = request->orders[oidx].assays[aidx].product_id
       SET sub_detail_desc = ""
     ENDCASE
     INSERT  FROM pn_recovery_detail prd
      SET prd.pn_recovery_detail_id = sub_pn_recovery_detail_id, prd.parent_entity_name =
       detail_parent_entity_name, prd.parent_entity_id = detail_parent_entity_id,
       prd.detail_mean = sub_detail_mean, prd.detail_value = sub_detail_value, prd.detail_desc =
       sub_detail_desc,
       prd.updt_dt_tm = cnvtdatetime(sysdate), prd.updt_id = reqinfo->updt_id, prd.updt_task =
       reqinfo->updt_task,
       prd.updt_applctx = reqinfo->updt_applctx, prd.updt_cnt = 0
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET reply->status_data.subeventstatus[1].operationname = "INSERT"
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectname = "PN_RECOVERY_DETAIL TABLE"
      SET reply->status_data.subeventstatus[1].targetobjectvalue =
      "Unable to insert pn_recovery_detail record"
      RETURN(0)
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (execute_maintain_review_items(none=i2) =i2)
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
#exit_script
 IF (oidx > 0)
  IF (order_update_complete != "Y")
   SET reply->err_accession = uar_fmt_accession(request->orders[oidx].accession,size(request->orders[
     oidx].accession,1))
   SET reply->err_catalog_cd = request->orders[oidx].catalog_cd
   SET reply->err_patient_order_ind = request->orders[oidx].patient_order_ind
   SET reply->err_person_product_id = request->orders[oidx].person_id
   IF (aidx > 0)
    IF ((request->orders[oidx].assays[aidx].upd_pat_hist_aborh_yn="Y"))
     SET reply->err_pat_aborh_upd_conflict_ind = pat_aborh_upd_conflict_ind
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 SET max_assay_cnt = 0
 SELECT INTO "nl:"
  d.seq
  FROM (dummyt d  WITH seq = value(nbr_of_orders))
  HEAD REPORT
   max_assay_cnt = 0
  DETAIL
   IF ((request->orders[d.seq].assays_cnt > max_assay_cnt))
    max_assay_cnt = request->orders[d.seq].assays_cnt
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  d_o.seq, d_a.seq
  FROM (dummyt d_o  WITH seq = value(nbr_of_orders)),
   (dummyt d_a  WITH seq = value(max_assay_cnt))
  PLAN (d_o)
   JOIN (d_a
   WHERE (d_a.seq <= request->orders[d_o.seq].assays_cnt))
  DETAIL
   IF ((request->orders[d_o.seq].assays[d_a.seq].upd_pat_hist_aborh_yn="Y"))
    reply->err_pat_aborh_ind = 1
   ELSEIF ((request->orders[d_o.seq].assays[d_a.seq].product_aborh_verify_yn="Y"))
    reply->err_prod_aborh_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 IF ((reply->status_data.status != "F")
  AND size(request->review_items,5) > 0)
  CALL execute_maintain_review_items(0)
 ENDIF
 SET reqinfo->commit_ind = 0
 IF ((((reply->status_data.status="F")) OR ((reply->status_data.status="Z"))) )
  SET reqinfo->commit_ind = 0
 ELSE
  SET reqinfo->commit_ind = 1
 ENDIF
 FREE RECORD gm_i_person_aborh_r0793_req
 FREE RECORD gm_i_person_aborh_r0793_rep
 FREE RECORD gm_u_person_aborh_r0793_req
 FREE RECORD gm_u_person_aborh_r0793_rep
 FREE RECORD gm_i_person_rh_phen2989_req
 FREE RECORD gm_i_person_rh_phen2989_rep
END GO
