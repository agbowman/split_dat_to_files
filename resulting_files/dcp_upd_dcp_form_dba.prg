CREATE PROGRAM dcp_upd_dcp_form:dba
 IF (validate(reply,"0")="0")
  RECORD reply(
    1 dcp_forms_ref_id = f8
    1 dcp_form_instance_id = f8
    1 updt_cnt = i4
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
 DECLARE form_ref_id = f8 WITH protect, noconstant(request->dcp_forms_ref_id)
 DECLARE form_text_rendition_event_cd = f8 WITH protect, noconstant(validate(request->
   text_rendition_event_cd,0.0))
 DECLARE form_instance_id = f8 WITH protect, noconstant(0.0)
 DECLARE event_set_name = vc WITH protect
 SET cnt = size(request->sect_list,5)
 SET event_set_name = fillstring(100," ")
 SET event_set_name = validate(request->event_set_name," ")
 SET sect_cnt = 0
 SET task_cnt = 0
 SET dta_cnt = 0
 SET input_cnt = 0
 SET prop_cnt = 0
 DECLARE form_dta = f8 WITH protect, noconstant(0.0)
 SET required = 0
 SET max_width = 0
 SET max_height = 0
 SET stat = 0
 SET updt_cnt = 0
 SET now = cnvtdatetime(curdate,curtime)
 DECLARE flag = i4
 DECLARE flag1 = i4
 DECLARE result = i4
 DECLARE pos = i4
 DECLARE val = vc
 DECLARE form_task_assay_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",13016,
   "TASK ASSAY"))
 DECLARE form_taskcat_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",13016,"TASKCAT"))
 DECLARE form_task_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",106,"TASK"))
 FREE SET temp
 RECORD temp(
   1 sections[*]
     2 dcp_section_ref_id = f8
     2 flags = i4
     2 inputs[*]
       3 input_type = i4
       3 properties[*]
         4 pvc_name = vc
         4 pvc_value = vc
         4 merge_id = f8
   1 dtas[*]
     2 task_assay_cd = f8
     2 required = i2
   1 tasks[*]
     2 reference_task_id = f8
     2 description = vc
     2 short_description = vc
 )
 FREE SET temp2
 RECORD temp2(
   1 dtas[*]
     2 task_assay_cd = f8
     2 required = i2
     2 activity_type_cd = f8
     2 description = vc
     2 mnemonic = vc
 )
 IF (form_ref_id=0)
  SELECT INTO "nl:"
   w = seq(carenet_seq,nextval)
   FROM dual
   DETAIL
    form_ref_id = cnvtreal(w)
   WITH nocounter
  ;end select
  CALL echo(build("form_ref_id",form_ref_id))
 ELSE
  SELECT INTO "nl:"
   FROM dcp_forms_ref r
   WHERE r.dcp_forms_ref_id=form_ref_id
    AND r.active_ind=1
   DETAIL
    updt_cnt = r.updt_cnt, form_instance_id = r.dcp_form_instance_id
   WITH maxqual(r,1), nocounter
  ;end select
  IF (curqual=0)
   GO TO exit_script
  ENDIF
  IF ((updt_cnt=request->updt_cnt))
   UPDATE  FROM dcp_forms_ref dfr
    SET dfr.active_ind = 0, dfr.end_effective_dt_tm = cnvtdatetime(now), dfr.updt_id = reqinfo->
     updt_id,
     dfr.updt_task = reqinfo->updt_task, dfr.updt_applctx = reqinfo->updt_applctx, dfr.updt_dt_tm =
     cnvtdatetime(now)
    WHERE dfr.dcp_form_instance_id=form_instance_id
    WITH nocounter
   ;end update
   SET updt_cnt = (updt_cnt+ 1)
  ELSE
   GO TO exit_script
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cnt)),
   dcp_section_ref s,
   dcp_input_ref i,
   name_value_prefs nv
  PLAN (d)
   JOIN (s
   WHERE (s.dcp_section_ref_id=request->sect_list[d.seq].dcp_section_ref_id)
    AND s.active_ind=1)
   JOIN (i
   WHERE s.dcp_section_instance_id=i.dcp_section_instance_id)
   JOIN (nv
   WHERE nv.parent_entity_id=i.dcp_input_ref_id
    AND nv.parent_entity_name="DCP_INPUT_REF")
  ORDER BY d.seq, i.dcp_input_ref_id, nv.pvc_name,
   nv.sequence
  HEAD s.dcp_section_ref_id
   sect_cnt = (sect_cnt+ 1), stat = alterlist(temp->sections,sect_cnt), input_cnt = 0,
   temp->sections[sect_cnt].dcp_section_ref_id = s.dcp_section_ref_id, temp->sections[sect_cnt].flags
    = 0, max_width = maxval(max_width,s.width),
   max_height = maxval(max_height,s.height)
  HEAD i.dcp_input_ref_id
   input_cnt = (input_cnt+ 1), stat = alterlist(temp->sections[sect_cnt].inputs,input_cnt), prop_cnt
    = 0,
   temp->sections[sect_cnt].inputs[input_cnt].input_type = i.input_type
  DETAIL
   prop_cnt = (prop_cnt+ 1), stat = alterlist(temp->sections[sect_cnt].inputs[input_cnt].properties,
    prop_cnt), temp->sections[sect_cnt].inputs[input_cnt].properties[prop_cnt].pvc_name = nv.pvc_name,
   temp->sections[sect_cnt].inputs[input_cnt].properties[prop_cnt].pvc_value = nv.pvc_value, temp->
   sections[sect_cnt].inputs[input_cnt].properties[prop_cnt].merge_id = nv.merge_id
  WITH nocounter
 ;end select
 SET sect_cnt = size(temp->sections,5)
 FOR (i = 1 TO sect_cnt)
  SET input_cnt = size(temp->sections[i].inputs,5)
  FOR (j = 1 TO input_cnt)
    SET prop_cnt = size(temp->sections[i].inputs[j].properties,5)
    SET form_dta = 0
    SET required = 0
    FOR (k = 1 TO prop_cnt)
      IF ((temp->sections[i].inputs[j].properties[k].pvc_name="conditional_section"))
       FOR (l = 1 TO sect_cnt)
         IF ((temp->sections[l].dcp_section_ref_id=temp->sections[i].inputs[j].properties[k].merge_id
         ))
          SET temp->sections[l].flags = bor(temp->sections[l].flags,1)
         ENDIF
       ENDFOR
      ELSEIF ((temp->sections[i].inputs[j].properties[k].pvc_name="required"))
       IF ((temp->sections[i].inputs[j].properties[k].pvc_value="true"))
        SET required = 1
       ENDIF
      ELSEIF ((temp->sections[i].inputs[j].properties[k].pvc_name="discrete_task_assay2")
       AND (temp->sections[i].inputs[j].input_type=19))
       IF ((temp->sections[i].inputs[j].properties[k].merge_id > 0))
        SET dta_cnt = (dta_cnt+ 1)
        SET stat = alterlist(temp->dtas,dta_cnt)
        SET temp->dtas[dta_cnt].task_assay_cd = temp->sections[i].inputs[j].properties[k].merge_id
        SET temp->dtas[dta_cnt].required = required
       ENDIF
      ELSEIF ((temp->sections[i].inputs[j].properties[k].pvc_name="discrete_task_assay"))
       IF ((temp->sections[i].inputs[j].input_type=14))
        IF ((temp->sections[i].inputs[j].properties[k].merge_id > 0))
         SET flag = cnvtint(temp->sections[i].inputs[j].properties[k].pvc_value)
         SET result = band(flag,2)
         SET dta_cnt = (dta_cnt+ 1)
         SET stat = alterlist(temp->dtas,dta_cnt)
         SET temp->dtas[dta_cnt].task_assay_cd = temp->sections[i].inputs[j].properties[k].merge_id
         IF (result=2)
          SET temp->dtas[dta_cnt].required = 1
         ELSE
          SET temp->dtas[dta_cnt].required = 0
         ENDIF
        ENDIF
       ELSEIF ((((temp->sections[i].inputs[j].input_type=17)) OR ((temp->sections[i].inputs[j].
       input_type=19))) )
        IF ((temp->sections[i].inputs[j].properties[k].merge_id > 0))
         SET pos = findstring(";",temp->sections[i].inputs[j].properties[k].pvc_value)
         SET val = substring(1,(pos - 1),temp->sections[i].inputs[j].properties[k].pvc_value)
         SET flag = cnvtint(val)
         SET result = band(flag,1)
         SET dta_cnt = (dta_cnt+ 1)
         SET stat = alterlist(temp->dtas,dta_cnt)
         SET temp->dtas[dta_cnt].task_assay_cd = temp->sections[i].inputs[j].properties[k].merge_id
         IF (result=1)
          SET temp->dtas[dta_cnt].required = 1
         ELSE
          SET temp->dtas[dta_cnt].required = 0
         ENDIF
        ENDIF
       ELSEIF ( NOT ((temp->sections[i].inputs[j].input_type=19)))
        SET form_dta = temp->sections[i].inputs[j].properties[k].merge_id
       ENDIF
      ELSEIF ((temp->sections[i].inputs[j].properties[k].pvc_name="task_assay_cd"))
       SET form_dta = cnvtreal(temp->sections[i].inputs[j].properties[k].pvc_value)
      ENDIF
    ENDFOR
    IF (form_dta > 0)
     SET dta_cnt = (dta_cnt+ 1)
     SET stat = alterlist(temp->dtas,dta_cnt)
     SET temp->dtas[dta_cnt].task_assay_cd = form_dta
     SET temp->dtas[dta_cnt].required = required
    ENDIF
  ENDFOR
 ENDFOR
 SELECT INTO "nl:"
  w = seq(carenet_seq,nextval)
  FROM dual
  DETAIL
   form_instance_id = cnvtreal(w)
  WITH nocounter
 ;end select
 CALL echo(build("form_instance_id:",form_instance_id))
 INSERT  FROM dcp_forms_ref dfr
  SET dfr.dcp_form_instance_id = form_instance_id, dfr.dcp_forms_ref_id = form_ref_id, dfr
   .description = request->description,
   dfr.definition = request->definition, dfr.task_assay_cd = request->task_assay_cd, dfr.event_cd =
   request->event_cd,
   dfr.event_set_name = event_set_name, dfr.done_charting_ind = 0, dfr.active_ind = 1,
   dfr.width = max_width, dfr.height = max_height, dfr.flags = request->flags,
   dfr.beg_effective_dt_tm = cnvtdatetime(now), dfr.end_effective_dt_tm = cnvtdatetime("31-Dec-2100"),
   dfr.updt_id = reqinfo->updt_id,
   dfr.updt_task = reqinfo->updt_task, dfr.updt_applctx = reqinfo->updt_applctx, dfr.updt_cnt =
   updt_cnt,
   dfr.updt_dt_tm = cnvtdatetime(now), dfr.text_rendition_event_cd = form_text_rendition_event_cd
  WITH nocounter
 ;end insert
 IF (curqual=0)
  GO TO exit_script
 ENDIF
 FOR (i = 1 TO sect_cnt)
   INSERT  FROM dcp_forms_def dfd
    SET dfd.dcp_forms_def_id = cnvtreal(seq(carenet_seq,nextval)), dfd.dcp_form_instance_id =
     form_instance_id, dfd.dcp_forms_ref_id = form_ref_id,
     dfd.dcp_section_ref_id = temp->sections[i].dcp_section_ref_id, dfd.section_seq = i, dfd.flags =
     temp->sections[i].flags,
     dfd.active_ind = 1, dfd.updt_id = reqinfo->updt_id, dfd.updt_task = reqinfo->updt_task,
     dfd.updt_applctx = reqinfo->updt_applctx, dfd.updt_cnt = 0, dfd.updt_dt_tm = cnvtdatetime(now)
    WITH nocounter
   ;end insert
 ENDFOR
 IF (curqual=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM order_task ot
  WHERE ot.dcp_forms_ref_id=form_ref_id
  DETAIL
   task_cnt = (task_cnt+ 1), stat = alterlist(temp->tasks,task_cnt), temp->tasks[task_cnt].
   reference_task_id = ot.reference_task_id,
   CALL echo(build("ref_task:",ot.reference_task_id))
  WITH nocounter
 ;end select
 IF (size(temp->dtas,5) > 0)
  SELECT DISTINCT INTO "nl:"
   temp->dtas[d1.seq].task_assay_cd
   FROM (dummyt d1  WITH seq = value(size(temp->dtas,5)))
   PLAN (d1)
   ORDER BY temp->dtas[d1.seq].task_assay_cd
   HEAD REPORT
    item_count = 0
   DETAIL
    item_count = (item_count+ 1)
    IF (mod(item_count,10)=1)
     stat = alterlist(temp2->dtas,(item_count+ 9))
    ENDIF
    temp2->dtas[item_count].task_assay_cd = temp->dtas[d1.seq].task_assay_cd, temp2->dtas[item_count]
    .required = temp->dtas[d1.seq].required
   FOOT REPORT
    stat = alterlist(temp2->dtas,item_count)
   WITH nocounter
  ;end select
 ENDIF
 FOR (i = 1 TO task_cnt)
  DELETE  FROM task_discrete_r
   WHERE (reference_task_id=temp->tasks[i].reference_task_id)
   WITH nocounter
  ;end delete
  FOR (j = 1 TO size(temp2->dtas,5))
    INSERT  FROM task_discrete_r tdr
     SET tdr.reference_task_id = temp->tasks[i].reference_task_id, tdr.task_assay_cd = temp2->dtas[j]
      .task_assay_cd, tdr.sequence = j,
      tdr.active_ind = 1, tdr.required_ind = temp2->dtas[j].required, tdr.updt_dt_tm = cnvtdatetime(
       curdate,curtime3),
      tdr.updt_id = reqinfo->updt_id, tdr.updt_task = reqinfo->updt_task, tdr.updt_cnt = 0,
      tdr.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
  ENDFOR
 ENDFOR
 IF (task_cnt != 0)
  FREE SET request
  RECORD request(
    1 nbr_of_recs = i2
    1 qual[*]
      2 action = i2
      2 ext_id = f8
      2 ext_contributor_cd = f8
      2 parent_qual_ind = f8
      2 ext_owner_cd = f8
      2 ext_description = vc
      2 ext_short_desc = c50
      2 build_ind = i2
      2 careset_ind = i2
      2 workload_only_ind = i2
      2 child_qual = i2
      2 price_qual = i2
      2 prices[*]
        3 price_sched_id = f8
        3 price = f8
      2 billcode_qual = i2
      2 billcodes[*]
        3 billcode_sched_cd = f8
        3 billcode = c25
      2 children[*]
        3 ext_id = f8
        3 ext_contributor_cd = f8
        3 ext_description = c100
        3 ext_short_desc = c50
        3 build_ind = i2
        3 ext_owner_cd = f8
  )
  RECORD afcreply(
    1 bill_item_qual = i4
    1 bill_item[*]
      2 bill_item_id = f8
    1 qual[*]
      2 bill_item_id = f8
    1 price_sched_items_qual = i2
    1 price_sched_items[*]
      2 price_sched_id = f8
      2 price_sched_items_id = f8
    1 bill_item_modifier_qual = i2
    1 bill_item_modifier[10]
      2 bill_item_mod_id = f8
    1 actioncnt = i2
    1 actionlist[*]
      2 action1 = vc
      2 action2 = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c20
        3 targetobjectname = c15
        3 targetobjectvalue = vc
  )
  SET rec_idx = 0
  SET dta_cnt = size(temp2->dtas,5)
  IF (dta_cnt != 0)
   DECLARE max_dta_cnt = i4 WITH constant(200)
   DECLARE dta_expand_size = i4 WITH noconstant(0)
   SET dta_expand_size = ceil(((dta_cnt * 1.0)/ max_dta_cnt))
   DECLARE totalexpanddtasize = i4 WITH noconstant(0)
   DECLARE expand_start = i4 WITH noconstant(0)
   DECLARE expand_end = i4 WITH noconstant(0)
   DECLARE expand_idx = i4 WITH noconstant(0)
   SET totalexpanddtasize = (dta_expand_size * max_dta_cnt)
   SET stat = alterlist(temp2->dtas,totalexpanddtasize)
   DECLARE locidx = i4 WITH noconstant(0)
   DECLARE locpos = i4 WITH noconstant(0)
   FOR (i = (dta_cnt+ 1) TO dta_expand_size)
     SET temp2->dtas[i].task_assay_cd = temp2->dtas[dta_cnt].task_assay_cd
   ENDFOR
   SET expand_start = 1
   SELECT INTO "nl:"
    FROM discrete_task_assay dta,
     (dummyt d  WITH seq = value(dta_expand_size))
    PLAN (d
     WHERE assign(expand_start,evaluate(d.seq,1,1,(expand_start+ max_dta_cnt))))
     JOIN (dta
     WHERE expand(expand_idx,expand_start,((expand_start+ max_dta_cnt) - 1),dta.task_assay_cd,temp2->
      dtas[expand_idx].task_assay_cd))
    DETAIL
     locpos = locateval(locidx,1,dta_cnt,dta.task_assay_cd,temp2->dtas[locidx].task_assay_cd)
     IF (locpos != 0)
      temp2->dtas[locpos].activity_type_cd = dta.activity_type_cd, temp2->dtas[locpos].description =
      dta.description, temp2->dtas[locpos].mnemonic = dta.mnemonic
     ENDIF
    WITH counter
   ;end select
  ENDIF
  SET stat = alterlist(request->qual,task_cnt)
  FOR (i = 1 TO task_cnt)
    SET request->qual[i].action = 1
    SET request->qual[i].ext_id = temp->tasks[i].reference_task_id
    SET request->qual[i].ext_contributor_cd = form_taskcat_cd
    SET request->qual[i].parent_qual_ind = 1
    SET request->qual[i].careset_ind = 0
    SET request->qual[i].child_qual = dta_cnt
    SET request->qual[i].ext_owner_cd = form_task_cd
    SET request->qual[i].ext_description = temp->tasks[i].description
    SET request->qual[i].ext_short_desc = temp->tasks[i].short_description
    SET stat = alterlist(request->qual[i].children,dta_cnt)
    FOR (j = 1 TO dta_cnt)
      SET request->qual[i].children[j].ext_id = temp2->dtas[j].task_assay_cd
      SET request->qual[i].children[j].ext_contributor_cd = form_task_assay_cd
      SET request->qual[i].children[j].ext_description = temp2->dtas[j].description
      SET request->qual[i].children[j].ext_short_desc = temp2->dtas[j].mnemonic
      SET request->qual[i].children[j].ext_owner_cd = temp2->dtas[j].activity_type_cd
    ENDFOR
    IF (dta_cnt=0)
     SET stat = alterlist(request->qual[i].children,1)
     SET request->qual[i].children[j].ext_id = 0
     SET request->qual[i].children[j].ext_contributor_cd = form_task_assay_cd
    ENDIF
  ENDFOR
  SET request->nbr_of_recs = task_cnt
  EXECUTE afc_add_reference_api  WITH replace("REPLY","AFCREPLY")
 ENDIF
 SET reply->dcp_forms_ref_id = form_ref_id
 SET reply->dcp_form_instance_id = form_instance_id
 SET reply->status_data.status = "S"
 SET reply->updt_cnt = updt_cnt
 SET reqinfo->commit_ind = 1
#exit_script
 CALL echo(build("status:",reply->status_data.status))
 CALL echo(build("InstanceId:",reply->dcp_form_instance_id))
END GO
