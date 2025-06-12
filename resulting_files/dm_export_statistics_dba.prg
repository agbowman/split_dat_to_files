CREATE PROGRAM dm_export_statistics:dba
 FREE RECORD dm_tables
 RECORD dm_tables(
   1 list[*]
     2 tbl_name = vc
 )
 DECLARE dm_stat = i4 WITH public, noconstant(0)
 DECLARE dm_tbl_cnt = i4 WITH public, noconstant(0)
 DECLARE dm_for_cnt = i4 WITH public, noconstant(0)
 DECLARE dm_for_cnt2 = i4 WITH public, noconstant(0)
 DECLARE dm_str = vc WITH public, noconstant(" ")
 DECLARE dm_err_msg = vc WITH public, noconstant(fillstring(132," "))
 SELECT INTO "nl:"
  ut.table_name
  FROM dm2_user_tables ut
  WHERE ut.table_name=patstring(cnvtupper( $1))
  WITH nocounter
 ;end select
 IF ( NOT (curqual))
  CALL echo("*******************************************************")
  CALL echo(concat( $1," not found. Please double check table name."))
  CALL echo("*******************************************************")
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  ut.table_name
  FROM dm2_user_tables ut
  WHERE ((ut.last_analyzed < datetimeadd(cnvtdatetime(curdate,curtime3),- ((1 *  $2)))) OR (ut
  .last_analyzed=null))
   AND ut.table_name=patstring(cnvtupper( $1))
  DETAIL
   dm_tbl_cnt = (dm_tbl_cnt+ 1)
   IF (mod(dm_tbl_cnt,10)=1)
    dm_stat = alterlist(dm_tables->list,(dm_tbl_cnt+ 10))
   ENDIF
   dm_tables->list[dm_tbl_cnt].tbl_name = ut.table_name
  FOOT REPORT
   dm_stat = alterlist(dm_tables->list,dm_tbl_cnt)
  WITH nocounter
 ;end select
 IF (dm_tbl_cnt=0)
  CALL echo("****************************************************************")
  CALL echo(concat("Stats have already been captured within ",trim(cnvtstring( $2),3)," days for ",
     $1))
  CALL echo("****************************************************************")
  GO TO exit_program
 ENDIF
 FOR (dm_for_cnt = 1 TO dm_tbl_cnt)
  EXECUTE dm2_runstats currdbuser, dm_tables->list[dm_for_cnt].tbl_name,  $4
  IF (error(dm_err_msg,1) != 0)
   CALL echo("**************************************************************")
   CALL echo("*** ERROR Occurred Executing dm2_runstats: Exiting Program ***")
   CALL echo("**************************************************************")
   GO TO exit_program
  ELSE
   CALL echo("*****************************************")
   CALL echo("** Runstats have been run successfully **")
   CALL echo("*****************************************")
  ENDIF
 ENDFOR
 IF (currdb="ORACLE")
  SELECT INTO  $3
   ut.table_name, ut.num_rows, ut.blocks,
   ut.avg_row_len
   FROM dm2_user_tables ut
   WHERE ut.table_name=patstring(cnvtupper( $1))
   ORDER BY ut.table_name
   DETAIL
    row + 1, col 0, "declare str = vc go",
    row + 1, dm_str = concat('set str = "rdb asis(^begin DBMS_STATS.SET_TABLE_STATS(',"'",trim(
      currdbuser,3),"','",trim(ut.table_name,3),
     "',null,null,null,",trim(cnvtstring(ut.num_rows),3),",",trim(cnvtstring(ut.blocks),3),",",
     trim(cnvtstring(ut.avg_row_len),3),'); end;^) go" go'), col 0,
    dm_str, row + 1, col 0,
    "call parser(str) go", row + 1
   WITH nocounter, maxcol = 150, formfeed = none,
    maxrow = 1, format = variable
  ;end select
 ENDIF
 IF (currdb="DB2UDB")
  SELECT INTO  $3
   ut.table_name, ut.num_rows, ut.blocks,
   ut.avg_row_len
   FROM dm2_user_tables ut
   WHERE ut.table_name=patstring(cnvtupper( $1))
   ORDER BY ut.table_name
   DETAIL
    row + 2, col 0, "update into sysstat.tables",
    row + 1, col 0, "  set card = ",
    col + 1, ut.num_rows, row + 1,
    col 0, "     ,npages = ", col + 1,
    ut.blocks, row + 1, col 0,
    "     ,fpages = ", col + 1, ut.blocks,
    row + 1, col 0, " where tabschema = ",
    col + 1, currdbuser, row + 1,
    col 0, "   and tabname  = ", col + 1,
    ut.table_name, row + 1, col 0,
    "with nocounter", row + 1, col 0,
    "go", row + 1, col 0,
    "commit go"
   WITH nocounter, maxcol = 150, formfeed = none,
    maxrow = 1, format = variable
  ;end select
  IF (error(dm_err_msg,1) != 0)
   CALL echo("ERROR Tables: Exiting Program")
   GO TO exit_program
  ENDIF
 ENDIF
 IF (currdb="ORACLE")
  SELECT INTO  $3
   ui.index_name, ui.blevel, ui.leaf_blocks,
   ui.distinct_keys, ui.avg_leaf_blocks_per_key, ui.avg_data_blocks_per_key,
   ui.clustering_factor
   FROM dm2_user_indexes ui
   WHERE ui.table_name=patstring(cnvtupper( $1))
   DETAIL
    row + 1, col 0, "declare str = vc go",
    row + 1, dm_str = "set str = ", col 0,
    dm_str, row + 1, dm_str = concat('"rdb asis(^begin DBMS_STATS.SET_INDEX_STATS(',"'",trim(
      currdbuser,3),"','",trim(ui.index_name,3),
     "',","null,null,null,null,",trim(cnvtstring(ui.leaf_blocks),3),",",trim(cnvtstring(ui
       .distinct_keys),3),
     ",",trim(cnvtstring(ui.avg_leaf_blocks_per_key),3),",",trim(cnvtstring(ui
       .avg_data_blocks_per_key),3),",",
     trim(cnvtstring(ui.clustering_factor),3),",",trim(cnvtstring(ui.blevel),3),'); end;^) go" go'),
    col 0, dm_str, row + 1,
    col 0, "call parser(str) go", row + 1
   WITH nocounter, maxcol = 150, append,
    formfeed = none, maxrow = 1, format = variable
  ;end select
 ELSEIF (currdb="DB2UDB")
  SELECT INTO value( $3)
   si.tabname, si.indname, si.nleaf,
   si.nlevels, si.firstkeycard, si.first2keycard,
   si.first3keycard, si.first4keycard, si.fullkeycard,
   si.clusterratio, si.clusterfactor, si.sequential_pages,
   si.density, si.numrids, si.numrids_deleted,
   si.num_empty_leafs
   FROM (syscat.indexes si)
   WHERE tabschema=currdbuser
    AND tabname=patstring( $1)
   DETAIL
    row + 2, col 0, "update into sysstat.indexes",
    row + 1, dm_str = build("  set nleaf            = ",si.nlevels,","), col 0,
    dm_str, row + 1, dm_str = build("      firstkeycard     = ",si.firstkeycard,","),
    col 0, dm_str, row + 1,
    dm_str = build("      first2keycard    = ",si.first2keycard,","), col 0, dm_str,
    row + 1, dm_str = build("      first3keycard    = ",si.first3keycard,","), col 0,
    dm_str, row + 1, dm_str = build("      first4keycard    = ",si.first4keycard,","),
    col 0, dm_str, row + 1,
    dm_str = build("      fullkeycard      = ",si.fullkeycard,","), col 0, dm_str,
    row + 1, dm_str = build("      clusterratio     = ",si.clusterratio,","), col 0,
    dm_str, row + 1, dm_str = build("      clusterfactor    = ",si.clusterfactor,","),
    col 0, dm_str, row + 1,
    dm_str = build("      sequential_pages = ",si.sequential_pages,","), col 0, dm_str,
    row + 1, dm_str = build("      density          = ",si.density,","), col 0,
    dm_str, row + 1, dm_str = build("      numrids          = ",si.numrids,","),
    col 0, dm_str, row + 1,
    dm_str = build("      numrids_deleted  = ",si.numrids_deleted,","), col 0, dm_str,
    row + 1, dm_str = build("      num_empty_leafs  = ",si.num_empty_leafs,","), col 0,
    dm_str, row + 1, dm_str = build(" where indname = '",si.indname,"'"),
    col 0, dm_str, row + 1,
    dm_str = concat("   and indschema = '",trim(currdbuser,3),"'"), col 0, dm_str,
    row + 1, dm_str = build("   and tabname = '",si.tabname,"'"), col 0,
    dm_str, row + 1, dm_str = concat("   and tabschema = '",trim(currdbuser,3),"'"),
    col 0, dm_str, row + 1,
    col 0, "go", row + 1,
    col 0, "commit go", row + 3
   WITH nocounter, maxcol = 150, append,
    formfeed = none, maxrow = 1, format = variable
  ;end select
  IF (error(dm_err_msg,1) != 0)
   CALL echo("ERROR Indexes: Exiting Program")
   GO TO exit_program
  ENDIF
 ENDIF
#exit_program
 FREE RECORD dm_tables
END GO
