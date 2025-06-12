CREATE PROGRAM ct_drv_pt_prescreened:dba
 RECORD reply(
   1 filename = vc
   1 node = vc
   1 prescreen_script_count = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD prescreenlistrequest(
   1 protocols[*]
     2 protocolid = f8
   1 person_id = f8
   1 statuslist[*]
     2 status_cd = f8
   1 org_security_ind = i2
   1 view_mode = i2
   1 start_dt_tm = dq8
   1 end_dt_tm = dq8
   1 eval_by = i2
   1 facilities[*]
     2 facility_cd = f8
   1 page_size = f8
   1 page_num = f8
   1 prescreen_type = i2
 )
 RECORD prescreenlistreply(
   1 prescreenlist[*]
     2 pt_prot_prescreen_id = f8
     2 prot_master_id = f8
     2 person_id = f8
     2 added_via_flag = i2
     2 last_name = vc
     2 first_name = vc
     2 full_name = vc
     2 birth_dt_tm = dq8
     2 sex_cd = f8
     2 race_cd = f8
     2 prot_alias = vc
     2 screening_dt_tm = dq8
     2 screener_person_id = f8
     2 screener_full_name = vc
     2 screening_status_cd = f8
     2 screening_status_disp = vc
     2 screening_status_desc = vc
     2 screening_status_mean = c12
     2 referral_dt_tm = dq8
     2 referral_person_id = f8
     2 referral_full_name = vc
     2 comment_text = vc
     2 reason_text = vc
     2 filename = vc
     2 displayable_docs_ind = i2
     2 cur_pt_elig_tracking_id = f8
     2 open_amendment_id = f8
     2 mrns[*]
       3 mrn = vc
       3 orgid = f8
       3 orgname = vc
       3 alias_pool_cd = f8
       3 alias_pool_disp = vc
       3 alias_pool_desc = vc
       3 alias_pool_mean = c12
   1 latest_prescreen_dt_tm = dq8
   1 latest_prescreen_person_id = f8
   1 latest_prescreen_full_name = vc
   1 pending_jobs = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 total_patients_cnt = f8
 )
 RECORD audit(
   1 qual[*]
     2 person_id = f8
 )
 RECORD contactinforequest(
   1 personlist[*]
     2 person_id = f8
   1 addresstypelist[*]
     2 address_type_cd = f8
   1 phonetypelist[*]
     2 phone_type_cd = f8
 )
 RECORD contactinforeply(
   1 contactinfolist[*]
     2 person_id = f8
     2 addresslist[*]
       3 address_type_cd = f8
       3 street_addr = vc
       3 street_addr2 = vc
       3 city = vc
       3 city_cd = f8
       3 state = vc
       3 state_cd = f8
       3 zipcode = vc
     2 phonelist[*]
       3 phone_type_cd = f8
       3 phone_format_cd = f8
       3 phone_num = vc
       3 extension = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD sysoutputrequest(
   1 output_dest_cd = f8
   1 file_name = vc
   1 copies = i4
   1 output_handle_id = f8
   1 number_of_copies = i4
   1 transmit_dt_tm = dq8
   1 priority_value = i4
   1 report_title = vc
   1 server = vc
   1 country_code = c3
   1 area_code = c10
   1 exchange = c10
   1 suffix = c50
 )
 RECORD sysoutputreply(
   1 sts = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE displayastable(null) = null WITH protect
 DECLARE displayascsv(null) = null WITH protect
 DECLARE printreport(null) = null WITH protect
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
 DECLARE i18nhandle = i4 WITH public, noconstant(0)
 SET stat = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 DECLARE prescreened_patients = vc WITH constant(uar_i18ngetmessage(i18nhandle,"PRESCREENED_PATIENTS",
   "Pre-Screened Patients"))
 DECLARE last_name = vc WITH constant(uar_i18ngetmessage(i18nhandle,"LAST_NAME","Last Name"))
 DECLARE first_name = vc WITH constant(uar_i18ngetmessage(i18nhandle,"FIRST_NAME","First Name"))
 DECLARE mrn = vc WITH constant(uar_i18ngetmessage(i18nhandle,"MRN","MRN"))
 DECLARE protocol_name = vc WITH constant(uar_i18ngetmessage(i18nhandle,"PROTOCOL_NAME",
   "Protocol Name"))
 DECLARE prescreened_status = vc WITH constant(uar_i18ngetmessage(i18nhandle,"PRESCREENED_STATUS",
   "Pre-Screened Status"))
 DECLARE added_via_discern = vc WITH constant(uar_i18ngetmessage(i18nhandle,"ADDED_VIA_DISCERN",
   "Discern"))
 DECLARE added_manual = vc WITH constant(uar_i18ngetmessage(i18nhandle,"ADDED_MANUAL","Manual"))
 DECLARE added_via_he = vc WITH constant(uar_i18ngetmessage(i18nhandle,"ADDED_VIA_HE","Health Expert"
   ))
 DECLARE added_via = vc WITH constant(uar_i18ngetmessage(i18nhandle,"ADDED_VIA","Added via"))
 DECLARE prescreened_by = vc WITH constant(uar_i18ngetmessage(i18nhandle,"PRESCREENED_BY",
   "Pre-Screened By"))
 DECLARE prescreened_date = vc WITH constant(uar_i18ngetmessage(i18nhandle,"PRESCREENED_DATE",
   "Pre-Screened Date"))
 DECLARE prescreened = vc WITH constant(uar_i18ngetmessage(i18nhandle,"PRESCREENED","Pre-Screened"))
 DECLARE referred_by = vc WITH constant(uar_i18ngetmessage(i18nhandle,"REFERRED_BY","Referred By"))
 DECLARE referred_date = vc WITH constant(uar_i18ngetmessage(i18nhandle,"REFERRED_DATE",
   "Referred Date"))
 DECLARE referred = vc WITH constant(uar_i18ngetmessage(i18nhandle,"REFERRED","Referred"))
 DECLARE time_stamp = vc WITH constant(uar_i18ngetmessage(i18nhandle,"TIME_STAMP",
   "Report execution time: "))
 DECLARE prot_for = vc WITH constant(" for")
 DECLARE address1 = vc WITH constant(uar_i18ngetmessage(i18nhandle,"ADDRESS1","Address line 1"))
 DECLARE address2 = vc WITH constant(uar_i18ngetmessage(i18nhandle,"ADDRESS2","Address line 2"))
 DECLARE city = vc WITH constant(uar_i18ngetmessage(i18nhandle,"CITY","City"))
 DECLARE state = vc WITH constant(uar_i18ngetmessage(i18nhandle,"STATE","State/Province"))
 DECLARE zip = vc WITH constant(uar_i18ngetmessage(i18nhandle,"ZIP","ZIP Code"))
 DECLARE address = vc WITH constant(uar_i18ngetmessage(i18nhandle,"ADDRESS","Address"))
 DECLARE phone = vc WITH constant(uar_i18ngetmessage(i18nhandle,"PHONE","Phone Number"))
 DECLARE ext = vc WITH constant(uar_i18ngetmessage(i18nhandle,"EXT","x"))
 DECLARE total = vc WITH constant(uar_i18ngetmessage(i18nhandle,"TOTAL",
   "Total Pre-screened Patients: "))
 DECLARE page_marker = vc WITH constant(uar_i18ngetmessage(i18nhandle,"PAGE_MARKER","Page"))
 DECLARE last_mod = c3 WITH private, noconstant(fillstring(3," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE protocolcnt = i4 WITH noconstant(size(request->protocollist,5))
 DECLARE filtercnt = i4 WITH noconstant(size(request->filterlist,5))
 DECLARE personcnt = i4 WITH noconstant(0)
 DECLARE holdfile = c40 WITH noconstant(build("CER_PRINT:","CT_VIEW_",cnvtstring(curtime3,6,0,r),
   ".DAT"))
 DECLARE facilitycnt = i4 WITH constant(size(request->facilities,5))
 DECLARE addedviastr = vc WITH protect
 DECLARE audit_mode = i2 WITH protect, constant(0)
 DECLARE auditcnt = i2 WITH protect, noconstant(0)
 DECLARE auditname = vc WITH protect
 DECLARE audittype = vc WITH protect
 DECLARE datalifecycle = vc WITH protect
 CALL logdebug("Beginning")
 IF (protocolcnt > 0)
  SET stat = alterlist(prescreenlistrequest->protocols,protocolcnt)
  FOR (i = 1 TO protocolcnt)
    SET prescreenlistrequest->protocols[i].protocolid = request->protocollist[i].prot_master_id
  ENDFOR
  SET stat = alterlist(prescreenlistrequest->statuslist,filtercnt)
  FOR (i = 1 TO filtercnt)
    SET prescreenlistrequest->statuslist[i].status_cd = request->filterlist[i].screening_status_cd
  ENDFOR
  SET prescreenlistrequest->org_security_ind = request->registryonlyind
  SET trace = recpersist
  IF (facilitycnt > 0)
   SET stat = alterlist(prescreenlistrequest->facilities,facilitycnt)
   FOR (i = 1 TO facilitycnt)
     SET prescreenlistrequest->facilities[i].facility_cd = request->facilities[i].facility_cd
   ENDFOR
   SET prescreenlistrequest->start_dt_tm = request->start_dt_tm
   SET prescreenlistrequest->end_dt_tm = request->end_dt_tm
   SET prescreenlistrequest->eval_by = request->eval_by
   CALL logdebug("Calling ct_get_filter_prescreen_list")
   EXECUTE ct_get_filter_prescreen_list  WITH replace("REQUEST","PRESCREENLISTREQUEST"), replace(
    "REPLY","PRESCREENLISTREPLY")
  ELSE
   CALL logdebug("Calling ct_get_pt_prescreen_list")
   EXECUTE ct_get_pt_prescreen_list  WITH replace("REQUEST","PRESCREENLISTREQUEST"), replace("REPLY",
    "PRESCREENLISTREPLY")
  ENDIF
  IF ((prescreenlistreply->status_data.status="F"))
   GO TO fail_script
  ENDIF
  SET personcnt = size(prescreenlistreply->prescreenlist,5)
  SET reply->prescreen_script_count = personcnt
  SET stat = alterlist(audit->qual,personcnt)
  FOR (auditcnt = 1 TO personcnt)
    SET audit->qual[auditcnt].person_id = prescreenlistreply->prescreenlist[auditcnt].person_id
  ENDFOR
  IF (personcnt > 0)
   IF ((request->contactinfoind=1))
    SET stat = alterlist(contactinforequest->personlist,personcnt)
    FOR (i = 1 TO personcnt)
      SET contactinforequest->personlist[i].person_id = prescreenlistreply->prescreenlist[i].
      person_id
    ENDFOR
    CALL logdebug("Calling ct_get_person_contact_info")
    EXECUTE ct_get_person_contact_info  WITH replace("REQUEST","CONTACTINFOREQUEST"), replace("REPLY",
     "CONTACTINFOREPLY")
   ENDIF
   IF ((request->formattypeind=1))
    CALL displayascsv(null)
   ELSE
    CALL displayastable(null)
   ENDIF
   IF ((request->outputdestcd > 0))
    CALL printreport(null)
   ELSE
    SET reply->filename = holdfile
    SET reply->node = curnode
   ENDIF
  ENDIF
 ENDIF
 SET reply->status_data[1].status = "S"
 GO TO exit_script
 SUBROUTINE (logdebug(message=vc) =null WITH protect)
   IF (validate(debug_ind,0) > 0)
    CALL echo(build("DEBUG - ct_drv_pt_prescreened:",message))
   ENDIF
 END ;Subroutine
 SUBROUTINE displayastable(null)
  CALL logdebug("Executing DisplayAsTable()")
  IF (personcnt > 0)
   DECLARE reporthead = vc WITH protect, noconstant(prescreened_patients)
   DECLARE executiontimestamp = vc WITH protect, noconstant(format(cnvtdatetime(curdate,curtime),
     "@SHORTDATETIME"))
   DECLARE mrncnt = i4 WITH protect, noconstant(0)
   DECLARE reportfoot = vc WITH protect, noconstant(concat(total," ",cnvtstring(personcnt)))
   DECLARE addressidx = i4 WITH protect, noconstant(0)
   DECLARE phoneidx = i4 WITH protect, noconstant(0)
   DECLARE citystring = vc WITH protect, noconstant("")
   DECLARE statestring = vc WITH protect, noconstant("")
   DECLARE lnamex = i4 WITH protect, noconstant(18)
   DECLARE fnamex = i4 WITH protect, noconstant(126)
   DECLARE mrnx = i4 WITH protect, noconstant(234)
   DECLARE protx = i4 WITH protect, noconstant(342)
   DECLARE statusx = i4 WITH protect, noconstant(450)
   DECLARE psx = i4 WITH protect, noconstant(0)
   DECLARE refx = i4 WITH protect, noconstant(563)
   DECLARE addx = i4 WITH protect, noconstant(0)
   DECLARE phonex = i4 WITH protect, noconstant(0)
   IF ((request->prescreen_type=0))
    SET psx = 563
    SET refx = 671
   ELSE
    SET refx = 563
   ENDIF
   DECLARE mrny = i4 WITH protect, noconstant(0)
   DECLARE addy = i4 WITH protect, noconstant(0)
   DECLARE psy = i4 WITH protect, noconstant(0)
   DECLARE refy = i4 WITH protect, noconstant(0)
   DECLARE phoney = i4 WITH protect, noconstant(0)
   DECLARE lnamemax = i4 WITH protect, noconstant(20)
   DECLARE fnamemax = i4 WITH protect, noconstant(20)
   DECLARE mrnmax = i4 WITH protect, noconstant(20)
   DECLARE protmax = i4 WITH protect, noconstant(20)
   DECLARE statusmax = i4 WITH protect, noconstant(21)
   DECLARE psmax = i4 WITH protect, noconstant(20)
   DECLARE refmax = i4 WITH protect, noconstant(20)
   DECLARE addmax = i4 WITH protect, noconstant(0)
   DECLARE phonemax = i4 WITH protect, noconstant(0)
   DECLARE temp = vc WITH protect, noconstant("")
   DECLARE estimate = i4 WITH protect, noconstant(0)
   DECLARE y = i4 WITH protect, noconstant(0)
   DECLARE charsperinch = vc WITH protect, noconstant("{CPI/14}")
   DECLARE lineheight = i4 WITH protect, noconstant(8)
   IF (protocolcnt=1)
    SET reporthead = concat(reporthead,prot_for," ",prescreenlistreply->prescreenlist[1].prot_alias)
   ENDIF
   IF ((request->contactinfoind > 0))
    SET lnamex = 18
    SET fnamex = 90
    SET mrnx = 162
    SET protx = 234
    SET statusx = 306
    IF ((request->prescreen_type=0))
     SET psx = 401
     SET refx = 496
     SET addx = 591
     SET phonex = 687
     SET psmax = 22
    ELSE
     SET refx = 401
     SET addx = 496
     SET phonex = 591
    ENDIF
    SET lnamemax = 17
    SET fnamemax = 17
    SET mrnmax = 17
    SET protmax = 17
    SET statusmax = 22
    SET refmax = 22
    SET addmax = 22
    SET phonemax = 18
    SET charsperinch = "{CPI/18}"
   ENDIF
   SET curalias person prescreenlistreply->prescreenlist[d.seq]
   SET curalias contact contactinforeply->contactinfolist[d.seq]
   SELECT INTO value(holdfile)
    lastnmsort = cnvtlower(substring(1,100,prescreenlistreply->prescreenlist[d.seq].last_name))
    FROM (dummyt d  WITH seq = value(personcnt))
    ORDER BY lastnmsort
    HEAD REPORT
     "{IPC}{PS/792 0 translate 90 rotate/}", row + 1, reporthead = concat("{CENTER/",reporthead,
      "/11/0}"),
     col 0, "{B}{CPI/10}", reporthead,
     row + 1
    HEAD PAGE
     temp = concat("{B}{CPI/20}",executiontimestamp,"{ENDB}{CPI/14}"),
     CALL print(calcpos(690,5)), temp,
     row + 1
     IF (curpage > 1)
      "{PS/792 0 translate 90 rotate/}", row + 1, y = 9
     ELSE
      y = 27
     ENDIF
     temp = limitstring(lnamemax,last_name), temp = concat("{B}",charsperinch,temp),
     CALL print(calcpos(lnamex,y)),
     temp, temp = limitstring(fnamemax,first_name),
     CALL print(calcpos(fnamex,y)),
     temp, temp = limitstring(mrnmax,mrn),
     CALL print(calcpos(mrnx,y)),
     temp, temp = limitstring(protmax,protocol_name),
     CALL print(calcpos(protx,y)),
     temp, temp = limitstring(statusmax,prescreened_status),
     CALL print(calcpos(statusx,y)),
     temp
     IF ((request->prescreen_type=0))
      temp = limitstring(psmax,prescreened),
      CALL print(calcpos(psx,y)), temp
     ENDIF
     temp = limitstring(refmax,referred),
     CALL print(calcpos(refx,y)), temp
     IF ((request->contactinfoind > 0))
      temp = limitstring(addmax,address),
      CALL print(calcpos(addx,y)), temp,
      temp = limitstring(phonemax,phone),
      CALL print(calcpos(phonex,y)), temp
     ENDIF
     row + 1, y += 2, temp = concat("{U}{CPI/14}",fillstring(148," "),"{ENDU}{ENDB}",charsperinch),
     CALL print(calcpos(13,y)), temp, row + 1,
     y += 10
    DETAIL
     IF (((y+ estimatedheight(d.seq,lineheight)) > 570))
      BREAK
     ENDIF
     temp = limitstring(lnamemax,prescreenlistreply->prescreenlist[d.seq].last_name),
     CALL print(calcpos(lnamex,y)), temp,
     temp = limitstring(fnamemax,prescreenlistreply->prescreenlist[d.seq].first_name),
     CALL print(calcpos(fnamex,y)), temp,
     mrncnt = size(prescreenlistreply->prescreenlist[d.seq].mrns,5), mrny = y
     FOR (i = 1 TO mrncnt)
       IF (i > 1)
        mrny += lineheight
       ENDIF
       IF (size(trim(prescreenlistreply->prescreenlist[d.seq].mrns[i].alias_pool_disp),1) > 0)
        temp = concat(prescreenlistreply->prescreenlist[d.seq].mrns[i].alias_pool_disp," - ",
         prescreenlistreply->prescreenlist[d.seq].mrns[i].mrn)
       ELSE
        temp = prescreenlistreply->prescreenlist[d.seq].mrns[i].mrn
       ENDIF
       temp = limitstring(mrnmax,temp),
       CALL print(calcpos(mrnx,mrny)), temp
     ENDFOR
     temp = limitstring(protmax,prescreenlistreply->prescreenlist[d.seq].prot_alias),
     CALL print(calcpos(protx,y)), temp,
     temp = limitstring(statusmax,uar_get_code_display(prescreenlistreply->prescreenlist[d.seq].
       screening_status_cd)),
     CALL print(calcpos(statusx,y)), temp
     IF ((request->prescreen_type=0))
      temp = limitstring(psmax,prescreenlistreply->prescreenlist[d.seq].screener_full_name),
      CALL print(calcpos(psx,y)), temp,
      psy = (y+ lineheight), temp = limitstring(psmax,format(prescreenlistreply->prescreenlist[d.seq]
        .screening_dt_tm,"@SHORTDATE")),
      CALL print(calcpos(psx,psy)),
      temp
     ENDIF
     temp = limitstring(refmax,prescreenlistreply->prescreenlist[d.seq].referral_full_name),
     CALL print(calcpos(refx,y)), temp,
     refy = (y+ lineheight), temp = limitstring(refmax,format(prescreenlistreply->prescreenlist[d.seq
       ].referral_dt_tm,"@SHORTDATE")),
     CALL print(calcpos(refx,refy)),
     temp, addy = y, phoney = y
     IF ((request->contactinfoind > 0))
      addressidx = getaddressindex(d.seq), phoneidx = getphoneindex(d.seq)
      IF (addressidx > 0)
       IF ((contactinforeply->contactinfolist[d.seq].addresslist[addressidx].city_cd > 0))
        citystring = uar_get_code_display(contactinforeply->contactinfolist[d.seq].addresslist[
         addressidx].city_cd)
       ELSE
        citystring = contactinforeply->contactinfolist[d.seq].addresslist[addressidx].city
       ENDIF
       IF ((contactinforeply->contactinfolist[d.seq].addresslist[addressidx].state_cd > 0))
        statestring = uar_get_code_display(contactinforeply->contactinfolist[d.seq].addresslist[
         addressidx].state_cd)
       ELSE
        statestring = contactinforeply->contactinfolist[d.seq].addresslist[addressidx].state
       ENDIF
       temp = limitstring(addmax,contactinforeply->contactinfolist[d.seq].addresslist[addressidx].
        street_addr),
       CALL print(calcpos(addx,addy)), temp,
       temp = limitstring(addmax,contactinforeply->contactinfolist[d.seq].addresslist[addressidx].
        street_addr2)
       IF (textlen(temp) > 0)
        addy += lineheight,
        CALL print(calcpos(addx,addy)), temp
       ENDIF
       addy += lineheight, temp = limitstring(addmax,citystring),
       CALL print(calcpos(addx,addy)),
       temp, addy += lineheight, temp = limitstring(addmax,statestring),
       CALL print(calcpos(addx,addy)), temp, addy += lineheight,
       temp = limitstring(addmax,contactinforeply->contactinfolist[d.seq].addresslist[addressidx].
        zipcode),
       CALL print(calcpos(addx,addy)), temp
      ENDIF
      IF (phoneidx > 0)
       temp = cnvtphone(contactinforeply->contactinfolist[d.seq].phonelist[phoneidx].phone_num,
        contactinforeply->contactinfolist[d.seq].phonelist[phoneidx].phone_format_cd), temp =
       limitstring(phonemax,temp),
       CALL print(calcpos(phonex,phoney)),
       temp
       IF (textlen(contactinforeply->contactinfolist[d.seq].phonelist[phoneidx].extension) > 0)
        phoney += lineheight, temp = concat(ext,contactinforeply->contactinfolist[d.seq].phonelist[
         phoneidx].extension), temp = limitstring(phonemax,temp),
        CALL print(calcpos(phonex,phoney)), temp
       ENDIF
      ENDIF
     ENDIF
     row + 1
     IF ((request->prescreen_type=0))
      y = (maxval(mrny,psy,refy,addy,phoney)+ (lineheight * 1.5))
     ELSE
      y = (maxval(mrny,refy,addy,phoney)+ (lineheight * 1.5))
     ENDIF
    FOOT PAGE
     temp = concat("{B}{CPI/20}",page_marker," ",trim(cnvtstring(curpage)),"{ENDB}{CPI/14}"),
     CALL print(calcpos(740,580)), temp,
     row + 1
    FOOT REPORT
     y -= (lineheight/ 2), temp = concat("{U}{B}",fillstring(148," "),"{ENDU}"),
     CALL print(calcpos(13,y)),
     temp, y += 10, temp = concat(reportfoot,"{ENDB}"),
     CALL print(calcpos(525,y)), temp, row + 1
    WITH dio = postscript, maxcol = 3000
   ;end select
  ENDIF
 END ;Subroutine
 SUBROUTINE displayascsv(null)
  CALL logdebug("Executing DisplayAsCSV()")
  IF (personcnt > 0)
   DECLARE reporthead = vc WITH protect, noconstant(concat('"',prescreened_patients))
   DECLARE comma = vc WITH protect, constant('","')
   DECLARE columnheaders = vc WITH protect
   IF ((request->prescreen_type=0))
    SET columnheaders = concat('"',last_name,comma,first_name,comma,
     mrn,comma,protocol_name,comma,prescreened_status,
     comma,added_via,comma,prescreened_by,comma,
     prescreened_date,comma,referred_by,comma,referred_date)
   ELSE
    SET columnheaders = concat('"',last_name,comma,first_name,comma,
     mrn,comma,protocol_name,comma,prescreened_status,
     comma,added_via,comma,referred_by,comma,
     referred_date)
   ENDIF
   DECLARE executiontimestamp = vc WITH protect, noconstant(concat('"',time_stamp," ",format(
      cnvtdatetime(curdate,curtime),"@SHORTDATETIME"),'"'))
   DECLARE persondata = vc WITH protect, noconstant("")
   DECLARE mrncnt = i4 WITH protect, noconstant(0)
   DECLARE reportfoot = vc WITH protect, noconstant(concat('"',total," ",trim(cnvtstring(personcnt)),
     '"'))
   DECLARE addressidx = i4 WITH protect, noconstant(0)
   DECLARE phoneidx = i4 WITH protect, noconstant(0)
   DECLARE statestring = vc WITH protect, noconstant("")
   IF (protocolcnt=1)
    SET reporthead = concat(reporthead,prot_for," ",prescreenlistreply->prescreenlist[1].prot_alias)
   ENDIF
   SET reporthead = concat(reporthead,'"')
   IF ((request->contactinfoind > 0))
    SET columnheaders = concat(columnheaders,comma,address1,comma,address2,
     comma,city,comma,state,comma,
     zip,comma,phone)
   ENDIF
   SET columnheaders = concat(columnheaders,'"')
   SET curalias person prescreenlistreply->prescreenlist[d.seq]
   SET curalias contact contactinforeply->contactinfolist[d.seq]
   SELECT INTO value(holdfile)
    lastnmsort = cnvtlower(substring(1,100,prescreenlistreply->prescreenlist[d.seq].last_name))
    FROM (dummyt d  WITH seq = value(personcnt))
    ORDER BY lastnmsort
    HEAD REPORT
     col 0, reporthead, row + 1,
     col 0, executiontimestamp, row + 2,
     col 0, columnheaders
    DETAIL
     persondata = concat('"',prescreenlistreply->prescreenlist[d.seq].last_name,comma,
      prescreenlistreply->prescreenlist[d.seq].first_name,comma), mrncnt = size(prescreenlistreply->
      prescreenlist[d.seq].mrns,5)
     IF (mrncnt > 0)
      FOR (i = 1 TO mrncnt)
       persondata = concat(persondata,";"),
       IF (size(trim(prescreenlistreply->prescreenlist[d.seq].mrns[i].alias_pool_disp),1) > 0)
        persondata = concat(persondata,prescreenlistreply->prescreenlist[d.seq].mrns[i].
         alias_pool_disp," - ",prescreenlistreply->prescreenlist[d.seq].mrns[i].mrn)
       ELSE
        persondata = concat(persondata,prescreenlistreply->prescreenlist[d.seq].mrns[i].mrn)
       ENDIF
      ENDFOR
     ENDIF
     CASE (prescreenlistreply->prescreenlist[d.seq].added_via_flag)
      OF 0:
       addedviastr = added_via_discern
      OF 1:
       addedviastr = added_manual
      OF 2:
       addedviastr = added_via_he
     ENDCASE
     IF ((request->prescreen_type=0))
      persondata = concat(persondata,comma,prescreenlistreply->prescreenlist[d.seq].prot_alias,comma,
       trim(uar_get_code_display(prescreenlistreply->prescreenlist[d.seq].screening_status_cd)),
       comma,addedviastr,comma,prescreenlistreply->prescreenlist[d.seq].screener_full_name,comma,
       format(prescreenlistreply->prescreenlist[d.seq].screening_dt_tm,"@SHORTDATETIME"),comma,
       prescreenlistreply->prescreenlist[d.seq].referral_full_name,comma,format(prescreenlistreply->
        prescreenlist[d.seq].referral_dt_tm,"@SHORTDATETIME"))
     ELSE
      persondata = concat(persondata,comma,prescreenlistreply->prescreenlist[d.seq].prot_alias,comma,
       trim(uar_get_code_display(prescreenlistreply->prescreenlist[d.seq].screening_status_cd)),
       comma,addedviastr,comma,prescreenlistreply->prescreenlist[d.seq].referral_full_name,comma,
       format(prescreenlistreply->prescreenlist[d.seq].referral_dt_tm,"@SHORTDATETIME"))
     ENDIF
     IF ((request->contactinfoind > 0))
      addressidx = getaddressindex(d.seq), phoneidx = getphoneindex(d.seq)
      IF (addressidx > 0)
       IF ((contactinforeply->contactinfolist[d.seq].addresslist[addressidx].city_cd > 0))
        citystring = uar_get_code_display(contactinforeply->contactinfolist[d.seq].addresslist[
         addressidx].city_cd)
       ELSE
        citystring = contactinforeply->contactinfolist[d.seq].addresslist[addressidx].city
       ENDIF
       IF ((contactinforeply->contactinfolist[d.seq].addresslist[addressidx].state_cd > 0))
        statestring = uar_get_code_display(contactinforeply->contactinfolist[d.seq].addresslist[
         addressidx].state_cd)
       ELSE
        statestring = contactinforeply->contactinfolist[d.seq].addresslist[addressidx].state
       ENDIF
       persondata = concat(persondata,comma,contactinforeply->contactinfolist[d.seq].addresslist[
        addressidx].street_addr,comma,contactinforeply->contactinfolist[d.seq].addresslist[addressidx
        ].street_addr2,
        comma,trim(citystring),comma,trim(statestring),comma,
        contactinforeply->contactinfolist[d.seq].addresslist[addressidx].zipcode,comma)
      ELSE
       FOR (i = 1 TO 6)
         persondata = concat(persondata,comma)
       ENDFOR
      ENDIF
      IF (phoneidx > 0)
       persondata = concat(persondata,cnvtphone(contactinforeply->contactinfolist[d.seq].phonelist[
         phoneidx].phone_num,contactinforeply->contactinfolist[d.seq].phonelist[phoneidx].
         phone_format_cd))
       IF (textlen(contactinforeply->contactinfolist[d.seq].phonelist[phoneidx].extension) > 0)
        persondata = concat(persondata," ",ext,contactinforeply->contactinfolist[d.seq].phonelist[
         phoneidx].extension)
       ENDIF
      ENDIF
     ENDIF
     persondata = concat(persondata,'"'), row + 1, col 0,
     persondata
    FOOT REPORT
     row + 2, col 0, reportfoot
    WITH format = crstream, formfeed = none, maxcol = 1500,
     nocounter
   ;end select
  ENDIF
 END ;Subroutine
 SUBROUTINE (getaddressindex(personindex=i4) =i4 WITH protect)
   CALL logdebug("Executing GetAddressIndex()")
   DECLARE completeidx = i4 WITH protect, noconstant(0)
   DECLARE incompleteidx = i4 WITH protect, noconstant(0)
   IF (personcnt >= personindex
    AND size(contactinforeply->contactinfolist,5) >= personindex)
    SET curalias contactinfo contactinforeply->contactinfolist[personindex]
    DECLARE addresscnt = i4 WITH protect, noconstant(size(contactinfo->addresslist,5))
    DECLARE temppriority = i4 WITH protect, noconstant(0)
    DECLARE curhighestpriority = i4 WITH protect, noconstant(0)
    DECLARE check = i2 WITH protect, noconstant(0)
    IF (addresscnt > 0)
     FOR (i = 1 TO addresscnt)
      SET check = checkaddress(personindex,i)
      IF (check=1)
       IF (completeidx=0)
        SET completeidx = i
       ELSE
        SET temppriority = getaddresstypepriority(contactinfo->addresslist[i].address_type_cd)
        SET curhighestpriority = getaddresstypepriority(contactinfo->addresslist[completeidx].
         address_type_cd)
        IF (temppriority < curhighestpriority)
         SET completeidx = i
        ENDIF
       ENDIF
      ELSEIF (check=0)
       IF (incompleteidx=0)
        SET incompleteidx = i
       ELSE
        SET temppriority = getaddresstypepriority(contactinfo->addresslist[i].address_type_cd)
        SET curhighestpriority = getaddresstypepriority(contactinfo->addresslist[incompleteidx].
         address_type_cd)
        IF (temppriority < curhighestpriority)
         SET incompleteidx = i
        ENDIF
       ENDIF
      ENDIF
     ENDFOR
    ENDIF
   ENDIF
   IF (completeidx > 0)
    RETURN(completeidx)
   ELSEIF (incompleteidx > 0)
    RETURN(incompleteidx)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (getaddresstypepriority(typecd=f8) =i4 WITH protect)
   CALL logdebug("Executing GetAddressTypePriority()")
   DECLARE result = i2 WITH protect, noconstant(0)
   DECLARE home_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",212,"HOME"))
   DECLARE mailing_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",212,"MAILING"))
   DECLARE business_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",212,"BUSINESS"))
   CASE (typecd)
    OF home_cd:
     SET result = 1
    OF mailing_cd:
     SET result = 2
    OF business_cd:
     SET result = 3
    ELSE
     SET result = 100
   ENDCASE
   RETURN(result)
 END ;Subroutine
 SUBROUTINE (getphoneindex(personindex=i4) =i4 WITH protect)
   CALL logdebug("Executing GetPhoneIndex()")
   DECLARE phoneidx = i4 WITH protect, noconstant(0)
   IF (personcnt >= personindex
    AND size(contactinforeply->contactinfolist,5) >= personindex)
    SET curalias contactinfo contactinforeply->contactinfolist[personindex]
    DECLARE phonecnt = i4 WITH protect, noconstant(size(contactinfo->phonelist,5))
    DECLARE temppriority = i4 WITH protect, noconstant(0)
    DECLARE curhighestpriority = i4 WITH protect, noconstant(0)
    IF (phonecnt > 0)
     SET phoneidx = 1
     SET curalias tempphone contactinforeply->contactinfolist[personindex].phonelist[i]
     SET curalias curphone contactinforeply->contactinfolist[personindex].phonelist[phoneidx]
     FOR (i = 2 TO phonecnt)
       SET temppriority = getphonetypepriority(tempphone->phone_type_cd)
       SET curhighestpriority = getphonetypepriority(curphone->phone_type_cd)
       IF (temppriority < curhighestpriority)
        SET phoneidx = i
       ENDIF
     ENDFOR
     SET curalias tempphone off
     SET curalias curphone off
    ENDIF
    SET curalias contactinfo off
   ENDIF
   RETURN(phoneidx)
 END ;Subroutine
 SUBROUTINE (getphonetypepriority(typecd=f8) =i4 WITH protect)
   CALL logdebug("Executing GetPhoneTypePriority()")
   DECLARE result = i2 WITH protect, noconstant(0)
   DECLARE home_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",43,"HOME"))
   DECLARE mobile_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",43,"MOBILE"))
   DECLARE cell_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",43,"CELL"))
   DECLARE business_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",43,"BUSINESS"))
   CASE (typecd)
    OF home_cd:
     SET result = 1
    OF mobile_cd:
     SET result = 2
    OF cell_cd:
     SET result = 3
    OF business_cd:
     SET result = 4
    ELSE
     SET result = 100
   ENDCASE
   RETURN(result)
 END ;Subroutine
 SUBROUTINE (limitstring(maxlength=i4,string=vc) =vc WITH protect)
   CALL logdebug("Executing LimitString()")
   DECLARE result = vc WITH protect, noconstant(trim(nullterm(string)))
   IF (textlen(result) > maxlength)
    SET result = concat(trim(substring(1,(maxlength - 3),string)),"...")
   ENDIF
   RETURN(result)
 END ;Subroutine
 SUBROUTINE (estimatedheight(ptindex=i4,lineheight=i4) =i4 WITH protect)
   CALL logdebug("Executing EstimatedHeight()")
   DECLARE min_height = i4 WITH protect, constant((2 * lineheight))
   DECLARE estimate = i4 WITH protect, noconstant(0)
   DECLARE addressidx = i4 WITH protect, noconstant(0)
   DECLARE addressestimate = i4 WITH protect, noconstant(0)
   DECLARE mrnestimate = i4 WITH protect, noconstant(0)
   IF (ptindex <= personcnt)
    IF ((request->contactinfoind > 0))
     SET addressidx = getaddressindex(ptindex)
     IF (addressidx > 0)
      IF (textlen(trim(contactinforeply->contactinfolist[ptindex].addresslist[addressidx].
        street_addr2)) > 0)
       SET addressestimate = (6 * lineheight)
      ELSE
       SET addressestimate = (5 * lineheight)
      ENDIF
     ENDIF
    ENDIF
    SET mrnestimate = (size(prescreenlistreply->prescreenlist[ptindex].mrns,5) * lineheight)
    SET estimate = maxval(min_height,mrnestimate,addressestimate)
   ENDIF
   RETURN(estimate)
 END ;Subroutine
 SUBROUTINE printreport(null)
   CALL logdebug("Executing PrintReport()")
   DECLARE reporthead = vc WITH protect, noconstant(prescreened_patients)
   IF (protocolcnt=1)
    SET reporthead = concat(reporthead,prot_for," ",prescreenlistreply->prescreenlist[1].prot_alias)
   ENDIF
   SET ct_request_struct->file_name = holdfile
   SET ct_request_struct->output_dest_cd = request->outputdestcd
   SET ct_request_struct->copies = 1
   SET ct_request_struct->number_of_copies = 1
   SET ct_request_struct->transmit_dt_tm = cnvtdatetime(sysdate)
   SET ct_request_struct->priority_value = 0
   SET ct_request_struct->report_title = reporthead
   SET ct_request_struct->country_code = " "
   SET ct_request_struct->area_code = " "
   SET ct_request_struct->exchange = " "
   SET ct_request_struct->suffix = " "
   EXECUTE sys_outputdest_print  WITH replace("REQUEST","SYSOUTPUTREQUEST"), replace("REPLY",
    "SYSOUTPUTREPLY")
   IF ((ct_reply_struct->sts=1))
    COMMIT
   ELSE
    GO TO fail_script
   ENDIF
 END ;Subroutine
 SUBROUTINE (checkaddress(ptindex=i4,addressidx=i4) =i2 WITH protect)
   CALL logdebug("Executing CheckAddress()")
   DECLARE result = i1 WITH private, noconstant(- (1))
   IF (ptindex <= personcnt
    AND addressidx > 0)
    IF (textlen(trim(contactinforeply->contactinfolist[ptindex].addresslist[addressidx].street_addr))
     > 0
     AND ((textlen(trim(contactinforeply->contactinfolist[ptindex].addresslist[addressidx].city)) > 0
    ) OR ((contactinforeply->contactinfolist[ptindex].addresslist[addressidx].city_cd > 0)))
     AND ((textlen(trim(contactinforeply->contactinfolist[ptindex].addresslist[addressidx].state)) >
    0) OR ((contactinforeply->contactinfolist[ptindex].addresslist[addressidx].state_cd > 0)))
     AND textlen(trim(contactinforeply->contactinfolist[ptindex].addresslist[addressidx].zipcode)) >
    0)
     SET result = 1
    ELSEIF (((textlen(trim(contactinforeply->contactinfolist[ptindex].addresslist[addressidx].
      street_addr)) > 0) OR (((((textlen(trim(contactinforeply->contactinfolist[ptindex].addresslist[
      addressidx].city)) > 0) OR ((contactinforeply->contactinfolist[ptindex].addresslist[addressidx]
    .city_cd > 0))) ) OR (((((textlen(trim(contactinforeply->contactinfolist[ptindex].addresslist[
      addressidx].state)) > 0) OR ((contactinforeply->contactinfolist[ptindex].addresslist[addressidx
    ].state_cd > 0))) ) OR (textlen(trim(contactinforeply->contactinfolist[ptindex].addresslist[
      addressidx].zipcode)) > 0)) )) )) )
     SET result = 0
    ENDIF
   ENDIF
   RETURN(result)
 END ;Subroutine
 GO TO exit_script
#fail_script
 SET reply->status_data[1].status = "F"
#exit_script
 IF ((reply->status_data[1].status="S"))
  IF ((request->print_ind=0))
   SET auditname = "Prescreen_PrintPreview"
   SET audittype = "View"
   SET datalifecycle = "Access/Use"
  ELSEIF ((request->print_ind=1))
   SET auditname = "Prescreened_Print"
   SET audittype = "Print"
   SET datalifecycle = "Report"
  ENDIF
  FOR (auditcnt = 1 TO personcnt)
    EXECUTE cclaudit audit_mode, auditname, audittype,
    "Person", "Patient", "Patient",
    datalifecycle, audit->qual[auditcnt].person_id, ""
  ENDFOR
 ENDIF
 SET last_mod = "002"
 SET mod_date = "May 20, 2019"
END GO
