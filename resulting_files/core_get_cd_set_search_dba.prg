CREATE PROGRAM core_get_cd_set_search:dba
 SET modify = predeclare
 IF (validate(reply)=0)
  FREE RECORD reply
  RECORD reply(
    1 starts_with_list[*]
      2 code_set = i4
      2 definition = vc
      2 description = vc
      2 display = c40
      2 cs_qual_count = i4
    1 contains_list[*]
      2 code_set = i4
      2 definition = vc
      2 description = vc
      2 display = c40
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE script_version = vc WITH public, noconstant(" ")
 DECLARE failed = c1 WITH public, noconstant("F")
 DECLARE startstr = vc WITH public, noconstant(" ")
 DECLARE containstr = vc WITH public, noconstant(" ")
 DECLARE st_cnt = i4 WITH public, noconstant(0)
 DECLARE cont_cnt = i4 WITH public, noconstant(0)
 SET reply->status_data.status = "F"
 IF ((((request->search_string > " ")
  AND (request->search_number > 0.0)) OR ( NOT ((request->search_string > " "))
  AND (request->search_number <= 0.0))) )
  SET failed = "T"
  CALL echo(concat("Only one of the variables search_string and search_number ",
    "can be used at a time."))
  GO TO exit_script
 ENDIF
 SET request->search_string = cnvtalphanum(cnvtupper(request->search_string))
 IF ((request->search_type_flag=0))
  SET startstr = concat("cvs.display_key = patstring('",request->search_string,"*')")
  CALL echo(build("The value of startstr:",startstr))
  SELECT
   IF ((request->search_number > 0.0))
    PLAN (cvs
     WHERE cvs.code_set > 0)
   ELSE
    PLAN (cvs
     WHERE parser(startstr)
      AND cvs.code_set > 0)
   ENDIF
   INTO "nl:"
   cvs.code_set, cvs.definition, cvs.description,
   cvs.display, cvs.display_key
   FROM code_value_set cvs
   ORDER BY cvs.code_set
   HEAD REPORT
    st_cnt = 0
   DETAIL
    st_cnt = (st_cnt+ 1)
    IF (mod(st_cnt,10)=1)
     stat = alterlist(reply->starts_with_list,(st_cnt+ 9))
    ENDIF
    reply->starts_with_list[st_cnt].code_set = cvs.code_set, reply->starts_with_list[st_cnt].
    definition = cvs.definition, reply->starts_with_list[st_cnt].description = cvs.description,
    reply->starts_with_list[st_cnt].display = cvs.display
   FOOT REPORT
    stat = alterlist(reply->starts_with_list,st_cnt)
   WITH nocounter
  ;end select
  SET containstr = concat("cvs.display_key = patstring('*",request->search_string,"*')",
   " and cvs.display_key != patstring('",request->search_string,
   "*')")
  CALL echo(build("The value of containstr:",containstr))
  IF ((request->search_string > " "))
   SELECT INTO "nl:"
    cvs.code_set, cvs.definition, cvs.description,
    cvs.display, cvs.display_key
    FROM code_value_set cvs
    PLAN (cvs
     WHERE parser(containstr)
      AND cvs.code_set > 0)
    ORDER BY cvs.code_set
    HEAD REPORT
     cont_cnt = 0
    DETAIL
     cont_cnt = (cont_cnt+ 1)
     IF (mod(cont_cnt,10)=1)
      stat = alterlist(reply->contains_list,(cont_cnt+ 9))
     ENDIF
     reply->contains_list[cont_cnt].code_set = cvs.code_set, reply->contains_list[cont_cnt].
     definition = cvs.definition, reply->contains_list[cont_cnt].description = cvs.description,
     reply->contains_list[cont_cnt].display = cvs.display
    FOOT REPORT
     stat = alterlist(reply->contains_list,cont_cnt)
    WITH nocounter
   ;end select
  ENDIF
 ELSEIF ((request->search_type_flag=1))
  SET startstr = concat("cv.display_key = patstring('",request->search_string,"*')")
  SELECT
   IF ((request->search_number > 0.0))
    PLAN (cv
     WHERE (cv.code_value=request->search_number))
     JOIN (cvs
     WHERE cvs.code_set=cv.code_set
      AND cvs.code_set > 0)
   ELSE
    PLAN (cv
     WHERE parser(startstr))
     JOIN (cvs
     WHERE cvs.code_set=cv.code_set
      AND cvs.code_set > 0)
   ENDIF
   INTO "nl:"
   cvs.code_set, cvs.display, cvs.definition,
   cvs.description, cs_qual_cnt = count(*)
   FROM code_value cv,
    code_value_set cvs
   GROUP BY cvs.code_set, cvs.display, cvs.definition,
    cvs.description
   ORDER BY cvs.code_set
   HEAD REPORT
    st_cnt = 0
   DETAIL
    st_cnt = (st_cnt+ 1)
    IF (mod(st_cnt,10)=1)
     stat = alterlist(reply->starts_with_list,(st_cnt+ 9))
    ENDIF
    reply->starts_with_list[st_cnt].code_set = cvs.code_set, reply->starts_with_list[st_cnt].
    definition = cvs.definition, reply->starts_with_list[st_cnt].description = cvs.description,
    reply->starts_with_list[st_cnt].display = cvs.display, reply->starts_with_list[st_cnt].
    cs_qual_count = cs_qual_cnt
   FOOT REPORT
    stat = alterlist(reply->starts_with_list,st_cnt)
   WITH nocounter
  ;end select
 ELSE
  SET failed = "T"
  CALL echo(build("Invalid search_type_flag:",request->search_type_flag))
  GO TO exit_script
 ENDIF
#exit_script
 IF (st_cnt=0
  AND cont_cnt=0)
  SET failed = "T"
 ENDIF
 IF (failed="T")
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET script_version = "000 02/26/03 JF8275"
END GO
