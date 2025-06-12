CREATE PROGRAM bed_get_info_button_by_id:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 buttons[*]
      2 service_id = f8
      2 service_name = vc
      2 service_uri = vc
      2 user_name = vc
      2 password = vc
      2 service_type
        3 code_value = f8
        3 display = vc
        3 mean = vc
        3 description = vc
      2 categories[*]
        3 category
          4 code_value = f8
          4 display = vc
          4 mean = vc
          4 description = vc
        3 nomens[*]
          4 nomen
            5 code_value = f8
            5 display = vc
            5 mean = vc
            5 description = vc
      2 facilities[*]
        3 facility
          4 code_value = f8
          4 display = vc
          4 mean = vc
          4 description = vc
      2 send_personel_id = i2
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
 DECLARE bed_is_logical_domain(dummyvar=i2) = i2
 DECLARE bed_get_logical_domain(dummyvar=i2) = f8
 SUBROUTINE bed_is_logical_domain(dummyvar)
   RETURN(checkprg("ACM_GET_CURR_LOGICAL_DOMAIN"))
 END ;Subroutine
 SUBROUTINE bed_get_logical_domain(dummyvar)
  IF (bed_is_logical_domain(null))
   IF (validate(ld_concept_person)=0)
    DECLARE ld_concept_person = i2 WITH public, constant(1)
   ENDIF
   IF (validate(ld_concept_prsnl)=0)
    DECLARE ld_concept_prsnl = i2 WITH public, constant(2)
   ENDIF
   IF (validate(ld_concept_organization)=0)
    DECLARE ld_concept_organization = i2 WITH public, constant(3)
   ENDIF
   IF (validate(ld_concept_healthplan)=0)
    DECLARE ld_concept_healthplan = i2 WITH public, constant(4)
   ENDIF
   IF (validate(ld_concept_alias_pool)=0)
    DECLARE ld_concept_alias_pool = i2 WITH public, constant(5)
   ENDIF
   IF (validate(ld_concept_minvalue)=0)
    DECLARE ld_concept_minvalue = i2 WITH public, constant(1)
   ENDIF
   IF (validate(ld_concept_maxvalue)=0)
    DECLARE ld_concept_maxvalue = i2 WITH public, constant(5)
   ENDIF
   RECORD acm_get_curr_logical_domain_req(
     1 concept = i4
   )
   RECORD acm_get_curr_logical_domain_rep(
     1 logical_domain_id = f8
     1 status_block
       2 status_ind = i2
       2 error_code = i4
   )
   SET acm_get_curr_logical_domain_req->concept = ld_concept_prsnl
   EXECUTE acm_get_curr_logical_domain  WITH replace("REQUEST",acm_get_curr_logical_domain_req),
   replace("REPLY",acm_get_curr_logical_domain_rep)
   IF ( NOT (acm_get_curr_logical_domain_rep->status_block.status_ind)
    AND checkfun("BEDERROR"))
    CALL bederror(build("Logical Domain Error: ",acm_get_curr_logical_domain_rep->status_block.
      error_code))
   ENDIF
   RETURN(acm_get_curr_logical_domain_rep->logical_domain_id)
  ENDIF
  RETURN(null)
 END ;Subroutine
 DECLARE log_domain_id = f8 WITH protect, constant(bed_get_logical_domain(0))
 DECLARE repcnt = i4 WITH noconstant(0)
 DECLARE catcnt = i4 WITH noconstant(0)
 DECLARE vocabcnt = i4 WITH noconstant(0)
 DECLARE facilitycnt = i4 WITH noconstant(0)
 DECLARE req_size = i4 WITH noconstant(0)
 SET req_size = size(request->button_ids,5)
 IF (req_size=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = req_size),
   si_external_service ses,
   code_value cv,
   si_service_property si
  PLAN (d)
   JOIN (ses
   WHERE (ses.si_external_service_id=request->button_ids[d.seq].service_id)
    AND ses.logical_domain_id=log_domain_id)
   JOIN (cv
   WHERE cv.code_value=ses.external_service_type_cd)
   JOIN (si
   WHERE si.parent_entity_id=outerjoin(ses.si_external_service_id)
    AND si.prop_name=outerjoin("SEND_USERNAME_AS_AUTHORIZED"))
  ORDER BY ses.si_external_service_id, si.si_service_property_id
  HEAD REPORT
   repcnt = 0, stat = alterlist(reply->buttons,100)
  HEAD ses.si_external_service_id
   repcnt = (repcnt+ 1)
   IF (repcnt > 100)
    stat = alterlist(reply->buttons,(repcnt+ 100))
   ENDIF
   reply->buttons[repcnt].service_id = ses.si_external_service_id, reply->buttons[repcnt].
   service_name = ses.service_name, reply->buttons[repcnt].service_uri = ses.service_uri,
   reply->buttons[repcnt].user_name = ses.username_txt, reply->buttons[repcnt].password = ses
   .certificate_txt, reply->buttons[repcnt].service_type.code_value = ses.external_service_type_cd,
   reply->buttons[repcnt].service_type.display = cv.display, reply->buttons[repcnt].service_type.mean
    = cv.cdf_meaning, reply->buttons[repcnt].service_type.description = cv.description
  HEAD si.si_service_property_id
   IF (si.prop_value="ENABLED")
    reply->buttons[repcnt].send_personel_id = 1
   ELSEIF (si.prop_value="DISABLED")
    reply->buttons[repcnt].send_personel_id = 0
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->buttons,repcnt)
  WITH nocounter
 ;end select
 CALL bederrorcheck("Return btn error")
 IF (repcnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = repcnt),
    si_external_service_vocab sesv,
    code_value cv
   PLAN (cv
    WHERE cv.code_set=15782)
    JOIN (sesv
    WHERE sesv.content_category_cd=outerjoin(cv.code_value))
    JOIN (d
    WHERE sesv.si_external_service_id=outerjoin(reply->buttons[d.seq].service_id))
   ORDER BY d.seq, cv.code_value
   HEAD d.seq
    catcnt = 0
   HEAD cv.code_value
    catcnt = (catcnt+ 1), stat = alterlist(reply->buttons[d.seq].categories,catcnt), reply->buttons[d
    .seq].categories[catcnt].category.code_value = cv.code_value,
    reply->buttons[d.seq].categories[catcnt].category.description = cv.description, reply->buttons[d
    .seq].categories[catcnt].category.display = cv.display, reply->buttons[d.seq].categories[catcnt].
    category.mean = cv.cdf_meaning
   WITH nocounter
  ;end select
  CALL bederrorcheck("Return cat error")
 ENDIF
 IF (repcnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = repcnt),
    (dummyt d2  WITH seq = 1),
    si_external_service_vocab sesv,
    code_value cv
   PLAN (d1
    WHERE maxrec(d2,size(reply->buttons[d1.seq].categories,5)))
    JOIN (d2)
    JOIN (sesv
    WHERE (sesv.si_external_service_id=reply->buttons[d1.seq].service_id)
     AND (sesv.content_category_cd=reply->buttons[d1.seq].categories[d2.seq].category.code_value)
     AND sesv.vocabulary_cd > 0.0)
    JOIN (cv
    WHERE cv.code_value=sesv.vocabulary_cd)
   ORDER BY d1.seq, d2.seq
   HEAD d1.seq
    vocabcnt = 0
   HEAD d2.seq
    vocabcnt = 0
   DETAIL
    vocabcnt = (vocabcnt+ 1), stat = alterlist(reply->buttons[d1.seq].categories[d2.seq].nomens,
     vocabcnt), reply->buttons[d1.seq].categories[d2.seq].nomens[vocabcnt].nomen.code_value = cv
    .code_value,
    reply->buttons[d1.seq].categories[d2.seq].nomens[vocabcnt].nomen.description = cv.description,
    reply->buttons[d1.seq].categories[d2.seq].nomens[vocabcnt].nomen.mean = cv.cdf_meaning, reply->
    buttons[d1.seq].categories[d2.seq].nomens[vocabcnt].nomen.display = cv.display
   WITH nocounter
  ;end select
  CALL bederrorcheck("Return vocab error")
 ENDIF
 IF (repcnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = repcnt),
    si_service_reltn ssr,
    location loc,
    code_value cv
   PLAN (d)
    JOIN (ssr
    WHERE (ssr.si_external_service_id=reply->buttons[d.seq].service_id)
     AND ssr.parent_entity_name="LOCATION")
    JOIN (loc
    WHERE loc.location_cd=ssr.parent_entity_id)
    JOIN (cv
    WHERE cv.code_value=loc.location_cd)
   ORDER BY d.seq, ssr.si_external_service_id, loc.location_cd
   HEAD d.seq
    facilitycnt = 0
   HEAD ssr.si_external_service_id
    dummyvar = 0
   HEAD loc.location_cd
    facilitycnt = (facilitycnt+ 1), stat = alterlist(reply->buttons[d.seq].facilities,facilitycnt),
    reply->buttons[d.seq].facilities[facilitycnt].facility.code_value = loc.location_cd,
    reply->buttons[d.seq].facilities[facilitycnt].facility.description = cv.description, reply->
    buttons[d.seq].facilities[facilitycnt].facility.display = cv.display, reply->buttons[d.seq].
    facilities[facilitycnt].facility.mean = cv.cdf_meaning
   WITH nocounter
  ;end select
  CALL bederrorcheck("Return cat facs error")
 ENDIF
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(reply)
END GO
