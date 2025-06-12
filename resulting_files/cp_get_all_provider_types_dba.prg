CREATE PROGRAM cp_get_all_provider_types:dba
 RECORD reply(
   1 relationship_type_list[*]
     2 reltn_code = f8
     2 reltn_display = c40
     2 reltn_cdf = c12
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count = 0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set IN (333, 331, 22333)
   AND cv.active_ind=1
  ORDER BY cv.display
  HEAD REPORT
   count = 0
  DETAIL
   count = (count+ 1), stat = alterlist(reply->relationship_type_list,count), reply->
   relationship_type_list[count].reltn_code = cv.code_value,
   reply->relationship_type_list[count].reltn_display = cv.display, reply->relationship_type_list[
   count].reltn_cdf = cv.cdf_meaning
  WITH nocounter
 ;end select
 SET size_reltns = 0
 SET size_reltns = size(reply->relationship_type_list,5)
 SET x = 0
 FOR (x = 1 TO size_reltns)
   CALL echo(build("CODE_VALUE = ",reply->relationship_type_list[x].reltn_code))
   CALL echo(build("DISPLAY = ",reply->relationship_type_list[x].reltn_display))
   CALL echo(build("CDF_MEANING = ",reply->relationship_type_list[x].reltn_cdf))
   CALL echo("---------------------------------------")
 ENDFOR
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
