CREATE PROGRAM bbd_get_dnr_or_soc:dba
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
 SET reply->status_data.status = "Z"
 SET failed = "F"
 SET donor_id_type_cd = 0.0
 SET social_security_type_cd = 0.0
 SET person_count = 0
 SET hold_person_id = 0.0
 SET dummydata = 0
 SET cdf_meaning = fillstring(12," ")
 SET code_value = 0.0
 SET code_set = 4
 SET cdf_meaning = "DONORID"
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,donor_id_type_cd)
 SET cdf_meaning = "SSN"
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,social_security_type_cd)
 IF (((donor_id_type_cd=0.0) OR (social_security_type_cd=0.0)) )
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].operationname = "UAR"
  SET reply->status_data.subeventstatus[1].targetobjectname = "code_value"
  IF (donor_id_type_cd=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to read donor id type code value"
  ELSE
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to read social security type code value"
  ENDIF
  GO TO end_script
 ENDIF
 IF ((request->donor_number_ind=1)
  AND (request->social_security_number_ind=1))
  CALL get_person_by_dnr_and_soc_nbrs(dummydata)
 ELSEIF ((request->donor_number_ind=1)
  AND (request->social_security_number_ind=0))
  CALL get_person_by_dnr_nbr(dummydata)
 ELSEIF ((request->donor_number_ind=0)
  AND (request->social_security_number_ind=1))
  CALL get_person_by_soc_nbr(dummydata)
 ENDIF
 GO TO end_script
 SUBROUTINE get_person_by_dnr_and_soc_nbrs(nodata)
  SELECT INTO "nl:"
   p.*, pa.*, pa1.*
   FROM person p,
    person_alias pa,
    person_alias pa1,
    person_donor pd
   PLAN (pa
    WHERE (pa.person_id > request->person_id)
     AND cnvtupper(pa.alias)=patstring(cnvtupper(request->donor_number))
     AND pa.person_alias_type_cd=donor_id_type_cd
     AND cnvtdatetime(curdate,curtime3) >= pa.beg_effective_dt_tm
     AND cnvtdatetime(curdate,curtime3) <= pa.end_effective_dt_tm
     AND pa.active_ind=1)
    JOIN (p
    WHERE p.person_id=pa.person_id
     AND cnvtdatetime(curdate,curtime3) >= p.beg_effective_dt_tm
     AND cnvtdatetime(curdate,curtime3) <= p.end_effective_dt_tm
     AND p.active_ind=1)
    JOIN (pa1
    WHERE pa1.person_id=p.person_id
     AND pa1.person_alias_type_cd=social_security_type_cd
     AND (pa1.alias=request->social_security_number)
     AND cnvtdatetime(curdate,curtime3) >= pa1.beg_effective_dt_tm
     AND cnvtdatetime(curdate,curtime3) <= pa1.end_effective_dt_tm
     AND pa1.active_ind=1)
    JOIN (pd
    WHERE pd.person_id=p.person_id
     AND pd.active_ind=1)
   ORDER BY pa.person_id
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
    IF (pa1.person_alias_type_cd=social_security_type_cd)
     reply->qual[person_count].social_security_number = pa1.alias
    ENDIF
   WITH nocounter, maxqual(p,value(request->max_qual))
  ;end select
  IF (curqual != 0)
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 END ;Subroutine
 SUBROUTINE get_person_by_dnr_nbr(nodata)
  SELECT INTO "nl:"
   p.*, pa.*, pa1.*
   FROM person p,
    person_alias pa,
    (dummyt d1  WITH seq = 1),
    person_alias pa1,
    person_donor pd
   PLAN (pa
    WHERE (pa.person_id > request->person_id)
     AND cnvtupper(pa.alias)=patstring(cnvtupper(request->donor_number))
     AND pa.person_alias_type_cd=donor_id_type_cd
     AND cnvtdatetime(curdate,curtime3) >= pa.beg_effective_dt_tm
     AND cnvtdatetime(curdate,curtime3) <= pa.end_effective_dt_tm
     AND pa.active_ind=1)
    JOIN (p
    WHERE p.person_id=pa.person_id
     AND cnvtdatetime(curdate,curtime3) >= p.beg_effective_dt_tm
     AND cnvtdatetime(curdate,curtime3) <= p.end_effective_dt_tm
     AND p.active_ind=1)
    JOIN (pd
    WHERE pd.person_id=p.person_id
     AND pd.active_ind=1)
    JOIN (d1
    WHERE d1.seq=1)
    JOIN (pa1
    WHERE pa1.person_id=p.person_id
     AND pa1.person_alias_type_cd=social_security_type_cd
     AND cnvtdatetime(curdate,curtime3) >= pa1.beg_effective_dt_tm
     AND cnvtdatetime(curdate,curtime3) <= pa1.end_effective_dt_tm
     AND pa1.active_ind=1)
   ORDER BY pa.person_id
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
    IF (pa1.person_alias_type_cd=social_security_type_cd)
     reply->qual[person_count].social_security_number = pa1.alias
    ENDIF
   WITH nocounter, maxqual(pa,value(request->max_qual)), outerjoin(d1)
  ;end select
  IF (curqual != 0)
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 END ;Subroutine
 SUBROUTINE get_person_by_soc_nbr(nodata)
  SELECT INTO "nl:"
   p.*, pa.*, pa1.*
   FROM person p,
    person_alias pa,
    (dummyt d1  WITH seq = 1),
    person_alias pa1,
    person_donor pd
   PLAN (pa
    WHERE (pa.person_id > request->person_id)
     AND (pa.alias=request->social_security_number)
     AND pa.person_alias_type_cd=social_security_type_cd
     AND cnvtdatetime(curdate,curtime3) >= pa.beg_effective_dt_tm
     AND cnvtdatetime(curdate,curtime3) <= pa.end_effective_dt_tm
     AND pa.active_ind=1)
    JOIN (p
    WHERE p.person_id=pa.person_id
     AND cnvtdatetime(curdate,curtime3) >= p.beg_effective_dt_tm
     AND cnvtdatetime(curdate,curtime3) <= p.end_effective_dt_tm
     AND p.active_ind=1)
    JOIN (d1
    WHERE d1.seq=1)
    JOIN (pa1
    WHERE pa1.person_id=p.person_id
     AND pa1.person_alias_type_cd=donor_id_type_cd
     AND cnvtdatetime(curdate,curtime3) >= pa1.beg_effective_dt_tm
     AND cnvtdatetime(curdate,curtime3) <= pa1.end_effective_dt_tm
     AND pa1.active_ind=1)
    JOIN (pd
    WHERE pd.person_id=p.person_id
     AND pd.active_ind=1)
   ORDER BY pa.person_id
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
    IF (pa1.person_alias_type_cd=donor_id_type_cd)
     reply->qual[person_count].donor_number = pa1.alias
    ENDIF
    IF (pa.person_alias_type_cd=social_security_type_cd)
     reply->qual[person_count].social_security_number = pa.alias
    ENDIF
   WITH nocounter, maxqual(pa,value(request->max_qual)), outerjoin(d1)
  ;end select
  IF (curqual != 0)
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 END ;Subroutine
#end_script
 IF (failed="T")
  SET reply->status_data.status = "F"
 ENDIF
END GO
