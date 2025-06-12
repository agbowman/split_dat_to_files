CREATE PROGRAM bbt_get_person:dba
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
 SUBROUTINE (formatage(birth_dt_tm=f8,deceased_dt_tm=f8,policy=vc) =vc WITH protect)
   DECLARE eff_end_dt_tm = f8 WITH private, noconstant(0.0)
   SET eff_end_dt_tm = deceased_dt_tm
   IF (((eff_end_dt_tm=null) OR (eff_end_dt_tm=0.00)) )
    SET eff_end_dt_tm = cnvtdatetime(sysdate)
   ENDIF
   IF (((birth_dt_tm > eff_end_dt_tm) OR (birth_dt_tm=null)) )
    RETURN(sunknownstring)
   ELSEIF (birth_dt_tm=deceased_dt_tm)
    RETURN(sstillbornstring)
   ELSE
    RETURN(cnvtage2(birth_dt_tm,eff_end_dt_tm,0,concat(policy,"/",trim(susername),"/",trim(cnvtstring
       (reqinfo->position_cd,32,2)))))
   ENDIF
 END ;Subroutine
 CALL echo("*****PM_HEADER_CCL.inc - 668615****")
 IF ((validate(gen_nbr_error,- (9))=- (9)))
  DECLARE gen_nbr_error = i2 WITH constant(3)
 ENDIF
 IF ((validate(insert_error,- (9))=- (9)))
  DECLARE insert_error = i2 WITH constant(4)
 ENDIF
 IF ((validate(update_error,- (9))=- (9)))
  DECLARE update_error = i2 WITH constant(5)
 ENDIF
 IF ((validate(replace_error,- (9))=- (9)))
  DECLARE replace_error = i2 WITH constant(6)
 ENDIF
 IF ((validate(delete_error,- (9))=- (9)))
  DECLARE delete_error = i2 WITH constant(7)
 ENDIF
 IF ((validate(undelete_error,- (9))=- (9)))
  DECLARE undelete_error = i2 WITH constant(8)
 ENDIF
 IF ((validate(remove_error,- (9))=- (9)))
  DECLARE remove_error = i2 WITH constant(9)
 ENDIF
 IF ((validate(attribute_error,- (9))=- (9)))
  DECLARE attribute_error = i2 WITH constant(10)
 ENDIF
 IF ((validate(lock_error,- (9))=- (9)))
  DECLARE lock_error = i2 WITH constant(11)
 ENDIF
 IF ((validate(none_found,- (9))=- (9)))
  DECLARE none_found = i2 WITH constant(12)
 ENDIF
 IF ((validate(select_error,- (9))=- (9)))
  DECLARE select_error = i2 WITH constant(13)
 ENDIF
 IF ((validate(add_history_error,- (9))=- (9)))
  DECLARE add_history_error = i2 WITH constant(14)
 ENDIF
 IF ((validate(transaction_error,- (9))=- (9)))
  DECLARE transaction_error = i2 WITH constant(15)
 ENDIF
 IF ((validate(none_found_ft,- (9))=- (9)))
  DECLARE none_found_ft = i2 WITH constant(16)
 ENDIF
 IF ((validate(failed,- (9))=- (9)))
  DECLARE failed = i2 WITH noconstant(false)
 ENDIF
 IF (validate(table_name,"ZZZ")="ZZZ")
  DECLARE table_name = vc WITH noconstant("")
  SET table_name = fillstring(50," ")
 ENDIF
 RECORD reply(
   1 person_id = f8
   1 name_full_formatted = c100
   1 birth_dt_cd = f8
   1 birth_dt_tm = dq8
   1 age = vc
   1 birth_tz = i4
   1 race_cd = f8
   1 race_disp = c40
   1 sex_cd = f8
   1 sex_disp = c40
   1 encntr_id = f8
   1 location_cd = f8
   1 location_disp = c40
   1 loc_facility_cd = f8
   1 loc_facility_disp = c40
   1 loc_building_cd = f8
   1 loc_building_disp = c40
   1 loc_nurse_unit_cd = f8
   1 loc_nurse_unit_disp = c40
   1 loc_room_cd = f8
   1 loc_room_disp = c40
   1 loc_bed_cd = f8
   1 loc_bed_disp = c40
   1 reason_for_visit = vc
   1 admit_dr_id = f8
   1 admit_dr_disp = vc
   1 attend_dr_id = f8
   1 attend_dr_disp = vc
   1 alias_mrn = vc
   1 alias_ssn = vc
   1 bb_comment[*]
     2 comment = vc
     2 bb_comment_id = f8
     2 bb_comment_updt_cnt = i4
   1 abo_cd = f8
   1 abo_disp = c15
   1 rh_cd = f8
   1 rh_disp = c15
   1 person_aborh_id = f8
   1 person_aborh_updt_cnt = i4
   1 antibody[*]
     2 antibody_cd = f8
     2 antibody_disp = c40
     2 antibody_desc = c40
     2 antibody_seq = i4
     2 antigenneg_cnt = i4
     2 anti_d_ind = i2
     2 significance_ind = i2
     2 antigen_neg_list[*]
       3 antigen_cd = f8
       3 antigen_disp = c40
       3 antigen_seq = i4
       3 warn_ind = i2
       3 allow_override_ind = i2
   1 reqs[*]
     2 requirement_cd = f8
     2 requirement_disp = c40
     2 requirement_desc = c40
     2 requirement_seq = i4
     2 antigenneg_cnt = i4
     2 antigen_neg_list[*]
       3 antigen_cd = f8
       3 antigen_disp = c40
       3 antigen_seq = i4
       3 warn_ind = i2
       3 allow_override_ind = i2
       3 antigen_mean = vc
       3 isbt_mean = vc
     2 excluded_product_category_list[*]
       3 product_cat_cd = f8
       3 product_cat_disp = vc
   1 transfusions_ind = i2
   1 donor_abo_cd = f8
   1 donor_abo_disp = c15
   1 donor_abo_desc = c15
   1 donor_rh_cd = f8
   1 donor_rh_disp = c15
   1 donor_rh_desc = c15
   1 donor_aborh_id = f8
   1 donor_aborh_updt_cnt = i4
   1 donor_antibody[*]
     2 antibody_cd = f8
     2 antibody_disp = c40
     2 antibody_desc = c40
   1 aliaslist[*]
     2 alias_type_cd = f8
     2 alias_type_disp = vc
     2 alias_type_mean = c12
     2 alias = vc
     2 alias_formatted = vc
   1 species_cd = f8
   1 species_disp = vc
   1 age_in_minutes = f8
   1 unknown_age_ind = i2
   1 race_qual[*]
     2 race_cd = f8
     2 race_disp = c40
   1 birth_sex_cd = f8
   1 birth_sex_disp = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE anti_cnt = i4 WITH protect, noconstant(0)
 DECLARE race_codeset = i4 WITH protect, constant(282)
 DECLARE race_cnt = i4 WITH protect, noconstant(0)
 DECLARE dracemultiplecd = f8 WITH protect, constant(uar_get_code_by("MEANING",282,"MULTIPLE"))
 SET reply->status_data.status = "I"
 IF ((request->using_ptselect_ind=1))
  GO TO get_encounter_by_id
 ENDIF
 SELECT INTO "nl:"
  p.*
  FROM person p
  WHERE (p.person_id=request->person_id)
   AND p.active_ind=1
   AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
   AND p.end_effective_dt_tm >= cnvtdatetime(sysdate)
  DETAIL
   reply->person_id = p.person_id, reply->name_full_formatted = p.name_full_formatted, reply->
   birth_dt_cd = p.birth_dt_cd,
   reply->birth_dt_tm = p.birth_dt_tm, reply->age = formatage(p.birth_dt_tm,p.deceased_dt_tm,
    "CHRONOAGE"), reply->birth_tz = validate(p.birth_tz,0),
   reply->race_cd = p.race_cd, reply->sex_cd = p.sex_cd, reply->species_cd = p.species_cd,
   reply->age_in_minutes = (cnvtmin2(curdate,curtime,1) - cnvtmin2(cnvtdate2(format(p.birth_dt_tm,
      "mm/dd/yyyy;;d"),"mm/dd/yyyy"),cnvtint(format(p.birth_dt_tm,"hhmm;;m"))))
   IF (p.birth_dt_tm=null)
    reply->unknown_age_ind = 1
   ELSE
    reply->unknown_age_ind = 0
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "PERSON"
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  pp.birth_sex_cd
  FROM person_patient pp
  WHERE (pp.person_id=request->person_id)
   AND pp.active_ind=1
   AND pp.beg_effective_dt_tm <= cnvtdatetime(sysdate)
   AND pp.end_effective_dt_tm >= cnvtdatetime(sysdate)
  DETAIL
   reply->birth_sex_cd = pp.birth_sex_cd
  WITH nocounter
 ;end select
 IF ((reply->race_cd=dracemultiplecd))
  SELECT INTO "nl:"
   pcvr.code_value
   FROM person p,
    person_code_value_r pcvr,
    code_value cv
   PLAN (p
    WHERE (p.person_id=request->person_id))
    JOIN (pcvr
    WHERE pcvr.code_set=race_codeset
     AND pcvr.person_id=p.person_id
     AND pcvr.active_ind=1
     AND pcvr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND pcvr.end_effective_dt_tm >= cnvtdatetime(sysdate))
    JOIN (cv
    WHERE cv.code_value=pcvr.code_value)
   ORDER BY cv.display
   HEAD REPORT
    race_cnt = 0
   DETAIL
    race_cnt += 1
    IF (mod(race_cnt,10)=1)
     stat = alterlist(reply->race_qual,(race_cnt+ 9))
    ENDIF
    reply->race_qual[race_cnt].race_cd = pcvr.code_value
   FOOT REPORT
    stat = alterlist(reply->race_qual,race_cnt)
   WITH nocounter
  ;end select
 ELSEIF ((reply->race_cd != 0))
  SET race_cnt = 1
  SET stat = alterlist(reply->race_qual,race_cnt)
  SET reply->race_qual[race_cnt].race_cd = reply->race_cd
 ENDIF
#get_encounter_by_id
 IF ((request->encntr_id=0))
  GO TO continue
 ENDIF
 SELECT INTO "nl:"
  e.*
  FROM encounter e
  WHERE (e.encntr_id=request->encntr_id)
   AND e.active_ind=1
   AND e.beg_effective_dt_tm <= cnvtdatetime(sysdate)
   AND e.end_effective_dt_tm >= cnvtdatetime(sysdate)
  DETAIL
   reply->encntr_id = e.encntr_id, reply->location_cd = e.location_cd, reply->loc_facility_cd = e
   .loc_facility_cd,
   reply->loc_building_cd = e.loc_building_cd, reply->loc_nurse_unit_cd = e.loc_nurse_unit_cd, reply
   ->loc_room_cd = e.loc_room_cd,
   reply->loc_bed_cd = e.loc_bed_cd, reply->reason_for_visit = e.reason_for_visit
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->encntr_id = 0
  SET reply->location_cd = 0
  SET reply->loc_facility_cd = 0
  SET reply->loc_building_cd = 0
  SET reply->loc_nurse_unit_cd = 0
  SET reply->loc_room_cd = 0
  SET reply->loc_bed_cd = 0
  SET reply->reason_for_visit = ""
  GO TO continue
 ENDIF
#get_mrn
 SET code_cnt = 1
 SET meaning_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(319,"MRN",code_cnt,meaning_cd)
 IF (meaning_cd=0.0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "UAR_GET_MEANING_BY_CODESET"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "MRN"
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  FROM encntr_alias ea
  WHERE (ea.encntr_id=request->encntr_id)
   AND ea.encntr_alias_type_cd=meaning_cd
   AND ea.active_ind=1
   AND ea.beg_effective_dt_tm <= cnvtdatetime(sysdate)
   AND ea.end_effective_dt_tm >= cnvtdatetime(sysdate)
  DETAIL
   reply->alias_mrn = cnvtalias(ea.alias,ea.alias_pool_cd)
  WITH nocounter
 ;end select
#get_admit_doc
 DECLARE attenddoc_cd = f8 WITH protected, noconstant(0.0)
 SET code_cnt = 1
 SET admitdoc_cd = 0.0
 SET attenddoc_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(333,"ADMITDOC",code_cnt,admitdoc_cd)
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(333,"ATTENDDOC",code_cnt,attenddoc_cd)
 IF (admitdoc_cd=0.0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "UAR_GET_MEANING_BY_CODESET"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "ADMITDOC"
  GO TO exit_program
 ENDIF
 IF (attenddoc_cd=0.0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "UAR_GET_MEANING_BY_CODESET"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "ATTENDDOC"
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  p.person_id, p.name_full_formatted, epr.seq
  FROM encntr_prsnl_reltn epr,
   prsnl p
  PLAN (epr
   WHERE ((admitdoc_cd=epr.encntr_prsnl_r_cd) OR (attenddoc_cd=epr.encntr_prsnl_r_cd))
    AND (reply->encntr_id=epr.encntr_id))
   JOIN (p
   WHERE p.person_id=epr.prsnl_person_id)
  DETAIL
   IF (admitdoc_cd=epr.encntr_prsnl_r_cd)
    reply->admit_dr_id = p.person_id, reply->admit_dr_disp = p.name_full_formatted
   ELSEIF (attenddoc_cd=epr.encntr_prsnl_r_cd)
    reply->attend_dr_id = p.person_id, reply->attend_dr_disp = p.name_full_formatted
   ENDIF
  WITH counter
 ;end select
 IF (curqual=0)
  SET reply->admit_dr_id = 0
  SET reply->admit_dr_disp = ""
  SET reply->attend_dr_id = 0
  SET reply->attend_dr_disp = ""
 ENDIF
#continue
#get_ssn
 SET code_cnt = 1
 SET meaning_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(4,"SSN",code_cnt,meaning_cd)
 IF (meaning_cd=0.0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "UAR_GET_MEANING_BY_CODESET"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "SSN"
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  p.seq
  FROM person_alias p
  WHERE (p.person_id=request->person_id)
   AND p.person_alias_type_cd=meaning_cd
   AND p.active_ind=1
   AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
   AND p.end_effective_dt_tm >= cnvtdatetime(sysdate)
  DETAIL
   reply->alias_ssn = cnvtalias(p.alias,p.alias_pool_cd)
  WITH nocounter
 ;end select
#get_bb_comments
 SELECT INTO "nl:"
  b.bb_comment_id
  FROM blood_bank_comment b,
   long_text lt
  PLAN (b
   WHERE (b.person_id=request->person_id)
    AND b.active_ind=1)
   JOIN (lt
   WHERE lt.long_text_id=b.long_text_id
    AND lt.active_ind=1)
  HEAD REPORT
   com_cnt = 0
  DETAIL
   com_cnt += 1, stat = alterlist(reply->bb_comment,com_cnt), reply->bb_comment[com_cnt].
   bb_comment_id = b.bb_comment_id,
   reply->bb_comment[com_cnt].bb_comment_updt_cnt = b.updt_cnt, reply->bb_comment[com_cnt].comment =
   lt.long_text
  WITH nocounter
 ;end select
#get_aborh
 SELECT INTO "nl:"
  p.*
  FROM person_aborh p
  PLAN (p
   WHERE (p.person_id=request->person_id)
    AND p.active_ind=1)
  DETAIL
   reply->abo_cd = p.abo_cd, reply->rh_cd = p.rh_cd, reply->person_aborh_id = p.person_aborh_id,
   reply->person_aborh_updt_cnt = p.updt_cnt
  WITH counter
 ;end select
 IF (curqual=0)
  SET reply->abo_cd = 0
  SET reply->rh_cd = 0
 ENDIF
#antibodies
 SET anti_cnt = 0
 SET neg_cnt = 0
 SET max_anti = 0
 SET max_neg = 0
 SELECT DISTINCT INTO "nl:"
  p.antibody_cd, t.special_testing_cd
  FROM person_antibody p,
   transfusion_requirements tr,
   dummyt d,
   trans_req_r t,
   code_value cv
  PLAN (p
   WHERE (p.person_id=request->person_id)
    AND p.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=p.antibody_cd)
   JOIN (tr
   WHERE p.antibody_cd=tr.requirement_cd)
   JOIN (d
   WHERE d.seq=1)
   JOIN (t
   WHERE p.antibody_cd=t.requirement_cd
    AND t.active_ind=1)
  ORDER BY cv.collation_seq, p.antibody_cd, t.special_testing_cd
  HEAD p.antibody_cd
   neg_cnt = 0, anti_cnt += 1, stat = alterlist(reply->antibody,anti_cnt),
   reply->antibody[anti_cnt].antibody_cd = p.antibody_cd, reply->antibody[anti_cnt].anti_d_ind = tr
   .anti_d_ind, reply->antibody[anti_cnt].significance_ind = tr.significance_ind
  DETAIL
   IF (t.special_testing_cd > 0)
    neg_cnt += 1, stat = alterlist(reply->antibody[anti_cnt].antigen_neg_list,neg_cnt),
    CALL echo(t.special_testing_cd),
    reply->antibody[anti_cnt].antigen_neg_list[neg_cnt].antigen_cd = t.special_testing_cd, reply->
    antibody[anti_cnt].antigen_neg_list[neg_cnt].warn_ind = t.warn_ind, reply->antibody[anti_cnt].
    antigen_neg_list[neg_cnt].allow_override_ind = t.allow_override_ind
   ENDIF
  FOOT  p.antibody_cd
   reply->antibody[anti_cnt].antigenneg_cnt = neg_cnt
  WITH nocounter, outerjoin = d
 ;end select
#get_transfusion_requirements
 SELECT DISTINCT INTO "nl:"
  p.requirement_cd, a.special_testing_cd
  FROM person_trans_req p,
   (dummyt d  WITH seq = 1),
   trans_req_r a,
   bb_isbt_attribute_r biar,
   bb_isbt_attribute bia,
   code_value cv
  PLAN (p
   WHERE (p.person_id=request->person_id)
    AND p.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=p.requirement_cd)
   JOIN (d
   WHERE d.seq=1)
   JOIN (a
   WHERE p.requirement_cd=a.requirement_cd
    AND a.active_ind=1)
   JOIN (biar
   WHERE (biar.attribute_cd= Outerjoin(a.special_testing_cd))
    AND (biar.active_ind= Outerjoin(1)) )
   JOIN (bia
   WHERE (bia.bb_isbt_attribute_id= Outerjoin(biar.bb_isbt_attribute_id))
    AND (bia.active_ind= Outerjoin(1)) )
  ORDER BY cv.collation_seq, p.requirement_cd, a.special_testing_cd
  HEAD REPORT
   anti_cnt = 0
  HEAD p.requirement_cd
   neg_cnt = 0, anti_cnt += 1, stat = alterlist(reply->reqs,anti_cnt),
   reply->reqs[anti_cnt].requirement_cd = p.requirement_cd
  DETAIL
   IF (a.special_testing_cd > 0)
    neg_cnt += 1, stat = alterlist(reply->reqs[anti_cnt].antigen_neg_list,neg_cnt), reply->reqs[
    anti_cnt].antigen_neg_list[neg_cnt].antigen_cd = a.special_testing_cd,
    reply->reqs[anti_cnt].antigen_neg_list[neg_cnt].warn_ind = a.warn_ind, reply->reqs[anti_cnt].
    antigen_neg_list[neg_cnt].allow_override_ind = a.allow_override_ind, reply->reqs[anti_cnt].
    antigen_neg_list[neg_cnt].isbt_mean = bia.standard_display,
    reply->reqs[anti_cnt].antigen_neg_list[neg_cnt].antigen_mean = uar_get_code_meaning(a
     .special_testing_cd)
   ENDIF
  FOOT  p.requirement_cd
   reply->reqs[anti_cnt].antigenneg_cnt = neg_cnt
  WITH nocounter, outerjoin = d
 ;end select
 SET excld_prod_cat_cnt = 0
 SELECT INTO "nl:"
  FROM excld_trans_req_prod_cat_r etp,
   (dummyt d  WITH seq = value(size(reply->reqs,5)))
  PLAN (d)
   JOIN (etp
   WHERE (etp.requirement_cd=reply->reqs[d.seq].requirement_cd)
    AND etp.active_ind=1)
  ORDER BY etp.requirement_cd
  HEAD etp.requirement_cd
   excld_prod_cat_cnt = 0
  DETAIL
   IF (etp.product_cat_cd > 0)
    excld_prod_cat_cnt += 1, stat = alterlist(reply->reqs[d.seq].excluded_product_category_list,
     excld_prod_cat_cnt), reply->reqs[d.seq].excluded_product_category_list[excld_prod_cat_cnt].
    product_cat_cd = etp.product_cat_cd,
    reply->reqs[d.seq].excluded_product_category_list[excld_prod_cat_cnt].product_cat_disp =
    uar_get_code_display(etp.product_cat_cd)
   ENDIF
  WITH nocounter
 ;end select
#transfusion_history
 SELECT INTO "nl:"
  t.*
  FROM transfusion t
  PLAN (t
   WHERE (request->person_id=t.person_id)
    AND t.active_ind=1)
  WITH counter
 ;end select
 IF (curqual=0)
  SET reply->transfusions_ind = 0
 ELSE
  SET reply->transfusions_ind = 1
 ENDIF
 SET code_cnt = 1
 SET transfused_event_type_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(1610,"7",code_cnt,transfused_event_type_cd)
 IF (transfused_event_type_cd=0.0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "UAR_GET_MEANING_BY_CODESET"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "7"
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  hp.product_id, hp.product_nbr, hp.product_sub_nbr,
  hp.product_cd, hp.abo_cd, hp.rh_cd,
  hpe.product_event_id, hpe.event_type_cd, hpe.event_dt_tm,
  hpe.volume
  FROM bbhist_product hp,
   bbhist_product_event hpe
  PLAN (hpe
   WHERE hpe.event_type_cd=transfused_event_type_cd
    AND (hpe.person_id=request->person_id)
    AND hpe.active_ind=1)
   JOIN (hp
   WHERE hpe.product_id=hp.product_id)
  WITH nocounter
 ;end select
 IF (curqual != 0)
  SET reply->transfusions_ind = 1
 ENDIF
 CALL echo(request->get_aliaslist_ind)
 IF ((request->get_aliaslist_ind=1))
  CALL echo("GET ALIAS LIST")
  SET request->called_from_script_ind = 1
  EXECUTE bbt_get_person_alias_list
 ENDIF
#diagnosis
#exit_program
 IF ((reply->status_data.status="I"))
  SET reply->status_data.status = "S"
 ENDIF
END GO
