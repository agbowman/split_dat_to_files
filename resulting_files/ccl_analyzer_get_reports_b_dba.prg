CREATE PROGRAM ccl_analyzer_get_reports_b:dba
 FREE SET reply
 CALL echo(concat("report_type:",request->qual[1].report_type,"."),1,10)
 IF ( NOT ((request->qual[1].report_type="T")))
  RECORD reply(
    1 qual[*]
      2 line = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ELSE
  RECORD reply(
    1 qual[*]
      2 table_name = vc
      2 fields[*]
        3 attr_name = vc
        3 data_type = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 SET errmsg = fillstring(255," ")
 SET cnt = 0
 FREE SET in_tables
 SET in_tables1 = fillstring(1000," ")
 SET in_fields1 = fillstring(1000," ")
 SET last = size(request->qual,5)
 SET line1 = fillstring(130," ")
 SET line2 = fillstring(130," ")
 SET line3 = fillstring(130," ")
 SET owner1 = fillstring(12," ")
 SET diff_owners = 0
 SET diff_reports = 0
 SET stat = alterlist(reply->qual,(cnt+ 10))
 SET uline = fillstring(130,"-")
 SET blanks = fillstring(130," ")
 SET owner1 = cnvtupper(request->qual[1].owner)
 SET report_type1 = cnvtupper(request->qual[1].report_type)
 SET fields = 0
 FOR (i = 1 TO last)
   CALL echo(build("i:",i,"=",request->qual[i].table_name,"."),1,10)
   CALL echo(build("i:",i,"=",request->qual[i].owner,"."),1,10)
   CALL echo(build("i:",i,"=",request->qual[i].report_type,"."),1,10)
   IF (fields=0)
    SET fields = size(request->qual[i].fields,5)
   ENDIF
   SET in_tables1 = concat(trim(in_tables1),char(34),trim(cnvtupper(request->qual[i].table_name)),
    char(34))
   IF ( NOT (trim(owner1)=trim(cnvtupper(request->qual[i].owner))))
    SET diff_owners = 1
   ENDIF
   IF ( NOT ((report_type1=request->qual[i].report_type)))
    SET diff_reports = 1
   ENDIF
   IF (i < last)
    SET in_tables1 = concat(trim(in_tables1),",")
   ENDIF
 ENDFOR
 CALL echo(concat("in_tables1:",in_tables1),1,10)
 CALL echo(build("diff_owners:",diff_owners),1,10)
 CALL echo(build("diff_reports:",diff_reports),1,10)
 IF (diff_owners=0
  AND diff_reports=0
  AND fields=0)
  SET header1 = 1
  IF (report_type1 IN ("I", "A"))
   CALL oraindex(in_tables1,owner1,header1)
  ENDIF
  IF (report_type1 IN ("C", "A"))
   CALL oracons(in_tables1,owner1,header1)
  ENDIF
  IF (report_type1 IN ("D", "A"))
   CALL oratable(in_tables1,header1)
  ENDIF
  SET stat = alterlist(reply->qual,cnt)
 ELSE
  SET header1 = 1
  FOR (i = 1 TO last)
    SET in_tables1 = concat(char(34),trim(cnvtupper(request->qual[i].table_name)),char(34))
    CALL echo(concat("in_tables1:",in_tables1),1,10)
    IF ((request->qual[i].report_type IN ("I", "A")))
     CALL oraindex(in_tables1,request->qual[i].owner,header1)
    ENDIF
    IF ((request->qual[i].report_type IN ("C", "A")))
     CALL oracons(in_tables1,request->qual[i].owner,header1)
    ENDIF
    IF ((request->qual[i].report_type IN ("D", "A")))
     CALL oratable(in_tables1,header1)
    ENDIF
    IF ((request->qual[i].report_type="T"))
     SET fields = size(request->qual[i].fields,5)
     SET in_fields1 = fillstring(1000," ")
     FOR (j = 1 TO fields)
      SET in_fields1 = concat(trim(in_fields1),char(34),trim(cnvtupper(request->qual[i].fields[j].
         attr_name)),char(34))
      IF (j < fields)
       SET in_fields1 = concat(trim(in_fields1),",")
      ENDIF
     ENDFOR
     CALL echo(build("i:",i,"-in_fields1:",in_fields1),1,10)
     SET in_fields = in_fields1
     CALL data_types(request->qual[i].table_name,i)
    ENDIF
    IF (diff_reports=0
     AND fields=0
     AND (request->qual[i].report_type != "A"))
     SET header1 = 0
    ENDIF
  ENDFOR
  IF ((request->qual[1].report_type != "T"))
   SET stat = alterlist(reply->qual,cnt)
  ELSE
   SET j = size(request->qual,5)
   SET stat = alterlist(reply->qual,j)
  ENDIF
 ENDIF
 CALL echo(build("cnt:",cnt),1,10)
 CALL echo(build("fields:",fields),1,10)
 SET i = size(reply->qual,5)
 CALL echo(build("i:",i),1,10)
 IF ((request->qual[1].report_type != "T"))
  FOR (i = 1 TO cnt)
    CALL echo(reply->qual[i].line,1,10)
  ENDFOR
 ELSE
  FOR (i = 1 TO size(reply->qual,5))
   CALL echo(reply->qual[i].table_name)
   FOR (j = 1 TO size(reply->qual[i].fields,5))
    CALL echo(reply->qual[i].fields[j].attr_name)
    CALL echo(reply->qual[i].fields[j].data_type)
   ENDFOR
  ENDFOR
 ENDIF
 SET failed = "F"
 GO TO exit_script
 SUBROUTINE oraindex(in_tables,p_owner,header)
   SELECT INTO "nl:"
    brk1 = concat(a.table_name,a.index_name), a.table_name, a.table_owner,
    a.tablespace_name, a.index_name, a.uniqueness,
    colname = substring(1,30,c.column_name), colpos = c.column_position, collen = c.column_length
    FROM (sys.all_indexes a),
     (sys.all_ind_columns c)
    WHERE parser(concat("a.TABLE_NAME in (",in_tables,")"))
     AND a.table_owner=patstring(cnvtupper(p_owner))
     AND a.index_name=c.index_name
     AND a.table_name=c.table_name
     AND a.table_owner=c.table_owner
    ORDER BY brk1, c.column_position
    HEAD REPORT
     desc = "Oracle Indexes"
     IF (header=1)
      line_ct = 0, cnt = (cnt+ 1)
      IF (mod(cnt,10)=1)
       stat = alterlist(reply->qual,(cnt+ 10))
      ENDIF
      reply->qual[cnt].line = concat(substring(1,(((130/ 2) - (size(desc)/ 2)) - 1),uline)," ",desc,
       " ",substring(1,(((130/ 2) - (size(desc)/ 2)) - 1),uline)), cnt = (cnt+ 1)
      IF (mod(cnt,10)=1)
       stat = alterlist(reply->qual,(cnt+ 10))
      ENDIF
      reply->qual[cnt].line = concat("Table_name/Owner/Space",substring(1,10,blanks),"Index Name",
       substring(1,22,blanks),"Unique",
       substring(1,5,blanks),"Index Col",substring(1,22,blanks),"Col Pos",substring(1,4,blanks),
       "Col len"), cnt = (cnt+ 1)
      IF (mod(cnt,10)=1)
       stat = alterlist(reply->qual,(cnt+ 10))
      ENDIF
      reply->qual[cnt].line = uline
     ENDIF
    HEAD brk1
     line1 = concat(a.table_name,"  ",a.index_name,"  ",a.uniqueness), line2 = a.table_owner, line3
      = a.tablespace_name
    DETAIL
     cnt = (cnt+ 1)
     IF (mod(cnt,10)=1)
      stat = alterlist(reply->qual,(cnt+ 10))
     ENDIF
     line_ct = (line_ct+ 1), reply->qual[cnt].line = blanks
     IF (line_ct=1)
      reply->qual[cnt].line = concat(trim(line1),"  ")
     ELSEIF (line_ct=2)
      reply->qual[cnt].line = concat(trim(line2)," ")
     ELSEIF (line_ct=3)
      reply->qual[cnt].line = concat(trim(line3)," ")
     ENDIF
     spaces = (75 - textlen(trim(reply->qual[cnt].line))), reply->qual[cnt].line = concat(trim(reply
       ->qual[cnt].line),substring(1,spaces,blanks),colname,"  ",format(colpos,"######;p "),
      "  ",format(collen,"######;p "))
    FOOT  brk1
     IF (line_ct < 3)
      IF (line_ct=1)
       cnt = (cnt+ 1)
       IF (mod(cnt,10)=1)
        stat = alterlist(reply->qual,(cnt+ 10))
       ENDIF
       reply->qual[cnt].line = line2, line_ct = (line_ct+ 1)
      ENDIF
      IF (line_ct=2)
       cnt = (cnt+ 1)
       IF (mod(cnt,10)=1)
        stat = alterlist(reply->qual,(cnt+ 10))
       ENDIF
       reply->qual[cnt].line = line3, line_ct = (line_ct+ 1)
      ENDIF
     ENDIF
     line_ct = 0, cnt = (cnt+ 1)
     IF (mod(cnt,10)=1)
      stat = alterlist(reply->qual,(cnt+ 10))
     ENDIF
     reply->qual[cnt].line = " "
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE oracons(in_tables,p_owner,header)
   SELECT INTO "nl:"
    a.table_name, b.table_name, b.column_name,
    owner = build("(",a.owner,")"), cname = substring(1,30,a.constraint_name), status =
    IF (a.status="ENABLED") "Y"
    ELSE "N"
    ENDIF
    ,
    delete_rule = a.delete_rule, type =
    IF (a.constraint_type="C") "Check      "
    ELSEIF (a.constraint_type="P") "Primary Key"
    ELSEIF (a.constraint_type="U") "Unique Key "
    ELSEIF (a.constraint_type="R") "Referential"
    ELSEIF (a.constraint_type="V") "View       "
    ENDIF
    , condition =
    IF (a.constraint_type="C") substring(1,50,a.search_condition)
    ELSEIF (a.constraint_type="P") build(b.table_name,".",b.column_name)
    ELSEIF (a.constraint_type="U") build(b.table_name,".",b.column_name)
    ELSEIF (a.constraint_type="R") build(a.r_constraint_name,"=",b.table_name,".",b.column_name)
    ELSEIF (a.constraint_type="V") build(b.table_name,".",b.column_name)
    ENDIF
    FROM user_constraints a,
     user_cons_columns b,
     (dummyt d  WITH seq = 1)
    PLAN (a
     WHERE parser(concat("a.TABLE_NAME in (",in_tables,")"))
      AND a.owner=patstring(cnvtupper(p_owner)))
     JOIN (d)
     JOIN (b
     WHERE a.owner=b.owner
      AND a.constraint_name=b.constraint_name)
    HEAD REPORT
     desc = "Oracle Constraints"
     IF (header=1)
      line_ct = 0, cnt = (cnt+ 1)
      IF (mod(cnt,10)=1)
       stat = alterlist(reply->qual,(cnt+ 10))
      ENDIF
      reply->qual[cnt].line = concat(substring(1,(((130/ 2) - (size(desc)/ 2)) - 1),uline)," ",desc,
       " ",substring(1,(((130/ 2) - (size(desc)/ 2)) - 1),uline)), cnt = (cnt+ 1)
      IF (mod(cnt,10)=1)
       stat = alterlist(reply->qual,(cnt+ 10))
      ENDIF
      reply->qual[cnt].line = concat("Table Name (Owner)",substring(1,14,blanks),"Constraint Name",
       substring(1,17,blanks),"Type",
       substring(1,9,blanks),"Active",substring(1,2,blanks),"Condition/Index Col/Referential Col"),
      cnt = (cnt+ 1)
      IF (mod(cnt,10)=1)
       stat = alterlist(reply->qual,(cnt+ 10))
      ENDIF
      reply->qual[cnt].line = uline
     ENDIF
    HEAD a.table_name
     line1 = a.table_name, line2 = owner
    DETAIL
     cnt = (cnt+ 1)
     IF (mod(cnt,10)=1)
      stat = alterlist(reply->qual,(cnt+ 10))
     ENDIF
     line_ct = (line_ct+ 1), reply->qual[cnt].line = blanks
     IF (line_ct=1)
      reply->qual[cnt].line = concat(trim(line1),"  "), spaces = ((30 - size(concat(trim(a.table_name
         )," ")))+ 3)
     ELSEIF (line_ct=2)
      reply->qual[cnt].line = concat(trim(line2)," "), spaces = ((30 - size(concat(trim(owner)," ")))
      + 3)
     ELSE
      spaces = 32
     ENDIF
     reply->qual[cnt].line = concat(trim(reply->qual[cnt].line),substring(1,spaces,blanks),cname,"  ",
      type,
      "  ",status,"  ",substring(1,4,delete_rule)," ",
      condition)
    FOOT  a.table_name
     cnt = (cnt+ 1)
     IF (mod(cnt,10)=1)
      stat = alterlist(reply->qual,(cnt+ 10))
     ENDIF
     reply->qual[cnt].line = " ", line_ct = 0
    WITH nocounter, outerjoin = d
   ;end select
 END ;Subroutine
 SUBROUTINE oratable(in_tables,header)
   SELECT INTO "nl:"
    table_name = check(t.table_name), flag = decode(i.seq,"I",a.seq,"A","Z"), brk = concat(c
     .index_owner,c.index_name),
    c.index_name, c.column_position, attr_name = l.attr_name,
    c.column_name, i.uniqueness, iskey = btest(l.stat,3),
    t.file_name, t.table_level, atype = concat(l.type,trim(cnvtstring(l.len)),".",cnvtstring(l
      .precision)),
    offset = l.offset"#####"
    FROM dtable t,
     dtableattr a,
     dtableattrl l,
     (sys.all_ind_columns c),
     (sys.all_indexes i)
    PLAN (t
     WHERE parser(concat("t.table_name in (",trim(in_tables),")")))
     JOIN (((a
     WHERE t.table_name=a.table_name)
     JOIN (l
     WHERE l.structtype != "K"
      AND btest(l.stat,11)=0)
     ) ORJOIN ((i
     WHERE t.table_name=i.table_name
      AND i.owner="V500")
     JOIN (c
     WHERE i.table_name=c.table_name
      AND i.index_name=c.index_name
      AND i.table_owner=c.table_owner)
     ))
    ORDER BY t.table_name, flag DESC, brk,
     c.index_name, c.column_position, attr_name
    HEAD REPORT
     desc = "Definitions", cntr = 0
     IF (header=1)
      line_ct = 0, cnt = (cnt+ 1)
      IF (mod(cnt,10)=1)
       stat = alterlist(reply->qual,(cnt+ 10))
      ENDIF
      reply->qual[cnt].line = concat(substring(1,(((78/ 2) - (size(desc)/ 2)) - 1),uline)," ",desc,
       " ",substring(1,(((78/ 2) - (size(desc)/ 2)) - 1),uline)), cnt = (cnt+ 1)
      IF (mod(cnt,10)=1)
       stat = alterlist(reply->qual,(cnt+ 10))
      ENDIF
      reply->qual[cnt].line =
      "Database     Table Name   Level  Attribute                      Type    Offset", cnt = (cnt+ 1
      )
      IF (mod(cnt,10)=1)
       stat = alterlist(reply->qual,(cnt+ 10))
      ENDIF
      reply->qual[cnt].line = substring(1,79,uline)
     ENDIF
    HEAD table_name
     data_begin = 0, fldnum = 1, keynum = 1,
     cntr = 0, cnt = (cnt+ 1)
     IF (mod(cnt,10)=1)
      stat = alterlist(reply->qual,(cnt+ 10))
     ENDIF
     reply->qual[cnt].line = concat(substring(1,12,t.file_name)," ",t.table_name,"      ",build(t
       .table_level))
    HEAD flag
     IF (flag="I")
      cnt = (cnt+ 1)
      IF (mod(cnt,10)=1)
       stat = alterlist(reply->qual,(cnt+ 10))
      ENDIF
      reply->qual[cnt].line = concat(substring(1,15,blanks),"Indexes:")
     ENDIF
    HEAD brk
     IF (flag="I")
      cntr = (cntr+ 1), reply->qual[cnt].line = concat(substring(1,25,reply->qual[cnt].line),format(
        cntr,"##;p "),substring(1,5,blanks),"  ",i.uniqueness)
     ELSE
      IF ((reply->qual[cnt].line != blanks))
       cnt = (cnt+ 1)
       IF (mod(cnt,10)=1)
        stat = alterlist(reply->qual,(cnt+ 10))
       ENDIF
       reply->qual[cnt].line = blanks
      ENDIF
     ENDIF
    DETAIL
     IF (flag="I")
      reply->qual[cnt].line = concat(substring(1,33,reply->qual[cnt].line),c.column_name,substring(34,
        99,reply->qual[cnt].line)), cnt = (cnt+ 1)
      IF (mod(cnt,10)=1)
       stat = alterlist(reply->qual,(cnt+ 10))
      ENDIF
     ELSE
      IF (iskey=1)
       kpos = ichar(substring(keynum,1,l.keyfld_struct))
       IF (kpos=0)
        keynum = (keynum+ 1), fldnum = 1
       ENDIF
       IF (fldnum=1)
        reply->qual[cnt].line = concat(trim(substring(1,15,reply->qual[cnt].line)),build(keynum)),
        lastkeyfld_off = 0
       ENDIF
       reply->qual[cnt].line = concat(trim(substring(1,23,reply->qual[cnt].line)),format(fldnum,
         "##;p "))
       IF (lastkeyfld_off > offset)
        reply->qual[cnt].line = concat(trim(reply->qual[cnt].line),"R")
       ENDIF
       fldnum = (fldnum+ 1), lastkeyfld_off = offset
      ELSEIF (data_begin=0)
       data_begin = 1, reply->qual[cnt].line = concat(substring(1,16,reply->qual[cnt].line),"Data:")
      ENDIF
      reply->qual[cnt].line = concat(substring(1,33,reply->qual[cnt].line),attr_name)
      IF (btest(l.stat,9))
       reply->qual[cnt].line = concat(substring(1,64,reply->qual[cnt].line),"A")
      ELSEIF (btest(l.stat,10))
       reply->qual[cnt].line = concat(substring(1,64,reply->qual[cnt].line),"B")
      ENDIF
      CASE (band(l.stat,224))
       OF 32:
        reply->qual[cnt].line = concat(substring(1,64,reply->qual[cnt].line),"T",format(atype,
          "#######;p "))
       OF 64:
        reply->qual[cnt].line = concat(substring(1,64,reply->qual[cnt].line),"D",format(atype,
          "#######;p "))
       OF 128:
        reply->qual[cnt].line = concat(substring(1,64,reply->qual[cnt].line),"R",format(atype,
          "#######;p "))
       OF 160:
        reply->qual[cnt].line = concat(substring(1,64,reply->qual[cnt].line),"RT",format(atype,
          "#######;p "))
       OF 192:
        reply->qual[cnt].line = concat(substring(1,64,reply->qual[cnt].line),"RD",format(atype,
          "#######;p "))
       ELSE
        reply->qual[cnt].line = concat(substring(1,64,reply->qual[cnt].line),format(atype,
          "#######;p "))
      ENDCASE
      reply->qual[cnt].line = concat(substring(1,73,reply->qual[cnt].line),format(offset,"####;p ")),
      cnt = (cnt+ 1)
      IF (mod(cnt,10)=1)
       stat = alterlist(reply->qual,(cnt+ 10))
      ENDIF
     ENDIF
    WITH check, nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE data_types(table1,table_num)
   FREE SET parser_line
   SET parser_line = fillstring(1000," ")
   SET parser_line = concat("L.STRUCTTYPE!= ",char(34),"K",char(34),
    " AND BTEST (L.STAT,  11 )= 0 AND l.attr_name in (",
    trim(in_fields),")")
   CALL echo(parser_line,1,10)
   CALL echo(build("table_num:",table_num),1,10)
   SET num_fields = size(request->qual[table_num].fields,5)
   CALL echo(build("num_fields:",num_fields),1,10)
   SELECT INTO "nl:"
    table_name = check(t.table_name), flag = decode(i.seq,"I",a.seq,"A","Z"), brk = concat(c
     .index_owner,c.index_name),
    c.index_name, c.column_position, attr_name = l.attr_name,
    c.column_name, i.uniqueness, iskey = btest(l.stat,3),
    t.file_name, t.table_level, atype = concat(l.type,trim(cnvtstring(l.len)),".",cnvtstring(l
      .precision)),
    offset = l.offset"#####"
    FROM dtable t,
     dtableattr a,
     dtableattrl l,
     (sys.all_ind_columns c),
     (sys.all_indexes i)
    PLAN (t
     WHERE parser(concat("t.table_name = ",char(34),table1,char(34))))
     JOIN (((a
     WHERE t.table_name=a.table_name)
     JOIN (l
     WHERE parser(parser_line))
     ) ORJOIN ((i
     WHERE t.table_name=i.table_name
      AND i.owner="V500")
     JOIN (c
     WHERE i.table_name=c.table_name
      AND i.index_name=c.index_name
      AND i.table_owner=c.table_owner)
     ))
    ORDER BY t.table_name, attr_name
    HEAD REPORT
     attr_num = 0
    HEAD attr_name
     data_type = fillstring(10," ")
     IF (btest(l.stat,9))
      data_type = "A"
     ELSEIF (btest(l.stat,10))
      data_type = "B"
     ENDIF
     CASE (band(l.stat,224))
      OF 32:
       data_type = concat("T",format(atype,"#######;p "))
      OF 64:
       data_type = concat("D",format(atype,"#######;p "))
      OF 128:
       data_type = concat("R",format(atype,"#######;p "))
      OF 160:
       data_type = concat("RT",format(atype,"#######;p "))
      OF 192:
       data_type = concat("RD",format(atype,"#######;p "))
      ELSE
       data_type = format(atype,"#######;p ")
     ENDCASE
     attr_num = (attr_num+ 1)
     IF (mod(attr_num,10)=1)
      stat = alterlist(reply->qual[table_num].fields,(attr_num+ 10))
     ENDIF
     reply->qual[table_num].fields[attr_num].attr_name = attr_name, reply->qual[table_num].fields[
     attr_num].data_type = data_type
    FOOT REPORT
     reply->qual[table_num].table_name = table1, stat = alterlist(reply->qual[table_num].fields,
      attr_num)
    WITH check, nocounter
   ;end select
 END ;Subroutine
#exit_script
 IF (failed="T")
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "get"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "ccl_analyzer_get_reports"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = errmsg
  GO TO endit
 ELSE
  SET reply->status_data.status = "S"
  GO TO endit
 ENDIF
#endit
END GO
