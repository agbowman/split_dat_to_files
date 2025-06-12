CREATE PROGRAM cr_get_auth_profile:dba
 IF (validate(reply) != 1)
  FREE RECORD reply
  RECORD reply(
    1 auth_profile[*]
      2 prsnl_id = f8
      2 profile_type_cd = f8
      2 age_lower_bound_val = i4
      2 age_upper_bound_val = i4
      2 is_age_range_defined = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE patient_user_adolescent_access = f8 WITH protect, constant(uar_get_code_by("MEANING",4002675,
   "PTNADLSCNT"))
 DECLARE currentlogicaldomain = f8
 DECLARE getcurrentlogicaldomain(null) = i2
 DECLARE getauthorizationprofiles(null) = i2
 SET reply->status_data.status = "F"
 CALL getcurrentlogicaldomain(null)
 CALL getauthorizationprofiles(null)
 SET reply->status_data.status = "S"
 SUBROUTINE getauthorizationprofiles(null)
   SELECT INTO "nl:"
    FROM authorization_profile ap,
     authorization_age_range ar
    PLAN (ap
     WHERE ap.logical_domain_id=currentlogicaldomain)
     JOIN (ar
     WHERE ar.profile_type_cd=outerjoin(ap.profile_type_cd)
      AND ar.profile_type_cd=outerjoin(patient_user_adolescent_access)
      AND ar.logical_domain_id=outerjoin(currentlogicaldomain))
    HEAD REPORT
     profile_cnt = 0
    DETAIL
     profile_cnt = (profile_cnt+ 1), stat = alterlist(reply->auth_profile,profile_cnt), reply->
     auth_profile[profile_cnt].prsnl_id = ap.profile_prsnl_id,
     reply->auth_profile[profile_cnt].profile_type_cd = ap.profile_type_cd
     IF ((reply->auth_profile[profile_cnt].profile_type_cd=patient_user_adolescent_access))
      reply->auth_profile[profile_cnt].is_age_range_defined = 1, reply->auth_profile[profile_cnt].
      age_lower_bound_val = ar.age_lower_bound_val, reply->auth_profile[profile_cnt].
      age_upper_bound_val = ar.age_upper_bound_val
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE getcurrentlogicaldomain(null)
   SELECT INTO "nl:"
    FROM prsnl p
    WHERE (p.person_id=reqinfo->updt_id)
    DETAIL
     currentlogicaldomain = p.logical_domain_id
    WITH nocounter
   ;end select
 END ;Subroutine
#exit_script
END GO
