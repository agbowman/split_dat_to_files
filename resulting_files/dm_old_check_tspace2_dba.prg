CREATE PROGRAM dm_old_check_tspace2:dba
 SET dm_env_name = cnvtupper( $1)
 SET system = cnvtupper(cursys)
 SET dm_schema_date = cnvtdatetime("31-DEC-1900")
 SET valid_schema_date_ind = 0
 SET valid_env_ind = 0
 SET envid = 0
 SELECT INTO "nl:"
  e.environment_name, e.environment_id
  FROM dm_environment e
  WHERE e.environment_name=dm_env_name
  DETAIL
   envid = e.environment_id, valid_env_ind = 1
  WITH nocounter
 ;end select
 IF (valid_env_ind=0)
  SELECT
   *
   FROM dual
   DETAIL
    col 0, "*******************************************", row + 1,
    col 0, "***        INVALID ENVIRONMENT          ***", row + 1,
    col 0, "***        TERMINATING PROGRAM          ***", row + 1,
    col 0, "*******************************************", row + 1
   WITH nocounter
  ;end select
  GO TO end_program
 ENDIF
 SELECT DISTINCT INTO "nl:"
  t.schema_date
  FROM dm_tables t
  WHERE t.schema_date=cnvtdatetime( $2)
  DETAIL
   dm_schema_date = cnvtdatetime( $2), valid_schema_date_ind = 1
  WITH nocounter
 ;end select
 IF (valid_env_ind=1)
  IF (valid_schema_date_ind=0)
   SELECT INTO "nl:"
    sv.schema_date
    FROM dm_schema_version sv,
     dm_environment e
    WHERE e.environment_name=dm_env_name
     AND sv.schema_version=e.schema_version
    DETAIL
     dm_schema_date = sv.schema_date
    WITH nocounter
   ;end select
   IF (curqual=0)
    SELECT
     *
     FROM dual
     DETAIL
      col 0, "*******************************************", row + 1,
      col 0, "***  ENVIRONMENT IS VALID, BUT SCHEMA   ***", row + 1,
      col 0, "***  DATE FOR THE ENVIRONMENT AND THE   ***", row + 1,
      col 0, "***  PASSED IN $2 PARAMETER IS INVALID  ***", row + 1,
      col 0, "***        TERMINATING PROGRAM          ***", row + 1,
      col 0, "*******************************************", row + 1
     WITH nocounter
    ;end select
    GO TO end_program
   ENDIF
  ENDIF
 ENDIF
 FREE SET fslist
 RECORD fslist(
   1 qual[*]
     2 table_name = vc
     2 new_table_ind = i2
     2 table_size = f8
     2 tablespace_name = vc
     2 new_tbspace_ind = i2
     2 schema_ind = i2
     2 index_count = i4
     2 index_name[*]
       3 iname = vc
       3 ind_tbspace_name = vc
       3 new_itspace_ind = i2
       3 size = f8
       3 new_index_ind = i2
   1 count = i4
 )
 SET fslist->count = 0
 SET stat = alterlist(fslist->qual,10)
 SELECT INTO "nl:"
  FROM (dummyt t  WITH seq = value(tgtdb->tbl_cnt))
  WHERE (((tgtdb->tbl[t.seq].new_ind=1)) OR ((tgtdb->tbl[t.seq].diff_ind=1)))
  DETAIL
   fslist->count = (fslist->count+ 1), stat = alterlist(fslist->qual,fslist->count), fslist->qual[
   fslist->count].table_name = tgtdb->tbl[t.seq].tbl_name,
   fslist->qual[fslist->count].tablespace_name = tgtdb->tbl[t.seq].tspace_name, fslist->qual[fslist->
   count].new_table_ind = 1, fslist->qual[fslist->count].new_tbspace_ind = 1,
   fslist->qual[fslist->count].schema_ind = 1
  WITH nocounter
 ;end select
 IF ((fslist->count=0))
  GO TO end_program
 ENDIF
 SELECT INTO "nl:"
  a.index_name
  FROM dm_indexes a,
   (dummyt d  WITH seq = value(fslist->count))
  PLAN (d)
   JOIN (a
   WHERE (a.table_name=fslist->qual[d.seq].table_name)
    AND a.schema_date=cnvtdatetime(dm_schema_date))
  HEAD a.table_name
   knt = 0
  DETAIL
   knt = (knt+ 1), stat = alterlist(fslist->qual[d.seq].index_name,knt), fslist->qual[d.seq].
   index_name[knt].iname = a.index_name,
   fslist->qual[d.seq].index_name[knt].new_index_ind = 1
  FOOT  a.table_name
   fslist->qual[d.seq].index_count = knt
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  a.table_name
  FROM user_tables a,
   (dummyt d  WITH seq = value(fslist->count))
  PLAN (d)
   JOIN (a
   WHERE (a.table_name=fslist->qual[d.seq].table_name)
    AND a.tablespace_name="D_*")
  DETAIL
   fslist->qual[d.seq].new_table_ind = 0
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  a.index_name
  FROM user_indexes a,
   (dummyt d  WITH seq = value(fslist->count)),
   (dummyt d2  WITH seq = value(30))
  PLAN (d)
   JOIN (d2
   WHERE (d2.seq <= fslist->qual[d.seq].index_count))
   JOIN (a
   WHERE (a.table_name=fslist->qual[d.seq].table_name)
    AND (a.index_name=fslist->qual[d.seq].index_name[d2.seq].iname)
    AND a.tablespace_name="I_*")
  DETAIL
   fslist->qual[d.seq].index_name[d2.seq].new_index_ind = 0
  WITH nocounter
 ;end select
 FREE SET tblist
 RECORD tblist(
   1 qual[*]
     2 tbname = vc
 )
 SET tbcount = 0
 SET stat = alterlist(tblist->qual,10)
 FREE SET itblist
 RECORD itblist(
   1 qual[*]
     2 itbname = vc
 )
 SET itbcount = 0
 SET stat = alterlist(itblist->qual,10)
 SELECT DISTINCT INTO "nl:"
  a.tablespace_name
  FROM user_tablespaces a
  WHERE a.status != "INVALID"
  ORDER BY a.tablespace_name
  DETAIL
   IF (substring(1,2,a.tablespace_name)="D_")
    tbcount = (tbcount+ 1), stat = alterlist(tblist->qual,tbcount), tblist->qual[tbcount].tbname = a
    .tablespace_name
   ELSEIF (substring(1,2,a.tablespace_name)="I_")
    itbcount = (itbcount+ 1), stat = alterlist(itblist->qual,itbcount), itblist->qual[itbcount].
    itbname = a.tablespace_name
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  a.tablespace_name
  FROM dm_tables a,
   (dummyt d  WITH seq = value(fslist->count))
  PLAN (d)
   JOIN (a
   WHERE (a.table_name=fslist->qual[d.seq].table_name)
    AND a.schema_date=cnvtdatetime(dm_schema_date))
  DETAIL
   tspace_exists = 0
   FOR (z = 1 TO tbcount)
     IF (trim(a.tablespace_name)=trim(tblist->qual[z].tbname))
      tspace_exists = 1, fslist->qual[d.seq].new_tbspace_ind = 0
     ENDIF
   ENDFOR
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  a.index_name, a.tablespace_name
  FROM dm_indexes a,
   (dummyt d  WITH seq = value(fslist->count)),
   (dummyt d2  WITH seq = value(30))
  PLAN (d)
   JOIN (d2
   WHERE (d2.seq <= fslist->qual[d.seq].index_count))
   JOIN (a
   WHERE (a.table_name=fslist->qual[d.seq].table_name)
    AND a.schema_date=cnvtdatetime(dm_schema_date)
    AND (a.index_name=fslist->qual[d.seq].index_name[d2.seq].iname))
  DETAIL
   itspace_exists = 0
   FOR (z = 1 TO itbcount)
     IF (trim(a.tablespace_name)=trim(itblist->qual[z].itbname))
      itspace_exists = 1, fslist->qual[d.seq].index_name[d2.seq].new_itspace_ind = 0, fslist->qual[d
      .seq].index_name[d2.seq].ind_tbspace_name = a.tablespace_name
     ENDIF
   ENDFOR
   IF (itspace_exists=0)
    fslist->qual[d.seq].index_name[d2.seq].ind_tbspace_name = a.tablespace_name, fslist->qual[d.seq].
    index_name[d2.seq].new_itspace_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SET block_size = 0.0
 SELECT INTO "nl:"
  d.value
  FROM v$parameter d
  WHERE d.name="db_block_size"
  DETAIL
   block_size = cnvtint(d.value)
  WITH nocounter
 ;end select
 SET mbyte = (1024.0 * 1024.0)
 SET max_size = 0.0
 SET partition_size = 0.0
 SET database_name = fillstring(10," ")
 SELECT INTO "nl:"
  de.max_file_size, de.data_file_partition_size, de.database_name
  FROM dm_environment de
  WHERE de.environment_id=envid
  DETAIL
   max_size = (de.max_file_size * mbyte), partition_size = de.data_file_partition_size, database_name
    = de.database_name
  WITH nocounter
 ;end select
 FREE SET newlist
 RECORD newlist(
   1 qual[*]
     2 new_tb_name = vc
     2 total_size = f8
     2 partitioned_bytes = f8
     2 file_count = i4
   1 count = i4
 )
 SET newlist->count = 0
 SET stat = alterlist(newlist->qual,10)
 FREE SET existlist
 RECORD existlist(
   1 qual[*]
     2 tb_name = vc
     2 total_size = f8
     2 partitioned_bytes = f8
     2 calc_size = f8
     2 free_space = f8
     2 file_count = i4
   1 count = i4
 )
 SET existlist->count = 0
 SET stat = alterlist(existlist->qual,10)
 SELECT INTO "nl:"
  d.seq
  FROM (dummyt d  WITH seq = value(fslist->count))
  ORDER BY d.seq
  DETAIL
   IF ((fslist->qual[d.seq].new_tbspace_ind=1))
    tbspace_exists = 0
    FOR (x = 1 TO newlist->count)
      IF ((fslist->qual[d.seq].tablespace_name=newlist->qual[x].new_tb_name))
       tbspace_exists = 1
      ENDIF
    ENDFOR
    IF (tbspace_exists=0)
     newlist->count = (newlist->count+ 1), stat = alterlist(newlist->qual,newlist->count), newlist->
     qual[newlist->count].new_tb_name = fslist->qual[d.seq].tablespace_name
    ENDIF
   ELSE
    tbspace_exists = 0
    FOR (x = 1 TO existlist->count)
      IF ((fslist->qual[d.seq].tablespace_name=existlist->qual[x].tb_name))
       tbspace_exists = 1
      ENDIF
    ENDFOR
    IF (tbspace_exists=0)
     existlist->count = (existlist->count+ 1), stat = alterlist(existlist->qual,existlist->count),
     existlist->qual[existlist->count].tb_name = fslist->qual[d.seq].tablespace_name
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SET cnt1 = newlist->count
 SET ecnt1 = existlist->count
 SELECT INTO "nl:"
  d.seq
  FROM (dummyt d  WITH seq = value(fslist->count)),
   (dummyt d2  WITH seq = value(30))
  PLAN (d)
   JOIN (d2
   WHERE (d2.seq <= fslist->qual[d.seq].index_count))
  DETAIL
   IF ((fslist->qual[d.seq].index_name[d2.seq].new_itspace_ind=1))
    tbspace_exists = 0
    FOR (x = 1 TO newlist->count)
      IF ((fslist->qual[d.seq].index_name[d2.seq].ind_tbspace_name=newlist->qual[x].new_tb_name))
       tbspace_exists = 1
      ENDIF
    ENDFOR
    IF (tbspace_exists=0)
     newlist->count = (newlist->count+ 1), stat = alterlist(newlist->qual,newlist->count), newlist->
     qual[newlist->count].new_tb_name = fslist->qual[d.seq].index_name[d2.seq].ind_tbspace_name
    ENDIF
   ELSE
    tbspace_exists = 0
    FOR (x = 1 TO existlist->count)
      IF ((fslist->qual[d.seq].index_name[d2.seq].ind_tbspace_name=existlist->qual[x].tb_name))
       tbspace_exists = 1
      ENDIF
    ENDFOR
    IF (tbspace_exists=0)
     existlist->count = (existlist->count+ 1), stat = alterlist(existlist->qual,existlist->count),
     existlist->qual[existlist->count].tb_name = fslist->qual[d.seq].index_name[d2.seq].
     ind_tbspace_name
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SET cnt2 = newlist->count
 SET ecnt2 = existlist->count
 SET rseq = 0
 SET rdate = 0
 SELECT INTO "nl:"
  a.report_seq, a.begin_date
  FROM ref_report_log a,
   ref_report_parms_log b,
   ref_instance_id c
  WHERE a.report_seq=b.report_seq
   AND b.parm_cd=1
   AND b.parm_value=cnvtstring(c.instance_cd)
   AND c.environment_id=envid
  ORDER BY a.begin_date
  DETAIL
   IF (a.begin_date > rdate)
    rdate = a.begin_date, rseq = a.report_seq
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  dc.data_length, so.row_count
  FROM (dummyt d  WITH seq = value(fslist->count)),
   (dummyt d2  WITH seq = 30),
   dm_index_columns dic,
   dm_indexes di,
   dm_columns dc,
   space_objects so,
   dummyt d3,
   ref_instance_id rd
  PLAN (d
   WHERE (fslist->qual[d.seq].new_table_ind=0))
   JOIN (d2
   WHERE (d2.seq <= fslist->qual[d.seq].index_count)
    AND (fslist->qual[d.seq].index_name[d2.seq].new_index_ind=1))
   JOIN (di
   WHERE (di.index_name=fslist->qual[d.seq].index_name[d2.seq].iname)
    AND di.schema_date=cnvtdatetime(dm_schema_date))
   JOIN (dic
   WHERE di.index_name=dic.index_name
    AND di.schema_date=dic.schema_date)
   JOIN (dc
   WHERE dc.table_name=di.table_name
    AND dic.column_name=dc.column_name
    AND dic.schema_date=dc.schema_date)
   JOIN (d3)
   JOIN (so
   WHERE so.segment_name=di.table_name
    AND so.report_seq=rseq)
   JOIN (rd
   WHERE so.instance_cd=rd.instance_cd
    AND rd.environment_id=envid)
  ORDER BY di.index_name, dic.column_position
  HEAD di.index_name
   col_sum = 0.0, ind_tot = 0.0
  DETAIL
   col_sum = (col_sum+ dc.data_length)
  FOOT  di.index_name
   ind_tot = (col_sum * so.row_count)
   IF ((ind_tot < (3 * block_size)))
    fslist->qual[d.seq].index_name[d2.seq].size = (3 * block_size)
   ELSE
    fslist->qual[d.seq].index_name[d2.seq].size = ind_tot
   ENDIF
  WITH nocounter, outerjoin = d3
 ;end select
 SELECT INTO "nl:"
  dc.data_length, so.row_count, so.total_space,
  so.free_space
  FROM (dummyt d  WITH seq = value(fslist->count)),
   dm_tables dt,
   dm_columns dc,
   space_objects so,
   dummyt d3,
   ref_instance_id rd,
   user_tab_columns a
  PLAN (d
   WHERE (fslist->qual[d.seq].new_table_ind=0))
   JOIN (dt
   WHERE (dt.table_name=fslist->qual[d.seq].table_name)
    AND dt.schema_date=cnvtdatetime(dm_schema_date))
   JOIN (dc
   WHERE dc.table_name=dt.table_name
    AND dc.schema_date=dt.schema_date
    AND dc.nullable="N")
   JOIN (d3)
   JOIN (a
   WHERE a.table_name=dc.table_name
    AND a.column_name=dc.column_name
    AND a.nullable="Y")
   JOIN (so
   WHERE so.segment_name=dt.table_name
    AND so.report_seq=rseq)
   JOIN (rd
   WHERE so.instance_cd=rd.instance_cd
    AND rd.environment_id=envid)
  HEAD dt.table_name
   col_sum = 0.0, col_tot = 0.0, used_space = 0.0
  DETAIL
   col_sum = (col_sum+ dc.data_length)
  FOOT  dt.table_name
   col_tot = (col_sum * so.row_count), used_space = ((so.total_space - so.free_space) * block_size),
   fslist->qual[d.seq].table_size = (col_tot+ used_space)
  WITH nocounter, outerjoin = d3
 ;end select
 FOR (x = 1 TO cnt1)
   SET obj_in_tspace = 0
   SET tab_size = 0.0
   SELECT INTO "nl:"
    d.seq
    FROM (dummyt d  WITH seq = value(fslist->count))
    PLAN (d
     WHERE (fslist->qual[d.seq].tablespace_name=newlist->qual[x].new_tb_name))
    DETAIL
     IF ((fslist->qual[d.seq].schema_ind=1))
      IF ((fslist->qual[d.seq].new_table_ind=1))
       obj_in_tspace = (obj_in_tspace+ 1)
      ELSE
       IF ((fslist->qual[d.seq].table_size < (2 * block_size)))
        fslist->qual[d.seq].table_size = (2 * block_size)
       ENDIF
       tab_size = (tab_size+ fslist->qual[d.seq].table_size)
      ENDIF
     ELSEIF ((fslist->qual[d.seq].schema_ind=2))
      IF ((fslist->qual[d.seq].new_table_ind=1))
       obj_in_tspace = (obj_in_tspace+ 2)
      ELSE
       IF ((fslist->qual[d.seq].table_size < (2 * block_size)))
        fslist->qual[d.seq].table_size = (2 * block_size)
       ENDIF
       tab_size = (tab_size+ (2 * fslist->qual[d.seq].table_size))
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   SET newlist->qual[x].partitioned_bytes = 0.0
   SET temp_sum = 0.0
   SET temp_sum = (tab_size+ ((obj_in_tspace * 2) * block_size))
   SET newlist->qual[x].partitioned_bytes = (((round((temp_sum/ (partition_size * mbyte)),0)+ 1) *
   partition_size) * mbyte)
 ENDFOR
 SET str_cnt = (cnt1+ 1)
 FOR (y = str_cnt TO cnt2)
   SET obj_in_tspace = 0
   SET ind_size = 0.0
   SELECT INTO "nl:"
    d.seq
    FROM (dummyt d  WITH seq = value(fslist->count)),
     (dummyt d2  WITH seq = value(30))
    PLAN (d)
     JOIN (d2
     WHERE (d2.seq <= fslist->qual[d.seq].index_count)
      AND (fslist->qual[d.seq].index_name[d2.seq].ind_tbspace_name=newlist->qual[y].new_tb_name))
    DETAIL
     IF ((fslist->qual[d.seq].new_table_ind=1))
      obj_in_tspace = (obj_in_tspace+ 1)
     ELSE
      IF ((fslist->qual[d.seq].index_name[d2.seq].size < (2 * block_size)))
       fslist->qual[d.seq].index_name[d2.seq].size = (2 * block_size)
      ENDIF
      ind_size = (ind_size+ fslist->qual[d.seq].index_name[d2.seq].size)
     ENDIF
    WITH nocounter
   ;end select
   SET newlist->qual[y].partitioned_bytes = 0.0
   SET temp_sum = 0.0
   SET temp_sum = (ind_size+ ((obj_in_tspace * 2) * block_size))
   SET newlist->qual[y].partitioned_bytes = (((round((temp_sum/ (partition_size * mbyte)),0)+ 1) *
   partition_size) * mbyte)
 ENDFOR
 FOR (x = 1 TO ecnt1)
   SET obj_in_tspace = 0
   SET tab_size = 0.0
   SELECT INTO "nl:"
    d.seq
    FROM (dummyt d2  WITH seq = value(fslist->count))
    PLAN (d2
     WHERE (fslist->qual[d2.seq].tablespace_name=existlist->qual[x].tb_name))
    DETAIL
     IF ((fslist->qual[d2.seq].schema_ind=1))
      IF ((fslist->qual[d2.seq].new_table_ind=1))
       obj_in_tspace = (obj_in_tspace+ 1)
      ELSE
       IF ((fslist->qual[d2.seq].table_size < (2 * block_size)))
        fslist->qual[d2.seq].table_size = (2 * block_size)
       ENDIF
       tab_size = (tab_size+ fslist->qual[d2.seq].table_size)
      ENDIF
     ELSEIF ((fslist->qual[d2.seq].schema_ind=2))
      IF ((fslist->qual[d2.seq].new_table_ind=1))
       obj_in_tspace = (obj_in_tspace+ 2)
      ELSE
       IF ((fslist->qual[d2.seq].table_size < (2 * block_size)))
        fslist->qual[d2.seq].table_size = (2 * block_size)
       ENDIF
       tab_size = (tab_size+ (fslist->qual[d2.seq].table_size * 2))
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   SET existlist->qual[x].calc_size = 0.0
   SET temp_sum = 0.0
   SET temp_sum = (tab_size+ ((obj_in_tspace * 2) * block_size))
   SET existlist->qual[x].calc_size = temp_sum
   SELECT INTO "nl:"
    a.minimum_size
    FROM dm_min_tspace_size a,
     dm_env_functions b
    WHERE (a.tablespace_name=existlist->qual[x].tb_name)
     AND a.function_id=b.function_id
     AND b.environment_id=envid
    DETAIL
     IF ((existlist->qual[x].calc_size < a.minimum_size))
      existlist->qual[x].calc_size = a.minimum_size
     ENDIF
    WITH nocounter
   ;end select
 ENDFOR
 SET ex_cnt = (ecnt1+ 1)
 FOR (y = ex_cnt TO ecnt2)
   SET obj_in_tspace = 0
   SET ind_size = 0.0
   SELECT INTO "nl:"
    d.seq
    FROM (dummyt d  WITH seq = value(fslist->count)),
     (dummyt d2  WITH seq = value(30))
    PLAN (d)
     JOIN (d2
     WHERE (d2.seq <= fslist->qual[d.seq].index_count)
      AND (fslist->qual[d.seq].index_name[d2.seq].ind_tbspace_name=existlist->qual[y].tb_name)
      AND (fslist->qual[d.seq].index_name[d2.seq].new_index_ind=1))
    DETAIL
     IF ((fslist->qual[d.seq].new_table_ind=1))
      obj_in_tspace = (obj_in_tspace+ 1)
     ELSE
      IF ((fslist->qual[d.seq].index_name[d2.seq].size < (3 * block_size)))
       fslist->qual[d.seq].index_name[d2.seq].size = (3 * block_size)
      ENDIF
      ind_size = (ind_size+ fslist->qual[d.seq].index_name[d2.seq].size)
     ENDIF
    WITH nocounter
   ;end select
   SET existlist->qual[y].calc_size = 0.0
   SET temp_sum = 0.0
   SET temp_sum = (ind_size+ ((obj_in_tspace * 3) * block_size))
   SET existlist->qual[y].calc_size = temp_sum
   SELECT INTO "nl:"
    a.minimum_size
    FROM dm_min_tspace_size a,
     dm_env_functions b
    WHERE (a.tablespace_name=existlist->qual[y].tb_name)
     AND a.function_id=b.function_id
     AND b.environment_id=envid
    DETAIL
     IF ((existlist->qual[y].calc_size < a.minimum_size))
      existlist->qual[y].calc_size = a.minimum_size
     ENDIF
    WITH nocounter
   ;end select
 ENDFOR
 SELECT INTO "nl:"
  s.bytes
  FROM dba_free_space s,
   (dummyt d  WITH seq = value(ecnt2)),
   dba_tablespaces c
  PLAN (d)
   JOIN (s
   WHERE (s.tablespace_name=existlist->qual[d.seq].tb_name))
   JOIN (c
   WHERE s.tablespace_name=c.tablespace_name
    AND s.bytes > c.initial_extent)
  HEAD d.seq
   free_space = 0.0
  DETAIL
   free_space = (free_space+ s.bytes)
  FOOT  d.seq
   existlist->qual[d.seq].free_space = free_space
  WITH nocounter
 ;end select
 DELETE  FROM dm_env_files d
  WHERE d.environment_id=envid
   AND d.file_type IN ("DATA", "INDEX")
  WITH nocounter
 ;end delete
 COMMIT
 IF (system != "AIX")
  FOR (c = 1 TO cnt2)
    SET newlist->qual[c].file_count = 0
    SET file_count = 0
    SET raw_size = 0.0
    SET total_size = newlist->qual[c].partitioned_bytes
    WHILE (total_size > 0)
      SET file_count = (file_count+ 1)
      IF (total_size > max_size)
       SET raw_size = max_size
      ELSE
       SET raw_size = total_size
      ENDIF
      SET total_size = (total_size - raw_size)
      SET newlist->qual[c].total_size = raw_size
      SET newlist->qual[c].file_count = file_count
      SET fname = fillstring(40," ")
      SET fname = build(newlist->qual[c].new_tb_name,"_",format(cnvtstring(newlist->qual[c].
         file_count),"###;P0"))
      INSERT  FROM dm_env_files def
       SET def.updt_applctx = 0, def.updt_dt_tm = cnvtdatetime(curdate,curtime3), def.updt_cnt = 0,
        def.updt_id = 0, def.updt_task = 0, def.file_type =
        IF (substring(1,1,newlist->qual[c].new_tb_name)="I") "INDEX"
        ELSE "DATA"
        ENDIF
        ,
        def.file_size = newlist->qual[c].total_size, def.size_sequence = file_count, def
        .environment_id = envid,
        def.tablespace_name = newlist->qual[c].new_tb_name, def.file_name = fname
       WITH nocounter
      ;end insert
    ENDWHILE
  ENDFOR
  FOR (a = 1 TO ecnt2)
    SET diff = 0.0
    SET existlist->qual[a].partitioned_bytes = 0.0
    IF ((existlist->qual[a].free_space < existlist->qual[a].calc_size))
     SET diff = (existlist->qual[a].calc_size - existlist->qual[a].free_space)
     SET existlist->qual[a].partitioned_bytes = (((round((diff/ (partition_size * mbyte)),0)+ 1) *
     partition_size) * mbyte)
     SET db_count = 0
     SELECT INTO "nl:"
      a.file_name
      FROM dba_data_files a
      WHERE (a.tablespace_name=existlist->qual[a].tb_name)
      DETAIL
       db_count = (db_count+ 1)
      WITH nocounter
     ;end select
     SET existlist->qual[a].file_count = db_count
     SET total_size = existlist->qual[a].partitioned_bytes
     WHILE (total_size > 0)
       SET file_count = (existlist->qual[a].file_count+ 1)
       IF (total_size > max_size)
        SET raw_size = max_size
       ELSE
        SET raw_size = total_size
       ENDIF
       SET total_size = (total_size - raw_size)
       SET existlist->qual[a].total_size = raw_size
       SET existlist->qual[a].file_count = file_count
       SET fname = fillstring(40," ")
       SET fname = build(existlist->qual[a].tb_name,"_",format(cnvtstring(existlist->qual[a].
          file_count),"###;P0"))
       INSERT  FROM dm_env_files def
        SET def.updt_applctx = 0, def.updt_dt_tm = cnvtdatetime(curdate,curtime3), def.updt_cnt = 0,
         def.updt_id = 0, def.updt_task = 0, def.file_type =
         IF (substring(1,1,existlist->qual[a].tb_name)="I") "INDEX"
         ELSE "DATA"
         ENDIF
         ,
         def.file_size = existlist->qual[a].total_size, def.size_sequence = file_count, def
         .environment_id = envid,
         def.tablespace_name = existlist->qual[a].tb_name, def.file_name = fname, def
         .tablespace_exist_ind = 1
        WITH nocounter
       ;end insert
     ENDWHILE
    ENDIF
  ENDFOR
 ELSE
  FREE SET file_sizes
  RECORD file_sizes(
    1 scount = i4
    1 sizes[*]
      2 size = f8
      2 size_seq = f8
  )
  SET file_sizes->scount = 0
  SET dclcom = build("ls /dev/r",cnvtlower(database_name),"_*  >vol_out.dat")
  SET len = size(trim(dclcom))
  SET status = 0
  CALL dcl(dclcom,len,status)
  SET db_length = size(trim(database_name),1)
  SET sb_length = (db_length+ 8)
  SET ss_length = (sb_length+ 5)
  FREE DEFINE rtl
  FREE SET file_loc
  SET logical file_loc "vol_out.dat"
  DEFINE rtl "file_loc"
  SELECT INTO "nl:"
   r.line
   FROM rtlt r
   DETAIL
    size_found = 0, size_bytes = ((cnvtint(substring(sb_length,4,r.line)) - 1) * mbyte), size_seq =
    cnvtint(substring(ss_length,3,r.line))
    FOR (i = 1 TO file_sizes->scount)
      IF ((size_bytes=file_sizes->sizes[i].size))
       IF ((file_sizes->sizes[i].size_seq < size_seq))
        file_sizes->sizes[i].size_seq = size_seq
       ENDIF
       size_found = 1
      ENDIF
    ENDFOR
    IF (size_found=0)
     file_sizes->scount = (file_sizes->scount+ 1)
     IF (mod(file_sizes->scount,10)=1)
      stat = alterlist(file_sizes->sizes,(file_sizes->scount+ 9))
     ENDIF
     file_sizes->sizes[file_sizes->scount].size = size_bytes, file_sizes->sizes[file_sizes->scount].
     size_seq = size_seq
    ENDIF
   WITH nocounter
  ;end select
  FREE SET tspace_files
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
  FOR (kount = 1 TO cnt2)
    SET row_count = 1
    SET total_size = newlist->qual[kount].partitioned_bytes
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
      SET tspace_files->tname[tspace_files->fcount].size = (raw_size - mbyte)
      SET tspace_files->tname[tspace_files->fcount].raw_size = raw_size
      SET tspace_files->tname[tspace_files->fcount].tspace_name = newlist->qual[kount].new_tb_name
      SET size_found = 0
      FOR (i = 1 TO file_sizes->scount)
        IF (((raw_size - mbyte)=file_sizes->sizes[i].size))
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
       SET file_sizes->sizes[file_sizes->scount].size = (raw_size - mbyte)
       SET file_sizes->sizes[file_sizes->scount].size_seq = 1
       SET tspace_files->tname[tspace_files->fcount].size_seq = 1
      ENDIF
      SET fname = fillstring(80," ")
      SET file_seq = format(cnvtstring(row_count),"###;P0")
      SET fname = build(cnvtlower(database_name),"_",format(cnvtstring((raw_size/ (1024.0 * 1024.0))),
        "####;P0"),"_",format(cnvtstring(tspace_files->tname[tspace_files->fcount].size_seq),"###;P0"
        ))
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
        tspace_files->tname[tspace_files->fcount].size_seq, def.environment_id = envid,
        def.tablespace_name = tspace_files->tname[tspace_files->fcount].tspace_name, def.file_name =
        tspace_files->tname[tspace_files->fcount].fname
       WITH nocounter
      ;end insert
    ENDWHILE
  ENDFOR
  COMMIT
  FREE SET tspace_files
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
  FOR (a = 1 TO ecnt2)
    SET diff = 0.0
    SET existlist->qual[a].partitioned_bytes = 0.0
    IF ((existlist->qual[a].free_space < existlist->qual[a].calc_size))
     SET diff = (existlist->qual[a].calc_size - existlist->qual[a].free_space)
     SET existlist->qual[a].partitioned_bytes = (((round((diff/ (partition_size * mbyte)),0)+ 1) *
     partition_size) * mbyte)
     SET row_count = 1
     SET total_size = existlist->qual[a].partitioned_bytes
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
       SET tspace_files->tname[tspace_files->fcount].size = (raw_size - mbyte)
       SET tspace_files->tname[tspace_files->fcount].raw_size = raw_size
       SET tspace_files->tname[tspace_files->fcount].tspace_name = existlist->qual[a].tb_name
       SET size_found = 0
       FOR (i = 1 TO file_sizes->scount)
         IF (((raw_size - mbyte)=file_sizes->sizes[i].size))
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
        SET file_sizes->sizes[file_sizes->scount].size = (raw_size - mbyte)
        SET file_sizes->sizes[file_sizes->scount].size_seq = 1
        SET tspace_files->tname[tspace_files->fcount].size_seq = 1
       ENDIF
       SET fname = fillstring(80," ")
       SET file_seq = format(cnvtstring(row_count),"###;P0")
       SET fname = build(cnvtlower(database_name),"_",format(cnvtstring((raw_size/ (1024.0 * 1024.0))
          ),"####;P0"),"_",format(cnvtstring(tspace_files->tname[tspace_files->fcount].size_seq),
         "###;P0"))
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
         tspace_files->tname[tspace_files->fcount].size_seq, def.environment_id = envid,
         def.tablespace_name = tspace_files->tname[tspace_files->fcount].tspace_name, def.file_name
          = tspace_files->tname[tspace_files->fcount].fname, def.tablespace_exist_ind = 1
        WITH nocounter
       ;end insert
     ENDWHILE
    ENDIF
  ENDFOR
 ENDIF
 COMMIT
#end_program
END GO
