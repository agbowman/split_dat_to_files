CREATE PROGRAM dm_fix_oe_format_default:dba
 SELECT
  a.oe_field_id, a.codeset, a.field_type_flag,
  b.default_value, b.oe_format_id
  FROM order_entry_fields a,
   oe_format_fields b,
   dm_merge_translate d
  WHERE a.codeset > 0
   AND a.oe_field_id=b.oe_field_id
   AND b.default_value > " "
   AND  NOT (b.default_value IN ("STAT", "~ORDERINGLOCATION"))
   AND  NOT (cnvtint(b.default_value) IN (
  (SELECT
   c.code_value
   FROM code_value c
   WHERE c.code_set=a.codeset)))
   AND d.table_name="CODE_VALUE"
   AND d.from_value=cnvtint(b.default_value)
  DETAIL
   x = trim(cnvtstring(d.to_value,8,0,r)), ";CODE_SET=", a.codeset,
   row + 1, ";FOR DEFAULT=", b.default_value,
   row + 1, "UPDATE INTO OE_FORMAT_FIELDS A", row + 1,
   "  SET A.DEFAULT_VALUE = '", x, "'",
   row + 1, "WHERE A.ROWID = '", b.rowid,
   "' GO", row + 1, "COMMIT GO",
   row + 2
  WITH counter
 ;end select
 SELECT
  a.oe_field_id, a.codeset, a.field_type_flag,
  b.default_value, b.oe_format_id
  FROM order_entry_fields a,
   accept_format_flexing b,
   dm_merge_translate d
  WHERE a.codeset > 0
   AND a.oe_field_id=b.oe_field_id
   AND b.default_value > " "
   AND  NOT (b.default_value IN ("STAT", "~ORDERINGLOCATION"))
   AND  NOT (cnvtint(b.default_value) IN (
  (SELECT
   c.code_value
   FROM code_value c
   WHERE c.code_set=a.codeset)))
   AND d.table_name="CODE_VALUE"
   AND d.from_value=cnvtint(b.default_value)
  DETAIL
   x = trim(cnvtstring(d.to_value,8,0,r)), ";CODE_SET=", a.codeset,
   row + 1, ";FOR DEFAULT=", b.default_value,
   row + 1, "UPDATE INTO accept_FORMAT_flexing A", row + 1,
   "  SET A.DEFAULT_VALUE = '", x, "'",
   row + 1, "WHERE A.ROWID = '", b.rowid,
   "' GO", row + 1, "COMMIT GO",
   row + 2
  WITH counter
 ;end select
END GO
