CREATE PROGRAM bhs_dcp_get_pl_provider_group:dba
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
 DECLARE visit_cnt = i4 WITH noconstant(0)
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE encntr_where = vc WITH noconstant(fillstring(1000," "))
 DECLARE prsnl_group_id = f8 WITH noconstant(0.0)
 DECLARE patient_status_flag = i4 WITH noconstant(0)
 DECLARE patient_status_minutes = i4
 DECLARE filtercnt = i4 WITH constant(cnvtint(size(request->encntr_type_filters,5)))
 DECLARE filterind = i2 WITH noconstant(0)
 DECLARE ppr_where = vc WITH noconstant(fillstring(1000," "))
 DECLARE x = i4 WITH noconstant(0)
 DECLARE y = i4 WITH noconstant(0)
 DECLARE z = i4 WITH noconstant(0)
 DECLARE facility_cnt = i4 WITH noconstant(0)
 DECLARE begin_time = f8 WITH noconstant(cnvtdatetime(sysdate))
 DECLARE exec_time = f8 WITH noconstant(cnvtdatetime(sysdate))
 RECORD temp(
   1 facilities[*]
     2 facility_cd = f8
   1 priorities[*]
     2 person_id = f8
     2 priority = i4
 )
 SET temp_dt_tm = cnvtdatetime(sysdate)
 CALL parsearguments(null)
 CALL formatencounterclause(null)
 IF (((confid_ind=1) OR (encntr_org_sec_ind=1)) )
  SET filterind = 1
 ELSE
  SET filterind = 0
 ENDIF
 SET cnt = 0
 CALL echo("HEREANG")
 CALL echo(encntr_where)
 SELECT INTO "nl:"
  FROM prsnl_group_reltn pgr,
   prsnl pr,
   team_mem_ppr_reltn team,
   encntr_prsnl_reltn epr,
   encounter e,
   person p
  PLAN (pgr
   WHERE pgr.prsnl_group_id=prsnl_group_id
    AND pgr.active_ind=1)
   JOIN (pr
   WHERE pr.person_id=pgr.person_id)
   JOIN (team
   WHERE team.prsnl_group_reltn_id=pgr.prsnl_group_reltn_id
    AND team.ppr_flag=1)
   JOIN (epr
   WHERE pr.person_id=epr.prsnl_person_id
    AND epr.expiration_ind=0
    AND epr.encntr_prsnl_r_cd=team.ppr_cd
    AND epr.beg_effective_dt_tm < cnvtdatetime(sysdate)
    AND epr.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND epr.active_ind=1)
   JOIN (e
   WHERE parser(trim(encntr_where)))
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1)
  ORDER BY e.person_id, e.encntr_id
  HEAD e.encntr_id
   cnt += 1
   IF (mod(cnt,100)=1)
    stat = alterlist(reply->patients,(cnt+ 99))
   ENDIF
   reply->patients[cnt].person_id = p.person_id, reply->patients[cnt].person_name = p
   .name_full_formatted, reply->patients[cnt].filter_ind = 0,
   reply->patients[cnt].encntr_id = e.encntr_id, reply->patients[cnt].responsible_prsnl_id = epr
   .prsnl_person_id, reply->patients[cnt].responsible_prsnl_name = pr.name_full_formatted,
   reply->patients[cnt].responsible_reltn_cd = epr.encntr_prsnl_r_cd, reply->patients[cnt].
   responsible_reltn_id = epr.encntr_prsnl_reltn_id, reply->patients[cnt].responsible_reltn_flag = 1,
   reply->patients[cnt].organization_id = e.organization_id, reply->patients[cnt].confid_level_cd = e
   .confid_level_cd, reply->patients[cnt].confid_level = uar_get_collation_seq(e.confid_level_cd)
   IF ((reply->patients[cnt].confid_level < 0))
    reply->patients[cnt].confid_level = 0
   ENDIF
   reply->patients[cnt].active_ind = 1
  DETAIL
   IF ((reply->patients[cnt].encntr_id != e.encntr_id)
    AND (reply->patients[cnt].responsible_prsnl_id != reqinfo->updt_id)
    AND (epr.prsnl_person_id=reqinfo->updt_id))
    reply->patients[cnt].encntr_id = e.encntr_id, reply->patients[cnt].responsible_prsnl_id = epr
    .prsnl_person_id, reply->patients[cnt].responsible_prsnl_name = pr.name_full_formatted,
    reply->patients[cnt].responsible_reltn_cd = epr.encntr_prsnl_r_cd, reply->patients[cnt].
    responsible_reltn_id = epr.encntr_prsnl_reltn_id, reply->patients[cnt].responsible_reltn_flag = 1,
    reply->patients[cnt].organization_id = e.organization_id, reply->patients[cnt].confid_level_cd =
    e.confid_level_cd, reply->patients[cnt].confid_level = uar_get_collation_seq(e.confid_level_cd)
    IF ((reply->patients[cnt].confid_level < 0))
     reply->patients[cnt].confid_level = 0
    ENDIF
   ENDIF
   IF ((reply->patients[cnt].responsible_prsnl_id=reqinfo->updt_id))
    reply->patients[cnt].filter_ind = 0
   ELSE
    reply->patients[cnt].filter_ind = filterind
   ENDIF
  WITH nocounter
 ;end select
 SET visit_cnt = cnt
 CALL echo(build("EPR Select Time: ",datetimediff(cnvtdatetime(sysdate),exec_time,5)))
 CALL echo(build("Execution Time: ",datetimediff(cnvtdatetime(sysdate),begin_time,5)))
 SET exec_time = cnvtdatetime(sysdate)
 IF (((confid_ind=1) OR (encntr_org_sec_ind=1))
  AND cnt > 0)
  CALL enforceorgsecurity(null)
  CALL echo(build("OrgSecurity Select Time: ",datetimediff(cnvtdatetime(sysdate),exec_time,5)))
  CALL echo(build("Execution Time: ",datetimediff(cnvtdatetime(sysdate),begin_time,5)))
  SET exec_time = cnvtdatetime(sysdate)
 ENDIF
 IF (cnt > 0)
  CALL removeunauthduplicates(null)
 ENDIF
 SET cnt = visit_cnt
 CALL echo(build("RemoveDup Select Time: ",datetimediff(cnvtdatetime(sysdate),exec_time,5)))
 CALL echo(build("Execution Time: ",datetimediff(cnvtdatetime(sysdate),begin_time,5)))
 SET exec_time = cnvtdatetime(sysdate)
 SET ppr_where = concat("pr.person_id = ppr.prsnl_person_id",
  " and ppr.person_prsnl_r_cd = team.ppr_cd and ppr.active_ind = 1",
  " and ppr.beg_effective_dt_tm < cnvtdatetime(curdate, curtime3)",
  " and ppr.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)")
 IF (visit_cnt > 0)
  SET ppr_where = concat(ppr_where,
   " and not expand(x, 1, visit_cnt, ppr.person_id, reply->patients[x].person_id)")
 ENDIF
 SELECT INTO "nl:"
  FROM prsnl_group_reltn pgr,
   prsnl pr,
   team_mem_ppr_reltn team,
   person_prsnl_reltn ppr,
   person p
  PLAN (pgr
   WHERE pgr.prsnl_group_id=prsnl_group_id
    AND pgr.active_ind=1)
   JOIN (pr
   WHERE pr.person_id=pgr.person_id)
   JOIN (team
   WHERE team.prsnl_group_reltn_id=pgr.prsnl_group_reltn_id
    AND team.ppr_flag=0)
   JOIN (ppr
   WHERE parser(ppr_where))
   JOIN (p
   WHERE p.person_id=ppr.person_id
    AND p.active_ind=1)
  ORDER BY p.person_id
  HEAD p.person_id
   cnt += 1
   IF (mod(cnt,100)=1)
    stat = alterlist(reply->patients,(cnt+ 99))
   ENDIF
   reply->patients[cnt].person_id = p.person_id, reply->patients[cnt].person_name = p
   .name_full_formatted, reply->patients[cnt].filter_ind = 0,
   reply->patients[cnt].encntr_id = 0, reply->patients[cnt].responsible_prsnl_id = ppr
   .prsnl_person_id, reply->patients[cnt].responsible_prsnl_name = pr.name_full_formatted,
   reply->patients[cnt].responsible_reltn_cd = ppr.person_prsnl_r_cd, reply->patients[cnt].
   responsible_reltn_id = ppr.person_prsnl_reltn_id, reply->patients[cnt].responsible_reltn_flag = 0,
   reply->patients[cnt].organization_id = 0, reply->patients[cnt].confid_level_cd = 0, reply->
   patients[cnt].confid_level = 0,
   reply->patients[cnt].active_ind = 1
  DETAIL
   IF ((reply->patients[cnt].responsible_prsnl_id != reqinfo->updt_id))
    IF ((ppr.prsnl_person_id=reqinfo->updt_id))
     reply->patients[cnt].encntr_id = 0, reply->patients[cnt].responsible_prsnl_id = ppr
     .prsnl_person_id, reply->patients[cnt].responsible_prsnl_name = pr.name_full_formatted,
     reply->patients[cnt].responsible_reltn_cd = ppr.person_prsnl_r_cd, reply->patients[cnt].
     responsible_reltn_id = ppr.person_prsnl_reltn_id, reply->patients[cnt].responsible_reltn_flag =
     0,
     reply->patients[cnt].organization_id = 0, reply->patients[cnt].confid_level_cd = 0, reply->
     patients[cnt].confid_level = 0,
     reply->patients[cnt].active_ind = 1
    ENDIF
   ENDIF
   IF ((reply->patients[cnt].encntr_id=0))
    reply->patients[cnt].filter_ind = 0
   ELSE
    reply->patients[cnt].filter_ind = filterind
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->patients,cnt)
 CALL echo(build("PPR Select Time: ",datetimediff(cnvtdatetime(sysdate),exec_time,5)))
 CALL echo(build("Execution Time: ",datetimediff(cnvtdatetime(sysdate),begin_time,5)))
 SET exec_time = cnvtdatetime(sysdate)
 CALL evalpriority(cnt,visit_cnt)
 CALL echo(build("Priority Select Time: ",datetimediff(cnvtdatetime(sysdate),exec_time,5)))
 CALL echo(build("Execution Time: ",datetimediff(cnvtdatetime(sysdate),begin_time,5)))
 SET exec_time = cnvtdatetime(sysdate)
 IF (cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SUBROUTINE (evalpriority(total=i4,v_cnt=i4) =null)
   DECLARE priority_cnt = i4 WITH noconstant(0)
   DECLARE last_visit = i4 WITH noconstant(0)
   DECLARE last_person = i4 WITH noconstant((v_cnt+ 1))
   DECLARE foundpriority = i2 WITH noconstant(0)
   IF (total > 0
    AND (request->patient_list_id > 0))
    SELECT INTO "nl:"
     FROM dcp_pl_prioritization p
     PLAN (p
      WHERE (p.patient_list_id=request->patient_list_id)
       AND expand(x,1,total,p.person_id,reply->patients[x].person_id))
     ORDER BY p.person_id
     DETAIL
      priority_cnt += 1
      IF (mod(priority_cnt,10)=1)
       stat = alterlist(temp->priorities,(priority_cnt+ 9))
      ENDIF
      temp->priorities[priority_cnt].person_id = p.person_id, temp->priorities[priority_cnt].priority
       = p.priority
     FOOT REPORT
      stat = alterlist(temp->priorities,priority_cnt)
     WITH nocounter
    ;end select
   ENDIF
   IF (priority_cnt > 0)
    FOR (x = 1 TO priority_cnt)
      SET foundpriority = 0
      FOR (y = last_visit TO v_cnt)
        IF ((reply->patients[y].person_id=temp->priorities[x].person_id))
         SET reply->patients[y].priority = temp->priorities[x].priority
         SET last_visit = (y+ 1)
         SET y = (visit_cnt+ 1)
         SET foundpriority = 1
        ELSEIF ((reply->patients[y].person_id > temp->priorities[x].person_id))
         SET last_visit = y
         SET y = (visit_cnt+ 1)
        ENDIF
      ENDFOR
      IF (foundpriority=0)
       FOR (y = last_person TO cnt)
         IF ((reply->patients[y].person_id=temp->priorities[x].person_id))
          SET reply->patients[y].priority = temp->priorities[x].priority
          SET last_person = (y+ 1)
          SET y = (cnt+ 1)
         ELSEIF ((reply->patients[y].person_id > temp->priorities[x].person_id))
          SET last_person = y
          SET y = (cnt+ 1)
         ENDIF
       ENDFOR
      ENDIF
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE parsearguments(null)
   DECLARE argcnt = i4 WITH constant(size(request->arguments,5)), private
   DECLARE i = i4 WITH noconstant(0)
   FOR (i = 1 TO argcnt)
     CASE (request->arguments[i].argument_name)
      OF "prsnl_group_id":
       SET prsnl_group_id = cnvtreal(request->arguments[i].parent_entity_id)
      OF "provider_group_id":
       SET prsnl_group_id = cnvtreal(request->arguments[i].parent_entity_id)
      OF "patient_status_flag":
       SET patient_status_flag = cnvtint(request->arguments[i].argument_value)
      OF "patient_status_minutes":
       SET patient_status_minutes = cnvtint(request->arguments[i].argument_value)
      OF "facility_filter":
       SET facility_cnt += 1
       SET stat = alterlist(temp->facilities,facility_cnt)
       SET temp->facilities[facility_cnt].facility_cd = request->arguments[i].parent_entity_id
     ENDCASE
   ENDFOR
 END ;Subroutine
 SUBROUTINE formatencounterclause(null)
   SET temp_dt_tm = datetimeadd(cnvtdatetime(sysdate),- ((patient_status_minutes/ 1440.0)))
   SET encntr_where = "e.encntr_id = epr.encntr_id and e.active_ind = 1"
   IF (patient_status_flag=1)
    SET encntr_where = concat(encntr_where,
     " and e.reg_dt_tm between cnvtdatetime(temp_dt_tm) and cnvtdatetime(curdate,curtime)")
   ELSEIF (patient_status_flag=2)
    SET encntr_where = concat(encntr_where,
     " and e.disch_dt_tm between cnvtdatetime(temp_dt_tm) and cnvtdatetime(curdate,curtime)")
   ELSEIF (patient_status_flag=3)
    SET encntr_where = concat(encntr_where," and nullind(e.disch_dt_tm) = 1")
   ENDIF
   IF (filtercnt != 0)
    IF ((request->encntr_type_filters[1].encntr_type_cd != 0))
     SET encntr_where = concat(encntr_where,
      " and expand(x, 1, filterCnt, e.encntr_type_cd, request->encntr_type_filters[x].encntr_type_cd)"
      )
    ELSE
     SET encntr_where = concat(encntr_where,
      " and expand(x, 1, filterCnt, e.encntr_class_cd, request->encntr_type_filters[x].encntr_class_cd)"
      )
    ENDIF
   ENDIF
   IF (facility_cnt > 0)
    SET encntr_where = concat(encntr_where,
     " and expand(y, 1, facility_cnt, e.loc_facility_cd, temp->facilities[y].facility_cd)")
   ENDIF
 END ;Subroutine
 SUBROUTINE enforceorgsecurity(null)
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
 END ;Subroutine
 SUBROUTINE removeunauthduplicates(null)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = visit_cnt)
   PLAN (d
    WHERE (reply->patients[d.seq].filter_ind=0))
   ORDER BY d.seq
   HEAD REPORT
    true_cnt = 0
   DETAIL
    IF (((true_cnt=0) OR ((reply->patients[true_cnt].encntr_id != reply->patients[d.seq].encntr_id)
    )) )
     true_cnt += 1
     IF (true_cnt != d.seq)
      reply->patients[true_cnt].person_id = reply->patients[d.seq].person_id, reply->patients[
      true_cnt].person_name = reply->patients[d.seq].person_name, reply->patients[true_cnt].
      filter_ind = reply->patients[d.seq].filter_ind,
      reply->patients[true_cnt].encntr_id = reply->patients[d.seq].encntr_id, reply->patients[
      true_cnt].responsible_prsnl_id = reply->patients[d.seq].responsible_prsnl_id, reply->patients[
      true_cnt].responsible_prsnl_name = reply->patients[d.seq].responsible_prsnl_name,
      reply->patients[true_cnt].responsible_reltn_cd = reply->patients[d.seq].responsible_reltn_cd,
      reply->patients[true_cnt].responsible_reltn_id = reply->patients[d.seq].responsible_reltn_id,
      reply->patients[true_cnt].responsible_reltn_flag = reply->patients[d.seq].
      responsible_reltn_flag,
      reply->patients[true_cnt].organization_id = reply->patients[d.seq].organization_id, reply->
      patients[true_cnt].confid_level_cd = reply->patients[d.seq].confid_level_cd, reply->patients[
      true_cnt].confid_level = reply->patients[d.seq].confid_level,
      reply->patients[true_cnt].active_ind = reply->patients[d.seq].active_ind
     ENDIF
    ENDIF
   FOOT REPORT
    visit_cnt = true_cnt
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET visit_cnt = 0
   SET stat = alterlist(reply->patients,visit_cnt)
  ENDIF
 END ;Subroutine
END GO
