CREATE PROGRAM dcp_get_cs_with_ext_opt:dba
 SET modify = predeclare
 RECORD reply(
   1 codeset[*]
     2 code_value = f8
     2 display = c40
     2 cdf_meaning = c12
     2 alias_type_code_sets = c100
     2 parent_entity_name = c100
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE icnt = i4 WITH protect, noconstant(0)
 DECLARE last_mod = c3 WITH private, noconstant("")
 DECLARE mod_date = c10 WITH private, noconstant("")
 SET reply->status_data.status = "F"
 IF ((request->ext_flag=1))
  SELECT INTO "nl:"
   cv.code_value, cv.display, cv.cdf_meaning,
   cve.field_value, cve2.field_value
   FROM code_value_extension cve,
    code_value_extension cve2,
    code_value cv
   PLAN (cv
    WHERE (cv.code_set=request->code_set)
     AND cv.active_ind=1)
    JOIN (cve
    WHERE cve.code_value=outerjoin(cv.code_value)
     AND cve.field_name=outerjoin("ALIAS_TYPE_CODESET"))
    JOIN (cve2
    WHERE cve2.code_value=outerjoin(cv.code_value)
     AND cve2.field_name=outerjoin("PARENT_ENTITY_NAME"))
   ORDER BY cv.display
   HEAD REPORT
    icnt = 0
   DETAIL
    icnt = (icnt+ 1)
    IF (icnt > size(reply->codeset,5))
     stat = alterlist(reply->codeset,(icnt+ 10))
    ENDIF
    reply->codeset[icnt].code_value = cv.code_value, reply->codeset[icnt].display = cv.display, reply
    ->codeset[icnt].cdf_meaning = cv.cdf_meaning,
    reply->codeset[icnt].alias_type_code_sets = trim(cve.field_value), reply->codeset[icnt].
    parent_entity_name = trim(cve2.field_value)
   FOOT REPORT
    stat = alterlist(reply->codeset,icnt)
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   cv.code_value, cv.display, cv.cdf_meaning
   FROM code_value cv
   WHERE (cv.code_set=request->code_set)
    AND cv.active_ind=1
   ORDER BY cv.display
   HEAD REPORT
    icnt = 0
   DETAIL
    icnt = (icnt+ 1)
    IF (icnt > size(reply->codeset,5))
     stat = alterlist(reply->codeset,(icnt+ 10))
    ENDIF
    reply->codeset[icnt].code_value = cv.code_value, reply->codeset[icnt].display = cv.display, reply
    ->codeset[icnt].cdf_meaning = cv.cdf_meaning
   FOOT REPORT
    stat = alterlist(reply->codeset,icnt)
   WITH nocounter
  ;end select
 ENDIF
 IF (icnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET last_mod = "001"
 SET mod_date = "10/26/2006"
 SET modify = nopredeclare
END GO
