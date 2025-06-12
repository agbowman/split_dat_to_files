CREATE PROGRAM cp_get_mrp_chart_formats:dba
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
 SET log_program_name = "CP_GET_MRP_CHART_FORMATS"
 RECORD reply(
   1 user_position_cd = f8
   1 format_qual[*]
     2 chart_format_id = f8
     2 chart_format_name = c64
     2 section_qual[*]
       3 chart_section_id = f8
       3 chart_section_name = c64
       3 category_qual[*]
         4 category_sect_reltn_id = f8
         4 category_id = f8
         4 category_name = c50
         4 category_seq = i4
         4 parent_category_id = f8
         4 expandable_doc_ind = i2
         4 sensitive_ind = i2
       3 position_qual[*]
         4 position_cd = f8
         4 position_name = c50
   1 positions[*]
     2 positioncode = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE getpositioncodes(null) = i2
 DECLARE getformatsbyorg(null) = null
 DECLARE getallformats(null) = null
 DECLARE getsectionpositionrelation(null) = null
 FREE RECORD flat_rec
 RECORD flat_rec(
   1 list_qual = i4
   1 list[*]
     2 chart_section_id = f8
     2 format_idx = i4
     2 section_idx = i4
 )
 DECLARE x = i2 WITH public, noconstant(0)
 DECLARE y = i2 WITH public, noconstant(0)
 DECLARE z = i2 WITH public, noconstant(0)
 DECLARE qual_size = i2 WITH public, noconstant(0)
 DECLARE org_size = i2 WITH public, noconstant(0)
 DECLARE idx = i4
 DECLARE idxstart = i4 WITH noconstant(1)
 DECLARE noptimizedtotal = i4
 DECLARE nrecordsize = i4
 DECLARE bind_cnt = i4 WITH constant(50)
 DECLARE get_position_codes_falied = i2 WITH constant(0), protect
 DECLARE get_position_codes_successful = i2 WITH constant(1), protect
 SET reply->status_data.status = "F"
 CALL log_message("Starting script: cp_get_mrp_chart_formats",log_level_debug)
 SET org_size = size(request->qual,5)
 IF (org_size > 0)
  CALL getformatsbyorg(null)
 ELSE
  CALL getallformats(null)
 ENDIF
 CALL getsectionpositionrelation(null)
 CALL getpositioncodes(null)
 SET reply->status_data.status = "S"
 SUBROUTINE getformatsbyorg(null)
   CALL log_message("In GetFormatsByOrg()",log_level_debug)
   SET org_size = size(request->qual,5)
   SET nrecordsize = org_size
   SET noptimizedtotal = (ceil((cnvtreal(nrecordsize)/ bind_cnt)) * bind_cnt)
   SET stat = alterlist(request->qual,noptimizedtotal)
   FOR (i = (nrecordsize+ 1) TO noptimizedtotal)
     SET request->qual[i].organization_id = request->qual[nrecordsize].organization_id
   ENDFOR
   SELECT INTO "nl:"
    cf.chart_format_id, cs.chart_section_id
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     format_org_reltn f,
     chart_format cf,
     chart_form_sects cfs,
     chart_section cs,
     category_sect_reltn csr,
     chart_category cc
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (f
     WHERE expand(idx,idxstart,((idxstart+ bind_cnt) - 1),f.organization_id,request->qual[idx].
      organization_id,
      bind_cnt)
      AND f.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND f.end_effective_dt_tm > cnvtdatetime(sysdate)
      AND f.active_ind=1)
     JOIN (cf
     WHERE cf.chart_format_id=f.chart_format_id
      AND cf.active_ind=1)
     JOIN (cfs
     WHERE cfs.chart_format_id=cf.chart_format_id
      AND cfs.active_ind=1)
     JOIN (cs
     WHERE cs.chart_section_id=cfs.chart_section_id
      AND cs.active_ind=1)
     JOIN (csr
     WHERE (csr.chart_section_id= Outerjoin(cs.chart_section_id))
      AND (csr.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(sysdate)))
      AND (csr.end_effective_dt_tm>= Outerjoin(cnvtdatetime(sysdate)))
      AND (csr.active_ind= Outerjoin(1)) )
     JOIN (cc
     WHERE (cc.chart_category_id= Outerjoin(csr.chart_category_id)) )
    ORDER BY cf.chart_format_id, cs.chart_section_id
    HEAD REPORT
     x = 0
    HEAD cf.chart_format_id
     y = 0, x += 1
     IF (x > size(reply->format_qual,5))
      stat = alterlist(reply->format_qual,(x+ 9))
     ENDIF
     reply->format_qual[x].chart_format_id = cf.chart_format_id, reply->format_qual[x].
     chart_format_name = cf.chart_format_desc
    HEAD cs.chart_section_id
     y += 1
     IF (y > size(reply->format_qual[x].section_qual,5))
      stat = alterlist(reply->format_qual[x].section_qual,(y+ 9))
     ENDIF
     reply->format_qual[x].section_qual[y].chart_section_id = cs.chart_section_id, reply->
     format_qual[x].section_qual[y].chart_section_name = cs.chart_section_desc, flat_rec->list_qual
      += 1
     IF (mod(flat_rec->list_qual,bind_cnt)=1)
      stat = alterlist(flat_rec->list,((flat_rec->list_qual+ bind_cnt) - 1))
     ENDIF
     flat_rec->list[flat_rec->list_qual].chart_section_id = cs.chart_section_id, flat_rec->list[
     flat_rec->list_qual].format_idx = x, flat_rec->list[flat_rec->list_qual].section_idx = y,
     z1 = 0
    DETAIL
     IF (csr.chart_section_id=cs.chart_section_id
      AND csr.chart_format_id=cf.chart_format_id)
      z1 += 1
      IF (z1 > size(reply->format_qual[x].section_qual[y].category_qual,5))
       stat = alterlist(reply->format_qual[x].section_qual[y].category_qual,(z1+ 9))
      ENDIF
      reply->format_qual[x].section_qual[y].category_qual[z1].category_sect_reltn_id = csr
      .category_sect_reltn_id, reply->format_qual[x].section_qual[y].category_qual[z1].category_id =
      csr.chart_category_id, reply->format_qual[x].section_qual[y].category_qual[z1].category_name =
      cc.category_name,
      reply->format_qual[x].section_qual[y].category_qual[z1].category_seq = cc.category_seq, reply->
      format_qual[x].section_qual[y].category_qual[z1].parent_category_id = cc.parent_category_id,
      reply->format_qual[x].section_qual[y].category_qual[z1].expandable_doc_ind = cc
      .expandable_doc_ind,
      reply->format_qual[x].section_qual[y].category_qual[z1].sensitive_ind = cc.sensitive_ind
     ENDIF
    FOOT  cs.chart_section_id
     stat = alterlist(reply->format_qual[x].section_qual[y].category_qual,z1)
    FOOT  cf.chart_format_id
     stat = alterlist(reply->format_qual[x].section_qual,y)
    FOOT REPORT
     stat = alterlist(reply->format_qual,x)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_CATEGORY","GETFORMATSBYORG",1,0)
 END ;Subroutine
 SUBROUTINE getallformats(null)
   CALL log_message("In GetAllFormats()",log_level_debug)
   SELECT INTO "nl:"
    cf.chart_format_id, cs.chart_section_id
    FROM chart_format cf,
     chart_form_sects cfs,
     chart_section cs,
     category_sect_reltn csr,
     chart_category cc
    PLAN (cf
     WHERE cf.active_ind=1)
     JOIN (cfs
     WHERE cfs.chart_format_id=cf.chart_format_id
      AND cfs.active_ind=1)
     JOIN (cs
     WHERE cs.chart_section_id=cfs.chart_section_id
      AND cs.active_ind=1)
     JOIN (csr
     WHERE (csr.chart_section_id= Outerjoin(cs.chart_section_id))
      AND (csr.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(sysdate)))
      AND (csr.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate)))
      AND (csr.active_ind= Outerjoin(1)) )
     JOIN (cc
     WHERE (cc.chart_category_id= Outerjoin(csr.chart_category_id)) )
    ORDER BY cf.chart_format_id, cs.chart_section_id
    HEAD REPORT
     x = 0
    HEAD cf.chart_format_id
     y = 0, x += 1
     IF (x > size(reply->format_qual,5))
      stat = alterlist(reply->format_qual,(x+ 9))
     ENDIF
     reply->format_qual[x].chart_format_id = cf.chart_format_id, reply->format_qual[x].
     chart_format_name = cf.chart_format_desc
    HEAD cs.chart_section_id
     y += 1
     IF (y > size(reply->format_qual[x].section_qual,5))
      stat = alterlist(reply->format_qual[x].section_qual,(y+ 9))
     ENDIF
     reply->format_qual[x].section_qual[y].chart_section_id = cs.chart_section_id, reply->
     format_qual[x].section_qual[y].chart_section_name = cs.chart_section_desc, flat_rec->list_qual
      += 1
     IF (mod(flat_rec->list_qual,bind_cnt)=1)
      stat = alterlist(flat_rec->list,((flat_rec->list_qual+ bind_cnt) - 1))
     ENDIF
     flat_rec->list[flat_rec->list_qual].chart_section_id = cs.chart_section_id, flat_rec->list[
     flat_rec->list_qual].format_idx = x, flat_rec->list[flat_rec->list_qual].section_idx = y,
     z1 = 0
    DETAIL
     IF (csr.chart_section_id=cs.chart_section_id
      AND csr.chart_format_id=cf.chart_format_id)
      z1 += 1
      IF (z1 > size(reply->format_qual[x].section_qual[y].category_qual,5))
       stat = alterlist(reply->format_qual[x].section_qual[y].category_qual,(z1+ 9))
      ENDIF
      reply->format_qual[x].section_qual[y].category_qual[z1].category_sect_reltn_id = csr
      .category_sect_reltn_id, reply->format_qual[x].section_qual[y].category_qual[z1].category_id =
      csr.chart_category_id, reply->format_qual[x].section_qual[y].category_qual[z1].category_name =
      cc.category_name,
      reply->format_qual[x].section_qual[y].category_qual[z1].category_seq = cc.category_seq, reply->
      format_qual[x].section_qual[y].category_qual[z1].parent_category_id = cc.parent_category_id,
      reply->format_qual[x].section_qual[y].category_qual[z1].expandable_doc_ind = cc
      .expandable_doc_ind,
      reply->format_qual[x].section_qual[y].category_qual[z1].sensitive_ind = cc.sensitive_ind
     ENDIF
    FOOT  cs.chart_section_id
     stat = alterlist(reply->format_qual[x].section_qual[y].category_qual,z1)
    FOOT  cf.chart_format_id
     stat = alterlist(reply->format_qual[x].section_qual,y)
    FOOT REPORT
     stat = alterlist(reply->format_qual,x)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_CATEGORY","GETALLFORMATS",1,0)
 END ;Subroutine
 SUBROUTINE getsectionpositionrelation(null)
   CALL log_message("In GetSectionPositionRelation()",log_level_debug)
   SET nrecordsize = flat_rec->list_qual
   SET noptimizedtotal = size(flat_rec->list,5)
   FOR (i = (nrecordsize+ 1) TO noptimizedtotal)
     SET flat_rec->list[i].chart_section_id = flat_rec->list[nrecordsize].chart_section_id
   ENDFOR
   SELECT INTO "nl:"
    locval = locateval(idx,1,nrecordsize,s.chart_section_id,flat_rec->list[idx].chart_section_id)
    FROM sect_position_reltn s,
     (dummyt d  WITH seq = (1+ ((noptimizedtotal - 1)/ bind_cnt)))
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (s
     WHERE expand(idx,idxstart,((idxstart+ bind_cnt) - 1),s.chart_section_id,flat_rec->list[idx].
      chart_section_id,
      bind_cnt)
      AND s.active_ind=1)
    ORDER BY locval
    HEAD REPORT
     z = 0
    DETAIL
     x = flat_rec->list[locval].format_idx, y = flat_rec->list[locval].section_idx, z = (size(reply->
      format_qual[x].section_qual[y].position_qual,5)+ 1),
     stat = alterlist(reply->format_qual[x].section_qual[y].position_qual,z), reply->format_qual[x].
     section_qual[y].position_qual[z].position_cd = s.position_cd, reply->format_qual[x].
     section_qual[y].position_qual[z].position_name = uar_get_code_display(s.position_cd)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"SECT_POSITION_RELTN","TABLE",1,0)
 END ;Subroutine
 SUBROUTINE getpositioncodes(null)
   CALL log_message("GetPositionCodes()",log_level_debug)
   DECLARE x = i4 WITH noconstant(0), protect
   DECLARE position_size = i4 WITH noconstant(0), protect
   RECORD sac_pos(
     1 positions[*]
       2 positioncode = f8
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   DECLARE mode_nhs = i2 WITH protect, constant(1)
   DECLARE error_code = i4 WITH protect, noconstant(0)
   DECLARE error_message = vc WITH protect, noconstant("")
   DECLARE login_type = i4 WITH protect, noconstant(- (1))
   EXECUTE secrtl
   CALL uar_secgetclientlogontype(login_type)
   IF (login_type != mode_nhs)
    SELECT INTO "nl:"
     FROM prsnl p
     WHERE (p.person_id=reqinfo->updt_id)
     DETAIL
      stat = alterlist(sac_pos->positions,1), sac_pos->positions[1].positioncode = p.position_cd
     WITH nocounter
    ;end select
   ELSE
    DECLARE attr_originator_role = i2 WITH protect, constant(5)
    DECLARE sec_status_ok = i2 WITH protect, constant(0)
    DECLARE property_handle = i4 WITH protect, noconstant(0)
    DECLARE status = i2 WITH protect, noconstant(0)
    DECLARE property_name = vc WITH protect, noconstant("")
    DECLARE role_profile_id = vc WITH protect, noconstant("")
    SET property_handle = uar_srvcreateproperty()
    SET status = uar_secgetclientattributesext(attr_originator_role,property_handle)
    IF (status=sec_status_ok)
     SET property_name = uar_srvfirstproperty(property_handle)
     IF (size(property_name)=0)
      SET sac_pos->status_data.status = "F"
      SET sac_pos->status_data.subeventstatus.targetobjectvalue = "Failure loading role property"
     ELSE
      SET role_profile_id = uar_srvgetpropertyptr(property_handle,nullterm(property_name))
      IF (size(role_profile_id)=0)
       SET sac_pos->status_data.status = "F"
       SET sac_pos->status_data.subeventstatus.targetobjectvalue = "Failure getting role profile ID"
      ELSE
       SELECT INTO "nl:"
        FROM prsnl_org_reltn_type prt
        WHERE prt.role_profile=trim(role_profile_id)
         AND prt.active_ind=1
         AND prt.beg_effective_dt_tm <= cnvtdatetime(sysdate)
         AND prt.end_effective_dt_tm > cnvtdatetime(sysdate)
        ORDER BY prt.updt_dt_tm DESC
        HEAD prt.role_profile
         stat = alterlist(sac_pos->positions,1), sac_pos->positions[1].positioncode = prt
         .access_position_cd
        WITH nocounter
       ;end select
      ENDIF
     ENDIF
    ELSE
     SET sac_pos->status_data.status = "F"
     SET sac_pos->status_data.subeventstatus.targetobjectvalue = concat(
      "Failure getting user role; status code: ",cnvtstring(status))
    ENDIF
    CALL uar_srvdestroyhandle(property_handle)
   ENDIF
   SET error_code = error(error_message,0)
   IF (error_code > 0)
    SET sac_pos->status_data.status = "F"
    SET sac_pos->status_data.subeventstatus.operationname = "Select"
    SET sac_pos->status_data.subeventstatus.operationstatus = "F"
    IF (login_type=mode_nhs)
     SET sac_pos->status_data.subeventstatus.targetobjectname = "PRSNL_ORG_RELTN_TYPE"
    ELSE
     SET sac_pos->status_data.subeventstatus.targetobjectname = "PRSNL"
    ENDIF
    SET sac_pos->status_data.subeventstatus.targetobjectvalue = error_message
   ELSEIF ((sac_pos->status_data.status != "F"))
    IF (curqual=1)
     SET sac_pos->status_data.status = "S"
    ELSE
     SET sac_pos->status_data.status = "Z"
    ENDIF
   ENDIF
   SET position_size = size(sac_pos->positions,5)
   SET stat = alterlist(reply->positions,position_size)
   FOR (x = 1 TO position_size)
     SET reply->positions[x].positioncode = sac_pos->positions[x].positioncode
   ENDFOR
 END ;Subroutine
#exit_script
 CALL log_message("End of script: cp_get_mrp_chart_formats",log_level_debug)
END GO
