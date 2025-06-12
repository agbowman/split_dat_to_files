CREATE PROGRAM catalyst_export:dba
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
 RECORD export_data(
   1 max_line_length = i4
   1 data_list[*]
     2 data_line = vc
 )
 DECLARE exporttables(no_param=i2(value)) = i2
#begin_script
 IF (loadtableinfo(0)=1)
  SET stat = exporttables(0)
 ENDIF
#exit_script
 SUBROUTINE exporttables(no_param)
   DECLARE i = i2 WITH noconstant(0), protect
   DECLARE csv_file_name = vc WITH noconstant(" "), protect
   DECLARE comma_str = vc WITH noconstant(""), protect
   DECLARE _field = vc WITH noconstant("  "), protect
   DECLARE row_count = i4 WITH noconstant(0), protect
   FOR (i = 1 TO size(catalyst_table_info->table_list,5))
     SET row_count = 0
     SET row_count = checktablefordata(catalyst_table_info->table_list[i].table_name)
     IF (row_count > 0)
      CALL parser(build(' select into "nl:" t.* '))
      CALL parser(build(" from "))
      CALL parser(build("     ",catalyst_table_info->table_list[i].table_name," t "))
      CALL parser(build(" plan t where 1 = 1 "))
      CALL parser(build(" head report "))
      CALL parser(build("   dl_cnt = 1 "))
      CALL parser(build('   head_str = fillstring (10000, " ") '))
      CALL parser(build("   head_str = build (trim (head_str) "))
      SET comma_str = ",','"
      FOR (j = 1 TO size(catalyst_table_info->table_list[i].column_list,5))
       IF (j=size(catalyst_table_info->table_list[i].column_list,5))
        SET comma_str = "  "
       ENDIF
       CALL parser(build(",'",catalyst_table_info->table_list[i].column_list[j].column_name,"'",
         comma_str))
      ENDFOR
      CALL parser(build(" ) "))
      CALL parser(build("   stat = alterlist (export_data->data_list, dl_cnt) "))
      CALL parser(build("   export_data->data_list[dl_cnt].data_line = trim (head_str) "))
      CALL parser(build(
        "   export_data->max_line_length = size (export_data->data_list[dl_cnt].data_line, 1) "))
      CALL parser(build(" detail "))
      CALL parser(build('   detail_str = fillstring (10000, " ") '))
      CALL parser(build("   detail_str = build (trim (detail_str) "))
      SET comma_str = ",','"
      FOR (j = 1 TO size(catalyst_table_info->table_list[i].column_list,5))
       IF (j=size(catalyst_table_info->table_list[i].column_list,5))
        SET comma_str = "  "
       ENDIF
       CASE (catalyst_table_info->table_list[i].column_list[j].data_type)
        OF "Q":
         CALL parser(build(", format (t.",catalyst_table_info->table_list[i].column_list[j].
           column_name,', "DD-MMM-YYYY HH:MM:00;;D")',comma_str))
        OF "C":
         CALL parser(build(", trim (t.",catalyst_table_info->table_list[i].column_list[j].column_name,
           ")",comma_str))
        ELSE
         CALL parser(build(", cnvtstring (t.",catalyst_table_info->table_list[i].column_list[j].
           column_name,")",comma_str))
       ENDCASE
      ENDFOR
      CALL parser(build(" ) "))
      CALL parser(build("   dl_cnt = dl_cnt + 1 "))
      CALL parser(build("   if (dl_cnt > size (export_data->data_list, 5)) "))
      CALL parser(build("     stat = alterlist (export_data->data_list, dl_cnt + 10) "))
      CALL parser(build("   endif "))
      CALL parser(build("   stat = alterlist (export_data->data_list, dl_cnt) "))
      CALL parser(build("   export_data->data_list[dl_cnt].data_line = trim (detail_str) "))
      CALL parser(build(
        "   if (size (export_data->data_list[dl_cnt].data_line, 1) > export_data->max_line_length) ")
       )
      CALL parser(build(
        "     export_data->max_line_length = size (export_data->data_list[dl_cnt].data_line, 1) "))
      CALL parser(build("   endif  "))
      CALL parser(build(" foot report "))
      CALL parser(build("   row + 0 "))
      CALL parser(build(" with nocounter go "))
      IF (size(export_data->data_list,5) > 0)
       SET csv_file_name = build("catalyst_",catalyst_table_info->table_list[i].table_name,".csv")
       SELECT INTO value(csv_file_name)
        d1.seq
        FROM (dummyt d1  WITH seq = value(size(export_data->data_list,5)))
        PLAN (d1)
        HEAD REPORT
         row 0, col 0
        DETAIL
         CALL print(export_data->data_list[d1.seq].data_line), row + 1
        WITH nocounter, maxcol = value((export_data->max_line_length+ 1)), maxrow = value((size(
           export_data->data_list,5)+ 1))
       ;end select
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
END GO
