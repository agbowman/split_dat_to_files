CREATE PROGRAM cpm_get_my_patients_only:dba
 RECORD reply(
   1 qual[1]
     2 name_full_formatted = vc
     2 person_id = f8
     2 birth_dt_tm = dq8
     2 age = c12
     2 sex_cd = f8
     2 sex_disp = c40
     2 person_alias_type_cd = f8
     2 person_alias_type_disp = vc
     2 alias = vc
     2 loc_facility_cd = f8
     2 loc_facility_disp = vc
     2 loc_nurse_unit_cd = f8
     2 loc_nurse_unit_disp = vc
     2 loc_room_cd = f8
     2 loc_room_disp = vc
     2 loc_bed_cd = f8
     2 loc_bed_disp = vc
     2 encntr_id = f8
     2 med_service_cd = f8
     2 med_service_disp = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET count2 = 0
 SET maxqualrows = 0
 SET continue_flag = 0
 SET name_last = fillstring(100," ")
 SET name_first = fillstring(100," ")
 SET name_phonetic = fillstring(8," ")
 SET soundex_search_ind = 0
 SET sex_cd = 0.0
 SET birth_dt_tm = cnvtdatetime(curdate,curtime3)
 SET start_age = 0
 SET start_dt_tm = cnvtdatetime("01-JAN-1800 00:00:00.00")
 SET end_dt_tm = cnvtdatetime(curdate,curtime3)
 SET return_location_ind = 0
 SET person_prsnl_reltn_cd = 0.0
 SET code_value = 0.0
 SET person_alias_type_cd = 0.0
 SET person_type_cd = 0.0
 SET code_set = 0.0
 SET cdf_meaning = fillstring(12," ")
 IF (validate(context->context_ind,0) != 0)
  SET context->context_ind = 0
  SET continue_flag = 1
  SET maxqualrows = context->maxqual
  SET person_alias_type_cd = context->person_alias_type_cd
  IF ((context->name_last > ""))
   SET name_last = context->name_last
   SET name_phonetic = soundex(cnvtupper(context->name_last))
  ENDIF
  IF (textlen(context->name_first) > 0)
   SET name_first = context->name_first
  ENDIF
  SET soundex_search_ind = context->soundex_search_ind
  SET sex_cd = context->sex_cd
  SET birth_dt_tm = context->birth_dt_tm
  SET start_age = context->start_age
  SET start_dt_tm = context->start_dt_tm
  SET end_dt_tm = context->end_dt_tm
  SET person_prsnl_reltn_cd = context->person_prsnl_reltn_cd
  SET return_location_ind = context->return_location_ind
  SET person_type_cd = context->person_type_cd
 ELSE
  SET maxqualrows = request->maxqual
  IF ((request->name_last > ""))
   SET name_last = concat(trim(cnvtupper(cnvtalphanum(request->name_last))),"*")
   SET name_phonetic = soundex(cnvtupper(request->name_last))
  ENDIF
  IF (textlen(request->name_first) > 0)
   SET name_first = concat(trim(cnvtupper(cnvtalphanum(request->name_first))),"*")
  ENDIF
  SET soundex_search_ind = request->soundex_search_ind
  SET sex_cd = request->sex_cd
  SET birth_dt_tm = request->birth_dt_tm
  SET person_prsnl_reltn_cd = request->person_prsnl_reltn_cd
  SET return_location_ind = request->return_location_ind
  RECORD context(
    1 context_ind = i2
    1 counter = i4
    1 person_alias_type_cd = f8
    1 person_type_cd = f8
    1 name_last = vc
    1 name_first = vc
    1 soundex_search_ind = i2
    1 sex_cd = f8
    1 birth_dt_tm = dq8
    1 start_age = i4
    1 start_dt_tm = dq8
    1 end_dt_tm = dq8
    1 person_prsnl_reltn_cd = f8
    1 maxqual = i4
    1 return_location_ind = i2
  )
  SET context->context_ind = 0
  SET context->counter = maxqualrows
 ENDIF
 IF (continue_flag=0)
  SET code_set = 4
  SET cdf_meaning = "MRN"
  EXECUTE cpm_get_cd_for_cdf
  SET person_alias_type_cd = code_value
  SET context->person_alias_type_cd = person_alias_type_cd
  SET code_set = 302
  SET cdf_meaning = "PERSON"
  EXECUTE cpm_get_cd_for_cdf
  SET person_type_cd = code_value
  SET context->person_type_cd = person_type_cd
 ELSE
  SET person_alias_type_cd = context->person_alias_type_cd
  SET person_type_cd = context->person_type_cd
 ENDIF
 IF (continue_flag=0)
  CASE (cnvtupper(request->age_units))
   OF "YEARS":
    IF ((request->end_age > 0))
     SET start_dt_tm = cnvtagedatetime(request->start_age,0,0,0)
     SET end_dt_tm = cnvtagedatetime(request->end_age,0,0,0)
    ELSE
     SET start_dt_tm = cnvtagedatetime((request->start_age - 1),6,0,0)
     SET end_dt_tm = cnvtagedatetime(request->start_age,6,0,0)
    ENDIF
   OF "MONTHS":
    IF ((request->end_age > 0))
     SET start_dt_tm = cnvtagedatetime(0,request->start_age,0,0)
     SET end_dt_tm = cnvtagedatetime(0,request->end_age,0,0)
    ELSE
     SET start_dt_tm = cnvtagedatetime(0,(request->start_age - 1),2,0)
     SET end_dt_tm = cnvtagedatetime(0,request->start_age,2,0)
    ENDIF
   OF "WEEKS":
    IF ((request->end_age > 0))
     SET start_dt_tm = cnvtagedatetime(0,0,request->start_age,0)
     SET end_dt_tm = cnvtagedatetime(0,0,request->end_age,0)
    ELSE
     SET start_dt_tm = cnvtagedatetime(0,0,(request->start_age - 1),3)
     SET end_dt_tm = cnvtagedatetime(0,0,request->start_age,3)
    ENDIF
   OF "DAYS":
    SET start_dt_tm = cnvtagedatetime(0,0,0,request->start_age)
    IF ((request->end_age > 0))
     SET end_dt_tm = cnvtagedatetime(0,0,0,request->end_age)
    ENDIF
  ENDCASE
  SET start_age = request->start_age
 ENDIF
 SET stat = alter(reply->qual,maxqualrows)
 EXECUTE cpm_get_my_patients_only2 parser(
  IF (soundex_search_ind=0
   AND name_last > " ") "p.name_last_key = patstring(name_last)"
  ELSEIF (soundex_search_ind=1) "p.name_phonetic = name_phonetic"
  ELSE "0 = 0"
  ENDIF
  ), parser(
  IF (name_first > " ") "p.name_first_key = patstring(name_first)"
  ELSE "0 = 0"
  ENDIF
  ), parser(
  IF (sex_cd > 0) "p.sex_cd = sex_cd"
  ELSE "0 = 0"
  ENDIF
  ),
 parser(
  IF (birth_dt_tm > 0) "0 = datetimecmp(p.birth_dt_tm,cnvtdatetime(birth_dt_tm))"
  ELSE "0 = 0"
  ENDIF
  ), parser(
  IF (start_age > 0) "p.birth_dt_tm between cnvtdatetime(end_dt_tm) and cnvtdatetime(start_dt_tm)"
  ELSE "0 = 0"
  ENDIF
  ), parser(
  IF (person_prsnl_reltn_cd > 0) "ppr.person_prsnl_r_cd = person_prsnl_reltn_cd"
  ELSE "0 = 0"
  ENDIF
  )
 SET stat = alter(reply->qual,count2)
 IF ((context->context_ind=0))
  FREE SET context
 ENDIF
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
