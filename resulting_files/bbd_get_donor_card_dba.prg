CREATE PROGRAM bbd_get_donor_card:dba
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
 RECORD card_request(
   1 location_name = vc
   1 location_address = vc
   1 location_address2 = vc
   1 location_address3 = vc
   1 location_address4 = vc
   1 location_city = vc
   1 location_state = vc
   1 location_zip = c25
   1 donor_name = vc
   1 ssn = vc
   1 donor_number = vc
   1 home_address = vc
   1 home_address2 = vc
   1 home_address3 = vc
   1 home_address4 = vc
   1 home_city = vc
   1 home_state = vc
   1 home_zip = vc
   1 home_phone = vc
   1 business_address = vc
   1 business_address2 = vc
   1 business_address3 = vc
   1 business_address4 = vc
   1 business_city = vc
   1 business_state = vc
   1 business_zip = vc
   1 business_phone = vc
   1 birth_dt_tm = dq8
   1 gender_disp = vc
   1 abo_disp = vc
   1 rh_disp = vc
   1 last_donation_dt_tm = dq8
   1 next_donation_dt_tm = dq8
   1 current_year_donations = i4
   1 total_donations = i4
   1 donation_proc_disp = vc
   1 donation_dt_tm = dq8
   1 eligibility_type_disp = vc
   1 antigen_list[*]
     2 antigen_disp = vc
   1 birth_tz = i4
   1 loc_facility_disp = vc
   1 loc_building_disp = vc
   1 loc_nurse_unit_disp = vc
   1 loc_room_disp = vc
   1 loc_bed_disp = vc
 )
 RECORD reply(
   1 report_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET modify = predeclare
 DECLARE script_name = c18 WITH constant("bbd_get_donor_card")
 DECLARE antigen_count = f8
 DECLARE temp = f8
 DECLARE stat = f8
 DECLARE home_address_cd = f8
 DECLARE business_address_cd = f8
 DECLARE home_phone_cd = f8
 DECLARE business_phone_cd = f8
 DECLARE ssn_alias_cd = f8
 DECLARE donor_id_alias_cd = f8
 DECLARE contact_type_cd = f8
 DECLARE abo_rh = f8 WITH noconstant(0.0)
 DECLARE nbryrdon = f8 WITH noconstant(0.0)
 DECLARE nbr_all_donations = f8 WITH noconstant(0.0)
 DECLARE current_date = f8 WITH constant(cnvtdatetime(curdate,curtime3))
 DECLARE next_donation_dt_tm = f8 WITH noconstant(cnvtdatetime(curdate,curtime3))
 DECLARE donation_dt_tm = f8 WITH noconstant(cnvtdatetime(request->donation_dt_tm))
 DECLARE test_counter = f8 WITH noconstant(0.0)
 DECLARE uar_error_string = vc WITH noconstant("")
 DECLARE errmsg = c132 WITH noconstant(fillstring(132," "))
 DECLARE error_check = i2 WITH noconstant(error(errmsg,1))
 DECLARE contact_status_cs = i4 WITH constant(14224)
 DECLARE contact_status_pending_mean = c7 WITH constant("PENDING")
 DECLARE contact_status_pending_cd = f8 WITH protect, noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(212,"HOME",1,home_address_cd)
 SET stat = uar_get_meaning_by_codeset(212,"BUSINESS",1,business_address_cd)
 SET stat = uar_get_meaning_by_codeset(43,"HOME",1,home_phone_cd)
 SET stat = uar_get_meaning_by_codeset(43,"BUSINESS",1,business_phone_cd)
 SET stat = uar_get_meaning_by_codeset(4,"SSN",1,ssn_alias_cd)
 SET stat = uar_get_meaning_by_codeset(4,"DONORID",1,donor_id_alias_cd)
 SET stat = uar_get_meaning_by_codeset(14220,"DONATE",1,contact_type_cd)
 SET contact_status_pending_cd = uar_get_code_by("MEANING",contact_status_cs,nullterm(
   contact_status_pending_mean))
 IF (home_address_cd <= 0.0)
  SET uar_error_string = concat("Fail:",trim(uar_get_code_meaning(home_address_cd)),".")
  CALL errorhandler(script_name,"F","uar_get_code_by",uar_error_string)
 ELSEIF (business_address_cd <= 0.0)
  SET uar_error_string = concat("Fail:",trim(uar_get_code_meaning(business_address_cd)),".")
  CALL errorhandler(script_name,"F","uar_get_code_by",uar_error_string)
 ELSEIF (home_phone_cd <= 0.0)
  SET uar_error_string = concat("Fail:",trim(uar_get_code_meaning(home_phone_cd)),".")
  CALL errorhandler(script_name,"F","uar_get_code_by",uar_error_string)
 ELSEIF (business_phone_cd <= 0.0)
  SET uar_error_string = concat("Fail:",trim(uar_get_code_meaning(business_phone_cd)),".")
  CALL errorhandler(script_name,"F","uar_get_code_by",uar_error_string)
 ELSEIF (ssn_alias_cd <= 0.0)
  SET uar_error_string = concat("Fail:",trim(uar_get_code_meaning(ssn_alias_cd)),".")
  CALL errorhandler(script_name,"F","uar_get_code_by",uar_error_string)
 ELSEIF (donor_id_alias_cd <= 0.0)
  SET uar_error_string = concat("Fail:",trim(uar_get_code_meaning(donor_id_alias_cd)),".")
  CALL errorhandler(script_name,"F","uar_get_code_by",uar_error_string)
 ELSEIF (contact_type_cd <= 0.0)
  SET uar_error_string = concat("Fail:",trim(uar_get_code_meaning(contact_type_cd)),".")
  CALL errorhandler(script_name,"F","uar_get_code_by",uar_error_string)
 ENDIF
 IF (contact_status_pending_cd <= 0.0)
  SET uar_error_string = concat("Failed to retrieve contact status code with meaning of ",trim(
    contact_status_pending_mean),".")
  CALL errorhandler(script_name,"F","uar_get_code_by",uar_error_string)
 ENDIF
 SELECT INTO "nl:"
  FROM bbd_donor_contact b,
   bbd_donation_results bd,
   bbd_donation_procedure dp,
   bbd_procedure_outcome po
  PLAN (b
   WHERE (b.person_id=request->person_id)
    AND b.active_ind=1
    AND b.contact_type_cd=contact_type_cd)
   JOIN (bd
   WHERE bd.encntr_id=b.encntr_id
    AND bd.active_ind=1)
   JOIN (dp
   WHERE dp.procedure_cd=bd.procedure_cd
    AND dp.active_ind=1)
   JOIN (po
   WHERE po.procedure_id=dp.procedure_id
    AND po.outcome_cd=bd.outcome_cd
    AND po.active_ind=1
    AND po.count_as_donation_ind=1)
  DETAIL
   nbr_all_donations = (nbr_all_donations+ 1)
   IF (b.contact_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND b.contact_dt_tm >= cnvtdatetime(datetimeadd(current_date,- (365))))
    nbryrdon = (nbryrdon+ 1)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM bbd_donation_procedure bdp,
   bbd_procedure_outcome bpo,
   bbd_outcome_bag_type bobt,
   bbd_bag_type_product bbtp,
   bbd_product_eligibility bpe
  PLAN (bdp
   WHERE (bdp.procedure_cd=request->procedure_cd)
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
   next_donation_dt_tm = datetimeadd(cnvtdatetime(request->donation_dt_tm),days_until_eligible)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  p.name_full_formatted, p.birth_dt_tm, gender_disp = uar_get_code_display(p.sex_cd),
  loc_name = uar_get_code_display(bdc.inventory_area_cd), a1.street_addr, a1.street_addr2,
  a1.street_addr3, a1.street_addr4, a1.city,
  a1.state, a1.zipcode, a2.street_addr,
  a2.street_addr2, a2.street_addr3, a2.street_addr4,
  a2.city, a2.state, a2.zipcode,
  a3.street_addr, a3.street_addr2, a3.street_addr3,
  a3.street_addr4, a3.city, a3.state,
  a3.zipcode, pa.alias, pa1.alias,
  ph.phone_num, ph1.phone_num, my_abo_disp = uar_get_code_display(dab.abo_cd),
  my_rh_disp = uar_get_code_display(dab.rh_cd), pd.last_donation_dt_tm, eligibility_disp =
  uar_get_code_display(pd.eligibility_type_cd),
  e.reg_dt_tm, don_proc_disp = uar_get_code_display(e.bbd_procedure_cd), antigen_disp =
  uar_get_code_display(dant.antigen_cd),
  locfacilitydisp = uar_get_code_display(e.loc_facility_cd), locbuildingdisp = uar_get_code_display(e
   .loc_building_cd), locnurseunitdisp = uar_get_code_display(e.loc_nurse_unit_cd),
  locroomdisp = uar_get_code_display(e.loc_room_cd), locbeddisp = uar_get_code_display(e.loc_bed_cd)
  FROM address a1,
   address a2,
   address a3,
   person p,
   encounter e,
   phone ph,
   phone ph1,
   person_alias pa,
   person_alias pa1,
   person_donor pd,
   donor_aborh dab,
   bbd_donor_contact bdc,
   donor_antigen dant
  PLAN (pd
   WHERE (pd.person_id=request->person_id)
    AND pd.active_ind=outerjoin(1))
   JOIN (p
   WHERE p.person_id=pd.person_id
    AND p.active_ind=outerjoin(1))
   JOIN (bdc
   WHERE bdc.person_id=outerjoin(pd.person_id)
    AND bdc.contact_type_cd=outerjoin(contact_type_cd)
    AND bdc.contact_status_cd=outerjoin(contact_status_pending_cd))
   JOIN (a1
   WHERE a1.parent_entity_id=outerjoin(pd.person_id)
    AND a1.parent_entity_name=outerjoin("PERSON")
    AND a1.address_type_cd=outerjoin(home_address_cd)
    AND a1.active_ind=outerjoin(1))
   JOIN (a2
   WHERE a2.parent_entity_id=outerjoin(pd.person_id)
    AND a2.parent_entity_name=outerjoin("PERSON")
    AND a2.address_type_cd=outerjoin(business_address_cd)
    AND a2.active_ind=outerjoin(1))
   JOIN (a3
   WHERE a3.parent_entity_id=outerjoin(bdc.inventory_area_cd)
    AND a3.parent_entity_name=outerjoin("LOCATION")
    AND a3.address_type_cd=outerjoin(business_address_cd)
    AND a3.active_ind=outerjoin(1))
   JOIN (e
   WHERE e.encntr_type_cd=outerjoin(request->encounter_cd)
    AND e.person_id=outerjoin(pd.person_id)
    AND e.active_ind=outerjoin(1))
   JOIN (ph
   WHERE ph.parent_entity_id=outerjoin(pd.person_id)
    AND ph.parent_entity_name=outerjoin("PERSON")
    AND ph.phone_type_cd=outerjoin(home_phone_cd)
    AND ph.active_ind=outerjoin(1))
   JOIN (ph1
   WHERE ph1.parent_entity_id=outerjoin(pd.person_id)
    AND ph1.parent_entity_name=outerjoin("PERSON")
    AND ph1.phone_type_cd=outerjoin(business_phone_cd)
    AND ph1.active_ind=outerjoin(1))
   JOIN (pa
   WHERE pa.person_id=outerjoin(pd.person_id)
    AND pa.person_alias_type_cd=outerjoin(ssn_alias_cd)
    AND pa.active_ind=outerjoin(1))
   JOIN (pa1
   WHERE pa1.person_id=outerjoin(pd.person_id)
    AND pa1.person_alias_type_cd=outerjoin(donor_id_alias_cd)
    AND pa1.active_ind=outerjoin(1))
   JOIN (dab
   WHERE dab.person_id=outerjoin(pd.person_id)
    AND dab.active_ind=outerjoin(1))
   JOIN (dant
   WHERE dant.person_id=outerjoin(pd.person_id)
    AND dant.active_ind=outerjoin(1))
  ORDER BY dant.antigen_cd
  HEAD REPORT
   stat = alterlist(card_request->antigen_list,10), count_array = 0, antigen_count = 0,
   card_request->location_name = trim(loc_name), card_request->location_address = trim(a3.street_addr
    ), card_request->location_address2 = trim(a3.street_addr2),
   card_request->location_address3 = trim(a3.street_addr3), card_request->location_address4 = trim(a3
    .street_addr4), card_request->location_city = trim(a3.city),
   card_request->location_state = trim(a3.state), card_request->location_zip = trim(a3.zipcode),
   card_request->donor_name = trim(p.name_full_formatted),
   card_request->ssn = trim(cnvtalias(pa.alias,pa.alias_pool_cd)), card_request->donor_number = trim(
    cnvtalias(pa1.alias,pa1.alias_pool_cd)), card_request->home_address = trim(a1.street_addr),
   card_request->home_address2 = trim(a1.street_addr2), card_request->home_address3 = trim(a1
    .street_addr3), card_request->home_address4 = trim(a1.street_addr4),
   card_request->home_city = trim(a1.city), card_request->home_state = trim(a1.state), card_request->
   home_zip = trim(a1.zipcode),
   card_request->home_phone = trim(ph.phone_num), card_request->business_address = trim(a2
    .street_addr), card_request->business_address2 = trim(a2.street_addr2),
   card_request->business_address3 = trim(a2.street_addr3), card_request->business_address4 = trim(a2
    .street_addr4), card_request->business_city = trim(a2.city),
   card_request->business_state = trim(a2.state), card_request->business_zip = trim(a2.zipcode),
   card_request->business_phone = trim(ph1.phone_num),
   card_request->birth_dt_tm = cnvtdatetime(p.birth_dt_tm), card_request->gender_disp = trim(
    gender_disp)
   IF (dab.abo_cd=0
    AND dab.rh_cd=0)
    card_request->abo_disp = "(None)", card_request->rh_disp = ""
   ELSE
    card_request->abo_disp = trim(my_abo_disp), card_request->rh_disp = trim(my_rh_disp)
   ENDIF
   card_request->last_donation_dt_tm = pd.last_donation_dt_tm, card_request->next_donation_dt_tm =
   next_donation_dt_tm, card_request->current_year_donations = nbryrdon,
   card_request->total_donations = nbr_all_donations, card_request->donation_proc_disp = trim(
    don_proc_disp), card_request->donation_dt_tm = e.reg_dt_tm,
   card_request->eligibility_type_disp = eligibility_disp, card_request->birth_tz = p.birth_tz,
   card_request->loc_facility_disp = locfacilitydisp,
   card_request->loc_building_disp = locbuildingdisp, card_request->loc_nurse_unit_disp =
   locnurseunitdisp, card_request->loc_room_disp = locroomdisp,
   card_request->loc_bed_disp = locbeddisp
  HEAD dant.antigen_cd
   count_array = (count_array+ 1)
   IF (size(card_request->antigen_list,5) >= count_array)
    stat = alterlist(card_request->antigen_list,(count_array+ 10))
   ENDIF
   IF (size(trim(antigen_disp)) > 0)
    card_request->antigen_list[count_array].antigen_disp = trim(antigen_disp), antigen_count = (
    antigen_count+ 1)
   ENDIF
  DETAIL
   dant.antigen_cd, row + 0
  FOOT  dant.antigen_cd
   row + 0
  FOOT REPORT
   stat = alterlist(card_request->antigen_list,count_array)
   IF (antigen_count=0)
    card_request->antigen_list[1].antigen_disp = "(None)"
   ENDIF
 ;end select
 SET error_check = error(errmsg,0)
 IF (error_check != 0)
  CALL errorhandler("SELECT","F","bbd_get_donor_card",errmsg)
  GO TO exit_script
 ENDIF
 EXECUTE bbd_rpt_donor_card
 DECLARE errorhandler(operationname=c25,operationstatus=c1,targetobjectname=c25,targetobjectvalue=vc)
  = null
 SUBROUTINE errorhandler(operationname,operationstatus,targetobjectname,targetobjectvalue)
   DECLARE error_cnt = i2 WITH private, noconstant(0)
   SET error_cnt = size(reply->status_data.subeventstatus,5)
   IF (((error_cnt > 1) OR (error_cnt=1
    AND (reply->status_data.subeventstatus[error_cnt].operationstatus != ""))) )
    SET error_cnt = (error_cnt+ 1)
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[error_cnt].operationname = operationname
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = operationstatus
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = targetobjectname
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = targetobjectvalue
 END ;Subroutine
#set_status
 IF (error_check != 0)
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
END GO
