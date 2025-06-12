CREATE PROGRAM core_get_cd_values_for_search:dba
 SET modify = predeclare
 FREE RECORD reply
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
 )
 DECLARE script_version = vc WITH public, noconstant(" ")
 DECLARE failed = c1 WITH public, noconstant("F")
 DECLARE startstr = vc WITH public, noconstant(" ")
 SET reply->status_data.status = "F"
 SET request->search_string = cnvtalphanum(cnvtupper(request->search_string))
 SET startstr = concat("cv.display_key = patstring('",request->search_string,"*')")
 SELECT
  IF ((request->search_number > 0.0))
   WHERE (cv.code_value=request->search_number)
    AND (cv.code_set=request->code_set)
  ELSE
   WHERE parser(startstr)
    AND (cv.code_set=request->code_set)
  ENDIF
  INTO "nl:"
  FROM code_value cv
  ORDER BY cv.code_value
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
 IF (curqual <= 0)
  SET failed = "T"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET script_version = "000 04/22/03 JF8275"
END GO
