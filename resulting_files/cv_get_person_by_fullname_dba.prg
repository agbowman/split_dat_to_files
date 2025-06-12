CREATE PROGRAM cv_get_person_by_fullname:dba
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET replace_error = 6
 SET delete_error = 7
 SET undelete_error = 8
 SET remove_error = 9
 SET attribute_error = 10
 SET lock_error = 11
 SET none_found = 12
 SET select_error = 13
 SET failed = false
 SET table_name = fillstring(50," ")
 RECORD reply(
   1 person[10]
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
     2 autopsy_ind = i2
     2 birth_dt_cd = f8
     2 birth_dt_tm = dq8
     2 blood_group_cd = f8
     2 blood_type_cd = f8
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
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET count1 = 0
 SET reply->status_data.status = "F"
 SET name_full_formatted_length = size(trim(request->name_full_formatted))
 IF (name_full_formatted_length > 0)
  SELECT INTO "nl:"
   p.*
   FROM person p
   WHERE cnvtupper(trim(p.name_full_formatted,3))=cnvtupper(trim(request->name_full_formatted,3))
    AND (p.active_ind=request->active_ind)
   DETAIL
    count1 = (count1+ 1)
    IF (mod(count1,10)=1
     AND count1 != 1)
     stat = alter(reply->person,(count1+ 10))
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
    reply->person[count1].birth_dt_cd = p.birth_dt_cd, reply->person[count1].birth_dt_tm = p
    .birth_dt_tm, reply->person[count1].conception_dt_tm = p.conception_dt_tm,
    reply->person[count1].cause_of_death = p.cause_of_death, reply->person[count1].deceased_cd = p
    .deceased_cd, reply->person[count1].deceased_dt_tm = p.deceased_dt_tm,
    reply->person[count1].ethnic_grp_cd = p.ethnic_grp_cd, reply->person[count1].language_cd = p
    .language_cd, reply->person[count1].marital_type_cd = p.marital_type_cd,
    reply->person[count1].purge_option_cd = p.purge_option_cd, reply->person[count1].race_cd = p
    .race_cd, reply->person[count1].religion_cd = p.religion_cd,
    reply->person[count1].sex_cd = p.sex_cd, reply->person[count1].sex_age_change_ind = p
    .sex_age_change_ind, reply->person[count1].data_status_cd = p.data_status_cd,
    reply->person[count1].data_status_dt_tm = p.data_status_dt_tm, reply->person[count1].
    data_status_prsnl_id = p.data_status_prsnl_id, reply->person[count1].contributor_system_cd = p
    .contributor_system_cd,
    reply->person[count1].language_dialect_cd = p.language_dialect_cd, reply->person[count1].
    name_last = p.name_last, reply->person[count1].name_first = p.name_first,
    reply->person[count1].name_phonetic = p.name_phonetic, reply->person[count1].last_encntr_dt_tm =
    p.last_encntr_dt_tm, reply->person[count1].species_cd = p.species_cd,
    reply->person[count1].confid_level_cd = p.confid_level_cd, reply->person[count1].vip_cd = p
    .vip_cd
   WITH nocounter, maxqual(p,50)
  ;end select
 ENDIF
 SET stat = alter(reply->person,count1)
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "PERSON"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
