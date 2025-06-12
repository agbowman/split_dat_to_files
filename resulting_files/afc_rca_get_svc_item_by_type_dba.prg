CREATE PROGRAM afc_rca_get_svc_item_by_type:dba
 IF ( NOT (validate(log_error)))
  DECLARE log_error = i4 WITH protect, constant(0)
 ENDIF
 IF ( NOT (validate(log_warning)))
  DECLARE log_warning = i4 WITH protect, constant(1)
 ENDIF
 IF ( NOT (validate(log_audit)))
  DECLARE log_audit = i4 WITH protect, constant(2)
 ENDIF
 IF ( NOT (validate(log_info)))
  DECLARE log_info = i4 WITH protect, constant(3)
 ENDIF
 IF ( NOT (validate(log_debug)))
  DECLARE log_debug = i4 WITH protect, constant(4)
 ENDIF
 DECLARE __lpahsys = i4 WITH protect, noconstant(0)
 DECLARE __lpalsysstat = i4 WITH protect, noconstant(0)
 IF (validate(logmessage,char(128))=char(128))
  SUBROUTINE (logmessage(psubroutine=vc,pmessage=vc,plevel=i4) =null)
    DECLARE cs23372_failed_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",23372,"FAILED"))
    DECLARE hmsg = i4 WITH protect, noconstant(0)
    DECLARE hreq = i4 WITH protect, noconstant(0)
    DECLARE hrep = i4 WITH protect, noconstant(0)
    DECLARE hobjarray = i4 WITH protect, noconstant(0)
    DECLARE srvstatus = i4 WITH protect, noconstant(0)
    DECLARE submit_log = i4 WITH protect, constant(4099455)
    CALL echo("")
    CALL echo("::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::")
    IF (size(trim(psubroutine,3)) > 0)
     CALL echo(concat(curprog," : ",psubroutine,"() : ",pmessage))
    ELSE
     CALL echo(concat(curprog," : ",pmessage))
    ENDIF
    CALL echo("::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::")
    CALL echo("")
    SET __lpahsys = 0
    SET __lpalsysstat = 0
    CALL uar_syscreatehandle(__lpahsys,__lpalsysstat)
    IF (__lpahsys > 0)
     CALL uar_sysevent(__lpahsys,plevel,curprog,nullterm(pmessage))
     CALL uar_sysdestroyhandle(__lpahsys)
    ENDIF
    IF (plevel=log_error)
     SET hmsg = uar_srvselectmessage(submit_log)
     SET hreq = uar_srvcreaterequest(hmsg)
     SET hrep = uar_srvcreatereply(hmsg)
     SET hobjarray = uar_srvadditem(hreq,"objArray")
     SET stat = uar_srvsetdouble(hobjarray,"final_status_cd",cs23372_failed_cd)
     SET stat = uar_srvsetstring(hobjarray,"task_name",nullterm(curprog))
     SET stat = uar_srvsetstring(hobjarray,"completion_msg",nullterm(pmessage))
     SET stat = uar_srvsetdate(hobjarray,"end_dt_tm",cnvtdatetime(sysdate))
     SET stat = uar_srvsetstring(hobjarray,"current_node_name",nullterm(curnode))
     SET stat = uar_srvsetstring(hobjarray,"server_name",nullterm(build(curserver)))
     SET srvstatus = uar_srvexecute(hmsg,hreq,hrep)
     IF (srvstatus != 0)
      CALL echo(build2("Execution of pft_save_system_activity_log was not successful"))
     ENDIF
     CALL uar_srvdestroyinstance(hreq)
     CALL uar_srvdestroyinstance(hrep)
    ENDIF
  END ;Subroutine
 ENDIF
 IF ( NOT (validate(go_to_exit_script)))
  DECLARE go_to_exit_script = i2 WITH constant(1)
 ENDIF
 IF ( NOT (validate(dont_go_to_exit_script)))
  DECLARE dont_go_to_exit_script = i2 WITH constant(0)
 ENDIF
 IF (validate(beginservice,char(128))=char(128))
  SUBROUTINE (beginservice(pversion=vc) =null)
   CALL logmessage("",concat("version:",pversion," :Begin Service"),log_debug)
   CALL setreplystatus("F","Begin Service")
  END ;Subroutine
 ENDIF
 IF (validate(exitservicesuccess,char(128))=char(128))
  SUBROUTINE (exitservicesuccess(pmessage=vc) =null)
    DECLARE errmsg = vc WITH noconstant(" ")
    DECLARE errcode = i2 WITH noconstant(1)
    IF (size(trim(pmessage,3)) > 0)
     CALL logmessage("",pmessage,log_info)
    ENDIF
    IF ((((currevminor2+ (currevminor * 100))+ (currev * 10000)) >= 080311))
     IF (curdomain IN ("SURROUND", "SOLUTION"))
      SET errmsg = fillstring(132," ")
      SET errcode = error(errmsg,1)
      IF (errcode != 0)
       CALL exitservicefailure(errmsg,true)
      ELSE
       CALL logmessage("","Exit Service - SUCCESS",log_debug)
       CALL setreplystatus("S",evaluate(pmessage,"","Exit Service - SUCCESS",pmessage))
       SET reqinfo->commit_ind = true
      ENDIF
     ELSE
      CALL logmessage("","Exit Service - SUCCESS",log_debug)
      CALL setreplystatus("S",evaluate(pmessage,"","Exit Service - SUCCESS",pmessage))
      SET reqinfo->commit_ind = true
     ENDIF
    ELSE
     CALL logmessage("","Exit Service - SUCCESS",log_debug)
     CALL setreplystatus("S",evaluate(pmessage,"","Exit Service - SUCCESS",pmessage))
     SET reqinfo->commit_ind = true
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(exitservicefailure,char(128))=char(128))
  SUBROUTINE (exitservicefailure(pmessage=vc,exitscriptind=i2) =null)
    CALL addtracemessage("",evaluate(trim(pmessage),trim(""),"Exit Service - FAILURE",pmessage))
    CALL logmessage("",evaluate(trim(pmessage),trim(""),"Exit Service - FAILURE",pmessage),log_error)
    IF (validate(reply->failure_stack.failures))
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].operationname = reply->failure_stack.failures[1].
     programname
     SET reply->status_data.subeventstatus[1].targetobjectname = reply->failure_stack.failures[1].
     routinename
     SET reply->status_data.subeventstatus[1].targetobjectvalue = reply->failure_stack.failures[1].
     message
    ELSE
     CALL setreplystatus("F",evaluate(trim(pmessage),trim(""),"Exit Service - FAILURE",pmessage))
    ENDIF
    SET reqinfo->commit_ind = false
    IF (exitscriptind)
     GO TO exit_script
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(exitservicenodata,char(128))=char(128))
  SUBROUTINE (exitservicenodata(pmessage=vc,exitscriptind=i2) =null)
    IF (size(trim(pmessage,3)) > 0)
     CALL logmessage("",pmessage,log_info)
    ENDIF
    CALL logmessage("","Exit Service - NO DATA",log_debug)
    CALL setreplystatus("Z",evaluate(pmessage,"","Exit Service - NO DATA",pmessage))
    SET reqinfo->commit_ind = false
    IF (exitscriptind)
     GO TO exit_script
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(setreplystatus,char(128))=char(128))
  SUBROUTINE (setreplystatus(pstatus=vc,pmessage=vc) =null)
    IF (validate(reply->status_data))
     SET reply->status_data.status = nullterm(pstatus)
     SET reply->status_data.subeventstatus[1].operationstatus = nullterm(pstatus)
     SET reply->status_data.subeventstatus[1].operationname = nullterm(curprog)
     SET reply->status_data.subeventstatus[1].targetobjectvalue = nullterm(pmessage)
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(addtracemessage,char(128))=char(128))
  SUBROUTINE (addtracemessage(proutinename=vc,pmessage=vc) =null)
   CALL logmessage(proutinename,pmessage,log_debug)
   IF (validate(reply->failure_stack))
    DECLARE failcnt = i4 WITH protect, noconstant((size(reply->failure_stack.failures,5)+ 1))
    SET stat = alterlist(reply->failure_stack.failures,failcnt)
    SET reply->failure_stack.failures[failcnt].programname = nullterm(curprog)
    SET reply->failure_stack.failures[failcnt].routinename = nullterm(proutinename)
    SET reply->failure_stack.failures[failcnt].message = nullterm(pmessage)
   ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(addstatusdetail,char(128))=char(128))
  SUBROUTINE (addstatusdetail(pentityid=f8,pdetailflag=i4,pdetailmessage=vc) =null)
    IF (validate(reply->status_detail))
     DECLARE detailcnt = i4 WITH protect, noconstant((size(reply->status_detail.details,5)+ 1))
     SET stat = alterlist(reply->status_detail.details,detailcnt)
     SET reply->status_detail.details[detailcnt].entityid = pentityid
     SET reply->status_detail.details[detailcnt].detailflag = pdetailflag
     SET reply->status_detail.details[detailcnt].detailmessage = nullterm(pdetailmessage)
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(copystatusdetails,char(128))=char(128))
  SUBROUTINE (copystatusdetails(pfromrecord=vc(ref),prtorecord=vc(ref)) =null)
    IF (validate(pfromrecord->status_detail)
     AND validate(prtorecord->status_detail))
     DECLARE fromidx = i4 WITH protect, noconstant(0)
     DECLARE fromcnt = i4 WITH protect, noconstant(size(pfromrecord->status_detail.details,5))
     DECLARE toidx = i4 WITH protect, noconstant(size(prtorecord->status_detail.details,5))
     DECLARE fromparamidx = i4 WITH protect, noconstant(0)
     DECLARE toparamcnt = i4 WITH protect, noconstant(0)
     FOR (fromidx = 1 TO fromcnt)
       SET toidx += 1
       SET stat = alterlist(prtorecord->status_detail.details,toidx)
       SET prtorecord->status_detail.details[toidx].entityid = pfromrecord->status_detail.details[
       fromidx].entityid
       SET prtorecord->status_detail.details[toidx].detailflag = pfromrecord->status_detail.details[
       fromidx].detailflag
       SET prtorecord->status_detail.details[toidx].detailmessage = pfromrecord->status_detail.
       details[fromidx].detailmessage
       SET toparamcnt = 0
       FOR (fromparamidx = 1 TO size(pfromrecord->status_detail.details[fromidx].parameters,5))
         SET toparamcnt += 1
         SET stat = alterlist(prtorecord->status_detail.details[toidx].parameters,toparamcnt)
         SET prtorecord->status_detail.details[toidx].parameters[toparamcnt].paramname = pfromrecord
         ->status_detail.details[fromidx].parameters[fromparamidx].paramname
         SET prtorecord->status_detail.details[toidx].parameters[toparamcnt].paramvalue = pfromrecord
         ->status_detail.details[fromidx].parameters[fromparamidx].paramvalue
       ENDFOR
     ENDFOR
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(addstatusdetailparam,char(128))=char(128))
  SUBROUTINE (addstatusdetailparam(pdetailidx=i4,pparamname=vc,pparamvalue=vc) =null)
    IF (validate(reply->status_detail))
     IF (validate(reply->status_detail.details[pdetailidx].parameters))
      DECLARE paramcnt = i4 WITH protect, noconstant((size(reply->status_detail.details[pdetailidx].
        parameters,5)+ 1))
      SET stat = alterlist(reply->status_detail.details[pdetailidx].parameters,paramcnt)
      SET reply->status_detail.details[pdetailidx].parameters[paramcnt].paramname = pparamname
      SET reply->status_detail.details[pdetailidx].parameters[paramcnt].paramvalue = pparamvalue
     ENDIF
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(copytracemessages,char(128))=char(128))
  SUBROUTINE (copytracemessages(pfromrecord=vc(ref),prtorecord=vc(ref)) =null)
    IF (validate(pfromrecord->failure_stack)
     AND validate(prtorecord->failure_stack))
     DECLARE fromidx = i4 WITH protect, noconstant(0)
     DECLARE fromcnt = i4 WITH protect, noconstant(size(pfromrecord->failure_stack.failures,5))
     DECLARE toidx = i4 WITH protect, noconstant(size(prtorecord->failure_stack.failures,5))
     FOR (fromidx = 1 TO fromcnt)
       SET toidx += 1
       SET stat = alterlist(prtorecord->failure_stack.failures,toidx)
       SET prtorecord->failure_stack.failures[toidx].programname = pfromrecord->failure_stack.
       failures[fromidx].programname
       SET prtorecord->failure_stack.failures[toidx].routinename = pfromrecord->failure_stack.
       failures[fromidx].routinename
       SET prtorecord->failure_stack.failures[toidx].message = pfromrecord->failure_stack.failures[
       fromidx].message
     ENDFOR
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(getcodevalue,char(128))=char(128))
  EXECUTE NULL ;noop
 ENDIF
 IF (validate(s_cdf_meaning,char(128))=char(128))
  DECLARE s_cdf_meaning = c12 WITH public, noconstant(fillstring(12," "))
 ENDIF
 IF ((validate(s_code_value,- (0.00001))=- (0.00001)))
  DECLARE s_code_value = f8 WITH public, noconstant(0.0)
 ENDIF
 DECLARE pa_table_name = vc WITH protect, noconstant("")
 SUBROUTINE (getcodevalue(code_set=i4,cdf_meaning=vc,option_flag=i2) =f8)
   SET s_cdf_meaning = cdf_meaning
   SET s_code_value = 0.0
   SET stat = uar_get_meaning_by_codeset(code_set,s_cdf_meaning,1,s_code_value)
   IF (((stat != 0) OR (s_code_value <= 0.0)) )
    SET s_code_value = 0.0
    CASE (option_flag)
     OF 0:
      SET pa_table_name = build("ERROR-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(pa_table_name)
      SET pft_failed = uar_error
      EXECUTE pft_log "getcodevalue", pa_table_name, 0
      GO TO exit_script
     OF 1:
      SET pa_table_name = build("INFO-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(pa_table_name)
     OF 2:
      SET pa_table_name = build("INFO-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(pa_table_name)
      EXECUTE pft_log "getcodevalue", pa_table_name, 3
     OF 3:
      SET pa_table_name = build("ERROR-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(pa_table_name)
      CALL err_add_message(pa_table_name)
      SET pft_failed = uar_error
    ENDCASE
   ELSE
    CALL echo(build("SUCCESS-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
      '"',",",option_flag,") CODE_VALUE [",s_code_value,
      "]"))
   ENDIF
   RETURN(s_code_value)
 END ;Subroutine
 CALL echo(build("Begin including AFC_GET_BILL_ITEM_SECURITY_SUBS.INC, version [",nullterm(
    "14696.002"),"]"))
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
 RECORD afc_dm_request(
   1 info_name_qual = i2
   1 info[*]
     2 info_name = vc
   1 info_name = vc
 )
 RECORD afc_dm_reply(
   1 dm_info_qual = i2
   1 dm_info[*]
     2 info_name = vc
     2 info_date = dq8
     2 info_char = vc
     2 info_number = f8
     2 info_long_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 FREE RECORD afc_dcp_request
 RECORD afc_dcp_request(
   1 chk_prsnl_ind = i2
   1 prsnl_id = f8
   1 chk_psn_ind = i2
   1 position_cd = f8
   1 chk_ppr_ind = i2
   1 ppr_cd = f8
   1 plist[*]
     2 privilege_cd = f8
     2 privilege_mean = c12
 )
 FREE RECORD afc_dcp_reply
 RECORD afc_dcp_reply(
   1 qual[*]
     2 privilege_cd = f8
     2 privilege_disp = c40
     2 privilege_desc = c60
     2 privilege_mean = c12
     2 priv_status = c1
     2 priv_value_cd = f8
     2 priv_value_disp = c40
     2 priv_value_desc = c60
     2 priv_value_mean = c12
     2 restr_method_cd = f8
     2 restr_method_disp = c40
     2 restr_method_desc = c60
     2 restr_method_mean = c12
     2 except_cnt = i4
     2 excepts[*]
       3 exception_entity_name = c40
       3 exception_type_cd = f8
       3 exception_type_disp = c40
       3 exception_type_desc = c60
       3 exception_type_mean = c12
       3 exception_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE isbillitemsecurityon = i2 WITH protect, noconstant(0)
 DECLARE isbillcodesecurityon = i2 WITH protect, noconstant(0)
 DECLARE isinexceptionlist = i2 WITH protect, noconstant(0)
 DECLARE foundsecurityitem = i2 WITH protect, noconstant(0)
 DECLARE nrepcount = i4 WITH protect, noconstant(0)
 DECLARE billcodesecurityinfoname = vc WITH protect, constant("BILL CODE SCHED SECURITY")
 DECLARE billitemsecurityinfoname = vc WITH protect, constant("BILL ITEM SECURITY")
 IF ( NOT (validate(cs26078_bc_sched)))
  DECLARE cs26078_bc_sched = f8 WITH protect, constant(getcodevalue(26078,"BC_SCHED",0))
 ENDIF
 IF ( NOT (validate(cs13019_bill_code_cd)))
  DECLARE cs13019_bill_code_cd = f8 WITH protect, constant(getcodevalue(13019,"BILL CODE",0))
 ENDIF
 IF ( NOT (validate(cs26078_bill_item)))
  DECLARE cs26078_bill_item = f8 WITH protect, constant(getcodevalue(26078,"BILL_ITEM",0))
 ENDIF
 IF ( NOT (validate(cs6016_chargeentry)))
  DECLARE cs6016_chargeentry = f8 WITH protect, constant(getcodevalue(6016,"CHARGEENTRY",0))
 ENDIF
 IF ( NOT (validate(cs6016_chargevient)))
  DECLARE cs6016_chargevient = f8 WITH protect, constant(getcodevalue(6016,"CHARGEVI&ENT",0))
 ENDIF
 IF ( NOT (validate(cs14002_asaschedulecd)))
  DECLARE cs14002_asaschedulecd = f8 WITH protect, constant(getcodevalue(14002,"ASA",0))
 ENDIF
 SUBROUTINE (initializebillitemsecurity(dummy=vc) =i2)
   SET afc_dm_request->info_name_qual = 2
   SET stat = alterlist(afc_dm_request->info,2)
   SET afc_dm_request->info[1].info_name = billcodesecurityinfoname
   SET afc_dm_request->info[2].info_name = billitemsecurityinfoname
   EXECUTE afc_get_dm_info  WITH replace("REQUEST",afc_dm_request), replace("REPLY",afc_dm_reply)
   IF ((afc_dm_reply->status_data.status="S"))
    FOR (nrepcount = 1 TO size(afc_dm_reply->dm_info,5))
     IF ((afc_dm_reply->dm_info[nrepcount].info_name=billcodesecurityinfoname)
      AND (afc_dm_reply->dm_info[nrepcount].info_char="Y"))
      SET isbillcodesecurityon = true
     ENDIF
     IF ((afc_dm_reply->dm_info[nrepcount].info_name=billitemsecurityinfoname)
      AND (afc_dm_reply->dm_info[nrepcount].info_char="Y"))
      SET isbillitemsecurityon = true
     ENDIF
    ENDFOR
    RETURN(true)
   ELSEIF ((afc_dm_reply->status_data.status="Z"))
    RETURN(true)
   ELSEIF ((afc_dm_reply->status_data.status="F"))
    RETURN(false)
   ENDIF
 END ;Subroutine
 SUBROUTINE (checkactivitytypeprivs(dactivitytypecd=f8) =i2)
   SET userhasprivsreturnvalue = true
   SET stat = alterlist(afc_dcp_reply->qual,0)
   SET afc_dcp_request->chk_psn_ind = 1
   SET stat = alterlist(afc_dcp_request->plist,1)
   SET afc_dcp_request->plist[1].privilege_mean = "CHARGEENTRY"
   SET afc_dcp_request->plist[1].privilege_cd = cs6016_chargeentry
   EXECUTE dcp_get_privs  WITH replace("REQUEST",afc_dcp_request), replace("REPLY",afc_dcp_reply)
   IF (size(afc_dcp_reply->qual,5)=0)
    SET afc_dcp_request->plist[1].privilege_meaning = "CHARGEVI&ENT"
    SET afc_dcp_request->plist[1].privilege_cd = cs6016_chargevient
    EXECUTE dcp_get_privs  WITH replace("REQUEST",afc_dcp_request), replace("REPLY",afc_dcp_reply)
   ENDIF
   IF (size(afc_dcp_reply->qual,5)=1)
    IF ((afc_dcp_reply->qual[1].priv_value_cd=0))
     SET afc_dcp_request->plist[1].privilege_mean = "CHARGEVI&ENT"
     SET afc_dcp_request->plist[1].privilege_cd = cs6016_chargevient
     EXECUTE dcp_get_privs  WITH replace("REQUEST",afc_dcp_request), replace("REPLY",afc_dcp_reply)
    ENDIF
   ENDIF
   IF (size(afc_dcp_reply->qual,5) > 0)
    FOR (nrepcount = 1 TO size(afc_dcp_reply->qual,5))
      SET meaningforvalue = uar_get_code_meaning(afc_dcp_reply->qual[nrepcount].priv_value_cd)
      SET isinexceptionlist = false
      IF (meaningforvalue="YES")
       SET userhasprivsreturnvalue = true
      ELSEIF (meaningforvalue="NO")
       SET userhasprivsreturnvalue = false
      ELSEIF (meaningforvalue="EXCLUDE")
       FOR (nexceptionloop = 1 TO afc_dcp_reply->qual[nrepcount].except_cnt)
         IF ((afc_dcp_reply->qual[nrepcount].excepts[nexceptionloop].exception_entity_name=
         "ACTIVITY TYPE"))
          IF ((dactivitytypecd=afc_dcp_reply->qual[nrepcount].excepts[nexceptionloop].exception_id))
           SET isinexceptionlist = true
          ENDIF
         ENDIF
       ENDFOR
       IF (isinexceptionlist)
        SET userhasprivsreturnvalue = false
       ENDIF
      ELSEIF (meaningforvalue="INCLUDE")
       FOR (nexceptionloop = 1 TO afc_dcp_reply->qual[nrepcount].except_cnt)
         IF ((afc_dcp_reply->qual[nrepcount].excepts[nexceptionloop].exception_entity_name=
         "ACTIVITY TYPE"))
          IF ((dactivitytypecd=afc_dcp_reply->qual[nrepcount].excepts[nexceptionloop].exception_id))
           SET isinexceptionlist = true
          ENDIF
         ENDIF
       ENDFOR
       IF (isinexceptionlist=false)
        SET userhasprivsreturnvalue = false
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   RETURN(userhasprivsreturnvalue)
 END ;Subroutine
 SUBROUTINE (checkbillcodesecurity(billitemid=f8,schedulecd=f8) =i2)
   SET securityreturnvalue = true
   IF (isbillcodesecurityon
    AND trim(request->description)="")
    SET foundsecurityitem = 0
    SELECT INTO "nl:"
     FROM prsnl_org_reltn por,
      cs_org_reltn cor,
      bill_item_modifier bim
     PLAN (por
      WHERE (por.person_id=reqinfo->updt_id)
       AND por.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND por.end_effective_dt_tm > cnvtdatetime(sysdate)
       AND por.active_ind=1)
      JOIN (cor
      WHERE cor.organization_id=por.organization_id
       AND cor.cs_org_reltn_type_cd=cs26078_bc_sched
       AND cor.key1_entity_name="BC_SCHED"
       AND cor.key1_id=schedulecd
       AND cor.active_ind=1)
      JOIN (bim
      WHERE bim.key1_id=cor.key1_id
       AND bim.bill_item_id=billitemid
       AND bim.bill_item_type_cd=cs13019_bill_code_cd
       AND bim.active_ind=1)
     DETAIL
      foundsecurityitem = 1
     WITH nocounter
    ;end select
    IF (foundsecurityitem=0
     AND schedulecd != cs14002_asaschedulecd)
     SET securityreturnvalue = 0
    ENDIF
   ENDIF
   RETURN(securityreturnvalue)
 END ;Subroutine
 SUBROUTINE (checkbillitemsecurity(billitemid=f8) =i2)
   SET securityreturnvalue = true
   IF (isbillitemsecurityon)
    SET foundsecurityitem = 0
    SELECT INTO "nl:"
     FROM prsnl_org_reltn por,
      cs_org_reltn cor
     PLAN (por
      WHERE (por.person_id=reqinfo->updt_id)
       AND por.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND por.end_effective_dt_tm > cnvtdatetime(sysdate)
       AND por.active_ind=1)
      JOIN (cor
      WHERE cor.organization_id=por.organization_id
       AND cor.cs_org_reltn_type_cd=cs26078_bill_item
       AND cor.key1_entity_name="BILL_ITEM"
       AND cor.key1_id=billitemid
       AND cor.active_ind=1)
     DETAIL
      foundsecurityitem = 1
     WITH nocounter
    ;end select
    IF (foundsecurityitem=0)
     SET securityreturnvalue = 0
    ENDIF
   ENDIF
   RETURN(securityreturnvalue)
 END ;Subroutine
 CALL echo("Begin PFT_LOGICAL_DOMAIN_SUBS.INC, version [714452.014 w/o 002,005,007,008,009,010]")
 IF (validate(ld_concept_person)=0)
  DECLARE ld_concept_person = i2 WITH public, constant(1)
 ENDIF
 IF (validate(ld_concept_prsnl)=0)
  DECLARE ld_concept_prsnl = i2 WITH public, constant(2)
 ENDIF
 IF (validate(ld_concept_organization)=0)
  DECLARE ld_concept_organization = i2 WITH public, constant(3)
 ENDIF
 IF (validate(ld_concept_healthplan)=0)
  DECLARE ld_concept_healthplan = i2 WITH public, constant(4)
 ENDIF
 IF (validate(ld_concept_alias_pool)=0)
  DECLARE ld_concept_alias_pool = i2 WITH public, constant(5)
 ENDIF
 IF (validate(ld_concept_minvalue)=0)
  DECLARE ld_concept_minvalue = i2 WITH public, constant(1)
 ENDIF
 IF (validate(ld_concept_maxvalue)=0)
  DECLARE ld_concept_maxvalue = i2 WITH public, constant(5)
 ENDIF
 IF ( NOT (validate(profitlogicaldomaininfo)))
  RECORD profitlogicaldomaininfo(
    1 hasbeenset = i2
    1 logicaldomainid = f8
    1 logicaldomainsystemuserid = f8
  ) WITH persistscript
 ENDIF
 IF ( NOT (validate(ld_concept_batch_trans)))
  DECLARE ld_concept_batch_trans = i2 WITH public, constant(ld_concept_person)
 ENDIF
 IF ( NOT (validate(ld_concept_pft_event)))
  DECLARE ld_concept_pft_event = i2 WITH public, constant(ld_concept_person)
 ENDIF
 IF ( NOT (validate(ld_concept_pft_ruleset)))
  DECLARE ld_concept_pft_ruleset = i2 WITH public, constant(ld_concept_person)
 ENDIF
 IF ( NOT (validate(ld_concept_pft_queue_item_wf_hist)))
  DECLARE ld_concept_pft_queue_item_wf_hist = i2 WITH public, constant(ld_concept_prsnl)
 ENDIF
 IF ( NOT (validate(ld_concept_pft_workflow)))
  DECLARE ld_concept_pft_workflow = i2 WITH public, constant(ld_concept_prsnl)
 ENDIF
 IF ( NOT (validate(ld_entity_account)))
  DECLARE ld_entity_account = vc WITH protect, constant("ACCOUNT")
 ENDIF
 IF ( NOT (validate(ld_entity_adjustment)))
  DECLARE ld_entity_adjustment = vc WITH protect, constant("ADJUSTMENT")
 ENDIF
 IF ( NOT (validate(ld_entity_balance)))
  DECLARE ld_entity_balance = vc WITH protect, constant("BALANCE")
 ENDIF
 IF ( NOT (validate(ld_entity_charge)))
  DECLARE ld_entity_charge = vc WITH protect, constant("CHARGE")
 ENDIF
 IF ( NOT (validate(ld_entity_claim)))
  DECLARE ld_entity_claim = vc WITH protect, constant("CLAIM")
 ENDIF
 IF ( NOT (validate(ld_entity_encounter)))
  DECLARE ld_entity_encounter = vc WITH protect, constant("ENCOUNTER")
 ENDIF
 IF ( NOT (validate(ld_entity_invoice)))
  DECLARE ld_entity_invoice = vc WITH protect, constant("INVOICE")
 ENDIF
 IF ( NOT (validate(ld_entity_payment)))
  DECLARE ld_entity_payment = vc WITH protect, constant("PAYMENT")
 ENDIF
 IF ( NOT (validate(ld_entity_person)))
  DECLARE ld_entity_person = vc WITH protect, constant("PERSON")
 ENDIF
 IF ( NOT (validate(ld_entity_pftencntr)))
  DECLARE ld_entity_pftencntr = vc WITH protect, constant("PFTENCNTR")
 ENDIF
 IF ( NOT (validate(ld_entity_statement)))
  DECLARE ld_entity_statement = vc WITH protect, constant("STATEMENT")
 ENDIF
 IF ( NOT (validate(getlogicaldomain)))
  SUBROUTINE (getlogicaldomain(concept=i4,logicaldomainid=f8(ref)) =i2)
    CALL logmessage("getLogicalDomain","Entering...",log_debug)
    IF (arelogicaldomainsinuse(0))
     IF (((concept < ld_concept_minvalue) OR (concept > ld_concept_maxvalue)) )
      CALL logmessage("getLogicalDomain",build2("Invalid logical domain concept: ",concept),log_error
       )
      RETURN(false)
     ENDIF
     FREE RECORD acm_get_curr_logical_domain_req
     RECORD acm_get_curr_logical_domain_req(
       1 concept = i4
     )
     FREE RECORD acm_get_curr_logical_domain_rep
     RECORD acm_get_curr_logical_domain_rep(
       1 logical_domain_id = f8
       1 status_block
         2 status_ind = i2
         2 error_code = i4
     )
     DECLARE currentuserid = f8 WITH protect, constant(reqinfo->updt_id)
     IF ((profitlogicaldomaininfo->hasbeenset=true))
      SET reqinfo->updt_id = profitlogicaldomaininfo->logicaldomainsystemuserid
     ENDIF
     SET acm_get_curr_logical_domain_req->concept = concept
     EXECUTE acm_get_curr_logical_domain
     SET reqinfo->updt_id = currentuserid
     IF ((acm_get_curr_logical_domain_rep->status_block.status_ind != true))
      CALL logmessage("getLogicalDomain","Failed to retrieve logical domain...",log_error)
      CALL echorecord(acm_get_curr_logical_domain_rep)
      RETURN(false)
     ENDIF
     SET logicaldomainid = acm_get_curr_logical_domain_rep->logical_domain_id
     CALL logmessage("getLogicalDomain",build2("Logical domain for concept [",trim(cnvtstring(concept
         )),"]: ",trim(cnvtstring(logicaldomainid))),log_debug)
     FREE RECORD acm_get_curr_logical_domain_req
     FREE RECORD acm_get_curr_logical_domain_rep
    ELSE
     SET logicaldomainid = 0.0
    ENDIF
    CALL logmessage("getLogicalDomain","Exiting...",log_debug)
    RETURN(true)
  END ;Subroutine
 ENDIF
 SUBROUTINE (getlogicaldomainforentitytype(pentityname=vc,prlogicaldomainid=f8(ref)) =i2)
   DECLARE entityconcept = i4 WITH protect, noconstant(0)
   CASE (pentityname)
    OF value(ld_entity_person,ld_entity_encounter,ld_entity_pftencntr):
     SET entityconcept = ld_concept_person
    OF value(ld_entity_claim,ld_entity_invoice,ld_entity_statement,ld_entity_adjustment,
    ld_entity_charge,
    ld_entity_payment,ld_entity_account,ld_entity_balance):
     SET entityconcept = ld_concept_organization
   ENDCASE
   RETURN(getlogicaldomain(entityconcept,prlogicaldomainid))
 END ;Subroutine
 IF ( NOT (validate(setlogicaldomain)))
  SUBROUTINE (setlogicaldomain(logicaldomainid=f8) =i2)
    CALL logmessage("setLogicalDomain","Entering...",log_debug)
    IF (arelogicaldomainsinuse(0))
     SELECT INTO "nl:"
      FROM logical_domain ld
      WHERE ld.logical_domain_id=logicaldomainid
      DETAIL
       profitlogicaldomaininfo->logicaldomainsystemuserid = ld.system_user_id
      WITH nocounter
     ;end select
     SET profitlogicaldomaininfo->logicaldomainid = logicaldomainid
     SET profitlogicaldomaininfo->hasbeenset = true
     SELECT INTO "nl:"
      FROM prsnl p
      WHERE (p.person_id=reqinfo->updt_id)
      DETAIL
       IF (p.logical_domain_id != logicaldomainid)
        reqinfo->updt_id = profitlogicaldomaininfo->logicaldomainsystemuserid
       ENDIF
      WITH nocounter
     ;end select
     IF (validate(debug,0))
      CALL echorecord(profitlogicaldomaininfo)
      CALL echo(build("reqinfo->updt_id:",reqinfo->updt_id))
     ENDIF
    ENDIF
    CALL logmessage("setLogicalDomain","Exiting...",log_debug)
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF ( NOT (validate(arelogicaldomainsinuse)))
  DECLARE arelogicaldomainsinuse(null) = i2
  SUBROUTINE arelogicaldomainsinuse(null)
    CALL logmessage("areLogicalDomainsInUse","Entering...",log_debug)
    DECLARE multiplelogicaldomainsdefined = i2 WITH protect, noconstant(false)
    SELECT INTO "nl:"
     FROM logical_domain ld
     WHERE ld.logical_domain_id > 0.0
      AND ld.active_ind=true
     WITH nocounter
    ;end select
    IF (curqual > 0)
     SET multiplelogicaldomainsdefined = true
    ENDIF
    CALL logmessage("areLogicalDomainsInUse",build2("Multiple logical domains ",evaluate(
       multiplelogicaldomainsdefined,true,"are","are not")," in use"),log_debug)
    CALL logmessage("areLogicalDomainsInUse","Exiting...",log_debug)
    RETURN(multiplelogicaldomainsdefined)
  END ;Subroutine
 ENDIF
 SUBROUTINE (getparameterentityname(dparmcd=f8) =vc)
   DECLARE parammeaning = vc WITH private, constant(trim(uar_get_code_meaning(dparmcd)))
   DECLARE returnvalue = vc WITH private, noconstant("")
   SET returnvalue = evaluate(parammeaning,"BEID","BILLING_ENTITY","OPTIONALBEID","BILLING_ENTITY",
    "HP ID","HEALTH_PLAN","HP_LIST","HEALTH_PLAN","PRIMARYHP",
    "HEALTH_PLAN","PRIPAYORHPID","HEALTH_PLAN","SECPAYORHPID","HEALTH_PLAN",
    "TERPAYORHPID","HEALTH_PLAN","COLLAGENCY","ORGANIZATION","PAYORORGID",
    "ORGANIZATION","PRECOLAGENCY","ORGANIZATION","PRIPAYORORGI","ORGANIZATION",
    "SECPAYORORGI","ORGANIZATION","TERPAYORORGI","ORGANIZATION","PAYER_LIST",
    "ORGANIZATION","UNKNOWN")
   RETURN(returnvalue)
 END ;Subroutine
 SUBROUTINE (paramsarevalidfordomain(paramstruct=vc(ref),dlogicaldomainid=f8) =i2)
   DECLARE paramidx = i4 WITH private, noconstant(0)
   DECLARE paramentityname = vc WITH private, noconstant("")
   DECLARE paramvalue = f8 WITH protect, noconstant(0.0)
   DECLARE paramerror = i2 WITH protect, noconstant(false)
   FOR (paramidx = 1 TO paramstruct->lparams_qual)
     SET paramentityname = getparameterentityname(paramstruct->aparams[paramidx].dvalue_meaning)
     SET paramvalue = cnvtreal(paramstruct->aparams[paramidx].svalue)
     SET paramerror = true
     IF (paramentityname="BILLING_ENTITY")
      SELECT INTO "nl:"
       FROM billing_entity be,
        organization o
       PLAN (be
        WHERE be.billing_entity_id=paramvalue)
        JOIN (o
        WHERE o.organization_id=be.organization_id
         AND o.logical_domain_id=dlogicaldomainid)
       DETAIL
        paramerror = false
       WITH nocounter
      ;end select
     ELSEIF (paramentityname="HEALTH_PLAN")
      SELECT INTO "nl:"
       FROM health_plan hp
       PLAN (hp
        WHERE hp.health_plan_id=paramvalue
         AND hp.logical_domain_id=dlogicaldomainid)
       DETAIL
        paramerror = false
       WITH nocounter
      ;end select
     ELSEIF (paramentityname="ORGANIZATION")
      SELECT INTO "nl:"
       FROM organization o
       PLAN (o
        WHERE o.organization_id=paramvalue
         AND o.logical_domain_id=dlogicaldomainid)
       DETAIL
        paramerror = false
       WITH nocounter
      ;end select
     ELSE
      SET paramerror = false
     ENDIF
     IF (paramerror)
      RETURN(false)
     ENDIF
   ENDFOR
   RETURN(true)
 END ;Subroutine
 IF ( NOT (validate(getlogicaldomainsystemuser)))
  SUBROUTINE (getlogicaldomainsystemuser(logicaldomainid=f8(ref)) =f8)
    DECLARE systempersonnelid = f8 WITH protect, noconstant(0.0)
    SELECT INTO "nl:"
     FROM logical_domain ld
     WHERE ld.logical_domain_id=logicaldomainid
     DETAIL
      systempersonnelid = ld.system_user_id
     WITH nocounter
    ;end select
    IF (systempersonnelid <= 0.0)
     SELECT INTO "nl:"
      FROM prsnl p
      WHERE p.active_ind=true
       AND p.logical_domain_id=logicaldomainid
       AND p.username="SYSTEM"
      DETAIL
       systempersonnelid = p.person_id
      WITH nocounter
     ;end select
    ENDIF
    IF (systempersonnelid <= 0.0)
     CALL logmessage("getLogicalDomainSystemUser",
      "Failed to determine the default 'SYSTEM' personnel id",log_error)
     RETURN(0.0)
    ENDIF
    CALL logmessage("getLogicalDomainSystemUser","Exiting",log_debug)
    RETURN(systempersonnelid)
  END ;Subroutine
 ENDIF
 IF ( NOT (validate(reply->status_data)))
  FREE RECORD reply
  RECORD reply(
    1 serviceitems[*]
      2 serviceitemid = f8
      2 serviceitemdesc = vc
      2 activitytypedesc = vc
      2 billcode = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE RECORD billitem
 RECORD billitem(
   1 items[*]
     2 billitemid = f8
     2 key1id = f8
     2 activitytypecd = f8
     2 key6 = vc
 )
 FREE RECORD authbillitem
 RECORD authbillitem(
   1 items[*]
     2 billitemid = f8
     2 key6 = vc
 )
 IF ( NOT (validate(cs13019_bill_code_cd)))
  DECLARE cs13019_bill_code_cd = f8 WITH protect, constant(getcodevalue(13019,"BILL CODE",0))
 ENDIF
 IF ( NOT (validate(cs13019_charge_point_cd)))
  DECLARE cs13019_charge_point_cd = f8 WITH protect, constant(getcodevalue(13019,"CHARGE POINT",0))
 ENDIF
 IF ( NOT (validate(cs13016_ord_cat_cd)))
  DECLARE cs13016_ord_cat_cd = f8 WITH protect, constant(getcodevalue(13016,"ORD CAT",0))
 ENDIF
 IF ( NOT (validate(cs13020_group_cd)))
  DECLARE cs13020_group_cd = f8 WITH protect, constant(getcodevalue(13020,"GROUP",0))
 ENDIF
 IF ( NOT (validate(cs13020_both_cd)))
  DECLARE cs13020_both_cd = f8 WITH protect, constant(getcodevalue(13020,"BOTH",0))
 ENDIF
 IF ( NOT (validate(cs13020_detail_now_cd)))
  DECLARE cs13020_detail_now_cd = f8 WITH protect, constant(getcodevalue(13020,"DETAIL_NOW",0))
 ENDIF
 IF ( NOT (validate(cs400_cpt4_cd)))
  DECLARE cs400_cpt4_cd = f8 WITH protect, constant(getcodevalue(400,"CPT4",0))
 ENDIF
 IF ( NOT (validate(cs400_hcpcs_cd)))
  DECLARE cs400_hcpcs_cd = f8 WITH protect, constant(getcodevalue(400,"HCPCS",0))
 ENDIF
 IF ( NOT (validate(cs400_icd9_cd)))
  DECLARE cs400_icd9_cd = f8 WITH protect, constant(getcodevalue(400,"ICD9",0))
 ENDIF
 IF ( NOT (validate(cs400_asa_cd)))
  DECLARE cs400_asa_cd = f8 WITH protect, constant(getcodevalue(400,"ASA",0))
 ENDIF
 IF ( NOT (validate(cs401_procedure_cd)))
  DECLARE cs401_procedure_cd = f8 WITH protect, constant(getcodevalue(401,"PROCEDURE",0))
 ENDIF
 IF ( NOT (validate(cs400_icd10_pcs_cd)))
  DECLARE cs400_icd10_pcs_cd = f8 WITH protect, constant(getcodevalue(400,"ICD10-PCS",0))
 ENDIF
 DECLARE loopbi = i4 WITH public, noconstant(0)
 DECLARE loopitem = i4 WITH public, noconstant(0)
 DECLARE loopauthbi = i4 WITH public, noconstant(0)
 DECLARE searchtype = vc WITH public, noconstant("")
 DECLARE searchstring = vc WITH public, noconstant("")
 DECLARE logicaldomainid = f8 WITH public, noconstant(0.0)
 DECLARE cap_plus = i4 WITH protect, noconstant(0)
 DECLARE servicedttm = dq8 WITH protect, noconstant(cnvtdatetime(sysdate))
 CALL beginservice("495794.011")
 CALL logmessage("Main","Begining main processing",log_debug)
 IF (initializebillitemsecurity(0)=false)
  CALL exitservicefailure("Bill item security initialization failed.",go_to_exit_script)
 ENDIF
 IF ( NOT (getlogicaldomain(ld_concept_organization,logicaldomainid)))
  CALL exitservicefailure("Failed to retrieve logical domain ID.",go_to_exit_script)
 ENDIF
 IF (validate(request->servicedttm,0.0) > 0.0)
  SET servicedttm = cnvtdatetime(request->servicedttm)
 ENDIF
 IF (trim(request->cptsearch) != "")
  CALL logmessage("Main",build("Search by cpt/hcpcs code: ",request->cptsearch),log_debug)
  SET searchtype = "CPT4"
  SET searchstring = concat('n.source_identifier_keycap = "',cnvtupper(trim(request->cptsearch)),'"')
 ELSEIF (trim(request->icdsearch) != "")
  CALL logmessage("Main",build("Search by ICD code: ",request->icdsearch),log_debug)
  SET searchtype = "PROCCODE"
  SET searchstring = concat('n.source_identifier_keycap = "',cnvtupper(trim(request->icdsearch)),'"')
 ELSEIF (trim(request->cdmsearch) != "")
  CALL logmessage("Main",build("Search by CDM code: ",request->cdmsearch),log_debug)
  SET searchtype = "CDM_SCHED"
  SET searchstring = concat('cnvtupper(bim.key6) = "',cnvtupper(trim(request->cdmsearch)),'"')
 ELSEIF (trim(request->asasearch) != "")
  CALL logmessage("Main",build("Search by ASA code: ",request->asasearch),log_debug)
  SET searchtype = "ASA"
  SET searchstring = concat('n.source_identifier_keycap = "',cnvtupper(trim(request->asasearch)),'"')
 ELSEIF (trim(request->description) != "")
  CALL logmessage("Main",build("Search by Description: ",request->description),log_debug)
  SET searchstring = concat('cnvtupper(b.ext_description) = "',cnvtupper(trim(request->description)),
   '"')
 ELSE
  CALL exitservicenodata("No search string sent",go_to_exit_script)
 ENDIF
 IF (((trim(request->cptsearch) != "") OR (((trim(request->icdsearch) != "") OR (trim(request->
  asasearch) != "")) )) )
  SELECT
   IF (trim(request->cptsearch) != "")
    PLAN (n
     WHERE n.nomenclature_id > 0.0
      AND parser(searchstring)
      AND n.source_vocabulary_cd IN (cs400_cpt4_cd, cs400_hcpcs_cd)
      AND n.beg_effective_dt_tm <= cnvtdatetime(servicedttm)
      AND n.end_effective_dt_tm > cnvtdatetime(servicedttm)
      AND n.active_ind=1)
     JOIN (bim
     WHERE bim.bill_item_type_cd=cs13019_bill_code_cd
      AND  EXISTS (
     (SELECT
      cv.code_value
      FROM code_value cv
      WHERE cv.code_value=bim.key1_id
       AND cv.code_set=14002
       AND cv.cdf_meaning IN ("CPT4", "HCPCS")
       AND cv.active_ind=1))
      AND bim.key3_id=n.nomenclature_id
      AND ((bim.bim1_int=1) OR (bim.key2_id=1))
      AND bim.active_ind=1)
     JOIN (b
     WHERE b.bill_item_id=bim.bill_item_id
      AND ((b.ext_child_reference_id=0) OR (b.ext_child_reference_id != 0
      AND b.ext_child_contributor_cd=cs13016_ord_cat_cd))
      AND ((b.logical_domain_id=logicaldomainid
      AND b.logical_domain_enabled_ind=true) OR (b.logical_domain_enabled_ind=false))
      AND b.active_ind=1)
   ELSEIF (trim(request->asasearch) != "")
    PLAN (n
     WHERE n.nomenclature_id > 0.0
      AND parser(searchstring)
      AND n.source_vocabulary_cd=cs400_asa_cd
      AND n.beg_effective_dt_tm <= cnvtdatetime(servicedttm)
      AND n.end_effective_dt_tm > cnvtdatetime(servicedttm)
      AND n.active_ind=1)
     JOIN (bim
     WHERE bim.bill_item_type_cd=cs13019_bill_code_cd
      AND  EXISTS (
     (SELECT
      cv.code_value
      FROM code_value cv
      WHERE cv.code_value=bim.key1_id
       AND cv.code_set=14002
       AND cv.cdf_meaning="ASA"
       AND cv.active_ind=1))
      AND bim.key3_id=n.nomenclature_id
      AND ((bim.bim1_int=1) OR (bim.key2_id=1))
      AND bim.active_ind=1)
     JOIN (b
     WHERE b.bill_item_id=bim.bill_item_id
      AND ((b.ext_child_reference_id=0) OR (b.ext_child_reference_id != 0
      AND b.ext_child_contributor_cd=cs13016_ord_cat_cd))
      AND ((b.logical_domain_id=logicaldomainid
      AND b.logical_domain_enabled_ind=true) OR (b.logical_domain_enabled_ind=false))
      AND b.active_ind=1)
   ELSE
    PLAN (n
     WHERE n.nomenclature_id > 0.0
      AND parser(searchstring)
      AND n.source_vocabulary_cd IN (cs400_icd9_cd, cs400_icd10_pcs_cd)
      AND n.principle_type_cd=cs401_procedure_cd
      AND n.beg_effective_dt_tm <= cnvtdatetime(servicedttm)
      AND n.end_effective_dt_tm > cnvtdatetime(servicedttm)
      AND n.active_ind=1)
     JOIN (bim
     WHERE bim.bill_item_type_cd=cs13019_bill_code_cd
      AND  EXISTS (
     (SELECT
      cv.code_value
      FROM code_value cv
      WHERE cv.code_value=bim.key1_id
       AND cv.code_set=14002
       AND cv.cdf_meaning=searchtype
       AND cv.active_ind=1))
      AND bim.key3_id=n.nomenclature_id
      AND ((bim.bim1_int=1) OR (bim.key2_id=1))
      AND bim.active_ind=1)
     JOIN (b
     WHERE b.bill_item_id=bim.bill_item_id
      AND ((b.ext_child_reference_id=0) OR (b.ext_child_reference_id != 0
      AND b.ext_child_contributor_cd=cs13016_ord_cat_cd))
      AND ((b.logical_domain_id=logicaldomainid
      AND b.logical_domain_enabled_ind=true) OR (b.logical_domain_enabled_ind=false))
      AND b.active_ind=1)
   ENDIF
   INTO "nl:"
   FROM nomenclature n,
    bill_item b,
    bill_item_modifier bim
   DETAIL
    IF (validate(request->activitytypecd,0.0) > 0.0)
     IF ((b.ext_owner_cd=request->activitytypecd))
      loopitem += 1, stat = alterlist(billitem->items,loopitem), billitem->items[loopitem].billitemid
       = bim.bill_item_id,
      billitem->items[loopitem].key1id = bim.key1_id, billitem->items[loopitem].activitytypecd = b
      .ext_owner_cd, billitem->items[loopitem].key6 = bim.key6
     ENDIF
    ELSE
     loopitem += 1, stat = alterlist(billitem->items,loopitem), billitem->items[loopitem].billitemid
      = bim.bill_item_id,
     billitem->items[loopitem].key1id = bim.key1_id, billitem->items[loopitem].activitytypecd = b
     .ext_owner_cd, billitem->items[loopitem].key6 = bim.key6
    ENDIF
   WITH nocounter
  ;end select
 ELSEIF (trim(request->cdmsearch) != "")
  SELECT INTO "nl:"
   FROM bill_item_modifier bim,
    bill_item b
   PLAN (bim
    WHERE bim.bill_item_type_cd=cs13019_bill_code_cd
     AND  EXISTS (
    (SELECT
     cv.code_value
     FROM code_value cv
     WHERE cv.code_value=bim.key1_id
      AND cv.code_set=14002
      AND cv.cdf_meaning=searchtype
      AND cv.active_ind=1))
     AND parser(searchstring)
     AND ((bim.bim1_int=1) OR (bim.key2_id=1))
     AND bim.active_ind=1)
    JOIN (b
    WHERE b.bill_item_id=bim.bill_item_id
     AND ((b.ext_child_reference_id=0) OR (b.ext_child_reference_id != 0
     AND b.ext_child_contributor_cd=cs13016_ord_cat_cd))
     AND ((b.logical_domain_id=logicaldomainid
     AND b.logical_domain_enabled_ind=true) OR (b.logical_domain_enabled_ind=false))
     AND b.active_ind=1)
   DETAIL
    IF (validate(request->activitytypecd,0.0) > 0.0)
     IF ((b.ext_owner_cd=request->activitytypecd))
      loopitem += 1, stat = alterlist(billitem->items,loopitem), billitem->items[loopitem].billitemid
       = bim.bill_item_id,
      billitem->items[loopitem].key1id = bim.key1_id, billitem->items[loopitem].activitytypecd = b
      .ext_owner_cd, billitem->items[loopitem].key6 = bim.key6
     ENDIF
    ELSE
     loopitem += 1, stat = alterlist(billitem->items,loopitem), billitem->items[loopitem].billitemid
      = bim.bill_item_id,
     billitem->items[loopitem].key1id = bim.key1_id, billitem->items[loopitem].activitytypecd = b
     .ext_owner_cd, billitem->items[loopitem].key6 = bim.key6
    ENDIF
   WITH nocounter
  ;end select
 ELSE
  IF (validate(request->maxlistsize))
   IF ((request->maxlistsize != 0))
    SET cap_plus = request->maxlistsize
   ELSE
    SET cap_plus = 100
   ENDIF
   SELECT INTO "nl:"
    FROM bill_item b
    WHERE b.bill_item_id != 0.0
     AND b.active_ind=1
     AND parser(searchstring)
     AND ((b.logical_domain_id=logicaldomainid
     AND b.logical_domain_enabled_ind=true) OR (b.logical_domain_enabled_ind=false))
    DETAIL
     IF (validate(request->activitytypecd,0.0) > 0.0)
      IF ((b.ext_owner_cd=request->activitytypecd))
       loopitem += 1, stat = alterlist(billitem->items,loopitem), billitem->items[loopitem].
       billitemid = b.bill_item_id,
       billitem->items[loopitem].activitytypecd = b.ext_owner_cd
      ENDIF
     ELSE
      loopitem += 1, stat = alterlist(billitem->items,loopitem), billitem->items[loopitem].billitemid
       = b.bill_item_id,
      billitem->items[loopitem].activitytypecd = b.ext_owner_cd
     ENDIF
    WITH nocounter, maxqual(b,value(cap_plus))
   ;end select
  ELSE
   SELECT INTO "nl:"
    FROM bill_item b
    WHERE b.bill_item_id != 0.0
     AND b.active_ind=1
     AND parser(searchstring)
     AND ((b.logical_domain_id=logicaldomainid
     AND b.logical_domain_enabled_ind=true) OR (b.logical_domain_enabled_ind=false))
    DETAIL
     IF (validate(request->activitytypecd,0.0) > 0.0)
      IF ((b.ext_owner_cd=request->activitytypecd))
       loopitem += 1, stat = alterlist(billitem->items,loopitem), billitem->items[loopitem].
       billitemid = b.bill_item_id,
       billitem->items[loopitem].activitytypecd = b.ext_owner_cd
      ENDIF
     ELSE
      loopitem += 1, stat = alterlist(billitem->items,loopitem), billitem->items[loopitem].billitemid
       = b.bill_item_id,
      billitem->items[loopitem].activitytypecd = b.ext_owner_cd
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 CALL echorecord(billitem)
 IF (loopitem=0)
  CALL exitservicenodata("No matching service items",go_to_exit_script)
 ENDIF
 FOR (loopbi = 1 TO loopitem)
   IF (checkbillcodesecurity(billitem->items[loopbi].billitemid,billitem->items[loopbi].key1id))
    IF (checkbillitemsecurity(billitem->items[loopbi].billitemid))
     IF (checkactivitytypeprivs(billitem->items[loopbi].activitytypecd))
      SET loopauthbi += 1
      SET stat = alterlist(authbillitem->items,loopauthbi)
      SET authbillitem->items[loopauthbi].billitemid = billitem->items[loopbi].billitemid
      SET authbillitem->items[loopauthbi].key6 = billitem->items[loopbi].key6
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 SET loopbi = 0
 IF (loopauthbi=0)
  CALL exitservicenodata("No matching service items",go_to_exit_script)
 ENDIF
 SELECT INTO "nl:"
  FROM bill_item b,
   bill_item_modifier bim,
   (dummyt d1  WITH seq = value(size(authbillitem->items,5)))
  PLAN (d1)
   JOIN (b
   WHERE (b.bill_item_id=authbillitem->items[d1.seq].billitemid))
   JOIN (bim
   WHERE bim.bill_item_id=b.bill_item_id
    AND bim.bill_item_type_cd=cs13019_charge_point_cd
    AND bim.key4_id IN (cs13020_group_cd, cs13020_both_cd, cs13020_detail_now_cd)
    AND bim.active_ind=1)
  ORDER BY b.ext_description
  HEAD b.bill_item_id
   loopbi += 1, stat = alterlist(reply->serviceitems,loopbi), reply->serviceitems[loopbi].
   serviceitemid = b.bill_item_id,
   reply->serviceitems[loopbi].serviceitemdesc = b.ext_description,
   CALL fillbillcode(0), reply->serviceitems[loopbi].activitytypedesc = uar_get_code_display(b
    .ext_owner_cd)
  DETAIL
   null
  WITH nocounter
 ;end select
 IF (loopbi > 0)
  CALL exitservicesuccess("")
 ELSE
  CALL exitservicenodata("No bill item found",go_to_exit_script)
 ENDIF
 CALL logmessage("Main","Exiting script",log_debug)
 SUBROUTINE fillbillcode(dummyvar)
   IF (validate(reply->serviceitems[loopbi].billcode))
    SET reply->serviceitems[loopbi].billcode = authbillitem->items[d1.seq].key6
   ENDIF
 END ;Subroutine
#exit_script
 FREE RECORD billitem
 IF (validate(debug,0)=1)
  CALL echorecord(reply)
 ENDIF
END GO
