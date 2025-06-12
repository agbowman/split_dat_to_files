CREATE PROGRAM bbt_rpt_pref_audit:dba
 RECORD question(
   1 text_lns[*]
     2 text_ln = c100
 )
 RECORD reply(
   1 rpt_list[*]
     2 rpt_filename = vc
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
   1 as_of_date = vc
   1 database_audit = vc
   1 page_no = vc
   1 time = vc
   1 db_pref_tool = vc
   1 bb_prefs = vc
   1 process = vc
   1 question = vc
   1 answer = vc
   1 yes = vc
   1 no = vc
   1 end_of_report = vc
 )
 SET captions->as_of_date = uar_i18ngetmessage(i18nhandle,"as_of_date","AS OF DATE:  ")
 SET captions->database_audit = uar_i18ngetmessage(i18nhandle,"database_audit","DATABASE AUDIT")
 SET captions->page_no = uar_i18ngetmessage(i18nhandle,"page_no","PAGE NO:")
 SET captions->time = uar_i18ngetmessage(i18nhandle,"time","TIME: ")
 SET captions->db_pref_tool = uar_i18ngetmessage(i18nhandle,"db_pref_tool","DB PREFERENCE TOOL")
 SET captions->bb_prefs = uar_i18ngetmessage(i18nhandle,"bb_prefs","BLOOD BANK PREFERENCES")
 SET captions->process = uar_i18ngetmessage(i18nhandle,"process","PROCESS:  ")
 SET captions->question = uar_i18ngetmessage(i18nhandle,"question","QUESTION")
 SET captions->answer = uar_i18ngetmessage(i18nhandle,"answer","ANSWER")
 SET captions->yes = uar_i18ngetmessage(i18nhandle,"yes","YES")
 SET captions->no = uar_i18ngetmessage(i18nhandle,"no","NO")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report",
  "* * * E N D  O F  R E P O R T * * * ")
 SET reply->status_data.status = "F"
 SET select_ok_ind = 0
 SET rpt_cnt = 0
 EXECUTE cpm_create_file_name_logical "bbt_pref_audit", "txt", "x"
 DECLARE stat = i2 WITH noconstant(0)
 DECLARE module_questions_cs = i4 WITH constant(1660)
 DECLARE bb_transf_cdf = c12 WITH noconstant(fillstring(12," "))
 DECLARE bb_transf_cd = f8 WITH noconstant(0.0)
 SET bb_transf_cdf = "BB TRANSF"
 SET stat = uar_get_meaning_by_codeset(module_questions_cs,bb_transf_cdf,1,bb_transf_cd)
 IF (stat != 0)
  CALL echo(concat("Error getting code value: ",bb_transf_cdf,cnvtstring(bb_transf_cd)))
  GO TO exit_script
 ENDIF
 SELECT INTO cpm_cfn_info->file_name_logical
  process_display = uar_get_code_display(q.process_cd), question_display = uar_get_code_display(q
   .question_cd), q.question,
  a.answer
  FROM question q,
   (dummyt d1  WITH seq = 1),
   answer a
  PLAN (q
   WHERE q.module_cd=bb_transf_cd
    AND q.active_ind=1)
   JOIN (d1)
   JOIN (a
   WHERE a.question_cd=q.question_cd
    AND a.active_ind=1)
  ORDER BY process_display
  HEAD REPORT
   ln_cnt = 0, beg_char = 0, tot_char_cnt = 0,
   len_text_ln = 100, len_get_text = 0, ln = 0,
   select_ok_ind = 0
  HEAD PAGE
   col 1, captions->as_of_date, col 14,
   curdate"@DATECONDENSED;;d", col 52, captions->database_audit,
   col 108, captions->page_no, col 120,
   curpage"##", row + 1, col 7,
   captions->time, col 14, curtime"@TIMENOSECONDS;;M",
   col 50, captions->db_pref_tool, row + 1,
   col 48, captions->bb_prefs, row + 2,
   line1 = fillstring(128,"="), line1, line = fillstring(128,"-"),
   row + 1
  HEAD process_display
   row + 2, line, row + 1,
   col 2, captions->process, col 23,
   process_display, row + 1, col 2,
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
     question_disp = substring(1,106,question->text_lns[ln].text_ln), col 2, question_disp
     IF (ln=1)
      IF (q.response_flag IN (0, 1))
       answer_display = substring(1,20,uar_get_code_display(cnvtreal(a.answer))), col 110,
       answer_display
      ELSEIF (q.response_flag IN (2, 3))
       answer_display = substring(1,20,a.answer), col 110, answer_display
      ELSEIF (q.response_flag=4
       AND a.active_ind=1
       AND a.answer="1")
       col 110, captions->yes
      ELSEIF (q.response_flag=4
       AND a.active_ind=1
       AND a.answer="0")
       col 110, captions->no
      ELSEIF (q.response_flag=5)
       answer_display = substring(1,20,a.answer), col 110, answer_display
      ENDIF
     ENDIF
     row + 1
   ENDFOR
   row + 1
  FOOT REPORT
   row + 3, col 49, captions->end_of_report,
   select_ok_ind = 1
  WITH nullreport, nocounter, compress,
   nolandscape, outerjoin = d1, dontcare = a
 ;end select
 SET rpt_cnt = (rpt_cnt+ 1)
 SET stat = alterlist(reply->rpt_list,rpt_cnt)
 SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
 IF (select_ok_ind=1)
  SET reply->status_data.status = "S"
 ENDIF
END GO
