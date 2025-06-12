CREATE PROGRAM bbd_rpt_pref_audit:dba
 RECORD question(
   1 text_lns[*]
     2 text_ln = c100
 )
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF (validate(i18nuar_def,999)=999)
  CALL echo("Declaring i18nuar_def")
  DECLARE i18nuar_def = i2 WITH persist
  SET i18nuar_def = 1
  DECLARE uar_i18nlocalizationinit(p1=i4,p2=vc,p3=vc,p4=f8) = i4 WITH persist
  DECLARE uar_i18ngetmessage(p1=i4,p2=vc,p3=vc) = vc WITH persist
  DECLARE uar_i18nbuildmessage() = vc WITH persist
  DECLARE uar_i18ngethijridate(imonth=i2(val),iday=i2(val),iyear=i2(val),sdateformattype=vc(ref)) =
  c50 WITH image_axp = "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar =
  "uar_i18nGetHijriDate",
  persist
  DECLARE uar_i18nbuildfullformatname(sfirst=vc(ref),slast=vc(ref),smiddle=vc(ref),sdegree=vc(ref),
   stitle=vc(ref),
   sprefix=vc(ref),ssuffix=vc(ref),sinitials=vc(ref),soriginal=vc(ref)) = c250 WITH image_axp =
  "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar = "i18nBuildFullFormatName",
  persist
  DECLARE uar_i18ngetarabictime(ctime=vc(ref)) = c20 WITH image_axp = "shri18nuar", image_aix =
  "libi18n_locale.a(libi18n_locale.o)", uar = "i18n_GetArabicTime",
  persist
 ENDIF
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 RECORD captions(
   1 rpt_as_of_date = vc
   1 db_audit = vc
   1 rpt_page = vc
   1 rpt_time = vc
   1 db_prefs_tool = vc
   1 bbd_prefs = vc
   1 process = vc
   1 question = vc
   1 answer = vc
   1 yes = vc
   1 no = vc
   1 end_of_report = vc
 )
 SET captions->rpt_as_of_date = uar_i18ngetmessage(i18nhandle,"rpt_as_of_date","As of Date:")
 SET captions->db_audit = uar_i18ngetmessage(i18nhandle,"db_audit","DATABASE AUDIT")
 SET captions->rpt_page = uar_i18ngetmessage(i18nhandle,"rpt_page","PAGE NO:")
 SET captions->rpt_time = uar_i18ngetmessage(i18nhandle,"rpt_time","TIME: ")
 SET captions->db_prefs_tool = uar_i18ngetmessage(i18nhandle,"db_prefs_tool","DB PREFERENCE TOOL")
 SET captions->bbd_prefs = uar_i18ngetmessage(i18nhandle,"bbd_prefs","BLOOD BANK DONOR PREFERENCES")
 SET captions->process = uar_i18ngetmessage(i18nhandle,"process","PROCESS: ")
 SET captions->question = uar_i18ngetmessage(i18nhandle,"question","QUESTION")
 SET captions->answer = uar_i18ngetmessage(i18nhandle,"answer","ANSWER")
 SET captions->yes = uar_i18ngetmessage(i18nhandle,"yes","YES")
 SET captions->no = uar_i18ngetmessage(i18nhandle,"no","NO")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report",
  "* * * E N D   O F   R E P O R T * * *")
 SELECT INTO "cer_temp:bbd_pref_audit.txt"
  c1660.code_value, c1660.cdf_meaning, c1662.code_value,
  c1662.display, c1659.code_value, c1659.display"##########",
  rsp = d_rsp.seq, q.module_cd, q.process_cd,
  q.question_cd, q.question, a.question_cd,
  a.answer"#############", cv.display"#############"
  FROM code_value c1660,
   code_value c1662,
   code_value c1659,
   (dummyt d_rsp  WITH seq = 1),
   code_value cv,
   question q,
   (dummyt d_ans  WITH seq = 1),
   answer a
  PLAN (c1660
   WHERE c1660.cdf_meaning="BB DONOR")
   JOIN (q
   WHERE c1660.code_value=q.module_cd
    AND q.active_ind=1)
   JOIN (c1662
   WHERE q.process_cd=c1662.code_value
    AND c1662.active_ind=1)
   JOIN (d_ans
   WHERE d_ans.seq=1)
   JOIN (a
   WHERE q.question_cd=a.question_cd
    AND a.active_ind=1)
   JOIN (d_rsp
   WHERE d_rsp.seq=1)
   JOIN (((c1659
   WHERE q.response_flag=1
    AND cnvtint(a.answer)=c1659.code_value)
   ) ORJOIN ((cv
   WHERE q.response_flag=0
    AND cnvtint(a.answer)=cv.code_value)
   ))
  ORDER BY c1662.display
  HEAD REPORT
   ln_cnt = 0, beg_char = 0, tot_char_cnt = 0,
   len_text_ln = 100, len_get_text = 0, ln = 0
  HEAD PAGE
   col 1, captions->rpt_as_of_date, col 14,
   curdate"@DATECONDENSED;;DATE",
   CALL center(captions->db_audit,1,125), col 108,
   captions->rpt_page, col 120, curpage"##",
   row + 1, col 7, captions->rpt_time,
   col 14, curtime"@TIMENOSECONDS;;MTIME",
   CALL center(captions->db_prefs_tool,1,125),
   row + 1,
   CALL center(captions->bbd_prefs,1,125), row + 2,
   line1 = fillstring(128,"="), line1, line = fillstring(128,"-"),
   row + 1
  HEAD c1662.display
   row + 2, line, row + 1,
   col 2, captions->process, col 23,
   c1662.display, row + 1, col 2,
   captions->question, col 110, captions->answer,
   row + 1, line, row + 2
  DETAIL
   tot_char_cnt = size(trim(q.question),1), ln_cnt = 0, beg_char = 1,
   stat = alterlist(question->text_lns,3)
   WHILE ((beg_char < (tot_char_cnt+ 1)))
     end_text_ind = "N"
     IF ((((tot_char_cnt+ 1) - beg_char) > len_text_ln))
      len_get_text = len_text_ln
      IF (substring((len_get_text+ 1),1,q.question)=" ")
       end_text_ind = "Y"
      ENDIF
     ELSE
      end_text_ind = "Y", len_get_text = ((tot_char_cnt+ 1) - beg_char)
     ENDIF
     space_ind = "N"
     WHILE (space_ind="N"
      AND end_text_ind != "Y")
       IF (substring(len_get_text,1,q.question)=" ")
        space_ind = "Y"
       ELSE
        len_get_text = (len_get_text - 1)
       ENDIF
     ENDWHILE
     ln_cnt = (ln_cnt+ 1)
     IF (mod(ln_cnt,3)=1
      AND ln_cnt != 1)
      stat = alterlist(question->text_lns,(ln_cnt+ 2))
     ENDIF
     question->text_lns[ln_cnt].text_ln = substring(beg_char,len_get_text,q.question), beg_char = (
     beg_char+ len_get_text)
     IF (end_text_ind="Y")
      beg_char = (beg_char+ 1)
     ENDIF
   ENDWHILE
   FOR (ln = 1 TO ln_cnt)
     col 2, question->text_lns[ln].text_ln
     IF (ln=1)
      IF (q.response_flag=1)
       col 110, c1659.display
      ELSEIF (q.response_flag=0)
       col 110, cv.display
      ELSEIF (q.response_flag IN (2, 3))
       col 110, a.answer
      ELSEIF (q.response_flag=4
       AND a.active_ind=1
       AND a.answer="1")
       col 110, captions->yes
      ELSEIF (q.response_flag=4
       AND a.active_ind=1
       AND a.answer="0")
       col 110, captions->no
      ENDIF
     ENDIF
     row + 1
   ENDFOR
   row + 1
  FOOT REPORT
   row + 3, col 49, captions->end_of_report
  WITH nullreport, nocounter, compress,
   nolandscape, dontcare = cv, outerjoin(d_ans),
   outerjoin(d_rsp)
 ;end select
END GO
