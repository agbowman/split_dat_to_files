CREATE PROGRAM dts_get_discharge:dba
 SET rhead =
 "{\rtf1\ansi \deff0{\fonttbl{\f0\fswiss Arial;}}{\colortbl;\red0\green0\blue0;\red255\green255\blue255;}\deftab1134"
 SET rh2r = "\plain \f0 \fs18 \cb2 \pard\sl0 "
 SET rh2b = "\plain \f0 \fs24 \b \cb2 \pard\sl0 "
 SET rh2bu = "\plain \f0 \fs18 \b \ul \cb2 \pard\sl0 "
 SET rh2u = "\plain \f0 \fs18 \u \cb2 \pard\sl0 "
 SET rh2i = "\plain \f0 \fs18 \i \cb2 \pard\sl0 "
 SET rtab = "\tab "
 SET reol = "\par "
 SET rtab = "\tab "
 SET wr = " \plain \f0 \fs20 \cb2 "
 SET wb = " \plain \f0 \fs20 \b \cb2 "
 SET wu = " \plain \f0 \fs18 \ul \cb2 "
 SET wi = " \plain \f0 \fs18 \i \cb2 "
 SET wbi = " \plain \f0 \fs18 \b \i \cb2 "
 SET wiu = " \plain \f0 \fs18 \i \ul \cb2 "
 SET wbiu = " \plain \f0 \fs18 \b \ul \i \cb2 "
 SET wbu = " \plain \f0 \fs18 \b \ul \cb2 "
 SET rtfeof = "}"
 RECORD drec(
   1 line_cnt = i4
   1 display_line = vc
   1 line_qual[*]
     2 disp_line = vc
 )
 RECORD allergy(
   1 cnt = i2
   1 qual[*]
     2 list = vc
 )
 RECORD diag(
   1 line = vc
 )
 RECORD lab(
   1 cnt = i2
   1 qual[*]
     2 val = vc
     2 date = vc
     2 label = vc
     2 unit = vc
 )
 RECORD proc(
   1 cnt = i2
   1 qual[*]
     2 line = vc
 )
 RECORD ord(
   1 cnt = i2
   1 qual[*]
     2 type = vc
     2 line = vc
 )
 RECORD exam(
   1 line = vc
   1 list_ln_cnt = i2
   1 list_tag[*]
     2 list_line = vc
 )
 RECORD cond(
   1 cnt = i2
   1 qual[*]
     2 type = vc
     2 line = vc
 )
 RECORD pt(
   1 line_cnt = i2
   1 lns[*]
     2 line = vc
 )
 SET lidx = 0
 SET code_value = 0.0
 SET code_set = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET name = fillstring(50," ")
 SET dob = fillstring(50," ")
 SET mrn = fillstring(50," ")
 SET attenddoc = fillstring(50," ")
 SET admit_date = fillstring(50," ")
 SET disch_date = fillstring(50," ")
 SET person_id = 0
 SET encntr_id = 0
 SET a_date = cnvtdatetime(curdate,curtime)
 SET age = fillstring(50," ")
 SET sex = fillstring(50," ")
 SET code_set = 333
 SET cdf_meaning = "ATTENDDOC"
 EXECUTE cpm_get_cd_for_cdf
 SET attend_doc_cd = code_value
 SET code_set = 4
 SET cdf_meaning = "MRN"
 SET sex = fillstring(50," ")
 SET age = fillstring(50," ")
 EXECUTE cpm_get_cd_for_cdf
 SET mrn_alias_cd = code_value
 SET canceled_cd = 0
 SET code_set = 12025
 SET cdf_meaning = "CANCELED"
 EXECUTE cpm_get_cd_for_cdf
 SET canceled_cd = code_value
 SET inerror_cd = 0
 SET code_set = 8
 SET cdf_meaning = "INERROR"
 EXECUTE cpm_get_cd_for_cdf
 SET inerror_cd = code_value
 SET code_set = 6004
 SET cdf_meaning = "ORDERED"
 EXECUTE cpm_get_cd_for_cdf
 SET ordered_cd = code_value
 SET code_set = 6004
 SET cdf_meaning = "INPROCESS"
 EXECUTE cpm_get_cd_for_cdf
 SET inprocess_cd = code_value
 SET code_set = 120
 SET cdf_meaning = "OCFCOMP"
 EXECUTE cpm_get_cd_for_cdf
 SET ocfcomp_cd = code_value
 SELECT INTO "nl:"
  FROM encounter e,
   person p,
   (dummyt d  WITH seq = 1),
   person_alias pa,
   (dummyt d1  WITH seq = 1),
   encntr_prsnl_reltn epr,
   prsnl pl
  PLAN (e
   WHERE (e.encntr_id=request->visit[1].encntr_id))
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (d)
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.person_alias_type_cd=mrn_alias_cd
    AND pa.active_ind=1)
   JOIN (d1)
   JOIN (epr
   WHERE epr.encntr_id=e.encntr_id
    AND epr.encntr_prsnl_r_cd=attend_doc_cd
    AND epr.active_ind=1
    AND ((epr.expiration_ind != 1) OR (epr.expiration_ind = null)) )
   JOIN (pl
   WHERE pl.person_id=epr.prsnl_person_id)
  DETAIL
   name = substring(1,40,p.name_full_formatted), dob = format(p.birth_dt_tm,"mm/dd/yy;;d"), mrn =
   substring(1,20,pa.alias),
   attenddoc = substring(1,40,pl.name_full_formatted), admit_date = format(e.reg_dt_tm,"mm/dd/yy;;d"),
   disch_date = format(curdate,"mm/dd/yy;;d"),
   person_id = e.person_id, encntr_id = e.encntr_id, a_date = cnvtdatetime(e.reg_dt_tm),
   age = cnvtage(p.birth_dt_tm), sex = uar_get_code_display(cnvtreal(p.sex_cd))
  WITH nocounter, outerjoin = d, dontcare = pa,
   outerjoin = d1, dontcare = epr
 ;end select
 SELECT INTO "nl:"
  FROM allergy a,
   (dummyt d  WITH seq = 1),
   nomenclature n
  PLAN (a
   WHERE a.person_id=person_id
    AND a.active_ind=1
    AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ((a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)) OR (a.end_effective_dt_tm=null))
    AND a.reaction_status_cd != canceled_cd)
   JOIN (d)
   JOIN (n
   WHERE n.nomenclature_id=a.substance_nom_id)
  ORDER BY cnvtdatetime(a.onset_dt_tm)
  HEAD REPORT
   allergy->cnt = 0
  DETAIL
   IF (((n.source_string > " ") OR (a.substance_ftdesc > " ")) )
    allergy->cnt = (allergy->cnt+ 1), stat = alterlist(allergy->qual,allergy->cnt), allergy->qual[
    allergy->cnt].list = a.substance_ftdesc
    IF (n.source_string > " ")
     allergy->qual[allergy->cnt].list = n.source_string
    ENDIF
   ENDIF
  WITH nocounter, outerjoin = d, dontcare = n
 ;end select
 SELECT INTO "nl:"
  FROM encounter e
  PLAN (e
   WHERE e.encntr_id=encntr_id)
  DETAIL
   diag->line = e.reason_for_visit
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM procedure p,
   (dummyt d1  WITH seq = 1),
   nomenclature n
  PLAN (p
   WHERE p.encntr_id=encntr_id
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ((p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)) OR (p.end_effective_dt_tm=null)) )
   JOIN (d1)
   JOIN (n
   WHERE n.nomenclature_id=p.nomenclature_id)
  ORDER BY cnvtdatetime(p.proc_dt_tm)
  HEAD REPORT
   proc->cnt = 0
  DETAIL
   IF (((n.source_string > " ") OR (p.proc_ftdesc > " ")) )
    proc->cnt = (proc->cnt+ 1), stat = alterlist(proc->qual,proc->cnt), proc->qual[proc->cnt].line =
    p.proc_ftdesc
    IF (n.source_string > " ")
     proc->qual[proc->cnt].line = n.source_string
    ENDIF
   ENDIF
  WITH nocounter, outerjoin = d1, dontcare = n
 ;end select
 SELECT INTO "nl:"
  FROM orders o,
   order_detail od
  PLAN (o
   WHERE o.encntr_id=encntr_id
    AND o.order_status_cd IN (ordered_cd, inprocess_cd)
    AND o.catalog_type_cd=583)
   JOIN (od
   WHERE o.order_id=od.order_id
    AND od.oe_field_id=330478)
  ORDER BY cnvtdatetime(o.current_start_dt_tm)
  HEAD REPORT
   ord->cnt = 0
  HEAD o.order_id
   ord->cnt = (ord->cnt+ 1), stat = alterlist(ord->qual,ord->cnt), ord->qual[ord->cnt].type = o
   .order_mnemonic,
   ord->qual[ord->cnt].line = o.clinical_display_line, ord->qual[ord->cnt].line = concat(trim(ord->
     qual[ord->cnt].type)," - ",trim(ord->qual[ord->cnt].line))
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM orders o
  PLAN (o
   WHERE o.encntr_id=encntr_id
    AND o.order_status_cd IN (ordered_cd, inprocess_cd)
    AND o.catalog_cd=892348)
  ORDER BY cnvtdatetime(o.current_start_dt_tm)
  HEAD REPORT
   cond->cnt = 0
  HEAD o.order_id
   cond->cnt = (cond->cnt+ 1), stat = alterlist(cond->qual,cond->cnt), cond->qual[cond->cnt].type = o
   .order_mnemonic,
   cond->qual[cond->cnt].line = o.clinical_display_line, cond->qual[cond->cnt].line = concat(trim(
     cond->qual[cond->cnt].type)," - ",trim(cond->qual[cond->cnt].line))
  WITH nocounter
 ;end select
 SET diff = 0
 SET beg_dt_tm = cnvtdatetime(curdate,curtime)
 SET end_dt_tm = cnvtdatetime(curdate,curtime)
 SET diff = datetimediff(cnvtdatetime(curdate,2359),cnvtdatetime(a_date))
 SET beg_dt_tm = cnvtdatetime((curdate - diff),0)
 SET end_dt_tm = cnvtdatetime((curdate - (diff - 1)),0)
 SELECT INTO "nl:"
  FROM v500_event_set_code vesc,
   v500_event_set_canon ves,
   v500_event_set_explode vese,
   clinical_event c,
   code_value cv,
   (dummyt d  WITH seq = 1),
   code_value cv2
  PLAN (vesc
   WHERE vesc.event_set_cd_disp_key IN ("CHEMISTRY", "HEMATOLOGY"))
   JOIN (ves
   WHERE ves.parent_event_set_cd=vesc.event_set_cd)
   JOIN (vese
   WHERE vese.event_set_cd=ves.event_set_cd)
   JOIN (c
   WHERE c.person_id=person_id
    AND (c.encntr_id=request->visit[1].encntr_id)
    AND c.event_cd=vese.event_cd
    AND c.view_level=1
    AND c.publish_flag=1
    AND c.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
    AND c.event_end_dt_tm >= cnvtdatetime(beg_dt_tm)
    AND c.event_end_dt_tm < cnvtdatetime(end_dt_tm)
    AND c.result_status_cd != inerror_cd)
   JOIN (cv
   WHERE cv.code_value=c.event_cd)
   JOIN (d)
   JOIN (cv2
   WHERE cv2.code_value=c.result_units_cd)
  ORDER BY cnvtdatetime(c.event_end_dt_tm)
  HEAD REPORT
   lab->cnt = 0
  DETAIL
   lab->cnt = (lab->cnt+ 1), stat = alterlist(lab->qual,lab->cnt), lab->qual[lab->cnt].val = c
   .event_tag,
   lab->qual[lab->cnt].label = cv.display, lab->qual[lab->cnt].unit = cv2.display
   IF ((lab->qual[lab->cnt].unit > " "))
    lab->qual[lab->cnt].val = concat(trim(lab->qual[lab->cnt].val)," ",trim(lab->qual[lab->cnt].unit)
     )
   ENDIF
   lab->qual[lab->cnt].date = format(c.event_end_dt_tm,"mm/dd/yy hh:mm;;d")
   IF ((lab->qual[lab->cnt].val > " "))
    lab->qual[lab->cnt].val = concat(trim(lab->qual[lab->cnt].date),"  ",trim(lab->qual[lab->cnt].
      label),": ",trim(lab->qual[lab->cnt].val))
   ENDIF
  WITH nocounter, outerjoin = d, dontcare = cv2
 ;end select
 SELECT INTO "nl:"
  FROM clinical_event c,
   clinical_event c2,
   ce_blob_result cbr,
   ce_blob cb
  PLAN (c
   WHERE c.person_id=person_id
    AND (c.encntr_id=request->visit[1].encntr_id)
    AND c.event_cd=22443
    AND c.view_level=1
    AND c.publish_flag=1
    AND c.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
    AND c.result_status_cd != inerror_cd)
   JOIN (c2
   WHERE c2.parent_event_id=c.parent_event_id
    AND c2.view_level=0
    AND c2.valid_until_dt_tm=cnvtdatetime("31-DEC-2100, 00:00:00")
    AND c2.publish_flag=1)
   JOIN (cbr
   WHERE cbr.event_id=c2.event_id
    AND cbr.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00"))
   JOIN (cb
   WHERE cb.event_id=c2.event_id
    AND cb.valid_until_dt_tm=cnvtdatetime("31-DEC-2100, 00:00:00"))
  ORDER BY c.event_end_dt_tm
  DETAIL
   blob_out = fillstring(32000," "), blob_out2 = fillstring(32000," ")
   IF (cb.compression_cd=ocfcomp_cd)
    blob_ret_len = 0, sze = textlen(cb.blob_contents),
    CALL uar_ocf_uncompress(cb.blob_contents,textlen(cb.blob_contents),blob_out,32000,blob_ret_len)
   ELSE
    y1 = size(trim(cb.blob_contents)), blob_out = substring(1,(y1 - 8),cb.blob_contents)
   ENDIF
   CALL uar_rtf(blob_out,textlen(blob_out),blob_out2,32000,32000,0), exam->line = trim(blob_out2,3)
  WITH nocounter
 ;end select
 SET pt->line_cnt = 0
 SET max_length = 70
 EXECUTE dcp_parse_text value(exam->line), value(max_length)
 SET stat = alterlist(exam->list_tag,pt->line_cnt)
 SET exam->list_ln_cnt = pt->line_cnt
 FOR (x = 1 TO pt->line_cnt)
   SET exam->list_tag[x].list_line = pt->lns[x].line
 ENDFOR
 SELECT INTO "nl:"
  d.seq
  FROM (dummyt d  WITH seq = 1)
  PLAN (d)
  DETAIL
   lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat
   (rhead,wr,"PATIENT:  ",trim(name),reol),
   lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat
   (rhead,wr,"MRN:  ",trim(mrn),reol),
   lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat
   (wr,"SEX: ",wr,trim(sex),rtab,
    rtab),
   lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat
   (wr,"DOB: ",wr,trim(dob),rtab,
    rtab),
   lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat
   (wr,"AGE: ",wr,trim(age),reol),
   lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat
   (wr,"ADMIT DATE: ",wr,trim(admit_date),rtab,
    rtab),
   lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat
   (wr,"DISCHARGE DATE: ",wr,trim(disch_date),reol),
   lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx)
   IF (((attenddoc="") OR (attenddoc=" ")) )
    attenddoc = '"??"'
   ENDIF
   drec->line_qual[lidx].disp_line = concat(wr,"ATTENDING PHYSICIAN: ",wr,trim(attenddoc),reol), lidx
    = (lidx+ 1), stat = alterlist(drec->line_qual,lidx),
   drec->line_qual[lidx].disp_line = reol, lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx),
   drec->line_qual[lidx].disp_line = concat(wr,"DISCHARGE DIAGNOSIS",reol), lidx = (lidx+ 1), stat =
   alterlist(drec->line_qual,lidx)
   IF ((diag->line=""))
    diag->line = '"??"'
   ENDIF
   drec->line_qual[lidx].disp_line = concat(wr,trim(diag->line),reol), lidx = (lidx+ 1), stat =
   alterlist(drec->line_qual,lidx),
   drec->line_qual[lidx].disp_line = reol, lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx),
   drec->line_qual[lidx].disp_line = concat(wr,"ALLERGIES",reol)
   IF ((allergy->cnt > 0))
    FOR (x = 1 TO allergy->cnt)
      lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line =
      concat(wr,trim(allergy->qual[x].list),reol)
    ENDFOR
   ELSE
    lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line =
    concat(wr,'"??"',reol)
   ENDIF
   lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = reol,
   lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat
   (wr,"ADMIT LAB WORK",reol)
   IF ((lab->cnt > 0))
    FOR (x = 1 TO lab->cnt)
      lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line =
      concat(wr,trim(lab->qual[x].val),reol)
    ENDFOR
   ELSE
    lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line =
    concat(wr,'"??"',reol)
   ENDIF
   lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = reol,
   lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat
   (wr,"PROCEDURE SUMMARY",reol)
   IF ((proc->cnt > 0))
    FOR (x = 1 TO proc->cnt)
      lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line =
      concat(wr,trim(proc->qual[x].line),reol)
    ENDFOR
   ELSE
    lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line =
    concat(wr,'"??"',reol)
   ENDIF
   lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = reol,
   lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat
   (wr,"DISCHARGE MEDICATIONS",reol)
   IF ((ord->cnt > 0))
    FOR (x = 1 TO ord->cnt)
      lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line =
      concat(wr,trim(ord->qual[x].line),reol)
    ENDFOR
   ELSE
    lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line =
    concat(wr,'"??"',reol)
   ENDIF
   lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = reol,
   lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat
   (wr,"DISCHARGE CONDITION",reol)
   IF ((cond->cnt > 0))
    FOR (x = 1 TO cond->cnt)
      lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line =
      concat(wr,trim(cond->qual[x].line),reol)
    ENDFOR
   ELSE
    lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line =
    concat(wr,'"??"',reol)
   ENDIF
   lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = reol,
   lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat
   (wr,"PHYSICAL EXAM",reol)
   IF ((exam->line > " "))
    FOR (x = 1 TO exam->list_ln_cnt)
      lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line =
      concat(wr,trim(exam->list_tag[x].list_line),reol)
    ENDFOR
   ELSE
    lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line =
    concat(wr,'"??"',reol)
   ENDIF
  FOOT REPORT
   FOR (z = 1 TO lidx)
     reply->text = concat(reply->text,drec->line_qual[z].disp_line)
   ENDFOR
  WITH nocounter, maxcol = 132, maxrow = 500
 ;end select
 SET reply->text = concat(reply->text,rtfeof)
END GO
