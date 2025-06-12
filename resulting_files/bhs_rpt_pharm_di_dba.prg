CREATE PROGRAM bhs_rpt_pharm_di:dba
 PROMPT
  "Enter MINE/CRT/printer/file:" = "Mine",
  "Search by Drug or Therapeutic Class:" = "",
  "Enter the search string (* for all):" = "*",
  "Enter the facility (* for all):" = "",
  "Enter the START date range (mmddyyyy hhmm) FROM :" = "SYSDATE",
  "(mmddyyyy hhmm)  TO :" = "SYSDATE",
  "Select status(s) for report:" = "",
  "Include Pyxis Orders:" = ""
  WITH outdev, searchtype, searchstring,
  facility, startdate, stopdate,
  status, pyxis
 DECLARE mf_dose_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,"STRENGTHDOSE"))
 DECLARE mf_dose_unit_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "STRENGTHDOSEUNIT"))
 DECLARE mf_route_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "ROUTEOFADMINISTRATION"))
 DECLARE mf_freq_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,"FREQUENCY"))
 DECLARE mf_vol_dose_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,"VOLUMEDOSE"))
 DECLARE mf_vol_dose_unit_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "VOLUMEDOSEUNIT"))
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
 DECLARE itemcnt = i4 WITH protect, noconstant(0)
 DECLARE medcnt = i4 WITH protect, noconstant(0)
 DECLARE nindex = i4 WITH protect, noconstant(0)
 DECLARE nactual_size = i4 WITH protect, noconstant(0)
 DECLARE nexpand_size = i2 WITH protect, constant(50)
 DECLARE nexpand_total = i4 WITH protect, noconstant(0)
 DECLARE nexpand_start = i4 WITH protect, noconstant(0)
 DECLARE nexpand_stop = i4 WITH protect, noconstant(0)
 DECLARE nexpand = i2 WITH protect, noconstant(0)
 DECLARE ball = i2 WITH protect, noconstant(0)
 DECLARE bactive = i2 WITH protect, noconstant(0)
 DECLARE bdc = i2 WITH protect, noconstant(0)
 DECLARE bcancel = i2 WITH protect, noconstant(0)
 DECLARE sstatus = vc WITH protect, noconstant(" ")
 DECLARE start_dt = q8
 DECLARE nstart_tm = i2 WITH protect, noconstant(0)
 DECLARE stop_dt = q8
 DECLARE nstop_tm = i2 WITH protect, noconstant(0)
 DECLARE ssearch_string = vc WITH protect, noconstant(" ")
 DECLARE dose = vc WITH protect, noconstant(" ")
 DECLARE disp_str = vc WITH protect, noconstant(" ")
 DECLARE disp_vol = vc WITH protect, noconstant(" ")
 DECLARE work_dt = q8
 DECLARE bjustprinted = i2 WITH protect, noconstant(0)
 DECLARE bdone_with_encntr = i2 WITH protect, noconstant(0)
 DECLARE bprint_patient_info = i2 WITH protect, noconstant(0)
 DECLARE nfacilitycounter = i2 WITH protect, noconstant(0)
 DECLARE new_model_check = i2 WITH protect, noconstant(0)
 DECLARE csystem = f8 WITH protect, constant(uar_get_code_by("MEANING",4062,"SYSTEM"))
 DECLARE csyspkgtyp = f8 WITH protect, constant(uar_get_code_by("MEANING",4062,"SYSPKGTYP"))
 DECLARE cinpatient = f8 WITH protect, constant(uar_get_code_by("MEANING",4500,"INPATIENT"))
 DECLARE cmeddef = f8 WITH protect, constant(uar_get_code_by("MEANING",11001,"MED_DEF"))
 DECLARE activity_type = f8 WITH protect, constant(uar_get_code_by("MEANING",106,"PHARMACY"))
 DECLARE ccatalogcd = f8 WITH protect, constant(uar_get_code_by("MEANING",6000,"PHARMACY"))
 DECLARE cfinnbr = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE cgeneric = f8 WITH protect, constant(uar_get_code_by("MEANING",11000,"GENERIC_NAME"))
 DECLARE clabel = f8 WITH protect, constant(uar_get_code_by("MEANING",11000,"DESC"))
 DECLARE cordered2 = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"ORDERED"))
 DECLARE cordered = f8 WITH protect, constant(uar_get_code_by("MEANING",14281,"ORDERED"))
 DECLARE ccanceled = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"CANCELED"))
 DECLARE csuspended = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"SUSPENDED"))
 DECLARE csoft = f8 WITH protect, constant(uar_get_code_by("MEANING",4009,"SOFT"))
 DECLARE cfuture = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"FUTURE"))
 DECLARE cdiscontinued = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"DISCONTINUED"))
 DECLARE ccompleted = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"COMPLETED"))
 DECLARE cvoided = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"VOIDED"))
 DECLARE cdeleted = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"DELETED"))
 DECLARE conhold = f8 WITH protect, constant(uar_get_code_by("MEANING",14281,"ONHOLD"))
 DECLARE cpending = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"PENDING"))
 DECLARE cincomplete = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"INCOMPLETE"))
 DECLARE ctrans = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"TRANS/CANCEL"))
 DECLARE cvoid = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"VOIDEDWRSLT"))
 DECLARE cformat = c50 WITH protect, constant(fillstring(50,"#"))
 DECLARE nerrorind = i2 WITH protect, noconstant(0)
 SET start_dt = cnvtdate(trim(substring(1,8, $STARTDATE)))
 SET nstart_tm = cnvtint(trim(substring(10,4, $STARTDATE)))
 SET stop_dt = cnvtdate(trim(substring(1,8, $STOPDATE)))
 SET nstop_tm = cnvtint(trim(substring(10,4, $STOPDATE)))
 SET ssearch_string = trim( $SEARCHSTRING,4)
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
 DECLARE cmlhr = f8 WITH protect, constant(uar_get_code_by("MEANING",54,"ML/HR"))
 DECLARE smlhr = vc WITH protect, noconstant("")
 SET smlhr = uar_get_code_display(cmlhr)
 DECLARE i18nhandle = i4 WITH noconstant(0)
 DECLARE h = i4 WITH noconstant(0)
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 DECLARE stitle = vc WITH protect, noconstant("")
 SET stitle = substring(1,50,uar_i18ngetmessage(i18nhandle,"titleKey","DRUG INQUIRY REPORT"))
 DECLARE sall_str = vc WITH protect, noconstant("")
 SET sall_str = uar_i18ngetmessage(i18nhandle,"allStrKey","ALL")
 DECLARE sactive_suspend = vc WITH protect, noconstant("")
 SET sactive_suspend = uar_i18ngetmessage(i18nhandle,"activeSuspendKey"," Active/Suspend")
 DECLARE sdc_completed = vc WITH protect, noconstant("")
 SET sdc_completed = uar_i18ngetmessage(i18nhandle,"DCCompletedKey"," Discontinue/Completed")
 DECLARE sfacility = vc WITH protect, noconstant("")
 SET sfacility = substring(1,20,uar_i18ngetmessage(i18nhandle,"facilityKey","Facility"))
 DECLARE scanceled_voided = vc WITH protect, noconstant("")
 SET scanceled_voided = uar_i18ngetmessage(i18nhandle,"canceledvoidedKey"," Canceled/Voided")
 DECLARE sall_ind = vc WITH protect, noconstant("")
 SET sall_ind = uar_i18ngetmessage(i18nhandle,"allindKey","Setting all ind")
 DECLARE cact_ind = vc WITH protect, noconstant("")
 SET cact_ind = uar_i18ngetmessage(i18nhandle,"actindKey","Setting active ind")
 DECLARE sdc_ind = vc WITH protect, noconstant("")
 SET sdc_ind = uar_i18ngetmessage(i18nhandle,"dcindKey","Setting dc ind")
 DECLARE scancel_ind = vc WITH protect, noconstant("")
 SET scancel_ind = uar_i18ngetmessage(i18nhandle,"cancelindKey","Setting cancel ind")
 DECLARE sagainst = vc WITH protect, noconstant("")
 SET sagainst = uar_i18ngetmessage(i18nhandle,"againstKey","against")
 DECLARE sprg_list_sizee = vc WITH protect, noconstant("")
 SET sprg_list_size = uar_i18ngetmessage(i18nhandle,"prglistsizeKey","Size of facility list in prg--"
  )
 DECLARE sfac_list_size = vc WITH protect, noconstant("")
 SET sfac_list_size = uar_i18ngetmessage(i18nhandle,"faclistsizeKey","Facility list size")
 DECLARE sno_access = vc WITH protect, noconstant("")
 SET sno_access = uar_i18ngetmessage(i18nhandle,"noaccessKey",
  "*** User does not have access to selected facility")
 DECLARE snew_model = vc WITH protect, noconstant("")
 SET snew_model = uar_i18ngetmessage(i18nhandle,"newmodelKey","NEW MODEL")
 DECLARE sitem_ids = vc WITH protect, noconstant("")
 SET sitem_ids = uar_i18ngetmessage(i18nhandle,"itemidsKey","Getting item ids")
 DECLARE sget_thera_class = vc WITH protect, noconstant("")
 SET sget_thera_class = uar_i18ngetmessage(i18nhandle,"gettheraclassKey",
  "Getting therapeutic class info")
 DECLARE sold_model = vc WITH protect, noconstant("")
 SET sold_model = uar_i18ngetmessage(i18nhandle,"oldmodelKey","Old Model")
 DECLARE sno_orders_ret = vc WITH protect, noconstant("")
 SET sno_orders_ret = uar_i18ngetmessage(i18nhandle,"ordersretKey","No Orders Retrieved")
 DECLARE sexceeded_list = vc WITH protect, noconstant("")
 SET sexceeded_list = uar_i18ngetmessage(i18nhandle,"exceededlistKey",
  "Item list size exceeds the maximum of 32767....exiting script.")
 DECLARE sget_ordid = vc WITH protect, noconstant("")
 SET sget_ordid = uar_i18ngetmessage(i18nhandle,"getordidkey","Getting order ids")
 DECLARE sdetail_orderid = vc WITH protect, noconstant("")
 SET sdetail_orderid = uar_i18ngetmessage(i18nhandle,"detailorderidkey","detail order id")
 DECLARE seloc = vc WITH protect, noconstant("")
 SET seloc = uar_i18ngetmessage(i18nhandle,"elockey","e loc fac")
 DECLARE sord_id = vc WITH protect, noconstant("")
 SET sord_id = uar_i18ngetmessage(i18nhandle,"ordidkey","order id")
 DECLARE cmain_rep = vc WITH protect, noconstant("")
 SET cmain_rep = uar_i18ngetmessage(i18nhandle,"mainrepkey","main report")
 DECLARE sord_list_size = vc WITH protect, noconstant("")
 SET sord_list_size = uar_i18ngetmessage(i18nhandle,"ordlistsizekey","Order list size")
 DECLARE sjoin = vc WITH protect, noconstant("")
 SET sjoin = uar_i18ngetmessage(i18nhandle,"joinkey","entering main big join")
 DECLARE sencntr = vc WITH protect, noconstant("")
 SET sencntr = uar_i18ngetmessage(i18nhandle,"encntrkey","encntr")
 DECLARE sid = vc WITH protect, noconstant("")
 SET sid = uar_i18ngetmessage(i18nhandle,"idkey","id")
 DECLARE shead = vc WITH protect, noconstant("")
 SET shead = uar_i18ngetmessage(i18nhandle,"headkey","head")
 DECLARE spage = vc WITH protect, noconstant("")
 SET spage = substring(1,30,uar_i18ngetmessage(i18nhandle,"pagekey","Page:"))
 DECLARE srun_date = vc WITH protect, noconstant("")
 SET srun_date = substring(1,20,uar_i18ngetmessage(i18nhandle,"rundatekey","Run Date:"))
 DECLARE stherapeutic_lower = vc WITH protect, noconstant("")
 SET stherapeutic_lower = substring(1,30,uar_i18ngetmessage(i18nhandle,"therapeuticlowerkey",
   "Therapeutic Class"))
 DECLARE sformulary_item = vc WITH protect, noconstant("")
 SET sformulary_item = substring(1,30,uar_i18ngetmessage(i18nhandle,"formularyitemkey",
   "Formulary Item"))
 DECLARE sall_selection = vc WITH protect, noconstant("")
 SET sall_selection = uar_i18ngetmessage(i18nhandle,"allselectionkey","ALL")
 DECLARE sdate_range = vc WITH protect, noconstant("")
 SET sdate_range = substring(1,30,uar_i18ngetmessage(i18nhandle,"daterangekey","Date Range"))
 DECLARE slocation = vc WITH protect, noconstant("")
 SET slocation = substring(1,20,uar_i18ngetmessage(i18nhandle,"locationkey","Location:"))
 DECLARE sdrug_stat = vc WITH protect, noconstant("")
 SET sdrug_stat = substring(1,30,uar_i18ngetmessage(i18nhandle,"drugstatkey","Drug Status"))
 DECLARE spatient_location = vc WITH protect, noconstant("")
 SET spatient_location = substring(1,30,uar_i18ngetmessage(i18nhandle,"patientlocationkey",
   "Room-Bed/Patient:"))
 DECLARE smedication = vc WITH protect, noconstant("")
 SET smedication = substring(1,30,uar_i18ngetmessage(i18nhandle,"medicationkey","Medication"))
 DECLARE sstatus_str = vc WITH protect, noconstant("")
 SET sstatus_str = substring(1,21,uar_i18ngetmessage(i18nhandle,"statuskey","Status"))
 DECLARE sstart_dttm = vc WITH protect, noconstant("")
 SET sstart_dttm = substring(1,25,uar_i18ngetmessage(i18nhandle,"startdttmkey","Start Dt/Tm"))
 DECLARE sstop_dttm = vc WITH protect, noconstant("")
 SET sstop_dttm = substring(1,24,uar_i18ngetmessage(i18nhandle,"stopdttmkey","Stop Dt/Tm"))
 DECLARE sorder_num = vc WITH protect, noconstant("")
 SET sorder_num = substring(1,8,uar_i18ngetmessage(i18nhandle,"ordernumkey","Order#"))
 DECLARE shead_facility = vc WITH protect, noconstant("")
 SET shead_facility = uar_i18ngetmessage(i18nhandle,"headfacilitykey","Head facility")
 DECLARE cprinted = vc WITH protect, noconstant("")
 SET cprinted = uar_i18ngetmessage(i18nhandle,"printkey","just printed")
 DECLARE shead_location = vc WITH protect, noconstant("")
 SET shead_location = uar_i18ngetmessage(i18nhandle,"headlocationkey","Head location")
 DECLARE shead_encntr = vc WITH protect, noconstant("")
 SET shead_encntr = uar_i18ngetmessage(i18nhandle,"headencntrkey","Head encntr")
 DECLARE sdesc = vc WITH protect, noconstant("")
 SET sdesc = uar_i18ngetmessage(i18nhandle,"desckey","desc")
 DECLARE sfin = vc WITH protect, noconstant("")
 SET sfin = uar_i18ngetmessage(i18nhandle,"FINkey","FIN#")
 DECLARE sactive = vc WITH protect, noconstant("")
 SET sactive = substring(1,21,uar_i18ngetmessage(i18nhandle,"activekey","Active"))
 DECLARE ssuspended_str = vc WITH protect, noconstant("")
 SET ssuspended_str = substring(1,21,uar_i18ngetmessage(i18nhandle,"suspendedkey","Suspended"))
 DECLARE sunknown_status = vc WITH protect, noconstant("")
 SET sunknown_status = substring(1,21,uar_i18ngetmessage(i18nhandle,"unknownkey","Unknown Status"))
 DECLARE sprn = vc WITH protect, noconstant("")
 SET sprn = uar_i18ngetmessage(i18nhandle,"prnkey","PRN")
 DECLARE sreplace_every = vc WITH protect, noconstant("")
 SET sreplace_every = uar_i18ngetmessage(i18nhandle,"replaceeverykey","Replace Every:")
 DECLARE stitrate_str = vc WITH protect, noconstant("")
 SET stitrate_str = uar_i18ngetmessage(i18nhandle,"titratekey","TITRATE")
 DECLARE srate_str = vc WITH protect, noconstant("")
 SET srate_str = uar_i18ngetmessage(i18nhandle,"titratekey","Rate:")
 DECLARE sroute_str = vc WITH protect, noconstant("")
 SET sroute_str = uar_i18ngetmessage(i18nhandle,"routekey","Route:")
 DECLARE sinfuse_ove_str = vc WITH protect, noconstant("")
 SET sinfuse_ove_str = uar_i18ngetmessage(i18nhandle,"infuseoverkey","Infuse Over:")
 DECLARE sfoot_encntr = vc WITH protect, noconstant("")
 SET sfoot_encntr = uar_i18ngetmessage(i18nhandle,"footencntrkey","Foot encntr")
 DECLARE sfoot_report = vc WITH protect, noconstant("")
 SET sfoot_report = uar_i18ngetmessage(i18nhandle,"footreportkey","Foot Report")
 DECLARE sno_records = vc WITH protect, noconstant("")
 SET sno_records = uar_i18ngetmessage(i18nhandle,"norecordkey","No Records Found")
 DECLARE send_report = vc WITH protect, noconstant("")
 SET send_report = uar_i18ngetmessage(i18nhandle,"endreportkey","End of Report")
 DECLARE sno_qualify = vc WITH protect, noconstant("")
 SET sno_qualify = uar_i18ngetmessage(i18nhandle,"noqualifykey","No Qualifications")
 CALL echo(build(cfacility," ==========", $FACILITY))
 IF (("ALL"= $STATUS))
  SET ball = 1
  SET sstatus = sall_str
  CALL echo(sall_ind)
 ENDIF
 IF (("Active/Suspend"= $STATUS))
  SET bactive = 1
  SET sstatus = concat(trim(sstatus),sactive_suspend)
  CALL echo(cact_ind)
 ENDIF
 IF (("Discontinue/Completed"= $STATUS))
  SET bdc = 1
  SET sstatus = concat(trim(sstatus),sdc_completed)
  CALL echo(sdc_ind)
 ENDIF
 IF (("Canceled/Voided"= $STATUS))
  SET bcancel = 1
  SET sstatus = concat(trim(sstatus)," sCANCELED_VOIDED")
  CALL echo(scancel_ind)
 ENDIF
 CALL echo(build(sstatus_str," ==",sstatus))
 IF ( NOT (validate(reply,0)))
  CALL echo(crecord_struct)
  RECORD reply(
    1 status_data
      2 status = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 EXECUTE rx_get_facs_for_prsnl_rr_incl  WITH replace("REQUEST","PRSNL_FACS_REQ"), replace("REPLY",
  "PRSNL_FACS_REPLY")
 SET stat = alterlist(prsnl_facs_req->qual,1)
 CALL echo(build("Reqinfo->updt_id --",reqinfo->updt_id))
 CALL echo(build("curuser --",curuser))
 SET prsnl_facs_req->qual[1].username = trim(curuser)
 SET prsnl_facs_req->qual[1].person_id = reqinfo->updt_id
 EXECUTE rx_get_facs_for_prsnl  WITH replace("REQUEST","PRSNL_FACS_REQ"), replace("REPLY",
  "PRSNL_FACS_REPLY")
 CALL echo(build(sprg_list_size,size(prsnl_facs_reply->qual[1].facility_list,5)))
 FREE RECORD facility_list
 RECORD facility_list(
   1 qual[*]
     2 facility_cd = f8
 )
 SET stat = alterlist(facility_list->qual,value(size(prsnl_facs_reply->qual[1].facility_list,5)))
 FOR (x = 1 TO size(prsnl_facs_reply->qual[1].facility_list,5))
   CALL echo(build(ccheck_facility," --",trim(format(prsnl_facs_reply->qual[1].facility_list[x].
       facility_cd,cformat),3)))
   CALL echo(build(sagainst," --", $FACILITY))
   IF ((trim(format(prsnl_facs_reply->qual[1].facility_list[x].facility_cd,cformat),3)= $FACILITY))
    SET nfacilitycounter = (nfacilitycounter+ 1)
    SET facility_list->qual[nfacilitycounter].facility_cd = prsnl_facs_reply->qual[1].facility_list[x
    ].facility_cd
   ENDIF
 ENDFOR
 SET stat = alterlist(facility_list->qual,nfacilitycounter)
 CALL echo(build(sfac_list_size," --",value(size(facility_list->qual,5))))
 IF (size(facility_list->qual,5)=0)
  CALL echo(build(sno_access," ***"))
  GO TO exit_script
 ENDIF
 SET count = 0
 SET items = 0
 SELECT INTO "nl:"
  dmp.pref_nbr
  FROM dm_prefs dmp
  WHERE dmp.application_nbr=300000
   AND dmp.person_id=0
   AND dmp.pref_domain="PHARMNET-INPATIENT"
   AND dmp.pref_section="FRMLRYMGMT"
   AND dmp.pref_name="NEW MODEL"
  DETAIL
   IF (dmp.pref_nbr=1)
    new_model_check = 1
   ENDIF
  WITH nocounter
 ;end select
 RECORD errors(
   1 err_cnt = i4
   1 err[*]
     2 err_code = i4
     2 err_msg = vc
 )
 SET errcode = 1
 SET errmsg = fillstring(132," ")
 SET errcnt = 0
 SET count1 = 0
 SET error = script_failure
 DECLARE med_cnt = i4
 DECLARE ord_cnt = i4
 SET firsttime = 1
 SET qualified = 0
 SET fin_nbr = fillstring(30," ")
 SET i = 0
 SET first_real = 1
 RECORD internal(
   1 select_desc = c30
   1 begin_dt_tm = dq8
   1 end_dt_tm = dq8
   1 output_device_s = c30
   1 orderid = f8
   1 personid = f8
   1 encntrid = f8
   1 alt_sel_cat_id = f8
   1 item_id = f8
 )
 SET internal->begin_dt_tm = cnvtdatetime(start_dt,nstart_tm)
 SET internal->end_dt_tm = cnvtdatetime(stop_dt,nstop_tm)
 RECORD orderrec(
   1 qual[*]
     2 item_id = f8
     2 synonym_id = f8
   1 orderlist[*]
     2 sort_generic_name = vc
     2 sort_label_desc = vc
     2 s_hna_mnemonic = vc
     2 s_dose = vc
     2 s_dose_unit = vc
     2 s_route = vc
     2 s_freq = vc
     2 orderid = f8
     2 deptmiscline = c255
     2 name = c30
     2 med_rec = c30
     2 fin_nbr = c30
     2 projected_stop_dt_tm = dq8
     2 projected_stop_tz = i4
     2 current_start_dt_tm = dq8
     2 current_start_tz = i4
     2 encntr_id = f8
     2 loc_s = c30
     2 loc_room_s = c10
     2 loc_bed_s = c10
     2 facility = c30
     2 order_status = f8
     2 all_unverified_ind = i2
     2 qualified = c1
     2 generic_name = vc
     2 actionlist[*]
       3 actionsequence = i4
       3 actiontypecd = f8
       3 communicationtypecd = f8
       3 orderproviderid = f8
       3 orderdttm = dq8
       3 ordertz = i4
       3 contributorsystemcd = f8
       3 orderlocncd = f8
       3 actionpersonnelid = f8
       3 effectivedttm = dq8
       3 effectivetz = i4
       3 actiondttm = dq8
       3 actiontz = i4
       3 needsverifyflag = i2
       3 deptstatuscd = f8
       3 actionrejectedind = i2
       3 detaillist[*]
         4 orderid = f8
         4 actionsequence = i4
         4 detailsequence = i4
         4 oefieldid = f8
         4 oefieldvalue = f8
         4 oefielddisplayvalue = vc
         4 oefielddttmvalue = dq8
         4 oefieldtz = i4
         4 oefieldmeaning = vc
         4 oefieldmeaningid = f8
         4 valuerequiredind = i2
         4 groupseq = i4
         4 fieldseq = i4
         4 modifiedind = i2
       3 subcomponentlist[*]
         4 sccompsequence = i4
         4 sccatalogcd = f8
         4 scgcrcode = i4
         4 sccatalogtypecd = f8
         4 scsynonymid = f8
         4 scordermnemonic = vc
         4 scorderdetaildisplayline = vc
         4 scoeformatid = f8
         4 scstrength = f8
         4 scstrengthunit = f8
         4 scvolume = f8
         4 scvolumeunit = f8
         4 scfreetextdose = vc
         4 scivseq = i4
         4 scmultumid = vc
         4 scgenericname = vc
         4 scbrandname = vc
         4 sclabeldesc = vc
         4 scfrequency = f8
 )
 SET ccost = 2004.00
 SET ccomponentcost = 2005.00
 SET cdispensefromloc = 2006.00
 SET cdispensecategory = 2007.00
 SET ccomponentdispensecategory = 2008.00
 SET cfreq = 2011.00
 SET ccomponentfreq = 2012.00
 SET civfreq = 2013.00
 SET cdrugform = 2014.00
 SET cdispenseqty = 2015.00
 SET crefillqty = 2016.00
 SET cdaw = 2017.00
 SET csamplesgiven = 2018.00
 SET csampleqty = 2019.00
 SET cnextdispensedttm = 2024.00
 SET cpharmnotes = 2028.00
 SET cnotetype = 2029.00
 SET cparvalue = 2032.00
 SET cphysician = 2033.00
 SET cprinter = 2039.00
 SET crate = 2043.00
 SET ccomponentrate = 2044.00
 SET ccollroute = 2045.00
 SET croute = 2050.00
 SET ccomponentroute = 2046.00
 SET cstartbag = 2047.00
 SET ccomponentstartbag = 2048.00
 SET cstopbag = 2053.00
 SET cstoptype = 2055.00
 SET cstrengthdose = 2056.00
 SET cstrengthdoseunit = 2057.00
 SET cvolumedose = 2058.00
 SET cvolumedoseunit = 2059.00
 SET ctotalvolume = 2060.00
 SET cduration = 2061.00
 SET cdurationunit = 2062.00
 SET cfreetxtdose = 2063.00
 SET cinfuseoverunit = 2064.00
 SET cinfuseover = 118.00
 SET cstopdttm = 2073.00
 SET cdiluentid = 2065.00
 SET cdiluentvol = 2066.00
 SET cschprn = 2037.00
 SET last_mod = "000"
 SET crepl = 2068.00
 SET creplunit = 2069.00
 SET cordertype = 2070.00
 SET ctitrate = 2078.00
 SET code_value = 0.0
 SET cdf_meaning = fillstring(16," ")
 SET code_set = 0.0
 CALL echo(sitem_ids)
 IF (cnvtupper(trim( $SEARCHTYPE))="DRUG")
  IF (new_model_check=0)
   SELECT INTO "NL:"
    oii2.object_id
    FROM object_identifier_index oii,
     object_identifier_index oii2
    PLAN (oii
     WHERE oii.value_key=patstring(value(cnvtupper(trim(ssearch_string))))
      AND oii.identifier_type_cd IN (clabel, cgeneric)
      AND oii.object_type_cd=cmeddef
      AND oii.generic_object=0)
     JOIN (oii2
     WHERE oii2.object_id=oii.object_id
      AND oii2.generic_object=0
      AND ((oii2.identifier_type_cd+ 0)=clabel)
      AND ((oii2.object_type_cd+ 0)=cmeddef)
      AND ((oii2.primary_ind+ 0)=1))
    ORDER BY oii2.object_id
    HEAD REPORT
     medcnt = 0
    HEAD oii2.object_id
     medcnt = (medcnt+ 1)
     IF (medcnt > size(orderrec->qual,5))
      stat = alterlist(orderrec->qual,(medcnt+ 10))
     ENDIF
     orderrec->qual[medcnt].item_id = oii2.object_id
    WITH nocounter, nullreport
   ;end select
  ELSE
   SELECT INTO "NL:"
    mi.item_id
    FROM med_identifier mi,
     med_identifier mi2
    PLAN (mi
     WHERE mi.value_key=patstring(value(cnvtupper(trim(ssearch_string))))
      AND mi.med_identifier_type_cd IN (cgeneric, clabel)
      AND ((mi.flex_type_cd+ 0)=csystem)
      AND mi.pharmacy_type_cd=cinpatient
      AND mi.med_product_id=0)
     JOIN (mi2
     WHERE mi2.item_id=mi.item_id
      AND mi2.med_product_id=0
      AND mi2.med_identifier_type_cd=clabel
      AND ((mi2.flex_type_cd+ 0)=csystem)
      AND ((mi2.pharmacy_type_cd+ 0)=cinpatient)
      AND ((mi2.primary_ind+ 0)=1))
    ORDER BY mi2.item_id
    HEAD REPORT
     medcnt = 0
    HEAD mi2.item_id
     medcnt = (medcnt+ 1)
     IF (medcnt > size(orderrec->qual,5))
      stat = alterlist(orderrec->qual,(medcnt+ 10))
     ENDIF
     orderrec->qual[medcnt].item_id = mi2.item_id
    WITH nocounter
   ;end select
  ENDIF
  SET stat = alterlist(orderrec->qual,medcnt)
 ELSEIF (cnvtupper(trim( $SEARCHTYPE))="THERAPEUTIC CLASS")
  RECORD ther(
    1 qual[*]
      2 alt_sel_cat_id = f8
      2 long_description = c35
  )
  SELECT DISTINCT INTO "NL:"
   a.alt_sel_category_id, a.long_description
   FROM alt_sel_cat a
   WHERE a.long_description_key_cap=patstring(value(cnvtupper(trim( $SEARCHSTRING))))
    AND ((a.alt_sel_category_id+ 0) > 0)
   ORDER BY a.long_description, a.alt_sel_category_id
   HEAD a.alt_sel_category_id
    IF (first_real=1
     AND a.alt_sel_category_id > 0)
     first_real = 0, internal->alt_sel_cat_id = a.alt_sel_category_id, internal->select_desc = a
     .long_description
    ENDIF
    IF (first_real=0
     AND count > 0
     AND (a.alt_sel_category_id != ther->qual[count].alt_sel_cat_id))
     total_thers = 2
    ENDIF
    count = (count+ 1)
    IF (count > size(ther->qual,5))
     stat = alterlist(ther->qual,(count+ 10))
    ENDIF
    ther->qual[count].alt_sel_cat_id = a.alt_sel_category_id, ther->qual[count].long_description = a
    .long_description
   WITH nocounter
  ;end select
  SET stat = alterlist(ther->qual,count)
 ENDIF
 IF (cnvtupper(trim( $SEARCHTYPE))="THERAPEUTIC CLASS"
  AND (internal->alt_sel_cat_id > 0))
  SET nactual_size = size(ther->qual,5)
  SET nexpand_total = (nactual_size+ (nexpand_size - mod(nactual_size,nexpand_size)))
  SET nexpand_start = 1
  SET nexpand_stop = 50
  SET stat = alterlist(ther->qual,nexpand_total)
  FOR (x = (nactual_size+ 1) TO nexpand_total)
    SET ther->qual[x].alt_sel_cat_id = ther->qual[nactual_size].alt_sel_cat_id
  ENDFOR
  CALL echo(cget_thera_class)
  SET tclass = 0.0
  SET rec_cnt = 0
  RECORD class(
    1 qual[*]
      2 code = f8
      2 long_description = c35
  )
  SELECT INTO "NL:"
   a2_hit = decode(a2.seq,1,0), a3_hit = decode(a3.seq,1,0), a4_hit = decode(a4.seq,1,0),
   a5_hit = decode(a5.seq,1,0), a1.alt_sel_category_id, a3.alt_sel_category_id,
   a5.alt_sel_category_id
   FROM (dummyt d  WITH seq = value((nexpand_total/ nexpand_size))),
    alt_sel_cat a1,
    dummyt d1,
    alt_sel_list a2,
    alt_sel_cat a3,
    dummyt d2,
    alt_sel_list a4,
    alt_sel_cat a5
   PLAN (d
    WHERE assign(nexpand_start,evaluate(d.seq,1,1,(nexpand_start+ nexpand_size)))
     AND assign(nexpand_stop,(nexpand_start+ (nexpand_size - 1))))
    JOIN (a1
    WHERE expand(nexpand,nexpand_start,nexpand_stop,a1.alt_sel_category_id,ther->qual[nexpand].
     alt_sel_cat_id)
     AND ((a1.alt_sel_category_id+ 0) > 0))
    JOIN (d1)
    JOIN (a2
    WHERE a1.alt_sel_category_id=a2.alt_sel_category_id
     AND a2.list_type != 2)
    JOIN (a3
    WHERE (a3.alt_sel_category_id=(a2.child_alt_sel_cat_id+ 0)))
    JOIN (d2)
    JOIN (a4
    WHERE a3.alt_sel_category_id=a4.alt_sel_category_id
     AND ((a4.alt_sel_category_id+ 0) > 0))
    JOIN (a5
    WHERE (a5.alt_sel_category_id=(a4.child_alt_sel_cat_id+ 0))
     AND ((a5.alt_sel_category_id+ 0) > 0))
   ORDER BY a1.alt_sel_category_id, a3.alt_sel_category_id, a5.alt_sel_category_id
   HEAD REPORT
    rec_cnt = 0
   HEAD a1.alt_sel_category_id
    rec_cnt = (rec_cnt+ 1)
    IF (rec_cnt > size(class->qual,5))
     stat = alterlist(class->qual,(rec_cnt+ 10))
    ENDIF
    class->qual[rec_cnt].code = a1.alt_sel_category_id, nindex = locateval(x,1,nactual_size,a3
     .alt_sel_category_id,ther->qual[x].alt_sel_cat_id), class->qual[rec_cnt].long_description = ther
    ->qual[nindex].long_description
   HEAD a3.alt_sel_category_id
    IF (a2_hit=1)
     rec_cnt = (rec_cnt+ 1)
     IF (rec_cnt > size(class->qual,5))
      stat = alterlist(class->qual,(rec_cnt+ 10))
     ENDIF
     class->qual[rec_cnt].code = a3.alt_sel_category_id
    ENDIF
   HEAD a5.alt_sel_category_id
    IF (a4_hit=1)
     rec_cnt = (rec_cnt+ 1)
     IF (rec_cnt > size(class->qual,5))
      stat = alterlist(class->qual,(rec_cnt+ 10))
     ENDIF
     class->qual[rec_cnt].code = a5.alt_sel_category_id
    ENDIF
   WITH outerjoin = d1, outerjoin = d2
  ;end select
  SET stat = alterlist(class->qual,rec_cnt)
  SET rec_cnt = size(class->qual,5)
  SET nactual_size = size(class->qual,5)
  SET nexpand_total = (nactual_size+ (nexpand_size - mod(nactual_size,nexpand_size)))
  SET nexpand_start = 1
  SET nexpand_stop = 50
  SET stat = alterlist(class->qual,nexpand_total)
  FOR (x = (nactual_size+ 1) TO nexpand_total)
    SET class->qual[x].code = class->qual[nactual_size].code
  ENDFOR
  IF (new_model_check=0)
   CALL echo(sold_model)
   SELECT DISTINCT INTO "NL:"
    oci.item_id
    FROM alt_sel_list a,
     order_catalog_item_r oci,
     (dummyt d  WITH seq = value((nexpand_total/ nexpand_size)))
    PLAN (d
     WHERE assign(nexpand_start,evaluate(d.seq,1,1,(nexpand_start+ nexpand_size)))
      AND assign(nexpand_stop,(nexpand_start+ (nexpand_size - 1))))
     JOIN (a
     WHERE expand(nexpand,nexpand_start,nexpand_stop,a.alt_sel_category_id,class->qual[nexpand].code)
      AND ((a.alt_sel_category_id+ 0) > 0))
     JOIN (oci
     WHERE (oci.synonym_id=(a.synonym_id+ 0))
      AND ((oci.catalog_cd+ 0) > 0)
      AND ((oci.synonym_id+ 0) > 0))
    ORDER BY oci.item_id
    HEAD REPORT
     itemcnt = 0
    HEAD oci.item_id
     itemcnt = (itemcnt+ 1)
     IF (itemcnt > size(orderrec->qual,5))
      stat = alterlist(orderrec->qual,(itemcnt+ 10))
     ENDIF
     orderrec->qual[itemcnt].item_id = oci.item_id
    WITH nocounter
   ;end select
  ELSE
   CALL echo(snew_model)
   SELECT DISTINCT INTO "NL:"
    oci.item_id
    FROM alt_sel_list a,
     order_catalog_item_r oci,
     med_def_flex mdf,
     (dummyt d  WITH seq = value((nexpand_total/ nexpand_size)))
    PLAN (d
     WHERE assign(nexpand_start,evaluate(d.seq,1,1,(nexpand_start+ nexpand_size)))
      AND assign(nexpand_stop,(nexpand_start+ (nexpand_size - 1))))
     JOIN (a
     WHERE expand(nexpand,nexpand_start,nexpand_stop,a.alt_sel_category_id,class->qual[nexpand].code)
      AND ((a.alt_sel_category_id+ 0) > 0))
     JOIN (oci
     WHERE (oci.synonym_id=(a.synonym_id+ 0))
      AND ((oci.catalog_cd+ 0) > 0)
      AND ((oci.synonym_id+ 0) > 0))
     JOIN (mdf
     WHERE (mdf.item_id=(oci.item_id+ 0))
      AND ((mdf.pharmacy_type_cd+ 0)=cinpatient)
      AND mdf.flex_type_cd=csyspkgtyp)
    ORDER BY oci.item_id
    HEAD REPORT
     itemcnt = 0
    HEAD oci.item_id
     itemcnt = (itemcnt+ 1)
     IF (itemcnt > size(orderrec->qual,5))
      stat = alterlist(orderrec->qual,(itemcnt+ 10))
     ENDIF
     orderrec->qual[itemcnt].item_id = oci.item_id
    WITH nocounter
   ;end select
  ENDIF
  SET stat = alterlist(orderrec->qual,itemcnt)
  IF (curqual=0)
   CALL echo(sno_orders_ret)
  ENDIF
 ENDIF
 IF (size(orderrec->qual,5) >= 32768)
  CALL echo(sexceeded_list)
  SET nerrorind = 1
  GO TO exit_script
 ENDIF
 RECORD orderlist(
   1 data[*]
     2 order_id = f8
 )
 SET idx = 0
 SET xcntr = 0
 SET cntr = 0
 SET cntr = size(orderrec->qual,5)
 SET nactual_size = size(orderrec->qual,5)
 SET nexpand_total = (nactual_size+ (nexpand_size - mod(nactual_size,nexpand_size)))
 SET nexpand_start = 1
 SET nexpand_stop = 50
 SET stat = alterlist(orderrec->qual,nexpand_total)
 FOR (x = (nactual_size+ 1) TO nexpand_total)
   SET orderrec->qual[x].item_id = orderrec->qual[nactual_size].item_id
 ENDFOR
 CALL echo(sget_ordid)
 SET idx = 0
 SELECT DISTINCT INTO "NL:"
  o.order_id, op.order_id, op.item_id,
  e.loc_facility_cd
  FROM encounter e,
   orders o,
   order_product op,
   (dummyt d  WITH seq = value((nexpand_total/ nexpand_size)))
  PLAN (d
   WHERE assign(nexpand_start,evaluate(d.seq,1,1,(nexpand_start+ nexpand_size)))
    AND assign(nexpand_stop,(nexpand_start+ (nexpand_size - 1))))
   JOIN (o
   WHERE o.template_order_id=0
    AND o.current_start_dt_tm BETWEEN cnvtdatetime(internal->begin_dt_tm) AND cnvtdatetime(internal->
    end_dt_tm)
    AND ((((o.orig_ord_as_flag+ 0)=0)) OR (cnvtupper( $PYXIS)="YES"
    AND ((o.orig_ord_as_flag+ 0)=4)))
    AND ((o.template_order_flag+ 0) IN (0, 1))
    AND ((o.catalog_type_cd+ 0)=ccatalogcd)
    AND ((o.activity_type_cd+ 0)=activity_type)
    AND ((ball=1) OR (((bactive=1
    AND ((o.order_status_cd+ 0) IN (cordered, cordered2, conhold, csoft, cfuture,
   csuspended))) OR (((bdc=1
    AND ((o.order_status_cd+ 0) IN (cdiscontinued, cpending, ctrans, ccompleted))) OR (bcancel=1
    AND ((o.order_status_cd+ 0) IN (cvoided, cdeleted, cvoid, cincomplete, ccanceled)))) )) )) )
   JOIN (op
   WHERE (op.order_id=(o.order_id+ 0))
    AND op.action_sequence > 0
    AND op.ingred_sequence > 0
    AND expand(nexpand,nexpand_start,nexpand_stop,op.item_id,orderrec->qual[nexpand].item_id)
    AND ((op.item_id+ 0) > 0))
   JOIN (e
   WHERE (e.encntr_id=(o.encntr_id+ 0)))
  ORDER BY op.order_id, op.item_id
  DETAIL
   CALL echo(build(sdetail_orderid," ","--",op.order_id)),
   CALL echo(build(seloc," ","--",e.loc_facility_cd))
   IF (locateval(x,1,size(facility_list->qual,5),e.loc_facility_cd,facility_list->qual[x].facility_cd
    ) > 0)
    idx = (idx+ 1)
    IF (idx > size(orderlist->data,5))
     stat = alterlist(orderlist->data,(idx+ 10))
    ENDIF
    orderlist->data[idx].order_id = o.order_id,
    CALL echo(build(sord_id," ","--",op.order_id))
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(orderlist->data,idx)
 SET ncntr = 0
 SET ncntr = size(orderlist->data,5)
 CALL echo(build(sord_list_size," ","===",size(orderlist->data,5)))
 SET nactual_size = size(orderlist->data,5)
 SET nexpand_total = (nactual_size+ (nexpand_size - mod(nactual_size,nexpand_size)))
 SET nexpand_start = 1
 SET nexpand_stop = 50
 SET stat = alterlist(orderlist->data,nexpand_total)
 FOR (x = (nactual_size+ 1) TO nexpand_total)
   SET orderlist->data[x].order_id = orderlist->data[nactual_size].order_id
 ENDFOR
 SET ordcnt = 0
 SET oacnt = 0
 SET oicnt = 0
 SET occnt = 0
 SET addedcomp = 0
 CALL echo(build(sord_list_size," ","===",size(orderlist->data,5)))
 CALL echo(sjoin)
 IF (new_model_check=0)
  SELECT INTO "NL:"
   o.order_id, ordactseq = concat(cnvtstring(o.order_id),cnvtstring(o.last_action_sequence)),
   ordsubseq = concat(cnvtstring(oi.order_id),cnvtstring(oi.action_sequence),cnvtstring(oi
     .comp_sequence)),
   oihit = decode(oi.comp_sequence,oi.comp_sequence,0), orddetseq = concat(cnvtstring(od.order_id),
    cnvtstring(od.action_sequence),cnvtstring(od.detail_sequence)), odhit = decode(od.detail_sequence,
    od.detail_sequence,0),
   op_hit = decode(op.seq,1,0), loc_bed_s = uar_get_code_display(e.loc_bed_cd), loc_s =
   uar_get_code_description(e.loc_nurse_unit_cd),
   prod_name = substring(1,30,oii.value), loc_room_s = uar_get_code_display(e.loc_room_cd),
   facility_area = uar_get_code_display(e.loc_facility_cd),
   e.loc_facility_cd, o.order_status_cd, o.projected_stop_dt_tm,
   o.projected_stop_tz, o.current_start_dt_tm, o.current_start_tz,
   o.dept_misc_line, o.order_status_cd, o.last_action_sequence,
   p.name_full_formatted, e.encntr_id, ea.alias,
   ea.alias_pool_cd, od.order_id, od.action_sequence,
   od.detail_sequence, od.oe_field_id, od.oe_field_value,
   od.oe_field_display_value, od.oe_field_meaning_id, od.oe_field_meaning,
   od.oe_field_dt_tm_value, od.oe_field_tz, oi.comp_sequence,
   oi.freq_cd, oi.catalog_cd, oi.catalog_type_cd,
   oi.synonym_id, oi.order_mnemonic, oi.order_detail_display_line,
   oi.strength, oi.strength_unit, oi.volume,
   oi.volume_unit, oi.freetext_dose, oi.iv_seq,
   oii.identifier_type_cd, oii.value, op.item_id
   FROM (dummyt d  WITH seq = value((nexpand_total/ nexpand_size))),
    orders o,
    order_ingredient oi,
    order_detail od,
    order_product op,
    object_identifier_index oii,
    person p,
    encounter e,
    encntr_alias ea,
    (dummyt do4  WITH seq = 1)
   PLAN (d
    WHERE assign(nexpand_start,evaluate(d.seq,1,1,(nexpand_start+ nexpand_size)))
     AND assign(nexpand_stop,(nexpand_start+ (nexpand_size - 1))))
    JOIN (o
    WHERE expand(nexpand,nexpand_start,nexpand_stop,o.order_id,orderlist->data[nexpand].order_id))
    JOIN (oi
    WHERE (oi.order_id=(o.order_id+ 0))
     AND (oi.action_sequence=(o.last_ingred_action_sequence+ 0)))
    JOIN (op
    WHERE (op.order_id=(oi.order_id+ 0))
     AND (op.action_sequence=(o.last_ingred_action_sequence+ 0))
     AND (op.ingred_sequence=(oi.comp_sequence+ 0)))
    JOIN (od
    WHERE (od.order_id=(op.order_id+ 0))
     AND ((od.action_sequence+ 0) > 0)
     AND ((od.detail_sequence+ 0) > 0)
     AND ((od.oe_field_meaning_id+ 0) IN (cfreq, crate, croute, cinfuseoverunit, cinfuseover,
    cschprn, crepl, creplunit, cordertype, ctitrate)))
    JOIN (oii
    WHERE (oii.object_id=(op.item_id+ 0))
     AND oii.generic_object=0
     AND ((oii.identifier_type_cd+ 0) IN (clabel, cgeneric))
     AND ((oii.primary_ind+ 0)=1))
    JOIN (p
    WHERE (p.person_id=(o.person_id+ 0)))
    JOIN (e
    WHERE (e.encntr_id=(o.encntr_id+ 0)))
    JOIN (do4)
    JOIN (ea
    WHERE (ea.encntr_id=(e.encntr_id+ 0))
     AND ea.encntr_alias_type_cd=cfinnbr
     AND ea.active_ind=1
     AND cnvtdatetime(curdate,curtime) BETWEEN (ea.beg_effective_dt_tm+ 0) AND (ea
    .end_effective_dt_tm+ 0))
   ORDER BY o.order_id, ordactseq, ordsubseq,
    orddetseq
   HEAD REPORT
    cnt2 = 0,
    CALL echo(cmain_rep), stat = alterlist(orderrec->orderlist,0)
   HEAD o.order_id
    IF (locateval(x,1,size(facility_list->qual,5),e.loc_facility_cd,facility_list->qual[x].
     facility_cd) > 0)
     temp_status = uar_get_code_display(o.order_status_cd), qualified = 1, ordcnt = (ordcnt+ 1),
     stat = alterlist(orderrec->orderlist,ordcnt), orderrec->orderlist[ordcnt].orderid = o.order_id,
     orderrec->orderlist[ordcnt].s_hna_mnemonic = trim(o.hna_order_mnemonic),
     orderrec->orderlist[ordcnt].projected_stop_dt_tm = cnvtdatetime(o.projected_stop_dt_tm),
     orderrec->orderlist[ordcnt].projected_stop_tz = o.projected_stop_tz, orderrec->orderlist[ordcnt]
     .current_start_dt_tm = cnvtdatetime(o.current_start_dt_tm),
     orderrec->orderlist[ordcnt].current_start_tz = o.current_start_tz, orderrec->orderlist[ordcnt].
     loc_s = substring(1,30,loc_s), orderrec->orderlist[ordcnt].loc_room_s = substring(1,10,
      loc_room_s),
     orderrec->orderlist[ordcnt].loc_bed_s = substring(1,10,loc_bed_s), orderrec->orderlist[ordcnt].
     facility = substring(1,30,facility_area), orderrec->orderlist[ordcnt].name = p
     .name_full_formatted,
     orderrec->orderlist[ordcnt].fin_nbr = cnvtalias(ea.alias,ea.alias_pool_cd), orderrec->orderlist[
     ordcnt].deptmiscline = o.dept_misc_line, orderrec->orderlist[ordcnt].order_status = o
     .order_status_cd,
     orderrec->orderlist[ordcnt].all_unverified_ind = 1, orderrec->orderlist[ordcnt].encntr_id = e
     .encntr_id, oacnt = 0,
     oicnt = 0
    ENDIF
   HEAD ordactseq
    IF (locateval(x,1,size(facility_list->qual,5),e.loc_facility_cd,facility_list->qual[x].
     facility_cd) > 0)
     orderrec->orderlist[ordcnt].qualified = "Y", oacnt = 1, stat = alterlist(orderrec->orderlist[
      ordcnt].actionlist,oacnt),
     orderrec->orderlist[ordcnt].actionlist[1].actionsequence = o.last_action_sequence, orderrec->
     orderlist[ordcnt].actionlist[1].deptstatuscd = orderrec->orderlist[ordcnt].order_status, oicnt
      = 0,
     odcnt = 0
    ENDIF
   HEAD orddetseq
    IF (locateval(x,1,size(facility_list->qual,5),e.loc_facility_cd,facility_list->qual[x].
     facility_cd) > 0)
     IF (odhit > 0)
      odcnt = (odcnt+ 1), stat = alterlist(orderrec->orderlist[ordcnt].actionlist[oacnt].detaillist,
       odcnt), orderrec->orderlist[ordcnt].actionlist[oacnt].detaillist[odcnt].orderid = od.order_id,
      orderrec->orderlist[ordcnt].actionlist[oacnt].detaillist[odcnt].actionsequence = od
      .action_sequence, orderrec->orderlist[ordcnt].actionlist[oacnt].detaillist[odcnt].
      detailsequence = od.detail_sequence, orderrec->orderlist[ordcnt].actionlist[oacnt].detaillist[
      odcnt].oefieldid = od.oe_field_id,
      orderrec->orderlist[ordcnt].actionlist[oacnt].detaillist[odcnt].oefieldvalue = od
      .oe_field_value, orderrec->orderlist[ordcnt].actionlist[oacnt].detaillist[odcnt].
      oefielddisplayvalue = od.oe_field_display_value, orderrec->orderlist[ordcnt].actionlist[oacnt].
      detaillist[odcnt].oefieldmeaningid = od.oe_field_meaning_id,
      orderrec->orderlist[ordcnt].actionlist[oacnt].detaillist[odcnt].oefieldmeaning = od
      .oe_field_meaning, orderrec->orderlist[ordcnt].actionlist[oacnt].detaillist[odcnt].
      oefielddttmvalue = od.oe_field_dt_tm_value, orderrec->orderlist[ordcnt].actionlist[oacnt].
      detaillist[odcnt].oefieldtz = od.oe_field_tz
     ENDIF
    ENDIF
   DETAIL
    IF (locateval(x,1,size(facility_list->qual,5),e.loc_facility_cd,facility_list->qual[x].
     facility_cd) > 0)
     i = 0
     IF (oihit > 0)
      oicnt = oi.comp_sequence, stat = alterlist(orderrec->orderlist[ordcnt].actionlist[oacnt].
       subcomponentlist,oicnt), orderrec->orderlist[ordcnt].actionlist[oacnt].subcomponentlist[oicnt]
      .sccompsequence = oi.comp_sequence,
      orderrec->orderlist[ordcnt].actionlist[oacnt].subcomponentlist[oicnt].scfrequency = oi.freq_cd,
      orderrec->orderlist[ordcnt].actionlist[oacnt].subcomponentlist[oicnt].sccatalogcd = oi
      .catalog_cd, orderrec->orderlist[ordcnt].actionlist[oacnt].subcomponentlist[oicnt].
      sccatalogtypecd = oi.catalog_type_cd,
      orderrec->orderlist[ordcnt].actionlist[oacnt].subcomponentlist[oicnt].scsynonymid = oi
      .synonym_id, orderrec->orderlist[ordcnt].actionlist[oacnt].subcomponentlist[oicnt].
      scordermnemonic = oi.order_mnemonic, orderrec->orderlist[ordcnt].actionlist[oacnt].
      subcomponentlist[oicnt].scorderdetaildisplayline = oi.order_detail_display_line,
      orderrec->orderlist[ordcnt].actionlist[oacnt].subcomponentlist[oicnt].scstrength = round(oi
       .strength,4), orderrec->orderlist[ordcnt].actionlist[oacnt].subcomponentlist[oicnt].
      scstrengthunit = oi.strength_unit, orderrec->orderlist[ordcnt].actionlist[oacnt].
      subcomponentlist[oicnt].scvolume = round(oi.volume,2),
      orderrec->orderlist[ordcnt].actionlist[oacnt].subcomponentlist[oicnt].scvolumeunit = oi
      .volume_unit, orderrec->orderlist[ordcnt].actionlist[oacnt].subcomponentlist[oicnt].
      scfreetextdose = oi.freetext_dose, orderrec->orderlist[ordcnt].actionlist[oacnt].
      subcomponentlist[oicnt].scivseq = oi.iv_seq
      IF (op_hit > 0)
       temp_idx = oi.comp_sequence
       IF (oii.identifier_type_cd=clabel)
        FOR (i = 1 TO cntr)
          IF ((op.item_id=orderrec->qual[i].item_id))
           orderrec->orderlist[ordcnt].sort_label_desc = substring(1,50,oii.value), i = cntr
          ENDIF
        ENDFOR
       ENDIF
       IF (oii.identifier_type_cd=cgeneric)
        orderrec->orderlist[ordcnt].actionlist[oacnt].subcomponentlist[temp_idx].scgenericname =
        substring(1,50,oii.value)
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   WITH nocounter, check, outerjoin = do4,
    outerjoin = ea, dontcare = ea
  ;end select
 ELSEIF (new_model_check=1)
  SELECT INTO "NL:"
   o.order_id, ordactseq = concat(cnvtstring(o.order_id),cnvtstring(o.last_action_sequence)),
   ordsubseq = concat(cnvtstring(oi.order_id),cnvtstring(oi.action_sequence),cnvtstring(oi
     .comp_sequence)),
   oihit = decode(oi.comp_sequence,oi.comp_sequence,0), orddetseq = concat(cnvtstring(od.order_id),
    cnvtstring(od.action_sequence),cnvtstring(od.detail_sequence)), odhit = decode(od.detail_sequence,
    od.detail_sequence,0),
   op_hit = decode(op.seq,1,0), loc_bed_s = uar_get_code_display(e.loc_bed_cd), loc_s =
   uar_get_code_description(e.loc_nurse_unit_cd),
   prod_name = substring(1,30,mi.value), loc_room_s = uar_get_code_display(e.loc_room_cd),
   facility_area = uar_get_code_display(e.loc_facility_cd),
   o.order_status_cd, o.projected_stop_dt_tm, o.projected_stop_tz,
   o.current_start_dt_tm, o.current_start_tz, o.dept_misc_line,
   o.order_status_cd, o.last_action_sequence, p.name_full_formatted,
   e.encntr_id, e.loc_facility_cd, ea.alias,
   ea.alias_pool_cd, od.order_id, od.action_sequence,
   od.detail_sequence, od.oe_field_id, od.oe_field_value,
   od.oe_field_meaning_id, od.oe_field_meaning, od.oe_field_dt_tm_value,
   od.oe_field_tz, oi.comp_sequence, oi.freq_cd,
   oi.catalog_cd, oi.catalog_type_cd, oi.synonym_id,
   oi.order_mnemonic, oi.order_detail_display_line, oi.strength,
   oi.strength_unit, oi.volume, oi.volume_unit,
   oi.freetext_dose, oi.iv_seq, mi.med_identifier_type_cd,
   mi.value
   FROM (dummyt d  WITH seq = value((nexpand_total/ nexpand_size))),
    orders o,
    order_ingredient oi,
    order_detail od,
    order_product op,
    med_identifier mi,
    person p,
    encounter e,
    encntr_alias ea,
    (dummyt do4  WITH seq = 1)
   PLAN (d
    WHERE assign(nexpand_start,evaluate(d.seq,1,1,(nexpand_start+ nexpand_size)))
     AND assign(nexpand_stop,(nexpand_start+ (nexpand_size - 1))))
    JOIN (o
    WHERE expand(nexpand,nexpand_start,nexpand_stop,o.order_id,orderlist->data[nexpand].order_id))
    JOIN (oi
    WHERE (oi.order_id=(o.order_id+ 0))
     AND (oi.action_sequence=(o.last_ingred_action_sequence+ 0)))
    JOIN (op
    WHERE (op.order_id=(oi.order_id+ 0))
     AND (op.action_sequence=(o.last_ingred_action_sequence+ 0))
     AND (op.ingred_sequence=(oi.comp_sequence+ 0))
     AND ((op.item_id+ 0) > 0))
    JOIN (od
    WHERE (od.order_id=(op.order_id+ 0))
     AND ((od.action_sequence+ 0) > 0)
     AND ((od.detail_sequence+ 0) > 0)
     AND ((od.oe_field_meaning_id+ 0) IN (cfreq, crate, croute, cinfuseoverunit, cinfuseover,
    cschprn, crepl, creplunit, cordertype, ctitrate)))
    JOIN (mi
    WHERE (mi.item_id=(op.item_id+ 0))
     AND mi.med_identifier_type_cd IN (clabel, cgeneric)
     AND mi.med_product_id=0
     AND mi.sequence=1
     AND ((mi.flex_type_cd+ 0)=csystem)
     AND ((mi.pharmacy_type_cd+ 0)=cinpatient)
     AND ((mi.primary_ind+ 0)=1))
    JOIN (p
    WHERE (p.person_id=(o.person_id+ 0)))
    JOIN (e
    WHERE (e.encntr_id=(o.encntr_id+ 0)))
    JOIN (do4)
    JOIN (ea
    WHERE (ea.encntr_id=(e.encntr_id+ 0))
     AND ea.encntr_alias_type_cd=cfinnbr
     AND ea.active_ind=1
     AND cnvtdatetime(curdate,curtime) BETWEEN (ea.beg_effective_dt_tm+ 0) AND (ea
    .end_effective_dt_tm+ 0))
   ORDER BY o.order_id, ordactseq, ordsubseq,
    orddetseq
   HEAD REPORT
    cnt2 = 0,
    CALL echo(cmain_rep), stat = alterlist(orderrec->orderlist,0)
   HEAD o.order_id
    IF (locateval(x,1,size(facility_list->qual,5),e.loc_facility_cd,facility_list->qual[x].
     facility_cd) > 0)
     temp_status = uar_get_code_display(o.order_status_cd), qualified = 1, ordcnt = (ordcnt+ 1),
     stat = alterlist(orderrec->orderlist,ordcnt), orderrec->orderlist[ordcnt].orderid = o.order_id,
     orderrec->orderlist[ordcnt].s_hna_mnemonic = trim(o.hna_order_mnemonic),
     orderrec->orderlist[ordcnt].projected_stop_dt_tm = cnvtdatetime(o.projected_stop_dt_tm),
     orderrec->orderlist[ordcnt].projected_stop_tz = o.projected_stop_tz, orderrec->orderlist[ordcnt]
     .current_start_dt_tm = cnvtdatetime(o.current_start_dt_tm),
     orderrec->orderlist[ordcnt].current_start_tz = o.current_start_tz, orderrec->orderlist[ordcnt].
     loc_s = substring(1,30,loc_s), orderrec->orderlist[ordcnt].loc_room_s = substring(1,10,
      loc_room_s),
     orderrec->orderlist[ordcnt].loc_bed_s = substring(1,10,loc_bed_s), orderrec->orderlist[ordcnt].
     facility = substring(1,30,facility_area), orderrec->orderlist[ordcnt].name = p
     .name_full_formatted,
     orderrec->orderlist[ordcnt].fin_nbr = cnvtalias(ea.alias,ea.alias_pool_cd), orderrec->orderlist[
     ordcnt].deptmiscline = o.dept_misc_line, orderrec->orderlist[ordcnt].order_status = o
     .order_status_cd,
     orderrec->orderlist[ordcnt].all_unverified_ind = 1, orderrec->orderlist[ordcnt].encntr_id = e
     .encntr_id,
     CALL echo(build(sencntr," ","--",e.encntr_id)),
     CALL echo(build(sencntr," ",sid," ","---",
      orderrec->orderlist[ordcnt].encntr_id)), oacnt = 0, oicnt = 0
    ENDIF
   HEAD ordactseq
    IF (locateval(x,1,size(facility_list->qual,5),e.loc_facility_cd,facility_list->qual[x].
     facility_cd) > 0)
     orderrec->orderlist[ordcnt].qualified = "Y", oacnt = 1
     IF (oacnt > size(orderrec->orderlist[ordcnt].actionlist,5))
      stat = alterlist(orderrec->orderlist[ordcnt].actionlist,oacnt)
     ENDIF
     orderrec->orderlist[ordcnt].actionlist[1].actionsequence = o.last_action_sequence, orderrec->
     orderlist[ordcnt].actionlist[1].deptstatuscd = orderrec->orderlist[ordcnt].order_status, oicnt
      = 0,
     odcnt = 0
    ENDIF
   HEAD orddetseq
    IF (locateval(x,1,size(facility_list->qual,5),e.loc_facility_cd,facility_list->qual[x].
     facility_cd) > 0)
     IF (odhit > 0)
      odcnt = (odcnt+ 1)
      IF (odcnt > size(orderrec->orderlist[ordcnt].actionlist[oacnt].detaillist,5))
       stat = alterlist(orderrec->orderlist[ordcnt].actionlist[oacnt].detaillist,odcnt)
      ENDIF
      orderrec->orderlist[ordcnt].actionlist[oacnt].detaillist[odcnt].orderid = od.order_id, orderrec
      ->orderlist[ordcnt].actionlist[oacnt].detaillist[odcnt].actionsequence = od.action_sequence,
      orderrec->orderlist[ordcnt].actionlist[oacnt].detaillist[odcnt].detailsequence = od
      .detail_sequence,
      orderrec->orderlist[ordcnt].actionlist[oacnt].detaillist[odcnt].oefieldid = od.oe_field_id,
      orderrec->orderlist[ordcnt].actionlist[oacnt].detaillist[odcnt].oefieldvalue = od
      .oe_field_value, orderrec->orderlist[ordcnt].actionlist[oacnt].detaillist[odcnt].
      oefielddisplayvalue = od.oe_field_display_value,
      orderrec->orderlist[ordcnt].actionlist[oacnt].detaillist[odcnt].oefieldmeaningid = od
      .oe_field_meaning_id, orderrec->orderlist[ordcnt].actionlist[oacnt].detaillist[odcnt].
      oefieldmeaning = od.oe_field_meaning, orderrec->orderlist[ordcnt].actionlist[oacnt].detaillist[
      odcnt].oefielddttmvalue = od.oe_field_dt_tm_value,
      orderrec->orderlist[ordcnt].actionlist[oacnt].detaillist[odcnt].oefieldtz = od.oe_field_tz
     ENDIF
    ENDIF
   DETAIL
    IF (locateval(x,1,size(facility_list->qual,5),e.loc_facility_cd,facility_list->qual[x].
     facility_cd) > 0)
     i = 0
     IF (oihit > 0)
      oicnt = oi.comp_sequence
      IF (oicnt > size(orderrec->orderlist[ordcnt].actionlist[oacnt].subcomponentlist,5))
       stat = alterlist(orderrec->orderlist[ordcnt].actionlist[oacnt].subcomponentlist,oicnt)
      ENDIF
      orderrec->orderlist[ordcnt].actionlist[oacnt].subcomponentlist[oicnt].sccompsequence = oi
      .comp_sequence, orderrec->orderlist[ordcnt].actionlist[oacnt].subcomponentlist[oicnt].
      scfrequency = oi.freq_cd, orderrec->orderlist[ordcnt].actionlist[oacnt].subcomponentlist[oicnt]
      .sccatalogcd = oi.catalog_cd,
      orderrec->orderlist[ordcnt].actionlist[oacnt].subcomponentlist[oicnt].sccatalogtypecd = oi
      .catalog_type_cd, orderrec->orderlist[ordcnt].actionlist[oacnt].subcomponentlist[oicnt].
      scsynonymid = oi.synonym_id, orderrec->orderlist[ordcnt].actionlist[oacnt].subcomponentlist[
      oicnt].scordermnemonic = oi.order_mnemonic,
      orderrec->orderlist[ordcnt].actionlist[oacnt].subcomponentlist[oicnt].scorderdetaildisplayline
       = oi.order_detail_display_line, orderrec->orderlist[ordcnt].actionlist[oacnt].
      subcomponentlist[oicnt].scstrength = round(oi.strength,4), orderrec->orderlist[ordcnt].
      actionlist[oacnt].subcomponentlist[oicnt].scstrengthunit = oi.strength_unit,
      orderrec->orderlist[ordcnt].actionlist[oacnt].subcomponentlist[oicnt].scvolume = round(oi
       .volume,2), orderrec->orderlist[ordcnt].actionlist[oacnt].subcomponentlist[oicnt].scvolumeunit
       = oi.volume_unit, orderrec->orderlist[ordcnt].actionlist[oacnt].subcomponentlist[oicnt].
      scfreetextdose = oi.freetext_dose,
      orderrec->orderlist[ordcnt].actionlist[oacnt].subcomponentlist[oicnt].scivseq = oi.iv_seq
      IF (op_hit > 0)
       temp_idx = oi.comp_sequence
       IF (mi.med_identifier_type_cd=clabel)
        FOR (i = 1 TO cntr)
          IF ((op.item_id=orderrec->qual[i].item_id))
           orderrec->orderlist[ordcnt].sort_label_desc = substring(1,50,mi.value), i = cntr
          ENDIF
        ENDFOR
       ENDIF
       IF (mi.med_identifier_type_cd=cgeneric)
        orderrec->orderlist[ordcnt].actionlist[oacnt].subcomponentlist[temp_idx].scgenericname =
        substring(1,50,mi.value)
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   WITH nocounter, check, outerjoin = do4,
    outerjoin = ea, dontcare = ea
  ;end select
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(orderrec->orderlist,5))),
   order_detail od
  PLAN (d)
   JOIN (od
   WHERE (od.order_id=orderrec->orderlist[d.seq].orderid)
    AND od.oe_field_id IN (mf_dose_cd, mf_dose_unit_cd, mf_freq_cd, mf_vol_dose_cd,
   mf_vol_dose_unit_cd,
   mf_route_cd))
  ORDER BY od.order_id
  DETAIL
   IF (od.oe_field_id IN (mf_dose_cd, mf_vol_dose_cd))
    orderrec->orderlist[d.seq].s_dose = trim(od.oe_field_display_value)
   ELSEIF (od.oe_field_id IN (mf_dose_unit_cd, mf_vol_dose_unit_cd))
    orderrec->orderlist[d.seq].s_dose_unit = trim(od.oe_field_display_value)
   ELSEIF (od.oe_field_id=mf_freq_cd)
    orderrec->orderlist[d.seq].s_freq = trim(od.oe_field_display_value)
   ELSEIF (od.oe_field_id=mf_route_cd)
    orderrec->orderlist[d.seq].s_route = trim(od.oe_field_display_value)
   ENDIF
  WITH nocounter
 ;end select
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 SELECT INTO value( $OUTDEV)
  ps_facility = orderrec->orderlist[d.seq].facility, ps_loc = orderrec->orderlist[d.seq].loc_s,
  pf_encntr = orderrec->orderlist[d.seq].encntr_id,
  ps_label = orderrec->orderlist[d.seq].sort_label_desc, pf_order_id = orderrec->orderlist[d.seq].
  orderid
  FROM (dummyt d  WITH seq = value(size(orderrec->orderlist,5)))
  PLAN (d
   WHERE (orderrec->orderlist[d.seq].qualified="Y"))
  ORDER BY ps_facility, ps_loc, pf_encntr,
   ps_label, pf_order_id
  HEAD REPORT
   pl_col = 0, col pl_col, "Facility",
   pl_col = (pl_col+ 50), col pl_col, "Room_Bed",
   pl_col = (pl_col+ 50), col pl_col, "Name",
   pl_col = (pl_col+ 50), col pl_col, "Fin",
   pl_col = (pl_col+ 50), col pl_col, "Medication",
   pl_col = (pl_col+ 50), col pl_col, "Dose",
   pl_col = (pl_col+ 50), col pl_col, "Frequency",
   pl_col = (pl_col+ 50), col pl_col, "Route",
   pl_col = (pl_col+ 50), col pl_col, "Status",
   pl_col = (pl_col+ 50), col pl_col, "Start_dt_tm",
   pl_col = (pl_col+ 50), col pl_col, "Stop_dt_tm",
   pl_col = (pl_col+ 50), col pl_col, "Order_ID"
  DETAIL
   row + 1, pl_col = 0, col pl_col,
   orderrec->orderlist[d.seq].facility, pl_col = (pl_col+ 50), ms_tmp = concat(trim(orderrec->
     orderlist[d.seq].loc_room_s)," ",trim(orderrec->orderlist[d.seq].loc_bed_s)),
   col pl_col, ms_tmp, pl_col = (pl_col+ 50),
   col pl_col, orderrec->orderlist[d.seq].name, pl_col = (pl_col+ 50),
   col pl_col, orderrec->orderlist[d.seq].fin_nbr, pl_col = (pl_col+ 50),
   col pl_col, orderrec->orderlist[d.seq].s_hna_mnemonic, pl_col = (pl_col+ 50),
   ms_tmp = concat(orderrec->orderlist[d.seq].s_dose," ",orderrec->orderlist[d.seq].s_dose_unit), col
    pl_col, ms_tmp,
   pl_col = (pl_col+ 50), col pl_col, orderrec->orderlist[d.seq].s_freq,
   pl_col = (pl_col+ 50), col pl_col, orderrec->orderlist[d.seq].s_route,
   pl_col = (pl_col+ 50), ms_tmp = trim(uar_get_code_display(orderrec->orderlist[d.seq].order_status)
    ), col pl_col,
   ms_tmp, pl_col = (pl_col+ 50), ms_tmp = trim(format(orderrec->orderlist[d.seq].current_start_dt_tm,
     "mm/dd/yyyy hh:mm;;d")),
   col pl_col, ms_tmp, pl_col = (pl_col+ 50),
   ms_tmp = trim(format(orderrec->orderlist[d.seq].projected_stop_dt_tm,"mm/dd/yyyy hh:mm;;d")), col
   pl_col, ms_tmp,
   pl_col = (pl_col+ 50), ms_tmp = trim(cnvtstring(orderrec->orderlist[d.seq].orderid)), col pl_col,
   ms_tmp
  WITH nocounter, maxcol = 5000, format,
   separator = " "
 ;end select
 SELECT INTO "nl:"
  DETAIL
   row + 0
  WITH skipreport = value(1)
 ;end select
 SET printfile = "cer_print:rxadi.dat"
#exit_script
 IF (nerrorind=1)
  SET reply->status_data.status = "F"
 ELSEIF (curqual=0)
  SET reply->status_data.status = "Z"
  CALL echo(sno_qualify)
 ELSE
  SET reply->status_data.status = "S"
  CALL echo(csuccess)
 ENDIF
 CALL echo("Last MOD: 023")
 CALL echo("MOD Date: 09/19/2008")
END GO
