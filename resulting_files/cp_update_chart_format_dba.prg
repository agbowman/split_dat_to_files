CREATE PROGRAM cp_update_chart_format:dba
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
 SET log_program_name = "CP_UPDATE_CHART_FORMAT"
 DECLARE xencntr_section_type = i4 WITH constant(4)
 DECLARE flex_section_type = i4 WITH constant(6)
 DECLARE horz_section_type = i4 WITH constant(9)
 DECLARE mic_section_type = i4 WITH constant(10)
 DECLARE ord_sum_section_type = i4 WITH constant(11)
 DECLARE rad_section_type = i4 WITH constant(14)
 DECLARE vert_section_type = i4 WITH constant(16)
 DECLARE zonal_old_section_type = i4 WITH constant(17)
 DECLARE ap_section_type = i4 WITH constant(18)
 DECLARE pwrfrm_section_type = i4 WITH constant(21)
 DECLARE hla_section_type = i4 WITH constant(22)
 DECLARE doc_section_type = i4 WITH constant(25)
 DECLARE lab_text_section_type = i4 WITH constant(27)
 DECLARE ppr_section_type = i4 WITH constant(28)
 DECLARE visit_list_section_type = i4 WITH constant(29)
 DECLARE allergy_section_type = i4 WITH constant(30)
 DECLARE prob_list_section_type = i4 WITH constant(31)
 DECLARE zonal_new_section_type = i4 WITH constant(32)
 DECLARE orders_section_type = i4 WITH constant(33)
 DECLARE mar_section_type = i4 WITH constant(34)
 DECLARE name_hist_section_type = i4 WITH constant(35)
 DECLARE facesheet_section_type = i4 WITH constant(36)
 DECLARE immun_section_type = i4 WITH constant(37)
 DECLARE proc_hist_section_type = i4 WITH constant(38)
 DECLARE mar2_section_type = i4 WITH constant(41)
 DECLARE io_section_type = i4 WITH constant(42)
 DECLARE med_prof_hist_section_type = i4 WITH constant(43)
 DECLARE user_defined_section_type = i4 WITH constant(44)
 DECLARE listview_section_type = i4 WITH constant(45)
 DECLARE getnextchartformatid(null) = f8
 DECLARE getnextchartsectionid(null) = f8
 DECLARE getnextchartgroupid(null) = f8
 DECLARE getnextchartlistviewformatid(null) = f8
 DECLARE getnextlongdataseq(null) = f8
 DECLARE insertenhancedlayoutxml(null) = f8
 DECLARE updateenhancedlayoutxml(null) = null
 DECLARE insertresubmitdisclaimer(null) = f8
 DECLARE buildreplystructure(null) = null
 DECLARE insertformat(null) = null
 DECLARE updateformat(null) = null
 DECLARE add_facesheet_section(null) = null
 DECLARE update_facesheet_section(null) = null
 DECLARE delete_facesheet_section(null) = null
 SUBROUTINE getnextchartformatid(null)
   CALL log_message("In GetNextChartFormatId()",log_level_debug)
   DECLARE returnval = f8 WITH noconstant(0.0), protect
   SELECT INTO "nl:"
    nextseqnum = seq(reference_seq,nextval)"######################;rp0"
    FROM dual
    DETAIL
     returnval = nextseqnum
    WITH format, nocounter
   ;end select
   CALL error_and_zero_check(curqual,"DUAL","GETNEXTCHARTFORMATID",1,1)
   RETURN(returnval)
 END ;Subroutine
 SUBROUTINE getnextchartsectionid(null)
   CALL log_message("In GetNextChartSectionId()",log_level_debug)
   DECLARE returnval = f8 WITH noconstant(0.0)
   SELECT INTO "nl:"
    nextseqnum = seq(reference_seq,nextval)"######################;rp0"
    FROM dual
    DETAIL
     returnval = nextseqnum
    WITH format, nocounter
   ;end select
   CALL error_and_zero_check(curqual,"DUAL","GETNEXTCHARTSECTIONID",1,1)
   RETURN(returnval)
 END ;Subroutine
 SUBROUTINE getnextchartgroupid(null)
   CALL log_message("In GetNextChartGroupId()",log_level_debug)
   DECLARE returnval = f8 WITH noconstant(0.0)
   SELECT INTO "nl:"
    nextseqnum = seq(reference_seq,nextval)"######################;rp0"
    FROM dual
    DETAIL
     returnval = nextseqnum
    WITH format, nocounter
   ;end select
   CALL error_and_zero_check(curqual,"DUAL","GETNEXTCHARTGROUPID",1,1)
   RETURN(returnval)
 END ;Subroutine
 SUBROUTINE getnextlongdataseq(null)
   CALL log_message("In GetNextLongDataSeq()",log_level_debug)
   DECLARE returnval = f8 WITH noconstant(0.0)
   SELECT INTO "nl:"
    nextseqnum = seq(long_data_seq,nextval)"######################;rp0"
    FROM dual
    DETAIL
     returnval = nextseqnum
    WITH format, nocounter
   ;end select
   CALL error_and_zero_check(curqual,"DUAL","GETNEXTLONGDATASEQ",1,1)
   RETURN(returnval)
 END ;Subroutine
 SUBROUTINE getnextchartlistviewformatid(null)
   CALL log_message("In GetNextChartListviewSectionId()",log_level_debug)
   DECLARE returnval = f8 WITH noconstant(0.0)
   SELECT INTO "nl:"
    nextseqnum = seq(reference_seq,nextval)"######################;rp0"
    FROM dual
    DETAIL
     returnval = nextseqnum
    WITH format, nocounter
   ;end select
   CALL error_and_zero_check(curqual,"DUAL","GETNEXTCHARTLISTVIEWSECTIONID",1,1)
   RETURN(returnval)
 END ;Subroutine
 SUBROUTINE insertenhancedlayoutxml(null)
   CALL log_message("In InsertEnhancedLayoutXML()",log_level_debug)
   DECLARE returnval = f8 WITH noconstant(0.0), protect
   SET returnval = getnextlongdataseq(null)
   INSERT  FROM long_text_reference ltr
    SET ltr.long_text_id = returnval, ltr.long_text = request->enhanced_layout_xml, ltr
     .parent_entity_id = request->chart_format_id,
     ltr.parent_entity_name = "ChartFormatEnhancedLayoutXML", ltr.active_ind = 1, ltr
     .active_status_cd = reqdata->active_status_cd,
     ltr.active_status_dt_tm = cnvtdatetime(sysdate), ltr.active_status_prsnl_id = reqinfo->updt_id,
     ltr.updt_cnt = 0,
     ltr.updt_dt_tm = cnvtdatetime(sysdate), ltr.updt_id = reqinfo->updt_id, ltr.updt_task = reqinfo
     ->updt_task,
     ltr.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   CALL error_and_zero_check(curqual,"LONG_TEXT_REFERENCE","InsertEnhancedLayoutXML",1,1)
   RETURN(returnval)
 END ;Subroutine
 SUBROUTINE updateenhancedlayoutxml(null)
   CALL log_message("In UpdateEnhancedLayoutXML()",log_level_debug)
   UPDATE  FROM long_text_reference ltr
    SET ltr.long_text = request->enhanced_layout_xml, ltr.updt_cnt = (ltr.updt_cnt+ 1), ltr
     .updt_dt_tm = cnvtdatetime(sysdate),
     ltr.updt_id = reqinfo->updt_id, ltr.updt_task = reqinfo->updt_task, ltr.updt_applctx = reqinfo->
     updt_applctx
    WHERE (ltr.parent_entity_id=request->chart_format_id)
     AND ltr.parent_entity_name="ChartFormatEnhancedLayoutXML"
    WITH nocounter
   ;end update
   CALL error_and_zero_check(curqual,"LONG_TEXT_REFERENCE","UpdateEnhancedLayoutXML",1,1)
 END ;Subroutine
 SUBROUTINE insertresubmitdisclaimer(null)
   CALL log_message("In InsertResubmitDisclaimer()",log_level_debug)
   DECLARE returnval = f8 WITH noconstant(0.0), protect
   SET returnval = getnextlongdataseq(null)
   INSERT  FROM long_text lt
    SET lt.long_text_id = returnval, lt.long_text = request->resubmit_disclaimer, lt.parent_entity_id
      = request->chart_format_id,
     lt.parent_entity_name = "CHART FORMAT", lt.active_ind = 1, lt.active_status_cd = reqdata->
     active_status_cd,
     lt.active_status_dt_tm = cnvtdatetime(sysdate), lt.active_status_prsnl_id = reqinfo->updt_id, lt
     .updt_cnt = 0,
     lt.updt_dt_tm = cnvtdatetime(sysdate), lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->
     updt_task,
     lt.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   CALL error_and_zero_check(curqual,"LONG_TEXT","INSERTRESUBMITDISCLAIMER",1,1)
   RETURN(returnval)
 END ;Subroutine
 SUBROUTINE (updateresubmitdisclaimer(resubmitdisclaimerid=f8(val)) =null)
   CALL log_message("In UpdateResubmitDisclaimer()",log_level_debug)
   UPDATE  FROM long_text lt
    SET lt.long_text = request->resubmit_disclaimer, lt.updt_cnt = (lt.updt_cnt+ 1), lt.updt_dt_tm =
     cnvtdatetime(sysdate),
     lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->
     updt_applctx
    WHERE lt.long_text_id=resubmitdisclaimerid
     AND (lt.parent_entity_id=request->chart_format_id)
    WITH nocounter
   ;end update
   CALL error_and_zero_check(curqual,"LONG_TEXT","UPDATERESUBMITDISCLAIMER",1,1)
 END ;Subroutine
 SUBROUTINE (deleteresubmitdisclaimer(resubmitdisclaimerid=f8(val)) =null)
   CALL log_message("In DeleteResubmitDisclaimer()",log_level_debug)
   DELETE  FROM long_text lt
    WHERE lt.long_text_id=resubmitdisclaimerid
     AND (lt.parent_entity_id=request->chart_format_id)
    WITH nocounter
   ;end delete
   CALL error_and_zero_check(curqual,"LONG_TEXT","DELETERESUBMITDISCLAIMER",1,0)
 END ;Subroutine
 SUBROUTINE buildreplystructure(null)
   CALL log_message("In BuildReplyStructure()",log_level_debug)
   DECLARE stat = i4 WITH noconstant(0), protect
   DECLARE x = i4 WITH noconstant(0), protect
   SET stat = alterlist(reply->chart_section_list,request->chart_section_count)
   FOR (x = 1 TO request->chart_section_count)
     SET stat = alterlist(reply->chart_section_list[x].chart_group_list,request->chart_section_list[x
      ].chart_group_count)
   ENDFOR
 END ;Subroutine
 SUBROUTINE (insertchartsection(index=i4(val)) =f8)
   CALL log_message("In InsertChartSection()",log_level_debug)
   DECLARE x = i4 WITH noconstant(0), protect
   DECLARE next_chart_section_seq = f8 WITH noconstant(0.0), protect
   SET next_chart_section_seq = getnextchartsectionid(null)
   SET request->chart_section_list[index].chart_section_id = next_chart_section_seq
   SET reply->chart_section_list[index].chart_section_id = next_chart_section_seq
   INSERT  FROM chart_section cs
    SET cs.chart_section_id = next_chart_section_seq, cs.chart_section_desc = request->
     chart_section_list[index].chart_section_desc, cs.section_type_flag = request->
     chart_section_list[index].section_type_flag,
     cs.sect_page_brk_ind = request->chart_section_list[index].sect_page_brk_ind, cs.active_ind = 1,
     cs.active_status_cd = reqdata->active_status_cd,
     cs.active_status_dt_tm = cnvtdatetime(sysdate), cs.active_status_prsnl_id = reqinfo->updt_id, cs
     .updt_cnt = 0,
     cs.updt_dt_tm = cnvtdatetime(sysdate), cs.updt_id = reqinfo->updt_id, cs.updt_task = reqinfo->
     updt_task,
     cs.updt_applctx = reqinfo->updt_applctx, cs.unique_ident = concat(trim(cnvtstring(
        next_chart_section_seq,30,0,"R"),3)," ",trim(format(curdate,"DD-MMM-YYYY;;D"),3)," ",trim(
       format(curtime3,";3;M"),3))
    WITH nocounter
   ;end insert
   CALL error_and_zero_check(curqual,"CHART_SECTION","INSERTCHARTSECTION",1,1)
   FOR (x = 1 TO request->chart_section_list[index].chart_group_count)
     CALL insertchartgroup(index,x)
   ENDFOR
 END ;Subroutine
 SUBROUTINE (insertchartformsects(secindex=i4(val)) =null)
   CALL log_message("In InsertChartFormSects()",log_level_debug)
   INSERT  FROM chart_form_sects cfs
    SET cfs.chart_format_id = request->chart_format_id, cfs.chart_section_id = request->
     chart_section_list[secindex].chart_section_id, cfs.cs_sequence_num = secindex,
     cfs.active_ind = 1, cfs.active_status_cd = reqdata->active_status_cd, cfs.active_status_dt_tm =
     cnvtdatetime(sysdate),
     cfs.active_status_prsnl_id = reqinfo->updt_id, cfs.updt_cnt = 0, cfs.updt_dt_tm = cnvtdatetime(
      sysdate),
     cfs.updt_id = reqinfo->updt_id, cfs.updt_task = reqinfo->updt_task, cfs.updt_applctx = reqinfo->
     updt_applctx
    WITH nocounter
   ;end insert
   CALL error_and_zero_check(curqual,"CHART_FORM_SECTS","INSERTCHARTFORMSECTS",1,1)
 END ;Subroutine
 SUBROUTINE (insertchartsectionfields(index=i4(val)) =null)
  CALL log_message("In InsertChartSectionFields()",log_level_debug)
  CASE (request->chart_section_list[index].section_type_flag)
   OF rad_section_type:
   OF ap_section_type:
   OF doc_section_type:
   OF lab_text_section_type:
    SET secfldcount = size(request->chart_section_list[index].sect_field_list,5)
    IF (secfldcount > 0)
     INSERT  FROM chart_sect_flds csf,
       (dummyt d  WITH seq = value(secfldcount))
      SET csf.seq = 1, csf.chart_section_id = request->chart_section_list[index].chart_section_id,
       csf.field_seq = d.seq,
       csf.field_id = request->chart_section_list[index].sect_field_list[d.seq].field_id, csf
       .field_row = request->chart_section_list[index].sect_field_list[d.seq].field_row, csf
       .active_ind = 1,
       csf.active_status_cd = reqdata->active_status_cd, csf.updt_cnt = 0, csf.updt_dt_tm =
       cnvtdatetime(curdate,curtime),
       csf.updt_id = reqinfo->updt_id, csf.updt_applctx = reqinfo->updt_applctx, csf.updt_task =
       reqinfo->updt_task
      PLAN (d)
       JOIN (csf)
      WITH nocounter
     ;end insert
     CALL error_and_zero_check(curqual,"CHART_SECT_FLDS","INSERTCHARTSECTIONFIELDS",1,1)
    ENDIF
  ENDCASE
 END ;Subroutine
 SUBROUTINE (insertchartgroup(secindex=i4(val),grpindex=i4(val)) =null)
   CALL log_message("In InsertChartGroup()",log_level_debug)
   DECLARE chart_group_next_seq = f8 WITH noconstant(0.0), protect
   SET chart_group_next_seq = getnextchartgroupid(null)
   SET request->chart_section_list[secindex].chart_group_list[grpindex].chart_group_id =
   chart_group_next_seq
   SET reply->chart_section_list[secindex].chart_group_list[grpindex].chart_group_id =
   chart_group_next_seq
   INSERT  FROM chart_group cg
    SET cg.chart_group_id = chart_group_next_seq, cg.chart_section_id = request->chart_section_list[
     secindex].chart_section_id, cg.chart_group_desc = request->chart_section_list[secindex].
     chart_group_list[grpindex].chart_group_desc,
     cg.enhanced_layout_ind = request->chart_section_list[secindex].chart_group_list[grpindex].
     enhanced_layout_ind, cg.cg_sequence = grpindex, cg.max_results = validate(request->
      chart_section_list[secindex].chart_group_list[grpindex].max_results,0),
     cg.active_ind = 1, cg.active_status_cd = reqdata->active_status_cd, cg.active_status_dt_tm =
     cnvtdatetime(sysdate),
     cg.active_status_prsnl_id = reqinfo->updt_id, cg.updt_cnt = 0, cg.updt_dt_tm = cnvtdatetime(
      sysdate),
     cg.updt_id = reqinfo->updt_id, cg.updt_task = reqinfo->updt_task, cg.updt_applctx = reqinfo->
     updt_applctx
    WITH nocounter
   ;end insert
   CALL error_and_zero_check(curqual,"CHART_GROUP","INSERTCHARTGROUP",1,1)
   FOR (t = 1 TO request->chart_section_list[secindex].chart_group_list[grpindex].chart_event_count)
     CALL insertevent(secindex,grpindex,t)
   ENDFOR
   CASE (request->chart_section_list[secindex].section_type_flag)
    OF xencntr_section_type:
     CALL add_xencntr_format(secindex,grpindex)
    OF flex_section_type:
     CALL add_flex_format(secindex,grpindex)
    OF horz_section_type:
     CALL add_horz_format(secindex,grpindex)
    OF mic_section_type:
     SET opt_nbr = size(request->chart_section_list[secindex].chart_group_list[grpindex].micro_info.
      option_list,5)
     SET micro_legend_id = 0
     CALL add_micro_format(secindex,grpindex)
    OF ord_sum_section_type:
     CALL add_order_summary_format(secindex,grpindex)
     SET filter_num = size(request->chart_section_list[secindex].chart_group_list[grpindex].
      order_summary_info.os_filter_list,5)
     FOR (f = 1 TO filter_num)
       CALL add_os_filter(secindex,grpindex,f)
     ENDFOR
    OF rad_section_type:
     CALL add_rad_format(secindex,grpindex)
    OF vert_section_type:
     CALL add_vert_format(secindex,grpindex)
    OF zonal_old_section_type:
     CALL add_zonal_format(secindex,grpindex)
     SET num_zones = size(request->chart_section_list[secindex].chart_group_list[grpindex].
      zonal_info_list,5)
     FOR (t = 1 TO num_zones)
       CALL add_zone(secindex,grpindex,t)
     ENDFOR
    OF ap_section_type:
     CALL add_ap_format(secindex,grpindex)
    OF hla_section_type:
     CALL add_hla_format(secindex,grpindex)
    OF doc_section_type:
     CALL add_doc_format(secindex,grpindex)
    OF lab_text_section_type:
     CALL add_gl_format(secindex,grpindex)
    OF ppr_section_type:
     CALL add_ppr_format(secindex,grpindex)
    OF visit_list_section_type:
     CALL add_vl_format(secindex,grpindex)
    OF allergy_section_type:
     CALL add_allergy_format(secindex,grpindex)
    OF prob_list_section_type:
     CALL add_prob_format(secindex,grpindex)
    OF zonal_new_section_type:
     CALL add_new_zonal_format(secindex,grpindex)
     SET num_zones = size(request->chart_section_list[secindex].chart_group_list[grpindex].
      new_zonal_info.zone_list,5)
     FOR (t = 1 TO num_zones)
       CALL add_new_zone(secindex,grpindex,t)
     ENDFOR
    OF orders_section_type:
     CALL add_orders_format(secindex,grpindex)
    OF name_hist_section_type:
     CALL add_name_hist_format(secindex,grpindex)
    OF immun_section_type:
     CALL add_immunization_format(secindex,grpindex)
    OF proc_hist_section_type:
     CALL add_proc_hist_format(secindex,grpindex)
    OF mar2_section_type:
     CALL add_mar2_format(secindex,grpindex)
    OF io_section_type:
     CALL add_io_format(secindex,grpindex)
    OF med_prof_hist_section_type:
     CALL add_mph_format(secindex,grpindex)
    OF user_defined_section_type:
     CALL add_discern_report_info(secindex,grpindex)
    OF listview_section_type:
     CALL add_listview_format(secindex,grpindex)
   ENDCASE
 END ;Subroutine
 SUBROUTINE (add_xencntr_format(sindex=i4(val),gindex=i4(val)) =null)
   CALL log_message("In add_xencntr_format()",log_level_debug)
   INSERT  FROM chart_xencntr_format xe
    SET xe.chart_group_id = request->chart_section_list[sindex].chart_group_list[gindex].
     chart_group_id, xe.rslt_seq_flag = request->chart_section_list[sindex].chart_group_list[gindex].
     xencntr_info.rslt_seq, xe.ea_prefix_format_flag = request->chart_section_list[sindex].
     chart_group_list[gindex].xencntr_info.prefix_format_flag,
     xe.ea_prefix_format = request->chart_section_list[sindex].chart_group_list[gindex].xencntr_info.
     prefix_format, xe.encntr_alias_lbl = request->chart_section_list[sindex].chart_group_list[gindex
     ].xencntr_info.encntr_alias_lbl, xe.facility_lbl = request->chart_section_list[sindex].
     chart_group_list[gindex].xencntr_info.facility_lbl,
     xe.building_lbl = request->chart_section_list[sindex].chart_group_list[gindex].xencntr_info.
     building_lbl, xe.nurse_unit_lbl = request->chart_section_list[sindex].chart_group_list[gindex].
     xencntr_info.nurse_unit_lbl, xe.client_lbl = request->chart_section_list[sindex].
     chart_group_list[gindex].xencntr_info.client_lbl,
     xe.fin_nbr_lbl = request->chart_section_list[sindex].chart_group_list[gindex].xencntr_info.
     fin_nbr_lbl, xe.mrn_lbl = request->chart_section_list[sindex].chart_group_list[gindex].
     xencntr_info.mrn_lbl, xe.admit_dt_lbl = request->chart_section_list[sindex].chart_group_list[
     gindex].xencntr_info.admit_dt_lbl,
     xe.dischg_dt_lbl = request->chart_section_list[sindex].chart_group_list[gindex].xencntr_info.
     dischg_dt_lbl, xe.diagnosis_lbl = request->chart_section_list[sindex].chart_group_list[gindex].
     xencntr_info.diagnosis_lbl, xe.encntr_alias_odr = request->chart_section_list[sindex].
     chart_group_list[gindex].xencntr_info.encntr_alias_odr,
     xe.facility_odr = request->chart_section_list[sindex].chart_group_list[gindex].xencntr_info.
     facility_odr, xe.building_odr = request->chart_section_list[sindex].chart_group_list[gindex].
     xencntr_info.building_odr, xe.nurse_unit_odr = request->chart_section_list[sindex].
     chart_group_list[gindex].xencntr_info.nurse_unit_odr,
     xe.client_odr = request->chart_section_list[sindex].chart_group_list[gindex].xencntr_info.
     client_odr, xe.fin_nbr_odr = request->chart_section_list[sindex].chart_group_list[gindex].
     xencntr_info.fin_nbr_odr, xe.mrn_odr = request->chart_section_list[sindex].chart_group_list[
     gindex].xencntr_info.mrn_odr,
     xe.admit_dt_odr = request->chart_section_list[sindex].chart_group_list[gindex].xencntr_info.
     admit_dt_odr, xe.dischg_dt_odr = request->chart_section_list[sindex].chart_group_list[gindex].
     xencntr_info.dischg_dt_odr, xe.diagnosis_odr = request->chart_section_list[sindex].
     chart_group_list[gindex].xencntr_info.diagnosis_odr,
     xe.active_ind = 1, xe.active_status_cd = reqdata->active_status_cd, xe.active_status_dt_tm =
     cnvtdatetime(sysdate),
     xe.active_status_prsnl_id = reqinfo->updt_id, xe.updt_cnt = 0, xe.updt_dt_tm = cnvtdatetime(
      curdate,curtime),
     xe.updt_id = reqinfo->updt_id, xe.updt_applctx = reqinfo->updt_applctx, xe.updt_task = reqinfo->
     updt_task
    WITH nocounter
   ;end insert
   CALL error_and_zero_check(curqual,"CHART_XENCNTR_FORMAT","ADD_XENCNTR_FORMAT",1,1)
 END ;Subroutine
 SUBROUTINE (update_xencntr(secindex=i4(val),grpindex=i4(val)) =null)
   CALL log_message("In update_xencntr()",log_level_debug)
   UPDATE  FROM chart_xencntr_format xe
    SET xe.rslt_seq_flag = request->chart_section_list[secindex].chart_group_list[grpindex].
     xencntr_info.rslt_seq, xe.ea_prefix_format_flag = request->chart_section_list[secindex].
     chart_group_list[grpindex].xencntr_info.prefix_format_flag, xe.ea_prefix_format = request->
     chart_section_list[secindex].chart_group_list[grpindex].xencntr_info.prefix_format,
     xe.encntr_alias_lbl = request->chart_section_list[secindex].chart_group_list[grpindex].
     xencntr_info.encntr_alias_lbl, xe.facility_lbl = request->chart_section_list[secindex].
     chart_group_list[grpindex].xencntr_info.facility_lbl, xe.building_lbl = request->
     chart_section_list[secindex].chart_group_list[grpindex].xencntr_info.building_lbl,
     xe.nurse_unit_lbl = request->chart_section_list[secindex].chart_group_list[grpindex].
     xencntr_info.nurse_unit_lbl, xe.client_lbl = request->chart_section_list[secindex].
     chart_group_list[grpindex].xencntr_info.client_lbl, xe.fin_nbr_lbl = request->
     chart_section_list[secindex].chart_group_list[grpindex].xencntr_info.fin_nbr_lbl,
     xe.mrn_lbl = request->chart_section_list[secindex].chart_group_list[grpindex].xencntr_info.
     mrn_lbl, xe.admit_dt_lbl = request->chart_section_list[secindex].chart_group_list[grpindex].
     xencntr_info.admit_dt_lbl, xe.dischg_dt_lbl = request->chart_section_list[secindex].
     chart_group_list[grpindex].xencntr_info.dischg_dt_lbl,
     xe.diagnosis_lbl = request->chart_section_list[secindex].chart_group_list[grpindex].xencntr_info
     .diagnosis_lbl, xe.encntr_alias_odr = request->chart_section_list[secindex].chart_group_list[
     grpindex].xencntr_info.encntr_alias_odr, xe.facility_odr = request->chart_section_list[secindex]
     .chart_group_list[grpindex].xencntr_info.facility_odr,
     xe.building_odr = request->chart_section_list[secindex].chart_group_list[grpindex].xencntr_info.
     building_odr, xe.nurse_unit_odr = request->chart_section_list[secindex].chart_group_list[
     grpindex].xencntr_info.nurse_unit_odr, xe.client_odr = request->chart_section_list[secindex].
     chart_group_list[grpindex].xencntr_info.client_odr,
     xe.fin_nbr_odr = request->chart_section_list[secindex].chart_group_list[grpindex].xencntr_info.
     fin_nbr_odr, xe.mrn_odr = request->chart_section_list[secindex].chart_group_list[grpindex].
     xencntr_info.mrn_odr, xe.admit_dt_odr = request->chart_section_list[secindex].chart_group_list[
     grpindex].xencntr_info.admit_dt_odr,
     xe.dischg_dt_odr = request->chart_section_list[secindex].chart_group_list[grpindex].xencntr_info
     .dischg_dt_odr, xe.diagnosis_odr = request->chart_section_list[secindex].chart_group_list[
     grpindex].xencntr_info.diagnosis_odr, xe.active_ind = 1,
     xe.active_status_cd = reqdata->active_status_cd, xe.updt_cnt = (xe.updt_cnt+ 1), xe.updt_dt_tm
      = cnvtdatetime(curdate,curtime),
     xe.updt_id = reqinfo->updt_id, xe.updt_applctx = reqinfo->updt_applctx, xe.updt_task = reqinfo->
     updt_task
    WHERE (xe.chart_group_id=request->chart_section_list[secindex].chart_group_list[grpindex].
    chart_group_id)
    WITH nocounter
   ;end update
   CALL error_and_zero_check(curqual,"CHART_XENCNTR_FORMAT","UPDATE_XENCNTR",1,1)
 END ;Subroutine
 SUBROUTINE (checkxencntrsection(secindex=i4(val),grpindex=i4(val)) =null)
   CALL log_message("In CheckXencntrSection()",log_level_debug)
   DECLARE update_xencntr_flag = i2 WITH noconstant(0), protect
   SELECT INTO "nl:"
    FROM chart_xencntr_format xe
    WHERE (xe.chart_group_id=request->chart_section_list[secindex].chart_group_list[grpindex].
    chart_group_id)
    DETAIL
     IF ((((request->chart_section_list[secindex].chart_group_list[grpindex].xencntr_info.rslt_seq
      != xe.rslt_seq_flag)) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].
     xencntr_info.prefix_format_flag != xe.ea_prefix_format_flag)) OR ((((request->
     chart_section_list[secindex].chart_group_list[grpindex].xencntr_info.prefix_format != xe
     .ea_prefix_format)) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].
     xencntr_info.encntr_alias_lbl != xe.encntr_alias_lbl)) OR ((((request->chart_section_list[
     secindex].chart_group_list[grpindex].xencntr_info.facility_lbl != xe.facility_lbl)) OR ((((
     request->chart_section_list[secindex].chart_group_list[grpindex].xencntr_info.building_lbl != xe
     .building_lbl)) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].
     xencntr_info.nurse_unit_lbl != xe.nurse_unit_lbl)) OR ((((request->chart_section_list[secindex].
     chart_group_list[grpindex].xencntr_info.client_lbl != xe.client_lbl)) OR ((((request->
     chart_section_list[secindex].chart_group_list[grpindex].xencntr_info.fin_nbr_lbl != xe
     .fin_nbr_lbl)) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].
     xencntr_info.mrn_lbl != xe.mrn_lbl)) OR ((((request->chart_section_list[secindex].
     chart_group_list[grpindex].xencntr_info.admit_dt_lbl != xe.admit_dt_lbl)) OR ((((request->
     chart_section_list[secindex].chart_group_list[grpindex].xencntr_info.dischg_dt_lbl != xe
     .dischg_dt_lbl)) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].
     xencntr_info.diagnosis_lbl != xe.diagnosis_lbl)) OR ((((request->chart_section_list[secindex].
     chart_group_list[grpindex].xencntr_info.encntr_alias_odr != xe.encntr_alias_odr)) OR ((((request
     ->chart_section_list[secindex].chart_group_list[grpindex].xencntr_info.facility_odr != xe
     .facility_odr)) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].
     xencntr_info.building_odr != xe.building_odr)) OR ((((request->chart_section_list[secindex].
     chart_group_list[grpindex].xencntr_info.nurse_unit_odr != xe.nurse_unit_odr)) OR ((((request->
     chart_section_list[secindex].chart_group_list[grpindex].xencntr_info.client_odr != xe.client_odr
     )) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].xencntr_info.
     fin_nbr_odr != xe.fin_nbr_odr)) OR ((((request->chart_section_list[secindex].chart_group_list[
     grpindex].xencntr_info.mrn_odr != xe.mrn_odr)) OR ((((request->chart_section_list[secindex].
     chart_group_list[grpindex].xencntr_info.admit_dt_odr != xe.admit_dt_odr)) OR ((((request->
     chart_section_list[secindex].chart_group_list[grpindex].xencntr_info.dischg_dt_odr != xe
     .dischg_dt_odr)) OR ((request->chart_section_list[secindex].chart_group_list[grpindex].
     xencntr_info.diagnosis_odr != xe.diagnosis_odr))) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
     )) )) )) )) )) )) )
      update_xencntr_flag = 1
     ENDIF
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_XENCNTR_FORMAT","CHECKXENCNTRSECTION",1,1)
   IF (update_xencntr_flag=1)
    CALL update_xencntr(secindex,grpindex)
   ENDIF
 END ;Subroutine
 SUBROUTINE (add_flex_format(sindex=i4(val),gindex=i4(val)) =null)
   CALL log_message("In add_flex_format()",log_level_debug)
   INSERT  FROM chart_flex_format cff
    SET cff.chart_group_id = request->chart_section_list[sindex].chart_group_list[gindex].
     chart_group_id, cff.flex_type = request->chart_section_list[sindex].chart_group_list[gindex].
     flex_info.flex_type, cff.order_seq_flag = request->chart_section_list[sindex].chart_group_list[
     gindex].flex_info.order_seq_flag,
     cff.product_nbr_lbl = request->chart_section_list[sindex].chart_group_list[gindex].flex_info.
     prod_nbr_lbl, cff.product_nbr_order = request->chart_section_list[sindex].chart_group_list[
     gindex].flex_info.prod_nbr_odr, cff.description_lbl = request->chart_section_list[sindex].
     chart_group_list[gindex].flex_info.desc_lbl,
     cff.description_order = request->chart_section_list[sindex].chart_group_list[gindex].flex_info.
     desc_odr, cff.display_lbl = request->chart_section_list[sindex].chart_group_list[gindex].
     flex_info.disp_lbl, cff.display_order = request->chart_section_list[sindex].chart_group_list[
     gindex].flex_info.disp_odr,
     cff.abo_rh_lbl = request->chart_section_list[sindex].chart_group_list[gindex].flex_info.
     abo_rh_lbl, cff.abo_rh_order = request->chart_section_list[sindex].chart_group_list[gindex].
     flex_info.abo_rh_odr, cff.verified_dt_tm_lbl = request->chart_section_list[sindex].
     chart_group_list[gindex].flex_info.verified_dt_tm_lbl,
     cff.verified_dt_tm_order = request->chart_section_list[sindex].chart_group_list[gindex].
     flex_info.verified_dt_tm_odr, cff.collected_dt_tm_lbl = request->chart_section_list[sindex].
     chart_group_list[gindex].flex_info.collected_dt_tm_lbl, cff.collected_dt_tm_order = request->
     chart_section_list[sindex].chart_group_list[gindex].flex_info.collected_dt_tm_odr,
     cff.crossmatch_result_lbl = request->chart_section_list[sindex].chart_group_list[gindex].
     flex_info.crossmatch_result_lbl, cff.crossmatch_result_order = request->chart_section_list[
     sindex].chart_group_list[gindex].flex_info.crossmatch_result_odr, cff.product_status_lbl =
     request->chart_section_list[sindex].chart_group_list[gindex].flex_info.product_status_lbl,
     cff.product_status_order = request->chart_section_list[sindex].chart_group_list[gindex].
     flex_info.product_status_odr, cff.received_dt_tm_lbl = request->chart_section_list[sindex].
     chart_group_list[gindex].flex_info.received_dt_tm_lbl, cff.received_dt_tm_order = request->
     chart_section_list[sindex].chart_group_list[gindex].flex_info.received_dt_tm_odr,
     cff.active_ind = 1, cff.active_status_cd = reqdata->active_status_cd, cff.active_status_dt_tm =
     cnvtdatetime(sysdate),
     cff.active_status_prsnl_id = reqinfo->updt_id, cff.updt_cnt = 0, cff.updt_dt_tm = cnvtdatetime(
      sysdate),
     cff.updt_id = reqinfo->updt_id, cff.updt_task = reqinfo->updt_task, cff.updt_applctx = reqinfo->
     updt_applctx
    WITH nocounter
   ;end insert
   CALL error_and_zero_check(curqual,"CHART_FLEX_FORMAT","ADD_FLEX_FORMAT",1,1)
 END ;Subroutine
 SUBROUTINE (update_flex(secindex=i4(val),grpindex=i4(val)) =null)
   CALL log_message("In update_flex()",log_level_debug)
   UPDATE  FROM chart_flex_format cff
    SET cff.flex_type = request->chart_section_list[secindex].chart_group_list[grpindex].flex_info.
     flex_type, cff.order_seq_flag = request->chart_section_list[secindex].chart_group_list[grpindex]
     .flex_info.order_seq_flag, cff.product_nbr_lbl = request->chart_section_list[secindex].
     chart_group_list[grpindex].flex_info.prod_nbr_lbl,
     cff.product_nbr_order = request->chart_section_list[secindex].chart_group_list[grpindex].
     flex_info.prod_nbr_odr, cff.description_lbl = request->chart_section_list[secindex].
     chart_group_list[grpindex].flex_info.desc_lbl, cff.description_order = request->
     chart_section_list[secindex].chart_group_list[grpindex].flex_info.desc_odr,
     cff.display_lbl = request->chart_section_list[secindex].chart_group_list[grpindex].flex_info.
     disp_lbl, cff.display_order = request->chart_section_list[secindex].chart_group_list[grpindex].
     flex_info.disp_odr, cff.abo_rh_lbl = request->chart_section_list[secindex].chart_group_list[
     grpindex].flex_info.abo_rh_lbl,
     cff.abo_rh_order = request->chart_section_list[secindex].chart_group_list[grpindex].flex_info.
     abo_rh_odr, cff.verified_dt_tm_lbl = request->chart_section_list[secindex].chart_group_list[
     grpindex].flex_info.verified_dt_tm_lbl, cff.verified_dt_tm_order = request->chart_section_list[
     secindex].chart_group_list[grpindex].flex_info.verified_dt_tm_odr,
     cff.collected_dt_tm_lbl = request->chart_section_list[secindex].chart_group_list[grpindex].
     flex_info.collected_dt_tm_lbl, cff.collected_dt_tm_order = request->chart_section_list[secindex]
     .chart_group_list[grpindex].flex_info.collected_dt_tm_odr, cff.crossmatch_result_lbl = request->
     chart_section_list[secindex].chart_group_list[grpindex].flex_info.crossmatch_result_lbl,
     cff.crossmatch_result_order = request->chart_section_list[secindex].chart_group_list[grpindex].
     flex_info.crossmatch_result_odr, cff.product_status_lbl = request->chart_section_list[secindex].
     chart_group_list[grpindex].flex_info.product_status_lbl, cff.product_status_order = request->
     chart_section_list[secindex].chart_group_list[grpindex].flex_info.product_status_odr,
     cff.received_dt_tm_lbl = request->chart_section_list[secindex].chart_group_list[grpindex].
     flex_info.received_dt_tm_lbl, cff.received_dt_tm_order = request->chart_section_list[secindex].
     chart_group_list[grpindex].flex_info.received_dt_tm_odr, cff.active_ind = 1,
     cff.active_status_cd = reqdata->active_status_cd, cff.updt_cnt = (cff.updt_cnt+ 1), cff
     .updt_dt_tm = cnvtdatetime(curdate,curtime),
     cff.updt_id = reqinfo->updt_id, cff.updt_applctx = reqinfo->updt_applctx, cff.updt_task =
     reqinfo->updt_task
    WHERE (cff.chart_group_id=request->chart_section_list[secindex].chart_group_list[grpindex].
    chart_group_id)
    WITH nocounter
   ;end update
   CALL error_and_zero_check(curqual,"CHART_FLEX_FORMAT","UPDATE_FLEX",1,1)
 END ;Subroutine
 SUBROUTINE (checkflexsection(secindex=i4(val),grpindex=i4(val)) =null)
   CALL log_message("In CheckFlexSection()",log_level_debug)
   DECLARE update_flex_flag = i2 WITH noconstant(0), protect
   SELECT INTO "nl:"
    FROM chart_flex_format cff
    WHERE (cff.chart_group_id=request->chart_section_list[secindex].chart_group_list[grpindex].
    chart_group_id)
    DETAIL
     IF ((((request->chart_section_list[secindex].chart_group_list[grpindex].flex_info.flex_type !=
     cff.flex_type)) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].
     flex_info.order_seq_flag != cff.order_seq_flag)) OR ((((request->chart_section_list[secindex].
     chart_group_list[grpindex].flex_info.prod_nbr_lbl != cff.product_nbr_lbl)) OR ((((request->
     chart_section_list[secindex].chart_group_list[grpindex].flex_info.prod_nbr_odr != cff
     .product_nbr_order)) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].
     flex_info.desc_lbl != cff.description_lbl)) OR ((((request->chart_section_list[secindex].
     chart_group_list[grpindex].flex_info.desc_odr != cff.description_order)) OR ((((request->
     chart_section_list[secindex].chart_group_list[grpindex].flex_info.disp_lbl != cff.display_lbl))
      OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].flex_info.disp_odr !=
     cff.display_order)) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].
     flex_info.abo_rh_lbl != cff.abo_rh_lbl)) OR ((((request->chart_section_list[secindex].
     chart_group_list[grpindex].flex_info.abo_rh_odr != cff.abo_rh_order)) OR ((((request->
     chart_section_list[secindex].chart_group_list[grpindex].flex_info.verified_dt_tm_lbl != cff
     .verified_dt_tm_lbl)) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].
     flex_info.verified_dt_tm_odr != cff.verified_dt_tm_order)) OR ((((request->chart_section_list[
     secindex].chart_group_list[grpindex].flex_info.collected_dt_tm_lbl != cff.collected_dt_tm_lbl))
      OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].flex_info.
     collected_dt_tm_odr != cff.collected_dt_tm_order)) OR ((((request->chart_section_list[secindex].
     chart_group_list[grpindex].flex_info.crossmatch_result_lbl != cff.crossmatch_result_lbl)) OR (((
     (request->chart_section_list[secindex].chart_group_list[grpindex].flex_info.
     crossmatch_result_odr != cff.crossmatch_result_order)) OR ((((request->chart_section_list[
     secindex].chart_group_list[grpindex].flex_info.product_status_lbl != cff.product_status_lbl))
      OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].flex_info.
     product_status_odr != cff.product_status_order)) OR ((((request->chart_section_list[secindex].
     chart_group_list[grpindex].flex_info.received_dt_tm_lbl != cff.received_dt_tm_lbl)) OR ((request
     ->chart_section_list[secindex].chart_group_list[grpindex].flex_info.received_dt_tm_odr != cff
     .received_dt_tm_order))) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )
      update_flex_flag = 1
     ENDIF
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_FLEX_FORMAT","CHECKFLEXSECTION",1,1)
   IF (update_flex_flag=1)
    CALL update_flex(secindex,grpindex)
   ENDIF
 END ;Subroutine
 SUBROUTINE (add_horz_format(sindex=i4(val),gindex=i4(val)) =null)
   CALL log_message("In add_horz_format()",log_level_debug)
   INSERT  FROM chart_horz_format chf
    SET chf.chart_group_id = request->chart_section_list[sindex].chart_group_list[gindex].
     chart_group_id, chf.test_lbl_order = request->chart_section_list[sindex].chart_group_list[gindex
     ].horizontal_info_list[1].test_lbl_order, chf.units_lbl_order = request->chart_section_list[
     sindex].chart_group_list[gindex].horizontal_info_list[1].units_lbl_order,
     chf.refer_lbl_order = request->chart_section_list[sindex].chart_group_list[gindex].
     horizontal_info_list[1].refer_lbl_order, chf.normall_lbl_order = request->chart_section_list[
     sindex].chart_group_list[gindex].horizontal_info_list[1].normall_lbl_order, chf
     .normalh_lbl_order = request->chart_section_list[sindex].chart_group_list[gindex].
     horizontal_info_list[1].normalh_lbl_order,
     chf.perfid_lbl_order = request->chart_section_list[sindex].chart_group_list[gindex].
     horizontal_info_list[1].perfid_lbl_order, chf.date_order = request->chart_section_list[sindex].
     chart_group_list[gindex].horizontal_info_list[1].date_order, chf.weekday_order = request->
     chart_section_list[sindex].chart_group_list[gindex].horizontal_info_list[1].weekday_order,
     chf.staydays_order = request->chart_section_list[sindex].chart_group_list[gindex].
     horizontal_info_list[1].staydays_order, chf.time_order = request->chart_section_list[sindex].
     chart_group_list[gindex].horizontal_info_list[1].time_order, chf.test_lbl = request->
     chart_section_list[sindex].chart_group_list[gindex].horizontal_info_list[1].test_lbl,
     chf.units_lbl = request->chart_section_list[sindex].chart_group_list[gindex].
     horizontal_info_list[1].units_lbl, chf.ref_range_lbl = request->chart_section_list[sindex].
     chart_group_list[gindex].horizontal_info_list[1].ref_range_lbl, chf.normal_low_lbl = request->
     chart_section_list[sindex].chart_group_list[gindex].horizontal_info_list[1].normal_low_lbl,
     chf.normal_high_lbl = request->chart_section_list[sindex].chart_group_list[gindex].
     horizontal_info_list[1].normal_high_lbl, chf.perfid_lbl = request->chart_section_list[sindex].
     chart_group_list[gindex].horizontal_info_list[1].perfid_lbl, chf.date_mask = request->
     chart_section_list[sindex].chart_group_list[gindex].horizontal_info_list[1].date_mask,
     chf.time_mask = request->chart_section_list[sindex].chart_group_list[gindex].
     horizontal_info_list[1].time_mask, chf.date_format_cd = request->chart_section_list[sindex].
     chart_group_list[gindex].horizontal_info_list[1].date_format_cd, chf.time_format_flag = request
     ->chart_section_list[sindex].chart_group_list[gindex].horizontal_info_list[1].time_format_flag,
     chf.wkday_format_flag = request->chart_section_list[sindex].chart_group_list[gindex].
     horizontal_info_list[1].wkday_format_flag, chf.ref_rng_form_flag = request->chart_section_list[
     sindex].chart_group_list[gindex].horizontal_info_list[1].ref_rng_form_flag, chf.rslt_seq_flag =
     request->chart_section_list[sindex].chart_group_list[gindex].horizontal_info_list[1].
     rslt_seq_flag,
     chf.ftnote_loc_flag = request->chart_section_list[sindex].chart_group_list[gindex].
     horizontal_info_list[1].ftnote_loc_flag, chf.interp_loc_flag = request->chart_section_list[
     sindex].chart_group_list[gindex].horizontal_info_list[1].interp_loc_flag, chf.rslt_start_col =
     request->chart_section_list[sindex].chart_group_list[gindex].horizontal_info_list[1].
     rslt_start_col,
     chf.encntr_alias_order = request->chart_section_list[sindex].chart_group_list[gindex].
     horizontal_info_list[1].encntr_alias_order, chf.flowsheet_ind = request->chart_section_list[
     sindex].chart_group_list[gindex].horizontal_info_list[1].flowsheet_ind, chf.active_ind = 1,
     chf.active_status_cd = reqdata->active_status_cd, chf.active_status_dt_tm = cnvtdatetime(sysdate
      ), chf.active_status_prsnl_id = reqinfo->updt_id,
     chf.updt_cnt = 0, chf.updt_dt_tm = cnvtdatetime(sysdate), chf.updt_id = reqinfo->updt_id,
     chf.updt_task = reqinfo->updt_task, chf.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   CALL error_and_zero_check(curqual,"CHART_HORZ_FORMAT","ADD_HORZ_FORMAT",1,1)
 END ;Subroutine
 SUBROUTINE (update_horz(secindex=i4(val),grpindex=i4(val)) =null)
   CALL log_message("In update_horz()",log_level_debug)
   UPDATE  FROM chart_horz_format chf
    SET chf.test_lbl_order = request->chart_section_list[secindex].chart_group_list[grpindex].
     horizontal_info_list[1].test_lbl_order, chf.units_lbl_order = request->chart_section_list[
     secindex].chart_group_list[grpindex].horizontal_info_list[1].units_lbl_order, chf
     .refer_lbl_order = request->chart_section_list[secindex].chart_group_list[grpindex].
     horizontal_info_list[1].refer_lbl_order,
     chf.normall_lbl_order = request->chart_section_list[secindex].chart_group_list[grpindex].
     horizontal_info_list[1].normall_lbl_order, chf.normalh_lbl_order = request->chart_section_list[
     secindex].chart_group_list[grpindex].horizontal_info_list[1].normalh_lbl_order, chf
     .perfid_lbl_order = request->chart_section_list[secindex].chart_group_list[grpindex].
     horizontal_info_list[1].perfid_lbl_order,
     chf.date_order = request->chart_section_list[secindex].chart_group_list[grpindex].
     horizontal_info_list[1].date_order, chf.weekday_order = request->chart_section_list[secindex].
     chart_group_list[grpindex].horizontal_info_list[1].weekday_order, chf.staydays_order = request->
     chart_section_list[secindex].chart_group_list[grpindex].horizontal_info_list[1].staydays_order,
     chf.time_order = request->chart_section_list[secindex].chart_group_list[grpindex].
     horizontal_info_list[1].time_order, chf.test_lbl = request->chart_section_list[secindex].
     chart_group_list[grpindex].horizontal_info_list[1].test_lbl, chf.units_lbl = request->
     chart_section_list[secindex].chart_group_list[grpindex].horizontal_info_list[1].units_lbl,
     chf.ref_range_lbl = request->chart_section_list[secindex].chart_group_list[grpindex].
     horizontal_info_list[1].ref_range_lbl, chf.normal_low_lbl = request->chart_section_list[secindex
     ].chart_group_list[grpindex].horizontal_info_list[1].normal_low_lbl, chf.normal_high_lbl =
     request->chart_section_list[secindex].chart_group_list[grpindex].horizontal_info_list[1].
     normal_high_lbl,
     chf.perfid_lbl = request->chart_section_list[secindex].chart_group_list[grpindex].
     horizontal_info_list[1].perfid_lbl, chf.date_mask = request->chart_section_list[secindex].
     chart_group_list[grpindex].horizontal_info_list[1].date_mask, chf.time_mask = request->
     chart_section_list[secindex].chart_group_list[grpindex].horizontal_info_list[1].time_mask,
     chf.date_format_cd = request->chart_section_list[secindex].chart_group_list[grpindex].
     horizontal_info_list[1].date_format_cd, chf.time_format_flag = request->chart_section_list[
     secindex].chart_group_list[grpindex].horizontal_info_list[1].time_format_flag, chf
     .wkday_format_flag = request->chart_section_list[secindex].chart_group_list[grpindex].
     horizontal_info_list[1].wkday_format_flag,
     chf.ref_rng_form_flag = request->chart_section_list[secindex].chart_group_list[grpindex].
     horizontal_info_list[1].ref_rng_form_flag, chf.rslt_seq_flag = request->chart_section_list[
     secindex].chart_group_list[grpindex].horizontal_info_list[1].rslt_seq_flag, chf.ftnote_loc_flag
      = request->chart_section_list[secindex].chart_group_list[grpindex].horizontal_info_list[1].
     ftnote_loc_flag,
     chf.interp_loc_flag = request->chart_section_list[secindex].chart_group_list[grpindex].
     horizontal_info_list[1].interp_loc_flag, chf.rslt_start_col = request->chart_section_list[
     secindex].chart_group_list[grpindex].horizontal_info_list[1].rslt_start_col, chf
     .encntr_alias_order = request->chart_section_list[secindex].chart_group_list[grpindex].
     horizontal_info_list[1].encntr_alias_order,
     chf.flowsheet_ind = request->chart_section_list[secindex].chart_group_list[grpindex].
     horizontal_info_list[1].flowsheet_ind, chf.active_ind = 1, chf.active_status_cd = reqdata->
     active_status_cd,
     chf.updt_cnt = (chf.updt_cnt+ 1), chf.updt_dt_tm = cnvtdatetime(curdate,curtime), chf.updt_id =
     reqinfo->updt_id,
     chf.updt_applctx = reqinfo->updt_applctx, chf.updt_task = reqinfo->updt_task
    WHERE (chf.chart_group_id=request->chart_section_list[secindex].chart_group_list[grpindex].
    chart_group_id)
    WITH nocounter
   ;end update
   CALL error_and_zero_check(curqual,"CHART_HORZ_FORMAT","UPDATE_HORZ",1,1)
 END ;Subroutine
 SUBROUTINE (checkhorzontalsection(secindex=i4(val),grpindex=i4(val)) =null)
   CALL log_message("In CheckHorzontalSection()",log_level_debug)
   DECLARE update_horz_flag = i2 WITH noconstant(0), protect
   SELECT INTO "nl:"
    FROM chart_horz_format chf
    WHERE (chf.chart_group_id=request->chart_section_list[secindex].chart_group_list[grpindex].
    chart_group_id)
    DETAIL
     IF ((((request->chart_section_list[secindex].chart_group_list[grpindex].horizontal_info_list[1].
     test_lbl_order != chf.test_lbl_order)) OR ((((request->chart_section_list[secindex].
     chart_group_list[grpindex].horizontal_info_list[1].units_lbl_order != chf.units_lbl_order)) OR (
     (((request->chart_section_list[secindex].chart_group_list[grpindex].horizontal_info_list[1].
     refer_lbl_order != chf.refer_lbl_order)) OR ((((request->chart_section_list[secindex].
     chart_group_list[grpindex].horizontal_info_list[1].normall_lbl_order != chf.normall_lbl_order))
      OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].horizontal_info_list[1]
     .normalh_lbl_order != chf.normalh_lbl_order)) OR ((((request->chart_section_list[secindex].
     chart_group_list[grpindex].horizontal_info_list[1].perfid_lbl_order != chf.perfid_lbl_order))
      OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].horizontal_info_list[1]
     .date_order != chf.date_order)) OR ((((request->chart_section_list[secindex].chart_group_list[
     grpindex].horizontal_info_list[1].weekday_order != chf.weekday_order)) OR ((((request->
     chart_section_list[secindex].chart_group_list[grpindex].horizontal_info_list[1].staydays_order
      != chf.staydays_order)) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex]
     .horizontal_info_list[1].time_order != chf.time_order)) OR ((((request->chart_section_list[
     secindex].chart_group_list[grpindex].horizontal_info_list[1].test_lbl != chf.test_lbl)) OR ((((
     request->chart_section_list[secindex].chart_group_list[grpindex].horizontal_info_list[1].
     units_lbl != chf.units_lbl)) OR ((((request->chart_section_list[secindex].chart_group_list[
     grpindex].horizontal_info_list[1].ref_range_lbl != chf.ref_range_lbl)) OR ((((request->
     chart_section_list[secindex].chart_group_list[grpindex].horizontal_info_list[1].normal_low_lbl
      != chf.normal_low_lbl)) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex]
     .horizontal_info_list[1].normal_high_lbl != chf.normal_high_lbl)) OR ((((request->
     chart_section_list[secindex].chart_group_list[grpindex].horizontal_info_list[1].perfid_lbl !=
     chf.perfid_lbl)) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].
     horizontal_info_list[1].date_mask != chf.date_mask)) OR ((((request->chart_section_list[secindex
     ].chart_group_list[grpindex].horizontal_info_list[1].time_mask != chf.time_mask)) OR ((((request
     ->chart_section_list[secindex].chart_group_list[grpindex].horizontal_info_list[1].date_format_cd
      != chf.date_format_cd)) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex]
     .horizontal_info_list[1].time_format_flag != chf.time_format_flag)) OR ((((request->
     chart_section_list[secindex].chart_group_list[grpindex].horizontal_info_list[1].
     wkday_format_flag != chf.wkday_format_flag)) OR ((((request->chart_section_list[secindex].
     chart_group_list[grpindex].horizontal_info_list[1].ref_rng_form_flag != chf.ref_rng_form_flag))
      OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].horizontal_info_list[1]
     .rslt_seq_flag != chf.rslt_seq_flag)) OR ((((request->chart_section_list[secindex].
     chart_group_list[grpindex].horizontal_info_list[1].ftnote_loc_flag != chf.ftnote_loc_flag)) OR (
     (((request->chart_section_list[secindex].chart_group_list[grpindex].horizontal_info_list[1].
     interp_loc_flag != chf.interp_loc_flag)) OR ((((request->chart_section_list[secindex].
     chart_group_list[grpindex].horizontal_info_list[1].rslt_start_col != chf.rslt_start_col)) OR (((
     (request->chart_section_list[secindex].chart_group_list[grpindex].horizontal_info_list[1].
     encntr_alias_order != chf.encntr_alias_order)) OR ((request->chart_section_list[secindex].
     chart_group_list[grpindex].horizontal_info_list[1].flowsheet_ind != chf.flowsheet_ind))) )) ))
     )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )
      update_horz_flag = 1
     ENDIF
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_HORZ_FORMAT","CHECKHORZONTALSECTION",1,1)
   IF (update_horz_flag=1)
    CALL update_horz(secindex,grpindex)
   ENDIF
 END ;Subroutine
 SUBROUTINE (add_order_summary_format(sindex=i4(val),gindex=i4(val)) =null)
   CALL log_message("In add_order_summary_format()",log_level_debug)
   INSERT  FROM chart_order_summary_format cosf
    SET cosf.chart_group_id = request->chart_section_list[sindex].chart_group_list[gindex].
     chart_group_id, cosf.order_summary_type = request->chart_section_list[sindex].chart_group_list[
     gindex].order_summary_info.order_summary_type, cosf.date_lbl = request->chart_section_list[
     sindex].chart_group_list[gindex].order_summary_info.date_lbl,
     cosf.time_lbl = request->chart_section_list[sindex].chart_group_list[gindex].order_summary_info.
     time_lbl, cosf.name_lbl = request->chart_section_list[sindex].chart_group_list[gindex].
     order_summary_info.name_lbl, cosf.mnemonic_lbl = request->chart_section_list[sindex].
     chart_group_list[gindex].order_summary_info.mnemonic_lbl,
     cosf.status_lbl = request->chart_section_list[sindex].chart_group_list[gindex].
     order_summary_info.status_lbl, cosf.cancel_reason_lbl = request->chart_section_list[sindex].
     chart_group_list[gindex].order_summary_info.cancel_reason_lbl, cosf.date_order = request->
     chart_section_list[sindex].chart_group_list[gindex].order_summary_info.date_order,
     cosf.time_order = request->chart_section_list[sindex].chart_group_list[gindex].
     order_summary_info.time_order, cosf.name_order = request->chart_section_list[sindex].
     chart_group_list[gindex].order_summary_info.name_order, cosf.mnemonic_order = request->
     chart_section_list[sindex].chart_group_list[gindex].order_summary_info.mnemonic_order,
     cosf.status_order = request->chart_section_list[sindex].chart_group_list[gindex].
     order_summary_info.status_order, cosf.cancel_reason_order = request->chart_section_list[sindex].
     chart_group_list[gindex].order_summary_info.cancel_reason_order, cosf.date_mask = request->
     chart_section_list[sindex].chart_group_list[gindex].order_summary_info.date_mask,
     cosf.time_mask = request->chart_section_list[sindex].chart_group_list[gindex].order_summary_info
     .time_mask, cosf.order_seq_flag = request->chart_section_list[sindex].chart_group_list[gindex].
     order_summary_info.order_seq_flag, cosf.dept_status_lbl = request->chart_section_list[sindex].
     chart_group_list[gindex].order_summary_info.dept_status_lbl,
     cosf.dept_status_order = request->chart_section_list[sindex].chart_group_list[gindex].
     order_summary_info.dept_status_order, cosf.order_provider_ind = request->chart_section_list[
     sindex].chart_group_list[gindex].order_summary_info.order_provider_ind, cosf.order_provider_lbl
      = request->chart_section_list[sindex].chart_group_list[gindex].order_summary_info.
     order_provider_lbl,
     cosf.order_provider_order = request->chart_section_list[sindex].chart_group_list[gindex].
     order_summary_info.order_provider_order, cosf.active_ind = 1, cosf.active_status_cd = reqdata->
     active_status_cd,
     cosf.active_status_dt_tm = cnvtdatetime(sysdate), cosf.active_status_prsnl_id = reqinfo->updt_id,
     cosf.updt_cnt = 0,
     cosf.updt_dt_tm = cnvtdatetime(sysdate), cosf.updt_id = reqinfo->updt_id, cosf.updt_task =
     reqinfo->updt_task,
     cosf.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   CALL error_and_zero_check(curqual,"CHART_ORDER_SUMMARY_FORMAT","ADD_ORDER_SUMMARY_FORMAT",1,1)
 END ;Subroutine
 SUBROUTINE (add_os_filter(sindex=i4(val),gindex=i4(val),findex=i4(val)) =null)
   CALL log_message("In add_os_filter()",log_level_debug)
   INSERT  FROM chart_ord_sum_filter osf
    SET osf.chart_group_id = request->chart_section_list[sindex].chart_group_list[gindex].
     chart_group_id, osf.filter_type_flag = request->chart_section_list[sindex].chart_group_list[
     gindex].order_summary_info.os_filter_list[findex].filter_type_flag, osf.filter_cd = request->
     chart_section_list[sindex].chart_group_list[gindex].order_summary_info.os_filter_list[findex].
     filter_cd,
     osf.sequence = request->chart_section_list[sindex].chart_group_list[gindex].order_summary_info.
     os_filter_list[findex].filter_seq, osf.active_ind = 1, osf.active_status_cd = reqdata->
     active_status_cd,
     osf.active_status_dt_tm = cnvtdatetime(sysdate), osf.active_status_prsnl_id = reqinfo->updt_id,
     osf.updt_cnt = 0,
     osf.updt_dt_tm = cnvtdatetime(sysdate), osf.updt_id = reqinfo->updt_id, osf.updt_task = reqinfo
     ->updt_task,
     osf.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   CALL error_and_zero_check(curqual,"CHART_ORD_SUM_FILTER","ADD_OS_FILTER",1,1)
 END ;Subroutine
 SUBROUTINE (update_order_summary(secindex=i4(val),grpindex=i4(val)) =null)
   CALL log_message("In update_order_summary()",log_level_debug)
   UPDATE  FROM chart_order_summary_format cosf
    SET cosf.order_summary_type = request->chart_section_list[secindex].chart_group_list[grpindex].
     order_summary_info.order_summary_type, cosf.date_lbl = request->chart_section_list[secindex].
     chart_group_list[grpindex].order_summary_info.date_lbl, cosf.time_lbl = request->
     chart_section_list[secindex].chart_group_list[grpindex].order_summary_info.time_lbl,
     cosf.name_lbl = request->chart_section_list[secindex].chart_group_list[grpindex].
     order_summary_info.name_lbl, cosf.mnemonic_lbl = request->chart_section_list[secindex].
     chart_group_list[grpindex].order_summary_info.mnemonic_lbl, cosf.status_lbl = request->
     chart_section_list[secindex].chart_group_list[grpindex].order_summary_info.status_lbl,
     cosf.cancel_reason_lbl = request->chart_section_list[secindex].chart_group_list[grpindex].
     order_summary_info.cancel_reason_lbl, cosf.date_order = request->chart_section_list[secindex].
     chart_group_list[grpindex].order_summary_info.date_order, cosf.time_order = request->
     chart_section_list[secindex].chart_group_list[grpindex].order_summary_info.time_order,
     cosf.name_order = request->chart_section_list[secindex].chart_group_list[grpindex].
     order_summary_info.name_order, cosf.mnemonic_order = request->chart_section_list[secindex].
     chart_group_list[grpindex].order_summary_info.mnemonic_order, cosf.status_order = request->
     chart_section_list[secindex].chart_group_list[grpindex].order_summary_info.status_order,
     cosf.cancel_reason_order = request->chart_section_list[secindex].chart_group_list[grpindex].
     order_summary_info.cancel_reason_order, cosf.date_mask = request->chart_section_list[secindex].
     chart_group_list[grpindex].order_summary_info.date_mask, cosf.time_mask = request->
     chart_section_list[secindex].chart_group_list[grpindex].order_summary_info.time_mask,
     cosf.order_seq_flag = request->chart_section_list[secindex].chart_group_list[grpindex].
     order_summary_info.order_seq_flag, cosf.dept_status_lbl = request->chart_section_list[secindex].
     chart_group_list[grpindex].order_summary_info.dept_status_lbl, cosf.dept_status_order = request
     ->chart_section_list[secindex].chart_group_list[grpindex].order_summary_info.dept_status_order,
     cosf.order_provider_ind = request->chart_section_list[secindex].chart_group_list[grpindex].
     order_summary_info.order_provider_ind, cosf.order_provider_lbl = request->chart_section_list[
     secindex].chart_group_list[grpindex].order_summary_info.order_provider_lbl, cosf
     .order_provider_order = request->chart_section_list[secindex].chart_group_list[grpindex].
     order_summary_info.order_provider_order,
     cosf.active_ind = 1, cosf.active_status_cd = reqdata->active_status_cd, cosf.updt_cnt = (cosf
     .updt_cnt+ 1),
     cosf.updt_dt_tm = cnvtdatetime(curdate,curtime), cosf.updt_id = reqinfo->updt_id, cosf
     .updt_applctx = reqinfo->updt_applctx,
     cosf.updt_task = reqinfo->updt_task
    WHERE (cosf.chart_group_id=request->chart_section_list[secindex].chart_group_list[grpindex].
    chart_group_id)
    WITH nocounter
   ;end update
   CALL error_and_zero_check(curqual,"CHART_ORDER_SUMMARY_FORMAT","UPDATE_ORDER_SUMMARY",1,1)
 END ;Subroutine
 SUBROUTINE (checkordersummarysection(secindex=i4(val),grpindex=i4(val)) =null)
   CALL log_message("In CheckOrderSummarySection()",log_level_debug)
   DECLARE update_order_sum_flag = i2 WITH noconstant(0), protect
   SELECT INTO "nl:"
    FROM chart_order_summary_format cosf
    WHERE (cosf.chart_group_id=request->chart_section_list[secindex].chart_group_list[grpindex].
    chart_group_id)
    DETAIL
     IF ((((request->chart_section_list[secindex].chart_group_list[grpindex].order_summary_info.
     order_summary_type != cosf.order_summary_type)) OR ((((request->chart_section_list[secindex].
     chart_group_list[grpindex].order_summary_info.date_lbl != cosf.date_lbl)) OR ((((request->
     chart_section_list[secindex].chart_group_list[grpindex].order_summary_info.time_lbl != cosf
     .time_lbl)) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].
     order_summary_info.name_lbl != cosf.name_lbl)) OR ((((request->chart_section_list[secindex].
     chart_group_list[grpindex].order_summary_info.mnemonic_lbl != cosf.mnemonic_lbl)) OR ((((request
     ->chart_section_list[secindex].chart_group_list[grpindex].order_summary_info.status_lbl != cosf
     .status_lbl)) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].
     order_summary_info.cancel_reason_lbl != cosf.cancel_reason_lbl)) OR ((((request->
     chart_section_list[secindex].chart_group_list[grpindex].order_summary_info.date_order != cosf
     .date_order)) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].
     order_summary_info.time_order != cosf.time_order)) OR ((((request->chart_section_list[secindex].
     chart_group_list[grpindex].order_summary_info.name_order != cosf.name_order)) OR ((((request->
     chart_section_list[secindex].chart_group_list[grpindex].order_summary_info.mnemonic_order !=
     cosf.mnemonic_order)) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].
     order_summary_info.status_order != cosf.status_order)) OR ((((request->chart_section_list[
     secindex].chart_group_list[grpindex].order_summary_info.cancel_reason_order != cosf
     .cancel_reason_order)) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].
     order_summary_info.date_mask != cosf.date_mask)) OR ((((request->chart_section_list[secindex].
     chart_group_list[grpindex].order_summary_info.time_mask != cosf.time_mask)) OR ((((request->
     chart_section_list[secindex].chart_group_list[grpindex].order_summary_info.order_seq_flag !=
     cosf.order_seq_flag)) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].
     order_summary_info.dept_status_lbl != cosf.dept_status_lbl)) OR ((((request->chart_section_list[
     secindex].chart_group_list[grpindex].order_summary_info.dept_status_order != cosf
     .dept_status_order)) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].
     order_summary_info.order_provider_ind != cosf.order_provider_ind)) OR ((((request->
     chart_section_list[secindex].chart_group_list[grpindex].order_summary_info.order_provider_lbl
      != cosf.order_provider_lbl)) OR ((request->chart_section_list[secindex].chart_group_list[
     grpindex].order_summary_info.order_provider_order != cosf.order_provider_order))) )) )) )) ))
     )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )
      update_order_sum_flag = 1
     ENDIF
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_ORDER_SUMMARY_FORMAT","CHECKORDERSUMMARYSECTION",1,1)
   IF (update_order_sum_flag=1)
    CALL update_order_summary(secindex,grpindex)
   ENDIF
   DELETE  FROM chart_ord_sum_filter osf
    WHERE (osf.chart_group_id=request->chart_section_list[i].chart_group_list[j].chart_group_id)
    WITH nocounter
   ;end delete
   CALL error_and_zero_check(curqual,"CHART_ORD_SUM_FILTER","CHECKORDERSUMMARYSECTION",1,0)
   SET filter_num = size(request->chart_section_list[i].chart_group_list[j].order_summary_info.
    os_filter_list,5)
   FOR (f = 1 TO filter_num)
     CALL add_os_filter(secindex,grpindex,f)
   ENDFOR
 END ;Subroutine
 SUBROUTINE (add_rad_format(sindex=i4(val),gindex=i4(val)) =null)
   CALL log_message("In add_rad_format()",log_level_debug)
   INSERT  FROM chart_rad_format crf
    SET crf.chart_group_id = request->chart_section_list[sindex].chart_group_list[gindex].
     chart_group_id, crf.group_style = request->chart_section_list[sindex].chart_group_list[gindex].
     rad_info.group_style, crf.result_sequence = request->chart_section_list[sindex].
     chart_group_list[gindex].rad_info.result_sequence,
     crf.reason_ind = request->chart_section_list[sindex].chart_group_list[gindex].rad_info.
     reason_ind, crf.reason_annotation = request->chart_section_list[sindex].chart_group_list[gindex]
     .rad_info.reason_annotation, crf.reason_caption = request->chart_section_list[sindex].
     chart_group_list[gindex].rad_info.reason_caption,
     crf.cpt4_code_ind = request->chart_section_list[sindex].chart_group_list[gindex].rad_info.
     cpt4_code_ind, crf.cpt4_desc_ind = request->chart_section_list[sindex].chart_group_list[gindex].
     rad_info.cpt4_desc_ind, crf.cpt4_label = request->chart_section_list[sindex].chart_group_list[
     gindex].rad_info.cpt4_label,
     crf.cpt4_label_style = request->chart_section_list[sindex].chart_group_list[gindex].rad_info.
     cpt4_label_style, crf.cdm_code_ind = request->chart_section_list[sindex].chart_group_list[gindex
     ].rad_info.cdm_code_ind, crf.cdm_desc_ind = request->chart_section_list[sindex].
     chart_group_list[gindex].rad_info.cdm_desc_ind,
     crf.cdm_label = request->chart_section_list[sindex].chart_group_list[gindex].rad_info.cdm_label,
     crf.cdm_label_style = request->chart_section_list[sindex].chart_group_list[gindex].rad_info.
     cdm_label_style, crf.active_ind = 1,
     crf.active_status_cd = reqdata->active_status_cd, crf.active_status_dt_tm = cnvtdatetime(sysdate
      ), crf.active_status_prsnl_id = reqinfo->updt_id,
     crf.updt_cnt = 0, crf.updt_dt_tm = cnvtdatetime(sysdate), crf.updt_id = reqinfo->updt_id,
     crf.updt_task = reqinfo->updt_task, crf.updt_applctx = reqinfo->updt_applctx, crf
     .cor_footnote_ind = request->chart_section_list[sindex].chart_group_list[gindex].rad_info.
     cor_footnote_ind
    WITH nocounter
   ;end insert
   CALL error_and_zero_check(curqual,"CHART_RAD_FORMAT","ADD_RAD_FORMAT",1,1)
 END ;Subroutine
 SUBROUTINE (update_rad(secindex=i4(val),grpindex=i4(val)) =null)
   CALL log_message("In update_rad()",log_level_debug)
   UPDATE  FROM chart_rad_format crf
    SET crf.group_style = request->chart_section_list[secindex].chart_group_list[grpindex].rad_info.
     group_style, crf.result_sequence = request->chart_section_list[secindex].chart_group_list[
     grpindex].rad_info.result_sequence, crf.reason_ind = request->chart_section_list[secindex].
     chart_group_list[grpindex].rad_info.reason_ind,
     crf.reason_annotation = request->chart_section_list[secindex].chart_group_list[grpindex].
     rad_info.reason_annotation, crf.reason_caption = request->chart_section_list[secindex].
     chart_group_list[grpindex].rad_info.reason_caption, crf.cpt4_code_ind = request->
     chart_section_list[secindex].chart_group_list[grpindex].rad_info.cpt4_code_ind,
     crf.cpt4_desc_ind = request->chart_section_list[secindex].chart_group_list[grpindex].rad_info.
     cpt4_desc_ind, crf.cpt4_label = request->chart_section_list[secindex].chart_group_list[grpindex]
     .rad_info.cpt4_label, crf.cpt4_label_style = request->chart_section_list[secindex].
     chart_group_list[grpindex].rad_info.cpt4_label_style,
     crf.cdm_code_ind = request->chart_section_list[secindex].chart_group_list[grpindex].rad_info.
     cdm_code_ind, crf.cdm_desc_ind = request->chart_section_list[secindex].chart_group_list[grpindex
     ].rad_info.cdm_desc_ind, crf.cdm_label = request->chart_section_list[secindex].chart_group_list[
     grpindex].rad_info.cdm_label,
     crf.cdm_label_style = request->chart_section_list[secindex].chart_group_list[grpindex].rad_info.
     cdm_label_style, crf.active_ind = 1, crf.updt_cnt = (crf.updt_cnt+ 1),
     crf.updt_dt_tm = cnvtdatetime(curdate,curtime), crf.updt_id = reqinfo->updt_id, crf.updt_applctx
      = reqinfo->updt_applctx,
     crf.updt_task = reqinfo->updt_task, crf.cor_footnote_ind = request->chart_section_list[secindex]
     .chart_group_list[grpindex].rad_info.cor_footnote_ind
    WHERE (crf.chart_group_id=request->chart_section_list[secindex].chart_group_list[grpindex].
    chart_group_id)
    WITH nocounter
   ;end update
   CALL error_and_zero_check(curqual,"CHART_RAD_FORMAT","UPDATE_RAD",1,1)
 END ;Subroutine
 SUBROUTINE (checkradiologysection(secindex=i4(val),grpindex=i4(val)) =null)
   CALL log_message("In CheckRadiologySection()",log_level_debug)
   DECLARE update_rad_flag = i2 WITH noconstant(0), protect
   SELECT INTO "nl:"
    FROM chart_rad_format crf
    WHERE (crf.chart_group_id=request->chart_section_list[secindex].chart_group_list[grpindex].
    chart_group_id)
    DETAIL
     IF ((((request->chart_section_list[secindex].chart_group_list[grpindex].rad_info.group_style !=
     crf.group_style)) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].
     rad_info.result_sequence != crf.result_sequence)) OR ((((request->chart_section_list[secindex].
     chart_group_list[grpindex].rad_info.reason_ind != crf.reason_ind)) OR ((((request->
     chart_section_list[secindex].chart_group_list[grpindex].rad_info.reason_annotation != crf
     .reason_annotation)) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].
     rad_info.reason_caption != crf.reason_caption)) OR ((((request->chart_section_list[secindex].
     chart_group_list[grpindex].rad_info.cpt4_code_ind != crf.cpt4_code_ind)) OR ((((request->
     chart_section_list[secindex].chart_group_list[grpindex].rad_info.cpt4_desc_ind != crf
     .cpt4_desc_ind)) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].
     rad_info.cpt4_label != crf.cpt4_label)) OR ((((request->chart_section_list[secindex].
     chart_group_list[grpindex].rad_info.cpt4_label_style != crf.cpt4_label_style)) OR ((((request->
     chart_section_list[secindex].chart_group_list[grpindex].rad_info.cdm_code_ind != crf
     .cdm_code_ind)) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].rad_info
     .cdm_desc_ind != crf.cdm_desc_ind)) OR ((((request->chart_section_list[secindex].
     chart_group_list[grpindex].rad_info.cdm_label != crf.cdm_label)) OR ((((request->
     chart_section_list[secindex].chart_group_list[grpindex].rad_info.cdm_label_style != crf
     .cdm_label_style)) OR ((request->chart_section_list[secindex].chart_group_list[grpindex].
     rad_info.cor_footnote_ind != crf.cor_footnote_ind))) )) )) )) )) )) )) )) )) )) )) )) )) )
      update_rad_flag = 1
     ENDIF
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_RAD_FORMAT","CHECKRADIOLOGYSECTION",1,1)
   IF (update_rad_flag=1)
    CALL update_rad(secindex,grpindex)
   ENDIF
 END ;Subroutine
 SUBROUTINE (add_ap_format(sindex=i4(val),gindex=i4(val)) =null)
   CALL log_message("In add_ap_format()",log_level_debug)
   DECLARE tempid = f8 WITH noconstant(0.0), protect
   SET tempid = update_ap_cpt_options(0.0,request->chart_section_list[sindex].chart_group_list[gindex
    ].ap_info.cpt_long_text)
   INSERT  FROM chart_ap_format capf
    SET capf.chart_group_id = request->chart_section_list[sindex].chart_group_list[gindex].
     chart_group_id, capf.group_style = request->chart_section_list[sindex].chart_group_list[gindex].
     ap_info.group_style, capf.result_sequence = request->chart_section_list[sindex].
     chart_group_list[gindex].ap_info.result_sequence,
     capf.snomed_codes_ind = request->chart_section_list[sindex].chart_group_list[gindex].ap_info.
     snomed_codes_ind, capf.snomed_desc_ind = request->chart_section_list[sindex].chart_group_list[
     gindex].ap_info.snomed_desc_ind, capf.snomed_codes_lbl = request->chart_section_list[sindex].
     chart_group_list[gindex].ap_info.snomed_codes_lbl,
     capf.snomed_cd_lbl_style = request->chart_section_list[sindex].chart_group_list[gindex].ap_info.
     snomed_cd_lbl_style, capf.tcc_codes_ind = request->chart_section_list[sindex].chart_group_list[
     gindex].ap_info.tcc_codes_ind, capf.tcc_desc_ind = request->chart_section_list[sindex].
     chart_group_list[gindex].ap_info.tcc_desc_ind,
     capf.tcc_codes_lbl = request->chart_section_list[sindex].chart_group_list[gindex].ap_info.
     tcc_codes_lbl, capf.tcc_cd_lbl_style = request->chart_section_list[sindex].chart_group_list[
     gindex].ap_info.tcc_cd_lbl_style, capf.ap_history_flag = request->chart_section_list[sindex].
     chart_group_list[gindex].ap_info.ap_history_flag,
     capf.image_flag = request->chart_section_list[sindex].chart_group_list[gindex].ap_info.
     image_flag, capf.ap_cpt_long_text_id = tempid, capf.active_ind = 1,
     capf.active_status_cd = reqdata->active_status_cd, capf.active_status_dt_tm = cnvtdatetime(
      sysdate), capf.active_status_prsnl_id = reqinfo->updt_id,
     capf.updt_cnt = 0, capf.updt_dt_tm = cnvtdatetime(sysdate), capf.updt_id = reqinfo->updt_id,
     capf.updt_task = reqinfo->updt_task, capf.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   CALL error_and_zero_check(curqual,"CHART_AP_FORMAT","ADD_AP_FORMAT",1,1)
 END ;Subroutine
 SUBROUTINE (update_ap(secindex=i4(val),grpindex=i4(val)) =null)
   CALL log_message("In update_ap()",log_level_debug)
   DECLARE tempid = f8 WITH noconstant(0.0), protect
   SELECT INTO "nl:"
    FROM chart_ap_format capf
    WHERE (capf.chart_group_id=request->chart_section_list[secindex].chart_group_list[grpindex].
    chart_group_id)
    DETAIL
     tempid = capf.ap_cpt_long_text_id
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"SELECT_CHART_AP_FORMAT","UPDATE_AP",1,0)
   SET tempid = update_ap_cpt_options(tempid,request->chart_section_list[secindex].chart_group_list[
    grpindex].ap_info.cpt_long_text)
   UPDATE  FROM chart_ap_format capf
    SET capf.group_style = request->chart_section_list[secindex].chart_group_list[grpindex].ap_info.
     group_style, capf.result_sequence = request->chart_section_list[secindex].chart_group_list[
     grpindex].ap_info.result_sequence, capf.snomed_codes_ind = request->chart_section_list[secindex]
     .chart_group_list[grpindex].ap_info.snomed_codes_ind,
     capf.snomed_desc_ind = request->chart_section_list[secindex].chart_group_list[grpindex].ap_info.
     snomed_desc_ind, capf.snomed_codes_lbl = request->chart_section_list[secindex].chart_group_list[
     grpindex].ap_info.snomed_codes_lbl, capf.snomed_cd_lbl_style = request->chart_section_list[
     secindex].chart_group_list[grpindex].ap_info.snomed_cd_lbl_style,
     capf.tcc_codes_ind = request->chart_section_list[secindex].chart_group_list[grpindex].ap_info.
     tcc_codes_ind, capf.tcc_desc_ind = request->chart_section_list[secindex].chart_group_list[
     grpindex].ap_info.tcc_desc_ind, capf.tcc_codes_lbl = request->chart_section_list[secindex].
     chart_group_list[grpindex].ap_info.tcc_codes_lbl,
     capf.tcc_cd_lbl_style = request->chart_section_list[secindex].chart_group_list[grpindex].ap_info
     .tcc_cd_lbl_style, capf.ap_history_flag = request->chart_section_list[secindex].
     chart_group_list[grpindex].ap_info.ap_history_flag, capf.image_flag = request->
     chart_section_list[secindex].chart_group_list[grpindex].ap_info.image_flag,
     capf.ap_cpt_long_text_id =
     IF (size(trim(request->chart_section_list[secindex].chart_group_list[grpindex].ap_info.
       cpt_long_text)) > 0) tempid
     ELSE 0.0
     ENDIF
     , capf.active_ind = 1, capf.updt_cnt = (capf.updt_cnt+ 1),
     capf.updt_dt_tm = cnvtdatetime(curdate,curtime), capf.updt_id = reqinfo->updt_id, capf
     .updt_applctx = reqinfo->updt_applctx,
     capf.updt_task = reqinfo->updt_task
    WHERE (capf.chart_group_id=request->chart_section_list[secindex].chart_group_list[grpindex].
    chart_group_id)
    WITH nocounter
   ;end update
   CALL error_and_zero_check(curqual,"UPDATE_CHART_AP_FORMAT","UPDATE_AP",1,1)
   IF (size(trim(request->chart_section_list[secindex].chart_group_list[grpindex].ap_info.
     cpt_long_text))=0
    AND tempid > 0)
    DELETE  FROM long_text_reference ltr
     WHERE ltr.long_text_id=tempid
     WITH nocounter
    ;end delete
    CALL error_and_zero_check(curqual,"LONG_TEXT_REFERENCE","UPDATE_AP",1,1)
   ENDIF
 END ;Subroutine
 SUBROUTINE (checkapsection(secindex=i4(val),grpindex=i4(val)) =null)
   CALL log_message("In CheckApSection()",log_level_debug)
   DECLARE update_ap_flag = i2 WITH noconstant(0), protect
   SELECT INTO "nl:"
    FROM chart_ap_format capf,
     long_text_reference ltr
    PLAN (capf
     WHERE (capf.chart_group_id=request->chart_section_list[secindex].chart_group_list[grpindex].
     chart_group_id))
     JOIN (ltr
     WHERE capf.ap_cpt_long_text_id=ltr.long_text_id)
    DETAIL
     IF ((((request->chart_section_list[secindex].chart_group_list[grpindex].ap_info.group_style !=
     capf.group_style)) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].
     ap_info.result_sequence != capf.result_sequence)) OR ((((request->chart_section_list[secindex].
     chart_group_list[grpindex].ap_info.snomed_codes_ind != capf.snomed_codes_ind)) OR ((((request->
     chart_section_list[secindex].chart_group_list[grpindex].ap_info.snomed_desc_ind != capf
     .snomed_desc_ind)) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].
     ap_info.snomed_codes_lbl != capf.snomed_codes_lbl)) OR ((((request->chart_section_list[secindex]
     .chart_group_list[grpindex].ap_info.snomed_cd_lbl_style != capf.snomed_cd_lbl_style)) OR ((((
     request->chart_section_list[secindex].chart_group_list[grpindex].ap_info.tcc_codes_ind != capf
     .tcc_codes_ind)) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].ap_info
     .tcc_desc_ind != capf.tcc_desc_ind)) OR ((((request->chart_section_list[secindex].
     chart_group_list[grpindex].ap_info.tcc_codes_lbl != capf.tcc_codes_lbl)) OR ((((request->
     chart_section_list[secindex].chart_group_list[grpindex].ap_info.tcc_cd_lbl_style != capf
     .tcc_cd_lbl_style)) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].
     ap_info.ap_history_flag != capf.ap_history_flag)) OR ((request->chart_section_list[secindex].
     chart_group_list[grpindex].ap_info.image_flag != capf.image_flag))) )) )) )) )) )) )) )) )) ))
     )) )
      update_ap_flag = 1
     ENDIF
     IF (capf.ap_cpt_long_text_id != 0)
      IF (trim(request->chart_section_list[secindex].chart_group_list[grpindex].ap_info.cpt_long_text
       ) != trim(ltr.long_text))
       update_ap_flag = 1
      ENDIF
     ELSEIF (size(trim(request->chart_section_list[secindex].chart_group_list[grpindex].ap_info.
       cpt_long_text)) > 0)
      update_ap_flag = 1
     ENDIF
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_AP_FORMAT","CHECKAPSECTION",1,1)
   IF (update_ap_flag=1)
    CALL update_ap(secindex,grpindex)
   ENDIF
 END ;Subroutine
 SUBROUTINE (add_vert_format(sindex=i4(val),gindex=i4(val)) =null)
   CALL log_message("In add_vert_format()",log_level_debug)
   INSERT  FROM chart_vert_format cvf
    SET cvf.chart_group_id = request->chart_section_list[sindex].chart_group_list[gindex].
     chart_group_id, cvf.test_lbl_order = request->chart_section_list[sindex].chart_group_list[gindex
     ].vertical_info_list[1].test_lbl_order, cvf.units_lbl_order = request->chart_section_list[sindex
     ].chart_group_list[gindex].vertical_info_list[1].units_lbl_order,
     cvf.refer_lbl_order = request->chart_section_list[sindex].chart_group_list[gindex].
     vertical_info_list[1].refer_lbl_order, cvf.perfid_lbl_order = request->chart_section_list[sindex
     ].chart_group_list[gindex].vertical_info_list[1].perfid_lbl_order, cvf.test_lbl_pos = request->
     chart_section_list[sindex].chart_group_list[gindex].vertical_info_list[1].test_lbl_pos,
     cvf.units_lbl_pos = request->chart_section_list[sindex].chart_group_list[gindex].
     vertical_info_list[1].units_lbl_pos, cvf.refer_lbl_pos = request->chart_section_list[sindex].
     chart_group_list[gindex].vertical_info_list[1].refer_lbl_pos, cvf.perfid_lbl_pos = request->
     chart_section_list[sindex].chart_group_list[gindex].vertical_info_list[1].perfid_lbl_pos,
     cvf.test_lbl = request->chart_section_list[sindex].chart_group_list[gindex].vertical_info_list[1
     ].test_lbl, cvf.units_lbl = request->chart_section_list[sindex].chart_group_list[gindex].
     vertical_info_list[1].units_lbl, cvf.ref_range_lbl = request->chart_section_list[sindex].
     chart_group_list[gindex].vertical_info_list[1].ref_range_lbl,
     cvf.perfid_lbl = request->chart_section_list[sindex].chart_group_list[gindex].
     vertical_info_list[1].perfid_lbl, cvf.date_lbl = request->chart_section_list[sindex].
     chart_group_list[gindex].vertical_info_list[1].date_lbl, cvf.staydays_lbl = request->
     chart_section_list[sindex].chart_group_list[gindex].vertical_info_list[1].staydays_lbl,
     cvf.time_lbl = request->chart_section_list[sindex].chart_group_list[gindex].vertical_info_list[1
     ].time_lbl, cvf.date_order = request->chart_section_list[sindex].chart_group_list[gindex].
     vertical_info_list[1].date_order, cvf.ref_rng_form_flag = request->chart_section_list[sindex].
     chart_group_list[gindex].vertical_info_list[1].ref_rng_form_flag,
     cvf.rslt_seq_flag = request->chart_section_list[sindex].chart_group_list[gindex].
     vertical_info_list[1].rslt_seq_flag, cvf.ftnote_loc_flag = request->chart_section_list[sindex].
     chart_group_list[gindex].vertical_info_list[1].ftnote_loc_flag, cvf.interp_loc_flag = request->
     chart_section_list[sindex].chart_group_list[gindex].vertical_info_list[1].interp_loc_flag,
     cvf.staydays_order = request->chart_section_list[sindex].chart_group_list[gindex].
     vertical_info_list[1].staydays_order, cvf.time_order = request->chart_section_list[sindex].
     chart_group_list[gindex].vertical_info_list[1].time_order, cvf.time_format_flag = request->
     chart_section_list[sindex].chart_group_list[gindex].vertical_info_list[1].time_format_flag,
     cvf.date_mask = request->chart_section_list[sindex].chart_group_list[gindex].vertical_info_list[
     1].date_mask, cvf.time_mask = request->chart_section_list[sindex].chart_group_list[gindex].
     vertical_info_list[1].time_mask, cvf.date_format_cd = request->chart_section_list[sindex].
     chart_group_list[gindex].vertical_info_list[1].date_format_cd,
     cvf.staydays_form_flag = request->chart_section_list[sindex].chart_group_list[gindex].
     vertical_info_list[1].staydays_form_flag, cvf.reslt_start_col = request->chart_section_list[
     sindex].chart_group_list[gindex].vertical_info_list[1].rslt_start_col, cvf.encntr_alias_lbl =
     request->chart_section_list[sindex].chart_group_list[gindex].vertical_info_list[1].
     encntr_alias_lbl,
     cvf.encntr_alias_order = request->chart_section_list[sindex].chart_group_list[gindex].
     vertical_info_list[1].encntr_alias_order, cvf.flowsheet_ind = request->chart_section_list[sindex
     ].chart_group_list[gindex].vertical_info_list[1].flowsheet_ind, cvf.active_ind = 1,
     cvf.active_status_cd = reqdata->active_status_cd, cvf.active_status_dt_tm = cnvtdatetime(sysdate
      ), cvf.active_status_prsnl_id = reqinfo->updt_id,
     cvf.updt_cnt = 0, cvf.updt_dt_tm = cnvtdatetime(sysdate), cvf.updt_id = reqinfo->updt_id,
     cvf.updt_task = reqinfo->updt_task, cvf.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   CALL error_and_zero_check(curqual,"CHART_VERT_FORMAT","ADD_VERT_FORMAT",1,1)
 END ;Subroutine
 SUBROUTINE (update_vert(secindex=i4(val),grpindex=i4(val)) =null)
   CALL log_message("In update_vert()",log_level_debug)
   UPDATE  FROM chart_vert_format cvf
    SET cvf.test_lbl_order = request->chart_section_list[secindex].chart_group_list[grpindex].
     vertical_info_list[1].test_lbl_order, cvf.units_lbl_order = request->chart_section_list[secindex
     ].chart_group_list[grpindex].vertical_info_list[1].units_lbl_order, cvf.refer_lbl_order =
     request->chart_section_list[secindex].chart_group_list[grpindex].vertical_info_list[1].
     refer_lbl_order,
     cvf.perfid_lbl_order = request->chart_section_list[secindex].chart_group_list[grpindex].
     vertical_info_list[1].perfid_lbl_order, cvf.test_lbl_pos = request->chart_section_list[secindex]
     .chart_group_list[grpindex].vertical_info_list[1].test_lbl_pos, cvf.units_lbl_pos = request->
     chart_section_list[secindex].chart_group_list[grpindex].vertical_info_list[1].units_lbl_pos,
     cvf.refer_lbl_pos = request->chart_section_list[secindex].chart_group_list[grpindex].
     vertical_info_list[1].refer_lbl_pos, cvf.perfid_lbl_pos = request->chart_section_list[secindex].
     chart_group_list[grpindex].vertical_info_list[1].perfid_lbl_pos, cvf.test_lbl = request->
     chart_section_list[secindex].chart_group_list[grpindex].vertical_info_list[1].test_lbl,
     cvf.units_lbl = request->chart_section_list[secindex].chart_group_list[grpindex].
     vertical_info_list[1].units_lbl, cvf.ref_range_lbl = request->chart_section_list[secindex].
     chart_group_list[grpindex].vertical_info_list[1].ref_range_lbl, cvf.perfid_lbl = request->
     chart_section_list[secindex].chart_group_list[grpindex].vertical_info_list[1].perfid_lbl,
     cvf.date_lbl = request->chart_section_list[secindex].chart_group_list[grpindex].
     vertical_info_list[1].date_lbl, cvf.staydays_lbl = request->chart_section_list[secindex].
     chart_group_list[grpindex].vertical_info_list[1].staydays_lbl, cvf.time_lbl = request->
     chart_section_list[secindex].chart_group_list[grpindex].vertical_info_list[1].time_lbl,
     cvf.date_order = request->chart_section_list[secindex].chart_group_list[grpindex].
     vertical_info_list[1].date_order, cvf.ref_rng_form_flag = request->chart_section_list[secindex].
     chart_group_list[grpindex].vertical_info_list[1].ref_rng_form_flag, cvf.rslt_seq_flag = request
     ->chart_section_list[secindex].chart_group_list[grpindex].vertical_info_list[1].rslt_seq_flag,
     cvf.ftnote_loc_flag = request->chart_section_list[secindex].chart_group_list[grpindex].
     vertical_info_list[1].ftnote_loc_flag, cvf.interp_loc_flag = request->chart_section_list[
     secindex].chart_group_list[grpindex].vertical_info_list[1].interp_loc_flag, cvf.staydays_order
      = request->chart_section_list[secindex].chart_group_list[grpindex].vertical_info_list[1].
     staydays_order,
     cvf.time_order = request->chart_section_list[secindex].chart_group_list[grpindex].
     vertical_info_list[1].time_order, cvf.time_format_flag = request->chart_section_list[secindex].
     chart_group_list[grpindex].vertical_info_list[1].time_format_flag, cvf.date_mask = request->
     chart_section_list[secindex].chart_group_list[grpindex].vertical_info_list[1].date_mask,
     cvf.time_mask = request->chart_section_list[secindex].chart_group_list[grpindex].
     vertical_info_list[1].time_mask, cvf.date_format_cd = request->chart_section_list[secindex].
     chart_group_list[grpindex].vertical_info_list[1].date_format_cd, cvf.staydays_form_flag =
     request->chart_section_list[secindex].chart_group_list[grpindex].vertical_info_list[1].
     staydays_form_flag,
     cvf.reslt_start_col = request->chart_section_list[secindex].chart_group_list[grpindex].
     vertical_info_list[1].rslt_start_col, cvf.encntr_alias_lbl = request->chart_section_list[
     secindex].chart_group_list[grpindex].vertical_info_list[1].encntr_alias_lbl, cvf
     .encntr_alias_order = request->chart_section_list[secindex].chart_group_list[grpindex].
     vertical_info_list[1].encntr_alias_order,
     cvf.flowsheet_ind = request->chart_section_list[secindex].chart_group_list[grpindex].
     vertical_info_list[1].flowsheet_ind, cvf.active_ind = 1, cvf.active_status_cd = reqdata->
     active_status_cd,
     cvf.updt_cnt = (cvf.updt_cnt+ 1), cvf.updt_dt_tm = cnvtdatetime(curdate,curtime), cvf.updt_id =
     reqinfo->updt_id,
     cvf.updt_applctx = reqinfo->updt_applctx, cvf.updt_task = reqinfo->updt_task
    WHERE (cvf.chart_group_id=request->chart_section_list[secindex].chart_group_list[grpindex].
    chart_group_id)
    WITH nocounter
   ;end update
   CALL error_and_zero_check(curqual,"CHART_VERT_FORMAT","UPDATE_VERT",1,1)
 END ;Subroutine
 SUBROUTINE (checkverticalsection(secindex=i4(val),grpindex=i4(val)) =null)
   CALL log_message("In CheckVerticalSection()",log_level_debug)
   DECLARE update_vertical_flag = i2 WITH noconstant(0), protect
   SELECT INTO "nl:"
    FROM chart_vert_format cvf
    WHERE (cvf.chart_group_id=request->chart_section_list[secindex].chart_group_list[grpindex].
    chart_group_id)
    DETAIL
     IF ((((request->chart_section_list[secindex].chart_group_list[grpindex].vertical_info_list[1].
     test_lbl_order != cvf.test_lbl_order)) OR ((((request->chart_section_list[secindex].
     chart_group_list[grpindex].vertical_info_list[1].units_lbl_order != cvf.units_lbl_order)) OR (((
     (request->chart_section_list[secindex].chart_group_list[grpindex].vertical_info_list[1].
     refer_lbl_order != cvf.refer_lbl_order)) OR ((((request->chart_section_list[secindex].
     chart_group_list[grpindex].vertical_info_list[1].perfid_lbl_order != cvf.perfid_lbl_order)) OR (
     (((request->chart_section_list[secindex].chart_group_list[grpindex].vertical_info_list[1].
     test_lbl_pos != cvf.test_lbl_pos)) OR ((((request->chart_section_list[secindex].
     chart_group_list[grpindex].vertical_info_list[1].units_lbl_pos != cvf.units_lbl_pos)) OR ((((
     request->chart_section_list[secindex].chart_group_list[grpindex].vertical_info_list[1].
     refer_lbl_pos != cvf.refer_lbl_pos)) OR ((((request->chart_section_list[secindex].
     chart_group_list[grpindex].vertical_info_list[1].perfid_lbl_pos != cvf.perfid_lbl_pos)) OR ((((
     request->chart_section_list[secindex].chart_group_list[grpindex].vertical_info_list[1].test_lbl
      != cvf.test_lbl)) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].
     vertical_info_list[1].units_lbl != cvf.units_lbl)) OR ((((request->chart_section_list[secindex].
     chart_group_list[grpindex].vertical_info_list[1].ref_range_lbl != cvf.ref_range_lbl)) OR ((((
     request->chart_section_list[secindex].chart_group_list[grpindex].vertical_info_list[1].
     perfid_lbl != cvf.perfid_lbl)) OR ((((request->chart_section_list[secindex].chart_group_list[
     grpindex].vertical_info_list[1].date_lbl != cvf.date_lbl)) OR ((((request->chart_section_list[
     secindex].chart_group_list[grpindex].vertical_info_list[1].staydays_lbl != cvf.staydays_lbl))
      OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].vertical_info_list[1].
     time_lbl != cvf.time_lbl)) OR ((((request->chart_section_list[secindex].chart_group_list[
     grpindex].vertical_info_list[1].date_order != cvf.date_order)) OR ((((request->
     chart_section_list[secindex].chart_group_list[grpindex].vertical_info_list[1].ref_rng_form_flag
      != cvf.ref_rng_form_flag)) OR ((((request->chart_section_list[secindex].chart_group_list[
     grpindex].vertical_info_list[1].rslt_seq_flag != cvf.rslt_seq_flag)) OR ((((request->
     chart_section_list[secindex].chart_group_list[grpindex].vertical_info_list[1].ftnote_loc_flag
      != cvf.ftnote_loc_flag)) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex
     ].vertical_info_list[1].interp_loc_flag != cvf.interp_loc_flag)) OR ((((request->
     chart_section_list[secindex].chart_group_list[grpindex].vertical_info_list[1].staydays_order !=
     cvf.staydays_order)) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].
     vertical_info_list[1].time_order != cvf.time_order)) OR ((((request->chart_section_list[secindex
     ].chart_group_list[grpindex].vertical_info_list[1].time_format_flag != cvf.time_format_flag))
      OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].vertical_info_list[1].
     date_mask != cvf.date_mask)) OR ((((request->chart_section_list[secindex].chart_group_list[
     grpindex].vertical_info_list[1].time_mask != cvf.time_mask)) OR ((((request->chart_section_list[
     secindex].chart_group_list[grpindex].vertical_info_list[1].date_format_cd != cvf.date_format_cd)
     ) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].vertical_info_list[1].
     staydays_form_flag != cvf.staydays_form_flag)) OR ((((request->chart_section_list[secindex].
     chart_group_list[grpindex].vertical_info_list[1].rslt_start_col != cvf.reslt_start_col)) OR ((((
     request->chart_section_list[secindex].chart_group_list[grpindex].vertical_info_list[1].
     encntr_alias_lbl != cvf.encntr_alias_lbl)) OR ((((request->chart_section_list[secindex].
     chart_group_list[grpindex].vertical_info_list[1].encntr_alias_order != cvf.encntr_alias_order))
      OR ((request->chart_section_list[secindex].chart_group_list[grpindex].vertical_info_list[1].
     flowsheet_ind != cvf.flowsheet_ind))) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
     )) )) )) )) )) )) )) )) )) )) )
      update_vertical_flag = 1
     ENDIF
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_VERT_FORMAT","CHECKVERTICALSECTION",1,1)
   IF (update_vertical_flag=1)
    CALL update_vert(secindex,grpindex)
   ENDIF
 END ;Subroutine
 SUBROUTINE (add_listview_format(sindex=i4(val),gindex=i4(val)) =null)
   CALL log_message("In add_listview_format()",log_level_debug)
   DECLARE chart_group_id_seq = f8 WITH noconstant(0.0), protect
   SET chart_group_next_seq = getnextchartgroupid(null)
   INSERT  FROM chart_listview_format clf
    SET clf.chart_listview_format_id = chart_group_next_seq, clf.chart_group_id = request->
     chart_section_list[sindex].chart_group_list[gindex].chart_group_id, clf.group_result_seq =
     request->chart_section_list[sindex].chart_group_list[gindex].listview_info_list.resseq_ind,
     clf.result_seq = request->chart_section_list[sindex].chart_group_list[gindex].listview_info_list
     .result_ord, clf.procedure_seq = request->chart_section_list[sindex].chart_group_list[gindex].
     listview_info_list.procedure_ord, clf.units_seq = request->chart_section_list[sindex].
     chart_group_list[gindex].listview_info_list.units_ord,
     clf.refrange_seq = request->chart_section_list[sindex].chart_group_list[gindex].
     listview_info_list.refrange_ord, clf.ref_rng_form_flag = request->chart_section_list[sindex].
     chart_group_list[gindex].listview_info_list.refrange_ind, clf.accession_seq = request->
     chart_section_list[sindex].chart_group_list[gindex].listview_info_list.accession_ord,
     clf.collected_dt_tm_seq = request->chart_section_list[sindex].chart_group_list[gindex].
     listview_info_list.collected_ord, clf.received_dt_tm_seq = request->chart_section_list[sindex].
     chart_group_list[gindex].listview_info_list.received_ord, clf.verified_dt_tm_seq = request->
     chart_section_list[sindex].chart_group_list[gindex].listview_info_list.verified_ord,
     clf.perf_ver_prsnl_seq = request->chart_section_list[sindex].chart_group_list[gindex].
     listview_info_list.perfver_ord, clf.spectype_seq = request->chart_section_list[sindex].
     chart_group_list[gindex].listview_info_list.spectype_ord, clf.result_txt = request->
     chart_section_list[sindex].chart_group_list[gindex].listview_info_list.result_lbl,
     clf.procedure_txt = request->chart_section_list[sindex].chart_group_list[gindex].
     listview_info_list.procedure_lbl, clf.units_txt = request->chart_section_list[sindex].
     chart_group_list[gindex].listview_info_list.units_lbl, clf.refrange_txt = request->
     chart_section_list[sindex].chart_group_list[gindex].listview_info_list.refrange_lbl,
     clf.accession_txt = request->chart_section_list[sindex].chart_group_list[gindex].
     listview_info_list.accession_lbl, clf.collected_txt = request->chart_section_list[sindex].
     chart_group_list[gindex].listview_info_list.collected_lbl, clf.received_txt = request->
     chart_section_list[sindex].chart_group_list[gindex].listview_info_list.received_lbl,
     clf.verified_txt = request->chart_section_list[sindex].chart_group_list[gindex].
     listview_info_list.verified_lbl, clf.perf_ver_prsnl_txt = request->chart_section_list[sindex].
     chart_group_list[gindex].listview_info_list.perfver_lbl, clf.spectype_txt = request->
     chart_section_list[sindex].chart_group_list[gindex].listview_info_list.spectype_lbl,
     clf.updt_cnt = 0, clf.updt_dt_tm = cnvtdatetime(sysdate), clf.updt_id = reqinfo->updt_id,
     clf.updt_task = reqinfo->updt_task, clf.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   CALL error_and_zero_check(curqual,"CHART_LISTVIEW_FORMAT","ADD_LISTVIEW_FORMAT",1,1)
 END ;Subroutine
 SUBROUTINE (update_listview(secindex=i4(val),grpindex=i4(val)) =null)
   CALL log_message("In update_listview()",log_level_debug)
   UPDATE  FROM chart_listview_format clf
    SET clf.group_result_seq = request->chart_section_list[sindex].chart_group_list[gindex].
     listview_info_list.resseq_ind, clf.result_seq = request->chart_section_list[sindex].
     chart_group_list[gindex].listview_info_list.result_ord, clf.procedure_seq = request->
     chart_section_list[sindex].chart_group_list[gindex].listview_info_list.procedure_ord,
     clf.units_seq = request->chart_section_list[sindex].chart_group_list[gindex].listview_info_list.
     units_ord, clf.refrange_seq = request->chart_section_list[sindex].chart_group_list[gindex].
     listview_info_list.refrange_ord, clf.ref_rng_form_flag = request->chart_section_list[sindex].
     chart_group_list[gindex].listview_info_list.refrange_ind,
     clf.accession_seq = request->chart_section_list[sindex].chart_group_list[gindex].
     listview_info_list.accession_ord, clf.collected_dt_tm_seq = request->chart_section_list[sindex].
     chart_group_list[gindex].listview_info_list.collected_ord, clf.received_dt_tm_seq = request->
     chart_section_list[sindex].chart_group_list[gindex].listview_info_list.received_ord,
     clf.verified_dt_tm_seq = request->chart_section_list[sindex].chart_group_list[gindex].
     listview_info_list.verified_ord, clf.perf_ver_prsnl_seq = request->chart_section_list[sindex].
     chart_group_list[gindex].listview_info_list.perfver_ord, clf.spectype_seq = request->
     chart_section_list[sindex].chart_group_list[gindex].listview_info_list.spectype_ord,
     clf.result_txt = request->chart_section_list[sindex].chart_group_list[gindex].listview_info_list
     .result_lbl, clf.procedure_txt = request->chart_section_list[sindex].chart_group_list[gindex].
     listview_info_list.procedure_lbl, clf.units_txt = request->chart_section_list[sindex].
     chart_group_list[gindex].listview_info_list.units_lbl,
     clf.refrange_txt = request->chart_section_list[sindex].chart_group_list[gindex].
     listview_info_list.refrange_lbl, clf.accession_txt = request->chart_section_list[sindex].
     chart_group_list[gindex].listview_info_list.accession_lbl, clf.collected_txt = request->
     chart_section_list[sindex].chart_group_list[gindex].listview_info_list.collected_lbl,
     clf.received_txt = request->chart_section_list[sindex].chart_group_list[gindex].
     listview_info_list.received_lbl, clf.verified_txt = request->chart_section_list[sindex].
     chart_group_list[gindex].listview_info_list.verified_lbl, clf.perf_ver_prsnl_txt = request->
     chart_section_list[sindex].chart_group_list[gindex].listview_info_list.perfver_lbl,
     clf.spectype_txt = request->chart_section_list[sindex].chart_group_list[gindex].
     listview_info_list.spectype_lbl, clf.updt_cnt = (clf.updt_cnt+ 1), clf.updt_dt_tm = cnvtdatetime
     (sysdate),
     clf.updt_id = reqinfo->updt_id, clf.updt_task = reqinfo->updt_task, clf.updt_applctx = reqinfo->
     updt_applctx
    WHERE (clf.chart_group_id=request->chart_section_list[secindex].chart_group_list[grpindex].
    chart_group_id)
    WITH nocounter
   ;end update
   CALL error_and_zero_check(curqual,"CHART_LISTVIEW_FORMAT","UPDATE_LISTVIEW",1,1)
 END ;Subroutine
 SUBROUTINE (checklistviewsection(sindex=i4(val),gindex=i4(val)) =null)
   CALL log_message("In CheckListviewSection()",log_level_debug)
   DECLARE update_listview_flag = i2 WITH noconstant(0), protect
   SELECT INTO "nl:"
    FROM chart_listview_format clf
    WHERE (clf.chart_group_id=request->chart_section_list[sindex].chart_group_list[gindex].
    chart_group_id)
    DETAIL
     IF ((((clf.group_result_seq != request->chart_section_list[sindex].chart_group_list[gindex].
     listview_info_list.resseq_ind)) OR ((((clf.result_seq != request->chart_section_list[sindex].
     chart_group_list[gindex].listview_info_list.result_ord)) OR ((((clf.procedure_seq != request->
     chart_section_list[sindex].chart_group_list[gindex].listview_info_list.procedure_ord)) OR ((((
     clf.units_seq != request->chart_section_list[sindex].chart_group_list[gindex].listview_info_list
     .units_ord)) OR ((((clf.refrange_seq != request->chart_section_list[sindex].chart_group_list[
     gindex].listview_info_list.refrange_ord)) OR ((((clf.ref_rng_form_flag != request->
     chart_section_list[sindex].chart_group_list[gindex].listview_info_list.refrange_ind)) OR ((((clf
     .accession_seq != request->chart_section_list[sindex].chart_group_list[gindex].
     listview_info_list.accession_ord)) OR ((((clf.collected_dt_tm_seq != request->
     chart_section_list[sindex].chart_group_list[gindex].listview_info_list.collected_ord)) OR ((((
     clf.received_dt_tm_seq != request->chart_section_list[sindex].chart_group_list[gindex].
     listview_info_list.received_ord)) OR ((((clf.verified_dt_tm_seq != request->chart_section_list[
     sindex].chart_group_list[gindex].listview_info_list.verified_ord)) OR ((((clf.perf_ver_prsnl_seq
      != request->chart_section_list[sindex].chart_group_list[gindex].listview_info_list.perfver_ord)
     ) OR ((((clf.spectype_seq != request->chart_section_list[sindex].chart_group_list[gindex].
     listview_info_list.spectype_ord)) OR ((((clf.result_txt != request->chart_section_list[sindex].
     chart_group_list[gindex].listview_info_list.result_lbl)) OR ((((clf.procedure_txt != request->
     chart_section_list[sindex].chart_group_list[gindex].listview_info_list.procedure_lbl)) OR ((((
     clf.units_txt != request->chart_section_list[sindex].chart_group_list[gindex].listview_info_list
     .units_lbl)) OR ((((clf.refrange_txt != request->chart_section_list[sindex].chart_group_list[
     gindex].listview_info_list.refrange_lbl)) OR ((((clf.accession_txt != request->
     chart_section_list[sindex].chart_group_list[gindex].listview_info_list.accession_lbl)) OR ((((
     clf.collected_txt != request->chart_section_list[sindex].chart_group_list[gindex].
     listview_info_list.collected_lbl)) OR ((((clf.received_txt != request->chart_section_list[sindex
     ].chart_group_list[gindex].listview_info_list.received_lbl)) OR ((((clf.verified_txt != request
     ->chart_section_list[sindex].chart_group_list[gindex].listview_info_list.verified_lbl)) OR ((clf
     .perf_ver_prsnl_txt != request->chart_section_list[sindex].chart_group_list[gindex].
     listview_info_list.perfver_lbl))) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )
      update_listview_flag = 1
     ENDIF
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_LISTVIEW_FORMAT","CHECKLISTVIEWSECTION",1,1)
   IF (update_listview_flag=1)
    CALL update_listview(sindex,gindex)
   ENDIF
 END ;Subroutine
 SUBROUTINE (add_zonal_format(sindex=i4(val),gindex=i4(val)) =null)
   CALL log_message("In add_zonal_format()",log_level_debug)
   INSERT  FROM chart_zonal_format czf
    SET czf.chart_group_id = request->chart_section_list[sindex].chart_group_list[gindex].
     chart_group_id, czf.ref_rng_form_flag = request->chart_section_list[sindex].chart_group_list[
     gindex].zonal_info_list[1].ref_rng_form_flag, czf.date_mask = request->chart_section_list[sindex
     ].chart_group_list[gindex].zonal_info_list[1].date_mask,
     czf.time_mask = request->chart_section_list[sindex].chart_group_list[gindex].zonal_info_list[1].
     time_mask, czf.date_format_cd = request->chart_section_list[sindex].chart_group_list[gindex].
     zonal_info_list[1].date_format_cd, czf.time_format_flag = request->chart_section_list[sindex].
     chart_group_list[gindex].zonal_info_list[1].time_format_flag,
     czf.rslt_seq_flag = request->chart_section_list[sindex].chart_group_list[gindex].
     zonal_info_list[1].rslt_seq_flag, czf.ftnote_loc_flag = request->chart_section_list[sindex].
     chart_group_list[gindex].zonal_info_list[1].ftnote_loc_flag, czf.interp_loc_flag = request->
     chart_section_list[sindex].chart_group_list[gindex].zonal_info_list[1].interp_loc_flag,
     czf.active_ind = 1, czf.active_status_cd = reqdata->active_status_cd, czf.active_status_dt_tm =
     cnvtdatetime(sysdate),
     czf.active_status_prsnl_id = reqinfo->updt_id, czf.updt_cnt = 0, czf.updt_dt_tm = cnvtdatetime(
      sysdate),
     czf.updt_id = reqinfo->updt_id, czf.updt_task = reqinfo->updt_task, czf.updt_applctx = reqinfo->
     updt_applctx
    WITH nocounter
   ;end insert
   CALL error_and_zero_check(curqual,"CHART_ZONAL_FORMAT","ADD_ZONAL_FORMAT",1,1)
 END ;Subroutine
 SUBROUTINE (add_zone(sindex=i4(val),gindex=i4(val),zindex=i4(val)) =null)
   CALL log_message("In add_zone()",log_level_debug)
   INSERT  FROM chart_zn_form_zone czfz
    SET czfz.chart_group_id = request->chart_section_list[sindex].chart_group_list[gindex].
     chart_group_id, czfz.zone_seq = request->chart_section_list[sindex].chart_group_list[gindex].
     zonal_info_list[zindex].zone_seq, czfz.test_lbl = request->chart_section_list[sindex].
     chart_group_list[gindex].zonal_info_list[zindex].test_lbl,
     czfz.units_lbl = request->chart_section_list[sindex].chart_group_list[gindex].zonal_info_list[
     zindex].units_lbl, czfz.ref_range_lbl = request->chart_section_list[sindex].chart_group_list[
     gindex].zonal_info_list[zindex].ref_range_lbl, czfz.alpha_abn_rslt_lbl = request->
     chart_section_list[sindex].chart_group_list[gindex].zonal_info_list[zindex].alpha_abn_rslt_lbl,
     czfz.all_rslt_lbl = request->chart_section_list[sindex].chart_group_list[gindex].
     zonal_info_list[zindex].all_rslt_lbl, czfz.crit_rslt_lbl = request->chart_section_list[sindex].
     chart_group_list[gindex].zonal_info_list[zindex].crit_rslt_lbl, czfz.high_rslt_lbl = request->
     chart_section_list[sindex].chart_group_list[gindex].zonal_info_list[zindex].high_rslt_lbl,
     czfz.low_rslt_lbl = request->chart_section_list[sindex].chart_group_list[gindex].
     zonal_info_list[zindex].low_rslt_lbl, czfz.normal_rslt_lbl = request->chart_section_list[sindex]
     .chart_group_list[gindex].zonal_info_list[zindex].normal_rslt_lbl, czfz.test_col = request->
     chart_section_list[sindex].chart_group_list[gindex].zonal_info_list[zindex].test_col,
     czfz.units_col = request->chart_section_list[sindex].chart_group_list[gindex].zonal_info_list[
     zindex].units_col, czfz.ref_range_col = request->chart_section_list[sindex].chart_group_list[
     gindex].zonal_info_list[zindex].ref_range_col, czfz.all_rslt_col = request->chart_section_list[
     sindex].chart_group_list[gindex].zonal_info_list[zindex].all_rslt_col,
     czfz.low_rslt_col = request->chart_section_list[sindex].chart_group_list[gindex].
     zonal_info_list[zindex].low_rslt_col, czfz.normal_rslt_col = request->chart_section_list[sindex]
     .chart_group_list[gindex].zonal_info_list[zindex].normal_rslt_col, czfz.high_rslt_col = request
     ->chart_section_list[sindex].chart_group_list[gindex].zonal_info_list[zindex].high_rslt_col,
     czfz.crit_rslt_col = request->chart_section_list[sindex].chart_group_list[gindex].
     zonal_info_list[zindex].crit_rslt_col, czfz.alpha_abn_rslt_col = request->chart_section_list[
     sindex].chart_group_list[gindex].zonal_info_list[zindex].alpha_abn_rslt_col, czfz.active_ind = 1,
     czfz.active_status_cd = reqdata->active_status_cd, czfz.active_status_dt_tm = cnvtdatetime(
      sysdate), czfz.active_status_prsnl_id = reqinfo->updt_id,
     czfz.updt_cnt = 0, czfz.updt_dt_tm = cnvtdatetime(sysdate), czfz.updt_id = reqinfo->updt_id,
     czfz.updt_task = reqinfo->updt_task, czfz.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   CALL error_and_zero_check(curqual,"CHART_ZN_FORM_ZONE","ADD_ZONE",1,1)
 END ;Subroutine
 SUBROUTINE (add_new_zonal_format(sindex=i4(val),gindex=i4(val)) =null)
   CALL log_message("In add_new_zonal_format()",log_level_debug)
   INSERT  FROM chart_zonal_format czf
    SET czf.chart_group_id = request->chart_section_list[sindex].chart_group_list[gindex].
     chart_group_id, czf.collect_date_lbl = request->chart_section_list[sindex].chart_group_list[
     gindex].new_zonal_info.collect_date_lbl, czf.collect_date_chk = request->chart_section_list[
     sindex].chart_group_list[gindex].new_zonal_info.collect_date_chk,
     czf.ref_rng_form_flag = request->chart_section_list[sindex].chart_group_list[gindex].
     new_zonal_info.ref_rng_form_flag, czf.date_mask = request->chart_section_list[sindex].
     chart_group_list[gindex].new_zonal_info.date_mask, czf.time_mask = request->chart_section_list[
     sindex].chart_group_list[gindex].new_zonal_info.time_mask,
     czf.date_format_cd = request->chart_section_list[sindex].chart_group_list[gindex].new_zonal_info
     .date_format_cd, czf.time_format_flag = request->chart_section_list[sindex].chart_group_list[
     gindex].new_zonal_info.time_format_flag, czf.rslt_seq_flag = request->chart_section_list[sindex]
     .chart_group_list[gindex].new_zonal_info.rslt_seq_flag,
     czf.ftnote_loc_flag = request->chart_section_list[sindex].chart_group_list[gindex].
     new_zonal_info.ftnote_loc_flag, czf.interp_loc_flag = request->chart_section_list[sindex].
     chart_group_list[gindex].new_zonal_info.interp_loc_flag, czf.order_group_ind = request->
     chart_section_list[sindex].chart_group_list[gindex].new_zonal_info.order_group_ind,
     czf.active_ind = 1, czf.active_status_cd = reqdata->active_status_cd, czf.active_status_dt_tm =
     cnvtdatetime(sysdate),
     czf.active_status_prsnl_id = reqinfo->updt_id, czf.updt_dt_tm = cnvtdatetime(sysdate), czf
     .updt_id = reqinfo->updt_id,
     czf.updt_task = reqinfo->updt_task, czf.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   CALL error_and_zero_check(curqual,"CHART_ZONAL_FORMAT","ADD_NEW_ZONAL_FORMAT",1,1)
 END ;Subroutine
 SUBROUTINE (add_new_zone(sindex=i4(val),gindex=i4(val),zindex=i4(val)) =null)
   CALL log_message("In add_new_zone()",log_level_debug)
   DECLARE x = i4 WITH noconstant(0), protect
   INSERT  FROM chart_dyn_zone_form cdfz
    SET cdfz.chart_group_id = request->chart_section_list[sindex].chart_group_list[gindex].
     chart_group_id, cdfz.zone_seq = request->chart_section_list[sindex].chart_group_list[gindex].
     new_zonal_info.zone_list[zindex].zone_seq, cdfz.proc_lbl = request->chart_section_list[sindex].
     chart_group_list[gindex].new_zonal_info.zone_list[zindex].proc_lbl,
     cdfz.units_lbl = request->chart_section_list[sindex].chart_group_list[gindex].new_zonal_info.
     zone_list[zindex].units_lbl, cdfz.ref_range_lbl = request->chart_section_list[sindex].
     chart_group_list[gindex].new_zonal_info.zone_list[zindex].ref_range_lbl, cdfz.proc_col = request
     ->chart_section_list[sindex].chart_group_list[gindex].new_zonal_info.zone_list[zindex].proc_col,
     cdfz.units_col = request->chart_section_list[sindex].chart_group_list[gindex].new_zonal_info.
     zone_list[zindex].units_col, cdfz.ref_range_col = request->chart_section_list[sindex].
     chart_group_list[gindex].new_zonal_info.zone_list[zindex].ref_range_col, cdfz.active_ind = 1,
     cdfz.active_status_cd = reqdata->active_status_cd, cdfz.active_status_dt_tm = cnvtdatetime(
      sysdate), cdfz.active_status_prsnl_id = reqinfo->updt_id,
     cdfz.updt_dt_tm = cnvtdatetime(sysdate), cdfz.updt_id = reqinfo->updt_id, cdfz.updt_task =
     reqinfo->updt_task,
     cdfz.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   CALL error_and_zero_check(curqual,"CHART_DYN_ZONE_FORM","ADD_NEW_ZONE",1,1)
   SET num_result_cols = size(request->chart_section_list[sindex].chart_group_list[gindex].
    new_zonal_info.zone_list[zindex].result_col_list,5)
   FOR (x = 1 TO num_result_cols)
     CALL add_result_col(sindex,gindex,zindex,x)
   ENDFOR
 END ;Subroutine
 SUBROUTINE (add_result_col(sindex=i4(val),gindex=i4(val),zindex=i4(val),cindex=i4(val)) =null)
   CALL log_message("In add_result_col()",log_level_debug)
   DECLARE x = i4 WITH noconstant(0), protect
   INSERT  FROM chart_zn_result_col czrc
    SET czrc.chart_group_id = request->chart_section_list[sindex].chart_group_list[gindex].
     chart_group_id, czrc.zone_seq = request->chart_section_list[sindex].chart_group_list[gindex].
     new_zonal_info.zone_list[zindex].zone_seq, czrc.column_seq = request->chart_section_list[sindex]
     .chart_group_list[gindex].new_zonal_info.zone_list[zindex].result_col_list[cindex].column_seq,
     czrc.col_index = request->chart_section_list[sindex].chart_group_list[gindex].new_zonal_info.
     zone_list[zindex].result_col_list[cindex].col_index, czrc.description = request->
     chart_section_list[sindex].chart_group_list[gindex].new_zonal_info.zone_list[zindex].
     result_col_list[cindex].description, czrc.active_ind = 1,
     czrc.active_status_cd = reqdata->active_status_cd, czrc.active_status_dt_tm = cnvtdatetime(
      sysdate), czrc.active_status_prsnl_id = reqinfo->updt_id,
     czrc.updt_dt_tm = cnvtdatetime(sysdate), czrc.updt_id = reqinfo->updt_id, czrc.updt_task =
     reqinfo->updt_task,
     czrc.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   CALL error_and_zero_check(curqual,"CHART_ZN_RESULT_COL","ADD_RESULT_COL",1,1)
   SET num_normalcy_cds = size(request->chart_section_list[sindex].chart_group_list[gindex].
    new_zonal_info.zone_list[zindex].result_col_list[cindex].normalcy_cds,5)
   FOR (x = 1 TO num_normalcy_cds)
     CALL add_normalcy_cd(sindex,gindex,zindex,cindex,x)
   ENDFOR
 END ;Subroutine
 SUBROUTINE (add_normalcy_cd(sindex=i4(val),gindex=i4(val),zindex=i4(val),cindex=i4(val),cdindex=i4(
   val)) =null)
   CALL log_message("In add_normalcy_cd()",log_level_debug)
   INSERT  FROM chart_zn_result_col_cds czrcc
    SET czrcc.chart_group_id = request->chart_section_list[sindex].chart_group_list[gindex].
     chart_group_id, czrcc.zone_seq = request->chart_section_list[sindex].chart_group_list[gindex].
     new_zonal_info.zone_list[zindex].zone_seq, czrcc.column_seq = request->chart_section_list[sindex
     ].chart_group_list[gindex].new_zonal_info.zone_list[zindex].result_col_list[cindex].column_seq,
     czrcc.normalcy_cd = request->chart_section_list[sindex].chart_group_list[gindex].new_zonal_info.
     zone_list[zindex].result_col_list[cindex].normalcy_cds[cdindex].code, czrcc.active_ind = 1,
     czrcc.active_status_cd = reqdata->active_status_cd,
     czrcc.active_status_dt_tm = cnvtdatetime(sysdate), czrcc.active_status_prsnl_id = reqinfo->
     updt_id, czrcc.updt_dt_tm = cnvtdatetime(sysdate),
     czrcc.updt_id = reqinfo->updt_id, czrcc.updt_task = reqinfo->updt_task, czrcc.updt_applctx =
     reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   CALL error_and_zero_check(curqual,"CHART_ZN_RESULT_COL_CDS","ADD_NORMALCY_CD",1,1)
 END ;Subroutine
 SUBROUTINE (update_zonal(secindex=i4(val),grpindex=i4(val)) =null)
   CALL log_message("In update_zonal()",log_level_debug)
   UPDATE  FROM chart_zonal_format czf
    SET czf.ref_rng_form_flag = request->chart_section_list[secindex].chart_group_list[grpindex].
     zonal_info_list[1].ref_rng_form_flag, czf.date_mask = request->chart_section_list[secindex].
     chart_group_list[grpindex].zonal_info_list[1].date_mask, czf.time_mask = request->
     chart_section_list[secindex].chart_group_list[grpindex].zonal_info_list[1].time_mask,
     czf.date_format_cd = request->chart_section_list[secindex].chart_group_list[grpindex].
     zonal_info_list[1].date_format_cd, czf.time_format_flag = request->chart_section_list[secindex].
     chart_group_list[grpindex].zonal_info_list[1].time_format_flag, czf.rslt_seq_flag = request->
     chart_section_list[secindex].chart_group_list[grpindex].zonal_info_list[1].rslt_seq_flag,
     czf.ftnote_loc_flag = request->chart_section_list[secindex].chart_group_list[grpindex].
     zonal_info_list[1].ftnote_loc_flag, czf.interp_loc_flag = request->chart_section_list[secindex].
     chart_group_list[grpindex].zonal_info_list[1].interp_loc_flag, czf.active_ind = 1,
     czf.active_status_cd = reqdata->active_status_cd, czf.updt_cnt = (czf.updt_cnt+ 1), czf
     .updt_dt_tm = cnvtdatetime(curdate,curtime),
     czf.updt_id = reqinfo->updt_id, czf.updt_applctx = reqinfo->updt_applctx, czf.updt_task =
     reqinfo->updt_task
    WHERE (czf.chart_group_id=request->chart_section_list[secindex].chart_group_list[grpindex].
    chart_group_id)
    WITH nocounter
   ;end update
   CALL error_and_zero_check(curqual,"CHART_ZONAL_FORMAT","UPDATE_ZONAL",1,1)
 END ;Subroutine
 SUBROUTINE (update_new_zonal(secindex=i4(val),grpindex=i4(val)) =null)
   CALL log_message("In update_new_zonal()",log_level_debug)
   UPDATE  FROM chart_zonal_format czf
    SET czf.collect_date_lbl = request->chart_section_list[secindex].chart_group_list[grpindex].
     new_zonal_info.collect_date_lbl, czf.collect_date_chk = request->chart_section_list[secindex].
     chart_group_list[grpindex].new_zonal_info.collect_date_chk, czf.ref_rng_form_flag = request->
     chart_section_list[secindex].chart_group_list[grpindex].new_zonal_info.ref_rng_form_flag,
     czf.date_mask = request->chart_section_list[secindex].chart_group_list[grpindex].new_zonal_info.
     date_mask, czf.time_mask = request->chart_section_list[secindex].chart_group_list[grpindex].
     new_zonal_info.time_mask, czf.date_format_cd = request->chart_section_list[secindex].
     chart_group_list[grpindex].new_zonal_info.date_format_cd,
     czf.time_format_flag = request->chart_section_list[secindex].chart_group_list[grpindex].
     new_zonal_info.time_format_flag, czf.rslt_seq_flag = request->chart_section_list[secindex].
     chart_group_list[grpindex].new_zonal_info.rslt_seq_flag, czf.ftnote_loc_flag = request->
     chart_section_list[secindex].chart_group_list[grpindex].new_zonal_info.ftnote_loc_flag,
     czf.interp_loc_flag = request->chart_section_list[secindex].chart_group_list[grpindex].
     new_zonal_info.interp_loc_flag, czf.order_group_ind = request->chart_section_list[secindex].
     chart_group_list[grpindex].new_zonal_info.order_group_ind, czf.active_ind = 1,
     czf.active_status_cd = reqdata->active_status_cd, czf.updt_cnt = (czf.updt_cnt+ 1), czf
     .updt_dt_tm = cnvtdatetime(curdate,curtime),
     czf.updt_id = reqinfo->updt_id, czf.updt_applctx = reqinfo->updt_applctx, czf.updt_task =
     reqinfo->updt_task
    WHERE (czf.chart_group_id=request->chart_section_list[secindex].chart_group_list[grpindex].
    chart_group_id)
    WITH nocounter
   ;end update
   CALL error_and_zero_check(curqual,"CHART_ZONAL_FORMAT","UPDATE_NEW_ZONAL",1,1)
 END ;Subroutine
 SUBROUTINE (checkoldzonalsection(secindex=i4(val),grpindex=i4(val)) =null)
   CALL log_message("In CheckOldZonalSection()",log_level_debug)
   DECLARE update_zonal_flag = i2 WITH noconstant(0), protect
   SELECT INTO "nl:"
    FROM chart_zonal_format czf
    WHERE (czf.chart_group_id=request->chart_section_list[secindex].chart_group_list[grpindex].
    chart_group_id)
    DETAIL
     IF ((((request->chart_section_list[secindex].chart_group_list[grpindex].zonal_info_list[1].
     ref_rng_form_flag != czf.ref_rng_form_flag)) OR ((((request->chart_section_list[secindex].
     chart_group_list[grpindex].zonal_info_list[1].date_mask != czf.date_mask)) OR ((((request->
     chart_section_list[secindex].chart_group_list[grpindex].zonal_info_list[1].time_mask != czf
     .time_mask)) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].
     zonal_info_list[1].date_format_cd != czf.date_format_cd)) OR ((((request->chart_section_list[
     secindex].chart_group_list[grpindex].zonal_info_list[1].time_format_flag != czf.time_format_flag
     )) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].zonal_info_list[1].
     rslt_seq_flag != czf.rslt_seq_flag)) OR ((((request->chart_section_list[secindex].
     chart_group_list[grpindex].zonal_info_list[1].ftnote_loc_flag != czf.ftnote_loc_flag)) OR ((
     request->chart_section_list[secindex].chart_group_list[grpindex].zonal_info_list[1].
     interp_loc_flag != czf.interp_loc_flag))) )) )) )) )) )) )) )
      update_zonal_flag = 1
     ENDIF
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_ZONAL_FORMAT","CHECKOLDZONALSECTION",1,1)
   IF (update_zonal_flag=1)
    CALL update_zonal(secindex,grpindex)
   ENDIF
   DELETE  FROM chart_zn_form_zone czfz
    WHERE (czfz.chart_group_id=request->chart_section_list[secindex].chart_group_list[grpindex].
    chart_group_id)
    WITH nocounter
   ;end delete
   CALL error_and_zero_check(curqual,"CHART_ZN_FORM_ZONE","CHECKOLDZONALSECTION",1,0)
   SET num_zones = size(request->chart_section_list[secindex].chart_group_list[grpindex].
    zonal_info_list,5)
   FOR (f = 1 TO num_zones)
     CALL add_zone(secindex,grpindex,f)
   ENDFOR
 END ;Subroutine
 SUBROUTINE (checknewzonalsection(secindex=i4(val),grpindex=i4(val)) =null)
   CALL log_message("In CheckNewZonalSection()",log_level_debug)
   DECLARE update_zonal_flag = i2 WITH noconstant(0), protect
   SELECT INTO "nl:"
    FROM chart_zonal_format czf
    WHERE (czf.chart_group_id=request->chart_section_list[secindex].chart_group_list[grpindex].
    chart_group_id)
    DETAIL
     IF ((((request->chart_section_list[secindex].chart_group_list[grpindex].new_zonal_info.
     ref_rng_form_flag != czf.ref_rng_form_flag)) OR ((((request->chart_section_list[secindex].
     chart_group_list[grpindex].new_zonal_info.date_mask != czf.date_mask)) OR ((((request->
     chart_section_list[secindex].chart_group_list[grpindex].new_zonal_info.time_mask != czf
     .time_mask)) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].
     new_zonal_info.date_format_cd != czf.date_format_cd)) OR ((((request->chart_section_list[
     secindex].chart_group_list[grpindex].new_zonal_info.time_format_flag != czf.time_format_flag))
      OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].new_zonal_info.
     rslt_seq_flag != czf.rslt_seq_flag)) OR ((((request->chart_section_list[secindex].
     chart_group_list[grpindex].new_zonal_info.ftnote_loc_flag != czf.ftnote_loc_flag)) OR ((((
     request->chart_section_list[secindex].chart_group_list[grpindex].new_zonal_info.interp_loc_flag
      != czf.interp_loc_flag)) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex
     ].new_zonal_info.collect_date_lbl != czf.collect_date_lbl)) OR ((((request->chart_section_list[
     secindex].chart_group_list[grpindex].new_zonal_info.order_group_ind != czf.order_group_ind)) OR
     ((request->chart_section_list[secindex].chart_group_list[grpindex].new_zonal_info.
     collect_date_chk != czf.collect_date_chk))) )) )) )) )) )) )) )) )) )) )
      update_zonal_flag = 1
     ENDIF
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_ZONAL_FORMAT","CHECKNEWZONALSECTION",1,1)
   IF (update_zonal_flag=1)
    CALL update_new_zonal(secindex,grpindex)
   ENDIF
   DELETE  FROM chart_zn_result_col_cds czrcc
    WHERE (czrcc.chart_group_id=request->chart_section_list[secindex].chart_group_list[grpindex].
    chart_group_id)
    WITH nocounter
   ;end delete
   CALL error_and_zero_check(curqual,"CHART_ZN_RESULT_COL_CDS","CHECKNEWZONALSECTION",1,0)
   DELETE  FROM chart_zn_result_col czrc
    WHERE (czrc.chart_group_id=request->chart_section_list[secindex].chart_group_list[grpindex].
    chart_group_id)
    WITH nocounter
   ;end delete
   CALL error_and_zero_check(curqual,"CHART_ZN_RESULT_COL","CHECKNEWZONALSECTION",1,0)
   DELETE  FROM chart_dyn_zone_form cdfz
    WHERE (cdfz.chart_group_id=request->chart_section_list[secindex].chart_group_list[grpindex].
    chart_group_id)
    WITH nocounter
   ;end delete
   CALL error_and_zero_check(curqual,"CHART_DYN_ZONE_FORM","CHECKNEWZONALSECTION",1,0)
   SET num_zones = size(request->chart_section_list[secindex].chart_group_list[grpindex].
    new_zonal_info.zone_list,5)
   FOR (f = 1 TO num_zones)
     CALL add_new_zone(secindex,grpindex,f)
   ENDFOR
 END ;Subroutine
 SUBROUTINE (add_hla_format(sindex=i4(val),gindex=i4(val)) =null)
   CALL log_message("In add_hla_format()",log_level_debug)
   INSERT  FROM chart_hla_format hla
    SET hla.chart_group_id = request->chart_section_list[sindex].chart_group_list[gindex].
     chart_group_id, hla.hla_type = request->chart_section_list[sindex].chart_group_list[gindex].
     hla_info.hla_type, hla.line_indicator = request->chart_section_list[sindex].chart_group_list[
     gindex].hla_info.line_ind,
     hla.result_seq_flag = request->chart_section_list[sindex].chart_group_list[gindex].hla_info.
     rslt_seq, hla.prsn_name_label = request->chart_section_list[sindex].chart_group_list[gindex].
     hla_info.prsn_name_lbl, hla.date_label = request->chart_section_list[sindex].chart_group_list[
     gindex].hla_info.date_lbl,
     hla.mrn_label = request->chart_section_list[sindex].chart_group_list[gindex].hla_info.mrn_lbl,
     hla.relation_label = request->chart_section_list[sindex].chart_group_list[gindex].hla_info.
     relation_lbl, hla.abo_rh_label = request->chart_section_list[sindex].chart_group_list[gindex].
     hla_info.abo_rh_lbl,
     hla.haploid1_label = request->chart_section_list[sindex].chart_group_list[gindex].hla_info.
     haploid1_lbl, hla.haploid2_label = request->chart_section_list[sindex].chart_group_list[gindex].
     hla_info.haploid2_lbl, hla.haplotype1_label = request->chart_section_list[sindex].
     chart_group_list[gindex].hla_info.haplotype1_lbl,
     hla.haplotype2_label = request->chart_section_list[sindex].chart_group_list[gindex].hla_info.
     haplotype2_lbl, hla.haploid1_order = request->chart_section_list[sindex].chart_group_list[gindex
     ].hla_info.haploid1_odr, hla.haploid2_order = request->chart_section_list[sindex].
     chart_group_list[gindex].hla_info.haploid2_odr,
     hla.haplotype1_order = request->chart_section_list[sindex].chart_group_list[gindex].hla_info.
     haplotype1_odr, hla.haplotype2_order = request->chart_section_list[sindex].chart_group_list[
     gindex].hla_info.haplotype2_odr, hla.prsn_name_order = request->chart_section_list[sindex].
     chart_group_list[gindex].hla_info.prsn_name_odr,
     hla.date_order = request->chart_section_list[sindex].chart_group_list[gindex].hla_info.date_odr,
     hla.mrn_order = request->chart_section_list[sindex].chart_group_list[gindex].hla_info.mrn_odr,
     hla.relation_order = request->chart_section_list[sindex].chart_group_list[gindex].hla_info.
     relation_odr,
     hla.abo_rh_order = request->chart_section_list[sindex].chart_group_list[gindex].hla_info.
     abo_rh_odr, hla.result_order = request->chart_section_list[sindex].chart_group_list[gindex].
     hla_info.result_odr, hla.active_ind = 1,
     hla.active_status_cd = reqdata->active_status_cd, hla.active_status_dt_tm = cnvtdatetime(sysdate
      ), hla.active_status_prsnl_id = reqinfo->updt_id,
     hla.updt_cnt = 0, hla.updt_dt_tm = cnvtdatetime(sysdate), hla.updt_id = reqinfo->updt_id,
     hla.updt_applctx = reqinfo->updt_applctx, hla.updt_task = reqinfo->updt_task, hla.prsn_name_rpt
      = request->chart_section_list[sindex].chart_group_list[gindex].hla_info.prsn_name_rpt,
     hla.date_rpt = request->chart_section_list[sindex].chart_group_list[gindex].hla_info.date_rpt,
     hla.mrn_rpt = request->chart_section_list[sindex].chart_group_list[gindex].hla_info.mrn_rpt, hla
     .relation_rpt = request->chart_section_list[sindex].chart_group_list[gindex].hla_info.
     relation_rpt,
     hla.rh_ind = request->chart_section_list[sindex].chart_group_list[gindex].hla_info.rh_ind, hla
     .abo_rpt = request->chart_section_list[sindex].chart_group_list[gindex].hla_info.abo_rpt
    WITH nocounter
   ;end insert
   CALL error_and_zero_check(curqual,"CHART_HLA_FORMAT","ADD_HLA_FORMAT",1,1)
 END ;Subroutine
 SUBROUTINE (update_hla(secindex=i4(val),grpindex=i4(val)) =null)
   CALL log_message("In update_hla()",log_level_debug)
   UPDATE  FROM chart_hla_format hla
    SET hla.hla_type = request->chart_section_list[secindex].chart_group_list[grpindex].hla_info.
     hla_type, hla.line_indicator = request->chart_section_list[secindex].chart_group_list[grpindex].
     hla_info.line_ind, hla.result_seq_flag = request->chart_section_list[secindex].chart_group_list[
     grpindex].hla_info.rslt_seq,
     hla.prsn_name_label = request->chart_section_list[secindex].chart_group_list[grpindex].hla_info.
     prsn_name_lbl, hla.date_label = request->chart_section_list[secindex].chart_group_list[grpindex]
     .hla_info.date_lbl, hla.mrn_label = request->chart_section_list[secindex].chart_group_list[
     grpindex].hla_info.mrn_lbl,
     hla.relation_label = request->chart_section_list[secindex].chart_group_list[grpindex].hla_info.
     relation_lbl, hla.abo_rh_label = request->chart_section_list[secindex].chart_group_list[grpindex
     ].hla_info.abo_rh_lbl, hla.haploid1_label = request->chart_section_list[secindex].
     chart_group_list[grpindex].hla_info.haploid1_lbl,
     hla.haploid2_label = request->chart_section_list[secindex].chart_group_list[grpindex].hla_info.
     haploid2_lbl, hla.haplotype1_label = request->chart_section_list[secindex].chart_group_list[
     grpindex].hla_info.haplotype1_lbl, hla.haplotype2_label = request->chart_section_list[secindex].
     chart_group_list[grpindex].hla_info.haplotype2_lbl,
     hla.haploid1_order = request->chart_section_list[secindex].chart_group_list[grpindex].hla_info.
     haploid1_odr, hla.haploid2_order = request->chart_section_list[secindex].chart_group_list[
     grpindex].hla_info.haploid2_odr, hla.haplotype1_order = request->chart_section_list[secindex].
     chart_group_list[grpindex].hla_info.haplotype1_odr,
     hla.haplotype2_order = request->chart_section_list[secindex].chart_group_list[grpindex].hla_info
     .haplotype2_odr, hla.prsn_name_order = request->chart_section_list[secindex].chart_group_list[
     grpindex].hla_info.prsn_name_odr, hla.date_order = request->chart_section_list[secindex].
     chart_group_list[grpindex].hla_info.date_odr,
     hla.mrn_order = request->chart_section_list[secindex].chart_group_list[grpindex].hla_info.
     mrn_odr, hla.relation_order = request->chart_section_list[secindex].chart_group_list[grpindex].
     hla_info.relation_odr, hla.abo_rh_order = request->chart_section_list[secindex].
     chart_group_list[grpindex].hla_info.abo_rh_odr,
     hla.result_order = request->chart_section_list[secindex].chart_group_list[grpindex].hla_info.
     result_odr, hla.active_ind = 1, hla.active_status_cd = reqdata->active_status_cd,
     hla.updt_cnt = (hla.updt_cnt+ 1), hla.updt_dt_tm = cnvtdatetime(curdate,curtime), hla.updt_id =
     reqinfo->updt_id,
     hla.updt_applctx = reqinfo->updt_applctx, hla.updt_task = reqinfo->updt_task, hla.prsn_name_rpt
      = request->chart_section_list[secindex].chart_group_list[grpindex].hla_info.prsn_name_rpt,
     hla.date_rpt = request->chart_section_list[secindex].chart_group_list[grpindex].hla_info.
     date_rpt, hla.mrn_rpt = request->chart_section_list[secindex].chart_group_list[grpindex].
     hla_info.mrn_rpt, hla.relation_rpt = request->chart_section_list[secindex].chart_group_list[
     grpindex].hla_info.relation_rpt,
     hla.rh_ind = request->chart_section_list[secindex].chart_group_list[grpindex].hla_info.rh_ind,
     hla.abo_rpt = request->chart_section_list[secindex].chart_group_list[grpindex].hla_info.abo_rpt
    WHERE (hla.chart_group_id=request->chart_section_list[secindex].chart_group_list[grpindex].
    chart_group_id)
    WITH nocounter
   ;end update
   CALL error_and_zero_check(curqual,"CHART_HLA_FORMAT","UPDATE_HLA",1,1)
 END ;Subroutine
 SUBROUTINE checkhlasection(secindex,grpindex)
   CALL log_message("In CheckHlaSection()",log_level_debug)
   DECLARE update_hla_flag = i2 WITH noconstant(0), protect
   SELECT INTO "nl:"
    FROM chart_hla_format hla
    WHERE (hla.chart_group_id=request->chart_section_list[secindex].chart_group_list[grpindex].
    chart_group_id)
    DETAIL
     IF ((((request->chart_section_list[secindex].chart_group_list[grpindex].hla_info.hla_type != hla
     .hla_type)) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].hla_info.
     line_ind != hla.line_indicator)) OR ((((request->chart_section_list[secindex].chart_group_list[
     grpindex].hla_info.rslt_seq != hla.result_seq_flag)) OR ((((request->chart_section_list[secindex
     ].chart_group_list[grpindex].hla_info.prsn_name_lbl != hla.prsn_name_label)) OR ((((request->
     chart_section_list[secindex].chart_group_list[grpindex].hla_info.date_lbl != hla.date_label))
      OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].hla_info.mrn_lbl != hla
     .mrn_label)) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].hla_info.
     relation_lbl != hla.relation_label)) OR ((((request->chart_section_list[secindex].
     chart_group_list[grpindex].hla_info.abo_rh_lbl != hla.abo_rh_label)) OR ((((request->
     chart_section_list[secindex].chart_group_list[grpindex].hla_info.haploid1_lbl != hla
     .haploid1_label)) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].
     hla_info.haploid2_lbl != hla.haploid2_label)) OR ((((request->chart_section_list[secindex].
     chart_group_list[grpindex].hla_info.haplotype1_lbl != hla.haplotype1_label)) OR ((((request->
     chart_section_list[secindex].chart_group_list[grpindex].hla_info.haplotype2_lbl != hla
     .haplotype2_label)) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].
     hla_info.haploid1_odr != hla.haploid1_order)) OR ((((request->chart_section_list[secindex].
     chart_group_list[grpindex].hla_info.haploid2_odr != hla.haploid2_order)) OR ((((request->
     chart_section_list[secindex].chart_group_list[grpindex].hla_info.haplotype1_odr != hla
     .haplotype1_order)) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].
     hla_info.haplotype2_odr != hla.haplotype2_order)) OR ((((request->chart_section_list[secindex].
     chart_group_list[grpindex].hla_info.prsn_name_odr != hla.prsn_name_order)) OR ((((request->
     chart_section_list[secindex].chart_group_list[grpindex].hla_info.date_odr != hla.date_order))
      OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].hla_info.mrn_odr != hla
     .mrn_order)) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].hla_info.
     relation_odr != hla.relation_order)) OR ((((request->chart_section_list[secindex].
     chart_group_list[grpindex].hla_info.abo_rh_odr != hla.abo_rh_order)) OR ((((request->
     chart_section_list[secindex].chart_group_list[grpindex].hla_info.result_odr != hla.result_order)
     ) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].hla_info.prsn_name_rpt
      != hla.prsn_name_rpt)) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].
     hla_info.date_rpt != hla.date_rpt)) OR ((((request->chart_section_list[secindex].
     chart_group_list[grpindex].hla_info.mrn_rpt != hla.mrn_rpt)) OR ((((request->chart_section_list[
     secindex].chart_group_list[grpindex].hla_info.relation_rpt != hla.relation_rpt)) OR ((((request
     ->chart_section_list[secindex].chart_group_list[grpindex].hla_info.rh_ind != hla.rh_ind)) OR ((
     request->chart_section_list[secindex].chart_group_list[grpindex].hla_info.abo_rpt != hla.abo_rpt
     ))) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )
      update_hla_flag = 1
     ENDIF
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_HLA_FORMAT","CHECKHLASECTION",1,1)
   IF (update_hla_flag=1)
    CALL update_hla(secindex,grpindex)
   ENDIF
 END ;Subroutine
 SUBROUTINE (add_doc_format(sindex=i4(val),gindex=i4(val)) =null)
   CALL log_message("In add_doc_format()",log_level_debug)
   INSERT  FROM chart_doc_format doc
    SET doc.chart_group_id = request->chart_section_list[sindex].chart_group_list[gindex].
     chart_group_id, doc.doc_type_flag = request->chart_section_list[sindex].chart_group_list[gindex]
     .doc_info.doc_type, doc.result_seq_flag = request->chart_section_list[sindex].chart_group_list[
     gindex].doc_info.rslt_seq,
     doc.page_brk_ind = request->chart_section_list[sindex].chart_group_list[gindex].doc_info.
     pgbrk_ind, doc.exclude_img_mdoc_ind = request->chart_section_list[sindex].chart_group_list[
     gindex].doc_info.exclude_img_mdoc_ind, doc.include_img_header_ind = request->chart_section_list[
     sindex].chart_group_list[gindex].doc_info.include_img_head_ind,
     doc.include_img_footer_ind = request->chart_section_list[sindex].chart_group_list[gindex].
     doc_info.include_img_foot_ind, doc.active_ind = 1, doc.active_status_cd = reqdata->
     active_status_cd,
     doc.active_status_dt_tm = cnvtdatetime(sysdate), doc.active_status_prsnl_id = reqinfo->updt_id,
     doc.updt_cnt = 0,
     doc.updt_dt_tm = cnvtdatetime(sysdate), doc.updt_id = reqinfo->updt_id, doc.updt_applctx =
     reqinfo->updt_applctx,
     doc.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   CALL error_and_zero_check(curqual,"CHART_DOC_FORMAT","ADD_DOC_FORMAT",1,1)
 END ;Subroutine
 SUBROUTINE (update_doc(secindex=i4(val),grpindex=i4(val)) =null)
   CALL log_message("In update_doc()",log_level_debug)
   UPDATE  FROM chart_doc_format doc
    SET doc.doc_type_flag = request->chart_section_list[secindex].chart_group_list[grpindex].doc_info
     .doc_type, doc.result_seq_flag = request->chart_section_list[secindex].chart_group_list[grpindex
     ].doc_info.rslt_seq, doc.page_brk_ind = request->chart_section_list[secindex].chart_group_list[
     grpindex].doc_info.pgbrk_ind,
     doc.exclude_img_mdoc_ind = request->chart_section_list[secindex].chart_group_list[grpindex].
     doc_info.exclude_img_mdoc_ind, doc.include_img_header_ind = request->chart_section_list[secindex
     ].chart_group_list[grpindex].doc_info.include_img_head_ind, doc.include_img_footer_ind = request
     ->chart_section_list[secindex].chart_group_list[grpindex].doc_info.include_img_foot_ind,
     doc.active_ind = 1, doc.active_status_cd = reqdata->active_status_cd, doc.updt_cnt = (doc
     .updt_cnt+ 1),
     doc.updt_dt_tm = cnvtdatetime(curdate,curtime), doc.updt_id = reqinfo->updt_id, doc.updt_applctx
      = reqinfo->updt_applctx,
     doc.updt_task = reqinfo->updt_task
    WHERE (doc.chart_group_id=request->chart_section_list[secindex].chart_group_list[grpindex].
    chart_group_id)
    WITH nocounter
   ;end update
   CALL error_and_zero_check(curqual,"CHART_DOC_FORMAT","UPDATE_DOC",1,1)
 END ;Subroutine
 SUBROUTINE (checkdocsection(secindex=i4(val),grpindex=i4(val)) =null)
   CALL log_message("In CheckDocSection()",log_level_debug)
   DECLARE update_doc_flag = i2 WITH noconstant(0), protect
   SELECT INTO "nl:"
    FROM chart_doc_format doc
    WHERE (doc.chart_group_id=request->chart_section_list[secindex].chart_group_list[grpindex].
    chart_group_id)
    DETAIL
     IF ((((request->chart_section_list[secindex].chart_group_list[grpindex].doc_info.rslt_seq != doc
     .result_seq_flag)) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].
     doc_info.pgbrk_ind != doc.page_brk_ind)) OR ((((request->chart_section_list[secindex].
     chart_group_list[grpindex].doc_info.exclude_img_mdoc_ind != doc.exclude_img_mdoc_ind)) OR ((((
     request->chart_section_list[secindex].chart_group_list[grpindex].doc_info.include_img_head_ind
      != doc.include_img_header_ind)) OR ((((request->chart_section_list[secindex].chart_group_list[
     grpindex].doc_info.include_img_foot_ind != doc.include_img_footer_ind)) OR ((request->
     chart_section_list[secindex].chart_group_list[grpindex].doc_info.doc_type != doc.doc_type_flag)
     )) )) )) )) )) )
      update_doc_flag = 1
     ENDIF
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_DOC_FORMAT","CHECKDOCSECTION",1,1)
   IF (update_doc_flag=1)
    CALL update_doc(secindex,grpindex)
   ENDIF
 END ;Subroutine
 SUBROUTINE (add_gl_format(sindex=i4(val),gindex=i4(val)) =null)
   CALL log_message("In add_gl_format()",log_level_debug)
   INSERT  FROM chart_gl_format gl
    SET gl.chart_group_id = request->chart_section_list[sindex].chart_group_list[gindex].
     chart_group_id, gl.result_seq_flag = request->chart_section_list[sindex].chart_group_list[gindex
     ].gl_info.rslt_seq, gl.group_style = request->chart_section_list[sindex].chart_group_list[gindex
     ].gl_info.group_style,
     gl.active_ind = 1, gl.active_status_cd = reqdata->active_status_cd, gl.active_status_dt_tm =
     cnvtdatetime(sysdate),
     gl.active_status_prsnl_id = reqinfo->updt_id, gl.updt_cnt = 0, gl.updt_dt_tm = cnvtdatetime(
      sysdate),
     gl.updt_id = reqinfo->updt_id, gl.updt_applctx = reqinfo->updt_applctx, gl.updt_task = reqinfo->
     updt_task
    WITH nocounter
   ;end insert
   CALL error_and_zero_check(curqual,"CHART_GL_FORMAT","ADD_GL_FORMAT",1,1)
 END ;Subroutine
 SUBROUTINE (update_gl(secindex=i4(val),grpindex=i4(val)) =null)
   CALL log_message("In update_gl()",log_level_debug)
   UPDATE  FROM chart_gl_format gl
    SET gl.result_seq_flag = request->chart_section_list[secindex].chart_group_list[grpindex].gl_info
     .rslt_seq, gl.group_style = request->chart_section_list[secindex].chart_group_list[grpindex].
     gl_info.group_style, gl.active_ind = 1,
     gl.active_status_cd = reqdata->active_status_cd, gl.updt_cnt = (gl.updt_cnt+ 1), gl.updt_dt_tm
      = cnvtdatetime(curdate,curtime),
     gl.updt_id = reqinfo->updt_id, gl.updt_applctx = reqinfo->updt_applctx, gl.updt_task = reqinfo->
     updt_task
    WHERE (gl.chart_group_id=request->chart_section_list[secindex].chart_group_list[grpindex].
    chart_group_id)
    WITH nocounter
   ;end update
   CALL error_and_zero_check(curqual,"CHART_GL_FORMAT","UPDATE_GL",1,1)
 END ;Subroutine
 SUBROUTINE (checklabtextsection(secindex=i4(val),grpindex=i4(val)) =null)
   CALL log_message("In CheckLabTextSection()",log_level_debug)
   DECLARE update_labtext_flag = i2 WITH noconstant(0), protect
   SELECT INTO "nl:"
    FROM chart_gl_format gl
    WHERE (gl.chart_group_id=request->chart_section_list[secindex].chart_group_list[grpindex].
    chart_group_id)
    DETAIL
     IF ((((request->chart_section_list[secindex].chart_group_list[grpindex].gl_info.rslt_seq != gl
     .result_seq_flag)) OR ((request->chart_section_list[secindex].chart_group_list[grpindex].gl_info
     .group_style != gl.group_style))) )
      update_labtext_flag = 1
     ENDIF
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_GL_FORMAT","CHECKLABTEXTSECTION",1,1)
   IF (update_labtext_flag=1)
    CALL update_gl(secindex,grpindex)
   ENDIF
 END ;Subroutine
 SUBROUTINE (add_allergy_format(sindex=i4(val),gindex=i4(val)) =null)
   CALL log_message("In add_allergy_format()",log_level_debug)
   INSERT  FROM chart_allergy_format alg
    SET alg.chart_group_id = request->chart_section_list[sindex].chart_group_list[gindex].
     chart_group_id, alg.substance_lbl = request->chart_section_list[sindex].chart_group_list[gindex]
     .allergy_info.substance_lbl, alg.category_lbl = request->chart_section_list[sindex].
     chart_group_list[gindex].allergy_info.category_lbl,
     alg.updt_dt_lbl = request->chart_section_list[sindex].chart_group_list[gindex].allergy_info.
     updt_dt_lbl, alg.severity_lbl = request->chart_section_list[sindex].chart_group_list[gindex].
     allergy_info.severity_lbl, alg.reaction_stat_lbl = request->chart_section_list[sindex].
     chart_group_list[gindex].allergy_info.reaction_stat_lbl,
     alg.reaction_lbl = request->chart_section_list[sindex].chart_group_list[gindex].allergy_info.
     reaction_lbl, alg.updt_by_lbl = request->chart_section_list[sindex].chart_group_list[gindex].
     allergy_info.updt_by_lbl, alg.source_lbl = request->chart_section_list[sindex].chart_group_list[
     gindex].allergy_info.source_lbl,
     alg.onset_dt_lbl = request->chart_section_list[sindex].chart_group_list[gindex].allergy_info.
     onset_dt_lbl, alg.type_lbl = request->chart_section_list[sindex].chart_group_list[gindex].
     allergy_info.type_lbl, alg.cancel_lbl = request->chart_section_list[sindex].chart_group_list[
     gindex].allergy_info.cancel_lbl,
     alg.comment_lbl = request->chart_section_list[sindex].chart_group_list[gindex].allergy_info.
     comment_lbl, alg.severity_odr = request->chart_section_list[sindex].chart_group_list[gindex].
     allergy_info.severity_odr, alg.reaction_stat_odr = request->chart_section_list[sindex].
     chart_group_list[gindex].allergy_info.reaction_stat_odr,
     alg.reaction_odr = request->chart_section_list[sindex].chart_group_list[gindex].allergy_info.
     reaction_odr, alg.source_odr = request->chart_section_list[sindex].chart_group_list[gindex].
     allergy_info.source_odr, alg.onset_dt_odr = request->chart_section_list[sindex].
     chart_group_list[gindex].allergy_info.onset_dt_odr,
     alg.type_odr = request->chart_section_list[sindex].chart_group_list[gindex].allergy_info.
     type_odr, alg.cancel_odr = request->chart_section_list[sindex].chart_group_list[gindex].
     allergy_info.cancel_odr, alg.category_odr = request->chart_section_list[sindex].
     chart_group_list[gindex].allergy_info.category_odr,
     alg.result_sequence_ind = request->chart_section_list[sindex].chart_group_list[gindex].
     allergy_info.result_sequence_ind, alg.active_ind = 1, alg.active_status_cd = reqdata->
     active_status_cd,
     alg.active_status_dt_tm = cnvtdatetime(sysdate), alg.active_status_prsnl_id = reqinfo->updt_id,
     alg.updt_cnt = 0,
     alg.updt_dt_tm = cnvtdatetime(curdate,curtime), alg.updt_id = reqinfo->updt_id, alg.updt_applctx
      = reqinfo->updt_applctx,
     alg.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   CALL error_and_zero_check(curqual,"CHART_ALLERGY_FORMAT","ADD_ALLERGY_FORMAT",1,1)
 END ;Subroutine
 SUBROUTINE (update_allergy(secindex=i4(val),grpindex=i4(val)) =null)
   CALL log_message("In update_allergy()",log_level_debug)
   UPDATE  FROM chart_allergy_format alg
    SET alg.substance_lbl = request->chart_section_list[secindex].chart_group_list[grpindex].
     allergy_info.substance_lbl, alg.category_lbl = request->chart_section_list[secindex].
     chart_group_list[grpindex].allergy_info.category_lbl, alg.updt_dt_lbl = request->
     chart_section_list[secindex].chart_group_list[grpindex].allergy_info.updt_dt_lbl,
     alg.severity_lbl = request->chart_section_list[secindex].chart_group_list[grpindex].allergy_info
     .severity_lbl, alg.reaction_stat_lbl = request->chart_section_list[secindex].chart_group_list[
     grpindex].allergy_info.reaction_stat_lbl, alg.reaction_lbl = request->chart_section_list[
     secindex].chart_group_list[grpindex].allergy_info.reaction_lbl,
     alg.updt_by_lbl = request->chart_section_list[secindex].chart_group_list[grpindex].allergy_info.
     updt_by_lbl, alg.source_lbl = request->chart_section_list[secindex].chart_group_list[grpindex].
     allergy_info.source_lbl, alg.onset_dt_lbl = request->chart_section_list[secindex].
     chart_group_list[grpindex].allergy_info.onset_dt_lbl,
     alg.type_lbl = request->chart_section_list[secindex].chart_group_list[grpindex].allergy_info.
     type_lbl, alg.cancel_lbl = request->chart_section_list[secindex].chart_group_list[grpindex].
     allergy_info.cancel_lbl, alg.comment_lbl = request->chart_section_list[secindex].
     chart_group_list[grpindex].allergy_info.comment_lbl,
     alg.severity_odr = request->chart_section_list[secindex].chart_group_list[grpindex].allergy_info
     .severity_odr, alg.reaction_stat_odr = request->chart_section_list[secindex].chart_group_list[
     grpindex].allergy_info.reaction_stat_odr, alg.reaction_odr = request->chart_section_list[
     secindex].chart_group_list[grpindex].allergy_info.reaction_odr,
     alg.source_odr = request->chart_section_list[secindex].chart_group_list[grpindex].allergy_info.
     source_odr, alg.onset_dt_odr = request->chart_section_list[secindex].chart_group_list[grpindex].
     allergy_info.onset_dt_odr, alg.type_odr = request->chart_section_list[secindex].
     chart_group_list[grpindex].allergy_info.type_odr,
     alg.cancel_odr = request->chart_section_list[secindex].chart_group_list[grpindex].allergy_info.
     cancel_odr, alg.category_odr = request->chart_section_list[secindex].chart_group_list[grpindex].
     allergy_info.category_odr, alg.result_sequence_ind = request->chart_section_list[secindex].
     chart_group_list[grpindex].allergy_info.result_sequence_ind,
     alg.active_ind = 1, alg.active_status_cd = reqdata->active_status_cd, alg.updt_cnt = (alg
     .updt_cnt+ 1),
     alg.updt_dt_tm = cnvtdatetime(curdate,curtime), alg.updt_id = reqinfo->updt_id, alg.updt_applctx
      = reqinfo->updt_applctx,
     alg.updt_task = reqinfo->updt_task
    WHERE (alg.chart_group_id=request->chart_section_list[secindex].chart_group_list[grpindex].
    chart_group_id)
    WITH nocounter
   ;end update
   CALL error_and_zero_check(curqual,"CHART_ALLERGY_FORMAT","UPDATE_ALLERGY",1,1)
 END ;Subroutine
 SUBROUTINE (checkallergysection(secindex=i4(val),grpindex=i4(val)) =null)
   CALL log_message("In CheckAllergySection()",log_level_debug)
   DECLARE update_allergy_flag = i2 WITH noconstant(0), protect
   SELECT INTO "nl:"
    FROM chart_allergy_format alg
    WHERE (alg.chart_group_id=request->chart_section_list[secindex].chart_group_list[grpindex].
    chart_group_id)
    DETAIL
     IF ((((request->chart_section_list[secindex].chart_group_list[grpindex].allergy_info.
     substance_lbl != alg.substance_lbl)) OR ((((request->chart_section_list[secindex].
     chart_group_list[grpindex].allergy_info.category_lbl != alg.category_lbl)) OR ((((request->
     chart_section_list[secindex].chart_group_list[grpindex].allergy_info.updt_dt_lbl != alg
     .updt_dt_lbl)) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].
     allergy_info.severity_lbl != alg.severity_lbl)) OR ((((request->chart_section_list[secindex].
     chart_group_list[grpindex].allergy_info.reaction_stat_lbl != alg.reaction_stat_lbl)) OR ((((
     request->chart_section_list[secindex].chart_group_list[grpindex].allergy_info.reaction_lbl !=
     alg.reaction_lbl)) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].
     allergy_info.updt_by_lbl != alg.updt_by_lbl)) OR ((((request->chart_section_list[secindex].
     chart_group_list[grpindex].allergy_info.source_lbl != alg.source_lbl)) OR ((((request->
     chart_section_list[secindex].chart_group_list[grpindex].allergy_info.onset_dt_lbl != alg
     .onset_dt_lbl)) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].
     allergy_info.type_lbl != alg.type_lbl)) OR ((((request->chart_section_list[secindex].
     chart_group_list[grpindex].allergy_info.cancel_lbl != alg.cancel_lbl)) OR ((((request->
     chart_section_list[secindex].chart_group_list[grpindex].allergy_info.comment_lbl != alg
     .comment_lbl)) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].
     allergy_info.severity_odr != alg.severity_odr)) OR ((((request->chart_section_list[secindex].
     chart_group_list[grpindex].allergy_info.reaction_stat_odr != alg.reaction_stat_odr)) OR ((((
     request->chart_section_list[secindex].chart_group_list[grpindex].allergy_info.reaction_odr !=
     alg.reaction_odr)) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].
     allergy_info.source_odr != alg.source_odr)) OR ((((request->chart_section_list[secindex].
     chart_group_list[grpindex].allergy_info.onset_dt_odr != alg.onset_dt_odr)) OR ((((request->
     chart_section_list[secindex].chart_group_list[grpindex].allergy_info.type_odr != alg.type_odr))
      OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].allergy_info.cancel_odr
      != alg.cancel_odr)) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].
     allergy_info.category_odr != alg.category_odr)) OR ((request->chart_section_list[secindex].
     chart_group_list[grpindex].allergy_info.result_sequence_ind != alg.result_sequence_ind))) )) ))
     )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )
      update_allergy_flag = 1
     ENDIF
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_ALLERGY_FORMAT","CHECKALLERGYSECTION",1,1)
   IF (update_allergy_flag=1)
    CALL update_allergy(secindex,grpindex)
   ENDIF
 END ;Subroutine
 SUBROUTINE (add_prob_format(sindex=i4(val),gindex=i4(val)) =null)
   CALL log_message("In add_prob_format()",log_level_debug)
   INSERT  FROM chart_problem_format prob
    SET prob.chart_group_id = request->chart_section_list[sindex].chart_group_list[gindex].
     chart_group_id, prob.prob_name_lbl = request->chart_section_list[sindex].chart_group_list[gindex
     ].prob_info.prob_name_lbl, prob.date_recorded_lbl = request->chart_section_list[sindex].
     chart_group_list[gindex].prob_info.date_rec_lbl,
     prob.code_lbl = request->chart_section_list[sindex].chart_group_list[gindex].prob_info.code_lbl,
     prob.con_stat_lbl = request->chart_section_list[sindex].chart_group_list[gindex].prob_info.
     con_stat_lbl, prob.life_stat_lbl = request->chart_section_list[sindex].chart_group_list[gindex].
     prob_info.life_stat_lbl,
     prob.course_lbl = request->chart_section_list[sindex].chart_group_list[gindex].prob_info.
     course_lbl, prob.perst_lbl = request->chart_section_list[sindex].chart_group_list[gindex].
     prob_info.perst_lbl, prob.prog_lbl = request->chart_section_list[sindex].chart_group_list[gindex
     ].prob_info.prog_lbl,
     prob.onset_lbl = request->chart_section_list[sindex].chart_group_list[gindex].prob_info.
     onset_lbl, prob.prov_lbl = request->chart_section_list[sindex].chart_group_list[gindex].
     prob_info.prov_lbl, prob.date_est_lbl = request->chart_section_list[sindex].chart_group_list[
     gindex].prob_info.date_est_lbl,
     prob.cancel_lbl = request->chart_section_list[sindex].chart_group_list[gindex].prob_info.
     cancel_lbl, prob.comment_lbl = request->chart_section_list[sindex].chart_group_list[gindex].
     prob_info.comment_lbl, prob.code_ord = request->chart_section_list[sindex].chart_group_list[
     gindex].prob_info.code_ord,
     prob.con_stat_ord = request->chart_section_list[sindex].chart_group_list[gindex].prob_info.
     con_stat_ord, prob.life_stat_ord = request->chart_section_list[sindex].chart_group_list[gindex].
     prob_info.life_stat_ord, prob.course_ord = request->chart_section_list[sindex].chart_group_list[
     gindex].prob_info.course_ord,
     prob.perst_ord = request->chart_section_list[sindex].chart_group_list[gindex].prob_info.
     perst_ord, prob.prog_ord = request->chart_section_list[sindex].chart_group_list[gindex].
     prob_info.prog_ord, prob.onset_ord = request->chart_section_list[sindex].chart_group_list[gindex
     ].prob_info.onset_ord,
     prob.cancel_ord = request->chart_section_list[sindex].chart_group_list[gindex].prob_info.
     cancel_ord, prob.result_sequence_ind = request->chart_section_list[sindex].chart_group_list[
     gindex].prob_info.result_sequence_ind, prob.date_recorded_sequence_ind = request->
     chart_section_list[sindex].chart_group_list[gindex].prob_info.date_rec_result_sequence_ind,
     prob.active_ind = 1, prob.active_status_cd = reqdata->active_status_cd, prob.active_status_dt_tm
      = cnvtdatetime(sysdate),
     prob.active_status_prsnl_id = reqinfo->updt_id, prob.updt_cnt = 0, prob.updt_dt_tm =
     cnvtdatetime(curdate,curtime),
     prob.updt_id = reqinfo->updt_id, prob.updt_applctx = reqinfo->updt_applctx, prob.updt_task =
     reqinfo->updt_task
    WITH nocounter
   ;end insert
   CALL error_and_zero_check(curqual,"CHART_PROBLEM_FORMAT","ADD_PROB_FORMAT",1,1)
 END ;Subroutine
 SUBROUTINE (update_problem(secindex=i4(val),grpindex=i4(val)) =null)
   CALL log_message("In update_problem()",log_level_debug)
   UPDATE  FROM chart_problem_format prob
    SET prob.prob_name_lbl = request->chart_section_list[secindex].chart_group_list[grpindex].
     prob_info.prob_name_lbl, prob.date_recorded_lbl = request->chart_section_list[secindex].
     chart_group_list[grpindex].prob_info.date_rec_lbl, prob.code_lbl = request->chart_section_list[
     secindex].chart_group_list[grpindex].prob_info.code_lbl,
     prob.con_stat_lbl = request->chart_section_list[secindex].chart_group_list[grpindex].prob_info.
     con_stat_lbl, prob.life_stat_lbl = request->chart_section_list[secindex].chart_group_list[
     grpindex].prob_info.life_stat_lbl, prob.course_lbl = request->chart_section_list[secindex].
     chart_group_list[grpindex].prob_info.course_lbl,
     prob.perst_lbl = request->chart_section_list[secindex].chart_group_list[grpindex].prob_info.
     perst_lbl, prob.prog_lbl = request->chart_section_list[secindex].chart_group_list[grpindex].
     prob_info.prog_lbl, prob.onset_lbl = request->chart_section_list[secindex].chart_group_list[
     grpindex].prob_info.onset_lbl,
     prob.prov_lbl = request->chart_section_list[secindex].chart_group_list[grpindex].prob_info.
     prov_lbl, prob.date_est_lbl = request->chart_section_list[secindex].chart_group_list[grpindex].
     prob_info.date_est_lbl, prob.cancel_lbl = request->chart_section_list[secindex].
     chart_group_list[grpindex].prob_info.cancel_lbl,
     prob.comment_lbl = request->chart_section_list[secindex].chart_group_list[grpindex].prob_info.
     comment_lbl, prob.code_ord = request->chart_section_list[secindex].chart_group_list[grpindex].
     prob_info.code_ord, prob.con_stat_ord = request->chart_section_list[secindex].chart_group_list[
     grpindex].prob_info.con_stat_ord,
     prob.life_stat_ord = request->chart_section_list[secindex].chart_group_list[grpindex].prob_info.
     life_stat_ord, prob.course_ord = request->chart_section_list[secindex].chart_group_list[grpindex
     ].prob_info.course_ord, prob.perst_ord = request->chart_section_list[secindex].chart_group_list[
     grpindex].prob_info.perst_ord,
     prob.prog_ord = request->chart_section_list[secindex].chart_group_list[grpindex].prob_info.
     prog_ord, prob.onset_ord = request->chart_section_list[secindex].chart_group_list[grpindex].
     prob_info.onset_ord, prob.cancel_ord = request->chart_section_list[secindex].chart_group_list[
     grpindex].prob_info.cancel_ord,
     prob.result_sequence_ind = request->chart_section_list[secindex].chart_group_list[grpindex].
     prob_info.result_sequence_ind, prob.date_recorded_sequence_ind = request->chart_section_list[
     secindex].chart_group_list[grpindex].prob_info.date_rec_result_sequence_ind, prob.active_ind = 1,
     prob.active_status_cd = reqdata->active_status_cd, prob.updt_cnt = (prob.updt_cnt+ 1), prob
     .updt_dt_tm = cnvtdatetime(curdate,curtime),
     prob.updt_id = reqinfo->updt_id, prob.updt_applctx = reqinfo->updt_applctx, prob.updt_task =
     reqinfo->updt_task
    WHERE (prob.chart_group_id=request->chart_section_list[secindex].chart_group_list[grpindex].
    chart_group_id)
    WITH nocounter
   ;end update
   CALL error_and_zero_check(curqual,"CHART_PROBLEM_FORMAT","UPDATE_PROBLEM",1,1)
 END ;Subroutine
 SUBROUTINE (checkproblemlistsection(secindex=i4(val),grpindex=i4(val)) =null)
   CALL log_message("In CheckProblemListSection()",log_level_debug)
   DECLARE update_problemlist_flag = i2 WITH noconstant(0), protect
   SELECT INTO "nl:"
    FROM chart_problem_format prob
    WHERE (prob.chart_group_id=request->chart_section_list[secindex].chart_group_list[grpindex].
    chart_group_id)
    DETAIL
     IF ((((request->chart_section_list[secindex].chart_group_list[grpindex].prob_info.prob_name_lbl
      != prob.prob_name_lbl)) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex]
     .prob_info.date_rec_lbl != prob.date_recorded_lbl)) OR ((((request->chart_section_list[secindex]
     .chart_group_list[grpindex].prob_info.code_lbl != prob.code_lbl)) OR ((((request->
     chart_section_list[secindex].chart_group_list[grpindex].prob_info.con_stat_lbl != prob
     .con_stat_lbl)) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].
     prob_info.life_stat_lbl != prob.life_stat_lbl)) OR ((((request->chart_section_list[secindex].
     chart_group_list[grpindex].prob_info.course_lbl != prob.course_lbl)) OR ((((request->
     chart_section_list[secindex].chart_group_list[grpindex].prob_info.perst_lbl != prob.perst_lbl))
      OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].prob_info.prog_lbl !=
     prob.prog_lbl)) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].
     prob_info.onset_lbl != prob.onset_lbl)) OR ((((request->chart_section_list[secindex].
     chart_group_list[grpindex].prob_info.prov_lbl != prob.prov_lbl)) OR ((((request->
     chart_section_list[secindex].chart_group_list[grpindex].prob_info.date_est_lbl != prob
     .date_est_lbl)) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].
     prob_info.cancel_lbl != prob.cancel_lbl)) OR ((((request->chart_section_list[secindex].
     chart_group_list[grpindex].prob_info.comment_lbl != prob.comment_lbl)) OR ((((request->
     chart_section_list[secindex].chart_group_list[grpindex].prob_info.code_ord != prob.code_ord))
      OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].prob_info.con_stat_ord
      != prob.con_stat_ord)) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].
     prob_info.life_stat_ord != prob.life_stat_ord)) OR ((((request->chart_section_list[secindex].
     chart_group_list[grpindex].prob_info.course_ord != prob.course_ord)) OR ((((request->
     chart_section_list[secindex].chart_group_list[grpindex].prob_info.perst_ord != prob.perst_ord))
      OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].prob_info.prog_ord !=
     prob.prog_ord)) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].
     prob_info.onset_ord != prob.onset_ord)) OR ((((request->chart_section_list[secindex].
     chart_group_list[grpindex].prob_info.cancel_ord != prob.cancel_ord)) OR ((((request->
     chart_section_list[secindex].chart_group_list[grpindex].prob_info.result_sequence_ind != prob
     .result_sequence_ind)) OR ((request->chart_section_list[secindex].chart_group_list[grpindex].
     prob_info.date_rec_result_sequence_ind != prob.date_recorded_sequence_ind))) )) )) )) )) )) ))
     )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )
      update_problemlist_flag = 1
     ENDIF
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_PROBLEM_FORMAT","CHECKPROBLEMLISTSECTION",1,1)
   IF (update_problemlist_flag=1)
    CALL update_problem(secindex,grpindex)
   ENDIF
 END ;Subroutine
 SUBROUTINE (add_micro_format(sindex=i4(val),gindex=i4(val)) =null)
   CALL log_message("In add_micro_format()",log_level_debug)
   DECLARE micro_legend_id = f8 WITH noconstant(0.0), protect
   DECLARE opt_nbr = i4 WITH noconstant(0), protect
   SET opt_nbr = size(request->chart_section_list[sindex].chart_group_list[gindex].micro_info.
    option_list,5)
   SELECT INTO "nl:"
    lt.long_text_id
    FROM long_text lt
    WHERE (lt.parent_entity_id=request->chart_section_list[sindex].chart_group_list[gindex].
    chart_group_id)
     AND lt.parent_entity_name="CHART MICRO LEGEND"
    DETAIL
     micro_legend_id = lt.long_text_id
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"GET_LONG_TEXT","ADD_MICRO_FORMAT",1,0)
   IF (micro_legend_id > 0)
    UPDATE  FROM long_text lt,
      (dummyt d  WITH seq = value(opt_nbr))
     SET lt.long_text = request->chart_section_list[sindex].chart_group_list[gindex].micro_info.
      option_list[d.seq].option_value, lt.updt_cnt = (lt.updt_cnt+ 1), lt.updt_dt_tm = cnvtdatetime(
       sysdate),
      lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->
      updt_applctx
     PLAN (d
      WHERE (request->chart_section_list[sindex].chart_group_list[gindex].micro_info.option_list[d
      .seq].option_flag=57))
      JOIN (lt
      WHERE lt.long_text_id=micro_legend_id)
    ;end update
    CALL error_and_zero_check(curqual,"UPDATE_LONG_TEXT","ADD_MICRO_FORMAT",1,0)
    IF (curqual=0)
     DELETE  FROM long_text lt
      WHERE lt.long_text_id=micro_legend_id
      WITH nocounter
     ;end delete
    ENDIF
   ELSE
    INSERT  FROM long_text lt,
      (dummyt d  WITH seq = value(opt_nbr))
     SET lt.long_text_id = seq(long_data_seq,nextval), lt.parent_entity_id = request->
      chart_section_list[sindex].chart_group_list[gindex].chart_group_id, lt.parent_entity_name =
      "CHART MICRO LEGEND",
      lt.long_text = request->chart_section_list[sindex].chart_group_list[gindex].micro_info.
      option_list[d.seq].option_value, lt.active_ind = 1, lt.active_status_cd = reqdata->
      active_status_cd,
      lt.active_status_dt_tm = cnvtdatetime(sysdate), lt.active_status_prsnl_id = reqinfo->updt_id,
      lt.updt_cnt = 0,
      lt.updt_dt_tm = cnvtdatetime(sysdate), lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->
      updt_task,
      lt.updt_applctx = reqinfo->updt_applctx
     PLAN (d
      WHERE (request->chart_section_list[sindex].chart_group_list[gindex].micro_info.option_list[d
      .seq].option_flag=57))
      JOIN (lt)
     WITH nocounter
    ;end insert
    SELECT INTO "nl:"
     lt.long_text_id
     FROM long_text lt
     WHERE (lt.parent_entity_id=request->chart_section_list[sindex].chart_group_list[gindex].
     chart_group_id)
      AND lt.parent_entity_name="CHART MICRO LEGEND"
     DETAIL
      micro_legend_id = lt.long_text_id
     WITH nocounter
    ;end select
    CALL error_and_zero_check(curqual,"INSERT_LONG_TEXT","ADD_MICRO_FORMAT",1,0)
   ENDIF
   INSERT  FROM chart_micro_format cmf,
     (dummyt d  WITH seq = value(opt_nbr))
    SET cmf.chart_group_id = request->chart_section_list[sindex].chart_group_list[gindex].
     chart_group_id, cmf.option_flag = request->chart_section_list[sindex].chart_group_list[gindex].
     micro_info.option_list[d.seq].option_flag, cmf.option_value =
     IF ((request->chart_section_list[sindex].chart_group_list[gindex].micro_info.option_list[d.seq].
     option_flag=57)) cnvtstring(micro_legend_id)
     ELSE request->chart_section_list[sindex].chart_group_list[gindex].micro_info.option_list[d.seq].
      option_value
     ENDIF
     ,
     cmf.active_ind = 1, cmf.active_status_cd = reqdata->active_status_cd, cmf.active_status_dt_tm =
     cnvtdatetime(sysdate),
     cmf.active_status_prsnl_id = reqinfo->updt_id, cmf.updt_cnt = 0, cmf.updt_dt_tm = cnvtdatetime(
      sysdate),
     cmf.updt_id = reqinfo->updt_id, cmf.updt_task = reqinfo->updt_task, cmf.updt_applctx = reqinfo->
     updt_applctx
    PLAN (d)
     JOIN (cmf)
    WITH nocounter
   ;end insert
   CALL error_and_zero_check(curqual,"CHART_MICRO_FORMAT","ADD_MICRO_FORMAT",1,1)
 END ;Subroutine
 SUBROUTINE (update_micro(secindex=i4(val),grpindex=i4(val)) =null)
   CALL log_message("In update_micro()",log_level_debug)
   UPDATE  FROM chart_micro_format cmf
    SET cmf.active_ind = 1, cmf.updt_cnt = (cmf.updt_cnt+ 1), cmf.updt_dt_tm = cnvtdatetime(curdate,
      curtime),
     cmf.updt_id = reqinfo->updt_id, cmf.updt_applctx = reqinfo->updt_applctx, cmf.updt_task =
     reqinfo->updt_task
    WHERE (cmf.chart_group_id=request->chart_section_list[secindex].chart_group_list[grpindex].
    chart_group_id)
    WITH nocounter
   ;end update
   CALL error_and_zero_check(curqual,"CHART_MICRO_FORMAT","UPDATE_MICRO",1,1)
 END ;Subroutine
 SUBROUTINE (checkmicrosection(secindex=i4(val),grpindex=i4(val)) =null)
   CALL log_message("In CheckMicroSection()",log_level_debug)
   SELECT INTO "nl:"
    cmf.option_value
    FROM chart_micro_format cmf
    WHERE (cmf.chart_group_id=request->chart_section_list[secindex].chart_group_list[grpindex].
    chart_group_id)
     AND cmf.option_flag=57
    DETAIL
     micro_legend_id = cnvtreal(cmf.option_value)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"SEL_CHART_MICRO_FORMAT","CHECKMICROSECTION",1,0)
   DELETE  FROM chart_micro_format cmf
    WHERE (cmf.chart_group_id=request->chart_section_list[secindex].chart_group_list[grpindex].
    chart_group_id)
    WITH nocounter
   ;end delete
   CALL error_and_zero_check(curqual,"CHART_MICRO_FORMAT","CHECKMICROSECTION",1,0)
   CALL add_micro_format(secindex,grpindex)
 END ;Subroutine
 SUBROUTINE (add_orders_format(sindex=i4(val),gindex=i4(val)) =null)
   CALL log_message("In add_orders_format()",log_level_debug)
   INSERT  FROM chart_orders_format cof
    SET cof.chart_group_id = request->chart_section_list[sindex].chart_group_list[gindex].
     chart_group_id, cof.order_seq_flag = request->chart_section_list[sindex].chart_group_list[gindex
     ].orders_info.order_seq_flag, cof.date_time_ind = request->chart_section_list[sindex].
     chart_group_list[gindex].orders_info.date_time_chk,
     cof.date_time_lbl = request->chart_section_list[sindex].chart_group_list[gindex].orders_info.
     date_time_lbl, cof.action_ind = request->chart_section_list[sindex].chart_group_list[gindex].
     orders_info.action_chk, cof.action_lbl = request->chart_section_list[sindex].chart_group_list[
     gindex].orders_info.action_lbl,
     cof.order_status_ind = request->chart_section_list[sindex].chart_group_list[gindex].orders_info.
     order_status_chk, cof.order_status_lbl = request->chart_section_list[sindex].chart_group_list[
     gindex].orders_info.order_status_lbl, cof.mnemonic_ind = request->chart_section_list[sindex].
     chart_group_list[gindex].orders_info.mnemonic_chk,
     cof.mnemonic_lbl = request->chart_section_list[sindex].chart_group_list[gindex].orders_info.
     mnemonic_lbl, cof.order_phys_ind = request->chart_section_list[sindex].chart_group_list[gindex].
     orders_info.order_phys_chk, cof.order_phys_lbl = request->chart_section_list[sindex].
     chart_group_list[gindex].orders_info.order_phys_lbl,
     cof.order_placer_ind = request->chart_section_list[sindex].chart_group_list[gindex].orders_info.
     order_placer_chk, cof.order_placer_lbl = request->chart_section_list[sindex].chart_group_list[
     gindex].orders_info.order_placer_lbl, cof.order_type_ind = request->chart_section_list[sindex].
     chart_group_list[gindex].orders_info.order_type_chk,
     cof.order_type_lbl = request->chart_section_list[sindex].chart_group_list[gindex].orders_info.
     order_type_lbl, cof.details_ind = request->chart_section_list[sindex].chart_group_list[gindex].
     orders_info.details_chk, cof.details_lbl = request->chart_section_list[sindex].chart_group_list[
     gindex].orders_info.details_lbl,
     cof.review_ind = request->chart_section_list[sindex].chart_group_list[gindex].orders_info.
     review_chk, cof.review_lbl = request->chart_section_list[sindex].chart_group_list[gindex].
     orders_info.review_lbl, cof.detail_order = request->chart_section_list[sindex].chart_group_list[
     gindex].orders_info.detail_order,
     cof.review_order = request->chart_section_list[sindex].chart_group_list[gindex].orders_info.
     review_order, cof.date_mask = request->chart_section_list[sindex].chart_group_list[gindex].
     orders_info.date_mask, cof.time_mask = request->chart_section_list[sindex].chart_group_list[
     gindex].orders_info.time_mask,
     cof.exclude_osname_ind = request->chart_section_list[sindex].chart_group_list[gindex].
     orders_info.orderset_exclude_ind, cof.label_bit_map = request->chart_section_list[sindex].
     chart_group_list[gindex].orders_info.label_bit_map, cof.cancel_reason_lbl = request->
     chart_section_list[sindex].chart_group_list[gindex].orders_info.cancel_reason_lbl,
     cof.canceled_dttm_lbl = request->chart_section_list[sindex].chart_group_list[gindex].orders_info
     .canceled_dttm_lbl, cof.comm_type_lbl = request->chart_section_list[sindex].chart_group_list[
     gindex].orders_info.comm_type_lbl, cof.dept_status_lbl = request->chart_section_list[sindex].
     chart_group_list[gindex].orders_info.dept_status_lbl,
     cof.discontinued_dttm_lbl = request->chart_section_list[sindex].chart_group_list[gindex].
     orders_info.discontinued_dttm_lbl, cof.future_disc_dttm_lbl = request->chart_section_list[sindex
     ].chart_group_list[gindex].orders_info.future_disc_dttm_lbl, cof.orig_order_dttm_lbl = request->
     chart_section_list[sindex].chart_group_list[gindex].orders_info.orig_order_dttm_lbl,
     cof.suppress_meds_bit_map = request->chart_section_list[sindex].chart_group_list[gindex].
     orders_info.suppress_meds_bit_map, cof.action_seq_flag = request->chart_section_list[sindex].
     chart_group_list[gindex].orders_info.action_seq_flag, cof.detailed_layout_ind = request->
     chart_section_list[secindex].chart_group_list[grpindex].orders_info.detailed_layout_ind,
     cof.active_ind = 1, cof.active_status_cd = reqdata->active_status_cd, cof.updt_cnt = 0,
     cof.updt_dt_tm = cnvtdatetime(curdate,curtime), cof.updt_id = reqinfo->updt_id, cof.updt_applctx
      = reqinfo->updt_applctx,
     cof.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   CALL error_and_zero_check(curqual,"CHART_ORDERS_FORMAT","ADD_ORDERS_FORMAT",1,1)
 END ;Subroutine
 SUBROUTINE (update_orders(secindex=i4(val),grpindex=i4(val)) =null)
   CALL log_message("In update_orders()",log_level_debug)
   UPDATE  FROM chart_orders_format cof
    SET cof.order_seq_flag = request->chart_section_list[secindex].chart_group_list[grpindex].
     orders_info.order_seq_flag, cof.date_time_ind = request->chart_section_list[secindex].
     chart_group_list[grpindex].orders_info.date_time_chk, cof.date_time_lbl = request->
     chart_section_list[secindex].chart_group_list[grpindex].orders_info.date_time_lbl,
     cof.action_ind = request->chart_section_list[secindex].chart_group_list[grpindex].orders_info.
     action_chk, cof.action_lbl = request->chart_section_list[secindex].chart_group_list[grpindex].
     orders_info.action_lbl, cof.order_status_ind = request->chart_section_list[secindex].
     chart_group_list[grpindex].orders_info.order_status_chk,
     cof.order_status_lbl = request->chart_section_list[secindex].chart_group_list[grpindex].
     orders_info.order_status_lbl, cof.mnemonic_ind = request->chart_section_list[secindex].
     chart_group_list[grpindex].orders_info.mnemonic_chk, cof.mnemonic_lbl = request->
     chart_section_list[secindex].chart_group_list[grpindex].orders_info.mnemonic_lbl,
     cof.order_phys_ind = request->chart_section_list[secindex].chart_group_list[grpindex].
     orders_info.order_phys_chk, cof.order_phys_lbl = request->chart_section_list[secindex].
     chart_group_list[grpindex].orders_info.order_phys_lbl, cof.order_placer_ind = request->
     chart_section_list[secindex].chart_group_list[grpindex].orders_info.order_placer_chk,
     cof.order_placer_lbl = request->chart_section_list[secindex].chart_group_list[grpindex].
     orders_info.order_placer_lbl, cof.order_type_ind = request->chart_section_list[secindex].
     chart_group_list[grpindex].orders_info.order_type_chk, cof.order_type_lbl = request->
     chart_section_list[secindex].chart_group_list[grpindex].orders_info.order_type_lbl,
     cof.details_ind = request->chart_section_list[secindex].chart_group_list[grpindex].orders_info.
     details_chk, cof.details_lbl = request->chart_section_list[secindex].chart_group_list[grpindex].
     orders_info.details_lbl, cof.review_ind = request->chart_section_list[secindex].
     chart_group_list[grpindex].orders_info.review_chk,
     cof.review_lbl = request->chart_section_list[secindex].chart_group_list[grpindex].orders_info.
     review_lbl, cof.detail_order = request->chart_section_list[secindex].chart_group_list[grpindex].
     orders_info.detail_order, cof.review_order = request->chart_section_list[secindex].
     chart_group_list[grpindex].orders_info.review_order,
     cof.date_mask = request->chart_section_list[secindex].chart_group_list[grpindex].orders_info.
     date_mask, cof.time_mask = request->chart_section_list[secindex].chart_group_list[grpindex].
     orders_info.time_mask, cof.exclude_osname_ind = request->chart_section_list[secindex].
     chart_group_list[grpindex].orders_info.orderset_exclude_ind,
     cof.label_bit_map = request->chart_section_list[secindex].chart_group_list[grpindex].orders_info
     .label_bit_map, cof.cancel_reason_lbl = request->chart_section_list[secindex].chart_group_list[
     grpindex].orders_info.cancel_reason_lbl, cof.canceled_dttm_lbl = request->chart_section_list[
     secindex].chart_group_list[grpindex].orders_info.canceled_dttm_lbl,
     cof.comm_type_lbl = request->chart_section_list[secindex].chart_group_list[grpindex].orders_info
     .comm_type_lbl, cof.dept_status_lbl = request->chart_section_list[secindex].chart_group_list[
     grpindex].orders_info.dept_status_lbl, cof.discontinued_dttm_lbl = request->chart_section_list[
     secindex].chart_group_list[grpindex].orders_info.discontinued_dttm_lbl,
     cof.future_disc_dttm_lbl = request->chart_section_list[secindex].chart_group_list[grpindex].
     orders_info.future_disc_dttm_lbl, cof.orig_order_dttm_lbl = request->chart_section_list[secindex
     ].chart_group_list[grpindex].orders_info.orig_order_dttm_lbl, cof.suppress_meds_bit_map =
     request->chart_section_list[secindex].chart_group_list[grpindex].orders_info.
     suppress_meds_bit_map,
     cof.action_seq_flag = request->chart_section_list[secindex].chart_group_list[grpindex].
     orders_info.action_seq_flag, cof.detailed_layout_ind = request->chart_section_list[secindex].
     chart_group_list[grpindex].orders_info.detailed_layout_ind, cof.active_ind = 1,
     cof.active_status_cd = reqdata->active_status_cd, cof.updt_cnt = (cof.updt_cnt+ 1), cof
     .updt_dt_tm = cnvtdatetime(curdate,curtime),
     cof.updt_id = reqinfo->updt_id, cof.updt_applctx = reqinfo->updt_applctx, cof.updt_task =
     reqinfo->updt_task
    WHERE (cof.chart_group_id=request->chart_section_list[secindex].chart_group_list[grpindex].
    chart_group_id)
    WITH nocounter
   ;end update
   CALL error_and_zero_check(curqual,"CHART_ORDERS_FORMAT","UPDATE_ORDERS",1,1)
 END ;Subroutine
 SUBROUTINE (checkorderssection(secindex=i4(val),grpindex=i4(val)) =null)
   CALL log_message("In CheckOrdersSection()",log_level_debug)
   DECLARE update_orders_flag = i2 WITH noconstant(0), protect
   SELECT INTO "nl:"
    FROM chart_orders_format cof
    WHERE (cof.chart_group_id=request->chart_section_list[secindex].chart_group_list[grpindex].
    chart_group_id)
    DETAIL
     IF ((((request->chart_section_list[secindex].chart_group_list[grpindex].orders_info.
     order_seq_flag != cof.order_seq_flag)) OR ((((request->chart_section_list[secindex].
     chart_group_list[grpindex].orders_info.date_time_chk != cof.date_time_ind)) OR ((((request->
     chart_section_list[secindex].chart_group_list[grpindex].orders_info.date_time_lbl != cof
     .date_time_lbl)) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].
     orders_info.action_chk != cof.action_ind)) OR ((((request->chart_section_list[secindex].
     chart_group_list[grpindex].orders_info.action_lbl != cof.action_lbl)) OR ((((request->
     chart_section_list[secindex].chart_group_list[grpindex].orders_info.order_status_chk != cof
     .order_status_ind)) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].
     orders_info.order_status_lbl != cof.order_status_lbl)) OR ((((request->chart_section_list[
     secindex].chart_group_list[grpindex].orders_info.mnemonic_chk != cof.mnemonic_ind)) OR ((((
     request->chart_section_list[secindex].chart_group_list[grpindex].orders_info.mnemonic_lbl != cof
     .mnemonic_lbl)) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].
     orders_info.order_phys_chk != cof.order_phys_ind)) OR ((((request->chart_section_list[secindex].
     chart_group_list[grpindex].orders_info.order_phys_lbl != cof.order_phys_lbl)) OR ((((request->
     chart_section_list[secindex].chart_group_list[grpindex].orders_info.order_placer_chk != cof
     .order_placer_ind)) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].
     orders_info.order_placer_lbl != cof.order_placer_lbl)) OR ((((request->chart_section_list[
     secindex].chart_group_list[grpindex].orders_info.order_type_chk != cof.order_type_ind)) OR ((((
     request->chart_section_list[secindex].chart_group_list[grpindex].orders_info.order_type_lbl !=
     cof.order_type_lbl)) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].
     orders_info.details_chk != cof.details_ind)) OR ((((request->chart_section_list[secindex].
     chart_group_list[grpindex].orders_info.details_lbl != cof.details_lbl)) OR ((((request->
     chart_section_list[secindex].chart_group_list[grpindex].orders_info.review_chk != cof.review_ind
     )) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].orders_info.
     review_lbl != cof.review_lbl)) OR ((((request->chart_section_list[secindex].chart_group_list[
     grpindex].orders_info.detail_order != cof.detail_order)) OR ((((request->chart_section_list[
     secindex].chart_group_list[grpindex].orders_info.review_order != cof.review_order)) OR ((((
     request->chart_section_list[secindex].chart_group_list[grpindex].orders_info.date_mask != cof
     .date_mask)) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].orders_info
     .time_mask != cof.time_mask)) OR ((((request->chart_section_list[secindex].chart_group_list[
     grpindex].orders_info.orderset_exclude_ind != cof.exclude_osname_ind)) OR ((((request->
     chart_section_list[secindex].chart_group_list[grpindex].orders_info.label_bit_map != cof
     .label_bit_map)) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].
     orders_info.cancel_reason_lbl != cof.cancel_reason_lbl)) OR ((((request->chart_section_list[
     secindex].chart_group_list[grpindex].orders_info.canceled_dttm_lbl != cof.canceled_dttm_lbl))
      OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].orders_info.
     comm_type_lbl != cof.comm_type_lbl)) OR ((((request->chart_section_list[secindex].
     chart_group_list[grpindex].orders_info.dept_status_lbl != cof.dept_status_lbl)) OR ((((request->
     chart_section_list[secindex].chart_group_list[grpindex].orders_info.action_seq_flag != cof
     .action_seq_flag)) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].
     orders_info.orig_order_dttm_lbl != cof.orig_order_dttm_lbl)) OR ((((request->chart_section_list[
     secindex].chart_group_list[grpindex].orders_info.discontinued_dttm_lbl != cof
     .discontinued_dttm_lbl)) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex]
     .orders_info.future_disc_dttm_lbl != cof.future_disc_dttm_lbl)) OR ((((request->
     chart_section_list[secindex].chart_group_list[grpindex].orders_info.suppress_meds_bit_map != cof
     .suppress_meds_bit_map)) OR ((request->chart_section_list[secindex].chart_group_list[grpindex].
     orders_info.detailed_layout_ind != cof.detailed_layout_ind))) )) )) )) )) )) )) )) )) )) )) ))
     )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )
      update_orders_flag = 1
     ENDIF
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_ORDERS_FORMAT","CHECKORDERSSECTION",1,1)
   IF (update_orders_flag=1)
    CALL update_orders(secindex,grpindex)
   ENDIF
 END ;Subroutine
 SUBROUTINE (add_mar2_format(sindex=i4(val),gindex=i4(val)) =null)
   CALL log_message("In add_mar2_format()",log_level_debug)
   INSERT  FROM chart_mar_format cmf
    SET cmf.chart_group_id = chart_group_next_seq, cmf.include_img_header_ind = request->
     chart_section_list[sindex].chart_group_list[gindex].mar2_info.include_img_head_ind, cmf
     .include_img_footer_ind = request->chart_section_list[sindex].chart_group_list[gindex].mar2_info
     .include_img_foot_ind,
     cmf.active_ind = 1, cmf.active_status_cd = reqdata->active_status_cd, cmf.updt_dt_tm =
     cnvtdatetime(curdate,curtime),
     cmf.updt_id = reqinfo->updt_id, cmf.updt_applctx = reqinfo->updt_applctx, cmf.updt_task =
     reqinfo->updt_task
    WITH nocounter
   ;end insert
   CALL error_and_zero_check(curqual,"CHART_MAR_FORMAT","ADD_MAR2_FORMAT",1,1)
 END ;Subroutine
 SUBROUTINE (update_mar2(secindex=i4(val),grpindex=i4(val)) =null)
   CALL log_message("In update_mar2()",log_level_debug)
   UPDATE  FROM chart_mar_format cmf
    SET cmf.include_img_header_ind = request->chart_section_list[secindex].chart_group_list[grpindex]
     .mar2_info.include_img_head_ind, cmf.include_img_footer_ind = request->chart_section_list[
     secindex].chart_group_list[grpindex].mar2_info.include_img_foot_ind, cmf.active_ind = 1,
     cmf.active_status_cd = reqdata->active_status_cd, cmf.updt_cnt = (cmf.updt_cnt+ 1), cmf
     .updt_dt_tm = cnvtdatetime(curdate,curtime),
     cmf.updt_id = reqinfo->updt_id, cmf.updt_applctx = reqinfo->updt_applctx, cmf.updt_task =
     reqinfo->updt_task
    WHERE (cmf.chart_group_id=request->chart_section_list[secindex].chart_group_list[grpindex].
    chart_group_id)
    WITH nocounter
   ;end update
   CALL error_and_zero_check(curqual,"CHART_MAR_FORMAT","UPDATE_MAR2",1,1)
 END ;Subroutine
 SUBROUTINE (checknewmarsection(secindex=i4(val),grpindex=i4(val)) =null)
   CALL log_message("In CheckNewMarSection()",log_level_debug)
   DECLARE update_mar_flag = i2 WITH noconstant(0), protect
   SELECT INTO "nl:"
    FROM chart_mar_format cmf
    WHERE (cmf.chart_group_id=request->chart_section_list[secindex].chart_group_list[grpindex].
    chart_group_id)
    DETAIL
     IF ((((request->chart_section_list[secindex].chart_group_list[grpindex].mar2_info.
     include_img_foot_ind != cmf.include_img_footer_ind)) OR ((request->chart_section_list[secindex].
     chart_group_list[grpindex].mar2_info.include_img_head_ind != cmf.include_img_header_ind))) )
      update_mar_flag = 1
     ENDIF
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_MAR_FORMAT","CHECKNEWMARSECTION",1,1)
   IF (update_mar_flag=1)
    CALL update_mar2(secindex,grpindex)
   ENDIF
 END ;Subroutine
 SUBROUTINE (add_mph_format(sindex=i4(val),gindex=i4(val)) =null)
   CALL log_message("In add_mph_format()",log_level_debug)
   INSERT  FROM chart_generic_format cgf
    SET cgf.chart_group_id = chart_group_next_seq, cgf.include_img_header_ind = request->
     chart_section_list[sindex].chart_group_list[gindex].mph_info.include_img_head_ind, cgf
     .include_img_footer_ind = request->chart_section_list[sindex].chart_group_list[gindex].mph_info.
     include_img_foot_ind,
     cgf.updt_dt_tm = cnvtdatetime(curdate,curtime), cgf.updt_id = reqinfo->updt_id, cgf.updt_applctx
      = reqinfo->updt_applctx,
     cgf.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   CALL error_and_zero_check(curqual,"CHART_GENERIC_FORMAT","ADD_MPH_FORMAT",1,1)
 END ;Subroutine
 SUBROUTINE (update_mph(secindex=i4(val),grpindex=i4(val)) =null)
   CALL log_message("In update_mph()",log_level_debug)
   UPDATE  FROM chart_generic_format cgf
    SET cgf.include_img_header_ind = request->chart_section_list[secindex].chart_group_list[grpindex]
     .mph_info.include_img_head_ind, cgf.include_img_footer_ind = request->chart_section_list[
     secindex].chart_group_list[grpindex].mph_info.include_img_foot_ind, cgf.updt_cnt = (cgf.updt_cnt
     + 1),
     cgf.updt_dt_tm = cnvtdatetime(curdate,curtime), cgf.updt_id = reqinfo->updt_id, cgf.updt_applctx
      = reqinfo->updt_applctx,
     cgf.updt_task = reqinfo->updt_task
    WHERE (cgf.chart_group_id=request->chart_section_list[secindex].chart_group_list[grpindex].
    chart_group_id)
    WITH nocounter
   ;end update
   CALL error_and_zero_check(curqual,"CHART_GENERIC_FORMAT","UPDATE_MPH",1,1)
 END ;Subroutine
 SUBROUTINE (checkmedprofhistsection(secindex=i4(val),grpindex=i4(val)) =null)
   CALL log_message("In CheckMedProfHistSection()",log_level_debug)
   DECLARE update_medprof_flag = i2 WITH noconstant(0), protect
   SELECT INTO "nl:"
    FROM chart_generic_format cgf
    WHERE (cgf.chart_group_id=request->chart_section_list[secindex].chart_group_list[grpindex].
    chart_group_id)
    DETAIL
     IF ((((request->chart_section_list[secindex].chart_group_list[grpindex].mph_info.
     include_img_foot_ind != cgf.include_img_footer_ind)) OR ((request->chart_section_list[secindex].
     chart_group_list[grpindex].mph_info.include_img_head_ind != cgf.include_img_header_ind))) )
      update_medprof_flag = 1
     ENDIF
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_GENERIC_FORMAT","CHECKMEDPROFHISTSECTION",1,1)
   IF (update_medprof_flag=1)
    CALL update_mph(secindex,grpindex)
   ENDIF
 END ;Subroutine
 SUBROUTINE (add_discern_report_info(secindex=i4(val),grpindex=i4(val)) =null)
   CALL log_message("In add_discern_report_info()",log_level_debug)
   INSERT  FROM chart_generic_format cgf
    SET cgf.chart_group_id = chart_group_next_seq, cgf.include_img_header_ind = request->
     chart_section_list[secindex].chart_group_list[grpindex].discern_report_info.include_img_head_ind,
     cgf.include_img_footer_ind = request->chart_section_list[secindex].chart_group_list[grpindex].
     discern_report_info.include_img_foot_ind,
     cgf.chart_discern_request_id = request->chart_section_list[secindex].chart_group_list[grpindex].
     discern_report_info.chart_discern_request_id, cgf.updt_dt_tm = cnvtdatetime(curdate,curtime),
     cgf.updt_id = reqinfo->updt_id,
     cgf.updt_applctx = reqinfo->updt_applctx, cgf.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   CALL error_and_zero_check(curqual,"CHART_GENERIC_FORMAT","ADD_DISCERN_REPORT_INFO",1,1)
 END ;Subroutine
 SUBROUTINE (update_discern_report_info(secindex=i4(val),grpindex=i4(val)) =null)
   CALL log_message("In update_discern_report_info()",log_level_debug)
   UPDATE  FROM chart_generic_format cgf
    SET cgf.include_img_header_ind = request->chart_section_list[secindex].chart_group_list[grpindex]
     .discern_report_info.include_img_head_ind, cgf.include_img_footer_ind = request->
     chart_section_list[secindex].chart_group_list[grpindex].discern_report_info.include_img_foot_ind,
     cgf.chart_discern_request_id = request->chart_section_list[secindex].chart_group_list[grpindex].
     discern_report_info.chart_discern_request_id,
     cgf.updt_cnt = (cgf.updt_cnt+ 1), cgf.updt_dt_tm = cnvtdatetime(curdate,curtime), cgf.updt_id =
     reqinfo->updt_id,
     cgf.updt_applctx = reqinfo->updt_applctx, cgf.updt_task = reqinfo->updt_task
    WHERE (cgf.chart_group_id=request->chart_section_list[secindex].chart_group_list[grpindex].
    chart_group_id)
    WITH nocounter
   ;end update
   CALL error_and_zero_check(curqual,"CHART_GENERIC_FORMAT","UPDATE_DISCERN_REPORT_INFO",1,1)
 END ;Subroutine
 SUBROUTINE (checkuserdefinedsection(secindex=i4(val),grpindex=i4(val)) =null)
   CALL log_message("In CheckUserDefinedSection()",log_level_debug)
   DECLARE update_user_defined_flag = i2 WITH noconstant(0), protect
   SELECT INTO "nl:"
    FROM chart_generic_format cgf
    WHERE (cgf.chart_group_id=request->chart_section_list[secindex].chart_group_list[grpindex].
    chart_group_id)
    DETAIL
     IF ((((request->chart_section_list[secindex].chart_group_list[grpindex].discern_report_info.
     include_img_foot_ind != cgf.include_img_footer_ind)) OR ((request->chart_section_list[secindex].
     chart_group_list[grpindex].discern_report_info.include_img_head_ind != cgf
     .include_img_header_ind))) )
      update_user_defined_flag = 1
     ENDIF
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_GENERIC_FORMAT","CHECKUSERDEFINEDSECTION",1,1)
   IF (update_flag=1)
    CALL update_discern_report_info(secindex,grpindex)
   ENDIF
 END ;Subroutine
 SUBROUTINE (add_io_format(sindex=i4(val),gindex=i4(val)) =null)
   CALL log_message("In add_io_format()",log_level_debug)
   DECLARE tempid = f8 WITH noconstant(0.0), protect
   SET tempid = getnextlongdataseq(null)
   INSERT  FROM long_text_reference ltr
    SET ltr.long_text_id = tempid, ltr.active_ind = 1, ltr.long_text = request->chart_section_list[
     sindex].chart_group_list[gindex].io_info.long_text,
     ltr.updt_cnt = 0, ltr.updt_dt_tm = cnvtdatetime(sysdate), ltr.updt_id = reqinfo->updt_id,
     ltr.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   CALL error_and_zero_check(curqual,"LONG_TEXT_REFERENCE","ADD_IO_FORMAT",1,1)
   INSERT  FROM chart_generic_format cgf
    SET cgf.chart_group_id = chart_group_next_seq, cgf.include_img_header_ind = request->
     chart_section_list[sindex].chart_group_list[gindex].io_info.include_img_head_ind, cgf
     .include_img_footer_ind = request->chart_section_list[sindex].chart_group_list[gindex].io_info.
     include_img_foot_ind,
     cgf.param_long_text_id = tempid, cgf.updt_dt_tm = cnvtdatetime(curdate,curtime), cgf.updt_id =
     reqinfo->updt_id,
     cgf.updt_applctx = reqinfo->updt_applctx, cgf.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   CALL error_and_zero_check(curqual,"CHART_GENERIC_FORMAT","ADD_IO_FORMAT",1,1)
 END ;Subroutine
 SUBROUTINE (update_io(secindex=i4(val),grpindex=i4(val)) =null)
   CALL log_message("In update_io()",log_level_debug)
   DECLARE tempid = f8 WITH noconstant(0.0), protect
   SELECT INTO "nl:"
    FROM chart_generic_format cgf
    WHERE (cgf.chart_group_id=request->chart_section_list[secindex].chart_group_list[grpindex].
    chart_group_id)
    DETAIL
     tempid = cgf.param_long_text_id
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_GENERIC_FORMAT","UPDATE_IO",1,1)
   UPDATE  FROM long_text_reference ltr
    SET ltr.long_text = request->chart_section_list[secindex].chart_group_list[grpindex].io_info[1].
     long_text, ltr.active_ind = 1, ltr.active_status_cd = reqdata->active_status_cd,
     ltr.updt_cnt = (ltr.updt_cnt+ 1), ltr.updt_dt_tm = cnvtdatetime(curdate,curtime), ltr.updt_id =
     reqinfo->updt_id,
     ltr.updt_applctx = reqinfo->updt_applctx, ltr.updt_task = reqinfo->updt_task
    WHERE ltr.long_text_id=tempid
   ;end update
   CALL error_and_zero_check(curqual,"LONG_TEXT_REFERENCE","UPDATE_IO",1,1)
   UPDATE  FROM chart_generic_format cgf
    SET cgf.include_img_header_ind = request->chart_section_list[secindex].chart_group_list[grpindex]
     .io_info[1].include_img_head_ind, cgf.include_img_footer_ind = request->chart_section_list[
     secindex].chart_group_list[grpindex].io_info[1].include_img_foot_ind, cgf.updt_cnt = (cgf
     .updt_cnt+ 1),
     cgf.updt_dt_tm = cnvtdatetime(curdate,curtime), cgf.updt_id = reqinfo->updt_id, cgf.updt_applctx
      = reqinfo->updt_applctx,
     cgf.updt_task = reqinfo->updt_task
    WHERE (cgf.chart_group_id=request->chart_section_list[secindex].chart_group_list[grpindex].
    chart_group_id)
    WITH nocounter
   ;end update
   CALL error_and_zero_check(curqual,"CHART_GENERIC_FORMAT","UPDATE_IO",1,1)
 END ;Subroutine
 SUBROUTINE (checkiosection(secindex=i4(val),grpindex=i4(val)) =null)
   CALL log_message("In CheckIoSection()",log_level_debug)
   DECLARE update_io_flag = i2 WITH noconstant(0), protect
   SELECT INTO "nl:"
    FROM chart_generic_format cgf,
     long_text_reference ltr
    PLAN (cgf
     WHERE (cgf.chart_group_id=request->chart_section_list[secindex].chart_group_list[grpindex].
     chart_group_id))
     JOIN (ltr
     WHERE cgf.param_long_text_id=ltr.long_text_id)
    DETAIL
     IF ((((request->chart_section_list[secindex].chart_group_list[grpindex].io_info.
     include_img_foot_ind != cgf.include_img_footer_ind)) OR ((((request->chart_section_list[secindex
     ].chart_group_list[grpindex].io_info.include_img_head_ind != cgf.include_img_header_ind)) OR ((
     request->chart_section_list[secindex].chart_group_list[grpindex].io_info.long_text != ltr
     .long_text))) )) )
      update_io_flag = 1
     ENDIF
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_GENERIC_FORMAT","CHECKIOSECTION",1,1)
   IF (update_io_flag=1)
    CALL update_io(secindex,grpindex)
   ENDIF
 END ;Subroutine
 SUBROUTINE (add_name_hist_format(sindex=i4(val),gindex=i4(val)) =null)
   CALL log_message("In add_name_hist_format()",log_level_debug)
   INSERT  FROM chart_name_hist_format cnhf
    SET cnhf.chart_group_id = chart_group_next_seq, cnhf.order_seq_ind = request->chart_section_list[
     sindex].chart_group_list[gindex].name_hist_info.order_seq_ind, cnhf.name_lbl = request->
     chart_section_list[sindex].chart_group_list[gindex].name_hist_info.name_lbl,
     cnhf.name_odr = request->chart_section_list[sindex].chart_group_list[gindex].name_hist_info.
     name_odr, cnhf.beg_effective_dt_tm_lbl = request->chart_section_list[sindex].chart_group_list[
     gindex].name_hist_info.beg_effective_dt_tm_lbl, cnhf.beg_effective_dt_tm_odr = request->
     chart_section_list[sindex].chart_group_list[gindex].name_hist_info.beg_effective_dt_tm_odr,
     cnhf.end_effective_dt_tm_lbl = request->chart_section_list[sindex].chart_group_list[gindex].
     name_hist_info.end_effective_dt_tm_lbl, cnhf.end_effective_dt_tm_odr = request->
     chart_section_list[sindex].chart_group_list[gindex].name_hist_info.end_effective_dt_tm_odr, cnhf
     .active_ind = 1,
     cnhf.active_status_cd = reqdata->active_status_cd, cnhf.updt_dt_tm = cnvtdatetime(curdate,
      curtime), cnhf.updt_id = reqinfo->updt_id,
     cnhf.updt_applctx = reqinfo->updt_applctx, cnhf.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   CALL error_and_zero_check(curqual,"CHART_NAME_HIST_FORMAT","ADD_NAME_HIST_FORMAT",1,1)
 END ;Subroutine
 SUBROUTINE (update_name_hist(secindex=i4(val),grpindex=i4(val)) =null)
   CALL log_message("In update_name_hist()",log_level_debug)
   UPDATE  FROM chart_name_hist_format cnhf
    SET cnhf.order_seq_ind = request->chart_section_list[secindex].chart_group_list[grpindex].
     name_hist_info.order_seq_ind, cnhf.name_lbl = request->chart_section_list[secindex].
     chart_group_list[grpindex].name_hist_info.name_lbl, cnhf.name_odr = request->chart_section_list[
     secindex].chart_group_list[grpindex].name_hist_info.name_odr,
     cnhf.beg_effective_dt_tm_lbl = request->chart_section_list[secindex].chart_group_list[grpindex].
     name_hist_info.beg_effective_dt_tm_lbl, cnhf.beg_effective_dt_tm_odr = request->
     chart_section_list[secindex].chart_group_list[grpindex].name_hist_info.beg_effective_dt_tm_odr,
     cnhf.end_effective_dt_tm_lbl = request->chart_section_list[secindex].chart_group_list[grpindex].
     name_hist_info.end_effective_dt_tm_lbl,
     cnhf.end_effective_dt_tm_odr = request->chart_section_list[secindex].chart_group_list[grpindex].
     name_hist_info.end_effective_dt_tm_odr, cnhf.active_ind = 1, cnhf.active_status_cd = reqdata->
     active_status_cd,
     cnhf.updt_cnt = (cnhf.updt_cnt+ 1), cnhf.updt_dt_tm = cnvtdatetime(curdate,curtime), cnhf
     .updt_id = reqinfo->updt_id,
     cnhf.updt_applctx = reqinfo->updt_applctx, cnhf.updt_task = reqinfo->updt_task
    WHERE (cnhf.chart_group_id=request->chart_section_list[secindex].chart_group_list[grpindex].
    chart_group_id)
    WITH nocounter
   ;end update
   CALL error_and_zero_check(curqual,"CHART_NAME_HIST_FORMAT","UPDATE_NAME_HIST",1,1)
 END ;Subroutine
 SUBROUTINE (checknamehistsection(secindex=i4(val),grpindex=i4(val)) =null)
   CALL log_message("In CheckAllergySection()",log_level_debug)
   DECLARE update_namehist_flag = i2 WITH noconstant(0), protect
   SELECT INTO "nl:"
    FROM chart_name_hist_format cnhf
    WHERE (cnhf.chart_group_id=request->chart_section_list[secindex].chart_group_list[grpindex].
    chart_group_id)
    DETAIL
     IF ((((request->chart_section_list[secindex].chart_group_list[grpindex].name_hist_info.
     order_seq_ind != cnhf.order_seq_ind)) OR ((((request->chart_section_list[secindex].
     chart_group_list[grpindex].name_hist_info.name_lbl != cnhf.name_lbl)) OR ((((request->
     chart_section_list[secindex].chart_group_list[grpindex].name_hist_info.name_odr != cnhf.name_odr
     )) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].name_hist_info.
     beg_effective_dt_tm_lbl != cnhf.beg_effective_dt_tm_lbl)) OR ((((request->chart_section_list[
     secindex].chart_group_list[grpindex].name_hist_info.beg_effective_dt_tm_odr != cnhf
     .beg_effective_dt_tm_odr)) OR ((((request->chart_section_list[secindex].chart_group_list[
     grpindex].name_hist_info.end_effective_dt_tm_lbl != cnhf.end_effective_dt_tm_lbl)) OR ((request
     ->chart_section_list[secindex].chart_group_list[grpindex].name_hist_info.end_effective_dt_tm_odr
      != cnhf.end_effective_dt_tm_odr))) )) )) )) )) )) )
      update_namehist_flag = 1
     ENDIF
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_NAME_HIST_FORMAT","CHECKNAMEHISTSECTION",1,1)
   IF (update_namehist_flag=1)
    CALL update_name_hist(secindex,grpindex)
   ENDIF
 END ;Subroutine
 SUBROUTINE (add_immunization_format(sindex=i4(val),gindex=i4(val)) =null)
   CALL log_message("In add_immunization_format()",log_level_debug)
   INSERT  FROM chart_immuniz_format cif
    SET cif.chart_group_id = chart_group_next_seq, cif.result_seq_ind = request->chart_section_list[
     sindex].chart_group_list[gindex].immun_info.result_seq_ind, cif.admin_note_ind = request->
     chart_section_list[sindex].chart_group_list[gindex].immun_info.admin_note_chk,
     cif.amount_ind = request->chart_section_list[sindex].chart_group_list[gindex].immun_info.
     amount_chk, cif.date_given_ind = request->chart_section_list[sindex].chart_group_list[gindex].
     immun_info.date_given_chk, cif.exp_dt_ind = request->chart_section_list[sindex].
     chart_group_list[gindex].immun_info.exp_dt_chk,
     cif.exp_tm_ind = request->chart_section_list[sindex].chart_group_list[gindex].immun_info.
     exp_tm_chk, cif.lot_num_ind = request->chart_section_list[sindex].chart_group_list[gindex].
     immun_info.lot_num_chk, cif.manufact_ind = request->chart_section_list[sindex].chart_group_list[
     gindex].immun_info.manufact_chk,
     cif.provider_ind = request->chart_section_list[sindex].chart_group_list[gindex].immun_info.
     provider_chk, cif.site_ind = request->chart_section_list[sindex].chart_group_list[gindex].
     immun_info.site_chk, cif.time_given_ind = request->chart_section_list[sindex].chart_group_list[
     gindex].immun_info.time_given_chk,
     cif.admin_person_lbl = request->chart_section_list[sindex].chart_group_list[gindex].immun_info.
     admin_person_lbl, cif.amount_lbl = request->chart_section_list[sindex].chart_group_list[gindex].
     immun_info.amount_lbl, cif.date_given_lbl = request->chart_section_list[sindex].
     chart_group_list[gindex].immun_info.date_given_lbl,
     cif.exp_dt_lbl = request->chart_section_list[sindex].chart_group_list[gindex].immun_info.
     exp_dt_lbl, cif.lot_num_lbl = request->chart_section_list[sindex].chart_group_list[gindex].
     immun_info.lot_num_lbl, cif.manufact_lbl = request->chart_section_list[sindex].chart_group_list[
     gindex].immun_info.manufact_lbl,
     cif.provider_lbl = request->chart_section_list[sindex].chart_group_list[gindex].immun_info.
     provider_lbl, cif.site_lbl = request->chart_section_list[sindex].chart_group_list[gindex].
     immun_info.site_lbl, cif.vaccine_lbl = request->chart_section_list[sindex].chart_group_list[
     gindex].immun_info.vaccine_lbl,
     cif.date_mask = request->chart_section_list[sindex].chart_group_list[gindex].immun_info.
     date_mask, cif.time_mask = request->chart_section_list[sindex].chart_group_list[gindex].
     immun_info.time_mask, cif.active_ind = 1,
     cif.active_status_cd = reqdata->active_status_cd, cif.updt_cnt = 0, cif.updt_dt_tm =
     cnvtdatetime(curdate,curtime),
     cif.updt_id = reqinfo->updt_id, cif.updt_applctx = reqinfo->updt_applctx, cif.updt_task =
     reqinfo->updt_task
    WITH nocounter
   ;end insert
   CALL error_and_zero_check(curqual,"CHART_IMMUNIZ_FORMAT","ADD_IMMUNIZATION_FORMAT",1,1)
 END ;Subroutine
 SUBROUTINE (update_immunization(secindex=i4(val),grpindex=i4(val)) =null)
   CALL log_message("In update_immunization()",log_level_debug)
   UPDATE  FROM chart_immuniz_format cif
    SET cif.result_seq_ind = request->chart_section_list[secindex].chart_group_list[grpindex].
     immun_info.result_seq_ind, cif.admin_note_ind = request->chart_section_list[secindex].
     chart_group_list[grpindex].immun_info.admin_note_chk, cif.amount_ind = request->
     chart_section_list[secindex].chart_group_list[grpindex].immun_info.amount_chk,
     cif.date_given_ind = request->chart_section_list[secindex].chart_group_list[grpindex].immun_info
     .date_given_chk, cif.exp_dt_ind = request->chart_section_list[secindex].chart_group_list[
     grpindex].immun_info.exp_dt_chk, cif.exp_tm_ind = request->chart_section_list[secindex].
     chart_group_list[grpindex].immun_info.exp_tm_chk,
     cif.lot_num_ind = request->chart_section_list[secindex].chart_group_list[grpindex].immun_info.
     lot_num_chk, cif.manufact_ind = request->chart_section_list[secindex].chart_group_list[grpindex]
     .immun_info.manufact_chk, cif.provider_ind = request->chart_section_list[secindex].
     chart_group_list[grpindex].immun_info.provider_chk,
     cif.site_ind = request->chart_section_list[secindex].chart_group_list[grpindex].immun_info.
     site_chk, cif.time_given_ind = request->chart_section_list[secindex].chart_group_list[grpindex].
     immun_info.time_given_chk, cif.admin_person_lbl = request->chart_section_list[secindex].
     chart_group_list[grpindex].immun_info.admin_person_lbl,
     cif.amount_lbl = request->chart_section_list[secindex].chart_group_list[grpindex].immun_info.
     amount_lbl, cif.date_given_lbl = request->chart_section_list[secindex].chart_group_list[grpindex
     ].immun_info.date_given_lbl, cif.exp_dt_lbl = request->chart_section_list[secindex].
     chart_group_list[grpindex].immun_info.exp_dt_lbl,
     cif.lot_num_lbl = request->chart_section_list[secindex].chart_group_list[grpindex].immun_info.
     lot_num_lbl, cif.manufact_lbl = request->chart_section_list[secindex].chart_group_list[grpindex]
     .immun_info.manufact_lbl, cif.provider_lbl = request->chart_section_list[secindex].
     chart_group_list[grpindex].immun_info.provider_lbl,
     cif.site_lbl = request->chart_section_list[secindex].chart_group_list[grpindex].immun_info.
     site_lbl, cif.vaccine_lbl = request->chart_section_list[secindex].chart_group_list[grpindex].
     immun_info.vaccine_lbl, cif.date_mask = request->chart_section_list[secindex].chart_group_list[
     grpindex].immun_info.date_mask,
     cif.time_mask = request->chart_section_list[secindex].chart_group_list[grpindex].immun_info.
     time_mask, cif.active_ind = 1, cif.active_status_cd = reqdata->active_status_cd,
     cif.updt_cnt = (cif.updt_cnt+ 1), cif.updt_dt_tm = cnvtdatetime(curdate,curtime), cif.updt_id =
     reqinfo->updt_id,
     cif.updt_applctx = reqinfo->updt_applctx, cif.updt_task = reqinfo->updt_task
    WHERE (cif.chart_group_id=request->chart_section_list[secindex].chart_group_list[grpindex].
    chart_group_id)
    WITH nocounter
   ;end update
   CALL error_and_zero_check(curqual,"CHART_IMMUNIZ_FORMAT","UPDATE_IMMUNIZATION",1,1)
 END ;Subroutine
 SUBROUTINE (checkimmunizationsection(secindex=i4(val),grpindex=i4(val)) =null)
   CALL log_message("In CheckImmunizationSection()",log_level_debug)
   DECLARE update_immun_flag = i2 WITH noconstant(0), protect
   SELECT INTO "nl:"
    FROM chart_immuniz_format cif
    WHERE (cif.chart_group_id=request->chart_section_list[secindex].chart_group_list[grpindex].
    chart_group_id)
    DETAIL
     IF ((((request->chart_section_list[secindex].chart_group_list[grpindex].immun_info.
     result_seq_ind != cif.result_seq_ind)) OR ((((request->chart_section_list[secindex].
     chart_group_list[grpindex].immun_info.admin_note_chk != cif.admin_note_ind)) OR ((((request->
     chart_section_list[secindex].chart_group_list[grpindex].immun_info.amount_chk != cif.amount_ind)
     ) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].immun_info.
     date_given_chk != cif.date_given_ind)) OR ((((request->chart_section_list[secindex].
     chart_group_list[grpindex].immun_info.exp_dt_chk != cif.exp_dt_ind)) OR ((((request->
     chart_section_list[secindex].chart_group_list[grpindex].immun_info.exp_tm_chk != cif.exp_tm_ind)
     ) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].immun_info.lot_num_chk
      != cif.lot_num_ind)) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].
     immun_info.manufact_chk != cif.manufact_ind)) OR ((((request->chart_section_list[secindex].
     chart_group_list[grpindex].immun_info.provider_chk != cif.provider_ind)) OR ((((request->
     chart_section_list[secindex].chart_group_list[grpindex].immun_info.site_chk != cif.site_ind))
      OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].immun_info.
     time_given_chk != cif.time_given_ind)) OR ((((request->chart_section_list[secindex].
     chart_group_list[grpindex].immun_info.admin_person_lbl != cif.admin_person_lbl)) OR ((((request
     ->chart_section_list[secindex].chart_group_list[grpindex].immun_info.amount_lbl != cif
     .amount_lbl)) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].immun_info
     .date_given_lbl != cif.date_given_lbl)) OR ((((request->chart_section_list[secindex].
     chart_group_list[grpindex].immun_info.exp_dt_lbl != cif.exp_dt_lbl)) OR ((((request->
     chart_section_list[secindex].chart_group_list[grpindex].immun_info.lot_num_lbl != cif
     .lot_num_lbl)) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].
     immun_info.manufact_lbl != cif.manufact_lbl)) OR ((((request->chart_section_list[secindex].
     chart_group_list[grpindex].immun_info.provider_lbl != cif.provider_lbl)) OR ((((request->
     chart_section_list[secindex].chart_group_list[grpindex].immun_info.site_lbl != cif.site_lbl))
      OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].immun_info.vaccine_lbl
      != cif.vaccine_lbl)) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].
     immun_info.date_mask != cif.date_mask)) OR ((request->chart_section_list[secindex].
     chart_group_list[grpindex].immun_info.time_mask != cif.time_mask))) )) )) )) )) )) )) )) )) ))
     )) )) )) )) )) )) )) )) )) )) )) )
      update_immun_flag = 1
     ENDIF
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_IMMUNIZ_FORMAT","CHECKIMMUNIZATIONSECTION",1,1)
   IF (update_immun_flag=1)
    CALL update_immunization(secindex,grpindex)
   ENDIF
 END ;Subroutine
 SUBROUTINE (add_proc_hist_format(sindex=i4(val),gindex=i4(val)) =null)
   CALL log_message("In add_proc_hist_format()",log_level_debug)
   INSERT  FROM chart_prochist_format cpf
    SET cpf.chart_group_id = chart_group_next_seq, cpf.proc_lbl = request->chart_section_list[sindex]
     .chart_group_list[gindex].proc_hist_info.proc_lbl, cpf.proc_ord = request->chart_section_list[
     sindex].chart_group_list[gindex].proc_hist_info.proc_ord,
     cpf.status_lbl = request->chart_section_list[sindex].chart_group_list[gindex].proc_hist_info.
     status_lbl, cpf.status_ord = request->chart_section_list[sindex].chart_group_list[gindex].
     proc_hist_info.status_ord, cpf.date_lbl = request->chart_section_list[sindex].chart_group_list[
     gindex].proc_hist_info.date_lbl,
     cpf.date_ord = request->chart_section_list[sindex].chart_group_list[gindex].proc_hist_info.
     date_ord, cpf.provider_lbl = request->chart_section_list[sindex].chart_group_list[gindex].
     proc_hist_info.provider_lbl, cpf.provider_ord = request->chart_section_list[sindex].
     chart_group_list[gindex].proc_hist_info.provider_ord,
     cpf.location_lbl = request->chart_section_list[sindex].chart_group_list[gindex].proc_hist_info.
     location_lbl, cpf.location_ord = request->chart_section_list[sindex].chart_group_list[gindex].
     proc_hist_info.location_ord, cpf.active_ind = 1,
     cpf.active_status_cd = reqdata->active_status_cd, cpf.updt_cnt = 0, cpf.updt_dt_tm =
     cnvtdatetime(curdate,curtime),
     cpf.updt_id = reqinfo->updt_id, cpf.updt_applctx = reqinfo->updt_applctx, cpf.updt_task =
     reqinfo->updt_task
    WITH nocounter
   ;end insert
   CALL error_and_zero_check(curqual,"CHART_PROCHIST_FORMAT","ADD_PROC_HIST_FORMAT",1,1)
 END ;Subroutine
 SUBROUTINE (update_proc_hist(secindex=i4(val),grpindex=i4(val)) =null)
   CALL log_message("In update_proc_hist()",log_level_debug)
   UPDATE  FROM chart_prochist_format cpf
    SET cpf.proc_lbl = request->chart_section_list[secindex].chart_group_list[grpindex].
     proc_hist_info.proc_lbl, cpf.proc_ord = request->chart_section_list[secindex].chart_group_list[
     grpindex].proc_hist_info.proc_ord, cpf.status_lbl = request->chart_section_list[secindex].
     chart_group_list[grpindex].proc_hist_info.status_lbl,
     cpf.status_ord = request->chart_section_list[secindex].chart_group_list[grpindex].proc_hist_info
     .status_ord, cpf.date_lbl = request->chart_section_list[secindex].chart_group_list[grpindex].
     proc_hist_info.date_lbl, cpf.date_ord = request->chart_section_list[secindex].chart_group_list[
     grpindex].proc_hist_info.date_ord,
     cpf.provider_lbl = request->chart_section_list[secindex].chart_group_list[grpindex].
     proc_hist_info.provider_lbl, cpf.provider_ord = request->chart_section_list[secindex].
     chart_group_list[grpindex].proc_hist_info.provider_ord, cpf.location_lbl = request->
     chart_section_list[secindex].chart_group_list[grpindex].proc_hist_info.location_lbl,
     cpf.location_ord = request->chart_section_list[secindex].chart_group_list[grpindex].
     proc_hist_info.location_ord, cpf.active_ind = 1, cpf.active_status_cd = reqdata->
     active_status_cd,
     cpf.updt_cnt = (cpf.updt_cnt+ 1), cpf.updt_dt_tm = cnvtdatetime(curdate,curtime), cpf.updt_id =
     reqinfo->updt_id,
     cpf.updt_applctx = reqinfo->updt_applctx, cpf.updt_task = reqinfo->updt_task
    WHERE (cpf.chart_group_id=request->chart_section_list[secindex].chart_group_list[grpindex].
    chart_group_id)
    WITH nocounter
   ;end update
   CALL error_and_zero_check(curqual,"CHART_PROCHIST_FORMAT","UPDATE_PROC_HIST",1,1)
 END ;Subroutine
 SUBROUTINE (checkprochistsection(secindex=i4(val),grpindex=i4(val)) =null)
   CALL log_message("In CheckProcHistSection()",log_level_debug)
   DECLARE update_prochist_flag = i2 WITH noconstant(0), protect
   SELECT INTO "nl:"
    FROM chart_prochist_format cpf
    WHERE (cpf.chart_group_id=request->chart_section_list[secindex].chart_group_list[grpindex].
    chart_group_id)
    DETAIL
     IF ((((request->chart_section_list[secindex].chart_group_list[grpindex].proc_hist_info.proc_lbl
      != cpf.proc_lbl)) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].
     proc_hist_info.proc_ord != cpf.proc_ord)) OR ((((request->chart_section_list[secindex].
     chart_group_list[grpindex].proc_hist_info.status_lbl != cpf.status_lbl)) OR ((((request->
     chart_section_list[secindex].chart_group_list[grpindex].proc_hist_info.status_ord != cpf
     .status_ord)) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].
     proc_hist_info.date_lbl != cpf.date_lbl)) OR ((((request->chart_section_list[secindex].
     chart_group_list[grpindex].proc_hist_info.date_ord != cpf.date_ord)) OR ((((request->
     chart_section_list[secindex].chart_group_list[grpindex].proc_hist_info.provider_lbl != cpf
     .provider_lbl)) OR ((((request->chart_section_list[secindex].chart_group_list[grpindex].
     proc_hist_info.provider_ord != cpf.provider_ord)) OR ((((request->chart_section_list[secindex].
     chart_group_list[grpindex].proc_hist_info.location_lbl != cpf.location_lbl)) OR ((request->
     chart_section_list[secindex].chart_group_list[grpindex].proc_hist_info.location_ord != cpf
     .location_ord))) )) )) )) )) )) )) )) )) )
      update_prochist_flag = 1
     ENDIF
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_PROCHIST_FORMAT","CHECKPROCHISTSECTION",1,1)
   IF (update_prochist_flag=1)
    CALL update_proc_hist(secindex,grpindex)
   ENDIF
 END ;Subroutine
 SUBROUTINE add_facesheet_section(null)
   CALL log_message("In add_facesheet_section()",log_level_debug)
   DECLARE chart_section_next_seq = f8 WITH noconstant(0.0), protect
   DECLARE chart_group_next_seq = f8 WITH noconstant(0.0), protect
   SET chart_section_next_seq = getnextchartsectionid(null)
   INSERT  FROM chart_section cs
    SET cs.chart_section_id = chart_section_next_seq, cs.chart_section_desc = "Facesheet", cs
     .section_type_flag = 36,
     cs.sect_page_brk_ind = 0, cs.active_ind = 1, cs.active_status_cd = reqdata->active_status_cd,
     cs.active_status_dt_tm = cnvtdatetime(sysdate), cs.active_status_prsnl_id = reqinfo->updt_id, cs
     .updt_cnt = 0,
     cs.updt_dt_tm = cnvtdatetime(sysdate), cs.updt_id = reqinfo->updt_id, cs.updt_task = reqinfo->
     updt_task,
     cs.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   CALL error_and_zero_check(curqual,"CHART_SECTION","ADD_FACESHEET_SECTION",1,1)
   SET reply->facesheet_sec_id = chart_section_next_seq
   INSERT  FROM chart_form_sects cfs
    SET cfs.chart_format_id = request->chart_format_id, cfs.chart_section_id = chart_section_next_seq,
     cfs.cs_sequence_num = (request->chart_section_count+ 1),
     cfs.active_ind = 1, cfs.active_status_cd = reqdata->active_status_cd, cfs.active_status_dt_tm =
     cnvtdatetime(sysdate),
     cfs.active_status_prsnl_id = reqinfo->updt_id, cfs.updt_cnt = 0, cfs.updt_dt_tm = cnvtdatetime(
      sysdate),
     cfs.updt_id = reqinfo->updt_id, cfs.updt_task = reqinfo->updt_task, cfs.updt_applctx = reqinfo->
     updt_applctx
    WITH nocounter
   ;end insert
   CALL error_and_zero_check(curqual,"CHART_FORM_SECTS","ADD_FACESHEET_SECTION",1,1)
   SET chart_group_next_seq = getnextchartgroupid(null)
   INSERT  FROM chart_group cg
    SET cg.chart_group_id = chart_group_next_seq, cg.chart_section_id = chart_section_next_seq, cg
     .cg_sequence = 1,
     cg.max_results = 0, cg.active_ind = 1, cg.active_status_cd = reqdata->active_status_cd,
     cg.active_status_dt_tm = cnvtdatetime(sysdate), cg.active_status_prsnl_id = reqinfo->updt_id, cg
     .updt_cnt = 0,
     cg.updt_dt_tm = cnvtdatetime(sysdate), cg.updt_id = reqinfo->updt_id, cg.updt_task = reqinfo->
     updt_task,
     cg.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   CALL error_and_zero_check(curqual,"CHART_GROUP","ADD_FACESHEET_SECTION",1,1)
 END ;Subroutine
 SUBROUTINE update_facesheet_section(null)
   CALL log_message("In update_facesheet_section()",log_level_debug)
   INSERT  FROM chart_form_sects cfs
    SET cfs.chart_format_id = request->chart_format_id, cfs.chart_section_id = request->
     facesheet_sec_id, cfs.cs_sequence_num = (request->chart_section_count+ 1),
     cfs.active_ind = 1, cfs.active_status_cd = reqdata->active_status_cd, cfs.active_status_dt_tm =
     cnvtdatetime(sysdate),
     cfs.active_status_prsnl_id = reqinfo->updt_id, cfs.updt_cnt = 0, cfs.updt_dt_tm = cnvtdatetime(
      sysdate),
     cfs.updt_id = reqinfo->updt_id, cfs.updt_task = reqinfo->updt_task, cfs.updt_applctx = reqinfo->
     updt_applctx
    WITH nocounter
   ;end insert
   CALL error_and_zero_check(curqual,"CHART_FORM_SECTS","UPDATE_FACESHEET_SECTION",1,1)
   SET reply->facesheet_sec_id = request->facesheet_sec_id
 END ;Subroutine
 SUBROUTINE delete_facesheet_section(null)
   CALL log_message("In delete_facesheet_section()",log_level_debug)
   DELETE  FROM chart_group cg
    WHERE (cg.chart_section_id=request->facesheet_sec_id)
    WITH nocounter
   ;end delete
   DELETE  FROM chart_form_sects cfs
    WHERE (cfs.chart_section_id=request->facesheet_sec_id)
    WITH nocounter
   ;end delete
 END ;Subroutine
 SUBROUTINE (insertevent(sindex=i4(val),gindex=i4(val),evtindex=i4(val)) =null)
   CALL log_message("In InsertEvent()",log_level_debug)
   INSERT  FROM chart_grp_evnt_set ce
    SET ce.event_set_name =
     IF ((request->chart_section_list[sindex].chart_group_list[gindex].chart_event_list[evtindex].
     procedure_type_flag=0)) request->chart_section_list[sindex].chart_group_list[gindex].
      chart_event_list[evtindex].event_set_name
     ELSE " "
     ENDIF
     , ce.order_catalog_cd =
     IF ((request->chart_section_list[sindex].chart_group_list[gindex].chart_event_list[evtindex].
     procedure_type_flag=1)) request->chart_section_list[sindex].chart_group_list[gindex].
      chart_event_list[evtindex].order_catalog_cd
     ELSE 0.0
     ENDIF
     , ce.synonym_id =
     IF ((request->chart_section_list[sindex].chart_group_list[gindex].chart_event_list[evtindex].
     procedure_type_flag=1)) request->chart_section_list[sindex].chart_group_list[gindex].
      chart_event_list[evtindex].synonym_id
     ELSE 0.0
     ENDIF
     ,
     ce.procedure_type_flag = request->chart_section_list[sindex].chart_group_list[gindex].
     chart_event_list[evtindex].procedure_type_flag, ce.chart_group_id = request->chart_section_list[
     sindex].chart_group_list[gindex].chart_group_id, ce.event_set_seq = evtindex,
     ce.zone = request->chart_section_list[sindex].chart_group_list[gindex].chart_event_list[evtindex
     ].zone, ce.display_name = request->chart_section_list[sindex].chart_group_list[gindex].
     chart_event_list[evtindex].display_name, ce.active_ind = 1,
     ce.active_status_cd = reqdata->active_status_cd, ce.active_status_dt_tm = cnvtdatetime(sysdate),
     ce.active_status_prsnl_id = reqinfo->updt_id,
     ce.updt_cnt = 0, ce.updt_dt_tm = cnvtdatetime(sysdate), ce.updt_id = reqinfo->updt_id,
     ce.updt_task = reqinfo->updt_task, ce.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   CALL error_and_zero_check(curqual,"CHART_GRP_EVNT_SET","INSERTEVENT",1,1)
   FOR (d = 1 TO size(request->chart_section_list[sindex].chart_group_list[gindex].chart_event_list[
    evtindex].suppressed_cd_list,5))
     CALL insertsuppressedcode(sindex,gindex,evtindex,d)
   ENDFOR
 END ;Subroutine
 SUBROUTINE (update_event(secindex=i4(val),grpindex=i4(val),evtindex=i4(val)) =null)
   CALL log_message("In update_event()",log_level_debug)
   UPDATE  FROM chart_grp_evnt_set ce
    SET ce.event_set_seq = evtindex, ce.order_catalog_cd = request->chart_section_list[secindex].
     chart_group_list[grpindex].chart_event_list[evtindex].order_catalog_cd, ce.display_name =
     request->chart_section_list[secindex].chart_group_list[grpindex].chart_event_list[evtindex].
     display_name,
     ce.zone = request->chart_section_list[secindex].chart_group_list[grpindex].chart_event_list[
     evtindex].zone, ce.synonym_id = request->chart_section_list[secindex].chart_group_list[grpindex]
     .chart_event_list[evtindex].synonym_id, ce.active_ind = 1,
     ce.active_status_cd = reqdata->active_status_cd, ce.updt_cnt = (ce.updt_cnt+ 1), ce.updt_dt_tm
      = cnvtdatetime(curdate,curtime),
     ce.updt_id = reqinfo->updt_id, ce.updt_applctx = reqinfo->updt_applctx, ce.updt_task = reqinfo->
     updt_task
    WHERE (ce.chart_group_id=request->chart_section_list[secindex].chart_group_list[grpindex].
    chart_group_id)
     AND ((ce.procedure_type_flag=0
     AND (ce.event_set_name=request->chart_section_list[secindex].chart_group_list[grpindex].
    chart_event_list[evtindex].event_set_name)) OR (ce.procedure_type_flag=1
     AND (ce.order_catalog_cd=request->chart_section_list[secindex].chart_group_list[grpindex].
    chart_event_list[evtindex].order_catalog_cd)))
    WITH nocounter
   ;end update
   CALL error_and_zero_check(curqual,"CHART_GRP_EVNT_SET","UPDATE_EVENT",1,1)
 END ;Subroutine
 SUBROUTINE (insertsuppressedcode(sindex=i4(val),gindex=i4(val),evtindex=i4(val),cdindex=i4(val)) =
  null)
   CALL log_message("In InsertSuppressedCode()",log_level_debug)
   INSERT  FROM chart_grp_evnt_suppress cges
    SET cges.chart_evnt_suppress_id = seq(reference_seq,nextval), cges.chart_group_id = request->
     chart_section_list[sindex].chart_group_list[gindex].chart_group_id, cges.event_set_name =
     IF ((request->chart_section_list[sindex].chart_group_list[gindex].chart_event_list[evtindex].
     procedure_type_flag=0)) request->chart_section_list[sindex].chart_group_list[gindex].
      chart_event_list[evtindex].event_set_name
     ELSE " "
     ENDIF
     ,
     cges.order_catalog_cd =
     IF ((request->chart_section_list[sindex].chart_group_list[gindex].chart_event_list[evtindex].
     procedure_type_flag=1)) request->chart_section_list[sindex].chart_group_list[gindex].
      chart_event_list[evtindex].order_catalog_cd
     ELSE 0.0
     ENDIF
     , cges.event_cd =
     IF ((request->chart_section_list[sindex].chart_group_list[gindex].chart_event_list[evtindex].
     procedure_type_flag=0)) request->chart_section_list[sindex].chart_group_list[gindex].
      chart_event_list[evtindex].suppressed_cd_list[cdindex].event_cd
     ELSE 0.0
     ENDIF
     , cges.task_assay_cd =
     IF ((request->chart_section_list[sindex].chart_group_list[gindex].chart_event_list[evtindex].
     procedure_type_flag=1)) request->chart_section_list[sindex].chart_group_list[gindex].
      chart_event_list[evtindex].suppressed_cd_list[cdindex].task_assay_cd
     ELSE 0.0
     ENDIF
     ,
     cges.updt_cnt = 0, cges.updt_dt_tm = cnvtdatetime(sysdate), cges.updt_id = reqinfo->updt_id,
     cges.updt_task = reqinfo->updt_task, cges.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   CALL error_and_zero_check(curqual,"CHART_GRP_EVNT_SUPPRESS","INSERTSUPPRESSEDCODE",1,1)
 END ;Subroutine
 SUBROUTINE (update_ap_cpt_options(long_text_id=f8(val),long_text=vc(val)) =f8)
   CALL log_message("In UPDATE_AP_CPT_OPTIONS()",log_level_debug)
   DECLARE trimmed_long_text = vc WITH protect, noconstant("")
   SET trimmed_long_text = trim(long_text)
   IF (long_text_id=0)
    IF (size(trimmed_long_text) > 0)
     SET long_text_id = getnextlongdataseq(null)
     INSERT  FROM long_text_reference ltr
      SET ltr.long_text_id = long_text_id, ltr.active_ind = 1, ltr.long_text = trimmed_long_text,
       ltr.updt_cnt = 0, ltr.updt_dt_tm = cnvtdatetime(sysdate), ltr.updt_id = reqinfo->updt_id,
       ltr.updt_task = reqinfo->updt_task
      WITH nocounter
     ;end insert
     CALL error_and_zero_check(curqual,"INSERT_LONG_TEXT_REFERENCE","UPDATE_AP_CPT_OPTIONS",1,1)
    ENDIF
   ELSEIF (size(trimmed_long_text) > 0)
    UPDATE  FROM long_text_reference ltr
     SET ltr.active_ind = 1, ltr.long_text = trimmed_long_text, ltr.updt_cnt = (ltr.updt_cnt+ 1),
      ltr.updt_dt_tm = cnvtdatetime(sysdate), ltr.updt_id = reqinfo->updt_id, ltr.updt_task = reqinfo
      ->updt_task
     WHERE ltr.long_text_id=long_text_id
     WITH nocounter
    ;end update
    CALL error_and_zero_check(curqual,"UPDATE_LONG_TEXT_REFERENCE","UPDATE_AP_CPT_OPTIONS",1,1)
   ENDIF
   RETURN(long_text_id)
 END ;Subroutine
 SUBROUTINE (update_cf_head_foot_text(long_text_id=f8(val),long_text=vc(val),apply_all_formats=i2(val
   )) =f8)
   CALL log_message("In UPDATE_CF_HEAD_FOOT_TEXT()",log_level_debug)
   IF (size(trim(long_text)) > 0)
    SET long_text_id = getnextlongdataseq(null)
    IF (apply_all_formats)
     INSERT  FROM long_text_reference ltr
      SET ltr.long_text_id = long_text_id, ltr.active_ind = 1, ltr.parent_entity_id = 0.0,
       ltr.parent_entity_name = "CHART_FORMAT ADD ID", ltr.long_text = long_text, ltr.updt_cnt = 0,
       ltr.updt_dt_tm = cnvtdatetime(sysdate), ltr.updt_id = reqinfo->updt_id, ltr.updt_task =
       reqinfo->updt_task
      WITH nocounter
     ;end insert
    ELSE
     INSERT  FROM long_text_reference ltr
      SET ltr.long_text_id = long_text_id, ltr.active_ind = 1, ltr.parent_entity_id = request->
       chart_format_id,
       ltr.parent_entity_name = "CHART_FORMAT ADD ID", ltr.long_text = long_text, ltr.updt_cnt = 0,
       ltr.updt_dt_tm = cnvtdatetime(sysdate), ltr.updt_id = reqinfo->updt_id, ltr.updt_task =
       reqinfo->updt_task
      WITH nocounter
     ;end insert
    ENDIF
    CALL error_and_zero_check(curqual,"INSERT_LONG_TEXT_REFERENCE","UPDATE_CF_HEAD_FOOT_TEXT",1,1)
   ENDIF
   RETURN(long_text_id)
 END ;Subroutine
 SUBROUTINE (deleteadditionalinfo(clear_all_ind=i2,additionalid=f8) =null)
  CALL log_message("In DeleteAdditionalInfo()",log_level_debug)
  IF (clear_all_ind)
   DELETE  FROM long_text_reference ltr
    SET ltr.seq = 1
    WHERE (ltr.long_text_id=
    (SELECT DISTINCT
     cf.additional_info_id
     FROM chart_format cf
     WHERE cf.additional_info_id > 0.0
      AND cf.chart_format_id > 0.0))
     AND ltr.long_text_id > 0.0
     AND ltr.parent_entity_name="CHART_FORMAT ADD ID"
    WITH nocounter
   ;end delete
   CALL error_and_zero_check(curqual,"CHART_FORMAT","DeleteAdditionalInfo",1,0)
  ELSE
   DELETE  FROM long_text_reference ltr
    WHERE ltr.long_text_id=additionalid
     AND ltr.long_text_id > 0.0
     AND (ltr.parent_entity_id=request->chart_format_id)
    WITH nocounter
   ;end delete
   CALL error_and_zero_check(curqual,"CHART_FORMAT","DeleteAdditionalInfo",1,0)
  ENDIF
 END ;Subroutine
 SUBROUTINE (delete_group(grp_id=f8(val),sect_type=i4(val)) =null)
   CALL log_message("In delete_group()",log_level_debug)
   DECLARE tempid = f8 WITH noconstant(0.0), protect
   DELETE  FROM chart_grp_evnt_suppress cges
    WHERE cges.chart_group_id=grp_id
    WITH nocounter
   ;end delete
   DELETE  FROM chart_grp_evnt_set ce
    WHERE ce.chart_group_id=grp_id
    WITH nocounter
   ;end delete
   CASE (sect_type)
    OF xencntr_section_type:
     DELETE  FROM chart_xencntr_format xe
      WHERE xe.chart_group_id=grp_id
      WITH nocounter
     ;end delete
    OF flex_section_type:
     DELETE  FROM chart_flex_format cff
      WHERE cff.chart_group_id=grp_id
      WITH nocounter
     ;end delete
    OF horz_section_type:
     DELETE  FROM chart_horz_format chf
      WHERE chf.chart_group_id=grp_id
      WITH nocounter
     ;end delete
    OF mic_section_type:
     DELETE  FROM chart_micro_format cmf
      WHERE cmf.chart_group_id=grp_id
      WITH nocounter
     ;end delete
     DELETE  FROM long_text lt
      WHERE lt.parent_entity_id=grp_id
       AND lt.parent_entity_name="CHART MICRO LEGEND"
      WITH nocounter
     ;end delete
    OF ord_sum_section_type:
     DELETE  FROM chart_order_summary_format cosf
      WHERE cosf.chart_group_id=grp_id
      WITH nocounter
     ;end delete
     DELETE  FROM chart_ord_sum_filter osf
      WHERE osf.chart_group_id=grp_id
      WITH nocounter
     ;end delete
    OF rad_section_type:
     DELETE  FROM chart_rad_format crf
      WHERE crf.chart_group_id=grp_id
      WITH nocounter
     ;end delete
    OF vert_section_type:
     DELETE  FROM chart_vert_format cvf
      WHERE cvf.chart_group_id=grp_id
      WITH nocounter
     ;end delete
    OF zonal_old_section_type:
     DELETE  FROM chart_zonal_format czf
      WHERE czf.chart_group_id=grp_id
      WITH nocounter
     ;end delete
     DELETE  FROM chart_zn_form_zone czfz
      WHERE czfz.chart_group_id=grp_id
      WITH nocounter
     ;end delete
    OF ap_section_type:
     SELECT INTO "nl:"
      FROM chart_ap_format capf
      WHERE capf.chart_group_id=grp_id
      DETAIL
       tempid = capf.ap_cpt_long_text_id
      WITH nocounter
     ;end select
     DELETE  FROM chart_ap_format capf
      WHERE capf.chart_group_id=grp_id
      WITH nocounter
     ;end delete
     DELETE  FROM long_text_reference ltr
      WHERE ltr.long_text_id=tempid
      WITH nocounter
     ;end delete
    OF hla_section_type:
     DELETE  FROM chart_hla_format hla
      WHERE hla.chart_group_id=grp_id
      WITH nocounter
     ;end delete
    OF doc_section_type:
     DELETE  FROM chart_doc_format doc
      WHERE doc.chart_group_id=grp_id
      WITH nocounter
     ;end delete
    OF lab_text_section_type:
     DELETE  FROM chart_gl_format gl
      WHERE gl.chart_group_id=grp_id
      WITH nocounter
     ;end delete
    OF ppr_section_type:
     DELETE  FROM chart_ppr_format ppr
      WHERE ppr.chart_group_id=grp_id
      WITH nocounter
     ;end delete
    OF visit_list_section_type:
     DELETE  FROM chart_visitlist_format vl
      WHERE vl.chart_group_id=grp_id
      WITH nocounter
     ;end delete
    OF allergy_section_type:
     DELETE  FROM chart_allergy_format alg
      WHERE alg.chart_group_id=grp_id
      WITH nocounter
     ;end delete
    OF prob_list_section_type:
     DELETE  FROM chart_problem_format prob
      WHERE prob.chart_group_id=grp_id
      WITH nocounter
     ;end delete
    OF zonal_new_section_type:
     DELETE  FROM chart_zn_result_col_cds czrcc
      WHERE czrcc.chart_group_id=grp_id
      WITH nocounter
     ;end delete
     DELETE  FROM chart_zn_result_col czrc
      WHERE czrc.chart_group_id=grp_id
      WITH nocounter
     ;end delete
     DELETE  FROM chart_dyn_zone_form cdzf
      WHERE cdzf.chart_group_id=grp_id
      WITH nocounter
     ;end delete
     DELETE  FROM chart_zonal_format czf
      WHERE czf.chart_group_id=grp_id
      WITH nocounter
     ;end delete
    OF orders_section_type:
     DELETE  FROM chart_orders_format cof
      WHERE cof.chart_group_id=grp_id
      WITH nocounter
     ;end delete
    OF mar_section_type:
     DELETE  FROM chart_mar_format cmf
      WHERE cmf.chart_group_id=grp_id
      WITH nocounter
     ;end delete
    OF name_hist_section_type:
     DELETE  FROM chart_name_hist_format cnhf
      WHERE cnhf.chart_group_id=grp_id
      WITH nocounter
     ;end delete
    OF immun_section_type:
     DELETE  FROM chart_immuniz_format cif
      WHERE cif.chart_group_id=grp_id
      WITH nocounter
     ;end delete
    OF proc_hist_section_type:
     DELETE  FROM chart_prochist_format cpf
      WHERE cpf.chart_group_id=grp_id
      WITH nocounter
     ;end delete
    OF mar2_section_type:
     DELETE  FROM chart_mar_format cmf
      WHERE cmf.chart_group_id=grp_id
      WITH nocounter
     ;end delete
    OF io_section_type:
     SET tempid = 0.0
     SELECT INTO "nl:"
      FROM chart_generic_format cgf
      WHERE (cgf.chart_group_id=request->chart_section_list[secindex].chart_group_list[grpindex].
      chart_group_id)
      DETAIL
       tempid = cgf.param_long_text_id
      WITH nocounter
     ;end select
     DELETE  FROM chart_generic_format cgf
      WHERE cgf.chart_group_id=grp_id
      WITH nocounter
     ;end delete
     DELETE  FROM long_text_reference ltr
      WHERE ltr.long_text_id=tempid
      WITH nocounter
     ;end delete
    OF med_prof_hist_section_type:
     DELETE  FROM chart_generic_format cgf
      WHERE cgf.chart_group_id=grp_id
      WITH nocounter
     ;end delete
    OF user_defined_section_type:
     DELETE  FROM chart_generic_format cgf
      WHERE cgf.chart_group_id=grp_id
      WITH nocounter
     ;end delete
    OF listview_section_type:
     DELETE  FROM chart_listview_format clf
      WHERE clf.chart_group_id=grp_id
      WITH nocounter
     ;end delete
   ENDCASE
   DELETE  FROM chart_group cg
    WHERE cg.chart_group_id=grp_id
    WITH nocounter
   ;end delete
   CALL error_and_zero_check(curqual,"CHART_GROUP","DELETE_GROUP",1,1)
 END ;Subroutine
 SUBROUTINE (delete_section(sec_id=f8(val),sec_type=i4(val)) =null)
   CALL log_message("In delete_group()",log_level_debug)
   DECLARE grpcount = i4 WITH noconstant(0), protect
   RECORD intern_grps(
     1 chart_group_list[*]
       2 chart_group_id = f8
   )
   RECORD intern_cds(
     1 cf_code_list[*]
       2 cf_code_id = f8
   )
   SELECT INTO "nl:"
    cg.chart_group_id
    FROM chart_group cg
    PLAN (cg
     WHERE cg.chart_section_id=sec_id)
    HEAD REPORT
     do_nothing = 0
    DETAIL
     grpcount += 1
     IF (mod(grpcount,10)=1)
      stat = alterlist(intern_grps->chart_group_list,(grpcount+ 9))
     ENDIF
     intern_grps->chart_group_list[grpcount].chart_group_id = cg.chart_group_id
    FOOT REPORT
     stat = alterlist(intern_grps->chart_group_list,grpcount)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_GROUP","DELETE_SECTION",1,0)
   FOR (w = 1 TO grpcount)
     CALL delete_group(intern_grps->chart_group_list[w].chart_group_id,sec_type)
   ENDFOR
   DELETE  FROM chart_section
    WHERE chart_section_id=sec_id
    WITH noconter
   ;end delete
   CALL error_and_zero_check(curqual,"CHART_SECTION","DELETE_SECTION",1,1)
 END ;Subroutine
 SUBROUTINE insertformat(null)
   CALL log_message("In InsertFormat()",log_level_debug)
   DECLARE tempid = f8 WITH noconstant(0.0), protect
   SET tempid = update_cf_head_foot_text(0.0,request->alt_head_foot_text,request->alt_text_apply_all)
   INSERT  FROM chart_format cf
    SET cf.chart_format_id = request->chart_format_id, cf.chart_format_desc = request->
     chart_format_desc, cf.date_mask = request->date_mask,
     cf.time_mask = request->time_mask, cf.template_loc = request->template_loc, cf.abnormal_symbol
      = request->abnormal_symbol,
     cf.corrected_symbol = request->corrected_symbol, cf.critical_symbol = request->critical_symbol,
     cf.high_symbol = request->high_symbol,
     cf.interp_data_symbol = request->interp_data_symbol, cf.low_symbol = request->low_symbol, cf
     .ref_lab_symbol = request->ref_lab_symbol,
     cf.ftnotes_symbol = request->ftnotes_symbol, cf.ftnote_loc_flag = request->ftnote_loc_flag, cf
     .interp_loc_flag = request->interp_loc_flag,
     cf.ord_comment_flag = request->ord_comment_flag, cf.ref_lab_flag = request->ref_lab_flag, cf
     .prsnl_ident_flag = request->prsnl_ident_flag,
     cf.page_brk_ind = request->page_brk_ind, cf.header_page_ind = request->header_page_ind, cf
     .repaginate_off_ind = request->repaginate_off_ind,
     cf.address_page_ind = request->address_page_ind, cf.address_row_nbr = request->address_row_nbr,
     cf.address_col_nbr = request->address_col_nbr,
     cf.address_rotate_ind = request->address_rotate, cf.program_name = request->program_name, cf
     .document_name = request->document_name,
     cf.blank_page_stmt = request->blank_page_statement, cf.resubmit_disclaimer_id =
     resubmit_disclaimer_id, cf.i_doc_ftr_nbr = request->i_doc_ftr_nbr,
     cf.i_doc_hdr_nbr = request->i_doc_hdr_nbr, cf.e_doc_ftr_nbr = request->e_doc_ftr_nbr, cf
     .e_doc_hdr_nbr = request->e_doc_hdr_nbr,
     cf.left_margin_nbr = request->left_margin_nbr, cf.right_margin_nbr = request->right_margin_nbr,
     cf.suppress_na_ind = request->suppress_na_ind,
     cf.ascii_ind = request->ascii_ind, cf.preserve_interp_ind = request->preserve_interp_ind, cf
     .additional_info_id = tempid,
     cf.active_ind = 1, cf.active_status_cd = reqdata->active_status_cd, cf.active_status_dt_tm =
     cnvtdatetime(sysdate),
     cf.include_prsnl_hist_ind = request->include_prsnl_hist_ind, cf.active_status_prsnl_id = reqinfo
     ->updt_id, cf.updt_cnt = 0,
     cf.updt_dt_tm = cnvtdatetime(sysdate), cf.updt_id = reqinfo->updt_id, cf.updt_task = reqinfo->
     updt_task,
     cf.updt_applctx = reqinfo->updt_applctx, cf.unique_ident = concat(trim(cnvtstring(request->
        chart_format_id,30,0,"R"),3)," ",trim(format(curdate,"DD-MMM-YYYY;;D"),3)," ",trim(format(
        curtime3,";3;M"),3))
    WITH nocounter
   ;end insert
   CALL error_and_zero_check(curqual,"CHART_FORMAT","INSERTFORMAT",1,1)
   IF ((request->alt_text_apply_all=1))
    UPDATE  FROM chart_format cf
     SET cf.additional_info_id = tempid, cf.suppress_na_ind = - (1)
     WHERE cf.chart_format_id > 0.0
     WITH nocounter
    ;end update
    CALL error_and_zero_check(curqual,"CHART_FORMAT ADDITIONAL_INFO","INSERTFORMAT",1,0)
   ENDIF
   SET reply->chart_format_id = request->chart_format_id
 END ;Subroutine
 SUBROUTINE updateformat(null)
   CALL log_message("In UpdateFormat()",log_level_debug)
   DECLARE tempid = f8 WITH noconstant(0.0), protect
   SET tempid = update_cf_head_foot_text(0.0,request->alt_head_foot_text,request->alt_text_apply_all)
   UPDATE  FROM chart_format cf
    SET cf.chart_format_desc = request->chart_format_desc, cf.date_mask = request->date_mask, cf
     .time_mask = request->time_mask,
     cf.template_loc = request->template_loc, cf.abnormal_symbol = request->abnormal_symbol, cf
     .corrected_symbol = request->corrected_symbol,
     cf.critical_symbol = request->critical_symbol, cf.high_symbol = request->high_symbol, cf
     .interp_data_symbol = request->interp_data_symbol,
     cf.low_symbol = request->low_symbol, cf.ref_lab_symbol = request->ref_lab_symbol, cf
     .ftnotes_symbol = request->ftnotes_symbol,
     cf.ftnote_loc_flag = request->ftnote_loc_flag, cf.interp_loc_flag = request->interp_loc_flag, cf
     .ord_comment_flag = request->ord_comment_flag,
     cf.prsnl_ident_flag = request->prsnl_ident_flag, cf.ref_lab_flag = request->ref_lab_flag, cf
     .page_brk_ind = request->page_brk_ind,
     cf.program_name = request->program_name, cf.document_name = request->document_name, cf
     .header_page_ind = request->header_page_ind,
     cf.repaginate_off_ind = request->repaginate_off_ind, cf.blank_page_stmt = request->
     blank_page_statement, cf.address_page_ind = request->address_page_ind,
     cf.address_row_nbr = request->address_row_nbr, cf.address_col_nbr = request->address_col_nbr, cf
     .address_rotate_ind = request->address_rotate,
     cf.resubmit_disclaimer_id = resubmit_disclaimer_id, cf.i_doc_ftr_nbr = request->i_doc_ftr_nbr,
     cf.i_doc_hdr_nbr = request->i_doc_hdr_nbr,
     cf.e_doc_ftr_nbr = request->e_doc_ftr_nbr, cf.e_doc_hdr_nbr = request->e_doc_hdr_nbr, cf
     .left_margin_nbr = request->left_margin_nbr,
     cf.right_margin_nbr = request->right_margin_nbr, cf.suppress_na_ind = request->suppress_na_ind,
     cf.ascii_ind = request->ascii_ind,
     cf.preserve_interp_ind = request->preserve_interp_ind, cf.include_prsnl_hist_ind = request->
     include_prsnl_hist_ind, cf.additional_info_id = tempid,
     cf.active_ind = 1, cf.active_status_cd = reqdata->active_status_cd, cf.updt_cnt = (cf.updt_cnt+
     1),
     cf.updt_dt_tm = cnvtdatetime(curdate,curtime), cf.updt_id = reqinfo->updt_id, cf.updt_applctx =
     reqinfo->updt_applctx,
     cf.updt_task = reqinfo->updt_task
    WHERE (cf.chart_format_id=request->chart_format_id)
    WITH nocounter
   ;end update
   CALL error_and_zero_check(curqual,"CHART_FORMAT","UPDATEFORMAT",1,1)
   IF ((request->alt_text_apply_all=1))
    UPDATE  FROM chart_format cf
     SET cf.additional_info_id = tempid, cf.suppress_na_ind = - (1)
     WHERE cf.chart_format_id > 0.0
     WITH nocounter
    ;end update
    CALL error_and_zero_check(curqual,"CHART_FORMAT ADDITIONAL_INFO","UPDATEFORMAT",1,0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (updatechartsection(secindex=i4(val)) =null)
   CALL log_message("In UpdateChartSection()",log_level_debug)
   UPDATE  FROM chart_section cs
    SET cs.chart_section_desc = request->chart_section_list[secindex].chart_section_desc, cs
     .sect_page_brk_ind = request->chart_section_list[secindex].sect_page_brk_ind, cs.active_ind = 1,
     cs.active_status_cd = reqdata->active_status_cd, cs.updt_cnt = (cs.updt_cnt+ 1), cs.updt_dt_tm
      = cnvtdatetime(curdate,curtime),
     cs.updt_id = reqinfo->updt_id, cs.updt_applctx = reqinfo->updt_applctx, cs.updt_task = reqinfo->
     updt_task
    WHERE (cs.chart_section_id=request->chart_section_list[secindex].chart_section_id)
    WITH nocounter
   ;end update
   CALL error_and_zero_check(curqual,"CHART_SECTION","UPDATECHARTSECTION",1,1)
   IF ((((request->chart_section_list[secindex].section_type_flag=rad_section_type)) OR ((((request->
   chart_section_list[secindex].section_type_flag=ap_section_type)) OR ((((request->
   chart_section_list[secindex].section_type_flag=doc_section_type)) OR ((request->
   chart_section_list[secindex].section_type_flag=lab_text_section_type))) )) )) )
    DELETE  FROM chart_sect_flds csf
     WHERE (csf.chart_section_id=request->chart_section_list[secindex].chart_section_id)
     WITH nocounter
    ;end delete
   ENDIF
   CALL insertchartsectionfields(secindex)
 END ;Subroutine
 SUBROUTINE (updatechartgroup(secindex=i4(val),grpindex=i4(val)) =null)
   CALL log_message("In UpdateChartGroup()",log_level_debug)
   UPDATE  FROM chart_group cg
    SET cg.chart_group_desc = request->chart_section_list[secindex].chart_group_list[grpindex].
     chart_group_desc, cg.enhanced_layout_ind = request->chart_section_list[secindex].
     chart_group_list[grpindex].enhanced_layout_ind, cg.max_results = request->chart_section_list[
     secindex].chart_group_list[grpindex].max_results,
     cg.cg_sequence = grpindex, cg.active_ind = 1, cg.active_status_cd = reqdata->active_status_cd,
     cg.updt_cnt = (cg.updt_cnt+ 1), cg.updt_dt_tm = cnvtdatetime(curdate,curtime), cg.updt_id =
     reqinfo->updt_id,
     cg.updt_applctx = reqinfo->updt_applctx, cg.updt_task = reqinfo->updt_task
    WHERE (cg.chart_group_id=request->chart_section_list[secindex].chart_group_list[grpindex].
    chart_group_id)
    WITH nocounter
   ;end update
   CALL error_and_zero_check(curqual,"CHART_GROUP","UPDATECHARTGROUP",1,1)
 END ;Subroutine
 RECORD reply(
   1 chart_format_id = f8
   1 facesheet_sec_id = f8
   1 chart_section_list[*]
     2 chart_section_id = f8
     2 chart_group_list[*]
       3 chart_group_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD internal(
   1 chart_form_sects_list[*]
     2 chart_section_id = f8
     2 section_type_flag = i2
   1 chart_group_list[*]
     2 chart_group_id = f8
   1 chart_event_list[*]
     2 event_set_name = vc
     2 synonym_id = f8
     2 order_catalog_cd = f8
     2 procedure_type_flag = i2
     2 display_name = vc
     2 event_set_seq = i4
     2 zone = i4
   1 sect_field_list[*]
     2 field_id = i4
     2 field_row = i4
 )
 DECLARE d = i4 WITH noconstant(0), protect
 DECLARE i = i4 WITH noconstant(0), protect
 DECLARE j = i4 WITH noconstant(0), protect
 DECLARE k = i4 WITH noconstant(0), protect
 DECLARE m = i4 WITH noconstant(0), protect
 DECLARE x = i4 WITH noconstant(0), protect
 DECLARE y = i4 WITH noconstant(0), protect
 DECLARE z = i4 WITH noconstant(0), protect
 DECLARE evtcount = i4 WITH noconstant(0), protect
 DECLARE grpcount = i4 WITH noconstant(0), protect
 DECLARE seccount = i4 WITH noconstant(0), protect
 DECLARE secfldcount = i4 WITH noconstant(0), protect
 DECLARE temp_seq = i4 WITH noconstant(0), protect
 DECLARE req_evtcount = i4 WITH noconstant(0), protect
 DECLARE req_grpcount = i4 WITH noconstant(0), protect
 DECLARE req_seccount = i4 WITH noconstant(0), protect
 DECLARE req_secfldcount = i4 WITH noconstant(0), protect
 DECLARE tbl_evtcount = i4 WITH noconstant(0), protect
 DECLARE tbl_grpcount = i4 WITH noconstant(0), protect
 DECLARE tbl_seccount = i4 WITH noconstant(0), protect
 DECLARE num_zones = i4 WITH noconstant(0), protect
 DECLARE num_result_cols = i4 WITH noconstant(0), protect
 DECLARE num_normalcy_cds = i4 WITH noconstant(0), protect
 DECLARE cp_exists = i4 WITH noconstant(0), protect
 DECLARE update_flag = i4 WITH noconstant(0), protect
 DECLARE facesheet_add = i4 WITH noconstant(0), protect
 DECLARE facesheet_del = i4 WITH noconstant(0), protect
 DECLARE facesheet_chg = i4 WITH noconstant(0), protect
 DECLARE program_name = vc WITH noconstant("")
 DECLARE resubmit_disclaimer_id = f8 WITH noconstant(0.0), protect
 DECLARE additional_info_id = f8 WITH noconstant(0.0), protect
 DECLARE update_chart_format_ind = i2 WITH noconstant(0)
 DECLARE updateinsertenhancedlayoutxml(null) = null
 DECLARE updatechartformat(null) = null
 DECLARE checkforchangedformat(null) = null
 DECLARE updateinsertresubmitdisclaimer(null) = null
 CALL log_message("Starting script: cp_update_chart_format",log_level_debug)
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 CALL buildreplystructure(null)
 CALL updatechartformat(null)
 SET reqinfo->commit_ind = 1
 SET reply->status_data.status = "S"
 SUBROUTINE updatechartformat(null)
   CALL log_message("In UpdateChartFormat()",log_level_debug)
   DECLARE update_flag = i2 WITH noconstant(0), protect
   CALL checkforchangedformat(null)
   IF (size(request->enhanced_layout_xml) > 0)
    CALL updateinsertenhancedlayoutxml(null)
   ENDIF
   IF (size(request->resubmit_disclaimer) > 0)
    CALL updateinsertresubmitdisclaimer(null)
   ELSEIF (resubmit_disclaimer_id > 0)
    CALL deleteresubmitdisclaimer(resubmit_disclaimer_id)
    SET resubmit_disclaimer_id = 0.0
    SET update_chart_format_ind = 1
   ENDIF
   IF (size(request->alt_head_foot_text,1) > 0)
    CALL deleteadditionalinfo(request->alt_text_apply_all,additional_info_id)
    SET update_chart_format_ind = 1
   ENDIF
   SET reply->chart_format_id = request->chart_format_id
   IF (update_chart_format_ind)
    CALL updateformat(null)
   ENDIF
   FOR (i = 1 TO request->chart_section_count)
     IF ((request->chart_section_list[i].chart_section_id < 0))
      CALL insertchartsection(i)
      CALL insertchartsectionfields(i)
     ELSE
      SELECT INTO "nl:"
       FROM chart_section cs
       WHERE (cs.chart_section_id=request->chart_section_list[i].chart_section_id)
       DETAIL
        update_flag = 0
        IF ((((request->chart_section_list[i].chart_section_desc != cs.chart_section_desc)) OR ((
        request->chart_section_list[i].sect_page_brk_ind != cs.sect_page_brk_ind))) )
         update_flag = 1
        ENDIF
       WITH nocounter
      ;end select
      CALL error_and_zero_check(curqual,"CHART_SECTION","UPDATECHARTFORMAT",1,1)
      SET req_secfldcount = size(request->chart_section_list[i].sect_field_list,5)
      SELECT INTO "nl:"
       FROM chart_sect_flds csf
       WHERE (csf.chart_section_id=request->chart_section_list[i].chart_section_id)
       HEAD REPORT
        secfldcount = 0
       DETAIL
        secfldcount += 1, stat = alterlist(internal->sect_field_list,secfldcount), internal->
        sect_field_list[secfldcount].field_id = csf.field_id,
        internal->sect_field_list[secfldcount].field_row = csf.field_row
       WITH nocounter
      ;end select
      IF (secfldcount != req_secfldcount)
       SET update_flag = 1
      ELSE
       FOR (j = 1 TO secfldcount)
         IF ((((request->chart_section_list[i].sect_field_list[j].field_id != internal->
         sect_field_list[j].field_id)) OR ((request->chart_section_list[i].sect_field_list[j].
         field_row != internal->sect_field_list[j].field_row))) )
          SET update_flag = 1
         ENDIF
       ENDFOR
      ENDIF
      SET reply->chart_section_list[i].chart_section_id = request->chart_section_list[i].
      chart_section_id
      IF (update_flag=1)
       CALL updatechartsection(i)
      ENDIF
      FOR (j = 1 TO request->chart_section_list[i].chart_group_count)
        IF ((request->chart_section_list[i].chart_group_list[j].chart_group_id < 0))
         CALL insertchartgroup(i,j)
        ELSE
         SELECT INTO "nl:"
          FROM chart_group cg
          WHERE (cg.chart_group_id=request->chart_section_list[i].chart_group_list[j].chart_group_id)
          DETAIL
           update_flag = 0
           IF ((((request->chart_section_list[i].chart_group_list[j].max_results != cg.max_results))
            OR (((cg.cg_sequence != j) OR ((((request->chart_section_list[i].chart_group_list[j].
           chart_group_desc != cg.chart_group_desc)) OR ((request->chart_section_list[i].
           chart_group_list[j].enhanced_layout_ind != cg.enhanced_layout_ind))) )) )) )
            update_flag = 1
           ENDIF
          WITH nocounter
         ;end select
         CALL error_and_zero_check(curqual,"CHART_GROUP","UPDATECHARTGROUP",1,0)
         SET reply->chart_section_list[i].chart_group_list[j].chart_group_id = request->
         chart_section_list[i].chart_group_list[j].chart_group_id
         IF (update_flag=1)
          CALL updatechartgroup(i,j)
         ENDIF
         SET update_flag = 0
         CASE (request->chart_section_list[i].section_type_flag)
          OF xencntr_section_type:
           CALL checkxencntrsection(i,j)
          OF flex_section_type:
           CALL checkflexsection(i,j)
          OF horz_section_type:
           CALL checkhorzontalsection(i,j)
          OF mic_section_type:
           CALL checkmicrosection(i,j)
          OF ord_sum_section_type:
           CALL checkordersummarysection(i,j)
          OF rad_section_type:
           CALL checkradiologysection(i,j)
          OF vert_section_type:
           CALL checkverticalsection(i,j)
          OF zonal_old_section_type:
           CALL checkoldzonalsection(i,j)
          OF ap_section_type:
           CALL checkapsection(i,j)
          OF hla_section_type:
           CALL checkhlasection(i,j)
          OF doc_section_type:
           CALL checkdocsection(i,j)
          OF lab_text_section_type:
           CALL checklabtextsection(i,j)
          OF allergy_section_type:
           CALL checkallergysection(i,j)
          OF prob_list_section_type:
           CALL checkproblemlistsection(i,j)
          OF zonal_new_section_type:
           CALL checknewzonalsection(i,j)
          OF orders_section_type:
           CALL checkorderssection(i,j)
          OF mar2_section_type:
           CALL checknewmarsection(i,j)
          OF io_section_type:
           CALL checkiosection(i,j)
          OF med_prof_hist_section_type:
           CALL checkmedprofhistsection(i,j)
          OF user_defined_section_type:
           CALL checkuserdefinedsection(i,j)
          OF name_hist_section_type:
           CALL checknamehistsection(i,j)
          OF immun_section_type:
           CALL checkimmunizationsection(i,j)
          OF proc_hist_section_type:
           CALL checkprochistsection(i,j)
          OF listview_section_type:
           CALL checklistviewsection(i,j)
         ENDCASE
         SET evtcount = 0
         SELECT INTO "nl:"
          FROM chart_grp_evnt_set ce
          PLAN (ce
           WHERE (ce.chart_group_id=request->chart_section_list[i].chart_group_list[j].chart_group_id
           ))
          ORDER BY ce.event_set_seq
          DETAIL
           evtcount += 1
           IF (mod(evtcount,10)=1)
            stat = alterlist(internal->chart_event_list,(evtcount+ 9))
           ENDIF
           internal->chart_event_list[evtcount].event_set_name = ce.event_set_name, internal->
           chart_event_list[evtcount].synonym_id = ce.synonym_id, internal->chart_event_list[evtcount
           ].order_catalog_cd = ce.order_catalog_cd,
           internal->chart_event_list[evtcount].procedure_type_flag = ce.procedure_type_flag,
           internal->chart_event_list[evtcount].event_set_seq = ce.event_set_seq, internal->
           chart_event_list[evtcount].display_name = ce.display_name,
           internal->chart_event_list[evtcount].zone = ce.zone
          WITH nocounter
         ;end select
         SET stat = alterlist(internal->chart_event_list,evtcount)
         FOR (k = 1 TO request->chart_section_list[i].chart_group_list[j].chart_event_count)
           SET cp_exists = 0
           SET z = 1
           WHILE (cp_exists != 1
            AND z <= evtcount)
             IF ((request->chart_section_list[i].chart_group_list[j].chart_event_list[k].
             procedure_type_flag=0))
              IF ((internal->chart_event_list[z].procedure_type_flag=0)
               AND (request->chart_section_list[i].chart_group_list[j].chart_event_list[k].
              event_set_name=internal->chart_event_list[z].event_set_name))
               SET cp_exists = 1
              ELSE
               SET z += 1
              ENDIF
             ELSE
              IF ((internal->chart_event_list[z].procedure_type_flag=1)
               AND (request->chart_section_list[i].chart_group_list[j].chart_event_list[k].
              order_catalog_cd=internal->chart_event_list[z].order_catalog_cd))
               SET cp_exists = 1
              ELSE
               SET z += 1
              ENDIF
             ENDIF
           ENDWHILE
           IF (cp_exists != 1)
            CALL insertevent(i,j,k)
           ELSE
            DELETE  FROM chart_grp_evnt_suppress cges
             WHERE (cges.chart_group_id=request->chart_section_list[i].chart_group_list[j].
             chart_group_id)
              AND (cges.event_set_name=request->chart_section_list[i].chart_group_list[j].
             chart_event_list[k].event_set_name)
              AND (cges.order_catalog_cd=request->chart_section_list[i].chart_group_list[j].
             chart_event_list[k].order_catalog_cd)
             WITH nocounter
            ;end delete
            FOR (m = 1 TO size(request->chart_section_list[i].chart_group_list[j].chart_event_list[k]
             .suppressed_cd_list,5))
              CALL insertsuppressedcode(i,j,k,m)
            ENDFOR
            IF ((internal->chart_event_list[z].event_set_seq != k))
             CALL update_event(i,j,k)
            ELSEIF ((internal->chart_event_list[z].procedure_type_flag != request->
            chart_section_list[i].chart_group_list[j].chart_event_list[k].procedure_type_flag))
             CALL update_event(i,j,k)
            ELSEIF ((internal->chart_event_list[z].display_name != request->chart_section_list[i].
            chart_group_list[j].chart_event_list[k].display_name))
             CALL update_event(i,j,k)
            ELSEIF ((internal->chart_event_list[z].synonym_id != request->chart_section_list[i].
            chart_group_list[j].chart_event_list[k].synonym_id))
             CALL update_event(i,j,k)
            ELSEIF ((internal->chart_event_list[z].zone != request->chart_section_list[i].
            chart_group_list[j].chart_event_list[k].zone))
             CALL update_event(i,j,k)
            ENDIF
           ENDIF
         ENDFOR
         SET evtcount = 0
         SELECT INTO "nl:"
          FROM chart_grp_evnt_set ce
          PLAN (ce
           WHERE (ce.chart_group_id=request->chart_section_list[i].chart_group_list[j].chart_group_id
           ))
          ORDER BY ce.event_set_seq
          DETAIL
           evtcount += 1
           IF (mod(evtcount,10)=1)
            stat = alterlist(internal->chart_event_list,(evtcount+ 9))
           ENDIF
           internal->chart_event_list[evtcount].event_set_name = ce.event_set_name, internal->
           chart_event_list[evtcount].order_catalog_cd = ce.order_catalog_cd
          WITH nocounter
         ;end select
         SET stat = alterlist(internal->chart_event_list,evtcount)
         SET req_evtcount = request->chart_section_list[i].chart_group_list[j].chart_event_count
         SET tbl_evtcount = evtcount
         SET x = 1
         SET y = 1
         WHILE (x <= req_evtcount
          AND y <= tbl_evtcount)
           IF ((request->chart_section_list[i].chart_group_list[j].chart_event_list[x].
           procedure_type_flag=0))
            IF ((request->chart_section_list[i].chart_group_list[j].chart_event_list[x].
            event_set_name != internal->chart_event_list[y].event_set_name))
             DELETE  FROM chart_grp_evnt_suppress cges
              WHERE (cges.chart_group_id=request->chart_section_list[i].chart_group_list[j].
              chart_group_id)
               AND (cges.event_set_name=internal->chart_event_list[y].event_set_name)
              WITH nocounter
             ;end delete
             DELETE  FROM chart_grp_evnt_set ce
              WHERE (ce.chart_group_id=request->chart_section_list[i].chart_group_list[j].
              chart_group_id)
               AND (ce.event_set_name=internal->chart_event_list[y].event_set_name)
              WITH nocounter
             ;end delete
             SET y += 1
            ELSE
             SET x += 1
             SET y += 1
            ENDIF
           ELSE
            IF ((request->chart_section_list[i].chart_group_list[j].chart_event_list[x].
            order_catalog_cd != internal->chart_event_list[y].order_catalog_cd))
             DELETE  FROM chart_grp_evnt_suppress cges
              WHERE (cges.chart_group_id=request->chart_section_list[i].chart_group_list[j].
              chart_group_id)
               AND (cges.order_catalog_cd=internal->chart_event_list[y].order_catalog_cd)
              WITH nocounter
             ;end delete
             DELETE  FROM chart_grp_evnt_set ce
              WHERE (ce.chart_group_id=request->chart_section_list[i].chart_group_list[j].
              chart_group_id)
               AND (ce.order_catalog_cd=internal->chart_event_list[y].order_catalog_cd)
              WITH nocounter
             ;end delete
             SET y += 1
            ELSE
             SET x += 1
             SET y += 1
            ENDIF
           ENDIF
         ENDWHILE
         IF ((request->chart_section_list[i].chart_group_list[j].chart_event_count=0))
          DELETE  FROM chart_grp_evnt_suppress cges
           WHERE (cges.chart_group_id=request->chart_section_list[i].chart_group_list[j].
           chart_group_id)
           WITH nocounter
          ;end delete
          DELETE  FROM chart_grp_evnt_set ce
           WHERE (ce.chart_group_id=request->chart_section_list[i].chart_group_list[j].chart_group_id
           )
           WITH nocounter
          ;end delete
         ELSE
          SET evtcount = 0
          SELECT INTO "nl:"
           FROM chart_grp_evnt_set ce
           WHERE (((ce.event_set_name != request->chart_section_list[i].chart_group_list[j].
           chart_event_list[req_evtcount].event_set_name)
            AND (ce.chart_group_id=request->chart_section_list[i].chart_group_list[j].chart_group_id)
            AND ce.event_set_seq >= req_evtcount) OR ((ce.order_catalog_cd != request->
           chart_section_list[i].chart_group_list[j].chart_event_list[req_evtcount].order_catalog_cd)
            AND (ce.chart_group_id=request->chart_section_list[i].chart_group_list[j].chart_group_id)
            AND ce.event_set_seq >= req_evtcount))
           DETAIL
            evtcount += 1
            IF (mod(evtcount,10)=1)
             stat = alterlist(internal->chart_event_list,(evtcount+ 9))
            ENDIF
            internal->chart_event_list[evtcount].event_set_name = ce.event_set_name, internal->
            chart_event_list[evtcount].order_catalog_cd = ce.order_catalog_cd
           WITH nocounter
          ;end select
          SET stat = alterlist(internal->chart_event_list,evtcount)
          FOR (d = 1 TO evtcount)
           DELETE  FROM chart_grp_evnt_suppress cges
            WHERE (cges.chart_group_id=request->chart_section_list[i].chart_group_list[j].
            chart_group_id)
             AND (cges.event_set_name=internal->chart_event_list[d].event_set_name)
             AND (cges.order_catalog_cd=internal->chart_event_list[d].order_catalog_cd)
            WITH nocounter
           ;end delete
           DELETE  FROM chart_grp_evnt_set cges
            WHERE (cges.chart_group_id=request->chart_section_list[i].chart_group_list[j].
            chart_group_id)
             AND (cges.event_set_name=internal->chart_event_list[d].event_set_name)
             AND (cges.order_catalog_cd=internal->chart_event_list[d].order_catalog_cd)
            WITH nocounter
           ;end delete
          ENDFOR
         ENDIF
        ENDIF
      ENDFOR
      SET grpcount = 0
      SELECT INTO "nl:"
       FROM chart_group cg
       PLAN (cg
        WHERE (cg.chart_section_id=request->chart_section_list[i].chart_section_id))
       ORDER BY cg.cg_sequence
       DETAIL
        grpcount += 1
        IF (mod(grpcount,10)=1)
         stat = alterlist(internal->chart_group_list,(grpcount+ 9))
        ENDIF
        internal->chart_group_list[grpcount].chart_group_id = cg.chart_group_id
       WITH nocounter
      ;end select
      SET stat = alterlist(internal->chart_group_list,grpcount)
      SET req_grpcount = request->chart_section_list[i].chart_group_count
      SET tbl_grpcount = grpcount
      SET x = 1
      SET y = 1
      WHILE (x <= req_grpcount
       AND y <= tbl_grpcount)
        IF ((request->chart_section_list[i].chart_group_list[x].chart_group_id != internal->
        chart_group_list[y].chart_group_id))
         CALL delete_group(internal->chart_group_list[y].chart_group_id,request->chart_section_list[i
          ].section_type_flag)
         SET y += 1
        ELSE
         SET x += 1
         SET y += 1
        ENDIF
      ENDWHILE
      WHILE (y <= tbl_grpcount)
       CALL delete_group(internal->chart_group_list[y].chart_group_id,request->chart_section_list[i].
        section_type_flag)
       SET y += 1
      ENDWHILE
     ENDIF
   ENDFOR
   DELETE  FROM chart_form_sects cfs
    WHERE (cfs.chart_format_id=request->chart_format_id)
    WITH nocounter
   ;end delete
   FOR (x = 1 TO request->chart_section_count)
     CALL insertchartformsects(x)
   ENDFOR
   IF (facesheet_add=1)
    CALL add_facesheet_section(null)
   ELSEIF (facesheet_del=1)
    CALL delete_facesheet_section(null)
   ELSEIF (facesheet_chg=1)
    CALL update_facesheet_section(null)
   ENDIF
 END ;Subroutine
 SUBROUTINE checkforchangedformat(null)
   CALL log_message("In CheckForChangedFormat()",log_level_debug)
   SELECT INTO "nl:"
    cf.*
    FROM chart_format cf
    WHERE (cf.chart_format_id=request->chart_format_id)
    DETAIL
     program_name = cf.program_name, resubmit_disclaimer_id = cf.resubmit_disclaimer_id,
     additional_info_id = cf.additional_info_id
     IF ((((request->chart_format_desc != cf.chart_format_desc)) OR ((((request->date_mask != cf
     .date_mask)) OR ((((request->time_mask != cf.time_mask)) OR ((((request->template_loc != cf
     .template_loc)) OR ((((request->abnormal_symbol != cf.abnormal_symbol)) OR ((((request->
     corrected_symbol != cf.corrected_symbol)) OR ((((request->critical_symbol != cf.critical_symbol)
     ) OR ((((request->high_symbol != cf.high_symbol)) OR ((((request->interp_data_symbol != cf
     .interp_data_symbol)) OR ((((request->low_symbol != cf.low_symbol)) OR ((((request->
     ref_lab_symbol != cf.ref_lab_symbol)) OR ((((request->ftnotes_symbol != cf.ftnotes_symbol)) OR (
     (((request->ftnote_loc_flag != cf.ftnote_loc_flag)) OR ((((request->interp_loc_flag != cf
     .interp_loc_flag)) OR ((((request->ord_comment_flag != cf.ord_comment_flag)) OR ((((request->
     prsnl_ident_flag != cf.prsnl_ident_flag)) OR ((((request->ref_lab_flag != cf.ref_lab_flag)) OR (
     (((request->program_name != cf.program_name)) OR ((((request->document_name != cf.document_name)
     ) OR ((((request->blank_page_statement != cf.blank_page_stmt)) OR ((((request->header_page_ind
      != cf.header_page_ind)) OR ((((request->repaginate_off_ind != cf.repaginate_off_ind)) OR ((((
     request->address_page_ind != cf.address_page_ind)) OR ((((request->address_row_nbr != cf
     .address_row_nbr)) OR ((((request->address_col_nbr != cf.address_col_nbr)) OR ((((request->
     address_rotate != cf.address_rotate_ind)) OR ((((request->page_brk_ind != cf.page_brk_ind)) OR (
     (((request->i_doc_ftr_nbr != cf.i_doc_ftr_nbr)) OR ((((request->i_doc_hdr_nbr != cf
     .i_doc_hdr_nbr)) OR ((((request->e_doc_ftr_nbr != cf.e_doc_ftr_nbr)) OR ((((request->
     e_doc_hdr_nbr != cf.e_doc_hdr_nbr)) OR ((((request->left_margin_nbr != cf.left_margin_nbr)) OR (
     (((request->right_margin_nbr != cf.right_margin_nbr)) OR ((((request->suppress_na_ind != cf
     .suppress_na_ind)) OR ((((request->ascii_ind != cf.ascii_ind)) OR ((((request->
     include_prsnl_hist_ind != cf.include_prsnl_hist_ind)) OR ((request->preserve_interp_ind != cf
     .preserve_interp_ind))) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
     )) )) )) )) )) )) )) )) )) )) )) )
      update_chart_format_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_FORMAT","CHECKFORCHANGEDFORMAT",1,1)
   IF ((request->program_name != program_name)
    AND trim(program_name)=null)
    SET facesheet_add = 1
   ELSEIF ((request->program_name != program_name)
    AND trim(request->program_name)=null)
    SET facesheet_del = 1
   ELSEIF ((request->program_name != null))
    SET facesheet_chg = 1
   ENDIF
 END ;Subroutine
 SUBROUTINE updateinsertenhancedlayoutxml(null)
   CALL log_message("In UpdateInsertEnhancedLayoutXML()",log_level_debug)
   SELECT INTO "nl:"
    FROM long_text_reference ltr
    WHERE (ltr.parent_entity_id=request->chart_format_id)
     AND ltr.parent_entity_name="ChartFormatEnhancedLayoutXML"
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"long_text_reference","UpdateInsertEnhancedLayoutXML",1,0)
   IF (curqual=0)
    CALL insertenhancedlayoutxml(null)
   ELSE
    CALL updateenhancedlayoutxml(null)
   ENDIF
 END ;Subroutine
 SUBROUTINE updateinsertresubmitdisclaimer(null)
  CALL log_message("In UpdateInsertResubmitDisclaimer()",log_level_debug)
  IF (resubmit_disclaimer_id=0.0)
   SET resubmit_disclaimer_id = insertresubmitdisclaimer(null)
   SET update_chart_format_ind = 1
  ELSE
   CALL updateresubmitdisclaimer(resubmit_disclaimer_id)
  ENDIF
 END ;Subroutine
#exit_script
 CALL log_message("Exiting script: cp_update_chart_format",log_level_debug)
END GO
