CREATE PROGRAM cpm_get_pat_by_demographics2:dba
 IF (return_location_ind=0)
  SELECT
   IF (continue_flag=1)
    FROM person p,
     person_alias pa
    PLAN (p
     WHERE p.name_last_key=patstring(context->name_last)
      AND (p.name_last_key >= context->name_last_found)
      AND p.name_first_key=patstring(name_first)
      AND (p.name_first_key >= context->name_first_found)
      AND  $3
      AND  $4
      AND  $5
      AND  $6
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
    ORDER BY p.name_full_formatted
   ELSE
    FROM person p,
     person_alias pa
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
     JOIN (pa
     WHERE p.person_id=pa.person_id
      AND pa.person_alias_type_cd=person_alias_type_cd
      AND pa.active_ind=1
      AND pa.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND pa.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    ORDER BY p.name_full_formatted
   ENDIF
   INTO "nl:"
   age = cnvtage(cnvtdate2(format(p.birth_dt_tm,"mm/dd/yyyy;;d"),"mm/dd/yyyy"),cnvtint(format(p
      .birth_dt_tm,"hhmm;;m")))
   HEAD REPORT
    count1 = 0
   DETAIL
    count1 = (count1+ 1)
    IF (mod(count1,10)=2)
     stat = alter(reply->qual,(count1+ 9))
    ENDIF
    reply->qual[count1].name_full_formatted = p.name_full_formatted, reply->qual[count1].person_id =
    p.person_id, reply->qual[count1].age = age,
    reply->qual[count1].sex_cd = p.sex_cd, reply->qual[count1].birth_dt_tm = cnvtdatetime(p
     .birth_dt_tm), reply->qual[count1].alias = trim(pa.alias),
    reply->qual[count1].person_alias_type_cd = pa.person_alias_type_cd
    IF (count1=maxqualrows)
     CALL echo(build("demo2a context being built ",p.name_last_key)), context->context_ind = 1,
     context->name_last = name_last,
     context->name_first = name_first, context->name_first_ind = name_first_ind, context->
     name_last_found = p.name_last_key,
     context->name_first_found = p.name_first_key, context->person_id = p.person_id, context->
     soundex_search_ind = soundex_search_ind,
     context->sex_cd = sex_cd, context->start_age = start_age, context->start_dt_tm = start_dt_tm,
     context->end_dt_tm = end_dt_tm, context->return_location_ind = return_location_ind, context->
     maxqual = maxqualrows
    ENDIF
   WITH nocounter, maxqual(p,value(maxqualrows))
  ;end select
 ELSE
  SELECT
   IF (continue_flag=0)
    FROM person p,
     person_alias pa,
     encntr_domain ed
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
     JOIN (pa
     WHERE p.person_id=pa.person_id
      AND pa.person_alias_type_cd=person_alias_type_cd
      AND pa.active_ind=1
      AND pa.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND pa.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
     JOIN (ed
     WHERE outerjoin(p.person_id)=ed.person_id
      AND ed.active_ind=1
      AND ed.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND ed.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    ORDER BY p.name_full_formatted
   ELSEIF (continue_flag=1)
    FROM person p,
     person_alias pa,
     (dummyt d  WITH seq = 1),
     encntr_domain ed
    PLAN (p
     WHERE p.name_last_key=patstring(context->name_last)
      AND (p.name_last_key >= context->name_last_found)
      AND p.name_first_key=patstring(name_first)
      AND (p.name_first_key >= context->name_first_found)
      AND  $3
      AND  $4
      AND  $5
      AND  $6
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
     JOIN (ed
     WHERE outerjoin(p.person_id)=ed.person_id
      AND ed.active_ind=1
      AND ed.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND ed.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    ORDER BY p.name_full_formatted
   ELSE
   ENDIF
   INTO "nl:"
   age = cnvtage(cnvtdate2(format(p.birth_dt_tm,"mm/dd/yyyy;;d"),"mm/dd/yyyy"),cnvtint(format(p
      .birth_dt_tm,"hhmm;;m")))
   HEAD REPORT
    count1 = 0
   DETAIL
    count1 = (count1+ 1)
    IF (mod(count1,10)=2)
     stat = alter(reply->qual,(count1+ 9))
    ENDIF
    reply->qual[count1].name_full_formatted = p.name_full_formatted, reply->qual[count1].person_id =
    p.person_id, reply->qual[count1].age = age,
    reply->qual[count1].sex_cd = p.sex_cd, reply->qual[count1].birth_dt_tm = cnvtdatetime(p
     .birth_dt_tm), reply->qual[count1].alias = trim(pa.alias),
    reply->qual[count1].person_alias_type_cd = pa.person_alias_type_cd
    IF (return_location_ind=1)
     reply->qual[count1].loc_facility_cd = ed.loc_facility_cd, reply->qual[count1].loc_nurse_unit_cd
      = ed.loc_nurse_unit_cd, reply->qual[count1].loc_room_cd = ed.loc_room_cd,
     reply->qual[count1].loc_bed_cd = ed.loc_bed_cd, reply->qual[count1].encntr_id = ed.encntr_id,
     reply->qual[count1].med_service_cd = ed.med_service_cd
    ENDIF
    IF (count1=maxqualrows)
     CALL echo(build("demo2b context being built ",p.name_last_key)), context->context_ind = 1,
     context->name_last = name_last,
     context->name_first = name_first, context->name_first_ind = name_first_ind, context->
     name_last_found = p.name_last_key,
     context->name_first_found = p.name_first_key, context->person_id = p.person_id, context->
     soundex_search_ind = soundex_search_ind,
     context->sex_cd = sex_cd, context->start_age = start_age, context->start_dt_tm = start_dt_tm,
     context->end_dt_tm = end_dt_tm, context->return_location_ind = return_location_ind, context->
     maxqual = maxqualrows
    ENDIF
   WITH nocounter, maxqual(p,value(maxqualrows))
  ;end select
 ENDIF
 IF (curqual > 0)
  SET success = 1
 ENDIF
END GO
