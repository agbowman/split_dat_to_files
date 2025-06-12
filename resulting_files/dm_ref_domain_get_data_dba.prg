CREATE PROGRAM dm_ref_domain_get_data:dba
 RECORD reply(
   1 qual[*]
     2 row_id = vc
     2 display = vc
     2 cki = vc
     2 primary_key = f8
     2 unique_ident = vc
     2 from_value = f8
     2 status_flg = i2
     2 to_value = f8
     2 active_ind = i2
     2 index = i4
     2 merge_id = f8
     2 merge_dt_tm = dq8
     2 merge_status_flag = i4
   1 sql[*]
     2 sql_line = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD data_rec(
   1 table_name = c30
   1 translate_name = c30
   1 display = c255
   1 cki_column = c30
   1 primary_key_column = c35
   1 unique_ident_column = c255
   1 from_clause = c255
   1 source_from_clause = c255
   1 where_clause = c255
   1 active_column = c35
   1 order_by_column = c100
 )
 SET reply->status_data.status = "F"
 SET cki_ind = 0
 SELECT INTO "nl:"
  a.column_name
  FROM user_tab_columns a
  WHERE a.table_name="CODE_VALUE"
   AND a.column_name="CKI"
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET cki_ind = 1
 ENDIF
 SELECT INTO "NL:"
  drd.ref_domain_name, drd.translate_name, drd.display_column,
  drd.cki_column, drd.primary_key_column, drd.unique_ident_column,
  drd.from_clause, drd.source_from_clause, drd.order_by_column,
  drd.where_clause, drd.active_column
  FROM dm_ref_domain drd
  WHERE (drd.ref_domain_name=request->ref_domain_name)
  DETAIL
   data_rec->display = drd.display_column, data_rec->table_name = drd.table_name, data_rec->
   translate_name = drd.translate_name,
   data_rec->cki_column = drd.cki_column, data_rec->primary_key_column = drd.primary_key_column,
   data_rec->unique_ident_column = drd.unique_ident_column,
   data_rec->from_clause = drd.from_clause, data_rec->source_from_clause = drd.source_from_clause,
   data_rec->where_clause = drd.where_clause,
   data_rec->order_by_column = drd.order_by_column, data_rec->active_column = drd.active_column
  WITH nocounter
 ;end select
 SET line_buffer[100] = fillstring(255," ")
 SET line_num = 0
 SET j = 0
 SET select_string = fillstring(20," ")
 SET select_string = 'select into "NL:" '
 SET nc_string = fillstring(255," ")
 SET nc_string = "with nocounter go"
 SET where_target = fillstring(80," ")
 SET where_source = fillstring(80," ")
 SET where_source = concat(" mrg.from_value = outerjoin(",trim(data_rec->primary_key_column),")")
 SET alias = substring(1,(findstring(".",trim(data_rec->primary_key_column)) - 1),trim(data_rec->
   primary_key_column))
 SET line_num = 1
 SET line_buffer[line_num] = select_string
 SET line_num = (line_num+ 1)
 SET line_buffer[line_num] = concat(trim(data_rec->display),",")
 SET line_num = (line_num+ 1)
 IF (trim(data_rec->cki_column) != null
  AND cki_ind=1)
  SET line_buffer[line_num] = concat(trim(data_rec->cki_column),",")
  SET line_num = (line_num+ 1)
 ENDIF
 SET line_buffer[line_num] = concat(trim(data_rec->primary_key_column),",")
 SET line_num = (line_num+ 1)
 SET line_buffer[line_num] = build(trim(alias),".","ROWID",",")
 SET line_num = (line_num+ 1)
 IF (trim(data_rec->active_column) != null)
  SET line_buffer[line_num] = concat(trim(data_rec->active_column),",")
  SET line_num = (line_num+ 1)
 ENDIF
 SET line_buffer[line_num] = trim(data_rec->unique_ident_column)
 SET line_num = (line_num+ 1)
 IF ((request->source_ind=1))
  SET line_buffer[line_num] = concat(","," dma.merge_status_flag ",",")
  SET line_num = (line_num+ 1)
  SET line_buffer[line_num] = concat("mrg.to_value",",")
  SET line_num = (line_num+ 1)
  SET line_buffer[line_num] = "mrg.from_value, dma.merge_id, dma.merge_status_flag, dma.merge_dt_tm "
  SET line_num = (line_num+ 1)
 ENDIF
 IF ((request->source_ind=1))
  SET line_buffer[line_num] = concat(trim(data_rec->source_from_clause),
   ", dm_merge_translate mrg, dm_merge_action dma")
  SET line_num = (line_num+ 1)
 ELSE
  SET line_buffer[line_num] = trim(data_rec->from_clause)
  SET line_num = (line_num+ 1)
 ENDIF
 SET maybe = fillstring(132," ")
 SET maybe = trim(data_rec->where_clause)
 IF (maybe != null)
  SET line_buffer[line_num] = trim(data_rec->where_clause)
  SET line_num = (line_num+ 1)
  SET line_buffer[line_num] = concat("and ",data_rec->primary_key_column," > 0")
  SET line_num = (line_num+ 1)
  IF ((request->source_ind=1))
   SET line_buffer[line_num] = concat(" and ",where_source)
   SET line_num = (line_num+ 1)
  ENDIF
 ENDIF
 IF (maybe=null)
  IF ((request->source_ind=1))
   SET line_buffer[line_num] = concat("where ",where_source)
   SET line_num = (line_num+ 1)
   SET line_buffer[line_num] = concat("and ",data_rec->primary_key_column," > 0")
   SET line_num = (line_num+ 1)
  ELSE
   SET line_buffer[line_num] = concat("where ",data_rec->primary_key_column," > 0")
   SET line_num = (line_num+ 1)
  ENDIF
 ENDIF
 IF ((request->source_ind=1))
  SET line_buffer[line_num] = "and mrg.env_source_id = outerjoin(request->env_source_id)"
  SET line_num = (line_num+ 1)
  SET line_buffer[line_num] = "and mrg.env_target_id = outerjoin(request->env_target_id)"
  SET line_num = (line_num+ 1)
  SET line_buffer[line_num] = build("and mrg.table_name = outerjoin('",trim(data_rec->translate_name),
   "')")
  SET line_num = (line_num+ 1)
  SET line_buffer[line_num] = "and dma.env_source_id = outerjoin(request->env_source_id)"
  SET line_num = (line_num+ 1)
  SET line_buffer[line_num] = "and dma.active_ind = outerjoin(1)"
  SET line_num = (line_num+ 1)
  SET line_buffer[line_num] = "and dma.env_target_id = outerjoin(request->env_target_id)"
  SET line_num = (line_num+ 1)
  SET line_buffer[line_num] = build("and dma.table_name = outerjoin('",trim(data_rec->table_name),
   "')")
  SET line_num = (line_num+ 1)
  SET line_buffer[line_num] = build("and dma.from_value= outerjoin(",data_rec->primary_key_column,")"
   )
  SET line_num = (line_num+ 1)
 ENDIF
 IF (trim(data_rec->order_by_column) != null)
  SET line_buffer[line_num] = concat("order by ",trim(data_rec->order_by_column))
 ELSE
  SET line_buffer[line_num] = concat("order by ",trim(data_rec->display))
  SET line_num = (line_num+ 1)
 ENDIF
 SET line_num = (line_num+ 1)
 SET line_buffer[line_num] = "detail"
 SET line_num = (line_num+ 1)
 SET line_buffer[line_num] = "j = j + 1"
 SET line_num = (line_num+ 1)
 SET line_buffer[line_num] = "stat = alterlist(reply->qual, j)"
 SET line_num = (line_num+ 1)
 SET line_buffer[line_num] = concat("reply->qual[j]->display = ",trim(data_rec->display))
 SET line_num = (line_num+ 1)
 SET line_buffer[line_num] = "reply->qual[j]->index = j "
 SET line_num = (line_num+ 1)
 IF (trim(data_rec->cki_column) != null
  AND cki_ind=1)
  SET line_buffer[line_num] = concat("reply->qual[j]->cki = ",trim(data_rec->cki_column))
  SET line_num = (line_num+ 1)
 ENDIF
 SET line_buffer[line_num] = concat("reply->qual[j]->primary_key = ",trim(data_rec->
   primary_key_column))
 SET line_num = (line_num+ 1)
 SET line_buffer[line_num] = concat("reply->qual[j]->unique_ident =",trim(data_rec->
   unique_ident_column))
 SET line_num = (line_num+ 1)
 SET line_buffer[line_num] = build("reply->qual[j]->row_id = ",alias,".","ROWID")
 SET line_num = (line_num+ 1)
 IF (trim(data_rec->active_column) != null)
  SET line_buffer[line_num] = concat("reply->qual[j]->active_ind = ",trim(data_rec->active_column))
 ELSE
  SET line_buffer[line_num] = "reply->qual[j]->active_ind = 1"
 ENDIF
 SET line_num = (line_num+ 1)
 IF ((request->source_ind=1))
  SET line_buffer[line_num] = "reply->qual[j]->from_value = mrg.from_value"
  SET line_num = (line_num+ 1)
  SET line_buffer[line_num] = "reply->qual[j]->to_value = mrg.to_value"
  SET line_num = (line_num+ 1)
  SET line_buffer[line_num] = "reply->qual[j]->merge_id = dma.merge_id"
  SET line_num = (line_num+ 1)
  SET line_buffer[line_num] = "reply->qual[j]->merge_dt_tm = cnvtdatetime(dma.merge_dt_tm)"
  SET line_num = (line_num+ 1)
  SET line_buffer[line_num] = "reply->qual[j]->merge_status_flag = dma.merge_status_flag"
  SET line_num = (line_num+ 1)
 ENDIF
 SET line_buffer[line_num] = nc_string
 SET stat = alterlist(reply->sql,line_num)
 SET i = 1
 FOR (i = 1 TO line_num)
   SET reply->sql[i].sql_line = line_buffer[i]
 ENDFOR
 SET i = 1
 FOR (i = 1 TO line_num)
   CALL parser(line_buffer[i],1)
 ENDFOR
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echo(reply->qual[1].merge_status_flag)
 CALL echo(reply->qual[1].merge_id)
END GO
