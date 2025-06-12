CREATE PROGRAM dc_mp_get_o_pt_det_line_tst:dba
 DECLARE display_compare_errors(null) = null WITH protect
 DECLARE cleanup_temp_tables(null) = null WITH protect
 DECLARE displaytestsresults(null) = null WITH protect
 DECLARE cur_item_level = i4 WITH protect, noconstant(1)
 DECLARE ut_debug_mode_ind = i4 WITH protect, noconstant(0)
 FREE RECORD script_unit_test
 RECORD script_unit_test(
   1 script_param_str = vc
   1 script_table_replace_cnt = i4
   1 script_table_replace[*]
     2 orig_table_name = vc
     2 orig_table_alias = vc
     2 new_table_name = vc
     2 new_table_alias = vc
 ) WITH protect
 FREE RECORD record_data
 RECORD record_data(
   1 item_cnt = i4
   1 items[*]
     2 name = vc
     2 type = vc
     2 level = i4
     2 value = vc
     2 index_seq = i4
 )
 FREE RECORD record_data_2
 RECORD record_data_2(
   1 item_cnt = i4
   1 items[*]
     2 name = vc
     2 type = vc
     2 level = i4
     2 value = vc
     2 index_seq = i4
 )
 FREE RECORD xml_tag_data
 RECORD xml_tag_data(
   1 tag_name = vc
   1 attr_cnt = i4
   1 attrs[*]
     2 attr_name = vc
     2 attr_value = vc
 )
 FREE RECORD temp_tables_created
 RECORD temp_tables_created(
   1 cnt = i4
   1 qual[*]
     2 name = vc
 )
 FREE RECORD temp_table_create_parse
 RECORD temp_table_create_parse(
   1 cnt = i4
   1 qual[*]
     2 parse_string = vc
 )
 FREE RECORD temp_table_insert_parse
 RECORD temp_table_insert_parse(
   1 cnt = i4
   1 qual[*]
     2 parse_string = vc
 )
 FREE RECORD compare_record_errors
 RECORD compare_record_errors(
   1 cnt = i4
   1 errors[*]
     2 message = vc
 )
 FREE RECORD record_lvl
 RECORD record_lvl(
   1 cnt = i4
   1 qual[*]
     2 cnt = i4
 )
 FREE RECORD unit_tests
 RECORD unit_tests(
   1 cnt = i4
   1 qual[*]
     2 test_name = vc
     2 test_passed = i2
     2 test_expected = vc
     2 test_actual = vc
 )
 SUBROUTINE (ut_module(module_name=vc) =null WITH protect)
   CALL echo(build2(" Unit Test Module: ",module_name))
 END ;Subroutine
 SUBROUTINE (ut_test(test_name=vc,expected_assertions=i4) =null WITH protect)
   CALL echo(build2("     ",test_name))
 END ;Subroutine
 SUBROUTINE (addtestresult(test_passed=i2,test_name=vc) =null WITH protect)
   SET unit_tests->cnt += 1
   SET stat = alterlist(unit_tests->qual,unit_tests->cnt)
   SET unit_tests->qual[unit_tests->cnt].test_name = test_name
   SET unit_tests->qual[unit_tests->cnt].test_passed = test_passed
   RETURN(null)
 END ;Subroutine
 SUBROUTINE displaytestsresults(null)
   DECLARE u_cntr = i4 WITH protect, noconstant(0)
   FOR (u_cntr = 1 TO unit_tests->cnt)
     IF ((unit_tests->qual[u_cntr].test_passed=1))
      CALL echo(build2(unit_tests->qual[u_cntr].test_name," Passed"))
     ELSE
      CALL echo(build2(unit_tests->qual[u_cntr].test_name," Failed"))
     ENDIF
   ENDFOR
   RETURN(null)
 END ;Subroutine
 SUBROUTINE (ut_assert_ok(state=i4,success_msg=vc) =i2 WITH protect)
   DECLARE return_value = i2 WITH protect, noconstant(0)
   IF (state=1)
    SET return_value = 1
    CALL echo(build2("         ",success_msg))
   ENDIF
   RETURN(return_value)
 END ;Subroutine
 SUBROUTINE (ut_assert_not_ok(state=i4,success_msg=vc) =i2 WITH protect)
   DECLARE return_value = i2 WITH protect, noconstant(0)
   IF (ut_assert_ok(state,success_msg)=0)
    SET return_value = 1
    CALL echo(build2("         ",success_msg))
   ENDIF
   RETURN(return_value)
 END ;Subroutine
 SUBROUTINE (ut_assert_equal(actual=vc,expected=vc,success_msg=vc) =i2 WITH protect)
   DECLARE return_value = i2 WITH protect, noconstant(0)
   IF (actual=expected)
    SET return_value = 1
    CALL echo(build2("         ",success_msg))
   ENDIF
   RETURN(return_value)
 END ;Subroutine
 SUBROUTINE (ut_assert_not_equal(actual=vc,expected=vc,success_msg=vc) =i2 WITH protect)
   DECLARE return_value = i2 WITH protect, noconstant(0)
   IF (ut_assert_equal(actual,expected,success_msg)=0)
    SET return_value = 1
    CALL echo(build2("         ",success_msg))
   ENDIF
   RETURN(return_value)
 END ;Subroutine
 SUBROUTINE (ut_assert_record_equal(actual_record_name=vc,expected_record_name=vc,success_msg=vc) =i2
   WITH protect)
   DECLARE return_value = i2 WITH protect, noconstant(0)
   CALL compare_records_structures(actual_record_name,expected_record_name)
   IF ((compare_record_errors->cnt=0))
    SET return_value = 1
    CALL echo(build2("         ",success_msg))
   ENDIF
   RETURN(return_value)
 END ;Subroutine
 SUBROUTINE (ut_assert_record_not_equal(actual_record_name=vc,expected_record_name=vc,success_msg=vc
  ) =i2 WITH protect)
   DECLARE return_value = i2 WITH protect, noconstant(0)
   IF (ut_assert_record_equal(actual_record_name,expected_record_name,success_msg)=0)
    SET return_value = 1
    CALL echo(build2("         ",success_msg))
   ENDIF
   RETURN(return_value)
 END ;Subroutine
 SUBROUTINE (parse_xml_tag(tag_str=vc) =vc WITH protect)
   SET stat = initrec(xml_tag_data)
   DECLARE tag_name = vc WITH protect, noconstant("")
   DECLARE attr_cntr = i4 WITH protect, noconstant(2)
   DECLARE cur_attr_str = vc WITH protect, noconstant(piece(tag_str," ",attr_cntr,"NULL"))
   DECLARE cur_attr_name = vc WITH protect, noconstant("")
   DECLARE cur_attr_value = vc WITH protect, noconstant("")
   SET tag_name = piece(tag_str," ",1,"NO_TAG")
   IF ( NOT (tag_name IN ("ITEM", "/ITEM", "/LIST")))
    IF (ut_debug_mode_ind=1)
     CALL echo(build(" tag_str ---- > ",tag_str))
    ENDIF
    SET xml_tag_data->tag_name = tag_name
    WHILE (cur_attr_str != "NULL")
      SET cur_attr_name = piece(cur_attr_str,"=",1,"NULL")
      SET cur_attr_value = piece(cur_attr_str,"=",2,"NULL")
      IF (cur_attr_name != "NULL"
       AND cur_attr_value != "NULL")
       SET xml_tag_data->attr_cnt += 1
       IF (mod(xml_tag_data->attr_cnt,10)=1)
        SET stat = alterlist(xml_tag_data->attrs,(xml_tag_data->attr_cnt+ 9))
       ENDIF
       SET xml_tag_data->attrs[xml_tag_data->attr_cnt].attr_name = cur_attr_name
       SET xml_tag_data->attrs[xml_tag_data->attr_cnt].attr_value = cur_attr_value
      ENDIF
      SET attr_cntr += 1
      SET cur_attr_str = piece(tag_str," ",attr_cntr,"NULL")
    ENDWHILE
    SET stat = alterlist(xml_tag_data->attrs,xml_tag_data->attr_cnt)
   ELSEIF (tag_name="ITEM")
    SET record_lvl->qual[cur_item_level].cnt += 1
   ENDIF
   RETURN(tag_name)
 END ;Subroutine
 SUBROUTINE (get_cur_tag_attr(attr_name=vc) =vc WITH protect)
   DECLARE search_num = i4 WITH protect, noconstant(0)
   DECLARE attr_index = i4 WITH protect, noconstant(locateval(search_num,1,xml_tag_data->attr_cnt,
     cnvtupper(attr_name),xml_tag_data->attrs[search_num].attr_name))
   IF (attr_index > 0)
    RETURN(xml_tag_data->attrs[attr_index].attr_value)
   ELSE
    RETURN("")
   ENDIF
 END ;Subroutine
 SUBROUTINE (add_record_data(item_level=i4,ref_rec_data=vc(ref),data_mode_ind=i2) =null WITH protect)
   DECLARE item_index = i4 WITH protect, noconstant(0)
   DECLARE search_cntr = i4 WITH protect, noconstant(0)
   DECLARE item_name = vc WITH protect, noconstant(xml_tag_data->tag_name)
   IF (item_name > " ")
    SET item_index = locateval(search_cntr,1,ref_rec_data->item_cnt,item_name,ref_rec_data->items[
     search_cntr].name)
    IF (((item_index=0) OR (data_mode_ind=1)) )
     SET ref_rec_data->item_cnt += 1
     SET stat = alterlist(ref_rec_data->items,ref_rec_data->item_cnt)
     SET ref_rec_data->items[ref_rec_data->item_cnt].name = xml_tag_data->tag_name
     SET ref_rec_data->items[ref_rec_data->item_cnt].type = xml_tag_data->attrs[1].attr_value
     IF ((ref_rec_data->items[ref_rec_data->item_cnt].type='"GROUP"'))
      SET ref_rec_data->items[ref_rec_data->item_cnt].type = '"LIST"'
     ENDIF
     IF ((xml_tag_data->attrs[1].attr_value IN ('"LIST"', '"GROUP"')))
      SET item_level -= 1
     ENDIF
     SET ref_rec_data->items[ref_rec_data->item_cnt].level = item_level
    ENDIF
   ENDIF
   RETURN(null)
 END ;Subroutine
 SUBROUTINE (extract_tag(source_str=vc,source_record=vc,ref_rec_data=vc(ref),data_mode_ind=i2) =vc
  WITH protect)
   DECLARE tag_str = vc WITH protect, noconstant("")
   DECLARE return_str = vc WITH protect, noconstant("")
   DECLARE tag_begin_index = i4 WITH protect, noconstant(0)
   DECLARE tag_end_index = i4 WITH protect, noconstant(0)
   DECLARE tag_str_length = i4 WITH protect, noconstant(0)
   DECLARE tag_name = vc WITH protect, noconstant("")
   DECLARE tag_attr_type = vc WITH protect, noconstant("")
   DECLARE tag_attr_name = vc WITH protect, noconstant("")
   DECLARE tag_attr_length = vc WITH protect, noconstant("")
   DECLARE tag_attr_value = vc WITH protect, noconstant("")
   DECLARE source_str_length = i4 WITH protect, noconstant(size(source_str,1))
   DECLARE vc_begin_index = i4 WITH protect, noconstant(0)
   DECLARE vc_end_index = i4 WITH protect, noconstant(0)
   DECLARE vc_str_length = i4 WITH protect, noconstant(0)
   DECLARE vc_str_value = vc WITH protect, noconstant("")
   SET tag_begin_index = findstring("<",source_str,1,0)
   IF (tag_begin_index > 0)
    SET tag_end_index = findstring(">",source_str,tag_begin_index,0)
    IF (tag_end_index > 0)
     SET tag_str_length = ((tag_end_index - tag_begin_index) - 1)
     SET tag_str = substring((tag_begin_index+ 1),tag_str_length,source_str)
     SET return_str = substring((tag_end_index+ 1),(source_str_length - tag_str_length),source_str)
     SET tag_name = parse_xml_tag(tag_str)
     SET tag_attr_type = get_cur_tag_attr("TYPE")
     SET tag_attr_name = get_cur_tag_attr("NAME")
     SET tag_attr_value = get_cur_tag_attr("VALUE")
     IF (tag_attr_type IN ('"LIST"', '"GROUP"'))
      SET cur_item_level += 1
      SET return_str = replace(return_str,concat("</",tag_name,">"),concat("</",tag_name,
        ' TYPE="END_LIST" >'),1)
      IF ((cur_item_level > record_lvl->cnt))
       SET record_lvl->cnt = cur_item_level
       SET stat = alterlist(record_lvl->qual,record_lvl->cnt)
      ENDIF
      SET record_lvl->qual[cur_item_level].cnt = 0
     ELSEIF (tag_attr_type='"END_LIST"')
      SET cur_item_level -= 1
     ELSE
      IF (tag_attr_type='"STRING"')
       SET tag_attr_length = get_cur_tag_attr("LENGTH")
       IF (tag_attr_value="")
        SET tag_attr_length = replace(tag_attr_length,'"',"",0)
        SET vc_str_length = cnvtint(tag_attr_length)
        SET vc_begin_index = 1
        SET vc_end_index = ((vc_begin_index+ vc_str_length)+ 12)
        SET vc_str_value = substring(vc_begin_index,(vc_str_length+ 12),return_str)
        SET return_str = substring(vc_end_index,((source_str_length - vc_str_length) - 1),return_str)
        SET return_str = replace(return_str,concat("</",tag_name,">"),"",1)
       ENDIF
      ELSE
       SET return_str = replace(return_str,concat("</",tag_name,">"),"",2)
      ENDIF
     ENDIF
     IF (tag_attr_name != concat('"',cnvtupper(source_record),'"')
      AND tag_attr_type != '"END_LIST"'
      AND tag_attr_type > "")
      CALL add_record_data(cur_item_level,ref_rec_data,data_mode_ind)
      IF (tag_attr_type='"STRING"')
       SET ref_rec_data->items[ref_rec_data->item_cnt].value = replace(replace(vc_str_value,
         "<![CDATA[",'"',1),"]]>",'"',2)
      ELSE
       SET ref_rec_data->items[ref_rec_data->item_cnt].value = replace(replace(tag_attr_value,'"',"",
         0),char(47),"",0)
      ENDIF
      IF (cur_item_level > 1
       AND (ref_rec_data->items[ref_rec_data->item_cnt].index_seq=0))
       SET ref_rec_data->items[ref_rec_data->item_cnt].index_seq = record_lvl->qual[cur_item_level].
       cnt
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   RETURN(return_str)
 END ;Subroutine
 SUBROUTINE (parse_record(record_name=vc,ref_rec_data=vc(ref),data_mode_ind=i2) =null WITH protect)
   DECLARE parsable_xml = vc WITH protect, noconstant("")
   DECLARE tag_cntr = i4 WITH protect, noconstant(0)
   DECLARE tag_str = vc WITH protect, noconstant("")
   DECLARE tag_found = i2 WITH protect, noconstant(1)
   CALL parser(concat("set parsable_xml = cnvtupper(cnvtrectoxml(",record_name,")) go"))
   IF (ut_debug_mode_ind=1)
    CALL echo(parsable_xml)
   ENDIF
   SET cur_item_level = 1
   WHILE (tag_found=1)
    SET parsable_xml = extract_tag(parsable_xml,record_name,ref_rec_data,data_mode_ind)
    IF (parsable_xml="")
     SET tag_found = 0
    ENDIF
   ENDWHILE
 END ;Subroutine
 SUBROUTINE (get_record_item_path(ref_rec_data=vc(ref),item_index=i4) =vc WITH protect)
   DECLARE item_path = vc WITH protect, noconstant("")
   DECLARE current_level = i4 WITH protect, noconstant(ref_rec_data->items[item_index].level)
   DECLARE search_cntr = i4 WITH protect, noconstant(item_index)
   DECLARE child_index = i4 WITH protect, noconstant(item_index)
   IF (current_level > 1)
    WHILE (current_level > 1
     AND search_cntr > 0)
     IF ((ref_rec_data->items[search_cntr].level=(current_level - 1))
      AND (ref_rec_data->items[search_cntr].type IN ('"LIST"', '"GROUP"')))
      SET current_level -= 1
      SET item_path = concat("->",ref_rec_data->items[search_cntr].name,"[",trim(cnvtstring(
         ref_rec_data->items[child_index].index_seq)),"].",
       ref_rec_data->items[child_index].name)
      SET child_index = search_cntr
     ENDIF
     SET search_cntr -= 1
    ENDWHILE
   ELSE
    SET item_path = concat("->",ref_rec_data->items[item_index].name)
   ENDIF
   RETURN(item_path)
 END ;Subroutine
 SUBROUTINE (add_compare_error(message=vc) =null WITH protect)
   DECLARE error_cnt = i4 WITH protect, noconstant(compare_record_errors->cnt)
   SET error_cnt += 1
   SET compare_record_errors->cnt = error_cnt
   SET stat = alterlist(compare_record_errors->errors,compare_record_errors->cnt)
   SET compare_record_errors->errors[error_cnt].message = message
 END ;Subroutine
 SUBROUTINE display_compare_errors(null)
  DECLARE e_cntr = i4 WITH protect, noconstant(0)
  FOR (e_cntr = 1 TO compare_record_errors->cnt)
    CALL echo(compare_record_errors->errors[e_cntr].message)
  ENDFOR
 END ;Subroutine
 SUBROUTINE (compare_records_structures(record_name_1=vc,record_name_2=vc) =i2 WITH protect)
   DECLARE r_cntr = i4 WITH protect, noconstant(0)
   DECLARE error_msg = vc WITH protect, noconstant("")
   DECLARE error_msg_line2 = vc WITH protect, noconstant("")
   DECLARE record_1_compare_string = vc WITH protect, noconstant("")
   DECLARE record_2_compare_string = vc WITH protect, noconstant("")
   SET stat = initrec(record_data)
   SET stat = initrec(record_data_2)
   SET stat = initrec(compare_record_errors)
   CALL parse_record(record_name_1,record_data,1)
   CALL parse_record(record_name_2,record_data_2,1)
   IF (ut_debug_mode_ind=1)
    CALL echorecord(record_data)
    CALL echorecord(record_data_2)
   ENDIF
   IF ((record_data->item_cnt != record_data_2->item_cnt))
    CALL add_compare_error(build2("RECORD COMPARE ERROR(001) - RECORD ITEM COUNT NOT MATCHING : ",
      record_name_1," has ",trim(cnvtstring(record_data->item_cnt))," items and ",
      record_name_2," has ",trim(cnvtstring(record_data_2->item_cnt))," items "))
   ELSE
    FOR (r_cntr = 1 TO record_data->item_cnt)
      IF ((((record_data->items[r_cntr].level != record_data_2->items[r_cntr].level)) OR ((((
      record_data->items[r_cntr].name != record_data_2->items[r_cntr].name)) OR ((((record_data->
      items[r_cntr].type != record_data_2->items[r_cntr].type)) OR ((record_data->items[r_cntr].value
       != record_data_2->items[r_cntr].value))) )) )) )
       SET error_msg = build2(record_name_1," has item : ",trim(cnvtstring(record_data->items[r_cntr]
          .level))," ",record_data->items[r_cntr].name,
        " = ",get_data_type(record_data->items[r_cntr].type)," and ",record_name_2," has item : ",
        trim(cnvtstring(record_data_2->items[r_cntr].level))," ",record_data_2->items[r_cntr].name,
        " = ",get_data_type(record_data_2->items[r_cntr].type))
       IF ((record_data->items[r_cntr].level != record_data_2->items[r_cntr].level))
        CALL add_compare_error(build2("RECORD COMPARE ERROR(002) - RECORD ITEM LEVEL NOT MATCHING : ",
          error_msg))
       ENDIF
       IF ((record_data->items[r_cntr].name != record_data_2->items[r_cntr].name))
        CALL add_compare_error(build2("RECORD COMPARE ERROR(003) - RECORD ITEM NAME NOT MATCHING : ",
          error_msg))
       ENDIF
       IF ((record_data->items[r_cntr].type != record_data_2->items[r_cntr].type))
        CALL add_compare_error(build2("RECORD COMPARE ERROR(004) - RECORD ITEM TYPE NOT MATCHING : ",
          error_msg))
       ENDIF
       IF ((record_data->items[r_cntr].value != record_data_2->items[r_cntr].value))
        SET error_msg = build2("   ",record_name_1," has item : ",record_name_1,get_record_item_path(
          record_data,r_cntr),
         " = ",record_data->items[r_cntr].value)
        SET error_msg_line2 = build2("   ",record_name_2," has item : ",record_name_2,
         get_record_item_path(record_data_2,r_cntr),
         " = ",record_data_2->items[r_cntr].value)
        CALL add_compare_error(build2("RECORD COMPARE ERROR(005) - RECORD ITEM VALUE NOT MATCHING  ")
         )
        CALL add_compare_error(error_msg)
        CALL add_compare_error(error_msg_line2)
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   IF ((compare_record_errors->cnt > 0))
    CALL display_compare_errors(null)
    RETURN(0)
   ELSE
    CALL echo(build2(" RECORDS ",record_name_1," and ",record_name_2," are equal "))
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE (add_create_parse(parse_str=vc) =null WITH protect)
   DECLARE cur_cnt = i4 WITH protect, noconstant(temp_table_create_parse->cnt)
   SET cur_cnt += 1
   SET temp_table_create_parse->cnt = cur_cnt
   SET stat = alterlist(temp_table_create_parse->qual,temp_table_create_parse->cnt)
   SET temp_table_create_parse->qual[cur_cnt].parse_string = parse_str
 END ;Subroutine
 SUBROUTINE (add_insert_parse(parse_str=vc) =null WITH protect)
   DECLARE cur_cnt = i4 WITH protect, noconstant(temp_table_insert_parse->cnt)
   SET cur_cnt += 1
   SET temp_table_insert_parse->cnt = cur_cnt
   SET stat = alterlist(temp_table_insert_parse->qual,temp_table_insert_parse->cnt)
   SET temp_table_insert_parse->qual[cur_cnt].parse_string = parse_str
 END ;Subroutine
 SUBROUTINE (get_data_type(item_type=vc) =vc WITH protect)
   DECLARE data_type = vc WITH protect, noconstant("")
   CASE (item_type)
    OF '"INT"':
     SET data_type = '"i4"'
    OF '"DOUBLE"':
     SET data_type = '"f8"'
    OF '"STRING"':
     SET data_type = '"vc"'
    OF '"GROUP"':
     SET data_type = '"[]"'
    OF '"LIST"':
     SET data_type = '"[*]"'
   ENDCASE
   RETURN(data_type)
 END ;Subroutine
 SUBROUTINE (add_temp_table_created(table_name=vc) =null WITH protect)
   DECLARE cur_cnt = i4 WITH protect, noconstant(temp_tables_created->cnt)
   SET cur_cnt += 1
   SET temp_tables_created->cnt = cur_cnt
   SET stat = alterlist(temp_tables_created->qual,temp_tables_created->cnt)
   SET temp_tables_created->qual[cur_cnt].name = table_name
 END ;Subroutine
 SUBROUTINE (call_parser(ref_record=vc(ref)) =null WITH protect)
  DECLARE p_cntr = i4 WITH protect, noconstant(0)
  FOR (p_cntr = 1 TO ref_record->cnt)
    CALL parser(ref_record->qual[p_cntr].parse_string)
  ENDFOR
 END ;Subroutine
 SUBROUTINE cleanup_temp_tables(null)
   DECLARE t_cntr = i4 WITH protect, noconstant(0)
   DECLARE parser_str = vc WITH protect, noconstant("")
   FOR (t_cntr = 1 TO temp_tables_created->cnt)
     SET parser_str = build2(" free select ",temp_tables_created->qual[t_cntr].name," go ")
     CALL echo(parser_str)
     CALL parser(parser_str)
   ENDFOR
 END ;Subroutine
 SUBROUTINE (build_temp_table(from_record_name=vc,rec_level=i4,temp_table_name=vc) =null WITH protect
  )
   DECLARE record_cntr = i4 WITH protect, noconstant(0)
   DECLARE item_type = vc WITH protect, noconstant("")
   DECLARE column_cnt = i4 WITH protect, noconstant(0)
   DECLARE cur_list_name = vc WITH protect, noconstant("")
   SET stat = initrec(temp_table_create_parse)
   SET stat = initrec(temp_table_insert_parse)
   CALL parse_record(from_record_name,record_data,0)
   CALL echorecord(record_data)
   CALL add_create_parse(build2("free select ",temp_table_name," go"))
   CALL add_create_parse(build2("select into table ",temp_table_name))
   FOR (record_cntr = 1 TO record_data->item_cnt)
     IF ((record_data->items[record_cntr].level=rec_level))
      SET item_type = get_data_type(record_data->items[record_cntr].type)
      IF (item_type > " ")
       IF (column_cnt > 0)
        CALL add_create_parse(", ")
       ENDIF
       CALL add_create_parse(build(record_data->items[record_cntr].name," = type(",item_type,")"))
       SET column_cnt += 1
      ENDIF
     ENDIF
   ENDFOR
   CALL add_create_parse('with organization = "TEMPRDB" go ')
   CALL add_insert_parse(build2("Insert into ",temp_table_name," CUST, "))
   SET column_cnt = 0
   FOR (record_cntr = 1 TO record_data->item_cnt)
    IF ((record_data->items[record_cntr].type IN ('"LIST"', '"GROUP"')))
     SET cur_list_name = record_data->items[record_cntr].name
     CALL add_insert_parse(build("(dummyt d with seq = size(",from_record_name,"->",cur_list_name,
       ",5))"))
    ENDIF
    IF ((record_data->items[record_cntr].level=rec_level)
     AND ((rec_level=1) OR (rec_level=2
     AND cur_list_name)) )
     SET item_type = get_data_type(record_data->items[record_cntr].type)
     IF (item_type > " ")
      IF (column_cnt=0)
       CALL add_insert_parse("set")
      ELSE
       CALL add_insert_parse(", ")
      ENDIF
      IF (rec_level > 1)
       CALL add_insert_parse(build2("cust.",record_data->items[record_cntr].name," =  ",
         from_record_name,"->",
         cur_list_name,"[d.seq].",record_data->items[record_cntr].name))
      ELSE
       CALL add_insert_parse(build2("cust.",record_data->items[record_cntr].name," =  ",
         from_record_name,"->",
         record_data->items[record_cntr].name))
      ENDIF
      SET column_cnt += 1
     ENDIF
    ENDIF
   ENDFOR
   CALL add_insert_parse("plan d")
   CALL add_insert_parse("join cust")
   CALL add_insert_parse("with nocounter go")
   CALL add_temp_table_created(temp_table_name)
   CALL echorecord(temp_table_create_parse)
   CALL echorecord(temp_table_insert_parse)
   CALL echorecord(temp_tables_created)
   CALL call_parser(temp_table_create_parse)
   CALL call_parser(temp_table_insert_parse)
 END ;Subroutine
 SUBROUTINE (find_column_name(source_string=vc,table_name_alias=vc,search_index=i4(ref)) =vc WITH
  protect)
   DECLARE column_name = vc WITH protect, noconstant("")
   DECLARE begin_index = i4 WITH protect, noconstant(0)
   DECLARE next_index = i4 WITH protect, noconstant(0)
   DECLARE next_character = vc WITH protect, noconstant("")
   SET begin_index = findstring(concat(cnvtupper(table_name_alias),"."),source_string,search_index,0)
   IF (begin_index > 0)
    SET next_index = ((begin_index+ size(table_name_alias,1))+ 1)
    SET next_character = substring(next_index,1,source_string)
    SET column_name = " "
    WHILE (next_character IN ("A", "B", "C", "D", "E",
    "F", "G", "H", "I", "J",
    "K", "L", "M", "N", "O",
    "P", "Q", "R", "S", "T",
    "U", "V", "W", "X", "Y",
    "Z", "_"))
      SET column_name = build(column_name,next_character)
      SET next_index += 1
      SET next_character = substring(next_index,1,source_string)
    ENDWHILE
    SET search_index = next_index
   ENDIF
   RETURN(column_name)
 END ;Subroutine
 SUBROUTINE (add_column_name(ref_record=vc(ref),column_name=vc) =null WITH protect)
   DECLARE cur_cnt = i4 WITH protect, noconstant(ref_record->cnt)
   DECLARE search_cntr = i4 WITH protect, noconstant(0)
   IF (column_name > " "
    AND locateval(search_cntr,1,ref_record->cnt,column_name,ref_record->qual[search_cntr].column_name
    )=0)
    SET cur_cnt += 1
    SET ref_record->cnt = cur_cnt
    SET stat = alterlist(ref_record->qual,ref_record->cnt)
    SET ref_record->qual[cur_cnt].column_name = column_name
   ENDIF
 END ;Subroutine
 SUBROUTINE extract_query(begin_string,source_string,search_index)
   DECLARE begin_index = i4 WITH protect, noconstant(0)
   DECLARE next_index = i4 WITH protect, noconstant(0)
   DECLARE next_character = vc WITH protect, noconstant("")
   SET begin_index = findstring(begin_string,source_string,search_index,0)
   IF (begin_index > 0)
    SET next_index = ((begin_index+ size(begin_string,1))+ 1)
    SET next_character = substring(next_index,1,source_string)
    SET column_name = " "
    WHILE (((is_char_alpha(next_character)) OR (((is_char_number(next_character)) OR (next_character
     IN ("_"))) )) )
      SET column_name = build(column_name,next_character)
      SET next_index += 1
      SET next_character = substring(next_index,1,source_string)
    ENDWHILE
    SET search_index = next_index
   ENDIF
   RETURN(null)
 END ;Subroutine
 SUBROUTINE is_char_number(char)
   IF (char IN ("0", "1", "2", "3", "4",
   "5", "6", "7", "8", "9"))
    RETURN(true)
   ELSE
    RETURN(false)
   ENDIF
 END ;Subroutine
 SUBROUTINE is_char_alpha(char)
   IF (cnvtupper(char) IN ("A", "B", "C", "D", "E",
   "F", "G", "H", "I", "J",
   "K", "L", "M", "N", "O",
   "P", "Q", "R", "S", "T",
   "U", "V", "W", "X", "Y",
   "Z"))
    RETURN(true)
   ELSE
    RETURN(false)
   ENDIF
 END ;Subroutine
 SUBROUTINE (extract_table_columns(source_file=vc,table_name_alias=vc) =null WITH protect)
   CALL echo("Entered extract_table_columns subroutine ")
   DECLARE realcnt = i4
   DECLARE file_content_str = vc WITH protect, noconstant("")
   FREE RECORD frec
   RECORD frec(
     1 file_desc = i4
     1 file_name = vc
     1 file_buf = vc
     1 file_dir = i4
     1 file_offset = i4
   )
   FREE RECORD column_names
   RECORD column_names(
     1 cnt = i4
     1 qual[*]
       2 column_name = vc
   )
   DECLARE abc = vc WITH protect
   DECLARE len = i4 WITH protect
   DECLARE column_name = vc WITH protect, noconstant("")
   DECLARE search_index = i4 WITH protect, noconstant(0)
   DECLARE tempstr = vc WITH protect, noconstant("TEST")
   SET frec->file_name = source_file
   SET frec->file_buf = "r"
   SET stat = cclio("OPEN",frec)
   IF (stat=0)
    RETURN(0)
   ENDIF
   SET frec->file_dir = 2
   SET stat = cclio("SEEK",frec)
   SET len = cclio("TELL",frec)
   SET frec->file_dir = 0
   SET stat = cclio("SEEK",frec)
   SET stat = memrealloc(abc,1,build("C",len))
   SET frec->file_buf = notrim(abc)
   FREE SET abc
   SET stat = cclio("READ",frec)
   SET file_content_str = frec->file_buf
   SET stat = cclio("CLOSE",frec)
   SET file_content_str = cnvtupper(file_content_str)
   SET file_content_str = replace(file_content_str,concat("(",trim(cnvtupper(table_name_alias)),"."),
    build2(" ",trim(cnvtupper(table_name_alias)),"."),0)
   CALL echo(build(" file_content_str --- > ",file_content_str))
   IF (file_content_str > " ")
    SET column_name = find_column_name(file_content_str,table_name_alias,search_index)
    CALL add_column_name(column_names,column_name)
    WHILE (column_name > " ")
     SET column_name = find_column_name(file_content_str,table_name_alias,search_index)
     CALL add_column_name(column_names,column_name)
    ENDWHILE
   ELSE
    CALL echo(concat("Unable to read in file ",source_file))
   ENDIF
   CALL echorecord(column_names)
   RETURN(null)
 END ;Subroutine
 FREE RECORD pt_ords_request
 RECORD pt_ords_request(
   1 cnt = i4
   1 list[*]
     2 order_id = f8
     2 order_name = vc
 ) WITH protect
 FREE RECORD pt_ords_reply
 RECORD pt_ords_reply(
   1 cnt = i4
   1 list[*]
     2 order_id = f8
     2 order_name = vc
     2 pt_ord_display_line = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 CALL echo(" Executing Test # 1 .... ")
 SET stat = cnvtjsontorec(
'{"TEST_REPLY_1":{			 "CNT":3,			 "LIST":[			 {			  "ORDER_ID":4317257.000000,			  "ORDER_NAME":"albuterol (albuterol 8 mg \
oral tablet, extended release)",			  "PT_ORD_DISPLAY_LINE":"1 tab(s), Oral, 2 times a day, 60 tab(s)"			 },			 {			  "ORDE\
R_ID":4317280.000000,			  "ORDER_NAME":"amoxicillin (amoxicillin 250 mg/5 mL oral liquid)",			  "PT_ORD_DISPLAY_LINE":"5 m\
L, Oral, 3 times a day, 150 mL"			 },			 {			  "ORDER_ID":4317289.000000,			  "ORDER_NAME":"buPROPion (buPROPion 75 mg ora\
l tablet)",			  "PT_ORD_DISPLAY_LINE":"1 tab(s), Oral, 3 times a day, 90 tab(s)"			 }			 ],			 "STATUS_DATA":{			  "STATUS\
":"",			  "SUBEVENTSTATUS":[{			   "OPERATIONNAME":"",			   "OPERATIONSTATUS":"",			   "TARGETOBJECTNAME":"",			   "TARGET\
OBJECTVALUE":""			  }]			 }			}}\
')
 SET pt_ords_request->cnt = 3
 SET stat = alterlist(pt_ords_request->list,pt_ords_request->cnt)
 SET pt_ords_request->list[1].order_id = 4317257.00
 SET pt_ords_request->list[1].order_name = "albuterol (albuterol 8 mg oral tablet, extended release)"
 SET pt_ords_request->list[2].order_id = 4317280.00
 SET pt_ords_request->list[2].order_name = "amoxicillin (amoxicillin 250 mg/5 mL oral liquid)"
 SET pt_ords_request->list[3].order_id = 4317289.00
 SET pt_ords_request->list[3].order_name = "buPROPion (buPROPion 75 mg oral tablet)"
 EXECUTE dc_mp_get_pt_ord_det_line  WITH replace("PT_ORDS_REQUEST","PT_ORDS_REQUEST"), replace(
  "PT_ORDS_REPLY","PT_ORDS_REPLY")
 CALL addtestresult(ut_assert_record_equal("test_reply_1","pt_ords_reply",
   " Record Structures are Equal"),"Test # 1")
 CALL echo(" Executing Test # 2 .... ")
 SET stat = cnvtjsontorec(
'{"TEST_REPLY_2":{			 "CNT":3,			 "LIST":[			 {			  "ORDER_ID":4317343.000000,			  "ORDER_NAME":"fentanyl (fentanyl 100 mcg\
 buccal tablet)",			  "PT_ORD_DISPLAY_LINE":"1 tab(s), Buccal, every 2 to 4 hours, As Needed, for Breakthrough Pain"			 },\
			 {			  "ORDER_ID":4317422.000000,			  "ORDER_NAME":"nicotine (nicotine 5 mg/16 hr transdermal patch)",			  "PT_ORD_DISP\
LAY_LINE":"1 patch(es), Topical, every day, 14 patch(es)"			 },			 {			  "ORDER_ID":4436584.000000,			  "ORDER_NAME":"cefu\
roxime (cefuroxime 250 mg oral tablet)",			  "PT_ORD_DISPLAY_LINE":"1 tab(s), Oral route, 2 times a day, 20 tab(s)"			 }		\
	 ],			 "STATUS_DATA":{			  "STATUS":"",			  "SUBEVENTSTATUS":[{			   "OPERATIONNAME":"",			   "OPERATIONSTATUS":"",			   \
"TARGETOBJECTNAME":"",			   "TARGETOBJECTVALUE":""			  }]			 }			}}\
')
 SET pt_ords_request->cnt = 3
 SET stat = alterlist(pt_ords_request->list,pt_ords_request->cnt)
 SET pt_ords_request->list[1].order_id = 4317343.00
 SET pt_ords_request->list[1].order_name = "fentanyl (fentanyl 100 mcg buccal tablet)"
 SET pt_ords_request->list[2].order_id = 4317422.00
 SET pt_ords_request->list[2].order_name = "nicotine (nicotine 5 mg/16 hr transdermal patch)"
 SET pt_ords_request->list[3].order_id = 4436584.00
 SET pt_ords_request->list[3].order_name = "cefuroxime (cefuroxime 250 mg oral tablet)"
 EXECUTE dc_mp_get_pt_ord_det_line  WITH replace("PT_ORDS_REQUEST","PT_ORDS_REQUEST"), replace(
  "PT_ORDS_REPLY","PT_ORDS_REPLY")
 CALL addtestresult(ut_assert_record_equal("test_reply_2","pt_ords_reply",
   " Record Structures are Equal"),"Test # 2")
 SET stat = cnvtjsontorec(
'{"TEST_REPLY_3":{			 "CNT":1,			 "LIST":[			 {			  "ORDER_ID":4317877.000000,			  "ORDER_NAME":"levothyroxine (Synthroid)"\
,			  "PT_ORD_DISPLAY_LINE":"1.5 tab(s)"			 }			 ],			 "STATUS_DATA":{			  "STATUS":"",			  "SUBEVENTSTATUS":[{			   "OPER\
ATIONNAME":"",			   "OPERATIONSTATUS":"",			   "TARGETOBJECTNAME":"",			   "TARGETOBJECTVALUE":""			  }]			 }			}}\
')
 SET pt_ords_request->cnt = 1
 SET stat = alterlist(pt_ords_request->list,pt_ords_request->cnt)
 SET pt_ords_request->list[1].order_id = 4317877.00
 SET pt_ords_request->list[1].order_name = "levothyroxine (Synthroid)"
 EXECUTE dc_mp_get_pt_ord_det_line  WITH replace("PT_ORDS_REQUEST","PT_ORDS_REQUEST"), replace(
  "PT_ORDS_REPLY","PT_ORDS_REPLY")
 CALL addtestresult(ut_assert_record_equal("test_reply_3","pt_ords_reply",
   " Record Structures are Equal"),"Test # 3")
 CALL displaytestsresults(null)
END GO
