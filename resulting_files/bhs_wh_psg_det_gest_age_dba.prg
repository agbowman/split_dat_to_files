CREATE PROGRAM bhs_wh_psg_det_gest_age:dba
 IF ( NOT (validate(rhead,0)))
  SET rhead = "{\rtf1\ansi \deff0{\fonttbl{\f0\fswiss Arial;}}"
  SET rhead_colors1 = "{\colortbl;\red0\green0\blue0;\red255\green255\blue255;"
  SET rhead_colors2 = "\red99\green99\blue99;\red22\green107\blue178;"
  SET rhead_colors3 = "\red0\green0\blue255;\red123\green193\blue67;\red255\green0\blue0;}"
  SET reol = "\par "
  SET rtab = "\tab "
  SET wr = "\plain \f0 \fs16 \cb2 "
  SET wr11 = "\plain \f0 \fs11 \cb2 "
  SET wr18 = "\plain \f0 \fs18 \cb2 "
  SET wr20 = "\plain \f0 \fs20 \cb2 "
  SET wu = "\plain \f0 \fs16 \ul \cb2 "
  SET wb = "\plain \f0 \fs16 \b \cb2 "
  SET wbu = "\plain \f0 \fs16 \b \ul \cb2 "
  SET wi = "\plain \f0 \fs16 \i \cb2 "
  SET ws = "\plain \f0 \fs16 \strike \cb2"
  SET wb2 = "\plain \f0 \fs18 \b \cb2 "
  SET wb18 = "\plain \f0 \fs18 \b \cb2 "
  SET wb20 = "\plain \f0 \fs20 \b \cb2 "
  SET rsechead = "\plain \f0 \fs28 \b \ul \cb2 "
  SET rsubsechead = "\plain \f0 \fs22 \b \cb2 "
  SET rsecline = "\plain \f0 \fs20 \b \cb2 "
  SET hi = "\pard\fi-2340\li2340 "
  SET rtfeof = "}"
  SET wbuf26 = "\plain \f0 \fs26 \b \ul \cb2 "
  SET wbuf30 = "\plain \f0 \fs30 \b \ul \cb2 "
  SET rpard = "\pard "
  SET rtitle = "\plain \f0 \fs36 \b \cb2 "
  SET rpatname = "\plain \f0 \fs38 \b \cb2 "
  SET rtabstop1 = "\tx300"
  SET rtabstopnd = "\tx400"
  SET wsd = "\plain \f0 \fs13 \cb2 "
  SET wsb = "\plain \f0 \fs13 \b \cb2 "
  SET wrs = "\plain \f0 \fs14 \cb2 "
  SET wbs = "\plain \f0 \fs14 \b \cb2 "
  DECLARE snot_documented = vc WITH public, constant("--")
  SET color0 = "\cf0 "
  SET colorgrey = "\cf3 "
  SET colornavy = "\cf4 "
  SET colorblue = "\cf5 "
  SET colorgreen = "\cf6 "
  SET colorred = "\cf7 "
  SET row_start = "\trowd"
  SET row_end = "\row"
  SET cell_start = "\intbl "
  SET cell_end = "\cell"
  SET cell_text_center = "\qc "
  SET cell_text_left = "\ql "
  SET cell_border_top = "\clbrdrt\brdrt\brdrw1"
  SET cell_border_left = "\clbrdrl\brdrl\brdrw1"
  SET cell_border_bottom = "\clbrdrb\brdrb\brdrw1"
  SET cell_border_right = "\clbrdrr\brdrr\brdrw1"
  SET cell_border_top_left = "\clbrdrt\brdrt\brdrw1\clbrdrl\brdrl\brdrw1"
  SET block_start = "{"
  SET block_end = "}"
 ENDIF
 DECLARE whorgsecpref = i2 WITH protect, noconstant(0)
 DECLARE prsnl_override_flag = i2 WITH protect, noconstant(0)
 DECLARE preg_org_sec_ind = i4 WITH noconstant(0), public
 DECLARE os_idx = i4 WITH noconstant(0)
 IF (validate(antepartum_run_ind)=0)
  DECLARE antepartum_run_ind = i4 WITH public, noconstant(0)
 ENDIF
 IF ( NOT (validate(whsecuritydisclaim)))
  DECLARE whsecuritydisclaim = vc WITH public, constant(uar_i18ngetmessage(i18nhandle,"cap99",
    "(Report contains only data from encounters at associated organizations)"))
 ENDIF
 IF ( NOT (validate(preg_sec_orgs)))
  FREE RECORD preg_sec_orgs
  RECORD preg_sec_orgs(
    1 qual[*]
      2 org_id = f8
      2 confid_level = i4
  )
 ENDIF
 DECLARE getpersonneloverride(person_id=f8(val),prsnl_id=f8(val)) = i2 WITH protect
 DECLARE getpreferences() = i2 WITH protect
 DECLARE getorgsecurity() = null WITH protect
 DECLARE loadorganizationsecuritylist() = null
 IF (validate(honor_org_security_flag)=0)
  DECLARE honor_org_security_flag = i2 WITH public, noconstant(0)
  SET whorgsecpref = getpreferences(null)
  CALL getorgsecurity(null)
  SET prsnl_override_flag = getpersonneloverride(request->person[1].person_id,reqinfo->updt_id)
  IF (prsnl_override_flag=0)
   IF (preg_org_sec_ind=1
    AND whorgsecpref=1)
    SET honor_org_security_flag = 1
   ENDIF
  ENDIF
 ENDIF
 SUBROUTINE getpersonneloverride(person_id,prsnl_id)
   CALL echo(build("person_id=",person_id))
   CALL echo(build("prsnl_id=",prsnl_id))
   DECLARE override_ind = i2 WITH protect, noconstant(0)
   IF (((person_id <= 0.0) OR (prsnl_id <= 0.0)) )
    RETURN(0)
   ENDIF
   SELECT INTO "nl:"
    FROM person_prsnl_reltn ppr,
     code_value_extension cve
    PLAN (ppr
     WHERE ppr.prsnl_person_id=prsnl_id
      AND ppr.active_ind=1
      AND ((ppr.person_id+ 0)=person_id)
      AND ppr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND ppr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     JOIN (cve
     WHERE cve.code_value=ppr.person_prsnl_r_cd
      AND cve.code_set=331
      AND ((cve.field_value="1") OR (cve.field_value="2"))
      AND cve.field_name="Override")
    DETAIL
     override_ind = 1
    WITH nocounter
   ;end select
   RETURN(override_ind)
 END ;Subroutine
 SUBROUTINE getpreferences(null)
   DECLARE powerchart_app_number = i4 WITH protect, constant(600005)
   DECLARE spreferencename = vc WITH protect, constant("PREGNANCY_SMART_TMPLT_ORG_SEC")
   DECLARE prefvalue = vc WITH noconstant("0"), protect
   SELECT INTO "nl:"
    FROM app_prefs ap,
     name_value_prefs nvp
    PLAN (ap
     WHERE ap.prsnl_id=0.0
      AND ap.position_cd=0.0
      AND ap.application_number=powerchart_app_number)
     JOIN (nvp
     WHERE nvp.parent_entity_name="APP_PREFS"
      AND nvp.parent_entity_id=ap.app_prefs_id
      AND trim(nvp.pvc_name,3)=cnvtupper(spreferencename))
    DETAIL
     prefvalue = nvp.pvc_value
    WITH nocounter
   ;end select
   RETURN(cnvtint(prefvalue))
 END ;Subroutine
 SUBROUTINE getorgsecurity(null)
   SELECT INTO "nl:"
    FROM dm_info d1
    WHERE d1.info_domain="SECURITY"
     AND d1.info_name="SEC_ORG_RELTN"
     AND d1.info_number=1
    DETAIL
     preg_org_sec_ind = 1
    WITH nocounter
   ;end select
   CALL echo(build("org_sec_ind=",preg_org_sec_ind))
   IF (preg_org_sec_ind=1)
    CALL loadorganizationsecuritylist(null)
   ENDIF
 END ;Subroutine
 SUBROUTINE loadorganizationsecuritylist(null)
   DECLARE org_cnt = i2 WITH noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (validate(sac_org)=1)
    FREE RECORD sac_org
   ENDIF
   RECORD sac_org(
     1 organizations[*]
       2 organization_id = f8
       2 confid_cd = f8
       2 confid_level = i4
   )
   EXECUTE secrtl
   DECLARE orgcnt = i4 WITH protected, noconstant(0)
   DECLARE secstat = i2
   DECLARE logontype = i4 WITH protect, noconstant(- (1))
   DECLARE confid_cd = f8 WITH protected, noconstant(0.0)
   DECLARE role_profile_org_id = f8 WITH protected, noconstant(0.0)
   CALL uar_secgetclientlogontype(logontype)
   CALL echo(build("logontype:",logontype))
   IF (logontype=0)
    SELECT DISTINCT INTO "nl:"
     FROM prsnl_org_reltn por,
      organization o,
      prsnl p
     PLAN (p
      WHERE (p.person_id=reqinfo->updt_id))
      JOIN (por
      WHERE por.person_id=p.person_id
       AND por.active_ind=1
       AND por.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND por.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
      JOIN (o
      WHERE por.organization_id=o.organization_id)
     DETAIL
      orgcnt = (orgcnt+ 1)
      IF (mod(orgcnt,10)=1)
       secstat = alterlist(sac_org->organizations,(orgcnt+ 9))
      ENDIF
      sac_org->organizations[orgcnt].organization_id = por.organization_id, sac_org->organizations[
      orgcnt].confid_cd = por.confid_level_cd, confid_cd = uar_get_collation_seq(por.confid_level_cd),
      sac_org->organizations[orgcnt].confid_level =
      IF (confid_cd > 0) confid_cd
      ELSE 0
      ENDIF
     WITH nocounter
    ;end select
    SET secstat = alterlist(sac_org->organizations,orgcnt)
   ENDIF
   IF (logontype=1)
    CALL echo("entered into NHS logon")
    DECLARE hprop = i4 WITH protect, noconstant(0)
    DECLARE tmpstat = i2
    DECLARE spropname = vc
    DECLARE sroleprofile = vc
    SET hprop = uar_srvcreateproperty()
    SET tmpstat = uar_secgetclientattributesext(5,hprop)
    SET spropname = uar_srvfirstproperty(hprop)
    SET sroleprofile = uar_srvgetpropertyptr(hprop,nullterm(spropname))
    CALL echo(sroleprofile)
    DECLARE nhstrustchild_org_org_reltn_cd = f8
    SET nhstrustchild_org_org_reltn_cd = uar_get_code_by("MEANING",369,"NHSTRUSTCHLD")
    SELECT INTO "nl:"
     FROM prsnl_org_reltn_type prt,
      prsnl_org_reltn por,
      organization o
     PLAN (prt
      WHERE prt.role_profile=sroleprofile
       AND prt.active_ind=1
       AND prt.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND prt.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
      JOIN (o
      WHERE o.organization_id=prt.organization_id)
      JOIN (por
      WHERE outerjoin(prt.organization_id)=por.organization_id
       AND por.person_id=outerjoin(prt.prsnl_id)
       AND por.active_ind=outerjoin(1)
       AND por.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
       AND por.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
     ORDER BY por.prsnl_org_reltn_id
     DETAIL
      orgcnt = 1, stat = alterlist(sac_org->organizations,1), sac_org->organizations[1].
      organization_id = prt.organization_id,
      role_profile_org_id = sac_org->organizations[orgcnt].organization_id, sac_org->organizations[1]
      .confid_cd = por.confid_level_cd, confid_cd = uar_get_collation_seq(por.confid_level_cd),
      sac_org->organizations[1].confid_level =
      IF (confid_cd > 0) confid_cd
      ELSE 0
      ENDIF
     WITH maxrec = 1
    ;end select
    SELECT INTO "nl:"
     FROM prsnl_org_reltn por
     PLAN (por
      WHERE (por.person_id=reqinfo->updt_id)
       AND por.active_ind=1
       AND por.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND por.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     HEAD REPORT
      IF (orgcnt > 0)
       stat = alterlist(sac_org->organizations,10)
      ENDIF
     DETAIL
      IF (role_profile_org_id != por.organization_id)
       orgcnt = (orgcnt+ 1)
       IF (mod(orgcnt,10)=1)
        stat = alterlist(sac_org->organizations,(orgcnt+ 9))
       ENDIF
       sac_org->organizations[orgcnt].organization_id = por.organization_id, sac_org->organizations[
       orgcnt].confid_cd = por.confid_level_cd, confid_cd = uar_get_collation_seq(por.confid_level_cd
        ),
       sac_org->organizations[orgcnt].confid_level =
       IF (confid_cd > 0) confid_cd
       ELSE 0
       ENDIF
      ENDIF
     FOOT REPORT
      stat = alterlist(sac_org->organizations,orgcnt)
     WITH nocounter
    ;end select
    CALL uar_srvdestroyhandle(hprop)
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
   CALL echorecord(preg_sec_orgs)
 END ;Subroutine
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
 DECLARE edd_id = f8
 DECLARE current_ega_days = f8
 DECLARE ega_found = i4 WITH public, noconstant(0)
 DECLARE ispatientdelivered(null) = i2 WITH protect
 FREE RECORD dcp_request
 RECORD dcp_request(
   1 provider_id = f8
   1 position_cd = f8
   1 cal_ega_multiple_gest = i2
   1 patient_list[1]
     2 patient_id = f8
     2 encntr_id = f8
   1 provider_list[1]
     2 patient_id = f8
     2 encntr_id = f8
     2 provider_patient_reltn_cd = f8
   1 pregnancy_list[*]
     2 pregnancy_id = f8
   1 multiple_egas = i2
 )
 SET stat = alterlist(dcp_request->patient_list,1)
 SET dcp_request->patient_list[1].patient_id = request->person[1].person_id
 SET dcp_request->cal_ega_multiple_gest = 1
 SET dcp_request->multiple_egas = 1
 SET dcp_request->provider_id = reqinfo->updt_id
 SET dcp_request->position_cd = reqinfo->position_cd
 EXECUTE dcp_get_final_ega  WITH replace("REQUEST",dcp_request), replace("REPLY",dcp_reply)
 SET modify = nopredeclare
 IF ((dcp_reply->gestation_info[1].edd_id > 0.0))
  SELECT INTO "nl:"
   FROM pregnancy_estimate pe
   PLAN (pe
    WHERE (pe.pregnancy_estimate_id=dcp_reply->gestation_info[1].edd_id))
   DETAIL
    ega_found = 1
    IF ((dcp_reply->gestation_info[1].current_gest_age > 0))
     current_ega_days = dcp_reply->gestation_info[1].current_gest_age
    ELSEIF ((dcp_reply->gestation_info[1].gest_age_at_delivery > 0))
     current_ega_days = dcp_reply->gestation_info[1].gest_age_at_delivery
    ENDIF
    edd_id = pe.pregnancy_estimate_id
   WITH nocounter
  ;end select
 ENDIF
 SUBROUTINE ispatientdelivered(null)
   DECLARE patient_delivered_ind = i2 WITH protect, noconstant(0)
   IF ((dcp_reply->gestation_info[1].delivered_ind=1)
    AND (dcp_reply->gestation_info[1].partial_delivery_ind=0)
    AND size(dcp_reply->gestation_info[1].dynamic_label,5) > 0)
    SET patient_delivered_ind = 1
   ENDIF
   RETURN(patient_delivered_ind)
 END ;Subroutine
 IF ( NOT (validate(i18nhandle)))
  DECLARE i18nhandle = i4 WITH protect, noconstant(0)
 ENDIF
 SET stat = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 DECLARE stand_alone_ind = i4 WITH protect, noconstant(0)
 IF ( NOT (validate(request->person[1].pregnancy_list)))
  SET stand_alone_ind = 1
 ENDIF
 IF (validate(debug_ind,0)=1)
  CALL echo(build("stand_alone_ind:",stand_alone_ind))
 ENDIF
 FREE SET gest_age
 RECORD gest_age(
   1 edd_calc_cnt = i4
   1 ega_current = vc
   1 edd_calc[*]
     2 confirmation = vc
     2 status = vc
     2 ega_current = vc
     2 method = vc
     2 description = vc
     2 documented_by = vc
     2 edd_final = vc
     2 entry_date = vc
     2 method_date = vc
     2 comments = vc
     2 comments_wrapped[*]
       3 wrap_text = vc
 )
 FREE SET g_info
 RECORD g_info(
   1 gravida = vc
   1 para_details = vc
   1 para_full_term = vc
   1 para_premature = vc
   1 para_abortions = vc
   1 para = vc
   1 mod_ind = vc
 )
 FREE RECORD pt
 RECORD pt(
   1 line_cnt = i2
   1 lns[*]
     2 line = vc
 )
 IF (validate(pt_info)=0)
  RECORD pt_info(
    1 age = vc
    1 gravida = vc
    1 para_full_term = vc
    1 para_premature = vc
    1 para_abortions = vc
    1 para = vc
    1 final_edd = vc
    1 mod_ind = vc
    1 ega = vc
  )
 ENDIF
 DECLARE cki_lmp = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!12676043"))
 DECLARE cckideldttm = vc WITH protect, constant("CERNER!ASYr9AEYvUr1YoPTCqIGfQ")
 DECLARE dqdel_dt_tm = dq8
 DECLARE del_ind = i2 WITH protect, noconstant(0)
 DECLARE cnodata = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"cap1",
   "No EGA/EDD calculations have been recorded"))
 DECLARE captions_title = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"cap2",
   "Gestational Age (EGA) and EDD"))
 DECLARE captions_edd_final = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"cap3","EDD:"))
 DECLARE captions_ega = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"cap4","EGA*:"))
 DECLARE captions_status = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"cap5","Type:"))
 DECLARE captions_method_dt = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"cap6",
   "Method Date:"))
 DECLARE captions_method = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"cap7","Method:"))
 DECLARE captions_confirmation = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"cap8",
   "Confirmation:"))
 DECLARE captions_description = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"cap9",
   "Description:"))
 DECLARE captions_comments = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"cap10",
   "Comments:"))
 DECLARE captions_documented_by = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"cap11",
   "Entered by:"))
 DECLARE captions_other_ega = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"cap16",
   "EGA (At Entry):"))
 DECLARE captions_other_edd_head = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"cap18",
   "Other EDD Calculations for this Pregnancy:"))
 DECLARE captions_no_other = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"cap19",
   "No additional EDD calculations have been recorded for this pregnancy"))
 DECLARE con = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"cap20"," on"))
 DECLARE cweeks = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"cap21"," weeks"))
 DECLARE cdays = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"cap22"," days"))
 DECLARE c1week = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"cap23","1 week"))
 DECLARE c1day = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"cap24","1 day"))
 DECLARE cnonauthoritative = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"cap25",
   "Non-Authoritative"))
 DECLARE cinitial = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"cap26","Initial"))
 DECLARE cauthoritative = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"cap27",
   "Authoritative"))
 DECLARE cfinal = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"cap28","Final"))
 DECLARE cinitial_final = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"cap29",
   "Initial / Final"))
 DECLARE cnormalamt = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"cap30",
   " Normal Amount/Duration"))
 DECLARE cabnormalamt = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"cap31",
   " Abnormal Amount/Duration"))
 DECLARE cdateapproximate = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"cap32",
   " Date Approximate"))
 DECLARE cdatedefinite = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"cap33",
   " Date Definite"))
 DECLARE cdateunknown = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"cap34",
   " Date Unknown"))
 DECLARE cdisclaimer = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"cap35",
   "     * Note: EGA calculated as of"))
 DECLARE modifiedcaption = vc WITH protect, noconstant(" (c)")
 DECLARE wk = vc WITH public, noconstant("")
 DECLARE dy = vc WITH public, noconstant("")
 DECLARE space = c6 WITH protect, constant(" ")
 DECLARE space_comments = c25 WITH protect, constant(" ")
 DECLARE max_length = i4 WITH protect, noconstant(90)
 DECLARE patient_delivered_ind = i2 WITH public, noconstant(0)
 DECLARE auth = f8 WITH public, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE altered = f8 WITH public, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE modified = f8 WITH public, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE gravida = f8 WITH public, constant(uar_get_code_by_cki("CKI.EC!6299"))
 DECLARE para_details = f8 WITH public, constant(uar_get_code_by_cki("CKI.EC!6300"))
 DECLARE para_full_term = f8 WITH public, constant(uar_get_code_by_cki("CKI.EC!10099"))
 DECLARE para_premature = f8 WITH public, constant(uar_get_code_by_cki("CKI.EC!10100"))
 DECLARE para_abortions = f8 WITH public, constant(uar_get_code_by_cki("CKI.EC!10101"))
 DECLARE para_living = f8 WITH public, constant(uar_get_code_by_cki("CKI.EC!10024"))
 IF (ispatientdelivered(null))
  IF ((dcp_reply->gestation_info[1].gest_age_at_delivery <= 0))
   SET pt_info->ega = snot_documented
  ELSEIF ((dcp_reply->gestation_info[1].gest_age_at_delivery < 7))
   SET pt_info->ega = build(dcp_reply->gestation_info[1].gest_age_at_delivery,cdays)
  ELSEIF ((dcp_reply->gestation_info[1].gest_age_at_delivery=7))
   SET pt_info->ega = c1week
  ELSEIF (mod(dcp_reply->gestation_info[1].gest_age_at_delivery,7)=0)
   SET pt_info->ega = build((dcp_reply->gestation_info[1].gest_age_at_delivery/ 7),cweeks)
  ELSE
   IF (((dcp_reply->gestation_info[1].gest_age_at_delivery/ 7) >= 1)
    AND ((dcp_reply->gestation_info[1].gest_age_at_delivery/ 7) < 2))
    SET wk = c1week
   ELSE
    SET wk = build(trim(cnvtstring((dcp_reply->gestation_info[1].gest_age_at_delivery/ 7))),cweeks)
   ENDIF
   IF (mod(dcp_reply->gestation_info[1].gest_age_at_delivery,7)=1)
    SET dy = c1day
   ELSE
    SET dy = build(trim(cnvtstring(mod(dcp_reply->gestation_info[1].gest_age_at_delivery,7))),cdays)
   ENDIF
   SET pt_info->ega = concat(wk," ",dy)
  ENDIF
 ELSE
  IF ((dcp_reply->gestation_info[1].current_gest_age <= 0))
   SET pt_info->ega = snot_documented
  ELSEIF ((dcp_reply->gestation_info[1].current_gest_age < 7))
   SET pt_info->ega = build(dcp_reply->gestation_info[1].current_gest_age,cdays)
  ELSEIF ((dcp_reply->gestation_info[1].current_gest_age=7))
   SET pt_info->ega = c1week
  ELSEIF (mod(dcp_reply->gestation_info[1].current_gest_age,7)=0)
   SET pt_info->ega = build((dcp_reply->gestation_info[1].current_gest_age/ 7),cweeks)
  ELSE
   IF (((dcp_reply->gestation_info[1].current_gest_age/ 7) >= 1)
    AND ((dcp_reply->gestation_info[1].current_gest_age/ 7) < 2))
    SET wk = c1week
   ELSE
    SET wk = build(trim(cnvtstring((dcp_reply->gestation_info[1].current_gest_age/ 7))),cweeks)
   ENDIF
   IF (mod(dcp_reply->gestation_info[1].current_gest_age,7)=1)
    SET dy = c1day
   ELSE
    SET dy = build(trim(cnvtstring(mod(dcp_reply->gestation_info[1].current_gest_age,7))),cdays)
   ENDIF
   SET pt_info->ega = concat(wk," ",dy)
  ENDIF
 ENDIF
 SELECT
  IF (honor_org_security_flag=1)
   PLAN (pi
    WHERE (pi.person_id=request->person[1].person_id)
     AND pi.active_ind=1
     AND pi.historical_ind=0
     AND pi.preg_end_dt_tm=cnvtdatetime("31-DEC-2100")
     AND expand(os_idx,1,size(preg_sec_orgs->qual,5),pi.organization_id,preg_sec_orgs->qual[os_idx].
     org_id))
    JOIN (pe
    WHERE pe.pregnancy_id=pi.pregnancy_id
     AND pe.active_ind=1
     AND pe.entered_dt_tm != null)
    JOIN (pr
    WHERE pr.person_id=pe.author_id)
    JOIN (lt
    WHERE lt.parent_entity_name=outerjoin("PREGNANCY_ESTIMATE")
     AND lt.parent_entity_id=outerjoin(pe.pregnancy_estimate_id)
     AND lt.active_ind=outerjoin(1))
  ELSE
   PLAN (pi
    WHERE (pi.person_id=request->person[1].person_id)
     AND pi.active_ind=1
     AND pi.historical_ind=0
     AND pi.preg_end_dt_tm=cnvtdatetime("31-DEC-2100"))
    JOIN (pe
    WHERE pe.pregnancy_id=pi.pregnancy_id
     AND pe.active_ind=1
     AND pe.entered_dt_tm != null)
    JOIN (pr
    WHERE pr.person_id=pe.author_id)
    JOIN (lt
    WHERE lt.parent_entity_name=outerjoin("PREGNANCY_ESTIMATE")
     AND lt.parent_entity_id=outerjoin(pe.pregnancy_estimate_id)
     AND lt.active_ind=outerjoin(1))
  ENDIF
  INTO "nl:"
  confirmation = uar_get_code_display(pe.confirmation_cd), status =
  IF (pe.status_flag=0) cnonauthoritative
  ELSEIF (pe.status_flag=1) cinitial
  ELSEIF (pe.status_flag=2) cauthoritative
  ELSEIF (pe.status_flag=3) cfinal
  ELSEIF (pe.status_flag=4) cinitial_final
  ELSE " "
  ENDIF
  , edd_final_dt = format(pe.est_delivery_dt_tm,"@SHORTDATE4YR"),
  sort =
  IF (pe.status_flag=3) 1
  ELSEIF (pe.status_flag=2) 2
  ELSEIF (pe.status_flag=1) 3
  ELSE 4
  ENDIF
  , ega =
  IF (mod(round(pe.est_gest_age_days,0),7)=0) build(cnvtint(round((pe.est_gest_age_days/ 7),0)),
    cweeks)
  ELSE concat(trim(cnvtstring(cnvtint((pe.est_gest_age_days/ 7)))),cweeks," ",trim(cnvtstring(mod(pe
       .est_gest_age_days,7))),cdays)
  ENDIF
  , method = trim(uar_get_code_display(pe.method_cd)),
  docby = nullterm(pr.name_full_formatted)
  FROM pregnancy_instance pi,
   pregnancy_estimate pe,
   prsnl pr,
   long_text lt
  ORDER BY pe.status_flag DESC, pe.entered_dt_tm DESC
  DETAIL
   gest_age->edd_calc_cnt = (gest_age->edd_calc_cnt+ 1), stat = alterlist(gest_age->edd_calc,gest_age
    ->edd_calc_cnt), gest_age->edd_calc[gest_age->edd_calc_cnt].confirmation = snot_documented,
   gest_age->edd_calc[gest_age->edd_calc_cnt].status = snot_documented, gest_age->edd_calc[gest_age->
   edd_calc_cnt].ega_current = snot_documented, gest_age->edd_calc[gest_age->edd_calc_cnt].method =
   snot_documented,
   gest_age->edd_calc[gest_age->edd_calc_cnt].documented_by = snot_documented, gest_age->edd_calc[
   gest_age->edd_calc_cnt].edd_final = snot_documented, gest_age->edd_calc[gest_age->edd_calc_cnt].
   entry_date = snot_documented,
   gest_age->edd_calc[gest_age->edd_calc_cnt].method_date = snot_documented, gest_age->edd_calc[
   gest_age->edd_calc_cnt].comments = snot_documented, mod_value = pe.descriptor_flag,
   gest_age->edd_calc[gest_age->edd_calc_cnt].edd_final = edd_final_dt, gest_age->edd_calc[gest_age->
   edd_calc_cnt].confirmation = confirmation, gest_age->edd_calc[gest_age->edd_calc_cnt].status =
   status,
   gest_age->edd_calc[gest_age->edd_calc_cnt].ega_current = ega, gest_age->edd_calc[gest_age->
   edd_calc_cnt].method = method
   IF (pe.descriptor_cd > 0)
    gest_age->edd_calc[gest_age->edd_calc_cnt].description = uar_get_code_display(pe.descriptor_cd)
   ELSEIF (pe.descriptor_flag > 0)
    IF (pe.descriptor_txt > " ")
     gest_age->edd_calc[gest_age->edd_calc_cnt].description = concat(gest_age->edd_calc[gest_age->
      edd_calc_cnt].description,trim(pe.descriptor_txt),", ")
    ENDIF
    IF (band(1,pe.descriptor_flag) > 0)
     gest_age->edd_calc[gest_age->edd_calc_cnt].description = concat(gest_age->edd_calc[gest_age->
      edd_calc_cnt].description,cnormalamt,", ")
    ENDIF
    IF (band(2,pe.descriptor_flag) > 0)
     gest_age->edd_calc[gest_age->edd_calc_cnt].description = concat(gest_age->edd_calc[gest_age->
      edd_calc_cnt].description,cabnormalamt,", ")
    ENDIF
    IF (band(4,pe.descriptor_flag) > 0)
     gest_age->edd_calc[gest_age->edd_calc_cnt].description = concat(gest_age->edd_calc[gest_age->
      edd_calc_cnt].description,cdateapproximate,", ")
    ENDIF
    IF (band(8,pe.descriptor_flag) > 0)
     gest_age->edd_calc[gest_age->edd_calc_cnt].description = concat(gest_age->edd_calc[gest_age->
      edd_calc_cnt].description,cdatedefinite,", ")
    ENDIF
    IF (band(16,pe.descriptor_flag) > 0)
     gest_age->edd_calc[gest_age->edd_calc_cnt].description = concat(gest_age->edd_calc[gest_age->
      edd_calc_cnt].description,cdateunknown,", ")
    ENDIF
    IF (size(gest_age->edd_calc[gest_age->edd_calc_cnt].description) > 0)
     gest_age->edd_calc[gest_age->edd_calc_cnt].description = substring(1,(size(gest_age->edd_calc[
       gest_age->edd_calc_cnt].description) - 1),gest_age->edd_calc[gest_age->edd_calc_cnt].
      description)
    ENDIF
   ELSE
    gest_age->edd_calc[gest_age->edd_calc_cnt].description = snot_documented
   ENDIF
   gest_age->edd_calc[gest_age->edd_calc_cnt].documented_by = docby, gest_age->edd_calc[gest_age->
   edd_calc_cnt].entry_date = format(pe.entered_dt_tm,"@SHORTDATE4YR"), gest_age->edd_calc[gest_age->
   edd_calc_cnt].method_date = format(pe.method_dt_tm,"@SHORTDATE4YR")
   IF (lt.long_text_id > 0)
    gest_age->edd_calc[gest_age->edd_calc_cnt].comments = lt.long_text
   ENDIF
  WITH nocounter
 ;end select
 SET g_info->gravida = "0"
 SET g_info->para_details = "0"
 SET g_info->para_full_term = "0"
 SET g_info->para_premature = "0"
 SET g_info->para_abortions = "0"
 SET g_info->para = "0"
 SET g_info->mod_ind = " "
 SELECT INTO "nl:"
  FROM clinical_event ce
  PLAN (ce
   WHERE (ce.person_id=request->person[1].person_id)
    AND ce.event_cd IN (gravida, para_details, para_full_term, para_premature, para_abortions,
   para_living)
    AND ce.result_status_cd IN (auth, altered, modified)
    AND ce.event_tag != "Date\Time Correction"
    AND ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime3))
  ORDER BY ce.event_cd, ce.event_end_dt_tm DESC
  HEAD REPORT
   g_info->gravida = "0", g_info->para_details = "0", g_info->para_full_term = "0",
   g_info->para_premature = "0", g_info->para_abortions = "0", g_info->para = "0",
   g_info->mod_ind = " "
  HEAD ce.event_cd
   g_info->mod_ind = " "
   CASE (ce.event_cd)
    OF gravida:
     g_info->gravida = trim(ce.result_val),
     IF (ce.result_status_cd=modified)
      g_info->mod_ind = modifiedcaption
     ENDIF
    OF para_details:
     g_info->para_details = trim(ce.result_val),
     IF (ce.result_status_cd=modified)
      g_info->mod_ind = modifiedcaption
     ENDIF
    OF para_full_term:
     g_info->para_full_term = trim(ce.result_val),
     IF (ce.result_status_cd=modified)
      g_info->mod_ind = modifiedcaption
     ENDIF
    OF para_premature:
     g_info->para_premature = trim(ce.result_val),
     IF (ce.result_status_cd=modified)
      g_info->mod_ind = modifiedcaption
     ENDIF
    OF para_abortions:
     g_info->para_abortions = trim(ce.result_val),
     IF (ce.result_status_cd=modified)
      g_info->mod_ind = modifiedcaption
     ENDIF
    OF para_living:
     g_info->para = trim(ce.result_val),
     IF (ce.result_status_cd=modified)
      g_info->mod_ind = modifiedcaption
     ENDIF
   ENDCASE
  WITH nocounter
 ;end select
 IF (validate(debug_ind,0)=1)
  CALL echorecord(gest_age)
 ENDIF
 IF (stand_alone_ind=1)
  SET reply->text = concat(reply->text,rhead,rhead_colors1,rhead_colors2,rhead_colors3)
  IF (honor_org_security_flag=1)
   SET reply->text = concat(reply->text,rtab,wu,whsecuritydisclaim,wr,
    reol)
  ENDIF
 ENDIF
 SET reply->text = concat(reply->text,"\tx1450\tx3200\tx5000\tx6500",rsechead,colornavy,
  captions_title,
  wsd,colorgrey,cdisclaimer," ",format(cnvtdatetime(curdate,curtime3),"@SHORTDATE4YR"),
  wr,reol)
 IF (size(gest_age->edd_calc,5)=0)
  SET reply->text = concat(reply->text,rpard,rtabstopnd,wr,reol,
   rtab,cnodata,reol)
  GO TO exit_script
 ELSE
  SET reply->text = concat(reply->text,reol)
  FOR (i = 1 TO size(gest_age->edd_calc,5))
    SET pt->line_cnt = 0
    SET stat = alterlist(pt->lns,0)
    EXECUTE dcp_parse_text value(gest_age->edd_calc[i].comments), value(max_length)
    SET stat = alterlist(gest_age->edd_calc[i].comments_wrapped,pt->line_cnt)
    FOR (wrapcnt = 1 TO pt->line_cnt)
      SET gest_age->edd_calc[i].comments_wrapped[wrapcnt].wrap_text = pt->lns[wrapcnt].line
    ENDFOR
    FOR (z = 1 TO size(gest_age->edd_calc[i].comments_wrapped,5))
      IF (z=1)
       SET gest_age->edd_calc[i].comments = gest_age->edd_calc[i].comments_wrapped[z].wrap_text
      ELSE
       SET gest_age->edd_calc[i].comments = concat(gest_age->edd_calc[i].comments,reol,space_comments,
        gest_age->edd_calc[i].comments_wrapped[z].wrap_text)
      ENDIF
    ENDFOR
  ENDFOR
  SET reply->text = concat(reply->text,wr,colorgrey,captions_edd_final," ",
   wr,gest_age->edd_calc[1].edd_final,rtab,wr,colorgrey,
   captions_ega," ",wr,pt_info->ega,"            ",
   rsechead,colornavy,"Pregnancy History",wr,"    ",
   wb18,"G",g_info->gravida," P",g_info->para_details,
   "(",g_info->para_full_term,",",g_info->para_premature,",",
   g_info->para_abortions,",",g_info->para,")",wsd,
   "     ",colorgrey,wr,reol,reol,
   space,wr,colorgrey,captions_method," ",
   wr,gest_age->edd_calc[1].method,wsd,colorgrey," (",
   gest_age->edd_calc[1].method_date,")",reol)
 ENDIF
 GO TO exit_script
#no_data
 IF ((request->person_cnt > 0)
  AND (request->visit_cnt > 0)
  AND (request->prsnl_cnt > 0))
  SET reply->text = concat(reply->text,rhead,wr,cpnodata,reol)
 ELSE
  SET reply->text = concat(reply->text,rhead,wbuf26,cpgatitle,wr,
   reol,reol,cpnodata,reol)
 ENDIF
 GO TO exit_script
#exit_script
 IF (stand_alone_ind=1)
  SET reply->text = concat(reply->text,rtfeof)
 ENDIF
 SET script_version = "000"
END GO
