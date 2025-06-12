CREATE PROGRAM cp_get_printable_activity:dba
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
 SET log_program_name = "CP_GET_PRINTABLE_ACTIVITY"
 IF (validate(request) != 1)
  FREE RECORD request
  RECORD request(
    1 chart_format_id = f8
    1 chart_section_id = f8
    1 section_type_flag = i2
    1 activity[*]
      2 chart_section_id = f8
      2 section_seq = i4
      2 section_type_flag = i2
      2 chart_group_id = f8
      2 group_seq = i4
      2 zone = i4
      2 flex_type_flag = i2
      2 doc_type_flag = i2
      2 procedure_seq = i4
      2 procedure_type_flag = i2
      2 event_set_name = vc
      2 dcp_forms_ref_id = f8
      2 catalog_cd = f8
      2 event_cds[*]
        3 event_cd = f8
        3 task_assay_cd = f8
        3 suppressed_ind = i2
    1 parent_event_ids[*]
      2 parent_event_id = f8
    1 inerr_events[*]
      2 event_id = f8
  )
 ENDIF
 IF (validate(reply) != 1)
  FREE RECORD reply
  RECORD reply(
    1 activity[*]
      2 chart_section_id = f8
      2 section_seq = i4
      2 section_type_flag = i2
      2 chart_group_id = f8
      2 group_seq = i4
      2 zone = i4
      2 flex_type_flag = i2
      2 doc_type_flag = i2
      2 procedure_seq = i4
      2 procedure_type_flag = i2
      2 event_set_name = vc
      2 dcp_forms_ref_id = f8
      2 catalog_cd = f8
      2 event_cds[*]
        3 event_cd = f8
        3 task_assay_cd = f8
        3 suppressed_ind = i2
    1 parent_event_ids[*]
      2 parent_event_id = f8
    1 inerr_events[*]
      2 event_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE idx = i4 WITH noconstant(0)
 DECLARE idx2 = i4 WITH noconstant(0)
 DECLARE idxstart = i4 WITH noconstant(1)
 DECLARE noptimizedtotal = i4 WITH noconstant(0)
 DECLARE nrecordsize = i4 WITH noconstant(0)
 DECLARE bind_cnt = i4 WITH constant(50), protect
 DECLARE parser_clause = vc WITH noconstant("")
 DECLARE doc_parser_clause = vc WITH noconstant("")
 DECLARE flexible_section = i2 WITH constant(6)
 DECLARE getprintableitems(null) = null
 DECLARE buildparserclause(null) = null
 DECLARE optimizerequest(null) = null
 DECLARE explodeeventsets(null) = null
 DECLARE explodecatalogcodes(null) = null
 DECLARE findsuppresseddtas(null) = null
 DECLARE formatreply(null) = null
 CALL log_message("Enter script: cp_get_printable_activity",log_level_debug)
 SET reply->status_data.status = "F"
 CALL buildparserclause(null)
 IF (size(request->activity,5)=0)
  CALL getprintableitems(null)
 ENDIF
 CALL optimizerequest(null)
 CALL explodeeventsets(null)
 CALL explodecatalogcodes(null)
 SET stat = alterlist(request->activity,nrecordsize)
 CALL findsuppresseddtas(null)
 CALL formatreply(null)
 SET reply->status_data.status = "S"
 SUBROUTINE getprintableitems(null)
  SELECT DISTINCT INTO "nl:"
   FROM chart_form_sects cfs,
    chart_section cs,
    chart_group cg,
    chart_grp_evnt_set cges,
    chart_flex_format cff,
    chart_doc_format cdf
   PLAN (cfs
    WHERE parser(parser_clause))
    JOIN (cs
    WHERE parser(doc_parser_clause))
    JOIN (cg
    WHERE cg.chart_section_id=cs.chart_section_id)
    JOIN (cges
    WHERE cges.chart_group_id=cg.chart_group_id)
    JOIN (cff
    WHERE (cff.chart_group_id= Outerjoin(cg.chart_group_id)) )
    JOIN (cdf
    WHERE (cdf.chart_group_id= Outerjoin(cg.chart_group_id)) )
   ORDER BY cfs.cs_sequence_num, cg.cg_sequence, cges.zone,
    cges.event_set_seq
   HEAD REPORT
    activity_cnt = 0
   DETAIL
    activity_cnt += 1
    IF (mod(activity_cnt,10)=1)
     stat = alterlist(request->activity,(activity_cnt+ 9))
    ENDIF
    request->activity[activity_cnt].chart_section_id = cs.chart_section_id, request->activity[
    activity_cnt].section_seq = cfs.cs_sequence_num, request->activity[activity_cnt].
    section_type_flag = cs.section_type_flag,
    request->activity[activity_cnt].chart_group_id = cg.chart_group_id, request->activity[
    activity_cnt].group_seq = cg.cg_sequence, request->activity[activity_cnt].zone = cges.zone,
    request->activity[activity_cnt].flex_type_flag = cff.flex_type, request->activity[activity_cnt].
    doc_type_flag = cdf.doc_type_flag, request->activity[activity_cnt].procedure_seq = cges
    .event_set_seq,
    request->activity[activity_cnt].procedure_type_flag = cges.procedure_type_flag, request->
    activity[activity_cnt].event_set_name = cges.event_set_name, request->activity[activity_cnt].
    catalog_cd = cges.order_catalog_cd
   FOOT REPORT
    stat = alterlist(request->activity,activity_cnt)
   WITH nocounter
  ;end select
  CALL error_and_zero_check(curqual,"GetPrintableItems","GetPrintableItems",1,1)
 END ;Subroutine
 SUBROUTINE buildparserclause(null)
  IF ((request->chart_section_id > 0))
   SET parser_clause = build("cfs.chart_section_id = ",request->chart_section_id)
  ELSE
   SET parser_clause = build("cfs.chart_format_id = ",request->chart_format_id)
  ENDIF
  IF ((request->chart_section_id=0)
   AND (request->section_type_flag=25))
   SET doc_parser_clause = build(
    "cs.chart_section_id = cfs.chart_section_id and cs.section_type_flag = 25")
  ELSE
   SET doc_parser_clause = build("cs.chart_section_id = cfs.chart_section_id")
  ENDIF
 END ;Subroutine
 SUBROUTINE optimizerequest(null)
   SET nrecordsize = size(request->activity,5)
   SET noptimizedtotal = (ceil((cnvtreal(nrecordsize)/ bind_cnt)) * bind_cnt)
   SET stat = alterlist(request->activity,noptimizedtotal)
   FOR (i = (nrecordsize+ 1) TO noptimizedtotal)
    SET request->activity[i].event_set_name = request->activity[nrecordsize].event_set_name
    SET request->activity[i].catalog_cd = request->activity[nrecordsize].catalog_cd
   ENDFOR
 END ;Subroutine
 SUBROUTINE explodeeventsets(null)
   SET idx = 0
   SET idx2 = 0
   SET idxstart = 1
   SELECT DISTINCT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     v500_event_set_code esc,
     v500_event_set_explode ese
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (esc
     WHERE expand(idx,idxstart,((idxstart+ bind_cnt) - 1),esc.event_set_name,request->activity[idx].
      event_set_name,
      bind_cnt)
      AND esc.event_set_name > "")
     JOIN (ese
     WHERE ese.event_set_cd=esc.event_set_cd)
    ORDER BY esc.event_set_name, ese.event_cd
    HEAD esc.event_set_name
     event_code_cnt = 0
    DETAIL
     event_code_cnt += 1, locval = locateval(idx2,1,nrecordsize,esc.event_set_name,request->activity[
      idx2].event_set_name)
     WHILE (locval != 0)
       stat = alterlist(request->activity[locval].event_cds,event_code_cnt), request->activity[locval
       ].event_cds[event_code_cnt].event_cd = ese.event_cd, locval = locateval(idx2,(locval+ 1),
        nrecordsize,esc.event_set_name,request->activity[idx2].event_set_name)
     ENDWHILE
    FOOT  esc.event_set_name
     do_nothing = 0
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"ExplodeEventSets","ExplodeEventSets",1,0)
 END ;Subroutine
 SUBROUTINE explodecatalogcodes(null)
   SET idx = 0
   SET idx2 = 0
   SET idxstart = 1
   SELECT DISTINCT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     profile_task_r p,
     code_value_event_r cver
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (p
     WHERE expand(idx,idxstart,((idxstart+ bind_cnt) - 1),p.catalog_cd,request->activity[idx].
      catalog_cd,
      bind_cnt)
      AND p.catalog_cd > 0
      AND p.active_ind=1
      AND p.beg_effective_dt_tm < cnvtdatetime(sysdate)
      AND p.end_effective_dt_tm >= cnvtdatetime(sysdate))
     JOIN (cver
     WHERE ((cver.parent_cd=p.task_assay_cd) OR (cver.parent_cd=p.catalog_cd)) )
    ORDER BY p.catalog_cd, cver.event_cd
    HEAD p.catalog_cd
     event_code_cnt = 0
    DETAIL
     event_code_cnt += 1, locval = locateval(idx2,1,nrecordsize,p.catalog_cd,request->activity[idx2].
      catalog_cd)
     WHILE (locval != 0)
       stat = alterlist(request->activity[locval].event_cds,event_code_cnt), request->activity[locval
       ].event_cds[event_code_cnt].event_cd = cver.event_cd, request->activity[locval].event_cds[
       event_code_cnt].task_assay_cd = cver.parent_cd,
       locval = locateval(idx2,(locval+ 1),nrecordsize,p.catalog_cd,request->activity[idx2].
        catalog_cd)
     ENDWHILE
    FOOT  p.catalog_cd
     do_nothing = 0
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"ExplodeCatalogCodes","ExplodeCatalogCodes",1,0)
 END ;Subroutine
 SUBROUTINE findsuppresseddtas(null)
   SET idx = 0
   SET idx2 = 0
   SET idxstart = 1
   SELECT DISTINCT INTO "nl:"
    FROM chart_form_sects cfs,
     chart_section cs,
     chart_group cg,
     chart_grp_evnt_suppress cgesp
    PLAN (cfs
     WHERE parser(parser_clause))
     JOIN (cs
     WHERE cs.chart_section_id=cfs.chart_section_id)
     JOIN (cg
     WHERE cg.chart_section_id=cs.chart_section_id)
     JOIN (cgesp
     WHERE cgesp.chart_group_id=cg.chart_group_id)
    DETAIL
     locval = locateval(idx,1,nrecordsize,cgesp.order_catalog_cd,request->activity[idx].catalog_cd)
     WHILE (locval != 0)
       locval2 = locateval(idx2,1,size(request->activity[locval].event_cds,5),cgesp.task_assay_cd,
        request->activity[locval].event_cds[idx2].task_assay_cd)
       IF ((request->activity[locval].chart_group_id=cgesp.chart_group_id))
        request->activity[locval].event_cds[locval2].suppressed_ind = 1
       ENDIF
       locval = locateval(idx,(locval+ 1),nrecordsize,cgesp.order_catalog_cd,request->activity[idx].
        catalog_cd)
     ENDWHILE
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"FindSuppressedDTAs","FindSuppressedDTAs",1,0)
 END ;Subroutine
 SUBROUTINE formatreply(null)
   DECLARE bbproduct_cd = f8 WITH noconstant(uar_get_code_by("DISPLAYKEY",72,"BBPRODUCT")), protect
   DECLARE temp_bbproduct_cd = f8 WITH noconstant(bbproduct_cd), protect
   DECLARE previoussectionid = f8 WITH noconstant(0.0), protect
   SET stat = alterlist(reply->activity,nrecordsize)
   FOR (i = 1 TO nrecordsize)
     IF ((previoussectionid != request->activity[i].chart_section_id))
      SET temp_bbproduct_cd = bbproduct_cd
     ENDIF
     SET reply->activity[i].chart_section_id = request->activity[i].chart_section_id
     SET reply->activity[i].section_seq = request->activity[i].section_seq
     SET reply->activity[i].section_type_flag = request->activity[i].section_type_flag
     SET reply->activity[i].chart_group_id = request->activity[i].chart_group_id
     SET reply->activity[i].group_seq = request->activity[i].group_seq
     SET reply->activity[i].zone = request->activity[i].zone
     SET reply->activity[i].flex_type_flag = request->activity[i].flex_type_flag
     SET reply->activity[i].doc_type_flag = request->activity[i].doc_type_flag
     SET reply->activity[i].procedure_seq = request->activity[i].procedure_seq
     SET reply->activity[i].procedure_type_flag = request->activity[i].procedure_type_flag
     SET reply->activity[i].event_set_name = request->activity[i].event_set_name
     SET reply->activity[i].catalog_cd = request->activity[i].catalog_cd
     SET stat = alterlist(reply->activity[i].event_cds,size(request->activity[i].event_cds,5))
     FOR (j = 1 TO size(request->activity[i].event_cds,5))
      IF ((request->activity[i].event_cds[j].suppressed_ind != 1))
       SET reply->activity[i].event_cds[j].event_cd = request->activity[i].event_cds[j].event_cd
       SET reply->activity[i].event_cds[j].task_assay_cd = request->activity[i].event_cds[j].
       task_assay_cd
      ENDIF
      IF ((reply->activity[i].section_type_flag=flexible_section)
       AND (reply->activity[i].flex_type_flag=0))
       IF ((reply->activity[i].catalog_cd=0))
        SET reply->activity[i].event_cds[j].event_cd = temp_bbproduct_cd
        SET temp_bbproduct_cd = 0
       ELSE
        SET reply->activity[i].event_cds[j].event_cd = bbproduct_cd
       ENDIF
      ENDIF
     ENDFOR
     SET previoussectionid = request->activity[i].chart_section_id
   ENDFOR
   CALL error_and_zero_check(1,"FormatReply","FormatReply",1,0)
 END ;Subroutine
#exit_script
 CALL log_message("Exit script: cp_get_printable_activity",log_level_debug)
END GO
