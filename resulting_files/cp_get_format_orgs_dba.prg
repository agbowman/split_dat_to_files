CREATE PROGRAM cp_get_format_orgs:dba
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
 SET log_program_name = "CP_GET_FORMAT_ORGS"
 RECORD reply(
   1 qual[*]
     2 organization_id = f8
     2 org_name = c100
     2 format_qual[*]
       3 chart_format_id = f8
       3 chart_format_name = c50
       3 primary_format_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD flat_rec
 RECORD flat_rec(
   1 qual[*]
     2 organization_id = f8
 )
 SET reply->status_data.status = "F"
 CALL log_message("Starting script: cp_get_format_orgs",log_level_debug)
 DECLARE client_cd = f8 WITH constant(uar_get_code_by("MEANING",278,"CLIENT")), protect
 DECLARE facility_cd = f8 WITH constant(uar_get_code_by("MEANING",278,"FACILITY")), protect
 DECLARE x = i4 WITH public, noconstant(0)
 DECLARE y = i4 WITH public, noconstant(0)
 DECLARE idx = i4
 DECLARE idxstart = i4 WITH noconstant(1)
 DECLARE noptimizedtotal = i4
 DECLARE bind_cnt = i4 WITH constant(50)
 DECLARE org_cnt = i2 WITH public, noconstant(0)
 SET org_cnt = size(request->qual,5)
 IF (org_cnt > 0)
  SET noptimizedtotal = (ceil((cnvtreal(org_cnt)/ bind_cnt)) * bind_cnt)
  SET stat = alterlist(request->qual,noptimizedtotal)
  FOR (i = (org_cnt+ 1) TO noptimizedtotal)
    SET request->qual[i].organization_id = request->qual[org_cnt].organization_id
  ENDFOR
  SELECT INTO "nl:"
   o.organization_id
   FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
    org_type_reltn otr,
    organization o
   PLAN (d
    WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
    JOIN (otr
    WHERE expand(idx,idxstart,((idxstart+ bind_cnt) - 1),otr.organization_id,request->qual[idx].
     organization_id,
     bind_cnt)
     AND otr.org_type_cd IN (client_cd, facility_cd)
     AND otr.active_ind=1)
    JOIN (o
    WHERE o.organization_id=otr.organization_id
     AND o.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND o.end_effective_dt_tm >= cnvtdatetime(sysdate)
     AND o.active_ind=1)
   ORDER BY o.organization_id
   HEAD o.organization_id
    x += 1
    IF (x > size(reply->qual,5))
     stat = alterlist(reply->qual,(x+ 9))
    ENDIF
    IF (mod(x,bind_cnt)=1)
     stat = alterlist(flat_rec->qual,((x+ bind_cnt) - 1))
    ENDIF
    reply->qual[x].organization_id = o.organization_id, reply->qual[x].org_name = o.org_name,
    flat_rec->qual[x].organization_id = o.organization_id
   FOOT REPORT
    stat = alterlist(reply->qual,x)
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   o.organization_id
   FROM org_type_reltn otr,
    organization o
   PLAN (otr
    WHERE otr.org_type_cd IN (client_cd, facility_cd)
     AND otr.active_ind=1)
    JOIN (o
    WHERE o.organization_id=otr.organization_id
     AND o.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND o.end_effective_dt_tm >= cnvtdatetime(sysdate)
     AND o.active_ind=1)
   ORDER BY o.organization_id
   HEAD o.organization_id
    x += 1
    IF (x > size(reply->qual,5))
     stat = alterlist(reply->qual,(x+ 9))
    ENDIF
    IF (mod(x,bind_cnt)=1)
     stat = alterlist(flat_rec->qual,((x+ bind_cnt) - 1))
    ENDIF
    reply->qual[x].organization_id = o.organization_id, reply->qual[x].org_name = o.org_name,
    flat_rec->qual[x].organization_id = o.organization_id
   FOOT REPORT
    stat = alterlist(reply->qual,x)
   WITH nocounter
  ;end select
 ENDIF
 CALL error_and_zero_check(curqual,"ORGANIZATION","TABLE",1,1)
 SET flat_rec_cnt = x
 SET noptimizedtotal = (ceil((cnvtreal(flat_rec_cnt)/ bind_cnt)) * bind_cnt)
 SET stat = alterlist(flat_rec->qual,noptimizedtotal)
 FOR (i = (flat_rec_cnt+ 1) TO noptimizedtotal)
   SET flat_rec->qual[i].organization_id = flat_rec->qual[flat_rec_cnt].organization_id
 ENDFOR
 DECLARE idx2 = i4
 SELECT INTO "nl:"
  locval = locateval(idx2,1,size(reply->qual,5),f.organization_id,reply->qual[idx2].organization_id)
  FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
   format_org_reltn f,
   chart_format c
  PLAN (d
   WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
   JOIN (f
   WHERE expand(idx,idxstart,((idxstart+ bind_cnt) - 1),f.organization_id,flat_rec->qual[idx].
    organization_id,
    bind_cnt)
    AND f.active_ind=1)
   JOIN (c
   WHERE c.chart_format_id=f.chart_format_id)
  ORDER BY f.organization_id
  HEAD f.organization_id
   y = 0
  DETAIL
   y += 1
   IF (y > size(reply->qual[locval].format_qual,5))
    stat = alterlist(reply->qual[locval].format_qual,(y+ 9))
   ENDIF
   reply->qual[locval].format_qual[y].chart_format_id = f.chart_format_id, reply->qual[locval].
   format_qual[y].chart_format_name = c.chart_format_desc, reply->qual[locval].format_qual[y].
   primary_format_ind = f.primary_format_ind
  FOOT  f.organization_id
   stat = alterlist(reply->qual[locval].format_qual,y)
  WITH nocounter
 ;end select
 CALL error_and_zero_check(curqual,"FORMAT_ORG_RELTN","TABLE",1,0)
 SET reply->status_data.status = "S"
#exit_script
 CALL log_message("End of script: cp_get_format_orgs",log_level_debug)
END GO
