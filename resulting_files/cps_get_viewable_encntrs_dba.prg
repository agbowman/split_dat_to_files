CREATE PROGRAM cps_get_viewable_encntrs:dba
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
   1 best_encntr_id = f8
   1 security_on = i2
   1 qual_knt = i4
   1 qual[*]
     2 encntr_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET cdf_meaning = fillstring(12," ")
 SET encntr_type_ind = 0
 SET encntr_status_ind = 0
 SET encntr_future_display = 1
 IF ((request->use_filters=0))
  GO TO determine_select_type
 ENDIF
 FREE RECORD encntr_type
 RECORD encntr_type(
   1 encntr_qual[*]
     2 encntr_type = vc
     2 type_cd = f8
 )
 SET ierrcode = error(serrmsg,0)
 SET ierrcode = 0
 SELECT INTO "NL:"
  a.app_prefs_id, n.name_value_prefs_id
  FROM app_prefs a,
   name_value_prefs n
  PLAN (a
   WHERE a.prsnl_id=0
    AND a.position_cd=0
    AND (a.application_number=reqinfo->updt_app))
   JOIN (n
   WHERE n.parent_entity_id=a.app_prefs_id
    AND n.parent_entity_name="APP_PREFS"
    AND n.pvc_name="ENCNTR_TYPE_DISPLAY")
  HEAD REPORT
   count1 = 0, start = 1
   FOR (i = 1 TO 256)
     IF (substring(i,1,n.pvc_value) IN (",", " "))
      IF (substring(start,(i - start),n.pvc_value) > " "
       AND  NOT (substring(start,(i - start),n.pvc_value)=",")
       AND  NOT (substring(start,(i - start),n.pvc_value)=", "))
       count1 += 1
       IF (size(encntr_type->encntr_qual,5) <= count1)
        stat = alterlist(encntr_type->encntr_qual,count1)
       ENDIF
       encntr_type->encntr_qual[count1].encntr_type = substring(start,(i - start),n.pvc_value)
       IF (((i+ 2) <= 256))
        IF (substring(i,2,n.pvc_value)=", ")
         start = (i+ 2)
        ELSEIF (substring(i,2,n.pvc_value)="  ")
         i = 256
        ELSE
         start = (i+ 1)
        ENDIF
       ELSE
        start = (i+ 1)
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,0)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "ENCNTR_TYPE_CHK"
  GO TO exit_script
 ELSEIF (size(encntr_type->encntr_qual,5) < 1)
  SET encntr_type_ind = 0
 ELSE
  SET ierrcode = error(serrmsg,0)
  SET ierrcode = 0
  SELECT INTO "nl:"
   c.cdf_meaning
   FROM code_value c,
    (dummyt d  WITH seq = value(size(encntr_type->encntr_qual,5)))
   PLAN (d
    WHERE d.seq > 0)
    JOIN (c
    WHERE c.code_set=69
     AND (c.display_key=encntr_type->encntr_qual[d.seq].encntr_type)
     AND c.active_ind=1)
   HEAD c.cdf_meaning
    encntr_type->encntr_qual[d.seq].type_cd = c.code_value
   WITH nocounter
  ;end select
  SET ierrcode = error(serrmsg,0)
  IF (ierrcode > 0)
   SET failed = select_error
   SET table_name = "ENCNTR_TYPE_PARSE"
   GO TO exit_script
  ELSEIF (curqual < 1)
   SET encntr_type_ind = 0
  ELSE
   SET encntr_type_ind = 1
  ENDIF
 ENDIF
 CALL echorecord(encntr_type)
 FREE RECORD encntr_status
 RECORD encntr_status(
   1 status_qual[*]
     2 encntr_status = vc
     2 status_cd = f8
 )
 SET ierrcode = error(serrmsg,0)
 SET ierrcode = 0
 SELECT INTO "NL:"
  a.app_prefs_id, n.name_value_prefs_id
  FROM app_prefs a,
   name_value_prefs n
  PLAN (a
   WHERE a.prsnl_id=0
    AND a.position_cd=0
    AND (a.application_number=reqinfo->updt_app))
   JOIN (n
   WHERE n.parent_entity_id=a.app_prefs_id
    AND n.parent_entity_name="APP_PREFS"
    AND n.pvc_name="ENCNTR_STATUS_DISPLAY")
  HEAD REPORT
   count1 = 0, start = 1
   FOR (i = 1 TO 256)
     IF (substring(i,1,n.pvc_value) IN (",", " "))
      IF (substring(start,(i - start),n.pvc_value) > " "
       AND  NOT (substring(start,(i - start),n.pvc_value)=",")
       AND  NOT (substring(start,(i - start),n.pvc_value)=", "))
       count1 += 1
       IF (size(encntr_status->status_qual,5) <= count1)
        stat = alterlist(encntr_status->status_qual,count1)
       ENDIF
       encntr_status->status_qual[count1].encntr_status = substring(start,(i - start),n.pvc_value)
       IF (((i+ 2) <= 256))
        IF (substring(i,2,n.pvc_value)=", ")
         start = (i+ 2)
        ELSEIF (substring(i,2,n.pvc_value)="  ")
         i = 256
        ELSE
         start = (i+ 1)
        ENDIF
       ELSE
        start = (i+ 1)
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,0)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "ENCNTR_STATUS_CHK"
  GO TO exit_script
 ELSEIF (size(encntr_status->status_qual,5) < 1)
  SET encntr_status_ind = 0
 ELSE
  SET ierrcode = error(serrmsg,0)
  SET ierrcode = 0
  SELECT INTO "nl:"
   c.cdf_meaning
   FROM code_value c,
    (dummyt d  WITH seq = value(size(encntr_status->status_qual,5)))
   PLAN (d
    WHERE d.seq > 0)
    JOIN (c
    WHERE c.code_set=261
     AND (c.cdf_meaning=encntr_status->status_qual[d.seq].encntr_status)
     AND c.active_ind=1)
   HEAD c.cdf_meaning
    encntr_status->status_qual[d.seq].status_cd = c.code_value
   WITH nocounter
  ;end select
  SET ierrcode = error(serrmsg,0)
  IF (ierrcode > 0)
   SET failed = select_error
   SET table_name = "ENCNTR_STATUS_PARSE"
   GO TO exit_script
  ELSEIF (curqual < 1)
   SET encntr_status_ind = 0
  ELSE
   SET encntr_status_ind = 1
  ENDIF
 ENDIF
 CALL echorecord(encntr_status)
 SET ierrcode = error(serrmsg,0)
 SET ierrcode = 0
 SELECT INTO "NL:"
  a.app_prefs_id, n.name_value_prefs_id
  FROM app_prefs a,
   name_value_prefs n
  PLAN (a
   WHERE a.prsnl_id=0
    AND a.position_cd=0
    AND (a.application_number=reqinfo->updt_app))
   JOIN (n
   WHERE n.parent_entity_id=a.app_prefs_id
    AND n.parent_entity_name="APP_PREFS"
    AND n.pvc_name="ENCNTR_FUTURE_DISPLAY")
  HEAD REPORT
   encntr_future_display = cnvtint(n.pvc_value)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,0)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "ENCNTR_FUTURE_CHK"
  GO TO exit_script
 ENDIF
#determine_select_type
 FREE RECORD temp1
 RECORD temp1(
   1 elist[*]
     2 el
       3 encntr_id = f8
       3 reg_dt_tm = dq8
       3 reg_dt_null = i2
       3 disch_dt_tm = dq8
       3 disch_dt_null = i2
       3 encntr_type_class_cd = f8
       3 encntr_status_cd = f8
 )
 FREE RECORD temp2
 RECORD temp2(
   1 elist[*]
     2 el
       3 encntr_id = f8
       3 reg_dt_tm = dq8
       3 reg_dt_null = i2
       3 disch_dt_tm = dq8
       3 disch_dt_null = i2
       3 encntr_type_class_cd = f8
       3 encntr_status_cd = f8
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
 SET reply->security_on = security_on
 IF (security_on=1
  AND org_knt < 1)
  GO TO exit_script
 ENDIF
 SET cancelled_cd = 0.0
 SET code_value = 0.0
 SET code_set = 261
 SET cdf_meaning = "CANCELLED"
 EXECUTE cpm_get_cd_for_cdf
 SET cancelled_cd = code_value
 CALL echo("***")
 CALL echo(build("***   encntr_future_display :",encntr_future_display))
 CALL echo(build("***   encntr_type_ind       :",encntr_type_ind))
 CALL echo(build("***   encntr_status_ind     :",encntr_status_ind))
 CALL echo("***")
 IF (encntr_type_ind=1
  AND encntr_status_ind=1)
  CALL echo("***")
  CALL echo("***   GET_TYPE_STATUS")
  CALL echo("***")
  GO TO get_type_status
 ELSEIF (encntr_type_ind=1)
  CALL echo("***")
  CALL echo("***   GET_TYPE")
  CALL echo("***")
  GO TO get_type
 ELSEIF (encntr_status_ind=1)
  CALL echo("***")
  CALL echo("***   GET_STATUS")
  CALL echo("***")
  GO TO get_status
 ELSE
  CALL echo("***")
  CALL echo("***   GET_ALL")
  CALL echo("***")
  GO TO get_all
 ENDIF
#get_type_status
 SET ierrcode = error(serrmsg,0)
 SET ierrcode = 0
 SELECT
  IF (security_on=1
   AND confid_ind=1
   AND encntr_future_display=1)
   FROM encounter e,
    (dummyt d  WITH seq = value(size(encntr_type->encntr_qual,5))),
    (dummyt d1  WITH seq = value(size(encntr_status->status_qual,5))),
    (dummyt d2  WITH seq = value(temp->org_cnt)),
    code_value cv
   PLAN (d
    WHERE d.seq > 0)
    JOIN (d1
    WHERE d1.seq > 0)
    JOIN (d2
    WHERE d2.seq > 0)
    JOIN (e
    WHERE (e.person_id=request->person_id)
     AND ((e.encntr_type_class_cd+ 0)=encntr_type->encntr_qual[d.seq].type_cd)
     AND ((e.encntr_status_cd+ 0)=encntr_status->status_qual[d1.seq].status_cd)
     AND ((e.organization_id+ 0)=temp->orglist[d2.seq].org_id)
     AND ((e.encntr_status_cd+ 0) != cancelled_cd)
     AND ((e.active_ind+ 0)=1))
    JOIN (cv
    WHERE cv.code_value=e.confid_level_cd
     AND (cv.collation_seq <= temp->orglist[d2.seq].confid_level))
  ELSEIF (security_on=1
   AND confid_ind=0
   AND encntr_future_display=1)
   FROM encounter e,
    (dummyt d  WITH seq = value(size(encntr_type->encntr_qual,5))),
    (dummyt d1  WITH seq = value(size(encntr_status->status_qual,5))),
    (dummyt d2  WITH seq = value(temp->org_cnt))
   PLAN (d
    WHERE d.seq > 0)
    JOIN (d1
    WHERE d1.seq > 0)
    JOIN (d2
    WHERE d2.seq > 0)
    JOIN (e
    WHERE (e.person_id=request->person_id)
     AND ((e.encntr_type_class_cd+ 0)=encntr_type->encntr_qual[d.seq].type_cd)
     AND ((e.encntr_status_cd+ 0)=encntr_status->status_qual[d1.seq].status_cd)
     AND ((e.organization_id+ 0)=temp->orglist[d2.seq].org_id)
     AND ((e.encntr_status_cd+ 0) != cancelled_cd)
     AND ((e.active_ind+ 0)=1))
  ELSEIF (security_on=1
   AND confid_ind=1)
   FROM encounter e,
    (dummyt d  WITH seq = value(size(encntr_type->encntr_qual,5))),
    (dummyt d1  WITH seq = value(size(encntr_status->status_qual,5))),
    (dummyt d2  WITH seq = value(temp->org_cnt)),
    code_value cv
   PLAN (d
    WHERE d.seq > 0)
    JOIN (d1
    WHERE d1.seq > 0)
    JOIN (d2
    WHERE d2.seq > 0)
    JOIN (e
    WHERE (e.person_id=request->person_id)
     AND ((e.encntr_type_class_cd+ 0)=encntr_type->encntr_qual[d.seq].type_cd)
     AND ((e.encntr_status_cd+ 0)=encntr_status->status_qual[d1.seq].status_cd)
     AND ((e.organization_id+ 0)=temp->orglist[d2.seq].org_id)
     AND ((e.reg_dt_tm+ 0) <= cnvtdatetime(curdate,curtime))
     AND ((e.encntr_status_cd+ 0) != cancelled_cd)
     AND ((e.active_ind+ 0)=1))
    JOIN (cv
    WHERE cv.code_value=e.confid_level_cd
     AND (cv.collation_seq <= temp->orglist[d2.seq].confid_level))
  ELSEIF (security_on=1)
   FROM encounter e,
    (dummyt d  WITH seq = value(size(encntr_type->encntr_qual,5))),
    (dummyt d1  WITH seq = value(size(encntr_status->status_qual,5))),
    (dummyt d2  WITH seq = value(temp->org_cnt))
   PLAN (d
    WHERE d.seq > 0)
    JOIN (d1
    WHERE d1.seq > 0)
    JOIN (d2
    WHERE d2.seq > 0)
    JOIN (e
    WHERE (e.person_id=request->person_id)
     AND ((e.encntr_type_class_cd+ 0)=encntr_type->encntr_qual[d.seq].type_cd)
     AND ((e.encntr_status_cd+ 0)=encntr_status->status_qual[d1.seq].status_cd)
     AND ((e.organization_id+ 0)=temp->orglist[d2.seq].org_id)
     AND ((e.reg_dt_tm+ 0) <= cnvtdatetime(curdate,curtime))
     AND ((e.encntr_status_cd+ 0) != cancelled_cd)
     AND ((e.active_ind+ 0)=1))
  ELSEIF (encntr_future_display=1)
   FROM encounter e,
    (dummyt d  WITH seq = value(size(encntr_type->encntr_qual,5))),
    (dummyt d1  WITH seq = value(size(encntr_status->status_qual,5)))
   PLAN (d
    WHERE d.seq > 0)
    JOIN (d1
    WHERE d1.seq > 0)
    JOIN (e
    WHERE (e.person_id=request->person_id)
     AND ((e.encntr_type_class_cd+ 0)=encntr_type->encntr_qual[d.seq].type_cd)
     AND ((e.encntr_status_cd+ 0)=encntr_status->status_qual[d1.seq].status_cd)
     AND ((e.encntr_status_cd+ 0) != cancelled_cd)
     AND ((e.active_ind+ 0)=1))
  ELSE
   FROM encounter e,
    (dummyt d  WITH seq = value(size(encntr_type->encntr_qual,5))),
    (dummyt d1  WITH seq = value(size(encntr_status->status_qual,5)))
   PLAN (d
    WHERE d.seq > 0)
    JOIN (d1
    WHERE d1.seq > 0)
    JOIN (e
    WHERE (e.person_id=request->person_id)
     AND ((e.encntr_type_class_cd+ 0)=encntr_type->encntr_qual[d.seq].type_cd)
     AND ((e.encntr_status_cd+ 0)=encntr_status->status_qual[d1.seq].status_cd)
     AND ((e.reg_dt_tm+ 0) <= cnvtdatetime(curdate,curtime))
     AND ((e.encntr_status_cd+ 0) != cancelled_cd)
     AND ((e.active_ind+ 0)=1))
  ENDIF
  DISTINCT INTO "NL:"
  e.encntr_id, e.person_id, e.encntr_type_class_cd,
  e.active_status_cd, e.reg_dt_tm, disch_null = nullind(e.disch_dt_tm),
  reg_null = nullind(e.reg_dt_tm)
  ORDER BY cnvtdatetime(e.reg_dt_tm) DESC, e.encntr_id DESC
  HEAD REPORT
   knt = 0, stat = alterlist(reply->qual,10), stat = alterlist(temp1->elist,10)
  DETAIL
   knt += 1
   IF (mod(knt,10)=1
    AND knt != 1)
    stat = alterlist(reply->qual,(knt+ 9)), stat = alterlist(temp1->elist,(knt+ 9))
   ENDIF
   reply->qual[knt].encntr_id = e.encntr_id, temp1->elist[knt].el.encntr_id = e.encntr_id, temp1->
   elist[knt].el.encntr_type_class_cd = e.encntr_type_class_cd,
   temp1->elist[knt].el.encntr_status_cd = e.encntr_status_cd
   IF (reg_null=0)
    temp1->elist[knt].el.reg_dt_tm = cnvtdatetime(e.reg_dt_tm), temp1->elist[knt].el.reg_dt_null = 0
   ELSE
    temp1->elist[knt].el.reg_dt_null = 1
   ENDIF
   IF (disch_null=0)
    temp1->elist[knt].el.disch_dt_tm = cnvtdatetime(e.disch_dt_tm), temp1->elist[knt].el.
    disch_dt_null = 0
   ELSE
    temp1->elist[knt].el.disch_dt_null = 1
   ENDIF
  FOOT REPORT
   reply->qual_knt = knt, stat = alterlist(reply->qual,knt), stat = alterlist(temp1->elist,knt)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,0)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "GET_TYPE_STATUS"
  GO TO exit_script
 ENDIF
 GO TO find_best
#get_type
 SET ierrcode = error(serrmsg,0)
 SET ierrcode = 0
 SELECT
  IF (security_on=1
   AND confid_ind=1
   AND encntr_future_display=1)
   FROM encounter e,
    (dummyt d  WITH seq = value(size(encntr_type->encntr_qual,5))),
    (dummyt d2  WITH seq = value(temp->org_cnt)),
    code_value cv
   PLAN (d
    WHERE d.seq > 0)
    JOIN (d2
    WHERE d2.seq > 0)
    JOIN (e
    WHERE (e.person_id=request->person_id)
     AND ((e.encntr_type_class_cd+ 0)=encntr_type->encntr_qual[d.seq].type_cd)
     AND ((e.organization_id+ 0)=temp->orglist[d2.seq].org_id)
     AND ((e.encntr_status_cd+ 0) != cancelled_cd)
     AND ((e.active_ind+ 0)=1))
    JOIN (cv
    WHERE cv.code_value=e.confid_level_cd
     AND (cv.collation_seq <= temp->orglist[d2.seq].confid_level))
  ELSEIF (security_on=1
   AND confid_ind=0
   AND encntr_future_display=1)
   FROM encounter e,
    (dummyt d  WITH seq = value(size(encntr_type->encntr_qual,5))),
    (dummyt d2  WITH seq = value(temp->org_cnt))
   PLAN (d
    WHERE d.seq > 0)
    JOIN (d2
    WHERE d2.seq > 0)
    JOIN (e
    WHERE (e.person_id=request->person_id)
     AND ((e.encntr_type_class_cd+ 0)=encntr_type->encntr_qual[d.seq].type_cd)
     AND ((e.organization_id+ 0)=temp->orglist[d2.seq].org_id)
     AND ((e.encntr_status_cd+ 0) != cancelled_cd)
     AND ((e.active_ind+ 0)=1))
  ELSEIF (security_on=1
   AND confid_ind=1)
   FROM encounter e,
    (dummyt d  WITH seq = value(size(encntr_type->encntr_qual,5))),
    (dummyt d2  WITH seq = value(temp->org_cnt)),
    code_value cv
   PLAN (d
    WHERE d.seq > 0)
    JOIN (d2
    WHERE d2.seq > 0)
    JOIN (e
    WHERE (e.person_id=request->person_id)
     AND ((e.encntr_type_class_cd+ 0)=encntr_type->encntr_qual[d.seq].type_cd)
     AND ((e.organization_id+ 0)=temp->orglist[d2.seq].org_id)
     AND ((e.reg_dt_tm+ 0) <= cnvtdatetime(curdate,curtime))
     AND ((e.encntr_status_cd+ 0) != cancelled_cd)
     AND ((e.active_ind+ 0)=1))
    JOIN (cv
    WHERE cv.code_value=e.confid_level_cd
     AND (cv.collation_seq <= temp->orglist[d2.seq].confid_level))
  ELSEIF (security_on=1)
   FROM encounter e,
    (dummyt d  WITH seq = value(size(encntr_type->encntr_qual,5))),
    (dummyt d2  WITH seq = value(temp->org_cnt))
   PLAN (d
    WHERE d.seq > 0)
    JOIN (d2
    WHERE d2.seq > 0)
    JOIN (e
    WHERE (e.person_id=request->person_id)
     AND ((e.encntr_type_class_cd+ 0)=encntr_type->encntr_qual[d.seq].type_cd)
     AND ((e.organization_id+ 0)=temp->orglist[d2.seq].org_id)
     AND ((e.reg_dt_tm+ 0) <= cnvtdatetime(curdate,curtime))
     AND ((e.encntr_status_cd+ 0) != cancelled_cd)
     AND ((e.active_ind+ 0)=1))
  ELSEIF (encntr_future_display=1)
   FROM encounter e,
    (dummyt d  WITH seq = value(size(encntr_type->encntr_qual,5)))
   PLAN (d
    WHERE d.seq > 0)
    JOIN (e
    WHERE (e.person_id=request->person_id)
     AND ((e.encntr_type_class_cd+ 0)=encntr_type->encntr_qual[d.seq].type_cd)
     AND ((e.encntr_status_cd+ 0) != cancelled_cd)
     AND ((e.active_ind+ 0)=1))
  ELSE
   FROM encounter e,
    (dummyt d  WITH seq = value(size(encntr_type->encntr_qual,5)))
   PLAN (d
    WHERE d.seq > 0)
    JOIN (e
    WHERE (e.person_id=request->person_id)
     AND ((e.encntr_type_class_cd+ 0)=encntr_type->encntr_qual[d.seq].type_cd)
     AND ((e.reg_dt_tm+ 0) <= cnvtdatetime(curdate,curtime))
     AND ((e.encntr_status_cd+ 0) != cancelled_cd)
     AND ((e.active_ind+ 0)=1))
  ENDIF
  DISTINCT INTO "NL:"
  e.encntr_id, e.person_id, e.encntr_type_class_cd,
  e.active_status_cd, e.reg_dt_tm, disch_null = nullind(e.disch_dt_tm),
  reg_null = nullind(e.reg_dt_tm)
  ORDER BY cnvtdatetime(e.reg_dt_tm) DESC, e.encntr_id DESC
  HEAD REPORT
   knt = 0, stat = alterlist(reply->qual,10), stat = alterlist(temp1->elist,10)
  DETAIL
   knt += 1
   IF (mod(knt,10)=1
    AND knt != 1)
    stat = alterlist(reply->qual,(knt+ 9)), stat = alterlist(temp1->elist,(knt+ 9))
   ENDIF
   reply->qual[knt].encntr_id = e.encntr_id, temp1->elist[knt].el.encntr_id = e.encntr_id, temp1->
   elist[knt].el.encntr_type_class_cd = e.encntr_type_class_cd,
   temp1->elist[knt].el.encntr_status_cd = e.encntr_status_cd
   IF (reg_null=0)
    temp1->elist[knt].el.reg_dt_tm = cnvtdatetime(e.reg_dt_tm), temp1->elist[knt].el.reg_dt_null = 0
   ELSE
    temp1->elist[knt].el.reg_dt_null = 1
   ENDIF
   IF (disch_null=0)
    temp1->elist[knt].el.disch_dt_tm = cnvtdatetime(e.disch_dt_tm), temp1->elist[knt].el.
    disch_dt_null = 0
   ELSE
    temp1->elist[knt].el.disch_dt_null = 1
   ENDIF
  FOOT REPORT
   reply->qual_knt = knt, stat = alterlist(reply->qual,knt), stat = alterlist(temp1->elist,knt)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,0)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "GET_TYPE"
  GO TO exit_script
 ENDIF
 GO TO find_best
#get_status
 SET ierrcode = error(serrmsg,0)
 SET ierrcode = 0
 SELECT
  IF (security_on=1
   AND confid_ind=1
   AND encntr_future_display=1)
   FROM encounter e,
    (dummyt d1  WITH seq = value(size(encntr_status->status_qual,5))),
    (dummyt d2  WITH seq = value(temp->org_cnt)),
    code_value cv
   PLAN (d1
    WHERE d1.seq > 0)
    JOIN (d2
    WHERE d2.seq > 0)
    JOIN (e
    WHERE (e.person_id=request->person_id)
     AND ((e.encntr_status_cd+ 0)=encntr_status->status_qual[d1.seq].status_cd)
     AND ((e.organization_id+ 0)=temp->orglist[d2.seq].org_id)
     AND ((e.encntr_status_cd+ 0) != cancelled_cd)
     AND ((e.active_ind+ 0)=1))
    JOIN (cv
    WHERE cv.code_value=e.confid_level_cd
     AND (cv.collation_seq <= temp->orglist[d2.seq].confid_level))
  ELSEIF (security_on=1
   AND confid_ind=0
   AND encntr_future_display=1)
   FROM encounter e,
    (dummyt d1  WITH seq = value(size(encntr_status->status_qual,5))),
    (dummyt d2  WITH seq = value(temp->org_cnt))
   PLAN (d1
    WHERE d1.seq > 0)
    JOIN (d2
    WHERE d2.seq > 0)
    JOIN (e
    WHERE (e.person_id=request->person_id)
     AND ((e.encntr_status_cd+ 0)=encntr_status->status_qual[d1.seq].status_cd)
     AND ((e.organization_id+ 0)=temp->orglist[d2.seq].org_id)
     AND ((e.encntr_status_cd+ 0) != cancelled_cd)
     AND ((e.active_ind+ 0)=1))
  ELSEIF (security_on=1
   AND confid_ind=1)
   FROM encounter e,
    (dummyt d1  WITH seq = value(size(encntr_status->status_qual,5))),
    (dummyt d2  WITH seq = value(temp->org_cnt)),
    code_value cv
   PLAN (d1
    WHERE d1.seq > 0)
    JOIN (d2
    WHERE d2.seq > 0)
    JOIN (e
    WHERE (e.person_id=request->person_id)
     AND ((e.encntr_status_cd+ 0)=encntr_status->status_qual[d1.seq].status_cd)
     AND ((e.organization_id+ 0)=temp->orglist[d2.seq].org_id)
     AND ((e.reg_dt_tm+ 0) <= cnvtdatetime(curdate,curtime))
     AND ((e.encntr_status_cd+ 0) != cancelled_cd)
     AND ((e.active_ind+ 0)=1))
    JOIN (cv
    WHERE cv.code_value=e.confid_level_cd
     AND (cv.collation_seq <= temp->orglist[d2.seq].confid_level))
  ELSEIF (security_on=1)
   FROM encounter e,
    (dummyt d1  WITH seq = value(size(encntr_status->status_qual,5))),
    (dummyt d2  WITH seq = value(temp->org_cnt))
   PLAN (d1
    WHERE d1.seq > 0)
    JOIN (d2
    WHERE d2.seq > 0)
    JOIN (e
    WHERE (e.person_id=request->person_id)
     AND ((e.encntr_status_cd+ 0)=encntr_status->status_qual[d1.seq].status_cd)
     AND ((e.organization_id+ 0)=temp->orglist[d2.seq].org_id)
     AND ((e.reg_dt_tm+ 0) <= cnvtdatetime(curdate,curtime))
     AND ((e.encntr_status_cd+ 0) != cancelled_cd)
     AND ((e.active_ind+ 0)=1))
  ELSEIF (encntr_future_display=1)
   FROM encounter e,
    (dummyt d1  WITH seq = value(size(encntr_status->status_qual,5)))
   PLAN (d1
    WHERE d1.seq > 0)
    JOIN (e
    WHERE (e.person_id=request->person_id)
     AND ((e.encntr_status_cd+ 0)=encntr_status->status_qual[d1.seq].status_cd)
     AND ((e.encntr_status_cd+ 0) != cancelled_cd)
     AND ((e.active_ind+ 0)=1))
  ELSE
   FROM encounter e,
    (dummyt d1  WITH seq = value(size(encntr_status->status_qual,5)))
   PLAN (d1
    WHERE d1.seq > 0)
    JOIN (e
    WHERE (e.person_id=request->person_id)
     AND ((e.encntr_status_cd+ 0)=encntr_status->status_qual[d1.seq].status_cd)
     AND ((e.reg_dt_tm+ 0) <= cnvtdatetime(curdate,curtime))
     AND ((e.encntr_status_cd+ 0) != cancelled_cd)
     AND ((e.active_ind+ 0)=1))
  ENDIF
  DISTINCT INTO "NL:"
  e.encntr_id, e.person_id, e.encntr_type_class_cd,
  e.active_status_cd, e.reg_dt_tm, disch_null = nullind(e.disch_dt_tm),
  reg_null = nullind(e.reg_dt_tm)
  ORDER BY cnvtdatetime(e.reg_dt_tm) DESC, e.encntr_id DESC
  HEAD REPORT
   knt = 0, stat = alterlist(reply->qual,10), stat = alterlist(temp1->elist,10)
  DETAIL
   knt += 1
   IF (mod(knt,10)=1
    AND knt != 1)
    stat = alterlist(reply->qual,(knt+ 9)), stat = alterlist(temp1->elist,(knt+ 9))
   ENDIF
   reply->qual[knt].encntr_id = e.encntr_id, temp1->elist[knt].el.encntr_id = e.encntr_id, temp1->
   elist[knt].el.encntr_type_class_cd = e.encntr_type_class_cd,
   temp1->elist[knt].el.encntr_status_cd = e.encntr_status_cd
   IF (reg_null=0)
    temp1->elist[knt].el.reg_dt_tm = cnvtdatetime(e.reg_dt_tm), temp1->elist[knt].el.reg_dt_null = 0
   ELSE
    temp1->elist[knt].el.reg_dt_null = 1
   ENDIF
   IF (disch_null=0)
    temp1->elist[knt].el.disch_dt_tm = cnvtdatetime(e.disch_dt_tm), temp1->elist[knt].el.
    disch_dt_null = 0
   ELSE
    temp1->elist[knt].el.disch_dt_null = 1
   ENDIF
  FOOT REPORT
   reply->qual_knt = knt, stat = alterlist(reply->qual,knt), stat = alterlist(temp1->elist,knt)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,0)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "GET_STATUS"
  GO TO exit_script
 ENDIF
 GO TO find_best
#get_all
 SET ierrcode = error(serrmsg,0)
 SET ierrcode = 0
 CALL echo("***")
 CALL echo(build("***   SECURITY_ON           :",security_on))
 CALL echo(build("***   CONFID_IND            :",confid_ind))
 CALL echo(build("***   ENCNTR_FUTURE_DISPLAY :",encntr_future_display))
 CALL echo("***")
 SELECT
  IF (security_on=1
   AND confid_ind=1
   AND encntr_future_display=1)
   FROM encounter e,
    (dummyt d2  WITH seq = value(temp->org_cnt)),
    code_value cv
   PLAN (d2
    WHERE d2.seq > 0)
    JOIN (e
    WHERE (e.person_id=request->person_id)
     AND ((e.organization_id+ 0)=temp->orglist[d2.seq].org_id)
     AND ((e.encntr_status_cd+ 0) != cancelled_cd)
     AND ((e.active_ind+ 0)=1))
    JOIN (cv
    WHERE cv.code_value=e.confid_level_cd
     AND (cv.collation_seq <= temp->orglist[d2.seq].confid_level))
  ELSEIF (security_on=1
   AND confid_ind=0
   AND encntr_future_display=1)
   FROM encounter e,
    (dummyt d2  WITH seq = value(temp->org_cnt))
   PLAN (d2
    WHERE d2.seq > 0)
    JOIN (e
    WHERE (e.person_id=request->person_id)
     AND ((e.organization_id+ 0)=temp->orglist[d2.seq].org_id)
     AND ((e.encntr_status_cd+ 0) != cancelled_cd)
     AND ((e.active_ind+ 0)=1))
  ELSEIF (security_on=1
   AND confid_ind=1)
   FROM encounter e,
    (dummyt d2  WITH seq = value(temp->org_cnt)),
    code_value cv
   PLAN (d2
    WHERE d2.seq > 0)
    JOIN (e
    WHERE (e.person_id=request->person_id)
     AND ((e.organization_id+ 0)=temp->orglist[d2.seq].org_id)
     AND ((e.reg_dt_tm+ 0) <= cnvtdatetime(curdate,curtime))
     AND ((e.encntr_status_cd+ 0) != cancelled_cd)
     AND ((e.active_ind+ 0)=1))
    JOIN (cv
    WHERE cv.code_value=e.confid_level_cd
     AND (cv.collation_seq <= temp->orglist[d2.seq].confid_level))
  ELSEIF (security_on=1)
   FROM encounter e,
    (dummyt d2  WITH seq = value(temp->org_cnt))
   PLAN (d2
    WHERE d2.seq > 0)
    JOIN (e
    WHERE (e.person_id=request->person_id)
     AND ((e.organization_id+ 0)=temp->orglist[d2.seq].org_id)
     AND ((e.reg_dt_tm+ 0) <= cnvtdatetime(curdate,curtime))
     AND ((e.encntr_status_cd+ 0) != cancelled_cd)
     AND ((e.active_ind+ 0)=1))
  ELSEIF (encntr_future_display=1)
   FROM encounter e
   PLAN (e
    WHERE (e.person_id=request->person_id)
     AND e.encntr_status_cd != cancelled_cd
     AND e.active_ind=1)
  ELSE
   FROM encounter e
   PLAN (e
    WHERE (e.person_id=request->person_id)
     AND ((e.reg_dt_tm+ 0) <= cnvtdatetime(curdate,curtime))
     AND ((e.encntr_status_cd+ 0) != cancelled_cd)
     AND ((e.active_ind+ 0)=1))
  ENDIF
  DISTINCT INTO "NL:"
  e.encntr_id, e.person_id, e.encntr_type_class_cd,
  e.active_status_cd, e.reg_dt_tm, disch_null = nullind(e.disch_dt_tm),
  reg_null = nullind(e.reg_dt_tm)
  ORDER BY cnvtdatetime(e.reg_dt_tm) DESC, e.encntr_id DESC
  HEAD REPORT
   knt = 0, stat = alterlist(reply->qual,10), stat = alterlist(temp1->elist,10)
  DETAIL
   knt += 1
   IF (mod(knt,10)=1
    AND knt != 1)
    stat = alterlist(reply->qual,(knt+ 9)), stat = alterlist(temp1->elist,(knt+ 9))
   ENDIF
   reply->qual[knt].encntr_id = e.encntr_id, temp1->elist[knt].el.encntr_id = e.encntr_id, temp1->
   elist[knt].el.encntr_type_class_cd = e.encntr_type_class_cd,
   temp1->elist[knt].el.encntr_status_cd = e.encntr_status_cd
   IF (reg_null=0)
    temp1->elist[knt].el.reg_dt_tm = cnvtdatetime(e.reg_dt_tm), temp1->elist[knt].el.reg_dt_null = 0
   ELSE
    temp1->elist[knt].el.reg_dt_null = 1
   ENDIF
   IF (disch_null=0)
    temp1->elist[knt].el.disch_dt_tm = cnvtdatetime(e.disch_dt_tm), temp1->elist[knt].el.
    disch_dt_null = 0
   ELSE
    temp1->elist[knt].el.disch_dt_null = 1
   ENDIF
  FOOT REPORT
   reply->qual_knt = knt, stat = alterlist(reply->qual,knt), stat = alterlist(temp1->elist,knt)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,0)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "GET_ALL"
  GO TO exit_script
 ENDIF
 GO TO find_best
#find_best
 SET the_date_tm = cnvtdatetime(sysdate)
 SET knt1 = size(temp1->elist,5)
 SET knt2 = 0
 IF (knt1=1)
  SET reply->best_encntr_id = temp1->elist[knt1].el.encntr_id
  SET reply->status_data.status = "S"
  GO TO exit_script
 ENDIF
 IF ((reqinfo->updt_app != 600005))
  GO TO skip_inpat_check
 ENDIF
 SET code_value = 0.0
 SET code_set = 69
 SET cdf_meaning = "INPATIENT"
 EXECUTE cpm_get_cd_for_cdf
 SET inpatient_cd = code_value
 FOR (x = 1 TO knt1)
   IF ((temp1->elist[x].el.encntr_type_class_cd != inpatient_cd))
    SET knt2 = knt2
   ELSE
    SET knt2 += 1
    SET stat = alterlist(temp2->elist,knt2)
    SET temp2->elist[knt2].el = temp1->elist[x].el
   ENDIF
 ENDFOR
 IF (knt2=1)
  SET reply->best_encntr_id = temp2->elist[knt2].el.encntr_id
  GO TO exit_script
 ENDIF
 IF (knt2 != 0)
  SET stat = alterlist(temp1->elist,knt2)
  FOR (x = 1 TO knt2)
    SET temp1->elist[x].el = temp2->elist[x].el
  ENDFOR
  SET knt1 = knt2
  SET knt2 = 0
 ENDIF
#skip_inpat_check
 IF ((reqinfo->updt_app != 961000))
  GO TO skip_outpat_check
 ENDIF
 SET code_value = 0.0
 SET code_set = 69
 SET cdf_meaning = "OUTPATIENT"
 EXECUTE cpm_get_cd_for_cdf
 SET outpatient_cd = code_value
 FOR (x = 1 TO knt1)
   IF ((temp1->elist[x].el.encntr_type_class_cd != outpatient_cd))
    SET knt2 = knt2
   ELSE
    SET knt2 += 1
    SET stat = alterlist(temp2->elist,knt2)
    SET temp2->elist[knt2].el = temp1->elist[x].el
   ENDIF
 ENDFOR
 IF (knt2=1)
  SET reply->best_encntr_id = temp2->elist[knt2].el.encntr_id
  GO TO exit_script
 ENDIF
 IF (knt2 != 0)
  SET stat = alterlist(temp1->elist,knt2)
  FOR (x = 1 TO knt2)
    SET temp1->elist[x].el = temp2->elist[x].el
  ENDFOR
  SET knt1 = knt2
  SET knt2 = 0
 ENDIF
#skip_outpat_check
 SET disch_cd = 0.0
 SET code_value = 0.0
 SET code_set = 261
 SET cdf_meaning = "DISCHARGED"
 EXECUTE cpm_get_cd_for_cdf
 SET disch_cd = code_value
 FOR (x = 1 TO knt1)
   IF ((((temp1->elist[x].el.encntr_status_cd=disch_cd)) OR ((temp1->elist[x].el.disch_dt_null=0)
    AND (temp1->elist[x].el.disch_dt_tm < cnvtdatetime(curdate,0)))) )
    SET knt2 = knt2
   ELSE
    SET knt2 += 1
    SET stat = alterlist(temp2->elist,knt2)
    SET temp2->elist[knt2].el = temp1->elist[x].el
   ENDIF
 ENDFOR
 IF (knt2=1)
  SET reply->best_encntr_id = temp2->elist[knt2].el.encntr_id
  GO TO exit_script
 ENDIF
 IF (knt2 != 0)
  SET stat = alterlist(temp1->elist,knt2)
  FOR (x = 1 TO knt2)
    SET temp1->elist[x].el = temp2->elist[x].el
  ENDFOR
  SET knt1 = knt2
  SET knt2 = 0
 ENDIF
 FOR (x = 1 TO knt1)
   IF ((((temp1->elist[x].el.reg_dt_null=1)) OR ((temp1->elist[x].el.reg_dt_tm > cnvtdatetime(curdate,
    curtime)))) )
    SET knt2 = knt2
   ELSE
    SET knt2 += 1
    SET stat = alterlist(temp2->elist,knt2)
    SET temp2->elist[knt2].el = temp1->elist[x].el
   ENDIF
 ENDFOR
 IF (knt2=1)
  SET reply->best_encntr_id = temp2->elist[knt2].el.encntr_id
  GO TO exit_script
 ENDIF
 IF (knt2 != 0)
  SET stat = alterlist(temp1->elist,knt2)
  FOR (x = 1 TO knt2)
    SET temp1->elist[x].el = temp2->elist[x].el
  ENDFOR
  SET knt1 = knt2
  SET knt2 = 0
 ENDIF
 IF (datetimediff(cnvtdatetime(the_date_tm),cnvtdatetime(temp1->elist[knt1].reg_dt_tm)) <= 0)
  SET reply->best_encntr_id = temp1->elist[knt1].el.encntr_id
 ELSE
  SET reply->best_encntr_id = temp1->elist[1].el.encntr_id
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
 ELSEIF ((reply->qual_knt > 0))
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 SET script_version = "005 10/10/03 SF3151"
END GO
