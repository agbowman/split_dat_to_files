CREATE PROGRAM dm2_cbo_plan_actual_report
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Search Text:" = "",
  "SearchText is a CCL Program" = 0,
  "Child Number:" = "ALL",
  "Mode:" = "TYPICAL +PEEKED_BINDS",
  "Number of Queries:" = "25",
  "Sort Criteria:" = "0"
  WITH outdev, i_searchtext, i_search,
  i_child, i_mode, i_numqueries,
  i_sortorder
 EXECUTE reportrtl
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE cclbuildhlink(vcprog=vc,vcparams=vc,nviewtype=i2,vcdescription=vc) = vc WITH protect
 DECLARE cclbuildapplink(nmode=i2,vcappname=vc,vcparams=vc,vcdescription=vc) = vc WITH protect
 DECLARE cclbuildweblink(vcaddress=vc,nmode=i2,vcdescription=vc) = vc WITH protect
 DECLARE get_datahtml(ndummy=i2) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
 DECLARE headreportrowhtml(dummy=i2) = null WITH protect
 DECLARE detailrowhtml(dummy=i2) = null WITH protect
 DECLARE footreportrowhtml(dummy=i2) = null WITH protect
 DECLARE initializereport(dummy) = null WITH protect
 DECLARE _hreport = i4 WITH noconstant(0), protect
 DECLARE _yoffset = f8 WITH noconstant(0.0), protect
 DECLARE _xoffset = f8 WITH noconstant(0.0), protect
 RECORD _htmlfileinfo(
   1 file_desc = i4
   1 file_name = vc
   1 file_buf = vc
   1 file_offset = i4
   1 file_dir = i4
 ) WITH protect
 SET _htmlfileinfo->file_desc = 0
 DECLARE _htmlfilestat = i4 WITH noconstant(0), protect
 DECLARE rpt_render = i2 WITH constant(0), protect
 DECLARE _crlf = vc WITH constant(concat(char(13),char(10))), protect
 DECLARE rpt_calcheight = i2 WITH constant(1), protect
 DECLARE _yshift = f8 WITH noconstant(0.0), protect
 DECLARE _xshift = f8 WITH noconstant(0.0), protect
 DECLARE _sendto = vc WITH noconstant( $OUTDEV), protect
 DECLARE _rpterr = i2 WITH noconstant(0), protect
 DECLARE _rptstat = i2 WITH noconstant(0), protect
 DECLARE _oldfont = i4 WITH noconstant(0), protect
 DECLARE _oldpen = i4 WITH noconstant(0), protect
 DECLARE _dummyfont = i4 WITH noconstant(0), protect
 DECLARE _dummypen = i4 WITH noconstant(0), protect
 DECLARE _fdrawheight = f8 WITH noconstant(0.0), protect
 DECLARE _rptpage = i4 WITH noconstant(0), protect
 DECLARE _diotype = i2 WITH noconstant(8), protect
 DECLARE _outputtype = i2 WITH noconstant(rpt_postscript), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
 DECLARE script_var = vc WITH public
 DECLARE dcpar_sort_order = vc WITH public
 DECLARE dcpar_child = vc WITH public
 DECLARE dcpar_sort = vc WITH noconstant("v.sql_id"), public
 SUBROUTINE cclbuildhlink(vcprogname,vcparams,nwindow,vcdescription)
   DECLARE vcreturn = vc WITH private, noconstant(vcdescription)
   IF ((_htmlfileinfo->file_desc != 0))
    SET vcreturn = build(^<a href='javascript:CCLLINK("^,vcprogname,'","',vcparams,'",',
     nwindow,")'>",vcdescription,"</a>")
   ENDIF
   RETURN(vcreturn)
 END ;Subroutine
 SUBROUTINE cclbuildapplink(nmode,vcappname,vcparams,vcdescription)
   DECLARE vcreturn = vc WITH private, noconstant(vcdescription)
   IF ((_htmlfileinfo->file_desc != 0))
    SET vcreturn = build("<a href='javascript:APPLINK(",nmode,',"',vcappname,'","',
     vcparams,^")'>^,vcdescription,"</a>")
   ENDIF
   RETURN(vcreturn)
 END ;Subroutine
 SUBROUTINE cclbuildweblink(vcaddress,nmode,vcdescription)
   DECLARE vcreturn = vc WITH private, noconstant(vcdescription)
   IF ((_htmlfileinfo->file_desc != 0))
    IF (nmode=1)
     SET vcreturn = build("<a href='",vcaddress,"'>",vcdescription,"</a>")
    ELSE
     SET vcreturn = build("<a href='",vcaddress,"' target='_blank'>",vcdescription,"</a>")
    ENDIF
   ENDIF
   RETURN(vcreturn)
 END ;Subroutine
 SUBROUTINE get_datahtml(ndummy)
  DECLARE rpt_pageofpage = vc WITH noconstant("Page 1 of 1"), protect
  SELECT INTO  $OUTDEV
   v.inst_id, v.sql_id, v.sql_text,
   v.first_load_time, v.buffer_gets, v.child_number,
   v.cpu_time, v.disk_reads, v.elapsed_time,
   v.executions, v.sql_plan_baseline, v.sql_profile,
   v.rows_processed, v.optimizer_mode, v.plan_hash_value,
   e_ratio = (v.elapsed_time/ v.executions), b_ratio = (v.buffer_gets/ v.executions), d_ratio = (v
   .disk_reads/ v.executions),
   c_ratio = (v.cpu_time/ v.executions)
   FROM gv$sql v
   WHERE v.sql_text=patstring(script_var)
    AND v.sql_text != "*V$SQL*"
    AND v.sql_text != "*CCLSQLAREA*"
    AND v.sql_text != "*DM_SQLAREA*"
    AND v.sql_text != "*DM_SQLPLAN*"
    AND v.sql_text != "*DM_SQL_PLAN*"
    AND v.sql_text != "*V$SQLAREA*"
    AND v.sql_text != "*DM2_CBO_PLAN_ACTUAL*"
    AND v.sql_text != "*DM2CBO*"
    AND v.sql_text != "*PLAN_TABLE*"
    AND v.executions > 0
    AND v.first_load_time >= ""
    AND parser(evaluate(dcpar_child,"ALL","1=1",build("v.child_number = ",cnvtint(dcpar_child))))
   ORDER BY parser(dcpar_sort_order) DESC, parser(dcpar_sort)
   HEAD REPORT
    _d0 = v.inst_id, _d1 = v.sql_id, _d2 = v.sql_text,
    _d3 = v.first_load_time, _d4 = v.buffer_gets, _d5 = v.child_number,
    _d6 = v.cpu_time, _d7 = v.disk_reads, _d8 = v.elapsed_time,
    _d9 = v.executions, _d10 = v.sql_plan_baseline, _d11 = v.sql_profile,
    _d12 = v.rows_processed, _d13 = v.optimizer_mode, _d14 = v.plan_hash_value,
    _d15 = d_ratio, _htmlfileinfo->file_buf = build2("<STYLE>",
     "table {border-collapse: collapse; empty-cells: show;  border: 0.014in solid #000000;  }",
     ".HeadReportRow0 { "," border: 0.014in solid #000000;",
     " padding: 0.000in 0.000in 0.000in 0.000in;",
     " font:   10pt Times;"," "," color: #000000;"," "," text-align: left;",
     " vertical-align: top;}","</STYLE>"), _htmlfilestat = cclio("WRITE",_htmlfileinfo),
    _htmlfileinfo->file_buf = "<table width='100%'><caption>", _htmlfilestat = cclio("WRITE",
     _htmlfileinfo), _htmlfileinfo->file_buf = build2("<colgroup span=27>","<col width=61/>",
     "<col width=62/>","<col width=34/>","<col width=27/>",
     "<col width=35/>","<col width=27/>","<col width=34/>","<col width=27/>","<col width=35/>",
     "<col width=27/>","<col width=34/>","<col width=27/>","<col width=35/>","<col width=27/>",
     "<col width=34/>","<col width=27/>","<col width=35/>","<col width=27/>","<col width=34/>",
     "<col width=27/>","<col width=34/>","<col width=28/>","<col width=34/>","<col width=27/>",
     "<col width=34/>","<col width=62/>","<col width=47/>","</colgroup>"),
    _htmlfilestat = cclio("WRITE",_htmlfileinfo), _htmlfileinfo->file_buf = "<thead>", _htmlfilestat
     = cclio("WRITE",_htmlfileinfo),
    dummy_val = headreportrowhtml(0), _htmlfileinfo->file_buf = "</thead>", _htmlfilestat = cclio(
     "WRITE",_htmlfileinfo),
    _htmlfileinfo->file_buf = "<tbody>", _htmlfilestat = cclio("WRITE",_htmlfileinfo)
   DETAIL
    row_ratio = (ceil(v.rows_processed)/ ceil(v.executions)), buffer_ratio = (ceil(v.buffer_gets)/
    ceil(v.executions)), disk_ratio = (ceil(v.disk_reads)/ ceil(v.executions)),
    elapsed_ratio = (ceil(v.elapsed_time)/ ceil(v.executions)), cpu_ratio = (ceil(v.cpu_time)/ ceil(v
     .executions)), dummy_val = detailrowhtml(0)
   FOOT REPORT
    _htmlfileinfo->file_buf = "</tbody>", _htmlfilestat = cclio("WRITE",_htmlfileinfo), _htmlfileinfo
    ->file_buf = "<tfoot>",
    _htmlfilestat = cclio("WRITE",_htmlfileinfo), dummy_val = footreportrowhtml(0), _htmlfileinfo->
    file_buf = "</tfoot>",
    _htmlfilestat = cclio("WRITE",_htmlfileinfo), _htmlfileinfo->file_buf = "</table>", _htmlfilestat
     = cclio("WRITE",_htmlfileinfo)
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE finalizereport(ssendreport)
   IF (_htmlfileinfo->file_desc)
    SET _htmlfileinfo->file_buf = "</html>"
    SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
    SET _htmlfilestat = cclio("CLOSE",_htmlfileinfo)
   ENDIF
 END ;Subroutine
 SUBROUTINE headreportrowhtml(dummy)
  SET _htmlfileinfo->file_buf = build2("<tr>","<td class='HeadReportRow0' colspan='3'>",
   "SQL_ID(Click to view plan)","</td>","<td class='HeadReportRow0' colspan='2'>",
   "DATABASE INSTANCE","</td>","<td class='HeadReportRow0' colspan='2'>","SQL TEXT","</td>",
   "<td class='HeadReportRow0' colspan='2'>","CHILD NUMBER","</td>",
   "<td class='HeadReportRow0' colspan='2'>","PLAN HASH VALUE",
   "</td>","<td class='HeadReportRow0' colspan='2'>","LOAD TIME","</td>",
   "<td class='HeadReportRow0' colspan='2'>",
   "EXECUTIONS","</td>","<td class='HeadReportRow0' colspan='2'>","ROW RATIO","</td>",
   "<td class='HeadReportRow0' colspan='2'>","BUFFER RATIO","</td>",
   "<td class='HeadReportRow0' colspan='2'>","DISK RATIO",
   "</td>","<td class='HeadReportRow0' colspan='2'>","ELAPSED RATIO","</td>",
   "<td class='HeadReportRow0' colspan='2'>",
   "CPU RATIO","</td>","<td class='HeadReportRow0' colspan='1'>","SQL PLAN BASELINE","</td>",
   "<td class='HeadReportRow0' colspan='1'>","SQL PROFILE","</td>","</tr>")
  SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
 END ;Subroutine
 SUBROUTINE detailrowhtml(dummy)
  SET _htmlfileinfo->file_buf = build2("<tr>","<td class='HeadReportRow0' colspan='3'>",cclbuildhlink
   ("dm2xplan_rpt",build("^MINE^,","^S^,^",v.sql_id,"^,^", $I_CHILD,
     "^,^", $I_MODE,"^,^", $I_NUMQUERIES,"^,^",
      $I_SORTORDER,"^"),0,build(v.sql_id,concat("  (",v.optimizer_mode,")"))),"</td>",
   "<td class='HeadReportRow0' colspan='2'>",
   cnvtstring(v.inst_id),"</td>","<td class='HeadReportRow0' colspan='2'>",v.sql_text,"</td>",
   "<td class='HeadReportRow0' colspan='2'>",ceil(v.child_number),"</td>",
   "<td class='HeadReportRow0' colspan='2'>",format(v.plan_hash_value,"##########"),
   "</td>","<td class='HeadReportRow0' colspan='2'>",v.first_load_time,"</td>",
   "<td class='HeadReportRow0' colspan='2'>",
   ceil(v.executions),"</td>","<td class='HeadReportRow0' colspan='2'>",row_ratio,"</td>",
   "<td class='HeadReportRow0' colspan='2'>",buffer_ratio,"</td>",
   "<td class='HeadReportRow0' colspan='2'>",disk_ratio,
   "</td>","<td class='HeadReportRow0' colspan='2'>",elapsed_ratio,"</td>",
   "<td class='HeadReportRow0' colspan='2'>",
   cpu_ratio,"</td>","<td class='HeadReportRow0' colspan='1'>",v.sql_plan_baseline,"</td>",
   "<td class='HeadReportRow0' colspan='1'>",v.sql_profile,"</td>","</tr>")
  SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
 END ;Subroutine
 SUBROUTINE footreportrowhtml(dummy)
  SET _htmlfileinfo->file_buf = build2("<tr>","<td class='HeadReportRow0' colspan='1'>","","</td>",
   "<td class='HeadReportRow0' colspan='1'>",
   "","</td>","<td class='HeadReportRow0' colspan='2'>","","</td>",
   "<td class='HeadReportRow0' colspan='2'>","","</td>","<td class='HeadReportRow0' colspan='2'>","",
   "</td>","<td class='HeadReportRow0' colspan='2'>","","</td>",
   "<td class='HeadReportRow0' colspan='2'>",
   "","</td>","<td class='HeadReportRow0' colspan='2'>","","</td>",
   "<td class='HeadReportRow0' colspan='2'>","","</td>","<td class='HeadReportRow0' colspan='2'>","",
   "</td>","<td class='HeadReportRow0' colspan='2'>","","</td>",
   "<td class='HeadReportRow0' colspan='2'>",
   "","</td>","<td class='HeadReportRow0' colspan='2'>","","</td>",
   "<td class='HeadReportRow0' colspan='2'>","","</td>","</tr>")
  SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET _htmlfileinfo->file_name = _sendto
   SET _htmlfileinfo->file_buf = "w+b"
   SET _htmlfilestat = cclio("OPEN",_htmlfileinfo)
   SET _htmlfileinfo->file_buf = "<html><head><META content=CCLLINK,APPLINK name=discern /></head>"
   SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
 END ;Subroutine
 IF (( $I_SEARCH=1))
  SET script_var = concat("*CCL<",patstring(cnvtupper( $I_SEARCHTEXT)),"*>*")
 ELSE
  SET script_var = concat("*",cnvtupper( $I_SEARCHTEXT),"*")
 ENDIF
 IF (( $I_SORTORDER="0"))
  SET dcpar_sort_order = "v.sql_id"
  SET dcpar_sort = "v.child_number"
 ELSEIF (( $I_SORTORDER="1"))
  SET dcpar_sort_order = "v.executions"
 ELSEIF (( $I_SORTORDER="2R"))
  SET dcpar_sort_order = "e_ratio"
 ELSEIF (( $I_SORTORDER="3R"))
  SET dcpar_sort_order = "b_ratio"
 ELSEIF (( $I_SORTORDER="4R"))
  SET dcpar_sort_order = "d_ratio"
 ELSEIF (( $I_SORTORDER="5R"))
  SET dcpar_sort_order = "c_ratio"
 ENDIF
 SET dcpar_child =  $I_CHILD
 CALL initializereport(0)
 SET _bishtml = validate(_htmlfileinfo->file_desc,0)
 CALL get_datahtml(0)
 CALL finalizereport(_sendto)
END GO
