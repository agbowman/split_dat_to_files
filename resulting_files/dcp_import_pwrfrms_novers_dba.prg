CREATE PROGRAM dcp_import_pwrfrms_novers:dba
 FREE SET request
 RECORD request(
   1 dcp_forms_ref_id = f8
   1 description = vc
   1 definition = vc
   1 task_assay_cd = f8
   1 event_cd = f8
   1 done_charting_ind = i2
   1 active_ind = i2
   1 width = i4
   1 height = i4
   1 flags = i4
   1 beg_effective_dt_tm = dq8
   1 end_effective_dt_tm = dq8
   1 updt_cnt = i4
   1 sect_info_passed_ind = i2
   1 sect_list[*]
     2 dcp_forms_def_id = f8
     2 section_seq = i4
     2 dcp_section_ref_id = f8
     2 description = vc
     2 definition = vc
     2 task_assay_cd = f8
     2 event_cd = f8
     2 active_ind = i2
     2 width = i4
     2 height = i4
     2 flags = i4
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 updt_cnt = i4
     2 input_info_passed_ind = i2
     2 input_list[*]
       3 dcp_input_ref_id = f8
       3 description = vc
       3 module = vc
       3 input_ref_seq = i4
       3 input_type = i4
       3 nv[*]
         4 pvc_name = vc
         4 pvc_value = vc
         4 merge_name = vc
         4 merge_id = f8
         4 sequence = i2
 )
 RECORD form(
   1 dcp_forms_ref_id = f8
   1 description = vc
   1 done_charting_ind = i2
   1 definition = vc
   1 width = i4
   1 height = i4
   1 enforce_required_ind = i2
   1 event_set_name = vc
   1 flags = i4
   1 section_cnt = i4
   1 section_qual[*]
     2 section_seq = i4
     2 flags = i4
     2 dcp_section_ref_id = f8
     2 description = vc
     2 definition = vc
     2 width = i4
     2 height = i4
     2 input_cnt = i4
     2 input_qual[*]
       3 dcp_input_ref_id = f8
       3 description = vc
       3 input_ref_seq = i4
       3 input_type = i4
       3 module = vc
       3 nv_cnt = i4
       3 nv_qual[*]
         4 pvc_name = vc
         4 pvc_value = vc
         4 merge_name = vc
         4 merge_id = f8
 )
 RECORD reply(
   1 dcp_forms_ref_id = f8
   1 section_cnt = i4
   1 sections[*]
     2 dcp_section_ref_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RECORD blob(
   1 qual[*]
     2 line = vc
 )
 SET numrows = 0
 SET new_dcp_forms_ref_id = 0.0
 SET new_dcp_forms_def_id = 0.0
 SET new_section_ref_id = 0.0
 SET new_input_ref_id = 0.0
 SET tmpformdesc = fillstring(200," ")
 SET tempsecdesc = fillstring(200," ")
 SET tmp_sectionid = 0.0
 SET tmp_inputid = 0.0
 SET prev_inputid = 0.0
 SET prev_sectionid = 0.0
 SET new_merge_id = 0.0
 SET tmp_pvc_value = fillstring(256," ")
 SET newline_cnt = 0
 SET numrows = size(requestin->list_0,5)
 SET dup_sect_exists = 0
 SET dup_form_exists = 0
 SET need_to_exit_loop = 0
 SET section_cnt = 0
 SET input_cnt = 0
 SET nv_cnt = 0
 SET tvar1 = 1
 SET rvar = 0
 SELECT INTO "dcp_import_powerforms.log"
  rvar
  HEAD REPORT
   curdate"dd-mmm-yyyy;;d", "-", curtime"hh:mm;;m",
   col + 1, "**DCP PowerForms Import Log", row + 1,
   col 0, "Form Being Imported: ", requestin->list_0[1].form_description
  DETAIL
   col 0
  WITH nocounter, format = variable, noformfeed,
   maxcol = 132, maxrow = 1
 ;end select
 SET lvar = 1
 CALL logrownum(numrows,lvar)
 WHILE (lvar <= numrows)
   IF (lvar=1)
    SET tmpformdesc = trim(requestin->list_0[lvar].form_description)
    CALL checkdupform(tmpformdesc)
   ENDIF
   IF (dup_form_exists=0)
    IF (lvar=1)
     SET request->dcp_forms_ref_id = 0
     SET request->description = requestin->list_0[lvar].form_description
     SET request->definition = requestin->list_0[lvar].form_definition
     SET request->task_assay_cd = 0
     SET request->event_cd = requestin->list_0[lvar].form_event_cd
     SET request->done_charting_ind = cnvtint(requestin->list_0[lvar].done_charting_ind)
     SET request->active_ind = 1
     SET request->width = cnvtint(requestin->list_0[lvar].form_width)
     SET request->height = cnvtint(requestin->list_0[lvar].form_height)
     SET request->flags = cnvtint(requestin->list_0[lvar].form_flags)
     SET request->beg_effective_dt_tm = cnvtdatetime(curdate,curtime3)
     SET request->end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00.00")
    ENDIF
    IF ((((requestin->list_0[lvar].dcp_section_ref_id != requestin->list_0[(lvar - 1)].
    dcp_section_ref_id)) OR (lvar=1)) )
     SET dup_sect_exists = 0
     SET tmpsecdesc = trim(requestin->list_0[lvar].section_description)
     CALL checkdupsection(tmpsecdesc)
     IF (dup_sect_exists=0)
      SET request->sect_info_passed_ind = 1
      SET section_cnt = (section_cnt+ 1)
      IF (section_cnt > size(request->sect_list,5))
       SET stat = alterlist(request->sect_list,(section_cnt+ 1))
      ENDIF
      IF (section_cnt > 1)
       IF (input_cnt > 0)
        SET stat = alterlist(request->sect_list[(section_cnt - 1)].input_list,input_cnt)
       ENDIF
      ENDIF
      SET input_cnt = 0
      CALL logsectioninfo(lvar)
      SET request->sect_list[section_cnt].dcp_forms_def_id = 0
      SET request->sect_list[section_cnt].section_seq = cnvtint(requestin->list_0[lvar].section_seq)
      SET request->sect_list[section_cnt].dcp_section_ref_id = 0
      SET request->sect_list[section_cnt].description = requestin->list_0[lvar].section_description
      SET request->sect_list[section_cnt].definition = requestin->list_0[lvar].section_definition
      SET request->sect_list[section_cnt].task_assay_cd = 0
      SET request->sect_list[section_cnt].event_cd = 0
      SET request->sect_list[section_cnt].active_ind = 1
      SET request->sect_list[section_cnt].width = cnvtint(requestin->list_0[lvar].section_width)
      SET request->sect_list[section_cnt].height = cnvtint(requestin->list_0[lvar].section_height)
      SET request->sect_list[section_cnt].flags = cnvtint(requestin->list_0[lvar].section_flags)
      SET request->sect_list[section_cnt].beg_effective_dt_tm = cnvtdatetime(curdate,curtime3)
      SET request->sect_list[section_cnt].end_effective_dt_tm = cnvtdatetime(
       "31-dec-2100 00:00:00.00")
     ELSE
      CALL logdupsection(lvar)
      SET lvar = (numrows+ 1)
      SET need_to_exit_loop = 1
     ENDIF
    ENDIF
    IF (need_to_exit_loop=0)
     IF ((((requestin->list_0[lvar].dcp_input_ref_id != requestin->list_0[(lvar - 1)].
     dcp_input_ref_id)) OR (lvar=1)) )
      SET nv_cnt = 0
      SET input_cnt = (input_cnt+ 1)
      IF (input_cnt > size(request->sect_list[section_cnt].input_list,5))
       SET stat = alterlist(request->sect_list[section_cnt].input_list,(input_cnt+ 1))
      ENDIF
      SET request->sect_list[section_cnt].input_info_passed_ind = 1
      SET request->sect_list[section_cnt].input_list[input_cnt].dcp_input_ref_id = 0
      SET request->sect_list[section_cnt].input_list[input_cnt].description = requestin->list_0[lvar]
      .input_description
      SET request->sect_list[section_cnt].input_list[input_cnt].module = requestin->list_0[lvar].
      module
      SET request->sect_list[section_cnt].input_list[input_cnt].input_ref_seq = cnvtint(requestin->
       list_0[lvar].input_ref_seq)
      SET request->sect_list[section_cnt].input_list[input_cnt].input_type = cnvtint(requestin->
       list_0[lvar].input_type)
      CALL loginputinfo(lvar)
     ENDIF
     IF ((((requestin->list_0[lvar].pvc_name != requestin->list_0[(lvar - 1)].pvc_name)) OR ((((
     requestin->list_0[lvar].pvc_name=requestin->list_0[(lvar - 1)].pvc_name)
      AND (requestin->list_0[lvar].merge_id != requestin->list_0[(lvar - 1)].merge_id)) OR (lvar=1))
     )) )
      SET nv_cnt = (nv_cnt+ 1)
      IF (nv_cnt > size(request->sect_list[section_cnt].input_list[input_cnt].nv,5))
       SET stat = alterlist(request->sect_list[section_cnt].input_list[input_cnt].nv,(nv_cnt+ 1))
      ENDIF
      SET request->sect_list[section_cnt].input_list[input_cnt].nv[nv_cnt].pvc_name = requestin->
      list_0[lvar].pvc_name
      IF ((requestin->list_0[lvar].pvc_value="TRUE"))
       SET request->sect_list[section_cnt].input_list[input_cnt].nv[nv_cnt].pvc_value = "true"
      ELSE
       SET tmp_pvc_value = requestin->list_0[lvar].pvc_value
       SET lf = concat(char(13),char(10))
       SET sc = concat("*","/","~")
       SET tmp_text2 = fillstring(256," ")
       SET tmp_text3 = fillstring(256," ")
       SET newline_cnt = 0
       SET length = textlen(tmp_pvc_value)
       SET cr = findstring(sc,tmp_pvc_value)
       WHILE (cr > 0)
         SET tmp_text2 = substring(1,(cr - 1),tmp_pvc_value)
         SET tmp_text3 = substring((cr+ 3),(length - (cr+ 3)),tmp_pvc_value)
         SET nl = movestring(lf,1,tmp_text2,cr,2)
         SET newline_cnt = (newline_cnt+ 1)
         SET stat = alterlist(blob->qual,newline_cnt)
         SET blob->qual[newline_cnt].line = tmp_text2
         SET tmp_pvc_value = tmp_text3
         SET length = textlen(tmp_pvc_value)
         SET cr = findstring(sc,tmp_pvc_value)
       ENDWHILE
       IF (newline_cnt > 0)
        SET tmp_text2 = substring((cr+ 1),(length - (cr+ 2)),tmp_pvc_value)
        SET newline_cnt = (newline_cnt+ 1)
        SET stat = alterlist(blob->qual,newline_cnt)
        SET blob->qual[newline_cnt].line = tmp_text2
        SET tmp_text2 = fillstring(700," ")
        SET tmp_text2 = blob->qual[1].line
        SET cr = findstring(lf,tmp_text2)
        SET idx = 1
        SET startpos = cr
        WHILE (cr > 0)
          SET idx = (idx+ 1)
          SET length = textlen(blob->qual[idx].line)
          SET nl = movestring(blob->qual[idx].line,1,tmp_text2,(cr+ 2),length)
          SET cr = findstring(lf,tmp_text2,(startpos+ 2))
          SET startpos = cr
        ENDWHILE
        SET tmp_pvc_value = tmp_text2
       ELSE
        SET tmp_pvc_value = requestin->list_0[lvar].pvc_value
       ENDIF
       SET request->sect_list[section_cnt].input_list[input_cnt].nv[nv_cnt].pvc_value = trim(
        tmp_pvc_value)
      ENDIF
      SET new_merge_id = 0.0
      SET request->sect_list[section_cnt].input_list[input_cnt].nv[nv_cnt].merge_name = requestin->
      list_0[lvar].merge_name
      IF ((request->sect_list[section_cnt].input_list[input_cnt].nv[nv_cnt].merge_name=
      "DISCRETE_TASK_ASSAY"))
       SELECT INTO "nl:"
        d.task_assay_cd
        FROM discrete_task_assay d
        WHERE d.mnemonic=trim(requestin->list_0[lvar].dta_mnemonic)
        DETAIL
         new_merge_id = d.task_assay_cd
        WITH nocounter
       ;end select
      ELSEIF ((request->sect_list[section_cnt].input_list[input_cnt].nv[nv_cnt].merge_name=
      "CODE_VALUE"))
       IF ((request->sect_list[section_cnt].input_list[input_cnt].nv[nv_cnt].pvc_name="unit*"))
        SELECT INTO "nl:"
         c.display
         FROM code_value c
         WHERE c.display=trim(requestin->list_0[lvar].code_value_display)
          AND c.code_set=54
         DETAIL
          new_merge_id = c.code_value
         WITH nocounter
        ;end select
       ELSEIF ((request->sect_list[section_cnt].input_list[input_cnt].nv[nv_cnt].pvc_name="template*"
       ))
        SELECT INTO "nl:"
         c.display
         FROM code_value c
         WHERE c.display=trim(requestin->list_0[lvar].code_value_display)
          AND c.code_set=16529
         DETAIL
          new_merge_id = c.code_value
         WITH nocounter
        ;end select
       ENDIF
      ENDIF
      SET request->sect_list[section_cnt].input_list[input_cnt].nv[nv_cnt].merge_id = new_merge_id
      SET request->sect_list[section_cnt].input_list[input_cnt].nv[nv_cnt].sequence = cnvtint(
       requestin->list_0[lvar].sequence)
     ENDIF
    ENDIF
   ELSE
    CALL logdupform(lvar)
    SET lvar = (numrows+ 1)
   ENDIF
   SET lvar = (lvar+ 1)
   SET dup_exists = 0
 ENDWHILE
 SET stat = alterlist(request->sect_list,section_cnt)
 CALL logrequest(rvar)
 IF (dup_form_exists=0
  AND dup_sect_exists=0)
  EXECUTE dcp_upd_dcp_form_all
  IF ((reply->status_data.status="S"))
   CALL logformok(tvar1)
  ELSE
   CALL logformnotok(tvar1)
  ENDIF
 ELSE
  CALL logformnotok(tvar1)
 ENDIF
 GO TO exit_script
 SUBROUTINE checkdupform(formdesc)
   SELECT INTO "nl:"
    f.description
    FROM dcp_forms_ref f
    WHERE f.description=formdesc
    DETAIL
     dup_form_exists = 1
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE checkdupsection(sectiondesc)
   SELECT INTO "nl:"
    s.description
    FROM dcp_section_ref s
    WHERE s.description=sectiondesc
    DETAIL
     dup_sect_exists = 1
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE logdupform(var1)
   SELECT INTO "dcp_import_powerforms.log"
    var1
    HEAD REPORT
     info1 = trim(requestin->list_0[var1].form_description)
    DETAIL
     "WARNING:PowerForm already exists in destination domain: ", info1, row + 1,
     col 0, "Row  #:  ", var1
    WITH nocounter, append, format = variable,
     noformfeed, maxcol = 132, maxrow = 1
   ;end select
 END ;Subroutine
 SUBROUTINE logdupsection(var1)
   SELECT INTO "dcp_import_powerforms.log"
    var1
    HEAD REPORT
     info1 = trim(requestin->list_0[var1].section_description)
    DETAIL
     row + 1, col 0, "WARNING:PowerForm Section already exists in destination domain: ",
     info1, row + 1, col 0
    WITH nocounter, append, format = variable,
     noformfeed, maxcol = 132, maxrow = 1
   ;end select
 END ;Subroutine
 SUBROUTINE logformok(var1)
   SELECT INTO "dcp_import_powerforms.log"
    var1
    HEAD REPORT
     info1 = trim(requestin->list_0[var1].form_description)
    DETAIL
     row + 1, col 0, "SUCCESS! PowerFrom Loaded Successfully: ",
     info1, row + 1, col 0
    WITH nocounter, append, format = variable,
     noformfeed, maxcol = 132, maxrow = 1
   ;end select
 END ;Subroutine
 SUBROUTINE logformnotok(var1)
   SELECT INTO "dcp_import_powerforms.log"
    var1
    HEAD REPORT
     info1 = trim(requestin->list_0[var1].form_description)
    DETAIL
     row + 1, col 0, "WARNING:PowerForm Not Loaded Successfully: ",
     info1, row + 1, col 0
    WITH nocounter, append, format = variable,
     noformfeed, maxcol = 132, maxrow = 1
   ;end select
 END ;Subroutine
 SUBROUTINE newmergeid(var1,scnt,icnt,ncnt)
  SET new_merge_id = 0
  IF ((request->sect_list[scnt].input_list[icnt].nv[ncnt].merge_name="DISCRETE_TASK_ASSAY"))
   SELECT INTO "nl:"
    d.task_assay_cd
    FROM discrete_task_assy d
    WHERE (d.mnemonic=requestin->list_0[var1].dta_mnemonic)
    DETAIL
     new_merge_id = d.task_assay_cd
    WITH nocounter
   ;end select
  ENDIF
 END ;Subroutine
 SUBROUTINE logsectioninfo(var1)
   SELECT INTO "dcp_import_powerforms.log"
    var1
    HEAD REPORT
     info1 = trim(requestin->list_0[var1].section_description)
    DETAIL
     row + 1, col 0, "Info: Section Being Imported: ",
     info1
    WITH nocounter, append, format = variable,
     noformfeed, maxcol = 132, maxrow = 1
   ;end select
 END ;Subroutine
 SUBROUTINE loginputinfo(var1)
   SELECT INTO "dcp_import_powerforms.log"
    var1
    HEAD REPORT
     info1 = trim(requestin->list_0[var1].input_description)
    DETAIL
     "Info: Input Control Being Imported: ", info1
    WITH nocounter, append, format = variable,
     noformfeed, maxcol = 132, maxrow = 1
   ;end select
 END ;Subroutine
 SUBROUTINE logsectionid(tmp1,prev1,var1)
   SELECT INTO "dcp_import_powerforms.log"
    var1
    HEAD REPORT
     info1 = requestin->list_0[var1].dcp_section_ref_id
    DETAIL
     "Info: Real Sect Id: ", requestin->list_0[var1].dcp_section_ref_id, row + 1,
     col 0, "Info: Tmp Section Id: ", tmp1,
     row + 1, col 0, "Info: Prev Section Id: ",
     prev1, row + 1, col 0,
     "Row  #:  ", var1
    WITH nocounter, append, format = variable,
     noformfeed, maxcol = 132, maxrow = 1
   ;end select
 END ;Subroutine
 SUBROUTINE logrownum(num,var1)
   SELECT INTO "dcp_import_powerforms.log"
    var1
    HEAD REPORT
     info1 = num
    DETAIL
     row + 1, col 0, "Info: Number of Rows: ",
     num
    WITH nocounter, append, format = variable,
     noformfeed, maxcol = 132, maxrow = 1
   ;end select
 END ;Subroutine
 SUBROUTINE logrequest(var1)
   SELECT INTO "dcp_import_pf_request.log"
    var1
    HEAD REPORT
     curdate"dd-mmm-yyyy;;d", "-", curtime"hh:mm;;m",
     col + 1, "DCP PowerForms Import Request Log"
    DETAIL
     row + 1, col 0, "dcp_forms_ref_id    : ",
     request->dcp_forms_ref_id, row + 1, col 0,
     "description         : ", request->description, row + 1,
     col 0, "definition          : ", request->definition,
     row + 1, col 0, "task_assay_cd       : ",
     request->task_assay_cd, row + 1, col 0,
     "event_cd            : ", request->event_cd, row + 1,
     col 0, "done_charting_ind   : ", request->done_charting_ind,
     row + 1, col 0, "active_ind          : ",
     request->active_ind, row + 1, col 0,
     "width               : ", request->width, row + 1,
     col 0, "height              : ", request->height,
     row + 1, col 0, "flags               : ",
     request->flags, row + 1, col 0,
     "beg_effective_dt_tm : ", request->beg_effective_dt_tm, row + 1,
     col 0, "end_effective_dt_tm : ", request->end_effective_dt_tm,
     row + 1, col 0, "updt_cnt            : ",
     request->updt_cnt, row + 1, col 0,
     "sect_info_passed_ind: ", request->sect_info_passed_ind
     FOR (x = 1 TO size(request->sect_list,5))
       row + 1, col + 4, "dcp_forms_def_id      : ",
       request->sect_list[x].dcp_forms_def_id, row + 1, col + 4,
       "section_seq           : ", request->sect_list[x].section_seq, row + 1,
       col + 4, "dcp_section_ref_id    : ", request->sect_list[x].dcp_section_ref_id,
       row + 1, col + 4, "description           : ",
       request->sect_list[x].description, row + 1, col + 4,
       "definition            : ", request->sect_list[x].definition, row + 1,
       col + 4, "task_assay_cd         : ", request->sect_list[x].task_assay_cd,
       row + 1, col + 4, "event_cd              : ",
       request->sect_list[x].event_cd, row + 1, col + 4,
       "active_ind            : ", request->sect_list[x].active_ind, row + 1,
       col + 4, "width                 : ", request->sect_list[x].width,
       row + 1, col + 4, "height                : ",
       request->sect_list[x].height, row + 1, col + 4,
       "flags                 : ", request->sect_list[x].flags, row + 1,
       col + 4, "beg_effective_dt_tm   : ", request->sect_list[x].beg_effective_dt_tm,
       row + 1, col + 4, "end_effective_dt_tm   : ",
       request->sect_list[x].end_effective_dt_tm, row + 1, col + 4,
       "updt_cnt              : ", request->sect_list[x].updt_cnt, row + 1,
       col + 4, "input_info_passed_ind : ", request->sect_list[x].input_info_passed_ind
       FOR (y = 1 TO size(request->sect_list[x].input_list,5))
         row + 1, col + 8, "dcp_input_ref_id : ",
         request->sect_list[x].input_list[y].dcp_input_ref_id, row + 1, col + 8,
         "description      : ", request->sect_list[x].input_list[y].description, row + 1,
         col + 8, "module           : ", request->sect_list[x].input_list[y].module,
         row + 1, col + 8, "input_ref_seq    : ",
         request->sect_list[x].input_list[y].input_ref_seq, row + 1, col + 8,
         "input_type       : ", request->sect_list[x].input_list[y].input_type
         FOR (z = 1 TO size(request->sect_list[x].input_list[y].nv,5))
           row + 1, col + 12, "pvc_name   : ",
           request->sect_list[x].input_list[y].nv[z].pvc_name, row + 1, col + 12,
           "pvc_value  : ", request->sect_list[x].input_list[y].nv[z].pvc_value, row + 1,
           col + 12, "merge_name : ", request->sect_list[x].input_list[y].nv[z].merge_name,
           row + 1, col + 12, "merge_id   : ",
           request->sect_list[x].input_list[y].nv[z].merge_id, row + 1, col + 12,
           "sequence   : ", request->sect_list[x].input_list[y].nv[z].sequence
         ENDFOR
       ENDFOR
     ENDFOR
    WITH nocounter, format = variable, noformfeed,
     maxcol = 132, maxrow = 1
   ;end select
 END ;Subroutine
 SUBROUTINE logdbimportrequest(var1)
   SELECT INTO "dcp_import_pf_db_request.log"
    var1
    HEAD REPORT
     curdate"dd-mmm-yyyy;;d", "-", curtime"hh:mm;;m",
     col + 1, "DCP PowerForms Import DbImport Request Log"
    DETAIL
     FOR (x = 1 TO numrows)
       row + 1, col 0, "description         : ",
       requestin->list_0[x].form_description, row + 1, col 0,
       "definition          : ", requestin->list_0[x].form_definition, row + 1,
       col 0, "event_cd            : ", requestin->list_0[x].form_event_cd,
       row + 1, col 0, "done_charting_ind   : ",
       requestin->list_0[x].done_charting_ind, row + 1, col 0,
       "width               : ", requestin->list_0[x].form_width, row + 1,
       col 0, "height              : ", requestin->list_0[x].form_height,
       row + 1, col 0, "flags               : ",
       requestin->list_0[x].form_flags, row + 1, col + 4,
       "section_seq           : ", requestin->list_0[x].section_seq, row + 1,
       col + 4, "description           : ", requestin->list_0[x].section_description,
       row + 1, col + 4, "definition            : ",
       requestin->list_0[x].section_definition, row + 1, col + 4,
       "width                 : ", requestin->list_0[x].section_width, row + 1,
       col + 4, "height                : ", requestin->list_0[x].section_height,
       row + 1, col + 4, "flags                 : ",
       requestin->list_0[x].section_flags, row + 1, col + 8,
       "description      : ", requestin->list_0[x].input_description, row + 1,
       col + 8, "module           : ", requestin->list_0[x].module,
       row + 1, col + 8, "input_ref_seq    : ",
       requestin->list_0[x].input_ref_seq, row + 1, col + 8,
       "input_type       : ", requestin->list_0[x].input_type, row + 1,
       col + 12, "pvc_name   : ", requestin->list_0[x].pvc_name,
       row + 1, col + 12, "pvc_value  : ",
       requestin->list_0[x].pvc_value, row + 1, col + 12,
       "merge_name : ", requestin->list_0[x].merge_name, row + 1,
       col + 12, "merge_id   : ", requestin->list_0[x].merge_id,
       row + 1, col + 12, "sequence   : ",
       requestin->list_0[x].sequence
     ENDFOR
    WITH nocounter, format = variable, noformfeed,
     maxcol = 132, maxrow = 1
   ;end select
 END ;Subroutine
#exit_script
 COMMIT
END GO
