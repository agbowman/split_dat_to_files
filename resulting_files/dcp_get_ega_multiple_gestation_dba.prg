CREATE PROGRAM dcp_get_ega_multiple_gestation:dba
 SET modify = predeclare
 FREE RECORD reply
 RECORD reply(
   1 multiple_gest_ind = i2
   1 partial_delivery_ind = i2
   1 latest_delivery_date = dq8
   1 dynamic_label[*]
     2 label_name = vc
     2 gest_age_at_delivery = i4
     2 delivery_date = dq8
     2 delivery_date_tz = i4
     2 dynamic_label_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH persistscript
 FREE RECORD docsetreply
 RECORD docsetreply(
   1 label_list[*]
     2 dynamic_label_id = f8
     2 label_name = vc
     2 result_set_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD eventsetsreply
 RECORD eventsetsreply(
   1 concepts[*]
     2 concept_cki = vc
     2 event_sets[*]
       3 event_set_cd = f8
       3 event_set_cd_disp = vc
       3 event_set_name = vc
       3 event_codes[*]
         4 event_cd = f8
         4 event_cd_disp = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD tempdate
 RECORD tempdate(
   1 date = dq8
 )
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
 SUBROUTINE (reportfailure(opname=vc,opstatus=vc,targetname=vc,targetvalue=vc) =null)
  SET reply->status_data.status = "F"
  CALL fillsubeventstatus(opname,opstatus,targetname,targetvalue)
 END ;Subroutine
 SUBROUTINE (fillsubeventstatus(opname=vc,opstatus=vc,objname=vc,objvalue=vc) =null)
   DECLARE dcp_substatus_cnt = i4 WITH protect, noconstant(size(reply->status_data.subeventstatus,5))
   SET dcp_substatus_cnt += 1
   IF (dcp_substatus_cnt != 1)
    SET stat = alter(reply->status_data.subeventstatus,dcp_substatus_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].operationname = trim(opname)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].targetobjectname = trim(objname)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].targetobjectvalue = trim(objvalue)
 END ;Subroutine
 DECLARE lreplyidx = i4 WITH protect, noconstant(1)
 DECLARE error_msg = vc WITH protect, noconstant("")
 DECLARE failure_ind = i2 WITH protect, noconstant(false)
 DECLARE sdocsetname = vc WITH protect, noconstant("")
 DECLARE lrequestnum = i4 WITH protect, constant(3200264)
 DECLARE zero_ind = i2 WITH protect, noconstant(false)
 DECLARE error_code = i2 WITH protect, noconstant(0)
 DECLARE concept_cki = vc WITH protect, constant("CERNER!ASYr9AEYvUr1YoPTCqIGfQ")
 DECLARE docset_pref = vc WITH protect, constant("fetus dynamic label docsets")
 DECLARE getpregnancyprefs(null) = null WITH protect
 DECLARE getlabelidsbydocsetref(null) = null WITH protect
 DECLARE geteventsetsbyconcept(null) = null WITH protect
 DECLARE getresultsbylabelid(null) = null WITH protect
 CALL getpregnancyprefs(null)
 SUBROUTINE getlabelidsbydocsetref(null)
   DECLARE lrescnt = i4 WITH protect, noconstant(0)
   DECLARE lbabycnt = i4 WITH protect, noconstant(0)
   DECLARE lstat = i4 WITH protect, noconstant(0)
   RECORD docsetrequest(
     1 person_id = f8
     1 docsetref_list[1]
       2 docsetname = vc
   )
   SET docsetrequest->docsetref_list[1].docsetname = sdocsetname
   SET docsetrequest->person_id = request->person_id
   EXECUTE dcp_get_labels_by_docsetrefs  WITH replace("REQUEST",docsetrequest), replace("REPLY",
    docsetreply)
   IF ((docsetreply->status_data.status="F"))
    CALL echo("[FAIL]: dcp_get_labels_by_docsetrefs failed")
    SET reply->status_data.status = "F"
    GO TO script_end
   ELSEIF ((docsetreply->status_data.status="Z"))
    CALL echo(build("[ZERO]: No label ids retireved for docsetref "),sdocsetname)
    SET reply->status_data.status = "Z"
    GO TO script_end
   ENDIF
   SET lbabycnt = size(docsetreply->label_list,5)
   IF (lbabycnt < 2)
    SET reply->multiple_gest_ind = 0
   ELSE
    SET reply->multiple_gest_ind = 1
   ENDIF
 END ;Subroutine
 SUBROUTINE geteventsetsbyconcept(null)
   DECLARE lstat = i4 WITH protect, noconstant(0)
   RECORD eventsetsrequest(
     1 concepts[*]
       2 concept_cki = vc
     1 event_code_ind = i2
     1 retrieve_all_prim_children = i2
   )
   SET lstat = alterlist(eventsetsrequest->concepts,1)
   SET eventsetsrequest->concepts[1].concept_cki = concept_cki
   SET eventsetsrequest->event_code_ind = 0
   SET eventsetsrequest->retrieve_all_prim_children = 0
   EXECUTE dcp_get_event_sets_by_concept  WITH replace("REQUEST",eventsetsrequest), replace("REPLY",
    eventsetsreply)
   IF ((eventsetsreply->status_data.status="F"))
    CALL echo("[FAIL]: dcp_get_event_sets_by_concept failed")
    SET reply->status_data.status = "F"
    GO TO script_end
   ELSEIF ((eventsetsreply->status_data.status="Z"))
    CALL echo("[ZERO]: No event sets retrieved for Concept CKI")
    SET reply->status_data.status = "Z"
    GO TO script_end
   ENDIF
 END ;Subroutine
 SUBROUTINE (populatelabelrequest(hrequest=i4,dlabelid=f8) =null WITH protect)
   DECLARE heventsetlist = i4 WITH protect, noconstant(0)
   DECLARE hcontext = i4 WITH private, noconstant(0)
   DECLARE hindicators = i4 WITH private, noconstant(0)
   DECLARE hclinicalevent = i4 WITH private, noconstant(0)
   DECLARE lconceptscnt = i4 WITH private, noconstant(0)
   DECLARE lconceptsidx = i4 WITH private, noconstant(0)
   DECLARE leventsetscnt = i4 WITH private, noconstant(0)
   DECLARE leventsetsidx = i4 WITH private, noconstant(0)
   DECLARE nstat = i4 WITH protect, noconstant(0)
   SET lconceptscnt = size(eventsetsreply->concepts,5)
   FOR (lconceptsidx = 1 TO lconceptscnt)
    SET leventsetscnt = size(eventsetsreply->concepts[lconceptsidx].event_sets,5)
    FOR (leventsetsidx = 1 TO leventsetscnt)
     SET heventsetlist = uar_srvadditem(hrequest,"event_set_list")
     IF (heventsetlist)
      SET nstat = uar_srvsetstring(heventsetlist,nullterm("event_set_name"),nullterm(eventsetsreply->
        concepts[lconceptsidx].event_sets[leventsetsidx].event_set_name))
     ENDIF
    ENDFOR
   ENDFOR
   SET nstat = uar_srvsetdouble(hrequest,"patient_id",request->person_id)
   SET nstat = uar_srvsetdate(hrequest,"anchor_date",cnvtdatetime(sysdate))
   SET nstat = uar_srvsetlong(hrequest,"result_count",1)
   SET nstat = uar_srvsetdouble(hrequest,"group_label_id",dlabelid)
   SET nstat = uar_srvsetshort(hrequest,"include_group_label_results_ind",0)
   SET hcontext = uar_srvgetstruct(hrequest,"context")
   IF (hcontext)
    SET nstat = uar_srvsetdouble(hcontext,"provider_id",request->provider_id)
    SET nstat = uar_srvsetdouble(hcontext,"position_cd",request->position_cd)
    SET nstat = uar_srvsetdouble(hcontext,"provider_patient_reltn_cd",request->
     provider_patient_reltn_cd)
   ENDIF
   SET hindicators = uar_srvgetstruct(hrequest,"load_indicators")
   IF (hindicators)
    SET hclinicalevent = uar_srvgetstruct(hindicators,"clinical_event")
    IF (hclinicalevent)
     SET nstat = uar_srvsetshort(hclinicalevent,"comments_ind",1)
     SET nstat = uar_srvsetshort(hclinicalevent,"meas_value_ind",1)
     SET nstat = uar_srvsetshort(hclinicalevent,"bp_value_ind",1)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE getresultsbylabelid(null)
   DECLARE hmsg = i4 WITH protect, noconstant(0)
   DECLARE hrequest = i4 WITH private, noconstant(0)
   DECLARE hreply = i4 WITH private, noconstant(0)
   DECLARE nstat = i4 WITH protect, noconstant(0)
   DECLARE llabelcnt = i4 WITH private, noconstant(0)
   DECLARE llabelidx = i4 WITH private, noconstant(0)
   SET llabelcnt = size(docsetreply->label_list,5)
   FOR (llabelidx = 1 TO llabelcnt)
     SET hmsg = uar_srvselectmessage(lrequestnum)
     SET hrequest = uar_srvcreaterequest(hmsg)
     SET hreply = uar_srvcreatereply(hmsg)
     IF (hrequest <= 0)
      SET failure_ind = true
      SET errormsg = "Unable to create request handle when calling msvc_svr_get_last_n_results"
      GO TO script_end
     ENDIF
     CALL populatelabelrequest(hrequest,docsetreply->label_list[llabelidx].dynamic_label_id)
     SET nstat = uar_srvexecute(hmsg,hrequest,hreply)
     IF (nstat != 0)
      SET failure_ind = true
      SET errormsg = "Unable to perform request when calling msvc_srv_get_last_n_results"
      GO TO script_end
     ENDIF
     CALL getreplydata(hreply,llabelidx)
   ENDFOR
 END ;Subroutine
 SUBROUTINE (getreplydata(hreply=i4,llabelidx=i4) =null WITH protect)
   DECLARE hstatus_data = i4 WITH protect, noconstant(0)
   DECLARE mes_value = vc WITH protect, noconstant("")
   DECLARE hitem = i4 WITH protect, noconstant(0)
   DECLARE hceitem = i4 WITH protect, noconstant(0)
   DECLARE hmesitem = i4 WITH protect, noconstant(0)
   DECLARE lresultscnt = i4 WITH protect, noconstant(0)
   DECLARE lcecnt = i4 WITH protect, noconstant(0)
   DECLARE lmeasrmtcnt = i4 WITH protect, noconstant(0)
   DECLARE ldatevalcnt = i4 WITH protect, noconstant(0)
   DECLARE lresultsidx = i4 WITH protect, noconstant(0)
   DECLARE lceidx = i4 WITH protect, noconstant(0)
   DECLARE lmeasrmtidx = i4 WITH protect, noconstant(0)
   DECLARE ldatevalidx = i4 WITH protect, noconstant(0)
   DECLARE del_ind = i2 WITH protect, noconstant(1)
   DECLARE hdatevalitem = i4 WITH protect, noconstant(0)
   DECLARE date = dq8 WITH protect, noconstant(0)
   SET lresultscnt = uar_srvgetitemcount(hreply,nullterm("results"))
   FOR (lresultsidx = 0 TO (lresultscnt - 1))
     SET hitem = uar_srvgetitem(hreply,nullterm("results"),lresultsidx)
     SET lcecnt = uar_srvgetitemcount(hitem,nullterm("clinical_events"))
     FOR (lceidx = 0 TO (lcecnt - 1))
       SET hceitem = uar_srvgetitem(hitem,nullterm("clinical_events"),lceidx)
       SET lmeasrmtcnt = uar_srvgetitemcount(hceitem,nullterm("measurement"))
       FOR (lmeasrmtidx = 0 TO (lmeasrmtcnt - 1))
         SET hmesitem = uar_srvgetitem(hceitem,nullterm("measurement"),lmeasrmtidx)
         SET mes_value = uar_srvgetstringptr(hmesitem,nullterm("measurement_classification"))
         SET ldatevalcnt = uar_srvgetitemcount(hmesitem,nullterm("date_value"))
         IF (ldatevalcnt > 0)
          FOR (ldatevalidx = 0 TO (ldatevalcnt - 1))
           SET hdatevalitem = uar_srvgetitem(hmesitem,nullterm("date_value"),ldatevalidx)
           IF (hdatevalitem)
            SET stat = uar_srvgetdate(hdatevalitem,nullterm("value_date"),tempdate->date)
            SET date = uar_srvgetlong(hdatevalitem,nullterm("value_date_tz"))
            SET stat = alterlist(reply->dynamic_label,lreplyidx)
            SET reply->dynamic_label[lreplyidx].delivery_date_tz = date
            SET reply->dynamic_label[lreplyidx].delivery_date = tempdate->date
            SET reply->dynamic_label[lreplyidx].label_name = docsetreply->label_list[llabelidx].
            label_name
            IF ((validate(reply->dynamic_label[lreplyidx].dynamic_label_id,- (99.0)) != - (99.0)))
             SET reply->dynamic_label[lreplyidx].dynamic_label_id = docsetreply->label_list[llabelidx
             ].dynamic_label_id
            ENDIF
            SET lreplyidx += 1
            SET del_ind = 0
            IF ((tempdate->date > reply->latest_delivery_date))
             SET reply->latest_delivery_date = tempdate->date
            ENDIF
           ENDIF
          ENDFOR
         ENDIF
       ENDFOR
     ENDFOR
   ENDFOR
   IF (lresultscnt > 0)
    IF (del_ind)
     SET reply->partial_delivery_ind = 1
    ENDIF
   ELSE
    SET reply->partial_delivery_ind = 1
   ENDIF
 END ;Subroutine
 SUBROUTINE getpregnancyprefs(null)
   RECORD pregnancy_event_sets(
     1 qual[*]
       2 pref_entry_name = vc
       2 event_set_name = vc
   )
   DECLARE stat = i2 WITH protect, noconstant(0)
   DECLARE hpref = i4 WITH private, noconstant(0)
   DECLARE hgroup = i4 WITH private, noconstant(0)
   DECLARE hrepgroup = i4 WITH private, noconstant(0)
   DECLARE hsection = i4 WITH private, noconstant(0)
   DECLARE hattr = i4 WITH private, noconstant(0)
   DECLARE hentry = i4 WITH private, noconstant(0)
   DECLARE lentrycnt = i4 WITH private, noconstant(0)
   DECLARE lentryidx = i4 WITH private, noconstant(0)
   DECLARE ilen = i4 WITH private, noconstant(255)
   DECLARE lattrcnt = i4 WITH private, noconstant(0)
   DECLARE lattridx = i4 WITH private, noconstant(0)
   DECLARE lvalcnt = i4 WITH private, noconstant(0)
   DECLARE sentryname = c255 WITH private, noconstant("")
   DECLARE sattrname = c255 WITH private, noconstant("")
   DECLARE sval = c255 WITH private, noconstant("")
   DECLARE sentryval = c255 WITH private, noconstant("")
   DECLARE tempdeldate = dq8 WITH private, noconstant(0)
   DECLARE deldate = dq8 WITH private, noconstant(0)
   CALL echo("[TRACE] Entering GetPregnancyPrefs subroutine")
   EXECUTE prefrtl
   SET hpref = uar_prefcreateinstance(0)
   SET stat = uar_prefaddcontext(hpref,nullterm("default"),nullterm("system"))
   SET stat = uar_prefsetsection(hpref,nullterm("component"))
   SET hgroup = uar_prefcreategroup()
   SET stat = uar_prefsetgroupname(hgroup,nullterm("Pregnancy"))
   SET stat = uar_prefaddgroup(hpref,hgroup)
   SET stat = uar_prefperform(hpref)
   SET hsection = uar_prefgetsectionbyname(hpref,nullterm("component"))
   SET hrepgroup = uar_prefgetgroupbyname(hsection,nullterm("Pregnancy"))
   SET stat = uar_prefgetgroupentrycount(hrepgroup,lentrycnt)
   FOR (lentryidx = 0 TO (lentrycnt - 1))
     SET hentry = uar_prefgetgroupentry(hrepgroup,lentryidx)
     SET ilen = 255
     SET sentryname = ""
     SET sentryval = ""
     SET stat = uar_prefgetentryname(hentry,sentryname,ilen)
     IF (sentryname=docset_pref)
      SET lattrcnt = 0
      SET stat = uar_prefgetentryattrcount(hentry,lattrcnt)
      FOR (lattridx = 0 TO (lattrcnt - 1))
        SET hattr = uar_prefgetentryattr(hentry,lattridx)
        SET ilen = 255
        SET sattrname = ""
        SET stat = uar_prefgetattrname(hattr,sattrname,ilen)
        IF (sattrname="prefvalue")
         SET lvalcnt = 0
         SET stat = uar_prefgetattrvalcount(hattr,lvalcnt)
         IF (lvalcnt > 0)
          SET sval = ""
          SET ilen = 255
          SET stat = uar_prefgetattrval(hattr,sval,ilen,0)
          SET sdocsetname = trim(sval)
          IF (size(trim(sdocsetname)) < 1)
           SET failure_ind = true
           CALL echo("[TRACE] Preference 'fetus dynamic label docsets' not found/not set")
           GO TO script_end
          ENDIF
         ENDIF
         SET lattridx = lattrcnt
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
   CALL uar_prefdestroysection(hsection)
   CALL uar_prefdestroygroup(hgroup)
   CALL uar_prefdestroyinstance(hpref)
   CALL getlabelidsbydocsetref(null)
   CALL geteventsetsbyconcept(null)
   CALL getresultsbylabelid(null)
   IF (size(reply->dynamic_label,5) < 1)
    SET zero_ind = true
   ENDIF
   GO TO script_end
 END ;Subroutine
#script_end
 SET error_code = error(error_msg,1)
 IF (error_code != 0)
  CALL echo(build("ERROR: ",error_msg))
  SET reply->status_data.status = "F"
  CALL fillsubeventstatus("ERROR","F","dcp_get_ega_multiple_gestation",error_msg)
 ELSEIF (failure_ind=true)
  CALL echo("*Get EGA Multiple Gestation Script failed*")
  SET reply->status_data.status = "F"
 ELSEIF (zero_ind=true)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echo("Script was last modified on: 002 03/13/15")
 SET modify = nopredeclare
END GO
