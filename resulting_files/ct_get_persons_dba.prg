CREATE PROGRAM ct_get_persons:dba
 RECORD reply(
   1 person[*]
     2 person_id = f8
     2 updt_cnt = i4
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_task = i4
     2 updt_applctx = i4
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_prsnl_id = f8
     2 active_status_dt_tm = dq8
     2 create_dt_tm = dq8
     2 create_prsnl_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 person_type_cd = f8
     2 name_last_key = c100
     2 name_first_key = c100
     2 name_full_formatted = c100
     2 autopsy_cd = f8
     2 birth_dt_cd = f8
     2 birth_dt_tm = dq8
     2 conception_dt_tm = dq8
     2 cause_of_death = c100
     2 deceased_cd = f8
     2 deceased_dt_tm = dq8
     2 ethnic_grp_cd = f8
     2 language_cd = f8
     2 marital_type_cd = f8
     2 purge_option_cd = f8
     2 race_cd = f8
     2 religion_cd = f8
     2 sex_cd = f8
     2 sex_age_change_ind = i2
     2 data_status_cd = f8
     2 data_status_dt_tm = dq8
     2 data_status_prsnl_id = f8
     2 contributor_system_cd = f8
     2 language_dialect_cd = f8
     2 name_last = c200
     2 name_first = c200
     2 name_phonetic = c8
     2 last_encntr_dt_tm = dq8
     2 species_cd = f8
     2 confid_level_cd = f8
     2 vip_cd = f8
     2 name_first_synonym_id = f8
     2 citizenship_cd = f8
     2 vet_military_status_cd = f8
     2 mother_maiden_name = c100
     2 nationality_cd = f8
     2 ft_entity_name = c32
     2 ft_entity_id = f8
     2 name_middle_key = c100
     2 name_middle = c200
     2 name_last_phonetic = c8
     2 name_first_phonetic = c8
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
 SELECT DISTINCT INTO "nl:"
  p.*
  FROM (dummyt d  WITH seq = value(request->person_qual)),
   person p
  PLAN (d)
   JOIN (p
   WHERE (p.person_id=request->person[d.seq].person_id)
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  HEAD REPORT
   count1 = 0, stat = alterlist(reply->person,10)
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=1
    AND count1 != 1)
    stat = alterlist(reply->person,(count1+ 9))
   ENDIF
   reply->person[count1].person_id = p.person_id, reply->person[count1].updt_cnt = p.updt_cnt, reply
   ->person[count1].updt_dt_tm = p.updt_dt_tm,
   reply->person[count1].updt_id = p.updt_id, reply->person[count1].updt_task = p.updt_task, reply->
   person[count1].updt_applctx = p.updt_applctx,
   reply->person[count1].active_ind = p.active_ind, reply->person[count1].active_status_cd = p
   .active_status_cd, reply->person[count1].active_status_prsnl_id = p.active_status_prsnl_id,
   reply->person[count1].active_status_dt_tm = p.active_status_dt_tm, reply->person[count1].
   create_dt_tm = p.create_dt_tm, reply->person[count1].create_prsnl_id = p.create_prsnl_id,
   reply->person[count1].beg_effective_dt_tm = p.beg_effective_dt_tm, reply->person[count1].
   end_effective_dt_tm = p.end_effective_dt_tm, reply->person[count1].person_type_cd = p
   .person_type_cd,
   reply->person[count1].name_last_key = p.name_last_key, reply->person[count1].name_first_key = p
   .name_first_key, reply->person[count1].name_full_formatted = p.name_full_formatted,
   reply->person[count1].autopsy_cd = p.autopsy_cd, reply->person[count1].birth_dt_cd = p.birth_dt_cd,
   reply->person[count1].birth_dt_tm = p.birth_dt_tm,
   reply->person[count1].conception_dt_tm = p.conception_dt_tm, reply->person[count1].cause_of_death
    = p.cause_of_death, reply->person[count1].deceased_cd = p.deceased_cd,
   reply->person[count1].deceased_dt_tm = p.deceased_dt_tm, reply->person[count1].ethnic_grp_cd = p
   .ethnic_grp_cd, reply->person[count1].language_cd = p.language_cd,
   reply->person[count1].marital_type_cd = p.marital_type_cd, reply->person[count1].purge_option_cd
    = p.purge_option_cd, reply->person[count1].race_cd = p.race_cd,
   reply->person[count1].religion_cd = p.religion_cd, reply->person[count1].sex_cd = p.sex_cd, reply
   ->person[count1].sex_age_change_ind = p.sex_age_change_ind,
   reply->person[count1].data_status_cd = p.data_status_cd, reply->person[count1].data_status_dt_tm
    = p.data_status_dt_tm, reply->person[count1].data_status_prsnl_id = p.data_status_prsnl_id,
   reply->person[count1].contributor_system_cd = p.contributor_system_cd, reply->person[count1].
   language_dialect_cd = p.language_dialect_cd, reply->person[count1].name_last = p.name_last,
   reply->person[count1].name_first = p.name_first, reply->person[count1].name_phonetic = p
   .name_phonetic, reply->person[count1].last_encntr_dt_tm = p.last_encntr_dt_tm,
   reply->person[count1].species_cd = p.species_cd, reply->person[count1].confid_level_cd = p
   .confid_level_cd, reply->person[count1].vip_cd = p.vip_cd,
   reply->person[count1].name_first_synonym_id = p.name_first_synonym_id, reply->person[count1].
   citizenship_cd = p.citizenship_cd, reply->person[count1].vet_military_status_cd = p
   .vet_military_status_cd,
   reply->person[count1].mother_maiden_name = p.mother_maiden_name, reply->person[count1].
   nationality_cd = p.nationality_cd, reply->person[count1].ft_entity_name = p.ft_entity_name,
   reply->person[count1].ft_entity_id = p.ft_entity_id, reply->person[count1].name_middle_key = p
   .name_middle_key, reply->person[count1].name_middle = p.name_middle,
   reply->person[count1].name_last_phonetic = p.name_last_phonetic, reply->person[count1].
   name_first_phonetic = p.name_first_phonetic
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->person,count1)
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
