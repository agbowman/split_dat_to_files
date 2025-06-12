CREATE PROGRAM dcp_get_assigned_prsnl:dba
 RECORD reply(
   1 prsnl[*]
     2 person_id = f8
     2 position_cd = f8
     2 position_disp = vc
     2 name_full_formatted = vc
     2 notes[*]
       3 sticky_note_id = f8
       3 sticky_note_text = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 prsnl[*]
     2 prsnl_id = f8
 )
 RECORD loc(
   1 list[*]
     2 encntr_id = f8
     2 fac_cd = f8
     2 building_cd = f8
     2 unit_cd = f8
     2 room_cd = f8
     2 bed_cd = f8
     2 loc_cd = f8
     2 assignment_group_cd = f8
     2 sec_select_ind = i2
   1 custom_loc[*]
     2 encntr_id = f8
     2 assignment_group_cd = f8
     2 sec_select_ind = i2
 )
 SET reply->status_data.status = "F"
 DECLARE getcustomlocations(null) = null
 SET sticky_cd = 0.0
 SET code_set = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET code_set = 14122
 SET cdf_meaning = "SHIFTNOTE"
 EXECUTE cpm_get_cd_for_cdf
 SET sticky_cd = code_value
 SET dt = cnvtdatetime(sysdate)
 SET encntr_org_sec_ind = 0
 SET confid_ind = 0
 SET security_ind = 0
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
 DECLARE prsnlcnt = i4 WITH noconstant(0)
 DECLARE notecnt = i4 WITH noconstant(0)
 FREE RECORD sac_org
 RECORD sac_org(
   1 organizations[*]
     2 organization_id = f8
     2 confid_cd = f8
     2 confid_level = i4
 )
 DECLARE org_cnt = i4 WITH protect, noconstant(0)
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
 CALL echorecord(sac_org)
 DECLARE sec_select_ind = i2 WITH noconstant(0)
 DECLARE loc_idx = i4 WITH noconstant(0)
 DECLARE loc_pos = i4 WITH noconstant(0)
 DECLARE loc_cnt = i4 WITH noconstant(0)
 SELECT INTO "nl:"
  p1.person_id, ed.encntr_id
  FROM encntr_domain ed,
   encounter e
  PLAN (ed
   WHERE (ed.person_id=request->patient_id)
    AND ed.active_ind=1)
   JOIN (e
   WHERE e.encntr_id=ed.encntr_id
    AND ((e.disch_dt_tm=null) OR (e.disch_dt_tm > cnvtdatetime(sysdate))) )
  ORDER BY e.encntr_id
  HEAD e.encntr_id
   loc_cnt = 0
  DETAIL
   loc_cnt += 1
   IF (mod(loc_cnt,10)=1)
    stat = alterlist(loc->list,(loc_cnt+ 9))
   ENDIF
   IF (e.encntr_id != 0
    AND security_ind=1)
    loc_idx = 0, loc->list[loc_cnt].sec_select_ind = 0, loc_pos = locateval(loc_idx,1,org_cnt,e
     .organization_id,sac_org->organizations[loc_idx].organization_id)
    IF (loc_pos != 0)
     IF (((confid_ind=0) OR ((sac_org->organizations[loc_idx].confid_level >= uar_get_collation_seq(e
      .confid_level_cd)))) )
      loc->list[loc_cnt].sec_select_ind = 1
     ENDIF
    ENDIF
   ELSEIF (e.encntr_id != 0
    AND security_ind=0)
    loc->list[loc_cnt].sec_select_ind = 1
   ENDIF
   loc->list[loc_cnt].fac_cd = ed.loc_facility_cd, loc->list[loc_cnt].building_cd = ed
   .loc_building_cd, loc->list[loc_cnt].unit_cd = ed.loc_nurse_unit_cd,
   loc->list[loc_cnt].room_cd = ed.loc_room_cd, loc->list[loc_cnt].bed_cd = ed.loc_bed_cd, loc->list[
   loc_cnt].encntr_id = ed.encntr_id
  FOOT  e.encntr_id
   stat = alterlist(loc->list,loc_cnt)
  WITH nocounter
 ;end select
 IF (loc_cnt=0)
  GO TO exit_script
 ENDIF
 CALL getcustomlocations(null)
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(size(loc->list,5))),
   dcp_shift_assignment sa,
   dcp_care_team_prsnl ctp
  PLAN (d1)
   JOIN (sa
   WHERE (((((loc->list[d1.seq].fac_cd=sa.loc_facility_cd)) OR (sa.loc_facility_cd=0))
    AND (((loc->list[d1.seq].building_cd=sa.loc_building_cd)) OR (sa.loc_building_cd=0))
    AND (((loc->list[d1.seq].unit_cd=sa.loc_unit_cd)) OR (sa.loc_unit_cd=0))
    AND (((loc->list[d1.seq].room_cd=sa.loc_room_cd)) OR (sa.loc_room_cd=0))
    AND (((loc->list[d1.seq].bed_cd=sa.loc_bed_cd)) OR (sa.loc_bed_cd=0))
    AND (((request->patient_id=sa.person_id)) OR (sa.person_id=0))
    AND ((sa.person_id > 0) OR (((sa.loc_bed_cd > 0) OR (((sa.loc_room_cd > 0) OR (((sa.loc_unit_cd
    > 0) OR (((sa.loc_building_cd > 0) OR (sa.loc_facility_cd > 0)) )) )) )) )) ) OR ((loc->list[d1
   .seq].assignment_group_cd=sa.assignment_group_cd)
    AND sa.loc_bed_cd=0
    AND sa.loc_room_cd=0
    AND sa.loc_unit_cd=0
    AND sa.loc_building_cd=0
    AND sa.loc_facility_cd=0
    AND sa.person_id=0))
    AND sa.beg_effective_dt_tm <= cnvtdatetime(dt)
    AND sa.end_effective_dt_tm >= cnvtdatetime(dt))
   JOIN (ctp
   WHERE ctp.careteam_id=sa.careteam_id
    AND ((ctp.careteam_id=0) OR (ctp.beg_effective_dt_tm <= cnvtdatetime(dt)))
    AND ((ctp.careteam_id=0) OR (ctp.end_effective_dt_tm >= cnvtdatetime(dt))) )
  ORDER BY sa.prsnl_id, ctp.prsnl_id
  HEAD sa.prsnl_id
   IF (sa.assignment_id != 0
    AND (loc->list[d1.seq].sec_select_ind=1)
    AND sa.prsnl_id != 0)
    prsnlcnt += 1
    IF (mod(prsnlcnt,10)=1)
     stat = alterlist(temp->prsnl,(prsnlcnt+ 9))
    ENDIF
    temp->prsnl[prsnlcnt].prsnl_id = sa.prsnl_id
   ENDIF
  HEAD ctp.prsnl_id
   IF (ctp.careteam_id != 0
    AND (loc->list[d1.seq].sec_select_ind=1)
    AND ctp.prsnl_id != 0)
    prsnlcnt += 1
    IF (mod(prsnlcnt,10)=1)
     stat = alterlist(temp->prsnl,(prsnlcnt+ 9))
    ENDIF
    temp->prsnl[prsnlcnt].prsnl_id = ctp.prsnl_id
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(temp->prsnl,prsnlcnt)
 IF (prsnlcnt=0)
  GO TO exit_script
 ENDIF
 DECLARE max_expand_cnt = i4 WITH constant(200)
 DECLARE max_expand_dnr = i4 WITH constant(ceil(((prsnlcnt * 1.0)/ max_expand_cnt)))
 DECLARE max_expand_val = i4 WITH constant((max_expand_dnr * max_expand_cnt))
 DECLARE expand_start = i4 WITH noconstant(1)
 DECLARE expand_idx = i4 WITH noconstant(0)
 DECLARE reply_prsnl_cnt = i4 WITH noconstant(0)
 SET stat = alterlist(temp->prsnl,max_expand_val)
 FOR (x = prsnlcnt TO max_expand_val)
   SET temp->prsnl[x].prsnl_id = temp->prsnl[prsnlcnt].prsnl_id
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH value(max_expand_dnr)),
   prsnl p
  PLAN (d1
   WHERE assign(expand_start,evaluate(d1.seq,1,1,(expand_start+ max_expand_cnt))))
   JOIN (p
   WHERE expand(expand_idx,expand_start,(expand_start+ (max_expand_cnt - 1)),p.person_id,temp->prsnl[
    expand_idx].prsnl_id))
  HEAD p.person_id
   reply_prsnl_cnt += 1
   IF (mod(reply_prsnl_cnt,10)=1)
    stat = alterlist(reply->prsnl,(reply_prsnl_cnt+ 9))
   ENDIF
   reply->prsnl[reply_prsnl_cnt].person_id = p.person_id, reply->prsnl[reply_prsnl_cnt].
   name_full_formatted = p.name_full_formatted, reply->prsnl[reply_prsnl_cnt].position_cd = p
   .position_cd
  WITH counter
 ;end select
 SET stat = alterlist(reply->prsnl,reply_prsnl_cnt)
 SET expand_start = 1
 SET loc_idx = 0
 SELECT INTO "nl:"
  FROM (dummyt d2  WITH value(max_expand_dnr)),
   sticky_note sn
  PLAN (d2
   WHERE assign(expand_start,evaluate(d2.seq,1,1,(expand_start+ max_expand_cnt))))
   JOIN (sn
   WHERE expand(expand_idx,expand_start,(expand_start+ (max_expand_cnt - 1)),sn.parent_entity_id,temp
    ->prsnl[expand_idx].prsnl_id)
    AND sn.parent_entity_name="PRSNL"
    AND sn.sticky_note_type_cd=sticky_cd
    AND sn.beg_effective_dt_tm <= cnvtdatetime(dt)
    AND sn.end_effective_dt_tm >= cnvtdatetime(dt))
  ORDER BY sn.parent_entity_id
  HEAD sn.parent_entity_id
   note_cnt = 0, loc_pos = locateval(loc_idx,1,reply_prsnl_cnt,sn.parent_entity_id,reply->prsnl[
    loc_idx].person_id)
  DETAIL
   IF (loc_pos != 0)
    note_cnt += 1
    IF (mod(note_cnt,10)=0)
     stat = alterlist(reply->prsnl[loc_idx].notes,(note_cnt+ 9))
    ENDIF
    reply->prsnl[loc_idx].notes[note_cnt].sticky_note_text = sn.sticky_note_text, reply->prsnl[
    prsnlcnt].notes[notecnt].sticky_note_id = sn.sticky_note_id
   ENDIF
  WITH nocounter
 ;end select
 SUBROUTINE getcustomlocations(null)
   SET encntr_cnt = size(loc->list,5)
   SET loc_cnt = 0
   FOR (i = 1 TO encntr_cnt)
     IF ((loc->list[i].bed_cd > 0))
      SET loc->list[i].loc_cd = loc->list[i].bed_cd
     ELSEIF ((loc->list[i].room_cd > 0))
      SET loc->list[i].loc_cd = loc->list[i].room_cd
     ELSEIF ((loc->list[i].unit_cd > 0))
      SET loc->list[i].loc_cd = loc->list[i].unit_cd
     ELSEIF ((loc->list[i].building_cd > 0))
      SET loc->list[i].loc_cd = loc->list[i].building_cd
     ELSEIF ((loc->list[i].fac_cd > 0))
      SET loc->list[i].loc_cd = loc->list[i].fac_cd
     ENDIF
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(encntr_cnt)),
     location_group lg
    PLAN (d1
     WHERE (loc->list[d1.seq].loc_cd > 0))
     JOIN (lg
     WHERE (lg.child_loc_cd=loc->list[d1.seq].loc_cd)
      AND lg.active_ind=1)
    HEAD REPORT
     loc_cnt = 0
    DETAIL
     IF (lg.root_loc_cd > 0)
      loc_cnt += 1
      IF (mod(loc_cnt,10)=1)
       stat = alterlist(loc->custom_loc,(loc_cnt+ 9))
      ENDIF
      loc->custom_loc[loc_cnt].encntr_id = loc->list[d1.seq].encntr_id, loc->custom_loc[loc_cnt].
      assignment_group_cd = lg.root_loc_cd, loc->custom_loc[loc_cnt].sec_select_ind = loc->list[d1
      .seq].sec_select_ind
     ENDIF
    FOOT REPORT
     stat = alterlist(loc->custom_loc,loc_cnt)
    WITH nocounter
   ;end select
   CALL echo(build("encntr_cnt=",encntr_cnt))
   CALL echo(build("loc_cnt=",loc_cnt))
   SET stat = alterlist(loc->list,(loc_cnt+ encntr_cnt))
   FOR (i = 1 TO loc_cnt)
     SET loc->list[(i+ encntr_cnt)].assignment_group_cd = loc->custom_loc[i].assignment_group_cd
     SET loc->list[(i+ encntr_cnt)].encntr_id = loc->custom_loc[i].encntr_id
     SET loc->list[(i+ encntr_cnt)].sec_select_ind = loc->custom_loc[i].sec_select_ind
   ENDFOR
   SET stat = alterlist(loc->custom_loc,0)
 END ;Subroutine
#exit_script
 IF (prsnlcnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
