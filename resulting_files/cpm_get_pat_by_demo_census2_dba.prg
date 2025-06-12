CREATE PROGRAM cpm_get_pat_by_demo_census2:dba
 SELECT
  IF (loc_nurse_unit_cd > 0)
   PLAN (ed
    WHERE  $6
     AND  $7
     AND  $8
     AND  $9
     AND  $10
     AND ed.active_ind=1
     AND ed.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND ed.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (p
    WHERE ed.person_id=p.person_id
     AND  $1
     AND  $2
     AND  $3
     AND  $4
     AND  $5
     AND p.active_ind=1
     AND p.person_type_cd=person_type_cd
     AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (pa
    WHERE p.person_id=pa.person_id
     AND pa.person_alias_type_cd=person_alias_type_cd
     AND pa.active_ind=1
     AND pa.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND pa.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   ORDER BY p.name_last_key, p.name_first_key
  ELSE
   PLAN (p
    WHERE  $1
     AND  $2
     AND  $3
     AND  $4
     AND  $5
     AND p.active_ind=1
     AND p.person_type_cd=person_type_cd
     AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (ed
    WHERE p.person_id=ed.person_id
     AND  $6
     AND  $7
     AND  $8
     AND  $9
     AND  $10
     AND ed.active_ind=1
     AND ed.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND ed.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (pa
    WHERE p.person_id=pa.person_id
     AND pa.person_alias_type_cd=person_alias_type_cd
     AND pa.active_ind=1
     AND pa.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND pa.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  ENDIF
  INTO "nl:"
  p.name_last_key, p.name_first_key, age = cnvtage(cnvtdate2(format(p.birth_dt_tm,"mm/dd/yyyy;;d"),
    "mm/dd/yyyy"),cnvtint(format(p.birth_dt_tm,"hhmm;;m")))
  FROM person p,
   person_alias pa,
   encntr_domain ed
  HEAD REPORT
   count1 = 0, count2 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (((continue_flag=0
    AND maxqualrows > count2) OR (continue_flag=1
    AND (count1 > context->counter)
    AND maxqualrows > count2)) )
    count2 = (count2+ 1), reply->qual[count2].name_full_formatted = p.name_full_formatted, reply->
    qual[count2].person_id = p.person_id,
    reply->qual[count2].age = age, reply->qual[count2].sex_cd = p.sex_cd, reply->qual[count2].
    birth_dt_tm = cnvtdatetime(p.birth_dt_tm),
    reply->qual[count2].loc_facility_cd = ed.loc_facility_cd, reply->qual[count2].loc_nurse_unit_cd
     = ed.loc_nurse_unit_cd, reply->qual[count2].loc_room_cd = ed.loc_room_cd,
    reply->qual[count2].loc_bed_cd = ed.loc_bed_cd, reply->qual[count2].encntr_id = ed.encntr_id,
    reply->qual[count2].med_service_cd = ed.med_service_cd,
    reply->qual[count2].alias = trim(pa.alias), reply->qual[count2].person_alias_type_cd = pa
    .person_alias_type_cd
    IF (maxqualrows=count2)
     context->context_ind = 1, context->counter = count1, context->name_last = name_last,
     context->name_first = name_first, context->soundex_search_ind = soundex_search_ind, context->
     sex_cd = sex_cd,
     context->birth_dt_tm = birth_dt_tm, context->start_age = start_age, context->start_dt_tm =
     start_dt_tm,
     context->end_dt_tm = end_dt_tm, context->loc_facility_cd = loc_facility_cd, context->
     loc_nurse_unit_cd = loc_nurse_unit_cd,
     context->loc_room_cd = loc_room_cd, context->loc_bed_cd = loc_bed_cd, context->med_service_cd =
     med_service_cd,
     context->maxqual = maxqualrows
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
END GO
