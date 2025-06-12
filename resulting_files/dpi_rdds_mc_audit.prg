CREATE PROGRAM dpi_rdds_mc_audit
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Title (default=RDDS Merge & Cutover Audit Report): " = "RDDS Merge & Cutover Audit",
  "Output File Root Path (default=/tmp): " = "/tmp",
  "Temp Table Lookup Pattern (default=*$R): " = "*$R",
  "RDDS Source Environment ID filter (default=*): " = "*",
  "RDDS Context Name filter (default=*): " = "*",
  "RDDS Status Flag filter (default=*): " = "*",
  "Only retrieve rows that have not been cutover (status < 9000)? (default=N): " = "N",
  "Number of rows per page (default=3000): " = "3000",
  "Skip tables with num. of rows LESS than (default=1): " = "1",
  "Skip tables with num. of rows GREATER than (default=0 <no limit>): " = "0",
  "Only retrieve this many rows from each table (default=0 <no limit>): " = "0",
  "Skip row information, output only table summary? (default=Y): " = "Y",
  "Start Audit? (default=N): " = "N"
  WITH outdev, p_title, p_rootpath,
  p_tablenamepattern, p_rdds_src_id, p_rdds_context,
  p_rdds_status, p_cutover, p_rowsperpage,
  p_minrows, p_maxrows, p_grablimit,
  p_summary_only, p_confirm
 CALL echo("File Name: dpi_rdds_mc_audit.prg")
 CALL echo("  Version: 2007-08-24")
 FREE RECORD err_msg
 RECORD err_msg(
   1 cnt = i4
   1 qual[*]
     2 msg = vc
 ) WITH public
 SET err_msg->cnt = 0
 DECLARE add_log_msg(msg=vc) = null
 FREE RECORD audit_timer
 RECORD audit_timer(
   1 start = dq8
   1 stop = dq8
 ) WITH public
 SET audit_timer->start = cnvtdatetime(curdate,curtime3)
 FREE RECORD table_ref_tmp
 RECORD table_ref_tmp(
   1 cnt = i4
   1 qual[*]
     2 tmp_name = vc
 ) WITH public
 SET table_ref_tmp->cnt = 0
 FREE RECORD table_ref
 RECORD table_ref(
   1 cnt = i4
   1 qual[*]
     2 name = vc
     2 tmp_name = vc
     2 base_name = vc
     2 column_cnt = i4
     2 columns[*]
       3 name = vc
       3 type = vc
       3 ccltype = vc
       3 len = i4
       3 code_set = i4
       3 unique_ident_ind = i2
       3 display_type = i4
     2 row_cnt = i4
     2 insert_cnt = i4
     2 update_cnt = i4
     2 delete_cnt = i4
     2 col_name_str = vc
     2 col_sqltype_str = vc
     2 pk_cnt = i4
     2 pk_hold[*]
       3 pk_name = vc
       3 pk_datatype = vc
     2 unique_ind_str = vc
     2 mergeable_ind = i2
     2 merge_delete_ind = i2
     2 reference_ind = i2
     2 cutover_cnt = i4
   1 processed_cnt = i4
   1 mergeable_cnt = i4
   1 merge_delete_cnt = i4
   1 reference_cnt = i4
   1 row_total = i4
   1 cutover_total = i4
 ) WITH public
 SET table_ref->cnt = 0
 SET table_ref->processed_cnt = 0
 SET table_ref->mergeable_cnt = 0
 SET table_ref->merge_delete_cnt = 0
 SET table_ref->reference_cnt = 0
 SET table_ref->row_total = 0
 SET table_ref->cutover_total = 0
 DECLARE display_type_dt_tm = i4 WITH protect, constant(1)
 DECLARE display_type_cd = i4 WITH protect, constant(2)
 DECLARE display_type_other_f8 = i4 WITH protect, constant(3)
 IF (trim(cnvtupper( $P_CONFIRM),3) != "Y")
  CALL add_log_msg("[AUDIT] Abort program execution.")
  GO TO exit_script
 ENDIF
 IF (isnumeric( $P_RDDS_SRC_ID)=0
  AND trim( $P_RDDS_SRC_ID) != char(42))
  CALL add_log_msg('[ERROR] "RDDS Source Environment ID filter" contains non-numberic value.')
  GO TO exit_script
 ENDIF
 IF (isnumeric( $P_RDDS_STATUS)=0
  AND ( $P_RDDS_STATUS != char(42)))
  CALL add_log_msg('[ERROR] "RDDS Status Flag filter" contains non-numberic value.')
  GO TO exit_script
 ENDIF
 IF (isnumeric( $P_ROWSPERPAGE)=0)
  CALL add_log_msg('[ERROR] "Number of rows per page" contains non-numberic value.')
  GO TO exit_script
 ENDIF
 IF (isnumeric( $P_MINROWS)=0)
  CALL add_log_msg('[ERROR] "Minimum number of rows" contains non-numberic value.')
  GO TO exit_script
 ENDIF
 IF (isnumeric( $P_MAXROWS)=0)
  CALL add_log_msg('[ERROR] "Maximum number of rows" contains non-numberic value.')
  GO TO exit_script
 ENDIF
 IF (isnumeric( $P_GRABLIMIT)=0)
  CALL add_log_msg('[ERROR] "Retrieval limit" contains non-numberic value.')
  GO TO exit_script
 ENDIF
 CALL echo("File Name: dpi_rdds_audit_htmlgen.inc")
 CALL echo("  Version: 2007-08-24")
 FREE RECORD prop
 RECORD prop(
   1 timestamp = vc
   1 title = vc
   1 rootpath = vc
   1 wholepath = vc
   1 indexpage = vc
   1 menupage = vc
   1 summarypage = vc
   1 rowsperpage = i4
   1 minrows = i4
   1 maxrows = i4
   1 grablimit = i4
   1 tablename = vc
 ) WITH protect
 SET prop->timestamp = ""
 SET prop->title = ""
 SET prop->rootpath = ""
 SET prop->wholepath = ""
 SET prop->indexpage = ""
 SET prop->menupage = ""
 SET prop->summarypage = ""
 SET prop->rowsperpage = 2000
 SET prop->minrows = 1
 SET prop->maxrows = 1000000
 SET prop->grablimit = 3000
 DECLARE htmlgen_set(prop_name=vc,prop_value=vc) = null
 DECLARE htmlgen_get(prop_name=vc) = vc
 DECLARE htmlgen_init_index_page() = null
 DECLARE htmlgen_init_menu_page() = null
 DECLARE htmlgen_init_summary_page() = null
 DECLARE htmlgen_row_begin() = vc
 DECLARE htmlgen_row_end() = vc
 DECLARE htmlgen_get_page_name(table_name=vc,page_num=i4) = vc
 DECLARE htmlgen_get_full_file_path(table_name=vc,page_num=i4) = vc
 DECLARE htmlgen_get_table_page_header1() = vc
 DECLARE htmlgen_get_table_page_header2(table_name=vc,page_num=i4,total_page=i4) = vc
 DECLARE htmlgen_get_table_column_header(table_name=vc,table_data=vc,col_idx=i4) = vc
 DECLARE htmlgen_get_table_col_cell(value=vc,colspan=i4,rowspan=i4,title=vc,class=vc) = vc
 DECLARE htmlgen_get_table_cell(value=vc,td_extra=vc) = vc
 DECLARE htmlgen_get_table_page_footer(table_name=vc,page_num=i4) = vc
 DECLARE htmlgen_get_th_extra_odd() = vc
 DECLARE htmlgen_get_th_extra_even() = vc
 DECLARE htmlgen_get_td_extra_odd() = vc
 DECLARE htmlgen_get_td_extra_even() = vc
 DECLARE htmlgen_get_th_number(value=vc,th_extra=vc) = vc
 DECLARE htmlgen_get_th_nobg(value=vc) = vc
 DECLARE htmlgen_show_prop() = null
 DECLARE htmlgen_page_index = vc WITH protect, constant("index.html")
 DECLARE htmlgen_page_menu = vc WITH protect, constant("menu.htm")
 DECLARE htmlgen_page_summary = vc WITH protect, constant("summary.htm")
 DECLARE css_line = vc WITH protect, constant(
  '<LINK href="style/styles.css" rel="stylesheet" type="text/css">')
 DECLARE sortable_line = vc WITH protect, constant('<script src="script\sorttable.js"></script>')
 SUBROUTINE htmlgen_set(prop_name,prop_value)
   DECLARE tmp_dcl = vc
   DECLARE len = i4
   DECLARE dcl_stat = i2
   IF (prop_name="rootpath")
    SET prop->rootpath = prop_value
    SET timestamp = cnvtdatetime(curdate,curtime3)
    SET prop->timestamp = format(cnvtreal(timestamp),"YYYY-MM-DD HH:MM:SS;;D")
    IF (cursys="AIX")
     SET prop->wholepath = concat(prop->rootpath,"/dpi_rdds_mc_audit")
     SET tmp_dcl = concat("mkdir ",prop->wholepath)
     SET len = size(tmp_dcl)
     CALL dcl(tmp_dcl,len,dcl_stat)
     SET prop->indexpage = concat(prop->wholepath,"/",htmlgen_page_index)
     SET prop->menupage = concat(prop->wholepath,"/",htmlgen_page_menu)
     SET prop->summarypage = concat(prop->wholepath,"/",htmlgen_page_summary)
    ELSEIF (((cursys="AXP") OR (cursys="VMS")) )
     SET prop->wholepath = concat(substring(1,(textlen(prop->rootpath) - 1),prop->rootpath),
      ".dpi_rdds_mc_audit]")
     SET tmp_dcl = concat("create /directory ",prop->wholepath)
     SET len = size(tmp_dcl)
     CALL dcl(tmp_dcl,len,dcl_stat)
     SET tmp_dcl = concat("set file ",prop->rootpath,
      "dpi.rdds_mc_audit.dir /protection=(OWNER:RWED,GROUP:RWED)")
     SET len = size(tmp_dcl)
     CALL dcl(tmp_dcl,len,dcl_stat)
     SET prop->indexpage = concat(prop->wholepath,htmlgen_page_index)
     SET prop->menupage = concat(prop->wholepath,htmlgen_page_menu)
     SET prop->summarypage = concat(prop->wholepath,htmlgen_page_summary)
    ENDIF
   ELSEIF (prop_name="title")
    SET prop->title = prop_value
   ELSEIF (prop_name="rowsperpage")
    SET prop->rowsperpage = cnvtint(prop_value)
   ELSEIF (prop_name="minrows")
    SET prop->minrows = cnvtint(prop_value)
   ELSEIF (prop_name="maxrows")
    SET prop->maxrows = cnvtint(prop_value)
   ELSEIF (prop_name="grablimit")
    SET prop->grablimit = cnvtint(prop_value)
   ELSEIF (prop_name="tablename")
    SET prop->tablename = prop_value
   ENDIF
 END ;Subroutine
 SUBROUTINE htmlgen_get(prop_name)
   DECLARE prop_value = vc WITH protect, noconstant("")
   IF (prop_name="timestamp")
    SET prop_value = prop->timestamp
   ELSEIF (prop_name="title")
    SET prop_value = prop->title
   ELSEIF (prop_name="rootpath")
    SET prop_value = prop->rootpath
   ELSEIF (prop_name="wholepath")
    SET prop_value = prop->wholepath
   ELSEIF (prop_name="indexpage")
    SET prop_value = prop->indexpage
   ELSEIF (prop_name="menupage")
    SET prop_value = prop->menupage
   ELSEIF (prop_name="summarypage")
    SET prop_value = prop->summarypage
   ELSEIF (prop_name="rowsperpage")
    SET prop_value = build(prop->rowsperpage)
   ELSEIF (prop_name="minrows")
    SET prop_value = build(prop->minrows)
   ELSEIF (prop_name="maxrows")
    SET prop_value = build(prop->maxrows)
   ELSEIF (prop_name="grablimit")
    SET prop_value = build(prop->grablimit)
   ELSEIF (prop_name="tablename")
    SET prop_value = prop->tablename
   ENDIF
   RETURN(prop_value)
 END ;Subroutine
 SUBROUTINE htmlgen_init_index_page(null)
   DECLARE title_line = vc WITH protect, constant(concat("            <TITLE>",prop->title,"</TITLE>"
     ))
   DECLARE menu_line = vc WITH protect, constant(concat('            <FRAME src="',htmlgen_page_menu,
     '" name="left">'))
   DECLARE summary_line = vc WITH protect, constant(concat('            <FRAME src="',
     htmlgen_page_summary,'" name="right">'))
   SELECT INTO value(prop->indexpage)
    FROM dummyt
    HEAD REPORT
     col 0, "    <HTML>", row + 1,
     col 0, "        <HEAD>", row + 1,
     col 0, title_line, row + 1,
     col 0, "        </HEAD>", row + 1,
     col 0, '        <FRAMESET cols="320, *">', row + 1,
     col 0, menu_line, row + 1,
     col 0, summary_line, row + 1,
     col 0, "        </FRAMESET>", row + 1,
     col 0, "    </HTML>", row + 1
    WITH nocounter, format = variable, noformfeed,
     maxrow = 1, noheading
   ;end select
 END ;Subroutine
 SUBROUTINE htmlgen_init_menu_page(null)
   DECLARE timestamp_line = vc WITH protect, constant(concat("        <p><b>Revision Time:</b><br>",
     prop->timestamp,"</p>"))
   DECLARE title_line = vc WITH protect, constant(concat("            <TITLE>",prop->title,
     " - Menu</TITLE>"))
   DECLARE summary_link_line = vc WITH protect, constant(concat('                <a href="',
     htmlgen_page_summary,
     '" target="right" title="Back to Summary Page">Back to Summary Page</a><br><br>'))
   DECLARE table_name = vc WITH protect, noconstant("")
   DECLARE empty_target_cnt = i4 WITH protect, noconstant(0)
   DECLARE table_line = vc WITH protect, noconstant("")
   DECLARE row_line = vc WITH protect, noconstant("")
   DECLARE output_table_cnt = i4 WITH protect, noconstant(0)
   DECLARE th_extra = vc WITH protect, noconstant("")
   DECLARE td_extra = vc WITH protect, noconstant("")
   DECLARE output_line = vc WITH protect, noconstant("")
   SELECT INTO value(prop->menupage)
    FROM dummyt
    HEAD REPORT
     col 0, "    <HTML>", row + 1,
     col 0, "        <HEAD>", row + 1,
     col 0, title_line, row + 1,
     col 0, css_line, row + 1,
     col 0, sortable_line, row + 1,
     col 0, "        </HEAD>", row + 1,
     col 0, "        <BODY>", row + 1,
     col 0, timestamp_line, row + 1,
     col 0, summary_link_line, row + 1,
     col 0,
     '<table cellspacing="0" width="100%"><tr><th class="nobg">Filter</th><th>Value</th></tr>', row
      + 1,
     output_line = concat(
      '<tr class="spec"><th class="spec" align="left">Temp Table Filter:</th><td align="left">',prop
      ->tablename,"</td></tr>"), col 0, output_line,
     row + 1, output_line = concat(
      '<tr class="spec"><th class="spec" align="left">RDDS Status Flag:</th><td align="left">',
       $P_RDDS_STATUS,"</td></tr>"), col 0,
     output_line, row + 1, output_line = concat(
      '<tr class="specalt"><th class="spec" align="left">RDDS Source Env ID:</th><td align="left">',
       $P_RDDS_SRC_ID,"</td></tr>"),
     col 0, output_line, row + 1,
     output_line = concat(
      '<tr class="spec"><th class="spec" align="left">RDDS Context Name:</th><td align="left">',
       $P_RDDS_CONTEXT,"</td></tr>"), col 0, output_line,
     row + 1, output_line = concat(
      '<tr class="spec"><th class="spec" align="left">Only Rows Ready for Cutover:</th><td align="left">',
       $P_CUTOVER,"</td></tr>"), col 0,
     output_line, row + 1, output_line = concat(
      '<tr class="specalt"><th class="spec" align="left">Rows per page:</th><td align="left">',build(
       prop->rowsperpage),"</td></tr>"),
     col 0, output_line, row + 1,
     output_line = concat(
      '<tr class="spec"><th class="spec" align="left">Min Number of Rows:</th><td align="left">',
      build(prop->minrows),"</td></tr>"), col 0, output_line,
     row + 1, output_line = concat(
      '<tr class="specalt"><th class="spec" align="left">Max Number of Rows:</th><td align="left">',
      evaluate(prop->maxrows,0,"No Limit",build(prop->maxrows)),"</td></tr>"), col 0,
     output_line, row + 1, output_line = concat(
      '<tr class="spec"><th class="spec" align="left">Retrieval Limit:</th><td align="left">',
      evaluate(prop->grablimit,0,"No Limit",build(prop->grablimit)),"</td></tr>"),
     col 0, output_line, row + 1,
     output_line = concat(
      '<tr class="spec"><th class="spec" align="left">Summary Only Mode:</th><td align="left">',
      summary_only,"</td></tr>"), col 0, output_line,
     row + 1, col 0, "</table><br><br>",
     row + 1, col 0,
     '            <table id="mytable" class="sortable" cellspacing="0" width="100%">',
     row + 1, col 0, "                <tr>",
     row + 1, row_line = htmlgen_get_th_nobg("Table Name"), col 0,
     row_line, row + 1, col 0,
     "                    <th>Rows</th>", row + 1, col 0,
     "                </tr>", row + 1
     FOR (idx = 1 TO table_ref->cnt)
       output_table_cnt = (output_table_cnt+ 1), th_extra = evaluate(mod(output_table_cnt,2),0,
        htmlgen_get_th_extra_even(null),htmlgen_get_th_extra_odd(null)), td_extra = evaluate(mod(
         output_table_cnt,2),0,htmlgen_get_td_extra_even(null),htmlgen_get_td_extra_odd(null)),
       col 0, "                <tr>", row + 1,
       table_name = table_ref->qual[idx].name
       IF (textlen(trim(table_name,3))=0)
        empty_target_cnt = (empty_target_cnt+ 1), table_name = concat("EMPTY_TARGET_NAME_",build(
          empty_target_cnt))
       ENDIF
       table_line = concat("                    <th",th_extra,">"), col 0, table_line,
       row + 1, table_line = concat('<a href="',htmlgen_page_summary,"#",table_name,
        '" target="right">'), col 0,
       table_line, row + 1, table_line = concat(table_name,"</a></th>"),
       col 0, table_line, row + 1,
       row_line = concat("                    <td",td_extra,">",build(table_ref->qual[idx].row_cnt),
        "</td>"), col 0, row_line,
       row + 1, col 0, "                </tr>",
       row + 1
     ENDFOR
     IF (output_table_cnt=0)
      col 0, '        <tr><th class="spec" colspan="9"><i>Search returns zero result</i></th></tr>',
      row + 1
     ENDIF
     col 0, "            </table>", row + 1,
     col 0, "        </BODY>", row + 1,
     col 0, "<p>&copy;2007 Cerner Corp<br>UK Deployment | Process Imrovement</p>", row + 1,
     col 0, "    </HTML>", row + 1
    WITH nocounter, format = variable, noformfeed,
     maxrow = 1, noheading
   ;end select
 END ;Subroutine
 SUBROUTINE htmlgen_init_summary_page(null)
   DECLARE timestamp_line = vc WITH protect, constant(concat("        <p><b>Revision Time:</b><br>",
     prop->timestamp,"</p>"))
   DECLARE title_line = vc WITH protect, noconstant(concat("            <TITLE>",prop->title,
     " - Summary</TITLE>"))
   DECLARE entry_number_str = vc WITH protect, noconstant("")
   DECLARE table_name = vc WITH protect, noconstant("")
   DECLARE target_table_line = vc WITH protect, noconstant("")
   DECLARE temp_table_line = vc WITH protect, noconstant("")
   DECLARE row_cnt_line = vc WITH protect, noconstant("")
   DECLARE output_result = vc WITH protect, noconstant("")
   DECLARE page_line = vc WITH protect, noconstant("")
   DECLARE th_extra = vc WITH protect, noconstant("")
   DECLARE td_extra = vc WITH protect, noconstant("")
   DECLARE cnt_value = vc WITH protect, noconstant("")
   DECLARE empty_target_cnt = i4 WITH protect, noconstant(0)
   DECLARE mark_empty = i2 WITH protect, noconstant(0)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE pageidx = i4 WITH protect, noconstant(0)
   DECLARE num_of_pages = i4 WITH protect, noconstant(0)
   DECLARE row_count = i4 WITH protect, noconstant(0)
   DECLARE row_start = i4 WITH protect, noconstant(0)
   DECLARE row_end = i4 WITH protect, noconstant(0)
   DECLARE output_table_cnt = i4 WITH protect, noconstant(0)
   SELECT INTO value(prop->summarypage)
    FROM dummyt
    HEAD REPORT
     col 0, "<HTML>", row + 1,
     col 0, "    <HEAD>", row + 1,
     col 0, title_line, row + 1,
     col 0, css_line, row + 1,
     col 0, sortable_line, row + 1,
     col 0, "    </HEAD>", row + 1,
     col 0, "    <BODY>", row + 1,
     col 0, timestamp_line, row + 1,
     title_line = concat("<p><h1>",prop->title,"</h1></p>"), col 0, title_line,
     row + 1, output_result = concat("<p><b>Number of processed $R tables:</b> ",build(table_ref->
       processed_cnt),"<br>"), col 0,
     output_result, row + 1, output_result = concat("<b>Number of Mergeable tables:</b> ",build(
       table_ref->mergeable_cnt),"<br>"),
     col 0, output_result, row + 1,
     output_result = concat("<b>Number of Merge Delete tables:</b> ",build(table_ref->
       merge_delete_cnt),"<br>"), col 0, output_result,
     row + 1, output_result = concat("<b>Number of Reference tables:</b> ",build(table_ref->
       reference_cnt),"<br>"), col 0,
     output_result, row + 1, output_result = concat("<b>Total number of rows:</b> ",build(table_ref->
       row_total),"<br>"),
     col 0, output_result, row + 1,
     output_result = concat("<b>Total number of rows ready for cutover (status_flag < 9000):</b> ",
      build(table_ref->cutover_total)," (",format(((cnvtreal(table_ref->cutover_total)/ cnvtreal(
        table_ref->row_total)) * 100),"###.##"),"%)<br></p>"), col 0, output_result,
     row + 1, col 0, '        <table id="mytable" class="sortable" cellspacing="0">',
     row + 1, col 0, '            <tr><th class="nobg">No.</th>',
     row + 1, col 0, "                <th>Target Table Name</th>",
     row + 1, col 0, "                <th>Temp Table Name</th>",
     row + 1, col 0, "                <th>Content</th>",
     row + 1, col 0, '                <th title="Total Number of Rows">Rows</th>',
     row + 1, col 0, '                <th title="Rows for cutover (status < 9000)">Cutover</th>',
     row + 1, col 0, '                <th title="Is this table Mergeable?">Mergeable?</th>',
     row + 1, col 0, '                <th title="Merge Delete Table">Merge Delete</th>',
     row + 1, col 0, '                <th title="Reference Table">Reference</th>',
     row + 1, col 0, "                <th>New</th>",
     row + 1, col 0, "                <th>Exists</th>",
     row + 1, col 0, "                <th>Delete</th>",
     row + 1, col 0, "            </tr>",
     row + 1
     FOR (idx = 1 TO table_ref->cnt)
       output_table_cnt = (output_table_cnt+ 1), th_extra = evaluate(mod(output_table_cnt,2),0,
        htmlgen_get_th_extra_even(null),htmlgen_get_th_extra_odd(null)), td_extra = evaluate(mod(
         output_table_cnt,2),0,htmlgen_get_td_extra_even(null),htmlgen_get_td_extra_odd(null)),
       col 0, "            <tr>", row + 1,
       entry_number_str = concat("<th",th_extra,' valign="top">',build(output_table_cnt),"</th>"),
       col 0, entry_number_str,
       row + 1, table_name = table_ref->qual[idx].name, mark_empty = 0
       IF (textlen(trim(table_name,3))=0)
        empty_target_cnt = (empty_target_cnt+ 1), table_name = concat("EMPTY_TARGET_NAME_",build(
          empty_target_cnt)), mark_empty = 1
       ENDIF
       target_table_line = concat("                <td",td_extra,' valign="top"><a name="',table_name,
        '"></a>',
        table_name,"</td>"), col 0, target_table_line,
       row + 1, temp_table_line = concat("                <td",td_extra,' valign="top">',table_ref->
        qual[idx].tmp_name,"</td>"), col 0,
       temp_table_line, row + 1, col 0,
       "                <td", td_extra, ' valign="top">',
       row + 1
       IF (summary_only="Y")
        mark_empty = 1
       ENDIF
       IF (mark_empty=0)
        IF ((((prop->grablimit=0)) OR ((table_ref->qual[idx].row_cnt <= prop->grablimit))) )
         row_count = table_ref->qual[idx].row_cnt
        ELSE
         row_count = prop->grablimit
        ENDIF
        row_start = 1
        IF ((row_count > prop->rowsperpage))
         num_of_pages = ceil((cnvtreal(row_count)/ cnvtreal(prop->rowsperpage))), row_end = prop->
         rowsperpage
         FOR (pageidx = 1 TO num_of_pages)
           page_line = concat('                    <a href="page_',table_name,"_",build(pageidx),
            '.htm">',
            build(row_start),"-",build(row_end),"</a><br>"), col 0, page_line,
           row + 1, row_start = (row_end+ 1)
           IF ((pageidx=(num_of_pages - 1)))
            row_end = row_count
           ELSE
            row_end = ((pageidx+ 1) * prop->rowsperpage)
           ENDIF
         ENDFOR
        ELSEIF (row_count > 0)
         num_of_pages = 1, row_end = table_ref->qual[idx].row_cnt, page_line = concat(
          '                    <a href="page_',table_name,"_1",'.htm">All Rows</a><br>'),
         col 0, page_line, row + 1
        ELSEIF (row_count <= 0)
         col 0, "&nbsp;", row + 1
        ENDIF
       ELSE
        col 0, "&nbsp;", row + 1
       ENDIF
       col 0, "                </td>", row + 1,
       row_cnt_line = concat("                <td",td_extra,' align="right" valign="top">',build(
         table_ref->qual[idx].row_cnt),"</td>"), col 0, row_cnt_line,
       row + 1, row_cnt_line = concat("                <td",td_extra,' align="right" valign="top">',
        build(table_ref->qual[idx].cutover_cnt)," (",
        format(((cnvtreal(table_ref->qual[idx].cutover_cnt)/ cnvtreal(table_ref->qual[idx].row_cnt))
          * 100),"###.##"),"%)</td>"), col 0,
       row_cnt_line, row + 1
       IF ((table_ref->qual[idx].mergeable_ind > 0))
        output_result = concat("                <td",td_extra,
         ' align="center" valign="top" title="Mergeable">&#10003;</td>')
       ELSE
        output_result = concat("                <td",td_extra,
         ' align="center" valign="top" title="Mergeable">&nbsp;</td>')
       ENDIF
       col 0, output_result, row + 1
       IF ((table_ref->qual[idx].merge_delete_ind > 0))
        output_result = concat("                <td",td_extra,
         ' align="center" valign="top" title="Merge Delete Table">&#10003;</td>')
       ELSE
        output_result = concat("                <td",td_extra,
         ' align="center" valign="top" title="Merge Delete Table">&nbsp;</td>')
       ENDIF
       col 0, output_result, row + 1
       IF ((table_ref->qual[idx].reference_ind > 0))
        output_result = concat("                <td",td_extra,
         ' align="center" valign="top" title="Reference Table">&#10003;</td>')
       ELSE
        output_result = concat("                <td",td_extra,
         ' align="center" valign="top" title="Reference Table">&nbsp;</td>')
       ENDIF
       col 0, output_result, row + 1
       IF ((table_ref->qual[idx].pk_cnt >= 1))
        cnt_value = build(table_ref->qual[idx].insert_cnt)
       ELSE
        cnt_value = "n.a."
       ENDIF
       output_result = concat("                <td",td_extra,' align="right" valign="top">',cnt_value,
        "</td>"), col 0, output_result,
       row + 1
       IF ((table_ref->qual[idx].pk_cnt >= 1))
        cnt_value = build(table_ref->qual[idx].update_cnt)
       ELSE
        cnt_value = "n.a."
       ENDIF
       output_result = concat("                <td",td_extra,' align="right" valign="top">',cnt_value,
        "</td>"), col 0, output_result,
       row + 1, output_result = concat("                <td",td_extra,' align="right" valign="top">',
        build(table_ref->qual[idx].delete_cnt),"</td>"), col 0,
       output_result, row + 1, col 0,
       "            </tr>", row + 1
     ENDFOR
     IF (output_table_cnt=0)
      col 0, '        <tr><th class="spec" colspan="9"><i>Search returns zero result</i></th></tr>',
      row + 1
     ENDIF
     col 0, "        </table>", row + 1,
     audit_timer->stop = cnvtdatetime(curdate,curtime3), output_result = concat(
      "<p>This report was generated in ",format(datetimediff(audit_timer->stop,audit_timer->start),
       "HH:MM:SS;;Z")), col 0,
     output_result, row + 1, col 0,
     ' using "<a href="usage.htm" title="Click to view usage information">', row + 1, col 0,
     'DPI_RDDS_MC_AUDIT.PRG</a>".<br>&copy;2007 Cerner Corp | UK Deployment | Process Imrovement</p>',
     row + 1, col 0,
     "    </BODY>", row + 1, col 0,
     "</HTML>", row + 1
    WITH nocounter, format = variable, noformfeed,
     maxrow = 1, noheading
   ;end select
 END ;Subroutine
 SUBROUTINE htmlgen_row_begin(null)
   RETURN("<tr>")
 END ;Subroutine
 SUBROUTINE htmlgen_row_end(null)
   RETURN("</tr>")
 END ;Subroutine
 SUBROUTINE htmlgen_get_page_name(table_name,page_num)
  DECLARE filename = vc WITH protect, noconstant(concat("page_",table_name,"_",build(page_num),".htm"
    ))
  RETURN(filename)
 END ;Subroutine
 SUBROUTINE htmlgen_get_full_file_path(table_name,page_num)
   DECLARE filename = vc WITH protect, noconstant("")
   IF (cursys="AIX")
    SET filename = concat(prop->wholepath,"/page_",table_name,"_",build(page_num),
     ".htm")
   ELSEIF (((cursys="AXP") OR (cursys="VMS")) )
    SET filename = concat(prop->wholepath,"page_",table_name,"_",build(page_num),
     ".htm")
   ENDIF
   RETURN(filename)
 END ;Subroutine
 SUBROUTINE htmlgen_get_table_col_cell(value,colspan,rowspan,title,class)
   DECLARE colspan_text = vc WITH protect, noconstant("")
   DECLARE rowspan_text = vc WITH protect, noconstant("")
   DECLARE title_text = vc WITH protect, noconstant("")
   DECLARE result = vc WITH protect, noconstant("<th")
   IF (colspan > 1)
    SET result = concat(result,' colspan="',build(colspan),'"')
   ENDIF
   IF (rowspan > 1)
    SET result = concat(result,' rowspan="',build(rowspan),'"')
   ENDIF
   IF (textlen(trim(title,3)) > 0)
    SET result = concat(result,' title="',title,'"')
   ENDIF
   IF (textlen(trim(class,3)) > 0)
    SET result = concat(result,' class="',class,'"')
   ENDIF
   RETURN(concat(result,">",value,"</th>"))
 END ;Subroutine
 SUBROUTINE htmlgen_get_table_cell(value,td_extra)
  DECLARE result = vc WITH protect, noconstant("")
  IF (textlen(trim(value,3))=0)
   RETURN(concat("<td",td_extra,">&nbsp;</td>"))
  ELSE
   RETURN(concat("<td",td_extra,">",value,"</td>"))
  ENDIF
 END ;Subroutine
 SUBROUTINE htmlgen_get_table_page_footer(table_name,page_num)
   RETURN("</table></BODY></HTML>")
 END ;Subroutine
 SUBROUTINE htmlgen_get_th_extra_odd(null)
   RETURN(' class="spec" ')
 END ;Subroutine
 SUBROUTINE htmlgen_get_th_extra_even(null)
   RETURN(' class="specalt" ')
 END ;Subroutine
 SUBROUTINE htmlgen_get_td_extra_odd(null)
   RETURN(" ")
 END ;Subroutine
 SUBROUTINE htmlgen_get_td_extra_even(null)
   RETURN(' class="alt" ')
 END ;Subroutine
 SUBROUTINE htmlgen_get_th_number(value,th_extra)
  DECLARE result = vc WITH protect, noconstant("")
  RETURN(concat("<th",th_extra,">",value,"</th>"))
 END ;Subroutine
 SUBROUTINE htmlgen_get_th_nobg(value)
   RETURN(concat('<th rowspan="2" class="nobg">',value,"</th>"))
 END ;Subroutine
 SUBROUTINE htmlgen_show_prop(null)
   CALL echo("===================================================")
   CALL echo(concat("  timestamp = [",htmlgen_get("timestamp"),"]"))
   CALL echo(concat("      title = [",htmlgen_get("title"),"]"))
   CALL echo(concat("   rootpath = [",htmlgen_get("rootpath"),"]"))
   CALL echo(concat("  wholepath = [",htmlgen_get("wholepath"),"]"))
   CALL echo(concat("  indexpage = [",htmlgen_get("indexpage"),"]"))
   CALL echo(concat("summarypage = [",htmlgen_get("summarypage"),"]"))
   CALL echo(concat("    minrows = [",htmlgen_get("minrows"),"]"))
   CALL echo(concat("  tablename = [",htmlgen_get("tablename"),"]"))
   CALL echo(concat("    maxrows = [",htmlgen_get("maxrows"),"]"))
   CALL echo(concat("  grablimit = [",htmlgen_get("grablimit"),"]"))
   CALL echo("===================================================")
 END ;Subroutine
 CALL htmlgen_set("title",trim( $P_TITLE,3))
 CALL htmlgen_set("rootpath",trim( $P_ROOTPATH,3))
 CALL htmlgen_set("rowsperpage",cnvtint( $P_ROWSPERPAGE))
 CALL htmlgen_set("minrows",cnvtint( $P_MINROWS))
 CALL htmlgen_set("maxrows",cnvtint( $P_MAXROWS))
 CALL htmlgen_set("grablimit",cnvtint( $P_GRABLIMIT))
 CALL htmlgen_set("tablename", $P_TABLENAMEPATTERN)
 DECLARE table_search_where = vc WITH protect, noconstant(concat(
   'uo.object_type = "TABLE" and uo.object_name = "',prop->tablename,'"'))
 DECLARE idx = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  uo.object_name
  FROM user_objects uo
  WHERE parser(table_search_where)
  ORDER BY uo.object_name
  DETAIL
   idx = (idx+ 1)
   IF (mod(idx,100)=1)
    stat = alterlist(table_ref_tmp->qual,(idx+ 99))
   ENDIF
   table_ref_tmp->qual[idx].tmp_name = uo.object_name
  FOOT REPORT
   table_ref_tmp->cnt = idx, stat = alterlist(table_ref_tmp->qual,idx)
  WITH nocounter
 ;end select
 IF ((table_ref_tmp->cnt=0))
  CALL add_log_msg("[AUDIT] No $R table found.")
  GO TO exit_script
 ENDIF
 DECLARE rdds_src_id_filter = vc WITH protect, noconstant( $P_RDDS_SRC_ID)
 DECLARE rdds_context_filter = vc WITH protect, noconstant( $P_RDDS_CONTEXT)
 DECLARE rdds_status_filter = vc WITH protect, noconstant( $P_RDDS_STATUS)
 DECLARE rdds_cutover_filter = vc WITH protect, noconstant(cnvtupper( $P_CUTOVER))
 DECLARE search_filter_where = vc WITH protect, noconstant("")
 DECLARE tmp_table_name = vc WITH protect, noconstant("")
 DECLARE minrows = i4 WITH protect, constant(prop->minrows)
 DECLARE maxrows = i4 WITH protect, constant(prop->maxrows)
 IF (rdds_context_filter=char(42))
  SET search_filter_where = 'rdds_context_name = "*"'
 ELSE
  SET search_filter_where = concat('rdds_context_name = "', $P_RDDS_CONTEXT,'"')
 ENDIF
 IF (rdds_src_id_filter != char(42))
  SET search_filter_where = concat(search_filter_where," and rdds_source_env_id = ",
   rdds_src_id_filter)
 ENDIF
 IF (rdds_status_filter != char(42))
  SET search_filter_where = concat(search_filter_where," and rdds_status_flag = ",rdds_status_filter)
 ENDIF
 IF (rdds_cutover_filter="Y")
  SET search_filter_where = concat(search_filter_where," and rdds_status_flag < 9000")
 ENDIF
 FOR (idx = 1 TO table_ref_tmp->cnt)
  SET tmp_table_name = table_ref_tmp->qual[idx].tmp_name
  SELECT INTO "nl:"
   num_rows = count(*)
   FROM (parser(tmp_table_name))
   WHERE parser(search_filter_where)
   HEAD REPORT
    IF (num_rows >= minrows
     AND ((num_rows <= maxrows) OR (maxrows=0)) )
     table_ref->row_total = (table_ref->row_total+ num_rows), table_ref->cnt = (table_ref->cnt+ 1),
     stat = alterlist(table_ref->qual,table_ref->cnt),
     table_ref->qual[table_ref->cnt].tmp_name = tmp_table_name, table_ref->qual[table_ref->cnt].
     base_name = substring(1,(textlen(table_ref->qual[table_ref->cnt].tmp_name) - 2),table_ref->qual[
      table_ref->cnt].tmp_name), table_ref->qual[table_ref->cnt].row_cnt = num_rows,
     table_ref->qual[table_ref->cnt].column_cnt = 6, table_ref->qual[table_ref->cnt].insert_cnt = 0,
     table_ref->qual[table_ref->cnt].update_cnt = 0,
     table_ref->qual[table_ref->cnt].delete_cnt = 0, table_ref->qual[table_ref->cnt].col_name_str =
     "", table_ref->qual[table_ref->cnt].col_sqltype_str = "",
     table_ref->qual[table_ref->cnt].pk_cnt = 0, table_ref->qual[table_ref->cnt].cutover_cnt = 0,
     stat = alterlist(table_ref->qual[table_ref->cnt].columns,50),
     table_ref->qual[table_ref->cnt].columns[1].name = "RDDS_STATUS_FLAG", table_ref->qual[table_ref
     ->cnt].columns[2].name = "RDDS_SOURCE_ENV_ID", table_ref->qual[table_ref->cnt].columns[3].name
      = "RDDS_DELETE_IND",
     table_ref->qual[table_ref->cnt].columns[4].name = "RDDS_DT_TM", table_ref->qual[table_ref->cnt].
     columns[5].name = "RDDS_LOG_ID", table_ref->qual[table_ref->cnt].columns[6].name =
     "RDDS_CONTEXT_NAME",
     table_ref->qual[table_ref->cnt].columns[2].display_type = display_type_other_f8, table_ref->
     qual[table_ref->cnt].columns[4].type = "DT_TM", table_ref->qual[table_ref->cnt].columns[4].
     display_type = display_type_dt_tm,
     table_ref->qual[table_ref->cnt].columns[5].display_type = display_type_other_f8
    ENDIF
   WITH nocounter
  ;end select
 ENDFOR
 DECLARE cur_list_size = i4 WITH protect, noconstant(table_ref->cnt)
 DECLARE batch_size = i4 WITH protect, constant(50)
 DECLARE loop_cnt = i4 WITH protect, noconstant(ceil((cnvtreal(cur_list_size)/ batch_size)))
 DECLARE new_list_size = i4 WITH protect, noconstant((loop_cnt * batch_size))
 DECLARE nstart = i4 WITH protect, noconstant(1)
 DECLARE expand_idx = i4 WITH protect, noconstant(0)
 DECLARE locateval_idx = i4 WITH protect, noconstant(0)
 SET stat = alterlist(table_ref->qual,new_list_size)
 IF ( NOT (validate(dguc_request,0)))
  FREE RECORD dguc_request
  RECORD dguc_request(
    1 what_tables = vc
    1 is_ref_ind = i2
    1 is_mrg_ind = i2
    1 only_special_ind = i2
    1 current_remote_db = i2
    1 local_tables_ind = i2
    1 db_link = vc
    1 req_special[*]
      2 sp_tbl = vc
  )
 ENDIF
 IF ( NOT (validate(dguc_reply,0)))
  FREE RECORD dguc_reply
  RECORD dguc_reply(
    1 rs_tbl_cnt = i4
    1 dguc_err_ind = i2
    1 dguc_err_msg = vc
    1 dtd_hold[*]
      2 tbl_name = vc
      2 tbl_suffix = vc
      2 pk_cnt = i4
      2 pk_hold[*]
        3 pk_datatype = vc
        3 pk_name = vc
  )
 ENDIF
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE dguc_table_cnt = i4 WITH protect, noconstant(1)
 SET dguc_request->is_mrg_ind = 0
 SET dguc_request->is_ref_ind = 1
 SET dguc_request->only_special_ind = 0
 SET dguc_request->what_tables = "_INVALID_"
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(loop_cnt)),
   dm_rdds_tbl_doc d
  PLAN (d1
   WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
   JOIN (d
   WHERE expand(expand_idx,nstart,(nstart+ (batch_size - 1)),d.table_name,table_ref->qual[expand_idx]
    .base_name))
  DETAIL
   pos = locateval(idx,1,table_ref->cnt,d.table_name,table_ref->qual[idx].base_name)
   IF (pos != 0)
    table_ref->qual[pos].name = d.full_table_name, table_ref->qual[pos].mergeable_ind = d
    .mergeable_ind, table_ref->qual[pos].merge_delete_ind = d.merge_delete_ind,
    table_ref->qual[pos].reference_ind = d.reference_ind
    IF (mod(dguc_table_cnt,50)=1)
     stat = alterlist(dguc_request->req_special,(dguc_table_cnt+ 49))
    ENDIF
    dguc_request->req_special[dguc_table_cnt].sp_tbl = d.full_table_name, dguc_table_cnt = (
    dguc_table_cnt+ 1)
   ENDIF
  FOOT REPORT
   stat = alterlist(dguc_request->req_special,dguc_table_cnt)
  WITH nocounter
 ;end select
 SET cur_list_size = table_ref->cnt
 SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
 SET new_list_size = (loop_cnt * batch_size)
 SET nstart = 1
 SET expand_idx = 0
 SET locateval_idx = 0
 SET stat = alterlist(table_ref->qual,new_list_size)
 FOR (idx = (cur_list_size+ 1) TO new_list_size)
   SET table_ref->qual[idx].name = table_ref->qual[cur_list_size].name
 ENDFOR
 DECLARE name_str = vc WITH protect, noconstant("")
 DECLARE atype_tmp = vc WITH protect, noconstant("")
 DECLARE sqltype_str = vc WITH protect, noconstant("")
 DECLARE suffix_str = vc WITH protect, noconstant("")
 SELECT INTO "nl:"
  atype =
  IF (l.precision) concat(l.type,trim(cnvtstring(l.len)),".",cnvtstring(l.precision))
  ELSE concat(l.type,trim(cnvtstring(l.len)))
  ENDIF
  FROM (dummyt d1  WITH seq = value(loop_cnt)),
   user_tab_columns utc,
   dm_columns_doc dcd,
   dtableattr a,
   dtableattrl l
  PLAN (d1
   WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
   JOIN (utc
   WHERE expand(expand_idx,nstart,(nstart+ (batch_size - 1)),utc.table_name,table_ref->qual[
    expand_idx].name)
    AND  NOT (utc.data_type IN ("BLOB", "LONG RAW", "CLOB", "LONG")))
   JOIN (a
   WHERE utc.table_name=a.table_name)
   JOIN (l
   WHERE l.attr_name=utc.column_name
    AND l.structtype="F"
    AND btest(l.stat,11)=0)
   JOIN (dcd
   WHERE dcd.table_name=outerjoin(utc.table_name)
    AND dcd.column_name=outerjoin(utc.column_name))
  ORDER BY utc.column_id
  DETAIL
   pos = locateval(idx,1,table_ref->cnt,utc.table_name,table_ref->qual[idx].name)
   IF (pos > 0)
    table_ref->qual[pos].column_cnt = (table_ref->qual[pos].column_cnt+ 1)
    IF (mod(table_ref->qual[pos].column_cnt,50)=1)
     stat = alterlist(table_ref->qual[pos].columns,(table_ref->qual[pos].column_cnt+ 49))
    ENDIF
    table_ref->qual[pos].columns[table_ref->qual[pos].column_cnt].name = utc.column_name, table_ref->
    qual[pos].columns[table_ref->qual[pos].column_cnt].ccltype = trim(atype,3), name_str = table_ref
    ->qual[pos].col_name_str
    IF (textlen(trim(name_str,3))=0)
     name_str = concat("x.",utc.column_name)
    ELSE
     name_str = concat(name_str,", x.",utc.column_name)
    ENDIF
    table_ref->qual[pos].col_name_str = name_str, sqltype_str = table_ref->qual[pos].col_sqltype_str,
    atype_tmp = trim(atype,3)
    IF (atype_tmp="Q8")
     atype_tmp = "DQ8"
    ENDIF
    IF (textlen(trim(sqltype_str,3))=0)
     sqltype_str = concat('"',atype_tmp,'"')
    ELSE
     sqltype_str = concat(sqltype_str,', "',atype_tmp,'"')
    ENDIF
    table_ref->qual[pos].col_sqltype_str = sqltype_str
    IF (textlen(trim(dcd.class_name)) > 0)
     table_ref->qual[pos].columns[table_ref->qual[pos].column_cnt].type = dcd.class_name, table_ref->
     qual[pos].columns[table_ref->qual[pos].column_cnt].code_set = dcd.code_set, table_ref->qual[pos]
     .columns[table_ref->qual[pos].column_cnt].unique_ident_ind = dcd.unique_ident_ind
     IF (dcd.unique_ident_ind=1)
      IF (textlen(trim(table_ref->qual[pos].unique_ind_str,3))=0)
       table_ref->qual[pos].unique_ind_str = utc.column_name
      ELSE
       table_ref->qual[pos].unique_ind_str = concat(table_ref->qual[pos].unique_ind_str,", ",utc
        .column_name)
      ENDIF
     ENDIF
    ELSE
     table_ref->qual[pos].columns[table_ref->qual[pos].column_cnt].type = utc.data_type
    ENDIF
    IF ((table_ref->qual[pos].columns[table_ref->qual[pos].column_cnt].type="DT_TM"))
     table_ref->qual[pos].columns[table_ref->qual[pos].column_cnt].display_type = display_type_dt_tm
    ELSEIF ((table_ref->qual[pos].columns[table_ref->qual[pos].column_cnt].type="CD"))
     table_ref->qual[pos].columns[table_ref->qual[pos].column_cnt].display_type = display_type_cd
    ENDIF
    suffix_str = substring((textlen(trim(utc.column_name,3)) - 2),3,utc.column_name)
    IF (((suffix_str="_ID") OR (((suffix_str="CTX") OR (suffix_str="NBR")) )) )
     table_ref->qual[pos].columns[table_ref->qual[pos].column_cnt].display_type =
     display_type_other_f8
    ENDIF
    IF (utc.avg_col_len > 0)
     table_ref->qual[pos].columns[table_ref->qual[pos].column_cnt].len = utc.avg_col_len
    ELSE
     table_ref->qual[pos].columns[table_ref->qual[pos].column_cnt].len = 25
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(table_ref->qual,cur_list_size)
 DECLARE pk_idx = i4 WITH protect, noconstant(0)
 EXECUTE dm_get_unique_columns
 DECLARE dguc_idx = i4 WITH protect, noconstant(0)
 DECLARE idx_tbl = i4 WITH protect, noconstant(0)
 DECLARE table_name = vc WITH protect, noconstant("")
 DECLARE summary_only = vc WITH protect, noconstant(trim(cnvtupper( $P_SUMMARY_ONLY),3))
 DECLARE row_count = i4 WITH protect, noconstant(0)
 DECLARE col_count = i4 WITH protect, noconstant(0)
 DECLARE row_start = i4 WITH protect, noconstant(0)
 DECLARE row_end = i4 WITH protect, noconstant(0)
 DECLARE pageidx = i4 WITH protect, noconstant(0)
 DECLARE num_of_pages = i4 WITH protect, noconstant(0)
 DECLARE page_file_name = vc WITH protect, noconstant("")
 DECLARE output_content = vc WITH protect, noconstant("")
 DECLARE tmp_table_name = vc WITH protect, noconstant("")
 DECLARE delete_cnt = i4 WITH public, noconstant(0)
 DECLARE insert_cnt = i4 WITH public, noconstant(0)
 DECLARE update_cnt = i4 WITH public, noconstant(0)
 DECLARE cutover_cnt = i4 WITH public, noconstant(0)
 FOR (idx = 1 TO table_ref->cnt)
   SET pos = locateval(dguc_idx,1,size(dguc_reply->dtd_hold,5),table_ref->qual[idx].name,dguc_reply->
    dtd_hold[dguc_idx].tbl_name)
   SET stat = alterlist(table_ref->qual[idx].pk_hold,dguc_reply->dtd_hold[pos].pk_cnt)
   SET table_ref->qual[idx].pk_cnt = dguc_reply->dtd_hold[pos].pk_cnt
   FOR (pk_idx = 1 TO table_ref->qual[idx].pk_cnt)
    SET table_ref->qual[idx].pk_hold[pk_idx].pk_name = dguc_reply->dtd_hold[pos].pk_hold[pk_idx].
    pk_name
    SET table_ref->qual[idx].pk_hold[pk_idx].pk_datatype = dguc_reply->dtd_hold[pos].pk_hold[pk_idx].
    pk_datatype
   ENDFOR
   SET stat = alterlist(table_ref->qual[idx].columns,table_ref->qual[idx].column_cnt)
   IF (textlen(trim(table_ref->qual[idx].name,3)) != 0)
    SET table_name = table_ref->qual[idx].name
    SET tmp_table_name = table_ref->qual[idx].tmp_name
    SET name_str = table_ref->qual[idx].col_name_str
    SET sqltype_str = concat('"I2", "F8", "I2", "DQ8", "F8", "VC256", ',table_ref->qual[idx].
     col_sqltype_str)
    IF ((((prop->grablimit=0)) OR ((table_ref->qual[idx].row_cnt <= prop->grablimit))) )
     SET row_count = table_ref->qual[idx].row_cnt
    ELSE
     SET row_count = prop->grablimit
    ENDIF
    SET col_count = table_ref->qual[idx].column_cnt
    SET row_start = 1
    SET skip = 0
    SET delete_cnt = 0
    SET update_cnt = 0
    SET insert_cnt = 0
    SET cutover_cnt = 0
    IF ((row_count > prop->rowsperpage))
     SET num_of_pages = ceil((cnvtreal(row_count)/ cnvtreal(prop->rowsperpage)))
     SET row_end = prop->rowsperpage
    ELSEIF (row_count > 0)
     SET num_of_pages = 1
     SET row_end = row_count
    ELSEIF (row_count <= 0)
     SET skip = 1
    ENDIF
    IF (skip=0)
     FOR (pageidx = 1 TO num_of_pages)
       SET page_file_name = htmlgen_get_full_file_path(table_name,pageidx)
       EXECUTE dpi_rdds_mc_output_page
       SET row_start = (row_end+ 1)
       IF ((pageidx=(num_of_pages - 1)))
        SET row_end = row_count
       ELSE
        SET row_end = ((pageidx+ 1) * prop->rowsperpage)
       ENDIF
     ENDFOR
     SET table_ref->qual[idx].delete_cnt = delete_cnt
     SET table_ref->qual[idx].update_cnt = update_cnt
     SET table_ref->qual[idx].insert_cnt = insert_cnt
     SET table_ref->qual[idx].cutover_cnt = cutover_cnt
     IF ((table_ref->qual[idx].mergeable_ind > 0))
      SET table_ref->mergeable_cnt = (table_ref->mergeable_cnt+ 1)
     ENDIF
     IF ((table_ref->qual[idx].merge_delete_ind > 0))
      SET table_ref->merge_delete_cnt = (table_ref->merge_delete_cnt+ 1)
     ENDIF
     IF ((table_ref->qual[idx].reference_ind > 0))
      SET table_ref->reference_cnt = (table_ref->reference_cnt+ 1)
     ENDIF
     SET table_ref->cutover_total = (table_ref->cutover_total+ cutover_cnt)
    ENDIF
    SET table_ref->processed_cnt = (table_ref->processed_cnt+ 1)
   ELSE
    CALL add_log_msg(concat("[ERROR] Unable to find the real table name for $R table ",table_ref->
      qual[idx].tmp_name))
   ENDIF
 ENDFOR
 SUBROUTINE add_log_msg(msg)
   SET err_msg->cnt = (err_msg->cnt+ 1)
   SET stat = alterlist(err_msg->qual,err_msg->cnt)
   SET err_msg->qual[err_msg->cnt].msg = msg
 END ;Subroutine
#output_summary
 CALL htmlgen_init_index_page(null)
 CALL htmlgen_init_menu_page(null)
 CALL htmlgen_init_summary_page(null)
#exit_script
 IF ((err_msg->cnt > 0))
  DECLARE err_idx = i4 WITH protect, noconstant(0)
  FOR (err_idx = 1 TO err_msg->cnt)
    CALL echo(err_msg->qual[err_idx].msg)
  ENDFOR
 ENDIF
END GO
