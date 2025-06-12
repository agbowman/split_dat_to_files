CREATE PROGRAM dcp_get_pat_asgmt_hist:dba
 RECORD reply(
   1 qual[*]
     2 person_id = f8
     2 name_full_formatted = vc
     2 beg_dt_tm = dq8
     2 end_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 qual[*]
     2 person_id = f8
     2 name_full_formatted = vc
     2 beg_dt_tm = dq8
     2 end_dt_tm = dq8
 )
 RECORD encntr_loc(
   1 qual[*]
     2 encntr_id = f8
     2 organization_id = f8
     2 confid_level = i4
     2 beg_dt_tm = dq8
     2 end_dt_tm = dq8
     2 loc_facility_cd = f8
     2 loc_building_cd = f8
     2 loc_nurse_unit_cd = f8
     2 loc_room_cd = f8
     2 loc_bed_cd = f8
 )
 SET reply->status_data.status = "F"
 SET encntr_org_sec_ind = 0
 SET confid_ind = 0
 SET security_ind = 0
 SET cnt = 0
 SET el_cnt = 0
 SET rep_cnt = 0
 SET temp_cnt = 0
 IF (validate(ccldminfo->mode,0))
  SET encntr_org_sec_ind = ccldminfo->sec_org_reltn
  SET confid_ind = ccldminfo->sec_confid
  IF (((encntr_org_sec_ind) OR (confid_ind)) )
   SET security_ind = 1
  ENDIF
 ELSE
  SELECT INTO "nl:"
   FROM dm_info di
   PLAN (di
    WHERE di.info_domain="SECURITY"
     AND di.info_name IN ("SEC_ORG_RELTN", "SEC_CONFID"))
   DETAIL
    IF (di.info_name="SEC_ORG_RELTN"
     AND di.info_number=1)
     encntr_org_sec_ind = 1, security_ind = 1
    ELSEIF (di.info_name="SEC_CONFID"
     AND di.info_number=1)
     confid_ind = 1, security_ind = 1
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 FREE RECORD sac_org
 RECORD sac_org(
   1 organizations[*]
     2 organization_id = f8
     2 confid_cd = f8
     2 confid_level = i4
 )
 DECLARE org_cnt = i4 WITH noconstant(0)
 IF (security_ind=1)
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
 DECLARE loc_idx = i4 WITH noconstant(0)
 DECLARE loc_pos = i4 WITH noconstant(0)
 DECLARE sec_select_ind = i2 WITH noconstant(0)
 DECLARE set_one = i2 WITH noconstant(0)
 SELECT INTO "nl:"
  ed.encntr_id
  FROM encntr_domain ed,
   encounter e,
   encntr_loc_hist elh
  PLAN (ed
   WHERE (ed.person_id=request->patient_id)
    AND ed.end_effective_dt_tm > cnvtdatetime(request->beg_dt_tm)
    AND ed.beg_effective_dt_tm < cnvtdatetime(request->end_dt_tm))
   JOIN (e
   WHERE e.encntr_id=ed.encntr_id)
   JOIN (elh
   WHERE elh.encntr_id=e.encntr_id
    AND elh.end_effective_dt_tm > cnvtdatetime(request->beg_dt_tm)
    AND elh.beg_effective_dt_tm < cnvtdatetime(request->end_dt_tm))
  ORDER BY elh.encntr_id, elh.end_effective_dt_tm
  HEAD REPORT
   el_cnt = 0
  HEAD elh.encntr_id
   set_one = 0, sec_select_ind = 1
   IF (e.encntr_id != 0
    AND security_ind=1)
    loc_idx = 0, sec_select_ind = 0, loc_pos = locateval(loc_idx,1,org_cnt,e.organization_id,sac_org
     ->organizations[loc_idx].organization_id)
    IF (loc_pos != 0)
     IF (((confid_ind=0) OR ((sac_org->organizations[loc_idx].confid_level >= uar_get_collation_seq(e
      .confid_level_cd)))) )
      sec_select_ind = 1
     ENDIF
    ENDIF
   ENDIF
  HEAD elh.encntr_loc_hist_id
   IF (sec_select_ind=1)
    IF (((set_one=0) OR ((((encntr_loc->qual[el_cnt].loc_facility_cd != elh.loc_facility_cd)) OR ((((
    encntr_loc->qual[el_cnt].loc_building_cd != elh.loc_building_cd)) OR ((((encntr_loc->qual[el_cnt]
    .loc_nurse_unit_cd != elh.loc_nurse_unit_cd)) OR ((((encntr_loc->qual[el_cnt].loc_room_cd != elh
    .loc_room_cd)) OR ((encntr_loc->qual[el_cnt].loc_bed_cd != elh.loc_bed_cd))) )) )) )) )) )
     set_one = 1, el_cnt += 1, stat = alterlist(encntr_loc->qual,el_cnt),
     encntr_loc->qual[el_cnt].encntr_id = elh.encntr_id, encntr_loc->qual[el_cnt].confid_level =
     uar_get_collation_seq(e.confid_level_cd), encntr_loc->qual[el_cnt].organization_id = e
     .organization_id
     IF ((elh.beg_effective_dt_tm < request->beg_dt_tm))
      encntr_loc->qual[el_cnt].beg_dt_tm = request->beg_dt_tm
     ELSE
      encntr_loc->qual[el_cnt].beg_dt_tm = elh.beg_effective_dt_tm
     ENDIF
     IF ((elh.end_effective_dt_tm > request->end_dt_tm))
      encntr_loc->qual[el_cnt].end_dt_tm = request->end_dt_tm
     ELSE
      encntr_loc->qual[el_cnt].end_dt_tm = elh.end_effective_dt_tm
     ENDIF
     encntr_loc->qual[el_cnt].loc_facility_cd = elh.loc_facility_cd, encntr_loc->qual[el_cnt].
     loc_building_cd = elh.loc_building_cd, encntr_loc->qual[el_cnt].loc_nurse_unit_cd = elh
     .loc_nurse_unit_cd,
     encntr_loc->qual[el_cnt].loc_room_cd = elh.loc_room_cd, encntr_loc->qual[el_cnt].loc_bed_cd =
     elh.loc_bed_cd
    ELSE
     IF ((elh.end_effective_dt_tm > request->end_dt_tm))
      encntr_loc->qual[el_cnt].end_dt_tm = request->end_dt_tm
     ELSE
      encntr_loc->qual[el_cnt].end_dt_tm = elh.end_effective_dt_tm
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (el_cnt=0)
  GO TO exit_prg
 ENDIF
 SELECT INTO "nl:"
  sa.assignment_id, ctp.careteam_id, p1.person_id
  FROM (dummyt d1  WITH seq = value(el_cnt)),
   dcp_shift_assignment sa,
   dcp_care_team_prsnl ctp,
   prsnl p1
  PLAN (d1)
   JOIN (sa
   WHERE (((((sa.loc_facility_cd=encntr_loc->qual[d1.seq].loc_facility_cd)) OR (sa.loc_facility_cd=0
   ))
    AND (((sa.loc_building_cd=encntr_loc->qual[d1.seq].loc_building_cd)) OR (sa.loc_building_cd=0))
    AND (((sa.loc_unit_cd=encntr_loc->qual[d1.seq].loc_nurse_unit_cd)) OR (sa.loc_unit_cd=0))
    AND (((sa.loc_room_cd=encntr_loc->qual[d1.seq].loc_room_cd)) OR (sa.loc_room_cd=0))
    AND (((sa.loc_bed_cd=encntr_loc->qual[d1.seq].loc_bed_cd)) OR (sa.loc_bed_cd=0))
    AND sa.person_id=0) OR ((((sa.loc_facility_cd=encntr_loc->qual[d1.seq].loc_facility_cd)) OR (sa
   .loc_facility_cd=0))
    AND (((sa.loc_building_cd=encntr_loc->qual[d1.seq].loc_building_cd)) OR (sa.loc_building_cd=0))
    AND (((sa.loc_unit_cd=encntr_loc->qual[d1.seq].loc_nurse_unit_cd)) OR (sa.loc_unit_cd=0))
    AND (sa.person_id=request->patient_id)))
    AND sa.end_effective_dt_tm >= cnvtdatetime(encntr_loc->qual[d1.seq].beg_dt_tm)
    AND sa.beg_effective_dt_tm <= cnvtdatetime(encntr_loc->qual[d1.seq].end_dt_tm)
    AND (sa.assignment_group_cd=request->assignment_group_cd))
   JOIN (ctp
   WHERE ctp.careteam_id=sa.careteam_id)
   JOIN (p1
   WHERE ((ctp.careteam_id > 0
    AND p1.person_id=ctp.prsnl_id) OR (ctp.careteam_id=0
    AND p1.person_id=sa.prsnl_id)) )
  DETAIL
   temp_cnt += 1, stat = alterlist(temp->qual,temp_cnt), temp->qual[temp_cnt].person_id = p1
   .person_id,
   temp->qual[temp_cnt].name_full_formatted = p1.name_full_formatted, temp->qual[temp_cnt].beg_dt_tm
    = sa.beg_effective_dt_tm, temp->qual[temp_cnt].end_dt_tm = sa.end_effective_dt_tm
   IF ((ctp.end_effective_dt_tm < temp->qual[temp_cnt].end_dt_tm)
    AND ctp.prsnl_id != 0)
    temp->qual[temp_cnt].end_dt_tm = ctp.end_effective_dt_tm
   ENDIF
   IF ((encntr_loc->qual[d1.seq].end_dt_tm < temp->qual[temp_cnt].end_dt_tm)
    AND (request->end_dt_tm != encntr_loc->qual[d1.seq].end_dt_tm))
    temp->qual[temp_cnt].end_dt_tm = encntr_loc->qual[d1.seq].end_dt_tm
   ENDIF
   IF ((ctp.beg_effective_dt_tm > temp->qual[temp_cnt].beg_dt_tm)
    AND ctp.prsnl_id != 0)
    temp->qual[temp_cnt].beg_dt_tm = ctp.beg_effective_dt_tm
   ENDIF
   IF ((encntr_loc->qual[d1.seq].beg_dt_tm > temp->qual[temp_cnt].beg_dt_tm)
    AND (encntr_loc->qual[d1.seq].beg_dt_tm != request->beg_dt_tm))
    temp->qual[temp_cnt].beg_dt_tm = encntr_loc->qual[d1.seq].beg_dt_tm
   ENDIF
  WITH nocounter
 ;end select
 IF (temp_cnt != 0)
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(temp_cnt))
   WHERE d1.seq > 0
   ORDER BY temp->qual[d1.seq].beg_dt_tm, temp->qual[d1.seq].end_dt_tm, temp->qual[d1.seq].person_id
   HEAD REPORT
    first_one = 1, rep_cnt = 0
   DETAIL
    IF (((first_one=1) OR ((((temp->qual[d1.seq].person_id != reply->qual[rep_cnt].person_id)) OR (((
    (temp->qual[d1.seq].beg_dt_tm != reply->qual[rep_cnt].beg_dt_tm)) OR ((temp->qual[d1.seq].
    end_dt_tm != reply->qual[rep_cnt].end_dt_tm))) )) )) )
     first_one = 0, rep_cnt += 1, stat = alterlist(reply->qual,rep_cnt),
     reply->qual[rep_cnt].person_id = temp->qual[d1.seq].person_id, reply->qual[rep_cnt].
     name_full_formatted = temp->qual[d1.seq].name_full_formatted, reply->qual[rep_cnt].beg_dt_tm =
     temp->qual[d1.seq].beg_dt_tm,
     reply->qual[rep_cnt].end_dt_tm = temp->qual[d1.seq].end_dt_tm
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
#exit_prg
 IF (rep_cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
 SET script_version = "004 10/28/05 mk3732"
END GO
