CREATE PROGRAM bbd_rpt_reinstated_donors:dba
 RECORD reply(
   1 report_name_list[*]
     2 report_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 sourceobjectname = c30
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c30
       3 targetobjectvalue = vc
       3 sourceobjectqual = i4
 )
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
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 RECORD captions(
   1 rpt_cerner_health_sys = vc
   1 rpt_title = vc
   1 rpt_time = vc
   1 rpt_date = vc
   1 begin_date = vc
   1 end_date = vc
   1 donor_id = vc
   1 social_security = vc
   1 number = vc
   1 full_name = vc
   1 home_phone = vc
   1 business_phone = vc
   1 last_donation = vc
   1 address = vc
   1 rpt_id = vc
   1 rpt_page = vc
   1 total_donors = vc
 )
 SET captions->rpt_cerner_health_sys = uar_i18ngetmessage(i18nhandle,"rpt_cerner_health_systems",
  "Cerner Health Systems")
 SET captions->rpt_title = uar_i18ngetmessage(i18nhandle,"rpt_title",
  "B L O O D   B A N K   R E I N S T A T E D   D O N O R S   R E P O R T")
 SET captions->rpt_time = uar_i18ngetmessage(i18nhandle,"rpt_time","Time:")
 SET captions->rpt_date = uar_i18ngetmessage(i18nhandle,"rpt_date","Date:")
 SET captions->begin_date = uar_i18ngetmessage(i18nhandle,"begin_date","Beginning Date:")
 SET captions->end_date = uar_i18ngetmessage(i18nhandle,"end_date","Ending Date:")
 SET captions->donor_id = uar_i18ngetmessage(i18nhandle,"donor_id","Donor ID")
 SET captions->social_security = uar_i18ngetmessage(i18nhandle,"social_security","Social Security")
 SET captions->number = uar_i18ngetmessage(i18nhandle,"number","     Number")
 SET captions->full_name = uar_i18ngetmessage(i18nhandle,"full_name","Full Name")
 SET captions->home_phone = uar_i18ngetmessage(i18nhandle,"home_phone","Home Phone")
 SET captions->business_phone = uar_i18ngetmessage(i18nhandle,"business_phone","Business Phone")
 SET captions->last_donation = uar_i18ngetmessage(i18nhandle,"last_donation","Last Donation")
 SET captions->address = uar_i18ngetmessage(i18nhandle,"address","Address:  ")
 SET captions->rpt_id = uar_i18ngetmessage(i18nhandle,"rpt_id","Report ID: BBD_RPT_REINSTATED_DONORS"
  )
 SET captions->rpt_page = uar_i18ngetmessage(i18nhandle,"rpt_page","Page:")
 SET captions->total_donors = uar_i18ngetmessage(i18nhandle,"total_donors",
  "Total Number of Donors:  ")
 RECORD current(
   1 system_dt_tm = dq8
 )
 SET code_cnt = 1
 SET home_phone_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(43,"HOME",code_cnt,home_phone_cd)
 IF (home_phone_cd=0.0)
  SET reply->status = "F"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_upd_reinstatement_elig.prg"
  SET reply->status_data.subeventstatus[1].operationname = "Update"
  SET reply->status_data.subeventstatus[1].targetobjectname = "uar_get_meaning_by_codeset"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Unable to retrieve code value for code set 43 and cdf meaning HOME."
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  GO TO exit_script
 ENDIF
 SET code_cnt = 1
 SET business_phone_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(43,"BUSINESS",code_cnt,business_phone_cd)
 IF (business_phone_cd=0)
  SET reply->status = "F"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_upd_reinstatement_elig.prg"
  SET reply->status_data.subeventstatus[1].operationname = "Update"
  SET reply->status_data.subeventstatus[1].targetobjectname = "uar_get_meaning_by_codeset"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Unable to retrieve code value for code set 43 and cdf meaning BUSINESS."
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  GO TO exit_script
 ENDIF
 SET code_cnt = 1
 SET question_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(1661,"BBDSSN",code_cnt,question_cd)
 IF (question_cd=0)
  SET reply->status = "F"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_upd_reinstatement_elig.prg"
  SET reply->status_data.subeventstatus[1].operationname = "Update"
  SET reply->status_data.subeventstatus[1].targetobjectname = "uar_get_meaning_by_codeset"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Unable to retrieve code value for code set 1661 and cdf meaning BBDSSN."
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  GO TO exit_script
 ENDIF
 SET code_cnt = 1
 SET answer_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(1659,"Y",code_cnt,answer_cd)
 IF (answer_cd=0)
  SET reply->status = "F"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_upd_reinstatement_elig.prg"
  SET reply->status_data.subeventstatus[1].operationname = "Update"
  SET reply->status_data.subeventstatus[1].targetobjectname = "uar_get_meaning_by_codeset"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Unable to retrieve code value for code set 1659 and cdf meaning Y."
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  GO TO exit_script
 ENDIF
 SET code_cnt = 1
 SET preference_cd = 0.0
 SELECT INTO "nl:"
  ans = a.answer
  FROM answer a
  WHERE a.question_cd=question_cd
   AND a.active_ind=1
  DETAIL
   IF (ans=cnvtstring(answer_cd))
    stat = uar_get_meaning_by_codeset(4,"SSN",code_cnt,preference_cd)
   ELSE
    stat = uar_get_meaning_by_codeset(4,"DONORID",code_cnt,preference_cd)
   ENDIF
  WITH nocounter
 ;end select
 IF (preference_cd=0)
  SET reply->status = "F"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_upd_reinstatement_elig.prg"
  SET reply->status_data.subeventstatus[1].operationname = "Update"
  SET reply->status_data.subeventstatus[1].targetobjectname = "uar_get_meaning_by_codeset"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Unable to retrieve cdf_meaning for preference answer."
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  GO TO exit_script
 ENDIF
 SET answer = uar_get_code_meaning(preference_cd)
 SET reply->status_data.status = "T"
 SET reply->status = "T"
 SET donor_number = 0
 SET line = fillstring(130,"-")
 SET report_complete_ind = "N"
 SET stat = alterlist(reply->report_name_list,1)
 SET sfiledate = format(curdate,"mmdd;;d")
 SET sfiletime = substring(1,6,format(curtime3,"hhmmss;;s"))
 SET sfilename = build("BBDrein",sfiledate,sfiletime)
 SET reply->report_name_list[1].report_name = concat("CER_TEMP:",trim(sfilename),".txt")
 SELECT INTO concat("CER_TEMP:",trim(sfilename),".txt")
  pd.person_id, pd.last_donation_dt_tm, state_display = substring(1,30,uar_get_code_display(a
    .state_cd)),
  country_display = substring(1,100,uar_get_code_display(a.country_cd)), city_display = substring(1,
   40,a.city), zip_display = substring(1,20,a.zipcode),
  name_display = substring(1,60,p.name_full_formatted), p.name_last_key, donor_nbr = substring(1,20,
   pa.alias),
  preference = substring(1,20,cnvtalias(pa.alias,ap.format_mask)), a.street_addr, a.street_addr2,
  a.street_addr3, a.street_addr4, ph.phone_num,
  ph2.phone_num
  FROM person_donor pd,
   person p,
   dummyt d2,
   address a,
   dummyt d3,
   person_alias pa,
   dummyt d4,
   alias_pool ap,
   dummyt d5,
   phone ph,
   phone ph2,
   dummyt d6
  PLAN (pd
   WHERE pd.last_donation_dt_tm < cnvtdatetime(request->end_dt_tm)
    AND pd.last_donation_dt_tm > cnvtdatetime(request->begin_dt_tm)
    AND pd.reinstated_ind=1
    AND pd.active_ind=1)
   JOIN (p
   WHERE p.person_id=pd.person_id
    AND p.active_ind=1)
   JOIN (d2)
   JOIN (a
   WHERE a.parent_entity_id=pd.person_id
    AND a.parent_entity_name="PERSON"
    AND a.active_ind=1)
   JOIN (d3)
   JOIN (pa
   WHERE pa.person_id=pd.person_id
    AND pa.person_alias_type_cd=preference_cd
    AND pa.active_ind=1)
   JOIN (d4)
   JOIN (ap
   WHERE ap.alias_pool_cd=pa.alias_pool_cd
    AND ap.active_ind=1)
   JOIN (d5)
   JOIN (ph
   WHERE ph.parent_entity_id=pd.person_id
    AND ph.phone_type_cd=home_phone_cd
    AND ph.parent_entity_name="PERSON"
    AND ph.active_ind=1)
   JOIN (d6)
   JOIN (ph2
   WHERE ph2.parent_entity_id=pd.person_id
    AND ph2.phone_type_cd=business_phone_cd
    AND ph2.parent_entity_name="PERSON"
    AND ph2.active_ind=1)
  ORDER BY p.name_last_key, pd.person_id
  HEAD PAGE
   beg_dt_tm = cnvtdatetime(request->begin_dt_tm), end_dt_tm = cnvtdatetime(request->end_dt_tm), col
   0,
   captions->rpt_cerner_health_sys,
   CALL center(captions->rpt_title,1,125), col 104,
   captions->rpt_time, col 118, curtime"@TIMENOSECONDS;;M",
   row + 1, col 104, captions->rpt_date,
   col 118, curdate"@DATECONDENSED;;d", row + 1,
   col 0, captions->begin_date, col + 2,
   beg_dt_tm"@DATECONDENSED;;d", col + 2, beg_dt_tm"@TIMENOSECONDS;;M",
   col + 2, captions->end_date, col + 2,
   end_dt_tm"@DATECONDENSED;;d", col + 2, end_dt_tm"@TIMENOSECONDS;;M"
   IF (answer="DONORID")
    row + 1, col 61, captions->donor_id
   ELSE
    row + 1, col 61, captions->social_security,
    row + 1, col 61, captions->number
   ENDIF
   col 0, captions->full_name, col 81,
   captions->home_phone, col 97, captions->business_phone,
   col 115, captions->last_donation, row + 1,
   col 0, "-----------------------------------------------------------", col 61,
   "------------------", col 81, "--------------",
   col 97, "----------------", col 115,
   "---------------", row + 1
  HEAD pd.person_id
   IF (row > 56)
    BREAK
   ENDIF
   donor_number = (donor_number+ 1), col 0, name_display
   IF (answer="DONORID")
    col 61, donor_nbr
   ELSE
    col 61, preference
   ENDIF
   IF (ph.phone_num != null)
    col 81, ph.phone_num"###############"
   ENDIF
   IF (ph2.phone_num != null)
    col 97, ph2.phone_num"###############"
   ENDIF
   col 115, pd.last_donation_dt_tm"MM/DD/YY"
   IF (((a.street_addr != null) OR (((a.street_addr2 != null) OR (((a.street_addr3 != null) OR (a
   .street_addr4 != null)) )) )) )
    row + 1
    IF (row > 56)
     BREAK
    ENDIF
    col 5, captions->address
   ENDIF
   IF (a.street_addr != null)
    col 15, a.street_addr
   ENDIF
   IF (a.street_addr2 != null)
    row + 1
    IF (row > 56)
     BREAK
    ENDIF
    col 15, a.street_addr2
   ENDIF
   IF (a.street_addr3 != null)
    row + 1
    IF (row > 56)
     BREAK
    ENDIF
    col 15, a.street_addr3
   ENDIF
   IF (a.street_addr4 != null)
    row + 1
    IF (row > 56)
     BREAK
    ENDIF
    col 15, a.street_addr4
   ENDIF
   city_state_zip_display = concat(trim(city_display),", ",trim(state_display)," ",zip_display)
   IF (city_state_zip_display != ",  ")
    row + 1
    IF (row > 56)
     BREAK
    ENDIF
    col 15, city_state_zip_display
   ENDIF
   IF (country_display != null)
    row + 1
    IF (row > 56)
     BREAK
    ENDIF
    col 15, country_display
   ENDIF
   counter = 0
  FOOT  pd.person_id
   row + 1, report_complete_ind = "Y"
  FOOT PAGE
   row 57, col 0, line,
   row + 1, col 0, captions->rpt_id,
   col 58, captions->rpt_page, col + 2,
   curpage"###"
  FOOT REPORT
   row 59, col 0, captions->total_donors,
   donor_number"#######"
  WITH nocounter, outerjoin = d2, outerjoin = d3,
   outerjoin = d4, outerjoin = d5, outerjoin = d6,
   dontcare = ph2, dontcare = ph, dontcare = ap,
   dontcare = pa, dontcare = a, compress,
   nolandscape, nullreport
 ;end select
 IF (report_complete_ind != "Y")
  SET reply->status = "F"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_rpt_reinstated_donors.prg"
  SET reply->status_data.subeventstatus[1].operationname = "Report"
  SET reply->status_data.subeventstatus[1].targetobjectname = "person_donor"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Error on printing reinstated donors report."
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  GO TO exit_script
 ENDIF
#exit_script
 IF ((reply->status="F"))
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
