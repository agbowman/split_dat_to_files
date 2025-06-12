CREATE PROGRAM bbd_get_donor_search:dba
 RECORD reply(
   1 qual[*]
     2 lock_ind = i2
     2 applctx_id = f8
     2 person_id = f8
     2 person_alias_id = f8
     2 name_full_formatted = vc
     2 donor_number = vc
     2 social_security_number = vc
     2 birth_dt_tm = di8
     2 gender_cd = f8
     2 gender_cd_disp = vc
     2 person_donor_updt_cnt = i4
     2 birth_tz = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET donor_id_type_cd = 0.0
 SET social_security_type_cd = 0.0
 SET hold_person_id = 0.0
 SET dummydata = 0
 SET person_count = 0
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(4,"DONORID",code_cnt,donor_id_type_cd)
 SET stat = uar_get_meaning_by_codeset(4,"SSN",code_cnt,social_security_type_cd)
 IF ((request->demographics_ind=1))
  CALL get_person_by_person_table(dummydata)
 ELSE
  CALL get_person_by_person_alias_table(dummydata)
 ENDIF
 GO TO end_script
 SUBROUTINE get_person_by_person_table(nodata)
  SELECT
   IF ((request->birth_date_ind=1))
    PLAN (p
     WHERE (p.person_id > request->person_id)
      AND p.birth_dt_tm=cnvtdatetime(request->birth_date)
      AND (((request->first_name_ind=1)
      AND p.name_first_key=patstring(request->first_name)) OR ((request->first_name_ind=0)))
      AND (((request->last_name_ind=1)
      AND p.name_last_key=patstring(request->last_name)) OR ((request->last_name_ind=0)))
      AND (((request->middle_name_ind=1)
      AND p.name_middle_key=patstring(request->middle_name)) OR ((request->middle_name_ind=0)))
      AND (((request->mothers_maiden_name_ind=1)
      AND cnvtupper(p.mother_maiden_name)=patstring(request->mothers_maiden_name)) OR ((request->
     mothers_maiden_name_ind=0)))
      AND (((request->gender_cd > 0)
      AND (p.sex_cd=request->gender_cd)) OR ((request->gender_cd=0)))
      AND p.active_ind=1
      AND cnvtdatetime(curdate,curtime3) >= p.beg_effective_dt_tm
      AND cnvtdatetime(curdate,curtime3) <= p.end_effective_dt_tm)
     JOIN (pa
     WHERE pa.person_id=p.person_id
      AND ((pa.person_alias_type_cd=donor_id_type_cd
      AND cnvtupper(pa.alias)=cnvtupper(request->donor_number)
      AND (request->donor_number_ind=1)) OR ((request->donor_number_ind=0)))
      AND ((pa.person_alias_type_cd=social_security_type_cd
      AND (pa.alias=request->social_security_nbr)
      AND (request->social_security_nbr_ind=1)) OR ((request->social_security_nbr_ind=0)))
      AND pa.active_ind=1
      AND cnvtdatetime(curdate,curtime3) >= pa.beg_effective_dt_tm
      AND cnvtdatetime(curdate,curtime3) <= pa.end_effective_dt_tm)
     JOIN (pd
     WHERE pd.person_id=pa.person_id
      AND pd.active_ind=1)
   ELSE
    PLAN (p
     WHERE (p.person_id > request->person_id)
      AND (((request->first_name_ind=1)
      AND p.name_first_key=patstring(request->first_name)) OR ((request->first_name_ind=0)))
      AND (((request->last_name_ind=1)
      AND p.name_last_key=patstring(request->last_name)) OR ((request->last_name_ind=0)))
      AND (((request->middle_name_ind=1)
      AND p.name_middle_key=patstring(request->middle_name)) OR ((request->middle_name_ind=0)))
      AND (((request->mothers_maiden_name_ind=1)
      AND cnvtupper(p.mother_maiden_name)=patstring(request->mothers_maiden_name)) OR ((request->
     mothers_maiden_name_ind=0)))
      AND p.birth_dt_tm < cnvtdatetime(request->age_from)
      AND p.birth_dt_tm > cnvtdatetime(request->age_to)
      AND (((request->gender_cd > 0)
      AND (p.sex_cd=request->gender_cd)) OR ((request->gender_cd=0)))
      AND p.active_ind=1
      AND cnvtdatetime(curdate,curtime3) >= p.beg_effective_dt_tm
      AND cnvtdatetime(curdate,curtime3) <= p.end_effective_dt_tm)
     JOIN (pa
     WHERE pa.person_id=p.person_id
      AND ((pa.person_alias_type_cd=donor_id_type_cd
      AND cnvtupper(pa.alias)=cnvtupper(request->donor_number)
      AND (request->donor_number_ind=1)) OR ((request->donor_number_ind=0)))
      AND ((pa.person_alias_type_cd=social_security_type_cd
      AND (pa.alias=request->social_security_nbr)
      AND (request->social_security_nbr_ind=1)) OR ((request->social_security_nbr_ind=0)))
      AND pa.active_ind=1
      AND cnvtdatetime(curdate,curtime3) >= pa.beg_effective_dt_tm
      AND cnvtdatetime(curdate,curtime3) <= pa.end_effective_dt_tm)
     JOIN (pd
     WHERE pd.person_id=pa.person_id
      AND pd.active_ind=1)
   ENDIF
   INTO "nl:"
   p.*, pa.*
   FROM person p,
    person_alias pa,
    person_donor pd
   PLAN (p
    WHERE (p.person_id > request->person_id)
     AND cnvtdatetime(curdate,curtime3) >= p.beg_effective_dt_tm
     AND cnvtdatetime(curdate,curtime3) <= p.end_effective_dt_tm
     AND p.active_ind=1)
    JOIN (pa
    WHERE pa.person_id=p.person_id
     AND ((pa.person_alias_type_cd=donor_id_type_cd) OR (pa.person_alias_type_cd=
    social_security_type_cd))
     AND cnvtdatetime(curdate,curtime3) >= pa.beg_effective_dt_tm
     AND cnvtdatetime(curdate,curtime3) <= pa.end_effective_dt_tm
     AND pa.active_ind=1)
    JOIN (pd
    WHERE pd.person_id=p.person_id
     AND pd.active_ind=1)
   ORDER BY p.person_id
   DETAIL
    IF (hold_person_id != p.person_id)
     hold_person_id = p.person_id, person_count = (person_count+ 1), stat = alterlist(reply->qual,
      person_count),
     reply->qual[person_count].lock_ind = pd.lock_ind, reply->qual[person_count].
     person_donor_updt_cnt = pd.updt_cnt, reply->qual[person_count].applctx_id = pd.updt_applctx,
     reply->qual[person_count].person_id = p.person_id, reply->qual[person_count].person_alias_id =
     pa.person_alias_id, reply->qual[person_count].name_full_formatted = p.name_full_formatted,
     reply->qual[person_count].birth_dt_tm = p.birth_dt_tm, reply->qual[person_count].gender_cd = p
     .sex_cd, reply->qual[person_count].birth_tz = p.birth_tz
    ENDIF
    IF (pa.person_alias_type_cd=donor_id_type_cd)
     reply->qual[person_count].donor_number = pa.alias
    ENDIF
    IF (pa.person_alias_type_cd=social_security_type_cd)
     reply->qual[person_count].social_security_number = pa.alias
    ENDIF
   WITH nocounter, maxqual(p,value(request->max_qual))
  ;end select
  IF (curqual != 0)
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 END ;Subroutine
 SUBROUTINE get_person_by_person_alias_table(nodata)
  SELECT
   IF ((request->birth_date_ind=1))
    PLAN (pa
     WHERE (pa.person_id > request->person_id)
      AND ((pa.person_alias_type_cd=donor_id_type_cd
      AND cnvtupper(pa.alias)=cnvtupper(request->donor_number)
      AND (request->donor_number_ind=1)) OR ((request->donor_number_ind=0)))
      AND ((pa.person_alias_type_cd=social_security_type_cd
      AND (pa.alias=request->social_security_nbr)
      AND (request->social_security_nbr_ind=1)) OR ((request->social_security_nbr_ind=0)))
      AND cnvtdatetime(curdate,curtime3) >= pa.beg_effective_dt_tm
      AND cnvtdatetime(curdate,curtime3) <= pa.end_effective_dt_tm
      AND pa.active_ind=1)
     JOIN (p
     WHERE p.person_id=pa.person_id
      AND p.birth_dt_tm=cnvtdatetime(request->birth_date)
      AND (((request->first_name_ind=1)
      AND p.name_first_key=patstring(request->first_name)) OR ((request->first_name_ind=0)))
      AND (((request->last_name_ind=1)
      AND p.name_last_key=patstring(request->last_name)) OR ((request->last_name_ind=0)))
      AND (((request->middle_name_ind=1)
      AND p.name_middle_key=patstring(request->middle_name)) OR ((request->middle_name_ind=0)))
      AND (((request->mothers_maiden_name_ind=1)
      AND cnvtupper(p.mother_maiden_name)=patstring(request->mothers_maiden_name)) OR ((request->
     mothers_maiden_name_ind=0)))
      AND (((request->gender_cd > 0)
      AND (p.sex_cd=request->gender_cd)) OR ((request->gender_cd=0)))
      AND p.active_ind=1
      AND cnvtdatetime(curdate,curtime3) >= p.beg_effective_dt_tm
      AND cnvtdatetime(curdate,curtime3) <= p.end_effective_dt_tm)
     JOIN (pd
     WHERE pd.person_id=p.person_id
      AND pd.active_ind=1)
   ELSE
    PLAN (pa
     WHERE (pa.person_id > request->person_id)
      AND ((pa.person_alias_type_cd=donor_id_type_cd
      AND cnvtupper(pa.alias)=cnvtupper(request->donor_number)
      AND (request->donor_number_ind=1)) OR ((request->donor_number_ind=0)))
      AND ((pa.person_alias_type_cd=social_security_type_cd
      AND (pa.alias=request->social_security_nbr)
      AND (request->social_security_nbr_ind=1)) OR ((request->social_security_nbr_ind=0)))
      AND pa.active_ind=1
      AND cnvtdatetime(curdate,curtime3) >= pa.beg_effective_dt_tm
      AND cnvtdatetime(curdate,curtime3) <= pa.end_effective_dt_tm)
     JOIN (p
     WHERE p.person_id=pa.person_id
      AND p.birth_dt_tm < cnvtdatetime(request->age_from)
      AND p.birth_dt_tm > cnvtdatetime(request->age_to)
      AND (((request->first_name_ind=1)
      AND p.name_first_key=patstring(request->first_name)) OR ((request->first_name_ind=0)))
      AND (((request->last_name_ind=1)
      AND p.name_last_key=patstring(request->last_name)) OR ((request->last_name_ind=0)))
      AND (((request->middle_name_ind=1)
      AND p.name_middle_key=patstring(request->middle_name)) OR ((request->middle_name_ind=0)))
      AND (((request->mothers_maiden_name_ind=1)
      AND cnvtupper(p.mother_maiden_name)=patstring(request->mothers_maiden_name)) OR ((request->
     mothers_maiden_name_ind=0)))
      AND (((request->gender_cd > 0)
      AND (p.sex_cd=request->gender_cd)) OR ((request->gender_cd=0)))
      AND p.active_ind=1
      AND cnvtdatetime(curdate,curtime3) >= p.beg_effective_dt_tm
      AND cnvtdatetime(curdate,curtime3) <= p.end_effective_dt_tm)
     JOIN (pd
     WHERE pd.person_id=p.person_id
      AND pd.active_ind=1)
   ENDIF
   INTO "nl:"
   p.*, pa.*
   FROM person p,
    person_alias pa,
    person_donor pd
   PLAN (p
    WHERE (p.person_id > request->person_id)
     AND cnvtdatetime(curdate,curtime3) >= p.beg_effective_dt_tm
     AND cnvtdatetime(curdate,curtime3) <= p.end_effective_dt_tm
     AND p.active_ind=1)
    JOIN (pd
    WHERE pd.person_id=p.person_id
     AND pd.active_ind=1)
    JOIN (pa
    WHERE pa.person_id=p.person_id
     AND ((pa.person_alias_type_cd=donor_id_type_cd) OR (pa.person_alias_type_cd=
    social_security_type_cd))
     AND cnvtdatetime(curdate,curtime3) >= pa.beg_effective_dt_tm
     AND cnvtdatetime(curdate,curtime3) <= pa.end_effective_dt_tm
     AND pa.active_ind=1)
   ORDER BY p.person_id
   DETAIL
    IF (hold_person_id != p.person_id)
     hold_person_id = p.person_id, person_count = (person_count+ 1), stat = alterlist(reply->qual,
      person_count),
     reply->qual[person_count].lock_ind = pd.lock_ind, reply->qual[person_count].
     person_donor_updt_cnt = pd.updt_cnt, reply->qual[person_count].applctx_id = pd.updt_applctx,
     reply->qual[person_count].person_id = p.person_id, reply->qual[person_count].person_alias_id =
     pa.person_alias_id, reply->qual[person_count].name_full_formatted = p.name_full_formatted,
     reply->qual[person_count].birth_dt_tm = p.birth_dt_tm, reply->qual[person_count].gender_cd = p
     .sex_cd, reply->qual[person_count].birth_tz = p.birth_tz
    ENDIF
    IF (pa.person_alias_type_cd=donor_id_type_cd)
     reply->qual[person_count].donor_number = pa.alias
    ELSE
     reply->qual[person_count].social_security_number = pa.alias
    ENDIF
   WITH nocounter, maxqual(p,value(request->max_qual))
  ;end select
  IF (curqual != 0)
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 END ;Subroutine
#end_script
END GO
