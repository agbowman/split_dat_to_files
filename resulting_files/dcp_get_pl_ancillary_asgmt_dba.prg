CREATE PROGRAM dcp_get_pl_ancillary_asgmt:dba
 CALL echo("Ancillary Assignment")
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
 SET modify = predeclare
 DECLARE loccnt = i4 WITH noconstant(0)
 DECLARE unitcount = i4 WITH noconstant(0)
 DECLARE roomcount = i4 WITH noconstant(0)
 DECLARE bedcount = i4 WITH noconstant(0)
 DECLARE encountercount = i4 WITH noconstant(0)
 DECLARE locationswithoutbuildings = i4 WITH noconstant(0)
 DECLARE locationswithoutnurseunit = i4 WITH noconstant(0)
 DECLARE idx = i4
 DECLARE idx2 = i4
 DECLARE num1 = i4
 DECLARE new_list_size = i4
 DECLARE cur_list_size = i4
 DECLARE batch_size = i4 WITH constant(40)
 DECLARE nstart = i4
 DECLARE loop_cnt = i4
 DECLARE temp = i4
 DECLARE z = i4
 DECLARE seq = i4 WITH noconstant(0)
 DECLARE stat = i4 WITH noconstant(0)
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE index = i4 WITH noconstant(0)
 DECLARE arg_nbr = i4 WITH noconstant(cnvtint(size(request->arguments,5)))
 DECLARE counter = i4 WITH noconstant(1)
 DECLARE prsnl_id = f8 WITH noconstant(0.0)
 DECLARE lag_minutes = i4 WITH noconstant(0)
 DECLARE interval = vc
 DECLARE x = i4 WITH noconstant(0)
 DECLARE y = i4 WITH noconstant(0)
 DECLARE e_dt_tm = q8 WITH noconstant(cnvtdatetime(sysdate))
 DECLARE b_dt_tm = q8 WITH noconstant(cnvtdatetime(sysdate))
 DECLARE pos_cd = f8 WITH noconstant(0.0)
 DECLARE filterind = i2 WITH noconstant(0)
 DECLARE failed = i2 WITH noconstant(0)
 DECLARE select_error = i2 WITH constant(7)
 DECLARE table_name = vc WITH noconstant(fillstring(50," "))
 DECLARE serrmsg = vc WITH noconstant(fillstring(132," "))
 DECLARE facility_type_cd = f8 WITH constant(uar_get_code_by("MEANING",222,"FACILITY"))
 IF (facility_type_cd < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = "Failed to find the code_value for cdf_meaning FACILITY from code_set 222"
  GO TO exit_script
 ENDIF
 DECLARE building_type_cd = f8 WITH constant(uar_get_code_by("MEANING",222,"BUILDING"))
 IF (building_type_cd < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = "Failed to find the code_value for cdf_meaning BUILDING from code_set 222"
  GO TO exit_script
 ENDIF
 DECLARE unit_type_cd = f8 WITH constant(uar_get_code_by("MEANING",222,"NURSEUNIT"))
 IF (unit_type_cd < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = "Failed to find the code_value for cdf_meaning NURSEUNIT from code_set 222"
  GO TO exit_script
 ENDIF
 DECLARE census_type_cd = f8 WITH constant(uar_get_code_by("MEANING",339,"CENSUS"))
 IF (census_type_cd < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = "Failed to find the code_value for cdf_meaning CENSUS from code_set 339"
  GO TO exit_script
 ENDIF
 DECLARE continous_cd = f8 WITH constant(uar_get_code_by("MEANING",6025,"CONT"))
 IF (continous_cd < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = "Failed to find the code_value for cdf_meaning CONT from code_set 6025"
  GO TO exit_script
 ENDIF
 DECLARE prn_cd = f8 WITH constant(uar_get_code_by("MEANING",6025,"PRN"))
 IF (prn_cd < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = "Failed to find the code_value for cdf_meaning PRN from code_set 6025"
  GO TO exit_script
 ENDIF
 DECLARE overdue_cd = f8 WITH constant(uar_get_code_by("MEANING",79,"OVERDUE"))
 IF (overdue_cd < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = "Failed to find the code_value for cdf_meaning OVERDUE from code_set 79"
  GO TO exit_script
 ENDIF
 DECLARE pending_cd = f8 WITH constant(uar_get_code_by("MEANING",79,"PENDING"))
 IF (pending_cd < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = "Failed to find the code_value for cdf_meaning PENDING from code_set 79"
  GO TO exit_script
 ENDIF
 DECLARE inprocess_cd = f8 WITH constant(uar_get_code_by("MEANING",79,"INPROCESS"))
 IF (inprocess_cd < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = "Failed to find the code_value for cdf_meaning INPROCESS from code_set 79"
  GO TO exit_script
 ENDIF
 DECLARE completed_cd = f8 WITH constant(uar_get_code_by("MEANING",79,"COMPLETE"))
 IF (completed_cd < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = "Failed to find the code_value for cdf_meaning COMPLETED from code_set 79"
  GO TO exit_script
 ENDIF
 DECLARE pendval_cd = f8 WITH constant(uar_get_code_by("MEANING",79,"VALIDATION"))
 IF (pendval_cd < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = "Failed to find the code_value for cdf_meaning VALIDATION from code_set 79"
  GO TO exit_script
 ENDIF
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
 CALL echo(build("Beg Time: ",cnvtdatetime(b_dt_tm)))
 CALL echo(build("End Time: ",cnvtdatetime(e_dt_tm)))
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
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
 )
 SELECT INTO "nl:"
  FROM prsnl p,
   dcp_care_team_prsnl ctp,
   dcp_shift_assignment sa
  PLAN (p
   WHERE p.person_id=prsnl_id)
   JOIN (ctp
   WHERE ((ctp.prsnl_id=0) OR (ctp.prsnl_id=p.person_id
    AND ctp.beg_effective_dt_tm <= cnvtdatetime(e_dt_tm)
    AND ctp.end_effective_dt_tm >= cnvtdatetime(b_dt_tm))) )
   JOIN (sa
   WHERE sa.careteam_id=ctp.careteam_id
    AND ((sa.prsnl_id=0
    AND sa.careteam_id != 0) OR (sa.prsnl_id=p.person_id))
    AND sa.beg_effective_dt_tm <= cnvtdatetime(e_dt_tm)
    AND sa.end_effective_dt_tm >= cnvtdatetime(b_dt_tm))
  HEAD REPORT
   loccnt = 0, pos_cd = p.position_cd
  DETAIL
   loccnt += 1
   IF (mod(loccnt,10)=1)
    stat = alterlist(locations->qual,(loccnt+ 9))
   ENDIF
   CALL echo(build("Assigned Location: ",sa.loc_unit_cd)), locations->qual[loccnt].loc_facility_cd =
   sa.loc_facility_cd, locations->qual[loccnt].loc_building_cd = sa.loc_building_cd,
   locations->qual[loccnt].loc_nurse_unit_cd = sa.loc_unit_cd, locations->qual[loccnt].loc_room_cd =
   sa.loc_room_cd, locations->qual[loccnt].loc_bed_cd = sa.loc_bed_cd,
   locations->qual[loccnt].encntr_id = sa.encntr_id
   IF (sa.beg_effective_dt_tm > ctp.beg_effective_dt_tm)
    locations->qual[loccnt].beg_effective_dt_tm = cnvtdatetime(sa.beg_effective_dt_tm)
   ELSE
    locations->qual[loccnt].beg_effective_dt_tm = cnvtdatetime(ctp.beg_effective_dt_tm)
   ENDIF
   IF (sa.end_effective_dt_tm < ctp.end_effective_dt_tm)
    locations->qual[loccnt].end_effective_dt_tm = cnvtdatetime(sa.end_effective_dt_tm)
   ELSE
    locations->qual[loccnt].end_effective_dt_tm = cnvtdatetime(ctp.end_effective_dt_tm)
   ENDIF
   locations->qual[loccnt].beg_effective_dt_tm = sa.beg_effective_dt_tm, locations->qual[loccnt].
   end_effective_dt_tm = sa.end_effective_dt_tm
  FOOT REPORT
   stat = alterlist(locations->qual,loccnt)
  WITH nocounter
 ;end select
 CALL echo(build("# of shifts assigned: ",curqual))
 IF (curqual=0)
  GO TO exit_script
 ENDIF
 SET cnt = loccnt
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(loccnt))
  PLAN (d
   WHERE (locations->qual[d.seq].loc_facility_cd != 0)
    AND (locations->qual[d.seq].loc_building_cd=0)
    AND (locations->qual[d.seq].encntr_id=0))
  HEAD REPORT
   locationswithoutbuildings = 1
  WITH nocounter
 ;end select
 IF (locationswithoutbuildings > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(cnt)),
    location_group lg,
    location_group lg1
   PLAN (d
    WHERE (locations->qual[d.seq].loc_building_cd=0)
     AND (locations->qual[d.seq].encntr_id=0))
    JOIN (lg
    WHERE (lg.parent_loc_cd=locations->qual[d.seq].loc_facility_cd)
     AND ((lg.root_loc_cd+ 0)=0)
     AND lg.active_ind=1
     AND lg.location_group_type_cd=facility_type_cd)
    JOIN (lg1
    WHERE lg1.parent_loc_cd=lg.child_loc_cd
     AND ((lg1.root_loc_cd+ 0)=0)
     AND lg1.active_ind=1
     AND lg1.location_group_type_cd=building_type_cd)
   HEAD REPORT
    IF (mod(size(locations->qual,5),10) != 0)
     stat = alterlist(locations->qual,((10 - mod(size(locations->qual,5),10))+ size(locations->qual,5
       )))
    ENDIF
   DETAIL
    loccnt += 1
    IF (mod(loccnt,10)=1)
     stat = alterlist(locations->qual,(loccnt+ 9))
    ENDIF
    locations->qual[loccnt].loc_facility_cd = locations->qual[d.seq].loc_facility_cd, locations->
    qual[loccnt].beg_effective_dt_tm = locations->qual[d.seq].beg_effective_dt_tm, locations->qual[
    loccnt].end_effective_dt_tm = locations->qual[d.seq].end_effective_dt_tm,
    locations->qual[loccnt].loc_building_cd = lg.child_loc_cd, locations->qual[loccnt].
    loc_nurse_unit_cd = lg1.child_loc_cd, locations->qual[loccnt].loc_room_cd = 0,
    locations->qual[loccnt].loc_bed_cd = 0, locations->qual[loccnt].encntr_id = 0
   FOOT REPORT
    stat = alterlist(locations->qual,loccnt)
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(loccnt))
  PLAN (d
   WHERE (locations->qual[d.seq].loc_building_cd != 0)
    AND (locations->qual[d.seq].loc_nurse_unit_cd=0)
    AND (locations->qual[d.seq].encntr_id=0))
  HEAD REPORT
   locationswithoutnurseunit = 1
  WITH nocounter
 ;end select
 IF (locationswithoutnurseunit > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(cnt)),
    location_group lg
   PLAN (d
    WHERE (locations->qual[d.seq].loc_nurse_unit_cd=0)
     AND (locations->qual[d.seq].encntr_id=0))
    JOIN (lg
    WHERE (lg.parent_loc_cd=locations->qual[d.seq].loc_building_cd)
     AND ((lg.root_loc_cd+ 0)=0)
     AND lg.active_ind=1
     AND lg.location_group_type_cd=building_type_cd)
   HEAD REPORT
    IF (mod(size(locations->qual,5),10) != 0)
     stat = alterlist(locations->qual,((10 - mod(size(locations->qual,5),10))+ size(locations->qual,5
       )))
    ENDIF
   DETAIL
    loccnt += 1
    IF (mod(loccnt,10)=1)
     stat = alterlist(locations->qual,(loccnt+ 9))
    ENDIF
    locations->qual[loccnt].loc_facility_cd = locations->qual[d.seq].loc_facility_cd, locations->
    qual[loccnt].loc_building_cd = locations->qual[d.seq].loc_building_cd, locations->qual[loccnt].
    beg_effective_dt_tm = locations->qual[d.seq].beg_effective_dt_tm,
    locations->qual[loccnt].end_effective_dt_tm = locations->qual[d.seq].end_effective_dt_tm,
    locations->qual[loccnt].loc_nurse_unit_cd = lg.child_loc_cd, locations->qual[loccnt].loc_room_cd
     = 0,
    locations->qual[loccnt].loc_bed_cd = 0, locations->qual[loccnt].encntr_id = 0
   FOOT REPORT
    stat = alterlist(locations->qual,loccnt)
   WITH nocounter
  ;end select
 ENDIF
 RECORD unit_record(
   1 qual[*]
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 unit_cd_list[*]
       3 loc_nurse_unit_cd = f8
 )
 RECORD room_record(
   1 qual[*]
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 room_cd_list[*]
       3 loc_nurse_unit_cd = f8
       3 loc_room_cd = f8
 )
 RECORD bed_record(
   1 qual[*]
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 bed_cd_list[*]
       3 loc_bed_cd = f8
 )
 RECORD encounters(
   1 qual[*]
     2 encntr_id = f8
 )
 SET unitcount = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(loccnt))
  PLAN (d
   WHERE (locations->qual[d.seq].loc_nurse_unit_cd > 0)
    AND (locations->qual[d.seq].loc_room_cd=0)
    AND (locations->qual[d.seq].loc_bed_cd=0)
    AND (locations->qual[d.seq].encntr_id=0))
  HEAD REPORT
   unitcount = 0
  DETAIL
   blnfound = 0
   IF (unitcount != 0)
    FOR (x = 1 TO unitcount BY 1)
      IF ((unit_record->qual[x].beg_effective_dt_tm=locations->qual[d.seq].beg_effective_dt_tm)
       AND (unit_record->qual[x].end_effective_dt_tm=locations->qual[d.seq].end_effective_dt_tm))
       new_size = (size(unit_record->qual[x].unit_cd_list,5)+ 1), stat = alterlist(unit_record->qual[
        x].unit_cd_list,new_size), unit_record->qual[x].unit_cd_list[new_size].loc_nurse_unit_cd =
       locations->qual[d.seq].loc_nurse_unit_cd,
       blnfound = 1, BREAK
      ENDIF
    ENDFOR
   ENDIF
   IF (((blnfound=0) OR (unitcount=0)) )
    unitcount += 1
    IF (mod(unitcount,10)=1)
     stat = alterlist(unit_record->qual,(unitcount+ 9))
    ENDIF
    unit_record->qual[unitcount].beg_effective_dt_tm = locations->qual[d.seq].beg_effective_dt_tm,
    unit_record->qual[unitcount].end_effective_dt_tm = locations->qual[d.seq].end_effective_dt_tm,
    stat = alterlist(unit_record->qual[unitcount].unit_cd_list,1),
    unit_record->qual[unitcount].unit_cd_list[1].loc_nurse_unit_cd = locations->qual[d.seq].
    loc_nurse_unit_cd
   ENDIF
  FOOT REPORT
   stat = alterlist(unit_record->qual,unitcount)
  WITH nocounter
 ;end select
 SET roomcount = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(loccnt))
  PLAN (d
   WHERE (locations->qual[d.seq].loc_nurse_unit_cd > 0)
    AND (locations->qual[d.seq].loc_room_cd != 0)
    AND (locations->qual[d.seq].loc_bed_cd=0)
    AND (locations->qual[d.seq].encntr_id=0))
  HEAD REPORT
   roomcount = 0
  DETAIL
   blnfound = 0
   IF (roomcount != 0)
    FOR (x = 1 TO roomcount BY 1)
      IF ((room_record->qual[x].beg_effective_dt_tm=locations->qual[d.seq].beg_effective_dt_tm)
       AND (room_record->qual[x].end_effective_dt_tm=locations->qual[d.seq].end_effective_dt_tm))
       new_size = (size(room_record->qual[x].room_cd_list,5)+ 1), stat = alterlist(room_record->qual[
        x].room_cd_list,new_size), room_record->qual[x].room_cd_list[new_size].loc_nurse_unit_cd =
       locations->qual[d.seq].loc_nurse_unit_cd,
       room_record->qual[x].room_cd_list[new_size].loc_room_cd = locations->qual[d.seq].loc_room_cd,
       blnfound = 1, BREAK
      ENDIF
    ENDFOR
   ENDIF
   IF (((blnfound=0) OR (roomcount=0)) )
    roomcount += 1
    IF (mod(roomcount,10)=1)
     stat = alterlist(room_record->qual,(roomcount+ 9))
    ENDIF
    room_record->qual[roomcount].beg_effective_dt_tm = locations->qual[d.seq].beg_effective_dt_tm,
    room_record->qual[roomcount].end_effective_dt_tm = locations->qual[d.seq].end_effective_dt_tm,
    stat = alterlist(room_record->qual[roomcount].room_cd_list,1),
    room_record->qual[roomcount].room_cd_list[1].loc_room_cd = locations->qual[d.seq].loc_room_cd,
    room_record->qual[roomcount].room_cd_list[1].loc_nurse_unit_cd = locations->qual[d.seq].
    loc_nurse_unit_cd
   ENDIF
  FOOT REPORT
   stat = alterlist(room_record->qual,roomcount)
  WITH nocounter
 ;end select
 SET bedcount = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(loccnt))
  PLAN (d
   WHERE (locations->qual[d.seq].loc_nurse_unit_cd > 0)
    AND (locations->qual[d.seq].loc_room_cd != 0)
    AND (locations->qual[d.seq].loc_bed_cd != 0)
    AND (locations->qual[d.seq].encntr_id=0))
  HEAD REPORT
   bedcount = 0
  DETAIL
   blnfound = 0
   IF (bedcount != 0)
    FOR (x = 1 TO bedcount BY 1)
      IF ((bed_record->qual[x].beg_effective_dt_tm=locations->qual[d.seq].beg_effective_dt_tm)
       AND (bed_record->qual[x].end_effective_dt_tm=locations->qual[d.seq].end_effective_dt_tm))
       new_size = (size(bed_record->qual[x].bed_cd_list,5)+ 1), stat = alterlist(bed_record->qual[x].
        bed_cd_list,new_size), bed_record->qual[x].bed_cd_list[new_size].loc_bed_cd = locations->
       qual[d.seq].loc_bed_cd,
       blnfound = 1, BREAK
      ENDIF
    ENDFOR
   ENDIF
   IF (((blnfound=0) OR (bedcount=0)) )
    bedcount += 1
    IF (mod(bedcount,10)=1)
     stat = alterlist(bed_record->qual,(bedcount+ 9))
    ENDIF
    bed_record->qual[bedcount].beg_effective_dt_tm = locations->qual[d.seq].beg_effective_dt_tm,
    bed_record->qual[bedcount].end_effective_dt_tm = locations->qual[d.seq].end_effective_dt_tm, stat
     = alterlist(bed_record->qual[bedcount].bed_cd_list,1),
    bed_record->qual[bedcount].bed_cd_list[1].loc_bed_cd = locations->qual[d.seq].loc_bed_cd
   ENDIF
  FOOT REPORT
   stat = alterlist(bed_record->qual,bedcount)
  WITH nocounter
 ;end select
 SET encountercount = 0
 SELECT INTO "nl:"
  ta.encntr_id, ta.reference_task_id
  FROM task_activity ta,
   (dummyt d  WITH seq = value(loccnt))
  PLAN (d
   WHERE (locations->qual[d.seq].loc_nurse_unit_cd > 0)
    AND (locations->qual[d.seq].encntr_id > 0))
   JOIN (ta
   WHERE (ta.encntr_id=locations->qual[d.seq].encntr_id)
    AND ((ta.task_status_cd=overdue_cd) OR (((ta.task_status_cd IN (pending_cd, inprocess_cd,
   completed_cd, pendval_cd)
    AND ta.task_dt_tm BETWEEN cnvtdatetime(locations->qual[d.seq].beg_effective_dt_tm) AND
   cnvtdatetime(locations->qual[d.seq].end_effective_dt_tm)) OR (ta.task_class_cd IN (continous_cd,
   prn_cd)
    AND ta.task_status_cd=pending_cd)) ))
    AND  EXISTS (
   (SELECT
    1
    FROM order_task_position_xref o
    WHERE ta.reference_task_id=o.reference_task_id
     AND o.position_cd=pos_cd)))
  ORDER BY ta.encntr_id
  HEAD REPORT
   IF (mod(size(encounters->qual,5),10) != 0)
    stat = alterlist(encounters->qual,((10 - mod(size(encounters->qual,5),10))+ size(encounters->qual,
      5)))
   ENDIF
  HEAD ta.encntr_id
   encountercount += 1
   IF (mod(encountercount,10)=1)
    stat = alterlist(encounters->qual,(encountercount+ 9))
   ENDIF
   encounters->qual[encountercount].encntr_id = ta.encntr_id
  FOOT REPORT
   stat = alterlist(encounters->qual,encountercount)
  WITH nocounter
 ;end select
 FREE RECORD locations
 SET cnt = 0
 IF (unitcount > 0)
  FOR (x = 1 TO size(unit_record->qual,5))
   SET temp = size(unit_record->qual[x].unit_cd_list,5)
   IF (x=1)
    SET cur_list_size = temp
   ELSE
    IF (cur_list_size < temp)
     SET cur_list_size = temp
    ENDIF
   ENDIF
  ENDFOR
  SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
  SET new_list_size = (loop_cnt * batch_size)
  FOR (x = 1 TO size(unit_record->qual,5))
    SET z = size(unit_record->qual[x].unit_cd_list,5)
    SET stat = alterlist(unit_record->qual[x].unit_cd_list,new_list_size)
    FOR (idx = (z+ 1) TO new_list_size)
      SET unit_record->qual[x].unit_cd_list[idx].loc_nurse_unit_cd = unit_record->qual[x].
      unit_cd_list[z].loc_nurse_unit_cd
    ENDFOR
  ENDFOR
  SET nstart = 1
  SELECT INTO "nl:"
   ta.encntr_id, ta.reference_task_id
   FROM (dummyt d  WITH seq = value(unitcount)),
    (dummyt d2  WITH seq = value(loop_cnt)),
    task_activity ta
   PLAN (d)
    JOIN (d2
    WHERE initarray(nstart,evaluate(d2.seq,1,1,(nstart+ batch_size))))
    JOIN (ta
    WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),ta.location_cd,unit_record->qual[d.seq].
     unit_cd_list[idx].loc_nurse_unit_cd)
     AND ((ta.task_status_cd=overdue_cd) OR (((ta.task_status_cd IN (pending_cd, inprocess_cd,
    completed_cd, pendval_cd)
     AND ta.task_dt_tm BETWEEN cnvtdatetime(unit_record->qual[d.seq].beg_effective_dt_tm) AND
    cnvtdatetime(unit_record->qual[d.seq].end_effective_dt_tm)) OR (ta.task_class_cd IN (continous_cd,
    prn_cd)
     AND ta.task_status_cd=pending_cd)) ))
     AND  EXISTS (
    (SELECT
     1
     FROM order_task_position_xref o
     WHERE ta.reference_task_id=o.reference_task_id
      AND o.position_cd=pos_cd)))
   ORDER BY ta.encntr_id
   HEAD REPORT
    IF (mod(size(encounters->qual,5),10) != 0)
     stat = alterlist(encounters->qual,((10 - mod(size(encounters->qual,5),10))+ size(encounters->
       qual,5)))
    ENDIF
   HEAD ta.encntr_id
    encountercount += 1
    IF (mod(encountercount,10)=1)
     stat = alterlist(encounters->qual,(encountercount+ 9))
    ENDIF
    encounters->qual[encountercount].encntr_id = ta.encntr_id
   FOOT REPORT
    stat = alterlist(encounters->qual,encountercount)
   WITH nocounter
  ;end select
 ENDIF
 FREE RECORD unit_record
 IF (roomcount > 0)
  FOR (x = 1 TO size(room_record->qual,5))
   SET temp = size(room_record->qual[x].room_cd_list,5)
   IF (x=1)
    SET cur_list_size = temp
   ELSE
    IF (cur_list_size < temp)
     SET cur_list_size = temp
    ENDIF
   ENDIF
  ENDFOR
  SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
  SET new_list_size = (loop_cnt * batch_size)
  FOR (x = 1 TO size(room_record->qual,5))
    SET z = size(room_record->qual[x].room_cd_list,5)
    SET stat = alterlist(room_record->qual[x].room_cd_list,new_list_size)
    FOR (idx = (z+ 1) TO new_list_size)
     SET room_record->qual[x].room_cd_list[idx].loc_room_cd = room_record->qual[x].room_cd_list[z].
     loc_room_cd
     SET room_record->qual[x].room_cd_list[idx].loc_nurse_unit_cd = room_record->qual[x].
     room_cd_list[z].loc_nurse_unit_cd
    ENDFOR
  ENDFOR
  SET nstart = 1
  SELECT INTO "nl:"
   ta.encntr_id, ta.reference_task_id
   FROM (dummyt d  WITH seq = value(roomcount)),
    (dummyt d2  WITH seq = value(loop_cnt)),
    task_activity ta
   PLAN (d)
    JOIN (d2
    WHERE initarray(nstart,evaluate(d2.seq,1,1,(nstart+ batch_size))))
    JOIN (ta
    WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),ta.location_cd,room_record->qual[d.seq].
     room_cd_list[idx].loc_nurse_unit_cd,
     ta.loc_room_cd,room_record->qual[d.seq].room_cd_list[idx].loc_room_cd)
     AND ((ta.task_status_cd=overdue_cd) OR (((ta.task_status_cd IN (pending_cd, inprocess_cd,
    completed_cd, pendval_cd)
     AND ta.task_dt_tm BETWEEN cnvtdatetime(room_record->qual[d.seq].beg_effective_dt_tm) AND
    cnvtdatetime(room_record->qual[d.seq].end_effective_dt_tm)) OR (ta.task_class_cd IN (continous_cd,
    prn_cd)
     AND ta.task_status_cd=pending_cd)) ))
     AND  EXISTS (
    (SELECT
     1
     FROM order_task_position_xref o
     WHERE ta.reference_task_id=o.reference_task_id
      AND o.position_cd=pos_cd)))
   ORDER BY ta.encntr_id
   HEAD REPORT
    IF (mod(size(encounters->qual,5),10) != 0)
     stat = alterlist(encounters->qual,((10 - mod(size(encounters->qual,5),10))+ size(encounters->
       qual,5)))
    ENDIF
   HEAD ta.encntr_id
    encountercount += 1
    IF (mod(encountercount,10)=1)
     stat = alterlist(encounters->qual,(encountercount+ 9))
    ENDIF
    encounters->qual[encountercount].encntr_id = ta.encntr_id
   FOOT REPORT
    stat = alterlist(encounters->qual,encountercount)
   WITH nocounter
  ;end select
 ENDIF
 FREE RECORD room_record
 IF (bedcount > 0)
  FOR (x = 1 TO size(bed_record->qual,5))
   SET temp = size(bed_record->qual[x].bed_cd_list,5)
   IF (x=1)
    SET cur_list_size = temp
   ELSE
    IF (cur_list_size < temp)
     SET cur_list_size = temp
    ENDIF
   ENDIF
  ENDFOR
  SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
  SET new_list_size = (loop_cnt * batch_size)
  FOR (x = 1 TO size(bed_record->qual,5))
    SET z = size(bed_record->qual[x].bed_cd_list,5)
    SET stat = alterlist(bed_record->qual[x].bed_cd_list,new_list_size)
    FOR (idx = (z+ 1) TO new_list_size)
      SET bed_record->qual[x].bed_cd_list[idx].loc_bed_cd = bed_record->qual[x].bed_cd_list[z].
      loc_bed_cd
    ENDFOR
  ENDFOR
  SET nstart = 1
  SELECT INTO "nl:"
   ta.encntr_id, ta.reference_task_id
   FROM (dummyt d  WITH seq = value(bedcount)),
    (dummyt d2  WITH seq = value(loop_cnt)),
    task_activity ta
   PLAN (d)
    JOIN (d2
    WHERE initarray(nstart,evaluate(d2.seq,1,1,(nstart+ batch_size))))
    JOIN (ta
    WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),ta.loc_bed_cd,bed_record->qual[d.seq].
     bed_cd_list[idx].loc_bed_cd)
     AND ((ta.task_status_cd=overdue_cd) OR (((ta.task_status_cd IN (pending_cd, inprocess_cd,
    completed_cd, pendval_cd)
     AND ta.task_dt_tm BETWEEN cnvtdatetime(bed_record->qual[d.seq].beg_effective_dt_tm) AND
    cnvtdatetime(bed_record->qual[d.seq].end_effective_dt_tm)) OR (ta.task_class_cd IN (continous_cd,
    prn_cd)
     AND ta.task_status_cd=pending_cd)) ))
     AND  EXISTS (
    (SELECT
     1
     FROM order_task_position_xref o
     WHERE ta.reference_task_id=o.reference_task_id
      AND o.position_cd=pos_cd)))
   ORDER BY ta.encntr_id
   HEAD REPORT
    IF (mod(encountercount,10) != 0)
     stat = alterlist(encounters->qual,((10 - mod(size(encounters->qual,5),10))+ size(encounters->
       qual,5)))
    ENDIF
   HEAD ta.encntr_id
    encountercount += 1
    IF (mod(encountercount,10)=1)
     stat = alterlist(encounters->qual,(encountercount+ 9))
    ENDIF
    encounters->qual[encountercount].encntr_id = ta.encntr_id
   FOOT REPORT
    stat = alterlist(encounters->qual,encountercount)
   WITH nocounter
  ;end select
 ENDIF
 FREE RECORD bed_record
 IF (encountercount=0)
  GO TO exit_script
 ENDIF
 SET idx = 0
 SET index = 1
 SET cur_list_size = size(encounters->qual,5)
 SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
 SET new_list_size = (loop_cnt * batch_size)
 SET stat = alterlist(encounters->qual,new_list_size)
 SET nstart = 1
 FOR (idx = (cur_list_size+ 1) TO new_list_size)
   SET encounters->qual[idx].encntr_id = encounters->qual[cur_list_size].encntr_id
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(loop_cnt)),
   encntr_domain ed,
   encounter e,
   person p
  PLAN (d
   WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
   JOIN (ed
   WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),ed.encntr_id,encounters->qual[idx].encntr_id)
    AND ed.encntr_domain_type_cd=census_type_cd
    AND ed.end_effective_dt_tm >= cnvtdatetime(b_dt_tm)
    AND ed.active_ind=1)
   JOIN (e
   WHERE e.encntr_id=ed.encntr_id
    AND e.active_ind=1)
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
 FREE RECORD encounters
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
#exit_script
 SET modify = nopredeclare
 IF (failed != 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].targetobjectname = table_name
 ELSEIF (cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET script_version = "006 05/31/07 MN014019"
END GO
