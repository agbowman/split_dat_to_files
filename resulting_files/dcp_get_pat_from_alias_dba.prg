CREATE PROGRAM dcp_get_pat_from_alias:dba
 RECORD reply(
   1 qual[*]
     2 person_id = f8
     2 encntr_id = f8
     2 alias_type_cd = f8
     2 barcode_type_cd = f8
     2 check_digit_ind = i2
     2 organization_id = f8
     2 org_barcode_format_id = f8
     2 parent_entity_id = f8
     2 parent_entity_name = c32
     2 prefix = vc
     2 z_data = vc
     2 privilege_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD barcode(
   1 format[*]
     2 alias_type_cd = f8
     2 barcode_type_cd = f8
     2 check_digit_ind = i2
     2 organization_id = f8
     2 org_barcode_format_id = f8
     2 parent_entity_id = f8
     2 parent_entity_name = c32
     2 prefix = vc
     2 z_data = vc
     2 person_id = f8
     2 encntr_id = f8
     2 alias_pool_cd = f8
     2 code_set = i4
     2 bc_alias = vc
   1 org_id = f8
   1 alias = vc
 )
 DECLARE org_cnt = i4 WITH noconstant(0)
 DECLARE errmsg = vc
 DECLARE pos = i4
 DECLARE count1 = i4
 DECLARE count2 = i4
 DECLARE count3 = i4
 DECLARE encounter_alias = i4
 DECLARE person_alias = i4
 DECLARE security_val = i2
 DECLARE nzeroflag = i2 WITH protect, noconstant(0)
 DECLARE lbclength = i4 WITH protect, noconstant(0)
 DECLARE sbarcodeprefix = vc WITH protect, noconstant("")
 DECLARE sbarcodezdata = vc WITH protect, noconstant("")
 SET reply->status_data.status = "F"
 SET barcode->alias = trim(request->alias,3)
 SET pos = 0
 SET count1 = 0
 SET count2 = 0
 SET count3 = 0
 SET encounter_alias = 319
 SET person_alias = 4
 CALL getprefix(barcode->alias,sbarcodeprefix)
 CALL getzdata(barcode->alias,sbarcodezdata)
 SELECT INTO "nl:"
  FROM location l
  WHERE (l.location_cd=request->location_cd)
   AND l.active_ind=1
  DETAIL
   barcode->org_id = l.organization_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET errmsg = concat("Organization not found for a given location_cd: ",cnvtstring(request->
    location_cd))
  CALL logstatus("SELECT","F","LOCATION",errmsg)
  CALL echo("NO Org Found")
  GO TO exit_prg
 ELSEIF (curqual > 1)
  CALL echo(concat("Multiple orgs found for a given location_cd ",cnvtstring(request->location_cd)))
 ENDIF
 SELECT DISTINCT INTO "nl:"
  obf.org_barcode_format_id
  FROM org_barcode_org obo,
   org_barcode_format obf,
   org_alias_pool_reltn oapr,
   code_value cv
  PLAN (obo
   WHERE (((obo.scan_organization_id=barcode->org_id)) OR (obo.scan_organization_id=0)) )
   JOIN (obf
   WHERE ((obf.organization_id=obo.label_organization_id
    AND obo.scan_organization_id > 0
    AND (obf.barcode_type_cd=request->barcode_type_cd)) OR (obo.scan_organization_id=0
    AND (obf.organization_id=barcode->org_id)
    AND (obf.barcode_type_cd=request->barcode_type_cd))) )
   JOIN (oapr
   WHERE oapr.alias_entity_alias_type_cd=obf.alias_type_cd
    AND oapr.organization_id=obf.organization_id
    AND oapr.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=obf.alias_type_cd
    AND cv.active_ind=1)
  ORDER BY obf.org_barcode_format_id
  HEAD REPORT
   count1 = 0
  HEAD obf.org_barcode_format_id
   IF (sbarcodeprefix=trim(obf.prefix,3)
    AND sbarcodezdata=trim(obf.z_data,3))
    count1 += 1
    IF (mod(count1,10)=1)
     cstat = alterlist(barcode->format,(count1+ 9))
    ENDIF
    barcode->format[count1].alias_type_cd = obf.alias_type_cd, barcode->format[count1].
    barcode_type_cd = obf.barcode_type_cd, barcode->format[count1].check_digit_ind = obf
    .check_digit_ind,
    barcode->format[count1].organization_id = obf.organization_id, barcode->format[count1].
    org_barcode_format_id = obf.org_barcode_format_id, barcode->format[count1].parent_entity_id = obf
    .parent_entity_id,
    barcode->format[count1].parent_entity_name = obf.parent_entity_name, barcode->format[count1].
    prefix = obf.prefix, barcode->format[count1].z_data = obf.z_data,
    barcode->format[count1].alias_pool_cd = oapr.alias_pool_cd, barcode->format[count1].code_set = cv
    .code_set
   ENDIF
  FOOT REPORT
   cstat = alterlist(barcode->format,count1)
  WITH nocounter
 ;end select
 IF (count1=0)
  SET errmsg = concat("Formats did not qualify for organization_id: ",cnvtstring(barcode->org_id))
  CALL logstatus("SELECT","F","ORG_BARCODE_FORMAT",errmsg)
  GO TO exit_prg
 ENDIF
#reprocess
 FOR (loop = 1 TO value(size(barcode->format,5)))
   SET barcode->format[loop].bc_alias = trim(barcode->alias)
   SET pos = 0
   IF (trim(barcode->format[loop].prefix) > " ")
    SET pos = findstring(trim(barcode->format[loop].prefix),barcode->format[loop].bc_alias)
    IF (pos=1)
     SET barcode->format[loop].bc_alias = substring((pos+ size(trim(barcode->format[loop].prefix),1)),
      size(barcode->format[loop].bc_alias,1),barcode->format[loop].bc_alias)
    ENDIF
   ENDIF
   SET pos = 0
   IF (trim(barcode->format[loop].z_data) > " ")
    SET pos = findstring("/Z",barcode->format[loop].bc_alias)
    IF (pos > 0)
     SET barcode->format[loop].bc_alias = substring(1,(pos - 1),barcode->format[loop].bc_alias)
    ENDIF
   ENDIF
   IF ((barcode->format[loop].check_digit_ind=1))
    SET barcode->format[loop].bc_alias = substring(1,(size(trim(barcode->format[loop].bc_alias),1) -
     1),barcode->format[loop].bc_alias)
   ENDIF
   IF (nzeroflag=1)
    SET pos = 0
    SET lbclength = textlen(barcode->format[loop].bc_alias)
    FOR (x = 1 TO lbclength)
      IF (substring(x,1,barcode->format[loop].bc_alias)="0")
       SET pos = x
      ELSE
       SET x = lbclength
      ENDIF
    ENDFOR
    IF (pos > 0)
     SET barcode->format[loop].bc_alias = substring((pos+ 1),(lbclength - pos),barcode->format[loop].
      bc_alias)
    ENDIF
   ENDIF
 ENDFOR
 FOR (loop = 1 TO value(size(barcode->format,5)))
   IF ((barcode->format[loop].code_set=encounter_alias))
    SELECT INTO "nl:"
     FROM encntr_alias ea,
      encounter e
     PLAN (ea
      WHERE (ea.alias_pool_cd=barcode->format[loop].alias_pool_cd)
       AND (ea.encntr_alias_type_cd=barcode->format[loop].alias_type_cd)
       AND (ea.alias=barcode->format[loop].bc_alias)
       AND ea.active_ind=1)
      JOIN (e
      WHERE e.encntr_id=ea.encntr_id
       AND e.active_ind=1)
     HEAD REPORT
      count3 = 0
     HEAD e.person_id
      count3 += 1, barcode->format[loop].person_id = e.person_id, barcode->format[loop].encntr_id = e
      .encntr_id
     WITH nocounter
    ;end select
   ELSEIF ((barcode->format[loop].code_set=person_alias))
    SELECT INTO "nl:"
     FROM person_alias pa
     WHERE (pa.alias_pool_cd=barcode->format[loop].alias_pool_cd)
      AND (pa.person_alias_type_cd=barcode->format[loop].alias_type_cd)
      AND (pa.alias=barcode->format[loop].bc_alias)
      AND pa.active_ind=1
     HEAD REPORT
      count3 = 0
     HEAD pa.person_id
      count3 += 1, barcode->format[loop].person_id = pa.person_id, barcode->format[loop].encntr_id =
      0
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
 SET count2 = 0
 FOR (loop = 1 TO value(size(barcode->format,5)))
   IF ((barcode->format[loop].person_id > 0))
    SET count2 += 1
    SET cstat = alterlist(reply->qual,count2)
    SET reply->qual[count2].person_id = barcode->format[loop].person_id
    SET reply->qual[count2].encntr_id = barcode->format[loop].encntr_id
    SET reply->qual[count2].alias_type_cd = barcode->format[loop].alias_type_cd
    SET reply->qual[count2].barcode_type_cd = barcode->format[loop].barcode_type_cd
    SET reply->qual[count2].check_digit_ind = barcode->format[loop].check_digit_ind
    SET reply->qual[count2].organization_id = barcode->format[loop].organization_id
    SET reply->qual[count2].org_barcode_format_id = barcode->format[loop].org_barcode_format_id
    SET reply->qual[count2].parent_entity_id = barcode->format[loop].parent_entity_id
    SET reply->qual[count2].parent_entity_name = barcode->format[loop].parent_entity_name
    SET reply->qual[count2].prefix = barcode->format[loop].prefix
    SET reply->qual[count2].z_data = barcode->format[loop].z_data
   ENDIF
 ENDFOR
 IF (count2 > 1)
  SET count2 = 0
  FOR (loop = 1 TO value(size(barcode->format,5)))
    IF ((barcode->format[loop].organization_id=barcode->org_id)
     AND (barcode->format[loop].person_id > 0))
     SET count2 += 1
     SET cstat = alterlist(reply->qual,count2)
     SET reply->qual[count2].person_id = barcode->format[loop].person_id
     SET reply->qual[count2].encntr_id = barcode->format[loop].encntr_id
    ENDIF
  ENDFOR
 ENDIF
 SUBROUTINE (getprefix(sbarcodein=vc,sprefix=vc(ref)) =null)
   DECLARE lcnt = i4 WITH protect, noconstant(0)
   DECLARE schar = c1 WITH protect, noconstant("")
   FOR (lcnt = 1 TO textlen(sbarcodein))
    SET schar = substring(lcnt,1,sbarcodein)
    IF (isnumeric(schar) > 0)
     SET sprefix = substring(1,(lcnt - 1),sbarcodein)
     SET lcnt = textlen(sbarcodein)
    ENDIF
   ENDFOR
   CALL echo(build2("Barcode Prefix:",sprefix))
 END ;Subroutine
 SUBROUTINE (getzdata(sbarcodein=vc,szdata=vc(ref)) =null)
   DECLARE lpos = i4 WITH protect, noconstant(0)
   SET lpos = findstring("/Z",sbarcodein)
   IF (lpos > 0)
    SET szdata = substring((lpos+ 2),(textlen(sbarcodein) - (lpos+ 1)),sbarcodein)
   ENDIF
   CALL echo(build2("Barcode Z-data:",szdata))
 END ;Subroutine
 SUBROUTINE (logstatus(operationname=vc,operationstatus=c1,targetobjectname=vc,targetobjectvalue=vc
  ) =null)
   SET reply->status_data.subeventstatus[1].operationname = operationname
   SET reply->status_data.subeventstatus[1].operationstatus = operationstatus
   SET reply->status_data.subeventstatus[1].targetobjectname = targetobjectname
   SET reply->status_data.subeventstatus[1].targetobjectvalue = targetobjectvalue
 END ;Subroutine
 SUBROUTINE (checksecurity(person_id=f8,encntr_id=f8) =i2)
   CALL echo("Checking Security")
   DECLARE org_sec_ind = i2 WITH noconstant(0)
   DECLARE confid_ind = i2 WITH noconstant(0)
   DECLARE por_confid_level = i4 WITH noconstant(0)
   DECLARE confid_level = i4 WITH noconstant(0)
   DECLARE security_granted = i2 WITH noconstant(0)
   IF (validate(ccldminfo->mode,0))
    SET org_sec_ind = ccldminfo->sec_org_reltn
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
       org_sec_ind = 1
      ELSEIF (di.info_name="SEC_CONFID"
       AND di.info_number=1)
       confid_ind = 1
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   CALL echo(build("OrgSecInd: ",org_sec_ind))
   IF (org_sec_ind=1)
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
   SET hprop = uar_srvcreateproperty()
   SET tmpstat = uar_secgetclientattributesext(3,hprop)
   SET spropname = uar_srvfirstproperty(hprop)
   SET slogontype = uar_srvgetpropertyptr(hprop,nullterm(spropname))
   CALL echo(build("logontype --> ",slogontype))
   DECLARE org_idx = i4 WITH noconstant(0), protect
   DECLARE locval = i4 WITH noconstant(0), protect
   IF (org_sec_ind=0
    AND confid_ind=0)
    SET security_granted = 1
   ELSE
    SELECT
     IF (encntr_id > 0)
      PLAN (e
       WHERE e.encntr_id=encntr_id)
     ELSE
      PLAN (e
       WHERE e.person_id=person_id)
     ENDIF
     INTO "nl:"
     FROM encounter e
     DETAIL
      org_idx = 0, locval = 0, locval = locateval(org_idx,1,org_cnt,e.organization_id,sac_org->
       organizations[org_idx].organization_id)
      IF (locval > 0)
       IF (confid_ind=1)
        confid_level = uar_get_collation_seq(e.confid_level_cd), por_confid_level = sac_org->
        organizations[locval].confid_level
        IF (por_confid_level >= confid_level)
         security_granted = 1
        ENDIF
       ELSE
        security_granted = 1
       ENDIF
      ENDIF
      confid_ind = 0, por_confid_level = 0
     WITH nocounter
    ;end select
    IF (security_granted=0)
     SELECT INTO "nl:"
      FROM person_prsnl_reltn ppr
      WHERE ppr.person_id=person_id
       AND (ppr.prsnl_person_id=reqinfo->updt_id)
       AND ppr.end_effective_dt_tm >= cnvtdatetime(sysdate)
       AND ppr.active_ind=1
      DETAIL
       security_granted = 1
      WITH nocounter
     ;end select
    ENDIF
    IF (security_granted=0)
     IF (encntr_id > 0)
      SELECT INTO "nl:"
       FROM encntr_prsnl_reltn epr
       WHERE epr.encntr_id=encntr_id
        AND (epr.prsnl_person_id=reqinfo->updt_id)
        AND epr.end_effective_dt_tm >= cnvtdatetime(sysdate)
        AND epr.active_ind=1
       DETAIL
        security_granted = 1
       WITH nocounter
      ;end select
     ELSE
      SELECT INTO "nl:"
       FROM encounter e,
        encntr_prsnl_reltn epr
       PLAN (e
        WHERE e.person_id=person_id)
        JOIN (epr
        WHERE epr.encntr_id=e.encntr_id
         AND (epr.prsnl_person_id=reqinfo->updt_id)
         AND epr.end_effective_dt_tm >= cnvtdatetime(sysdate)
         AND epr.active_ind=1)
       DETAIL
        security_granted = 1
       WITH nocounter
      ;end select
     ENDIF
    ENDIF
   ENDIF
   SET security_val = security_granted
 END ;Subroutine
#exit_prg
 IF (count2=0)
  IF (nzeroflag=0
   AND count1 > 0)
   SET nzeroflag = 1
   CALL echo(" - ")
   CALL echo("***** Reprocessing barcode stripping leading zeros *****")
   CALL echo(" - ")
   GO TO reprocess
  ENDIF
  SET reply->status_data.status = "Z"
 ELSEIF (count2=1)
  CALL checksecurity(reply->qual[1].person_id,reply->qual[1].encntr_id)
  SET reply->qual[1].privilege_ind = security_val
  SET reply->status_data.status = "S"
  IF (security_val != 1)
   CALL logstatus("SELECT","S","DM_INFO","No privilege for encounter.")
  ENDIF
 ELSE
  SET reply->status_data.status = "F"
  SET errmsg = concat(request->alias,
   "Alias shared by multiple person records in the same organization")
  CALL logstatus("SELECT","F","ALIAS",errmsg)
 ENDIF
 FREE RECORD barcode
 SET last_mod = "010"
 SET mod_date = "12/27/2005"
END GO
