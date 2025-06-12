CREATE PROGRAM ce_get_code_value_by_meaning:dba
 IF (validate(reply,"-999")="-999")
  FREE RECORD reply
  RECORD reply(
    1 qual = i4
    1 error_code = f8
    1 error_msg = vc
    1 reply_list[*]
      2 code_value = f8
  )
 ENDIF
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE error_msg = vc WITH protect, noconstant("")
 SET error_code = 0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.cdf_meaning=trim(request->cdf_meaning)
   AND (cv.code_set=request->code_set)
   AND cv.active_ind=1
  DETAIL
   cnt += 1
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->reply_list,(cnt+ 9))
   ENDIF
   reply->reply_list[cnt].code_value = cv.code_value
  WITH nocounter
 ;end select
 SET reply->qual = cnt
 SET error_code = error(error_msg,0)
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
 SET stat = alterlist(reply->reply_list,cnt)
END GO
