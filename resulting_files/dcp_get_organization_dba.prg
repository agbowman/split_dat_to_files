CREATE PROGRAM dcp_get_organization:dba
 RECORD reply(
   1 organization[*]
     2 organization_id = f8
     2 organization_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE ncnt = i4
 SET ncnt = 0
 DECLARE last_mod = c12 WITH private, noconstant(fillstring(12," "))
 DECLARE org_sec_ind = i2 WITH protect, noconstant(0)
 DECLARE org_cnt = i4 WITH protect, noconstant(0)
 DECLARE org_idx = i4 WITH protect, noconstant(0)
 FREE RECORD org_sec
 RECORD org_sec(
   1 encntr_org_security_ind = i2
   1 confid_security_ind = i2
 )
 DECLARE checkorgsecurity(null) = null
 SUBROUTINE checkorgsecurity(null)
   DECLARE dminfo_ok = i2 WITH protect, noconstant(0)
   SET org_sec->encntr_org_security_ind = 0
   SET org_sec->confid_security_ind = 0
   SET dminfo_ok = validate(ccldminfo->mode,0)
   IF (dminfo_ok=1)
    SET org_sec->encntr_org_security_ind = ccldminfo->sec_org_reltn
    SET org_sec->confid_security_ind = ccldminfo->sec_confid
   ELSE
    SELECT INTO "nl:"
     FROM dm_info dmi
     WHERE dmi.info_domain="SECURITY"
      AND dmi.info_name IN ("SEC_ORG_RELTN", "SEC_CONFID")
      AND dmi.info_number=1
     DETAIL
      IF (dmi.info_name="SEC_ORG_RELTN")
       org_sec->encntr_org_security_ind = 1
      ELSE
       org_sec->confid_security_ind = 1
      ENDIF
     WITH nocounter
    ;end select
    IF (curqual <= 0
     AND checkerror(failure,"SELECT",failure,"ORG SECURITY") > 0)
     SET s_msgbox_disp = errors->status_data.subeventstatus[errors->error_cnt].targetobjectvalue
     GO TO exit_script
    ENDIF
   ENDIF
 END ;Subroutine
 CALL checkorgsecurity(null)
 SET org_sec_ind = org_sec->encntr_org_security_ind
 FREE RECORD sac_org
 RECORD sac_org(
   1 organizations[*]
     2 organization_id = f8
     2 confid_cd = f8
     2 confid_level = i4
 )
 IF (org_sec_ind)
  FREE RECORD sac_org
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
 ENDIF
 IF (org_cnt > 0)
  SELECT INTO "nl:"
   FROM location l,
    organization o
   PLAN (o
    WHERE expand(org_idx,1,org_cnt,o.organization_id,sac_org->organizations[org_idx].organization_id)
     AND o.active_ind=1)
    JOIN (l
    WHERE l.organization_id=o.organization_id
     AND l.active_ind=1
     AND l.patcare_node_ind=1)
   DETAIL
    ncnt += 1
    IF (ncnt > size(reply->organization,5))
     stat = alterlist(reply->organization,(ncnt+ 100))
    ENDIF
    reply->organization[ncnt].organization_id = o.organization_id, reply->organization[ncnt].
    organization_name = o.org_name
   FOOT REPORT
    stat = alterlist(reply->organization,ncnt)
   WITH nocounter, expand = 1
  ;end select
 ENDIF
#exit_script
 IF (((ncnt=0) OR (org_cnt=0)) )
  SET reply->status_data.operationname = "SELECT"
  SET reply->status_data.targetobjectvalue = "No Records Found"
  SET reply->status_data.operationstatus = "F"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET last_mod = "002 12/07/23"
END GO
