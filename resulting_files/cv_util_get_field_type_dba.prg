CREATE PROGRAM cv_util_get_field_type:dba
 PROMPT
  "Output(Mine):" = mine,
  "Dataset" = "STS"
 SET dataset_param = concat("*", $2,"*")
 SELECT INTO  $1
  x.xref_internal_name, ",", uar_get_code_meaning(x.field_type_cd)
  FROM cv_xref x
  PLAN (x
   WHERE x.xref_internal_name=patstring(dataset_param))
  WITH nocounter
 ;end select
END GO
