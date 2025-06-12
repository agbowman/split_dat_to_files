CREATE PROGRAM csm_get_cat_list:dba
 SET reply->status_data.status = "F"
 SELECT DISTINCT INTO "nl:"
  csm_cat = cc.csm_cat_desc
  FROM csm_categories cc
  WHERE cc.csm_cat_id != 0
  ORDER BY csm_cat
  HEAD REPORT
   v_cat_count = 0
  DETAIL
   v_cat_count = (v_cat_count+ 1), stat = alterlist(reply->datacoll,v_cat_count), reply->datacoll[
   v_cat_count].description = cc.csm_cat_desc,
   reply->datacoll[v_cat_count].currcv = trim(build2(cc.csm_cat_id),3)
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
END GO
