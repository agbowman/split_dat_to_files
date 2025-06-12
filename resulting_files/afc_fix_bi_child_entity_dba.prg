CREATE PROGRAM afc_fix_bi_child_entity:dba
 SET task_cat_cd = 0.0
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=13016
   AND cv.cdf_meaning="TASKCAT"
   AND cv.active_ind=1
  DETAIL
   task_cat_cd = cv.code_value
  WITH nocounter
 ;end select
 SET alpha_response = 0.0
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=13016
   AND cv.cdf_meaning="ALPHA RESP"
   AND cv.active_ind=1
  DETAIL
   alpha_response = cv.code_value
  WITH nocounter
 ;end select
 UPDATE  FROM bill_item b
  SET b.ext_child_entity_name = "ORDER_TASK"
  WHERE b.ext_child_contributor_cd=task_cat_cd
  WITH nocounter
 ;end update
 UPDATE  FROM bill_item b
  SET b.ext_parent_entity_name = "ORDER_TASK"
  WHERE b.ext_parent_contributor_cd=task_cat_cd
  WITH nocounter
 ;end update
 UPDATE  FROM bill_item b
  SET b.ext_child_entity_name = "NOMENCLATURE"
  WHERE b.ext_child_contributor_cd=alpha_response
  WITH nocounter
 ;end update
 COMMIT
END GO
