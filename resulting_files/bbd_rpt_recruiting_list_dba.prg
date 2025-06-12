CREATE PROGRAM bbd_rpt_recruiting_list:dba
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
   1 rpt_as_of_date = vc
   1 donor_id = vc
   1 ssn = vc
   1 name = vc
   1 phone = vc
   1 donation_info = vc
   1 abo_rh = vc
   1 home = vc
   1 unknown = vc
   1 address = vc
   1 bus = vc
   1 rpt_id = vc
   1 rpt_page = vc
 )
 SET captions->rpt_cerner_health_sys = uar_i18ngetmessage(i18nhandle,"rpt_cerner_health_systems",
  "Cerner Health Systems")
 SET captions->rpt_title = uar_i18ngetmessage(i18nhandle,"rpt_title",
  "R E C R U I T I N G   L I S T   R E P O R T")
 SET captions->rpt_time = uar_i18ngetmessage(i18nhandle,"rpt_time","Time:")
 SET captions->rpt_as_of_date = uar_i18ngetmessage(i18nhandle,"rpt_as_of_date","As of Date:")
 SET captions->donor_id = uar_i18ngetmessage(i18nhandle,"donor_id","Donor ID")
 SET captions->ssn = uar_i18ngetmessage(i18nhandle,"ssn","SSN")
 SET captions->name = uar_i18ngetmessage(i18nhandle,"name","Name - ")
 SET captions->phone = uar_i18ngetmessage(i18nhandle,"phone","Phone")
 SET captions->donation_info = uar_i18ngetmessage(i18nhandle,"donation_info","Donation Info")
 SET captions->abo_rh = uar_i18ngetmessage(i18nhandle,"abo_rh","ABO/RH")
 SET captions->home = uar_i18ngetmessage(i18nhandle,"home","Home: ")
 SET captions->unknown = uar_i18ngetmessage(i18nhandle,"unknown","(unknown)")
 SET captions->address = uar_i18ngetmessage(i18nhandle,"address","Address")
 SET captions->bus = uar_i18ngetmessage(i18nhandle,"bus","Bus: ")
 SET captions->rpt_id = uar_i18ngetmessage(i18nhandle,"rpt_id","Report ID: BBD_RPT_RECRUITING_LIST")
 SET captions->rpt_page = uar_i18ngetmessage(i18nhandle,"rpt_page","Page:")
 RECORD current(
   1 system_dt_tm = dq8
 )
 SET current->system_dt_tm = cnvtdatetime(curdate,curtime3)
 SET reply->status_data.status = "T"
 SET failed = "F"
 SET acount = size(request->antigen,5)
 SET zcount = size(request->zipcode,5)
 SET aliascount = 0
 SET antigencount = 0
 SET antibodycount = 0
 SET maiden_name_cd = 0.0
 SET preference_cd = 0.0
 SET phone_num_cd = 0.0
 SET bus_phone_num_cd = 0.0
 SET one_cd = 0.0
 SET two_cd = 0.0
 SET three_cd = 0.0
 SET four_cd = 0.0
 SET five_cd = 0.0
 SET six_cd = 0.0
 SET seven_cd = 0.0
 SET eight_cd = 0.0
 SET nine_cd = 0.0
 SET ten_cd = 0.0
 SET eleven_cd = 0.0
 SET twelve_cd = 0.0
 SET thirteen_cd = 0.0
 SET fourteen_cd = 0.0
 SET fifteen_cd = 0.0
 SET temp_cd = 0.0
 SET permnent_cd = 0.0
 SET name_cd = 0.0
 SET cdf_mean = fillstring(12," ")
 SET code_set = 0
 SET line = fillstring(130,"-")
 SET addline = 0
 SET sfiledate = format(curdate,"mmdd;;d")
 SET sfiletime = substring(1,6,format(curtime3,"hhmmss;;s"))
 SET sfilename = build("bbdrec",sfiledate,sfiletime)
 DECLARE days_until_eligible = i4 WITH protect
 SET stat = alterlist(reply->report_name_list,1)
 SET reply->report_name_list[1].report_name = concat("CER_TEMP:",sfilename,".txt")
 SET code_set = 4
 SET code_cnt = 1
 IF ((request->preference_ind="Y"))
  SET cdf_mean = "SSN"
 ELSE
  SET cdf_mean = "DONORID"
 ENDIF
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,code_cnt,preference_cd)
 SET code_set = 213
 SET code_cnt = 1
 SET cdf_mean = "CURRENT"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,code_cnt,name_cd)
 SET code_set = 43
 SET cdf_mean = "HOME"
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,code_cnt,phone_num_cd)
 SET cdf_mean = "BUSINESS"
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,code_cnt,bus_phone_num_cd)
 IF (((preference_cd=0.0) OR (((name_cd=0.0) OR (((phone_num_cd=0.0) OR (bus_phone_num_cd=0.0)) ))
 )) )
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_rpt_recruiting_list.prg"
  SET reply->status_data.subeventstatus[1].operationname = "Select"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE"
  IF (preference_cd=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to read temporary eligibility type code value"
  ELSEIF (name_cd=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "Unable to read name type code value"
  ELSEIF (phone_num_cd=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to read home phone number code value"
  ELSE
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to read business phone number code value"
  ENDIF
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  GO TO exit_script
 ENDIF
 IF ((request->person_id > 0))
  SELECT INTO concat("CER_TEMP:",sfilename,".txt")
   first_display = substring(1,20,pn.name_first), last_display = substring(1,30,pn.name_last),
   last_donation = substring(1,20,uar_get_code_display(dr.procedure_cd)),
   eligibility_type = substring(1,20,uar_get_code_display(pd.eligibility_type_cd)), pd
   .last_donation_dt_tm, abo_display = substring(1,10,uar_get_code_display(pa.abo_cd)),
   rh_display = substring(1,10,uar_get_code_display(pa.rh_cd)), ad.street_addr, ad.street_addr2,
   state_display = substring(1,30,ad.state), country_display = substring(1,100,uar_get_code_display(
     ad.country_cd)), city_display = substring(1,40,ad.city),
   zip_display = substring(1,20,ad.zipcode), ssn = substring(1,20,cnvtalias(a.alias,ap.format_mask)),
   preference = substring(1,20,a.alias),
   phone_display = substring(1,15,ph.phone_num), phone_display2 = substring(1,15,ph2.phone_num)
   FROM person_donor pd,
    bbd_donation_results dr,
    dummyt d1,
    person_aborh pa,
    dummyt d2,
    person_name pn,
    dummyt d3,
    address ad,
    dummyt d4,
    phone ph,
    dummyt d5,
    phone ph2,
    dummyt d6,
    person_alias a,
    dummyt d7,
    alias_pool ap
   PLAN (pd
    WHERE (pd.person_id=request->person_id)
     AND pd.active_ind=1)
    JOIN (dr
    WHERE dr.person_id=pd.person_id
     AND dr.drawn_dt_tm=pd.last_donation_dt_tm
     AND dr.active_ind=1)
    JOIN (d1)
    JOIN (pa
    WHERE pa.person_id=pd.person_id
     AND pa.active_ind=1)
    JOIN (d2)
    JOIN (pn
    WHERE pn.person_id=pd.person_id
     AND pn.name_type_cd=name_cd
     AND pn.active_ind=1)
    JOIN (d3)
    JOIN (ph
    WHERE ph.parent_entity_id=pd.person_id
     AND ph.phone_type_cd=phone_num_cd
     AND ph.parent_entity_name="PERSON"
     AND ph.active_ind=1)
    JOIN (d4)
    JOIN (ph2
    WHERE ph2.parent_entity_id=pd.person_id
     AND ph2.phone_type_cd=bus_phone_num_cd
     AND ph2.parent_entity_name="PERSON"
     AND ph2.active_ind=1)
    JOIN (d5)
    JOIN (ad
    WHERE ad.parent_entity_id=pd.person_id
     AND ad.parent_entity_name="PERSON"
     AND ad.active_ind=1)
    JOIN (d6)
    JOIN (a
    WHERE a.person_id=pd.person_id
     AND a.person_alias_type_cd=preference_cd
     AND a.active_ind=1)
    JOIN (d7)
    JOIN (ap
    WHERE ap.alias_pool_cd=a.alias_pool_cd
     AND ap.active_ind=1)
   ORDER BY pd.person_id
   HEAD PAGE
    col 0, captions->rpt_cerner_health_sys,
    CALL center(captions->rpt_title,1,130),
    col 104, captions->rpt_time, col 118,
    curtime"@TIMENOSECONDS;;M", row + 1, col 104,
    captions->rpt_as_of_date, col 118, curdate"@DATECONDENSED;;d",
    row + 1
    IF ((request->preference_ind="N"))
     row + 1, col 7, captions->donor_id
    ELSE
     row + 1, col 7, captions->ssn
    ENDIF
    col 0, captions->name, col 61,
    captions->phone, col 83, captions->donation_info,
    col 105, captions->abo_rh, row + 1,
    col 0, "-----------------------------------------------------------", col 61,
    "--------------------", col 83, "--------------------",
    col 105, "-----------"
   HEAD pd.person_id
    IF (row > 56)
     BREAK
    ENDIF
    IF (last_display != null
     AND first_display != null)
     row + 1
     IF ((request->preference_ind="N"))
      name_display = concat(trim(first_display)," ",trim(last_display)," - ",trim(preference))
     ELSE
      name_display = concat(trim(first_display)," ",trim(last_display)," - ",trim(ssn))
     ENDIF
     col 0, name_display, col 67,
     captions->home
     IF (ph.phone_num != null)
      phone = trim(phone_display), col 67, phone
     ELSE
      col 67, captions->unknown
     ENDIF
     eligibility = trim(eligibility_type), col 83, eligibility,
     aborh = concat(trim(abo_display)," ",trim(rh_display))
     IF (aborh != null)
      col 105, aborh
     ELSE
      col 105, captions->unknown
     ENDIF
     row + 1
     IF (((ad.street_addr != null) OR (ad.street_addr2 != null)) )
      col 5, captions->address
     ELSE
      addline2 = 1
     ENDIF
     IF (ad.street_addr != null)
      col 15, ad.street_addr
     ENDIF
     col 61, captions->bus
     IF (ph2.phone_num != null)
      phone2 = trim(phone_display2), col 67, phone2
     ELSE
      col 67, captions->unknown
     ENDIF
     donation = trim(last_donation), col 83, donation
     IF (ad.street_addr2 != null)
      row + 1, col 15, ad.street_addr2
     ELSE
      addline = 1
     ENDIF
     IF (addline=0)
      col 83, pd.last_donation_dt_tm"@DATECONDENSED;;d"
     ENDIF
     city_state_zip_display = concat(trim(city_display),", ",trim(state_display),"  ",trim(
       zip_display))
     IF (city_state_zip_display != ",  ")
      row + 1, col 15, city_state_zip_display
     ENDIF
     IF (addline=1)
      IF (addline2=1)
       row + 1
      ENDIF
      col 83, pd.last_donation_dt_tm"@DATECONDENSED;;d"
     ENDIF
     country = trim(country_display)
     IF (country != null
      AND country != "USA")
      row + 1, col 15, country
     ENDIF
     addline = 0, addline2 = 0
    ENDIF
   DETAIL
    IF (row > 56)
     BREAK
    ENDIF
   FOOT  pd.person_id
    row + 1
   FOOT PAGE
    row 57, col 0, line,
    row + 1, col 0, captions->rpt_id,
    col 58, captions->rpt_page, col 64,
    curpage"###"
   FOOT REPORT
    row 59
   WITH counter, dontcare = pa, dontcare = pn,
    dontcare = ph, dontcare = ph2, dontcare = ad,
    dontcare = a, dontcare = ap, compress,
    nolandscape, nullreport
  ;end select
 ELSE
  SET code_set = 14236
  SET cdf_mean = "ONE"
  SET code_cnt = 1
  SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,code_cnt,one_cd)
  SET cdf_mean = "TWO"
  SET code_cnt = 1
  SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,code_cnt,two_cd)
  SET cdf_mean = "THREE"
  SET code_cnt = 1
  SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,code_cnt,three_cd)
  SET cdf_mean = "FOUR"
  SET code_cnt = 1
  SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,code_cnt,four_cd)
  SET cdf_mean = "FIVE"
  SET code_cnt = 1
  SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,code_cnt,five_cd)
  SET cdf_mean = "SIX"
  SET code_cnt = 1
  SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,code_cnt,six_cd)
  SET cdf_mean = "SEVEN"
  SET code_cnt = 1
  SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,code_cnt,seven_cd)
  SET cdf_mean = "EIGHT"
  SET code_cnt = 1
  SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,code_cnt,eight_cd)
  SET cdf_mean = "NINE"
  SET code_cnt = 1
  SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,code_cnt,nine_cd)
  SET cdf_mean = "TEN"
  SET code_cnt = 1
  SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,code_cnt,ten_cd)
  SET cdf_mean = "ELEVEN"
  SET code_cnt = 1
  SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,code_cnt,eleven_cd)
  SET cdf_mean = "TWELVE"
  SET code_cnt = 1
  SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,code_cnt,twelve_cd)
  SET cdf_mean = "THIRTEEN"
  SET code_cnt = 1
  SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,code_cnt,thirteen_cd)
  SET cdf_mean = "FOURTEEN"
  SET code_cnt = 1
  SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,code_cnt,fourteen_cd)
  SET cdf_mean = "FIFTEEN"
  SET code_cnt = 1
  SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,code_cnt,fifteen_cd)
  SET code_set = 14237
  SET cdf_mean = "TEMP"
  SET code_cnt = 1
  SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,code_cnt,temp_cd)
  SET cdf_mean = "PERMNENT"
  SET code_cnt = 1
  SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,code_cnt,permnent_cd)
  IF (((temp_cd=0.0) OR (permnent_cd=0.0)) )
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_rpt_recruiting_list.prg"
   SET reply->status_data.subeventstatus[1].operationname = "Select"
   SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE"
   IF (temp_cd=0.0)
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Unable to read temporary eligibility type code value"
   ELSEIF (permnent_cd=0.0)
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Unable to read permanent eligibility code value"
   ENDIF
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 2
   GO TO exit_script
  ENDIF
  SET days_until_eligible = 0
  IF ((request->donation_procedure_cd > 0.0))
   SELECT INTO "nl:"
    FROM bbd_donation_procedure bdp,
     bbd_procedure_outcome bpo,
     bbd_outcome_bag_type bobt,
     bbd_bag_type_product bbtp,
     bbd_product_eligibility bpe
    PLAN (bdp
     WHERE (bdp.procedure_cd=request->donation_procedure_cd)
      AND bdp.active_ind=1)
     JOIN (bpo
     WHERE bpo.procedure_id=bdp.procedure_id
      AND bpo.active_ind=1)
     JOIN (bobt
     WHERE bobt.procedure_outcome_id=bpo.procedure_outcome_id
      AND bobt.active_ind=1)
     JOIN (bbtp
     WHERE bbtp.outcome_bag_type_id=bobt.outcome_bag_type_id
      AND bbtp.active_ind=1)
     JOIN (bpe
     WHERE bpe.previous_product_cd=bbtp.product_cd
      AND bpe.active_ind=1)
    HEAD REPORT
     days_until_eligible = 0
    DETAIL
     IF (bpe.days_until_eligible > days_until_eligible)
      days_until_eligible = bpe.days_until_eligible
     ENDIF
    FOOT REPORT
     row + 0
    WITH nocounter
   ;end select
  ENDIF
  IF (acount=0
   AND zcount=0)
   SELECT INTO concat("CER_TEMP:",sfilename,".txt")
    first_display = substring(1,20,pn.name_first), last_display = substring(1,30,pn.name_last),
    last_donation = substring(1,20,uar_get_code_display(pe.prev_procedure_cd)),
    eligibility_type = substring(1,20,uar_get_code_display(pd.eligibility_type_cd)), pd
    .last_donation_dt_tm, abo_display = substring(1,10,uar_get_code_display(pa2.abo_cd)),
    rh_display = substring(1,10,uar_get_code_display(pa2.rh_cd)), ad.street_addr, ad.street_addr2,
    state_display = substring(1,30,ad.state), country_display = substring(1,100,uar_get_code_display(
      ad.country_cd)), city_display = substring(1,40,ad.city),
    zip_display = substring(1,20,ad.zipcode), ssn = substring(1,20,cnvtalias(a.alias,ap.format_mask)),
    preference = substring(1,20,a.alias),
    phone_display = substring(1,15,ph.phone_num), phone_display2 = substring(1,15,ph2.phone_num)
    FROM bbd_donation_results dr,
     person_donor pd,
     person p,
     person_aborh pa,
     bbd_special_interest i,
     bbd_rare_types r,
     bbd_donor_contact dc,
     code_value cv,
     person_name pn,
     dummyt d1,
     address ad,
     dummyt d2,
     phone ph,
     dummyt d3,
     phone ph2,
     dummyt d4,
     person_alias a,
     dummyt d5,
     person_aborh pa2,
     dummyt d6,
     alias_pool ap
    PLAN (dr
     WHERE dr.active_ind=1
      AND (((request->donation_procedure_cd > 0.0)
      AND datetimeadd(dr.drawn_dt_tm,days_until_eligible) BETWEEN cnvtdatetime(request->from_dt_tm)
      AND cnvtdatetime(request->to_dt_tm)) OR ((request->donation_procedure_cd=0.0))) )
     JOIN (pd
     WHERE pd.person_id=dr.person_id
      AND ((pd.willingness_level_cd=0.0) OR ((((pd.last_donation_dt_tm < (cnvtdatetime(current->
      system_dt_tm) - 365))
      AND pd.willingness_level_cd=one_cd) OR ((((pd.last_donation_dt_tm < (cnvtdatetime(current->
      system_dt_tm) - 183))
      AND pd.willingness_level_cd=two_cd) OR ((((pd.last_donation_dt_tm < (cnvtdatetime(current->
      system_dt_tm) - 122))
      AND pd.willingness_level_cd=three_cd) OR ((((pd.last_donation_dt_tm < (cnvtdatetime(current->
      system_dt_tm) - 91))
      AND pd.willingness_level_cd=four_cd) OR ((((pd.last_donation_dt_tm < (cnvtdatetime(current->
      system_dt_tm) - 73))
      AND pd.willingness_level_cd=five_cd) OR ((((pd.last_donation_dt_tm < (cnvtdatetime(current->
      system_dt_tm) - 61))
      AND pd.willingness_level_cd=six_cd) OR ((((pd.last_donation_dt_tm < (cnvtdatetime(current->
      system_dt_tm) - 52))
      AND pd.willingness_level_cd=seven_cd) OR ((((pd.last_donation_dt_tm < (cnvtdatetime(current->
      system_dt_tm) - 46))
      AND pd.willingness_level_cd=eight_cd) OR ((((pd.last_donation_dt_tm < (cnvtdatetime(current->
      system_dt_tm) - 41))
      AND pd.willingness_level_cd=nine_cd) OR ((((pd.last_donation_dt_tm < (cnvtdatetime(current->
      system_dt_tm) - 37))
      AND pd.willingness_level_cd=ten_cd) OR ((((pd.last_donation_dt_tm < (cnvtdatetime(current->
      system_dt_tm) - 33))
      AND pd.willingness_level_cd=eleven_cd) OR ((((pd.last_donation_dt_tm < (cnvtdatetime(current->
      system_dt_tm) - 30))
      AND pd.willingness_level_cd=twelve_cd) OR ((((pd.last_donation_dt_tm < (cnvtdatetime(current->
      system_dt_tm) - 28))
      AND pd.willingness_level_cd=thirteen_cd) OR ((((pd.last_donation_dt_tm < (cnvtdatetime(current
      ->system_dt_tm) - 26))
      AND pd.willingness_level_cd=fourteen_cd) OR ((pd.last_donation_dt_tm < (cnvtdatetime(current->
      system_dt_tm) - 24))
      AND pd.willingness_level_cd=fifteen_cd)) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
      AND ((pd.eligibility_type_cd=temp_cd
      AND pd.defer_until_dt_tm < cnvtdatetime(current->system_dt_tm)) OR (pd.eligibility_type_cd !=
     permnent_cd))
      AND pd.active_ind=1
      AND pd.lock_ind=0)
     JOIN (p
     WHERE (((request->race_cd > 0.0)
      AND p.person_id=pd.person_id
      AND (p.race_cd=request->race_cd)
      AND p.active_ind=1) OR ((request->race_cd=0.0)
      AND p.person_id=0.0)) )
     JOIN (pa
     WHERE (((request->abo_cd > 0.0)
      AND (request->rh_cd > 0.0)
      AND pa.person_id=pd.person_id
      AND (pa.abo_cd=request->abo_cd)
      AND (pa.rh_cd=request->abo_cd)
      AND pa.active_ind=1) OR ((request->abo_cd=0.0)
      AND (request->rh_cd=0.0)
      AND pa.person_aborh_id=0.0)) )
     JOIN (i
     WHERE (((request->special_interest_cd > 0.0)
      AND i.person_id=pd.person_id
      AND (i.special_interest_cd=request->special_interest_cd)
      AND i.active_ind=1) OR ((request->special_interest_cd=0.0)
      AND i.person_id=0.0)) )
     JOIN (r
     WHERE (((request->rare_type_cd > 0.0)
      AND r.person_id=pd.person_id
      AND (r.rare_type_cd=request->rare_type_cd)
      AND r.active_ind=1) OR ((request->rare_type_cd=0.0)
      AND r.person_id=0.0)) )
     JOIN (dc
     WHERE (((request->organization_id > 0.0)
      AND (dc.organization_id=request->organization_id)
      AND dc.person_id=p.person_id
      AND dc.active_ind=1) OR ((((request->organization_id=0.0)
      AND ((dc.person_id=p.person_id) OR (dc.contact_id=0.0)) ) OR (dc.contact_id=0.0)) )) )
     JOIN (cv
     WHERE ((dc.contact_outcome_cd > 0
      AND cv.code_set=14221
      AND cv.cdf_meaning="CALLBACK"
      AND cv.code_value=dc.contact_outcome_cd) OR (dc.contact_id=0.0
      AND cv.code_value=0.0)) )
     JOIN (pn
     WHERE pn.person_id=pd.person_id
      AND pn.active_ind=1)
     JOIN (d1)
     JOIN (ad
     WHERE ad.parent_entity_id=pd.person_id
      AND ad.parent_entity_name="PERSON"
      AND ad.active_ind=1)
     JOIN (d2)
     JOIN (ph
     WHERE ph.parent_entity_id=pd.person_id
      AND ph.phone_type_cd=phone_num_cd
      AND ph.parent_entity_name="PERSON"
      AND ph.active_ind=1)
     JOIN (d3)
     JOIN (ph2
     WHERE ph2.parent_entity_id=pd.person_id
      AND ph2.phone_type_cd=bus_phone_num_cd
      AND ph2.parent_entity_name="PERSON"
      AND ph2.active_ind=1)
     JOIN (d4)
     JOIN (a
     WHERE a.person_id=pd.person_id
      AND a.person_alias_type_cd=preference_cd
      AND a.active_ind=1)
     JOIN (d5)
     JOIN (pa2
     WHERE pa2.person_id=pd.person_id
      AND pa2.active_ind=1)
     JOIN (d6)
     JOIN (ap
     WHERE ap.alias_pool_cd=a.alias_pool_cd
      AND ap.active_ind=1)
    ORDER BY pd.person_id
    HEAD PAGE
     col 0, captions->rpt_cerner_health_sys,
     CALL center(captions->rpt_title,1,130),
     col 104, captions->rpt_time, col 118,
     curtime"@TIMENOSECONDS;;M", row + 1, col 104,
     captions->rpt_as_of_date, col 118, curdate"@DATECONDENSED;;d",
     row + 1
     IF ((request->preference_ind="N"))
      row + 1, col 7, captions->donor_id
     ELSE
      row + 1, col 7, captions->ssn
     ENDIF
     col 0, captions->name, col 61,
     captions->phone, col 83, captions->donation_info,
     col 105, captions->abo_rh, row + 1,
     col 0, "-----------------------------------------------------------", col 61,
     "--------------------", col 83, "--------------------",
     col 105, "-----------"
    HEAD pd.person_id
     IF (((row+ 5) > 56))
      BREAK
     ENDIF
     IF (last_display != null
      AND first_display != null)
      row + 1
      IF ((request->preference_ind="N"))
       name_display = concat(trim(first_display)," ",trim(last_display)," - ",trim(preference))
      ELSE
       name_display = concat(trim(first_display)," ",trim(last_display)," - ",trim(ssn))
      ENDIF
      col 0, name_display, col 61,
      captions->home
      IF (ph.phone_num != null)
       phone = trim(phone_display), col 67, phone
      ELSE
       col 67, captions->unknown
      ENDIF
      eligibility = trim(eligibility_type), col 83, eligibility,
      aborh = concat(trim(abo_display)," ",trim(rh_display))
      IF (aborh != null)
       col 105, aborh
      ELSE
       col 105, captions->unknown
      ENDIF
      row + 1
      IF (((ad.street_addr != null) OR (ad.street_addr2 != null)) )
       col 5, captions->address
      ELSE
       addline2 = 1
      ENDIF
      IF (ad.street_addr != null)
       col 15, ad.street_addr
      ENDIF
      col 61, captions->bus
      IF (ph2.phone_num != null)
       phone2 = trim(phone_display2), col 67, phone2
      ELSE
       col 67, captions->unknown
      ENDIF
      donation = trim(last_donation), col 83, donation
      IF (ad.street_addr2 != null)
       row + 1, col 15, ad.street_addr2
      ELSE
       addline = 1
      ENDIF
      IF (addline=0)
       col 83, pd.last_donation_dt_tm"@DATECONDENSED;;d"
      ENDIF
      city_state_zip_display = concat(trim(city_display),", ",trim(state_display),"  ",trim(
        zip_display))
      IF (city_state_zip_display != ",  ")
       row + 1, col 15, city_state_zip_display
      ENDIF
      IF (addline=1)
       IF (addline2=1)
        row + 1
       ENDIF
       col 83, pd.last_donation_dt_tm"@DATECONDENSED;;d"
      ENDIF
      country = trim(country_display)
      IF (country != null
       AND country != "USA")
       row + 1, col 15, country
      ENDIF
      addline = 0, addline2 = 0
     ENDIF
    DETAIL
     IF (row > 56)
      BREAK
     ENDIF
    FOOT  pd.person_id
     row + 1
    FOOT PAGE
     row 57, col 0, line,
     row + 1, col 0, captions->rpt_id,
     col 58, captions->rpt_page, col 64,
     curpage"###"
    FOOT REPORT
     row 59
    WITH counter, outerjoin = dc, dontcare = ad,
     dontcare = ph, dontcare = ph2, dontcare = a,
     dontcare = pa2, dontcare = ap, compress,
     nolandscape, nullreport
   ;end select
  ELSEIF (acount > 0
   AND zcount=0)
   SELECT INTO concat("CER_TEMP:",sfilename,".txt")
    first_display = substring(1,20,pn.name_first), last_display = substring(1,30,pn.name_last),
    last_donation = substring(1,20,uar_get_code_display(pe.prev_procedure_cd)),
    eligibility_type = substring(1,20,uar_get_code_display(pd.eligibility_type_cd)), pd
    .last_donation_dt_tm, abo_display = substring(1,10,uar_get_code_display(pa2.abo_cd)),
    rh_display = substring(1,10,uar_get_code_display(pa2.rh_cd)), ad.street_addr, ad.street_addr2,
    state_display = substring(1,30,ad.state), country_display = substring(1,100,uar_get_code_display(
      ad.country_cd)), city_display = substring(1,40,ad.city),
    zip_display = substring(1,20,ad.zipcode), ssn = substring(1,20,cnvtalias(a.alias,ap.format_mask)),
    preference = substring(1,20,a.alias),
    phone_display = substring(1,15,ph.phone_num), phone_display2 = substring(1,15,ph2.phone_num)
    FROM bbd_donation_results dr,
     person_donor pd,
     person p,
     person_aborh pa,
     bbd_special_interest i,
     bbd_rare_types r,
     bbd_donor_contact dc,
     code_value cv,
     person_antigen pg,
     (dummyt d0  WITH seq = value(acount)),
     person_name pn,
     dummyt d1,
     address ad,
     dummyt d2,
     phone ph,
     dummyt d3,
     phone ph2,
     dummyt d4,
     person_alias a,
     dummyt d5,
     person_aborh pa2,
     dummyt d6,
     alias_pool ap
    PLAN (dr
     WHERE dr.active_ind=1
      AND (((request->donation_procedure_cd > 0.0)
      AND datetimeadd(dr.drawn_dt_tm,days_until_eligible) BETWEEN cnvtdatetime(request->from_dt_tm)
      AND cnvtdatetime(request->to_dt_tm)) OR ((request->donation_procedure_cd=0.0))) )
     JOIN (pd
     WHERE pd.person_id=dr.person_id
      AND ((pd.willingness_level_cd=0.0) OR ((((pd.last_donation_dt_tm < (cnvtdatetime(current->
      system_dt_tm) - 365))
      AND pd.willingness_level_cd=one_cd) OR ((((pd.last_donation_dt_tm < (cnvtdatetime(current->
      system_dt_tm) - 183))
      AND pd.willingness_level_cd=two_cd) OR ((((pd.last_donation_dt_tm < (cnvtdatetime(current->
      system_dt_tm) - 122))
      AND pd.willingness_level_cd=three_cd) OR ((((pd.last_donation_dt_tm < (cnvtdatetime(current->
      system_dt_tm) - 91))
      AND pd.willingness_level_cd=four_cd) OR ((((pd.last_donation_dt_tm < (cnvtdatetime(current->
      system_dt_tm) - 73))
      AND pd.willingness_level_cd=five_cd) OR ((((pd.last_donation_dt_tm < (cnvtdatetime(current->
      system_dt_tm) - 61))
      AND pd.willingness_level_cd=six_cd) OR ((((pd.last_donation_dt_tm < (cnvtdatetime(current->
      system_dt_tm) - 52))
      AND pd.willingness_level_cd=seven_cd) OR ((((pd.last_donation_dt_tm < (cnvtdatetime(current->
      system_dt_tm) - 46))
      AND pd.willingness_level_cd=eight_cd) OR ((((pd.last_donation_dt_tm < (cnvtdatetime(current->
      system_dt_tm) - 41))
      AND pd.willingness_level_cd=nine_cd) OR ((((pd.last_donation_dt_tm < (cnvtdatetime(current->
      system_dt_tm) - 37))
      AND pd.willingness_level_cd=ten_cd) OR ((((pd.last_donation_dt_tm < (cnvtdatetime(current->
      system_dt_tm) - 33))
      AND pd.willingness_level_cd=eleven_cd) OR ((((pd.last_donation_dt_tm < (cnvtdatetime(current->
      system_dt_tm) - 30))
      AND pd.willingness_level_cd=twelve_cd) OR ((((pd.last_donation_dt_tm < (cnvtdatetime(current->
      system_dt_tm) - 28))
      AND pd.willingness_level_cd=thirteen_cd) OR ((((pd.last_donation_dt_tm < (cnvtdatetime(current
      ->system_dt_tm) - 26))
      AND pd.willingness_level_cd=fourteen_cd) OR ((pd.last_donation_dt_tm < (cnvtdatetime(current->
      system_dt_tm) - 24))
      AND pd.willingness_level_cd=fifteen_cd)) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
      AND ((pd.eligibility_type_cd=temp_cd
      AND pd.defer_until_dt_tm < cnvtdatetime(current->system_dt_tm)) OR (pd.eligibility_type_cd !=
     permnent_cd))
      AND pd.active_ind=1
      AND pd.lock_ind=0)
     JOIN (p
     WHERE (((request->race_cd > 0.0)
      AND p.person_id=pd.person_id
      AND (p.race_cd=request->race_cd)
      AND p.active_ind=1) OR ((request->race_cd=0.0)
      AND p.person_id=0.0)) )
     JOIN (pa
     WHERE (((request->abo_cd > 0.0)
      AND (request->rh_cd > 0.0)
      AND pa.person_id=pd.person_id
      AND (pa.abo_cd=request->abo_cd)
      AND (pa.rh_cd=request->abo_cd)
      AND pa.active_ind=1) OR ((request->abo_cd=0.0)
      AND (request->rh_cd=0.0)
      AND pa.person_aborh_id=0.0)) )
     JOIN (i
     WHERE (((request->special_interest_cd > 0.0)
      AND i.person_id=pd.person_id
      AND (i.special_interest_cd=request->special_interest_cd)
      AND i.active_ind=1) OR ((request->special_interest_cd=0.0)
      AND i.person_id=0.0)) )
     JOIN (r
     WHERE (((request->rare_type_cd > 0.0)
      AND r.person_id=pd.person_id
      AND (r.rare_type_cd=request->rare_type_cd)
      AND r.active_ind=1) OR ((request->rare_type_cd=0.0)
      AND r.person_id=0.0)) )
     JOIN (dc
     WHERE (((request->organization_id > 0.0)
      AND (dc.organization_id=request->organization_id)
      AND dc.person_id=p.person_id
      AND dc.active_ind=1) OR ((((request->organization_id=0.0)
      AND ((dc.person_id=p.person_id) OR (dc.contact_id=0.0)) ) OR (dc.contact_id=0.0)) )) )
     JOIN (cv
     WHERE ((dc.contact_outcome_cd > 0
      AND cv.code_set=14221
      AND cv.cdf_meaning="CALLBACK"
      AND cv.code_value=dc.contact_outcome_cd) OR (dc.contact_id=0.0
      AND cv.code_value=0.0)) )
     JOIN (d0)
     JOIN (pg
     WHERE pg.person_id=pd.person_id
      AND (pg.antigen_cd=request->antigen[d1.seq].antigen_cd)
      AND pg.active_ind=1)
     JOIN (pn
     WHERE pn.person_id=pd.person_id
      AND pn.active_ind=1)
     JOIN (d1)
     JOIN (ad
     WHERE ad.parent_entity_id=pn.person_id
      AND ad.parent_entity_name="PERSON"
      AND ad.active_ind=1)
     JOIN (d2)
     JOIN (ph
     WHERE ph.parent_entity_id=pd.person_id
      AND ph.phone_type_cd=phone_num_cd
      AND ph.parent_entity_name="PERSON"
      AND ph.active_ind=1)
     JOIN (d3)
     JOIN (ph2
     WHERE ph2.parent_entity_id=pd.person_id
      AND ph2.phone_type_cd=bus_phone_num_cd
      AND ph2.parent_entity_name="PERSON"
      AND ph2.active_ind=1)
     JOIN (d4)
     JOIN (a
     WHERE a.person_id=pd.person_id
      AND a.person_alias_type_cd=preference_cd
      AND a.active_ind=1)
     JOIN (d5)
     JOIN (pa2
     WHERE pa2.person_id=pd.person_id
      AND pa2.active_ind=1)
     JOIN (d6)
     JOIN (ap
     WHERE ap.alias_pool_cd=a.alias_pool_cd
      AND ap.active_ind=1)
    ORDER BY pd.person_id
    HEAD PAGE
     col 0, captions->rpt_cerner_health_sys,
     CALL center(captions->rpt_title,1,130),
     col 104, captions->rpt_time, col 118,
     curtime"@TIMENOSECONDS;;M", row + 1, col 104,
     captions->rpt_as_of_date, col 118, curdate"@DATECONDENSED;;d",
     row + 1
     IF ((request->preference_ind="N"))
      row + 1, col 7, captions->donor_id
     ELSE
      row + 1, col 7, captions->ssn
     ENDIF
     col 0, captions->name, col 61,
     captions->phone, col 83, captions->donation_info,
     col 105, captions->abo_rh, row + 1,
     col 0, "-----------------------------------------------------------", col 61,
     "--------------------", col 83, "--------------------",
     col 105, "-----------"
    HEAD pd.person_id
     IF (row > 56)
      BREAK
     ENDIF
     IF (last_display != null
      AND first_display != null)
      row + 1
      IF ((request->preference_ind="N"))
       name_display = concat(trim(first_display)," ",trim(last_display)," - ",trim(preference))
      ELSE
       name_display = concat(trim(first_display)," ",trim(last_display)," - ",trim(ssn))
      ENDIF
      col 0, name_display, col 61,
      captions->home
      IF (ph.phone_num != null)
       phone = trim(phone_display), col 67, phone
      ELSE
       col 67, captions->unknown
      ENDIF
      eligibility = trim(eligibility_type), col 83, eligibility,
      aborh = concat(trim(abo_display)," ",trim(rh_display))
      IF (aborh != null)
       col 105, aborh
      ELSE
       col 105, captions->unknown
      ENDIF
      row + 1
      IF (((ad.street_addr != null) OR (ad.street_addr2 != null)) )
       col 5, captions->address
      ELSE
       addline2 = 1
      ENDIF
      IF (ad.street_addr != null)
       col 15, ad.street_addr
      ENDIF
      col 61, captions->bus
      IF (ph2.phone_num != null)
       phone2 = trim(phone_display2), col 67, phone2
      ELSE
       col 67, captions->unknown
      ENDIF
      donation = trim(last_donation), col 83, donation
      IF (ad.street_addr2 != null)
       row + 1, col 15, ad.street_addr2
      ELSE
       addline = 1
      ENDIF
      IF (addline=0)
       col 83, pd.last_donation_dt_tm"@DATECONDENSED;;d"
      ENDIF
      city_state_zip_display = concat(trim(city_display),", ",trim(state_display),"  ",trim(
        zip_display))
      IF (city_state_zip_display != ",  ")
       row + 1, col 15, city_state_zip_display
      ENDIF
      IF (addline=1)
       IF (addline2=1)
        row + 1
       ENDIF
       col 83, pd.last_donation_dt_tm"@DATECONDENSED;;d"
      ENDIF
      country = trim(country_display)
      IF (country != null
       AND country != "USA")
       row + 1, col 15, country
      ENDIF
      addline = 0, addline2 = 0
     ENDIF
    DETAIL
     IF (row > 56)
      BREAK
     ENDIF
    FOOT  pd.person_id
     row + 1
    FOOT PAGE
     row 57, col 0, line,
     row + 1, col 0, captions->rpt_id,
     col 58, captions->rpt_page, col 64,
     curpage"###"
    FOOT REPORT
     row 59
    WITH counter, outerjoin = dc, outerjoin = d0,
     dontcare = ad, dontcare = ph, dontcare = ph2,
     dontcare = a, dontcare = pa2, dontcare = ap,
     compress, nolandscape, nullreport
   ;end select
  ELSEIF (acount=0
   AND zcount > 0)
   SELECT INTO concat("CER_TEMP:",sfilename,".txt")
    first_display = substring(1,20,pn.name_first), last_display = substring(1,30,pn.name_last),
    last_donation = substring(1,20,uar_get_code_display(pe.prev_procedure_cd)),
    eligibility_type = substring(1,20,uar_get_code_display(pd.eligibility_type_cd)), pd
    .last_donation_dt_tm, abo_display = substring(1,10,uar_get_code_display(pa2.abo_cd)),
    rh_display = substring(1,10,uar_get_code_display(pa2.rh_cd)), ad.street_addr, ad.street_addr2,
    state_display = substring(1,30,ad.state), country_display = substring(1,100,uar_get_code_display(
      ad.country_cd)), city_display = substring(1,40,ad.city),
    zip_display = substring(1,20,ad.zipcode), ssn = substring(1,20,cnvtalias(a.alias,ap.format_mask)),
    preference = substring(1,20,a.alias),
    phone_display = substring(1,15,ph.phone_num), phone_display2 = substring(1,15,ph2.phone_num)
    FROM bbd_donation_results dr,
     person_donor pd,
     person p,
     person_aborh pa,
     bbd_special_interest i,
     bbd_rare_types r,
     bbd_donor_contact dc,
     code_value cv,
     person_zipcode pz,
     (dummyt d0  WITH seq = value(zcount)),
     person_name pn,
     dummyt d1,
     address ad,
     dummyt d2,
     phone ph,
     dummyt d3,
     phone ph2,
     dummyt d4,
     person_alias a,
     dummyt d5,
     person_aborh pa2,
     dummyt d6,
     alias_pool ap
    PLAN (dr
     WHERE dr.active_ind=1
      AND (((request->donation_procedure_cd > 0.0)
      AND datetimeadd(dr.drawn_dt_tm,days_until_eligible) BETWEEN cnvtdatetime(request->from_dt_tm)
      AND cnvtdatetime(request->to_dt_tm)) OR ((request->donation_procedure_cd=0.0))) )
     JOIN (pd
     WHERE pd.person_id=dr.person_id
      AND ((pd.willingness_level_cd=0.0) OR ((((pd.last_donation_dt_tm < (cnvtdatetime(current->
      system_dt_tm) - 365))
      AND pd.willingness_level_cd=one_cd) OR ((((pd.last_donation_dt_tm < (cnvtdatetime(current->
      system_dt_tm) - 183))
      AND pd.willingness_level_cd=two_cd) OR ((((pd.last_donation_dt_tm < (cnvtdatetime(current->
      system_dt_tm) - 122))
      AND pd.willingness_level_cd=three_cd) OR ((((pd.last_donation_dt_tm < (cnvtdatetime(current->
      system_dt_tm) - 91))
      AND pd.willingness_level_cd=four_cd) OR ((((pd.last_donation_dt_tm < (cnvtdatetime(current->
      system_dt_tm) - 73))
      AND pd.willingness_level_cd=five_cd) OR ((((pd.last_donation_dt_tm < (cnvtdatetime(current->
      system_dt_tm) - 61))
      AND pd.willingness_level_cd=six_cd) OR ((((pd.last_donation_dt_tm < (cnvtdatetime(current->
      system_dt_tm) - 52))
      AND pd.willingness_level_cd=seven_cd) OR ((((pd.last_donation_dt_tm < (cnvtdatetime(current->
      system_dt_tm) - 46))
      AND pd.willingness_level_cd=eight_cd) OR ((((pd.last_donation_dt_tm < (cnvtdatetime(current->
      system_dt_tm) - 41))
      AND pd.willingness_level_cd=nine_cd) OR ((((pd.last_donation_dt_tm < (cnvtdatetime(current->
      system_dt_tm) - 37))
      AND pd.willingness_level_cd=ten_cd) OR ((((pd.last_donation_dt_tm < (cnvtdatetime(current->
      system_dt_tm) - 33))
      AND pd.willingness_level_cd=eleven_cd) OR ((((pd.last_donation_dt_tm < (cnvtdatetime(current->
      system_dt_tm) - 30))
      AND pd.willingness_level_cd=twelve_cd) OR ((((pd.last_donation_dt_tm < (cnvtdatetime(current->
      system_dt_tm) - 28))
      AND pd.willingness_level_cd=thirteen_cd) OR ((((pd.last_donation_dt_tm < (cnvtdatetime(current
      ->system_dt_tm) - 26))
      AND pd.willingness_level_cd=fourteen_cd) OR ((pd.last_donation_dt_tm < (cnvtdatetime(current->
      system_dt_tm) - 24))
      AND pd.willingness_level_cd=fifteen_cd)) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
      AND ((pd.eligibility_type_cd=temp_cd
      AND pd.defer_until_dt_tm < cnvtdatetime(current->system_dt_tm)) OR (pd.eligibility_type_cd !=
     permnent_cd))
      AND pd.active_ind=1
      AND pd.lock_ind=0)
     JOIN (p
     WHERE (((request->race_cd > 0.0)
      AND p.person_id=pd.person_id
      AND (p.race_cd=request->race_cd)
      AND p.active_ind=1) OR ((request->race_cd=0.0)
      AND p.person_id=0.0)) )
     JOIN (pa
     WHERE (((request->abo_cd > 0.0)
      AND (request->rh_cd > 0.0)
      AND pa.person_id=pd.person_id
      AND (pa.abo_cd=request->abo_cd)
      AND (pa.rh_cd=request->abo_cd)
      AND pa.active_ind=1) OR ((request->abo_cd=0.0)
      AND (request->rh_cd=0.0)
      AND pa.person_aborh_id=0.0)) )
     JOIN (i
     WHERE (((request->special_interest_cd > 0.0)
      AND i.person_id=pd.person_id
      AND (i.special_interest_cd=request->special_interest_cd)
      AND i.active_ind=1) OR ((request->special_interest_cd=0.0)
      AND i.person_id=0.0)) )
     JOIN (r
     WHERE (((request->rare_type_cd > 0.0)
      AND r.person_id=pd.person_id
      AND (r.rare_type_cd=request->rare_type_cd)
      AND r.active_ind=1) OR ((request->rare_type_cd=0.0)
      AND r.person_id=0.0)) )
     JOIN (dc
     WHERE (((request->organization_id > 0.0)
      AND (dc.organization_id=request->organization_id)
      AND dc.person_id=p.person_id
      AND dc.active_ind=1) OR ((((request->organization_id=0.0)
      AND ((dc.person_id=p.person_id) OR (dc.contact_id=0.0)) ) OR (dc.contact_id=0.0)) )) )
     JOIN (cv
     WHERE ((dc.contact_outcome_cd > 0
      AND cv.code_set=14221
      AND cv.cdf_meaning="CALLBACK"
      AND cv.code_value=dc.contact_outcome_cd) OR (dc.contact_id=0.0
      AND cv.code_value=0.0)) )
     JOIN (d0)
     JOIN (pz
     WHERE pz.person_id=pd.person_id
      AND (pz.zip_code=request->zipcode[d1.seq].zip_code)
      AND pz.active_ind=1)
     JOIN (pn
     WHERE pn.person_id=pd.person_id
      AND pn.active_ind=1)
     JOIN (d1)
     JOIN (ad
     WHERE ad.parent_entity_id=pn.person_id
      AND ad.parent_entity_name="PERSON"
      AND ad.active_ind=1)
     JOIN (d2)
     JOIN (ph
     WHERE ph.parent_entity_id=pd.person_id
      AND ph.phone_type_cd=phone_num_cd
      AND ph.parent_entity_name="PERSON"
      AND ph.active_ind=1)
     JOIN (d3)
     JOIN (ph2
     WHERE ph2.parent_entity_id=pd.person_id
      AND ph2.phone_type_cd=bus_phone_num_cd
      AND ph2.parent_entity_name="PEROSN"
      AND ph2.active_ind=1)
     JOIN (d4)
     JOIN (a
     WHERE a.person_id=pd.person_id
      AND a.person_alias_type_cd=preference_cd
      AND a.active_ind=1)
     JOIN (d5)
     JOIN (pa2
     WHERE pa2.person_id=pd.person_id
      AND pa2.active_ind=1)
     JOIN (d6)
     JOIN (ap
     WHERE ap.alias_pool_cd=a.alias_pool_cd
      AND ap.active_ind=1)
    ORDER BY pd.person_id
    HEAD PAGE
     col 0, captions->rpt_cerner_health_sys,
     CALL center(captions->rpt_title,1,130),
     col 104, captions->rpt_time, col 118,
     curtime"@TIMENOSECONDS;;M", row + 1, col 104,
     captions->rpt_as_of_date, col 118, curdate"@DATECONDENSED;;d",
     row + 1
     IF ((request->preference_ind="N"))
      row + 1, col 7, captions->donor_id
     ELSE
      row + 1, col 7, captions->ssn
     ENDIF
     col 0, captions->name, col 61,
     captions->phone, col 83, captions->donation_info,
     col 105, captions->abo_rh, row + 1,
     col 0, "-----------------------------------------------------------", col 61,
     "--------------------", col 83, "--------------------",
     col 105, "-----------"
    HEAD pd.person_id
     IF (row > 56)
      BREAK
     ENDIF
     IF (last_display != null
      AND first_display != null)
      row + 1
      IF ((request->preference_ind="N"))
       name_display = concat(trim(first_display)," ",trim(last_display)," - ",trim(preference))
      ELSE
       name_display = concat(trim(first_display)," ",trim(last_display)," - ",trim(ssn))
      ENDIF
      col 0, name_display, col 61,
      captions->home
      IF (ph.phone_num != null)
       phone = trim(phone_display), col 67, phone
      ELSE
       col 67, captions->unknown
      ENDIF
      eligibility = trim(eligibility_type), col 83, eligibility,
      aborh = concat(trim(abo_display)," ",trim(rh_display))
      IF (aborh != null)
       col 105, aborh
      ELSE
       col 105, captions->unknown
      ENDIF
      row + 1
      IF (((ad.street_addr != null) OR (ad.street_addr2 != null)) )
       col 5, captions->address
      ELSE
       addline2 = 1
      ENDIF
      IF (ad.street_addr != null)
       col 15, ad.street_addr
      ENDIF
      col 61, captions->bus
      IF (ph2.phone_num != null)
       phone2 = trim(phone_display2), col 67, phone2
      ELSE
       col 67, captions->unknown
      ENDIF
      donation = trim(last_donation), col 83, donation
      IF (ad.street_addr2 != null)
       row + 1, col 15, ad.street_addr2
      ELSE
       addline = 1
      ENDIF
      IF (addline=0)
       col 83, pd.last_donation_dt_tm"@DATECONDENSED;;d"
      ENDIF
      city_state_zip_display = concat(trim(city_display),", ",trim(state_display),"  ",trim(
        zip_display))
      IF (city_state_zip_display != ",  ")
       row + 1, col 15, city_state_zip_display
      ENDIF
      IF (addline=1)
       IF (addline2=1)
        row + 1
       ENDIF
       col 83, pd.last_donation_dt_tm"@DATECONDENSED;;d"
      ENDIF
      country = trim(country_display)
      IF (country != null
       AND country != "USA")
       row + 1, col 15, country
      ENDIF
      addline = 0, addline2 = 0
     ENDIF
    DETAIL
     IF (row > 56)
      BREAK
     ENDIF
    FOOT  pd.person_id
     row + 1
    FOOT PAGE
     row 57, col 0, line,
     row + 1, col 0, captions->rpt_id,
     col 58, captions->rpt_page, col 64,
     curpage"###"
    FOOT REPORT
     row 59
    WITH counter, outerjoin = dc, outerjoin = d0,
     dontcare = ad, dontcare = ph, dontcare = ph2,
     dontcare = a, dontcare = pa2, dontcare = ap,
     compress, nolandscape, nullreport
   ;end select
  ELSE
   SELECT INTO concat("CER_TEMP:",sfilename,".txt")
    first_display = substring(1,20,pn.name_first), last_display = substring(1,30,pn.name_last),
    last_donation = substring(1,20,uar_get_code_display(pe.prev_procedure_cd)),
    eligibility_type = substring(1,20,uar_get_code_display(pd.eligibility_type_cd)), pd
    .last_donation_dt_tm, abo_display = substring(1,10,uar_get_code_display(pa2.abo_cd)),
    rh_display = substring(1,10,uar_get_code_display(pa2.rh_cd)), ad.street_addr, ad.street_addr2,
    state_display = substring(1,30,ad.state), country_display = substring(1,100,uar_get_code_display(
      ad.country_cd)), city_display = substring(1,40,ad.city),
    zip_display = substring(1,20,ad.zipcode), ssn = substring(1,20,cnvtalias(a.alias,ap.format_mask)),
    preference = substring(1,20,a.alias),
    phone_display = substring(1,15,ph.phone_num), phone_display2 = substring(1,15,ph2.phone_num)
    FROM bbd_donation_results dr,
     person_donor pd,
     person p,
     person_aborh pa,
     bbd_special_interest i,
     bbd_rare_types r,
     bbd_donor_contact dc,
     code_value cv,
     person_antigen pg,
     person_zipcode pz,
     (dummyt d0  WITH seq = value(acount)),
     (dummyt d1  WITH seq = value(zcount)),
     person_name pn,
     dummyt d2,
     address ad,
     dummyt d3,
     phone ph,
     dummyt d4,
     phone ph2,
     dummyt d5,
     person_alias a,
     dummyt d6,
     person_aborh pa2,
     dummyt d7,
     alias_pool ap
    PLAN (dr
     WHERE dr.active_ind=1
      AND (((request->donation_procedure_cd > 0.0)
      AND datetimeadd(dr.drawn_dt_tm,days_until_eligible) BETWEEN cnvtdatetime(request->from_dt_tm)
      AND cnvtdatetime(request->to_dt_tm)) OR ((request->donation_procedure_cd=0.0))) )
     JOIN (pd
     WHERE pd.person_id=dr.person_id
      AND ((pd.willingness_level_cd=0.0) OR ((((pd.last_donation_dt_tm < (cnvtdatetime(current->
      system_dt_tm) - 365))
      AND pd.willingness_level_cd=one_cd) OR ((((pd.last_donation_dt_tm < (cnvtdatetime(current->
      system_dt_tm) - 183))
      AND pd.willingness_level_cd=two_cd) OR ((((pd.last_donation_dt_tm < (cnvtdatetime(current->
      system_dt_tm) - 122))
      AND pd.willingness_level_cd=three_cd) OR ((((pd.last_donation_dt_tm < (cnvtdatetime(current->
      system_dt_tm) - 91))
      AND pd.willingness_level_cd=four_cd) OR ((((pd.last_donation_dt_tm < (cnvtdatetime(current->
      system_dt_tm) - 73))
      AND pd.willingness_level_cd=five_cd) OR ((((pd.last_donation_dt_tm < (cnvtdatetime(current->
      system_dt_tm) - 61))
      AND pd.willingness_level_cd=six_cd) OR ((((pd.last_donation_dt_tm < (cnvtdatetime(current->
      system_dt_tm) - 52))
      AND pd.willingness_level_cd=seven_cd) OR ((((pd.last_donation_dt_tm < (cnvtdatetime(current->
      system_dt_tm) - 46))
      AND pd.willingness_level_cd=eight_cd) OR ((((pd.last_donation_dt_tm < (cnvtdatetime(current->
      system_dt_tm) - 41))
      AND pd.willingness_level_cd=nine_cd) OR ((((pd.last_donation_dt_tm < (cnvtdatetime(current->
      system_dt_tm) - 37))
      AND pd.willingness_level_cd=ten_cd) OR ((((pd.last_donation_dt_tm < (cnvtdatetime(current->
      system_dt_tm) - 33))
      AND pd.willingness_level_cd=eleven_cd) OR ((((pd.last_donation_dt_tm < (cnvtdatetime(current->
      system_dt_tm) - 30))
      AND pd.willingness_level_cd=twelve_cd) OR ((((pd.last_donation_dt_tm < (cnvtdatetime(current->
      system_dt_tm) - 28))
      AND pd.willingness_level_cd=thirteen_cd) OR ((((pd.last_donation_dt_tm < (cnvtdatetime(current
      ->system_dt_tm) - 26))
      AND pd.willingness_level_cd=fourteen_cd) OR ((pd.last_donation_dt_tm < (cnvtdatetime(current->
      system_dt_tm) - 24))
      AND pd.willingness_level_cd=fifteen_cd)) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
      AND ((pd.eligibility_type_cd=temp_cd
      AND pd.defer_until_dt_tm < cnvtdatetime(current->system_dt_tm)) OR (pd.eligibility_type_cd !=
     permnent_cd))
      AND pd.active_ind=1
      AND pd.lock_ind=0)
     JOIN (p
     WHERE (((request->race_cd > 0.0)
      AND p.person_id=pd.person_id
      AND (p.race_cd=request->race_cd)
      AND p.active_ind=1) OR ((request->race_cd=0.0)
      AND p.person_id=0.0)) )
     JOIN (pa
     WHERE (((request->abo_cd > 0.0)
      AND (request->rh_cd > 0.0)
      AND pa.person_id=pd.person_id
      AND (pa.abo_cd=request->abo_cd)
      AND (pa.rh_cd=request->abo_cd)
      AND pa.active_ind=1) OR ((request->abo_cd=0.0)
      AND (request->rh_cd=0.0)
      AND pa.person_aborh_id=0.0)) )
     JOIN (i
     WHERE (((request->special_interest_cd > 0.0)
      AND i.person_id=pd.person_id
      AND (i.special_interest_cd=request->special_interest_cd)
      AND i.active_ind=1) OR ((request->special_interest_cd=0.0)
      AND i.person_id=0.0)) )
     JOIN (r
     WHERE (((request->rare_type_cd > 0.0)
      AND r.person_id=pd.person_id
      AND (r.rare_type_cd=request->rare_type_cd)
      AND r.active_ind=1) OR ((request->rare_type_cd=0.0)
      AND r.person_id=0.0)) )
     JOIN (dc
     WHERE (((request->organization_id > 0.0)
      AND (dc.organization_id=request->organization_id)
      AND dc.person_id=p.person_id
      AND dc.active_ind=1) OR ((((request->organization_id=0.0)
      AND ((dc.person_id=p.person_id) OR (dc.contact_id=0.0)) ) OR (dc.contact_id=0.0)) )) )
     JOIN (cv
     WHERE ((dc.contact_outcome_cd > 0
      AND cv.code_set=14221
      AND cv.cdf_meaning="CALLBACK"
      AND cv.code_value=dc.contact_outcome_cd) OR (dc.contact_id=0.0
      AND cv.code_value=0.0)) )
     JOIN (d0)
     JOIN (pg
     WHERE pg.person_id=pd.person_id
      AND (pg.antigen_cd=request->antigen[d0.seq].antigen_cd)
      AND pg.active_ind=1)
     JOIN (d1)
     JOIN (pz
     WHERE pz.person_id=pd.person_id
      AND (pz.zip_code=request->zipcode[d1.seq].zip_code)
      AND pz.active_ind=1)
     JOIN (pn
     WHERE pn.person_id=pd.person_id
      AND pn.active_ind=1)
     JOIN (d2)
     JOIN (ad
     WHERE ad.parent_entity_id=pn.person_id
      AND ad.parent_entity_name="PERSON"
      AND ad.active_ind=1)
     JOIN (d3)
     JOIN (ph
     WHERE ph.parent_entity_id=pd.person_id
      AND ph.phone_type_cd=phone_num_cd
      AND ph.parent_entity_name="PERSON"
      AND ph.active_ind=1)
     JOIN (d4)
     JOIN (ph2
     WHERE ph2.parent_entity_id=pd.person_id
      AND ph2.phone_type_cd=bus_phone_num_cd
      AND ph2.parent_entity_name="PERSON"
      AND ph2.active_ind=1)
     JOIN (d5)
     JOIN (a
     WHERE a.person_id=pd.person_id
      AND a.person_alias_type_cd=preference_cd
      AND a.active_ind=1)
     JOIN (d6)
     JOIN (pa2
     WHERE pa2.person_id=pd.person_id
      AND pa2.active_ind=1)
     JOIN (d7)
     JOIN (ap
     WHERE ap.alias_pool_cd=a.alias_pool_cd
      AND ap.active_ind=1)
    ORDER BY pd.person_id
    HEAD PAGE
     col 0, captions->rpt_cerner_health_sys,
     CALL center(captions->rpt_title,1,130),
     col 104, captions->rpt_time, col 118,
     curtime"@TIMENOSECONDS;;M", row + 1, col 104,
     captions->rpt_as_of_date, col 118, curdate"@DATECONDENSED;;d",
     row + 1
     IF ((request->preference_ind="N"))
      row + 1, col 7, captions->donor_id
     ELSE
      row + 1, col 7, captions->ssn
     ENDIF
     col 0, captions->name, col 61,
     captions->phone, col 83, captions->donation_info,
     col 105, captions->abo_rh, row + 1,
     col 0, "-----------------------------------------------------------", col 61,
     "--------------------", col 83, "--------------------",
     col 105, "-----------"
    HEAD pd.person_id
     IF (row > 56)
      BREAK
     ENDIF
     IF (last_display != null
      AND first_display != null)
      row + 1
      IF ((request->preference_ind="N"))
       name_display = concat(trim(first_display)," ",trim(last_display)," - ",trim(preference))
      ELSE
       name_display = concat(trim(first_display)," ",trim(last_display)," - ",trim(ssn))
      ENDIF
      col 0, name_display, col 61,
      captions->home
      IF (ph.phone_num != null)
       phone = trim(phone_display), col 67, phone
      ELSE
       col 67, captions->unknown
      ENDIF
      eligibility = trim(eligibility_type), col 83, eligibility,
      aborh = concat(trim(abo_display)," ",trim(rh_display))
      IF (aborh != null)
       col 105, aborh
      ELSE
       col 105, captions->unknown
      ENDIF
      row + 1
      IF (((ad.street_addr != null) OR (ad.street_addr2 != null)) )
       col 5, captions->address
      ELSE
       addline2 = 1
      ENDIF
      IF (ad.street_addr != null)
       col 15, ad.street_addr
      ENDIF
      col 61, captions->bus
      IF (ph2.phone_num != null)
       phone2 = trim(phone_display2), col 67, phone2
      ELSE
       col 67, captions->unknown
      ENDIF
      donation = trim(last_donation), col 83, donation
      IF (ad.street_addr2 != null)
       row + 1, col 15, ad.street_addr2
      ELSE
       addline = 1
      ENDIF
      IF (addline=0)
       col 83, pd.last_donation_dt_tm"@DATECONDENSED;;d"
      ENDIF
      city_state_zip_display = concat(trim(city_display),", ",trim(state_display),"  ",trim(
        zip_display))
      IF (city_state_zip_display != ",  ")
       row + 1, col 15, city_state_zip_display
      ENDIF
      IF (addline=1)
       IF (addline2=1)
        row + 1
       ENDIF
       col 83, pd.last_donation_dt_tm"@DATECONDENSED;;d"
      ENDIF
      country = trim(country_display)
      IF (country != null
       AND country != "USA")
       row + 1, col 15, country
      ENDIF
      addline = 0, addline2 = 0
     ENDIF
    DETAIL
     IF (row > 56)
      BREAK
     ENDIF
    FOOT  pd.person_id
     row + 1
    FOOT PAGE
     row 57, col 0, line,
     row + 1, col 0, captions->rpt_id,
     col 58, captions->rpt_page, col 64,
     curpage"###"
    FOOT REPORT
     row 59
    WITH counter, outerjoin = dc, outerjoin = d0,
     outerjoin = d1, dontcare = ad, dontcare = ph,
     dontcare = ph2, dontcare = a, dontcare = pa2,
     dontcare = ap, compress, nolandscape,
     nullreport
   ;end select
  ENDIF
 ENDIF
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
  ROLLBACK
 ELSE
  SET reply->status_data.status = "S"
  COMMIT
 ENDIF
END GO
