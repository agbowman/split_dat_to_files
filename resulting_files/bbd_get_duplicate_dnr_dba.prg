CREATE PROGRAM bbd_get_duplicate_dnr:dba
 RECORD reply(
   1 qual[*]
     2 person_id = f8
     2 name_full_formatted = vc
     2 donor_number = vc
     2 social_security_number = vc
     2 birth_dt_tm = di8
     2 gender_cd = f8
     2 gender_cd_disp = vc
     2 identical_donor_num_ind = i2
     2 identical_ssn_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 sourceobjectname = c30
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c30
       3 targetobjectvalue = vc
       3 sourceobjectqual = i4
 )
 DECLARE failed = c1
 DECLARE donor_id_type_cd = f8
 DECLARE social_security_type_cd = f8
 DECLARE person_count = i2
 DECLARE code_set = i4
 SET failed = "F"
 SET donor_id_type_cd = 0.0
 SET social_security_type_cd = 0.0
 SET person_count = 0
 SET code_set = 4
 SET cdf_meaning = fillstring(12," ")
 SET cdf_meaning = "DONORID"
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,donor_id_type_cd)
 SET cdf_meaning = fillstring(12," ")
 SET cdf_meaning = "SSN"
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,social_security_type_cd)
 IF (((donor_id_type_cd=0.0) OR (social_security_type_cd=0.0)) )
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_get_duplicate_dnr.prg"
  SET reply->status_data.subeventstatus[1].operationname = "Retrieve"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE"
  IF (donor_id_type_cd=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Error retrieving donor alias type code value."
  ELSE
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Error retrieving social security number alias type code value."
  ENDIF
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  pa.alias, pa.person_alias_type_cd, pa1.alias,
  pa1.person_alias_type_cd, p.person_id
  FROM person_alias pa,
   person p,
   (dummyt d1  WITH seq = 1),
   person_alias pa1
  PLAN (pa
   WHERE ((cnvtupper(pa.alias)=cnvtupper(request->donor_number)
    AND pa.person_alias_type_cd=donor_id_type_cd) OR ((pa.alias=request->social_security_number)
    AND pa.person_alias_type_cd=social_security_type_cd))
    AND (pa.person_id != request->person_id)
    AND pa.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND pa.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND pa.active_ind=1)
   JOIN (p
   WHERE p.person_id=pa.person_id
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND p.active_ind=1)
   JOIN (d1
   WHERE d1.seq=1)
   JOIN (pa1
   WHERE pa1.person_id=pa.person_id
    AND pa1.person_alias_type_cd IN (social_security_type_cd, donor_id_type_cd)
    AND pa1.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND pa1.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND pa1.active_ind=1)
  ORDER BY p.person_id
  HEAD p.person_id
   person_count = (person_count+ 1), stat = alterlist(reply->qual,person_count), reply->qual[
   person_count].identical_donor_num_ind = 0,
   reply->qual[person_count].identical_ssn_ind = 0, reply->qual[person_count].person_id = p.person_id,
   reply->qual[person_count].name_full_formatted = p.name_full_formatted,
   reply->qual[person_count].birth_dt_tm = p.birth_dt_tm, reply->qual[person_count].gender_cd = p
   .sex_cd
  DETAIL
   IF (pa1.person_alias_type_cd=donor_id_type_cd)
    reply->qual[person_count].donor_number = pa1.alias
   ENDIF
   IF (pa1.person_alias_type_cd=social_security_type_cd)
    reply->qual[person_count].social_security_number = pa1.alias
   ENDIF
   IF (pa.person_alias_type_cd=donor_id_type_cd)
    reply->qual[person_count].identical_donor_num_ind = 1
   ENDIF
   IF (pa.person_alias_type_cd=social_security_type_cd)
    reply->qual[person_count].identical_ssn_ind = 1
   ENDIF
  FOOT  p.person_id
   row + 0
  WITH nocounter, outerjoin(d1)
 ;end select
#exit_script
 IF (((curqual != 0) OR (failed="F")) )
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
END GO
