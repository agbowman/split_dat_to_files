CREATE PROGRAM dcp_rpt_pregnancy_close_out:dba
 SET modify = predeclare
 FREE RECORD pregnancy
 RECORD pregnancy(
   1 patient[*]
     2 person_lastname = vc
     2 person_firstname = vc
     2 mrn = vc
     2 gest_age = vc
     2 primary_physician = vc
     2 facility = vc
 )
 FREE RECORD request_final_ega
 RECORD request_final_ega(
   1 patient_list[*]
     2 patient_id = f8
     2 encntr_id = f8
   1 pregnancy_list[*]
     2 pregnancy_id = f8
   1 multiple_egas = i2
 )
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE debug_ind = i2 WITH protect, noconstant(0)
 IF (validate(request->debug_ind,0))
  SET debug_ind = request->debug_ind
 ENDIF
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
 IF (validate(i18nuar_def,999)=999)
  CALL echo("Declaring i18nuar_def")
  DECLARE i18nuar_def = i2 WITH persist, noconstant(1)
  DECLARE uar_i18nlocalizationinit(p1=i4,p2=vc,p3=vc,p4=f8) = i4 WITH persist
  DECLARE uar_i18ngetmessage(p1=i4,p2=vc,p3=vc) = vc WITH persist
  DECLARE uar_i18nbuildmessage() = vc WITH persist
 ENDIF
 DECLARE i18nhandle = i4 WITH persistscript
 CALL uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 DECLARE titlecaption = vc WITH protect
 DECLARE reportcaption = vc WITH protect
 DECLARE reportbycaption = vc WITH protect
 DECLARE patientidcaption = vc WITH protect
 DECLARE lastnamecaption = vc WITH protect
 DECLARE firstnamecaption = vc WITH protect
 DECLARE gestagecaption = vc WITH protect
 DECLARE physiciancaption = vc WITH protect
 DECLARE nodatacaption = vc WITH protect
 DECLARE noencountercaption = vc WITH protect
 DECLARE facilitycaption = vc WITH protect
 DECLARE patientcaption = vc WITH protect
 DECLARE timereportcaption = vc WITH protect
 DECLARE endofreportcaption = vc WITH protect
 DECLARE pagecaption = vc WITH protect
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"MRN"))
 DECLARE facility_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",222,"FACILITY"))
 DECLARE ndx_v = i2 WITH protect, noconstant(0)
 DECLARE active_preg_cnt = i4 WITH protect, noconstant(0)
 DECLARE est_delivery_date = dq8 WITH protect
 DECLARE delivery_date = dq8 WITH protect
 DECLARE gest_age_delivery = i4 WITH protect, noconstant(0)
 DECLARE gestageweeks = i4 WITH protect, noconstant(0)
 DECLARE new_cur_gest_age = i4 WITH protect, noconstant(0)
 DECLARE gestage = i4 WITH protect, noconstant(0)
 DECLARE gestagedays = i4 WITH protect, noconstant(0)
 DECLARE ega_calculated = i2 WITH protect, noconstant(0)
 DECLARE print_prsnl_name = vc WITH protect, noconstant("")
 DECLARE irequestsize = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE expand_start = i4 WITH protect, noconstant(1)
 DECLARE expand_size = i4 WITH protect, noconstant(100)
 DECLARE expand_total = i4 WITH protect, noconstant(0)
 DECLARE bstatus = i2 WITH protect, noconstant(0)
 DECLARE serrormsg = vc WITH protect, noconstant("")
 DECLARE ierrorcode = i2 WITH protect, noconstant(0)
 SET titlecaption = uar_i18ngetmessage(i18nhandle,"cap1",
  "All Open Pregnancies Greater Than or Equal To 44 Weeks Gestation")
 SET reportcaption = uar_i18ngetmessage(i18nhandle,"cap2","Report as of:")
 SET patientidcaption = uar_i18ngetmessage(i18nhandle,"cap3","Patient MRN / ID")
 SET lastnamecaption = uar_i18ngetmessage(i18nhandle,"cap4","Last Name")
 SET firstnamecaption = uar_i18ngetmessage(i18nhandle,"cap5","First Name")
 SET gestagecaption = uar_i18ngetmessage(i18nhandle,"cap6","Gestational Age at")
 SET physiciancaption = uar_i18ngetmessage(i18nhandle,"cap7","Responsible Provider")
 SET nodatacaption = uar_i18ngetmessage(i18nhandle,"cap8","No qualifying data available")
 SET facilitycaption = uar_i18ngetmessage(i18nhandle,"cap9","Facility Name")
 SET reportbycaption = uar_i18ngetmessage(i18nhandle,"cap10","Report run by:")
 SET patientcaption = uar_i18ngetmessage(i18nhandle,"cap11","Patient")
 SET timereportcaption = uar_i18ngetmessage(i18nhandle,"cap12","Time of Report")
 SET endofreportcaption = uar_i18ngetmessage(i18nhandle,"cap13","***End of Report***")
 SET pagecaption = uar_i18ngetmessage(i18nhandle,"cap14","Page")
 SELECT INTO "nl:"
  FROM prsnl p
  PLAN (p
   WHERE (p.person_id=reqinfo->updt_id))
  DETAIL
   print_prsnl_name = substring(1,40,p.name_full_formatted)
  WITH nocounter
 ;end select
 IF (debug_ind >= 1)
  CALL echo(build("PRSNL_ID: ",reqinfo->updt_id))
  CALL echo(build("PRSNL_NAME: ",print_prsnl_name))
 ENDIF
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
 IF (debug_ind >= 1
  AND preg_org_sec_ind=1)
  CALL echorecord(preg_sec_orgs)
 ENDIF
 SELECT
  IF (preg_org_sec_ind=1)
   FROM pregnancy_instance pi,
    (dummyt d1  WITH seq = size(preg_sec_orgs->qual,5))
   PLAN (pi
    WHERE pi.active_ind=1
     AND pi.preg_end_dt_tm >= cnvtdatetime("31-DEC-2100"))
    JOIN (d1
    WHERE (pi.organization_id=preg_sec_orgs->qual[d1.seq].org_id))
  ELSE
   FROM pregnancy_instance pi
   PLAN (pi
    WHERE pi.active_ind=1
     AND pi.preg_end_dt_tm >= cnvtdatetime("31-DEC-2100"))
  ENDIF
  INTO "nl:"
  HEAD REPORT
   active_preg_cnt = 0
  HEAD pi.pregnancy_id
   active_preg_cnt += 1
   IF (active_preg_cnt > size(request_final_ega->pregnancy_list,5))
    bstatus = alterlist(request_final_ega->pregnancy_list,(active_preg_cnt+ 9))
   ENDIF
   request_final_ega->pregnancy_list[active_preg_cnt].pregnancy_id = pi.pregnancy_id
  FOOT REPORT
   bstatus = alterlist(request_final_ega->pregnancy_list,active_preg_cnt)
  WITH nocounter
 ;end select
 IF (debug_ind >= 2)
  CALL echorecord(request_final_ega)
 ENDIF
 SET modify = nopredeclare
 EXECUTE dcp_get_final_ega  WITH replace("REQUEST",request_final_ega), replace("REPLY",
  reply_final_ega)
 SET modify = predeclare
 IF (debug_ind >= 2)
  CALL echorecord(reply_final_ega)
 ENDIF
 IF ((reply_final_ega->status_data.status="F"))
  SET reply->status_data.status = "F"
  SET reply->subeventstatus[1].operationname = "Execute"
  SET reply->subeventstatus[1].operationstatus = "F"
  SET reply->subeventstatus[1].targetobjectname = "dcp_get_final_ega"
  SET reply->subeventstatus[1].targetobjectvalue = "fail status returned from dcp_get_final_ega"
  GO TO exit_report
 ELSEIF (size(reply_final_ega->gestation_info,5)=0)
  GO TO no_encntr
 ENDIF
 SET irequestsize = size(reply_final_ega->gestation_info,5)
 SET expand_total = (ceil((cnvtreal(irequestsize)/ expand_size)) * expand_size)
 SET bstatus = alterlist(reply_final_ega->gestation_info,expand_total)
 SELECT INTO "nl:"
  facility = uar_get_code_display(loc.location_cd)
  FROM pregnancy_estimate pe,
   pregnancy_instance pi,
   person p,
   location loc,
   person_alias pa,
   pregnancy_action pra,
   person p2,
   dummyt d2,
   (dummyt d  WITH seq = value((1+ ((expand_total - 1)/ expand_size))))
  PLAN (d
   WHERE initarray(expand_start,evaluate(d.seq,1,1,(expand_start+ expand_size))))
   JOIN (pe
   WHERE expand(idx,expand_start,(expand_start+ (expand_size - 1)),pe.pregnancy_id,reply_final_ega->
    gestation_info[idx].pregnancy_id)
    AND pe.active_ind=1)
   JOIN (pi
   WHERE pi.pregnancy_id=pe.pregnancy_id
    AND pi.active_ind=1
    AND pi.preg_end_dt_tm >= cnvtdatetime(curdate,curtime))
   JOIN (p
   WHERE pi.person_id=p.person_id
    AND p.active_ind=1)
   JOIN (pa
   WHERE p.person_id=pa.person_id
    AND pa.person_alias_type_cd IN (mrn_cd)
    AND pa.active_ind=1)
   JOIN (pra
   WHERE pi.pregnancy_id=pra.pregnancy_id)
   JOIN (p2
   WHERE pra.prsnl_id=p2.person_id)
   JOIN (d2)
   JOIN (loc
   WHERE loc.organization_id=pi.organization_id
    AND loc.organization_id > 0
    AND loc.location_type_cd IN (facility_cd)
    AND loc.active_ind=1)
  ORDER BY facility, p2.name_last_key, p2.name_first_key,
   p.name_last_key, p.name_first_key, pa.alias,
   pe.status_flag DESC, pra.updt_dt_tm DESC
  HEAD REPORT
   cnt = 0
  HEAD pi.pregnancy_id
   pregidx = locateval(idx,1,irequestsize,pi.pregnancy_id,reply_final_ega->gestation_info[idx].
    pregnancy_id), delivery_date = reply_final_ega->gestation_info[pregidx].delivery_date,
   gest_age_delivery = reply_final_ega->gestation_info[pregidx].gest_age_at_delivery,
   est_delivery_date = reply_final_ega->gestation_info[pregidx].est_delivery_date, new_cur_gest_age
    = reply_final_ega->gestation_info[pregidx].current_gest_age, ega_calculated = 0
   IF (debug_ind >= 4)
    CALL echo(build("pi.pregnancy_id=",pi.pregnancy_id)),
    CALL echo(build("pregIdx=",pregidx))
   ENDIF
   IF (new_cur_gest_age=0
    AND delivery_date != 0)
    new_cur_gest_age = (gest_age_delivery+ datetimediff(cnvtdatetime(sysdate),delivery_date))
   ELSEIF (new_cur_gest_age=0
    AND est_delivery_date != 0)
    new_cur_gest_age = ((40 * 7)+ datetimediff(cnvtdatetime(sysdate),est_delivery_date)),
    ega_calculated = 1
   ENDIF
   IF (debug_ind >= 4)
    CALL echo(build("new_cur_gest_age=",new_cur_gest_age)),
    CALL echo(build("ega_calculated=",ega_calculated))
   ENDIF
   IF (new_cur_gest_age >= 308)
    cnt += 1
    IF (mod(cnt,10)=1)
     bstatus = alterlist(pregnancy->patient,(10+ cnt))
    ENDIF
    pregnancy->patient[cnt].mrn = trim(pa.alias), pregnancy->patient[cnt].person_lastname = substring
    (1,18,trim(p.name_last)), pregnancy->patient[cnt].person_firstname = substring(1,18,trim(p
      .name_first)),
    pregnancy->patient[cnt].facility = substring(1,18,trim(facility)), pregnancy->patient[cnt].
    primary_physician = substring(1,24,trim(p2.name_full_formatted)), gestage = new_cur_gest_age,
    gestageweeks = (gestage/ 7), gestagedays = mod(gestage,7)
    IF (gestagedays > 0)
     pregnancy->patient[cnt].gest_age = concat(trim(cnvtstring(gestageweeks))," ",trim(cnvtstring(
        gestagedays)),"/7")
    ELSE
     pregnancy->patient[cnt].gest_age = build(gestageweeks)
    ENDIF
    IF (ega_calculated=1)
     pregnancy->patient[cnt].gest_age = concat(pregnancy->patient[cnt].gest_age,"*")
    ENDIF
   ENDIF
  FOOT REPORT
   bstatus = alterlist(pregnancy->patient,cnt)
  WITH nocounter, outerjoin = d2
 ;end select
 IF (debug_ind >= 1)
  CALL echorecord(pregnancy)
 ENDIF
 SET ierrorcode = error(serrormsg,1)
 IF (ierrorcode != 0)
  CALL echo("*********************************")
  CALL echo(build("ERROR MESSAGE : ",serrormsg))
  CALL echo("*********************************")
  SET reply->status_data.status = "F"
  SET reply->subeventstatus[1].operationname = "Execute"
  SET reply->subeventstatus[1].operationstatus = "F"
  SET reply->subeventstatus[1].targetobjectname = "DCP_RPT_PREGNANCY_CLOSE_OUT"
  SET reply->subeventstatus[1].targetobjectvalue = "Failure while retrieving pregnancy details"
  GO TO exit_report
 ELSEIF (size(pregnancy->patient,5)=0)
  IF (debug_ind >= 1)
   CALL echo("Printing report - no data ")
  ENDIF
  GO TO no_encntr
 ELSE
  IF (debug_ind >= 1)
   CALL echo(build("Printing report - pregnancy count: ",size(pregnancy->patient,5)))
  ENDIF
  GO TO print_report
 ENDIF
#no_encntr
 SELECT INTO request->output_device
  d.seq
  FROM (dummyt d  WITH seq = 1)
  PLAN (d)
  ORDER BY d.seq
  HEAD REPORT
   half_line = 6, 1_line = 12, 3_line = 36,
   x_pos = 0, y_pos = 0, x_offset = 0,
   y_offset = 0, c_pos = 175, a_pos = 30,
   m_pos = 130, n_pos = 230, o_pos = 330,
   p_pos = 340, q_pos = 450, r_pos = 360,
   j_pos = 580, page_pos = 330, endreport_pos = 305,
   header_top_pos = 18, line = fillstring(200,"-"),
   MACRO (print_line)
    x_pos = a_pos, y_pos += half_line,
    CALL print(calcpos(x_pos,y_pos)),
    line, row + 1
   ENDMACRO
   ,
   "{PS/792 0 translate 90 rotate/}"
  HEAD PAGE
   "{f/8}{cpi/8}", x_pos = c_pos, y_pos = header_top_pos,
   CALL print(calcpos(x_pos,y_pos)), "{b}", titlecaption,
   row + 1, "{f/8}{cpi/12}", x_pos = a_pos,
   y_pos += 3_line,
   CALL print(calcpos(x_pos,y_pos)), "{b}",
   reportbycaption, "{endb} ", " ",
   print_prsnl_name, x_pos = a_pos, y_pos += 1_line,
   CALL print(calcpos(x_pos,y_pos)), "{b}", reportcaption,
   "{endb} ", curdate, "  ",
   curtime, row + 1, x_pos = m_pos,
   y_pos += 3_line,
   CALL print(calcpos(x_pos,y_pos)), "{b}",
   patientcaption, x_pos = n_pos,
   CALL print(calcpos(x_pos,y_pos)),
   "{b}", patientcaption, x_pos = o_pos,
   CALL print(calcpos(x_pos,y_pos)), "{b}", gestagecaption,
   row + 1, y_pos += 1_line, x_pos = a_pos,
   CALL print(calcpos(x_pos,y_pos)), "{b}", patientidcaption,
   row + 1, x_pos = m_pos,
   CALL print(calcpos(x_pos,y_pos)),
   "{b}", lastnamecaption, row + 1,
   x_pos = n_pos,
   CALL print(calcpos(x_pos,y_pos)), "{b}",
   firstnamecaption, row + 1, x_pos = p_pos,
   CALL print(calcpos(x_pos,y_pos)), "{b}", timereportcaption,
   row + 1, x_pos = q_pos,
   CALL print(calcpos(x_pos,y_pos)),
   "{b}", physiciancaption, row + 1,
   x_pos = j_pos,
   CALL print(calcpos(x_pos,y_pos)), "{b}",
   facilitycaption, row + 1, print_line,
   y_pos += 3_line, x_pos = a_pos,
   CALL print(calcpos(x_pos,y_pos)),
   "{endb} ", nodatacaption, x_pos = endreport_pos,
   y_pos += 3_line,
   CALL print(calcpos(x_pos,y_pos)), "{b}",
   endofreportcaption, "{endb}"
  WITH nocounter, nullreport, dio = postscript,
   maxcol = 500, maxrow = 500
 ;end select
 SET ierrorcode = error(serrormsg,1)
 IF (ierrorcode != 0)
  CALL echo("*********************************")
  CALL echo(build("ERROR MESSAGE : ",serrormsg))
  CALL echo("*********************************")
  SET reply->status_data.status = "F"
  SET reply->subeventstatus[1].operationname = "Execute"
  SET reply->subeventstatus[1].operationstatus = "F"
  SET reply->subeventstatus[1].targetobjectname = "DCP_RPT_PREGNANCY_CLOSE_OUT"
  SET reply->subeventstatus[1].targetobjectvalue = "Failure while printing NO DATA."
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 GO TO exit_report
#print_report
 SELECT INTO request->output_device
  d.seq
  FROM (dummyt d  WITH seq = 1)
  PLAN (d)
  ORDER BY d.seq
  HEAD REPORT
   half_line = 6, 1_line = 12, 3_line = 36,
   x_pos = 0, y_pos = 0, x_offset = 0,
   y_offset = 0, c_pos = 175, a_pos = 30,
   m_pos = 130, n_pos = 230, o_pos = 330,
   p_pos = 340, q_pos = 450, r_pos = 360,
   j_pos = 580, page_pos = 330, endreport_pos = 305,
   header_top_pos = 18, line = fillstring(200,"-"),
   MACRO (print_line)
    x_pos = a_pos, y_pos += half_line,
    CALL print(calcpos(x_pos,y_pos)),
    line, row + 1
   ENDMACRO
   ,
   current_row_knt = 0,
   MACRO (add_row_check)
    current_row_knt += 1
    IF (y_pos > 530)
     BREAK, y_pos += 1_line, x_pos = a_pos
    ENDIF
   ENDMACRO
   , "{PS/792 0 translate 90 rotate/}"
  HEAD PAGE
   IF (curpage > 1)
    "{PS/792 0 translate 90 rotate/}", row + 1
   ENDIF
   "{f/8}{cpi/8}", x_pos = c_pos, y_pos = header_top_pos,
   CALL print(calcpos(x_pos,y_pos)), "{b}", titlecaption,
   row + 1, "{f/8}{cpi/12}", x_pos = a_pos,
   y_pos += 3_line,
   CALL print(calcpos(x_pos,y_pos)), "{b}",
   reportbycaption, "{endb} ", " ",
   print_prsnl_name, x_pos = a_pos, y_pos += 1_line,
   CALL print(calcpos(x_pos,y_pos)), "{b}", reportcaption,
   "{endb} ", curdate, "  ",
   curtime, row + 1, x_pos = m_pos,
   y_pos += 3_line,
   CALL print(calcpos(x_pos,y_pos)), "{b}",
   patientcaption, x_pos = n_pos,
   CALL print(calcpos(x_pos,y_pos)),
   "{b}", patientcaption, x_pos = o_pos,
   CALL print(calcpos(x_pos,y_pos)), "{b}", gestagecaption,
   row + 1, y_pos += 1_line, x_pos = a_pos,
   CALL print(calcpos(x_pos,y_pos)), "{b}", patientidcaption,
   row + 1, x_pos = m_pos,
   CALL print(calcpos(x_pos,y_pos)),
   "{b}", lastnamecaption, row + 1,
   x_pos = n_pos,
   CALL print(calcpos(x_pos,y_pos)), "{b}",
   firstnamecaption, row + 1, x_pos = p_pos,
   CALL print(calcpos(x_pos,y_pos)), "{b}", timereportcaption,
   row + 1, x_pos = q_pos,
   CALL print(calcpos(x_pos,y_pos)),
   "{b}", physiciancaption, row + 1,
   x_pos = j_pos,
   CALL print(calcpos(x_pos,y_pos)), "{b}",
   facilitycaption, row + 1, print_line
  DETAIL
   y_pos += 1_line
   FOR (m = 1 TO cnt)
     x_pos = a_pos,
     CALL print(calcpos(x_pos,y_pos)), pregnancy->patient[m].mrn,
     x_pos = m_pos,
     CALL print(calcpos(x_pos,y_pos)), pregnancy->patient[m].person_lastname,
     x_pos = n_pos,
     CALL print(calcpos(x_pos,y_pos)), pregnancy->patient[m].person_firstname,
     x_pos = r_pos,
     CALL print(calcpos(x_pos,y_pos)), pregnancy->patient[m].gest_age,
     x_pos = q_pos,
     CALL print(calcpos(x_pos,y_pos)), pregnancy->patient[m].primary_physician,
     x_pos = j_pos,
     CALL print(calcpos(x_pos,y_pos)), pregnancy->patient[m].facility,
     row + 1, y_pos += 1_line, add_row_check
   ENDFOR
  FOOT PAGE
   x_pos = page_pos, y_pos += 1_line,
   CALL print(calcpos(x_pos,y_pos)),
   "{b}", pagecaption, curpage"##;;I"
  FOOT REPORT
   x_pos = endreport_pos, y_pos += 3_line,
   CALL print(calcpos(x_pos,y_pos)),
   "{b}", endofreportcaption, "{endb}"
  WITH nocounter, nullreport, dio = postscript,
   maxcol = 500, maxrow = 1500
 ;end select
 SET ierrorcode = error(serrormsg,1)
 IF (ierrorcode != 0)
  CALL echo("*********************************")
  CALL echo(build("ERROR MESSAGE : ",serrormsg))
  CALL echo("*********************************")
  SET reply->status_data.status = "F"
  SET reply->subeventstatus[1].operationname = "Execute"
  SET reply->subeventstatus[1].operationstatus = "F"
  SET reply->subeventstatus[1].targetobjectname = "DCP_RPT_PREGNANCY_CLOSE_OUT"
  SET reply->subeventstatus[1].targetobjectvalue = "Failure while printing report."
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_report
 FREE RECORD pregnancy
 FREE RECORD request_final_ega
 FREE RECORD reply_final_ega
 SET modify = nopredeclare
 SET script_version = "001 12/14/2009 MS012548"
END GO
