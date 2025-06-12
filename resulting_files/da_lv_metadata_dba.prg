CREATE PROGRAM da_lv_metadata:dba
 DECLARE daprint(text=vc) = null WITH public
 DECLARE dacleancolumn(column=vc) = vc WITH public
 DECLARE out_filename = vc WITH constant("DA_METADATA")
 DECLARE lv_id = f8 WITH noconstant(0.0)
 DECLARE tab_cnt = i2 WITH noconstant(0)
 DECLARE col_cnt = i2 WITH noconstant(0)
 DECLARE where_cnt = i2 WITH noconstant(0)
 DECLARE grp_by_cnt = i2 WITH noconstant(0)
 DECLARE query_cnt = i2 WITH noconstant(0)
 DECLARE num = i2 WITH noconstant(0)
 DECLARE temp_line = vc WITH noconstant("")
 DECLARE errcode = i4 WITH noconstant(0)
 DECLARE errmsg = vc WITH noconstant("")
 DECLARE run_ind = i2 WITH noconstant(1)
 DECLARE run_text = vc WITH noconstant("")
 DECLARE start_pos = i4 WITH noconstant(0)
 DECLARE uuid_start_pos = i4 WITH noconstant(0)
 DECLARE uuid_end_pos = i4 WITH noconstant(0)
 DECLARE uid_cnt = i4 WITH noconstant(0)
 RECORD query(
   1 qual[*]
     2 select_clause[*]
       3 line = vc
     2 from_clause[*]
       3 table_id = f8
       3 line = vc
     2 where_clause[*]
       3 line = vc
     2 group_by_clause[*]
       3 line = vc
 )
 RECORD uid(
   1 qual[*]
     2 value = vc
 )
 SET lv_id = parameter(1,0)
 IF (reflect(parameter(2,0))=" ")
  SET run_ind = 1
 ELSE
  SET run_text = parameter(2,0)
  IF (((run_text="-w") OR (run_text="-W")) )
   SET run_ind = 0
  ENDIF
 ENDIF
 SET query_cnt = 1
 SET stat = alterlist(query->qual,query_cnt)
 SELECT INTO "NL:"
  FROM da_logical_view lv,
   da_lv_table_elem_reltn ter,
   da_element de,
   long_text_reference cols
  WHERE lv.da_logical_view_id=lv_id
   AND ((ter.da_logical_view_id=lv.da_logical_view_id) OR (ter.da_logical_view_id=lv
  .parent_logical_view_id
   AND lv.parent_logical_view_id > 0))
   AND de.da_element_id=ter.da_element_id
   AND de.active_ind=1
   AND cols.long_text_id=de.column_string_txt_id
  ORDER BY de.da_element_id
  HEAD REPORT
   col_cnt = 0, uid_cnt = 0
  HEAD de.da_element_id
   col_cnt = (col_cnt+ 1), stat = alterlist(query->qual[query_cnt].select_clause,col_cnt), query->
   qual[query_cnt].select_clause[col_cnt].line = dacleancolumn(cols.long_text),
   start_pos = 1
   WHILE (findstring(":uuid(",trim(cols.long_text,3),start_pos) > 0)
     uuid_start_pos = (findstring(":uuid(",trim(cols.long_text,3),start_pos)+ 6), uuid_end_pos =
     findstring(")",trim(cols.long_text,3),uuid_start_pos), uid_cnt = (uid_cnt+ 1),
     stat = alterlist(uid->qual,uid_cnt), uid->qual[uid_cnt].value = substring(uuid_start_pos,(
      uuid_end_pos - uuid_start_pos),trim(cols.long_text,3)), start_pos = (uuid_end_pos+ 1)
   ENDWHILE
   IF (de.group_by_ind=1
    AND size(trim(de.group_by_string_txt,3)) > 0)
    grp_by_cnt = (grp_by_cnt+ 1), stat = alterlist(query->qual[query_cnt].group_by_clause,grp_by_cnt),
    query->qual[query_cnt].group_by_clause[grp_by_cnt].line = dacleancolumn(de.group_by_string_txt)
   ENDIF
   IF (de.group_by_qual_ind=1
    AND size(trim(de.qual_string_txt,3)) > 0)
    grp_by_cnt = (grp_by_cnt+ 1), stat = alterlist(query->qual[query_cnt].group_by_clause,grp_by_cnt),
    query->qual[query_cnt].group_by_clause[grp_by_cnt].line = dacleancolumn(de.qual_string_txt)
   ENDIF
   IF (de.group_by_column_ind=1
    AND size(trim(cols.long_text,3)) > 0)
    grp_by_cnt = (grp_by_cnt+ 1), stat = alterlist(query->qual[query_cnt].group_by_clause,grp_by_cnt),
    query->qual[query_cnt].group_by_clause[grp_by_cnt].line = dacleancolumn(cols.long_text)
   ENDIF
  WITH nocounter
 ;end select
 IF (size(uid->qual,5) > 0)
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = size(uid->qual,5)),
    da_element e,
    long_text_reference cols
   PLAN (d)
    JOIN (e
    WHERE (e.element_uuid=uid->qual[d.seq].value))
    JOIN (cols
    WHERE cols.long_text_id=e.column_string_txt_id)
   DETAIL
    FOR (i = 1 TO size(query->qual[query_cnt].select_clause,5))
      new_txt = replace(query->qual[query_cnt].select_clause[i].line,uid->qual[d.seq].value,trim(cols
        .long_text,3),0), new_txt = replace(new_txt,":uuid","",0), query->qual[query_cnt].
      select_clause[i].line = dacleancolumn(new_txt)
    ENDFOR
   WITH nocounter
  ;end select
 ENDIF
 FOR (q_cnt = 1 TO size(query->qual,5))
   SELECT INTO "NL:"
    FROM da_table_reltn dtr,
     da_logical_view lv,
     da_table_info tabs,
     da_table_info join_tabs,
     long_text_reference whr
    PLAN (lv
     WHERE lv.da_logical_view_id=lv_id)
     JOIN (dtr
     WHERE dtr.parent_entity_name="DA_LOGICAL_VIEW"
      AND ((dtr.parent_entity_id=lv.da_logical_view_id) OR (dtr.parent_entity_id=lv
     .parent_logical_view_id
      AND lv.parent_logical_view_id > 0))
      AND dtr.where_clause_txt_id > 0)
     JOIN (tabs
     WHERE tabs.da_table_info_id=dtr.table_id)
     JOIN (join_tabs
     WHERE join_tabs.da_table_info_id=dtr.join_table_id)
     JOIN (whr
     WHERE whr.long_text_id=dtr.where_clause_txt_id)
    ORDER BY dtr.table_id, dtr.join_table_id, whr.long_text_id
    HEAD REPORT
     tab_cnt = 0, where_cnt = 0
    HEAD dtr.table_id
     IF (dtr.table_id > 0
      AND locateval(num,1,tab_cnt,dtr.table_id,query->qual[q_cnt].from_clause[num].table_id)=0)
      tab_cnt = (tab_cnt+ 1), stat = alterlist(query->qual[query_cnt].from_clause,tab_cnt), query->
      qual[q_cnt].from_clause[tab_cnt].table_id = tabs.da_table_info_id,
      query->qual[q_cnt].from_clause[tab_cnt].line = concat(trim(tabs.table_name,3)," ",trim(tabs
        .table_alias_name,3))
     ENDIF
    HEAD dtr.join_table_id
     IF (dtr.join_table_id > 0
      AND locateval(num,1,tab_cnt,dtr.join_table_id,query->qual[q_cnt].from_clause[num].table_id)=0)
      tab_cnt = (tab_cnt+ 1), stat = alterlist(query->qual[query_cnt].from_clause,tab_cnt), query->
      qual[q_cnt].from_clause[tab_cnt].table_id = join_tabs.da_table_info_id,
      query->qual[q_cnt].from_clause[tab_cnt].line = concat(trim(join_tabs.table_name,3)," ",trim(
        join_tabs.table_alias_name,3))
     ENDIF
    HEAD whr.long_text_id
     IF (size(trim(whr.long_text,3)) > 0)
      where_cnt = (where_cnt+ 1), stat = alterlist(query->qual[q_cnt].where_clause,where_cnt), query
      ->qual[q_cnt].where_clause[where_cnt].line = dacleancolumn(whr.long_text)
     ENDIF
    WITH nocounter
   ;end select
 ENDFOR
 SET where_cnt = (where_cnt+ 1)
 SET stat = alterlist(query->qual[1].where_clause,where_cnt)
 SET query->qual[1].where_clause[where_cnt].line = "rownum < 10"
 SET message = noinformation
 SELECT INTO value(out_filename)
  FROM dummyt
  DETAIL
   CALL print("")
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1
 ;end select
 FOR (j = 1 TO size(query->qual,5))
   FOR (i = 1 TO size(query->qual[j].select_clause,5))
    IF (i=1)
     CALL daprint("RDB")
     SET temp_line = concat("SELECT ",query->qual[j].select_clause[i].line)
    ELSE
     SET temp_line = concat("     , ",query->qual[j].select_clause[i].line)
    ENDIF
    CALL daprint(temp_line)
   ENDFOR
   FOR (i = 1 TO size(query->qual[j].from_clause,5))
    IF (i=1)
     SET temp_line = concat("FROM ",query->qual[j].from_clause[i].line)
    ELSE
     SET temp_line = concat("   , ",query->qual[j].from_clause[i].line)
    ENDIF
    CALL daprint(temp_line)
   ENDFOR
   FOR (i = 1 TO size(query->qual[j].where_clause,5))
    IF (i=1)
     SET temp_line = concat("WHERE ",query->qual[j].where_clause[i].line)
    ELSE
     SET temp_line = concat("  AND ",query->qual[j].where_clause[i].line)
    ENDIF
    CALL daprint(temp_line)
   ENDFOR
   FOR (i = 1 TO size(query->qual[j].group_by_clause,5))
    IF (i=1)
     SET temp_line = concat("GROUP BY ",query->qual[j].group_by_clause[i].line)
    ELSE
     SET temp_line = concat("        ,  ",query->qual[j].group_by_clause[i].line)
    ENDIF
    CALL daprint(temp_line)
   ENDFOR
   CALL daprint("")
 ENDFOR
 SET message = information
 DECLARE query_size = i4 WITH noconstant(0)
 FOR (i = 1 TO size(query->qual[1].select_clause,5))
   SET query_size = (query_size+ size(query->qual[1].select_clause[i].line))
 ENDFOR
 FOR (i = 1 TO size(query->qual[1].from_clause,5))
   SET query_size = (query_size+ size(query->qual[1].from_clause[i].line))
 ENDFOR
 FOR (i = 1 TO size(query->qual[1].where_clause,5))
   SET query_size = (query_size+ size(query->qual[1].where_clause[i].line))
 ENDFOR
 FOR (i = 1 TO size(query->qual[1].group_by_clause,5))
   SET query_size = (query_size+ size(query->qual[1].group_by_clause[i].line))
 ENDFOR
 SET query_size = (query_size+ 100)
 IF (run_ind=1)
  SET errcode = error(errmsg,1)
  IF (size(query->qual[1].from_clause,5) > 0)
   CALL parser("RDB")
   FOR (j = 1 TO size(query->qual,5))
     FOR (i = 1 TO size(query->qual[j].select_clause,5))
      IF (i=1)
       SET temp_line = concat("SELECT ",replace(replace(replace(query->qual[j].select_clause[i].line,
           " end",' asis(" end")')," END",' asis(" END")'),"||",'asis("||")'))
      ELSE
       SET temp_line = concat("     , ",replace(replace(replace(query->qual[j].select_clause[i].line,
           " end",' asis(" end")')," END",' asis(" END")'),"||",'asis("||")'))
      ENDIF
      CALL parser(temp_line)
     ENDFOR
     FOR (i = 1 TO size(query->qual[j].from_clause,5))
      IF (i=1)
       SET temp_line = concat("FROM ",query->qual[j].from_clause[i].line)
      ELSE
       SET temp_line = concat("   , ",query->qual[j].from_clause[i].line)
      ENDIF
      CALL parser(temp_line)
     ENDFOR
     FOR (i = 1 TO size(query->qual[j].where_clause,5))
      IF (i=1)
       SET temp_line = concat("WHERE ",query->qual[j].where_clause[i].line)
      ELSE
       SET temp_line = concat("  AND ",query->qual[j].where_clause[i].line)
      ENDIF
      CALL parser(temp_line)
     ENDFOR
     FOR (i = 1 TO size(query->qual[j].group_by_clause,5))
      IF (i=1)
       SET temp_line = concat("GROUP BY ",replace(query->qual[j].group_by_clause[i].line,"||",
         'asis("||")'))
      ELSE
       SET temp_line = concat("        ,  ",replace(query->qual[j].group_by_clause[i].line,"||",
         'asis("||")'))
      ENDIF
      CALL parser(temp_line)
     ENDFOR
   ENDFOR
   CALL parser("GO")
  ENDIF
  SET errcode = error(errmsg,0)
  CALL echo("")
  CALL echo("")
  CALL echo("")
  CALL echo("")
  CALL echo("################################################################")
  IF (errcode != 0)
   CALL echo("Error while running query")
   CALL echo(errmsg)
  ELSE
   CALL echo("Query ran successfully")
  ENDIF
  CALL echo("################################################################")
 ENDIF
 SUBROUTINE daprint(text)
   SELECT INTO value(out_filename)
    FROM dummyt
    DETAIL
     CALL print(text)
    WITH noheading, nocounter, format = lfstream,
     maxcol = 1999, maxrow = 1, append
   ;end select
 END ;Subroutine
 SUBROUTINE dacleancolumn(column)
   DECLARE return_val = vc
   SET return_val = replace(replace(trim(column,3),":CURUTC",trim(cnvtstring(curutc),3)),
    ":CURTIMEZONEAPP",trim(cnvtstring(curtimezoneapp),3))
   RETURN(return_val)
 END ;Subroutine
END GO
