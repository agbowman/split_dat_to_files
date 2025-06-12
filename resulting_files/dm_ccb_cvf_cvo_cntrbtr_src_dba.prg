CREATE PROGRAM dm_ccb_cvf_cvo_cntrbtr_src:dba
 DECLARE daf_is_blank(dib_str=vc) = i2
 DECLARE daf_is_not_blank(dinb_str=vc) = i2
 SUBROUTINE daf_is_blank(dib_str)
  IF (textlen(trim(dib_str,3)) > 0)
   RETURN(false)
  ENDIF
  RETURN(true)
 END ;Subroutine
 SUBROUTINE daf_is_not_blank(dinb_str)
  IF (textlen(trim(dinb_str,3)) > 0)
   RETURN(true)
  ENDIF
  RETURN(false)
 END ;Subroutine
 IF (validate(reply)=0)
  RECORD reply(
    1 cd_value_list[*]
      2 code_value = f8
      2 display = c40
      2 cdf_meaning = c12
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
    1 message = vc
  )
 ENDIF
 DECLARE cvo_cv_status = c1 WITH protect, noconstant("S")
 DECLARE cvo_cv_errcode = i4 WITH protect, noconstant(0)
 DECLARE cvo_cv_errmsg = vc WITH protect, noconstant(" ")
 DECLARE cvo_cv_filter = vc WITH protect, noconstant(" ")
 IF (daf_is_blank(request->filterlist[1].column_value))
  SET cvo_cv_status = "F"
  SET cvo_cv_errmsg = "No filter values provided for Code Value Outbound - Contributor Source"
  GO TO exit_program
 ENDIF
 IF ((request->code_set=0))
  SET cvo_cv_status = "F"
  SET cvo_cv_errmsg = "No code_set provided for Code Value Outbound - Contributor Source search"
  GO TO exit_program
 ENDIF
 SET cvo_cv_filter = build2(trim(cnvtalphanum(cnvtupper(request->filterlist[1].column_value))),"*")
 SELECT DISTINCT INTO "nl:"
  cv.code_set, cv.code_value, cv.display,
  cv.cdf_meaning
  FROM code_value cs73,
   code_value_outbound cvo,
   code_value cv
  PLAN (cs73
   WHERE cs73.code_set=73
    AND cs73.display_key=patstring(cvo_cv_filter))
   JOIN (cvo
   WHERE (cvo.code_set=request->code_set)
    AND cvo.contributor_source_cd=cs73.code_value)
   JOIN (cv
   WHERE cv.code_value=cvo.code_value
    AND (cv.code_set=request->code_set))
  ORDER BY cv.code_set
  HEAD REPORT
   cv_cnt = 0
  DETAIL
   cv_cnt = (cv_cnt+ 1)
   IF (mod(cv_cnt,10)=1)
    stat = alterlist(reply->cd_value_list,(cv_cnt+ 9))
   ENDIF
   reply->cd_value_list[cv_cnt].code_value = cv.code_value, reply->cd_value_list[cv_cnt].display = cv
   .display, reply->cd_value_list[cv_cnt].cdf_meaning = cv.cdf_meaning
  FOOT REPORT
   stat = alterlist(reply->cd_value_list,cv_cnt)
  WITH nocounter
 ;end select
 SET cvo_cv_errcode = error(cvo_cv_errmsg,1)
 IF (cvo_cv_errcode != 0)
  SET cvo_cv_errmsg = concat("Error searching for Code Value Outbound - Contributor Source:",
   cvo_cv_errmsg)
  SET cvo_cv_status = "F"
  GO TO exit_program
 ELSEIF (size(reply->cd_value_list,5)=0)
  SET cvo_cv_errmsg = concat("No values found for contributor source: ",request->filterlist[1].
   column_value)
  SET cvo_cv_status = "F"
  GO TO exit_program
 ENDIF
#exit_program
 SET reply->status_data.status = cvo_cv_status
 SET reply->message = cvo_cv_errmsg
 CALL echorecord(request)
 CALL echorecord(reply)
END GO
