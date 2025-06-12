CREATE PROGRAM dcp_get_exp_interp:dba
 SET task_assay_cd1 =  $1
 SET filename = fillstring(50,"")
 SET taskname = trim(cnvtstring(task_assay_cd1,20,0),3)
 SET filename = concat("dta_",trim(taskname),"_interp.csv")
 SET comp_cnt = 0
 SET state_cnt = 0
 SET qual_cnt = 0
 SET stat = 0
 SET tmp_task_assay_mnemonic = fillstring(60," ")
 SET tmp_task_assay_desc = fillstring(110," ")
 SET tmp_source_string = fillstring(265," ")
 SET dcp_interp_id = fillstring(50," ")
 SET task_assay_cd = fillstring(50," ")
 SET task_assay_mnemonic = fillstring(60," ")
 SET task_assay_desc = fillstring(110," ")
 SET task_act_type_disp = fillstring(50," ")
 SET sex_cd = fillstring(50," ")
 SET sex_cd_meaning = fillstring(50," ")
 SET sex_cd_dk = fillstring(50," ")
 SET sour_cd = fillstring(50," ")
 SET sour_cd_meaning = fillstring(50," ")
 SET sour_cd_dk = fillstring(50," ")
 SET age_from_minutes = fillstring(50," ")
 SET age_to_minutes = fillstring(50," ")
 SET check1 = fillstring(50," ")
 SET dcp_interp_component_id = fillstring(50," ")
 SET component_sequence = fillstring(50," ")
 SET flags = fillstring(50," ")
 SET comp_cd = fillstring(50," ")
 SET comp_cd_mnemonic = fillstring(60," ")
 SET comp_cd_desc = fillstring(110," ")
 SET comp_act_type_disp = fillstring(50," ")
 SET dcp_interp_state_id = fillstring(50," ")
 SET input_cd = fillstring(50," ")
 SET input_cd_mnemonic = fillstring(60," ")
 SET input_cd_desc = fillstring(110," ")
 SET input_act_type_disp = fillstring(50," ")
 SET nomen_source_iden = fillstring(50," ")
 SET nomen_source_cd = fillstring(50," ")
 SET nomen_source_meaning = fillstring(50," ")
 SET nomen_source_dk = fillstring(50," ")
 SET nomen_source_string = fillstring(265," ")
 SET nomen_prin_cd = fillstring(50," ")
 SET nomen_prin_meaning = fillstring(50," ")
 SET nomen_prin_dk = fillstring(50," ")
 SET rnomen_source_iden = fillstring(50," ")
 SET rnomen_source_cd = fillstring(50," ")
 SET rnomen_source_meaning = fillstring(50," ")
 SET rnomen_source_dk = fillstring(50," ")
 SET rnomen_source_string = fillstring(265," ")
 SET rnomen_prin_cd = fillstring(50," ")
 SET rnomen_prin_meaning = fillstring(50," ")
 SET rnomen_prin_dk = fillstring(50," ")
 SET state_flag = fillstring(50," ")
 SET numeric_low = fillstring(50," ")
 SET numeric_high = fillstring(50," ")
 SET state = fillstring(50," ")
 SET resulting_state = fillstring(50," ")
 SET result_value = fillstring(50," ")
 SET line = fillstring(1000," ")
 SELECT INTO value(filename)
  i.dcp_interp_id, dta.task_assay_cd, check = decode(ist.seq,"ist",ic.seq,"ic",i.seq,
   "i","z"),
  ic.dcp_interp_component_id, dta1.task_assay_cd, ist.dcp_interp_state_id,
  dta2.task_assay_cd, n.nomenclature_id, n1.nomenclature_id
  FROM dcp_interp i,
   (dummyt d1  WITH seq = 1),
   discrete_task_assay dta,
   (dummyt d2  WITH seq = 1),
   dcp_interp_component ic,
   (dummyt d3  WITH seq = 1),
   discrete_task_assay dta1,
   (dummyt d4  WITH seq = 1),
   dcp_interp_state ist,
   (dummyt d5  WITH seq = 1),
   discrete_task_assay dta2,
   (dummyt d6  WITH seq = 1),
   nomenclature n,
   (dummyt d7  WITH seq = 1),
   nomenclature n1
  PLAN (i
   WHERE i.task_assay_cd=task_assay_cd1)
   JOIN (d1)
   JOIN (dta
   WHERE dta.task_assay_cd=i.task_assay_cd)
   JOIN (((d2)
   JOIN (ic
   WHERE ic.dcp_interp_id=i.dcp_interp_id)
   JOIN (d3)
   JOIN (dta1
   WHERE dta1.task_assay_cd=ic.component_assay_cd)
   ) ORJOIN ((d4)
   JOIN (ist
   WHERE ist.dcp_interp_id=i.dcp_interp_id)
   JOIN (d5)
   JOIN (dta2
   WHERE dta2.task_assay_cd=ist.input_assay_cd)
   JOIN (d6)
   JOIN (n
   WHERE n.nomenclature_id=ist.nomenclature_id)
   JOIN (d7)
   JOIN (n1
   WHERE n1.nomenclature_id=ist.result_nomenclature_id)
   ))
  ORDER BY dta.task_assay_cd
  HEAD REPORT
   row 0, "DCP_INTERP_ID, TASK_ASSAY_CD, TASK_ASSAY_MNEMONIC, TASK_ASSAY_DESC, TASK_ACT_TYPE_DISP,",
   "SEX_CD, SEX_CD_MEANING, SEX_CD_DK, SOUR_CD, SOUR_CD_MEANING, SOUR_CD_DK, AGE_FROM_MINUTES, AGE_TO_MINUTES,",
   "CHECK, DCP_INTERP_COMPONENT_ID, COMPONENT_SEQUENCE, FLAGS, COMP_CD, COMP_CD_MNEMONIC, COMP_CD_DESC, COMP_ACT_TYPE_DISP,",
   "DCP_INTERP_STATE_ID, INPUT_CD, INPUT_CD_MNEMONIC, INPUT_CD_DESC, INPUT_ACT_TYPE_DISP, NOMEN_SOURCE_IDEN, NOMEN_SOURCE_CD,",
   "NOMEN_SOURCE_MEANING, NOMEN_SOURCE_DK, NOMEN_SOURCE_STRING, NOMEN_PRIN_CD, NOMEN_PRIN_MEANING,",
   "NOMEN_PRIN_DK, RNOMEN_SOURCE_IDEN, RNOMEN_SOURCE_CD, RNOMEN_SOURCE_MEANING, RNOMEN_SOURCE_DK,",
   "RNOMEN_SOURCE_STRING, RNOMEN_PRIN_CD, RNOMEN_PRIN_MEANING, RNOMEN_PRIN_DK, STATE_FLAG, NUMERIC_LOW,",
   "NUMERIC_HIGH, STATE, RESULTING_STATE, RESULT_VALUE"
  DETAIL
   check1 = build(trim(check),",")
   CASE (check)
    OF "ic":
     tmp_task_assay_mnemonic = concat('"',trim(dta.mnemonic),'"'),tmp_task_assay_desc = concat('"',
      trim(dta.description),'"'),dcp_interp_id = build(trim(cnvtstring(i.dcp_interp_id,20,0),3),","),
     task_assay_cd = build(trim(cnvtstring(dta.task_assay_cd,20,0),3),","),task_assay_mnemonic =
     build(trim(tmp_task_assay_mnemonic),","),task_assay_desc = build(trim(tmp_task_assay_desc),","),
     task_act_type_disp = build(cnvtalphanum(cnvtupper(trim(uar_get_code_display(dta.activity_type_cd
          )))),","),sex_cd = build(trim(cnvtstring(i.sex_cd,20,0),3),","),sex_cd_meaning = build(trim
      (uar_get_code_meaning(i.sex_cd)),","),
     sex_cd_dk = build(cnvtalphanum(cnvtupper(trim(uar_get_code_display(i.sex_cd)))),","),sour_cd =
     build(trim(cnvtstring(i.service_resource_cd,20,0),3),","),sour_cd_meaning = build(trim(
       uar_get_code_meaning(i.service_resource_cd)),","),
     sour_cd_dk = build(cnvtalphanum(cnvtupper(trim(uar_get_code_display(i.service_resource_cd)))),
      ","),age_from_minutes = build(cnvtstring(i.age_from_minutes),","),age_to_minutes = build(
      cnvtstring(i.age_to_minutes),","),
     dcp_interp_component_id = build(trim(cnvtstring(ic.dcp_interp_component_id,20,0),3),","),
     component_sequence = build(cnvtstring(ic.component_sequence),","),flags = build(cnvtstring(ic
       .flags),","),
     tmp_task_assay_mnemonic = concat('"',trim(dta1.mnemonic),'"'),tmp_task_assay_desc = concat('"',
      trim(dta1.description),'"'),comp_cd = build(trim(cnvtstring(dta1.task_assay_cd,20,0),3),","),
     comp_cd_mnemonic = build(trim(tmp_task_assay_mnemonic),","),comp_cd_desc = build(trim(
       tmp_task_assay_desc),","),comp_act_type_disp = build(cnvtalphanum(cnvtupper(trim(
         uar_get_code_display(dta1.activity_type_cd)))),","),
     dcp_interp_state_id = build(" ",","),input_cd = build(" ",","),input_cd_mnemonic = build(" ",","
      ),
     input_cd_desc = build(" ",","),input_act_type_disp = build(" ",","),nomen_source_iden = build(
      " ",","),
     nomen_source_cd = build(" ",","),nomen_source_meaning = build(" ",","),nomen_source_dk = build(
      " ",","),
     nomen_source_string = build(" ",","),nomen_prin_cd = build(" ",","),nomen_prin_meaning = build(
      " ",","),
     nomen_prin_dk = build(" ",","),rnomen_source_iden = build(" ",","),rnomen_source_cd = build(" ",
      ","),
     rnomen_source_meaning = build(" ",","),rnomen_source_dk = build(" ",","),rnomen_source_string =
     build(" ",","),
     rnomen_prin_cd = build(" ",","),rnomen_prin_meaning = build(" ",","),rnomen_prin_dk = build(" ",
      ","),
     state_flag = build(" ",","),numeric_low = build(" ",","),numeric_high = build(" ",","),
     state = build(" ",","),resulting_state = build(" ",","),result_value = build(" ",",")
    OF "ist":
     dcp_interp_state_id = build(trim(cnvtstring(ist.dcp_interp_state_id,20,0),3),","),input_cd =
     build(trim(cnvtstring(ist.input_assay_cd,20,0),3),","),tmp_task_assay_mnemonic = concat('"',trim
      (dta2.mnemonic),'"'),
     tmp_task_assay_desc = concat('"',trim(dta2.description),'"'),input_cd_mnemonic = build(trim(
       tmp_task_assay_mnemonic),","),input_cd_desc = build(trim(tmp_task_assay_desc),","),
     input_act_type_disp = build(cnvtalphanum(cnvtupper(trim(uar_get_code_display(dta2
          .activity_type_cd)))),","),nomen_source_iden = build(trim(n.source_identifier),","),
     nomen_source_cd = build(trim(cnvtstring(n.source_vocabulary_cd,20,0),3),","),
     nomen_source_meaning = build(trim(uar_get_code_meaning(n.source_vocabulary_cd)),","),
     nomen_source_dk = build(cnvtalphanum(cnvtupper(trim(uar_get_code_display(n.source_vocabulary_cd)
         ))),","),tmp_source_string = build('"',trim(n.source_string),'"'),
     nomen_source_string = build(trim(tmp_source_string),","),nomen_prin_cd = build(trim(cnvtstring(n
        .principle_type_cd,20,0),3),","),nomen_prin_meaning = build(trim(uar_get_code_meaning(n
        .principle_type_cd)),","),
     nomen_prin_dk = build(cnvtalphanum(cnvtupper(trim(uar_get_code_display(n.principle_type_cd)))),
      ","),rnomen_source_iden = build(trim(n1.source_identifier),","),rnomen_source_cd = build(trim(
       cnvtstring(n1.source_vocabulary_cd,20,0),3),","),
     rnomen_source_meaning = build(trim(uar_get_code_meaning(n1.source_vocabulary_cd)),","),
     rnomen_source_dk = build(cnvtalphanum(cnvtupper(trim(uar_get_code_display(n1
          .source_vocabulary_cd)))),","),tmp_source_string = build('"',trim(n1.source_string),'"'),
     rnomen_source_string = build(trim(tmp_source_string),","),rnomen_prin_cd = build(trim(cnvtstring
       (n1.principle_type_cd,20,0),3),","),rnomen_prin_meaning = build(trim(uar_get_code_meaning(n1
        .principle_type_cd)),","),
     rnomen_prin_dk = build(cnvtalphanum(cnvtupper(trim(uar_get_code_display(n1.principle_type_cd)))),
      ","),state_flag = build(cnvtstring(ist.flags),","),numeric_low = build(cnvtstring(ist
       .numeric_low),","),
     numeric_high = build(cnvtstring(ist.numeric_high),","),state = build(cnvtstring(ist.state),","),
     resulting_state = build(cnvtstring(ist.resulting_state),","),
     result_value = build(trim(cnvtstring(ist.result_value,20,0),3),",")
   ENDCASE
   line = concat(trim(dcp_interp_id),trim(task_assay_cd),trim(task_assay_mnemonic)), line = concat(
    trim(line),trim(task_assay_desc),trim(task_act_type_disp)), line = concat(trim(line),trim(sex_cd),
    trim(sex_cd_meaning),trim(sex_cd_dk)),
   line = concat(trim(line),trim(sour_cd),trim(sour_cd_meaning),trim(sour_cd_dk)), line = concat(trim
    (line),trim(age_from_minutes),trim(age_to_minutes),trim(check1)), line = concat(trim(line),trim(
     dcp_interp_component_id),trim(component_sequence)),
   line = concat(trim(line),trim(flags),trim(comp_cd),trim(comp_cd_mnemonic)), line = concat(trim(
     line),trim(comp_cd_desc)), line = concat(trim(line),trim(comp_act_type_disp),trim(
     dcp_interp_state_id)),
   line = concat(trim(line),trim(input_cd),trim(input_cd_mnemonic)), line = concat(trim(line),trim(
     input_cd_desc)), line = concat(trim(line),trim(input_act_type_disp),trim(nomen_source_iden)),
   line = concat(trim(line),trim(nomen_source_cd),trim(nomen_source_meaning)), line = concat(trim(
     line),trim(nomen_source_dk),trim(nomen_source_string),trim(nomen_prin_cd)), line = concat(trim(
     line),trim(nomen_prin_meaning),trim(nomen_prin_dk)),
   line = concat(trim(line),trim(rnomen_source_iden)), line = concat(trim(line),trim(rnomen_source_cd
     ),trim(rnomen_source_meaning)), line = concat(trim(line),trim(rnomen_source_dk),trim(
     rnomen_source_string),trim(rnomen_prin_cd)),
   line = concat(trim(line),trim(rnomen_prin_meaning),trim(rnomen_prin_dk)), line = concat(trim(line),
    trim(state_flag),trim(numeric_low)), line = concat(trim(line),trim(numeric_high),trim(state)),
   line = concat(trim(line),trim(resulting_state),trim(result_value)), row + 1, line
  WITH maxcol = 1100, maxrow = 3000, nocounter,
   nullreport, outerjoin = d1, outerjoin = d2,
   outerjoin = d3, outerjoin = d4, outerjoin = d5,
   outerjoin = d5, outerjoin = d6, outerjoin = d7
 ;end select
 SET reqinfo->commit_ind = 1
END GO
