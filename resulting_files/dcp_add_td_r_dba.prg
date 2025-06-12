CREATE PROGRAM dcp_add_td_r:dba
 RECORD td_list(
   1 nbr_of_recs = i4
   1 qual[*]
     2 reference_task_id = f8
     2 task_description = vc
     2 task_description_key = c50
     2 input_type = i4
     2 dta[*]
       3 task_assay_cd = f8
       3 required_ind = i2
       3 dcp_input_ref_id = f8
       3 sequence = i4
     2 nodupdta[*]
       3 task_assay_cd = f8
       3 required_ind = i2
       3 sequence = i4
     2 ordereddta[*]
       3 task_assay_cd = f8
       3 required_ind = i2
       3 sequence = i4
 )
 IF (validate(readme_data,0))
  SET readme_data->status = "F"
  SET readme_data->message = "Readme failure. Starting dcp_add_td_r script"
 ENDIF
 DECLARE code_set = f8 WITH public, noconstant(0.0)
 DECLARE code_value = f8 WITH public, noconstant(0.0)
 DECLARE cdf_meaning = vc WITH public, noconstant(fillstring(12," "))
 DECLARE taskcat_cd = f8 WITH private, noconstant(0.0)
 DECLARE task_assay_cd = f8 WITH private, noconstant(0.0)
 DECLARE task_cd = f8 WITH private, noconstant(0.0)
 DECLARE junk_ptr = i4 WITH private, noconstant(0)
 DECLARE total_cnt = i4 WITH private, noconstant(0)
 SET total_cnt = 0
 DECLARE var1 = i4 WITH private, noconstant(0)
 DECLARE billtaskcnt = i4 WITH private, noconstant(0)
 DECLARE billdtacnt = i4 WITH private, noconstant(0)
 DECLARE save_dta = f8 WITH protect, noconstant(0.0)
 DECLARE task_cnt = i4 WITH noconstant(0)
 DECLARE tsk_cnt = i4 WITH noconstant(0)
 DECLARE dta_cnt = i4 WITH noconstant(0)
 DECLARE sequence = i4 WITH noconstant(0)
 DECLARE current_dta_required_ind = i2 WITH noconstant(0)
 SET code_set = 13016
 SET cdf_meaning = "TASKCAT"
 EXECUTE cpm_get_cd_for_cdf
 SET taskcat_cd = code_value
 SET code_set = 13016
 SET cdf_meaning = "TASK ASSAY"
 EXECUTE cpm_get_cd_for_cdf
 SET task_assay_cd = code_value
 SET code_set = 106
 SET cdf_meaning = "TASK"
 EXECUTE cpm_get_cd_for_cdf
 SET task_cd = code_value
 DECLARE pos = i4
 DECLARE flag = i4
 DECLARE val = vc
 DECLARE result = i4
 SELECT
  IF (temp_dcp_forms_ref_id > 0)
   PLAN (o
    WHERE o.dcp_forms_ref_id=temp_dcp_forms_ref_id)
    JOIN (dfr
    WHERE dfr.dcp_forms_ref_id=o.dcp_forms_ref_id
     AND dfr.active_ind=1)
    JOIN (d5)
    JOIN (f
    WHERE f.dcp_form_instance_id=dfr.dcp_form_instance_id)
    JOIN (d1)
    JOIN (s
    WHERE s.dcp_section_ref_id=f.dcp_section_ref_id
     AND s.active_ind=1)
    JOIN (d2)
    JOIN (i
    WHERE i.dcp_section_instance_id=s.dcp_section_instance_id)
    JOIN (d3)
    JOIN (n
    WHERE n.parent_entity_name="DCP_INPUT_REF"
     AND n.parent_entity_id=i.dcp_input_ref_id
     AND ((n.pvc_name="task_assay_cd") OR (((n.pvc_name="dta_list") OR (((n.pvc_name="dta_listY") OR
    (((n.pvc_name="discrete_task_assay") OR (((n.pvc_name="discrete_task_assay2") OR (n.pvc_name=
    "required")) )) )) )) )) )
  ELSE
   PLAN (o
    WHERE o.dcp_forms_ref_id > 0)
    JOIN (dfr
    WHERE dfr.dcp_forms_ref_id=o.dcp_forms_ref_id
     AND dfr.active_ind=1)
    JOIN (d5)
    JOIN (f
    WHERE f.dcp_form_instance_id=dfr.dcp_form_instance_id)
    JOIN (d1)
    JOIN (s
    WHERE s.dcp_section_ref_id=f.dcp_section_ref_id
     AND s.active_ind=1)
    JOIN (d2)
    JOIN (i
    WHERE i.dcp_section_instance_id=s.dcp_section_instance_id)
    JOIN (d3)
    JOIN (n
    WHERE n.parent_entity_name="DCP_INPUT_REF"
     AND n.parent_entity_id=i.dcp_input_ref_id
     AND ((n.pvc_name="task_assay_cd") OR (((n.pvc_name="dta_list") OR (((n.pvc_name="dta_listY") OR
    (((n.pvc_name="discrete_task_assay") OR (((n.pvc_name="discrete_task_assay2") OR (n.pvc_name=
    "required")) )) )) )) )) )
  ENDIF
  INTO "nl:"
  o.dcp_forms_ref_id, dfr.dcp_forms_ref_id, f.dcp_forms_ref_id,
  s.dcp_section_ref_id, i.dcp_input_ref_id, i.input_type,
  n.name_value_prefs_id
  FROM order_task o,
   dcp_forms_ref dfr,
   (dummyt d5  WITH seq = 1),
   dcp_forms_def f,
   (dummyt d1  WITH seq = 1),
   dcp_section_ref s,
   (dummyt d2  WITH seq = 1),
   dcp_input_ref i,
   (dummyt d3  WITH seq = 1),
   name_value_prefs n
  ORDER BY o.reference_task_id, f.dcp_forms_ref_id, f.section_seq,
   i.input_ref_seq, i.input_type
  HEAD REPORT
   task_cnt = 0, total_cnt = 0, junk_ptr = 0,
   dta_cnt = 0
  HEAD o.reference_task_id
   task_cnt = (task_cnt+ 1), total_cnt = (total_cnt+ 1)
   IF (total_cnt > size(td_list->qual,5))
    stat = alterlist(td_list->qual,(total_cnt+ 5))
   ENDIF
   td_list->qual[total_cnt].reference_task_id = o.reference_task_id, td_list->qual[total_cnt].
   task_description = o.task_description, td_list->qual[total_cnt].task_description_key = o
   .task_description_key,
   form_cnt = 0, dta_cnt = 0, sequence = 0
  HEAD f.dcp_forms_ref_id
   form_cnt = (form_cnt+ 1), section_cnt = 0
  HEAD s.dcp_section_ref_id
   section_cnt = (section_cnt+ 1), input_cnt = 0
  HEAD i.dcp_input_ref_id
   input_cnt = (input_cnt+ 1), td_list->qual[total_cnt].input_type = i.input_type,
   current_dta_required_ind = 0
  HEAD n.name_value_prefs_id
   IF (n.pvc_name="task_assay_cd")
    dta_cnt = (dta_cnt+ 1)
    IF (dta_cnt > size(td_list->qual[total_cnt].dta,5))
     stat = alterlist(td_list->qual[total_cnt].dta,(dta_cnt+ 1))
    ENDIF
    td_list->qual[total_cnt].dta[dta_cnt].task_assay_cd = cnvtreal(n.pvc_value), td_list->qual[
    total_cnt].dta[dta_cnt].dcp_input_ref_id = n.parent_entity_id, sequence = (sequence+ 1),
    td_list->qual[total_cnt].dta[dta_cnt].sequence = sequence
   ELSEIF (((n.pvc_name="dta_list") OR (n.pvc_name="dta_listY")) )
    tmp_length = 0, tmp_dta_cnt = 0, tmp_count = 0,
    tmp_char = fillstring(1," "), prev_start = 1, current_dta = 0,
    tmp_length = size(n.pvc_value)
    FOR (x = 1 TO tmp_length)
     tmp_char = substring(x,1,n.pvc_value),
     IF (tmp_char=",")
      dta_cnt = (dta_cnt+ 1), current_dta = cnvtreal(substring(prev_start,(x - prev_start),n
        .pvc_value)), prev_start = (x+ 1)
      IF (dta_cnt > size(td_list->qual[total_cnt].dta,5))
       stat = alterlist(td_list->qual[total_cnt].dta,(dta_cnt+ 1))
      ENDIF
      td_list->qual[total_cnt].dta[dta_cnt].task_assay_cd = current_dta, td_list->qual[total_cnt].
      dta[dta_cnt].dcp_input_ref_id = n.parent_entity_id, sequence = (sequence+ 1),
      td_list->qual[total_cnt].dta[dta_cnt].sequence = sequence
     ENDIF
    ENDFOR
   ELSEIF (n.pvc_name="discrete_task_assay")
    dta_cnt = (dta_cnt+ 1)
    IF (dta_cnt > size(td_list->qual[total_cnt].dta,5))
     stat = alterlist(td_list->qual[total_cnt].dta,(dta_cnt+ 1))
    ENDIF
    td_list->qual[total_cnt].dta[dta_cnt].task_assay_cd = n.merge_id, td_list->qual[total_cnt].dta[
    dta_cnt].dcp_input_ref_id = n.parent_entity_id, sequence = (sequence+ 1),
    td_list->qual[total_cnt].dta[dta_cnt].sequence = sequence
    IF ((td_list->qual[total_cnt].input_type=14))
     flag = cnvtint(n.pvc_value), result = band(flag,2)
     IF (result=2)
      td_list->qual[total_cnt].dta[dta_cnt].required_ind = 1
     ELSE
      td_list->qual[total_cnt].dta[dta_cnt].required_ind = 0
     ENDIF
    ELSEIF ((((td_list->qual[total_cnt].input_type=17)) OR ((td_list->qual[total_cnt].input_type=19)
    )) )
     pos = findstring(";",n.pvc_value), val = substring(1,(pos - 1),n.pvc_value), flag = cnvtint(val),
     result = band(flag,1)
     IF (result=1)
      td_list->qual[total_cnt].dta[dta_cnt].required_ind = 1
     ELSE
      td_list->qual[total_cnt].dta[dta_cnt].required_ind = 0
     ENDIF
    ENDIF
   ELSEIF (n.pvc_name="discrete_task_assay2")
    dta_cnt = (dta_cnt+ 1)
    IF (dta_cnt > size(td_list->qual[total_cnt].dta,5))
     stat = alterlist(td_list->qual[total_cnt].dta,(dta_cnt+ 1))
    ENDIF
    td_list->qual[total_cnt].dta[dta_cnt].task_assay_cd = n.merge_id, td_list->qual[total_cnt].dta[
    dta_cnt].dcp_input_ref_id = n.parent_entity_id, sequence = (sequence+ 1),
    td_list->qual[total_cnt].dta[dta_cnt].sequence = sequence
   ELSEIF (n.pvc_name="required"
    AND n.pvc_value="true")
    current_dta_required_ind = 1
   ENDIF
  DETAIL
   junk_ptr = junk_ptr
  FOOT  n.name_value_prefs_id
   junk_ptr = junk_ptr
  FOOT  i.dcp_input_ref_id
   junk_ptr = junk_ptr
   IF (current_dta_required_ind=1)
    td_list->qual[total_cnt].dta[dta_cnt].required_ind = 1
   ENDIF
  FOOT  s.dcp_section_ref_id
   junk_ptr = junk_ptr
  FOOT  f.dcp_forms_ref_id
   junk_ptr = junk_ptr
  FOOT  o.reference_task_id
   stat = alterlist(td_list->qual[task_cnt].dta,dta_cnt)
  FOOT REPORT
   stat = alterlist(td_list->qual,task_cnt)
  WITH nocounter, outerjoin = d1
 ;end select
 SET td_list->nbr_of_recs = task_cnt
 SET tsk_cnt = size(td_list->qual,5)
 IF (tsk_cnt > 0)
  FOR (tsk_idx = 1 TO tsk_cnt)
   SET temp_reference_task_id = td_list->qual[tsk_idx].reference_task_id
   EXECUTE dcp_del_td_r
  ENDFOR
 ENDIF
 SET total_cnt = 0
 IF (tsk_cnt > 0)
  FOR (x = 1 TO tsk_cnt)
    SET nbr_to_get = cnvtint(size(td_list->qual[x].dta,5))
    IF (nbr_to_get > 0)
     SET total_cnt = 0
     SELECT INTO "nl:"
      dta_cd = td_list->qual[x].dta[d1.seq].task_assay_cd, required_ind = td_list->qual[x].dta[d1.seq
      ].required_ind, sequence = td_list->qual[x].dta[d1.seq].sequence
      FROM (dummyt d1  WITH seq = value(nbr_to_get))
      ORDER BY dta_cd
      HEAD REPORT
       save_dta = 0, total_cnt = 0
      DETAIL
       IF (dta_cd != save_dta)
        total_cnt = (total_cnt+ 1)
        IF (total_cnt > size(td_list->qual[x].nodupdta,5))
         stat = alterlist(td_list->qual[x].nodupdta,(total_cnt+ 5))
        ENDIF
        td_list->qual[x].nodupdta[total_cnt].task_assay_cd = dta_cd, td_list->qual[x].nodupdta[
        total_cnt].required_ind = required_ind, td_list->qual[x].nodupdta[total_cnt].sequence =
        td_list->qual[x].dta[d1.seq].sequence
       ENDIF
       save_dta = dta_cd
      FOOT REPORT
       stat = alterlist(td_list->qual[x].nodupdta,total_cnt)
     ;end select
    ENDIF
    SET nbr_to_get = cnvtint(size(td_list->qual[x].nodupdta,5))
    IF (nbr_to_get > 0)
     SELECT INTO "nl:"
      sequence = td_list->qual[x].nodupdta[d1.seq].sequence
      FROM (dummyt d1  WITH seq = value(nbr_to_get))
      ORDER BY td_list->qual[x].nodupdta[d1.seq].sequence
      HEAD REPORT
       total_cnt = 0
      DETAIL
       total_cnt = (total_cnt+ 1)
       IF (total_cnt > size(td_list->qual[x].ordereddta,5))
        stat = alterlist(td_list->qual[x].ordereddta,(total_cnt+ 5))
       ENDIF
       td_list->qual[x].ordereddta[total_cnt].task_assay_cd = td_list->qual[x].nodupdta[d1.seq].
       task_assay_cd, td_list->qual[x].ordereddta[total_cnt].required_ind = td_list->qual[x].
       nodupdta[d1.seq].required_ind, td_list->qual[x].ordereddta[total_cnt].sequence = td_list->
       qual[x].nodupdta[d1.seq].sequence
      FOOT REPORT
       stat = alterlist(td_list->qual[x].ordereddta,total_cnt)
     ;end select
    ENDIF
  ENDFOR
 ENDIF
 SET tsk_cnt = size(td_list->qual,5)
 FOR (x = 1 TO tsk_cnt)
   SET dta_cnt = size(td_list->qual[x].ordereddta,5)
   FOR (y = 1 TO dta_cnt)
     INSERT  FROM task_discrete_r tdr
      SET tdr.reference_task_id = td_list->qual[x].reference_task_id, tdr.task_assay_cd = td_list->
       qual[x].ordereddta[y].task_assay_cd, tdr.sequence = y,
       tdr.active_ind = 1, tdr.required_ind = td_list->qual[x].ordereddta[y].required_ind, tdr
       .updt_dt_tm = cnvtdatetime(curdate,curtime3),
       tdr.updt_id = reqinfo->updt_id, tdr.updt_task = reqinfo->updt_task, tdr.updt_cnt = 0,
       tdr.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
   ENDFOR
   UPDATE  FROM order_task_xref otx
    SET otx.order_task_type_flag = 2
    WHERE (otx.reference_task_id=td_list->qual[x].reference_task_id)
    WITH nocounter
   ;end update
 ENDFOR
 IF (validate(temp_td_list,0))
  SET temp_td_list->nbr_of_recs = td_list->nbr_of_recs
  SET stat = alterlist(temp_td_list->qual,temp_td_list->nbr_of_recs)
  FOR (i = 1 TO temp_td_list->nbr_of_recs)
    SET temp_td_list->qual[i].reference_task_id = td_list->qual[i].reference_task_id
    SET temp_td_list->qual[i].task_description = td_list->qual[i].task_description
    SET temp_td_list->qual[i].task_description_key = td_list->qual[i].task_description_key
    SET temp_td_list->qual[i].input_type = td_list->qual[i].input_type
    SET stat = alterlist(temp_td_list->qual[i].dta,size(td_list->qual[i].ordereddta,5))
    CALL echo(build("size of td_list->qual[",i,"].orderreddta=",size(td_list->qual[i].ordereddta,5)))
    FOR (j = 1 TO size(temp_td_list->qual[i].dta,5))
      SET temp_td_list->qual[i].dta[j].required_ind = td_list->qual[i].ordereddta[j].required_ind
      SET temp_td_list->qual[i].dta[j].sequence = td_list->qual[i].ordereddta[j].sequence
      SET temp_td_list->qual[i].dta[j].task_assay_cd = td_list->qual[i].ordereddta[j].task_assay_cd
    ENDFOR
  ENDFOR
 ENDIF
 FREE RECORD td_list
END GO
