CREATE PROGRAM bed_get_dup_secure_email:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 duplicates[*]
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
 DECLARE error_flag = vc
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 DECLARE email_type_cd = f8 WITH protect
 DECLARE dcnt = i4 WITH protect
 SET email_type_cd = 0.0
 IF ((request->secure_email_type=1))
  SELECT INTO "nl:"
   FROM code_value cv
   WHERE cv.code_set=43
    AND cv.cdf_meaning="INTSECEMAIL"
    AND cv.active_ind=1
   DETAIL
    email_type_cd = cv.code_value
   WITH nocounter
  ;end select
 ELSEIF ((request->secure_email_type=2))
  SELECT INTO "nl:"
   FROM code_value cv
   WHERE cv.code_set=43
    AND cv.cdf_meaning="EXTSECEMAIL"
    AND cv.active_ind=1
   DETAIL
    email_type_cd = cv.code_value
   WITH nocounter
  ;end select
 ELSE
  GO TO exit_script
 ENDIF
 SET dcnt = 0
 IF ((request->parent_entity_name="PERSON"))
  SELECT INTO "nl:"
   FROM phone p,
    person pr
   PLAN (p
    WHERE p.parent_entity_name="PERSON"
     AND p.phone_num_key=trim(cnvtupper(cnvtalphanum(request->email_address)))
     AND p.phone_type_cd=email_type_cd
     AND trim(cnvtupper(p.phone_num))=trim(cnvtupper(request->email_address))
     AND p.active_ind=1)
    JOIN (pr
    WHERE pr.person_id=p.parent_entity_id
     AND pr.active_ind=1)
   DETAIL
    dcnt = (dcnt+ 1), stat = alterlist(reply->duplicates,dcnt), reply->duplicates[dcnt].id = pr
    .person_id,
    reply->duplicates[dcnt].name = pr.name_full_formatted
   WITH nocounter
  ;end select
 ELSEIF ((request->parent_entity_name="ORGANIZATION"))
  SELECT INTO "nl:"
   FROM phone p,
    organization o
   PLAN (p
    WHERE p.parent_entity_name="ORGANIZATION"
     AND p.phone_num_key=trim(cnvtupper(cnvtalphanum(request->email_address)))
     AND p.phone_type_cd=email_type_cd
     AND trim(cnvtupper(p.phone_num))=trim(cnvtupper(request->email_address))
     AND p.active_ind=1)
    JOIN (o
    WHERE o.organization_id=p.parent_entity_id
     AND o.active_ind=1)
   DETAIL
    dcnt = (dcnt+ 1), stat = alterlist(reply->duplicates,dcnt), reply->duplicates[dcnt].id = o
    .organization_id,
    reply->duplicates[dcnt].name = o.org_name
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
