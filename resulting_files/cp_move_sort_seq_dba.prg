CREATE PROGRAM cp_move_sort_seq:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 FREE RECORD distr
 RECORD distr(
   1 qual[*]
     2 distr_id = f8
     2 sort_seq = i2
     2 ss_cv = f8
 )
 SET successful_cnt = 0
 SET count = 0
 SET count1 = 0
 SET cnt_ops = 0
 SET active_cd = 0.0
 SET inactive_cd = 0.0
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.cdf_meaning IN ("ACTIVE", "INACTIVE")
   AND cv.active_ind=1
   AND cv.code_set=48
  HEAD REPORT
   do_nothing = 0
  DETAIL
   IF (cv.cdf_meaning="ACTIVE")
    active_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="INACTIVE")
    inactive_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  cd.distribution_id, cd.sort_sequence_flag
  FROM chart_distribution cd
  ORDER BY cd.distribution_id
  HEAD REPORT
   count = 0
  HEAD cd.distribution_id
   count += 1, stat = alterlist(distr->qual,count), distr->qual[count].distr_id = cd.distribution_id,
   distr->qual[count].sort_seq = cd.sort_sequence_flag
  WITH nocounter
 ;end select
 FREE RECORD ops_rec
 RECORD ops_rec(
   1 qual[*]
     2 charting_operations_id = f8
     2 has_15 = i2
 )
 SET cnt_ops = 0
 SET value1 = 0.0
 DELETE  FROM charting_operations co
  SET co.seq = 1
  WHERE co.param_type_flag=15
   AND co.param IN ("0", " ", "")
 ;end delete
 COMMIT
 SELECT INTO "nl:"
  co.charting_operations_id
  FROM charting_operations co
  WHERE co.param_type_flag=15
  ORDER BY co.charting_operations_id, co.sequence
  HEAD REPORT
   cnt_ops = 0
  DETAIL
   IF (cnvtint(co.param) > 0)
    cnt_ops += 1, stat = alterlist(ops_rec->qual,cnt_ops), ops_rec->qual[cnt_ops].
    charting_operations_id = co.charting_operations_id,
    ops_rec->qual[cnt_ops].has_15 = 1
   ENDIF
  WITH nocounter
 ;end select
 SET cnt_ops = 0
 SET cnt_ops = size(ops_rec->qual,5)
 FREE RECORD all_ops_rec
 RECORD all_ops_rec(
   1 qual[*]
     2 ops_id = f8
     2 batch_name = vc
     2 batch_key = vc
     2 active_ind = i2
     2 dist_id = f8
     2 max_seq = i4
     2 ss_cv = vc
     2 has_15 = i2
 )
 SET ops_cnt = 0
 SELECT INTO "nl:"
  co.charting_operations_id
  FROM charting_operations co
  ORDER BY co.charting_operations_id, co.sequence DESC
  HEAD REPORT
   ops_cnt = 0, x = 0, found = 0
  HEAD co.charting_operations_id
   x = 0, ops_cnt += 1, stat = alterlist(all_ops_rec->qual,ops_cnt),
   all_ops_rec->qual[ops_cnt].ops_id = co.charting_operations_id, all_ops_rec->qual[ops_cnt].max_seq
    = (co.sequence+ 1), all_ops_rec->qual[ops_cnt].batch_name = co.batch_name,
   all_ops_rec->qual[ops_cnt].batch_key = co.batch_name_key, found = 0
   FOR (x = 1 TO cnt_ops)
     IF ((ops_rec->qual[x].charting_operations_id=all_ops_rec->qual[ops_cnt].ops_id)
      AND found=0)
      all_ops_rec->qual[ops_cnt].has_15 = 1, found = 1
     ELSEIF (found=0)
      all_ops_rec->qual[ops_cnt].has_15 = 0
     ENDIF
   ENDFOR
  DETAIL
   do_nothing = 0
  WITH nocounter
 ;end select
 SET size_distr = 0
 SET size_distr = size(distr->qual,5)
 FOR (x = 1 TO size_distr)
  SET code_value = 0.0
  SELECT INTO "nl:"
   cv.code_value
   FROM code_value cv
   WHERE cv.code_set=22011
    AND cv.active_ind=1
    AND cv.cdf_meaning=cnvtstring(distr->qual[x].sort_seq)
   HEAD REPORT
    do_nothing = 0
   DETAIL
    distr->qual[x].ss_cv =
    IF (cv.code_value > 0) cv.code_value
    ELSE 0.0
    ENDIF
   WITH nocounter
  ;end select
 ENDFOR
 SET size_all_ops = 0
 SET size_all_ops = size(all_ops_rec->qual,5)
 SELECT INTO "nl:"
  co.param
  FROM charting_operations co,
   (dummyt dt  WITH seq = value(size_all_ops))
  PLAN (dt)
   JOIN (co
   WHERE (co.charting_operations_id=all_ops_rec->qual[dt.seq].ops_id)
    AND co.param_type_flag=2)
  HEAD dt.seq
   all_ops_rec->qual[dt.seq].dist_id = cnvtreal(co.param), all_ops_rec->qual[dt.seq].active_ind = co
   .active_ind
  WITH nocounter
 ;end select
 FOR (x = 1 TO size_all_ops)
   FOR (y = 1 TO size_distr)
     IF ((all_ops_rec->qual[x].dist_id=distr->qual[y].distr_id))
      SET all_ops_rec->qual[x].ss_cv = cnvtstring(distr->qual[y].ss_cv)
     ENDIF
   ENDFOR
 ENDFOR
 SET count1 = size(all_ops_rec->qual,5)
 IF (count1 > 0)
  SET count2 = 1
  WHILE (count2 <= count1)
   IF ((all_ops_rec->qual[count2].has_15 != 1)
    AND (all_ops_rec->qual[count2].ops_id > 0))
    CALL insert_param_in_ops(count2)
   ENDIF
   SET count2 += 1
  ENDWHILE
 ENDIF
 SUBROUTINE insert_param_in_ops(index)
   CALL echo(build("trying to insert ops = ",all_ops_rec->qual[index].ops_id," ss_cv = ",all_ops_rec
     ->qual[index].ss_cv," with sequence = ",
     all_ops_rec->qual[index].max_seq))
   SET readme_data->message = build("Inserting Ops_id = ",all_ops_rec->qual[index].ops_id,
    " / SORT-SEQ = ",all_ops_rec->qual[index].ss_cv," / sequence = ",
    all_ops_rec->qual[index].max_seq)
   SET readme_data->status = "S"
   EXECUTE dm_readme_status
   COMMIT
   INSERT  FROM charting_operations c
    SET c.charting_operations_id = all_ops_rec->qual[index].ops_id, c.sequence = all_ops_rec->qual[
     index].max_seq, c.batch_name = all_ops_rec->qual[index].batch_name,
     c.batch_name_key = all_ops_rec->qual[index].batch_key, c.param_type_flag = 15, c.param =
     all_ops_rec->qual[index].ss_cv,
     c.active_ind = all_ops_rec->qual[index].active_ind, c.active_status_cd =
     IF ((all_ops_rec->qual[index].active_ind=1)) active_cd
     ELSE inactive_cd
     ENDIF
     , c.active_status_dt_tm = cnvtdatetime(sysdate),
     c.active_status_prsnl_id = 0.0, c.updt_cnt = 0, c.updt_dt_tm = cnvtdatetime(sysdate),
     c.updt_id = 0.0, c.updt_task = 0, c.updt_applctx = 0
   ;end insert
   IF (curqual > 0)
    SET successful_cnt += 1
   ENDIF
 END ;Subroutine
#exit_script
 CALL echo(build("updated count = ",successful_cnt))
 SET count_sort = 0
 SELECT INTO "nl:"
  co.charting_operations_id
  FROM charting_operations co
  WHERE co.param_type_flag=15
  HEAD REPORT
   count_sort = 0
  DETAIL
   count_sort += 1
  WITH nocounter
 ;end select
 CALL echo(build("count_sort = ",count_sort))
 SET count_ops = 0
 SELECT INTO "nl:"
  co.charting_operations_id
  FROM charting_operations co
  WHERE co.param_type_flag=2
  HEAD REPORT
   count_ops = 0
  DETAIL
   count_ops += 1
  WITH nocounter
 ;end select
 CALL echo(build("count_ops = ",count_ops))
 COMMIT
 CALL echo("committing changes to charting_operations sort-sequences")
 IF (count_ops=count_sort)
  COMMIT
  SET readme_data->message =
  "Sort-sequence added successfully to charting_operations table - SUCCESSFUL"
  SET readme_data->status = "S"
  EXECUTE dm_readme_status
  CALL echo("SORT-SEQUENCE UPDATE -- SUCCESSFUL")
  COMMIT
 ELSE
  ROLLBACK
  SET readme_data->message = "Sort-sequence not added to charting_operations table - FAILED"
  SET readme_data->status = "F"
  EXECUTE dm_readme_status
  COMMIT
  CALL echo("SORT-SEQUENCE UPDATE -- FAILURE")
 ENDIF
END GO
