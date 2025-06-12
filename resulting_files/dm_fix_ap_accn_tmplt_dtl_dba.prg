CREATE PROGRAM dm_fix_ap_accn_tmplt_dtl:dba
 SELECT
  a.detail_id
  FROM ap_accn_template_detail a,
   dm_merge_translate d
  WHERE a.detail_id > 0
   AND a.detail_name IN ("SPEC_PRIORITY", "SPECIMEN_CODE", "SPEC_FIXATIVE", "SPEC_ADEQUACY")
   AND  NOT (a.detail_id IN (
  (SELECT
   c.code_value
   FROM code_value c
   WHERE c.code_value=a.detail_id)))
   AND d.table_name="CODE_VALUE"
   AND d.from_value=a.detail_id
  DETAIL
   x = trim(cnvtstring(d.to_value,8,0,r)), y = trim(cnvtstring(a.detail_id,8,0,r)),
   ";FOR DETAIL_NAME=",
   a.detail_name, " ORIGINAL DETAIL_ID=", y,
   row + 1, "UPDATE INTO AP_ACCN_TEMPLATE_DETAIL A", row + 1,
   "  SET A.DETAIL_ID = ", x, row + 1,
   "WHERE A.ROWID = '", a.rowid, "' GO",
   row + 1, "COMMIT GO", row + 2
  WITH counter
 ;end select
END GO
