CREATE PROGRAM bed_get_codes_by_concki:dba
 FREE SET reply
 RECORD reply(
   1 codes[*]
     2 code_value = f8
     2 code_set = i4
     2 cdf_meaning = vc
     2 display = vc
     2 description = vc
     2 concept_cki = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET ccnt = 0
 SET cnt = size(request->codes,5)
 DECLARE c_string = vc
 IF ((request->code_set > 0))
  SET c_string = build("c.code_set = ",request->code_set)
 ELSE
  SET c_string = concat("c.code_set > 0")
 ENDIF
 IF (cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(cnt)),
    code_value c
   PLAN (d)
    JOIN (c
    WHERE parser(c_string)
     AND (c.concept_cki=request->codes[d.seq].concept_cki))
   ORDER BY c.code_set, c.display
   DETAIL
    ccnt = (ccnt+ 1), stat = alterlist(reply->codes,ccnt), reply->codes[ccnt].code_value = c
    .code_value,
    reply->codes[ccnt].code_set = c.code_set, reply->codes[ccnt].cdf_meaning = c.cdf_meaning, reply->
    codes[ccnt].display = c.display,
    reply->codes[ccnt].description = c.description, reply->codes[ccnt].concept_cki = c.concept_cki
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
