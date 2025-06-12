CREATE PROGRAM dpi_rdds_mc_output_page
 CALL echo("File Name: dpi_rdds_mc_output_page.prg")
 CALL echo("  Version: 2007-08-24")
 DECLARE display_type_dt_tm = i4 WITH protect, constant(1)
 DECLARE display_type_cd = i4 WITH protect, constant(2)
 DECLARE display_type_other_f8 = i4 WITH protect, constant(3)
 DECLARE filter_script_line = vc WITH protect, constant('<script src="script\filters.js"></script>')
 FREE RECORD table_data
 RECORD table_data(
   1 rows[*]
     2 columns[*]
       3 value = vc
     2 insert_ind = i2
     2 update_ind = i2
     2 delete_ind = i2
 )
 FREE RECORD parser_cmd
 RECORD parser_cmd(
   1 cnt = i4
   1 qual[*]
     2 cmd = vc
 )
 FREE RECORD col_group
 RECORD col_group(
   1 cnt = i4
   1 groups[*]
     2 parent_name = vc
     2 child_cnt = i4
     2 children[*]
       3 name = vc
       3 title = vc
 )
 DECLARE addparser(new_cmd=vc) = null
 SUBROUTINE addparser(new_cmd)
   SET parser_cmd->cnt = (parser_cmd->cnt+ 1)
   SET stat = alterlist(parser_cmd->qual,parser_cmd->cnt)
   SET parser_cmd->qual[parser_cmd->cnt].cmd = concat(" ",new_cmd," ")
 END ;Subroutine
 DECLARE idx_tbl = i4 WITH protect, noconstant(idx)
 DECLARE row_idx = i4 WITH protect, noconstant(0)
 DECLARE col_idx = i4 WITH protect, noconstant(0)
 DECLARE rdds_action = i4 WITH protect, noconstant(0)
 DECLARE where_string = vc WITH protect, noconstant("")
 IF (rdds_context_filter != char(42))
  SET search_filter_where = concat('x.rdds_context_name = "',rdds_context_filter,'"')
 ELSE
  SET search_filter_where = 'x.rdds_context_name = "*"'
 ENDIF
 IF (rdds_src_id_filter != char(42))
  SET search_filter_where = concat(search_filter_where," and x.rdds_source_env_id = ",
   rdds_src_id_filter)
 ENDIF
 IF (rdds_status_filter != char(42))
  SET search_filter_where = concat(search_filter_where," and x.rdds_status_flag = ",
   rdds_status_filter)
 ENDIF
 IF (rdds_cutover_filter="Y")
  SET search_filter_where = concat(search_filter_where," and x.rdds_status_flag < 9000")
 ENDIF
 CALL addparser(concat('select into "nl:" from (('))
 CALL addparser(concat("select rnum=rownum,"))
 CALL addparser(concat("x.RDDS_STATUS_FLAG, x.RDDS_SOURCE_ENV_ID, x.RDDS_DELETE_IND, x.RDDS_DT_TM,"))
 CALL addparser(concat("x.RDDS_LOG_ID, x.RDDS_CONTEXT_NAME, ",name_str))
 CALL addparser(concat("from ",tmp_table_name," x"))
 CALL addparser(concat("where ",search_filter_where))
 CALL addparser(concat("with maxqual(x, ",build(row_end),'), sqltype("F8", ',sqltype_str,")) a)"))
 IF ((table_ref->qual[idx_tbl].pk_cnt >= 1))
  CALL addparser(concat(", ",table_ref->qual[idx_tbl].name," y"))
 ENDIF
 CALL addparser(concat("where a.rnum >= ",build(row_start)))
 IF ((table_ref->qual[idx_tbl].pk_cnt >= 1))
  DECLARE pk_idx = i4 WITH protect, noconstant(0)
  FOR (pk_idx = 1 TO table_ref->qual[idx_tbl].pk_cnt)
    CALL addparser(concat(" and y.",table_ref->qual[idx_tbl].pk_hold[pk_idx].pk_name,
      " = outerjoin(a.",table_ref->qual[idx_tbl].pk_hold[pk_idx].pk_name,")"))
  ENDFOR
 ENDIF
 CALL addparser("head report")
 CALL addparser("    stat = alterlist (table_data->rows, (row_end - row_start + 1))")
 CALL addparser("   row_idx = 0")
 CALL addparser("detail")
 CALL addparser("   row_idx = row_idx + 1")
 CALL addparser("    stat = alterlist (table_data->rows[row_idx].columns, col_count)")
 FOR (col_idx = 1 TO col_count)
   CALL addparser(concat("  table_data->rows[row_idx].columns[",build(col_idx),"].value = build(a.",
     table_ref->qual[idx_tbl].columns[col_idx].name,") "))
 ENDFOR
 CALL addparser("   if (a.RDDS_DELETE_IND = 1)")
 CALL addparser("       table_data->rows[row_idx].delete_ind = 1")
 CALL addparser("       delete_cnt = delete_cnt + 1")
 CALL addparser("   else")
 CALL addparser("       table_data->rows[row_idx].delete_ind = 0")
 CALL addparser("   endif")
 IF ((table_ref->qual[idx_tbl].pk_cnt >= 1))
  IF ((table_ref->qual[idx_tbl].pk_hold[1].pk_datatype="NUMBER"))
   CALL addparser(concat("   if (y.",table_ref->qual[idx_tbl].pk_hold[1].pk_name," > 0.0 "))
  ELSE
   CALL addparser(concat("   if (textlen(trim(y.",table_ref->qual[idx_tbl].pk_hold[1].pk_name,
     ")) > 0 "))
  ENDIF
  IF ((table_ref->qual[idx_tbl].pk_cnt > 1))
   FOR (pk_idx = 2 TO table_ref->qual[idx_tbl].pk_cnt)
     IF ((table_ref->qual[idx_tbl].pk_hold[pk_idx].pk_datatype="NUMBER"))
      CALL addparser(concat(" and y.",table_ref->qual[idx_tbl].pk_hold[pk_idx].pk_name," > 0.0 "))
     ELSE
      CALL addparser(concat(" and textlen(trim(y.",table_ref->qual[idx_tbl].pk_hold[pk_idx].pk_name,
        ")) > 0 "))
     ENDIF
   ENDFOR
  ENDIF
  CALL addparser(")")
  CALL addparser("       table_data->rows[row_idx].update_ind = 1")
  CALL addparser("       update_cnt = update_cnt + 1")
  CALL addparser("   else")
  CALL addparser("       table_data->rows[row_idx].insert_ind = 1")
  CALL addparser("       insert_cnt = insert_cnt + 1")
  CALL addparser("   endif")
 ENDIF
 CALL addparser("   if (a.RDDS_STATUS_FLAG < 9000)")
 CALL addparser("       cutover_cnt = cutover_cnt + 1")
 CALL addparser("   endif")
 CALL addparser("with nocounter")
 FOR (cmd_idx = 1 TO parser_cmd->cnt)
  CALL echo(parser_cmd->qual[cmd_idx].cmd)
  CALL parser(parser_cmd->qual[cmd_idx].cmd,1)
 ENDFOR
 CALL parser("go")
 SET parser_cmd->cnt = 0
 SET stat = initrec(parser_cmd)
 IF (summary_only="Y")
  GO TO exit_script
 ENDIF
 DECLARE output_filter(table_idx=vc,col_idx=vc,row_idx=vc) = vc
 DECLARE th_extra = vc WITH protect, noconstant("")
 DECLARE td_extra = vc WITH protect, noconstant("")
 DECLARE rowspancnt = i4 WITH public, noconstant(0)
 DECLARE idx_row = i4 WITH public, noconstant(0)
 DECLARE idx_row_end = i4 WITH public, noconstant(0)
 DECLARE idx_col_group = i4 WITH public, noconstant(0)
 DECLARE idx_col_child = i4 WITH public, noconstant(0)
 DECLARE output_content = vc WITH protect, noconstant("")
 DECLARE updt_parent_exist = i2 WITH protect, noconstant(0)
 DECLARE child_count_done = i2 WITH protect, noconstant(0)
 DECLARE next_col_name = vc WITH protect, noconstant("")
 DECLARE nothing_to_group = i2 WITH protect, noconstant(0)
 SELECT INTO value(page_file_name)
  FROM dummyt
  HEAD REPORT
   col 0, "<HTML>", row + 1,
   col 0, "    <HEAD>", row + 1,
   col 0, css_line, row + 1,
   col 0, sortable_line, row + 1,
   col 0, filter_script_line, row + 1,
   col 0, "    </HEAD>", row + 1,
   col 0, "    <BODY>", row + 1,
   col 0, "<p>Filters:", row + 1,
   output_content = concat('<A HREF="javascript:show_all(',"'mytable'",')" >All</A> |'), col 0,
   output_content,
   row + 1, output_content = concat('<A HREF="javascript:filter_column(',"'Exists', 'mytable', 1",
    ')" >PK Exists?</A> |'), col 0,
   output_content, row + 1, output_content = concat('<A HREF="javascript:filter_column(',
    "'New', 'mytable', 1",')" >New PK</A> |'),
   col 0, output_content, row + 1,
   output_content = concat('<A HREF="javascript:filter_column(',"'Delete', 'mytable', 1",
    ')" >Delete</A>'), col 0, output_content,
   row + 1, col 0, "</p>",
   row + 1, col 0, '<div class="pagination">',
   row + 1
   IF (pageidx=1)
    col 0, '   <span class="disabled">&laquo; previous</span>', row + 1
   ELSE
    output_content = concat('   <a href="',htmlgen_get_page_name(table_name,(pageidx - 1)),
     '">&laquo; previous</a>'), col 0, output_content,
    row + 1
   ENDIF
   FOR (page_nav_idx = 1 TO num_of_pages)
     IF (page_nav_idx=pageidx)
      output_content = concat('<span class="current">',build(page_nav_idx),"</span>"), col 0,
      output_content,
      row + 1
     ELSE
      output_content = concat('<a href="',htmlgen_get_page_name(table_name,page_nav_idx),'">',build(
        page_nav_idx),"</a>"), col 0, output_content,
      row + 1
     ENDIF
   ENDFOR
   IF (pageidx=num_of_pages)
    col 0, '   <span class="disabled">next &raquo;</span>', row + 1
   ELSE
    output_content = concat('   <a href="',htmlgen_get_page_name(table_name,(pageidx+ 1)),
     '">next &raquo;</a>'), col 0, output_content,
    row + 1
   ENDIF
   col 0, "</div>", row + 1,
   output_content = concat("<p><b>Temp Table Name:</b> ",tmp_table_name,"<br>"), col 0,
   output_content,
   row + 1, output_content = concat("<b>Target Table:</b> ",table_name,"<br>"), col 0,
   output_content, row + 1
   IF ((table_ref->qual[idx_tbl].pk_cnt >= 1))
    output_content = concat("<b>Primary Key:</b> ",table_ref->qual[idx_tbl].pk_hold[1].pk_name)
    IF ((table_ref->qual[idx_tbl].pk_cnt >= 2))
     FOR (pk_idx = 2 TO table_ref->qual[idx_tbl].pk_cnt)
       output_content = concat(output_content,", ",table_ref->qual[idx_tbl].pk_hold[pk_idx].pk_name)
     ENDFOR
    ENDIF
   ELSE
    output_content = concat("<b>Primary Key(s):</b> N/A<br>")
   ENDIF
   output_content = concat(output_content,"</p>"), col 0, output_content,
   row + 1, col 0, '<table id="mytable" cellspacing="0" width="100%">',
   row + 1, output_content = htmlgen_row_begin(null), col 0,
   output_content, row + 1, output_content = htmlgen_get_th_nobg("Row"),
   col 0, output_content, row + 1,
   output_content = htmlgen_get_table_col_cell("RDDS",7,1,"","rdds"), col 0, output_content,
   row + 1, col_group->cnt = 1, stat = alterlist(col_group->groups,col_group->cnt),
   stat = alterlist(col_group->groups[col_group->cnt].children,7), col_group->groups[col_group->cnt].
   parent_name = "RDDS", col_group->groups[col_group->cnt].child_cnt = 7,
   col_group->groups[col_group->cnt].children[1].name = "Unique Column(s)", col_group->groups[
   col_group->cnt].children[2].name = "STATUS", col_group->groups[col_group->cnt].children[3].name =
   "SOURCE",
   col_group->groups[col_group->cnt].children[4].name = "DEL?", col_group->groups[col_group->cnt].
   children[5].name = "DT_TM", col_group->groups[col_group->cnt].children[6].name = "LOG_ID",
   col_group->groups[col_group->cnt].children[7].name = "CONTEXT", col_group->groups[col_group->cnt].
   children[1].title = "Unique Column(s) exists?", col_group->groups[col_group->cnt].children[2].
   title = "RDDS_STATUS_FLAG",
   col_group->groups[col_group->cnt].children[3].title = "RDDS_SOURCE_ENV_ID", col_group->groups[
   col_group->cnt].children[4].title = "RDDS_DELETE_IND", col_group->groups[col_group->cnt].children[
   5].title = "RDDS_DT_TM",
   col_group->groups[col_group->cnt].children[6].title = "RDDS_LOG_ID", col_group->groups[col_group->
   cnt].children[7].title = "RDDS_CONTEXT_NAME"
   FOR (idx_col = 7 TO col_count)
     IF ((table_ref->qual[idx_tbl].columns[idx_col].type="CD"))
      col_group->cnt = (col_group->cnt+ 1), stat = alterlist(col_group->groups,col_group->cnt),
      col_group->groups[col_group->cnt].parent_name = substring(1,(textlen(table_ref->qual[idx_tbl].
        columns[idx_col].name) - 3),table_ref->qual[idx_tbl].columns[idx_col].name),
      col_group->groups[col_group->cnt].child_cnt = 2, stat = alterlist(col_group->groups[col_group->
       cnt].children,col_group->groups[col_group->cnt].child_cnt), col_group->groups[col_group->cnt].
      children[1].name = "CD",
      col_group->groups[col_group->cnt].children[1].title = table_ref->qual[idx_tbl].columns[idx_col]
      .name, col_group->groups[col_group->cnt].children[2].name = "DISPLAY", col_group->groups[
      col_group->cnt].children[2].title = concat(table_ref->qual[idx_tbl].columns[idx_col].name,
       "_DISPLAY"),
      child_count_done = 1
     ELSEIF (substring(1,5,table_ref->qual[idx_tbl].columns[idx_col].name)="UPDT_")
      IF (((idx_col+ 1) <= col_count))
       next_col_name = table_ref->qual[idx_tbl].columns[(idx_col+ 1)].name
      ELSE
       next_col_name = ""
      ENDIF
      IF (substring(1,5,next_col_name)="UPDT_")
       IF (updt_parent_exist=0)
        col_group->cnt = (col_group->cnt+ 1), stat = alterlist(col_group->groups,col_group->cnt),
        col_group->groups[col_group->cnt].parent_name = "UPDT",
        updt_parent_exist = 1
       ENDIF
       col_group->groups[col_group->cnt].child_cnt = (col_group->groups[col_group->cnt].child_cnt+ 1),
       stat = alterlist(col_group->groups[col_group->cnt].children,col_group->groups[col_group->cnt].
        child_cnt), col_group->groups[col_group->cnt].children[col_group->groups[col_group->cnt].
       child_cnt].name = substring(6,textlen(table_ref->qual[idx_tbl].columns[idx_col].name),
        table_ref->qual[idx_tbl].columns[idx_col].name),
       col_group->groups[col_group->cnt].children[col_group->groups[col_group->cnt].child_cnt].title
        = table_ref->qual[idx_tbl].columns[idx_col].name
      ELSEIF (updt_parent_exist=1)
       child_count_done = 1, col_group->groups[col_group->cnt].child_cnt = (col_group->groups[
       col_group->cnt].child_cnt+ 1), stat = alterlist(col_group->groups[col_group->cnt].children,
        col_group->groups[col_group->cnt].child_cnt),
       col_group->groups[col_group->cnt].children[col_group->groups[col_group->cnt].child_cnt].name
        = substring(6,textlen(table_ref->qual[idx_tbl].columns[idx_col].name),table_ref->qual[idx_tbl
        ].columns[idx_col].name), col_group->groups[col_group->cnt].children[col_group->groups[
       col_group->cnt].child_cnt].title = table_ref->qual[idx_tbl].columns[idx_col].name
      ELSE
       nothing_to_group = 1
      ENDIF
     ELSE
      nothing_to_group = 1
     ENDIF
     IF (nothing_to_group=1)
      col_group->cnt = (col_group->cnt+ 1), stat = alterlist(col_group->groups,col_group->cnt),
      col_group->groups[col_group->cnt].parent_name = table_ref->qual[idx_tbl].columns[idx_col].name,
      col_group->groups[col_group->cnt].child_cnt = 0, child_count_done = 1, nothing_to_group = 0
     ENDIF
     IF (child_count_done=1)
      IF ((col_group->groups[col_group->cnt].child_cnt=0))
       output_content = htmlgen_get_table_col_cell(col_group->groups[col_group->cnt].parent_name,
        col_group->groups[col_group->cnt].child_cnt,2,"","")
      ELSE
       output_content = htmlgen_get_table_col_cell(col_group->groups[col_group->cnt].parent_name,
        col_group->groups[col_group->cnt].child_cnt,1," ","top")
      ENDIF
      col 0, output_content, row + 1,
      child_count_done = 0
     ENDIF
   ENDFOR
   col 0, "</tr><tr>", row + 1
   FOR (idx_col_group = 1 TO col_group->cnt)
     IF ((col_group->groups[idx_col_group].child_cnt > 0))
      FOR (idx_col_child = 1 TO col_group->groups[idx_col_group].child_cnt)
        output_content = htmlgen_get_table_col_cell(col_group->groups[idx_col_group].children[
         idx_col_child].name,1,1,col_group->groups[idx_col_group].children[idx_col_child].title,""),
        col 0, output_content,
        row + 1
      ENDFOR
     ENDIF
   ENDFOR
   output_content = htmlgen_row_end(null), col 0, output_content,
   row + 1
  DETAIL
   idx_row_end = ((row_end - row_start)+ 1)
   FOR (idx_row = 1 TO idx_row_end)
     th_extra = evaluate(mod(idx_row,2),0,htmlgen_get_th_extra_even(null),htmlgen_get_th_extra_odd(
       null)), td_extra = evaluate(mod(idx_row,2),0,htmlgen_get_td_extra_even(null),
      htmlgen_get_td_extra_odd(null)), output_content = htmlgen_row_begin(null),
     col 0, output_content, row + 1,
     output_content = htmlgen_get_th_number(build(((idx_row+ row_start) - 1)),th_extra), col 0,
     output_content,
     row + 1
     IF ((table_data->rows[idx_row].delete_ind=1))
      output_content = htmlgen_get_table_cell("Delete",td_extra)
     ELSEIF ((table_data->rows[idx_row].update_ind=1))
      output_content = htmlgen_get_table_cell("Exists",td_extra)
     ELSEIF ((table_data->rows[idx_row].insert_ind=1))
      output_content = htmlgen_get_table_cell("New",td_extra)
     ELSE
      output_content = htmlgen_get_table_cell("&nbsp;",td_extra)
     ENDIF
     col 0, output_content, row + 1
     FOR (idx_col = 1 TO col_count)
       output_content = htmlgen_get_table_cell(output_filter(idx_tbl,idx_col,idx_row),td_extra), col
       0, output_content,
       row + 1
       IF ((table_ref->qual[idx_tbl].columns[idx_col].type="CD"))
        output_content = htmlgen_get_table_cell(uar_get_code_display(cnvtreal(table_data->rows[
           idx_row].columns[idx_col].value)),td_extra), col 0, output_content,
        row + 1
       ENDIF
     ENDFOR
     output_content = htmlgen_row_end(null), col 0, output_content,
     row + 1
   ENDFOR
  FOOT REPORT
   col 0, '<tr style="display: none">', row + 1,
   col 0,
   '<th class="spec" colspan="200"><i>Zero row returned. Please try another filter.</i></th></tr>',
   row + 1,
   output_content = htmlgen_get_table_page_footer(table_name,pageidx), col 0, output_content,
   row + 1
  WITH nocounter, format = variable, noformfeed,
   maxcol = 500, maxrow = 1, noheading
 ;end select
 SUBROUTINE output_filter(table_idx,col_idx,row_idx)
   DECLARE display_type = i4 WITH protect, noconstant(table_ref->qual[table_idx].columns[col_idx].
    display_type)
   DECLARE value = vc WITH protect, noconstant(table_data->rows[idx_row].columns[idx_col].value)
   IF (display_type=display_type_dt_tm)
    RETURN(format(cnvtreal(value),"DD-MMM-YYYY HH:MM;;D"))
   ELSEIF (((display_type=display_type_cd) OR (display_type=display_type_other_f8)) )
    RETURN(substring(1,(findstring(".",value,1) - 1),value))
   ELSE
    RETURN(value)
   ENDIF
 END ;Subroutine
#exit_script
END GO
