CREATE PROGRAM aps_get_omf_case_type_list:dba
 SET v_cv_count = 0
 SELECT INTO "nl:"
  cv.display, cv.code_value
  FROM code_value cv
  WHERE cv.code_set=1301
  ORDER BY cv.display
  DETAIL
   v_cv_count = (v_cv_count+ 1), stat = alterlist(reply->datacoll,v_cv_count), reply->datacoll[
   v_cv_count].description = cv.display,
   reply->datacoll[v_cv_count].currcv = cnvtstring(cv.code_value,32,2)
  WITH nocounter
 ;end select
END GO
