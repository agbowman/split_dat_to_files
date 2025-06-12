CREATE PROGRAM bhs_athn_get_encntr_ids_v2
 FREE RECORD result
 RECORD result(
   1 person_id = f8
   1 prsnl_id = f8
   1 list[*]
     2 encntr_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE log_level_error = i2 WITH protect, noconstant(0)
 DECLARE log_level_warning = i2 WITH protect, noconstant(1)
 DECLARE log_level_audit = i2 WITH protect, noconstant(2)
 DECLARE log_level_info = i2 WITH protect, noconstant(3)
 DECLARE log_level_debug = i2 WITH protect, noconstant(4)
 DECLARE hsys = i4 WITH protect, noconstant(0)
 DECLARE sysstat = i4 WITH protect, noconstant(0)
 DECLARE msg_default = i4 WITH protect, noconstant(0)
 DECLARE msg_level = i4 WITH protect, noconstant(0)
 DECLARE log_message(logmsg=vc,loglvl=i4) = null
 EXECUTE msgrtl
 SET msg_default = uar_msgdefhandle()
 SET msg_level = uar_msggetlevel(msg_default)
 EXECUTE crmrtl
 EXECUTE srvrtl
 DECLARE slogtext = vc WITH protect, noconstant("")
 DECLARE slogevent = vc WITH protect, noconstant("")
 DECLARE uarmsgwritestat = i4 WITH protect, noconstant(0)
 DECLARE info_domain = vc WITH protect, constant("ADMINISTRATIF LOGGING")
 DECLARE debug_on = c1 WITH protect, constant("1")
 DECLARE adm_debug_ind = i2 WITH protect, noconstant(0)
 DECLARE errmsg = c132 WITH protect, noconstant(" ")
 DECLARE uar_sisrvdump(p1=i4(ref)) = null WITH uar = "SiSrvDump", image_aix =
 "libsirtl.a(libsirtl.o)", image_axp = "sirtl"
 SELECT INTO "nl:"
  FROM dm_info dm
  PLAN (dm
   WHERE dm.info_domain=info_domain
    AND dm.info_name=curprog)
  DETAIL
   IF (dm.info_char=debug_on)
    adm_debug_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SUBROUTINE log_message(logmsg,loglvl)
   SET slogtext = ""
   SET slogevent = ""
   SET slogtext = concat("{{Script::",value(curprog),"}} ",logmsg)
   CASE (loglvl)
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
   SET uarmsgwritestat = uar_msgwrite(msg_default,0,curprog,loglvl,nullterm(slogtext))
   CALL echo(logmsg)
 END ;Subroutine
 DECLARE verifysecuritysettings(null) = i2
 DECLARE addencntrtosecurityreq(p1=f8(val),p2=f8(val)) = null
 DECLARE execencntrsecuritycheck(null) = null
 DECLARE always_call_validate_encounters = i2 WITH protect, noconstant(0)
 DECLARE bypass_security_check = i2 WITH protect, noconstant(0)
 DECLARE override_prsnl_id = f8 WITH protect, noconstant(0.0)
 IF (validate(encntr_access_reply) != 1)
  RECORD encntr_access_reply(
    1 encounter[*]
      2 encntr_id = f8
      2 access_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH persistscript
 ENDIF
 EXECUTE dcp_gen_cve_recs
 SUBROUTINE addencntrtosecurityreq(personid,encntrid)
   CALL log_message("In AddEncntrtoSecurityReq()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(curtime3), private
   DECLARE cvelistcnt = i4 WITH protect, noconstant(0)
   DECLARE cve_idx = i4 WITH protect, noconstant(0)
   DECLARE newcnt = i4 WITH protect, noconstant(0)
   SET cvelistcnt = size(cve_request->encntrs,5)
   IF (((cvelistcnt=0) OR (locateval(cve_idx,1,cvelistcnt,personid,cve_request->encntrs[cve_idx].
    person_id,
    encntrid,cve_request->encntrs[cve_idx].encntr_id) <= 0)) )
    SET newcnt = (cvelistcnt+ 1)
    SET stat = alterlist(cve_request->encntrs,newcnt)
    SET cve_request->encntrs[newcnt].person_id = personid
    SET cve_request->encntrs[newcnt].encntr_id = encntrid
   ENDIF
   CALL log_message(build("Exit AddEncntrtoSecurityReq(), Elapsed time in seconds:",((curtime3 -
     begin_date_time)/ 100)),log_level_debug)
 END ;Subroutine
 SUBROUTINE execencntrsecuritycheck(null)
   CALL log_message("In ExecEncntrSecurityCheck()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(curtime3), private
   DECLARE encntr_idx = i4 WITH protect, noconstant(0)
   DECLARE prev_reqinfo_updt_id = f8 WITH protect, noconstant(0.0)
   IF (validate(debug_ind,0)=1)
    CALL echorecord(cve_request)
   ENDIF
   IF (verifysecuritysettings(null)=1)
    IF (override_prsnl_id > 0.0)
     IF (validate(debug_ind,0)=1)
      CALL echo(build2("setting reqinfo->updt_id = ",override_prsnl_id))
     ENDIF
     SET prev_reqinfo_updt_id = reqinfo->updt_id
     SET reqinfo->updt_id = override_prsnl_id
    ENDIF
    EXECUTE dcp_chck_valid_encounters  WITH replace("REQUEST",cve_request), replace("REPLY",cve_reply
     )
    IF (override_prsnl_id > 0.0)
     IF (validate(debug_ind,0)=1)
      CALL echo(build2("restoring reqinfo->updt_id to ",prev_reqinfo_updt_id))
     ENDIF
     SET reqinfo->updt_id = prev_reqinfo_updt_id
    ENDIF
    IF (validate(debug_ind,0)=1)
     CALL echorecord(cve_reply)
    ENDIF
    SET stat = initrec(encntr_access_reply)
    SET stat = alterlist(encntr_access_reply->encounter,size(cve_reply->encntrs,5))
    FOR (encntr_idx = 1 TO size(cve_reply->encntrs,5))
     SET encntr_access_reply->encounter[encntr_idx].encntr_id = cve_reply->encntrs[encntr_idx].
     encntr_id
     IF ((cve_reply->encntrs[encntr_idx].secure_ind=0))
      SET encntr_access_reply->encounter[encntr_idx].access_ind = 1
     ELSE
      SET encntr_access_reply->encounter[encntr_idx].access_ind = 0
     ENDIF
    ENDFOR
   ELSE
    SET stat = alterlist(encntr_access_reply->encounter,size(cve_request->encntrs,5))
    FOR (encntr_idx = 1 TO size(cve_request->encntrs,5))
     SET encntr_access_reply->encounter[encntr_idx].encntr_id = cve_request->encntrs[encntr_idx].
     encntr_id
     SET encntr_access_reply->encounter[encntr_idx].access_ind = 1
    ENDFOR
   ENDIF
   IF ((cve_reply->status_data.status != "F"))
    IF (size(encntr_access_reply->encounter,5) > 0)
     SET encntr_access_reply->status_data.status = "S"
    ELSE
     SET encntr_access_reply->status_data.status = "Z"
    ENDIF
   ELSE
    SET encntr_access_reply->status_data.status = "F"
   ENDIF
   IF (validate(debug_ind,0)=1)
    CALL echorecord(encntr_access_reply)
   ENDIF
   CALL log_message(build("Exit ExecEncntrSecurityCheck(), Elapsed time in seconds:",((curtime3 -
     begin_date_time)/ 100)),log_level_debug)
 END ;Subroutine
 SUBROUTINE verifysecuritysettings(null)
   DECLARE begin_date_time = dq8 WITH constant(curtime3), private
   DECLARE org_security_on = i2 WITH protect, noconstant(0)
   DECLARE confid_security_on = i2 WITH protect, noconstant(0)
   IF (bypass_security_check=1)
    IF (validate(debug_ind,0)=1)
     CALL echo("Security checking bypassed. Returning false from VerifySecuritySettings")
    ENDIF
    RETURN(false)
   ENDIF
   IF (always_call_validate_encounters=1)
    IF (validate(debug_ind,0)=1)
     CALL echo("returning true from VerifySecuritySettings - security_level is unknown")
    ENDIF
    RETURN(true)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info dm
    PLAN (dm
     WHERE dm.info_domain="SECURITY"
      AND dm.info_name IN ("SEC_ORG_RELTN", "SEC_CONFID"))
    DETAIL
     IF (dm.info_name="SEC_ORG_RELTN"
      AND dm.info_number=1)
      org_security_on = 1
     ELSEIF (dm.info_name="SEC_CONFID"
      AND dm.info_number=1)
      confid_security_on = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (org_security_on=1
    AND confid_security_on=1)
    SET cve_request->security_flag = 2
   ELSEIF (org_security_on=1
    AND confid_security_on=0)
    SET cve_request->security_flag = 1
   ELSE
    SET cve_request->security_flag = 0
    IF (validate(debug_ind,0)=1)
     CALL echo(build2("returning false from VerifySecuritySettings - security_level = ",0))
    ENDIF
    RETURN(false)
   ENDIF
   IF (validate(debug_ind,0)=1)
    CALL echo(build2("returning true from VerifySecuritySettings - security_level = ",cve_request->
      security_flag))
   ENDIF
   CALL log_message(build("Exit VerifySecuritySettings(), Elapsed time in seconds:",((curtime3 -
     begin_date_time)/ 100)),log_level_debug)
   RETURN(true)
 END ;Subroutine
 DECLARE getencounters(null) = i4
 DECLARE checkorgsecurity(null) = i4
 DECLARE success = i2 WITH protect, constant(0)
 DECLARE fail = i2 WITH protect, constant(1)
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE ecnt = i4 WITH protect, noconstant(0)
 SET result->status_data.status = "F"
 IF (( $2 <= 0.0))
  CALL echo("INVALID PERSON ID PARAMETER...EXITING")
  GO TO exit_script
 ELSEIF (( $3 <= 0.0))
  CALL echo("INVALID PERSONNEL ID PARAMETER...EXITING")
  GO TO exit_script
 ENDIF
 SET result->person_id = cnvtreal( $2)
 SET result->prsnl_id = cnvtreal( $3)
 SET stat = getencounters(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 IF (size(result->list,5) > 0)
  SET stat = checkorgsecurity(null)
  IF (stat=fail)
   GO TO exit_script
  ENDIF
 ENDIF
 SET result->status_data.status = "S"
#exit_script
 CALL echorecord(result)
 IF (size(trim(moutputdevice,3)) > 0)
  FREE RECORD out_rec
  RECORD out_rec(
    1 encntr_ids = vc
  ) WITH protect
  FOR (idx = 1 TO size(cve_reply->encntrs,5))
    IF ((cve_reply->encntrs[idx].secure_ind=0))
     IF (size(trim(out_rec->encntr_ids,3)) > 0)
      SET out_rec->encntr_ids = concat(out_rec->encntr_ids,char(44))
     ENDIF
     SET out_rec->encntr_ids = concat(out_rec->encntr_ids,trim(cnvtstring(cve_reply->encntrs[idx].
        encntr_id),3))
    ENDIF
  ENDFOR
  CALL echorecord(out_rec)
  CALL echojson(out_rec,moutputdevice)
 ENDIF
 FREE RECORD result
 FREE RECORD out_rec
 SUBROUTINE getencounters(null)
   SELECT INTO "NL:"
    FROM encounter e
    PLAN (e
     WHERE (e.person_id=result->person_id)
      AND e.active_ind=1)
    ORDER BY e.encntr_id
    HEAD e.encntr_id
     ecnt = (ecnt+ 1), stat = alterlist(result->list,ecnt), result->list[ecnt].encntr_id = e
     .encntr_id
    WITH nocounter, time = 30
   ;end select
 END ;Subroutine
 SUBROUTINE checkorgsecurity(null)
   FOR (idx = 1 TO size(result->list,5))
     CALL addencntrtosecurityreq(result->person_id,result->list[idx].encntr_id)
   ENDFOR
   SET override_prsnl_id = result->prsnl_id
   CALL execencntrsecuritycheck(null)
 END ;Subroutine
END GO
