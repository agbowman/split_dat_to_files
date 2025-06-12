CREATE PROGRAM cp_get_ecg_interps:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 num_lines = f8
    1 qual[*]
      2 line = c255
    1 output_file = vc
    1 log_info[*]
      2 log_level = i2
      2 log_message = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
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
 DECLARE i18nhandle = i4 WITH noconstant(0)
 DECLARE h = i4 WITH noconstant(0)
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 DECLARE cfailed = c1 WITH protect, noconstant("F")
 DECLARE cnodata = c1 WITH protect, noconstant("Y")
 DECLARE maximum_length = i4 WITH protect, constant(100)
 DECLARE debug = i2 WITH protect
 IF ((request->scope_flag=777))
  SET debug = 1
 ENDIF
 DECLARE g_person_id = f8 WITH protect, constant(validate(request->person_id,0.0))
 DECLARE g_encntr_id = f8 WITH protect, constant(validate(request->encntr_id,0.0))
 DECLARE g_begin_dt_tm = q8 WITH protect, constant(validate(request->begin_dt_tm,cnvtdatetime(
    "01-JAN-1800")))
 DECLARE g_end_dt_tm = q8 WITH protect, constant(validate(request->end_dt_tm,cnvtdatetime(curdate,
    curtime3)))
 DECLARE nencntrcnt = i4 WITH protect
 DECLARE cur_list_size = i4 WITH protect
 DECLARE loop_cnt = i4 WITH protect
 DECLARE new_list_size = i4 WITH protect
 DECLARE stat = i4 WITH protect
 DECLARE nstart = i4 WITH protect
 DECLARE idx = i4 WITH protect
 DECLARE batch_size = i4 WITH protect, constant(20)
 DECLARE mnem_disp_level = c1 WITH protect, noconstant("1")
 DECLARE errmsg = vc WITH protect
 DECLARE order_disp_str = vc WITH protect
 DECLARE order_date_str = vc WITH protect
 DECLARE step_status_completed_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4000440,
   "COMPLETED"))
 DECLARE step_type_finalreport_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4001923,
   "FINALREPORT"))
 DECLARE doc_type_ecg_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4000360,"ECG"))
 DECLARE source_text = vc WITH protect
 DECLARE source_size = i4 WITH protect
 DECLARE processed_cnt = i4 WITH protect
 DECLARE newline_pos = i4 WITH protect
 DECLARE qual_cnt = i4 WITH protect
 DECLARE newline = c2 WITH protect, constant(concat(char(13),char(10)))
 DECLARE cr = c1 WITH protect, constant(char(13))
 DECLARE report_failure(opname=vc,opstatus=c1,targetname=vc,targetvalue=vc) = null
 SELECT INTO "nl:"
  FROM name_value_prefs nvp,
   app_prefs ap
  PLAN (nvp
   WHERE nvp.pvc_name="MNEM_DISP_LEVEL")
   JOIN (ap
   WHERE ap.app_prefs_id=nvp.parent_entity_id
    AND ap.prsnl_id=0.0
    AND ap.position_cd=0.0)
  DETAIL
   IF (nvp.pvc_value IN ("0", "1", "2", "4"))
    mnem_disp_level = nvp.pvc_value
   ENDIF
  WITH nocounter
 ;end select
 CALL echo(concat("mnem_disp_level:",mnem_disp_level))
 IF (error(errmsg,0) != 0)
  CALL report_failure("SELECT","F","NAME_VALUE_PREFS",errmsg)
  GO TO exit_script
 ENDIF
 FREE RECORD tmp_lines
 RECORD tmp_lines(
   1 unprocessed[*]
     2 line = vc
   1 nl_processed[*]
     2 line = vc
   1 unproc_cnt = i4
   1 nlproc_cnt = i4
 )
 SET cur_list_size = size(request->encntr_list,5)
 IF (cur_list_size > 0)
  SET nencntrcnt = cur_list_size
  SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
  SET new_list_size = (loop_cnt * batch_size)
  SET stat = alterlist(request->encntr_list,new_list_size)
  SET nstart = 1
  FOR (idx = (cur_list_size+ 1) TO new_list_size)
    SET request->encntr_list[idx].encntr_id = request->encntr_list[cur_list_size].encntr_id
  ENDFOR
 ENDIF
 SELECT
  IF (nencntrcnt > 0)
   FROM (dummyt d1  WITH seq = value(loop_cnt)),
    cv_proc cp,
    cv_step cs,
    cv_step_ref csr,
    long_text lt,
    orders o
   PLAN (d1
    WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
    JOIN (cp
    WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),cp.encntr_id,request->encntr_list[idx].
     encntr_id))
    JOIN (o
    WHERE o.order_id=cp.order_id)
    JOIN (cs
    WHERE cs.cv_proc_id=cp.cv_proc_id
     AND cs.step_status_cd=step_status_completed_cd
     AND cs.perf_start_dt_tm BETWEEN cnvtdatetime(g_begin_dt_tm) AND cnvtdatetime(g_end_dt_tm))
    JOIN (csr
    WHERE csr.task_assay_cd=cs.task_assay_cd
     AND csr.doc_type_cd=doc_type_ecg_cd
     AND csr.step_type_cd=step_type_finalreport_cd)
    JOIN (lt
    WHERE lt.parent_entity_name="CV_STEP"
     AND lt.active_ind=1
     AND lt.parent_entity_id=cs.cv_step_id)
  ELSEIF (g_encntr_id != 0.0)
   FROM cv_proc cp,
    cv_step cs,
    cv_step_ref csr,
    long_text lt,
    orders o
   PLAN (cp
    WHERE cp.encntr_id=g_encntr_id)
    JOIN (o
    WHERE o.order_id=cp.order_id)
    JOIN (cs
    WHERE cs.cv_proc_id=cp.cv_proc_id
     AND cs.step_status_cd=step_status_completed_cd
     AND cs.perf_start_dt_tm BETWEEN cnvtdatetime(g_begin_dt_tm) AND cnvtdatetime(g_end_dt_tm))
    JOIN (csr
    WHERE csr.task_assay_cd=cs.task_assay_cd
     AND csr.doc_type_cd=doc_type_ecg_cd
     AND csr.step_type_cd=step_type_finalreport_cd)
    JOIN (lt
    WHERE lt.parent_entity_name="CV_STEP"
     AND lt.active_ind=1
     AND lt.parent_entity_id=cs.cv_step_id)
  ELSEIF (g_person_id != 0.0)
   FROM cv_proc cp,
    cv_step cs,
    cv_step_ref csr,
    long_text lt,
    orders o
   PLAN (cp
    WHERE cp.person_id=g_person_id)
    JOIN (o
    WHERE o.order_id=cp.order_id)
    JOIN (cs
    WHERE cs.cv_proc_id=cp.cv_proc_id
     AND cs.step_status_cd=step_status_completed_cd
     AND cs.perf_start_dt_tm BETWEEN cnvtdatetime(g_begin_dt_tm) AND cnvtdatetime(g_end_dt_tm))
    JOIN (csr
    WHERE csr.task_assay_cd=cs.task_assay_cd
     AND csr.doc_type_cd=doc_type_ecg_cd
     AND csr.step_type_cd=step_type_finalreport_cd)
    JOIN (lt
    WHERE lt.parent_entity_name="CV_STEP"
     AND lt.active_ind=1
     AND lt.parent_entity_id=cs.cv_step_id)
  ELSE
  ENDIF
  INTO "nl:"
  FROM cv_proc cp,
   cv_step cs,
   cv_step_ref csr,
   long_text lt,
   orders o
  PLAN (cp
   WHERE (cp.cv_proc_id=- (1.0)))
   JOIN (o
   WHERE o.order_id=cp.order_id)
   JOIN (cs
   WHERE cs.cv_proc_id=cp.cv_proc_id)
   JOIN (csr
   WHERE csr.task_assay_cd=cs.task_assay_cd)
   JOIN (lt
   WHERE lt.parent_entity_id=cs.cv_step_id)
  ORDER BY cp.action_dt_tm DESC
  HEAD REPORT
   tmp_cnt = 0
  DETAIL
   order_disp_str = " "
   IF (mnem_disp_level="0")
    order_disp_str = trim(o.hna_order_mnemonic)
   ELSEIF (mnem_disp_level="1")
    IF (((o.hna_order_mnemonic=o.ordered_as_mnemonic) OR (o.ordered_as_mnemonic=" ")) )
     order_disp_str = trim(o.hna_order_mnemonic)
    ELSE
     order_disp_str = concat(trim(o.hna_order_mnemonic),"(",trim(o.ordered_as_mnemonic),")")
    ENDIF
   ELSEIF (mnem_disp_level="2")
    IF (((o.hna_order_mnemonic=o.ordered_as_mnemonic) OR (o.ordered_as_mnemonic=" ")) )
     order_disp_str = trim(o.hna_order_mnemonic)
    ELSE
     order_disp_str = concat(trim(o.hna_order_mnemonic),"(",trim(o.ordered_as_mnemonic),")")
    ENDIF
    IF (o.order_mnemonic != o.ordered_as_mnemonic
     AND o.order_mnemonic > " ")
     order_disp_str = concat(trim(order_disp_str),"(",trim(o.order_mnemonic),")")
    ENDIF
   ELSEIF (mnem_disp_level="4")
    IF (((o.hna_order_mnemonic=o.order_mnemonic) OR (o.order_mnemonic=" ")) )
     order_disp_str = trim(o.hna_order_mnemonic)
    ELSE
     order_disp_str = concat(trim(o.hna_order_mnemonic),"(",trim(o.order_mnemonic),")")
    ENDIF
   ENDIF
   tmp_cnt = (tmp_cnt+ 1)
   IF (mod(tmp_cnt,30)=1)
    stat = alterlist(tmp_lines->unprocessed,(tmp_cnt+ 29))
   ENDIF
   order_date_str = trim(format(cp.action_dt_tm,"@LONGDATETIME")), tmp_lines->unprocessed[tmp_cnt].
   line = uar_i18nbuildmessage(i18nhandle,"key1",
    "%1 was performed on %2. The interpretation is as follows:","ss",nullterm(order_disp_str),
    nullterm(order_date_str)), tmp_cnt = (tmp_cnt+ 1),
   tmp_lines->unprocessed[tmp_cnt].line = lt.long_text, tmp_cnt = (tmp_cnt+ 1), tmp_lines->
   unprocessed[tmp_cnt].line = ""
  FOOT REPORT
   stat = alterlist(tmp_lines->unprocessed,tmp_cnt), tmp_lines->unproc_cnt = tmp_cnt
  WITH nocounter
 ;end select
 IF (error(errmsg,0) != 0)
  CALL report_failure("SELECT","F","LONG_TEXT",errmsg)
  GO TO exit_script
 ENDIF
 IF (curqual=0)
  CALL echo("No interpretation text found for patient or encounter.")
  GO TO exit_script
 ELSE
  SET cnodata = "N"
 ENDIF
 SET processed_cnt = 0
 FOR (i = 1 TO tmp_lines->unproc_cnt)
   SET source_text = tmp_lines->unprocessed[i].line
   SET source_text = replace(source_text,newline,cr,0)
   SET source_text = replace(source_text,cr,newline,0)
   SET newline_pos = findstring(newline,source_text)
   WHILE (newline_pos > 0)
     SET processed_cnt = (processed_cnt+ 1)
     SET stat = alterlist(tmp_lines->nl_processed,processed_cnt)
     SET tmp_lines->nl_processed[processed_cnt].line = substring(1,(newline_pos - 1),source_text)
     SET source_text = substring((newline_pos+ 2),(textlen(source_text) - (newline_pos+ 1)),
      source_text)
     SET newline_pos = findstring(newline,source_text)
   ENDWHILE
   SET processed_cnt = (processed_cnt+ 1)
   SET stat = alterlist(tmp_lines->nl_processed,processed_cnt)
   SET tmp_lines->nl_processed[processed_cnt].line = source_text
 ENDFOR
 SET tmp_lines->nlproc_cnt = processed_cnt
 SET qual_cnt = 0
 FOR (i = 1 TO tmp_lines->nlproc_cnt)
   SET source_text = tmp_lines->nl_processed[i].line
   SET source_size = textlen(source_text)
   WHILE (source_size > maximum_length)
     SET idx = maximum_length
     WHILE (idx > 0)
       CALL echo(idx)
       IF (substring(idx,1,source_text)=" ")
        SET qual_cnt = (qual_cnt+ 1)
        SET stat = alterlist(reply->qual,qual_cnt)
        SET reply->qual[qual_cnt].line = substring(1,idx,source_text)
        SET source_text = substring((idx+ 1),(textlen(source_text) - idx),source_text)
        SET idx = 1
       ENDIF
       SET idx = (idx - 1)
     ENDWHILE
     IF (textlen(source_text)=textlen(trim(tmp_lines->nl_processed[i].line)))
      SET qual_cnt = (qual_cnt+ 1)
      SET stat = alterlist(reply->qual,qual_cnt)
      SET reply->qual[qual_cnt].line = substring(1,maximum_length,source_text)
      SET source_text = substring((maximum_length+ 1),(textlen(source_text) - maximum_length),
       source_text)
     ENDIF
     SET source_size = textlen(source_text)
   ENDWHILE
   SET qual_cnt = (qual_cnt+ 1)
   SET stat = alterlist(reply->qual,qual_cnt)
   SET reply->qual[qual_cnt].line = source_text
 ENDFOR
 IF (debug=1)
  CALL echorecord(tmp_lines)
 ENDIF
 SET stat = alterlist(reply->qual,qual_cnt)
 SET reply->num_lines = qual_cnt
 SUBROUTINE report_failure(opname,opstatus,targetname,targetvalue)
   DECLARE cnt = i4 WITH protect, noconstant(0)
   DECLARE stat = i4 WITH protect, noconstant(0)
   SET cfailed = "T"
   SET cnt = size(reply->status_data.subeventstatus,5)
   IF (((cnt != 1) OR (cnt=1
    AND (reply->status_data.subeventstatus[1].operationstatus != null))) )
    SET cnt = (cnt+ 1)
    SET stat = alter(reply->status_data.subeventstatus,value(cnt))
   ENDIF
   SET reply->status_data.subeventstatus[cnt].operationname = trim(opname)
   SET reply->status_data.subeventstatus[cnt].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[cnt].targetobjectname = trim(targetname)
   SET reply->status_data.subeventstatus[cnt].targetobjectvalue = trim(targetvalue)
 END ;Subroutine
#exit_script
 IF (cfailed="T")
  SET reply->status_data.status = "F"
 ELSE
  IF (cnodata="Y")
   SET reply->status_data.status = "Z"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
 IF (debug=1)
  CALL echorecord(reply)
 ENDIF
END GO
