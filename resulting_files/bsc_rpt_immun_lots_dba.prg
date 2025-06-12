CREATE PROGRAM bsc_rpt_immun_lots:dba
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
 DECLARE fin_nbr = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE last_column = i4 WITH protect, constant(131)
 DECLARE location_cs = i4 WITH protect, constant(220)
 DECLARE funding_source_cs = i4 WITH protect, constant(4002904)
 DECLARE manufacturer_cs = i4 WITH protect, constant(221)
 DECLARE max_row = i2 WITH protect, constant(48)
 DECLARE display_per_day = i2 WITH protect, constant(0)
 DECLARE display_per_user = i2 WITH protect, constant(1)
 DECLARE display_per_nurse_unit = i2 WITH protect, constant(2)
 DECLARE start_print_pos = i2 WITH protect, constant(7)
 DECLARE bold = vc WITH protect, constant("{B}")
 DECLARE dashline = vc WITH protect, constant("{b/132/0}{r/131/-/}")
 DECLARE ltotaldetail = i4 WITH protect, noconstant(0)
 DECLARE nallind = i2 WITH protect, noconstant(0)
 DECLARE lcnt = i4 WITH protect, noconstant(0)
 DECLARE lidx = i4 WITH protect, noconstant(0)
 DECLARE sdisplay = vc WITH protect, noconstant("")
 DECLARE sstartdate = vc WITH protect, noconstant("")
 DECLARE senddate = vc WITH protect, noconstant("")
 DECLARE smnemonic1 = vc WITH protect, noconstant("")
 DECLARE smnemonic2 = vc WITH protect, noconstant("")
 DECLARE dstat = f8 WITH protect, noconstant(0.0)
 DECLARE last_mod = c3 WITH private, noconstant("")
 DECLARE mod_date = c10 WITH private, noconstant("")
 DECLARE lprintpos = i4 WITH protect, noconstant(0)
 DECLARE nnurseunitprintpos = i2 WITH protect, noconstant(0)
 DECLARE ndayprintpos = i2 WITH protect, noconstant(0)
 DECLARE nuserprintpos = i2 WITH protect, noconstant(0)
 DECLARE ncurrentrow = i2 WITH protect, noconstant(0)
 DECLARE nfundingsourcelength = i2 WITH protect, noconstant(0)
 DECLARE ngroupprinted = i1 WITH protect, noconstant(0)
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
    "Immunization Lot Tracking Audit Report"),3))
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
 DECLARE i18n_sfin = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_FIN","FIN"),3
   ))
 DECLARE i18n_smnemonic = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_MNEMONIC","Immunization Name"),3))
 DECLARE i18n_slotnumber = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_LOT_NUMBER","Lot Number"),3))
 DECLARE i18n_smanufacturer = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_MANUFACTURER","Manufacturer"),3))
 DECLARE i18n_sexpiration = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_EXPIRATION","Exp. Date"),3))
 DECLARE i18n_sdocumentedfs = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_DOCUMENTEDFS","Funding Source"),3))
 DECLARE i18n_stotal = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_TOTAL",
    "Total:"),3))
 DECLARE i18n_sendofreport = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_END_OF_REPORT","End of Report"),3))
 DECLARE i18n_snoresultsqualified = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_NO_RESULTS_QUALIFIED","No Results Qualified"),3))
 DECLARE generatereport(null) = null WITH protect
 DECLARE getnurseunitsfromfacility(null) = null WITH protect
 DECLARE getnurseunitsfromlist(null) = null WITH protect
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
  IF (( $NURSE_UNIT="*"))
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
   DECLARE sdisplay = vc WITH protect, noconstant("")
   SET sdisplay = ""
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
     SET sdisplay = smnemonic1
    ELSE
     SET sdisplay = build(smnemonic1," (",smnemonic2,")")
    ENDIF
   ENDIF
   RETURN(sdisplay)
 END ;Subroutine
 SUBROUTINE (getnurseunitsfromfacility(null) =null)
   SELECT INTO "nl:"
    FROM code_value cv,
     location_group lg1,
     location_group lg2
    PLAN (cv
     WHERE cv.code_set=location_cs
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
     sort_ord = ce.event_end_dt_tm, datetime = ce.event_end_dt_tm, documentedfs = imcv.display,
     nurse_unit_cd = e.loc_nurse_unit_cd, patient_name = person.name_full_formatted, prsnl_name =
     prsnl.name_full_formatted,
     hna_order_mnemonic = o.hna_order_mnemonic, ordered_as_mnemonic = o.ordered_as_mnemonic,
     order_mnemonic = o.order_mnemonic,
     mnemonic = getdisplaymnemonic(o.hna_order_mnemonic,o.ordered_as_mnemonic,o.order_mnemonic),
     lot_number = cmr.substance_lot_number, manufacturer = mcv.display,
     expiration = cmr.substance_exp_dt_tm, fin = ea.alias, order_id = o.order_id
    ELSEIF (( $DISPLAY_TYPE=display_per_user))
     sort_ord = prsnl.name_full_formatted, datetime = ce.event_end_dt_tm, documentedfs = imcv.display,
     nurse_unit_cd = e.loc_nurse_unit_cd, patient_name = person.name_full_formatted, prsnl_name =
     prsnl.name_full_formatted,
     hna_order_mnemonic = o.hna_order_mnemonic, ordered_as_mnemonic = o.ordered_as_mnemonic,
     order_mnemonic = o.order_mnemonic,
     mnemonic = getdisplaymnemonic(o.hna_order_mnemonic,o.ordered_as_mnemonic,o.order_mnemonic),
     lot_number = cmr.substance_lot_number, manufacturer = mcv.display,
     expiration = cmr.substance_exp_dt_tm, fin = ea.alias, order_id = o.order_id
    ELSEIF (( $DISPLAY_TYPE=display_per_nurse_unit))
     sort_ord = uar_get_code_display(e.loc_nurse_unit_cd), datetime = ce.event_end_dt_tm,
     documentedfs = imcv.display,
     nurse_unit_cd = e.loc_nurse_unit_cd, patient_name = person.name_full_formatted, prsnl_name =
     prsnl.name_full_formatted,
     hna_order_mnemonic = o.hna_order_mnemonic, ordered_as_mnemonic = o.ordered_as_mnemonic,
     order_mnemonic = o.order_mnemonic,
     mnemonic = getdisplaymnemonic(o.hna_order_mnemonic,o.ordered_as_mnemonic,o.order_mnemonic),
     lot_number = cmr.substance_lot_number, manufacturer = mcv.display,
     expiration = cmr.substance_exp_dt_tm, fin = ea.alias, order_id = o.order_id
    ELSE
    ENDIF
    INTO  $1
    FROM encounter e,
     encntr_alias ea,
     clinical_event ce,
     ce_med_result cmr,
     code_value mcv,
     immunization_modifier im,
     code_value imcv,
     prsnl,
     person,
     orders o
    PLAN (e
     WHERE expand(lidx,1,audit_request->unit_cnt,e.loc_nurse_unit_cd,audit_request->unit[lidx].
      nurse_unit_cd)
      AND e.active_ind=1)
     JOIN (ea
     WHERE ea.encntr_id=e.encntr_id
      AND ea.encntr_alias_type_cd=fin_nbr
      AND ea.active_ind=1)
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
     JOIN (mcv
     WHERE cmr.substance_manufacturer_cd=mcv.code_value
      AND mcv.code_set=manufacturer_cs
      AND mcv.active_ind=1)
     JOIN (im
     WHERE im.event_id=ce.event_id
      AND im.person_id=ce.person_id
      AND im.funding_source_cd > 0.0
      AND (im.immunization_modifier_id=
     (SELECT
      max(mo.immunization_modifier_id)
      FROM immunization_modifier mo
      WHERE im.event_id=mo.event_id)))
     JOIN (imcv
     WHERE imcv.code_set=funding_source_cs
      AND im.funding_source_cd=imcv.code_value
      AND imcv.active_ind=1)
     JOIN (prsnl
     WHERE prsnl.person_id=ce.performed_prsnl_id
      AND prsnl.active_ind=1)
     JOIN (person
     WHERE person.active_ind=1
      AND e.person_id=person.person_id)
     JOIN (o
     WHERE o.active_ind=1
      AND o.order_id=ce.order_id)
    ORDER BY hna_order_mnemonic, mnemonic, lot_number,
     manufacturer, expiration, documentedfs,
     sort_ord
    HEAD REPORT
     ltotaldetail = 0,
     MACRO (print_group_data)
      IF ( NOT (( $1 IN ("MINE"))))
       row + 1, "{f/1/0}"
      ELSE
       row + 1
      ENDIF
      row + 1, sdisplay = getdisplaymnemonic(hna_order_mnemonic,ordered_as_mnemonic,order_mnemonic),
      col 00,
      sdisplay
      IF (textlen(sdisplay) > 39)
       row + 1, ncurrentrow = (ncurrentrow+ 1)
      ENDIF
      sdisplay = formatlabelbylength(trim(lot_number),17), col 42, sdisplay,
      sdisplay = formatlabelbylength(manufacturer,40), col 60, sdisplay,
      sdisplay = format(expiration,"@SHORTDATE4YR;;D"), col 101, sdisplay,
      nfundingsourcelength = textlen(trim(documentedfs)), sdisplay = formatlabelbylength(documentedfs,
       16), call reportmove('COL',(131 - nfundingsourcelength),0),
      sdisplay, row + 1, sdisplay = dashline,
      col 00, sdisplay, ncurrentrow = (ncurrentrow+ 3)
     ENDMACRO
     ,
     MACRO (group_header)
      IF (ngroupprinted=0)
       IF ((ncurrentrow > (max_row - 13)))
        BREAK, ncurrentrow = 0
       ENDIF
       print_group_data, ngroupprinted = 1
      ENDIF
     ENDMACRO
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
       sdisplay = concat(i18n_sdisplayper,": ",i18n_sday),ndayprintpos = start_print_pos,
       nuserprintpos = (start_print_pos+ 18),
       nnurseunitprintpos = (start_print_pos+ 60)
      OF display_per_user:
       sdisplay = concat(i18n_sdisplayper,": ",i18n_suser),nuserprintpos = start_print_pos,
       ndayprintpos = (start_print_pos+ 42),
       nnurseunitprintpos = (start_print_pos+ 60)
      OF display_per_nurse_unit:
       sdisplay = concat(i18n_sdisplayper,": ",i18n_snurseunit),nnurseunitprintpos = start_print_pos,
       ndayprintpos = (start_print_pos+ 21),
       nuserprintpos = (start_print_pos+ 42)
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
     row + 1, sdisplay = formatlabelbylength(i18n_smnemonic,34), col 00,
     sdisplay, sdisplay = formatlabelbylength(i18n_slotnumber,17), col 42,
     sdisplay, sdisplay = formatlabelbylength(i18n_smanufacturer,40), col 60,
     sdisplay, sdisplay = formatlabelbylength(i18n_sexpiration,10), col 101,
     sdisplay, sdisplay = formatlabelbylength(i18n_sdocumentedfs,16), col 117,
     sdisplay, row + 1, col 00,
     dashline
     IF ( NOT (( $1 IN ("MINE"))))
      row + 1, "{f/1/0}"
     ELSE
      row + 1
     ENDIF
     sdisplay = formatlabelbylength(i18n_sdate,9), col ndayprintpos, sdisplay,
     sdisplay = formatlabelbylength(i18n_stime,5), call reportmove('COL',(ndayprintpos+ 9),0),
     sdisplay,
     sdisplay = formatlabelbylength(i18n_suser,40), col nuserprintpos, sdisplay,
     sdisplay = formatlabelbylength(i18n_snurseunit,20), col nnurseunitprintpos, sdisplay,
     sdisplay = formatlabelbylength(i18n_sfin,23), col 108, sdisplay,
     ncurrentrow = 0
    HEAD mnemonic
     group_header
    HEAD lot_number
     group_header
    HEAD manufacturer
     group_header
    HEAD expiration
     group_header
    HEAD documentedfs
     group_header
    DETAIL
     ngroupprinted = 0
     IF ((ncurrentrow > (max_row - 9)))
      BREAK, ncurrentrow = 0
     ENDIF
     IF (ncurrentrow=0)
      print_group_data
     ENDIF
     IF ( NOT (( $1 IN ("MINE"))))
      row + 1, "{f/0/0}"
     ELSE
      row + 1
     ENDIF
     sdisplay = format(datetime,"@SHORTDATE;;Q"), col ndayprintpos, sdisplay,
     sdisplay = format(datetime,"@TIMENOSECONDS;;Q"), call reportmove('COL',(ndayprintpos+ 9),0),
     sdisplay,
     sdisplay = formatlabelbylength(prsnl_name,40), col nuserprintpos, sdisplay,
     sdisplay = formatlabelbylength(uar_get_code_display(nurse_unit_cd),20), col nnurseunitprintpos,
     sdisplay,
     sdisplay = formatlabelbylength(fin,23), col 108, sdisplay,
     ltotaldetail = (ltotaldetail+ 1), ncurrentrow = (ncurrentrow+ 1)
    FOOT REPORT
     IF ((ncurrentrow > (max_row - 10)))
      BREAK
     ENDIF
     row + 2
     IF (ltotaldetail=0)
      sdisplay = concat("{b}***** ",i18n_snoresultsqualified," *****")
     ELSE
      sdisplay = concat("{b}",i18n_stotal," ",trim(cnvtstring(ltotaldetail))), col 6, sdisplay,
      row + 1, sdisplay = concat("{b}***** ",i18n_sendofreport," *****")
     ENDIF
     CALL center(sdisplay,1,last_column)
    WITH dio = postscript, nocounter, expand = 2,
     nullreport, maxrow = max_row, skipreport = 0
   ;end select
 END ;Subroutine
 SET last_mod = "001"
 SET mod_date = "04/05/2017"
 SET modify = nopredeclare
END GO
