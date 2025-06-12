CREATE PROGRAM dm_explode_mrg_tables:dba
 RECORD mrg(
   1 list[*]
     2 table_name = c30
     2 process_flg = i4
     2 dup_check_ind = i4
     2 mode_flg = i4
     2 commit_ind = i4
     2 restrict_clause = c255
     2 child_tables = c255
 )
 RECORD mrg1(
   1 sort[*]
     2 mrg_order = i4
 )
 SET mrg_list_cnt = 0
 SET stat = alterlist(mrg->list,10)
 SET stat = alterlist(mrg1->sort,10)
 SET list_order = 0
 SELECT INTO "nl:"
  mtl.*
  FROM dm_env_mrg_table_list mtl
  DETAIL
   mrg_list_cnt = (mrg_list_cnt+ 1)
   IF (mod(mrg_list_cnt,10)=1
    AND mrg_list_cnt != 1)
    stat = alterlist(mrg->list,(mrg_list_cnt+ 9)), stat = alterlist(mrg1->sort,(mrg_list_cnt+ 9))
   ENDIF
   mrg1->sort[mrg_list_cnt].mrg_order = mrg_list_cnt, mrg->list[mrg_list_cnt].table_name = mtl
   .table_name, mrg->list[mrg_list_cnt].process_flg = mtl.process_flg,
   mrg->list[mrg_list_cnt].dup_check_ind = mtl.dup_check_ind, mrg->list[mrg_list_cnt].mode_flg = mtl
   .mode_flg, mrg->list[mrg_list_cnt].commit_ind = mtl.commit_ind,
   mrg->list[mrg_list_cnt].restrict_clause = mtl.restrict_clause, mrg->list[mrg_list_cnt].
   child_tables = mtl.child_tables
  WITH nocounter
 ;end select
 SET list_sorted = 0
 WHILE (list_sorted=0)
  SET list_sorted = 1
  SELECT INTO "NL:"
   d.seq, cd.*
   FROM dm_columns_doc cd,
    (dummyt d  WITH seq = value(mrg_list_cnt))
   PLAN (d)
    JOIN (cd
    WHERE (cd.table_name=mrg->list[d.seq].table_name)
     AND cd.root_entity_name IS NOT null
     AND cd.root_entity_name > " ")
   DETAIL
    table_found = 0
    FOR (y = 1 TO mrg_list_cnt)
      IF ((mrg->list[y].table_name=cd.root_entity_name))
       table_found = 1
       IF ((mrg->list[y].table_name != mrg->list[d.seq].table_name))
        pos = findstring(trim(mrg->list[d.seq].table_name),mrg->list[y].child_tables,1)
        IF (pos=0)
         mrg->list[y].child_tables = build(mrg->list[y].child_tables,mrg->list[d.seq].table_name,",")
        ENDIF
       ENDIF
       IF ((mrg1->sort[y].mrg_order > mrg1->sort[d.seq].mrg_order))
        FOR (i = 1 TO mrg_list_cnt)
          IF ((mrg1->sort[i].mrg_order > mrg1->sort[d.seq].mrg_order))
           mrg1->sort[i].mrg_order = (mrg1->sort[i].mrg_order+ 1)
          ENDIF
        ENDFOR
        mrg1->sort[y].mrg_order = mrg1->sort[d.seq].mrg_order, mrg1->sort[d.seq].mrg_order = (mrg1->
        sort[d.seq].mrg_order+ 1), list_sorted = 0
       ENDIF
      ENDIF
    ENDFOR
    IF (table_found=0)
     mrg_list_cnt = (mrg_list_cnt+ 1)
     IF (mod(mrg_list_cnt,10)=1
      AND mrg_list_cnt != 1)
      stat = alterlist(mrg->list,(mrg_list_cnt+ 9)), stat = alterlist(mrg1->sort,(mrg_list_cnt+ 9))
     ENDIF
     FOR (i = 1 TO mrg_list_cnt)
       IF ((mrg1->sort[i].mrg_order > mrg1->sort[d.seq].mrg_order))
        mrg1->sort[i].mrg_order = (mrg1->sort[i].mrg_order+ 1)
       ENDIF
     ENDFOR
     mrg1->sort[mrg_list_cnt].mrg_order = mrg1->sort[d.seq].mrg_order, mrg1->sort[d.seq].mrg_order =
     (mrg1->sort[d.seq].mrg_order+ 1), mrg->list[mrg_list_cnt].table_name = trim(cd.root_entity_name),
     mrg->list[mrg_list_cnt].process_flg = 1, mrg->list[mrg_list_cnt].dup_check_ind = 1, mrg->list[
     mrg_list_cnt].mode_flg = 0,
     mrg->list[mrg_list_cnt].commit_ind = 1, mrg->list[mrg_list_cnt].restrict_clause = "", pos =
     findstring(trim(mrg->list[d.seq].table_name),mrg->list[mrg_list_cnt].child_tables,1)
     IF (pos=0)
      mrg->list[mrg_list_cnt].child_tables = build(mrg->list[mrg_list_cnt].child_tables,mrg->list[d
       .seq].table_name,",")
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
 ENDWHILE
 DELETE  FROM dm_env_mrg_table_list
  WHERE 1=1
 ;end delete
 COMMIT
 FOR (z = 1 TO mrg_list_cnt)
  INSERT  FROM dm_env_mrg_table_list
   (mrg_order, table_name, process_flg,
   dup_check_ind, mode_flg, commit_ind,
   restrict_clause, child_tables)
   VALUES(mrg1->sort[z].mrg_order, mrg->list[z].table_name, mrg->list[z].process_flg,
   mrg->list[z].dup_check_ind, mrg->list[z].mode_flg, mrg->list[z].commit_ind,
   mrg->list[z].restrict_clause, mrg->list[z].child_tables)
  ;end insert
  COMMIT
 ENDFOR
END GO
