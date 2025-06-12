CREATE PROGRAM dm_check_static_rowcounts
 SET env = fillstring(20," ")
 SELECT INTO "nl:"
  de.environment_name
  FROM dm_info di,
   dm_environment de
  WHERE di.info_name="DM_ENV_ID"
   AND di.info_domain="DATA MANAGEMENT"
   AND de.environment_id=di.info_number
  DETAIL
   env = de.environment_name
  WITH nocounter
 ;end select
 SET environment_id = 0.0
 SELECT INTO "nl:"
  de.environment_id
  FROM dm_environment de
  WHERE de.environment_name=env
  DETAIL
   environment_id = de.environment_id
  WITH nocounter
 ;end select
 FREE SET table_list
 RECORD table_list(
   1 table_count = i4
   1 total_row_count = f8
   1 list[*]
     2 tname = c32
     2 rowcount = f8
     2 actual_row_count = f8
     2 bytes_per_row = f8
     2 table_ref_count = i4
     2 init = f8
     2 next = f8
     2 static_rows = f8
     2 delta_rows = f8
     2 dependency_count = i4
     2 dependency[30]
       3 dependency_resolved = i4
       3 dependency = c32
       3 dependency_flg = f8
       3 dependency_ratio = f8
     2 sum_index = f8
     2 index_count = i4
     2 index_name[*]
       3 iname = c32
       3 bytes_per_row = f8
       3 init = f8
       3 next = f8
 )
 SET table_list->table_count = 0
 FREE SET question_list
 RECORD question_list(
   1 question_count = i4
   1 question[*]
     2 question_number = f8
     2 description = c100
     2 question_type = i4
     2 question_answer = f8
 )
 SET question_list->question_count = 0
 SET total_static_space = 0.0
 SET static_count = 0.0
 SET kount = 0
 SET temp_sum = 0.0
 SET icnt = 0
 SET sum_static = 0.0
 SET sum_delta = 0.0
 SET first_flag = 0
 SET max_size = 0.0
 SET mbyte = (1024.0 * 1024.0)
 SET kount = 0
 SELECT DISTINCT INTO "nl:"
  dtd.table_name
  FROM dm_tables_doc dtd
  WHERE dtd.reference_ind=1
  ORDER BY dtd.table_name
  DETAIL
   kount = (kount+ 1)
   IF (mod(kount,10)=1)
    stat = alterlist(table_list->list,(kount+ 9))
   ENDIF
   table_list->list[kount].tname = dtd.table_name, table_list->list[kount].delta_rows = 0.0,
   table_list->list[kount].static_rows = 0.0,
   table_list->list[kount].actual_row_count = 0.0, table_list->list[kount].table_ref_count = 0,
   table_list->list[kount].dependency_count = 1,
   table_list->list[kount].dependency[1].dependency_resolved = 1, table_list->list[kount].dependency[
   1].dependency_flg = 3, table_list->list[kount].dependency[1].dependency = "1000",
   table_list->list[kount].dependency[1].dependency_ratio = 1
  WITH nocounter
 ;end select
 SET table_list->table_count = kount
 SELECT INTO "nl:"
  d.seq, dep.dependency, dep.dependency_flg,
  dep.dependency_ratio, dep.table_name
  FROM (dummyt d  WITH seq = value(table_list->table_count)),
   dm_table_dependency dep
  PLAN (d)
   JOIN (dep
   WHERE (dep.table_name=table_list->list[d.seq].tname))
  ORDER BY dep.table_name
  HEAD dep.table_name
   table_list->list[d.seq].static_rows = 0, table_list->list[d.seq].dependency_count = 0, dep_cnt = 0
  DETAIL
   table_list->list[d.seq].dependency_count = (table_list->list[d.seq].dependency_count+ 1), dep_cnt
    = table_list->list[d.seq].dependency_count, table_list->list[d.seq].dependency[dep_cnt].
   dependency = dep.dependency,
   table_list->list[d.seq].dependency[dep_cnt].dependency_flg = dep.dependency_flg
   IF (dep.dependency_ratio=0)
    table_list->list[d.seq].dependency[dep_cnt].dependency_ratio = 1.0
   ELSE
    table_list->list[d.seq].dependency[dep_cnt].dependency_ratio = dep.dependency_ratio
   ENDIF
   table_list->list[d.seq].dependency[dep_cnt].dependency_resolved = 1
   IF (dep.dependency_flg=3)
    table_list->list[d.seq].static_rows = (table_list->list[d.seq].static_rows+ (cnvtint(dep
     .dependency) * dep.dependency_ratio))
   ELSEIF (dep.dependency_flg=4)
    table_list->list[d.seq].delta_rows = (table_list->list[d.seq].delta_rows+ (cnvtint(dep.dependency
     ) * dep.dependency_ratio))
   ELSEIF (dep.dependency_flg=2)
    table_list->list[d.seq].table_ref_count = (table_list->list[d.seq].table_ref_count+ 1),
    table_list->list[d.seq].dependency[dep_cnt].dependency_resolved = 0
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("getting the answers to the questions")
 SELECT INTO "nl:"
  dq.description, dq.question_type, dq.question_number,
  deq.question_answer
  FROM dm_question dq,
   dm_env_question deq
  WHERE deq.environment_id=environment_id
   AND dq.question_number=deq.question_number
  ORDER BY dq.question_number
  DETAIL
   question_list->question_count = (question_list->question_count+ 1)
   IF (mod(question_list->question_count,10)=1)
    stat = alterlist(question_list->question,(question_list->question_count+ 9))
   ENDIF
   question_list->question[question_list->question_count].description = dq.description, question_list
   ->question[question_list->question_count].question_type = dq.question_type, question_list->
   question[question_list->question_count].question_number = dq.question_number,
   question_list->question[question_list->question_count].question_answer = deq.question_answer
  WITH nocounter
 ;end select
 CALL echo("caclulating the row counts based on the answers to the questions")
 FOR (kount = 1 TO table_list->table_count)
   FOR (dcount = 1 TO table_list->list[kount].dependency_count)
     IF ((table_list->list[kount].dependency[dcount].dependency_flg=1))
      FOR (qcount = 1 TO question_list->question_count)
        IF ((cnvtint(table_list->list[kount].dependency[dcount].dependency)=question_list->question[
        qcount].question_number))
         IF ((question_list->question[qcount].question_type=1))
          SET table_list->list[kount].static_rows = (table_list->list[kount].static_rows+ (
          question_list->question[qcount].question_answer * table_list->list[kount].dependency[dcount
          ].dependency_ratio))
         ELSE
          SET table_list->list[kount].delta_rows = (table_list->list[kount].delta_rows+ (
          question_list->question[qcount].question_answer * table_list->list[kount].dependency[dcount
          ].dependency_ratio))
         ENDIF
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
 ENDFOR
 CALL echo("all of the questions have been resolved")
 SET max_attempts = 10
 SET attempts = 0
 SET unresolves_exist = 1
 SET global_unresolves_exist = 1
 WHILE (attempts < max_attempts
  AND global_unresolves_exist=1)
   SET attempts = (attempts+ 1)
   SET global_unresolves_exist = 0
   FOR (kount = 1 TO table_list->table_count)
     FOR (dcount = 1 TO table_list->list[kount].dependency_count)
       IF ((table_list->list[kount].dependency[dcount].dependency_flg=2)
        AND (table_list->list[kount].dependency[dcount].dependency_resolved=0))
        SET unresolves_exist = 0
        SET driver_table_found = 0
        FOR (tcount = 1 TO table_list->table_count)
          IF ((table_list->list[tcount].tname=table_list->list[kount].dependency[dcount].dependency))
           SET driver_table_found = 1
           FOR (pcount = 1 TO table_list->list[tcount].dependency_count)
             IF ((table_list->list[tcount].dependency[pcount].dependency_resolved=0))
              SET global_unresolves_exist = 1
              SET unresolves_exist = 1
             ENDIF
           ENDFOR
           IF (unresolves_exist=0)
            SET table_list->list[kount].dependency[dcount].dependency_resolved = 1
            SET table_list->list[kount].delta_rows = (table_list->list[kount].delta_rows+ (table_list
            ->list[tcount].delta_rows * table_list->list[kount].dependency[dcount].dependency_ratio))
            SET table_list->list[kount].static_rows = (table_list->list[kount].static_rows+ (
            table_list->list[tcount].static_rows * table_list->list[kount].dependency[dcount].
            dependency_ratio))
           ENDIF
          ENDIF
        ENDFOR
        IF (driver_table_found=0)
         CALL echo(build("Warning - ",table_list->list[kount].tname," is dependent on table ",
           table_list->list[kount].dependency[dcount].dependency,
           " which is not in the schema being built."))
         SET table_list->list[kount].dependency[dcount].dependency_resolved = 1
        ENDIF
       ENDIF
     ENDFOR
   ENDFOR
 ENDWHILE
 IF (attempts=max_attempts)
  CALL echo(build("Max attempts reached to resolve dependencies"))
  GO TO end_prg
 ENDIF
 SET tempcmd = fillstring(255," ")
 FOR (i = 1 TO table_list->table_count)
   IF ((table_list->list[i].static_rows > 0.0))
    SET tempcmd = concat('select into "nl:" y=count(*) from ',table_list->list[i].tname,
     " detail table_list->list[",cnvtstring(i),"]->actual_row_count = y ",
     "with nocounter go")
    CALL parser(tempcmd)
   ENDIF
 ENDFOR
 SELECT
  d.*
  FROM dual d
  DETAIL
   FOR (i = 1 TO table_list->table_count)
     IF ((table_list->list[i].actual_row_count > table_list->list[i].static_rows))
      table_list->list[i].tname, table_list->list[i].actual_row_count, table_list->list[i].
      static_rows,
      row + 1
     ENDIF
   ENDFOR
  WITH nocounter
 ;end select
END GO
