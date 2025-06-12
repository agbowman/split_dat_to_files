CREATE PROGRAM da_get_admin_lists:dba
 DECLARE stat = i4 WITH protect
 IF ((request->val2="REPORTING"))
  SET stat = alterlist(reply->datacoll,2)
  SET reply->datacoll[1].description = "Yes"
  SET reply->datacoll[1].currcv = trim(build2(uar_get_code_by_cki("CKI.CODEVALUE!4100899206")),3)
  SET reply->datacoll[2].description = "No"
  SET reply->datacoll[2].currcv = "NULL"
 ELSEIF ((request->val2="REPORTON"))
  SET stat = alterlist(reply->datacoll,2)
  SET reply->datacoll[1].description = "Yes"
  SET reply->datacoll[1].currcv = trim(build2(uar_get_code_by_cki("CKI.CODEVALUE!4100380367")),3)
  SET reply->datacoll[2].description = "No"
  SET reply->datacoll[2].currcv = "NULL"
 ELSE
  SET stat = alterlist(reply->datacoll,0)
 ENDIF
END GO
