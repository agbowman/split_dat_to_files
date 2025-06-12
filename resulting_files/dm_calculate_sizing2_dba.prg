CREATE PROGRAM dm_calculate_sizing2:dba
 SET environment_id =  $1
 SET schema_date = cnvtdatetime( $2)
 SET system = cnvtupper( $3)
 SET cname = cnvtupper( $4)
 SET mode =  $5
 SET mbyte = (1024.0 * 1024.0)
 SET rem_size = 0.0
 SET cid = fillstring(15," ")
 SELECT INTO "nl:"
  c.client_mnemonic
  FROM dm_client_size c
  WHERE c.client_name=cname
  DETAIL
   cid = c.client_mnemonic
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET tempstr = fillstring(132," ")
  SET fname = "dm_calculate_sizing2.log"
  SELECT INTO value(fname)
   *
   FROM dual
   DETAIL
    tempstr = "Client name entered does not have a match in the database", tempstr, row + 1,
    tempstr = "Please enter the correct client name and run sizing again", tempstr, row + 1
   WITH nocounter, maxcol = 512, formfeed = none,
    maxrow = 1
  ;end select
  GO TO end_prg
 ENDIF
 SET block_size = 0.0
 SELECT INTO "nl:"
  d.value
  FROM v$parameter d
  WHERE d.name="db_block_size"
  DETAIL
   block_size = cnvtint(d.value)
  WITH nocounter
 ;end select
 FREE SET table_list
 RECORD table_list(
   1 table_count = i4
   1 total_row_count = f8
   1 list[*]
     2 tname = c32
     2 rowcount = f8
     2 bytes_per_row = f8
     2 init = f8
     2 next = f8
     2 static_rows = f8
     2 sum_index = f8
     2 static_size = f8
     2 bytes_per_day = f8
     2 index_count = i4
     2 new_ind = i2
     2 total = f8
     2 index_name[*]
       3 iname = c32
       3 col_length = i4
       3 bytes_per_row = f8
       3 init = f8
       3 next = f8
       3 static_size = f8
       3 bytes_per_day = f8
       3 new_ind_old_tab = i2
       3 new_ind_new_tab = i2
       3 tsize = f8
       3 total = f8
 )
 SET table_list->table_count = 0
 SET kount = 0
 SET tab_count = 0
 SELECT INTO "nl:"
  dt.table_name
  FROM dm_tables dt
  WHERE dt.schema_date=cnvtdatetime(schema_date)
  ORDER BY dt.table_name
  DETAIL
   kount = (kount+ 1)
   IF (mod(kount,10)=1)
    stat = alterlist(table_list->list,(kount+ 9))
   ENDIF
   table_list->list[kount].tname = dt.table_name, table_list->list[kount].new_ind = 1, tab_count = (
   tab_count+ 1)
  WITH nocounter
 ;end select
 SET table_list->table_count = kount
 SELECT INTO "nl:"
  d.seq, table_name = table_list->list[d.seq].tname, di.index_name,
  dic.column_name, dc.data_length
  FROM (dummyt d  WITH seq = value(table_list->table_count)),
   dm_indexes di,
   dm_index_columns dic,
   dm_columns dc
  PLAN (d)
   JOIN (di
   WHERE (di.table_name=table_list->list[d.seq].tname)
    AND di.schema_date=cnvtdatetime(schema_date))
   JOIN (dic
   WHERE dic.table_name=di.table_name
    AND dic.schema_date=di.schema_date
    AND dic.index_name=di.index_name)
   JOIN (dc
   WHERE dc.table_name=dic.table_name
    AND dc.schema_date=dic.schema_date
    AND dc.column_name=dic.column_name)
  ORDER BY d.seq, di.index_name
  HEAD d.seq
   icnt = 0
  HEAD di.index_name
   icnt = (icnt+ 1)
   IF (mod(icnt,10)=1)
    stat = alterlist(table_list->list[d.seq].index_name,(icnt+ 9))
   ENDIF
   table_list->list[d.seq].index_name[icnt].iname = di.index_name, table_list->list[d.seq].
   index_name[icnt].new_ind_new_tab = 1, table_list->list[d.seq].index_name[icnt].new_ind_old_tab = 1,
   col_length = 0.0
  DETAIL
   col_length = (col_length+ dc.data_length)
  FOOT  di.index_name
   table_list->list[d.seq].index_name[icnt].col_length = col_length
  FOOT  d.seq
   table_list->list[d.seq].index_count = icnt
  WITH nocounter
 ;end select
 RECORD tab_list(
   1 qual[*]
     2 ob_name = vc
     2 bytes_per_row = f8
     2 no_of_rows = f8
     2 static_size = f8
     2 bytes_per_day = f8
   1 count = i4
 )
 SET tab_list->count = 0
 RECORD ind_list(
   1 qual[*]
     2 ob_name = vc
     2 bytes_per_row = f8
     2 no_of_rows = f8
     2 static_size = f8
     2 bytes_per_day = f8
   1 count = i4
 )
 SET ind_list->count = 0
 SELECT INTO "nl:"
  a.*
  FROM dm_client_object_size a,
   dm_client_size b
  WHERE b.client_mnemonic=cid
   AND a.client_mnemonic=b.client_mnemonic
   AND a.object_type="TABLE"
  DETAIL
   tab_list->count = (tab_list->count+ 1), stat = alterlist(tab_list->qual,tab_list->count), tab_list
   ->qual[tab_list->count].ob_name = a.object_name,
   tab_list->qual[tab_list->count].bytes_per_row = a.bytes_per_row, tab_list->qual[tab_list->count].
   no_of_rows = a.curr_num_rows, tab_list->qual[tab_list->count].bytes_per_day = a.used_space_day
   IF (a.static_ind=1)
    tab_list->qual[tab_list->count].static_size = a.curr_used_space
   ELSE
    tab_list->qual[tab_list->count].static_size = 0
   ENDIF
   IF ((tab_list->qual[tab_list->count].bytes_per_day=0)
    AND (tab_list->qual[tab_list->count].static_size < (2 * block_size)))
    tab_list->qual[tab_list->count].static_size = (2 * block_size)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  a.*
  FROM dm_client_object_size a,
   dm_client_size b
  WHERE b.client_mnemonic=cid
   AND a.client_mnemonic=b.client_mnemonic
   AND a.object_type="INDEX"
  DETAIL
   ind_list->count = (ind_list->count+ 1), stat = alterlist(ind_list->qual,ind_list->count), ind_list
   ->qual[ind_list->count].ob_name = a.object_name,
   ind_list->qual[ind_list->count].bytes_per_row = a.bytes_per_row, ind_list->qual[ind_list->count].
   no_of_rows = a.curr_num_rows, ind_list->qual[ind_list->count].bytes_per_day = a.used_space_day
   IF (a.static_ind=1)
    ind_list->qual[ind_list->count].static_size = a.curr_used_space
   ELSE
    ind_list->qual[ind_list->count].static_size = 0
   ENDIF
   IF ((ind_list->qual[ind_list->count].bytes_per_day=0)
    AND (ind_list->qual[ind_list->count].static_size < (2 * block_size)))
    ind_list->qual[ind_list->count].static_size = (2 * block_size)
   ENDIF
  WITH nocounter
 ;end select
 SET c = 0
 SET d = 0
 FOR (c = 1 TO table_list->table_count)
   FOR (d = 1 TO tab_list->count)
     IF ((table_list->list[c].tname=tab_list->qual[d].ob_name))
      SET table_list->list[c].bytes_per_row = tab_list->qual[d].bytes_per_row
      SET table_list->list[c].static_size = tab_list->qual[d].static_size
      SET table_list->list[c].bytes_per_day = tab_list->qual[d].bytes_per_day
      SET table_list->list[c].new_ind = 0
      SET tab_count = (tab_count - 1)
     ENDIF
   ENDFOR
 ENDFOR
 SET old_ind_sum = 0.0
 SET ind_count = 0
 SET x = 0
 SET y = 0
 SET z = 0
 FOR (x = 1 TO table_list->table_count)
   FOR (y = 1 TO table_list->list[x].index_count)
    FOR (z = 1 TO ind_list->count)
      IF ((table_list->list[x].index_name[y].iname=ind_list->qual[z].ob_name))
       SET table_list->list[x].index_name[y].bytes_per_row = ind_list->qual[z].bytes_per_row
       SET table_list->list[x].index_name[y].static_size = ind_list->qual[z].static_size
       SET table_list->list[x].index_name[y].bytes_per_day = ind_list->qual[z].bytes_per_day
       SET table_list->list[x].index_name[y].new_ind_old_tab = 0
       SET table_list->list[x].index_name[y].new_ind_new_tab = 0
      ENDIF
    ENDFOR
    IF ((table_list->list[x].index_name[y].new_ind_new_tab=1)
     AND (table_list->list[x].index_name[y].new_ind_old_tab=1))
     IF ((table_list->list[x].new_ind=1))
      SET table_list->list[x].index_name[y].new_ind_old_tab = 0
      SET ind_count = (ind_count+ 1)
     ELSE
      FOR (w = 1 TO tab_list->count)
        IF ((table_list->list[x].tname=tab_list->qual[w].ob_name))
         SET table_list->list[x].index_name[y].new_ind_new_tab = 0
         SET table_list->list[x].index_name[y].tsize = (table_list->list[x].index_name[y].col_length
          * tab_list->qual[w].no_of_rows)
         IF ((table_list->list[x].index_name[y].tsize < (2 * block_size)))
          SET table_list->list[x].index_name[y].tsize = (2 * block_size)
         ENDIF
         SET old_ind_sum = (old_ind_sum+ table_list->list[x].index_name[y].tsize)
        ENDIF
      ENDFOR
     ENDIF
    ENDIF
   ENDFOR
 ENDFOR
 SET tab_sum = 0.0
 SET tab_sum = ((tab_count * 2) * block_size)
 SET ind_sum = 0.0
 SET ind_sum = ((ind_count * 2) * block_size)
 SET ndays = 0
 SET target_size = 0.0
 SET partition_size = 0.0
 SET max_size = 0.0
 SET database_name = fillstring(6," ")
 SELECT INTO "nl:"
  de.total_database_size, de.month_cnt, de.data_file_partition_size,
  de.database_name, de.max_file_size
  FROM dm_environment de
  WHERE de.environment_id=environment_id
  DETAIL
   IF (mode=1)
    target_size = de.total_database_size
   ELSEIF (mode=2)
    ndays = floor((de.month_cnt * 30))
   ENDIF
   partition_size = de.data_file_partition_size, database_name = de.database_name, max_size = (de
   .max_file_size * mbyte)
  WITH nocounter
 ;end select
 IF (mode=2)
  IF (ndays < 90)
   DELETE  FROM dm_env_table det
    WHERE det.environment_id=environment_id
    WITH nocounter
   ;end delete
   COMMIT
   DELETE  FROM dm_env_index dei
    WHERE dei.environment_id=environment_id
    WITH nocounter
   ;end delete
   COMMIT
   DELETE  FROM dm_env_files def
    WHERE def.environment_id=environment_id
     AND def.file_type IN ("DATA", "INDEX")
    WITH nocounter
   ;end delete
   COMMIT
   UPDATE  FROM dm_environment d
    SET d.total_database_size = 0
    WHERE d.environment_id=environment_id
    WITH nocounter
   ;end update
   COMMIT
   GO TO end_prg
  ENDIF
 ENDIF
 EXECUTE FROM tablespace_start TO tablespace_end
#tablespace_start
 FREE SET tspace_list
 RECORD tspace_list(
   1 tname[*]
     2 tspace_name = c32
     2 raw_bytes = f8
     2 partitioned_bytes = f8
     2 static_ind = i2
   1 tcount = i4
 )
 SET tspace_list->tcount = 0
 SET total_static_space = 0.0
 SELECT INTO "nl:"
  dst.tablespace_name, dst.static_size
  FROM dm_static_tablespaces dst,
   dm_env_functions def
  WHERE def.environment_id=environment_id
   AND dst.function_id=def.function_id
  ORDER BY dst.tablespace_name, dst.static_size
  DETAIL
   tspace_list->tcount = (tspace_list->tcount+ 1)
   IF (mod(tspace_list->tcount,10)=1)
    stat = alterlist(tspace_list->tname,(tspace_list->tcount+ 9))
   ENDIF
   tspace_list->tname[tspace_list->tcount].tspace_name = dst.tablespace_name, tspace_list->tname[
   tspace_list->tcount].raw_bytes = (dst.static_size * mbyte), tspace_list->tname[tspace_list->tcount
   ].partitioned_bytes = (((round((dst.static_size/ partition_size),0)+ 1) * partition_size) * mbyte),
   tspace_list->tname[tspace_list->tcount].static_ind = 1, total_static_space = (total_static_space+
   tspace_list->tname[tspace_list->tcount].partitioned_bytes)
  WITH nocounter
 ;end select
#tablespace_end
 SET used_size = 0.0
 SET used_size = (total_static_space/ mbyte)
 SELECT INTO "nl:"
  def.file_size
  FROM dm_env_files def
  WHERE def.environment_id=environment_id
   AND  NOT (def.file_type IN ("DATA", "INDEX"))
  DETAIL
   used_size = (used_size+ (def.file_size/ mbyte))
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  derl.log_size
  FROM dm_env_redo_logs derl
  WHERE derl.environment_id=environment_id
  DETAIL
   used_size = (used_size+ (derl.log_size/ mbyte))
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  decf.file_size
  FROM dm_env_control_files decf
  WHERE decf.environment_id=environment_id
  DETAIL
   used_size = (used_size+ (decf.file_size/ mbyte))
  WITH nocounter
 ;end select
 IF (mode=1)
  SET orig_size = 0.0
  SET orig_size = target_size
  SET target_size = (target_size - used_size)
  SET rem_size = target_size
  SET target_size = ((target_size * mbyte) - ((tab_sum+ ind_sum)+ old_ind_sum))
  SET a = 0
  SET tbytes_day = 0.0
  SET tstatic = 0.0
  FOR (a = 1 TO tab_list->count)
   IF ((tab_list->qual[a].bytes_per_day=0)
    AND (tab_list->qual[a].static_size=0))
    SET tbytes_day = (tbytes_day+ (2 * block_size))
   ELSE
    SET tbytes_day = (tbytes_day+ tab_list->qual[a].bytes_per_day)
   ENDIF
   SET tstatic = (tstatic+ tab_list->qual[a].static_size)
  ENDFOR
  SET b = 0
  FOR (b = 1 TO ind_list->count)
   IF ((ind_list->qual[b].bytes_per_day=0)
    AND (ind_list->qual[b].static_size=0))
    SET tbytes_day = (tbytes_day+ (2 * block_size))
   ELSE
    SET tbytes_day = (tbytes_day+ ind_list->qual[b].bytes_per_day)
   ENDIF
   SET tstatic = (tstatic+ ind_list->qual[b].static_size)
  ENDFOR
  EXECUTE dm_calculate_days
  IF (ndays < 90)
   DELETE  FROM dm_env_table det
    WHERE det.environment_id=environment_id
    WITH nocounter
   ;end delete
   COMMIT
   DELETE  FROM dm_env_index dei
    WHERE dei.environment_id=environment_id
    WITH nocounter
   ;end delete
   COMMIT
   DELETE  FROM dm_env_files def
    WHERE def.environment_id=environment_id
     AND def.file_type IN ("DATA", "INDEX")
    WITH nocounter
   ;end delete
   COMMIT
   UPDATE  FROM dm_environment d
    SET d.month_cnt = 0
    WHERE d.environment_id=environment_id
    WITH nocounter
   ;end update
   COMMIT
   GO TO end_prg
  ENDIF
 ELSEIF (mode=2)
  SET grow_size = 0.0
  SET grow_size = ((tab_sum+ ind_sum)+ old_ind_sum)
  SET j = 0
  SET temp_size = 0.0
  FOR (j = 1 TO tab_list->count)
    SET temp_size = (tab_list->qual[j].static_size+ (ndays * tab_list->qual[j].bytes_per_day))
    IF ((temp_size < (2 * block_size)))
     SET temp_size = (2 * block_size)
    ELSE
     SET temp_size = ((round((temp_size/ 8192),0)+ 1) * 8192)
    ENDIF
    SET grow_size = (grow_size+ temp_size)
  ENDFOR
  SET k = 0
  SET temp_size = 0.0
  FOR (k = 1 TO ind_list->count)
    SET temp_size = (ind_list->qual[k].static_size+ (ndays * ind_list->qual[k].bytes_per_day))
    IF ((temp_size < (2 * block_size)))
     SET temp_size = (2 * block_size)
    ELSE
     SET temp_size = ((round((temp_size/ 8192),0)+ 1) * 8192)
    ENDIF
    SET grow_size = (grow_size+ temp_size)
  ENDFOR
  SET grow_size = (grow_size/ mbyte)
  SET total_size = 0.0
  SET target_size = (1.1 * (grow_size+ used_size))
  SET total_size = ceil(target_size)
  SET rem_size = (total_size - used_size)
 ENDIF
 SET total_part = 0.0
 EXECUTE dm_table_sizing
 IF (mode=1)
  SET tempstr = fillstring(132," ")
  SET fname = "dm_calculate_sizing2.log"
  WHILE (total_part > rem_size)
    EXECUTE dm_calculate_days
    SET total_part = 0.0
    EXECUTE FROM tablespace_start TO tablespace_end
    EXECUTE dm_table_sizing
  ENDWHILE
  SET nmonth = 0
  SET nmonth = (ndays/ 30)
  UPDATE  FROM dm_environment d
   SET d.month_cnt = nmonth
   WHERE d.environment_id=environment_id
   WITH nocounter
  ;end update
  COMMIT
 ELSE
  IF (total_part > total_size)
   SET total_size = (1.05 * (total_part+ used_size))
   SET rem_size = (total_size - used_size)
  ENDIF
  CALL echo(build("Total Size required (MB):",total_size))
  UPDATE  FROM dm_environment d
   SET d.total_database_size = total_size
   WHERE d.environment_id=environment_id
   WITH nocounter
  ;end update
  COMMIT
 ENDIF
 DELETE  FROM dm_env_files def
  WHERE def.environment_id=environment_id
   AND def.file_type IN ("DATA", "INDEX")
  WITH nocounter
 ;end delete
 COMMIT
 RECORD file_sizes(
   1 scount = i4
   1 sizes[*]
     2 size = f8
     2 size_seq = f8
 )
 SET file_sizes->scount = 0
 SELECT INTO "nl:"
  derl.log_size
  FROM dm_env_redo_logs derl
  WHERE derl.environment_id=environment_id
  DETAIL
   size_found = 0
   FOR (i = 1 TO file_sizes->scount)
     IF ((derl.log_size=file_sizes->sizes[i].size))
      file_sizes->sizes[i].size_seq = (file_sizes->sizes[i].size_seq+ 1), size_found = 1
     ENDIF
   ENDFOR
   IF (size_found=0)
    file_sizes->scount = (file_sizes->scount+ 1)
    IF (mod(file_sizes->scount,10)=1)
     stat = alterlist(file_sizes->sizes,(file_sizes->scount+ 9))
    ENDIF
    file_sizes->sizes[file_sizes->scount].size = derl.log_size, file_sizes->sizes[file_sizes->scount]
    .size_seq = 1
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  decf.file_size
  FROM dm_env_control_files decf
  WHERE decf.environment_id=environment_id
  DETAIL
   size_found = 0
   FOR (i = 1 TO file_sizes->scount)
     IF ((decf.file_size=file_sizes->sizes[i].size))
      file_sizes->sizes[i].size_seq = (file_sizes->sizes[i].size_seq+ 1), size_found = 1
     ENDIF
   ENDFOR
   IF (size_found=0)
    file_sizes->scount = (file_sizes->scount+ 1)
    IF (mod(file_sizes->scount,10)=1)
     stat = alterlist(file_sizes->sizes,(file_sizes->scount+ 9))
    ENDIF
    file_sizes->sizes[file_sizes->scount].size = decf.file_size, file_sizes->sizes[file_sizes->scount
    ].size_seq = 1
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  def.file_size
  FROM dm_env_files def
  WHERE def.environment_id=environment_id
   AND  NOT (def.file_type IN ("DATA", "INDEX"))
  DETAIL
   size_found = 0
   FOR (i = 1 TO file_sizes->scount)
     IF ((def.file_size=file_sizes->sizes[i].size))
      file_sizes->sizes[i].size_seq = (file_sizes->sizes[i].size_seq+ 1), size_found = 1
     ENDIF
   ENDFOR
   IF (size_found=0)
    file_sizes->scount = (file_sizes->scount+ 1)
    IF (mod(file_sizes->scount,10)=1)
     stat = alterlist(file_sizes->sizes,(file_sizes->scount+ 9))
    ENDIF
    file_sizes->sizes[file_sizes->scount].size = def.file_size, file_sizes->sizes[file_sizes->scount]
    .size_seq = 1
   ENDIF
  WITH nocounter
 ;end select
 RECORD tspace_files(
   1 fcount = i4
   1 tname[*]
     2 size = f8
     2 raw_size = f8
     2 tspace_name = c32
     2 fname = c40
     2 size_seq = f8
 )
 SET tspace_files->fcount = 0
 FOR (kount = 1 TO tspace_list->tcount)
   SET row_count = 1
   SET total_size = tspace_list->tname[kount].partitioned_bytes
   WHILE (total_size > 0.0)
     SET tspace_files->fcount = (tspace_files->fcount+ 1)
     IF (mod(tspace_files->fcount,10)=1)
      SET stat = alterlist(tspace_files->tname,(tspace_files->fcount+ 9))
     ENDIF
     IF (total_size > max_size)
      SET raw_size = max_size
     ELSE
      SET raw_size = total_size
     ENDIF
     SET total_size = (total_size - raw_size)
     IF (system="AIX")
      SET tspace_files->tname[tspace_files->fcount].size = (raw_size - mbyte)
     ELSE
      SET tspace_files->tname[tspace_files->fcount].size = raw_size
     ENDIF
     SET tspace_files->tname[tspace_files->fcount].raw_size = raw_size
     SET tspace_files->tname[tspace_files->fcount].tspace_name = tspace_list->tname[kount].
     tspace_name
     SET size_found = 0
     FOR (i = 1 TO file_sizes->scount)
       IF (((system="AIX"
        AND ((raw_size - mbyte)=file_sizes->sizes[i].size)) OR (system != "AIX"
        AND (raw_size=file_sizes->sizes[i].size))) )
        SET file_sizes->sizes[i].size_seq = (file_sizes->sizes[i].size_seq+ 1)
        SET tspace_files->tname[tspace_files->fcount].size_seq = file_sizes->sizes[i].size_seq
        SET size_found = 1
       ENDIF
     ENDFOR
     IF (size_found=0)
      SET file_sizes->scount = (file_sizes->scount+ 1)
      IF (mod(file_sizes->scount,10)=1)
       SET stat = alterlist(file_sizes->sizes,(file_sizes->scount+ 9))
      ENDIF
      IF (system="AIX")
       SET file_sizes->sizes[file_sizes->scount].size = (raw_size - mbyte)
      ELSE
       SET file_sizes->sizes[file_sizes->scount].size = raw_size
      ENDIF
      SET file_sizes->sizes[file_sizes->scount].size_seq = 1
      SET tspace_files->tname[tspace_files->fcount].size_seq = 1
     ENDIF
     SET file_seq = format(cnvtstring(row_count),"###;P0")
     IF (system="AIX")
      SET fname = build(cnvtlower(database_name),"_",format(cnvtstring((raw_size/ (1024 * 1024))),
        "####;P0"),"_",format(cnvtstring(tspace_files->tname[tspace_files->fcount].size_seq),"###;P0"
        ))
     ELSE
      SET fname = build(tspace_list->tname[kount].tspace_name,"_",file_seq)
     ENDIF
     SET row_count = (row_count+ 1)
     SET tspace_files->tname[tspace_files->fcount].fname = fname
     INSERT  FROM dm_env_files def
      SET def.updt_applctx = 0, def.updt_dt_tm = cnvtdatetime(curdate,curtime3), def.updt_cnt = 0,
       def.updt_id = 0, def.updt_task = 0, def.file_type =
       IF (substring(1,1,tspace_files->tname[tspace_files->fcount].tspace_name)="I") "INDEX"
       ELSE "DATA"
       ENDIF
       ,
       def.file_size = tspace_files->tname[tspace_files->fcount].size, def.size_sequence =
       tspace_files->tname[tspace_files->fcount].size_seq, def.environment_id = environment_id,
       def.tablespace_name = tspace_files->tname[tspace_files->fcount].tspace_name, def.file_name =
       tspace_files->tname[tspace_files->fcount].fname
      WITH nocounter
     ;end insert
   ENDWHILE
 ENDFOR
 COMMIT
#end_prg
END GO
