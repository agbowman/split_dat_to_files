CREATE PROGRAM dcp_get_final_ega1:dba
 SET modify = predeclare
 RECORD request_temp(
   1 patient_list[*]
     2 patient_id = f8
     2 encntr_id = f8
   1 pregnancy_list[*]
     2 pregnancy_id = f8
   1 multiple_egas = i2
   1 provider_id = f8
   1 position_cd = f8
   1 cal_ega_multiple_gest = i2
 )
 RECORD temp_provider_patient_relation(
   1 provider_list[*]
     2 person_id = f8
     2 encntr_id = f8
     2 provider_patient_reltn_cd = f8
 )
 IF (validate(request->multiple_egas)=0)
  DECLARE patcnt = i4 WITH public, noconstant(size(request->patient_list,5))
  IF (patcnt > 0)
   SET stat = alterlist(request_temp->patient_list,patcnt)
   SELECT INTO "nl:"
    person_id = request->patient_list[d2.seq].patient_id
    FROM (dummyt d2  WITH seq = value(patcnt))
    DETAIL
     request_temp->patient_list[d2.seq].patient_id = person_id, request_temp->patient_list[d2.seq].
     encntr_id = 0.00
    WITH nocounter
   ;end select
  ENDIF
  DECLARE pregcnt = i4 WITH public, noconstant(size(request->pregnancy_list,5))
  IF (pregcnt > 0)
   SET stat = alterlist(request_temp->pregnancy_list,pregcnt)
   SELECT INTO "nl:"
    pregnancy_id = request->pregnancy_list[d2.seq].pregnancy_id
    FROM (dummyt d2  WITH seq = value(pregcnt))
    DETAIL
     request_temp->pregnancy_list[d2.seq].pregnancy_id = pregnancy_id
    WITH nocounter
   ;end select
  ENDIF
  SET request_temp->multiple_egas = 0
  IF (validate(request->position_cd,0))
   SET request_temp->position_cd = request->position_cd
  ENDIF
  IF (validate(request->provider_id,0))
   SET request_temp->provider_id = request->provider_id
  ENDIF
  IF (validate(request->cal_ega_multiple_gest,0))
   SET request_temp->cal_ega_multiple_gest = request->cal_ega_multiple_gest
  ENDIF
  IF (validate(request->provider_list,0))
   SET stat = moverec(request->provider_list,temp_provider_patient_relation->provider_list)
  ENDIF
  FREE SET request
  RECORD request(
    1 patient_list[*]
      2 patient_id = f8
      2 encntr_id = f8
    1 pregnancy_list[*]
      2 pregnancy_id = f8
    1 multiple_egas = i2
    1 provider_list[*]
      2 patient_id = f8
      2 encntr_id = f8
      2 provider_patient_reltn_cd = f8
    1 provider_id = f8
    1 position_cd = f8
    1 cal_ega_multiple_gest = i2
  )
  SET request->multiple_egas = 0
  SET stat = moverec(request_temp->patient_list,request->patient_list)
  SET stat = moverec(request_temp->pregnancy_list,request->pregnancy_list)
  SET request->position_cd = request_temp->position_cd
  SET request->provider_id = request_temp->provider_id
  SET request->cal_ega_multiple_gest = request_temp->cal_ega_multiple_gest
 ENDIF
 FREE RECORD reply
 RECORD reply(
   1 gestation_info[*]
     2 person_id = f8
     2 encntr_id = f8
     2 pregnancy_id = f8
     2 est_gest_age = i4
     2 current_gest_age = i4
     2 est_delivery_date = dq8
     2 edd_id = f8
     2 gest_age_at_delivery = i4
     2 delivery_date = dq8
     2 delivery_date_tz = i4
     2 delivered_ind = i2
     2 org_id = f8
     2 est_delivery_tz = i4
     2 partial_delivery_ind = i2
     2 multiple_gest_ind = i2
     2 latest_delivery_date = dq8
     2 dynamic_label[*]
       3 label_name = vc
       3 gest_age_at_delivery = i4
       3 delivery_date = dq8
       3 delivery_date_tz = i4
       3 dynamic_label_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH persistscript
 RECORD temp_preglist(
   1 pregnancy_list[*]
     2 person_id = f8
     2 pregnancy_id = f8
     2 org_id = f8
     2 encntr_id = f8
 )
 RECORD temp_preglist_active(
   1 pregnancy_list[*]
     2 person_id = f8
     2 pregnancy_id = f8
     2 preg_onset_dt_tm = dq8
     2 org_id = f8
 )
 RECORD temp_preglist_edd(
   1 pregnancy_list[*]
     2 person_id = f8
     2 pregnancy_id = f8
     2 preg_onset_dt_tm = dq8
     2 edd_ega = i4
     2 pregnancy_estimate_id = f8
     2 est_delivery_dt_tm = dq8
 )
 FREE RECORD multipleegareply
 RECORD multipleegareply(
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
     DECLARE getdynamicorgpref(dtrustid=f8) = i4
     SUBROUTINE getdynamicorgpref(dtrustid)
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
        AND prt.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
        AND prt.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
       JOIN (por
       WHERE outerjoin(prt.organization_id)=por.organization_id
        AND por.person_id=outerjoin(prt.prsnl_id)
        AND por.active_ind=outerjoin(1)
        AND por.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
        AND por.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
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
       confid_cnt = (confid_cnt+ 1)
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
       AND por.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
       AND por.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
      HEAD REPORT
       IF (orgcnt > 0)
        secstat = alterlist(sac_org->organizations,100)
       ENDIF
      DETAIL
       orgcnt = (orgcnt+ 1)
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
        AND oor.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
        AND oor.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
        AND oor.org_org_reltn_cd=nhstrustchild_org_org_reltn_cd)
      HEAD REPORT
       IF (orgcnt > 0)
        secstat = alterlist(sac_org->organizations,10)
       ENDIF
      DETAIL
       IF (oor.related_org_id > 0)
        orgcnt = (orgcnt+ 1)
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
 DECLARE reportfailure(opname=vc,opstatus=vc,targetname=vc,targetvalue=vc) = null
 DECLARE fillsubeventstatus(opname=vc,opstatus=vc,objname=vc,objvalue=vc) = null
 SUBROUTINE reportfailure(opname,opstatus,targetname,targetvalue)
  SET reply->status_data.status = "F"
  CALL fillsubeventstatus(opname,opstatus,targetname,targetvalue)
 END ;Subroutine
 SUBROUTINE fillsubeventstatus(opname,opstatus,objname,objvalue)
   DECLARE dcp_substatus_cnt = i4 WITH protect, noconstant(size(reply->status_data.subeventstatus,5))
   SET dcp_substatus_cnt = (dcp_substatus_cnt+ 1)
   IF (dcp_substatus_cnt != 1)
    SET stat = alter(reply->status_data.subeventstatus,dcp_substatus_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].operationname = trim(opname)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].targetobjectname = trim(objname)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].targetobjectvalue = trim(objvalue)
 END ;Subroutine
 DECLARE failure_ind = i2 WITH noconstant(false)
 DECLARE zero_ind = i2 WITH noconstant(false)
 DECLARE stat = i2 WITH noconstant(false)
 DECLARE error_code = i2 WITH protect, noconstant(0)
 DECLARE error_msg = vc WITH protect, noconstant("")
 DECLARE est_est_preg_start_date = dq8 WITH protect, noconstant(0)
 DECLARE patientidcnt = i4 WITH public, noconstant(size(request->patient_list,5))
 DECLARE pregnancyidcnt = i4 WITH public, noconstant(size(request->pregnancy_list,5))
 DECLARE earliestpregnancydt = dq8 WITH public, noconstant(cnvtdatetime("31-DEC-2100"))
 DECLARE uniquepersoncnt = i4 WITH public, noconstant(0)
 DECLARE indexcount = i4 WITH public, noconstant(0)
 DECLARE standard_preg_duration = i4 WITH protected, noconstant(280)
 DECLARE debug_ind = i2 WITH protect, noconstant(0)
 DECLARE igestationweeks = i4 WITH protect, noconstant(0)
 DECLARE findpregbyperson(null) = null
 DECLARE findpregbyid(null) = null
 DECLARE getpregnancypreferences(null) = null
 DECLARE getegadata(null) = null
 DECLARE checkfordelivery(null) = null
 DECLARE checkformultiplegestation(null) = null
 SET reply->status_data.status = "F"
 IF (validate(request->debug_ind)=1)
  IF ((request->debug_ind=1))
   SET debug_ind = 1
   CALL echo("*DEBUG MODE - ON - DCP_GET_FINAL_EGA*")
  ENDIF
 ENDIF
 IF (patientidcnt > 0
  AND pregnancyidcnt=0)
  SET stat = alterlist(reply->gestation_info,patientidcnt)
  SET stat = alterlist(temp_preglist->pregnancy_list,patientidcnt)
  SELECT INTO "nl:"
   person_id = request->patient_list[d2.seq].patient_id
   FROM (dummyt d2  WITH seq = value(patientidcnt))
   ORDER BY person_id
   HEAD person_id
    uniquepersoncnt = (uniquepersoncnt+ 1), temp_preglist->pregnancy_list[uniquepersoncnt].person_id
     = person_id, temp_preglist->pregnancy_list[uniquepersoncnt].encntr_id = request->patient_list[d2
    .seq].encntr_id
   WITH nocounter
  ;end select
  SET stat = alterlist(temp_preglist->pregnancy_list,uniquepersoncnt)
  IF (preg_org_sec_ind=1)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = uniquepersoncnt),
     encounter e
    PLAN (d)
     JOIN (e
     WHERE (e.encntr_id=temp_preglist->pregnancy_list[d.seq].encntr_id))
    DETAIL
     temp_preglist->pregnancy_list[d.seq].org_id = e.organization_id
    WITH nocounter
   ;end select
  ENDIF
  CALL findpregbyperson(null)
 ELSEIF (pregnancyidcnt > 0
  AND patientidcnt=0)
  SET stat = alterlist(reply->gestation_info,pregnancyidcnt)
  SET stat = alterlist(temp_preglist->pregnancy_list,pregnancyidcnt)
  SELECT INTO "nl:"
   pregnancy_id = request->pregnancy_list[d2.seq].pregnancy_id
   FROM (dummyt d2  WITH seq = value(pregnancyidcnt))
   ORDER BY pregnancy_id
   HEAD pregnancy_id
    uniquepersoncnt = (uniquepersoncnt+ 1), temp_preglist->pregnancy_list[uniquepersoncnt].
    pregnancy_id = pregnancy_id
   WITH nocounter
  ;end select
  SET stat = alterlist(temp_preglist->pregnancy_list,uniquepersoncnt)
  SET stat = alterlist(reply->gestation_info,uniquepersoncnt)
  CALL findpregbyid(null)
 ELSE
  CALL echo("[FAIL]: No data in the request")
  SET failure_ind = true
  GO TO script_end
 ENDIF
 CALL getpregnancypreferences(null)
 CALL getegadata(null)
 CALL checkfordelivery(null)
 IF (validate(request->cal_ega_multiple_gest))
  IF ((request->cal_ega_multiple_gest=1))
   CALL checkformultiplegestation(null)
  ENDIF
 ENDIF
 GO TO script_end
 SUBROUTINE findpregbyperson(null)
   DECLARE uniquepatientcnt = i4 WITH noconstant(size(temp_preglist->pregnancy_list,5))
   DECLARE num = i4 WITH protect, noconstant(0)
   DECLARE expand_size = i4 WITH protect, constant(50)
   DECLARE expand_start = i4 WITH protect, noconstant(1)
   DECLARE expand_stop = i4 WITH protect, noconstant(50)
   DECLARE expand_total = i4 WITH protect, noconstant(0)
   DECLARE active_preg_cnt = i4 WITH protect, noconstant(0)
   DECLARE recs_per_person_cnt = i4 WITH protect, noconstant(0)
   DECLARE person_idx = i4 WITH protect, noconstant(0)
   IF (uniquepatientcnt=0)
    CALL echo("[ZERO]: FindPregByPerson - No patients")
    SET zero_ind = true
    GO TO script_end
   ENDIF
   SET expand_total = (ceil((cnvtreal(uniquepatientcnt)/ expand_size)) * expand_size)
   SET stat = alterlist(temp_preglist->pregnancy_list,expand_total)
   SET stat = alterlist(temp_preglist_active->pregnancy_list,uniquepatientcnt)
   FOR (idx = (uniquepatientcnt+ 1) TO expand_total)
     SET temp_preglist->pregnancy_list[idx].person_id = temp_preglist->pregnancy_list[
     uniquepatientcnt].person_id
   ENDFOR
   DECLARE pregnancyidx = i4 WITH noconstant(0)
   IF (preg_org_sec_ind=0)
    SELECT INTO "nl:"
     FROM pregnancy_instance p,
      problem prb,
      (dummyt d  WITH seq = value((expand_total/ expand_size)))
     PLAN (d
      WHERE assign(expand_start,evaluate(d.seq,1,1,(expand_start+ expand_size)))
       AND assign(expand_stop,(expand_start+ (expand_size - 1))))
      JOIN (p
      WHERE expand(idx,expand_start,expand_stop,p.person_id,temp_preglist->pregnancy_list[idx].
       person_id)
       AND p.active_ind=1
       AND p.preg_end_dt_tm=cnvtdatetime("31-DEC-2100"))
      JOIN (prb
      WHERE prb.problem_id=p.problem_id
       AND prb.active_ind=p.active_ind)
     ORDER BY p.person_id, prb.onset_dt_tm
     HEAD p.person_id
      active_preg_cnt = (active_preg_cnt+ 1), temp_preglist_active->pregnancy_list[active_preg_cnt].
      person_id = p.person_id, temp_preglist_active->pregnancy_list[active_preg_cnt].pregnancy_id = p
      .pregnancy_id,
      temp_preglist_active->pregnancy_list[active_preg_cnt].preg_onset_dt_tm = prb.onset_dt_tm,
      temp_preglist_active->pregnancy_list[active_preg_cnt].org_id = p.organization_id
      IF (prb.onset_dt_tm != null
       AND prb.onset_dt_tm < earliestpregnancydt)
       earliestpregnancydt = prb.onset_dt_tm
      ENDIF
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "nl:"
     FROM pregnancy_instance p,
      problem prb,
      (dummyt d  WITH seq = value((expand_total/ expand_size))),
      (dummyt d1  WITH seq = size(preg_sec_orgs->qual,5))
     PLAN (d
      WHERE assign(expand_start,evaluate(d.seq,1,1,(expand_start+ expand_size)))
       AND assign(expand_stop,(expand_start+ (expand_size - 1))))
      JOIN (p
      WHERE expand(idx,expand_start,expand_stop,p.person_id,temp_preglist->pregnancy_list[idx].
       person_id)
       AND p.active_ind=1
       AND p.preg_end_dt_tm=cnvtdatetime("31-DEC-2100"))
      JOIN (prb
      WHERE prb.problem_id=p.problem_id
       AND prb.active_ind=p.active_ind)
      JOIN (d1
      WHERE (p.organization_id=preg_sec_orgs->qual[d1.seq].org_id))
     ORDER BY p.person_id, prb.onset_dt_tm
     HEAD p.person_id
      person_idx = locateval(idx,1,uniquepatientcnt,p.person_id,temp_preglist->pregnancy_list[idx].
       person_id),
      CALL echo(build("PERSON_IDX : ",person_idx)), recs_per_person_cnt = 0
     DETAIL
      IF ((request->multiple_egas=0)
       AND recs_per_person_cnt=0)
       IF ((((temp_preglist->pregnancy_list[person_idx].encntr_id=0)) OR (person_idx > 0
        AND (temp_preglist->pregnancy_list[person_idx].encntr_id > 0)
        AND (temp_preglist->pregnancy_list[person_idx].org_id=p.organization_id))) )
        active_preg_cnt = (active_preg_cnt+ 1), recs_per_person_cnt = (recs_per_person_cnt+ 1),
        temp_preglist_active->pregnancy_list[active_preg_cnt].person_id = p.person_id,
        temp_preglist_active->pregnancy_list[active_preg_cnt].pregnancy_id = p.pregnancy_id,
        temp_preglist_active->pregnancy_list[active_preg_cnt].preg_onset_dt_tm = prb.onset_dt_tm,
        temp_preglist_active->pregnancy_list[active_preg_cnt].org_id = p.organization_id
        IF (prb.onset_dt_tm != null
         AND prb.onset_dt_tm < earliestpregnancydt)
         earliestpregnancydt = prb.onset_dt_tm
        ENDIF
       ENDIF
      ELSEIF ((request->multiple_egas=1))
       IF ((((temp_preglist->pregnancy_list[person_idx].encntr_id=0)) OR ((temp_preglist->
       pregnancy_list[person_idx].encntr_id > 0)
        AND (temp_preglist->pregnancy_list[person_idx].org_id=p.organization_id))) )
        active_preg_cnt = (active_preg_cnt+ 1), recs_per_person_cnt = (recs_per_person_cnt+ 1)
        IF (active_preg_cnt > size(temp_preglist_active->pregnancy_list,5))
         stat = alterlist(temp_preglist_active->pregnancy_list,(active_preg_cnt+ 9))
        ENDIF
        temp_preglist_active->pregnancy_list[active_preg_cnt].person_id = p.person_id,
        temp_preglist_active->pregnancy_list[active_preg_cnt].pregnancy_id = p.pregnancy_id,
        temp_preglist_active->pregnancy_list[active_preg_cnt].preg_onset_dt_tm = prb.onset_dt_tm,
        temp_preglist_active->pregnancy_list[active_preg_cnt].org_id = p.organization_id
        IF (prb.onset_dt_tm != null
         AND prb.onset_dt_tm < earliestpregnancydt)
         earliestpregnancydt = prb.onset_dt_tm
        ENDIF
       ENDIF
      ENDIF
     FOOT REPORT
      stat = alterlist(temp_preglist_active->pregnancy_list,active_preg_cnt)
     WITH nocounter
    ;end select
   ENDIF
   SET stat = alterlist(temp_preglist_active->pregnancy_list,active_preg_cnt)
   SET stat = alterlist(reply->gestation_info,active_preg_cnt)
   IF (active_preg_cnt=0)
    CALL echo("[ZERO]: FindPregByPerson - No active pregnancies found")
    SET zero_ind = true
    GO TO script_end
   ENDIF
 END ;Subroutine
 SUBROUTINE findpregbyid(null)
   DECLARE uniquepregnancycnt = i4 WITH noconstant(size(temp_preglist->pregnancy_list,5))
   DECLARE num = i4 WITH protect, noconstant(0)
   DECLARE expand_size = i4 WITH protect, constant(50)
   DECLARE expand_start = i4 WITH protect, noconstant(1)
   DECLARE expand_stop = i4 WITH protect, noconstant(50)
   DECLARE expand_total = i4 WITH protect, noconstant(0)
   DECLARE active_preg_cnt = i4 WITH protect, noconstant(0)
   IF (uniquepregnancycnt=0)
    CALL echo("[ZERO]: FindPregById - No pregnancies")
    SET zero_ind = true
    GO TO script_end
   ENDIF
   SET stat = alterlist(temp_preglist_active->pregnancy_list,uniquepregnancycnt)
   SET expand_total = (ceil((cnvtreal(uniquepregnancycnt)/ expand_size)) * expand_size)
   SET stat = alterlist(temp_preglist->pregnancy_list,expand_total)
   FOR (idx = (uniquepregnancycnt+ 1) TO expand_total)
     SET temp_preglist->pregnancy_list[idx].pregnancy_id = temp_preglist->pregnancy_list[
     uniquepregnancycnt].pregnancy_id
   ENDFOR
   SELECT INTO "nl:"
    FROM pregnancy_instance p,
     problem prb,
     (dummyt d  WITH seq = value((expand_total/ expand_size)))
    PLAN (d
     WHERE assign(expand_start,evaluate(d.seq,1,1,(expand_start+ expand_size)))
      AND assign(expand_stop,(expand_start+ (expand_size - 1))))
     JOIN (p
     WHERE expand(idx,expand_start,expand_stop,p.pregnancy_id,temp_preglist->pregnancy_list[idx].
      pregnancy_id)
      AND p.active_ind=1
      AND p.preg_end_dt_tm=cnvtdatetime("31-DEC-2100"))
     JOIN (prb
     WHERE prb.problem_id=p.problem_id
      AND prb.active_ind=p.active_ind)
    ORDER BY p.person_id, prb.onset_dt_tm
    HEAD p.person_id
     active_preg_cnt = (active_preg_cnt+ 1), temp_preglist_active->pregnancy_list[active_preg_cnt].
     person_id = p.person_id, temp_preglist_active->pregnancy_list[active_preg_cnt].pregnancy_id = p
     .pregnancy_id,
     temp_preglist_active->pregnancy_list[active_preg_cnt].preg_onset_dt_tm = prb.onset_dt_tm,
     temp_preglist_active->pregnancy_list[active_preg_cnt].org_id = p.organization_id
     IF (prb.onset_dt_tm != null
      AND prb.onset_dt_tm < earliestpregnancydt)
      earliestpregnancydt = prb.onset_dt_tm
     ENDIF
    WITH nocounter
   ;end select
   SET stat = alterlist(temp_preglist_active->pregnancy_list,active_preg_cnt)
   SET stat = alterlist(reply->gestation_info,active_preg_cnt)
   IF (curqual=0)
    CALL echo("[ZERO]: FindPregById - No active pregnancies found")
    SET zero_ind = true
    GO TO script_end
   ENDIF
 END ;Subroutine
 SUBROUTINE getegadata(null)
   CALL echo("IN GetEGAData subroutine")
   DECLARE num = i4 WITH protect, noconstant(0)
   DECLARE expand_size = i4 WITH protect, constant(50)
   DECLARE expand_start = i4 WITH protect, noconstant(1)
   DECLARE expand_stop = i4 WITH protect, noconstant(50)
   DECLARE expand_total = i4 WITH protect, noconstant(0)
   DECLARE pregnancycnt1 = i4 WITH public, noconstant(size(temp_preglist_active->pregnancy_list,5))
   DECLARE temp_preg_idx = i4 WITH public, noconstant(0)
   IF (pregnancycnt1=0)
    CALL echo("[ZERO]: GetEGAData - No pregnancies")
    SET zero_ind = true
    GO TO script_end
   ENDIF
   SET expand_total = (ceil((cnvtreal(pregnancycnt1)/ expand_size)) * expand_size)
   SET stat = alterlist(temp_preglist_active->pregnancy_list,expand_total)
   FOR (idx = (pregnancycnt1+ 1) TO expand_total)
     SET temp_preglist_active->pregnancy_list[idx].pregnancy_id = temp_preglist_active->
     pregnancy_list[pregnancycnt1].pregnancy_id
   ENDFOR
   SET stat = alterlist(temp_preglist_edd->pregnancy_list,pregnancycnt1)
   SET stat = alterlist(reply->gestation_info,pregnancycnt1)
   DECLARE pregnancy_edd_cnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    pe.pregnancy_id, pe.est_gest_age_days, pe.method_dt_tm,
    pe.pregnancy_estimate_id, pe.est_delivery_dt_tm, pe.entered_dt_tm
    FROM pregnancy_estimate pe,
     (dummyt d  WITH seq = value((expand_total/ expand_size)))
    PLAN (d
     WHERE assign(expand_start,evaluate(d.seq,1,1,(expand_start+ expand_size)))
      AND assign(expand_stop,(expand_start+ (expand_size - 1))))
     JOIN (pe
     WHERE expand(num,expand_start,expand_stop,pe.pregnancy_id,temp_preglist_active->pregnancy_list[
      num].pregnancy_id)
      AND pe.entered_dt_tm != null
      AND pe.active_ind=1)
    ORDER BY pe.pregnancy_id, pe.status_flag DESC
    HEAD REPORT
     preg_indx = 0
    HEAD pe.pregnancy_id
     preg_idx = locateval(idx,1,pregnancycnt1,pe.pregnancy_id,temp_preglist_active->pregnancy_list[
      idx].pregnancy_id)
     IF (preg_idx > 0)
      pregnancy_edd_cnt = (pregnancy_edd_cnt+ 1), temp_preglist_edd->pregnancy_list[pregnancy_edd_cnt
      ].edd_ega = pe.est_gest_age_days, temp_preglist_edd->pregnancy_list[pregnancy_edd_cnt].
      person_id = temp_preglist_active->pregnancy_list[preg_idx].person_id,
      temp_preglist_edd->pregnancy_list[pregnancy_edd_cnt].pregnancy_id = pe.pregnancy_id,
      temp_preglist_edd->pregnancy_list[pregnancy_edd_cnt].preg_onset_dt_tm = temp_preglist_active->
      pregnancy_list[preg_idx].preg_onset_dt_tm, temp_preglist_edd->pregnancy_list[pregnancy_edd_cnt]
      .edd_ega = pe.est_gest_age_days,
      temp_preglist_edd->pregnancy_list[pregnancy_edd_cnt].pregnancy_estimate_id = pe
      .pregnancy_estimate_id, temp_preglist_edd->pregnancy_list[pregnancy_edd_cnt].est_delivery_dt_tm
       = cnvtdatetime(datetimezoneformat(pe.est_delivery_dt_tm,pe.est_delivery_tz,"dd-MMM-yyyy")),
      reply->gestation_info[pregnancy_edd_cnt].est_delivery_tz = pe.est_delivery_tz,
      reply->gestation_info[pregnancy_edd_cnt].current_gest_age = datetimediff(cnvtdatetime(
        datetimezoneformat(cnvtdatetime(curdate,curtime3),pe.est_delivery_tz,"dd-MMM-yyyy hh:mm")),
       datetimeadd(cnvtdatetime(datetimezoneformat(pe.est_delivery_dt_tm,pe.est_delivery_tz,
          "dd-MMM-yyyy")),- (standard_preg_duration))), reply->gestation_info[pregnancy_edd_cnt].
      est_gest_age = pe.est_gest_age_days, reply->gestation_info[pregnancy_edd_cnt].edd_id = pe
      .pregnancy_estimate_id,
      reply->gestation_info[pregnancy_edd_cnt].est_delivery_date = cnvtdatetime(datetimezoneformat(pe
        .est_delivery_dt_tm,pe.est_delivery_tz,"dd-MMM-yyyy hh:mm")), reply->gestation_info[
      pregnancy_edd_cnt].person_id = temp_preglist_active->pregnancy_list[preg_idx].person_id, reply
      ->gestation_info[pregnancy_edd_cnt].pregnancy_id = pe.pregnancy_id,
      reply->gestation_info[pregnancy_edd_cnt].org_id = temp_preglist_active->pregnancy_list[preg_idx
      ].org_id
     ENDIF
    WITH nocounter
   ;end select
   IF (((curqual=0) OR (pregnancy_edd_cnt=0)) )
    CALL echo("[ZERO]: GetEGAData - Active estimate could not be found")
    SET zero_ind = true
    GO TO script_end
   ENDIF
   SET stat = alterlist(temp_preglist_edd->pregnancy_list,pregnancy_edd_cnt)
   SET stat = alterlist(reply->gestation_info,pregnancy_edd_cnt)
 END ;Subroutine
 SUBROUTINE checkfordelivery(null)
   DECLARE i = i4 WITH noconstant(0)
   DECLARE j = i4 WITH noconstant(0)
   DECLARE authstatuscd = f8 WITH constant(uar_get_code_by("MEANING",8,"AUTH"))
   DECLARE unauthstatuscd = f8 WITH constant(uar_get_code_by("MEANING",8,"UNAUTH"))
   DECLARE modifiedstatuscd = f8 WITH constant(uar_get_code_by("MEANING",8,"MODIFIED"))
   DECLARE alteredstatuscd = f8 WITH constant(uar_get_code_by("MEANING",8,"ALTERED"))
   DECLARE delivery_concept_cki = vc WITH constant("CERNER!ASYr9AEYvUr1YoPTCqIGfQ")
   DECLARE num = i4 WITH protect, noconstant(0)
   DECLARE expand_size = i4 WITH protect, constant(20)
   DECLARE expand_start = i4 WITH protect, noconstant(1)
   DECLARE expand_stop = i4 WITH protect, noconstant(20)
   DECLARE expand_total = i4 WITH protect, noconstant(0)
   DECLARE pregnancycnt = i4 WITH public, noconstant(size(temp_preglist_edd->pregnancy_list,5))
   DECLARE temp_preg_idx = i4 WITH public, noconstant(0)
   DECLARE reply_idx = i4 WITH public, noconstant(0)
   IF (pregnancycnt=0)
    CALL echo("[ZERO]: CheckForDelivery - No Pregnancies")
    SET zero_ind = true
    GO TO script_end
   ENDIF
   SET expand_total = (ceil((cnvtreal(pregnancycnt)/ expand_size)) * expand_size)
   SET stat = alterlist(temp_preglist_edd->pregnancy_list,expand_total)
   FOR (idx = (pregnancycnt+ 1) TO expand_total)
     SET temp_preglist_edd->pregnancy_list[idx].person_id = temp_preglist_edd->pregnancy_list[
     pregnancycnt].person_id
   ENDFOR
   SELECT
    IF (preg_org_sec_ind=0)
     FROM clinical_event ce,
      ce_date_result dr,
      code_value cv,
      v500_event_set_explode es,
      (dummyt d  WITH seq = value((expand_total/ expand_size)))
     PLAN (d
      WHERE assign(expand_start,evaluate(d.seq,1,1,(expand_start+ expand_size)))
       AND assign(expand_stop,(expand_start+ (expand_size - 1))))
      JOIN (cv
      WHERE cv.concept_cki=delivery_concept_cki)
      JOIN (es
      WHERE es.event_set_cd=cv.code_value)
      JOIN (ce
      WHERE expand(num,expand_start,expand_stop,ce.person_id,temp_preglist_edd->pregnancy_list[num].
       person_id)
       AND ce.event_cd=es.event_cd
       AND ce.event_cd > 0.0
       AND ce.event_end_dt_tm > cnvtdatetime(cnvtdate(earliestpregnancydt),0)
       AND ce.publish_flag=1
       AND ce.view_level >= 1
       AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00:00")
       AND ce.result_status_cd IN (authstatuscd, unauthstatuscd, modifiedstatuscd, alteredstatuscd))
      JOIN (dr
      WHERE dr.event_id=ce.event_id
       AND dr.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00:00")
       AND dr.date_type_flag=0)
    ELSE
     FROM clinical_event ce,
      ce_date_result dr,
      encounter e,
      code_value cv,
      v500_event_set_explode es,
      (dummyt d1  WITH seq = size(preg_sec_orgs->qual,5)),
      (dummyt d  WITH seq = value((expand_total/ expand_size)))
     PLAN (d
      WHERE assign(expand_start,evaluate(d.seq,1,1,(expand_start+ expand_size)))
       AND assign(expand_stop,(expand_start+ (expand_size - 1))))
      JOIN (cv
      WHERE cv.concept_cki=delivery_concept_cki)
      JOIN (es
      WHERE es.event_set_cd=cv.code_value)
      JOIN (ce
      WHERE expand(num,expand_start,expand_stop,ce.person_id,temp_preglist_edd->pregnancy_list[num].
       person_id)
       AND ce.event_cd=es.event_cd
       AND ce.event_cd > 0.0
       AND ce.event_end_dt_tm > cnvtdatetime(cnvtdate(earliestpregnancydt),0)
       AND ce.publish_flag=1
       AND ce.view_level >= 1
       AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00:00")
       AND ce.result_status_cd IN (authstatuscd, unauthstatuscd, modifiedstatuscd, alteredstatuscd))
      JOIN (dr
      WHERE dr.event_id=ce.event_id
       AND dr.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00:00")
       AND dr.date_type_flag=0)
      JOIN (e
      WHERE e.encntr_id=ce.encntr_id)
      JOIN (d1
      WHERE (e.organization_id=preg_sec_orgs->qual[d1.seq].org_id))
    ENDIF
    INTO "nl:"
    ORDER BY ce.person_id, ce.event_end_dt_tm DESC
    HEAD ce.person_id
     temp_preg_idx = locateval(i,1,pregnancycnt,ce.person_id,temp_preglist_edd->pregnancy_list[i].
      person_id)
     IF (temp_preg_idx > 0)
      IF (dr.result_dt_tm > cnvtdatetime(cnvtdate(temp_preglist_edd->pregnancy_list[temp_preg_idx].
        preg_onset_dt_tm),0))
       IF ((ce.person_id=reply->gestation_info[temp_preg_idx].person_id))
        reply_idx = temp_preg_idx
       ELSE
        reply_idx = locateval(j,1,pregnancycnt,ce.person_id,reply->gestation_info[j].person_id)
       ENDIF
       IF (reply_idx > 0)
        IF ((((temp_preglist_edd->pregnancy_list[temp_preg_idx].edd_ega != 0)) OR (dr.result_dt_tm >
        cnvtdatetime(cnvtdate(temp_preglist_edd->pregnancy_list[temp_preg_idx].preg_onset_dt_tm),0)
        )) )
         reply->gestation_info[reply_idx].current_gest_age = 0, reply->gestation_info[reply_idx].
         est_gest_age = 0, est_preg_start_date = datetimeadd(cnvtdatetime(temp_preglist_edd->
           pregnancy_list[temp_preg_idx].est_delivery_dt_tm),- (standard_preg_duration),0),
         reply->gestation_info[reply_idx].gest_age_at_delivery = datetimediff(cnvtdatetime(
           datetimezoneformat(dr.result_dt_tm,dr.result_tz,"dd-MMM-yyyy hh:mm")),est_preg_start_date),
         reply->gestation_info[reply_idx].delivery_date = dr.result_dt_tm, reply->gestation_info[
         reply_idx].delivery_date_tz = dr.result_tz,
         reply->gestation_info[reply_idx].delivered_ind = 1, reply->gestation_info[reply_idx].
         encntr_id = ce.encntr_id
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE checkformultiplegestation(null)
   CALL echo("IN CheckForMultipleGestation subroutine")
   IF (checkprg("DCP_GET_EGA_MULTIPLE_GESTATION")=0)
    GO TO script_end
   ENDIF
   DECLARE ipatientcnt = i2 WITH protect, noconstant(0)
   DECLARE ipatientidx = i2 WITH protect, noconstant(0)
   DECLARE igestationcnt = i2 WITH protect, noconstant(0)
   DECLARE igestationidx = i2 WITH protect, noconstant(0)
   DECLARE iprovidercnt = i2 WITH protect, noconstant(0)
   DECLARE iprovideridx = i2 WITH protect, noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
   SET ipatientcnt = size(reply->gestation_info,5)
   RECORD multipleegarequest(
     1 person_id = f8
     1 provider_id = f8
     1 position_cd = f8
     1 provider_patient_reltn_cd = f8
   )
   FOR (ipatientidx = 0 TO (ipatientcnt - 1))
     IF (reply->gestation_info[ipatientidx].delivered_ind)
      SET multipleegarequest->person_id = reply->gestation_info[ipatientidx].person_id
      SET multipleegarequest->provider_id = request->provider_id
      SET multipleegarequest->position_cd = request->position_cd
      SET iprovidercnt = size(request->provider_list,5)
      FOR (iprovideridx = 0 TO (iprovidercnt - 1))
        IF ((reply->gestation_info[ipatientidx].person_id=request->provider_list[iprovideridx].
        patient_id))
         IF ((reply->gestation_info[ipatientidx].person_id=request->provider_list[iprovideridx].
         patient_id))
          SET multipleegarequest->provider_patient_reltn_cd = request->provider_list[iprovideridx].
          provider_patient_reltn_cd
         ENDIF
        ENDIF
      ENDFOR
      EXECUTE dcp_get_ega_multiplegestation1  WITH replace("REQUEST",multipleegarequest), replace(
       "REPLY",multipleegareply)
      IF ((multipleegareply->status_data.status="S"))
       IF ((multipleegareply->multiple_gest_ind > 0))
        IF ((multipleegareply->partial_delivery_ind > 0))
         SET reply->gestation_info[ipatientidx].current_gest_age = (reply->gestation_info[ipatientidx
         ].gest_age_at_delivery+ datetimediff(cnvtdatetime(datetimezoneformat(cnvtdatetime(curdate,
             curtime3),reply->gestation_info[ipatientidx].delivery_date_tz,"dd-MMM-yyyy")),
          cnvtdatetime(datetimezoneformat(reply->gestation_info[ipatientidx].delivery_date,reply->
            gestation_info[ipatientidx].delivery_date_tz,"dd-MMM-yyyy"))))
        ELSE
         SET reply->gestation_info[ipatientidx].current_gest_age = (reply->gestation_info[ipatientidx
         ].gest_age_at_delivery+ datetimediff(cnvtdatetime(datetimezoneformat(multipleegareply->
            latest_delivery_date,reply->gestation_info[ipatientidx].delivery_date_tz,"dd-MMM-yyyy")),
          cnvtdatetime(datetimezoneformat(reply->gestation_info[ipatientidx].delivery_date,reply->
            gestation_info[ipatientidx].delivery_date_tz,"dd-MMM-yyyy"))))
        ENDIF
       ENDIF
       SET reply->gestation_info[ipatientidx].partial_delivery_ind = multipleegareply->
       partial_delivery_ind
       SET reply->gestation_info[ipatientidx].multiple_gest_ind = multipleegareply->multiple_gest_ind
       SET reply->gestation_info[ipatientidx].latest_delivery_date = multipleegareply->
       latest_delivery_date
       SET igestationcnt = size(multipleegareply->dynamic_label,5)
       FOR (igestationidx = 1 TO igestationcnt)
         SET stat = alterlist(reply->gestation_info[ipatientidx].dynamic_label,igestationidx)
         SET reply->gestation_info[ipatientidx].dynamic_label[igestationidx].delivery_date_tz =
         multipleegareply->dynamic_label[igestationidx].delivery_date_tz
         SET reply->gestation_info[ipatientidx].dynamic_label[igestationidx].delivery_date =
         multipleegareply->dynamic_label[igestationidx].delivery_date
         IF (cnvtdate(reply->gestation_info[ipatientidx].dynamic_label[igestationidx].delivery_date)=
         cnvtdate(reply->gestation_info[ipatientidx].delivery_date))
          SET reply->gestation_info[ipatientidx].dynamic_label[igestationidx].gest_age_at_delivery =
          reply->gestation_info[ipatientidx].gest_age_at_delivery
         ELSE
          SET reply->gestation_info[ipatientidx].dynamic_label[igestationidx].gest_age_at_delivery =
          (reply->gestation_info[ipatientidx].gest_age_at_delivery+ datetimediff(datetimetrunc(
            multipleegareply->dynamic_label[igestationidx].delivery_date,"dd"),datetimetrunc(reply->
            gestation_info[ipatientidx].delivery_date,"dd")))
         ENDIF
         SET reply->gestation_info[ipatientidx].dynamic_label[igestationidx].label_name =
         multipleegareply->dynamic_label[igestationidx].label_name
         IF ((validate(reply->gestation_info[ipatientidx].dynamic_label[igestationidx].
          dynamic_label_id,- (99.0)) != - (99.0)))
          SET reply->gestation_info[ipatientidx].dynamic_label[igestationidx].dynamic_label_id =
          multipleegareply->dynamic_label[igestationidx].dynamic_label_id
         ENDIF
       ENDFOR
      ELSE
       SET reply->gestation_info[ipatientidx].multiple_gest_ind = 0
       SET reply->gestation_info[ipatientidx].partial_delivery_ind = 0
       IF (debug_ind=1)
        CALL echo("*DCP_GET_EGA_MULTIPLE_GESTATION Failed to return dynamic label information*")
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   CALL echo("EXIT CheckForMultipleGestation subroutine")
 END ;Subroutine
 SUBROUTINE getpregnancypreferences(null)
   DECLARE stat = i2 WITH protect, noconstant(0)
   DECLARE llocateindex = i4 WITH protect, noconstant(0)
   DECLARE hpref = i4 WITH private, noconstant(0)
   DECLARE hgroup = i4 WITH private, noconstant(0)
   DECLARE hrepgroup = i4 WITH private, noconstant(0)
   DECLARE hsection = i4 WITH private, noconstant(0)
   DECLARE hattr = i4 WITH private, noconstant(0)
   DECLARE hentry = i4 WITH private, noconstant(0)
   DECLARE lentrycnt = i4 WITH private, noconstant(0)
   DECLARE lentryidx = i4 WITH private, noconstant(0)
   DECLARE larraysize = i4 WITH private, noconstant(0)
   DECLARE ilen = i4 WITH private, noconstant(255)
   DECLARE lattrcnt = i4 WITH private, noconstant(0)
   DECLARE lattridx = i4 WITH private, noconstant(0)
   DECLARE lvalcnt = i4 WITH private, noconstant(0)
   DECLARE sentryname = c255 WITH private, noconstant("")
   DECLARE sattrname = c255 WITH private, noconstant("")
   DECLARE sval = c255 WITH private, noconstant("")
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
     SET stat = uar_prefgetentryname(hentry,sentryname,ilen)
     IF (trim(sentryname)="gestational period")
      CALL echo("sEntryName")
      CALL echo(sentryname)
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
          IF (debug_ind=1)
           CALL echo(build2(concat("entry: ",trim(sentryname),"  value: ",trim(sval))))
          ENDIF
          SET igestationweeks = cnvtint(trim(sval))
          SET standard_preg_duration = (igestationweeks * 7)
         ENDIF
         SET lattridx = lattrcnt
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
   CALL uar_prefdestroysection(hsection)
   CALL uar_prefdestroygroup(hgroup)
   CALL uar_prefdestroyinstance(hpref)
   IF (igestationweeks <= 0)
    CALL fillsubeventstatus("dcp_get_final_ega","F","GetPregnancyPreferences",
     "Prefs are not defined properly")
   ENDIF
 END ;Subroutine
#script_end
 SET error_code = error(error_msg,1)
 IF (error_code != 0)
  CALL echo(build("ERROR: ",error_msg))
  SET reply->status_data.status = "F"
  CALL fillsubeventstatus("ERROR","F","dcp_get_final_ega",error_msg)
 ELSEIF (failure_ind=true)
  CALL echo("*Get Final EGA Script failed*")
  SET reply->status_data.status = "F"
 ELSEIF (zero_ind=true)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 FREE RECORD temp_preglist
 FREE RECORD temp_preglist_active
 FREE RECORD temp_preglist_edd
 CALL echo("Script was last modified on: 0015 11/7/19")
 SET modify = nopredeclare
END GO
