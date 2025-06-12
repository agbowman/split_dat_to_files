CREATE PROGRAM dm_fill_table_size:dba
 SET debug_ind = "N"
 RECORD list(
   1 table1[*]
     2 table_name = c30
     2 rel_table_size = f8
     2 bytes_per_row = f8
     2 row_count = f8
   1 table_cnt = i4
   1 all_product_cd = f8
   1 block_size = f8
   1 driver_table_name = c30
 )
 SET stat = alterlist(list->table1,100)
 SET list->table_cnt = 0
 SET list->all_product_cd = 0
 SET list->block_size = cnvtreal(8000.00)
 SET list->driver_table_name = fillstring(30," ")
 SELECT INTO "nl:"
  so.*
  FROM space_objects so
  WHERE (so.report_seq= $1)
   AND so.segment_type="TABLE"
  ORDER BY so.row_count DESC
  HEAD REPORT
   divisor = cnvtreal(so.row_count), list->driver_table_name = so.segment_name
  DETAIL
   list->table_cnt = (list->table_cnt+ 1)
   IF (mod(list->table_cnt,100)=1
    AND (list->table_cnt != 1))
    stat = alterlist(list->table1,(list->table_cnt+ 99))
   ENDIF
   list->table1[list->table_cnt].table_name = so.segment_name, list->table1[list->table_cnt].
   rel_table_size = (so.row_count/ divisor), list->table1[list->table_cnt].row_count = so.row_count,
   list->table1[list->table_cnt].bytes_per_row = (((so.total_space - so.free_space) * list->
   block_size)/ so.row_count)
  WITH nocounter
 ;end select
 IF (debug_ind="Y")
  SELECT
   *
   FROM dual
   DETAIL
    FOR (x = 1 TO list->table_cnt)
      "TBL: ", list->table1[x].table_name, " DR: ",
      list->driver_table_name, " RELSIZ: ", list->table1[x].rel_table_size"#.#########",
      " BPR: ", list->table1[x].bytes_per_row, " ROWCNT: ",
      list->table1[x].row_count"########", row + 1
    ENDFOR
   WITH nocounter, maxcol = 200
  ;end select
 ENDIF
 IF (debug_ind != "Y")
  FOR (x = 1 TO list->table_cnt)
    UPDATE  FROM dm_product_table_reltn dptr
     SET dptr.table_name = list->table1[x].table_name, dptr.product_cd = list->all_product_cd, dptr
      .driver_table_name = list->driver_table_name,
      dptr.rel_table_size = list->table1[x].rel_table_size, dptr.updt_dt_tm = cnvtdatetime(curdate,
       curtime3), dptr.updt_cnt = (dptr.updt_cnt+ 1),
      dptr.updt_id = 0, dptr.updt_task = 0
     WHERE (dptr.table_name=list->table1[x].table_name)
      AND (dptr.product_cd=list->all_product_cd)
     WITH nocounter
    ;end update
    IF (curqual=0)
     INSERT  FROM dm_product_table_reltn dptr
      SET dptr.table_name = list->table1[x].table_name, dptr.product_cd = list->all_product_cd, dptr
       .driver_table_name = list->driver_table_name,
       dptr.rel_table_size = list->table1[x].rel_table_size, dptr.updt_dt_tm = cnvtdatetime(curdate,
        curtime3), dptr.updt_cnt = 0,
       dptr.updt_id = 0, dptr.updt_task = 0
      WHERE 1=1
      WITH nocounter
     ;end insert
    ENDIF
    COMMIT
  ENDFOR
 ENDIF
 IF (debug_ind != "Y")
  FOR (x = 1 TO list->table_cnt)
   UPDATE  FROM dm_tables_doc dtd
    SET dtd.bytes_per_row = list->table1[x].bytes_per_row
    WHERE (dtd.table_name=list->table1[x].table_name)
    WITH nocounter
   ;end update
   COMMIT
  ENDFOR
 ENDIF
 RECORD list1(
   1 table1[*]
     2 index_name = c30
     2 rel_index_size = f8
     2 bytes_per_row = f8
     2 row_count = f8
   1 index_cnt = i4
   1 all_product_cd = f8
   1 block_size = f8
   1 driver_index_name = c30
 )
 SET stat = alterlist(list1->table1,100)
 SET list1->index_cnt = 0
 SET list1->all_product_cd = 0
 SET list1->block_size = cnvtreal(8000.00)
 SET list1->driver_index_name = fillstring(30," ")
 SELECT INTO "nl:"
  so.*
  FROM space_objects so
  WHERE (so.report_seq= $1)
   AND so.segment_type="INDEX"
  ORDER BY so.row_count DESC
  HEAD REPORT
   divisor = cnvtreal(so.row_count), list1->driver_index_name = so.segment_name
  DETAIL
   list1->index_cnt = (list1->index_cnt+ 1)
   IF (mod(list1->index_cnt,100)=1
    AND (list1->index_cnt != 1))
    stat = alterlist(list1->table1,(list1->index_cnt+ 99))
   ENDIF
   list1->table1[list1->index_cnt].index_name = so.segment_name, list1->table1[list1->index_cnt].
   rel_index_size = (so.row_count/ divisor), list1->table1[list1->index_cnt].row_count = so.row_count,
   list1->table1[list1->index_cnt].bytes_per_row = (((so.total_space - so.free_space) * list1->
   block_size)/ so.row_count)
  WITH nocounter
 ;end select
 IF (debug_ind="Y")
  SELECT
   *
   FROM dual
   DETAIL
    FOR (x = 1 TO list1->index_cnt)
      "INDX: ", list1->table1[x].index_name, " DR: ",
      list1->driver_index_name, " RELSIZ: ", list1->table1[x].rel_index_size"#.#########",
      " BPR: ", list1->table1[x].bytes_per_row, " ROWCNT: ",
      list1->table1[x].row_count"########", row + 1
    ENDFOR
   WITH nocounter, maxcol = 200
  ;end select
 ENDIF
 IF (debug_ind != "Y")
  FOR (x = 1 TO list1->index_cnt)
   UPDATE  FROM dm_indexes_doc did
    SET did.bytes_per_row = list1->table1[x].bytes_per_row
    WHERE (did.index_name=list1->table1[x].index_name)
    WITH nocounter
   ;end update
   COMMIT
  ENDFOR
 ENDIF
#end_program
END GO
