CREATE PROGRAM dcp_get_prsnl_asgmt_hist:dba
 RECORD reply(
   1 qual_shift[*]
     2 beg_dt_tm = dq8
     2 end_dt_tm = dq8
     2 qual_loc[*]
       3 fac_cd = f8
       3 fac_disp = vc
       3 bldg_cd = f8
       3 bldg_disp = vc
       3 nu_cd = f8
       3 nu_disp = vc
       3 rm_cd = f8
       3 rm_disp = vc
       3 bed_cd = f8
       3 bed_disp = vc
       3 qual_person[*]
         4 person_id = f8
         4 encntr_id = f8
         4 name_full_formatted = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 org_cnt = i2
   1 orglist[*]
     2 org_id = f8
     2 confid_level = i4
   1 shifts[*]
     2 beg_dt_tm = dq8
     2 end_dt_tm = dq8
     2 fac_cd = f8
     2 bldg_cd = f8
     2 nu_cd = f8
     2 rm_cd = f8
     2 bed_cd = f8
     2 person_id = f8
     2 encntr_id = f8
   1 patients[*]
     2 shift = i4
     2 person_id = f8
     2 encntr_id = f8
     2 name_full_formatted = vc
     2 confid_level = i4
     2 org_id = f8
     2 active_ind = i2
 )
 SET reply->status_data.status = "F"
 SET fac_disp = fillstring(40," ")
 SET bld_disp = fillstring(40," ")
 SET nu_disp = fillstring(40," ")
 SET rm_disp = fillstring(40," ")
 SET bed_disp = fillstring(40," ")
 DECLARE loc_qual = i4 WITH noconstant(0)
 DECLARE shift_qual = i4 WITH noconstant(0)
 DECLARE person_qual = i4 WITH noconstant(0)
 DECLARE confid_ind = i4 WITH noconstant(0)
 DECLARE count = i4 WITH noconstant(0)
 DECLARE security_ind = i4 WITH noconstant(0)
 DECLARE shft_cnt = i4 WITH noconstant(0)
 DECLARE patient_cnt = i4 WITH noconstant(0)
 DECLARE active_sec_ind = i4 WITH noconstant(1)
 DECLARE x = i4 WITH noconstant(0)
 DECLARE y = i4 WITH noconstant(0)
 DECLARE sequence = i4 WITH noconstant(0)
 DECLARE qual_one = i4 WITH noconstant(1)
 SET b_dt_tm = cnvtdatetime(request->beg_dt_tm)
 SET e_dt_tm = cnvtdatetime(request->end_dt_tm)
 DECLARE temp_loc = vc WITH noconstant("")
 DECLARE begin_time = f8 WITH noconstant(cnvtdatetime(sysdate))
 DECLARE exec_time = f8 WITH noconstant(cnvtdatetime(sysdate))
 IF (validate(ccldminfo->mode,0))
  SET security_ind = ccldminfo->sec_org_reltn
  SET confid_ind = ccldminfo->sec_confid
  IF (confid_ind)
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
     security_ind = 1
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
 SELECT INTO "nl:"
  FROM dcp_care_team_prsnl ctp,
   dcp_shift_assignment sa
  PLAN (ctp
   WHERE (((ctp.prsnl_id=request->prsnl_id)
    AND ((ctp.beg_effective_dt_tm <= cnvtdatetime(b_dt_tm)
    AND ctp.end_effective_dt_tm >= cnvtdatetime(b_dt_tm)) OR (ctp.beg_effective_dt_tm >= cnvtdatetime
   (b_dt_tm)
    AND ctp.beg_effective_dt_tm <= cnvtdatetime(e_dt_tm))) ) OR (ctp.prsnl_id=0)) )
   JOIN (sa
   WHERE sa.careteam_id=ctp.careteam_id
    AND ((sa.prsnl_id=0) OR ((sa.prsnl_id=request->prsnl_id)))
    AND ((sa.beg_effective_dt_tm <= cnvtdatetime(b_dt_tm)
    AND sa.end_effective_dt_tm >= cnvtdatetime(b_dt_tm)) OR (sa.beg_effective_dt_tm >= cnvtdatetime(
    b_dt_tm)
    AND sa.beg_effective_dt_tm <= cnvtdatetime(e_dt_tm))) )
  ORDER BY sa.beg_effective_dt_tm, sa.end_effective_dt_tm, sa.loc_facility_cd,
   sa.loc_building_cd, sa.loc_unit_cd, sa.loc_room_cd,
   sa.person_id, sa.loc_bed_cd
  DETAIL
   shft_cnt += 1, stat = alterlist(temp->shifts,shft_cnt), temp->shifts[shft_cnt].beg_dt_tm =
   cnvtdatetime(sa.beg_effective_dt_tm),
   temp->shifts[shft_cnt].end_dt_tm = cnvtdatetime(sa.end_effective_dt_tm), temp->shifts[shft_cnt].
   fac_cd = sa.loc_facility_cd, temp->shifts[shft_cnt].bldg_cd = sa.loc_building_cd,
   temp->shifts[shft_cnt].nu_cd = sa.loc_unit_cd, temp->shifts[shft_cnt].rm_cd = sa.loc_room_cd, temp
   ->shifts[shft_cnt].bed_cd = sa.loc_bed_cd,
   temp->shifts[shft_cnt].person_id = sa.person_id, temp->shifts[shft_cnt].encntr_id = sa.encntr_id
  WITH nocounter
 ;end select
 IF (shft_cnt != 0)
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(size(temp->shifts,5))),
    encntr_loc_hist elh,
    encounter e,
    person p
   PLAN (d1
    WHERE (temp->shifts[d1.seq].rm_cd > 0)
     AND (temp->shifts[d1.seq].encntr_id=0))
    JOIN (elh
    WHERE elh.end_effective_dt_tm >= cnvtdatetime(temp->shifts[d1.seq].beg_dt_tm)
     AND (elh.loc_facility_cd=temp->shifts[d1.seq].fac_cd)
     AND (elh.loc_building_cd=temp->shifts[d1.seq].bldg_cd)
     AND (elh.loc_nurse_unit_cd=temp->shifts[d1.seq].nu_cd)
     AND (elh.loc_room_cd=temp->shifts[d1.seq].rm_cd)
     AND (((elh.loc_bed_cd=temp->shifts[d1.seq].bed_cd)) OR ((temp->shifts[d1.seq].bed_cd=0)))
     AND elh.active_ind=1
     AND elh.beg_effective_dt_tm <= cnvtdatetime(temp->shifts[d1.seq].end_dt_tm))
    JOIN (e
    WHERE elh.encntr_id=e.encntr_id)
    JOIN (p
    WHERE p.person_id=e.person_id)
   ORDER BY elh.loc_facility_cd, elh.loc_building_cd, elh.loc_nurse_unit_cd,
    elh.loc_room_cd, p.person_id, elh.loc_bed_cd
   DETAIL
    patient_cnt += 1
    IF (patient_cnt > size(temp->patients,5))
     stat = alterlist(temp->patients,(patient_cnt+ 5))
    ENDIF
    temp->patients[patient_cnt].shift = d1.seq, temp->patients[patient_cnt].person_id = p.person_id,
    temp->patients[patient_cnt].encntr_id = e.encntr_id,
    temp->patients[patient_cnt].name_full_formatted = p.name_full_formatted, temp->patients[
    patient_cnt].confid_level = e.confid_level_cd, temp->patients[patient_cnt].org_id = e
    .organization_id,
    temp->patients[patient_cnt].active_ind = active_sec_ind, stat = alterlist(temp->patients,
     patient_cnt)
  ;end select
 ENDIF
 SET exec_time = cnvtdatetime(sysdate)
 IF (shft_cnt != 0)
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(size(temp->shifts,5))),
    encntr_loc_hist elh,
    encounter e,
    person p
   PLAN (d1
    WHERE (temp->shifts[d1.seq].encntr_id > 0))
    JOIN (elh
    WHERE (elh.encntr_id=temp->shifts[d1.seq].encntr_id)
     AND elh.beg_effective_dt_tm <= cnvtdatetime(temp->shifts[d1.seq].beg_dt_tm)
     AND ((elh.end_effective_dt_tm >= cnvtdatetime(temp->shifts[d1.seq].beg_dt_tm)) OR (elh
    .beg_effective_dt_tm >= cnvtdatetime(temp->shifts[d1.seq].beg_dt_tm)
     AND elh.beg_effective_dt_tm <= cnvtdatetime(temp->shifts[d1.seq].end_dt_tm)))
     AND (elh.loc_facility_cd=temp->shifts[d1.seq].fac_cd)
     AND (elh.loc_building_cd=temp->shifts[d1.seq].bldg_cd)
     AND (elh.loc_nurse_unit_cd=temp->shifts[d1.seq].nu_cd)
     AND elh.active_ind=1)
    JOIN (e
    WHERE elh.encntr_id=e.encntr_id)
    JOIN (p
    WHERE p.person_id=e.person_id)
   ORDER BY elh.loc_facility_cd, elh.loc_building_cd, elh.loc_nurse_unit_cd,
    elh.loc_room_cd, p.person_id, elh.loc_bed_cd
   DETAIL
    patient_cnt += 1
    IF (patient_cnt > size(temp->patients,5))
     stat = alterlist(temp->patients,(patient_cnt+ 5))
    ENDIF
    temp->patients[patient_cnt].shift = d1.seq, temp->patients[patient_cnt].person_id = p.person_id,
    temp->patients[patient_cnt].encntr_id = e.encntr_id,
    temp->patients[patient_cnt].name_full_formatted = p.name_full_formatted, temp->patients[
    patient_cnt].confid_level = e.confid_level_cd, temp->patients[patient_cnt].org_id = e
    .organization_id,
    temp->patients[patient_cnt].active_ind = active_sec_ind, stat = alterlist(temp->patients,
     patient_cnt)
   WITH nocounter
  ;end select
 ENDIF
 CALL echo(build("Select Time: ",datetimediff(cnvtdatetime(sysdate),exec_time,5)))
 CALL echo(build("Execution Time: ",datetimediff(cnvtdatetime(sysdate),begin_time,5)))
 IF (security_ind=1
  AND shft_cnt != 0
  AND patient_cnt > 0
  AND org_cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d2  WITH seq = value(org_cnt)),
    (dummyt d3  WITH seq = value(patient_cnt))
   PLAN (d2)
    JOIN (d3
    WHERE (temp->patients[d3.seq].org_id=sac_org->organizations[d2.seq].organization_id))
   DETAIL
    IF (((confid_ind=0) OR ((temp->orglist[d2.seq].confid_level >= sac_org->organizations[d2.seq].
    confid_level))) )
     temp->patients[d3.seq].active_ind = 1
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (shft_cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF (shft_cnt != 0)
  FOR (x = 1 TO shft_cnt)
    IF ((((reply->qual_shift[shift_qual].beg_dt_tm != temp->shifts[x].beg_dt_tm)) OR ((reply->
    qual_shift[shift_qual].end_dt_tm != temp->shifts[x].end_dt_tm))) )
     SET shift_qual += 1
     SET stat = alterlist(reply->qual_shift,shift_qual)
     SET reply->qual_shift[shift_qual].beg_dt_tm = temp->shifts[x].beg_dt_tm
     SET reply->qual_shift[shift_qual].end_dt_tm = temp->shifts[x].end_dt_tm
     SET loc_qual = 0
     SET person_qual = 0
    ENDIF
    IF ((((reply->qual_shift[shift_qual].qual_loc[loc_qual].fac_cd != temp->shifts[x].fac_cd)) OR (((
    (reply->qual_shift[shift_qual].qual_loc[loc_qual].bldg_cd != temp->shifts[x].bldg_cd)) OR ((((
    reply->qual_shift[shift_qual].qual_loc[loc_qual].nu_cd != temp->shifts[x].nu_cd)) OR ((((reply->
    qual_shift[shift_qual].qual_loc[loc_qual].rm_cd != temp->shifts[x].rm_cd)) OR ((reply->
    qual_shift[shift_qual].qual_loc[loc_qual].bed_cd != temp->shifts[x].bed_cd))) )) )) )) )
     SET loc_qual += 1
     SET stat = alterlist(reply->qual_shift[shift_qual].qual_loc,loc_qual)
     SET reply->qual_shift[shift_qual].qual_loc[loc_qual].fac_cd = temp->shifts[x].fac_cd
     SET reply->qual_shift[shift_qual].qual_loc[loc_qual].fac_disp = uar_get_code_display(temp->
      shifts[x].fac_cd)
     SET reply->qual_shift[shift_qual].qual_loc[loc_qual].bldg_cd = temp->shifts[x].bldg_cd
     SET reply->qual_shift[shift_qual].qual_loc[loc_qual].bldg_disp = uar_get_code_display(temp->
      shifts[x].bldg_cd)
     SET reply->qual_shift[shift_qual].qual_loc[loc_qual].nu_cd = temp->shifts[x].nu_cd
     SET reply->qual_shift[shift_qual].qual_loc[loc_qual].nu_disp = uar_get_code_display(temp->
      shifts[x].nu_cd)
     SET reply->qual_shift[shift_qual].qual_loc[loc_qual].rm_cd = temp->shifts[x].rm_cd
     SET reply->qual_shift[shift_qual].qual_loc[loc_qual].rm_disp = uar_get_code_display(temp->
      shifts[x].rm_cd)
     SET reply->qual_shift[shift_qual].qual_loc[loc_qual].bed_cd = temp->shifts[x].bed_cd
     SET reply->qual_shift[shift_qual].qual_loc[loc_qual].bed_disp = uar_get_code_display(temp->
      shifts[x].bed_cd)
     SET person_qual = 0
    ENDIF
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = patient_cnt)
     PLAN (d
      WHERE (temp->patients[d.seq].shift=x)
       AND (temp->patients[d.seq].active_ind=1))
     DETAIL
      person_qual += 1, stat = alterlist(reply->qual_shift[shift_qual].qual_loc[loc_qual].qual_person,
       person_qual), reply->qual_shift[shift_qual].qual_loc[loc_qual].qual_person[person_qual].
      person_id = temp->patients[d.seq].person_id,
      reply->qual_shift[shift_qual].qual_loc[loc_qual].qual_person[person_qual].encntr_id = temp->
      patients[d.seq].encntr_id, reply->qual_shift[shift_qual].qual_loc[loc_qual].qual_person[
      person_qual].name_full_formatted = temp->patients[d.seq].name_full_formatted
    ;end select
  ENDFOR
 ENDIF
END GO
