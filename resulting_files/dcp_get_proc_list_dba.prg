CREATE PROGRAM dcp_get_proc_list:dba
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 RECORD reply(
   1 person_org_sec_on = i2
   1 proc_cnt = i2
   1 proc_list[*]
     2 person_id = f8
     2 procedure_id = f8
     2 active_ind = i2
     2 encntr_id = f8
     2 nomenclature_id = f8
     2 organization_id = f8
     2 source_string = vc
     2 proc_dt_tm = dq8
     2 proc_ft_dt_tm_ind = i2
     2 proc_ft_time_frame = vc
     2 proc_prsnl_reltn_id = f8
     2 proc_prsnl_reltn_cd = f8
     2 proc_prsnl_id = f8
     2 proc_prsnl_name = vc
     2 proc_prsnl_ft_ind = i2
     2 proc_ft_prsnl = vc
     2 proc_loc_cd = f8
     2 proc_loc_disp = vc
     2 proc_loc_ft_ind = i2
     2 proc_ft_loc = vc
     2 comment_ind = i2
     2 long_text_id = f8
     2 text = vc
     2 proc_prsnl_reltns[*]
       3 proc_prsnl_reltn_id = f8
       3 proc_prsnl_reltn_cd = f8
       3 proc_prsnl_reltn_disp = vc
       3 proc_prsnl_reltn_mean = vc
       3 proc_prsnl_id = f8
       3 proc_prsnl_name = vc
       3 proc_prsnl_ft_ind = i2
       3 proc_ft_prsnl = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET encntr_org_sec_ind = 0
 SET confid_ind = 0
 SET prsnl_id = 0.0
 SET security_on = 0
 SET org_knt = 0
 SET person_sec_ind = 0
 IF (validate(request->prsnl_id,0)=0)
  SET prsnl_id = reqinfo->updt_id
 ELSE
  SET prsnl_id = request->prsnl_id
 ENDIF
 SET dminfo_ok = validate(ccldminfo->mode,0)
 IF (dminfo_ok=1)
  SET encntr_org_sec_ind = ccldminfo->sec_org_reltn
  SET confid_ind = ccldminfo->sec_confid
  SET person_sec_ind = ccldminfo->person_org_sec
  IF (((encntr_org_sec_ind=1) OR (((confid_ind=1) OR (person_sec_ind=1)) )) )
   SET security_on = 1
  ENDIF
 ELSE
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  SELECT INTO "nl:"
   FROM dm_info di
   PLAN (di
    WHERE di.info_domain="SECURITY"
     AND di.info_name IN ("SEC_ORG_RELTN", "SEC_CONFID", "PERSON_ORG_SEC")
     AND di.info_number=1)
   DETAIL
    IF (di.info_name="SEC_ORG_RELTN"
     AND di.info_number=1)
     encntr_org_sec_ind = 1, security_on = 1
    ELSEIF (di.info_name="SEC_CONFID"
     AND di.info_number=1)
     confid_ind = 1, security_on = 1
    ELSEIF (di.info_name="PERSON_ORG_SEC")
     person_sec_ind = 1
    ENDIF
   WITH nocounter
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = select_error
   SET table_name = "DM_INFO"
   GO TO exit_script
  ENDIF
 ENDIF
 CALL echo("***")
 CALL echo(build("***   encntr_org_sec_ind :",encntr_org_sec_ind))
 CALL echo(build("***   confid_ind         :",confid_ind))
 CALL echo(build("***   security_on        :",security_on))
 CALL echo(build("***   person_sec_ind     :",person_sec_ind))
 CALL echo("***")
 FREE RECORD temp
 RECORD temp(
   1 org_cnt = i2
   1 orglist[*]
     2 org_id = f8
     2 confid_level = i4
 )
 IF (security_on=1)
  IF (prsnl_id < 1)
   GO TO skip_prsnl_sec
  ENDIF
  SET ierrcode = 0
  IF ((prsnl_id=reqinfo->updt_id))
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
   SET temp->org_cnt = size(sac_org->organizations,5)
   SET stat = alterlist(temp->orglist,temp->org_cnt)
   FOR (i = 1 TO temp->org_cnt)
    SET temp->orglist[i].org_id = sac_org->organizations[i].organization_id
    SET temp->orglist[i].confid_level = sac_org->organizations[i].confid_level
   ENDFOR
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = select_error
    SET table_name = "PRSNL_ORG_RELTN"
    GO TO exit_script
   ENDIF
  ELSE
   SELECT INTO "nl:"
    c.collation_seq
    FROM prsnl_org_reltn por,
     code_value c
    PLAN (por
     WHERE por.person_id=prsnl_id
      AND por.active_ind=1
      AND por.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND por.end_effective_dt_tm >= cnvtdatetime(sysdate))
     JOIN (c
     WHERE c.code_value=por.confid_level_cd)
    HEAD REPORT
     knt = 0, stat = alterlist(temp->orglist,1)
    DETAIL
     knt += 1
     IF (mod(knt,10)=1)
      stat = alterlist(temp->orglist,(knt+ 9))
     ENDIF
     temp->orglist[knt].org_id = por.organization_id
     IF (por.confid_level_cd > 0
      AND c.collation_seq > 0)
      temp->orglist[knt].confid_level = c.collation_seq
     ELSE
      temp->orglist[knt].confid_level = 0
     ENDIF
    FOOT REPORT
     temp->org_cnt = knt, org_knt = knt, stat = alterlist(temp->orglist,knt)
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
#skip_prsnl_sec
 SET script_version = "002 10/20/05 AB8971"
 DECLARE knt1 = i4 WITH public, noconstant(0)
 DECLARE idx = i4 WITH public, noconstant(0)
 DECLARE knt = i4 WITH public, noconstant(0)
 DECLARE dminfo_ok = i2 WITH private, noconstant(false)
 DECLARE encntr_org_sec_on = i2 WITH public, noconstant(false)
 DECLARE person_org_sec_on = i2 WITH public, noconstant(false)
 DECLARE network_var = f8 WITH constant(uar_get_code_by("MEANING",28881,"NETWORK")), public
 SET reply->status_data.status = "F"
 IF ((request->person_qual_ind=1))
  EXECUTE dcp_get_proc_list_by_prsn_ids
  IF (ierrcode > 0)
   GO TO exit_script
  ENDIF
  GO TO get_access
 ENDIF
 IF ((request->proc_qual_ind=1))
  EXECUTE dcp_get_proc_list_by_proc_ids
  IF (ierrcode > 0)
   GO TO exit_script
  ENDIF
  GO TO get_access
 ENDIF
 IF ((request->call_type_flag=1))
  SET encntr_org_sec_ind = 0
  SET confid_ind = 0
 ENDIF
 IF (((encntr_org_sec_ind=1) OR (confid_ind=1)) )
  IF ((temp->org_cnt < 1))
   GO TO exit_script
  ENDIF
  SET ierrcode = 0
  SELECT
   IF (confid_ind=1)
    FROM encounter e,
     procedure p,
     nomenclature n,
     (dummyt d  WITH seq = 1),
     proc_prsnl_reltn ppr,
     prsnl pr,
     code_value cv,
     (dummyt d2  WITH seq = value(temp->org_cnt))
    PLAN (e
     WHERE (e.person_id=request->person_id))
     JOIN (cv
     WHERE cv.code_value=e.confid_level_cd)
     JOIN (d2
     WHERE (temp->orglist[d2.seq].org_id=e.organization_id)
      AND (temp->orglist[d2.seq].confid_level >= cv.collation_seq))
     JOIN (p
     WHERE p.encntr_id=e.encntr_id)
     JOIN (n
     WHERE n.nomenclature_id=p.nomenclature_id)
     JOIN (d)
     JOIN (ppr
     WHERE ppr.procedure_id=p.procedure_id)
     JOIN (pr
     WHERE pr.person_id=ppr.prsnl_person_id)
   ELSE
    FROM encounter e,
     procedure p,
     nomenclature n,
     (dummyt d  WITH seq = 1),
     proc_prsnl_reltn ppr,
     prsnl pr,
     (dummyt d2  WITH seq = value(temp->org_cnt))
    PLAN (e
     WHERE (e.person_id=request->person_id))
     JOIN (d2
     WHERE (temp->orglist[d2.seq].org_id=e.organization_id))
     JOIN (p
     WHERE p.encntr_id=e.encntr_id)
     JOIN (n
     WHERE n.nomenclature_id=p.nomenclature_id)
     JOIN (d)
     JOIN (ppr
     WHERE ppr.procedure_id=p.procedure_id)
     JOIN (pr
     WHERE pr.person_id=ppr.prsnl_person_id)
   ENDIF
   INTO "nl:"
   e.encntr_id, p.procedure_id, ppr.beg_effective_dt_tm
   ORDER BY p.procedure_id, ppr.beg_effective_dt_tm DESC
   HEAD REPORT
    knt = 0, stat = alterlist(reply->proc_list,1)
   HEAD p.procedure_id
    knt1 = 0, knt += 1
    IF (mod(knt,10)=1)
     stat = alterlist(reply->proc_list,(knt+ 9))
    ENDIF
    reply->proc_list[knt].procedure_id = p.procedure_id, reply->proc_list[knt].encntr_id = e
    .encntr_id, reply->proc_list[knt].active_ind = p.active_ind,
    reply->proc_list[knt].nomenclature_id = p.nomenclature_id
    IF (p.nomenclature_id > 0)
     reply->proc_list[knt].source_string = n.source_string
    ELSE
     reply->proc_list[knt].source_string = p.proc_ftdesc
    ENDIF
    reply->proc_list[knt].organization_id = e.organization_id, reply->proc_list[knt].proc_dt_tm =
    cnvtdatetime(p.proc_dt_tm), reply->proc_list[knt].proc_ft_dt_tm_ind = p.proc_ft_dt_tm_ind,
    reply->proc_list[knt].proc_ft_time_frame = p.proc_ft_time_frame, reply->proc_list[knt].
    proc_prsnl_reltn_id = ppr.proc_prsnl_reltn_id, reply->proc_list[knt].proc_prsnl_id = ppr
    .prsnl_person_id
    IF (ppr.prsnl_person_id > 0)
     reply->proc_list[knt].proc_prsnl_name = pr.name_full_formatted
    ELSE
     reply->proc_list[knt].proc_prsnl_name = ppr.proc_ft_prsnl, reply->proc_list[knt].proc_ft_prsnl
      = ppr.proc_ft_prsnl
    ENDIF
    reply->proc_list[knt].proc_prsnl_ft_ind = ppr.proc_prsnl_ft_ind, reply->proc_list[knt].
    proc_loc_cd = p.proc_loc_cd, reply->proc_list[knt].proc_loc_ft_ind = p.proc_loc_ft_ind,
    reply->proc_list[knt].proc_ft_loc = p.proc_ft_loc, reply->proc_list[knt].comment_ind = p
    .comment_ind, reply->proc_list[knt].long_text_id = p.long_text_id
   HEAD ppr.proc_prsnl_reltn_id
    IF (ppr.proc_prsnl_reltn_id > 0)
     knt1 += 1, stat = alterlist(reply->proc_list[knt].proc_prsnl_reltns,knt1), reply->proc_list[knt]
     .proc_prsnl_reltns[knt1].proc_prsnl_reltn_id = ppr.proc_prsnl_reltn_id,
     reply->proc_list[knt].proc_prsnl_reltns[knt1].proc_prsnl_reltn_cd = ppr.proc_prsnl_reltn_cd,
     reply->proc_list[knt].proc_prsnl_reltns[knt1].proc_prsnl_id = ppr.prsnl_person_id
     IF (ppr.proc_prsnl_ft_ind > 0)
      reply->proc_list[knt].proc_prsnl_reltns[knt1].proc_ft_prsnl = ppr.proc_ft_prsnl
     ELSE
      reply->proc_list[knt].proc_prsnl_reltns[knt1].proc_prsnl_name = pr.name_full_formatted, reply->
      proc_list[knt].proc_prsnl_reltns[knt1].proc_prsnl_id = ppr.prsnl_person_id
     ENDIF
     reply->proc_list[knt].proc_prsnl_reltns[knt1].proc_prsnl_ft_ind = ppr.proc_prsnl_ft_ind
    ENDIF
   FOOT REPORT
    reply->proc_cnt = knt, stat = alterlist(reply->proc_list,knt)
   WITH nocounter, outerjoin = d
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = select_error
   SET table_name = "PROCEDURE"
   GO TO exit_script
  ENDIF
 ELSE
  SET ierrcode = 0
  SELECT INTO "nl:"
   e.encntr_id, p.procedure_id, ppr.beg_effective_dt_tm
   FROM encounter e,
    procedure p,
    nomenclature n,
    (dummyt d  WITH seq = 1),
    proc_prsnl_reltn ppr,
    prsnl pr
   PLAN (e
    WHERE (e.person_id=request->person_id))
    JOIN (p
    WHERE p.encntr_id=e.encntr_id)
    JOIN (n
    WHERE n.nomenclature_id=p.nomenclature_id)
    JOIN (d)
    JOIN (ppr
    WHERE ppr.procedure_id=p.procedure_id)
    JOIN (pr
    WHERE pr.person_id=ppr.prsnl_person_id)
   ORDER BY p.procedure_id, ppr.beg_effective_dt_tm DESC
   HEAD REPORT
    knt = 0, stat = alterlist(reply->proc_list,1)
   HEAD p.procedure_id
    knt1 = 0, knt += 1
    IF (mod(knt,10)=1)
     stat = alterlist(reply->proc_list,(knt+ 9))
    ENDIF
    reply->proc_list[knt].procedure_id = p.procedure_id,
    CALL echo(build(reply->proc_list[knt].procedure_id)), reply->proc_list[knt].encntr_id = e
    .encntr_id,
    reply->proc_list[knt].active_ind = p.active_ind, reply->proc_list[knt].nomenclature_id = p
    .nomenclature_id
    IF (p.nomenclature_id > 0)
     reply->proc_list[knt].source_string = n.source_string
    ELSE
     reply->proc_list[knt].source_string = p.proc_ftdesc
    ENDIF
    reply->proc_list[knt].organization_id = e.organization_id, reply->proc_list[knt].proc_dt_tm =
    cnvtdatetime(p.proc_dt_tm), reply->proc_list[knt].proc_ft_dt_tm_ind = p.proc_ft_dt_tm_ind,
    reply->proc_list[knt].proc_ft_time_frame = p.proc_ft_time_frame, reply->proc_list[knt].
    proc_prsnl_reltn_id = ppr.proc_prsnl_reltn_id, reply->proc_list[knt].proc_prsnl_id = ppr
    .prsnl_person_id
    IF (ppr.prsnl_person_id > 0)
     reply->proc_list[knt].proc_prsnl_name = pr.name_full_formatted
    ELSE
     reply->proc_list[knt].proc_prsnl_name = ppr.proc_ft_prsnl, reply->proc_list[knt].proc_ft_prsnl
      = ppr.proc_ft_prsnl
    ENDIF
    reply->proc_list[knt].proc_prsnl_ft_ind = ppr.proc_prsnl_ft_ind, reply->proc_list[knt].
    proc_loc_cd = p.proc_loc_cd, reply->proc_list[knt].proc_loc_ft_ind = p.proc_loc_ft_ind,
    reply->proc_list[knt].proc_ft_loc = p.proc_ft_loc, reply->proc_list[knt].comment_ind = p
    .comment_ind, reply->proc_list[knt].long_text_id = p.long_text_id
   HEAD ppr.proc_prsnl_reltn_id
    knt1 += 1, stat = alterlist(reply->proc_list[knt].proc_prsnl_reltns,knt1), reply->proc_list[knt].
    proc_prsnl_reltns[knt1].proc_prsnl_reltn_id = ppr.proc_prsnl_reltn_id,
    reply->proc_list[knt].proc_prsnl_reltns[knt1].proc_prsnl_reltn_cd = ppr.proc_prsnl_reltn_cd
    IF (ppr.proc_prsnl_ft_ind > 0)
     reply->proc_list[knt].proc_prsnl_reltns[knt1].proc_ft_prsnl = ppr.proc_ft_prsnl
    ELSE
     reply->proc_list[knt].proc_prsnl_reltns[knt1].proc_prsnl_name = pr.name_full_formatted, reply->
     proc_list[knt].proc_prsnl_reltns[knt1].proc_prsnl_id = ppr.prsnl_person_id
    ENDIF
    CALL echo(build("Prsnl Id:",reply->proc_list[knt].proc_prsnl_reltns[knt1].proc_prsnl_id)), reply
    ->proc_list[knt].proc_prsnl_reltns[knt1].proc_prsnl_ft_ind = ppr.proc_prsnl_ft_ind
   FOOT REPORT
    reply->proc_cnt = knt, stat = alterlist(reply->proc_list,knt)
   WITH nocounter, outerjoin = d
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = select_error
   SET table_name = "PROCEDURE"
   GO TO exit_script
  ENDIF
 ENDIF
#get_access
 SET dminfo_ok = validate(ccldminfo->mode,0)
 IF (dminfo_ok=1)
  SET encntr_org_sec_on = ccldminfo->sec_org_reltn
  SET person_org_sec_on = ccldminfo->person_org_sec
 ELSE
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  SELECT INTO "nl:"
   FROM dm_info di
   PLAN (di
    WHERE di.info_domain="SECURITY"
     AND di.info_name IN ("SEC_ORG_RELTN", "PERSON_ORG_SEC")
     AND di.info_number=1)
   DETAIL
    IF (di.info_name="SEC_ORG_RELTN"
     AND di.info_number=1)
     encntr_org_sec_on = 1
    ELSEIF (di.info_name="PERSON_ORG_SEC")
     person_org_sec_on = 1
    ENDIF
   WITH nocounter
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = select_error
   SET table_name = "DM_INFO"
   GO TO exit_script
  ENDIF
 ENDIF
 IF (person_org_sec_on=true
  AND encntr_org_sec_on=true)
  SET reply->person_org_sec_on = true
  IF (network_var < 1)
   SET failed = select_error
   SET table_name = "CODE_VALUE"
   SET serrmsg = "Failed to find Code Value for CDF_MEANING NETWORK from Code Set 28881"
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((reply->proc_cnt > 0))
  SET ierrcode = 0
  SELECT INTO "nl:"
   l.long_text_id, l.long_text
   FROM long_text l,
    (dummyt d2  WITH seq = value(reply->proc_cnt))
   PLAN (d2)
    JOIN (l
    WHERE (l.long_text_id=reply->proc_list[d2.seq].long_text_id))
   DETAIL
    reply->proc_list[d2.seq].text = l.long_text
   WITH nocounter
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = select_error
   SET table_name = "PROCEDURE"
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 IF (failed != false)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  IF (failed=select_error)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSEIF (failed=insert_error)
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSEIF (failed=input_error)
   SET reply->status_data.subeventstatus[1].operationname = "VALIDATION"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSE
   SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ENDIF
 ELSEIF ((reply->proc_cnt > 0))
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
 SET dcp_script_version = "015 04/04/05 SF3151"
END GO
