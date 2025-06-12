CREATE PROGRAM bbd_rpt_mailing_list:dba
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
   1 rpt_f = vc
   1 rpt_cer_temp = vc
   1 rpt_txt = vc
   1 rpt_usa = vc
   1 rpt_one = vc
   1 rpt_two = vc
   1 rpt_three = vc
   1 rpt_four = vc
   1 rpt_five = vc
   1 rpt_six = vc
   1 rpt_seven = vc
   1 rpt_eight = vc
   1 rpt_nine = vc
   1 rpt_ten = vc
   1 rpt_eleven = vc
   1 rpt_twelve = vc
   1 rpt_thirteen = vc
   1 rpt_fourteen = vc
   1 rpt_fifteen = vc
   1 rpt_temp = vc
   1 rpt_perm = vc
   1 rpt_t = vc
   1 rpt_bbd = vc
   1 rpt_select = vc
   1 rpt_code = vc
   1 rpt_unable_read_temp = vc
   1 rpt_unable_read_perm = vc
   1 rpt_callback = vc
   1 rpt_mail = vc
   1 rpt_s = vc
   1 rpt_bbdmail = vc
 )
 SET captions->rpt_f = uar_i18ngetmessage(i18nhandle,"rpt_f","F")
 SET captions->rpt_cer_temp = uar_i18ngetmessage(i18nhandle,"rpt_cer_temp","CER_TEMP")
 SET captions->rpt_txt = uar_i18ngetmessage(i18nhandle,"rpt_txt",".txt")
 SET captions->rpt_usa = uar_i18ngetmessage(i18nhandle,"rpt_usa","USA")
 SET captions->rpt_one = uar_i18ngetmessage(i18nhandle,"rpt_one","ONE")
 SET captions->rpt_two = uar_i18ngetmessage(i18nhandle,"rpt_two","TWO")
 SET captions->rpt_three = uar_i18ngetmessage(i18nhandle,"rpt_three","THREE")
 SET captions->rpt_four = uar_i18ngetmessage(i18nhandle,"rpt_four","FOUR")
 SET captions->rpt_five = uar_i18ngetmessage(i18nhandle,"rpt_five","FIVE")
 SET captions->rptsix1 = uar_i18ngetmessage(i18nhandle,"rpt_six","SIX")
 SET captions->rpt_seven = uar_i18ngetmessage(i18nhandle,"rpt_seven","SEVEN")
 SET captions->rpt_eight = uar_i18ngetmessage(i18nhandle,"rpt_eight","EIGHT")
 SET captions->rpt_nine = uar_i18ngetmessage(i18nhandle,"rpt_nine","NINE")
 SET captions->rpt_ten = uar_i18ngetmessage(i18nhandle,"rpt_ten","TEN")
 SET captions->rpt_eleven = uar_i18ngetmessage(i18nhandle,"rpt_eleven","ELEVEN")
 SET captions->rpt_twelve = uar_i18ngetmessage(i18nhandle,"rpt_twelve","TWELVE")
 SET captions->rpt_thirteen = uar_i18ngetmessage(i18nhandle,"rpt_thirteen","THIRTEEN")
 SET captions->rpt_fourteen = uar_i18ngetmessage(i18nhandle,"rpt_fourteen","FOURTEEN")
 SET captions->rpt_fifteen = uar_i18ngetmessage(i18nhandle,"rpt_fifteen","FIFTEEN")
 SET captions->rpt_temp = uar_i18ngetmessage(i18nhandle,"rpt_temp","TEMP")
 SET captions->rpt_perm = uar_i18ngetmessage(i18nhandle,"rpt_perm","PERMNENT")
 SET captions->rpt_t = uar_i18ngetmessage(i18nhandle,"rpt_t","T")
 SET captions->rpt_bbd = uar_i18ngetmessage(i18nhandle,"rpt_bbd","bbd_rpt_mailing_list.prg")
 SET captions->rpt_select = uar_i18ngetmessage(i18nhandle,"rpt_select","Select")
 SET captions->rpt_code = uar_i18ngetmessage(i18nhandle,"rpt_code","CODE_VALUE")
 SET captions->rpt_unable_read_temp = uar_i18ngetmessage(i18nhandle,"rpt_unable_read_temp",
  "Unable to read temporary eligibility type code value")
 SET captions->rpt_unable_read_perm = uar_i18ngetmessage(i18nhandle,"rpt_unable_read_perm",
  "Unable to read permanent eligibility type code value")
 SET captions->rpt_callback = uar_i18ngetmessage(i18nhandle,"rpt_callback","CALLBACK")
 SET captions->rpt_mail = uar_i18ngetmessage(i18nhandle,"rpt_mail","MAILING")
 SET captions->rpt_s = uar_i18ngetmessage(i18nhandle,"rpt_s","S")
 SET captions->rpt_bbdmail = uar_i18ngetmessage(i18nhandle,"rpt_bbdmail","bbdmail")
 RECORD current(
   1 system_dt_tm = dq8
 )
 SET current->system_dt_tm = cnvtdatetime(curdate,curtime3)
 SET reply->status_data.status = captions->rpt_f
 SET failed = captions->rpt_f
 SET acount = size(request->antigen,5)
 SET zcount = size(request->zipcode,5)
 SET linecount = 0
 SET aliascount = 0
 SET antigencount = 0
 SET antibodycount = 0
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
 SET cdf_mean = fillstring(12," ")
 SET code_set = 0
 SET code_cnt = 1
 SET sfiledate = format(curdate,"@DATECONDENSED;;d")
 SET sfiletime = substring(1,6,format(curtime3,"@TIME;;s"))
 SET sfilename = build(captions->rpt_bbdmail,sfiledate,sfiletime)
 SET stat = alterlist(reply->report_name_list,1)
 SET reply->report_name_list[1].report_name = concat(captions->rpt_cer_temp,sfilename,captions->
  rpt_txt)
 DECLARE days_until_eligible = i4 WITH protect
 IF ((request->person_id > 0))
  SELECT INTO concat(captions->rpt_cer_temp,sfilename,captions->rpt_txt)
   first_display = substring(1,40,pn.name_first), last_display = substring(1,60,pn.name_last), ad
   .street_addr,
   ad.street_addr2, state_display = substring(1,30,ad.state), country_display = substring(1,100,
    uar_get_code_display(ad.country_cd)),
   city_display = substring(1,40,ad.city), zip_display = substring(1,20,ad.zipcode)
   FROM person_name pn,
    address ad
   PLAN (pn
    WHERE (pn.person_id=request->person_id)
     AND pn.active_ind=1)
    JOIN (ad
    WHERE ad.parent_entity_id=pn.person_id
     AND (ad.parent_entity_name=captions->rpt_mail)
     AND ad.active_ind=1)
   ORDER BY pn.person_id
   HEAD pn.person_id
    linecount = 3, name_display = concat(trim(first_display)," ",trim(last_display)), col 0,
    name_display
    IF (ad.street_addr != null)
     row + 1, col 0, ad.street_addr
    ELSE
     linecount = (linecount+ 1)
    ENDIF
    IF (ad.street_addr2 != null)
     row + 1, col 0, ad.street_addr2
    ELSE
     linecount = (linecount+ 1)
    ENDIF
    city_state_zip_display = concat(trim(city_display),", ",trim(state_display),"  ",trim(zip_display
      ))
    IF (city_state_zip_display != ",  ")
     row + 1, col 0, city_state_zip_display
    ELSE
     linecount = (linecount+ 1)
    ENDIF
    country = trim(country_display)
    IF (country != null
     AND (country != captions->rpt_usa))
     row + 1, col 0, country
    ELSE
     linecount = (linecount+ 1)
    ENDIF
   FOOT  pn.person_id
    row + linecount
   WITH counter, compress, nolandscape,
    nullreport
  ;end select
 ELSE
  SET code_set = 14236
  SET cdf_mean = captions->rpt_one
  SET code_cnt = 1
  SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,code_cnt,one_cd)
  SET cdf_mean = captions->rpt_two
  SET code_cnt = 1
  SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,code_cnt,two_cd)
  SET cdf_mean = captions->rpt_three
  SET code_cnt = 1
  SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,code_cnt,three_cd)
  SET cdf_mean = captions->rpt_four
  SET code_cnt = 1
  SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,code_cnt,four_cd)
  SET cdf_mean = captions->rpt_five
  SET code_cnt = 1
  SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,code_cnt,five_cd)
  SET cdf_mean = captions->rpt_six
  SET code_cnt = 1
  SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,code_cnt,six_cd)
  SET cdf_mean = captions->rpt_seven
  SET code_cnt = 1
  SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,code_cnt,seven_cd)
  SET cdf_mean = captions->rpt_eight
  SET code_cnt = 1
  SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,code_cnt,eight_cd)
  SET cdf_mean = captions->rpt_nine
  SET code_cnt = 1
  SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,code_cnt,nine_cd)
  SET cdf_mean = captions->rpt_ten
  SET code_cnt = 1
  SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,code_cnt,ten_cd)
  SET cdf_mean = captions->rpt_eleven
  SET code_cnt = 1
  SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,code_cnt,eleven_cd)
  SET cdf_mean = captions->rpt_twelve
  SET code_cnt = 1
  SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,code_cnt,twelve_cd)
  SET cdf_mean = captions->rpt_thirteen
  SET code_cnt = 1
  SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,code_cnt,thirteen_cd)
  SET cdf_mean = captions->rpt_fourteen
  SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,code_cnt,fourteen_cd)
  SET cdf_mean = captions->rpt_fifteen
  SET code_cnt = 1
  SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,code_cnt,fifteen_cd)
  SET code_set = 14237
  SET cdf_mean = captions->rpt_temp
  SET code_cnt = 1
  SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,code_cnt,temp_cd)
  SET cdf_mean = captions->rpt_perm
  SET code_cnt = 1
  SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,code_cnt,permnent_cd)
  IF (((temp_cd=0.0) OR (permnent_cd=0.0)) )
   SET failed = captions->rpt_t
   SET reply->status_data.subeventstatus[1].sourceobjectname = captions->rpt_bbd
   SET reply->status_data.subeventstatus[1].operationname = captions->rpt_select
   SET reply->status_data.subeventstatus[1].targetobjectname = captions->rpt_code
   IF (temp_cd=0.0)
    SET reply->status_data.subeventstatus[1].targetobjectvalue = captions->rpt_unable_read_temp
   ELSEIF (permnent_cd=0.0)
    SET reply->status_data.subeventstatus[1].targetobjectvalue = captions->rpt_unable_read_perm
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
   SELECT INTO concat(captions->rpt_cer_temp,sfilename,captions->rpt_txt)
    first_display = substring(1,40,pn.name_first), last_display = substring(1,60,pn.name_last), ad
    .street_addr,
    ad.street_addr2, state_display = substring(1,30,ad.state), country_display = substring(1,100,
     uar_get_code_display(ad.country_cd)),
    city_display = substring(1,40,ad.city), zip_display = substring(1,20,ad.zipcode)
    FROM bbd_donation_results dr,
     bbd_donor_contact dc,
     code_value cv,
     person_name pn,
     address ad,
     person p,
     person_aborh pa,
     person_donor pd,
     bbd_special_interest i,
     bbd_rare_types r
    PLAN (dr
     WHERE dr.active_ind=1
      AND (((request->donation_procedure_cd > 0.0)
      AND datetimeadd(dr.drawn_dt_tm,days_until_eligible) BETWEEN cnvtdatetime(request->from_dt_tm)
      AND cnvtdatetime(request->to_dt_tm)) OR ((request->donation_procedure_cd=0.0))) )
     JOIN (pd
     WHERE pd.person_id=dr.person_id
      AND pd.mailings_ind=1
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
      AND (cv.cdf_meaning=captions->rpt_callback)
      AND cv.code_value=dc.contact_outcome_cd) OR (dc.contact_id=0.0
      AND cv.code_value=0.0)) )
     JOIN (pn
     WHERE pn.person_id=pd.person_id
      AND pn.active_ind=1)
     JOIN (ad
     WHERE ad.parent_entity_id=pn.person_id
      AND (ad.parent_entity_name=captions->rpt_mail)
      AND ad.active_ind=1)
    ORDER BY pd.person_id
    HEAD pd.person_id
     linecount = 3, name_display = concat(trim(first_display)," ",trim(last_display)), col 0,
     name_display
     IF (ad.street_addr != null)
      row + 1, col 0, ad.street_addr
     ELSE
      linecount = (linecount+ 1)
     ENDIF
     IF (ad.street_addr2 != null)
      row + 1, col 0, ad.street_addr2
     ELSE
      linecount = (linecount+ 1)
     ENDIF
     city_state_zip_display = concat(trim(city_display),", ",trim(state_display),"  ",trim(
       zip_display))
     IF (city_state_zip_display != ",  ")
      row + 1, col 0, city_state_zip_display
     ELSE
      linecount = (linecount+ 1)
     ENDIF
     country = trim(country_display)
     IF (country != null
      AND (country != captions->rpt_usa))
      row + 1, col 0, country
     ELSE
      linecount = (linecount+ 1)
     ENDIF
    FOOT  pd.person_id
     row + linecount
    WITH counter, outerjoin = dc, compress,
     nolandscape, nullreport
   ;end select
  ELSEIF (acount > 0
   AND zcount=0)
   SELECT INTO concat(captions->rpt_cer_temp,sfilename,captions->rpt_txt)
    first_display = substring(1,40,pn.name_first), last_display = substring(1,60,pn.name_last), ad
    .street_addr,
    ad.street_addr2, state_display = substring(1,30,ad.state), country_display = substring(1,100,
     uar_get_code_display(ad.country_cd)),
    city_display = substring(1,40,ad.city), zip_display = substring(1,20,ad.zipcode)
    FROM bbd_donation_results dr,
     bbd_donor_contact dc,
     code_value cv,
     procedure_eligibility_r pe,
     person_name pn,
     address ad,
     person p,
     person_aborh pa,
     person_donor pd,
     bbd_special_interest i,
     bbd_rare_types r,
     person_antigen pg,
     (dummyt d1  WITH seq = value(acount))
    PLAN (dr
     WHERE dr.active_ind=1
      AND (((request->donation_procedure_cd > 0.0)
      AND datetimeadd(dr.drawn_dt_tm,days_until_eligible) BETWEEN cnvtdatetime(request->from_dt_tm)
      AND cnvtdatetime(request->to_dt_tm)) OR ((request->donation_procedure_cd=0.0))) )
     JOIN (pd
     WHERE pd.person_id=dr.person_id
      AND pd.mailings_ind=1
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
      AND (cv.cdf_meaning=captions->rpt_callback)
      AND cv.code_value=dc.contact_outcome_cd) OR (dc.contact_id=0.0
      AND cv.code_value=0.0)) )
     JOIN (d1)
     JOIN (pg
     WHERE pg.person_id=pd.person_id
      AND (pg.antigen_cd=request->antigen[d1.seq].antigen_cd)
      AND pg.active_ind=1)
     JOIN (pn
     WHERE pn.person_id=pd.person_id
      AND pn.active_ind=1)
     JOIN (ad
     WHERE ad.parent_entity_id=pn.person_id
      AND (ad.parent_entity_name=captions->rpt_mail)
      AND ad.active_ind=1)
    ORDER BY pd.person_id
    HEAD pd.person_id
     linecount = 3, name_display = concat(trim(first_display)," ",trim(last_display)), col 0,
     name_display
     IF (ad.street_addr != null)
      row + 1, col 0, ad.street_addr
     ELSE
      linecount = (linecount+ 1)
     ENDIF
     IF (ad.street_addr2 != null)
      row + 1, col 0, ad.street_addr2
     ELSE
      linecount = (linecount+ 1)
     ENDIF
     city_state_zip_display = concat(trim(city_display),", ",trim(state_display),"  ",trim(
       zip_display))
     IF (city_state_zip_display != ",  ")
      row + 1, col 0, city_state_zip_display
     ELSE
      linecount = (linecount+ 1)
     ENDIF
     country = trim(country_display)
     IF (country != null
      AND (country != captions->rpt_usa))
      row + 1, col 0, country
     ELSE
      linecount = (linecount+ 1)
     ENDIF
    FOOT  pd.person_id
     row + linecount
    WITH counter, outerjoin = dc, compress,
     nolandscape, nullreport
   ;end select
  ELSEIF (acount=0
   AND zcount > 0)
   SELECT INTO concat("captions->rpt_cer_temp",sfilename,"captions->rpt_txt")
    first_display = substring(1,40,pn.name_first), last_display = substring(1,60,pn.name_last), ad
    .street_addr,
    ad.street_addr2, state_display = substring(1,30,ad.state), country_display = substring(1,100,
     uar_get_code_display(ad.country_cd)),
    city_display = substring(1,40,ad.city), zip_display = substring(1,20,ad.zipcode)
    FROM bbd_donation_results dr,
     bbd_donor_contact dc,
     code_value cv,
     procedure_eligibility_r pe,
     person_name pn,
     address ad,
     person p,
     person_aborh pa,
     person_donor pd,
     bbd_special_interest i,
     bbd_rare_types r,
     person_zipcode pz,
     (dummyt d1  WITH seq = value(zcount))
    PLAN (dr
     WHERE dr.active_ind=1
      AND (((request->donation_procedure_cd > 0.0)
      AND datetimeadd(dr.drawn_dt_tm,days_until_eligible) BETWEEN cnvtdatetime(request->from_dt_tm)
      AND cnvtdatetime(request->to_dt_tm)) OR ((request->donation_procedure_cd=0.0))) )
     JOIN (pd
     WHERE pd.person_id=dr.person_id
      AND pd.mailings_ind=1
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
      AND (cv.cdf_meaning=captions->rpt_callback)
      AND cv.code_value=dc.contact_outcome_cd) OR (dc.contact_id=0.0
      AND cv.code_value=0.0)) )
     JOIN (d1)
     JOIN (pz
     WHERE pz.person_id=pd.person_id
      AND (pz.zip_code=request->zipcode[d1.seq].zip_code)
      AND pz.active_ind=1)
     JOIN (pn
     WHERE pn.person_id=pd.person_id
      AND pn.active_ind=1)
     JOIN (ad
     WHERE ad.parent_entity_id=pn.person_id
      AND (ad.parent_entity_name=captions->rpt_mail)
      AND ad.active_ind=1)
    ORDER BY pd.person_id
    HEAD pd.person_id
     linecount = 3, name_display = concat(trim(first_display)," ",trim(last_display)), col 0,
     name_display
     IF (ad.street_addr != null)
      row + 1, col 0, ad.street_addr
     ELSE
      linecount = (linecount+ 1)
     ENDIF
     IF (ad.street_addr2 != null)
      row + 1, col 0, ad.street_addr2
     ELSE
      linecount = (linecount+ 1)
     ENDIF
     city_state_zip_display = concat(trim(city_display),", ",trim(state_display),"  ",trim(
       zip_display))
     IF (city_state_zip_display != ",  ")
      row + 1, col 0, city_state_zip_display
     ELSE
      linecount = (linecount+ 1)
     ENDIF
     country = trim(country_display)
     IF (country != null
      AND (country != captions->rpt_usa))
      row + 1, col 0, country
     ELSE
      linecount = (linecount+ 1)
     ENDIF
    FOOT  pd.person_id
     row + linecount
    WITH counter, outerjoin = dc, compress,
     nolandscape, nullreport
   ;end select
  ELSE
   SELECT INTO concat("captions->rpt_cer_temp",sfilename,"captions->rpt_txt")
    first_display = substring(1,40,pn.name_first), last_display = substring(1,60,pn.name_last), ad
    .street_addr,
    ad.street_addr2, state_display = substring(1,30,ad.state), country_display = substring(1,100,
     uar_get_code_display(ad.country_cd)),
    city_display = substring(1,40,ad.city), zip_display = substring(1,20,ad.zipcode)
    FROM bbd_donation_results dr,
     bbd_donor_contact dc,
     code_value cv,
     procedure_eligibility_r pe,
     person_name pn,
     address ad,
     person p,
     person_aborh pa,
     person_donor pd,
     bbd_special_interest i,
     bbd_rare_types r,
     person_antigen pg,
     person_zipcode pz,
     (dummyt d1  WITH seq = value(acount)),
     (dummyt d2  WITH seq = value(zcount))
    PLAN (dr
     WHERE dr.active_ind=1
      AND (((request->donation_procedure_cd > 0.0)
      AND datetimeadd(dr.drawn_dt_tm,days_until_eligible) BETWEEN cnvtdatetime(request->from_dt_tm)
      AND cnvtdatetime(request->to_dt_tm)) OR ((request->donation_procedure_cd=0.0))) )
     JOIN (pd
     WHERE pd.person_id=dr.person_id
      AND pd.mailings_ind=1
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
      AND (cv.cdf_meaning=captions->rpt_callback)
      AND cv.code_value=dc.contact_outcome_cd) OR (dc.contact_id=0.0
      AND cv.code_value=0.0)) )
     JOIN (d1)
     JOIN (pg
     WHERE pg.person_id=pd.person_id
      AND (pg.antigen_cd=request->antigen[d1.seq].antigen_cd)
      AND pg.active_ind=1)
     JOIN (d2)
     JOIN (pz
     WHERE pz.person_id=pd.person_id
      AND (pz.zip_code=request->zipcode[d1.seq].zip_code)
      AND pz.active_ind=1)
     JOIN (pn
     WHERE pn.person_id=pd.person_id
      AND pn.active_ind=1)
     JOIN (ad
     WHERE ad.parent_entity_id=pn.person_id
      AND (ad.parent_entity_name=captions->rpt_mail)
      AND ad.active_ind=1)
    ORDER BY pd.person_id
    HEAD pd.person_id
     linecount = 3, name_display = concat(trim(first_display)," ",trim(last_display)), col 0,
     name_display
     IF (ad.street_addr != null)
      row + 1, col 0, ad.street_addr
     ELSE
      linecount = (linecount+ 1)
     ENDIF
     IF (ad.street_addr2 != null)
      row + 1, col 0, ad.street_addr2
     ELSE
      linecount = (linecount+ 1)
     ENDIF
     city_state_zip_display = concat(trim(city_display),", ",trim(state_display),"  ",trim(
       zip_display))
     IF (city_state_zip_display != ",  ")
      row + 1, col 0, city_state_zip_display
     ELSE
      linecount = (linecount+ 1)
     ENDIF
     country = trim(country_display)
     IF (country != null
      AND (country != captions->rpt_usa))
      row + 1, col 0, country
     ELSE
      linecount = (linecount+ 1)
     ENDIF
    FOOT  pd.person_id
     row + linecount
    WITH counter, outerjoin = dc, compress,
     nolandscape, nullreport
   ;end select
  ENDIF
 ENDIF
#exit_script
 IF ((failed=captions->rpt_t))
  SET reply->status_data.status = captions->rpt_f
  ROLLBACK
 ELSE
  SET reply->status_data.status = captions->rpt_s
  COMMIT
 ENDIF
END GO
