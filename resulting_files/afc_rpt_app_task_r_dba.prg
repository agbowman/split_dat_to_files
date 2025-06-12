CREATE PROGRAM afc_rpt_app_task_r:dba
 SET eqline = fillstring(130,"=")
 SET dash130 = fillstring(130,"-")
 SET dash125 = fillstring(125,"-")
 SET dash120 = fillstring(120,"-")
 SET astline = fillstring(130,"*")
 SET showheader = 1
 SET firsttime = 1
 SELECT
  a.application_number, a.owner, a_desc = substring(0,50,a.description),
  a.active_ind, a_text_line1 = substring(0,130,a.text), a_text_line2 = substring(130,130,a.text),
  a.application_ini_ind, a.object_name, a.direct_access_ind,
  t.task_number, t_desc = substring(0,50,t.description), t.active_ind,
  t_text_line1 = substring(0,125,t.text), t_text_line2 = substring(125,125,t.text), t
  .subordinate_task_ind,
  r.request_number, r_description = substring(0,50,r.description), r.request_name,
  r_text_line1 = substring(0,120,r.text), r_text_line2 = substring(120,120,r.text), r.active_ind
  FROM application a,
   application_task_r atr,
   application_task t,
   task_request_r tr,
   request r
  PLAN (a
   WHERE ((a.application_number BETWEEN 951000 AND 951999) OR (a.application_number=5000)) )
   JOIN (atr
   WHERE ((a.application_number != 5000
    AND atr.application_number=a.application_number) OR (a.application_number=5000
    AND atr.application_number=5000
    AND atr.task_number BETWEEN 951000 AND 951999)) )
   JOIN (t
   WHERE t.task_number=atr.task_number)
   JOIN (tr
   WHERE tr.task_number=t.task_number)
   JOIN (r
   WHERE r.request_number=tr.request_number)
  ORDER BY a.application_number, t.task_number, r.request_number
  HEAD a.application_number
   col 01, eqline, row + 1,
   col 01, a.application_number, col 15,
   a_desc, row + 1
  HEAD t.task_number
   col 05, t.task_number, col 20,
   t_desc, row + 1
  DETAIL
   col 10, r.request_number, col 25,
   r_description, row + 1
 ;end select
END GO
