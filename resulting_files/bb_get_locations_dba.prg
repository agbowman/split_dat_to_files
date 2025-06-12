CREATE PROGRAM bb_get_locations:dba
 RECORD temp_req(
   1 levellist[*]
     2 locationlist[*]
       3 location_type_cd = f8
       3 discipline_type_cd = f8
     2 locationfilterlist[*]
       3 location_cd = f8
   1 max_count = i2
   1 search_prefix = vc
 )
 RECORD code_req115408(
   1 mode = i2
   1 criteria[*]
     2 name = vc
     2 value_nbr[*]
       3 value_nbr = f8
     2 value_time[*]
       3 value_dt_tm = dq8
     2 value_str[*]
       3 value = vc
 )
 RECORD code_rep115408(
   1 locations[*]
     2 location_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD reply(
   1 levellist1[*]
     2 location_cd = f8
     2 location_disp = vc
     2 location_desc = vc
     2 location_mean = c12
     2 location_type_cd = f8
     2 location_type_disp = vc
     2 location_type_desc = vc
     2 location_type_mean = c12
     2 discipline_type_cd = f8
     2 discipline_type_disp = vc
     2 discipline_type_desc = vc
     2 discipline_type_mean = c12
     2 organization_id = f8
     2 lvl2_cnt = i4
     2 levellist2[*]
       3 location_cd = f8
       3 location_disp = vc
       3 location_desc = vc
       3 location_mean = c12
       3 location_type_cd = f8
       3 location_type_disp = vc
       3 location_type_desc = vc
       3 location_type_mean = c12
       3 discipline_type_cd = f8
       3 discipline_type_disp = vc
       3 discipline_type_desc = vc
       3 discipline_type_mean = c12
       3 organization_id = f8
       3 lvl3_cnt = i4
       3 levellist3[*]
         4 location_cd = f8
         4 location_disp = vc
         4 location_desc = vc
         4 location_mean = c12
         4 location_type_cd = f8
         4 location_type_disp = vc
         4 location_type_desc = vc
         4 location_type_mean = c12
         4 discipline_type_cd = f8
         4 discipline_type_disp = vc
         4 discipline_type_desc = vc
         4 discipline_type_mean = c12
         4 organization_id = f8
         4 lvl4_cnt = i4
         4 levellist4[*]
           5 location_cd = f8
           5 location_disp = vc
           5 location_desc = vc
           5 location_mean = c12
           5 location_type_cd = f8
           5 location_type_disp = vc
           5 location_type_desc = vc
           5 location_type_mean = c12
           5 discipline_type_cd = f8
           5 discipline_type_disp = vc
           5 discipline_type_desc = vc
           5 discipline_type_mean = c12
           5 organization_id = f8
           5 lvl5_cnt = i4
           5 levellist5[*]
             6 location_cd = f8
             6 location_disp = vc
             6 location_desc = vc
             6 location_mean = c12
             6 location_type_cd = f8
             6 location_type_disp = vc
             6 location_type_desc = vc
             6 location_type_mean = c12
             6 discipline_type_cd = f8
             6 discipline_type_disp = vc
             6 discipline_type_desc = vc
             6 discipline_type_mean = c12
             6 organization_id = f8
   1 organization_security_flag = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SUBROUTINE (subevent_add(op_name=vc(value),op_status=vc(value),obj_name=vc(value),obj_value=vc(value
   )) =null WITH protect)
   DECLARE se_itm = i4 WITH protect, noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
   SET se_itm = size(reply->status_data.subeventstatus,5)
   SET stat = alter(reply->status_data.subeventstatus,(se_itm+ 1))
   SET reply->status_data.subeventstatus[se_itm].operationname = cnvtupper(substring(1,25,trim(
      op_name)))
   SET reply->status_data.subeventstatus[se_itm].operationstatus = cnvtupper(substring(1,1,trim(
      op_status)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectname = cnvtupper(substring(1,25,trim(
      obj_name)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectvalue = obj_value
 END ;Subroutine
 DECLARE dm_security = vc WITH protect, constant("SECURITY")
 DECLARE dm_org_security = vc WITH protect, constant("SEC_ORG_RELTN")
 DECLARE dm_confid = vc WITH protect, constant("SEC_CONFID")
 DECLARE encntr_org_sec_ind = i2 WITH protect, noconstant(0)
 DECLARE confid_sec_ind = i2 WITH protect, noconstant(0)
 DECLARE subeventstatus_cnt = i4 WITH protect, noconstant(0)
 DECLARE security_determined_ind = i2 WITH protect, noconstant(0)
 SUBROUTINE (scsscripterror(opname=vc,opstat=vc,tarobjname=vc,tarobjval=vc) =null)
   SET subeventstatus_cnt += 1
   SET stat = alter(reply->status_data.subeventstatus,subeventstatus_cnt)
   SET reply->status_data.subeventstatus[subeventstatus_cnt].operationname = build(opname)
   SET reply->status_data.subeventstatus[subeventstatus_cnt].operationstatus = build(opstat)
   SET reply->status_data.subeventstatus[subeventstatus_cnt].targetobjectname = build(tarobjname)
   SET reply->status_data.subeventstatus[subeventstatus_cnt].targetobjectvalue = build(tarobjval)
 END ;Subroutine
 DECLARE scscheckorgsecandconfid() = null
 SUBROUTINE scscheckorgsecandconfid(null)
   SET encntr_org_sec_ind = 0
   SET confid_sec_ind = 0
   SET security_determined_ind = 1
   SELECT INTO "nl:"
    FROM dm_info di
    PLAN (di
     WHERE di.info_domain=dm_security
      AND di.info_name IN (dm_org_security, dm_confid))
    DETAIL
     IF (di.info_name=dm_org_security
      AND di.info_number=1)
      encntr_org_sec_ind = 1
     ELSEIF (di.info_name=dm_confid
      AND di.info_number=1)
      confid_sec_ind = 1
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE (scschecksecurity(person_id=f8(value),encntr_id=f8(value)) =i2)
   DECLARE por_confid_level = i4 WITH noconstant(0), protect
   DECLARE confid_level = i4 WITH noconstant(0), protect
   DECLARE security_granted = i2 WITH noconstant(0), protect
   IF (security_determined_ind=0)
    CALL scscheckorgsecandconfid(null)
   ENDIF
   IF (encntr_org_sec_ind=0
    AND confid_sec_ind=0)
    SET security_granted = 1
   ELSE
    SELECT
     IF (encntr_id > 0)
      PLAN (e
       WHERE e.encntr_id=encntr_id)
       JOIN (por
       WHERE (por.person_id=reqinfo->updt_id)
        AND por.organization_id=e.organization_id)
     ELSE
      PLAN (e
       WHERE e.person_id=person_id)
       JOIN (por
       WHERE (por.person_id=reqinfo->updt_id)
        AND por.organization_id=e.organization_id)
     ENDIF
     INTO "nl:"
     FROM encounter e,
      prsnl_org_reltn por
     DETAIL
      IF (confid_sec_ind=1)
       confid_level = uar_get_collation_seq(e.confid_level_cd), por_confid_level =
       uar_get_collation_seq(por.confid_level_cd)
       IF (por_confid_level >= confid_level)
        security_granted = 1
       ENDIF
      ELSE
       security_granted = 1
      ENDIF
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
   RETURN(security_granted)
 END ;Subroutine
 DECLARE getlevelinfo_with_filter_1(null) = i2
 DECLARE getlevelinfo_1(null) = i2
 DECLARE getcodevalues(null) = i2
 DECLARE copyrequest(null) = i2
 DECLARE resetexpandvars(null) = i2
 DECLARE lstat = i4 WITH protect, noconstant(0)
 DECLARE select_ok_flag = i2 WITH protect, noconstant(0)
 DECLARE nlevelidx = i2 WITH protect, noconstant(0)
 DECLARE nlevelsize = i2 WITH protect, noconstant(size(request->levellist,5))
 DECLARE lnumrecords1 = i4 WITH protect, noconstant(0)
 DECLARE lnumrecords2 = i4 WITH protect, noconstant(0)
 DECLARE lnumrecords3 = i4 WITH protect, noconstant(0)
 DECLARE lnumrecords4 = i4 WITH protect, noconstant(0)
 DECLARE lnumrecords5 = i4 WITH protect, noconstant(0)
 DECLARE lparsecnt = i4 WITH protect, noconstant(0)
 DECLARE llistcnt = i4 WITH protect, noconstant(0)
 DECLARE lloc_type_cs = i4 WITH protect, constant(222)
 DECLARE snurseunit = c12 WITH protect, constant("NURSEUNIT")
 DECLARE dnurseunit = f8 WITH protect, noconstant(0.0)
 DECLARE sancilsurg = c12 WITH protect, constant("ANCILSURG")
 DECLARE dancilsurg = f8 WITH protect, noconstant(0.0)
 DECLARE sambulatory = c12 WITH protect, constant("AMBULATORY")
 DECLARE dambulatory = f8 WITH protect, noconstant(0.0)
 DECLARE slab = c12 WITH protect, constant("LAB ")
 DECLARE dlab = f8 WITH protect, noconstant(0.0)
 DECLARE spharm = c12 WITH protect, constant("PHARM")
 DECLARE dpharm = f8 WITH protect, noconstant(0.0)
 DECLARE sapptloc = c12 WITH protect, constant("APPTLOC")
 DECLARE dapptloc = f8 WITH protect, noconstant(0.0)
 DECLARE srad = c12 WITH protect, constant("RAD")
 DECLARE drad = f8 WITH protect, noconstant(0.0)
 DECLARE norgsecurityflag = i2 WITH protect, noconstant(0)
 DECLARE lbatchsize = i4 WITH protect, constant(20)
 DECLARE lparsebatchsize = i4 WITH protect, constant(2)
 DECLARE lcurlistsize = i4 WITH protect, noconstant(0)
 DECLARE lnewlistsize = i4 WITH protect, noconstant(0)
 DECLARE lstart = i4 WITH protect, noconstant(0)
 DECLARE lloopcnt = i4 WITH protect, noconstant(0)
 DECLARE lloopidx = i4 WITH protect, noconstant(0)
 DECLARE lnumidx = i4 WITH protect, noconstant(0)
 SET lstat = getcodevalues(null)
 IF (lstat=0)
  GO TO exit_script
 ENDIF
 IF ((request->security_bypass_ind=0))
  CALL scscheckorgsecandconfid(null)
  SET norgsecurityflag = encntr_org_sec_ind
 ELSE
  SET norgsecurityflag = 0
 ENDIF
 SET reply->organization_security_flag = norgsecurityflag
 SET lstat = copyrequest(null)
 IF (norgsecurityflag=1)
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
 ENDIF
 FOR (lparsecnt = 1 TO size(temp_req->levellist,5))
   IF (size(temp_req->levellist[lparsecnt].locationlist,5) > 0)
    FOR (llistcnt = 1 TO size(temp_req->levellist[lparsecnt].locationlist,5))
      IF ((temp_req->levellist[lparsecnt].locationlist[llistcnt].location_type_cd IN (dnurseunit,
      dancilsurg, dambulatory, dlab, dpharm,
      dapptloc, drad)))
       CASE (lparsecnt)
        OF 3:
         CALL parserequestupfacility(lparsecnt,size(temp_req->levellist[lparsecnt].locationlist,5))
         GO TO get_locations
        OF 2:
         CALL parserequestupbuilding(lparsecnt,size(temp_req->levellist[lparsecnt].locationlist,5))
         GO TO get_locations
       ENDCASE
      ENDIF
    ENDFOR
   ELSE
    GO TO get_locations
   ENDIF
 ENDFOR
#get_locations
 FOR (nlevelidx = 1 TO nlevelsize)
   CASE (nlevelidx)
    OF 1:
     IF ((temp_req->max_count > 0)
      AND textlen(trim(temp_req->search_prefix)) > 0)
      CALL getlevelinfo_with_filter_1(null)
     ELSE
      CALL getlevelinfo_1(null)
     ENDIF
    OF 2:
     CALL getlevelinfo_2(size(temp_req->levellist[nlevelidx].locationlist,5),size(temp_req->
       levellist[nlevelidx].locationfilterlist,5))
    OF 3:
     CALL getlevelinfo_3(size(temp_req->levellist[nlevelidx].locationlist,5),size(temp_req->
       levellist[nlevelidx].locationfilterlist,5))
    OF 4:
     CALL getlevelinfo_4(size(temp_req->levellist[nlevelidx].locationlist,5),size(temp_req->
       levellist[nlevelidx].locationfilterlist,5))
    OF 5:
     CALL getlevelinfo_5(size(temp_req->levellist[nlevelidx].locationlist,5),size(temp_req->
       levellist[nlevelidx].locationfilterlist,5))
   ENDCASE
 ENDFOR
 SUBROUTINE resetexpandvars(null)
   SET lcurlistsize = 0
   SET lnewlistsize = 0
   SET lstart = 1
   SET lloopcnt = 0
   SET lloopidx = 0
   SET lnumidx = 0
   RETURN(1)
 END ;Subroutine
 SUBROUTINE copyrequest(null)
   DECLARE llistsize = i4 WITH protect, noconstant(0)
   DECLARE llevel = i4 WITH protect, noconstant(0)
   DECLARE lfiltersize = i4 WITH protect, noconstant(0)
   DECLARE lloctypesize = i4 WITH protect, noconstant(0)
   DECLARE lcnt1 = i4 WITH protect, noconstant(0)
   DECLARE lcnt2 = i4 WITH protect, noconstant(0)
   SET llistsize = size(request->levellist,5)
   SET lstat = alterlist(temp_req->levellist,llistsize)
   SET temp_req->search_prefix = request->search_prefix
   SET temp_req->max_count = request->max_count
   FOR (llevel = 1 TO llistsize)
     SET lfiltersize = size(request->levellist[llevel].locationfilterlist,5)
     IF (lfiltersize > 0)
      SET lstat = alterlist(temp_req->levellist[llevel].locationfilterlist,lfiltersize)
      FOR (lcnt1 = 1 TO lfiltersize)
        SET temp_req->levellist[llevel].locationfilterlist[lcnt1].location_cd = request->levellist[
        llevel].locationfilterlist[lcnt1].location_cd
      ENDFOR
     ENDIF
     SET lloctypesize = size(request->levellist[llevel].locationlist,5)
     IF (lloctypesize > 0)
      SET lstat = alterlist(temp_req->levellist[llevel].locationlist,lloctypesize)
      FOR (lcnt2 = 1 TO lloctypesize)
       SET temp_req->levellist[llevel].locationlist[lcnt2].location_type_cd = request->levellist[
       llevel].locationlist[lcnt2].location_type_cd
       SET temp_req->levellist[llevel].locationlist[lcnt2].discipline_type_cd = request->levellist[
       llevel].locationlist[lcnt2].discipline_type_cd
      ENDFOR
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE getcodevalues(null)
   DECLARE code_cnt = i4 WITH protect, noconstant(1)
   SET lstat = uar_get_meaning_by_codeset(lloc_type_cs,nullterm(snurseunit),code_cnt,dnurseunit)
   IF (dnurseunit=0.0)
    SET reply->status_data.status = "F"
    CALL subevent_add("bb_get_locations.prg","F","uar_get_meaning_by_codeset",
     "Unable to retrieve the code_value for the cdf_meaning NURSEUNIT in code_set 222.")
    SET reply->status = "F"
    RETURN(0)
   ENDIF
   SET lstat = uar_get_meaning_by_codeset(lloc_type_cs,nullterm(sancilsurg),code_cnt,dancilsurg)
   IF (dancilsurg=0.0)
    SET reply->status_data.status = "F"
    CALL subevent_add("bb_get_locations.prg","F","uar_get_meaning_by_codeset",
     "Unable to retrieve the code_value for the cdf_meaning ANCILSURG in code_set 222.")
    SET reply->status = "F"
    RETURN(0)
   ENDIF
   SET lstat = uar_get_meaning_by_codeset(lloc_type_cs,nullterm(sambulatory),code_cnt,dambulatory)
   IF (dambulatory=0.0)
    SET reply->status_data.status = "F"
    CALL subevent_add("bb_get_locations.prg","F","uar_get_meaning_by_codeset",
     "Unable to retrieve the code_value for the cdf_meaning AMBULATORY in code_set 222.")
    SET reply->status = "F"
    RETURN(0)
   ENDIF
   SET lstat = uar_get_meaning_by_codeset(lloc_type_cs,nullterm(slab),code_cnt,dlab)
   IF (dlab=0.0)
    SET reply->status_data.status = "F"
    CALL subevent_add("bb_get_locations.prg","F","uar_get_meaning_by_codeset",
     "Unable to retrieve the code_value for the cdf_meaning LAB in code_set 222.")
    SET reply->status = "F"
    RETURN(0)
   ENDIF
   SET lstat = uar_get_meaning_by_codeset(lloc_type_cs,nullterm(spharm),code_cnt,dpharm)
   IF (dpharm=0.0)
    SET reply->status_data.status = "F"
    CALL subevent_add("bb_get_locations.prg","F","uar_get_meaning_by_codeset",
     "Unable to retrieve the code_value for the cdf_meaning PHARM in code_set 222.")
    SET reply->status = "F"
    RETURN(0)
   ENDIF
   SET lstat = uar_get_meaning_by_codeset(lloc_type_cs,nullterm(sapptloc),code_cnt,dapptloc)
   IF (dapptloc=0.0)
    SET reply->status_data.status = "F"
    CALL subevent_add("bb_get_locations.prg","F","uar_get_meaning_by_codeset",
     "Unable to retrieve the code_value for the cdf_meaning APPTLOC in code_set 222.")
    SET reply->status = "F"
    RETURN(0)
   ENDIF
   SET lstat = uar_get_meaning_by_codeset(lloc_type_cs,nullterm(srad),code_cnt,drad)
   IF (drad=0.0)
    SET reply->status_data.status = "F"
    CALL subevent_add("bb_get_locations.prg","F","uar_get_meaning_by_codeset",
     "Unable to retrieve the code_value for the cdf_meaning RAD in code_set 222.")
    SET reply->status = "F"
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (parserequestupfacility(nlevel=i2,nlocationsize=i4) =i2)
   DECLARE nicnt = i2 WITH protect, noconstant(0)
   DECLARE lsize = i4 WITH protect, noconstant(0)
   CALL resetexpandvars(null)
   SET lloopcnt = ceil((cnvtreal(nlocationsize)/ lparsebatchsize))
   SET lcurlistsize = size(request->levellist[nlevel].locationlist,5)
   SET lnewlistsize = (lloopcnt * lparsebatchsize)
   SET lstat = alterlist(request->levellist[nlevel].locationlist,lnewlistsize)
   FOR (lloopidx = (lcurlistsize+ 1) TO lnewlistsize)
    SET request->levellist[nlevel].locationlist[lloopidx].location_type_cd = request->levellist[
    nlevel].locationlist[lcurlistsize].location_type_cd
    SET request->levellist[nlevel].locationlist[lloopidx].discipline_type_cd = request->levellist[
    nlevel].locationlist[lcurlistsize].discipline_type_cd
   ENDFOR
   SELECT INTO "nl:"
    col_seq = uar_get_collation_seq(lg2.parent_loc_cd), facility = uar_get_code_display(lg2
     .parent_loc_cd), building = uar_get_code_display(lg1.parent_loc_cd),
    ambulatory = uar_get_code_display(lg1.child_loc_cd)
    FROM (dummyt d1  WITH seq = value(lloopcnt)),
     location lo,
     location_group lg1,
     location_group lg2
    PLAN (d1
     WHERE initarray(lstart,evaluate(d1.seq,1,1,(lstart+ lparsebatchsize))))
     JOIN (lo
     WHERE expand(lnumidx,lstart,(lstart+ (lparsebatchsize - 1)),lo.location_type_cd,request->
      levellist[nlevel].locationlist[lnumidx].location_type_cd)
      AND ((lo.active_ind+ 0)=1)
      AND ((lo.beg_effective_dt_tm+ 0) <= cnvtdatetime(sysdate))
      AND ((lo.end_effective_dt_tm+ 0) >= cnvtdatetime(sysdate)))
     JOIN (lg1
     WHERE lg1.child_loc_cd=lo.location_cd
      AND ((lg1.active_ind+ 0)=1)
      AND ((lg1.beg_effective_dt_tm+ 0) <= cnvtdatetime(sysdate))
      AND ((lg1.end_effective_dt_tm+ 0) >= cnvtdatetime(sysdate)))
     JOIN (lg2
     WHERE lg2.child_loc_cd=lg1.parent_loc_cd
      AND ((lg2.active_ind+ 0)=1)
      AND ((lg2.beg_effective_dt_tm+ 0) <= cnvtdatetime(sysdate))
      AND ((lg2.end_effective_dt_tm+ 0) >= cnvtdatetime(sysdate)))
    ORDER BY col_seq, lg2.sequence, lg1.sequence
    HEAD REPORT
     ncnt = 0, loop1 = 0, badd = "F",
     ncnt2 = 0, ncnt3 = 0, bcontinue = "T"
    DETAIL
     IF (norgsecurityflag=1)
      IF (isvalidorg(lo.organization_id)=0)
       bcontinue = "F"
      ELSE
       bcontinue = "T"
      ENDIF
     ENDIF
     IF (bcontinue="T")
      badd = "F"
      IF (isduplicate(lo.location_cd,3)=0)
       IF (size(request->levellist[nlevel].locationlist,5) > 0)
        FOR (loop1 = 1 TO size(request->levellist[nlevel].locationlist,5))
          IF ((request->levellist[nlevel].locationlist[loop1].location_type_cd=lo.location_type_cd))
           IF ((request->levellist[nlevel].locationlist[loop1].discipline_type_cd > 0.00))
            IF ((request->levellist[nlevel].locationlist[loop1].discipline_type_cd=lo
            .discipline_type_cd))
             badd = "T", loop1 = size(request->levellist[nlevel].locationlist,5)
            ENDIF
           ELSE
            badd = "T", loop1 = size(request->levellist[nlevel].locationlist,5)
           ENDIF
          ENDIF
        ENDFOR
       ELSE
        badd = "T"
       ENDIF
      ENDIF
      IF (badd="T")
       IF (isduplicate(lg2.parent_loc_cd,1)=0)
        ncnt += 1
        IF (ncnt > size(temp_req->levellist[1].locationfilterlist,5))
         lstat = alterlist(temp_req->levellist[1].locationfilterlist,ncnt)
        ENDIF
        IF (lg2.parent_loc_cd > 0.00)
         temp_req->levellist[1].locationfilterlist[ncnt].location_cd = lg2.parent_loc_cd
        ENDIF
       ENDIF
       IF (isduplicate(lg1.parent_loc_cd,2)=0)
        ncnt2 += 1
        IF (ncnt2 > size(temp_req->levellist[2].locationfilterlist,5))
         lstat = alterlist(temp_req->levellist[2].locationfilterlist,ncnt2)
        ENDIF
        IF (lg1.parent_loc_cd > 0.00)
         temp_req->levellist[2].locationfilterlist[ncnt2].location_cd = lg1.parent_loc_cd
        ENDIF
       ENDIF
       ncnt3 += 1
       IF (ncnt3 > size(temp_req->levellist[3].locationfilterlist,5))
        lstat = alterlist(temp_req->levellist[3].locationfilterlist,ncnt3)
       ENDIF
       temp_req->levellist[3].locationfilterlist[ncnt3].location_cd = lo.location_cd
      ENDIF
     ENDIF
    FOOT REPORT
     lstat = alterlist(request->levellist[nlevel].locationlist,lcurlistsize)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE (parserequestupbuilding(nlevel=i2,nlocationsize=i4) =i2)
   DECLARE nicnt = i2 WITH protect, noconstant(0)
   DECLARE lsize = i4 WITH protect, noconstant(0)
   CALL resetexpandvars(null)
   SET lloopcnt = ceil((cnvtreal(nlocationsize)/ lparsebatchsize))
   SET lcurlistsize = size(request->levellist[nlevel].locationlist,5)
   SET lnewlistsize = (lloopcnt * lparsebatchsize)
   SET lstat = alterlist(request->levellist[nlevel].locationlist,lnewlistsize)
   FOR (lloopidx = (lcurlistsize+ 1) TO lnewlistsize)
    SET request->levellist[nlevel].locationlist[lloopidx].location_type_cd = request->levellist[
    nlevel].locationlist[lcurlistsize].location_type_cd
    SET request->levellist[nlevel].locationlist[lloopidx].discipline_type_cd = request->levellist[
    nlevel].locationlist[lcurlistsize].discipline_type_cd
   ENDFOR
   SELECT INTO "nl:"
    col_seq = uar_get_collation_seq(lg1.parent_loc_cd), building = uar_get_code_display(lg1
     .parent_loc_cd), ambulatory = uar_get_code_display(lg1.child_loc_cd)
    FROM (dummyt d1  WITH seq = value(lloopcnt)),
     location lo,
     location_group lg1
    PLAN (d1
     WHERE initarray(lstart,evaluate(d1.seq,1,1,(lstart+ lparsebatchsize))))
     JOIN (lo
     WHERE expand(lnumidx,lstart,(lstart+ (lparsebatchsize - 1)),lo.location_type_cd,request->
      levellist[nlevel].locationlist[nicnt].location_type_cd)
      AND ((lo.active_ind+ 0)=1)
      AND ((lo.beg_effective_dt_tm+ 0) <= cnvtdatetime(sysdate))
      AND ((lo.end_effective_dt_tm+ 0) >= cnvtdatetime(sysdate)))
     JOIN (lg1
     WHERE lg1.child_loc_cd=lo.location_cd
      AND ((lg1.active_ind+ 0)=1)
      AND ((lg1.beg_effective_dt_tm+ 0) <= cnvtdatetime(sysdate))
      AND ((lg1.end_effective_dt_tm+ 0) >= cnvtdatetime(sysdate)))
    ORDER BY col_seq, lg1.sequence
    HEAD REPORT
     loop1 = 0, badd = "F", ncnt = 0,
     ncnt2 = 0
    DETAIL
     badd = "F"
     IF (isduplicate(lo.location_cd,2)=0)
      IF (size(request->levellist[nlevel].locationlist,5) > 0)
       FOR (loop1 = 1 TO size(request->levellist[nlevel].locationlist,5))
         IF ((request->levellist[nlevel].locationlist[loop1].location_type_cd=lo.location_type_cd))
          IF ((request->levellist[nlevel].locationlist[loop1].discipline_type_cd > 0.00))
           IF ((request->levellist[nlevel].locationlist[loop1].discipline_type_cd=lo
           .discipline_type_cd))
            badd = "T", loop1 = size(request->levellist[nlevel].locationlist,5)
           ENDIF
          ELSE
           badd = "T", loop1 = size(request->levellist[nlevel].locationlist,5)
          ENDIF
         ENDIF
       ENDFOR
      ELSE
       badd = "T"
      ENDIF
     ENDIF
     IF (badd="T")
      IF (isduplicate(lg1.parent_loc_cd,1)=0)
       ncnt += 1
       IF (ncnt > size(temp_req->levellist[1].locationfilterlist,5))
        lstat = alterlist(temp_req->levellist[1].locationfilterlist,ncnt)
       ENDIF
       temp_req->levellist[1].locationfilterlist[ncnt].location_cd = lg1.parent_loc_cd
      ENDIF
      ncnt2 += 1
      IF (ncnt2 > size(temp_req->levellist[2].locationfilterlist,5))
       lstat = alterlist(temp_req->levellist[2].locationfilterlist,ncnt2)
      ENDIF
      temp_req->levellist[2].locationfilterlist[ncnt2].location_cd = lo.location_cd
     ENDIF
    FOOT REPORT
     lstat = alterlist(request->levellist[nlevel].locationlist,lcurlistsize)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE getlevelinfo_with_filter_1(null)
   DECLARE ordercnt1 = i2 WITH protect, noconstant(0)
   SET lnumidx = 0
   SET stat = alterlist(code_req115408->criteria,2)
   SET code_req115408->criteria[1].name = "PLACE_NAME"
   SET stat = alterlist(code_req115408->criteria[1].value_str,1)
   SET code_req115408->criteria[1].value_str[1].value = temp_req->search_prefix
   SET code_req115408->criteria[2].name = "PLACE_CODE"
   SET stat = alterlist(code_req115408->criteria[2].value_nbr,1)
   SET code_req115408->criteria[2].value_nbr[1].value_nbr = temp_req->levellist[1].locationlist[1].
   location_type_cd
   EXECUTE pm_get_location_by_crit  WITH replace("REQUEST","CODE_REQ115408"), replace("REPLY",
    "CODE_REP115408")
   IF ((code_rep115408->status_data.status="Z"))
    SET select_ok_flag = 2
    GO TO exit_script
   ENDIF
   IF ((code_rep115408->status_data.status="F"))
    SET select_ok_flag = 0
    GO TO exit_script
   ENDIF
   SELECT INTO "nl:"
    col_seq = uar_get_collation_seq(lo.location_cd), lo.location_cd, displaysort =
    uar_get_code_display(lo.location_cd)
    FROM location lo
    PLAN (lo
     WHERE expand(lnumidx,1,size(code_rep115408->locations,5),lo.location_cd,code_rep115408->
      locations[lnumidx].location_cd))
    ORDER BY displaysort
    HEAD col_seq
     badd = "T"
    DETAIL
     IF (norgsecurityflag=1)
      IF (isvalidorg(lo.organization_id)=0)
       badd = "F"
      ELSE
       badd = "T"
      ENDIF
     ENDIF
     IF (badd="T")
      IF (textlen(trim(uar_get_code_display(lo.location_cd))) > 0)
       ordercnt1 += 1
       IF (ordercnt1 > size(reply->levellist1,5))
        lstat = alterlist(reply->levellist1,(ordercnt1+ 5))
       ENDIF
       reply->levellist1[ordercnt1].location_cd = lo.location_cd, reply->levellist1[ordercnt1].
       location_type_cd = lo.location_type_cd, reply->levellist1[ordercnt1].discipline_type_cd = lo
       .discipline_type_cd,
       reply->levellist1[ordercnt1].organization_id = lo.organization_id
      ENDIF
     ENDIF
     IF ((ordercnt1 > temp_req->max_count))
      IF (lo.location_cd != 0)
       CALL cancel(1)
      ENDIF
     ENDIF
    FOOT REPORT
     lstat = alterlist(reply->levellist1,ordercnt1)
    WITH nocounter, expand = 1
   ;end select
   IF (ordercnt1=0)
    SET select_ok_flag = 2
    GO TO exit_script
   ELSEIF ((ordercnt1 > temp_req->max_count))
    SET lstat = alterlist(reply->levellist1,temp_req->max_count)
    SET select_ok_flag = 3
    GO TO exit_script
   ELSE
    SET select_ok_flag = 1
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE getlevelinfo_1(null)
   DECLARE ordercnt1 = i2 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    col_seq = uar_get_collation_seq(lo.location_cd), lo.location_cd
    FROM location lo
    PLAN (lo
     WHERE (lo.location_type_cd=temp_req->levellist[1].locationlist[1].location_type_cd)
      AND ((lo.active_ind+ 0)=1))
    ORDER BY col_seq
    HEAD col_seq
     badd = "F"
    DETAIL
     IF (norgsecurityflag=1)
      IF (isvalidorg(lo.organization_id)=0)
       badd = "F"
      ELSE
       badd = "T"
      ENDIF
     ENDIF
     IF (badd="T")
      IF (textlen(trim(uar_get_code_display(lo.location_cd))) > 0)
       ordercnt1 += 1
       IF (ordercnt1 > size(reply->levellist1,5))
        lstat = alterlist(reply->levellist1,(ordercnt1+ 5))
       ENDIF
       reply->levellist1[ordercnt1].location_cd = lo.location_cd, reply->levellist1[ordercnt1].
       location_type_cd = lo.location_type_cd, reply->levellist1[ordercnt1].discipline_type_cd = lo
       .discipline_type_cd,
       reply->levellist1[ordercnt1].organization_id = lo.organization_id
      ENDIF
     ENDIF
     IF ((temp_req->max_count > 0)
      AND (ordercnt1 > temp_req->max_count))
      IF (lo.location_cd != 0)
       CALL cancel(1)
      ENDIF
     ENDIF
    FOOT REPORT
     lstat = alterlist(reply->levellist1,ordercnt1)
    WITH nocounter
   ;end select
   IF (ordercnt1=0)
    SET select_ok_flag = 2
    GO TO exit_script
   ELSEIF ((temp_req->max_count > 0)
    AND (ordercnt1 > temp_req->max_count))
    SET lstat = alterlist(reply->levellist1,0)
    SET select_ok_flag = 3
    GO TO exit_script
   ELSE
    SET select_ok_flag = 1
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (getlevelinfo_2(nlocationsize=i4,nfiltersize=i4) =i2)
   DECLARE nordercnt2 = i2 WITH protect, noconstant(0)
   DECLARE nloctypecnt2 = i2 WITH protect, noconstant(0)
   DECLARE nfiltercnt2 = i2 WITH protect, noconstant(0)
   DECLARE ncnt = i2 WITH protect, noconstant(0)
   DECLARE nidx = i2 WITH protect, noconstant(0)
   CALL resetexpandvars(null)
   IF (nfiltersize > 0)
    SET lloopcnt = ceil((cnvtreal(nfiltersize)/ lbatchsize))
   ELSE
    SET lloopcnt = ceil((cnvtreal(nlocationsize)/ lbatchsize))
   ENDIF
   SET lcurlistsize = size(reply->levellist1,5)
   SET lnewlistsize = (lloopcnt * lbatchsize)
   SET lstat = alterlist(reply->levellist1,lnewlistsize)
   FOR (lloopidx = (lcurlistsize+ 1) TO lnewlistsize)
     SET reply->levellist1[lloopidx].location_cd = reply->levellist1[lcurlistsize].location_cd
   ENDFOR
   SELECT
    IF (nfiltersize > 0)
     PLAN (d1
      WHERE initarray(lstart,evaluate(d1.seq,1,1,(lstart+ lbatchsize))))
      JOIN (lg
      WHERE expand(lnumidx,lstart,(lstart+ (lbatchsize - 1)),lg.parent_loc_cd,reply->levellist1[
       lnumidx].location_cd,
       lg.location_group_type_cd,reply->levellist1[lnumidx].location_type_cd)
       AND expand(nfiltercnt2,1,nfiltersize,lg.child_loc_cd,temp_req->levellist[2].
       locationfilterlist[nfiltercnt2].location_cd)
       AND ((lg.active_ind+ 0)=1)
       AND ((lg.root_loc_cd+ 0)=0.0))
      JOIN (lo
      WHERE lo.location_cd=lg.child_loc_cd
       AND ((lo.active_ind+ 0)=1))
     ORDER BY lg.parent_loc_cd, lg.sequence
    ELSE
     PLAN (d1
      WHERE initarray(lstart,evaluate(d1.seq,1,1,(lstart+ lbatchsize))))
      JOIN (lg
      WHERE expand(lnumidx,lstart,(lstart+ (lbatchsize - 1)),lg.parent_loc_cd,reply->levellist1[
       lnumidx].location_cd)
       AND ((lg.active_ind+ 0)=1)
       AND ((lg.root_loc_cd+ 0)=0.0))
      JOIN (lo
      WHERE lo.location_cd=lg.child_loc_cd
       AND ((lo.active_ind+ 0)=1)
       AND expand(nloctypecnt2,1,nlocationsize,(lo.location_type_cd+ 0),temp_req->levellist[2].
       locationlist[nloctypecnt2].location_type_cd))
     ORDER BY lg.parent_loc_cd, lg.sequence
    ENDIF
    INTO "nl:"
    nindex = locateval(nidx,1,size(reply->levellist1,5),lg.parent_loc_cd,reply->levellist1[nidx].
     location_cd)
    FROM (dummyt d1  WITH seq = value(lloopcnt)),
     location_group lg,
     location lo
    HEAD REPORT
     ordercnt2 = 0, loop1 = 0, badd = "F"
    HEAD lg.parent_loc_cd
     ordercnt2 = 0
    HEAD lg.sequence
     row + 0
    DETAIL
     badd = "F"
     IF (nlocationsize > 0)
      FOR (loop1 = 1 TO nlocationsize)
        IF ((temp_req->levellist[2].locationlist[loop1].location_type_cd=lo.location_type_cd))
         IF ((temp_req->levellist[2].locationlist[loop1].discipline_type_cd > 0.00))
          IF ((temp_req->levellist[2].locationlist[loop1].discipline_type_cd=lo.discipline_type_cd))
           badd = "T", loop1 = nlocationsize
          ENDIF
         ELSE
          badd = "T", loop1 = nlocationsize
         ENDIF
        ENDIF
      ENDFOR
     ELSE
      badd = "T"
     ENDIF
     IF (badd="T")
      ordercnt2 += 1
      IF (ordercnt2 > size(reply->levellist1[nindex].levellist2,5))
       lstat = alterlist(reply->levellist1[nindex].levellist2,ordercnt2)
      ENDIF
      reply->levellist1[nindex].levellist2[ordercnt2].location_cd = lo.location_cd, reply->
      levellist1[nindex].levellist2[ordercnt2].location_type_cd = lo.location_type_cd, reply->
      levellist1[nindex].levellist2[ordercnt2].discipline_type_cd = lo.discipline_type_cd,
      reply->levellist1[nindex].levellist2[ordercnt2].organization_id = lo.organization_id,
      nordercnt2 += 1
     ENDIF
    FOOT  lg.parent_loc_cd
     reply->levellist1[nindex].lvl2_cnt = ordercnt2
    FOOT REPORT
     select_ok_flag = 1, lstat = alterlist(reply->levellist1,lcurlistsize)
    WITH nocounter
   ;end select
   IF (nordercnt2=0)
    GO TO exit_script
   ELSE
    SET lnumrecords2 = nordercnt2
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (getlevelinfo_3(nlocationsize=i4,nfiltersize=i4) =i2)
   DECLARE nordercnt3 = i2 WITH protect, noconstant(0)
   DECLARE nloctypecnt3 = i2 WITH protect, noconstant(0)
   DECLARE nfiltercnt3 = i2 WITH protect, noconstant(0)
   DECLARE ncnt = i2 WITH protect, noconstant(0)
   DECLARE nidx1 = i2 WITH protect, noconstant(0)
   DECLARE nidx2 = i2 WITH protect, noconstant(0)
   FOR (nidx1 = 1 TO size(reply->levellist1,5))
     IF ((reply->levellist1[nidx1].lvl2_cnt > 0))
      CALL resetexpandvars(null)
      IF (nfiltersize > 0)
       SET lloopcnt = ceil((cnvtreal(nfiltersize)/ lbatchsize))
      ELSE
       SET lloopcnt = ceil((cnvtreal(nlocationsize)/ lbatchsize))
      ENDIF
      SET lcurlistsize = size(reply->levellist1[nidx1].levellist2,5)
      SET lnewlistsize = (lloopcnt * lbatchsize)
      SET lstat = alterlist(reply->levellist1[nidx1].levellist2,lnewlistsize)
      FOR (lloopidx = (lcurlistsize+ 1) TO lnewlistsize)
        SET reply->levellist1[nidx1].levellist2[lloopidx].location_cd = reply->levellist1[nidx1].
        levellist2[lcurlistsize].location_cd
      ENDFOR
      SELECT
       IF (nfiltersize > 0)
        PLAN (d1
         WHERE initarray(lstart,evaluate(d1.seq,1,1,(lstart+ lbatchsize))))
         JOIN (lg
         WHERE expand(lnumidx,lstart,(lstart+ (lbatchsize - 1)),lg.parent_loc_cd,reply->levellist1[
          nidx1].levellist2[lnumidx].location_cd,
          lg.location_group_type_cd,reply->levellist1[nidx1].levellist2[lnumidx].location_type_cd)
          AND expand(nfiltercnt3,1,nfiltersize,lg.child_loc_cd,temp_req->levellist[3].
          locationfilterlist[nfiltercnt3].location_cd)
          AND ((lg.active_ind+ 0)=1)
          AND ((lg.root_loc_cd+ 0)=0.0))
         JOIN (lo
         WHERE lo.location_cd=lg.child_loc_cd
          AND ((lo.active_ind+ 0)=1))
        ORDER BY nindex2, lg.sequence
       ELSE
        PLAN (d1
         WHERE initarray(lstart,evaluate(d1.seq,1,1,(lstart+ lbatchsize))))
         JOIN (lg
         WHERE expand(lnumidx,lstart,(lstart+ (lbatchsize - 1)),lg.parent_loc_cd,reply->levellist1[
          nidx1].levellist2[lnumidx].location_cd,
          lg.location_group_type_cd,reply->levellist1[nidx1].levellist2[lnumidx].location_type_cd)
          AND ((lg.active_ind+ 0)=1)
          AND ((lg.root_loc_cd+ 0)=0.0))
         JOIN (lo
         WHERE lo.location_cd=lg.child_loc_cd
          AND ((lo.active_ind+ 0)=1)
          AND expand(nloctypecnt3,1,nlocationsize,(lo.location_type_cd+ 0),temp_req->levellist[3].
          locationlist[nloctypecnt3].location_type_cd))
        ORDER BY nindex2, lg.sequence
       ENDIF
       INTO "nl:"
       nindex2 = locateval(nidx2,1,size(reply->levellist1[nidx1].levellist2,5),lg.parent_loc_cd,reply
        ->levellist1[nidx1].levellist2[nidx2].location_cd)
       FROM (dummyt d1  WITH seq = value(lloopcnt)),
        location_group lg,
        location lo
       HEAD REPORT
        ordercnt3 = 0, loop1 = 0, badd = "F"
       HEAD nindex2
        ordercnt3 = 0
       HEAD lg.sequence
        row + 0
       DETAIL
        badd = "F"
        IF (nlocationsize > 0)
         FOR (loop1 = 1 TO nlocationsize)
           IF ((temp_req->levellist[3].locationlist[loop1].location_type_cd=lo.location_type_cd))
            IF ((temp_req->levellist[3].locationlist[loop1].discipline_type_cd > 0.00))
             IF ((temp_req->levellist[3].locationlist[loop1].discipline_type_cd=lo.discipline_type_cd
             ))
              badd = "T", loop1 = nlocationsize
             ENDIF
            ELSE
             badd = "T", loop1 = nlocationsize
            ENDIF
           ENDIF
         ENDFOR
        ELSE
         badd = "T"
        ENDIF
        IF (badd="T")
         ordercnt3 += 1
         IF (ordercnt3 > size(reply->levellist1[nidx1].levellist2[nindex2].levellist3,5))
          lstat = alterlist(reply->levellist1[nidx1].levellist2[nindex2].levellist3,ordercnt3)
         ENDIF
         reply->levellist1[nidx1].levellist2[nindex2].levellist3[ordercnt3].location_cd = lo
         .location_cd, reply->levellist1[nidx1].levellist2[nindex2].levellist3[ordercnt3].
         location_type_cd = lo.location_type_cd, reply->levellist1[nidx1].levellist2[nindex2].
         levellist3[ordercnt3].discipline_type_cd = lo.discipline_type_cd,
         reply->levellist1[nidx1].levellist2[nindex2].levellist3[ordercnt3].organization_id = lo
         .organization_id, nordercnt3 += 1
        ENDIF
       FOOT  nindex2
        reply->levellist1[nidx1].levellist2[nindex2].lvl3_cnt = ordercnt3
       FOOT REPORT
        select_ok_flag = 1, lstat = alterlist(reply->levellist1[nidx1].levellist2,lcurlistsize)
       WITH nocounter
      ;end select
     ENDIF
   ENDFOR
   IF (nordercnt3=0)
    GO TO exit_script
   ELSE
    SET lnumrecords3 = nordercnt3
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (getlevelinfo_4(nlocationsize=i4,nfiltersize=i4) =i2)
   DECLARE nordercnt4 = i2 WITH protect, noconstant(0)
   DECLARE nloctypecnt4 = i2 WITH protect, noconstant(0)
   DECLARE nfiltercnt4 = i2 WITH protect, noconstant(0)
   DECLARE ncnt = i2 WITH protect, noconstant(0)
   DECLARE nidx1 = i2 WITH protect, noconstant(0)
   DECLARE nidx2 = i2 WITH protect, noconstant(0)
   DECLARE nidx3 = i2 WITH protect, noconstant(0)
   FOR (nidx1 = 1 TO size(reply->levellist1,5))
     IF ((reply->levellist1[nidx1].lvl2_cnt > 0))
      FOR (nidx2 = 1 TO size(reply->levellist1[nidx1].levellist2,5))
        IF ((reply->levellist1[nidx1].levellist2[nidx2].lvl3_cnt > 0))
         CALL resetexpandvars(null)
         IF (nfiltersize > 0)
          SET lloopcnt = ceil((cnvtreal(nfiltersize)/ lbatchsize))
         ELSE
          SET lloopcnt = ceil((cnvtreal(nlocationsize)/ lbatchsize))
         ENDIF
         SET lcurlistsize = size(reply->levellist1[nidx1].levellist2[nidx2].levellist3,5)
         SET lnewlistsize = (lloopcnt * lbatchsize)
         SET lstat = alterlist(reply->levellist1[nidx1].levellist2[nidx2].levellist3,lnewlistsize)
         FOR (lloopidx = (lcurlistsize+ 1) TO lnewlistsize)
           SET reply->levellist1[nidx1].levellist2[nidx2].levellist3[lloopidx].location_cd = reply->
           levellist1[nidx1].levellist2[nidx2].levellist3[lcurlistsize].location_cd
         ENDFOR
         SELECT
          IF (nlocationsize > 0
           AND nfiltersize > 0)
           PLAN (d1
            WHERE initarray(lstart,evaluate(d1.seq,1,1,(lstart+ lbatchsize))))
            JOIN (lg
            WHERE expand(lnumidx,lstart,(lstart+ (lbatchsize - 1)),lg.parent_loc_cd,reply->
             levellist1[nidx1].levellist2[nidx2].levellist3[lnumidx].location_cd,
             lg.location_group_type_cd,reply->levellist1[nidx1].levellist2[nidx2].levellist3[lnumidx]
             .location_type_cd)
             AND ((lg.active_ind+ 0)=1)
             AND ((lg.root_loc_cd+ 0)=0.0))
            JOIN (lo
            WHERE lo.location_cd=lg.child_loc_cd
             AND expand(nloctypecnt4,1,nlocationsize,lo.location_type_cd,temp_req->levellist[4].
             locationlist[nloctypecnt4].location_type_cd)
             AND expand(nfiltercnt4,1,nfiltersize,lo.location_cd,temp_req->levellist[4].
             locationfilterlist[nfiltercnt4].location_cd)
             AND ((lo.active_ind+ 0)=1))
           ORDER BY nindex3, lg.sequence
          ELSE
           PLAN (d1
            WHERE initarray(lstart,evaluate(d1.seq,1,1,(lstart+ lbatchsize))))
            JOIN (lg
            WHERE expand(lnumidx,lstart,(lstart+ (lbatchsize - 1)),lg.parent_loc_cd,reply->
             levellist1[nidx1].levellist2[nidx2].levellist3[lnumidx].location_cd,
             lg.location_group_type_cd,reply->levellist1[nidx1].levellist2[nidx2].levellist3[lnumidx]
             .location_type_cd)
             AND ((lg.active_ind+ 0)=1)
             AND ((lg.root_loc_cd+ 0)=0.0)
             AND lg.beg_effective_dt_tm <= cnvtdatetime(sysdate)
             AND lg.end_effective_dt_tm >= cnvtdatetime(sysdate))
            JOIN (lo
            WHERE lo.location_cd=lg.child_loc_cd
             AND expand(nloctypecnt4,1,nlocationsize,(lo.location_type_cd+ 0),temp_req->levellist[4].
             locationlist[nloctypecnt4].location_type_cd)
             AND ((lo.active_ind+ 0)=1)
             AND ((lo.beg_effective_dt_tm+ 0) <= cnvtdatetime(sysdate))
             AND ((lo.end_effective_dt_tm+ 0) >= cnvtdatetime(sysdate)))
           ORDER BY nindex3, lg.sequence
          ENDIF
          INTO "nl:"
          nindex3 = locateval(nidx3,1,size(reply->levellist1[nidx1].levellist2[nidx2].levellist3,5),
           lg.parent_loc_cd,reply->levellist1[nidx1].levellist2[nidx2].levellist3[nidx3].location_cd)
          FROM (dummyt d1  WITH seq = value(lloopcnt)),
           location_group lg,
           location lo
          HEAD REPORT
           ordercnt4 = 0, loop1 = 0, badd = "F"
          HEAD nindex3
           ordercnt4 = 0
          HEAD lg.sequence
           row + 0
          DETAIL
           badd = "F"
           IF (nlocationsize > 0)
            FOR (loop1 = 1 TO nlocationsize)
              IF ((temp_req->levellist[4].locationlist[loop1].location_type_cd=lo.location_type_cd))
               IF ((temp_req->levellist[4].locationlist[loop1].discipline_type_cd > 0.00))
                IF ((temp_req->levellist[4].locationlist[loop1].discipline_type_cd=lo
                .discipline_type_cd))
                 badd = "T", loop1 = nlocationsize
                ENDIF
               ELSE
                badd = "T", loop1 = nlocationsize
               ENDIF
              ENDIF
            ENDFOR
           ELSE
            badd = "T"
           ENDIF
           IF (badd="T")
            ordercnt4 += 1
            IF (ordercnt4 > size(reply->levellist1[nidx1].levellist2[nidx2].levellist3[nindex3].
             levellist4,5))
             lstat = alterlist(reply->levellist1[nidx1].levellist2[nidx2].levellist3[nindex3].
              levellist4,ordercnt4)
            ENDIF
            reply->levellist1[nidx1].levellist2[nidx2].levellist3[nindex3].levellist4[ordercnt4].
            location_cd = lo.location_cd, reply->levellist1[nidx1].levellist2[nidx2].levellist3[
            nindex3].levellist4[ordercnt4].location_type_cd = lo.location_type_cd, reply->levellist1[
            nidx1].levellist2[nidx2].levellist3[nindex3].levellist4[ordercnt4].discipline_type_cd =
            lo.discipline_type_cd,
            reply->levellist1[nidx1].levellist2[nidx2].levellist3[nindex3].levellist4[ordercnt4].
            organization_id = lo.organization_id
           ENDIF
          FOOT  nindex3
           reply->levellist1[nidx1].levellist2[nidx2].levellist3[nindex3].lvl4_cnt = ordercnt4
           IF (nordercnt4 < ordercnt4)
            nordercnt4 = ordercnt4
           ENDIF
          FOOT REPORT
           select_ok_flag = 1, lstat = alterlist(reply->levellist1[nidx1].levellist2[nidx2].
            levellist3,lcurlistsize)
          WITH nocounter
         ;end select
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
   IF (nordercnt4=0)
    GO TO exit_script
   ELSE
    SET lnumrecords4 = nordercnt4
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (getlevelinfo_5(nlocationsize=i4,nfiltersize=i4) =i2)
   DECLARE nordercnt5 = i2 WITH protect, noconstant(0)
   DECLARE nloctypecnt5 = i2 WITH protect, noconstant(0)
   DECLARE nfiltercnt5 = i2 WITH protect, noconstant(0)
   DECLARE ncnt = i2 WITH protect, noconstant(0)
   DECLARE nidx1 = i2 WITH protect, noconstant(0)
   DECLARE nidx2 = i2 WITH protect, noconstant(0)
   DECLARE nidx3 = i2 WITH protect, noconstant(0)
   DECLARE nidx4 = i2 WITH protect, noconstant(0)
   FOR (nidx1 = 1 TO size(reply->levellist1,5))
     IF ((reply->levellist1[nidx1].lvl2_cnt > 0))
      FOR (nidx2 = 1 TO size(reply->levellist1[nidx1].levellist2,5))
        IF ((reply->levellist1[nidx1].levellist2[nidx2].lvl3_cnt > 0))
         FOR (nidx3 = 1 TO size(reply->levellist1[nidx1].levellist2[nidx2].levellist3,5))
           IF ((reply->levellist1[nidx1].levellist2[nidx2].levellist3[nidx3].lvl4_cnt > 0))
            CALL resetexpandvars(null)
            IF (nfiltersize > 0)
             SET lloopcnt = ceil((cnvtreal(nfiltersize)/ lbatchsize))
            ELSE
             SET lloopcnt = ceil((cnvtreal(nlocationsize)/ lbatchsize))
            ENDIF
            SET lcurlistsize = size(reply->levellist1[nidx1].levellist2[nidx2].levellist3[nidx3].
             levellist4,5)
            SET lnewlistsize = (lloopcnt * lbatchsize)
            SET lstat = alterlist(reply->levellist1[nidx1].levellist2[nidx2].levellist3[nidx3].
             levellist4,lnewlistsize)
            FOR (lloopidx = (lcurlistsize+ 1) TO lnewlistsize)
              SET reply->levellist1[nidx1].levellist2[nidx2].levellist3[nidx3].levellist4[lloopidx].
              location_cd = reply->levellist1[nidx1].levellist2[nidx2].levellist3[nidx3].levellist4[
              lcurlistsize].location_cd
            ENDFOR
            SELECT
             IF (nlocationsize > 0
              AND nfiltersize > 0)
              PLAN (d1
               WHERE initarray(lstart,evaluate(d1.seq,1,1,(lstart+ lbatchsize))))
               JOIN (lg
               WHERE expand(lnumidx,lstart,(lstart+ (lbatchsize - 1)),lg.parent_loc_cd,reply->
                levellist1[nidx1].levellist2[nidx2].levellist3[nidx3].levellist4[lnumidx].location_cd,
                lg.location_group_type_cd,reply->levellist1[nidx1].levellist2[nidx2].levellist3[nidx3
                ].levellist4[lnumidx].location_type_cd)
                AND ((lg.active_ind+ 0)=1)
                AND ((lg.root_loc_cd+ 0)=0.0))
               JOIN (lo
               WHERE lo.location_cd=lg.child_loc_cd
                AND expand(nloctypecnt5,1,nlocationsize,lo.location_type_cd,temp_req->levellist[5].
                locationlist[nloctypecnt5].location_type_cd)
                AND expand(nfiltercnt5,1,nfiltersize,lo.location_cd,temp_req->levellist[5].
                locationfilterlist[nfiltercnt5].location_cd)
                AND ((lo.active_ind+ 0)=1))
              ORDER BY nindex4, lg.sequence
             ELSE
              PLAN (d1
               WHERE initarray(lstart,evaluate(d1.seq,1,1,(lstart+ lbatchsize))))
               JOIN (lg
               WHERE expand(lnumidx,lstart,(lstart+ (lbatchsize - 1)),lg.parent_loc_cd,reply->
                levellist1[nidx1].levellist2[nidx2].levellist3[nidx3].levellist4[lnumidx].location_cd,
                lg.location_group_type_cd,reply->levellist1[nidx1].levellist2[nidx2].levellist3[nidx3
                ].levellist4[lnumidx].location_type_cd)
                AND ((lg.active_ind+ 0)=1)
                AND ((lg.root_loc_cd+ 0)=0.0))
               JOIN (lo
               WHERE lo.location_cd=lg.child_loc_cd
                AND expand(nloctypecnt5,1,nlocationsize,(lo.location_type_cd+ 0),temp_req->levellist[
                5].locationlist[nloctypecnt5].location_type_cd)
                AND ((lo.active_ind+ 0)=1))
              ORDER BY nindex4, lg.sequence
             ENDIF
             INTO "nl:"
             nindex4 = locateval(nidx4,1,size(reply->levellist1[nidx1].levellist2[nidx2].levellist3[
               nidx3].levellist4,5),lg.parent_loc_cd,reply->levellist1[nidx1].levellist2[nidx2].
              levellist3[nidx3].levellist4[nidx4].location_cd)
             FROM (dummyt d1  WITH seq = value(lloopcnt)),
              location_group lg,
              location lo
             HEAD REPORT
              ordercnt5 = 0, loop1 = 0, badd = "F"
             HEAD nindex4
              ordercnt5 = 0
             HEAD lg.sequence
              row + 0
             DETAIL
              badd = "F"
              IF (nlocationsize > 0)
               FOR (loop1 = 1 TO nlocationsize)
                 IF ((temp_req->levellist[5].locationlist[loop1].location_type_cd=lo.location_type_cd
                 ))
                  IF ((temp_req->levellist[5].locationlist[loop1].discipline_type_cd > 0.00))
                   IF ((temp_req->levellist[5].locationlist[loop1].discipline_type_cd=lo
                   .discipline_type_cd))
                    badd = "T", loop1 = nlocationsize
                   ENDIF
                  ELSE
                   badd = "T", loop1 = nlocationsize
                  ENDIF
                 ENDIF
               ENDFOR
              ELSE
               badd = "T"
              ENDIF
              IF (badd="T")
               ordercnt5 += 1
               IF (ordercnt5 > size(reply->levellist1[nidx1].levellist2[nidx2].levellist3[nidx3].
                levellist4[nindex4].levellist5,5))
                lstat = alterlist(reply->levellist1[nidx1].levellist2[nidx2].levellist3[nidx3].
                 levellist4[nindex4].levellist5,ordercnt5)
               ENDIF
               reply->levellist1[nidx1].levellist2[nidx2].levellist3[nidx3].levellist4[nindex4].
               levellist5[ordercnt5].location_cd = lo.location_cd, reply->levellist1[nidx1].
               levellist2[nidx2].levellist3[nidx3].levellist4[nindex4].levellist5[ordercnt5].
               location_type_cd = lo.location_type_cd, reply->levellist1[nidx1].levellist2[nidx2].
               levellist3[nidx3].levellist4[nindex4].levellist5[ordercnt5].discipline_type_cd = lo
               .discipline_type_cd,
               reply->levellist1[nidx1].levellist2[nidx2].levellist3[nidx3].levellist4[nindex4].
               levellist5[ordercnt5].organization_id = lo.organization_id
              ENDIF
             FOOT  nindex4
              reply->levellist1[nidx1].levellist2[nidx2].levellist3[nidx3].levellist4[nindex4].
              lvl5_cnt = ordercnt5
             FOOT REPORT
              select_ok_flag = 1, lstat = alterlist(reply->levellist1[nidx1].levellist2[nidx2].
               levellist3[nidx3].levellist4,lcurlistsize), nordercnt5 = ordercnt5
             WITH nocounter
            ;end select
           ENDIF
         ENDFOR
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
   IF (nordercnt5=0)
    GO TO exit_script
   ELSE
    SET lnumrecords5 = nordercnt5
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (isduplicate(loc_cd=f8,level=i2) =i2)
   DECLARE lcnt = i4 WITH protect, noconstant(0)
   DECLARE lsize = i4 WITH protect, noconstant(0)
   DECLARE dupind = i2 WITH protect, noconstant(0)
   SET lsize = size(temp_req->levellist[level].locationfilterlist,5)
   FOR (lcnt = 1 TO lsize)
     IF ((temp_req->levellist[level].locationfilterlist[lcnt].location_cd=loc_cd))
      SET dupind = 1
      SET lcnt = lsize
     ENDIF
   ENDFOR
   RETURN(dupind)
 END ;Subroutine
 SUBROUTINE (isvalidorg(org_id=f8) =i2)
   DECLARE lcnt = i2 WITH protect, noconstant(0)
   DECLARE lsize = i4 WITH protect, noconstant(0)
   DECLARE validind = i2 WITH protect, noconstant(0)
   SET lsize = size(sac_org->organizations,5)
   FOR (lcnt = 1 TO lsize)
     IF ((sac_org->organizations[lcnt].organization_id=org_id))
      SET validind = 1
      SET lcnt = lsize
     ENDIF
   ENDFOR
   RETURN(validind)
 END ;Subroutine
#exit_script
 IF (select_ok_flag=0)
  SET reply->status_data.status = "F"
  CALL subevent_add("Select failed","F","BB_GET_LOCATIONS","Failed to retrieve data.")
 ELSEIF (select_ok_flag=1)
  SET reply->status_data.status = "S"
  CALL subevent_add("Select successful","S","BB_GET_LOCATIONS",
   "All possible data generated successfully.")
 ELSEIF (select_ok_flag=2)
  SET reply->status_data.status = "Z"
  CALL subevent_add("Select successful","Z","BB_GET_LOCATIONS","Data does not exist.")
 ELSEIF (select_ok_flag=3)
  SET reply->status_data.status = "M"
  CALL subevent_add("Too many locations","M","BB_GET_LOCATIONS",
   "Too Many Locations add more filters.")
 ENDIF
 FREE RECORD temp_req
 FREE RECORD code_rep115408
 FREE RECORD code_req115408
END GO
