CREATE PROGRAM dcp_get_forms_activity_prt:dba
 FREE RECORD sac_def_pos_req
 RECORD sac_def_pos_req(
   1 personnel_id = f8
 )
 FREE RECORD sac_def_pos_list_req
 RECORD sac_def_pos_list_req(
   1 personnels[*]
     2 personnel_id = f8
 )
 FREE RECORD sac_def_pos_rep
 RECORD sac_def_pos_rep(
   1 position_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD sac_def_pos_list_rep
 RECORD sac_def_pos_list_rep(
   1 personnels[*]
     2 personnel_id = f8
     2 personnel_found = i2
     2 position_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD sac_cur_pos_rep
 RECORD sac_cur_pos_rep(
   1 position_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE getdefaultposition(null) = i2
 DECLARE getmultipledefaultpositions(null) = i2
 DECLARE getcurrentposition(null) = i2
 EXECUTE sacrtl
 SUBROUTINE getdefaultposition(null)
   DECLARE stat = i2 WITH protect
   SET stat = initrec(sac_def_pos_rep)
   SET sac_def_pos_rep->status_data.subeventstatus[1].operationname = "GetDefaultPosition"
   SET sac_def_pos_rep->status_data.subeventstatus[1].targetobjectname = "POSITION_CD"
   SELECT INTO "nl:"
    p.position_cd
    FROM prsnl p
    WHERE (p.person_id=sac_def_pos_req->personnel_id)
    DETAIL
     sac_def_pos_rep->position_cd = p.position_cd
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET sac_def_pos_rep->status_data.status = "Z"
    SET sac_def_pos_rep->status_data.subeventstatus[1].operationstatus = "Z"
    SET sac_def_pos_rep->status_data.subeventstatus[1].targetobjectvalue = build2("Personnel ID of ",
     cnvtstring(sac_def_pos_req->personnel_id,17)," does not exist.")
    RETURN(0)
   ENDIF
   IF ((sac_def_pos_rep->position_cd < 0))
    SET sac_def_pos_rep->status_data.status = "F"
    SET sac_def_pos_rep->status_data.subeventstatus[1].operationstatus = "F"
    SET sac_def_pos_rep->status_data.subeventstatus[1].targetobjectvalue = build2(
     "Invalid POSITION_CD of ",cnvtstring(sac_def_pos_rep->position_cd,17),". Value is less than 0.")
    RETURN(0)
   ENDIF
   SET sac_def_pos_rep->status_data.status = "S"
   SET sac_def_pos_rep->status_data.subeventstatus[1].operationstatus = "S"
   RETURN(1)
 END ;Subroutine
 SUBROUTINE getmultipledefaultpositions(null)
   DECLARE stat = i2 WITH protect
   SET stat = initrec(sac_def_pos_list_rep)
   SET sac_def_pos_list_rep->status_data.subeventstatus[1].operationname =
   "GetMultipleDefaultPositions"
   SET sac_def_pos_list_rep->status_data.subeventstatus[1].targetobjectname = "POSITION_CD"
   DECLARE prsnl_list_size = i4 WITH protect
   SET prsnl_list_size = size(sac_def_pos_list_req->personnels,5)
   IF (prsnl_list_size=0)
    SET sac_def_pos_list_rep->status_data.status = "F"
    SET sac_def_pos_list_rep->status_data.subeventstatus[1].operationstatus = "F"
    SET sac_def_pos_list_rep->status_data.subeventstatus[1].targetobjectvalue = build2(
     "No personnel IDs set in request list of size ",cnvtstring(prsnl_list_size))
    RETURN(0)
   ENDIF
   SET stat = alterlist(sac_def_pos_list_rep->personnels,prsnl_list_size)
   FOR (x = 1 TO prsnl_list_size)
     SET sac_def_pos_list_rep->personnels[x].personnel_id = sac_def_pos_list_req->personnels[x].
     personnel_id
     SET sac_def_pos_list_rep->personnels[x].personnel_found = 0
     SET sac_def_pos_list_rep->personnels[x].position_cd = - (1)
   ENDFOR
   DECLARE prsnl_idx = i4 WITH protect
   DECLARE expand_idx = i4 WITH protect
   DECLARE actual_idx = i4 WITH protect
   SELECT INTO "nl:"
    p.position_cd
    FROM prsnl p
    WHERE expand(prsnl_idx,1,prsnl_list_size,p.person_id,sac_def_pos_list_req->personnels[prsnl_idx].
     personnel_id)
    DETAIL
     actual_idx = locateval(expand_idx,1,prsnl_list_size,p.person_id,sac_def_pos_list_rep->
      personnels[expand_idx].personnel_id), sac_def_pos_list_rep->personnels[actual_idx].
     personnel_found = 1, sac_def_pos_list_rep->personnels[actual_idx].position_cd = p.position_cd
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET sac_def_pos_list_rep->status_data.status = "Z"
    SET sac_def_pos_list_rep->status_data.subeventstatus[1].operationstatus = "Z"
    SET sac_def_pos_list_rep->status_data.subeventstatus[1].targetobjectvalue = build2(
     "No personnels found in request list of size ",cnvtstring(prsnl_list_size))
    RETURN(0)
   ENDIF
   SET sac_def_pos_list_rep->status_data.status = "S"
   SET sac_def_pos_list_rep->status_data.subeventstatus[1].operationstatus = "S"
   RETURN(1)
 END ;Subroutine
 SUBROUTINE getcurrentposition(null)
   DECLARE stat = i2 WITH protect
   SET stat = initrec(sac_cur_pos_rep)
   SET sac_cur_pos_rep->status_data.subeventstatus[1].operationname = "GetCurrentPosition"
   SET sac_cur_pos_rep->status_data.subeventstatus[1].targetobjectname = "POSITION_CD"
   SET sac_cur_pos_rep->status_data.status = "F"
   SET sac_cur_pos_rep->status_data.subeventstatus[1].operationstatus = "F"
   DECLARE hpositionhandle = i4 WITH protect, noconstant(0)
   DECLARE clearhandle = i4 WITH protect, noconstant(0)
   SET hpositionhandle = uar_sacgetcurrentpositions()
   IF (hpositionhandle=0)
    CALL echo("Get Position failed: Unable to get the position handle.")
    SET sac_cur_pos_rep->status_data.subeventstatus[1].targetobjectvalue =
    "Get Current Position Failed: Unable to get the position handle."
    SET clearhandle = uar_sacclosehandle(hpositionhandle)
    RETURN(0)
   ENDIF
   DECLARE positioncnt = i4 WITH protect, noconstant(0)
   SET positioncnt = uar_srvgetitemcount(hpositionhandle,nullterm("Positions"))
   IF (positioncnt != 1)
    CALL echo("Get Position failed: Position count was not exactly 1.")
    SET sac_cur_pos_rep->status_data.subeventstatus[1].targetobjectvalue = build2(
     "Get Current Position Failed: ",cnvtstring(positioncnt,1)," positions returned.")
    SET clearhandle = uar_sacclosehandle(hpositionhandle)
    RETURN(0)
   ENDIF
   DECLARE hpositionlisthandle = i4 WITH protect, noconstant(0)
   SET hpositionlisthandle = uar_srvgetitem(hpositionhandle,nullterm("Positions"),0)
   IF (hpositionlisthandle=0)
    CALL echo("Get Position item failed: Unable to retrieve current position.")
    SET sac_cur_pos_rep->status_data.subeventstatus[1].targetobjectvalue =
    "Get Current Position Failed: Unable to retrieve current position."
    SET clearhandle = uar_sacclosehandle(hpositionlisthandle)
    SET clearhandle = uar_sacclosehandle(hpositionhandle)
    RETURN(0)
   ENDIF
   SET sac_cur_pos_rep->position_cd = uar_srvgetdouble(hpositionlisthandle,nullterm("PositionCode"))
   SET sac_cur_pos_rep->status_data.status = "S"
   SET sac_cur_pos_rep->status_data.subeventstatus[1].operationstatus = "S"
   SET clearhandle = uar_sacclosehandle(hpositionlisthandle)
   SET clearhandle = uar_sacclosehandle(hpositionhandle)
   RETURN(1)
 END ;Subroutine
 SET modify = predeclare
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE failure_ind = i2 WITH protect, noconstant(0)
 DECLARE applicationid = i4 WITH constant(1000011)
 DECLARE taskid = i4 WITH constant(1000011)
 DECLARE requestid = i4 WITH constant(1000011)
 DECLARE query_mode = i4 WITH constant(3)
 DECLARE eventid = f8
 DECLARE happ = i4
 DECLARE htask = i4
 DECLARE hstep = i4
 DECLARE hreq = i4
 DECLARE hrep = i4
 DECLARE hsb = i4
 DECLARE hrblist = i4
 DECLARE statuscd = i4
 DECLARE hsectionresult = i4
 DECLARE hinputresult = i4
 DECLARE warningstatus = i4 WITH constant(2)
 DECLARE date_tag = vc
 DECLARE coded_tag = vc
 DECLARE comment_tag = vc
 DECLARE event_id = f8 WITH noconstant(0)
 DECLARE inerror_ind = i2 WITH constant(1)
 DECLARE modified_ind = i2 WITH constant(2)
 DECLARE unauth_ind = i2 WITH constant(3)
 DECLARE inprogress_ind = i2 WITH constant(4)
 DECLARE date_precision = i2 WITH protected, constant(0)
 DECLARE month_precision = i2 WITH protected, constant(1)
 DECLARE year_precision = i2 WITH protected, constant(2)
 DECLARE no_qualifier = i2 WITH protected, constant(0)
 DECLARE before_qualifier = i2 WITH protected, constant(1)
 DECLARE about_qualifier = i2 WITH protected, constant(2)
 DECLARE after_qualifier = i2 WITH protected, constant(3)
 DECLARE dateonly_qualifier = i2 WITH protected, constant(4)
 DECLARE before_qualifier_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",25320,"BEFORE"))
 DECLARE after_qualifier_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",25320,"AFTER"))
 DECLARE about_qualifier_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",25320,"ABOUT"))
 DECLARE before_qualifier_str = vc WITH protect, constant(uar_get_code_display(before_qualifier_cd))
 DECLARE after_qualifier_str = vc WITH protect, constant(uar_get_code_display(after_qualifier_cd))
 DECLARE about_qualifier_str = vc WITH protect, constant(uar_get_code_display(about_qualifier_cd))
 DECLARE date_utc_str = vc WITH noconstant(fillstring(255," "))
 DECLARE diff = i4
 DECLARE 3m = f8 WITH protect, constant(uar_get_code_by("MEANING",89,"3M"))
 DECLARE 3m_aus = f8 WITH protect, constant(uar_get_code_by("MEANING",89,"3M-AUS"))
 DECLARE 3m_can = f8 WITH protect, constant(uar_get_code_by("MEANING",89,"3M-CAN"))
 DECLARE kodip = f8 WITH protect, constant(uar_get_code_by("MEANING",89,"KODIP"))
 DECLARE profile = f8 WITH protect, constant(uar_get_code_by("MEANING",89,"PROFILE"))
 DECLARE power_chart = f8 WITH protect, constant(uar_get_code_by("MEANING",89,"POWERCHART"))
 DECLARE application_num = i4 WITH protect, constant(reqinfo->updt_app)
 DECLARE position_cd = f8 WITH protect, constant(reqinfo->position_cd)
 DECLARE personnelid = f8 WITH protect, constant(reqinfo->updt_id)
 DECLARE getauthcontributorsystems(null) = null WITH protect
 SET diff = validate(curutcdiff,0)
 SET date_tag = fillstring(32000," ")
 SET coded_tag = fillstring(32000," ")
 SET comment_tag = fillstring(32000," ")
 SET modify = nopredeclare
 EXECUTE crmrtl
 EXECUTE srvrtl
 SET modify = predeclare
 FREE SET con_sys
 RECORD con_sys(
   1 system_cnt = i4
   1 systems[*]
     2 system_code = f8
 )
 RECORD events(
   1 form_event_id = f8
   1 section_cnt = i4
   1 sections[*]
     2 sect_event_id = f8
     2 collating_seq = vc
 )
 RECORD nomen_temp(
   1 nomen_qual[*]
     2 nomenclature_id = f8
     2 descriptor = vc
 )
 RECORD date_temp(
   1 dt1 = dq8
 )
 RECORD grid_temp(
   1 qual[*]
     2 result = i4
     2 collating_seq = vc
     2 event_id = f8
 )
 RECORD input_ref_temp(
   1 qual[*]
     2 dcp_input_ref_id = f8
     2 section_idx = i4
     2 input_idx = i4
 )
 RECORD temp_inputrefforform(
   1 sl[*]
     2 dcp_section_instance_id = f8
 )
 RECORD provider_list(
   1 qual[*]
     2 provider_id = f8
 )
 FREE RECORD user_sec_organizations
 RECORD user_sec_organizations(
   1 qual[*]
     2 organization_id = f8
 )
 FREE RECORD person_org_sec_map
 RECORD person_org_sec_map(
   1 encntrs[*]
     2 encntr_id = f8
 )
 IF (validate(org_sec_map)=0)
  RECORD org_sec_map(
    1 restrict_ind = i2
    1 patient_prsnl_list[*]
      2 prsnl_id = f8
      2 person_id = f8
      2 restrict_ind = i2
      2 encntrs[*]
        3 encntr_id = f8
  )
  SET org_sec_map->restrict_ind = - (1)
 ENDIF
 DECLARE unauth_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"UNAUTH"))
 DECLARE inprogress_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"IN PROGRESS"))
 DECLARE placeholder_cd = f8 WITH constant(uar_get_code_by("MEANING",53,"PLACEHOLDER"))
 SET captions->sunauth = uar_get_code_display(unauth_cd)
 SET captions->sinprogress = uar_get_code_display(inprogress_cd)
 DECLARE time_zone_ind = i2 WITH protect, noconstant(0)
 DECLARE stat_medlist = i4 WITH protect, noconstant(0)
 DECLARE stat_ppr = i4 WITH protect, noconstant(0)
 DECLARE formseventactivitycomp_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",18189,
   "CLINCALEVENT"))
 DECLARE iret = i4 WITH protect, noconstant(0)
 DECLARE srvstat = i4 WITH protect, noconstant(0)
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE orgsecoverrideind = i4 WITH protect, noconstant(0)
 DECLARE get_social_category(null) = null
 DECLARE checkfororgsecurity(null) = null
 DECLARE checkukorgsecutiryshx(null) = null
 DECLARE getuserorganizations(null) = null
 DECLARE checkmedlistorgsec(null) = null
 DECLARE checkoverrideind(null) = null
 DECLARE populateorgsecuritymap(null) = null
 DECLARE checkmedlistencntrfilter(null) = null
 CALL checkcolumnexists("DCP_FORMS_ACTIVITY","FORM_TZ")
 SET modify = nopredeclare
 DECLARE loadpregnancyorganizationsecuritylist() = null
 IF (validate(preg_org_sec_ind)=0)
  DECLARE preg_org_sec_ind = i4 WITH noconstant(0)
  SELECT INTO "nl:"
   FROM dm_info d1,
    dm_info d2
   WHERE d1.info_domain="SECURITY"
    AND d1.info_name="SEC_ORG_RELTN"
    AND d1.info_number=1
    AND d2.info_domain="SECURITY"
    AND d2.info_name="SEC_PREG_ORG_RELTN"
    AND d2.info_number=1
   DETAIL
    preg_org_sec_ind = 1
   WITH nocounter
  ;end select
  CALL echo(build("preg_org_sec_ind=",preg_org_sec_ind))
  IF (preg_org_sec_ind=1)
   FREE RECORD preg_sec_orgs
   RECORD preg_sec_orgs(
     1 qual[*]
       2 org_id = f8
       2 confid_level = i4
   )
   CALL loadpregnancyorganizationsecuritylist(null)
  ENDIF
 ENDIF
 SUBROUTINE loadpregnancyorganizationsecuritylist(null)
   DECLARE org_cnt = i2 WITH noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (validate(sac_org)=1)
    FREE RECORD sac_org
   ENDIF
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
   CALL echo(build("org_cnt: ",org_cnt))
   SET stat = alterlist(preg_sec_orgs->qual,(org_cnt+ 1))
   FOR (count = 1 TO org_cnt)
    SET preg_sec_orgs->qual[count].org_id = sac_org->organizations[count].organization_id
    SET preg_sec_orgs->qual[count].confid_level = sac_org->organizations[count].confid_level
   ENDFOR
   SET preg_sec_orgs->qual[(org_cnt+ 1)].org_id = 0.00
   SET preg_sec_orgs->qual[(org_cnt+ 1)].confid_level = 0
 END ;Subroutine
 SET modify = predeclare
 SELECT INTO "nl:"
  FROM dcp_forms_activity dfa,
   prsnl pp
  PLAN (dfa
   WHERE dfa.dcp_forms_activity_id=dcp_forms_activity_id)
   JOIN (pp
   WHERE pp.person_id=dfa.updt_id)
  DETAIL
   temp->performed_dt_tm = cnvtdatetime(dfa.form_dt_tm), temp->person_id = dfa.person_id, temp->
   encntr_id = dfa.encntr_id,
   temp->dcp_forms_ref_id = dfa.dcp_forms_ref_id
   IF (time_zone_ind=1
    AND curutc=1)
    IF (validate(dfa.form_tz,0) != 0)
     temp->performed_tz = validate(dfa.form_tz,0), temp->time_zone_ind = 1
    ENDIF
   ENDIF
   temp->form_status_cd = dfa.form_status_cd, temp->last_updt_prsnl = pp.name_full_formatted, temp->
   last_updt_dt_tm = cnvtdatetime(dfa.updt_dt_tm)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM dcp_forms_activity_comp dfac
  WHERE dfac.dcp_forms_activity_id=dcp_forms_activity_id
   AND dfac.parent_entity_name="CLINICAL_EVENT"
   AND dfac.component_cd=formseventactivitycomp_cd
  DETAIL
   events->form_event_id = dfac.parent_entity_id
  WITH nocounter
 ;end select
 SET date_temp->dt1 = cnvtdatetime(temp->last_updt_dt_tm)
 CALL formatdatetime(0,"ZZZ")
 SET temp->last_updt_str = concat(captions->slastupd," ",date_utc_str," ",captions->sby,
  ": ",temp->last_updt_prsnl)
 SET iret = uar_crmbeginapp(applicationid,happ)
 IF (iret != 0)
  CALL echo("uar_crm_begin_app failed in post_to_clinical_event")
  SET failure_ind = 1
  GO TO exit_script
 ENDIF
 SET iret = uar_crmbegintask(happ,taskid,htask)
 IF (iret != 0)
  CALL echo("uar_crm_begin_task failed in post_to_clinical_event")
  SET failure_ind = 1
  GO TO exit_script
 ENDIF
 SET iret = uar_crmbeginreq(htask,"",requestid,hstep)
 IF (iret != 0)
  CALL echo("uar_crm_begin_Request failed in post_to_clinical_event")
  SET failure_ind = 1
  GO TO exit_script
 ENDIF
 SET hreq = uar_crmgetrequest(hstep)
 IF (hreq)
  SET srvstat = uar_srvsetulong(hreq,"query_mode",query_mode)
  SET srvstat = uar_srvsetdouble(hreq,"event_id",events->form_event_id)
  SET srvstat = uar_srvsetlong(hreq,"subtable_bit_map",0)
  SET srvstat = uar_srvsetshort(hreq,"subtable_bit_map_ind",1)
  SET srvstat = uar_srvsetshort(hreq,"decode_flag",false)
  SET srvstat = uar_srvsetshort(hreq,"valid_from_dt_tm_ind",1)
 ENDIF
 SET iret = uar_crmperform(hstep)
 SET hrep = uar_crmgetreply(hstep)
 IF (hrep)
  CALL processsb(hrep)
  SET cnt = uar_srvgetitemcount(hrep,"rb_list")
  SET hrblist = uar_srvgetitem(hrep,"rb_list",0)
  IF (hrblist)
   SET cnt = uar_srvgetitemcount(hrblist,"child_event_list")
  ENDIF
 ENDIF
 DECLARE update_prsnl_cnt = i4 WITH noconstant(0)
 DECLARE first_prsnl_ind = i4 WITH noconstant(0)
 SELECT INTO "nl:"
  FROM dcp_forms_activity_prsnl dfap,
   prsnl pp
  PLAN (dfap
   WHERE dfap.dcp_forms_activity_id=dcp_forms_activity_id)
   JOIN (pp
   WHERE pp.person_id=dfap.proxy_id)
  ORDER BY dfap.dcp_forms_activity_prsnl_id
  HEAD dfap.dcp_forms_activity_id
   first_prsnl_ind = 1, temp->performed_prsnl_ft = dfap.prsnl_ft, temp->performed_prsnl_id = dfap
   .prsnl_id,
   temp->performed_proxy_id = dfap.proxy_id, temp->performed_proxy_ft = pp.name_full_formatted, temp
   ->entered_dt_tm = cnvtdatetime(dfap.activity_dt_tm)
   IF (validate(dfap.activity_tz,0) != 0
    AND curutc=1)
    temp->entered_tz = validate(dfap.activity_tz,0)
   ENDIF
   temp->prsnl_ind = 1
  DETAIL
   IF (first_prsnl_ind=0)
    update_prsnl_cnt += 1
    IF (update_prsnl_cnt > size(temp->updated_prsnl,5))
     stat = alterlist(temp->updated_prsnl,(update_prsnl_cnt+ 5))
    ENDIF
    temp->updated_prsnl[update_prsnl_cnt].prsnl_id = dfap.prsnl_id, temp->updated_prsnl[
    update_prsnl_cnt].prsnl_ft = dfap.prsnl_ft, temp->updated_prsnl[update_prsnl_cnt].proxy_prsnl_id
     = dfap.proxy_id,
    temp->updated_prsnl[update_prsnl_cnt].proxy_prsnl_ft = pp.name_full_formatted, temp->
    updated_prsnl[update_prsnl_cnt].update_dt_tm = cnvtdatetime(dfap.activity_dt_tm)
    IF (validate(dfap.activity_tz,0) != 0
     AND curutc=1)
     temp->updated_prsnl[update_prsnl_cnt].activity_tz = validate(dfap.activity_tz,0)
    ENDIF
   ELSE
    first_prsnl_ind = 0
   ENDIF
  FOOT  dfap.dcp_forms_activity_id
   first_prsnl_ind = 0
  WITH nocounter
 ;end select
 SET stat = alterlist(temp->updated_prsnl,update_prsnl_cnt)
 SET date_temp->dt1 = cnvtdatetime(temp->performed_dt_tm)
 CALL formatdatetime(temp->performed_tz,"ZZZ")
 SET temp->performed_dt_str = concat(trim(date_utc_str)," ",trim(captions->sperformedby)," ",trim(
   temp->performed_prsnl_ft))
 IF ((temp->performed_proxy_id != 0))
  SET temp->performed_dt_str = concat(trim(temp->performed_dt_str)," ",trim(captions->sproxyby)," ",
   trim(temp->performed_proxy_ft))
 ENDIF
 SET date_temp->dt1 = cnvtdatetime(temp->entered_dt_tm)
 CALL formatdatetime(temp->entered_tz,"ZZZ")
 SET temp->entered_dt_str = concat(captions->senteredon," ",date_utc_str)
 FOR (update_prsnl = 1 TO update_prsnl_cnt)
   CALL buildupdatestr(update_prsnl)
 ENDFOR
 IF (((dcp_forms_ref_id <= 0) OR (dcp_forms_ref_id=null)) )
  SELECT INTO "nl:"
   FROM dcp_forms_activity dfa,
    dcp_forms_ref dfr,
    dcp_forms_def dfd,
    dcp_section_ref dsr
   PLAN (dfa
    WHERE dfa.dcp_forms_activity_id=dcp_forms_activity_id)
    JOIN (dfr
    WHERE dfr.dcp_forms_ref_id=dfa.dcp_forms_ref_id
     AND dfr.beg_effective_dt_tm <= cnvtdatetime(version_dt_tm)
     AND dfr.end_effective_dt_tm >= cnvtdatetime(version_dt_tm))
    JOIN (dfd
    WHERE (dfd.dcp_form_instance_id= Outerjoin(dfr.dcp_form_instance_id)) )
    JOIN (dsr
    WHERE (dsr.dcp_section_ref_id= Outerjoin(dfd.dcp_section_ref_id))
     AND (dsr.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(version_dt_tm)))
     AND (dsr.end_effective_dt_tm>= Outerjoin(cnvtdatetime(version_dt_tm))) )
   ORDER BY dfr.dcp_forms_ref_id, dfd.section_seq
   HEAD REPORT
    scnt = 0, icnt = 0, val_cnt = 0
   HEAD dfr.dcp_forms_ref_id
    scnt = 0, icnt = 0, val_cnt = 0,
    temp->dcp_forms_ref_id = dfr.dcp_forms_ref_id, temp->description = dfr.description
   HEAD dfd.section_seq
    scnt += 1, icnt = 0, val_cnt = 0,
    stat = alterlist(temp->sl,scnt), temp->sl[scnt].dcp_section_ref_id = dsr.dcp_section_ref_id, temp
    ->sl[scnt].description = dsr.description,
    temp->sl[scnt].section_seq = dfd.section_seq, temp->sl[scnt].dcp_section_instance_id = dsr
    .dcp_section_instance_id
   FOOT  dfd.section_seq
    temp->sl[scnt].input_cnt = icnt
   FOOT  dfd.dcp_forms_ref_id
    temp->sect_cnt = scnt, stat = alterlist(temp->sl,scnt)
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM dcp_forms_ref dfr,
    dcp_forms_def dfd,
    dcp_section_ref dsr
   PLAN (dfr
    WHERE dfr.dcp_forms_ref_id=dcp_forms_ref_id
     AND dfr.beg_effective_dt_tm <= cnvtdatetime(version_dt_tm)
     AND dfr.end_effective_dt_tm >= cnvtdatetime(version_dt_tm))
    JOIN (dfd
    WHERE (dfd.dcp_form_instance_id= Outerjoin(dfr.dcp_form_instance_id)) )
    JOIN (dsr
    WHERE (dsr.dcp_section_ref_id= Outerjoin(dfd.dcp_section_ref_id))
     AND (dsr.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(version_dt_tm)))
     AND (dsr.end_effective_dt_tm>= Outerjoin(cnvtdatetime(version_dt_tm))) )
   ORDER BY dfr.dcp_forms_ref_id, dfd.section_seq
   HEAD REPORT
    scnt = 0, icnt = 0, val_cnt = 0
   HEAD dfr.dcp_forms_ref_id
    scnt = 0, icnt = 0, val_cnt = 0,
    temp->dcp_forms_ref_id = dfr.dcp_forms_ref_id, temp->description = dfr.description
   HEAD dfd.section_seq
    scnt += 1, icnt = 0, val_cnt = 0,
    stat = alterlist(temp->sl,scnt), temp->sl[scnt].dcp_section_ref_id = dsr.dcp_section_ref_id, temp
    ->sl[scnt].description = dsr.description,
    temp->sl[scnt].section_seq = dfd.section_seq, temp->sl[scnt].dcp_section_instance_id = dsr
    .dcp_section_instance_id
   FOOT  dfd.section_seq
    temp->sl[scnt].input_cnt = icnt
   FOOT  dfd.dcp_forms_ref_id
    temp->sect_cnt = scnt, stat = alterlist(temp->sl,scnt)
   WITH nocounter
  ;end select
 ENDIF
 CALL checkfororgsecurity(null)
 CALL checkoverrideind(null)
 CALL getuserorganizations(null)
 CALL getinputreferenceforform(null)
 CALL getpropertiesforallinput(null)
 FOR (x = 1 TO temp->sect_cnt)
  CALL findsectionresult(hrblist,temp->sl[x].dcp_section_ref_id)
  FOR (y = 1 TO temp->sl[x].input_cnt)
    FOR (z = 1 TO temp->sl[x].il[y].val_cnt)
      IF ((temp->sl[x].il[y].val_qual[z].pvc_name="grid_event_cd")
       AND (temp->sl[x].il[y].input_type != 15))
       SET temp->sl[x].il[y].pvc_value = temp->sl[x].il[y].val_qual[z].pvc_value
       SET z = temp->sl[x].il[y].val_cnt
      ENDIF
    ENDFOR
    SET temp->sl[x].il[y].status_ind = 0
    SET temp->sl[x].il[y].event_tag = " "
    SET temp->sl[x].il[y].ind = 0
    CALL echo(build("Control type = ",temp->sl[x].il[y].input_type))
    CALL echo(build("Module is = ",temp->sl[x].il[y].module))
    IF (trim(temp->sl[x].il[y].module)="PVTRACKFORMS")
     CALL get_general_result(x,y)
     IF (hinputresult)
      CASE (temp->sl[x].il[y].input_type)
       OF 1:
        CALL get_tracking1_result(x,y)
       OF 2:
        CALL get_tracking2_result(x,y)
      ENDCASE
     ENDIF
    ELSEIF (trim(temp->sl[x].il[y].module)="PFEXTCTRLS")
     CASE (temp->sl[x].il[y].input_type)
      OF 1:
       CALL get_medprofile_result(x,y)
      OF 2:
       CALL get_problemdx_result(x,y)
      OF 3:
       CALL get_pregnancy_history(x,y)
       CALL get_gravida_data(x,y)
      OF 4:
       CALL get_procedure_history(x,y)
      OF 5:
       CALL get_family_history(x,y)
      OF 6:
       CALL get_medlist_result(x,y)
      OF 7:
       CALL get_past_med_history(x,y)
      OF 8:
       CALL get_social_history(x,y)
      OF 9:
       CALL get_communication_preference(x,y)
     ENDCASE
    ELSEIF (trim(temp->sl[x].il[y].module)="PFPMCtrls")
     CASE (temp->sl[x].il[y].input_type)
      OF 1:
       CALL get_gestational_result(x,y)
      OF 2:
       CALL get_encounter_info(x,y)
     ENDCASE
    ELSEIF ((temp->sl[x].il[y].input_type=11))
     CALL get_allergy_result(x,y)
    ELSE
     CALL get_general_result(x,y)
     IF (hinputresult)
      CASE (temp->sl[x].il[y].input_type)
       OF 4:
        CALL get_alpha_result(x,y)
       OF 5:
        CALL get_magrid_result(x,y)
       OF 9:
        CALL get_alpha_result(x,y)
       OF 10:
        CALL get_date_result(x,y)
       OF 13:
        CALL get_rtf_result(x,y)
       OF 14:
        CALL get_dsgrid_result(x,y)
       OF 15:
        CALL get_ragrid_result(x,y)
       OF 17:
        CALL get_pwgrid_result(x,y,0)
       OF 19:
        CALL get_pwgrid_result(x,y,1)
       OF 23:
        CALL get_alpha_result(x,y)
      ENDCASE
     ENDIF
    ENDIF
  ENDFOR
 ENDFOR
#exit_script
 IF (statuscd > warningstatus)
  CALL echo(build("Not a valid event server status contact system admin:",statuscd))
 ELSEIF (failure_ind=1)
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF (hstep)
  CALL uar_crmendreq(hstep)
 ENDIF
 IF (htask)
  CALL uar_crmendtask(htask)
 ENDIF
 IF (happ)
  CALL uar_crmendapp(happ)
 ENDIF
 FREE RECORD grid_temp
 FREE RECORD date_temp
 FREE RECORD nomen_temp
 FREE RECORD events
 FREE RECORD input_ref_temp
 FREE RECORD temp_inputrefforform
 FREE RECORD provider_list
 FREE RECORD tmp_procs
 FREE RECORD request_grav
 FREE RECORD reply_grav
 FREE RECORD request_fam
 FREE RECORD reply_fam
 FREE RECORD tmp_members
 FREE RECORD social_category
 FREE RECORD tmp_grp_id
 SUBROUTINE getinputreferenceforform(null)
   DECLARE scnt = i4 WITH noconstant(temp->sect_cnt)
   IF (scnt=0)
    SET failure_ind = 1
    GO TO exit_script
   ENDIF
   DECLARE locindex = i4 WITH noconstant(0)
   DECLARE sindex = i4 WITH noconstant(0)
   DECLARE icnt = i4 WITH noconstant(0)
   DECLARE val_cnt = i4 WITH noconstant(0)
   DECLARE temp_icnt = i4 WITH noconstant(0)
   DECLARE numx = i4 WITH protect, noconstant(0)
   DECLARE expand_size = i4 WITH protect, constant(200)
   DECLARE expand_start = i4 WITH protect, noconstant(1)
   DECLARE expand_stop = i4 WITH protect, noconstant(200)
   DECLARE expand_total = i4 WITH protect, noconstant(0)
   SET expand_total = (ceil((cnvtreal(scnt)/ expand_size)) * expand_size)
   SET stat = alterlist(temp_inputrefforform->sl,expand_total)
   FOR (idx = 1 TO expand_total)
     IF (idx <= scnt)
      SET temp_inputrefforform->sl[idx].dcp_section_instance_id = temp->sl[idx].
      dcp_section_instance_id
     ELSE
      SET temp_inputrefforform->sl[idx].dcp_section_instance_id = temp->sl[scnt].
      dcp_section_instance_id
     ENDIF
   ENDFOR
   SELECT INTO "nl:"
    FROM dcp_input_ref dir,
     (dummyt d  WITH seq = value((expand_total/ expand_size)))
    PLAN (d
     WHERE assign(expand_start,evaluate(d.seq,1,1,(expand_start+ expand_size)))
      AND assign(expand_stop,(expand_start+ (expand_size - 1))))
     JOIN (dir
     WHERE expand(numx,expand_start,expand_stop,dir.dcp_section_instance_id,temp_inputrefforform->sl[
      numx].dcp_section_instance_id)
      AND ((dir.input_type != 0
      AND dir.input_type != null
      AND dir.input_type != 1
      AND dir.input_type != 3
      AND dir.input_type != 8
      AND dir.input_type != 12
      AND dir.input_type != 16) OR (dir.module != " ")) )
    ORDER BY dir.dcp_section_instance_id, dir.input_ref_seq
    HEAD dir.dcp_section_instance_id
     sindex = locateval(locindex,1,scnt,dir.dcp_section_instance_id,temp->sl[locindex].
      dcp_section_instance_id), icnt = 0
    HEAD dir.input_ref_seq
     IF (sindex > 0)
      icnt += 1, val_cnt = 0
      IF (mod(icnt,10)=1)
       stat = alterlist(temp->sl[sindex].il,(icnt+ 9))
      ENDIF
      temp->sl[sindex].il[icnt].dcp_input_ref_id = dir.dcp_input_ref_id, temp->sl[sindex].il[icnt].
      description = dir.description, temp->sl[sindex].il[icnt].input_ref_seq = dir.input_ref_seq,
      temp->sl[sindex].il[icnt].input_type = dir.input_type, temp->sl[sindex].il[icnt].module = trim(
       dir.module)
     ENDIF
     temp_icnt += 1
     IF (mod(temp_icnt,10)=1)
      stat = alterlist(input_ref_temp->qual,(temp_icnt+ 9))
     ENDIF
     input_ref_temp->qual[temp_icnt].dcp_input_ref_id = dir.dcp_input_ref_id, input_ref_temp->qual[
     temp_icnt].section_idx = sindex, input_ref_temp->qual[temp_icnt].input_idx = icnt
    FOOT  dir.dcp_section_instance_id
     IF (sindex > 0)
      stat = alterlist(temp->sl[sindex].il,icnt), temp->sl[sindex].input_cnt = icnt
     ENDIF
    WITH nocounter
   ;end select
   SET stat = alterlist(input_ref_temp->qual,temp_icnt)
 END ;Subroutine
 SUBROUTINE getpropertiesforallinput(null)
   DECLARE trck_cnt = i4 WITH noconstant(0)
   DECLARE num1 = i4 WITH noconstant(0)
   DECLARE pos1 = i4 WITH noconstant(0)
   DECLARE temp_size_cnt = i4 WITH noconstant(size(input_ref_temp->qual,5))
   IF (temp_size_cnt=0)
    SET failure_ind = 1
    GO TO exit_script
   ENDIF
   DECLARE locidx = i4 WITH noconstant(0)
   DECLARE sidx = i4 WITH noconstant(0)
   DECLARE inpidx = i4 WITH noconstant(0)
   DECLARE templocidx = i4 WITH noconstant(0)
   DECLARE numx = i4 WITH protect, noconstant(0)
   DECLARE expand_size = i4 WITH protect, constant(50)
   DECLARE expand_start = i4 WITH protect, noconstant(1)
   DECLARE expand_stop = i4 WITH protect, noconstant(50)
   DECLARE expand_total = i4 WITH protect, noconstant(0)
   SET expand_total = (ceil((cnvtreal(temp_size_cnt)/ expand_size)) * expand_size)
   SET stat = alterlist(input_ref_temp->qual,expand_total)
   FOR (idx = (temp_size_cnt+ 1) TO expand_total)
     SET input_ref_temp->qual[idx].dcp_input_ref_id = input_ref_temp->qual[temp_size_cnt].
     dcp_input_ref_id
   ENDFOR
   SELECT INTO "nl:"
    FROM name_value_prefs nvp,
     (dummyt d  WITH seq = value((expand_total/ expand_size)))
    PLAN (d
     WHERE assign(expand_start,evaluate(d.seq,1,1,(expand_start+ expand_size)))
      AND assign(expand_stop,(expand_start+ (expand_size - 1))))
     JOIN (nvp
     WHERE expand(numx,expand_start,expand_stop,nvp.parent_entity_id,input_ref_temp->qual[numx].
      dcp_input_ref_id)
      AND nvp.parent_entity_name="DCP_INPUT_REF"
      AND ((nvp.pvc_name="task_assay_cd") OR (((nvp.pvc_name="grid_event_cd") OR (((nvp.pvc_name=
     "discrete_task_assay*") OR (((nvp.pvc_name="nomen_field") OR (((nvp.pvc_name="Label_Name") OR (
     nvp.pvc_name="Tracking_comment_visible")) )) )) )) )) )
    ORDER BY nvp.parent_entity_id
    HEAD nvp.parent_entity_id
     trck_cnt += 1, templocidx = locateval(locidx,1,temp_size_cnt,nvp.parent_entity_id,input_ref_temp
      ->qual[locidx].dcp_input_ref_id)
     IF (templocidx > 0)
      sidx = input_ref_temp->qual[templocidx].section_idx, inpidx = input_ref_temp->qual[templocidx].
      input_idx, val_cnt = 0
      IF ((temp->sl[sidx].il[inpidx].module="PFPMCtrls")
       AND (temp->sl[sidx].il[inpidx].input_type=2))
       stat = alterlist(temp->sl[sidx].il[inpidx].tracking_cmt,(trck_cnt+ 10))
       IF (nvp.pvc_name="Label_Name")
        pos1 = locateval(num1,1,size(temp->sl[sidx].il[inpidx].tracking_cmt,5),nvp.sequence,temp->sl[
         sidx].il[inpidx].tracking_cmt[num1].comment_seq)
        IF (pos1=0)
         trck_cnt += 1, temp->sl[sidx].il[inpidx].tracking_cmt[trck_cnt].comment_seq = nvp.sequence,
         temp->sl[sidx].il[inpidx].tracking_cmt[trck_cnt].comment_lbl = nullterm(nvp.pvc_value)
        ELSE
         temp->sl[sidx].il[inpidx].tracking_cmt[pos1].comment_lbl = nullterm(nvp.pvc_value)
        ENDIF
       ELSEIF (nvp.pvc_name="Tracking_comment_visible")
        pos1 = locateval(num1,1,size(temp->sl[sidx].il[inpidx].tracking_cmt,5),nvp.sequence,temp->sl[
         sidx].il[inpidx].tracking_cmt[num1].comment_seq)
        IF (pos1=0)
         trck_cnt += 1, temp->sl[sidx].il[inpidx].tracking_cmt[trck_cnt].comment_seq = nvp.sequence,
         temp->sl[sidx].il[inpidx].tracking_cmt[trck_cnt].comment_visible = cnvtint(nvp.pvc_value)
        ELSE
         temp->sl[sidx].il[inpidx].tracking_cmt[pos1].comment_visible = cnvtint(nvp.pvc_value)
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    DETAIL
     IF (templocidx > 0)
      IF (((nvp.pvc_name="task_assay_cd") OR (((nvp.pvc_name="grid_event_cd") OR (nvp.pvc_name=
      "discrete_task_assay")) )) )
       temp->sl[sidx].il[inpidx].pvc_name = nvp.pvc_name
       IF (nvp.merge_id > 0)
        temp->sl[sidx].il[inpidx].pvc_value = cnvtstring(nvp.merge_id,20,2)
       ELSEIF (nvp.pvc_value > " ")
        temp->sl[sidx].il[inpidx].pvc_value = nvp.pvc_value
       ENDIF
      ENDIF
      val_cnt += 1, temp->sl[sidx].il[inpidx].val_cnt = val_cnt
      IF (mod(val_cnt,10)=1)
       stat = alterlist(temp->sl[sidx].il[inpidx].val_qual,(val_cnt+ 9))
      ENDIF
      temp->sl[sidx].il[inpidx].val_qual[val_cnt].pvc_name = nvp.pvc_name
      IF (nvp.merge_id > 0)
       temp->sl[sidx].il[inpidx].val_qual[val_cnt].pvc_value = cnvtstring(nvp.merge_id,20,2)
      ELSEIF (nvp.pvc_value > " ")
       temp->sl[sidx].il[inpidx].val_qual[val_cnt].pvc_value = nvp.pvc_value
      ENDIF
     ENDIF
    FOOT  nvp.parent_entity_id
     stat = alterlist(temp->sl[sidx].il[inpidx].val_qual,val_cnt)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE processsb(hreply)
  SET hsb = uar_srvgetstruct(hreply,"sb")
  IF (hsb)
   SET statuscd = uar_srvgetlong(hsb,"severityCd")
   CALL echo(build("statusCd:",statuscd))
   IF (statuscd > warningstatus)
    SET failure_ind = 1
    GO TO exit_script
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE findsectionresult(hformevent,sectionrefid)
   IF (hformevent)
    DECLARE eventsecitercnt = i4 WITH protect, noconstant(0)
    DECLARE hsecevent = i4 WITH protect, noconstant(0)
    DECLARE collating_seq = vc WITH protect, noconstant(fillstring(1000," "))
    SET hsectionresult = 0
    SET eventsecitercnt = uar_srvgetitemcount(hformevent,"child_event_list")
    FOR (iter = 1 TO eventsecitercnt)
     SET hsecevent = uar_srvgetitem(hformevent,"child_event_list",(iter - 1))
     IF (hsecevent)
      SET collating_seq = uar_srvgetstringptr(hsecevent,"collating_seq")
      IF (sectionrefid=cnvtreal(collating_seq))
       CALL echo("found Section Event")
       SET hsectionresult = hsecevent
       SET iter = eventsecitercnt
      ENDIF
     ENDIF
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE get_allergy_result(xx,yy)
   CALL echo("Entering GET_ALLERGY_RESULT")
   DECLARE locateidx = i4 WITH protect, noconstant(0)
   DECLARE allergyidx = i4 WITH protect, noconstant(0)
   SET temp->sl[xx].il[yy].allergy_restricted_ind = 0
   SELECT INTO "nl:"
    a.allergy_instance_id, a.substance_ftdesc, a.onset_dt_tm,
    n.source_string, r.reaction_ftdesc, n2.source_string,
    check = decode(n.seq,"n",r.seq,"r","z")
    FROM allergy a,
     nomenclature n,
     reaction r,
     nomenclature n2,
     (dummyt d1  WITH seq = 1),
     (dummyt d2  WITH seq = 1)
    PLAN (a
     WHERE a.person_id=person_id
      AND a.active_ind=1
      AND a.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND ((a.end_effective_dt_tm >= cnvtdatetime(sysdate)) OR (a.end_effective_dt_tm=null))
      AND a.reaction_status_cd != canceled_cd)
     JOIN (d1)
     JOIN (((r
     WHERE a.allergy_id=r.allergy_id
      AND r.active_ind=1
      AND r.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND ((r.end_effective_dt_tm >= cnvtdatetime(sysdate)) OR (r.end_effective_dt_tm=null)) )
     JOIN (n2
     WHERE r.reaction_nom_id=n2.nomenclature_id)
     ) ORJOIN ((d2)
     JOIN (n
     WHERE a.substance_nom_id=n.nomenclature_id)
     ))
    ORDER BY a.allergy_id, check
    HEAD REPORT
     temp->sl[xx].ind = 1, cnt = 0, rcnt = 0
    HEAD a.allergy_id
     locateidx = locateval(allergyidx,1,size(user_sec_organizations->qual,5),a.organization_id,
      user_sec_organizations->qual[allergyidx].organization_id)
     IF ((((org_sec_map->restrict_ind=0)) OR (((orgsecoverrideind != 0) OR (locateidx > 0)) )) )
      cnt += 1, temp->sl[xx].il[yy].allergy_cnt = cnt, stat = alterlist(temp->sl[xx].il[yy].
       allergy_qual,cnt)
     ELSE
      temp->sl[xx].il[yy].allergy_restricted_ind = 1
     ENDIF
    DETAIL
     IF ((((org_sec_map->restrict_ind=0)) OR (((orgsecoverrideind != 0) OR (locateidx > 0)) )) )
      IF (((n.source_string > " ") OR (a.substance_ftdesc > " ")) )
       IF (a.substance_ftdesc > " ")
        temp->sl[xx].il[yy].allergy_qual[cnt].list = trim(a.substance_ftdesc)
       ELSEIF (n.source_string > " ")
        temp->sl[xx].il[yy].allergy_qual[cnt].list = trim(n.source_string)
       ENDIF
       temp->sl[xx].il[yy].allergy_qual[cnt].a_inst_id = a.allergy_instance_id
      ENDIF
      IF (((r.reaction_ftdesc > " ") OR (n2.source_string > " ")) )
       rcnt += 1, stat = alterlist(temp->sl[xx].il[yy].allergy_qual[cnt].reaction_qual,rcnt), temp->
       sl[xx].il[yy].allergy_qual[cnt].reaction_cnt = rcnt
       IF (r.reaction_ftdesc > " ")
        temp->sl[xx].il[yy].allergy_qual[cnt].reaction_qual[rcnt].rlist = trim(r.reaction_ftdesc)
       ELSEIF (n2.source_string > " ")
        temp->sl[xx].il[yy].allergy_qual[cnt].reaction_qual[rcnt].rlist = trim(n2.source_string)
       ENDIF
       temp->sl[xx].il[yy].allergy_qual[cnt].date = a.onset_dt_tm
      ENDIF
     ENDIF
    WITH nocounter, outerjoin = d1, dontcare = n2
   ;end select
   IF ((temp->sl[xx].il[yy].allergy_cnt > 0))
    SELECT INTO "nl:"
     ac.allergy_comment, ac.allergy_comment_id
     FROM allergy_comment ac,
      (dummyt d  WITH seq = value(temp->sl[xx].il[yy].allergy_cnt))
     PLAN (d)
      JOIN (ac
      WHERE (ac.allergy_instance_id=temp->sl[xx].il[yy].allergy_qual[d.seq].a_inst_id))
     ORDER BY ac.allergy_comment_id
     HEAD REPORT
      cnt = 0
     HEAD ac.allergy_comment_id
      cnt += 1, temp->sl[xx].il[yy].allergy_qual[d.seq].note_cnt = cnt, stat = alterlist(temp->sl[xx]
       .il[yy].allergy_qual[d.seq].note_qual,cnt)
     DETAIL
      IF (ac.allergy_comment > " ")
       temp->sl[xx].il[yy].note_ind = 1, temp->sl[xx].il[yy].allergy_qual[d.seq].note_ind = 1, temp->
       sl[xx].il[yy].allergy_qual[d.seq].note_qual[cnt].note_text = trim(ac.allergy_comment)
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   CALL echo("leaving GET_ALLERGY_RESULT")
 END ;Subroutine
 SUBROUTINE (get_medlist_result(xx=i4,yy=i4) =null)
   CALL echo("Entering GET_MEDLIST_RESULT")
   CALL get_person_prsnl_r_cd(xx,yy)
   DECLARE appid_medlist = i4 WITH constant(600005), protect
   DECLARE tskid_medlist = i4 WITH constant(500195), protect
   DECLARE reqid_medlist = i4 WITH constant(680200), protect
   DECLARE happ_medlist = i4 WITH noconstant(0), protect
   DECLARE htask_medlist = i4 WITH noconstant(0), protect
   DECLARE hstep_medlist = i4 WITH noconstant(0), protect
   DECLARE hrequest_medlist = i4 WITH noconstant(0), protect
   DECLARE hreply_medlist = i4 WITH noconstant(0), protect
   DECLARE irtn = i4 WITH noconstant(0), protect
   SET irtn = uar_crmbeginapp(appid_medlist,happ_medlist)
   IF (irtn != 0)
    CALL echo("uar_crm_begin_app failed in Order Service for MedList from dcp_get_forms_activity_prt"
     )
    SET failure_ind = 1
    GO TO exit_script
   ENDIF
   SET irtn = uar_crmbegintask(happ_medlist,tskid_medlist,htask_medlist)
   IF (irtn != 0)
    CALL echo(
     "uar_crm_begin_task failed in Order Service for MedList from dcp_get_forms_activity_prt")
    SET failure_ind = 1
    GO TO exit_script
   ENDIF
   SET irtn = uar_crmbeginreq(htask_medlist,"",reqid_medlist,hstep_medlist)
   IF (irtn != 0)
    CALL echo(
     "uar_crm_begin_Request failed in Order Service for MedList from dcp_get_forms_activity_prt")
    SET failure_ind = 1
    GO TO exit_script
   ENDIF
   SET hrequest_medlist = uar_crmgetrequest(hstep_medlist)
   IF (hrequest_medlist)
    CALL set_medlist_request(hrequest_medlist)
   ENDIF
   SET irtn = uar_crmperform(hstep_medlist)
   SET hreply_medlist = uar_crmgetreply(hstep_medlist)
   IF (hreply_medlist)
    CALL check_reply_status(hreply_medlist)
    CALL get_medlist_reply(xx,yy,hreply_medlist)
    CALL get_order_compliance(xx,yy)
   ENDIF
   CALL cleanup(happ_medlist,htask_medlist,hstep_medlist)
   CALL echo("leaving GET_MEDLIST_RESULT")
 END ;Subroutine
 SUBROUTINE get_person_prsnl_r_cd(xx,yy)
   CALL echo("Entering GET_PERSON_PRSNL_R_CD")
   DECLARE appid_ppr = i4 WITH protect, constant(5000)
   DECLARE tskid_ppr = i4 WITH protect, constant(600206)
   DECLARE reqid_ppr = i4 WITH protect, constant(3200310)
   DECLARE happ_ppr = i4 WITH protect, noconstant(0)
   DECLARE htask_ppr = i4 WITH protect, noconstant(0)
   DECLARE hstep_ppr = i4 WITH protect, noconstant(0)
   DECLARE hrequest_ppr = i4 WITH protect, noconstant(0)
   DECLARE hreply_ppr = i4 WITH protect, noconstant(0)
   DECLARE irtn_ppr = i4 WITH protect, noconstant(0)
   SET irtn_ppr = uar_crmbeginapp(appid_ppr,happ_ppr)
   IF (irtn_ppr != 0)
    CALL echo(
     "uar_crm_begin_app failed in msvc_svr_get_clinctx Service for PPR from dcp_get_forms_activity_prt"
     )
    SET failure_ind = 1
    GO TO exit_script
   ENDIF
   SET irtn_ppr = uar_crmbegintask(happ_ppr,tskid_ppr,htask_ppr)
   IF (irtn_ppr != 0)
    CALL echo(
     "uar_crm_begin_task failed in msvc_svr_get_clinctx Service for PPR from dcp_get_forms_activity_prt"
     )
    SET failure_ind = 1
    GO TO exit_script
   ENDIF
   SET irtn_ppr = uar_crmbeginreq(htask_ppr,"",reqid_ppr,hstep_ppr)
   IF (irtn_ppr != 0)
    CALL echo(
     "uar_crm_begin_Request failed in msvc_svr_get_clinctx Service for PPR from dcp_get_forms_activity_prt"
     )
    SET failure_ind = 1
    GO TO exit_script
   ENDIF
   SET hrequest_ppr = uar_crmgetrequest(hstep_ppr)
   IF (hrequest_ppr)
    CALL set_ppr_request(hrequest_ppr)
   ENDIF
   SET irtn_ppr = uar_crmperform(hstep_ppr)
   SET hreply_ppr = uar_crmgetreply(hstep_ppr)
   IF (hreply_ppr)
    CALL check_reply_status(hreply_ppr)
    CALL get_ppr_reply(hreply_ppr)
   ENDIF
   CALL cleanup(happ_ppr,htask_ppr,hstep_ppr)
   CALL echo("leaving GET_PERSON_PRSNL_R_CD")
 END ;Subroutine
 SUBROUTINE (set_ppr_request(request_ppr=i4) =null)
   CALL echo("Enter SET_PPR_REQUEST")
   DECLARE iload = i4 WITH protect, noconstant(0)
   SET stat_ppr = uar_srvsetdouble(request_ppr,"patient_id",temp->person_id)
   SET stat_ppr = uar_srvsetdouble(request_ppr,"encounter_id",temp->encntr_id)
   SET iload = uar_srvgetstruct(request_ppr,"load")
   IF (iload)
    SET stat_ppr = uar_srvsetshort(iload,"encounter_relationship",1)
    SET stat_ppr = uar_srvsetshort(iload,"patient_relationship",1)
   ENDIF
 END ;Subroutine
 SUBROUTINE (get_ppr_reply(reply_ppr=i4) =null)
   CALL echo("Enter GET_PPR_REPLY")
   IF (reply_ppr=0)
    RETURN
   ENDIF
   DECLARE cnt_encntr_reltn = i4 WITH protect, noconstant(0)
   DECLARE idx_encntr_reltn = i4 WITH protect, noconstant(0)
   DECLARE hencntrreltn = i4 WITH protect, noconstant(0)
   DECLARE hencntrreltnships = i4 WITH protect, noconstant(0)
   DECLARE cnt_pa_reltn = i4 WITH protect, noconstant(0)
   DECLARE idx_pa_reltn = i4 WITH protect, noconstant(0)
   DECLARE hpareltn = i4 WITH protect, noconstant(0)
   DECLARE hpareltnships = i4 WITH protect, noconstant(0)
   DECLARE tmp_prsnl_id = f8 WITH protect, noconstant(0.0)
   DECLARE tmp_encntr_id = f8 WITH protect, noconstant(0.0)
   SET hencntrreltn = uar_srvgetstruct(reply_ppr,"encounter_relationship")
   IF (hencntrreltn)
    SET cnt_encntr_reltn = uar_srvgetitemcount(hencntrreltn,"encounter_relationships")
    FOR (idx_encntr_reltn = 0 TO cnt_encntr_reltn)
     SET hencntrreltnships = uar_srvgetitem(hencntrreltn,"encounter_relationships",idx_encntr_reltn)
     IF (hencntrreltnships)
      SET tmp_prsnl_id = uar_srvgetdouble(hencntrreltnships,"prsnl_id")
      SET tmp_encntr_id = uar_srvgetdouble(hencntrreltnships,"encntr_id")
      IF ((tmp_prsnl_id=reqinfo->updt_id)
       AND (tmp_encntr_id=temp->encntr_id))
       SET temp->person_prsnl_r_cd = uar_srvgetdouble(hencntrreltnships,"encntr_prsnl_reltn_cd")
       RETURN
      ENDIF
     ENDIF
    ENDFOR
   ENDIF
   SET hpareltn = uar_srvgetstruct(reply_ppr,"patient_relationship")
   IF (hpareltn)
    SET cnt_pa_reltn = uar_srvgetitemcount(hpareltn,"patient_relationships")
    FOR (idx_pa_reltn = 0 TO cnt_pa_reltn)
     SET hpareltnships = uar_srvgetitem(hpareltn,"patient_relationships",idx_pa_reltn)
     IF (hpareltnships)
      SET tmp_prsnl_id = uar_srvgetdouble(hpareltnships,"prsnl_id")
      IF ((tmp_prsnl_id=reqinfo->updt_id))
       SET temp->person_prsnl_r_cd = uar_srvgetdouble(hpareltnships,"person_prsnl_reltn_id")
       RETURN
      ENDIF
     ENDIF
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE (set_medlist_request(request_medlist=i4) =null)
   CALL echo("Enter SET_MEDLIST_REQUEST")
   DECLARE hencountercriteria = i4 WITH noconstant(0), protect
   DECLARE hactiveorderscriteria = i4 WITH noconstant(0), protect
   DECLARE hactiveorderstatus = i4 WITH noconstant(0), protect
   DECLARE hinactiveorderscriteria = i4 WITH noconstant(0), protect
   DECLARE hmedordercriteria = i4 WITH noconstant(0), protect
   DECLARE hinactiveorderstatus = i4 WITH noconstant(0), protect
   DECLARE husercriteria = i4 WITH noconstant(0), protect
   DECLARE hdatecriteria = i4 WITH noconstant(0), protect
   DECLARE hloadind = i4 WITH noconstant(0), protect
   DECLARE medlistorgsecind = i2 WITH protect, noconstant(0)
   DECLARE medlistencntrfilterind = i2 WITH protect, noconstant(0)
   DECLARE hencountercriteriaencounters = i4 WITH noconstant(0), protect
   CALL checkmedlistorgsec(null)
   CALL checkmedlistencntrfilter(null)
   SET stat_medlist = uar_srvsetdouble(request_medlist,"patient_id",temp->person_id)
   SET hencountercriteria = uar_srvgetstruct(request_medlist,"encounter_criteria")
   IF (hencountercriteria)
    IF (medlistorgsecind=1)
     SET stat_medlist = uar_srvsetshort(hencountercriteria,"override_org_security_ind",0)
    ELSE
     SET stat_medlist = uar_srvsetshort(hencountercriteria,"override_org_security_ind",1)
    ENDIF
    IF (medlistencntrfilterind=1)
     SET hencountercriteriaencounters = uar_srvadditem(hencountercriteria,nullterm("encounters"))
     SET stat_medlist = uar_srvsetdouble(hencountercriteriaencounters,"encounter_id",temp->encntr_id)
    ENDIF
   ENDIF
   SET husercriteria = uar_srvgetstruct(request_medlist,"user_criteria")
   IF (husercriteria)
    SET stat_medlist = uar_srvsetdouble(husercriteria,"user_id",reqinfo->updt_id)
    SET stat_medlist = uar_srvsetdouble(husercriteria,"patient_user_relationship_cd",temp->
     person_prsnl_r_cd)
   ENDIF
   SET hactiveorderscriteria = uar_srvgetstruct(request_medlist,"active_orders_criteria")
   IF (hactiveorderscriteria)
    SET hactiveorderstatus = uar_srvgetstruct(hactiveorderscriteria,"order_statuses")
    IF (hactiveorderstatus)
     SET stat_medlist = uar_srvsetshort(hactiveorderstatus,"load_ordered_ind",1)
     SET stat_medlist = uar_srvsetshort(hactiveorderstatus,"load_future_ind",1)
     SET stat_medlist = uar_srvsetshort(hactiveorderstatus,"load_in_process_ind",1)
     SET stat_medlist = uar_srvsetshort(hactiveorderstatus,"load_on_hold_ind",1)
     SET stat_medlist = uar_srvsetshort(hactiveorderstatus,"load_suspended_ind",1)
     SET stat_medlist = uar_srvsetshort(hactiveorderstatus,"load_incomplete_ind",1)
    ENDIF
   ENDIF
   DECLARE horderprofileind = i4 WITH noconstant(0), protect
   DECLARE hcommentind = i4 WITH noconstant(0), protect
   SET hinactiveorderscriteria = uar_srvgetstruct(request_medlist,"inactive_orders_criteria")
   IF (hinactiveorderscriteria)
    SET hinactiveorderstatus = uar_srvgetstruct(hinactiveorderscriteria,"order_statuses")
    IF (hinactiveorderstatus)
     SET stat_medlist = uar_srvsetshort(hinactiveorderstatus,"load_canceled_ind",1)
     SET stat_medlist = uar_srvsetshort(hinactiveorderstatus,"load_discontinued_ind",1)
     SET stat_medlist = uar_srvsetshort(hinactiveorderstatus,"load_completed_ind",1)
     SET stat_medlist = uar_srvsetshort(hinactiveorderstatus,"load_pending_complete_ind",1)
     SET stat_medlist = uar_srvsetshort(hinactiveorderstatus,"load_voided_with_results_ind",1)
     SET stat_medlist = uar_srvsetshort(hinactiveorderstatus,"load_voided_without_results_ind",1)
     SET stat_medlist = uar_srvsetshort(hinactiveorderstatus,"load_transfer_canceled_ind",1)
    ENDIF
    SET hdatecriteria = uar_srvgetstruct(hinactiveorderscriteria,"date_criteria")
    IF (hdatecriteria)
     SET stat_medlist = uar_srvsetdate(hdatecriteria,"begin_dt_tm",cnvtdatetime((curdate - 1),
       curtime3))
     SET stat_medlist = uar_srvsetdate(hdatecriteria,"end_dt_tm",cnvtdatetime(sysdate))
     SET stat_medlist = uar_srvsetshort(hdatecriteria,"qualify_on_start_dt_tm_ind",1)
    ENDIF
   ENDIF
   SET hmedordercriteria = uar_srvgetstruct(request_medlist,"medication_order_criteria")
   IF (hmedordercriteria)
    SET stat_medlist = uar_srvsetshort(hmedordercriteria,"load_normal_ind",1)
    SET stat_medlist = uar_srvsetshort(hmedordercriteria,"load_prescription_ind",1)
    SET stat_medlist = uar_srvsetshort(hmedordercriteria,"load_documented_ind",1)
    SET stat_medlist = uar_srvsetshort(hmedordercriteria,"load_charge_only_ind",1)
    SET stat_medlist = uar_srvsetshort(hmedordercriteria,"load_satellite_ind",1)
   ENDIF
   SET hloadind = uar_srvgetstruct(request_medlist,"load_indicators")
   IF (hloadind)
    SET horderprofileind = uar_srvgetstruct(hloadind,"order_profile_indicators")
    IF (horderprofileind)
     SET hcommentind = uar_srvgetstruct(horderprofileind,"comment_types")
     IF (hcommentind)
      SET stat_medlist = uar_srvsetshort(hcommentind,"load_order_comment_ind",1)
     ENDIF
     SET stat_medlist = uar_srvsetshort(horderprofileind,"load_order_schedule_ind",1)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (get_medlist_reply(xx=i4,yy=i4,reply_medlist=i4) =null)
   CALL echo("Enter GET_MEDLIST_REPLY")
   IF (reply_medlist=0)
    RETURN
   ENDIF
   DECLARE cnt_active_ord = i4 WITH protect, noconstant(0)
   DECLARE hactiveorders = i4 WITH protect, noconstant(0)
   DECLARE idx_active_ord = i4 WITH protect, noconstant(0)
   DECLARE order_status_cd = f8 WITH protect, noconstant(0.0)
   DECLARE icomment = i4 WITH protect, noconstant(0)
   DECLARE icore = i4 WITH protect, noconstant(0)
   DECLARE ischedule = i4 WITH protect, noconstant(0)
   DECLARE ischeduleinactive = i4 WITH protect, noconstant(0)
   DECLARE imnemonic = i4 WITH protect, noconstant(0)
   DECLARE idisplay = i4 WITH protect, noconstant(0)
   DECLARE imedinfo = i4 WITH protect, noconstant(0)
   DECLARE iorigorderedas = i4 WITH protect, noconstant(0)
   SET cnt_active_ord = uar_srvgetitemcount(reply_medlist,"active_orders")
   SET temp->sl[xx].ind = 1
   SET stat = alterlist(temp->sl[xx].il[yy].med_list,cnt_active_ord)
   FOR (idx_active_ord = 1 TO cnt_active_ord)
    SET hactiveorders = uar_srvgetitem(reply_medlist,"active_orders",(idx_active_ord - 1))
    IF (hactiveorders)
     SET idisplay = uar_srvgetstruct(hactiveorders,"displays")
     IF (idisplay)
      SET temp->sl[xx].il[yy].med_list[idx_active_ord].reference_name = uar_srvgetstringptr(idisplay,
       "reference_name")
      SET temp->sl[xx].il[yy].med_list[idx_active_ord].display_line = uar_srvgetstringptr(idisplay,
       "simplified_display_line")
     ENDIF
     SET icomment = uar_srvgetstruct(hactiveorders,"comments")
     IF (icomment)
      SET temp->sl[xx].il[yy].med_list[idx_active_ord].comment = uar_srvgetstringptr(icomment,
       "order_comment")
     ENDIF
     SET icore = uar_srvgetstruct(hactiveorders,"core")
     IF (icore)
      SET temp->sl[xx].il[yy].med_list[idx_active_ord].provider_id = uar_srvgetdouble(icore,
       "responsible_provider_id")
      SET order_status_cd = uar_srvgetdouble(icore,"order_status_cd")
      SET temp->sl[xx].il[yy].med_list[idx_active_ord].order_status = uar_get_code_display(
       order_status_cd)
     ENDIF
     SET ischedule = uar_srvgetstruct(hactiveorders,"schedule")
     IF (ischedule)
      SET stat = uar_srvgetdate2(ischedule,"original_order_dt_tm",date_temp)
      SET temp->sl[xx].il[yy].med_list[idx_active_ord].order_tz = uar_srvgetlong(ischedule,
       "original_order_tz")
      SET temp->sl[xx].il[yy].med_list[idx_active_ord].order_dt_tm_str = trim(formatdatetime(temp->
        sl[xx].il[yy].med_list[idx_active_ord].order_tz," "))
     ENDIF
     SET imedinfo = uar_srvgetstruct(hactiveorders,"medication_information")
     IF (imedinfo)
      SET temp->sl[xx].il[yy].med_list[idx_active_ord].medication_order_type_cd = uar_srvgetdouble(
       imedinfo,"medication_order_type_cd")
     ENDIF
     SET iorigorderedas = uar_srvgetstruct(imedinfo,"originally_ordered_as_type")
     IF (iorigorderedas)
      SET temp->sl[xx].il[yy].med_list[idx_active_ord].originally_ordered_as_type.normal_ind =
      uar_srvgetshort(iorigorderedas,"normal_ind")
      SET temp->sl[xx].il[yy].med_list[idx_active_ord].originally_ordered_as_type.prescription_ind =
      uar_srvgetshort(iorigorderedas,"prescription_ind")
      SET temp->sl[xx].il[yy].med_list[idx_active_ord].originally_ordered_as_type.documented_ind =
      uar_srvgetshort(iorigorderedas,"documented_ind")
      SET temp->sl[xx].il[yy].med_list[idx_active_ord].originally_ordered_as_type.patients_own_ind =
      uar_srvgetshort(iorigorderedas,"patients_own_ind")
      SET temp->sl[xx].il[yy].med_list[idx_active_ord].originally_ordered_as_type.charge_only_ind =
      uar_srvgetshort(iorigorderedas,"charge_only_ind")
      SET temp->sl[xx].il[yy].med_list[idx_active_ord].originally_ordered_as_type.satellite_ind =
      uar_srvgetshort(iorigorderedas,"satellite_ind")
     ENDIF
     IF ((temp->sl[xx].il[yy].med_list[idx_active_ord].originally_ordered_as_type.normal_ind=1))
      SET temp->sl[xx].il[yy].med_list[idx_active_ord].med_type_ind = 1
      SET normalorder = 1
     ELSEIF ((temp->sl[xx].il[yy].med_list[idx_active_ord].originally_ordered_as_type.
     prescription_ind=1))
      SET temp->sl[xx].il[yy].med_list[idx_active_ord].med_type_ind = 2
      SET prescriptionorder = 1
     ELSEIF ((temp->sl[xx].il[yy].med_list[idx_active_ord].originally_ordered_as_type.documented_ind=
     1))
      SET temp->sl[xx].il[yy].med_list[idx_active_ord].med_type_ind = 3
      SET homemeds = 1
     ELSEIF ((temp->sl[xx].il[yy].med_list[idx_active_ord].originally_ordered_as_type.
     patients_own_ind=1))
      SET temp->sl[xx].il[yy].med_list[idx_active_ord].med_type_ind = 4
      SET patientownsmeds = 1
     ELSEIF ((temp->sl[xx].il[yy].med_list[idx_active_ord].originally_ordered_as_type.charge_only_ind
     =1))
      SET temp->sl[xx].il[yy].med_list[idx_active_ord].med_type_ind = 5
      SET chargeonly = 1
     ELSEIF ((temp->sl[xx].il[yy].med_list[idx_active_ord].originally_ordered_as_type.satellite_ind=1
     ))
      SET temp->sl[xx].il[yy].med_list[idx_active_ord].med_type_ind = 6
      SET satellitemeds = 1
     ELSE
      SET otherorder = 1
     ENDIF
    ENDIF
   ENDFOR
   DECLARE cnt_inactive_ord = i4 WITH noconstant(0), protect
   DECLARE hinactiveorders = i4 WITH noconstant(0), protect
   DECLARE idx_inactive_ord = i4 WITH noconstant(0), protect
   SET cnt_inactive_ord = uar_srvgetitemcount(reply_medlist,"inactive_orders")
   SET stat = alterlist(temp->sl[xx].il[yy].med_list,(cnt_active_ord+ cnt_inactive_ord))
   FOR (idx_inactive_ord = 1 TO cnt_inactive_ord)
    SET hinactiveorders = uar_srvgetitem(reply_medlist,"inactive_orders",(idx_inactive_ord - 1))
    IF (hinactiveorders)
     SET idisplay = uar_srvgetstruct(hinactiveorders,"displays")
     IF (idisplay)
      SET temp->sl[xx].il[yy].med_list[(cnt_active_ord+ idx_inactive_ord)].reference_name = trim(
       uar_srvgetstringptr(idisplay,"reference_name"))
      SET temp->sl[xx].il[yy].med_list[(cnt_active_ord+ idx_inactive_ord)].display_line =
      uar_srvgetstringptr(idisplay,"simplified_display_line")
     ENDIF
     SET icomment = uar_srvgetstruct(hinactiveorders,"comments")
     IF (icomment)
      SET temp->sl[xx].il[yy].med_list[(cnt_active_ord+ idx_inactive_ord)].comment =
      uar_srvgetstringptr(icomment,"order_comment")
     ENDIF
     SET icore = uar_srvgetstruct(hinactiveorders,"core")
     IF (icore)
      SET temp->sl[xx].il[yy].med_list[idx_active_ord].provider_id = uar_srvgetdouble(icore,
       "responsible_provider_id")
      SET order_status_cd = uar_srvgetdouble(icore,"order_status_cd")
      SET temp->sl[xx].il[yy].med_list[(cnt_active_ord+ idx_inactive_ord)].order_status =
      uar_get_code_display(order_status_cd)
     ENDIF
     SET ischeduleinactive = uar_srvgetstruct(hinactiveorders,"schedule")
     IF (ischeduleinactive)
      SET stat = uar_srvgetdate2(ischeduleinactive,"original_order_dt_tm",date_temp)
      SET temp->sl[xx].il[yy].med_list[(cnt_active_ord+ idx_inactive_ord)].order_tz = uar_srvgetlong(
       ischeduleinactive,"original_order_tz")
      SET temp->sl[xx].il[yy].med_list[idx_active_ord].order_dt_tm_str = trim(formatdatetime(temp->
        sl[xx].il[yy].med_list[(cnt_active_ord+ idx_inactive_ord)].order_tz," "))
     ENDIF
     SET imedinfo = uar_srvgetstruct(hinactiveorders,"medication_information")
     IF (imedinfo)
      SET temp->sl[xx].il[yy].med_list[(cnt_active_ord+ idx_inactive_ord)].medication_order_type_cd
       = uar_srvgetdouble(imedinfo,"medication_order_type_cd")
     ENDIF
     SET iorigorderedas = uar_srvgetstruct(imedinfo,"originally_ordered_as_type")
     IF (iorigorderedas)
      SET temp->sl[xx].il[yy].med_list[(cnt_active_ord+ idx_inactive_ord)].originally_ordered_as_type
      .normal_ind = uar_srvgetshort(iorigorderedas,"normal_ind")
      SET temp->sl[xx].il[yy].med_list[(cnt_active_ord+ idx_inactive_ord)].originally_ordered_as_type
      .prescription_ind = uar_srvgetshort(iorigorderedas,"prescription_ind")
      SET temp->sl[xx].il[yy].med_list[(cnt_active_ord+ idx_inactive_ord)].originally_ordered_as_type
      .documented_ind = uar_srvgetshort(iorigorderedas,"documented_ind")
      SET temp->sl[xx].il[yy].med_list[(cnt_active_ord+ idx_inactive_ord)].originally_ordered_as_type
      .patients_own_ind = uar_srvgetshort(iorigorderedas,"patients_own_ind")
      SET temp->sl[xx].il[yy].med_list[(cnt_active_ord+ idx_inactive_ord)].originally_ordered_as_type
      .charge_only_ind = uar_srvgetshort(iorigorderedas,"charge_only_ind")
      SET temp->sl[xx].il[yy].med_list[(cnt_active_ord+ idx_inactive_ord)].originally_ordered_as_type
      .satellite_ind = uar_srvgetshort(iorigorderedas,"satellite_ind")
     ENDIF
     IF ((temp->sl[xx].il[yy].med_list[(cnt_active_ord+ idx_inactive_ord)].originally_ordered_as_type
     .normal_ind=1))
      SET temp->sl[xx].il[yy].med_list[(cnt_active_ord+ idx_inactive_ord)].med_type_ind = 1
      SET normalorder = 1
     ELSEIF ((temp->sl[xx].il[yy].med_list[(cnt_active_ord+ idx_inactive_ord)].
     originally_ordered_as_type.prescription_ind=1))
      SET temp->sl[xx].il[yy].med_list[(cnt_active_ord+ idx_inactive_ord)].med_type_ind = 2
      SET prescriptionorder = 1
     ELSEIF ((temp->sl[xx].il[yy].med_list[(cnt_active_ord+ idx_inactive_ord)].
     originally_ordered_as_type.documented_ind=1))
      SET temp->sl[xx].il[yy].med_list[(cnt_active_ord+ idx_inactive_ord)].med_type_ind = 3
      SET homemeds = 1
     ELSEIF ((temp->sl[xx].il[yy].med_list[(cnt_active_ord+ idx_inactive_ord)].
     originally_ordered_as_type.patients_own_ind=1))
      SET temp->sl[xx].il[yy].med_list[(cnt_active_ord+ idx_inactive_ord)].med_type_ind = 4
      SET patientownsmeds = 1
     ELSEIF ((temp->sl[xx].il[yy].med_list[(cnt_active_ord+ idx_inactive_ord)].
     originally_ordered_as_type.charge_only_ind=1))
      SET temp->sl[xx].il[yy].med_list[(cnt_active_ord+ idx_inactive_ord)].med_type_ind = 5
      SET chargeonly = 1
     ELSEIF ((temp->sl[xx].il[yy].med_list[(cnt_active_ord+ idx_inactive_ord)].
     originally_ordered_as_type.satellite_ind=1))
      SET temp->sl[xx].il[yy].med_list[(cnt_active_ord+ idx_inactive_ord)].med_type_ind = 6
      SET satellitemeds = 1
     ELSE
      SET otherorder = 1
     ENDIF
    ENDIF
   ENDFOR
   CALL get_provider_names(xx,yy,(cnt_active_ord+ cnt_inactive_ord))
 END ;Subroutine
 SUBROUTINE (get_provider_names(xx=i4,yy=i4,provider_cnt=i4) =null)
   CALL echo("Enter GET_PROVIDER_NAMES")
   IF (provider_cnt < 1)
    RETURN
   ENDIF
   DECLARE find_idx = i4 WITH noconstant(0), protect
   DECLARE icnt = i4 WITH noconstant(0), protect
   DECLARE maxcnt = i4 WITH constant(10), protect
   DECLARE blocksize = i4 WITH constant(ceil(((provider_cnt * 1.0)/ maxcnt))), protect
   DECLARE x_start = i4 WITH noconstant(1), protect
   DECLARE x_idx = i4 WITH noconstant(1), protect
   DECLARE xmaxsize = i4 WITH noconstant((blocksize * maxcnt)), protect
   SET stat = alterlist(provider_list->qual,xmaxsize)
   FOR (icnt = 1 TO xmaxsize)
     IF (icnt > provider_cnt)
      SET provider_list->qual[icnt].provider_id = temp->sl[xx].il[yy].med_list[provider_cnt].
      provider_id
     ELSE
      SET provider_list->qual[icnt].provider_id = temp->sl[xx].il[yy].med_list[icnt].provider_id
     ENDIF
   ENDFOR
   SELECT DISTINCT INTO "NL:"
    FROM (dummyt dt  WITH seq = value(blocksize)),
     prsnl p
    PLAN (dt
     WHERE assign(x_start,evaluate(dt.seq,1,1,(x_start+ maxcnt))))
     JOIN (p
     WHERE expand(x_idx,x_start,((x_start+ maxcnt) - 1),p.person_id,provider_list->qual[x_idx].
      provider_id))
    ORDER BY p.person_id
    HEAD p.person_id
     FOR (find_idx = 1 TO provider_cnt)
       IF ((temp->sl[xx].il[yy].med_list[find_idx].provider_id=p.person_id))
        temp->sl[xx].il[yy].med_list[find_idx].provider_name = p.name_full_formatted
       ENDIF
     ENDFOR
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE (check_reply_status(hreply=i4) =null)
   CALL echo("Enter CHECK_REPLY_STATUS")
   IF (hreply=0)
    CALL echo("Check_Reply_Status - reply parameter is empty")
    SET failure_ind = 1
    GO TO exit_script
   ENDIF
   DECLARE hstatus_data = i4 WITH protect, noconstant(0)
   DECLARE status_vc = c1 WITH protect, noconstant(fillstring(1," "))
   SET hstatus_data = uar_srvgetstruct(hreply,"status_data")
   IF (hstatus_data)
    SET status_vc = uar_srvgetstringptr(hstatus_data,"status")
    CALL echo(build("Reply Status:",status_vc))
    IF (((status_vc="F") OR (status_vc="f")) )
     CALL echo("Check_Reply_Status - returned status F")
     SET failure_ind = 1
     GO TO exit_script
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (get_order_compliance(xx=i4,yy=i4) =null)
   CALL echo("Entering GET_ORDER_COMPLIANCE")
   DECLARE compliance_cnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM order_compliance oc,
     prsnl p
    PLAN (oc
     WHERE (oc.encntr_id=temp->encntr_id))
     JOIN (p
     WHERE oc.performed_prsnl_id=p.person_id)
    ORDER BY oc.performed_dt_tm DESC
    HEAD oc.performed_dt_tm
     compliance_cnt = 0
    DETAIL
     compliance_cnt += 1
     IF (compliance_cnt > size(temp->sl[xx].il[yy].order_compliance,5))
      stat = alterlist(temp->sl[xx].il[yy].order_compliance,compliance_cnt)
     ENDIF
     temp->sl[xx].il[yy].order_compliance[1].unable_to_obtain_ind = oc.unable_to_obtain_ind, temp->
     sl[xx].il[yy].order_compliance[1].no_known_home_meds_ind = oc.no_known_home_meds_ind, temp->sl[
     xx].il[yy].order_compliance[1].performed_by_name = p.name_full_formatted,
     date_temp->dt1 = cnvtdatetime(oc.performed_dt_tm), temp->sl[xx].il[yy].order_compliance[1].
     performed_dt_tm_str = trim(formatdatetime(oc.performed_tz," "))
    WITH maxqual(oc,1)
   ;end select
   CALL echo(build("compliance_cnt: ",compliance_cnt))
 END ;Subroutine
 SUBROUTINE get_general_result(xx,yy)
   CALL echo("Entering GET_GENERAL_RESULT")
   DECLARE eventinputitercnt = i4 WITH protect
   DECLARE hprotinputevent = i4 WITH protect
   DECLARE result_val = vc WITH protect
   DECLARE result_status_cd = f8 WITH protect
   DECLARE result_units_cd = f8 WITH protect
   DECLARE task_assay_cd = f8 WITH protect
   SET hinputresult = 0
   IF (hsectionresult)
    SET eventinputitercnt = uar_srvgetitemcount(hsectionresult,"child_event_list")
    FOR (iter = 0 TO (eventinputitercnt - 1))
     SET hprotinputevent = uar_srvgetitem(hsectionresult,"child_event_list",iter)
     IF (hprotinputevent)
      SET task_assay_cd = uar_srvgetdouble(hprotinputevent,"task_assay_cd")
      IF (((task_assay_cd != 0
       AND task_assay_cd=cnvtreal(trim(temp->sl[xx].il[yy].pvc_value))) OR (((uar_srvgetdouble(
       hprotinputevent,"event_cd")=cnvtreal(trim(temp->sl[xx].il[yy].pvc_value))) OR ((cnvtreal(
       uar_srvgetstringptr(hprotinputevent,"collating_seq"))=temp->sl[xx].il[yy].dcp_input_ref_id)))
      )) )
       SET temp->sl[xx].ind = 1
       SET iter = (eventinputitercnt - 1)
       SET hinputresult = hprotinputevent
       SET result_val = uar_srvgetstringptr(hinputresult,"result_val")
       IF ((((temp->sl[xx].il[yy].input_type=2)) OR ((((temp->sl[xx].il[yy].input_type=7)) OR ((temp
       ->sl[xx].il[yy].input_type=22))) ))
        AND  NOT (trim(temp->sl[xx].il[yy].module)="PVTRACKFORMS"))
        SET temp->sl[xx].il[yy].event_tag = trim(format(result_val,"#########################;I;F"),3
         )
       ELSE
        SET temp->sl[xx].il[yy].event_tag = trim(nullterm(result_val))
       ENDIF
       IF ((((temp->sl[xx].il[yy].event_tag > " ")) OR (textlen(temp->sl[xx].il[yy].event_tag) > 0))
       )
        SET temp->sl[xx].ind = 1
        SET temp->sl[xx].il[yy].ind = 1
       ENDIF
       SET result_units_cd = uar_srvgetdouble(hinputresult,"result_units_cd")
       IF (result_units_cd > 0)
        SET temp->sl[xx].il[yy].unit = trim(substring(1,40,uar_srvgetstringptr(hinputresult,
           "result_units_cd_disp")),3)
       ENDIF
       IF ((temp->sl[xx].il[yy].unit > " ")
        AND (temp->sl[xx].il[yy].ind=1))
        SET temp->sl[xx].il[yy].event_tag = concat(temp->sl[xx].il[yy].event_tag," ",temp->sl[xx].il[
         yy].unit)
       ENDIF
       SET temp->sl[xx].il[yy].description = trim(substring(1,40,uar_srvgetstringptr(hinputresult,
          "event_cd_disp")),3)
       IF ((temp->sl[xx].il[yy].input_type != 5))
        SET temp->sl[xx].il[yy].description = concat(trim(temp->sl[xx].il[yy].description)," ")
       ENDIF
       SET temp->sl[xx].il[yy].task_assay_cd = uar_srvgetdouble(hinputresult,"task_assay_cd")
       SET stat = uar_srvgetdate2(hinputresult,"event_end_dt_tm",date_temp)
       SET temp->sl[xx].il[yy].date = cnvtdatetime(date_temp->dt1)
       SET temp->sl[xx].il[yy].note_ind = btest(uar_srvgetlong(hinputresult,"subtable_bit_map"),1)
       IF ((temp->sl[xx].il[yy].note_ind=1))
        CALL get_comments(hinputresult)
        SET temp->sl[xx].il[yy].note_text = comment_tag
       ENDIF
       SET temp->sl[xx].il[yy].event_id = uar_srvgetdouble(hinputresult,"event_id")
       SET temp->sl[xx].il[yy].valid_date = uar_srvgetdateptr(hinputresult,"valid_until_dt_tm")
       SET temp->sl[xx].il[yy].event_cd = uar_srvgetdouble(hinputresult,"event_cd")
       SET temp->sl[xx].il[yy].parent_event_id = uar_srvgetdouble(hinputresult,"parent_event_id")
       SET result_status_cd = uar_srvgetdouble(hinputresult,"result_status_cd")
       IF (result_status_cd=modified_cd)
        SET temp->sl[xx].il[yy].status_ind = modified_ind
        SET temp->sl[xx].il[yy].event_tag = concat(trim(temp->sl[xx].il[yy].event_tag)," (",captions
         ->smodified,")")
       ENDIF
       IF (result_status_cd=inerror_cd)
        SET temp->sl[xx].il[yy].status_ind = inerror_ind
        SET temp->sl[xx].il[yy].event_tag = error_line
       ENDIF
       IF (result_status_cd=unauth_cd)
        SET temp->sl[xx].il[yy].event_tag = concat(trim(temp->sl[xx].il[yy].event_tag)," (",captions
         ->sunauth,")")
        SET temp->sl[xx].il[yy].status_ind = unauth_ind
       ENDIF
       IF (result_status_cd=inprogress_cd)
        SET temp->sl[xx].il[yy].event_tag = concat(trim(temp->sl[xx].il[yy].event_tag)," (",captions
         ->sinprogress,")")
        SET temp->sl[xx].il[yy].status_ind = inprogress_ind
       ENDIF
      ENDIF
     ENDIF
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE get_rtf_result(xx,yy)
   CALL echo("Entering GET_RTF_RESULT")
   DECLARE hblobresult = i4 WITH protect
   DECLARE hblob = i4 WITH protect
   DECLARE rtf_blob = i4 WITH protect
   DECLARE blob_content = vc WITH protect
   DECLARE blob_out2 = c32000 WITH protect
   DECLARE blobcount = i4 WITH protect
   DECLARE blob_size = i4 WITH protect
   DECLARE return_blob_size = i4 WITH protect
   SET blob_size = 32000
   IF (hinputresult)
    SET blob_content = fillstring(32000," ")
    SET blobcount = uar_srvgetitemcount(hinputresult,"blob_result")
    IF (blobcount > 0)
     SET hblobresult = uar_srvgetitem(hinputresult,"blob_result",0)
     IF (hblobresult)
      SET rtf_blob = uar_srvgetitemcount(hblobresult,"blob")
      IF (rtf_blob > 0)
       SET hblob = uar_srvgetitem(hblobresult,"blob",0)
       IF (hblob)
        SET blob_content = uar_srvgetasisptr(hblob,"blob_contents")
        CALL uar_rtf3(blob_content,size(blob_content),blob_out2,blob_size,return_blob_size,
         0)
        SET temp->sl[xx].il[yy].event_tag = concat(trim(blob_out2,3))
       ENDIF
      ENDIF
      IF ((temp->sl[xx].il[yy].status_ind=modified_ind))
       SET temp->sl[xx].il[yy].event_tag = concat(trim(temp->sl[xx].il[yy].event_tag)," (",captions->
        smodified,")")
      ENDIF
      IF ((temp->sl[xx].il[yy].status_ind=unauth_ind))
       SET temp->sl[xx].il[yy].event_tag = concat(trim(temp->sl[xx].il[yy].event_tag)," (",captions->
        sunauth,")")
      ENDIF
      IF ((temp->sl[xx].il[yy].status_ind=inerror_ind))
       SET temp->sl[xx].il[yy].event_tag = error_line
      ENDIF
      IF ((temp->sl[xx].il[yy].status_ind=inprogress_ind))
       SET temp->sl[xx].il[yy].event_tag = concat(trim(temp->sl[xx].il[yy].event_tag)," (",captions->
        sinprogress,")")
      ENDIF
      IF ((temp->sl[xx].il[yy].event_tag > " "))
       SET temp->sl[xx].ind = 1
       SET temp->sl[xx].il[yy].ind = 1
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   CALL echo("Leaving  GET_RTF_RESULT")
 END ;Subroutine
 SUBROUTINE get_alpha_result(xx,yy)
   CALL echo("Entering GET_ALPHA_RESULT")
   IF (hinputresult)
    CALL get_general_coded_result(hinputresult,xx,yy)
    SET temp->sl[xx].il[yy].event_tag = coded_tag
    IF ((temp->sl[xx].il[yy].status_ind=modified_ind))
     SET temp->sl[xx].il[yy].event_tag = concat(trim(temp->sl[xx].il[yy].event_tag)," (",captions->
      smodified,")")
    ENDIF
    IF ((temp->sl[xx].il[yy].status_ind=inerror_ind))
     SET temp->sl[xx].il[yy].event_tag = error_line
    ENDIF
    IF ((temp->sl[xx].il[yy].status_ind=unauth_ind))
     SET temp->sl[xx].il[yy].event_tag = concat(trim(temp->sl[xx].il[yy].event_tag)," (",captions->
      sunauth,")")
    ENDIF
    IF ((temp->sl[xx].il[yy].status_ind=inprogress_ind))
     SET temp->sl[xx].il[yy].event_tag = concat(trim(temp->sl[xx].il[yy].event_tag)," (",captions->
      sinprogress,")")
    ENDIF
   ENDIF
   CALL echo("Exiting GET_ALPHA_RESULT")
 END ;Subroutine
 SUBROUTINE get_magrid_result(xx,yy)
   CALL echo("Entering GET_MAGRID_RESULT")
   DECLARE codecount = i4 WITH protect
   DECLARE hcodedresult = i4 WITH protect
   DECLARE nom_cnt = i4 WITH protect
   DECLARE qual_cnt = i4 WITH protect
   IF (hinputresult)
    SET codecount = uar_srvgetitemcount(hinputresult,"coded_result_list")
    CALL echo(build("Code count:",codecount))
    SET stat = alterlist(nomen_temp->nomen_qual,codecount)
    FOR (codeiter = 1 TO codecount)
     SET hcodedresult = uar_srvgetitem(hinputresult,"coded_result_list",(codeiter - 1))
     IF (hcodedresult)
      SET nomen_temp->nomen_qual[codeiter].nomenclature_id = uar_srvgetdouble(hcodedresult,
       "nomenclature_id")
      SET nomen_temp->nomen_qual[codeiter].descriptor = uar_srvgetstringptr(hcodedresult,"descriptor"
       )
     ENDIF
    ENDFOR
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = 1),
      reference_range_factor rrf,
      (dummyt d1  WITH seq = cnvtint(codecount)),
      alpha_responses ar
     PLAN (d)
      JOIN (rrf
      WHERE (rrf.task_assay_cd=temp->sl[xx].il[yy].task_assay_cd)
       AND rrf.active_ind=1)
      JOIN (d1)
      JOIN (ar
      WHERE (ar.nomenclature_id=nomen_temp->nomen_qual[d1.seq].nomenclature_id)
       AND ar.reference_range_factor_id=rrf.reference_range_factor_id)
     HEAD REPORT
      temp->sl[xx].ind = 1, nom_cnt = 0, qual_cnt = 0
     DETAIL
      IF (ar.multi_alpha_sort_order=0)
       nom_cnt = 0, qual_cnt += 1, temp->sl[xx].il[yy].cnt = qual_cnt,
       stat = alterlist(temp->sl[xx].il[yy].qual,qual_cnt), temp->sl[xx].il[yy].qual[qual_cnt].line
        = nomen_temp->nomen_qual[d1.seq].descriptor
      ELSE
       IF (ar.multi_alpha_sort_order=1)
        temp->sl[xx].il[yy].qual[qual_cnt].label = trim(nomen_temp->nomen_qual[d1.seq].descriptor)
       ELSE
        temp->sl[xx].il[yy].qual[qual_cnt].line = concat(temp->sl[xx].il[yy].qual[qual_cnt].line,"  ",
         nomen_temp->nomen_qual[d1.seq].descriptor)
       ENDIF
      ENDIF
     WITH nocounter, maxqual(rrf,1)
    ;end select
   ENDIF
   IF (qual_cnt=0)
    RETURN
   ENDIF
   IF ((((temp->sl[xx].il[yy].status_ind=modified_ind)) OR ((((temp->sl[xx].il[yy].status_ind=
   inerror_ind)) OR ((((temp->sl[xx].il[yy].status_ind=unauth_ind)) OR ((temp->sl[xx].il[yy].
   status_ind=inprogress_ind))) )) )) )
    SELECT INTO "nl"
     FROM (dummyt d1  WITH seq = value(qual_cnt))
     PLAN (d1)
     DETAIL
      IF ((temp->sl[xx].il[yy].status_ind=modified_ind))
       temp->sl[xx].il[yy].qual[d1.seq].line = concat(trim(temp->sl[xx].il[yy].qual[d1.seq].line),
        " (",captions->smodified,")")
      ENDIF
      IF ((temp->sl[xx].il[yy].status_ind=inerror_ind))
       temp->sl[xx].il[yy].qual[d1.seq].line = error_line
      ENDIF
      IF ((temp->sl[xx].il[yy].status_ind=unauth_ind))
       temp->sl[xx].il[yy].qual[d1.seq].line = concat(trim(temp->sl[xx].il[yy].qual[d1.seq].line),
        " (",captions->sunauth,")")
      ENDIF
      IF ((temp->sl[xx].il[yy].status_ind=inprogress_ind))
       temp->sl[xx].il[yy].qual[d1.seq].line = concat(trim(temp->sl[xx].il[yy].qual[d1.seq].line),
        " (",captions->sinprogress,")")
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   CALL echo("Exiting GET_MAGRID_RESULT")
 END ;Subroutine
 SUBROUTINE get_ragrid_result(xx,yy)
   CALL echo("Entering GET_RAGRID_RESULT")
   DECLARE childiter = i4 WITH protect
   DECLARE child_count = i4 WITH protect
   DECLARE result_status_cd = f8 WITH protect
   DECLARE hchildresult = i4 WITH protect
   DECLARE coded_cnt = i4 WITH protect
   DECLARE grid_collating_seq = i4 WITH protect, noconstant(0)
   IF (hinputresult=0)
    RETURN
   ENDIF
   SET child_count = uar_srvgetitemcount(hinputresult,"child_event_list")
   SET temp->sl[xx].il[yy].grid_cnt = child_count
   SET stat = alterlist(temp->sl[xx].il[yy].grid_qual,child_count)
   SET temp->sl[xx].il[yy].label = concat(trim(substring(1,40,uar_srvgetstringptr(hinputresult,
       "event_cd_disp")),3),":")
   CALL fill_grid_results(hinputresult,child_count)
   SET childiter = 0
   IF (child_count=0)
    RETURN
   ENDIF
   SELECT INTO "nl"
    grid_collating_seq = cnvtreal(grid_temp->qual[d1.seq].collating_seq)
    FROM (dummyt d1  WITH seq = value(child_count))
    PLAN (d1)
    ORDER BY grid_collating_seq
    HEAD grid_collating_seq
     childiter += 1, temp->sl[xx].il[yy].grid_qual[childiter].row_result = grid_temp->qual[d1.seq].
     result
    WITH nocounter
   ;end select
   FOR (childiter = 1 TO child_count)
     SET hchildresult = temp->sl[xx].il[yy].grid_qual[childiter].row_result
     SET coded_cnt = 0
     IF (hchildresult)
      SET temp->sl[xx].il[yy].grid_qual[childiter].ind = 1
      SET temp->sl[xx].il[yy].grid_qual[childiter].label = concat(trim(substring(1,40,
         uar_srvgetstringptr(hchildresult,"event_cd_disp")),3),":")
      SET coded_cnt = uar_srvgetitemcount(hchildresult,"coded_result_list")
      SET stat = alterlist(temp->sl[xx].il[yy].grid_qual[childiter].nom_qual,coded_cnt)
      SET temp->sl[xx].il[yy].grid_qual[childiter].note_ind = btest(uar_srvgetlong(hchildresult,
        "subtable_bit_map"),1)
      CALL get_general_coded_result(hchildresult,xx,yy)
      SET temp->sl[xx].il[yy].grid_qual[childiter].event_tag = trim(coded_tag)
      SET result_status_cd = uar_srvgetdouble(hchildresult,"result_status_cd")
      IF (result_status_cd=modified_cd)
       SET temp->sl[xx].il[yy].grid_qual[childiter].status_ind = 2
       SET temp->sl[xx].il[yy].grid_qual[childiter].event_tag = concat(trim(temp->sl[xx].il[yy].
         grid_qual[childiter].event_tag)," (",captions->smodified,")")
      ENDIF
      IF (result_status_cd=inerror_cd)
       SET temp->sl[xx].il[yy].grid_qual[childiter].event_tag = error_line
      ENDIF
      IF (result_status_cd=unauth_cd)
       SET temp->sl[xx].il[yy].grid_qual[childiter].event_tag = concat(trim(temp->sl[xx].il[yy].
         grid_qual[childiter].event_tag)," (",captions->sunauth,")")
      ENDIF
      IF (result_status_cd=inprogress_cd)
       SET temp->sl[xx].il[yy].grid_qual[childiter].event_tag = concat(trim(temp->sl[xx].il[yy].
         grid_qual[childiter].event_tag)," (",captions->sinprogress,")")
      ENDIF
      IF ((temp->sl[xx].il[yy].grid_qual[childiter].note_ind=1))
       CALL get_comments(hchildresult)
       SET temp->sl[xx].il[yy].grid_qual[childiter].note_text = comment_tag
      ENDIF
     ENDIF
   ENDFOR
   CALL echo("Exiting GET_RAGRID_RESULT")
 END ;Subroutine
 SUBROUTINE get_dsgrid_result(xx,yy)
   CALL echo("Entering GET_DSGRID_RESULT")
   DECLARE child_count = i4 WITH protect
   DECLARE hchildresult = i4 WITH protect
   DECLARE result_status_cd = f8 WITH protect
   DECLARE grid_collating_seq = i4 WITH protect, noconstant(0)
   DECLARE hgridresult = i4 WITH protect
   DECLARE childiter = i4 WITH protect
   DECLARE coded_cnt = i4 WITH protect
   IF (hinputresult=0)
    RETURN
   ENDIF
   SET temp->sl[xx].il[yy].label = uar_srvgetstringptr(hinputresult,"event_tag")
   SET child_count = uar_srvgetitemcount(hinputresult,"child_event_list")
   SET temp->sl[xx].il[yy].grid_cnt = child_count
   SET stat = alterlist(temp->sl[xx].il[yy].grid_qual,child_count)
   CALL fill_grid_results(hinputresult,child_count)
   SET childiter = 0
   IF (child_count=0)
    RETURN
   ENDIF
   SELECT INTO "nl"
    grid_collating_seq = cnvtreal(grid_temp->qual[d1.seq].collating_seq)
    FROM (dummyt d1  WITH seq = value(child_count))
    PLAN (d1)
    ORDER BY grid_collating_seq
    HEAD grid_collating_seq
     childiter += 1, temp->sl[xx].il[yy].grid_qual[childiter].row_result = grid_temp->qual[d1.seq].
     result
    WITH nocounter
   ;end select
   FOR (childiter = 1 TO child_count)
    SET hchildresult = temp->sl[xx].il[yy].grid_qual[childiter].row_result
    IF (hchildresult)
     SET temp->sl[xx].il[yy].grid_qual[childiter].ind = 0
     SET temp->sl[xx].il[yy].grid_qual[childiter].event_tag = " "
     SET temp->sl[xx].il[yy].grid_qual[childiter].status_ind = 0
     SET temp->sl[xx].il[yy].grid_qual[childiter].event_tag = uar_srvgetstringptr(hchildresult,
      "event_tag")
     IF ((temp->sl[xx].il[yy].grid_qual[childiter].event_tag > " "))
      SET temp->sl[xx].il[yy].grid_qual[childiter].ind = 1
     ENDIF
     SET temp->sl[xx].il[yy].grid_qual[childiter].label = concat(trim(uar_srvgetstringptr(
        hchildresult,"event_title_text")),":")
     SET temp->sl[xx].il[yy].grid_qual[childiter].date = uar_srvgetdateptr(hchildresult,
      "event_end_dt_tm")
     SET temp->sl[xx].il[yy].grid_qual[childiter].note_ind = btest(uar_srvgetlong(hchildresult,
       "subtable_bit_map"),1)
     SET coded_cnt = uar_srvgetitemcount(hchildresult,"coded_result_list")
     SET stat = alterlist(temp->sl[xx].il[yy].grid_qual[childiter].nom_qual,coded_cnt)
     SET result_status_cd = uar_srvgetdouble(hchildresult,"result_status_cd")
     CALL get_general_coded_result(hchildresult,xx,yy)
     SET temp->sl[xx].il[yy].grid_qual[childiter].event_tag = trim(coded_tag)
     IF (result_status_cd=modified_cd)
      SET temp->sl[xx].il[yy].grid_qual[childiter].status_ind = 2
      SET temp->sl[xx].il[yy].grid_qual[childiter].event_tag = concat(trim(temp->sl[xx].il[yy].
        grid_qual[childiter].event_tag)," (",captions->smodified,")")
     ENDIF
     IF (result_status_cd=inerror_cd)
      SET temp->sl[xx].il[yy].grid_qual[childiter].event_tag = error_line
     ENDIF
     IF (result_status_cd=unauth_cd)
      SET temp->sl[xx].il[yy].grid_qual[childiter].event_tag = concat(trim(temp->sl[xx].il[yy].
        grid_qual[childiter].event_tag)," (",captions->sunauth,")")
     ENDIF
     IF (result_status_cd=inprogress_cd)
      SET temp->sl[xx].il[yy].grid_qual[childiter].event_tag = concat(trim(temp->sl[xx].il[yy].
        grid_qual[childiter].event_tag)," (",captions->sinprogress,")")
     ENDIF
     CALL echo(build("event_tag;",temp->sl[xx].il[yy].grid_qual[childiter].event_tag))
     IF ((temp->sl[xx].il[yy].grid_qual[childiter].note_ind=1))
      CALL get_comments(hchildresult)
      SET temp->sl[xx].il[yy].grid_qual[childiter].note_text = comment_tag
     ENDIF
    ENDIF
   ENDFOR
   CALL echo("Exiting GET_DSGRID_RESULT")
 END ;Subroutine
 SUBROUTINE get_pwgrid_result(xx,yy,ultragridflag)
   CALL echo("Entering GET_PWGRID_RESULT")
   DECLARE child_count = i4 WITH protect
   DECLARE hchildresult = i4 WITH protect
   DECLARE cell_count = i4 WITH protect
   DECLARE result_status_cd = f8 WITH protect
   DECLARE row_collating_seq = i4 WITH protect, noconstant(0)
   DECLARE cell_collating_seq = i4 WITH protect
   DECLARE childiter = i4 WITH protect
   DECLARE hrowresult = i4 WITH protect
   DECLARE row_class_cd = f8 WITH protect
   IF (hinputresult=0)
    RETURN
   ENDIF
   SET temp->sl[xx].il[yy].description = uar_srvgetstringptr(hinputresult,"event_cd_disp")
   SET child_count = uar_srvgetitemcount(hinputresult,"child_event_list")
   SET temp->sl[xx].il[yy].grid_cnt = child_count
   SET stat = alterlist(temp->sl[xx].il[yy].grid_qual,child_count)
   CALL fill_grid_results(hinputresult,child_count)
   SET childiter = 0
   IF (child_count=0)
    RETURN
   ENDIF
   SELECT INTO "nl"
    row_collating_seq = cnvtreal(grid_temp->qual[d1.seq].collating_seq)
    FROM (dummyt d1  WITH seq = value(child_count))
    PLAN (d1)
    ORDER BY row_collating_seq
    DETAIL
     hrowresult = grid_temp->qual[d1.seq].result
     IF (hrowresult)
      row_class_cd = uar_srvgetdouble(hrowresult,"event_class_cd")
      IF (row_class_cd != placeholder_cd)
       childiter += 1, temp->sl[xx].il[yy].grid_qual[childiter].row_result = hrowresult
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   SET temp->sl[xx].il[yy].grid_cnt = childiter
   SET childiter = 0
   FOR (childiter = 1 TO child_count)
    SET hchildresult = temp->sl[xx].il[yy].grid_qual[childiter].row_result
    IF (hchildresult)
     SET temp->sl[xx].il[yy].grid_qual[childiter].event_id = uar_srvgetdouble(hchildresult,"event_id"
      )
     SET temp->sl[xx].il[yy].grid_qual[childiter].note_ind = btest(uar_srvgetlong(hchildresult,
       "subtable_bit_map"),1)
     SET temp->sl[xx].il[yy].grid_qual[childiter].date = uar_srvgetdateptr(hchildresult,
      "event_end_dt_tm")
     CALL get_pwgrid_child_result(xx,yy,childiter,hchildresult,ultragridflag)
     IF (temp->sl[xx].il[yy].grid_qual[childiter].note_ind)
      CALL get_comments(hchildresult)
      SET temp->sl[xx].il[yy].grid_qual[childiter].note_text = comment_tag
     ENDIF
    ENDIF
   ENDFOR
   CALL echo("Exiting GET_PWGRID_RESULT")
 END ;Subroutine
 SUBROUTINE get_pwgrid_child_result(xx,yy,grid_cnt,hrowresult,ultragridflag)
   DECLARE cell_count = i4 WITH protect
   DECLARE hcellresult = i4 WITH protect
   DECLARE result_class_cd = f8 WITH protect
   DECLARE result_status_cd = f8 WITH protect
   DECLARE celliter = i4 WITH protect
   SET cell_count = uar_srvgetitemcount(hrowresult,"child_event_list")
   SET temp->sl[xx].il[yy].grid_qual[grid_cnt].cnt = cell_count
   SET stat = alterlist(temp->sl[xx].il[yy].grid_qual[grid_cnt].qual,cell_count)
   IF (ultragridflag=1)
    SET temp->sl[xx].il[yy].grid_qual[grid_cnt].label = uar_srvgetstringptr(hrowresult,
     "event_cd_disp")
   ENDIF
   CALL fill_grid_results(hrowresult,cell_count)
   IF (cell_count=0)
    RETURN
   ENDIF
   SET celliter = 0
   SELECT INTO "nl"
    row_collating_seq = cnvtreal(grid_temp->qual[d1.seq].collating_seq), event_id = grid_temp->qual[
    d1.seq].event_id
    FROM (dummyt d1  WITH seq = value(cell_count))
    PLAN (d1)
    ORDER BY row_collating_seq, event_id
    HEAD row_collating_seq
     CALL echo(build("row_collating_seq",grid_temp->qual[d1.seq].collating_seq))
    HEAD event_id
     celliter += 1, temp->sl[xx].il[yy].grid_qual[grid_cnt].qual[celliter].cell_result = grid_temp->
     qual[d1.seq].result
    WITH nocounter
   ;end select
   FOR (celliter = 1 TO cell_count)
    SET hcellresult = temp->sl[xx].il[yy].grid_qual[grid_cnt].qual[celliter].cell_result
    IF (hcellresult)
     SET result_class_cd = uar_srvgetdouble(hcellresult,"event_class_cd")
     IF (result_class_cd=num_cd)
      CALL get_pwgrid_numeric_result(xx,yy,grid_cnt,celliter,hcellresult)
     ELSEIF (result_class_cd=date_cd)
      CALL get_pwgrid_date_result(xx,yy,grid_cnt,celliter,hcellresult)
     ELSE
      CALL get_pwgrid_default_result(xx,yy,grid_cnt,celliter,hcellresult)
     ENDIF
     SET temp->sl[xx].il[yy].grid_qual[grid_cnt].qual[celliter].collating_seq = cnvtreal(trim(
       uar_srvgetstringptr(hcellresult,"collating_seq")))
     SET temp->sl[xx].il[yy].grid_qual[grid_cnt].qual[celliter].label = trim(uar_srvgetstringptr(
       hcellresult,"event_cd_disp"))
     IF (ultragridflag=0)
      IF (celliter=1)
       SET temp->sl[xx].il[yy].grid_qual[grid_cnt].qual[celliter].label = trim(temp->sl[xx].il[yy].
        grid_qual[grid_cnt].qual[celliter].label)
      ELSE
       SET temp->sl[xx].il[yy].grid_qual[grid_cnt].qual[celliter].label = trim(temp->sl[xx].il[yy].
        grid_qual[grid_cnt].qual[celliter].label)
      ENDIF
     ENDIF
     SET temp->sl[xx].il[yy].grid_qual[grid_cnt].qual[celliter].note_ind = btest(uar_srvgetlong(
       hcellresult,"subtable_bit_map"),1)
     SET temp->sl[xx].il[yy].grid_qual[grid_cnt].qual[celliter].event_id = uar_srvgetdouble(
      hcellresult,"event_id")
     SET result_status_cd = uar_srvgetdouble(hcellresult,"result_status_cd")
     IF (result_status_cd=modified_cd)
      SET temp->sl[xx].il[yy].grid_qual[grid_cnt].qual[celliter].event_tag = concat(trim(temp->sl[xx]
        .il[yy].grid_qual[grid_cnt].qual[celliter].event_tag)," (",captions->smodified,")")
     ENDIF
     IF (result_status_cd=inprogress_cd)
      SET temp->sl[xx].il[yy].grid_qual[grid_cnt].qual[celliter].event_tag = concat(trim(temp->sl[xx]
        .il[yy].grid_qual[grid_cnt].qual[celliter].event_tag)," (",captions->sinprogress,")")
     ENDIF
     IF (result_status_cd=unauth_cd)
      SET temp->sl[xx].il[yy].grid_qual[grid_cnt].qual[celliter].event_tag = concat(trim(temp->sl[xx]
        .il[yy].grid_qual[grid_cnt].qual[celliter].event_tag)," (",captions->sunauth,")")
     ENDIF
     IF (result_status_cd=inerror_cd)
      SET temp->sl[xx].il[yy].grid_qual[grid_cnt].qual[celliter].status_ind = 1
      SET temp->sl[xx].il[yy].grid_qual[grid_cnt].qual[celliter].event_tag = error_line
     ENDIF
     IF (temp->sl[xx].il[yy].grid_qual[grid_cnt].qual[celliter].note_ind)
      CALL get_comments(hcellresult)
      SET temp->sl[xx].il[yy].grid_qual[grid_cnt].qual[celliter].note_text = comment_tag
     ENDIF
    ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE get_pwgrid_numeric_result(xx,yy,grid_cnt,celliter,hcellresult)
  SET temp->sl[xx].il[yy].grid_qual[grid_cnt].qual[celliter].event_tag = trim(format(
    uar_srvgetstringptr(hcellresult,"result_val"),"#########################;I;F"),3)
  IF (uar_srvgetdouble(hcellresult,"result_units_cd") > 0)
   SET temp->sl[xx].il[yy].grid_qual[grid_cnt].qual[celliter].event_tag = concat(trim(temp->sl[xx].
     il[yy].grid_qual[grid_cnt].qual[celliter].event_tag)," ",trim(uar_srvgetstringptr(hcellresult,
      "result_units_cd_disp")))
  ENDIF
 END ;Subroutine
 SUBROUTINE get_pwgrid_date_result(xx,yy,grid_cnt,celliter,hcellresult)
   CALL echo("Entering GET_PWGRID_RESULT_DATE")
   CALL get_general_date_result(hcellresult)
   SET temp->sl[xx].il[yy].grid_qual[grid_cnt].qual[celliter].event_tag = trim(date_tag)
 END ;Subroutine
 SUBROUTINE get_pwgrid_default_result(xx,yy,grid_cnt,celliter,hcellresult)
   CALL echo("Entering GET_PWGRID_RESULT_DEFAULT")
   CALL get_general_coded_result(hcellresult,xx,yy)
   CALL echo(build("coded_tag:",coded_tag,grid_cnt,celliter))
   SET temp->sl[xx].il[yy].grid_qual[grid_cnt].qual[celliter].event_tag = trim(coded_tag)
 END ;Subroutine
 SUBROUTINE get_tracking1_result(xx,yy)
   CALL echo("Entering GET_TRACKING_RESULT")
   DECLARE childiter = i4 WITH protect
   DECLARE hchildresult = i4 WITH protect
   DECLARE child_count = i4 WITH protect
   DECLARE result_status_cd = f8 WITH protect
   DECLARE event_class_cd = f8 WITH protect
   IF (hinputresult=0)
    RETURN
   ENDIF
   SET child_count = uar_srvgetitemcount(hinputresult,"child_event_list")
   SET temp->sl[xx].il[yy].cnt = child_count
   SET stat = alterlist(temp->sl[xx].il[yy].qual,child_count)
   FOR (childiter = 1 TO child_count)
     SET hchildresult = uar_srvgetitem(hinputresult,"child_event_list",(childiter - 1))
     IF (hchildresult)
      SET temp->sl[xx].il[yy].qual[childiter].label = uar_srvgetstringptr(hchildresult,
       "event_cd_disp")
      SET temp->sl[xx].il[yy].qual[childiter].line = uar_srvgetstringptr(hchildresult,"result_val")
     ENDIF
     SET event_class_cd = uar_srvgetdouble(hchildresult,"event_class_cd")
     IF (event_class_cd=date_cd)
      CALL get_general_date_result(hchildresult)
      SET temp->sl[xx].il[yy].qual[childiter].line = date_tag
     ENDIF
     SET result_status_cd = uar_srvgetdouble(hchildresult,"result_status_cd")
     IF (result_status_cd=modified_cd)
      SET temp->sl[xx].il[yy].status_ind = 2
      SET temp->sl[xx].il[yy].qual[childiter].line = concat(trim(temp->sl[xx].il[yy].qual[childiter].
        line)," (",captions->smodified,")")
     ENDIF
     IF (result_status_cd=inerror_cd)
      SET temp->sl[xx].il[yy].status_ind = 1
      SET temp->sl[xx].il[yy].qual[childiter].line = error_line
     ENDIF
     IF (result_status_cd=unauth_cd)
      SET temp->sl[xx].il[yy].status_ind = unauth_ind
      SET temp->sl[xx].il[yy].qual[childiter].line = concat(trim(temp->sl[xx].il[yy].qual[childiter].
        line)," (",captions->sunauth,")")
     ENDIF
     IF (result_status_cd=inprogress_cd)
      SET temp->sl[xx].il[yy].status_ind = inprogress_ind
      SET temp->sl[xx].il[yy].qual[childiter].line = concat(trim(temp->sl[xx].il[yy].qual[childiter].
        line)," (",captions->sinprogress,")")
     ENDIF
   ENDFOR
   CALL echo("Exiting GetTRACKING_RESULT")
 END ;Subroutine
 SUBROUTINE get_tracking2_result(xx,yy)
   CALL echo("Entering GET_TRACKING2_RESULT")
   DECLARE childiter = i4 WITH protect
   DECLARE hchildresult = i4 WITH protect
   DECLARE child_count = i4 WITH protect
   DECLARE result_status_cd = f8 WITH protect
   DECLARE event_class_cd = f8 WITH protect
   SET child_count = uar_srvgetitemcount(hinputresult,"child_event_list")
   SET temp->sl[xx].il[yy].cnt = child_count
   SET stat = alterlist(temp->sl[xx].il[yy].qual,child_count)
   FOR (childiter = 1 TO child_count)
    SET hchildresult = uar_srvgetitem(hinputresult,"child_event_list",(childiter - 1))
    IF (hchildresult)
     SET temp->sl[xx].il[yy].qual[childiter].label = uar_srvgetstringptr(hchildresult,"event_cd_disp"
      )
     SET temp->sl[xx].il[yy].qual[childiter].line = uar_srvgetstringptr(hchildresult,"result_val")
     SET result_status_cd = uar_srvgetdouble(hchildresult,"result_status_cd")
     SET event_class_cd = uar_srvgetdouble(hchildresult,"event_class_cd")
     IF (event_class_cd=date_cd)
      CALL get_general_date_result(hchildresult)
      SET temp->sl[xx].il[yy].qual[childiter].line = date_tag
     ENDIF
     IF (result_status_cd=modified_cd)
      SET temp->sl[xx].il[yy].status_ind = modified_ind
      SET temp->sl[xx].il[yy].qual[childiter].line = concat(trim(temp->sl[xx].il[yy].qual[childiter].
        line)," (",captions->smodified,")")
     ENDIF
     IF (result_status_cd=inerror_cd)
      SET temp->sl[xx].il[yy].status_ind = inerror_ind
      SET temp->sl[xx].il[yy].qual[childiter].line = error_line
     ENDIF
     IF (result_status_cd=unauth_cd)
      SET temp->sl[xx].il[yy].status_ind = unauth_ind
      SET temp->sl[xx].il[yy].qual[childiter].line = concat(trim(temp->sl[xx].il[yy].qual[childiter].
        line)," (",captions->sunauth,")")
     ENDIF
     IF (result_status_cd=inprogress_cd)
      SET temp->sl[xx].il[yy].status_ind = inprogress_ind
      SET temp->sl[xx].il[yy].qual[childiter].line = concat(trim(temp->sl[xx].il[yy].qual[childiter].
        line)," (",captions->sinprogress,")")
     ENDIF
    ENDIF
   ENDFOR
   CALL echo("exiting GET_TRACKING2_RESULT")
 END ;Subroutine
 SUBROUTINE get_date_result(xx,yy)
   CALL echo("Entering GET_DATE_RESULT")
   CALL get_general_date_result(hinputresult)
   SET temp->sl[xx].il[yy].event_tag = trim(date_tag)
   IF ((temp->sl[xx].il[yy].status_ind=modified_ind))
    SET temp->sl[xx].il[yy].event_tag = concat(trim(temp->sl[xx].il[yy].event_tag)," (",captions->
     smodified,")")
   ENDIF
   IF ((temp->sl[xx].il[yy].status_ind=inerror_ind))
    SET temp->sl[xx].il[yy].event_tag = error_line
    SET temp->sl[xx].il[yy].status_ind = 1
   ENDIF
   IF ((temp->sl[xx].il[yy].status_ind=unauth_ind))
    SET temp->sl[xx].il[yy].event_tag = concat(trim(temp->sl[xx].il[yy].event_tag)," (",captions->
     sunauth,")")
   ENDIF
   IF ((temp->sl[xx].il[yy].status_ind=inprogress_ind))
    SET temp->sl[xx].il[yy].event_tag = concat(trim(temp->sl[xx].il[yy].event_tag)," (",captions->
     sinprogress,")")
   ENDIF
   CALL echo("exiting GET_DATE_RESULT")
 END ;Subroutine
 SUBROUTINE get_general_date_result(hresultin)
   CALL echo("entering GET_GENERAL_DATE_RESULT")
   DECLARE hdateresult = i4 WITH protect
   DECLARE datecount = i4 WITH protect
   DECLARE date_type = i2 WITH protect
   DECLARE result_tz_ind = i2 WITH protect
   DECLARE result_tz = i2 WITH protect
   SET date_tag = " "
   SET event_id = uar_srvgetdouble(hresultin,"event_id")
   SET datecount = uar_srvgetitemcount(hresultin,"date_result")
   IF (datecount >= 0)
    SET hdateresult = uar_srvgetitem(hresultin,"date_result",0)
    IF (hdateresult)
     SET date_type = uar_srvgetshort(hdateresult,"date_type_flag")
     SET stat = uar_srvgetdate2(hdateresult,"result_dt_tm",date_temp)
     IF (time_zone_ind=1
      AND curutc=1)
      SET result_tz_ind = uar_srvgetshort(hdateresult,"result_tz_ind")
      SET result_tz = uar_srvgetlong(hdateresult,"result_tz")
     ENDIF
     IF (date_type=0)
      IF (result_tz_ind=1
       AND curutc=1)
       CALL formatdatetime(result_tz,"ZZZZ")
       SET date_tag = date_utc_str
      ELSE
       IF (time_zone_ind=1
        AND curutc=1)
        SET date_tag = concat(trim(datetimezoneformat(date_temp->dt1,result_tz,"@SHORTDATE"))," ",
         trim(datetimezoneformat(date_temp->dt1,result_tz,"@TIMENOSECONDS")))
       ELSE
        SET date_tag = concat(trim(format(date_temp->dt1,"@SHORTDATE"))," ",trim(format(date_temp->
           dt1,"@TIMENOSECONDS")))
       ENDIF
      ENDIF
     ENDIF
     IF (date_type=1)
      IF (time_zone_ind=1
       AND curutc=1)
       SET date_tag = concat(trim(datetimezoneformat(date_temp->dt1,result_tz,"@SHORTDATE")))
      ELSE
       SET date_tag = concat(trim(format(date_temp->dt1,"@SHORTDATE")))
      ENDIF
     ENDIF
     IF (date_type=2)
      IF (time_zone_ind=1
       AND curutc=1)
       SET date_tag = concat(trim(datetimezoneformat(date_temp->dt1,result_tz,"@TIMENOSECONDS")))
      ELSE
       SET date_tag = concat(trim(format(date_temp->dt1,"@TIMENOSECONDS")))
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   CALL echo("exiting GET_GENERAL_DATE_RESULT")
 END ;Subroutine
 SUBROUTINE (get_general_coded_result(hresultin=i4,xx=i4,yy=i4) =null)
   DECLARE hstringresult = i4 WITH protect
   DECLARE hcodedresult = i4 WITH protect
   DECLARE stringcount = i4 WITH protect
   DECLARE codecount = i4 WITH protect
   DECLARE codeset = i4 WITH protect
   DECLARE string_result = vc WITH protect
   DECLARE coded_result = vc WITH protect
   DECLARE result_val = vc WITH protect
   DECLARE input_nomen_flag = i2 WITH protect
   DECLARE val_indx = i4 WITH protect
   DECLARE val_sz = i4 WITH protect
   DECLARE nomen_string_flag = i2 WITH protect
   SET input_nomen_flag = - (1)
   SET nomen_string_flag = - (1)
   SET val_indx = 0
   SET val_sz = size(temp->sl[xx].il[yy].val_qual,5)
   IF (val_sz > 0)
    FOR (val_indx = 1 TO val_sz)
      IF (trim(temp->sl[xx].il[yy].val_qual[val_indx].pvc_name)="nomen_field")
       SET input_nomen_flag = cnvtint(trim(temp->sl[xx].il[yy].val_qual[val_indx].pvc_value))
       SET val_indx = val_sz
      ENDIF
    ENDFOR
   ENDIF
   IF ((((temp->sl[xx].il[yy].input_type=4)) OR ((temp->sl[xx].il[yy].input_type=14))) )
    IF ((input_nomen_flag=- (1)))
     SET input_nomen_flag = 0
    ENDIF
   ENDIF
   SET coded_tag = " "
   SET coded_result = fillstring(32000," ")
   SET result_val = fillstring(32000," ")
   SET stringcount = uar_srvgetitemcount(hresultin,"string_result")
   IF (stringcount >= 0)
    SET hstringresult = uar_srvgetitem(hresultin,"string_result",0)
    IF (hstringresult)
     SET string_result = uar_srvgetstringptr(hstringresult,"string_result_text")
    ENDIF
   ENDIF
   SET codecount = uar_srvgetitemcount(hresultin,"coded_result_list")
   IF ((input_nomen_flag=- (1)))
    SET nomen_string_flag = uar_srvgetshort(hresultin,"nomen_string_flag")
   ENDIF
   FOR (codeiter = 1 TO codecount)
     SET hcodedresult = uar_srvgetitem(hresultin,"coded_result_list",(codeiter - 1))
     SET codeset = uar_srvgetlong(hcodedresult,"result_set")
     IF (codeset=0)
      IF ((input_nomen_flag=- (1)))
       CASE (nomen_string_flag)
        OF 0:
         SET result_val = uar_srvgetstringptr(hcodedresult,"short_string")
        OF 1:
         SET result_val = uar_srvgetstringptr(hcodedresult,"mnemonic")
        OF 2:
         SET result_val = uar_srvgetstringptr(hcodedresult,"descriptor")
        ELSE
         SET result_val = uar_srvgetstringptr(hcodedresult,"descriptor")
       ENDCASE
      ELSE
       CASE (input_nomen_flag)
        OF 0:
         SET result_val = uar_srvgetstringptr(hcodedresult,"mnemonic")
        OF 1:
         SET result_val = uar_srvgetstringptr(hcodedresult,"short_string")
        OF 2:
         SET result_val = uar_srvgetstringptr(hcodedresult,"descriptor")
        ELSE
         SET result_val = uar_srvgetstringptr(hcodedresult,"descriptor")
       ENDCASE
      ENDIF
     ELSE
      SET result_val = uar_srvgetstringptr(hcodedresult,"result_cd_disp")
     ENDIF
     IF (codeiter=1)
      SET coded_result = result_val
     ELSE
      SET coded_result = concat(trim(coded_result),", ",result_val)
     ENDIF
   ENDFOR
   IF (coded_result > "  "
    AND string_result > " ")
    SET coded_tag = concat(trim(coded_result),", ",trim(string_result))
   ELSEIF (coded_result > " ")
    SET coded_tag = concat(trim(coded_result))
   ELSEIF (string_result > "  ")
    SET coded_tag = concat(trim(string_result))
   ENDIF
 END ;Subroutine
 SUBROUTINE get_comments(hnoteresults)
   CALL echo("entering Comments results")
   DECLARE note_cnt = i4 WITH protect
   DECLARE hnoteresult = i4 WITH protect
   DECLARE blob_out = vc WITH protect
   DECLARE blob_out2 = c32000 WITH protect
   DECLARE format_cd = f8 WITH protect
   DECLARE return_buffer_len = i4 WITH protect
   DECLARE buffer_len = i4 WITH protect
   DECLARE status = i4 WITH protect
   DECLARE blob_size = i4 WITH protect
   SET comment_tag = " "
   SET buffer_len = 32000
   SET note_cnt = uar_srvgetitemcount(hnoteresults,"event_note_list")
   FOR (noteiter = 1 TO note_cnt)
     SET hnoteresult = uar_srvgetitem(hnoteresults,"event_note_list",(noteiter - 1))
     SET blob_out2 = " "
     IF (hnoteresult)
      SET blob_size = uar_srvgetasissize(hnoteresult,"long_blob")
      IF (blob_size)
       SET blob_out = trim(uar_srvgetasisptr(hnoteresult,"long_blob"))
       SET blob_out = substring(1,blob_size,trim(blob_out))
       SET status = uar_rtf(blob_out,textlen(blob_out),blob_out2,buffer_len,return_buffer_len,
        0)
      ENDIF
     ENDIF
     IF (noteiter=1)
      SET comment_tag = concat(trim(blob_out2))
     ELSE
      SET comment_tag = concat(trim(comment_tag),",",trim(blob_out2))
     ENDIF
   ENDFOR
   CALL echo("exiting comments Results")
 END ;Subroutine
 SUBROUTINE fill_grid_results(hinputresult,child_count)
   CALL echo("Entering Fill_Grid_results")
   DECLARE hgridresult = i4 WITH protect
   DECLARE childiter = i4 WITH protect
   SET stat = alterlist(grid_temp->qual,child_count)
   FOR (childiter = 1 TO child_count)
    SET hgridresult = uar_srvgetitem(hinputresult,"child_event_list",(childiter - 1))
    IF (hgridresult)
     SET grid_temp->qual[childiter].result = hgridresult
     SET grid_temp->qual[childiter].collating_seq = uar_srvgetstringptr(hgridresult,"collating_seq")
     SET grid_temp->qual[childiter].event_id = uar_srvgetdouble(hgridresult,"event_id")
    ELSE
     SET grid_temp->qual[childiter].result = 0
     SET grid_temp->qual[childiter].collating_seq = 0
     SET grid_temp->qual[childiter].event_id = 0
    ENDIF
   ENDFOR
   CALL echo("Exiting Fill_Grid_results")
 END ;Subroutine
 SUBROUTINE (checkcolumnexists(table_name=vc,column_name=vc) =i2)
  SET time_zone_ind = 0
  SELECT INTO "nl:"
   FROM user_tab_columns utc
   WHERE utc.table_name=table_name
    AND utc.column_name=column_name
   DETAIL
    time_zone_ind = 1
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE (formatdatetime(time_zone=i4,tz_format=vc) =vc)
  IF (((time_zone_ind=0) OR (curutc=0)) )
   SET date_utc_str = concat(format(date_temp->dt1,"@SHORTDATE;;Q")," ",format(date_temp->dt1,
     "@TIMENOSECONDS;;S"))
  ELSE
   DECLARE offset = i4 WITH private, noconstant(0)
   DECLARE daylight = i4 WITH private, noconstant(0)
   DECLARE mode = i2 WITH private, constant(7)
   IF (tz_format > " ")
    SET date_utc_str = concat(trim(datetimezoneformat(date_temp->dt1,time_zone,"@SHORTDATE"))," ",
     trim(datetimezoneformat(date_temp->dt1,time_zone,"@TIMENOSECONDS"))," ",trim(datetimezoneformat(
       date_temp->dt1,time_zone,tz_format)))
   ELSE
    SET date_utc_str = concat(trim(datetimezoneformat(date_temp->dt1,time_zone,"@SHORTDATE"))," ",
     trim(datetimezoneformat(date_temp->dt1,time_zone,"@TIMENOSECONDS")))
   ENDIF
  ENDIF
  RETURN(date_utc_str)
 END ;Subroutine
 SUBROUTINE (formatdateonly(time_zone=i4,tz_format=vc) =vc)
  IF (((time_zone_ind=0) OR (curutc=0)) )
   SET date_utc_str = format(date_temp->dt1,"@SHORTDATE;;Q")
  ELSE
   DECLARE offset = i4 WITH private, noconstant(0)
   DECLARE daylight = i4 WITH private, noconstant(0)
   DECLARE mode = i2 WITH private, constant(7)
   SET date_utc_str = trim(datetimezoneformat(date_temp->dt1,time_zone,"@SHORTDATE"))
  ENDIF
  RETURN(date_utc_str)
 END ;Subroutine
 SUBROUTINE (formatfuzzydate(time_zone=i4,tz_format=vc,dt_precision=i2,dt_qualifier=i2) =vc)
   DECLARE qualifier_str = vc WITH private
   DECLARE fuzzy_date_str = vc WITH private, noconstant(" ")
   DECLARE fuzzy_month = i4 WITH private, noconstant(0)
   DECLARE fuzzy_year = i4 WITH private, noconstant(0)
   IF (dt_precision=0)
    IF (dt_qualifier=dateonly_qualifier)
     CALL formatdateonly(time_zone,tz_format)
    ELSE
     CALL formatdatetime(time_zone,tz_format)
    ENDIF
   ELSE
    IF (dt_qualifier=about_qualifier)
     SET qualifier_str = about_qualifier_str
    ELSEIF (dt_qualifier=before_qualifier)
     SET qualifier_str = before_qualifier_str
    ELSEIF (dt_qualifier=after_qualifier)
     SET qualifier_str = after_qualifier_str
    ENDIF
    SET fuzzy_month = month(cnvtdatetime(date_temp->dt1))
    SET fuzzy_year = year(cnvtdatetime(date_temp->dt1))
    IF (dt_precision=month_precision)
     SET fuzzy_date_str = concat(build(fuzzy_month),"/",build(fuzzy_year))
    ELSEIF (dt_precision=year_precision)
     SET fuzzy_date_str = build(fuzzy_year)
    ENDIF
    IF (dt_qualifier > 0
     AND dt_qualifier < dateonly_qualifier)
     SET date_utc_str = concat(qualifier_str," ",fuzzy_date_str)
    ELSE
     SET date_utc_str = fuzzy_date_str
    ENDIF
   ENDIF
   RETURN(date_utc_str)
 END ;Subroutine
 SUBROUTINE (buildupdatestr(updateindex=i4) =null)
   SET date_temp->dt1 = cnvtdatetime(temp->updated_prsnl[updateindex].update_dt_tm)
   CALL formatdatetime(temp->updated_prsnl[updateindex].activity_tz,"ZZZ")
   SET temp->updated_prsnl[updateindex].update_dt_str = concat(trim(date_utc_str)," ",trim(captions->
     sby)," ",trim(temp->updated_prsnl[updateindex].prsnl_ft))
   IF ((temp->updated_prsnl[updateindex].proxy_prsnl_id != 0.0))
    SET temp->updated_prsnl[updateindex].update_dt_str = concat(trim(temp->updated_prsnl[updateindex]
      .update_dt_str)," ",captions->sproxyby," ",temp->updated_prsnl[updateindex].proxy_prsnl_ft)
   ENDIF
 END ;Subroutine
 SUBROUTINE (get_medprofile_result(xx=i4,yy=i4) =null)
   CALL echo(build("entering medprofile results"))
   DECLARE dwk_frms_med_cnt = i4 WITH protect, noconstant(0)
   DECLARE locateidx = i4 WITH protect, noconstant(0)
   DECLARE medidx = i4 WITH protect, noconstant(0)
   SET temp->sl[xx].il[yy].med_profile_restricted_ind = 0
   DECLARE order_ordered_status_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,
     "ORDERED"))
   DECLARE order_inprocess_status_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,
     "INPROCESS"))
   DECLARE order_pending_status_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,
     "PENDING"))
   DECLARE order_medstud_status_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,
     "MEDSTUDENT"))
   DECLARE order_studord_status_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,
     "STUDENTORD"))
   DECLARE order_pendrev_status_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,
     "PENDING REV"))
   SELECT INTO "nl:"
    FROM orders o
    WHERE o.person_id=person_id
     AND o.active_ind=1
     AND o.orig_ord_as_flag=2
     AND ((o.order_status_cd+ 0) IN (order_ordered_status_cd, order_inprocess_status_cd,
    order_pending_status_cd, order_medstud_status_cd, order_studord_status_cd,
    order_pendrev_status_cd))
    ORDER BY o.order_id
    DETAIL
     IF ((org_sec_map->restrict_ind=0))
      dwk_frms_med_cnt += 1, temp->sl[xx].ind = 1
      IF (size(temp->sl[xx].il[yy].med_profile_qual,5) < dwk_frms_med_cnt)
       stat = alterlist(temp->sl[xx].il[yy].med_profile_qual,(dwk_frms_med_cnt+ 5))
      ENDIF
      temp->sl[xx].il[yy].med_profile_qual[dwk_frms_med_cnt].hna_order_mnemonic = trim(o
       .hna_order_mnemonic), temp->sl[xx].il[yy].med_profile_qual[dwk_frms_med_cnt].
      order_detail_display_line = trim(o.clinical_display_line)
     ELSE
      locateidx = locateval(medidx,1,size(person_org_sec_map->encntrs,5),o.encntr_id,
       person_org_sec_map->encntrs[medidx].encntr_id)
      IF (locateidx > 0)
       dwk_frms_med_cnt += 1, temp->sl[xx].ind = 1
       IF (size(temp->sl[xx].il[yy].med_profile_qual,5) < dwk_frms_med_cnt)
        stat = alterlist(temp->sl[xx].il[yy].med_profile_qual,(dwk_frms_med_cnt+ 5))
       ENDIF
       temp->sl[xx].il[yy].med_profile_qual[dwk_frms_med_cnt].hna_order_mnemonic = trim(o
        .hna_order_mnemonic), temp->sl[xx].il[yy].med_profile_qual[dwk_frms_med_cnt].
       order_detail_display_line = trim(o.clinical_display_line)
      ELSE
       temp->sl[xx].il[yy].med_profile_restricted_ind = 1
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   SET stat = alterlist(temp->sl[xx].il[yy].med_profile_qual,dwk_frms_med_cnt)
 END ;Subroutine
 SUBROUTINE (get_procedure_history(xx=i4,yy=i4) =null)
   CALL echo(build("Entering GET_PROCEDURE_HISTORY"))
   DECLARE facility_cd = i4 WITH protect, constant(uar_get_code_by("MEANING",222,"FACILITIY"))
   DECLARE proc_num = i4 WITH protect, noconstant(0)
   DECLARE locateidx = i4 WITH protect, noconstant(0)
   DECLARE procidx = i4 WITH protect, noconstant(0)
   DECLARE indx = i4 WITH protect, noconstant(0)
   SET temp->sl[xx].il[yy].proc_list_restricted_ind = 0
   RECORD tmp_procs(
     1 qual[*]
       2 proc_id = f8
   )
   CALL getauthcontributorsystems(null)
   SELECT INTO "nl:"
    FROM encounter e,
     procedure pcd,
     nomenclature n,
     proc_prsnl_reltn ppr,
     prsnl prn
    PLAN (e
     WHERE (e.person_id=temp->person_id))
     JOIN (pcd
     WHERE pcd.encntr_id=e.encntr_id
      AND pcd.active_ind=1
      AND expand(indx,1,con_sys->system_cnt,pcd.contributor_system_cd,con_sys->systems[indx].
      system_code)
      AND pcd.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND ((pcd.end_effective_dt_tm >= cnvtdatetime(sysdate)) OR (pcd.end_effective_dt_tm=null))
      AND pcd.suppress_narrative_ind != 1)
     JOIN (n
     WHERE n.nomenclature_id=pcd.nomenclature_id)
     JOIN (ppr
     WHERE (ppr.procedure_id= Outerjoin(pcd.procedure_id))
      AND (ppr.active_ind= Outerjoin(1))
      AND (ppr.proc_prsnl_reltn_cd= Outerjoin(0.0)) )
     JOIN (prn
     WHERE (prn.person_id= Outerjoin(ppr.prsnl_person_id)) )
    ORDER BY pcd.procedure_id, pcd.nomenclature_id, ppr.beg_effective_dt_tm DESC
    HEAD pcd.procedure_id
     locateidx = locateval(procidx,1,size(person_org_sec_map->encntrs,5),pcd.encntr_id,
      person_org_sec_map->encntrs[procidx].encntr_id)
     IF ((((org_sec_map->restrict_ind=0)) OR (locateidx > 0)) )
      proc_num += 1, temp->sl[xx].ind = 1
      IF (size(temp->sl[xx].il[yy].proc_list,5) < proc_num)
       stat = alterlist(temp->sl[xx].il[yy].proc_list,(proc_num+ 5)), stat = alterlist(tmp_procs->
        qual,(proc_num+ 5))
      ENDIF
      tmp_procs->qual[proc_num].proc_id = pcd.procedure_id, temp->sl[xx].il[yy].proc_list[proc_num].
      proc_id = pcd.procedure_id
      IF (pcd.proc_ftdesc > " ")
       temp->sl[xx].il[yy].proc_list[proc_num].proc_desc = trim(pcd.proc_ftdesc)
      ELSEIF (n.source_string > " ")
       temp->sl[xx].il[yy].proc_list[proc_num].proc_desc = trim(n.source_string)
      ENDIF
      IF (trim(ppr.proc_ft_prsnl) > "")
       temp->sl[xx].il[yy].proc_list[proc_num].proc_prsnl_name = trim(ppr.proc_ft_prsnl)
      ELSE
       temp->sl[xx].il[yy].proc_list[proc_num].proc_prsnl_name = prn.name_full_formatted
      ENDIF
      temp->sl[xx].il[yy].proc_list[proc_num].voca_cd_meaning = uar_get_code_meaning(n
       .source_vocabulary_cd), temp->sl[xx].il[yy].proc_list[proc_num].source_identifier = n
      .source_identifier
      IF (year(pcd.proc_dt_tm) > 0)
       temp->sl[xx].il[yy].proc_list[proc_num].proc_year = year(pcd.proc_dt_tm), temp->sl[xx].il[yy].
       proc_list[proc_num].age_at_proc = trim(cnvtage(birth_temp->birth_temp_dt,pcd.proc_dt_tm,0))
      ENDIF
      IF (pcd.proc_loc_cd > 0.0)
       temp->sl[xx].il[yy].proc_list[proc_num].proc_location = uar_get_code_display(pcd.proc_loc_cd)
      ELSEIF (trim(pcd.proc_ft_loc) > "")
       temp->sl[xx].il[yy].proc_list[proc_num].proc_location = pcd.proc_ft_loc
      ENDIF
     ELSE
      temp->sl[xx].il[yy].proc_list_restricted_ind = 1
     ENDIF
    FOOT REPORT
     stat = alterlist(temp->sl[xx].il[yy].proc_list,proc_num), stat = alterlist(tmp_procs->qual,
      proc_num)
    WITH nocounter
   ;end select
   IF (proc_num=0)
    RETURN
   ENDIF
   DECLARE cmnt_num = i4 WITH protect, noconstant(0)
   DECLARE proc_idx = i4 WITH protect, noconstant(0)
   DECLARE locate_idx = i4 WITH protect, noconstant(0)
   DECLARE expand_index = i4 WITH protect, noconstant(0)
   DECLARE dwk_frms_nstart = i4 WITH protect, noconstant(1)
   DECLARE dwk_frms_cur_list_size = i4 WITH protect, constant(proc_num)
   DECLARE dwk_frms_batch_size = i4 WITH protect, noconstant(10)
   DECLARE dwk_frms_loop_cnt = i4 WITH protect, noconstant(ceil((cnvtreal(dwk_frms_cur_list_size)/
     dwk_frms_batch_size)))
   DECLARE dwk_frms_new_list_size = i4 WITH protect, constant((dwk_frms_loop_cnt *
    dwk_frms_batch_size))
   SET stat = alterlist(tmp_procs->qual,dwk_frms_new_list_size)
   FOR (x_cnt = (dwk_frms_cur_list_size+ 1) TO dwk_frms_new_list_size)
     SET tmp_procs->qual[x_cnt].proc_id = tmp_procs->qual[proc_num].proc_id
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(dwk_frms_loop_cnt)),
     long_text lt,
     prsnl p
    PLAN (d
     WHERE initarray(dwk_frms_nstart,evaluate(d.seq,1,1,(dwk_frms_nstart+ dwk_frms_batch_size))))
     JOIN (lt
     WHERE expand(expand_index,dwk_frms_nstart,(dwk_frms_nstart+ (dwk_frms_batch_size - 1)),lt
      .parent_entity_id,tmp_procs->qual[expand_index].proc_id)
      AND lt.parent_entity_name="PROCEDURE"
      AND lt.active_ind=1)
     JOIN (p
     WHERE p.person_id=lt.updt_id
      AND p.active_ind=1
      AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND p.end_effective_dt_tm > cnvtdatetime(sysdate))
    ORDER BY lt.parent_entity_id, cnvtdatetime(lt.updt_dt_tm) DESC
    HEAD lt.parent_entity_id
     cmnt_num = 0, proc_idx = 0, proc_idx = locateval(locate_idx,1,dwk_frms_cur_list_size,lt
      .parent_entity_id,temp->sl[xx].il[yy].proc_list[locate_idx].proc_id)
    DETAIL
     IF (proc_idx > 0)
      cmnt_num += 1
      IF (mod(cmnt_num,10)=1)
       stat = alterlist(temp->sl[xx].il[yy].proc_list[proc_idx].comments,(cmnt_num+ 9))
      ENDIF
      temp->sl[xx].il[yy].proc_list[proc_idx].comments[cmnt_num].comment = lt.long_text, temp->sl[xx]
      .il[yy].proc_list[proc_idx].comments[cmnt_num].comment_prsnl_name = p.name_full_formatted,
      date_temp->dt1 = cnvtdatetime(lt.updt_dt_tm),
      temp->sl[xx].il[yy].proc_list[proc_idx].comments[cmnt_num].comment_dt_tm_str = trim(
       formatdatetime(0," "))
     ENDIF
    FOOT  lt.parent_entity_id
     IF (proc_idx > 0)
      stat = alterlist(temp->sl[xx].il[yy].proc_list[proc_idx].comments,cmnt_num)
     ENDIF
    WITH nocounter
   ;end select
   CALL echo(build("Leaving GET_PROCEDURE_HISTORY"))
 END ;Subroutine
 SUBROUTINE (get_past_med_history(xx=i4,yy=i4) =null)
   CALL echo(build("Entering GET_PAST_MED_HISTORY"))
   DECLARE past_prob_cnt = i4 WITH protect, noconstant(0)
   DECLARE comment_cnt = i4 WITH protect, noconstant(0)
   DECLARE tmp_age = i4 WITH protect, noconstant(0)
   DECLARE locateidx = i4 WITH protect, noconstant(0)
   DECLARE problemidx = i4 WITH protect, noconstant(0)
   SET temp->sl[xx].il[yy].past_prob_list_restricted_ind = 0
   SELECT INTO "nl:"
    pr.person_id, pr.nomenclature_id
    FROM problem pr,
     nomenclature n,
     problem_comment pc,
     prsnl prp
    PLAN (pr
     WHERE (pr.person_id=temp->person_id)
      AND pr.active_ind=1
      AND pr.show_in_pm_history_ind=1
      AND pr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND ((pr.end_effective_dt_tm >= cnvtdatetime(sysdate)) OR (pr.end_effective_dt_tm=null)) )
     JOIN (n
     WHERE n.nomenclature_id=pr.nomenclature_id)
     JOIN (pc
     WHERE (pc.problem_id= Outerjoin(pr.problem_id))
      AND (pc.active_ind= Outerjoin(1)) )
     JOIN (prp
     WHERE (prp.person_id= Outerjoin(pc.comment_prsnl_id)) )
    ORDER BY pr.problem_id, pc.problem_comment_id
    HEAD pr.problem_id
     locateidx = locateval(problemidx,1,size(user_sec_organizations->qual,5),pr.organization_id,
      user_sec_organizations->qual[problemidx].organization_id)
     IF ((((org_sec_map->restrict_ind=0)) OR (((orgsecoverrideind != 0) OR (locateidx > 0)) )) )
      comment_cnt = 0, past_prob_cnt += 1, temp->sl[xx].ind = 1
      IF (size(temp->sl[xx].il[yy].past_prob_list,5) < past_prob_cnt)
       stat = alterlist(temp->sl[xx].il[yy].past_prob_list,(past_prob_cnt+ 5))
      ENDIF
      IF (trim(pr.annotated_display) > "")
       temp->sl[xx].il[yy].past_prob_list[past_prob_cnt].prob_desc = trim(pr.annotated_display)
      ELSEIF (trim(pr.problem_ftdesc) > "")
       temp->sl[xx].il[yy].past_prob_list[past_prob_cnt].prob_desc = trim(pr.problem_ftdesc)
      ELSEIF (trim(n.source_string) > "")
       temp->sl[xx].il[yy].past_prob_list[past_prob_cnt].prob_desc = trim(n.source_string)
      ENDIF
      IF (trim(n.source_string) > "")
       temp->sl[xx].il[yy].past_prob_list[past_prob_cnt].voca_cd_meaning = uar_get_code_meaning(n
        .source_vocabulary_cd), temp->sl[xx].il[yy].past_prob_list[past_prob_cnt].source_identifier
        = n.source_identifier
      ENDIF
      IF (year(pr.onset_dt_tm) > 0)
       temp->sl[xx].il[yy].past_prob_list[past_prob_cnt].onset_year = trim(cnvtstring(year(pr
          .onset_dt_tm)))
      ENDIF
      temp->sl[xx].il[yy].past_prob_list[past_prob_cnt].onset_age = trim(cnvtage(birth_temp->
        birth_temp_dt,pr.onset_dt_tm,0)), temp->sl[xx].il[yy].past_prob_list[past_prob_cnt].
      life_cycle_status_disp = uar_get_code_display(pr.life_cycle_status_cd)
     ELSE
      temp->sl[xx].il[yy].past_prob_list_restricted_ind = 1
     ENDIF
    HEAD pc.problem_comment_id
     IF ((((org_sec_map->restrict_ind=0)) OR (((orgsecoverrideind != 0) OR (locateidx > 0)) )) )
      IF (pc.problem_comment_id > 0)
       comment_cnt += 1
       IF (size(temp->sl[xx].il[yy].past_prob_list[past_prob_cnt].comments,5) < comment_cnt)
        stat = alterlist(temp->sl[xx].il[yy].past_prob_list[past_prob_cnt].comments,comment_cnt)
       ENDIF
       temp->sl[xx].il[yy].past_prob_list[past_prob_cnt].comments[comment_cnt].comment = pc
       .problem_comment, temp->sl[xx].il[yy].past_prob_list[past_prob_cnt].comments[comment_cnt].
       comment_prsnl_name = prp.name_full_formatted, date_temp->dt1 = cnvtdatetime(pc.comment_dt_tm),
       temp->sl[xx].il[yy].past_prob_list[past_prob_cnt].comments[comment_cnt].comment_dt_tm_str =
       trim(formatdatetime(pc.comment_tz," "))
      ENDIF
     ENDIF
    FOOT REPORT
     stat = alterlist(temp->sl[xx].il[yy].past_prob_list,past_prob_cnt)
    WITH nocounter
   ;end select
   CALL echo(build("Exiting GET_PAST_MED_HISTORY"))
 END ;Subroutine
 SUBROUTINE (get_gravida_data(xx=i4,yy=i4) =null)
   CALL echo(build("GET_GRAVIDA_DATA"))
   RECORD request_grav(
     1 patient_id = f8
     1 prsnl_id = f8
     1 org_sec_override = i2
   )
   SET request_grav->patient_id = temp->person_id
   SET request_grav->prsnl_id = reqinfo->updt_id
   CALL echo(build("reqinfo->updt_id",reqinfo->updt_id))
   SET request_grav->org_sec_override = 0
   SET modify = nopredeclare
   EXECUTE dcp_get_gravida_info  WITH replace("REQUEST",request_grav), replace("REPLY",reply_grav)
   SET modify = predeclare
   IF ((reply_grav->status_data.status="F"))
    CALL echo(build("dcp_get_gravida_info: ","Status failed"))
   ELSEIF ((reply_grav->status_data.status="S"))
    CALL echorecord(reply_grav)
    SET temp->sl[xx].ind = 1
    SET stat = alterlist(temp->sl[xx].il[yy].gravida,1)
    SET temp->sl[xx].il[yy].gravida[1].gravida = reply_grav->gravida
    SET temp->sl[xx].il[yy].gravida[1].fullterm = reply_grav->fullterm
    SET temp->sl[xx].il[yy].gravida[1].parapreterm = reply_grav->premature
    SET temp->sl[xx].il[yy].gravida[1].aborted = reply_grav->aborted
    SET temp->sl[xx].il[yy].gravida[1].living = reply_grav->living
   ENDIF
   CALL echo(build("Leaving GET_GRAVIDA_DATA"))
 END ;Subroutine
 SUBROUTINE (get_pregnancy_history(xx=i4,yy=i4) =null)
   CALL echo(build("Entering GET_PREGNANCY_HISTORY"))
   DECLARE preg_num = i4 WITH protect, noconstant(0)
   DECLARE chld_num = i4 WITH protect, noconstant(0)
   DECLARE mothercomp_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002124,"MOTHERCOMP"))
   DECLARE fetuscomp_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002124,"FETUSCOMP"))
   DECLARE newborncomp_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002124,"NEWBORNCOMP"
     ))
   DECLARE pretermlabor_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002124,
     "PRETERMLABOR"))
   DECLARE ma_comp_num = i4 WITH protect, noconstant(0)
   DECLARE fetus_comp_num = i4 WITH protect, noconstant(0)
   DECLARE neo_comp_num = i4 WITH protect, noconstant(0)
   DECLARE prelabor_num = i4 WITH protect, noconstant(0)
   DECLARE pregidx = i4 WITH protect, noconstant(0)
   DECLARE auto_close_action_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002114,
     "AUTOCLOSE"))
   DECLARE locateidx = i4 WITH protect, noconstant(0)
   SET temp->sl[xx].il[yy].pregnancies_restricted_ind = 0
   SET temp->sl[xx].ind = 1
   SELECT INTO "nl:"
    FROM pregnancy_instance pi,
     pregnancy_action pa,
     pregnancy_child pc,
     pregnancy_child_entity_r pce,
     nomenclature n,
     long_text lt
    PLAN (pi
     WHERE (pi.person_id=temp->person_id)
      AND pi.active_ind=1
      AND pi.preg_end_dt_tm <= cnvtdatetime(sysdate))
     JOIN (pa
     WHERE (pa.pregnancy_instance_id= Outerjoin(pi.pregnancy_instance_id))
      AND (pa.action_type_cd= Outerjoin(auto_close_action_cd)) )
     JOIN (pc
     WHERE (pc.pregnancy_id= Outerjoin(pi.pregnancy_id))
      AND (pc.active_ind= Outerjoin(1)) )
     JOIN (pce
     WHERE (pce.pregnancy_child_id= Outerjoin(pc.pregnancy_child_id))
      AND (pce.active_ind= Outerjoin(1)) )
     JOIN (n
     WHERE (n.nomenclature_id= Outerjoin(pce.parent_entity_id)) )
     JOIN (lt
     WHERE (lt.long_text_id= Outerjoin(pce.parent_entity_id)) )
    ORDER BY pi.pregnancy_id, pc.pregnancy_child_id, pce.parent_entity_id
    HEAD pi.pregnancy_id
     locateidx = locateval(pregidx,1,size(user_sec_organizations->qual,5),pi.organization_id,
      user_sec_organizations->qual[pregidx].organization_id)
     IF (((preg_org_sec_ind=0) OR (locateidx > 0)) )
      chld_num = 0, preg_num += 1
      IF (preg_num > size(temp->sl[xx].il[yy].pregnancies,5))
       stat = alterlist(temp->sl[xx].il[yy].pregnancies,(preg_num+ 10))
      ENDIF
      date_temp->dt1 = cnvtdatetime(pi.preg_start_dt_tm), temp->sl[xx].il[yy].pregnancies[preg_num].
      preg_start_dt_tm_str = formatdatetime(0," "), date_temp->dt1 = cnvtdatetime(pi.preg_end_dt_tm),
      temp->sl[xx].il[yy].pregnancies[preg_num].preg_end_dt_tm_str = formatdatetime(0," ")
     ELSE
      temp->sl[xx].il[yy].pregnancies_restricted_ind = 1
     ENDIF
     IF (pa.action_type_cd > 0
      AND pa.action_type_cd=auto_close_action_cd)
      temp->sl[xx].il[yy].pregnancies[preg_num].auto_close_ind = 1
     ELSE
      temp->sl[xx].il[yy].pregnancies[preg_num].auto_close_ind = 0
     ENDIF
    HEAD pc.pregnancy_child_id
     IF (((preg_org_sec_ind=0) OR (locateidx > 0)) )
      ma_comp_num = 0, fetus_comp_num = 0, neo_comp_num = 0,
      prelabor_num = 0, chld_num += 1
      IF (chld_num > size(temp->sl[xx].il[yy].pregnancies[preg_num].child_list,5))
       stat = alterlist(temp->sl[xx].il[yy].pregnancies[preg_num].child_list,(chld_num+ 10))
      ENDIF
      temp->sl[xx].il[yy].pregnancies[preg_num].child_list[chld_num].child_name = pc.child_name, temp
      ->sl[xx].il[yy].pregnancies[preg_num].child_list[chld_num].gender_disp = uar_get_code_display(
       pc.gender_cd), temp->sl[xx].il[yy].pregnancies[preg_num].child_list[chld_num].
      delivery_date_precision_flag = pc.delivery_date_precision_flag,
      date_temp->dt1 = cnvtdatetime(pc.delivery_dt_tm), temp->sl[xx].il[yy].pregnancies[preg_num].
      child_list[chld_num].delivery_dt_tm_str = formatfuzzydate(pc.delivery_tz," ",pc
       .delivery_date_precision_flag,pc.delivery_date_qualifier_flag), temp->sl[xx].il[yy].
      pregnancies[preg_num].child_list[chld_num].delivery_hospital = pc.delivery_hospital,
      temp->sl[xx].il[yy].pregnancies[preg_num].child_list[chld_num].delivery_method_disp =
      uar_get_code_display(pc.delivery_method_cd), temp->sl[xx].il[yy].pregnancies[preg_num].
      child_list[chld_num].anesthesia_disp = pc.anesthesia_txt
      IF (pc.gestation_age > 0)
       IF (((pc.gestation_age/ 7) > 0))
        temp->sl[xx].il[yy].pregnancies[preg_num].child_list[chld_num].gestation_age_in_weeks = (pc
        .gestation_age/ 7)
       ENDIF
       IF (mod(pc.gestation_age,7) > 0)
        temp->sl[xx].il[yy].pregnancies[preg_num].child_list[chld_num].gestation_age_in_days = mod(pc
         .gestation_age,7)
       ENDIF
      ELSEIF (validate(pc.gestation_term_txt))
       IF (trim(pc.gestation_term_txt) > "")
        temp->sl[xx].il[yy].pregnancies[preg_num].child_list[chld_num].gestation_term_txt = pc
        .gestation_term_txt
       ENDIF
      ENDIF
      IF (trim(pc.preterm_labor_txt) > "")
       temp->sl[xx].il[yy].pregnancies[preg_num].child_list[chld_num].preterm_labor_disp = pc
       .preterm_labor_txt
      ENDIF
      IF (pc.weight_amt > 0)
       temp->sl[xx].il[yy].pregnancies[preg_num].child_list[chld_num].birth_weight_disp = build2(trim
        (cnvtstring(pc.weight_amt)),"  ",uar_get_code_display(pc.weight_unit_cd))
      ENDIF
      temp->sl[xx].il[yy].pregnancies[preg_num].child_list[chld_num].father_name = pc.father_name,
      temp->sl[xx].il[yy].pregnancies[preg_num].child_list[chld_num].neonate_outcome_disp =
      uar_get_code_display(pc.neonate_outcome_cd)
     ENDIF
    HEAD pce.parent_entity_id
     IF (((preg_org_sec_ind=0) OR (locateidx > 0)) )
      IF (pce.component_type_cd=mothercomp_cd)
       ma_comp_num += 1
       IF (ma_comp_num > size(temp->sl[xx].il[yy].pregnancies[preg_num].child_list[chld_num].
        ma_comp_list,5))
        stat = alterlist(temp->sl[xx].il[yy].pregnancies[preg_num].child_list[chld_num].ma_comp_list,
         ma_comp_num)
       ENDIF
       IF (trim(n.source_string) > "")
        temp->sl[xx].il[yy].pregnancies[preg_num].child_list[chld_num].ma_comp_list[ma_comp_num].
        complication_disp = n.source_string
       ELSE
        temp->sl[xx].il[yy].pregnancies[preg_num].child_list[chld_num].ma_comp_list[ma_comp_num].
        complication_disp = lt.long_text
       ENDIF
      ELSEIF (pce.component_type_cd=fetuscomp_cd)
       fetus_comp_num += 1
       IF (fetus_comp_num > size(temp->sl[xx].il[yy].pregnancies[preg_num].child_list[chld_num].
        fetus_comp_list,5))
        stat = alterlist(temp->sl[xx].il[yy].pregnancies[preg_num].child_list[chld_num].
         fetus_comp_list,fetus_comp_num)
       ENDIF
       IF (trim(n.source_string) > "")
        temp->sl[xx].il[yy].pregnancies[preg_num].child_list[chld_num].fetus_comp_list[fetus_comp_num
        ].complication_disp = n.source_string
       ELSE
        temp->sl[xx].il[yy].pregnancies[preg_num].child_list[chld_num].fetus_comp_list[fetus_comp_num
        ].complication_disp = lt.long_text
       ENDIF
      ELSEIF (pce.component_type_cd=newborncomp_cd)
       neo_comp_num += 1
       IF (neo_comp_num > size(temp->sl[xx].il[yy].pregnancies[preg_num].child_list[chld_num].
        neo_comp_list,5))
        stat = alterlist(temp->sl[xx].il[yy].pregnancies[preg_num].child_list[chld_num].neo_comp_list,
         neo_comp_num)
       ENDIF
       IF (trim(n.source_string) > "")
        temp->sl[xx].il[yy].pregnancies[preg_num].child_list[chld_num].neo_comp_list[neo_comp_num].
        complication_disp = n.source_string
       ELSE
        temp->sl[xx].il[yy].pregnancies[preg_num].child_list[chld_num].neo_comp_list[neo_comp_num].
        complication_disp = lt.long_text
       ENDIF
      ELSEIF (pce.component_type_cd=pretermlabor_cd)
       IF (pce.parent_entity_name="CODE_VALUE")
        prelabor_num += 1
        IF (prelabor_num > size(temp->sl[xx].il[yy].pregnancies[preg_num].child_list[chld_num].
         preterm_labors,5))
         stat = alterlist(temp->sl[xx].il[yy].pregnancies[preg_num].child_list[chld_num].
          preterm_labors,prelabor_num)
        ENDIF
        temp->sl[xx].il[yy].pregnancies[preg_num].child_list[chld_num].preterm_labors[prelabor_num].
        preterm_labor = uar_get_code_display(pce.parent_entity_id)
       ENDIF
      ENDIF
     ENDIF
    FOOT  pc.pregnancy_child_id
     IF (((preg_org_sec_ind=0) OR (locateidx > 0)) )
      stat = alterlist(temp->sl[xx].il[yy].pregnancies[preg_num].child_list,chld_num)
      IF (trim(temp->sl[xx].il[yy].pregnancies[preg_num].child_list[chld_num].preterm_labor_disp) >
      "")
       prelabor_num += 1
       IF (prelabor_num > size(temp->sl[xx].il[yy].pregnancies[preg_num].child_list[chld_num].
        preterm_labors,5))
        stat = alterlist(temp->sl[xx].il[yy].pregnancies[preg_num].child_list[chld_num].
         preterm_labors,prelabor_num)
       ENDIF
       temp->sl[xx].il[yy].pregnancies[preg_num].child_list[chld_num].preterm_labors[prelabor_num].
       preterm_labor = trim(temp->sl[xx].il[yy].pregnancies[preg_num].child_list[chld_num].
        preterm_labor_disp)
      ENDIF
     ENDIF
    FOOT  pi.pregnancy_id
     IF (((preg_org_sec_ind=0) OR (locateidx > 0)) )
      stat = alterlist(temp->sl[xx].il[yy].pregnancies,preg_num)
     ENDIF
    WITH nocounter
   ;end select
   CALL echo(build("Leaving GET_PREGNANCY_HISTORY"))
 END ;Subroutine
 SUBROUTINE (get_family_history(xx=i4,yy=i4) =null)
   CALL echo(build("Entering GET_FAMILY_HISTORY"))
   DECLARE member_cnt = i4 WITH protect, noconstant(0)
   SET temp->sl[xx].il[yy].entire_fam_hist_ind = - (1)
   SELECT INTO "nl:"
    FROM fhx_activity fa
    PLAN (fa
     WHERE (fa.person_id=temp->person_id)
      AND fa.active_ind=1
      AND fa.type_mean="PERSON"
      AND fa.fhx_value_flag IN (0, 2, 3, 4))
    ORDER BY fa.fhx_activity_id
    HEAD fa.fhx_activity_id
     temp->sl[xx].ind = 1, temp->sl[xx].il[yy].entire_fam_hist_ind = fa.fhx_value_flag
    WITH nocounter
   ;end select
   IF ((((temp->sl[xx].il[yy].entire_fam_hist_ind=0)) OR ((((temp->sl[xx].il[yy].entire_fam_hist_ind=
   2)) OR ((temp->sl[xx].il[yy].entire_fam_hist_ind=3))) )) )
    SET temp->sl[xx].ind = 1
    RETURN
   ENDIF
   CALL get_family_hist_details(xx,yy)
   CALL get_family_member_reltns(xx,yy)
   IF (member_cnt > 0
    AND (temp->sl[xx].il[yy].entire_fam_hist_ind=- (1)))
    SET temp->sl[xx].il[yy].entire_fam_hist_ind = 1
   ENDIF
   CALL echo(build("Leaving GET_FAMILY_HISTORY"))
 END ;Subroutine
 SUBROUTINE (get_family_hist_details(xx=i4,yy=i4) =null)
   CALL echo("Entering GET_FAMILY_HIST_DETAILS")
   DECLARE reply_ind = i2 WITH protect, noconstant(0)
   DECLARE rscnt = i4 WITH protect, noconstant(0)
   DECLARE pidx = i4 WITH protect, noconstant(0)
   DECLARE locateind = i4 WITH protect, noconstant(0)
   DECLARE tmp_related_prn_id = f8 WITH protect, noconstant(0)
   DECLARE condi_cnt = i4 WITH protect, noconstant(0)
   DECLARE memb_sync = i4 WITH protect, noconstant(0)
   DECLARE comntcnt = i4 WITH protect, noconstant(0)
   DECLARE comntidx = i4 WITH protect, noconstant(0)
   SET temp->sl[xx].il[yy].fam_list_restricted_ind = 0
   RECORD request_fam(
     1 person_id = f8
     1 prsnl_id = f8
   )
   SET request_fam->person_id = temp->person_id
   SET request_fam->prsnl_id = reqinfo->updt_id
   SET modify = nopredeclare
   EXECUTE kia_get_family_history  WITH replace("REQUEST",request_fam), replace("REPLY",reply_fam)
   SET modify = predeclare
   IF ((reply_fam->status_data.status="F"))
    CALL echo(build("kia_get_family_history: ","status failed"))
    RETURN
   ELSEIF ((reply_fam->status_data.status="Z"))
    CALL echo(build("kia_get_family_history: ","no data"))
   ELSEIF ((reply_fam->status_data.status="S"))
    SET temp->sl[xx].ind = 1
    SET reply_ind = 1
   ENDIF
   IF ((reply_fam->incomplete_data_ind=1))
    SET temp->sl[xx].il[yy].fam_list_restricted_ind = 1
   ENDIF
   IF (reply_ind=1)
    FOR (rscnt = 1 TO size(reply_fam->result_qual,5))
      IF ((reply_fam->result_qual[rscnt].type_mean="PERSON"))
       SET temp->sl[xx].il[yy].entire_fam_hist_ind = reply_fam->result_qual[rscnt].fhx_value_flag
      ELSEIF ((((reply_fam->result_qual[rscnt].type_mean="RELTN")) OR ((reply_fam->result_qual[rscnt]
      .type_mean="CONDITION"))) )
       SET pidx = 0
       SET tmp_related_prn_id = reply_fam->result_qual[rscnt].related_person_id
       SET pidx = locateval(locateind,1,member_cnt,tmp_related_prn_id,temp->sl[xx].il[yy].
        fam_members[locateind].related_person_id)
       IF (pidx=0)
        SET member_cnt += 1
        IF (size(temp->sl[xx].il[yy].fam_members,5) < member_cnt)
         SET stat = alterlist(temp->sl[xx].il[yy].fam_members,member_cnt)
        ENDIF
        SET temp->sl[xx].il[yy].fam_members[member_cnt].memb_entire_hist_ind = reply_fam->
        result_qual[rscnt].fhx_value_flag
        SET temp->sl[xx].il[yy].fam_members[member_cnt].related_person_id = reply_fam->result_qual[
        rscnt].related_person_id
        IF ((reply_fam->result_qual[rscnt].type_mean="RELTN"))
         SET temp->sl[xx].il[yy].fam_members[member_cnt].memb_entire_hist_ind = reply_fam->
         result_qual[rscnt].fhx_value_flag
        ELSE
         SET temp->sl[xx].il[yy].fam_members[member_cnt].memb_entire_hist_ind = 1
        ENDIF
        SET memb_sync = member_cnt
       ELSE
        SET memb_sync = pidx
       ENDIF
       IF ((reply_fam->result_qual[rscnt].type_mean="CONDITION"))
        SET condi_cnt = (size(temp->sl[xx].il[yy].fam_members[memb_sync].conditions,5)+ 1)
        SET stat = alterlist(temp->sl[xx].il[yy].fam_members[memb_sync].conditions,condi_cnt)
        SET temp->sl[xx].il[yy].fam_members[memb_sync].conditions[condi_cnt].source_string =
        reply_fam->result_qual[rscnt].source_string
        SET temp->sl[xx].il[yy].fam_members[memb_sync].conditions[condi_cnt].fhx_value_flag =
        reply_fam->result_qual[rscnt].fhx_value_flag
        SET temp->sl[xx].il[yy].fam_members[memb_sync].conditions[condi_cnt].condition_status =
        uar_get_code_display(reply_fam->result_qual[rscnt].life_cycle_status_cd)
        SET temp->sl[xx].il[yy].fam_members[memb_sync].conditions[condi_cnt].onset_age = reply_fam->
        result_qual[rscnt].onset_age
        SET temp->sl[xx].il[yy].fam_members[memb_sync].conditions[condi_cnt].onset_age_unit_disp =
        uar_get_code_display(reply_fam->result_qual[rscnt].onset_age_unit_cd)
        SET temp->sl[xx].il[yy].fam_members[memb_sync].conditions[condi_cnt].onset_age_unit_cd_mean
         = uar_get_code_meaning(reply_fam->result_qual[rscnt].onset_age_unit_cd)
        SET comntcnt = size(reply_fam->result_qual[rscnt].comment_qual,5)
        SET stat = alterlist(temp->sl[xx].il[yy].fam_members[memb_sync].conditions[condi_cnt].
         comments,comntcnt)
        FOR (comntidx = 1 TO comntcnt)
          SET temp->sl[xx].il[yy].fam_members[memb_sync].conditions[condi_cnt].comments[comntidx].
          comment = reply_fam->result_qual[rscnt].comment_qual[comntidx].long_text
          SET temp->sl[xx].il[yy].fam_members[memb_sync].conditions[condi_cnt].comments[comntidx].
          comment_prsnl_name = reply_fam->result_qual[rscnt].comment_qual[comntidx].
          comment_prsnl_full_name
          SET date_temp->dt1 = cnvtdatetime(reply_fam->result_qual[rscnt].comment_qual[comntidx].
           comment_dt_tm)
          SET temp->sl[xx].il[yy].fam_members[memb_sync].conditions[condi_cnt].comments[comntidx].
          comment_dt_tm_str = formatdatetime(reply_fam->result_qual[rscnt].comment_qual[comntidx].
           comment_dt_tm_tz," ")
        ENDFOR
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   CALL echo("leaving GET_FAMILY_HIST_DETAILS")
 END ;Subroutine
 SUBROUTINE (get_family_member_reltns(xx=i4,yy=i4) =null)
   CALL echo(build("Entering GET_FAMILY_MEMBER_RELTNS/member_cnt: ",member_cnt))
   IF (member_cnt=0)
    RETURN
   ENDIF
   DECLARE familyhist_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",351,"FAMILYHIST"))
   DECLARE self_reltn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",40,"SELF"))
   DECLARE fam_members_cnt = i4 WITH protect, noconstant(size(temp->sl[xx].il[yy].fam_members,5))
   DECLARE exp_cnt = i4 WITH protect, noconstant(member_cnt)
   DECLARE exp_index = i4 WITH protect, noconstant(0)
   DECLARE exp_start = i4 WITH protect, noconstant(1)
   DECLARE exp_max = i4 WITH protect, constant(20)
   DECLARE exp_chunk_cnt = i4 WITH protect, constant(ceil(((exp_cnt * 1.0)/ exp_max)))
   DECLARE exp_max_size = i4 WITH protect, constant((exp_chunk_cnt * exp_max))
   DECLARE prn_idx = i4 WITH protect, noconstant(0)
   DECLARE found_idx = i4 WITH protect, noconstant(0)
   DECLARE x_cnt = i4 WITH protect, noconstant(0)
   RECORD tmp_members(
     1 member_list[*]
       2 person_id = f8
   )
   SET stat = alterlist(tmp_members->member_list,exp_max_size)
   FOR (x_cnt = 1 TO exp_max_size)
     IF (x_cnt < exp_cnt)
      SET tmp_members->member_list[x_cnt].person_id = temp->sl[xx].il[yy].fam_members[x_cnt].
      related_person_id
     ELSE
      SET tmp_members->member_list[x_cnt].person_id = temp->sl[xx].il[yy].fam_members[exp_cnt].
      related_person_id
     ENDIF
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt dt  WITH seq = value(exp_chunk_cnt)),
     person_person_reltn ppr,
     person p
    PLAN (dt
     WHERE assign(exp_start,evaluate(dt.seq,1,1,(exp_start+ exp_max))))
     JOIN (ppr
     WHERE expand(exp_index,exp_start,((exp_start+ exp_max) - 1),ppr.related_person_id,tmp_members->
      member_list[exp_index].person_id)
      AND ppr.active_ind=1
      AND ppr.person_reltn_type_cd=familyhist_cd)
     JOIN (p
     WHERE p.person_id=ppr.related_person_id)
    ORDER BY ppr.related_person_id
    HEAD ppr.related_person_id
     temp->sl[xx].ind = 1, found_idx = 0, found_idx = locateval(prn_idx,1,fam_members_cnt,ppr
      .related_person_id,temp->sl[xx].il[yy].fam_members[prn_idx].related_person_id)
     IF (found_idx > 0)
      IF (self_reltn_cd=ppr.person_reltn_cd)
       temp->sl[xx].il[yy].fam_members[found_idx].memb_name = trim(pat_name), temp->sl[xx].il[yy].
       fam_members[found_idx].memb_birth_dt_tm = birth_temp->birth_temp_dt
      ELSE
       IF (trim(p.name_last_key) > ""
        AND trim(p.name_first_key) > "")
        temp->sl[xx].il[yy].fam_members[found_idx].memb_name = trim(p.name_full_formatted)
       ENDIF
       temp->sl[xx].il[yy].fam_members[found_idx].memb_birth_dt_tm = p.birth_dt_tm
      ENDIF
      temp->sl[xx].il[yy].fam_members[found_idx].reltn_disp = uar_get_code_display(ppr
       .person_reltn_cd), temp->sl[xx].il[yy].fam_members[found_idx].deceased_cd = p.deceased_cd,
      temp->sl[xx].il[yy].fam_members[found_idx].cause_of_death = p.cause_of_death
      IF (p.age_at_death > 0)
       temp->sl[xx].il[yy].fam_members[found_idx].age_at_death_str = build2(trim(cnvtstring(p
          .age_at_death))," ",uar_get_code_display(p.age_at_death_unit_cd))
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   CALL echo(build("Leaving GET_FAMILY_MEMBER_RELTNS/member_cnt: ",member_cnt))
 END ;Subroutine
 SUBROUTINE (get_social_history(xx=i4,yy=i4) =null)
   SET temp->sl[xx].il[yy].shx_unable_to_obtain_ind = - (1)
   SELECT INTO "nl:"
    FROM shx_activity sact
    WHERE (sact.person_id=temp->person_id)
     AND sact.type_mean="PERSON"
     AND sact.active_ind=1
    ORDER BY sact.shx_activity_id
    HEAD sact.shx_activity_id
     temp->sl[xx].il[yy].shx_unable_to_obtain_ind = sact.unable_to_obtain_ind, temp->sl[xx].ind = 1
    WITH nocounter
   ;end select
   IF ((temp->sl[xx].il[yy].shx_unable_to_obtain_ind=1))
    SET temp->sl[xx].ind = 1
    RETURN
   ENDIF
   RECORD social_category(
     1 cat_qual[*]
       2 shx_cat_ref_id = f8
       2 order_idx = i4
   )
   CALL get_social_category(null)
   CALL get_social_hist_details(xx,yy)
   IF ((temp->sl[xx].il[yy].shx_unable_to_obtain_ind=- (1))
    AND size(temp->sl[xx].il[yy].social_cat_list,5) > 0)
    SET temp->sl[xx].il[yy].shx_unable_to_obtain_ind = 0
    SET temp->sl[xx].ind = 1
   ENDIF
 END ;Subroutine
 SUBROUTINE get_social_category(null)
   DECLARE category_ref_id = f8 WITH protect, noconstant(0.0)
   DECLARE hpref = i4 WITH protect, noconstant(0)
   DECLARE position_cd_str = vc WITH protect, noconstant(fillstring(20," "))
   DECLARE user_id_str = vc WITH protect, noconstant(fillstring(20," "))
   DECLARE hgroup = i4 WITH protect, noconstant(0)
   DECLARE hrepgroup = i4 WITH protect, noconstant(0)
   DECLARE cntentry = i4 WITH protect, noconstant(0)
   DECLARE idxentry = i4 WITH protect, noconstant(0)
   DECLARE hsection = i4 WITH protect, noconstant(0)
   DECLARE hattr = i4 WITH protect, noconstant(0)
   DECLARE hentry = i4 WITH protect, noconstant(0)
   DECLARE cntval = i4 WITH protect, noconstant(0)
   DECLARE idxval = i4 WITH protect, noconstant(0)
   DECLARE entryname = c255 WITH protect, noconstant("")
   DECLARE val = c255 WITH protect, noconstant("")
   DECLARE len = i4 WITH protect, noconstant(0)
   CALL get_prsnl_position_cd(null)
   SET modify = nopredeclare
   EXECUTE prefrtl
   SET modify = predeclare
   SET hpref = uar_prefcreateinstance(0)
   SET stat = uar_prefaddcontext(hpref,"default","system")
   IF ((temp->prsnl_position_cd > 0))
    SET position_cd_str = cnvtstring(temp->prsnl_position_cd,20,2)
    SET stat = uar_prefaddcontext(hpref,"position",nullterm(position_cd_str))
   ENDIF
   IF ((reqinfo->updt_id > 0))
    SET user_id_str = cnvtstring(reqinfo->updt_id,20,2)
    SET stat = uar_prefaddcontext(hpref,"user",nullterm(user_id_str))
   ENDIF
   SET stat = uar_prefsetsection(hpref,"component")
   SET hgroup = uar_prefcreategroup()
   SET stat = uar_prefsetgroupname(hgroup,"social history")
   SET stat = uar_prefaddgroup(hpref,hgroup)
   SET stat = uar_prefperform(hpref)
   SET hsection = uar_prefgetsectionbyname(hpref,"component")
   SET hrepgroup = uar_prefgetgroupbyname(hsection,"social history")
   SET cntentry = 0
   SET stat = uar_prefgetgroupentrycount(hrepgroup,cntentry)
   SET idxentry = 0
   FOR (idxentry = 0 TO (cntentry - 1))
     SET hentry = uar_prefgetgroupentry(hrepgroup,idxentry)
     SET len = 255
     SET entryname = ""
     SET stat = uar_prefgetentryname(hentry,entryname,len)
     IF (trim(entryname)="category list")
      SET hattr = uar_prefgetentryattr(hentry,0)
      SET cntval = 0
      SET stat = uar_prefgetattrvalcount(hattr,cntval)
      SET idxval = 0
      SET stat = alterlist(social_category->cat_qual,cntval)
      FOR (idxval = 0 TO (cntval - 1))
        SET val = ""
        SET len = 255
        SET stat = uar_prefgetattrval(hattr,val,len,idxval)
        SET category_ref_id = cnvtreal(trim(val))
        SET social_category->cat_qual[(idxval+ 1)].shx_cat_ref_id = category_ref_id
        SET social_category->cat_qual[(idxval+ 1)].order_idx = (idxval+ 1)
        CALL echo(build("Pref Order:",cnvtreal(trim(val))))
      ENDFOR
     ENDIF
   ENDFOR
   CALL uar_prefdestroysection(hsection)
   CALL uar_prefdestroygroup(hgroup)
   CALL uar_prefdestroyinstance(hpref)
 END ;Subroutine
 SUBROUTINE (get_social_hist_details(xx=i4,yy=i4) =null)
   IF (value(size(social_category->cat_qual,5))=0)
    RETURN
   ENDIF
   RECORD tmp_grp_id(
     1 activity_qual[*]
       2 shx_activity_group_id = f8
       2 shx_category_ref_id = f8
   )
   DECLARE status_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002172,"ACTIVE"))
   DECLARE batch_sz = i4 WITH protect, noconstant(20)
   DECLARE cur_size = i4 WITH protect, noconstant(value(size(social_category->cat_qual,5)))
   DECLARE batch_cnt = i4 WITH protect, noconstant(0)
   DECLARE new_size = i4 WITH protect, noconstant(0)
   DECLARE start_xp = i4 WITH protect, noconstant(0)
   DECLARE id_xp = i4 WITH protect, noconstant(0)
   DECLARE cat_cnt = i4 WITH protect, noconstant(0)
   DECLARE act_cnt = i4 WITH protect, noconstant(0)
   DECLARE grp_id_cnt = i4 WITH protect, noconstant(0)
   DECLARE userlogontypenhsind = i2 WITH protect, noconstant(0)
   DECLARE locateidx = i4 WITH protect, noconstant(0)
   DECLARE shxidx = i4 WITH protect, noconstant(0)
   SET temp->sl[xx].il[yy].social_cat_list_restricted_ind = 0
   CALL checkukorgsecutiryshx(null)
   SET batch_cnt = ceil((cnvtreal(cur_size)/ batch_sz))
   SET new_size = (batch_cnt * batch_sz)
   SET stat = alterlist(social_category->cat_qual,new_size)
   FOR (cat_cnt = (cur_size+ 1) TO new_size)
    SET social_category->cat_qual[cat_cnt].shx_cat_ref_id = social_category->cat_qual[cur_size].
    shx_cat_ref_id
    SET social_category->cat_qual[cat_cnt].order_idx = social_category->cat_qual[cur_size].order_idx
   ENDFOR
   SELECT INTO "nl:"
    npriority = social_category->cat_qual[id_xp].order_idx
    FROM shx_activity sa,
     shx_category_ref ref,
     long_text lt,
     prsnl p
    PLAN (sa
     WHERE (sa.person_id=temp->person_id)
      AND expand(id_xp,1,new_size,sa.shx_category_ref_id,social_category->cat_qual[id_xp].
      shx_cat_ref_id)
      AND sa.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND sa.end_effective_dt_tm > cnvtdatetime(sysdate)
      AND ((sa.type_mean="ASSESSMENT") OR (sa.type_mean="DETAIL"))
      AND sa.active_ind=1
      AND sa.status_cd=status_cd)
     JOIN (ref
     WHERE ref.shx_category_ref_id=sa.shx_category_ref_id)
     JOIN (lt
     WHERE lt.long_text_id=sa.long_text_id)
     JOIN (p
     WHERE p.person_id=sa.updt_id)
    ORDER BY npriority, ref.description, ref.shx_category_ref_id,
     sa.shx_activity_group_id, sa.updt_dt_tm
    HEAD REPORT
     cat_cnt = 0
    HEAD ref.shx_category_ref_id
     temp->sl[xx].ind = 1, locateidx = locateval(shxidx,1,size(user_sec_organizations->qual,5),sa
      .organization_id,user_sec_organizations->qual[shxidx].organization_id)
     IF (((userlogontypenhsind=0) OR (locateidx > 0)) )
      cat_cnt += 1
      IF (mod(cat_cnt,10)=1)
       stat = alterlist(temp->sl[xx].il[yy].social_cat_list,(cat_cnt+ 9))
      ENDIF
      temp->sl[xx].il[yy].social_cat_list[cat_cnt].shx_cat_ref_id = sa.shx_category_ref_id, temp->sl[
      xx].il[yy].social_cat_list[cat_cnt].desc = ref.description, act_cnt = 0
     ELSE
      temp->sl[xx].il[yy].social_cat_list_restricted_ind = 1
     ENDIF
    HEAD sa.shx_activity_group_id
     IF (((userlogontypenhsind=0) OR (locateidx > 0)) )
      IF (sa.type_mean="ASSESSMENT")
       temp->sl[xx].il[yy].social_cat_list[cat_cnt].assessment_disp = uar_get_code_display(sa
        .assessment_cd), temp->sl[xx].il[yy].social_cat_list[cat_cnt].last_updt_prsnl = trim(p
        .name_full_formatted), date_temp->dt1 = cnvtdatetime(sa.updt_dt_tm),
       temp->sl[xx].il[yy].social_cat_list[cat_cnt].last_updt_dt_tm = trim(formatdatetime(0," "))
      ENDIF
      IF (sa.type_mean="DETAIL")
       grp_id_cnt += 1
       IF (grp_id_cnt > size(tmp_grp_id->activity_qual,5))
        stat = alterlist(tmp_grp_id->activity_qual,(grp_id_cnt+ 5))
       ENDIF
       tmp_grp_id->activity_qual[grp_id_cnt].shx_activity_group_id = sa.shx_activity_group_id,
       tmp_grp_id->activity_qual[grp_id_cnt].shx_category_ref_id = sa.shx_category_ref_id, act_cnt
        += 1
       IF (act_cnt > size(temp->sl[xx].il[yy].social_cat_list[cat_cnt].detail_list,5))
        stat = alterlist(temp->sl[xx].il[yy].social_cat_list[cat_cnt].detail_list,(act_cnt+ 5))
       ENDIF
       temp->sl[xx].il[yy].social_cat_list[cat_cnt].detail_list[act_cnt].shx_activity_grp_id = sa
       .shx_activity_group_id, temp->sl[xx].il[yy].social_cat_list[cat_cnt].detail_list[act_cnt].
       detail_disp = trim(lt.long_text), temp->sl[xx].il[yy].social_cat_list[cat_cnt].detail_list[
       act_cnt].detail_updt_prsnl = trim(p.name_full_formatted),
       date_temp->dt1 = cnvtdatetime(sa.updt_dt_tm), temp->sl[xx].il[yy].social_cat_list[cat_cnt].
       detail_list[act_cnt].detail_updt_dt_tm = trim(formatdatetime(0," "))
      ENDIF
     ENDIF
    FOOT  sa.shx_activity_group_id
     IF (((userlogontypenhsind=0) OR (locateidx > 0)) )
      IF (act_cnt > 0)
       stat = alterlist(temp->sl[xx].il[yy].social_cat_list[cat_cnt].detail_list,act_cnt)
      ENDIF
     ENDIF
    FOOT REPORT
     IF (cat_cnt > 0)
      stat = alterlist(temp->sl[xx].il[yy].social_cat_list,cat_cnt)
     ENDIF
     IF (grp_id_cnt > 0)
      stat = alterlist(tmp_grp_id->activity_qual,grp_id_cnt)
     ENDIF
    WITH nocounter
   ;end select
   IF (grp_id_cnt=0)
    RETURN
   ENDIF
   DECLARE cmnt_cnt = i4 WITH protect, noconstant(0)
   DECLARE locat_act = i4 WITH protect, noconstant(0)
   DECLARE locat_cat = i4 WITH protect, noconstant(0)
   DECLARE locat_ref = i4 WITH protect, noconstant(0)
   DECLARE tmp_idx = i4 WITH protect, noconstant(0)
   DECLARE detail_sz = i4 WITH protect, noconstant(0)
   DECLARE idx_xp = i4 WITH protect, noconstant(0)
   SET start_xp = 1
   SET batch_sz = 20
   SET cur_size = value(grp_id_cnt)
   SET batch_cnt = ceil((cnvtreal(cur_size)/ batch_sz))
   SET new_size = (batch_cnt * batch_sz)
   SET act_cnt = 0
   SET stat = alterlist(tmp_grp_id->activity_qual,new_size)
   FOR (tmp_idx = (cur_size+ 1) TO new_size)
    SET tmp_grp_id->activity_qual[tmp_idx].shx_activity_group_id = tmp_grp_id->activity_qual[cur_size
    ].shx_activity_group_id
    SET tmp_grp_id->activity_qual[tmp_idx].shx_category_ref_id = tmp_grp_id->activity_qual[cur_size].
    shx_category_ref_id
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(batch_cnt)),
     shx_comment sc,
     long_text lt,
     prsnl p
    PLAN (d1
     WHERE initarray(start_xp,evaluate(d1.seq,1,1,(start_xp+ batch_sz))))
     JOIN (sc
     WHERE expand(idx_xp,start_xp,(start_xp+ (batch_sz - 1)),sc.shx_activity_group_id,tmp_grp_id->
      activity_qual[idx_xp].shx_activity_group_id))
     JOIN (lt
     WHERE lt.long_text_id=sc.long_text_id)
     JOIN (p
     WHERE p.person_id=sc.comment_prsnl_id)
    ORDER BY sc.shx_activity_group_id, sc.comment_dt_tm DESC
    HEAD REPORT
     act_cnt = 0
    HEAD sc.shx_activity_group_id
     locat_cat = 0, locat_act = 0, locat_ref = 0,
     locat_ref = locateval(tmp_idx,1,size(tmp_grp_id->activity_qual,5),sc.shx_activity_group_id,
      tmp_grp_id->activity_qual[tmp_idx].shx_activity_group_id)
     IF (locat_ref > 0)
      locat_cat = locateval(tmp_idx,1,cat_cnt,tmp_grp_id->activity_qual[locat_ref].
       shx_category_ref_id,temp->sl[xx].il[yy].social_cat_list[tmp_idx].shx_cat_ref_id)
     ENDIF
     IF (locat_cat > 0)
      detail_sz = size(temp->sl[xx].il[yy].social_cat_list[locat_cat].detail_list,5), locat_act =
      locateval(tmp_idx,1,detail_sz,sc.shx_activity_group_id,temp->sl[xx].il[yy].social_cat_list[
       locat_cat].detail_list[tmp_idx].shx_activity_grp_id)
     ENDIF
     cmnt_cnt = 0
    DETAIL
     IF (locat_cat > 0
      AND locat_act > 0)
      cmnt_cnt += 1, stat = alterlist(temp->sl[xx].il[yy].social_cat_list[locat_cat].detail_list[
       locat_act].comments,cmnt_cnt), temp->sl[xx].il[yy].social_cat_list[locat_cat].detail_list[
      locat_act].comments[cmnt_cnt].comment = trim(lt.long_text),
      temp->sl[xx].il[yy].social_cat_list[locat_cat].detail_list[locat_act].comments[cmnt_cnt].
      comment_prsnl = trim(p.name_full_formatted), date_temp->dt1 = cnvtdatetime(sc.comment_dt_tm),
      temp->sl[xx].il[yy].social_cat_list[locat_cat].detail_list[locat_act].comments[cmnt_cnt].
      comment_dt_tm = trim(formatdatetime(sc.comment_dt_tm_tz," "))
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE get_prsnl_position_cd(null)
   CALL echo("Entering GET_PRSNL_POSITION_CD.")
   SET stat = getcurrentposition(null)
   IF (stat)
    SET position_cd = sac_cur_pos_rep->position_cd
   ELSE
    CALL echo(build("Current position lookup failed with status ",sac_cur_pos_rep->status_data.status
      ))
   ENDIF
   SET temp->prsnl_position_cd = p.position_cd
   IF (curqual=0)
    CALL echo(build("Looking up position_cd for the prsnl failed in get_psnl_position_cd."))
    SET cfailed = "T"
    RETURN
   ENDIF
   CALL echo(build("Leaving GET_PRSNL_POSITION_CD"))
 END ;Subroutine
 SUBROUTINE (get_problemdx_result(xx=i4,yy=i4) =null)
   CALL echo(build("entering problem list"))
   DECLARE problem_cnt = i4 WITH protect, noconstant(0)
   DECLARE problem_recorder_cd = f8 WITH constant(uar_get_code_by("MEANING",12038,"RECORDER"))
   DECLARE locateidx = i4 WITH protect, noconstant(0)
   DECLARE problemidx = i4 WITH protect, noconstant(0)
   SET temp->sl[xx].il[yy].problem_list_restricted_ind = 0
   SELECT INTO "nl:"
    pr.person_id, pr.nomenclature_id
    FROM problem pr,
     problem_prsnl_r ppr,
     nomenclature n,
     prsnl prp
    PLAN (pr
     WHERE pr.person_id=person_id
      AND pr.active_ind=1
      AND pr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND ((pr.end_effective_dt_tm >= cnvtdatetime(sysdate)) OR (pr.end_effective_dt_tm=null)) )
     JOIN (n
     WHERE n.nomenclature_id=pr.nomenclature_id)
     JOIN (ppr
     WHERE (ppr.problem_id= Outerjoin(pr.problem_id))
      AND (ppr.problem_reltn_cd= Outerjoin(problem_recorder_cd)) )
     JOIN (prp
     WHERE (prp.person_id= Outerjoin(ppr.problem_reltn_prsnl_id)) )
    ORDER BY pr.problem_id
    HEAD pr.problem_id
     locateidx = locateval(problemidx,1,size(user_sec_organizations->qual,5),pr.organization_id,
      user_sec_organizations->qual[problemidx].organization_id)
     IF ((((org_sec_map->restrict_ind=0)) OR (((orgsecoverrideind != 0) OR (locateidx > 0)) )) )
      problem_cnt += 1, temp->sl[xx].ind = 1
      IF (size(temp->sl[xx].il[yy].problem_list,5) < problem_cnt)
       stat = alterlist(temp->sl[xx].il[yy].problem_list,(problem_cnt+ 5))
      ENDIF
      IF (pr.annotated_display > " ")
       temp->sl[xx].il[yy].problem_list[problem_cnt].problem_desc = trim(pr.annotated_display)
      ELSEIF (pr.problem_ftdesc > " ")
       temp->sl[xx].il[yy].problem_list[problem_cnt].problem_desc = trim(pr.problem_ftdesc)
      ELSEIF (n.source_string > " ")
       temp->sl[xx].il[yy].problem_list[problem_cnt].problem_desc = trim(n.source_string)
      ENDIF
      temp->sl[xx].il[yy].problem_list[problem_cnt].onset_dt_tm = cnvtdatetime(pr.onset_dt_tm), temp
      ->sl[xx].il[yy].problem_list[problem_cnt].onset_dt_flag = pr.onset_dt_flag, temp->sl[xx].il[yy]
      .problem_list[problem_cnt].problem_recorder = trim(prp.name_full_formatted),
      temp->sl[xx].il[yy].problem_list[problem_cnt].problem_onset_tz = pr.onset_tz, temp->sl[xx].il[
      yy].problem_list[problem_cnt].qualifier_cd = pr.qualifier_cd, temp->sl[xx].il[yy].problem_list[
      problem_cnt].qualifier_disp = uar_get_code_display(pr.qualifier_cd),
      temp->sl[xx].il[yy].problem_list[problem_cnt].confirmation_cd = pr.confirmation_status_cd, temp
      ->sl[xx].il[yy].problem_list[problem_cnt].confirmation_disp = uar_get_code_display(pr
       .confirmation_status_cd), temp->sl[xx].il[yy].problem_list[problem_cnt].problem_status_disp =
      uar_get_code_display(pr.life_cycle_status_cd)
     ELSE
      temp->sl[xx].il[yy].problem_list_restricted_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   SET stat = alterlist(temp->sl[xx].il[yy].problem_list,problem_cnt)
   FOR (prob_index = 1 TO problem_cnt)
    SET date_temp->dt1 = temp->sl[xx].il[yy].problem_list[prob_index].onset_dt_tm
    IF ((temp->sl[xx].il[yy].problem_list[prob_index].onset_dt_flag=1))
     SET temp->sl[xx].il[yy].problem_list[prob_index].onset_dt_tm_str = concat(build(month(
        cnvtdatetime(date_temp->dt1))),"/",build(year(cnvtdatetime(date_temp->dt1))))
    ELSEIF ((temp->sl[xx].il[yy].problem_list[prob_index].onset_dt_flag=2))
     SET temp->sl[xx].il[yy].problem_list[prob_index].onset_dt_tm_str = build(year(cnvtdatetime(
        date_temp->dt1)))
    ELSE
     SET temp->sl[xx].il[yy].problem_list[prob_index].onset_dt_tm_str = formatdateonly(temp->sl[xx].
      il[yy].problem_list[prob_index].problem_onset_tz," ")
    ENDIF
   ENDFOR
   DECLARE dx_cnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM diagnosis dx,
     nomenclature n
    PLAN (dx
     WHERE dx.person_id=person_id
      AND (dx.encntr_id=temp->encntr_id)
      AND dx.active_ind=1
      AND  NOT (dx.contributor_system_cd IN (3m, 3m_aus, 3m_can, kodip, profile))
      AND dx.diagnosis_group > 0.0
      AND dx.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND ((dx.end_effective_dt_tm >= cnvtdatetime(sysdate)) OR (dx.end_effective_dt_tm=null)) )
     JOIN (n
     WHERE n.nomenclature_id=dx.nomenclature_id)
    ORDER BY dx.diagnosis_id
    HEAD dx.diagnosis_id
     dx_cnt += 1, temp->sl[xx].ind = 1
     IF (size(temp->sl[xx].il[yy].diagnosis,5) < dx_cnt)
      stat = alterlist(temp->sl[xx].il[yy].diagnosis,(dx_cnt+ 5))
     ENDIF
     IF (dx.diagnosis_display > " ")
      temp->sl[xx].il[yy].diagnosis[dx_cnt].diagnosis_desc = trim(dx.diagnosis_display)
     ELSEIF (dx.diag_ftdesc > " ")
      temp->sl[xx].il[yy].diagnosis[dx_cnt].diagnosis_desc = dx.diag_ftdesc
     ELSEIF (n.source_string > " ")
      temp->sl[xx].il[yy].diagnosis[dx_cnt].diagnosis_desc = n.source_string
     ENDIF
     temp->sl[xx].il[yy].diagnosis[dx_cnt].diagnosis_onset_dt = cnvtdatetime(dx.diag_dt_tm), temp->
     sl[xx].il[yy].diagnosis[dx_cnt].diagnosis_type_cd = dx.diag_type_cd, temp->sl[xx].il[yy].
     diagnosis[dx_cnt].diagnosis_type_disp = uar_get_code_display(dx.diag_type_cd),
     temp->sl[xx].il[yy].diagnosis[dx_cnt].diagnosis_qualifier_cd = dx.conditional_qual_cd, temp->sl[
     xx].il[yy].diagnosis[dx_cnt].diagnosis_qualifier_disp = uar_get_code_display(dx
      .conditional_qual_cd), temp->sl[xx].il[yy].diagnosis[dx_cnt].diagnosis_confirmation_cd = dx
     .confirmation_status_cd,
     temp->sl[xx].il[yy].diagnosis[dx_cnt].diagnosis_confirmation_disp = uar_get_code_display(dx
      .confirmation_status_cd)
    WITH nocounter
   ;end select
   SET stat = alterlist(temp->sl[xx].il[yy].diagnosis,dx_cnt)
   FOR (dx_index = 1 TO dx_cnt)
     SET date_temp->dt1 = temp->sl[xx].il[yy].diagnosis[dx_index].diagnosis_onset_dt
     CALL formatdate(0)
     SET temp->sl[xx].il[yy].diagnosis[dx_index].diagnosis_onset_dtstr = trim(date_utc_str)
   ENDFOR
   CALL echo(build("ending Problem List"))
 END ;Subroutine
 SUBROUTINE (formatdate(time_zone=i4) =vc)
  IF (((time_zone_ind=0) OR (curutc=0)) )
   SET date_utc_str = concat(format(date_temp->dt1,"@SHORTDATE;;Q"))
  ELSE
   SET date_utc_str = concat(trim(datetimezoneformat(date_temp->dt1,time_zone,"@SHORTDATE")))
  ENDIF
  RETURN(date_utc_str)
 END ;Subroutine
 SUBROUTINE get_gestational_result(xx,yy)
   DECLARE gest_cnt = i4 WITH noconstant(0)
   SELECT INTO "nl:"
    pp.gest_age_at_birth
    FROM person_patient pp
    WHERE pp.person_id=person_id
     AND pp.active_ind=1
    DETAIL
     gest_cnt += 1, temp->sl[xx].ind = 1
     IF (size(temp->sl[xx].il[yy].gestational,5) < gest_cnt)
      stat = alterlist(temp->sl[xx].il[yy].gestational,(gest_cnt+ 1))
     ENDIF
     temp->sl[xx].il[yy].gestational[gest_cnt].gest_age_at_birth_week = (pp.gest_age_at_birth/ 7),
     temp->sl[xx].il[yy].gestational[gest_cnt].gest_age_at_birth_days = mod(pp.gest_age_at_birth,7),
     temp->sl[xx].il[yy].gestational[gest_cnt].gest_age_method = uar_get_code_display(pp
      .gest_age_method_cd)
    WITH nocounter
   ;end select
   SET temp->sl[xx].il[yy].gestational[gest_cnt].gest_age_concat = concat(build(temp->sl[xx].il[yy].
     gestational[gest_cnt].gest_age_at_birth_week,"weeks")," ",build(temp->sl[xx].il[yy].gestational[
     gest_cnt].gest_age_at_birth_days,"days"))
   SET gest_cnt = 0
   DECLARE gest_comment_cd = f8 WITH constant(uar_get_code_by("MEANING",355,"GESTCOMMENT"))
   SELECT INTO "nl:"
    pi.long_text_id
    FROM person_info pi,
     long_text l
    PLAN (pi
     WHERE pi.person_id=person_id
      AND pi.info_type_cd=gest_comment_cd
      AND pi.active_ind=1)
     JOIN (l
     WHERE l.long_text_id=pi.long_text_id)
    DETAIL
     gest_cnt += 1, temp->sl[xx].ind = 1
     IF (size(temp->sl[xx].il[yy].gestational,5) < gest_cnt)
      stat = alterlist(temp->sl[xx].il[yy].gestational,(gest_cnt+ 1))
     ENDIF
     temp->sl[xx].il[yy].gestational[gest_cnt].gest_comment = l.long_text
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE (get_encounter_info(xx=i4,yy=i4) =null)
   DECLARE enc_cnt = i4 WITH noconstant(0)
   DECLARE num = i4 WITH noconstant(0)
   DECLARE start = i4 WITH noconstant(1)
   DECLARE pos = i4
   DECLARE encntr_comment_cd = f8 WITH constant(uar_get_code_by("MEANING",355,"GESTCOMMENT"))
   SELECT INTO "nl:"
    ei.long_text_id
    FROM encntr_info ei,
     long_text l
    PLAN (ei
     WHERE (ei.encntr_id=temp->encntr_id)
      AND ei.info_type_cd=encntr_comment_cd
      AND ei.active_ind=1)
     JOIN (l
     WHERE l.long_text_id=ei.long_text_id)
    DETAIL
     enc_cnt += 1, temp->sl[xx].ind = 1
     IF (size(temp->sl[xx].il[yy].tracking_cmt,5) < enc_cnt)
      stat = alterlist(temp->sl[xx].il[yy].tracking_cmt,(enc_cnt+ 1))
     ENDIF
     pos = locateval(num,start,size(temp->sl[xx].il[yy].tracking_cmt,5),ei.internal_seq,temp->sl[xx].
      il[yy].tracking_cmt[num].comment_seq)
     IF ((temp->sl[xx].il[yy].tracking_cmt[pos].comment_visible=1))
      temp->sl[xx].il[yy].tracking_cmt[pos].tracking_comment = l.long_text
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE checkfororgsecurity(null)
   DECLARE chidx = i2 WITH noconstant(0)
   DECLARE idx = i4 WITH protect, noconstant(0)
   IF ((reqinfo->updt_id=0))
    SET org_sec_map->restrict_ind = 0
   ENDIF
   IF ((org_sec_map->restrict_ind != 0)
    AND locateval(idx,1,size(org_sec_map->patient_prsnl_list,5),temp->person_id,org_sec_map->
    patient_prsnl_list[idx].person_id,
    reqinfo->updt_id,org_sec_map->patient_prsnl_list[idx].prsnl_id) <= 0)
    SET modify = nopredeclare
    EXECUTE dcp_gen_valid_encounters_recs
    SET modify = predeclare
    SET gve_request->prsnl_id = reqinfo->updt_id
    SET gve_request->force_encntrs_ind = 0
    SET stat = alterlist(gve_request->persons,size(temp->person_id,5))
    FOR (chidx = 1 TO size(temp->person_id,5))
      SET gve_request->persons[chidx].person_id = temp->person_id
    ENDFOR
    SET modify = nopredeclare
    EXECUTE dcp_get_valid_encounters  WITH replace("REQUEST",gve_request), replace("REPLY",gve_reply)
    SET modify = predeclare
    IF ((gve_reply->status_data.status="F"))
     CALL echo("*Failed - dcp_get_valid_encounters in DCP_GET_FORMS_ACTIVITY_PRT*")
     SET failure_ind = 1
     GO TO exit_script
    ENDIF
    CALL populateorgsecuritymap(null)
   ENDIF
   CALL populatepersonencounters(temp->person_id,reqinfo->updt_id)
 END ;Subroutine
 SUBROUTINE populateorgsecuritymap(null)
   DECLARE i = i4 WITH protect, noconstant(0)
   DECLARE j = i4 WITH protect, noconstant(0)
   DECLARE map_size = i4 WITH protect, noconstant(size(org_sec_map->patient_prsnl_list,5))
   SET org_sec_map->restrict_ind = gve_reply->restrict_ind
   SET stat = alterlist(org_sec_map->patient_prsnl_list,(map_size+ size(gve_reply->persons,5)))
   FOR (i = 1 TO size(gve_reply->persons,5))
     SET org_sec_map->patient_prsnl_list[(map_size+ i)].person_id = gve_reply->persons[i].person_id
     SET org_sec_map->patient_prsnl_list[(map_size+ i)].restrict_ind = gve_reply->persons[i].
     restrict_ind
     SET org_sec_map->patient_prsnl_list[(map_size+ i)].prsnl_id = reqinfo->updt_id
     SET stat = alterlist(org_sec_map->patient_prsnl_list[(map_size+ i)].encntrs,size(gve_reply->
       persons[i].encntrs,5))
     FOR (j = 1 TO size(gve_reply->persons[i].encntrs,5))
       SET org_sec_map->patient_prsnl_list[(map_size+ i)].encntrs[j].encntr_id = gve_reply->persons[i
       ].encntrs[j].encntr_id
     ENDFOR
   ENDFOR
 END ;Subroutine
 SUBROUTINE (populatepersonencounters(person_id=f8,prsnl_id=f8) =null)
   DECLARE i = i4 WITH protect, noconstant(0)
   DECLARE pos = i4 WITH protect, noconstant(0)
   IF ((org_sec_map->restrict_ind=0))
    RETURN
   ENDIF
   SET pos = locateval(i,1,size(org_sec_map->patient_prsnl_list,5),person_id,org_sec_map->
    patient_prsnl_list[i].person_id,
    prsnl_id,org_sec_map->patient_prsnl_list[i].prsnl_id)
   IF (pos > 0)
    SET stat = alterlist(person_org_sec_map->encntrs,size(org_sec_map->patient_prsnl_list[pos].
      encntrs,5))
    FOR (i = 1 TO size(org_sec_map->patient_prsnl_list[pos].encntrs,5))
      SET person_org_sec_map->encntrs[i].encntr_id = org_sec_map->patient_prsnl_list[pos].encntrs[i].
      encntr_id
    ENDFOR
   ELSE
    CALL echo("***FAILURE***Person/Prsnl relationship not found in the map.")
    SET failure_ind = 1
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE getuserorganizations(null)
   DECLARE org_cnt = i2 WITH noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (validate(sac_org)=1)
    FREE RECORD sac_org
   ENDIF
   SET modify = nopredeclare
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
   SET modify = predeclare
   SET org_cnt = size(sac_org->organizations,5)
   SET stat = alterlist(user_sec_organizations->qual,(org_cnt+ 1))
   FOR (count = 1 TO org_cnt)
     SET user_sec_organizations->qual[count].organization_id = sac_org->organizations[count].
     organization_id
   ENDFOR
   SET user_sec_organizations->qual[(org_cnt+ 1)].organization_id = 0
 END ;Subroutine
 SUBROUTINE checkukorgsecutiryshx(null)
   DECLARE ilogontype = i2 WITH protect, noconstant(0)
   DECLARE shxsecurityind = i2 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM dm_info d1,
     dm_info d2
    WHERE d1.info_domain="SECURITY"
     AND d1.info_name="SEC_ORG_RELTN"
     AND d1.info_number=1
     AND d2.info_domain="SECURITY"
     AND d2.info_name="SEC_SOC_HIST_ORG_RELTN"
     AND d2.info_number=1
    DETAIL
     shxsecurityind = 1
    WITH nocounter
   ;end select
   SET modify = nopredeclare
   EXECUTE sacrtl
   SET modify = predeclare
   SET ilogontype = uar_sacgetuserlogontype()
   IF (ilogontype=1
    AND shxsecurityind=1)
    SET userlogontypenhsind = 1
   ENDIF
   CALL echo(build("UserLogontypeNHSInd:",userlogontypenhsind))
 END ;Subroutine
 SUBROUTINE checkmedlistorgsec(null)
   DECLARE sprefname = c27 WITH protect, constant("MED_LIST_APPLY_ORG_SECURITY")
   DECLARE iprefappvalue = i2 WITH protect, noconstant(- (1))
   DECLARE iprefposvalue = i2 WITH protect, noconstant(- (1))
   DECLARE iprefuservalue = i2 WITH protect, noconstant(- (1))
   DECLARE iprefvalue = i2 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM app_prefs ap,
     name_value_prefs nvp
    PLAN (ap
     WHERE (ap.application_number=reqinfo->updt_app)
      AND ap.position_cd IN (reqinfo->position_cd, 0.0)
      AND ap.prsnl_id IN (reqinfo->updt_id, 0.0)
      AND ap.active_ind=1)
     JOIN (nvp
     WHERE ap.app_prefs_id=nvp.parent_entity_id
      AND nvp.parent_entity_name="APP_PREFS"
      AND nvp.pvc_name=sprefname
      AND nvp.active_ind=1)
    HEAD nvp.pvc_name
     iprefappvalue = - (1), iprefposvalue = - (1), iprefuservalue = - (1)
    DETAIL
     IF (ap.prsnl_id > 0.0)
      iprefuservalue = cnvtint(trim(nvp.pvc_value))
     ELSEIF (ap.position_cd > 0.0)
      iprefposvalue = cnvtint(trim(nvp.pvc_value))
     ELSE
      iprefappvalue = cnvtint(trim(nvp.pvc_value))
     ENDIF
    FOOT  nvp.pvc_name
     IF ((iprefuservalue != - (1)))
      iprefvalue = iprefuservalue
     ELSEIF ((iprefposvalue != - (1)))
      iprefvalue = iprefposvalue
     ELSE
      iprefvalue = iprefappvalue
     ENDIF
    WITH nocounter
   ;end select
   IF (iprefvalue=1)
    SET medlistorgsecind = 1
   ENDIF
 END ;Subroutine
 SUBROUTINE checkmedlistencntrfilter(null)
   DECLARE sprefname = c22 WITH protect, constant("MED_LIST_ENCNTR_FILTER")
   DECLARE iprefappvalue = i2 WITH protect, noconstant(- (1))
   DECLARE iprefposvalue = i2 WITH protect, noconstant(- (1))
   DECLARE iprefuservalue = i2 WITH protect, noconstant(- (1))
   DECLARE iprefvalue = i2 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM app_prefs ap,
     name_value_prefs nvp
    PLAN (ap
     WHERE (ap.application_number=reqinfo->updt_app)
      AND ap.position_cd IN (reqinfo->position_cd, 0.0)
      AND ap.prsnl_id IN (reqinfo->updt_id, 0.0)
      AND ap.active_ind=1)
     JOIN (nvp
     WHERE ap.app_prefs_id=nvp.parent_entity_id
      AND nvp.parent_entity_name="APP_PREFS"
      AND nvp.pvc_name=sprefname
      AND nvp.active_ind=1)
    HEAD nvp.pvc_name
     iprefappvalue = - (1), iprefposvalue = - (1), iprefuservalue = - (1)
    DETAIL
     IF (ap.prsnl_id > 0.0
      AND nvp.pvc_value="FOCUS")
      iprefuservalue = 1
     ELSEIF (ap.position_cd > 0.0
      AND nvp.pvc_value="FOCUS")
      iprefposvalue = 1
     ELSEIF (nvp.pvc_value="FOCUS")
      iprefappvalue = 1
     ENDIF
    FOOT  nvp.pvc_name
     IF ((iprefuservalue != - (1)))
      iprefvalue = iprefuservalue
     ELSEIF ((iprefposvalue != - (1)))
      iprefvalue = iprefposvalue
     ELSE
      iprefvalue = iprefappvalue
     ENDIF
    WITH nocounter
   ;end select
   IF (iprefvalue=1)
    SET medlistencntrfilterind = 1
   ENDIF
 END ;Subroutine
 SUBROUTINE checkoverrideind(null)
   DECLARE dcp_task_pco_get_prsnl_override = i4 WITH protect, constant(961010)
   DECLARE dcp_request_pco_get_prsnl_override = i4 WITH protect, constant(969696)
   DECLARE dcp_appl_pco_get_prsnl_override = i4 WITH constant(600005), protect
   DECLARE happ_prsnloverride = i4 WITH noconstant(0), protect
   DECLARE htask_prsnloverride = i4 WITH noconstant(0), protect
   DECLARE hstep_prsnloverride = i4 WITH noconstant(0), protect
   DECLARE hrequest_prsnloverride = i4 WITH noconstant(0), protect
   DECLARE hreply_prsnloverride = i4 WITH noconstant(0), protect
   DECLARE irtn = i4 WITH noconstant(0), protect
   DECLARE person_id1 = f8 WITH noconstant(0), protect
   SET irtn = uar_crmbeginapp(dcp_appl_pco_get_prsnl_override,happ_prsnloverride)
   IF (irtn != 0)
    CALL echo("Unable to create an application handle for PCO_GET_PRSNL_OVERRIDE")
    SET failure_ind = 1
    GO TO exit_script
   ENDIF
   SET irtn = uar_crmbegintask(happ_prsnloverride,dcp_task_pco_get_prsnl_override,htask_prsnloverride
    )
   IF (irtn != 0)
    CALL echo("uar_crm_begin_task failed in PCO_GET_PRSNL_OVERRIDE")
    SET failure_ind = 1
    GO TO exit_script
   ENDIF
   SET irtn = uar_crmbeginreq(htask_prsnloverride,"",dcp_request_pco_get_prsnl_override,
    hstep_prsnloverride)
   IF (irtn != 0)
    CALL echo("uar_crm_begin_Request failed in PCO_GET_PRSNL_OVERRIDE")
    SET failure_ind = 1
    GO TO exit_script
   ENDIF
   SET hrequest_prsnloverride = uar_crmgetrequest(hstep_prsnloverride)
   IF (hrequest_prsnloverride <= 0)
    CALL echo("Unable to perform the request")
    SET failure_ind = 1
    GO TO exit_script
   ENDIF
   SET person_id1 = person_id
   SET stat = uar_srvsetdouble(hrequest_prsnloverride,"prsnl_id",reqinfo->updt_id)
   SET stat = uar_srvsetdouble(hrequest_prsnloverride,"person_id",person_id1)
   IF (uar_crmperform(hstep_prsnloverride) != 0)
    CALL echo("Unable to perform the request PCO_GET_PRSNL_OVERRIDEor ")
    SET failure_ind = 1
    GO TO exit_script
   ENDIF
   SET hreply = uar_crmgetreply(hstep_prsnloverride)
   IF (hreply <= 0)
    CALL echo("Unable to obtain the reply for PCO_GET_PRSNL_OVERRIDE")
    SET failure_ind = 1
    GO TO exit_script
   ENDIF
   SET orgsecoverrideind = uar_srvgetshort(hreply,"OVERRIDE_IND")
   CALL echo(build("Org Sec OverrideInd:",orgsecoverrideind))
   CALL cleanup(happ_prsnloverride,htask_prsnloverride,hstep_prsnloverride)
 END ;Subroutine
 SUBROUTINE (get_communication_preference(xx=i4,yy=i4) =null)
   DECLARE no_pref_contact_method_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",23042,
     "NOPREFERENCE"))
   DECLARE letter_contact_method_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",23042,
     "LETTER"))
   DECLARE telephone_contact_method_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",23042,
     "TELEPHONE"))
   DECLARE patient_portal_contact_method_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",
     23042,"PATPORTAL"))
   DECLARE email_contact_method_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",23042,
     "EMAIL"))
   DECLARE external_secure_phone_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",43,
     "EXTSECEMAIL"))
   DECLARE email_phone_contact_method_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",23056,
     "MAILTO"))
   DECLARE count = i4 WITH noconstant(0), protect
   SELECT INTO "nl:"
    FROM person_patient pp
    WHERE (pp.person_id=temp->person_id)
    DETAIL
     IF (pp.contact_method_cd > 0
      AND ((pp.contact_method_cd=no_pref_contact_method_cd) OR (((pp.contact_method_cd=
     letter_contact_method_cd) OR (((pp.contact_method_cd=telephone_contact_method_cd) OR (((pp
     .contact_method_cd=patient_portal_contact_method_cd) OR (pp.contact_method_cd=
     email_contact_method_cd)) )) )) )) )
      temp->sl[xx].ind = 1, count += 1
      IF (count > size(temp->sl[xx].il[yy].comm_pref_list,5))
       stat = alterlist(temp->sl[xx].il[yy].comm_pref_list,count)
      ENDIF
      temp->sl[xx].il[yy].comm_pref_list[count].contact_method_cd = pp.contact_method_cd
     ENDIF
    WITH nocounter
   ;end select
   FOR (tmp_idx = 1 TO count)
     IF ((temp->sl[xx].il[yy].comm_pref_list[tmp_idx].contact_method_cd=email_contact_method_cd))
      SELECT INTO "nl:"
       FROM phone ph
       WHERE (ph.parent_entity_id=temp->person_id)
        AND ph.parent_entity_name="PERSON_PATIENT"
        AND ph.phone_type_cd=external_secure_phone_type_cd
        AND ph.contact_method_cd=email_phone_contact_method_cd
        AND ph.active_ind=1
        AND ph.beg_effective_dt_tm <= cnvtdatetime(sysdate)
        AND ph.end_effective_dt_tm > cnvtdatetime(sysdate)
       DETAIL
        temp->sl[xx].il[yy].comm_pref_list[tmp_idx].secure_email = trim(ph.phone_num)
       WITH nocounter
      ;end select
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE (cleanup(happ=i4,htsk=i4,hreq=i4) =null)
   CALL echo("Enter CleanUp")
   IF (hreq)
    CALL uar_crmendreq(hreq)
   ENDIF
   IF (htsk)
    CALL uar_crmendtask(htsk)
   ENDIF
   IF (happ)
    CALL uar_crmendapp(happ)
   ENDIF
   CALL echo("Exit CleanUp")
 END ;Subroutine
 SUBROUTINE getauthcontributorsystems(null)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE preffound = i2 WITH protect, noconstant(0)
   DECLARE syscnt = i4 WITH protect, noconstant(0)
   DECLARE appcontribsyscnt = i4 WITH protect, noconstant(0)
   DECLARE getappprefs = i2 WITH protect, noconstant(0)
   DECLARE poscontribsyscnt = i4 WITH protect, noconstant(0)
   DECLARE getposprefs = i2 WITH protect, noconstant(0)
   DECLARE usercontribsyscnt = i4 WITH protect, noconstant(0)
   DECLARE getuserprefs = i2 WITH protect, noconstant(0)
   DECLARE nindex = i4 WITH protect, noconstant(0)
   DECLARE prochist = vc WITH protect, constant("PROCHIST")
   SELECT INTO "nl:"
    FROM detail_prefs dp,
     name_value_prefs nvp
    PLAN (dp
     WHERE dp.prsnl_id IN (0.0, personnelid)
      AND dp.position_cd IN (0.0, position_cd)
      AND dp.application_number=application_num
      AND dp.view_name=prochist
      AND dp.comp_name=prochist
      AND dp.active_ind > 0)
     JOIN (nvp
     WHERE nvp.parent_entity_id=dp.detail_prefs_id
      AND nvp.parent_entity_name="DETAIL_PREFS"
      AND nvp.pvc_name="PROCEDURES_ContributorSysListCnt"
      AND nvp.active_ind > 0)
    DETAIL
     IF (dp.prsnl_id=0.0
      AND dp.position_cd=0.0)
      appcontribsyscnt = cnvtint(nvp.pvc_value)
     ELSEIF (dp.prsnl_id=0.0
      AND dp.position_cd=position_cd)
      poscontribsyscnt = cnvtint(nvp.pvc_value)
     ELSEIF (dp.prsnl_id=personnelid
      AND dp.position_cd=0.0)
      usercontribsyscnt = cnvtint(nvp.pvc_value)
     ENDIF
    WITH nocounter
   ;end select
   IF (usercontribsyscnt > 0)
    SET getuserprefs = 1
   ELSEIF (poscontribsyscnt > 0)
    SET getposprefs = 1
   ELSEIF (appcontribsyscnt > 0)
    SET getappprefs = 1
   ENDIF
   SELECT INTO "nl:"
    sort = cnvtint(replace(nvp.pvc_name,"PROCEDURES_CONTRIBUTOR_SYSTEMS",""))
    FROM detail_prefs dp,
     name_value_prefs nvp
    PLAN (dp
     WHERE dp.prsnl_id IN (0.0, personnelid)
      AND dp.position_cd IN (0.0, position_cd)
      AND dp.application_number=application_num
      AND dp.view_name=prochist
      AND dp.comp_name=prochist
      AND dp.active_ind > 0)
     JOIN (nvp
     WHERE nvp.parent_entity_id=dp.detail_prefs_id
      AND nvp.parent_entity_name="DETAIL_PREFS"
      AND nvp.pvc_name="PROCEDURES_CONTRIBUTOR_SYSTEMS*"
      AND nvp.active_ind > 0)
    ORDER BY sort, dp.prsnl_id DESC, dp.position_cd DESC
    HEAD REPORT
     syscnt = 0
    HEAD sort
     syscnt += 1
     IF (mod(syscnt,10)=1)
      stat = alterlist(con_sys->systems,(syscnt+ 9))
     ENDIF
     IF (getuserprefs
      AND syscnt <= usercontribsyscnt)
      con_sys->system_cnt = syscnt
     ELSEIF (getposprefs
      AND syscnt <= poscontribsyscnt)
      con_sys->system_cnt = syscnt
     ELSEIF (getappprefs
      AND syscnt <= appcontribsyscnt)
      con_sys->system_cnt = syscnt
     ENDIF
    DETAIL
     IF (getuserprefs
      AND syscnt <= usercontribsyscnt
      AND (con_sys->systems[syscnt].system_code=0.0))
      con_sys->systems[syscnt].system_code = cnvtreal(nvp.pvc_value)
     ELSEIF (getposprefs
      AND syscnt <= poscontribsyscnt
      AND dp.prsnl_id=0.0
      AND (con_sys->systems[syscnt].system_code=0.0))
      con_sys->systems[syscnt].system_code = cnvtreal(nvp.pvc_value)
     ELSEIF (getappprefs
      AND syscnt <= appcontribsyscnt
      AND dp.prsnl_id=0.0
      AND dp.position_cd=0.0)
      con_sys->systems[syscnt].system_code = cnvtreal(nvp.pvc_value)
     ENDIF
    WITH nocounter
   ;end select
   SET stat = alterlist(con_sys->systems,con_sys->system_cnt)
   IF (locateval(nindex,1,con_sys->system_cnt,power_chart,con_sys->systems[nindex].system_code) <= 0)
    SET con_sys->system_cnt += 1
    SET stat = alterlist(con_sys->systems,con_sys->system_cnt)
    SET con_sys->systems[con_sys->system_cnt].system_code = power_chart
   ENDIF
   SET con_sys->system_cnt += 1
   SET stat = alterlist(con_sys->systems,con_sys->system_cnt)
   SET con_sys->systems[con_sys->system_cnt].system_code = 0.0
 END ;Subroutine
 SET modify = nopredeclare
END GO
