CREATE PROGRAM bed_get_thera_class_by_fac:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 classes[*]
      2 id = f8
      2 name = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE error_flag = vc WITH protect
 DECLARE serrmsg = vc WITH protect
 DECLARE ierrcode = i4 WITH protect
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 DECLARE bederror(errordescription=vc) = null
 DECLARE bederrorcheck(errordescription=vc) = null
 SUBROUTINE bederror(errordescription)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = errordescription
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE bederrorcheck(errordescription)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   CALL bederror(errordescription)
  ENDIF
 END ;Subroutine
 DECLARE cnt = i4 WITH protect
 DECLARE tcnt = i4 WITH protect
 SELECT INTO "nl:"
  m.category_name, m.multum_category_id
  FROM location l,
   cms_critical_location cl,
   cms_critical_category c,
   mltm_drug_categories m
  PLAN (l
   WHERE (l.location_cd=request->facility_code_value))
   JOIN (cl
   WHERE cl.organization_id=l.organization_id
    AND cl.location_cd=l.location_cd)
   JOIN (c
   WHERE c.cms_critical_location_id=cl.cms_critical_location_id)
   JOIN (m
   WHERE m.multum_category_id=c.multum_category_id)
  HEAD REPORT
   cnt = 0, tcnt = 0, stat = alterlist(reply->classes,10)
  DETAIL
   cnt = (cnt+ 1), tcnt = (tcnt+ 1)
   IF (cnt > 10)
    cnt = 1, stat = alterlist(reply->classes,(tcnt+ 10))
   ENDIF
   reply->classes[tcnt].id = m.multum_category_id, reply->classes[tcnt].name = m.category_name
  FOOT REPORT
   stat = alterlist(reply->classes,tcnt)
  WITH nocounter
 ;end select
 CALL bederrorcheck("Error loading TCs")
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(reply)
END GO
