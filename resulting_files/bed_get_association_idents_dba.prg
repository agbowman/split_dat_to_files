CREATE PROGRAM bed_get_association_idents:dba
 FREE SET reply
 RECORD reply(
   1 assoc_idents[*]
     2 code_value = f8
     2 display = vc
     2 description = vc
     2 definition = vc
     2 mean = vc
     2 nomenclature_id = f8
     2 nomenclature = vc
     2 active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET acnt = 0
 SELECT INTO "nl:"
  FROM code_value cv,
   code_value_extension cve
  PLAN (cv
   WHERE cv.code_set=6999)
   JOIN (cve
   WHERE cve.code_value=outerjoin(cv.code_value)
    AND cve.code_set=outerjoin(6999)
    AND cve.field_name=outerjoin("REPEATABLE_GROUP_NOMENCLATURE_ID"))
  ORDER BY cv.display
  DETAIL
   acnt = (acnt+ 1), stat = alterlist(reply->assoc_idents,acnt), reply->assoc_idents[acnt].code_value
    = cv.code_value,
   reply->assoc_idents[acnt].display = cv.display, reply->assoc_idents[acnt].description = cv
   .description, reply->assoc_idents[acnt].definition = cv.definition,
   reply->assoc_idents[acnt].mean = cv.cdf_meaning
   IF (cve.field_value > " "
    AND isnumeric(cve.field_value) > 0)
    reply->assoc_idents[acnt].nomenclature_id = cnvtreal(cve.field_value)
   ELSE
    reply->assoc_idents[acnt].nomenclature_id = 0
   ENDIF
   reply->assoc_idents[acnt].active_ind = cv.active_ind
  WITH nocounter
 ;end select
 IF (acnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = acnt),
    nomenclature n
   PLAN (d
    WHERE (reply->assoc_idents[d.seq].nomenclature_id > 0))
    JOIN (n
    WHERE (n.nomenclature_id=reply->assoc_idents[d.seq].nomenclature_id))
   DETAIL
    reply->assoc_idents[d.seq].nomenclature = n.source_string
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
