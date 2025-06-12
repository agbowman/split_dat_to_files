CREATE PROGRAM bhs_prax_reason_for_exam
 SET file_name = request->output_device
 SET catalog_cd_param = request->person[1].person_id
 SELECT INTO value(file_name)
  c.exam_reason_id, exam_reason_desc = trim(replace(replace(replace(replace(replace(c.description,"&",
        "&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3)
  FROM exam_reason e,
   coded_exam_reason c
  PLAN (e
   WHERE e.catalog_cd=catalog_cd_param)
   JOIN (c
   WHERE c.exam_reason_id=e.exam_reason_id
    AND c.active_ind=1)
  HEAD REPORT
   html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
    '"',"UTF-8",'"'," ?>"), col 0, html_tag,
   row + 1, col + 1, "<ReplyMessage>",
   row + 1
  DETAIL
   col 1, "<DCPRadiologyExamReason>", row + 1,
   r_id = build("<ExamReasonId>",cnvtint(c.exam_reason_id),"</ExamReasonId>"), col + 1, r_id,
   row + 1, r_desc = build("<ExamReasonDesc>",exam_reason_desc,"</ExamReasonDesc>"), col + 1,
   r_desc, row + 1, col 1,
   "</DCPRadiologyExamReason>", row + 1
  FOOT REPORT
   col + 1, "</ReplyMessage>", row + 1
  WITH nocounter, nullreport, formfeed = none,
   maxcol = 1000, format = variable, maxrow = 0,
   time = 30
 ;end select
END GO
