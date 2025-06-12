CREATE PROGRAM dcp_get_pl_asgmt:dba
 RECORD orgs(
   1 qual[*]
     2 org_id = f8
     2 confid_level = i4
 )
 SET encntr_org_sec_ind = 0
 SET confid_ind = 0
 DECLARE dminfo_ok = i2 WITH noconstant(0)
 SET dminfo_ok = validate(ccldminfo->mode,0)
 CALL echo(concat("Ccldminfo exists= ",build(dminfo_ok)))
 IF (dminfo_ok=1)
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
  DECLARE org_cnt = i2 WITH noconstant(0)
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
  SET stat = alterlist(orgs->qual,org_cnt)
  FOR (count = 1 TO org_cnt)
   SET orgs->qual[count].org_id = sac_org->organizations[count].organization_id
   SET orgs->qual[count].confid_level = sac_org->organizations[count].confid_level
  ENDFOR
 ENDIF
 DECLARE loccnt = i4 WITH noconstant(0)
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE arg_nbr = i4 WITH noconstant(cnvtint(size(request->arguments,5)))
 DECLARE counter = i4 WITH noconstant(1)
 DECLARE prsnl_id = f8 WITH noconstant(0.0)
 DECLARE lag_minutes = i4 WITH noconstant(0)
 DECLARE interval = vc
 DECLARE x = i4 WITH noconstant(0)
 DECLARE y = i4 WITH noconstant(0)
 DECLARE facility_type_cd = f8 WITH noconstant(0.0)
 DECLARE building_type_cd = f8 WITH noconstant(0.0)
 DECLARE unit_type_cd = f8 WITH noconstant(0.0)
 DECLARE filterind = i2 WITH noconstant(0)
 SET facility_type_cd = uar_get_code_by("MEANING",222,"FACILITY")
 SET building_type_cd = uar_get_code_by("MEANING",222,"BUILDING")
 SET unit_type_cd = uar_get_code_by("MEANING",222,"NURSEUNIT")
 SET census_type_cd = uar_get_code_by("MEANING",339,"CENSUS")
 SET e_dt_tm = cnvtdatetime(sysdate)
 SET b_dt_tm = cnvtdatetime(sysdate)
 FOR (counter = 1 TO arg_nbr)
   CASE (request->arguments[counter].argument_name)
    OF "prsnl_id":
     SET prsnl_id = cnvtreal(request->arguments[counter].parent_entity_id)
    OF "lag_minutes":
     SET lag_minutes = cnvtint(request->arguments[counter].argument_value)
   ENDCASE
 ENDFOR
 IF (lag_minutes > 0)
  SET interval = build(abs(lag_minutes),"min")
  SET e_dt_tm = cnvtlookahead(interval,cnvtdatetime(sysdate))
  SET b_dt_tm = cnvtlookbehind(interval,cnvtdatetime(sysdate))
 ENDIF
 SET encntr_where = "e.encntr_id = ed.encntr_id and e.active_ind = 1"
 IF (((confid_ind=1) OR (encntr_org_sec_ind=1)) )
  SET filterind = 1
 ELSE
  SET filterind = 0
 ENDIF
 RECORD locations(
   1 qual[*]
     2 loc_facility_cd = f8
     2 loc_building_cd = f8
     2 loc_nurse_unit_cd = f8
     2 loc_room_cd = f8
     2 loc_bed_cd = f8
     2 encntr_id = f8
 )
 SELECT INTO "nl:"
  FROM dcp_care_team_prsnl ctp,
   dcp_shift_assignment sa
  PLAN (ctp
   WHERE ((ctp.prsnl_id=0) OR (ctp.prsnl_id=prsnl_id
    AND ((ctp.beg_effective_dt_tm <= cnvtdatetime(b_dt_tm)
    AND ctp.end_effective_dt_tm >= cnvtdatetime(b_dt_tm)) OR (ctp.beg_effective_dt_tm >= cnvtdatetime
   (b_dt_tm)
    AND ctp.beg_effective_dt_tm <= cnvtdatetime(e_dt_tm))) )) )
   JOIN (sa
   WHERE (sa.careteam_id=(ctp.careteam_id+ 0))
    AND ((sa.prsnl_id=0
    AND sa.careteam_id != 0) OR (sa.prsnl_id=prsnl_id))
    AND sa.active_ind=1
    AND ((sa.beg_effective_dt_tm <= cnvtdatetime(b_dt_tm)
    AND sa.end_effective_dt_tm >= cnvtdatetime(b_dt_tm)) OR (sa.beg_effective_dt_tm >= cnvtdatetime(
    b_dt_tm)
    AND sa.beg_effective_dt_tm <= cnvtdatetime(e_dt_tm))) )
  HEAD REPORT
   loccnt = 0
  DETAIL
   loccnt += 1
   IF (mod(loccnt,10)=1)
    stat = alterlist(locations->qual,(loccnt+ 9))
   ENDIF
   locations->qual[loccnt].loc_facility_cd = sa.loc_facility_cd, locations->qual[loccnt].
   loc_building_cd = sa.loc_building_cd, locations->qual[loccnt].loc_nurse_unit_cd = sa.loc_unit_cd,
   locations->qual[loccnt].loc_room_cd = sa.loc_room_cd, locations->qual[loccnt].loc_bed_cd = sa
   .loc_bed_cd, locations->qual[loccnt].encntr_id = sa.encntr_id
  WITH nocounter
 ;end select
 SET cnt = loccnt
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cnt)),
   location_group lg,
   location_group lg1
  PLAN (d
   WHERE (locations->qual[d.seq].loc_building_cd=0)
    AND (locations->qual[d.seq].encntr_id=0))
   JOIN (lg
   WHERE (lg.parent_loc_cd=locations->qual[d.seq].loc_facility_cd)
    AND lg.location_group_type_cd=facility_type_cd
    AND lg.root_loc_cd=0)
   JOIN (lg1
   WHERE lg1.parent_loc_cd=lg.child_loc_cd
    AND lg1.location_group_type_cd=building_type_cd
    AND lg1.root_loc_cd=0)
  DETAIL
   loccnt += 1
   IF (mod(loccnt,10)=1)
    stat = alterlist(locations->qual,(loccnt+ 9))
   ENDIF
   locations->qual[loccnt].loc_facility_cd = locations->qual[d.seq].loc_facility_cd, locations->qual[
   loccnt].loc_building_cd = lg.child_loc_cd, locations->qual[loccnt].loc_nurse_unit_cd = lg1
   .child_loc_cd,
   locations->qual[loccnt].loc_room_cd = 0, locations->qual[loccnt].loc_bed_cd = 0, locations->qual[
   loccnt].encntr_id = 0
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cnt)),
   location_group lg
  PLAN (d
   WHERE (locations->qual[d.seq].loc_nurse_unit_cd=0)
    AND (locations->qual[d.seq].encntr_id=0))
   JOIN (lg
   WHERE (lg.parent_loc_cd=locations->qual[d.seq].loc_building_cd)
    AND lg.location_group_type_cd=building_type_cd
    AND lg.root_loc_cd=0)
  DETAIL
   loccnt += 1
   IF (mod(loccnt,10)=1)
    stat = alterlist(locations->qual,(loccnt+ 9))
   ENDIF
   locations->qual[loccnt].loc_facility_cd = locations->qual[d.seq].loc_facility_cd, locations->qual[
   loccnt].loc_building_cd = locations->qual[d.seq].loc_building_cd, locations->qual[loccnt].
   loc_nurse_unit_cd = lg.child_loc_cd,
   locations->qual[loccnt].loc_room_cd = 0, locations->qual[loccnt].loc_bed_cd = 0, locations->qual[
   loccnt].encntr_id = 0
  WITH nocounter
 ;end select
 SET cnt = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(loccnt)),
   encntr_domain ed,
   encounter e,
   person p
  PLAN (d
   WHERE (locations->qual[d.seq].loc_nurse_unit_cd > 0))
   JOIN (ed
   WHERE ed.encntr_domain_type_cd=census_type_cd
    AND (ed.loc_nurse_unit_cd=locations->qual[d.seq].loc_nurse_unit_cd)
    AND ed.end_effective_dt_tm >= cnvtdatetime(b_dt_tm)
    AND (((ed.loc_room_cd=locations->qual[d.seq].loc_room_cd)) OR ((locations->qual[d.seq].
   loc_room_cd=0)))
    AND (((ed.loc_bed_cd=locations->qual[d.seq].loc_bed_cd)) OR ((locations->qual[d.seq].loc_bed_cd=0
   )))
    AND (((ed.encntr_id=locations->qual[d.seq].encntr_id)) OR ((locations->qual[d.seq].encntr_id=0)
   ))
    AND ed.active_ind=1)
   JOIN (e
   WHERE parser(encntr_where))
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1)
  ORDER BY e.encntr_id
  HEAD REPORT
   cnt = 0
  HEAD e.encntr_id
   cnt += 1
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->patients,(cnt+ 9))
   ENDIF
   reply->patients[cnt].person_id = p.person_id, reply->patients[cnt].person_name = p
   .name_full_formatted, reply->patients[cnt].encntr_id = e.encntr_id,
   reply->patients[cnt].priority = 0, reply->patients[cnt].active_ind = 1, reply->patients[cnt].
   organization_id = e.organization_id,
   reply->patients[cnt].confid_level_cd = e.confid_level_cd, reply->patients[cnt].confid_level =
   uar_get_collation_seq(e.confid_level_cd)
   IF ((reply->patients[cnt].confid_level < 0))
    reply->patients[cnt].confid_level = 0
   ENDIF
   reply->patients[cnt].filter_ind = filterind
  FOOT REPORT
   stat = alterlist(reply->patients,cnt)
  WITH nocounter
 ;end select
 IF (((confid_ind=1) OR (encntr_org_sec_ind=1))
  AND cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(cnt)),
    person_prsnl_reltn ppr,
    code_value_extension cve
   PLAN (d
    WHERE (reply->patients[d.seq].filter_ind=1))
    JOIN (ppr
    WHERE (ppr.person_id=reply->patients[d.seq].person_id)
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
     AND ((confid_ind=0) OR ((reply->patients[d.seq].confid_level=0))) )) )
     reply->patients[d.seq].filter_ind = 0
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(cnt)),
    (dummyt d2  WITH seq = value(org_cnt))
   PLAN (d
    WHERE (reply->patients[d.seq].filter_ind=1))
    JOIN (d2
    WHERE (orgs->qual[d2.seq].org_id=reply->patients[d.seq].organization_id))
   DETAIL
    IF (((confid_ind=0) OR ((orgs->qual[d2.seq].confid_level >= reply->patients[d.seq].confid_level)
    )) )
     reply->patients[d.seq].filter_ind = 0
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(cnt)),
    encntr_prsnl_reltn epr
   PLAN (d
    WHERE (reply->patients[d.seq].filter_ind=1))
    JOIN (epr
    WHERE (epr.encntr_id=reply->patients[d.seq].encntr_id)
     AND (epr.prsnl_person_id=reqinfo->updt_id)
     AND epr.expiration_ind=0
     AND epr.active_ind=1
     AND epr.encntr_prsnl_r_cd > 0
     AND epr.beg_effective_dt_tm < cnvtdatetime(sysdate)
     AND epr.end_effective_dt_tm > cnvtdatetime(sysdate))
   DETAIL
    reply->patients[d.seq].filter_ind = 0
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(cnt))
   PLAN (d
    WHERE (reply->patients[d.seq].filter_ind=0))
   HEAD REPORT
    actual_cnt = 0
   DETAIL
    actual_cnt += 1, reply->patients[actual_cnt].person_id = reply->patients[d.seq].person_id, reply
    ->patients[actual_cnt].person_name = reply->patients[d.seq].person_name,
    reply->patients[actual_cnt].encntr_id = reply->patients[d.seq].encntr_id, reply->patients[
    actual_cnt].priority = reply->patients[d.seq].priority, reply->patients[actual_cnt].active_ind =
    reply->patients[d.seq].active_ind,
    reply->patients[actual_cnt].organization_id = reply->patients[d.seq].organization_id, reply->
    patients[actual_cnt].confid_level_cd = reply->patients[d.seq].confid_level_cd, reply->patients[
    actual_cnt].confid_level = reply->patients[d.seq].confid_level,
    reply->patients[actual_cnt].filter_ind = reply->patients[d.seq].filter_ind
   FOOT REPORT
    cnt = actual_cnt, stat = alterlist(reply->patients,cnt)
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET cnt = 0
   SET stat = alterlist(reply->patients,cnt)
  ENDIF
 ENDIF
 IF (cnt > 0
  AND (request->patient_list_id > 0))
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(cnt)),
    dcp_pl_prioritization p
   PLAN (d)
    JOIN (p
    WHERE (p.patient_list_id=request->patient_list_id)
     AND (p.person_id=reply->patients[d.seq].person_id))
   DETAIL
    reply->patients[d.seq].priority = p.priority
   WITH nocounter
  ;end select
 ENDIF
 IF (cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET script_version = "004 05/31/07 MN014019"
END GO
