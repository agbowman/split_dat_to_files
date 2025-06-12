CREATE PROGRAM bhs_athn_get_ord_priority
 SELECT INTO  $1
  opf.priority_cd, priority = uar_get_code_display(opf.priority_cd), priority_mean =
  uar_get_code_meaning(opf.priority_cd),
  opf.disable_freq_ind, opf.default_start_dt_tm, opf.oe_format_id
  FROM order_priority_flexing opf
  PLAN (opf
   WHERE (opf.oe_format_id= $2)
    AND opf.priority_cd > 0.0
    AND opf.active_ind=1)
  ORDER BY opf.oe_format_id, opf.priority_cd
  HEAD REPORT
   html_tag = build("<?xml version=",'"',"1.0",'"'," encoding=",
    '"',"UTF-8",'"'," ?>"), col 0, html_tag,
   row + 1, col + 1, "<ReplyMessage>",
   row + 1
  HEAD opf.priority_cd
   header_grp = build("<OrderPriority>"), col + 1, header_grp,
   row + 1, v1 = build("<PriorityID>",cnvtint(opf.priority_cd),"</PriorityID>"), col + 1,
   v1, row + 1, v2 = build("<Display>",priority,"</Display>"),
   col + 1, v2, row + 1,
   v3 = build("<Meaning>",priority_mean,"</Meaning>"), col + 1, v3,
   row + 1, v4 = build("<DisableFrequencyIndicator>",opf.disable_freq_ind,
    "</DisableFrequencyIndicator>"), col + 1,
   v4, row + 1, v5 = build("<DefaultStartDateTime>",opf.default_start_dt_tm,"</DefaultStartDateTime>"
    ),
   col + 1, v5, row + 1,
   foot_grp = build("</OrderPriority>"), col + 1, foot_grp,
   row + 1
  FOOT REPORT
   row + 1, col + 1, "</ReplyMessage>",
   row + 1
  WITH maxcol = 32000, maxrow = 0, nocounter,
   nullreport, formfeed = none, format = variable,
   time = 30
 ;end select
END GO
