CREATE PROGRAM dcp_chk_valid_encntr:dba
 RECORD reply(
   1 restrict_ind = i2
   1 encntr_id = f8
   1 encntr_type_cd = f8
   1 encntr_type_disp = vc
   1 encntr_type_class_cd = f8
   1 encntr_type_class_disp = vc
   1 encntr_status_cd = f8
   1 encntr_status_disp = vc
   1 reg_dt_tm = dq8
   1 location_cd = f8
   1 loc_facility_cd = f8
   1 loc_facility_disp = vc
   1 loc_building_cd = f8
   1 loc_building_disp = vc
   1 loc_nurse_unit_cd = f8
   1 loc_nurse_unit_disp = vc
   1 loc_room_cd = f8
   1 loc_room_disp = vc
   1 loc_bed_cd = f8
   1 loc_bed_disp = vc
   1 reason_for_visit = vc
   1 financial_class_cd = f8
   1 financial_class_disp = vc
   1 beg_effective_dt_tm = dq8
   1 disch_dt_tm = dq8
   1 med_service_cd = f8
   1 diet_type_cd = f8
   1 isolation_cd = f8
   1 encntr_financial_id = f8
   1 arrive_dt_tm = dq8
   1 provider_list[*]
     2 provider_id = f8
     2 provider_name = vc
     2 relationship_cd = f8
     2 relationship_disp = vc
     2 relationship_mean = c12
   1 organization_id = f8
   1 time_zone_indx = i4
   1 est_disch_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 org_list[*]
     2 organization_id = f8
     2 confid_level = i4
   1 person_id = f8
   1 encntr_id = f8
   1 organization_id = f8
   1 confid_level = i4
   1 auth_ind = i2
   1 encntr_type_cd = f8
   1 encntr_type_disp = vc
   1 encntr_type_class_cd = f8
   1 encntr_type_class_disp = vc
   1 encntr_status_cd = f8
   1 encntr_status_disp = vc
   1 reg_dt_tm = dq8
   1 location_cd = f8
   1 loc_facility_cd = f8
   1 loc_facility_disp = vc
   1 loc_building_cd = f8
   1 loc_building_disp = vc
   1 loc_nurse_unit_cd = f8
   1 loc_nurse_unit_disp = vc
   1 loc_room_cd = f8
   1 loc_room_disp = vc
   1 loc_bed_cd = f8
   1 loc_bed_disp = vc
   1 reason_for_visit = vc
   1 financial_class_cd = f8
   1 financial_class_disp = vc
   1 beg_effective_dt_tm = dq8
   1 disch_dt_tm = dq8
   1 med_service_cd = f8
   1 diet_type_cd = f8
   1 isolation_cd = f8
   1 encntr_financial_id = f8
   1 arrive_dt_tm = dq8
   1 est_disch_dt_tm = dq8
   1 time_zone = i4
 )
 RECORD encntrloctzreq(
   1 encntrs[*]
     2 encntr_id = f8
   1 facilities[*]
     2 loc_facility_cd = f8
 )
 RECORD encntrloctzrep(
   1 encntrs_qual_cnt = i4
   1 encntrs[*]
     2 encntr_id = f8
     2 time_zone_indx = i4
     2 time_zone = vc
     2 status = i2
   1 facilities_qual_cnt = i4
   1 facilities[*]
     2 loc_facility_cd = f8
     2 time_zone_indx = i4
     2 time_zone = vc
     2 status = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE org_cnt = i4 WITH noconstant(0)
 DECLARE provider_cnt = i4 WITH noconstant(0)
 DECLARE person_id = f8 WITH noconstant(0.0)
 DECLARE encntr_id = f8 WITH noconstant(0.0)
 DECLARE encntr_org_sec_ind = i2 WITH noconstant(0)
 DECLARE confid_ind = i2 WITH noconstant(0)
 DECLARE attendcd = f8 WITH noconstant(0.0)
 DECLARE admitcd = f8 WITH noconstant(0.0)
 DECLARE ordercd = f8 WITH noconstant(0.0)
 DECLARE refercd = f8 WITH noconstant(0.0)
 DECLARE auth_ind = i2 WITH noconstant(0)
 SET reply->restrict_ind = 0
 IF (validate(ccldminfo->mode,0))
  SET encntr_org_sec_ind = ccldminfo->sec_org_reltn
  SET confid_ind = ccldminfo->sec_confid
 ELSE
  SELECT INTO "nl:"
   FROM dm_info di
   PLAN (di
    WHERE di.info_domain="SECURITY"
     AND di.info_name IN ("SEC_ORG_RELTN", "SEC_CONFID"))
   DETAIL
    IF (di.info_name="SEC_ORG_RELTN"
     AND di.info_number=1)
     encntr_org_sec_ind = 1
    ELSEIF (di.info_name="SEC_CONFID"
     AND di.info_number=1)
     confid_ind = 1
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (((encntr_org_sec_ind=1) OR (confid_ind=1)) )
  SET auth_ind = 0
  SET reply->restrict_ind = 1
 ELSE
  SET auth_ind = 1
  SET reply->restrict_ind = 0
 ENDIF
 IF (((encntr_org_sec_ind=1) OR (((confid_ind=1) OR ((request->force_encntrs_ind=1))) )) )
  SELECT INTO "nl:"
   FROM encounter e
   PLAN (e
    WHERE (e.person_id=request->person_id)
     AND (e.encntr_id=request->encntr_id)
     AND e.active_ind=1)
   DETAIL
    temp->person_id = e.person_id, temp->encntr_id = e.encntr_id, temp->organization_id = e
    .organization_id,
    temp->confid_level = uar_get_collation_seq(e.confid_level_cd)
    IF ((temp->confid_level < 0))
     temp->confid_level = 0
    ENDIF
    temp->encntr_type_cd = e.encntr_type_cd, temp->encntr_type_class_cd = e.encntr_type_class_cd,
    temp->encntr_status_cd = e.encntr_status_cd,
    temp->reg_dt_tm = e.reg_dt_tm, temp->location_cd = e.location_cd, temp->loc_facility_cd = e
    .loc_facility_cd,
    temp->loc_building_cd = e.loc_building_cd, temp->loc_nurse_unit_cd = e.loc_nurse_unit_cd, temp->
    loc_room_cd = e.loc_room_cd,
    temp->loc_bed_cd = e.loc_bed_cd, temp->reason_for_visit = e.reason_for_visit, temp->
    financial_class_cd = e.financial_class_cd,
    temp->beg_effective_dt_tm = e.beg_effective_dt_tm, temp->disch_dt_tm = e.disch_dt_tm, temp->
    med_service_cd = e.med_service_cd,
    temp->diet_type_cd = e.diet_type_cd, temp->isolation_cd = e.isolation_cd, temp->
    encntr_financial_id = e.encntr_financial_id,
    temp->arrive_dt_tm = e.arrive_dt_tm, temp->est_disch_dt_tm = e.est_depart_dt_tm, temp->auth_ind
     = auth_ind,
    stat = alterlist(encntrloctzreq->facilities,1)
    IF ((temp->loc_facility_cd > 0))
     encntrloctzreq->facilities[1].loc_facility_cd = temp->loc_facility_cd
    ENDIF
   WITH nocounter
  ;end select
  IF ((temp->loc_facility_cd > 0)
   AND curutc)
   EXECUTE pm_get_encntr_loc_tz  WITH replace("REQUEST",encntrloctzreq), replace("REPLY",
    encntrloctzrep)
   IF ((encntrloctzrep->status_data.status="F"))
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = encntrloctzrep->status_data.
    subeventstatus[1].targetobjectvalue
    GO TO exit_script
   ENDIF
  ENDIF
  SET temp->time_zone = encntrloctzrep->facilities[1].time_zone_indx
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
  IF (org_cnt > 0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(org_cnt))
    WHERE (sac_org->organizations[d.seq].organization_id=temp->organization_id)
    HEAD d.seq
     stat = alterlist(temp->org_list,1)
    DETAIL
     temp->org_list[1].confid_level = sac_org->organizations[d.seq].confid_level
     IF ((temp->org_list[1].confid_level < 0))
      temp->org_list[1].confid_level = 0
     ENDIF
     IF (confid_ind=1)
      IF ((temp->confid_level <= temp->org_list[1].confid_level))
       temp->auth_ind = 1
      ENDIF
     ELSE
      temp->auth_ind = 1
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
  IF ((temp->auth_ind=0))
   SELECT INTO "nl:"
    FROM person_prsnl_reltn ppr,
     code_value_extension cve
    PLAN (ppr
     WHERE (ppr.person_id=temp->person_id)
      AND (ppr.prsnl_person_id=reqinfo->updt_id)
      AND ppr.active_ind=1
      AND ppr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND ppr.end_effective_dt_tm > cnvtdatetime(sysdate))
     JOIN (cve
     WHERE cve.code_value=ppr.person_prsnl_r_cd
      AND cve.field_name="Override"
      AND cve.code_set=331)
    DETAIL
     IF (((cve.field_value="2") OR (cve.field_value="1"
      AND ((confid_ind=0) OR ((temp->confid_level=0))) )) )
      temp->auth_ind = 1
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
  IF ((temp->auth_ind=0))
   SELECT INTO "nl:"
    FROM encntr_prsnl_reltn epr
    PLAN (epr
     WHERE (epr.encntr_id=temp->encntr_id)
      AND (epr.prsnl_person_id=reqinfo->updt_id)
      AND epr.expiration_ind=0
      AND epr.active_ind=1
      AND epr.encntr_prsnl_r_cd > 0
      AND epr.beg_effective_dt_tm < cnvtdatetime(sysdate)
      AND epr.end_effective_dt_tm > cnvtdatetime(sysdate))
    DETAIL
     temp->auth_ind = 1
    WITH nocounter
   ;end select
  ENDIF
  SET reply->status_data.status = "Z"
  IF ((temp->auth_ind=1))
   SET reply->status_data.status = "S"
   SET reply->encntr_id = temp->encntr_id
   SET reply->encntr_type_cd = temp->encntr_type_cd
   SET reply->encntr_type_class_cd = temp->encntr_type_class_cd
   SET reply->encntr_status_cd = temp->encntr_status_cd
   SET reply->reg_dt_tm = temp->reg_dt_tm
   SET reply->location_cd = temp->location_cd
   SET reply->loc_facility_cd = temp->loc_facility_cd
   SET reply->loc_building_cd = temp->loc_building_cd
   SET reply->loc_nurse_unit_cd = temp->loc_nurse_unit_cd
   SET reply->loc_room_cd = temp->loc_room_cd
   SET reply->loc_bed_cd = temp->loc_bed_cd
   SET reply->reason_for_visit = temp->reason_for_visit
   SET reply->financial_class_cd = temp->financial_class_cd
   SET reply->beg_effective_dt_tm = temp->beg_effective_dt_tm
   SET reply->disch_dt_tm = temp->disch_dt_tm
   SET reply->med_service_cd = temp->med_service_cd
   SET reply->diet_type_cd = temp->diet_type_cd
   SET reply->isolation_cd = temp->isolation_cd
   SET reply->encntr_financial_id = temp->encntr_financial_id
   SET reply->arrive_dt_tm = temp->arrive_dt_tm
   SET reply->organization_id = temp->organization_id
   SET reply->time_zone_indx = temp->time_zone
   SET reply->est_disch_dt_tm = temp->est_disch_dt_tm WITH nocounter
   IF ((request->provider_ind=1))
    SET attendcd = uar_get_code_by("MEANING",333,"ATTENDDOC")
    SET admitcd = uar_get_code_by("MEANING",333,"ADMITDOC")
    SET ordercd = uar_get_code_by("MEANING",333,"ORDERDOC")
    SET refercd = uar_get_code_by("MEANING",333,"REFERDOC")
    SELECT INTO "nl:"
     FROM encntr_prsnl_reltn epr,
      prsnl p
     PLAN (epr
      WHERE (epr.encntr_id=reply->encntr_id)
       AND epr.encntr_prsnl_r_cd IN (refercd, ordercd, admitcd, attendcd))
      JOIN (p
      WHERE p.person_id=epr.prsnl_person_id)
     ORDER BY temp->encntr_id
     HEAD epr.encntr_id
      provider_cnt = 0
     DETAIL
      provider_cnt += 1, stat = alterlist(reply->provider_list,provider_cnt), reply->provider_list[
      provider_cnt].provider_id = epr.encntr_prsnl_reltn_id,
      reply->provider_list[provider_cnt].provider_name = p.name_full_formatted, reply->provider_list[
      provider_cnt].relationship_cd = epr.encntr_prsnl_r_cd
     WITH nocounter
    ;end select
   ENDIF
  ENDIF
  FREE RECORD temp
 ELSE
  SET reply->status_data.status = "Z"
  SET reply->restrict_ind = 0
 ENDIF
#exit_script
 CALL echorecord(reply)
END GO
