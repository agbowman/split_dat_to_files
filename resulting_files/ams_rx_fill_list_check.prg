CREATE PROGRAM ams_rx_fill_list_check
 PROMPT
  "Enter Output Location (Only Mine is accepted):" = "Mine",
  "Fill Batch Code: " = 0.0,
  "Order ID: " = 0.0,
  "Fill Hx ID: " = 0.0,
  "Mode (0: Order did not qualify(default); 1: Order qualified): " = 0.0
  WITH outdev, batch_cd, order_id,
  fill_hx, mode
 RECORD outputs(
   1 writethis[200]
     2 line = vc
 )
 DECLARE ncnt = i4 WITH protect, noconstant(1)
 DECLARE i18nhandle = i4 WITH protect, noconstant(0)
 CALL uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 CALL echorecord(reqinfo)
 DECLARE soutput = vc WITH protect, noconstant("")
 CALL echo(build("OUTDEV: ", $OUTDEV))
 IF ((reqinfo->updt_app=0)
  AND cnvtupper(trim( $OUTDEV,3)) != "MINE")
  CALL echo("Output not MINE")
  SET outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap151",
   "Only output location of MINE is accepted, setting to MINE")
  SET ncnt = (ncnt+ 1)
  SET soutput = "MINE"
 ELSE
  SET soutput =  $OUTDEV
 ENDIF
 IF ((reqinfo->updt_app=0))
  DECLARE ilogincheck = i4 WITH noconstant(0)
  SET ilogincheck = validate(xxcclseclogin->loggedin,99)
  IF (ilogincheck != 1)
   SET outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap143",
    "CCLSECLOGIN Failure!  Please complete CCLSECLOGIN")
   SET ncnt = (ncnt+ 1)
   GO TO end_script
  ENDIF
 ENDIF
 CALL echo(build("Batch: ", $BATCH_CD))
 CALL echo(build("Order: ", $ORDER_ID))
 CALL echo(build("Hx id: ", $FILL_HX))
 CALL echo(build("Mode: ", $MODE))
 SET program_modification = "Mod 001; August 2013"
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
 DECLARE utcdatetime(ddatetime=vc,lindex=i4,bshowtz=i2,sformat=vc) = vc
 DECLARE utcshorttz(lindex=i4) = vc
 DECLARE sutcdatetime = vc WITH protect, noconstant(" ")
 DECLARE dutcdatetime = f8 WITH protect, noconstant(0.0)
 DECLARE cutc = i2 WITH protect, constant(curutc)
 SUBROUTINE utcdatetime(sdatetime,lindex,bshowtz,sformat)
   DECLARE offset = i2 WITH protect, noconstant(0)
   DECLARE daylight = i2 WITH protect, noconstant(0)
   DECLARE lnewindex = i4 WITH protect, noconstant(curtimezoneapp)
   DECLARE snewdatetime = vc WITH protect, noconstant(" ")
   DECLARE ctime_zone_format = vc WITH protect, constant("ZZZ")
   IF (lindex > 0)
    SET lnewindex = lindex
   ENDIF
   SET snewdatetime = datetimezoneformat(sdatetime,lnewindex,sformat)
   IF (cutc=1
    AND bshowtz=1)
    IF (size(trim(snewdatetime)) > 0)
     SET snewdatetime = concat(snewdatetime," ",datetimezoneformat(sdatetime,lnewindex,
       ctime_zone_format))
    ENDIF
   ENDIF
   SET snewdatetime = trim(snewdatetime)
   RETURN(snewdatetime)
 END ;Subroutine
 SUBROUTINE utcshorttz(lindex)
   DECLARE offset = i2 WITH protect, noconstant(0)
   DECLARE daylight = i2 WITH protect, noconstant(0)
   DECLARE lnewindex = i4 WITH protect, noconstant(curtimezoneapp)
   DECLARE snewshorttz = vc WITH protect, noconstant(" ")
   DECLARE ctime_zone_format = i2 WITH protect, constant(7)
   IF (cutc=1)
    IF (lindex > 0)
     SET lnewindex = lindex
    ENDIF
    SET snewshorttz = datetimezonebyindex(lnewindex,offset,daylight,ctime_zone_format)
   ENDIF
   SET snewshorttz = trim(snewshorttz)
   RETURN(snewshorttz)
 END ;Subroutine
 DECLARE ddomain_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",339,"CENSUS"))
 DECLARE dencntr_id = f8
 DECLARE sdisp_cat = vc
 DECLARE ddisp_cat_cd = f8
 DECLARE spat_loc = vc
 DECLARE dpat_loc_cd = f8
 DECLARE cprotocol = i4 WITH protect, constant(7)
 DECLARE nquit = i2
 DECLARE nskip = i2 WITH protect, noconstant(0)
 DECLARE nfoundall = i2
 DECLARE nfoundloc = i2
 DECLARE iprodsize = i4
 DECLARE imanfsize = i4
 DECLARE sadrloc = vc
 DECLARE dfreq_id = f8
 DECLARE dfreq_type = f8
 DECLARE dprnind = f8
 DECLARE dunscheduled_dispense_pref = f8
 DECLARE dtotal_dispensed_doses = f8
 DECLARE dpar_doses = f8
 DECLARE dprn_fill_time = f8
 DECLARE dprn_fill_time_unit = f8
 DECLARE dfill_time = f8
 DECLARE dfill_time_unit = f8
 DECLARE fill_run_time = dq8
 DECLARE ddiscontinue_qual_begin_dt_tm = f8
 DECLARE ddiscontinue_qual_end_dt_tm = f8
 DECLARE dsuspend_qual_begin_dt_tm = f8
 DECLARE dsuspend_qual_end_dt_tm = f8
 DECLARE dsusp_offset = f8
 DECLARE ddc_offset = f8
 DECLARE dprev_fill_dt_tm = f8
 DECLARE susp_dt_tm = dq8
 DECLARE stop_dt_tm = dq8
 DECLARE start_date_time = dq8
 DECLARE sstatus = vc
 DECLARE dstop_type_cd = f8
 DECLARE fill_cycle_to_dt_tm = dq8
 DECLARE fill_cycle_from_dt_tm = dq8
 DECLARE npatient_own_med_ind = i2
 DECLARE start_disp_dt = dq8
 DECLARE next_dispense_dt = dq8
 DECLARE dfuture_nu = f8
 DECLARE nfloorstockoverride = i2
 DECLARE dbatch_cnt = f8
 DECLARE nsuspend_ind = i2 WITH protect, noconstant(0)
 DECLARE smessage1 = vc WITH protect, noconstant("")
 DECLARE smessage2 = vc WITH protect, noconstant("")
 DECLARE slocaldatetime = vc WITH protect, noconstant("")
 DECLARE dinpatient = f8 WITH protect, constant(uar_get_code_by("MEANING",4500,"INPATIENT"))
 DECLARE dsystem = f8 WITH protect, constant(uar_get_code_by("MEANING",4062,"SYSTEM"))
 DECLARE dsoft_stop_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4009,"SOFT"))
 DECLARE dsuspend = f8 WITH protect, constant(uar_get_code_by("MEANING",6003,"SUSPEND"))
 DECLARE dresume = f8 WITH protect, constant(uar_get_code_by("MEANING",6003,"RESUME"))
 DECLARE dinitialdose = f8 WITH protect, constant(uar_get_code_by("MEANING",4032,"INITIALDOSE"))
 DECLARE dfilllist = f8 WITH protect, constant(uar_get_code_by("MEANING",4032,"FILLLIST"))
 DECLARE stempstring = vc WITH protect, noconstant("")
 SET smessage1 = uar_i18ngetmessage(i18nhandle,"sCap1","Fill batch:")
 SET outputs->writethis[ncnt].line = concat(smessage1,cnvtstring( $BATCH_CD))
 SET ncnt = (ncnt+ 1)
 IF (( $BATCH_CD <= 0))
  SET outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap2",
   "Batch code provided is not greater than 0")
  SET ncnt = (ncnt+ 1)
  GO TO end_script
 ENDIF
 IF (( $ORDER_ID <= 0))
  SET outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap3",
   "Order id provided is not greater than 0")
  SET ncnt = (ncnt+ 1)
  GO TO end_script
 ENDIF
 IF (( $FILL_HX <= 0))
  SET outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap4",
   "Fill hx id provided is not greater than 0")
  SET ncnt = (ncnt+ 1)
  GO TO end_script
 ENDIF
 SELECT INTO "NL:"
  FROM fill_batch_hx fbh
  WHERE (fbh.fill_hx_id= $FILL_HX)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap5",
   "Fill hx id provided does not exist on fill_batch_hx")
  SET ncnt = (ncnt+ 1)
  GO TO end_script
 ENDIF
 SELECT DISTINCT INTO "NL:"
  fb.fill_batch_cd
  FROM fill_batch fb
  WHERE (fb.fill_batch_cd= $BATCH_CD)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap9","sel")
  SET ncnt = (ncnt+ 1)
  GO TO end_script
 ELSE
  SET outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap10",
   "Found Fill Batch on fill_batch table")
  SET ncnt = (ncnt+ 1)
 ENDIF
 SELECT INTO "NL:"
  FROM fill_batch_hx fbh
  WHERE (fbh.fill_hx_id= $FILL_HX)
   AND (fbh.fill_batch_cd= $BATCH_CD)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap6",
   "Fill hx id provided is not for the batch code provided")
  SET ncnt = (ncnt+ 1)
  GO TO end_script
 ELSE
  SET smessage1 = uar_i18ngetmessage(i18nhandle,"sCap7","Fill hx id")
  SET smessage2 = uar_i18ngetmessage(i18nhandle,"sCap8","is valid")
  SET outputs->writethis[ncnt].line = build(smessage1," (", $FILL_HX,") ",smessage2)
  SET ncnt = (ncnt+ 1)
 ENDIF
 SET sstatus = "S"
 SELECT DISTINCT INTO "NL:"
  cv.code_value
  FROM code_value cv
  WHERE (cv.code_value= $BATCH_CD)
   AND active_ind=1
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap11",
   "fill_batch_cd not active on code_value table")
  SET ncnt = (ncnt+ 1)
  GO TO end_script
 ELSE
  SET outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap12",
   "Fill batch active on code_value")
  SET ncnt = (ncnt+ 1)
 ENDIF
 SELECT INTO "NL:"
  FROM dispense_hx dh
  PLAN (dh
   WHERE (dh.fill_hx_id= $FILL_HX)
    AND (dh.order_id= $ORDER_ID))
  WITH nocounter
 ;end select
 IF (( $MODE=0))
  IF (curqual > 0)
   SET smessage1 = uar_i18ngetmessage(i18nhandle,"sCap144","Order id found on")
   SET smessage2 = uar_i18ngetmessage(i18nhandle,"sCap145"," for provided fill hx id")
   SET outputs->writethis[ncnt].line = build(smessage1," DISPENSE_HX",smessage2)
   SET ncnt = (ncnt+ 1)
   SET outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap13",
    "Order qualified for fill run")
   SET ncnt = (ncnt+ 1)
   SET sstatus = "F"
  ENDIF
 ELSE
  IF (curqual=0)
   SET smessage1 = uar_i18ngetmessage(i18nhandle,"sCap17","Order did not qualify for fill run")
   SET outputs->writethis[ncnt].line = smessage1
   SET ncnt = (ncnt+ 1)
   SET sstatus = "F"
  ENDIF
 ENDIF
 IF (sstatus="F")
  GO TO end_script
 ENDIF
 SELECT INTO "NL:"
  FROM fill_batch_hx fbh
  WHERE (fbh.fill_batch_cd= $BATCH_CD)
   AND (fbh.fill_hx_id <  $FILL_HX)
   AND fbh.def_operation_flag IN (1, 2, 3)
  ORDER BY fill_hx_id DESC
  DETAIL
   dprev_fill_dt_tm = fbh.fill_dt_tm
  WITH maxqual(fbh,1)
 ;end select
 SELECT INTO "NL:"
  FROM fill_batch_hx fbh
  WHERE (fbh.fill_hx_id= $FILL_HX)
  DETAIL
   fill_run_time = fbh.fill_dt_tm, fill_cycle_to_dt_tm = fbh.to_dt_tm, fill_cycle_from_dt_tm = fbh
   .from_dt_tm,
   dprn_fill_time = fbh.prn_fill_time, dprn_fill_time_unit = fbh.prn_fill_unit_flag, dfill_time = fbh
   .fill_time,
   dfill_time_unit = fbh.fill_unit_flag,
   CALL echo(build("fill_cycle_from_dt_tm: ",fill_cycle_from_dt_tm)),
   CALL echo(build("fill_cycle_to_dt_tm: ",fill_cycle_to_dt_tm)),
   slocaldatetime = utcdatetime(fbh.from_dt_tm,0,1,"@SHORTDATETIME"), smessage1 = uar_i18ngetmessage(
    i18nhandle,"sCap20","fill_batch_hx.from_dt_tm is:"), outputs->writethis[ncnt].line = build(
    smessage1,slocaldatetime),
   ncnt = (ncnt+ 1), slocaldatetime = utcdatetime(fbh.to_dt_tm,0,1,"@SHORTDATETIME"), smessage1 =
   uar_i18ngetmessage(i18nhandle,"sCap21","fill_batch_hx.to_dt_tm is:"),
   outputs->writethis[ncnt].line = build(smessage1,slocaldatetime), ncnt = (ncnt+ 1)
   IF ( NOT (fbh.def_operation_flag IN (1, 2, 3)))
    outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap22",
     "Operation for the provided fill hx id is not initial/update/final"), ncnt = (ncnt+ 1), sstatus
     = "F"
   ENDIF
   IF (fbh.from_dt_tm < fbh.fill_dt_tm)
    ncnt = (ncnt+ 1), slocaldatetime = utcdatetime(fbh.from_dt_tm,0,1,"@SHORTDATETIME"), smessage1 =
    uar_i18ngetmessage(i18nhandle,"sCap23","fill_batch_hx.from_dt_tm is:"),
    outputs->writethis[ncnt].line = build(smessage1,slocaldatetime), ncnt = (ncnt+ 1), slocaldatetime
     = utcdatetime(fbh.fill_dt_tm,0,1,"@SHORTDATETIME"),
    smessage1 = uar_i18ngetmessage(i18nhandle,"sCap24",
     "Cycle 'from' time is prior to the fill run date/time of:"), outputs->writethis[ncnt].line =
    build("*** ",smessage1,slocaldatetime," ***"), ncnt = (ncnt+ 1),
    outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap25",
     "Fill run included past time, invalid scenario. Unexpected results may occur"), ncnt = (ncnt+ 2)
   ENDIF
   CALL echo(build("Operation flag: ",fbh.def_operation_flag))
   IF (fbh.def_operation_flag=1)
    IF (fbh.suspend_unit_flag=1)
     dsusp_offset = (cnvtreal(fbh.suspend_time)/ 1440.0)
    ELSEIF (fbh.suspend_unit_flag=2)
     dsusp_offset = (cnvtreal(fbh.suspend_time)/ 24.0)
    ELSE
     dsusp_offset = cnvtreal(fbh.suspend_time)
    ENDIF
    CALL echo(build("Susp offset (days): ",dsusp_offset))
    IF (fbh.discontinue_unit_flag=1)
     ddc_offset = (cnvtreal(fbh.discontinue_time)/ 1440.0)
    ELSEIF (fbh.discontinue_unit_flag=2)
     ddc_offset = (cnvtreal(fbh.discontinue_time)/ 24.0)
    ELSE
     ddc_offset = cnvtreal(fbh.discontinue_time)
    ENDIF
    CALL echo(build("DC offset (days): ",ddc_offset)), dsusp_offset = (dsusp_offset * - (1)),
    dsuspend_qual_begin_dt_tm = datetimeadd(fbh.from_dt_tm,dsusp_offset),
    dsuspend_qual_end_dt_tm = cnvtdatetime(fbh.from_dt_tm), ddc_offset = (ddc_offset * - (1)),
    ddiscontinue_qual_begin_dt_tm = datetimeadd(fbh.from_dt_tm,ddc_offset),
    ddiscontinue_qual_end_dt_tm = cnvtdatetime(fbh.from_dt_tm)
   ENDIF
   IF (fbh.def_operation_flag IN (2, 3))
    dsuspend_qual_begin_dt_tm = cnvtdatetime(dprev_fill_dt_tm), dsuspend_qual_end_dt_tm =
    cnvtdatetime(fbh.fill_dt_tm), ddiscontinue_qual_begin_dt_tm = cnvtdatetime(dprev_fill_dt_tm),
    ddiscontinue_qual_end_dt_tm = cnvtdatetime(fbh.fill_dt_tm)
   ENDIF
  WITH nocounter
 ;end select
 IF (sstatus="F")
  GO TO end_script
 ENDIF
 SET outputs->writethis[ncnt].line = ""
 SET ncnt = (ncnt+ 1)
 SET smessage1 = uar_i18ngetmessage(i18nhandle,"sCap26","ORDER_ID:")
 SET outputs->writethis[ncnt].line = build(smessage1, $ORDER_ID)
 SET ncnt = (ncnt+ 1)
 SET slocaldatetime = utcdatetime(fill_run_time,0,1,"@SHORTDATETIME")
 SET smessage1 = uar_i18ngetmessage(i18nhandle,"sCap27","Fill run time:")
 SET outputs->writethis[ncnt].line = build(smessage1,slocaldatetime)
 SET ncnt = (ncnt+ 1)
 CALL echo(build("fill run time: ",format(fill_run_time,";;q")))
 SELECT INTO "NL:"
  FROM order_detail odt
  PLAN (odt
   WHERE (odt.order_id= $ORDER_ID)
    AND odt.oe_field_meaning IN ("DISPENSECATEGORY", "FREQSCHEDID", "SCH/PRN", "STOPDTTM",
   "RXSTARTDISPDTTM",
   "PATOWNMED", "STOPTYPE", "REQSTARTDTTM", "PARDOSES")
    AND odt.updt_dt_tm <= cnvtdatetime(fill_run_time))
  ORDER BY odt.order_id, odt.action_sequence
  HEAD odt.order_id
   CALL echo("head odt.order_id"), dprnind = 0, npatient_own_med_ind = 0
  DETAIL
   CALL echo(build("order_detail action_sequence: ",odt.action_sequence))
   CASE (odt.oe_field_meaning)
    OF "DISPENSECATEGORY":
     sdisp_cat = uar_get_code_display(odt.oe_field_value),ddisp_cat_cd = odt.oe_field_value,
     CALL echo(build("sDisp_cat: ",sdisp_cat))
    OF "FREQSCHEDID":
     dfreq_id = odt.oe_field_value,
     CALL echo(build("freq_id: ",dfreq_id))
    OF "SCH/PRN":
     dprnind = odt.oe_field_value,
     CALL echo(build("PrnInd: ",dprnind))
    OF "STOPDTTM":
     stop_dt_tm = odt.oe_field_dt_tm_value,
     CALL echo(build("Stop_dt_tm: ",format(stop_dt_tm,";;q")))
    OF "RXSTARTDISPDTTM":
     start_disp_dt = odt.oe_field_dt_tm_value,
     CALL echo(build("Start_disp_dt: ",format(start_disp_dt,";;q")))
    OF "PATOWNMED":
     npatient_own_med_ind = odt.oe_field_value,
     CALL echo(build("Patient_own_med_ind: ",npatient_own_med_ind))
    OF "STOPTYPE":
     dstop_type_cd = odt.oe_field_value,
     CALL echo(build("dStop_type_cd: ",dstop_type_cd))
    OF "REQSTARTDTTM":
     start_date_time = odt.oe_field_dt_tm_value,
     CALL echo(build("Start_date_time: ",format(start_date_time,";;q")))
    OF "PARDOSES":
     dpar_doses = odt.oe_field_value,
     CALL echo(build("Par doses: ",dpar_doses))
   ENDCASE
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap141",
   "Order id not found on order_detail table")
  SET ncnt = (ncnt+ 1)
 ENDIF
 SELECT INTO "NL:"
  o.order_id
  FROM orders o,
   order_dispense od
  PLAN (o
   WHERE (o.order_id= $ORDER_ID))
   JOIN (od
   WHERE o.order_id=od.order_id)
  ORDER BY od.order_id
  HEAD od.order_id
   CALL echo("head od.order_id"), dencntr_id = o.encntr_id, dtotal_dispensed_doses = od
   .total_dispense_doses,
   susp_dt_tm = o.suspend_effective_dt_tm, next_dispense_dt = od.next_dispense_dt_tm
   IF (od.encntr_id=0)
    CALL echo("Future order"), dfuture_nu = od.future_loc_nurse_unit_cd
   ENDIF
   IF (o.need_rx_verify_ind=1)
    outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap28",
     "order id is unverified on the orders table"), ncnt = (ncnt+ 1)
   ELSEIF (o.template_order_flag=cprotocol)
    smessage1 = uar_i18ngetmessage(i18nhandle,"sCap29","is protocol"), outputs->writethis[ncnt].line
     = build("orders.template_order_flag ",smessage1), ncnt = (ncnt+ 1),
    sstatus = "F"
   ENDIF
   IF (od.ignore_ind=1)
    outputs->writethis[ncnt].line = "order_dispense.ignore_ind = 1", ncnt = (ncnt+ 1), sstatus = "F"
   ELSEIF (od.print_ind != 1)
    smessage1 = uar_i18ngetmessage(i18nhandle,"sCap30","is not 1"), outputs->writethis[ncnt].line =
    build("order_dispense.print_ind ",smessage1), ncnt = (ncnt+ 1),
    sstatus = "F"
   ELSEIF (od.order_dispense_ind != 1)
    smessage1 = uar_i18ngetmessage(i18nhandle,"sCap31","is not 1"), outputs->writethis[ncnt].line =
    build("order_dispense.order_dispense_ind ",smessage1), ncnt = (ncnt+ 1),
    sstatus = "F"
   ELSEIF (od.floorstock_override_ind=1)
    smessage1 = uar_i18ngetmessage(i18nhandle,"sCap32","always dispense from floorstock"), outputs->
    writethis[ncnt].line = build("order_dispense.floorstock_override_ind = 1; ",smessage1), ncnt = (
    ncnt+ 1),
    sstatus = "F"
   ELSEIF (od.floorstock_override_ind=2)
    smessage1 = uar_i18ngetmessage(i18nhandle,"sCap33","always dispense from Pharmacy"), outputs->
    writethis[ncnt].line = build("order_dispense.floorstock_override_ind = 2; ",smessage1), ncnt = (
    ncnt+ 1),
    nfloorstockoverride = 2
   ENDIF
   CALL echo(build("od.next_dispense_dt_tm: ",format(od.next_dispense_dt_tm,";;q")))
   IF (start_date_time=stop_dt_tm
    AND od.next_dispense_dt_tm > start_date_time
    AND  NOT (od.stop_dt_tm IN (null, 0))
    AND  NOT (od.stop_type_cd IN (0, dsoft_stop_cd)))
    outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap34","Order is One Time order"),
    ncnt = (ncnt+ 1), smessage1 = uar_i18ngetmessage(i18nhandle,"sCap138"," is equal to "),
    outputs->writethis[ncnt].line = build("Order_Detail REQSTARTDTTM",smessage1,
     " Order_Detail STOPDTTM"), ncnt = (ncnt+ 1), smessage1 = uar_i18ngetmessage(i18nhandle,"sCap139",
     "and"),
    smessage2 = uar_i18ngetmessage(i18nhandle,"sCap140"," is greater than"), outputs->writethis[ncnt]
    .line = build(smessage1," order_dispense.next_dispense_dt_tm",smessage2,
     " Order_Detail REQSTARTDTTM"), ncnt = (ncnt+ 1),
    slocaldatetime = utcdatetime(start_date_time,0,1,"@SHORTDATETIME"), outputs->writethis[ncnt].line
     = build("Order_Detail REQSTARTDTTM: ",slocaldatetime), ncnt = (ncnt+ 1),
    slocaldatetime = utcdatetime(stop_dt_tm,0,1,"@SHORTDATETIME"), outputs->writethis[ncnt].line =
    build("Order_Detail STOPDTTM: ",slocaldatetime), ncnt = (ncnt+ 1),
    slocaldatetime = utcdatetime(od.next_dispense_dt_tm,0,1,"@SHORTDATETIME"), outputs->writethis[
    ncnt].line = build("order_dispense.next_dispense_dt_tm: ",slocaldatetime), ncnt = (ncnt+ 1),
    outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap154","Order will not qualify"),
    ncnt = (ncnt+ 1), outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap155",
     "Next dispense indicates that the dose has already been dispensed"),
    ncnt = (ncnt+ 1), sstatus = "F"
   ENDIF
   slocaldatetime = utcdatetime(start_date_time,0,1,"@SHORTDATETIME"), smessage1 = uar_i18ngetmessage
   (i18nhandle,"sCap35"," at the time of the fill run is:"), outputs->writethis[ncnt].line = build(
    "Order_Detail REQSTARTDTTM",smessage1,slocaldatetime),
   ncnt = (ncnt+ 1), slocaldatetime = utcdatetime(o.orig_order_dt_tm,0,1,"@SHORTDATETIME"), smessage1
    = uar_i18ngetmessage(i18nhandle,"sCap36","orders.orig_order_dt_tm is:"),
   outputs->writethis[ncnt].line = build(smessage1,slocaldatetime), ncnt = (ncnt+ 1)
   IF (start_date_time > fill_cycle_to_dt_tm)
    slocaldatetime = utcdatetime(fill_cycle_to_dt_tm,0,1,"@SHORTDATETIME"), smessage1 =
    uar_i18ngetmessage(i18nhandle,"sCap37","start_dt_tm is after cycle to time of:"), smessage2 =
    uar_i18ngetmessage(i18nhandle,"sCap38","  Order has not started yet"),
    outputs->writethis[ncnt].line = build(smessage1,slocaldatetime,smessage2), ncnt = (ncnt+ 1),
    sstatus = "F"
   ELSEIF (o.orig_order_dt_tm > fill_run_time)
    slocaldatetime = utcdatetime(fill_run_time,0,1,"@SHORTDATETIME"), smessage1 = uar_i18ngetmessage(
     i18nhandle,"sCap39"," is after the fill run time of:"), smessage2 = uar_i18ngetmessage(
     i18nhandle,"sCap40","  Order was entered after the fill was ran"),
    outputs->writethis[ncnt].line = build("orders.orig_order_dt_tm ",smessage1,slocaldatetime,
     smessage2), ncnt = (ncnt+ 1), sstatus = "F"
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap41",
   "order id provided is not found on the orders or order_dispense table")
  SET ncnt = (ncnt+ 1)
  GO TO end_script
 ELSEIF (sstatus="F")
  GO TO end_script
 ENDIF
 SET outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap42",
  "Checking if order was verified at the time the fill ran")
 SET ncnt = (ncnt+ 1)
 SELECT INTO "NL:"
  FROM order_action oa
  WHERE (oa.order_id= $ORDER_ID)
   AND oa.action_dt_tm < cnvtdatetime(fill_run_time)
  ORDER BY oa.action_sequence DESC
  HEAD oa.order_id
   CALL echo(build("oa.order_id: ",oa.order_id))
  HEAD oa.action_sequence
   CALL echo(build("oa.action_seq: ",oa.action_sequence))
   IF (oa.needs_verify_ind IN (3, 5))
    IF (oa.updt_dt_tm > fill_run_time)
     slocaldatetime = utcdatetime(oa.updt_dt_tm,0,1,"@SHORTDATETIME"), smessage1 = uar_i18ngetmessage
     (i18nhandle,"sCap43","Verify action occured at:"), outputs->writethis[ncnt].line = build(
      smessage1,slocaldatetime),
     ncnt = (ncnt+ 1), slocaldatetime = utcdatetime(fill_run_time,0,1,"@SHORTDATETIME"), smessage1 =
     uar_i18ngetmessage(i18nhandle,"sCap44","This is after the fill run time of:"),
     outputs->writethis[ncnt].line = build(smessage1,slocaldatetime), ncnt = (ncnt+ 1), sstatus = "F"
    ENDIF
   ENDIF
  FOOT  oa.order_id
   IF (sstatus != "F")
    outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap142",
     "Order was verified at the time of the fill run"), ncnt = (ncnt+ 1)
   ENDIF
  WITH maxrec = 1
 ;end select
 IF (sstatus="F")
  GO TO end_script
 ELSE
  SET outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap45",
   "order id valid and not one-time")
  SET ncnt = (ncnt+ 1)
 ENDIF
 SET outputs->writethis[ncnt].line = ""
 SET ncnt = (ncnt+ 1)
 IF (dencntr_id > 0)
  SELECT DISTINCT INTO "NL:"
   e.encntr_id
   FROM encounter e,
    encntr_domain ed
   PLAN (e
    WHERE e.encntr_id=dencntr_id)
    JOIN (ed
    WHERE e.encntr_id=ed.encntr_id)
   DETAIL
    slocaldatetime = utcdatetime(ed.end_effective_dt_tm,0,1,"@SHORTDATETIME"),
    CALL echo(build("ed.end_effective_dt_tm; sLocalDateTime: ",slocaldatetime)),
    CALL echo(cnvtdatetime(slocaldatetime))
    IF (ed.active_ind=0)
     smessage1 = uar_i18ngetmessage(i18nhandle,"sCap46","encounter id"), smessage2 =
     uar_i18ngetmessage(i18nhandle,"sCap47"," is inactive on"), outputs->writethis[ncnt].line = build
     (smessage1,e.encntr_id,smessage2," encntr_domain"),
     ncnt = (ncnt+ 1)
    ELSEIF (ed.end_effective_dt_tm < cnvtdatetime(fill_run_time))
     smessage1 = uar_i18ngetmessage(i18nhandle,"sCap48","encounter id"), smessage2 =
     uar_i18ngetmessage(i18nhandle,"sCap49"," < fill run time"), outputs->writethis[ncnt].line =
     build(smessage1,e.encntr_id,"encntr_domain.end_effective_dt_tm ",smessage2),
     ncnt = (ncnt+ 1)
    ELSEIF (ed.encntr_domain_type_cd != ddomain_type_cd)
     smessage1 = uar_i18ngetmessage(i18nhandle,"sCap50","encounter id"), smessage2 =
     uar_i18ngetmessage(i18nhandle,"sCap51"," is not CENSUS"), outputs->writethis[ncnt].line = build(
      smessage1,e.encntr_id," encntr_domain.encntr_domain_type_cd ",smessage2),
     ncnt = (ncnt+ 1)
    ELSE
     IF (ed.loc_nurse_unit_cd > 0)
      dpat_loc_cd = ed.loc_nurse_unit_cd, spat_loc = uar_get_code_display(ed.loc_nurse_unit_cd),
      smessage1 = uar_i18ngetmessage(i18nhandle,"sCap52","encounter id:"),
      smessage2 = uar_i18ngetmessage(i18nhandle,"sCap53"," is valid"), outputs->writethis[ncnt].line
       = build(smessage1,e.encntr_id,smessage2), ncnt = (ncnt+ 1)
     ELSE
      outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap54",
       "encntr_domain.loc_nurse_unit_cd is 0"), ncnt = (ncnt+ 1)
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET smessage1 = uar_i18ngetmessage(i18nhandle,"sCap55","encounter id")
   SET smessage2 = uar_i18ngetmessage(i18nhandle,"sCap56",
    " is not found on the encounter or encntr_domain table")
   SET outputs->writethis[ncnt].line = build(smessage1,dencntr_id,smessage2)
   SET ncnt = (ncnt+ 1)
   GO TO end_script
  ENDIF
  CALL echo("finding patient's location at the time of the fill run")
  SET smessage1 = uar_i18ngetmessage(i18nhandle,"sCap57",
   "Finding patient's location at the time of the fill run")
  SET outputs->writethis[ncnt].line = smessage1
  SET ncnt = (ncnt+ 1)
  SELECT INTO "NL:"
   FROM encntr_loc_hist elh
   WHERE elh.encntr_id=dencntr_id
    AND dencntr_id > 0
    AND cnvtdatetime(fill_run_time) BETWEEN elh.beg_effective_dt_tm AND elh.end_effective_dt_tm
   DETAIL
    dpat_loc_cd = elh.loc_nurse_unit_cd, spat_loc = uar_get_code_display(elh.loc_nurse_unit_cd),
    smessage1 = uar_i18ngetmessage(i18nhandle,"sCap58","encntr_loc_hist shows the encounter was at "),
    smessage2 = uar_i18ngetmessage(i18nhandle,"sCap59"," when the fill ran"), outputs->writethis[ncnt
    ].line = build(smessage1,spat_loc,smessage2), ncnt = (ncnt+ 1)
   WITH nocounter
  ;end select
 ELSE
  SET outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap60",
   "order_dispense.encntr_id is 0 using future location")
  SET ncnt = (ncnt+ 1)
  SET dpat_loc_cd = dfuture_nu
  SET spat_loc = uar_get_code_display(dfuture_nu)
 ENDIF
 SET outputs->writethis[ncnt].line = " "
 SET ncnt = (ncnt+ 1)
 SET smessage1 = uar_i18ngetmessage(i18nhandle,"sCap61","ORDER_ID: ")
 SET outputs->writethis[ncnt].line = build(smessage1, $ORDER_ID)
 SET ncnt = (ncnt+ 1)
 SET smessage1 = uar_i18ngetmessage(i18nhandle,"sCap62","DISPENSE CATEGORY:")
 SET outputs->writethis[ncnt].line = build(smessage1,sdisp_cat," (",ddisp_cat_cd,")")
 SET ncnt = (ncnt+ 1)
 SET smessage1 = uar_i18ngetmessage(i18nhandle,"sCap63","NURSE UNIT:")
 SET outputs->writethis[ncnt].line = build(smessage1," ",spat_loc," (",dpat_loc_cd,
  ")")
 SET ncnt = (ncnt+ 1)
 SET outputs->writethis[ncnt].line = " "
 SET ncnt = (ncnt+ 1)
 SET outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap64",
  "Checking to see if dispense category and nurse unit are on the fill batch")
 SET ncnt = (ncnt+ 1)
 SELECT DISTINCT INTO "NL:"
  fcb.fill_batch_cd
  FROM fill_cycle_batch fcb
  WHERE (fcb.fill_batch_cd= $BATCH_CD)
   AND fcb.dispense_category_cd=ddisp_cat_cd
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap65",
   "dispense category does not match any defined on the fill batch")
  SET ncnt = (ncnt+ 1)
  GO TO end_script
 ELSE
  SET outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap66",
   "dispense category matches")
  SET ncnt = (ncnt+ 1)
 ENDIF
 SELECT DISTINCT INTO "NL:"
  fcb.fill_batch_cd
  FROM fill_cycle_batch fcb
  WHERE (fcb.fill_batch_cd= $BATCH_CD)
   AND fcb.location_cd=dpat_loc_cd
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap67",
   "Location does not match any defined on the fill_batch")
  SET ncnt = (ncnt+ 1)
  SET outputs->writethis[ncnt].line = " "
  SET ncnt = (ncnt+ 1)
  GO TO end_script
 ELSE
  SET outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap68","Location Matches")
  SET ncnt = (ncnt+ 1)
  SET outputs->writethis[ncnt].line = " "
  SET ncnt = (ncnt+ 1)
 ENDIF
 SELECT INTO "NL:"
  batch = uar_get_code_display(fcb.fill_batch_cd)
  FROM fill_cycle_batch fcb,
   code_value cv
  PLAN (fcb
   WHERE fcb.dispense_category_cd=ddisp_cat_cd
    AND fcb.location_cd=dpat_loc_cd)
   JOIN (cv
   WHERE fcb.fill_batch_cd=cv.code_value
    AND cv.active_ind=1)
  HEAD REPORT
   dbatch_cnt = 0, outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap69",
    "Dispense category and Location are part of the following fill batches:"), ncnt = (ncnt+ 1)
  DETAIL
   dbatch_cnt = (dbatch_cnt+ 1), outputs->writethis[ncnt].line = build(batch," (",fcb.fill_batch_cd,
    ")"), ncnt = (ncnt+ 1)
  FOOT REPORT
   IF (dbatch_cnt > 1)
    outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap70",
     "Multiple batches are displayed evaluate this further to ensure"), ncnt = (ncnt+ 1), outputs->
    writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap71","the fill batches are cascading"),
    ncnt = (ncnt+ 1), outputs->writethis[ncnt].line = " ", ncnt = (ncnt+ 1)
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("Check if the dispense category is set to 0 specified doses")
 SELECT INTO "NL:"
  FROM dispense_category dc
  PLAN (dc
   WHERE dc.dispense_category_cd=ddisp_cat_cd)
  DETAIL
   CALL echo(build("dc.disp_fill_qty_ind: ",dc.disp_fill_qty_ind)),
   CALL echo(build("dc.disp_fill_days_supply_amt: ",dc.disp_fill_days_supply_amt)),
   CALL echo(build("dc.dc.disp_fill_days_supply_ind: ",dc.disp_fill_days_supply_ind))
   IF (dc.disp_fill_qty_ind=0)
    outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap72",
     "Dispense category is built as specified 0 doses"), ncnt = (ncnt+ 1), sstatus = "F"
   ELSEIF (dc.disp_fill_days_supply_amt=0
    AND dc.disp_fill_days_supply_ind=1)
    outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap73",
     "Dispense category is built as specified 0 day supply"), ncnt = (ncnt+ 1), sstatus = "F"
   ENDIF
  WITH nocounter
 ;end select
 IF (sstatus="F")
  GO TO end_script
 ENDIF
 IF (nfloorstockoverride=2)
  SET smessage1 = uar_i18ngetmessage(i18nhandle,"sCap74","skipping stored_at check")
  SET outputs->writethis[ncnt].line = concat("order_dispense.floorstock_override_ind = 2; ",smessage1
   )
  SET ncnt = (ncnt+ 1)
 ELSE
  SET outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap75",
   "Check if order is floorstock")
  SET ncnt = (ncnt+ 1)
  SELECT INTO "NL:"
   FROM order_product op,
    stored_at sa
   PLAN (op
    WHERE (op.order_id= $ORDER_ID))
    JOIN (sa
    WHERE op.item_id=sa.item_id)
   ORDER BY sa.item_id
   HEAD REPORT
    nquit = 0, nfoundall = 0
   HEAD sa.item_id
    CALL echo(build("Item id: ",sa.item_id)), nfoundloc = 0
   DETAIL
    CALL echo(build("nQuit = ",nquit)),
    CALL echo(build("Location: ",sa.location_cd))
    IF (sa.location_cd=dpat_loc_cd
     AND nquit=0)
     CALL echo("item stored at patient location"), nfoundloc = 1
    ENDIF
   FOOT  sa.item_id
    IF (nfoundloc=1)
     nquit = 0, nfoundall = 1, smessage1 = uar_i18ngetmessage(i18nhandle,"sCap76","Item:"),
     smessage2 = uar_i18ngetmessage(i18nhandle,"sCap77"," stored at NURSE UNIT:"), outputs->
     writethis[ncnt].line = build(smessage1,sa.item_id,smessage2,spat_loc," (",
      dpat_loc_cd,")"), ncnt = (ncnt+ 1)
    ELSE
     nquit = 1, nfoundall = 0, smessage1 = uar_i18ngetmessage(i18nhandle,"sCap78","Item:"),
     smessage2 = uar_i18ngetmessage(i18nhandle,"sCap79"," NOT stored at NURSE UNIT:"), outputs->
     writethis[ncnt].line = build(smessage1,sa.item_id,smessage2,spat_loc," (",
      dpat_loc_cd,")"), ncnt = (ncnt+ 1)
    ENDIF
   WITH nocounter
  ;end select
  IF (nfoundall=1)
   SET sstatus = "F"
   SET smessage1 = uar_i18ngetmessage(i18nhandle,"sCap80",
    "All items on the order are stored at the patient's location")
   SET outputs->writethis[ncnt].line = smessage1
   SET ncnt = (ncnt+ 1)
   SET outputs->writethis[ncnt].line = " "
   SET ncnt = (ncnt+ 1)
  ELSE
   SET smessage1 = uar_i18ngetmessage(i18nhandle,"sCap81",
    "All items on the order are NOT stored at the patient's location")
   SET outputs->writethis[ncnt].line = smessage1
   SET ncnt = (ncnt+ 1)
   SET outputs->writethis[ncnt].line = " "
   SET ncnt = (ncnt+ 1)
  ENDIF
 ENDIF
 RECORD adr_request(
   1 orderlist[*]
     2 encounterid = f8
     2 workstationdispfromloccd = f8
     2 dispensecategorycd = f8
     2 prnind = i2
     2 fsoverrideflag = i2
     2 dispensedttm = dq8
     2 productlist[*]
       3 itemid = f8
       3 dispenseqty = f8
       3 alwaysdispensefromflag = i2
       3 packagetypeid = f8
       3 manflist[*]
         4 manfsequence = i2
         4 manfitemid = f8
         4 itemmasterid = f8
         4 packagetypeid = f8
       3 tnfid = f8
       3 firstdosedispenseqty = f8
     2 doseroutinglogicmask = i2
     2 futurefacilitycd = f8
     2 futurenurseunitcd = f8
 ) WITH protect
 RECORD adr_reply(
   1 orderlist[*]
     2 location_cd = f8
     2 floorstock_ind = i2
     2 inv_location_cd = f8
     2 service_resource_cd = f8
     2 service_resource_type_cd = f8
     2 bestlocprodlist[*]
       3 product_owe_ind = i2
   1 elapsed_time = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 SELECT INTO "NL:"
  FROM order_dispense od,
   order_product op,
   template_nonformulary tnf,
   med_dispense md,
   med_def_flex mdf,
   med_flex_object_idx mfoi,
   med_product mp,
   package_type pt1,
   manufacturer_item mi,
   package_type pt2
  PLAN (od
   WHERE (od.order_id= $ORDER_ID))
   JOIN (op
   WHERE op.order_id=od.order_id
    AND op.action_sequence=od.last_ver_ingr_seq)
   JOIN (tnf
   WHERE tnf.tnf_id=op.tnf_id
    AND ((tnf.action_sequence=op.action_sequence) OR (tnf.action_sequence=0)) )
   JOIN (md
   WHERE md.pharmacy_type_cd=dinpatient
    AND ((md.item_id=op.item_id) OR (md.item_id=tnf.shell_item_id))
    AND md.parent_entity_id=0
    AND md.item_id > 0)
   JOIN (pt1
   WHERE pt1.item_id=md.item_id
    AND ((pt1.active_ind+ 0)=1)
    AND ((pt1.base_package_type_ind+ 0)=1))
   JOIN (mdf
   WHERE mdf.item_id=md.item_id
    AND mdf.pharmacy_type_cd=dinpatient
    AND ((mdf.flex_type_cd+ 0)=dsystem))
   JOIN (mfoi
   WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
    AND trim(mfoi.parent_entity_name)="MED_PRODUCT")
   JOIN (mp
   WHERE mp.med_product_id=mfoi.parent_entity_id)
   JOIN (mi
   WHERE mi.item_id=mp.manf_item_id)
   JOIN (pt2
   WHERE pt2.item_id=outerjoin(mi.item_master_id)
    AND pt2.item_id > outerjoin(0)
    AND ((pt2.active_ind+ 0)=outerjoin(1))
    AND ((pt2.base_package_type_ind+ 0)=outerjoin(1)))
  ORDER BY od.order_id, op.item_id, mp.manf_item_id
  HEAD od.order_id
   iprodsize = 0, stat = alterlist(adr_request->orderlist,1), adr_request->orderlist[1].encounterid
    = dencntr_id,
   adr_request->orderlist[1].workstationdispfromloccd = 0, adr_request->orderlist[1].
   dispensecategorycd = ddisp_cat_cd, adr_request->orderlist[1].prnind = dprnind,
   adr_request->orderlist[1].fsoverrideflag = od.floorstock_override_ind, adr_request->orderlist[1].
   doseroutinglogicmask = 1, adr_request->orderlist[1].futurefacilitycd = od.future_loc_facility_cd,
   adr_request->orderlist[1].futurenurseunitcd = od.future_loc_nurse_unit_cd, adr_request->orderlist[
   1].dispensedttm = cnvtdatetime(fill_run_time)
  HEAD op.item_id
   iprodsize = (iprodsize+ 1)
   IF (iprodsize > size(adr_request->orderlist[1].productlist,5))
    stat = alterlist(adr_request->orderlist[1].productlist,(iprodsize+ 4))
   ENDIF
   adr_request->orderlist[1].productlist[iprodsize].itemid = md.item_id, adr_request->orderlist[1].
   productlist[iprodsize].tnfid = op.tnf_id, adr_request->orderlist[1].productlist[iprodsize].
   dispenseqty = op.dose_quantity,
   adr_request->orderlist[1].productlist[iprodsize].alwaysdispensefromflag = md
   .always_dispense_from_flag,
   CALL echo(build("always dispense from: ",md.always_dispense_from_flag))
   IF (md.always_dispense_from_flag=1)
    smessage1 = uar_i18ngetmessage(i18nhandle,"sCap82","is 1; always dispense from pharmacy"),
    outputs->writethis[ncnt].line = concat("med_dispense.always_dispense_from_flag ",smessage1), ncnt
     = (ncnt+ 1),
    sstatus = ""
   ELSEIF (md.always_dispense_from_flag=2
    AND nfloorstockoverride != 2)
    smessage1 = uar_i18ngetmessage(i18nhandle,"sCap83","is 2; always dispense from floorstock"),
    outputs->writethis[ncnt].line = concat("med_dispense.always_dispense_from_flag ",smessage1), ncnt
     = (ncnt+ 1),
    sstatus = "F"
   ENDIF
   adr_request->orderlist[1].productlist[iprodsize].firstdosedispenseqty = 0, adr_request->orderlist[
   1].productlist[iprodsize].packagetypeid = pt1.package_type_id
  HEAD mp.manf_item_id
   imanfsize = (imanfsize+ 1)
   IF (imanfsize > size(adr_request->orderlist[1].productlist[iprodsize].manflist,5))
    stat = alterlist(adr_request->orderlist[1].productlist[iprodsize].manflist,(imanfsize+ 4))
   ENDIF
   adr_request->orderlist[1].productlist[iprodsize].manflist[imanfsize].manfitemid = mp.manf_item_id,
   adr_request->orderlist[1].productlist[iprodsize].manflist[imanfsize].manfsequence = mfoi.sequence,
   adr_request->orderlist[1].productlist[iprodsize].manflist[imanfsize].itemmasterid = mi
   .item_master_id,
   adr_request->orderlist[1].productlist[iprodsize].manflist[imanfsize].packagetypeid = pt2
   .package_type_id
  FOOT  mp.manf_item_id
   IF (iprodsize > 0
    AND imanfsize > 0)
    stat = alterlist(adr_request->orderlist[1].productlist[iprodsize].manflist,imanfsize)
   ENDIF
  FOOT  op.item_id
   IF (iprodsize > 0)
    stat = alterlist(adr_request->orderlist[1].productlist,iprodsize)
   ENDIF
  FOOT  od.order_id
   stat = 0
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap84",
   "Could not fill out the request for rx_get_adr_best_loc; skipping ADR check")
  SET ncnt = (ncnt+ 1)
  SET outputs->writethis[ncnt].line = " "
  SET ncnt = (ncnt+ 1)
 ELSE
  SET outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap85",
   "Calling rx_get_adr_best_loc")
  SET ncnt = (ncnt+ 1)
  CALL echorecord(adr_request)
  EXECUTE rx_get_adr_best_loc  WITH replace("REQUEST","ADR_REQUEST"), replace("REPLY","ADR_REPLY")
  SET sadrloc = uar_get_code_display(adr_reply->orderlist[1].location_cd)
  SET smessage1 = uar_i18ngetmessage(i18nhandle,"sCap86","ADR routing selected location:")
  SET outputs->writethis[ncnt].line = build(smessage1,sadrloc," (",adr_reply->orderlist[1].
   location_cd,")")
  SET ncnt = (ncnt+ 1)
  IF ((adr_reply->orderlist[1].floorstock_ind=1))
   SET outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap87",
    "ADR selected floorstock location")
   SET ncnt = (ncnt+ 1)
   SET outputs->writethis[ncnt].line = " "
   SET ncnt = (ncnt+ 1)
   GO TO end_script
  ELSEIF ((adr_reply->orderlist[1].location_cd > 0))
   SET sstatus = ""
  ENDIF
 ENDIF
 IF (sstatus="F")
  SET outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap88","Order is floorstock")
  SET ncnt = (ncnt+ 1)
  GO TO end_script
 ELSE
  SET outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap89",
   "Order is not floorstock")
  SET ncnt = (ncnt+ 1)
 ENDIF
 SET stempstring = concat(
  "**** The ADR check is only capable of checking the initial dose routing hierarchy.  If the fill list ",
  "hierarchy is different this needs to be manually evaluated to ensure accurate floorstock status ****"
  )
 SET smessage1 = uar_i18ngetmessage(i18nhandle,"sCap152",nullterm(stempstring))
 SET outputs->writethis[ncnt].line = smessage1
 SET ncnt = (ncnt+ 1)
 SET outputs->writethis[ncnt].line = " "
 SET ncnt = (ncnt+ 1)
 IF (npatient_own_med_ind=1)
  SET outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap90",
   "Patient own med checking start dispense date/time")
  SET ncnt = (ncnt+ 1)
  SET slocaldatetime = utcdatetime(start_disp_dt,0,1,"@SHORTDATETIME")
  SET smessage1 = uar_i18ngetmessage(i18nhandle,"sCap91","Order_dispense.start_dispense_dt_tm:")
  SET outputs->writethis[ncnt].line = build(smessage1,slocaldatetime)
  SET ncnt = (ncnt+ 1)
  IF (start_disp_dt != null)
   SET slocaldatetime = utcdatetime(fill_cycle_to_dt_tm,0,1,"@SHORTDATETIME")
   SET smessage1 = uar_i18ngetmessage(i18nhandle,"sCap92","Fill cycle to time:")
   SET outputs->writethis[ncnt].line = build(smessage1,slocaldatetime)
   SET ncnt = (ncnt+ 1)
   CALL echo(build("Start_disp_dt: ",format(start_disp_dt,";;q")))
   CALL echo(build("fill_cycle_to_dt_tm: ",format(fill_cycle_to_dt_tm,";;q")))
   IF (start_disp_dt > fill_cycle_to_dt_tm)
    SET outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap93",
     "Start dispense dt/tm is after the fill cycle 'to' time")
    SET ncnt = (ncnt+ 1)
    GO TO end_script
   ELSE
    SET outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap94",
     "Start dispense dt/tm is prior to the fill cycle 'to' time")
    SET ncnt = (ncnt+ 1)
    SET outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap95",
     "Ensure a dose (based on the frequency schedule was due between the start")
    SET ncnt = (ncnt+ 1)
    SET outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap96",
     "dispense dt/tm and the fill cycle 'to' time")
    SET ncnt = (ncnt+ 1)
   ENDIF
  ELSE
   SET outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap97",
    "Start dispense dt/tm not filled out, treating as patient own medication.")
   SET ncnt = (ncnt+ 1)
   GO TO end_script
  ENDIF
 ENDIF
 SET ncnt = (ncnt+ 1)
 SET outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap98",
  "Checking Suspend/Discontinue status against specific fill run")
 SET ncnt = (ncnt+ 1)
 SET slocaldatetime = utcdatetime(stop_dt_tm,0,1,"@SHORTDATETIME")
 SET outputs->writethis[ncnt].line = build("Order_detail stop_dt_tm:",slocaldatetime)
 SET ncnt = (ncnt+ 1)
 IF ( NOT (stop_dt_tm IN (null, 0))
  AND  NOT (dstop_type_cd IN (0, dsoft_stop_cd))
  AND stop_dt_tm < fill_cycle_from_dt_tm)
  SET outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap99",
   "Order stops prior to the cycle 'from' time")
  SET ncnt = (ncnt+ 1)
  SET slocaldatetime = utcdatetime(fill_cycle_from_dt_tm,0,1,"@SHORTDATETIME")
  SET smessage1 = uar_i18ngetmessage(i18nhandle,"sCap100","Fill 'from' time:")
  SET outputs->writethis[ncnt].line = build(smessage1,slocaldatetime)
  SET ncnt = (ncnt+ 1)
  IF (((ddc_offset * - (1)) > 0))
   SET outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap101",
    "Fill batch includes discontinued orders")
   SET ncnt = (ncnt+ 1)
   SET slocaldatetime = utcdatetime(ddiscontinue_qual_begin_dt_tm,0,1,"@SHORTDATETIME")
   SET smessage1 = uar_i18ngetmessage(i18nhandle,"sCap102","discontinue qual begin date: ")
   SET outputs->writethis[ncnt].line = build(smessage1,slocaldatetime)
   SET ncnt = (ncnt+ 1)
   SET slocaldatetime = utcdatetime(ddiscontinue_qual_end_dt_tm,0,1,"@SHORTDATETIME")
   SET smessage1 = uar_i18ngetmessage(i18nhandle,"sCap103","discontinue qual end date: ")
   SET outputs->writethis[ncnt].line = build(smessage1,slocaldatetime)
   SET ncnt = (ncnt+ 1)
   IF (stop_dt_tm >= cnvtdatetime(ddiscontinue_qual_begin_dt_tm)
    AND stop_dt_tm <= cnvtdatetime(ddiscontinue_qual_end_dt_tm))
    SET outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap104",
     "Order stop time within the discontinue qual range")
    SET ncnt = (ncnt+ 1)
   ELSE
    SET outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap105",
     "Order DC time NOT within the discontinue qual range")
    SET ncnt = (ncnt+ 1)
    GO TO end_script
   ENDIF
  ELSE
   SET outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap106",
    "Fill batch does NOT include stopped orders")
   SET ncnt = (ncnt+ 1)
   GO TO end_script
  ENDIF
 ELSE
  SET outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap107",
   "Order was NOT discontinued prior to the cycle 'from' time or stop type is 'Soft'")
  SET ncnt = (ncnt+ 1)
  SET slocaldatetime = utcdatetime(susp_dt_tm,0,1,"@SHORTDATETIME")
  SET outputs->writethis[ncnt].line = build("Orders.suspend_effective_dt_tm:",slocaldatetime)
  SET ncnt = (ncnt+ 1)
  IF ( NOT (susp_dt_tm IN (null, 0))
   AND susp_dt_tm <= fill_cycle_from_dt_tm)
   SET outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap108",
    "Suspended date/time is prior to the cycle 'from' time")
   SET ncnt = (ncnt+ 1)
   SET slocaldatetime = utcdatetime(fill_cycle_from_dt_tm,0,1,"@SHORTDATETIME")
   SET smessage1 = uar_i18ngetmessage(i18nhandle,"sCap109","Fill 'from' time:")
   SET outputs->writethis[ncnt].line = build(smessage1,slocaldatetime)
   SET ncnt = (ncnt+ 1)
   SET nsuspend_ind = 1
  ELSE
   SET outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap110",
    "Order is not currently suspended, checking if it was suspended at the time of the fill run")
   SET ncnt = (ncnt+ 1)
   CALL echo(build("dSUSPEND: ",dsuspend))
   CALL echo(build("dRESUME: ",dresume))
   SELECT INTO "NL:"
    FROM order_action oa
    WHERE (oa.order_id= $ORDER_ID)
     AND oa.effective_dt_tm <= cnvtdatetime(fill_run_time)
     AND oa.action_type_cd IN (dsuspend, dresume)
    ORDER BY oa.action_sequence DESC
    DETAIL
     CALL echo(build("action seq: ",oa.action_sequence)),
     CALL echo(build("action type: ",oa.action_type_cd," ",uar_get_code_display(oa.action_type_cd)))
     IF (oa.action_type_cd=dsuspend)
      CALL echo("suspend action found"), outputs->writethis[ncnt].line = uar_i18ngetmessage(
       i18nhandle,"sCap111","Suspend action found"), ncnt = (ncnt+ 1),
      slocaldatetime = utcdatetime(oa.effective_dt_tm,0,1,"@SHORTDATETIME"), smessage1 =
      uar_i18ngetmessage(i18nhandle,"sCap112","Suspend effective date/time:"), outputs->writethis[
      ncnt].line = build(smessage1,slocaldatetime),
      ncnt = (ncnt+ 1), slocaldatetime = utcdatetime(fill_run_time,0,1,"@SHORTDATETIME"), smessage1
       = uar_i18ngetmessage(i18nhandle,"sCap113","Fill run time:"),
      outputs->writethis[ncnt].line = build(smessage1,slocaldatetime), ncnt = (ncnt+ 1), outputs->
      writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap114",
       "Order suspended at the time the fill ran"),
      ncnt = (ncnt+ 1), susp_dt_tm = oa.effective_dt_tm, nsuspend_ind = 1
     ENDIF
    WITH maxqual(oa,1)
   ;end select
  ENDIF
  IF (nsuspend_ind=1)
   IF (((dsusp_offset * - (1)) > 0))
    SET outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap115",
     "Fill batch includes suspended orders")
    SET ncnt = (ncnt+ 1)
    SET slocaldatetime = utcdatetime(dsuspend_qual_begin_dt_tm,0,1,"@SHORTDATETIME")
    SET smessage1 = uar_i18ngetmessage(i18nhandle,"sCap116","suspend qual begin date: ")
    SET outputs->writethis[ncnt].line = build(smessage1,slocaldatetime)
    SET ncnt = (ncnt+ 1)
    SET slocaldatetime = utcdatetime(dsuspend_qual_end_dt_tm,0,1,"@SHORTDATETIME")
    SET smessage1 = uar_i18ngetmessage(i18nhandle,"sCap117","suspend qual end date: ")
    SET outputs->writethis[ncnt].line = build(smessage1,slocaldatetime)
    SET ncnt = (ncnt+ 1)
    IF (susp_dt_tm >= cnvtdatetime(dsuspend_qual_begin_dt_tm)
     AND susp_dt_tm <= cnvtdatetime(dsuspend_qual_end_dt_tm))
     SET outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap118",
      "Order suspend time within the suspend qual range")
     SET ncnt = (ncnt+ 1)
    ELSE
     SET outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap119",
      "Order suspend time NOT within the suspend qual range")
     SET ncnt = (ncnt+ 1)
     GO TO end_script
    ENDIF
   ELSE
    SET outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap120",
     "Fill batch does NOT include suspended orders")
    SET ncnt = (ncnt+ 1)
    GO TO end_script
   ENDIF
  ELSE
   SET outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap121",
    "Order was NOT suspended at the time the fill ran")
   SET ncnt = (ncnt+ 1)
  ENDIF
 ENDIF
 SET outputs->writethis[ncnt].line = " "
 SET ncnt = (ncnt+ 1)
 SET outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap122",
  "Checking for Unscheduled non-prn order")
 SET ncnt = (ncnt+ 1)
 SELECT INTO "NL:"
  FROM frequency_schedule fs
  PLAN (fs
   WHERE fs.frequency_id=dfreq_id)
  DETAIL
   dfreq_type = fs.frequency_type
  WITH nocounter
 ;end select
 IF (dfreq_type=5
  AND dprnind=0)
  SET outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap123",
   "Unscheduled non-prn order")
  SET ncnt = (ncnt+ 1)
  SELECT INTO "nl:"
   dp.pref_nbr
   FROM dm_prefs dp
   WHERE dp.application_nbr=300000
    AND dp.person_id=0
    AND dp.pref_domain="PHARMNET"
    AND dp.pref_section="DISPENSE"
    AND dp.pref_name="UNSCHEDULED QUAL"
   HEAD dp.pref_nbr
    dunscheduled_dispense_pref = dp.pref_nbr
   WITH nocounter
  ;end select
  SET outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap124",
   "'Misc: How should the system dispense orders with an unscheduled non-PRN frequency during a fill batch run?'"
   )
  SET ncnt = (ncnt+ 1)
  IF (dunscheduled_dispense_pref=1
   AND dtotal_dispensed_doses > 0)
   SET outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap125",
    "pref set to 'One Time' and order has been dispensed, order won't qualify")
   SET ncnt = (ncnt+ 1)
   GO TO end_script
  ELSEIF (dunscheduled_dispense_pref=2)
   SET outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap126",
    "pref set to 'Never', order won't qualify")
   SET ncnt = (ncnt+ 1)
   GO TO end_script
  ELSE
   SET outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap127",
    "pref set to 'Always', order will always qualify")
   SET ncnt = (ncnt+ 1)
  ENDIF
 ELSE
  SET outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap128",
   "Order is NOT Unscheduled non-prn")
  SET ncnt = (ncnt+ 1)
 ENDIF
 SET outputs->writethis[ncnt].line = " "
 SET ncnt = (ncnt+ 1)
 SET outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap129","Checking for PRN order"
  )
 SET ncnt = (ncnt+ 1)
 CALL echo(build("dPrnInd: ",dprnind))
 CALL echo(build("dPar_doses: ",dpar_doses))
 CALL echo(build("dPrn_fill_time: ",dprn_fill_time))
 CALL echo(build("dFill_time: ",dfill_time))
 CALL echo(build("dPrn_fill_time_unit: ",dprn_fill_time_unit))
 CALL echo(build("dFill_time_unit: ",dfill_time_unit))
 IF (dpar_doses > 0
  AND dprn_fill_time=0)
  SET outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap130",
   "PRN order and the fill batch is built with a PRN fill time of 0.  Batch does not qualify PRN orders"
   )
  SET ncnt = (ncnt+ 1)
  GO TO end_script
 ELSEIF (dpar_doses=0
  AND dprnind=1)
  SET outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap148",
   "PRN order with Par Doses of 0.  Order won't qualify")
  SET ncnt = (ncnt+ 1)
  GO TO end_script
 ELSEIF (dpar_doses > 0
  AND dprn_fill_time > 0
  AND ((dprn_fill_time != dfill_time) OR (dprn_fill_time_unit != dfill_time_unit)) )
  SET outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap149",
   "Batch Qual time and PRN qual time don't match, check batch build")
  SET ncnt = (ncnt+ 1)
  GO TO end_script
 ELSE
  SET outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap131",
   "PRN check passed; order is not PRN or fill batch qualifies PRN orders")
  SET ncnt = (ncnt+ 1)
 ENDIF
 SET outputs->writethis[ncnt].line = " "
 SET ncnt = (ncnt+ 1)
 SET outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap132",
  "Checking next_dispense_dt_tm")
 SET ncnt = (ncnt+ 1)
 IF (( $MODE=0))
  SELECT INTO "NL:"
   FROM dispense_hx dh
   WHERE (dh.order_id= $ORDER_ID)
    AND dh.updt_dt_tm < cnvtdatetime(fill_run_time)
    AND dh.next_dispense_dt_tm != null
    AND dh.chrg_dispense_hx_id=0
   ORDER BY dh.dispense_hx_id DESC
   DETAIL
    CALL echo(build("dispense hx id: ",dh.dispense_hx_id)), next_dispense_dt = dh.next_dispense_dt_tm
   WITH maxrec = 1
  ;end select
  SET slocaldatetime = utcdatetime(next_dispense_dt,0,1,"@SHORTDATETIME")
  CALL echo(build("Next_dispense_dt; sLocalDateTime: ",slocaldatetime))
  CALL echo(cnvtdatetime(slocaldatetime))
  IF (curqual=0)
   CALL echo(
    "no row on dispense_hx found checking for initial dose/fill list runs since provided fill hx")
   SET smessage1 = uar_i18ngetmessage(i18nhandle,"sCap153",
    "Found no dispense events prior to the provided fill run")
   SET ncnt = (ncnt+ 1)
   SELECT INTO "NL:"
    FROM dispense_hx dh
    WHERE (dh.order_id= $ORDER_ID)
     AND dh.updt_dt_tm > cnvtdatetime(fill_run_time)
     AND dh.disp_event_type_cd IN (dinitialdose, dfilllist)
   ;end select
   IF (curqual > 0)
    CALL echo("Found initial dose/fill list event since the provided fill run")
    SET smessage1 = uar_i18ngetmessage(i18nhandle,"sCap146",
     "Found initial dose/fill list event since the provided fill run")
    SET outputs->writethis[ncnt].line = smessage1
    SET ncnt = (ncnt+ 1)
    SET smessage1 = uar_i18ngetmessage(i18nhandle,"sCap147",
     "Accurate next dispense at the time of fill run cannot be determined")
    SET outputs->writethis[ncnt].line = smessage1
    SET ncnt = (ncnt+ 1)
    SET nskip = 1
   ELSE
    CALL echo("no row on dispense_hx found using order_dispense for next_dispense_dt_tm")
    SET outputs->writethis[ncnt].line = build("order_dispense.next_dispense_dt_tm:",slocaldatetime)
    SET ncnt = (ncnt+ 1)
   ENDIF
  ELSE
   SET outputs->writethis[ncnt].line = build("dispense_hx.next_dispense_dt_tm:",slocaldatetime)
   SET ncnt = (ncnt+ 1)
  ENDIF
 ELSE
  CALL echo("order qualified for the fill, use prev_dispense_dt_tm")
  SELECT INTO "NL:"
   FROM dispense_hx dh
   WHERE (dh.order_id= $ORDER_ID)
    AND (dh.fill_hx_id= $FILL_HX)
   DETAIL
    CALL echo(build("dispense hx id: ",dh.dispense_hx_id)), next_dispense_dt = dh.prev_dispense_dt_tm
   WITH nocounter
  ;end select
  SET slocaldatetime = utcdatetime(next_dispense_dt,0,1,"@SHORTDATETIME")
  CALL echo(build("Next_dispense_dt; sLocalDateTime: ",slocaldatetime))
  CALL echo(cnvtdatetime(slocaldatetime))
  SET outputs->writethis[ncnt].line = build("dispense_hx.prev_dispense_dt_tm:",slocaldatetime)
  SET ncnt = (ncnt+ 1)
 ENDIF
 IF (nskip=0)
  SET slocaldatetime = utcdatetime(fill_cycle_to_dt_tm,0,1,"@SHORTDATETIME")
  CALL echo(build("fill_cycle_to_dt_tm; sLocalDateTime: ",slocaldatetime))
  CALL echo(cnvtdatetime(slocaldatetime))
  IF (next_dispense_dt > fill_cycle_to_dt_tm)
   SET smessage1 = uar_i18ngetmessage(i18nhandle,"sCap133",
    "Next dispense date/time > fill to date/time of:")
   SET outputs->writethis[ncnt].line = build(smessage1,slocaldatetime)
   SET ncnt = (ncnt+ 1)
   GO TO end_script
  ELSE
   SET smessage1 = uar_i18ngetmessage(i18nhandle,"sCap134",
    "Next dispense date/time prior to fill to date/time of:")
   SET outputs->writethis[ncnt].line = build(smessage1,slocaldatetime)
   SET ncnt = (ncnt+ 1)
  ENDIF
 ENDIF
 SET ncnt = (ncnt+ 1)
 SET outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap150",
  "Next dispense date/time checks passed.  To ensure accuracy the")
 SET ncnt = (ncnt+ 1)
 SET outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap135",
  "Next dispense date/time should be manually evaluated to ensure its value at the time the fill")
 SET ncnt = (ncnt+ 1)
 SET outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap136",
  "ran.  Dispense_hx can provide a running history of the Next dispense date/time.")
 SET ncnt = (ncnt+ 1)
 SET ncnt = (ncnt+ 1)
 SET outputs->writethis[ncnt].line = uar_i18ngetmessage(i18nhandle,"sCap137",
  "Order is dispensable...")
 SET ncnt = (ncnt+ 1)
#end_script
 CALL echorecord(outputs)
 SET writecnt = ncnt
 SELECT INTO value(soutput)
  FROM (dual  WITH seq = 1)
  DETAIL
   FOR (x = 1 TO writecnt)
     col 01, outputs->writethis[x].line, row + 1
   ENDFOR
   CALL echo("Last MOD: 001"),
   CALL echo("MOD Date: 07/15/2014")
 ;end select
END GO
