CREATE PROGRAM bsc_rpt_fund_src_mismatch:dba
 PROMPT
  "Output to File/Printer/MINE:" = "MINE",
  "Starting date:" = "CURDATE",
  "Ending date:" = "CURDATE",
  "Facility:" = 0,
  "Nurse unit(s):" = 0,
  "Display per:" = 0
  WITH out_dev, start_date, end_date,
  facility, nurse_unit, display_type
 SET modify = predeclare
 DECLARE butcind = i2 WITH protect, constant(curutc)
 DECLARE ctime_zone_format = vc WITH protect, constant("ZZZ")
 DECLARE parsezeroes(passfieldin=f8) = vc
 DECLARE formatutcdatetime(sdatetime=vc,ltzindex=i4,bshowtz=i2) = vc
 DECLARE formatlabelbylength(slabel=vc,lmaxlen=i4) = vc
 DECLARE formatstrength(dstrength=f8) = vc
 DECLARE formatvolume(dvolume=f8) = vc
 DECLARE formatrate(drate=f8) = vc
 DECLARE formatpercentwithdecimal(dpercent=f8) = vc
 SUBROUTINE parsezeroes(pass_field_in)
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
     SET str_cnt = (str_cnt+ 1)
   ENDWHILE
   SET sig_dig = (str_cnt - 1)
   SET str_cnt = 16
   WHILE (str_cnt > 12
    AND substring(str_cnt,1,strfld) IN ("0", " "))
     SET str_cnt = (str_cnt - 1)
   ENDWHILE
   IF (str_cnt=12
    AND substring(str_cnt,1,strfld)=".")
    SET str_cnt = (str_cnt - 1)
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
 SUBROUTINE formatutcdatetime(sdatetime,ltzindex,bshowtz)
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
 SUBROUTINE formatlabelbylength(slabel,lmaxlen)
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
 SUBROUTINE formatstrength(dstrength)
   DECLARE snewlabel = vc WITH protect, noconstant("")
   SET snewlabel = nullterm(trim(format(dstrength,"######.####;It(1);F"),3))
   RETURN(snewlabel)
 END ;Subroutine
 SUBROUTINE formatvolume(dvolume)
   DECLARE snewlabel = vc WITH protect, noconstant("")
   SET snewlabel = nullterm(trim(format(dvolume,"######.##;It(1);F"),3))
   RETURN(snewlabel)
 END ;Subroutine
 SUBROUTINE formatrate(drate)
   DECLARE snewlabel = vc WITH protect, noconstant("")
   SET snewlabel = nullterm(trim(format(drate,"######.####;It(1);F"),3))
   RETURN(snewlabel)
 END ;Subroutine
 SUBROUTINE formatpercentwithdecimal(dpercent)
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
 DECLARE auth = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE modified = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE altered = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE unauth = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"UNAUTH"))
 DECLARE immun = f8 WITH protect, constant(uar_get_code_by("MEANING",53,"IMMUN"))
 DECLARE active = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE last_column = i4 WITH protect, constant(131)
 DECLARE nurse_unit_cs = i4 WITH protect, constant(220)
 DECLARE funding_source_cs = i4 WITH protect, constant(4002904)
 DECLARE oe_field_meaning_funding_source = i4 WITH protect, constant(6020)
 DECLARE display_per_day = i2 WITH protect, constant(0)
 DECLARE display_per_user = i2 WITH protect, constant(1)
 DECLARE display_per_nurse_unit = i2 WITH protect, constant(2)
 DECLARE max_row = i2 WITH protect, constant(48)
 DECLARE dashline = vc WITH protect, constant(fillstring(131,"-"))
 DECLARE asterisk = vc WITH protect, constant("*")
 DECLARE ltotaldetail = i4 WITH protect, noconstant(0)
 DECLARE lcnt = i4 WITH protect, noconstant(0)
 DECLARE lidx = i4 WITH protect, noconstant(0)
 DECLARE nallind = i2 WITH protect, noconstant(0)
 DECLARE nlength = i2 WITH protect, noconstant(0)
 DECLARE sdisplay = vc WITH protect, noconstant("")
 DECLARE sstartdate = vc WITH protect, noconstant("")
 DECLARE senddate = vc WITH protect, noconstant("")
 DECLARE dstat = f8 WITH protect, noconstant(0.0)
 DECLARE dusedfundingsourcecd = f8 WITH protect, noconstant(0.0)
 DECLARE last_mod = c3 WITH private, noconstant("")
 DECLARE mod_date = c10 WITH private, noconstant("")
 DECLARE lprintpos = i4 WITH protect, noconstant(0)
 DECLARE nnurseunitprintpos = i2 WITH protect, noconstant(0)
 DECLARE ndayprintpos = i2 WITH protect, noconstant(0)
 DECLARE nuserprintpos = i2 WITH protect, noconstant(0)
 DECLARE ncurrentrow = i2 WITH protect, noconstant(0)
 DECLARE nfundingsourcepos = i2 WITH protect, noconstant(0)
 DECLARE sexpectedfs = vc WITH protect, noconstant("")
 DECLARE sdocumentedfs = vc WITH protect, noconstant("")
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
    "Immunization Funding Source Mismatch Report"),3))
 DECLARE i18n_sdisplayper = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_DISPLAY_PER","Display per"),3))
 DECLARE i18n_sdate = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_DATE","Date"
    ),3))
 DECLARE i18n_stime = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_TIME","Time"
    ),3))
 DECLARE i18n_suser = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_USER","User"
    ),3))
 DECLARE i18n_sday = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_DAY","Day"),3
   ))
 DECLARE i18n_spatient = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_PATIENT",
    "Patient"),3))
 DECLARE i18n_smnemonic = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_MNEMONIC","Immunization"),3))
 DECLARE i18n_sexpectedfs = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_EXPECTEDFS","Expected"),3))
 DECLARE i18n_sdocumentedfs = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_DOCUMENTEDFS","Documented"),3))
 DECLARE i18n_stotal = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_TOTAL",
    "Total Mismatches:"),3))
 DECLARE i18n_sendofreport = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_END_OF_REPORT","End of Report"),3))
 DECLARE i18n_snoresultsqualified = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_NO_RESULTS_QUALIFIED","No Results Qualified"),3))
 DECLARE generatereport(null) = null WITH protect
 DECLARE getnurseunitsfromfacility(null) = null WITH protect
 DECLARE getnurseunitsfromlist(null) = null WITH protect
 DECLARE getorganizationsforreportuser(null) = null WITH protect
 DECLARE getdisplaymnemonic(hnaordermnemonic=vc,orderedasmnemonic=vc,ordermnemonic=vc) = vc WITH
 protect
 FREE RECORD audit_request
 SET modify = nopredeclare
 EXECUTE bsc_get_audit_info_rr
 SET modify = predeclare
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
 IF (substring(1,1,reflect( $NURSE_UNIT))="I")
  IF (( $NURSE_UNIT=0))
   SET nallind = 1
  ENDIF
 ELSEIF (substring(1,1,reflect( $NURSE_UNIT))="C")
  IF (( $NURSE_UNIT=asterisk))
   SET nallind = 1
  ENDIF
 ENDIF
 IF (nallind=1)
  CALL getnurseunitsfromfacility(null)
 ELSE
  CALL getnurseunitsfromlist(null)
 ENDIF
 CALL generatereport(null)
 SUBROUTINE (getdisplaymnemonic(hnaordermnemonic=vc,orderedasmnemonic=vc,ordermnemonic=vc) =vc)
   DECLARE smnemonic1 = vc WITH protect, noconstant("")
   DECLARE smnemonic2 = vc WITH protect, noconstant("")
   DECLARE smnemonic3 = vc WITH protect, noconstant("")
   SET smnemonic3 = ""
   SET smnemonic1 = trim(hnaordermnemonic)
   IF (textlen(smnemonic1)=0)
    SET smnemonic1 = trim(ordermnemonic)
   ENDIF
   IF (textlen(smnemonic1)=0)
    SET smnemonic1 = trim(orderedasmnemonic)
   ENDIF
   IF (textlen(smnemonic1) > 0)
    SET smnemonic2 = trim(orderedasmnemonic)
    IF (((smnemonic1=smnemonic2) OR (textlen(smnemonic2)=0)) )
     SET smnemonic3 = smnemonic1
    ELSE
     SET smnemonic3 = build(smnemonic1," (",smnemonic2,")")
    ENDIF
   ENDIF
   RETURN(smnemonic3)
 END ;Subroutine
 SUBROUTINE (getnurseunitsfromfacility(null) =null)
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
     lcnt = (lcnt+ 1)
     IF (mod(lcnt,10)=1)
      dstat = alterlist(audit_request->unit,(lcnt+ 9))
     ENDIF
     audit_request->unit[lcnt].nurse_unit_cd = cv.code_value
    FOOT REPORT
     dstat = alterlist(audit_request->unit,lcnt), audit_request->unit_cnt = lcnt
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE (getnurseunitsfromlist(null) =null)
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_value IN ( $NURSE_UNIT))
    ORDER BY cv.display
    HEAD REPORT
     lcnt = 0
    DETAIL
     lcnt = (lcnt+ 1)
     IF (mod(lcnt,10)=1)
      dstat = alterlist(audit_request->unit,(lcnt+ 9))
     ENDIF
     audit_request->unit[lcnt].nurse_unit_cd = cv.code_value
    FOOT REPORT
     dstat = alterlist(audit_request->unit,lcnt), audit_request->unit_cnt = lcnt
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE (generatereport(null) =null)
   SELECT
    IF (( $DISPLAY_TYPE=display_per_day))
     sort_ord = ce.event_end_dt_tm, datetime = ce.event_end_dt_tm, patient_name = person
     .name_full_formatted,
     prsnl_name = prsnl.name_full_formatted, hna_order_mnemonic = o.hna_order_mnemonic,
     ordered_as_mnemonic = o.ordered_as_mnemonic,
     order_mnemonic = o.order_mnemonic, nurse_unit_cd = e.loc_nurse_unit_cd,
     expected_funding_source_cd = d.oe_field_value,
     documented_funding_source_cd = im.funding_source_cd, event_id = ce.event_id
    ELSEIF (( $DISPLAY_TYPE=display_per_user))
     sort_ord = prsnl.name_full_formatted, datetime = ce.event_end_dt_tm, orderid = ce.order_id,
     nurse_unit_cd = e.loc_nurse_unit_cd, patient_name = person.name_full_formatted, prsnl_name =
     prsnl.name_full_formatted,
     hna_order_mnemonic = o.hna_order_mnemonic, ordered_as_mnemonic = o.ordered_as_mnemonic,
     order_mnemonic = o.order_mnemonic,
     expected_funding_source_cd = d.oe_field_value, documented_funding_source_cd = im
     .funding_source_cd
    ELSEIF (( $DISPLAY_TYPE=display_per_nurse_unit))
     sort_ord = uar_get_code_display(e.loc_nurse_unit_cd), datetime = ce.event_end_dt_tm, orderid =
     ce.order_id,
     nurse_unit_cd = e.loc_nurse_unit_cd, patient_name = person.name_full_formatted, prsnl_name =
     prsnl.name_full_formatted,
     hna_order_mnemonic = o.hna_order_mnemonic, ordered_as_mnemonic = o.ordered_as_mnemonic,
     order_mnemonic = o.order_mnemonic,
     expected_funding_source_cd = d.oe_field_value, documented_funding_source_cd = im
     .funding_source_cd
    ELSE
    ENDIF
    INTO  $1
    FROM encounter e,
     clinical_event ce,
     ce_med_result cmr,
     immunization_modifier im,
     order_detail d,
     prsnl,
     person,
     orders o
    PLAN (e
     WHERE expand(lidx,1,audit_request->unit_cnt,e.loc_nurse_unit_cd,audit_request->unit[lidx].
      nurse_unit_cd)
      AND e.active_ind=1)
     JOIN (ce
     WHERE ce.encntr_id=e.encntr_id
      AND ce.event_class_cd=immun
      AND ce.record_status_cd=active
      AND ce.result_status_cd IN (auth, modified, altered, unauth)
      AND ce.valid_until_dt_tm=cnvtdatetime("31-Dec-2100 00:00:00.00")
      AND ce.event_end_dt_tm BETWEEN cnvtdatetime(audit_request->start_dt_tm) AND cnvtdatetime(
      audit_request->end_dt_tm)
      AND ce.view_level > 0)
     JOIN (cmr
     WHERE cmr.event_id=ce.event_id
      AND cmr.valid_until_dt_tm=cnvtdatetime("31-Dec-2100 00:00:00.00"))
     JOIN (im
     WHERE im.event_id=ce.event_id
      AND im.person_id=ce.person_id
      AND im.funding_source_cd > 0.0)
     JOIN (d
     WHERE d.order_id=ce.order_id
      AND d.action_sequence=ce.order_action_sequence
      AND d.oe_field_meaning_id=oe_field_meaning_funding_source
      AND d.oe_field_value > 0
      AND d.oe_field_value != im.funding_source_cd)
     JOIN (prsnl
     WHERE prsnl.person_id=ce.performed_prsnl_id
      AND prsnl.active_ind=1)
     JOIN (person
     WHERE e.person_id=person.person_id
      AND person.active_ind=1)
     JOIN (o
     WHERE o.order_id=ce.order_id
      AND o.active_ind=1)
    ORDER BY sort_ord
    HEAD PAGE
     IF ( NOT (( $1 IN ("MINE"))))
      col 00, "{ps/792 0 translate 90 rotate/}{pos/000/000}{f/1/0}{lpi/6}{cpi/13}", row + 1
     ENDIF
     CALL center(i18n_stitle,1,last_column), row + 1, sdisplay = concat(i18n_sdaterange,":"),
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
     sdisplay = concat(i18n_spage,": ",cnvtstring(curpage)), lprintpos = (last_column - size(sdisplay
      )), col lprintpos,
     sdisplay, row + 1, sdisplay = concat(i18n_sfacility,": ",trim(uar_get_code_display(cnvtreal(
          $FACILITY)),3)),
     col 00, sdisplay, sdisplay = concat(i18n_srundatetime,": ",format(cnvtdatetime(curdate,curtime3),
       "@SHORTDATE;;Q")," ",format(cnvtdatetime(curdate,curtime3),"@TIMENOSECONDS")),
     lprintpos = (last_column - size(sdisplay)), col lprintpos, sdisplay,
     row + 1
     CASE ( $DISPLAY_TYPE)
      OF display_per_day:
       sdisplay = concat(i18n_sdisplayper,": ",i18n_sday),ndayprintpos = 0,nuserprintpos = 15,
       nnurseunitprintpos = 35
      OF display_per_user:
       sdisplay = concat(i18n_sdisplayper,": ",i18n_suser),nuserprintpos = 0,ndayprintpos = 20,
       nnurseunitprintpos = 35
      OF display_per_nurse_unit:
       sdisplay = concat(i18n_sdisplayper,": ",i18n_snurseunit),nnurseunitprintpos = 0,ndayprintpos
        = 11,
       nuserprintpos = 27
     ENDCASE
     lprintpos = (last_column - size(sdisplay)), col lprintpos, sdisplay,
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
     row + 1, col 00, dashline,
     row + 1, sdisplay = formatlabelbylength(i18n_sdate,9), col ndayprintpos,
     sdisplay, sdisplay = formatlabelbylength(i18n_stime,5), call reportmove('COL',(ndayprintpos+ 9)
     ,0),
     sdisplay, sdisplay = formatlabelbylength(i18n_suser,19), col nuserprintpos,
     sdisplay, sdisplay = formatlabelbylength(i18n_snurseunit,11), col nnurseunitprintpos,
     sdisplay, sdisplay = formatlabelbylength(i18n_spatient,19), col 47,
     sdisplay, sdisplay = formatlabelbylength(i18n_smnemonic,45), col 67,
     sdisplay, sdisplay = formatlabelbylength(i18n_sexpectedfs,9), col 112,
     sdisplay, sdisplay = formatlabelbylength(i18n_sdocumentedfs,10), col 121,
     sdisplay, row + 2, ncurrentrow = 0
    DETAIL
     IF ((ncurrentrow > (max_row - 7)))
      BREAK, ncurrentrow = 0
     ENDIF
     sdisplay = format(datetime,"@SHORTDATE;;Q"), col ndayprintpos, sdisplay,
     sdisplay = format(datetime,"@TIMENOSECONDS;;Q"), call reportmove('COL',(ndayprintpos+ 9),0),
     sdisplay,
     sdisplay = formatlabelbylength(prsnl_name,19), col nuserprintpos, sdisplay,
     sdisplay = formatlabelbylength(uar_get_code_display(nurse_unit_cd),11), col nnurseunitprintpos,
     sdisplay,
     sdisplay = formatlabelbylength(patient_name,19), col 47, sdisplay,
     sdisplay = formatlabelbylength(getdisplaymnemonic(hna_order_mnemonic,ordered_as_mnemonic,
       order_mnemonic),44), col 67, sdisplay,
     sexpectedfs = uar_get_code_display(expected_funding_source_cd), nlength = textlen(trim(
       sexpectedfs)), sdisplay = formatlabelbylength(substring(1,(nlength - 5),sexpectedfs),9),
     col 112, sdisplay, sdocumentedfs = uar_get_code_display(documented_funding_source_cd),
     nlength = textlen(trim(sdocumentedfs))
     IF (nlength > 0)
      sdisplay = formatlabelbylength(substring(1,(nlength - 6),sdocumentedfs),9)
     ELSE
      sdisplay = "<none>"
     ENDIF
     nfundingsourcepos = (131 - textlen(trim(sdisplay))), col nfundingsourcepos, sdisplay,
     row + 1, ltotaldetail = (ltotaldetail+ 1), ncurrentrow = (ncurrentrow+ 1)
    FOOT REPORT
     IF ((ncurrentrow > (max_row - 7)))
      BREAK
     ENDIF
     IF (ltotaldetail=0)
      row + 1, sdisplay = concat("***** ",i18n_snoresultsqualified," *****"),
      CALL center(sdisplay,1,last_column)
     ELSE
      row + 1, sdisplay = concat(i18n_stotal," ",trim(cnvtstring(ltotaldetail))), col 6,
      sdisplay, row + 2, sdisplay = concat("***** ",i18n_sendofreport," *****"),
      CALL center(sdisplay,1,last_column)
     ENDIF
    WITH dio = postscript, nocounter, expand = 2,
     nullreport, maxrow = max_row, skipreport = 0
   ;end select
 END ;Subroutine
 SET last_mod = "002"
 SET mod_date = "04/11/2017"
 SET modify = nopredeclare
END GO
