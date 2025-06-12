CREATE PROGRAM dcp_forms_upd_afc:dba
 RECORD formslist(
   1 forms[*]
     2 dcp_forms_ref_id = f8
     2 form_instance_id = f8
     2 task_assay_cd = f8
     2 sections[*]
       3 dcp_section_ref_id = f8
       3 dcp_section_instance_id = f8
       3 inputs[*]
         4 input_type = i4
         4 properties[*]
           5 pvc_name = vc
           5 pvc_value = vc
           5 merge_id = f8
     2 dtas[*]
       3 task_assay_cd = f8
       3 description = vc
       3 mnemonic = vc
       3 activity_type_cd = f8
   1 tasks[*]
     2 reference_task_id = f8
     2 description = vc
     2 short_description = vc
       3 form_index = i4
 )
 RECORD dtatemplist(
   1 dtas[*]
     2 task_assay_cd = f8
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
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE task_assay_cd = f8 WITH public, noconstant(uar_get_code_by("meaning",13016,"TASK ASSAY"))
 DECLARE taskcat_cd = f8 WITH public, noconstant(uar_get_code_by("meaning",13016,"TASKCAT"))
 DECLARE task_cd = f8 WITH public, noconstant(uar_get_code_by("meaning",106,"TASK"))
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
 DECLARE forms_cnt = i4 WITH protected, noconstant(0)
 DECLARE section_id = f8 WITH protected, noconstant(request->dcp_section_id)
 DECLARE stat = i4 WITH protected, noconstant(0)
 DECLARE section_cnt = i4 WITH protected, noconstant(0)
 DECLARE input_cnt = i4 WITH protected, noconstant(0)
 DECLARE prop_cnt = i4 WITH protected, noconstant(0)
 DECLARE formidx = i4 WITH protected, noconstant(0)
 DECLARE dta_cnt = i4 WITH protected, noconstant(0)
 DECLARE task_cnt = i4 WITH protected, noconstant(0)
 DECLARE dta = f8 WITH protected, noconstant(0.0)
 DECLARE dtaidx = i4 WITH protected, noconstant(0)
 DECLARE batch_size = i4 WITH protected, noconstant(0)
 DECLARE loop_cnt = i4 WITH protected, noconstant(0)
 DECLARE max_list_size = i4 WITH protected, noconstant(0)
 DECLARE expand_start = i4 WITH protected, noconstant(1)
 DECLARE loop_idx = i4 WITH protected, noconstant(0)
 DECLARE idx = i4 WITH protected, noconstant(0)
 SELECT INTO "nl:"
  FROM dcp_forms_def d,
   dcp_forms_ref r
  WHERE d.dcp_section_ref_id=section_id
   AND r.dcp_form_instance_id=d.dcp_form_instance_id
   AND r.active_ind=1
  HEAD REPORT
   forms_cnt = 0
  DETAIL
   forms_cnt = (forms_cnt+ 1)
   IF (mod(forms_cnt,10)=1)
    stat = alterlist(formslist->forms,(forms_cnt+ 9))
   ENDIF
   formslist->forms[forms_cnt].form_instance_id = r.dcp_form_instance_id, formslist->forms[forms_cnt]
   .dcp_forms_ref_id = r.dcp_forms_ref_id
  FOOT REPORT
   stat = alterlist(formslist->forms,forms_cnt)
  WITH nocounter
 ;end select
 SET batch_size = 20
 SET loop_cnt = ceil((cnvtreal(forms_cnt)/ batch_size))
 SET max_list_size = (batch_size * loop_cnt)
 SET stat = alterlist(formslist->forms,max_list_size)
 FOR (loop_idx = (forms_cnt+ 1) TO max_list_size)
  SET formslist->forms[loop_idx].dcp_forms_ref_id = formslist->forms[forms_cnt].dcp_forms_ref_id
  SET formslist->forms[loop_idx].form_instance_id = formslist->forms[forms_cnt].form_instance_id
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(loop_cnt)),
   dcp_forms_ref r,
   dcp_forms_def d,
   dcp_section_ref s,
   dcp_input_ref i,
   name_value_prefs nvp
  PLAN (d1
   WHERE assign(expand_start,evaluate(d1.seq,1,1,(expand_start+ batch_size))))
   JOIN (r
   WHERE expand(idx,expand_start,(expand_start+ (batch_size - 1)),r.dcp_form_instance_id,formslist->
    forms[idx].form_instance_id)
    AND r.active_ind=1)
   JOIN (d
   WHERE d.dcp_form_instance_id=r.dcp_form_instance_id)
   JOIN (s
   WHERE d.dcp_section_ref_id=s.dcp_section_ref_id
    AND s.active_ind=1)
   JOIN (i
   WHERE i.dcp_section_instance_id=s.dcp_section_instance_id)
   JOIN (nvp
   WHERE nvp.parent_entity_id=i.dcp_input_ref_id
    AND nvp.parent_entity_name="DCP_INPUT_REF")
  ORDER BY r.dcp_form_instance_id, d.section_seq, s.dcp_section_instance_id,
   i.input_ref_seq, i.dcp_input_ref_id, nvp.pvc_name,
   nvp.sequence
  HEAD REPORT
   formnum = 0
  HEAD r.dcp_form_instance_id
   formidx = locateval(formnum,1,forms_cnt,r.dcp_form_instance_id,formslist->forms[formnum].
    form_instance_id), formslist->forms[formidx].task_assay_cd = r.task_assay_cd, section_cnt = 0
  HEAD s.dcp_section_ref_id
   section_cnt = (section_cnt+ 1)
   IF (mod(section_cnt,10)=1)
    stat = alterlist(formslist->forms[formidx].sections,(section_cnt+ 9))
   ENDIF
   formslist->forms[formidx].sections[section_cnt].dcp_section_ref_id = d.dcp_section_ref_id,
   formslist->forms[formidx].sections[section_cnt].dcp_section_instance_id = s
   .dcp_section_instance_id, input_cnt = 0
  HEAD i.dcp_input_ref_id
   input_cnt = (input_cnt+ 1)
   IF (mod(input_cnt,10)=1)
    stat = alterlist(formslist->forms[formidx].sections[section_cnt].inputs,(input_cnt+ 9))
   ENDIF
   formslist->forms[formidx].sections[section_cnt].inputs[input_cnt].input_type = i.input_type,
   prop_cnt = 0
  DETAIL
   prop_cnt = (prop_cnt+ 1)
   IF (mod(prop_cnt,10)=1)
    stat = alterlist(formslist->forms[formidx].sections[section_cnt].inputs[input_cnt].properties,(
     prop_cnt+ 9))
   ENDIF
   formslist->forms[formidx].sections[section_cnt].inputs[input_cnt].properties[prop_cnt].pvc_name =
   nvp.pvc_name, formslist->forms[formidx].sections[section_cnt].inputs[input_cnt].properties[
   prop_cnt].pvc_value = nvp.pvc_value, formslist->forms[formidx].sections[section_cnt].inputs[
   input_cnt].properties[prop_cnt].merge_id = nvp.merge_id
  FOOT  i.dcp_input_ref_id
   stat = alterlist(formslist->forms[formidx].sections[section_cnt].inputs[input_cnt].properties,
    prop_cnt)
  FOOT  s.dcp_section_ref_id
   stat = alterlist(formslist->forms[formidx].sections[section_cnt].inputs,input_cnt)
  FOOT  r.dcp_form_instance_id
   stat = alterlist(formslist->forms[formidx].sections,section_cnt)
  WITH nocounter
 ;end select
 SET stat = alterlist(formslist->forms,forms_cnt)
 SET stat = alterlist(formslist->tasks,10)
 FOR (h = 1 TO forms_cnt)
   SET stat = alterlist(dtatemplist->dtas,100)
   SET section_cnt = size(formslist->forms[h].sections,5)
   SET dta_cnt = 0
   FOR (i = 1 TO section_cnt)
    SET input_cnt = size(formslist->forms[h].sections[i].inputs,5)
    FOR (j = 1 TO input_cnt)
      SET prop_cnt = size(formslist->forms[h].sections[i].inputs[j].properties,5)
      SET dta = 0
      FOR (k = 1 TO prop_cnt)
        IF ((formslist->forms[h].sections[i].inputs[j].properties[k].pvc_name="discrete_task_assay2")
         AND (formslist->forms[h].sections[i].inputs[j].input_type=ultra_grid))
         SET dta = formslist->forms[h].sections[i].inputs[j].properties[k].merge_id
         IF (dta > 0)
          SET dta_cnt = (dta_cnt+ 1)
          IF (mod(dta_cnt,100)=1)
           SET stat = alterlist(dtatemplist->dtas,(dta_cnt+ 99))
          ENDIF
          SET dtatemplist->dtas[dta_cnt].task_assay_cd = dta
          SET dta = 0
         ENDIF
        ELSEIF ((formslist->forms[h].sections[i].inputs[j].properties[k].pvc_name=
        "discrete_task_assay"))
         IF ((((formslist->forms[h].sections[i].inputs[j].input_type=power_grid)) OR ((((formslist->
         forms[h].sections[i].inputs[j].input_type=discrete_grid)) OR ((formslist->forms[h].sections[
         i].inputs[j].input_type=ultra_grid))) )) )
          SET dta = formslist->forms[h].sections[i].inputs[j].properties[k].merge_id
          IF (dta > 0)
           SET dta_cnt = (dta_cnt+ 1)
           IF (mod(dta_cnt,100)=1)
            SET stat = alterlist(dtatemplist->dtas,(dta_cnt+ 99))
           ENDIF
           SET dtatemplist->dtas[dta_cnt].task_assay_cd = dta
           SET dta = 0
          ENDIF
         ELSE
          SET dta = formslist->forms[h].sections[i].inputs[j].properties[k].merge_id
         ENDIF
        ELSEIF ((formslist->forms[h].sections[i].inputs[j].properties[k].pvc_name=
        "discrete_task_assay*"))
         IF ((((formslist->forms[h].sections[i].inputs[j].input_type=tracking_control)) OR ((
         formslist->forms[h].sections[i].inputs[j].input_type=carenet_control))) )
          SET dta = formslist->forms[h].sections[i].inputs[j].properties[k].merge_id
          IF (dta > 0)
           SET dta_cnt = (dta_cnt+ 1)
           IF (mod(dta_cnt,100)=1)
            SET stat = alterlist(dtatemplist->dtas,(dta_cnt+ 99))
           ENDIF
           SET dtatemplist->dtas[dta_cnt].task_assay_cd = dta
           SET dta = 0
          ENDIF
         ENDIF
        ELSEIF ((formslist->forms[h].sections[i].inputs[j].properties[k].pvc_name="task_assay_cd"))
         SET dta = cnvtreal(formslist->forms[h].sections[i].inputs[j].properties[k].pvc_value)
        ENDIF
      ENDFOR
      IF (dta > 0)
       SET dta_cnt = (dta_cnt+ 1)
       IF (mod(dta_cnt,100)=1)
        SET stat = alterlist(dtatemplist->dtas,(dta_cnt+ 99))
       ENDIF
       SET dtatemplist->dtas[dta_cnt].task_assay_cd = dta
      ENDIF
    ENDFOR
   ENDFOR
   SET stat = alterlist(dtatemplist->dtas,dta_cnt)
   IF ((formslist->forms[h].dcp_forms_ref_id > 0))
    SELECT INTO "nl:"
     FROM order_task ot
     WHERE (ot.dcp_forms_ref_id=formslist->forms[h].dcp_forms_ref_id)
     DETAIL
      task_cnt = (task_cnt+ 1)
      IF (mod(task_cnt,10)=1)
       stat = alterlist(formslist->tasks,(task_cnt+ 9))
      ENDIF
      formslist->tasks[task_cnt].reference_task_id = ot.reference_task_id, formslist->tasks[task_cnt]
      .description = ot.task_description, formslist->tasks[task_cnt].short_description = ot
      .task_description_key,
      formslist->tasks[task_cnt].form_index = h
     WITH nocounter
    ;end select
   ENDIF
   IF (dta_cnt != 0)
    SET batch_size = 200
    SET expand_start = 1
    SET loop_idx = 0
    SET idx = 0
    SET loop_cnt = ceil((cnvtreal(dta_cnt)/ batch_size))
    SET max_list_size = (batch_size * loop_cnt)
    SET stat = alterlist(dtatemplist->dtas,max_list_size)
    FOR (loopidx = (dta_cnt+ 1) TO max_list_size)
      SET dtatemplist->dtas[loopidx].task_assay_cd = dtatemplist->dtas[dta_cnt].task_assay_cd
    ENDFOR
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(loop_cnt)),
      discrete_task_assay dta
     PLAN (d
      WHERE assign(expand_start,evaluate(d.seq,1,1,(expand_start+ batch_size))))
      JOIN (dta
      WHERE expand(idx,expand_start,((expand_start+ batch_size) - 1),dta.task_assay_cd,dtatemplist->
       dtas[idx].task_assay_cd))
     ORDER BY dta.task_assay_cd
     HEAD REPORT
      item_cnt = 0
     HEAD dta.task_assay_cd
      item_cnt = (item_cnt+ 1)
      IF (mod(item_cnt,10)=1)
       stat = alterlist(formslist->forms[h].dtas,(item_cnt+ 9))
      ENDIF
      formslist->forms[h].dtas[item_cnt].task_assay_cd = dta.task_assay_cd, formslist->forms[h].dtas[
      item_cnt].activity_type_cd = dta.activity_type_cd, formslist->forms[h].dtas[item_cnt].
      description = dta.description,
      formslist->forms[h].dtas[item_cnt].mnemonic = dta.mnemonic
     FOOT REPORT
      stat = alterlist(formslist->forms[h].dtas,item_cnt)
     WITH counter
    ;end select
   ENDIF
 ENDFOR
 SET stat = alterlist(formslist->tasks,task_cnt)
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
  SET stat = alterlist(request->qual,task_cnt)
  FOR (i = 1 TO task_cnt)
    SET fidx = formslist->tasks[i].form_index
    SET taskdta_cnt = size(formslist->forms[fidx].dtas,5)
    SET stat = alterlist(request->qual[i].children,taskdta_cnt)
    SET request->qual[i].action = 1
    SET request->qual[i].ext_id = formslist->tasks[i].reference_task_id
    SET request->qual[i].ext_contributor_cd = taskcat_cd
    SET request->qual[i].parent_qual_ind = 1
    SET request->qual[i].careset_ind = 0
    SET request->qual[i].child_qual = dta_cnt
    SET request->qual[i].ext_owner_cd = task_cd
    SET request->qual[i].ext_description = formslist->tasks[i].description
    SET request->qual[i].ext_short_desc = formslist->tasks[i].short_description
    FOR (j = 1 TO taskdta_cnt)
      SET request->qual[i].children[j].ext_id = formslist->forms[fidx].dtas[j].task_assay_cd
      SET request->qual[i].children[j].ext_contributor_cd = task_assay_cd
      SET request->qual[i].children[j].ext_description = formslist->forms[fidx].dtas[j].description
      SET request->qual[i].children[j].ext_short_desc = formslist->forms[fidx].dtas[j].mnemonic
      SET request->qual[i].children[j].ext_owner_cd = formslist->forms[fidx].dtas[j].activity_type_cd
    ENDFOR
    IF (taskdta_cnt=0)
     SET stat = alterlist(request->qual[i].children,1)
     SET request->qual[i].children[j].ext_id = 0.0
     SET request->qual[i].children[j].ext_contributor_cd = task_assay_cd
    ENDIF
  ENDFOR
  SET request->nbr_of_recs = task_cnt
  EXECUTE afc_add_reference_api  WITH replace("REPLY","AFCREPLY")
 ENDIF
 FREE SET afcreply
END GO
