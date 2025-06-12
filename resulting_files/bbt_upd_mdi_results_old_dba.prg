CREATE PROGRAM bbt_upd_mdi_results_old:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE estatusok = i2 WITH constant(0)
 DECLARE ecrmerror = i2 WITH constant(1)
 DECLARE escripterror = i2 WITH constant(2)
 DECLARE eprocreserror = i2 WITH constant(3)
 DECLARE eresultnotfounderror = i2 WITH constant(4)
 DECLARE enoorderserror = i2 WITH constant(6)
 DECLARE einvalidassayerror = i2 WITH constant(7)
 DECLARE enoresultspassederror = i2 WITH constant(8)
 DECLARE epreviousresultserror = i2 WITH constant(9)
 DECLARE lapp_nbr = i4 WITH constant(225016)
 DECLARE ltask_nbr = i4 WITH constant(225046)
 DECLARE lbb_processing_type_cs = i4 WITH constant(1635)
 DECLARE santibody_scrn_ord_type = c12 WITH constant("ANTIBDY SCRN")
 DECLARE santibody_scrn_comp_ord_type = c12 WITH constant("ABSC CI")
 DECLARE spatient_aborh_ord_type = c12 WITH constant("PATIENT ABO")
 DECLARE sno_spcl_proc_ord_type = c12 WITH constant("NO SPCL PROC")
 DECLARE lresult_type_cs = i4 WITH constant(289)
 DECLARE salpha_res_type = c12 WITH constant("2")
 DECLARE sonline_codeset_res_type = c12 WITH constant("9")
 DECLARE lresult_status_cs = i4 WITH constant(1901)
 DECLARE sperformed_result_status = c12 WITH constant("PERFORMED")
 DECLARE lresource_grp_type_cs = i4 WITH constant(223)
 DECLARE ssubsection_grp_type = c12 WITH constant("SUBSECTION")
 DECLARE sinstrument_grp_type = c12 WITH protected, constant("INSTRUMENT")
 DECLARE lorder_status_cs = i4 WITH constant(6004)
 DECLARE scancelled_status_cdf = c12 WITH constant("CANCELED")
 DECLARE sdeleted_status_cdf = c12 WITH constant("DELETED")
 DECLARE sdiscontinued_status_cdf = c12 WITH constant("DISCONTINUED")
 DECLARE dantibodyscreenordertypecd = f8 WITH noconstant(0.0)
 DECLARE dantibodyscreencompordertypecd = f8 WITH noconstant(0.0)
 DECLARE dpatientaborhordertypecd = f8 WITH noconstant(0.0)
 DECLARE dalpharesulttypecd = f8 WITH noconstant(0.0)
 DECLARE donlinecodesetresulttypecd = f8 WITH noconstant(0.0)
 DECLARE dnospclprocordertypecd = f8 WITH noconstant(0.0)
 DECLARE dperformedstatuscd = f8 WITH noconstant(0.0)
 DECLARE dsubsectiontypecd = f8 WITH noconstant(0.0)
 DECLARE dcancelstatuscd = f8 WITH noconstant(0.0)
 DECLARE ddeletedstatuscd = f8 WITH noconstant(0.0)
 DECLARE ddiscontinuedstatuscd = f8 WITH noconstant(0.0)
 DECLARE iscriptstatus = i4 WITH noconstant(estatusok)
 DECLARE istat = i2 WITH noconstant(0)
 DECLARE lresultcnt = i4 WITH noconstant(size(request->assay_list,5))
 DECLARE lmaxassaycnt = i4 WITH noconstant(0)
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
 SET log_program_name = curprog
 CALL log_message("Starting Script",log_level_debug)
 SET reply->status_data.status = "F"
 SET iscriptstatus = init(null)
 IF (iscriptstatus != estatusok)
  GO TO exit_script
 ENDIF
 IF ((bb_cache->ilogoverrideind=1))
  CALL echo("request")
  CALL echorecord(request)
 ENDIF
 RECORD orders(
   1 orders[*]
     2 order_id = f8
     2 container_id = f8
     2 osrc_srv_res_cd = f8
 )
 RECORD assays(
   1 assays[*]
     2 task_assay_cd = f8
     2 result = vc
     2 resource_error_codes = vc
 )
 RECORD results(
   1 orders[*]
     2 order_id = f8
     2 person_id = f8
     2 encntr_id = f8
     2 catalog_cd = f8
     2 catalog_type_cd = f8
     2 container_id = f8
     2 osrc_srv_res_cd = f8
     2 assays[*]
       3 task_assay_cd = f8
       3 result_type_cd = f8
       3 result_value_alpha = vc
       3 nomenclature_id = f8
       3 bb_result_code_set_cd = f8
       3 perform_dt_tm = dq8
       3 resource_error_codes = vc
       3 code_set = i4
       3 units_cd = f8
       3 normal_low = f8
       3 normal_high = f8
       3 critical_low = f8
       3 critical_high = f8
       3 reference_range_factor_id = f8
       3 result_id = f8
       3 perform_result_id = f8
       3 result_updt_cnt = i4
       3 perform_result_updt_cnt = i4
 )
 SET donlinecodesetresulttypecd = uar_get_code_by("MEANING",lresult_type_cs,nullterm(
   sonline_codeset_res_type))
 SET dalpharesulttypecd = uar_get_code_by("MEANING",lresult_type_cs,nullterm(salpha_res_type))
 SET dpatientaborhordertypecd = uar_get_code_by("MEANING",lbb_processing_type_cs,nullterm(
   spatient_aborh_ord_type))
 SET dantibodyscreenordertypecd = uar_get_code_by("MEANING",lbb_processing_type_cs,nullterm(
   santibody_scrn_ord_type))
 SET dantibodyscreencompordertypecd = uar_get_code_by("MEANING",lbb_processing_type_cs,nullterm(
   santibody_scrn_comp_ord_type))
 SET dnospclprocordertypecd = uar_get_code_by("MEANING",lbb_processing_type_cs,nullterm(
   sno_spcl_proc_ord_type))
 SET dperformedstatuscd = uar_get_code_by("MEANING",lresult_status_cs,nullterm(
   sperformed_result_status))
 SET dsubsectiontypecd = uar_get_code_by("MEANING",lresource_grp_type_cs,nullterm(
   ssubsection_grp_type))
 SET dcancelstatuscd = uar_get_code_by("MEANING",lorder_status_cs,nullterm(scancelled_status_cdf))
 SET ddeletedstatuscd = uar_get_code_by("MEANING",lorder_status_cs,nullterm(sdeleted_status_cdf))
 SET ddiscontinuedstatuscd = uar_get_code_by("MEANING",lorder_status_cs,nullterm(
   sdiscontinued_status_cdf))
 IF (((donlinecodesetresulttypecd <= 0.0) OR (((dalpharesulttypecd <= 0.0) OR (((
 dpatientaborhordertypecd <= 0.0) OR (((dantibodyscreenordertypecd <= 0.0) OR (((
 dantibodyscreencompordertypecd <= 0.0) OR (((dnospclprocordertypecd <= 0.0) OR (((dperformedstatuscd
  <= 0.0) OR (((dsubsectiontypecd <= 0.0) OR (((dcancelstatuscd <= 0.0) OR (((ddeletedstatuscd <= 0.0
 ) OR (ddiscontinuedstatuscd <= 0.0)) )) )) )) )) )) )) )) )) )) )
  SET iscriptstatus = escripterror
  CALL populate_subeventstatus_msg("VALIDATE","F","UAR",build(
    "At least one required code value not found : ",donlinecodesetresulttypecd,",",dalpharesulttypecd,
    ",",
    dpatientaborhordertypecd,",",dantibodyscreenordertypecd,",",dnospclprocordertypecd,
    ",",dantibodyscreencompordertypecd,",",dperformedstatuscd),log_level_audit)
  GO TO exit_script
 ENDIF
 SET iscriptstatus = buildassaylist(null)
 IF (iscriptstatus != estatusok)
  GO TO exit_script
 ENDIF
 IF (lresultcnt < 1)
  SET iscriptstatus = enoresultspassederror
  CALL populate_subeventstatus_msg("VALIDATE","F","REQUEST","No results passed in",log_level_audit)
  GO TO exit_script
 ENDIF
 IF ((bb_cache->ilogoverrideind=1))
  CALL echo("Assays")
  CALL echorecord(assays)
 ENDIF
 SET iscriptstatus = validateprocedureresulttype(null)
 IF (iscriptstatus != estatusok)
  GO TO exit_script
 ENDIF
 IF ((bb_cache->ilogoverrideind=1))
  CALL echo("Orders")
  CALL echorecord(orders)
  CALL echo("results after ValidateProcedureResultType")
  CALL echorecord(results)
 ENDIF
 SET iscriptstatus = handleonlinecodeset(null)
 IF (iscriptstatus != estatusok)
  GO TO exit_script
 ENDIF
 IF ((bb_cache->ilogoverrideind=1))
  CALL echo("results after HandleOnlineCodeset")
  CALL echorecord(results)
 ENDIF
 SET iscriptstatus = handlealpha(null)
 IF (iscriptstatus != estatusok)
  GO TO exit_script
 ENDIF
 IF ((bb_cache->ilogoverrideind=1))
  CALL echo("results after HandleAlpha")
  CALL echorecord(results)
 ENDIF
 SET iscriptstatus = handlepreviousresults(null)
 IF (iscriptstatus != estatusok)
  GO TO exit_script
 ENDIF
 IF ((bb_cache->ilogoverrideind=1))
  CALL echo("results after HandlePreviousResults")
  CALL echorecord(results)
 ENDIF
 SET iscriptstatus = bbtupdlabresults(null)
 IF (iscriptstatus != estatusok)
  GO TO exit_script
 ENDIF
#exit_script
 CALL cleanup(null)
 IF ((bb_cache->ilogoverrideind=1))
  CALL echo("Reply")
  CALL echorecord(reply)
 ENDIF
 CALL log_message("Ending Script",log_level_debug)
 DECLARE init() = i2
 SUBROUTINE init(null)
   EXECUTE crmrtl
   EXECUTE srvrtl
   IF (validate(bb_cache->happ,0)=0)
    CALL log_message("Creating cache",log_level_debug)
    RECORD bb_cache(
      1 happ = i4
      1 htask = i4
      1 ilogoverrideind = i2
    ) WITH persist
    SET istat = uar_crmbeginapp(lapp_nbr,bb_cache->happ)
    IF (istat != estatusok)
     CALL populate_subeventstatus_msg("BEGINAPP","F",build(lapp_nbr),build(
       "Begin App failed - return status : ",istat),log_level_audit)
     RETURN(ecrmerror)
    ENDIF
    SET istat = uar_crmbegintask(bb_cache->happ,ltask_nbr,bb_cache->htask)
    IF (istat != estatusok)
     CALL populate_subeventstatus_msg("BEGINTASK","F",build(ltask_nbr),build(
       "Begin Task failed - return status : ",istat),log_level_audit)
     RETURN(ecrmerror)
    ENDIF
    SELECT INTO "nl:"
     dm.info_char
     FROM dm_info dm
     WHERE dm.info_domain="PATHNET BLOOD BANK"
      AND dm.info_name="OVERRIDE UPD MDI RESULTS"
     DETAIL
      IF (dm.info_char="L")
       bb_cache->ilogoverrideind = 1
      ELSE
       bb_cache->ilogoverrideind = 0
      ENDIF
     WITH nocounter
    ;end select
    SET istat = error_message(1)
    IF (istat != estatusok)
     RETURN(escripterror)
    ENDIF
   ENDIF
   SET log_override_ind = bb_cache->ilogoverrideind
   RETURN(estatusok)
 END ;Subroutine
 DECLARE buildassaylist() = i2
 SUBROUTINE buildassaylist(null)
   DECLARE nassaycnt = i2 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM (dummyt d_asy  WITH seq = value(size(request->assay_list,5)))
    PLAN (d_asy)
    HEAD REPORT
     nassaycnt = 0
    DETAIL
     IF (trim(request->assay_list[d_asy.seq].result) != "")
      nassaycnt += 1
      IF (nassaycnt > size(assays->assays,5))
       istat = alterlist(assays->assays,(nassaycnt+ 10))
      ENDIF
      assays->assays[nassaycnt].task_assay_cd = request->assay_list[d_asy.seq].task_assay_cd, assays
      ->assays[nassaycnt].result = request->assay_list[d_asy.seq].result, assays->assays[nassaycnt].
      resource_error_codes = request->assay_list[d_asy.seq].resource_error_codes
     ENDIF
    FOOT REPORT
     istat = alterlist(assays->assays,nassaycnt)
    WITH nocounter
   ;end select
   SET lresultcnt = nassaycnt
   RETURN(estatusok)
 END ;Subroutine
 DECLARE validateprocedureresulttype() = i2
 SUBROUTINE validateprocedureresulttype(null)
   DECLARE iprocresvalid = i2 WITH protect, noconstant(1)
   DECLARE iordvalid = i2 WITH protect, noconstant(1)
   DECLARE ltotalassaysloaded = i4 WITH protect, noconstant(0)
   DECLARE iordercontainercnt = i2 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    sserviceresourcemean = uar_get_code_meaning(osrc.service_resource_cd)
    FROM accession_order_r aor,
     resource_group rgp,
     resource_group rgc,
     order_serv_res_container osrc,
     orders o
    PLAN (aor
     WHERE (aor.accession=request->accession)
      AND aor.primary_flag=0)
     JOIN (osrc
     WHERE osrc.order_id=aor.order_id
      AND ((osrc.status_flag+ 0) IN (1, 2)))
     JOIN (o
     WHERE o.order_id=osrc.order_id
      AND  NOT (o.order_status_cd IN (dcancelstatuscd, ddeletedstatuscd, ddiscontinuedstatuscd)))
     JOIN (rgp
     WHERE (rgp.child_service_resource_cd=request->service_resource_cd)
      AND rgp.resource_group_type_cd=dsubsectiontypecd
      AND rgp.active_ind=1)
     JOIN (rgc
     WHERE rgc.parent_service_resource_cd=rgp.parent_service_resource_cd
      AND rgc.child_service_resource_cd=osrc.service_resource_cd
      AND rgc.resource_group_type_cd=dsubsectiontypecd
      AND rgc.active_ind=1)
    ORDER BY osrc.order_id, osrc.container_id
    HEAD REPORT
     iordercontainercnt = 0, iosrcstatus = - (1)
    HEAD osrc.order_id
     IF (sserviceresourcemean=sinstrument_grp_type)
      iordercontainercnt += 1
      IF (iordercontainercnt > size(orders->orders,5))
       istat = alterlist(orders->orders,(iordercontainercnt+ 10))
      ENDIF
      orders->orders[iordercontainercnt].order_id = osrc.order_id, iosrcstatus = - (1)
     ENDIF
    DETAIL
     IF (sserviceresourcemean=sinstrument_grp_type)
      IF ((iosrcstatus=- (1)))
       iosrcstatus = osrc.status_flag, orders->orders[iordercontainercnt].container_id = osrc
       .container_id, orders->orders[iordercontainercnt].osrc_srv_res_cd = osrc.service_resource_cd
      ELSEIF (iosrcstatus=2
       AND osrc.status_flag=1)
       iosrcstatus = osrc.status_flag, orders->orders[iordercontainercnt].container_id = osrc
       .container_id, orders->orders[iordercontainercnt].osrc_srv_res_cd = osrc.service_resource_cd
      ENDIF
     ENDIF
    FOOT  osrc.order_id
     row + 0
    FOOT REPORT
     istat = alterlist(orders->orders,iordercontainercnt)
    WITH nocounter
   ;end select
   SET istat = error_message(1)
   IF (istat != estatusok)
    RETURN(escripterror)
   ENDIF
   IF (iordercontainercnt < 1)
    CALL populate_subeventstatus_msg("LOAD","F","ORDERS",build("No orders found for accession : ",
      request->accession,", Service Resource : ",request->service_resource_cd),log_level_audit)
    RETURN(enoorderserror)
   ENDIF
   SELECT INTO "nl:"
    o.order_id
    FROM orders o,
     (dummyt d_ord  WITH seq = value(iordercontainercnt)),
     service_directory sd,
     (dummyt d_asy  WITH seq = value(lresultcnt)),
     profile_task_r ptr,
     discrete_task_assay dta
    PLAN (d_ord)
     JOIN (o
     WHERE (o.order_id=orders->orders[d_ord.seq].order_id))
     JOIN (sd
     WHERE sd.catalog_cd=o.catalog_cd)
     JOIN (d_asy)
     JOIN (ptr
     WHERE ptr.catalog_cd=sd.catalog_cd
      AND (ptr.task_assay_cd=assays->assays[d_asy.seq].task_assay_cd))
     JOIN (dta
     WHERE dta.task_assay_cd=ptr.task_assay_cd)
    ORDER BY o.order_id, dta.task_assay_cd
    HEAD REPORT
     iordercnt = 0, iassaycnt = 0
    HEAD o.order_id
     iordercnt += 1
     IF (iordercnt > size(results->orders,5))
      istat = alterlist(results->orders,(iordercnt+ 10))
     ENDIF
     results->orders[iordercnt].order_id = o.order_id, results->orders[iordercnt].person_id = o
     .person_id, results->orders[iordercnt].encntr_id = o.encntr_id,
     results->orders[iordercnt].catalog_cd = o.catalog_cd, results->orders[iordercnt].catalog_type_cd
      = o.catalog_type_cd, results->orders[iordercnt].container_id = orders->orders[d_ord.seq].
     container_id,
     results->orders[iordercnt].osrc_srv_res_cd = orders->orders[d_ord.seq].osrc_srv_res_cd,
     iassaycnt = 0
    HEAD dta.task_assay_cd
     iassaycnt += 1
     IF (iassaycnt > size(results->orders[iordercnt].assays,5))
      istat = alterlist(results->orders[iordercnt].assays,(iassaycnt+ 10))
     ENDIF
     results->orders[iordercnt].assays[iassaycnt].task_assay_cd = dta.task_assay_cd, results->orders[
     iordercnt].assays[iassaycnt].result_type_cd = dta.default_result_type_cd, results->orders[
     iordercnt].assays[iassaycnt].result_value_alpha = assays->assays[d_asy.seq].result,
     results->orders[iordercnt].assays[iassaycnt].perform_dt_tm = cnvtdatetime(request->perform_dt_tm
      ), results->orders[iordercnt].assays[iassaycnt].resource_error_codes = assays->assays[d_asy.seq
     ].resource_error_codes
     IF (((((sd.bb_processing_cd=dantibodyscreenordertypecd) OR (sd.bb_processing_cd=
     dantibodyscreencompordertypecd))
      AND dta.default_result_type_cd=dalpharesulttypecd) OR (((sd.bb_processing_cd=
     dpatientaborhordertypecd
      AND ((dta.default_result_type_cd=donlinecodesetresulttypecd) OR (dta.default_result_type_cd=
     dalpharesulttypecd)) ) OR (sd.bb_processing_cd IN (dnospclprocordertypecd, 0.0)
      AND dta.default_result_type_cd=dalpharesulttypecd)) )) )
      IF (dta.default_result_type_cd=donlinecodesetresulttypecd)
       results->orders[iordercnt].assays[iassaycnt].code_set = dta.code_set
      ENDIF
     ELSE
      iprocresvalid = false,
      CALL populate_subeventstatus_msg("VALIDATE","F","PROC/RES TYPE",build(
       "An invalid procedure, result type was found.  OrdType : ",sd.bb_processing_cd,", ResType : ",
       dta.default_result_type_cd),log_level_audit)
     ENDIF
    FOOT  dta.task_assay_cd
     row + 0
    FOOT  o.order_id
     IF (iassaycnt > lmaxassaycnt)
      lmaxassaycnt = iassaycnt
     ENDIF
     istat = alterlist(results->orders[iordercnt].assays,iassaycnt), ltotalassaysloaded += iassaycnt
    FOOT REPORT
     istat = alterlist(results->orders,iordercnt)
    WITH nocounter
   ;end select
   SET istat = error_message(1)
   IF (istat != estatusok)
    RETURN(escripterror)
   ENDIF
   IF (lresultcnt != ltotalassaysloaded)
    CALL populate_subeventstatus_msg("LOAD","F","ASSAYS",concat(
      "At least one assay is invalid for accession : ",request->accession),log_level_audit)
    RETURN(einvalidassayerror)
   ENDIF
   IF (iprocresvalid=false)
    RETURN(eprocreserror)
   ELSE
    RETURN(estatusok)
   ENDIF
 END ;Subroutine
 DECLARE handleonlinecodeset() = i2
 SUBROUTINE handleonlinecodeset(null)
   DECLARE ionlinecsvalid = i2 WITH protect, noconstant(1)
   SELECT INTO "nl:"
    FROM (dummyt d_ord  WITH seq = value(size(results->orders,5))),
     (dummyt d_asy  WITH seq = value(lmaxassaycnt)),
     code_value cv
    PLAN (d_ord)
     JOIN (d_asy
     WHERE d_asy.seq <= size(results->orders[d_ord.seq].assays,5))
     JOIN (cv
     WHERE (cv.code_set=results->orders[d_ord.seq].assays[d_asy.seq].code_set)
      AND cv.active_ind=1
      AND (results->orders[d_ord.seq].assays[d_asy.seq].result_type_cd=donlinecodesetresulttypecd))
    ORDER BY d_ord.seq, d_asy.seq
    HEAD REPORT
     ifoundcsresult = false
    HEAD d_ord.seq
     row + 0
    HEAD d_asy.seq
     ifoundcsresult = false
    DETAIL
     IF ((cv.display=results->orders[d_ord.seq].assays[d_asy.seq].result_value_alpha))
      ifoundcsresult = true, results->orders[d_ord.seq].assays[d_asy.seq].bb_result_code_set_cd = cv
      .code_value
     ENDIF
    FOOT  d_asy.seq
     IF (ifoundcsresult=false)
      ionlinecsvalid = false,
      CALL populate_subeventstatus_msg("VALIDATE","F","CODESET RESULT",build(
       "Invalid online codeset result: ",results->orders[d_ord.seq].assays[d_asy.seq].
       result_value_alpha,", for code set : ",results->orders[d_ord.seq].assays[d_asy.seq].code_set),
      log_level_audit)
     ENDIF
    FOOT  d_ord.seq
     row + 0
    FOOT REPORT
     row + 0
    WITH nocounter
   ;end select
   SET istat = error_message(1)
   IF (istat != estatusok)
    RETURN(escripterror)
   ENDIF
   IF (ionlinecsvalid=true)
    RETURN(estatusok)
   ELSE
    RETURN(eresultnotfounderror)
   ENDIF
 END ;Subroutine
 DECLARE handlealpha() = i2
 SUBROUTINE handlealpha(null)
   DECLARE ialphavalid = i2 WITH protect, noconstant(1)
   DECLARE i = i4 WITH private, noconstant(0)
   DECLARE j = i4 WITH private, noconstant(0)
   DECLARE k = i4 WITH private, noconstant(0)
   DECLARE lordidx = i4 WITH private, noconstant(0)
   DECLARE ifoundalpharesult = i2 WITH private, noconstant(0)
   RECORD requestgetrefranges(
     1 species_cd = f8
     1 specimen_type_cd = f8
     1 sex_cd = f8
     1 birth_sex_cd = f8
     1 age_in_minutes = i4
     1 unknown_age_ind = i2
     1 patient_condition_cd = f8
     1 assays[*]
       2 task_assay_cd = f8
       2 service_resource_cd = f8
       2 order_key = f8
       2 reeval_effective_dt_tm = dq8
       2 specimen_type_cd = f8
       2 prompt_test_ind = i2
       2 age_in_minutes = i4
     1 mdi_nomen_ind = i2
   )
   RECORD replygetrefranges(
     1 qual[*]
       2 order_key = f8
       2 task_assay_cd = f8
       2 service_resource_cd = f8
       2 precedence_sequence = i4
       2 reference_range_factor_id = f8
       2 species_cd = f8
       2 organism_cd = f8
       2 gestational_ind = i2
       2 unknown_age_ind = i2
       2 sex_cd = f8
       2 age_from_units_cd = f8
       2 age_from_minutes = i4
       2 age_to_units_cd = f8
       2 age_to_minutes = i4
       2 specimen_type_cd = f8
       2 patient_condition_cd = f8
       2 default_result = f8
       2 review_ind = i2
       2 review_low = f8
       2 review_high = f8
       2 sensitive_ind = i2
       2 sensitive_low = f8
       2 sensitive_high = f8
       2 normal_ind = i2
       2 normal_low = f8
       2 normal_high = f8
       2 critical_ind = i2
       2 critical_low = f8
       2 critical_high = f8
       2 linear_ind = i2
       2 linear_low = f8
       2 linear_high = f8
       2 feasible_ind = i2
       2 feasible_low = f8
       2 feasible_high = f8
       2 dilute_ind = i2
       2 units_cd = f8
       2 units_disp = vc
       2 delta_check_type_cd = f8
       2 delta_check_type_disp = vc
       2 delta_check_type_mean = c12
       2 delta_minutes = f8
       2 delta_value = f8
       2 code_set = i4
       2 alpha_responses_cnt = i4
       2 alpha_responses[*]
         3 nomenclature_id = f8
         3 sequence = i4
         3 source_vocabulary_cd = f8
         3 source_vocabulary_disp = vc
         3 source_vocabulary_mean = c12
         3 short_string = vc
         3 mnemonic = c25
         3 use_units_ind = i2
         3 result_process_cd = f8
         3 result_process_disp = vc
         3 default_ind = i2
         3 reference_ind = i2
         3 description = vc
         3 concept_identifier = c18
         3 concept_source_cd = f8
         3 concept_source_disp = vc
         3 concept_source_mean = c12
         3 nomenclature_term = vc
       2 delta_chk_flag = i2
       2 advanced_delta_cnt = i4
       2 advanced_delta[*]
         3 advanced_delta_id = f8
         3 delta_ind = i2
         3 delta_low = f8
         3 delta_high = f8
         3 delta_check_type_cd = f8
         3 delta_minutes = i4
         3 delta_value = f8
       2 notify_triggers[*]
         3 sequence = i4
         3 trigger_name = c30
       2 def_result_ind = i2
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   SELECT INTO "nl:"
    dta_cd = results->orders[d_ord.seq].assays[d_asy.seq].task_assay_cd, order_id = results->orders[
    d_ord.seq].order_id, isbirthdttmnull = nullind(p.birth_dt_tm)
    FROM (dummyt d_ord  WITH seq = value(size(results->orders,5))),
     (dummyt d_asy  WITH seq = value(lmaxassaycnt)),
     person p,
     container c,
     person_patient pp
    PLAN (d_ord)
     JOIN (d_asy
     WHERE d_asy.seq <= size(results->orders[d_ord.seq].assays,5))
     JOIN (p
     WHERE (p.person_id=results->orders[d_ord.seq].person_id))
     JOIN (c
     WHERE (c.container_id=results->orders[d_ord.seq].container_id))
     JOIN (pp
     WHERE (pp.person_id= Outerjoin(p.person_id))
      AND (pp.active_ind= Outerjoin(1))
      AND (pp.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(sysdate)))
      AND (pp.end_effective_dt_tm>= Outerjoin(cnvtdatetime(sysdate))) )
    ORDER BY order_id, dta_cd
    HEAD REPORT
     requestgetrefranges->species_cd = p.species_cd, requestgetrefranges->sex_cd = p.sex_cd,
     requestgetrefranges->birth_sex_cd = pp.birth_sex_cd
     IF (isbirthdttmnull=false)
      requestgetrefranges->age_in_minutes = (cnvtmin(c.drawn_dt_tm) - cnvtmin(p.birth_dt_tm))
     ELSE
      requestgetrefranges->unknown_age_ind = 1
     ENDIF
     requestgetrefranges->mdi_nomen_ind = 1, iassaycnt = 0
    HEAD order_id
     row + 0
    HEAD dta_cd
     requestgetrefranges->specimen_type_cd = c.specimen_type_cd, iassaycnt += 1
     IF (iassaycnt > size(requestgetrefranges->assays,5))
      istat = alterlist(requestgetrefranges->assays,(iassaycnt+ 10))
     ENDIF
     requestgetrefranges->assays[iassaycnt].task_assay_cd = dta_cd, requestgetrefranges->assays[
     iassaycnt].service_resource_cd = request->service_resource_cd, requestgetrefranges->assays[
     iassaycnt].order_key = d_ord.seq
    DETAIL
     row + 0
    FOOT  dta_cd
     row + 0
    FOOT  order_id
     row + 0
    FOOT REPORT
     istat = alterlist(requestgetrefranges->assays,iassaycnt)
    WITH nocounter
   ;end select
   SET istat = error_message(1)
   IF (istat != estatusok)
    RETURN(escripterror)
   ENDIF
   EXECUTE glb_get_ref_ranges  WITH replace(request,requestgetrefranges), replace(reply,
    replygetrefranges)
   IF ((bb_cache->ilogoverrideind=1))
    CALL echorecord(requestgetrefranges)
    CALL echorecord(replygetrefranges)
   ENDIF
   IF ((replygetrefranges->status_data.status != "S"))
    CALL log_message("HandleAlpha - GLB_GET_REF_RANGES returned a non-success status",log_level_audit
     )
    SET reply->status_data.status = replygetrefranges->status_data.status
    FOR (i = 1 TO size(replygetrefranges->status_data.subeventstatus,5))
      CALL populate_subeventstatus_msg(replygetrefranges->status_data.subeventstatus[i].operationname,
       replygetrefranges->status_data.subeventstatus[i].operationstatus,replygetrefranges->
       status_data.subeventstatus[i].targetobjectname,replygetrefranges->status_data.subeventstatus[i
       ].targetobjectvalue,log_level_audit)
    ENDFOR
    RETURN(escripterror)
   ENDIF
   FOR (i = 1 TO size(replygetrefranges->qual,5))
    SET lordidx = cnvtint(replygetrefranges->qual[i].order_key)
    FOR (j = 1 TO size(results->orders[lordidx].assays,5))
      IF ((results->orders[lordidx].assays[j].task_assay_cd=replygetrefranges->qual[i].task_assay_cd)
      )
       SET results->orders[lordidx].assays[j].units_cd = replygetrefranges->qual[i].units_cd
       SET results->orders[lordidx].assays[j].normal_low = replygetrefranges->qual[i].normal_low
       SET results->orders[lordidx].assays[j].normal_high = replygetrefranges->qual[i].normal_high
       SET results->orders[lordidx].assays[j].critical_low = replygetrefranges->qual[i].critical_low
       SET results->orders[lordidx].assays[j].critical_high = replygetrefranges->qual[i].
       critical_high
       SET results->orders[lordidx].assays[j].reference_range_factor_id = replygetrefranges->qual[i].
       reference_range_factor_id
       IF ((results->orders[lordidx].assays[j].result_type_cd=dalpharesulttypecd))
        SET ifoundalpharesult = false
        SET k = 1
        WHILE (k <= size(replygetrefranges->qual[i].alpha_responses,5)
         AND ifoundalpharesult=false)
         IF ((results->orders[lordidx].assays[j].result_value_alpha=replygetrefranges->qual[i].
         alpha_responses[k].mnemonic))
          SET ifoundalpharesult = true
          SET results->orders[lordidx].assays[j].nomenclature_id = replygetrefranges->qual[i].
          alpha_responses[k].nomenclature_id
         ENDIF
         SET k += 1
        ENDWHILE
        IF (ifoundalpharesult=false)
         CALL populate_subeventstatus_msg("VALIDATE","F","ALPHA_RESPONSES",concat(
           "Unable to find MDI alpha response results for:",results->orders[lordidx].assays[j].
           result_value_alpha),log_level_audit)
         SET ialphavalid = false
        ENDIF
       ENDIF
      ENDIF
    ENDFOR
   ENDFOR
   FREE RECORD requestgetrefranges
   FREE RECORD replygetrefranges
   IF (ialphavalid=true)
    RETURN(estatusok)
   ELSE
    RETURN(eresultnotfounderror)
   ENDIF
 END ;Subroutine
 DECLARE handlepreviousresults() = i2
 SUBROUTINE handlepreviousresults(null)
   DECLARE ipreviousresultsvalid = i2 WITH protect, noconstant(1)
   SELECT INTO "nl:"
    r.result_id
    FROM (dummyt d_ord  WITH seq = value(size(results->orders,5))),
     (dummyt d_asy  WITH seq = value(lmaxassaycnt)),
     result r,
     perform_result pr
    PLAN (d_ord)
     JOIN (d_asy
     WHERE d_asy.seq <= size(results->orders[d_ord.seq].assays,5))
     JOIN (r
     WHERE (r.order_id=results->orders[d_ord.seq].order_id)
      AND (r.task_assay_cd=results->orders[d_ord.seq].assays[d_asy.seq].task_assay_cd))
     JOIN (pr
     WHERE pr.result_id=r.result_id
      AND pr.result_status_cd=r.result_status_cd)
    DETAIL
     IF (pr.result_status_cd=dperformedstatuscd)
      results->orders[d_ord.seq].assays[d_asy.seq].result_id = pr.result_id, results->orders[d_ord
      .seq].assays[d_asy.seq].perform_result_id = pr.perform_result_id, results->orders[d_ord.seq].
      assays[d_asy.seq].result_updt_cnt = r.updt_cnt,
      results->orders[d_ord.seq].assays[d_asy.seq].perform_result_updt_cnt = pr.updt_cnt
     ELSE
      ipreviousresultsvalid = false,
      CALL populate_subeventstatus_msg("VALIDATE","F","PREVIOUSRESULTS",build(
       "Found previous result in invalid status for order_id : ",results->orders[d_ord.seq].order_id,
       ", status_cd = ",pr.result_status_cd),log_level_audit)
     ENDIF
    WITH nocounter
   ;end select
   SET istat = error_message(1)
   IF (istat != estatusok)
    RETURN(escripterror)
   ENDIF
   IF (ipreviousresultsvalid=true)
    RETURN(estatusok)
   ELSE
    RETURN(epreviousresultserror)
   ENDIF
 END ;Subroutine
 DECLARE bbtupdlabresults() = i2
 SUBROUTINE bbtupdlabresults(null)
   DECLARE lreq_nbr = i4 WITH private, constant(225070)
   DECLARE hstep = i4 WITH private, noconstant(0)
   DECLARE hrequest = i4 WITH protect, noconstant(0)
   DECLARE hreply = i4 WITH private, noconstant(0)
   DECLARE hstatus = i4 WITH private, noconstant(0)
   DECLARE hitem = i4 WITH private, noconstant(0)
   DECLARE horder = i4 WITH protect, noconstant(0)
   DECLARE hassay = i4 WITH protect, noconstant(0)
   DECLARE sstatus = c1 WITH private, noconstant("F")
   SET istat = uar_crmbeginreq(bb_cache->htask,"",lreq_nbr,hstep)
   IF (istat != estatusok)
    CALL populate_subeventstatus_msg("BEGINREQ","F",build(lreq_nbr),build(
      "Begin Request failed - return status : ",istat),log_level_audit)
    RETURN(ecrmerror)
   ENDIF
   SET hrequest = uar_crmgetrequest(hstep)
   SELECT INTO "nl:"
    dta_cd = results->orders[d_ord.seq].assays[d_asy.seq].task_assay_cd, order_id = results->orders[
    d_ord.seq].order_id
    FROM (dummyt d_ord  WITH seq = value(size(results->orders,5))),
     (dummyt d_asy  WITH seq = value(lmaxassaycnt)),
     container c
    PLAN (d_ord)
     JOIN (d_asy
     WHERE d_asy.seq <= size(results->orders[d_ord.seq].assays,5))
     JOIN (c
     WHERE (c.container_id=results->orders[d_ord.seq].container_id))
    ORDER BY order_id, dta_cd
    HEAD REPORT
     istat = uar_srvsetdate(hrequest,"event_dt_tm",cnvtdatetime(request->perform_dt_tm)), istat =
     uar_srvsetstring(hrequest,"event_reason",nullterm("Performed"))
    HEAD order_id
     horder = 0, horder = uar_srvadditem(hrequest,"orders"), istat = uar_srvsetstring(horder,
      "accession",nullterm(request->accession)),
     istat = uar_srvsetdouble(horder,"order_id",results->orders[d_ord.seq].order_id), istat =
     uar_srvsetdouble(horder,"catalog_cd",results->orders[d_ord.seq].catalog_cd), istat =
     uar_srvsetdouble(horder,"person_id",results->orders[d_ord.seq].person_id),
     istat = uar_srvsetdouble(horder,"encntr_id",results->orders[d_ord.seq].encntr_id), istat =
     uar_srvsetdouble(horder,"catalog_type_cd",results->orders[d_ord.seq].catalog_type_cd), istat =
     uar_srvsetlong(horder,"assays_cnt",size(results->orders[d_ord.seq].assays,5)),
     istat = uar_srvsetshort(horder,"patient_order_ind",1)
    HEAD dta_cd
     hassay = 0, hassay = uar_srvadditem(horder,"assays"), istat = uar_srvsetdouble(hassay,
      "container_id",c.container_id),
     istat = uar_srvsetdouble(hassay,"specimen_id",c.specimen_id), istat = uar_srvsetdate(hassay,
      "drawn_dt_tm",c.drawn_dt_tm), istat = uar_srvsetdouble(hassay,"task_assay_cd",results->orders[
      d_ord.seq].assays[d_asy.seq].task_assay_cd),
     istat = uar_srvsetdouble(hassay,"reference_range_factor_id",results->orders[d_ord.seq].assays[
      d_asy.seq].reference_range_factor_id), istat = uar_srvsetdouble(hassay,"result_type_cd",results
      ->orders[d_ord.seq].assays[d_asy.seq].result_type_cd), istat = uar_srvsetstring(hassay,
      "result_value_alpha",nullterm(results->orders[d_ord.seq].assays[d_asy.seq].result_value_alpha)),
     istat = uar_srvsetdate(hassay,"perform_dt_tm",cnvtdatetime(request->perform_dt_tm)), istat =
     uar_srvsetdouble(hassay,"service_resource_cd",request->service_resource_cd), istat =
     uar_srvsetstring(hassay,"resource_error_codes",nullterm(results->orders[d_ord.seq].assays[d_asy
       .seq].resource_error_codes)),
     istat = uar_srvsetdouble(hassay,"nomenclature_id",results->orders[d_ord.seq].assays[d_asy.seq].
      nomenclature_id), istat = uar_srvsetdouble(hassay,"bb_result_code_set_cd",results->orders[d_ord
      .seq].assays[d_asy.seq].bb_result_code_set_cd), istat = uar_srvsetdouble(hassay,"result_id",
      results->orders[d_ord.seq].assays[d_asy.seq].result_id),
     istat = uar_srvsetdouble(hassay,"perform_result_id",results->orders[d_ord.seq].assays[d_asy.seq]
      .perform_result_id), istat = uar_srvsetlong(hassay,"result_updt_cnt",results->orders[d_ord.seq]
      .assays[d_asy.seq].result_updt_cnt), istat = uar_srvsetlong(hassay,"perform_result_updt_cnt",
      results->orders[d_ord.seq].assays[d_asy.seq].perform_result_updt_cnt),
     istat = uar_srvsetshort(hassay,"perform_ind",1), istat = uar_srvsetdouble(hassay,
      "result_status_cd",dperformedstatuscd), istat = uar_srvsetshort(hassay,"next_row_ind",1),
     istat = uar_srvsetstring(hassay,"bb_result_id_yn",nullterm("N")), istat = uar_srvsetstring(
      hassay,"crossmatch_verify_yn",nullterm("N")), istat = uar_srvsetstring(hassay,"update_to_xm_yn",
      nullterm("N")),
     istat = uar_srvsetstring(hassay,"aborh_verify_yn",nullterm("N")), istat = uar_srvsetstring(
      hassay,"upd_pat_hist_aborh_yn",nullterm("N")), istat = uar_srvsetstring(hassay,
      "antibody_verify_yn",nullterm("N")),
     istat = uar_srvsetstring(hassay,"antigen_verify_yn",nullterm("N")), istat = uar_srvsetstring(
      hassay,"product_test_special_test_yn",nullterm("N")), istat = uar_srvsetstring(hassay,
      "special_testing_verify_yn",nullterm("N")),
     istat = uar_srvsetstring(hassay,"upd_blood_product_yn",nullterm("N")), istat = uar_srvsetstring(
      hassay,"upd_product_avail_yn",nullterm("N")), istat = uar_srvsetstring(hassay,
      "upd_product_conf_yn",nullterm("N")),
     istat = uar_srvsetstring(hassay,"upd_product_unconf_yn",nullterm("N")), istat = uar_srvsetstring
     (hassay,"inact_product_avail_yn",nullterm("N")), istat = uar_srvsetstring(hassay,
      "add_product_unconf_yn",nullterm("N")),
     istat = uar_srvsetstring(hassay,"rh_phenotype_verify_yn",nullterm("N")), istat =
     uar_srvsetstring(hassay,"product_rh_phenotype_verify_yn",nullterm("N")), istat =
     uar_srvsetstring(hassay,"upd_rh_phenotype_yn",nullterm("N")),
     istat = uar_srvsetshort(hassay,"interface_flag",1)
    DETAIL
     row + 0
    FOOT  dta_cd
     row + 0
    FOOT  order_id
     row + 0
    FOOT REPORT
     row + 0
    WITH nocounter
   ;end select
   SET istat = error_message(1)
   IF (istat != estatusok)
    CALL uar_crmendreq(hstep)
    RETURN(escripterror)
   ENDIF
   IF (log_override_ind=1)
    CALL uar_crmlogmessage(hrequest,"req225070.dat")
   ENDIF
   SET istat = uar_crmperform(hstep)
   IF (istat != estatusok)
    CALL populate_subeventstatus_msg("CRMPERFORM","F","BBT_UPD_LAB_RESULTS",build(
      "Calling update results script failed.  Status : ",istat),log_level_warning)
    CALL uar_crmendreq(hstep)
    RETURN(ecrmerror)
   ENDIF
   SET hreply = uar_crmgetreply(hstep)
   IF (log_override_ind=1)
    CALL uar_crmlogmessage(hreply,"rep225070.dat")
   ENDIF
   SET hstatus = uar_srvgetstruct(hreply,"status_data")
   SET sstatus = uar_srvgetstringptr(hstatus,"status")
   IF (sstatus != "S")
    CALL log_message("BBT_UPD_LAB_RESULTS returned a non-success status",log_level_audit)
    SET reply->status_data.status = uar_srvgetstringptr(hstatus,"status")
    FOR (i = 0 TO (uar_srvgetitemcount(hstatus,"subeventstatus") - 1))
     SET hitem = uar_srvgetitem(hstatus,"subeventstatus",i)
     CALL populate_subeventstatus_msg(uar_srvgetstringptr(hitem,"OperationName"),uar_srvgetstringptr(
       hitem,"OperationStatus"),uar_srvgetstringptr(hitem,"TargetObjectName"),uar_srvgetstringptr(
       hitem,"TargetObjectValue"),log_level_audit)
    ENDFOR
    CALL uar_crmendreq(hstep)
    RETURN(escripterror)
   ENDIF
   CALL uar_crmendreq(hstep)
   RETURN(estatusok)
 END ;Subroutine
 DECLARE cleanup() = null
 SUBROUTINE cleanup(null)
   IF (iscriptstatus != estatusok)
    SET reply->status = "F"
    CALL populate_subeventstatus_msg("SCRIPT","F","BBT_UPD_MDI_RESULTS_OLD",build(
      "Script failure.  Status: ",iscriptstatus),log_level_audit)
   ELSE
    SET reply->status = "S"
   ENDIF
   FREE RECORD orders
   FREE RECORD assays
   FREE RECORD results
   CALL uar_sysdestroyhandle(hsys)
 END ;Subroutine
END GO
