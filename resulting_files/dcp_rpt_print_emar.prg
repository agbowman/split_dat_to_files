CREATE PROGRAM dcp_rpt_print_emar
 SET modify = predeclare
 RECORD reply(
   1 num_lines = f8
   1 qual[*]
     2 line = c255
   1 output_file = vc
   1 log_info[*]
     2 log_level = i2
     2 log_message = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
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
 DECLARE cvieworder = f8 WITH protect, constant(uar_get_code_by("MEANING",6016,"VIEWORDER"))
 DECLARE filteredordercount = i4 WITH protect, noconstant(0)
 IF (validate(request->privileges))
  DECLARE idx = i4 WITH protect, noconstant(0)
  DECLARE num = i4 WITH protect, noconstant(0)
  SET idx = locateval(num,1,size(request->privileges,5),cvieworder,request->privileges[num].
   privilege_cd)
  IF (idx
   AND (request->privileges[idx].default[1].granted_ind=0)
   AND size(request->privileges[idx].default[1].exceptions,5)=0)
   SET reply->status_data.status = "Z"
   GO TO exit_program
  ENDIF
 ENDIF
 SET modify = nopredeclare
 EXECUTE dcp_get_mar_details  WITH replace("MAR_DETAIL_REQUEST","REQUEST")
 SET modify = predeclare
 FREE SET internal
 RECORD internal(
   1 order_ingredients[*]
     2 order_mnemonic = vc
     2 ordered_as = vc
     2 dose_print = vc
     2 bag_freq = vc
     2 action = i2
 )
 FREE SET response_print_data
 RECORD response_print_data(
   1 text[*]
     2 comment_type = vc
     2 comment_col = i4
     2 response_info = vc
     2 chars_per_line = i4
     2 note_string = vc
     2 col_start = i4
 )
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
 DECLARE debug_ind = i2 WITH protect, noconstant(0)
 IF (validate(request->debug_ind))
  SET debug_ind = request->debug_ind
 ELSE
  SET debug_ind = 0
 ENDIF
 DECLARE dio_output = i4 WITH protect, noconstant(8)
 DECLARE param_cnt = i4 WITH noconstant(0)
 DECLARE x = i4 WITH noconstant(0)
 IF (validate(request->param_list))
  SET param_cnt = size(request->param_list,5)
  FOR (x = 1 TO param_cnt)
    IF ((request->param_list[x].value_type="file_option")
     AND (request->param_list[x].value="2"))
     SET dio_output = 38
     SET x = (param_cnt+ 1)
    ENDIF
  ENDFOR
 ENDIF
 IF (debug_ind=1)
  DECLARE printfile = vc WITH protect, constant("MINE")
 ELSEIF (dio_output=38)
  DECLARE printfile = vc WITH protect, constant(concat(trim(cnvtlower(logical("CER_PRINT")),3),
    "/emarprint_",trim(cnvtstring(request->chart_request_id,20)),".pdf"))
 ELSE
  DECLARE printfile = vc WITH protect, constant(concat("cer_print:emarprint_",trim(cnvtstring(request
      ->chart_request_id,20)),".ps"))
 ENDIF
 DECLARE scheduled_admin_na_ind = i2 WITH protect, noconstant(0)
 DECLARE rpt_header = vc WITH protect, noconstant(" ")
 DECLARE orderable_sort = vc WITH protect, noconstant(" ")
 DECLARE med_sort = i2 WITH protect, noconstant(0)
 DECLARE time2 = i2 WITH protect, noconstant(0)
 DECLARE ordered_by = vc WITH protect, noconstant(" ")
 DECLARE modified_by = vc WITH protect, noconstant(" ")
 DECLARE rescheduled_by = vc WITH protect, noconstant(" ")
 DECLARE time = vc WITH protect, noconstant(" ")
 DECLARE tod = f8 WITH protect, noconstant(0.0)
 DECLARE reviewed_print = vc WITH protect, noconstant(" ")
 DECLARE order_action_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE dose_print = vc WITH protect, noconstant(" ")
 DECLARE review_action_type = vc WITH protect, noconstant(" ")
 DECLARE prsnl_type = vc WITH protect, noconstant(" ")
 DECLARE prsnl_id = vc WITH protect, noconstant(" ")
 DECLARE order_id = vc WITH protect, noconstant(" ")
 DECLARE action_performed_by = vc WITH protect, noconstant(" ")
 DECLARE print_action = vc WITH protect, noconstant(" ")
 DECLARE strength_dose = f8 WITH protect, noconstant(0.0)
 DECLARE strength_dose_unit = f8 WITH protect, noconstant(0.0)
 DECLARE volume_dose = f8 WITH protect, noconstant(0.0)
 DECLARE volume_dose_unit = f8 WITH protect, noconstant(0.0)
 DECLARE print_bag_freq = vc WITH protect, noconstant(" ")
 DECLARE name_id = i2 WITH protect, noconstant(0)
 DECLARE order_comment_text = vc WITH protect, noconstant("")
 DECLARE product_note_text = vc WITH protect, noconstant("")
 DECLARE ingred_count = i2 WITH protect, noconstant(0)
 DECLARE print_ingred_info = vc WITH protect, noconstant("")
 DECLARE print_ingred_info_extra = vc WITH protect, noconstant("")
 DECLARE length_to_add = i2 WITH protect, noconstant(0)
 DECLARE string_length = i4 WITH protect, noconstant(0)
 DECLARE printdose = vc WITH protect, noconstant("")
 DECLARE admin_action = vc WITH protect, noconstant("")
 DECLARE admin_dose = vc WITH protect, noconstant("")
 DECLARE admin_dt_time = vc WITH protect, noconstant("")
 DECLARE scheduled_admin = vc WITH protect, noconstant("")
 DECLARE bag_number = vc WITH protect, noconstant("")
 DECLARE admin_volume = vc WITH protect, noconstant("")
 DECLARE admin_rate = vc WITH protect, noconstant("")
 DECLARE admin_site = vc WITH protect, noconstant("")
 DECLARE admin_comment = vc WITH protect, noconstant("")
 DECLARE commenttype = vc WITH protect, noconstant("")
 DECLARE typelength = i2 WITH protect, noconstant(0)
 DECLARE dta = vc WITH protect, noconstant("")
 DECLARE dta_comment = vc WITH protect, noconstant("")
 DECLARE dta_result_val = vc WITH protect, noconstant("")
 DECLARE comment_dt_tm = vc WITH protect, noconstant("")
 DECLARE action_prsnl_label = vc WITH protect, noconstant("")
 DECLARE action_prsnl_info = vc WITH protect, noconstant("")
 DECLARE proxy_prsnl_label = vc WITH protect, noconstant("")
 DECLARE proxy_prsnl_info = vc WITH protect, noconstant("")
 DECLARE request_prsnl_label = vc WITH protect, noconstant("")
 DECLARE request_prsnl_info = vc WITH protect, noconstant("")
 DECLARE response_dt_tm = vc WITH protect, noconstant("")
 DECLARE prev_event_end_dt_tm = f8 WITH protect, noconstant(0.0)
 DECLARE response_comment = vc WITH protect, noconstant("")
 DECLARE adminhist = i2 WITH protect, noconstant(0)
 DECLARE dta_hist = vc WITH protect, noconstant("")
 DECLARE dta_hist_comment = vc WITH protect, noconstant("")
 DECLARE type_length = i2 WITH protect, noconstant(0)
 DECLARE comment_type = vc WITH protect, noconstant("")
 DECLARE comment_text = vc WITH protect, noconstant("")
 DECLARE response_info = vc WITH protect, noconstant("")
 DECLARE clinical_display_line = vc WITH protect, noconstant("")
 DECLARE printed_action_prsnl_info = i2 WITH protect, noconstant(0)
 DECLARE result_action_dt_tm = vc WITH protect, noconstant("")
 DECLARE notdone_found = i2 WITH protect, noconstant(0)
 DECLARE notgiven_found = i2 WITH protect, noconstant(0)
 DECLARE notdone_printed = i2 WITH protect, noconstant(0)
 DECLARE unchart_found = i2 WITH protect, noconstant(0)
 DECLARE acknowledgement = i4 WITH protect, noconstant(0)
 DECLARE ack_info = vc WITH protect, noconstant("")
 DECLARE ack_comment = i4 WITH protect, noconstant(0)
 DECLARE ack_comment_info = vc WITH protect, noconstant("")
 DECLARE trimmed_label = vc WITH protect, noconstant("")
 DECLARE action_cnt = i4 WITH protect, noconstant(0)
 DECLARE parent_response_idx = i4 WITH protect, noconstant(0)
 DECLARE response_action_disp = vc WITH protect, noconstant("")
 DECLARE print_column_format = i2 WITH protect, noconstant(0)
 DECLARE response_data_cnt = i4 WITH protect, noconstant(0)
 DECLARE immun_detail = vc WITH protect, noconstant("")
 DECLARE ingred_print = vc WITH protect, noconstant("")
 DECLARE device_free_txt = vc WITH protect, noconstant("")
 DECLARE clinreviewflag_unset = i2 WITH protect, constant(0)
 DECLARE clinreviewflag_needs_review = i2 WITH protect, constant(1)
 DECLARE clinreviewflag_reviewed = i2 WITH protect, constant(2)
 DECLARE clinreviewflag_rejected = i2 WITH protect, constant(3)
 DECLARE clinreviewflag_dna = i2 WITH protect, constant(4)
 DECLARE clinreviewflag_superceded = i2 WITH protect, constant(5)
 DECLARE line = c100 WITH protect, constant(fillstring(100,"_"))
 DECLARE line2 = c80 WITH protect, constant(fillstring(80,"_"))
 DECLARE line3 = c67 WITH protect, constant(fillstring(67,"_"))
 DECLARE line4 = c130 WITH protect, constant(fillstring(130,"_"))
 DECLARE cnurse = i2 WITH protect, constant(1)
 DECLARE cdoctor = i2 WITH protect, constant(2)
 DECLARE crx = i2 WITH protect, constant(3)
 DECLARE cactivate = i2 WITH protect, constant(1)
 DECLARE caccepted = i2 WITH protect, constant(1)
 DECLARE crejected = i2 WITH protect, constant(2)
 DECLARE csuperseded = i2 WITH protect, constant(4)
 DECLARE creviewed = i2 WITH protect, constant(5)
 DECLARE cschedprintformat = i2 WITH protect, constant(1)
 DECLARE ccharted = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE cunchart = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"INERROR"))
 DECLARE cnotgiven = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"NOT DONE"))
 DECLARE cmodified = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE caltered = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE cbeginbag = f8 WITH protect, constant(uar_get_code_by("MEANING",180,"BEGIN"))
 DECLARE cratechange = f8 WITH protect, constant(uar_get_code_by("MEANING",180,"RATECHG"))
 DECLARE cmodify = f8 WITH protect, constant(uar_get_code_by("MEANING",6003,"MODIFY"))
 DECLARE creschedule = f8 WITH protect, constant(uar_get_code_by("MEANING",6003,"RESCHEDULE"))
 DECLARE corder = f8 WITH protect, constant(uar_get_code_by("MEANING",6003,"ORDER"))
 DECLARE cstatuschange = f8 WITH protect, constant(uar_get_code_by("MEANING",6003,"STATUSCHANGE"))
 DECLARE cmed = f8 WITH protect, constant(uar_get_code_by("MEANING",18309,"MED"))
 DECLARE cint = f8 WITH protect, constant(uar_get_code_by("MEANING",18309,"INTERMITTENT"))
 DECLARE civ = f8 WITH protect, constant(uar_get_code_by("MEANING",18309,"IV"))
 DECLARE civparent = f8 WITH protect, constant(uar_get_code_by("MEANING",72,"IVPARENT"))
 DECLARE cpowerchart = f8 WITH protect, constant(uar_get_code_by("MEANING",73,"POWERCHART"))
 DECLARE cdcpgeneric = f8 WITH protect, noconstant(0.0)
 DECLARE cwitness = f8 WITH protect, constant(uar_get_code_by("MEANING",21,"WITNESS"))
 DECLARE csign = f8 WITH protect, constant(uar_get_code_by("MEANING",21,"SIGN"))
 DECLARE creview = f8 WITH protect, constant(uar_get_code_by("MEANING",21,"REVIEW"))
 DECLARE cperform = f8 WITH protect, constant(uar_get_code_by("MEANING",21,"PERFORM"))
 DECLARE cchartmodify = f8 WITH protect, constant(uar_get_code_by("MEANING",21,"MODIFY"))
 DECLARE cprsnlorder = f8 WITH protect, constant(uar_get_code_by("MEANING",21,"ORDER"))
 DECLARE cprsnlverify = f8 WITH protect, constant(uar_get_code_by("MEANING",21,"VERIFY"))
 DECLARE cpharmnet = i4 WITH protect, constant(380000)
 DECLARE cordercomment = f8 WITH protect, constant(uar_get_code_by("MEANING",14,"ORD COMMENT"))
 DECLARE cproductnote = f8 WITH protect, constant(uar_get_code_by("MEANING",14,"MARNOTE"))
 DECLARE cactivitytype = f8 WITH protect, constant(uar_get_code_by("MEANING",6015,"ACTIVITYTYPE"))
 DECLARE ccatalogtype = f8 WITH protect, constant(uar_get_code_by("MEANING",6015,"CATALOGTYPE"))
 DECLARE corderables = f8 WITH protect, constant(uar_get_code_by("MEANING",6015,"ORDERABLES"))
 DECLARE cnum = f8 WITH protect, constant(uar_get_code_by("MEANING",53,"NUM"))
 DECLARE ceventimmun = f8 WITH protect, constant(uar_get_code_by("MEANING",53,"IMMUN"))
 DECLARE i18nhandle = i4 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 SET stat = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 DECLARE i18n_sprn = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_PRN","PRN"),3
   ))
 DECLARE i18n_scontinuousinfusion = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_CONTINUOUS_INFUSIONS","CONTINUOUS INFUSIONS"),3))
 DECLARE i18n_sunscheduledmeds = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_UNSCHEDULED_MEDS","UNSCHEDULED MEDS"),3))
 DECLARE i18n_sscheduledmed = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_SCHEDULED_MEDS","SCHEDULED MEDS"),3))
 DECLARE i18n_snostrengthorvolume = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_NO_STRENGTH_OR_VOLUME","NO STRENGTH OR VOLUME"),3))
 DECLARE i18n_sorderid = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_ORDER_ID",
    "Order Id"),3))
 DECLARE i18n_sscheduled = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_SCHEDULED","Scheduled"),3))
 DECLARE i18n_sordercomment = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_ORDER_COMMENT","Order Comment"),3))
 DECLARE i18n_sproductnote = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_PRODUCT_NOTE","Product Note"),3))
 DECLARE i18n_sorderenteredby = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_ORDER_ENTERED_BY","Order Entered By"),3))
 DECLARE i18n_sordermodifiedverifiedby = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_ORDER_MODIFIED_VERIFIED_BY","Order Modified/Verified By"),3))
 DECLARE i18n_sordermodifiedby = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_ORDER_MODIFIED_BY","Order Modified By"),3))
 DECLARE i18n_sorderrescheduledby = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_ORDER_RESCHEDULED_BY","Order Rescheduled By"),3))
 DECLARE i18n_ssupercededon = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_SUPERCEDED_ON","superceded on"),3))
 DECLARE i18n_srejectedon = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_REJECTED_ON","rejected on"),3))
 DECLARE i18n_sacceptedon = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_ACCEPTED_ON","accepted on"),3))
 DECLARE i18n_sreviewedon = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_REVIEWED_ON","reviewed on"),3))
 DECLARE i18n_snurse = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_NURSE",
    "Nurse"),3))
 DECLARE i18n_sdr = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_DR","Dr."),3))
 DECLARE i18n_spharmacist = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_PHARMACIST","Pharmacist"),3))
 DECLARE i18n_sphysicianactivated = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_PHYSICIAN_ACTIVATED","Physician Activated"),3))
 DECLARE i18n_sactions = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_ACTIONS",
    "ACTION(S)"),3))
 DECLARE i18n_schartedat = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_CHARTED_AT","CHARTED AT"),3))
 DECLARE i18n_sscheduledcaps = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_SCHEDULED_CAPS","SCHEDULED"),3))
 DECLARE i18n_sadmintimes = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_ADMIN_TIMES","ADMIN TIME(S)"),3))
 DECLARE i18n_sadmindetails = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_ADMIN_DETAILS","ADMIN DETAIL(S)"),3))
 DECLARE i18n_sperformedby = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_PERFORMED_BY","Performed by"),3))
 DECLARE i18n_smodifiedby = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_MODIFIED_BY","Modified by"),3))
 DECLARE i18n_sunchartedby = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_UNCHARTED_BY","Uncharted by"),3))
 DECLARE i18n_sverifiedby = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_VERIFIED_BY","Verified by"),3))
 DECLARE i18n_switnessedby = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_WITNESSED_BY","Witnessed by"),3))
 DECLARE i18n_ssignedby = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_SIGNED_BY","Signed by"),3))
 DECLARE i18n_sreviewedby = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_REVIEWED_BY","Reviewed by"),3))
 DECLARE i18n_sorderedby = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_ORDERED_BY","Ordered by"),3))
 DECLARE i18n_sat = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_AT","at"),3))
 DECLARE i18n_smedgiven = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_MED_GIVEN","Med Given"),3))
 DECLARE i18n_suncharted = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_UNCHARTED","Uncharted"),3))
 DECLARE i18n_sunchart = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_UNCHART",
    "Unchart"),3))
 DECLARE i18n_snotgiven = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_NOT_GIVEN","Not Given"),3))
 DECLARE i18n_smodified = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_MODIFIED","Modified"),3))
 DECLARE i18n_sbag = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_BAG","Bag"),3
   ))
 DECLARE i18n_sna = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_NA","N/A"),3))
 DECLARE i18n_svolume = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_VOLUME",
    "Volume"),3))
 DECLARE i18n_srate = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_RATE","Rate"
    ),3))
 DECLARE i18n_ssite = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_SITE","Site"
    ),3))
 DECLARE i18n_spreviousvalue = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_PREVIOUS_VALUE","Previous Value"),3))
 DECLARE i18n_sproxy = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_PROXY",
    "Proxy"),3))
 DECLARE i18n_srequest = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_REQUEST",
    "Request"),3))
 DECLARE i18n_sactioncomment = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_ACTION_COMMENT","Action Comment"),3))
 DECLARE i18n_srequestcomment = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_REQUEST_COMMENT","Request Comment"),3))
 DECLARE i18n_sresponse = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_RESPONSE","Response"),3))
 DECLARE i18n_snotdone = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_NOT_DONE",
    "Not Done"),3))
 DECLARE i18n_soriginaladmintime = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_ORIGINAL_ADMIN_TIME","Original Admin Time"),3))
 DECLARE i18n_sincompleteprintmsg = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_INCOMPLETE_PRINT_MSG","This is an incomplete print, based on the privileges of user"),3))
 DECLARE i18n_scommententeredat = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_COMMENT_ENTERED_AT","Comment entered at"),3))
 DECLARE i18n_simmunizationdetails = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_sIMMUNIZATION_DETAILS","Immunization Details"),3))
 DECLARE i18n_sexpirationdate = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_sEXPIRATION_DATE","Expiration Date"),3))
 DECLARE i18n_slotnumber = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_sLOT_NUMBER","Lot Number"),3))
 DECLARE i18n_smanufacturer = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_sMANUFACTURER","Manufacturer"),3))
 DECLARE i18n_sdevice = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_sDEVICE",
    "Device"),3))
 DECLARE canorderbeviewed(dcatalogcd=f8,dactivitytypecd=f8,dcatalogtypecd=f8,dorderid=f8) = i2
 DECLARE logmessageinreply(iloglevel=i2,slogmessage=vc) = null
 DECLARE doesexceptionexist(dcatalogcd=f8,dactivitytypecd=f8,dcatalogtypecd=f8,iprividx=i4) = i2
 DECLARE storeresponseevents(iorderidx=i4,iresponseidx=i4,iresponseactionidx=i4,ieventidx=i4) = i2
 SET reply->status_data.status = "F"
 IF (size(mar_detail_reply->orders,5)=0)
  SET reply->status_data.status = "Z"
  GO TO exit_program
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SELECT INTO "NL:"
  FROM code_value_alias cva
  PLAN (cva
   WHERE cva.contributor_source_cd=cpowerchart
    AND cva.alias=cnvtupper("DCPGENERIC"))
  DETAIL
   cdcpgeneric = cva.code_value
  WITH nocounter
 ;end select
 SET reply->output_file = printfile
 IF (validate(request->name_id))
  SET name_id = request->name_id
 ENDIF
 SELECT INTO value(printfile)
  med_sort =
  IF ((mar_detail_reply->orders[d.seq].top_level_prn_ind=1)) 3
  ELSEIF ((mar_detail_reply->orders[d.seq].top_level_order_type=civ)) 4
  ELSEIF ((mar_detail_reply->orders[d.seq].top_level_freq_type=5)) 2
  ELSE 1
  ENDIF
  , orderable_sort = cnvtupper(mar_detail_reply->orders[d.seq].top_level_order_mnemonic)
  FROM (dummyt d  WITH seq = value(size(mar_detail_reply->orders,5)))
  PLAN (d
   WHERE (mar_detail_reply->orders[d.seq].top_level_order_id > 0)
    AND canorderbeviewed(mar_detail_reply->orders[d.seq].top_level_catalog_cd,mar_detail_reply->
    orders[d.seq].top_level_activity_type_cd,mar_detail_reply->orders[d.seq].
    top_level_catalog_type_cd,mar_detail_reply->orders[d.seq].top_level_order_id))
  ORDER BY med_sort, orderable_sort
  HEAD REPORT
   MACRO (prnt_note)
    ln_width_in = chars_per_line, stuck = 0, count_no_spaces = 0,
    counter = 0, time_to_loop = 0, time_to_loop = ((size(trim(note_text_in,1))/ chars_per_line)+ 1)
    FOR (note_length = 1 TO time_to_loop)
      FOR (time2 = 1 TO chars_per_line)
       counter = (counter+ 1),
       IF (substring(counter,1,note_text_in) != " ")
        count_no_spaces = (count_no_spaces+ 1)
        IF (count_no_spaces >= chars_per_line)
         stuck = 1, note_length = time_to_loop, time2 = chars_per_line
        ENDIF
       ELSE
        count_no_spaces = 0
       ENDIF
      ENDFOR
    ENDFOR
    IF (stuck=0)
     start_pos = 1, big_string_len = 0, count = 0,
     note_string = fillstring(130," "), hold_string = fillstring(130," "), return_found = 0,
     big_string_len = size(trim(note_text_in)), cr = fillstring(1," "), cr = char(13)
     WHILE (((big_string_len - start_pos) > 0))
       space_loc = 0, return_found = 0, count = 0,
       cr_count = 0, end_pos = 0, end_pos = (ln_width_in+ start_pos),
       len1 = movestring(note_text_in,start_pos,hold_string,0,end_pos), hold_string = hold_string,
       cr_count = findstring(cr,hold_string)
       IF (cr_count > 0
        AND size(trim(substring(0,(cr_count - 1),hold_string))) <= chars_per_line)
        return_found = 1, note_string = substring(0,(cr_count - 1),hold_string), note_string = trim(
         note_string,1),
        call reportmove('COL',(00+ col_start),0), "{ENDB}", note_string,
        row + 1, ord_row = row, cr_count = (cr_count+ 1),
        start_pos = (start_pos+ cr_count)
       ENDIF
       WHILE (count < ln_width_in
        AND return_found=0)
        count = (count+ 1),
        IF (substring(count,1,hold_string)=" "
         AND return_found=0)
         space_loc = count
        ENDIF
       ENDWHILE
       IF (space_loc > 0
        AND return_found=0)
        note_string = substring(0,(space_loc - 1),hold_string), note_string = trim(note_string),
        call reportmove('COL',(00+ col_start),0),
        "{ENDB}", note_string, row + 1,
        ord_row = row, start_pos = (start_pos+ space_loc)
       ENDIF
     ENDWHILE
    ELSE
     call reportmove('COL',(00+ col_start),0), "See chart for notes", row + 1,
     ord_row = row
    ENDIF
   ENDMACRO
  HEAD PAGE
   x = 0
  HEAD med_sort
   print_line = 0, "{f/4/1}{lpi/8}{cpi/14}", row + 1
   IF ((mar_detail_reply->orders[d.seq].top_level_prn_ind=1))
    rpt_header = i18n_sprn
   ELSEIF ((mar_detail_reply->orders[d.seq].top_level_order_type=civ))
    rpt_header = i18n_scontinuousinfusion
   ELSEIF ((mar_detail_reply->orders[d.seq].top_level_freq_type=5))
    rpt_header = i18n_sunscheduledmeds
   ELSE
    rpt_header = i18n_sscheduledmed
   ENDIF
   "{B}",
   CALL center(rpt_header,0,230), row + 1,
   line4
  HEAD d.seq
   product_note_text = "", order_comment_text = ""
   IF (print_line=1)
    line
   ENDIF
   print_line = 1, row + 1
  HEAD orderable_sort
   FOR (action = 1 TO size(mar_detail_reply->orders[d.seq].order_actions,5))
     ingredients = 0, volume_dose = 0.0, volume_dose_unit = 0.0,
     strength_dose = 0.0, strength_dose_unit = 0.0, print_column_format = 0,
     dose_print = " ", ordered_by = " ", modified_by = " ",
     rescheduled_by = " ", order_action_dt_tm = " ", ingred_count = 0,
     printdose = "", clinical_display_line = ""
     IF ((mar_detail_reply->orders[d.seq].top_level_freq_type IN (1, 2))
      AND (mar_detail_reply->orders[d.seq].top_level_order_type IN (cmed, cint))
      AND (mar_detail_reply->orders[d.seq].order_actions[action].prn_ind != 1))
      print_column_format = cschedprintformat
     ENDIF
     IF ((mar_detail_reply->orders[d.seq].order_actions[action].action_type_cd IN (corder, cmodify,
     creschedule)))
      row + 1, ingred_count = 0
      FOR (ingredients = 1 TO size(mar_detail_reply->orders[d.seq].order_actions[action].
       order_ingredients,5))
        print_bag_freq = " ", ingred_count = (ingred_count+ 1), stat = alterlist(internal->
         order_ingredients,ingred_count),
        internal->order_ingredients[ingred_count].action = action, internal->order_ingredients[
        ingred_count].order_mnemonic = mar_detail_reply->orders[d.seq].order_actions[action].
        order_ingredients[ingredients].order_mnemonic
        IF ((mar_detail_reply->orders[d.seq].order_actions[action].order_ingredients[ingredients].
        ordered_as_mnemonic != mar_detail_reply->orders[d.seq].order_actions[action].
        order_ingredients[ingredients].order_mnemonic))
         internal->order_ingredients[ingred_count].ordered_as = concat("(",trim(mar_detail_reply->
           orders[d.seq].order_actions[action].order_ingredients[ingredients].ordered_as_mnemonic),
          ")")
        ELSE
         internal->order_ingredients[ingred_count].ordered_as = " "
        ENDIF
        IF ((mar_detail_reply->orders[d.seq].order_actions[action].order_ingredients[ingredients].
        volume > 0)
         AND (mar_detail_reply->orders[d.seq].order_actions[action].order_ingredients[ingredients].
        strength > 0))
         volume_dose = mar_detail_reply->orders[d.seq].order_actions[action].order_ingredients[
         ingredients].volume, printdose = formatvolume(volume_dose), volume_dose_unit =
         mar_detail_reply->orders[d.seq].order_actions[action].order_ingredients[ingredients].
         volume_unit,
         dose_print = concat(trim(printdose)," ",trim(uar_get_code_display(volume_dose_unit))),
         strength_dose = mar_detail_reply->orders[d.seq].order_actions[action].order_ingredients[
         ingredients].strength, printdose = formatstrength(strength_dose),
         strength_dose_unit = mar_detail_reply->orders[d.seq].order_actions[action].
         order_ingredients[ingredients].strength_unit, dose_print = concat(trim(dose_print)," = ",
          concat(trim(printdose)," ",trim(uar_get_code_display(strength_dose_unit))))
        ELSEIF ((mar_detail_reply->orders[d.seq].order_actions[action].order_ingredients[ingredients]
        .strength > 0))
         strength_dose = mar_detail_reply->orders[d.seq].order_actions[action].order_ingredients[
         ingredients].strength, printdose = formatstrength(strength_dose), strength_dose_unit =
         mar_detail_reply->orders[d.seq].order_actions[action].order_ingredients[ingredients].
         strength_unit,
         dose_print = concat(trim(printdose)," ",trim(uar_get_code_display(strength_dose_unit)))
        ELSEIF ((mar_detail_reply->orders[d.seq].order_actions[action].order_ingredients[ingredients]
        .volume > 0))
         volume_dose = mar_detail_reply->orders[d.seq].order_actions[action].order_ingredients[
         ingredients].volume, printdose = formatvolume(volume_dose), volume_dose_unit =
         mar_detail_reply->orders[d.seq].order_actions[action].order_ingredients[ingredients].
         volume_unit,
         dose_print = concat(trim(printdose)," ",trim(uar_get_code_display(volume_dose_unit)))
        ELSEIF ((mar_detail_reply->orders[d.seq].order_actions[action].order_ingredients[ingredients]
        .freetext_dose != ""))
         dose_print = mar_detail_reply->orders[d.seq].order_actions[action].order_ingredients[
         ingredients].freetext_dose
        ELSE
         dose_print = i18n_snostrengthorvolume
        ENDIF
        internal->order_ingredients[ingred_count].dose_print = dose_print
        IF ((mar_detail_reply->orders[d.seq].top_level_order_type=civ))
         bag_freq = mar_detail_reply->orders[d.seq].order_actions[action].order_ingredients[
         ingredients].bag_freq, print_bag_freq = uar_get_code_description(bag_freq), internal->
         order_ingredients[ingred_count].bag_freq = print_bag_freq
        ENDIF
      ENDFOR
      FOR (print_ingred = 1 TO size(internal->order_ingredients,5))
        print_ingred_info = "", print_ingred_info_extra = ""
        IF ((mar_detail_reply->orders[d.seq].top_level_order_type=civ))
         IF ((internal->order_ingredients[print_ingred].ordered_as != ""))
          print_ingred_info = concat(internal->order_ingredients[print_ingred].order_mnemonic,
           internal->order_ingredients[print_ingred].ordered_as,"   ",internal->order_ingredients[
           print_ingred].dose_print,"   ",
           internal->order_ingredients[print_ingred].bag_freq)
         ELSE
          print_ingred_info = concat(internal->order_ingredients[print_ingred].order_mnemonic," ",
           internal->order_ingredients[print_ingred].dose_print,"   ",internal->order_ingredients[
           print_ingred].bag_freq)
         ENDIF
        ELSE
         IF ((internal->order_ingredients[print_ingred].ordered_as != ""))
          print_ingred_info = concat(internal->order_ingredients[print_ingred].order_mnemonic,
           internal->order_ingredients[print_ingred].ordered_as,"   ",internal->order_ingredients[
           print_ingred].dose_print)
         ELSE
          print_ingred_info = concat(internal->order_ingredients[print_ingred].order_mnemonic," ",
           internal->order_ingredients[print_ingred].dose_print)
         ENDIF
        ENDIF
        string_length = textlen(print_ingred_info)
        IF (string_length > 80)
         print_ingred_info_extra = formatlabelbylength(substring(76,(string_length - 75),
           print_ingred_info),75), print_ingred_info = substring(1,75,print_ingred_info)
        ENDIF
        "{B}", print_ingred_info
        IF (size(trim(print_ingred_info_extra)) > 0)
         row + 1
        ENDIF
        "{B}", print_ingred_info_extra
        IF (print_ingred=1)
         order_id = concat("(",i18n_sorderid," = ",trim(cnvtstring(mar_detail_reply->orders[d.seq].
            top_level_order_id,20,2)),")"), col 140, order_id
        ENDIF
        row + 1
      ENDFOR
      clinical_display_line = mar_detail_reply->orders[d.seq].order_actions[action].
      clinical_display_line, note_text_in = fillstring(1000," "), note_text_in =
      clinical_display_line,
      chars_per_line = 130, note_string = fillstring(130," "), col_start = 2,
      prnt_note
      IF (print_column_format=cschedprintformat)
       note_text_in = fillstring(1000," "), chars_per_line = 130, note_string = fillstring(130," "),
       col_start = 2, note_text_in = build(i18n_sscheduled,": ")
       FOR (freq = 1 TO size(mar_detail_reply->orders[d.seq].order_actions[action].schedule,5))
         tod = mar_detail_reply->orders[d.seq].order_actions[action].schedule[freq].time_of_day, time
          = cnvtstring(cnvttime(tod)), length_to_add = 0
         IF (textlen(time) < 4)
          length_to_add = (4 - textlen(time))
          FOR (len2 = 1 TO length_to_add)
            time = concat("0",time)
          ENDFOR
         ENDIF
         note_text_in = build(note_text_in," {B}",time," ")
       ENDFOR
       prnt_note
      ENDIF
      type_length = 0, comment_type = "", comment_text = ""
      IF (size(mar_detail_reply->orders[d.seq].order_actions[action].notes,5) > 0)
       FOR (note = 1 TO size(mar_detail_reply->orders[d.seq].order_actions[action].notes,5))
         type_length = 0, comment_type = "", comment_text = ""
         IF ((mar_detail_reply->orders[d.seq].order_actions[action].notes[note].comment_type_cd=
         cordercomment))
          order_comment_text = mar_detail_reply->orders[d.seq].order_actions[action].notes[note].
          comment_text
         ENDIF
         IF ((mar_detail_reply->orders[d.seq].order_actions[action].notes[note].comment_type_cd=
         cproductnote))
          product_note_text = mar_detail_reply->orders[d.seq].order_actions[action].notes[note].
          comment_text
         ENDIF
         IF ( NOT ((mar_detail_reply->orders[d.seq].order_actions[action].notes[note].comment_type_cd
          IN (cordercomment, cproductnote))))
          comment_text = mar_detail_reply->orders[d.seq].order_actions[action].notes[note].
          comment_text, comment_type = uar_get_code_display(mar_detail_reply->orders[d.seq].
           order_actions[action].notes[note].comment_type_cd), type_length = size(comment_type,1)
         ENDIF
       ENDFOR
      ENDIF
      IF (order_comment_text != "")
       col 4, "{B}", i18n_sordercomment,
       ": ", note_text_in = fillstring(1000," "), note_text_in = order_comment_text,
       chars_per_line = 90, note_string = fillstring(90," "), col_start = 22,
       prnt_note
      ENDIF
      IF (product_note_text != "")
       col 4, "{B}", i18n_sproductnote,
       ": ", note_text_in = fillstring(1000," "), note_text_in = product_note_text,
       chars_per_line = 90, note_string = fillstring(90," "), col_start = 22,
       prnt_note
      ENDIF
      IF (comment_text != "")
       col 4, "{B}", comment_type,
       ":", note_text_in = fillstring(1000," "), note_text_in = comment_text,
       chars_per_line = 90, note_string = fillstring(90," "), col_start = (8+ type_length),
       prnt_note
      ENDIF
      reviewed_print = " "
      IF ((mar_detail_reply->orders[d.seq].order_actions[action].action_type_cd=corder))
       IF (name_id=0)
        ordered_by = mar_detail_reply->orders[d.seq].order_actions[action].action_person
       ELSE
        ordered_by = trim(cnvtstring(mar_detail_reply->orders[d.seq].order_actions[action].
          action_personnel_id,20,2))
       ENDIF
       col 6, "{B}", i18n_sorderenteredby,
       ": ", "{ENDB}", ordered_by,
       row + 1
      ELSEIF ((mar_detail_reply->orders[d.seq].order_actions[action].action_type_cd=cmodify))
       IF (name_id=0)
        modified_by = mar_detail_reply->orders[d.seq].order_actions[action].action_person
       ELSE
        modified_by = trim(cnvtstring(mar_detail_reply->orders[d.seq].order_actions[action].
          action_personnel_id,20,2))
       ENDIF
       IF ((mar_detail_reply->orders[d.seq].order_actions[action].need_rx_clin_review_flag IN (
       clinreviewflag_reviewed, clinreviewflag_dna))
        AND (mar_detail_reply->orders[d.seq].order_actions[action].order_app_nbr=cpharmnet))
        col 6, "{B}", i18n_sordermodifiedverifiedby,
        ": ", "{ENDB}", modified_by
       ELSE
        col 6, "{B}", i18n_sordermodifiedby,
        ": ", "{ENDB}", modified_by
       ENDIF
       row + 1
      ELSEIF ((mar_detail_reply->orders[d.seq].order_actions[action].action_type_cd=creschedule))
       IF (name_id=0)
        rescheduled_by = mar_detail_reply->orders[d.seq].order_actions[action].action_person
       ELSE
        rescheduled_by = trim(cnvtstring(mar_detail_reply->orders[d.seq].order_actions[action].
          action_personnel_id,20,2))
       ENDIF
       col 6, "{B}", i18n_sorderrescheduledby,
       ": ", "{ENDB}", rescheduled_by,
       row + 1
      ENDIF
      review_action_type = "", prsnl_type = "", prsnl_id = ""
      FOR (review = 1 TO size(mar_detail_reply->orders[d.seq].order_actions[action].order_review,5))
        reviewed_print = formatutcdatetime(mar_detail_reply->orders[d.seq].order_actions[action].
         order_review[review].review_dt_tm,mar_detail_reply->orders[d.seq].order_actions[action].
         order_review[review].review_tz,1)
        CASE (mar_detail_reply->orders[d.seq].order_actions[action].order_review[review].
        reviewed_status_flag)
         OF csuperseded:
          review_action_type = concat(" ",i18n_ssupercededon," ")
         OF crejected:
          review_action_type = concat(" ",i18n_srejectedon," ")
         OF caccepted:
          review_action_type = concat(" ",i18n_sacceptedon," ")
         OF creviewed:
          review_action_type = concat(" ",i18n_sreviewedon," ")
         ELSE
          review_action_type = ""
        ENDCASE
        CASE (mar_detail_reply->orders[d.seq].order_actions[action].order_review[review].
        review_type_flag)
         OF cnurse:
          prsnl_type = concat(i18n_snurse,": ")
         OF cdoctor:
          prsnl_type = concat(i18n_sdr," ")
         OF crx:
          prsnl_type = concat(i18n_spharmacist,": ")
         OF cactivate:
          prsnl_type = concat(i18n_sphysicianactivated,": ")
         ELSE
          prsnl_type = ""
        ENDCASE
        IF (name_id=0)
         prsnl_id = mar_detail_reply->orders[d.seq].order_actions[action].order_review[review].
         reviewed_person_name
        ELSE
         prsnl_id = trim(cnvtstring(mar_detail_reply->orders[d.seq].order_actions[action].
           order_review[review].review_personnel_id,20,2))
        ENDIF
        col 6, prsnl_type, " ",
        "{B}", prsnl_id, "{ENDB}",
        review_action_type, " ", reviewed_print,
        row + 1
      ENDFOR
      row + 1
      IF (print_column_format=cschedprintformat)
       trimmed_label = formatlabelbylength(i18n_sactions,16), col 2, trimmed_label,
       trimmed_label = formatlabelbylength(i18n_schartedat,15), col 19, trimmed_label,
       trimmed_label = formatlabelbylength(i18n_sscheduledcaps,18), col 38, trimmed_label,
       trimmed_label = formatlabelbylength(i18n_sadmintimes,16), col 57, trimmed_label,
       col 74, i18n_sadmindetails, row + 1,
       col 2, line2
      ELSE
       trimmed_label = formatlabelbylength(i18n_sactions,22), col 2, trimmed_label,
       trimmed_label = formatlabelbylength(i18n_schartedat,14), col 25, trimmed_label,
       trimmed_label = formatlabelbylength(i18n_sadmintimes,18), col 43, trimmed_label,
       col 62, i18n_sadmindetails, row + 1,
       col 2, line3
      ENDIF
      "{f/4/1}{lpi/8}{cpi/14}", row + 1
     ELSE
      IF ((mar_detail_reply->orders[d.seq].order_actions[action].effective_dt_tm >= cnvtdatetime(
       request->start_dt_tm))
       AND (mar_detail_reply->orders[d.seq].order_actions[action].effective_dt_tm <= cnvtdatetime(
       request->end_dt_tm)))
       IF ((mar_detail_reply->orders[d.seq].order_actions[action].action_type_cd=cstatuschange))
        print_action = uar_get_code_display(mar_detail_reply->orders[d.seq].top_level_order_status_cd
         )
       ELSE
        print_action = uar_get_code_display(mar_detail_reply->orders[d.seq].order_actions[action].
         action_type_cd)
       ENDIF
       col 2, "{B}", print_action,
       order_action_dt_tm = formatutcdatetime(mar_detail_reply->orders[d.seq].order_actions[action].
        effective_dt_tm,mar_detail_reply->orders[d.seq].order_actions[action].effective_tz,1)
       IF (print_column_format=cschedprintformat)
        col 91, "{B}", order_action_dt_tm
       ELSE
        col 64, "{B}", order_action_dt_tm
       ENDIF
       row + 1
       IF (name_id=0)
        action_performed_by = mar_detail_reply->orders[d.seq].order_actions[action].action_person
       ELSE
        action_performed_by = trim(cnvtstring(mar_detail_reply->orders[d.seq].order_actions[action].
          action_personnel_id,20,2))
       ENDIF
       IF (print_column_format=cschedprintformat)
        col 145, "{B}", i18n_sperformedby,
        "{ENDB}", action_performed_by
       ELSE
        col 136, "{B}", i18n_sperformedby,
        "{ENDB}", action_performed_by
       ENDIF
       row + 1
      ENDIF
     ENDIF
     FOR (admins = 1 TO size(mar_detail_reply->orders[d.seq].administrations,5))
      admin_action = "",
      IF ((mar_detail_reply->orders[d.seq].order_actions[action].action_sequence=mar_detail_reply->
      orders[d.seq].administrations[admins].core_action_sequence))
       adminhist = size(mar_detail_reply->orders[d.seq].administrations[admins].admin_histories,5)
       WHILE (adminhist > 0)
         notdone_printed = 0, notdone_found = 0, unchart_found = 0,
         notgiven_found = 0, admin_action = "", admin_dt_time = "",
         scheduled_admin = "", bag_number = "", device_free_txt = ""
         IF ((mar_detail_reply->orders[d.seq].top_level_order_type=civ)
          AND  NOT ((mar_detail_reply->orders[d.seq].administrations[admins].admin_histories[
         adminhist].result_status_cd IN (caltered, cmodified, cunchart))))
          admin_action = uar_get_code_display(mar_detail_reply->orders[d.seq].administrations[admins]
           .admin_histories[adminhist].iv_event_cd), bag_number = trim(mar_detail_reply->orders[d.seq
           ].administrations[admins].admin_histories[adminhist].substance_lot_number,3)
         ELSE
          IF ((mar_detail_reply->orders[d.seq].top_level_order_type=civ))
           bag_number = trim(mar_detail_reply->orders[d.seq].administrations[admins].admin_histories[
            adminhist].substance_lot_number,3)
          ENDIF
          IF ((mar_detail_reply->orders[d.seq].administrations[admins].admin_histories[adminhist].
          result_status_cd=ccharted))
           admin_action = i18n_smedgiven
          ELSEIF ((mar_detail_reply->orders[d.seq].administrations[admins].admin_histories[adminhist]
          .result_status_cd=cunchart))
           admin_action = concat("*",i18n_suncharted,"*"), unchart_found = 1
          ELSEIF ((mar_detail_reply->orders[d.seq].administrations[admins].admin_histories[adminhist]
          .result_status_cd=cnotgiven))
           IF ((mar_detail_reply->orders[d.seq].administrations[admins].admin_histories[adminhist].
           event_cd=cdcpgeneric))
            notgiven_found = 1, admin_action = i18n_snotgiven
           ELSE
            admin_action = trim(mar_detail_reply->orders[d.seq].administrations[admins].
             admin_histories[adminhist].event_tag), notdone_found = 1
           ENDIF
          ELSEIF ((mar_detail_reply->orders[d.seq].administrations[admins].admin_histories[adminhist]
          .result_status_cd IN (caltered, cmodified)))
           admin_action = concat("*",i18n_smodified,"*")
          ELSE
           admin_action = concat("*",trim(uar_get_code_display(mar_detail_reply->orders[d.seq].
              administrations[admins].admin_histories[adminhist].result_status_cd)),"*")
          ENDIF
         ENDIF
         IF ((mar_detail_reply->orders[d.seq].administrations[admins].admin_histories[adminhist].
         result_status_cd IN (caltered, cmodified, cunchart)))
          admin_action = formatlabelbylength(admin_action,13), col 4, "{B}",
          admin_action
         ELSE
          admin_action = formatlabelbylength(admin_action,15), col 2, "{B}",
          admin_action
         ENDIF
         IF ((mar_detail_reply->orders[d.seq].top_level_order_type=civ))
          trimmed_label = formatlabelbylength(i18n_sbag,6), col 18, trimmed_label,
          " ", bag_number
         ENDIF
         performed_dt_tm = formatutcdatetime(mar_detail_reply->orders[d.seq].administrations[admins].
          admin_histories[adminhist].performed_dt_tm,mar_detail_reply->orders[d.seq].administrations[
          admins].admin_histories[adminhist].performed_tz,1), admin_dt_time = formatutcdatetime(
          mar_detail_reply->orders[d.seq].administrations[admins].admin_histories[adminhist].
          event_end_dt_tm,mar_detail_reply->orders[d.seq].administrations[admins].admin_histories[
          adminhist].event_end_tz,1), device_free_txt = trim(mar_detail_reply->orders[d.seq].
          administrations[admins].admin_histories[adminhist].device_free_txt,3)
         IF (print_column_format=cschedprintformat)
          IF ((mar_detail_reply->orders[d.seq].top_level_order_id=mar_detail_reply->orders[d.seq].
          administrations[admins].order_id))
           scheduled_admin = concat("      ",i18n_sna)
          ELSE
           scheduled_admin = formatutcdatetime(mar_detail_reply->orders[d.seq].administrations[admins
            ].admin_histories[adminhist].scheduled_admin_dt_tm,mar_detail_reply->orders[d.seq].
            administrations[admins].admin_histories[adminhist].scheduled_admin_tz,1)
          ENDIF
          col 22, performed_dt_tm, col 45,
          scheduled_admin, col 68, admin_dt_time
         ELSE
          col 28, performed_dt_tm, col 50,
          admin_dt_time
         ENDIF
         FOR (ingreds = 1 TO size(mar_detail_reply->orders[d.seq].administrations[admins].ingredients,
          5))
          IF (size(mar_detail_reply->orders[d.seq].administrations[admins].ingredients[ingreds].
           ingredient_histories,5)=0)
           row + 1
          ENDIF
          ,
          FOR (ingredhist = 1 TO size(mar_detail_reply->orders[d.seq].administrations[admins].
           ingredients[ingreds].ingredient_histories,5))
            admin_dose = "", admin_dose = formatstrength(mar_detail_reply->orders[d.seq].
             administrations[admins].ingredients[ingreds].ingredient_histories[ingredhist].admin_dose
             )
            IF ((mar_detail_reply->orders[d.seq].administrations[admins].admin_histories[adminhist].
            valid_from_dt_tm=mar_detail_reply->orders[d.seq].administrations[admins].ingredients[
            ingreds].ingredient_histories[ingredhist].valid_from_dt_tm))
             IF ((mar_detail_reply->orders[d.seq].administrations[admins].admin_histories[adminhist].
             iv_event_cd=cbeginbag))
              IF ((mar_detail_reply->orders[d.seq].administrations[admins].ingredients[ingreds].
              ingredient_histories[ingredhist].initial_dose > 0)
               AND (mar_detail_reply->orders[d.seq].administrations[admins].ingredients[ingreds].
              ingredient_histories[ingredhist].initial_volume > 0)
               AND (mar_detail_reply->orders[d.seq].administrations[admins].ingredients[ingreds].
              ingredient_histories[ingredhist].initial_dose != mar_detail_reply->orders[d.seq].
              administrations[admins].ingredients[ingreds].ingredient_histories[ingredhist].
              initial_volume))
               admin_dose = concat(formatstrength(mar_detail_reply->orders[d.seq].administrations[
                 admins].ingredients[ingreds].ingredient_histories[ingredhist].initial_dose)," ",trim
                (uar_get_code_display(mar_detail_reply->orders[d.seq].administrations[admins].
                  ingredients[ingreds].ingredient_histories[ingredhist].dose_unit_cd))," / ",
                formatvolume(mar_detail_reply->orders[d.seq].administrations[admins].ingredients[
                 ingreds].ingredient_histories[ingredhist].initial_volume),
                " ",trim(uar_get_code_display(mar_detail_reply->orders[d.seq].administrations[admins]
                  .ingredients[ingreds].ingredient_histories[ingredhist].volume_unit_cd)))
              ELSEIF ((mar_detail_reply->orders[d.seq].administrations[admins].ingredients[ingreds].
              ingredient_histories[ingredhist].initial_dose > 0))
               admin_dose = concat(formatstrength(mar_detail_reply->orders[d.seq].administrations[
                 admins].ingredients[ingreds].ingredient_histories[ingredhist].initial_dose)," ",trim
                (uar_get_code_display(mar_detail_reply->orders[d.seq].administrations[admins].
                  ingredients[ingreds].ingredient_histories[ingredhist].dose_unit_cd)))
              ELSEIF ((mar_detail_reply->orders[d.seq].administrations[admins].ingredients[ingreds].
              ingredient_histories[ingredhist].initial_volume > 0))
               admin_dose = concat(formatvolume(mar_detail_reply->orders[d.seq].administrations[
                 admins].ingredients[ingreds].ingredient_histories[ingredhist].initial_volume)," ",
                trim(uar_get_code_display(mar_detail_reply->orders[d.seq].administrations[admins].
                  ingredients[ingreds].ingredient_histories[ingredhist].volume_unit_cd)))
              ELSE
               admin_dose = i18n_sna
              ENDIF
             ELSE
              IF ((mar_detail_reply->orders[d.seq].administrations[admins].ingredients[ingreds].
              ingredient_histories[ingredhist].admin_dose > 0)
               AND (mar_detail_reply->orders[d.seq].administrations[admins].ingredients[ingreds].
              ingredient_histories[ingredhist].admin_volume > 0)
               AND (mar_detail_reply->orders[d.seq].administrations[admins].ingredients[ingreds].
              ingredient_histories[ingredhist].admin_dose != mar_detail_reply->orders[d.seq].
              administrations[admins].ingredients[ingreds].ingredient_histories[ingredhist].
              admin_volume))
               admin_dose = concat(formatstrength(mar_detail_reply->orders[d.seq].administrations[
                 admins].ingredients[ingreds].ingredient_histories[ingredhist].admin_dose)," ",trim(
                 uar_get_code_display(mar_detail_reply->orders[d.seq].administrations[admins].
                  ingredients[ingreds].ingredient_histories[ingredhist].dose_unit_cd))," / ",
                formatvolume(mar_detail_reply->orders[d.seq].administrations[admins].ingredients[
                 ingreds].ingredient_histories[ingredhist].admin_volume),
                " ",trim(uar_get_code_display(mar_detail_reply->orders[d.seq].administrations[admins]
                  .ingredients[ingreds].ingredient_histories[ingredhist].volume_unit_cd)))
              ELSEIF ((mar_detail_reply->orders[d.seq].administrations[admins].ingredients[ingreds].
              ingredient_histories[ingredhist].admin_dose > 0))
               admin_dose = concat(formatstrength(mar_detail_reply->orders[d.seq].administrations[
                 admins].ingredients[ingreds].ingredient_histories[ingredhist].admin_dose)," ",trim(
                 uar_get_code_display(mar_detail_reply->orders[d.seq].administrations[admins].
                  ingredients[ingreds].ingredient_histories[ingredhist].dose_unit_cd)))
              ELSEIF ((mar_detail_reply->orders[d.seq].administrations[admins].ingredients[ingreds].
              ingredient_histories[ingredhist].admin_volume > 0))
               admin_dose = concat(formatvolume(mar_detail_reply->orders[d.seq].administrations[
                 admins].ingredients[ingreds].ingredient_histories[ingredhist].admin_volume)," ",trim
                (uar_get_code_display(mar_detail_reply->orders[d.seq].administrations[admins].
                  ingredients[ingreds].ingredient_histories[ingredhist].volume_unit_cd)))
              ELSE
               admin_dose = i18n_sna
              ENDIF
             ENDIF
             IF (notdone_found=1)
              ingred_print = trim(uar_get_code_display(mar_detail_reply->orders[d.seq].
                administrations[admins].event_cd))
             ELSE
              IF ((mar_detail_reply->orders[d.seq].top_level_order_type IN (cmed, cint)))
               ingred_print = concat(trim(uar_get_code_display(mar_detail_reply->orders[d.seq].
                  administrations[admins].ingredients[ingreds].ingredient_histories[ingredhist].
                  catalog_cd))," ",trim(admin_dose)," ",trim(uar_get_code_display(mar_detail_reply->
                  orders[d.seq].administrations[admins].ingredients[ingreds].ingredient_histories[
                  ingredhist].admin_route_cd)),
                " ",trim(uar_get_code_display(mar_detail_reply->orders[d.seq].administrations[admins]
                  .ingredients[ingreds].ingredient_histories[ingredhist].admin_site_cd)))
              ELSE
               ingred_print = concat(trim(uar_get_code_display(mar_detail_reply->orders[d.seq].
                  administrations[admins].ingredients[ingreds].ingredient_histories[ingredhist].
                  catalog_cd))," ",trim(admin_dose)," ",trim(uar_get_code_display(mar_detail_reply->
                  orders[d.seq].administrations[admins].ingredients[ingreds].ingredient_histories[
                  ingredhist].admin_route_cd)))
               IF ((((mar_detail_reply->orders[d.seq].administrations[admins].admin_histories[
               adminhist].iv_event_cd=cbeginbag)) OR ((mar_detail_reply->orders[d.seq].
               administrations[admins].admin_histories[adminhist].iv_event_cd=cratechange)))
                AND (mar_detail_reply->orders[d.seq].administrations[admins].ingredients[ingreds].
               ingredient_histories[ingredhist].infusion_rate_unit_cd > 0))
                IF ((mar_detail_reply->orders[d.seq].administrations[admins].ingredients[ingreds].
                ingredient_histories[ingredhist].infusion_rate=0))
                 ingred_print = concat(trim(ingred_print)," 0 ",trim(uar_get_code_display(
                    mar_detail_reply->orders[d.seq].administrations[admins].ingredients[ingreds].
                    ingredient_histories[ingredhist].infusion_rate_unit_cd)))
                ELSE
                 ingred_print = concat(formatrate(mar_detail_reply->orders[d.seq].administrations[
                   admins].ingredients[ingreds].ingredient_histories[ingredhist].infusion_rate)," ",
                  trim(uar_get_code_display(mar_detail_reply->orders[d.seq].administrations[admins].
                    ingredients[ingreds].ingredient_histories[ingredhist].infusion_rate_unit_cd)))
                ENDIF
               ENDIF
              ENDIF
             ENDIF
             IF (notdone_printed=0)
              typelength = 0, typelength = size(ingred_print,1)
              IF (ingreds=1)
               IF (print_column_format=cschedprintformat)
                col 91, note_text_in = fillstring(1000," "), note_text_in = "{B}",
                ingred_print, chars_per_line = 70, note_string = fillstring(90," "),
                col_start = (94+ typelength), prnt_note
               ELSE
                col 74, note_text_in = fillstring(1000," "), note_text_in = "{B}",
                ingred_print, chars_per_line = 87, note_string = fillstring(90," "),
                col_start = (77+ typelength), prnt_note
               ENDIF
              ELSE
               IF (print_column_format=cschedprintformat)
                col 130, note_text_in = fillstring(1000," "), note_text_in = "{B}",
                ingred_print, chars_per_line = 31, note_string = fillstring(90," "),
                col_start = (133+ typelength), prnt_note
               ELSE
                col 102, note_text_in = fillstring(1000," "), note_text_in = "{B}",
                ingred_print, chars_per_line = 59, note_string = fillstring(90," "),
                col_start = (105+ typelength), prnt_note
               ENDIF
              ENDIF
              row + 1
             ENDIF
             IF (((notdone_found=1) OR (notgiven_found=1))
              AND notdone_printed=0)
              typelength = 0, ingred_print = trim(mar_detail_reply->orders[d.seq].administrations[
               admins].ingredients[ingreds].ingredient_histories[ingredhist].event_tag), typelength
               = size(ingred_print,1)
              IF (print_column_format=cschedprintformat)
               col 130, note_text_in = fillstring(1000," "), note_text_in = "{B}",
               ingred_print, chars_per_line = 31, note_string = fillstring(90," "),
               col_start = (133+ typelength), prnt_note
              ELSE
               col 102, note_text_in = fillstring(1000," "), note_text_in = "{B}",
               ingred_print, chars_per_line = 59, note_string = fillstring(90," "),
               col_start = (105+ typelength), prnt_note
              ENDIF
              row + 1, notdone_printed = 1
             ENDIF
             IF ((mar_detail_reply->orders[d.seq].top_level_order_type=civ)
              AND ingreds=size(mar_detail_reply->orders[d.seq].administrations[admins].ingredients,5)
             )
              IF ((mar_detail_reply->orders[d.seq].administrations[admins].admin_histories[adminhist]
              .iv_event_cd=cbeginbag))
               IF ((mar_detail_reply->orders[d.seq].administrations[admins].admin_histories[adminhist
               ].initial_dose > 0)
                AND (mar_detail_reply->orders[d.seq].administrations[admins].admin_histories[
               adminhist].initial_volume > 0)
                AND (mar_detail_reply->orders[d.seq].administrations[admins].admin_histories[
               adminhist].initial_dose != mar_detail_reply->orders[d.seq].administrations[admins].
               admin_histories[adminhist].initial_volume))
                admin_volume = concat(formatstrength(mar_detail_reply->orders[d.seq].administrations[
                  admins].admin_histories[adminhist].initial_dose)," ",trim(uar_get_code_display(
                   mar_detail_reply->orders[d.seq].administrations[admins].admin_histories[adminhist]
                   .dose_unit_cd))," / ",formatvolume(mar_detail_reply->orders[d.seq].
                  administrations[admins].admin_histories[adminhist].initial_volume),
                 " ",trim(uar_get_code_display(mar_detail_reply->orders[d.seq].administrations[admins
                   ].admin_histories[adminhist].volume_unit_cd)))
               ELSEIF ((mar_detail_reply->orders[d.seq].administrations[admins].admin_histories[
               adminhist].initial_dose > 0))
                admin_volume = concat(formatstrength(mar_detail_reply->orders[d.seq].administrations[
                  admins].admin_histories[adminhist].initial_dose)," ",trim(uar_get_code_display(
                   mar_detail_reply->orders[d.seq].administrations[admins].admin_histories[adminhist]
                   .dose_unit_cd)))
               ELSEIF ((mar_detail_reply->orders[d.seq].administrations[admins].admin_histories[
               adminhist].initial_volume > 0))
                admin_volume = concat(formatvolume(mar_detail_reply->orders[d.seq].administrations[
                  admins].admin_histories[adminhist].initial_volume)," ",trim(uar_get_code_display(
                   mar_detail_reply->orders[d.seq].administrations[admins].admin_histories[adminhist]
                   .volume_unit_cd)))
               ELSE
                admin_volume = i18n_sna
               ENDIF
              ELSE
               IF ((mar_detail_reply->orders[d.seq].administrations[admins].admin_histories[adminhist
               ].admin_dose > 0)
                AND (mar_detail_reply->orders[d.seq].administrations[admins].admin_histories[
               adminhist].admin_volume > 0)
                AND (mar_detail_reply->orders[d.seq].administrations[admins].admin_histories[
               adminhist].admin_dose != mar_detail_reply->orders[d.seq].administrations[admins].
               admin_histories[adminhist].admin_volume))
                admin_volume = concat(formatstrength(mar_detail_reply->orders[d.seq].administrations[
                  admins].admin_histories[adminhist].admin_dose)," ",trim(uar_get_code_display(
                   mar_detail_reply->orders[d.seq].administrations[admins].admin_histories[adminhist]
                   .dose_unit_cd))," / ",formatvolume(mar_detail_reply->orders[d.seq].
                  administrations[admins].admin_histories[adminhist].admin_volume),
                 " ",trim(uar_get_code_display(mar_detail_reply->orders[d.seq].administrations[admins
                   ].admin_histories[adminhist].volume_unit_cd)))
               ELSEIF ((mar_detail_reply->orders[d.seq].administrations[admins].admin_histories[
               adminhist].admin_dose > 0))
                admin_volume = concat(formatstrength(mar_detail_reply->orders[d.seq].administrations[
                  admins].admin_histories[adminhist].admin_dose)," ",trim(uar_get_code_display(
                   mar_detail_reply->orders[d.seq].administrations[admins].admin_histories[adminhist]
                   .dose_unit_cd)))
               ELSEIF ((mar_detail_reply->orders[d.seq].administrations[admins].admin_histories[
               adminhist].admin_volume > 0))
                admin_volume = concat(formatvolume(mar_detail_reply->orders[d.seq].administrations[
                  admins].admin_histories[adminhist].admin_volume)," ",trim(uar_get_code_display(
                   mar_detail_reply->orders[d.seq].administrations[admins].admin_histories[adminhist]
                   .volume_unit_cd)))
               ELSE
                admin_volume = i18n_sna
               ENDIF
              ENDIF
              IF ((mar_detail_reply->orders[d.seq].administrations[admins].admin_histories[adminhist]
              .infusion_rate=0))
               admin_rate = concat("0 ",trim(uar_get_code_display(mar_detail_reply->orders[d.seq].
                  administrations[admins].admin_histories[adminhist].infusion_rate_unit_cd)))
              ELSE
               admin_rate = concat(formatrate(mar_detail_reply->orders[d.seq].administrations[admins]
                 .admin_histories[adminhist].infusion_rate)," ",trim(uar_get_code_display(
                  mar_detail_reply->orders[d.seq].administrations[admins].admin_histories[adminhist].
                  infusion_rate_unit_cd)))
              ENDIF
              admin_site = trim(uar_get_code_display(mar_detail_reply->orders[d.seq].administrations[
                admins].admin_histories[adminhist].admin_site_cd)), col 112, i18n_svolume,
              ": ", admin_volume, row + 1
              IF ((mar_detail_reply->orders[d.seq].administrations[admins].admin_histories[adminhist]
              .iv_event_cd IN (cbeginbag, cratechange)))
               col 112, i18n_srate, ": ",
               admin_rate, row + 1
              ENDIF
              col 112, i18n_ssite, ": ",
              admin_site, row + 1
             ENDIF
             IF (ingreds=size(mar_detail_reply->orders[d.seq].administrations[admins].ingredients,5)
              AND notdone_found=0
              AND unchart_found=0)
              FOR (discretes = 1 TO size(mar_detail_reply->orders[d.seq].administrations[admins].
               discretes,5))
                FOR (dtahist = 1 TO size(mar_detail_reply->orders[d.seq].administrations[admins].
                 discretes[discretes].result_histories,5))
                  IF ((mar_detail_reply->orders[d.seq].administrations[admins].discretes[discretes].
                  result_histories[dtahist].valid_from_dt_tm >= mar_detail_reply->orders[d.seq].
                  administrations[admins].admin_histories[adminhist].valid_from_dt_tm)
                   AND (mar_detail_reply->orders[d.seq].administrations[admins].discretes[discretes].
                  result_histories[dtahist].valid_until_dt_tm <= mar_detail_reply->orders[d.seq].
                  administrations[admins].admin_histories[adminhist].valid_until_dt_tm))
                   dta_result_val = ""
                   IF ((mar_detail_reply->orders[d.seq].administrations[admins].discretes[discretes].
                   event_class_cd=cnum))
                    dta_result_val = nullterm(trim(format(mar_detail_reply->orders[d.seq].
                       administrations[admins].discretes[discretes].result_histories[dtahist].
                       result_val,"####################;LIt(1)")))
                   ELSE
                    dta_result_val = mar_detail_reply->orders[d.seq].administrations[admins].
                    discretes[discretes].result_histories[dtahist].result_val
                   ENDIF
                   dta_hist = "", dta_hist = concat(trim(uar_get_code_display(mar_detail_reply->
                      orders[d.seq].administrations[admins].discretes[discretes].result_histories[
                      dtahist].event_cd))," ",trim(dta_result_val)," ",trim(uar_get_code_display(
                      mar_detail_reply->orders[d.seq].administrations[admins].discretes[discretes].
                      result_histories[dtahist].result_unit_cd)))
                   IF ((mar_detail_reply->orders[d.seq].administrations[admins].result_status_cd !=
                   ccharted))
                    IF (print_column_format=cschedprintformat)
                     col 130, "{B}", dta_hist
                    ELSE
                     col 104, "{B}", dta_hist
                    ENDIF
                    row + 1
                   ELSE
                    IF (print_column_format=cschedprintformat)
                     col 134, i18n_spreviousvalue, ":",
                     dta_hist
                    ELSE
                     col 108, i18n_spreviousvalue, ":",
                     dta_hist
                    ENDIF
                    row + 1
                   ENDIF
                   FOR (dtacomment = 1 TO size(mar_detail_reply->orders[d.seq].administrations[admins
                    ].discretes[discretes].result_comments,5))
                     IF ((mar_detail_reply->orders[d.seq].administrations[admins].discretes[discretes
                     ].result_histories[dtahist].valid_from_dt_tm >= mar_detail_reply->orders[d.seq].
                     administrations[admins].discretes[discretes].result_comments[dtacomment].
                     valid_from_dt_tm)
                      AND (mar_detail_reply->orders[d.seq].administrations[admins].discretes[
                     discretes].result_histories[dtahist].valid_until_dt_tm <= mar_detail_reply->
                     orders[d.seq].administrations[admins].discretes[discretes].result_comments[
                     dtacomment].valid_until_dt_tm))
                      dta_comment = "", comment_dt_tm = "", commenttype = "",
                      typelength = 0, dta_comment = mar_detail_reply->orders[d.seq].administrations[
                      admins].discretes[discretes].result_comments[dtacomment].comment_text,
                      comment_dt_tm = formatutcdatetime(mar_detail_reply->orders[d.seq].
                       administrations[admins].discretes[discretes].result_comments[dtacomment].
                       valid_from_dt_tm,mar_detail_reply->orders[d.seq].administrations[admins].
                       discretes[discretes].result_comments[dtacomment].note_tz,1),
                      commenttype = concat(trim(i18n_scommententeredat,3)," ",trim(comment_dt_tm,3)),
                      typelength = size(i18n_scommententeredat,1)
                      IF (print_column_format=cschedprintformat)
                       col 132, "{B}", commenttype,
                       row + 1, note_text_in = fillstring(1000," "), note_text_in = dta_comment,
                       chars_per_line = 45, note_string = fillstring(45," "), col_start = (135+
                       typelength),
                       prnt_note
                      ELSE
                       col 106, "{B}", commenttype,
                       row + 1, note_text_in = fillstring(1000," "), note_text_in = dta_comment,
                       chars_per_line = 55, note_string = fillstring(55," "), col_start = (120+
                       typelength),
                       prnt_note
                      ENDIF
                     ENDIF
                   ENDFOR
                  ENDIF
                ENDFOR
              ENDFOR
             ENDIF
             IF (ingreds=size(mar_detail_reply->orders[d.seq].administrations[admins].ingredients,5))
              IF ((mar_detail_reply->orders[d.seq].administrations[admins].ingredients[ingreds].
              event_class_cd=ceventimmun))
               IF (print_column_format=cschedprintformat)
                col 130, "{B}", i18n_simmunizationdetails
               ELSE
                col 111, "{B}", i18n_simmunizationdetails
               ENDIF
               row + 1, immun_detail = "", immun_detail = concat(i18n_sexpirationdate,": ",
                datetimezoneformat(mar_detail_reply->orders[d.seq].administrations[admins].
                 ingredients[ingreds].ingredient_histories[ingredhist].substance_exp_dt_tm,
                 mar_detail_reply->orders[d.seq].administrations[admins].event_end_tz,"@SHORTDATE"))
               IF (print_column_format=cschedprintformat)
                col 145, immun_detail
               ELSE
                col 136, immun_detail
               ENDIF
               row + 1, immun_detail = "", immun_detail = concat(i18n_slotnumber,": ",trim(
                 mar_detail_reply->orders[d.seq].administrations[admins].ingredients[ingreds].
                 ingredient_histories[ingredhist].substance_lot_number))
               IF (print_column_format=cschedprintformat)
                col 145, immun_detail
               ELSE
                col 136, immun_detail
               ENDIF
               row + 1, immun_detail = "", immun_detail = concat(i18n_smanufacturer,": ",trim(
                 uar_get_code_display(mar_detail_reply->orders[d.seq].administrations[admins].
                  ingredients[ingreds].ingredient_histories[ingredhist].substance_manufacturer_cd)))
               IF (print_column_format=cschedprintformat)
                col 145, immun_detail
               ELSE
                col 136, immun_detail
               ENDIF
               row + 1
              ENDIF
             ENDIF
             IF (ingreds=size(mar_detail_reply->orders[d.seq].administrations[admins].ingredients,5))
              FOR (admincomment = 1 TO size(mar_detail_reply->orders[d.seq].administrations[admins].
               result_comments,5))
                IF ((mar_detail_reply->orders[d.seq].administrations[admins].admin_histories[
                adminhist].valid_from_dt_tm=mar_detail_reply->orders[d.seq].administrations[admins].
                result_comments[admincomment].valid_from_dt_tm))
                 admin_comment = "", commenttype = "", typelength = 0,
                 admin_comment = mar_detail_reply->orders[d.seq].administrations[admins].
                 result_comments[admincomment].comment_text, commenttype = concat(trim(
                   uar_get_code_display(mar_detail_reply->orders[d.seq].administrations[admins].
                    result_comments[admincomment].note_type_cd)),":"), typelength = size(commenttype,
                  1)
                 IF (print_column_format=cschedprintformat)
                  col 130, "{B}", commenttype,
                  note_text_in = fillstring(1000," "), note_text_in = admin_comment, chars_per_line
                   = 45,
                  note_string = fillstring(45," "), col_start = (134+ typelength), prnt_note
                 ELSE
                  col 111, "{B}", commenttype,
                  note_text_in = fillstring(1000," "), note_text_in = admin_comment, chars_per_line
                   = 55,
                  note_string = fillstring(55," "), col_start = (115+ typelength), prnt_note
                 ENDIF
                ENDIF
              ENDFOR
             ENDIF
             FOR (ingredcomment = 1 TO size(mar_detail_reply->orders[d.seq].administrations[admins].
              ingredients[ingreds].result_comments,5))
               IF ((mar_detail_reply->orders[d.seq].administrations[admins].admin_histories[adminhist
               ].valid_from_dt_tm <= mar_detail_reply->orders[d.seq].administrations[admins].
               ingredients[ingreds].result_comments[ingredcomment].valid_from_dt_tm)
                AND ((1 < adminhist
                AND (mar_detail_reply->orders[d.seq].administrations[admins].ingredients[ingreds].
               result_comments[ingredcomment].valid_from_dt_tm < mar_detail_reply->orders[d.seq].
               administrations[admins].admin_histories[(adminhist - 1)].valid_from_dt_tm)) OR ((
               mar_detail_reply->orders[d.seq].administrations[admins].ingredients[ingreds].
               result_comments[ingredcomment].valid_from_dt_tm < mar_detail_reply->orders[d.seq].
               administrations[admins].valid_from_dt_tm)
                AND 1 >= adminhist)) )
                admin_comment = "", commenttype = "", typelength = 0,
                admin_comment = mar_detail_reply->orders[d.seq].administrations[admins].ingredients[
                ingreds].result_comments[ingredcomment].comment_text, commenttype = concat(trim(
                  uar_get_code_display(mar_detail_reply->orders[d.seq].administrations[admins].
                   ingredients[ingreds].result_comments[ingredcomment].note_type_cd)),":"),
                typelength = size(commenttype,1)
                IF (print_column_format=cschedprintformat)
                 col 130, "{B}", commenttype,
                 note_text_in = fillstring(1000," "), note_text_in = admin_comment, chars_per_line =
                 45,
                 note_string = fillstring(45," "), col_start = (134+ typelength), prnt_note
                ELSE
                 col 111, "{B}", commenttype,
                 note_text_in = fillstring(1000," "), note_text_in = admin_comment, chars_per_line =
                 55,
                 note_string = fillstring(55," "), col_start = (115+ typelength), prnt_note
                ENDIF
               ENDIF
             ENDFOR
             IF (ingreds=size(mar_detail_reply->orders[d.seq].administrations[admins].ingredients,5))
              IF (size(device_free_txt,1) > 0)
               IF (print_column_format=cschedprintformat)
                col 145, "{B}", i18n_sdevice,
                ":", note_text_in = fillstring(1000," "), note_text_in = device_free_txt,
                chars_per_line = 55, note_string = fillstring(55," "), col_start = 155,
                prnt_note
               ELSE
                col 136, "{B}", i18n_sdevice,
                ":", note_text_in = fillstring(1000," "), note_text_in = device_free_txt,
                chars_per_line = 55, note_string = fillstring(55," "), col_start = 146,
                prnt_note
               ENDIF
              ENDIF
              FOR (prsnl = 1 TO size(mar_detail_reply->orders[d.seq].administrations[admins].
               event_prsnl_actions,5))
               result_action_dt_tm = "",
               IF ((mar_detail_reply->orders[d.seq].administrations[admins].event_prsnl_actions[prsnl
               ].valid_from_dt_tm=mar_detail_reply->orders[d.seq].administrations[admins].
               admin_histories[adminhist].valid_from_dt_tm))
                IF ( NOT ((mar_detail_reply->orders[d.seq].administrations[admins].
                event_prsnl_actions[prsnl].action_type_cd IN (cprsnlorder, cprsnlverify))))
                 action_prsnl_label = "", action_prsnl_info = "", proxy_prsnl_label = "",
                 proxy_prsnl_info = "", request_prsnl_label = "", request_prsnl_info = ""
                 IF ((mar_detail_reply->orders[d.seq].administrations[admins].event_prsnl_actions[
                 prsnl].action_type_cd=cchartmodify))
                  result_action_dt_tm = formatutcdatetime(mar_detail_reply->orders[d.seq].
                   administrations[admins].event_prsnl_actions[prsnl].action_dt_tm,mar_detail_reply->
                   orders[d.seq].administrations[admins].event_prsnl_actions[prsnl].action_tz,1),
                  action_prsnl_label = concat(trim(i18n_smodifiedby),": "), action_prsnl_info =
                  concat(trim(mar_detail_reply->orders[d.seq].administrations[admins].
                    event_prsnl_actions[prsnl].action_prsnl_name)," ",trim(i18n_sat)," ",
                   result_action_dt_tm)
                 ELSE
                  IF ((mar_detail_reply->orders[d.seq].administrations[admins].event_prsnl_actions[
                  prsnl].action_type_cd=cperform))
                   action_prsnl_label = concat(trim(i18n_sperformedby),": ")
                  ELSEIF ((mar_detail_reply->orders[d.seq].administrations[admins].
                  event_prsnl_actions[prsnl].action_type_cd=cwitness))
                   action_prsnl_label = concat(trim(i18n_switnessedby),": ")
                  ELSEIF ((mar_detail_reply->orders[d.seq].administrations[admins].
                  event_prsnl_actions[prsnl].action_type_cd=csign))
                   action_prsnl_label = concat(trim(i18n_ssignedby),": ")
                  ELSEIF ((mar_detail_reply->orders[d.seq].administrations[admins].
                  event_prsnl_actions[prsnl].action_type_cd=creview))
                   action_prsnl_label = concat(trim(i18n_sreviewedby),": ")
                  ELSE
                   action_prsnl_label = concat(trim(uar_get_code_display(mar_detail_reply->orders[d
                      .seq].administrations[admins].event_prsnl_actions[prsnl].action_type_cd)),": ")
                  ENDIF
                  action_prsnl_info = trim(mar_detail_reply->orders[d.seq].administrations[admins].
                   event_prsnl_actions[prsnl].action_prsnl_name)
                 ENDIF
                 IF ((mar_detail_reply->orders[d.seq].administrations[admins].event_prsnl_actions[
                 prsnl].proxy_prsnl_id > 0.0))
                  proxy_prsnl_label = concat(trim(i18n_sproxy),": "), proxy_prsnl_info = trim(
                   mar_detail_reply->orders[d.seq].administrations[admins].event_prsnl_actions[prsnl]
                   .proxy_prsnl_name)
                 ENDIF
                 IF ((mar_detail_reply->orders[d.seq].administrations[admins].event_prsnl_actions[
                 prsnl].request_prsnl_id > 0.0))
                  request_prsnl_label = concat(trim(i18n_srequest),": "), request_prsnl_info = trim(
                   mar_detail_reply->orders[d.seq].administrations[admins].event_prsnl_actions[prsnl]
                   .request_prsnl_name)
                 ENDIF
                 IF (print_column_format=cschedprintformat)
                  col 145, "{B}", action_prsnl_label,
                  "{ENDB}", action_prsnl_info
                  IF (proxy_prsnl_info != "")
                   row + 1, col 145, "{B}",
                   proxy_prsnl_label, "{ENDB}", proxy_prsnl_info
                  ENDIF
                  IF (request_prsnl_info != "")
                   row + 1, col 145, "{B}",
                   request_prsnl_label, "{ENDB}", request_prsnl_info
                  ENDIF
                  IF ((mar_detail_reply->orders[d.seq].administrations[admins].event_prsnl_actions[
                  prsnl].action_comment != ""))
                   row + 1, col 155, "{B}",
                   i18n_sactioncomment, ":", note_text_in = fillstring(1000," "),
                   note_text_in = mar_detail_reply->orders[d.seq].administrations[admins].
                   event_prsnl_actions[prsnl].action_comment, chars_per_line = 55, note_string =
                   fillstring(55," "),
                   col_start = 175, prnt_note
                  ENDIF
                  IF ((mar_detail_reply->orders[d.seq].administrations[admins].event_prsnl_actions[
                  prsnl].request_comment != "")
                   AND (mar_detail_reply->orders[d.seq].administrations[admins].event_prsnl_actions[
                  prsnl].request_comment != mar_detail_reply->orders[d.seq].administrations[admins].
                  event_prsnl_actions[prsnl].action_comment))
                   row + 1, col 155, "{B}",
                   i18n_srequestcomment, ":", note_text_in = fillstring(1000," "),
                   note_text_in = mar_detail_reply->orders[d.seq].administrations[admins].
                   event_prsnl_actions[prsnl].request_comment, chars_per_line = 55, note_string =
                   fillstring(55," "),
                   col_start = 175, prnt_note
                  ENDIF
                 ELSE
                  col 136, "{B}", action_prsnl_label,
                  "{ENDB}", action_prsnl_info
                  IF (proxy_prsnl_info != "")
                   row + 1, col 136, "{B}",
                   proxy_prsnl_label, "{ENDB}", proxy_prsnl_info
                  ENDIF
                  IF (request_prsnl_info != "")
                   row + 1, col 136, "{B}",
                   request_prsnl_label, "{ENDB}", request_prsnl_info
                  ENDIF
                  IF ((mar_detail_reply->orders[d.seq].administrations[admins].event_prsnl_actions[
                  prsnl].action_comment != ""))
                   row + 1, col 146, "{B}",
                   i18n_sactioncomment, ":", note_text_in = fillstring(1000," "),
                   note_text_in = mar_detail_reply->orders[d.seq].administrations[admins].
                   event_prsnl_actions[prsnl].action_comment, chars_per_line = 55, note_string =
                   fillstring(55," "),
                   col_start = 166, prnt_note
                  ENDIF
                  IF ((mar_detail_reply->orders[d.seq].administrations[admins].event_prsnl_actions[
                  prsnl].request_comment != "")
                   AND (mar_detail_reply->orders[d.seq].administrations[admins].event_prsnl_actions[
                  prsnl].request_comment != mar_detail_reply->orders[d.seq].administrations[admins].
                  event_prsnl_actions[prsnl].action_comment))
                   row + 1, col 146, "{B}",
                   i18n_srequestcomment, ":", note_text_in = fillstring(1000," "),
                   note_text_in = mar_detail_reply->orders[d.seq].administrations[admins].
                   event_prsnl_actions[prsnl].request_comment, chars_per_line = 55, note_string =
                   fillstring(55," "),
                   col_start = 166, prnt_note
                  ENDIF
                 ENDIF
                 row + 1
                ENDIF
               ENDIF
              ENDFOR
             ENDIF
            ENDIF
          ENDFOR
         ENDFOR
         FOR (ingreds = 1 TO size(mar_detail_reply->orders[d.seq].administrations[admins].ingredients,
          5))
           FOR (prsnl = 1 TO size(mar_detail_reply->orders[d.seq].administrations[admins].
            ingredients[ingreds].event_prsnl_actions,5))
            result_action_dt_tm = "",
            IF ((mar_detail_reply->orders[d.seq].administrations[admins].ingredients[ingreds].
            event_prsnl_actions[prsnl].action_type_cd IN (csign, creview)))
             action_prsnl_label = "", action_prsnl_info = "", proxy_prsnl_label = "",
             proxy_prsnl_info = "", request_prsnl_label = "", request_prsnl_info = ""
             IF ((mar_detail_reply->orders[d.seq].administrations[admins].ingredients[ingreds].
             event_prsnl_actions[prsnl].action_type_cd=csign))
              action_prsnl_label = concat(trim(i18n_ssignedby),": ")
             ELSEIF ((mar_detail_reply->orders[d.seq].administrations[admins].ingredients[ingreds].
             event_prsnl_actions[prsnl].action_type_cd=creview))
              action_prsnl_label = concat(trim(i18n_sreviewedby),": ")
             ENDIF
             action_prsnl_info = trim(mar_detail_reply->orders[d.seq].administrations[admins].
              ingredients[ingreds].event_prsnl_actions[prsnl].action_prsnl_name)
             IF ((mar_detail_reply->orders[d.seq].administrations[admins].ingredients[ingreds].
             event_prsnl_actions[prsnl].proxy_prsnl_id > 0.0))
              proxy_prsnl_label = concat(trim(i18n_sproxy),": "), proxy_prsnl_info = trim(
               mar_detail_reply->orders[d.seq].administrations[admins].ingredients[ingreds].
               event_prsnl_actions[prsnl].proxy_prsnl_name)
             ENDIF
             IF ((mar_detail_reply->orders[d.seq].administrations[admins].ingredients[ingreds].
             event_prsnl_actions[prsnl].request_prsnl_id > 0.0))
              request_prsnl_label = concat(trim(i18n_srequest),": "), request_prsnl_info = trim(
               mar_detail_reply->orders[d.seq].administrations[admins].ingredients[ingreds].
               event_prsnl_actions[prsnl].request_prsnl_name)
             ENDIF
             IF (print_column_format=cschedprintformat)
              col 145, "{B}", action_prsnl_label,
              "{ENDB}", action_prsnl_info
              IF (proxy_prsnl_info != "")
               row + 1, col 145, "{B}",
               proxy_prsnl_label, "{ENDB}", proxy_prsnl_info
              ENDIF
              IF (request_prsnl_info != "")
               row + 1, col 145, "{B}",
               request_prsnl_label, "{ENDB}", request_prsnl_info
              ENDIF
              IF ((mar_detail_reply->orders[d.seq].administrations[admins].ingredients[ingreds].
              event_prsnl_actions[prsnl].action_comment != ""))
               row + 1, col 145, "{B}",
               i18n_sactioncomment, ":", note_text_in = fillstring(1000," "),
               note_text_in = mar_detail_reply->orders[d.seq].administrations[admins].ingredients[
               ingreds].event_prsnl_actions[prsnl].action_comment, chars_per_line = 55, note_string
                = fillstring(55," "),
               col_start = 155, prnt_note
              ENDIF
              IF ((mar_detail_reply->orders[d.seq].administrations[admins].ingredients[ingreds].
              event_prsnl_actions[prsnl].request_comment != "")
               AND (mar_detail_reply->orders[d.seq].administrations[admins].ingredients[ingreds].
              event_prsnl_actions[prsnl].request_comment != mar_detail_reply->orders[d.seq].
              administrations[admins].ingredients[ingreds].event_prsnl_actions[prsnl].action_comment)
              )
               row + 1, col 145, "{B}",
               i18n_srequestcomment, ":", note_text_in = fillstring(1000," "),
               note_text_in = mar_detail_reply->orders[d.seq].administrations[admins].ingredients[
               ingreds].event_prsnl_actions[prsnl].request_comment, chars_per_line = 55, note_string
                = fillstring(55," "),
               col_start = 165, prnt_note
              ENDIF
             ELSE
              col 136, "{B}", action_prsnl_label,
              "{ENDB}", action_prsnl_info
              IF (proxy_prsnl_info != "")
               row + 1, col 136, "{B}",
               proxy_prsnl_label, "{ENDB}", proxy_prsnl_info
              ENDIF
              IF (request_prsnl_info != "")
               row + 1, col 136, "{B}",
               request_prsnl_label, "{ENDB}", request_prsnl_info
              ENDIF
              IF ((mar_detail_reply->orders[d.seq].administrations[admins].ingredients[ingreds].
              event_prsnl_actions[prsnl].action_comment != ""))
               row + 1, col 136, "{B}",
               i18n_sactioncomment, ":", note_text_in = fillstring(1000," "),
               note_text_in = mar_detail_reply->orders[d.seq].administrations[admins].ingredients[
               ingreds].event_prsnl_actions[prsnl].action_comment, chars_per_line = 55, note_string
                = fillstring(55," "),
               col_start = 146, prnt_note
              ENDIF
              IF ((mar_detail_reply->orders[d.seq].administrations[admins].ingredients[ingreds].
              event_prsnl_actions[prsnl].request_comment != "")
               AND (mar_detail_reply->orders[d.seq].administrations[admins].ingredients[ingreds].
              event_prsnl_actions[prsnl].request_comment != mar_detail_reply->orders[d.seq].
              administrations[admins].ingredients[ingreds].event_prsnl_actions[prsnl].action_comment)
              )
               row + 1, col 136, "{B}",
               i18n_srequestcomment, ":", note_text_in = fillstring(1000," "),
               note_text_in = mar_detail_reply->orders[d.seq].administrations[admins].ingredients[
               ingreds].event_prsnl_actions[prsnl].request_comment, chars_per_line = 55, note_string
                = fillstring(55," "),
               col_start = 156, prnt_note
              ENDIF
             ENDIF
             row + 1
            ENDIF
           ENDFOR
         ENDFOR
         adminhist = (adminhist - 1)
       ENDWHILE
       notdone_found = 0, notdone_printed = 0, unchart_found = 0,
       notgiven_found = 0, admin_action = "", admin_dt_time = "",
       scheduled_admin = "", bag_number = "", admin_volume = "",
       admin_rate = "", admin_site = "", scheduled_admin_na_ind = 0,
       device_free_txt = ""
       IF ((mar_detail_reply->orders[d.seq].top_level_order_type=civ)
        AND  NOT ((mar_detail_reply->orders[d.seq].administrations[admins].result_status_cd IN (
       caltered, cmodified, cunchart))))
        admin_action = uar_get_code_display(mar_detail_reply->orders[d.seq].administrations[admins].
         iv_event_cd), bag_number = trim(mar_detail_reply->orders[d.seq].administrations[admins].
         substance_lot_number,3)
       ELSE
        IF ((mar_detail_reply->orders[d.seq].top_level_order_type=civ))
         bag_number = trim(mar_detail_reply->orders[d.seq].administrations[admins].
          substance_lot_number,3)
        ENDIF
        IF ((mar_detail_reply->orders[d.seq].top_level_order_type=civ))
         bag_number = trim(mar_detail_reply->orders[d.seq].administrations[admins].
          substance_lot_number,3)
        ENDIF
        IF ((mar_detail_reply->orders[d.seq].administrations[admins].result_status_cd=ccharted))
         admin_action = i18n_smedgiven
        ELSEIF ((mar_detail_reply->orders[d.seq].administrations[admins].result_status_cd=cunchart))
         unchart_found = 1, admin_action = concat("*",i18n_suncharted,"*")
        ELSEIF ((mar_detail_reply->orders[d.seq].administrations[admins].result_status_cd=cnotgiven))
         IF ((mar_detail_reply->orders[d.seq].administrations[admins].event_cd=cdcpgeneric))
          notgiven_found = 1, admin_action = i18n_snotgiven
         ELSE
          admin_action = trim(mar_detail_reply->orders[d.seq].administrations[admins].event_tag),
          notdone_found = 1
         ENDIF
        ELSEIF ((mar_detail_reply->orders[d.seq].administrations[admins].result_status_cd IN (
        caltered, cmodified)))
         admin_action = concat("*",i18n_smodified,"*")
        ELSE
         admin_action = concat("*",trim(uar_get_code_display(mar_detail_reply->orders[d.seq].
            administrations[admins].result_status_cd)),"*")
        ENDIF
       ENDIF
       IF ((mar_detail_reply->orders[d.seq].administrations[admins].result_status_cd IN (caltered,
       cmodified, cunchart)))
        admin_action = formatlabelbylength(admin_action,13), col 4, "{B}",
        admin_action
       ELSE
        admin_action = formatlabelbylength(admin_action,15), col 2, "{B}",
        admin_action
       ENDIF
       IF ((mar_detail_reply->orders[d.seq].top_level_order_type=civ))
        trimmed_label = formatlabelbylength(i18n_sbag,6), col 18, trimmed_label,
        " ", bag_number
       ENDIF
       performed_dt_tm = formatutcdatetime(mar_detail_reply->orders[d.seq].administrations[admins].
        performed_dt_tm,mar_detail_reply->orders[d.seq].administrations[admins].performed_tz,1),
       admin_dt_time = formatutcdatetime(mar_detail_reply->orders[d.seq].administrations[admins].
        event_end_dt_tm,mar_detail_reply->orders[d.seq].administrations[admins].event_end_tz,1),
       device_free_txt = trim(mar_detail_reply->orders[d.seq].administrations[admins].device_free_txt,
        3)
       IF (print_column_format=cschedprintformat)
        IF ((mar_detail_reply->orders[d.seq].top_level_order_id=mar_detail_reply->orders[d.seq].
        administrations[admins].order_id))
         scheduled_admin = concat("          ",i18n_sna), scheduled_admin_na_ind = 1
        ELSE
         scheduled_admin = formatutcdatetime(mar_detail_reply->orders[d.seq].administrations[admins].
          scheduled_admin_dt_tm,mar_detail_reply->orders[d.seq].administrations[admins].
          scheduled_admin_tz,1)
        ENDIF
        col 22, performed_dt_tm, col 45,
        scheduled_admin
        IF (scheduled_admin_na_ind=1)
         col 75, admin_dt_time
        ELSE
         col 68, admin_dt_time
        ENDIF
       ELSE
        col 28, performed_dt_tm, col 50,
        admin_dt_time
       ENDIF
       FOR (ingreds = 1 TO size(mar_detail_reply->orders[d.seq].administrations[admins].ingredients,5
        ))
         admin_dose = ""
         IF ((mar_detail_reply->orders[d.seq].administrations[admins].iv_event_cd=cbeginbag))
          IF ((mar_detail_reply->orders[d.seq].administrations[admins].ingredients[ingreds].
          result_status_cd=cnotgiven))
           admin_dose = trim(mar_detail_reply->orders[d.seq].administrations[admins].ingredients[
            ingreds].event_tag)
          ELSEIF ((mar_detail_reply->orders[d.seq].administrations[admins].ingredients[ingreds].
          initial_dose > 0)
           AND (mar_detail_reply->orders[d.seq].administrations[admins].ingredients[ingreds].
          initial_volume > 0)
           AND (mar_detail_reply->orders[d.seq].administrations[admins].ingredients[ingreds].
          initial_dose != mar_detail_reply->orders[d.seq].administrations[admins].ingredients[ingreds
          ].initial_volume))
           admin_dose = concat(formatstrength(mar_detail_reply->orders[d.seq].administrations[admins]
             .ingredients[ingreds].initial_dose)," ",trim(uar_get_code_display(mar_detail_reply->
              orders[d.seq].administrations[admins].ingredients[ingreds].dose_unit_cd))," / ",
            formatvolume(mar_detail_reply->orders[d.seq].administrations[admins].ingredients[ingreds]
             .initial_volume),
            " ",trim(uar_get_code_display(mar_detail_reply->orders[d.seq].administrations[admins].
              ingredients[ingreds].volume_unit_cd)))
          ELSEIF ((mar_detail_reply->orders[d.seq].administrations[admins].ingredients[ingreds].
          initial_dose > 0))
           admin_dose = concat(formatstrength(mar_detail_reply->orders[d.seq].administrations[admins]
             .ingredients[ingreds].initial_dose)," ",trim(uar_get_code_display(mar_detail_reply->
              orders[d.seq].administrations[admins].ingredients[ingreds].dose_unit_cd)))
          ELSEIF ((mar_detail_reply->orders[d.seq].administrations[admins].ingredients[ingreds].
          initial_volume > 0))
           admin_dose = concat(formatvolume(mar_detail_reply->orders[d.seq].administrations[admins].
             ingredients[ingreds].initial_volume)," ",trim(uar_get_code_display(mar_detail_reply->
              orders[d.seq].administrations[admins].ingredients[ingreds].volume_unit_cd)))
          ELSE
           admin_dose = concat(" ",i18n_sna)
          ENDIF
         ELSE
          IF ((mar_detail_reply->orders[d.seq].administrations[admins].ingredients[ingreds].
          admin_dose > 0)
           AND (mar_detail_reply->orders[d.seq].administrations[admins].ingredients[ingreds].
          admin_volume > 0)
           AND (mar_detail_reply->orders[d.seq].administrations[admins].ingredients[ingreds].
          admin_dose != mar_detail_reply->orders[d.seq].administrations[admins].ingredients[ingreds].
          admin_volume))
           admin_dose = concat(formatstrength(mar_detail_reply->orders[d.seq].administrations[admins]
             .ingredients[ingreds].admin_dose)," ",trim(uar_get_code_display(mar_detail_reply->
              orders[d.seq].administrations[admins].ingredients[ingreds].dose_unit_cd))," / ",
            formatvolume(mar_detail_reply->orders[d.seq].administrations[admins].ingredients[ingreds]
             .admin_volume),
            " ",trim(uar_get_code_display(mar_detail_reply->orders[d.seq].administrations[admins].
              ingredients[ingreds].volume_unit_cd)))
          ELSEIF ((mar_detail_reply->orders[d.seq].administrations[admins].ingredients[ingreds].
          admin_dose > 0))
           admin_dose = concat(formatstrength(mar_detail_reply->orders[d.seq].administrations[admins]
             .ingredients[ingreds].admin_dose)," ",trim(uar_get_code_display(mar_detail_reply->
              orders[d.seq].administrations[admins].ingredients[ingreds].dose_unit_cd)))
          ELSEIF ((mar_detail_reply->orders[d.seq].administrations[admins].ingredients[ingreds].
          admin_volume > 0))
           admin_dose = concat(formatvolume(mar_detail_reply->orders[d.seq].administrations[admins].
             ingredients[ingreds].admin_volume)," ",trim(uar_get_code_display(mar_detail_reply->
              orders[d.seq].administrations[admins].ingredients[ingreds].volume_unit_cd)))
          ELSE
           admin_dose = concat(" ",i18n_sna)
          ENDIF
         ENDIF
         IF (notdone_found=1)
          ingred_print = trim(uar_get_code_display(mar_detail_reply->orders[d.seq].administrations[
            admins].event_cd))
         ELSE
          IF ((mar_detail_reply->orders[d.seq].top_level_order_type IN (cmed, cint)))
           ingred_print = concat(trim(uar_get_code_display(mar_detail_reply->orders[d.seq].
              administrations[admins].ingredients[ingreds].catalog_cd))," ",trim(admin_dose)," ",trim
            (uar_get_code_display(mar_detail_reply->orders[d.seq].administrations[admins].
              ingredients[ingreds].admin_route_cd)),
            " ",trim(uar_get_code_display(mar_detail_reply->orders[d.seq].administrations[admins].
              ingredients[ingreds].admin_site_cd)))
          ELSE
           ingred_print = concat(trim(uar_get_code_display(mar_detail_reply->orders[d.seq].
              administrations[admins].ingredients[ingreds].catalog_cd))," ",trim(admin_dose)," ",trim
            (uar_get_code_display(mar_detail_reply->orders[d.seq].administrations[admins].
              ingredients[ingreds].admin_route_cd)))
           IF ((((mar_detail_reply->orders[d.seq].administrations[admins].iv_event_cd=cbeginbag)) OR
           ((mar_detail_reply->orders[d.seq].administrations[admins].iv_event_cd=cratechange)))
            AND (mar_detail_reply->orders[d.seq].administrations[admins].ingredients[ingreds].
           infusion_rate_unit_cd > 0))
            IF ((mar_detail_reply->orders[d.seq].administrations[admins].ingredients[ingreds].
            infusion_rate=0))
             ingred_print = concat(trim(ingred_print)," 0 ",trim(uar_get_code_display(
                mar_detail_reply->orders[d.seq].administrations[admins].ingredients[ingreds].
                infusion_rate_unit_cd)))
            ELSE
             ingred_print = concat(trim(ingred_print)," ",formatrate(mar_detail_reply->orders[d.seq].
               administrations[admins].ingredients[ingreds].infusion_rate)," ",trim(
               uar_get_code_display(mar_detail_reply->orders[d.seq].administrations[admins].
                ingredients[ingreds].infusion_rate_unit_cd)))
            ENDIF
           ENDIF
          ENDIF
         ENDIF
         IF (notdone_printed=0)
          typelength = 0, typelength = size(ingred_print,1)
          IF (ingreds=1)
           IF (print_column_format=cschedprintformat)
            IF (scheduled_admin_na_ind=1)
             col 97, note_text_in = fillstring(1000," "), note_text_in = "{B}",
             ingred_print, chars_per_line = 64, note_string = fillstring(90," "),
             col_start = (100+ typelength), prnt_note
            ELSE
             col 91, note_text_in = fillstring(1000," "), note_text_in = "{B}",
             ingred_print, chars_per_line = 70, note_string = fillstring(90," "),
             col_start = (94+ typelength), prnt_note
            ENDIF
           ELSE
            col 74, note_text_in = fillstring(1000," "), note_text_in = "{B}",
            ingred_print, chars_per_line = 87, note_string = fillstring(90," "),
            col_start = (77+ typelength), prnt_note
           ENDIF
          ELSE
           IF (print_column_format=cschedprintformat)
            col 130, note_text_in = fillstring(1000," "), note_text_in = "{B}",
            ingred_print, chars_per_line = 31, note_string = fillstring(90," "),
            col_start = (133+ typelength), prnt_note
           ELSE
            col 102, note_text_in = fillstring(1000," "), note_text_in = "{B}",
            ingred_print, chars_per_line = 59, note_string = fillstring(90," "),
            col_start = (105+ typelength), prnt_note
           ENDIF
          ENDIF
          row + 1
         ENDIF
         IF (((notdone_found=1) OR (notgiven_found=1))
          AND notdone_printed=0)
          ingred_print = trim(mar_detail_reply->orders[d.seq].administrations[admins].ingredients[
           ingreds].event_tag), typelength = size(ingred_print,1)
          IF (print_column_format=cschedprintformat)
           col 130, note_text_in = fillstring(1000," "), note_text_in = "{B}",
           ingred_print, chars_per_line = 31, note_string = fillstring(90," "),
           col_start = (133+ typelength), prnt_note
          ELSE
           col 102, note_text_in = fillstring(1000," "), note_text_in = "{B}",
           ingred_print, chars_per_line = 59, note_string = fillstring(90," "),
           col_start = (105+ typelength), prnt_note
          ENDIF
          row + 1, notdone_printed = 1
         ENDIF
         IF ((mar_detail_reply->orders[d.seq].top_level_order_type=civ)
          AND ingreds=size(mar_detail_reply->orders[d.seq].administrations[admins].ingredients,5))
          IF ((mar_detail_reply->orders[d.seq].administrations[admins].iv_event_cd=cbeginbag))
           IF ((mar_detail_reply->orders[d.seq].administrations[admins].initial_dose > 0)
            AND (mar_detail_reply->orders[d.seq].administrations[admins].initial_volume > 0)
            AND (mar_detail_reply->orders[d.seq].administrations[admins].initial_dose !=
           mar_detail_reply->orders[d.seq].administrations[admins].initial_volume))
            admin_volume = concat(formatstrength(mar_detail_reply->orders[d.seq].administrations[
              admins].initial_dose)," ",trim(uar_get_code_display(mar_detail_reply->orders[d.seq].
               administrations[admins].dose_unit_cd))," / ",formatvolume(mar_detail_reply->orders[d
              .seq].administrations[admins].initial_volume),
             " ",trim(uar_get_code_display(mar_detail_reply->orders[d.seq].administrations[admins].
               volume_unit_cd)))
           ELSEIF ((mar_detail_reply->orders[d.seq].administrations[admins].initial_dose > 0))
            admin_volume = concat(formatstrength(mar_detail_reply->orders[d.seq].administrations[
              admins].initial_dose)," ",trim(uar_get_code_display(mar_detail_reply->orders[d.seq].
               administrations[admins].dose_unit_cd)))
           ELSEIF ((mar_detail_reply->orders[d.seq].administrations[admins].initial_volume > 0))
            admin_volume = concat(formatvolume(mar_detail_reply->orders[d.seq].administrations[admins
              ].initial_volume)," ",trim(uar_get_code_display(mar_detail_reply->orders[d.seq].
               administrations[admins].volume_unit_cd)))
           ELSE
            admin_volume = concat(" ",i18n_sna)
           ENDIF
          ELSE
           IF ((mar_detail_reply->orders[d.seq].administrations[admins].admin_dose > 0)
            AND (mar_detail_reply->orders[d.seq].administrations[admins].admin_volume > 0)
            AND (mar_detail_reply->orders[d.seq].administrations[admins].admin_dose !=
           mar_detail_reply->orders[d.seq].administrations[admins].admin_volume))
            admin_volume = concat(formatstrength(mar_detail_reply->orders[d.seq].administrations[
              admins].admin_dose)," ",trim(uar_get_code_display(mar_detail_reply->orders[d.seq].
               administrations[admins].dose_unit_cd))," / ",formatvolume(mar_detail_reply->orders[d
              .seq].administrations[admins].admin_volume),
             " ",trim(uar_get_code_display(mar_detail_reply->orders[d.seq].administrations[admins].
               volume_unit_cd)))
           ELSEIF ((mar_detail_reply->orders[d.seq].administrations[admins].admin_dose > 0))
            admin_volume = concat(formatstrength(mar_detail_reply->orders[d.seq].administrations[
              admins].admin_dose)," ",trim(uar_get_code_display(mar_detail_reply->orders[d.seq].
               administrations[admins].dose_unit_cd)))
           ELSEIF ((mar_detail_reply->orders[d.seq].administrations[admins].admin_volume > 0))
            admin_volume = concat(formatvolume(mar_detail_reply->orders[d.seq].administrations[admins
              ].admin_volume)," ",trim(uar_get_code_display(mar_detail_reply->orders[d.seq].
               administrations[admins].volume_unit_cd)))
           ELSE
            admin_volume = concat(" ",i18n_sna)
           ENDIF
          ENDIF
          IF ((mar_detail_reply->orders[d.seq].administrations[admins].infusion_rate=0))
           admin_rate = concat("0 ",trim(uar_get_code_display(mar_detail_reply->orders[d.seq].
              administrations[admins].infusion_rate_unit_cd)))
          ELSE
           admin_rate = concat(formatrate(mar_detail_reply->orders[d.seq].administrations[admins].
             infusion_rate)," ",trim(uar_get_code_display(mar_detail_reply->orders[d.seq].
              administrations[admins].infusion_rate_unit_cd)))
          ENDIF
          admin_site = trim(uar_get_code_display(mar_detail_reply->orders[d.seq].administrations[
            admins].admin_site_cd)), col 112, i18n_svolume,
          ": ", admin_volume, row + 1
          IF ((mar_detail_reply->orders[d.seq].administrations[admins].iv_event_cd IN (cbeginbag,
          cratechange)))
           col 112, i18n_srate, ": ",
           admin_rate, row + 1
          ENDIF
          col 112, i18n_ssite, ": ",
          admin_site, row + 1
         ENDIF
         IF (ingreds=size(mar_detail_reply->orders[d.seq].administrations[admins].ingredients,5)
          AND notdone_found=0
          AND unchart_found=0)
          FOR (discretes = 1 TO size(mar_detail_reply->orders[d.seq].administrations[admins].
           discretes,5))
            IF ((mar_detail_reply->orders[d.seq].administrations[admins].valid_from_dt_tm <=
            mar_detail_reply->orders[d.seq].administrations[admins].discretes[discretes].
            valid_from_dt_tm))
             dta_result_val = ""
             IF ((mar_detail_reply->orders[d.seq].administrations[admins].discretes[discretes].
             event_class_cd=cnum))
              dta_result_val = nullterm(trim(format(mar_detail_reply->orders[d.seq].administrations[
                 admins].discretes[discretes].result_val,"####################;LIt(2)")))
             ELSE
              dta_result_val = mar_detail_reply->orders[d.seq].administrations[admins].discretes[
              discretes].result_val
             ENDIF
             dta = "", dta = concat(trim(uar_get_code_display(mar_detail_reply->orders[d.seq].
                administrations[admins].discretes[discretes].event_cd))," ",trim(dta_result_val)," ",
              trim(uar_get_code_display(mar_detail_reply->orders[d.seq].administrations[admins].
                discretes[discretes].result_unit_cd)))
             IF (print_column_format=cschedprintformat)
              col 130, "{B}", dta
             ELSE
              col 104, "{B}", dta
             ENDIF
             row + 1
             FOR (dtacomment = 1 TO size(mar_detail_reply->orders[d.seq].administrations[admins].
              discretes[discretes].result_comments,5))
               IF ((mar_detail_reply->orders[d.seq].administrations[admins].discretes[discretes].
               valid_from_dt_tm >= mar_detail_reply->orders[d.seq].administrations[admins].discretes[
               discretes].result_comments[dtacomment].valid_from_dt_tm)
                AND (mar_detail_reply->orders[d.seq].administrations[admins].discretes[discretes].
               valid_until_dt_tm <= mar_detail_reply->orders[d.seq].administrations[admins].
               discretes[discretes].result_comments[dtacomment].valid_until_dt_tm))
                dta_comment = "", comment_dt_tm = "", commenttype = "",
                typelength = 0, dta_comment = mar_detail_reply->orders[d.seq].administrations[admins]
                .discretes[discretes].result_comments[dtacomment].comment_text, comment_dt_tm =
                formatutcdatetime(mar_detail_reply->orders[d.seq].administrations[admins].discretes[
                 discretes].result_comments[dtacomment].valid_from_dt_tm,mar_detail_reply->orders[d
                 .seq].administrations[admins].discretes[discretes].result_comments[dtacomment].
                 note_tz,1),
                commenttype = concat(trim(i18n_scommententeredat,3)," ",trim(comment_dt_tm,3)),
                typelength = size(i18n_scommententeredat,1)
                IF (print_column_format=cschedprintformat)
                 col 132, "{B}", commenttype,
                 row + 1, note_text_in = fillstring(1000," "), note_text_in = dta_comment,
                 chars_per_line = 55, note_string = fillstring(55," "), col_start = (135+ typelength),
                 prnt_note
                ELSE
                 col 106, "{B}", commenttype,
                 row + 1, note_text_in = fillstring(1000," "), note_text_in = dta_comment,
                 chars_per_line = 65, note_string = fillstring(65," "), col_start = (120+ typelength),
                 prnt_note
                ENDIF
               ENDIF
             ENDFOR
             FOR (dtahist = 1 TO size(mar_detail_reply->orders[d.seq].administrations[admins].
              discretes[discretes].result_histories,5))
               IF ((mar_detail_reply->orders[d.seq].administrations[admins].valid_from_dt_tm <=
               mar_detail_reply->orders[d.seq].administrations[admins].discretes[discretes].
               result_histories[dtahist].valid_from_dt_tm)
                AND (mar_detail_reply->orders[d.seq].administrations[admins].valid_until_dt_tm >=
               mar_detail_reply->orders[d.seq].administrations[admins].discretes[discretes].
               result_histories[dtahist].valid_until_dt_tm))
                dta_result_val = ""
                IF ((mar_detail_reply->orders[d.seq].administrations[admins].discretes[discretes].
                event_class_cd=cnum))
                 dta_result_val = nullterm(trim(format(mar_detail_reply->orders[d.seq].
                    administrations[admins].discretes[discretes].result_histories[dtahist].result_val,
                    "####################;LIt(1)")))
                ELSE
                 dta_result_val = mar_detail_reply->orders[d.seq].administrations[admins].discretes[
                 discretes].result_histories[dtahist].result_val
                ENDIF
                dta_hist = "", dta_hist = concat(trim(uar_get_code_display(mar_detail_reply->orders[d
                   .seq].administrations[admins].discretes[discretes].result_histories[dtahist].
                   event_cd))," ",trim(dta_result_val)," ",trim(uar_get_code_display(mar_detail_reply
                   ->orders[d.seq].administrations[admins].discretes[discretes].result_histories[
                   dtahist].result_unit_cd)))
                IF (print_column_format=cschedprintformat)
                 col 134, i18n_spreviousvalue, ":",
                 dta_hist
                ELSE
                 col 108, i18n_spreviousvalue, ":",
                 dta_hist
                ENDIF
                row + 1
                FOR (dtacomment = 1 TO size(mar_detail_reply->orders[d.seq].administrations[admins].
                 discretes[discretes].result_comments,5))
                  IF ((mar_detail_reply->orders[d.seq].administrations[admins].discretes[discretes].
                  result_histories[dtahist].valid_from_dt_tm >= mar_detail_reply->orders[d.seq].
                  administrations[admins].discretes[discretes].result_comments[dtacomment].
                  valid_from_dt_tm)
                   AND (mar_detail_reply->orders[d.seq].administrations[admins].discretes[discretes].
                  result_histories[dtahist].valid_until_dt_tm <= mar_detail_reply->orders[d.seq].
                  administrations[admins].discretes[discretes].result_comments[dtacomment].
                  valid_until_dt_tm))
                   dta_comment = "", comment_dt_tm = "", commenttype = "",
                   typelength = 0, dta_comment = mar_detail_reply->orders[d.seq].administrations[
                   admins].discretes[discretes].result_comments[dtacomment].comment_text,
                   comment_dt_tm = formatutcdatetime(mar_detail_reply->orders[d.seq].administrations[
                    admins].discretes[discretes].result_comments[dtacomment].valid_from_dt_tm,
                    mar_detail_reply->orders[d.seq].administrations[admins].discretes[discretes].
                    result_comments[dtacomment].note_tz,1),
                   commenttype = concat(trim(i18n_scommententeredat,3)," ",trim(comment_dt_tm,3)),
                   typelength = size(i18n_scommententeredat,1)
                   IF (print_column_format=cschedprintformat)
                    col 132, "{B}", commenttype,
                    row + 1, note_text_in = fillstring(1000," "), note_text_in = dta_comment,
                    chars_per_line = 55, note_string = fillstring(55," "), col_start = (135+
                    typelength),
                    prnt_note
                   ELSE
                    col 106, "{B}", commenttype,
                    row + 1, note_text_in = fillstring(1000," "), note_text_in = dta_comment,
                    chars_per_line = 65, note_string = fillstring(65," "), col_start = (120+
                    typelength),
                    prnt_note
                   ENDIF
                  ENDIF
                ENDFOR
               ENDIF
             ENDFOR
            ENDIF
          ENDFOR
          IF (ingreds=size(mar_detail_reply->orders[d.seq].administrations[admins].ingredients,5))
           IF ((mar_detail_reply->orders[d.seq].administrations[admins].ingredients[ingreds].
           event_class_cd=ceventimmun))
            IF (print_column_format=cschedprintformat)
             col 130, "{B}", i18n_simmunizationdetails
            ELSE
             col 111, "{B}", i18n_simmunizationdetails
            ENDIF
            row + 1, immun_detail = "", immun_detail = concat(i18n_sexpirationdate,": ",
             datetimezoneformat(mar_detail_reply->orders[d.seq].administrations[admins].ingredients[
              ingreds].substance_exp_dt_tm,mar_detail_reply->orders[d.seq].administrations[admins].
              event_end_tz,"@SHORTDATE"))
            IF (print_column_format=cschedprintformat)
             col 145, immun_detail
            ELSE
             col 136, immun_detail
            ENDIF
            row + 1, immun_detail = "", immun_detail = concat(i18n_slotnumber,": ",trim(
              mar_detail_reply->orders[d.seq].administrations[admins].ingredients[ingreds].
              substance_lot_number))
            IF (print_column_format=cschedprintformat)
             col 145, immun_detail
            ELSE
             col 136, immun_detail
            ENDIF
            row + 1, immun_detail = "", immun_detail = concat(i18n_smanufacturer,": ",trim(
              uar_get_code_display(mar_detail_reply->orders[d.seq].administrations[admins].
               ingredients[ingreds].substance_manufacturer_cd)))
            IF (print_column_format=cschedprintformat)
             col 145, immun_detail
            ELSE
             col 136, immun_detail
            ENDIF
            row + 1
           ENDIF
          ENDIF
          FOR (acknowledgement = 1 TO size(mar_detail_reply->orders[d.seq].administrations[admins].
           acknowledgements,5))
            ack_info = "", ack_info = concat(trim(uar_get_code_display(mar_detail_reply->orders[d.seq
               ].administrations[admins].acknowledgements[acknowledgement].event_cd))," ",trim(
              mar_detail_reply->orders[d.seq].administrations[admins].acknowledgements[
              acknowledgement].result_val)," ",trim(uar_get_code_display(mar_detail_reply->orders[d
               .seq].administrations[admins].acknowledgements[acknowledgement].result_units_cd)),
             " ",trim(formatutcdatetime(mar_detail_reply->orders[d.seq].administrations[admins].
               acknowledgements[acknowledgement].event_end_dt_tm,mar_detail_reply->orders[d.seq].
               administrations[admins].acknowledgements[acknowledgement].event_end_tz,1)))
            IF (print_column_format=cschedprintformat)
             col 130, "{B}", ack_info
            ELSE
             col 124, "{B}", ack_info
            ENDIF
            row + 1
            FOR (ack_comment = 1 TO size(mar_detail_reply->orders[d.seq].administrations[admins].
             acknowledgements[acknowledgement].result_comments,5))
              IF ((mar_detail_reply->orders[d.seq].administrations[admins].acknowledgements[
              acknowledgement].valid_from_dt_tm >= mar_detail_reply->orders[d.seq].administrations[
              admins].acknowledgements[acknowledgement].result_comments[ack_comment].valid_from_dt_tm
              )
               AND (mar_detail_reply->orders[d.seq].administrations[admins].acknowledgements[
              acknowledgement].valid_until_dt_tm <= mar_detail_reply->orders[d.seq].administrations[
              admins].acknowledgements[acknowledgement].result_comments[ack_comment].
              valid_until_dt_tm))
               ack_comment_info = "", comment_dt_tm = "", commenttype = "",
               typelength = 0, ack_comment_info = trim(mar_detail_reply->orders[d.seq].
                administrations[admins].acknowledgements[acknowledgement].result_comments[ack_comment
                ].comment_text), comment_dt_tm = formatutcdatetime(mar_detail_reply->orders[d.seq].
                administrations[admins].acknowledgements[acknowledgement].result_comments[ack_comment
                ].valid_from_dt_tm,mar_detail_reply->orders[d.seq].administrations[admins].
                acknowledgements[acknowledgement].result_comments[ack_comment].note_tz,1),
               commenttype = concat(trim(i18n_scommententeredat,3)," ",trim(comment_dt_tm,3)),
               typelength = size(i18n_scommententeredat,1)
               IF (print_column_format=cschedprintformat)
                col 132, "{B}", commenttype,
                row + 1, note_text_in = fillstring(1000," "), note_text_in = ack_comment_info,
                chars_per_line = 55, note_string = fillstring(55," "), col_start = (135+ typelength),
                prnt_note
               ELSE
                col 106, "{B}", commenttype,
                row + 1, note_text_in = fillstring(1000," "), note_text_in = ack_comment_info,
                chars_per_line = 65, note_string = fillstring(65," "), col_start = (120+ typelength),
                prnt_note
               ENDIF
               row + 1
              ENDIF
            ENDFOR
          ENDFOR
         ENDIF
         IF (ingreds=size(mar_detail_reply->orders[d.seq].administrations[admins].ingredients,5))
          FOR (admincomment = 1 TO size(mar_detail_reply->orders[d.seq].administrations[admins].
           result_comments,5))
            IF ((mar_detail_reply->orders[d.seq].administrations[admins].valid_from_dt_tm <=
            mar_detail_reply->orders[d.seq].administrations[admins].result_comments[admincomment].
            valid_from_dt_tm))
             admin_comment = "", commenttype = "", typelength = 0,
             admin_comment = mar_detail_reply->orders[d.seq].administrations[admins].result_comments[
             admincomment].comment_text, commenttype = concat(trim(uar_get_code_display(
                mar_detail_reply->orders[d.seq].administrations[admins].result_comments[admincomment]
                .note_type_cd)),":"), typelength = size(commenttype,1)
             IF (print_column_format=cschedprintformat)
              col 130, "{B}", commenttype,
              note_text_in = fillstring(1000," "), note_text_in = admin_comment, chars_per_line = 55,
              note_string = fillstring(55," "), col_start = (134+ typelength), prnt_note
             ELSE
              col 111, "{B}", commenttype,
              note_text_in = fillstring(1000," "), note_text_in = admin_comment, chars_per_line = 65,
              note_string = fillstring(65," "), col_start = (115+ typelength), prnt_note
             ENDIF
            ENDIF
          ENDFOR
         ENDIF
         FOR (ingredcomment = 1 TO size(mar_detail_reply->orders[d.seq].administrations[admins].
          ingredients[ingreds].result_comments,5))
           IF ((mar_detail_reply->orders[d.seq].administrations[admins].valid_from_dt_tm <=
           mar_detail_reply->orders[d.seq].administrations[admins].ingredients[ingreds].
           result_comments[ingredcomment].valid_from_dt_tm))
            admin_comment = "", commenttype = "", typelength = 0,
            admin_comment = mar_detail_reply->orders[d.seq].administrations[admins].ingredients[
            ingreds].result_comments[ingredcomment].comment_text, commenttype = concat(trim(
              uar_get_code_display(mar_detail_reply->orders[d.seq].administrations[admins].
               ingredients[ingreds].result_comments[ingredcomment].note_type_cd)),":"), typelength =
            size(commenttype,1)
            IF (print_column_format=cschedprintformat)
             col 130, "{B}", commenttype,
             note_text_in = fillstring(1000," "), note_text_in = admin_comment, chars_per_line = 55,
             note_string = fillstring(55," "), col_start = (134+ typelength), prnt_note
            ELSE
             col 111, "{B}", commenttype,
             note_text_in = fillstring(1000," "), note_text_in = admin_comment, chars_per_line = 65,
             note_string = fillstring(65," "), col_start = (115+ typelength), prnt_note
            ENDIF
           ENDIF
         ENDFOR
       ENDFOR
       IF (size(device_free_txt,1) > 0)
        IF (print_column_format=cschedprintformat)
         col 145, "{B}", i18n_sdevice,
         ":", note_text_in = fillstring(1000," "), note_text_in = device_free_txt,
         chars_per_line = 55, note_string = fillstring(55," "), col_start = 155,
         prnt_note
        ELSE
         col 136, "{B}", i18n_sdevice,
         ":", note_text_in = fillstring(1000," "), note_text_in = device_free_txt,
         chars_per_line = 55, note_string = fillstring(55," "), col_start = 146,
         prnt_note
        ENDIF
       ENDIF
       previous_action_cd = 0.0, previous_action_prsnl_id = 0.0, printed_action_prsnl_info = 0
       FOR (prsnl = 1 TO size(mar_detail_reply->orders[d.seq].administrations[admins].
        event_prsnl_actions,5))
        result_action_dt_tm = "",
        IF ((((mar_detail_reply->orders[d.seq].administrations[admins].event_prsnl_actions[prsnl].
        valid_from_dt_tm=mar_detail_reply->orders[d.seq].administrations[admins].valid_from_dt_tm))
         OR ((mar_detail_reply->orders[d.seq].administrations[admins].event_prsnl_actions[prsnl].
        action_type_cd IN (csign, creview)))) )
         IF ( NOT ((mar_detail_reply->orders[d.seq].administrations[admins].event_prsnl_actions[prsnl
         ].action_type_cd IN (cprsnlorder, cprsnlverify))))
          IF ((previous_action_cd != mar_detail_reply->orders[d.seq].administrations[admins].
          event_prsnl_actions[prsnl].action_type_cd)
           AND (previous_action_prsnl_id != mar_detail_reply->orders[d.seq].administrations[admins].
          event_prsnl_actions[prsnl].action_prsnl_id))
           previous_action_cd = mar_detail_reply->orders[d.seq].administrations[admins].
           event_prsnl_actions[prsnl].action_type_cd, previous_action_prsnl_id = mar_detail_reply->
           orders[d.seq].administrations[admins].event_prsnl_actions[prsnl].action_prsnl_id,
           action_prsnl_label = "",
           action_prsnl_info = "", proxy_prsnl_label = "", proxy_prsnl_info = "",
           request_prsnl_label = "", request_prsnl_info = ""
           IF ((mar_detail_reply->orders[d.seq].administrations[admins].event_prsnl_actions[prsnl].
           action_type_cd=cchartmodify))
            result_action_dt_tm = formatutcdatetime(mar_detail_reply->orders[d.seq].administrations[
             admins].event_prsnl_actions[prsnl].action_dt_tm,mar_detail_reply->orders[d.seq].
             administrations[admins].event_prsnl_actions[prsnl].action_tz,1), action_prsnl_label =
            concat(trim(i18n_smodifiedby),": "), action_prsnl_info = concat(trim(mar_detail_reply->
              orders[d.seq].administrations[admins].event_prsnl_actions[prsnl].action_prsnl_name)," ",
             trim(i18n_sat)," ",result_action_dt_tm)
           ELSE
            IF ((mar_detail_reply->orders[d.seq].administrations[admins].event_prsnl_actions[prsnl].
            action_type_cd=cperform))
             action_prsnl_label = concat(trim(i18n_sperformedby),": ")
            ELSEIF ((mar_detail_reply->orders[d.seq].administrations[admins].event_prsnl_actions[
            prsnl].action_type_cd=cprsnlverify))
             action_prsnl_label = concat(trim(i18n_sverifiedby),": ")
            ELSEIF ((mar_detail_reply->orders[d.seq].administrations[admins].event_prsnl_actions[
            prsnl].action_type_cd=cwitness))
             action_prsnl_label = concat(trim(i18n_switnessedby),": ")
            ELSEIF ((mar_detail_reply->orders[d.seq].administrations[admins].event_prsnl_actions[
            prsnl].action_type_cd=csign))
             action_prsnl_label = concat(trim(i18n_ssignedby),": ")
            ELSEIF ((mar_detail_reply->orders[d.seq].administrations[admins].event_prsnl_actions[
            prsnl].action_type_cd=creview))
             action_prsnl_label = concat(trim(i18n_sreviewedby),": ")
            ELSEIF ((mar_detail_reply->orders[d.seq].administrations[admins].event_prsnl_actions[
            prsnl].action_type_cd=cprsnlorder))
             action_prsnl_label = concat(trim(i18n_sorderedby),": ")
            ELSE
             action_prsnl_label = concat(trim(uar_get_code_display(mar_detail_reply->orders[d.seq].
                administrations[admins].event_prsnl_actions[prsnl].action_type_cd)),": ")
            ENDIF
            action_prsnl_info = trim(mar_detail_reply->orders[d.seq].administrations[admins].
             event_prsnl_actions[prsnl].action_prsnl_name)
           ENDIF
           IF ((mar_detail_reply->orders[d.seq].administrations[admins].event_prsnl_actions[prsnl].
           proxy_prsnl_id > 0.0))
            proxy_prsnl_label = concat(trim(i18n_sproxy),": "), proxy_prsnl_info = trim(
             mar_detail_reply->orders[d.seq].administrations[admins].event_prsnl_actions[prsnl].
             proxy_prsnl_name)
           ENDIF
           IF ((mar_detail_reply->orders[d.seq].administrations[admins].event_prsnl_actions[prsnl].
           request_prsnl_id > 0.0))
            request_prsnl_label = concat(trim(i18n_srequest),": "), request_prsnl_info = trim(
             mar_detail_reply->orders[d.seq].administrations[admins].event_prsnl_actions[prsnl].
             request_prsnl_name)
           ENDIF
           IF (print_column_format=cschedprintformat)
            col 145, "{B}", action_prsnl_label,
            "{ENDB}", action_prsnl_info, printed_action_prsnl_info = 1
            IF (proxy_prsnl_info != "")
             row + 1, col 145, "{B}",
             proxy_prsnl_label, "{ENDB}", proxy_prsnl_info
            ENDIF
            IF (request_prsnl_info != "")
             row + 1, col 145, "{B}",
             request_prsnl_label, "{ENDB}", request_prsnl_info
            ENDIF
            IF ((mar_detail_reply->orders[d.seq].administrations[admins].event_prsnl_actions[prsnl].
            action_comment != ""))
             row + 1, col 145, "{B}",
             i18n_sactioncomment, ":", note_text_in = fillstring(1000," "),
             note_text_in = mar_detail_reply->orders[d.seq].administrations[admins].
             event_prsnl_actions[prsnl].action_comment, chars_per_line = 55, note_string = fillstring
             (55," "),
             col_start = 155, prnt_note
            ENDIF
            IF ((mar_detail_reply->orders[d.seq].administrations[admins].event_prsnl_actions[prsnl].
            request_comment != "")
             AND (mar_detail_reply->orders[d.seq].administrations[admins].event_prsnl_actions[prsnl].
            request_comment != mar_detail_reply->orders[d.seq].administrations[admins].
            event_prsnl_actions[prsnl].action_comment))
             row + 1, col 145, "{B}",
             i18n_srequestcomment, ":", note_text_in = fillstring(1000," "),
             note_text_in = mar_detail_reply->orders[d.seq].administrations[admins].
             event_prsnl_actions[prsnl].request_comment, chars_per_line = 55, note_string =
             fillstring(55," "),
             col_start = 165, prnt_note
            ENDIF
           ELSE
            col 136, "{B}", action_prsnl_label,
            "{ENDB}", action_prsnl_info, printed_action_prsnl_info = 1
            IF (proxy_prsnl_info != "")
             row + 1, col 136, "{B}",
             proxy_prsnl_label, "{ENDB}", proxy_prsnl_info
            ENDIF
            IF (request_prsnl_info != "")
             row + 1, col 136, "{B}",
             request_prsnl_label, "{ENDB}", request_prsnl_info
            ENDIF
            IF ((mar_detail_reply->orders[d.seq].administrations[admins].event_prsnl_actions[prsnl].
            action_comment != ""))
             row + 1, col 136, "{B}",
             i18n_sactioncomment, ":", note_text_in = fillstring(1000," "),
             note_text_in = mar_detail_reply->orders[d.seq].administrations[admins].
             event_prsnl_actions[prsnl].action_comment, chars_per_line = 55, note_string = fillstring
             (55," "),
             col_start = 146, prnt_note
            ENDIF
            IF ((mar_detail_reply->orders[d.seq].administrations[admins].event_prsnl_actions[prsnl].
            request_comment != "")
             AND (mar_detail_reply->orders[d.seq].administrations[admins].event_prsnl_actions[prsnl].
            request_comment != mar_detail_reply->orders[d.seq].administrations[admins].
            event_prsnl_actions[prsnl].action_comment))
             row + 1, col 136, "{B}",
             i18n_srequestcomment, ":", note_text_in = fillstring(1000," "),
             note_text_in = mar_detail_reply->orders[d.seq].administrations[admins].
             event_prsnl_actions[prsnl].request_comment, chars_per_line = 55, note_string =
             fillstring(55," "),
             col_start = 156, prnt_note
            ENDIF
           ENDIF
           row + 1
          ENDIF
         ENDIF
        ENDIF
       ENDFOR
       IF (printed_action_prsnl_info=0
        AND (mar_detail_reply->orders[d.seq].administrations[admins].result_status_cd=cunchart))
        action_prsnl_label = "", action_prsnl_info = "", proxy_prsnl_label = "",
        proxy_prsnl_info = "", request_prsnl_label = "", request_prsnl_info = "",
        result_action_dt_tm = formatutcdatetime(mar_detail_reply->orders[d.seq].administrations[
         admins].valid_from_dt_tm,mar_detail_reply->orders[d.seq].administrations[admins].
         performed_tz,1), action_prsnl_label = concat(trim(i18n_sunchartedby),": "),
        action_prsnl_info = concat(trim(mar_detail_reply->orders[d.seq].administrations[admins].
          performed_prsnl_name)," ",i18n_sat," ",result_action_dt_tm)
        IF (print_column_format=cschedprintformat)
         col 145, "{B}", action_prsnl_label,
         "{ENDB}", action_prsnl_info, row + 1
        ELSE
         col 136, "{B}", action_prsnl_label,
         "{ENDB}", action_prsnl_info, row + 1
        ENDIF
       ENDIF
       FOR (ingreds = 1 TO size(mar_detail_reply->orders[d.seq].administrations[admins].ingredients,5
        ))
         FOR (prsnl = 1 TO size(mar_detail_reply->orders[d.seq].administrations[admins].ingredients[
          ingreds].event_prsnl_actions,5))
           IF ((mar_detail_reply->orders[d.seq].administrations[admins].ingredients[ingreds].
           event_prsnl_actions[prsnl].valid_from_dt_tm=mar_detail_reply->orders[d.seq].
           administrations[admins].ingredients[ingreds].valid_from_dt_tm))
            IF ((mar_detail_reply->orders[d.seq].administrations[admins].ingredients[ingreds].
            event_prsnl_actions[prsnl].action_type_cd IN (csign, creview)))
             action_prsnl_label = "", action_prsnl_info = "", proxy_prsnl_label = "",
             proxy_prsnl_info = "", request_prsnl_label = "", request_prsnl_info = ""
             IF ((mar_detail_reply->orders[d.seq].administrations[admins].ingredients[ingreds].
             event_prsnl_actions[prsnl].action_type_cd=csign))
              action_prsnl_label = concat(trim(i18n_ssignedby),": ")
             ELSEIF ((mar_detail_reply->orders[d.seq].administrations[admins].ingredients[ingreds].
             event_prsnl_actions[prsnl].action_type_cd=creview))
              action_prsnl_label = concat(trim(i18n_sreviewedby),": ")
             ENDIF
             action_prsnl_info = trim(mar_detail_reply->orders[d.seq].administrations[admins].
              ingredients[ingreds].event_prsnl_actions[prsnl].action_prsnl_name)
             IF ((mar_detail_reply->orders[d.seq].administrations[admins].ingredients[ingreds].
             event_prsnl_actions[prsnl].proxy_prsnl_id > 0.0))
              proxy_prsnl_label = concat(trim(i18n_sproxy),": "), proxy_prsnl_info = trim(
               mar_detail_reply->orders[d.seq].administrations[admins].ingredients[ingreds].
               event_prsnl_actions[prsnl].proxy_prsnl_name)
             ENDIF
             IF ((mar_detail_reply->orders[d.seq].administrations[admins].ingredients[ingreds].
             event_prsnl_actions[prsnl].request_prsnl_id > 0.0))
              request_prsnl_label = concat(trim(i18n_srequest),": "), request_prsnl_info = trim(
               mar_detail_reply->orders[d.seq].administrations[admins].ingredients[ingreds].
               event_prsnl_actions[prsnl].request_prsnl_name)
             ENDIF
             IF (print_column_format=cschedprintformat)
              col 145, "{B}", action_prsnl_label,
              "{ENDB}", action_prsnl_info
              IF (proxy_prsnl_info != "")
               row + 1, col 145, "{B}",
               proxy_prsnl_label, "{ENDB}", proxy_prsnl_info
              ENDIF
              IF (request_prsnl_info != "")
               row + 1, col 145, "{B}",
               request_prsnl_label, "{ENDB}", request_prsnl_info
              ENDIF
              IF ((mar_detail_reply->orders[d.seq].administrations[admins].ingredients[ingreds].
              event_prsnl_actions[prsnl].action_comment != ""))
               row + 1, col 145, "{B}",
               i18n_sactioncomment, ":", note_text_in = fillstring(1000," "),
               note_text_in = mar_detail_reply->orders[d.seq].administrations[admins].ingredients[
               ingreds].event_prsnl_actions[prsnl].action_comment, chars_per_line = 55, note_string
                = fillstring(55," "),
               col_start = 165, prnt_note
              ENDIF
              IF ((mar_detail_reply->orders[d.seq].administrations[admins].ingredients[ingreds].
              event_prsnl_actions[prsnl].request_comment != "")
               AND (mar_detail_reply->orders[d.seq].administrations[admins].ingredients[ingreds].
              event_prsnl_actions[prsnl].request_comment != mar_detail_reply->orders[d.seq].
              administrations[admins].ingredients[ingreds].event_prsnl_actions[prsnl].action_comment)
              )
               row + 1, col 145, "{B}",
               i18n_srequestcomment, ":", note_text_in = fillstring(1000," "),
               note_text_in = mar_detail_reply->orders[d.seq].administrations[admins].ingredients[
               ingreds].event_prsnl_actions[prsnl].request_comment, chars_per_line = 55, note_string
                = fillstring(55," "),
               col_start = 165, prnt_note
              ENDIF
             ELSE
              col 136, "{B}", action_prsnl_label,
              "{ENDB}", action_prsnl_info
              IF (proxy_prsnl_info != "")
               row + 1, col 136, "{B}",
               proxy_prsnl_label, "{ENDB}", proxy_prsnl_info
              ENDIF
              IF (request_prsnl_info != "")
               row + 1, col 136, "{B}",
               request_prsnl_label, "{ENDB}", request_prsnl_info
              ENDIF
              IF ((mar_detail_reply->orders[d.seq].administrations[admins].ingredients[ingreds].
              event_prsnl_actions[prsnl].action_comment != ""))
               row + 1, col 136, "{B}",
               i18n_sactioncomment, ":", note_text_in = fillstring(1000," "),
               note_text_in = mar_detail_reply->orders[d.seq].administrations[admins].ingredients[
               ingreds].event_prsnl_actions[prsnl].action_comment, chars_per_line = 55, note_string
                = fillstring(55," "),
               col_start = 156, prnt_note
              ENDIF
              IF ((mar_detail_reply->orders[d.seq].administrations[admins].ingredients[ingreds].
              event_prsnl_actions[prsnl].request_comment != "")
               AND (mar_detail_reply->orders[d.seq].administrations[admins].ingredients[ingreds].
              event_prsnl_actions[prsnl].request_comment != mar_detail_reply->orders[d.seq].
              administrations[admins].ingredients[ingreds].event_prsnl_actions[prsnl].action_comment)
              )
               row + 1, col 136, "{B}",
               i18n_srequestcomment, ":", note_text_in = fillstring(1000," "),
               note_text_in = mar_detail_reply->orders[d.seq].administrations[admins].ingredients[
               ingreds].event_prsnl_actions[prsnl].request_comment, chars_per_line = 55, note_string
                = fillstring(55," "),
               col_start = 156, prnt_note
              ENDIF
             ENDIF
             row + 1
            ENDIF
           ENDIF
         ENDFOR
       ENDFOR
       FOR (responses = 1 TO size(mar_detail_reply->orders[d.seq].responseresults,5))
         IF ((mar_detail_reply->orders[d.seq].administrations[admins].core_action_sequence=
         mar_detail_reply->orders[d.seq].responseresults[responses].admin_core_action_seq)
          AND (mar_detail_reply->orders[d.seq].administrations[admins].parent_event_id=
         mar_detail_reply->orders[d.seq].responseresults[responses].admin_parent_event_id))
          FOR (action_cnt = 1 TO size(mar_detail_reply->orders[d.seq].responseresults[responses].
           response_actions,5))
            response_dt_tm = "", performed_dt_tm = "", parent_response_idx = 0
            FOR (events = 1 TO size(mar_detail_reply->orders[d.seq].responseresults[responses].
             response_actions[action_cnt].events,5))
              IF ((mar_detail_reply->orders[d.seq].responseresults[responses].response_actions[
              action_cnt].events[events].event_id=mar_detail_reply->orders[d.seq].responseresults[
              responses].response_actions[action_cnt].events[events].parent_event_id))
               parent_response_idx = events, events = (size(mar_detail_reply->orders[d.seq].
                responseresults[responses].response_actions[action_cnt].events,5)+ 1)
              ENDIF
            ENDFOR
            IF (parent_response_idx=0
             AND size(mar_detail_reply->orders[d.seq].responseresults[responses].response_actions[
             action_cnt].events,5) > 0)
             parent_response_idx = 1
            ENDIF
            IF (parent_response_idx > 0)
             performed_dt_tm = formatutcdatetime(mar_detail_reply->orders[d.seq].responseresults[
              responses].response_actions[action_cnt].events[parent_response_idx].performed_dt_tm,
              mar_detail_reply->orders[d.seq].responseresults[responses].response_actions[action_cnt]
              .events[parent_response_idx].performed_tz,1), response_dt_tm = formatutcdatetime(
              mar_detail_reply->orders[d.seq].responseresults[responses].response_actions[action_cnt]
              .events[parent_response_idx].event_end_dt_tm,mar_detail_reply->orders[d.seq].
              responseresults[responses].response_actions[action_cnt].events[parent_response_idx].
              event_end_tz,1)
            ENDIF
            IF (action_cnt=1)
             response_action_disp = concat("*",i18n_sresponse,"*"), response_action_disp =
             formatlabelbylength(response_action_disp,13), col 5,
             "{B}", response_action_disp
            ELSE
             IF (parent_response_idx > 0)
              IF ((mar_detail_reply->orders[d.seq].responseresults[responses].response_actions[
              action_cnt].events[parent_response_idx].result_status_cd=cnotgiven))
               response_action_disp = concat("*",i18n_snotdone,"*"), response_action_disp =
               formatlabelbylength(response_action_disp,13)
              ELSEIF ((mar_detail_reply->orders[d.seq].responseresults[responses].response_actions[
              action_cnt].events[parent_response_idx].result_status_cd=cunchart))
               response_action_disp = concat("*",i18n_suncharted,"*"), response_action_disp =
               formatlabelbylength(response_action_disp,13)
              ELSEIF ((((mar_detail_reply->orders[d.seq].responseresults[responses].response_actions[
              action_cnt].events[parent_response_idx].result_status_cd=cmodified)) OR ((((
              mar_detail_reply->orders[d.seq].responseresults[responses].response_actions[action_cnt]
              .events[parent_response_idx].result_status_cd=caltered)) OR ((mar_detail_reply->orders[
              d.seq].responseresults[responses].response_actions[action_cnt].events[
              parent_response_idx].result_status_cd=ccharted))) )) )
               response_action_disp = concat("*",i18n_smodified,"*"), response_action_disp =
               formatlabelbylength(response_action_disp,13)
              ELSE
               response_action_disp = concat("*",trim(uar_get_code_display(mar_detail_reply->orders[d
                  .seq].responseresults[responses].response_actions[action_cnt].events[
                  parent_response_idx].result_status_cd)),"*"), response_action_disp =
               formatlabelbylength(response_action_disp,13)
              ENDIF
              col 7, "{B}", response_action_disp
             ENDIF
            ENDIF
            IF (print_column_format=cschedprintformat)
             col 23, performed_dt_tm, col 50,
             "     ", i18n_sna, col 75,
             response_dt_tm
            ELSE
             col 28, performed_dt_tm, col 50,
             response_dt_tm
            ENDIF
            stat = alterlist(response_print_data->text,0), idummyval = storeresponseevents(d.seq,
             responses,action_cnt,parent_response_idx)
            FOR (response_data_cnt = 1 TO size(response_print_data->text,5))
              IF ((response_print_data->text[response_data_cnt].comment_type != ""))
               print_col = response_print_data->text[response_data_cnt].comment_col, col print_col,
               "{B}",
               response_print_data->text[response_data_cnt].comment_type
              ENDIF
              note_text_in = fillstring(1000," "), note_text_in = response_print_data->text[
              response_data_cnt].response_info, chars_per_line = response_print_data->text[
              response_data_cnt].chars_per_line,
              note_string = response_print_data->text[response_data_cnt].note_string, col_start =
              response_print_data->text[response_data_cnt].col_start, prnt_note
            ENDFOR
            IF (parent_response_idx > 0
             AND parent_response_idx <= size(mar_detail_reply->orders[d.seq].responseresults[
             responses].response_actions[action_cnt].events,5))
             FOR (prsnl = 1 TO size(mar_detail_reply->orders[d.seq].responseresults[responses].
              response_actions[action_cnt].events[parent_response_idx].event_prsnl_actions,5))
               action_prsnl_label = "", action_prsnl_info = "", proxy_prsnl_label = "",
               proxy_prsnl_info = "", request_prsnl_label = "", request_prsnl_info = ""
               IF ((((mar_detail_reply->orders[d.seq].responseresults[responses].response_actions[
               action_cnt].events[parent_response_idx].result_status_cd=ccharted)) OR ((
               mar_detail_reply->orders[d.seq].responseresults[responses].response_actions[action_cnt
               ].events[parent_response_idx].result_status_cd=cnotgiven)))
                AND (mar_detail_reply->orders[d.seq].responseresults[responses].response_actions[
               action_cnt].events[parent_response_idx].event_prsnl_actions[prsnl].action_type_cd=
               cperform))
                action_prsnl_label = concat(trim(i18n_sperformedby),": ")
               ELSEIF ((((mar_detail_reply->orders[d.seq].responseresults[responses].
               response_actions[action_cnt].events[parent_response_idx].result_status_cd=cmodified))
                OR ((mar_detail_reply->orders[d.seq].responseresults[responses].response_actions[
               action_cnt].events[parent_response_idx].result_status_cd=caltered)))
                AND (mar_detail_reply->orders[d.seq].responseresults[responses].response_actions[
               action_cnt].events[parent_response_idx].event_prsnl_actions[prsnl].action_type_cd=
               cchartmodify))
                action_prsnl_label = concat(trim(i18n_smodifiedby),": ")
               ELSEIF ((mar_detail_reply->orders[d.seq].responseresults[responses].response_actions[
               action_cnt].events[parent_response_idx].result_status_cd=cunchart)
                AND (mar_detail_reply->orders[d.seq].responseresults[responses].response_actions[
               action_cnt].events[parent_response_idx].event_prsnl_actions[prsnl].action_type_cd=
               cchartmodify))
                action_prsnl_label = concat(trim(i18n_sunchartedby),": ")
               ENDIF
               IF (action_prsnl_label != "")
                result_action_dt_tm = formatutcdatetime(mar_detail_reply->orders[d.seq].
                 responseresults[responses].response_actions[action_cnt].events[parent_response_idx].
                 event_prsnl_actions[prsnl].action_dt_tm,mar_detail_reply->orders[d.seq].
                 responseresults[responses].response_actions[action_cnt].events[parent_response_idx].
                 event_prsnl_actions[prsnl].action_tz,1), action_prsnl_info = concat(trim(
                  mar_detail_reply->orders[d.seq].responseresults[responses].response_actions[
                  action_cnt].events[parent_response_idx].event_prsnl_actions[prsnl].
                  action_prsnl_name)," ",trim(i18n_sat)," ",result_action_dt_tm)
                IF ((mar_detail_reply->orders[d.seq].responseresults[responses].response_actions[
                action_cnt].events[parent_response_idx].event_prsnl_actions[prsnl].proxy_prsnl_id >
                0.0))
                 proxy_prsnl_label = concat(trim(i18n_sproxy),": "), proxy_prsnl_info = trim(
                  mar_detail_reply->orders[d.seq].responseresults[responses].response_actions[
                  action_cnt].events[parent_response_idx].event_prsnl_actions[prsnl].proxy_prsnl_name
                  )
                ENDIF
                IF ((mar_detail_reply->orders[d.seq].responseresults[responses].response_actions[
                action_cnt].events[parent_response_idx].event_prsnl_actions[prsnl].request_prsnl_id
                 > 0.0))
                 request_prsnl_label = concat(trim(i18n_srequest),": "), request_prsnl_info = trim(
                  mar_detail_reply->orders[d.seq].responseresults[responses].response_actions[
                  action_cnt].events[parent_response_idx].event_prsnl_actions[prsnl].
                  request_prsnl_name)
                ENDIF
                IF (print_column_format=cschedprintformat)
                 IF (action_prsnl_info != "")
                  col 141, "{B}", action_prsnl_label,
                  "{ENDB}", action_prsnl_info, row + 1
                 ENDIF
                 IF (proxy_prsnl_info != "")
                  col 141, "{B}", proxy_prsnl_label,
                  "{ENDB}", proxy_prsnl_info, row + 1
                 ENDIF
                 IF (request_prsnl_info != "")
                  col 141, "{B}", request_prsnl_label,
                  "{ENDB}", request_prsnl_info, row + 1
                 ENDIF
                 IF ((mar_detail_reply->orders[d.seq].responseresults[responses].response_actions[
                 action_cnt].events[parent_response_idx].event_prsnl_actions[prsnl].action_comment
                  != ""))
                  col 141, "{B}", i18n_sactioncomment,
                  ":", note_text_in = fillstring(1000," "), note_text_in = mar_detail_reply->orders[d
                  .seq].responseresults[responses].response_actions[action_cnt].events[
                  parent_response_idx].event_prsnl_actions[prsnl].action_comment,
                  chars_per_line = 55, note_string = fillstring(55," "), col_start = 161,
                  prnt_note
                 ENDIF
                 IF ((mar_detail_reply->orders[d.seq].responseresults[responses].response_actions[
                 action_cnt].events[parent_response_idx].event_prsnl_actions[prsnl].request_comment
                  != "")
                  AND (mar_detail_reply->orders[d.seq].responseresults[responses].response_actions[
                 action_cnt].events[parent_response_idx].event_prsnl_actions[prsnl].request_comment
                  != mar_detail_reply->orders[d.seq].responseresults[responses].response_actions[
                 action_cnt].events[parent_response_idx].event_prsnl_actions[prsnl].action_comment))
                  col 161, "{B}", i18n_srequestcomment,
                  ":", note_text_in = fillstring(1000," "), note_text_in = mar_detail_reply->orders[d
                  .seq].responseresults[responses].response_actions[action_cnt].events[
                  parent_response_idx].event_prsnl_actions[prsnl].request_comment,
                  chars_per_line = 55, note_string = fillstring(55," "), col_start = 181,
                  prnt_note
                 ENDIF
                ELSE
                 IF (action_prsnl_info != "")
                  col 118, "{B}", action_prsnl_label,
                  "{ENDB}", action_prsnl_info, row + 1
                 ENDIF
                 IF (proxy_prsnl_info != "")
                  col 118, "{B}", proxy_prsnl_label,
                  "{ENDB}", proxy_prsnl_info, row + 1
                 ENDIF
                 IF (request_prsnl_info != "")
                  col 118, "{B}", request_prsnl_label,
                  "{ENDB}", request_prsnl_info, row + 1
                 ENDIF
                 IF ((mar_detail_reply->orders[d.seq].responseresults[responses].response_actions[
                 action_cnt].events[parent_response_idx].event_prsnl_actions[prsnl].action_comment
                  != ""))
                  col 118, "{B}", i18n_sactioncomment,
                  ":", note_text_in = fillstring(1000," "), note_text_in = mar_detail_reply->orders[d
                  .seq].responseresults[responses].response_actions[action_cnt].events[
                  parent_response_idx].event_prsnl_actions[prsnl].action_comment,
                  chars_per_line = 55, note_string = fillstring(55," "), col_start = 118,
                  prnt_note
                 ENDIF
                 IF ((mar_detail_reply->orders[d.seq].responseresults[responses].response_actions[
                 action_cnt].events[parent_response_idx].event_prsnl_actions[prsnl].request_comment
                  != "")
                  AND (mar_detail_reply->orders[d.seq].responseresults[responses].response_actions[
                 action_cnt].events[parent_response_idx].event_prsnl_actions[prsnl].request_comment
                  != mar_detail_reply->orders[d.seq].responseresults[responses].response_actions[
                 action_cnt].events[parent_response_idx].event_prsnl_actions[prsnl].action_comment))
                  col 118, "{B}", i18n_srequestcomment,
                  ":", note_text_in = fillstring(1000," "), note_text_in = mar_detail_reply->orders[d
                  .seq].responseresults[responses].response_actions[action_cnt].events[
                  parent_response_idx].event_prsnl_actions[prsnl].request_comment,
                  chars_per_line = 55, note_string = fillstring(55," "), col_start = 118,
                  prnt_note
                 ENDIF
                ENDIF
               ENDIF
             ENDFOR
            ENDIF
          ENDFOR
         ENDIF
       ENDFOR
      ENDIF
     ENDFOR
   ENDFOR
   row + 1
  FOOT REPORT
   IF (filteredordercount > 0)
    CALL echo(build("This is an incomplete print, based on the privileges of user:",reqinfo->updt_id)
    ), row + 3, col 52,
    "{B}", "*******************************************************************************", row + 1,
    col 52, "{B}", "****** ",
    i18n_sincompleteprintmsg, ":", reqinfo->updt_id,
    row + 1, col 52, "{B}",
    "*******************************************************************************", row + 1
   ENDIF
  WITH nocounter, maxcol = 500, maxrow = 80,
   dio = value(dio_output)
 ;end select
 SUBROUTINE canorderbeviewed(dcatalogcd,dactivitytypecd,dcatalogtypecd,dorderid)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE prividx = i4 WITH protect, noconstant(0)
   DECLARE num = i4 WITH protect, noconstant(0)
   DECLARE retval = i2 WITH protect, noconstant(0)
   IF (validate(request->privileges))
    SET prividx = locateval(num,1,size(request->privileges,5),cvieworder,request->privileges[num].
     privilege_cd)
    IF (prividx > 0)
     IF (size(request->privileges[prividx].default[1].exceptions,5)=0)
      IF ((request->privileges[prividx].default[1].granted_ind=0))
       CALL logmessageinreply(2,build("Filtered order: ",dorderid))
      ENDIF
      RETURN(request->privileges[prividx].default[1].granted_ind)
     ELSE
      SET retval = doesexceptionexist(dcatalogcd,dactivitytypecd,dcatalogtypecd,prividx)
      IF (retval)
       IF ((request->privileges[prividx].default[1].granted_ind > 0))
        CALL echo("---->Will not display")
        SET filteredordercount = (filteredordercount+ 1)
        CALL logmessageinreply(2,build("Filtered order: ",dorderid))
        RETURN(0)
       ELSE
        CALL echo("---->Will display")
        RETURN(1)
       ENDIF
      ELSE
       CALL echo("should return granted_ind")
       IF ((request->privileges[prividx].default[1].granted_ind > 0))
        CALL echo(build("*********Did Not Find an exception for order id--->",dorderid,
          "-----Will display"))
       ELSE
        SET filteredordercount = (filteredordercount+ 1)
        CALL echo(build("*********Did Not Find an exception for order id--->",dorderid,
          "-----Will NOT display"))
        CALL logmessageinreply(2,build("Filtered order: ",dorderid))
       ENDIF
       RETURN(request->privileges[prividx].default[1].granted_ind)
      ENDIF
     ENDIF
    ELSE
     CALL echo("Order Inquiry priv not found, display everything")
     RETURN(1)
    ENDIF
   ELSE
    CALL echo("privileges are not in the request, display everything")
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE doesexceptionexist(dcatalogcd,dactivitytypecd,dcatalogtypecd,iprividx)
   DECLARE num = i4 WITH protect, noconstant(0)
   FOR (num = 1 TO size(request->privileges[prividx].default[1].exceptions,5))
     IF ((request->privileges[prividx].default[1].exceptions[num].type_cd=cactivitytype))
      IF ((request->privileges[prividx].default[1].exceptions[num].id=dactivitytypecd))
       CALL echo(build("*********FOUND AN EXCEPTION for activity type code--->",dactivitytypecd))
       RETURN(1)
      ENDIF
     ENDIF
     IF ((request->privileges[prividx].default[1].exceptions[num].type_cd=ccatalogtype))
      IF ((request->privileges[prividx].default[1].exceptions[num].id=dcatalogtypecd))
       CALL echo(build("*********FOUND AN EXCEPTION for catalog type code--->",dcatalogtypecd))
       RETURN(1)
      ENDIF
     ENDIF
     IF ((request->privileges[prividx].default[1].exceptions[num].type_cd=corderables))
      IF ((request->privileges[prividx].default[1].exceptions[num].id=dcatalogcd))
       CALL echo(build("*********FOUND AN EXCEPTION for catalog code--->",dcatalogcd))
       RETURN(1)
      ENDIF
     ENDIF
   ENDFOR
   RETURN(0)
 END ;Subroutine
 SUBROUTINE storeresponseevents(iorderidx,iresponseidx,iresponseactionidx,ieventidx)
   DECLARE ieventcnt = i4 WITH protect, noconstant(0)
   DECLARE responsecomment = i4 WITH protect, noconstant(0)
   DECLARE idummyval = i2 WITH protect, noconstant(0)
   SET response_data_cnt = size(response_print_data->text,5)
   IF (iorderidx > 0
    AND iorderidx <= size(mar_detail_reply->orders,5))
    IF (iresponseidx > 0
     AND iresponseidx <= size(mar_detail_reply->orders[iorderidx].responseresults,5))
     IF (iresponseactionidx > 0
      AND iresponseactionidx <= size(mar_detail_reply->orders[iorderidx].responseresults[iresponseidx
      ].response_actions,5))
      IF (ieventidx > 0
       AND ieventidx <= size(mar_detail_reply->orders[iorderidx].responseresults[iresponseidx].
       response_actions[iresponseactionidx].events,5))
       SET response_data_cnt = (response_data_cnt+ 1)
       SET stat = alterlist(response_print_data->text,response_data_cnt)
       IF ((mar_detail_reply->orders[iorderidx].responseresults[iresponseidx].response_actions[
       iresponseactionidx].events[ieventidx].event_cd=cdcpgeneric))
        SET response_print_data->text[response_data_cnt].response_info = concat("{B}",trim(
          mar_detail_reply->orders[iorderidx].responseresults[iresponseidx].response_actions[
          iresponseactionidx].events[ieventidx].event_title_text))
       ELSEIF ((mar_detail_reply->orders[iorderidx].responseresults[iresponseidx].response_actions[
       iresponseactionidx].events[ieventidx].parent_event_id != mar_detail_reply->orders[iorderidx].
       responseresults[iresponseidx].response_actions[iresponseactionidx].events[ieventidx].event_id)
        AND (mar_detail_reply->orders[iorderidx].responseresults[iresponseidx].response_actions[
       iresponseactionidx].events[ieventidx].result_status_cd=cnotgiven))
        SET response_print_data->text[response_data_cnt].response_info = concat("{B}",trim(
          mar_detail_reply->orders[iorderidx].responseresults[iresponseidx].response_actions[
          iresponseactionidx].events[ieventidx].event_tag))
       ELSEIF ((mar_detail_reply->orders[iorderidx].responseresults[iresponseidx].response_actions[
       iresponseactionidx].events[ieventidx].result_val != ""))
        IF ((mar_detail_reply->orders[iorderidx].responseresults[iresponseidx].response_actions[
        iresponseactionidx].events[ieventidx].result_status_cd=cunchart))
         SET response_print_data->text[response_data_cnt].response_info = concat("{B}",trim(
           uar_get_code_display(mar_detail_reply->orders[iorderidx].responseresults[iresponseidx].
            response_actions[iresponseactionidx].events[ieventidx].event_cd)),":{ENDB} ",
          i18n_suncharted)
        ELSE
         SET dta_result_val = ""
         IF ((mar_detail_reply->orders[iorderidx].responseresults[iresponseidx].response_actions[
         iresponseactionidx].events[ieventidx].event_class_cd=cnum))
          SET dta_result_val = nullterm(trim(format(mar_detail_reply->orders[iorderidx].
             responseresults[iresponseidx].response_actions[iresponseactionidx].events[ieventidx].
             result_val,"####################;LIt(1)")))
         ELSE
          SET dta_result_val = mar_detail_reply->orders[iorderidx].responseresults[iresponseidx].
          response_actions[iresponseactionidx].events[ieventidx].result_val
         ENDIF
         SET response_print_data->text[response_data_cnt].response_info = concat("{B}",trim(
           uar_get_code_display(mar_detail_reply->orders[iorderidx].responseresults[iresponseidx].
            response_actions[iresponseactionidx].events[ieventidx].event_cd)),":{ENDB} ",trim(
           dta_result_val)," ",
          trim(uar_get_code_display(mar_detail_reply->orders[iorderidx].responseresults[iresponseidx]
            .response_actions[iresponseactionidx].events[ieventidx].result_unit_cd)))
        ENDIF
       ELSE
        SET response_print_data->text[response_data_cnt].response_info = concat("{B}",trim(
          uar_get_code_display(mar_detail_reply->orders[iorderidx].responseresults[iresponseidx].
           response_actions[iresponseactionidx].events[ieventidx].event_cd)))
       ENDIF
       IF ((mar_detail_reply->orders[iorderidx].responseresults[iresponseidx].response_actions[
       iresponseactionidx].events[ieventidx].parent_event_id=mar_detail_reply->orders[iorderidx].
       responseresults[iresponseidx].response_actions[iresponseactionidx].events[ieventidx].event_id)
       )
        IF (print_column_format=cschedprintformat)
         SET response_print_data->text[response_data_cnt].chars_per_line = 55
         SET response_print_data->text[response_data_cnt].note_string = fillstring(80," ")
         SET response_print_data->text[response_data_cnt].col_start = 96
        ELSE
         SET response_print_data->text[response_data_cnt].chars_per_line = 80
         SET response_print_data->text[response_data_cnt].note_string = fillstring(80," ")
         SET response_print_data->text[response_data_cnt].col_start = 75
        ENDIF
       ELSEIF ((mar_detail_reply->orders[iorderidx].responseresults[iresponseidx].response_actions[
       iresponseactionidx].events[ieventidx].event_cd=cdcpgeneric))
        IF (print_column_format=cschedprintformat)
         SET response_print_data->text[response_data_cnt].chars_per_line = 65
         SET response_print_data->text[response_data_cnt].note_string = fillstring(65," ")
         SET response_print_data->text[response_data_cnt].col_start = 132
        ELSE
         SET response_print_data->text[response_data_cnt].chars_per_line = 65
         SET response_print_data->text[response_data_cnt].note_string = fillstring(65," ")
         SET response_print_data->text[response_data_cnt].col_start = 110
        ENDIF
       ELSEIF ((mar_detail_reply->orders[iorderidx].responseresults[iresponseidx].response_actions[
       iresponseactionidx].events[ieventidx].result_status_cd=cnotgiven))
        IF (print_column_format=cschedprintformat)
         SET response_print_data->text[response_data_cnt].chars_per_line = 65
         SET response_print_data->text[response_data_cnt].note_string = fillstring(65," ")
         SET response_print_data->text[response_data_cnt].col_start = 132
        ELSE
         SET response_print_data->text[response_data_cnt].chars_per_line = 65
         SET response_print_data->text[response_data_cnt].note_string = fillstring(65," ")
         SET response_print_data->text[response_data_cnt].col_start = 108
        ENDIF
       ELSE
        IF (print_column_format=cschedprintformat)
         SET response_print_data->text[response_data_cnt].chars_per_line = 65
         SET response_print_data->text[response_data_cnt].note_string = fillstring(65," ")
         SET response_print_data->text[response_data_cnt].col_start = 137
        ELSE
         SET response_print_data->text[response_data_cnt].chars_per_line = 65
         SET response_print_data->text[response_data_cnt].note_string = fillstring(65," ")
         SET response_print_data->text[response_data_cnt].col_start = 116
        ENDIF
       ENDIF
       FOR (responsecomment = 1 TO size(mar_detail_reply->orders[iorderidx].responseresults[
        iresponseidx].response_actions[iresponseactionidx].events[ieventidx].result_comments,5))
         IF ((mar_detail_reply->orders[iorderidx].responseresults[iresponseidx].response_actions[
         iresponseactionidx].events[ieventidx].result_comments[responsecomment].event_id=
         mar_detail_reply->orders[iorderidx].responseresults[iresponseidx].response_actions[
         iresponseactionidx].events[ieventidx].event_id)
          AND (mar_detail_reply->orders[iorderidx].responseresults[iresponseidx].response_actions[
         iresponseactionidx].events[ieventidx].result_comments[responsecomment].valid_from_dt_tm=
         mar_detail_reply->orders[iorderidx].responseresults[iresponseidx].response_actions[
         iresponseactionidx].events[ieventidx].valid_from_dt_tm))
          SET response_comment = ""
          SET response_comment = trim(mar_detail_reply->orders[iorderidx].responseresults[
           iresponseidx].response_actions[iresponseactionidx].events[ieventidx].result_comments[
           responsecomment].comment_text)
          IF (response_comment != "")
           SET response_data_cnt = (response_data_cnt+ 1)
           SET stat = alterlist(response_print_data->text,response_data_cnt)
           SET response_print_data->text[response_data_cnt].comment_type = concat(trim(
             uar_get_code_display(mar_detail_reply->orders[iorderidx].responseresults[iresponseidx].
              response_actions[iresponseactionidx].events[ieventidx].result_comments[responsecomment]
              .note_type_cd)),":")
           SET response_print_data->text[response_data_cnt].response_info = response_comment
           SET typelength = 0
           SET typelength = size(response_print_data->text[response_data_cnt].comment_type,1)
           IF ((response_print_data->text[response_data_cnt].response_info != ""))
            IF (print_column_format=cschedprintformat)
             SET response_print_data->text[response_data_cnt].comment_col = 140
             SET response_print_data->text[response_data_cnt].chars_per_line = 55
             SET response_print_data->text[response_data_cnt].note_string = fillstring(55," ")
             SET response_print_data->text[response_data_cnt].col_start = (144+ typelength)
            ELSE
             SET response_print_data->text[response_data_cnt].comment_col = 120
             SET response_print_data->text[response_data_cnt].chars_per_line = 55
             SET response_print_data->text[response_data_cnt].note_string = fillstring(55," ")
             SET response_print_data->text[response_data_cnt].col_start = (124+ typelength)
            ENDIF
           ENDIF
          ENDIF
         ENDIF
       ENDFOR
       FOR (ieventcnt = 1 TO size(mar_detail_reply->orders[iorderidx].responseresults[iresponseidx].
        response_actions[iresponseactionidx].events,5))
         IF (ieventcnt != ieventidx
          AND (mar_detail_reply->orders[iorderidx].responseresults[iresponseidx].response_actions[
         iresponseactionidx].events[ieventidx].event_id=mar_detail_reply->orders[iorderidx].
         responseresults[iresponseidx].response_actions[iresponseactionidx].events[ieventcnt].
         parent_event_id))
          SET idummyval = storeresponseevents(iorderidx,iresponseidx,iresponseactionidx,ieventcnt)
         ENDIF
       ENDFOR
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   RETURN(idummyval)
 END ;Subroutine
 SUBROUTINE logmessageinreply(iloglevel,slogmessage)
   DECLARE count = i2 WITH protect, noconstant(0)
   SET count = size(reply->log_info,5)
   SET count = (count+ 1)
   SET stat = alterlist(reply->log_info,count)
   SET reply->log_info[count].log_level = iloglevel
   SET reply->log_info[count].log_message = slogmessage
 END ;Subroutine
#exit_program
 DECLARE last_mod = c12 WITH private, noconstant(fillstring(12," "))
 IF (filteredordercount=size(mar_detail_reply->orders,5))
  SET reply->status_data.status = "Z"
 ENDIF
 SET last_mod = "037 10/27/15"
 IF (debug_ind=1)
  CALL echo(build("DCP_RPT_PRINT_EMAR Last Mod: ",last_mod))
 ENDIF
 SET modify = nopredeclare
END GO
