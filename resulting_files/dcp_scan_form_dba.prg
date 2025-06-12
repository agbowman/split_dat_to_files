CREATE PROGRAM dcp_scan_form:dba
 SET modify = predeclare
 IF (validate(reply)=0)
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE SET form_temp
 RECORD form_temp(
   1 dcp_forms_ref_id = f8
   1 description = vc
   1 definition = vc
   1 task_assay_cd = f8
   1 event_cd = f8
   1 done_charting_ind = i2
   1 width = f8
   1 height = f8
   1 event_set_name = vc
   1 flags = i4
   1 updt_cnt = i4
   1 sections[*]
     2 dcp_section_ref_id = f8
     2 dcp_section_instance_id = f8
     2 section_seq = i4
     2 flags = i4
     2 inputs[*]
       3 input_type = i4
       3 properties[*]
         4 pvc_name = vc
         4 pvc_value = vc
         4 merge_id = f8
   1 dtas[*]
     2 task_assay_cd = f8
     2 required_ind = i2
   1 tasks[*]
     2 reference_task_id = f8
     2 description = vc
     2 short_description = vc
   1 text_rendition_event_cd = f8
 )
 FREE SET tdrs
 RECORD tdrs(
   1 current[*]
     2 reference_task_id = f8
     2 task_assay_cd = f8
     2 sequence = i4
     2 active_ind = i2
     2 required_ind = i2
     2 acknowledge_ind = i2
     2 document_ind = i2
     2 view_only_ind = i2
     2 updt_cnt = i4
     2 transferred = i2
   1 new[*]
     2 task_assay_cd = f8
     2 required_ind = i2
     2 sequence = i4
   1 add[*]
     2 reference_task_id = f8
     2 task_assay_cd = f8
     2 sequence = i4
     2 active_ind = i2
     2 required_ind = i2
     2 acknowledge_ind = i2
     2 document_ind = i2
     2 view_only_ind = i2
   1 modify[*]
     2 reference_task_id = f8
     2 task_assay_cd = f8
     2 sequence = i4
     2 active_ind = i2
     2 required_ind = i2
     2 acknowledge_ind = i2
     2 document_ind = i2
     2 view_only_ind = i2
     2 updt_cnt = i4
   1 remove[*]
     2 reference_task_id = f8
     2 task_assay_cd = f8
 )
 DECLARE reportfailure(opname=vc,opstatus=vc,targetname=vc,targetvalue=vc) = null
 DECLARE fillsubeventstatus(opname=vc,opstatus=vc,objname=vc,objvalue=vc) = null
 SUBROUTINE reportfailure(opname,opstatus,targetname,targetvalue)
  SET reply->status_data.status = "F"
  CALL fillsubeventstatus(opname,opstatus,targetname,targetvalue)
 END ;Subroutine
 SUBROUTINE fillsubeventstatus(opname,opstatus,objname,objvalue)
   DECLARE dcp_substatus_cnt = i4 WITH protect, noconstant(size(reply->status_data.subeventstatus,5))
   SET dcp_substatus_cnt = (dcp_substatus_cnt+ 1)
   IF (dcp_substatus_cnt != 1)
    SET stat = alter(reply->status_data.subeventstatus,dcp_substatus_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].operationname = trim(opname)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].targetobjectname = trim(objname)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].targetobjectvalue = trim(objvalue)
 END ;Subroutine
 DECLARE unknown_type = i4 WITH public, constant(0)
 DECLARE label_control = i4 WITH public, constant(1)
 DECLARE numeric_control = i4 WITH public, constant(2)
 DECLARE flexunit_control = i4 WITH public, constant(3)
 DECLARE list_control = i4 WITH public, constant(4)
 DECLARE magrid_control = i4 WITH public, constant(5)
 DECLARE freetext_control = i4 WITH public, constant(6)
 DECLARE calculation_control = i4 WITH public, constant(7)
 DECLARE staticunit_control = i4 WITH public, constant(8)
 DECLARE alphacombo_control = i4 WITH public, constant(9)
 DECLARE datetime_control = i4 WITH public, constant(10)
 DECLARE allergy_control = i4 WITH public, constant(11)
 DECLARE imageholder_control = i4 WITH public, constant(12)
 DECLARE rtfeditor_control = i4 WITH public, constant(13)
 DECLARE discrete_grid = i4 WITH public, constant(14)
 DECLARE ralpha_grid = i4 WITH public, constant(15)
 DECLARE comment_control = i4 WITH public, constant(16)
 DECLARE power_grid = i4 WITH public, constant(17)
 DECLARE provider_control = i4 WITH public, constant(18)
 DECLARE ultra_grid = i4 WITH public, constant(19)
 DECLARE tracking_control1 = i4 WITH public, constant(20)
 DECLARE conversion_control = i4 WITH public, constant(21)
 DECLARE numeric_control2 = i4 WITH public, constant(22)
 DECLARE nomenclature_control = i4 WITH public, constant(23)
 DECLARE tracking_control = i4 WITH public, constant(1)
 DECLARE carenet_control = i4 WITH public, constant(2)
 DECLARE medprofile_control = i4 WITH public, constant(1)
 DECLARE problemdx_control = i4 WITH public, constant(2)
 DECLARE pregnancyhistory_control = i4 WITH public, constant(3)
 DECLARE procedurehistory_control = i4 WITH public, constant(4)
 DECLARE familyhistory_control = i4 WITH public, constant(5)
 DECLARE medlist_control = i4 WITH public, constant(6)
 DECLARE pastmedhistory_control = i4 WITH public, constant(7)
 DECLARE socialhistory_control = i4 WITH public, constant(8)
 DECLARE communicationpreference_control = i4 WITH public, constant(9)
 DECLARE now = dq8 WITH protect, noconstant(cnvtdatetime(curdate,curtime3))
 DECLARE dscriptstarttime = dq8 WITH protect, noconstant(cnvtdatetime(curdate,curtime3))
 DECLARE dactionstarttime = dq8 WITH protect, noconstant(0)
 DECLARE delapsedtime = f8 WITH protect, noconstant(0.0)
 DECLARE dirty = i2 WITH protect, noconstant(0)
 DECLARE section_cnt = i4 WITH protect, noconstant(0)
 DECLARE input_cnt = i4 WITH protect, noconstant(0)
 DECLARE prop_cnt = i4 WITH protect, noconstant(0)
 DECLARE dta_cnt = i4 WITH protect, noconstant(0)
 DECLARE instance_id = f8 WITH protect, noconstant( $1)
 DECLARE max_width = f8 WITH protect, noconstant(0)
 DECLARE max_height = f8 WITH protect, noconstant(0)
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE dta = f8 WITH protect, noconstant(0)
 DECLARE required = i2 WITH protect, noconstant(0)
 DECLARE task_cnt = i4 WITH protect, noconstant(0)
 DECLARE current_tdr_cnt = i4 WITH protect, noconstant(0)
 DECLARE new_tdr_cnt = i4 WITH protect, noconstant(0)
 DECLARE add_tdr_cnt = i4 WITH protect, noconstant(0)
 DECLARE modify_tdr_cnt = i4 WITH protect, noconstant(0)
 DECLARE remove_tdr_cnt = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE script_debug_ind = i2 WITH protect, noconstant(0)
 IF (validate(debug_ind))
  SET script_debug_ind = debug_ind
 ENDIF
 IF (script_debug_ind > 0)
  CALL echo(build("Scan form with dcp_form_instance_id:",instance_id))
 ENDIF
 SET dactionstarttime = cnvtdatetime(curdate,curtime3)
 SELECT INTO "nl:"
  FROM dcp_forms_ref dfr,
   dcp_forms_def dfd,
   dcp_section_ref dsr,
   dcp_input_ref dir,
   name_value_prefs nvp
  PLAN (dfr
   WHERE dfr.dcp_form_instance_id=instance_id
    AND dfr.active_ind=1)
   JOIN (dfd
   WHERE dfd.dcp_form_instance_id=dfr.dcp_form_instance_id)
   JOIN (dsr
   WHERE dfd.dcp_section_ref_id=dsr.dcp_section_ref_id
    AND dsr.active_ind=1)
   JOIN (dir
   WHERE dir.dcp_section_instance_id=dsr.dcp_section_instance_id)
   JOIN (nvp
   WHERE nvp.parent_entity_id=dir.dcp_input_ref_id
    AND nvp.parent_entity_name="DCP_INPUT_REF")
  ORDER BY dfr.dcp_form_instance_id, dfd.section_seq, dsr.dcp_section_instance_id,
   dir.input_ref_seq, dir.dcp_input_ref_id, nvp.pvc_name,
   nvp.sequence
  HEAD dfr.dcp_form_instance_id
   form_temp->dcp_forms_ref_id = dfr.dcp_forms_ref_id, form_temp->description = dfr.description,
   form_temp->definition = dfr.definition,
   form_temp->task_assay_cd = dfr.task_assay_cd, form_temp->event_cd = dfr.event_cd, form_temp->
   done_charting_ind = dfr.done_charting_ind,
   form_temp->width = dfr.width, form_temp->height = dfr.height, form_temp->event_set_name = dfr
   .event_set_name,
   form_temp->flags = dfr.flags, form_temp->updt_cnt = dfr.updt_cnt, form_temp->
   text_rendition_event_cd = dfr.text_rendition_event_cd,
   section_cnt = 0
  HEAD dsr.dcp_section_ref_id
   input_cnt = 0, section_cnt = (section_cnt+ 1)
   IF (mod(section_cnt,10)=1)
    stat = alterlist(form_temp->sections,(section_cnt+ 9))
   ENDIF
   form_temp->sections[section_cnt].dcp_section_ref_id = dfd.dcp_section_ref_id, form_temp->sections[
   section_cnt].dcp_section_instance_id = dsr.dcp_section_instance_id, form_temp->sections[
   section_cnt].section_seq = dfd.section_seq,
   form_temp->sections[section_cnt].flags = dfd.flags, max_width = maxval(max_width,dsr.width),
   max_height = maxval(max_height,dsr.height)
  HEAD dir.dcp_input_ref_id
   prop_cnt = 0, input_cnt = (input_cnt+ 1)
   IF (mod(input_cnt,10)=1)
    stat = alterlist(form_temp->sections[section_cnt].inputs,(input_cnt+ 9))
   ENDIF
   form_temp->sections[section_cnt].inputs[input_cnt].input_type = dir.input_type
  DETAIL
   prop_cnt = (prop_cnt+ 1)
   IF (mod(prop_cnt,5)=1)
    stat = alterlist(form_temp->sections[section_cnt].inputs[input_cnt].properties,(prop_cnt+ 4))
   ENDIF
   form_temp->sections[section_cnt].inputs[input_cnt].properties[prop_cnt].pvc_name = nvp.pvc_name,
   form_temp->sections[section_cnt].inputs[input_cnt].properties[prop_cnt].pvc_value = nvp.pvc_value,
   form_temp->sections[section_cnt].inputs[input_cnt].properties[prop_cnt].merge_id = nvp.merge_id
  FOOT  dir.dcp_input_ref_id
   stat = alterlist(form_temp->sections[section_cnt].inputs[input_cnt].properties,prop_cnt)
  FOOT  dsr.dcp_section_ref_id
   stat = alterlist(form_temp->sections[section_cnt].inputs,input_cnt)
  FOOT  dfr.dcp_form_instance_id
   stat = alterlist(form_temp->sections,section_cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("*******************************************************")
  CALL echo("Form was not found.")
  CALL echo("*******************************************************")
 ENDIF
 SET delapsedtime = datetimediff(cnvtdatetime(curdate,curtime3),dactionstarttime,5)
 IF (script_debug_ind=1)
  CALL echo("*******************************************************")
  CALL echo(build("select time = ",delapsedtime))
  CALL echo(build("dcp_forms_ref_id = ",form_temp->dcp_forms_ref_id))
  CALL echo(build("section_cnt = ",section_cnt))
  CALL echo("*******************************************************")
 ENDIF
 IF (script_debug_ind=1)
  CALL echo("form_temp before conditional sections parse")
  CALL echorecord(form_temp)
 ENDIF
 SET dactionstarttime = cnvtdatetime(curdate,curtime3)
 FOR (i = 1 TO section_cnt)
  SET input_cnt = size(form_temp->sections[i].inputs,5)
  FOR (j = 1 TO input_cnt)
    SET prop_cnt = size(form_temp->sections[i].inputs[j].properties,5)
    SET dta = 0
    SET required = 0
    FOR (k = 1 TO prop_cnt)
      IF ((form_temp->sections[i].inputs[j].properties[k].pvc_name="conditional_section"))
       FOR (l = 1 TO section_cnt)
         IF ((form_temp->sections[l].dcp_section_ref_id=form_temp->sections[i].inputs[j].properties[k
         ].merge_id))
          SET stat = band(form_temp->sections[l].flags,1)
          IF (stat=0)
           SET form_temp->sections[l].flags = bor(form_temp->sections[l].flags,1)
           SET dirty = true
          ENDIF
         ENDIF
       ENDFOR
      ELSEIF ((form_temp->sections[i].inputs[j].properties[k].pvc_name="required"))
       IF ((form_temp->sections[i].inputs[j].properties[k].pvc_value="true"))
        SET required = 1
       ENDIF
      ELSEIF ((form_temp->sections[i].inputs[j].properties[k].pvc_name="discrete_task_assay2")
       AND (form_temp->sections[i].inputs[j].input_type=ultra_grid))
       SET dta = form_temp->sections[i].inputs[j].properties[k].merge_id
       IF (dta > 0)
        SET dta_cnt = (dta_cnt+ 1)
        IF (mod(dta_cnt,20)=1)
         SET stat = alterlist(form_temp->dtas,(dta_cnt+ 19))
        ENDIF
        SET form_temp->dtas[dta_cnt].task_assay_cd = dta
        SET form_temp->dtas[dta_cnt].required_ind = required
        SET dta = 0
       ENDIF
      ELSEIF ((form_temp->sections[i].inputs[j].properties[k].pvc_name="discrete_task_assay"))
       IF ((((form_temp->sections[i].inputs[j].input_type=power_grid)) OR ((((form_temp->sections[i].
       inputs[j].input_type=discrete_grid)) OR ((form_temp->sections[i].inputs[j].input_type=
       ultra_grid))) )) )
        SET dta = form_temp->sections[i].inputs[j].properties[k].merge_id
        IF (dta > 0)
         SET dta_cnt = (dta_cnt+ 1)
         IF (mod(dta_cnt,20)=1)
          SET stat = alterlist(form_temp->dtas,(dta_cnt+ 19))
         ENDIF
         SET form_temp->dtas[dta_cnt].task_assay_cd = dta
         SET form_temp->dtas[dta_cnt].required_ind = required
         SET dta = 0
        ENDIF
       ELSE
        SET dta = form_temp->sections[i].inputs[j].properties[k].merge_id
       ENDIF
      ELSEIF ((form_temp->sections[i].inputs[j].properties[k].pvc_name="discrete_task_assay*"))
       IF ((((form_temp->sections[i].inputs[j].input_type=tracking_control)) OR ((form_temp->
       sections[i].inputs[j].input_type=carenet_control))) )
        SET dta = form_temp->sections[i].inputs[j].properties[k].merge_id
        IF (dta > 0)
         SET dta_cnt = (dta_cnt+ 1)
         IF (mod(dta_cnt,20)=1)
          SET stat = alterlist(form_temp->dtas,(dta_cnt+ 19))
         ENDIF
         SET form_temp->dtas[dta_cnt].task_assay_cd = dta
         SET form_temp->dtas[dta_cnt].required_ind = required
         SET dta = 0
        ENDIF
       ENDIF
      ELSEIF ((form_temp->sections[i].inputs[j].properties[k].pvc_name="task_assay_cd"))
       SET dta = cnvtreal(form_temp->sections[i].inputs[j].properties[k].pvc_value)
      ENDIF
    ENDFOR
    IF (dta > 0)
     SET dta_cnt = (dta_cnt+ 1)
     IF (mod(dta_cnt,20)=1)
      SET stat = alterlist(form_temp->dtas,(dta_cnt+ 19))
     ENDIF
     SET form_temp->dtas[dta_cnt].task_assay_cd = dta
     SET form_temp->dtas[dta_cnt].required_ind = required
    ENDIF
  ENDFOR
 ENDFOR
 SET stat = alterlist(form_temp->dtas,dta_cnt)
 SET stat = band(form_temp->flags,16)
 IF (stat=0)
  IF ( NOT ((max_width=form_temp->width)))
   SET form_temp->width = max_width
   SET dirty = true
  ENDIF
  IF ( NOT ((max_height=form_temp->height)))
   SET form_temp->height = max_height
   SET dirty = true
  ENDIF
 ENDIF
 SET delapsedtime = datetimediff(cnvtdatetime(curdate,curtime3),dactionstarttime,5)
 IF (script_debug_ind=1)
  CALL echo("*******************************************************")
  CALL echo(build("parse and check for dirty time = ",delapsedtime))
  CALL echo(build("dirty?: ",dirty))
  CALL echo("*******************************************************")
 ENDIF
 SET dactionstarttime = cnvtdatetime(curdate,curtime3)
 IF (dirty=true)
  UPDATE  FROM dcp_forms_ref dfr
   SET dfr.active_ind = 0, dfr.end_effective_dt_tm = cnvtdatetime(now), dfr.updt_id = reqinfo->
    updt_id,
    dfr.updt_task = reqinfo->updt_task, dfr.updt_applctx = reqinfo->updt_applctx, dfr.updt_cnt = (dfr
    .updt_cnt+ 1),
    dfr.updt_dt_tm = cnvtdatetime(now)
   WHERE dfr.dcp_form_instance_id=instance_id
   WITH nocounter
  ;end update
  UPDATE  FROM dcp_forms_def dfd
   SET dfd.active_ind = 0, dfd.updt_id = reqinfo->updt_id, dfd.updt_task = reqinfo->updt_task,
    dfd.updt_applctx = reqinfo->updt_applctx, dfd.updt_cnt = (form_temp->updt_cnt+ 1), dfd.updt_dt_tm
     = cnvtdatetime(now)
   WHERE dfd.dcp_form_instance_id=instance_id
   WITH nocounter
  ;end update
  SELECT INTO "nl:"
   w = seq(carenet_seq,nextval)
   FROM dual
   DETAIL
    instance_id = cnvtreal(w)
   WITH nocounter
  ;end select
  INSERT  FROM dcp_forms_ref dfr
   SET dfr.dcp_form_instance_id = instance_id, dfr.dcp_forms_ref_id = form_temp->dcp_forms_ref_id,
    dfr.description = form_temp->description,
    dfr.definition = form_temp->definition, dfr.task_assay_cd = form_temp->task_assay_cd, dfr
    .event_cd = form_temp->event_cd,
    dfr.done_charting_ind = form_temp->done_charting_ind, dfr.active_ind = 1, dfr.width = form_temp->
    width,
    dfr.height = form_temp->height, dfr.event_set_name = trim(form_temp->event_set_name), dfr.flags
     = form_temp->flags,
    dfr.beg_effective_dt_tm = cnvtdatetime(now), dfr.end_effective_dt_tm = cnvtdatetime("31-Dec-2100"
     ), dfr.updt_id = reqinfo->updt_id,
    dfr.updt_task = reqinfo->updt_task, dfr.updt_applctx = reqinfo->updt_applctx, dfr.updt_cnt = (
    form_temp->updt_cnt+ 1),
    dfr.updt_dt_tm = cnvtdatetime(now), dfr.text_rendition_event_cd = form_temp->
    text_rendition_event_cd
   WITH nocounter
  ;end insert
  IF (section_cnt > 0)
   INSERT  FROM dcp_forms_def dfd,
     (dummyt d  WITH seq = value(section_cnt))
    SET dfd.dcp_forms_def_id = cnvtreal(seq(carenet_seq,nextval)), dfd.dcp_form_instance_id =
     instance_id, dfd.dcp_forms_ref_id = form_temp->dcp_forms_ref_id,
     dfd.dcp_section_ref_id = form_temp->sections[d.seq].dcp_section_ref_id, dfd.section_seq = d.seq,
     dfd.flags = form_temp->sections[d.seq].flags,
     dfd.active_ind = 1, dfd.updt_id = reqinfo->updt_id, dfd.updt_task = reqinfo->updt_task,
     dfd.updt_applctx = reqinfo->updt_applctx, dfd.updt_cnt = 0, dfd.updt_dt_tm = cnvtdatetime(now)
    PLAN (d)
     JOIN (dfd)
    WITH nocounter
   ;end insert
  ENDIF
 ENDIF
 SET delapsedtime = datetimediff(cnvtdatetime(curdate,curtime3),dactionstarttime,5)
 IF (script_debug_ind=1)
  CALL echo("*******************************************************")
  CALL echo(build("update form time = ",delapsedtime))
  CALL echo("*******************************************************")
 ENDIF
 SET dactionstarttime = cnvtdatetime(curdate,curtime3)
 IF ((form_temp->dcp_forms_ref_id > 0))
  SELECT INTO "nl:"
   FROM order_task ot
   WHERE (ot.dcp_forms_ref_id=form_temp->dcp_forms_ref_id)
    AND ot.active_ind=1
   ORDER BY ot.reference_task_id
   DETAIL
    task_cnt = (task_cnt+ 1), stat = alterlist(form_temp->tasks,task_cnt), form_temp->tasks[task_cnt]
    .reference_task_id = ot.reference_task_id,
    form_temp->tasks[task_cnt].description = ot.task_description, form_temp->tasks[task_cnt].
    short_description = ot.task_description_key
   WITH nocounter
  ;end select
  SET delapsedtime = datetimediff(cnvtdatetime(curdate,curtime3),dactionstarttime,5)
  IF (script_debug_ind=1)
   CALL echo("*******************************************************")
   CALL echo(build("select tasks linked to the form time = ",delapsedtime))
   CALL echo(build("task_cnt = ",task_cnt))
   CALL echo("*******************************************************")
  ENDIF
  IF (task_cnt <= 0)
   CALL echo("No tasks linked to the form.")
  ELSE
   SET dactionstarttime = cnvtdatetime(curdate,curtime3)
   SELECT INTO "nl:"
    FROM task_discrete_r tdr,
     (dummyt d  WITH seq = value(task_cnt))
    PLAN (d)
     JOIN (tdr
     WHERE (tdr.reference_task_id=form_temp->tasks[d.seq].reference_task_id))
    ORDER BY tdr.reference_task_id, tdr.task_assay_cd
    DETAIL
     current_tdr_cnt = (current_tdr_cnt+ 1)
     IF (mod(current_tdr_cnt,20)=1)
      stat = alterlist(tdrs->current,(current_tdr_cnt+ 19))
     ENDIF
     tdrs->current[current_tdr_cnt].reference_task_id = tdr.reference_task_id, tdrs->current[
     current_tdr_cnt].task_assay_cd = tdr.task_assay_cd, tdrs->current[current_tdr_cnt].sequence =
     tdr.sequence,
     tdrs->current[current_tdr_cnt].active_ind = tdr.active_ind, tdrs->current[current_tdr_cnt].
     required_ind = tdr.required_ind, tdrs->current[current_tdr_cnt].acknowledge_ind = tdr
     .acknowledge_ind,
     tdrs->current[current_tdr_cnt].document_ind = tdr.document_ind, tdrs->current[current_tdr_cnt].
     view_only_ind = tdr.view_only_ind, tdrs->current[current_tdr_cnt].updt_cnt = tdr.updt_cnt
    FOOT REPORT
     stat = alterlist(tdrs->current,current_tdr_cnt)
    WITH nocounter
   ;end select
   SET delapsedtime = datetimediff(cnvtdatetime(curdate,curtime3),dactionstarttime,5)
   IF (script_debug_ind=1)
    CALL echo("*******************************************************")
    CALL echo(build("select from tdr time = ",delapsedtime))
    CALL echo(build("current_tdr_cnt = ",current_tdr_cnt))
    CALL echo("*******************************************************")
   ENDIF
  ENDIF
  IF (size(form_temp->dtas,5) <= 0)
   CALL echo("No DTAs exist on the form.")
  ELSE
   SET dactionstarttime = cnvtdatetime(curdate,curtime3)
   SELECT DISTINCT INTO "nl:"
    form_temp->dtas[d1.seq].task_assay_cd
    FROM (dummyt d1  WITH seq = value(size(form_temp->dtas,5)))
    PLAN (d1)
    ORDER BY form_temp->dtas[d1.seq].task_assay_cd
    HEAD REPORT
     new_tdr_cnt = 0
    DETAIL
     new_tdr_cnt = (new_tdr_cnt+ 1)
     IF (mod(new_tdr_cnt,20)=1)
      stat = alterlist(tdrs->new,(new_tdr_cnt+ 19))
     ENDIF
     tdrs->new[new_tdr_cnt].task_assay_cd = form_temp->dtas[d1.seq].task_assay_cd, tdrs->new[
     new_tdr_cnt].required_ind = form_temp->dtas[d1.seq].required_ind, tdrs->new[new_tdr_cnt].
     sequence = new_tdr_cnt
    FOOT REPORT
     stat = alterlist(tdrs->new,new_tdr_cnt)
    WITH nocounter
   ;end select
   SET delapsedtime = datetimediff(cnvtdatetime(curdate,curtime3),dactionstarttime,5)
   IF (script_debug_ind=1)
    CALL echo("*******************************************************")
    CALL echo(build("select distinct dtas time = ",delapsedtime))
    CALL echo(build("new_tdr_cnt = ",new_tdr_cnt))
    CALL echo("*******************************************************")
   ENDIF
  ENDIF
  IF (script_debug_ind=1)
   CALL echo("tdrs before synch")
   CALL echorecord(tdrs)
  ENDIF
  SET dactionstarttime = cnvtdatetime(curdate,curtime3)
  FOR (i = 1 TO task_cnt)
    FOR (j = 1 TO new_tdr_cnt)
     IF (current_tdr_cnt > 0)
      SET pos = locatevalsort(idx,1,current_tdr_cnt,form_temp->tasks[i].reference_task_id,tdrs->
       current[idx].reference_task_id,
       tdrs->new[j].task_assay_cd,tdrs->current[idx].task_assay_cd)
     ELSE
      SET pos = 0
     ENDIF
     IF (pos <= 0)
      SET add_tdr_cnt = (add_tdr_cnt+ 1)
      IF (mod(add_tdr_cnt,10)=1)
       SET stat = alterlist(tdrs->add,(add_tdr_cnt+ 9))
      ENDIF
      SET tdrs->add[add_tdr_cnt].reference_task_id = form_temp->tasks[i].reference_task_id
      SET tdrs->add[add_tdr_cnt].task_assay_cd = tdrs->new[j].task_assay_cd
      SET tdrs->add[add_tdr_cnt].sequence = tdrs->new[j].sequence
      SET tdrs->add[add_tdr_cnt].active_ind = 1
      SET tdrs->add[add_tdr_cnt].required_ind = tdrs->new[j].required_ind
      SET tdrs->add[add_tdr_cnt].acknowledge_ind = 0
      SET tdrs->add[add_tdr_cnt].document_ind = 0
      SET tdrs->add[add_tdr_cnt].view_only_ind = 0
     ELSE
      IF ((((tdrs->current[pos].sequence != tdrs->new[j].sequence)) OR ((((tdrs->current[pos].
      required_ind != tdrs->new[j].required_ind)) OR ((tdrs->current[pos].active_ind != 1))) )) )
       SET modify_tdr_cnt = (modify_tdr_cnt+ 1)
       IF (mod(modify_tdr_cnt,10)=1)
        SET stat = alterlist(tdrs->modify,(modify_tdr_cnt+ 9))
       ENDIF
       SET tdrs->modify[modify_tdr_cnt].reference_task_id = tdrs->current[pos].reference_task_id
       SET tdrs->modify[modify_tdr_cnt].task_assay_cd = tdrs->current[pos].task_assay_cd
       SET tdrs->modify[modify_tdr_cnt].sequence = tdrs->new[j].sequence
       SET tdrs->modify[modify_tdr_cnt].active_ind = 1
       SET tdrs->modify[modify_tdr_cnt].required_ind = tdrs->new[j].required_ind
       SET tdrs->modify[modify_tdr_cnt].acknowledge_ind = tdrs->current[pos].acknowledge_ind
       SET tdrs->modify[modify_tdr_cnt].document_ind = tdrs->current[pos].document_ind
       SET tdrs->modify[modify_tdr_cnt].view_only_ind = tdrs->current[pos].view_only_ind
       SET tdrs->modify[modify_tdr_cnt].updt_cnt = tdrs->current[pos].updt_cnt
      ENDIF
      SET tdrs->current[pos].transferred = 1
     ENDIF
    ENDFOR
  ENDFOR
  FOR (i = 1 TO current_tdr_cnt)
    IF ((tdrs->current[i].transferred=0))
     SET remove_tdr_cnt = (remove_tdr_cnt+ 1)
     SET stat = alterlist(tdrs->remove,remove_tdr_cnt)
     IF (mod(remove_tdr_cnt,10)=1)
      SET stat = alterlist(tdrs->remove,(remove_tdr_cnt+ 9))
     ENDIF
     SET tdrs->remove[remove_tdr_cnt].reference_task_id = tdrs->current[i].reference_task_id
     SET tdrs->remove[remove_tdr_cnt].task_assay_cd = tdrs->current[i].task_assay_cd
    ENDIF
  ENDFOR
  SET stat = alterlist(tdrs->add,add_tdr_cnt)
  SET stat = alterlist(tdrs->modify,modify_tdr_cnt)
  SET stat = alterlist(tdrs->remove,remove_tdr_cnt)
  SET delapsedtime = datetimediff(cnvtdatetime(curdate,curtime3),dactionstarttime,5)
  IF (script_debug_ind=1)
   CALL echo("*******************************************************")
   CALL echo(build("TDR sync time = ",delapsedtime))
   CALL echo(build("add_tdr_cnt = ",add_tdr_cnt))
   CALL echo(build("modify_tdr_cnt = ",modify_tdr_cnt))
   CALL echo(build("remove_tdr_cnt = ",remove_tdr_cnt))
   CALL echo("*******************************************************")
  ENDIF
  IF (add_tdr_cnt > 0)
   SET dactionstarttime = cnvtdatetime(curdate,curtime3)
   INSERT  FROM task_discrete_r tdr,
     (dummyt d  WITH seq = value(add_tdr_cnt))
    SET tdr.reference_task_id = tdrs->add[d.seq].reference_task_id, tdr.task_assay_cd = tdrs->add[d
     .seq].task_assay_cd, tdr.sequence = tdrs->add[d.seq].sequence,
     tdr.active_ind = tdrs->add[d.seq].active_ind, tdr.required_ind = tdrs->add[d.seq].required_ind,
     tdr.acknowledge_ind = tdrs->add[d.seq].acknowledge_ind,
     tdr.document_ind = tdrs->add[d.seq].document_ind, tdr.view_only_ind = tdrs->add[d.seq].
     view_only_ind, tdr.updt_dt_tm = cnvtdatetime(now),
     tdr.updt_id = reqinfo->updt_id, tdr.updt_task = reqinfo->updt_task, tdr.updt_cnt = 0,
     tdr.updt_applctx = reqinfo->updt_applctx
    PLAN (d)
     JOIN (tdr)
    WITH nocounter
   ;end insert
   SET delapsedtime = datetimediff(cnvtdatetime(curdate,curtime3),dactionstarttime,5)
   CALL fillsubeventstatus("INSERT","S","dcp_scan_form",build("insert(",add_tdr_cnt,
     ") into tdr time = ",delapsedtime))
   IF (script_debug_ind=1)
    CALL echo("*******************************************************")
    CALL echo(build("insert into tdr time = ",delapsedtime))
    CALL echo("*******************************************************")
   ENDIF
  ENDIF
  IF (modify_tdr_cnt > 0)
   SET dactionstarttime = cnvtdatetime(curdate,curtime3)
   UPDATE  FROM task_discrete_r tdr,
     (dummyt d  WITH seq = value(modify_tdr_cnt))
    SET tdr.reference_task_id = tdrs->modify[d.seq].reference_task_id, tdr.task_assay_cd = tdrs->
     modify[d.seq].task_assay_cd, tdr.sequence = tdrs->modify[d.seq].sequence,
     tdr.active_ind = tdrs->modify[d.seq].active_ind, tdr.required_ind = tdrs->modify[d.seq].
     required_ind, tdr.acknowledge_ind = tdrs->modify[d.seq].acknowledge_ind,
     tdr.document_ind = tdrs->modify[d.seq].document_ind, tdr.view_only_ind = tdrs->modify[d.seq].
     view_only_ind, tdr.updt_dt_tm = cnvtdatetime(now),
     tdr.updt_id = reqinfo->updt_id, tdr.updt_task = reqinfo->updt_task, tdr.updt_cnt = (tdrs->
     modify[d.seq].updt_cnt+ 1),
     tdr.updt_applctx = reqinfo->updt_applctx
    PLAN (d)
     JOIN (tdr
     WHERE (tdr.reference_task_id=tdrs->modify[d.seq].reference_task_id)
      AND (tdr.task_assay_cd=tdrs->modify[d.seq].task_assay_cd))
    WITH nocounter
   ;end update
   SET delapsedtime = datetimediff(cnvtdatetime(curdate,curtime3),dactionstarttime,5)
   CALL fillsubeventstatus("UPDATE","S","dcp_scan_form",build("update(",modify_tdr_cnt,
     ") into tdr time = ",delapsedtime))
   IF (script_debug_ind=1)
    CALL echo("*******************************************************")
    CALL echo(build("update into tdr time = ",delapsedtime))
    CALL echo("*******************************************************")
   ENDIF
  ENDIF
  IF (remove_tdr_cnt > 0)
   SET dactionstarttime = cnvtdatetime(curdate,curtime3)
   DELETE  FROM task_discrete_r tdr
    SET tdr.seq = 1
    PLAN (tdr
     WHERE expand(idx,1,remove_tdr_cnt,tdr.reference_task_id,tdrs->remove[idx].reference_task_id,
      tdr.task_assay_cd,tdrs->remove[idx].task_assay_cd))
    WITH expand = 1, nocounter
   ;end delete
   SET delapsedtime = datetimediff(cnvtdatetime(curdate,curtime3),dactionstarttime,5)
   CALL fillsubeventstatus("DELETE","S","dcp_scan_form",build("delete(",remove_tdr_cnt,
     ") from tdr time = ",delapsedtime))
   IF (script_debug_ind=1)
    CALL echo("*******************************************************")
    CALL echo(build("delete from tdr time = ",delapsedtime))
    CALL echo("*******************************************************")
   ENDIF
  ENDIF
 ENDIF
 IF (script_debug_ind=1)
  CALL echorecord(form_temp)
 ENDIF
 IF (script_debug_ind=1)
  CALL echorecord(tdrs)
 ENDIF
 SET delapsedtime = datetimediff(cnvtdatetime(curdate,curtime3),dscriptstarttime,5)
 CALL fillsubeventstatus("UPDATE","S","dcp_scan_form",build("form(",instance_id,") total time = ",
   delapsedtime))
 IF (script_debug_ind=1)
  CALL echo("*******************************************************")
  CALL echo("dcp_scan_form Last Modified = 007 02/09/11")
  CALL echo(build("dcp_scan_form Total Time = ",delapsedtime))
  CALL echo("*******************************************************")
 ENDIF
 IF (script_debug_ind=0)
  FREE SET form_temp
  FREE SET tdrs
 ENDIF
 SET modify = nopredeclare
END GO
