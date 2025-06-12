CREATE PROGRAM cvomf_sts3_list_range:dba
 SET reply->status_data.status = "F"
 DECLARE start_range = i4
 DECLARE stop_range = i4
 DECLARE decnum = f8
 IF ((request->val2="DECNUM"))
  SELECT INTO "nl:"
   FROM cv_response cr
   WHERE cr.response_internal_name=concat("STS03_",request->val3)
   DETAIL
    start_range = (10 * cnvtreal(cr.a4)), stop_range = (10 * cnvtreal(cr.a5))
   WITH nocounter
  ;end select
  SET stat = alterlist(reply->datacoll,((stop_range - start_range)+ 1))
  FOR (i = start_range TO stop_range)
    SET decnum = cnvtreal(i)
    SET decnum = (decnum/ 10.0)
    SET reply->datacoll[((i - start_range)+ 1)].currcv = format(decnum,"####.#;L;F")
    SET reply->datacoll[((i - start_range)+ 1)].description = format(decnum,"####.#;L;F")
  ENDFOR
 ELSE
  SELECT INTO "nl:"
   FROM cv_response cr
   WHERE cr.response_internal_name=concat("STS03_",request->val3)
   DETAIL
    start_range = cnvtint(cr.a4), stop_range = cnvtint(cr.a5)
   WITH nocounter
  ;end select
  SET stat = alterlist(reply->datacoll,((stop_range - start_range)+ 1))
  FOR (i = start_range TO stop_range)
   SET reply->datacoll[((i - start_range)+ 1)].currcv = cnvtstring(i)
   SET reply->datacoll[((i - start_range)+ 1)].description = trim(cnvtstring(i),3)
  ENDFOR
 ENDIF
 SET reply->status_data.status = "S"
 SET cvomf_sts3_list_range = "MOD 002 08/05/04 IH6582"
END GO
