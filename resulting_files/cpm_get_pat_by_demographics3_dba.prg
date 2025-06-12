CREATE PROGRAM cpm_get_pat_by_demographics3:dba
 SELECT
  IF (continue_flag=1)
   FROM person p
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
    AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
   ORDER BY p.name_full_formatted
  ELSE
   FROM person p
   WHERE  $1
    AND  $2
    AND  $3
    AND  $4
    AND  $5
    AND p.active_ind=1
    AND p.person_type_cd=person_type_cd
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
   ORDER BY p.name_full_formatted
  ENDIF
  INTO "nl:"
  p.name_full_formatted, p.person_id, p.sex_cd,
  cnvtdatetime(p.birth_dt_tm), age = cnvtage(cnvtdate2(format(p.birth_dt_tm,"mm/dd/yyyy;;d"),
    "mm/dd/yyyy"),cnvtint(format(p.birth_dt_tm,"hhmm;;m")))
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=2)
    stat = alter(reply->qual,(count1+ 9))
   ENDIF
   reply->qual[count1].name_full_formatted = p.name_full_formatted, reply->qual[count1].person_id = p
   .person_id, reply->qual[count1].age = age,
   reply->qual[count1].sex_cd = p.sex_cd, reply->qual[count1].birth_dt_tm = cnvtdatetime(p
    .birth_dt_tm)
   IF (count1=maxqualrows)
    CALL echo(build("demo3 context being built ",p.name_last_key)), context->context_ind = 1, context
    ->name_last = name_last,
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
 IF (curqual > 0)
  SET success = 1
 ENDIF
 SET code_set = 4
 SET cdf_meaning = "MRN"
 EXECUTE cpm_get_cd_for_cdf
 SET mrn_type_cd = code_value
 SET code_set = 4
 SET cdf_meaning = "SSN"
 EXECUTE cpm_get_cd_for_cdf
 SET ssn_type_cd = code_value
 SET total_persons = count1
 SELECT INTO "nl:"
  p.alias, p.person_alias_type_cd
  FROM person_alias p,
   (dummyt d  WITH seq = value(total_persons))
  PLAN (d)
   JOIN (p
   WHERE (p.person_id=reply->qual[d.seq].person_id)
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  DETAIL
   CASE (p.person_alias_type_cd)
    OF mrn_type_cd:
     count = (size(reply->qual[d.seq].mrn_alias,5)+ 1),stat = alterlist(reply->qual[d.seq].mrn_alias,
      count),reply->qual[d.seq].mrn_alias[count].alias = trim(p.alias)
    OF ssn_type_cd:
     reply->qual[d.seq].alias = trim(p.alias),reply->qual[d.seq].person_alias_type_cd = ssn_type_cd
   ENDCASE
  WITH nocounter
 ;end select
END GO
