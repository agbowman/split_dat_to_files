CREATE PROGRAM dcp_chk_reactivate_preg:dba
 RECORD organization_info(
   1 encntr_id = f8
   1 org_id = f8
 )
 RECORD reply(
   1 pregnancy_id = f8
   1 delivery_dt_tm = dq8
   1 close_dt_tm = dq8
   1 action_cd = f8
   1 delivery_method_cd = f8
   1 pregnancy_instance_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH persistscript
 DECLARE failure_ind = i2 WITH protect, noconstant(false)
 DECLARE zero_ind = i2 WITH protect, noconstant(false)
 DECLARE closed_action_cd = f8 WITH constant(uar_get_code_by("MEANING",4002114,"CLOSE")), protected
 DECLARE auto_closed_action_cd = f8 WITH constant(uar_get_code_by("MEANING",4002114,"AUTOCLOSE")),
 protected
 DECLARE update_action_cd = f8 WITH constant(uar_get_code_by("MEANING",4002114,"UPDATE")), protected
 DECLARE cancel_action_cd = f8 WITH constant(uar_get_code_by("MEANING",4002114,"CANCEL")), protected
 DECLARE reopen_action_cd = f8 WITH constant(uar_get_code_by("MEANING",4002114,"REOPEN")), protected
 DECLARE delete_action_cd = f8 WITH constant(uar_get_code_by("MEANING",4002114,"DELETE")), protected
 DECLARE preg_cnt_info = i4 WITH protect, noconstant(0)
 DECLARE prev_preg_cnt = i4 WITH protect, noconstant(0)
 DECLARE validaterequest() = null
 DECLARE findpregnancyinfo() = null
 DECLARE findchildinfo() = null
 DECLARE fillorgencntrinfo() = null
 SUBROUTINE (checkactivepregnancy(argpersonid=f8) =f8)
   RETURN(checkactivepregnancyorg(argpersonid,0,0))
 END ;Subroutine
 SUBROUTINE (checkactivepregnancyorg(argpersonid=f8,argencntrid=f8,argorgsecoverride=i2) =f8)
   CALL echo("[TRACE]: CheckActivePregnancy")
   DECLARE retval = f8 WITH noconstant(0.0), private
   RECORD actchkrequest(
     1 patient_id = f8
     1 encntr_id = f8
     1 org_sec_override = i2
   )
   SET actchkrequest->patient_id = argpersonid
   SET actchkrequest->encntr_id = argencntrid
   SET actchkrequest->org_sec_override = argorgsecoverride
   EXECUTE dcp_chk_active_preg  WITH replace("REQUEST",actchkrequest), replace("REPLY",actchkreply)
   IF ((actchkreply->status_data.status="F"))
    CALL echo("[FAIL]: DCP_CHK_ACTIVE_PREG failed")
   ELSEIF ((actchkreply->status_data.status="Z"))
    SET retval = 0.0
   ELSE
    CALL echo("[TRACE]: Active Pregnancy found for patient")
    SET retval = actchkreply->pregnancy_id
   ENDIF
   RETURN(retval)
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
 SET reply->status_data.status = "F"
 CALL fillorgencntrinfo(null)
 CALL validaterequest(null)
 CALL findpregnancyinfo(null)
 CALL findchildinfo(null)
#failure
 IF (failure_ind=true)
  CALL echo("*Check Reactivate Pregnancy Script failed*")
 ELSEIF (zero_ind=true)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
 SUBROUTINE fillorgencntrinfo(null)
  SET organization_info->encntr_id = request->encntr_id
  SELECT INTO "nl:"
   FROM encounter e
   WHERE (e.encntr_id=organization_info->encntr_id)
   DETAIL
    organization_info->org_id = e.organization_id
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE validaterequest(null)
   IF ((((request->lookback_days > 1000)) OR ((request->lookback_days <= 0))) )
    SET failure_ind = true
    SET reply->status_data.subeventstatus.targetobjectvalue =
    "Lookback days was either invalid or over 1000 days"
    CALL echo("[FAIL] invalid lookback days value")
    GO TO failure
   ENDIF
   DECLARE pregid = f8 WITH noconstant(0)
   SET pregid = checkactivepregnancyorg(request->person_id,request->encntr_id,request->
    org_sec_override)
   IF (pregid > 0.0)
    SET reply->status_data.subeventstatus.targetobjectvalue = build("Found an active pregnancy: ",
     pregid)
    CALL echo("[ZERO] active pregnancy exists, reopen not available")
    CALL echo(build("[TRACE] pregnancy id: ",pregid))
    SET zero_ind = true
    GO TO failure
   ENDIF
 END ;Subroutine
 SUBROUTINE findpregnancyinfo(null)
   CALL echo("[TRACE] getting pregnancy info...")
   SELECT
    IF (((preg_org_sec_ind=0) OR ((request->org_sec_override=1))) )
     FROM pregnancy_instance pi,
      pregnancy_action pa
     PLAN (pi
      WHERE (pi.person_id=request->person_id)
       AND pi.preg_end_dt_tm < cnvtdatetime("31-DEC-2100")
       AND pi.historical_ind=false)
      JOIN (pa
      WHERE pa.pregnancy_id=pi.pregnancy_id
       AND pa.action_type_cd IN (closed_action_cd, auto_closed_action_cd, cancel_action_cd,
      update_action_cd, delete_action_cd))
    ELSE
     FROM pregnancy_instance pi,
      (dummyt d  WITH seq = size(preg_sec_orgs->qual,5)),
      pregnancy_action pa
     PLAN (pi
      WHERE (pi.person_id=request->person_id)
       AND pi.preg_end_dt_tm < cnvtdatetime("31-DEC-2100")
       AND pi.historical_ind=false)
      JOIN (d
      WHERE (pi.organization_id=preg_sec_orgs->qual[d.seq].org_id))
      JOIN (pa
      WHERE pa.pregnancy_id=pi.pregnancy_id
       AND pa.action_type_cd IN (closed_action_cd, auto_closed_action_cd, cancel_action_cd,
      update_action_cd, delete_action_cd))
    ENDIF
    INTO "nl:"
    ORDER BY pi.preg_end_dt_tm DESC, pa.action_dt_tm DESC
    HEAD REPORT
     preg_cnt_info = 0, prev_preg_cnt = 0
    DETAIL
     IF (preg_cnt_info=0)
      IF (((preg_org_sec_ind=0) OR ((request->org_sec_override=1))) )
       IF (pa.action_dt_tm > cnvtdatetime((curdate - request->lookback_days),curtime3))
        preg_cnt_info += 1, reply->pregnancy_instance_id = pi.pregnancy_instance_id, reply->
        pregnancy_id = pi.pregnancy_id,
        reply->close_dt_tm = pi.preg_end_dt_tm, reply->action_cd = pa.action_type_cd
       ELSEIF (prev_preg_cnt=0)
        prev_preg_cnt += 1, reply->action_cd = pa.action_type_cd
       ENDIF
      ELSEIF ((((organization_info->org_id=pi.organization_id)) OR (pi.organization_id=0)) )
       IF (pa.action_dt_tm > cnvtdatetime((curdate - request->lookback_days),curtime3))
        preg_cnt_info += 1, reply->pregnancy_instance_id = pi.pregnancy_instance_id, reply->
        pregnancy_id = pi.pregnancy_id,
        reply->close_dt_tm = pi.preg_end_dt_tm, reply->action_cd = pa.action_type_cd
       ELSEIF (prev_preg_cnt=0)
        prev_preg_cnt += 1, reply->action_cd = pa.action_type_cd
       ENDIF
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (preg_cnt_info=0)
    SET zero_ind = true
    CALL echo("[ZERO] no eligible pregnancies found")
    GO TO failure
   ENDIF
 END ;Subroutine
 SUBROUTINE findchildinfo(null)
   IF ((reply->pregnancy_id <= 0.0))
    SET failure_ind = true
    GO TO failure
   ENDIF
   CALL echo("[TRACE] getting child info...")
   SELECT INTO "nl:"
    FROM pregnancy_child pc
    WHERE (pc.pregnancy_id=reply->pregnancy_id)
     AND pc.active_ind=true
    ORDER BY pc.delivery_dt_tm DESC
    HEAD REPORT
     reply->delivery_dt_tm = pc.delivery_dt_tm, reply->delivery_method_cd = pc.delivery_method_cd
    WITH nocounter
   ;end select
 END ;Subroutine
END GO
