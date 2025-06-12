CREATE PROGRAM bhs_rpt_mpage_br_audit:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Freetext Description:" = ""
  WITH outdev, s_ft_desc
 SELECT DISTINCT INTO  $OUTDEV
  mpage_name = mp.category_name, component_name = cp.report_name, filter_name = f.filter_display,
  value = v.freetext_desc
  FROM br_datamart_category mp,
   br_datamart_report cp,
   br_datamart_report_filter_r fr,
   br_datamart_filter f,
   br_datamart_value v,
   br_datamart_value v2
  PLAN (mp)
   JOIN (cp
   WHERE cp.br_datamart_category_id=mp.br_datamart_category_id)
   JOIN (fr
   WHERE fr.br_datamart_report_id=cp.br_datamart_report_id)
   JOIN (f
   WHERE f.br_datamart_filter_id=fr.br_datamart_filter_id)
   JOIN (v
   WHERE v.br_datamart_filter_id=f.br_datamart_filter_id
    AND v.freetext_desc=patstring(trim( $S_FT_DESC,3)))
   JOIN (v2
   WHERE (v2.br_datamart_filter_id= Outerjoin(v.br_datamart_filter_id))
    AND v2.parent_entity_id=v.parent_entity_id)
  ORDER BY mpage_name, component_name, filter_name,
   value
  WITH nocounter, heading, maxrow = 1,
   formfeed = none, format, separator = " "
 ;end select
#exit_script
END GO
