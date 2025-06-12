CREATE PROGRAM cp_get_pregnancy:dba
 SET modify = predeclare
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
 RECORD blob(
   1 line = vc
   1 cnt = i2
   1 qual[*]
     2 line = vc
     2 sze = i4
 )
 RECORD pt(
   1 line_cnt = i2
   1 lns[*]
     2 line = vc
 )
 SET reply->status_data.status = "F"
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE failure_ind = i2 WITH protect, noconstant(0)
 DECLARE zero_ind = i2 WITH protect, noconstant(0)
 DECLARE error_code = i2 WITH protect, noconstant(false)
 DECLARE error_msg = vc WITH protect, noconstant("")
 DECLARE i18nhandle = i4 WITH protect, noconstant(0)
 DECLARE rtnhandle = i2 WITH protect, noconstant(0)
 DECLARE active_preg_ind = i2 WITH protect, noconstant(0)
 DECLARE edd_data_ind = i2 WITH protect, noconstant(0)
 DECLARE hx_edd_data_ind = i2 WITH protect, noconstant(0)
 DECLARE phx_data_ind = i2 WITH protect, noconstant(0)
 DECLARE gravida_data_ind = i2 WITH protect, noconstant(0)
 DECLARE dummy_void = i2 WITH constant(0)
 DECLARE egadisplay = vc WITH noconstant, protect
 DECLARE egadays = i4 WITH noconstant(0), protect
 DECLARE entered_dt_str = vc WITH noconstant, protect
 DECLARE num = i4 WITH noconstant(0), public
 DECLARE start = i4 WITH noconstant(1), public
 DECLARE displaystr = vc WITH noconstant, protect
 DECLARE ln = i4 WITH noconstant(0), protect
 DECLARE numrows = i4 WITH noconstant(0), protect
 DECLARE method_ultra_cd = f8 WITH constant(uar_get_code_by("MEANING",4002113,"ULTRASOUND"))
 DECLARE method_lmp_cd = f8 WITH constant(uar_get_code_by("MEANING",4002113,"LMP"))
 DECLARE method_art_cd = f8 WITH constant(uar_get_code_by("MEANING",4002113,"ADVREPTECH"))
 DECLARE method_doc_cd = f8 WITH constant(uar_get_code_by("MEANING",4002113,"CONCEPTIONDT"))
 DECLARE lmp_normal = i4 WITH constant(1), protect
 DECLARE lmp_abnormal = i4 WITH constant(2), protect
 DECLARE lmp_dateapprox = i4 WITH constant(4), protect
 DECLARE lmp_datedef = i4 WITH constant(8), protect
 DECLARE lmp_dateunknown = i4 WITH constant(16), protect
 DECLARE lmp_other = i4 WITH constant(32), protect
 DECLARE entity_anesthesia = f8 WITH constant(uar_get_code_by("MEANING",4002124,"ANESTHESIA"))
 DECLARE entity_fetus = f8 WITH constant(uar_get_code_by("MEANING",4002124,"FETUSCOMP"))
 DECLARE entity_mother = f8 WITH constant(uar_get_code_by("MEANING",4002124,"MOTHERCOMP"))
 DECLARE entity_newborn = f8 WITH constant(uar_get_code_by("MEANING",4002124,"NEWBORNCOMP"))
 DECLARE entity_preterm = f8 WITH constant(uar_get_code_by("MEANING",4002124,"PRETERMLABOR"))
 DECLARE qual_before = i4 WITH constant(1), protect
 DECLARE qual_about = i4 WITH constant(2), protect
 DECLARE qual_after = i4 WITH constant(3), protect
 DECLARE qual_dateonly = i4 WITH constant(4), protect
 DECLARE precision_month = i4 WITH constant(1), protect
 DECLARE precision_year = i4 WITH constant(2), protect
 DECLARE current = i2 WITH constant(1), protect
 DECLARE modified = i2 WITH constant(2), protect
 DECLARE deleted = i2 WITH constant(3), protect
 DECLARE formatreport(null) = null
 DECLARE loadpregnancyhistory(null) = null
 DECLARE fillhxeddrequest(null) = null
 DECLARE buildhxeddtext(null) = null
 SUBROUTINE (reportfailure(opname=vc,opstatus=vc,targetname=vc,targetvalue=vc) =null)
  SET reply->status_data.status = "F"
  CALL fillsubeventstatus(opname,opstatus,targetname,targetvalue)
 END ;Subroutine
 SUBROUTINE (fillsubeventstatus(opname=vc,opstatus=vc,objname=vc,objvalue=vc) =null)
   DECLARE dcp_substatus_cnt = i4 WITH protect, noconstant(size(reply->status_data.subeventstatus,5))
   SET dcp_substatus_cnt += 1
   IF (dcp_substatus_cnt != 1)
    SET stat = alter(reply->status_data.subeventstatus,dcp_substatus_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].operationname = trim(opname)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].targetobjectname = trim(objname)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].targetobjectvalue = trim(objvalue)
 END ;Subroutine
 DECLARE birth_dt_tm_parameter = dq8 WITH protect, noconstant(0)
 SUBROUTINE (calculate_onset_year(onset_age=i4,onset_age_unit_cd_mean=vc) =i4)
   DECLARE onset_year = i4 WITH protect, noconstant(0)
   DECLARE age_in_year = f8 WITH protect, noconstant(0)
   IF (((onset_age=0) OR (birth_dt_tm_parameter=0)) )
    RETURN(onset_year)
   ENDIF
   CASE (onset_age_unit_cd_mean)
    OF "SECONDS":
     SET age_in_year = ((((onset_age/ 60)/ 60)/ 24)/ 365)
    OF "MINUTES":
     SET age_in_year = (((onset_age/ 60)/ 24)/ 365)
    OF "HOURS":
     SET age_in_year = ((onset_age/ 24)/ 365)
    OF "DAYS":
     SET age_in_year = (onset_age/ 365)
    OF "WEEKS":
     SET age_in_year = ((onset_age * 7)/ 365)
    OF "MONTHS":
     SET age_in_year = ((onset_age * 30)/ 365)
    OF "YEARS":
     SET age_in_year = onset_age
    ELSE
     SET age_in_year = onset_age
   ENDCASE
   SET onset_year = ceil(cnvtreal((age_in_year+ year(birth_dt_tm_parameter))))
   RETURN(onset_year)
 END ;Subroutine
 SUBROUTINE (wrap_text(blob_string=vc,wrap_max_length=i4,wrap_sec_max_length=i4) =null)
   DECLARE lf = vc WITH private, noconstant(char(10))
   DECLARE check = vc WITH private, noconstant(concat(char(13),char(10)))
   DECLARE l = i4 WITH private, noconstant(0)
   DECLARE h = i4 WITH private, noconstant(0)
   DECLARE c = i4 WITH private, noconstant(0)
   DECLARE j = i4 WITH private, noconstant(0)
   DECLARE check_blob = vc WITH private, noconstant(fillstring(65535," "))
   SET check_blob = build(blob_string,lf)
   DECLARE cr = i4 WITH private, noconstant(findstring(lf,check_blob))
   DECLARE length = i4 WITH private, noconstant(textlen(check_blob))
   DECLARE checkstring = vc WITH private, noconstant(fillstring(65535," "))
   SET checkstring = substring(1,(cr - 1),check_blob)
   DECLARE lfcheck = i4 WITH private, noconstant(findstring(check,checkstring))
   SET blob->cnt = 0
   IF (length=0)
    SET pt->line_cnt = 0
    SET stat = alterlist(pt->lns,0)
    SET stat = alterlist(blob->qual,0)
    RETURN
   ENDIF
   WHILE (cr > 0)
     SET blob->line = substring(1,(cr - 1),check_blob)
     SET check_blob = substring((cr+ 1),length,check_blob)
     IF (lfcheck > 0)
      SET check_blob = substring((cr+ 2),length,check_blob)
     ENDIF
     SET blob->cnt += 1
     SET stat = alterlist(blob->qual,blob->cnt)
     SET blob->qual[blob->cnt].line = trim(blob->line)
     SET blob->qual[blob->cnt].sze = textlen(trim(blob->line))
     SET cr = findstring(lf,check_blob)
     SET checkstring = substring(1,(cr - 1),check_blob)
     SET lfcheck = findstring(check,checkstring)
   ENDWHILE
   IF (trim(check_blob) != " ")
    SET blob->cnt += 1
    SET stat = alterlist(blob->qual,blob->cnt)
    SET blob->qual[blob->cnt].line = trim(check_blob)
    SET blob->qual[blob->cnt].sze = textlen(trim(check_blob))
   ENDIF
   FOR (j = 1 TO blob->cnt)
     WHILE ((blob->qual[j].sze > wrap_max_length))
       SET h = l
       SET c = wrap_max_length
       WHILE (c > 0)
        IF (substring(c,1,blob->qual[j].line) IN (" ", "-"))
         SET l += 1
         SET stat = alterlist(pt->lns,l)
         SET pt->lns[l].line = substring(1,c,blob->qual[j].line)
         SET blob->qual[j].line = substring((c+ 1),(blob->qual[j].sze - c),blob->qual[j].line)
         SET c = 1
        ENDIF
        SET c -= 1
       ENDWHILE
       IF (h=l)
        SET l += 1
        SET stat = alterlist(pt->lns,l)
        SET pt->lns[l].line = substring(1,wrap_max_length,blob->qual[j].line)
        SET blob->qual[j].line = substring((wrap_max_length+ 1),(blob->qual[j].sze - wrap_max_length),
         blob->qual[j].line)
       ENDIF
       SET blob->qual[j].sze = size(trim(blob->qual[j].line))
       SET wrap_max_length = wrap_sec_max_length
     ENDWHILE
     SET l += 1
     SET stat = alterlist(pt->lns,l)
     SET pt->lns[l].line = substring(1,blob->qual[j].sze,blob->qual[j].line)
     SET pt->line_cnt = l
     IF (l=1)
      SET wrap_max_length = wrap_sec_max_length
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE (medlist_refname_formatting(sect=i4,ctrl=i4,medlistindex=i4) =null)
  DECLARE x = i4 WITH private, noconstant(0)
  IF ((temp->sl[sect].il[ctrl].med_list[medlistindex].reference_name > ""))
   SET pt->line_cnt = 0
   CALL wrap_text(temp->sl[sect].il[ctrl].med_list[medlistindex].reference_name,(m_totalchar - 14),(
    m_totalchar - 14))
   SET stat = alterlist(temp->sl[sect].il[ctrl].med_list[medlistindex].name_lines,pt->line_cnt)
   FOR (x = 1 TO pt->line_cnt)
     SET temp->sl[sect].il[ctrl].med_list[medlistindex].name_lines[x].name_line = pt->lns[x].line
   ENDFOR
  ENDIF
 END ;Subroutine
 SUBROUTINE (medlist_comment_formatting(sect=i4,ctrl=i4,medlistindex=i4) =null)
   DECLARE long_txt = vc WITH protect, noconstant(fillstring(2000," "))
   DECLARE x = i4 WITH private, noconstant(0)
   IF ((temp->sl[sect].il[ctrl].med_list[medlistindex].comment > ""))
    SET pt->line_cnt = 0
    SET long_txt = build(captions->scomment,": ",temp->sl[sect].il[ctrl].med_list[medlistindex].
     comment)
    CALL wrap_text(long_txt,(m_totalchar - 20),(m_totalchar - 20))
    SET stat = alterlist(temp->sl[sect].il[ctrl].med_list[medlistindex].comment_lines,pt->line_cnt)
    FOR (x = 1 TO pt->line_cnt)
      SET temp->sl[sect].il[ctrl].med_list[medlistindex].comment_lines[x].comment_line = pt->lns[x].
      line
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE (medlist_displayln_formatting(sect=i4,ctrl=i4,medlistindex=i4) =null)
   DECLARE long_ln = vc WITH protect, noconstant(fillstring(2000," "))
   DECLARE x = i4 WITH private, noconstant(0)
   IF ((temp->sl[sect].il[ctrl].med_list[medlistindex].display_line > ""))
    SET pt->line_cnt = 0
    SET long_ln = build(captions->ssig,": ",temp->sl[sect].il[ctrl].med_list[medlistindex].
     display_line)
    CALL wrap_text(long_ln,(m_totalchar - 20),(m_totalchar - 20))
    SET stat = alterlist(temp->sl[sect].il[ctrl].med_list[medlistindex].display_lines,pt->line_cnt)
    FOR (x = 1 TO pt->line_cnt)
      SET temp->sl[sect].il[ctrl].med_list[medlistindex].display_lines[x].display_ln = pt->lns[x].
      line
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE (preg_data_str_formatting(sect=i4,ctrl=i4,pregindex=i4) =null)
   DECLARE long_str = vc WITH private, noconstant(fillstring(65535," "))
   DECLARE macomp_cnt = i4 WITH private, noconstant(0)
   DECLARE macomp_idx = i4 WITH private, noconstant(0)
   DECLARE fetcomp_cnt = i4 WITH private, noconstant(0)
   DECLARE fetcomp_idx = i4 WITH private, noconstant(0)
   DECLARE neocomp_cnt = i4 WITH private, noconstant(0)
   DECLARE neocomp_idx = i4 WITH private, noconstant(0)
   DECLARE prelabor_cnt = i4 WITH private, noconstant(0)
   DECLARE prelabor_idx = i4 WITH private, noconstant(0)
   DECLARE chldcnt = i4 WITH private, noconstant(0)
   DECLARE chldidx = i4 WITH private, noconstant(0)
   DECLARE x = i4 WITH private, noconstant(0)
   SET chldcnt = size(temp->sl[sect].il[ctrl].pregnancies[pregindex].child_list,5)
   FOR (chldidx = 1 TO chldcnt)
     SET long_str = ""
     IF (chldcnt > 1)
      SET long_str = build2("(",captions->sbaby)
      CASE (chldidx)
       OF 1:
        SET long_str = build2(long_str," A): ")
       OF 2:
        SET long_str = build2(long_str," B): ")
       OF 3:
        SET long_str = build2(long_str," C): ")
       OF 4:
        SET long_str = build2(long_str," D): ")
       OF 5:
        SET long_str = build2(long_str," E): ")
       OF 6:
        SET long_str = build2(long_str," F): ")
       OF 7:
        SET long_str = build2(long_str," G): ")
       OF 8:
        SET long_str = build2(long_str," H): ")
       OF 9:
        SET long_str = build2(long_str," I): ")
       OF 10:
        SET long_str = build2(long_str," J): ")
       OF 11:
        SET long_str = build2(long_str," K): ")
       OF 12:
        SET long_str = build2(long_str," L): ")
       OF 13:
        SET long_str = build2(long_str," M): ")
       OF 14:
        SET long_str = build2(long_str," N): ")
       OF 15:
        SET long_str = build2(long_str," O): ")
       OF 16:
        SET long_str = build2(long_str," P): ")
       OF 17:
        SET long_str = build2(long_str," Q): ")
       OF 18:
        SET long_str = build2(long_str," R): ")
       OF 19:
        SET long_str = build2(long_str," S): ")
       OF 20:
        SET long_str = build2(long_str," T): ")
       OF 21:
        SET long_str = build2(long_str," U): ")
       OF 22:
        SET long_str = build2(long_str," V): ")
       OF 23:
        SET long_str = build2(long_str," W): ")
       OF 24:
        SET long_str = build2(long_str," X): ")
       OF 25:
        SET long_str = build2(long_str," Y): ")
       OF 26:
        SET long_str = build2(long_str," Z): ")
       ELSE
        SET long_str = build2(long_str," ",captions->sanother,"): ")
      ENDCASE
     ENDIF
     IF ((temp->sl[sect].il[ctrl].pregnancies[pregindex].child_list[chldidx].gestation_age_in_weeks
      > 0))
      SET long_str = build2(long_str,trim(cnvtstring(temp->sl[sect].il[ctrl].pregnancies[pregindex].
         child_list[chldidx].gestation_age_in_weeks))," ",captions->sweeks)
     ENDIF
     IF ((temp->sl[sect].il[ctrl].pregnancies[pregindex].child_list[chldidx].gestation_age_in_days >
     0))
      IF ((temp->sl[sect].il[ctrl].pregnancies[pregindex].child_list[chldidx].gestation_age_in_weeks
       > 0))
       SET long_str = build2(long_str," ",trim(cnvtstring(temp->sl[sect].il[ctrl].pregnancies[
          pregindex].child_list[chldidx].gestation_age_in_days))," ",captions->sdays,
        "; ")
      ELSE
       SET long_str = build2(long_str,trim(cnvtstring(temp->sl[sect].il[ctrl].pregnancies[pregindex].
          child_list[chldidx].gestation_age_in_days))," ",captions->sdays,"; ")
      ENDIF
     ELSEIF ((temp->sl[sect].il[ctrl].pregnancies[pregindex].child_list[chldidx].gestation_term_txt
      > ""))
      SET long_str = build2(long_str,temp->sl[sect].il[ctrl].pregnancies[pregindex].child_list[
       chldidx].gestation_term_txt,"; ")
     ELSE
      IF ((temp->sl[sect].il[ctrl].pregnancies[pregindex].child_list[chldidx].gestation_age_in_weeks
       > 0))
       SET long_str = build2(long_str,"; ")
      ENDIF
     ENDIF
     IF ((temp->sl[sect].il[ctrl].pregnancies[pregindex].child_list[chldidx].delivery_method_disp >
     ""))
      SET long_str = build2(long_str,temp->sl[sect].il[ctrl].pregnancies[pregindex].child_list[
       chldidx].delivery_method_disp,"; ")
     ENDIF
     IF ((temp->sl[sect].il[ctrl].pregnancies[pregindex].child_list[chldidx].gender_disp > ""))
      SET long_str = build2(long_str,temp->sl[sect].il[ctrl].pregnancies[pregindex].child_list[
       chldidx].gender_disp,"; ")
     ENDIF
     IF ((temp->sl[sect].il[ctrl].pregnancies[pregindex].child_list[chldidx].birth_weight_disp > ""))
      SET long_str = build2(long_str,temp->sl[sect].il[ctrl].pregnancies[pregindex].child_list[
       chldidx].birth_weight_disp,";  ")
     ENDIF
     IF ((temp->sl[sect].il[ctrl].pregnancies[pregindex].child_list[chldidx].anesthesia_disp > ""))
      SET long_str = build2(long_str,captions->sanesthesia,": ",temp->sl[sect].il[ctrl].pregnancies[
       pregindex].child_list[chldidx].anesthesia_disp,";  ")
     ENDIF
     IF ((temp->sl[sect].il[ctrl].pregnancies[pregindex].child_list[chldidx].delivery_hospital > ""))
      SET long_str = build2(long_str,captions->sdeliveryhosp,": ",temp->sl[sect].il[ctrl].
       pregnancies[pregindex].child_list[chldidx].delivery_hospital,"; ")
     ENDIF
     SET prelabor_cnt = size(temp->sl[sect].il[ctrl].pregnancies[pregindex].child_list[chldidx].
      preterm_labors,5)
     IF (prelabor_cnt > 0)
      SET long_str = build2(long_str,captions->spretermlabor,": ")
      FOR (prelabor_idx = 1 TO prelabor_cnt)
        IF (prelabor_idx=prelabor_cnt)
         SET long_str = build2(long_str,temp->sl[sect].il[ctrl].pregnancies[pregindex].child_list[
          chldidx].preterm_labors[prelabor_idx].preterm_labor,"; ")
        ELSE
         SET long_str = build2(long_str,temp->sl[sect].il[ctrl].pregnancies[pregindex].child_list[
          chldidx].preterm_labors[prelabor_idx].preterm_labor,", ")
        ENDIF
      ENDFOR
     ENDIF
     SET macomp_cnt = size(temp->sl[sect].il[ctrl].pregnancies[pregindex].child_list[chldidx].
      ma_comp_list,5)
     IF (macomp_cnt > 0)
      SET long_str = build2(long_str,captions->smothercomp,": ")
      FOR (macomp_idx = 1 TO macomp_cnt)
        IF (macomp_idx=macomp_cnt)
         SET long_str = build2(long_str,temp->sl[sect].il[ctrl].pregnancies[pregindex].child_list[
          chldidx].ma_comp_list[macomp_idx].complication_disp,"; ")
        ELSE
         SET long_str = build2(long_str,temp->sl[sect].il[ctrl].pregnancies[pregindex].child_list[
          chldidx].ma_comp_list[macomp_idx].complication_disp,", ")
        ENDIF
      ENDFOR
     ELSE
      SET long_str = build2(long_str,captions->smothercomp,": ",captions->snone,"; ")
     ENDIF
     SET fetcomp_cnt = size(temp->sl[sect].il[ctrl].pregnancies[pregindex].child_list[chldidx].
      fetus_comp_list,5)
     IF (fetcomp_cnt > 0)
      SET long_str = build2(long_str,captions->sfetuscomp,": ")
      FOR (fetcomp_idx = 1 TO fetcomp_cnt)
        IF (fetcomp_idx=fetcomp_cnt)
         SET long_str = build2(long_str,temp->sl[sect].il[ctrl].pregnancies[pregindex].child_list[
          chldidx].fetus_comp_list[fetcomp_idx].complication_disp,"; ")
        ELSE
         SET long_str = build2(long_str,temp->sl[sect].il[ctrl].pregnancies[pregindex].child_list[
          chldidx].fetus_comp_list[fetcomp_idx].complication_disp,", ")
        ENDIF
      ENDFOR
     ELSE
      SET long_str = build2(long_str,captions->sfetuscomp,": ",captions->snone,"; ")
     ENDIF
     IF ((temp->sl[sect].il[ctrl].pregnancies[pregindex].child_list[chldidx].neonate_outcome_disp >
     ""))
      SET long_str = build2(long_str,captions->sneonataloutcome,": ",temp->sl[sect].il[ctrl].
       pregnancies[pregindex].child_list[chldidx].neonate_outcome_disp,"; ")
     ENDIF
     SET neocomp_cnt = size(temp->sl[sect].il[ctrl].pregnancies[pregindex].child_list[chldidx].
      neo_comp_list,5)
     IF (neocomp_cnt > 0)
      SET long_str = build2(long_str,captions->sneocomp,": ")
      FOR (neocomp_idx = 1 TO neocomp_cnt)
        IF (neocomp_idx=neocomp_cnt)
         SET long_str = concat(long_str,temp->sl[sect].il[ctrl].pregnancies[pregindex].child_list[
          chldidx].neo_comp_list[neocomp_idx].complication_disp,"; ")
        ELSE
         SET long_str = concat(long_str,temp->sl[sect].il[ctrl].pregnancies[pregindex].child_list[
          chldidx].neo_comp_list[neocomp_idx].complication_disp,", ")
        ENDIF
      ENDFOR
     ELSE
      SET long_str = build2(long_str,captions->sneocomp,": ",captions->snone,"; ")
     ENDIF
     IF ((temp->sl[sect].il[ctrl].pregnancies[pregindex].child_list[chldidx].child_name > ""))
      SET long_str = build2(long_str,captions->schildname,": ",temp->sl[sect].il[ctrl].pregnancies[
       pregindex].child_list[chldidx].child_name,"; ")
     ENDIF
     IF ((temp->sl[sect].il[ctrl].pregnancies[pregindex].child_list[chldidx].father_name > ""))
      SET long_str = build2(long_str,captions->sfathername,": ",temp->sl[sect].il[ctrl].pregnancies[
       pregindex].child_list[chldidx].father_name)
     ENDIF
     IF (( NOT (substring(1,1,long_str))=" "))
      SET pt->line_cnt = 0
      CALL wrap_text(long_str,(m_totalchar - 14),(m_totalchar - 14))
      SET stat = alterlist(temp->sl[sect].il[ctrl].pregnancies[pregindex].child_list[chldidx].
       data_str_lines,pt->line_cnt)
      FOR (x = 1 TO pt->line_cnt)
        SET temp->sl[sect].il[ctrl].pregnancies[pregindex].child_list[chldidx].data_str_lines[x].
        aline = pt->lns[x].line
      ENDFOR
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE (proc_term_formatting(sect=i4,ctrl=i4,procindex=i4) =null)
   DECLARE proc_str = vc WITH private, noconstant(fillstring(2000," "))
   DECLARE x = i4 WITH private, noconstant(0)
   SET proc_str = temp->sl[sect].il[ctrl].proc_list[procindex].proc_desc
   IF (trim(temp->sl[sect].il[ctrl].proc_list[procindex].voca_cd_meaning) > "")
    SET proc_str = build2(proc_str,"(",temp->sl[sect].il[ctrl].proc_list[procindex].voca_cd_meaning,
     "-",temp->sl[sect].il[ctrl].proc_list[procindex].source_identifier,
     ")")
   ENDIF
   SET pt->line_cnt = 0
   CALL wrap_text(proc_str,(m_totalchar - 8),(m_totalchar - 8))
   SET stat = alterlist(temp->sl[sect].il[ctrl].proc_list[procindex].proc_lines,pt->line_cnt)
   FOR (x = 1 TO pt->line_cnt)
     SET temp->sl[sect].il[ctrl].proc_list[procindex].proc_lines[x].proc_line = pt->lns[x].line
   ENDFOR
   DECLARE proc_perform = vc WITH private, noconstant(fillstring(2000," "))
   SET proc_perform = ""
   IF (trim(temp->sl[sect].il[ctrl].proc_list[procindex].proc_prsnl_name) > "")
    SET proc_perform = build2(temp->sl[sect].il[ctrl].proc_list[procindex].proc_prsnl_name)
   ENDIF
   IF ((temp->sl[sect].il[ctrl].proc_list[procindex].proc_year > 0))
    IF (trim(proc_perform) > "")
     SET proc_perform = build2(proc_perform,"/")
    ENDIF
    SET proc_perform = build2(proc_perform,trim(cnvtstring(temp->sl[sect].il[ctrl].proc_list[
       procindex].proc_year)))
   ENDIF
   IF (trim(temp->sl[sect].il[ctrl].proc_list[procindex].proc_location) > "")
    IF (trim(proc_perform) > "")
     SET proc_perform = build2(proc_perform,"/")
    ENDIF
    SET proc_perform = build2(proc_perform,temp->sl[sect].il[ctrl].proc_list[procindex].proc_location
     )
   ENDIF
   IF (trim(proc_perform) > "")
    SET proc_perform = build2(captions->sperformedby,": ",proc_perform)
    SET pt->line_cnt = 0
    CALL wrap_text(proc_perform,(m_totalchar - 8),(m_totalchar - 8))
    SET stat = alterlist(temp->sl[sect].il[ctrl].proc_list[procindex].perform_lines,pt->line_cnt)
    FOR (x = 1 TO pt->line_cnt)
      SET temp->sl[sect].il[ctrl].proc_list[procindex].perform_lines[x].aline = pt->lns[x].line
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE (proc_comment_formatting(sect=i4,ctrl=i4,procindex=i4) =null)
   DECLARE comt_cnt = i4 WITH private, noconstant(0)
   DECLARE comt_idx = i4 WITH private, noconstant(0)
   DECLARE x = i4 WITH private, noconstant(0)
   SET comt_cnt = size(temp->sl[sect].il[ctrl].proc_list[procindex].comments,5)
   FOR (comt_idx = 1 TO comt_cnt)
     SET pt->line_cnt = 0
     CALL wrap_text(temp->sl[sect].il[ctrl].proc_list[procindex].comments[comt_idx].comment,(
      m_totalchar - 20),(m_totalchar - 20))
     SET stat = alterlist(temp->sl[sect].il[ctrl].proc_list[procindex].comments[comt_idx].
      comment_lines,pt->line_cnt)
     FOR (x = 1 TO pt->line_cnt)
       SET temp->sl[sect].il[ctrl].proc_list[procindex].comments[comt_idx].comment_lines[x].
       comment_line = pt->lns[x].line
     ENDFOR
   ENDFOR
 END ;Subroutine
 SUBROUTINE (past_prob_formatting(sect=i4,ctrl=i4,probindex=i4) =null)
   DECLARE prob_str = vc WITH private, noconstant(fillstring(1000," "))
   DECLARE x = i4 WITH private, noconstant(0)
   SET pt->line_cnt = 0
   SET prob_str = build2(temp->sl[sect].il[ctrl].past_prob_list[probindex].prob_desc)
   IF ((temp->sl[sect].il[ctrl].past_prob_list[probindex].source_identifier > ""))
    SET prob_str = build2(prob_str," ( ",temp->sl[sect].il[ctrl].past_prob_list[probindex].
     voca_cd_meaning,": ",temp->sl[sect].il[ctrl].past_prob_list[probindex].source_identifier,
     " )")
   ENDIF
   CALL wrap_text(prob_str,(m_totalchar - 10),(m_totalchar - 10))
   SET stat = alterlist(temp->sl[sect].il[ctrl].past_prob_list[probindex].prob_lines,pt->line_cnt)
   FOR (x = 1 TO pt->line_cnt)
     SET temp->sl[sect].il[ctrl].past_prob_list[probindex].prob_lines[x].prob_line = pt->lns[x].line
   ENDFOR
 END ;Subroutine
 SUBROUTINE (past_prob_comment_formatting(sect=i4,ctrl=i4,probindex=i4) =null)
   DECLARE cmt_cnt = i4 WITH private, noconstant(0)
   DECLARE cmt_idx = i4 WITH private, noconstant(0)
   DECLARE x = i4 WITH private, noconstant(0)
   SET cmt_cnt = size(temp->sl[sect].il[ctrl].past_prob_list[probindex].comments,5)
   FOR (cmt_idx = 1 TO cmt_cnt)
     IF ((temp->sl[sect].il[ctrl].past_prob_list[probindex].comments[cmt_idx].comment > ""))
      SET pt->line_cnt = 0
      CALL wrap_text(temp->sl[sect].il[ctrl].past_prob_list[probindex].comments[cmt_idx].comment,(
       m_totalchar - 20),(m_totalchar - 20))
      SET stat = alterlist(temp->sl[sect].il[ctrl].past_prob_list[probindex].comments[cmt_idx].
       comment_lines,pt->line_cnt)
      FOR (x = 1 TO pt->line_cnt)
        SET temp->sl[sect].il[ctrl].past_prob_list[probindex].comments[cmt_idx].comment_lines[x].
        comment_line = pt->lns[x].line
      ENDFOR
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE (family_history_name_str_formatting(sect=i4,ctrl=i4,memidx=i4) =null)
   DECLARE name_str = vc WITH private, noconstant(fillstring(800," "))
   DECLARE x = i4 WITH private, noconstant(0)
   SET name_str = ""
   IF (trim(temp->sl[sect].il[ctrl].fam_members[memidx].reltn_disp) > "")
    SET name_str = build2(trim(temp->sl[sect].il[ctrl].fam_members[memidx].reltn_disp),": ")
   ENDIF
   IF (trim(temp->sl[sect].il[ctrl].fam_members[memidx].memb_name) > "")
    SET name_str = build2(name_str,trim(temp->sl[sect].il[ctrl].fam_members[memidx].memb_name))
   ENDIF
   IF ((temp->sl[sect].il[ctrl].fam_members[memidx].deceased_cd=deceased_cd_yes))
    SET name_str = build2(name_str," (",captions->sdeceased,") ")
   ELSE
    SET name_str = build2(name_str," (",captions->salive,") ")
   ENDIF
   IF (name_str > "")
    SET pt->line_cnt = 0
    CALL wrap_text(name_str,(m_totalchar - 12),(m_totalchar - 12))
    SET stat = alterlist(temp->sl[sect].il[ctrl].fam_members[memidx].name_lines,pt->line_cnt)
    FOR (x = 1 TO pt->line_cnt)
      SET temp->sl[sect].il[ctrl].fam_members[memidx].name_lines[x].aline = pt->lns[x].line
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE (family_history_condition_str_formatting(sect=i4,ctrl=i4,memidx=i4,conidx=i4) =null)
   DECLARE onset_str = vc WITH private, noconstant(fillstring(100," "))
   DECLARE x = i4 WITH private, noconstant(0)
   IF (trim(temp->sl[sect].il[ctrl].fam_members[memidx].conditions[conidx].source_string) > "")
    SET pt->line_cnt = 0
    CALL wrap_text(build(temp->sl[sect].il[ctrl].fam_members[memidx].conditions[conidx].source_string,
      ":"),(m_totalchar - 12),(m_totalchar - 12))
    SET stat = alterlist(temp->sl[sect].il[ctrl].fam_members[memidx].conditions[conidx].src_str_lines,
     pt->line_cnt)
    FOR (x = 1 TO pt->line_cnt)
      SET temp->sl[sect].il[ctrl].fam_members[memidx].conditions[conidx].src_str_lines[x].aline = pt
      ->lns[x].line
    ENDFOR
   ENDIF
   SET onset_str = ""
   IF ((temp->sl[sect].il[ctrl].fam_members[memidx].conditions[conidx].onset_age > 0))
    SET onset_str = build2(captions->sonsetage,": ",trim(cnvtstring(temp->sl[sect].il[ctrl].
       fam_members[memidx].conditions[conidx].onset_age))," ",temp->sl[sect].il[ctrl].fam_members[
     memidx].conditions[conidx].onset_age_unit_disp)
   ENDIF
   IF ((temp->sl[sect].il[ctrl].fam_members[memidx].conditions[conidx].onset_year > 0))
    SET onset_str = build2(captions->sonsetyear,": ",trim(cnvtstring(temp->sl[sect].il[ctrl].
       fam_members[memidx].conditions[conidx].onset_year)),"; ",onset_str)
   ENDIF
   IF (onset_str > "")
    SET pt->line_cnt = 0
    CALL wrap_text(onset_str,(m_totalchar - 10),(m_totalchar - 10))
    SET stat = alterlist(temp->sl[sect].il[ctrl].fam_members[memidx].conditions[conidx].onset_lines,
     pt->line_cnt)
    FOR (x = 1 TO pt->line_cnt)
      SET temp->sl[sect].il[ctrl].fam_members[memidx].conditions[conidx].onset_lines[x].aline = pt->
      lns[x].line
    ENDFOR
   ENDIF
   SET cmnt_cnt = size(temp->sl[sect].il[ctrl].fam_members[memidx].conditions[conidx].comments,5)
   FOR (cmnt_idx = 1 TO cmnt_cnt)
     IF (trim(temp->sl[sect].il[ctrl].fam_members[memidx].conditions[conidx].comments[cmnt_idx].
      comment) > "")
      SET pt->line_cnt = 0
      CALL wrap_text(temp->sl[sect].il[ctrl].fam_members[memidx].conditions[conidx].comments[cmnt_idx
       ].comment,(m_totalchar - 22),(m_totalchar - 22))
      SET stat = alterlist(temp->sl[sect].il[ctrl].fam_members[memidx].conditions[conidx].comments[
       cmnt_idx].comment_lines,pt->line_cnt)
      FOR (x = 1 TO pt->line_cnt)
        SET temp->sl[sect].il[ctrl].fam_members[memidx].conditions[conidx].comments[cmnt_idx].
        comment_lines[x].line = pt->lns[x].line
      ENDFOR
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE (social_data_str_formatting(sect=i4,ctrl=i4,socialindex=i4) =null)
   DECLARE tmpstr = vc WITH private, noconstant(fillstring(65000," "))
   DECLARE cntdet = i4 WITH private, noconstant(0)
   DECLARE idxdet = i4 WITH private, noconstant(0)
   DECLARE cntcmt = i4 WITH private, noconstant(0)
   DECLARE idxcmt = i4 WITH private, noconstant(0)
   DECLARE x = i4 WITH private, noconstant(0)
   SET tmpstr = ""
   SET tmpstr = temp->sl[sect].il[ctrl].social_cat_list[socialindex].desc
   IF (trim(tmpstr) > "")
    SET tmpstr = build2(tmpstr,": ")
   ENDIF
   IF (trim(temp->sl[sect].il[ctrl].social_cat_list[socialindex].assessment_disp) > "")
    SET tmpstr = build2(tmpstr,"(",temp->sl[sect].il[ctrl].social_cat_list[socialindex].
     assessment_disp,")")
   ENDIF
   IF (trim(tmpstr) > "")
    SET pt->line_cnt = 0
    CALL wrap_text(tmpstr,(m_totalchar - 10),(m_totalchar - 10))
    SET stat = alterlist(temp->sl[sect].il[ctrl].social_cat_list[socialindex].desc_lines,pt->line_cnt
     )
    FOR (x = 1 TO pt->line_cnt)
      SET temp->sl[sect].il[ctrl].social_cat_list[socialindex].desc_lines[x].desc_line = pt->lns[x].
      line
    ENDFOR
   ENDIF
   SET cntdet = size(temp->sl[sect].il[ctrl].social_cat_list[socialindex].detail_list,5)
   FOR (idxdet = 1 TO cntdet)
     SET tmpstr = ""
     IF (trim(temp->sl[sect].il[ctrl].social_cat_list[socialindex].detail_list[idxdet].detail_disp)
      > "")
      SET tmpstr = temp->sl[sect].il[ctrl].social_cat_list[socialindex].detail_list[idxdet].
      detail_disp
     ENDIF
     IF (((trim(temp->sl[sect].il[ctrl].social_cat_list[socialindex].detail_list[idxdet].
      detail_updt_dt_tm) > "") OR (trim(temp->sl[sect].il[ctrl].social_cat_list[socialindex].
      detail_list[idxdet].detail_updt_prsnl) > "")) )
      SET tmpstr = build2(tmpstr,"(",captions->slastupdated,": ",trim(temp->sl[sect].il[ctrl].
        social_cat_list[socialindex].detail_list[idxdet].detail_updt_dt_tm),
       "  ",captions->sby,"  ",trim(temp->sl[sect].il[ctrl].social_cat_list[socialindex].detail_list[
        idxdet].detail_updt_prsnl),")")
     ENDIF
     IF (trim(tmpstr) > "")
      SET pt->line_cnt = 0
      CALL wrap_text(tmpstr,(m_totalchar - 16),(m_totalchar - 16))
      SET stat = alterlist(temp->sl[sect].il[ctrl].social_cat_list[socialindex].detail_list[idxdet].
       disp_lines,pt->line_cnt)
      FOR (x = 1 TO pt->line_cnt)
        SET temp->sl[sect].il[ctrl].social_cat_list[socialindex].detail_list[idxdet].disp_lines[x].
        aline = pt->lns[x].line
      ENDFOR
     ENDIF
   ENDFOR
   FOR (idxdet = 1 TO cntdet)
    SET cntcmt = size(temp->sl[sect].il[ctrl].social_cat_list[socialindex].detail_list[idxdet].
     comments,5)
    FOR (idxcmt = 1 TO cntcmt)
      SET pt->line_cnt = 0
      SET tmpstr = ""
      SET tmpstr = temp->sl[sect].il[ctrl].social_cat_list[socialindex].detail_list[idxdet].comments[
      idxcmt].comment
      IF (((trim(temp->sl[sect].il[ctrl].social_cat_list[socialindex].detail_list[idxdet].comments[
       idxcmt].comment_dt_tm) > "") OR (trim(temp->sl[sect].il[ctrl].social_cat_list[socialindex].
       detail_list[idxdet].comments[idxcmt].comment_prsnl) > "")) )
       SET tmpstr = build2(temp->sl[sect].il[ctrl].social_cat_list[socialindex].detail_list[idxdet].
        comments[idxcmt].comment_dt_tm," - ",temp->sl[sect].il[ctrl].social_cat_list[socialindex].
        detail_list[idxdet].comments[idxcmt].comment_prsnl,": ",tmpstr)
      ENDIF
      CALL wrap_text(tmpstr,(m_totalchar - 20),(m_totalchar - 20))
      SET stat = alterlist(temp->sl[sect].il[ctrl].social_cat_list[socialindex].detail_list[idxdet].
       comments[idxcmt].comment_lines,pt->line_cnt)
      FOR (x = 1 TO pt->line_cnt)
        SET temp->sl[sect].il[ctrl].social_cat_list[socialindex].detail_list[idxdet].comments[idxcmt]
        .comment_lines[x].aline = pt->lns[x].line
      ENDFOR
    ENDFOR
   ENDFOR
 END ;Subroutine
 SUBROUTINE (communication_preference_str_formatting(sect=i4,ctrl=i4,commprefindex=i4) =null)
   DECLARE no_pref_contact_method_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",23042,
     "NOPREFERENCE"))
   DECLARE letter_contact_method_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",23042,
     "LETTER"))
   DECLARE telephone_contact_method_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",23042,
     "TELEPHONE"))
   DECLARE patient_portal_contact_method_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",
     23042,"PATPORTAL"))
   DECLARE email_contact_method_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",23042,
     "EMAIL"))
   DECLARE tmpstr = vc WITH private, noconstant(fillstring(65000," "))
   DECLARE tmpemail = vc WITH private, noconstant(fillstring(255," "))
   DECLARE label_length = i4 WITH private, constant(size(captions->scommunicationmethod))
   DECLARE x = i4 WITH private, noconstant(0)
   IF ((temp->sl[sect].il[ctrl].comm_pref_list[commprefindex].contact_method_cd=
   no_pref_contact_method_cd))
    SET tmpstr = captions->scommnopreference
   ELSEIF ((temp->sl[sect].il[ctrl].comm_pref_list[commprefindex].contact_method_cd=
   letter_contact_method_cd))
    SET tmpstr = captions->scommsendletter
   ELSEIF ((temp->sl[sect].il[ctrl].comm_pref_list[commprefindex].contact_method_cd=
   telephone_contact_method_cd))
    SET tmpstr = captions->scommphonecall
   ELSEIF ((temp->sl[sect].il[ctrl].comm_pref_list[commprefindex].contact_method_cd=
   patient_portal_contact_method_cd))
    SET tmpstr = captions->scommpatientportal
   ELSEIF ((temp->sl[sect].il[ctrl].comm_pref_list[commprefindex].contact_method_cd=
   email_contact_method_cd))
    SET tmpemail = ""
    SET tmpemail = trim(temp->sl[sect].il[ctrl].comm_pref_list[commprefindex].secure_email)
    SET tmpstr = trim(uar_i18nbuildmessage(i18nhandle,"SECUREEMAIL",nullterm(captions->
       scommsecureemail),"s",nullterm(tmpemail)))
   ELSE
    SET tmpstr = ""
   ENDIF
   IF (trim(tmpstr) > "")
    SET temp->sl[sect].il[ctrl].comm_pref_list[commprefindex].desc = tmpstr
    SET pt->line_cnt = 0
    CALL wrap_text(tmpstr,(m_totalchar - 50),(m_totalchar - 5))
    SET stat = alterlist(temp->sl[sect].il[ctrl].comm_pref_list[commprefindex].desc_lines,pt->
     line_cnt)
    FOR (x = 1 TO pt->line_cnt)
      SET temp->sl[sect].il[ctrl].comm_pref_list[commprefindex].desc_lines[x].desc_line = pt->lns[x].
      line
    ENDFOR
   ENDIF
 END ;Subroutine
 DECLARE loadpregnancyorganizationsecuritylist() = null
 IF (validate(preg_org_sec_ind)=0)
  DECLARE preg_org_sec_ind = i4 WITH noconstant(0)
  SELECT INTO "nl:"
   FROM dm_info d1,
    dm_info d2
   WHERE d1.info_domain="SECURITY"
    AND d1.info_name="SEC_ORG_RELTN"
    AND d1.info_number=1
    AND d2.info_domain="SECURITY"
    AND d2.info_name="SEC_PREG_ORG_RELTN"
    AND d2.info_number=1
   DETAIL
    preg_org_sec_ind = 1
   WITH nocounter
  ;end select
  CALL echo(build("preg_org_sec_ind=",preg_org_sec_ind))
  IF (preg_org_sec_ind=1)
   FREE RECORD preg_sec_orgs
   RECORD preg_sec_orgs(
     1 qual[*]
       2 org_id = f8
       2 confid_level = i4
   )
   CALL loadpregnancyorganizationsecuritylist(null)
  ENDIF
 ENDIF
 SUBROUTINE loadpregnancyorganizationsecuritylist(null)
   DECLARE org_cnt = i2 WITH noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (validate(sac_org)=1)
    FREE RECORD sac_org
   ENDIF
   IF (validate(_sacrtl_org_inc_,99999)=99999)
    DECLARE _sacrtl_org_inc_ = i2 WITH constant(1)
    RECORD sac_org(
      1 organizations[*]
        2 organization_id = f8
        2 confid_cd = f8
        2 confid_level = i4
    )
    EXECUTE secrtl
    EXECUTE sacrtl
    DECLARE orgcnt = i4 WITH protected, noconstant(0)
    DECLARE secstat = i2
    DECLARE logontype = i4 WITH protect, noconstant(- (1))
    DECLARE dynamic_org_ind = i4 WITH protect, noconstant(- (1))
    DECLARE dcur_trustid = f8 WITH protect, noconstant(0.0)
    DECLARE dynorg_enabled = i4 WITH constant(1)
    DECLARE dynorg_disabled = i4 WITH constant(0)
    DECLARE logontype_nhs = i4 WITH constant(1)
    DECLARE logontype_legacy = i4 WITH constant(0)
    DECLARE confid_cnt = i4 WITH protected, noconstant(0)
    RECORD confid_codes(
      1 list[*]
        2 code_value = f8
        2 coll_seq = f8
    )
    CALL uar_secgetclientlogontype(logontype)
    CALL echo(build("logontype:",logontype))
    IF (logontype != logontype_nhs)
     SET dynamic_org_ind = dynorg_disabled
    ENDIF
    IF (logontype=logontype_nhs)
     SUBROUTINE (getdynamicorgpref(dtrustid=f8) =i4)
       DECLARE scur_trust = vc
       DECLARE pref_val = vc
       DECLARE is_enabled = i4 WITH constant(1)
       DECLARE is_disabled = i4 WITH constant(0)
       SET scur_trust = cnvtstring(dtrustid)
       SET scur_trust = concat(scur_trust,".00")
       IF ( NOT (validate(pref_req,0)))
        RECORD pref_req(
          1 write_ind = i2
          1 delete_ind = i2
          1 pref[*]
            2 contexts[*]
              3 context = vc
              3 context_id = vc
            2 section = vc
            2 section_id = vc
            2 subgroup = vc
            2 entries[*]
              3 entry = vc
              3 values[*]
                4 value = vc
        )
       ENDIF
       IF ( NOT (validate(pref_rep,0)))
        RECORD pref_rep(
          1 pref[*]
            2 section = vc
            2 section_id = vc
            2 subgroup = vc
            2 entries[*]
              3 pref_exists_ind = i2
              3 entry = vc
              3 values[*]
                4 value = vc
          1 status_data
            2 status = c1
            2 subeventstatus[1]
              3 operationname = c25
              3 operationstatus = c1
              3 targetobjectname = c25
              3 targetobjectvalue = vc
        )
       ENDIF
       SET stat = alterlist(pref_req->pref,1)
       SET stat = alterlist(pref_req->pref[1].contexts,2)
       SET stat = alterlist(pref_req->pref[1].entries,1)
       SET pref_req->pref[1].contexts[1].context = "organization"
       SET pref_req->pref[1].contexts[1].context_id = scur_trust
       SET pref_req->pref[1].contexts[2].context = "default"
       SET pref_req->pref[1].contexts[2].context_id = "system"
       SET pref_req->pref[1].section = "workflow"
       SET pref_req->pref[1].section_id = "UK Trust Security"
       SET pref_req->pref[1].entries[1].entry = "dynamic organizations"
       EXECUTE ppr_preferences  WITH replace("REQUEST","PREF_REQ"), replace("REPLY","PREF_REP")
       IF (cnvtupper(pref_rep->pref[1].entries[1].values[1].value)="ENABLED")
        RETURN(is_enabled)
       ELSE
        RETURN(is_disabled)
       ENDIF
     END ;Subroutine
     DECLARE hprop = i4 WITH protect, noconstant(0)
     DECLARE tmpstat = i2
     DECLARE spropname = vc
     DECLARE sroleprofile = vc
     SET hprop = uar_srvcreateproperty()
     SET tmpstat = uar_secgetclientattributesext(5,hprop)
     SET spropname = uar_srvfirstproperty(hprop)
     SET sroleprofile = uar_srvgetpropertyptr(hprop,nullterm(spropname))
     SELECT INTO "nl:"
      FROM prsnl_org_reltn_type prt,
       prsnl_org_reltn por
      PLAN (prt
       WHERE prt.role_profile=sroleprofile
        AND prt.active_ind=1
        AND prt.beg_effective_dt_tm <= cnvtdatetime(sysdate)
        AND prt.end_effective_dt_tm > cnvtdatetime(sysdate))
       JOIN (por
       WHERE (por.organization_id= Outerjoin(prt.organization_id))
        AND (por.person_id= Outerjoin(prt.prsnl_id))
        AND (por.active_ind= Outerjoin(1))
        AND (por.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(sysdate)))
        AND (por.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
      ORDER BY por.prsnl_org_reltn_id
      DETAIL
       orgcnt = 1, secstat = alterlist(sac_org->organizations,1), user_person_id = prt.prsnl_id,
       sac_org->organizations[1].organization_id = prt.organization_id, sac_org->organizations[1].
       confid_cd = por.confid_level_cd, confid_cd = uar_get_collation_seq(por.confid_level_cd),
       sac_org->organizations[1].confid_level =
       IF (confid_cd > 0) confid_cd
       ELSE 0
       ENDIF
      WITH maxrec = 1
     ;end select
     SET dcur_trustid = sac_org->organizations[1].organization_id
     SET dynamic_org_ind = getdynamicorgpref(dcur_trustid)
     CALL uar_srvdestroyhandle(hprop)
    ENDIF
    IF (dynamic_org_ind=dynorg_disabled)
     SET confid_cnt = 0
     SELECT INTO "NL:"
      c.code_value, c.collation_seq
      FROM code_value c
      WHERE c.code_set=87
      DETAIL
       confid_cnt += 1
       IF (mod(confid_cnt,10)=1)
        secstat = alterlist(confid_codes->list,(confid_cnt+ 9))
       ENDIF
       confid_codes->list[confid_cnt].code_value = c.code_value, confid_codes->list[confid_cnt].
       coll_seq = c.collation_seq
      WITH nocounter
     ;end select
     SET secstat = alterlist(confid_codes->list,confid_cnt)
     SELECT DISTINCT INTO "nl:"
      FROM prsnl_org_reltn por
      WHERE (por.person_id=reqinfo->updt_id)
       AND por.active_ind=1
       AND por.beg_effective_dt_tm < cnvtdatetime(sysdate)
       AND por.end_effective_dt_tm >= cnvtdatetime(sysdate)
      HEAD REPORT
       IF (orgcnt > 0)
        secstat = alterlist(sac_org->organizations,100)
       ENDIF
      DETAIL
       orgcnt += 1
       IF (mod(orgcnt,100)=1)
        secstat = alterlist(sac_org->organizations,(orgcnt+ 99))
       ENDIF
       sac_org->organizations[orgcnt].organization_id = por.organization_id, sac_org->organizations[
       orgcnt].confid_cd = por.confid_level_cd
      FOOT REPORT
       secstat = alterlist(sac_org->organizations,orgcnt)
      WITH nocounter
     ;end select
     SELECT INTO "NL:"
      FROM (dummyt d1  WITH seq = value(orgcnt)),
       (dummyt d2  WITH seq = value(confid_cnt))
      PLAN (d1)
       JOIN (d2
       WHERE (sac_org->organizations[d1.seq].confid_cd=confid_codes->list[d2.seq].code_value))
      DETAIL
       sac_org->organizations[d1.seq].confid_level = confid_codes->list[d2.seq].coll_seq
      WITH nocounter
     ;end select
    ELSEIF (dynamic_org_ind=dynorg_enabled)
     DECLARE nhstrustchild_org_org_reltn_cd = f8
     SET nhstrustchild_org_org_reltn_cd = uar_get_code_by("MEANING",369,"NHSTRUSTCHLD")
     SELECT INTO "nl:"
      FROM org_org_reltn oor
      PLAN (oor
       WHERE oor.organization_id=dcur_trustid
        AND oor.active_ind=1
        AND oor.beg_effective_dt_tm < cnvtdatetime(sysdate)
        AND oor.end_effective_dt_tm >= cnvtdatetime(sysdate)
        AND oor.org_org_reltn_cd=nhstrustchild_org_org_reltn_cd)
      HEAD REPORT
       IF (orgcnt > 0)
        secstat = alterlist(sac_org->organizations,10)
       ENDIF
      DETAIL
       IF (oor.related_org_id > 0)
        orgcnt += 1
        IF (mod(orgcnt,10)=1)
         secstat = alterlist(sac_org->organizations,(orgcnt+ 9))
        ENDIF
        sac_org->organizations[orgcnt].organization_id = oor.related_org_id
       ENDIF
      FOOT REPORT
       secstat = alterlist(sac_org->organizations,orgcnt)
      WITH nocounter
     ;end select
    ELSE
     CALL echo(build("Unexpected login type: ",dynamimc_org_ind))
    ENDIF
   ENDIF
   SET org_cnt = size(sac_org->organizations,5)
   CALL echo(build("org_cnt: ",org_cnt))
   SET stat = alterlist(preg_sec_orgs->qual,(org_cnt+ 1))
   FOR (count = 1 TO org_cnt)
    SET preg_sec_orgs->qual[count].org_id = sac_org->organizations[count].organization_id
    SET preg_sec_orgs->qual[count].confid_level = sac_org->organizations[count].confid_level
   ENDFOR
   SET preg_sec_orgs->qual[(org_cnt+ 1)].org_id = 0.00
   SET preg_sec_orgs->qual[(org_cnt+ 1)].confid_level = 0
 END ;Subroutine
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
 SET rtnhandle = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 RECORD captions(
   1 scomment = vc
   1 scurrent = vc
   1 sedd = vc
   1 sega = vc
   1 sprintdatetime = vc
   1 sstatus = vc
   1 syears = vc
   1 sweeks = vc
   1 sdays = vc
   1 smethod = vc
   1 sconfirmation = vc
   1 sdate = vc
   1 sdocby = vc
   1 seddheader = vc
   1 spregheader = vc
   1 smethoddate = vc
   1 sentereddate = vc
   1 sheadcirc = vc
   1 sbiparietal = vc
   1 scrownrump = vc
   1 snormal = vc
   1 sabnormal = vc
   1 sdateapprox = vc
   1 sdatedef = vc
   1 sdateunknown = vc
   1 sdescription = vc
   1 scm = vc
   1 sadditionaldetails = vc
   1 sagemenarche = vc
   1 smensesfreq = vc
   1 sdatepriormenses = vc
   1 sdatehomepregtest = vc
   1 slmpsymptoms = vc
   1 sgravida = vc
   1 sparapremature = vc
   1 sparafullterm = vc
   1 spara = vc
   1 sabortions = vc
   1 sspontaneous = vc
   1 sinduced = vc
   1 sectopic = vc
   1 sparaliving = vc
   1 smultiplebirths = vc
   1 slivingcomment = vc
   1 sdeliverydate = vc
   1 scloseddate = vc
   1 sautocloseddate = vc
   1 ssensitive = vc
   1 smothercomp = vc
   1 sfetuscomp = vc
   1 sneonatecomp = vc
   1 sneonateoutcome = vc
   1 sfather = vc
   1 sdeliveryhospital = vc
   1 schildname = vc
   1 spretermlabor = vc
   1 sanesthesia = vc
   1 slaborduration = vc
   1 sminutes = vc
   1 sbefore = vc
   1 safter = vc
   1 sabout = vc
   1 sweeksatdelivery = vc
   1 aeddstatuses[5]
     2 seddstatus = vc
   1 ababylabels[10]
     2 sbabylabel = vc
   1 smodby = vc
   1 smoddate = vc
   1 sorganization = vc
   1 smodon = vc
   1 sdeletedon = vc
   1 sdeletedby = vc
   1 segaonmethoddate = vc
 )
 SUBROUTINE fillcaptions(dummyvar)
   SET captions->scomment = trim(uar_i18ngetmessage(i18nhandle,"COMMENT","Comment:"))
   SET captions->aeddstatuses[1].seddstatus = trim(uar_i18ngetmessage(i18nhandle,"NONAUTHORITATIVE",
     "Non-Authoritative"))
   SET captions->aeddstatuses[2].seddstatus = trim(uar_i18ngetmessage(i18nhandle,"INITIAL","Initial")
    )
   SET captions->aeddstatuses[3].seddstatus = trim(uar_i18ngetmessage(i18nhandle,"AUTHORITATIVE",
     "Authoritative"))
   SET captions->aeddstatuses[4].seddstatus = trim(uar_i18ngetmessage(i18nhandle,"FINAL","Final"))
   SET captions->aeddstatuses[5].seddstatus = trim(uar_i18ngetmessage(i18nhandle,"INITIALFINAL",
     "Initial/Final"))
   SET captions->scurrent = trim(uar_i18ngetmessage(i18nhandle,"CURRENT","Current:"))
   SET captions->sedd = trim(uar_i18ngetmessage(i18nhandle,"EDD","EDD"))
   SET captions->sega = trim(uar_i18ngetmessage(i18nhandle,"EGA","EGA"))
   SET captions->sprintdatetime = trim(uar_i18ngetmessage(i18nhandle,"PRINTDATETIME",
     "Print Date/Time:"))
   SET captions->sstatus = trim(uar_i18ngetmessage(i18nhandle,"STATUS","Status:"))
   SET captions->syears = trim(uar_i18ngetmessage(i18nhandle,"YEARS","years"))
   SET captions->sweeks = trim(uar_i18ngetmessage(i18nhandle,"WEEKS","weeks"))
   SET captions->sdays = trim(uar_i18ngetmessage(i18nhandle,"DAYS","Days"))
   SET captions->smethod = trim(uar_i18ngetmessage(i18nhandle,"METHOD","Method:"))
   SET captions->sconfirmation = trim(uar_i18ngetmessage(i18nhandle,"CONFIRMATION","Confirmation:"))
   SET captions->sdate = trim(uar_i18ngetmessage(i18nhandle,"DATE","Date:"))
   SET captions->sdocby = trim(uar_i18ngetmessage(i18nhandle,"DOCUMENTEDBY","Documented By:"))
   SET captions->seddheader = trim(uar_i18ngetmessage(i18nhandle,"EDDHEADER","EDD/EGA Information:"))
   SET captions->spregheader = trim(uar_i18ngetmessage(i18nhandle,"PREGHEADER",
     "Pregnancy History and EDD/EGA Information:"))
   SET captions->smethoddate = trim(uar_i18ngetmessage(i18nhandle,"METHODDATE","Date of Method:"))
   SET captions->sheadcirc = trim(uar_i18ngetmessage(i18nhandle,"HEADCIRC","Head Circumference:"))
   SET captions->sbiparietal = trim(uar_i18ngetmessage(i18nhandle,"BIPARIETAL","Biparietal Diameter:"
     ))
   SET captions->scrownrump = trim(uar_i18ngetmessage(i18nhandle,"CROWNRUMP","Crown Rump Length:"))
   SET captions->snormal = trim(uar_i18ngetmessage(i18nhandle,"NORMAL","Normal Amount/Duration"))
   SET captions->sabnormal = trim(uar_i18ngetmessage(i18nhandle,"ABNORMAL","Abnormal Amount/Duration"
     ))
   SET captions->sdateapprox = trim(uar_i18ngetmessage(i18nhandle,"DATEAPPROX","Date Approximate"))
   SET captions->sdatedef = trim(uar_i18ngetmessage(i18nhandle,"DATEDEFINITE","Date Definite"))
   SET captions->sdateunknown = trim(uar_i18ngetmessage(i18nhandle,"DATEUNKNOWN","Date Unknown"))
   SET captions->sdescription = trim(uar_i18ngetmessage(i18nhandle,"DESCRIPTION","Description:"))
   SET captions->scm = trim(uar_i18ngetmessage(i18nhandle,"CM","cm"))
   SET captions->sadditionaldetails = trim(uar_i18ngetmessage(i18nhandle,"ADDITIONALDETAILS",
     "Additional Details:"))
   SET captions->sagemenarche = trim(uar_i18ngetmessage(i18nhandle,"AGEMENARCHE",
     "Age of Menarche Onset:"))
   SET captions->smensesfreq = trim(uar_i18ngetmessage(i18nhandle,"MENSESFREQ",
     "Frequency of Menstruation:"))
   SET captions->sdatepriormenses = trim(uar_i18ngetmessage(i18nhandle,"DATEPRIORMENSES",
     "Date of Menses Prior to LMP:"))
   SET captions->sdatehomepregtest = trim(uar_i18ngetmessage(i18nhandle,"DATEHOMEPREGTEST",
     "Date of Home Pregnancy Test:"))
   SET captions->slmpsymptoms = trim(uar_i18ngetmessage(i18nhandle,"LMP Symptoms",
     "Symptoms since LMP:"))
   SET captions->sgravida = trim(uar_i18ngetmessage(i18nhandle,"GRAVIDA","Gravida - "))
   SET captions->sparapremature = trim(uar_i18ngetmessage(i18nhandle,"PARAPREMATURE",
     "Para Premature - "))
   SET captions->sparafullterm = trim(uar_i18ngetmessage(i18nhandle,"PARAFULLTERM","Para Fullterm - "
     ))
   SET captions->spara = trim(uar_i18ngetmessage(i18nhandle,"PARA","Para - "))
   SET captions->sabortions = trim(uar_i18ngetmessage(i18nhandle,"ABORTIONS","Abortions - "))
   SET captions->sspontaneous = trim(uar_i18ngetmessage(i18nhandle,"SPONTANEOUS",
     "Spontaneous Abortions - "))
   SET captions->sinduced = trim(uar_i18ngetmessage(i18nhandle,"INDUCED","Induced Abortions - "))
   SET captions->sparaliving = trim(uar_i18ngetmessage(i18nhandle,"PARALIVING","Para Living - "))
   SET captions->sectopic = trim(uar_i18ngetmessage(i18nhandle,"ECTOPIC","Ectopic - "))
   SET captions->smultiplebirths = trim(uar_i18ngetmessage(i18nhandle,"MULTIPLEBIRTHS",
     "Multiple Births - "))
   SET captions->slivingcomment = trim(uar_i18ngetmessage(i18nhandle,"LIVINGCOMMENT",
     "Child Living Comment:"))
   SET captions->ababylabels[1].sbabylabel = trim(uar_i18ngetmessage(i18nhandle,"BABYA","(Baby A)"))
   SET captions->ababylabels[2].sbabylabel = trim(uar_i18ngetmessage(i18nhandle,"BABYB","(Baby B)"))
   SET captions->ababylabels[3].sbabylabel = trim(uar_i18ngetmessage(i18nhandle,"BABYC","(Baby C)"))
   SET captions->ababylabels[4].sbabylabel = trim(uar_i18ngetmessage(i18nhandle,"BABYD","(Baby D)"))
   SET captions->ababylabels[5].sbabylabel = trim(uar_i18ngetmessage(i18nhandle,"BABYE","(Baby E)"))
   SET captions->ababylabels[6].sbabylabel = trim(uar_i18ngetmessage(i18nhandle,"BABYF","(Baby F)"))
   SET captions->ababylabels[7].sbabylabel = trim(uar_i18ngetmessage(i18nhandle,"BABYG","(Baby G)"))
   SET captions->ababylabels[8].sbabylabel = trim(uar_i18ngetmessage(i18nhandle,"BABYH","(Baby H)"))
   SET captions->ababylabels[9].sbabylabel = trim(uar_i18ngetmessage(i18nhandle,"BABYI","(Baby I)"))
   SET captions->ababylabels[10].sbabylabel = trim(uar_i18ngetmessage(i18nhandle,"BABYJ","(Baby J)"))
   SET captions->sdeliverydate = trim(uar_i18ngetmessage(i18nhandle,"DELIVERYDATE",
     "Delivery/Outcome Date:"))
   SET captions->scloseddate = trim(uar_i18ngetmessage(i18nhandle,"CLOSEDPREGNANCY",
     "Closed Pregnancy:"))
   SET captions->sautocloseddate = trim(uar_i18ngetmessage(i18nhandle,"CLOSEDPREGNANCY",
     "Closed Pregnancy (AUTO-CLOSED):"))
   SET captions->ssensitive = trim(uar_i18ngetmessage(i18nhandle,"Sensitive","(Sensitive)"))
   SET captions->smothercomp = trim(uar_i18ngetmessage(i18nhandle,"MOTHERCOMP",
     "Maternal Complications:"))
   SET captions->sfetuscomp = trim(uar_i18ngetmessage(i18nhandle,"FETUSCOMP","Fetus Complications:"))
   SET captions->sneonatecomp = trim(uar_i18ngetmessage(i18nhandle,"NEONATECOMP",
     "Neonatal Complications:"))
   SET captions->sneonateoutcome = trim(uar_i18ngetmessage(i18nhandle,"NEONATEOUTCOME",
     "Neonatal Outcome:"))
   SET captions->sfather = trim(uar_i18ngetmessage(i18nhandle,"FATHER","Father's Name:"))
   SET captions->sdeliveryhospital = trim(uar_i18ngetmessage(i18nhandle,"Delivery Hosptial",
     "Delivery Hospital:"))
   SET captions->schildname = trim(uar_i18ngetmessage(i18nhandle,"CHILDNAME","Child's Name:"))
   SET captions->spretermlabor = trim(uar_i18ngetmessage(i18nhandle,"PRETERMLABOR","Preterm Labor:"))
   SET captions->sanesthesia = trim(uar_i18ngetmessage(i18nhandle,"ANESTHESIA","Anesthesia:"))
   SET captions->slaborduration = trim(uar_i18ngetmessage(i18nhandle,"LABORDURATION",
     "Labor Duration:"))
   SET captions->sminutes = trim(uar_i18ngetmessage(i18nhandle,"MINUTES","minutes"))
   SET captions->sentereddate = trim(uar_i18ngetmessage(i18nhandle,"ENTEREDDATE","Entered Date:"))
   SET captions->sbefore = trim(uar_i18ngetmessage(i18nhandle,"BEFORE","Before"))
   SET captions->safter = trim(uar_i18ngetmessage(i18nhandle,"AFTER","After"))
   SET captions->sabout = trim(uar_i18ngetmessage(i18nhandle,"ABOUT","About"))
   SET captions->sweeksatdelivery = trim(uar_i18ngetmessage(i18nhandle,"WEEKSATDELIVERY",
     "at delivery/outcome"))
   SET captions->smodby = trim(uar_i18ngetmessage(i18nhandle,"MODIFIEDBY","Modified By:"))
   SET captions->smoddate = trim(uar_i18ngetmessage(i18nhandle,"MODIFIEDDATE","Modified Date:"))
   SET captions->sorganization = trim(uar_i18ngetmessage(i18nhandle,"ORGANIZATION","Organization:"))
   SET captions->smodon = trim(uar_i18ngetmessage(i18nhandle,"MODIFIEDON","Modified On:"))
   SET captions->sdeletedon = trim(uar_i18ngetmessage(i18nhandle,"DELETEDON","Deleted On:"))
   SET captions->sdeletedby = trim(uar_i18ngetmessage(i18nhandle,"DELETEDBY","Deleted By:"))
   SET captions->segaonmethoddate = trim(uar_i18ngetmessage(i18nhandle,"EGAONMETHODDATE",
     "EGA on Method Date"))
 END ;Subroutine
 CALL fillcaptions(dummy_void)
 DECLARE loadcurrentega(null) = null
 DECLARE loadeddorgs(null) = null
 DECLARE loadgravida(null) = null
 DECLARE savephxdates(null) = null
 DECLARE savephxversionsdates(null) = null
 DECLARE addentitytext(null) = null
 DECLARE buildgravidatext(null) = null
 DECLARE loadeddprsnl(null) = null
 DECLARE loadhxprsnl(null) = null
 DECLARE buildphxtext(null) = null
 DECLARE buildegatext(null) = null
 DECLARE loadhxpregnancyedds(null) = null
 FREE RECORD flatpregs
 RECORD flatpregs(
   1 children[*]
     2 pregnancy_id = f8
     2 pregnancy_instance_id = f8
     2 pregnancy_child_id = f8
     2 inst_prsnl_id = f8
     2 inst_prsnl_disp = vc
     2 inst_dt_tm_disp = vc
     2 child_label = vc
     2 sensitive_ind = i2
     2 gender_cd = f8
     2 child_name = vc
     2 father_name = vc
     2 delivery_method_cd = f8
     2 delivery_hospital = vc
     2 gestation_age = i4
     2 labor_duration = i4
     2 weight_amt = f8
     2 weight_unit_cd = f8
     2 anesthesia_txt = vc
     2 preterm_labor_txt = vc
     2 delivery_dt_tm_sort = dq8
     2 delivery_dt_precision = i2
     2 delivery_dt_tm_disp = vc
     2 neonate_outcome_cd = f8
     2 child_comment = vc
     2 instance_status = i2
     2 anesthesia[*]
       3 anesthesia_type = vc
     2 preterm_labor[*]
       3 preterm_item = vc
     2 fetal_complications[*]
       3 fetal_comp = vc
     2 mother_complications[*]
       3 mother_comp = vc
     2 neonate_complications[*]
       3 neonate_comp = vc
     2 auto_closed_ind = i2
     2 gestation_term_txt = vc
 )
 SUBROUTINE loadcurrentega(null)
   FREE RECORD egarequest
   RECORD egarequest(
     1 patient_list[*]
       2 patient_id = f8
       2 encntr_id = f8
     1 pregnancy_list[*]
       2 pregnancy_id = f8
     1 multiple_egas = i2
   )
   SET stat = alterlist(egarequest->patient_list,1)
   SET egarequest->patient_list[1].patient_id = request->person_id
   SET egarequest->patient_list[1].encntr_id = request->encntr_id
   IF ((request->encntr_id > 0))
    SET egarequest->multiple_egas = 0
   ELSE
    SET egarequest->multiple_egas = 1
   ENDIF
   SET modify = nopredeclare
   EXECUTE dcp_get_final_ega  WITH replace("REQUEST",egarequest), replace("REPLY",egareply)
   SET modify = predeclare
   IF ((egareply->status_data.status="S")
    AND size(egareply->gestation_info,5) >= 1)
    SET active_preg_ind = 1
   ELSEIF ((egareply->status_data.status="Z"))
    SET active_preg_ind = 0
   ELSE
    SET failure_ind = true
    CALL fillsubeventstatus("EXECUTE","F","cp_pregnancy_versions",
     "dcp_get_final_ega: failure loading current ega")
    GO TO failure
   ENDIF
   CALL echorecord(egareply)
   FREE RECORD egarequest
 END ;Subroutine
 SUBROUTINE (loadpregnancyedds(deleted_edds=i2) =null)
   FREE RECORD eddrequest
   RECORD eddrequest(
     1 patient_id = f8
     1 pregnancy_id = f8
     1 edds[*]
       2 edd_id = f8
     1 previous_values_flag = i2
     1 encntr_id = f8
     1 org_sec_override = i2
     1 deleted_edds_flag = i2
   )
   SET eddrequest->patient_id = request->person_id
   SET eddrequest->encntr_id = request->encntr_id
   SET eddrequest->previous_values_flag = 1
   SET eddrequest->deleted_edds_flag = deleted_edds
   SET modify = nopredeclare
   EXECUTE dcp_get_pregnancy_edd  WITH replace("REQUEST",eddrequest), replace("REPLY",eddreply)
   SET modify = predeclare
   IF ((eddreply->status_data.status="S"))
    SET edd_data_ind = 1
   ELSEIF ((eddreply->status_data.status="Z"))
    SET edd_data_ind = 0
   ELSE
    SET failure_ind = true
    CALL fillsubeventstatus("EXECUTE","F","cp_pregnancy_versions",
     "dcp_get_pregnancy_edd: failure retrieving EDDs")
    GO TO failure
   ENDIF
   CALL echorecord(eddreply)
   FREE RECORD eddrequest
 END ;Subroutine
 SUBROUTINE loadeddorgs(null)
   DECLARE org_idx = i4 WITH noconstant(0), protect
   DECLARE organization_cnt = i4 WITH noconstant(0), protect
   DECLARE i = i4 WITH noconstant(0), protect
   SET stat = alterlist(organizations->organization_list,0)
   FOR (i = 1 TO size(eddreply->edd_list,5))
     IF (locateval(org_idx,1,size(organizations->organization_list,5),eddreply->edd_list[i].org_id,
      organizations->organization_list[org_idx].org_id)=0)
      SET organization_cnt += 1
      IF (mod(i,10)=1)
       SET stat = alterlist(organizations->organization_list,(i+ 9))
      ENDIF
      SET organizations->organization_list[organization_cnt].org_id = eddreply->edd_list[i].org_id
     ENDIF
   ENDFOR
   SET stat = alterlist(organizations->organization_list,organization_cnt)
   IF (organization_cnt > 0)
    SELECT INTO "nl:"
     FROM organization o,
      (dummyt d  WITH seq = size(organizations->organization_list,5))
     PLAN (d)
      JOIN (o
      WHERE (o.organization_id=organizations->organization_list[d.seq].org_id)
       AND o.active_ind=1)
     DETAIL
      organizations->organization_list[d.seq].org_name = o.org_name
     WITH nocounter
    ;end select
   ENDIF
 END ;Subroutine
 SUBROUTINE loadgravida(null)
   DECLARE chart_request_prsnl = f8 WITH noconstant(0), protect
   IF ((request->chart_request_id > 0))
    SELECT INTO "nl:"
     FROM chart_request
     WHERE (chart_request_id=request->chart_request_id)
     HEAD REPORT
      chart_request_prsnl = chart_request.request_prsnl_id
     WITH maxcol = 132
    ;end select
   ELSEIF (validate(request->provider_prsnl_id))
    SET chart_request_prsnl = request->provider_prsnl_id
   ENDIF
   IF (chart_request_prsnl <= 0)
    SET failure_ind = true
    CALL fillsubeventstatus("EXECUTE","F","cp_pregnancy_versions",
     "No chart_request_prsnl, unable to obtain gravida counts")
    GO TO failure
   ENDIF
   FREE RECORD gravrequest
   RECORD gravrequest(
     1 patient_id = f8
     1 prsnl_id = f8
     1 org_sec_override = i2
   )
   SET gravrequest->patient_id = request->person_id
   SET gravrequest->prsnl_id = chart_request_prsnl
   SET modify = nopredeclare
   EXECUTE dcp_get_gravida_info  WITH replace("REQUEST",gravrequest), replace("REPLY",gravreply)
   SET modify = predeclare
   IF ((gravreply->status_data.status="S"))
    SET gravida_data_ind = 1
   ELSEIF ((gravreply->status_data.status="Z"))
    SET gravida_data_ind = 0
   ELSE
    CALL echo(build("dcp_get_gravida_info: ","Status failed"))
    SET failure_ind = true
    CALL fillsubeventstatus("EXECUTE","F","cp_pregnancy_versions",
     "dcp_get_gravida_info: failure loading gravida counts")
    GO TO failure
   ENDIF
   FREE RECORD gravrequest
 END ;Subroutine
 SUBROUTINE (formatega(egadays=i4,egadisplay=vc(ref)) =null)
   DECLARE egaweeks = i4 WITH noconstant(0), protect
   DECLARE egadayremainder = i4 WITH noconstant(0), protect
   SET egaweeks = (egadays/ 7)
   SET egadayremainder = mod(egadays,7)
   SET egadisplay = concat(build(egaweeks)," ",build(egadayremainder),"/7 ",captions->sweeks)
 END ;Subroutine
 SUBROUTINE (flattenpregnancies(preg_versions=i2) =null)
   DECLARE preg_inst_cnt = i4 WITH noconstant(1), protect
   DECLARE total_child_cnt = i4 WITH noconstant(0), protect
   DECLARE child_cnt = i4 WITH noconstant(0), protect
   DECLARE entity_cnt = i4 WITH noconstant(0), protect
   DECLARE entity_nomen = f8 WITH noconstant(0), protect
   DECLARE parent_entity = vc WITH noconstant, protect
   DECLARE n_idx = i4 WITH noconstant(0), protect
   DECLARE preg = i2 WITH noconstant(0), protect
   DECLARE inst = i2 WITH noconstant(0), protect
   DECLARE child = i2 WITH noconstant(0), protect
   DECLARE entity = i2 WITH noconstant(0), protect
   DECLARE reply_size = i4 WITH noconstant(0), protect
   DECLARE sortdate = dq8 WITH protect, noconstant
   DECLARE actiondt = dq8 WITH protect, noconstant(0)
   DECLARE create_action_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002114,"CREATE"))
   DECLARE update_action_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002114,"UPDATE"))
   DECLARE reopen_action_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002114,"REOPEN"))
   DECLARE close_action_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002114,"CLOSE"))
   DECLARE auto_close_action_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002114,
     "AUTOCLOSE"))
   DECLARE delete_action_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002114,"DELETE"))
   IF (preg_versions=true)
    SET curalias pregs pregreply->pregnancies[preg].preg_instance[inst]
    SET curalias preg_children pregreply->pregnancies[preg].preg_instance[inst].pregnancy_children[
    child]
    SET curalias child_entities pregreply->pregnancies[preg].preg_instance[inst].pregnancy_children[
    child].child_entities[entity]
    SET reply_size = size(pregreply->pregnancies,5)
   ELSE
    SET curalias pregs phxreply->pregnancies[preg]
    SET curalias preg_children phxreply->pregnancies[preg].pregnancy_children[child]
    SET curalias preg_actions phxreply->pregnancies[preg].pregnancy_actions[action]
    SET curalias child_entities phxreply->pregnancies[preg].pregnancy_children[child].child_entities[
    entity]
    SET reply_size = size(phxreply->pregnancies,5)
    CALL addentitytext(null)
   ENDIF
   FOR (preg = 1 TO reply_size)
    IF (preg_versions=1)
     SET preg_inst_cnt = size(pregreply->pregnancies[preg].preg_instance,5)
    ENDIF
    FOR (inst = 1 TO preg_inst_cnt)
      SET child_cnt = size(pregs->pregnancy_children,5)
      SET stat = alterlist(flatpregs->children,(size(flatpregs->children,5)+ child_cnt))
      FOR (child = 1 TO child_cnt)
        SET total_child_cnt += 1
        SET flatpregs->children[total_child_cnt].pregnancy_id = pregs->pregnancy_id
        IF (child_cnt > 1)
         SET flatpregs->children[total_child_cnt].child_label = captions->ababylabels[child].
         sbabylabel
        ENDIF
        SET flatpregs->children[total_child_cnt].sensitive_ind = pregs->sensitive_ind
        SET flatpregs->children[total_child_cnt].pregnancy_child_id = preg_children->
        pregnancy_child_id
        SET flatpregs->children[total_child_cnt].gender_cd = preg_children->gender_cd
        SET flatpregs->children[total_child_cnt].child_name = preg_children->child_name
        SET flatpregs->children[total_child_cnt].father_name = preg_children->father_name
        SET flatpregs->children[total_child_cnt].delivery_method_cd = preg_children->
        delivery_method_cd
        SET flatpregs->children[total_child_cnt].delivery_hospital = preg_children->delivery_hospital
        SET flatpregs->children[total_child_cnt].gestation_age = preg_children->gestation_age
        SET flatpregs->children[total_child_cnt].gestation_term_txt = validate(preg_children->
         gestation_term_txt,"")
        SET flatpregs->children[total_child_cnt].labor_duration = preg_children->labor_duration
        SET flatpregs->children[total_child_cnt].weight_amt = preg_children->weight_amt
        SET flatpregs->children[total_child_cnt].weight_unit_cd = preg_children->weight_unit_cd
        SET flatpregs->children[total_child_cnt].neonate_outcome_cd = preg_children->
        neonate_outcome_cd
        SET flatpregs->children[total_child_cnt].child_comment = preg_children->child_comment
        SET flatpregs->children[total_child_cnt].delivery_dt_precision = preg_children->
        delivery_date_precision_flag
        IF (preg_versions=1)
         SET flatpregs->children[total_child_cnt].pregnancy_instance_id = pregs->
         pregnancy_instance_id
         SET flatpregs->children[total_child_cnt].inst_prsnl_id = pregs->instance_prsnl_id
         SET flatpregs->children[total_child_cnt].auto_closed_ind = pregs->auto_closed_ind
         IF ((pregs->deleted_ind=1))
          SET flatpregs->children[total_child_cnt].instance_status = deleted
         ELSEIF (inst > 1)
          SET flatpregs->children[total_child_cnt].instance_status = modified
         ELSE
          SET flatpregs->children[total_child_cnt].instance_status = current
         ENDIF
         CALL savephxversionsdates(null)
        ELSE
         SET flatpregs->children[total_child_cnt].instance_status = current
         CALL savephxdates(null)
         FOR (action = 1 TO size(pregs->pregnancy_actions,5))
           IF ((actiondt < preg_actions->action_dt_tm))
            SET actiondt = preg_actions->action_dt_tm
            IF ((preg_actions->action_type_cd=auto_close_action_cd))
             SET flatpregs->children[total_child_cnt].auto_closed_ind = 1
            ELSEIF ((preg_actions->action_type_cd IN (create_action_cd, update_action_cd,
            reopen_action_cd, close_action_cd, delete_action_cd)))
             SET flatpregs->children[total_child_cnt].auto_closed_ind = 0
            ENDIF
           ENDIF
         ENDFOR
         SET actiondt = 0
        ENDIF
        IF (size(preg_children->anesthesia_txt,1) > 0)
         SET stat = alterlist(flatpregs->children[total_child_cnt].anesthesia,1)
         SET flatpregs->children[total_child_cnt].anesthesia[1].anesthesia_type = preg_children->
         anesthesia_txt
        ENDIF
        IF (size(preg_children->preterm_labor_txt,1) > 0)
         SET stat = alterlist(flatpregs->children[total_child_cnt].preterm_labor,1)
         SET flatpregs->children[total_child_cnt].preterm_labor[1].preterm_item = preg_children->
         preterm_labor_txt
        ENDIF
        FOR (entity = 1 TO size(preg_children->child_entities,5))
          CASE (child_entities->component_type_cd)
           OF entity_anesthesia:
            SET stat = alterlist(flatpregs->children[total_child_cnt].anesthesia,(size(flatpregs->
              children[total_child_cnt].anesthesia,5)+ 1))
            SET entity_cnt = size(flatpregs->children[total_child_cnt].anesthesia,5)
            SET flatpregs->children[total_child_cnt].anesthesia[entity_cnt].anesthesia_type = trim(
             uar_get_code_display(child_entities->parent_entity_id))
           OF entity_fetus:
            SET stat = alterlist(flatpregs->children[total_child_cnt].fetal_complications,(size(
              flatpregs->children[total_child_cnt].fetal_complications,5)+ 1))
            SET entity_cnt = size(flatpregs->children[total_child_cnt].fetal_complications,5)
            SET entity_nomen = child_entities->parent_entity_id
            SET parent_entity = child_entities->parent_entity_name
            IF (((parent_entity="NOMENCLATURE") OR (parent_entity="LONG_TEXT")) )
             SET flatpregs->children[total_child_cnt].fetal_complications[entity_cnt].fetal_comp =
             child_entities->entity_text
            ELSE
             CALL echo("Found unrecognized fetal complication entity")
            ENDIF
           OF entity_mother:
            SET stat = alterlist(flatpregs->children[total_child_cnt].mother_complications,(size(
              flatpregs->children[total_child_cnt].mother_complications,5)+ 1))
            SET entity_cnt = size(flatpregs->children[total_child_cnt].mother_complications,5)
            SET entity_nomen = child_entities->parent_entity_id
            SET parent_entity = child_entities->parent_entity_name
            IF (((parent_entity="NOMENCLATURE") OR (parent_entity="LONG_TEXT")) )
             SET flatpregs->children[total_child_cnt].mother_complications[entity_cnt].mother_comp =
             child_entities->entity_text
            ELSE
             CALL echo("Found unrecognized mother complication entity")
            ENDIF
           OF entity_newborn:
            SET stat = alterlist(flatpregs->children[total_child_cnt].neonate_complications,(size(
              flatpregs->children[total_child_cnt].neonate_complications,5)+ 1))
            SET entity_cnt = size(flatpregs->children[total_child_cnt].neonate_complications,5)
            SET entity_nomen = child_entities->parent_entity_id
            SET parent_entity = child_entities->parent_entity_name
            IF (((parent_entity="NOMENCLATURE") OR ("LONG_TEXT")) )
             SET flatpregs->children[total_child_cnt].neonate_complications[entity_cnt].neonate_comp
              = child_entities->entity_text
            ELSE
             CALL echo("Found unrecognized neonatal complication entity")
            ENDIF
           OF entity_preterm:
            SET stat = alterlist(flatpregs->children[total_child_cnt].preterm_labor,(size(flatpregs->
              children[total_child_cnt].preterm_labor,5)+ 1))
            SET entity_cnt = size(flatpregs->children[total_child_cnt].preterm_labor,5)
            SET flatpregs->children[total_child_cnt].preterm_labor[entity_cnt].preterm_item = trim(
             uar_get_code_display(child_entities->parent_entity_id))
          ENDCASE
        ENDFOR
      ENDFOR
    ENDFOR
   ENDFOR
   IF (preg_versions=true)
    CALL loadhxprsnl(null)
   ENDIF
   SET curalias pregs off
   SET curalias preg_children off
   SET curalias child_entities off
   CALL echorecord(flatpregs)
   FREE RECORD pregreply
 END ;Subroutine
 SUBROUTINE savephxdates(null)
   DECLARE datestr = vc WITH protect, noconstant
   IF ((preg_children->delivery_date_precision_flag=3))
    SET flatpregs->children[total_child_cnt].delivery_dt_tm_sort = pregs->preg_end_dt_tm
   ELSE
    CALL defuzzifydate(preg_children->delivery_dt_tm,preg_children->delivery_date_precision_flag,
     preg_children->delivery_date_qualifier_flag,sortdate)
    SET flatpregs->children[total_child_cnt].delivery_dt_tm_sort = sortdate
   ENDIF
   IF ((preg_children->delivery_date_precision_flag=3))
    CALL formatfuzzydate(pregs->preg_end_dt_tm,preg_children->delivery_tz,preg_children->
     delivery_date_precision_flag,0,datestr)
   ELSE
    CALL formatfuzzydate(preg_children->delivery_dt_tm,preg_children->delivery_tz,preg_children->
     delivery_date_precision_flag,preg_children->delivery_date_qualifier_flag,datestr)
   ENDIF
   SET flatpregs->children[total_child_cnt].delivery_dt_tm_disp = datestr
 END ;Subroutine
 SUBROUTINE savephxversionsdates(null)
   DECLARE datestr = vc WITH protect, noconstant
   IF ((preg_children->delivery_date_precision_flag=3))
    SET flatpregs->children[total_child_cnt].delivery_dt_tm_sort = pregs->entered_dt_tm
   ELSE
    IF ((flatpregs->children[total_child_cnt].instance_status != modified))
     CALL defuzzifydate(preg_children->delivery_dt_tm,preg_children->delivery_date_precision_flag,
      preg_children->delivery_date_qualifier_flag,sortdate)
    ENDIF
    SET flatpregs->children[total_child_cnt].delivery_dt_tm_sort = sortdate
   ENDIF
   SET flatpregs->children[total_child_cnt].inst_dt_tm_disp = concat(trim(datetimezoneformat(pregs->
      entered_dt_tm,pregs->entered_tz,"@SHORTDATE"))," ",trim(datetimezoneformat(pregs->entered_dt_tm,
      pregs->entered_tz,"@TIMEWITHSECONDS")))
   IF ((preg_children->delivery_date_precision_flag=3))
    CALL formatfuzzydate(pregs->preg_end_dt_tm,preg_children->delivery_tz,preg_children->
     delivery_date_precision_flag,0,datestr)
   ELSE
    CALL formatfuzzydate(preg_children->delivery_dt_tm,preg_children->delivery_tz,preg_children->
     delivery_date_precision_flag,preg_children->delivery_date_qualifier_flag,datestr)
   ENDIF
   SET flatpregs->children[total_child_cnt].delivery_dt_tm_disp = datestr
 END ;Subroutine
 SUBROUTINE addentitytext(null)
   DECLARE preg_cnt = i4 WITH protect, constant(size(phxreply->pregnancies,5))
   DECLARE child_cnt = i4 WITH protect, noconstant(0)
   DECLARE entity_cnt = i4 WITH protect, noconstant(0)
   DECLARE n_idx = i4 WITH protect, noconstant
   DECLARE num = i4 WITH protect, noconstant
   DECLARE i = i4 WITH noconstant(0), protect
   DECLARE j = i4 WITH noconstant(0), protect
   DECLARE k = i4 WITH noconstant(0), protect
   FOR (i = 1 TO preg_cnt)
    SET child_cnt = size(phxreply->pregnancies[i].pregnancy_children,5)
    FOR (j = 1 TO child_cnt)
     SET entity_cnt = size(phxreply->pregnancies[i].pregnancy_children[j].child_entities,5)
     FOR (k = 1 TO entity_cnt)
      SET n_idx = locateval(num,1,size(phxreply->nomenclature_info,5),phxreply->pregnancies[i].
       pregnancy_children[j].child_entities[k].parent_entity_id,phxreply->nomenclature_info[num].
       nomenclature_id)
      IF (n_idx > 0)
       SET phxreply->pregnancies[i].pregnancy_children[j].child_entities[k].entity_text = phxreply->
       nomenclature_info[n_idx].source_string
      ENDIF
     ENDFOR
    ENDFOR
   ENDFOR
 END ;Subroutine
 SUBROUTINE (formatfuzzydate(datetime=dq8,tz=i4,dateprecision=i4,datequalifier=i4,datestr=vc(ref)) =
  null)
   DECLARE qualifierdisp = vc WITH noconstant, protect
   DECLARE datemonth = i4 WITH noconstant(0), protect
   DECLARE dateyear = i4 WITH noconstant(0), protect
   DECLARE fuzzystr = vc WITH noconstant, protect
   IF (((dateprecision=0) OR (dateprecision=3)) )
    IF (curutc=0)
     IF (datequalifier=qual_dateonly)
      SET datestr = format(datetime,"@SHORTDATE;;Q")
     ELSE
      SET datestr = concat(format(datetime,"@SHORTDATE;;Q")," ",format(datetime,"@TIMENOSECONDS;;S"))
     ENDIF
    ELSE
     IF (datequalifier=qual_dateonly)
      SET datestr = trim(datetimezoneformat(datetime,tz,"@SHORTDATE"))
     ELSE
      SET datestr = concat(trim(datetimezoneformat(datetime,tz,"@SHORTDATE"))," ",trim(
        datetimezoneformat(datetime,tz,"@TIMENOSECONDS")))
     ENDIF
    ENDIF
   ELSE
    CASE (datequalifier)
     OF qual_before:
      SET qualifierdisp = captions->sbefore
     OF qual_after:
      SET qualifierdisp = captions->safter
     OF qual_about:
      SET qualifierdisp = captions->sabout
    ENDCASE
    SET datemonth = month(cnvtdatetime(datetime))
    SET dateyear = year(cnvtdatetime(datetime))
    CASE (dateprecision)
     OF precision_year:
      SET fuzzystr = build(dateyear)
     OF precision_month:
      SET fuzzystr = concat(build(datemonth),"/",build(dateyear))
    ENDCASE
    IF (datequalifier > 0)
     SET datestr = concat(qualifierdisp," ",fuzzystr)
    ELSE
     SET datestr = fuzzystr
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (defuzzifydate(fuzzydt=dq8,dateprecision=i4,datequalifier=i4,sortdate=dq8(ref)) =null)
   IF (dateprecision=precision_month)
    SET sortdate = fuzzydt
    IF (datequalifier=qual_before)
     SET sortdate = cnvtlookbehind("1,D",sortdate)
    ELSEIF (datequalifier=qual_after)
     SET sortdate = cnvtlookahead("1,M",sortdate)
    ENDIF
   ELSEIF (dateprecision=precision_year)
    SET sortdate = fuzzydt
    IF (datequalifier=qual_before)
     SET sortdate = cnvtlookbehind("1,D",sortdate)
    ELSEIF (datequalifier=qual_after)
     SET sortdate = cnvtlookahead("1,Y",sortdate)
    ENDIF
   ELSE
    SET sortdate = fuzzydt
   ENDIF
 END ;Subroutine
 SUBROUTINE (flattenedd(previous_edds=i2) =null)
   DECLARE edd_cnt = i4 WITH protect, noconstant(size(eddreply->edd_list,5))
   DECLARE prev_edd_cnt = i4 WITH protect, noconstant(0)
   DECLARE edd_idx = i4 WITH protect, noconstant(0)
   DECLARE sort_date = dq8 WITH protect, noconstant
   DECLARE sort_status = i2 WITH protect, noconstant(0)
   DECLARE i = i4 WITH noconstant(0), protect
   DECLARE j = i4 WITH noconstant(0), protect
   FOR (i = 1 TO edd_cnt)
     IF (previous_edds=1)
      SET prev_edd_cnt = size(eddreply->edd_list[i].prev_edds,5)
     ELSE
      SET prev_edd_cnt = 0
     ENDIF
     SET edd_idx += 1
     SET stat = alterlist(flatedd->edd_list,(edd_idx+ prev_edd_cnt))
     SET flatedd->edd_list[edd_idx].pregnancy_estimate_id = eddreply->edd_list[i].
     pregnancy_estimate_id
     SET flatedd->edd_list[edd_idx].pregnancy_id = eddreply->edd_list[i].pregnancy_id
     SET flatedd->edd_list[edd_idx].org_id = eddreply->edd_list[i].org_id
     SET flatedd->edd_list[edd_idx].status_flag = eddreply->edd_list[i].status_flag
     SET flatedd->edd_list[edd_idx].est_delivery_date = eddreply->edd_list[i].est_delivery_date
     SET flatedd->edd_list[edd_idx].est_gest_age = eddreply->edd_list[i].est_gest_age
     SET flatedd->edd_list[edd_idx].method_cd = eddreply->edd_list[i].method_cd
     SET flatedd->edd_list[edd_idx].method_dt_tm = eddreply->edd_list[i].method_dt_tm
     SET flatedd->edd_list[edd_idx].confirmation_cd = eddreply->edd_list[i].confirmation_cd
     SET flatedd->edd_list[edd_idx].author_id = eddreply->edd_list[i].author_id
     SET flatedd->edd_list[edd_idx].entered_dt_tm = eddreply->edd_list[i].entered_dt_tm
     SET flatedd->edd_list[edd_idx].original_entered_dttm = eddreply->edd_list[i].
     original_entered_dttm
     SET flatedd->edd_list[edd_idx].creator_id = eddreply->edd_list[i].creator_id
     SET flatedd->edd_list[edd_idx].descriptor_flag = eddreply->edd_list[i].descriptor_flag
     SET flatedd->edd_list[edd_idx].descriptor_txt = eddreply->edd_list[i].descriptor_txt
     SET flatedd->edd_list[edd_idx].biparietal_diameter = eddreply->edd_list[i].biparietal_diameter
     SET flatedd->edd_list[edd_idx].crown_rump_length = eddreply->edd_list[i].crown_rump_length
     SET flatedd->edd_list[edd_idx].head_circumference = eddreply->edd_list[i].head_circumference
     SET flatedd->edd_list[edd_idx].descriptor_cd = eddreply->edd_list[i].descriptor_cd
     SET flatedd->edd_list[edd_idx].edd_comment = eddreply->edd_list[i].edd_comment
     IF ((eddreply->edd_list[i].active_ind=1))
      SET flatedd->edd_list[edd_idx].instance_status = current
     ELSE
      SET flatedd->edd_list[edd_idx].instance_status = deleted
     ENDIF
     IF (size(eddreply->edd_list[i].details,5)=1)
      SET stat = alterlist(flatedd->edd_list[edd_idx].details,1)
      SET flatedd->edd_list[edd_idx].details[1].menarche_age = eddreply->edd_list[i].details[1].
      menarche_age
      SET flatedd->edd_list[edd_idx].details[1].menstrual_freq = eddreply->edd_list[i].details[1].
      menstrual_freq
      SET flatedd->edd_list[edd_idx].details[1].prior_menses_dt_tm = eddreply->edd_list[i].details[1]
      .prior_menses_dt_tm
      SET flatedd->edd_list[edd_idx].details[1].pregnancy_test_dt_tm = eddreply->edd_list[i].details[
      1].pregnancy_test_dt_tm
      SET flatedd->edd_list[edd_idx].details[1].lmp_symptoms_txt = eddreply->edd_list[i].details[1].
      lmp_symptoms_txt
     ENDIF
     SET sort_date = eddreply->edd_list[i].entered_dt_tm
     SET flatedd->edd_list[edd_idx].sort_dt_tm = sort_date
     SET sort_status = eddreply->edd_list[i].status_flag
     SET flatedd->edd_list[edd_idx].sort_status = sort_status
     FOR (j = 1 TO prev_edd_cnt)
       SET edd_idx += 1
       SET flatedd->edd_list[edd_idx].pregnancy_estimate_id = eddreply->edd_list[i].prev_edds[j].
       pregnancy_estimate_id
       SET flatedd->edd_list[edd_idx].pregnancy_id = eddreply->edd_list[i].prev_edds[j].pregnancy_id
       SET flatedd->edd_list[edd_idx].status_flag = eddreply->edd_list[i].prev_edds[j].status_flag
       SET flatedd->edd_list[edd_idx].est_delivery_date = eddreply->edd_list[i].prev_edds[j].
       est_delivery_date
       SET flatedd->edd_list[edd_idx].est_gest_age = eddreply->edd_list[i].prev_edds[j].est_gest_age
       SET flatedd->edd_list[edd_idx].method_cd = eddreply->edd_list[i].prev_edds[j].method_cd
       SET flatedd->edd_list[edd_idx].method_dt_tm = eddreply->edd_list[i].prev_edds[j].method_dt_tm
       SET flatedd->edd_list[edd_idx].confirmation_cd = eddreply->edd_list[i].prev_edds[j].
       confirmation_cd
       SET flatedd->edd_list[edd_idx].author_id = eddreply->edd_list[i].prev_edds[j].author_id
       SET flatedd->edd_list[edd_idx].entered_dt_tm = eddreply->edd_list[i].prev_edds[j].
       entered_dt_tm
       SET flatedd->edd_list[edd_idx].descriptor_flag = eddreply->edd_list[i].prev_edds[j].
       descriptor_flag
       SET flatedd->edd_list[edd_idx].descriptor_txt = eddreply->edd_list[i].prev_edds[j].
       descriptor_txt
       SET flatedd->edd_list[edd_idx].biparietal_diameter = eddreply->edd_list[i].prev_edds[j].
       biparietal_diameter
       SET flatedd->edd_list[edd_idx].crown_rump_length = eddreply->edd_list[i].prev_edds[j].
       crown_rump_length
       SET flatedd->edd_list[edd_idx].head_circumference = eddreply->edd_list[i].prev_edds[j].
       head_circumference
       SET flatedd->edd_list[edd_idx].descriptor_cd = eddreply->edd_list[i].prev_edds[j].
       descriptor_cd
       SET flatedd->edd_list[edd_idx].edd_comment = eddreply->edd_list[i].prev_edds[j].edd_comment
       SET flatedd->edd_list[edd_idx].active_ind = eddreply->edd_list[i].prev_edds[j].active_ind
       SET flatedd->edd_list[edd_idx].instance_status = modified
       SET flatedd->edd_list[edd_idx].sort_dt_tm = sort_date
       SET flatedd->edd_list[edd_idx].sort_status = sort_status
       IF (size(eddreply->edd_list[i].prev_edds[j].details,5)=1)
        SET stat = alterlist(flatedd->edd_list[edd_idx].details,1)
        SET flatedd->edd_list[edd_idx].details[1].menarche_age = eddreply->edd_list[i].prev_edds[j].
        details[1].menarche_age
        SET flatedd->edd_list[edd_idx].details[1].menstrual_freq = eddreply->edd_list[i].prev_edds[j]
        .details[1].menstrual_freq
        SET flatedd->edd_list[edd_idx].details[1].prior_menses_dt_tm = eddreply->edd_list[i].
        prev_edds[j].details[1].prior_menses_dt_tm
        SET flatedd->edd_list[edd_idx].details[1].pregnancy_test_dt_tm = eddreply->edd_list[i].
        prev_edds[j].details[1].pregnancy_test_dt_tm
        SET flatedd->edd_list[edd_idx].details[1].lmp_symptoms_txt = eddreply->edd_list[i].prev_edds[
        j].details[1].lmp_symptoms_txt
       ENDIF
     ENDFOR
   ENDFOR
   CALL echorecord(flatedd)
 END ;Subroutine
 SUBROUTINE buildgravidatext(null)
   IF ((gravreply->gravida_ind > 0))
    SET print_pregnancy->gravida_text = concat(captions->sgravida," ",build(gravreply->gravida),";")
   ENDIF
   IF ((gravreply->para_ind > 0))
    SET print_pregnancy->gravida_text = concat(print_pregnancy->gravida_text," ",captions->spara," ",
     build(gravreply->para),
     ";")
   ENDIF
   IF ((gravreply->fullterm_ind > 0))
    SET print_pregnancy->gravida_text = concat(print_pregnancy->gravida_text," ",captions->
     sparafullterm," ",build(gravreply->fullterm),
     ";")
   ENDIF
   IF ((gravreply->premature_ind > 0))
    SET print_pregnancy->gravida_text = concat(print_pregnancy->gravida_text," ",captions->
     sparapremature," ",build(gravreply->premature),
     ";")
   ENDIF
   IF ((gravreply->aborted_ind > 0))
    SET print_pregnancy->gravida_text = concat(print_pregnancy->gravida_text," ",captions->sabortions,
     " ",build(gravreply->aborted),
     ";")
   ENDIF
   IF ((gravreply->induced_abortions_ind > 0))
    SET print_pregnancy->gravida_text = concat(print_pregnancy->gravida_text," ",captions->sinduced,
     " ",build(gravreply->induced_abortions),
     ";")
   ENDIF
   IF ((gravreply->spontaneous_abortions_ind > 0))
    SET print_pregnancy->gravida_text = concat(print_pregnancy->gravida_text," ",captions->
     sspontaneous," ",build(gravreply->spontaneous_abortions),
     ";")
   ENDIF
   IF ((gravreply->ectopic_ind > 0))
    SET print_pregnancy->gravida_text = concat(print_pregnancy->gravida_text," ",captions->sectopic,
     " ",build(gravreply->ectopic),
     ";")
   ENDIF
   IF ((gravreply->multiple_births_ind > 0))
    SET print_pregnancy->gravida_text = concat(print_pregnancy->gravida_text," ",captions->
     smultiplebirths," ",build(gravreply->multiple_births))
   ENDIF
   IF ((gravreply->living_ind > 0))
    SET print_pregnancy->gravida_text = concat(print_pregnancy->gravida_text," ",captions->
     sparaliving," ",build(gravreply->living))
   ENDIF
   IF (size(gravreply->living_comment,1) > 0)
    SET print_pregnancy->gravida_text = concat(print_pregnancy->gravida_text," ",captions->
     slivingcomment," ",gravreply->living_comment)
   ENDIF
   CALL wrap_text(print_pregnancy->gravida_text,80,80)
   SET stat = alterlist(print_pregnancy->gravida_wrap,pt->line_cnt)
   DECLARE x = i4 WITH noconstant(0), protect
   FOR (x = 1 TO pt->line_cnt)
     SET print_pregnancy->gravida_wrap[x].gravida_line = pt->lns[x].line
   ENDFOR
   FREE RECORD gravreply
 END ;Subroutine
 SUBROUTINE loadeddprsnl(null)
   DECLARE edd_cnt = i4 WITH noconstant(size(flatedd->edd_list,5)), protect
   DECLARE author_cnt = i4 WITH noconstant(0), protect
   DECLARE auth_idx = i4 WITH noconstant(0), protect
   SELECT INTO "nl:"
    p.name_full_formatted
    FROM prsnl p,
     (dummyt d1  WITH seq = value(edd_cnt))
    PLAN (d1)
     JOIN (p
     WHERE expand(auth_idx,1,edd_cnt,p.person_id,flatedd->edd_list[auth_idx].author_id))
    HEAD p.person_id
     author_cnt += 1
     IF (mod(author_cnt,10)=1)
      stat = alterlist(authors->author_list,(author_cnt+ 9))
     ENDIF
     authors->author_list[author_cnt].prsnl_name = p.name_full_formatted, authors->author_list[
     author_cnt].prsnl_id = p.person_id
    WITH nocounter
   ;end select
   SET stat = alterlist(authors->author_list,author_cnt)
 END ;Subroutine
 SUBROUTINE loadhxprsnl(null)
   FREE RECORD prsnl
   RECORD prsnl(
     1 prsnl_list[*]
       2 prsnl_id = f8
       2 prsnl_name = vc
   )
   DECLARE child_cnt = i4 WITH protect, noconstant(size(flatpregs->children,5))
   DECLARE prsnl_cnt = i4 WITH protect, noconstant(0)
   DECLARE child_idx = i4 WITH protect, noconstant(0)
   DECLARE prsnl_idx = i4 WITH protect, noconstant(0)
   DECLARE idx = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    p.name_full_formatted
    FROM prsnl p,
     (dummyt d1  WITH seq = value(child_cnt))
    PLAN (d1)
     JOIN (p
     WHERE expand(idx,1,child_cnt,p.person_id,flatpregs->children[idx].inst_prsnl_id))
    HEAD p.person_id
     prsnl_cnt += 1
     IF (mod(prsnl_cnt,10)=1)
      stat = alterlist(prsnl->prsnl_list,(prsnl_cnt+ 9))
     ENDIF
     prsnl->prsnl_list[prsnl_cnt].prsnl_id = p.person_id, prsnl->prsnl_list[prsnl_cnt].prsnl_name = p
     .name_full_formatted
    WITH nocounter
   ;end select
   SET stat = alterlist(prsnl->prsnl_list,prsnl_cnt)
   FOR (idx = 1 TO child_cnt)
    SET prsnl_idx = locateval(prsnl_idx,1,prsnl_cnt,flatpregs->children[idx].inst_prsnl_id,prsnl->
     prsnl_list[prsnl_idx].prsnl_id)
    IF (prsnl_idx > 0)
     SET flatpregs->children[idx].inst_prsnl_disp = prsnl->prsnl_list[prsnl_idx].prsnl_name
    ENDIF
   ENDFOR
   FREE RECORD prsnl
 END ;Subroutine
 SUBROUTINE buildphxtext(null)
   DECLARE child_cnt = i4 WITH protect, noconstant(0)
   DECLARE prev_preg_id = i4 WITH protect, noconstant(0)
   DECLARE child_id = i4 WITH noconstant(0), protect
   DECLARE first_child_ind = i2 WITH noconstant(0), protect
   DECLARE anes_cnt = i4 WITH noconstant(0), protect
   DECLARE aidx = i4 WITH noconstant(0), protect
   DECLARE pidx = i4 WITH noconstant(0), protect
   DECLARE midx = i4 WITH noconstant(0), protect
   DECLARE fidx = i4 WITH noconstant(0), protect
   DECLARE nidx = i4 WITH noconstant(0), protect
   DECLARE x = i4 WITH noconstant(0), protect
   DECLARE preterm_cnt = i4 WITH noconstant(0), protect
   DECLARE maternal_cnt = i4 WITH noconstant(0), protect
   DECLARE fetus_cnt = i4 WITH noconstant(0), protect
   DECLARE neonate_cnt = i4 WITH noconstant(0), protect
   DECLARE maternal_cnt = i4 WITH noconstant(0), protect
   SET stat = alterlist(print_pregnancy->child_list,size(flatpregs->children,5))
   SELECT INTO "nl:"
    child_id = flatpregs->children[d1.seq].pregnancy_child_id
    FROM (dummyt d1  WITH seq = value(size(flatpregs->children,5)))
    ORDER BY flatpregs->children[d1.seq].delivery_dt_tm_sort
    HEAD REPORT
     child_cnt = 0, prev_preg_id = 0, first_child_ind = 0
    HEAD child_id
     child_cnt += 1, print_pregnancy->child_list[child_cnt].pregnancy_id = flatpregs->children[d1.seq
     ].pregnancy_id
     IF ((flatpregs->children[d1.seq].pregnancy_id != prev_preg_id))
      first_child_ind = 1
     ELSE
      first_child_ind = 0
     ENDIF
     IF ((flatpregs->children[d1.seq].instance_status=deleted))
      print_pregnancy->child_list[child_cnt].instance_status = deleted, print_pregnancy->child_list[
      child_cnt].instance_header = concat(captions->sdeletedon," ",flatpregs->children[d1.seq].
       inst_dt_tm_disp," ",captions->sdeletedby,
       " ",flatpregs->children[d1.seq].inst_prsnl_disp)
     ELSEIF ((flatpregs->children[d1.seq].instance_status=modified))
      print_pregnancy->child_list[child_cnt].instance_status = modified, print_pregnancy->child_list[
      child_cnt].instance_header = concat(captions->smodon," ",flatpregs->children[d1.seq].
       inst_dt_tm_disp," ",captions->smodby,
       " ",flatpregs->children[d1.seq].inst_prsnl_disp)
     ENDIF
     IF ((flatpregs->children[d1.seq].delivery_dt_precision=3))
      print_pregnancy->child_list[child_cnt].child_header = concat(captions->scloseddate," ",
       flatpregs->children[d1.seq].delivery_dt_tm_disp)
     ELSE
      print_pregnancy->child_list[child_cnt].child_header = concat(captions->sdeliverydate," ",
       flatpregs->children[d1.seq].delivery_dt_tm_disp)
     ENDIF
     IF ((flatpregs->children[d1.seq].sensitive_ind > 0)
      AND first_child_ind=1)
      print_pregnancy->child_list[child_cnt].child_header = concat(print_pregnancy->child_list[
       child_cnt].child_header," ",captions->ssensitive)
     ENDIF
     IF (size(flatpregs->children[d1.seq].child_label,1) > 0)
      print_pregnancy->child_list[child_cnt].child_header = concat(print_pregnancy->child_list[
       child_cnt].child_header," ",flatpregs->children[d1.seq].child_label)
     ENDIF
     IF ((flatpregs->children[d1.seq].gestation_age > 0))
      CALL formatega(flatpregs->children[d1.seq].gestation_age,egadisplay), print_pregnancy->
      child_list[child_cnt].child_text = concat(print_pregnancy->child_list[child_cnt].child_text," ",
       trim(egadisplay),";"),
      CALL echo(build("To check Trim value:",egadisplay))
     ELSEIF ((flatpregs->children[d1.seq].gestation_term_txt != ""))
      egadisplay = flatpregs->children[d1.seq].gestation_term_txt, print_pregnancy->child_list[
      child_cnt].child_text = concat(print_pregnancy->child_list[child_cnt].child_text," ",trim(
        egadisplay),";")
     ENDIF
     print_pregnancy->child_list[child_cnt].child_text = concat(print_pregnancy->child_list[child_cnt
      ].child_text," ",trim(uar_get_code_display(flatpregs->children[d1.seq].delivery_method_cd)),";"
      )
     IF ((flatpregs->children[d1.seq].gender_cd > 0))
      print_pregnancy->child_list[child_cnt].child_text = concat(print_pregnancy->child_list[
       child_cnt].child_text," ",trim(uar_get_code_display(flatpregs->children[d1.seq].gender_cd)),
       ";")
     ENDIF
     IF ((flatpregs->children[d1.seq].weight_amt > 0))
      print_pregnancy->child_list[child_cnt].child_text = concat(print_pregnancy->child_list[
       child_cnt].child_text," ",trim(build2(flatpregs->children[d1.seq].weight_amt),3)," ",trim(
        uar_get_code_display(flatpregs->children[d1.seq].weight_unit_cd)),
       ";")
     ENDIF
     anes_cnt = size(flatpregs->children[d1.seq].anesthesia,5)
     IF (anes_cnt > 0)
      print_pregnancy->child_list[child_cnt].child_text = concat(print_pregnancy->child_list[
       child_cnt].child_text," ",captions->sanesthesia)
      FOR (aidx = 1 TO anes_cnt)
       print_pregnancy->child_list[child_cnt].child_text = concat(print_pregnancy->child_list[
        child_cnt].child_text," ",flatpregs->children[d1.seq].anesthesia[aidx].anesthesia_type),
       IF (aidx=anes_cnt)
        print_pregnancy->child_list[child_cnt].child_text = concat(print_pregnancy->child_list[
         child_cnt].child_text,";")
       ELSE
        print_pregnancy->child_list[child_cnt].child_text = concat(print_pregnancy->child_list[
         child_cnt].child_text,", ")
       ENDIF
      ENDFOR
     ENDIF
     IF (size(flatpregs->children[d1.seq].delivery_hospital,1) > 0)
      print_pregnancy->child_list[child_cnt].child_text = concat(print_pregnancy->child_list[
       child_cnt].child_text," ",captions->sdeliveryhospital," ",flatpregs->children[d1.seq].
       delivery_hospital,
       ";")
     ENDIF
     preterm_cnt = size(flatpregs->children[d1.seq].preterm_labor,5)
     IF (preterm_cnt > 0)
      print_pregnancy->child_list[child_cnt].child_text = concat(print_pregnancy->child_list[
       child_cnt].child_text," ",captions->spretermlabor," ")
      FOR (pidx = 1 TO preterm_cnt)
       print_pregnancy->child_list[child_cnt].child_text = concat(print_pregnancy->child_list[
        child_cnt].child_text," ",flatpregs->children[d1.seq].preterm_labor[pidx].preterm_item),
       IF (pidx=preterm_cnt)
        print_pregnancy->child_list[child_cnt].child_text = concat(print_pregnancy->child_list[
         child_cnt].child_text,";")
       ELSE
        print_pregnancy->child_list[child_cnt].child_text = concat(print_pregnancy->child_list[
         child_cnt].child_text,", ")
       ENDIF
      ENDFOR
     ENDIF
     IF ((flatpregs->children[d1.seq].labor_duration > - (1)))
      print_pregnancy->child_list[child_cnt].child_text = concat(print_pregnancy->child_list[
       child_cnt].child_text," ",captions->slaborduration," ",build(flatpregs->children[d1.seq].
        labor_duration),
       " ",captions->sminutes,";")
     ENDIF
     maternal_cnt = size(flatpregs->children[d1.seq].mother_complications,5)
     IF (maternal_cnt > 0)
      print_pregnancy->child_list[child_cnt].child_text = concat(print_pregnancy->child_list[
       child_cnt].child_text," ",captions->smothercomp)
      FOR (midx = 1 TO maternal_cnt)
       print_pregnancy->child_list[child_cnt].child_text = concat(print_pregnancy->child_list[
        child_cnt].child_text," ",flatpregs->children[d1.seq].mother_complications[midx].mother_comp),
       IF (midx=maternal_cnt)
        print_pregnancy->child_list[child_cnt].child_text = concat(print_pregnancy->child_list[
         child_cnt].child_text,";")
       ELSE
        print_pregnancy->child_list[child_cnt].child_text = concat(print_pregnancy->child_list[
         child_cnt].child_text,", ")
       ENDIF
      ENDFOR
     ENDIF
     fetus_cnt = size(flatpregs->children[d1.seq].fetal_complications,5)
     IF (fetus_cnt > 0)
      print_pregnancy->child_list[child_cnt].child_text = concat(print_pregnancy->child_list[
       child_cnt].child_text," ",captions->sfetuscomp)
      FOR (fidx = 1 TO fetus_cnt)
       print_pregnancy->child_list[child_cnt].child_text = concat(print_pregnancy->child_list[
        child_cnt].child_text," ",flatpregs->children[d1.seq].fetal_complications[fidx].fetal_comp),
       IF (fidx=fetus_cnt)
        print_pregnancy->child_list[child_cnt].child_text = concat(print_pregnancy->child_list[
         child_cnt].child_text,";")
       ELSE
        print_pregnancy->child_list[child_cnt].child_text = concat(print_pregnancy->child_list[
         child_cnt].child_text,", ")
       ENDIF
      ENDFOR
     ENDIF
     print_pregnancy->child_list[child_cnt].child_text = concat(print_pregnancy->child_list[child_cnt
      ].child_text," ",captions->sneonateoutcome," ",trim(uar_get_code_display(flatpregs->children[d1
        .seq].neonate_outcome_cd)),
      ";"), neonate_cnt = size(flatpregs->children[d1.seq].neonate_complications,5)
     IF (neonate_cnt > 0)
      print_pregnancy->child_list[child_cnt].child_text = concat(print_pregnancy->child_list[
       child_cnt].child_text," ",captions->sneonatecomp)
      FOR (nidx = 1 TO neonate_cnt)
       print_pregnancy->child_list[child_cnt].child_text = concat(print_pregnancy->child_list[
        child_cnt].child_text," ",flatpregs->children[d1.seq].neonate_complications[nidx].
        neonate_comp),
       IF (nidx=neonate_cnt)
        print_pregnancy->child_list[child_cnt].child_text = concat(print_pregnancy->child_list[
         child_cnt].child_text,";")
       ELSE
        print_pregnancy->child_list[child_cnt].child_text = concat(print_pregnancy->child_list[
         child_cnt].child_text,", ")
       ENDIF
      ENDFOR
     ENDIF
     IF (size(flatpregs->children[d1.seq].child_name,1) > 0)
      print_pregnancy->child_list[child_cnt].child_text = concat(print_pregnancy->child_list[
       child_cnt].child_text," ",captions->schildname," ",flatpregs->children[d1.seq].child_name,
       ";")
     ENDIF
     IF (size(flatpregs->children[d1.seq].father_name,1) > 0)
      print_pregnancy->child_list[child_cnt].child_text = concat(print_pregnancy->child_list[
       child_cnt].child_text," ",captions->sfather," ",flatpregs->children[d1.seq].father_name,
       ";")
     ENDIF
     IF (size(flatpregs->children[d1.seq].child_comment,1) > 0)
      print_pregnancy->child_list[child_cnt].child_text = concat(print_pregnancy->child_list[
       child_cnt].child_text," ",captions->scomment," ",flatpregs->children[d1.seq].child_comment,
       ";")
     ENDIF
     prev_preg_id = flatpregs->children[d1.seq].pregnancy_id
    WITH maxcol = 132
   ;end select
   FOR (x = 1 TO size(print_pregnancy->child_list,5))
     IF ((print_pregnancy->child_list[x].instance_status=modified))
      CALL wrap_text(print_pregnancy->child_list[x].child_text,65,65)
     ELSE
      CALL wrap_text(print_pregnancy->child_list[x].child_text,70,70)
     ENDIF
     SET stat = alterlist(print_pregnancy->child_list[x].child_wrap,pt->line_cnt)
     FOR (y = 1 TO pt->line_cnt)
       SET print_pregnancy->child_list[x].child_wrap[y].child_line = pt->lns[y].line
     ENDFOR
   ENDFOR
   FREE RECORD flatpregs
 END ;Subroutine
 SUBROUTINE buildegatext(null)
   DECLARE ega_list_size = i4 WITH noconstant(size(egareply->gestation_info,5)), protect
   DECLARE datestr = vc WITH protect, noconstant
   DECLARE i = i4 WITH noconstant(0), protect
   SET stat = alterlist(print_pregnancy->current_ega_list,ega_list_size)
   FOR (i = 1 TO ega_list_size)
     SET print_pregnancy->current_ega_list[i].current_ega = concat(captions->scurrent," ",captions->
      sedd,": ",format(egareply->gestation_info[i].est_delivery_date,"@SHORTDATE;;Q"))
     IF ((egareply->gestation_info[i].delivered_ind=0))
      CALL formatega(egareply->gestation_info[i].current_gest_age,egadisplay)
      SET print_pregnancy->current_ega_list[i].current_ega = concat(print_pregnancy->
       current_ega_list[i].current_ega," ",captions->sega,": ",egadisplay)
     ELSE
      CALL formatega(egareply->gestation_info[i].gest_age_at_delivery,egadisplay)
      CALL formatfuzzydate(egareply->gestation_info[i].delivery_date,egareply->gestation_info[i].
       delivery_date_tz,0,0,datestr)
      SET print_pregnancy->current_ega_list[i].current_ega = concat(print_pregnancy->
       current_ega_list[i].current_ega," ",captions->sega,": ",egadisplay)
      SET print_pregnancy->current_ega_list[i].current_ega = concat(print_pregnancy->
       current_ega_list[i].current_ega," ",captions->sweeksatdelivery," ",datestr)
     ENDIF
     SET print_pregnancy->current_ega_list[i].current_ega = concat(print_pregnancy->current_ega_list[
      i].current_ega," (",captions->sprintdatetime," ",format(cnvtdatetime(sysdate),"@SHORTDATE;;Q"),
      ")")
     SET print_pregnancy->current_ega_list[i].org_id = egareply->gestation_info[i].org_id
   ENDFOR
 END ;Subroutine
 SUBROUTINE loadhxpregnancyedds(null)
   FREE RECORD eddrequest
   RECORD eddrequest(
     1 patient_id = f8
     1 pregnancy_id = f8
     1 edds[*]
       2 edd_id = f8
     1 previous_values_flag = i2
     1 encntr_id = f8
     1 org_sec_override = i2
     1 deleted_edds_flag = i2
   )
   CALL fillhxeddrequest(null)
   CALL echorecord(eddrequest)
   IF (size(eddrequest->edds,5) > 0)
    SET modify = nopredeclare
    EXECUTE dcp_get_pregnancy_edd  WITH replace("REQUEST",eddrequest), replace("REPLY",eddreply)
    SET modify = predeclare
    IF ((eddreply->status_data.status="S"))
     SET hx_edd_data_ind = 1
    ELSEIF ((eddreply->status_data.status="Z"))
     SET hx_edd_data_ind = 0
    ELSE
     SET failure_ind = true
     CALL fillsubeventstatus("EXECUTE","F","cp_pregnancy_versions",
      "dcp_get_pregnancy_edd: failure retrieving historical pregnancy EDDs")
     GO TO failure
    ENDIF
   ELSE
    SET hx_edd_data_ind = 0
   ENDIF
   FREE RECORD eddrequest
 END ;Subroutine
 SUBROUTINE (addeddtext(historical_ind=i2,preg_versions=i2) =null)
   DECLARE auth_id = f8 WITH noconstant(0.0), protect
   DECLARE author_cnt2 = i4 WITH noconstant(0), protect
   DECLARE auth_idx = i4 WITH noconstant(0), protect
   DECLARE creator_id = f8 WITH noconstant(0.0), protect
   DECLARE creator_idx = i4 WITH noconstant(0), protect
   DECLARE bpd_cm = f8 WITH noconstant(0.0), protect
   DECLARE crl_cm = f8 WITH noconstant(0.0), protect
   DECLARE hc_cm = f8 WITH noconstant(0.0), protect
   DECLARE mod_dt_tm_str = vc WITH noconstant(""), protect
   DECLARE original_entered_dt_str = vc WITH noconstant, protect
   DECLARE status_flag = i2 WITH noconstant(0), protect
   IF (historical_ind=1)
    SET curalias printrec print_pregnancy->child_list[childidx].edd_list[eddcnt]
   ELSE
    SET curalias printrec print_pregnancy->edd_list[eddcnt]
    SET printrec->org_id = flatedd->edd_list[d1.seq].org_id
   ENDIF
   SET auth_id = flatedd->edd_list[d1.seq].author_id
   SET author_cnt2 = size(authors->author_list,5)
   SET auth_idx = locateval(num,1,author_cnt2,auth_id,authors->author_list[num].prsnl_id)
   SET entered_dt_str = concat(format(flatedd->edd_list[d1.seq].entered_dt_tm,"@SHORTDATE;;Q")," ",
    format(flatedd->edd_list[d1.seq].entered_dt_tm,"@TIMENOSECONDS;;S"))
   SET mod_dt_tm_str = format(flatedd->edd_list[d1.seq].entered_dt_tm,"@SHORTDATETIME;;Q")
   IF ((flatedd->edd_list[d1.seq].instance_status=modified))
    SET printrec->edd_text = concat(printrec->edd_text," ",captions->smodon," ",mod_dt_tm_str,
     ";")
    SET printrec->edd_text = concat(printrec->edd_text," ",captions->smodby," ",authors->author_list[
     auth_idx].prsnl_name,
     ";")
   ELSEIF ((flatedd->edd_list[d1.seq].instance_status=deleted))
    SET printrec->edd_text = concat(printrec->edd_text," ",captions->sdeletedon," ",mod_dt_tm_str,
     ";")
    SET printrec->edd_text = concat(printrec->edd_text," ",captions->sdeletedby," ",authors->
     author_list[auth_idx].prsnl_name,
     ";")
   ENDIF
   SET status_flag = flatedd->edd_list[d1.seq].status_flag
   SET printrec->edd_text = concat(printrec->edd_text," ",captions->sstatus," ",captions->
    aeddstatuses[(status_flag+ 1)].seddstatus,
    ";")
   SET printrec->edd_text = concat(printrec->edd_text," ",captions->sedd,": ",format(flatedd->
     edd_list[d1.seq].est_delivery_date,"@SHORTDATE;;Q"),
    ";")
   CALL formatega(flatedd->edd_list[d1.seq].est_gest_age,egadisplay)
   SET printrec->edd_text = concat(printrec->edd_text," ",captions->segaonmethoddate,": ",egadisplay,
    ";")
   SET printrec->edd_text = concat(printrec->edd_text," ",captions->smethod," ",trim(
     uar_get_code_display(flatedd->edd_list[d1.seq].method_cd)),
    ";")
   SET printrec->edd_text = concat(printrec->edd_text," ",captions->smethoddate," ",format(flatedd->
     edd_list[d1.seq].method_dt_tm,"@SHORTDATE;;Q"),
    ";")
   SET printrec->edd_text = concat(printrec->edd_text," ",captions->sconfirmation," ",trim(
     uar_get_code_display(flatedd->edd_list[d1.seq].confirmation_cd)),
    ";")
   IF (preg_versions=1)
    SET printrec->edd_text = concat(printrec->edd_text," ",captions->sdocby," ",authors->author_list[
     auth_idx].prsnl_name,
     ";")
    SET printrec->edd_text = concat(printrec->edd_text," ",captions->sentereddate," ",entered_dt_str,
     ";")
   ELSE
    SET creator_id = flatedd->edd_list[d1.seq].creator_id
    IF (creator_id > 0)
     SET creator_idx = locateval(num,1,author_cnt2,creator_id,authors->author_list[num].prsnl_id)
     SET original_entered_dt_str = concat(format(flatedd->edd_list[d1.seq].original_entered_dttm,
       "@SHORTDATE;;Q")," ",format(flatedd->edd_list[d1.seq].original_entered_dttm,
       "@TIMENOSECONDS;;S"))
     SET printrec->edd_text = concat(printrec->edd_text," ",captions->sdocby," ",authors->
      author_list[creator_idx].prsnl_name,
      ";")
     SET printrec->edd_text = concat(printrec->edd_text," ",captions->sentereddate," ",
      original_entered_dt_str,
      ";")
     SET printrec->edd_text = concat(printrec->edd_text," ",captions->smodby," ",authors->
      author_list[auth_idx].prsnl_name,
      ";")
     SET printrec->edd_text = concat(printrec->edd_text," ",captions->smoddate," ",entered_dt_str,
      ";")
    ELSE
     SET printrec->edd_text = concat(printrec->edd_text," ",captions->sdocby," ",authors->
      author_list[auth_idx].prsnl_name,
      ";")
     SET printrec->edd_text = concat(printrec->edd_text," ",captions->sentereddate," ",entered_dt_str,
      ";")
    ENDIF
   ENDIF
   IF ((((flatedd->edd_list[d1.seq].method_cd=method_lmp_cd)) OR ((flatedd->edd_list[d1.seq].
   method_cd=method_doc_cd))) )
    IF ((flatedd->edd_list[d1.seq].descriptor_flag > 0))
     SET printrec->edd_text = concat(printrec->edd_text," ",captions->sdescription)
     IF (band(flatedd->edd_list[d1.seq].descriptor_flag,lmp_normal))
      SET printrec->edd_text = concat(printrec->edd_text," ",captions->snormal,",")
     ENDIF
     IF (band(flatedd->edd_list[d1.seq].descriptor_flag,lmp_abnormal))
      SET printrec->edd_text = concat(printrec->edd_text," ",captions->sabnormal,",")
     ENDIF
     IF (band(flatedd->edd_list[d1.seq].descriptor_flag,lmp_dateapprox))
      SET printrec->edd_text = concat(printrec->edd_text," ",captions->sdateapprox,",")
     ENDIF
     IF (band(flatedd->edd_list[d1.seq].descriptor_flag,lmp_datedef))
      SET printrec->edd_text = concat(printrec->edd_text," ",captions->sdatedef,",")
     ENDIF
     IF (band(flatedd->edd_list[d1.seq].descriptor_flag,lmp_dateunknown))
      SET printrec->edd_text = concat(printrec->edd_text," ",captions->sdateunknown,",")
     ENDIF
     IF (size(flatedd->edd_list[d1.seq].descriptor_txt,1) > 0)
      SET printrec->edd_text = concat(printrec->edd_text," ",flatedd->edd_list[d1.seq].descriptor_txt,
       ",")
     ENDIF
     SET printrec->edd_text = replace(printrec->edd_text,",",";",2)
    ENDIF
    IF (size(flatedd->edd_list[d1.seq].details,5)=1)
     SET printrec->edd_text = concat(printrec->edd_text," ",captions->sadditionaldetails)
     IF ((flatedd->edd_list[d1.seq].details[1].menarche_age > 0))
      SET printrec->edd_text = concat(printrec->edd_text," ",captions->sagemenarche," ",build(flatedd
        ->edd_list[d1.seq].details[1].menarche_age),
       " ",captions->syears,";")
     ENDIF
     IF ((flatedd->edd_list[d1.seq].details[1].menstrual_freq > 0))
      SET printrec->edd_text = concat(printrec->edd_text," ",captions->smensesfreq," ",build(flatedd
        ->edd_list[d1.seq].details[1].menstrual_freq),
       " ",captions->sdays,";")
     ENDIF
     IF ((flatedd->edd_list[d1.seq].details[1].prior_menses_dt_tm > null))
      SET printrec->edd_text = concat(printrec->edd_text," ",captions->sdatepriormenses," ",format(
        flatedd->edd_list[d1.seq].details[1].prior_menses_dt_tm,"@SHORTDATE;;Q"),
       ";")
     ENDIF
     IF ((flatedd->edd_list[d1.seq].details[1].pregnancy_test_dt_tm > null))
      SET printrec->edd_text = concat(printrec->edd_text," ",captions->sdatehomepregtest," ",format(
        flatedd->edd_list[d1.seq].details[1].pregnancy_test_dt_tm,"@SHORTDATE;;Q"),
       ";")
     ENDIF
     IF (size(flatedd->edd_list[d1.seq].details[1].lmp_symptoms_txt,1) > 0)
      SET printrec->edd_text = concat(printrec->edd_text," ",captions->slmpsymptoms," ",flatedd->
       edd_list[d1.seq].details[1].lmp_symptoms_txt,
       ";")
     ENDIF
    ENDIF
   ELSEIF ((flatedd->edd_list[d1.seq].method_cd=method_ultra_cd))
    IF ((((flatedd->edd_list[d1.seq].biparietal_diameter > 0)) OR ((((flatedd->edd_list[d1.seq].
    crown_rump_length > 0)) OR ((flatedd->edd_list[d1.seq].crown_rump_length > 0))) )) )
     SET printrec->edd_text = concat(printrec->edd_text," ",captions->sdescription)
     IF ((flatedd->edd_list[d1.seq].biparietal_diameter > 0))
      SET bpd_cm = (flatedd->edd_list[d1.seq].biparietal_diameter/ 10)
      SET printrec->edd_text = concat(printrec->edd_text," ",captions->sbiparietal," ",trim(build2(
         bpd_cm),3),
       captions->scm,";")
     ENDIF
     IF ((flatedd->edd_list[d1.seq].crown_rump_length > 0))
      SET crl_cm = (flatedd->edd_list[d1.seq].crown_rump_length/ 10)
      SET printrec->edd_text = concat(printrec->edd_text," ",captions->scrownrump," ",trim(build2(
         crl_cm),3),
       captions->scm,";")
     ENDIF
     IF ((flatedd->edd_list[d1.seq].head_circumference > 0))
      SET hc_cm = (flatedd->edd_list[d1.seq].head_circumference/ 10)
      SET printrec->edd_text = concat(printrec->edd_text," ",captions->sheadcirc," ",trim(build2(
         hc_cm),3),
       captions->scm,";")
     ENDIF
    ENDIF
   ELSEIF ((flatedd->edd_list[d1.seq].method_cd=method_art_cd))
    IF ((flatedd->edd_list[d1.seq].descriptor_cd > 0))
     SET printrec->edd_text = concat(printrec->edd_text," ",captions->sdescription," ",trim(
       uar_get_code_display(flatedd->edd_list[d1.seq].descriptor_cd)),
      ";")
    ELSEIF (size(flatedd->edd_list[d1.seq].descriptor_txt,1) > 0)
     SET printrec->edd_text = concat(printrec->edd_text," ",captions->sdescription," ",flatedd->
      edd_list[d1.seq].descriptor_txt,
      ";")
    ENDIF
   ENDIF
   IF (size(flatedd->edd_list[d1.seq].edd_comment,1) > 0)
    SET printrec->edd_text = concat(printrec->edd_text," ",captions->scomment," ",flatedd->edd_list[
     d1.seq].edd_comment)
   ENDIF
   SET printrec->instance_status = flatedd->edd_list[d1.seq].instance_status
   SET curalias printrec off
 END ;Subroutine
 FREE RECORD flatedd
 RECORD flatedd(
   1 edd_list[*]
     2 pregnancy_estimate_id = f8
     2 pregnancy_id = f8
     2 status_flag = i2
     2 method_cd = f8
     2 method_disp = c40
     2 method_desc = vc
     2 method_mean = c12
     2 method_dt_tm = dq8
     2 descriptor_cd = f8
     2 descriptor_disp = c40
     2 descriptor_desc = vc
     2 descriptor_mean = c12
     2 descriptor_txt = vc
     2 descriptor_flag = i2
     2 edd_comment = vc
     2 author_id = f8
     2 crown_rump_length = f8
     2 biparietal_diameter = f8
     2 head_circumference = f8
     2 est_gest_age = i4
     2 est_delivery_date = dq8
     2 confirmation_cd = f8
     2 confirmation_disp = c40
     2 confirmation_desc = vc
     2 confirmation_mean = c12
     2 prev_edd_id = f8
     2 active_ind = i2
     2 entered_dt_tm = dq8
     2 updt_id = f8
     2 updt_dt_tm = dq8
     2 details[*]
       3 lmp_symptoms_txt = vc
       3 pregnancy_test_dt_tm = dq8
       3 contraception_ind = i2
       3 contraception_duration = i4
       3 breastfeeding_ind = i2
       3 menarche_age = i4
       3 menstrual_freq = i4
       3 prior_menses_dt_tm = dq8
     2 creator_id = f8
     2 original_entered_dttm = dq8
     2 org_id = f8
     2 instance_status = i2
     2 sort_dt_tm = dq8
     2 sort_status = i2
 )
 RECORD print_pregnancy(
   1 current_ega_list[*]
     2 current_ega = vc
     2 current_ega_wrap[*]
       3 current_ega_line = vc
     2 org_id = f8
   1 edd_list[*]
     2 edd_text = vc
     2 edd_wrap[*]
       3 edd_line = vc
     2 org_id = f8
     2 instance_status = i2
   1 gravida_text = vc
   1 gravida_wrap[*]
     2 gravida_line = vc
   1 child_list[*]
     2 pregnancy_id = f8
     2 instance_status = i2
     2 instance_header = vc
     2 child_header = vc
     2 child_text = vc
     2 child_wrap[*]
       3 child_line = vc
     2 edd_list[*]
       3 edd_text = vc
       3 edd_wrap[*]
         4 edd_line = vc
       3 instance_status = i2
 )
 FREE RECORD authors
 RECORD authors(
   1 author_list[*]
     2 prsnl_id = f8
     2 prsnl_name = vc
 )
 FREE RECORD organizations
 RECORD organizations(
   1 organization_list[*]
     2 org_id = f8
     2 org_name = vc
 )
 CALL loadcurrentega(null)
 CALL echo(build("active_preg_ind: ",active_preg_ind))
 IF (active_preg_ind > 0)
  CALL loadpregnancyedds(false)
  CALL flattenedd(false)
  CALL loadeddorgs(null)
  CALL loadeddprsnl(null)
 ENDIF
 CALL loadpregnancyhistory(null)
 CALL loadgravida(null)
 CALL flattenpregnancies(null)
 IF (active_preg_ind > 0
  AND edd_data_ind > 0)
  CALL buildeddtext(null)
 ENDIF
 IF (gravida_data_ind > 0)
  CALL buildgravidatext(null)
 ENDIF
 IF (phx_data_ind > 0)
  CALL buildphxtext(null)
  CALL loadhxpregnancyedds(null)
  IF (hx_edd_data_ind > 0)
   CALL flattenedd(false)
   CALL loadeddprsnl(authors)
   CALL buildhxeddtext(null)
  ENDIF
 ENDIF
 CALL formatreport(null)
#failure
 CALL echo(build2("Active: ",active_preg_ind))
 CALL echo(build2("EDD: ",edd_data_ind))
 CALL echo(build2("GRAV: ",gravida_data_ind))
 CALL echo(build2("PHX: ",phx_data_ind))
 CALL echo(build2("HxEDD: ",hx_edd_data_ind))
 IF (active_preg_ind=0
  AND edd_data_ind=0
  AND phx_data_ind=0
  AND gravida_data_ind=0
  AND hx_edd_data_ind=0)
  SET zero_ind = true
 ELSE
  SET zero_ind = false
 ENDIF
 SET error_code = error(error_msg,1)
 IF (error_code != 0)
  SET reply->status_data.status = "F"
  CALL fillsubeventstatus("ERROR","F","cp_get_pregnancy",error_msg)
 ELSEIF (failure_ind=true)
  SET reply->status_data.status = "F"
 ELSEIF (zero_ind=true)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SUBROUTINE loadpregnancyhistory(null)
   FREE RECORD phxrequest
   RECORD phxrequest(
     1 person_id = f8
     1 problem_id = f8
     1 pregnancies[*]
       2 pregnancy_id = f8
     1 encntr_id = f8
     1 org_sec_override = i2
   )
   SET phxrequest->person_id = request->person_id
   SET phxrequest->encntr_id = request->encntr_id
   SET modify = nopredeclare
   EXECUTE dcp_get_phx  WITH replace("REQUEST",phxrequest), replace("REPLY",phxreply)
   SET modify = predeclare
   IF ((phxreply->status_data.status="S"))
    SET phx_data_ind = 1
   ELSEIF ((phxreply->status_data.status="Z"))
    SET phx_data_ind = 0
   ELSE
    SET failure_ind = true
    CALL logerror("EXECUTE","F","cp_get_pregnancy",
     "dcp_get_phx: failure retrieving pregnancy history")
    GO TO failure
   ENDIF
   FREE RECORD phxrequest
 END ;Subroutine
 SUBROUTINE formatreport(null)
   DECLARE egasize = i4 WITH noconstant(0), protect
   DECLARE eddsize = i4 WITH noconstant(0), protect
   DECLARE orgsize = i4 WITH noconstant(0), protect
   DECLARE gravsize = i4 WITH noconstant(0), protect
   DECLARE childsize = i4 WITH noconstant(0), protect
   DECLARE childseq = i4 WITH protect, noconstant(0)
   DECLARE i = i4 WITH noconstant(0), protect
   DECLARE linecnt = i4 WITH noconstant(0), protect
   DECLARE j = i4 WITH noconstant(0), protect
   DECLARE x = i4 WITH noconstant(0), protect
   DECLARE org_id = f8 WITH noconstant(0.0), protect
   DECLARE k = i4 WITH noconstant(0), protect
   DECLARE pagevar = i4 WITH noconstant(0), protect
   DECLARE nullpos = i2 WITH noconstant(0), protect
   DECLARE done = i2 WITH noconstant(0), protect
   SELECT
    FROM (dummyt d1  WITH seq = 1)
    PLAN (d1)
    DETAIL
     IF (active_preg_ind > 0)
      col 0, captions->seddheader, row + 1,
      row + 1
      IF (((preg_org_sec_ind=0) OR ((((request->encntr_id > 0)) OR (size(organizations->
       organization_list,5)=1)) )) )
       egasize = size(print_pregnancy->current_ega_list,5)
       FOR (i = 1 TO egasize)
         linecnt = size(print_pregnancy->current_ega_list[i].current_ega_wrap,5)
         FOR (j = 1 TO linecnt)
           col 0, print_pregnancy->current_ega_list[i].current_ega_wrap[j].current_ega_line, row + 1
         ENDFOR
         row + 1
       ENDFOR
       eddsize = size(print_pregnancy->edd_list,5)
       FOR (i = 1 TO eddsize)
         linecnt = size(print_pregnancy->edd_list[i].edd_wrap,5)
         FOR (j = 1 TO linecnt)
           col 5, print_pregnancy->edd_list[i].edd_wrap[j].edd_line, row + 1
         ENDFOR
         row + 1
       ENDFOR
      ELSE
       orgsize = size(organizations->organization_list,5)
       FOR (x = 1 TO orgsize)
         col 0, captions->sorganization, " ",
         organizations->organization_list[x].org_name, row + 2, org_id = organizations->
         organization_list[x].org_id,
         CALL echo(build("org_id :",org_id)), egasize = size(print_pregnancy->current_ega_list,5)
         FOR (i = 1 TO egasize)
           IF ((print_pregnancy->current_ega_list[i].org_id=org_id))
            linecnt = size(print_pregnancy->current_ega_list[i].current_ega_wrap,5)
            FOR (j = 1 TO linecnt)
              col 0, print_pregnancy->current_ega_list[i].current_ega_wrap[j].current_ega_line, row
               + 1
            ENDFOR
            row + 1
           ENDIF
         ENDFOR
         eddsize = size(print_pregnancy->edd_list,5)
         FOR (i = 1 TO eddsize)
           IF ((print_pregnancy->edd_list[i].org_id=org_id))
            linecnt = size(print_pregnancy->edd_list[i].edd_wrap,5)
            FOR (j = 1 TO linecnt)
              col 5, print_pregnancy->edd_list[i].edd_wrap[j].edd_line, row + 1
            ENDFOR
            row + 1
           ENDIF
         ENDFOR
       ENDFOR
      ENDIF
     ENDIF
     gravsize = size(print_pregnancy->gravida_wrap,5)
     IF (gravsize > 0)
      col 0, captions->spregheader, row + 2
     ENDIF
     FOR (i = 1 TO gravsize)
       col 0, print_pregnancy->gravida_wrap[i].gravida_line, row + 1
     ENDFOR
     IF (gravsize > 0)
      row + 1
     ENDIF
     childsize = size(print_pregnancy->child_list,5)
     FOR (i = 1 TO childsize)
       linecnt = size(print_pregnancy->child_list[i].child_wrap,5)
       IF (i > 1
        AND (print_pregnancy->child_list[i].pregnancy_id=print_pregnancy->child_list[(i - 1)].
       pregnancy_id))
        col 10, print_pregnancy->child_list[i].child_header
       ELSE
        col 0, print_pregnancy->child_list[i].child_header
       ENDIF
       row + 1
       FOR (j = 1 TO linecnt)
         col 10, print_pregnancy->child_list[i].child_wrap[j].child_line, row + 1
       ENDFOR
       row + 1
       IF (((i=childsize) OR ((print_pregnancy->child_list[i].pregnancy_id != print_pregnancy->
       child_list[(i+ 1)].pregnancy_id))) )
        IF (size(print_pregnancy->child_list[(i - childseq)].edd_list,5) > 0)
         col 5, captions->seddheader, row + 1,
         row + 1
         FOR (j = 1 TO size(print_pregnancy->child_list[(i - childseq)].edd_list,5))
           linecnt = size(print_pregnancy->child_list[(i - childseq)].edd_list[j].edd_wrap,5)
           FOR (k = 1 TO linecnt)
             col 10, print_pregnancy->child_list[(i - childseq)].edd_list[j].edd_wrap[k].edd_line,
             row + 1
           ENDFOR
           row + 1
         ENDFOR
         row + 1
        ENDIF
        childseq = 0
       ELSE
        childseq += 1
       ENDIF
     ENDFOR
    FOOT PAGE
     numrows = row
     IF (numrows > 0)
      stat = alterlist(reply->qual,((ln+ numrows)+ 1))
      FOR (pagevar = 0 TO numrows)
        ln += 1, reply->qual[ln].line = reportrow((pagevar+ 1)), done = false
        WHILE (done=false)
         nullpos = findstring(char(0),reply->qual[ln].line),
         IF (nullpos > 0)
          stat = movestring(" ",1,reply->qual[ln].line,nullpos,1)
         ELSE
          done = true
         ENDIF
        ENDWHILE
      ENDFOR
     ENDIF
     reply->num_lines = ln
    WITH nocounter, maxcol = 132
   ;end select
 END ;Subroutine
 SUBROUTINE buildeddtext(null)
   DECLARE flatedd_size = i4 WITH constant(size(flatedd->edd_list,5)), protect
   DECLARE ega_idx = i4 WITH noconstant(0), protect
   DECLARE ega_list_size = i4 WITH noconstant(size(egareply->gestation_info,5)), protect
   DECLARE edd_id = f8 WITH noconstant(0.0), protect
   DECLARE eddcnt = i4 WITH noconstant(0), protect
   DECLARE x = i4 WITH noconstant(0), protect
   DECLARE y = i4 WITH noconstant(0), protect
   CALL echo(build("ega_list_size: ",ega_list_size))
   CALL buildegatext(null)
   SET stat = alterlist(print_pregnancy->edd_list,flatedd_size)
   SELECT INTO "nl:"
    edd_id = flatedd->edd_list[d1.seq].pregnancy_estimate_id
    FROM (dummyt d1  WITH seq = flatedd_size)
    ORDER BY flatedd->edd_list[d1.seq].status_flag DESC, flatedd->edd_list[d1.seq].sort_dt_tm DESC
    HEAD REPORT
     eddcnt = 0
    HEAD edd_id
     eddcnt += 1,
     CALL addeddtext(false,false)
    WITH maxcol = 130
   ;end select
   FOR (x = 1 TO size(print_pregnancy->current_ega_list,5))
     CALL wrap_text(print_pregnancy->current_ega_list[x].current_ega,80,80)
     SET stat = alterlist(print_pregnancy->current_ega_list[x].current_ega_wrap,pt->line_cnt)
     FOR (y = 1 TO pt->line_cnt)
       SET print_pregnancy->current_ega_list[x].current_ega_wrap[y].current_ega_line = pt->lns[y].
       line
     ENDFOR
   ENDFOR
   FOR (x = 1 TO size(print_pregnancy->edd_list,5))
     CALL wrap_text(print_pregnancy->edd_list[x].edd_text,70,70)
     SET stat = alterlist(print_pregnancy->edd_list[x].edd_wrap,pt->line_cnt)
     FOR (y = 1 TO pt->line_cnt)
       SET print_pregnancy->edd_list[x].edd_wrap[y].edd_line = pt->lns[y].line
     ENDFOR
   ENDFOR
   SET stat = alterlist(authors->author_list,0)
 END ;Subroutine
 SUBROUTINE fillhxeddrequest(null)
   DECLARE totalchildcnt = i4 WITH noconstant(size(print_pregnancy->child_list,5))
   DECLARE eddidx = i4 WITH noconstant(0)
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = totalchildcnt),
     pregnancy_estimate pe
    PLAN (d1)
     JOIN (pe
     WHERE expand(num,1,totalchildcnt,pe.pregnancy_id,print_pregnancy->child_list[num].pregnancy_id)
      AND ((pe.active_ind+ 0)=1))
    ORDER BY pe.pregnancy_id, pe.pregnancy_estimate_id
    HEAD REPORT
     eddidx = 0, stat = alterlist(eddrequest->edds,10)
    HEAD pe.pregnancy_estimate_id
     eddidx += 1
     IF (mod(eddidx,10)=1)
      stat = alterlist(eddrequest->edds,(eddidx+ 9))
     ENDIF
     eddrequest->edds[eddidx].edd_id = pe.pregnancy_estimate_id
    FOOT REPORT
     stat = alterlist(eddrequest->edds,eddidx)
    WITH nocounter
   ;end select
   SET eddrequest->previous_values_flag = 1
 END ;Subroutine
 SUBROUTINE buildhxeddtext(null)
   DECLARE eddlistsize = i4 WITH noconstant(size(flatedd->edd_list,5))
   DECLARE childcnt = i4 WITH noconstant(size(print_pregnancy->child_list,5))
   DECLARE prevchildidx = i4 WITH noconstant(0)
   DECLARE eddcnt = i4 WITH noconstant(0), protect
   DECLARE edd_id = f8 WITH noconstant(0.0), protect
   DECLARE childidx = i4 WITH noconstant(0), protect
   DECLARE i = i4 WITH noconstant(0), protect
   DECLARE x = i4 WITH noconstant(0), protect
   DECLARE y = i4 WITH noconstant(0), protect
   SELECT INTO "nl:"
    pregnancy_id = flatedd->edd_list[d1.seq].pregnancy_id, edd_id = flatedd->edd_list[d1.seq].
    pregnancy_estimate_id
    FROM (dummyt d1  WITH seq = eddlistsize)
    ORDER BY flatedd->edd_list[d1.seq].pregnancy_id, flatedd->edd_list[d1.seq].status_flag DESC,
     flatedd->edd_list[d1.seq].sort_dt_tm DESC
    HEAD REPORT
     eddcnt = 0, prevchildidx = 0
    HEAD edd_id
     childidx = locateval(num,1,childcnt,pregnancy_id,print_pregnancy->child_list[num].pregnancy_id),
     stat = alterlist(print_pregnancy->child_list[childidx].edd_list,eddlistsize)
     IF (childidx != prevchildidx)
      eddcnt = 0
     ENDIF
     eddcnt += 1,
     CALL addeddtext(true,false), prevchildidx = childidx
    FOOT  edd_id
     stat = alterlist(print_pregnancy->child_list[childidx].edd_list,eddcnt)
    WITH maxcol = 132
   ;end select
   FOR (i = 1 TO size(print_pregnancy->child_list,5))
     FOR (x = 1 TO size(print_pregnancy->child_list[i].edd_list,5))
       CALL wrap_text(print_pregnancy->child_list[i].edd_list[x].edd_text,70,70)
       SET stat = alterlist(print_pregnancy->child_list[i].edd_list[x].edd_wrap,pt->line_cnt)
       FOR (y = 1 TO pt->line_cnt)
         SET print_pregnancy->child_list[i].edd_list[x].edd_wrap[y].edd_line = pt->lns[y].line
       ENDFOR
     ENDFOR
   ENDFOR
   SET stat = alterlist(authors->author_list,0)
 END ;Subroutine
 SET modify = nopredeclare
 FREE RECORD print_pregnancy
 FREE RECORD eddreply
 FREE RECORD authors
 FREE RECORD captions
 FREE RECORD flatedd
 DECLARE last_mod = vc WITH protect, noconstant("MOD 005 - 13/04/17")
 CALL echo(last_mod)
END GO
