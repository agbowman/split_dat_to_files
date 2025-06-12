CREATE PROGRAM dm_env_list:dba
 SET reply->status_data.status = "F"
 SET v_cv_count = 0
 SELECT INTO "nl:"
  a.environment_id, a.environment_name
  FROM dm_environment a
  ORDER BY a.environment_id
  DETAIL
   v_cv_count = (v_cv_count+ 1), stat = alterlist(reply->datacoll,v_cv_count), reply->datacoll[
   v_cv_count].description = a.environment_name,
   reply->datacoll[v_cv_count].currcv = cnvtstring(a.environment_id)
  WITH nocounter
 ;end select
 FOR (counter = 1 TO v_cv_count)
  CALL echo(concat("description = ",reply->datacoll[counter].description))
  CALL echo(concat("curcv = ",cnvtstring(reply->datacoll[counter].currcv)))
 ENDFOR
END GO
