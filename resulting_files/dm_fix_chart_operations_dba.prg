CREATE PROGRAM dm_fix_chart_operations:dba
 SELECT
  a.param_type_flag, a.param
  FROM charting_operations a,
   dm_merge_translate d
  WHERE a.param_type_flag=2
   AND a.param > " "
   AND  NOT (cnvtint(a.param) IN (
  (SELECT
   c.distribution_id
   FROM chart_distribution c)))
   AND d.table_name="CHART_DISTRIBUTION"
   AND d.from_value=cnvtint(a.param)
  DETAIL
   x = trim(cnvtstring(d.to_value,8,0,r)), ";CHARTING_OPERATIONS_ID=", a.charting_operations_id,
   row + 1, ";FOR PARAM=", a.param,
   row + 1, "UPDATE INTO CHARTING_OPERATIONS A", row + 1,
   "  SET A.PARAM = '", x, "'",
   row + 1, "WHERE A.ROWID = '", a.rowid,
   "' GO", row + 1, "COMMIT GO",
   row + 2
  WITH counter
 ;end select
END GO
