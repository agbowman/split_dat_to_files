CREATE PROGRAM dcp_get_child_loc:dba
 FREE RECORD reply
 RECORD reply(
   1 loc_list[*]
     2 location_cd = f8
     2 location_disp = vc
     2 location_desc = vc
     2 location_mean = vc
     2 location_type_cd = f8
     2 collation_seq = i4
     2 patcare_node_ind = i2
     2 location_type_mean = c12
     2 location_sequence = i4
     2 logical_domain_id = f8
     2 orgs_id = f8
   1 organization_list[*]
     2 organization_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
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
 SET modify = predeclare
 DECLARE org_sec_ind = i2 WITH protect, noconstant(0)
 DECLARE org_cnt = i4 WITH protect, noconstant(0)
 DECLARE failed = i2 WITH protect, noconstant(0)
 DECLARE patcarenodeind = i2 WITH protect, noconstant(0)
 DECLARE locationtypecnt = i4 WITH protect, noconstant(0)
 DECLARE serrormsg = vc WITH protect, noconstant("")
 DECLARE ierrorcode = i2 WITH protect, noconstant(0)
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE requestedorgcount = i4 WITH protect, noconstant(0)
 DECLARE batch_ind = i2 WITH protect, noconstant(0)
 DECLARE deletedcd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",48,"DELETED"))
 IF (deletedcd < 1)
  SET failed = 1
  CALL fillsubeventstatus("SELECT","F","CODE_VALUE",
   "Failed to find the code_value for cdf_meaning DELETED from code_set 48")
  GO TO exit_script
 ENDIF
 DECLARE facilitycd = f8 WITH protect, constant(uar_get_code_by("MEANING",222,"FACILITY"))
 IF (facilitycd < 1)
  SET failed = 1
  CALL fillsubeventstatus("SELECT","F","CODE_VALUE",
   "Failed to find the code_value for cdf_meaning FACILITY from code_set 222")
  GO TO exit_script
 ENDIF
 DECLARE buildingcd = f8 WITH protect, constant(uar_get_code_by("MEANING",222,"BUILDING"))
 IF (buildingcd < 1)
  SET failed = 1
  CALL fillsubeventstatus("SELECT","F","CODE_VALUE",
   "Failed to find the code_value for cdf_meaning BUILDING from code_set 222")
  GO TO exit_script
 ENDIF
 DECLARE nurseunitcd = f8 WITH protect, constant(uar_get_code_by("MEANING",222,"NURSEUNIT"))
 IF (nurseunitcd < 1)
  SET failed = 1
  CALL fillsubeventstatus("SELECT","F","CODE_VALUE",
   "Failed to find the code_value for cdf_meaning NURSEUNIT from code_set 222")
  GO TO exit_script
 ENDIF
 DECLARE ambulatorycd = f8 WITH protect, constant(uar_get_code_by("MEANING",222,"AMBULATORY"))
 IF (ambulatorycd < 1)
  SET failed = 1
  CALL fillsubeventstatus("SELECT","F","CODE_VALUE",
   "Failed to find the code_value for cdf_meaning AMBULATORY from code_set 222")
  GO TO exit_script
 ENDIF
 DECLARE roomcd = f8 WITH protect, constant(uar_get_code_by("MEANING",222,"ROOM"))
 IF (roomcd < 1)
  SET failed = 1
  CALL fillsubeventstatus("SELECT","F","CODE_VALUE",
   "Failed to find the code_value for cdf_meaning ROOM from code_set 222")
  GO TO exit_script
 ENDIF
 DECLARE bedcd = f8 WITH protect, constant(uar_get_code_by("MEANING",222,"BED"))
 IF (bedcd < 1)
  SET failed = 1
  CALL fillsubeventstatus("SELECT","F","CODE_VALUE",
   "Failed to find the code_value for cdf_meaning BED from code_set 222")
  GO TO exit_script
 ENDIF
 DECLARE getlocationcdwithtype(null) = null
 DECLARE getlocationcd(null) = null
 DECLARE getlocationtype(x) = null
 DECLARE getlocationtypeorgsecurityon(x) = null
 DECLARE getlocationtypeorgsecurityoff(x) = null
 DECLARE getorganizationlist(x) = null
 FREE RECORD org_sec
 RECORD org_sec(
   1 encntr_org_security_ind = i2
   1 confid_security_ind = i2
 )
 DECLARE checkorgsecurity(null) = null
 SUBROUTINE checkorgsecurity(null)
   DECLARE dminfo_ok = i2 WITH protect, noconstant(0)
   SET org_sec->encntr_org_security_ind = 0
   SET org_sec->confid_security_ind = 0
   SET dminfo_ok = validate(ccldminfo->mode,0)
   IF (dminfo_ok=1)
    SET org_sec->encntr_org_security_ind = ccldminfo->sec_org_reltn
    SET org_sec->confid_security_ind = ccldminfo->sec_confid
   ELSE
    SELECT INTO "nl:"
     FROM dm_info dmi
     WHERE dmi.info_domain="SECURITY"
      AND dmi.info_name IN ("SEC_ORG_RELTN", "SEC_CONFID")
      AND dmi.info_number=1
     DETAIL
      IF (dmi.info_name="SEC_ORG_RELTN")
       org_sec->encntr_org_security_ind = 1
      ELSE
       org_sec->confid_security_ind = 1
      ENDIF
     WITH nocounter
    ;end select
    IF (curqual <= 0
     AND checkerror(failure,"SELECT",failure,"ORG SECURITY") > 0)
     SET s_msgbox_disp = errors->status_data.subeventstatus[errors->error_cnt].targetobjectvalue
     GO TO exit_script
    ENDIF
   ENDIF
 END ;Subroutine
 CALL checkorgsecurity(null)
 SET org_sec_ind = org_sec->encntr_org_security_ind
 IF (validate(request->only_patcare_node_ind,0))
  SET patcarenodeind = 1
 ENDIF
 FREE RECORD sac_org
 RECORD sac_org(
   1 organizations[*]
     2 organization_id = f8
     2 confid_cd = f8
     2 confid_level = i4
 )
 IF (org_sec_ind)
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
 SET batch_ind = 0
 IF (validate(request->perform_batching)=1)
  IF ((request->perform_batching=1))
   SET batch_ind = 1
  ENDIF
 ENDIF
 IF (batch_ind)
  IF (org_sec_ind)
   IF (validate(request->count_org_id)=1)
    IF ((((request->count_org_id=org_cnt)) OR ((request->count_org_id < org_cnt))) )
     SET requestedorgcount = request->count_org_id
    ELSE
     SET requestedorgcount = org_cnt
    ENDIF
   ELSE
    GO TO exit_script
   ENDIF
  ELSE
   IF (validate(request->location_type_cd)=1)
    IF ((request->location_type_cd > 0.0))
     CALL getlocationtypeorgsecurityoff(patcarenodeind)
     GO TO exit_script
    ENDIF
   ENDIF
  ENDIF
  IF (validate(request->org_list[1].organization_id)=1)
   IF ((request->org_list[1].organization_id=0))
    SET stat = alterlist(reply->organization_list,org_cnt)
    FOR (count = 1 TO org_cnt)
      SET reply->organization_list[count].organization_id = sac_org->organizations[count].
      organization_id
    ENDFOR
    CALL getlocationtypeorgsecurityon(patcarenodeind)
   ENDIF
  ELSE
   GO TO exit_script
  ENDIF
  IF (validate(request->org_list[1].organization_id)=1)
   IF ((request->org_list[1].organization_id > 0))
    CALL getorganizationlist(patcarenodeind)
   ENDIF
  ENDIF
 ELSE
  IF ((request->location_type_cd > 0.0))
   IF ((request->location_type_cd != facilitycd)
    AND (request->location_type_cd != buildingcd)
    AND (request->location_type_cd != nurseunitcd)
    AND (request->location_type_cd != ambulatorycd)
    AND (request->location_type_cd != roomcd)
    AND (request->location_type_cd != bedcd))
    SET org_sec_ind = 0
   ENDIF
   CALL getlocationtype(patcarenodeind)
  ELSEIF ((request->location_cd > 0.0))
   IF (validate(request->location_type_list))
    SET locationtypecnt = size(request->location_type_list,5)
   ENDIF
   IF (locationtypecnt > 0)
    CALL getlocationcdwithtype(null)
   ELSE
    CALL getlocationcd(null)
   ENDIF
  ELSE
   SET reply->status_data.status = "F"
   CALL fillsubeventstatus("Request","F","dcp_get_child_loc:Request","Invalid Request passed")
  ENDIF
 ENDIF
 GO TO exit_script
 SUBROUTINE getlocationcdwithtype(null)
   DECLARE org_idx = i4 WITH noconstant(0), protect
   DECLARE locval = i4 WITH noconstant(0), protect
   DECLARE num = i4 WITH protect, noconstant(0)
   DECLARE loc_cnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM location_group lg,
     code_value cv,
     location l
    PLAN (lg
     WHERE (lg.parent_loc_cd=request->location_cd)
      AND lg.active_ind=1
      AND ((lg.root_loc_cd+ 0)=0))
     JOIN (cv
     WHERE cv.code_value=lg.child_loc_cd
      AND cv.begin_effective_dt_tm <= cnvtdatetime(sysdate)
      AND cv.end_effective_dt_tm >= cnvtdatetime(sysdate)
      AND cv.active_type_cd != deletedcd)
     JOIN (l
     WHERE expand(num,1,locationtypecnt,l.location_type_cd,request->location_type_list[num].
      location_type_cd)
      AND l.location_cd=cv.code_value
      AND l.active_ind=1)
    ORDER BY lg.sequence, cv.display, lg.child_loc_cd
    HEAD REPORT
     loc_cnt = 0
    HEAD lg.child_loc_cd
     org_idx = 0, locval = locateval(org_idx,1,org_cnt,l.organization_id,sac_org->organizations[
      org_idx].organization_id)
     IF (((org_sec_ind=0) OR (locval > 0)) )
      loc_cnt += 1
      IF (loc_cnt > size(reply->loc_list,5))
       stat = alterlist(reply->loc_list,(loc_cnt+ 10))
      ENDIF
      reply->loc_list[loc_cnt].location_cd = l.location_cd, reply->loc_list[loc_cnt].location_disp =
      cv.display, reply->loc_list[loc_cnt].location_type_cd = l.location_type_cd,
      reply->loc_list[loc_cnt].collation_seq = cv.collation_seq, reply->loc_list[loc_cnt].
      patcare_node_ind = l.patcare_node_ind, reply->loc_list[loc_cnt].location_type_mean =
      uar_get_code_meaning(l.location_type_cd),
      reply->loc_list[loc_cnt].location_mean = cv.cdf_meaning, reply->loc_list[loc_cnt].
      location_sequence = lg.sequence
     ENDIF
    FOOT REPORT
     stat = alterlist(reply->loc_list,loc_cnt)
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET reply->status_data.status = "Z"
    CALL fillsubeventstatus("SELECT","Z","dcp_get_child_loc",
     "Failed to retrieve locations by location_cd and location types")
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE getlocationcd(null)
   DECLARE org_idx = i4 WITH noconstant(0), protect
   DECLARE locval = i4 WITH noconstant(0), protect
   DECLARE loc_cnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM location_group lg,
     code_value cv,
     location l
    PLAN (lg
     WHERE (lg.parent_loc_cd=request->location_cd)
      AND lg.active_ind=1
      AND ((lg.root_loc_cd+ 0)=0))
     JOIN (cv
     WHERE cv.code_value=lg.child_loc_cd
      AND cv.begin_effective_dt_tm <= cnvtdatetime(sysdate)
      AND cv.end_effective_dt_tm >= cnvtdatetime(sysdate)
      AND cv.active_type_cd != deletedcd)
     JOIN (l
     WHERE l.location_cd=cv.code_value
      AND l.active_ind=1)
    ORDER BY cv.collation_seq, cv.display, lg.child_loc_cd
    HEAD REPORT
     loc_cnt = 0
    HEAD lg.child_loc_cd
     org_idx = 0, locval = locateval(org_idx,1,org_cnt,l.organization_id,sac_org->organizations[
      org_idx].organization_id)
     IF (((org_sec_ind=0) OR (locval > 0)) )
      loc_cnt += 1
      IF (loc_cnt > size(reply->loc_list,5))
       stat = alterlist(reply->loc_list,(loc_cnt+ 10))
      ENDIF
      reply->loc_list[loc_cnt].location_cd = l.location_cd, reply->loc_list[loc_cnt].location_disp =
      cv.display, reply->loc_list[loc_cnt].location_type_cd = l.location_type_cd,
      reply->loc_list[loc_cnt].collation_seq = cv.collation_seq, reply->loc_list[loc_cnt].
      patcare_node_ind = l.patcare_node_ind, reply->loc_list[loc_cnt].location_type_mean =
      uar_get_code_meaning(l.location_type_cd),
      reply->loc_list[loc_cnt].location_mean = cv.cdf_meaning, reply->loc_list[loc_cnt].
      location_sequence = lg.sequence
     ENDIF
    FOOT REPORT
     stat = alterlist(reply->loc_list,loc_cnt)
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET reply->status_data.status = "Z"
    CALL fillsubeventstatus("SELECT","Z","dcp_get_child_loc",
     "Failed to retrieve locations by location_cd only")
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE getlocationtype(bonlypatcare)
   DECLARE org_idx = i4 WITH noconstant(0), protect
   DECLARE locval = i4 WITH noconstant(0), protect
   DECLARE loc_cnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM location l,
     code_value cv
    PLAN (l
     WHERE (l.location_type_cd=request->location_type_cd)
      AND l.active_ind=1
      AND l.patcare_node_ind IN (bonlypatcare, 1))
     JOIN (cv
     WHERE cv.code_value=l.location_cd
      AND cv.active_ind=1
      AND cv.begin_effective_dt_tm <= cnvtdatetime(sysdate)
      AND cv.end_effective_dt_tm >= cnvtdatetime(sysdate)
      AND cv.active_type_cd != deletedcd)
    ORDER BY cv.collation_seq, cv.display, l.location_cd
    HEAD REPORT
     loc_cnt = 0
    HEAD l.location_cd
     org_idx = 0, locval = locateval(org_idx,1,org_cnt,l.organization_id,sac_org->organizations[
      org_idx].organization_id)
     IF (((org_sec_ind=0) OR (locval > 0)) )
      loc_cnt += 1
      IF (loc_cnt > size(reply->loc_list,5))
       stat = alterlist(reply->loc_list,(loc_cnt+ 10))
      ENDIF
      reply->loc_list[loc_cnt].location_cd = l.location_cd, reply->loc_list[loc_cnt].location_disp =
      cv.display, reply->loc_list[loc_cnt].location_type_cd = l.location_type_cd,
      reply->loc_list[loc_cnt].collation_seq = cv.collation_seq, reply->loc_list[loc_cnt].
      patcare_node_ind = l.patcare_node_ind, reply->loc_list[loc_cnt].location_type_mean =
      uar_get_code_meaning(l.location_type_cd)
     ENDIF
    FOOT REPORT
     stat = alterlist(reply->loc_list,loc_cnt)
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET reply->status_data.status = "Z"
    CALL fillsubeventstatus("SELECT","Z","dcp_get_child_loc",
     "Failed to retrieve locations by location type")
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE getlocationtypeorgsecurityon(bonlypatcare)
   DECLARE org_idx = i4 WITH noconstant(0), protect
   DECLARE loc_cnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM organization o,
     location l,
     code_value cv
    PLAN (o
     WHERE expand(org_idx,1,requestedorgcount,o.organization_id,sac_org->organizations[org_idx].
      organization_id))
     JOIN (l
     WHERE l.organization_id=o.organization_id
      AND (l.location_type_cd=request->location_type_cd)
      AND l.active_ind=1
      AND l.patcare_node_ind IN (bonlypatcare, 1))
     JOIN (cv
     WHERE cv.code_value=l.location_cd
      AND cv.active_ind=1
      AND cv.begin_effective_dt_tm <= cnvtdatetime(sysdate)
      AND cv.end_effective_dt_tm >= cnvtdatetime(sysdate)
      AND cv.active_type_cd != deletedcd)
    ORDER BY cv.collation_seq, cv.display, l.location_cd
    HEAD REPORT
     loc_cnt = 0
    HEAD l.location_cd
     loc_cnt += 1
     IF (mod(loc_cnt,100)=1)
      stat = alterlist(reply->loc_list,(loc_cnt+ 99))
     ENDIF
     reply->loc_list[loc_cnt].location_cd = l.location_cd, reply->loc_list[loc_cnt].location_disp =
     cv.display, reply->loc_list[loc_cnt].location_type_cd = l.location_type_cd,
     reply->loc_list[loc_cnt].collation_seq = cv.collation_seq, reply->loc_list[loc_cnt].
     patcare_node_ind = l.patcare_node_ind, reply->loc_list[loc_cnt].location_type_mean =
     uar_get_code_meaning(l.location_type_cd),
     reply->loc_list[loc_cnt].logical_domain_id = o.logical_domain_id, reply->loc_list[loc_cnt].
     orgs_id = o.organization_id
    FOOT REPORT
     stat = alterlist(reply->loc_list,loc_cnt)
    WITH nocounter, expand = 2
   ;end select
   IF (curqual=0)
    SET reply->status_data.status = "Z"
    CALL fillsubeventstatus("SELECT","Z","dcp_get_child_loc",
     "Failed to retrieve locations by location type")
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE getlocationtypeorgsecurityoff(bonlypatcare)
   DECLARE org_idx = i4 WITH noconstant(0), protect
   DECLARE loc_cnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM organization o,
     location l,
     code_value cv
    PLAN (l
     WHERE (l.location_type_cd=request->location_type_cd)
      AND l.active_ind=1
      AND l.patcare_node_ind IN (bonlypatcare, 1))
     JOIN (o
     WHERE o.organization_id=l.organization_id)
     JOIN (cv
     WHERE cv.code_value=l.location_cd
      AND cv.active_ind=1
      AND cv.begin_effective_dt_tm <= cnvtdatetime(sysdate)
      AND cv.end_effective_dt_tm >= cnvtdatetime(sysdate)
      AND cv.active_type_cd != deletedcd)
    ORDER BY cv.collation_seq, cv.display, l.location_cd
    HEAD REPORT
     loc_cnt = 0
    HEAD l.location_cd
     loc_cnt += 1
     IF (mod(loc_cnt,100)=1)
      stat = alterlist(reply->loc_list,(loc_cnt+ 99))
     ENDIF
     reply->loc_list[loc_cnt].location_cd = l.location_cd, reply->loc_list[loc_cnt].location_disp =
     cv.display, reply->loc_list[loc_cnt].location_type_cd = l.location_type_cd,
     reply->loc_list[loc_cnt].collation_seq = cv.collation_seq, reply->loc_list[loc_cnt].
     patcare_node_ind = l.patcare_node_ind, reply->loc_list[loc_cnt].location_type_mean =
     uar_get_code_meaning(l.location_type_cd),
     reply->loc_list[loc_cnt].logical_domain_id = o.logical_domain_id
    FOOT REPORT
     stat = alterlist(reply->loc_list,loc_cnt)
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET reply->status_data.status = "Z"
    CALL fillsubeventstatus("SELECT","Z","dcp_get_child_loc",
     "Failed to retrieve locations by location type")
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE getorganizationlist(bonlypatcare)
   DECLARE org_idx = i4 WITH noconstant(0), protect
   DECLARE loc_cnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM location l,
     code_value cv,
     organization o
    PLAN (o
     WHERE expand(org_idx,1,requestedorgcount,o.organization_id,request->org_list[org_idx].
      organization_id))
     JOIN (l
     WHERE l.organization_id=o.organization_id
      AND (l.location_type_cd=request->location_type_cd)
      AND l.active_ind=1
      AND l.patcare_node_ind IN (bonlypatcare, 1))
     JOIN (cv
     WHERE cv.code_value=l.location_cd
      AND cv.active_ind=1
      AND cv.begin_effective_dt_tm <= cnvtdatetime(sysdate)
      AND cv.end_effective_dt_tm >= cnvtdatetime(sysdate)
      AND cv.active_type_cd != deletedcd)
    ORDER BY cv.collation_seq, cv.display, l.location_cd
    HEAD REPORT
     loc_cnt = 0
    HEAD l.location_cd
     loc_cnt += 1
     IF (mod(loc_cnt,100)=1)
      stat = alterlist(reply->loc_list,(loc_cnt+ 99))
     ENDIF
     reply->loc_list[loc_cnt].location_cd = l.location_cd, reply->loc_list[loc_cnt].location_disp =
     cv.display, reply->loc_list[loc_cnt].location_type_cd = l.location_type_cd,
     reply->loc_list[loc_cnt].collation_seq = cv.collation_seq, reply->loc_list[loc_cnt].
     patcare_node_ind = l.patcare_node_ind, reply->loc_list[loc_cnt].location_type_mean =
     uar_get_code_meaning(l.location_type_cd),
     reply->loc_list[loc_cnt].logical_domain_id = o.logical_domain_id, reply->loc_list[loc_cnt].
     orgs_id = o.organization_id
    FOOT REPORT
     stat = alterlist(reply->loc_list,loc_cnt)
    WITH nocounter, expand = 2
   ;end select
   IF (curqual=0)
    SET reply->status_data.status = "Z"
    CALL fillsubeventstatus("SELECT","Z","dcp_get_child_loc",
     "Failed to retrieve locations by location type")
    GO TO exit_script
   ENDIF
 END ;Subroutine
#exit_script
 SET ierrorcode = error(serrormsg,1)
 IF (ierrorcode != 0)
  CALL echo(build("ERROR CODE: ",ierrorcode))
  CALL echo(build("ERROR MESSAGE: ",serrormsg))
  CALL reportfailure("ERROR","F","dcp_get_child_loc",serrormsg)
 ELSEIF (failed=1)
  CALL echo("Failure reported.  Exiting.")
  SET reply->status_data.status = "F"
 ELSE
  CALL echo("******** Success ********")
  SET reply->status_data.status = "S"
 ENDIF
 CALL echo("Last mod: 007 1/12/22 SH103862")
 SET modify = nopredeclare
END GO
