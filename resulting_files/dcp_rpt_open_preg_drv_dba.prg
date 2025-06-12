CREATE PROGRAM dcp_rpt_open_preg_drv:dba
 CALL echo("Enter dcp_rpt_open_preg_drv")
 SET modify = predeclare
 DECLARE testvar1 = vc WITH persistscript
 DECLARE testvar2 = vc WITH persistscript
 DECLARE testvar3 = vc WITH persistscript
 DECLARE debug_person_1 = f8 WITH persistscript
 DECLARE debug_person_2 = f8 WITH persistscript
 DECLARE org_idx = i4 WITH protect, noconstant(0)
 DECLARE prompt11 = i4 WITH protect, noconstant(0)
 DECLARE prompt8 = i4 WITH protect, noconstant(0)
 SET prompt11 = parameter(11,1)
 SET prompt8 = parameter(8,1)
 IF ( NOT (validate(pregnancy,0)))
  FREE RECORD pregnancy
  RECORD pregnancy(
    1 patient[*]
      2 person_lastname = vc
      2 person_firstname = vc
      2 mrn = vc
      2 gest_age = vc
      2 primary_physician = vc
      2 facility = vc
      2 edd = vc
    1 patient_cnt = i4
  )
 ENDIF
 FREE RECORD temp
 RECORD temp(
   1 patient[*]
     2 person_lastname = vc
     2 person_firstname = vc
     2 mrn = vc
     2 gest_age = vc
     2 gest_age_delivery = vc
     2 primary_physician = vc
     2 facility = vc
     2 edd = vc
     2 person_id = f8
     2 pregnancy_id = f8
     2 ega = i4
     2 print_ind = i4
     2 r_est_delivery_date = dq8
     2 r_delivery_date = dq8
     2 r_gest_age_delivery = i4
     2 r_current_gest_age = i4
     2 org_display = vc
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
 FREE RECORD org
 RECORD org(
   1 rec[*]
     2 organization_id = f8
     2 display = vc
   1 count = i4
   1 display = vc
 )
 FREE RECORD attending
 RECORD attending(
   1 rec[*]
     2 person_id = f8
     2 display = vc
   1 count = i4
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
 SET debug_ind = 0
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
 DECLARE titlecaption = vc WITH persistscript
 DECLARE titlecaption_cont = vc WITH persistscript
 DECLARE reportcaption = vc WITH persistscript
 DECLARE reportbycaption = vc WITH persistscript
 DECLARE patientidcaption = vc WITH persistscript
 DECLARE lastnamecaption = vc WITH persistscript
 DECLARE firstnamecaption = vc WITH persistscript
 DECLARE gestagecaption = vc WITH persistscript
 DECLARE eddcaption = vc WITH persistscript
 DECLARE physiciancaption = vc WITH persistscript
 DECLARE nodatacaption = vc WITH persistscript
 DECLARE noencountercaption = vc WITH persistscript
 DECLARE facilitycaption = vc WITH persistscript
 DECLARE patientcaption = vc WITH persistscript
 DECLARE timereportcaption = vc WITH persistscript
 DECLARE endofreportcaption = vc WITH persistscript
 DECLARE orgcaption = vc WITH persistscript
 DECLARE orgscaption = vc WITH persistscript
 DECLARE allorgcaption = vc WITH persistscript
 DECLARE rangecaptionedd = vc WITH persistscript
 DECLARE rangecaptionega = vc WITH persistscript
 DECLARE greaterthancaption = vc WITH persistscript
 DECLARE lessthancaption = vc WITH persistscript
 DECLARE equaltocaption = vc WITH persistscript
 DECLARE betweencaption = vc WITH persistscript
 DECLARE weekscaption = vc WITH persistscript
 DECLARE filtercaptionp = vc WITH persistscript
 DECLARE filtercaptiong = vc WITH persistscript
 DECLARE filtercaptiona = vc WITH persistscript
 DECLARE filtercaption = vc WITH persistscript
 DECLARE filterbycaption = vc WITH persistscript
 DECLARE pagecaption = vc WITH protect
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"MRN"))
 DECLARE facility_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",222,"FACILITY"))
 DECLARE provider_group_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!111133"))
 DECLARE ndx_v = i2 WITH protect, noconstant(0)
 DECLARE active_preg_cnt = i4 WITH protect, noconstant(0)
 DECLARE est_delivery_date = dq8 WITH protect
 DECLARE delivery_date = dq8 WITH protect
 DECLARE org_display = vc WITH protect, noconstant("")
 DECLARE gest_age_delivery = i4 WITH protect, noconstant(0)
 DECLARE gestageweeks = i4 WITH protect, noconstant(0)
 DECLARE new_cur_gest_age = i4 WITH protect, noconstant(0)
 DECLARE gestage = i4 WITH protect, noconstant(0)
 DECLARE gestagedays = i4 WITH protect, noconstant(0)
 DECLARE ega_calculated = i2 WITH protect, noconstant(0)
 DECLARE print_prsnl_name = vc WITH persistscript, noconstant("")
 DECLARE irequestsize = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE expand_start = i4 WITH protect, noconstant(1)
 DECLARE expand_size = i4 WITH protect, noconstant(100)
 DECLARE expand_total = i4 WITH protect, noconstant(0)
 DECLARE bstatus = i2 WITH protect, noconstant(0)
 DECLARE cstatus = i2 WITH protect, noconstant(0)
 DECLARE serrormsg = vc WITH protect, noconstant("")
 DECLARE ierrorcode = i2 WITH protect, noconstant(0)
 DECLARE s_org = vc WITH persistscript
 DECLARE org_caption = vc WITH persistscript
 DECLARE rangecaption = vc WITH persistscript
 DECLARE dt_or_age_range = vc WITH persistscript
 DECLARE rpt_time_display = vc WITH persistscript
 DECLARE num_days_int_s = i4 WITH protect, noconstant(0)
 DECLARE num_days_int_e = i4 WITH protect, noconstant(0)
 DECLARE org_int = i4 WITH protect, noconstant(0)
 DECLARE per_int = i4 WITH protect, noconstant(0)
 DECLARE istat = i4 WITH protect, noconstant(0)
 DECLARE s_condition_parser = vc WITH persistscript, noconstant(" ")
 DECLARE valid_pi_org_id_ind = i4 WITH protect, constant(checkdic(
   "PREGNANCY_INSTANCE.ORGANIZATION_ID","A",0))
 DECLARE all_orgs_flag = i4 WITH protect, noconstant(0)
 SET titlecaption = uar_i18ngetmessage(i18nhandle,"cap1","Open Pregnancies by EGA/EDD")
 SET titlecaption_cont = uar_i18ngetmessage(i18nhandle,"cap1.5",
  "Estimated Gestational Age Report (continued)")
 SET reportcaption = uar_i18ngetmessage(i18nhandle,"cap2","Report as of:")
 SET patientidcaption = uar_i18ngetmessage(i18nhandle,"cap3","Patient MRN / ID")
 SET lastnamecaption = uar_i18ngetmessage(i18nhandle,"cap4","Last Name")
 SET firstnamecaption = uar_i18ngetmessage(i18nhandle,"cap5","First Name")
 SET gestagecaption = uar_i18ngetmessage(i18nhandle,"cap6","Gestational Age")
 SET physiciancaption = uar_i18ngetmessage(i18nhandle,"cap7","Pregnancy Added By")
 SET nodatacaption = uar_i18ngetmessage(i18nhandle,"cap8","No qualifying data available")
 SET facilitycaption = uar_i18ngetmessage(i18nhandle,"cap9","Facility Name")
 SET reportbycaption = uar_i18ngetmessage(i18nhandle,"cap10","Report run by:   ")
 SET patientcaption = uar_i18ngetmessage(i18nhandle,"cap11","Patient")
 SET timereportcaption = uar_i18ngetmessage(i18nhandle,"cap12","Time of Report:   ")
 SET endofreportcaption = uar_i18ngetmessage(i18nhandle,"cap13","*** End of Report ***")
 SET pagecaption = uar_i18ngetmessage(i18nhandle,"cap14","Page")
 SET eddcaption = uar_i18ngetmessage(i18nhandle,"cap15","EDD")
 SET orgcaption = uar_i18ngetmessage(i18nhandle,"cap16","Organization: ")
 SET orgscaption = uar_i18ngetmessage(i18nhandle,"cap17","Organizations: ")
 SET rangecaptionega = uar_i18ngetmessage(i18nhandle,"cap18","Estimated Gestational Age Range:   ")
 SET rangecaptionedd = uar_i18ngetmessage(i18nhandle,"cap19","Estimated Delivery Date Range:   ")
 SET greaterthancaption = uar_i18ngetmessage(i18nhandle,"cap20","Greater than")
 SET lessthancaption = uar_i18ngetmessage(i18nhandle,"cap21","Less than")
 SET equaltocaption = uar_i18ngetmessage(i18nhandle,"cap22","Equal to")
 SET betweencaption = uar_i18ngetmessage(i18nhandle,"cap23","Range")
 SET allorgcaption = uar_i18ngetmessage(i18nhandle,"cap24","All Organizations")
 SET weekscaption = uar_i18ngetmessage(i18nhandle,"cap25","weeks")
 SET filtercaptionp = uar_i18ngetmessage(i18nhandle,"cap26","Physician")
 SET filtercaptiong = uar_i18ngetmessage(i18nhandle,"cap27","Physician group")
 SET filtercaptiona = uar_i18ngetmessage(i18nhandle,"cap28","All physicians")
 SET filterbycaption = uar_i18ngetmessage(i18nhandle,"cap29","Filtered by:")
 SELECT INTO "nl:"
  FROM organization o
  PLAN (o
   WHERE o.organization_id IN ( $8)
    AND o.organization_id != 0)
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(org->rec,cnt), org->rec[cnt].organization_id = o.organization_id,
   org->rec[cnt].display = o.org_name
   IF (cnt > 1)
    org->display = concat(org->display,"; ",trim(o.org_name))
   ELSE
    org->display = trim(o.org_name)
   ENDIF
  FOOT REPORT
   org->count = cnt
  WITH nocounter
 ;end select
 IF (size(org->rec,5)=0)
  SET all_orgs_flag = 1
 ENDIF
 IF (cnvtint( $2)=1)
  SET num_days_int_s = (cnvtint( $4) * 7)
  SET num_days_int_e = (cnvtint( $5) * 7)
  SET rangecaption = rangecaptionega
 ENDIF
 IF (cnvtint( $2)=2)
  SET rangecaption = rangecaptionedd
  SET dt_or_age_range = concat(trim( $6)," - ",trim( $7))
 ELSEIF (cnvtint( $3)=1)
  SET s_condition_parser = "new_cur_gest_age = value(num_days_int_s)"
  SET dt_or_age_range = concat(equaltocaption," ",trim( $4)," ",weekscaption)
 ELSEIF (cnvtint( $3)=2)
  SET s_condition_parser = "new_cur_gest_age > value(num_days_int_s)"
  SET dt_or_age_range = concat(greaterthancaption," ",trim( $4)," ",weekscaption)
 ELSEIF (cnvtint( $3)=3)
  SET s_condition_parser = "new_cur_gest_age < value(num_days_int_s)"
  SET dt_or_age_range = concat(lessthancaption," ",trim( $4)," ",weekscaption)
 ELSEIF (cnvtint( $3)=4)
  SET s_condition_parser = "new_cur_gest_age between value(num_days_int_s) and value(num_days_int_e)"
  SET dt_or_age_range = concat(betweencaption," ",trim( $4)," - ",trim( $5),
   " ",weekscaption)
 ENDIF
 IF (cnvtint( $9)=1)
  IF (prompt11=0)
   SET filtercaption = filtercaptiona
  ELSE
   SELECT INTO "nl:"
    FROM prsnl pr
    PLAN (pr
     WHERE pr.person_id IN ( $11)
      AND pr.person_id != 0)
    HEAD REPORT
     p_cnt = 0
    DETAIL
     p_cnt = (p_cnt+ 1)
     IF (p_cnt > size(attending->rec,5))
      stat = alterlist(attending->rec,(p_cnt+ 9))
     ENDIF
     attending->rec[p_cnt].person_id = pr.person_id, attending->rec[p_cnt].display = pr.name_last
    FOOT REPORT
     attending->count = p_cnt, stat = alterlist(attending->rec,p_cnt)
    WITH nocounter
   ;end select
   SET filtercaption = filtercaptionp
  ENDIF
 ELSEIF (cnvtint( $9)=2)
  SET filtercaption = filtercaptiong
  IF (isnumeric(parameter(11,1)) > 0)
   SELECT INTO "nl:"
    FROM prsnl_group_reltn pgr,
     prsnl pr
    PLAN (pgr
     WHERE pgr.prsnl_group_id IN ( $11))
     JOIN (pr
     WHERE pr.person_id=pgr.person_id
      AND pr.active_ind=1)
    ORDER BY pr.person_id
    HEAD REPORT
     p_cnt = 0
    HEAD pr.person_id
     p_cnt = (p_cnt+ 1)
     IF (p_cnt > size(attending->rec,5))
      stat = alterlist(attending->rec,(p_cnt+ 9))
     ENDIF
     attending->rec[p_cnt].person_id = pr.person_id, attending->rec[p_cnt].display = pr.name_last
    FOOT REPORT
     attending->count = p_cnt, stat = alterlist(attending->rec,p_cnt)
    WITH nocounter
   ;end select
  ELSE
   SELECT INTO "nl:"
    FROM prsnl_group pg,
     prsnl_group_reltn pgr,
     prsnl pr
    PLAN (pg
     WHERE pg.prsnl_group_class_cd=provider_group_cd
      AND pg.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      AND pg.active_ind=1)
     JOIN (pgr
     WHERE pgr.prsnl_group_id=pg.prsnl_group_id
      AND pgr.prsnl_group_id != 0)
     JOIN (pr
     WHERE pr.person_id=pgr.person_id
      AND pr.active_ind=1)
    ORDER BY pr.person_id
    HEAD REPORT
     p_cnt = 0
    HEAD pr.person_id
     p_cnt = (p_cnt+ 1)
     IF (p_cnt > size(attending->rec,5))
      stat = alterlist(attending->rec,(p_cnt+ 9))
     ENDIF
     attending->rec[p_cnt].person_id = pr.person_id, attending->rec[p_cnt].display = pr.name_last
    FOOT REPORT
     attending->count = p_cnt, stat = alterlist(attending->rec,p_cnt)
    WITH nocounter
   ;end select
  ENDIF
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
 SET rpt_time_display = format(cnvtdatetime(curdate,curtime3),"@SHORTDATETIME")
 IF (all_orgs_flag=1)
  SELECT
   IF (preg_org_sec_ind=1
    AND valid_pi_org_id_ind > 0)
    FROM pregnancy_instance pi,
     encounter e,
     organization o,
     problem pr,
     (dummyt d1  WITH seq = size(preg_sec_orgs->qual,5))
    PLAN (pi
     WHERE pi.preg_end_dt_tm >= cnvtdatetime(curdate,curtime3)
      AND pi.active_ind=1
      AND pi.historical_ind=0)
     JOIN (pr
     WHERE pr.problem_id=pi.problem_id
      AND pr.active_ind=1)
     JOIN (e
     WHERE e.person_id=pi.person_id
      AND cnvtint(format(e.reg_dt_tm,"YYYYMMDD;;D")) >= cnvtint(format(pr.onset_dt_tm,"YYYYMMDD;;D"))
     )
     JOIN (o
     WHERE o.organization_id=e.organization_id)
     JOIN (d1
     WHERE (o.organization_id=preg_sec_orgs->qual[d1.seq].org_id))
   ELSE
    FROM pregnancy_instance pi,
     encounter e,
     organization o,
     problem pr
    PLAN (pi
     WHERE pi.preg_end_dt_tm >= cnvtdatetime(curdate,curtime3)
      AND pi.active_ind=1
      AND pi.historical_ind=0)
     JOIN (pr
     WHERE pr.problem_id=pi.problem_id
      AND pr.active_ind=1)
     JOIN (e
     WHERE e.person_id=pi.person_id
      AND cnvtint(format(e.reg_dt_tm,"YYYYMMDD;;D")) >= cnvtint(format(pr.onset_dt_tm,"YYYYMMDD;;D"))
     )
     JOIN (o
     WHERE o.organization_id=e.organization_id)
   ENDIF
   ORDER BY pi.pregnancy_id, o.organization_id
   HEAD REPORT
    active_preg_cnt = 0, org_cnt = 0
   HEAD pi.pregnancy_id
    active_preg_cnt = (active_preg_cnt+ 1)
    IF (active_preg_cnt > size(request_final_ega->pregnancy_list,5))
     bstatus = alterlist(request_final_ega->pregnancy_list,(active_preg_cnt+ 9)), cstatus = alterlist
     (temp->patient,(active_preg_cnt+ 9))
    ENDIF
    request_final_ega->pregnancy_list[active_preg_cnt].pregnancy_id = pi.pregnancy_id, temp->patient[
    active_preg_cnt].pregnancy_id = pi.pregnancy_id, temp->patient[active_preg_cnt].person_id = pi
    .person_id,
    org_cnt = 0
   HEAD o.organization_id
    org_cnt = (org_cnt+ 1)
    IF (org_cnt=1)
     temp->patient[active_preg_cnt].org_display = trim(o.org_name)
    ELSE
     temp->patient[active_preg_cnt].org_display = concat(temp->patient[active_preg_cnt].org_display,
      " ,",trim(o.org_name))
    ENDIF
   FOOT REPORT
    bstatus = alterlist(request_final_ega->pregnancy_list,active_preg_cnt), cstatus = alterlist(temp
     ->patient,active_preg_cnt)
   WITH nocounter
  ;end select
 ELSE
  SELECT
   IF (preg_org_sec_ind=1
    AND valid_pi_org_id_ind > 0)
    FROM pregnancy_instance pi,
     encounter e,
     organization o,
     problem pr
    PLAN (pi
     WHERE pi.preg_end_dt_tm >= cnvtdatetime(curdate,curtime3)
      AND pi.active_ind=1
      AND pi.historical_ind=0)
     JOIN (pr
     WHERE pr.problem_id=pi.problem_id
      AND pr.active_ind=1)
     JOIN (e
     WHERE e.person_id=pi.person_id
      AND cnvtint(format(e.reg_dt_tm,"YYYYMMDD;;D")) >= cnvtint(format(pr.onset_dt_tm,"YYYYMMDD;;D"))
      AND expand(org_idx,1,org->count,e.organization_id,org->rec[org_idx].organization_id)
      AND expand(org_idx,1,size(preg_sec_orgs->qual,5),e.organization_id,preg_sec_orgs->qual[org_idx]
      .org_id))
     JOIN (o
     WHERE o.organization_id=e.organization_id)
   ELSE
    FROM pregnancy_instance pi,
     encounter e,
     organization o,
     problem pr
    PLAN (pi
     WHERE pi.preg_end_dt_tm >= cnvtdatetime(curdate,curtime3)
      AND pi.active_ind=1
      AND pi.historical_ind=0)
     JOIN (pr
     WHERE pr.problem_id=pi.problem_id
      AND pr.active_ind=1)
     JOIN (e
     WHERE e.person_id=pi.person_id
      AND cnvtint(format(e.reg_dt_tm,"YYYYMMDD;;D")) >= cnvtint(format(pr.onset_dt_tm,"YYYYMMDD;;D"))
      AND expand(org_idx,1,org->count,e.organization_id,org->rec[org_idx].organization_id))
     JOIN (o
     WHERE o.organization_id=e.organization_id)
   ENDIF
   ORDER BY pi.pregnancy_id, o.organization_id
   HEAD REPORT
    active_preg_cnt = 0, org_cnt = 0
   HEAD pi.pregnancy_id
    active_preg_cnt = (active_preg_cnt+ 1)
    IF (active_preg_cnt > size(request_final_ega->pregnancy_list,5))
     bstatus = alterlist(request_final_ega->pregnancy_list,(active_preg_cnt+ 9)), cstatus = alterlist
     (temp->patient,(active_preg_cnt+ 9))
    ENDIF
    request_final_ega->pregnancy_list[active_preg_cnt].pregnancy_id = pi.pregnancy_id, temp->patient[
    active_preg_cnt].pregnancy_id = pi.pregnancy_id, temp->patient[active_preg_cnt].person_id = pi
    .person_id,
    org_cnt = 0
   HEAD o.organization_id
    org_cnt = (org_cnt+ 1)
    IF (org_cnt=1)
     temp->patient[active_preg_cnt].org_display = trim(o.org_name)
    ELSE
     temp->patient[active_preg_cnt].org_display = concat(temp->patient[active_preg_cnt].org_display,
      " ,",trim(o.org_name))
    ENDIF
   FOOT REPORT
    bstatus = alterlist(request_final_ega->pregnancy_list,active_preg_cnt), cstatus = alterlist(temp
     ->patient,active_preg_cnt)
   WITH nocounter
  ;end select
 ENDIF
 IF (debug_ind >= 2)
  CALL echorecord(request_final_ega)
 ENDIF
 SET modify = nopredeclare
 IF (valid_pi_org_id_ind > 0)
  EXECUTE dcp_get_final_ega  WITH replace("REQUEST",request_final_ega), replace("REPLY",
   reply_final_ega)
 ELSE
  EXECUTE pcm_wh_get_final_ega  WITH replace("REQUEST",request_final_ega), replace("REPLY",
   reply_final_ega)
 ENDIF
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
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = size(reply_final_ega->gestation_info,5)),
   (dummyt d2  WITH seq = size(temp->patient,5))
  PLAN (d1)
   JOIN (d2
   WHERE (temp->patient[d2.seq].pregnancy_id=reply_final_ega->gestation_info[d1.seq].pregnancy_id))
  DETAIL
   temp->patient[d2.seq].r_est_delivery_date = reply_final_ega->gestation_info[d1.seq].
   est_delivery_date, temp->patient[d2.seq].r_delivery_date = reply_final_ega->gestation_info[d1.seq]
   .delivery_date, temp->patient[d2.seq].r_gest_age_delivery = reply_final_ega->gestation_info[d1.seq
   ].gest_age_at_delivery,
   temp->patient[d2.seq].r_current_gest_age = reply_final_ega->gestation_info[d1.seq].
   current_gest_age
  WITH nocounter
 ;end select
 SET irequestsize = size(temp->patient,5)
 SET expand_total = (ceil((cnvtreal(irequestsize)/ expand_size)) * expand_size)
 SET bstatus = alterlist(temp->patient,expand_total)
 SELECT
  IF (prompt11=0)
   FROM pregnancy_instance pi,
    person p,
    person_alias pa,
    pregnancy_action pra,
    person p2,
    (dummyt d  WITH seq = value((1+ ((expand_total - 1)/ expand_size))))
   PLAN (d
    WHERE initarray(expand_start,evaluate(d.seq,1,1,(expand_start+ expand_size))))
    JOIN (pi
    WHERE expand(idx,expand_start,(expand_start+ (expand_size - 1)),pi.pregnancy_id,temp->patient[idx
     ].pregnancy_id)
     AND pi.active_ind=1
     AND pi.preg_end_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (p
    WHERE pi.person_id=p.person_id
     AND p.active_ind=1)
    JOIN (pa
    WHERE p.person_id=pa.person_id
     AND pa.person_alias_type_cd IN (mrn_cd)
     AND pa.active_ind=1)
    JOIN (pra
    WHERE pra.pregnancy_id=outerjoin(pi.pregnancy_id))
    JOIN (p2
    WHERE p2.person_id=outerjoin(pra.prsnl_id))
  ELSE
   FROM pregnancy_instance pi,
    person p,
    person_alias pa,
    pregnancy_action pra,
    person p2,
    (dummyt d  WITH seq = value((1+ ((expand_total - 1)/ expand_size))))
   PLAN (d
    WHERE initarray(expand_start,evaluate(d.seq,1,1,(expand_start+ expand_size))))
    JOIN (pi
    WHERE expand(idx,expand_start,(expand_start+ (expand_size - 1)),pi.pregnancy_id,temp->patient[idx
     ].pregnancy_id)
     AND pi.active_ind=1
     AND pi.preg_end_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (p
    WHERE pi.person_id=p.person_id
     AND p.active_ind=1)
    JOIN (pa
    WHERE p.person_id=pa.person_id
     AND pa.person_alias_type_cd IN (mrn_cd)
     AND pa.active_ind=1)
    JOIN (pra
    WHERE pra.pregnancy_id=pi.pregnancy_id
     AND expand(per_int,1,attending->count,pra.prsnl_id,attending->rec[per_int].person_id))
    JOIN (p2
    WHERE p2.person_id=pra.prsnl_id)
  ENDIF
  INTO "nl:"
  ORDER BY pi.pregnancy_id, pra.updt_dt_tm DESC, p.name_last_key,
   p.name_first_key, pa.alias
  HEAD REPORT
   cnt = 0, q_cnt = 0
  HEAD pi.pregnancy_id
   q_cnt = (q_cnt+ 1), pregidx = locateval(idx,1,irequestsize,pi.pregnancy_id,temp->patient[idx].
    pregnancy_id), new_cur_gest_age = 0,
   ega_calculated = 0
   IF ((temp->patient[idx].r_current_gest_age=0)
    AND (temp->patient[idx].r_delivery_date != null))
    new_cur_gest_age = (temp->patient[idx].r_gest_age_delivery+ datetimediff(cnvtdatetime(curdate,
      curtime3),temp->patient[idx].r_delivery_date))
   ELSEIF ((temp->patient[idx].r_current_gest_age=0)
    AND (temp->patient[idx].r_est_delivery_date != 0))
    new_cur_gest_age = ((40 * 7)+ datetimediff(cnvtdatetime(curdate,curtime3),temp->patient[idx].
     r_est_delivery_date)), ega_calculated = 1
   ELSE
    new_cur_gest_age = temp->patient[idx].r_current_gest_age
   ENDIF
   IF (cnvtint( $2)=2)
    IF ((temp->patient[idx].r_est_delivery_date BETWEEN cnvtdatetime(value( $6)) AND cnvtdatetime(
     value( $7))))
     temp->patient[idx].print_ind = 1
    ENDIF
   ELSEIF (cnvtint( $2)=1)
    IF (cnvtint( $3)=1)
     IF ((new_cur_gest_age=(cnvtint( $4) * 7)))
      temp->patient[idx].print_ind = 1
     ENDIF
    ELSEIF (cnvtint( $3)=2)
     IF ((new_cur_gest_age > (cnvtint( $4) * 7)))
      temp->patient[idx].print_ind = 1
     ENDIF
    ELSEIF (cnvtint( $3)=3)
     IF ((new_cur_gest_age < (cnvtint( $4) * 7)))
      temp->patient[idx].print_ind = 1
     ENDIF
    ELSEIF (cnvtint( $3)=4)
     IF (new_cur_gest_age BETWEEN (cnvtint( $4) * 7) AND (cnvtint( $5) * 7))
      temp->patient[idx].print_ind = 1
     ENDIF
    ENDIF
   ENDIF
   temp->patient[idx].mrn = trim(pa.alias), temp->patient[idx].person_lastname = substring(1,18,trim(
     p.name_last)), temp->patient[idx].person_firstname = substring(1,18,trim(p.name_first))
   IF (size(trim(p2.name_full_formatted)) > 0)
    temp->patient[idx].primary_physician = p2.name_full_formatted
   ELSE
    temp->patient[idx].primary_physician = "--"
   ENDIF
   IF ((temp->patient[idx].r_est_delivery_date=null))
    temp->patient[idx].edd = "--"
   ELSEIF ((temp->patient[idx].r_est_delivery_date=0))
    temp->patient[idx].edd = "--"
   ELSE
    temp->patient[idx].edd = format(temp->patient[idx].r_est_delivery_date,"@SHORTDATE")
   ENDIF
   gestage = new_cur_gest_age, gestageweeks = (gestage/ 7), gestagedays = mod(gestage,7)
   IF (gestagedays > 0)
    temp->patient[idx].gest_age = concat(trim(cnvtstring(gestageweeks))," ",trim(cnvtstring(
       gestagedays)),"/7")
   ELSE
    temp->patient[idx].gest_age = build(gestageweeks)
   ENDIF
   IF (gestage=0)
    temp->patient[idx].gest_age = "--"
   ENDIF
   temp->patient[idx].pregnancy_id = pi.pregnancy_id, temp->patient[idx].person_id = pi.person_id,
   temp->patient[idx].ega = new_cur_gest_age
  WITH nocounter
 ;end select
 CALL echo(build("iRequestSize   :",irequestsize))
 SET istat = alterlist(temp->patient,irequestsize)
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
 ELSEIF (size(temp->patient,5)=0)
  IF (debug_ind >= 1)
   CALL echo("Printing report - no data ")
  ENDIF
  GO TO no_encntr
 ELSE
  IF (debug_ind >= 1)
   CALL echo(build("Printing report - pregnancy count: ",size(temp->patient,5)))
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  sort =
  IF (cnvtint( $2)=1) temp->patient[d.seq].ega
  ELSEIF (cnvtint( $2)=2) temp->patient[d.seq].r_est_delivery_date
  ENDIF
  , sort2 = temp->patient[d.seq].primary_physician, sort3 = temp->patient[d.seq].person_lastname
  FROM (dummyt d  WITH seq = size(temp->patient,5))
  WHERE (temp->patient[d.seq].print_ind=1)
  ORDER BY sort, sort2, sort3
  HEAD REPORT
   temp_cnt = 0
  DETAIL
   temp_cnt = (temp_cnt+ 1)
   IF (temp_cnt > size(pregnancy->patient,5))
    stat = alterlist(pregnancy->patient,(temp_cnt+ 99))
   ENDIF
   pregnancy->patient[temp_cnt].mrn = temp->patient[d.seq].mrn, pregnancy->patient[temp_cnt].
   person_lastname = temp->patient[d.seq].person_lastname, pregnancy->patient[temp_cnt].
   person_firstname = temp->patient[d.seq].person_firstname,
   pregnancy->patient[temp_cnt].gest_age = temp->patient[d.seq].gest_age, pregnancy->patient[temp_cnt
   ].edd = temp->patient[d.seq].edd, pregnancy->patient[temp_cnt].primary_physician = temp->patient[d
   .seq].primary_physician,
   pregnancy->patient[temp_cnt].facility = temp->patient[d.seq].org_display
  FOOT REPORT
   stat = alterlist(pregnancy->patient,temp_cnt), pregnancy->patient_cnt = temp_cnt
  WITH nocounter
 ;end select
 IF (debug_ind >= 1)
  CALL echorecord(pregnancy)
 ENDIF
 CALL echorecord(pregnancy)
#no_encntr
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
#exit_report
 FREE RECORD request_final_ega
 FREE RECORD reply_final_ega
 FREE RECORD attending
 FREE RECORD temp
 SET modify = nopredeclare
 SET script_version = "003 12/12/2012 ss026368"
END GO
