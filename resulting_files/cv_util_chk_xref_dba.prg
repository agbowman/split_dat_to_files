CREATE PROGRAM cv_util_chk_xref:dba
 PROMPT
  "Output:" = mine,
  "Dataset Internal Name:" = "ACC",
  "XREF Internal Name:" = "ACC"
 SET this_dataset = fillstring(100," ")
 SET this_dataset = concat("*",cnvtupper( $2),"*")
 SET this_file = fillstring(100," ")
 SET this_file = concat("*",cnvtupper( $3),"*")
 SET dataset_col = 5
 SET xref_col = (dataset_col+ 5)
 SET resp_col = (xref_col+ 5)
 SELECT INTO  $1
  cdf = substring(1,20,uar_get_code_meaning(x.task_assay_cd)), dta = substring(1,20,
   uar_get_code_display(x.task_assay_cd)), field = substring(1,20,uar_get_code_display(x
    .field_type_cd)),
  event_type = substring(1,10,uar_get_code_display(x.event_type_cd)), event_code = substring(1,20,
   uar_get_code_display(x.event_cd)), data_int_name = substring(1,50,d.dataset_internal_name),
  xref_int_name = substring(1,50,x.xref_internal_name), resp_int_name = substring(1,50,r
   .response_internal_name), nom_id = r.nomenclature_id
  FROM cv_dataset d,
   cv_xref x,
   cv_response r
  PLAN (d
   WHERE cnvtupper(d.dataset_internal_name)=patstring(this_dataset))
   JOIN (x
   WHERE cnvtupper(x.xref_internal_name)=patstring(this_file))
   JOIN (r
   WHERE r.xref_id=x.xref_id)
  ORDER BY d.dataset_id, x.xref_id, r.response_id
  HEAD REPORT
   " CVNet Dataset ", row + 1
  HEAD d.dataset_id
   col dataset_col, "DATASET::", data_int_name,
   row + 1
  HEAD x.xref_id
   col xref_col, xref_int_name, col + 2,
   field, col + 2, event_type,
   col + 2
   IF (trim(cdf) > " ")
    event_code, col + 2, cdf,
    col + 2, dta, col + 2,
    row + 1
   ELSE
    "<No Event Code>", col + 2, row + 1,
    "<No Event Code>", col + 2, row + 1,
    "<No Event Code>", col + 2, row + 1
   ENDIF
  DETAIL
   col resp_col, resp_int_name, col + 5,
   nom_id, col + 5, row + 1
  WITH nocounter, maxcol = 1000
 ;end select
END GO
