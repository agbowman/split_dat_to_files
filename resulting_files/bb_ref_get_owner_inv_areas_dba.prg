CREATE PROGRAM bb_ref_get_owner_inv_areas:dba
 RECORD reply(
   1 ownerlist[*]
     2 owner_cd = f8
     2 owner_disp = vc
     2 invlist[*]
       3 inventory_cd = f8
       3 inventory_disp = vc
       3 org_id = f8
       3 restrict_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE dm_security = vc WITH protect, constant("SECURITY")
 DECLARE dm_org_security = vc WITH protect, constant("SEC_ORG_RELTN")
 DECLARE dm_confid = vc WITH protect, constant("SEC_CONFID")
 DECLARE encntr_org_sec_ind = i2 WITH protect, noconstant(0)
 DECLARE confid_sec_ind = i2 WITH protect, noconstant(0)
 DECLARE subeventstatus_cnt = i4 WITH protect, noconstant(0)
 DECLARE security_determined_ind = i2 WITH protect, noconstant(0)
 SUBROUTINE (scsscripterror(opname=vc,opstat=vc,tarobjname=vc,tarobjval=vc) =null)
   SET subeventstatus_cnt += 1
   SET stat = alter(reply->status_data.subeventstatus,subeventstatus_cnt)
   SET reply->status_data.subeventstatus[subeventstatus_cnt].operationname = build(opname)
   SET reply->status_data.subeventstatus[subeventstatus_cnt].operationstatus = build(opstat)
   SET reply->status_data.subeventstatus[subeventstatus_cnt].targetobjectname = build(tarobjname)
   SET reply->status_data.subeventstatus[subeventstatus_cnt].targetobjectvalue = build(tarobjval)
 END ;Subroutine
 DECLARE scscheckorgsecandconfid() = null
 SUBROUTINE scscheckorgsecandconfid(null)
   SET encntr_org_sec_ind = 0
   SET confid_sec_ind = 0
   SET security_determined_ind = 1
   SELECT INTO "nl:"
    FROM dm_info di
    PLAN (di
     WHERE di.info_domain=dm_security
      AND di.info_name IN (dm_org_security, dm_confid))
    DETAIL
     IF (di.info_name=dm_org_security
      AND di.info_number=1)
      encntr_org_sec_ind = 1
     ELSEIF (di.info_name=dm_confid
      AND di.info_number=1)
      confid_sec_ind = 1
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE (scschecksecurity(person_id=f8(value),encntr_id=f8(value)) =i2)
   DECLARE por_confid_level = i4 WITH noconstant(0), protect
   DECLARE confid_level = i4 WITH noconstant(0), protect
   DECLARE security_granted = i2 WITH noconstant(0), protect
   IF (security_determined_ind=0)
    CALL scscheckorgsecandconfid(null)
   ENDIF
   IF (encntr_org_sec_ind=0
    AND confid_sec_ind=0)
    SET security_granted = 1
   ELSE
    SELECT
     IF (encntr_id > 0)
      PLAN (e
       WHERE e.encntr_id=encntr_id)
       JOIN (por
       WHERE (por.person_id=reqinfo->updt_id)
        AND por.organization_id=e.organization_id)
     ELSE
      PLAN (e
       WHERE e.person_id=person_id)
       JOIN (por
       WHERE (por.person_id=reqinfo->updt_id)
        AND por.organization_id=e.organization_id)
     ENDIF
     INTO "nl:"
     FROM encounter e,
      prsnl_org_reltn por
     DETAIL
      IF (confid_sec_ind=1)
       confid_level = uar_get_collation_seq(e.confid_level_cd), por_confid_level =
       uar_get_collation_seq(por.confid_level_cd)
       IF (por_confid_level >= confid_level)
        security_granted = 1
       ENDIF
      ELSE
       security_granted = 1
      ENDIF
     WITH nocounter
    ;end select
    IF (security_granted=0)
     SELECT INTO "nl:"
      FROM person_prsnl_reltn ppr
      WHERE ppr.person_id=person_id
       AND (ppr.prsnl_person_id=reqinfo->updt_id)
       AND ppr.end_effective_dt_tm >= cnvtdatetime(sysdate)
       AND ppr.active_ind=1
      DETAIL
       security_granted = 1
      WITH nocounter
     ;end select
    ENDIF
    IF (security_granted=0)
     IF (encntr_id > 0)
      SELECT INTO "nl:"
       FROM encntr_prsnl_reltn epr
       WHERE epr.encntr_id=encntr_id
        AND (epr.prsnl_person_id=reqinfo->updt_id)
        AND epr.end_effective_dt_tm >= cnvtdatetime(sysdate)
        AND epr.active_ind=1
       DETAIL
        security_granted = 1
       WITH nocounter
      ;end select
     ELSE
      SELECT INTO "nl:"
       FROM encounter e,
        encntr_prsnl_reltn epr
       PLAN (e
        WHERE e.person_id=person_id)
        JOIN (epr
        WHERE epr.encntr_id=e.encntr_id
         AND (epr.prsnl_person_id=reqinfo->updt_id)
         AND epr.end_effective_dt_tm >= cnvtdatetime(sysdate)
         AND epr.active_ind=1)
       DETAIL
        security_granted = 1
       WITH nocounter
      ;end select
     ENDIF
    ENDIF
   ENDIF
   RETURN(security_granted)
 END ;Subroutine
 DECLARE nchecksecurityflag = i2 WITH protect, noconstant(0)
 DECLARE d222_bbownerroot_cd = f8
 DECLARE scdf_meaning = c12
 SET serrormsg = fillstring(255," ")
 SET serror_check = error(serrormsg,1)
 SET d222_bbownerroot_cd = 0.0
 SET nownercnt = 0
 SET ninvcnt = 0
 CALL scscheckorgsecandconfid(null)
 IF (((encntr_org_sec_ind=1) OR (confid_sec_ind=1)) )
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
  SET nchecksecurityflag = 1
 ENDIF
 SET scdf_meaning = "BBOWNERROOT"
 SET stat = uar_get_meaning_by_codeset(222,scdf_meaning,1,d222_bbownerroot_cd)
 IF (d222_bbownerroot_cd=0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Code lookup for BBOWNERROOT in codeset 222 failed"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  l.location_cd, lg.location_group_type_cd, cv.code_value
  FROM location l,
   location_group lg,
   code_value cv,
   location l2
  PLAN (l
   WHERE l.location_type_cd=d222_bbownerroot_cd
    AND l.active_ind=1
    AND l.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND l.end_effective_dt_tm >= cnvtdatetime(sysdate))
   JOIN (lg
   WHERE lg.parent_loc_cd=l.location_cd
    AND lg.active_ind=1
    AND lg.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND lg.end_effective_dt_tm >= cnvtdatetime(sysdate))
   JOIN (cv
   WHERE lg.child_loc_cd=cv.code_value
    AND cv.cdf_meaning="BBINVAREA"
    AND cv.active_ind=1)
   JOIN (l2
   WHERE l2.location_cd=lg.child_loc_cd)
  ORDER BY lg.parent_loc_cd, lg.child_loc_cd
  HEAD REPORT
   nownercnt = 0, stat = alterlist(reply->ownerlist,10)
  HEAD lg.parent_loc_cd
   nownercnt += 1
   IF (mod(nownercnt,10)=1
    AND nownercnt != 1)
    stat = alterlist(reply->ownerlist,(nownercnt+ 9))
   ENDIF
   ninvcnt = 0, stat = alterlist(reply->ownerlist[nownercnt].invlist,5), reply->ownerlist[nownercnt].
   owner_cd = lg.parent_loc_cd
  HEAD lg.child_loc_cd
   ninvcnt += 1
   IF (mod(ninvcnt,5)=1
    AND ninvcnt != 1)
    stat = alterlist(reply->ownerlist[nownercnt].invlist,(ninvcnt+ 4))
   ENDIF
   reply->ownerlist[nownercnt].invlist[ninvcnt].inventory_cd = lg.child_loc_cd, reply->ownerlist[
   nownercnt].invlist[ninvcnt].org_id = l2.organization_id
   IF (nchecksecurityflag=0)
    reply->ownerlist[nownercnt].invlist[ninvcnt].restrict_ind = 0
   ELSE
    reply->ownerlist[nownercnt].invlist[ninvcnt].restrict_ind = getaccessind(l2.organization_id)
   ENDIF
  FOOT  lg.parent_loc_cd
   stat = alterlist(reply->ownerlist[nownercnt].invlist,ninvcnt)
  FOOT REPORT
   stat = alterlist(reply->ownerlist,nownercnt)
  WITH nocounter
 ;end select
 SET serror_check = error(serrormsg,0)
 IF (serror_check=0)
  IF (curqual > 0)
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ELSE
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
 ENDIF
 SUBROUTINE (getaccessind(dorgid=f8) =i2)
   DECLARE lidx = i4 WITH protect, noconstant(0)
   DECLARE lcnt = i4 WITH protect, noconstant(0)
   SET lcnt = size(sac_org->organizations,5)
   FOR (lidx = 1 TO lcnt)
     IF ((dorgid=sac_org->organizations[lidx].organization_id))
      RETURN(0)
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
#exit_script
END GO
