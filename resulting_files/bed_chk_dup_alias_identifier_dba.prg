CREATE PROGRAM bed_chk_dup_alias_identifier:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
    1 alias_found = i2
  )
 ENDIF
 DECLARE alias_pool_cd = f8 WITH protect, noconstant(0.0)
 DECLARE duplicate_flag = i4 WITH protect, noconstant(0)
 DECLARE alias_exists_ind = i2 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=263
   AND cv.active_ind=1
   AND cv.display_key=cnvtupper(trim(cnvtalphanum(request->alias_pool_name)))
  DETAIL
   alias_pool_cd = cv.code_value
  WITH nocounter
 ;end select
 IF (alias_pool_cd > 0)
  SELECT INTO "nl:"
   FROM alias_pool ap
   WHERE ap.alias_pool_cd=alias_pool_cd
    AND ap.active_ind=1
   DETAIL
    duplicate_flag = ap.dup_allowed_flag
   WITH nocounter
  ;end select
  IF ((request->alias_mode=1))
   SELECT INTO "nl:"
    FROM organization_alias orga
    PLAN (orga
     WHERE orga.alias_pool_cd=alias_pool_cd
      AND (orga.alias=request->alias)
      AND orga.active_ind=1)
    DETAIL
     alias_exists_ind = 1
    WITH nocounter
   ;end select
  ELSE
   SELECT INTO "nl:"
    FROM health_plan_alias hpa
    PLAN (hpa
     WHERE hpa.alias_pool_cd=alias_pool_cd
      AND (hpa.alias=request->alias)
      AND hpa.active_ind=1)
    DETAIL
     alias_exists_ind = 1
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 IF (alias_exists_ind=1
  AND duplicate_flag=3)
  SET reply->alias_found = 1
 ELSE
  SET reply->alias_found = 0
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
 CALL echorecord(reply)
END GO
