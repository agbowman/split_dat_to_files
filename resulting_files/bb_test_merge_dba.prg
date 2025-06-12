CREATE PROGRAM bb_test_merge:dba
 SET modify = predeclare
 SELECT
  cve_code_set = cve.code_set, cve_field_name = cve.field_name, cve_code_value = cve.code_value,
  cve_field_value = cve.field_value"###############", code_set_for_field_value = evaluate(nullind(cv
    .code_value),0,build(cv.code_set),"<< NOT FOUND >>"), cve_src_code_value = cve_src.code_value,
  cve_src_field_value = cve_src.field_value"###############", needs_update =
  IF (cve.field_value=cve_src.field_value
   AND cnvtreal(cve.field_value) > 0.0) "YES"
  ELSE "NO"
  ENDIF
  FROM code_value_extension cve,
   code_value cv,
   dm_merge_translate dmt,
   code_value_extension@loc_mrg_link cve_src
  PLAN (cve
   WHERE cve.code_set IN (1612, 1613, 1640, 1643)
    AND cve.field_name IN ("ABORH_cd", "ABOOnly_cd", "RhOnly_cd", "Opposite", "AntigenNeg"))
   JOIN (cv
   WHERE cv.code_value=outerjoin(cnvtreal(cve.field_value)))
   JOIN (dmt
   WHERE dmt.to_value=cve.code_value
    AND dmt.table_name="CODE_VALUE")
   JOIN (cve_src
   WHERE cve_src.code_value=dmt.from_value
    AND cnvtcap(cve_src.field_name)=cnvtcap(cve.field_name)
    AND cve_src.code_set=cve.code_set)
  ORDER BY cve.code_set, cve.field_name, cve.code_value
  WITH counter
 ;end select
END GO
