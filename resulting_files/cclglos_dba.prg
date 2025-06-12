CREATE PROGRAM cclglos:dba
 PAINT
  video(n), clear(1,1), box(2,2,20,78),
  line(6,2,77,xhor), text(4,30,"GLOSSARY"), text(8,5,"OUTPUT DEVICE (MINE,PRINTER,FILE): "),
  accept(8,45,"P(30);CU","MINE"), text(10,5,"DM SECTION,TABLE,COLUMN,OR CODE_SET (D,T,C,S): "),
  accept(10,52,"P;CU","T"
   WHERE curaccept IN ("T", "C", "D", "S")),
  text(12,5,"ENTER DM SECTION,TABLE,COLUMN,OR CODE_SET:"), accept(12,48,"C(30);CUP","X"), video(rb),
  clear(24,1), text(24,1,"PROCESSING ..."), video(n)
 IF (( $2="T"))
  SELECT INTO  $1
   t.table_name, t.definition, t.data_model_section,
   f.column_name, f.definition, f.code_set,
   f.sequence_name
   FROM dm_tables_doc t,
    dm_columns_doc f
   PLAN (t
    WHERE t.table_name=patstring(cnvtupper( $3)))
    JOIN (f
    WHERE t.table_name=f.table_name)
   ORDER BY t.table_name, f.column_name
   HEAD REPORT
    desc = fillstring(100," "), len = 0, beg = 1,
    cnt = 0, info = fillstring(100," ")
   HEAD PAGE
    col 0, " "
   HEAD t.table_name
    desc = fillstring(90," "), table_1 =
    IF (t.data_model_section > " ") concat(trim(t.table_name)," / ",trim(t.data_model_section),
      " Model")
    ELSE t.table_name
    ENDIF
    , len = 0,
    beg = 1, cnt = 0, col 0,
    table_1, row + 1, len = size(trim(t.definition),1)
    WHILE (beg <= len)
      desc = substring(beg,90,t.definition), flag = 0, end_sp = 91
      WHILE (flag=0)
        end_sp -= 1, subchar = substring(end_sp,1,desc)
        IF (subchar != char(13)
         AND size(trim(subchar))=0)
         flag = 1, desc = substring(1,end_sp,desc)
        ENDIF
      ENDWHILE
      beg += end_sp, col 30, desc,
      row + 1
    ENDWHILE
    row + 2
   DETAIL
    desc = fillstring(90," "), len = 0, beg = 1,
    cnt = 0, col 0, f.column_name
    IF (f.column_name="*_CD")
     info = build("CODE SET: ",f.code_set), col 30, info,
     row + 1
    ELSEIF (f.column_name="*_ID"
     AND f.sequence_name > " ")
     info = build("SEQUENCE NAME: ",f.sequence_name), col 30, info,
     row + 1
    ENDIF
    len = size(trim(f.definition),1)
    WHILE (beg <= len)
      desc = substring(beg,90,f.definition), flag = 0, end_sp = 91
      WHILE (flag=0)
        end_sp -= 1, subchar = substring(end_sp,1,desc)
        IF (subchar != char(13)
         AND size(trim(subchar))=0)
         flag = 1, desc = substring(1,end_sp,desc)
        ENDIF
      ENDWHILE
      beg += end_sp, col 30, desc,
      row + 1
    ENDWHILE
   FOOT  t.table_name
    row + 3
   WITH counter
  ;end select
 ELSEIF (( $2="D"))
  SELECT INTO  $1
   t.table_name, t.definition, t.data_model_section
   FROM dm_tables_doc t
   PLAN (t
    WHERE  NOT (t.data_model_section=null)
     AND t.data_model_section=patstring(cnvtupper( $3)))
   ORDER BY t.data_model_section, t.table_name
   HEAD REPORT
    desc = fillstring(100," "), len = 0, beg = 1,
    cnt = 0, info = fillstring(100," ")
   HEAD PAGE
    col 0, "PAGE:", col + 1,
    curpage"###", row + 2
   HEAD t.data_model_section
    sect =
    IF (t.data_model_section > " ") concat(trim(t.data_model_section)," Model")
    ELSE "NO SECTION LISTED"
    ENDIF
    , col 0, sect,
    row + 3
   HEAD t.table_name
    desc = fillstring(90," "), len = 0, beg = 1,
    cnt = 0, col 0, t.table_name,
    len = size(trim(t.definition),1)
    WHILE (beg <= len)
      desc = substring(beg,90,t.definition), flag = 0, end_sp = 91
      WHILE (flag=0)
        end_sp -= 1, subchar = substring(end_sp,1,desc)
        IF (subchar != char(13)
         AND size(trim(subchar))=0)
         flag = 1, desc = substring(1,end_sp,desc)
        ENDIF
      ENDWHILE
      beg += end_sp, col 30, desc,
      row + 1
    ENDWHILE
   FOOT  t.table_name
    row + 2
   FOOT  t.data_model_section
    col 0, "TOTAL TABLES:", col + 1,
    count(t.table_name), BREAK
   FOOT REPORT
    col 0, "TOTAL TABLES:", col + 1,
    count(t.table_name)
   WITH counter
  ;end select
 ELSEIF (( $2="C"))
  SELECT INTO  $1
   f.column_name, f.table_name, f.definition,
   f.code_set, f.sequence_name
   FROM dm_columns_doc f
   PLAN (f
    WHERE f.column_name=patstring(cnvtupper( $3)))
   ORDER BY f.column_name, f.table_name
   HEAD REPORT
    line1 = fillstring(120,"-"), desc = fillstring(60," "), len = 0,
    beg = 1, cnt = 0
   HEAD PAGE
    IF (f.column_name="*_CD")
     col 3, "CODE SET"
    ENDIF
    col 30, "TABLE NAME", col 60,
    "DESCRIPTION", row + 1, line1,
    row + 2
   HEAD f.column_name
    col 10, f.column_name, row + 2
   DETAIL
    desc = fillstring(60," "), len = 0, beg = 1,
    cnt = 0
    IF (f.column_name="*_CD")
     col 3, f.code_set";L"
    ENDIF
    col 30, f.table_name, len = size(trim(f.definition),1)
    WHILE (beg <= len)
      desc = substring(beg,60,f.definition), flag = 0, end_sp = 61
      WHILE (flag=0)
        end_sp -= 1, subchar = substring(end_sp,1,desc)
        IF (subchar != char(13)
         AND size(trim(subchar))=0)
         flag = 1, desc = substring(1,end_sp,desc)
        ENDIF
      ENDWHILE
      beg += end_sp, col 60, desc,
      row + 1
    ENDWHILE
   FOOT  f.column_name
    row + 2
   WITH nocounter
  ;end select
 ELSEIF (( $2="S"))
  SELECT INTO  $1
   f.column_name, f.table_name, f.definition,
   f.code_set, f.sequence_name
   FROM dm_columns_doc f
   PLAN (f
    WHERE f.code_set=cnvtint( $3))
   ORDER BY f.table_name
   HEAD REPORT
    line1 = fillstring(120,"-"), desc = fillstring(60," "), len = 0,
    beg = 1, cnt = 0
   HEAD PAGE
    col 3, "CODE SET:", col + 1,
    f.code_set";L", row + 2, col 0,
    "TABLE NAME", col 30, "COLUMN NAME",
    col 60, "DESCRIPTION", row + 1,
    line1, row + 2
   DETAIL
    desc = fillstring(60," "), len = 0, beg = 1,
    cnt = 0, col 0, f.table_name,
    col 30, f.column_name, len = size(trim(f.definition),1)
    WHILE (beg <= len)
      desc = substring(beg,60,f.definition), flag = 0, end_sp = 61
      WHILE (flag=0)
        end_sp -= 1, subchar = substring(end_sp,1,desc)
        IF (subchar != char(13)
         AND size(trim(subchar))=0)
         flag = 1, desc = substring(1,end_sp,desc)
        ENDIF
      ENDWHILE
      beg += end_sp, col 60, desc,
      row + 1
    ENDWHILE
   WITH nocounter
  ;end select
 ENDIF
END GO
