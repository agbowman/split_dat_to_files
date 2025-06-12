CREATE PROGRAM dcp_get_user_organizations:dba
 DECLARE checkorgsecurity(null) = null
 DECLARE checkmultitenancy(null) = null
 DECLARE getallorganizations(null) = null
 DECLARE getuserorganizations(null) = null
 DECLARE s_msgbox_disp = vc WITH protect, noconstant("")
 DECLARE curdatetime = q8 WITH public, constant(cnvtdatetime(sysdate))
 IF (validate(ukr_error_subroutines) != 0)
  GO TO ukr_error_subroutines_exit
 ENDIF
 DECLARE ukr_error_subroutines = i2 WITH public, constant(1)
 DECLARE max_errors = i4 WITH public, constant(25)
 DECLARE failure = c1 WITH public, constant("F")
 DECLARE no_data = c1 WITH public, constant("Z")
 DECLARE warning = c1 WITH public, constant("W")
 DECLARE success = c1 WITH public, constant("S")
 DECLARE partial = c1 WITH public, constant("P")
 DECLARE error_mode = c1 WITH public, constant("E")
 DECLARE reply_mode = c1 WITH public, constant("R")
 DECLARE error_storage_mode = c1 WITH public, noconstant(error_mode)
 DECLARE log_program_name = vc WITH protect, noconstant("")
 DECLARE log_override_ind = i2 WITH protect, noconstant(0)
 SET log_program_name = curprog
 SET log_override_ind = 0
 DECLARE log_level_error = i2 WITH protect, noconstant(0)
 DECLARE log_level_warning = i2 WITH protect, noconstant(1)
 DECLARE log_level_audit = i2 WITH protect, noconstant(2)
 DECLARE log_level_info = i2 WITH protect, noconstant(3)
 DECLARE log_level_debug = i2 WITH protect, noconstant(4)
 DECLARE clearerrorstructure() = null
 DECLARE serrmsg = c132 WITH protect, noconstant(" ")
 DECLARE ierrcode = i4 WITH protect, noconstant(error(serrmsg,1))
 DECLARE msg_default = i4 WITH protect, noconstant(0)
 DECLARE msg_level = i4 WITH protect, noconstant(0)
 EXECUTE msgrtl
 SET msg_default = uar_msgopen("UKDISCERNREPORTING")
 SET msg_level = uar_msggetlevel(msg_default)
 DECLARE iloglvloverrideind = i2 WITH protect, noconstant(0)
 DECLARE slogtext = vc WITH protect, noconstant("")
 DECLARE slogevent = vc WITH protect, noconstant("")
 DECLARE iholdloglevel = i2 WITH protect, noconstant(0)
 DECLARE icrslerroroccured = i2 WITH protect, noconstant(0)
 DECLARE lcrsluarmsgwritestat = i4 WITH protect, noconstant(0)
 DECLARE info_domain = vc WITH protect, constant("UKDISCERNREPORTING SCRIPT LOGGING")
 DECLARE logging_on = c1 WITH protect, constant("L")
 DECLARE debug_ind = i2 WITH public, noconstant(0)
 DECLARE sysstat = i4 WITH protect, noconstant(0)
 DECLARE serrmsg = c132 WITH protect, noconstant(" ")
 DECLARE subeventcnt = i4 WITH protect, noconstant(0)
 DECLARE iloggingstat = i2 WITH protect, noconstant(0)
 DECLARE subeventsize = i4 WITH protect, noconstant(0)
 DECLARE icrslerroroccured = i2 WITH protect, noconstant(0)
 DECLARE lcrsluarmsgwritestat = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM dm_info dm
  PLAN (dm
   WHERE dm.info_domain=info_domain
    AND dm.info_name=curprog)
  DETAIL
   IF (dm.info_char=logging_on)
    log_override_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 FREE RECORD errors
 RECORD errors(
   1 error_ind = i2
   1 error_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE ms_err_msg = vc WITH private, noconstant("")
 SET stat = error(ms_err_msg,1)
 FREE SET ms_err_msg
 SUBROUTINE (checkerror(s_status=c1,s_op_name=vc,s_op_status=c1,s_target_obj_name=vc) =i2)
   DECLARE s_err_msg = vc WITH private, noconstant("")
   DECLARE l_err_code = i4 WITH private, noconstant(0)
   DECLARE l_err_cnt = i4 WITH private, noconstant(0)
   SET l_err_code = error(s_err_msg,0)
   WHILE (l_err_code > 0
    AND l_err_cnt < max_errors)
     SET errors->error_ind = 1
     SET l_err_cnt += 1
     CALL adderrormsg(s_status,s_op_name,s_op_status,s_target_obj_name,s_err_msg)
     CALL log_message(s_err_msg,log_level_audit)
     SET l_err_code = error(s_err_msg,0)
   ENDWHILE
   RETURN(errors->error_ind)
 END ;Subroutine
 SUBROUTINE (seterrorstoragemode(s_error_storage_mode=c1) =i2)
  IF (s_error_storage_mode=error_mode)
   SET error_storage_mode = s_error_storage_mode
  ELSEIF (s_error_storage_mode=reply_mode
   AND validate(reply)=1)
   SET error_storage_mode = s_error_storage_mode
   SET reply->status_data.status = failure
  ELSE
   RETURN(0)
  ENDIF
  RETURN(1)
 END ;Subroutine
 SUBROUTINE (adderrormsg(s_status=c1,s_op_name=vc,s_op_status=c1,s_target_obj_name=vc,
  s_target_obj_value=vc) =null)
   SET errors->error_cnt += 1
   SET s_status = cnvtupper(trim(substring(1,1,s_status),3))
   SET s_op_status = cnvtupper(trim(substring(1,1,s_op_status),3))
   IF (error_storage_mode=reply_mode)
    IF ((reply->status_data.status=failure))
     SET errors->error_ind = 1
    ENDIF
    IF (((s_status=failure) OR (s_op_status=failure)) )
     SET msg = concat("SCRIPT FAILURE - ",trim(s_target_obj_value,3))
     CALL echo(msg)
     CALL log_message(msg,log_level_audit)
    ENDIF
    IF (size(reply->status_data.subeventstatus,5) < max_errors)
     SET stat = alter(reply->status_data.subeventstatus,max_errors)
    ENDIF
    IF ((errors->error_cnt <= max_errors))
     SET reply->status_data.subeventstatus[errors->error_cnt].operationname = trim(substring(1,25,
       s_op_name),3)
     SET reply->status_data.subeventstatus[errors->error_cnt].operationstatus = s_op_status
     SET reply->status_data.subeventstatus[errors->error_cnt].targetobjectname = trim(substring(1,25,
       s_target_obj_name),3)
     SET reply->status_data.subeventstatus[errors->error_cnt].targetobjectvalue = trim(
      s_target_obj_value,3)
    ENDIF
   ELSE
    IF (textlen(s_status) > 0
     AND (errors->status_data.status != failure))
     SET errors->status_data.status = s_status
    ENDIF
    IF ((errors->status_data.status=failure))
     SET errors->error_ind = 1
    ENDIF
    IF (((s_status=failure) OR (s_op_status=failure)) )
     SET msg = concat("SCRIPT FAILURE - ",trim(s_target_obj_value,3))
     CALL echo(msg)
     CALL log_message(msg,log_level_audit)
    ENDIF
    IF (size(errors->status_data.subeventstatus,5) < max_errors)
     SET stat = alter(errors->status_data.subeventstatus,max_errors)
    ENDIF
    IF ((errors->error_cnt <= max_errors))
     SET errors->status_data.subeventstatus[errors->error_cnt].operationname = trim(substring(1,25,
       s_op_name),3)
     SET errors->status_data.subeventstatus[errors->error_cnt].operationstatus = s_op_status
     SET errors->status_data.subeventstatus[errors->error_cnt].targetobjectname = trim(substring(1,25,
       s_target_obj_name),3)
     SET errors->status_data.subeventstatus[errors->error_cnt].targetobjectvalue = trim(
      s_target_obj_value,3)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (showerrors(s_output=vc) =null)
  DECLARE s_output_dest = vc WITH protect, noconstant(cnvtupper(trim(s_output,3)))
  IF ((errors->error_cnt > 0))
   IF (error_storage_mode=reply_mode)
    SET stat = alter(reply->status_data.subeventstatus,errors->error_cnt)
    IF (((textlen(s_output_dest)=0) OR (s_output_dest="MINE")) )
     SET s_output_dest = "NOFORMS"
    ENDIF
    IF (s_output_dest="NOFORMS")
     CALL echo("")
    ENDIF
    SELECT INTO value(s_output_dest)
     operation_name = evaluate(d.seq,1,"ERROR LOG",reply->status_data.subeventstatus[(d.seq - 1)].
      operationname), target_object_name = evaluate(d.seq,1,"ERROR LOG",reply->status_data.
      subeventstatus[(d.seq - 1)].targetobjectname), status = evaluate(d.seq,1,reply->status_data.
      status,reply->status_data.subeventstatus[(d.seq - 1)].operationstatus),
     error_message = trim(substring(1,100,evaluate(d.seq,1,concat("SCRIPT ERROR LOG FOR: ",trim(
          curprog,3)),reply->status_data.subeventstatus[(d.seq - 1)].targetobjectvalue)))
     FROM (dummyt d  WITH seq = value((errors->error_cnt+ 1)))
     PLAN (d)
     WITH nocounter, format, separator = " "
    ;end select
   ELSE
    SET stat = alter(errors->status_data.subeventstatus,errors->error_cnt)
    IF (((textlen(s_output_dest)=0) OR (s_output_dest="MINE")) )
     SET s_output_dest = "NOFORMS"
    ENDIF
    IF (s_output_dest="NOFORMS")
     CALL echo("")
    ENDIF
    SELECT INTO value(s_output_dest)
     operation_name = evaluate(d.seq,1,"ERROR LOG",errors->status_data.subeventstatus[(d.seq - 1)].
      operationname), target_object_name = evaluate(d.seq,1,"ERROR LOG",errors->status_data.
      subeventstatus[(d.seq - 1)].targetobjectname), status = evaluate(d.seq,1,errors->status_data.
      status,errors->status_data.subeventstatus[(d.seq - 1)].operationstatus),
     error_message = trim(substring(1,100,evaluate(d.seq,1,concat("SCRIPT ERROR LOG FOR: ",trim(
          curprog,3)),errors->status_data.subeventstatus[(d.seq - 1)].targetobjectvalue)))
     FROM (dummyt d  WITH seq = value((errors->error_cnt+ 1)))
     PLAN (d)
     WITH nocounter, format, separator = " "
    ;end select
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE checkstatusblock(i_expected_cnt,i_results_cnt)
  IF ((errors->error_ind=1))
   CALL checkerror(failure,"CCL_ERROR",failure,"FINAL ERROR CHECK")
  ENDIF
  IF ((errors->error_ind=1))
   SET reply->status_data.status = failure
  ELSE
   CASE (i_results_cnt)
    OF i_expected_cnt:
     SET reply->status_data.status = success
    OF 0:
     SET reply->status_data.status = no_data
    ELSE
     SET reply->status_data.status = partial
   ENDCASE
  ENDIF
 END ;Subroutine
 SUBROUTINE (log_message(logmsg=vc,loglvl=i4) =null)
   SET iloglvloverrideind = 0
   SET slogtext = ""
   SET slogevent = ""
   SET slogtext = concat("{{Script::",value(log_program_name),"}} ",logmsg)
   IF (log_override_ind=0)
    SET iholdloglevel = loglvl
   ELSE
    IF (msg_level < loglvl)
     SET iholdloglevel = msg_level
     SET iloglvloverrideind = 1
    ELSE
     SET iholdloglevel = loglvl
    ENDIF
   ENDIF
   IF (iloglvloverrideind=1)
    SET slogevent = "Script_Override"
   ELSE
    CASE (iholdloglevel)
     OF log_level_error:
      SET slogevent = "Script_Error"
     OF log_level_warning:
      SET slogevent = "Script_Warning"
     OF log_level_audit:
      SET slogevent = "Script_Audit"
     OF log_level_info:
      SET slogevent = "Script_Info"
     OF log_level_debug:
      SET slogevent = "Script_Debug"
    ENDCASE
   ENDIF
   SET lcrsluarmsgwritestat = uar_msgwrite(msg_default,0,nullterm(slogevent),iholdloglevel,nullterm(
     slogtext))
   IF (debug_ind=1)
    CALL echo(logmsg)
   ENDIF
 END ;Subroutine
 SUBROUTINE clearerrorstructure(null)
   SET errors->error_ind = 0
   SET errors->error_cnt = 0
   SET errors->status_data.status = ""
   SET errors->status_data.subeventstatus[1].operationname = ""
   SET errors->status_data.subeventstatus[1].operationstatus = ""
   SET errors->status_data.subeventstatus[1].targetobjectname = ""
   SET errors->status_data.subeventstatus[1].targetobjectvalue = ""
 END ;Subroutine
 SUBROUTINE (error_and_zero_check(qualnum=i4,opname=vc,logname=vc,errorforceexit=i2,zeroforceexit=i2
  ) =i2)
   SET icrslerroroccured = 0
   SET ierrcode = error(serrmsg,0)
   WHILE (ierrcode > 0)
     SET icrslerroroccured = 1
     CALL log_message(serrmsg,log_level_audit)
     CALL adderrormsg(failure,opname,failure,"CCL ERROR",serrmsg)
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
    CALL populate_subeventstatus(opname,"Z","No records qualified",logname)
    GO TO exit_script
   ENDIF
   RETURN(icrslerroroccured)
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value)) =i2)
   IF (validate(reply->status_data.status,"-1") != "-1")
    SET subeventcnt = size(reply->status_data.subeventstatus,5)
    SET subeventsize = size(trim(reply->status_data.subeventstatus[subeventcnt].operationname))
    SET subeventsize += size(trim(reply->status_data.subeventstatus[subeventcnt].operationstatus))
    SET subeventsize += size(trim(reply->status_data.subeventstatus[subeventcnt].targetobjectname))
    SET subeventsize += size(trim(reply->status_data.subeventstatus[subeventcnt].targetobjectvalue))
    IF (subeventsize > 0)
     SET subeventcnt += 1
     SET iloggingstat = alter(reply->status_data.subeventstatus,subeventcnt)
    ENDIF
    SET reply->status_data.subeventstatus[subeventcnt].operationname = substring(1,25,operationname)
    SET reply->status_data.subeventstatus[subeventcnt].operationstatus = substring(1,1,
     operationstatus)
    SET reply->status_data.subeventstatus[subeventcnt].targetobjectname = substring(1,25,
     targetobjectname)
    SET reply->status_data.subeventstatus[subeventcnt].targetobjectvalue = targetobjectvalue
   ENDIF
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus_msg(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value),loglevel=i2(value)) =i2)
  CALL populate_subeventstatus(operationname,operationstatus,targetobjectname,targetobjectvalue)
  CALL log_message(targetobjectvalue,loglevel)
 END ;Subroutine
 SUBROUTINE (validationfailuremsg(s_output=vc,logmsg=vc,loglvl=vc) =null)
   CALL log_message(logmsg,loglvl)
   DECLARE s_output_dest = vc WITH protect, noconstant(cnvtupper(trim(s_output,3)))
   IF (((textlen(s_output_dest)=0) OR (s_output_dest="MINE")) )
    SET s_output_dest = "NOFORMS"
   ENDIF
   SELECT INTO value(s_output_dest)
    FROM (dummyt d  WITH seq = 1)
    PLAN (d)
    DETAIL
     row + 1, logmsg
    WITH nocounter, format, separator = " ",
     maxcol = 200
   ;end select
   GO TO exit_script
 END ;Subroutine
#ukr_error_subroutines_exit
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET replace_error = 6
 SET delete_error = 7
 SET undelete_error = 8
 SET remove_error = 9
 SET attribute_error = 10
 SET lock_error = 11
 SET none_found = 12
 SET select_error = 13
 SET updt_cnt_error = 14
 SET obj_id_index_error = 15
 SET code_value_error = 16
 SET failed = false
 SET mm_table_name = fillstring(100," ")
 DECLARE debugl1_ind = i2 WITH protect, noconstant(0)
 DECLARE debugl2_ind = i2 WITH protect, noconstant(0)
 DECLARE tableexists(stable=vc) = i2 WITH protect
 IF (validate(debug_on,0))
  IF (debug_on=2)
   SET debugl1_ind = 1
   SET debugl2_ind = 1
  ELSEIF (debug_on=1)
   SET debugl1_ind = 1
   SET debugl2_ind = 0
  ELSE
   SET debugl1_ind = 0
   SET debugl2_ind = 0
  ENDIF
 ENDIF
 SUBROUTINE (tableexists(stablename=vc) =i2)
   DECLARE btableexists = i2 WITH noconstant(false)
   IF (size(trim(stablename,3)))
    SELECT INTO "nl:"
     t.table_name
     FROM dtable t
     WHERE t.table_name=stablename
     DETAIL
      btableexists = true
     WITH nocounter
    ;end select
   ENDIF
   RETURN(btableexists)
 END ;Subroutine
 SUBROUTINE (columnexistsontable(stable=vc,scolumn=vc) =i4 WITH protect)
   DECLARE ce_flag = i4 WITH protect, noconstant(0)
   DECLARE ce_temp = vc WITH protect, noconstant("")
   SET stable = cnvtupper(trim(stable,3))
   SET scolumn = cnvtupper(trim(scolumn,3))
   IF (((currev=8
    AND currevminor=2
    AND currevminor2 >= 4) OR (((currev=8
    AND currevminor > 2) OR (currev > 8)) )) )
    SET ce_temp = build('"',stable,".",scolumn,'"')
    SET stat = checkdic(parser(ce_temp),"A",0)
    IF (stat > 0)
     SET ce_flag = 1
    ENDIF
   ELSE
    SELECT INTO "nl:"
     l.attr_name
     FROM dtableattr a,
      dtableattrl l
     WHERE a.table_name=stable
      AND l.attr_name=scolumn
      AND l.structtype="F"
      AND btest(l.stat,11)=0
     DETAIL
      ce_flag = 1
     WITH nocounter
    ;end select
   ENDIF
   RETURN(ce_flag)
 END ;Subroutine
 SUBROUTINE (debugstringecho(sstring=vc) =null WITH protect)
   IF (debugl1_ind=1)
    CALL echo(sstring)
   ENDIF
 END ;Subroutine
 SUBROUTINE (debugrecordecho(orec=vc(ref)) =null WITH protect)
   IF (debugl1_ind=1)
    CALL echorecord(orec)
   ENDIF
 END ;Subroutine
 SUBROUTINE (debugstringfileecho(sstring=vc,sfilename=vc,nmode=i2) =null WITH protect)
   DECLARE stimestamp = vc WITH protect, noconstant("")
   DECLARE squery = vc WITH protect, noconstant("")
   IF (((debugl2_ind != 1) OR (((sstring="") OR (textlen(trim(sfilename,3))=0)) )) )
    IF (debugl2_ind=1)
     IF (sstring="")
      CALL debugstringecho("debugStringFileEcho() cannot continue. No string to echo into file.")
     ELSEIF (textlen(trim(sfilename,3))=0)
      CALL debugstringecho("debugStringFileEcho() cannot continue. No file to write to.")
     ENDIF
    ENDIF
   ELSE
    SET stimestamp = format(curdate,"mm-dd-yy;;d")
    SET stimestamp = concat(stimestamp," ",format(curtime3,"hh:mm:ss;;m"))
    SET squery = concat("select into '",trim(sfilename,3),"'")
    SET squery = concat(squery," detail col 0 '",stimestamp,"'")
    SET squery = concat(squery," col 19 '",sstring,"'")
    SET squery = concat(squery," with nocounter, noformfeed, noheading, maxrow = 1")
    IF (nmode=1)
     SET squery = concat(squery,", append")
    ENDIF
    SET squery = concat(squery," go")
    CALL parser(squery)
   ENDIF
 END ;Subroutine
 SUBROUTINE (writeloninfo(reqnumber=i4,mmlogical_domainid=f8,appid=i4,taskid=i4,mminfoname=vc) =i4
  WITH protect)
   EXECUTE crmrtl
   EXECUTE srvrtl
   DECLARE happ = i4 WITH private, noconstant(0)
   DECLARE htask = i4 WITH private, noconstant(0)
   DECLARE hstep = i4 WITH private, noconstant(0)
   DECLARE hreq = i4 WITH private, noconstant(0)
   DECLARE crmstat = i2 WITH private, noconstant(0)
   SET crmstat = uar_crmbeginapp(appid,happ)
   IF (crmstat != 0)
    SET errorstr = build("CrmBeginApp(",appid,") stat:",crmstat)
    CALL echo(build("Error:: ",errorstr))
    RETURN(0)
   ENDIF
   SET crmstat = uar_crmbegintask(happ,taskid,htask)
   IF (crmstat != 0)
    SET errorstr = build("CrmBeginTask(",taskid,") stat:",crmstat)
    CALL uar_crmendapp(happ)
    CALL echo(build("Error:: ",errorstr))
    RETURN(0)
   ENDIF
   SET crmstat = uar_crmbeginreq(htask,"",reqnumber,hstep)
   IF (crmstat != 0)
    SET errorstr = build("CrmBeginReq(",reqnumber,") stat:",crmstat)
    CALL uar_crmendtask(htask)
    CALL uar_crmendapp(happ)
    CALL echo(build("Error:: ",errorstr))
    RETURN(0)
   ENDIF
   SET hreq = uar_crmgetrequest(hstep)
   SET srvstat = uar_srvsetstring(hreq,"info_name",nullterm(trim(mminfoname)))
   SET srvstat = uar_srvsetdouble(hreq,"logical_domain_id",mmlogical_domainid)
   SET crmstat = uar_crmperform(hstep)
   IF (crmstat != 0)
    SET errorstr = build("CrmPerform(",reqnumber,") stat:",crmstat)
    CALL echo(build("Error:: ",errorstr))
    RETURN(0)
   ENDIF
   CALL uar_crmendreq(hstep)
   CALL uar_crmendtask(htask)
   CALL uar_crmendapp(happ)
   RETURN(0)
 END ;Subroutine
 EXECUTE ccl_prompt_api_dataset "autoset"
 CALL checkmultitenancy(null)
 GO TO exit_script
 SUBROUTINE checkmultitenancy(null)
   IF (columnexistsontable("ORGANIZATION","LOGICAL_DOMAIN_ID")=1)
    SET logical_dm_ind = 1
   ENDIF
   SELECT INTO "nl:"
    ld.logical_domain_id
    FROM logical_domain ld
    WHERE ld.logical_domain_id > 0
     AND ld.active_ind=1
    WITH nocounter
   ;end select
   IF (curqual >= 1)
    SET logical_dm_ind += 1
   ENDIF
   IF (logical_dm_ind > 1)
    CALL getuserorganizations(null)
   ELSE
    CALL checkorgsecurity(null)
   ENDIF
 END ;Subroutine
 SUBROUTINE checkorgsecurity(null)
   DECLARE org_sec = i4 WITH protect, noconstant(0)
   IF (validate(ccldminfo->mode,0))
    IF ((ccldminfo->sec_org_reltn > 0))
     SET org_sec = 1
    ENDIF
   ELSE
    SELECT INTO "nl:"
     FROM dm_info d
     WHERE d.info_name="SEC_ORG_RELTN"
      AND d.info_domain="SECURITY"
     DETAIL
      org_sec = d.info_number
     WITH nocounter
    ;end select
    IF (curqual <= 0)
     IF (checkerror(failure,"SELECT",failure,"ORG SECURITY") > 0)
      SET s_msgbox_disp = errors->status_data.subeventstatus[errors->error_cnt].targetobjectvalue
      GO TO exit_script
     ENDIF
    ENDIF
   ENDIF
   IF (org_sec=0)
    CALL getallorganizations(null)
   ELSE
    CALL getuserorganizations(null)
   ENDIF
   IF (checkerror(failure,"SELECT",failure,"ORGANIZATION") > 0)
    SET s_msgbox_disp = errors->status_data.subeventstatus[errors->error_cnt].targetobjectvalue
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE getallorganizations(null)
   SELECT DISTINCT INTO "nl:"
    org_name = o.org_name, o.organization_id, org_name2 = o.org_name
    FROM organization o,
     org_type_reltn otr,
     location l,
     code_value cv,
     code_value cv2
    PLAN (o
     WHERE o.active_ind=1
      AND o.beg_effective_dt_tm <= cnvtdatetime(curdatetime)
      AND o.end_effective_dt_tm > cnvtdatetime(curdatetime))
     JOIN (otr
     WHERE otr.organization_id=o.organization_id)
     JOIN (cv
     WHERE cv.code_set=278
      AND otr.org_type_cd=cv.code_value)
     JOIN (l
     WHERE l.organization_id=o.organization_id
      AND l.patcare_node_ind=1
      AND l.active_ind=1)
     JOIN (cv2
     WHERE cv2.code_set=222
      AND cv2.code_value=l.location_type_cd)
    ORDER BY o.org_name
    HEAD REPORT
     stat = makedataset(50)
    DETAIL
     stat = writerecord(0)
    FOOT REPORT
     stat = closedataset(0)
    WITH nocounter, reporthelp, check
   ;end select
 END ;Subroutine
 SUBROUTINE getuserorganizations(null)
   EXECUTE secrtl
   EXECUTE sacrtl
   IF (validate(_sacrtl_org_inc_,99999)=99999)
    DECLARE _sacrtl_org_inc_ = i2 WITH constant(1)
    RECORD sac_org(
      1 organizations[*]
        2 organization_id = f8
        2 confid_cd = f8
        2 confid_level = i4
    )
    EXECUTE secrtl
    EXECUTE sacrtl
    DECLARE orgcnt = i4 WITH protected, noconstant(0)
    DECLARE secstat = i2
    DECLARE logontype = i4 WITH protect, noconstant(- (1))
    DECLARE dynamic_org_ind = i4 WITH protect, noconstant(- (1))
    DECLARE dcur_trustid = f8 WITH protect, noconstant(0.0)
    DECLARE dynorg_enabled = i4 WITH constant(1)
    DECLARE dynorg_disabled = i4 WITH constant(0)
    DECLARE logontype_nhs = i4 WITH constant(1)
    DECLARE logontype_legacy = i4 WITH constant(0)
    DECLARE confid_cnt = i4 WITH protected, noconstant(0)
    RECORD confid_codes(
      1 list[*]
        2 code_value = f8
        2 coll_seq = f8
    )
    CALL uar_secgetclientlogontype(logontype)
    CALL echo(build("logontype:",logontype))
    IF (logontype != logontype_nhs)
     SET dynamic_org_ind = dynorg_disabled
    ENDIF
    IF (logontype=logontype_nhs)
     SUBROUTINE (getdynamicorgpref(dtrustid=f8) =i4)
       DECLARE scur_trust = vc
       DECLARE pref_val = vc
       DECLARE is_enabled = i4 WITH constant(1)
       DECLARE is_disabled = i4 WITH constant(0)
       SET scur_trust = cnvtstring(dtrustid)
       SET scur_trust = concat(scur_trust,".00")
       IF ( NOT (validate(pref_req,0)))
        RECORD pref_req(
          1 write_ind = i2
          1 delete_ind = i2
          1 pref[*]
            2 contexts[*]
              3 context = vc
              3 context_id = vc
            2 section = vc
            2 section_id = vc
            2 subgroup = vc
            2 entries[*]
              3 entry = vc
              3 values[*]
                4 value = vc
        )
       ENDIF
       IF ( NOT (validate(pref_rep,0)))
        RECORD pref_rep(
          1 pref[*]
            2 section = vc
            2 section_id = vc
            2 subgroup = vc
            2 entries[*]
              3 pref_exists_ind = i2
              3 entry = vc
              3 values[*]
                4 value = vc
          1 status_data
            2 status = c1
            2 subeventstatus[1]
              3 operationname = c25
              3 operationstatus = c1
              3 targetobjectname = c25
              3 targetobjectvalue = vc
        )
       ENDIF
       SET stat = alterlist(pref_req->pref,1)
       SET stat = alterlist(pref_req->pref[1].contexts,2)
       SET stat = alterlist(pref_req->pref[1].entries,1)
       SET pref_req->pref[1].contexts[1].context = "organization"
       SET pref_req->pref[1].contexts[1].context_id = scur_trust
       SET pref_req->pref[1].contexts[2].context = "default"
       SET pref_req->pref[1].contexts[2].context_id = "system"
       SET pref_req->pref[1].section = "workflow"
       SET pref_req->pref[1].section_id = "UK Trust Security"
       SET pref_req->pref[1].entries[1].entry = "dynamic organizations"
       EXECUTE ppr_preferences  WITH replace("REQUEST","PREF_REQ"), replace("REPLY","PREF_REP")
       IF (cnvtupper(pref_rep->pref[1].entries[1].values[1].value)="ENABLED")
        RETURN(is_enabled)
       ELSE
        RETURN(is_disabled)
       ENDIF
     END ;Subroutine
     DECLARE hprop = i4 WITH protect, noconstant(0)
     DECLARE tmpstat = i2
     DECLARE spropname = vc
     DECLARE sroleprofile = vc
     SET hprop = uar_srvcreateproperty()
     SET tmpstat = uar_secgetclientattributesext(5,hprop)
     SET spropname = uar_srvfirstproperty(hprop)
     SET sroleprofile = uar_srvgetpropertyptr(hprop,nullterm(spropname))
     SELECT INTO "nl:"
      FROM prsnl_org_reltn_type prt,
       prsnl_org_reltn por
      PLAN (prt
       WHERE prt.role_profile=sroleprofile
        AND prt.active_ind=1
        AND prt.beg_effective_dt_tm <= cnvtdatetime(sysdate)
        AND prt.end_effective_dt_tm > cnvtdatetime(sysdate))
       JOIN (por
       WHERE (por.organization_id= Outerjoin(prt.organization_id))
        AND (por.person_id= Outerjoin(prt.prsnl_id))
        AND (por.active_ind= Outerjoin(1))
        AND (por.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(sysdate)))
        AND (por.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
      ORDER BY por.prsnl_org_reltn_id
      DETAIL
       orgcnt = 1, secstat = alterlist(sac_org->organizations,1), user_person_id = prt.prsnl_id,
       sac_org->organizations[1].organization_id = prt.organization_id, sac_org->organizations[1].
       confid_cd = por.confid_level_cd, confid_cd = uar_get_collation_seq(por.confid_level_cd),
       sac_org->organizations[1].confid_level =
       IF (confid_cd > 0) confid_cd
       ELSE 0
       ENDIF
      WITH maxrec = 1
     ;end select
     SET dcur_trustid = sac_org->organizations[1].organization_id
     SET dynamic_org_ind = getdynamicorgpref(dcur_trustid)
     CALL uar_srvdestroyhandle(hprop)
    ENDIF
    IF (dynamic_org_ind=dynorg_disabled)
     SET confid_cnt = 0
     SELECT INTO "NL:"
      c.code_value, c.collation_seq
      FROM code_value c
      WHERE c.code_set=87
      DETAIL
       confid_cnt += 1
       IF (mod(confid_cnt,10)=1)
        secstat = alterlist(confid_codes->list,(confid_cnt+ 9))
       ENDIF
       confid_codes->list[confid_cnt].code_value = c.code_value, confid_codes->list[confid_cnt].
       coll_seq = c.collation_seq
      WITH nocounter
     ;end select
     SET secstat = alterlist(confid_codes->list,confid_cnt)
     SELECT DISTINCT INTO "nl:"
      FROM prsnl_org_reltn por
      WHERE (por.person_id=reqinfo->updt_id)
       AND por.active_ind=1
       AND por.beg_effective_dt_tm < cnvtdatetime(sysdate)
       AND por.end_effective_dt_tm >= cnvtdatetime(sysdate)
      HEAD REPORT
       IF (orgcnt > 0)
        secstat = alterlist(sac_org->organizations,100)
       ENDIF
      DETAIL
       orgcnt += 1
       IF (mod(orgcnt,100)=1)
        secstat = alterlist(sac_org->organizations,(orgcnt+ 99))
       ENDIF
       sac_org->organizations[orgcnt].organization_id = por.organization_id, sac_org->organizations[
       orgcnt].confid_cd = por.confid_level_cd
      FOOT REPORT
       secstat = alterlist(sac_org->organizations,orgcnt)
      WITH nocounter
     ;end select
     SELECT INTO "NL:"
      FROM (dummyt d1  WITH seq = value(orgcnt)),
       (dummyt d2  WITH seq = value(confid_cnt))
      PLAN (d1)
       JOIN (d2
       WHERE (sac_org->organizations[d1.seq].confid_cd=confid_codes->list[d2.seq].code_value))
      DETAIL
       sac_org->organizations[d1.seq].confid_level = confid_codes->list[d2.seq].coll_seq
      WITH nocounter
     ;end select
    ELSEIF (dynamic_org_ind=dynorg_enabled)
     DECLARE nhstrustchild_org_org_reltn_cd = f8
     SET nhstrustchild_org_org_reltn_cd = uar_get_code_by("MEANING",369,"NHSTRUSTCHLD")
     SELECT INTO "nl:"
      FROM org_org_reltn oor
      PLAN (oor
       WHERE oor.organization_id=dcur_trustid
        AND oor.active_ind=1
        AND oor.beg_effective_dt_tm < cnvtdatetime(sysdate)
        AND oor.end_effective_dt_tm >= cnvtdatetime(sysdate)
        AND oor.org_org_reltn_cd=nhstrustchild_org_org_reltn_cd)
      HEAD REPORT
       IF (orgcnt > 0)
        secstat = alterlist(sac_org->organizations,10)
       ENDIF
      DETAIL
       IF (oor.related_org_id > 0)
        orgcnt += 1
        IF (mod(orgcnt,10)=1)
         secstat = alterlist(sac_org->organizations,(orgcnt+ 9))
        ENDIF
        sac_org->organizations[orgcnt].organization_id = oor.related_org_id
       ENDIF
      FOOT REPORT
       secstat = alterlist(sac_org->organizations,orgcnt)
      WITH nocounter
     ;end select
    ELSE
     CALL echo(build("Unexpected login type: ",dynamimc_org_ind))
    ENDIF
   ENDIF
   DECLARE org_cnt = i4 WITH protect, constant(size(sac_org->organizations,5))
   IF (org_cnt <= 0)
    GO TO exit_script
   ENDIF
   DECLARE expand_start = i4 WITH protected, noconstant(1)
   DECLARE expand_stop = i4 WITH protect, noconstant(50)
   DECLARE expand_size = i4 WITH constant(50)
   DECLARE expand_total = i4 WITH protect, noconstant(0)
   DECLARE index = i4 WITH protect, noconstant(0)
   DECLARE idx = i4 WITH protected, noconstant(0)
   SET expand_total = (ceil((cnvtreal(org_cnt)/ expand_size)) * expand_size)
   SET stat = alterlist(sac_org->organizations,expand_total)
   FOR (index = (org_cnt+ 1) TO expand_total)
     SET sac_org->organizations[index].organization_id = sac_org->organizations[org_cnt].
     organization_id
   ENDFOR
   SELECT DISTINCT INTO "nl:"
    org_name = o.org_name, o.organization_id, org_name2 = o.org_name
    FROM (dummyt d  WITH seq = value((expand_total/ expand_size))),
     organization o
    PLAN (d
     WHERE assign(expand_start,evaluate(d.seq,1,1,(expand_start+ expand_size)))
      AND assign(expand_stop,(expand_start+ (expand_size - 1))))
     JOIN (o
     WHERE expand(idx,expand_start,expand_stop,o.organization_id,sac_org->organizations[idx].
      organization_id)
      AND o.active_ind=1
      AND o.beg_effective_dt_tm <= cnvtdatetime(curdatetime)
      AND o.end_effective_dt_tm > cnvtdatetime(curdatetime))
    ORDER BY org_name
    HEAD REPORT
     stat = makedataset(50)
    DETAIL
     stat = writerecord(0)
    FOOT REPORT
     stat = closedataset(0)
    WITH nocounter, reporthelp, check
   ;end select
 END ;Subroutine
#exit_script
 IF (checkerror(failure,"CCL ERROR",failure,"FINAL ERROR CHECK") > 0)
  CALL showerrors("MINE")
  IF (textlen(trim(s_msgbox_disp,3)) > 0)
   SET stat = setmessageboxex(s_msgbox_disp,"Prompt Error",mb_error)
  ENDIF
 ENDIF
 FREE RECORD sac_org
END GO
