CREATE PROGRAM bbt_upd_mdi_results:dba
 IF ((validate(request->order_type_flag,- (1))=- (1)))
  EXECUTE bbt_upd_mdi_results_old
  GO TO end_script
 ENDIF
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE buildresultnotefrommetadata() = vc
 DECLARE modifiedassaycounter = i2 WITH noconstant(0)
 DECLARE estatusok = i2 WITH constant(0)
 DECLARE ecrmerror = i2 WITH constant(1)
 DECLARE escripterror = i2 WITH constant(2)
 DECLARE eprocreserror = i2 WITH constant(3)
 DECLARE eresultnotfounderror = i2 WITH constant(4)
 DECLARE enoorderserror = i2 WITH constant(6)
 DECLARE einvalidassayerror = i2 WITH constant(7)
 DECLARE enoresultspassederror = i2 WITH constant(8)
 DECLARE epreviousresultserror = i2 WITH constant(9)
 DECLARE emetadatanotbuilterror = i2 WITH constant(10)
 DECLARE einvalidpanelerror = i2 WITH constant(11)
 DECLARE lapp_nbr = i4 WITH constant(225016)
 DECLARE ltask_nbr = i4 WITH constant(225046)
 DECLARE lpatient_order_type = i4 WITH protect, constant(0)
 DECLARE lproduct_order_type = i4 WITH protect, constant(1)
 DECLARE lpatient_product_order_type = i4 WITH protect, constant(2)
 DECLARE lbb_aborh_type_cs = i4 WITH constant(1643)
 DECLARE lbb_processing_type_cs = i4 WITH constant(1635)
 DECLARE lbb_interp_type_cs = i4 WITH constant(1632)
 DECLARE lbb_metadata_cs = i4 WITH constant(4460007)
 DECLARE lbb_product_aborh_type_cs = i4 WITH constant(1640)
 DECLARE santibody_scrn_ord_type = c12 WITH constant("ANTIBDY SCRN")
 DECLARE santibody_scrn_comp_ord_type = c12 WITH constant("ABSC CI")
 DECLARE srhphenotype_ord_type = c12 WITH constant("RH PHENOTYPE")
 DECLARE spatient_aborh_ord_type = c12 WITH constant("PATIENT ABO")
 DECLARE scrossmatch_ord_type = c12 WITH constant("XM")
 DECLARE sproduct_aborh_ord_type = c12 WITH constant("PRODUCT ABO")
 DECLARE sno_spcl_proc_ord_type = c12 WITH constant("NO SPCL PROC")
 DECLARE santibody_id_ord_type = c12 WITH constant("ANTIBODY ID")
 DECLARE santigen_ord_type = c12 WITH constant("ANTIGEN")
 DECLARE lresult_processing_type_cs = i4 WITH constant(1636)
 DECLARE stest_phase_proc_type = c12 WITH constant("TEST PHASE")
 DECLARE shistory_upd_proc_type = c12 WITH constant("HISTRY & UPD")
 DECLARE shistory_only_proc_type = c12 WITH constant("HISTRY ONLY")
 DECLARE lresult_type_cs = i4 WITH constant(289)
 DECLARE salpha_res_type = c12 WITH constant("2")
 DECLARE sonline_codeset_res_type = c12 WITH constant("9")
 DECLARE sinterp_result_type = c21 WITH constant("4")
 DECLARE salpha_interp_type = c12 WITH constant("ALPHA")
 DECLARE scodeset_interp_type = c12 WITH constant("CODESET")
 DECLARE santigen_interp_type = c12 WITH constant("AG INTERP")
 DECLARE santigen_reaction_type = c12 WITH constant("AG REACTION")
 DECLARE santigen_tested_type = c12 WITH constant("AG TESTED")
 DECLARE lresult_status_cs = i4 WITH constant(1901)
 DECLARE sperformed_result_status = c12 WITH constant("PERFORMED")
 DECLARE lresource_grp_type_cs = i4 WITH constant(223)
 DECLARE ssubsection_grp_type = c12 WITH constant("SUBSECTION")
 DECLARE lorder_status_cs = i4 WITH constant(6004)
 DECLARE scancelled_status_cdf = c12 WITH constant("CANCELED")
 DECLARE sdeleted_status_cdf = c12 WITH constant("DELETED")
 DECLARE sdiscontinued_status_cdf = c12 WITH constant("DISCONTINUED")
 DECLARE linventory_state_cs = i4 WITH constant(1610)
 DECLARE sin_progress_state_cdf = c12 WITH constant("16")
 DECLARE sresult_comment_type_cs = i4 WITH constant(14)
 DECLARE sresult_note_mean = c12 WITH constant("RES NOTE")
 DECLARE sinstrument_type_cs = i4 WITH constant(73)
 DECLARE sinstrument_model_type_cs = i4 WITH constant(221)
 DECLARE stask_assay_cs = i4 WITH constant(14003)
 DECLARE scell_group_cs = i4 WITH constant(1602)
 DECLARE sphase_group_cs = i4 WITH constant(1601)
 DECLARE santigen_cs = i4 WITH constant(4502006)
 DECLARE sreagentcell_cs = i4 WITH constant(1603)
 DECLARE dantibodyscreenordertypecd = f8 WITH noconstant(0.0)
 DECLARE dantibodyscreencompordertypecd = f8 WITH noconstant(0.0)
 DECLARE dpatientaborhordertypecd = f8 WITH noconstant(0.0)
 DECLARE dcrossmatchordertypecd = f8 WITH noconstant(0.0)
 DECLARE dproductaborhordertypecd = f8 WITH noconstant(0.0)
 DECLARE dnospclprocordertypecd = f8 WITH noconstant(0.0)
 DECLARE dalpharesulttypecd = f8 WITH noconstant(0.0)
 DECLARE donlinecodesetresulttypecd = f8 WITH noconstant(0.0)
 DECLARE dinterpresulttypecd = f8 WITH noconstant(0.0)
 DECLARE dperformedstatuscd = f8 WITH noconstant(0.0)
 DECLARE dsubsectiontypecd = f8 WITH noconstant(0.0)
 DECLARE dcancelstatuscd = f8 WITH noconstant(0.0)
 DECLARE ddeletedstatuscd = f8 WITH noconstant(0.0)
 DECLARE ddiscontinuedstatuscd = f8 WITH noconstant(0.0)
 DECLARE dinprogressstatuscd = f8 WITH noconstant(0.0)
 DECLARE dalphainterptypecd = f8 WITH noconstant(0.0)
 DECLARE dcodesetinterptypecd = f8 WITH noconstant(0.0)
 DECLARE dresultnotecd = f8 WITH noconstant(0.0)
 DECLARE sperformedstatusdisp = vc WITH noconstant("")
 DECLARE dantibodyidordertypecd = f8 WITH noconstant(0.0)
 DECLARE dantigenordertypecd = f8 WITH noconstant(0.0)
 DECLARE dorderprocesstypecd = f8 WITH noconstant(0.0)
 DECLARE dantigeninterptypecd = f8 WITH noconstant(0.0)
 DECLARE dantigenreactiontypecd = f8 WITH noconstant(0.0)
 DECLARE dantigentestedtypecd = f8 WITH noconstant(0.0)
 DECLARE iscriptstatus = i4 WITH noconstant(estatusok)
 DECLARE istat = i2 WITH noconstant(0)
 DECLARE smodifiedresultyes = vc WITH noconstant("")
 DECLARE lresultcnt = i4 WITH noconstant(size(request->assay_list,5))
 DECLARE lmaxassaycnt = i4 WITH noconstant(0)
 DECLARE lpanelcnt = i4 WITH noconstant(size(request->panels,5))
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
 DECLARE i18nhandle = i4 WITH public, noconstant(0)
 CALL uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 DECLARE statusyes = vc WITH protected, constant(uar_i18ngetmessage(i18nhandle,"statusYes","Yes"))
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
     2 interface_status_flag = i2
     2 task_assay_cd = f8
     2 result = vc
     2 product_id = f8
     2 resource_error_codes = vc
     2 inprogress_event_id = f8
     2 prod_state_updt_cnt = i4
     2 result_note = vc
     2 bb_order_cell_id = f8
     2 bb_control_cell_cd = f8
 )
 RECORD metadatas(
   1 meta_datas[*]
     2 meta_data_cd = f8
     2 meta_data_disp = vc
     2 meta_data_cdf_meaning = vc
     2 meta_data_collation_seq = i4
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
       3 product_id = f8
       3 bb_result_id = f8
       3 inprogress_prod_event_id = f8
       3 prod_state_updt_cnt = i4
       3 next_row_ind = i2
       3 interp_type_cd = f8
       3 interface_status_flag = i2
       3 result_note = vc
       3 bb_order_cell_id = f8
       3 bb_control_cell_cd = f8
       3 nomenclature_term = vc
       3 review_cd = f8
       3 critical_cd = f8
       3 normal_cd = f8
 )
 RECORD panels(
   1 service_resource_cd = f8
   1 instrument_model_cd = f8
   1 phase_group_cd = f8
   1 order_phase_id = f8
   1 max_cell_cnt = i4
   1 panel[*]
     2 panel_name = vc
     2 cell_group_cd = f8
     2 phase_group_cd = f8
     2 cell_cd = f8
     2 bb_order_cell_id = f8
     2 product_id = f8
     2 cell[*]
       3 cell_name = vc
       3 dta_cd = f8
       3 result = vc
       3 resource_error_codes = vc
       3 result_note = vc
       3 antigen_tested_cd = f8
       3 antigen_tested_text = vc
 )
 DECLARE resolvepanelinformation(null) = i2
 DECLARE findinstrumentfromserviceresource(null) = i2
 DECLARE findaliasesfrompanelname(null) = i2
 DECLARE resolvecellgroups(null) = i2
 DECLARE resolveproperphasegroup(null) = i2
 DECLARE resolvetaskassays(null) = i2
 DECLARE addordercells(null) = i2
 DECLARE findresultprocessingtypebyorderid(null) = null
 DECLARE buildantigenpanels(null) = i2
 DECLARE findantigendtasbymeaning(null) = i2
 DECLARE findpreviousantigenresults(null) = i2
 DECLARE resolveantigeninterps(null) = null
 SUBROUTINE resolvepanelinformation(null)
   IF (findinstrumentfromserviceresource(null) != estatusok)
    RETURN(escripterror)
   ENDIF
   IF (findaliasesfrompanelname(null) != estatusok)
    RETURN(escripterror)
   ENDIF
   CALL findresultprocessingtypebyorderid(null)
   IF (resolvecellgroups(null) != estatusok)
    RETURN(escripterror)
   ENDIF
   IF (resolveproperphasegroup(null) != estatusok)
    RETURN(escripterror)
   ENDIF
   IF (resolvetaskassays(null) != estatusok)
    RETURN(escripterror)
   ENDIF
   IF (buildantigenpanels(null) != estatusok)
    RETURN(escripterror)
   ENDIF
   IF (addordercells(null) != estatusok)
    RETURN(escripterror)
   ENDIF
   RETURN(estatusok)
 END ;Subroutine
 SUBROUTINE findinstrumentfromserviceresource(null)
   DECLARE recordcnt = i2 WITH protect, noconstant(0)
   DECLARE parent_code_value = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    FROM code_value_group cvg,
     code_value cv
    PLAN (cvg
     WHERE (cvg.child_code_value=request->service_resource_cd)
      AND cvg.code_set=sinstrument_model_type_cs)
     JOIN (cv
     WHERE cv.code_set=sinstrument_type_cs
      AND cv.code_value=cvg.parent_code_value
      AND cv.active_ind=1)
    DETAIL
     recordcnt += 1, parent_code_value = cvg.parent_code_value
    WITH nocounter
   ;end select
   IF (recordcnt=1)
    SET panels->service_resource_cd = request->service_resource_cd
    SET panels->instrument_model_cd = parent_code_value
   ELSE
    CALL populate_subeventstatus_msg("LOAD","F","PANELS","Unable to find instrument model",
     log_level_audit)
    RETURN(einvalidpanelerror)
   ENDIF
   RETURN(estatusok)
 END ;Subroutine
 SUBROUTINE findaliasesfrompanelname(null)
   DECLARE npanelcnt = i2 WITH protect, noconstant(0)
   DECLARE ncellcnt = i2 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM (dummyt d_panel  WITH seq = value(size(request->panels,5))),
     code_value cv,
     code_value_alias cva
    PLAN (d_panel)
     JOIN (cv
     WHERE cv.active_ind=1
      AND cv.code_set IN (sphase_group_cs, scell_group_cs))
     JOIN (cva
     WHERE (cva.contributor_source_cd=panels->instrument_model_cd)
      AND cva.code_set=cv.code_set
      AND cva.code_value=cv.code_value
      AND (cva.alias=request->panels[d_panel.seq].panel_name))
    ORDER BY d_panel.seq, cv.code_set
    HEAD REPORT
     npanelcnt = 0
    HEAD d_panel.seq
     npanelcnt += 1
    DETAIL
     cv.code_set
     IF (npanelcnt > size(panels->panel,5))
      istat = alterlist(panels->panel,(npanelcnt+ 10))
     ENDIF
     IF (cv.code_set=scell_group_cs)
      panels->panel[npanelcnt].panel_name = request->panels[d_panel.seq].panel_name, panels->panel[
      npanelcnt].product_id = request->panels[d_panel.seq].product_id, panels->panel[npanelcnt].
      cell_group_cd = cva.code_value
      IF ((size(request->panels[d_panel.seq].cells,5) > panels->max_cell_cnt))
       panels->max_cell_cnt = size(request->panels[d_panel.seq].cells,5)
      ENDIF
     ELSE
      panels->panel[npanelcnt].panel_name = request->panels[d_panel.seq].panel_name, panels->panel[
      npanelcnt].product_id = request->panels[d_panel.seq].product_id, panels->panel[npanelcnt].
      phase_group_cd = cva.code_value
     ENDIF
    FOOT REPORT
     istat = alterlist(panels->panel,npanelcnt)
    WITH nocounter
   ;end select
   SET istat = error_message(1)
   IF (istat != estatusok)
    RETURN(escripterror)
   ENDIF
   IF (npanelcnt != lpanelcnt)
    CALL populate_subeventstatus_msg("LOAD","F","PANELS","Unable to find alias for panel name.",
     log_level_audit)
    RETURN(einvalidpanelerror)
   ENDIF
   RETURN(estatusok)
 END ;Subroutine
 SUBROUTINE resolvecellgroups(null)
   DECLARE cellcnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM (dummyt d_panel  WITH seq = lpanelcnt),
     cell_group cg,
     code_value cv
    PLAN (d_panel)
     JOIN (cg
     WHERE (cg.cell_group_cd=panels->panel[d_panel.seq].cell_group_cd)
      AND cg.active_ind=1)
     JOIN (cv
     WHERE cv.code_value=cg.cell_cd
      AND cv.code_set=sreagentcell_cs)
    ORDER BY d_panel.seq
    HEAD REPORT
     cellcnt = 0
    DETAIL
     IF (dorderprocesstypecd=dantigenordertypecd)
      IF ((panels->panel[d_panel.seq].product_id=0)
       AND cv.cdf_meaning="PATIENT CELL")
       panels->panel[d_panel.seq].cell_cd = cg.cell_cd, cellcnt += 1
      ELSEIF ((panels->panel[d_panel.seq].product_id > 0)
       AND cv.cdf_meaning="PRODUCT CELL")
       panels->panel[d_panel.seq].cell_cd = cg.cell_cd, cellcnt += 1
      ENDIF
     ELSE
      panels->panel[d_panel.seq].cell_cd = cg.cell_cd, cellcnt += 1
     ENDIF
    WITH nocounter
   ;end select
   IF (cellcnt != lpanelcnt)
    CALL populate_subeventstatus_msg("LOAD","F","PANELS",
     "Unable to find cell. Cell Group should contain one cell.",log_level_audit)
    RETURN(einvalidpanelerror)
   ENDIF
   RETURN(estatusok)
 END ;Subroutine
 SUBROUTINE resolveproperphasegroup(null)
   DECLARE pcnt = i4 WITH protect, noconstant(0)
   DECLARE i = i4 WITH protect, noconstant(0)
   DECLARE req_sup_phase_grp_cd = f8 WITH protect, noconstant(- (1.0))
   DECLARE superset_phase_grp_cd = f8 WITH protect, noconstant(- (1.0))
   SET req_sup_phase_grp_cd = panels->panel[lpanelcnt].phase_group_cd
   FOR (i = 1 TO (lpanelcnt - 1))
    IF ((panels->panel[i].phase_group_cd != 0.0))
     SET req_sup_phase_grp_cd = findsupersetphasegroup(req_sup_phase_grp_cd,panels->panel[i].
      phase_group_cd)
    ENDIF
    IF ((req_sup_phase_grp_cd=- (1.0)))
     CALL populate_subeventstatus_msg("LOAD","F","PANELS","0:Unable to resolve phase group.",
      log_level_audit)
     RETURN(einvalidpanelerror)
    ENDIF
   ENDFOR
   RECORD temp(
     1 qual[*]
       2 order_phase_id = f8
       2 phase_grp_cd = f8
   )
   SELECT DISTINCT INTO "nl:"
    FROM bb_order_phase bop
    PLAN (bop
     WHERE (bop.order_id=request->order_id))
    HEAD REPORT
     pcnt = 0, istat = alterlist(temp->qual,10)
    HEAD bop.phase_grp_cd
     pcnt += 1
     IF (mod(pcnt,10)=1
      AND pcnt > 10)
      istat = alterlist(temp->qual,(pcnt+ 9))
     ENDIF
     temp->qual[pcnt].order_phase_id = bop.order_phase_id, temp->qual[pcnt].phase_grp_cd = bop
     .phase_grp_cd
    FOOT REPORT
     istat = alterlist(temp->qual,pcnt)
    WITH nocounter
   ;end select
   IF (pcnt=0)
    RETURN(addorupdatephasegroup(request->order_id,req_sup_phase_grp_cd,1))
   ENDIF
   IF (pcnt=1)
    IF ((temp->qual[pcnt].phase_grp_cd=req_sup_phase_grp_cd))
     SET panels->phase_group_cd = temp->qual[pcnt].phase_grp_cd
     SET panels->order_phase_id = temp->qual[pcnt].order_phase_id
    ELSE
     SET superset_phase_grp_cd = findsupersetphasegroup(temp->qual[pcnt].phase_grp_cd,
      req_sup_phase_grp_cd)
     IF ((superset_phase_grp_cd != - (1.0)))
      IF ((superset_phase_grp_cd != temp->qual[pcnt].phase_grp_cd))
       RETURN(addorupdatephasegroup(request->order_id,superset_phase_grp_cd,0))
      ENDIF
     ELSE
      CALL populate_subeventstatus_msg("LOAD","F","PANELS","2:Unable to resolve phase group.",
       log_level_audit)
      RETURN(einvalidpanelerror)
     ENDIF
    ENDIF
   ENDIF
   FREE RECORD temp
   SET istat = error_message(1)
   IF (istat != estatusok)
    RETURN(escripterror)
   ENDIF
   RETURN(estatusok)
 END ;Subroutine
 SUBROUTINE (findsupersetphasegroup(existing_pg_cd=f8,proposed_pg_cd=f8) =f8)
   DECLARE existing_superset_ind = i2 WITH protect, noconstant(1)
   DECLARE proposed_superset_ind = i2 WITH protect, noconstant(1)
   SELECT INTO "nl:"
    FROM phase_group pg,
     phase_group pg1,
     phase_group pg2
    PLAN (pg
     WHERE pg.phase_group_cd IN (existing_pg_cd, proposed_pg_cd)
      AND pg.active_ind=1)
     JOIN (pg1
     WHERE (pg1.task_assay_cd= Outerjoin(pg.task_assay_cd))
      AND (pg1.phase_group_cd= Outerjoin(existing_pg_cd)) )
     JOIN (pg2
     WHERE (pg2.task_assay_cd= Outerjoin(pg.task_assay_cd))
      AND (pg2.phase_group_cd= Outerjoin(proposed_pg_cd)) )
    ORDER BY pg1.phase_group_cd, pg2.phase_group_cd
    DETAIL
     IF (pg1.phase_group_cd=0.0)
      existing_superset_ind = 0
     ELSEIF (pg2.phase_group_cd=0.0)
      proposed_superset_ind = 0
     ENDIF
    WITH nocounter
   ;end select
   IF (existing_superset_ind > 0)
    RETURN(existing_pg_cd)
   ELSEIF (proposed_superset_ind > 0)
    RETURN(proposed_pg_cd)
   ENDIF
   RETURN(- (1.0))
 END ;Subroutine
 SUBROUTINE (addorupdatephasegroup(order_id=f8,phase_grp_cd=f8,flag=i2) =i2)
   RECORD requestaddupdateorderphase(
     1 order_id = f8
     1 phase_grp_cd = f8
   )
   RECORD replyaddupdateorderphase(
     1 order_phase_id = f8
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   SET requestaddupdateorderphase->order_id = order_id
   SET requestaddupdateorderphase->phase_grp_cd = phase_grp_cd
   IF (flag=1)
    EXECUTE bbt_add_order_phase  WITH replace(request,requestaddupdateorderphase), replace(reply,
     replyaddupdateorderphase)
   ELSE
    EXECUTE bbt_upd_order_phase  WITH replace(request,requestaddupdateorderphase), replace(reply,
     replyaddupdateorderphase)
   ENDIF
   IF ((bb_cache->ilogoverrideind=1))
    CALL echorecord(requestaddupdateorderphase)
    CALL echorecord(replyaddupdateorderphase)
   ENDIF
   IF ((replyaddupdateorderphase->status_data.status != "S"))
    CALL log_message("AddOrUpdatePhaseGroup - bbt_add_order_phase returned a non-success status",
     log_level_audit)
    SET reply->status_data.status = replyaddupdateorderphase->status_data.status
    FOR (i = 1 TO size(replyaddupdateorderphase->status_data.subeventstatus,5))
      CALL populate_subeventstatus_msg(replyaddupdateorderphase->status_data.subeventstatus[i].
       operationname,replyaddupdateorderphase->status_data.subeventstatus[i].operationstatus,
       replyaddupdateorderphase->status_data.subeventstatus[i].targetobjectname,
       replyaddupdateorderphase->status_data.subeventstatus[i].targetobjectvalue,log_level_audit)
    ENDFOR
    RETURN(escripterror)
   ENDIF
   SET panels->phase_group_cd = phase_grp_cd
   SET panels->order_phase_id = replyaddupdateorderphase->order_phase_id
   FREE RECORD requestaddupdateorderphase
   FREE RECORD replyaddupdateorderphase
   RETURN(estatusok)
 END ;Subroutine
 SUBROUTINE resolvetaskassays(null)
   DECLARE ncellcnt = i2 WITH protect, noconstant(0)
   DECLARE assay_list_idx = i2 WITH protect, noconstant(0)
   DECLARE nantigencnt = i2 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM (dummyt d_panel  WITH seq = value(lpanelcnt)),
     (dummyt d_cell  WITH seq = value(panels->max_cell_cnt)),
     code_value cv,
     code_value_alias cva
    PLAN (d_panel)
     JOIN (d_cell
     WHERE d_cell.seq <= size(request->panels[d_panel.seq].cells,5))
     JOIN (cva
     WHERE (cva.alias=request->panels[d_panel.seq].cells[d_cell.seq].cell_name)
      AND (cva.contributor_source_cd=panels->instrument_model_cd))
     JOIN (cv
     WHERE cva.code_value=cv.code_value
      AND cv.active_ind=1
      AND cv.code_set IN (stask_assay_cs, santigen_cs))
    ORDER BY d_panel.seq, d_cell.seq
    HEAD REPORT
     nantigencnt = 0
    HEAD d_panel.seq
     ncellcnt = 0
    HEAD d_cell.seq
     ncellcnt += 1
    DETAIL
     IF (ncellcnt > size(panels->panel[d_panel.seq].cell,5))
      istat = alterlist(panels->panel[d_panel.seq].cell,(ncellcnt+ 10))
     ENDIF
     IF (size(request->panels[d_panel.seq].cells[d_cell.seq].cell_name,1) > 0)
      IF (cv.code_set=santigen_cs)
       panels->panel[d_panel.seq].cell[ncellcnt].antigen_tested_cd = cv.code_value, panels->panel[
       d_panel.seq].cell[ncellcnt].antigen_tested_text = request->panels[d_panel.seq].cells[d_cell
       .seq].cell_name, panels->panel[d_panel.seq].cell[ncellcnt].dta_cd = 0,
       panels->panel[d_panel.seq].cell[ncellcnt].result = request->panels[d_panel.seq].cells[d_cell
       .seq].result, nantigencnt += 1
      ELSE
       panels->panel[d_panel.seq].cell[ncellcnt].cell_name = request->panels[d_panel.seq].cells[
       d_cell.seq].cell_name, panels->panel[d_panel.seq].cell[ncellcnt].dta_cd = cva.code_value,
       panels->panel[d_panel.seq].cell[ncellcnt].result = request->panels[d_panel.seq].cells[d_cell
       .seq].result
      ENDIF
      IF (size(request->panels[d_panel.seq].cells[d_cell.seq].metadata,5) != 0)
       panels->panel[d_panel.seq].cell[ncellcnt].result_note = buildresultnotefrommetadata("PANEL",
        d_cell.seq,d_panel.seq,size(request->panels[d_panel.seq].cells[d_cell.seq].metadata,5))
      ENDIF
      panels->panel[d_panel.seq].cell[ncellcnt].resource_error_codes = request->panels[d_panel.seq].
      cells[d_cell.seq].resource_error_codes
     ENDIF
    FOOT  d_panel.seq
     istat = alterlist(panels->panel[d_panel.seq].cell,ncellcnt)
    WITH nocounter
   ;end select
   IF (dorderprocesstypecd=dantigenordertypecd
    AND nantigencnt != lpanelcnt)
    CALL populate_subeventstatus_msg("LOAD","F","PANELS","No resulted antigen found",log_level_audit)
    RETURN(einvalidpanelerror)
   ENDIF
   FOR (assay_list_idx = 1 TO lpanelcnt)
    IF (size(request->panels[assay_list_idx].cells,5) != size(panels->panel[assay_list_idx].cell,5))
     CALL populate_subeventstatus_msg("LOAD","F","PANELS","Unable to find alias for cell name.",
      log_level_audit)
     RETURN(einvalidpanelerror)
    ENDIF
    IF (isassaylistsubsetofphasegroup(panels->panel[assay_list_idx].phase_group_cd,assay_list_idx)
     != 1)
     CALL populate_subeventstatus_msg("LOAD","F","PANELS",
      "Unable to result task assay. DTA may not be part of phase group.",log_level_audit)
     RETURN(einvalidpanelerror)
    ENDIF
   ENDFOR
   SET istat = error_message(1)
   IF (istat != estatusok)
    RETURN(escripterror)
   ENDIF
   RETURN(estatusok)
 END ;Subroutine
 SUBROUTINE addordercells(null)
   DECLARE panelidx = i2 WITH protect, noconstant(0)
   DECLARE i = i2 WITH protect, noconstant(0)
   DECLARE cellcnt = i2 WITH protect, noconstant(0)
   DECLARE idx = i2 WITH protect, noconstant(0)
   RECORD requestaddordercell(
     1 order_id = f8
     1 qual[*]
       2 cell_cd = f8
       2 product_id = f8
   )
   RECORD replyaddordercell(
     1 qualreply[*]
       2 cell_cd = f8
       2 product_id = f8
       2 order_cell_id = f8
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   RECORD requestpanelidx(
     1 qual[*]
       2 panelidx = i2
   )
   SET requestaddordercell->order_id = request->order_id
   FOR (panelidx = 1 TO lpanelcnt)
     IF ((panels->panel[panelidx].bb_order_cell_id=0))
      SET idx += 1
      IF (idx > size(requestpanelidx->qual,5))
       SET istat = alterlist(requestpanelidx->qual,(idx+ 10))
       SET istat = alterlist(requestaddordercell->qual,(idx+ 10))
      ENDIF
      SET requestaddordercell->qual[idx].cell_cd = panels->panel[panelidx].cell_cd
      SET requestaddordercell->qual[idx].product_id = panels->panel[panelidx].product_id
      SET requestpanelidx->qual[idx].panelidx = panelidx
      SET cellcnt += 1
     ENDIF
   ENDFOR
   SET istat = alterlist(requestpanelidx->qual,idx)
   SET istat = alterlist(requestaddordercell->qual,idx)
   IF (cellcnt > 0)
    EXECUTE bbt_add_order_cell  WITH replace(request,requestaddordercell), replace(reply,
     replyaddordercell)
    COMMIT
    IF ((bb_cache->ilogoverrideind=1))
     CALL echorecord(requestaddordercell)
     CALL echorecord(replyaddordercell)
    ENDIF
    IF ((replyaddordercell->status_data.status != "S"))
     CALL log_message("AddOrderCells - bb_order_cell returned a non-success status",log_level_audit)
     SET reply->status_data.status = replyaddordercell->status_data.status
     FOR (i = 1 TO size(replyaddordercell->status_data.subeventstatus,5))
       CALL populate_subeventstatus_msg(replyaddordercell->status_data.subeventstatus[i].
        operationname,replyaddordercell->status_data.subeventstatus[i].operationstatus,
        replyaddordercell->status_data.subeventstatus[i].targetobjectname,replyaddordercell->
        status_data.subeventstatus[i].targetobjectvalue,log_level_audit)
     ENDFOR
     RETURN(escripterror)
    ENDIF
    FOR (i = 1 TO value(size(replyaddordercell->qualreply,5)))
      SET panels->panel[requestpanelidx->qual[i].panelidx].bb_order_cell_id = replyaddordercell->
      qualreply[i].order_cell_id
    ENDFOR
   ENDIF
   FREE RECORD requestaddordercell
   FREE RECORD replyaddordercell
   FREE RECORD requestpanelidx
   RETURN(estatusok)
 END ;Subroutine
 SUBROUTINE (isassaylistsubsetofphasegroup(phase_group_cd=f8,assay_list_idx=i4) =i2)
   DECLARE assay_list_subset_ind = i2 WITH protect, noconstant(1)
   SELECT INTO "nl:"
    FROM (dummyt d_panel  WITH seq = value(size(panels->panel[assay_list_idx].cell,5))),
     discrete_task_assay dta,
     phase_group pg
    PLAN (d_panel)
     JOIN (dta
     WHERE (panels->panel[assay_list_idx].cell[d_panel.seq].dta_cd=dta.task_assay_cd)
      AND dta.task_assay_cd > 0)
     JOIN (pg
     WHERE (pg.phase_group_cd= Outerjoin(phase_group_cd))
      AND (pg.task_assay_cd= Outerjoin(dta.task_assay_cd)) )
    ORDER BY d_panel.seq
    DETAIL
     IF (pg.task_assay_cd=0)
      assay_list_subset_ind = - (1)
     ENDIF
    WITH nocounter
   ;end select
   RETURN(assay_list_subset_ind)
 END ;Subroutine
 SUBROUTINE findresultprocessingtypebyorderid(null)
   SELECT INTO "nl:"
    FROM orders o,
     service_directory sd
    PLAN (o
     WHERE (o.order_id=request->order_id))
     JOIN (sd
     WHERE sd.catalog_cd=o.catalog_cd)
    DETAIL
     dorderprocesstypecd = sd.bb_processing_cd
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE buildantigenpanels(null)
  IF (dorderprocesstypecd=dantigenordertypecd)
   IF (findantigendtasbymeaning(null) != estatusok)
    RETURN(escripterror)
   ENDIF
   CALL findpreviousantigenresults(null)
  ENDIF
  RETURN(estatusok)
 END ;Subroutine
 SUBROUTINE findantigendtasbymeaning(null)
   DECLARE flag = i2 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM orders o,
     profile_task_r ptr,
     discrete_task_assay dta,
     code_value cv
    PLAN (o
     WHERE (o.order_id=request->order_id))
     JOIN (ptr
     WHERE ptr.catalog_cd=o.catalog_cd)
     JOIN (dta
     WHERE dta.task_assay_cd=ptr.task_assay_cd)
     JOIN (cv
     WHERE cv.code_value=dta.bb_result_processing_cd
      AND cv.cdf_meaning=santigen_interp_type
      AND cv.code_set=lresult_processing_type_cs)
    DETAIL
     dantigeninterptypecd = dta.task_assay_cd
    WITH nocounter
   ;end select
   IF (curqual != 0)
    SET flag = 1
   ENDIF
   SELECT INTO "nl:"
    FROM phase_group pg,
     discrete_task_assay dta,
     code_value cv
    PLAN (pg
     WHERE (pg.phase_group_cd=panels->phase_group_cd))
     JOIN (dta
     WHERE dta.task_assay_cd=pg.task_assay_cd)
     JOIN (cv
     WHERE cv.code_value=dta.bb_result_processing_cd
      AND cv.cdf_meaning IN (santigen_reaction_type, santigen_tested_type)
      AND cv.code_set=lresult_processing_type_cs)
    DETAIL
     IF (cv.cdf_meaning=santigen_reaction_type)
      dantigenreactiontypecd = dta.task_assay_cd
     ELSE
      dantigentestedtypecd = dta.task_assay_cd
     ENDIF
    WITH nocounter
   ;end select
   IF (curqual != 0)
    SET flag = 1
   ENDIF
   IF (flag != 1)
    CALL populate_subeventstatus_msg("LOAD","F","PANELS","Unable to locate required task assays",
     log_level_audit)
    RETURN(einvalidpanelerror)
   ENDIF
   RETURN(estatusok)
 END ;Subroutine
 SUBROUTINE findpreviousantigenresults(null)
  SELECT INTO "nl:"
   FROM (dummyt d_panel  WITH seq = value(lpanelcnt)),
    (dummyt d_cell  WITH seq = value(panels->max_cell_cnt)),
    result r,
    perform_result pr,
    bb_order_cell boc
   PLAN (d_panel)
    JOIN (d_cell
    WHERE d_cell.seq <= size(panels->panel[d_panel.seq].cell,5))
    JOIN (r
    WHERE (r.order_id=request->order_id)
     AND r.task_assay_cd=dantigentestedtypecd)
    JOIN (pr
    WHERE pr.result_id=r.result_id
     AND pr.result_status_cd=r.result_status_cd
     AND (pr.result_code_set_cd=panels->panel[d_panel.seq].cell[d_cell.seq].antigen_tested_cd))
    JOIN (boc
    WHERE boc.bb_result_id=r.bb_result_id
     AND (boc.order_id=request->order_id))
   ORDER BY d_panel.seq, d_cell.seq
   HEAD REPORT
    d_panel.seq
   DETAIL
    panels->panel[d_panel.seq].bb_order_cell_id = boc.order_cell_id
   WITH nocounter
  ;end select
  RETURN(estatusok)
 END ;Subroutine
 SUBROUTINE resolveantigeninterps(null)
   DECLARE nomen_term = vc WITH protect, noconstant("")
   DECLARE ag_tested_cd = f8 WITH protect, noconstant(0.0)
   DECLARE pos_interp = i4 WITH protect, noconstant(0)
   DECLARE pos_reaction = i4 WITH protect, noconstant(0)
   DECLARE pos_tested = i4 WITH protect, noconstant(0)
   DECLARE assaycnt = i4 WITH protect, noconstant(0)
   DECLARE a_index = i4 WITH protect, noconstant(0)
   DECLARE start = i4 WITH protect, noconstant(1)
   DECLARE i = i4 WITH protect, noconstant(0)
   DECLARE j = i4 WITH protect, noconstant(0)
   FOR (i = 1 TO value(size(results->orders,5)))
    SET assaycnt = value(size(results->orders[i].assays,5))
    FOR (j = 1 TO assaycnt)
      SET cell_id = results->orders[i].assays[j].bb_order_cell_id
      SET pos_interp = locateval(a_index,start,assaycnt,dantigeninterptypecd,results->orders[i].
       assays[a_index].task_assay_cd,
       cell_id,results->orders[i].assays[a_index].bb_order_cell_id)
      IF ((results->orders[i].assays[pos_interp].bb_result_code_set_cd=0.0))
       SET pos_reaction = locateval(a_index,start,assaycnt,dantigenreactiontypecd,results->orders[i].
        assays[a_index].task_assay_cd,
        cell_id,results->orders[i].assays[a_index].bb_order_cell_id)
       SET pos_tested = locateval(a_index,start,assaycnt,dantigentestedtypecd,results->orders[i].
        assays[a_index].task_assay_cd,
        cell_id,results->orders[i].assays[a_index].bb_order_cell_id)
       SET nomen_term = cnvtcap(results->orders[i].assays[pos_reaction].nomenclature_term)
       SET ag_tested_cd = uar_get_code_by("DISPLAY",santigen_cs,nullterm(results->orders[i].assays[
         pos_tested].result_value_alpha))
       IF (ag_tested_cd != 0.0
        AND nomen_term != "")
        SET results->orders[i].assays[pos_interp].bb_result_code_set_cd = findantigeninterpcode(
         ag_tested_cd,nomen_term)
        SET results->orders[i].assays[pos_interp].result_value_alpha = uar_get_code_display(results->
         orders[i].assays[pos_interp].bb_result_code_set_cd)
       ENDIF
       SET ag_tested_cd = 0.0
       SET nomen_term = ""
      ENDIF
    ENDFOR
   ENDFOR
 END ;Subroutine
 SUBROUTINE (findantigeninterpcode(ag_tested_cd=f8,nomen_term=vc) =f8)
   DECLARE ag_interp_cd = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    FROM code_value_extension cve
    WHERE cve.code_set=santigen_cs
     AND cve.field_name IN ("Positive", "Negative")
     AND cve.field_name=trim(nomen_term)
     AND cve.code_value > 0.0
     AND cve.code_value=ag_tested_cd
    DETAIL
     ag_interp_cd = cnvtint(cve.field_value)
    WITH nocounter
   ;end select
   IF (ag_interp_cd=0.0)
    CALL populate_subeventstatus_msg("LOAD","F","PANELS",build(
      "Unable to find antigen interp code with ag_tested_cd:",ag_tested_cd,"and nomen_term:",
      nomen_term),log_level_audit)
    GO TO exit_script
   ENDIF
   RETURN(ag_interp_cd)
 END ;Subroutine
 SET donlinecodesetresulttypecd = uar_get_code_by("MEANING",lresult_type_cs,nullterm(
   sonline_codeset_res_type))
 SET dalpharesulttypecd = uar_get_code_by("MEANING",lresult_type_cs,nullterm(salpha_res_type))
 SET dinterpresulttypecd = uar_get_code_by("MEANING",lresult_type_cs,nullterm(sinterp_result_type))
 SET dalphainterptypecd = uar_get_code_by("MEANING",lbb_interp_type_cs,nullterm(salpha_interp_type))
 SET dcodesetinterptypecd = uar_get_code_by("MEANING",lbb_interp_type_cs,nullterm(
   scodeset_interp_type))
 SET dpatientaborhordertypecd = uar_get_code_by("MEANING",lbb_processing_type_cs,nullterm(
   spatient_aborh_ord_type))
 SET dantibodyscreenordertypecd = uar_get_code_by("MEANING",lbb_processing_type_cs,nullterm(
   santibody_scrn_ord_type))
 SET dcrossmatchordertypecd = uar_get_code_by("MEANING",lbb_processing_type_cs,nullterm(
   scrossmatch_ord_type))
 SET dproductaborhordertypecd = uar_get_code_by("MEANING",lbb_processing_type_cs,nullterm(
   sproduct_aborh_ord_type))
 SET dnospclprocordertypecd = uar_get_code_by("MEANING",lbb_processing_type_cs,nullterm(
   sno_spcl_proc_ord_type))
 SET dantibodyscreencompordertypecd = uar_get_code_by("MEANING",lbb_processing_type_cs,nullterm(
   santibody_scrn_comp_ord_type))
 SET drhphenotypeordertypecd = uar_get_code_by("MEANING",lbb_processing_type_cs,nullterm(
   srhphenotype_ord_type))
 SET dantibodyidordertypecd = uar_get_code_by("MEANING",lbb_processing_type_cs,nullterm(
   santibody_id_ord_type))
 SET dantigenordertypecd = uar_get_code_by("MEANING",lbb_processing_type_cs,nullterm(
   santigen_ord_type))
 SET dperformedstatuscd = uar_get_code_by("MEANING",lresult_status_cs,nullterm(
   sperformed_result_status))
 SET dsubsectiontypecd = uar_get_code_by("MEANING",lresource_grp_type_cs,nullterm(
   ssubsection_grp_type))
 SET dcancelstatuscd = uar_get_code_by("MEANING",lorder_status_cs,nullterm(scancelled_status_cdf))
 SET ddeletedstatuscd = uar_get_code_by("MEANING",lorder_status_cs,nullterm(sdeleted_status_cdf))
 SET ddiscontinuedstatuscd = uar_get_code_by("MEANING",lorder_status_cs,nullterm(
   sdiscontinued_status_cdf))
 SET dinprogressstatuscd = uar_get_code_by("MEANING",linventory_state_cs,nullterm(
   sin_progress_state_cdf))
 SET dresultnotecd = uar_get_code_by("MEANING",sresult_comment_type_cs,nullterm(sresult_note_mean))
 IF (((donlinecodesetresulttypecd <= 0.0) OR (((dalphainterptypecd <= 0.0) OR (((dcodesetinterptypecd
  <= 0.0) OR (((dalpharesulttypecd <= 0.0) OR (((dinterpresulttypecd <= 0.0) OR (((
 dpatientaborhordertypecd <= 0.0) OR (((dantibodyscreenordertypecd <= 0.0) OR (((
 dantibodyscreencompordertypecd <= 0.0) OR (((dcrossmatchordertypecd <= 0.0) OR (((
 drhphenotypeordertypecd <= 0.0) OR (((dperformedstatuscd <= 0.0) OR (((dsubsectiontypecd <= 0.0) OR
 (((dcancelstatuscd <= 0.0) OR (((ddeletedstatuscd <= 0.0) OR (((ddiscontinuedstatuscd <= 0.0) OR (((
 dproductaborhordertypecd <= 0.0) OR (((dnospclprocordertypecd <= 0.0) OR (((dinprogressstatuscd <=
 0.0) OR (((dresultnotecd <= 0.0) OR (((dantibodyidordertypecd <= 0.0) OR (dantigenordertypecd <= 0.0
 )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )
  SET iscriptstatus = escripterror
  CALL populate_subeventstatus_msg("VALIDATE","F","UAR",build(
    "At least one required code value not found : ",donlinecodesetresulttypecd,",",dalphainterptypecd,
    ",",
    dcodesetinterptypecd,",",dalpharesulttypecd,",",dinterpresulttypecd,
    ",",dpatientaborhordertypecd,",",dantibodyscreenordertypecd,",",
    dantibodyscreencompordertypecd,",",dcrossmatchordertypecd,",",drhphenotypeordertypecd,
    ",",dperformedstatuscd,",",dproductaborhordertypecd,",",
    dnospclprocordertypecd,",",dsubsectiontypecd,",",dcancelstatuscd,
    ",",ddeletedstatuscd,",",ddiscontinuedstatuscd,",",
    dinprogressstatuscd,",",dresultnotecd,",",dantibodyidordertypecd,
    ",",dantigenordertypecd),log_level_audit)
  GO TO exit_script
 ENDIF
 SET sperformedstatusdisp = uar_get_code_display(dperformedstatuscd)
 SET iscriptstatus = populatemetadatastructure(null)
 IF (iscriptstatus != estatusok)
  GO TO exit_script
 ENDIF
 IF (lpanelcnt > 0)
  SET iscriptstatus = resolvepanelinformation(null)
  IF (iscriptstatus != estatusok)
   GO TO exit_script
  ENDIF
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
 SET iscriptstatus = handlealpha(null)
 IF (iscriptstatus != estatusok)
  GO TO exit_script
 ENDIF
 IF ((bb_cache->ilogoverrideind=1))
  CALL echo("results after HandleAlpha")
  CALL echorecord(results)
 ENDIF
 IF (dorderprocesstypecd=dantigenordertypecd)
  CALL resolveantigeninterps(null)
 ENDIF
 IF ((bb_cache->ilogoverrideind=1))
  CALL echo("results after ResolveAntigenInterps")
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
#end_script
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
   DECLARE nassaycnt = i4 WITH protect, noconstant(0)
   IF (lpanelcnt != 0)
    SELECT INTO "nl:"
     FROM (dummyt d_panel  WITH seq = lpanelcnt),
      (dummyt d_cell  WITH seq = value(panels->max_cell_cnt))
     PLAN (d_panel)
      JOIN (d_cell
      WHERE d_cell.seq <= size(request->panels[d_panel.seq].cells,5))
     ORDER BY d_panel.seq, d_cell.seq
     HEAD REPORT
      nassaycnt = 0
     HEAD d_panel.seq
      row + 1
     HEAD d_cell.seq
      nassaycnt += 1
      IF (nassaycnt > size(assays->assays,5))
       istat = alterlist(assays->assays,(nassaycnt+ 10))
      ENDIF
      assays->assays[nassaycnt].result = panels->panel[d_panel.seq].cell[d_cell.seq].result, assays->
      assays[nassaycnt].resource_error_codes = panels->panel[d_panel.seq].cell[d_cell.seq].
      resource_error_codes, assays->assays[nassaycnt].result_note = panels->panel[d_panel.seq].cell[
      d_cell.seq].result_note,
      assays->assays[nassaycnt].bb_order_cell_id = panels->panel[d_panel.seq].bb_order_cell_id,
      assays->assays[nassaycnt].bb_control_cell_cd = panels->panel[d_panel.seq].cell_cd, assays->
      assays[nassaycnt].product_id = panels->panel[d_panel.seq].product_id
      IF (dorderprocesstypecd=dantigenordertypecd
       AND (panels->panel[d_panel.seq].cell[d_cell.seq].dta_cd=0))
       assays->assays[nassaycnt].task_assay_cd = dantigenreactiontypecd, nassaycnt += 2
       IF (nassaycnt > size(assays->assays,5))
        istat = alterlist(assays->assays,(nassaycnt+ 10))
       ENDIF
       assays->assays[(nassaycnt - 1)].task_assay_cd = dantigentestedtypecd, assays->assays[(
       nassaycnt - 1)].result = uar_get_code_display(panels->panel[d_panel.seq].cell[d_cell.seq].
        antigen_tested_cd), assays->assays[(nassaycnt - 1)].resource_error_codes = panels->panel[
       d_panel.seq].cell[d_cell.seq].resource_error_codes,
       assays->assays[(nassaycnt - 1)].bb_order_cell_id = panels->panel[d_panel.seq].bb_order_cell_id,
       assays->assays[(nassaycnt - 1)].bb_control_cell_cd = panels->panel[d_panel.seq].cell_cd,
       assays->assays[(nassaycnt - 1)].product_id = panels->panel[d_panel.seq].product_id,
       assays->assays[nassaycnt].task_assay_cd = dantigeninterptypecd, assays->assays[nassaycnt].
       resource_error_codes = panels->panel[d_panel.seq].cell[d_cell.seq].resource_error_codes,
       assays->assays[nassaycnt].bb_order_cell_id = panels->panel[d_panel.seq].bb_order_cell_id,
       assays->assays[nassaycnt].bb_control_cell_cd = panels->panel[d_panel.seq].cell_cd, assays->
       assays[nassaycnt].product_id = panels->panel[d_panel.seq].product_id
      ELSE
       assays->assays[nassaycnt].task_assay_cd = panels->panel[d_panel.seq].cell[d_cell.seq].dta_cd
      ENDIF
     FOOT  d_panel.seq
      istat = alterlist(assays->assays,nassaycnt)
     WITH nocounter
    ;end select
   ELSEIF ((request->order_type_flag=lpatient_order_type))
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
       IF (validate(request->assay_list[d_asy.seq].result_status_flag,- (1))=1)
        modifiedassaycounter += 1
       ENDIF
       assays->assays[nassaycnt].interface_status_flag = request->assay_list[d_asy.seq].
       result_status_flag, assays->assays[nassaycnt].task_assay_cd = request->assay_list[d_asy.seq].
       task_assay_cd, assays->assays[nassaycnt].result = request->assay_list[d_asy.seq].result,
       assays->assays[nassaycnt].product_id = 0, assays->assays[nassaycnt].resource_error_codes =
       request->assay_list[d_asy.seq].resource_error_codes, assays->assays[nassaycnt].result_note =
       buildresultnotefrommetadata("PATIENT",d_asy.seq,- (1),size(request->assay_list[d_asy.seq].
         metadata,5))
      ENDIF
     FOOT REPORT
      istat = alterlist(assays->assays,nassaycnt)
     WITH nocounter
    ;end select
   ELSEIF ((request->order_type_flag=lpatient_product_order_type))
    SELECT INTO "nl:"
     product_id = request->product_list[d_prod.seq].product_id
     FROM (dummyt d_prod  WITH seq = value(size(request->product_list,5))),
      product_event pe
     PLAN (d_prod)
      JOIN (pe
      WHERE (pe.product_id=request->product_list[d_prod.seq].product_id)
       AND (pe.order_id=request->order_id)
       AND pe.event_type_cd=dinprogressstatuscd)
     ORDER BY product_id
     HEAD REPORT
      nassaycnt = 0, nproductassaycnt = 0
     HEAD product_id
      nproductassaycnt = size(request->product_list[d_prod.seq].product_assay_list,5), istat =
      alterlist(assays->assays,(nassaycnt+ nproductassaycnt))
     DETAIL
      FOR (nassayidx = 1 TO nproductassaycnt)
        IF (trim(request->product_list[d_prod.seq].product_assay_list[nassayidx].result) != "")
         nassaycnt += 1, assays->assays[nassaycnt].product_id = request->product_list[d_prod.seq].
         product_id, assays->assays[nassaycnt].task_assay_cd = request->product_list[d_prod.seq].
         product_assay_list[nassayidx].task_assay_cd,
         assays->assays[nassaycnt].result = request->product_list[d_prod.seq].product_assay_list[
         nassayidx].result, assays->assays[nassaycnt].resource_error_codes = request->product_list[
         d_prod.seq].product_assay_list[nassayidx].resource_error_codes
         IF (pe.product_event_id > 0)
          assays->assays[nassaycnt].inprogress_event_id = pe.product_event_id, assays->assays[
          nassaycnt].prod_state_updt_cnt = pe.updt_cnt
         ENDIF
         IF (size(request->product_list[d_prod.seq].product_assay_list[nassayidx].metadata,5) != 0)
          assays->assays[nassaycnt].result_note = buildresultnotefrommetadata("PRODUCT",nassayidx,
           d_prod.seq,size(request->product_list[d_prod.seq].product_assay_list[nassayidx].metadata,5
            ))
         ENDIF
        ENDIF
      ENDFOR
     FOOT  product_id
      row + 1
     FOOT REPORT
      row + 1
     WITH nocounter
    ;end select
   ELSEIF ((request->order_type_flag=lproduct_order_type))
    SELECT INTO "nl:"
     product_id = request->product_list[d_prod.seq].product_id
     FROM (dummyt d_prod  WITH seq = value(size(request->product_list,5)))
     PLAN (d_prod)
     ORDER BY product_id
     HEAD REPORT
      nassaycnt = 0, nproductassaycnt = 0
     HEAD product_id
      nproductassaycnt = size(request->product_list[d_prod.seq].product_assay_list,5), istat =
      alterlist(assays->assays,(nassaycnt+ nproductassaycnt))
     DETAIL
      FOR (nassayidx = 1 TO nproductassaycnt)
        IF (trim(request->product_list[d_prod.seq].product_assay_list[nassayidx].result) != "")
         nassaycnt += 1, assays->assays[nassaycnt].product_id = request->product_list[d_prod.seq].
         product_id, assays->assays[nassaycnt].task_assay_cd = request->product_list[d_prod.seq].
         product_assay_list[nassayidx].task_assay_cd,
         assays->assays[nassaycnt].result = request->product_list[d_prod.seq].product_assay_list[
         nassayidx].result, assays->assays[nassaycnt].resource_error_codes = request->product_list[
         d_prod.seq].product_assay_list[nassayidx].resource_error_codes
         IF (size(request->product_list[d_prod.seq].product_assay_list[nassayidx].metadata,5) != 0)
          assays->assays[nassaycnt].result_note = buildresultnotefrommetadata("PRODUCT",nassayidx,
           d_prod.seq,size(request->product_list[d_prod.seq].product_assay_list[nassayidx].metadata,5
            ))
         ENDIF
        ENDIF
      ENDFOR
     FOOT  product_id
      row + 1
     FOOT REPORT
      row + 1
     WITH nocounter
    ;end select
   ENDIF
   SET lresultcnt = nassaycnt
   RETURN(estatusok)
 END ;Subroutine
 DECLARE validateprocedureresulttype() = i2
 SUBROUTINE validateprocedureresulttype(null)
   DECLARE iprocresvalid = i2 WITH protect, noconstant(1)
   DECLARE iordvalid = i2 WITH protect, noconstant(1)
   DECLARE ltotalassaysloaded = i4 WITH protect, noconstant(0)
   DECLARE iordercontainercnt = i2 WITH protect, noconstant(0)
   IF ((request->order_type_flag IN (lpatient_order_type, lpatient_product_order_type)))
    SELECT INTO "nl:"
     FROM order_serv_res_container osrc
     PLAN (osrc
      WHERE (osrc.order_id=request->order_id)
       AND ((osrc.status_flag+ 0) IN (1, 2)))
     ORDER BY osrc.order_id, osrc.container_id
     HEAD REPORT
      iordercontainercnt = 0, iosrcstatus = - (1)
     HEAD osrc.order_id
      iordercontainercnt += 1
      IF (iordercontainercnt > size(orders->orders,5))
       istat = alterlist(orders->orders,(iordercontainercnt+ 10))
      ENDIF
      orders->orders[iordercontainercnt].order_id = osrc.order_id, iosrcstatus = - (1)
     DETAIL
      IF ((iosrcstatus=- (1)))
       iosrcstatus = osrc.status_flag, orders->orders[iordercontainercnt].container_id = osrc
       .container_id, orders->orders[iordercontainercnt].osrc_srv_res_cd = osrc.service_resource_cd
      ELSEIF (iosrcstatus=2
       AND osrc.status_flag=1)
       iosrcstatus = osrc.status_flag, orders->orders[iordercontainercnt].container_id = osrc
       .container_id, orders->orders[iordercontainercnt].osrc_srv_res_cd = osrc.service_resource_cd
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
   ELSE
    SET istat = alterlist(orders->orders,1)
    SET iordercontainercnt = 1
    SET orders->orders[1].order_id = request->order_id
    SET orders->orders[1].container_id = 0
    SET orders->orders[1].osrc_srv_res_cd = request->service_resource_cd
   ENDIF
   SELECT INTO "nl:"
    o.order_id, result_processing_mean = uar_get_code_meaning(dta.bb_result_processing_cd)
    FROM orders o,
     (dummyt d_ord  WITH seq = value(iordercontainercnt)),
     service_directory sd,
     (dummyt d_asy  WITH seq = value(size(assays->assays,5))),
     profile_task_r ptr,
     discrete_task_assay dta,
     assay_processing_r apr,
     bb_order_phase op,
     phase_group pg,
     dummyt d1,
     dummyt d2,
     interp_task_assay ita
    PLAN (d_ord)
     JOIN (o
     WHERE (o.order_id=orders->orders[d_ord.seq].order_id))
     JOIN (sd
     WHERE sd.catalog_cd=o.catalog_cd)
     JOIN (d_asy)
     JOIN (dta
     WHERE (dta.task_assay_cd=assays->assays[d_asy.seq].task_assay_cd))
     JOIN (apr
     WHERE apr.task_assay_cd=dta.task_assay_cd
      AND (apr.service_resource_cd=request->service_resource_cd))
     JOIN (ita
     WHERE (ita.task_assay_cd= Outerjoin(apr.task_assay_cd))
      AND (ita.order_cat_cd= Outerjoin(o.catalog_cd))
      AND (ita.active_ind= Outerjoin(1)) )
     JOIN (((d1)
     JOIN (ptr
     WHERE ptr.catalog_cd=sd.catalog_cd
      AND (ptr.task_assay_cd=assays->assays[d_asy.seq].task_assay_cd)
      AND ptr.active_ind=1)
     ) ORJOIN ((d2)
     JOIN (op
     WHERE op.order_id=o.order_id)
     JOIN (pg
     WHERE pg.phase_group_cd=op.phase_grp_cd
      AND (pg.task_assay_cd=assays->assays[d_asy.seq].task_assay_cd)
      AND pg.active_ind=1)
     ))
    ORDER BY o.order_id, d_asy.seq, ita.service_resource_cd DESC
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
    HEAD d_asy.seq
     iassaycnt += 1
     IF (iassaycnt > size(results->orders[iordercnt].assays,5))
      istat = alterlist(results->orders[iordercnt].assays,(iassaycnt+ 10))
     ENDIF
     results->orders[iordercnt].assays[iassaycnt].task_assay_cd = apr.task_assay_cd, results->orders[
     iordercnt].assays[iassaycnt].result_type_cd = apr.default_result_type_cd, results->orders[
     iordercnt].assays[iassaycnt].result_value_alpha = assays->assays[d_asy.seq].result,
     results->orders[iordercnt].assays[iassaycnt].perform_dt_tm = cnvtdatetime(request->perform_dt_tm
      ), results->orders[iordercnt].assays[iassaycnt].resource_error_codes = assays->assays[d_asy.seq
     ].resource_error_codes, results->orders[iordercnt].assays[iassaycnt].interface_status_flag =
     assays->assays[d_asy.seq].interface_status_flag,
     results->orders[iordercnt].assays[iassaycnt].result_note = assays->assays[d_asy.seq].result_note,
     results->orders[iordercnt].assays[iassaycnt].bb_control_cell_cd = assays->assays[d_asy.seq].
     bb_control_cell_cd, results->orders[iordercnt].assays[iassaycnt].bb_order_cell_id = assays->
     assays[d_asy.seq].bb_order_cell_id
     IF (result_processing_mean IN (stest_phase_proc_type, shistory_upd_proc_type,
     shistory_only_proc_type)
      AND sd.bb_processing_cd=dcrossmatchordertypecd)
      results->orders[iordercnt].assays[iassaycnt].product_id = assays->assays[d_asy.seq].product_id,
      results->orders[iordercnt].assays[iassaycnt].inprogress_prod_event_id = assays->assays[d_asy
      .seq].inprogress_event_id, results->orders[iordercnt].assays[iassaycnt].prod_state_updt_cnt =
      assays->assays[d_asy.seq].prod_state_updt_cnt
     ELSE
      results->orders[iordercnt].assays[iassaycnt].product_id = 0
     ENDIF
    HEAD ita.service_resource_cd
     IF ((((ita.service_resource_cd=request->service_resource_cd)) OR (ita.service_resource_cd=0))
      AND apr.default_result_type_cd=dinterpresulttypecd)
      IF ((results->orders[iordercnt].assays[iassaycnt].interp_type_cd=0))
       results->orders[iordercnt].assays[iassaycnt].interp_type_cd = ita.interp_type_cd
      ENDIF
     ENDIF
    FOOT  ita.service_resource_cd
     row + 0
    FOOT  d_asy.seq
     IF (((((sd.bb_processing_cd=dantibodyscreenordertypecd) OR (sd.bb_processing_cd=
     dantibodyscreencompordertypecd))
      AND ((apr.default_result_type_cd=dalpharesulttypecd) OR (apr.default_result_type_cd=
     dinterpresulttypecd
      AND ita.interp_type_cd=dalphainterptypecd)) ) OR (((sd.bb_processing_cd=dcrossmatchordertypecd
      AND ((apr.default_result_type_cd=donlinecodesetresulttypecd) OR (apr.default_result_type_cd=
     dalpharesulttypecd)) ) OR (((sd.bb_processing_cd=dpatientaborhordertypecd
      AND ((apr.default_result_type_cd=donlinecodesetresulttypecd) OR (((apr.default_result_type_cd=
     dalpharesulttypecd) OR (apr.default_result_type_cd=dinterpresulttypecd
      AND ((ita.interp_type_cd=dalphainterptypecd) OR (ita.interp_type_cd=dcodesetinterptypecd)) ))
     )) ) OR (((sd.bb_processing_cd=dproductaborhordertypecd
      AND ((apr.default_result_type_cd=donlinecodesetresulttypecd) OR (((apr.default_result_type_cd=
     dalpharesulttypecd) OR (apr.default_result_type_cd=dinterpresulttypecd
      AND ((ita.interp_type_cd=dalphainterptypecd) OR (ita.interp_type_cd=dcodesetinterptypecd)) ))
     )) ) OR (((sd.bb_processing_cd IN (dnospclprocordertypecd, 0.0)
      AND ((apr.default_result_type_cd=dalpharesulttypecd) OR (apr.default_result_type_cd=
     dinterpresulttypecd
      AND ita.interp_type_cd=dalphainterptypecd)) ) OR (((sd.bb_processing_cd=dantibodyidordertypecd
      AND ((apr.default_result_type_cd=dalpharesulttypecd) OR (apr.default_result_type_cd=
     donlinecodesetresulttypecd)) ) OR (((sd.bb_processing_cd=drhphenotypeordertypecd
      AND ((apr.default_result_type_cd=dalpharesulttypecd) OR (apr.default_result_type_cd=
     dinterpresulttypecd
      AND ita.interp_type_cd=dalphainterptypecd)) ) OR (sd.bb_processing_cd=dantigenordertypecd
      AND ((apr.default_result_type_cd=donlinecodesetresulttypecd) OR (apr.default_result_type_cd=
     dalpharesulttypecd)) )) )) )) )) )) )) )) )
      IF (apr.default_result_type_cd=donlinecodesetresulttypecd)
       results->orders[iordercnt].assays[iassaycnt].code_set = apr.code_set
      ENDIF
      IF (ita.interp_type_cd=dcodesetinterptypecd
       AND apr.default_result_type_cd=dinterpresulttypecd)
       IF (sd.bb_processing_cd=dpatientaborhordertypecd)
        results->orders[iordercnt].assays[iassaycnt].code_set = lbb_aborh_type_cs
       ELSE
        results->orders[iordercnt].assays[iassaycnt].code_set = lbb_product_aborh_type_cs
       ENDIF
      ENDIF
     ELSE
      iprocresvalid = false,
      CALL populate_subeventstatus_msg("VALIDATE","F","PROC/RES TYPE",build(
       "An invalid procedure, result type was found.  OrdType : ",sd.bb_processing_cd,", ResType : ",
       apr.default_result_type_cd,", Interp_type_cd : ",
       ita.interp_type_cd),log_level_audit)
     ENDIF
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
    IF (dorderprocesstypecd != dantigenordertypecd)
     CALL populate_subeventstatus_msg("LOAD","F","ASSAYS",concat(
       "At least one assay is invalid for accession : ",request->accession),log_level_audit)
     RETURN(einvalidassayerror)
    ENDIF
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
     code_value cv,
     code_value_alias cva,
     code_value_group cvg
    PLAN (d_ord)
     JOIN (d_asy
     WHERE d_asy.seq <= size(results->orders[d_ord.seq].assays,5))
     JOIN (cv
     WHERE (cv.code_set=results->orders[d_ord.seq].assays[d_asy.seq].code_set)
      AND cv.active_ind=1
      AND (((results->orders[d_ord.seq].assays[d_asy.seq].result_type_cd=donlinecodesetresulttypecd))
      OR ((results->orders[d_ord.seq].assays[d_asy.seq].result_type_cd=dinterpresulttypecd)
      AND (results->orders[d_ord.seq].assays[d_asy.seq].interp_type_cd=dcodesetinterptypecd))) )
     JOIN (cva
     WHERE (cva.code_value= Outerjoin(cv.code_value)) )
     JOIN (cvg
     WHERE (cvg.child_code_value= Outerjoin(request->service_resource_cd))
      AND (cvg.parent_code_value= Outerjoin(cva.contributor_source_cd)) )
    ORDER BY d_ord.seq, d_asy.seq
    HEAD REPORT
     ifoundcsresult = false
    HEAD d_ord.seq
     row + 0
    HEAD d_asy.seq
     ifoundcsresult = false
    DETAIL
     IF ((((cv.display=results->orders[d_ord.seq].assays[d_asy.seq].result_value_alpha)) OR ((cva
     .alias=results->orders[d_ord.seq].assays[d_asy.seq].result_value_alpha)
      AND (cvg.child_code_value=request->service_resource_cd))) )
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
   DECLARE result_process_cd = f8 WITH private, noconstant(0.0)
   DECLARE result_meaning = vc WITH private, noconstant("")
   DECLARE lresult_flag_cs = i4 WITH private, constant(1902)
   DECLARE salpha_normal_flag = c12 WITH private, constant("ALP_NORMAL")
   DECLARE dnormalcd = f8 WITH private, constant(uar_get_code_by("MEANING",lresult_flag_cs,nullterm(
      salpha_normal_flag)))
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
       IF ((((results->orders[lordidx].assays[j].result_type_cd=dalpharesulttypecd)) OR ((results->
       orders[lordidx].assays[j].result_type_cd=dinterpresulttypecd)
        AND (results->orders[lordidx].assays[j].interp_type_cd=dalphainterptypecd))) )
        SET ifoundalpharesult = false
        SET k = 1
        WHILE (k <= size(replygetrefranges->qual[i].alpha_responses,5)
         AND ifoundalpharesult=false)
         IF (trim(results->orders[lordidx].assays[j].result_value_alpha)=trim(replygetrefranges->
          qual[i].alpha_responses[k].mnemonic))
          SET ifoundalpharesult = true
          SET results->orders[lordidx].assays[j].result_value_alpha = replygetrefranges->qual[i].
          alpha_responses[k].short_string
          SET results->orders[lordidx].assays[j].nomenclature_id = replygetrefranges->qual[i].
          alpha_responses[k].nomenclature_id
          SET results->orders[lordidx].assays[j].nomenclature_term = replygetrefranges->qual[i].
          alpha_responses[k].nomenclature_term
          SET result_process_cd = replygetrefranges->qual[i].alpha_responses[k].result_process_cd
          IF (result_process_cd > 0)
           SET result_meaning = trim(uar_get_code_meaning(result_process_cd))
           CASE (result_meaning)
            OF "ALP_REVIEW":
             SET results->orders[lordidx].assays[j].review_cd = result_process_cd
            OF "ALP_CRITICAL":
             SET results->orders[lordidx].assays[j].critical_cd = result_process_cd
            OF "ALP_ABNORMAL":
            OF "ALP_NORMAL":
            OF "ALP_UNKNOWN":
             SET results->orders[lordidx].assays[j].normal_cd = result_process_cd
           ENDCASE
          ELSE
           SET results->orders[lordidx].assays[j].normal_cd = dnormalcd
          ENDIF
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
   SELECT
    IF ((request->order_type_flag=lpatient_product_order_type))
     FROM (dummyt d_ord  WITH seq = value(size(results->orders,5))),
      (dummyt d_asy  WITH seq = value(lmaxassaycnt)),
      product_event pe,
      result r,
      perform_result pr
     PLAN (d_ord)
      JOIN (d_asy
      WHERE d_asy.seq <= size(results->orders[d_ord.seq].assays,5))
      JOIN (pe
      WHERE (pe.product_id=results->orders[d_ord.seq].assays[d_asy.seq].product_id)
       AND (pe.product_event_id=results->orders[d_ord.seq].assays[d_asy.seq].inprogress_prod_event_id
      ))
      JOIN (r
      WHERE (r.order_id=results->orders[d_ord.seq].order_id)
       AND (r.task_assay_cd=results->orders[d_ord.seq].assays[d_asy.seq].task_assay_cd)
       AND r.bb_result_id=pe.bb_result_id)
      JOIN (pr
      WHERE pr.result_id=r.result_id
       AND pr.result_status_cd=r.result_status_cd)
    ELSEIF (dorderprocesstypecd=dantigenordertypecd)
     FROM (dummyt d_ord  WITH seq = value(size(results->orders,5))),
      (dummyt d_asy  WITH seq = value(lmaxassaycnt)),
      bb_order_cell boc,
      result r,
      perform_result pr
     PLAN (d_ord)
      JOIN (d_asy
      WHERE d_asy.seq <= size(results->orders[d_ord.seq].assays,5))
      JOIN (boc
      WHERE (boc.order_cell_id=results->orders[d_ord.seq].assays[d_asy.seq].bb_order_cell_id))
      JOIN (r
      WHERE (r.order_id=results->orders[d_ord.seq].order_id)
       AND r.bb_result_id=boc.bb_result_id
       AND (r.task_assay_cd=results->orders[d_ord.seq].assays[d_asy.seq].task_assay_cd)
       AND (r.bb_control_cell_cd=results->orders[d_ord.seq].assays[d_asy.seq].bb_control_cell_cd))
      JOIN (pr
      WHERE pr.result_id=r.result_id
       AND pr.result_status_cd=r.result_status_cd)
    ELSE
     FROM (dummyt d_ord  WITH seq = value(size(results->orders,5))),
      (dummyt d_asy  WITH seq = value(lmaxassaycnt)),
      result r,
      perform_result pr
     PLAN (d_ord)
      JOIN (d_asy
      WHERE d_asy.seq <= size(results->orders[d_ord.seq].assays,5))
      JOIN (r
      WHERE (r.order_id=results->orders[d_ord.seq].order_id)
       AND (r.task_assay_cd=results->orders[d_ord.seq].assays[d_asy.seq].task_assay_cd)
       AND r.bb_control_cell_cd=0)
      JOIN (pr
      WHERE pr.result_id=r.result_id
       AND pr.result_status_cd=r.result_status_cd)
    ENDIF
    DETAIL
     IF (pr.result_status_cd=dperformedstatuscd)
      results->orders[d_ord.seq].assays[d_asy.seq].result_id = pr.result_id, results->orders[d_ord
      .seq].assays[d_asy.seq].perform_result_id = pr.perform_result_id, results->orders[d_ord.seq].
      assays[d_asy.seq].result_updt_cnt = r.updt_cnt,
      results->orders[d_ord.seq].assays[d_asy.seq].perform_result_updt_cnt = pr.updt_cnt, results->
      orders[d_ord.seq].assays[d_asy.seq].bb_result_id = r.bb_result_id
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
   DECLARE hrescomment = i4 WITH protect, noconstant(0)
   SET istat = uar_crmbeginreq(bb_cache->htask,"",lreq_nbr,hstep)
   IF (istat != estatusok)
    CALL populate_subeventstatus_msg("BEGINREQ","F",build(lreq_nbr),build(
      "Begin Request failed - return status : ",istat),log_level_audit)
    RETURN(ecrmerror)
   ENDIF
   SET hrequest = uar_crmgetrequest(hstep)
   SELECT INTO "nl:"
    dta_cd = results->orders[d_ord.seq].assays[d_asy.seq].task_assay_cd, order_id = results->orders[
    d_ord.seq].order_id, product_id = results->orders[d_ord.seq].assays[d_asy.seq].product_id,
    order_cell_id = results->orders[d_ord.seq].assays[d_asy.seq].bb_order_cell_id
    FROM (dummyt d_ord  WITH seq = value(size(results->orders,5))),
     (dummyt d_asy  WITH seq = value(lmaxassaycnt)),
     container c
    PLAN (d_ord)
     JOIN (d_asy
     WHERE d_asy.seq <= size(results->orders[d_ord.seq].assays,5))
     JOIN (c
     WHERE (c.container_id=results->orders[d_ord.seq].container_id))
    ORDER BY order_id, product_id, order_cell_id,
     dta_cd
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
     istat = uar_srvsetshort(horder,"patient_order_ind",1), nnextrowind = 1
    HEAD product_id
     nnextrowind = 1
    HEAD order_cell_id
     nnextrowind = 1
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
     istat = uar_srvsetdouble(hassay,"bb_result_id",results->orders[d_ord.seq].assays[d_asy.seq].
      bb_result_id), istat = uar_srvsetdouble(hassay,"product_id",results->orders[d_ord.seq].assays[
      d_asy.seq].product_id), istat = uar_srvsetdouble(hassay,"inprogress_prod_event_id",results->
      orders[d_ord.seq].assays[d_asy.seq].inprogress_prod_event_id),
     istat = uar_srvsetdouble(hassay,"inprogress_prod_event_id",results->orders[d_ord.seq].assays[
      d_asy.seq].inprogress_prod_event_id), istat = uar_srvsetlong(hassay,"prod_state_updt_cnt",
      results->orders[d_ord.seq].assays[d_asy.seq].prod_state_updt_cnt), istat = uar_srvsetshort(
      hassay,"perform_ind",1),
     istat = uar_srvsetdouble(hassay,"result_status_cd",dperformedstatuscd), istat = uar_srvsetstring
     (hassay,"result_status_disp",trim(sperformedstatusdisp)), istat = uar_srvsetdouble(hassay,
      "review_cd",results->orders[d_ord.seq].assays[d_asy.seq].review_cd),
     istat = uar_srvsetdouble(hassay,"critical_cd",results->orders[d_ord.seq].assays[d_asy.seq].
      critical_cd), istat = uar_srvsetdouble(hassay,"normal_cd",results->orders[d_ord.seq].assays[
      d_asy.seq].normal_cd)
     IF (nnextrowind=1)
      istat = uar_srvsetshort(hassay,"next_row_ind",1), nnextrowind = 0
     ELSE
      istat = uar_srvsetshort(hassay,"next_row_ind",0)
     ENDIF
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
     IF (modifiedassaycounter > 0)
      IF ((results->orders[d_ord.seq].assays[d_asy.seq].interface_status_flag > 0))
       istat = uar_srvsetshort(hassay,"interface_status_flag",results->orders[d_ord.seq].assays[d_asy
        .seq].interface_status_flag)
      ELSE
       istat = uar_srvsetshort(hassay,"interface_status_flag",2)
      ENDIF
     ENDIF
     istat = uar_srvsetdouble(hassay,"bb_control_cell_cd",results->orders[d_ord.seq].assays[d_asy.seq
      ].bb_control_cell_cd), istat = uar_srvsetdouble(hassay,"order_cell_id",results->orders[d_ord
      .seq].assays[d_asy.seq].bb_order_cell_id)
     IF (size(trim(results->orders[d_ord.seq].assays[d_asy.seq].result_note,7),1) > 0)
      istat = uar_srvsetlong(hassay,"result_comment_cnt",1), hrescomment = uar_srvadditem(hassay,
       "result_comment"), istat = uar_srvsetdouble(hrescomment,"comment_type_cd",dresultnotecd),
      istat = uar_srvsetstring(hrescomment,"comment_text",trim(results->orders[d_ord.seq].assays[
        d_asy.seq].result_note,7))
     ENDIF
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
 DECLARE populatemetadatastructure() = i2
 SUBROUTINE populatemetadatastructure(null)
   DECLARE nmetadatacnt = i2 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM code_value cd
    WHERE cd.code_set=lbb_metadata_cs
     AND cd.active_ind=1
    ORDER BY cd.collation_seq, cd.code_value
    HEAD REPORT
     nmetadatacnt = 0
    DETAIL
     nmetadatacnt += 1
     IF (nmetadatacnt > size(metadatas->meta_datas,5))
      istat = alterlist(metadatas->meta_datas,(nmetadatacnt+ 10))
     ENDIF
     metadatas->meta_datas[nmetadatacnt].meta_data_cd = cd.code_value, metadatas->meta_datas[
     nmetadatacnt].meta_data_disp = cd.display, metadatas->meta_datas[nmetadatacnt].
     meta_data_cdf_meaning = cd.cdf_meaning,
     metadatas->meta_datas[nmetadatacnt].meta_data_collation_seq = cd.collation_seq
     IF (cd.cdf_meaning="RESMODIFIED")
      smodifiedresultyes = concat(trim(cd.display),": ",statusyes)
     ENDIF
    FOOT  cd.code_value
     row + 0
    FOOT REPORT
     istat = alterlist(metadatas->meta_datas,nmetadatacnt)
    WITH nocounter
   ;end select
   SET istat = error_message(1)
   IF (istat != estatusok)
    RETURN(escripterror)
   ENDIF
   RETURN(estatusok)
 END ;Subroutine
 SUBROUTINE buildresultnotefrommetadata(type,assayidx,prodidx,mdsize)
   DECLARE num = i4 WITH protect, noconstant(0)
   DECLARE start = i4 WITH protect, noconstant(1)
   DECLARE index = i4 WITH protect, noconstant(1)
   DECLARE pos = i4 WITH protect, noconstant(- (1))
   DECLARE md_cs_size = i4 WITH protect, constant(size(metadatas->meta_datas,5))
   DECLARE result_note = vc WITH public, noconstant(" ")
   DECLARE crlf = vc WITH noconstant(concat(char(13),char(10)))
   IF (type="PATIENT")
    IF (mdsize > 0)
     WHILE (index <= md_cs_size)
       SET pos = locateval(num,start,mdsize,metadatas->meta_datas[index].meta_data_cd,request->
        assay_list[assayidx].metadata[num].metadata_cd)
       IF (pos > 0)
        SET result_note = build(result_note,metadatas->meta_datas[index].meta_data_disp,": ",request
         ->assay_list[assayidx].metadata[pos].text,crlf)
       ELSEIF ((request->assay_list[assayidx].result_status_flag=1)
        AND (metadatas->meta_datas[index].meta_data_cdf_meaning="RESMODIFIED"))
        SET result_note = build(result_note,metadatas->meta_datas[index].meta_data_disp,": ",
         statusyes,crlf)
       ENDIF
       SET index += 1
     ENDWHILE
    ELSEIF ((request->assay_list[assayidx].result_status_flag=1))
     SET result_note = build(smodifiedresultyes,crlf)
    ENDIF
   ELSEIF (type="PRODUCT")
    WHILE (index <= md_cs_size)
      SET pos = locateval(num,start,mdsize,metadatas->meta_datas[index].meta_data_cd,request->
       product_list[prodidx].product_assay_list[assayidx].metadata[num].metadata_cd)
      IF (pos > 0)
       SET result_note = build(result_note,metadatas->meta_datas[index].meta_data_disp,": ",request->
        product_list[prodidx].product_assay_list[assayidx].metadata[pos].text,crlf)
      ENDIF
      SET index += 1
    ENDWHILE
   ELSEIF (type="PANEL")
    WHILE (index <= md_cs_size)
      SET pos = locateval(num,start,mdsize,metadatas->meta_datas[index].meta_data_cd,request->panels[
       prodidx].cells[assayidx].metadata[num].metadata_cd)
      IF (pos > 0)
       SET result_note = build(result_note,metadatas->meta_datas[index].meta_data_disp,": ",request->
        panels[prodidx].cells[assayidx].metadata[pos].text,crlf)
      ENDIF
      SET index += 1
    ENDWHILE
   ENDIF
   RETURN(nullterm(result_note))
 END ;Subroutine
 DECLARE cleanup() = null
 SUBROUTINE cleanup(null)
   IF (iscriptstatus != estatusok)
    SET reply->status = "F"
    CALL populate_subeventstatus_msg("SCRIPT","F","BBT_UPD_MDI_RESULTS",build(
      "Script failure.  Status: ",iscriptstatus),log_level_audit)
   ELSE
    SET reply->status = "S"
   ENDIF
   FREE RECORD orders
   FREE RECORD assays
   FREE RECORD results
   FREE RECORD metadatas
   FREE RECORD panels
   CALL uar_sysdestroyhandle(hsys)
 END ;Subroutine
END GO
