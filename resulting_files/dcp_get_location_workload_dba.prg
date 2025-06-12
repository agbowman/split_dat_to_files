CREATE PROGRAM dcp_get_location_workload:dba
 RECORD reply(
   1 location_list[*]
     2 location_cd = f8
     2 workload_units = f8
     2 person_list[*]
       3 person_id = f8
       3 encntr_id = f8
       3 acuity_level = i2
       3 name_full_formatted = vc
       3 loc_bed_cd = f8
       3 loc_room_cd = f8
       3 loc_unit_cd = f8
       3 loc_building_cd = f8
       3 loc_facility_cd = f8
       3 organization_id = f8
       3 confid_level_cd = f8
       3 confid_level = i4
       3 filter_ind = i2
       3 task_list[*]
         4 task_id = f8
         4 reference_task_id = f8
         4 catalog_cd = f8
         4 workload_units = f8
         4 multiplier = i4
         4 allpositionchart_ind = i2
         4 task_status_cd = f8
         4 task_class_cd = f8
         4 order_id = f8
         4 freq_id = f8
         4 start_dt_tm = dq8
         4 task_dt_tm = dq8
         4 task_tz = i4
         4 stop_dt_tm = dq8
         4 position_list[*]
           5 position_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD encntr_list(
   1 encntr_list[*]
     2 encntr_id = f8
     2 person_id = f8
     2 organization_id = f8
     2 filter_ind = i2
     2 confid_level = i4
     2 location_idx = i4
     2 person_idx = i4
 )
 IF (validate(i18nuar_def,999)=999)
  CALL echo("Declaring i18nuar_def")
  DECLARE i18nuar_def = i2 WITH persist
  SET i18nuar_def = 1
  DECLARE uar_i18nlocalizationinit(p1=i4,p2=vc,p3=vc,p4=f8) = i4 WITH persist
  DECLARE uar_i18ngetmessage(p1=i4,p2=vc,p3=vc) = vc WITH persist
  DECLARE uar_i18nbuildmessage() = vc WITH persist
  DECLARE uar_i18ngethijridate(imonth=i2(val),iday=i2(val),iyear=i2(val),sdateformattype=vc(ref)) =
  c50 WITH image_axp = "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar =
  "uar_i18nGetHijriDate",
  persist
  DECLARE uar_i18nbuildfullformatname(sfirst=vc(ref),slast=vc(ref),smiddle=vc(ref),sdegree=vc(ref),
   stitle=vc(ref),
   sprefix=vc(ref),ssuffix=vc(ref),sinitials=vc(ref),soriginal=vc(ref)) = c250 WITH image_axp =
  "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar = "i18nBuildFullFormatName",
  persist
  DECLARE uar_i18ngetarabictime(ctime=vc(ref)) = c20 WITH image_axp = "shri18nuar", image_aix =
  "libi18n_locale.a(libi18n_locale.o)", uar = "i18n_GetArabicTime",
  persist
 ENDIF
 DECLARE encntr_org_sec_ind = i4 WITH noconstant(0)
 DECLARE confid_ind = i4 WITH noconstant(0)
 DECLARE examineorgsecurity(null) = null
 DECLARE performorgsecurity(null) = null
 DECLARE performrelationshipoverrides(null) = null
 DECLARE filterpatientname(null) = null
 DECLARE anonymous = vc WITH noconstant(fillstring(50," "))
 DECLARE dminfo_ok = i2 WITH noconstant(0)
 SUBROUTINE examineorgsecurity(null)
   SET error_level = 0
   SET dminfo_ok = validate(ccldminfo->mode,0)
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
       encntr_org_sec_ind = 1, confid_ind = 1
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET error_level = 1
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE performorgsecurity(null)
   DECLARE org_cnt = i4 WITH noconstant(0)
   SET error_level = 0
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
   IF (org_cnt > 0
    AND encounter_cnt > 0)
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = value(encounter_cnt)),
      (dummyt d2  WITH seq = value(org_cnt))
     PLAN (d1
      WHERE (encntr_list->encntr_list[d1.seq].filter_ind=1))
      JOIN (d2
      WHERE (sac_org->organizations[d2.seq].organization_id=encntr_list->encntr_list[d1.seq].
      organization_id))
     DETAIL
      IF (((confid_ind=0) OR ((sac_org->organizations[d2.seq].confid_level >= encntr_list->
      encntr_list[d1.seq].confid_level))) )
       location_idx = encntr_list->encntr_list[d1.seq].location_idx, person_idx = encntr_list->
       encntr_list[d1.seq].person_idx, encntr_list->encntr_list[d1.seq].filter_ind = 0,
       reply->location_list[location_idx].person_list[person_idx].filter_ind = 0
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   FREE SET orgs
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET error_level = 1
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE performrelationshipoverrides(null)
   DECLARE pprcnt = i4 WITH noconstant(0)
   SET error_level = 0
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(encounter_cnt)),
     encntr_prsnl_reltn epr
    PLAN (d1
     WHERE (encntr_list->encntr_list[d1.seq].filter_ind=1))
     JOIN (epr
     WHERE (epr.encntr_id=encntr_list->encntr_list[d1.seq].encntr_id)
      AND (epr.prsnl_person_id=reqinfo->updt_id)
      AND epr.expiration_ind=0
      AND epr.active_ind=1
      AND epr.encntr_prsnl_r_cd > 0
      AND epr.beg_effective_dt_tm < cnvtdatetime(sysdate)
      AND epr.end_effective_dt_tm > cnvtdatetime(sysdate))
    DETAIL
     location_idx = encntr_list->encntr_list[d1.seq].location_idx, person_idx = encntr_list->
     encntr_list[d1.seq].person_idx, encntr_list->encntr_list[d1.seq].filter_ind = 0,
     reply->location_list[location_idx].person_list[person_idx].filter_ind = 0
    WITH nocounter
   ;end select
   FREE SET temp
   RECORD temp(
     1 org_cnt = i4
     1 confid_cnt = i4
     1 orgs[*]
       2 pprcd = f8
     1 confids[*]
       2 pprcd = f8
   )
   SELECT INTO "nl:"
    FROM code_value_extension cve
    PLAN (cve
     WHERE cve.code_set=331
      AND cve.field_name="Override")
    HEAD REPORT
     temp->org_cnt = 0, temp->confid_cnt = 0
    DETAIL
     IF (cve.field_value="1")
      temp->org_cnt += 1, stat = alterlist(temp->orgs,temp->org_cnt), temp->orgs[temp->org_cnt].pprcd
       = cve.code_value
     ELSEIF (cve.field_value="2")
      temp->confid_cnt += 1, stat = alterlist(temp->confids,temp->confid_cnt), temp->confids[temp->
      confid_cnt].pprcd = cve.code_value
     ENDIF
    WITH nocounter
   ;end select
   IF ((temp->org_cnt > 0))
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = value(encounter_cnt)),
      person_prsnl_reltn ppr
     PLAN (d1
      WHERE (encntr_list->encntr_list[d1.seq].filter_ind=1)
       AND (encntr_list->encntr_list[d1.seq].confid_level=0))
      JOIN (ppr
      WHERE (ppr.person_id=encntr_list->encntr_list[d1.seq].person_id)
       AND (ppr.prsnl_person_id=reqinfo->updt_id)
       AND ppr.active_ind=1
       AND ppr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND ppr.end_effective_dt_tm > cnvtdatetime(sysdate)
       AND expand(pprcnt,1,temp->org_cnt,ppr.person_prsnl_r_cd,temp->orgs[pprcnt].pprcd))
     DETAIL
      location_idx = encntr_list->encntr_list[d1.seq].location_idx, person_idx = encntr_list->
      encntr_list[d1.seq].person_idx, encntr_list->encntr_list[d1.seq].filter_ind = 0,
      reply->location_list[location_idx].person_list[person_idx].filter_ind = 0
     WITH nocounter
    ;end select
   ENDIF
   IF ((temp->confid_cnt > 0))
    SET pprcnt = 0
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = value(encounter_cnt)),
      person_prsnl_reltn ppr
     PLAN (d1
      WHERE (encntr_list->encntr_list[d1.seq].filter_ind=1))
      JOIN (ppr
      WHERE (ppr.person_id=encntr_list->encntr_list[d1.seq].person_id)
       AND (ppr.prsnl_person_id=reqinfo->updt_id)
       AND ppr.active_ind=1
       AND expand(pprcnt,1,temp->confid_cnt,ppr.person_prsnl_r_cd,temp->confids[pprcnt].pprcd))
     DETAIL
      location_idx = encntr_list->encntr_list[d1.seq].location_idx, person_idx = encntr_list->
      encntr_list[d1.seq].person_idx, encntr_list->encntr_list[d1.seq].filter_ind = 0,
      reply->location_list[location_idx].person_list[person_idx].filter_ind = 0
     WITH nocounter
    ;end select
   ENDIF
   FREE SET temp
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET error_level = 1
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE filterpatientname(null)
   DECLARE i = i4 WITH private, noconstant(0)
   SET error_level = 0
   SET i18nhandle = 0
   SET y = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
   SET anonymous = uar_i18ngetmessage(i18nhandle,"name_full_formatted","Anonymous")
   FOR (i = 1 TO encounter_cnt)
     IF ((encntr_list->encntr_list[i].filter_ind=1))
      SET location_idx = encntr_list->encntr_list[i].location_idx
      SET person_idx = encntr_list->encntr_list[i].person_idx
      SET reply->location_list[location_idx].person_list[person_idx].name_full_formatted = anonymous
     ENDIF
   ENDFOR
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET error_level = 1
    GO TO exit_script
   ENDIF
 END ;Subroutine
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
 DECLARE error_level = i2 WITH public, noconstant(0)
 DECLARE bed_cd = f8 WITH noconstant(0.0)
 DECLARE room_cd = f8 WITH noconstant(0.0)
 DECLARE nurse_unit_cd = f8 WITH noconstant(0.0)
 DECLARE building_cd = f8 WITH noconstant(0.0)
 DECLARE facility_cd = f8 WITH noconstant(0.0)
 DECLARE census_type_cd = f8 WITH constant(uar_get_code_by("MEANING",339,"CENSUS"))
 DECLARE tsk_inprocess = f8 WITH constant(uar_get_code_by("MEANING",79,"INPROCESS"))
 DECLARE tsk_overdue = f8 WITH constant(uar_get_code_by("MEANING",79,"OVERDUE"))
 DECLARE tsk_pending = f8 WITH constant(uar_get_code_by("MEANING",79,"PENDING"))
 DECLARE tsk_complete = f8 WITH constant(uar_get_code_by("MEANING",79,"COMPLETE"))
 DECLARE prn_cd = f8 WITH constant(uar_get_code_by("MEANING",6025,"PRN"))
 DECLARE cont_cd = f8 WITH constant(uar_get_code_by("MEANING",6025,"CONT"))
 DECLARE workload_cd = f8 WITH constant(uar_get_code_by("MEANING",13019,"WORKLOAD"))
 DECLARE encntr_type_class_cd_preadmit = f8 WITH constant(uar_get_code_by("MEANING",69,"PREADMIT"))
 DECLARE loc_cnt = i4 WITH noconstant(0)
 DECLARE person_cnt = i4 WITH noconstant(0)
 DECLARE temp_loc_idx = i4 WITH noconstant(0)
 DECLARE filterind = i2 WITH noconstant(0)
 DECLARE script_version = vc WITH protect
 DECLARE encntr_idx = i4 WITH noconstant(0)
 DECLARE location_idx = i4 WITH noconstant(0)
 DECLARE person_idx = i4 WITH noconstant(0)
 DECLARE encounter_cnt = i4 WITH noconstant(0)
 DECLARE idx = i4 WITH noconstant(0), protect
 DECLARE batch_size = i4 WITH constant(20), protect
 DECLARE new_list_size = i4 WITH noconstant(0), protect
 DECLARE loop_cnt = i4 WITH noconstant(0), protect
 DECLARE primaryselect(null) = null
 DECLARE getencounterids(null) = null
 DECLARE getacuity(d1) = i2
 SET script_version = "010 26/09/2013"
 SET reply->status_data.status = "F"
 SET loc_cnt = size(request->location_list,5)
 SET stat = alterlist(reply->location_list,loc_cnt)
 IF (loc_cnt > 0)
  CALL examineorgsecurity(null)
  CALL getencounterids(null)
  IF ((request->acuity_event_cd != 0))
   IF (getacuity(0) != true)
    GO TO exit_script
   ENDIF
  ENDIF
  CALL primaryselect(null)
  SET encounter_cnt = size(encntr_list->encntr_list,5)
  IF (encntr_org_sec_ind=1
   AND encounter_cnt > 0)
   CALL performorgsecurity(null)
   CALL performrelationshipoverrides(null)
   CALL filterpatientname(null)
  ENDIF
 ENDIF
#exit_script
 IF (error_level > 0)
  SET reply->status_data.status = "F"
 ELSE
  IF (encounter_cnt > 0)
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ENDIF
 SUBROUTINE getencounterids(null)
   SET encntr_idx = 0
   FOR (x = 1 TO loc_cnt)
     IF ((request->location_list[x].loc_unit_cd=0)
      AND (request->location_list[x].loc_facility_cd=0)
      AND (request->location_list[x].loc_building_cd=0)
      AND (request->location_list[x].person_id > 0)
      AND (request->location_list[x].encntr_id > 0))
      SELECT INTO "nl:"
       FROM encntr_domain e,
        encounter encntr,
        person p
       PLAN (e
        WHERE e.encntr_domain_type_cd=census_type_cd
         AND (e.person_id=request->location_list[x].person_id)
         AND (e.encntr_id=request->location_list[x].encntr_id)
         AND e.end_effective_dt_tm >= cnvtdatetime(request->end_effective_dt_tm)
         AND e.active_ind=1)
        JOIN (encntr
        WHERE encntr.encntr_id=e.encntr_id
         AND encntr.encntr_type_class_cd != encntr_type_class_cd_preadmit)
        JOIN (p
        WHERE p.person_id=e.person_id
         AND p.active_ind=1)
       ORDER BY p.person_id
       HEAD REPORT
        person_cnt = 0
       HEAD p.person_id
        person_cnt += 1
        IF (mod(person_cnt,10)=1)
         stat = alterlist(reply->location_list[x].person_list,(person_cnt+ 9))
        ENDIF
        reply->location_list[x].person_list[person_cnt].encntr_id = e.encntr_id, reply->
        location_list[x].person_list[person_cnt].loc_bed_cd = e.loc_bed_cd, reply->location_list[x].
        person_list[person_cnt].loc_room_cd = e.loc_room_cd,
        reply->location_list[x].person_list[person_cnt].loc_unit_cd = e.loc_nurse_unit_cd, reply->
        location_list[x].person_list[person_cnt].loc_building_cd = e.loc_building_cd, reply->
        location_list[x].person_list[person_cnt].loc_facility_cd = e.loc_facility_cd,
        reply->location_list[x].person_list[person_cnt].person_id = p.person_id, reply->
        location_list[x].person_list[person_cnt].name_full_formatted = p.name_full_formatted, reply->
        location_list[x].person_list[person_cnt].organization_id = encntr.organization_id,
        reply->location_list[x].person_list[person_cnt].confid_level_cd = encntr.confid_level_cd,
        reply->location_list[x].person_list[person_cnt].filter_ind = filterind
        IF (encntr_org_sec_ind=0)
         reply->location_list[x].person_list[person_cnt].filter_ind = 0
        ELSE
         reply->location_list[x].person_list[person_cnt].filter_ind = 1
         IF (confid_ind=1)
          reply->location_list[x].person_list[person_cnt].confid_level = maxval(0,
           uar_get_collation_seq(encntr.confid_level_cd))
         ENDIF
        ENDIF
        encntr_idx += 1
        IF (mod(encntr_idx,10)=1)
         stat = alterlist(encntr_list->encntr_list,(encntr_idx+ 9))
        ENDIF
        encntr_list->encntr_list[encntr_idx].encntr_id = e.encntr_id, encntr_list->encntr_list[
        encntr_idx].person_id = p.person_id, encntr_list->encntr_list[encntr_idx].location_idx = x,
        encntr_list->encntr_list[encntr_idx].person_idx = person_cnt, encntr_list->encntr_list[
        encntr_idx].filter_ind = reply->location_list[x].person_list[person_cnt].filter_ind,
        encntr_list->encntr_list[encntr_idx].organization_id = encntr.organization_id,
        encntr_list->encntr_list[encntr_idx].confid_level = reply->location_list[x].person_list[
        person_cnt].confid_level
       FOOT REPORT
        IF (person_cnt > 0)
         stat = alterlist(reply->location_list[x].person_list,person_cnt)
        ENDIF
        stat = alterlist(encntr_list->encntr_list,encntr_idx)
       WITH nocounter
      ;end select
     ENDIF
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(loc_cnt)),
     encntr_domain e,
     encounter encntr,
     person p
    PLAN (d)
     JOIN (e
     WHERE e.encntr_domain_type_cd=census_type_cd
      AND (e.loc_nurse_unit_cd=request->location_list[d.seq].loc_unit_cd)
      AND e.end_effective_dt_tm >= cnvtdatetime(request->end_effective_dt_tm)
      AND e.active_ind=1
      AND (e.loc_facility_cd=request->location_list[d.seq].loc_facility_cd)
      AND (e.loc_building_cd=request->location_list[d.seq].loc_building_cd)
      AND (((request->location_list[d.seq].loc_room_cd=0)) OR ((e.loc_room_cd=request->location_list[
     d.seq].loc_room_cd)))
      AND (((request->location_list[d.seq].loc_bed_cd=0)) OR ((e.loc_bed_cd=request->location_list[d
     .seq].loc_bed_cd)))
      AND (((request->location_list[d.seq].person_id=0)) OR ((e.person_id=request->location_list[d
     .seq].person_id)))
      AND (((request->location_list[d.seq].encntr_id=0)) OR ((e.encntr_id=request->location_list[d
     .seq].encntr_id))) )
     JOIN (encntr
     WHERE encntr.encntr_id=e.encntr_id
      AND encntr.encntr_type_class_cd != encntr_type_class_cd_preadmit)
     JOIN (p
     WHERE p.person_id=e.person_id
      AND p.active_ind=1)
    ORDER BY d.seq, p.person_id
    HEAD d.seq
     person_cnt = 0
    HEAD p.person_id
     person_cnt += 1
     IF (mod(person_cnt,10)=1)
      stat = alterlist(reply->location_list[d.seq].person_list,(person_cnt+ 9))
     ENDIF
     reply->location_list[d.seq].person_list[person_cnt].encntr_id = e.encntr_id, reply->
     location_list[d.seq].person_list[person_cnt].loc_bed_cd = e.loc_bed_cd, reply->location_list[d
     .seq].person_list[person_cnt].loc_room_cd = e.loc_room_cd,
     reply->location_list[d.seq].person_list[person_cnt].loc_unit_cd = e.loc_nurse_unit_cd, reply->
     location_list[d.seq].person_list[person_cnt].loc_building_cd = e.loc_building_cd, reply->
     location_list[d.seq].person_list[person_cnt].loc_facility_cd = e.loc_facility_cd,
     reply->location_list[d.seq].person_list[person_cnt].person_id = p.person_id, reply->
     location_list[d.seq].person_list[person_cnt].name_full_formatted = p.name_full_formatted, reply
     ->location_list[d.seq].person_list[person_cnt].organization_id = encntr.organization_id,
     reply->location_list[d.seq].person_list[person_cnt].confid_level_cd = encntr.confid_level_cd,
     reply->location_list[d.seq].person_list[person_cnt].filter_ind = filterind
     IF (encntr_org_sec_ind=0)
      reply->location_list[d.seq].person_list[person_cnt].filter_ind = 0
     ELSE
      reply->location_list[d.seq].person_list[person_cnt].filter_ind = 1
      IF (confid_ind=1)
       reply->location_list[d.seq].person_list[person_cnt].confid_level = maxval(0,
        uar_get_collation_seq(encntr.confid_level_cd))
      ENDIF
     ENDIF
     encntr_idx += 1
     IF (mod(encntr_idx,10)=1)
      stat = alterlist(encntr_list->encntr_list,(encntr_idx+ 9))
     ENDIF
     encntr_list->encntr_list[encntr_idx].encntr_id = e.encntr_id, encntr_list->encntr_list[
     encntr_idx].person_id = p.person_id, encntr_list->encntr_list[encntr_idx].location_idx = d.seq,
     encntr_list->encntr_list[encntr_idx].person_idx = person_cnt, encntr_list->encntr_list[
     encntr_idx].filter_ind = reply->location_list[d.seq].person_list[person_cnt].filter_ind,
     encntr_list->encntr_list[encntr_idx].organization_id = encntr.organization_id,
     encntr_list->encntr_list[encntr_idx].confid_level = reply->location_list[d.seq].person_list[
     person_cnt].confid_level
    FOOT  d.seq
     IF (person_cnt > 0)
      stat = alterlist(reply->location_list[d.seq].person_list,person_cnt)
     ENDIF
    FOOT REPORT
     stat = alterlist(encntr_list->encntr_list,encntr_idx)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE getacuity(d1)
   DECLARE applicationid = i4
   DECLARE happ = i4
   DECLARE iret = i4
   DECLARE htask = i4
   DECLARE taskid = i4
   DECLARE hstep = i4
   DECLARE hreq = i4
   DECLARE requestid = i4
   DECLARE hlist = i4
   DECLARE heventlist = i4
   DECLARE hreply = i4
   DECLARE hreplist = i4
   DECLARE henclist = i4
   DECLARE hrblist = i4
   SET applicationid = 4400000
   SET taskid = 4400001
   SET requestid = 1000080
   DECLARE patientcnt = i4 WITH private, noconstant(0)
   DECLARE qualcnt = i4 WITH private, noconstant(0)
   DECLARE i = i4 WITH private, noconstant(0)
   DECLARE j = i4 WITH private, noconstant(0)
   DECLARE k = i4 WITH private, noconstant(0)
   DECLARE l = i4 WITH private, noconstant(0)
   DECLARE temppersonid = f8 WITH private, noconstant(0.0)
   DECLARE tempencntrid = f8 WITH private, noconstant(0.0)
   SET iret = uar_crmbeginapp(applicationid,happ)
   IF (iret != 0)
    SET failed_op = concat("GetAcuity","::","Begin app failed with code:",build(iret))
    SET fail = "T"
    RETURN(false)
   ENDIF
   SET iret = uar_crmbegintask(happ,taskid,htask)
   IF (iret != 0)
    SET failed_op = concat("GetAcuity","::","Begin task failed with code:",build(iret))
    CALL uar_crmendtask(htask)
    SET fail = "T"
    RETURN(false)
   ENDIF
   SET iret = uar_crmbeginreq(htask,"",requestid,hstep)
   IF (iret != 0)
    SET failed_op = concat("GetAcuity","::","Begin request failed with code:",build(iret))
    SET fail = "T"
    RETURN(false)
   ENDIF
   SET hreq = uar_crmgetrequest(hstep)
   SET qualcnt = value(size(reply->location_list,5))
   FOR (i = 1 TO qualcnt)
    SET patientcnt = value(size(reply->location_list[i].person_list,5))
    FOR (j = 1 TO patientcnt)
      SET hlist = uar_srvadditem(hreq,"req_list")
      SET iret = uar_srvsetdouble(hlist,"person_id",reply->location_list[i].person_list[j].person_id)
      SET heventlist = uar_srvadditem(hlist,"event_set_list")
      SET iret = uar_srvsetdouble(heventlist,"event_cd",request->acuity_event_cd)
      SET henclist = uar_srvadditem(hlist,"encntr_list")
      SET iret = uar_srvsetdouble(henclist,"encntr_id",reply->location_list[i].person_list[j].
       encntr_id)
    ENDFOR
   ENDFOR
   SET iret = uar_crmperform(hstep)
   IF (iret != 0)
    SET failed_op = concat("GetAcuity","::","CRM perform failed with code:",build(iret))
    SET fail = "T"
    RETURN(false)
   ENDIF
   SET hreply = uar_crmgetreply(hstep)
   SET cnt = uar_srvgetitemcount(hreply,"rep_list")
   FOR (i = 0 TO (cnt - 1))
     SET hreplist = uar_srvgetitem(hreply,"rep_list",i)
     SET cnt2 = uar_srvgetitemcount(hreplist,"rb_list")
     FOR (j = 0 TO (cnt2 - 1))
       SET hrblist = uar_srvgetitem(hreplist,"rb_list",j)
       SET temppersonid = uar_srvgetdouble(hrblist,"person_id")
       SET tempencntrid = uar_srvgetdouble(hrblist,"encntr_id")
       FOR (k = 1 TO qualcnt)
        SET patientcnt = value(size(reply->location_list[k].person_list,5))
        FOR (l = 1 TO patientcnt)
          IF ((reply->location_list[k].person_list[l].person_id=temppersonid))
           SET reply->location_list[k].person_list[l].acuity_level = cnvtint(uar_srvgetstringptr(
             hrblist,"event_tag"))
          ENDIF
        ENDFOR
       ENDFOR
     ENDFOR
   ENDFOR
   CALL uar_crmendreq(hstep)
   CALL uar_crmendtask(htask)
   CALL uar_crmendapp(happ)
   RETURN(true)
 END ;Subroutine
 SUBROUTINE primaryselect(null)
   SET ierrcode = 0
   DECLARE i = i4 WITH protect, noconstant(0)
   DECLARE start = i4 WITH protect, noconstant(1)
   SET encounter_cnt = size(encntr_list->encntr_list,5)
   IF (encounter_cnt > 0
    AND (request->query_mode=0))
    SET loop_cnt = ceil((cnvtreal(encounter_cnt)/ batch_size))
    SET new_list_size = (loop_cnt * batch_size)
    SET stat = alterlist(encntr_list->encntr_list,new_list_size)
    FOR (idx = (encounter_cnt+ 1) TO new_list_size)
      SET encntr_list->encntr_list[idx].confid_level = encntr_list->encntr_list[encounter_cnt].
      confid_level
      SET encntr_list->encntr_list[idx].encntr_id = encntr_list->encntr_list[encounter_cnt].encntr_id
      SET encntr_list->encntr_list[idx].filter_ind = encntr_list->encntr_list[encounter_cnt].
      filter_ind
      SET encntr_list->encntr_list[idx].location_idx = encntr_list->encntr_list[encounter_cnt].
      location_idx
      SET encntr_list->encntr_list[idx].organization_id = encntr_list->encntr_list[encounter_cnt].
      organization_id
      SET encntr_list->encntr_list[idx].person_id = encntr_list->encntr_list[encounter_cnt].person_id
      SET encntr_list->encntr_list[idx].person_idx = encntr_list->encntr_list[encounter_cnt].
      person_idx
    ENDFOR
    IF ((request->prn_cont_workload_ind=1))
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(encounter_cnt)),
       task_activity ta,
       order_task ot,
       bill_item bi,
       bill_item_modifier bim,
       workload_code wl,
       order_task_position_xref otpx
      PLAN (d)
       JOIN (ta
       WHERE (ta.encntr_id=encntr_list->encntr_list[d.seq].encntr_id)
        AND ((ta.task_status_cd IN (tsk_inprocess, tsk_pending, tsk_overdue)
        AND ta.task_dt_tm >= cnvtdatetime(request->beg_effective_dt_tm)
        AND ta.task_dt_tm < cnvtdatetime(request->end_effective_dt_tm)) OR (ta.task_class_cd IN (
       cont_cd, prn_cd)
        AND ta.task_status_cd IN (tsk_inprocess, tsk_pending)
        AND ta.task_dt_tm < cnvtdatetime(request->end_effective_dt_tm)))
        AND ta.active_ind=1)
       JOIN (ot
       WHERE ot.reference_task_id=ta.reference_task_id
        AND ot.active_ind=1)
       JOIN (bi
       WHERE bi.ext_parent_reference_id=ta.catalog_cd
        AND bi.ext_child_reference_id=ot.reference_task_id
        AND bi.active_ind=1)
       JOIN (bim
       WHERE bim.bill_item_id=bi.bill_item_id
        AND bim.active_ind=1
        AND bim.bill_item_type_cd=workload_cd)
       JOIN (wl
       WHERE (wl.workload_code_id= Outerjoin(bim.key3_id))
        AND (wl.active_ind= Outerjoin(1)) )
       JOIN (otpx
       WHERE (otpx.reference_task_id= Outerjoin(ta.reference_task_id)) )
      ORDER BY ta.encntr_id, ta.task_id, otpx.position_cd
      HEAD REPORT
       encntr_idx = 0
      HEAD ta.encntr_id
       task_cnt = 0, workload = 0, encntr_idx = locateval(idx,1,encounter_cnt,ta.encntr_id,
        encntr_list->encntr_list[idx].encntr_id),
       location_idx = encntr_list->encntr_list[encntr_idx].location_idx, person_idx = encntr_list->
       encntr_list[encntr_idx].person_idx
      HEAD ta.task_id
       position_cnt = 0, task_cnt += 1
       IF (mod(task_cnt,10)=1)
        stat = alterlist(reply->location_list[location_idx].person_list[person_idx].task_list,(
         task_cnt+ 9))
       ENDIF
       reply->location_list[location_idx].person_list[person_idx].task_list[task_cnt].task_id = ta
       .task_id, reply->location_list[location_idx].person_list[person_idx].task_list[task_cnt].
       reference_task_id = ta.reference_task_id, reply->location_list[location_idx].person_list[
       person_idx].task_list[task_cnt].task_status_cd = ta.task_status_cd,
       reply->location_list[location_idx].person_list[person_idx].task_list[task_cnt].order_id = ta
       .order_id, reply->location_list[location_idx].person_list[person_idx].task_list[task_cnt].
       task_dt_tm = ta.task_dt_tm, reply->location_list[location_idx].person_list[person_idx].
       task_list[task_cnt].task_tz = ta.task_tz,
       reply->location_list[location_idx].person_list[person_idx].task_list[task_cnt].task_class_cd
        = ta.task_class_cd, reply->location_list[location_idx].person_list[person_idx].task_list[
       task_cnt].allpositionchart_ind = ot.allpositionchart_ind
       IF ((bim.bim1_int=- (1)))
        reply->location_list[location_idx].person_list[person_idx].task_list[task_cnt].multiplier = 1
       ENDIF
       IF ((bim.bim2_int=- (1)))
        reply->location_list[location_idx].person_list[person_idx].task_list[task_cnt].multiplier =
        wl.multiplier
       ENDIF
       IF (bim.key3_id=0)
        reply->location_list[location_idx].person_list[person_idx].task_list[task_cnt].workload_units
         = bim.bim1_nbr
       ELSE
        reply->location_list[location_idx].person_list[person_idx].task_list[task_cnt].workload_units
         = wl.units
       ENDIF
       workload += reply->location_list[location_idx].person_list[person_idx].task_list[task_cnt].
       workload_units
      DETAIL
       IF (otpx.position_cd > 0
        AND location_idx > 0
        AND person_idx > 0)
        position_cnt += 1
        IF (mod(position_cnt,10)=1)
         stat = alterlist(reply->location_list[location_idx].person_list[person_idx].task_list[
          task_cnt].position_list,(position_cnt+ 9))
        ENDIF
        reply->location_list[location_idx].person_list[person_idx].task_list[task_cnt].position_list[
        position_cnt].position_cd = otpx.position_cd
       ENDIF
      FOOT  ta.task_id
       IF (position_cnt > 0)
        stat = alterlist(reply->location_list[location_idx].person_list[person_idx].task_list[
         task_cnt].position_list,position_cnt)
       ENDIF
      FOOT  ta.encntr_id
       reply->location_list[location_idx].workload_units += workload
       IF (task_cnt > 0)
        stat = alterlist(reply->location_list[location_idx].person_list[person_idx].task_list,
         task_cnt)
       ENDIF
      WITH nocounter
     ;end select
     SET stat = alterlist(encntr_list->encntr_list,encounter_cnt)
    ELSE
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(encounter_cnt)),
       task_activity ta,
       order_task ot,
       bill_item bi,
       bill_item_modifier bim,
       workload_code wl,
       order_task_position_xref otpx
      PLAN (d)
       JOIN (ta
       WHERE (ta.encntr_id=encntr_list->encntr_list[d.seq].encntr_id)
        AND ta.task_status_cd IN (tsk_inprocess, tsk_pending, tsk_overdue)
        AND  NOT (ta.task_class_cd IN (cont_cd, prn_cd))
        AND ta.task_dt_tm >= cnvtdatetime(request->beg_effective_dt_tm)
        AND ta.task_dt_tm < cnvtdatetime(request->end_effective_dt_tm)
        AND ta.active_ind=1)
       JOIN (ot
       WHERE ot.reference_task_id=ta.reference_task_id
        AND ot.active_ind=1)
       JOIN (bi
       WHERE bi.ext_parent_reference_id=ta.catalog_cd
        AND bi.ext_child_reference_id=ot.reference_task_id
        AND bi.active_ind=1)
       JOIN (bim
       WHERE bim.bill_item_id=bi.bill_item_id
        AND bim.active_ind=1
        AND bim.bill_item_type_cd=workload_cd)
       JOIN (wl
       WHERE (wl.workload_code_id= Outerjoin(bim.key3_id))
        AND (wl.active_ind= Outerjoin(1)) )
       JOIN (otpx
       WHERE (otpx.reference_task_id= Outerjoin(ta.reference_task_id)) )
      ORDER BY ta.encntr_id, ta.task_id, otpx.position_cd
      HEAD REPORT
       encntr_idx = 0
      HEAD ta.encntr_id
       task_cnt = 0, workload = 0, encntr_idx = locateval(idx,1,encounter_cnt,ta.encntr_id,
        encntr_list->encntr_list[idx].encntr_id),
       location_idx = encntr_list->encntr_list[encntr_idx].location_idx, person_idx = encntr_list->
       encntr_list[encntr_idx].person_idx
      HEAD ta.task_id
       position_cnt = 0, task_cnt += 1
       IF (mod(task_cnt,10)=1)
        stat = alterlist(reply->location_list[location_idx].person_list[person_idx].task_list,(
         task_cnt+ 9))
       ENDIF
       reply->location_list[location_idx].person_list[person_idx].task_list[task_cnt].task_id = ta
       .task_id, reply->location_list[location_idx].person_list[person_idx].task_list[task_cnt].
       reference_task_id = ta.reference_task_id, reply->location_list[location_idx].person_list[
       person_idx].task_list[task_cnt].task_status_cd = ta.task_status_cd,
       reply->location_list[location_idx].person_list[person_idx].task_list[task_cnt].order_id = ta
       .order_id, reply->location_list[location_idx].person_list[person_idx].task_list[task_cnt].
       task_dt_tm = ta.task_dt_tm, reply->location_list[location_idx].person_list[person_idx].
       task_list[task_cnt].task_tz = ta.task_tz,
       reply->location_list[location_idx].person_list[person_idx].task_list[task_cnt].task_class_cd
        = ta.task_class_cd, reply->location_list[location_idx].person_list[person_idx].task_list[
       task_cnt].allpositionchart_ind = ot.allpositionchart_ind
       IF ((bim.bim1_int=- (1)))
        reply->location_list[location_idx].person_list[person_idx].task_list[task_cnt].multiplier = 1
       ENDIF
       IF ((bim.bim2_int=- (1)))
        reply->location_list[location_idx].person_list[person_idx].task_list[task_cnt].multiplier =
        wl.multiplier
       ENDIF
       IF (bim.key3_id=0)
        reply->location_list[location_idx].person_list[person_idx].task_list[task_cnt].workload_units
         = bim.bim1_nbr
       ELSE
        reply->location_list[location_idx].person_list[person_idx].task_list[task_cnt].workload_units
         = wl.units
       ENDIF
       workload += reply->location_list[location_idx].person_list[person_idx].task_list[task_cnt].
       workload_units
      DETAIL
       IF (otpx.position_cd > 0
        AND location_idx > 0
        AND person_idx > 0)
        position_cnt += 1
        IF (mod(position_cnt,10)=1)
         stat = alterlist(reply->location_list[location_idx].person_list[person_idx].task_list[
          task_cnt].position_list,(position_cnt+ 9))
        ENDIF
        reply->location_list[location_idx].person_list[person_idx].task_list[task_cnt].position_list[
        position_cnt].position_cd = otpx.position_cd
       ENDIF
      FOOT  ta.task_id
       IF (position_cnt > 0)
        stat = alterlist(reply->location_list[location_idx].person_list[person_idx].task_list[
         task_cnt].position_list,position_cnt)
       ENDIF
      FOOT  ta.encntr_id
       reply->location_list[location_idx].workload_units += workload
       IF (task_cnt > 0)
        stat = alterlist(reply->location_list[location_idx].person_list[person_idx].task_list,
         task_cnt)
       ENDIF
      WITH nocounter
     ;end select
     SET stat = alterlist(encntr_list->encntr_list,encounter_cnt)
    ENDIF
   ENDIF
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET error_level = 1
    GO TO exit_script
   ENDIF
 END ;Subroutine
 FREE SET encntr_list
END GO
