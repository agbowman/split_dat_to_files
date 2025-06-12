CREATE PROGRAM catalyst_import:dba
 IF ( NOT (validate(catalyst_import_context,0)))
  RECORD catalyst_import_context(
    1 delete_ind = i2
    1 failed_ind = i2
    1 table_name = vc
    1 table_index = i2
  )
 ENDIF
 IF ( NOT (validate(catalyst_table_info,0)))
  RECORD catalyst_table_info(
    1 table_count = i2
    1 max_column_count = i2
    1 table_list[*]
      2 table_name = vc
      2 column_count = i2
      2 column_list[*]
        3 column_name = vc
        3 data_type = vc
  )
 ENDIF
 DECLARE loadtableinfo(no_param=i2(value)) = i2
 SUBROUTINE loadtableinfo(no_param)
   SET stat = addtable("CKE_ATTRIBUTES")
   SET stat = addtable("CKE_IDSEQUENCE")
   SET stat = addtable("CKE_QNAIRE_ELEMENT")
   SET stat = addtable("CKE_QNAIRE_ELEMENT_ITEM")
   SET stat = addtable("CKE_QNAIRE_ELEMENT_TAG")
   SET stat = addtable("CKE_QUESTION")
   SET stat = addtable("CKE_QUESTIONNAIRE")
   SET stat = addtable("CKE_ATTRIBUTE_PATH")
   SET stat = addtable("CKE_ATTRIBUTE_TOKEN")
   SET stat = addtable("CKE_CRITERION_TOKEN")
   SET stat = addtable("CKE_OBJECT_ATTRIBUTE")
   SET stat = addtable("CKE_EXPRESSION_TEMPLATE")
   SET stat = addtable("CKE_EXPRESSION_PARAM")
   SET stat = addtable("W_CODE")
   SET stat = addtable("W_CODE_ALIAS")
   SET stat = addtable("W_CODE_SET")
   SET stat = addtable("W_OBJECT_FACTORY")
   SET stat = alterlist(catalyst_table_info->table_list,catalyst_table_info->table_count)
   RETURN(gettableinfo(0))
 END ;Subroutine
 DECLARE addtable(table_name=vc(value)) = i2
 SUBROUTINE addtable(table_name)
   SET catalyst_table_info->table_count = (catalyst_table_info->table_count+ 1)
   SET stat = alterlist(catalyst_table_info->table_list,catalyst_table_info->table_count)
   SET catalyst_table_info->table_list[catalyst_table_info->table_count].table_name = cnvtlower(
    table_name)
   RETURN(1)
 END ;Subroutine
 DECLARE gettableinfo(no_param=i2(value)) = i2
 SUBROUTINE gettableinfo(no_param)
   DECLARE i = i2 WITH noconstant(0), protect
   FOR (i = 1 TO catalyst_table_info->table_count)
     SELECT INTO "nl:"
      iskey = btest(l.stat,3), t.file_name, table_name = t.table_name,
      t.table_level, attr_name = l.attr_name, astat1 =
      IF (btest(l.stat,15)) "L"
      ELSEIF (btest(l.stat,1)) "Z"
      ELSE " "
      ENDIF
      ,
      astat2 =
      IF (btest(l.stat,9)) "A"
      ELSEIF (btest(l.stat,10)) "B"
      ELSEIF (btest(l.stat,13)) "V"
      ELSEIF (btest(l.stat,12)
       AND btest(l.stat,6)) "S"
      ELSEIF (btest(l.stat,12)
       AND  NOT (btest(l.stat,6))) "W"
      ELSE " "
      ENDIF
      , astat3 =
      IF (btest(l.stat,14)) "G "
      ELSEIF (band(l.stat,224)=32) "T "
      ELSEIF (band(l.stat,224)=64) "D "
      ELSEIF (band(l.stat,224)=128) "R "
      ELSEIF (band(l.stat,224)=160) "RT"
      ELSEIF (band(l.stat,224)=192) "RD"
      ELSE "  "
      ENDIF
      , atype =
      IF (l.precision) concat(l.type,trim(cnvtstring(l.len)),".",cnvtstring(l.precision))
      ELSE concat(l.type,trim(cnvtstring(l.len)))
      ENDIF
      ,
      offset = l.offset"#####"
      FROM dtable t,
       dtableattr a,
       dtableattrl l
      PLAN (t
       WHERE t.table_name=cnvtupper(catalyst_table_info->table_list[i].table_name))
       JOIN (a
       WHERE t.table_name=a.table_name)
       JOIN (l
       WHERE l.structtype != "K"
        AND btest(l.stat,11)=0
        AND  NOT (l.attr_name IN ("DATAREC", "ROWID")))
      HEAD REPORT
       cl_cnt = 0, data_type_char = " "
      DETAIL
       cl_cnt = (cl_cnt+ 1)
       IF (cl_cnt > size(catalyst_table_info->table_list[i].column_list,5))
        stat = alterlist(catalyst_table_info->table_list[i].column_list,(cl_cnt+ 10))
       ENDIF
       catalyst_table_info->table_list[i].column_list[cl_cnt].column_name = trim(attr_name),
       catalyst_table_info->table_list[i].column_list[cl_cnt].data_type = trim(l.type)
      FOOT REPORT
       catalyst_table_info->table_list[i].column_count = cl_cnt, stat = alterlist(catalyst_table_info
        ->table_list[i].column_list,cl_cnt)
       IF ((cl_cnt > catalyst_table_info->max_column_count))
        catalyst_table_info->max_column_count = cl_cnt
       ENDIF
      WITH nocounter
     ;end select
   ENDFOR
   IF ((catalyst_table_info->max_column_count > 0))
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 DECLARE checktablefordata(table_name=vc(value)) = i2
 SUBROUTINE checktablefordata(table_name)
   DECLARE ccl_statement = vc WITH noconstant(" "), protect
   DECLARE row_count = i4 WITH noconstant(0), protect
   SET ccl_statement = concat(ccl_statement,'select into "nl:" total_count = count (*) from ',
    table_name," ","foot report row_count = total_count ",
    "with nocounter go")
   CALL parser(ccl_statement)
   RETURN(row_count)
 END ;Subroutine
 DECLARE createstatements(no_param=i2(value)) = i2
 DECLARE i = i2 WITH noconstant(0), private
 DECLARE list_0_sze = i4 WITH constant(value(size(requestin->list_0,5)))
 DECLARE _table_index = i2 WITH constant(catalyst_import_context->table_index), protect
 DECLARE comma_str = vc WITH noconstant(" "), protect
 DECLARE column_name = vc WITH noconstant(" "), protect
 DECLARE left_column = vc WITH noconstant(" "), protect
 DECLARE right_column = vc WITH noconstant(" "), protect
#begin_script
 IF ((catalyst_import_context->failed_ind=0))
  SET catalyst_import_context->failed_ind = 1
  IF ((catalyst_import_context->delete_ind=1))
   IF (currdb="ORACLE")
    CALL parser(concat(" rdb truncate table ",catalyst_import_context->table_name," go "))
   ELSE
    CALL parser(concat(" delete from ",catalyst_import_context->table_name,
      " where 1 = 1 with nocounter go "))
    COMMIT
   ENDIF
   SET catalyst_import_context->delete_ind = 0
  ENDIF
  CALL parser(concat(" insert into ",catalyst_import_context->table_name," t, "))
  CALL parser(concat("                (dummyt d1 with seq = value (list_0_sze)) "))
  CALL parser(concat("   set "))
  FOR (i = 1 TO size(catalyst_table_info->table_list[_table_index].column_list,5))
    SET left_column = " "
    SET right_column = " "
    SET left_column = concat(trim(left_column),"t.",catalyst_table_info->table_list[_table_index].
     column_list[i].column_name)
    SET right_column = concat(trim(right_column),"requestin->list_0[d1.seq].",catalyst_table_info->
     table_list[_table_index].column_list[i].column_name)
    CALL parser(build(comma_str,left_column," = if (size (trim (",right_column,", 1), 1) > 0) "))
    CASE (catalyst_table_info->table_list[_table_index].column_list[i].data_type)
     OF "Q":
      CALL parser(build(" cnvtdatetime (",right_column,") "))
     OF "C":
      CALL parser(build(" trim (",right_column,") "))
     ELSE
      CALL parser(build(" cnvtreal (",right_column,") "))
    ENDCASE
    IF ((catalyst_import_context->table_name IN ("cke_attribute_path", "cke_expression_template")))
     CASE (catalyst_table_info->table_list[_table_index].column_list[i].data_type)
      OF "Q":
       CALL parser(build(" else cnvtdatetime (curdate, curtime3) endif "))
      OF "C":
       CALL parser(build(' else " " endif '))
      ELSE
       CALL parser(build(' else cnvtreal ("0") endif '))
     ENDCASE
    ELSE
     CALL parser(build(" else NULL endif "))
    ENDIF
    SET comma_str = ", "
  ENDFOR
  CALL parser(build(" plan d1 "))
  CALL parser(build(" join t  "))
  CALL parser(build(" with nocounter go "))
  IF (curqual=list_0_sze)
   SET catalyst_import_context->failed_ind = 0
  ENDIF
 ENDIF
#exit_script
END GO
