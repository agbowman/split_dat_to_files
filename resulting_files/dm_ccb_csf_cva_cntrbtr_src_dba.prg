CREATE PROGRAM dm_ccb_csf_cva_cntrbtr_src:dba
 SUBROUTINE (daf_is_blank(dib_str=vc) =i2)
  IF (textlen(trim(dib_str,3)) > 0)
   RETURN(false)
  ENDIF
  RETURN(true)
 END ;Subroutine
 SUBROUTINE (daf_is_not_blank(dinb_str=vc) =i2)
  IF (textlen(trim(dinb_str,3)) > 0)
   RETURN(true)
  ENDIF
  RETURN(false)
 END ;Subroutine
 IF (validate(reply)=0)
  RECORD reply(
    1 code_set_list[*]
      2 code_set = i4
      2 definition = vc
      2 description = vc
      2 display = vc
      2 cs_qual_count = i4
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
 DECLARE cva_cs_status = c1 WITH protect, noconstant("S")
 DECLARE cva_cs_errcode = i4 WITH protect, noconstant(0)
 DECLARE cva_cs_errmsg = vc WITH protect, noconstant(" ")
 DECLARE cva_cv_filter = vc WITH protect, noconstant(" ")
 IF (daf_is_blank(request->filterlist[1].column_value))
  SET cva_cs_status = "F"
  SET cva_cs_errmsg = "No filter values provided for Code Value Alias - Contributor Source"
  GO TO exit_program
 ENDIF
 SET cva_cv_filter = build2(trim(cnvtalphanum(cnvtupper(request->filterlist[1].column_value))),"*")
 SELECT
  IF ((request->code_set > 0))
   PLAN (cv
    WHERE cv.code_set=73
     AND cv.display_key=patstring(cva_cv_filter))
    JOIN (cva
    WHERE (cva.code_set=request->code_set)
     AND cva.contributor_source_cd=cv.code_value)
    JOIN (cvs
    WHERE cvs.code_set=cva.code_set)
    JOIN (cv2
    WHERE cv2.code_value=cva.code_value
     AND (cv2.code_set=request->code_set))
  ELSE
   PLAN (cv
    WHERE cv.code_set=73
     AND cv.display_key=patstring(cva_cv_filter))
    JOIN (cva
    WHERE cva.code_set > 0
     AND cva.contributor_source_cd=cv.code_value)
    JOIN (cvs
    WHERE cvs.code_set=cva.code_set)
    JOIN (cv2
    WHERE cv2.code_value=cva.code_value)
  ENDIF
  INTO "nl:"
  cvs.code_set, cvs.definition, cvs.description,
  cvs.display, cnt = count(DISTINCT cva.code_value)
  FROM code_value cv,
   code_value_alias cva,
   code_value_set cvs,
   code_value cv2
  GROUP BY cvs.code_set, cvs.definition, cvs.description,
   cvs.display
  HEAD REPORT
   cv_cnt = 0
  DETAIL
   cv_cnt += 1
   IF (mod(cv_cnt,10)=1)
    stat = alterlist(reply->code_set_list,(cv_cnt+ 9))
   ENDIF
   reply->code_set_list[cv_cnt].code_set = cvs.code_set, reply->code_set_list[cv_cnt].definition =
   cvs.definition, reply->code_set_list[cv_cnt].description = cvs.description,
   reply->code_set_list[cv_cnt].display = cvs.display, reply->code_set_list[cv_cnt].cs_qual_count =
   cnt
  FOOT REPORT
   stat = alterlist(reply->code_set_list,cv_cnt)
  WITH nocounter
 ;end select
 SET cva_cs_errcode = error(cva_cs_errmsg,1)
 IF (cva_cs_errcode != 0)
  SET cva_cs_errmsg = concat("Error searching for contributor source: ",cva_cs_errmsg)
  SET cva_cs_status = "F"
  GO TO exit_program
 ELSEIF (size(reply->code_set_list,5)=0)
  SET cva_cs_errmsg = concat("No values found for contributor source: ",request->filterlist[1].
   column_value)
  SET cva_cs_status = "F"
  GO TO exit_program
 ENDIF
#exit_program
 SET reply->status_data.status = cva_cs_status
 SET reply->message = cva_cs_errmsg
END GO
