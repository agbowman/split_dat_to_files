CREATE PROGRAM dm_merge_add:dba
 RECORD temp(
   1 pri = vc
   1 var = vc
   1 unique_id = vc
   1 target_from = vc
   1 source_from = vc
   1 where_stmt = vc
   1 domain_name = vc
   1 pkey = vc
   1 where_tab = vc
 )
 FREE SET data
 RECORD data(
   1 target[*]
     2 row_id = vc
     2 unique_ident = vc
   1 source[*]
     2 row_id = vc
     2 unique_ident = vc
     2 pri_k = f4
 )
 RECORD tabl(
   1 table_nm = vc
 )
 RECORD check(
   1 trans[*]
     2 from_val = f4
 )
 SET pri_key = fillstring(35,"")
 SET a = fillstring(1,"")
 SET ta = 0
 SET tar = 0
 SET sou = 0
 SET tar1 = 0
 SET sou1 = 0
 SET z = 0
 SET y = 0
 SET track = 0
 SET temp->domain_name = concat(trim(d_name,1))
 SELECT INTO "nl:"
  d.table_name, d.primary_key_column, d.unique_ident_column,
  d.from_clause, d.source_from_clause, d.where_clause
  FROM dm_ref_domain d
  WHERE d.ref_domain_name=d_name
  HEAD REPORT
   pri_key = d.primary_key_column
  DETAIL
   tabl->table_nm = d.table_name, a = ".", tbl_alias = findstring(a,pri_key),
   temp->pri = substring(1,tbl_alias,pri_key), temp->var = concat(trim(temp->pri),"rowid"), temp->
   pkey = d.primary_key_column,
   temp->unique_id = d.unique_ident_column, temp->target_from = d.from_clause, temp->source_from = d
   .source_from_clause,
   temp->where_stmt = d.where_clause
  WITH nocounter
 ;end select
 SET parser_buffer[11] = fillstring(350," ")
 SET x = initarray(parser_buffer," ")
 SET parser_buffer[1] = "select into 'nl:'"
 SET parser_buffer[2] = concat("trw=",temp->var,", tui=",temp->unique_id)
 SET parser_buffer[3] = temp->target_from
 SET parser_buffer[4] = temp->where_stmt
 SET parser_buffer[5] = "detail"
 SET parser_buffer[6] = "stat=alterlist(data->TARGET, z+1)"
 SET parser_buffer[7] = "z = z+1"
 SET parser_buffer[8] = "data->target[z]->row_id=trw"
 SET parser_buffer[9] = "data->target[z]->unique_ident=tui"
 SET parser_buffer[10] = "go"
 SET cnt = 0
 FOR (cnt = 1 TO 11)
  CALL echo(parser_buffer[cnt])
  CALL parser(parser_buffer[cnt],1)
 ENDFOR
 SET parser_buffer[11] = fillstring(132," ")
 SET x = initarray(parser_buffer," ")
 SET parser_buffer[1] = "select into 'nl:'"
 SET parser_buffer[2] = concat("srw=",temp->var,", sui=",temp->unique_id,", kk=",
  temp->pkey)
 SET parser_buffer[3] = temp->source_from
 SET parser_buffer[4] = temp->where_stmt
 SET parser_buffer[5] = "DETAIL"
 SET parser_buffer[6] = "stat=alterlist(data->source, y+1)"
 SET parser_buffer[7] = "y = y+1"
 SET parser_buffer[8] = "data->source[y]->row_id=srw"
 SET parser_buffer[9] = "data->source[y]->unique_ident=sui"
 SET parser_buffer[10] = "data->source[y]->pri_k=kk"
 SET parser_buffer[11] = "go"
 SET cnt = 0
 FOR (cnt = 1 TO 11)
  CALL echo(parser_buffer[cnt])
  CALL parser(parser_buffer[cnt],1)
 ENDFOR
 CALL echorecord(data)
 SET parser_buffer[11] = fillstring(300," ")
 SET x = initarray(parser_buffer," ")
 SET parser_buffer[1] = "select into 'nl:'"
 SET parser_buffer[2] = "t.from_value, t.table_name"
 SET parser_buffer[3] = "from dm_merge_translate t"
 SET parser_buffer[4] = "where t.table_name = tabl->table_nm"
 SET parser_buffer[5] = "detail"
 SET parser_buffer[6] = "stat=alterlist(check->trans, ta+1)"
 SET parser_buffer[7] = "ta = ta +1"
 SET parser_buffer[8] = "check->trans[ta]->from_val=t.from_value"
 SET parser_buffer[9] = "go"
 SET cnt = 0
 FOR (cnt = 1 TO 9)
  CALL echo(parser_buffer[cnt])
  CALL parser(parser_buffer[cnt],1)
 ENDFOR
 CALL echorecord(check)
 CALL echo(ta)
 SELECT INTO tll_merge_file
  FROM dummyt
  HEAD REPORT
   CALL center("/* Include this file to Merge the Following: */",1,80), row + 2
  DETAIL
   tar = z, sou = y, tar1 = tar,
   sou1 = sou, z = 0, y = 0,
   tab = ta, ta = 0
   FOR (z = 1 TO tar)
    merge_done = 0,
    FOR (y = 1 TO sou)
      IF ((data->target[z].unique_ident=data->source[y].unique_ident))
       FOR (ta = 1 TO tab)
         IF ((check->trans[ta].from_val=data->source[y].pri_k))
          merge_done = 1
         ENDIF
       ENDFOR
       IF (merge_done=0)
        row + 1, col 0, ";Unique_Id:",
        col 20, ";source - ", data->source[y].unique_ident,
        row + 1, col 20, ";target - ",
        data->target[z].unique_ident, row + 1, "dm_merge_batch '",
        data->source[y].row_id, "', ;from rowid", row + 1,
        "               '", data->target[z].row_id, "', ;to rowid",
        row + 1, "               '", tabl->table_nm,
        "', ;table name", row + 1, "               '",
        temp->domain_name, "', ;ref domain name", row + 1,
        "               ", mas, " go ;master ind, 1=source is master",
        row + 4, stat = alterlist(info->merge,(m+ 1)), m = (m+ 1),
        merge_no = (merge_no+ 1), info->merge[m].ident = data->source[y].unique_ident, info->merge[m]
        .from_id = data->source[y].row_id,
        info->merge[m].to_id = data->target[z].row_id, info->merge[m].tabb = tabl->table_nm, info->
        merge[m].domain = temp->domain_name,
        info->merge[m].master = mas
       ENDIF
      ENDIF
    ENDFOR
   ENDFOR
  WITH nocounter, formfeed = none, format = stream,
   maxcol = 300
 ;end select
 SELECT INTO tll_add_file
  FROM dummyt
  HEAD REPORT
   row 1,
   CALL center("/* Include this file to Add the Following: */",1,80), row + 2
  DETAIL
   z = 0, y = 0
   FOR (y = 1 TO sou1)
     mflag = 0
     FOR (z = 1 TO tar1)
       IF ((data->source[y].unique_ident=data->target[z].unique_ident))
        mflag = (mflag+ 1)
       ENDIF
     ENDFOR
     IF (mflag=0)
      track = (track+ 1), row + 1, col 0,
      ";Unique_Id: ", data->source[y].unique_ident, row + 1,
      "dm_merge_batch '", data->source[y].row_id, "', ;from rowid",
      row + 1, "               '', ;to rowid", row + 1,
      "               '", tabl->table_nm, "', ;table name",
      row + 1, "               '", temp->domain_name,
      "', ;ref domain name", row + 1, "               ",
      mas, " go ;master ind, 1=source is master", row + 4,
      stat = alterlist(info->add,(ad+ 1)), ad = (ad+ 1), add_no = (add_no+ 1),
      info->add[ad].ident = data->source[y].unique_ident, info->add[ad].from_id = data->source[y].
      row_id, info->add[ad].to_id = "",
      info->add[ad].tabb = tabl->table_nm, info->add[ad].domain = temp->domain_name, info->add[ad].
      master = mas
     ENDIF
   ENDFOR
   IF (track=0)
    col 0, ";There is no new data to add."
   ENDIF
  WITH nocounter, formfeed = none, format = stream,
   maxcol = 300
 ;end select
END GO
