CREATE PROGRAM cv_utl_chk_dup_xref_disp:dba
 PROMPT
  "Output(Mine:" = mine
 SET disp_col = 20
 SELECT INTO  $1
  FROM cv_xref_field x,
   cv_dataset d
  PLAN (d)
   JOIN (x
   WHERE x.dataset_id=d.dataset_id)
  ORDER BY d.dataset_internal_name, x.display_name
  HEAD REPORT
   cnt = 0, dup_cnt = 0, ds_dup_cnt = 0
  HEAD d.dataset_internal_name
   ds_dup_cnt = 0, "Dataset::", d.dataset_internal_name,
   row + 1
  HEAD x.display_name
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
  FOOT  x.display_name
   IF (cnt > 1)
    dup_cnt = (dup_cnt+ 1), ds_dup_cnt = (ds_dup_cnt+ 1), col disp_col,
    x.display_name, row + 1
   ENDIF
  FOOT  d.dataset_internal_name
   "The number of duplicate display names in the dataset::", ds_dup_cnt, row + 1
  FOOT REPORT
   "The number of duplicate display names::", dup_cnt, row + 1
  WITH nocounter
 ;end select
END GO
