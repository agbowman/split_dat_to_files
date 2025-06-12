CREATE PROGRAM dcp_calculator_import:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RECORD internal(
   1 positions[*]
     2 position_cd = f8
   1 units[*]
     2 unit_measure_cd = f8
     2 unit_measure_meaning = c12
   1 equations[*]
     2 dcp_equation_id = f8
     2 number_components = i2
     2 components[*]
       3 dcp_component_id = f8
       3 number_units = i2
       3 units[*]
         4 unit_measure_cd = f8
         4 unit_measure_meaning = c12
 )
 SET pos_cnt = 0
 SET uom_cnt = 0
 SET equa_cnt = 0
 SET comp_cnt = 0
 SET unit_cnt = 0
 SET exist_pos_cnt = 0
 SET exist_equa_cnt = 0
 SET new_equa_cnt = 0
 DECLARE temp_unit_cd = f8 WITH protect, noconstant(0.0)
 SET temp_unit_meaning = fillstring(12," ")
 DECLARE new_equa_id = f8 WITH protect, noconstant(0.0)
 DECLARE new_comp_id = f8 WITH protect, noconstant(0.0)
 SET mcgcc_cdf_ind = 0
 SET mgcc_cdf_ind = 0
 SET mcgcc_val_ind = 0
 SET mgcc_val_ind = 0
 SET mcgkgmin_cdf_ind = 0
 SET mcgkgmin_val_ind = 0
 SELECT INTO "nl:"
  c.cdf_meaning
  FROM common_data_foundation c
  WHERE c.cdf_meaning="MG/CC"
  DETAIL
   mgcc_cdf_ind = 1
  WITH nocounter
 ;end select
 IF (mgcc_cdf_ind=0)
  INSERT  FROM common_data_foundation c
   SET c.code_set = 54, c.cdf_meaning = "MG/CC", c.display = "MG/CC",
    c.definition = "milligram/cubic centimeter", c.updt_applctx = 0, c.updt_id = 0,
    c.updt_cnt = 0, c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_task = 0
   WITH nocounter
  ;end insert
 ENDIF
 SELECT INTO "nl:"
  c.cdf_meaning
  FROM common_data_foundation c
  WHERE c.cdf_meaning="MCG/CC"
  DETAIL
   mcgcc_cdf_ind = 1
  WITH nocounter
 ;end select
 IF (mcgcc_cdf_ind=0)
  INSERT  FROM common_data_foundation c
   SET c.code_set = 54, c.cdf_meaning = "MCG/CC", c.display = "MCG/CC",
    c.definition = "microgram/cubic centimeter", c.updt_applctx = 0, c.updt_id = 0,
    c.updt_cnt = 0, c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_task = 0
   WITH nocounter
  ;end insert
 ENDIF
 SELECT INTO "nl:"
  c.cdf_meaning
  FROM common_data_foundation c
  WHERE c.cdf_meaning="MCG/KG/MIN"
  DETAIL
   mcgkgmin_cdf_ind = 1
  WITH nocounter
 ;end select
 IF (mcgkgmin_cdf_ind=0)
  INSERT  FROM common_data_foundation c
   SET c.code_set = 54, c.cdf_meaning = "MCG/KG/MIN", c.display = "MCG/KG/MIN",
    c.definition = "micrograms/kilogram/minute", c.updt_applctx = 0, c.updt_id = 0,
    c.updt_cnt = 0, c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_task = 0
   WITH nocounter
  ;end insert
 ENDIF
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=54
   AND c.cdf_meaning="MCG/CC"
  DETAIL
   mcgcc_val_ind = 1
  WITH nocounter
 ;end select
 IF (mcgcc_val_ind=0)
  INSERT  FROM code_value c
   SET c.code_value = seq(reference_seq,nextval), c.code_set = 54, c.cdf_meaning = "MCG/CC",
    c.display = "mcg/cc", c.display_key = "MCGCC", c.description = "mcg/cc",
    c.definition = "mcg/cc", c.collation_seq = 0, c.active_type_cd = reqdata->active_status_cd,
    c.active_ind = 1, c.active_dt_tm = cnvtdatetime(curdate,curtime3), c.data_status_cd = reqdata->
    data_status_cd,
    c.data_status_dt_tm = cnvtdatetime(curdate,curtime), c.data_status_prsnl_id = 0, c.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    c.updt_id = 0, c.updt_cnt = 0, c.updt_applctx = 0,
    c.updt_task = 0
   WITH nocounter
  ;end insert
 ENDIF
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=54
   AND c.cdf_meaning="MG/CC"
  DETAIL
   mgcc_val_ind = 1
  WITH nocounter
 ;end select
 IF (mgcc_val_ind=0)
  INSERT  FROM code_value c
   SET c.code_value = seq(reference_seq,nextval), c.code_set = 54, c.cdf_meaning = "MG/CC",
    c.display = "mg/cc", c.display_key = "MGCC", c.description = "mg/cc",
    c.definition = "mg/cc", c.collation_seq = 0, c.active_type_cd = reqdata->active_status_cd,
    c.active_ind = 1, c.active_dt_tm = cnvtdatetime(curdate,curtime3), c.data_status_cd = reqdata->
    data_status_cd,
    c.data_status_dt_tm = cnvtdatetime(curdate,curtime), c.data_status_prsnl_id = 0, c.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    c.updt_id = 0, c.updt_cnt = 0, c.updt_applctx = 0,
    c.updt_task = 0
   WITH nocounter
  ;end insert
 ENDIF
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=54
   AND c.cdf_meaning="MCG/KG/MIN"
  DETAIL
   mcgkgmin_val_ind = 1
  WITH nocounter
 ;end select
 IF (mcgkgmin_val_ind=0)
  INSERT  FROM code_value c
   SET c.code_value = seq(reference_seq,nextval), c.code_set = 54, c.cdf_meaning = "MCG/KG/MIN",
    c.display = "mcg/kg/min", c.display_key = "mcg/kg/min", c.description = "mcg/kg/min",
    c.definition = "mcg/kg/min", c.collation_seq = 0, c.active_type_cd = reqdata->active_status_cd,
    c.active_ind = 1, c.active_dt_tm = cnvtdatetime(curdate,curtime3), c.data_status_cd = reqdata->
    data_status_cd,
    c.data_status_dt_tm = cnvtdatetime(curdate,curtime), c.data_status_prsnl_id = 0, c.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    c.updt_id = 0, c.updt_cnt = 0, c.updt_applctx = 0,
    c.updt_task = 0
   WITH nocounter
  ;end insert
 ENDIF
 SELECT INTO "nl:"
  d.dcp_equation_id
  FROM dcp_equation d
  WHERE d.dcp_equation_id > 0.0
  DETAIL
   exist_equa_cnt = (exist_equa_cnt+ 1)
  WITH nocounter
 ;end select
 IF (exist_equa_cnt > 0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  p.dcp_equation_id
  FROM dcp_equa_position p
  WHERE p.dcp_equation_id > 0.0
  DETAIL
   exist_pos_cnt = (exist_pos_cnt+ 1)
  WITH nocounter
 ;end select
 IF (exist_pos_cnt > 0)
  GO TO exit_script
 ENDIF
 RECORD calc_data(
   1 qual[29]
     2 description = vc
     2 description_key = vc
     2 begin_age_nbr = f8
     2 begin_age_flag = i2
     2 end_age_nbr = f8
     2 end_age_flag = i2
     2 gender_cd = f8
     2 equation_display = vc
     2 equation_meaning = c12
     2 equation_code = vc
     2 active_ind = i2
     2 calcvalue_description = vc
     2 number_components = i2
     2 components[8]
       3 component_flag = i2
       3 constant_value = f8
       3 component_label = c50
       3 component_description = c50
       3 event_cd = f8
       3 required_ind = i2
       3 corresponding_equation_id = f8
       3 component_code = c5
       3 duplicate_component_name = c50
       3 number_units = i2
       3 unit_measure[3]
         4 unit_measure_cd = f8
         4 unit_measure_meaning = c12
         4 default_ind = i2
         4 equation_dependent_unit_ind = i2
 )
 SET calc_data->qual[1].description = "Cardiac Index"
 SET calc_data->qual[1].description_key = cnvtupper(calc_data->qual[1].description)
 SET calc_data->qual[1].begin_age_nbr = 0
 SET calc_data->qual[1].begin_age_flag = 0
 SET calc_data->qual[1].end_age_nbr = 0
 SET calc_data->qual[1].end_age_flag = 0
 SET calc_data->qual[1].gender_cd = 0.0
 SET calc_data->qual[1].equation_display = "CO/BSA"
 SET calc_data->qual[1].equation_meaning = ""
 SET calc_data->qual[1].equation_code = "A/B"
 SET calc_data->qual[1].active_ind = 1
 SET calc_data->qual[1].calcvalue_description = "Cardiac Index"
 SET calc_data->qual[1].number_components = 2
 SET calc_data->qual[1].components[1].component_flag = 1
 SET calc_data->qual[1].components[1].constant_value = 0.0
 SET calc_data->qual[1].components[1].component_label = "Cardiac Output"
 SET calc_data->qual[1].components[1].component_description = "CO"
 SET calc_data->qual[1].components[1].event_cd = 0.0
 SET calc_data->qual[1].components[1].required_ind = 1
 SET calc_data->qual[1].components[1].corresponding_equation_id = 0.0
 SET calc_data->qual[1].components[1].component_code = "A"
 SET calc_data->qual[1].components[1].duplicate_component_name = ""
 SET calc_data->qual[1].components[1].number_units = 0
 SET calc_data->qual[1].components[2].component_flag = 1
 SET calc_data->qual[1].components[2].constant_value = 0.0
 SET calc_data->qual[1].components[2].component_label = "BSA"
 SET calc_data->qual[1].components[2].component_description = "BSA"
 SET calc_data->qual[1].components[2].event_cd = 0.0
 SET calc_data->qual[1].components[2].required_ind = 1
 SET calc_data->qual[1].components[2].corresponding_equation_id = 0.0
 SET calc_data->qual[1].components[2].component_code = "B"
 SET calc_data->qual[1].components[2].duplicate_component_name = ""
 SET calc_data->qual[1].components[2].number_units = 0
 SET calc_data->qual[2].description = "Cardiac Output"
 SET calc_data->qual[2].description_key = cnvtupper(calc_data->qual[2].description)
 SET calc_data->qual[2].begin_age_nbr = 0
 SET calc_data->qual[2].begin_age_flag = 0
 SET calc_data->qual[2].end_age_nbr = 0
 SET calc_data->qual[2].end_age_flag = 0
 SET calc_data->qual[2].gender_cd = 0.0
 SET calc_data->qual[2].equation_display = "Heart Rate * SV"
 SET calc_data->qual[2].equation_meaning = ""
 SET calc_data->qual[2].equation_code = "A*B"
 SET calc_data->qual[2].active_ind = 1
 SET calc_data->qual[2].calcvalue_description = "Cardiac Output"
 SET calc_data->qual[2].number_components = 2
 SET calc_data->qual[2].components[1].component_flag = 1
 SET calc_data->qual[2].components[1].constant_value = 0.0
 SET calc_data->qual[2].components[1].component_label = "Heart Rate"
 SET calc_data->qual[2].components[1].component_description = "Heart Rate"
 SET calc_data->qual[2].components[1].event_cd = 0.0
 SET calc_data->qual[2].components[1].required_ind = 1
 SET calc_data->qual[2].components[1].corresponding_equation_id = 0.0
 SET calc_data->qual[2].components[1].component_code = "A"
 SET calc_data->qual[2].components[1].duplicate_component_name = ""
 SET calc_data->qual[2].components[1].number_units = 0
 SET calc_data->qual[2].components[2].component_flag = 1
 SET calc_data->qual[2].components[2].constant_value = 0.0
 SET calc_data->qual[2].components[2].component_label = "Stroke Volume"
 SET calc_data->qual[2].components[2].component_description = "Stroke Volume"
 SET calc_data->qual[2].components[2].event_cd = 0.0
 SET calc_data->qual[2].components[2].required_ind = 1
 SET calc_data->qual[2].components[2].corresponding_equation_id = 0.0
 SET calc_data->qual[2].components[2].component_code = "B"
 SET calc_data->qual[2].components[2].duplicate_component_name = ""
 SET calc_data->qual[2].components[2].number_units = 0
 SET calc_data->qual[3].description = "CCs per Hour"
 SET calc_data->qual[3].description_key = cnvtupper(calc_data->qual[3].description)
 SET calc_data->qual[3].begin_age_nbr = 0
 SET calc_data->qual[3].begin_age_flag = 0
 SET calc_data->qual[3].end_age_nbr = 0
 SET calc_data->qual[3].end_age_flag = 0
 SET calc_data->qual[3].gender_cd = 0.0
 SET calc_data->qual[3].equation_display = "(mcg desired * weight * 60)/(concentration of drip)"
 SET calc_data->qual[3].equation_meaning = ""
 SET calc_data->qual[3].equation_code = "(A*B*C)/(D)"
 SET calc_data->qual[3].active_ind = 1
 SET calc_data->qual[3].calcvalue_description = "cc/hr"
 SET calc_data->qual[3].number_components = 4
 SET calc_data->qual[3].components[1].component_flag = 1
 SET calc_data->qual[3].components[1].constant_value = 0.0
 SET calc_data->qual[3].components[1].component_label = "mcg/kg/min desired"
 SET calc_data->qual[3].components[1].component_description = "mcg desired"
 SET calc_data->qual[3].components[1].event_cd = 0.0
 SET calc_data->qual[3].components[1].required_ind = 1
 SET calc_data->qual[3].components[1].corresponding_equation_id = 0.0
 SET calc_data->qual[3].components[1].component_code = "A"
 SET calc_data->qual[3].components[1].duplicate_component_name = ""
 SET calc_data->qual[3].components[1].number_units = 0
 SET calc_data->qual[3].components[2].component_flag = 1
 SET calc_data->qual[3].components[2].constant_value = 0.0
 SET calc_data->qual[3].components[2].component_label = "Patient Weight"
 SET calc_data->qual[3].components[2].component_description = "weight"
 SET calc_data->qual[3].components[2].event_cd = 0.0
 SET calc_data->qual[3].components[2].required_ind = 1
 SET calc_data->qual[3].components[2].corresponding_equation_id = 0.0
 SET calc_data->qual[3].components[2].component_code = "B"
 SET calc_data->qual[3].components[2].duplicate_component_name = ""
 SET calc_data->qual[3].components[2].number_units = 3
 SET calc_data->qual[3].components[2].unit_measure[1].unit_measure_meaning = "LB"
 SET calc_data->qual[3].components[2].unit_measure[1].default_ind = 1
 SET calc_data->qual[3].components[2].unit_measure[1].equation_dependent_unit_ind = 0
 SET calc_data->qual[3].components[2].unit_measure[2].unit_measure_meaning = "KG"
 SET calc_data->qual[3].components[2].unit_measure[2].default_ind = 0
 SET calc_data->qual[3].components[2].unit_measure[2].equation_dependent_unit_ind = 1
 SET calc_data->qual[3].components[2].unit_measure[3].unit_measure_meaning = "GM"
 SET calc_data->qual[3].components[2].unit_measure[3].default_ind = 0
 SET calc_data->qual[3].components[2].unit_measure[3].equation_dependent_unit_ind = 0
 SET calc_data->qual[3].components[3].component_flag = 2
 SET calc_data->qual[3].components[3].constant_value = 60.0
 SET calc_data->qual[3].components[3].component_label = "(No Label)"
 SET calc_data->qual[3].components[3].component_description = "60"
 SET calc_data->qual[3].components[3].event_cd = 0.0
 SET calc_data->qual[3].components[3].required_ind = 1
 SET calc_data->qual[3].components[3].corresponding_equation_id = 0.0
 SET calc_data->qual[3].components[3].component_code = "C"
 SET calc_data->qual[3].components[3].duplicate_component_name = ""
 SET calc_data->qual[3].components[3].number_units = 0
 SET calc_data->qual[3].components[4].component_flag = 4
 SET calc_data->qual[3].components[4].constant_value = 0.0
 SET calc_data->qual[3].components[4].component_label = "concentration of drip"
 SET calc_data->qual[3].components[4].component_description = "concentration of drip"
 SET calc_data->qual[3].components[4].event_cd = 0.0
 SET calc_data->qual[3].components[4].required_ind = 1
 SET calc_data->qual[3].components[4].corresponding_equation_id = 0.0
 SET calc_data->qual[3].components[4].component_code = "D"
 SET calc_data->qual[3].components[4].duplicate_component_name = ""
 SET calc_data->qual[3].components[4].number_units = 2
 SET calc_data->qual[3].components[4].unit_measure[1].unit_measure_meaning = "MG/CC"
 SET calc_data->qual[3].components[4].unit_measure[1].default_ind = 0
 SET calc_data->qual[3].components[4].unit_measure[1].equation_dependent_unit_ind = 0
 SET calc_data->qual[3].components[4].unit_measure[2].unit_measure_meaning = "MCG/CC"
 SET calc_data->qual[3].components[4].unit_measure[2].default_ind = 1
 SET calc_data->qual[3].components[4].unit_measure[2].equation_dependent_unit_ind = 1
 SET calc_data->qual[4].description = "Estimated Creatinine Clearance - Women"
 SET calc_data->qual[4].description_key = cnvtupper(calc_data->qual[4].description)
 SET calc_data->qual[4].begin_age_nbr = 0
 SET calc_data->qual[4].begin_age_flag = 0
 SET calc_data->qual[4].end_age_nbr = 0
 SET calc_data->qual[4].end_age_flag = 0
 SET calc_data->qual[4].gender_cd = 0.0
 SET calc_data->qual[4].equation_display = "(((140 - age) * (weight))/(72 * serum Cr)) * .85"
 SET calc_data->qual[4].equation_meaning = ""
 SET calc_data->qual[4].equation_code = "(((A-B)*(C))/(D*E))*F"
 SET calc_data->qual[4].active_ind = 1
 SET calc_data->qual[4].calcvalue_description = "Estimated Creatinine Clearance (in kg)"
 SET calc_data->qual[4].number_components = 6
 SET calc_data->qual[4].components[1].component_flag = 2
 SET calc_data->qual[4].components[1].constant_value = 140
 SET calc_data->qual[4].components[1].component_label = "(No label)"
 SET calc_data->qual[4].components[1].component_description = "140"
 SET calc_data->qual[4].components[1].event_cd = 0.0
 SET calc_data->qual[4].components[1].required_ind = 1
 SET calc_data->qual[4].components[1].corresponding_equation_id = 0.0
 SET calc_data->qual[4].components[1].component_code = "A"
 SET calc_data->qual[4].components[1].duplicate_component_name = ""
 SET calc_data->qual[4].components[1].number_units = 0
 SET calc_data->qual[4].components[2].component_flag = 1
 SET calc_data->qual[4].components[2].constant_value = 0
 SET calc_data->qual[4].components[2].component_label = "Patient Age"
 SET calc_data->qual[4].components[2].component_description = "age"
 SET calc_data->qual[4].components[2].event_cd = 0.0
 SET calc_data->qual[4].components[2].required_ind = 1
 SET calc_data->qual[4].components[2].corresponding_equation_id = 0.0
 SET calc_data->qual[4].components[2].component_code = "B"
 SET calc_data->qual[4].components[2].duplicate_component_name = ""
 SET calc_data->qual[4].components[2].number_units = 0
 SET calc_data->qual[4].components[3].component_flag = 1
 SET calc_data->qual[4].components[3].constant_value = 0
 SET calc_data->qual[4].components[3].component_label = "Patient Weight"
 SET calc_data->qual[4].components[3].component_description = "weight"
 SET calc_data->qual[4].components[3].event_cd = 0.0
 SET calc_data->qual[4].components[3].required_ind = 1
 SET calc_data->qual[4].components[3].corresponding_equation_id = 0.0
 SET calc_data->qual[4].components[3].component_code = "C"
 SET calc_data->qual[4].components[3].duplicate_component_name = ""
 SET calc_data->qual[4].components[3].number_units = 3
 SET calc_data->qual[4].components[3].unit_measure[1].unit_measure_meaning = "LB"
 SET calc_data->qual[4].components[3].unit_measure[1].default_ind = 1
 SET calc_data->qual[4].components[3].unit_measure[1].equation_dependent_unit_ind = 0
 SET calc_data->qual[4].components[3].unit_measure[2].unit_measure_meaning = "KG"
 SET calc_data->qual[4].components[3].unit_measure[2].default_ind = 0
 SET calc_data->qual[4].components[3].unit_measure[2].equation_dependent_unit_ind = 1
 SET calc_data->qual[4].components[3].unit_measure[3].unit_measure_meaning = "GM"
 SET calc_data->qual[4].components[3].unit_measure[3].default_ind = 0
 SET calc_data->qual[4].components[3].unit_measure[3].equation_dependent_unit_ind = 0
 SET calc_data->qual[4].components[4].component_flag = 2
 SET calc_data->qual[4].components[4].constant_value = 72
 SET calc_data->qual[4].components[4].component_label = "(No Label)"
 SET calc_data->qual[4].components[4].component_description = "72"
 SET calc_data->qual[4].components[4].event_cd = 0.0
 SET calc_data->qual[4].components[4].required_ind = 1
 SET calc_data->qual[4].components[4].corresponding_equation_id = 0.0
 SET calc_data->qual[4].components[4].component_code = "D"
 SET calc_data->qual[4].components[4].duplicate_component_name = ""
 SET calc_data->qual[4].components[4].number_units = 0
 SET calc_data->qual[4].components[5].component_flag = 1
 SET calc_data->qual[4].components[5].constant_value = 0
 SET calc_data->qual[4].components[5].component_label = "Serum Cr"
 SET calc_data->qual[4].components[5].component_description = "serum Cr"
 SET calc_data->qual[4].components[5].event_cd = 0.0
 SET calc_data->qual[4].components[5].required_ind = 1
 SET calc_data->qual[4].components[5].corresponding_equation_id = 0.0
 SET calc_data->qual[4].components[5].component_code = "E"
 SET calc_data->qual[4].components[5].duplicate_component_name = ""
 SET calc_data->qual[4].components[5].number_units = 0
 SET calc_data->qual[4].components[6].component_flag = 2
 SET calc_data->qual[4].components[6].constant_value = 0.85
 SET calc_data->qual[4].components[6].component_label = "(No Label)"
 SET calc_data->qual[4].components[6].component_description = ".85"
 SET calc_data->qual[4].components[6].event_cd = 0.0
 SET calc_data->qual[4].components[6].required_ind = 1
 SET calc_data->qual[4].components[6].corresponding_equation_id = 0.0
 SET calc_data->qual[4].components[6].component_code = "F"
 SET calc_data->qual[4].components[6].duplicate_component_name = ""
 SET calc_data->qual[4].components[6].number_units = 0
 SET calc_data->qual[5].description = "Estimated Creatinine Clearance  - Children < 17"
 SET calc_data->qual[5].description_key = cnvtupper(calc_data->qual[5].description)
 SET calc_data->qual[5].begin_age_nbr = 0
 SET calc_data->qual[5].begin_age_flag = 0
 SET calc_data->qual[5].end_age_nbr = 0
 SET calc_data->qual[5].end_age_flag = 0
 SET calc_data->qual[5].gender_cd = 0.0
 SET calc_data->qual[5].equation_display = "(.48 * Height * BSA)/(Serum Cr * 1.73)"
 SET calc_data->qual[5].equation_meaning = ""
 SET calc_data->qual[5].equation_code = "(A*B*C)/(D*E)"
 SET calc_data->qual[5].active_ind = 1
 SET calc_data->qual[5].calcvalue_description = "EST  CC - Children (in kg)"
 SET calc_data->qual[5].number_components = 5
 SET calc_data->qual[5].components[1].component_flag = 2
 SET calc_data->qual[5].components[1].constant_value = 0.48
 SET calc_data->qual[5].components[1].component_label = "(No Label)"
 SET calc_data->qual[5].components[1].component_description = ".48"
 SET calc_data->qual[5].components[1].event_cd = 0.0
 SET calc_data->qual[5].components[1].required_ind = 1
 SET calc_data->qual[5].components[1].corresponding_equation_id = 0.0
 SET calc_data->qual[5].components[1].component_code = "A"
 SET calc_data->qual[5].components[1].duplicate_component_name = ""
 SET calc_data->qual[5].components[1].number_units = 0
 SET calc_data->qual[5].components[2].component_flag = 1
 SET calc_data->qual[5].components[2].constant_value = 0
 SET calc_data->qual[5].components[2].component_label = "Patient Height"
 SET calc_data->qual[5].components[2].component_description = "Height"
 SET calc_data->qual[5].components[2].event_cd = 0.0
 SET calc_data->qual[5].components[2].required_ind = 1
 SET calc_data->qual[5].components[2].corresponding_equation_id = 0.0
 SET calc_data->qual[5].components[2].component_code = "B"
 SET calc_data->qual[5].components[2].duplicate_component_name = ""
 SET calc_data->qual[5].components[2].number_units = 2
 SET calc_data->qual[5].components[2].unit_measure[1].unit_measure_meaning = "INCHES"
 SET calc_data->qual[5].components[2].unit_measure[1].default_ind = 1
 SET calc_data->qual[5].components[2].unit_measure[1].equation_dependent_unit_ind = 0
 SET calc_data->qual[5].components[2].unit_measure[2].unit_measure_meaning = "CM"
 SET calc_data->qual[5].components[2].unit_measure[2].default_ind = 0
 SET calc_data->qual[5].components[2].unit_measure[2].equation_dependent_unit_ind = 1
 SET calc_data->qual[5].components[3].component_flag = 1
 SET calc_data->qual[5].components[3].constant_value = 0
 SET calc_data->qual[5].components[3].component_label = "BSA"
 SET calc_data->qual[5].components[3].component_description = "BSA"
 SET calc_data->qual[5].components[3].event_cd = 0.0
 SET calc_data->qual[5].components[3].required_ind = 1
 SET calc_data->qual[5].components[3].corresponding_equation_id = 0.0
 SET calc_data->qual[5].components[3].component_code = "C"
 SET calc_data->qual[5].components[3].duplicate_component_name = ""
 SET calc_data->qual[5].components[3].number_units = 0
 SET calc_data->qual[5].components[4].component_flag = 1
 SET calc_data->qual[5].components[4].constant_value = 0
 SET calc_data->qual[5].components[4].component_label = "Serum Cr"
 SET calc_data->qual[5].components[4].component_description = "Serum Cr"
 SET calc_data->qual[5].components[4].event_cd = 0.0
 SET calc_data->qual[5].components[4].required_ind = 1
 SET calc_data->qual[5].components[4].corresponding_equation_id = 0.0
 SET calc_data->qual[5].components[4].component_code = "D"
 SET calc_data->qual[5].components[4].duplicate_component_name = ""
 SET calc_data->qual[5].components[4].number_units = 0
 SET calc_data->qual[5].components[5].component_flag = 2
 SET calc_data->qual[5].components[5].constant_value = 1.73
 SET calc_data->qual[5].components[5].component_label = "(No Label)"
 SET calc_data->qual[5].components[5].component_description = "1.73"
 SET calc_data->qual[5].components[5].event_cd = 0.0
 SET calc_data->qual[5].components[5].required_ind = 1
 SET calc_data->qual[5].components[5].corresponding_equation_id = 0.0
 SET calc_data->qual[5].components[5].component_code = "E"
 SET calc_data->qual[5].components[5].duplicate_component_name = ""
 SET calc_data->qual[5].components[5].number_units = 0
 SET calc_data->qual[6].description = "Fahrenheit to Celsius"
 SET calc_data->qual[6].description_key = cnvtupper(calc_data->qual[6].description)
 SET calc_data->qual[6].begin_age_nbr = 0
 SET calc_data->qual[6].begin_age_flag = 0
 SET calc_data->qual[6].end_age_nbr = 0
 SET calc_data->qual[6].end_age_flag = 0
 SET calc_data->qual[6].gender_cd = 0.0
 SET calc_data->qual[6].equation_display = "(F - 32) * (5/9)"
 SET calc_data->qual[6].equation_meaning = ""
 SET calc_data->qual[6].equation_code = "(A-B)*(C/D)"
 SET calc_data->qual[6].active_ind = 1
 SET calc_data->qual[6].calcvalue_description = "Degrees Celsius"
 SET calc_data->qual[6].number_components = 4
 SET calc_data->qual[6].components[1].component_flag = 1
 SET calc_data->qual[6].components[1].constant_value = 0
 SET calc_data->qual[6].components[1].component_label = "Degrees Fahrenheit"
 SET calc_data->qual[6].components[1].component_description = "F"
 SET calc_data->qual[6].components[1].event_cd = 0.0
 SET calc_data->qual[6].components[1].required_ind = 1
 SET calc_data->qual[6].components[1].corresponding_equation_id = 0.0
 SET calc_data->qual[6].components[1].component_code = "A"
 SET calc_data->qual[6].components[1].duplicate_component_name = ""
 SET calc_data->qual[6].components[1].number_units = 0
 SET calc_data->qual[6].components[2].component_flag = 2
 SET calc_data->qual[6].components[2].constant_value = 32
 SET calc_data->qual[6].components[2].component_label = "(No Label)"
 SET calc_data->qual[6].components[2].component_description = "32"
 SET calc_data->qual[6].components[2].event_cd = 0.0
 SET calc_data->qual[6].components[2].required_ind = 1
 SET calc_data->qual[6].components[2].corresponding_equation_id = 0.0
 SET calc_data->qual[6].components[2].component_code = "B"
 SET calc_data->qual[6].components[2].duplicate_component_name = ""
 SET calc_data->qual[6].components[2].number_units = 0
 SET calc_data->qual[6].components[3].component_flag = 2
 SET calc_data->qual[6].components[3].constant_value = 5
 SET calc_data->qual[6].components[3].component_label = "(No Label)"
 SET calc_data->qual[6].components[3].component_description = "5"
 SET calc_data->qual[6].components[3].event_cd = 0.0
 SET calc_data->qual[6].components[3].required_ind = 1
 SET calc_data->qual[6].components[3].corresponding_equation_id = 0.0
 SET calc_data->qual[6].components[3].component_code = "C"
 SET calc_data->qual[6].components[3].duplicate_component_name = ""
 SET calc_data->qual[6].components[3].number_units = 0
 SET calc_data->qual[6].components[4].component_flag = 2
 SET calc_data->qual[6].components[4].constant_value = 9
 SET calc_data->qual[6].components[4].component_label = "(No Label)"
 SET calc_data->qual[6].components[4].component_description = "9"
 SET calc_data->qual[6].components[4].event_cd = 0.0
 SET calc_data->qual[6].components[4].required_ind = 1
 SET calc_data->qual[6].components[4].corresponding_equation_id = 0.0
 SET calc_data->qual[6].components[4].component_code = "D"
 SET calc_data->qual[6].components[4].duplicate_component_name = ""
 SET calc_data->qual[6].components[4].number_units = 0
 SET calc_data->qual[7].description = "Ideal Body Weight - Children < 60 inches"
 SET calc_data->qual[7].description_key = cnvtupper(calc_data->qual[7].description)
 SET calc_data->qual[7].begin_age_nbr = 0
 SET calc_data->qual[7].begin_age_flag = 0
 SET calc_data->qual[7].end_age_nbr = 0
 SET calc_data->qual[7].end_age_flag = 0
 SET calc_data->qual[7].gender_cd = 0.0
 SET calc_data->qual[7].equation_display = "((height^2) * 1.65)/1000"
 SET calc_data->qual[7].equation_meaning = ""
 SET calc_data->qual[7].equation_code = "((A^B)*C)/D"
 SET calc_data->qual[7].active_ind = 1
 SET calc_data->qual[7].calcvalue_description = "IBW (in kg)"
 SET calc_data->qual[7].number_components = 4
 SET calc_data->qual[7].components[1].component_flag = 1
 SET calc_data->qual[7].components[1].constant_value = 0
 SET calc_data->qual[7].components[1].component_label = "Patient Height"
 SET calc_data->qual[7].components[1].component_description = "height"
 SET calc_data->qual[7].components[1].event_cd = 0.0
 SET calc_data->qual[7].components[1].required_ind = 1
 SET calc_data->qual[7].components[1].corresponding_equation_id = 0.0
 SET calc_data->qual[7].components[1].component_code = "A"
 SET calc_data->qual[7].components[1].duplicate_component_name = ""
 SET calc_data->qual[7].components[1].number_units = 2
 SET calc_data->qual[7].components[1].unit_measure[1].unit_measure_meaning = "INCHES"
 SET calc_data->qual[7].components[1].unit_measure[1].default_ind = 1
 SET calc_data->qual[7].components[1].unit_measure[1].equation_dependent_unit_ind = 0
 SET calc_data->qual[7].components[1].unit_measure[2].unit_measure_meaning = "CM"
 SET calc_data->qual[7].components[1].unit_measure[2].default_ind = 0
 SET calc_data->qual[7].components[1].unit_measure[2].equation_dependent_unit_ind = 1
 SET calc_data->qual[7].components[2].component_flag = 2
 SET calc_data->qual[7].components[2].constant_value = 2
 SET calc_data->qual[7].components[2].component_label = "(No Label)"
 SET calc_data->qual[7].components[2].component_description = "2"
 SET calc_data->qual[7].components[2].event_cd = 0.0
 SET calc_data->qual[7].components[2].required_ind = 1
 SET calc_data->qual[7].components[2].corresponding_equation_id = 0.0
 SET calc_data->qual[7].components[2].component_code = "B"
 SET calc_data->qual[7].components[2].duplicate_component_name = ""
 SET calc_data->qual[7].components[2].number_units = 0
 SET calc_data->qual[7].components[3].component_flag = 2
 SET calc_data->qual[7].components[3].constant_value = 1.65
 SET calc_data->qual[7].components[3].component_label = "(No Label)"
 SET calc_data->qual[7].components[3].component_description = "1.65"
 SET calc_data->qual[7].components[3].event_cd = 0.0
 SET calc_data->qual[7].components[3].required_ind = 1
 SET calc_data->qual[7].components[3].corresponding_equation_id = 0.0
 SET calc_data->qual[7].components[3].component_code = "C"
 SET calc_data->qual[7].components[3].duplicate_component_name = ""
 SET calc_data->qual[7].components[3].number_units = 0
 SET calc_data->qual[7].components[4].component_flag = 2
 SET calc_data->qual[7].components[4].constant_value = 1000
 SET calc_data->qual[7].components[4].component_label = "(No Label)"
 SET calc_data->qual[7].components[4].component_description = "1000"
 SET calc_data->qual[7].components[4].event_cd = 0.0
 SET calc_data->qual[7].components[4].required_ind = 1
 SET calc_data->qual[7].components[4].corresponding_equation_id = 0.0
 SET calc_data->qual[7].components[4].component_code = "D"
 SET calc_data->qual[7].components[4].duplicate_component_name = ""
 SET calc_data->qual[7].components[4].number_units = 0
 SET calc_data->qual[8].description = "Ideal Body Weight - Female Children > 60 inches"
 SET calc_data->qual[8].description_key = cnvtupper(calc_data->qual[8].description)
 SET calc_data->qual[8].begin_age_nbr = 0
 SET calc_data->qual[8].begin_age_flag = 0
 SET calc_data->qual[8].end_age_nbr = 0
 SET calc_data->qual[8].end_age_flag = 0
 SET calc_data->qual[8].gender_cd = 0.0
 SET calc_data->qual[8].equation_display = "42.2 + 2.27*(height - 60)"
 SET calc_data->qual[8].equation_meaning = ""
 SET calc_data->qual[8].equation_code = "A+B*(C-D)"
 SET calc_data->qual[8].active_ind = 1
 SET calc_data->qual[8].calcvalue_description = "IBW (in kg)"
 SET calc_data->qual[8].number_components = 4
 SET calc_data->qual[8].components[1].component_flag = 2
 SET calc_data->qual[8].components[1].constant_value = 42.2
 SET calc_data->qual[8].components[1].component_label = "(No Label)"
 SET calc_data->qual[8].components[1].component_description = "42.2"
 SET calc_data->qual[8].components[1].event_cd = 0.0
 SET calc_data->qual[8].components[1].required_ind = 1
 SET calc_data->qual[8].components[1].corresponding_equation_id = 0.0
 SET calc_data->qual[8].components[1].component_code = "A"
 SET calc_data->qual[8].components[1].duplicate_component_name = ""
 SET calc_data->qual[8].components[1].number_units = 0
 SET calc_data->qual[8].components[2].component_flag = 2
 SET calc_data->qual[8].components[2].constant_value = 2.27
 SET calc_data->qual[8].components[2].component_label = "(No Label)"
 SET calc_data->qual[8].components[2].component_description = "2.27"
 SET calc_data->qual[8].components[2].event_cd = 0.0
 SET calc_data->qual[8].components[2].required_ind = 1
 SET calc_data->qual[8].components[2].corresponding_equation_id = 0.0
 SET calc_data->qual[8].components[2].component_code = "B"
 SET calc_data->qual[8].components[2].duplicate_component_name = ""
 SET calc_data->qual[8].components[2].number_units = 0
 SET calc_data->qual[8].components[3].component_flag = 1
 SET calc_data->qual[8].components[3].constant_value = 0
 SET calc_data->qual[8].components[3].component_label = "Patient Height"
 SET calc_data->qual[8].components[3].component_description = "height"
 SET calc_data->qual[8].components[3].event_cd = 0.0
 SET calc_data->qual[8].components[3].required_ind = 1
 SET calc_data->qual[8].components[3].corresponding_equation_id = 0.0
 SET calc_data->qual[8].components[3].component_code = "C"
 SET calc_data->qual[8].components[3].duplicate_component_name = ""
 SET calc_data->qual[8].components[3].number_units = 2
 SET calc_data->qual[8].components[3].unit_measure[1].unit_measure_meaning = "INCHES"
 SET calc_data->qual[8].components[3].unit_measure[1].default_ind = 1
 SET calc_data->qual[8].components[3].unit_measure[1].equation_dependent_unit_ind = 1
 SET calc_data->qual[8].components[3].unit_measure[2].unit_measure_meaning = "CM"
 SET calc_data->qual[8].components[3].unit_measure[2].default_ind = 0
 SET calc_data->qual[8].components[3].unit_measure[2].equation_dependent_unit_ind = 0
 SET calc_data->qual[8].components[4].component_flag = 2
 SET calc_data->qual[8].components[4].constant_value = 60
 SET calc_data->qual[8].components[4].component_label = "(No Label)"
 SET calc_data->qual[8].components[4].component_description = "60"
 SET calc_data->qual[8].components[4].event_cd = 0.0
 SET calc_data->qual[8].components[4].required_ind = 1
 SET calc_data->qual[8].components[4].corresponding_equation_id = 0.0
 SET calc_data->qual[8].components[4].component_code = "D"
 SET calc_data->qual[8].components[4].duplicate_component_name = ""
 SET calc_data->qual[8].components[4].number_units = 0
 SET calc_data->qual[9].description = "IV Fluid Rate"
 SET calc_data->qual[9].description_key = cnvtupper(calc_data->qual[9].description)
 SET calc_data->qual[9].begin_age_nbr = 0
 SET calc_data->qual[9].begin_age_flag = 0
 SET calc_data->qual[9].end_age_nbr = 0
 SET calc_data->qual[9].end_age_flag = 0
 SET calc_data->qual[9].gender_cd = 0.0
 SET calc_data->qual[9].equation_display = "(cc * drop factor) / (time)"
 SET calc_data->qual[9].equation_meaning = ""
 SET calc_data->qual[9].equation_code = "(A*B)/(C)"
 SET calc_data->qual[9].active_ind = 1
 SET calc_data->qual[9].calcvalue_description = "IV Fluid Rate"
 SET calc_data->qual[9].number_components = 3
 SET calc_data->qual[9].components[1].component_flag = 1
 SET calc_data->qual[9].components[1].constant_value = 0
 SET calc_data->qual[9].components[1].component_label = "Total Amt in cc"
 SET calc_data->qual[9].components[1].component_description = "cc"
 SET calc_data->qual[9].components[1].event_cd = 0.0
 SET calc_data->qual[9].components[1].required_ind = 1
 SET calc_data->qual[9].components[1].corresponding_equation_id = 0.0
 SET calc_data->qual[9].components[1].component_code = "A"
 SET calc_data->qual[9].components[1].duplicate_component_name = ""
 SET calc_data->qual[9].components[1].number_units = 0
 SET calc_data->qual[9].components[2].component_flag = 1
 SET calc_data->qual[9].components[2].constant_value = 0
 SET calc_data->qual[9].components[2].component_label = "drop factor"
 SET calc_data->qual[9].components[2].component_description = "drop factor"
 SET calc_data->qual[9].components[2].event_cd = 0.0
 SET calc_data->qual[9].components[2].required_ind = 1
 SET calc_data->qual[9].components[2].corresponding_equation_id = 0.0
 SET calc_data->qual[9].components[2].component_code = "B"
 SET calc_data->qual[9].components[2].duplicate_component_name = ""
 SET calc_data->qual[9].components[2].number_units = 0
 SET calc_data->qual[9].components[3].component_flag = 1
 SET calc_data->qual[9].components[3].constant_value = 0
 SET calc_data->qual[9].components[3].component_label = "time"
 SET calc_data->qual[9].components[3].component_description = "time"
 SET calc_data->qual[9].components[3].event_cd = 0.0
 SET calc_data->qual[9].components[3].required_ind = 1
 SET calc_data->qual[9].components[3].corresponding_equation_id = 0.0
 SET calc_data->qual[9].components[3].component_code = "C"
 SET calc_data->qual[9].components[3].duplicate_component_name = ""
 SET calc_data->qual[9].components[3].number_units = 2
 SET calc_data->qual[9].components[3].unit_measure[1].unit_measure_meaning = "HOURS"
 SET calc_data->qual[9].components[3].unit_measure[1].default_ind = 1
 SET calc_data->qual[9].components[3].unit_measure[1].equation_dependent_unit_ind = 0
 SET calc_data->qual[9].components[3].unit_measure[2].unit_measure_meaning = "MINUTES"
 SET calc_data->qual[9].components[3].unit_measure[2].default_ind = 0
 SET calc_data->qual[9].components[3].unit_measure[2].equation_dependent_unit_ind = 1
 SET calc_data->qual[10].description = "Lean Body Weight - Women"
 SET calc_data->qual[10].description_key = cnvtupper(calc_data->qual[10].description)
 SET calc_data->qual[10].begin_age_nbr = 0
 SET calc_data->qual[10].begin_age_flag = 0
 SET calc_data->qual[10].end_age_nbr = 0
 SET calc_data->qual[10].end_age_flag = 0
 SET calc_data->qual[10].gender_cd = 0.0
 SET calc_data->qual[10].equation_display = "1.07 * weight - (148 *((weight^2) /(100 * height) ^2))"
 SET calc_data->qual[10].equation_meaning = ""
 SET calc_data->qual[10].equation_code = "A*B-(C*((B^E)/(F*G)^H))"
 SET calc_data->qual[10].active_ind = 1
 SET calc_data->qual[10].calcvalue_description = "LBW (in kg)"
 SET calc_data->qual[10].number_components = 8
 SET calc_data->qual[10].components[1].component_flag = 2
 SET calc_data->qual[10].components[1].constant_value = 1.07
 SET calc_data->qual[10].components[1].component_label = "(No Label)"
 SET calc_data->qual[10].components[1].component_description = "1.07"
 SET calc_data->qual[10].components[1].event_cd = 0.0
 SET calc_data->qual[10].components[1].required_ind = 1
 SET calc_data->qual[10].components[1].corresponding_equation_id = 0.0
 SET calc_data->qual[10].components[1].component_code = "A"
 SET calc_data->qual[10].components[1].duplicate_component_name = ""
 SET calc_data->qual[10].components[1].number_units = 0
 SET calc_data->qual[10].components[2].component_flag = 1
 SET calc_data->qual[10].components[2].constant_value = 0
 SET calc_data->qual[10].components[2].component_label = "Patient Weight"
 SET calc_data->qual[10].components[2].component_description = "weight"
 SET calc_data->qual[10].components[2].event_cd = 0.0
 SET calc_data->qual[10].components[2].required_ind = 1
 SET calc_data->qual[10].components[2].corresponding_equation_id = 0.0
 SET calc_data->qual[10].components[2].component_code = "B"
 SET calc_data->qual[10].components[2].duplicate_component_name = ""
 SET calc_data->qual[10].components[2].number_units = 3
 SET calc_data->qual[10].components[2].unit_measure[1].unit_measure_meaning = "LB"
 SET calc_data->qual[10].components[2].unit_measure[1].default_ind = 1
 SET calc_data->qual[10].components[2].unit_measure[1].equation_dependent_unit_ind = 0
 SET calc_data->qual[10].components[2].unit_measure[2].unit_measure_meaning = "KG"
 SET calc_data->qual[10].components[2].unit_measure[2].default_ind = 0
 SET calc_data->qual[10].components[2].unit_measure[2].equation_dependent_unit_ind = 1
 SET calc_data->qual[10].components[2].unit_measure[3].unit_measure_meaning = "GM"
 SET calc_data->qual[10].components[2].unit_measure[3].default_ind = 0
 SET calc_data->qual[10].components[2].unit_measure[3].equation_dependent_unit_ind = 0
 SET calc_data->qual[10].components[3].component_flag = 2
 SET calc_data->qual[10].components[3].constant_value = 148
 SET calc_data->qual[10].components[3].component_label = "(No Label)"
 SET calc_data->qual[10].components[3].component_description = "148"
 SET calc_data->qual[10].components[3].event_cd = 0.0
 SET calc_data->qual[10].components[3].required_ind = 1
 SET calc_data->qual[10].components[3].corresponding_equation_id = 0.0
 SET calc_data->qual[10].components[3].component_code = "C"
 SET calc_data->qual[10].components[3].duplicate_component_name = ""
 SET calc_data->qual[10].components[3].number_units = 0
 SET calc_data->qual[10].components[4].component_flag = 5
 SET calc_data->qual[10].components[4].constant_value = 0
 SET calc_data->qual[10].components[4].component_label = "weight"
 SET calc_data->qual[10].components[4].component_description = "weight"
 SET calc_data->qual[10].components[4].event_cd = 0.0
 SET calc_data->qual[10].components[4].required_ind = 1
 SET calc_data->qual[10].components[4].corresponding_equation_id = 0.0
 SET calc_data->qual[10].components[4].component_code = "B"
 SET calc_data->qual[10].components[4].duplicate_component_name = "weight"
 SET calc_data->qual[10].components[4].number_units = 0
 SET calc_data->qual[10].components[5].component_flag = 2
 SET calc_data->qual[10].components[5].constant_value = 2
 SET calc_data->qual[10].components[5].component_label = "(No Label)"
 SET calc_data->qual[10].components[5].component_description = "2"
 SET calc_data->qual[10].components[5].event_cd = 0.0
 SET calc_data->qual[10].components[5].required_ind = 1
 SET calc_data->qual[10].components[5].corresponding_equation_id = 0.0
 SET calc_data->qual[10].components[5].component_code = "E"
 SET calc_data->qual[10].components[5].duplicate_component_name = ""
 SET calc_data->qual[10].components[5].number_units = 0
 SET calc_data->qual[10].components[6].component_flag = 2
 SET calc_data->qual[10].components[6].constant_value = 100
 SET calc_data->qual[10].components[6].component_label = "(No Label)"
 SET calc_data->qual[10].components[6].component_description = "100"
 SET calc_data->qual[10].components[6].event_cd = 0.0
 SET calc_data->qual[10].components[6].required_ind = 1
 SET calc_data->qual[10].components[6].corresponding_equation_id = 0.0
 SET calc_data->qual[10].components[6].component_code = "F"
 SET calc_data->qual[10].components[6].duplicate_component_name = ""
 SET calc_data->qual[10].components[6].number_units = 0
 SET calc_data->qual[10].components[7].component_flag = 1
 SET calc_data->qual[10].components[7].constant_value = 0
 SET calc_data->qual[10].components[7].component_label = "Patient Height"
 SET calc_data->qual[10].components[7].component_description = "height"
 SET calc_data->qual[10].components[7].event_cd = 0.0
 SET calc_data->qual[10].components[7].required_ind = 1
 SET calc_data->qual[10].components[7].corresponding_equation_id = 0.0
 SET calc_data->qual[10].components[7].component_code = "G"
 SET calc_data->qual[10].components[7].duplicate_component_name = ""
 SET calc_data->qual[10].components[7].number_units = 2
 SET calc_data->qual[10].components[7].unit_measure[1].unit_measure_meaning = "INCHES"
 SET calc_data->qual[10].components[7].unit_measure[1].default_ind = 1
 SET calc_data->qual[10].components[7].unit_measure[1].equation_dependent_unit_ind = 0
 SET calc_data->qual[10].components[7].unit_measure[2].unit_measure_meaning = "CM"
 SET calc_data->qual[10].components[7].unit_measure[2].default_ind = 0
 SET calc_data->qual[10].components[7].unit_measure[2].equation_dependent_unit_ind = 1
 SET calc_data->qual[10].components[8].component_flag = 2
 SET calc_data->qual[10].components[8].constant_value = 2
 SET calc_data->qual[10].components[8].component_label = "(No Label)"
 SET calc_data->qual[10].components[8].component_description = "2"
 SET calc_data->qual[10].components[8].event_cd = 0.0
 SET calc_data->qual[10].components[8].required_ind = 1
 SET calc_data->qual[10].components[8].corresponding_equation_id = 0.0
 SET calc_data->qual[10].components[8].component_code = "H"
 SET calc_data->qual[10].components[8].duplicate_component_name = ""
 SET calc_data->qual[10].components[8].number_units = 0
 SET calc_data->qual[11].description = "mcg/kg/min"
 SET calc_data->qual[11].description_key = cnvtupper(calc_data->qual[11].description)
 SET calc_data->qual[11].begin_age_nbr = 0
 SET calc_data->qual[11].begin_age_flag = 0
 SET calc_data->qual[11].end_age_nbr = 0
 SET calc_data->qual[11].end_age_flag = 0
 SET calc_data->qual[11].gender_cd = 0.0
 SET calc_data->qual[11].equation_display = "(cc * concentration of drip) /( 60 * weight)"
 SET calc_data->qual[11].equation_meaning = ""
 SET calc_data->qual[11].equation_code = "(A*B)/(C*D)"
 SET calc_data->qual[11].active_ind = 1
 SET calc_data->qual[11].calcvalue_description = "mcg/kg/min"
 SET calc_data->qual[11].number_components = 4
 SET calc_data->qual[11].components[1].component_flag = 1
 SET calc_data->qual[11].components[1].constant_value = 0
 SET calc_data->qual[11].components[1].component_label = "cc/hr"
 SET calc_data->qual[11].components[1].component_description = "cc"
 SET calc_data->qual[11].components[1].event_cd = 0.0
 SET calc_data->qual[11].components[1].required_ind = 1
 SET calc_data->qual[11].components[1].corresponding_equation_id = 0.0
 SET calc_data->qual[11].components[1].component_code = "A"
 SET calc_data->qual[11].components[1].duplicate_component_name = ""
 SET calc_data->qual[11].components[1].number_units = 0
 SET calc_data->qual[11].components[2].component_flag = 4
 SET calc_data->qual[11].components[2].constant_value = 0
 SET calc_data->qual[11].components[2].component_label = "Concentration of drip"
 SET calc_data->qual[11].components[2].component_description = "concentration of drip"
 SET calc_data->qual[11].components[2].event_cd = 0.0
 SET calc_data->qual[11].components[2].required_ind = 1
 SET calc_data->qual[11].components[2].corresponding_equation_id = 0.0
 SET calc_data->qual[11].components[2].component_code = "B"
 SET calc_data->qual[11].components[2].duplicate_component_name = ""
 SET calc_data->qual[11].components[2].number_units = 2
 SET calc_data->qual[11].components[2].unit_measure[1].unit_measure_meaning = "MG/CC"
 SET calc_data->qual[11].components[2].unit_measure[1].default_ind = 0
 SET calc_data->qual[11].components[2].unit_measure[1].equation_dependent_unit_ind = 0
 SET calc_data->qual[11].components[2].unit_measure[2].unit_measure_meaning = "MCG/CC"
 SET calc_data->qual[11].components[2].unit_measure[2].default_ind = 1
 SET calc_data->qual[11].components[2].unit_measure[2].equation_dependent_unit_ind = 1
 SET calc_data->qual[11].components[3].component_flag = 2
 SET calc_data->qual[11].components[3].constant_value = 60
 SET calc_data->qual[11].components[3].component_label = "(No Label)"
 SET calc_data->qual[11].components[3].component_description = "60"
 SET calc_data->qual[11].components[3].event_cd = 0.0
 SET calc_data->qual[11].components[3].required_ind = 1
 SET calc_data->qual[11].components[3].corresponding_equation_id = 0.0
 SET calc_data->qual[11].components[3].component_code = "C"
 SET calc_data->qual[11].components[3].duplicate_component_name = ""
 SET calc_data->qual[11].components[3].number_units = 0
 SET calc_data->qual[11].components[4].component_flag = 1
 SET calc_data->qual[11].components[4].constant_value = 0
 SET calc_data->qual[11].components[4].component_label = "Patient Weight"
 SET calc_data->qual[11].components[4].component_description = "weight"
 SET calc_data->qual[11].components[4].event_cd = 0.0
 SET calc_data->qual[11].components[4].required_ind = 1
 SET calc_data->qual[11].components[4].corresponding_equation_id = 0.0
 SET calc_data->qual[11].components[4].component_code = "D"
 SET calc_data->qual[11].components[4].duplicate_component_name = ""
 SET calc_data->qual[11].components[4].number_units = 3
 SET calc_data->qual[11].components[4].unit_measure[1].unit_measure_meaning = "LB"
 SET calc_data->qual[11].components[4].unit_measure[1].default_ind = 1
 SET calc_data->qual[11].components[4].unit_measure[1].equation_dependent_unit_ind = 0
 SET calc_data->qual[11].components[4].unit_measure[2].unit_measure_meaning = "KG"
 SET calc_data->qual[11].components[4].unit_measure[2].default_ind = 0
 SET calc_data->qual[11].components[4].unit_measure[2].equation_dependent_unit_ind = 1
 SET calc_data->qual[11].components[4].unit_measure[3].unit_measure_meaning = "GM"
 SET calc_data->qual[11].components[4].unit_measure[3].default_ind = 0
 SET calc_data->qual[11].components[4].unit_measure[3].equation_dependent_unit_ind = 0
 SET calc_data->qual[12].description = "Stroke Volume"
 SET calc_data->qual[12].description_key = cnvtupper(calc_data->qual[12].description)
 SET calc_data->qual[12].begin_age_nbr = 0
 SET calc_data->qual[12].begin_age_flag = 0
 SET calc_data->qual[12].end_age_nbr = 0
 SET calc_data->qual[12].end_age_flag = 0
 SET calc_data->qual[12].gender_cd = 0.0
 SET calc_data->qual[12].equation_display = "CO/HR"
 SET calc_data->qual[12].equation_meaning = ""
 SET calc_data->qual[12].equation_code = "A/B"
 SET calc_data->qual[12].active_ind = 1
 SET calc_data->qual[12].calcvalue_description = "Stroke Volume"
 SET calc_data->qual[12].number_components = 2
 SET calc_data->qual[12].components[1].component_flag = 1
 SET calc_data->qual[12].components[1].constant_value = 0
 SET calc_data->qual[12].components[1].component_label = "Cardiac Output"
 SET calc_data->qual[12].components[1].component_description = "CO"
 SET calc_data->qual[12].components[1].event_cd = 0.0
 SET calc_data->qual[12].components[1].required_ind = 1
 SET calc_data->qual[12].components[1].corresponding_equation_id = 0.0
 SET calc_data->qual[12].components[1].component_code = "A"
 SET calc_data->qual[12].components[1].duplicate_component_name = ""
 SET calc_data->qual[12].components[1].number_units = 0
 SET calc_data->qual[12].components[2].component_flag = 1
 SET calc_data->qual[12].components[2].constant_value = 0
 SET calc_data->qual[12].components[2].component_label = "Heart Rate"
 SET calc_data->qual[12].components[2].component_description = "HR"
 SET calc_data->qual[12].components[2].event_cd = 0.0
 SET calc_data->qual[12].components[2].required_ind = 1
 SET calc_data->qual[12].components[2].corresponding_equation_id = 0.0
 SET calc_data->qual[12].components[2].component_code = "B"
 SET calc_data->qual[12].components[2].duplicate_component_name = ""
 SET calc_data->qual[12].components[2].number_units = 0
 SET calc_data->qual[13].description = "Ideal Body Weight - Men"
 SET calc_data->qual[13].description_key = cnvtupper(calc_data->qual[13].description)
 SET calc_data->qual[13].begin_age_nbr = 0
 SET calc_data->qual[13].begin_age_flag = 0
 SET calc_data->qual[13].end_age_nbr = 0
 SET calc_data->qual[13].end_age_flag = 0
 SET calc_data->qual[13].gender_cd = 0.0
 SET calc_data->qual[13].equation_display = "50 + 2.3*(height - 60)"
 SET calc_data->qual[13].equation_meaning = ""
 SET calc_data->qual[13].equation_code = "A+B*(C-D)"
 SET calc_data->qual[13].active_ind = 1
 SET calc_data->qual[13].calcvalue_description = "IBW (in kg)"
 SET calc_data->qual[13].number_components = 4
 SET calc_data->qual[13].components[1].component_flag = 2
 SET calc_data->qual[13].components[1].constant_value = 50
 SET calc_data->qual[13].components[1].component_label = "(No Label)"
 SET calc_data->qual[13].components[1].component_description = "50"
 SET calc_data->qual[13].components[1].event_cd = 0.0
 SET calc_data->qual[13].components[1].required_ind = 1
 SET calc_data->qual[13].components[1].corresponding_equation_id = 0.0
 SET calc_data->qual[13].components[1].component_code = "A"
 SET calc_data->qual[13].components[1].duplicate_component_name = ""
 SET calc_data->qual[13].components[1].number_units = 0
 SET calc_data->qual[13].components[2].component_flag = 2
 SET calc_data->qual[13].components[2].constant_value = 2.30
 SET calc_data->qual[13].components[2].component_label = "(No Label)"
 SET calc_data->qual[13].components[2].component_description = "2.30"
 SET calc_data->qual[13].components[2].event_cd = 0.0
 SET calc_data->qual[13].components[2].required_ind = 1
 SET calc_data->qual[13].components[2].corresponding_equation_id = 0.0
 SET calc_data->qual[13].components[2].component_code = "B"
 SET calc_data->qual[13].components[2].duplicate_component_name = ""
 SET calc_data->qual[13].components[2].number_units = 0
 SET calc_data->qual[13].components[3].component_flag = 1
 SET calc_data->qual[13].components[3].constant_value = 0
 SET calc_data->qual[13].components[3].component_label = "Patient Height"
 SET calc_data->qual[13].components[3].component_description = "height"
 SET calc_data->qual[13].components[3].event_cd = 0.0
 SET calc_data->qual[13].components[3].required_ind = 1
 SET calc_data->qual[13].components[3].corresponding_equation_id = 0.0
 SET calc_data->qual[13].components[3].component_code = "C"
 SET calc_data->qual[13].components[3].duplicate_component_name = ""
 SET calc_data->qual[13].components[3].number_units = 2
 SET calc_data->qual[13].components[3].unit_measure[1].unit_measure_meaning = "INCHES"
 SET calc_data->qual[13].components[3].unit_measure[1].default_ind = 1
 SET calc_data->qual[13].components[3].unit_measure[1].equation_dependent_unit_ind = 1
 SET calc_data->qual[13].components[3].unit_measure[2].unit_measure_meaning = "CM"
 SET calc_data->qual[13].components[3].unit_measure[2].default_ind = 0
 SET calc_data->qual[13].components[3].unit_measure[2].equation_dependent_unit_ind = 0
 SET calc_data->qual[13].components[4].component_flag = 2
 SET calc_data->qual[13].components[4].constant_value = 60
 SET calc_data->qual[13].components[4].component_label = "(No Label)"
 SET calc_data->qual[13].components[4].component_description = "60"
 SET calc_data->qual[13].components[4].event_cd = 0.0
 SET calc_data->qual[13].components[4].required_ind = 1
 SET calc_data->qual[13].components[4].corresponding_equation_id = 0.0
 SET calc_data->qual[13].components[4].component_code = "D"
 SET calc_data->qual[13].components[4].duplicate_component_name = ""
 SET calc_data->qual[13].components[4].number_units = 0
 SET calc_data->qual[14].description = "Ideal Body Weight - Women"
 SET calc_data->qual[14].description_key = cnvtupper(calc_data->qual[14].description)
 SET calc_data->qual[14].begin_age_nbr = 0
 SET calc_data->qual[14].begin_age_flag = 0
 SET calc_data->qual[14].end_age_nbr = 0
 SET calc_data->qual[14].end_age_flag = 0
 SET calc_data->qual[14].gender_cd = 0.0
 SET calc_data->qual[14].equation_display = "45.5 + 2.3*(height - 60) "
 SET calc_data->qual[14].equation_meaning = ""
 SET calc_data->qual[14].equation_code = "A+B*(C-D)"
 SET calc_data->qual[14].active_ind = 1
 SET calc_data->qual[14].calcvalue_description = "IBW (in kg)"
 SET calc_data->qual[14].number_components = 4
 SET calc_data->qual[14].components[1].component_flag = 2
 SET calc_data->qual[14].components[1].constant_value = 45.5
 SET calc_data->qual[14].components[1].component_label = "(No Label)"
 SET calc_data->qual[14].components[1].component_description = "45.5"
 SET calc_data->qual[14].components[1].event_cd = 0.0
 SET calc_data->qual[14].components[1].required_ind = 1
 SET calc_data->qual[14].components[1].corresponding_equation_id = 0.0
 SET calc_data->qual[14].components[1].component_code = "A"
 SET calc_data->qual[14].components[1].duplicate_component_name = ""
 SET calc_data->qual[14].components[1].number_units = 0
 SET calc_data->qual[14].components[2].component_flag = 2
 SET calc_data->qual[14].components[2].constant_value = 2.3
 SET calc_data->qual[14].components[2].component_label = "(No Label)"
 SET calc_data->qual[14].components[2].component_description = "2.3"
 SET calc_data->qual[14].components[2].event_cd = 0.0
 SET calc_data->qual[14].components[2].required_ind = 1
 SET calc_data->qual[14].components[2].corresponding_equation_id = 0.0
 SET calc_data->qual[14].components[2].component_code = "B"
 SET calc_data->qual[14].components[2].duplicate_component_name = ""
 SET calc_data->qual[14].components[2].number_units = 0
 SET calc_data->qual[14].components[3].component_flag = 1
 SET calc_data->qual[14].components[3].constant_value = 0
 SET calc_data->qual[14].components[3].component_label = "Patient Height"
 SET calc_data->qual[14].components[3].component_description = "height"
 SET calc_data->qual[14].components[3].event_cd = 0.0
 SET calc_data->qual[14].components[3].required_ind = 1
 SET calc_data->qual[14].components[3].corresponding_equation_id = 0.0
 SET calc_data->qual[14].components[3].component_code = "C"
 SET calc_data->qual[14].components[3].duplicate_component_name = ""
 SET calc_data->qual[14].components[3].number_units = 2
 SET calc_data->qual[14].components[3].unit_measure[1].unit_measure_meaning = "INCHES"
 SET calc_data->qual[14].components[3].unit_measure[1].default_ind = 1
 SET calc_data->qual[14].components[3].unit_measure[1].equation_dependent_unit_ind = 1
 SET calc_data->qual[14].components[3].unit_measure[2].unit_measure_meaning = "CM"
 SET calc_data->qual[14].components[3].unit_measure[2].default_ind = 0
 SET calc_data->qual[14].components[3].unit_measure[2].equation_dependent_unit_ind = 0
 SET calc_data->qual[14].components[4].component_flag = 2
 SET calc_data->qual[14].components[4].constant_value = 60
 SET calc_data->qual[14].components[4].component_label = "(No Label)"
 SET calc_data->qual[14].components[4].component_description = "60"
 SET calc_data->qual[14].components[4].event_cd = 0.0
 SET calc_data->qual[14].components[4].required_ind = 1
 SET calc_data->qual[14].components[4].corresponding_equation_id = 0.0
 SET calc_data->qual[14].components[4].component_code = "D"
 SET calc_data->qual[14].components[4].duplicate_component_name = ""
 SET calc_data->qual[14].components[4].number_units = 0
 SET calc_data->qual[15].description = "Lean Body Weight - Men"
 SET calc_data->qual[15].description_key = cnvtupper(calc_data->qual[15].description)
 SET calc_data->qual[15].begin_age_nbr = 0
 SET calc_data->qual[15].begin_age_flag = 0
 SET calc_data->qual[15].end_age_nbr = 0
 SET calc_data->qual[15].end_age_flag = 0
 SET calc_data->qual[15].gender_cd = 0.0
 SET calc_data->qual[15].equation_display = "1.10 * weight - (128 *( (weight ^2 )/(height^2)))"
 SET calc_data->qual[15].equation_meaning = ""
 SET calc_data->qual[15].equation_code = "A*B-(C*((B^E)/(G^H)))"
 SET calc_data->qual[15].active_ind = 1
 SET calc_data->qual[15].calcvalue_description = "LBW (in kg)"
 SET calc_data->qual[15].number_components = 7
 SET calc_data->qual[15].components[1].component_flag = 2
 SET calc_data->qual[15].components[1].constant_value = 1.10
 SET calc_data->qual[15].components[1].component_label = "(No Label)"
 SET calc_data->qual[15].components[1].component_description = "1.10"
 SET calc_data->qual[15].components[1].event_cd = 0.0
 SET calc_data->qual[15].components[1].required_ind = 1
 SET calc_data->qual[15].components[1].corresponding_equation_id = 0.0
 SET calc_data->qual[15].components[1].component_code = "A"
 SET calc_data->qual[15].components[1].duplicate_component_name = ""
 SET calc_data->qual[15].components[1].number_units = 0
 SET calc_data->qual[15].components[2].component_flag = 1
 SET calc_data->qual[15].components[2].constant_value = 0
 SET calc_data->qual[15].components[2].component_label = "Patient Weight"
 SET calc_data->qual[15].components[2].component_description = "weight"
 SET calc_data->qual[15].components[2].event_cd = 0.0
 SET calc_data->qual[15].components[2].required_ind = 1
 SET calc_data->qual[15].components[2].corresponding_equation_id = 0.0
 SET calc_data->qual[15].components[2].component_code = "B"
 SET calc_data->qual[15].components[2].duplicate_component_name = ""
 SET calc_data->qual[15].components[2].number_units = 3
 SET calc_data->qual[15].components[2].unit_measure[1].unit_measure_meaning = "LB"
 SET calc_data->qual[15].components[2].unit_measure[1].default_ind = 1
 SET calc_data->qual[15].components[2].unit_measure[1].equation_dependent_unit_ind = 0
 SET calc_data->qual[15].components[2].unit_measure[2].unit_measure_meaning = "KG"
 SET calc_data->qual[15].components[2].unit_measure[2].default_ind = 0
 SET calc_data->qual[15].components[2].unit_measure[2].equation_dependent_unit_ind = 1
 SET calc_data->qual[15].components[2].unit_measure[3].unit_measure_meaning = "GM"
 SET calc_data->qual[15].components[2].unit_measure[3].default_ind = 0
 SET calc_data->qual[15].components[2].unit_measure[3].equation_dependent_unit_ind = 0
 SET calc_data->qual[15].components[3].component_flag = 2
 SET calc_data->qual[15].components[3].constant_value = 128
 SET calc_data->qual[15].components[3].component_label = "(No Label)"
 SET calc_data->qual[15].components[3].component_description = "128"
 SET calc_data->qual[15].components[3].event_cd = 0.0
 SET calc_data->qual[15].components[3].required_ind = 1
 SET calc_data->qual[15].components[3].corresponding_equation_id = 0.0
 SET calc_data->qual[15].components[3].component_code = "C"
 SET calc_data->qual[15].components[3].duplicate_component_name = ""
 SET calc_data->qual[15].components[3].number_units = 0
 SET calc_data->qual[15].components[4].component_flag = 5
 SET calc_data->qual[15].components[4].constant_value = 0
 SET calc_data->qual[15].components[4].component_label = "weight"
 SET calc_data->qual[15].components[4].component_description = "weight"
 SET calc_data->qual[15].components[4].event_cd = 0.0
 SET calc_data->qual[15].components[4].required_ind = 1
 SET calc_data->qual[15].components[4].corresponding_equation_id = 0.0
 SET calc_data->qual[15].components[4].component_code = "B"
 SET calc_data->qual[15].components[4].duplicate_component_name = "weight"
 SET calc_data->qual[15].components[4].number_units = 0
 SET calc_data->qual[15].components[5].component_flag = 2
 SET calc_data->qual[15].components[5].constant_value = 2
 SET calc_data->qual[15].components[5].component_label = "(No Label)"
 SET calc_data->qual[15].components[5].component_description = "2"
 SET calc_data->qual[15].components[5].event_cd = 0.0
 SET calc_data->qual[15].components[5].required_ind = 1
 SET calc_data->qual[15].components[5].corresponding_equation_id = 0.0
 SET calc_data->qual[15].components[5].component_code = "E"
 SET calc_data->qual[15].components[5].duplicate_component_name = ""
 SET calc_data->qual[15].components[5].number_units = 0
 SET calc_data->qual[15].components[6].component_flag = 1
 SET calc_data->qual[15].components[6].constant_value = 0
 SET calc_data->qual[15].components[6].component_label = "Patient Height"
 SET calc_data->qual[15].components[6].component_description = "height"
 SET calc_data->qual[15].components[6].event_cd = 0.0
 SET calc_data->qual[15].components[6].required_ind = 1
 SET calc_data->qual[15].components[6].corresponding_equation_id = 0.0
 SET calc_data->qual[15].components[6].component_code = "G"
 SET calc_data->qual[15].components[6].duplicate_component_name = ""
 SET calc_data->qual[15].components[6].number_units = 2
 SET calc_data->qual[15].components[6].unit_measure[1].unit_measure_meaning = "INCHES"
 SET calc_data->qual[15].components[6].unit_measure[1].default_ind = 1
 SET calc_data->qual[15].components[6].unit_measure[1].equation_dependent_unit_ind = 0
 SET calc_data->qual[15].components[6].unit_measure[2].unit_measure_meaning = "CM"
 SET calc_data->qual[15].components[6].unit_measure[2].default_ind = 0
 SET calc_data->qual[15].components[6].unit_measure[2].equation_dependent_unit_ind = 1
 SET calc_data->qual[15].components[7].component_flag = 2
 SET calc_data->qual[15].components[7].constant_value = 2
 SET calc_data->qual[15].components[7].component_label = "(No Label)"
 SET calc_data->qual[15].components[7].component_description = "2"
 SET calc_data->qual[15].components[7].event_cd = 0.0
 SET calc_data->qual[15].components[7].required_ind = 1
 SET calc_data->qual[15].components[7].corresponding_equation_id = 0.0
 SET calc_data->qual[15].components[7].component_code = "H"
 SET calc_data->qual[15].components[7].duplicate_component_name = ""
 SET calc_data->qual[15].components[7].number_units = 0
 SET calc_data->qual[16].description = "Estimated Creatinine Clearance - Men"
 SET calc_data->qual[16].description_key = cnvtupper(calc_data->qual[16].description)
 SET calc_data->qual[16].begin_age_nbr = 0
 SET calc_data->qual[16].begin_age_flag = 0
 SET calc_data->qual[16].end_age_nbr = 0
 SET calc_data->qual[16].end_age_flag = 0
 SET calc_data->qual[16].gender_cd = 0.0
 SET calc_data->qual[16].equation_display = "((140 - age) * (weight))/(72 * serum Cr)"
 SET calc_data->qual[16].equation_meaning = ""
 SET calc_data->qual[16].equation_code = "((A-B)*(C))/(D*E)"
 SET calc_data->qual[16].active_ind = 1
 SET calc_data->qual[16].calcvalue_description = "EST CC - Men (in kg)"
 SET calc_data->qual[16].number_components = 5
 SET calc_data->qual[16].components[1].component_flag = 2
 SET calc_data->qual[16].components[1].constant_value = 140
 SET calc_data->qual[16].components[1].component_label = "(No Label)"
 SET calc_data->qual[16].components[1].component_description = "140"
 SET calc_data->qual[16].components[1].event_cd = 0.0
 SET calc_data->qual[16].components[1].required_ind = 1
 SET calc_data->qual[16].components[1].corresponding_equation_id = 0.0
 SET calc_data->qual[16].components[1].component_code = "A"
 SET calc_data->qual[16].components[1].duplicate_component_name = ""
 SET calc_data->qual[16].components[1].number_units = 0
 SET calc_data->qual[16].components[2].component_flag = 1
 SET calc_data->qual[16].components[2].constant_value = 0
 SET calc_data->qual[16].components[2].component_label = "Patient Age"
 SET calc_data->qual[16].components[2].component_description = "age"
 SET calc_data->qual[16].components[2].event_cd = 0.0
 SET calc_data->qual[16].components[2].required_ind = 1
 SET calc_data->qual[16].components[2].corresponding_equation_id = 0.0
 SET calc_data->qual[16].components[2].component_code = "B"
 SET calc_data->qual[16].components[2].duplicate_component_name = ""
 SET calc_data->qual[16].components[2].number_units = 0
 SET calc_data->qual[16].components[3].component_flag = 1
 SET calc_data->qual[16].components[3].constant_value = 0
 SET calc_data->qual[16].components[3].component_label = "Patient Weight"
 SET calc_data->qual[16].components[3].component_description = "weight"
 SET calc_data->qual[16].components[3].event_cd = 0.0
 SET calc_data->qual[16].components[3].required_ind = 1
 SET calc_data->qual[16].components[3].corresponding_equation_id = 0.0
 SET calc_data->qual[16].components[3].component_code = "C"
 SET calc_data->qual[16].components[3].duplicate_component_name = ""
 SET calc_data->qual[16].components[3].number_units = 3
 SET calc_data->qual[16].components[3].unit_measure[1].unit_measure_meaning = "LB"
 SET calc_data->qual[16].components[3].unit_measure[1].default_ind = 1
 SET calc_data->qual[16].components[3].unit_measure[1].equation_dependent_unit_ind = 0
 SET calc_data->qual[16].components[3].unit_measure[2].unit_measure_meaning = "KG"
 SET calc_data->qual[16].components[3].unit_measure[2].default_ind = 0
 SET calc_data->qual[16].components[3].unit_measure[2].equation_dependent_unit_ind = 1
 SET calc_data->qual[16].components[3].unit_measure[3].unit_measure_meaning = "GM"
 SET calc_data->qual[16].components[3].unit_measure[3].default_ind = 0
 SET calc_data->qual[16].components[3].unit_measure[3].equation_dependent_unit_ind = 0
 SET calc_data->qual[16].components[4].component_flag = 2
 SET calc_data->qual[16].components[4].constant_value = 72
 SET calc_data->qual[16].components[4].component_label = "(No Label)"
 SET calc_data->qual[16].components[4].component_description = "72"
 SET calc_data->qual[16].components[4].event_cd = 0.0
 SET calc_data->qual[16].components[4].required_ind = 1
 SET calc_data->qual[16].components[4].corresponding_equation_id = 0.0
 SET calc_data->qual[16].components[4].component_code = "D"
 SET calc_data->qual[16].components[4].duplicate_component_name = ""
 SET calc_data->qual[16].components[4].number_units = 0
 SET calc_data->qual[16].components[5].component_flag = 1
 SET calc_data->qual[16].components[5].constant_value = 0
 SET calc_data->qual[16].components[5].component_label = "serum Cr"
 SET calc_data->qual[16].components[5].component_description = "serum Cr"
 SET calc_data->qual[16].components[5].event_cd = 0.0
 SET calc_data->qual[16].components[5].required_ind = 1
 SET calc_data->qual[16].components[5].corresponding_equation_id = 0.0
 SET calc_data->qual[16].components[5].component_code = "E"
 SET calc_data->qual[16].components[5].duplicate_component_name = ""
 SET calc_data->qual[16].components[5].number_units = 0
 SET calc_data->qual[17].description = "Ideal Body Weight - Male Children > 60 inches"
 SET calc_data->qual[17].description_key = cnvtupper(calc_data->qual[17].description)
 SET calc_data->qual[17].begin_age_nbr = 0
 SET calc_data->qual[17].begin_age_flag = 0
 SET calc_data->qual[17].end_age_nbr = 0
 SET calc_data->qual[17].end_age_flag = 0
 SET calc_data->qual[17].gender_cd = 0.0
 SET calc_data->qual[17].equation_display = "39+2.27*(height - 60)"
 SET calc_data->qual[17].equation_meaning = ""
 SET calc_data->qual[17].equation_code = "A+B*(C-D)"
 SET calc_data->qual[17].active_ind = 1
 SET calc_data->qual[17].calcvalue_description = "IBW (in kg)"
 SET calc_data->qual[17].number_components = 4
 SET calc_data->qual[17].components[1].component_flag = 2
 SET calc_data->qual[17].components[1].constant_value = 39
 SET calc_data->qual[17].components[1].component_label = "(No Label)"
 SET calc_data->qual[17].components[1].component_description = "39"
 SET calc_data->qual[17].components[1].event_cd = 0.0
 SET calc_data->qual[17].components[1].required_ind = 1
 SET calc_data->qual[17].components[1].corresponding_equation_id = 0.0
 SET calc_data->qual[17].components[1].component_code = "A"
 SET calc_data->qual[17].components[1].duplicate_component_name = ""
 SET calc_data->qual[17].components[1].number_units = 0
 SET calc_data->qual[17].components[2].component_flag = 2
 SET calc_data->qual[17].components[2].constant_value = 2.27
 SET calc_data->qual[17].components[2].component_label = "(No Label)"
 SET calc_data->qual[17].components[2].component_description = "2.27"
 SET calc_data->qual[17].components[2].event_cd = 0.0
 SET calc_data->qual[17].components[2].required_ind = 1
 SET calc_data->qual[17].components[2].corresponding_equation_id = 0.0
 SET calc_data->qual[17].components[2].component_code = "B"
 SET calc_data->qual[17].components[2].duplicate_component_name = ""
 SET calc_data->qual[17].components[2].number_units = 0
 SET calc_data->qual[17].components[3].component_flag = 1
 SET calc_data->qual[17].components[3].constant_value = 0
 SET calc_data->qual[17].components[3].component_label = "Patient Height"
 SET calc_data->qual[17].components[3].component_description = "height"
 SET calc_data->qual[17].components[3].event_cd = 0.0
 SET calc_data->qual[17].components[3].required_ind = 1
 SET calc_data->qual[17].components[3].corresponding_equation_id = 0.0
 SET calc_data->qual[17].components[3].component_code = "C"
 SET calc_data->qual[17].components[3].duplicate_component_name = ""
 SET calc_data->qual[17].components[3].number_units = 2
 SET calc_data->qual[17].components[3].unit_measure[1].unit_measure_meaning = "INCHES"
 SET calc_data->qual[17].components[3].unit_measure[1].default_ind = 1
 SET calc_data->qual[17].components[3].unit_measure[1].equation_dependent_unit_ind = 1
 SET calc_data->qual[17].components[3].unit_measure[2].unit_measure_meaning = "CM"
 SET calc_data->qual[17].components[3].unit_measure[2].default_ind = 0
 SET calc_data->qual[17].components[3].unit_measure[2].equation_dependent_unit_ind = 0
 SET calc_data->qual[17].components[4].component_flag = 2
 SET calc_data->qual[17].components[4].constant_value = 60
 SET calc_data->qual[17].components[4].component_label = "(No Label)"
 SET calc_data->qual[17].components[4].component_description = "60"
 SET calc_data->qual[17].components[4].event_cd = 0.0
 SET calc_data->qual[17].components[4].required_ind = 1
 SET calc_data->qual[17].components[4].corresponding_equation_id = 0.0
 SET calc_data->qual[17].components[4].component_code = "D"
 SET calc_data->qual[17].components[4].duplicate_component_name = ""
 SET calc_data->qual[17].components[4].number_units = 0
 SET calc_data->qual[18].description = "Body Surface Area (Mostellar)"
 SET calc_data->qual[18].description_key = cnvtupper(calc_data->qual[18].description)
 SET calc_data->qual[18].begin_age_nbr = 0
 SET calc_data->qual[18].begin_age_flag = 0
 SET calc_data->qual[18].end_age_nbr = 0
 SET calc_data->qual[18].end_age_flag = 0
 SET calc_data->qual[18].gender_cd = 0.0
 SET calc_data->qual[18].equation_display = "sqr((height * weight)/3600)"
 SET calc_data->qual[18].equation_meaning = ""
 SET calc_data->qual[18].equation_code = "SQR((A*B)/C)"
 SET calc_data->qual[18].active_ind = 1
 SET calc_data->qual[18].calcvalue_description = "Body Surface Area"
 SET calc_data->qual[18].number_components = 3
 SET calc_data->qual[18].components[1].component_flag = 1
 SET calc_data->qual[18].components[1].constant_value = 0
 SET calc_data->qual[18].components[1].component_label = "Patient Height"
 SET calc_data->qual[18].components[1].component_description = "height"
 SET calc_data->qual[18].components[1].event_cd = 0.0
 SET calc_data->qual[18].components[1].required_ind = 1
 SET calc_data->qual[18].components[1].corresponding_equation_id = 0.0
 SET calc_data->qual[18].components[1].component_code = "A"
 SET calc_data->qual[18].components[1].duplicate_component_name = ""
 SET calc_data->qual[18].components[1].number_units = 2
 SET calc_data->qual[18].components[1].unit_measure[1].unit_measure_meaning = "INCHES"
 SET calc_data->qual[18].components[1].unit_measure[1].default_ind = 1
 SET calc_data->qual[18].components[1].unit_measure[1].equation_dependent_unit_ind = 0
 SET calc_data->qual[18].components[1].unit_measure[2].unit_measure_meaning = "CM"
 SET calc_data->qual[18].components[1].unit_measure[2].default_ind = 0
 SET calc_data->qual[18].components[1].unit_measure[2].equation_dependent_unit_ind = 1
 SET calc_data->qual[18].components[2].component_flag = 1
 SET calc_data->qual[18].components[2].constant_value = 0
 SET calc_data->qual[18].components[2].component_label = "Patient Weight"
 SET calc_data->qual[18].components[2].component_description = "weight"
 SET calc_data->qual[18].components[2].event_cd = 0.0
 SET calc_data->qual[18].components[2].required_ind = 1
 SET calc_data->qual[18].components[2].corresponding_equation_id = 0.0
 SET calc_data->qual[18].components[2].component_code = "B"
 SET calc_data->qual[18].components[2].duplicate_component_name = ""
 SET calc_data->qual[18].components[2].number_units = 3
 SET calc_data->qual[18].components[2].unit_measure[1].unit_measure_meaning = "LB"
 SET calc_data->qual[18].components[2].unit_measure[1].default_ind = 1
 SET calc_data->qual[18].components[2].unit_measure[1].equation_dependent_unit_ind = 0
 SET calc_data->qual[18].components[2].unit_measure[2].unit_measure_meaning = "KG"
 SET calc_data->qual[18].components[2].unit_measure[2].default_ind = 0
 SET calc_data->qual[18].components[2].unit_measure[2].equation_dependent_unit_ind = 1
 SET calc_data->qual[18].components[2].unit_measure[3].unit_measure_meaning = "GM"
 SET calc_data->qual[18].components[2].unit_measure[3].default_ind = 0
 SET calc_data->qual[18].components[2].unit_measure[3].equation_dependent_unit_ind = 0
 SET calc_data->qual[18].components[3].component_flag = 2
 SET calc_data->qual[18].components[3].constant_value = 3600
 SET calc_data->qual[18].components[3].component_label = "(No Label)"
 SET calc_data->qual[18].components[3].component_description = "3600"
 SET calc_data->qual[18].components[3].event_cd = 0.0
 SET calc_data->qual[18].components[3].required_ind = 1
 SET calc_data->qual[18].components[3].corresponding_equation_id = 0.0
 SET calc_data->qual[18].components[3].component_code = "C"
 SET calc_data->qual[18].components[3].duplicate_component_name = ""
 SET calc_data->qual[18].components[3].number_units = 0
 SET calc_data->qual[19].description = "Celsius to Fahrenheit"
 SET calc_data->qual[19].description_key = cnvtupper(calc_data->qual[19].description)
 SET calc_data->qual[19].begin_age_nbr = 0
 SET calc_data->qual[19].begin_age_flag = 0
 SET calc_data->qual[19].end_age_nbr = 0
 SET calc_data->qual[19].end_age_flag = 0
 SET calc_data->qual[19].gender_cd = 0.0
 SET calc_data->qual[19].equation_display = "32 + ((9/5) * C)"
 SET calc_data->qual[19].equation_meaning = ""
 SET calc_data->qual[19].equation_code = "A+((B/C)*D)"
 SET calc_data->qual[19].active_ind = 1
 SET calc_data->qual[19].calcvalue_description = "Degrees Fahrenheit"
 SET calc_data->qual[19].number_components = 4
 SET calc_data->qual[19].components[1].component_flag = 2
 SET calc_data->qual[19].components[1].constant_value = 32
 SET calc_data->qual[19].components[1].component_label = "(No Label)"
 SET calc_data->qual[19].components[1].component_description = "32"
 SET calc_data->qual[19].components[1].event_cd = 0.0
 SET calc_data->qual[19].components[1].required_ind = 1
 SET calc_data->qual[19].components[1].corresponding_equation_id = 0.0
 SET calc_data->qual[19].components[1].component_code = "A"
 SET calc_data->qual[19].components[1].duplicate_component_name = ""
 SET calc_data->qual[19].components[1].number_units = 0
 SET calc_data->qual[19].components[2].component_flag = 2
 SET calc_data->qual[19].components[2].constant_value = 9
 SET calc_data->qual[19].components[2].component_label = "(No Label)"
 SET calc_data->qual[19].components[2].component_description = "9"
 SET calc_data->qual[19].components[2].event_cd = 0.0
 SET calc_data->qual[19].components[2].required_ind = 1
 SET calc_data->qual[19].components[2].corresponding_equation_id = 0.0
 SET calc_data->qual[19].components[2].component_code = "B"
 SET calc_data->qual[19].components[2].duplicate_component_name = ""
 SET calc_data->qual[19].components[2].number_units = 0
 SET calc_data->qual[19].components[3].component_flag = 2
 SET calc_data->qual[19].components[3].constant_value = 5
 SET calc_data->qual[19].components[3].component_label = "(No Label)"
 SET calc_data->qual[19].components[3].component_description = "5"
 SET calc_data->qual[19].components[3].event_cd = 0.0
 SET calc_data->qual[19].components[3].required_ind = 1
 SET calc_data->qual[19].components[3].corresponding_equation_id = 0.0
 SET calc_data->qual[19].components[3].component_code = "C"
 SET calc_data->qual[19].components[3].duplicate_component_name = ""
 SET calc_data->qual[19].components[3].number_units = 0
 SET calc_data->qual[19].components[4].component_flag = 1
 SET calc_data->qual[19].components[4].constant_value = 0
 SET calc_data->qual[19].components[4].component_label = "Degrees Celsius"
 SET calc_data->qual[19].components[4].component_description = "D"
 SET calc_data->qual[19].components[4].event_cd = 0.0
 SET calc_data->qual[19].components[4].required_ind = 1
 SET calc_data->qual[19].components[4].corresponding_equation_id = 0.0
 SET calc_data->qual[19].components[4].component_code = "D"
 SET calc_data->qual[19].components[4].duplicate_component_name = ""
 SET calc_data->qual[19].components[4].number_units = 0
 SET calc_data->qual[20].description = "Pounds to Kilograms"
 SET calc_data->qual[20].description_key = cnvtupper(calc_data->qual[20].description)
 SET calc_data->qual[20].begin_age_nbr = 0
 SET calc_data->qual[20].begin_age_flag = 0
 SET calc_data->qual[20].end_age_nbr = 0
 SET calc_data->qual[20].end_age_flag = 0
 SET calc_data->qual[20].gender_cd = 0.0
 SET calc_data->qual[20].equation_display = "Pounds / 2.2"
 SET calc_data->qual[20].equation_meaning = ""
 SET calc_data->qual[20].equation_code = "A/B"
 SET calc_data->qual[20].active_ind = 1
 SET calc_data->qual[20].calcvalue_description = "Weight in Kilograms"
 SET calc_data->qual[20].number_components = 2
 SET calc_data->qual[20].components[1].component_flag = 1
 SET calc_data->qual[20].components[1].constant_value = 0
 SET calc_data->qual[20].components[1].component_label = "Weight in Pounds"
 SET calc_data->qual[20].components[1].component_description = "Pounds"
 SET calc_data->qual[20].components[1].event_cd = 0.0
 SET calc_data->qual[20].components[1].required_ind = 1
 SET calc_data->qual[20].components[1].corresponding_equation_id = 0.0
 SET calc_data->qual[20].components[1].component_code = "A"
 SET calc_data->qual[20].components[1].duplicate_component_name = ""
 SET calc_data->qual[20].components[1].number_units = 0
 SET calc_data->qual[20].components[2].component_flag = 2
 SET calc_data->qual[20].components[2].constant_value = 2.2
 SET calc_data->qual[20].components[2].component_label = "(No Label)"
 SET calc_data->qual[20].components[2].component_description = "2.2"
 SET calc_data->qual[20].components[2].event_cd = 0.0
 SET calc_data->qual[20].components[2].required_ind = 1
 SET calc_data->qual[20].components[2].corresponding_equation_id = 0.0
 SET calc_data->qual[20].components[2].component_code = "B"
 SET calc_data->qual[20].components[2].duplicate_component_name = ""
 SET calc_data->qual[20].components[2].number_units = 0
 SET calc_data->qual[21].description = "Kilograms to Pounds"
 SET calc_data->qual[21].description_key = cnvtupper(calc_data->qual[21].description)
 SET calc_data->qual[21].begin_age_nbr = 0
 SET calc_data->qual[21].begin_age_flag = 0
 SET calc_data->qual[21].end_age_nbr = 0
 SET calc_data->qual[21].end_age_flag = 0
 SET calc_data->qual[21].gender_cd = 0.0
 SET calc_data->qual[21].equation_display = "kilograms * 2.2"
 SET calc_data->qual[21].equation_meaning = ""
 SET calc_data->qual[21].equation_code = "A*B"
 SET calc_data->qual[21].active_ind = 1
 SET calc_data->qual[21].calcvalue_description = "Weight in Pounds"
 SET calc_data->qual[21].number_components = 2
 SET calc_data->qual[21].components[1].component_flag = 1
 SET calc_data->qual[21].components[1].constant_value = 0
 SET calc_data->qual[21].components[1].component_label = "Weight in Kilograms"
 SET calc_data->qual[21].components[1].component_description = "kilograms"
 SET calc_data->qual[21].components[1].event_cd = 0.0
 SET calc_data->qual[21].components[1].required_ind = 1
 SET calc_data->qual[21].components[1].corresponding_equation_id = 0.0
 SET calc_data->qual[21].components[1].component_code = "A"
 SET calc_data->qual[21].components[1].duplicate_component_name = ""
 SET calc_data->qual[21].components[1].number_units = 0
 SET calc_data->qual[21].components[2].component_flag = 2
 SET calc_data->qual[21].components[2].constant_value = 2.2
 SET calc_data->qual[21].components[2].component_label = "(No Label)"
 SET calc_data->qual[21].components[2].component_description = "2.2"
 SET calc_data->qual[21].components[2].event_cd = 0.0
 SET calc_data->qual[21].components[2].required_ind = 1
 SET calc_data->qual[21].components[2].corresponding_equation_id = 0.0
 SET calc_data->qual[21].components[2].component_code = "B"
 SET calc_data->qual[21].components[2].duplicate_component_name = ""
 SET calc_data->qual[21].components[2].number_units = 0
 SET calc_data->qual[22].description = "Total Systemic Resistance"
 SET calc_data->qual[22].description_key = cnvtupper(calc_data->qual[22].description)
 SET calc_data->qual[22].begin_age_nbr = 0
 SET calc_data->qual[22].begin_age_flag = 0
 SET calc_data->qual[22].end_age_nbr = 0
 SET calc_data->qual[22].end_age_flag = 0
 SET calc_data->qual[22].gender_cd = 0.0
 SET calc_data->qual[22].equation_display = "MAP / CO"
 SET calc_data->qual[22].equation_meaning = ""
 SET calc_data->qual[22].equation_code = "A/B"
 SET calc_data->qual[22].active_ind = 1
 SET calc_data->qual[22].calcvalue_description = "Total Systemic Resistance"
 SET calc_data->qual[22].number_components = 2
 SET calc_data->qual[22].components[1].component_flag = 1
 SET calc_data->qual[22].components[1].constant_value = 0
 SET calc_data->qual[22].components[1].component_label = "Mean Arterial Pressure"
 SET calc_data->qual[22].components[1].component_description = "MAP"
 SET calc_data->qual[22].components[1].event_cd = 0.0
 SET calc_data->qual[22].components[1].required_ind = 1
 SET calc_data->qual[22].components[1].corresponding_equation_id = 0.0
 SET calc_data->qual[22].components[1].component_code = "A"
 SET calc_data->qual[22].components[1].duplicate_component_name = ""
 SET calc_data->qual[22].components[1].number_units = 0
 SET calc_data->qual[22].components[2].component_flag = 1
 SET calc_data->qual[22].components[2].constant_value = 0
 SET calc_data->qual[22].components[2].component_label = "Cardiac Output"
 SET calc_data->qual[22].components[2].component_description = "CO"
 SET calc_data->qual[22].components[2].event_cd = 0.0
 SET calc_data->qual[22].components[2].required_ind = 1
 SET calc_data->qual[22].components[2].corresponding_equation_id = 0.0
 SET calc_data->qual[22].components[2].component_code = "B"
 SET calc_data->qual[22].components[2].duplicate_component_name = ""
 SET calc_data->qual[22].components[2].number_units = 0
 SET calc_data->qual[23].description = "Coronary Perfusion Pressure"
 SET calc_data->qual[23].description_key = cnvtupper(calc_data->qual[23].description)
 SET calc_data->qual[23].begin_age_nbr = 0
 SET calc_data->qual[23].begin_age_flag = 0
 SET calc_data->qual[23].end_age_nbr = 0
 SET calc_data->qual[23].end_age_flag = 0
 SET calc_data->qual[23].gender_cd = 0.0
 SET calc_data->qual[23].equation_display = "Diastolic BP - PWP"
 SET calc_data->qual[23].equation_meaning = ""
 SET calc_data->qual[23].equation_code = "A - B"
 SET calc_data->qual[23].active_ind = 1
 SET calc_data->qual[23].calcvalue_description = "Coronary Perfusion Pressure"
 SET calc_data->qual[23].number_components = 2
 SET calc_data->qual[23].components[1].component_flag = 1
 SET calc_data->qual[23].components[1].constant_value = 0
 SET calc_data->qual[23].components[1].component_label = "Diastolic BP"
 SET calc_data->qual[23].components[1].component_description = "Diastolic BP"
 SET calc_data->qual[23].components[1].event_cd = 0.0
 SET calc_data->qual[23].components[1].required_ind = 1
 SET calc_data->qual[23].components[1].corresponding_equation_id = 0.0
 SET calc_data->qual[23].components[1].component_code = "A"
 SET calc_data->qual[23].components[1].duplicate_component_name = ""
 SET calc_data->qual[23].components[1].number_units = 0
 SET calc_data->qual[23].components[2].component_flag = 1
 SET calc_data->qual[23].components[2].constant_value = 0
 SET calc_data->qual[23].components[2].component_label = "Pulmonary Wedge Pressure"
 SET calc_data->qual[23].components[2].component_description = "PWP"
 SET calc_data->qual[23].components[2].event_cd = 0.0
 SET calc_data->qual[23].components[2].required_ind = 1
 SET calc_data->qual[23].components[2].corresponding_equation_id = 0.0
 SET calc_data->qual[23].components[2].component_code = "B"
 SET calc_data->qual[23].components[2].duplicate_component_name = ""
 SET calc_data->qual[23].components[2].number_units = 0
 SET calc_data->qual[24].description = "Total Pulmonary Resistance"
 SET calc_data->qual[24].description_key = cnvtupper(calc_data->qual[24].description)
 SET calc_data->qual[24].begin_age_nbr = 0
 SET calc_data->qual[24].begin_age_flag = 0
 SET calc_data->qual[24].end_age_nbr = 0
 SET calc_data->qual[24].end_age_flag = 0
 SET calc_data->qual[24].gender_cd = 0.0
 SET calc_data->qual[24].equation_display = "Mean PAP / CO"
 SET calc_data->qual[24].equation_meaning = ""
 SET calc_data->qual[24].equation_code = "A/B"
 SET calc_data->qual[24].active_ind = 1
 SET calc_data->qual[24].calcvalue_description = "Total Pulmonary Resistance"
 SET calc_data->qual[24].number_components = 2
 SET calc_data->qual[24].components[1].component_flag = 1
 SET calc_data->qual[24].components[1].constant_value = 0
 SET calc_data->qual[24].components[1].component_label = "Mean Pulmonary Artery Pressure"
 SET calc_data->qual[24].components[1].component_description = "Mean PAP"
 SET calc_data->qual[24].components[1].event_cd = 0.0
 SET calc_data->qual[24].components[1].required_ind = 1
 SET calc_data->qual[24].components[1].corresponding_equation_id = 0.0
 SET calc_data->qual[24].components[1].component_code = "A"
 SET calc_data->qual[24].components[1].duplicate_component_name = ""
 SET calc_data->qual[24].components[1].number_units = 0
 SET calc_data->qual[24].components[2].component_flag = 1
 SET calc_data->qual[24].components[2].constant_value = 0
 SET calc_data->qual[24].components[2].component_label = "Cardiac Output"
 SET calc_data->qual[24].components[2].component_description = "CO"
 SET calc_data->qual[24].components[2].event_cd = 0.0
 SET calc_data->qual[24].components[2].required_ind = 1
 SET calc_data->qual[24].components[2].corresponding_equation_id = 0.0
 SET calc_data->qual[24].components[2].component_code = "B"
 SET calc_data->qual[24].components[2].duplicate_component_name = ""
 SET calc_data->qual[24].components[2].number_units = 0
 SET calc_data->qual[25].description = "Pulmonary Vascular Resistance"
 SET calc_data->qual[25].description_key = cnvtupper(calc_data->qual[25].description)
 SET calc_data->qual[25].begin_age_nbr = 0
 SET calc_data->qual[25].begin_age_flag = 0
 SET calc_data->qual[25].end_age_nbr = 0
 SET calc_data->qual[25].end_age_flag = 0
 SET calc_data->qual[25].gender_cd = 0.0
 SET calc_data->qual[25].equation_display = "((Mean PAP - PWP)/CO) * 80"
 SET calc_data->qual[25].equation_meaning = ""
 SET calc_data->qual[25].equation_code = "((A-B)/C)*D"
 SET calc_data->qual[25].active_ind = 1
 SET calc_data->qual[25].calcvalue_description = "Pulmonary Vascular Resistance"
 SET calc_data->qual[25].number_components = 4
 SET calc_data->qual[25].components[1].component_flag = 1
 SET calc_data->qual[25].components[1].constant_value = 0
 SET calc_data->qual[25].components[1].component_label = "Mean PAP"
 SET calc_data->qual[25].components[1].component_description = "Mean PAP"
 SET calc_data->qual[25].components[1].event_cd = 0.0
 SET calc_data->qual[25].components[1].required_ind = 1
 SET calc_data->qual[25].components[1].corresponding_equation_id = 0.0
 SET calc_data->qual[25].components[1].component_code = "A"
 SET calc_data->qual[25].components[1].duplicate_component_name = ""
 SET calc_data->qual[25].components[1].number_units = 0
 SET calc_data->qual[25].components[2].component_flag = 1
 SET calc_data->qual[25].components[2].constant_value = 0
 SET calc_data->qual[25].components[2].component_label = "Pulmonary Wedge Pressure"
 SET calc_data->qual[25].components[2].component_description = "PWP"
 SET calc_data->qual[25].components[2].event_cd = 0.0
 SET calc_data->qual[25].components[2].required_ind = 1
 SET calc_data->qual[25].components[2].corresponding_equation_id = 0.0
 SET calc_data->qual[25].components[2].component_code = "B"
 SET calc_data->qual[25].components[2].duplicate_component_name = ""
 SET calc_data->qual[25].components[2].number_units = 0
 SET calc_data->qual[25].components[3].component_flag = 1
 SET calc_data->qual[25].components[3].constant_value = 0
 SET calc_data->qual[25].components[3].component_label = "Cardiac Output"
 SET calc_data->qual[25].components[3].component_description = "CO"
 SET calc_data->qual[25].components[3].event_cd = 0.0
 SET calc_data->qual[25].components[3].required_ind = 1
 SET calc_data->qual[25].components[3].corresponding_equation_id = 0.0
 SET calc_data->qual[25].components[3].component_code = "C"
 SET calc_data->qual[25].components[3].duplicate_component_name = ""
 SET calc_data->qual[25].components[3].number_units = 0
 SET calc_data->qual[25].components[4].component_flag = 2
 SET calc_data->qual[25].components[4].constant_value = 80
 SET calc_data->qual[25].components[4].component_label = "(No Label)"
 SET calc_data->qual[25].components[4].component_description = "80"
 SET calc_data->qual[25].components[4].event_cd = 0.0
 SET calc_data->qual[25].components[4].required_ind = 1
 SET calc_data->qual[25].components[4].corresponding_equation_id = 0.0
 SET calc_data->qual[25].components[4].component_code = "D"
 SET calc_data->qual[25].components[4].duplicate_component_name = ""
 SET calc_data->qual[25].components[4].number_units = 0
 SET calc_data->qual[26].description = "System Vascular Resistance"
 SET calc_data->qual[26].description_key = cnvtupper(calc_data->qual[26].description)
 SET calc_data->qual[26].begin_age_nbr = 0
 SET calc_data->qual[26].begin_age_flag = 0
 SET calc_data->qual[26].end_age_nbr = 0
 SET calc_data->qual[26].end_age_flag = 0
 SET calc_data->qual[26].gender_cd = 0.0
 SET calc_data->qual[26].equation_display = "((MAP - Mean RAP)/CO) * 80"
 SET calc_data->qual[26].equation_meaning = ""
 SET calc_data->qual[26].equation_code = "((A-B)/C)*D"
 SET calc_data->qual[26].active_ind = 1
 SET calc_data->qual[26].calcvalue_description = "System Vascular Resistance"
 SET calc_data->qual[26].number_components = 4
 SET calc_data->qual[26].components[1].component_flag = 1
 SET calc_data->qual[26].components[1].constant_value = 0
 SET calc_data->qual[26].components[1].component_label = "Mean Arterial Pressure"
 SET calc_data->qual[26].components[1].component_description = "MAP"
 SET calc_data->qual[26].components[1].event_cd = 0.0
 SET calc_data->qual[26].components[1].required_ind = 1
 SET calc_data->qual[26].components[1].corresponding_equation_id = 0.0
 SET calc_data->qual[26].components[1].component_code = "A"
 SET calc_data->qual[26].components[1].duplicate_component_name = ""
 SET calc_data->qual[26].components[1].number_units = 0
 SET calc_data->qual[26].components[2].component_flag = 1
 SET calc_data->qual[26].components[2].constant_value = 0
 SET calc_data->qual[26].components[2].component_label = "Mean Right Atrial Pressure"
 SET calc_data->qual[26].components[2].component_description = "Mean RAP"
 SET calc_data->qual[26].components[2].event_cd = 0.0
 SET calc_data->qual[26].components[2].required_ind = 1
 SET calc_data->qual[26].components[2].corresponding_equation_id = 0.0
 SET calc_data->qual[26].components[2].component_code = "B"
 SET calc_data->qual[26].components[2].duplicate_component_name = ""
 SET calc_data->qual[26].components[2].number_units = 0
 SET calc_data->qual[26].components[3].component_flag = 1
 SET calc_data->qual[26].components[3].constant_value = 0
 SET calc_data->qual[26].components[3].component_label = "Cardiac Output"
 SET calc_data->qual[26].components[3].component_description = "CO"
 SET calc_data->qual[26].components[3].event_cd = 0.0
 SET calc_data->qual[26].components[3].required_ind = 1
 SET calc_data->qual[26].components[3].corresponding_equation_id = 0.0
 SET calc_data->qual[26].components[3].component_code = "C"
 SET calc_data->qual[26].components[3].duplicate_component_name = ""
 SET calc_data->qual[26].components[3].number_units = 0
 SET calc_data->qual[26].components[4].component_flag = 2
 SET calc_data->qual[26].components[4].constant_value = 80
 SET calc_data->qual[26].components[4].component_label = "(No Label)"
 SET calc_data->qual[26].components[4].component_description = "80"
 SET calc_data->qual[26].components[4].event_cd = 0.0
 SET calc_data->qual[26].components[4].required_ind = 1
 SET calc_data->qual[26].components[4].corresponding_equation_id = 0.0
 SET calc_data->qual[26].components[4].component_code = "D"
 SET calc_data->qual[26].components[4].duplicate_component_name = ""
 SET calc_data->qual[26].components[4].number_units = 0
 SET calc_data->qual[27].description = "mcg/min"
 SET calc_data->qual[27].description_key = cnvtupper(calc_data->qual[27].description)
 SET calc_data->qual[27].begin_age_nbr = 0
 SET calc_data->qual[27].begin_age_flag = 0
 SET calc_data->qual[27].end_age_nbr = 0
 SET calc_data->qual[27].end_age_flag = 0
 SET calc_data->qual[27].gender_cd = 0.0
 SET calc_data->qual[27].equation_display = "(cc * concentration of drip)/60"
 SET calc_data->qual[27].equation_meaning = ""
 SET calc_data->qual[27].equation_code = "(A*B)/C"
 SET calc_data->qual[27].active_ind = 1
 SET calc_data->qual[27].calcvalue_description = "mcg/min"
 SET calc_data->qual[27].number_components = 3
 SET calc_data->qual[27].components[1].component_flag = 1
 SET calc_data->qual[27].components[1].constant_value = 0
 SET calc_data->qual[27].components[1].component_label = "cc/hr"
 SET calc_data->qual[27].components[1].component_description = "cc"
 SET calc_data->qual[27].components[1].event_cd = 0.0
 SET calc_data->qual[27].components[1].required_ind = 1
 SET calc_data->qual[27].components[1].corresponding_equation_id = 0.0
 SET calc_data->qual[27].components[1].component_code = "A"
 SET calc_data->qual[27].components[1].duplicate_component_name = ""
 SET calc_data->qual[27].components[1].number_units = 0
 SET calc_data->qual[27].components[2].component_flag = 4
 SET calc_data->qual[27].components[2].constant_value = 0
 SET calc_data->qual[27].components[2].component_label = "concentration of drip"
 SET calc_data->qual[27].components[2].component_description = "concentration of drip"
 SET calc_data->qual[27].components[2].event_cd = 0.0
 SET calc_data->qual[27].components[2].required_ind = 1
 SET calc_data->qual[27].components[2].corresponding_equation_id = 0.0
 SET calc_data->qual[27].components[2].component_code = "B"
 SET calc_data->qual[27].components[2].duplicate_component_name = ""
 SET calc_data->qual[27].components[2].number_units = 2
 SET calc_data->qual[27].components[2].unit_measure[1].unit_measure_meaning = "MG/CC"
 SET calc_data->qual[27].components[2].unit_measure[1].default_ind = 0
 SET calc_data->qual[27].components[2].unit_measure[1].equation_dependent_unit_ind = 0
 SET calc_data->qual[27].components[2].unit_measure[2].unit_measure_meaning = "MCG/CC"
 SET calc_data->qual[27].components[2].unit_measure[2].default_ind = 1
 SET calc_data->qual[27].components[2].unit_measure[2].equation_dependent_unit_ind = 1
 SET calc_data->qual[27].components[3].component_flag = 2
 SET calc_data->qual[27].components[3].constant_value = 60
 SET calc_data->qual[27].components[3].component_label = "(No Label)"
 SET calc_data->qual[27].components[3].component_description = "60"
 SET calc_data->qual[27].components[3].event_cd = 0.0
 SET calc_data->qual[27].components[3].required_ind = 1
 SET calc_data->qual[27].components[3].corresponding_equation_id = 0.0
 SET calc_data->qual[27].components[3].component_code = "C"
 SET calc_data->qual[27].components[3].duplicate_component_name = ""
 SET calc_data->qual[27].components[3].number_units = 0
 SET calc_data->qual[28].description = "Inches to Centimeters"
 SET calc_data->qual[28].description_key = cnvtupper(calc_data->qual[28].description)
 SET calc_data->qual[28].begin_age_nbr = 0
 SET calc_data->qual[28].begin_age_flag = 0
 SET calc_data->qual[28].end_age_nbr = 0
 SET calc_data->qual[28].end_age_flag = 0
 SET calc_data->qual[28].gender_cd = 0.0
 SET calc_data->qual[28].equation_display = "Inches * 2.54"
 SET calc_data->qual[28].equation_meaning = ""
 SET calc_data->qual[28].equation_code = "A*B"
 SET calc_data->qual[28].active_ind = 1
 SET calc_data->qual[28].calcvalue_description = "Centimeters"
 SET calc_data->qual[28].number_components = 2
 SET calc_data->qual[28].components[1].component_flag = 1
 SET calc_data->qual[28].components[1].constant_value = 0
 SET calc_data->qual[28].components[1].component_label = "Inches"
 SET calc_data->qual[28].components[1].component_description = "Inches"
 SET calc_data->qual[28].components[1].event_cd = 0.0
 SET calc_data->qual[28].components[1].required_ind = 1
 SET calc_data->qual[28].components[1].corresponding_equation_id = 0.0
 SET calc_data->qual[28].components[1].component_code = "A"
 SET calc_data->qual[28].components[1].duplicate_component_name = ""
 SET calc_data->qual[28].components[1].number_units = 0
 SET calc_data->qual[28].components[2].component_flag = 2
 SET calc_data->qual[28].components[2].constant_value = 2.54
 SET calc_data->qual[28].components[2].component_label = "(No Label)"
 SET calc_data->qual[28].components[2].component_description = "2.54"
 SET calc_data->qual[28].components[2].event_cd = 0.0
 SET calc_data->qual[28].components[2].required_ind = 1
 SET calc_data->qual[28].components[2].corresponding_equation_id = 0.0
 SET calc_data->qual[28].components[2].component_code = "B"
 SET calc_data->qual[28].components[2].duplicate_component_name = ""
 SET calc_data->qual[28].components[2].number_units = 0
 SET calc_data->qual[29].description = "Centimeters to Inches"
 SET calc_data->qual[29].description_key = cnvtupper(calc_data->qual[29].description)
 SET calc_data->qual[29].begin_age_nbr = 0
 SET calc_data->qual[29].begin_age_flag = 0
 SET calc_data->qual[29].end_age_nbr = 0
 SET calc_data->qual[29].end_age_flag = 0
 SET calc_data->qual[29].gender_cd = 0.0
 SET calc_data->qual[29].equation_display = "Centimeters /2.54"
 SET calc_data->qual[29].equation_meaning = ""
 SET calc_data->qual[29].equation_code = "A/B"
 SET calc_data->qual[29].active_ind = 1
 SET calc_data->qual[29].calcvalue_description = "Inches"
 SET calc_data->qual[29].number_components = 2
 SET calc_data->qual[29].components[1].component_flag = 1
 SET calc_data->qual[29].components[1].constant_value = 0
 SET calc_data->qual[29].components[1].component_label = "Centimeters"
 SET calc_data->qual[29].components[1].component_description = "Centimeters"
 SET calc_data->qual[29].components[1].event_cd = 0.0
 SET calc_data->qual[29].components[1].required_ind = 1
 SET calc_data->qual[29].components[1].corresponding_equation_id = 0.0
 SET calc_data->qual[29].components[1].component_code = "A"
 SET calc_data->qual[29].components[1].duplicate_component_name = ""
 SET calc_data->qual[29].components[1].number_units = 0
 SET calc_data->qual[29].components[2].component_flag = 2
 SET calc_data->qual[29].components[2].constant_value = 2.54
 SET calc_data->qual[29].components[2].component_label = "(No Label)"
 SET calc_data->qual[29].components[2].component_description = "2.54"
 SET calc_data->qual[29].components[2].event_cd = 0.0
 SET calc_data->qual[29].components[2].required_ind = 1
 SET calc_data->qual[29].components[2].corresponding_equation_id = 0.0
 SET calc_data->qual[29].components[2].component_code = "B"
 SET calc_data->qual[29].components[2].duplicate_component_name = ""
 SET calc_data->qual[29].components[2].number_units = 0
 SET new_equa_cnt = size(calc_data->qual,5)
 FOR (x = 1 TO new_equa_cnt)
   SELECT INTO "nl:"
    tmpy = seq(reference_seq,nextval)
    FROM dual
    DETAIL
     new_equa_id = tmpy
    WITH format, nocounter
   ;end select
   INSERT  FROM dcp_equation d
    SET d.seq = 1, d.dcp_equation_id = new_equa_id, d.description = calc_data->qual[x].description,
     d.description_key = calc_data->qual[x].description_key, d.begin_age_nbr = calc_data->qual[x].
     begin_age_nbr, d.begin_age_flag = calc_data->qual[x].begin_age_flag,
     d.end_age_nbr = calc_data->qual[x].end_age_nbr, d.end_age_flag = calc_data->qual[x].end_age_flag,
     d.gender_cd = calc_data->qual[x].gender_cd,
     d.equation_display = calc_data->qual[x].equation_display, d.equation_meaning = calc_data->qual[x
     ].equation_meaning, d.equation_code = calc_data->qual[x].equation_code,
     d.active_ind = calc_data->qual[x].active_ind, d.calcvalue_description = calc_data->qual[x].
     calcvalue_description, d.updt_dt_tm = cnvtdatetime(curdate,curtime),
     d.updt_id = 0, d.updt_task = 0, d.updt_applctx = 0,
     d.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF ((calc_data->qual[x].number_components > 0))
    FOR (y = 1 TO calc_data->qual[x].number_components)
      SELECT INTO "nl:"
       tmpz = seq(reference_seq,nextval)
       FROM dual
       DETAIL
        new_comp_id = tmpz
       WITH format, nocounter
      ;end select
      INSERT  FROM dcp_equa_component d
       SET d.seq = 1, d.dcp_equation_id = new_equa_id, d.dcp_component_id = new_comp_id,
        d.component_flag = calc_data->qual[x].components[y].component_flag, d.constant_value =
        calc_data->qual[x].components[y].constant_value, d.component_label = calc_data->qual[x].
        components[y].component_label,
        d.component_description = calc_data->qual[x].components[y].component_description, d.event_cd
         = calc_data->qual[x].components[y].event_cd, d.required_ind = calc_data->qual[x].components[
        y].required_ind,
        d.corresponding_equation_id = calc_data->qual[x].components[y].corresponding_equation_id, d
        .component_code = calc_data->qual[x].components[y].component_code, d.duplicate_component_name
         = calc_data->qual[x].components[y].duplicate_component_name,
        d.updt_dt_tm = cnvtdatetime(curdate,curtime), d.updt_id = 0, d.updt_task = 0,
        d.updt_applctx = 0, d.updt_cnt = 0
       WITH nocounter
      ;end insert
      IF ((calc_data->qual[x].components[y].number_units > 0))
       INSERT  FROM dcp_unit_measure d,
         (dummyt d1  WITH seq = value(calc_data->qual[x].components[y].number_units))
        SET d.seq = 1, d.dcp_component_id = new_comp_id, d.dcp_equation_id = new_equa_id,
         temp_unit_cd = d1.seq, d.unit_measure_cd = temp_unit_cd, d.unit_measure_meaning = calc_data
         ->qual[x].components[y].unit_measure[d1.seq].unit_measure_meaning,
         d.default_ind = calc_data->qual[x].components[y].unit_measure[d1.seq].default_ind, d
         .equation_dependent_unit_ind = calc_data->qual[x].components[y].unit_measure[d1.seq].
         equation_dependent_unit_ind, d.updt_dt_tm = cnvtdatetime(curdate,curtime),
         d.updt_id = reqinfo->updt_id, d.updt_task = reqinfo->updt_task, d.updt_applctx = reqinfo->
         updt_applctx,
         d.updt_cnt = 0
        PLAN (d1)
         JOIN (d
         WHERE (calc_data->qual[x].components[y].unit_measure[d1.seq].unit_measure_cd > 0))
        WITH nocounter
       ;end insert
      ENDIF
    ENDFOR
   ENDIF
 ENDFOR
 SET temp_unit_cd = 0
 SELECT INTO "nl:"
  c.code_set
  FROM code_value c
  WHERE c.code_set=88
   AND c.active_ind=1
  DETAIL
   pos_cnt = (pos_cnt+ 1)
   IF (pos_cnt > size(internal->positions,5))
    stat = alterlist(internal->positions,(pos_cnt+ 10))
   ENDIF
   internal->positions[pos_cnt].position_cd = c.code_value
  WITH nocounter
 ;end select
 SET stat = alterlist(internal->positions,pos_cnt)
 SELECT INTO "nl:"
  FROM code_value c
  WHERE c.code_set=54
   AND c.active_ind=1
   AND c.cdf_meaning > ""
  DETAIL
   uom_cnt = (uom_cnt+ 1)
   IF (uom_cnt > size(internal->units,5))
    stat = alterlist(internal->units,(uom_cnt+ 10))
   ENDIF
   internal->units[uom_cnt].unit_measure_cd = c.code_value, internal->units[uom_cnt].
   unit_measure_meaning = c.cdf_meaning
  WITH nocounter
 ;end select
 SET stat = alterlist(internal->units,uom_cnt)
 SELECT INTO "nl:"
  de.dcp_equation_id, dec.dcp_component_id, dum.unit_measure_meaning,
  check = decode(dum.seq,"dum",dec.seq,"dec",de.seq,
   "de","z")
  FROM dcp_equation de,
   (dummyt d1  WITH seq = 1),
   dcp_equa_component dec,
   (dummyt d2  WITH seq = 1),
   dcp_unit_measure dum
  PLAN (de
   WHERE de.dcp_equation_id > 0.0)
   JOIN (d1)
   JOIN (dec
   WHERE dec.dcp_equation_id=de.dcp_equation_id)
   JOIN (d2)
   JOIN (dum
   WHERE dum.dcp_component_id=dec.dcp_component_id)
  ORDER BY de.dcp_equation_id, dec.dcp_component_id
  HEAD REPORT
   equa_cnt = 0
  HEAD de.dcp_equation_id
   equa_cnt = (equa_cnt+ 1)
   IF (equa_cnt > size(internal->equations,5))
    stat = alterlist(internal->equations,(equa_cnt+ 5))
   ENDIF
   internal->equations[equa_cnt].dcp_equation_id = de.dcp_equation_id, comp_cnt = 0
  HEAD dec.dcp_component_id
   comp_cnt = (comp_cnt+ 1)
   IF (comp_cnt > size(internal->equations[equa_cnt].components,5))
    stat = alterlist(internal->equations[equa_cnt].components,(comp_cnt+ 10))
   ENDIF
   internal->equations[equa_cnt].components[comp_cnt].dcp_component_id = dec.dcp_component_id,
   unit_cnt = 0
  DETAIL
   IF (check="dum")
    unit_cnt = (unit_cnt+ 1)
    IF (unit_cnt > size(internal->equations[equa_cnt].components[comp_cnt].units,5))
     stat = alterlist(internal->equations[equa_cnt].components[comp_cnt].units,(unit_cnt+ 10))
    ENDIF
    internal->equations[equa_cnt].components[comp_cnt].units[unit_cnt].unit_measure_meaning = dum
    .unit_measure_meaning
   ENDIF
  FOOT  dec.dcp_component_id
   stat = alterlist(internal->equations[equa_cnt].components[comp_cnt].units,unit_cnt), internal->
   equations[equa_cnt].components[comp_cnt].number_units = unit_cnt
  FOOT  de.dcp_equation_id
   stat = alterlist(internal->equations[equa_cnt].components,comp_cnt), internal->equations[equa_cnt]
   .number_components = comp_cnt
  FOOT REPORT
   stat = alterlist(internal->equations,equa_cnt)
  WITH check, outerjoin = d1, outerjoin = d2
 ;end select
 FOR (x = 1 TO equa_cnt)
   INSERT  FROM dcp_equa_position dep,
     (dummyt d1  WITH seq = value(pos_cnt))
    SET dep.seq = 1, dep.dcp_equation_id = internal->equations[x].dcp_equation_id, dep.position_cd =
     internal->positions[d1.seq].position_cd,
     dep.updt_dt_tm = cnvtdatetime(curdate,curtime), dep.updt_id = 0, dep.updt_task = 0,
     dep.updt_applctx = 0, dep.updt_cnt = 0
    PLAN (d1)
     JOIN (dep)
    WITH nocounter
   ;end insert
 ENDFOR
 FOR (x = 1 TO equa_cnt)
   FOR (y = 1 TO internal->equations[x].number_components)
     IF ((internal->equations[x].components[y].number_units > 0))
      FOR (z = 1 TO internal->equations[x].components[y].number_units)
        SET temp_unit_meaning = internal->equations[x].components[y].units[z].unit_measure_meaning
        FOR (a = 1 TO uom_cnt)
          IF ((temp_unit_meaning=internal->units[a].unit_measure_meaning))
           SET temp_unit_cd = internal->units[a].unit_measure_cd
          ENDIF
        ENDFOR
        UPDATE  FROM dcp_unit_measure dum
         SET dum.unit_measure_cd = temp_unit_cd
         WHERE (dum.dcp_component_id=internal->equations[x].components[y].dcp_component_id)
          AND dum.unit_measure_meaning=temp_unit_meaning
         WITH nocounter
        ;end update
      ENDFOR
     ENDIF
     SET temp_unit_cd = 0
     SET temp_unit_meaning = ""
   ENDFOR
 ENDFOR
 COMMIT
#exit_script
END GO
