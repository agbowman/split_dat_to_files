CREATE PROGRAM dm_table_sizing:dba
 SET nquarter = ceil((ndays/ 90))
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
 SET init_val = 0.0
 SET init_val = (2 * block_size)
 SET x = 0
 FOR (x = 1 TO table_list->table_count)
  IF ((table_list->list[x].new_ind=0))
   SET table_list->list[x].total = (table_list->list[x].static_size+ (ndays * table_list->list[x].
   bytes_per_day))
  ELSE
   SET table_list->list[x].total = (2 * block_size)
  ENDIF
  IF ((table_list->list[x].total <= (2 * block_size)))
   SET table_list->list[x].init = init_val
   SET table_list->list[x].next = block_size
   SET table_list->list[x].total = (2 * block_size)
  ELSEIF (((2 * block_size) < table_list->list[x].total)
   AND nquarter <= 2)
   SET table_list->list[x].init = (table_list->list[x].total/ 2)
   SET table_list->list[x].next = table_list->list[x].init
   IF ((table_list->list[x].init < init_val))
    SET table_list->list[x].init = init_val
   ENDIF
   IF ((table_list->list[x].next < block_size))
    SET table_list->list[x].next = block_size
   ENDIF
  ELSE
   SET table_list->list[x].init = (table_list->list[x].total/ nquarter)
   SET table_list->list[x].next = ((table_list->list[x].total - table_list->list[x].init)/ (nquarter
    - 1))
   IF ((table_list->list[x].init < init_val))
    SET table_list->list[x].init = init_val
   ENDIF
   IF ((table_list->list[x].next < block_size))
    SET table_list->list[x].next = block_size
   ENDIF
  ENDIF
 ENDFOR
 INSERT  FROM dm_env_table dev,
   (dummyt d  WITH seq = value(table_list->table_count))
  SET dev.environment_id = environment_id, dev.table_name = table_list->list[d.seq].tname, dev
   .initial_extent = table_list->list[d.seq].init,
   dev.next_extent = table_list->list[d.seq].next, dev.updt_applctx = 0, dev.updt_dt_tm =
   cnvtdatetime(curdate,curtime3),
   dev.updt_cnt = 0, dev.updt_id = 0, dev.updt_task = 0
  PLAN (d)
   JOIN (dev)
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET tempstr = fillstring(132," ")
  SET fname = "dm_calculate_sizing2.log"
  SELECT INTO value(fname)
   *
   FROM dual
   DETAIL
    tempstr = "Failed to insert sizing data for the tables", tempstr, row + 1
   WITH nocounter, maxcol = 512, formfeed = none,
    maxrow = 1
  ;end select
 ENDIF
 COMMIT
 SET x = 0
 SET y = 0
 FOR (x = 1 TO table_list->table_count)
   FOR (y = 1 TO table_list->list[x].index_count)
    IF ((table_list->list[x].index_name[y].new_ind_old_tab=0)
     AND (table_list->list[x].index_name[y].new_ind_new_tab=0))
     SET table_list->list[x].index_name[y].total = (table_list->list[x].index_name[y].static_size+ (
     ndays * table_list->list[x].index_name[y].bytes_per_day))
    ELSEIF ((table_list->list[x].index_name[y].new_ind_old_tab=1))
     SET table_list->list[x].index_name[y].total = table_list->list[x].index_name[y].tsize
    ELSE
     SET table_list->list[x].index_name[y].total = (2 * block_size)
    ENDIF
    IF ((table_list->list[x].index_name[y].total <= (2 * block_size)))
     SET table_list->list[x].index_name[y].init = init_val
     SET table_list->list[x].index_name[y].next = block_size
     SET table_list->list[x].index_name[y].total = (2 * block_size)
    ELSEIF (((2 * block_size) < table_list->list[x].index_name[y].total)
     AND nquarter <= 2)
     SET table_list->list[x].index_name[y].init = (table_list->list[x].index_name[y].total/ 2)
     SET table_list->list[x].index_name[y].next = table_list->list[x].index_name[y].init
     IF ((table_list->list[x].index_name[y].init < init_val))
      SET table_list->list[x].index_name[y].init = init_val
     ENDIF
     IF ((table_list->list[x].index_name[y].next < block_size))
      SET table_list->list[x].index_name[y].next = block_size
     ENDIF
    ELSE
     SET table_list->list[x].index_name[y].init = (table_list->list[x].index_name[y].total/ nquarter)
     SET table_list->list[x].index_name[y].next = ((table_list->list[x].index_name[y].total -
     table_list->list[x].index_name[y].init)/ (nquarter - 1))
     IF ((table_list->list[x].index_name[y].init < init_val))
      SET table_list->list[x].index_name[y].init = init_val
     ENDIF
     IF ((table_list->list[x].index_name[y].next < block_size))
      SET table_list->list[x].index_name[y].next = block_size
     ENDIF
    ENDIF
   ENDFOR
 ENDFOR
 INSERT  FROM dm_env_index dei,
   (dummyt d  WITH seq = value(table_list->table_count)),
   (dummyt d2  WITH seq = value(30))
  SET dei.environment_id = environment_id, dei.index_name = table_list->list[d.seq].index_name[d2.seq
   ].iname, dei.initial_extent = table_list->list[d.seq].index_name[d2.seq].init,
   dei.next_extent = table_list->list[d.seq].index_name[d2.seq].next, dei.updt_applctx = 0, dei
   .updt_dt_tm = cnvtdatetime(curdate,curtime3),
   dei.updt_cnt = 0, dei.updt_id = 0, dei.updt_task = 0
  PLAN (d)
   JOIN (d2
   WHERE (d2.seq <= table_list->list[d.seq].index_count))
   JOIN (dei)
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET tempstr = fillstring(132," ")
  SET fname = "dm_calculate_sizing2.log"
  SELECT INTO value(fname)
   *
   FROM dual
   DETAIL
    tempstr = "Failed to insert sizing data for the indexes.", tempstr, row + 1
   WITH nocounter, maxcol = 512, formfeed = none,
    maxrow = 1
  ;end select
 ENDIF
 COMMIT
 SET total_space = 0.0
 SET temp_sum = 0.0
 SELECT INTO "nl:"
  dt.tablespace_name, dt.table_name
  FROM (dummyt d  WITH seq = value(table_list->table_count)),
   dm_tables dt,
   dm_env_table det
  PLAN (d)
   JOIN (dt
   WHERE dt.schema_date=cnvtdatetime(schema_date)
    AND (dt.table_name=table_list->list[d.seq].tname))
   JOIN (det
   WHERE det.environment_id=environment_id
    AND det.table_name=dt.table_name)
  ORDER BY dt.tablespace_name
  HEAD dt.tablespace_name
   temp_sum = 0.0
  DETAIL
   IF ((table_list->list[d.seq].new_ind=1))
    temp_sum = (temp_sum+ (2 * block_size))
   ELSE
    temp_sum = (temp_sum+ (1.05 * table_list->list[d.seq].total))
   ENDIF
  FOOT  dt.tablespace_name
   found = 0, i = 0
   FOR (i = 1 TO tspace_list->tcount)
     IF ((dt.tablespace_name=tspace_list->tname[i].tspace_name))
      tspace_list->tname[i].raw_bytes = (tspace_list->tname[i].raw_bytes+ temp_sum), tspace_list->
      tname[i].partitioned_bytes = (tspace_list->tname[i].partitioned_bytes+ (((round((temp_sum/ (
       partition_size * mbyte)),0)+ 1) * partition_size) * mbyte)), tspace_list->tname[i].static_ind
       = 0,
      total_space = (total_space+ temp_sum), total_part = (total_part+ tspace_list->tname[i].
      partitioned_bytes), found = 1
     ENDIF
   ENDFOR
   IF (found=0)
    tspace_list->tcount = (tspace_list->tcount+ 1)
    IF (mod(tspace_list->tcount,10)=1)
     stat = alterlist(tspace_list->tname,(tspace_list->tcount+ 9))
    ENDIF
    tspace_list->tname[tspace_list->tcount].tspace_name = dt.tablespace_name, tspace_list->tname[
    tspace_list->tcount].raw_bytes = temp_sum, tspace_list->tname[tspace_list->tcount].
    partitioned_bytes = (((round((temp_sum/ (partition_size * mbyte)),0)+ 1) * partition_size) *
    mbyte),
    tspace_list->tname[tspace_list->tcount].static_ind = 0, total_space = (total_space+ temp_sum),
    total_part = (total_part+ tspace_list->tname[tspace_list->tcount].partitioned_bytes)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  di.tablespace_name, di.index_name
  FROM (dummyt d  WITH seq = value(table_list->table_count)),
   (dummyt d2  WITH seq = value(30)),
   dm_indexes di,
   dm_env_index dei
  PLAN (d)
   JOIN (d2
   WHERE (d2.seq <= table_list->list[d.seq].index_count))
   JOIN (di
   WHERE di.schema_date=cnvtdatetime(schema_date)
    AND (di.table_name=table_list->list[d.seq].tname))
   JOIN (dei
   WHERE dei.environment_id=environment_id
    AND (dei.index_name=table_list->list[d.seq].index_name[d2.seq].iname)
    AND dei.index_name=di.index_name)
  ORDER BY di.tablespace_name
  HEAD di.tablespace_name
   temp_sum = 0.0
  DETAIL
   IF ((table_list->list[d.seq].index_name[d2.seq].new_ind_new_tab=1))
    temp_sum = (temp_sum+ (2 * block_size))
   ELSE
    temp_sum = (temp_sum+ (1.05 * table_list->list[d.seq].index_name[d2.seq].total))
   ENDIF
  FOOT  di.tablespace_name
   found = 0
   FOR (i = 1 TO tspace_list->tcount)
     IF ((di.tablespace_name=tspace_list->tname[i].tspace_name))
      tspace_list->tname[i].raw_bytes = (tspace_list->tname[i].raw_bytes+ temp_sum), tspace_list->
      tname[i].partitioned_bytes = (tspace_list->tname[i].partitioned_bytes+ (((round((temp_sum/ (
       partition_size * mbyte)),0)+ 1) * partition_size) * mbyte)), tspace_list->tname[i].static_ind
       = 0,
      total_space = (total_space+ temp_sum), total_part = (total_part+ tspace_list->tname[i].
      partitioned_bytes), found = 1
     ENDIF
   ENDFOR
   IF (found=0)
    tspace_list->tcount = (tspace_list->tcount+ 1), stat = alterlist(tspace_list->tname,tspace_list->
     tcount), tspace_list->tname[tspace_list->tcount].tspace_name = di.tablespace_name,
    tspace_list->tname[tspace_list->tcount].raw_bytes = temp_sum, tspace_list->tname[tspace_list->
    tcount].partitioned_bytes = (((round((temp_sum/ (partition_size * mbyte)),0)+ 1) * partition_size
    ) * mbyte), tspace_list->tname[tspace_list->tcount].static_ind = 0,
    total_space = (total_space+ temp_sum), total_part = (total_part+ tspace_list->tname[tspace_list->
    tcount].partitioned_bytes)
   ENDIF
  WITH nocounter
 ;end select
 SET total_part = (total_part/ mbyte)
END GO
