CREATE PROGRAM csm_get_subcat_list:dba
 SET reply->status_data.status = "F"
 SELECT DISTINCT INTO "nl:"
  csm_sub_cat = csc.csm_sub_cat_desc
  FROM csm_sub_categories csc
  WHERE csc.csm_sub_cat_id != 0
  ORDER BY csm_sub_cat
  HEAD REPORT
   v_subcat_count = 0
  DETAIL
   v_subcat_count = (v_subcat_count+ 1), stat = alterlist(reply->datacoll,v_subcat_count), reply->
   datacoll[v_subcat_count].description = csc.csm_sub_cat_desc,
   reply->datacoll[v_subcat_count].currcv = trim(build2(csc.csm_sub_cat_id),3)
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
END GO
