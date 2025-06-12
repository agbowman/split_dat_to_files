CREATE PROGRAM dm_refresh_check:dba
 SET cvs_ind = 0
 SET cdf_ind = 0
 SET cv_ind = 0
 SET cse_ind = 0
 SET cve_ind = 0
 SET cva_ind = 0
 FREE SET r1
 RECORD r1(
   1 rdate = dq8
 )
 SET r1->rdate = 0
 SET y = 0
 SET z = 0
 SELECT DISTINCT INTO "nl:"
  a.schema_date
  FROM dm_code_value_set a
  DETAIL
   IF ((a.schema_date > r1->rdate))
    r1->rdate = a.schema_date
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  x = count(*)
  FROM code_value_set
  WHERE code_set > 0
  DETAIL
   y = x
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  x = count(*)
  FROM dm_code_value_set c
  WHERE c.code_set > 0
   AND datetimediff(c.schema_date,cnvtdatetime(r1->rdate))=0
  GROUP BY c.schema_date
  DETAIL
   z = x
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  *
  FROM dual
  DETAIL
   IF (y >= z)
    cvs_ind = 1
   ELSE
    cvs_ind = 0
   ENDIF
  WITH nocounter
 ;end select
 SET y = 0
 SET z = 0
 SELECT INTO "nl:"
  x = count(*)
  FROM code_set_extension
  WHERE code_set > 0
  DETAIL
   y = x
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  x = count(*)
  FROM dm_code_set_extension c
  WHERE c.code_set > 0
   AND datetimediff(c.schema_date,cnvtdatetime(r1->rdate))=0
   AND c.field_type != 0
  GROUP BY c.schema_date
  DETAIL
   z = x
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  *
  FROM dual
  DETAIL
   IF (y >= z)
    cse_ind = 1
   ELSE
    cse_ind = 0
   ENDIF
  WITH nocounter
 ;end select
 SET y = 0
 SET z = 0
 SELECT INTO "nl:"
  x = count(*)
  FROM common_data_foundation
  WHERE code_set > 0
  DETAIL
   y = x
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  x = count(*)
  FROM dm_common_data_foundation c
  WHERE c.code_set > 0
   AND datetimediff(c.schema_date,cnvtdatetime(r1->rdate))=0
  GROUP BY c.schema_date
  DETAIL
   z = x
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  *
  FROM dual
  DETAIL
   IF (y >= z)
    cdf_ind = 1
   ELSE
    cdf_ind = 0
   ENDIF
  WITH nocounter
 ;end select
 SET y = 0
 SET z = 0
 SELECT INTO "nl:"
  x = count(*)
  FROM code_value
  WHERE code_set > 0
  DETAIL
   y = x
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  x = count(*)
  FROM dm_code_value c
  WHERE c.code_set > 0
   AND datetimediff(c.schema_date,cnvtdatetime(r1->rdate))=0
  GROUP BY c.schema_date
  DETAIL
   z = x
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  *
  FROM dual
  DETAIL
   IF (y >= z)
    cv_ind = 1
   ELSE
    cv_ind = 0
   ENDIF
  WITH nocounter
 ;end select
 SET y = 0
 SET z = 0
 SELECT INTO "nl:"
  x = count(*)
  FROM code_value_alias
  WHERE code_set > 0
  DETAIL
   y = x
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  x = count(*)
  FROM dm_code_value_alias c
  WHERE c.code_set > 0
   AND datetimediff(c.schema_date,cnvtdatetime(r1->rdate))=0
  GROUP BY c.schema_date
  DETAIL
   z = x
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  *
  FROM dual
  DETAIL
   IF (y >= z)
    cva_ind = 1
   ELSE
    cva_ind = 0
   ENDIF
  WITH nocounter
 ;end select
 SET y = 0
 SET z = 0
 SELECT INTO "nl:"
  x = count(*)
  FROM code_value_extension
  WHERE code_set > 0
  DETAIL
   y = x
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  x = count(*)
  FROM dm_code_value_extension c
  WHERE c.code_set > 0
   AND datetimediff(c.schema_date,cnvtdatetime(r1->rdate))=0
  GROUP BY c.schema_date
  DETAIL
   z = x
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  *
  FROM dual
  DETAIL
   IF (y >= z)
    cve_ind = 1
   ELSE
    cve_ind = 0
   ENDIF
  WITH nocounter
 ;end select
 IF (cvs_ind=1
  AND cv_ind=1
  AND cdf_ind=1
  AND cse_ind=1
  AND cva_ind=1
  AND cve_ind=1)
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg = "All Code sets refreshed"
  SET request->setup_proc[1].process_id = 609
 ELSE
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = "Refresh Failed"
  SET request->setup_proc[1].process_id = 609
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO
