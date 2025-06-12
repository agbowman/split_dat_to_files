CREATE PROGRAM bhs_athn_get_surg_proc
 SELECT INTO  $1
  procedure =
  IF (trim(sc.modifier,3)="") trim(replace(replace(replace(replace(replace(uar_get_code_display(sc
          .surg_proc_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3
    )
  ELSE concat(trim(replace(replace(replace(replace(replace(uar_get_code_display(sc.surg_proc_cd),"&",
          "&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"(",trim(sc
     .modifier,3),")")
  ENDIF
  , surgeon = trim(replace(replace(replace(replace(replace(p.name_full_formatted,"&","&amp;",0),"<",
       "&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), surg_date = format(s
   .sched_start_dt_tm,"MM/DD/YYYY HH:MM;;d"),
  case_nbr = trim(replace(replace(replace(replace(replace(s.surg_case_nbr_formatted,"&","&amp;",0),
       "<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), anesthesia_type =
  IF (s.anesth_type_cd=0.00) "General"
  ELSE trim(replace(replace(replace(replace(replace(uar_get_code_display(s.anesth_type_cd),"&",
         "&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3)
  ENDIF
  , s.surg_case_id,
  sc.surg_case_proc_id
  FROM surgical_case s,
   surg_case_procedure sc,
   prsnl p
  PLAN (s
   WHERE s.person_id=cnvtint( $2)
    AND s.active_ind=1
    AND s.surg_start_dt_tm IS NOT null
    AND s.surg_area_cd > 0.00
    AND s.pat_type_cd > 0.00)
   JOIN (sc
   WHERE s.surg_case_id=sc.surg_case_id
    AND sc.active_ind=1
    AND sc.surg_proc_cd > 0.00
    AND sc.proc_complete_qty > 0)
   JOIN (p
   WHERE p.person_id=sc.primary_surgeon_id
    AND p.active_ind=1)
  ORDER BY s.sched_start_dt_tm DESC
  HEAD REPORT
   html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
    '"',"UTF-8",'"'," ?>"), col 0, html_tag,
   row + 1, col + 1, "<ReplyMessage>",
   row + 1
  DETAIL
   v4 = build("<","SurgProc",">"), col + 1, v4,
   row + 1, v1 = build("<Procedure>",procedure,"</Procedure>"), col + 1,
   v1, row + 1, v2 = build("<Surgeon>",surgeon,"</Surgeon>"),
   col + 1, v2, row + 1,
   v3 = build("<SurgerDate>",surg_date,"</SurgerDate>"), col + 1, v3,
   row + 1, v6 = build("<CaseNumber>",case_nbr,"</CaseNumber>"), col + 1,
   v6, row + 1, v7 = build("<AnesthType>",anesthesia_type,"</AnesthType>"),
   col + 1, v7, row + 1,
   v8 = build("<SurgicalCaseId>",s.surg_case_id,"</SurgicalCaseId>"), col + 1, v8,
   row + 1, v9 = build("<SurgicalProcId>",sc.surg_case_proc_id,"</SurgicalProcId>"), col + 1,
   v9, row + 1, v5 = build("</","SurgProc",">"),
   col + 1, v5, row + 1
  FOOT REPORT
   row + 1, col + 1, "</ReplyMessage>",
   row + 1
  WITH maxcol = 32000, maxrow = 0, nocounter,
   nullreport, formfeed = none, format = variable,
   time = 30
 ;end select
END GO
