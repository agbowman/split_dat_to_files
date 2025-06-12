CREATE PROGRAM bhs_prax_get_coll_datetime
 SET where_params = build("CP.COLLECTION_PRIORITY_CD =", $2)
 SELECT INTO  $1
  cp.collection_priority_cd, c_collection_priority_disp = uar_get_code_display(cp
   .collection_priority_cd), cp.default_report_priority_cd,
  c_default_report_priority_disp = uar_get_code_display(cp.default_report_priority_cd), cp
  .default_start_dt_tm
  FROM collection_priority cp
  PLAN (cp
   WHERE parser(where_params))
  HEAD REPORT
   html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
    '"',"UTF-8",'"'," ?>"), col 0, html_tag,
   row + 1, col + 1, "<ReplyMessage>",
   row + 1
  HEAD cp.collection_priority_cd
   row + 1, v1 = build("<DefaultDateTime>",cp.default_start_dt_tm,"</DefaultDateTime>"), col + 1,
   v1, row + 1, v2 = build("<DefaultRepPriorityCD>",cp.default_report_priority_cd,
    "</DefaultRepPriorityCD>"),
   col + 1, v2, row + 1,
   v3 = build("<DefaultRepPriorityDisp>",c_default_report_priority_disp,"</DefaultRepPriorityDisp>"),
   col + 1, v3,
   row + 1
  FOOT  cp.collection_priority_cd
   row + 1
  FOOT REPORT
   row + 1, col + 1, "</ReplyMessage>",
   row + 1
  WITH maxcol = 32000, maxrow = 0, nocounter,
   nullreport, formfeed = none, format = variable,
   time = 30
 ;end select
END GO
