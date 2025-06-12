CREATE PROGRAM dcp_get_pregnancy_edd:dba
 SET modify = predeclare
 FREE RECORD reply
 RECORD reply(
   1 edd_list[*]
     2 pregnancy_estimate_id = f8
     2 pregnancy_id = f8
     2 status_flag = i2
     2 method_cd = f8
     2 method_disp = c40
     2 method_desc = vc
     2 method_mean = c12
     2 method_dt_tm = dq8
     2 descriptor_cd = f8
     2 descriptor_disp = c40
     2 descriptor_desc = vc
     2 descriptor_mean = c12
     2 descriptor_txt = vc
     2 descriptor_flag = i2
     2 edd_comment = vc
     2 author_id = f8
     2 crown_rump_length = f8
     2 biparietal_diameter = f8
     2 head_circumference = f8
     2 est_gest_age = i4
     2 est_delivery_date = dq8
     2 confirmation_cd = f8
     2 confirmation_disp = c40
     2 confirmation_desc = vc
     2 confirmation_mean = c12
     2 prev_edd_id = f8
     2 active_ind = i2
     2 entered_dt_tm = dq8
     2 updt_id = f8
     2 updt_dt_tm = dq8
     2 details[*]
       3 lmp_symptoms_txt = vc
       3 pregnancy_test_dt_tm = dq8
       3 contraception_ind = i2
       3 contraception_duration = i4
       3 breastfeeding_ind = i2
       3 menarche_age = i4
       3 menstrual_freq = i4
       3 prior_menses_dt_tm = dq8
     2 prev_edds[*]
       3 pregnancy_estimate_id = f8
       3 pregnancy_id = f8
       3 status_flag = i2
       3 method_cd = f8
       3 method_disp = c40
       3 method_desc = vc
       3 method_mean = c12
       3 method_dt_tm = dq8
       3 descriptor_cd = f8
       3 descriptor_disp = c40
       3 descriptor_desc = vc
       3 descriptor_mean = c12
       3 descriptor_txt = vc
       3 descriptor_flag = i2
       3 edd_comment = vc
       3 crown_rump_length = f8
       3 biparietal_diameter = f8
       3 head_circumference = f8
       3 est_gest_age = i4
       3 est_delivery_date = dq8
       3 confirmation_cd = f8
       3 confirmation_disp = c40
       3 confirmation_desc = vc
       3 confirmation_mean = c12
       3 active_ind = i2
       3 author_id = f8
       3 entered_dt_tm = dq8
       3 details[*]
         4 lmp_symptoms_txt = vc
         4 pregnancy_test_dt_tm = dq8
         4 contraception_ind = i2
         4 contraception_duration = i4
         4 breastfeeding_ind = i2
         4 menarche_age = i4
         4 menstrual_freq = i4
         4 prior_menses_dt_tm = dq8
       3 method_tz = i4
       3 est_delivery_tz = i4
     2 creator_id = f8
     2 original_entered_dttm = dq8
     2 org_id = f8
     2 method_tz = i4
     2 est_delivery_tz = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH persistscript
 FREE RECORD active_preg_list
 RECORD active_preg_list(
   1 pregnancy_list[*]
     2 pregnancy_id = f8
     2 org_id = f8
 )
 DECLARE failure_ind = i2 WITH protect, noconstant(false)
 DECLARE zero_ind = i2 WITH protect, noconstant(false)
 DECLARE debug_ind = i2 WITH protect, noconstant(0)
 DECLARE error_msg = vc WITH protect, noconstant("")
 DECLARE error_code = i2 WITH protect, noconstant(false)
 DECLARE select_mode = i4 WITH protect, noconstant(0)
 DECLARE chunksize = i2 WITH protect, constant(20)
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE eddlistidx = i4 WITH protect, noconstant(0)
 DECLARE multiple_orgs = i2 WITH protect, noconstant(0)
 DECLARE deleted_edds_flag = i2 WITH protect, constant(request->deleted_edds_flag)
 DECLARE validaterequest(null) = null
 DECLARE queryforeddlist(null) = null
 DECLARE loadpregintolist(null) = null
 DECLARE querybypregnancy(null) = null
 DECLARE findpregbyperson(null) = null
 DECLARE querydetails(null) = null
 DECLARE gethistoricedds(null) = null
 SUBROUTINE (checkactivepregnancy(argpersonid=f8) =f8)
   RETURN(checkactivepregnancyorg(argpersonid,0,0))
 END ;Subroutine
 SUBROUTINE (checkactivepregnancyorg(argpersonid=f8,argencntrid=f8,argorgsecoverride=i2) =f8)
   CALL echo("[TRACE]: CheckActivePregnancy")
   DECLARE retval = f8 WITH noconstant(0.0), private
   RECORD actchkrequest(
     1 patient_id = f8
     1 encntr_id = f8
     1 org_sec_override = i2
   )
   SET actchkrequest->patient_id = argpersonid
   SET actchkrequest->encntr_id = argencntrid
   SET actchkrequest->org_sec_override = argorgsecoverride
   EXECUTE dcp_chk_active_preg  WITH replace("REQUEST",actchkrequest), replace("REPLY",actchkreply)
   IF ((actchkreply->status_data.status="F"))
    CALL echo("[FAIL]: DCP_CHK_ACTIVE_PREG failed")
   ELSEIF ((actchkreply->status_data.status="Z"))
    SET retval = 0.0
   ELSE
    CALL echo("[TRACE]: Active Pregnancy found for patient")
    SET retval = actchkreply->pregnancy_id
   ENDIF
   RETURN(retval)
 END ;Subroutine
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
 SET reply->status_data.status = "F"
 IF (validate(request->debug_ind))
  IF ((request->debug_ind=1))
   SET debug_ind = true
  ENDIF
 ENDIF
 CALL validaterequest(null)
 IF (select_mode=2)
  CALL queryforeddlist(null)
 ELSEIF (select_mode=1)
  CALL loadpregintolist(null)
  CALL querybypregnancy(null)
 ELSE
  CALL findpregbyperson(null)
  CALL querybypregnancy(null)
 ENDIF
 CALL querydetails(null)
 IF ((request->previous_values_flag=true))
  CALL gethistoricedds(null)
 ENDIF
 SUBROUTINE validaterequest(null)
   IF (size(request->edds,5) > 0)
    CALL echo("[TRACE]: EDD ids found, switching to EDD List mode")
    SET select_mode = 2
    IF (locateval(idx,1,size(request->edds,5),0.0,request->edds[idx].edd_id) > 0)
     CALL fillsubeventstatus("dcp_get_pregnancy_edd","F","ValidateRequest",
      "request contains edd_id = 0")
     SET reply->status_data.status = "F"
     GO TO exit_script
    ENDIF
   ELSEIF ((request->pregnancy_id > 0))
    CALL echo("[TRACE]: Preg id found, switching to Pregnancy mode")
    SET select_mode = 1
   ELSEIF ((request->patient_id <= 0))
    CALL echo("[FAIL]: Query mode could not be determined")
    SET failure_ind = true
    CALL fillsubeventstatus("dcp_get_pregnancy_edd","F","ValidateRequest",
     "Query mode could not be determined")
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE loadpregintolist(null)
   SET stat = alterlist(active_preg_list->pregnancy_list,1)
   SET active_preg_list->pregnancy_list[1].pregnancy_id = request->pregnancy_id
   SELECT INTO "nl:"
    FROM pregnancy_instance p
    WHERE (p.pregnancy_id=request->pregnancy_id)
     AND p.active_ind=1
    DETAIL
     active_preg_list->pregnancy_list[1].org_id = p.organization_id
   ;end select
 END ;Subroutine
 SUBROUTINE findpregbyperson(null)
  CALL echo("[TRACE]: Defaulting to Person mode")
  IF ((((request->encntr_id > 0)) OR (preg_org_sec_ind=0)) )
   DECLARE pregid = f8 WITH noconstant(0)
   SET pregid = checkactivepregnancyorg(request->patient_id,request->encntr_id,request->
    org_sec_override)
   IF (pregid <= 0.0)
    CALL echo("[ZERO]: Active pregnancy could not be found")
    CALL fillsubeventstatus("dcp_get_pregnancy_edd","Z","FindPregByPerson",
     "Active pregnancy could not be found")
    SET zero_ind = true
    GO TO exit_script
   ENDIF
   SET stat = alterlist(active_preg_list->pregnancy_list,1)
   SET active_preg_list->pregnancy_list[1].pregnancy_id = pregid
   CALL echo("[TRACE]: Single pregnancy found for patient")
  ELSE
   SELECT INTO "nl:"
    FROM pregnancy_instance p,
     (dummyt d  WITH seq = size(preg_sec_orgs->qual,5))
    PLAN (p
     WHERE p.active_ind=1
      AND (p.person_id=request->patient_id)
      AND p.preg_end_dt_tm=cnvtdatetime("31-DEC-2100"))
     JOIN (d
     WHERE (p.organization_id=preg_sec_orgs->qual[d.seq].org_id))
    HEAD REPORT
     active_preg_cnt = 0
    HEAD p.pregnancy_id
     active_preg_cnt += 1
     IF (active_preg_cnt > size(active_preg_list->pregnancy_list,5))
      stat = alterlist(active_preg_list->pregnancy_list,(active_preg_cnt+ 9))
     ENDIF
     active_preg_list->pregnancy_list[active_preg_cnt].pregnancy_id = p.pregnancy_id,
     active_preg_list->pregnancy_list[active_preg_cnt].org_id = p.organization_id
    FOOT REPORT
     stat = alterlist(active_preg_list->pregnancy_list,active_preg_cnt)
    WITH nocounter
   ;end select
   IF (size(preg_sec_orgs->qual,5)=0)
    CALL echo("[ZERO]: Active pregnancy could not be found")
    CALL fillsubeventstatus("dcp_get_pregnancy_edd","Z","FindPregByPerson",
     "Active pregnancy could not be found")
    SET zero_ind = true
    GO TO exit_script
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE queryforeddlist(null)
   DECLARE eddlistcnt = i2 WITH protect, noconstant(size(request->edds,5))
   DECLARE eddlistchunkcnt = i2 WITH protect, noconstant(ceil(((eddlistcnt * 1.0)/ chunksize)))
   DECLARE eddidx = i2 WITH protect, noconstant(0)
   IF (mod(eddlistcnt,chunksize) != 0)
    SET stat = alterlist(request->edds,(eddlistchunkcnt * chunksize))
    CALL echo("[TRACE]: Normalizing EDD request")
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = ((eddlistchunkcnt * chunksize) - eddlistcnt))
     HEAD REPORT
      eddidx = 0
     DETAIL
      eddidx += 1, request->edds[(eddidx+ eddlistcnt)].edd_id = request->edds[eddlistcnt].edd_id
     WITH nocounter
    ;end select
   ENDIF
   SELECT DISTINCT INTO "nl:"
    FROM (dummyt d1  WITH seq = eddlistchunkcnt),
     pregnancy_estimate pe,
     long_text lt,
     pregnancy_instance pi
    PLAN (d1)
     JOIN (pe
     WHERE expand(eddlistidx,(((d1.seq - 1) * chunksize)+ 1),(d1.seq * chunksize),pe
      .pregnancy_estimate_id,request->edds[eddlistidx].edd_id))
     JOIN (lt
     WHERE lt.long_text_id=pe.edd_comment_id)
     JOIN (pi
     WHERE pi.pregnancy_id=pe.pregnancy_id)
    ORDER BY pe.pregnancy_estimate_id
    HEAD REPORT
     idx = 0, stat = alterlist(reply->edd_list,10)
    DETAIL
     idx += 1
     IF (mod(idx,10)=1)
      stat = alterlist(reply->edd_list,(idx+ 9))
     ENDIF
     reply->edd_list[idx].pregnancy_estimate_id = pe.pregnancy_estimate_id, reply->edd_list[idx].
     pregnancy_id = pe.pregnancy_id, reply->edd_list[idx].status_flag = pe.status_flag,
     reply->edd_list[idx].method_cd = pe.method_cd, reply->edd_list[idx].method_dt_tm = pe
     .method_dt_tm, reply->edd_list[idx].method_tz = pe.method_tz,
     reply->edd_list[idx].est_delivery_tz = pe.est_delivery_tz, reply->edd_list[idx].author_id = pe
     .author_id, reply->edd_list[idx].descriptor_cd = pe.descriptor_cd,
     reply->edd_list[idx].descriptor_txt = pe.descriptor_txt, reply->edd_list[idx].descriptor_flag =
     pe.descriptor_flag, reply->edd_list[idx].crown_rump_length = pe.crown_rump_length,
     reply->edd_list[idx].biparietal_diameter = pe.biparietal_diameter, reply->edd_list[idx].
     head_circumference = pe.head_circumference, reply->edd_list[idx].est_gest_age = pe
     .est_gest_age_days,
     reply->edd_list[idx].est_delivery_date = pe.est_delivery_dt_tm, reply->edd_list[idx].
     confirmation_cd = pe.confirmation_cd, reply->edd_list[idx].prev_edd_id = pe
     .prev_preg_estimate_id,
     reply->edd_list[idx].active_ind = pe.active_ind, reply->edd_list[idx].updt_dt_tm = pe.updt_dt_tm,
     reply->edd_list[idx].entered_dt_tm = pe.entered_dt_tm,
     reply->edd_list[idx].edd_comment = lt.long_text, reply->edd_list[idx].org_id = pi
     .organization_id
    FOOT REPORT
     stat = alterlist(reply->edd_list,idx)
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL echo("[ZERO]: No EDDs match the ids given")
    CALL fillsubeventstatus("dcp_get_pregnancy_edd","Z","QueryForEDDList",
     "No EDDs match the ids given")
    SET zero_ind = true
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE querybypregnancy(null)
  SELECT
   IF (deleted_edds_flag=1)
    FROM pregnancy_estimate pe,
     long_text lt,
     (dummyt d  WITH seq = size(active_preg_list->pregnancy_list,5))
    PLAN (d)
     JOIN (pe
     WHERE (pe.pregnancy_id=active_preg_list->pregnancy_list[d.seq].pregnancy_id)
      AND  NOT (pe.pregnancy_estimate_id IN (
     (SELECT
      pe2.prev_preg_estimate_id
      FROM pregnancy_estimate pe2
      WHERE pe2.pregnancy_id=pe.pregnancy_id))))
     JOIN (lt
     WHERE (lt.long_text_id= Outerjoin(pe.edd_comment_id)) )
   ELSE
    FROM pregnancy_estimate pe,
     long_text lt,
     (dummyt d  WITH seq = size(active_preg_list->pregnancy_list,5))
    PLAN (d)
     JOIN (pe
     WHERE (pe.pregnancy_id=active_preg_list->pregnancy_list[d.seq].pregnancy_id)
      AND pe.active_ind=1)
     JOIN (lt
     WHERE (lt.long_text_id= Outerjoin(pe.edd_comment_id)) )
   ENDIF
   INTO "nl:"
   ORDER BY pe.pregnancy_id, pe.entered_dt_tm DESC, pe.pregnancy_estimate_id DESC
   HEAD REPORT
    idx = 0, stat = alterlist(reply->edd_list,10)
   DETAIL
    idx += 1
    IF (mod(idx,10)=1)
     stat = alterlist(reply->edd_list,(idx+ 9))
    ENDIF
    reply->edd_list[idx].pregnancy_estimate_id = pe.pregnancy_estimate_id, reply->edd_list[idx].
    pregnancy_id = pe.pregnancy_id, reply->edd_list[idx].org_id = active_preg_list->pregnancy_list[d
    .seq].org_id,
    reply->edd_list[idx].status_flag = pe.status_flag, reply->edd_list[idx].method_cd = pe.method_cd,
    reply->edd_list[idx].method_dt_tm = pe.method_dt_tm,
    reply->edd_list[idx].method_tz = pe.method_tz, reply->edd_list[idx].est_delivery_tz = pe
    .est_delivery_tz, reply->edd_list[idx].author_id = pe.author_id,
    reply->edd_list[idx].descriptor_cd = pe.descriptor_cd, reply->edd_list[idx].descriptor_txt = pe
    .descriptor_txt, reply->edd_list[idx].descriptor_flag = pe.descriptor_flag,
    reply->edd_list[idx].crown_rump_length = pe.crown_rump_length, reply->edd_list[idx].
    biparietal_diameter = pe.biparietal_diameter, reply->edd_list[idx].head_circumference = pe
    .head_circumference,
    reply->edd_list[idx].est_gest_age = pe.est_gest_age_days, reply->edd_list[idx].est_delivery_date
     = pe.est_delivery_dt_tm, reply->edd_list[idx].confirmation_cd = pe.confirmation_cd,
    reply->edd_list[idx].prev_edd_id = pe.prev_preg_estimate_id, reply->edd_list[idx].active_ind = pe
    .active_ind, reply->edd_list[idx].entered_dt_tm = pe.entered_dt_tm,
    reply->edd_list[idx].updt_dt_tm = pe.updt_dt_tm, reply->edd_list[idx].edd_comment = lt.long_text
   FOOT REPORT
    stat = alterlist(reply->edd_list,idx)
   WITH nocounter
  ;end select
  IF (curqual=0)
   CALL echo("[ZERO]: No EDDs match the active pregnancy")
   CALL fillsubeventstatus("dcp_get_pregnancy_edd","Z","QueryByPregnancy",
    "No EDDs match the active pregnancy")
   SET zero_ind = true
   GO TO exit_script
  ENDIF
 END ;Subroutine
 SUBROUTINE gethistoricedds(null)
   CALL echo("[TRACE]: Fetching historic estimates")
   DECLARE act_eddcnt = i2 WITH private, constant(size(reply->edd_list,5))
   DECLARE prev_edd_id = f8 WITH protect, noconstant(0.0)
   DECLARE i = i4 WITH protect, noconstant(0)
   DECLARE chaincnt = i4 WITH protect, noconstant(0)
   FOR (i = 1 TO act_eddcnt)
     SET prev_edd_id = reply->edd_list[i].prev_edd_id
     SET chaincnt = 0
     SET stat = alterlist(reply->edd_list[i].prev_edds,10)
     WHILE (prev_edd_id != 0.0)
      SELECT INTO "nl:"
       FROM pregnancy_estimate pe,
        long_text lt,
        pregnancy_detail pd
       PLAN (pe
        WHERE pe.pregnancy_estimate_id=prev_edd_id)
        JOIN (lt
        WHERE (lt.long_text_id= Outerjoin(pe.edd_comment_id)) )
        JOIN (pd
        WHERE (pd.pregnancy_estimate_id= Outerjoin(pe.pregnancy_estimate_id)) )
       HEAD REPORT
        chaincnt += 1
        IF (mod(chaincnt,10)=1)
         stat = alterlist(reply->edd_list[i].prev_edds,(chaincnt+ 9))
        ENDIF
        reply->edd_list[i].prev_edds[chaincnt].pregnancy_estimate_id = pe.pregnancy_estimate_id,
        reply->edd_list[i].prev_edds[chaincnt].pregnancy_id = pe.pregnancy_id, reply->edd_list[i].
        prev_edds[chaincnt].status_flag = pe.status_flag,
        reply->edd_list[i].prev_edds[chaincnt].method_cd = pe.method_cd, reply->edd_list[i].
        prev_edds[chaincnt].method_dt_tm = pe.method_dt_tm, reply->edd_list[i].prev_edds[chaincnt].
        method_tz = pe.method_tz,
        reply->edd_list[i].prev_edds[chaincnt].est_delivery_tz = pe.est_delivery_tz, reply->edd_list[
        i].prev_edds[chaincnt].descriptor_cd = pe.descriptor_cd, reply->edd_list[i].prev_edds[
        chaincnt].descriptor_txt = pe.descriptor_txt,
        reply->edd_list[i].prev_edds[chaincnt].descriptor_flag = pe.descriptor_flag, reply->edd_list[
        i].prev_edds[chaincnt].crown_rump_length = pe.crown_rump_length, reply->edd_list[i].
        prev_edds[chaincnt].biparietal_diameter = pe.biparietal_diameter,
        reply->edd_list[i].prev_edds[chaincnt].head_circumference = pe.head_circumference, reply->
        edd_list[i].prev_edds[chaincnt].est_gest_age = pe.est_gest_age_days, reply->edd_list[i].
        prev_edds[chaincnt].est_delivery_date = pe.est_delivery_dt_tm,
        reply->edd_list[i].prev_edds[chaincnt].confirmation_cd = pe.confirmation_cd, reply->edd_list[
        i].prev_edds[chaincnt].active_ind = pe.active_ind, reply->edd_list[i].prev_edds[chaincnt].
        edd_comment = lt.long_text,
        reply->edd_list[i].prev_edds[chaincnt].author_id = pe.author_id, reply->edd_list[i].
        prev_edds[chaincnt].entered_dt_tm = pe.entered_dt_tm, prev_edd_id = pe.prev_preg_estimate_id
        IF (pd.pregnancy_detail_id > 0)
         stat = alterlist(reply->edd_list[i].prev_edds[chaincnt].details,1), reply->edd_list[i].
         prev_edds[chaincnt].details[1].lmp_symptoms_txt = pd.lmp_symptoms_txt, reply->edd_list[i].
         prev_edds[chaincnt].details[1].breastfeeding_ind = pd.breastfeeding_ind,
         reply->edd_list[i].prev_edds[chaincnt].details[1].contraception_duration = pd
         .contraception_duration, reply->edd_list[i].prev_edds[chaincnt].details[1].contraception_ind
          = pd.contraception_ind, reply->edd_list[i].prev_edds[chaincnt].details[1].menarche_age = pd
         .menarche_age,
         reply->edd_list[i].prev_edds[chaincnt].details[1].pregnancy_test_dt_tm = pd
         .pregnancy_test_dt_tm, reply->edd_list[i].prev_edds[chaincnt].details[1].menstrual_freq = pd
         .menstrual_freq, reply->edd_list[i].prev_edds[chaincnt].details[1].prior_menses_dt_tm = pd
         .prior_menses_dt_tm
        ENDIF
       WITH nocounter
      ;end select
      IF (curqual=0)
       SET prev_edd_id = 0.0
      ENDIF
     ENDWHILE
     SET stat = alterlist(reply->edd_list[i].prev_edds,chaincnt)
     IF (chaincnt > 0)
      SET reply->edd_list[i].creator_id = reply->edd_list[i].prev_edds[chaincnt].author_id
      SET reply->edd_list[i].original_entered_dttm = reply->edd_list[i].prev_edds[chaincnt].
      entered_dt_tm
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE querydetails(null)
   DECLARE replychunksize = i4 WITH constant(5)
   DECLARE replycnt = i4 WITH constant(size(reply->edd_list,5))
   DECLARE replychunkcnt = i4 WITH constant(ceil(((replycnt * 1.0)/ replychunksize)))
   IF (mod(replycnt,replychunksize) != 0)
    SET stat = alterlist(reply->edd_list,(replychunkcnt * replychunksize))
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = ((replychunkcnt * replychunksize) - replycnt))
     HEAD REPORT
      eddidx = replycnt
     DETAIL
      eddidx += 1, reply->edd_list[eddidx].pregnancy_estimate_id = reply->edd_list[replycnt].
      pregnancy_estimate_id
     WITH nocounter
    ;end select
   ENDIF
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = replychunkcnt),
     pregnancy_detail pd
    PLAN (d1)
     JOIN (pd
     WHERE expand(idx,(((d1.seq - 1) * replychunksize)+ 1),(d1.seq * replychunksize),pd
      .pregnancy_estimate_id,reply->edd_list[idx].pregnancy_estimate_id)
      AND ((pd.active_ind+ 0)=1))
    ORDER BY pd.pregnancy_estimate_id, pd.pregnancy_detail_id
    HEAD REPORT
     eddidx = 0
    HEAD pd.pregnancy_estimate_id
     eddidx = locateval(idx,1,replycnt,pd.pregnancy_estimate_id,reply->edd_list[idx].
      pregnancy_estimate_id), stat = alterlist(reply->edd_list[eddidx].details,10), detailidx = 0
    DETAIL
     detailidx += 1
     IF (mod(detailidx,10)=1)
      stat = alterlist(reply->edd_list[eddidx].details,(detailidx+ 9))
     ENDIF
     reply->edd_list[eddidx].details[detailidx].lmp_symptoms_txt = pd.lmp_symptoms_txt, reply->
     edd_list[eddidx].details[detailidx].breastfeeding_ind = pd.breastfeeding_ind, reply->edd_list[
     eddidx].details[detailidx].contraception_duration = pd.contraception_duration,
     reply->edd_list[eddidx].details[detailidx].contraception_ind = pd.contraception_ind, reply->
     edd_list[eddidx].details[detailidx].menarche_age = pd.menarche_age, reply->edd_list[eddidx].
     details[detailidx].pregnancy_test_dt_tm = pd.pregnancy_test_dt_tm,
     reply->edd_list[eddidx].details[detailidx].menstrual_freq = pd.menstrual_freq, reply->edd_list[
     eddidx].details[detailidx].prior_menses_dt_tm = pd.prior_menses_dt_tm
    FOOT  pd.pregnancy_estimate_id
     stat = alterlist(reply->edd_list[eddidx].details,detailidx)
    WITH nocounter
   ;end select
   SET stat = alterlist(reply->edd_list,replycnt)
 END ;Subroutine
#exit_script
 SET error_code = error(error_msg,1)
 IF (error_code != 0)
  CALL fillsubeventstatus("ERROR","F","dcp_get_pregnancy_edd",error_msg)
 ELSEIF (failure_ind=true)
  CALL echo("*Get Pregnancy EDD Script failed*")
 ELSEIF (zero_ind=true)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF (debug_ind=1)
  CALL echorecord(active_preg_list)
  CALL echorecord(reply)
  CALL echo("Last Mod: 003 06/20/18")
 ENDIF
 FREE RECORD active_preg_list
 SET modify = nopredeclare
END GO
