CREATE PROGRAM bbd_get_recruiting_search:dba
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
 DECLARE formatage(birth_dt_tm=f8,deceased_dt_tm=f8,policy=vc) = vc WITH protect
 DECLARE susername = c50 WITH protect, noconstant("")
 DECLARE nstatus = i4 WITH protect, noconstant(0)
 DECLARE i18nhandle = i4 WITH protect, noconstant(0)
 DECLARE sunknownstring = vc WITH protect, noconstant("")
 DECLARE sstillbornstring = vc WITH protect, noconstant("")
 SET nstatus = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET sunknownstring = uar_i18ngetmessage(i18nhandle,"UNKNOWN_AGE","Unknown")
 SET sstillbornstring = uar_i18ngetmessage(i18nhandle,"STILLBORN_AGE","Stillborn")
 SELECT INTO "nl:"
  FROM prsnl pl
  WHERE (person_id=reqinfo->updt_id)
  DETAIL
   susername = pl.username
  WITH nocounter
 ;end select
 SUBROUTINE formatage(birth_dt_tm,deceased_dt_tm,policy)
   DECLARE eff_end_dt_tm = f8 WITH private, noconstant(0.0)
   SET eff_end_dt_tm = deceased_dt_tm
   IF (((eff_end_dt_tm=null) OR (eff_end_dt_tm=0.00)) )
    SET eff_end_dt_tm = cnvtdatetime(curdate,curtime3)
   ENDIF
   IF (((birth_dt_tm > eff_end_dt_tm) OR (birth_dt_tm=null)) )
    RETURN(sunknownstring)
   ELSEIF (birth_dt_tm=deceased_dt_tm)
    RETURN(sstillbornstring)
   ELSE
    RETURN(cnvtage2(birth_dt_tm,eff_end_dt_tm,0,concat(policy,"/",trim(susername),"/",cnvtstring(
       reqinfo->position_cd))))
   ENDIF
 END ;Subroutine
 RECORD reply(
   1 person_id = f8
   1 name_full_formatted = vc
   1 birth_dt_tm = di8
   1 age = vc
   1 sex_cd = f8
   1 sex_cd_disp = vc
   1 race_cd = f8
   1 race_cd_disp = vc
   1 species_cd = f8
   1 species_cd_disp = vc
   1 nationality_cd = f8
   1 nationality_cd_disp = vc
   1 marital_type_cd = f8
   1 marital_type_cd_disp = vc
   1 maiden_name = vc
   1 eligibility_type_cd = f8
   1 eligibility_type_cd_disp = vc
   1 eligibility_type_cd_mean = vc
   1 watch_ind = i2
   1 lock_ind = i2
   1 updt_cnt = i4
   1 defer_until_dt_tm = di8
   1 last_donation_dt_tm = di8
   1 willingness_level_cd = f8
   1 willingness_level_disp = vc
   1 willingness_level_mean = vc
   1 note_ind = i2
   1 abo_cd = f8
   1 abo_cd_disp = vc
   1 rh_cd = f8
   1 rh_cd_disp = vc
   1 phone_num = vc
   1 alias[*]
     2 person_alias_type_cd = f8
     2 person_alias_type_cd_disp = vc
     2 person_alias_type_cd_mean = vc
     2 person_alias = vc
   1 antigen[*]
     2 antigen_cd = f8
     2 antigen_cd_disp = vc
   1 antibody[*]
     2 antibody_cd = f8
     2 antibody_cd_disp = vc
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
 RECORD current(
   1 system_dt_tm = dq8
 )
 SET current->system_dt_tm = cnvtdatetime(curdate,curtime3)
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET acount = size(request->antigen,5)
 SET zcount = size(request->zipcode,5)
 SET aliascount = 0
 SET antigencount = 0
 SET antibodycount = 0
 SET hold_last_person = 0.0
 SET hold_updt_cnt = 0
 SET new_person_id = 0.0
 SET maiden_name_cd = 0.0
 SET ssn_cd = 0.0
 SET phone_num_cd = 0.0
 SET donor_id_cd = 0.0
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
 DECLARE days_until_eligible = i4 WITH protect
 SET days_until_eligible = 0
 SELECT INTO "nl:"
  l.last_person_id, l.updt_cnt
  FROM bbd_recruiting_list l
  WHERE (l.list_id=request->list_id)
  DETAIL
   hold_last_person = l.last_person_id, hold_updt_cnt = l.updt_cnt
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET failed = "T"
  SET reply->status = "S"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_get_recruiting_search.prg"
  SET reply->status_data.subeventstatus[1].operationname = "Select"
  SET reply->status_data.subeventstatus[1].targetobjectname = "BBD_RECRUITING_LIST"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Error retrieving the last_person_id from bbd_recruiting_list"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  GO TO exit_script
 ENDIF
 SET code_set = 14236
 SET cdf_mean = "ONE"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,1,one_cd)
 SET cdf_mean = "TWO"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,1,two_cd)
 SET cdf_mean = "THREE"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,1,three_cd)
 SET cdf_mean = "FOUR"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,1,four_cd)
 SET cdf_mean = "FIVE"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,1,five_cd)
 SET cdf_mean = "SIX"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,1,six_cd)
 SET cdf_mean = "SEVEN"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,1,seven_cd)
 SET cdf_mean = "EIGHT"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,1,eight_cd)
 SET cdf_mean = "NINE"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,1,nine_cd)
 SET cdf_mean = "TEN"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,1,ten_cd)
 SET cdf_mean = "ELEVEN"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,1,eleven_cd)
 SET cdf_mean = "TWELVE"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,1,twelve_cd)
 SET cdf_mean = "THIRTEEN"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,1,thirteen_cd)
 SET cdf_mean = "FOURTEEN"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,1,fourteen_cd)
 SET cdf_mean = "FIFTEEN"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,1,fifteen_cd)
 SET code_set = 14237
 SET cdf_mean = "TEMP"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,1,temp_cd)
 SET cdf_mean = "PERMNENT"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,1,permnent_cd)
 SET code_set = 4
 SET cdf_mean = "DONORID"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,1,donor_id_cd)
 SET cdf_mean = "SSN"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,1,ssn_cd)
 SET code_set = 43
 SET cdf_mean = "HOME"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,1,phone_num_cd)
 SET code_set = 213
 SET cdf_mean = "MAIDEN"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,1,maiden_name_cd)
 IF (((temp_cd=0.0) OR (((permnent_cd=0.0) OR (((donor_id_cd=0.0) OR (((ssn_cd=0.0) OR (((
 phone_num_cd=0.0) OR (maiden_name_cd=0.0)) )) )) )) )) )
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_get_recruiting_search.prg"
  SET reply->status_data.subeventstatus[1].operationname = "Select"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE"
  IF (temp_cd=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to read temporary eligibility type code value"
  ELSEIF (permnent_cd=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to read permanent eligibility type code value"
  ELSEIF (donor_id_cd=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "Unable to read donor id code value"
  ELSEIF (ssn_cd=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to read social security number code value"
  ELSEIF (phone_num_cd=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to read phone number type code value"
  ELSE
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to read maiden name code value"
  ENDIF
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 2
  GO TO exit_script
 ENDIF
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
  SELECT INTO "nl:"
   dr.person_id
   FROM bbd_donation_results dr,
    bbd_donor_contact dc,
    code_value cv,
    person p,
    donor_aborh da,
    person_donor pd,
    bbd_special_interest i,
    bbd_rare_types r
   PLAN (dr
    WHERE dr.person_id > hold_last_person
     AND (((request->donation_procedure_cd > 0.0)
     AND datetimeadd(dr.drawn_dt_tm,days_until_eligible) BETWEEN cnvtdatetime(request->from_dt_tm)
     AND cnvtdatetime(request->to_dt_tm)) OR ((request->donation_procedure_cd=0.0)))
     AND dr.active_ind=1)
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
     AND pd.willingness_level_cd=thirteen_cd) OR ((((pd.last_donation_dt_tm < (cnvtdatetime(current->
     system_dt_tm) - 26))
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
    JOIN (da
    WHERE (((request->abo_cd > 0.0)
     AND (request->rh_cd > 0.0)
     AND da.person_id=pd.person_id
     AND (da.abo_cd=request->abo_cd)
     AND (da.rh_cd=request->abo_cd)
     AND da.active_ind=1) OR ((request->abo_cd=0.0)
     AND (request->rh_cd=0.0)
     AND da.donor_aborh_id=0.0)) )
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
   ORDER BY dr.person_id, dr.drawn_dt_tm DESC
   DETAIL
    new_person_id = dr.person_id
   WITH counter, outerjoin = dc, maxrec = 1
  ;end select
 ELSEIF (acount > 0
  AND zcount=0)
  SELECT INTO "nl:"
   dr.person_id
   FROM bbd_donation_results dr,
    bbd_donor_contact dc,
    code_value cv,
    person p,
    donor_aborh da,
    person_donor pd,
    bbd_special_interest i,
    bbd_rare_types r,
    donor_antigen dn,
    encounter e,
    (dummyt d1  WITH seq = value(acount))
   PLAN (dr
    WHERE dr.person_id > hold_last_person
     AND (((request->donation_procedure_cd > 0.0)
     AND datetimeadd(dr.drawn_dt_tm,days_until_eligible) BETWEEN cnvtdatetime(request->from_dt_tm)
     AND cnvtdatetime(request->to_dt_tm)) OR ((request->donation_procedure_cd=0.0)))
     AND dr.active_ind=1)
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
     AND pd.willingness_level_cd=thirteen_cd) OR ((((pd.last_donation_dt_tm < (cnvtdatetime(current->
     system_dt_tm) - 26))
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
    JOIN (da
    WHERE (((request->abo_cd > 0.0)
     AND (request->rh_cd > 0.0)
     AND da.person_id=pd.person_id
     AND (da.abo_cd=request->abo_cd)
     AND (da.rh_cd=request->abo_cd)
     AND da.active_ind=1) OR ((request->abo_cd=0.0)
     AND (request->rh_cd=0.0)
     AND da.donor_aborh_id=0.0)) )
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
    JOIN (e
    WHERE e.person_id=pd.person_id)
    JOIN (d1)
    JOIN (dn
    WHERE dn.encntr_id=e.encntr_id
     AND (dn.antigen_cd=request->antigen[d1.seq].antigen_cd)
     AND dn.active_ind=1)
   ORDER BY dr.person_id, dr.drawn_dt_tm DESC
   DETAIL
    new_person_id = dr.person_id
   WITH counter, outerjoin = dc, maxrec = 1
  ;end select
 ELSEIF (acount=0
  AND zcount > 0)
  SELECT INTO "nl:"
   dr.person_id
   FROM bbd_donation_results dr,
    bbd_donor_contact dc,
    code_value cv,
    person p,
    donor_aborh da,
    person_donor pd,
    bbd_special_interest i,
    bbd_rare_types r,
    person_zipcode pz,
    (dummyt d1  WITH seq = value(zcount))
   PLAN (dr
    WHERE dr.person_id > hold_last_person
     AND (((request->donation_procedure_cd > 0.0)
     AND datetimeadd(dr.drawn_dt_tm,days_until_eligible) BETWEEN cnvtdatetime(request->from_dt_tm)
     AND cnvtdatetime(request->to_dt_tm)) OR ((request->donation_procedure_cd=0.0)))
     AND dr.active_ind=1)
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
     AND pd.willingness_level_cd=thirteen_cd) OR ((((pd.last_donation_dt_tm < (cnvtdatetime(current->
     system_dt_tm) - 26))
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
    JOIN (da
    WHERE (((request->abo_cd > 0.0)
     AND (request->rh_cd > 0.0)
     AND da.person_id=pd.person_id
     AND (da.abo_cd=request->abo_cd)
     AND (da.rh_cd=request->abo_cd)
     AND da.active_ind=1) OR ((request->abo_cd=0.0)
     AND (request->rh_cd=0.0)
     AND da.donor_aborh_id=0.0)) )
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
    JOIN (d1)
    JOIN (pz
    WHERE pz.person_id=pd.person_id
     AND (pz.zip_code=request->zipcode[d1.seq].zip_code)
     AND pz.active_ind=1)
   ORDER BY dr.person_id, dr.drawn_dt_tm DESC
   DETAIL
    new_person_id = dr.person_id
   WITH counter, outerjoin = dc, maxrec = 1
  ;end select
 ELSE
  SELECT INTO "nl:"
   dr.person_id
   FROM bbd_donation_results dr,
    bbd_donor_contact dc,
    code_value cv,
    person p,
    donor_aborh da,
    person_donor pd,
    bbd_special_interest i,
    bbd_rare_types r,
    donor_antigen dn,
    encounter e,
    person_zipcode pz,
    (dummyt d1  WITH seq = value(acount)),
    (dummyt d2  WITH seq = value(zcount))
   PLAN (dr
    WHERE dr.person_id > hold_last_person
     AND (((request->donation_procedure_cd > 0.0)
     AND datetimeadd(dr.drawn_dt_tm,days_until_eligible) BETWEEN cnvtdatetime(request->from_dt_tm)
     AND cnvtdatetime(request->to_dt_tm)) OR ((request->donation_procedure_cd=0.0)))
     AND dr.active_ind=1)
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
     AND pd.willingness_level_cd=thirteen_cd) OR ((((pd.last_donation_dt_tm < (cnvtdatetime(current->
     system_dt_tm) - 26))
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
    JOIN (da
    WHERE (((request->abo_cd > 0.0)
     AND (request->rh_cd > 0.0)
     AND da.person_id=pd.person_id
     AND (da.abo_cd=request->abo_cd)
     AND (da.rh_cd=request->abo_cd)
     AND da.active_ind=1) OR ((request->abo_cd=0.0)
     AND (request->rh_cd=0.0)
     AND da.donor_aborh_id=0.0)) )
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
    JOIN (e
    WHERE e.person_id=pd.person_id)
    JOIN (d1)
    JOIN (dn
    WHERE dn.encntr_id=e.encntr_id
     AND (dn.antigen_cd=request->antigen[d1.seq].antigen_cd)
     AND dn.active_ind=1)
    JOIN (d2)
    JOIN (pz
    WHERE pz.person_id=pd.person_id
     AND (pz.zip_code=request->zipcode[d1.seq].zip_code)
     AND pz.active_ind=1)
   ORDER BY dr.person_id, dr.drawn_dt_tm DESC
   DETAIL
    new_person_id = dr.person_id
   WITH counter, outerjoin = dc, maxrec = 1
  ;end select
 ENDIF
 SELECT INTO "nl:"
  p.name_full_formatted, p.birth_dt_tm, p.species_cd,
  p.race_cd, p.nationality_cd, p.sex_cd,
  p.marital_type_cd, dn.antigen_cd, db.antibody_cd
  FROM person p,
   donor_antigen dn,
   donor_antibody db,
   encounter e,
   (dummyt d1  WITH seq = 1),
   (dummyt d2  WITH seq = 1)
  PLAN (p
   WHERE p.person_id=new_person_id)
   JOIN (e
   WHERE e.person_id=p.person_id)
   JOIN (((d1
   WHERE d1.seq=1)
   JOIN (dn
   WHERE dn.encntr_id=e.encntr_id
    AND dn.active_ind=1)
   ) ORJOIN ((d2
   WHERE d2.seq=1)
   JOIN (db
   WHERE db.encntr_id=e.encntr_id
    AND db.active_ind=1)
   ))
  ORDER BY dn.antigen_cd
  HEAD REPORT
   reply->name_full_formatted = p.name_full_formatted, reply->birth_dt_tm = p.birth_dt_tm, reply->age
    = formatage(p.birth_dt_tm,p.deceased_dt_tm,"CHRONOAGE"),
   reply->sex_cd = p.sex_cd, reply->race_cd = p.race_cd, reply->species_cd = p.species_cd,
   reply->nationality_cd = p.nationality_cd, reply->marital_type_cd = p.marital_type_cd
  HEAD dn.antigen_cd
   IF (dn.antigen_cd > 0)
    antigencount = (antigencount+ 1), stat = alterlist(reply->antigen,antigencount), reply->antigen[
    antigencount].antigen_cd = dn.antigen_cd
   ENDIF
  FOOT  db.antibody_cd
   IF (db.antibody_cd > 0)
    antibodycount = (antibodycount+ 1), stat = alterlist(reply->antibody,antibodycount), reply->
    antibody[antibodycount].antibody_cd = db.antibody_cd
   ENDIF
  WITH counter, outerjoin = d1, outerjoin = d2
 ;end select
 SELECT INTO "nl:"
  a.person_alias_type_cd, a.alias
  FROM person_alias a
  PLAN (a
   WHERE a.person_id=new_person_id
    AND a.person_alias_type_cd IN (ssn_cd, donor_id_cd)
    AND a.active_ind=1)
  ORDER BY a.person_alias_type_cd
  HEAD a.person_alias_type_cd
   IF (a.person_alias_type_cd > 0)
    aliascount = (aliascount+ 1), stat = alterlist(reply->alias,aliascount), reply->alias[aliascount]
    .person_alias_type_cd = a.person_alias_type_cd,
    reply->alias[aliascount].person_alias = a.alias
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  pd.updt_cnt, pd.eligibility_type_cd, pd.watch_ind,
  pd.lock_ind, dn.donor_note_id
  FROM person_donor pd,
   bbd_donor_note dn,
   dummyt d
  PLAN (pd
   WHERE pd.person_id=new_person_id
    AND pd.active_ind=1)
   JOIN (d)
   JOIN (dn
   WHERE dn.person_id=pd.person_id
    AND dn.active_ind=1)
  HEAD REPORT
   reply->eligibility_type_cd = pd.eligibility_type_cd, reply->watch_ind = pd.watch_ind, reply->
   updt_cnt = pd.updt_cnt,
   reply->lock_ind = pd.lock_ind
   IF (dn.donor_note_id > 0.0)
    reply->note_ind = 1
   ELSE
    reply->note_ind = 0
   ENDIF
  WITH nocounter, outerjoin = d
 ;end select
 SELECT INTO "nl:"
  da.abo_cd, da.rh_cd
  FROM donor_aborh da
  PLAN (da
   WHERE da.person_id=new_person_id
    AND da.active_ind=1)
  HEAD REPORT
   reply->abo_cd = da.abo_cd, reply->rh_cd = da.rh_cd
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  pn.name_full
  FROM person_name pn
  PLAN (pn
   WHERE pn.person_id=new_person_id
    AND pn.name_type_cd=maiden_name_cd
    AND pn.active_ind=1)
  HEAD REPORT
   reply->maiden_name = pn.name_full
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  ph.phone_num
  FROM phone ph
  PLAN (ph
   WHERE ph.parent_entity_id=new_person_id
    AND ph.parent_entity_name="PERSON"
    AND ph.phone_type_cd=phone_num_cd
    AND cnvtdatetime(curdate,curtime3) >= ph.beg_effective_dt_tm
    AND cnvtdatetime(curdate,curtime3) <= ph.end_effective_dt_tm
    AND ph.active_ind=1)
  HEAD REPORT
   reply->phone_num = ph.phone_num
  WITH nocounter
 ;end select
 UPDATE  FROM bbd_recruiting_list l
  SET l.last_person_id = new_person_id, l.updt_applctx = reqinfo->updt_applctx, l.updt_dt_tm =
   cnvtdatetime(current->system_dt_tm),
   l.updt_id = reqinfo->updt_id, l.updt_task = reqinfo->updt_task, l.updt_cnt = (l.updt_cnt+ 1)
  WHERE (l.list_id=request->list_id)
   AND l.updt_cnt=hold_updt_cnt
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET failed = "T"
  SET reply->status = "S"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_get_recruiting_search.prg"
  SET reply->status_data.subeventstatus[1].operationname = "Update"
  SET reply->status_data.subeventstatus[1].targetobjectname = "BBD_RECRUITING_LIST"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Error updating the last_person_id in bbd_recruiting_list"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 3
  GO TO exit_script
 ENDIF
 SET reply->person_id = new_person_id
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
  ROLLBACK
 ELSE
  SET reply->status_data.status = "S"
  COMMIT
 ENDIF
END GO
