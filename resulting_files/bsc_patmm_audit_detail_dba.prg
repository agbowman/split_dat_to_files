CREATE PROGRAM bsc_patmm_audit_detail:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Starting date:" = "CURDATE",
  "Ending date:" = "CURDATE",
  "Facility:" = 0,
  "Nurse unit(s):" = 0,
  "Display per:" = 2
  WITH out_dev, start_date, end_date,
  facility, nurse_unit, display_type
 SET modify = predeclare
 DECLARE butcind = i2 WITH protect, constant(curutc)
 DECLARE ctime_zone_format = vc WITH protect, constant("ZZZ")
 SUBROUTINE (parsezeroes(pass_field_in=f8) =vc)
   DECLARE dsvalue = c16 WITH noconstant(fillstring(16," "))
   DECLARE move_fld = c16 WITH noconstant(fillstring(16," "))
   DECLARE strfld = c16 WITH noconstant(fillstring(16," "))
   DECLARE sig_dig = i4 WITH noconstant(0)
   DECLARE sig_dec = i4 WITH noconstant(0)
   DECLARE str_cnt = i4 WITH noconstant(1)
   DECLARE len = i4 WITH noconstant(0)
   SET strfld = cnvtstring(pass_field_in,16,4,r)
   WHILE (str_cnt < 12
    AND substring(str_cnt,1,strfld) IN ("0", " "))
     SET str_cnt += 1
   ENDWHILE
   SET sig_dig = (str_cnt - 1)
   SET str_cnt = 16
   WHILE (str_cnt > 12
    AND substring(str_cnt,1,strfld) IN ("0", " "))
     SET str_cnt -= 1
   ENDWHILE
   IF (str_cnt=12
    AND substring(str_cnt,1,strfld)=".")
    SET str_cnt -= 1
   ENDIF
   SET sig_dec = str_cnt
   IF (sig_dig=11
    AND sig_dec=11)
    SET dsvalue = ""
   ELSE
    SET len = movestring(strfld,(sig_dig+ 1),move_fld,1,(sig_dec - sig_dig))
    SET dsvalue = trim(move_fld)
    IF (substring(1,1,dsvalue)=".")
     SET dsvalue = concat("0",trim(move_fld))
    ENDIF
   ENDIF
   RETURN(dsvalue)
 END ;Subroutine
 SUBROUTINE (formatutcdatetime(sdatetime=vc,ltzindex=i4,bshowtz=i2) =vc)
   DECLARE lnewindex = i4 WITH protect, noconstant(curtimezoneapp)
   DECLARE snewdatetime = vc WITH protect, noconstant(" ")
   IF (ltzindex > 0)
    SET lnewindex = ltzindex
   ENDIF
   SET snewdatetime = datetimezoneformat(sdatetime,lnewindex,"@SHORTDATE")
   IF (size(trim(snewdatetime)) > 0)
    SET snewdatetime = concat(snewdatetime," ",datetimezoneformat(sdatetime,lnewindex,
      "@TIMENOSECONDS"))
    IF (butcind=1
     AND bshowtz=1)
     SET snewdatetime = concat(snewdatetime," ",datetimezoneformat(sdatetime,lnewindex,
       ctime_zone_format))
    ENDIF
   ENDIF
   SET snewdatetime = trim(snewdatetime)
   RETURN(snewdatetime)
 END ;Subroutine
 SUBROUTINE (formatlabelbylength(slabel=vc,lmaxlen=i4) =vc)
   DECLARE snewlabel = vc WITH protect, noconstant("")
   SET snewlabel = trim(slabel,3)
   IF (size(snewlabel) > 0
    AND lmaxlen > 0)
    IF (lmaxlen < 4)
     SET snewlabel = substring(1,lmaxlen,snewlabel)
    ELSEIF (size(snewlabel) > lmaxlen)
     SET snewlabel = concat(substring(1,(lmaxlen - 3),snewlabel),"...")
    ENDIF
   ENDIF
   RETURN(snewlabel)
 END ;Subroutine
 SUBROUTINE (formatstrength(dstrength=f8) =vc)
   DECLARE snewlabel = vc WITH protect, noconstant("")
   SET snewlabel = nullterm(trim(format(dstrength,"######.####;It(1);F"),3))
   RETURN(snewlabel)
 END ;Subroutine
 SUBROUTINE (formatvolume(dvolume=f8) =vc)
   DECLARE snewlabel = vc WITH protect, noconstant("")
   SET snewlabel = nullterm(trim(format(dvolume,"######.##;It(1);F"),3))
   RETURN(snewlabel)
 END ;Subroutine
 SUBROUTINE (formatrate(drate=f8) =vc)
   DECLARE snewlabel = vc WITH protect, noconstant("")
   SET snewlabel = nullterm(trim(format(drate,"######.####;It(1);F"),3))
   RETURN(snewlabel)
 END ;Subroutine
 SUBROUTINE (formatpercentwithdecimal(dpercent=f8) =vc)
   DECLARE snewlabel = vc WITH protect, noconstant("")
   SET snewlabel = nullterm(format(dpercent,"###.##;I;F"))
   RETURN(snewlabel)
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
 DECLARE i18nhandle = i4 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 SET stat = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 DECLARE i18n_sdaterange = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_DATE_RANGE","Date Range"),3))
 DECLARE i18n_spage = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_PAGE","Page"
    ),3))
 DECLARE i18n_sfacility = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_FACILITY","Facility"),3))
 DECLARE i18n_srundatetime = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_RUN_DATE","Run Date/Time"),3))
 DECLARE i18n_snurseunit = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_NURSE_UNIT","Nurse Unit"),3))
 DECLARE i18n_snurseunits = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_NURSE_UNITS","Nurse Units"),3))
 DECLARE i18n_sall = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_ALL","All"),3
   ))
 DECLARE i18n_sunknownerror = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_UNKNOWN_ERROR","Unknown/Error"),3))
 DECLARE i18n_stitle = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_TITLE",
    "Point of Care Audit Patient Mismatch Report"),3))
 DECLARE i18n_sdisplayper = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_DISPLAY_PER","Display per"),3))
 DECLARE i18n_sexpectedpatient = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_EXPECTED_PATIENT","Expected Patient"),3))
 DECLARE i18n_slegend = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_LEGEND",
    "Legend"),3))
 DECLARE i18n_spos = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_POS","Pos"),3
   ))
 DECLARE i18n_sposition = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_POSITION","Position"),3))
 DECLARE i18n_salert = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_ALERT",
    "Alert"),3))
 DECLARE i18n_sexpected = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_EXPECTED","Expected"),3))
 DECLARE i18n_snurse = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_NURSE",
    "Nurse"),3))
 DECLARE i18n_sidentified = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_IDENTIFIED","Identified"),3))
 DECLARE i18n_suser = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_USER","User"
    ),3))
 DECLARE i18n_sdatetime = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_DATE_TIME","Date/Time"),3))
 DECLARE i18n_spatientname = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_PATIENTNAME","Patient Name"),3))
 DECLARE i18n_smrn = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_MRN","MRN"),3
   ))
 DECLARE i18n_sunit = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_UNIT","Unit"
    ),3))
 DECLARE i18n_sname = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_NAME","Name"
    ),3))
 DECLARE i18n_stotalalerts = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_TOTAL_ALERTS","Total Alerts"),3))
 DECLARE i18n_snoresultsqualified = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_NO_RESULTS_QUALIFIED","No Results Qualified"),3))
 DECLARE i18n_smedname = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_MED_NAME",
    "Med Name"),3))
 DECLARE i18n_salertdatetime = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_ALERT_DTTM","Alert date/time"),3))
 DECLARE i18n_sexppatname = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_EXP_PATNAME","Expected Patient Name"),3))
 DECLARE i18n_sexpmrn = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_EXP_MRN",
    "Expected MRN"),3))
 DECLARE i18n_sidentpatname = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_IDENT_PATNAME","Identified Patient Name"),3))
 DECLARE i18n_sidentmrn = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_IDENT_MRN","Identified MRN"),3))
 DECLARE i18n_sfrom = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_FROM","From"
    ),3))
 DECLARE i18n_sto = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_TO","To"),3))
 FREE RECORD audit_request
 RECORD audit_request(
   1 report_name = vc
   1 start_dt_tm = dq8
   1 end_dt_tm = dq8
   1 facility_cd = f8
   1 unit_cnt = i4
   1 unit[*]
     2 nurse_unit_cd = f8
   1 display_ind = i2
 )
 DECLARE llastcolumn = i4 WITH protect, constant(140)
 DECLARE cdashline = vc WITH protect, constant(fillstring(140,"-"))
 DECLARE ctotal_line = vc WITH protect, constant(fillstring(139,"-"))
 DECLARE cpatmismatch = f8 WITH protect, constant(uar_get_code_by("MEANING",4000040,"PATMISMATCH"))
 DECLARE cpatmrn = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"MRN"))
 DECLARE coutput = vc WITH protect, noconstant(concat("patmismtch",cnvtstring(cnvtdatetime(sysdate)),
   ".csv"))
 DECLARE from_dt_tm = dq8 WITH protect, noconstant(cnvtdatetime(sysdate))
 DECLARE to_dt_tm = dq8 WITH protect, noconstant(cnvtdatetime(sysdate))
 DECLARE last_mod = vc WITH protect, noconstant("")
 DECLARE mod_date = vc WITH protect, noconstant("")
 DECLARE expectedname = vc WITH protect, noconstant("")
 DECLARE identifiedname = vc WITH protect, noconstant("")
 DECLARE alert = vc WITH protect, noconstant("")
 DECLARE username = vc WITH protect, noconstant("")
 DECLARE position = vc WITH protect, noconstant("")
 DECLARE nurseunit = vc WITH protect, noconstant("")
 DECLARE expectedmrn = vc WITH protect, noconstant("")
 DECLARE identifiedmrn = vc WITH protect, noconstant("")
 DECLARE smedname = vc WITH protect, noconstant("")
 DECLARE snurse_units = vc WITH protect, noconstant("")
 DECLARE nallind = i2 WITH protect, noconstant(0)
 DECLARE dstat = f8 WITH protect, noconstant(0.00)
 DECLARE lcnt = i4 WITH protect, noconstant(0)
 DECLARE lcnt2 = i4 WITH protect, noconstant(0)
 DECLARE snua_clause = vc WITH protect, noconstant("1=1")
 DECLARE snue_clause = vc WITH protect, noconstant("1=1")
 DECLARE sdisplay = vc WITH protect, noconstant("")
 DECLARE lprintpos = i4 WITH protect, noconstant(0)
 DECLARE lnurse_units_length = i4 WITH protect, noconstant(0)
 DECLARE lmin_col_length = i4 WITH protect, noconstant(2000)
 SET audit_request->report_name = "BSC_PATMISMATCH_AUDIT_DETAIL"
 IF (( $START_DATE="CURDATE"))
  SET audit_request->start_dt_tm = cnvtdatetime(curdate,0)
 ELSE
  SET audit_request->start_dt_tm = cnvtdatetime(cnvtdate(cnvtalphanum( $START_DATE)),0)
 ENDIF
 IF (( $END_DATE="CURDATE"))
  SET audit_request->end_dt_tm = cnvtdatetime(curdate,235959)
 ELSE
  SET audit_request->end_dt_tm = cnvtdatetime(cnvtdate(cnvtalphanum( $END_DATE)),235959)
 ENDIF
 SET audit_request->facility_cd =  $FACILITY
 IF (substring(1,1,reflect(parameter(5,0)))="I")
  IF (( $NURSE_UNIT=0))
   SET nallind = 1
  ENDIF
 ELSEIF (substring(1,1,reflect(parameter(5,0)))="C")
  IF (( $NURSE_UNIT="*"))
   SET nallind = 1
  ENDIF
 ENDIF
 IF (nallind=1
  AND ( $FACILITY > 0))
  SELECT INTO "nl:"
   FROM code_value cv,
    location_group lg1,
    location_group lg2
   PLAN (cv
    WHERE cv.code_set=220
     AND cv.cdf_meaning IN ("AMBULATORY", "NURSEUNIT")
     AND cv.active_ind=1)
    JOIN (lg1
    WHERE lg1.child_loc_cd=cv.code_value
     AND lg1.root_loc_cd=0)
    JOIN (lg2
    WHERE lg2.child_loc_cd=lg1.parent_loc_cd
     AND lg2.root_loc_cd=0
     AND (lg2.parent_loc_cd= $FACILITY))
   ORDER BY cv.display
   HEAD REPORT
    lcnt = 0
   DETAIL
    lcnt += 1
    IF (mod(lcnt,10)=1)
     dstat = alterlist(audit_request->unit,(lcnt+ 9))
    ENDIF
    audit_request->unit[lcnt].nurse_unit_cd = cv.code_value
   FOOT REPORT
    dstat = alterlist(audit_request->unit,lcnt), audit_request->unit_cnt = lcnt
   WITH nocounter
  ;end select
  SET lcnt2 = 0
  WHILE (lcnt2 < lcnt)
    SET lcnt2 += 1
    IF (lcnt2=1)
     SET snue_clause = build("mae.nurse_unit_cd in(",audit_request->unit[lcnt2].nurse_unit_cd)
     SET snua_clause = build("maa.nurse_unit_cd in(",audit_request->unit[lcnt2].nurse_unit_cd)
     SET snurse_units = uar_get_code_display(audit_request->unit[lcnt2].nurse_unit_cd)
    ELSE
     SET snue_clause = build(snue_clause,",",audit_request->unit[lcnt2].nurse_unit_cd)
     SET snua_clause = build(snua_clause,",",audit_request->unit[lcnt2].nurse_unit_cd)
     SET snurse_units = build(snurse_units,"/",uar_get_code_display(audit_request->unit[lcnt2].
       nurse_unit_cd))
    ENDIF
    IF (lcnt2=lcnt)
     SET snue_clause = build(snue_clause,")")
     SET snua_clause = build(snua_clause,")")
    ENDIF
  ENDWHILE
 ELSE
  SELECT INTO "nl:"
   FROM code_value cv
   PLAN (cv
    WHERE cv.code_value IN ( $NURSE_UNIT))
   ORDER BY cv.display
   HEAD REPORT
    lcnt = 0
   DETAIL
    lcnt += 1
    IF (mod(lcnt,10)=1)
     dstat = alterlist(audit_request->unit,(lcnt+ 9))
    ENDIF
    audit_request->unit[lcnt].nurse_unit_cd = cv.code_value
   FOOT REPORT
    dstat = alterlist(audit_request->unit,lcnt), audit_request->unit_cnt = lcnt
   WITH nocounter
  ;end select
  SET lcnt2 = 0
  WHILE (lcnt2 < lcnt)
    SET lcnt2 += 1
    IF (lcnt2=1)
     SET snue_clause = build("mae.nurse_unit_cd in(",audit_request->unit[lcnt2].nurse_unit_cd)
     SET snua_clause = build("maa.nurse_unit_cd in(",audit_request->unit[lcnt2].nurse_unit_cd)
     SET snurse_units = uar_get_code_display(audit_request->unit[lcnt2].nurse_unit_cd)
    ELSE
     SET snue_clause = build(snue_clause,",",audit_request->unit[lcnt2].nurse_unit_cd)
     SET snua_clause = build(snua_clause,",",audit_request->unit[lcnt2].nurse_unit_cd)
     SET snurse_units = build(snurse_units,"/",uar_get_code_display(audit_request->unit[lcnt2].
       nurse_unit_cd))
    ENDIF
    IF (lcnt2=lcnt)
     SET snue_clause = build(snue_clause,")")
     SET snua_clause = build(snua_clause,")")
    ENDIF
  ENDWHILE
 ENDIF
 SET audit_request->display_ind =  $DISPLAY_TYPE
 IF ((audit_request->display_ind=2))
  SELECT INTO  $OUT_DEV
   FROM med_admin_alert maa,
    med_admin_pt_error mape,
    prsnl p,
    med_admin_event mae,
    orders o,
    person pers1,
    person pers2,
    person_alias pa,
    person_alias pa1,
    org_alias_pool_reltn oap,
    location l,
    dummyt d,
    dummyt d1
   PLAN (maa
    WHERE maa.alert_type_cd IN (cpatmismatch)
     AND maa.event_dt_tm BETWEEN cnvtdatetime(audit_request->start_dt_tm) AND cnvtdatetime(
     audit_request->end_dt_tm)
     AND maa.nurse_unit_cd > 0.00
     AND parser(snua_clause))
    JOIN (l
    WHERE l.location_cd=maa.nurse_unit_cd)
    JOIN (oap
    WHERE oap.organization_id=l.organization_id
     AND oap.alias_entity_name="PERSON_ALIAS"
     AND oap.alias_entity_alias_type_cd=cpatmrn)
    JOIN (p
    WHERE p.person_id=maa.prsnl_id)
    JOIN (mae
    WHERE (mae.med_admin_event_id= Outerjoin(maa.med_admin_event_id)) )
    JOIN (o
    WHERE (o.order_id= Outerjoin(mae.order_id)) )
    JOIN (mape
    WHERE mape.med_admin_alert_id=maa.med_admin_alert_id)
    JOIN (pers1
    WHERE pers1.person_id=mape.expected_pt_id)
    JOIN (d1)
    JOIN (pa
    WHERE pa.person_id=pers1.person_id
     AND pa.person_alias_type_cd=cpatmrn
     AND pa.alias_pool_cd=oap.alias_pool_cd
     AND pa.alias_pool_cd > 0.0)
    JOIN (pers2
    WHERE pers2.person_id=mape.identified_pt_id)
    JOIN (d)
    JOIN (pa1
    WHERE pa1.person_id=pers2.person_id
     AND pa1.person_alias_type_cd=cpatmrn
     AND pa1.alias_pool_cd=oap.alias_pool_cd
     AND pa1.alias_pool_cd > 0.0)
   ORDER BY pers1.name_last_key, pers1.name_first_key, pers1.person_id,
    cnvtdatetime(maa.event_dt_tm), maa.prsnl_id, mape.med_admin_pt_error_id
   HEAD REPORT
    col + 0, totalalert = 0
   HEAD PAGE
    IF ( NOT (( $OUT_DEV IN ("MINE"))))
     col 00, "{ps/792 0 translate 90 rotate/}{pos/000/000}{f/1/0}{lpi/6}{cpi/13}", row + 1
    ENDIF
    CALL center(i18n_stitle,1,llastcolumn), row + 1, sdisplay = concat(i18n_sdaterange,":"),
    col 00, sdisplay, lprintpos = (size(sdisplay)+ 1),
    sdisplay = ""
    IF ((audit_request->start_dt_tm > 0))
     sdisplay = format(audit_request->start_dt_tm,"@SHORTDATE;;Q")
    ENDIF
    IF ((audit_request->end_dt_tm > 0))
     sdisplay = build2(sdisplay," - ",format(audit_request->end_dt_tm,"@SHORTDATE;;Q"))
    ENDIF
    IF (textlen(sdisplay) > 0)
     col lprintpos, sdisplay
    ENDIF
    sdisplay = concat(i18n_spage,": ",cnvtstring(curpage)), lprintpos = (llastcolumn - size(sdisplay)
    ), col lprintpos,
    sdisplay, row + 1, sdisplay = concat(i18n_sfacility,": ",trim(uar_get_code_display(cnvtreal(
         $FACILITY)),3)),
    col 00, sdisplay, sdisplay = concat(i18n_srundatetime,": ",format(cnvtdatetime(sysdate),
      "@SHORTDATE;;Q")," ",format(cnvtdatetime(sysdate),"@TIMENOSECONDS")),
    lprintpos = (llastcolumn - size(sdisplay)), col lprintpos, sdisplay,
    row + 1, sdisplay = concat(i18n_sdisplayper,": ",i18n_sexpectedpatient), lprintpos = (llastcolumn
     - size(sdisplay)),
    col lprintpos, sdisplay, lnewline = (lprintpos - 20),
    sdisplay = ""
    IF (nallind=1)
     sdisplay = concat(i18n_snurseunits,": ",i18n_sall), col 00, sdisplay
    ELSEIF ((audit_request->unit_cnt > 1))
     sdisplay = concat(i18n_snurseunits,": ",trim(uar_get_code_display(audit_request->unit[1].
        nurse_unit_cd),3),","), col 00, sdisplay,
     lprintpos = (size(sdisplay)+ 1)
     IF (lprintpos > lnewline)
      row + 1, lprintpos = (size(i18n_snurseunits)+ 2)
     ENDIF
     FOR (lcnt = 2 TO audit_request->unit_cnt)
       sdisplay = trim(uar_get_code_display(audit_request->unit[lcnt].nurse_unit_cd),3)
       IF ((lcnt != audit_request->unit_cnt))
        sdisplay = concat(sdisplay,",")
       ENDIF
       IF (((lprintpos+ size(sdisplay)) > lnewline))
        row + 1, lprintpos = (size(i18n_snurseunits)+ 2)
       ENDIF
       col lprintpos, sdisplay, lprintpos = ((lprintpos+ size(sdisplay))+ 1)
     ENDFOR
    ELSEIF ((audit_request->unit_cnt=1))
     sdisplay = concat(i18n_snurseunit,": ",trim(uar_get_code_display(audit_request->unit[1].
        nurse_unit_cd),3)), col 00, sdisplay
    ELSE
     sdisplay = concat(i18n_snurseunits,": ",i18n_sunknownerror), col 00, sdisplay
    ENDIF
    row + 1, col 00, cdashline,
    row + 1, sdisplay = concat(i18n_slegend," (",i18n_spos," = ",i18n_sposition,
     ")"), col 00,
    sdisplay, row + 1, sdisplay = formatlabelbylength(i18n_salert,14),
    col 00, sdisplay, sdisplay = formatlabelbylength(i18n_sexpected,16),
    col 15, sdisplay, sdisplay = formatlabelbylength(i18n_sexpected,15),
    col 32, sdisplay, sdisplay = formatlabelbylength(i18n_snurse,15),
    col 48, sdisplay, sdisplay = formatlabelbylength(i18n_sidentified,16),
    col 64, sdisplay, sdisplay = formatlabelbylength(i18n_sidentified,15),
    col 81, sdisplay, sdisplay = formatlabelbylength(i18n_suser,16),
    col 97, sdisplay, row + 1,
    sdisplay = formatlabelbylength(i18n_sdatetime,14), col 00, sdisplay,
    sdisplay = formatlabelbylength(i18n_spatientname,16), col 15, sdisplay,
    sdisplay = formatlabelbylength(i18n_smrn,15), col 32, sdisplay,
    sdisplay = formatlabelbylength(i18n_sunit,15), col 48, sdisplay,
    sdisplay = formatlabelbylength(i18n_spatientname,16), col 64, sdisplay,
    sdisplay = formatlabelbylength(i18n_smrn,15), col 81, sdisplay,
    sdisplay = formatlabelbylength(i18n_sname,16), col 97, sdisplay,
    sdisplay = formatlabelbylength(i18n_spos,5), col 114, sdisplay,
    sdisplay = formatlabelbylength(i18n_smedname,20), col 120, sdisplay,
    row + 1, col 00, ctotal_line,
    row + 1
   HEAD mape.med_admin_pt_error_id
    col + 0, expectedmrn = "", identifiedmrn = ""
   DETAIL
    x = 0
    IF (pa.alias_pool_cd > 0.0)
     expectedmrn = cnvtalias(pa.alias,pa.alias_pool_cd)
    ENDIF
    IF (pa1.alias_pool_cd > 0.0)
     identifiedmrn = cnvtalias(pa1.alias,pa1.alias_pool_cd)
    ELSE
     identifiedmrn = "--"
    ENDIF
   FOOT  mape.med_admin_pt_error_id
    IF (row=42)
     BREAK
    ENDIF
    expectedname = "", identifiedname = "", alert = "",
    username = "", position = "", nurseunit = "",
    smedname = "", totalalert += 1, alert = uar_get_code_display(maa.alert_type_cd),
    alert_time = formatutcdatetime(maa.event_dt_tm,0,0), expectedname = trim(replace(pers1
      .name_full_formatted,",","-",0),3), identifiedname = trim(replace(pers2.name_full_formatted,",",
      "-",0),3),
    username = trim(replace(p.name_full_formatted,",","-",0),3), position = uar_get_code_display(maa
     .position_cd), nurseunit = trim(replace(uar_get_code_display(maa.nurse_unit_cd),","," ",0),3),
    smedname = trim(o.order_mnemonic,3)
    IF (identifiedname="")
     identifiedname = "--"
    ENDIF
    sdisplay = formatlabelbylength(alert_time,14), col 00, sdisplay,
    sdisplay = formatlabelbylength(expectedname,16), col 15, sdisplay,
    sdisplay = formatlabelbylength(expectedmrn,15), col 32, sdisplay,
    sdisplay = formatlabelbylength(nurseunit,15), col 48, sdisplay,
    sdisplay = formatlabelbylength(identifiedname,16), col 64, sdisplay,
    sdisplay = formatlabelbylength(identifiedmrn,15), col 81, sdisplay,
    sdisplay = formatlabelbylength(username,16), col 97, sdisplay,
    sdisplay = formatlabelbylength(position,5), col 114, sdisplay,
    sdisplay = formatlabelbylength(smedname,20), col 120, sdisplay,
    row + 1
   FOOT PAGE
    col 0, i18n_spage, ": ",
    curpage
   FOOT REPORT
    row + 1, col 00, i18n_stotalalerts,
    ": ", totalalert, row + 1
   WITH nocounter, outerjoin = d, outerjoin = d1,
    dio = postscript, maxrow = 45, maxcol = 141
  ;end select
 ELSEIF ((audit_request->display_ind=0))
  SELECT INTO  $OUT_DEV
   FROM med_admin_alert maa,
    med_admin_pt_error mape,
    prsnl p,
    med_admin_event mae,
    orders o,
    person pers1,
    person pers2,
    person_alias pa,
    person_alias pa1,
    org_alias_pool_reltn oap,
    location l,
    dummyt d,
    dummyt d1
   PLAN (maa
    WHERE maa.alert_type_cd IN (cpatmismatch)
     AND maa.event_dt_tm BETWEEN cnvtdatetime(audit_request->start_dt_tm) AND cnvtdatetime(
     audit_request->end_dt_tm)
     AND maa.nurse_unit_cd > 0.00
     AND parser(snua_clause))
    JOIN (l
    WHERE l.location_cd=maa.nurse_unit_cd)
    JOIN (oap
    WHERE oap.organization_id=l.organization_id
     AND oap.alias_entity_name="PERSON_ALIAS"
     AND oap.alias_entity_alias_type_cd=cpatmrn)
    JOIN (p
    WHERE p.person_id=maa.prsnl_id)
    JOIN (mae
    WHERE (mae.med_admin_event_id= Outerjoin(maa.med_admin_event_id)) )
    JOIN (o
    WHERE (o.order_id= Outerjoin(mae.order_id)) )
    JOIN (mape
    WHERE mape.med_admin_alert_id=maa.med_admin_alert_id)
    JOIN (pers1
    WHERE pers1.person_id=mape.expected_pt_id)
    JOIN (d1)
    JOIN (pa
    WHERE pa.person_id=pers1.person_id
     AND pa.person_alias_type_cd=cpatmrn
     AND pa.alias_pool_cd=oap.alias_pool_cd
     AND pa.alias_pool_cd > 0.0)
    JOIN (pers2
    WHERE pers2.person_id=mape.identified_pt_id)
    JOIN (d)
    JOIN (pa1
    WHERE pa1.person_id=pers2.person_id
     AND pa1.person_alias_type_cd=cpatmrn
     AND pa1.alias_pool_cd=oap.alias_pool_cd
     AND pa1.alias_pool_cd > 0.0)
   ORDER BY p.name_last_key, p.name_first_key, p.person_id,
    cnvtdatetime(maa.event_dt_tm), maa.prsnl_id, mape.med_admin_pt_error_id
   HEAD REPORT
    col + 0, totalalert = 0
   HEAD PAGE
    IF ( NOT (( $OUT_DEV IN ("MINE"))))
     col 00, "{ps/792 0 translate 90 rotate/}{pos/000/000}{f/1/0}{lpi/6}{cpi/13}", row + 1
    ENDIF
    CALL center(i18n_stitle,1,llastcolumn), row + 1, sdisplay = concat(i18n_sdaterange,":"),
    col 00, sdisplay, lprintpos = (size(sdisplay)+ 1),
    sdisplay = ""
    IF ((audit_request->start_dt_tm > 0))
     sdisplay = format(audit_request->start_dt_tm,"@SHORTDATE;;Q")
    ENDIF
    IF ((audit_request->end_dt_tm > 0))
     sdisplay = build2(sdisplay," - ",format(audit_request->end_dt_tm,"@SHORTDATE;;Q"))
    ENDIF
    IF (textlen(sdisplay) > 0)
     col lprintpos, sdisplay
    ENDIF
    sdisplay = concat(i18n_spage,": ",cnvtstring(curpage)), lprintpos = (llastcolumn - size(sdisplay)
    ), col lprintpos,
    sdisplay, row + 1, sdisplay = concat(i18n_sfacility,": ",trim(uar_get_code_display(cnvtreal(
         $FACILITY)),3)),
    col 00, sdisplay, sdisplay = concat(i18n_srundatetime,": ",format(cnvtdatetime(sysdate),
      "@SHORTDATE;;Q")," ",format(cnvtdatetime(sysdate),"@TIMENOSECONDS")),
    lprintpos = (llastcolumn - size(sdisplay)), col lprintpos, sdisplay,
    row + 1, sdisplay = concat(i18n_sdisplayper,": ",i18n_suser), lprintpos = (llastcolumn - size(
     sdisplay)),
    col lprintpos, sdisplay, lnewline = (lprintpos - 20),
    sdisplay = ""
    IF (nallind=1)
     sdisplay = concat(i18n_snurseunits,": ",i18n_sall), col 00, sdisplay
    ELSEIF ((audit_request->unit_cnt > 1))
     sdisplay = concat(i18n_snurseunits,": ",trim(uar_get_code_display(audit_request->unit[1].
        nurse_unit_cd),3),","), col 00, sdisplay,
     lprintpos = (size(sdisplay)+ 1)
     IF (lprintpos > lnewline)
      row + 1, lprintpos = (size(i18n_snurseunits)+ 2)
     ENDIF
     FOR (lcnt = 2 TO audit_request->unit_cnt)
       sdisplay = trim(uar_get_code_display(audit_request->unit[lcnt].nurse_unit_cd),3)
       IF ((lcnt != audit_request->unit_cnt))
        sdisplay = concat(sdisplay,",")
       ENDIF
       IF (((lprintpos+ size(sdisplay)) > lnewline))
        row + 1, lprintpos = (size(i18n_snurseunits)+ 2)
       ENDIF
       col lprintpos, sdisplay, lprintpos = ((lprintpos+ size(sdisplay))+ 1)
     ENDFOR
    ELSEIF ((audit_request->unit_cnt=1))
     sdisplay = concat(i18n_snurseunit,": ",trim(uar_get_code_display(audit_request->unit[1].
        nurse_unit_cd),3)), col 00, sdisplay
    ELSE
     sdisplay = concat(i18n_snurseunits,": ",i18n_sunknownerror), col 00, sdisplay
    ENDIF
    row + 1, col 00, cdashline,
    row + 1, sdisplay = concat(i18n_slegend," (",i18n_spos," = ",i18n_sposition,
     ")"), col 00,
    sdisplay, row + 1, sdisplay = formatlabelbylength(i18n_suser,16),
    col 00, sdisplay, sdisplay = formatlabelbylength(i18n_salert,14),
    col 17, sdisplay, sdisplay = formatlabelbylength(i18n_sexpected,16),
    col 32, sdisplay, sdisplay = formatlabelbylength(i18n_sexpected,15),
    col 49, sdisplay, sdisplay = formatlabelbylength(i18n_snurse,15),
    col 65, sdisplay, sdisplay = formatlabelbylength(i18n_sidentified,16),
    col 81, sdisplay, sdisplay = formatlabelbylength(i18n_sidentified,15),
    col 98, sdisplay, row + 1,
    sdisplay = formatlabelbylength(i18n_sname,16), col 00, sdisplay,
    sdisplay = formatlabelbylength(i18n_sdatetime,14), col 17, sdisplay,
    sdisplay = formatlabelbylength(i18n_spatientname,16), col 32, sdisplay,
    sdisplay = formatlabelbylength(i18n_smrn,15), col 49, sdisplay,
    sdisplay = formatlabelbylength(i18n_sunit,15), col 65, sdisplay,
    sdisplay = formatlabelbylength(i18n_spatientname,16), col 81, sdisplay,
    sdisplay = formatlabelbylength(i18n_smrn,15), col 98, sdisplay,
    sdisplay = formatlabelbylength(i18n_spos,5), col 114, sdisplay,
    sdisplay = formatlabelbylength(i18n_smedname,20), col 120, sdisplay,
    row + 1, col 00, ctotal_line,
    row + 1
   HEAD mape.med_admin_pt_error_id
    col + 0, expectedmrn = "", identifiedmrn = ""
   DETAIL
    x = 0
    IF (pa.alias_pool_cd > 0.0)
     expectedmrn = cnvtalias(pa.alias,pa.alias_pool_cd)
    ENDIF
    IF (pa1.alias_pool_cd > 0.0)
     identifiedmrn = cnvtalias(pa1.alias,pa1.alias_pool_cd)
    ELSE
     identifiedmrn = "--"
    ENDIF
   FOOT  mape.med_admin_pt_error_id
    IF (row=42)
     BREAK
    ENDIF
    expectedname = "", identifiedname = "", alert = "",
    username = "", position = "", nurseunit = "",
    smedname = "", totalalert += 1, alert = uar_get_code_display(maa.alert_type_cd),
    alert_time = formatutcdatetime(maa.event_dt_tm,0,0), expectedname = trim(replace(pers1
      .name_full_formatted,",","-",0),3), identifiedname = trim(replace(pers2.name_full_formatted,",",
      "-",0),3),
    username = trim(replace(p.name_full_formatted,",","-",0),3), position = uar_get_code_display(maa
     .position_cd), nurseunit = trim(replace(uar_get_code_display(maa.nurse_unit_cd),","," ",0),3),
    smedname = trim(o.order_mnemonic,3)
    IF (identifiedname="")
     identifiedname = "--"
    ENDIF
    sdisplay = formatlabelbylength(username,16), col 00, sdisplay,
    sdisplay = formatlabelbylength(alert_time,14), col 17, sdisplay,
    sdisplay = formatlabelbylength(expectedname,16), col 32, sdisplay,
    sdisplay = formatlabelbylength(expectedmrn,15), col 49, sdisplay,
    sdisplay = formatlabelbylength(nurseunit,15), col 65, sdisplay,
    sdisplay = formatlabelbylength(identifiedname,16), col 81, sdisplay,
    sdisplay = formatlabelbylength(identifiedmrn,15), col 98, sdisplay,
    sdisplay = formatlabelbylength(position,5), col 114, sdisplay,
    sdisplay = formatlabelbylength(smedname,20), col 120, sdisplay,
    row + 1
   FOOT PAGE
    col 0, i18n_spage, ": ",
    curpage
   FOOT REPORT
    row + 1, col 00, i18n_stotalalerts,
    ": ", totalalert, row + 1
   WITH nocounter, outerjoin = d, outerjoin = d1,
    dio = postscript, maxrow = 45, maxcol = 141
  ;end select
 ELSEIF ((audit_request->display_ind=1))
  SELECT INTO  $OUT_DEV
   FROM med_admin_alert maa,
    med_admin_pt_error mape,
    prsnl p,
    med_admin_event mae,
    orders o,
    person pers1,
    person pers2,
    person_alias pa,
    person_alias pa1,
    org_alias_pool_reltn oap,
    location l,
    dummyt d,
    dummyt d1
   PLAN (maa
    WHERE maa.alert_type_cd IN (cpatmismatch)
     AND maa.event_dt_tm BETWEEN cnvtdatetime(audit_request->start_dt_tm) AND cnvtdatetime(
     audit_request->end_dt_tm)
     AND maa.nurse_unit_cd > 0.00
     AND parser(snua_clause))
    JOIN (l
    WHERE l.location_cd=maa.nurse_unit_cd)
    JOIN (oap
    WHERE oap.organization_id=l.organization_id
     AND oap.alias_entity_name="PERSON_ALIAS"
     AND oap.alias_entity_alias_type_cd=cpatmrn)
    JOIN (p
    WHERE p.person_id=maa.prsnl_id)
    JOIN (mae
    WHERE (mae.med_admin_event_id= Outerjoin(maa.med_admin_event_id)) )
    JOIN (o
    WHERE (o.order_id= Outerjoin(mae.order_id)) )
    JOIN (mape
    WHERE mape.med_admin_alert_id=maa.med_admin_alert_id)
    JOIN (pers1
    WHERE pers1.person_id=mape.expected_pt_id)
    JOIN (d1)
    JOIN (pa
    WHERE pa.person_id=pers1.person_id
     AND pa.person_alias_type_cd=cpatmrn
     AND pa.alias_pool_cd=oap.alias_pool_cd
     AND pa.alias_pool_cd > 0.0)
    JOIN (pers2
    WHERE pers2.person_id=mape.identified_pt_id)
    JOIN (d)
    JOIN (pa1
    WHERE pa1.person_id=pers2.person_id
     AND pa1.person_alias_type_cd=cpatmrn
     AND pa1.alias_pool_cd=oap.alias_pool_cd
     AND pa1.alias_pool_cd > 0.0)
   ORDER BY cnvtdatetime(maa.event_dt_tm), maa.prsnl_id, mape.med_admin_pt_error_id
   HEAD REPORT
    col + 0, totalalert = 0
   HEAD PAGE
    IF ( NOT (( $OUT_DEV IN ("MINE"))))
     col 00, "{ps/792 0 translate 90 rotate/}{pos/000/000}{f/1/0}{lpi/6}{cpi/13}", row + 1
    ENDIF
    CALL center(i18n_stitle,1,llastcolumn), row + 1, sdisplay = concat(i18n_sdaterange,":"),
    col 00, sdisplay, lprintpos = (size(sdisplay)+ 1),
    sdisplay = ""
    IF ((audit_request->start_dt_tm > 0))
     sdisplay = format(audit_request->start_dt_tm,"@SHORTDATE;;Q")
    ENDIF
    IF ((audit_request->end_dt_tm > 0))
     sdisplay = build2(sdisplay," - ",format(audit_request->end_dt_tm,"@SHORTDATE;;Q"))
    ENDIF
    IF (textlen(sdisplay) > 0)
     col lprintpos, sdisplay
    ENDIF
    sdisplay = concat(i18n_spage,": ",cnvtstring(curpage)), lprintpos = (llastcolumn - size(sdisplay)
    ), col lprintpos,
    sdisplay, row + 1, sdisplay = concat(i18n_sfacility,": ",trim(uar_get_code_display(cnvtreal(
         $FACILITY)),3)),
    col 00, sdisplay, sdisplay = concat(i18n_srundatetime,": ",format(cnvtdatetime(sysdate),
      "@SHORTDATE;;Q")," ",format(cnvtdatetime(sysdate),"@TIMENOSECONDS")),
    lprintpos = (llastcolumn - size(sdisplay)), col lprintpos, sdisplay,
    row + 1, sdisplay = concat(i18n_sdisplayper,": ",i18n_sdatetime), lprintpos = (llastcolumn - size
    (sdisplay)),
    col lprintpos, sdisplay, lnewline = (lprintpos - 20),
    sdisplay = ""
    IF (nallind=1)
     sdisplay = concat(i18n_snurseunits,": ",i18n_sall), col 00, sdisplay
    ELSEIF ((audit_request->unit_cnt > 1))
     sdisplay = concat(i18n_snurseunits,": ",trim(uar_get_code_display(audit_request->unit[1].
        nurse_unit_cd),3),","), col 00, sdisplay,
     lprintpos = (size(sdisplay)+ 1)
     IF (lprintpos > lnewline)
      row + 1, lprintpos = (size(i18n_snurseunits)+ 2)
     ENDIF
     FOR (lcnt = 2 TO audit_request->unit_cnt)
       sdisplay = trim(uar_get_code_display(audit_request->unit[lcnt].nurse_unit_cd),3)
       IF ((lcnt != audit_request->unit_cnt))
        sdisplay = concat(sdisplay,",")
       ENDIF
       IF (((lprintpos+ size(sdisplay)) > lnewline))
        row + 1, lprintpos = (size(i18n_snurseunits)+ 2)
       ENDIF
       col lprintpos, sdisplay, lprintpos = ((lprintpos+ size(sdisplay))+ 1)
     ENDFOR
    ELSEIF ((audit_request->unit_cnt=1))
     sdisplay = concat(i18n_snurseunit,": ",trim(uar_get_code_display(audit_request->unit[1].
        nurse_unit_cd),3)), col 00, sdisplay
    ELSE
     sdisplay = concat(i18n_snurseunits,": ",i18n_sunknownerror), col 00, sdisplay
    ENDIF
    row + 1, col 00, cdashline,
    row + 1, sdisplay = concat(i18n_slegend," (",i18n_spos," = ",i18n_sposition,
     ")"), col 00,
    sdisplay, row + 1, sdisplay = formatlabelbylength(i18n_salert,14),
    col 00, sdisplay, sdisplay = formatlabelbylength(i18n_sexpected,16),
    col 15, sdisplay, sdisplay = formatlabelbylength(i18n_sexpected,15),
    col 32, sdisplay, sdisplay = formatlabelbylength(i18n_snurse,15),
    col 48, sdisplay, sdisplay = formatlabelbylength(i18n_sidentified,16),
    col 64, sdisplay, sdisplay = formatlabelbylength(i18n_sidentified,15),
    col 81, sdisplay, sdisplay = formatlabelbylength(i18n_suser,16),
    col 97, sdisplay, row + 1,
    sdisplay = formatlabelbylength(i18n_sdatetime,14), col 00, sdisplay,
    sdisplay = formatlabelbylength(i18n_spatientname,16), col 15, sdisplay,
    sdisplay = formatlabelbylength(i18n_smrn,15), col 32, sdisplay,
    sdisplay = formatlabelbylength(i18n_sunit,15), col 48, sdisplay,
    sdisplay = formatlabelbylength(i18n_spatientname,16), col 64, sdisplay,
    sdisplay = formatlabelbylength(i18n_smrn,15), col 81, sdisplay,
    sdisplay = formatlabelbylength(i18n_sname,16), col 97, sdisplay,
    sdisplay = formatlabelbylength(i18n_spos,5), col 114, sdisplay,
    sdisplay = formatlabelbylength(i18n_smedname,20), col 120, sdisplay,
    row + 1, col 00, ctotal_line,
    row + 1
   HEAD mape.med_admin_pt_error_id
    col + 0, expectedmrn = "", identifiedmrn = ""
   DETAIL
    x = 0
    IF (pa.alias_pool_cd > 0.0)
     expectedmrn = cnvtalias(pa.alias,pa.alias_pool_cd)
    ENDIF
    IF (pa1.alias_pool_cd > 0.0)
     identifiedmrn = cnvtalias(pa1.alias,pa1.alias_pool_cd)
    ELSE
     identifiedmrn = "--"
    ENDIF
   FOOT  mape.med_admin_pt_error_id
    IF (row=42)
     BREAK
    ENDIF
    expectedname = "", identifiedname = "", alert = "",
    username = "", position = "", nurseunit = "",
    smedname = "", totalalert += 1, alert = uar_get_code_display(maa.alert_type_cd),
    alert_time = formatutcdatetime(maa.event_dt_tm,0,0), expectedname = trim(replace(pers1
      .name_full_formatted,",","-",0),3), identifiedname = trim(replace(pers2.name_full_formatted,",",
      "-",0),3),
    username = trim(replace(p.name_full_formatted,",","-",0),3), position = uar_get_code_display(maa
     .position_cd), nurseunit = trim(replace(uar_get_code_display(maa.nurse_unit_cd),","," ",0),3),
    smedname = trim(o.order_mnemonic,3)
    IF (identifiedname="")
     identifiedname = "--"
    ENDIF
    sdisplay = formatlabelbylength(alert_time,14), col 00, sdisplay,
    sdisplay = formatlabelbylength(expectedname,16), col 15, sdisplay,
    sdisplay = formatlabelbylength(expectedmrn,15), col 32, sdisplay,
    sdisplay = formatlabelbylength(nurseunit,15), col 48, sdisplay,
    sdisplay = formatlabelbylength(identifiedname,16), col 64, sdisplay,
    sdisplay = formatlabelbylength(identifiedmrn,15), col 81, sdisplay,
    sdisplay = formatlabelbylength(username,16), col 97, sdisplay,
    sdisplay = formatlabelbylength(position,5), col 114, sdisplay,
    sdisplay = formatlabelbylength(smedname,20), col 120, sdisplay,
    row + 1
   FOOT PAGE
    col 0, i18n_spage, ": ",
    curpage
   FOOT REPORT
    row + 1, col 00, i18n_stotalalerts,
    ": ", totalalert, row + 1
   WITH nocounter, outerjoin = d, outerjoin = d1,
    dio = postscript, maxrow = 45, maxcol = 141
  ;end select
 ELSEIF ((audit_request->display_ind=3))
  SET lnurse_units_length = (size(snurse_units,1)+ 100)
  IF (lnurse_units_length < lmin_col_length)
   SET lnurse_units_length = lmin_col_length
  ENDIF
  SET coutput =  $OUT_DEV
  SET modify = nopredeclare
  EXECUTE bsc_patmm_audit_detail_csv
  SET modify = predeclare
 ENDIF
 IF ((audit_request->display_ind != 3)
  AND curqual=0)
  SELECT INTO  $1
   FROM (dummyt d  WITH seq = 1)
   ORDER BY d.seq
   HEAD PAGE
    IF ( NOT (( $OUT_DEV IN ("MINE"))))
     col 00, "{ps/792 0 translate 90 rotate/}{pos/000/000}{f/1/0}{lpi/6}{cpi/13}", row + 1
    ENDIF
    CALL center(i18n_stitle,1,llastcolumn), row + 1, sdisplay = concat(i18n_sdaterange,":"),
    col 00, sdisplay, lprintpos = (size(sdisplay)+ 1),
    sdisplay = ""
    IF ((audit_request->start_dt_tm > 0))
     sdisplay = format(audit_request->start_dt_tm,"@SHORTDATE;;Q")
    ENDIF
    IF ((audit_request->end_dt_tm > 0))
     sdisplay = build2(sdisplay," - ",format(audit_request->end_dt_tm,"@SHORTDATE;;Q"))
    ENDIF
    IF (textlen(sdisplay) > 0)
     col lprintpos, sdisplay
    ENDIF
    sdisplay = concat(i18n_spage,": ",cnvtstring(curpage)), lprintpos = (llastcolumn - size(sdisplay)
    ), col lprintpos,
    sdisplay, row + 1, sdisplay = concat(i18n_sfacility,": ",trim(uar_get_code_display(cnvtreal(
         $FACILITY)),3)),
    col 00, sdisplay, sdisplay = concat(i18n_srundatetime,": ",format(cnvtdatetime(sysdate),
      "@SHORTDATE;;Q")," ",format(cnvtdatetime(sysdate),"@TIMENOSECONDS")),
    lprintpos = (llastcolumn - size(sdisplay)), col lprintpos, sdisplay,
    row + 1
    IF ((audit_request->display_ind=0))
     sdisplay = concat(i18n_sdisplayper,": ",i18n_suser), lprintpos = (llastcolumn - size(sdisplay)),
     col lprintpos,
     sdisplay
    ELSEIF ((audit_request->display_ind=1))
     sdisplay = concat(i18n_sdisplayper,": ",i18n_sdatetime), lprintpos = (llastcolumn - size(
      sdisplay)), col lprintpos,
     sdisplay
    ELSEIF ((audit_request->display_ind=2))
     sdisplay = concat(i18n_sdisplayper,": ",i18n_sexpectedpatient), lprintpos = (llastcolumn - size(
      sdisplay)), col lprintpos,
     sdisplay
    ENDIF
    lnewline = (lprintpos - 20), sdisplay = ""
    IF (nallind=1)
     sdisplay = concat(i18n_snurseunits,": ",i18n_sall), col 00, sdisplay
    ELSEIF ((audit_request->unit_cnt > 1))
     sdisplay = concat(i18n_snurseunits,": ",trim(uar_get_code_display(audit_request->unit[1].
        nurse_unit_cd),3),","), col 00, sdisplay,
     lprintpos = (size(sdisplay)+ 1)
     IF (lprintpos > lnewline)
      row + 1, lprintpos = (size(i18n_snurseunits)+ 2)
     ENDIF
     FOR (lcnt = 2 TO audit_request->unit_cnt)
       sdisplay = trim(uar_get_code_display(audit_request->unit[lcnt].nurse_unit_cd),3)
       IF ((lcnt != audit_request->unit_cnt))
        sdisplay = concat(sdisplay,",")
       ENDIF
       IF (((lprintpos+ size(sdisplay)) > lnewline))
        row + 1, lprintpos = (size(i18n_snurseunits)+ 2)
       ENDIF
       col lprintpos, sdisplay, lprintpos = ((lprintpos+ size(sdisplay))+ 1)
     ENDFOR
    ELSEIF ((audit_request->unit_cnt=1))
     sdisplay = concat(i18n_snurseunit,": ",trim(uar_get_code_display(audit_request->unit[1].
        nurse_unit_cd),3)), col 00, sdisplay
    ELSE
     sdisplay = concat(i18n_snurseunits,": ",i18n_sunknownerror), col 00, sdisplay
    ENDIF
    row + 1, col 00, cdashline,
    row + 1, sdisplay = concat("***** ",i18n_snoresultsqualified," *****"),
    CALL center(sdisplay,1,llastcolumn)
   WITH nocounter, dio = postscript, maxrow = 45,
    maxcol = 141
  ;end select
 ENDIF
 SET last_mod = "009"
 SET mod_date = "08/26/2019"
 SET modify = nopredeclare
 FREE RECORD audit_request
END GO
