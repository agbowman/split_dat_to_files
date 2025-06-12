CREATE PROGRAM cr_upd_auth_profile:dba
 IF (validate(reply) != 1)
  FREE RECORD reply
  RECORD reply(
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
 DECLARE currentauthprofileusername = vc
 DECLARE nnumbofauthprofiles = i4 WITH noconstant(size(request->auth_profile,5))
 DECLARE currentlogicaldomain = f8
 DECLARE updateauthorizationprofiles(null) = i2
 DECLARE getcurrentlogicaldomain(null) = i2
 SET reply->status_data.status = "F"
 CALL getcurrentlogicaldomain(null)
 CALL updateauthorizationprofiles(null)
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
 SUBROUTINE updateauthorizationprofiles(null)
   FOR (n = 1 TO nnumbofauthprofiles)
     SELECT INTO "nl:"
      FROM authorization_profile ap
      WHERE (ap.profile_type_cd=request->auth_profile[n].profile_type_cd)
       AND ap.logical_domain_id=currentlogicaldomain
      WITH nocounter
     ;end select
     IF (curqual=1)
      UPDATE  FROM authorization_profile ap
       SET ap.profile_prsnl_id = request->auth_profile[n].prsnl_id, ap.updt_cnt = (ap.updt_cnt+ 1),
        ap.updt_dt_tm = cnvtdatetime(curdate,curtime3),
        ap.updt_id = reqinfo->updt_id, ap.updt_applctx = reqinfo->updt_applctx, ap.updt_task =
        reqinfo->updt_task
       WHERE (ap.profile_type_cd=request->auth_profile[n].profile_type_cd)
        AND ap.logical_domain_id=currentlogicaldomain
      ;end update
     ELSE
      INSERT  FROM authorization_profile ap
       SET ap.authorization_profile_id = seq(reference_seq,nextval), ap.profile_prsnl_id = request->
        auth_profile[n].prsnl_id, ap.logical_domain_id = currentlogicaldomain,
        ap.profile_type_cd = request->auth_profile[n].profile_type_cd, ap.updt_cnt = 0, ap.updt_dt_tm
         = cnvtdatetime(curdate,curtime3),
        ap.updt_id = reqinfo->updt_id, ap.updt_applctx = reqinfo->updt_applctx, ap.updt_task =
        reqinfo->updt_task
      ;end insert
     ENDIF
     IF ((request->auth_profile[n].profile_type_cd=patient_user_adolescent_access))
      IF (validate(request->auth_profile[n].age_lower_bound_val))
       SELECT INTO "nl:"
        FROM authorization_age_range ar
        WHERE ar.logical_domain_id=currentlogicaldomain
         AND ar.profile_type_cd=patient_user_adolescent_access
        WITH nocounter
       ;end select
       IF (curqual=0)
        INSERT  FROM authorization_age_range ar
         SET ar.authorization_age_range_id = seq(reference_seq,nextval), ar.logical_domain_id =
          currentlogicaldomain, ar.profile_type_cd = patient_user_adolescent_access,
          ar.age_lower_bound_val = request->auth_profile[n].age_lower_bound_val, ar
          .age_upper_bound_val = request->auth_profile[n].age_upper_bound_val, ar.updt_cnt = 0,
          ar.updt_dt_tm = cnvtdatetime(curdate,curtime3), ar.updt_id = reqinfo->updt_id, ar
          .updt_applctx = reqinfo->updt_applctx,
          ar.updt_task = reqinfo->updt_task
        ;end insert
       ELSE
        UPDATE  FROM authorization_age_range ar
         SET ar.age_lower_bound_val = request->auth_profile[n].age_lower_bound_val, ar
          .age_upper_bound_val = request->auth_profile[n].age_upper_bound_val, ar.updt_cnt = (ar
          .updt_cnt+ 1),
          ar.updt_dt_tm = cnvtdatetime(curdate,curtime3), ar.updt_id = reqinfo->updt_id, ar
          .updt_applctx = reqinfo->updt_applctx,
          ar.updt_task = reqinfo->updt_task
         WHERE ar.logical_domain_id=currentlogicaldomain
          AND ar.profile_type_cd=patient_user_adolescent_access
        ;end update
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
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
