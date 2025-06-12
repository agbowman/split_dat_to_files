CREATE PROGRAM dm_create_ship_csv:dba
 PAINT
 SET message = nowindow
 SET dcc_tbl_name = cnvtupper( $1)
 SET dcc_link_pos = findstring("@",dcc_tbl_name)
 IF (dcc_link_pos > 0)
  SET dcc_file_name = concat("cer_install:",substring(1,(dcc_link_pos - 1),dcc_tbl_name),".csv")
  SET dcc_tbl_str = concat("'",substring(1,(dcc_link_pos - 1),dcc_tbl_name),"'")
  SET dcc_link = substring(dcc_link_pos,100,dcc_tbl_name)
  SET dcc_table = concat("USER_TAB_COLUMNS",dcc_link)
 ELSE
  SET dcc_file_name = concat("cer_install:",trim(dcc_tbl_name),".csv")
  SET dcc_tbl_str = concat("'",trim(dcc_tbl_name),"'")
  SET dcc_table = " "
 ENDIF
 SET logical csv_file_name dcc_file_name
 FREE RECORD dcc_column
 RECORD dcc_column(
   1 qual[*]
     2 col_name = c30
     2 data_type = c9
     2 data_length = f8
 )
 SET tot_data_length = 0
 SET long_flag = 0
 SET dcc_col_cnt = 0
 SELECT
  IF (dcc_link_pos > 0)
   FROM (value(dcc_table) u)
   WHERE u.table_name=parser(dcc_tbl_str)
  ELSE
   FROM user_tab_columns u
   WHERE u.table_name=parser(dcc_tbl_str)
  ENDIF
  INTO "nl:"
  u.column_name, u.data_type
  HEAD REPORT
   dcc_col_cnt = 0, stat = alterlist(dcc_column->qual,10)
  DETAIL
   dcc_col_cnt = (dcc_col_cnt+ 1)
   IF (mod(dcc_col_cnt,10)=1
    AND dcc_col_cnt != 1)
    stat = alterlist(dcc_column->qual,(dcc_col_cnt+ 9))
   ENDIF
   dcc_column->qual[dcc_col_cnt].col_name = u.column_name, dcc_column->qual[dcc_col_cnt].data_type =
   u.data_type, dcc_column->qual[dcc_col_cnt].data_length = u.data_length
   IF ((dcc_column->qual[dcc_col_cnt].data_type="LONG"))
    long_flag = 1
   ELSEIF ((dcc_column->qual[dcc_col_cnt].data_type != "DATE"))
    tot_data_length = (tot_data_length+ dcc_column->qual[dcc_col_cnt].data_length)
   ELSE
    tot_data_length = (tot_data_length+ 23)
   ENDIF
  FOOT REPORT
   stat = alterlist(dcc_column->qual,dcc_col_cnt)
  WITH nocounter
 ;end select
 SET message = window
 IF (long_flag=1)
  CALL clear(1,1)
  CALL text(3,5,"*******************************************************************")
  CALL text(4,5,"*This table has a long data type column.  CAN NOT create csv file.*")
  CALL text(5,5,"*******************************************************************")
  GO TO end_of_program
 ENDIF
 SET message = nowindow
 FREE RECORD buff
 RECORD buff(
   1 list[*]
     2 str = vc
   1 cnt = i4
 )
 SET buff_cnt = 0
 FREE RECORD str
 RECORD str(
   1 str = vc
 )
 SET buff_cnt = (buff_cnt+ 1)
 SET stat = alterlist(buff->list,buff_cnt)
 SET buff->list[buff_cnt].str = concat("select into csv_file_name d.* from ",dcc_tbl_name,
  " d, dm_info dm")
 SET buff_cnt = (buff_cnt+ 1)
 SET stat = alterlist(buff->list,buff_cnt)
 SET buff->list[buff_cnt].str = concat(
  "plan dm where dm.info_domain = 'DATA MANAGEMENT' and dm.info_char = 'SHIP ENVIRONMENT'")
 SET buff_cnt = (buff_cnt+ 1)
 SET stat = alterlist(buff->list,buff_cnt)
 SET buff->list[buff_cnt].str = concat("join d where dm.info_name = d.environment_name")
 SET buff_cnt = (buff_cnt+ 1)
 SET stat = alterlist(buff->list,buff_cnt)
 SET buff->list[buff_cnt].str = "head report"
 SET buff_cnt = (buff_cnt+ 1)
 SET stat = alterlist(buff->list,buff_cnt)
 SET buff->list[buff_cnt].str = build("'",'"',dcc_column->qual[1].col_name,'"',"'")
 FOR (dcc_idx = 2 TO dcc_col_cnt)
   SET buff_cnt = (buff_cnt+ 1)
   SET stat = alterlist(buff->list,buff_cnt)
   SET buff->list[buff_cnt].str = build("'",',"',dcc_column->qual[dcc_idx].col_name,'"',"'")
 ENDFOR
 SET buff_cnt = (buff_cnt+ 1)
 SET stat = alterlist(buff->list,buff_cnt)
 SET buff->list[buff_cnt].str = "detail row +1"
 IF ((dcc_column->qual[1].data_type IN ("CHAR", "VARCHAR2", "VARCHAR")))
  SET buff_cnt = (buff_cnt+ 1)
  SET stat = alterlist(buff->list,buff_cnt)
  SET buff->list[buff_cnt].str = build("str->str = d.",dcc_column->qual[1].col_name)
  SET buff_cnt = (buff_cnt+ 1)
  SET stat = alterlist(buff->list,buff_cnt)
  SET buff->list[buff_cnt].str = concat("str->str = build(","'",'"',"', str->str,","'",
   '"',"')")
  SET buff_cnt = (buff_cnt+ 1)
  SET stat = alterlist(buff->list,buff_cnt)
  SET buff->list[buff_cnt].str = "str->str"
 ELSEIF ((dcc_column->qual[1].data_type="NUMBER"))
  SET buff_cnt = (buff_cnt+ 1)
  SET stat = alterlist(buff->list,buff_cnt)
  SET buff->list[buff_cnt].str = concat("str->str = build(","trim(cnvtstring(d.",dcc_column->qual[1].
   col_name,")))")
  SET buff_cnt = (buff_cnt+ 1)
  SET stat = alterlist(buff->list,buff_cnt)
  SET buff->list[buff_cnt].str = "str->str"
 ELSEIF ((dcc_column->qual[1].data_type="FLOAT"))
  SET buff_cnt = (buff_cnt+ 1)
  SET stat = alterlist(buff->list,buff_cnt)
  SET buff->list[buff_cnt].str = build("d.",dcc_column->qual[1].col_name)
 ELSEIF ((dcc_column->qual[1].data_type="DATE"))
  SET buff_cnt = (buff_cnt+ 1)
  SET stat = alterlist(buff->list,buff_cnt)
  SET buff->list[buff_cnt].str = concat("str->str = build(","'",'"',"', format(d.",dcc_column->qual[1
   ].col_name,
   ',";;Q"),',"'",'"',"')")
  SET buff_cnt = (buff_cnt+ 1)
  SET stat = alterlist(buff->list,buff_cnt)
  SET buff->list[buff_cnt].str = "str->str"
 ENDIF
 FOR (dcc_cnt = 2 TO dcc_col_cnt)
   IF ((dcc_column->qual[dcc_cnt].data_type IN ("CHAR", "VARCHAR2", "VARCHAR")))
    SET buff_cnt = (buff_cnt+ 1)
    SET stat = alterlist(buff->list,buff_cnt)
    SET buff->list[buff_cnt].str = build("str->str = d.",dcc_column->qual[dcc_cnt].col_name)
    SET buff_cnt = (buff_cnt+ 1)
    SET stat = alterlist(buff->list,buff_cnt)
    SET buff->list[buff_cnt].str = concat("str->str = build(","',",'"',"', str->str,","'",
     '"',"')")
    SET buff_cnt = (buff_cnt+ 1)
    SET stat = alterlist(buff->list,buff_cnt)
    SET buff->list[buff_cnt].str = "str->str"
   ELSEIF ((dcc_column->qual[dcc_cnt].data_type="NUMBER"))
    SET buff_cnt = (buff_cnt+ 1)
    SET stat = alterlist(buff->list,buff_cnt)
    SET buff->list[buff_cnt].str = concat("str->str = build(",'",", trim(cnvtstring(d.',dcc_column->
     qual[dcc_cnt].col_name,")))")
    SET buff_cnt = (buff_cnt+ 1)
    SET stat = alterlist(buff->list,buff_cnt)
    SET buff->list[buff_cnt].str = "str->str"
   ELSEIF ((dcc_column->qual[dcc_cnt].data_type="FLOAT"))
    SET buff_cnt = (buff_cnt+ 1)
    SET stat = alterlist(buff->list,buff_cnt)
    SET buff->list[buff_cnt].str = concat("str->str = build(",'",", d.',dcc_column->qual[dcc_cnt].
     col_name,")")
    SET buff_cnt = (buff_cnt+ 1)
    SET stat = alterlist(buff->list,buff_cnt)
    SET buff->list[buff_cnt].str = "str->str"
   ELSE
    SET buff_cnt = (buff_cnt+ 1)
    SET stat = alterlist(buff->list,buff_cnt)
    SET buff->list[buff_cnt].str = concat("str->str = build(","',",'"',"', format(d.",dcc_column->
     qual[dcc_cnt].col_name,
     ',";;q"),',"'",'"',"')")
    SET buff_cnt = (buff_cnt+ 1)
    SET stat = alterlist(buff->list,buff_cnt)
    SET buff->list[buff_cnt].str = "str->str"
   ENDIF
 ENDFOR
 SET buff_cnt = (buff_cnt+ 1)
 SET stat = alterlist(buff->list,buff_cnt)
 SET buff->list[buff_cnt].str = build("with nocounter, maxcol =",tot_data_length,
  ",format = variable,formfeed=none,maxrow=1 go")
 FOR (dcc_i = 1 TO buff_cnt)
   CALL parser(buff->list[dcc_i].str)
 ENDFOR
#end_of_program
END GO
