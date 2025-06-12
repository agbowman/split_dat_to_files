CREATE PROGRAM ams_add_dtawizard_dtainfo:dba
 PROMPT
  "Save your inputs in any of the CSV file in any of the below directories" = "MINE",
  "Directory" = "",
  "Input File" = ""
  WITH outdev, directory, inputfile
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 DECLARE serrmsg = vc WITH protect, noconstant("")
 DECLARE ierrcode = i2 WITH protect, noconstant(0)
 DECLARE bamsassociate = i2 WITH protect, noconstant(false)
 DECLARE smessage = vc WITH protect, noconstant("")
 FREE RECORD rdata
 RECORD rdata(
   1 qual_knt = i4
   1 qual[*]
     2 object_name = vc
     2 user_name = vc
     2 compiled_dt_tm = vc
     2 source_name = vc
 )
 EXECUTE ams_define_toolkit_common
 SET bamsassociate = isamsuser(reqinfo->updt_id)
 IF ( NOT (bamsassociate))
  SET failed = exe_error
  SET serrmsg = "User must be a Cerner AMS associate to run this program from Explorer Menu"
  GO TO exit_script
 ENDIF
 SET path = value(logical( $DIRECTORY))
 SET infile =  $INPUTFILE
 SET file_path = build(path,":",infile)
 CALL echo(build(path,":",infile))
 CALL echo(file_path)
 DEFINE rtl2 value(file_path)
 FREE RECORD orig_content
 RECORD orig_content(
   1 rec[*]
     2 dta_mnemonic = vc
     2 description = vc
     2 activity_type = vc
     2 result_type = vc
     2 numeric_max = vc
     2 numeric_min = vc
     2 decimal = vc
     2 use_modifier = vc
     2 first_alpha_single = vc
     2 witness_required = vc
     2 code_set = vc
     2 asso_event = vc
     2 asso_concept_cki = vc
     2 default_type = vc
     2 intake_output = vc
     2 look_back_min_res = vc
     2 look_back_min_bmdi = vc
     2 look_forward_min_bmdi = vc
     2 sex = vc
     2 start_age = vc
     2 start_units = vc
     2 end_age = vc
     2 end_units = vc
     2 min_back = vc
     2 flex_rule = vc
     2 del = vc
     2 normal_low = vc
     2 normal_high = vc
     2 critical_low = vc
     2 critical_high = vc
     2 feasible_low = vc
     2 feasible_high = vc
     2 review_low = vc
     2 review_high = vc
     2 linear_low = vc
     2 linear_high = vc
     2 ref_default_val = vc
     2 uom = vc
     2 alpha_description = vc
     2 sequence = vc
     2 res_val = vc
     2 concept_cki = vc
     2 truth_state = vc
     2 grid_disp = vc
     2 alpha_default = vc
 )
 FREE SET file_content
 RECORD file_content(
   1 qual[*]
     2 mnemonic = vc
     2 description = vc
     2 activity_type_cd = vc
     2 event_cd = vc
     2 modifier_ind = i2
     2 default_type_flag = i2
     2 single_select_ind = i2
     2 default_result_type_cd = vc
     2 build_event_cd_ind = i2
     2 code_set = f8
     2 max_digits = i4
     2 min_digits = i4
     2 min_decimal_places = i4
     2 ref_range_cnt = i4
     2 ref_range[*]
       3 ref_id = f8
       3 service_resource_cd = f8
       3 species_cd = f8
       3 organism_cd = f8
       3 sex_cd = vc
       3 unknown_age_ind = f8
       3 age_from_units_cd = vc
       3 age_from_minutes = i4
       3 age_to_units_cd = vc
       3 age_to_minutes = i4
       3 specimen_type_cd = f8
       3 patient_condition_cd = f8
       3 def_result_ind = i2
       3 default_result = f8
       3 dilute_ind = i2
       3 review_ind = i2
       3 review_low = f8
       3 review_high = f8
       3 feasible_ind = i2
       3 feasible_low = f8
       3 feasible_high = f8
       3 linear_ind = i2
       3 linear_low = f8
       3 linear_high = f8
       3 normal_ind = i2
       3 normal_low = f8
       3 normal_high = f8
       3 critical_ind = i2
       3 critical_low = f8
       3 critical_high = f8
       3 delta_check_type_cd = f8
       3 delta_minutes = f8
       3 delta_value = f8
       3 delta_chk_flag = i2
       3 delta_lvl_flag = i2
       3 mins_back = f8
       3 resource_ref_flag = i2
       3 gestational_ind = i2
       3 precedence_sequence = i4
       3 units_cd = vc
       3 alpha_cnt = i4
       3 alpha[*]
         4 nomenclature_id = f8
         4 sequence = i4
         4 use_units_ind = i2
         4 default_ind = i2
         4 description = vc
         4 multi_alpha_sort_order = i4
         4 result_value = f8
         4 category_id = f8
         4 concept_cki = vc
         4 truth_state_cd = vc
       3 categories[*]
         4 mod = i2
         4 category_id = f8
         4 placeholder_category_id = f8
         4 category_name = vc
         4 category_sequence = i4
         4 expand_flag = i2
       3 rule_ind = i2
       3 rule_cnt = i4
       3 rule[*]
         4 rule_id = f8
         4 gestational_age_ind = i2
         4 gestation_from_age_in_days = i4
         4 gestation_to_age_in_days = i4
         4 from_weight = i4
         4 to_weight = i4
         4 from_weight_unit_cd = f8
         4 to_weight_unit_cd = f8
         4 from_height = i4
         4 to_height = i4
         4 from_height_unit_cd = f8
         4 to_height_unit_cd = f8
         4 location_cd = f8
         4 feasible_ind = i2
         4 feasible_low = f8
         4 feasible_high = f8
         4 normal_ind = i2
         4 normal_low = f8
         4 normal_high = f8
         4 critical_ind = i2
         4 critical_low = f8
         4 critical_high = f8
         4 def_result_ind = i2
         4 default_result = f8
         4 units_cd = f8
         4 alpha_rule_cnt = i4
         4 alpha_rule[*]
           5 nomenclature_id = f8
     2 io_flag = i2
     2 template_script_cd = f8
     2 concept_cki = vc
     2 offset_min_cnt = i4
     2 offset_mins[*]
       3 offset_min_type = vc
       3 offset_min_nbr = i4
     2 witness_required_ind = i2
 )
 SELECT INTO  $1
  r.line
  FROM rtl2t r
  HEAD REPORT
   row_count = 0, check = 0, count = 0
  HEAD r.line
   line1 = r.line, check = (check+ 1)
   IF (check > 2)
    IF (textlen(trim(replace(line1,",",""),3)) > 0)
     count = (count+ 1)
     IF (count >= 1)
      row_count = (row_count+ 1), stat = alterlist(orig_content->rec,row_count), orig_content->rec[
      row_count].dta_mnemonic = piece(line1,",",1,"Not Found"),
      orig_content->rec[row_count].description = piece(line1,",",2,"Not Found"), orig_content->rec[
      row_count].activity_type = piece(line1,",",3,"Not Found"), orig_content->rec[row_count].
      result_type = piece(line1,",",4,"Not Found"),
      orig_content->rec[row_count].numeric_max = piece(line1,",",5,"Not Found"), orig_content->rec[
      row_count].numeric_min = piece(line1,",",6,"Not Found"), orig_content->rec[row_count].decimal
       = piece(line1,",",7,"Not Found"),
      orig_content->rec[row_count].use_modifier = piece(line1,",",8,"Not Found"), orig_content->rec[
      row_count].first_alpha_single = piece(line1,",",9,"Not Found"), orig_content->rec[row_count].
      witness_required = piece(line1,",",10,"Not Found"),
      orig_content->rec[row_count].code_set = piece(line1,",",11,"Not Found"), orig_content->rec[
      row_count].asso_event = piece(line1,",",12,"Not Found"), orig_content->rec[row_count].
      asso_concept_cki = piece(line1,",",13,"Not Found"),
      orig_content->rec[row_count].default_type = piece(line1,",",14,"Not Found"), orig_content->rec[
      row_count].intake_output = piece(line1,",",15,"Not Found"), orig_content->rec[row_count].
      look_back_min_res = piece(line1,",",16,"Not Found"),
      orig_content->rec[row_count].look_back_min_bmdi = piece(line1,",",17,"Not Found"), orig_content
      ->rec[row_count].look_forward_min_bmdi = piece(line1,",",18,"Not Found"), orig_content->rec[
      row_count].sex = piece(line1,",",19,"Not Found"),
      orig_content->rec[row_count].start_age = piece(line1,",",20,"Not Found"), orig_content->rec[
      row_count].start_units = piece(line1,",",21,"Not Found"), orig_content->rec[row_count].end_age
       = piece(line1,",",22,"Not Found"),
      orig_content->rec[row_count].end_units = piece(line1,",",23,"Not Found"), orig_content->rec[
      row_count].min_back = piece(line1,",",24,"Not Found"), orig_content->rec[row_count].flex_rule
       = piece(line1,",",25,"Not Found"),
      orig_content->rec[row_count].normal_low = piece(line1,",",26,"Not Found"), orig_content->rec[
      row_count].normal_high = piece(line1,",",27,"Not Found"), orig_content->rec[row_count].
      critical_low = piece(line1,",",28,"Not Found"),
      orig_content->rec[row_count].critical_high = piece(line1,",",29,"Not Found"), orig_content->
      rec[row_count].feasible_low = piece(line1,",",30,"Not Found"), orig_content->rec[row_count].
      feasible_high = piece(line1,",",31,"Not Found"),
      orig_content->rec[row_count].review_low = piece(line1,",",32,"Not Found"), orig_content->rec[
      row_count].review_high = piece(line1,",",33,"Not Found"), orig_content->rec[row_count].
      linear_low = piece(line1,",",34,"Not Found"),
      orig_content->rec[row_count].linear_high = piece(line1,",",35,"Not Found"), orig_content->rec[
      row_count].ref_default_val = piece(line1,",",36,"Not Found"), orig_content->rec[row_count].uom
       = piece(line1,",",37,"Not Found"),
      orig_content->rec[row_count].alpha_description = piece(line1,",",38,"Not Found"), orig_content
      ->rec[row_count].sequence = piece(line1,",",39,"Not Found"), orig_content->rec[row_count].
      res_val = piece(line1,",",40,"Not Found"),
      orig_content->rec[row_count].concept_cki = piece(line1,",",41,"Not Found"), orig_content->rec[
      row_count].truth_state = piece(line1,",",42,"Not Found"), orig_content->rec[row_count].
      grid_disp = piece(line1,",",43,"Not Found"),
      orig_content->rec[row_count].alpha_default = piece(line1,",",44,"Not Found")
     ENDIF
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(orig_content->rec,row_count)
  WITH nocounter, format, separator = ""
 ;end select
 SET row_count = 0
 SET ref_count = 0
 SET off_cnt = 0
 FOR (i = 1 TO size(orig_content->rec,5))
   IF ((orig_content->rec[i].dta_mnemonic != ""))
    SET row_count = (row_count+ 1)
    SET ref_count = 0
    SET alpha_count = 0
    SET off_cnt = 0
    SET stat = alterlist(file_content->qual,row_count)
    SET file_content->qual[row_count].mnemonic = orig_content->rec[i].dta_mnemonic
    SET file_content->qual[row_count].description = orig_content->rec[i].description
    SET file_content->qual[row_count].activity_type_cd = cnvtupper(trim(replace(replace(replace(
         replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                    replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                              replace(replace(replace(replace(replace(replace(replace(orig_content->
                                     rec[i].activity_type," ","",0),",","",0),"~","",0),"`","",0),"!",
                                 "",0),"@","",0),"#","",0),"$","",0),"%","",0),"^","",0),"&","",0),
                          "*","",0),"(","",0),")","",0),"-","",0),"_","",0),"+","",0),"=","",0),"{",
                   "",0),"}","",0),"|","",0),"\","",0),":","",0),";","",0),'"',"",0),"'","",0),"<","",
           0),">","",0),".","",0),"/","",0),"?","",0),8))
    SET file_content->qual[row_count].event_cd = cnvtupper(trim(replace(replace(replace(replace(
          replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                     replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                               replace(replace(replace(replace(replace(replace(orig_content->rec[i].
                                     asso_event," ","",0),",","",0),"~","",0),"`","",0),"!","",0),"@",
                                "",0),"#","",0),"$","",0),"%","",0),"^","",0),"&","",0),"*","",0),
                         "(","",0),")","",0),"-","",0),"_","",0),"+","",0),"=","",0),"{","",0),"}","",
                  0),"|","",0),"\","",0),":","",0),";","",0),'"',"",0),"'","",0),"<","",0),">","",0),
         ".","",0),"/","",0),"?","",0),8))
    SET file_content->qual[row_count].modifier_ind = cnvtint(orig_content->rec[i].use_modifier)
    SET file_content->qual[row_count].default_type_flag = cnvtint(orig_content->rec[i].default_type)
    SET file_content->qual[row_count].single_select_ind = cnvtint(orig_content->rec[i].
     first_alpha_single)
    SET file_content->qual[row_count].default_result_type_cd = cnvtupper(trim(replace(replace(replace
        (replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                    replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                              replace(replace(replace(replace(replace(replace(replace(orig_content->
                                     rec[i].result_type," ","",0),",","",0),"~","",0),"`","",0),"!",
                                 "",0),"@","",0),"#","",0),"$","",0),"%","",0),"^","",0),"&","",0),
                          "*","",0),"(","",0),")","",0),"-","",0),"_","",0),"+","",0),"=","",0),"{",
                   "",0),"}","",0),"|","",0),"\","",0),":","",0),";","",0),'"',"",0),"'","",0),"<","",
           0),">","",0),".","",0),"/","",0),"?","",0),8))
    SET file_content->qual[row_count].code_set = cnvtreal(orig_content->rec[i].code_set)
    SET file_content->qual[row_count].max_digits = cnvtint(orig_content->rec[i].numeric_max)
    SET file_content->qual[row_count].min_digits = cnvtint(orig_content->rec[i].numeric_min)
    SET file_content->qual[row_count].min_decimal_places = cnvtint(orig_content->rec[i].decimal)
    SET file_content->qual[row_count].concept_cki = cnvtupper(orig_content->rec[i].asso_concept_cki)
    SET file_content->qual[row_count].io_flag = cnvtint(orig_content->rec[i].intake_output)
    SET file_content->qual[row_count].witness_required_ind = cnvtint(orig_content->rec[i].
     witness_required)
   ENDIF
   IF ((orig_content->rec[i].sex != ""))
    SET ref_count = (ref_count+ 1)
    SET stat = alterlist(file_content->qual[row_count].ref_range,ref_count)
    SET file_content->qual[row_count].ref_range[ref_count].sex_cd = cnvtupper(trim(replace(replace(
        replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                   replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                             replace(replace(replace(replace(replace(replace(replace(replace(
                                     orig_content->rec[i].sex," ","",0),",","",0),"~","",0),"`","",0),
                                 "!","",0),"@","",0),"#","",0),"$","",0),"%","",0),"^","",0),"&","",
                           0),"*","",0),"(","",0),")","",0),"-","",0),"_","",0),"+","",0),"=","",0),
                   "{","",0),"}","",0),"|","",0),"\","",0),":","",0),";","",0),'"',"",0),"'","",0),
           "<","",0),">","",0),".","",0),"/","",0),"?","",0),8))
    IF ((orig_content->rec[i].start_units="Years"))
     CALL echo("years")
     CALL echo(build("age",cnvtint(orig_content->rec[i].start_age)))
     SET file_content->qual[row_count].ref_range[ref_count].age_from_minutes = (((cnvtint(
      orig_content->rec[i].start_age) * 365) * 24) * 60)
    ELSEIF ((orig_content->rec[i].start_units="Months"))
     CALL echo("Months")
     CALL echo(build("age",cnvtint(orig_content->rec[i].start_age)))
     SET file_content->qual[row_count].ref_range[ref_count].age_from_minutes = (((cnvtint(
      orig_content->rec[i].start_age) * 31) * 24) * 60)
    ELSEIF ((orig_content->rec[i].start_units="Weeks"))
     CALL echo("Weeks")
     CALL echo(build("age",cnvtint(orig_content->rec[i].start_age)))
     SET file_content->qual[row_count].ref_range[ref_count].age_from_minutes = (((cnvtint(
      orig_content->rec[i].start_age) * 7) * 24) * 60)
    ELSEIF ((orig_content->rec[i].start_units="Days"))
     CALL echo("Days")
     CALL echo(build("age",cnvtint(orig_content->rec[i].start_age)))
     SET file_content->qual[row_count].ref_range[ref_count].age_from_minutes = ((cnvtint(orig_content
      ->rec[i].start_age) * 24) * 60)
    ELSEIF ((orig_content->rec[i].start_units="Hours"))
     CALL echo("Hours")
     CALL echo(build("age",cnvtint(orig_content->rec[i].start_age)))
     SET file_content->qual[row_count].ref_range[ref_count].age_from_minutes = (cnvtint(orig_content
      ->rec[i].start_age) * 60)
    ELSEIF ((orig_content->rec[i].start_units="Minutes"))
     CALL echo("Minutes")
     CALL echo(build("age",cnvtint(orig_content->rec[i].start_age)))
     SET file_content->qual[row_count].ref_range[ref_count].age_from_minutes = cnvtint(orig_content->
      rec[i].start_age)
    ELSEIF ((orig_content->rec[i].start_units="Seconds"))
     CALL echo("Seconds")
     CALL echo(build("age",cnvtint(orig_content->rec[i].start_age)))
     SET file_content->qual[row_count].ref_range[ref_count].age_from_minutes = (cnvtint(orig_content
      ->rec[i].start_age)/ 60)
    ENDIF
    SET file_content->qual[row_count].ref_range[ref_count].age_from_units_cd = cnvtupper(trim(replace
      (replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                  replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                            replace(replace(replace(replace(replace(replace(replace(replace(replace(
                                     orig_content->rec[i].start_units," ","",0),",","",0),"~","",0),
                                  "`","",0),"!","",0),"@","",0),"#","",0),"$","",0),"%","",0),"^","",
                            0),"&","",0),"*","",0),"(","",0),")","",0),"-","",0),"_","",0),"+","",0),
                    "=","",0),"{","",0),"}","",0),"|","",0),"\","",0),":","",0),";","",0),'"',"",0),
            "'","",0),"<","",0),">","",0),".","",0),"/","",0),"?","",0),8))
    IF ((orig_content->rec[i].end_units="Years"))
     CALL echo("years")
     CALL echo(build("age",cnvtint(orig_content->rec[i].end_age)))
     SET file_content->qual[row_count].ref_range[ref_count].age_to_minutes = (((cnvtint(orig_content
      ->rec[i].end_age) * 365) * 24) * 60)
    ELSEIF ((orig_content->rec[i].end_units="Months"))
     CALL echo("Months")
     CALL echo(build(cnvtint(orig_content->rec[i].end_age)))
     SET file_content->qual[row_count].ref_range[ref_count].age_to_minutes = (((cnvtint(orig_content
      ->rec[i].end_age) * 31) * 24) * 60)
    ELSEIF ((orig_content->rec[i].end_units="Weeks"))
     CALL echo("Weeks")
     CALL echo(build(cnvtint(orig_content->rec[i].end_age)))
     SET file_content->qual[row_count].ref_range[ref_count].age_to_minutes = (((cnvtint(orig_content
      ->rec[i].end_age) * 7) * 24) * 60)
    ELSEIF ((orig_content->rec[i].end_units="Days"))
     CALL echo("Days")
     CALL echo(build(cnvtint(orig_content->rec[i].end_age)))
     SET file_content->qual[row_count].ref_range[ref_count].age_to_minutes = ((cnvtint(orig_content->
      rec[i].end_age) * 24) * 60)
    ELSEIF ((orig_content->rec[i].end_units="Hours"))
     CALL echo("Hours")
     CALL echo(build(cnvtint(orig_content->rec[i].end_age)))
     SET file_content->qual[row_count].ref_range[ref_count].age_to_minutes = (cnvtint(orig_content->
      rec[i].end_age) * 60)
    ELSEIF ((orig_content->rec[i].end_units="Minutes"))
     CALL echo("Minutes")
     CALL echo(build(cnvtint(orig_content->rec[i].end_age)))
     SET file_content->qual[row_count].ref_range[ref_count].age_to_minutes = cnvtint(orig_content->
      rec[i].end_age)
    ELSEIF ((orig_content->rec[i].end_units="Seconds"))
     CALL echo("Seconds")
     CALL echo(build(cnvtint(orig_content->rec[i].start_age)))
     SET file_content->qual[row_count].ref_range[ref_count].age_to_minutes = (cnvtint(orig_content->
      rec[i].start_age)/ 60)
    ENDIF
    SET file_content->qual[row_count].ref_range[ref_count].age_to_units_cd = cnvtupper(trim(replace(
       replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                  replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                            replace(replace(replace(replace(replace(replace(replace(replace(replace(
                                     orig_content->rec[i].end_units," ","",0),",","",0),"~","",0),"`",
                                  "",0),"!","",0),"@","",0),"#","",0),"$","",0),"%","",0),"^","",0),
                           "&","",0),"*","",0),"(","",0),")","",0),"-","",0),"_","",0),"+","",0),"=",
                    "",0),"{","",0),"}","",0),"|","",0),"\","",0),":","",0),";","",0),'"',"",0),"'",
            "",0),"<","",0),">","",0),".","",0),"/","",0),"?","",0),8))
    SET file_content->qual[row_count].ref_range[ref_count].mins_back = cnvtint(orig_content->rec[i].
     min_back)
    SET file_content->qual[row_count].ref_range[ref_count].rule_ind = cnvtint(orig_content->rec[i].
     flex_rule)
    IF ((orig_content->rec[i].ref_default_val != ""))
     SET file_content->qual[row_count].ref_range[ref_count].def_result_ind = 1
     SET file_content->qual[row_count].ref_range[ref_count].default_result = cnvtint(orig_content->
      rec[i].ref_default_val)
    ELSE
     SET file_content->qual[row_count].ref_range[ref_count].def_result_ind = 0
     SET file_content->qual[row_count].ref_range[ref_count].default_result = 0
    ENDIF
    SET file_content->qual[row_count].ref_range[ref_count].units_cd = cnvtupper(trim(replace(replace(
        replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                   replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                             replace(replace(replace(replace(replace(replace(replace(replace(
                                     orig_content->rec[i].uom," ","",0),",","",0),"~","",0),"`","",0),
                                 "!","",0),"@","",0),"#","",0),"$","",0),"%","",0),"^","",0),"&","",
                           0),"*","",0),"(","",0),")","",0),"-","",0),"_","",0),"+","",0),"=","",0),
                   "{","",0),"}","",0),"|","",0),"\","",0),":","",0),";","",0),'"',"",0),"'","",0),
           "<","",0),">","",0),".","",0),"/","",0),"?","",0),8))
    SET file_content->qual[row_count].ref_range[ref_count].normal_low = cnvtint(orig_content->rec[i].
     normal_low)
    SET file_content->qual[row_count].ref_range[ref_count].normal_high = cnvtint(orig_content->rec[i]
     .normal_high)
    IF ((file_content->qual[row_count].ref_range[ref_count].normal_low > 0)
     AND (file_content->qual[row_count].ref_range[ref_count].normal_high > 0))
     SET file_content->qual[row_count].ref_range[ref_count].normal_ind = 3
    ELSEIF ((file_content->qual[row_count].ref_range[ref_count].normal_high > 0))
     SET file_content->qual[row_count].ref_range[ref_count].normal_ind = 2
    ELSEIF ((file_content->qual[row_count].ref_range[ref_count].normal_low > 0))
     SET file_content->qual[row_count].ref_range[ref_count].normal_ind = 1
    ELSE
     SET file_content->qual[row_count].ref_range[ref_count].normal_ind = 0
    ENDIF
    SET file_content->qual[row_count].ref_range[ref_count].review_low = cnvtint(orig_content->rec[i].
     review_low)
    SET file_content->qual[row_count].ref_range[ref_count].review_high = cnvtint(orig_content->rec[i]
     .review_high)
    IF ((file_content->qual[row_count].ref_range[ref_count].review_low > 0)
     AND (file_content->qual[row_count].ref_range[ref_count].review_high > 0))
     SET file_content->qual[row_count].ref_range[ref_count].review_ind = 3
    ELSEIF ((file_content->qual[row_count].ref_range[ref_count].review_high > 0))
     SET file_content->qual[row_count].ref_range[ref_count].review_ind = 2
    ELSEIF ((file_content->qual[row_count].ref_range[ref_count].review_low > 0))
     SET file_content->qual[row_count].ref_range[ref_count].review_ind = 1
    ELSE
     SET file_content->qual[row_count].ref_range[ref_count].review_ind = 0
    ENDIF
    SET file_content->qual[row_count].ref_range[ref_count].feasible_low = cnvtint(orig_content->rec[i
     ].feasible_low)
    SET file_content->qual[row_count].ref_range[ref_count].feasible_high = cnvtint(orig_content->rec[
     i].feasible_high)
    IF ((file_content->qual[row_count].ref_range[ref_count].feasible_low > 0)
     AND (file_content->qual[row_count].ref_range[ref_count].feasible_high > 0))
     SET file_content->qual[row_count].ref_range[ref_count].feasible_ind = 3
    ELSEIF ((file_content->qual[row_count].ref_range[ref_count].feasible_high > 0))
     SET file_content->qual[row_count].ref_range[ref_count].feasible_ind = 2
    ELSEIF ((file_content->qual[row_count].ref_range[ref_count].feasible_low > 0))
     SET file_content->qual[row_count].ref_range[ref_count].feasible_ind = 1
    ELSE
     SET file_content->qual[row_count].ref_range[ref_count].feasible_ind = 0
    ENDIF
    SET file_content->qual[row_count].ref_range[ref_count].linear_low = cnvtint(orig_content->rec[i].
     linear_low)
    SET file_content->qual[row_count].ref_range[ref_count].linear_high = cnvtint(orig_content->rec[i]
     .linear_high)
    IF ((file_content->qual[row_count].ref_range[ref_count].linear_low > 0)
     AND (file_content->qual[row_count].ref_range[ref_count].linear_high > 0))
     SET file_content->qual[row_count].ref_range[ref_count].linear_ind = 3
    ELSEIF ((file_content->qual[row_count].ref_range[ref_count].linear_high > 0))
     SET file_content->qual[row_count].ref_range[ref_count].linear_ind = 2
    ELSEIF ((file_content->qual[row_count].ref_range[ref_count].linear_low > 0))
     SET file_content->qual[row_count].ref_range[ref_count].linear_ind = 1
    ELSE
     SET file_content->qual[row_count].ref_range[ref_count].linear_ind = 0
    ENDIF
    SET file_content->qual[row_count].ref_range[ref_count].critical_low = cnvtint(orig_content->rec[i
     ].critical_low)
    SET file_content->qual[row_count].ref_range[ref_count].critical_high = cnvtint(orig_content->rec[
     i].critical_high)
    IF ((file_content->qual[row_count].ref_range[ref_count].critical_low > 0)
     AND (file_content->qual[row_count].ref_range[ref_count].critical_high > 0))
     SET file_content->qual[row_count].ref_range[ref_count].critical_ind = 3
    ELSEIF ((file_content->qual[row_count].ref_range[ref_count].critical_high > 0))
     SET file_content->qual[row_count].ref_range[ref_count].critical_ind = 2
    ELSEIF ((file_content->qual[row_count].ref_range[ref_count].critical_low > 0))
     SET file_content->qual[row_count].ref_range[ref_count].critical_ind = 1
    ELSE
     SET file_content->qual[row_count].ref_range[ref_count].critical_ind = 0
    ENDIF
    SET file_content->qual[row_count].ref_range[ref_count].mins_back = cnvtint(orig_content->rec[i].
     min_back)
    SET alpha_count = 0
   ENDIF
   IF ((orig_content->rec[i].alpha_description != ""))
    SET alpha_count = (alpha_count+ 1)
    SET stat = alterlist(file_content->qual[row_count].ref_range[ref_count].alpha,alpha_count)
    SET file_content->qual[row_count].ref_range[ref_count].alpha[alpha_count].description =
    orig_content->rec[i].alpha_description
    SET file_content->qual[row_count].ref_range[ref_count].alpha[alpha_count].sequence = cnvtint(
     orig_content->rec[i].sequence)
    SET file_content->qual[row_count].ref_range[ref_count].alpha[alpha_count].result_value = cnvtint(
     orig_content->rec[i].res_val)
    SET file_content->qual[row_count].ref_range[ref_count].alpha[alpha_count].concept_cki = cnvtupper
    (orig_content->rec[i].concept_cki)
    SET file_content->qual[row_count].ref_range[ref_count].alpha[alpha_count].truth_state_cd =
    cnvtupper(trim(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                          replace(replace(replace(replace(replace(replace(replace(replace(replace(
                                   replace(replace(orig_content->rec[i].truth_state," ","",0),",","",
                                    0),"~","",0),"`","",0),"!","",0),"@","",0),"#","",0),"$","",0),
                             "%","",0),"^","",0),"&","",0),"*","",0),"(","",0),")","",0),"-","",0),
                      "_","",0),"+","",0),"=","",0),"{","",0),"}","",0),"|","",0),"\","",0),":","",0),
              ";","",0),'"',"",0),"'","",0),"<","",0),">","",0),".","",0),"/","",0),"?","",0),8))
    SET file_content->qual[row_count].ref_range[ref_count].alpha[alpha_count].multi_alpha_sort_order
     = cnvtint(orig_content->rec[i].grid_disp)
    SET file_content->qual[row_count].ref_range[ref_count].alpha[alpha_count].default_ind = cnvtint(
     orig_content->rec[i].alpha_default)
   ENDIF
   IF ((orig_content->rec[i].look_back_min_res != ""))
    SET off_cnt = (off_cnt+ 1)
    SET stat = alterlist(file_content->qual[row_count].offset_mins,off_cnt)
    SET file_content->qual[row_count].offset_mins[off_cnt].offset_min_nbr = cnvtint(orig_content->
     rec[i].look_back_min_res)
    SET file_content->qual[row_count].offset_mins[off_cnt].offset_min_type =
    "Acknowledge Result in Minutes"
   ENDIF
   IF ((orig_content->rec[i].look_back_min_bmdi != ""))
    SET off_cnt = (off_cnt+ 1)
    SET stat = alterlist(file_content->qual[row_count].offset_mins,off_cnt)
    SET file_content->qual[row_count].offset_mins[off_cnt].offset_min_nbr = cnvtint(orig_content->
     rec[i].look_back_min_bmdi)
    SET file_content->qual[row_count].offset_mins[off_cnt].offset_min_type = "MDI BackWard Minutes"
   ENDIF
   IF ((orig_content->rec[i].look_forward_min_bmdi != ""))
    SET off_cnt = (off_cnt+ 1)
    SET stat = alterlist(file_content->qual[row_count].offset_mins,off_cnt)
    SET file_content->qual[row_count].offset_mins[off_cnt].offset_min_nbr = cnvtint(orig_content->
     rec[i].look_forward_min_bmdi)
    SET file_content->qual[row_count].offset_mins[off_cnt].offset_min_type = "MDI Forward Minutes"
   ENDIF
 ENDFOR
 CALL echorecord(file_content)
 SET x = size(file_content->qual,5)
 SET cnt = 0
 FOR (cnt = 1 TO size(file_content->qual,5))
   FREE SET request_new
   RECORD request_new(
     1 mnemonic = vc
     1 description = vc
     1 activity_type_cd = f8
     1 event_cd = f8
     1 modifier_ind = i2
     1 default_type_flag = i2
     1 single_select_ind = i2
     1 default_result_type_cd = f8
     1 build_event_cd_ind = i2
     1 code_set = f8
     1 max_digits = i4
     1 min_digits = i4
     1 min_decimal_places = i4
     1 ref_range_cnt = i4
     1 ref_range[*]
       2 ref_id = f8
       2 service_resource_cd = f8
       2 species_cd = f8
       2 organism_cd = f8
       2 sex_cd = f8
       2 unknown_age_ind = f8
       2 age_from_units_cd = f8
       2 age_from_minutes = i4
       2 age_to_units_cd = f8
       2 age_to_minutes = i4
       2 specimen_type_cd = f8
       2 patient_condition_cd = f8
       2 def_result_ind = i2
       2 default_result = f8
       2 dilute_ind = i2
       2 review_ind = i2
       2 review_low = f8
       2 review_high = f8
       2 feasible_ind = i2
       2 feasible_low = f8
       2 feasible_high = f8
       2 linear_ind = i2
       2 linear_low = f8
       2 linear_high = f8
       2 normal_ind = i2
       2 normal_low = f8
       2 normal_high = f8
       2 critical_ind = i2
       2 critical_low = f8
       2 critical_high = f8
       2 delta_check_type_cd = f8
       2 delta_minutes = f8
       2 delta_value = f8
       2 delta_chk_flag = i2
       2 delta_lvl_flag = i2
       2 mins_back = f8
       2 resource_ref_flag = i2
       2 gestational_ind = i2
       2 precedence_sequence = i4
       2 units_cd = f8
       2 alpha_cnt = i4
       2 alpha[*]
         3 nomenclature_id = f8
         3 sequence = i4
         3 use_units_ind = i2
         3 default_ind = i2
         3 description = vc
         3 multi_alpha_sort_order = i4
         3 result_value = f8
         3 category_id = f8
         3 concept_cki = vc
         3 truth_state_cd = f8
       2 categories[*]
         3 mod = i2
         3 category_id = f8
         3 placeholder_category_id = f8
         3 category_name = vc
         3 category_sequence = i4
         3 expand_flag = i2
       2 rule_ind = i2
       2 rule_cnt = i4
       2 rule[*]
         3 rule_id = f8
         3 gestational_age_ind = i2
         3 gestation_from_age_in_days = i4
         3 gestation_to_age_in_days = i4
         3 from_weight = i4
         3 to_weight = i4
         3 from_weight_unit_cd = f8
         3 to_weight_unit_cd = f8
         3 from_height = i4
         3 to_height = i4
         3 from_height_unit_cd = f8
         3 to_height_unit_cd = f8
         3 location_cd = f8
         3 feasible_ind = i2
         3 feasible_low = f8
         3 feasible_high = f8
         3 normal_ind = i2
         3 normal_low = f8
         3 normal_high = f8
         3 critical_ind = i2
         3 critical_low = f8
         3 critical_high = f8
         3 def_result_ind = i2
         3 default_result = f8
         3 units_cd = f8
         3 alpha_rule_cnt = i4
         3 alpha_rule[*]
           4 nomenclature_id = f8
     1 io_flag = i2
     1 template_script_cd = f8
     1 concept_cki = vc
     1 offset_min_cnt = i4
     1 offset_mins[*]
       2 offset_min_type_cd = f8
       2 offset_min_nbr = i4
     1 witness_required_ind = i2
   )
   SET reqinfo->updt_id = reqinfo->updt_id
   SET reqinfo->updt_task = 0
   SET request_new->mnemonic = file_content->qual[cnt].mnemonic
   SET request_new->description = file_content->qual[cnt].description
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE (cv.display_key=file_content->qual[cnt].activity_type_cd)
     AND cv.code_set=106
     AND cv.active_ind=1
    HEAD cv.code_value
     request_new->activity_type_cd = cv.code_value
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    cv.code_value
    FROM code_value cv
    WHERE (cv.display_key=file_content->qual[cnt].event_cd)
     AND cv.code_set=72
     AND cv.active_ind=1
    HEAD cv.code_value
     request_new->event_cd = cv.code_value
    WITH nocounter
   ;end select
   SELECT
    cv.code_value, cv.code_set, cv.description,
    cv.display_key
    FROM code_value cv
    WHERE cv.code_set=289
     AND (cv.display_key=file_content->qual[cnt].default_result_type_cd)
     AND cv.active_ind=1
    HEAD cv.code_value
     request_new->default_result_type_cd = cv.code_value
    WITH nocounter
   ;end select
   SET request_new->build_event_cd_ind = 0
   SET request_new->code_set = file_content->qual[cnt].code_set
   SET request_new->max_digits = file_content->qual[cnt].max_digits
   SET request_new->min_digits = file_content->qual[cnt].min_digits
   SET request_new->min_decimal_places = file_content->qual[cnt].min_decimal_places
   SET j = 0
   SET request_new->ref_range_cnt = size(file_content->qual[cnt].ref_range,5)
   FOR (j = 1 TO size(file_content->qual[cnt].ref_range,5))
     SET stat = alterlist(request_new->ref_range,j)
     SET request_new->ref_range[j].ref_id = 0
     SET request_new->ref_range[j].service_resource_cd = 0
     SET request_new->ref_range[j].species_cd = 0
     SET request_new->ref_range[j].organism_cd = 0
     SELECT INTO "nl:"
      FROM code_value cv
      WHERE (cv.display_key=file_content->qual[cnt].ref_range[j].sex_cd)
       AND cv.code_set=57
       AND cv.active_ind=1
      HEAD cv.code_value
       request_new->ref_range[j].sex_cd = cv.code_value
      WITH nocounter
     ;end select
     SET request_new->ref_range[j].unknown_age_ind = file_content->qual[cnt].ref_range[j].
     unknown_age_ind
     SELECT INTO "nl:"
      FROM code_value cv
      WHERE (cv.display_key=file_content->qual[cnt].ref_range[j].age_from_units_cd)
       AND cv.code_set=340
       AND cv.active_ind=1
      HEAD cv.code_value
       request_new->ref_range[j].age_from_units_cd = cv.code_value
      WITH nocounter
     ;end select
     SET request_new->ref_range[j].age_from_minutes = file_content->qual[cnt].ref_range[j].
     age_from_minutes
     SELECT INTO "nl:"
      FROM code_value cv
      WHERE (cv.display_key=file_content->qual[cnt].ref_range[j].age_to_units_cd)
       AND cv.code_set=340
       AND cv.active_ind=1
      HEAD cv.code_value
       request_new->ref_range[j].age_to_units_cd = cv.code_value
      WITH nocounter
     ;end select
     SET request_new->ref_range[j].age_to_minutes = file_content->qual[cnt].ref_range[j].
     age_to_minutes
     SET request_new->ref_range[j].specimen_type_cd = 0
     SET request_new->ref_range[j].patient_condition_cd = 0
     SET request_new->ref_range[j].def_result_ind = file_content->qual[cnt].ref_range[j].
     def_result_ind
     SET request_new->ref_range[j].default_result = file_content->qual[cnt].ref_range[j].
     default_result
     SET request_new->ref_range[j].dilute_ind = 0
     SET request_new->ref_range[j].review_ind = file_content->qual[cnt].ref_range[j].review_ind
     SET request_new->ref_range[j].review_low = file_content->qual[cnt].ref_range[j].review_low
     SET request_new->ref_range[j].review_high = file_content->qual[cnt].ref_range[j].review_high
     SET request_new->ref_range[j].feasible_ind = file_content->qual[cnt].ref_range[j].feasible_ind
     SET request_new->ref_range[j].feasible_low = file_content->qual[cnt].ref_range[j].feasible_low
     SET request_new->ref_range[j].feasible_high = file_content->qual[cnt].ref_range[j].feasible_high
     SET request_new->ref_range[j].linear_ind = file_content->qual[cnt].ref_range[j].linear_ind
     SET request_new->ref_range[j].linear_low = file_content->qual[cnt].ref_range[j].linear_low
     SET request_new->ref_range[j].linear_high = file_content->qual[cnt].ref_range[j].linear_high
     SET request_new->ref_range[j].normal_ind = file_content->qual[cnt].ref_range[j].normal_ind
     SET request_new->ref_range[j].normal_low = file_content->qual[cnt].ref_range[j].normal_low
     SET request_new->ref_range[j].normal_high = file_content->qual[cnt].ref_range[j].normal_high
     SET request_new->ref_range[j].critical_ind = file_content->qual[cnt].ref_range[j].critical_ind
     SET request_new->ref_range[j].critical_low = file_content->qual[cnt].ref_range[j].critical_low
     SET request_new->ref_range[j].critical_high = file_content->qual[cnt].ref_range[j].critical_high
     SET request_new->ref_range[j].delta_check_type_cd = 0
     SET request_new->ref_range[j].delta_minutes = 0
     SET request_new->ref_range[j].delta_value = 0
     SET request_new->ref_range[j].delta_chk_flag = 0
     SET request_new->ref_range[j].delta_lvl_flag = 0
     SET request_new->ref_range[j].mins_back = file_content->qual[cnt].ref_range[j].mins_back
     SET request_new->ref_range[j].resource_ref_flag = 0
     SET request_new->ref_range[j].gestational_ind = 0
     SET request_new->ref_range[j].precedence_sequence = 0
     SELECT INTO "nl:"
      FROM code_value cv
      WHERE (cv.display_key=file_content->qual[cnt].ref_range[j].units_cd)
       AND cv.code_set=54
       AND cv.active_ind=1
      HEAD cv.code_value
       request_new->ref_range[j].units_cd = cv.code_value
      WITH nocounter
     ;end select
     SET request_new->ref_range[j].alpha_cnt = size(file_content->qual[cnt].ref_range[j].alpha,5)
     FOR (k = 1 TO size(file_content->qual[cnt].ref_range[j].alpha,5))
       SET stat = alterlist(request_new->ref_range[j].alpha,k)
       SELECT INTO "nl:"
        FROM nomenclature n
        WHERE (n.source_string=file_content->qual[cnt].ref_range[j].alpha[k].description)
        HEAD n.nomenclature_id
         request_new->ref_range[j].alpha[k].nomenclature_id = n.nomenclature_id
        WITH nocounter
       ;end select
       SET request_new->ref_range[j].alpha[k].sequence = file_content->qual[cnt].ref_range[j].alpha[k
       ].sequence
       SET request_new->ref_range[j].alpha[k].use_units_ind = 0
       SET request_new->ref_range[j].alpha[k].default_ind = file_content->qual[cnt].ref_range[j].
       alpha[k].default_ind
       SET request_new->ref_range[j].alpha[k].description = file_content->qual[cnt].ref_range[j].
       alpha[k].description
       SET request_new->ref_range[j].alpha[k].multi_alpha_sort_order = file_content->qual[cnt].
       ref_range[j].alpha[k].multi_alpha_sort_order
       SET request_new->ref_range[j].alpha[k].result_value = file_content->qual[cnt].ref_range[j].
       alpha[k].result_value
       SELECT INTO "nl:"
        n.nomenclature_id
        FROM nomenclature n
        WHERE (n.source_string_keycap=file_content->qual[cnt].ref_range[j].alpha[k].concept_cki)
        HEAD n.nomenclature_id
         request_new->ref_range[j].alpha[k].concept_cki = n.concept_cki
        WITH nocounter
       ;end select
       SELECT INTO "nl:"
        FROM code_value cv
        WHERE (cv.display_key=file_content->qual[cnt].ref_range[j].alpha[k].truth_state_cd)
         AND cv.active_ind=1
         AND cv.code_set=15751
        HEAD cv.code_value
         request_new->ref_range[j].alpha[k].truth_state_cd = cv.code_value
        WITH nocounter
       ;end select
     ENDFOR
     SET stat = alterlist(request_new->ref_range[j].categories,0)
     SET request_new->ref_range[j].rule_ind = 0
     SET request_new->ref_range[j].rule_cnt = 0
     SET stat = alterlist(request_new->ref_range[j].rule,0)
   ENDFOR
   SET request_new->offset_min_cnt = size(file_content->qual[cnt].offset_mins,5)
   SET m = 0
   FOR (m = 1 TO request_new->offset_min_cnt)
     SET stat = alterlist(request_new->offset_mins,m)
     SELECT INTO "nl:"
      cv.code_value
      FROM code_value cv
      WHERE (cv.definition=file_content->qual[cnt].offset_mins[m].offset_min_type)
       AND cv.code_set=4002164
       AND cv.active_ind=1
      HEAD cv.code_value
       request_new->offset_mins[m].offset_min_type_cd = cv.code_value
      WITH nocounter
     ;end select
     SET request_new->offset_mins[m].offset_min_nbr = file_content->qual[cnt].offset_mins[m].
     offset_min_nbr
   ENDFOR
   SET request_new->modifier_ind = 1
   SET request_new->single_select_ind = 1
   SET request_new->default_type_flag = 1
   SET request_new->io_flag = 0
   SET request_new->template_script_cd = 0
   SELECT INTO "nl:"
    FROM nomenclature n
    WHERE (n.source_string_keycap=file_content->qual[cnt].concept_cki)
     AND n.active_ind=1
    HEAD n.nomenclature_id
     request_new->concept_cki = n.concept_cki
    WITH nocounter
   ;end select
   SET request_new->witness_required_ind = 1
   CALL echorecord(request_new)
   EXECUTE dcp_add_dtawizard_dtainfo:dba  WITH replace("REQUEST",request_new), replace("REPLY",reply)
 ENDFOR
 SELECT INTO  $OUTDEV
  status = "Succesfully Added DTAs into the tool"
  FROM dummyt d1
  WITH nocounter, format
 ;end select
#exit_script
 IF (failed != false)
  SELECT INTO value( $OUTDEV)
   message = trim(substring(1,200,serrmsg),3)
   FROM (dummyt d  WITH seq = 1)
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
 IF (failed != exe_error)
  CALL updtdminfo(trim(cnvtupper(curprog),3))
 ENDIF
END GO
