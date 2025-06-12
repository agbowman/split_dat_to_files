CREATE PROGRAM bhs_prax_get_list_type_oe_val
 SELECT DISTINCT INTO  $1
  code = nom.nomenclature_id, display = trim(replace(replace(replace(replace(replace(nom.mnemonic,"&",
        "&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), display_key = trim
  (replace(replace(replace(replace(replace(nom.source_string_keycap,"&","&amp;",0),"<","&lt;",0),">",
      "&gt;",0),"'","&apos;",0),'"',"&quot;",0),3)
  FROM order_catalog oc,
   order_catalog_synonym ocs,
   order_entry_format oef1,
   oe_format_fields oef2,
   order_entry_fields oef3,
   discrete_task_assay d,
   reference_range_factor r,
   alpha_responses a,
   nomenclature nom
  PLAN (oc
   WHERE oc.catalog_type_cd=cnvtint( $2))
   JOIN (ocs
   WHERE ocs.catalog_cd=oc.catalog_cd
    AND ocs.mnemonic_type_cd=2583
    AND ocs.active_ind=1)
   JOIN (oef1
   WHERE oef1.oe_format_id=ocs.oe_format_id
    AND oef1.action_type_cd=2534)
   JOIN (oef2
   WHERE oef2.oe_format_id=oef1.oe_format_id
    AND oef2.oe_field_id=cnvtint( $3))
   JOIN (oef3
   WHERE oef3.oe_field_id=oef2.oe_field_id
    AND oef3.prompt_entity_name="DISCRETE_TASK_ASSAY")
   JOIN (d
   WHERE d.task_assay_cd=oef3.prompt_entity_id)
   JOIN (r
   WHERE r.task_assay_cd=d.task_assay_cd)
   JOIN (a
   WHERE a.reference_range_factor_id=r.reference_range_factor_id)
   JOIN (nom
   WHERE nom.nomenclature_id=a.nomenclature_id)
  ORDER BY display
  HEAD REPORT
   html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
    '"',"UTF-8",'"'," ?>"), col 0, html_tag,
   row + 1, col + 1, "<ReplyMessage>",
   row + 1
  DETAIL
   v4 = build("<","Code",">"), col + 1, v4,
   row + 1, v1 = build("<CodeValue>",code,"</CodeValue>"), col + 1,
   v1, row + 1, v2 = build("<Display>",display,"</Display>"),
   col + 1, v2, row + 1,
   v3 = build("<DisplayKey>",display_key,"</DisplayKey>"), col + 1, v3,
   row + 1, v5 = build("</","Code",">"), col + 1,
   v5, row + 1
  FOOT REPORT
   row + 1, col + 1, "</ReplyMessage>",
   row + 1
  WITH maxcol = 32000, maxrow = 0, nocounter,
   nullreport, formfeed = none, format = variable,
   time = 30
 ;end select
END GO
