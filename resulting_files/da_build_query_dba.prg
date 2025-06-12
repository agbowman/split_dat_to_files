CREATE PROGRAM da_build_query:dba
 DECLARE engine_version = vc WITH constant("Discern SQL Engine v 35.2"), protect
 DECLARE maximum_in_list_count = i4 WITH constant(500), protect
 DECLARE getnexttag(string=vc(ref),pos=i4,tag=vc(ref)) = i4 WITH public
 DECLARE gettagbyname(string=vc(ref),name=vc,pos=i4,tag=vc(ref)) = i4 WITH public
 DECLARE findtagend(string=vc(ref),pos=i4) = i4 WITH public
 DECLARE skipwhitespace(string=vc(ref),pos=i4,max=i4) = i4 WITH public
 DECLARE readnametoken(string=vc(ref),pos=i4,name=vc(ref)) = i4 WITH public
 DECLARE getnodeattribute(node=vc,attrib_name=vc) = vc WITH public
 DECLARE dareplacequery(query_text=gvc(ref),query_name=vc,replace_text=vc) = vc WITH public
 DECLARE dacleancolumn(column=vc) = vc WITH public
 DECLARE isnextnodeempty(source=vc,start_position=i4) = i2 WITH public
 DECLARE findnode(source=vc,nodename=vc,start_position=i4) = i4 WITH public
 DECLARE getnextnode(source=vc,start_position=i4) = vc WITH public
 DECLARE getnextnodename(source=vc,start_position=i4) = vc WITH public
 DECLARE extractopenparentheses(string=vc) = vc WITH protect
 IF (validate(request)=0)
  RECORD request(
    1 xml = gvc
  )
 ENDIF
 IF (validate(reply)=0)
  RECORD reply(
    1 query_str = gvc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 IF (validate(pre_reply)=0)
  RECORD pre_reply(
    1 qual[*]
      2 query_name = vc
      2 query_str = gvc
  )
 ENDIF
 RECORD parsed_request(
   1 da_domain[*]
     2 da_domain_id = f8
     2 element_list[*]
       3 element_uuid = vc
       3 name = vc
     2 select_element_cnt = f8
     2 query_list_name = vc
     2 join_type = vc
     2 filter_list[*]
       3 filter = vc
       3 having_ind = i2
 )
 RECORD query(
   1 select_clause[*]
     2 line = vc
   1 from_clause[*]
     2 line = vc
   1 where_clause[*]
     2 line = vc
   1 group_by_clause[*]
     2 line = vc
   1 having_clause[*]
     2 line = vc
   1 order_by_clause[*]
     2 line = vc
 )
 RECORD uuid_list(
   1 qual[*]
     2 element_id = f8
     2 uuid = vc
 )
 RECORD columns(
   1 qual[*]
     2 da_element_id = f8
     2 column_txt = vc
     2 ord_column_txt = vc
 )
 RECORD tables(
   1 qual[*]
     2 table_id = f8
     2 table_name = vc
 )
 RECORD table_joins(
   1 qual[*]
     2 da_table_reltn_id = f8
     2 table_join_txt = vc
 )
 RECORD operator_stack(
   1 qual[*]
     2 operator = vc
     2 paren_ind = i2
 )
 RECORD query_stack(
   1 qual[*]
     2 query = vc
     2 query_seq = i2
 )
 RECORD qualification_values(
   1 qual[*]
     2 text = vc
   1 null_ind = i2
 )
 RECORD sub_query_org(
   1 qual[*]
     2 query_name = vc
     2 parent_query_name = vc
 )
 RECORD join_op_org(
   1 qual[*]
     2 query_name = vc
     2 child_query_name = vc
     2 operator = vc
     2 combine_query = vc
     2 paren_ind = i2
 )
 DECLARE filter_pos = i4 WITH noconstant(0), protect
 DECLARE filter_cnt = i2 WITH noconstant(0), protect
 DECLARE filt_cnt = i2 WITH noconstant(0), protect
 DECLARE filt_var = vc WITH noconstant(""), protect
 DECLARE uuid_val = vc WITH noconstant(""), protect
 DECLARE op_type_val = vc WITH noconstant(""), protect
 DECLARE val_val = vc WITH noconstant(""), protect
 DECLARE filt_col = vc WITH noconstant(""), protect
 DECLARE filt_op = vc WITH noconstant(""), protect
 DECLARE null_qual = vc WITH noconstant(""), protect
 DECLARE null_bool = vc WITH noconstant(""), protect
 DECLARE num = i2 WITH noconstant(0), protect
 DECLARE elem_cnt = i2 WITH noconstant(0), protect
 DECLARE select_cnt = i2 WITH noconstant(0)
 DECLARE from_cnt = i2 WITH noconstant(0)
 DECLARE where_cnt = i2 WITH noconstant(0)
 DECLARE having_cnt = i2 WITH noconstant(0)
 DECLARE grp_by_cnt = i2 WITH noconstant(0)
 DECLARE ord_by_cnt = i2 WITH noconstant(0)
 DECLARE col_cnt = i2 WITH noconstant(0)
 DECLARE tab_cnt = i2 WITH noconstant(0)
 DECLARE join_cnt = i2 WITH noconstant(0)
 DECLARE xml_str = vc WITH noconstant("")
 DECLARE cur_pos = i4 WITH noconstant(0)
 DECLARE operator_stack_sz = i2 WITH noconstant(0)
 DECLARE filter_list_sz = i2 WITH noconstant(0)
 DECLARE paren_close_ind = i2 WITH noconstant(0)
 DECLARE paren_cnt = i2 WITH noconstant(0)
 DECLARE cur_node = vc WITH noconstant("")
 DECLARE element_node = vc WITH noconstant("")
 DECLARE element_name = vc WITH noconstant("")
 DECLARE element_uuid = vc WITH noconstant("")
 DECLARE op_node = vc WITH noconstant("")
 DECLARE value_node = vc WITH noconstant("")
 DECLARE value_cnt = i2 WITH noconstant(0)
 DECLARE v_node = vc WITH noconstant("")
 DECLARE filt_datatype = i2 WITH noconstant(0)
 DECLARE temp_pos = i4 WITH noconstant(0)
 DECLARE formatted_value = vc WITH noconstant("")
 DECLARE rel_from_date = vc WITH noconstant("")
 DECLARE rel_to_date = vc WITH noconstant("")
 DECLARE relative_date_cv = f8 WITH noconstant(0.0)
 DECLARE relative_date_str = vc WITH noconstant("")
 DECLARE end_of_select_fields = i2 WITH noconstant(0)
 DECLARE set_operator_string = vc WITH noconstant("")
 DECLARE cur_pos_query = i2 WITH noconstant(0)
 DECLARE sub_query_node = vc WITH noconstant("")
 DECLARE sub_query_name = vc WITH noconstant("")
 DECLARE child_query_idx = i2 WITH noconstant(0)
 DECLARE op_query_seq = i2 WITH noconstant(0)
 DECLARE xcountquery = vc WITH noconstant("")
 DECLARE xcountelement = vc WITH noconstant("")
 DECLARE domain_uuid = vc WITH noconstant("")
 DECLARE q_cnt = i2 WITH noconstant(0)
 DECLARE filter_q_node = vc WITH noconstant("")
 DECLARE filter_list_q_sz = i2 WITH noconstant(0)
 DECLARE cur_ql_pos = i2 WITH noconstant(1)
 DECLARE query_list_name = vc WITH noconstant("")
 DECLARE subquery_ind = i2 WITH noconstant(0)
 DECLARE subquery_global_ind = i2 WITH noconstant(0)
 DECLARE join_pos = i2 WITH noconstant(0)
 DECLARE join_node = vc WITH noconstant("")
 DECLARE join_type = vc WITH noconstant("")
 DECLARE join_query_node = vc WITH noconstant("")
 DECLARE join_query_name = vc WITH noconstant("")
 DECLARE sub_query_pos = i2 WITH noconstant(0)
 DECLARE sub_idx = i2 WITH noconstant(0)
 DECLARE s_q_cnt = i2 WITH noconstant(0)
 DECLARE op_join_cnt = i2 WITH noconstant(0)
 DECLARE op_query_cnt = i2 WITH noconstant(0)
 DECLARE join_query_seq = i2 WITH noconstant(0)
 DECLARE set_query = vc WITH noconstant("")
 DECLARE query_pos = i2 WITH noconstant(0)
 DECLARE query_num = i2 WITH noconstant(0)
 DECLARE sub_query = vc WITH noconstant("")
 DECLARE start_query = vc WITH noconstant("")
 DECLARE start_query_indx = i2 WITH noconstant(0)
 DECLARE c = i2 WITH noconstant(0)
 DECLARE blank_pos = i2 WITH noconstant(0)
 DECLARE idx = i2 WITH noconstant(0)
 DECLARE cur_element_pos = i2 WITH noconstant(0)
 DECLARE col_element_node = vc WITH noconstant("")
 DECLARE col_ind = i2 WITH noconstant(0)
 DECLARE col_element_uuid = vc WITH noconstant("")
 DECLARE errcode = i4 WITH noconstant(0)
 DECLARE errmsg = vc WITH noconstant("")
 DECLARE set_operator_ind = i2 WITH noconstant(0)
 DECLARE blob_clob_ind = i2 WITH noconstant(0)
 DECLARE ordby = i2 WITH noconstant(0)
 DECLARE grp_by_pos = i4 WITH noconstant(0)
 DECLARE grp_by_txt = vc WITH noconstant("")
 DECLARE hint_str = vc WITH noconstant("")
 DECLARE hint_pos = i4 WITH noconstant(0)
 DECLARE hint_node = vc WITH noconstant("")
 DECLARE plus_zero = vc WITH constant("+0")
 DECLARE trim_it = vc WITH constant("Trim")
 DECLARE element_useindex = vc WITH noconstant("1")
 DECLARE filt_pos = i4 WITH noconstant(0)
 DECLARE filt_node = vc WITH noconstant("")
 DECLARE xrnum = vc WITH noconstant("")
 DECLARE rnum_pos = i4 WITH noconstant(0)
 DECLARE rnum_node = vc WITH noconstant("")
 DECLARE use_rnum = i2 WITH noconstant(0)
 DECLARE rnum_txt = vc WITH noconstant("rownum < ")
 DECLARE rnum_qual = vc WITH noconstant("")
 DECLARE group_by_ind = i2 WITH noconstant(1)
 DECLARE order_by_ind = i2 WITH noconstant(1)
 DECLARE attr_txt = vc WITH noconstant("")
 DECLARE qual_text = vc WITH noconstant(""), protect
 DECLARE where_filter_cnt = i4 WITH protect, noconstant(0)
 DECLARE having_filter_cnt = i4 WITH protect, noconstant(0)
 DECLARE list_val_cnt = i4 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 SET errcode = error(errmsg,1)
 SET xml_str = request->xml
 SET hint_pos = findnode(xml_str,"hint",1)
 IF (hint_pos > 0)
  SET hint_node = getnextnode(xml_str,hint_pos)
  SET hint_str = getnodeattribute(hint_node,"text")
 ELSE
  SET hint_str = " "
 ENDIF
 SET rnum_pos = findnode(xml_str,"xrnum",1)
 IF (rnum_pos > 0)
  SET rnum_node = getnextnode(xml_str,rnum_pos)
  SET xrnum = getnodeattribute(rnum_node,"xnbr")
  SET use_rnum = 1
  SET rnum_qual = concat(rnum_txt," ",trim(xrnum))
 ELSE
  SET use_rnum = 0
  SET rnum_qual = " "
 ENDIF
 SET cur_pos = findnode(xml_str,"queries",1)
 IF (cur_pos > 0)
  SET cur_node = getnextnode(xml_str,cur_pos)
  SET attr_txt = getnodeattribute(cur_node,"usegroupby")
  IF (textlen(attr_txt) > 0)
   SET group_by_ind = cnvtint(attr_txt)
  ENDIF
  SET attr_txt = getnodeattribute(cur_node,"useorderby")
  IF (textlen(attr_txt) > 0)
   SET order_by_ind = cnvtint(attr_txt)
  ENDIF
 ENDIF
 SET cur_pos = findnode(xml_str,"query_list",1)
 SET cur_node = getnextnode(xml_str,cur_pos)
 SET xcountquery = getnodeattribute(cur_node,"xCount")
 SET stat = alterlist(parsed_request->da_domain,cnvtint(xcountquery))
 FOR (q_cnt = 1 TO cnvtint(xcountquery))
   SET cur_pos = findnode(xml_str,"domain",(cur_pos+ 1))
   SET cur_node = getnextnode(xml_str,cur_pos)
   SET domain_uuid = getnodeattribute(cur_node,"uuid")
   SELECT INTO "NL:"
    FROM da_domain dom
    WHERE dom.domain_uuid=domain_uuid
    DETAIL
     parsed_request->da_domain[q_cnt].da_domain_id = dom.da_domain_id
    WITH nocounter
   ;end select
   SET cur_pos = findnode(xml_str,"elements",(cur_pos+ 1))
   SET cur_node = getnextnode(xml_str,cur_pos)
   SET xcountelement = getnodeattribute(cur_node,"xCount")
   SET parsed_request->da_domain[q_cnt].select_element_cnt = cnvtint(xcountelement)
   SET stat = alterlist(parsed_request->da_domain[q_cnt].element_list,cnvtint(xcountelement))
   FOR (j = 1 TO cnvtint(xcountelement))
     SET cur_pos = findnode(xml_str,"element",(cur_pos+ 1))
     SET cur_node = getnextnode(xml_str,cur_pos)
     SET parsed_request->da_domain[q_cnt].element_list[j].element_uuid = getnodeattribute(cur_node,
      "uuid")
     SET parsed_request->da_domain[q_cnt].element_list[j].name = getnodeattribute(cur_node,"name")
   ENDFOR
   SET query_list_name = concat("query_list_item",cnvtstring(q_cnt))
   SET cur_ql_pos = findnode(xml_str,query_list_name,cur_ql_pos)
   SET cur_ql_node = getnextnode(xml_str,cur_ql_pos)
   SET parsed_request->da_domain[q_cnt].query_list_name = getnodeattribute(cur_ql_node,"name")
 ENDFOR
 SET join_pos = findnode(xml_str,"operator",1)
 SET join_node = getnextnode(xml_str,join_pos)
 SET join_type = getnodeattribute(join_node,"type")
 SET join_query_seq = 1
 IF (((join_type="UNION") OR (((join_type="INTERSECT") OR (join_type="MINUS")) )) )
  SET set_operator_ind = 1
  WHILE (((getnextnodename(xml_str,join_pos)="query") OR (((getnextnodename(xml_str,join_pos)=
  "operator") OR (((getnextnodename(xml_str,join_pos)="/operator") OR (((getnextnodename(xml_str,
   join_pos)="operator2") OR (((getnextnodename(xml_str,join_pos)="/operator2") OR (getnextnodename(
   xml_str,join_pos)="query2")) )) )) )) )) )
    IF (getnextnodename(xml_str,join_pos) IN ("operator", "operator2"))
     SET join_node = getnextnode(xml_str,join_pos)
     SET join_type = getnodeattribute(join_node,"type")
     SET operator_stack_sz = (size(operator_stack->qual,5)+ 1)
     SET stat = alterlist(operator_stack->qual,operator_stack_sz)
     SET operator_stack->qual[operator_stack_sz].operator = join_type
     SET join_query_seq = (join_query_seq+ 1)
     IF (getnodeattribute(join_node,"paren")="true")
      SET operator_stack->qual[operator_stack_sz].paren_ind = 1
      SET paren_cnt = (paren_cnt+ 1)
     ENDIF
    ELSE
     IF (getnextnodename(xml_str,join_pos) IN ("query", "query2"))
      SET join_query_node = getnextnode(xml_str,join_pos)
      SET join_query_name = getnodeattribute(join_query_node,"name")
      SET stat = locateval(c,1,size(parsed_request->da_domain,5),join_query_name,parsed_request->
       da_domain[c].query_list_name)
      SET join_query_name = build("Query",stat)
      SET op_query_cnt = (size(query_stack->qual,5)+ 1)
      SET stat = alterlist(query_stack->qual,op_query_cnt)
      SET query_stack->qual[op_query_cnt].query = join_query_name
      SET query_stack->qual[op_query_cnt].query_seq = join_query_seq
      IF (isnextnodeempty(xml_str,join_pos)=1)
       SET join_pos = (join_pos+ 1)
      ELSE
       SET join_pos = findnode(xml_str,"/query",join_pos)
      ENDIF
     ELSEIF (getnextnodename(xml_str,join_pos) IN ("/operator", "/operator2"))
      IF (operator_stack_sz > 0)
       SET op_join_cnt = (op_join_cnt+ 1)
       SET stat = alterlist(join_op_org->qual,op_join_cnt)
       SET join_op_org->qual[op_join_cnt].operator = operator_stack->qual[operator_stack_sz].operator
       SET join_op_org->qual[op_join_cnt].paren_ind = operator_stack->qual[operator_stack_sz].
       paren_ind
       IF (op_query_cnt > 0)
        SET join_op_org->qual[op_join_cnt].query_name = query_stack->qual[op_query_cnt].query
        SET op_query_seq = query_stack->qual[op_query_cnt].query_seq
       ELSE
        SET join_op_org->qual[op_join_cnt].query_name = join_op_org->qual[(op_join_cnt - 2)].
        combine_query
        SET op_query_seq = 0
       ENDIF
       SET op_query_paren = operator_stack->qual[operator_stack_sz].paren_ind
       SET op_query_cnt = (op_query_cnt - 1)
       SET stat = alterlist(query_stack->qual,op_query_cnt)
       SET child_query_idx = locateval(idx,1,size(query_stack->qual,5),query_stack->qual[op_query_cnt
        ].query_seq,query_stack->qual[idx].query_seq)
       IF (child_query_idx > 0)
        SET join_op_org->qual[op_join_cnt].child_query_name = query_stack->qual[child_query_idx].
        query
        SET op_query_cnt = (op_query_cnt - 1)
        SET stat = alterlist(query_stack->qual,op_query_cnt)
       ELSE
        SET join_op_org->qual[op_join_cnt].child_query_name = join_op_org->qual[(op_join_cnt - 1)].
        combine_query
       ENDIF
       IF (op_query_paren=1)
        SET join_op_org->qual[op_join_cnt].combine_query = build2("( ",join_op_org->qual[op_join_cnt]
         .child_query_name," ",join_op_org->qual[op_join_cnt].operator," ",
         join_op_org->qual[op_join_cnt].query_name," )")
       ELSE
        SET join_op_org->qual[op_join_cnt].combine_query = build2(join_op_org->qual[op_join_cnt].
         child_query_name," ",join_op_org->qual[op_join_cnt].operator," ",join_op_org->qual[
         op_join_cnt].query_name)
       ENDIF
       SET operator_stack_sz = (operator_stack_sz - 1)
       SET stat = alterlist(operator_stack->qual,operator_stack_sz)
      ENDIF
     ENDIF
    ENDIF
    SET join_node = getnextnode(xml_str,join_pos)
    SET join_pos = (findnode(xml_str,join_node,join_pos)+ 1)
  ENDWHILE
 ENDIF
 IF (size(join_op_org->qual,5) > 0)
  SET set_operator_string = join_op_org->qual[size(join_op_org->qual,5)].combine_query
 ENDIF
 SET stat = alterlist(operator_stack->qual,0)
 SET operator_stack_sz = 0
 SET paren_close_ind = 0
 SET paren_cnt = 0
 SET cur_pos = (findnode(xml_str,"query_list",1)+ 1)
 FOR (q_cnt = 1 TO cnvtint(xcountquery))
   SET subquery_ind = 0
   SET col_ind = 0
   SET cur_pos = (findnode(xml_str,"qualification",cur_pos)+ 1)
   SET paren_close_ind = 0
   SET paren_cnt = 0
   SET filter_list_sz = 1
   SET stat = alterlist(parsed_request->da_domain[q_cnt].filter_list,filter_list_sz)
   SET parsed_request->da_domain[q_cnt].filter_list[filter_list_sz].filter = " "
   WHILE (((getnextnodename(xml_str,cur_pos)="filter") OR (((getnextnodename(xml_str,cur_pos)=
   "operator") OR (((getnextnodename(xml_str,cur_pos)="/operator") OR (((getnextnodename(xml_str,
    cur_pos)="operator2") OR (((getnextnodename(xml_str,cur_pos)="/operator2") OR (getnextnodename(
    xml_str,cur_pos)="filter2")) )) )) )) )) )
     IF (getnextnodename(xml_str,cur_pos) IN ("filter", "filter2"))
      SET filt_node = getnextnode(xml_str,cur_pos)
      SET element_useindex = getnodeattribute(filt_node,"useIndex")
     ENDIF
     IF (getnextnodename(xml_str,cur_pos) IN ("operator", "operator2"))
      SET cur_node = getnextnode(xml_str,cur_pos)
      SET type = getnodeattribute(cur_node,"type")
      SET operator_stack_sz = (size(operator_stack->qual,5)+ 1)
      SET stat = alterlist(operator_stack->qual,operator_stack_sz)
      SET operator_stack->qual[operator_stack_sz].operator = type
      IF (getnodeattribute(cur_node,"paren")="true")
       SET parsed_request->da_domain[q_cnt].filter_list[filter_list_sz].filter = concat(
        parsed_request->da_domain[q_cnt].filter_list[filter_list_sz].filter,"(")
       SET operator_stack->qual[operator_stack_sz].paren_ind = 1
       SET paren_cnt = (paren_cnt+ 1)
      ENDIF
     ELSEIF (getnextnodename(xml_str,cur_pos) IN ("/operator", "/operator2"))
      SET x = 1
     ELSE
      SET cur_pos = (findnode(xml_str,"filter",cur_pos)+ 1)
      SET element_node = getnextnode(xml_str,cur_pos)
      SET element_name = getnodeattribute(element_node,"name")
      SET element_uuid = getnodeattribute(element_node,"uuid")
      SET col_ind = 0
      SET subquery_ind = 0
      SET cur_pos = (findnode(xml_str,"element",cur_pos)+ 1)
      SET having_ind = 0
      SELECT INTO "NL:"
       FROM da_element e,
        long_text_reference cols
       WHERE e.element_uuid=element_uuid
        AND cols.long_text_id=e.column_string_txt_id
       HEAD REPORT
        elem_cnt = size(parsed_request->da_domain[q_cnt].element_list,5)
       DETAIL
        IF (trim(e.qual_string_txt,3) != "")
         filt_datatype = e.qual_data_type_flag
         IF (element_useindex="0")
          IF (e.qual_data_type_flag=1)
           filt_col = trim(concat(trim(dacleancolumn(e.qual_string_txt),3),"+0"),3)
          ELSE
           filt_col = concat(trim_it,"(",trim(dacleancolumn(e.qual_string_txt),3),")")
          ENDIF
         ELSE
          filt_col = trim(dacleancolumn(e.qual_string_txt),3)
         ENDIF
        ELSEIF (trim(cols.long_text,3) != "")
         filt_datatype = e.result_data_type_flag
         IF (element_useindex="0")
          IF (e.result_data_type_flag=1)
           filt_col = trim(concat(trim(dacleancolumn(cols.long_text),3),"+0"),3)
          ELSE
           filt_col = concat(trim_it,"(",trim(dacleancolumn(cols.long_text),3),")")
          ENDIF
         ELSE
          filt_col = trim(dacleancolumn(cols.long_text),3)
         ENDIF
        ENDIF
        IF (e.element_type_cd=uar_get_code_by("MEANING",14170,"FACT"))
         having_ind = 1
        ENDIF
        elem_cnt = (elem_cnt+ 1), stat = alterlist(parsed_request->da_domain[q_cnt].element_list,
         elem_cnt), parsed_request->da_domain[q_cnt].element_list[elem_cnt].element_uuid =
        element_uuid,
        parsed_request->da_domain[q_cnt].element_list[elem_cnt].name = trim(e.element_name,3)
       WITH nocounter
      ;end select
      IF (getnextnodename(xml_str,cur_pos)="operator")
       SET op_node = getnextnode(xml_str,cur_pos)
       SET op_type_val = getnodeattribute(op_node,"type")
       SET cur_pos = (findnode(xml_str,"operator",cur_pos)+ 1)
       SET value_node = getnextnode(xml_str,cur_pos)
       SET value_cnt = cnvtint(getnodeattribute(value_node,"xCount"))
       IF (getnextnodename(xml_str,(cur_pos+ 1))="query")
        SET filter_q_node = getnextnode(xml_str,(cur_pos+ 1))
        SET val_val = getnodeattribute(filter_q_node,"name")
        SET value_cnt = 0
        SET subquery_ind = 1
        SET subquery_global_ind = 1
        SET s_q_cnt = (s_q_cnt+ 1)
        SET stat = alterlist(sub_query_org->qual,s_q_cnt)
        SET sub_query_org->qual[s_q_cnt].query_name = val_val
        SET sub_query_org->qual[s_q_cnt].parent_query_name = parsed_request->da_domain[q_cnt].
        query_list_name
       ENDIF
       IF (getnextnodename(xml_str,(cur_pos+ 1))="elements")
        SET val_cnt = 0
        SET stat = alterlist(qualification_values->qual,val_cnt)
        SET qualification_values->null_ind = 0
        SET cur_element_pos = (findnode(xml_str,"element",cur_pos)+ 1)
        FOR (i = 1 TO value_cnt)
          SET col_element_node = getnextnode(xml_str,cur_element_pos)
          SET col_element_uuid = getnodeattribute(col_element_node,"uuid")
          SET errcode = error(errmsg,1)
          SELECT INTO "NL:"
           FROM da_element e,
            long_text_reference cols
           WHERE e.element_uuid=col_element_uuid
            AND cols.long_text_id=e.column_string_txt_id
           HEAD REPORT
            elem_cnt = size(parsed_request->da_domain[q_cnt].element_list,5)
           DETAIL
            IF (trim(e.qual_string_txt,3) != "")
             val_val = trim(dacleancolumn(e.qual_string_txt),3)
            ELSEIF (trim(cols.long_text,3) != "")
             val_val = trim(dacleancolumn(cols.long_text),3)
            ENDIF
            IF (e.element_type_cd=uar_get_code_by("MEANING",14170,"FACT"))
             having_ind = 1
            ENDIF
            elem_cnt = (elem_cnt+ 1), stat = alterlist(parsed_request->da_domain[q_cnt].element_list,
             elem_cnt), parsed_request->da_domain[q_cnt].element_list[elem_cnt].element_uuid =
            col_element_uuid,
            parsed_request->da_domain[q_cnt].element_list[elem_cnt].name = trim(e.element_name,3)
           WITH nocounter
          ;end select
          SET val_cnt = (val_cnt+ 1)
          SET stat = alterlist(qualification_values->qual,val_cnt)
          SET qualification_values->qual[val_cnt].text = val_val
          SET cur_element_pos = (findstring(">",xml_str,cur_element_pos)+ 2)
        ENDFOR
        SET value_cnt = 0
        SET col_ind = 1
       ENDIF
      ELSE
       SET op_node = ""
       SET op_type_val = "RELATIVE_DATE"
       SET value_node = getnextnode(xml_str,cur_pos)
       SET value_cnt = cnvtint(getnodeattribute(value_node,"xCount"))
      ENDIF
      IF (subquery_ind != 1
       AND col_ind != 1)
       SET cur_pos = findnode(xml_str,"values",cur_pos)
       SET temp_pos = (findtagend(xml_str,cur_pos)+ 1)
       SET val_cnt = 0
       SET stat = alterlist(qualification_values->qual,val_cnt)
       SET qualification_values->null_ind = 0
       FOR (i = 1 TO value_cnt)
         SET temp_pos = getnexttag(xml_str,temp_pos,v_node)
         SET val_val = getnodeattribute(v_node,"text")
         CASE (filt_datatype)
          OF 3:
           IF ( NOT (substring(1,1,val_val)="'")
            AND val_val != "null")
            SET val_val = concat("'",replace(val_val,"'","''",0),"'")
           ENDIF
          OF 2:
           SET year = substring(1,4,val_val)
           SET month = substring(6,2,val_val)
           SET day = substring(9,2,val_val)
           SET hour = substring(12,2,val_val)
           SET min = substring(15,2,val_val)
           SET sec = substring(18,2,val_val)
           SET val_val = concat("to_date('",month,"/",day,"/",
            year," ",hour,":",min,
            ":",sec,"','MM/DD/YYYY HH24:MI:SS')")
           IF (curutc=1)
            SET val_val = concat("cclsql_cnvtutc(",val_val,",",trim(cnvtstring(curtimezonesys)),
             ",260)")
           ENDIF
          OF 6:
           SET year = substring(1,4,val_val)
           SET month = substring(6,2,val_val)
           SET day = substring(9,2,val_val)
           SET val_val = concat("to_date('",month,"/",day,"/",
            year,"','MM/DD/YYYY')")
         ENDCASE
         IF (val_val="null")
          SET qualification_values->null_ind = 1
         ELSE
          SET val_cnt = (val_cnt+ 1)
          SET stat = alterlist(qualification_values->qual,val_cnt)
          SET qualification_values->qual[val_cnt].text = val_val
         ENDIF
       ENDFOR
      ENDIF
      CASE (op_type_val)
       OF "EQUALS":
        SET filt_op = "="
        SET formatted_value = val_val
       OF "NOT EQUALS":
        SET filt_op = "!="
        SET formatted_value = val_val
       OF "GREATER THAN":
        SET filt_op = ">"
        SET formatted_value = val_val
       OF "LESS THAN":
        SET filt_op = "<"
        SET formatted_value = val_val
       OF "GREATER THAN OR EQUALS":
        SET filt_op = ">="
        SET formatted_value = val_val
       OF "LESS THAN OR EQUALS":
        SET filt_op = "<="
        SET formatted_value = val_val
       OF "IN":
       OF "NOT IN":
        SET filt_op = op_type_val
        IF (subquery_ind != 1)
         SET list_val_cnt = 0
         SET formatted_value = " "
         FOR (i = 1 TO val_cnt)
           IF (i=1)
            SET formatted_value = "("
           ELSEIF (list_val_cnt=maximum_in_list_count)
            SET formatted_value = concat(replace(formatted_value,",",")",2)," ",evaluate(op_type_val,
              "NOT IN","and","or")," ",filt_col,
             " ",op_type_val," (")
            SET list_val_cnt = 0
           ENDIF
           SET formatted_value = concat(formatted_value,qualification_values->qual[i].text,",")
           SET list_val_cnt = (list_val_cnt+ 1)
         ENDFOR
         SET formatted_value = replace(formatted_value,",",")",2)
        ELSE
         SET formatted_value = val_val
        ENDIF
       OF "BETWEEN":
       OF "NOT BETWEEN":
        SET filt_op = op_type_val
        SET formatted_value = concat(qualification_values->qual[1].text," AND ",qualification_values
         ->qual[2].text)
       OF "RELATIVE_DATE":
        SET relative_date_str = replace(replace(getnodeattribute(v_node,"cdfmeaning"),"&lt;","<",0),
         "&gt;",">",0)
        SET relative_date_cv = cnvtreal(uar_get_code_by("MEANING",14729,nullterm(relative_date_str)))
        SELECT INTO "NL:"
         FROM da_relative_date d
         WHERE d.relative_date_cd=relative_date_cv
         DETAIL
          rel_from_date = dacleancolumn(trim(d.from_date_txt,3)), rel_to_date = dacleancolumn(trim(d
            .to_date_txt,3))
         WITH nocounter
        ;end select
        SET filt_op = "BETWEEN"
        SET formatted_value = concat(rel_from_date," AND ",rel_to_date)
       OF "NULL":
        SET filt_op = concat("IS ",op_type_val)
        SET formatted_value = " "
       OF "NOT NULL":
        SET filt_op = concat("IS ",op_type_val)
        SET formatted_value = " "
       ELSE
        SET filt_op = op_type_val
        SET formatted_value = val_val
      ENDCASE
      IF (having_ind=1)
       SET having_cnt = (having_cnt+ 1)
       IF (having_cnt=1)
        SET parsed_request->da_domain[q_cnt].filter_list[filter_list_sz].filter = concat(
         extractopenparentheses(parsed_request->da_domain[q_cnt].filter_list[filter_list_sz].filter),
         filt_col," ",filt_op," ",
         formatted_value)
       ELSE
        SET parsed_request->da_domain[q_cnt].filter_list[filter_list_sz].filter = concat(
         parsed_request->da_domain[q_cnt].filter_list[filter_list_sz].filter," ",filt_col," ",filt_op,
         " ",formatted_value)
       ENDIF
       SET parsed_request->da_domain[q_cnt].filter_list[filter_list_sz].having_ind = 1
       IF (paren_close_ind=1)
        SET paren_close_ind = 2
       ENDIF
      ELSE
       SET where_cnt = (where_cnt+ 1)
       IF ((qualification_values->null_ind=1))
        IF (filt_op="NOT IN")
         SET null_qual = "IS NOT NULL"
         SET null_bool = "AND"
        ELSE
         SET null_qual = "IS NULL"
         SET null_bool = "OR"
        ENDIF
        IF (size(qualification_values->qual,5) > 0)
         SET null_qual = concat("(",filt_col," ",null_qual," ",
          null_bool," ",filt_col," ",filt_op,
          " ",formatted_value,")")
        ELSE
         SET null_qual = concat("(",filt_col," ",null_qual,")")
        ENDIF
        SET qual_text = null_qual
       ELSE
        SET qual_text = concat("(",filt_col," ",filt_op," ",
         formatted_value,")")
       ENDIF
       IF (where_cnt=1)
        SET parsed_request->da_domain[q_cnt].filter_list[filter_list_sz].filter = concat(
         extractopenparentheses(parsed_request->da_domain[q_cnt].filter_list[filter_list_sz].filter),
         qual_text)
       ELSE
        SET parsed_request->da_domain[q_cnt].filter_list[filter_list_sz].filter = concat(
         parsed_request->da_domain[q_cnt].filter_list[filter_list_sz].filter," ",qual_text)
       ENDIF
      ENDIF
      IF (paren_close_ind > 0)
       SET filter_end_pos = (findnode(xml_str,"/filter",cur_pos)+ 8)
       IF (((getnextnodename(xml_str,filter_end_pos)="/operator") OR (getnextnodename(xml_str,
        filter_end_pos)="/operator2")) )
        SET filter_list_sz = (filter_list_sz+ 1)
        SET stat = alterlist(parsed_request->da_domain[q_cnt].filter_list,filter_list_sz)
        SET parsed_request->da_domain[q_cnt].filter_list[filter_list_sz].filter = concat(fillstring(
          value((8 * paren_cnt))," "),")")
        IF (paren_close_ind=2)
         SET parsed_request->da_domain[q_cnt].filter_list[filter_list_sz].having_ind = 1
        ENDIF
        SET paren_cnt = (paren_cnt - 1)
        SET operator_end_pos = (findnode(xml_str,"/operator",filter_end_pos)+ 10)
        IF (((getnextnodename(xml_str,operator_end_pos)="/operator") OR (getnextnodename(xml_str,
         operator_end_pos)="/operator2"))
         AND paren_cnt > 0)
         SET filter_list_sz = (filter_list_sz+ 1)
         SET stat = alterlist(parsed_request->da_domain[q_cnt].filter_list,filter_list_sz)
         SET parsed_request->da_domain[q_cnt].filter_list[filter_list_sz].filter = concat(fillstring(
           value((8 * paren_cnt))," "),")")
         IF (paren_close_ind=2)
          SET parsed_request->da_domain[q_cnt].filter_list[filter_list_sz].having_ind = 1
         ENDIF
         SET paren_cnt = (paren_cnt - 1)
        ENDIF
       ENDIF
      ENDIF
      IF (operator_stack_sz > 0)
       SET filter_list_sz = (filter_list_sz+ 1)
       SET stat = alterlist(parsed_request->da_domain[q_cnt].filter_list,filter_list_sz)
       SET parsed_request->da_domain[q_cnt].filter_list[filter_list_sz].filter = concat(fillstring(
         value((8 * paren_cnt))," "),operator_stack->qual[operator_stack_sz].operator)
       SET paren_close_ind = operator_stack->qual[operator_stack_sz].paren_ind
       SET operator_stack_sz = (operator_stack_sz - 1)
       SET stat = alterlist(operator_stack->qual,operator_stack_sz)
      ENDIF
      SET cur_pos = findnode(xml_str,"/filter",cur_pos)
     ENDIF
     SET cur_node = getnextnode(xml_str,cur_pos)
     SET cur_pos = (findnode(xml_str,cur_node,cur_pos)+ 1)
   ENDWHILE
 ENDFOR
 SET stat = alterlist(pre_reply->qual,cnvtint(xcountquery))
 FOR (q_cnt = 1 TO cnvtint(xcountquery))
   SET select_cnt = 0
   SET tab_cnt = 0
   SET from_cnt = 0
   SET join_cnt = 0
   SET where_cnt = 0
   SET having_cnt = 0
   SET grp_by_cnt = 0
   SET ord_by_cnt = 0
   SET blob_clob_ind = 0
   SET ordby = 0
   SET end_of_select_fields = parsed_request->da_domain[q_cnt].select_element_cnt
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = end_of_select_fields),
     da_element e,
     long_text_reference cols
    PLAN (d)
     JOIN (e
     WHERE (e.element_uuid=parsed_request->da_domain[q_cnt].element_list[d.seq].element_uuid))
     JOIN (cols
     WHERE cols.long_text_id=e.column_string_txt_id)
    HEAD REPORT
     col_cnt = 0
    DETAIL
     col_cnt = (col_cnt+ 1), stat = alterlist(columns->qual,col_cnt), columns->qual[col_cnt].
     da_element_id = e.da_element_id,
     columns->qual[col_cnt].column_txt = concat(dacleancolumn(cols.long_text),' as "',trim(substring(
        1,30,parsed_request->da_domain[q_cnt].element_list[d.seq].name),3),'"'), ordby = e.sort_flag
     IF (((set_operator_ind != 0) OR (((subquery_global_ind != 0) OR (((order_by_ind=0) OR (e
     .element_type_cd=uar_get_code_by("MEANING",14170,"FACT"))) )) )) )
      ordby = 4
     ELSE
      IF (trim(e.qual_string_txt,3) != ""
       AND ((e.qual_data_type_flag=4) OR (e.qual_data_type_flag=5)) )
       blob_clob_ind = 1, ordby = 4
      ELSE
       IF (trim(cols.long_text,3) != ""
        AND ((e.result_data_type_flag=4) OR (e.result_data_type_flag=5)) )
        blob_clob_ind = 1, ordby = 4
       ENDIF
      ENDIF
     ENDIF
     IF (ordby != 4)
      IF (ordby=2
       AND trim(e.qual_string_txt,3) != "")
       columns->qual[col_cnt].ord_column_txt = dacleancolumn(e.qual_string_txt)
      ELSE
       IF (ordby=3
        AND trim(e.group_by_string_txt,3) != "")
        columns->qual[col_cnt].ord_column_txt = dacleancolumn(e.group_by_string_txt)
       ELSE
        columns->qual[col_cnt].ord_column_txt = dacleancolumn(cols.long_text)
       ENDIF
      ENDIF
     ENDIF
     uuid_loc = findstring(":uuid(",trim(cols.long_text,3))
     WHILE (uuid_loc > 0)
       uuid_start_pos = (uuid_loc+ 6), uuid_end_pos = findstring(")",trim(cols.long_text,3),
        uuid_start_pos), uuid_list_sz = (size(uuid_list->qual,5)+ 1),
       stat = alterlist(uuid_list->qual,uuid_list_sz), uuid_list->qual[uuid_list_sz].element_id = e
       .da_element_id, uuid_list->qual[uuid_list_sz].uuid = substring(uuid_start_pos,(uuid_end_pos -
        uuid_start_pos),trim(cols.long_text,3)),
       uuid_loc = findstring(":uuid(",trim(cols.long_text,3),(uuid_loc+ 1))
     ENDWHILE
    WITH nocounter
   ;end select
   IF (size(uuid_list->qual,5) > 0)
    DECLARE search_txt = vc WITH protect
    DECLARE new_txt = vc WITH protect
    SELECT INTO "NL:"
     FROM (dummyt d  WITH seq = size(uuid_list->qual,5)),
      da_element e,
      long_text_reference cols
     PLAN (d
      WHERE size(uuid_list->qual[d.seq],5) > 0)
      JOIN (e
      WHERE (e.element_uuid=uuid_list->qual[d.seq].uuid))
      JOIN (cols
      WHERE cols.long_text_id=e.column_string_txt_id)
     DETAIL
      search_txt = concat(":uuid(",uuid_list->qual[d.seq].uuid,")"), col_idx = locateval(num,1,size(
        columns->qual,5),uuid_list->qual[d.seq].element_id,columns->qual[num].da_element_id), new_txt
       = replace(columns->qual[col_idx].column_txt,search_txt,trim(cols.long_text,3)),
      grp_ord_new_txt = replace(columns->qual[col_idx].ord_column_txt,search_txt,trim(cols.long_text,
        3)), columns->qual[col_idx].column_txt = dacleancolumn(new_txt), columns->qual[col_idx].
      ord_column_txt = dacleancolumn(grp_ord_new_txt)
     WITH nocounter
    ;end select
   ENDIF
   SET select_cnt = (select_cnt+ 1)
   SET stat = alterlist(query->select_clause,select_cnt)
   SET query->select_clause[select_cnt].line = concat("SELECT ",hint_str)
   FOR (i = 1 TO size(columns->qual,5))
     SET select_cnt = (select_cnt+ 1)
     SET stat = alterlist(query->select_clause,select_cnt)
     SET query->select_clause[select_cnt].line = evaluate(select_cnt,1,concat(" SELECT ",hint_str," ",
       columns->qual[i].column_txt),concat(evaluate(i,1,"       ","     , "),columns->qual[i].
       column_txt))
     SET hint_str = " "
     IF ((columns->qual[i].ord_column_txt != ""))
      SET ord_by_cnt = (ord_by_cnt+ 1)
      SET stat = alterlist(query->order_by_clause,ord_by_cnt)
      SET query->order_by_clause[ord_by_cnt].line = evaluate(ord_by_cnt,1,concat(" ORDER BY ",columns
        ->qual[i].ord_column_txt," Nulls First "),concat("     , ",columns->qual[i].ord_column_txt,
        " Nulls First "))
     ENDIF
   ENDFOR
   SELECT INTO "NL:"
    FROM da_table_reltn tr
    PLAN (tr
     WHERE tr.parent_entity_name="DA_DOMAIN"
      AND (tr.parent_entity_id=parsed_request->da_domain[q_cnt].da_domain_id)
      AND tr.required_ind=1)
    DETAIL
     IF (locateval(num,1,size(table_joins->qual,5),tr.da_table_reltn_id,table_joins->qual[num].
      da_table_reltn_id)=0)
      join_cnt = (join_cnt+ 1), stat = alterlist(table_joins->qual,join_cnt), table_joins->qual[
      join_cnt].da_table_reltn_id = tr.da_table_reltn_id
     ENDIF
     IF (locateval(num,1,size(tables->qual,5),tr.table_id,tables->qual[num].table_id)=0)
      tab_cnt = (tab_cnt+ 1), stat = alterlist(tables->qual,tab_cnt), tables->qual[tab_cnt].table_id
       = tr.table_id
     ENDIF
     IF (locateval(num,1,size(tables->qual,5),tr.join_table_id,tables->qual[num].table_id)=0
      AND tr.join_table_id != 0)
      tab_cnt = (tab_cnt+ 1), stat = alterlist(tables->qual,tab_cnt), tables->qual[tab_cnt].table_id
       = tr.join_table_id
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "NL:"
    FROM da_domain_bv_reltn d_b,
     da_bv_lv_elem_reltn b_l_e,
     da_table_reltn tr
    PLAN (d_b
     WHERE (d_b.da_domain_id=parsed_request->da_domain[q_cnt].da_domain_id)
      AND d_b.required_ind=1)
     JOIN (b_l_e
     WHERE b_l_e.da_bus_view_id=d_b.da_bus_view_id)
     JOIN (tr
     WHERE tr.parent_entity_name="DA_LOGICAL_VIEW"
      AND tr.parent_entity_id=b_l_e.da_logical_view_id
      AND tr.required_ind=1)
    DETAIL
     IF (locateval(num,1,size(table_joins->qual,5),tr.da_table_reltn_id,table_joins->qual[num].
      da_table_reltn_id)=0)
      join_cnt = (join_cnt+ 1), stat = alterlist(table_joins->qual,join_cnt), table_joins->qual[
      join_cnt].da_table_reltn_id = tr.da_table_reltn_id
     ENDIF
     IF (locateval(num,1,size(tables->qual,5),tr.table_id,tables->qual[num].table_id)=0)
      tab_cnt = (tab_cnt+ 1), stat = alterlist(tables->qual,tab_cnt), tables->qual[tab_cnt].table_id
       = tr.table_id
     ENDIF
     IF (locateval(num,1,size(tables->qual,5),tr.join_table_id,tables->qual[num].table_id)=0
      AND tr.join_table_id != 0)
      tab_cnt = (tab_cnt+ 1), stat = alterlist(tables->qual,tab_cnt), tables->qual[tab_cnt].table_id
       = tr.join_table_id
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = size(columns->qual,5)),
     da_lv_table_elem_reltn l_t_e,
     da_table_reltn tr,
     da_bv_lv_elem_reltn b_l_e,
     da_domain_bv_reltn d_b
    PLAN (d)
     JOIN (l_t_e
     WHERE (l_t_e.da_element_id=columns->qual[d.seq].da_element_id))
     JOIN (tr
     WHERE tr.parent_entity_name="DA_LOGICAL_VIEW"
      AND tr.parent_entity_id=l_t_e.da_logical_view_id
      AND tr.required_ind=1)
     JOIN (b_l_e
     WHERE b_l_e.da_logical_view_id=l_t_e.da_logical_view_id)
     JOIN (d_b
     WHERE (d_b.da_domain_id=parsed_request->da_domain[q_cnt].da_domain_id)
      AND d_b.da_bus_view_id=b_l_e.da_bus_view_id)
    ORDER BY l_t_e.da_logical_view_id
    HEAD l_t_e.da_logical_view_id
     row + 0
    DETAIL
     IF (locateval(num,1,size(table_joins->qual,5),tr.da_table_reltn_id,table_joins->qual[num].
      da_table_reltn_id)=0)
      join_cnt = (join_cnt+ 1), stat = alterlist(table_joins->qual,join_cnt), table_joins->qual[
      join_cnt].da_table_reltn_id = tr.da_table_reltn_id
     ENDIF
     IF (locateval(num,1,size(tables->qual,5),tr.table_id,tables->qual[num].table_id)=0)
      tab_cnt = (tab_cnt+ 1), stat = alterlist(tables->qual,tab_cnt), tables->qual[tab_cnt].table_id
       = tr.table_id
     ENDIF
     IF (locateval(num,1,size(tables->qual,5),tr.join_table_id,tables->qual[num].table_id)=0
      AND tr.join_table_id != 0)
      tab_cnt = (tab_cnt+ 1), stat = alterlist(tables->qual,tab_cnt), tables->qual[tab_cnt].table_id
       = tr.join_table_id
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = size(columns->qual,5)),
     da_lv_table_elem_reltn l_t_e,
     da_table_reltn tr,
     da_bv_lv_elem_reltn b_l_e,
     da_domain_bv_reltn d_b,
     da_logical_view l_v
    PLAN (d)
     JOIN (l_t_e
     WHERE (l_t_e.da_element_id=columns->qual[d.seq].da_element_id))
     JOIN (l_v
     WHERE l_v.parent_logical_view_id=l_t_e.da_logical_view_id)
     JOIN (tr
     WHERE tr.parent_entity_name="DA_LOGICAL_VIEW"
      AND tr.parent_entity_id=l_v.parent_logical_view_id
      AND tr.required_ind=1)
     JOIN (b_l_e
     WHERE b_l_e.da_logical_view_id=l_v.da_logical_view_id)
     JOIN (d_b
     WHERE (d_b.da_domain_id=parsed_request->da_domain[q_cnt].da_domain_id)
      AND d_b.da_bus_view_id=b_l_e.da_bus_view_id)
    ORDER BY l_v.da_logical_view_id
    HEAD l_v.da_logical_view_id
     row + 0
    DETAIL
     IF (locateval(num,1,size(table_joins->qual,5),tr.da_table_reltn_id,table_joins->qual[num].
      da_table_reltn_id)=0)
      join_cnt = (join_cnt+ 1), stat = alterlist(table_joins->qual,join_cnt), table_joins->qual[
      join_cnt].da_table_reltn_id = tr.da_table_reltn_id
     ENDIF
     IF (locateval(num,1,size(tables->qual,5),tr.table_id,tables->qual[num].table_id)=0)
      tab_cnt = (tab_cnt+ 1), stat = alterlist(tables->qual,tab_cnt), tables->qual[tab_cnt].table_id
       = tr.table_id
     ENDIF
     IF (locateval(num,1,size(tables->qual,5),tr.join_table_id,tables->qual[num].table_id)=0
      AND tr.join_table_id != 0)
      tab_cnt = (tab_cnt+ 1), stat = alterlist(tables->qual,tab_cnt), tables->qual[tab_cnt].table_id
       = tr.join_table_id
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = size(parsed_request->da_domain[q_cnt].element_list,5)),
     da_element e,
     da_lv_table_elem_reltn l_t_e,
     da_bv_lv_elem_reltn b_l_e,
     da_domain_bv_reltn d_b
    PLAN (d)
     JOIN (e
     WHERE (e.element_uuid=parsed_request->da_domain[q_cnt].element_list[d.seq].element_uuid))
     JOIN (l_t_e
     WHERE l_t_e.da_element_id=e.da_element_id
      AND l_t_e.da_table_info_id > 0)
     JOIN (b_l_e
     WHERE b_l_e.da_logical_view_id=l_t_e.da_logical_view_id)
     JOIN (d_b
     WHERE (d_b.da_domain_id=parsed_request->da_domain[q_cnt].da_domain_id)
      AND d_b.da_bus_view_id=b_l_e.da_bus_view_id)
    ORDER BY l_t_e.da_table_info_id
    HEAD l_t_e.da_table_info_id
     IF (locateval(num,1,size(tables->qual,5),l_t_e.da_table_info_id,tables->qual[num].table_id)=0)
      tab_cnt = (tab_cnt+ 1), stat = alterlist(tables->qual,tab_cnt), tables->qual[tab_cnt].table_id
       = l_t_e.da_table_info_id
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = size(parsed_request->da_domain[q_cnt].element_list,5)),
     da_element e,
     da_lv_table_elem_reltn lter,
     da_bv_lv_elem_reltn bler,
     da_domain_bv_reltn db,
     da_logical_view lv
    PLAN (d)
     JOIN (e
     WHERE (e.element_uuid=parsed_request->da_domain[q_cnt].element_list[d.seq].element_uuid))
     JOIN (lter
     WHERE lter.da_element_id=e.da_element_id
      AND lter.da_table_info_id > 0)
     JOIN (lv
     WHERE lv.parent_logical_view_id=lter.da_logical_view_id)
     JOIN (bler
     WHERE bler.da_logical_view_id=lv.da_logical_view_id)
     JOIN (db
     WHERE (db.da_domain_id=parsed_request->da_domain[q_cnt].da_domain_id)
      AND db.da_bus_view_id=bler.da_bus_view_id)
    ORDER BY lter.da_table_info_id
    HEAD lter.da_table_info_id
     IF (locateval(num,1,size(tables->qual,5),lter.da_table_info_id,tables->qual[num].table_id)=0)
      tab_cnt = (tab_cnt+ 1), stat = alterlist(tables->qual,tab_cnt), tables->qual[tab_cnt].table_id
       = lter.da_table_info_id
     ENDIF
    WITH nocounter
   ;end select
   DECLARE dabuildgraph(domain_id=f8,recgraph=vc(ref)) = null WITH public
   RECORD da_graph(
     1 vertex_list[*]
       2 vertex_id = f8
       2 edge_list[*]
         3 edge_id = f8
         3 adjacent_vertex_id = f8
   )
   RECORD da_vertices(
     1 qual[*]
       2 vertex_id = f8
   )
   RECORD da_edges(
     1 qual[*]
       2 edge_id = f8
   )
   CALL dabuildgraph(parsed_request->da_domain[q_cnt].da_domain_id,da_graph)
   SET stat = alterlist(da_vertices->qual,size(tables->qual,5))
   FOR (i = 1 TO size(tables->qual,5))
     SET da_vertices->qual[i].vertex_id = tables->qual[i].table_id
   ENDFOR
   SET stat = alterlist(da_edges->qual,size(table_joins->qual,5))
   FOR (i = 1 TO size(table_joins->qual,5))
     SET da_edges->qual[i].edge_id = table_joins->qual[i].da_table_reltn_id
   ENDFOR
   EXECUTE da_find_tree  WITH replace(graph,da_graph), replace(vertices,da_vertices), replace(edges,
    da_edges)
   SET stat = alterlist(tables->qual,size(da_vertices->qual,5))
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = size(da_vertices->qual,5)),
     da_table_info t
    PLAN (d)
     JOIN (t
     WHERE (t.da_table_info_id=da_vertices->qual[d.seq].vertex_id))
    DETAIL
     tables->qual[d.seq].table_id = t.da_table_info_id, tables->qual[d.seq].table_name = concat(trim(
       t.table_name)," ",t.table_alias_name)
    WITH nocounter
   ;end select
   SET stat = alterlist(table_joins->qual,size(da_edges->qual,5))
   IF (size(da_edges->qual,5) > 0)
    SELECT INTO "NL:"
     FROM (dummyt d  WITH seq = size(da_edges->qual,5)),
      da_table_reltn tr,
      long_text_reference whr
     PLAN (d)
      JOIN (tr
      WHERE (tr.da_table_reltn_id=da_edges->qual[d.seq].edge_id))
      JOIN (whr
      WHERE whr.long_text_id=tr.where_clause_txt_id
       AND tr.where_clause_txt_id > 0)
     DETAIL
      table_joins->qual[d.seq].da_table_reltn_id = tr.da_table_reltn_id, table_joins->qual[d.seq].
      table_join_txt = dacleancolumn(whr.long_text)
     WITH nocounter
    ;end select
   ENDIF
   FOR (i = 1 TO size(tables->qual,5))
     SET from_cnt = (from_cnt+ 1)
     SET stat = alterlist(query->from_clause,from_cnt)
     SET query->from_clause[from_cnt].line = evaluate(from_cnt,1,concat(" FROM ",tables->qual[i].
       table_name),concat("   , ",tables->qual[i].table_name))
   ENDFOR
   FOR (i = 1 TO size(table_joins->qual,5))
     IF (size(trim(table_joins->qual[i].table_join_txt,3)) > 0)
      SET where_cnt = (where_cnt+ 1)
      SET stat = alterlist(query->where_clause,where_cnt)
      SET query->where_clause[where_cnt].line = evaluate(where_cnt,1,concat(" WHERE ",table_joins->
        qual[i].table_join_txt),concat("  AND ",table_joins->qual[i].table_join_txt))
     ENDIF
   ENDFOR
   SET where_filter_cnt = 0
   SET having_filter_cnt = 0
   FOR (i = 1 TO size(parsed_request->da_domain[q_cnt].filter_list,5))
     IF (size(trim(parsed_request->da_domain[q_cnt].filter_list[i].filter,3)) > 0)
      IF ((parsed_request->da_domain[q_cnt].filter_list[i].having_ind != 1))
       SET where_cnt = (where_cnt+ 1)
       SET where_filter_cnt = (where_filter_cnt+ 1)
       SET stat = alterlist(query->where_clause,where_cnt)
       SET query->where_clause[where_cnt].line = evaluate(where_cnt,1,concat(" WHERE ",parsed_request
         ->da_domain[q_cnt].filter_list[i].filter),evaluate(where_filter_cnt,1,concat("  AND ",
          parsed_request->da_domain[q_cnt].filter_list[i].filter),concat("   ",parsed_request->
          da_domain[q_cnt].filter_list[i].filter)))
      ELSE
       SET having_cnt = (having_cnt+ 1)
       SET having_filter_cnt = (having_filter_cnt+ 1)
       SET stat = alterlist(query->having_clause,having_cnt)
       SET query->having_clause[having_cnt].line = evaluate(having_cnt,1,concat(" HAVING ",
         parsed_request->da_domain[q_cnt].filter_list[i].filter),evaluate(having_filter_cnt,1,concat(
          "  AND ",parsed_request->da_domain[q_cnt].filter_list[i].filter),concat("   ",
          parsed_request->da_domain[q_cnt].filter_list[i].filter)))
      ENDIF
     ENDIF
   ENDFOR
   IF (use_rnum=1)
    SET use_rnum = 0
    SET where_cnt = (where_cnt+ 1)
    SET stat = alterlist(query->where_clause,where_cnt)
    SET query->where_clause[where_cnt].line = evaluate(where_cnt,1,concat(" WHERE ",rnum_qual),concat
     ("  AND ",rnum_qual))
   ENDIF
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = size(columns->qual,5)),
     da_element e,
     long_text_reference ltr
    PLAN (d)
     JOIN (e
     WHERE (e.da_element_id=columns->qual[d.seq].da_element_id)
      AND e.where_clause_txt_id > 0)
     JOIN (ltr
     WHERE ltr.long_text_id=e.where_clause_txt_id)
    DETAIL
     IF (trim(ltr.long_text,3) != "")
      where_cnt = (where_cnt+ 1), stat = alterlist(query->where_clause,where_cnt), query->
      where_clause[where_cnt].line = evaluate(where_cnt,1,concat(" WHERE ",trim(ltr.long_text,3)),
       concat("   AND ",trim(ltr.long_text,3)))
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = size(columns->qual,5)),
     da_element e,
     long_text_reference cols
    PLAN (d)
     JOIN (e
     WHERE (e.da_element_id=columns->qual[d.seq].da_element_id))
     JOIN (cols
     WHERE cols.long_text_id=e.column_string_txt_id)
    DETAIL
     IF (blob_clob_ind=0
      AND group_by_ind != 0)
      IF (e.group_by_ind=1
       AND size(trim(e.group_by_string_txt,3)) > 0)
       grp_by_cnt = (grp_by_cnt+ 1), stat = alterlist(query->group_by_clause,grp_by_cnt), query->
       group_by_clause[grp_by_cnt].line = evaluate(grp_by_cnt,1,concat(" GROUP BY ",dacleancolumn(e
          .group_by_string_txt)),concat("  , ",dacleancolumn(e.group_by_string_txt)))
      ENDIF
      IF (e.group_by_qual_ind=1
       AND size(trim(e.qual_string_txt,3)) > 0)
       grp_by_cnt = (grp_by_cnt+ 1), stat = alterlist(query->group_by_clause,grp_by_cnt), query->
       group_by_clause[grp_by_cnt].line = evaluate(grp_by_cnt,1,concat(" GROUP BY ",dacleancolumn(e
          .qual_string_txt)),concat("  , ",dacleancolumn(e.qual_string_txt)))
      ENDIF
      IF (e.group_by_column_ind=1
       AND size(trim(cols.long_text,3)) > 0)
       grp_by_cnt = (grp_by_cnt+ 1), stat = alterlist(query->group_by_clause,grp_by_cnt), grp_by_pos
        = findstring(" as ",columns->qual[d.seq].column_txt,1,size(columns->qual[d.seq].column_txt,1)
        ),
       grp_by_txt = substring(1,grp_by_pos,columns->qual[d.seq].column_txt), query->group_by_clause[
       grp_by_cnt].line = evaluate(grp_by_cnt,1,concat(" GROUP BY ",grp_by_txt),concat("     , ",
         grp_by_txt))
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   SET pre_reply->qual[q_cnt].query_name = parsed_request->da_domain[q_cnt].query_list_name
   FOR (i = 1 TO size(query->select_clause,5))
     SET pre_reply->qual[q_cnt].query_str = concat(pre_reply->qual[q_cnt].query_str,query->
      select_clause[i].line,char(10))
   ENDFOR
   FOR (i = 1 TO size(query->from_clause,5))
     SET pre_reply->qual[q_cnt].query_str = concat(pre_reply->qual[q_cnt].query_str,query->
      from_clause[i].line,char(10))
   ENDFOR
   FOR (i = 1 TO size(query->where_clause,5))
     SET pre_reply->qual[q_cnt].query_str = concat(pre_reply->qual[q_cnt].query_str,query->
      where_clause[i].line,char(10))
   ENDFOR
   FOR (i = 1 TO size(query->group_by_clause,5))
     SET pre_reply->qual[q_cnt].query_str = concat(pre_reply->qual[q_cnt].query_str,query->
      group_by_clause[i].line,char(10))
   ENDFOR
   FOR (i = 1 TO size(query->having_clause,5))
     SET pre_reply->qual[q_cnt].query_str = concat(pre_reply->qual[q_cnt].query_str,query->
      having_clause[i].line,char(10))
   ENDFOR
   FOR (i = 1 TO size(query->order_by_clause,5))
     SET pre_reply->qual[q_cnt].query_str = concat(pre_reply->qual[q_cnt].query_str,query->
      order_by_clause[i].line,char(10))
   ENDFOR
   SET pre_reply->qual[q_cnt].query_str = replace(replace(replace(replace(replace(replace(pre_reply->
         qual[q_cnt].query_str,"&quot;",'"',0),"&apos;","'",0),"&amp;","&",0),"&lt;","<",0),"&gt;",
     ">",0),"&#xD;","",0)
   SET stat = alterlist(columns->qual,0)
   SET stat = alterlist(uuid_list->qual,0)
   SET stat = alterlist(table_joins->qual,0)
   SET stat = alterlist(tables->qual,0)
   SET stat = alterlist(da_vertices->qual,0)
   SET stat = alterlist(da_edges->qual,0)
   SET stat = alterlist(query->select_clause,0)
   SET stat = alterlist(query->from_clause,0)
   SET stat = alterlist(query->where_clause,0)
   SET stat = alterlist(query->group_by_clause,0)
   SET stat = alterlist(query->having_clause,0)
 ENDFOR
 CALL echorecord(sub_query_org)
 CALL echorecord(parsed_request)
 CALL echorecord(pre_reply)
 CALL echo(build("Combined string after SET operator: ",set_operator_string))
 IF (trim(set_operator_string,3) != "")
  SET reply->query_str = set_operator_string
  FOR (i = 1 TO cnvtint(xcountquery))
    SET reply->query_str = dareplacequery(reply->query_str,trim(build("Query",i)),build("( ",
      pre_reply->qual[i].query_str," )"))
  ENDFOR
 ELSE
  IF (size(sub_query_org->qual,5) > 0)
   FOR (i = 1 TO cnvtint(xcountquery))
    SET start_query = concat("Query",cnvtstring(i))
    IF (locateval(sub_idx,1,size(sub_query_org->qual,5),start_query,sub_query_org->qual[sub_idx].
     query_name)=0)
     SET start_query_indx = i
    ENDIF
   ENDFOR
   SET reply->query_str = pre_reply->qual[start_query_indx].query_str
  ELSE
   SET reply->query_str = pre_reply->qual[1].query_str
  ENDIF
 ENDIF
 FOR (i = 1 TO size(sub_query_org->qual,5))
   IF ((sub_query_org->qual[i].parent_query_name != " "))
    SET query_num = cnvtint(substring(6,(textlen(sub_query_org->qual[i].query_name) - 5),
      sub_query_org->qual[i].query_name))
    SET reply->query_str = dareplacequery(reply->query_str,sub_query_org->qual[i].query_name,build(
      "( ",pre_reply->qual[query_num].query_str," )"))
   ENDIF
 ENDFOR
 SET reply->query_str = concat("/* ",engine_version," */",char(10),reply->query_str)
 CALL echo("Final Query is:")
 CALL echo(reply->query_str)
 SUBROUTINE dabuildgraph(domain_id,recgraph)
   DECLARE vertex_cnt = i4 WITH noconstant(0)
   DECLARE edge_cnt = i4 WITH noconstant(0)
   DECLARE num = i4 WITH noconstant(0), protect
   SELECT INTO "NL:"
    FROM da_table_reltn tr
    WHERE tr.parent_entity_name="DA_DOMAIN"
     AND tr.parent_entity_id=domain_id
    HEAD REPORT
     vertex_cnt = 0, edge_cnt = 0
    DETAIL
     v_idx = locateval(num,1,size(recgraph->vertex_list,5),tr.table_id,recgraph->vertex_list[num].
      vertex_id)
     IF (v_idx=0)
      vertex_cnt = (vertex_cnt+ 1), stat = alterlist(recgraph->vertex_list,vertex_cnt), v_idx =
      vertex_cnt,
      recgraph->vertex_list[v_idx].vertex_id = tr.table_id
     ENDIF
     edge_cnt = (size(recgraph->vertex_list[v_idx].edge_list,5)+ 1), stat = alterlist(recgraph->
      vertex_list[v_idx].edge_list,edge_cnt), recgraph->vertex_list[v_idx].edge_list[edge_cnt].
     edge_id = tr.da_table_reltn_id,
     recgraph->vertex_list[v_idx].edge_list[edge_cnt].adjacent_vertex_id = tr.join_table_id
     IF (tr.join_table_id > 0)
      v_idx = locateval(num,1,size(recgraph->vertex_list,5),tr.join_table_id,recgraph->vertex_list[
       num].vertex_id)
      IF (v_idx=0)
       vertex_cnt = (vertex_cnt+ 1), stat = alterlist(recgraph->vertex_list,vertex_cnt), v_idx =
       vertex_cnt,
       recgraph->vertex_list[v_idx].vertex_id = tr.join_table_id
      ENDIF
      edge_cnt = (size(recgraph->vertex_list[v_idx].edge_list,5)+ 1), stat = alterlist(recgraph->
       vertex_list[v_idx].edge_list,edge_cnt), recgraph->vertex_list[v_idx].edge_list[edge_cnt].
      edge_id = tr.da_table_reltn_id,
      recgraph->vertex_list[v_idx].edge_list[edge_cnt].adjacent_vertex_id = tr.table_id
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "NL:"
    da_table_reltn_id = trc.da_table_reltn_id, table_id = trc.table_id, join_table_id = trc
    .join_table_id
    FROM da_domain_bv_reltn dbc,
     da_bv_lv_elem_reltn blec,
     da_table_reltn trc
    WHERE dbc.da_domain_id=domain_id
     AND blec.da_bus_view_id=dbc.da_bus_view_id
     AND trc.parent_entity_name="DA_LOGICAL_VIEW"
     AND ((trc.parent_entity_id=blec.da_logical_view_id) UNION (
    (SELECT
     trp.da_table_reltn_id, trp.table_id, trp.join_table_id
     FROM da_domain_bv_reltn dbp,
      da_bv_lv_elem_reltn blep,
      da_logical_view lvc,
      da_table_reltn trp
     WHERE dbp.da_domain_id=domain_id
      AND blep.da_bus_view_id=dbp.da_bus_view_id
      AND lvc.da_logical_view_id=blep.da_logical_view_id
      AND trp.parent_entity_name="DA_LOGICAL_VIEW"
      AND trp.parent_entity_id=lvc.parent_logical_view_id)))
    ORDER BY da_table_reltn_id
    HEAD da_table_reltn_id
     v_idx = locateval(num,1,size(recgraph->vertex_list,5),table_id,recgraph->vertex_list[num].
      vertex_id)
     IF (v_idx=0)
      vertex_cnt = (vertex_cnt+ 1), stat = alterlist(recgraph->vertex_list,vertex_cnt), v_idx =
      vertex_cnt,
      recgraph->vertex_list[v_idx].vertex_id = table_id
     ENDIF
     edge_idx = locateval(num,1,size(recgraph->vertex_list[v_idx].edge_list,5),da_table_reltn_id,
      recgraph->vertex_list[v_idx].edge_list[num].edge_id)
     IF (edge_idx=0)
      edge_cnt = (size(recgraph->vertex_list[v_idx].edge_list,5)+ 1), stat = alterlist(recgraph->
       vertex_list[v_idx].edge_list,edge_cnt), recgraph->vertex_list[v_idx].edge_list[edge_cnt].
      edge_id = da_table_reltn_id,
      recgraph->vertex_list[v_idx].edge_list[edge_cnt].adjacent_vertex_id = join_table_id
     ENDIF
     IF (join_table_id > 0)
      v_idx = locateval(num,1,size(recgraph->vertex_list,5),join_table_id,recgraph->vertex_list[num].
       vertex_id)
      IF (v_idx=0)
       vertex_cnt = (vertex_cnt+ 1), stat = alterlist(recgraph->vertex_list,vertex_cnt), v_idx =
       vertex_cnt,
       recgraph->vertex_list[v_idx].vertex_id = join_table_id
      ENDIF
      edge_idx = locateval(num,1,size(recgraph->vertex_list[v_idx].edge_list,5),da_table_reltn_id,
       recgraph->vertex_list[v_idx].edge_list[num].edge_id)
      IF (edge_idx=0)
       edge_cnt = (size(recgraph->vertex_list[v_idx].edge_list,5)+ 1), stat = alterlist(recgraph->
        vertex_list[v_idx].edge_list,edge_cnt), recgraph->vertex_list[v_idx].edge_list[edge_cnt].
       edge_id = da_table_reltn_id,
       recgraph->vertex_list[v_idx].edge_list[edge_cnt].adjacent_vertex_id = table_id
      ENDIF
     ENDIF
    WITH nocounter, rdbunion
   ;end select
 END ;Subroutine
 SUBROUTINE dacleancolumn(column)
   DECLARE return_val = vc
   SET return_val = replace(replace(replace(trim(column,3),":CURUTC",build(curutc)),":CURTIMEZONEAPP",
     build(curtimezoneapp)),":CURTIMEZONESYS",build(curtimezonesys))
   RETURN(return_val)
 END ;Subroutine
 SUBROUTINE isnextnodeempty(source,start_position)
   DECLARE begin_pos = i4
   DECLARE end_pos = i4
   DECLARE prev_char = c1 WITH noconstant("X")
   SET begin_pos = findstring("<",source,start_position)
   IF (begin_pos > 0)
    SET end_pos = findstring(">",source,begin_pos)
    SET prev_char = substring((end_pos - 1),1,source)
   ENDIF
   IF (prev_char="/")
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE findnode(source,nodename,start_position)
   RETURN(findstring(concat("<",nodename),source,start_position))
 END ;Subroutine
 SUBROUTINE gettagbyname(string,name,pos,tag)
   DECLARE tag_begin = i4 WITH protect
   DECLARE tag_end = i4 WITH protect
   DECLARE tag_name = vc WITH protect
   DECLARE name_begin = i4 WITH protect
   DECLARE name_end = i4 WITH protect
   DECLARE char = c1 WITH protect
   DECLARE max_pos = i4 WITH protect, constant(textlen(string))
   WHILE (pos < max_pos)
    SET char = substring(pos,1,string)
    IF (char="<")
     SET tag_begin = pos
     SET tag_end = findtagend(string,pos)
     IF (tag_end > 0)
      IF (substring((tag_begin+ 1),1,string) IN (char(63), "!"))
       SET name_begin = (tag_begin+ 2)
      ELSE
       SET name_begin = (tag_begin+ 1)
      ENDIF
      SET name_end = readnametoken(string,name_begin,tag_name)
      SET char = substring(name_end,1,string)
      IF (name_end > 0
       AND ((name_end=tag_end) OR ((((name_end=(tag_end - 1))
       AND char="/") OR (char IN (" ", char(9), char(10), char(13)))) )) )
       IF (name=tag_name)
        SET tag = substring((tag_begin+ 1),((tag_end - tag_begin) - 1),string)
        RETURN(tag_end)
       ENDIF
      ENDIF
     ELSE
      RETURN(tag_end)
     ENDIF
     SET pos = tag_end
    ELSE
     SET pos = (pos+ 1)
    ENDIF
   ENDWHILE
   RETURN(0)
 END ;Subroutine
 SUBROUTINE getnexttag(string,pos,tag)
   DECLARE tag_begin = i4 WITH protect
   DECLARE tag_end = i4 WITH protect
   DECLARE char = c1 WITH protect
   DECLARE max_pos = i4 WITH protect, constant(textlen(string))
   WHILE (pos < max_pos)
    SET char = substring(pos,1,string)
    IF (char="<")
     SET tag_begin = pos
     SET tag_end = findtagend(string,pos)
     IF (tag_end > 0)
      SET tag = substring((tag_begin+ 1),((tag_end - tag_begin) - 1),string)
      RETURN(tag_end)
     ELSE
      RETURN(tag_end)
     ENDIF
     SET pos = tag_end
    ELSE
     SET pos = (pos+ 1)
    ENDIF
   ENDWHILE
   RETURN(0)
 END ;Subroutine
 SUBROUTINE findtagend(string,pos)
   DECLARE length = i4 WITH protect, noconstant(textlen(string))
   DECLARE openq = c1 WITH protect, noconstant(" ")
   DECLARE char = c1 WITH protect
   IF (substring(pos,4,string)="<!--")
    SET pos = findstring("-->",string,(pos+ 4))
    IF (pos > 0)
     RETURN(pos)
    ELSE
     RETURN(- (1))
    ENDIF
   ELSEIF (substring(pos,9,string)="<![CDATA[")
    SET pos = findstring("]]>",string,(pos+ 9))
    IF (pos > 0)
     RETURN(pos)
    ELSE
     RETURN(- (1))
    ENDIF
   ENDIF
   WHILE (pos < length)
     SET pos = (pos+ 1)
     SET char = substring(pos,1,string)
     IF (char IN ('"', "'"))
      IF (openq=" ")
       SET openq = char
      ELSEIF (openq=char)
       SET openq = " "
      ENDIF
     ELSEIF (char=">"
      AND openq=" ")
      RETURN(pos)
     ELSEIF (char="<"
      AND openq=" ")
      RETURN(- (1))
     ENDIF
   ENDWHILE
   RETURN(- (1))
 END ;Subroutine
 SUBROUTINE skipwhitespace(string,pos,max)
   DECLARE char = c1 WITH protect
   SET char = substring(pos,1,string)
   WHILE (pos <= max
    AND char IN (" ", char(9), char(10), char(13)))
    SET pos = (pos+ 1)
    SET char = substring(pos,1,string)
   ENDWHILE
   IF (pos > max)
    SET pos = 0
   ENDIF
   RETURN(pos)
 END ;Subroutine
 SUBROUTINE readnametoken(string,pos,name)
   DECLARE begin = i4 WITH protect, constant(pos)
   DECLARE char = c1 WITH protect
   SET char = substring(pos,1,string)
   IF ( NOT (((char BETWEEN char(65) AND char(90)) OR (((char BETWEEN char(97) AND char(122)) OR (
   char IN ("_", ":"))) )) ))
    RETURN(0)
   ENDIF
   WHILE (((char BETWEEN char(65) AND char(90)) OR (((char BETWEEN char(97) AND char(122)) OR (((char
    BETWEEN "0" AND "9") OR (char IN (".", "-", "_", ":"))) )) )) )
    SET pos = (pos+ 1)
    SET char = substring(pos,1,string)
   ENDWHILE
   SET name = substring(begin,(pos - begin),string)
   RETURN(pos)
 END ;Subroutine
 SUBROUTINE getnodeattribute(node,attrib_name)
   DECLARE name = vc WITH protect, constant(trim(attrib_name,3))
   DECLARE name_len = i4 WITH protect, constant(textlen(name))
   DECLARE max_len = i4 WITH protect, constant(textlen(node))
   DECLARE pos = i4 WITH protect, noconstant(1)
   DECLARE openq = i4 WITH protect
   DECLARE closeq = i4 WITH protect
   DECLARE quote = c1 WITH protect
   DECLARE str = vc WITH protect
   WHILE (pos < max_len
    AND  NOT (substring(pos,1,node) IN (" ", char(9), char(10), char(13))))
     SET pos = (pos+ 1)
   ENDWHILE
   WHILE (pos > 0
    AND pos < max_len)
     SET pos = skipwhitespace(node,pos,max_len)
     SET pos = readnametoken(node,pos,str)
     SET pos = skipwhitespace(node,pos,max_len)
     IF (pos > 0
      AND substring(pos,1,node)="=")
      SET pos = skipwhitespace(node,(pos+ 1),max_len)
      IF (pos > 0)
       SET openq = pos
       SET quote = substring(openq,1,node)
       IF (quote IN ("'", '"'))
        SET closeq = findstring(quote,node,(openq+ 1))
        IF (closeq <= 0)
         RETURN("")
        ENDIF
        IF (str=name)
         RETURN(substring((openq+ 1),((closeq - openq) - 1),node))
        ENDIF
        SET pos = (closeq+ 1)
       ELSE
        RETURN("")
       ENDIF
      ELSE
       RETURN("")
      ENDIF
     ELSE
      RETURN("")
     ENDIF
   ENDWHILE
   RETURN("")
 END ;Subroutine
 SUBROUTINE getnextnode(source,start_position)
   DECLARE return_val = vc WITH noconstant("")
   DECLARE begin_pos = i4
   DECLARE end_pos = i4
   SET begin_pos = findstring("<",source,start_position)
   IF (begin_pos > 0)
    SET end_pos = findstring(">",source,begin_pos)
    SET return_val = substring((begin_pos+ 1),((end_pos - begin_pos) - 1),source)
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 SUBROUTINE getnextnodename(source,start_position)
   DECLARE return_val = vc WITH noconstant("")
   DECLARE begin_pos = i4
   DECLARE end_pos = i4
   SET begin_pos = findstring("<",source,start_position)
   IF (begin_pos > 0)
    SET end_pos = minval(evaluate(findstring(" ",source,begin_pos),0,1000000,findstring(" ",source,
       begin_pos)),evaluate(findstring(">",source,begin_pos),0,1000000,findstring(">",source,
       begin_pos)))
    SET return_val = substring((begin_pos+ 1),((end_pos - begin_pos) - 1),source)
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 SUBROUTINE dareplacequery(query_text,query_name,replace_query)
   DECLARE qlen = i4 WITH protect, constant(textlen(query_text))
   DECLARE pos = i4 WITH protect, noconstant(1)
   DECLARE npos = i4 WITH protect, noconstant(1)
   DECLARE sqpos = i4 WITH protect, noconstant(1)
   DECLARE lqpos = i4 WITH protect, noconstant(1)
   DECLARE rquery = vc WITH protect
   WHILE (pos < qlen)
     SET sqpos = findstring(query_name,query_text,pos)
     SET npos = findstring("'",query_text,pos)
     IF (sqpos > 0
      AND ((npos=0) OR ((npos > (sqpos+ textlen(query_name))))) )
      SET rquery = concat(rquery,substring(lqpos,(sqpos - lqpos),query_text),replace_query)
      SET lqpos = (sqpos+ textlen(query_name))
      SET pos = lqpos
     ELSEIF (npos > 0)
      SET pos = (npos - 1)
      WHILE (pos <= qlen
       AND substring((pos+ 1),1,query_text)="'")
       SET pos = findstring("'",query_text,(pos+ 2))
       IF (pos <= 0)
        SET pos = (qlen+ 1)
       ENDIF
      ENDWHILE
      SET pos = (pos+ 1)
     ELSE
      SET pos = qlen
     ENDIF
   ENDWHILE
   SET rquery = concat(rquery,substring(lqpos,((qlen - lqpos)+ 1),query_text))
   RETURN(rquery)
 END ;Subroutine
 SUBROUTINE extractopenparentheses(string)
   DECLARE parens = vc WITH protect, noconstant("")
   DECLARE len = i4 WITH protect
   DECLARE i = i4 WITH protect
   DECLARE char = c1 WITH protect
   SET len = textlen(string)
   FOR (i = 1 TO len)
    SET char = substring(i,1,string)
    IF (char IN (" ", char(9), "("))
     SET parens = notrim(concat(parens,char))
    ENDIF
   ENDFOR
   RETURN(substring(2,(textlen(parens) - 1),parens))
 END ;Subroutine
 SET errcode = error(errmsg,0)
 IF (errcode != 0)
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
