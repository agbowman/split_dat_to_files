CREATE PROGRAM bbd_get_person_alias:dba
 RECORD reply(
   1 qual[*]
     2 person_alias_id = f8
     2 updt_cnt = i4
     2 alias_pool_cd = f8
     2 alias_pool_cd_disp = vc
     2 alias_type_cd = f8
     2 alias_type_cd_disp = vc
     2 alias_type_cd_mean = c12
     2 alias = vc
     2 alias_sub_type_cd = f8
     2 alias_sub_type_cd_mean = c12
     2 check_digit = i4
     2 check_digit_method_cd = f8
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
 SET drivers_license_type_cd = 0.0
 SET medical_rec_nbr_type_cd = 0.0
 SET person_count = 0
 SET cv_cnt = 1
 SET stat = uar_get_meaning_by_codeset(4,"DONORID",cv_cnt,donor_id_type_cd)
 SET stat = uar_get_meaning_by_codeset(4,"SSN",cv_cnt,social_security_type_cd)
 SET stat = uar_get_meaning_by_codeset(4,"MRN",cv_cnt,medical_rec_nbr_type_cd)
 SET stat = uar_get_meaning_by_codeset(4,"DRLIC",cv_cnt,drivers_license_type_cd)
 SELECT INTO "nl:"
  pa.*
  FROM person_alias pa
  PLAN (pa
   WHERE (pa.person_id=request->person_id)
    AND ((pa.person_alias_type_cd=donor_id_type_cd
    AND (request->get_donor_id_ind=1)) OR (((pa.person_alias_type_cd=social_security_type_cd
    AND (request->get_social_sec_ind=1)) OR (((pa.person_alias_type_cd=medical_rec_nbr_type_cd
    AND (request->get_med_rec_nbr_ind=1)) OR (pa.person_alias_type_cd=drivers_license_type_cd
    AND (request->get_driver_license_ind=1))) )) ))
    AND cnvtdatetime(curdate,curtime3) >= pa.beg_effective_dt_tm
    AND cnvtdatetime(curdate,curtime3) <= pa.end_effective_dt_tm
    AND pa.active_ind=1)
  DETAIL
   person_count = (person_count+ 1), stat = alterlist(reply->qual,person_count), reply->qual[
   person_count].person_alias_id = pa.person_alias_id,
   reply->qual[person_count].updt_cnt = pa.updt_cnt, reply->qual[person_count].alias_pool_cd = pa
   .alias_pool_cd, reply->qual[person_count].alias_type_cd = pa.person_alias_type_cd,
   reply->qual[person_count].alias = pa.alias, reply->qual[person_count].alias_sub_type_cd = pa
   .person_alias_sub_type_cd, reply->qual[person_count].check_digit = pa.check_digit,
   reply->qual[person_count].check_digit_method_cd = pa.check_digit_method_cd
  WITH nocounter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#end_script
END GO
