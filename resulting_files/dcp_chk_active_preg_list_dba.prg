CREATE PROGRAM dcp_chk_active_preg_list:dba
 SET modify = predeclare
 RECORD reply(
   1 patient_list[*]
     2 patient_id = f8
     2 pregnancy_id = f8
     2 encntr_id = f8
     2 org_id = f8
     2 chart_access_org_id = f8
     2 pregnancy_instance_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH persistscript
 RECORD temp_patient(
   1 patient_list[*]
     2 patient_id = f8
     2 encntr_id = f8
     2 org_id = f8
     2 chart_access_org_id = f8
 )
 SUBROUTINE (reportfailure(opname=vc,opstatus=vc,targetname=vc,targetvalue=vc) =null)
  SET reply->status_data.status = "F"
  CALL fillsubeventstatus(opname,opstatus,targetname,targetvalue)
 END ;Subroutine
 SUBROUTINE (fillsubeventstatus(opname=vc,opstatus=vc,objname=vc,objvalue=vc) =null)
   DECLARE dcp_substatus_cnt = i4 WITH protect, noconstant(size(reply->status_data.subeventstatus,5))
   SET dcp_substatus_cnt += 1
   IF (dcp_substatus_cnt != 1)
    SET stat = alter(reply->status_data.subeventstatus,dcp_substatus_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].operationname = trim(opname)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].targetobjectname = trim(objname)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].targetobjectvalue = trim(objvalue)
 END ;Subroutine
 SET reply->status_data.status = "F"
 DECLARE patientcnt1 = i4 WITH public, noconstant(size(request->patient_list,5))
 DECLARE num = i4 WITH protect, noconstant(1)
 DECLARE org_num = i4 WITH protect, noconstant(1)
 DECLARE total_result_cnt = i4 WITH protect, noconstant(0)
 DECLARE expand_size = i4 WITH protect, constant(20)
 DECLARE expand_start = i4 WITH protect, noconstant(1)
 DECLARE expand_stop = i4 WITH protect, noconstant(20)
 DECLARE expand_total = i4 WITH protect, noconstant(0)
 DECLARE stat1 = i4 WITH protected, noconstant(0)
 DECLARE person_preg_multiple_ind = i2 WITH protected, noconstant(0)
 DECLARE error_msg = vc WITH protect, noconstant("")
 DECLARE error_cd = i2 WITH protect, noconstant(0)
 DECLARE debug_ind = i2 WITH protect, noconstant(0)
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
 DECLARE crsl_msg_default = i4 WITH protect, noconstant(0)
 DECLARE crsl_msg_level = i4 WITH protect, noconstant(0)
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
 DECLARE crsl_info_domain = vc WITH protect, constant("DISCERNABU SCRIPT LOGGING")
 DECLARE crsl_logging_on = c1 WITH protect, constant("L")
 IF (((logical("MP_LOGGING_ALL") > " ") OR (logical(concat("MP_LOGGING_",log_program_name)) > " ")) )
  SET log_override_ind = 1
 ENDIF
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
     IF (validate(reply))
      SET reply->status_data.status = "F"
     ENDIF
     CALL log_message(serrmsg,log_level_audit)
     IF (logstatusblockind=1)
      IF (validate(reply))
       CALL populate_subeventstatus("EXECUTE","F","CCL SCRIPT",serrmsg)
      ENDIF
     ENDIF
     SET ierrcode = error(serrmsg,0)
   ENDWHILE
   RETURN(icrslerroroccured)
 END ;Subroutine
 SUBROUTINE (error_and_zero_check_rec(qualnum=i4,opname=vc,logmsg=vc,errorforceexit=i2,zeroforceexit=
  i2,recorddata=vc(ref)) =i2)
   SET icrslerroroccured = 0
   SET ierrcode = error(serrmsg,0)
   WHILE (ierrcode > 0)
     SET icrslerroroccured = 1
     CALL log_message(serrmsg,log_level_audit)
     CALL populate_subeventstatus_rec(opname,"F",serrmsg,logmsg,recorddata)
     SET ierrcode = error(serrmsg,0)
   ENDWHILE
   IF (icrslerroroccured=1
    AND errorforceexit=1)
    SET recorddata->status_data.status = "F"
    GO TO exit_script
   ENDIF
   IF (qualnum=0
    AND zeroforceexit=1)
    SET recorddata->status_data.status = "Z"
    CALL populate_subeventstatus_rec(opname,"Z","No records qualified",logmsg,recorddata)
    GO TO exit_script
   ENDIF
   RETURN(icrslerroroccured)
 END ;Subroutine
 SUBROUTINE (error_and_zero_check(qualnum=i4,opname=vc,logmsg=vc,errorforceexit=i2,zeroforceexit=i2
  ) =i2)
   RETURN(error_and_zero_check_rec(qualnum,opname,logmsg,errorforceexit,zeroforceexit,
    reply))
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus_rec(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value),recorddata=vc(ref)) =i2)
   IF (validate(recorddata->status_data.status,"-1") != "-1")
    SET lcrslsubeventcnt = size(recorddata->status_data.subeventstatus,5)
    SET lcrslsubeventsize = size(trim(recorddata->status_data.subeventstatus[lcrslsubeventcnt].
      operationname))
    SET lcrslsubeventsize += size(trim(recorddata->status_data.subeventstatus[lcrslsubeventcnt].
      operationstatus))
    SET lcrslsubeventsize += size(trim(recorddata->status_data.subeventstatus[lcrslsubeventcnt].
      targetobjectname))
    SET lcrslsubeventsize += size(trim(recorddata->status_data.subeventstatus[lcrslsubeventcnt].
      targetobjectvalue))
    IF (lcrslsubeventsize > 0)
     SET lcrslsubeventcnt += 1
     SET icrslloggingstat = alter(recorddata->status_data.subeventstatus,lcrslsubeventcnt)
    ENDIF
    SET recorddata->status_data.subeventstatus[lcrslsubeventcnt].operationname = substring(1,25,
     operationname)
    SET recorddata->status_data.subeventstatus[lcrslsubeventcnt].operationstatus = substring(1,1,
     operationstatus)
    SET recorddata->status_data.subeventstatus[lcrslsubeventcnt].targetobjectname = substring(1,25,
     targetobjectname)
    SET recorddata->status_data.subeventstatus[lcrslsubeventcnt].targetobjectvalue =
    targetobjectvalue
   ENDIF
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value)) =i2)
   CALL populate_subeventstatus_rec(operationname,operationstatus,targetobjectname,targetobjectvalue,
    reply)
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
 DECLARE loadpregnancyorganizationsecuritylist() = null
 IF (validate(preg_org_sec_ind)=0)
  DECLARE preg_org_sec_ind = i4 WITH noconstant(0)
  SELECT INTO "nl:"
   FROM dm_info d1,
    dm_info d2
   WHERE d1.info_domain="SECURITY"
    AND d1.info_name="SEC_ORG_RELTN"
    AND d1.info_number=1
    AND d2.info_domain="SECURITY"
    AND d2.info_name="SEC_PREG_ORG_RELTN"
    AND d2.info_number=1
   DETAIL
    preg_org_sec_ind = 1
   WITH nocounter
  ;end select
  CALL echo(build("preg_org_sec_ind=",preg_org_sec_ind))
  IF (preg_org_sec_ind=1)
   FREE RECORD preg_sec_orgs
   RECORD preg_sec_orgs(
     1 qual[*]
       2 org_id = f8
       2 confid_level = i4
   )
   CALL loadpregnancyorganizationsecuritylist(null)
  ENDIF
 ENDIF
 SUBROUTINE loadpregnancyorganizationsecuritylist(null)
   DECLARE org_cnt = i2 WITH noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (validate(sac_org)=1)
    FREE RECORD sac_org
   ENDIF
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
   SET org_cnt = size(sac_org->organizations,5)
   CALL echo(build("org_cnt: ",org_cnt))
   SET stat = alterlist(preg_sec_orgs->qual,(org_cnt+ 1))
   FOR (count = 1 TO org_cnt)
    SET preg_sec_orgs->qual[count].org_id = sac_org->organizations[count].organization_id
    SET preg_sec_orgs->qual[count].confid_level = sac_org->organizations[count].confid_level
   ENDFOR
   SET preg_sec_orgs->qual[(org_cnt+ 1)].org_id = 0.00
   SET preg_sec_orgs->qual[(org_cnt+ 1)].confid_level = 0
 END ;Subroutine
 RECORD encounters(
   1 encounter_ids[*]
     2 encounter_id = f8
 )
 SUBROUTINE (getallpregencounters(person_id=f8(val),encounters=vc(ref)) =null WITH protect)
   CALL log_message("In GetAllPregEncounters()",log_level_debug)
   DECLARE lcnt = i4 WITH protect, noconstant(0)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   IF (preg_org_sec_ind=0)
    SELECT INTO "nl:"
     FROM encounter e
     WHERE e.person_id=person_id
      AND e.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND ((e.end_effective_dt_tm+ 0) > cnvtdatetime(sysdate))
      AND ((e.active_ind+ 0)=1)
      AND ((e.organization_id+ 0) > 0.0)
     DETAIL
      lcnt += 1
      IF (mod(lcnt,10)=1)
       lstat = alterlist(encounters->encounter_ids,(lcnt+ 9))
      ENDIF
      encounters->encounter_ids[lcnt].encounter_id = e.encntr_id
     WITH nocounter
    ;end select
    SET stat = alterlist(encounters->encounter_ids,lcnt)
   ENDIF
   CALL log_message(build("Exit GetAllPregEncounters(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (getpregpreferences(preferencename=vc(val)) =vc WITH protect)
   CALL log_message("In GetPregPreferences()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE preferencevalue = vc WITH noconstant(""), protect
   RECORD pregnancy_event_sets(
     1 qual[*]
       2 pref_entry_name = vc
       2 event_set_name = vc
   )
   DECLARE stat = i2 WITH protect, noconstant(0)
   DECLARE hpref = i4 WITH private, noconstant(0)
   DECLARE hgroup = i4 WITH private, noconstant(0)
   DECLARE hrepgroup = i4 WITH private, noconstant(0)
   DECLARE hsection = i4 WITH private, noconstant(0)
   DECLARE hattr = i4 WITH private, noconstant(0)
   DECLARE hentry = i4 WITH private, noconstant(0)
   DECLARE lentrycnt = i4 WITH private, noconstant(0)
   DECLARE lentryidx = i4 WITH private, noconstant(0)
   DECLARE ilen = i4 WITH private, noconstant(255)
   DECLARE lattrcnt = i4 WITH private, noconstant(0)
   DECLARE lattridx = i4 WITH private, noconstant(0)
   DECLARE lvalcnt = i4 WITH private, noconstant(0)
   DECLARE sentryname = c255 WITH private, noconstant("")
   DECLARE sattrname = c255 WITH private, noconstant("")
   DECLARE sval = c255 WITH private, noconstant("")
   DECLARE sentryval = c255 WITH private, noconstant("")
   DECLARE tempdeldate = dq8 WITH private, noconstant(0)
   DECLARE deldate = dq8 WITH private, noconstant(0)
   CALL echo("Entering GetPregPreferences subroutine")
   EXECUTE prefrtl
   SET hpref = uar_prefcreateinstance(0)
   SET stat = uar_prefaddcontext(hpref,nullterm("default"),nullterm("system"))
   SET stat = uar_prefsetsection(hpref,nullterm("component"))
   SET hgroup = uar_prefcreategroup()
   SET stat = uar_prefsetgroupname(hgroup,nullterm("Pregnancy"))
   SET stat = uar_prefaddgroup(hpref,hgroup)
   SET stat = uar_prefperform(hpref)
   SET hsection = uar_prefgetsectionbyname(hpref,nullterm("component"))
   SET hrepgroup = uar_prefgetgroupbyname(hsection,nullterm("Pregnancy"))
   SET stat = uar_prefgetgroupentrycount(hrepgroup,lentrycnt)
   FOR (lentryidx = 0 TO (lentrycnt - 1))
     SET hentry = uar_prefgetgroupentry(hrepgroup,lentryidx)
     SET ilen = 255
     SET sentryname = ""
     SET sentryval = ""
     SET stat = uar_prefgetentryname(hentry,sentryname,ilen)
     IF (sentryname=preferencename)
      SET lattrcnt = 0
      SET stat = uar_prefgetentryattrcount(hentry,lattrcnt)
      FOR (lattridx = 0 TO (lattrcnt - 1))
        SET hattr = uar_prefgetentryattr(hentry,lattridx)
        SET ilen = 255
        SET sattrname = ""
        SET stat = uar_prefgetattrname(hattr,sattrname,ilen)
        IF (sattrname="prefvalue")
         SET lvalcnt = 0
         SET stat = uar_prefgetattrvalcount(hattr,lvalcnt)
         IF (lvalcnt > 0)
          SET sval = ""
          SET ilen = 255
          SET stat = uar_prefgetattrval(hattr,sval,ilen,0)
          SET preferencevalue = trim(sval)
         ENDIF
         SET lattridx = lattrcnt
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
   CALL uar_prefdestroysection(hsection)
   CALL uar_prefdestroygroup(hgroup)
   CALL uar_prefdestroyinstance(hpref)
   CALL log_message(build("Exit GetPregPreferences(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
   RETURN(preferencevalue)
 END ;Subroutine
 RECORD accessible_encntr_person_ids(
   1 person_ids[*]
     2 person_id = f8
 ) WITH public
 RECORD accessible_encntr_ids(
   1 accessible_encntrs_cnt = i4
   1 accessible_encntrs[*]
     2 accessible_encntr_id = f8
 ) WITH public
 RECORD accessible_encntr_ids_maps(
   1 persons_cnt = i4
   1 persons[*]
     2 person_id = f8
     2 accessible_encntrs_cnt = i4
     2 accessible_encntrs[*]
       3 accessible_encntr_id = f8
 ) WITH public
 DECLARE getaccessibleencntrerrormsg = vc WITH protect
 DECLARE getaccessibleencntrtoggleerrormsg = vc WITH protect
 DECLARE h3202611srvmsg = i4 WITH noconstant(0), protect
 DECLARE h3202611srvreq = i4 WITH noconstant(0), protect
 DECLARE h3202611srvrep = i4 WITH noconstant(0), protect
 DECLARE hsys = i4 WITH noconstant(0), protect
 DECLARE sysstat = i4 WITH noconstant(0), protect
 DECLARE slogtext = vc WITH noconstant(""), protect
 DECLARE access_encntr_req_number = i4 WITH constant(3202611), protect
 SUBROUTINE (get_accessible_encntr_ids_by_person_id(person_id=f8,concept=vc,
  disable_access_security_ind=i2(value,0)) =i4)
   SET h3202611srvmsg = uar_srvselectmessage(access_encntr_req_number)
   IF (h3202611srvmsg=0)
    SET getaccessibleencntrerrormsg = build2("*** Failed to select message ",build(
      access_encntr_req_number))
    RETURN(1)
   ENDIF
   SET h3202611srvreq = uar_srvcreaterequest(h3202611srvmsg)
   IF (h3202611srvreq=0)
    SET getaccessibleencntrerrormsg = build2("*** Failed to create request ",build(
      access_encntr_req_number))
    RETURN(1)
   ENDIF
   SET h3202611srvrep = uar_srvcreatereply(h3202611srvmsg)
   IF (h3202611srvrep=0)
    SET getaccessibleencntrerrormsg = build2("*** Failed to create reply ",build(
      access_encntr_req_number))
    RETURN(1)
   ENDIF
   DECLARE e_count = i4 WITH noconstant(0), protect
   DECLARE encounter_count = i4 WITH noconstant(0), protect
   DECLARE htransactionstatus = i4 WITH noconstant(0), protect
   DECLARE hencounter = i4 WITH noconstant(0), protect
   SET stat = uar_srvsetdouble(h3202611srvreq,"patientId",person_id)
   IF (disable_access_security_ind=0)
    SET stat = uar_srvsetstring(h3202611srvreq,"concept",nullterm(concept))
   ELSE
    SET stat = uar_srvsetstring(h3202611srvreq,"concept",nullterm("No_Security"))
   ENDIF
   SET stat = uar_srvexecute(h3202611srvmsg,h3202611srvreq,h3202611srvrep)
   IF (stat=0)
    SET htransactionstatus = uar_srvgetstruct(h3202611srvrep,"transactionStatus")
    IF (htransactionstatus=0)
     SET getaccessibleencntrerrormsg = build2("Failed to get transaction status from reply of ",build
      (access_encntr_req_number))
     RETURN(1)
    ELSE
     IF (uar_srvgetshort(htransactionstatus,"successIndicator") != 1)
      SET getaccessibleencntrerrormsg = build2("Failure for call to ",build(access_encntr_req_number),
       ". Debug Msg =",uar_srvgetstringptr(htransactionstatus,"debugErrorMessage"))
      RETURN(1)
     ELSE
      SET encounter_count = uar_srvgetitemcount(h3202611srvrep,"encounterIds")
      SET stat = alterlist(accessible_encntr_ids->accessible_encntrs,encounter_count)
      SET accessible_encntr_ids->accessible_encntrs_cnt = encounter_count
      FOR (e_count = 1 TO encounter_count)
       SET hencounter = uar_srvgetitem(h3202611srvrep,"encounterIds",(e_count - 1))
       SET accessible_encntr_ids->accessible_encntrs[e_count].accessible_encntr_id = uar_srvgetdouble
       (hencounter,"encounterId")
      ENDFOR
     ENDIF
    ENDIF
    RETURN(0)
   ELSE
    SET getaccessibleencntrerrormsg = build2("Failure for call to ",build(access_encntr_req_number))
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE (get_accessible_encntr_ids_by_person_ids(accessible_encntr_person_ids=vc(ref),concept=vc,
  disable_access_security_ind=i2(value,0),user_id=f8(value,0.0)) =i4)
   SET h3202611srvmsg = uar_srvselectmessage(access_encntr_req_number)
   IF (h3202611srvmsg=0)
    SET getaccessibleencntrerrormsg = build2("*** Failed to select message ",build(
      access_encntr_req_number))
    RETURN(1)
   ENDIF
   SET h3202611srvreq = uar_srvcreaterequest(h3202611srvmsg)
   IF (h3202611srvreq=0)
    SET getaccessibleencntrerrormsg = build2("*** Failed to create request ",build(
      access_encntr_req_number))
    RETURN(1)
   ENDIF
   SET h3202611srvrep = uar_srvcreatereply(h3202611srvmsg)
   IF (h3202611srvrep=0)
    SET getaccessibleencntrerrormsg = build2("*** Failed to create reply ",build(
      access_encntr_req_number))
    RETURN(1)
   ENDIF
   DECLARE p_count = i4 WITH noconstant(0), protect
   DECLARE person_count = i4 WITH noconstant(0), protect
   DECLARE e_count = i4 WITH noconstant(0), protect
   DECLARE encounter_count = i4 WITH noconstant(0), protect
   DECLARE htransactionstatus = i4 WITH noconstant(0), protect
   DECLARE hencounter = i4 WITH noconstant(0), protect
   DECLARE curr_encntr_cnt = i4 WITH noconstant(0), protect
   DECLARE prev_encntr_cnt = i4 WITH noconstant(0), protect
   SET person_count = size(accessible_encntr_person_ids->person_ids,5)
   FOR (p_count = 1 TO person_count)
     SET stat = uar_srvsetdouble(h3202611srvreq,"patientId",accessible_encntr_person_ids->person_ids[
      p_count].person_id)
     IF (disable_access_security_ind=0)
      SET stat = uar_srvsetstring(h3202611srvreq,"concept",nullterm(concept))
     ELSE
      SET stat = uar_srvsetstring(h3202611srvreq,"concept",nullterm("No_Security"))
     ENDIF
     SET stat = uar_srvsetdouble(h3202611srvreq,"userId",user_id)
     SET stat = uar_srvexecute(h3202611srvmsg,h3202611srvreq,h3202611srvrep)
     IF (stat=0)
      SET htransactionstatus = uar_srvgetstruct(h3202611srvrep,"transactionStatus")
      IF (htransactionstatus=0)
       SET getaccessibleencntrerrormsg = build2("Failed to get transaction status from reply of ",
        build(access_encntr_req_number))
       RETURN(1)
      ELSE
       IF (uar_srvgetshort(htransactionstatus,"successIndicator") != 1)
        SET getaccessibleencntrerrormsg = build2("Failure for call to ",build(
          access_encntr_req_number),". Debug Msg =",uar_srvgetstringptr(htransactionstatus,
          "debugErrorMessage"))
        RETURN(1)
       ELSE
        SET encounter_count = uar_srvgetitemcount(h3202611srvrep,"encounterIds")
        SET prev_encntr_cnt = curr_encntr_cnt
        SET curr_encntr_cnt += encounter_count
        SET stat = alterlist(accessible_encntr_ids->accessible_encntrs,curr_encntr_cnt)
        SET accessible_encntr_ids->accessible_encntrs_cnt = curr_encntr_cnt
        FOR (e_count = 1 TO encounter_count)
         SET hencounter = uar_srvgetitem(h3202611srvrep,"encounterIds",(e_count - 1))
         SET accessible_encntr_ids->accessible_encntrs[(e_count+ prev_encntr_cnt)].
         accessible_encntr_id = uar_srvgetdouble(hencounter,"encounterId")
        ENDFOR
       ENDIF
      ENDIF
     ELSE
      SET getaccessibleencntrerrormsg = build2("Failure for call to ",build(access_encntr_req_number)
       )
      RETURN(1)
     ENDIF
   ENDFOR
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (get_accessible_encntr_ids_by_person_ids_map(accessible_encntr_person_ids=vc(ref),concept
  =vc,disable_access_security_ind=i2(value,0)) =i4)
   SET h3202611srvmsg = uar_srvselectmessage(access_encntr_req_number)
   IF (h3202611srvmsg=0)
    SET getaccessibleencntrerrormsg = build2("*** Failed to select message ",build(
      access_encntr_req_number))
    RETURN(1)
   ENDIF
   SET h3202611srvreq = uar_srvcreaterequest(h3202611srvmsg)
   IF (h3202611srvreq=0)
    SET getaccessibleencntrerrormsg = build2("*** Failed to create request ",build(
      access_encntr_req_number))
    RETURN(1)
   ENDIF
   SET h3202611srvrep = uar_srvcreatereply(h3202611srvmsg)
   IF (h3202611srvrep=0)
    SET getaccessibleencntrerrormsg = build2("*** Failed to create reply ",build(
      access_encntr_req_number))
    RETURN(1)
   ENDIF
   DECLARE p_count = i4 WITH noconstant(0), protect
   DECLARE person_count = i4 WITH noconstant(0), protect
   DECLARE e_count = i4 WITH noconstant(0), protect
   DECLARE encounter_count = i4 WITH noconstant(0), protect
   DECLARE htransactionstatus = i4 WITH noconstant(0), protect
   DECLARE hencounter = i4 WITH noconstant(0), protect
   SET person_count = size(accessible_encntr_person_ids->person_ids,5)
   SET accessible_encntr_ids_maps->persons_cnt = person_count
   FOR (p_count = 1 TO person_count)
     SET stat = uar_srvsetdouble(h3202611srvreq,"patientId",accessible_encntr_person_ids->person_ids[
      p_count].person_id)
     IF (disable_access_security_ind=0)
      SET stat = uar_srvsetstring(h3202611srvreq,"concept",nullterm(concept))
     ELSE
      SET stat = uar_srvsetstring(h3202611srvreq,"concept",nullterm("No_Security"))
     ENDIF
     SET accessible_encntr_ids_maps->persons[p_count].person_id = accessible_encntr_person_ids->
     person_ids[p_count].person_id
     SET stat = uar_srvexecute(h3202611srvmsg,h3202611srvreq,h3202611srvrep)
     IF (stat=0)
      SET htransactionstatus = uar_srvgetstruct(h3202611srvrep,"transactionStatus")
      IF (htransactionstatus=0)
       SET getaccessibleencntrerrormsg = build2("Failed to get transaction status from reply of ",
        build(access_encntr_req_number))
       RETURN(1)
      ELSE
       IF (uar_srvgetshort(htransactionstatus,"successIndicator") != 1)
        SET getaccessibleencntrerrormsg = build2("Failure for call to ",build(
          access_encntr_req_number),". Debug Msg =",uar_srvgetstringptr(htransactionstatus,
          "debugErrorMessage"))
        RETURN(1)
       ELSE
        SET encounter_count = uar_srvgetitemcount(h3202611srvrep,"encounterIds")
        SET stat = alterlist(accessible_encntr_ids_maps->persons[p_count].accessible_encntrs,
         encounter_count)
        SET accessible_encntr_ids_maps->persons[p_count].accessible_encntrs_cnt = encounter_count
        FOR (e_count = 1 TO encounter_count)
         SET hencounter = uar_srvgetitem(h3202611srvrep,"encounterIds",(e_count - 1))
         SET accessible_encntr_ids_maps->persons[p_count].accessible_encntrs[e_count].
         accessible_encntr_id = uar_srvgetdouble(hencounter,"encounterId")
        ENDFOR
       ENDIF
      ENDIF
     ELSE
      SET getaccessibleencntrerrormsg = build2("Failure for call to ",build(access_encntr_req_number)
       )
      RETURN(1)
     ENDIF
   ENDFOR
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (get_accessible_encntr_toggle(result=i4(ref)) =i4)
   DECLARE concept_policies_req_concept = vc WITH constant("PowerChart_Framework"), protect
   DECLARE featuretoggleflag = i2 WITH noconstant(false), protect
   DECLARE chartaccessflag = i2 WITH noconstant(false), protect
   DECLARE featuretogglestat = i2 WITH noconstant(0), protect
   DECLARE chartaccessstat = i2 WITH noconstant(0), protect
   SET featuretogglestat = isfeaturetoggleon("urn:cerner:millennium:accessible-encounters-by-concept",
    "urn:cerner:millennium",featuretoggleflag)
   CALL uar_syscreatehandle(hsys,sysstat)
   IF (hsys > 0)
    SET slogtext = build2("get_accessible_encntr_toggle - featureToggleStat is ",build(
      featuretogglestat))
    CALL uar_sysevent(hsys,4,"pm_get_access_encntr_by_person",nullterm(slogtext))
    SET slogtext = build2("get_accessible_encntr_toggle - featureToggleFlag is ",build(
      featuretoggleflag))
    CALL uar_sysevent(hsys,4,"pm_get_access_encntr_by_person",nullterm(slogtext))
    CALL uar_sysdestroyhandle(hsys)
   ENDIF
   IF (featuretogglestat=0
    AND featuretoggleflag=true)
    SET result = 1
    RETURN(0)
   ENDIF
   IF (featuretogglestat != 0)
    CALL uar_syscreatehandle(hsys,sysstat)
    IF (hsys > 0)
     SET slogtext = build("Feature toggle service returned failure status.")
     CALL uar_sysevent(hsys,1,"pm_get_access_encntr_by_person",nullterm(slogtext))
     CALL uar_sysdestroyhandle(hsys)
    ENDIF
   ENDIF
   SET chartaccessstat = ischartaccesson(concept_policies_req_concept,chartaccessflag)
   CALL uar_syscreatehandle(hsys,sysstat)
   IF (hsys > 0)
    SET slogtext = build2("get_accessible_encntr_toggle - chartAccessStat is ",build(chartaccessstat)
     )
    CALL uar_sysevent(hsys,4,"pm_get_access_encntr_by_person",nullterm(slogtext))
    SET slogtext = build2("get_accessible_encntr_toggle - chartAccessFlag is ",build(chartaccessflag)
     )
    CALL uar_sysevent(hsys,4,"pm_get_access_encntr_by_person",nullterm(slogtext))
    CALL uar_sysdestroyhandle(hsys)
   ENDIF
   IF (chartaccessstat != 0)
    RETURN(1)
   ENDIF
   IF (chartaccessflag=true)
    SET result = 1
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (isfeaturetoggleon(togglename=vc,systemidentifier=vc,featuretoggleflag=i2(ref)) =i4)
   DECLARE feature_toggle_req_number = i4 WITH constant(2030001), protect
   DECLARE toggle = vc WITH noconstant(""), protect
   DECLARE htransactionstatus = i4 WITH noconstant(0), protect
   DECLARE hfeatureflagmsg = i4 WITH noconstant(0), protect
   DECLARE hfeatureflagreq = i4 WITH noconstant(0), protect
   DECLARE hfeatureflagrep = i4 WITH noconstant(0), protect
   DECLARE rep2030001count = i4 WITH noconstant(0), protect
   DECLARE rep2030001successind = i2 WITH noconstant(0), protect
   SET hfeatureflagmsg = uar_srvselectmessage(feature_toggle_req_number)
   IF (hfeatureflagmsg=0)
    RETURN(0)
   ENDIF
   SET hfeatureflagreq = uar_srvcreaterequest(hfeatureflagmsg)
   IF (hfeatureflagreq=0)
    RETURN(0)
   ENDIF
   SET hfeatureflagrep = uar_srvcreatereply(hfeatureflagmsg)
   IF (hfeatureflagrep=0)
    RETURN(0)
   ENDIF
   SET stat = uar_srvsetstring(hfeatureflagreq,"system_identifier",nullterm(systemidentifier))
   SET stat = uar_srvsetshort(hfeatureflagreq,"ignore_overrides_ind",1)
   IF (uar_srvexecute(hfeatureflagmsg,hfeatureflagreq,hfeatureflagrep)=0)
    SET htransactionstatus = uar_srvgetstruct(hfeatureflagrep,"transaction_status")
    IF (htransactionstatus != 0)
     SET rep2030001successind = uar_srvgetshort(htransactionstatus,"success_ind")
    ELSE
     SET getaccessibleencntrtoggleerrormsg = build2("Failed to get transaction status from reply of ",
      build(feature_toggle_req_number))
     RETURN(1)
    ENDIF
    IF (rep2030001successind=1)
     IF (uar_srvgetitem(hfeatureflagrep,"feature_toggle_keys",0) > 0)
      SET rep2030001count = uar_srvgetitemcount(hfeatureflagrep,"feature_toggle_keys")
      FOR (loop = 0 TO (rep2030001count - 1))
       SET toggle = uar_srvgetstringptr(uar_srvgetitem(hfeatureflagrep,"feature_toggle_keys",loop),
        "key")
       IF (togglename=toggle)
        SET featuretoggleflag = true
        RETURN(0)
       ENDIF
      ENDFOR
     ENDIF
    ELSE
     SET getaccessibleencntrtoggleerrormsg = build2("Failure for call to ",build(
       feature_toggle_req_number),". Debug Msg =",uar_srvgetstringptr(htransactionstatus,
       "debug_error_message"))
     RETURN(1)
    ENDIF
   ELSE
    SET getaccessibleencntrtoggleerrormsg = build2("Failure for call to ",build(
      feature_toggle_req_number))
    RETURN(1)
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (ischartaccesson(concept=vc,chartaccessflag=i2(ref)) =i4)
   DECLARE concept_policies_req_number = i4 WITH constant(3202590), protect
   DECLARE htransactionstatus = i4 WITH noconstant(0), protect
   DECLARE hconceptpoliciesreqstruct = i4 WITH noconstant(0), protect
   DECLARE hconceptpoliciesmsg = i4 WITH noconstant(0), protect
   DECLARE hconceptpoliciesreq = i4 WITH noconstant(0), protect
   DECLARE hconceptpoliciesrep = i4 WITH noconstant(0), protect
   DECLARE hconceptpoliciesstruct = i4 WITH noconstant(0), protect
   DECLARE rep3202590count = i4 WITH noconstant(0), protect
   DECLARE rep3202590successind = i2 WITH noconstant(0), protect
   SET hconceptpoliciesmsg = uar_srvselectmessage(concept_policies_req_number)
   IF (hconceptpoliciesmsg=0)
    RETURN(0)
   ENDIF
   SET hconceptpoliciesreq = uar_srvcreaterequest(hconceptpoliciesmsg)
   IF (hconceptpoliciesreq=0)
    RETURN(0)
   ENDIF
   SET hconceptpoliciesrep = uar_srvcreatereply(hconceptpoliciesmsg)
   IF (hconceptpoliciesrep=0)
    RETURN(0)
   ENDIF
   SET hconceptpoliciesreqstruct = uar_srvadditem(hconceptpoliciesreq,"concepts")
   IF (hconceptpoliciesreqstruct > 0)
    SET stat = uar_srvsetstring(hconceptpoliciesreqstruct,"concept",nullterm(concept))
    IF (uar_srvexecute(hconceptpoliciesmsg,hconceptpoliciesreq,hconceptpoliciesrep)=0)
     SET htransactionstatus = uar_srvgetstruct(hconceptpoliciesrep,"transaction_status")
     IF (htransactionstatus != 0)
      SET rep3202590successind = uar_srvgetshort(htransactionstatus,"success_ind")
     ELSE
      SET getaccessibleencntrtoggleerrormsg = build2(
       "Failed to get transaction status from reply of ",build(concept_policies_req_number))
      RETURN(1)
     ENDIF
     IF (rep3202590successind=1)
      IF (uar_srvgetitem(hconceptpoliciesrep,"concept_policies_batch",0) > 0)
       SET rep3202590count = uar_srvgetitemcount(hconceptpoliciesrep,"concept_policies_batch")
       FOR (loop = 0 TO (rep3202590count - 1))
        SET hconceptpoliciesstruct = uar_srvgetstruct(uar_srvgetitem(hconceptpoliciesrep,
          "concept_policies_batch",loop),"policies")
        IF (hconceptpoliciesstruct > 0)
         IF (uar_srvgetshort(hconceptpoliciesstruct,"chart_access_group_security_ind")=1)
          SET chartaccessflag = true
          RETURN(0)
         ENDIF
        ELSE
         SET getaccessibleencntrtoggleerrormsg = build2("Failure for call to ",build(
           concept_policies_req_number),build("Found an invalid hConceptPoliciesStruct : ",
           hconceptpoliciesstruct))
         RETURN(1)
        ENDIF
       ENDFOR
      ENDIF
     ELSE
      SET getaccessibleencntrtoggleerrormsg = build2("Failure for call to ",build(
        concept_policies_req_number),". Debug Msg =",uar_srvgetstringptr(htransactionstatus,
        "debug_error_message"))
      RETURN(1)
     ENDIF
    ELSE
     SET getaccessibleencntrtoggleerrormsg = build2("Failure for call to ",build(
       concept_policies_req_number))
     RETURN(1)
    ENDIF
   ELSE
    SET getaccessibleencntrtoggleerrormsg = build2("Failure for call to ",build(
      concept_policies_req_number),build("Found an invalid hConceptPoliciesReqStruct : ",
      hconceptpoliciesreqstruct))
    RETURN(1)
   ENDIF
   RETURN(0)
 END ;Subroutine
 RECORD encounters(
   1 encounter_ids[*]
     2 encounter_id = f8
 )
 DECLARE pregnancy_concept = vc WITH constant("PREGNANCY"), protect
 DECLARE womens_health_concept = vc WITH constant("WOMENS_HEALTH"), protect
 SUBROUTINE (ischartaccessenabled(chartaccessflag=i2(ref),ispregcomp=i2(val,0)) =i4)
   CALL log_message("In IsChartAccessEnabled()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(curtime3), private
   DECLARE concept_policies_req_num = i4 WITH constant(3202590), protect
   DECLARE htransactionstatus = i4 WITH noconstant(0), protect
   DECLARE hconceptpoliciesreqstruct = i4 WITH noconstant(0), protect
   DECLARE hconceptpoliciesmsg = i4 WITH noconstant(0), protect
   DECLARE hconceptpoliciesreq = i4 WITH noconstant(0), protect
   DECLARE hconceptpoliciesrep = i4 WITH noconstant(0), protect
   DECLARE hconceptpoliciesstruct = i4 WITH noconstant(0), protect
   DECLARE rep3202590count = i4 WITH noconstant(0), protect
   DECLARE rep3202590successind = i2 WITH noconstant(0), protect
   DECLARE rep3202590debugerrormsg = vc WITH noconstant(""), protect
   DECLARE concept = vc WITH noconstant(womens_health_concept), private
   IF (ispregcomp=1)
    SET concept = pregnancy_concept
   ENDIF
   SET hconceptpoliciesmsg = uar_srvselectmessage(concept_policies_req_num)
   IF (hconceptpoliciesmsg=0)
    RETURN(0)
   ENDIF
   SET hconceptpoliciesreq = uar_srvcreaterequest(hconceptpoliciesmsg)
   IF (hconceptpoliciesreq=0)
    RETURN(0)
   ENDIF
   SET hconceptpoliciesrep = uar_srvcreatereply(hconceptpoliciesmsg)
   IF (hconceptpoliciesrep=0)
    RETURN(0)
   ENDIF
   SET hconceptpoliciesreqstruct = uar_srvadditem(hconceptpoliciesreq,"concepts")
   IF (hconceptpoliciesreqstruct > 0)
    SET stat = uar_srvsetstring(hconceptpoliciesreqstruct,"concept",nullterm(concept))
    IF (uar_srvexecute(hconceptpoliciesmsg,hconceptpoliciesreq,hconceptpoliciesrep)=0)
     SET htransactionstatus = uar_srvgetstruct(hconceptpoliciesrep,"transaction_status")
     IF (htransactionstatus != 0)
      SET rep3202590successind = uar_srvgetshort(htransactionstatus,"success_ind")
      SET rep3202590debugerrormsg = uar_srvgetstringptr(htransactionstatus,"debug_error_message")
     ELSE
      IF (validate(debug_ind,0)=1)
       CALL echo(build2("Failed to get transaction status from reply of ",build(
          concept_policies_req_num)))
      ENDIF
      CALL log_message(build("Exit IsChartAccessEnabled(), Elapsed time in seconds:",((curtime3 -
        begin_date_time)/ 100.0)),log_level_debug)
      RETURN(1)
     ENDIF
     IF (rep3202590successind=1)
      IF (uar_srvgetitem(hconceptpoliciesrep,"concept_policies_batch",0) > 0)
       SET rep3202590count = uar_srvgetitemcount(hconceptpoliciesrep,"concept_policies_batch")
       FOR (loop = 0 TO (rep3202590count - 1))
        SET hconceptpoliciesstruct = uar_srvgetstruct(uar_srvgetitem(hconceptpoliciesrep,
          "concept_policies_batch",loop),"policies")
        IF (hconceptpoliciesstruct > 0)
         IF (uar_srvgetshort(hconceptpoliciesstruct,"chart_access_group_security_ind")=1)
          SET chartaccessflag = true
          CALL log_message(build("Exit IsChartAccessEnabled(), Elapsed time in seconds:",((curtime3
             - begin_date_time)/ 100.0)),log_level_debug)
          RETURN(0)
         ENDIF
        ELSE
         IF (validate(debug_ind,0)=1)
          CALL echo(build2("Failure for call to ",build(concept_policies_req_num),build(
             "Found an invalid hConceptPoliciesStruct : ",hconceptpoliciesstruct)))
         ENDIF
         CALL log_message(build("Exit IsChartAccessEnabled(), Elapsed time in seconds:",((curtime3 -
           begin_date_time)/ 100.0)),log_level_debug)
         RETURN(1)
        ENDIF
       ENDFOR
      ENDIF
     ELSE
      IF (validate(debug_ind,0)=1)
       CALL echo(build2("Failure for call to ",build(concept_policies_req_num),". Debug Msg =",
         uar_srvgetstringptr(htransactionstatus,"debug_error_message")))
      ENDIF
      CALL log_message(build("Exit IsChartAccessEnabled(), Elapsed time in seconds:",((curtime3 -
        begin_date_time)/ 100.0)),log_level_debug)
      RETURN(1)
     ENDIF
    ELSE
     IF (validate(debug_ind,0)=1)
      CALL echo(build2("Failure for call to ",build(concept_policies_req_num)))
     ENDIF
     CALL log_message(build("Exit IsChartAccessEnabled(), Elapsed time in seconds:",((curtime3 -
       begin_date_time)/ 100.0)),log_level_debug)
     RETURN(1)
    ENDIF
   ELSE
    IF (validate(debug_ind,0)=1)
     CALL echo(build2("Failure for call to ",build(concept_policies_req_num),build(
        "Found an invalid hConceptPoliciesReqStruct : ",hconceptpoliciesreqstruct)))
    ENDIF
    CALL log_message(build("Exit IsChartAccessEnabled(), Elapsed time in seconds:",((curtime3 -
      begin_date_time)/ 100.0)),log_level_debug)
    RETURN(1)
   ENDIF
   CALL log_message(build("Exit IsChartAccessEnabled(), Elapsed time in seconds:",((curtime3 -
     begin_date_time)/ 100.0)),log_level_debug)
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (getallencounters(encntrsrec=vc(ref),personid=f8(val)) =i4)
   CALL log_message("In GetAllEncounters()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(curtime3), private
   IF (preg_org_sec_ind=0)
    CALL getallpregencounters(personid,encounters)
    SET stat = alterlist(encntrsrec->qual,0)
    SET stat = moverec(encounters->encounter_ids,encntrsrec->qual)
    SET encntrsrec->cnt = size(encntrsrec->qual,5)
   ENDIF
   CALL log_message(build("Exit GetAllEncounters(), Elapsed time in seconds:",((curtime3 -
     begin_date_time)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (getaccessibleencounters(encntrsrec=vc(ref),personid=f8(val),ispregcomp=i2(val,0)) =i4)
   CALL log_message("In GetAccessibleEncounters()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(curtime3), private
   DECLARE result = i4 WITH protect, noconstant(0)
   DECLARE concept = vc WITH noconstant(womens_health_concept), private
   IF (ispregcomp=1)
    SET concept = pregnancy_concept
   ENDIF
   CALL get_accessible_encntr_toggle(result)
   IF (result=1)
    SET stat = get_accessible_encntr_ids_by_person_id(personid,concept,0)
    IF (stat=0)
     SET stat = alterlist(encntrsrec->qual,0)
     SET stat = moverec(accessible_encntr_ids->accessible_encntrs,encntrsrec->qual)
     SET encntrsrec->cnt = size(encntrsrec->qual,5)
    ENDIF
   ELSEIF (ispregcomp=1)
    CALL getallencounters(encntrsrec,personid)
   ENDIF
   CALL log_message(build("Exit GetAccessibleEncounters(), Elapsed time in seconds:",((curtime3 -
     begin_date_time)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (getaccessibleencounterbypersonids(patientids=vc(ref),encntrsrec=vc(ref),patientcount=i4(
   val,0)) =i4)
   CALL log_message("In GetAccessibleEncounterByPersonIds()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(curtime3), private
   DECLARE pcount = i4 WITH noconstant(0), protect
   DECLARE encntrcount = i4 WITH protect, noconstant(0)
   DECLARE prevencntrcount = i4 WITH protect, noconstant(0)
   DECLARE currencntrcount = i4 WITH protect, noconstant(0)
   DECLARE result = i4 WITH protect, noconstant(0)
   IF (patientcount=0)
    SET patientcount = size(patientids->patient_list,5)
   ENDIF
   CALL get_accessible_encntr_toggle(result)
   IF (result=1)
    FOR (pcount = 1 TO patientcount)
     SET stat = get_accessible_encntr_ids_by_person_id(patientids->patient_list[pcount].patient_id,
      pregnancy_concept,0)
     IF (stat=0)
      SET encntrcount = accessible_encntr_ids->accessible_encntrs_cnt
      SET prevencntrcount = currencntrcount
      SET currencntrcount += encntrcount
      SET stat = alterlist(encntrsrec->qual,currencntrcount)
      SET encntrsrec->cnt = currencntrcount
      FOR (ecount = 1 TO encntrcount)
        SET encntrsrec->qual[(ecount+ prevencntrcount)].value = accessible_encntr_ids->
        accessible_encntrs[ecount].accessible_encntr_id
      ENDFOR
     ENDIF
    ENDFOR
   ENDIF
   CALL log_message(build("Exit GetAccessibleEncounterByPersonIds(), Elapsed time in seconds:",((
     curtime3 - begin_date_time)/ 100.0)),log_level_debug)
 END ;Subroutine
 IF (validate(request->debug_ind))
  IF ((request->debug_ind=1))
   SET debug_ind = 1
  ENDIF
 ENDIF
 IF (patientcnt1=0)
  GO TO script_end
 ENDIF
 SET expand_total = (ceil((cnvtreal(patientcnt1)/ expand_size)) * expand_size)
 SET stat1 = alterlist(temp_patient->patient_list,expand_total)
 DECLARE loadpregnancyorganizationsecuritylist() = null
 IF (validate(preg_org_sec_ind)=0)
  DECLARE preg_org_sec_ind = i4 WITH noconstant(0)
  SELECT INTO "nl:"
   FROM dm_info d1,
    dm_info d2
   WHERE d1.info_domain="SECURITY"
    AND d1.info_name="SEC_ORG_RELTN"
    AND d1.info_number=1
    AND d2.info_domain="SECURITY"
    AND d2.info_name="SEC_PREG_ORG_RELTN"
    AND d2.info_number=1
   DETAIL
    preg_org_sec_ind = 1
   WITH nocounter
  ;end select
  CALL echo(build("preg_org_sec_ind=",preg_org_sec_ind))
  IF (preg_org_sec_ind=1)
   FREE RECORD preg_sec_orgs
   RECORD preg_sec_orgs(
     1 qual[*]
       2 org_id = f8
       2 confid_level = i4
   )
   CALL loadpregnancyorganizationsecuritylist(null)
  ENDIF
 ENDIF
 SUBROUTINE loadpregnancyorganizationsecuritylist(null)
   DECLARE org_cnt = i2 WITH noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (validate(sac_org)=1)
    FREE RECORD sac_org
   ENDIF
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
   SET org_cnt = size(sac_org->organizations,5)
   CALL echo(build("org_cnt: ",org_cnt))
   SET stat = alterlist(preg_sec_orgs->qual,(org_cnt+ 1))
   FOR (count = 1 TO org_cnt)
    SET preg_sec_orgs->qual[count].org_id = sac_org->organizations[count].organization_id
    SET preg_sec_orgs->qual[count].confid_level = sac_org->organizations[count].confid_level
   ENDFOR
   SET preg_sec_orgs->qual[(org_cnt+ 1)].org_id = 0.00
   SET preg_sec_orgs->qual[(org_cnt+ 1)].confid_level = 0
 END ;Subroutine
 FOR (idx = 1 TO expand_total)
   IF (idx <= patientcnt1)
    SET temp_patient->patient_list[idx].patient_id = request->patient_list[idx].patient_id
    IF (validate(request->patient_list[idx].encntr_id)=0)
     SET temp_patient->patient_list[idx].encntr_id = 0
    ELSE
     SET temp_patient->patient_list[idx].encntr_id = request->patient_list[idx].encntr_id
    ENDIF
   ELSE
    SET temp_patient->patient_list[idx].patient_id = request->patient_list[patientcnt1].patient_id
    IF (validate(request->patient_list[idx].encntr_id)=0)
     SET temp_patient->patient_list[idx].encntr_id = 0
    ELSE
     SET temp_patient->patient_list[idx].encntr_id = request->patient_list[patientcnt1].encntr_id
    ENDIF
   ENDIF
 ENDFOR
 DECLARE encntr_id_column_exists = i2 WITH public, noconstant(0)
 FREE RECORD encntr_list
 RECORD encntr_list(
   1 cnt = i4
   1 qual[*]
     2 value = f8
 )
 DECLARE encntr_idx = i4 WITH protect, noconstant(0)
 DECLARE chart_access_flag = i2 WITH protect, noconstant(0)
 IF (checkdic("PREGNANCY_INSTANCE.ENCNTR_ID","A",0) > 1)
  SET encntr_id_column_exists = 1
 ENDIF
 IF (encntr_id_column_exists=1)
  CALL ischartaccessenabled(chart_access_flag)
  IF (chart_access_flag=1)
   CALL getaccessibleencounterbypersonids(temp_patient,encntr_list,patientcnt1)
  ENDIF
 ENDIF
 IF (preg_org_sec_ind=1)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = size(temp_patient->patient_list,5)),
    encounter e
   PLAN (d)
    JOIN (e
    WHERE (e.encntr_id=temp_patient->patient_list[d.seq].encntr_id))
   DETAIL
    temp_patient->patient_list[d.seq].org_id = e.organization_id
    IF (chart_access_flag=1)
     temp_patient->patient_list[d.seq].chart_access_org_id = e.chart_access_organization_id
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (((preg_org_sec_ind=0) OR (((validate(request->org_sec_override)=0) OR ((request->
 org_sec_override=1))) )) )
  SELECT INTO "nl:"
   FROM pregnancy_instance p,
    (dummyt d  WITH seq = value((expand_total/ expand_size)))
   PLAN (d
    WHERE assign(expand_start,evaluate(d.seq,1,1,(expand_start+ expand_size)))
     AND assign(expand_stop,(expand_start+ (expand_size - 1))))
    JOIN (p
    WHERE expand(num,expand_start,expand_stop,p.person_id,temp_patient->patient_list[num].patient_id)
     AND p.active_ind=1
     AND p.preg_end_dt_tm=cnvtdatetime("31-DEC-2100"))
   ORDER BY p.person_id, p.pregnancy_id DESC
   HEAD REPORT
    stat = alterlist(reply->patient_list,patientcnt1)
    FOR (i = 1 TO patientcnt1)
      reply->patient_list[i].patient_id = temp_patient->patient_list[i].patient_id, reply->
      patient_list[i].encntr_id = temp_patient->patient_list[i].encntr_id, reply->patient_list[i].
      org_id = temp_patient->patient_list[i].org_id,
      reply->patient_list[i].pregnancy_id = 0
    ENDFOR
    total_result_cnt = 0, person_preg_multiple_ind = 0
   HEAD p.person_id
    person_idx = locateval(idx,1,patientcnt1,p.person_id,reply->patient_list[idx].patient_id),
    person_org_preg_cnt = 0
   DETAIL
    IF (person_idx > 0)
     person_org_preg_cnt += 1, total_result_cnt += 1, reply->patient_list[person_idx].pregnancy_id =
     p.pregnancy_id,
     reply->patient_list[person_idx].org_id = p.organization_id, reply->patient_list[person_idx].
     pregnancy_instance_id = p.pregnancy_instance_id
    ENDIF
   FOOT  p.person_id
    IF (person_org_preg_cnt > 1)
     person_preg_multiple_ind = 1
     IF (debug_ind=1)
      CALL echo(build("Org Security is Off. Multiple active pregnancies exist for person_id=",p
       .person_id))
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
 ELSEIF (chart_access_flag=1)
  SELECT INTO "nl:"
   FROM pregnancy_instance p,
    encounter e,
    (dummyt d  WITH seq = value((expand_total/ expand_size)))
   PLAN (d
    WHERE assign(expand_start,evaluate(d.seq,1,1,(expand_start+ expand_size)))
     AND assign(expand_stop,(expand_start+ (expand_size - 1))))
    JOIN (p
    WHERE expand(num,expand_start,expand_stop,p.person_id,temp_patient->patient_list[num].patient_id)
     AND p.active_ind=1
     AND p.preg_end_dt_tm=cnvtdatetime("31-DEC-2100")
     AND ((expand(encntr_idx,1,size(encntr_list->qual,5),p.encntr_id,encntr_list->qual[encntr_idx].
     value)) OR (p.encntr_id=0)) )
    JOIN (e
    WHERE ((e.encntr_id=p.encntr_id) OR (p.encntr_id=0)) )
   ORDER BY p.person_id, p.pregnancy_id DESC
   HEAD REPORT
    stat = alterlist(reply->patient_list,patientcnt1)
    FOR (i = 1 TO patientcnt1)
      reply->patient_list[i].patient_id = temp_patient->patient_list[i].patient_id, reply->
      patient_list[i].encntr_id = temp_patient->patient_list[i].encntr_id, reply->patient_list[i].
      org_id = temp_patient->patient_list[i].org_id,
      reply->patient_list[i].chart_access_org_id = temp_patient->patient_list[i].chart_access_org_id,
      reply->patient_list[i].pregnancy_id = 0
    ENDFOR
    total_result_cnt = 0, person_preg_multiple_ind = 0
   HEAD p.person_id
    person_idx = locateval(idx,1,patientcnt1,p.person_id,reply->patient_list[idx].patient_id),
    person_org_preg_cnt = 0, preg_exist_in_curr_care_unit = 0
   DETAIL
    IF (person_idx > 0
     AND (reply->patient_list[person_idx].chart_access_org_id=e.chart_access_organization_id)
     AND preg_exist_in_curr_care_unit=0)
     preg_exist_in_curr_care_unit = 1, total_result_cnt += 1, reply->patient_list[person_idx].
     pregnancy_id = p.pregnancy_id,
     reply->patient_list[person_idx].org_id = p.organization_id, reply->patient_list[person_idx].
     pregnancy_instance_id = p.pregnancy_instance_id
    ELSEIF (person_idx > 0
     AND preg_exist_in_curr_care_unit=0
     AND total_result_cnt=0)
     IF (validate(p.encntr_id,0)=0
      AND (((reply->patient_list[person_idx].org_id=p.organization_id)) OR (p.organization_id=0)) )
      total_result_cnt += 1, reply->patient_list[person_idx].pregnancy_id = p.pregnancy_id, reply->
      patient_list[person_idx].org_id = p.organization_id,
      reply->patient_list[person_idx].pregnancy_instance_id = p.pregnancy_instance_id
     ELSEIF (validate(p.encntr_id,0) > 0)
      total_result_cnt += 1, reply->patient_list[person_idx].pregnancy_id = p.pregnancy_id, reply->
      patient_list[person_idx].org_id = p.organization_id,
      reply->patient_list[person_idx].pregnancy_instance_id = p.pregnancy_instance_id
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM pregnancy_instance p,
    (dummyt d  WITH seq = value((expand_total/ expand_size))),
    (dummyt d1  WITH seq = size(preg_sec_orgs->qual,5))
   PLAN (d
    WHERE assign(expand_start,evaluate(d.seq,1,1,(expand_start+ expand_size)))
     AND assign(expand_stop,(expand_start+ (expand_size - 1))))
    JOIN (p
    WHERE expand(num,expand_start,expand_stop,p.person_id,temp_patient->patient_list[num].patient_id)
     AND p.active_ind=1
     AND p.preg_end_dt_tm=cnvtdatetime("31-DEC-2100"))
    JOIN (d1
    WHERE (p.organization_id=preg_sec_orgs->qual[d1.seq].org_id))
   ORDER BY p.person_id, p.organization_id, p.pregnancy_id DESC
   HEAD REPORT
    stat = alterlist(reply->patient_list,patientcnt1)
    FOR (i = 1 TO patientcnt1)
      reply->patient_list[i].patient_id = temp_patient->patient_list[i].patient_id, reply->
      patient_list[i].encntr_id = temp_patient->patient_list[i].encntr_id, reply->patient_list[i].
      org_id = temp_patient->patient_list[i].org_id,
      reply->patient_list[i].pregnancy_id = 0
    ENDFOR
    total_result_cnt = 0, person_preg_multiple_ind = 0
   HEAD p.person_id
    person_idx = locateval(idx,1,patientcnt1,p.person_id,reply->patient_list[idx].patient_id)
   HEAD p.organization_id
    person_org_preg_cnt = 0
   DETAIL
    IF (person_idx > 0)
     IF ((((reply->patient_list[person_idx].org_id=p.organization_id)) OR (p.organization_id=0)) )
      person_org_preg_cnt += 1, total_result_cnt += 1, reply->patient_list[person_idx].pregnancy_id
       = p.pregnancy_id,
      reply->patient_list[person_idx].org_id = p.organization_id, reply->patient_list[person_idx].
      pregnancy_instance_id = p.pregnancy_instance_id
     ENDIF
    ENDIF
   FOOT  p.organization_id
    IF (person_org_preg_cnt > 1)
     person_preg_multiple_ind = 1
     IF (debug_ind=1)
      CALL echo(concat("Org Security is On. Multiple active pregnancies exist for person_id = ",
       cnvtstring(p.person_id)," at org_id = ",cnvtstring(p.organization_id)))
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
#script_end
 SET error_cd = error(error_msg,1)
 IF (error_cd != 0)
  CALL reportfailure("ERROR","F","dcp_chk_active_preg_list",error_msg)
 ELSEIF (person_preg_multiple_ind=1)
  CALL reportfailure("ERROR","F","dcp_chk_active_preg_list",
   "Multiple active pregnancies exist for the patient.")
  IF (debug_ind=1)
   CALL echorecord(reply)
  ENDIF
  SET stat1 = alterlist(reply->patient_list,0)
 ELSEIF (total_result_cnt <= 0)
  SET reply->status_data.status = "Z"
 ELSE
  CALL fillsubeventstatus("SUCCESS","S","dcp_chk_active_preg_list","Active pregnancies were found.")
  SET reply->status_data.status = "S"
 ENDIF
 IF (debug_ind=1)
  CALL echo(build("Total active pregs=",total_result_cnt))
  CALL echorecord(reply)
  CALL echo("Last Mod: 004 05/27/21")
 ENDIF
 SET modify = nopredeclare
END GO
