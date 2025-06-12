CREATE PROGRAM cp_get_encntr_by_filters:dba
 RECORD reply(
   1 qual[1]
     2 name_full_formatted = vc
     2 person_id = f8
     2 birth_dt_tm = dq8
     2 age = c12
     2 sex_cd = f8
     2 sex_disp = c40
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
     2 fin_nbr = vc
     2 med_service_cd = f8
     2 med_service_disp = vc
     2 reg_dt_tm = dq8
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
 SET continue_flag = 0
 SET name_temp = fillstring(100," ")
 SET start_dt_tm = cnvtdatetime("01-JAN-1800")
 SET end_dt_tm = cnvtdatetime("01-JAN-1800")
 SET code_value = 0.0
 SET code_set = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET pn = 0
 SET pb[300] = fillstring(100," ")
 IF (validate(context->context_ind,0) != 0)
  SET context->context_ind = 0
  SET continue_flag = 1
 ELSE
  RECORD context(
    1 context_ind = i2
    1 counter = i4
    1 person_type_cd = f8
    1 mrn_alias_type_cd = f8
    1 fin_nbr_alias_type_cd = f8
    1 name_last = vc
    1 name_first = vc
    1 soundex_search_ind = i2
    1 sex_cd = f8
    1 birth_dt_tm = dq8
    1 start_age = i4
    1 start_dt_tm = dq8
    1 end_dt_tm = dq8
    1 loc_facility_cd = f8
    1 loc_nurse_unit_cd = f8
    1 loc_room_cd = f8
    1 loc_bed_cd = f8
    1 med_service_cd = f8
    1 reg_dt_tm = dq8
    1 maxqual = i4
  )
  SET context->context_ind = 0
  SET context->name_last = request->name_last
  SET context->name_first = request->name_first
  SET context->soundex_search_ind = request->soundex_search_ind
  SET context->sex_cd = request->sex_cd
  SET context->birth_dt_tm = request->birth_dt_tm
  SET context->start_age = request->start_age
  SET context->loc_facility_cd = request->loc_facility_cd
  SET context->loc_nurse_unit_cd = request->loc_nurse_unit_cd
  SET context->loc_room_cd = request->loc_room_cd
  SET context->loc_bed_cd = request->loc_bed_cd
  SET context->med_service_cd = request->med_service_cd
  SET context->reg_dt_tm = request->reg_dt_tm
  SET context->maxqual = request->maxqual
 ENDIF
 IF (continue_flag=0)
  SET code_set = 319
  SET cdf_meaning = "MRN"
  EXECUTE cpm_get_cd_for_cdf
  SET context->mrn_alias_type_cd = code_value
  SET code_set = 302
  SET cdf_meaning = "PERSON"
  EXECUTE cpm_get_cd_for_cdf
  SET context->person_type_cd = code_value
  SET code_set = 319
  SET cdf_meaning = "FIN NBR"
  EXECUTE cpm_get_cd_for_cdf
  SET context->fin_nbr_alias_type_cd = code_value
 ENDIF
 IF (continue_flag=0)
  CASE (cnvtupper(request->age_units))
   OF "YEARS":
    SET start_dt_tm = cnvtagedatetime(request->start_age,0,0,0)
    IF ((request->end_age > 0))
     SET end_dt_tm = cnvtagedatetime((request->end_age+ 1),0,0,0)
    ELSE
     SET end_dt_tm = cnvtagedatetime((request->start_age+ 1),0,0,0)
    ENDIF
   OF "MONTHS":
    SET start_dt_tm = cnvtagedatetime(0,request->start_age,0,0)
    IF ((request->end_age > 0))
     SET end_dt_tm = cnvtagedatetime(0,(request->end_age+ 1),0,0)
    ELSE
     SET end_dt_tm = cnvtagedatetime(0,(request->start_age+ 1),0,0)
    ENDIF
   OF "WEEKS":
    SET start_dt_tm = cnvtagedatetime(0,0,request->start_age,0)
    IF ((request->end_age > 0))
     SET end_dt_tm = cnvtagedatetime(0,0,(request->end_age+ 1),0)
    ELSE
     SET end_dt_tm = cnvtagedatetime(0,0,(request->start_age+ 1),0)
    ENDIF
   OF "DAYS":
    SET start_dt_tm = cnvtagedatetime(0,0,0,request->start_age)
    IF ((request->end_age > 0))
     SET end_dt_tm = cnvtagedatetime(0,0,0,(request->end_age+ 1))
    ELSE
     SET end_dt_tm = cnvtagedatetime(0,0,0,(request->start_age+ 1))
    ENDIF
  ENDCASE
  SET context->start_dt_tm = start_dt_tm
  SET context->end_dt_tm = end_dt_tm
 ENDIF
 SET stat = alter(reply->qual,context->maxqual)
 SET pn = (pn+ 1)
 SET pb[pn] = 'select into "nl:"'
 SET pn = (pn+ 1)
 SET pb[pn] = "  p.name_last_key,"
 SET pn = (pn+ 1)
 SET pb[pn] = "  p.name_first_key,"
 SET pn = (pn+ 1)
 SET pb[pn] = "  p.name_full_formatted,"
 SET pn = (pn+ 1)
 SET pb[pn] = '  age = cnvtage(cnvtdate2(format(p.birth_dt_tm,"mm/dd/yyyy;;d"),"mm/dd/yyyy"),'
 SET pn = (pn+ 1)
 SET pb[pn] = '    cnvtint(format(p.birth_dt_tm,"hhmm;;m")))'
 SET pn = (pn+ 1)
 SET pb[pn] = "from person p,"
 SET pn = (pn+ 1)
 SET pb[pn] = "     encounter ed,"
 SET pn = (pn+ 1)
 SET pb[pn] = "     (dummyt d1 with seq = 1),"
 SET pn = (pn+ 1)
 SET pb[pn] = "     encntr_alias ea1,"
 SET pn = (pn+ 1)
 SET pb[pn] = "     (dummyt d2 with seq = 1),"
 SET pn = (pn+ 1)
 SET pb[pn] = "     encntr_alias ea2"
 IF ((context->loc_nurse_unit_cd=0))
  SET pn = (pn+ 1)
  SET pb[pn] = "plan p where "
  SET name_temp = cnvtupper(cnvtalphanum(context->name_last))
  IF ((context->soundex_search_ind=0))
   SET pn = (pn+ 1)
   SET pb[pn] = concat("     p.name_last_key = patstring('",trim(name_temp),"*')")
  ELSE
   SET pn = (pn+ 1)
   SET pb[pn] = "     substring(1,4,p.name_phonetic) =soundex(trim(name_temp))"
  ENDIF
  SET pn = (pn+ 1)
  SET name_temp = cnvtupper(cnvtalphanum(context->name_first))
  SET pb[pn] = concat("     and p.name_first_key = patstring('",trim(name_temp),"*')")
  EXECUTE FROM start_person TO end_person
  SET pn = (pn+ 1)
  SET pb[pn] = "join ed where ed.person_id = p.person_id"
  IF ((context->loc_facility_cd > 0))
   SET pn = (pn+ 1)
   SET pb[pn] = "     and ed.loc_facility_cd = context->loc_facility_cd"
  ENDIF
  EXECUTE FROM start_encntr TO end_encntr
  GO TO start_joins
 ELSE
  SET pn = (pn+ 1)
  SET pb[pn] = "plan ed where ed.loc_facility_cd = context->loc_facility_cd"
  EXECUTE FROM start_encntr TO end_encntr
  SET pn = (pn+ 1)
  SET pb[pn] = "join p where p.person_id = ed.person_id"
  EXECUTE FROM start_person TO end_person
  GO TO start_joins
 ENDIF
#start_person
 IF ((context->sex_cd > 0))
  SET pn = (pn+ 1)
  SET pb[pn] = "     and p.sex_cd = context->sex_cd"
 ENDIF
 IF ((context->birth_dt_tm > 0))
  SET pn = (pn+ 1)
  SET pb[pn] = "     and 0 = datetimecmp(p.birth_dt_tm,cnvtdatetime(context->birth_dt_tm))"
 ENDIF
 IF ((context->start_dt_tm > cnvtdatetime("01-jan-1800")))
  SET pn = (pn+ 1)
  SET pb[pn] = "     and p.birth_dt_tm between cnvtdatetime(end_dt_tm)"
  SET pn = (pn+ 1)
  SET pb[pn] = "     and cnvtdatetime(start_dt_tm)"
 ENDIF
 SET pn = (pn+ 1)
 SET pb[pn] = "     and p.person_type_cd = context->person_type_cd"
 SET pn = (pn+ 1)
 SET pb[pn] = "     and p.active_ind = 1"
 SET pn = (pn+ 1)
 SET pb[pn] = "     and p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)"
 SET pn = (pn+ 1)
 SET pb[pn] = "     and p.end_effective_dt_tm >=cnvtdatetime(curdate,curtime3)"
#end_person
#start_encntr
 IF ((context->loc_nurse_unit_cd > 0))
  SET pn = (pn+ 1)
  SET pb[pn] = "     and ed.loc_nurse_unit_cd = context->loc_nurse_unit_cd"
 ENDIF
 IF ((context->loc_room_cd > 0))
  SET pn = (pn+ 1)
  SET pb[pn] = "     and ed.loc_room_cd = context->loc_room_cd"
 ENDIF
 IF ((context->loc_bed_cd > 0))
  SET pn = (pn+ 1)
  SET pb[pn] = "     and ed.loc_bed_cd = context->loc_bed_cd"
 ENDIF
 IF ((context->med_service_cd > 0))
  SET pn = (pn+ 1)
  SET pb[pn] = "     and ed.med_service_cd = context->med_service_cd"
 ENDIF
 IF ((context->reg_dt_tm > 0))
  SET pn = (pn+ 1)
  SET pb[pn] = "     and 0 = datetimecmp(ed.reg_dt_tm,cnvtdatetime(context->reg_dt_tm))"
 ENDIF
 SET pn = (pn+ 1)
 SET pb[pn] = "     and ed.active_ind = 1"
 SET pn = (pn+ 1)
 SET pb[pn] = "     and ed.beg_effective_dt_tm <=cnvtdatetime(curdate,curtime3)"
 SET pn = (pn+ 1)
 SET pb[pn] = "     and ed.end_effective_dt_tm >=cnvtdatetime(curdate,curtime3)"
#end_encntr
#start_joins
 SET pn = (pn+ 1)
 SET pb[pn] = "join d1 "
 SET pn = (pn+ 1)
 SET pb[pn] = "join ea1 where ea1.encntr_id = ed.encntr_id"
 SET pn = (pn+ 1)
 SET pb[pn] = "     and ea1.encntr_alias_type_cd = context->mrn_alias_type_cd"
 SET pn = (pn+ 1)
 SET pb[pn] = "     and ea1.active_ind = 1"
 SET pn = (pn+ 1)
 SET pb[pn] = "     and ea1.beg_effective_dt_tm <=cnvtdatetime(curdate,curtime3)"
 SET pn = (pn+ 1)
 SET pb[pn] = "     and ea1.end_effective_dt_tm >=cnvtdatetime(curdate,curtime3)"
 SET pn = (pn+ 1)
 SET pb[pn] = "join d2 "
 SET pn = (pn+ 1)
 SET pb[pn] = "join ea2 where ea2.encntr_id = ed.encntr_id"
 SET pn = (pn+ 1)
 SET pb[pn] = "     and ea2.encntr_alias_type_cd = context->fin_nbr_alias_type_cd"
 SET pn = (pn+ 1)
 SET pb[pn] = "     and ea2.active_ind = 1"
 SET pn = (pn+ 1)
 SET pb[pn] = "     and ea2.beg_effective_dt_tm <=cnvtdatetime(curdate,curtime3)"
 SET pn = (pn+ 1)
 SET pb[pn] = "     and ea2.end_effective_dt_tm >=cnvtdatetime(curdate,curtime3)"
 SET pn = (pn+ 1)
 SET pb[pn] = "order by p.name_last_key, p.name_first_key"
 SET pn = (pn+ 1)
 SET pb[pn] = "head report"
 SET pn = (pn+ 1)
 SET pb[pn] = "  count1 = 0"
 SET pn = (pn+ 1)
 SET pb[pn] = "  count2 = 0"
 SET pn = (pn+ 1)
 SET pb[pn] = "detail"
 SET pn = (pn+ 1)
 SET pb[pn] = "  count1 = count1 + 1"
 SET pn = (pn+ 1)
 SET pb[pn] = "  if ((continue_flag = 0 and context->maxqual > count2) or"
 SET pn = (pn+ 1)
 SET pb[pn] = "    (continue_flag = 1 and count1 > context->counter and"
 SET pn = (pn+ 1)
 SET pb[pn] = "       context->maxqual > count2))"
 SET pn = (pn+ 1)
 SET pb[pn] = "    count2 = count2 + 1"
 SET pn = (pn+ 1)
 SET pb[pn] = "    reply->qual[count2]->name_full_formatted = p.name_full_formatted"
 SET pn = (pn+ 1)
 SET pb[pn] = "    reply->qual[count2]->person_id        = p.person_id"
 SET pn = (pn+ 1)
 SET pb[pn] = "    reply->qual[count2]->age              = age"
 SET pn = (pn+ 1)
 SET pb[pn] = "    reply->qual[count2]->sex_cd           = p.sex_cd"
 SET pn = (pn+ 1)
 SET pb[pn] = "    reply->qual[count2]->birth_dt_tm      =cnvtdatetime(p.birth_dt_tm)"
 SET pn = (pn+ 1)
 SET pb[pn] = "    reply->qual[count2]->loc_facility_cd  = ed.loc_facility_cd"
 SET pn = (pn+ 1)
 SET pb[pn] = "    reply->qual[count2]->loc_nurse_unit_cd= ed.loc_nurse_unit_cd"
 SET pn = (pn+ 1)
 SET pb[pn] = "    reply->qual[count2]->loc_room_cd      = ed.loc_room_cd"
 SET pn = (pn+ 1)
 SET pb[pn] = "    reply->qual[count2]->loc_bed_cd       = ed.loc_bed_cd"
 SET pn = (pn+ 1)
 SET pb[pn] = "    reply->qual[count2]->encntr_id        = ed.encntr_id"
 SET pn = (pn+ 1)
 SET pb[pn] = "    reply->qual[count2]->med_service_cd   = ed.med_service_cd"
 SET pn = (pn+ 1)
 SET pb[pn] = "    reply->qual[count2]->reg_dt_tm        = ed.reg_dt_tm"
 SET pn = (pn+ 1)
 SET pb[pn] = "    reply->qual[count2]->alias            = ea1.alias"
 SET pn = (pn+ 1)
 SET pb[pn] = "    reply->qual[count2]->fin_nbr          = ea2.alias"
 SET pn = (pn+ 1)
 SET pb[pn] = "    if (context->maxqual = count2)"
 SET pn = (pn+ 1)
 SET pb[pn] = "      context->context_ind                = 1"
 SET pn = (pn+ 1)
 SET pb[pn] = "      context->counter                    = count1"
 SET pn = (pn+ 1)
 SET pb[pn] = "    endif"
 SET pn = (pn+ 1)
 SET pb[pn] = "  endif"
 SET pn = (pn+ 1)
 SET pb[pn] = "with nocounter, outerjoin = d1, dontcare = ea1, outerjoin = d2, dontcare = ea2 go"
 FOR (idx = 1 TO pn)
   CALL parser(pb[idx])
 ENDFOR
 IF ((count2 < context->maxqual))
  SET stat = alter(reply->qual,count2)
 ENDIF
 IF ((context->context_ind=0))
  FREE SET context
 ENDIF
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
