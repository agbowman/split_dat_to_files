CREATE PROGRAM dm_fix_chart_sect_ui:dba
 SELECT
  *
  FROM chart_format a,
   chart_form_sects b,
   chart_section c
  WHERE a.chart_format_id=b.chart_format_id
   AND b.chart_section_id=c.chart_section_id
  DETAIL
   x = build('"',a.chart_format_desc,c.chart_section_id,'"'),
   "UPDATE INTO CHART_SECTION SET UNIQUE_IDENT = ", row + 1,
   x, row + 1, "WHERE ROWID = '",
   c.rowid, "' GO", row + 1,
   "commit go", row + 2
 ;end select
END GO
