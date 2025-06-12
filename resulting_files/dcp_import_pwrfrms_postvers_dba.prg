CREATE PROGRAM dcp_import_pwrfrms_postvers:dba
 FREE SET request
 RECORD request(
   1 dcp_section_ref_id = f8
   1 description = vc
   1 definition = vc
   1 task_assay_cd = f8
   1 event_cd = f8
   1 active_ind = i2
   1 width = i4
   1 height = i4
   1 updt_cnt = i4
   1 input_list[*]
     2 description = vc
     2 module = vc
     2 input_ref_seq = i4
     2 input_type = i4
     2 nv[*]
       3 pvc_name = vc
       3 pvc_value = vc
       3 merge_name = vc
       3 merge_id = f8
       3 sequence = i2
 )
 FREE SET form
 RECORD form(
   1 dcp_forms_ref_id = f8
   1 description = vc
   1 definition = vc
   1 task_assay_cd = f8
   1 event_cd = f8
   1 done_charting_ind = i2
   1 width = i4
   1 height = i4
   1 flags = i4
   1 updt_cnt = i4
   1 sect_list[*]
     2 dcp_section_ref_id = f8
 )
 FREE SET section
 RECORD section(
   1 sect_list[*]
     2 dcp_section_ref_id = f8
     2 description = vc
     2 definition = vc
     2 task_assay_cd = f8
     2 event_cd = f8
     2 active_ind = i2
     2 width = i4
     2 height = i4
     2 updt_cnt = i4
     2 input_cnt = i4
     2 input_list[*]
       3 description = vc
       3 module = vc
       3 input_ref_seq = i4
       3 input_type = i4
       3 nv_cnt = i4
       3 nv[*]
         4 pvc_name = vc
         4 pvc_value = vc
         4 merge_name = vc
         4 merge_id = f8
         4 sequence = i2
 )
 IF (validate(reply,"0")="0")
  RECORD reply(
    1 dcp_section_ref_id = f8
    1 updt_cnt = i4
    1 dcp_form_instance_id = f8
    1 dcp_forms_ref_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE SET blob
 RECORD blob(
   1 qual[*]
     2 line = vc
 )
 DECLARE tmp_pvc_value = vc
 CALL echo("Called Postversioning Script")
 SET numrows = 0
 SET new_dcp_forms_ref_id = 0.0
 SET new_dcp_forms_def_id = 0.0
 SET new_section_ref_id = 0.0
 SET new_input_ref_id = 0.0
 SET tmpformdesc = fillstring(200," ")
 SET tempsecdesc = fillstring(200," ")
 SET tmpformdefn = fillstring(200," ")
 SET tmpsecdefn = fillstring(200," ")
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
 SET input_cnt1 = 0
 SET nv_cnt = 0
 SET tvar1 = 1
 SET code_display = fillstring(50," ")
 SET temp_task_description = fillstring(50," ")
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
    SET tmpformdesc = fillstring(200," ")
    SET tmpformdefn = fillstring(200," ")
    SET tmpformdesc = trim(requestin->list_0[lvar].form_description)
    SET tmpformdefn = trim(requestin->list_0[lvar].form_definition)
    SET forms_ref_id = 0.0
    SET form_updt_cnt = 0
    CALL checkdupform(tmpformdesc,tmpformdefn)
    IF (forms_ref_id != 0)
     CALL logdupformchanged(lvar,forms_ref_id)
    ENDIF
   ENDIF
   IF (dup_form_exists=0)
    IF (lvar=1)
     SET form->dcp_forms_ref_id = forms_ref_id
     SET form->description = requestin->list_0[lvar].form_description
     SET form->definition = requestin->list_0[lvar].form_definition
     SET form->task_assay_cd = 0
     SET form->event_cd = requestin->list_0[lvar].form_event_cd
     IF ((form->event_cd=0))
      SET code_value = 0.0
      SET code_set = 72
      SET code_display = cnvtalphanum(trim(requestin->list_0[lvar].form_event_cd_disp))
      EXECUTE cpm_get_cd_for_disp
      SET form->event_cd = code_value
     ENDIF
     SET form->done_charting_ind = cnvtint(requestin->list_0[lvar].done_charting_ind)
     SET form->width = cnvtint(requestin->list_0[lvar].form_width)
     SET form->height = cnvtint(requestin->list_0[lvar].form_height)
     SET form->flags = cnvtint(requestin->list_0[lvar].form_flags)
     SET form->updt_cnt = form_updt_cnt
    ENDIF
    IF (((lvar=1) OR ((requestin->list_0[lvar].dcp_section_ref_id != requestin->list_0[(lvar - 1)].
    dcp_section_ref_id))) )
     SET dup_sect_exists = 0
     SET section_ref_id = 0.0
     SET section_updt_cnt = 0
     CALL echo(build("Section exists in the Field"))
     CALL checkdupsection(lvar)
     IF (section_ref_id != 0)
      CALL logdupsectionchanged(lvar,section_ref_id)
     ENDIF
     SET section_cnt = (section_cnt+ 1)
     CALL echo(build("Section_cnt:",section_cnt))
     IF (section_cnt > size(section->sect_list,5))
      SET stat = alterlist(section->sect_list,(section_cnt+ 1))
     ENDIF
     IF (section_cnt > 1)
      IF (input_cnt1 > 0)
       CALL echo(build("input_cnt:",input_cnt1,"for section:",section_cnt))
       SET stat = alterlist(section->sect_list[(section_cnt - 1)].input_list,input_cnt1)
       IF (nv_cnt > 0)
        SET stat = alterlist(section->sect_list[(section_cnt - 1)].input_list[input_cnt1].nv,nv_cnt)
        CALL echo(build("for the next section nv_cnt:",nv_cnt))
       ENDIF
      ENDIF
      SET section->sect_list[(section_cnt - 1)].input_cnt = input_cnt1
      SET section->sect_list[(section_cnt - 1)].input_list[input_cnt1].nv_cnt = nv_cnt
     ENDIF
     SET input_cnt1 = 0
     SET nv_cnt = 0
     CALL logsectioninfo(lvar)
     SET section->sect_list[section_cnt].dcp_section_ref_id = section_ref_id
     SET section->sect_list[section_cnt].description = requestin->list_0[lvar].section_description
     SET section->sect_list[section_cnt].definition = requestin->list_0[lvar].section_definition
     SET section->sect_list[section_cnt].task_assay_cd = 0
     SET section->sect_list[section_cnt].event_cd = 0
     SET section->sect_list[section_cnt].active_ind = 1
     SET section->sect_list[section_cnt].width = cnvtint(requestin->list_0[lvar].section_width)
     SET section->sect_list[section_cnt].height = cnvtint(requestin->list_0[lvar].section_height)
     SET section->sect_list[section_cnt].updt_cnt = section_updt_cnt
     IF (dup_sect_exists != 0)
      CALL echo(build("bails out on dup section:"))
      CALL logdupsection(lvar)
      SET lvar = (numrows+ 1)
     ENDIF
    ENDIF
    IF (need_to_exit_loop=0)
     IF (((lvar=1) OR ((requestin->list_0[lvar].dcp_input_ref_id != requestin->list_0[(lvar - 1)].
     dcp_input_ref_id))) )
      IF (nv_cnt > 0)
       SET stat = alterlist(section->sect_list[section_cnt].input_list[input_cnt1].nv,nv_cnt)
       CALL echo(build("nv_cnt   inside the control   :",nv_cnt))
       SET section->sect_list[section_cnt].input_list[input_cnt1].nv_cnt = nv_cnt
      ENDIF
      SET nv_cnt = 0
      CALL echo(build("input_cnt2:",input_cnt1))
      SET input_cnt1 = (input_cnt1+ 1)
      IF (input_cnt1 > size(section->sect_list[section_cnt].input_list,5))
       SET stat = alterlist(section->sect_list[section_cnt].input_list,input_cnt1)
      ENDIF
      CALL echo(build("input_cnt1:",input_cnt1))
      SET section->sect_list[section_cnt].input_list[input_cnt1].description = requestin->list_0[lvar
      ].input_description
      SET section->sect_list[section_cnt].input_list[input_cnt1].module = requestin->list_0[lvar].
      module
      SET section->sect_list[section_cnt].input_list[input_cnt1].input_ref_seq = cnvtint(requestin->
       list_0[lvar].input_ref_seq)
      SET section->sect_list[section_cnt].input_list[input_cnt1].input_type = cnvtint(requestin->
       list_0[lvar].input_type)
      CALL loginputinfo(lvar)
     ENDIF
     CALL echo(concat("lvar = ",cnvtstring(lvar)))
     SET boolstat = 0
     IF (lvar=1)
      SET boolstat = 1
     ELSE
      IF ((((requestin->list_0[lvar].pvc_name != requestin->list_0[(lvar - 1)].pvc_name)) OR ((
      requestin->list_0[lvar].pvc_name=requestin->list_0[(lvar - 1)].pvc_name)
       AND (((requestin->list_0[lvar].merge_id != requestin->list_0[(lvar - 1)].merge_id)) OR ((
      requestin->list_0[lvar].dcp_input_ref_id != requestin->list_0[(lvar - 1)].dcp_input_ref_id)))
      )) )
       SET boolstat = 1
      ENDIF
     ENDIF
     IF (boolstat=1)
      SET nv_cnt = (nv_cnt+ 1)
      CALL echo(build("nv_cnt under the loop:",nv_cnt))
      IF (nv_cnt > size(section->sect_list[section_cnt].input_list[input_cnt1].nv,5))
       SET stat = alterlist(section->sect_list[section_cnt].input_list[input_cnt1].nv,(nv_cnt+ 1))
      ENDIF
      SET section->sect_list[section_cnt].input_list[input_cnt1].nv_cnt = nv_cnt
      SET section->sect_list[section_cnt].input_list[input_cnt1].nv[nv_cnt].pvc_name = requestin->
      list_0[lvar].pvc_name
      IF ((requestin->list_0[lvar].pvc_value="TRUE"))
       SET section->sect_list[section_cnt].input_list[input_cnt1].nv[nv_cnt].pvc_value = "true"
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
       SET section->sect_list[section_cnt].input_list[input_cnt1].nv[nv_cnt].pvc_value = trim(
        tmp_pvc_value)
      ENDIF
      SET new_merge_id = 0.0
      SET section->sect_list[section_cnt].input_list[input_cnt1].nv[nv_cnt].merge_name = requestin->
      list_0[lvar].merge_name
      IF ((section->sect_list[section_cnt].input_list[input_cnt1].nv[nv_cnt].merge_name=
      "DISCRETE_TASK_ASSAY"))
       SET code_value = 0.0
       SET code_set = 106
       SET code_display = cnvtalphanum(trim(requestin->list_0[lvar].dta_act_type_display))
       CALL echo(build("activity_type_cd:",requestin->list_0[lvar].dta_act_type_display))
       EXECUTE cpm_get_cd_for_disp
       CALL echo(build("activity_type_cd:",code_value))
       SELECT INTO "nl:"
        d.task_assay_cd
        FROM discrete_task_assay d
        WHERE d.mnemonic=trim(requestin->list_0[lvar].dta_mnemonic)
         AND d.activity_type_cd=code_value
        DETAIL
         new_merge_id = d.task_assay_cd
        WITH nocounter
       ;end select
       IF (new_merge_id=0)
        CALL lognomergeid(1,lvar)
       ENDIF
      ELSEIF ((section->sect_list[section_cnt].input_list[input_cnt1].nv[nv_cnt].merge_name=
      "CODE_VALUE"))
       IF ((section->sect_list[section_cnt].input_list[input_cnt1].nv[nv_cnt].pvc_name="unit*"))
        SELECT INTO "nl:"
         c.display
         FROM code_value c
         WHERE c.display=trim(requestin->list_0[lvar].code_value_display)
          AND c.code_set=cnvtint(requestin->list_0[lvar].code_set)
         DETAIL
          new_merge_id = c.code_value
         WITH nocounter
        ;end select
        IF (new_merge_id=0)
         CALL lognomergeid(2,lvar)
        ENDIF
       ELSEIF ((section->sect_list[section_cnt].input_list[input_cnt1].nv[nv_cnt].pvc_name=
       "template*"))
        SELECT INTO "nl:"
         c.display
         FROM code_value c
         WHERE c.display=trim(requestin->list_0[lvar].code_value_display)
          AND c.code_set=cnvtint(requestin->list_0[lvar].code_set)
         DETAIL
          new_merge_id = c.code_value
         WITH nocounter
        ;end select
        IF (new_merge_id=0)
         CALL lognomergeid(3,lvar)
        ENDIF
       ENDIF
      ELSEIF ((section->sect_list[section_cnt].input_list[input_cnt1].nv[nv_cnt].merge_name=
      "V500_EVENT_CODE"))
       SELECT INTO "nl:"
        v5.event_cd_disp
        FROM v500_event_code v5
        WHERE v5.event_cd_disp=trim(requestin->list_0[lvar].event_cd_display)
        DETAIL
         new_merge_id = v5.event_cd
        WITH nocounter
       ;end select
       IF (new_merge_id=0)
        SET temp_task_description = trim(requestin->list_0[lvar].event_cd_display)
        SET temp_event_cd = 0.0
        EXECUTE tsk_post_event_code
        SET new_merge_id = temp_event_cd
       ENDIF
       IF (new_merge_id=0)
        CALL lognomergeid(4,lvar)
       ENDIF
      ELSEIF ((section->sect_list[section_cnt].input_list[input_cnt1].nv[nv_cnt].merge_name=
      "DCP_SECTION_REF"))
       SELECT INTO "nl:"
        dsr.dcp_section_ref_id
        FROM dcp_section_ref dsr
        WHERE dsr.description=trim(requestin->list_0[lvar].cond_sect_desc)
         AND dsr.definition=trim(requestin->list_0[lvar].cond_sect_defn)
        DETAIL
         new_merge_id = dsr.dcp_section_ref_id
        WITH nocounter
       ;end select
       IF (new_merge_id=0)
        CALL createnewsection(lvar)
       ENDIF
       IF (new_merge_id=0)
        CALL lognomergeid(5,lvar)
       ENDIF
      ENDIF
      CALL echo(build("nv_cnt:",nv_cnt,"input_cnt:",input_cnt1))
      SET section->sect_list[section_cnt].input_list[input_cnt1].nv[nv_cnt].merge_id = new_merge_id
      SET section->sect_list[section_cnt].input_list[input_cnt1].nv[nv_cnt].sequence = cnvtint(
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
 SET stat = alterlist(section->sect_list,section_cnt)
 SET section->sect_list[section_cnt].input_cnt = input_cnt1
 SET section->sect_list[section_cnt].input_list[input_cnt1].nv_cnt = nv_cnt
 SET need_to_exit_loop = 0
 CALL echorecord(section)
 IF (dup_form_exists=0
  AND dup_sect_exists=0)
  DECLARE section_knt = i4
  SET section_knt = section_cnt
  FOR (x = 1 TO section_knt)
    SET request->dcp_section_ref_id = section->sect_list[x].dcp_section_ref_id
    SET request->description = section->sect_list[x].description
    SET request->definition = section->sect_list[x].definition
    SET request->task_assay_cd = section->sect_list[x].task_assay_cd
    SET request->event_cd = section->sect_list[x].event_cd
    SET request->active_ind = section->sect_list[x].active_ind
    SET request->width = section->sect_list[x].width
    SET request->height = section->sect_list[x].height
    SET request->updt_cnt = section->sect_list[x].updt_cnt
    SET input_cnt = size(section->sect_list[x].input_list,5)
    SET stat = alterlist(request->input_list,input_cnt)
    FOR (y = 1 TO input_cnt)
      SET request->input_list[y].description = section->sect_list[x].input_list[y].description
      SET request->input_list[y].module = section->sect_list[x].input_list[y].module
      SET request->input_list[y].input_ref_seq = section->sect_list[x].input_list[y].input_ref_seq
      SET request->input_list[y].input_type = section->sect_list[x].input_list[y].input_type
      CALL echo(build("inside the echo scripting:",section->sect_list[x].input_list[y].nv_cnt))
      SET nv_cnt = size(section->sect_list[x].input_list[y].nv,5)
      SET stat = alterlist(request->input_list[y].nv,nv_cnt)
      FOR (z = 1 TO nv_cnt)
        SET request->input_list[y].nv[z].pvc_name = section->sect_list[x].input_list[y].nv[z].
        pvc_name
        SET request->input_list[y].nv[z].pvc_value = section->sect_list[x].input_list[y].nv[z].
        pvc_value
        SET request->input_list[y].nv[z].merge_name = section->sect_list[x].input_list[y].nv[z].
        merge_name
        SET request->input_list[y].nv[z].merge_id = section->sect_list[x].input_list[y].nv[z].
        merge_id
        SET request->input_list[y].nv[z].sequence = section->sect_list[x].input_list[y].nv[z].
        sequence
      ENDFOR
    ENDFOR
    CALL echorecord(request)
    EXECUTE dcp_upd_dcp_sect
    IF ((reply->status_data.status="S"))
     SET section->sect_list[x].dcp_section_ref_id = reply->dcp_section_ref_id
     CALL echo(build("Section_ref_id: ",reply->dcp_section_ref_id))
    ELSE
     SET need_to_exit_loop = 1
     SET x = (section_knt+ 1)
    ENDIF
  ENDFOR
  IF (need_to_exit_loop=0)
   FREE SET request
   RECORD request(
     1 dcp_forms_ref_id = f8
     1 description = vc
     1 definition = vc
     1 task_assay_cd = f8
     1 event_cd = f8
     1 done_charting_ind = i2
     1 width = i4
     1 height = i4
     1 flags = i4
     1 updt_cnt = i4
     1 sect_list[*]
       2 dcp_section_ref_id = f8
   )
   CALL echo(build("request->dcp_forms_ref_id:",form->dcp_forms_ref_id))
   SET from_updt_cnt = 0
   CALL checkdupform(form->description,form->definition)
   SET request->dcp_forms_ref_id = forms_ref_id
   SET request->description = form->description
   SET request->definition = form->definition
   SET request->task_assay_cd = form->task_assay_cd
   SET request->event_cd = form->event_cd
   SET request->done_charting_ind = form->done_charting_ind
   SET request->width = form->width
   SET request->height = form->height
   SET request->flags = form->flags
   SET request->updt_cnt = form_updt_cnt
   SET section_cnt = size(section->sect_list,5)
   SET stat = alterlist(request->sect_list,section_cnt)
   CALL echo(build("Section cnt beform executing the dcp_upd_dcp_form:",section_cnt))
   FOR (x = 1 TO section_cnt)
     SET request->sect_list[x].dcp_section_ref_id = section->sect_list[x].dcp_section_ref_id
   ENDFOR
   EXECUTE dcp_upd_dcp_form
  ENDIF
  IF ((reply->status_data.status="S"))
   CALL logformok(tvar1)
  ELSE
   CALL logformnotok(tvar1)
  ENDIF
 ELSE
  CALL logformnotok(tvar1)
 ENDIF
 EXECUTE dcp_purge_sections
 EXECUTE dcp_purge_forms
 GO TO exit_script
 SUBROUTINE checkdupform(formdesc,formdefn)
  SET formdupcnt = 0
  SELECT INTO "nl:"
   f.description
   FROM dcp_forms_ref f
   WHERE f.description=formdesc
    AND f.definition=formdefn
    AND f.active_ind=1
   DETAIL
    forms_ref_id = f.dcp_forms_ref_id, form_updt_cnt = f.updt_cnt, formdupcnt = (formdupcnt+ 1)
    IF (formdupcnt > 1)
     dup_form_exists = 1
    ENDIF
    CALL echo(build("forms_ref_id:",forms_ref_id)),
    CALL echo(build("form_updt_cnt:",form_updt_cnt))
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE checkdupsection(varsect)
  SET sectdupcnt = 0
  SELECT INTO "nl:"
   s.description
   FROM dcp_section_ref s
   WHERE (s.description=requestin->list_0[varsect].section_description)
    AND (s.definition=requestin->list_0[varsect].section_definition)
    AND s.active_ind=1
   DETAIL
    section_ref_id = s.dcp_section_ref_id, section_updt_cnt = s.updt_cnt, sectdupcnt = (sectdupcnt+ 1
    )
    IF (sectdupcnt > 1)
     dup_sect_exists = 1
    ENDIF
    CALL echo(build("Section_ref_id:",section_ref_id))
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE logdupform(var1)
   SELECT INTO "dcp_import_powerforms.log"
    var1
    HEAD REPORT
     info1 = trim(requestin->list_0[var1].form_description)
    DETAIL
     "WARNING:There are two forms of the same description exists in destination domain: ", info1, row
      + 1,
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
     row + 1, col 0,
     "WARNING:There are two sections of the same description exists in destination domain: ",
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
  SET new_merge_id = 0.0
  IF ((request->sect_list[scnt].input_list[icnt].nv[ncnt].merge_name="DISCRETE_TASK_ASSAY"))
   SELECT INTO "nl:"
    d.task_assay_cd
    FROM discrete_task_assay d
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
           "merge_name : ", request->sect_list[x].input_list[y].nv[z].merge_name, row + 1,
           col + 12, "merge_id   : ", request->sect_list[x].input_list[y].nv[z].merge_id,
           row + 1, col + 12, "sequence   : ",
           request->sect_list[x].input_list[y].nv[z].sequence
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
     row + 1, col 0, "Testing"
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
       requestin->list_0[x].form_flags, row + 1, col 0,
       "event set name      : ", requestin->list_0[x].event_set_name, row + 1,
       col + 4, "Testing2", row + 1,
       col + 4, "section_seq           : ", requestin->list_0[x].section_seq,
       row + 1, col + 4, "description           : ",
       requestin->list_0[x].section_description, row + 1, col + 4,
       "definition            : ", requestin->list_0[x].section_definition, row + 1,
       col + 4, "width                 : ", requestin->list_0[x].section_width,
       row + 1, col + 4, "height                : ",
       requestin->list_0[x].section_height, row + 1, col + 4,
       "flags                 : ", requestin->list_0[x].section_flags, row + 1,
       col + 8, "Testing3", row + 1,
       col + 8, "description      : ", requestin->list_0[x].input_description,
       row + 1, col + 8, "module           : ",
       requestin->list_0[x].module, row + 1, col + 8,
       "input_ref_seq    : ", requestin->list_0[x].input_ref_seq, row + 1,
       col + 8, "input_type       : ", requestin->list_0[x].input_type,
       row + 1, col + 12, "Testing4",
       row + 1, col + 12, "pvc_name   : ",
       requestin->list_0[x].pvc_name, row + 1, col + 12,
       "merge_name : ", requestin->list_0[x].merge_name, row + 1,
       col + 12, "merge_id   : ", requestin->list_0[x].merge_id,
       row + 1, col + 12, "sequence   : ",
       requestin->list_0[x].sequence
     ENDFOR
    WITH nocounter, format = variable, noformfeed,
     maxcol = 132, maxrow = 1
   ;end select
 END ;Subroutine
 SUBROUTINE logdupsectionchanged(var1,tmp1)
   SELECT INTO "dcp_import_powerforms.log"
    var1
    HEAD REPORT
     info1 = requestin->list_0[var1].dcp_section_ref_id
    DETAIL
     "Info: Real Sect Id: ", requestin->list_0[var1].dcp_section_ref_id, row + 1,
     col 0, "WARNING:Section is over Written:", requestin->list_0[var1].section_description,
     row + 1, col 0, "Info: Tmp Section Id: ",
     tmp1, row + 1, col 0,
     "Row  #:  ", var1
    WITH nocounter, append, format = variable,
     noformfeed, maxcol = 132, maxrow = 1
   ;end select
 END ;Subroutine
 SUBROUTINE logdupformchanged(var1,tmp1)
   SELECT INTO "dcp_import_powerforms.log"
    var1
    HEAD REPORT
     info1 = requestin->list_0[var1].dcp_forms_ref_id
    DETAIL
     "Info: Real Sect Id: ", requestin->list_0[var1].dcp_forms_ref_id, row + 1,
     col 0, "WARNING:Form is over Written:", requestin->list_0[var1].form_description,
     row + 1, col 0, "Info: Tmp form Id: ",
     tmp1, row + 1, col 0,
     "Row  #:  ", var1
    WITH nocounter, append, format = variable,
     noformfeed, maxcol = 132, maxrow = 1
   ;end select
 END ;Subroutine
 SUBROUTINE lognomergeid(etype,var2)
   SELECT INTO "dcp_import_powerforms.log"
    var2
    HEAD REPORT
     info1 = requestin->list_0[var2].merge_name
    DETAIL
     "Info:merge name:", requestin->list_0[var2].merge_name
     IF (etype=1)
      row + 1, col 0, "no task assayCd for this description",
      row + 1, col 0, requestin->list_0[var2].dta_description,
      row + 1, col 0, " and for this mnemonic ",
      row + 1, col 0, requestin->list_0[var2].dta_mnemonic,
      row + 1, col 0, "Row #:",
      var2, row + 1, col 0,
      requestin->list_0[var2].dta_act_type_display
     ENDIF
     IF (etype=2)
      row + 1, col 0, "Following unit Code is not found in code set",
      requestin->list_0[var2].code_set, row + 1, col 0,
      requestin->list_0[var2].code_value_display, row + 1, col 0,
      "Row #:", var2
     ENDIF
     IF (etype=3)
      row + 1, col 0, "Following template is not found in codeset",
      requestin->list_0[var2].code_set, row + 1, col 0,
      requestin->list_0[var2].code_value_display, row + 1, col 0,
      "Row #:", var2
     ENDIF
     IF (etype=4)
      row + 1, col 0, "Following Event code is not found in code set 72",
      row + 1, col 0, requestin->list_0[var2].event_cd_display,
      row + 1, col 0, "Row #:",
      var2
     ENDIF
     IF (etype=5)
      row + 1, col 0, "Following Cond Section is not able to created",
      row + 1, col 0, "Row #:",
      var2
     ENDIF
    WITH nocounter, append, format = variable,
     noformfeed, maxcol = 132, maxrow = 1
   ;end select
 END ;Subroutine
 SUBROUTINE createnewsection(var1)
   SET cond_size = size(trim(requestin->list_0[var1].cond_sect_desc),1)
   SET cond_size2 = size(trim(requestin->list_0[var1].cond_sect_defn),1)
   SET request->dcp_section_ref_id = 0
   SET request->description = trim(requestin->list_0[var1].cond_sect_desc)
   SET request->definition = trim(requestin->list_0[lvar].cond_sect_defn)
   SET request->task_assay_cd = 0
   SET request->event_cd = 0
   SET request->active_ind = 1
   SET request->width = 0
   SET request->height = 0
   SET request->updt_cnt = 0
   SET stat = alterlist(request->input_list,0)
   IF (((cond_size > 1
    AND cond_size2 > 1) OR ((request->description > " ")
    AND (request->definition > " "))) )
    EXECUTE dcp_upd_dcp_sect
    IF ((reply->status_data.status="S"))
     SET new_merge_id = reply->dcp_section_ref_id
     CALL echo(build("Section_ref_id: ",reply->dcp_section_ref_id))
    ENDIF
   ENDIF
 END ;Subroutine
#exit_script
 COMMIT
END GO
