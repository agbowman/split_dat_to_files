CREATE PROGRAM cp_load_chart_formats:dba
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
 SET log_program_name = "CP_LOAD_CHART_FORMATS"
 RECORD reply(
   1 qual[*]
     2 chart_format_id = f8
     2 chart_format_desc = vc
     2 template_loc = vc
     2 abnormal_symbol = vc
     2 corrected_symbol = vc
     2 critical_symbol = vc
     2 high_symbol = vc
     2 interp_data_symbol = vc
     2 low_symbol = vc
     2 new_result_symbol = vc
     2 ref_lab_symbol = vc
     2 review_symbol = vc
     2 sex_age_change_symbol = vc
     2 stat_symbol = vc
     2 ftnotes_symbol = vc
     2 date_mask = vc
     2 time_mask = vc
     2 program_name = vc
     2 document_name = vc
     2 facesheet_sec_id = f8
     2 ftnote_loc_flag = i2
     2 interp_loc_flag = i2
     2 ord_comment_flag = i2
     2 ref_lab_flag = i2
     2 prsnl_ident_flag = i2
     2 page_brk_ind = i2
     2 header_page_ind = i2
     2 repaginate_off_ind = i2
     2 address_page_ind = i2
     2 address_row_nbr = i4
     2 address_col_nbr = i4
     2 address_rotate = i2
     2 blank_page_statement = vc
     2 resubmit_disclaimer = vc
     2 all_sects_have_pgbrks = i2
     2 i_doc_ftr_nbr = i4
     2 i_doc_hdr_nbr = i4
     2 e_doc_ftr_nbr = i4
     2 e_doc_hdr_nbr = i4
     2 left_margin_nbr = i4
     2 right_margin_nbr = i4
     2 chart_section_list[*]
       3 chart_section_id = f8
       3 cs_sequence_num = i4
     2 cf_mm_field_list[*]
       3 cdf_meaning = vc
       3 name = vc
     2 suppress_na_ind = i2
     2 ascii_ind = i2
     2 cf_mm_image_field_list[*]
       3 image_cdf = vc
       3 image_cd = f8
       3 image_disp = c40
       3 image_desc = c60
       3 image_mean = c12
       3 location_ind = i2
     2 preserve_interp_ind = i2
     2 alt_head_foot_text = vc
     2 enhanced_layout_xml = vc
     2 include_prsnl_hist_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE seccount = i4 WITH noconstant(0)
 DECLARE all_sects_have_pgbrks = i2 WITH noconstant(1)
 DECLARE mmcount = i4 WITH noconstant(0)
 DECLARE mmimgcount = i4 WITH noconstant(0)
 DECLARE long_text_id = f8 WITH noconstant(0.0)
 DECLARE facesheet_type = i4 WITH constant(36)
 DECLARE bind_cnt = i4 WITH constant(50)
 DECLARE loadchartformat(null) = null
 DECLARE loadextendedchartformatinformation(null) = null
 CALL log_message("Entering cp_load_chart_formats script",log_level_debug)
 SET reply->status_data.status = "F"
 CALL preparerequestforexpand(null)
 IF ((request->load_base_ind=1)
  AND (request->load_section_ind=0))
  CALL loadbasechartformatinformation(null)
 ELSE
  CALL loadextendedchartformatinformation(null)
 ENDIF
 SET reply->status_data.status = "S"
 SUBROUTINE preparerequestforexpand(null)
   CALL log_message("In PrepareRequestForExpand()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE noptimizedtotal = i4
   DECLARE nrecordsize = i4
   SET nrecordsize = size(request->qual,5)
   SET noptimizedtotal = (ceil((cnvtreal(nrecordsize)/ bind_cnt)) * bind_cnt)
   SET stat = alterlist(request->qual,noptimizedtotal)
   FOR (i = (nrecordsize+ 1) TO noptimizedtotal)
     SET request->qual[i].chart_format_id = request->qual[nrecordsize].chart_format_id
   ENDFOR
   CALL log_message(build("Exit PrepareRequestForExpand(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE loadbasechartformatinformation(null)
   CALL log_message("In LoadBaseChartFormatInformation()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE idx = i4
   DECLARE idxstart = i4 WITH noconstant(1)
   DECLARE noptimizedtotal = i4 WITH constant(size(request->qual,5))
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     chart_format cf
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (cf
     WHERE expand(idx,idxstart,((idxstart+ bind_cnt) - 1),cf.chart_format_id,request->qual[idx].
      chart_format_id,
      bind_cnt)
      AND cf.chart_format_id > 0)
    HEAD REPORT
     x = 0
    DETAIL
     x += 1
     IF (x > size(reply->qual,5))
      stat = alterlist(reply->qual,(x+ 9))
     ENDIF
     reply->qual[x].chart_format_id = cf.chart_format_id, reply->qual[x].chart_format_desc = cf
     .chart_format_desc
    FOOT REPORT
     stat = alterlist(reply->qual,x)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"LoadBaseChartFormatInformation",
    "An error occured when reading from chart_format table.  Exiting script.",1,1)
   CALL log_message(build("Exit LoadBaseChartFormatInformation(), Elapsed time in seconds:",
     datetimediff(cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE loadextendedchartformatinformation(null)
   CALL log_message("In LoadExtendedChartFormatInformation()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE idx = i4 WITH noconstant(0), protect
   DECLARE idxstart = i4 WITH noconstant(1), protect
   DECLARE noptimizedtotal = i4 WITH constant(size(request->qual,5)), private
   FREE RECORD resubmit_rec
   RECORD resubmit_rec(
     1 rec_cnt = i4
     1 qual[*]
       2 chart_format_id = f8
       2 long_text_id = f8
   )
   SELECT INTO "nl:"
    cf.chart_format_id, cfs.chart_section_id, cfs_exists_yn = decode(cfs.seq,"Y","N"),
    cs.sect_page_brk_ind
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     chart_format cf,
     chart_form_sects cfs,
     chart_section cs,
     long_text_reference ltr
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (cf
     WHERE expand(idx,idxstart,((idxstart+ bind_cnt) - 1),cf.chart_format_id,request->qual[idx].
      chart_format_id,
      bind_cnt)
      AND cf.chart_format_id > 0)
     JOIN (cfs
     WHERE (cfs.chart_format_id= Outerjoin(cf.chart_format_id)) )
     JOIN (cs
     WHERE (cs.chart_section_id= Outerjoin(cfs.chart_section_id)) )
     JOIN (ltr
     WHERE ltr.long_text_id=cf.additional_info_id)
    ORDER BY cf.chart_format_id, cfs.cs_sequence_num
    HEAD REPORT
     x = 0
    HEAD cf.chart_format_id
     seccount = 0, x += 1
     IF (x > size(reply->qual,5))
      stat = alterlist(reply->qual,(x+ 9))
     ENDIF
     seccount = 0, reply->qual[x].chart_format_id = cf.chart_format_id, reply->qual[x].
     chart_format_desc = cf.chart_format_desc,
     reply->qual[x].template_loc = cf.template_loc, reply->qual[x].abnormal_symbol = cf
     .abnormal_symbol, reply->qual[x].corrected_symbol = cf.corrected_symbol,
     reply->qual[x].critical_symbol = cf.critical_symbol, reply->qual[x].high_symbol = cf.high_symbol,
     reply->qual[x].interp_data_symbol = cf.interp_data_symbol,
     reply->qual[x].low_symbol = cf.low_symbol, reply->qual[x].new_result_symbol = cf
     .new_result_symbol, reply->qual[x].ref_lab_symbol = cf.ref_lab_symbol,
     reply->qual[x].review_symbol = cf.review_symbol, reply->qual[x].sex_age_change_symbol = cf
     .sex_age_change_symbol, reply->qual[x].stat_symbol = cf.stat_symbol,
     reply->qual[x].ftnotes_symbol = cf.ftnotes_symbol, reply->qual[x].date_mask = cf.date_mask,
     reply->qual[x].time_mask = cf.time_mask,
     reply->qual[x].ftnote_loc_flag = cf.ftnote_loc_flag, reply->qual[x].interp_loc_flag = cf
     .interp_loc_flag, reply->qual[x].ord_comment_flag = cf.ord_comment_flag,
     reply->qual[x].ref_lab_flag = cf.ref_lab_flag, reply->qual[x].prsnl_ident_flag = cf
     .prsnl_ident_flag, reply->qual[x].page_brk_ind = cf.page_brk_ind,
     reply->qual[x].program_name = cf.program_name, reply->qual[x].document_name = cf.document_name,
     reply->qual[x].header_page_ind = cf.header_page_ind,
     reply->qual[x].repaginate_off_ind = cf.repaginate_off_ind, reply->qual[x].blank_page_statement
      = cf.blank_page_stmt, reply->qual[x].address_page_ind = cf.address_page_ind,
     reply->qual[x].address_row_nbr = cf.address_row_nbr, reply->qual[x].address_col_nbr = cf
     .address_col_nbr, reply->qual[x].address_rotate = cf.address_rotate_ind,
     reply->qual[x].i_doc_ftr_nbr = cf.i_doc_ftr_nbr, reply->qual[x].i_doc_hdr_nbr = cf.i_doc_hdr_nbr,
     reply->qual[x].e_doc_ftr_nbr = cf.e_doc_ftr_nbr,
     reply->qual[x].e_doc_hdr_nbr = cf.e_doc_hdr_nbr, reply->qual[x].left_margin_nbr = cf
     .left_margin_nbr, reply->qual[x].right_margin_nbr = cf.right_margin_nbr,
     reply->qual[x].suppress_na_ind = cf.suppress_na_ind, reply->qual[x].ascii_ind = cf.ascii_ind,
     reply->qual[x].preserve_interp_ind = cf.preserve_interp_ind,
     reply->qual[x].include_prsnl_hist_ind = cf.include_prsnl_hist_ind
     IF (ltr.long_text_id > 0.0)
      reply->qual[x].alt_head_foot_text = ltr.long_text
     ENDIF
     IF (cf.resubmit_disclaimer_id > 0)
      resubmit_rec->rec_cnt += 1, stat = alterlist(resubmit_rec->qual,resubmit_rec->rec_cnt),
      resubmit_rec->qual[resubmit_rec->rec_cnt].chart_format_id = cf.chart_format_id,
      resubmit_rec->qual[resubmit_rec->rec_cnt].long_text_id = cf.resubmit_disclaimer_id
     ENDIF
    DETAIL
     IF (cfs_exists_yn="Y")
      IF (cs.section_type_flag=facesheet_type)
       reply->qual[x].facesheet_sec_id = cfs.chart_section_id
      ELSE
       seccount += 1
       IF (mod(seccount,10)=1)
        stat = alterlist(reply->qual[x].chart_section_list,(seccount+ 9))
       ENDIF
       IF (all_sects_have_pgbrks=1
        AND cs.sect_page_brk_ind=0)
        all_sects_have_pgbrks = 0
       ENDIF
       reply->qual[x].chart_section_list[seccount].chart_section_id = cfs.chart_section_id, reply->
       qual[x].chart_section_list[seccount].cs_sequence_num = cfs.cs_sequence_num
      ENDIF
     ENDIF
     reply->qual[x].all_sects_have_pgbrks = all_sects_have_pgbrks
    FOOT  cf.chart_format_id
     stat = alterlist(reply->qual[x].chart_section_list,seccount)
    FOOT REPORT
     stat = alterlist(reply->qual,x)
    WITH nocounter, memsort
   ;end select
   CALL error_and_zero_check(curqual,"LoadExtendedChartFormatInformation",
    "An error occured when reading from chart_format table.  Exiting script.",1,1)
   CALL log_message(build("Exit LoadExtendedChartFormatInformation(), Elapsed time in seconds:",
     datetimediff(cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
   CALL loadenhancedlayoutxml(null)
   CALL loadchartformatmailmergefields(null)
   CALL loadimagemailmergefields(null)
   IF (size(resubmit_rec->qual,5) > 0)
    CALL loadresubmitdisclaimer(null)
   ENDIF
 END ;Subroutine
 SUBROUTINE loadchartformatmailmergefields(null)
   CALL log_message("In LoadChartFormatMailMergeFields()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE idx = i4 WITH noconstant(0), protect
   DECLARE idx2 = i4 WITH noconstant(0), protect
   DECLARE idxstart = i4 WITH noconstant(1), protect
   DECLARE noptimizedtotal = i4 WITH constant(size(request->qual,5)), private
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     chart_form_mm_flds cfm
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (cfm
     WHERE expand(idx,idxstart,((idxstart+ bind_cnt) - 1),cfm.chart_format_id,request->qual[idx].
      chart_format_id,
      bind_cnt)
      AND cfm.chart_format_id > 0)
    ORDER BY cfm.chart_format_id, cfm.field_seq
    HEAD cfm.chart_format_id
     cf_loc = locateval(idx2,1,size(reply->qual,5),cfm.chart_format_id,reply->qual[idx2].
      chart_format_id), mmcount = 0
    HEAD cfm.field_seq
     donothing = 0
    DETAIL
     IF (cf_loc > 0)
      mmcount += 1
      IF (mod(mmcount,10)=1)
       stat = alterlist(reply->qual[cf_loc].cf_mm_field_list,(mmcount+ 9))
      ENDIF
      reply->qual[cf_loc].cf_mm_field_list[mmcount].cdf_meaning = cfm.cdf_meaning, reply->qual[cf_loc
      ].cf_mm_field_list[mmcount].name = cfm.field_desc
     ENDIF
    FOOT  cfm.field_seq
     donothing = 0
    FOOT  cfm.chart_format_id
     stat = alterlist(reply->qual[cf_loc].cf_mm_field_list,mmcount)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"LoadChartFormatMailMergeFields",
    "An error occured when reading from chart_form_mm_flds table.  Exiting script.",1,0)
   CALL log_message(build("Exit LoadChartFormatMailMergeFields(), Elapsed time in seconds:",
     datetimediff(cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE loadimagemailmergefields(null)
   CALL log_message("In LoadImageMailMergeFields()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE idx = i4 WITH noconstant(0), protect
   DECLARE idx2 = i4 WITH noconstant(0), protect
   DECLARE idxstart = i4 WITH noconstant(1), protect
   DECLARE noptimizedtotal = i4 WITH constant(size(request->qual,5)), private
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     chart_image_mm_flds cfm
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (cfm
     WHERE expand(idx,idxstart,((idxstart+ bind_cnt) - 1),cfm.chart_format_id,request->qual[idx].
      chart_format_id,
      bind_cnt)
      AND cfm.chart_format_id > 0)
    ORDER BY cfm.chart_format_id, cfm.field_seq
    HEAD cfm.chart_format_id
     cf_loc = locateval(idx2,1,size(reply->qual,5),cfm.chart_format_id,reply->qual[idx2].
      chart_format_id), mmimgcount = 0
    HEAD cfm.field_seq
     donothing = 0
    DETAIL
     IF (cf_loc > 0)
      mmimgcount += 1
      IF (mod(mmimgcount,10)=1)
       stat = alterlist(reply->qual[cf_loc].cf_mm_image_field_list,(mmimgcount+ 9))
      ENDIF
      reply->qual[cf_loc].cf_mm_image_field_list[mmimgcount].image_cdf = cfm.cdf_meaning, reply->
      qual[cf_loc].cf_mm_image_field_list[mmimgcount].image_cd = uar_get_code_by("MEANING",14005,
       nullterm(reply->qual[cf_loc].cf_mm_image_field_list[mmimgcount].image_cdf)), reply->qual[
      cf_loc].cf_mm_image_field_list[mmimgcount].location_ind = cfm.location_ind
     ENDIF
    FOOT  cfm.field_seq
     donothing = 0
    FOOT  cfm.chart_format_id
     stat = alterlist(reply->qual[cf_loc].cf_mm_image_field_list,mmimgcount)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"LoadImageMailMergeFields",
    "An error occured when reading from chart_image_mm_flds table.  Exiting script.",1,0)
   CALL log_message(build("Exit LoadImageMailMergeFields(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE loadresubmitdisclaimer(null)
   CALL log_message("In LoadResubmitDisclaimer()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE idx = i4 WITH noconstant(0), protect
   DECLARE idx2 = i4 WITH noconstant(0), protect
   DECLARE idxstart = i4 WITH noconstant(1), protect
   DECLARE noptimizedtotal = i4 WITH noconstant(0), protect
   DECLARE nrecordsize = i4 WITH noconstant(0), protect
   SET nrecordsize = resubmit_rec->rec_cnt
   SET noptimizedtotal = (ceil((cnvtreal(nrecordsize)/ bind_cnt)) * bind_cnt)
   SET stat = alterlist(resubmit_rec->qual,noptimizedtotal)
   FOR (i = (nrecordsize+ 1) TO noptimizedtotal)
    SET resubmit_rec->qual[i].long_text_id = resubmit_rec->qual[nrecordsize].long_text_id
    SET resubmit_rec->qual[i].chart_format_id = resubmit_rec->qual[nrecordsize].chart_format_id
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     long_text lt
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (lt
     WHERE expand(idx,idxstart,((idxstart+ bind_cnt) - 1),lt.long_text_id,resubmit_rec->qual[idx].
      long_text_id,
      lt.parent_entity_id,resubmit_rec->qual[idx].chart_format_id,bind_cnt)
      AND lt.long_text_id > 0)
    DETAIL
     cf_loc = locateval(idx2,1,size(reply->qual,5),lt.parent_entity_id,reply->qual[idx2].
      chart_format_id)
     IF (cf_loc > 0)
      reply->qual[cf_loc].resubmit_disclaimer = lt.long_text
     ENDIF
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"LoadResubmitDisclaimer",
    "An error occured when reading from long_text_reference table.  Exiting script.",1,0)
   CALL log_message(build("Exit LoadResubmitDisclaimer(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE loadenhancedlayoutxml(null)
   CALL log_message("In LoadEnhancedLayoutXML()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE idx = i4 WITH noconstant(0), protect
   DECLARE idx2 = i4 WITH noconstant(0), protect
   DECLARE idxstart = i4 WITH noconstant(1), protect
   DECLARE noptimizedtotal = i4 WITH constant(size(request->qual,5)), private
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     long_text_reference ltr
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (ltr
     WHERE expand(idx,idxstart,((idxstart+ bind_cnt) - 1),ltr.parent_entity_id,request->qual[idx].
      chart_format_id,
      bind_cnt)
      AND ltr.parent_entity_name="ChartFormatEnhancedLayoutXML")
    ORDER BY ltr.updt_dt_tm
    DETAIL
     cf_loc = locateval(idx2,1,size(reply->qual,5),ltr.parent_entity_id,reply->qual[idx2].
      chart_format_id)
     IF (cf_loc > 0)
      reply->qual[cf_loc].enhanced_layout_xml = ltr.long_text
     ENDIF
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"LoadEnhancedLayoutXML",
    "An error occured when reading from long_text table.  Exiting script.",1,0)
   CALL log_message(build("Exit LoadEnhancedLayoutXML(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
#exit_script
 CALL log_message("Exiting cp_load_chart_formats script",log_level_debug)
END GO
