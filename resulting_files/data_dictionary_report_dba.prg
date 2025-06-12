CREATE PROGRAM data_dictionary_report:dba
 PAINT
 SET s_row = 8
 SET work_col = 3
 CALL box(3,1,22,80)
 CALL text(2,1,"Data Dictionary Report",w)
 CALL text(4,2,"Enter output device:")
 CALL text(5,2,"Table name (ret when done, * for all): ")
 CALL text(6,2,"Column level info:")
 CALL accept(4,23,"p(30);cu","FORMS")
 SET odev = curaccept
 RECORD in_rec(
   1 qual[1]
     2 table_name = c30
 )
 SET numrecs = 0
#inrec
 SET validate = 2
 SET validate =
 SELECT INTO "nl:"
  u.table_name
  FROM dm_tables_doc u
  WHERE u.table_name=patstring(curaccept)
  WITH nocounter
 ;end select
 CALL accept(5,43,"p(30);cu"," ")
 IF (curaccept > " "
  AND trim(curaccept) != char(42))
  SET numrecs = (numrecs+ 1)
  IF (numrecs <= 28)
   CALL text(s_row,work_col,cnvtstring(numrecs))
   CALL text(s_row,(work_col+ 3),curaccept)
   SET s_row = (s_row+ 1)
  ENDIF
  IF (numrecs=14)
   SET s_row = 8
   SET work_col = 40
  ENDIF
  IF (numrecs > 1)
   SET stat = alter(in_rec->qual,numrecs)
  ENDIF
  SET in_rec->qual[numrecs].table_name = curaccept
  SET to_get = "SOME"
  GO TO inrec
 ELSEIF (trim(curaccept)=char(42))
  SET to_get = "ALL "
 ENDIF
 SET help = off
 SET validate = off
 CALL accept(6,23,"p;cu","Y"
  WHERE curaccept IN ("Y", "N"))
 SET col_level = curaccept
 SET dx = size(in_rec->qual,5)
 CALL text(7,3,cnvtstring(dx))
 IF (col_level="Y")
  SELECT
   IF (to_get="SOME")
    FROM (dummyt d1  WITH seq = value(numrecs)),
     (dummyt d  WITH seq = 1),
     dm_tables_doc t,
     dm_columns_doc c,
     dm_flags f,
     all_tab_columns a
    PLAN (d1)
     JOIN (t
     WHERE (in_rec->qual[d1.seq].table_name=t.table_name))
     JOIN (c
     WHERE t.table_name=c.table_name)
     JOIN (a
     WHERE c.table_name=a.table_name
      AND c.column_name=a.column_name)
     JOIN (d
     WHERE 1=d.seq)
     JOIN (f
     WHERE c.table_name=f.table_name
      AND c.column_name=f.column_name
      AND c.column_name IN ("*FLAG", "*FLG"))
    ORDER BY t.table_name, c.column_name, f.flag_value
   ELSE
    FROM (dummyt d  WITH seq = 1),
     dm_tables_doc t,
     dm_columns_doc c,
     dm_flags f,
     all_tab_columns a
    PLAN (t)
     JOIN (c
     WHERE t.table_name=c.table_name)
     JOIN (a
     WHERE t.table_name=a.table_name
      AND c.column_name=a.column_name)
     JOIN (d
     WHERE 1=d.seq)
     JOIN (f
     WHERE t.table_name=f.table_name
      AND c.column_name=f.column_name
      AND c.column_name IN ("*FLAG", "*FLG"))
    ORDER BY t.table_name, c.column_name, f.flag_value
   ENDIF
   INTO trim(odev)
   is_flag = decode(f.seq,"Y","N"), t.table_name, c.column_name,
   t.definition, t.description, t.primary_update_script,
   t.primary_insert_script, t.primary_delete_script, t.static_size_flg,
   t.static_rows, t.growth_criteria, c.definition,
   c.description, c.sequence_name, c.code_set,
   c.flag_ind, f.flag_value, f.definition,
   f.description
   HEAD REPORT
    under = fillstring(208,"=")
   HEAD PAGE
    row 1, col 0, "{ps/792 0 translate 90 rotate/}",
    "{cpi/20}", "{lpi/8}", row + 1,
    col 0, "Date: ", curdate"dd-mmm-yyyy;;d",
    col 82, "D A T A   D I C T I O N A R Y   R E P O R T", col 195,
    "Page: ", curpage"#####;l", row + 2,
    col 0, t.table_name, col 31,
    "Primary Update Script", col 62, "Primary Insert Script",
    col 93, "Primary Delete Script", col 124,
    "Table Description", row + 1, col 0,
    "Static: ", t.static_size_flg"######;l", col + 1,
    "Rows: "
    IF (t.static_rows > 0)
     t.static_rows"######;l"
    ENDIF
    col 31,
    CALL print(trim(t.primary_update_script)), col 62,
    CALL print(trim(t.primary_insert_script)), col 93,
    CALL print(trim(t.primary_delete_script)),
    col 124, t.description
    IF (trim(t.growth_criteria) > " ")
     row + 1, col 0, "Table Growth Criteria: ",
     row + 1, col 0, t.growth_criteria
    ENDIF
    IF (trim(t.definition) > " ")
     row + 1, col 0, "Table Definition:",
     hold_one = fillstring(500," "), out_one = fillstring(205," "), hold_one = t.definition
     IF (size(trim(hold_one)) > 205)
      done1 = "F"
      WHILE (done1="F")
        done = "F", b_point = 205
        WHILE (done="F")
          IF (substring(b_point,1,hold_one) > " ")
           b_point = (b_point - 1)
          ELSE
           done = "T"
          ENDIF
        ENDWHILE
        out_one = substring(1,b_point,hold_one), px2 = (500 - b_point), row + 1,
        col 0, out_one, hold_one = fillstring(500," "),
        hold_one = substring(b_point,px2,t.definition)
        IF (size(trim(hold_one)) < 205)
         out_one = trim(hold_one), done1 = "T"
        ENDIF
      ENDWHILE
     ELSE
      out_one = trim(t.definition)
     ENDIF
     row + 1, col 0, out_one
    ENDIF
    row + 1, col 0, "Column Name",
    col 31, "Sequence Name", col 62,
    "Code Set", col 75, "Flag",
    col 124, "Col Description", row + 1,
    col 0, under, row + 1
   HEAD t.table_name
    row + 0
   HEAD c.column_name
    row + 1, col 5, c.column_name,
    col 36, c.sequence_name, col 67
    IF (c.code_set > 0)
     c.code_set"##########;l"
    ELSE
     "N/A"
    ENDIF
    col 80
    IF (c.flag_ind=0)
     "N"
    ELSE
     "Y"
    ENDIF
    col 124, c.description
    IF (trim(c.definition) > " ")
     row + 1, col 5, "Col Definition:",
     hold_one = fillstring(500," "), out_onee = fillstring(200," "), hold_one = c.definition
     IF (size(trim(hold_one)) > 200)
      done1 = "F"
      WHILE (done1="F")
        done = "F", b_point = 200
        WHILE (done="F")
          IF (substring(b_point,1,hold_one) > " ")
           b_point = (b_point - 1)
          ELSE
           done = "T"
          ENDIF
        ENDWHILE
        out_onee = substring(1,b_point,hold_one), px2 = (500 - b_point), row + 1,
        col 5, out_onee, hold_one = fillstring(500," "),
        hold_one = substring(b_point,px2,c.definition)
        IF (size(trim(hold_one)) < 200)
         out_onee = trim(hold_one), done1 = "T"
        ENDIF
      ENDWHILE
     ELSE
      out_onee = trim(c.definition)
     ENDIF
     row + 1, col 5, out_onee,
     row + 1
    ENDIF
   HEAD f.flag_value
    IF (is_flag="Y")
     col 5, "Flag Value: ", col 18,
     f.flag_value"#", col 20, "Flag Desc: ",
     f.description
     IF (trim(f.definition) > " ")
      col 115, "Flag Def: ", hold_one = fillstring(500," "),
      out_oned = fillstring(120," "), hold_one = c.definition
      IF (size(trim(hold_one)) > 120)
       done1 = "F"
       WHILE (done1="F")
         done = "F", b_point = 120
         WHILE (done="F")
           IF (substring(b_point,1,hold_one) > " ")
            b_point = (b_point - 1)
           ELSE
            done = "T"
           ENDIF
         ENDWHILE
         out_oned = substring(1,b_point,hold_one), px2 = (500 - b_point), row + 1,
         col 10, out_oned, hold_one = fillstring(500," "),
         hold_one = substring(b_point,px2,f.definition)
         IF (size(trim(hold_one)) < 120)
          out_oned = trim(hold_one), done1 = "T"
         ENDIF
       ENDWHILE
      ELSE
       out_oned = trim(f.definition)
      ENDIF
      row + 1, col 10, out_oned,
      row + 1
     ELSE
      row + 1
     ENDIF
    ENDIF
   DETAIL
    row + 0
   FOOT  t.table_name
    BREAK
   WITH outerjoin = d, maxcol = 300, dio = postscript
  ;end select
 ELSE
  SELECT
   IF (to_get="SOME")
    FROM (dummyt d1  WITH seq = value(numrecs)),
     dm_tables_doc t
    PLAN (d1)
     JOIN (t
     WHERE (in_rec->qual[d1.seq].table_name=t.table_name))
    ORDER BY t.table_name
   ELSE
    FROM (dummyt d  WITH seq = 1),
     dm_tables_doc t
    PLAN (t)
    ORDER BY t.table_name
   ENDIF
   DISTINCT INTO trim(odev)
   t.table_name, t.definition, t.description,
   t.primary_update_script, t.primary_insert_script, t.primary_delete_script,
   t.static_size_flg, t.static_rows, t.growth_criteria
   FROM (dummyt d1  WITH seq = value(numrecs)),
    dm_tables_doc t
   PLAN (d1)
    JOIN (t
    WHERE (in_rec->qual[d.seq].table_name=t.table_name))
   ORDER BY t.table_name
   HEAD REPORT
    under = fillstring(208,"=")
   HEAD PAGE
    row 1, col 0, "{ps/792 0 translate 90 rotate/}",
    "{cpi/20}", "{lpi/8}", row + 1,
    col 0, "Table Name", col 31,
    "Primary Update Script", col 62, "Primary Insert Script",
    col 93, "Primary Delete Script", col 124,
    "Table Description", row + 1, col 0,
    under
   HEAD t.table_name
    row + 0
   DETAIL
    row + 1, col 0, t.table_name,
    col 31,
    CALL print(trim(t.primary_update_script)), col 62,
    CALL print(trim(t.primary_insert_script)), col 93,
    CALL print(trim(t.primary_delete_script)),
    col 124, t.description, row + 1,
    col 0, "Static: ", t.static_size_flg,
    col + 1, "Rows:"
    IF (t.static_rows > 0)
     t.static_rows"#######"
    ENDIF
    IF (trim(t.growth_criteria) > " ")
     row + 1, col 0, "Table Growth Criteria: ",
     row + 1, col 0, t.growth_criteria
    ENDIF
    IF (trim(t.definition) > " ")
     row + 1, col 0, "Table Definition:",
     hold_one = fillstring(500," "), out_one = fillstring(205," "), hold_one = t.definition
     IF (size(trim(hold_one)) > 205)
      done1 = "F"
      WHILE (done1="F")
        done = "F", b_point = 205
        WHILE (done="F")
          IF (substring(b_point,1,hold_one) > " ")
           b_point = (b_point - 1)
          ELSE
           done = "T"
          ENDIF
        ENDWHILE
        out_one = substring(1,b_point,hold_one), px2 = (500 - b_point), row + 1,
        col 0, out_one, hold_one = fillstring(500," "),
        hold_one = substring(b_point,px2,t.definition)
        IF (size(trim(hold_one)) < 205)
         out_one = trim(hold_one), done1 = "T"
        ENDIF
      ENDWHILE
     ELSE
      out_one = trim(t.definition)
     ENDIF
     row + 1, col 0, out_one,
     row + 1
    ENDIF
   WITH maxcol = 300, dio = postscript
  ;end select
 ENDIF
END GO
