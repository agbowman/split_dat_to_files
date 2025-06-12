CREATE PROGRAM dm_parallel_reports:dba
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
 DECLARE dipr_setup_install_itinerary(dsit_plan_id=f8,dsit_plan_type=vc) = i2
 DECLARE dipr_add_itin_step(dais_mode=vc,dais_level=i2,dais_step_nbr=i2,dais_step_name=vc,
  dais_itin_key=vc) = i2
 DECLARE dipr_get_install_itinerary(dgit_plan_id=f8) = i2
 DECLARE dipr_update_install_itinerary(duit_status=i2,duit_itin_id=f8,duit_plan_id=f8) = i2
 DECLARE dipr_get_cur_dpe_data(dgcdd_install_plan=f8) = i2
 DECLARE dipr_get_plan_nbr(null) = i2
 DECLARE dipr_disp_error_msg(null) = i2
 IF ((validate(dip_itin_rs->itin_cnt,- (1))=- (1))
  AND (validate(dip_itin_rs->itin_cnt,- (2))=- (2)))
  FREE RECORD dip_itin_rs
  RECORD dip_itin_rs(
    1 install_plan_id = f8
    1 itin_cnt = i4
    1 itin_step[*]
      2 dm_process_event_id = f8
      2 event_status = vc
      2 begin_dt_tm = dq8
      2 end_dt_tm = dq8
      2 message_txt = vc
      2 itinerary_key = vc
      2 install_mode = vc
      2 level_number = i2
      2 step_number = i4
      2 step_name = vc
      2 parent_step_name = vc
      2 parent_level_number = i2
  )
 ENDIF
 IF ((validate(dipm_misc_data->install_plan_id,- (1))=- (1))
  AND (validate(dipm_misc_data->install_plan_id,- (2))=- (2)))
  FREE RECORD dipm_misc_data
  RECORD dipm_misc_data(
    1 install_plan_id = f8
    1 cur_dpe_id = f8
    1 cur_mode = vc
    1 cur_itin_dpe_id = f8
    1 cur_appl_id = f8
    1 cur_method = vc
    1 cur_dpe_status = vc
    1 cur_install_event = vc
  )
  SET dipm_misc_data->install_plan_id = 0.0
  SET dipm_misc_data->cur_dpe_id = 0.0
  SET dipm_misc_data->cur_mode = "DM2NOTSET"
  SET dipm_misc_data->cur_itin_dpe_id = 0.0
  SET dipm_misc_data->cur_appl_id = 0.0
  SET dipm_misc_data->cur_method = "DM2NOTSET"
  SET dipm_misc_data->cur_dpe_status = "DM2NOTSET"
  SET dipm_misc_data->cur_install_event = "DM2NOTSET"
 ENDIF
 DECLARE parallelsize = i4 WITH protect, noconstant(0)
 DECLARE childsize = i4 WITH protect, noconstant(0)
 DECLARE infonamesize = i4 WITH protect, noconstant(0)
 DECLARE invalid_choice = i2 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE lvalidx = i4 WITH protect, noconstant(0)
 DECLARE text_string = vc WITH protect, noconstant("")
 DECLARE chosen = c2 WITH protect
 DECLARE all_ind = i2 WITH protect, noconstant(0)
 DECLARE num = i4
 DECLARE r_id = vc WITH protect, noconstant("")
 DECLARE domain = vc WITH protect, noconstant("")
 DECLARE cur_id_str = vc WITH protect, noconstant("")
 DECLARE status_str = vc WITH protect, noconstant("")
 DECLARE last_time_str = vc WITH protect, noconstant("")
 DECLARE rate = f8 WITH protect, noconstant(0.0)
 DECLARE mins_estimate = f8 WITH protect, noconstant(0.0)
 DECLARE mins_elapsed = f8 WITH protect, noconstant(0.0)
 DECLARE mins_elapsed_str = vc WITH protect, noconstant("")
 DECLARE num_days = i4 WITH protect, noconstant(0)
 DECLARE num_hours = i4 WITH protect, noconstant(0)
 DECLARE num_mins = i4 WITH protect, noconstant(0)
 DECLARE num_secs = f4 WITH protect, noconstant(0.0)
 DECLARE num_days_str = vc WITH protect, noconstant("")
 DECLARE num_hours_str = vc WITH protect, noconstant("")
 DECLARE num_mins_str = vc WITH protect, noconstant("")
 DECLARE num_secs_str = vc WITH protect, noconstant("")
 DECLARE min_val_str = vc WITH protect, noconstant("")
 DECLARE max_val_str = vc WITH protect, noconstant("")
 DECLARE id_column_str = vc WITH protect, noconstant("")
 DECLARE percent_val = f4 WITH protect, noconstant(0.0)
 DECLARE percent_val_str = vc WITH protect, noconstant("")
 DECLARE bad_batch_ind = i2 WITH protect, noconstant(0)
 DECLARE done_ind = i2 WITH protect, noconstant(0)
 DECLARE batches_done_str = vc WITH protect, noconstant("")
 DECLARE batches_total_str = vc WITH protect, noconstant("")
 DECLARE batch_hours = i4 WITH protect, noconstant(0)
 DECLARE batch_mins = i4 WITH protect, noconstant(0)
 DECLARE batch_secs = f4 WITH protect, noconstant(0.0)
 DECLARE batch_hours_str = vc WITH protect, noconstant("")
 DECLARE batch_mins_str = vc WITH protect, noconstant("")
 DECLARE batch_secs_str = vc WITH protect, noconstant("")
 DECLARE days_left = i4 WITH protect, noconstant(0)
 DECLARE hours_left = i4 WITH protect, noconstant(0)
 DECLARE mins_left = i4 WITH protect, noconstant(0)
 DECLARE secs_left = f4 WITH protect, noconstant(0.0)
 DECLARE days_left_str = vc WITH protect, noconstant("")
 DECLARE hours_left_str = vc WITH protect, noconstant("")
 DECLARE mins_left_str = vc WITH protect, noconstant("")
 DECLARE secs_left_str = vc WITH protect, noconstant("")
 DECLARE min_hours = i4 WITH protect, noconstant(0)
 DECLARE min_mins = i4 WITH protect, noconstant(0)
 DECLARE min_secs = f4 WITH protect, noconstant(0.0)
 DECLARE min_hours_str = vc WITH protect, noconstant("")
 DECLARE min_mins_str = vc WITH protect, noconstant("")
 DECLARE min_secs_str = vc WITH protect, noconstant("")
 DECLARE max_hours = i4 WITH protect, noconstant(0)
 DECLARE max_mins = i4 WITH protect, noconstant(0)
 DECLARE max_secs = f4 WITH protect, noconstant(0.0)
 DECLARE max_hours_str = vc WITH protect, noconstant("")
 DECLARE max_mins_str = vc WITH protect, noconstant("")
 DECLARE max_secs_str = vc WITH protect, noconstant("")
 DECLARE avg_time = f8 WITH protect, noconstant(0.0)
 DECLARE avg_hours = i4 WITH protect, noconstant(0)
 DECLARE avg_mins = i4 WITH protect, noconstant(0)
 DECLARE avg_secs = f4 WITH protect, noconstant(0.0)
 DECLARE avg_hours_str = vc WITH protect, noconstant("")
 DECLARE avg_mins_str = vc WITH protect, noconstant("")
 DECLARE avg_secs_str = vc WITH protect, noconstant("")
 DECLARE std_hours = i4 WITH protect, noconstant(0)
 DECLARE std_mins = i4 WITH protect, noconstant(0)
 DECLARE std_secs = f4 WITH protect, noconstant(0.0)
 DECLARE std_hours_str = vc WITH protect, noconstant("")
 DECLARE std_mins_str = vc WITH protect, noconstant("")
 DECLARE std_secs_str = vc WITH protect, noconstant("")
 DECLARE num_done = i2 WITH protect, noconstant(0)
 DECLARE last_time = f4 WITH protect, noconstant(0.0)
 DECLARE last_time_left = f4 WITH protect, noconstant(0.0)
 DECLARE last_percent = f4 WITH protect, noconstant(0.0)
 DECLARE percent_sum = f8 WITH protect, noconstant(0.0)
 DECLARE max_eval_cnt = i2 WITH protect, noconstant(0)
 DECLARE mult_parserstmt = vc WITH protect, noconstant("")
 FREE RECORD parallels
 RECORD parallels(
   1 list[*]
     2 info_domain = vc
     2 info_names[*]
       3 info_name = vc
     2 parent_id = f8
     2 exists_ind = i2
     2 success_ind = i2
     2 id_column = vc
     2 multiple_ind = i2
     2 child_list[*]
       3 readme_id = f8
 )
 FREE RECORD qualifiers
 RECORD qualifiers(
   1 list[*]
     2 index = i4
 )
 FREE RECORD copy_requestin
 RECORD copy_requestin(
   1 list_0[*]
     2 parent_id = f8
     2 child_id = f8
     2 info_domain = vc
     2 info_name = vc
     2 id_column = vc
     2 multiple_ind = i2
 ) WITH public
 EXECUTE dm_dbimport "cer_install:dm_parallel_data.csv", "dm_load_parallel_reports", 250
 IF ((readme_data->status="F"))
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  parent_readme_id = copy_requestin->list_0[d.seq].parent_id, child_id = copy_requestin->list_0[d.seq
  ].child_id
  FROM (dummyt d  WITH seq = value(size(copy_requestin->list_0,5)))
  ORDER BY parent_readme_id, child_id
  HEAD parent_readme_id
   parallelsize = (parallelsize+ 1), stat = alterlist(parallels->list,parallelsize), parallels->list[
   parallelsize].parent_id = copy_requestin->list_0[d.seq].parent_id,
   parallels->list[parallelsize].info_domain = copy_requestin->list_0[d.seq].info_domain, parallels->
   list[parallelsize].id_column = copy_requestin->list_0[d.seq].id_column, parallels->list[
   parallelsize].multiple_ind = copy_requestin->list_0[d.seq].multiple_ind,
   childsize = 0, infonamesize = 0
  DETAIL
   IF (locateval(lvalidx,1,infonamesize,copy_requestin->list_0[d.seq].info_name,parallels->list[
    parallelsize].info_names[lvalidx].info_name)=0)
    infonamesize = (infonamesize+ 1), stat = alterlist(parallels->list[parallelsize].info_names,
     infonamesize), parallels->list[parallelsize].info_names[infonamesize].info_name = copy_requestin
    ->list_0[d.seq].info_name
   ENDIF
   childsize = (childsize+ 1), stat = alterlist(parallels->list[parallelsize].child_list,childsize),
   parallels->list[parallelsize].child_list[childsize].readme_id = copy_requestin->list_0[d.seq].
   child_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM dm_ocd_log dol,
   (dummyt d  WITH seq = value(size(parallels->list,5)))
  PLAN (d)
   JOIN (dol
   WHERE (dol.environment_id=
   (SELECT
    di.info_number
    FROM dm_info di
    WHERE di.info_domain="DATA MANAGEMENT"
     AND di.info_name="DM_ENV_ID"))
    AND dol.project_type="README"
    AND dol.project_name=cnvtstring(parallels->list[d.seq].parent_id))
  DETAIL
   IF ((dipm_misc_data->install_plan_id > 0))
    IF (((dol.ocd * - (1))=dipm_misc_data->install_plan_id))
     parallels->list[d.seq].exists_ind = 1
    ENDIF
   ELSE
    parallels->list[d.seq].exists_ind = 1
   ENDIF
   IF (dol.status="SUCCESS")
    parallels->list[d.seq].success_ind = 1
   ENDIF
  WITH nocounter
 ;end select
#main
 SET width = 132
 CALL clear(1,1)
 CALL video(n)
 CALL clear(2,2,128)
 CALL clear(3,2,128)
 CALL text(2,60,"Parallel Readme Statistics")
 CALL video(l)
 CALL text(5,4,"Choose a set of parallel readmes (ID listed is the parent)")
 CALL text(6,10,"1. All Parallel Sets")
 SET num_per_col = 13
 SET cnt = 0
 SET loop_cnt = 1
 SET column = 10
 FOR (loop_cnt = 1 TO size(parallels->list,5))
   IF ((parallels->list[loop_cnt].exists_ind=1))
    SET cnt = (cnt+ 1)
    IF (cnt >= num_per_col)
     SET column = 45
    ENDIF
    IF ((cnt >= (2 * num_per_col)))
     SET column = 80
    ENDIF
    SET text_string = trim(concat(build((cnt+ 1)),". ",trim(cnvtstring(parallels->list[loop_cnt].
        parent_id))))
    SET stat = alterlist(qualifiers->list,(cnt+ 1))
    SET qualifiers->list[(cnt+ 1)].index = loop_cnt
    IF ((parallels->list[loop_cnt].success_ind=1))
     CALL text((mod(cnt,num_per_col)+ 6),column,text_string)
    ELSE
     CALL text((mod(cnt,num_per_col)+ 6),column,concat(text_string," **NO STATS**"))
    ENDIF
   ENDIF
 ENDFOR
 CALL text((num_per_col+ 7),10,"0. Exit")
 IF (invalid_choice=1)
  CALL text((num_per_col+ 8),10,"Invalid Selection.")
  SET invalid_choice = 0
 ENDIF
 CALL video(n)
 CALL box(1,1,24,130)
 CALL video(l)
 CALL text((num_per_col+ 9),10,"Make a selection:")
 CALL accept((num_per_col+ 9),41,"XX;CU","1")
 SET chosen = curaccept
 IF (chosen="0")
  GO TO exit_program
 ELSEIF ((cnvtint(chosen) > (cnt+ 1)))
  SET invalid_choice = 1
  GO TO main
 ENDIF
 CALL text((num_per_col+ 10),10,"Summary(1), Standard(2), or Full(3) statistics:")
 CALL accept((num_per_col+ 10),58,"9",1)
 SET style = curaccept
 IF (style != 1
  AND style != 2
  AND style != 3)
  SET invalid_choice = 1
  GO TO main
 ENDIF
 IF (chosen="1")
  SET all_ind = 1
 ELSE
  SET choice = qualifiers->list[cnvtint(chosen)].index
  SET all_ind = 0
 ENDIF
 IF (all_ind=0)
  SELECT INTO "nl:"
   FROM dm_parallel_readme_stats dmp,
    (dummyt d  WITH seq = value(size(parallels->list[choice].child_list,5)))
   PLAN (d)
    JOIN (dmp
    WHERE (dmp.readme_id=parallels->list[choice].child_list[d.seq].readme_id))
  ;end select
  IF (curqual=0)
   SELECT
    FROM dual
    DETAIL
     col 0, "No data recorded for this readme set"
    WITH nocounter
   ;end select
   GO TO main
  ENDIF
 ELSE
  CALL echo("")
 ENDIF
 IF (style=1)
  SET col2 = 12
  SET col3 = 24
  SET col4 = 34
  SET col5 = 49
  SET col6 = 67
  SET col7 = 86
  SET col8 = 100
  IF (all_ind)
   SELECT
    parent = parallels->list[d.seq].parent_id
    FROM dm_info info1,
     dm_info info2,
     dm_parallel_readme_stats stats,
     (dummyt d  WITH seq = value(size(parallels->list,5)))
    PLAN (d
     WHERE (parallels->list[d.seq].exists_ind=1))
     JOIN (info1
     WHERE (info1.info_domain=parallels->list[d.seq].info_domain))
     JOIN (info2
     WHERE info1.info_domain=info2.info_domain
      AND expand(num,1,size(parallels->list[d.seq].child_list,5),info2.info_number,parallels->list[d
      .seq].child_list[num].readme_id))
     JOIN (stats
     WHERE stats.readme_id=info2.info_number
      AND stats.range_name=info1.info_name)
    ORDER BY parent, stats.readme_id, info1.info_name
    HEAD parent
     r_id = build(cnvtint(parent)), domain = build(info2.info_domain), col 0,
     "<PARENT README ID ", r_id, " - DOMAIN:'",
     domain, "'>", row + 1,
     col 0, "README ID", col col2,
     "STATUS", col col3, "PROGRESS",
     col col4, "ELAPSED (MIN)", col col5,
     "EST REMAIN (MIN)", col col6, "LAST UPDATE",
     col col7, "CURR ID VAL", col col8,
     "RANGE VALUES", row + 1
    HEAD info1.info_name
     r_id = build(cnvtint(stats.readme_id)), min_max_str = info2.info_char, end_pos = findstring(
      ":max:",min_max_str),
     max_val = cnvtreal(substring((end_pos+ 5),textlen(min_max_str),min_max_str)), pos = (findstring(
      "min:",min_max_str)+ 4), min_val = cnvtreal(substring(pos,(end_pos - pos),min_max_str)),
     min_val_str = trim(format(min_val,"################.#"),3), max_val_str = trim(format(max_val,
       "################.#"),3), ids_processed = ((info1.info_number - min_val)+ 1.0),
     cur_id_str = trim(format(info1.info_number,"################.#"),3)
     IF (info1.info_number=max_val)
      mins_left_str = "DONE", percent_val_str = "100.00%", status_str = "COMPLETE"
     ELSEIF (stats.total_elapsed_tm > 0.0)
      rate = (ids_processed/ stats.total_elapsed_tm), ids_to_process = ((max_val - min_val)+ 1.0),
      ids_remaining = (ids_to_process - ids_processed)
      IF (ids_to_process > 0.0)
       percent_val = ((ids_processed/ ids_to_process) * 100.0), percent_val_str = concat(trim(format(
          percent_val,"###.##"),3),"%")
      ENDIF
      mins_estimate = ((ids_remaining/ rate)/ 60.0), mins_left_str = trim(format(mins_estimate,
        "################.#"),3), status_str = "RUNNING"
     ELSE
      mins_left_str = "", percent_val_str = "", status_str = "NOT STARTED"
     ENDIF
     mins_elapsed = (stats.total_elapsed_tm/ 60.0), mins_elapsed_str = trim(format(mins_elapsed,
       "################.##"),3), last_time_str = format(stats.updt_dt_tm,"MM/DD/YY HH:MM:SS;;Q"),
     col 0, r_id, col col2,
     status_str, col col3, percent_val_str,
     col col4, mins_elapsed_str, col col5,
     mins_left_str, col col6, last_time_str,
     col col7, cur_id_str, col col8,
     min_val_str, " to ", max_val_str,
     row + 1
    FOOT  parent
     row + 1
    WITH nocounter, maxcol = 2000, nullreport,
     noheading
   ;end select
  ELSE
   SELECT
    FROM dm_info info1,
     dm_info info2,
     dm_parallel_readme_stats stats
    WHERE (info1.info_domain=parallels->list[choice].info_domain)
     AND info1.info_domain=info2.info_domain
     AND expand(num,1,size(parallels->list[choice].child_list,5),info2.info_number,parallels->list[
     choice].child_list[num].readme_id)
     AND stats.readme_id=info2.info_number
     AND stats.range_name=info1.info_name
    ORDER BY stats.readme_id, info1.info_name
    HEAD REPORT
     r_id = build(cnvtint(parallels->list[choice].parent_id)), domain = build(info2.info_domain), col
      0,
     "<PARENT README ID ", r_id, " - DOMAIN:'",
     domain, "'>", row + 1,
     col 0, "README ID", col col2,
     "STATUS", col col3, "PROGRESS",
     col col4, "ELAPSED (MIN)", col col5,
     "EST REMAIN (MIN)", col col6, "LAST UPDATE",
     col col7, "CURR ID VAL", col col8,
     "RANGE VALUES", row + 1
    HEAD info1.info_name
     r_id = build(cnvtint(stats.readme_id)), min_max_str = info2.info_char, end_pos = findstring(
      ":max:",min_max_str),
     max_val = cnvtreal(substring((end_pos+ 5),textlen(min_max_str),min_max_str)), pos = (findstring(
      "min:",min_max_str)+ 4), min_val = cnvtreal(substring(pos,(end_pos - pos),min_max_str)),
     min_val_str = trim(format(min_val,"################.#"),3), max_val_str = trim(format(max_val,
       "################.#"),3), ids_processed = ((info1.info_number - min_val)+ 1.0),
     cur_id_str = trim(format(info1.info_number,"################.#"),3)
     IF (info1.info_number=max_val)
      mins_left_str = "DONE", percent_val_str = "100.00%", status_str = "COMPLETE"
     ELSEIF (stats.total_elapsed_tm > 0.0)
      rate = (ids_processed/ stats.total_elapsed_tm), ids_to_process = ((max_val - min_val)+ 1.0),
      ids_remaining = (ids_to_process - ids_processed)
      IF (ids_to_process > 0.0)
       percent_val = ((ids_processed/ ids_to_process) * 100.0), percent_val_str = concat(trim(format(
          percent_val,"###.##"),3),"%")
      ENDIF
      mins_estimate = ((ids_remaining/ rate)/ 60.0), mins_left_str = trim(format(mins_estimate,
        "################.#"),3), status_str = "RUNNING"
     ELSE
      mins_left_str = "", percent_val_str = "", status_str = ""
     ENDIF
     mins_elapsed = (stats.total_elapsed_tm/ 60.0), mins_elapsed_str = trim(format(mins_elapsed,
       "################.##"),3), last_time_str = format(stats.updt_dt_tm,"MM/DD/YY HH:MM:SS;;Q"),
     col 0, r_id, col col2,
     status_str, col col3, percent_val_str,
     col col4, mins_elapsed_str, col col5,
     mins_left_str, col col6, last_time_str,
     col col7, cur_id_str, col col8,
     min_val_str, " to ", max_val_str,
     row + 1
    WITH nocounter, maxcol = 2000, nullreport,
     noheading
   ;end select
  ENDIF
  GO TO main
 ENDIF
 IF ((parallels->list[choice].multiple_ind=1))
  SELECT INTO "nl:"
   maxevalname = parallels->list[choice].info_names[d.seq].info_name
   FROM (dummyt d  WITH seq = value(size(parallels->list[choice].info_names,5)))
   PLAN (d)
   ORDER BY maxevalname
   HEAD REPORT
    maxevalcnt = 0
   HEAD maxevalname
    maxevalcnt = (maxevalcnt+ 1)
    IF (maxevalcnt=1)
     mult_parserstmt = concat("di1.info_name = concat('",parallels->list[choice].info_names[d.seq].
      info_name," ', cnvtstring(di2.info_number))")
    ELSE
     mult_parserstmt = concat(mult_parserstmt," OR di1.info_name = concat('",parallels->list[choice].
      info_names[d.seq].info_name," ', cnvtstring(di2.info_number))")
    ENDIF
   WITH nocounter
  ;end select
  SELECT
   FROM dm_info di1,
    dm_info di2,
    dm_parallel_readme_stats dmp
   WHERE (di1.info_domain=parallels->list[choice].info_domain)
    AND di1.info_domain=di2.info_domain
    AND expand(num,1,size(parallels->list[choice].child_list,5),di2.info_number,parallels->list[
    choice].child_list[num].readme_id)
    AND parser(mult_parserstmt)
    AND dmp.readme_id=di2.info_number
    AND dmp.range_name=di1.info_name
   ORDER BY dmp.readme_id, di1.info_name
   HEAD REPORT
    cnt = 0
   HEAD dmp.readme_id
    num_done = 0, last_time = 0.0, last_time_left = 0.0,
    percent_sum = 0.0, max_eval_cnt = 0, r_id = build(cnvtint(dmp.readme_id)),
    col 0, "Readme ID: ", r_id,
    col 20, "Range Name: ", di2.info_name,
    row + 1
   HEAD di1.info_name
    cnt = (cnt+ 1), max_eval_cnt = (max_eval_cnt+ 1), min_max_str = di2.info_char,
    end_pos = findstring(":max:",min_max_str), max_val = cnvtreal(substring((end_pos+ 5),textlen(
       min_max_str),min_max_str)), pos = (findstring("min:",min_max_str)+ 4),
    min_val = cnvtreal(substring(pos,(end_pos - pos),min_max_str)), min_val_str = trim(format(min_val,
      "################.#"),3), max_val_str = trim(format(max_val,"################.#"),3),
    id_column_str = build(parallels->list[choice].id_column), time = dmp.total_elapsed_tm
    IF (last_time=0)
     last_time = time
    ENDIF
    num_days = (time/ 86400), time = (time - (num_days * 86400)), num_hours = (time/ 3600),
    time = (time - (num_hours * 3600)), num_mins = (time/ 60), num_secs = (time - (num_mins * 60)),
    num_days_str = build(num_days), num_hours_str = build(num_hours), num_mins_str = build(num_mins),
    num_secs_str = trim(format(num_secs,"##.#"),3), batch_time = dmp.last_batch_tm, batch_hours = (
    batch_time/ 3600),
    batch_time = (batch_time - (batch_hours * 3600)), batch_mins = (batch_time/ 60), batch_secs = (
    batch_time - (batch_mins * 60)),
    batch_hours_str = build(batch_hours), batch_mins_str = build(batch_mins), batch_secs_str = trim(
     format(batch_secs,"##.#"),3),
    max_eval = ((di1.info_number - min_val)+ 1.0), range_val = ((max_val - min_val)+ 1.0)
    IF (range_val=0)
     percent_val = 100
    ELSEIF (di1.info_number <= min_val)
     percent_val = 0.00
    ELSE
     percent_val = ((max_eval/ range_val) * 100)
    ENDIF
    IF (di1.info_number=max_val)
     done_ind = 1, num_done = (num_done+ 1)
    ELSE
     last_percent = percent_val, done_ind = 0
    ENDIF
    percent_sum = (percent_sum+ percent_val), batch_size = di1.info_long_id, batches_done = dmp
    .updt_cnt
    IF (((max_eval/ batches_done) != batch_size)
     AND di1.info_number != min_val)
     bad_batch_ind = 1
    ELSE
     bad_batch_ind = 0
    ENDIF
    batches_total = ceil((range_val/ batch_size)), batches_done_str = build(batches_done),
    batches_total_str = build(batches_total)
    IF (di1.info_number < min_val)
     percent_val_str = "00.0"
    ELSEIF (di1.info_number > max_val)
     percent_val_str = "100.0"
    ELSE
     percent_val_str = trim(format(percent_val,"###.##"),3)
    ENDIF
    avg_time = (dmp.total_elapsed_tm/ dmp.updt_cnt), batches_left = (batches_total - batches_done),
    time_left = (batches_left * avg_time)
    IF (last_time_left=0)
     last_time_left = time_left
    ENDIF
    days_left = (time_left/ 86400), time_left = (time_left - (days_left * 86400)), hours_left = (
    time_left/ 3600),
    time_left = (time_left - (hours_left * 3600)), mins_left = (time_left/ 60), secs_left = (
    time_left - (mins_left * 60)),
    days_left_str = build(days_left), hours_left_str = build(hours_left), mins_left_str = build(
     mins_left),
    secs_left_str = trim(format(secs_left,"##.#"),3), last_updt = format(dmp.updt_dt_tm,";;Q")
    IF (style=3)
     min_time = dmp.min_batch_tm, min_hours = (min_time/ 3600), min_time = (min_time - (min_hours *
     3600)),
     min_mins = (min_time/ 60), min_secs = (min_time - (min_mins * 60)), min_hours_str = build(
      min_hours),
     min_mins_str = build(min_mins), min_secs_str = trim(format(min_secs,"##.#"),3), max_time = dmp
     .max_batch_tm,
     max_hours = (max_time/ 3600), max_time = (max_time - (max_hours * 3600)), max_mins = (max_time/
     60),
     max_secs = (max_time - (max_mins * 60)), max_hours_str = build(max_hours), max_mins_str = build(
      max_mins),
     max_secs_str = trim(format(max_secs,"##.#"),3), avg_hours = (avg_time/ 3600), avg_time = (
     avg_time - (avg_hours * 3600)),
     avg_mins = (avg_time/ 60), avg_secs = (avg_time - (avg_mins * 60)), avg_hours_str = build(
      avg_hours),
     avg_mins_str = build(avg_mins), avg_secs_str = trim(format(avg_secs,"##.#"),3), std_dev = ((((
     dmp.updt_cnt * dmp.std_dvtn_square) - (dmp.total_elapsed_tm** 2))** 0.5)/ dmp.updt_cnt),
     std_hours = (std_dev/ 3600), std_dev = (std_dev - (std_hours * 3600)), std_mins = (std_dev/ 60),
     std_secs = (std_dev - (std_mins * 60)), std_hours_str = build(std_hours), std_mins_str = build(
      std_mins),
     std_secs_str = trim(format(std_secs,"##.#"),3)
    ENDIF
    range_str = build(dmp.range_name), row + 1, col 0,
    "Sub-range: ", range_str, row + 1,
    col 0, "ID Range: ", id_column_str,
    " ", min_val_str, " to ",
    max_val_str, row + 1, col 0,
    "Time Elapsed: ", num_days_str, " Days, ",
    num_hours_str, " Hours, ", num_mins_str,
    " Minutes, ", num_secs_str, " Seconds",
    row + 1, col 0, "Percent Complete: ",
    percent_val_str, " %", row + 1,
    col 0, "Batches Complete: ", batches_done_str,
    " out of ", batches_total_str
    IF (done_ind=0
     AND bad_batch_ind=1)
     row + 1, col 0, "WARNING: Batch data appears inconsistent"
    ENDIF
    IF (di1.info_number < min_val)
     row + 1, col 0, "WARNING: Highest ID updated by readme is lower than minimum of range!"
    ELSEIF (di1.info_number > max_val)
     row + 1, col 0, "WARNING: Highest ID updated by readme is higher than maximum of range!"
    ENDIF
    row + 1, col 0, "Duration of Last Batch: ",
    batch_hours_str, " Hours, ", batch_mins_str,
    " Minutes, ", batch_secs_str, " Seconds",
    row + 1, col 0, "Estimated Time Left: "
    IF (done_ind)
     col 21, "DONE"
    ELSE
     col 21, days_left_str, " Days, ",
     hours_left_str, " Hours, ", mins_left_str,
     " Minutes, ", secs_left_str, " Seconds"
    ENDIF
    row + 1, col 0, "Statistics current as of: ",
    last_updt
    IF (style=3)
     row + 1, col 0, "Min Batch Time: ",
     min_hours_str, " Hours, ", min_mins_str,
     " Minutes, ", min_secs_str, " Seconds",
     row + 1, col 0, "Max Batch Time: ",
     max_hours_str, " Hours, ", max_mins_str,
     " Minutes, ", max_secs_str, " Seconds",
     row + 1, col 0, "Avg Batch Time: ",
     avg_hours_str, " Hours, ", avg_mins_str,
     " Minutes, ", avg_secs_str, " Seconds",
     row + 1, col 0, "Standard Deviation: ",
     std_hours_str, " Hours, ", std_mins_str,
     " Minutes, ", std_secs_str, " Seconds"
    ENDIF
    row + 2
   FOOT  dmp.readme_id
    IF (num_done=0)
     time = last_time, time_left = ((max_eval_cnt * last_time_left)+ time)
    ELSE
     time = (time+ last_time)
    ENDIF
    percent_val = minval(100.0,(percent_sum/ max_eval_cnt)), num_days = (time/ 86400), time = (time
     - (num_days * 86400)),
    num_hours = (time/ 3600), time = (time - (num_hours * 3600)), num_mins = (time/ 60),
    num_secs = (time - (num_mins * 60)), num_days_str = build(num_days), num_hours_str = build(
     num_hours),
    num_mins_str = build(num_mins), num_secs_str = trim(format(num_secs,"##.#"),3), percent_val_str
     = build(percent_val),
    days_left = (time_left/ 86400), time_left = (time_left - (days_left * 86400)), hours_left = (
    time_left/ 3600),
    time_left = (time_left - (hours_left * 3600)), mins_left = (time_left/ 60), secs_left = (
    time_left - (mins_left * 60)),
    days_left_str = build(days_left), hours_left_str = build(hours_left), mins_left_str = build(
     mins_left),
    secs_left_str = trim(format(secs_left,"##.#"),3), row + 1, col 0,
    "Total Time Elapsed: ", col 20, num_days_str,
    " Days, ", num_hours_str, " Hours, ",
    num_mins_str, " Minutes, ", num_secs_str,
    " Seconds", row + 1, col 0,
    "Percent Complete: "
    IF (num_done < max_eval_cnt)
     col 18, percent_val_str, " %"
    ELSE
     col 18, "DONE"
    ENDIF
    row + 1, col 0, "Estimated Time Left: ",
    col 21, days_left_str, " Days, ",
    hours_left_str, " Hours, ", mins_left_str,
    " Minutes, ", secs_left_str, " Seconds",
    row + 2
   FOOT REPORT
    IF (cnt=0)
     col 0, "No data recorded for this readme set"
    ENDIF
   WITH nocounter, maxcol = 32000, nullreport,
    noheading
  ;end select
 ELSE
  SELECT
   FROM dm_info di1,
    dm_info di2,
    dm_parallel_readme_stats dmp
   WHERE (di1.info_domain=parallels->list[choice].info_domain)
    AND di1.info_domain=di2.info_domain
    AND expand(num,1,size(parallels->list[choice].child_list,5),di2.info_number,parallels->list[
    choice].child_list[num].readme_id)
    AND di1.info_name=concat(trim(parallels->list[choice].info_names[1].info_name)," ",cnvtstring(di2
     .info_number))
    AND dmp.readme_id=di2.info_number
    AND dmp.range_name=di1.info_name
   ORDER BY dmp.readme_id
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt = (cnt+ 1), min_max_str = di2.info_char, end_pos = findstring(":max:",min_max_str),
    max_val = cnvtreal(substring((end_pos+ 5),textlen(min_max_str),min_max_str)), pos = (findstring(
     "min:",min_max_str)+ 4), min_val = cnvtreal(substring(pos,(end_pos - pos),min_max_str)),
    min_val_str = trim(format(min_val,"################.#"),3), max_val_str = trim(format(max_val,
      "################.#"),3), id_column_str = build(parallels->list[choice].id_column),
    time = dmp.total_elapsed_tm, num_days = (time/ 86400), time = (time - (num_days * 86400)),
    num_hours = (time/ 3600), time = (time - (num_hours * 3600)), num_mins = (time/ 60),
    num_secs = (time - (num_mins * 60)), num_days_str = build(num_days), num_hours_str = build(
     num_hours),
    num_mins_str = build(num_mins), num_secs_str = trim(format(num_secs,"##.#"),3), batch_time = dmp
    .last_batch_tm,
    batch_hours = (batch_time/ 3600), batch_time = (batch_time - (batch_hours * 3600)), batch_mins =
    (batch_time/ 60),
    batch_secs = (batch_time - (batch_mins * 60)), batch_hours_str = build(batch_hours),
    batch_mins_str = build(batch_mins),
    batch_secs_str = trim(format(batch_secs,"##.#"),3), max_eval = ((di1.info_number - min_val)+ 1.0),
    range_val = ((max_val - min_val)+ 1.0)
    IF (range_val=0)
     percent_val = 100
    ELSEIF (di1.info_number <= min_val)
     percent_val = 0.00
    ELSE
     percent_val = ((max_eval/ range_val) * 100)
    ENDIF
    IF (percent_val >= 100.0)
     done_ind = 1
    ELSE
     done_ind = 0
    ENDIF
    batch_size = di1.info_long_id, batches_done = dmp.updt_cnt
    IF (((max_eval/ batches_done) != batch_size)
     AND di1.info_number != min_val)
     bad_batch_ind = 1
    ELSE
     bad_batch_ind = 0
    ENDIF
    batches_total = ceil((range_val/ batch_size)), batches_done_str = build(batches_done),
    batches_total_str = build(batches_total)
    IF (di1.info_number < min_val)
     percent_val_str = "00.0"
    ELSEIF (di1.info_number > max_val)
     percent_val_str = "100.0"
    ELSE
     percent_val_str = trim(format(percent_val,"###.##"),3)
    ENDIF
    avg_time = (dmp.total_elapsed_tm/ dmp.updt_cnt), batches_left = (batches_total - batches_done),
    time_left = (batches_left * avg_time),
    days_left = (time_left/ 86400), time_left = (time_left - (days_left * 86400)), hours_left = (
    time_left/ 3600),
    time_left = (time_left - (hours_left * 3600)), mins_left = (time_left/ 60), secs_left = (
    time_left - (mins_left * 60)),
    days_left_str = build(days_left), hours_left_str = build(hours_left), mins_left_str = build(
     mins_left),
    secs_left_str = trim(format(secs_left,"##.#"),3), last_updt = format(dmp.updt_dt_tm,";;Q")
    IF (style=3)
     min_time = dmp.min_batch_tm, min_hours = (min_time/ 3600), min_time = (min_time - (min_hours *
     3600)),
     min_mins = (min_time/ 60), min_secs = (min_time - (min_mins * 60)), min_hours_str = build(
      min_hours),
     min_mins_str = build(min_mins), min_secs_str = trim(format(min_secs,"##.#"),3), max_time = dmp
     .max_batch_tm,
     max_hours = (max_time/ 3600), max_time = (max_time - (max_hours * 3600)), max_mins = (max_time/
     60),
     max_secs = (max_time - (max_mins * 60)), max_hours_str = build(max_hours), max_mins_str = build(
      max_mins),
     max_secs_str = trim(format(max_secs,"##.#"),3), avg_hours = (avg_time/ 3600), avg_time = (
     avg_time - (avg_hours * 3600)),
     avg_mins = (avg_time/ 60), avg_secs = (avg_time - (avg_mins * 60)), avg_hours_str = build(
      avg_hours),
     avg_mins_str = build(avg_mins), avg_secs_str = trim(format(avg_secs,"##.#"),3), std_dev = ((((
     dmp.updt_cnt * dmp.std_dvtn_square) - (dmp.total_elapsed_tm** 2))** 0.5)/ dmp.updt_cnt),
     std_hours = (std_dev/ 3600), std_dev = (std_dev - (std_hours * 3600)), std_mins = (std_dev/ 60),
     std_secs = (std_dev - (std_mins * 60)), std_hours_str = build(std_hours), std_mins_str = build(
      std_mins),
     std_secs_str = trim(format(std_secs,"##.#"),3)
    ENDIF
    r_id = build(cnvtint(dmp.readme_id)), col 0, "Readme ID: ",
    r_id, col 20, "Range Name: ",
    di2.info_name, row + 1, col 0,
    "ID Range: ", id_column_str, " ",
    min_val_str, " to ", max_val_str,
    row + 1, col 0, "Time Elapsed: ",
    num_days_str, " Days, ", num_hours_str,
    " Hours, ", num_mins_str, " Minutes, ",
    num_secs_str, " Seconds", row + 1,
    col 0, "Percent Complete: ", percent_val_str,
    " %", row + 1, col 0,
    "Batches Complete: ", batches_done_str, " out of ",
    batches_total_str
    IF (done_ind=0
     AND bad_batch_ind=1)
     row + 1, col 0, "WARNING: Batch data appears inconsistent"
    ENDIF
    IF (di1.info_number < min_val)
     row + 1, col 0, "WARNING: Highest ID updated by readme is lower than minimum of range!"
    ELSEIF (di1.info_number > max_val)
     row + 1, col 0, "WARNING: Highest ID updated by readme is higher than maximum of range!"
    ENDIF
    row + 1, col 0, "Duration of Last Batch: ",
    batch_hours_str, " Hours, ", batch_mins_str,
    " Minutes, ", batch_secs_str, " Seconds",
    row + 1, col 0, "Estimated Time Left: "
    IF (done_ind)
     col 21, "DONE"
    ELSE
     col 21, days_left_str, " Days, ",
     hours_left_str, " Hours, ", mins_left_str,
     " Minutes, ", secs_left_str, " Seconds"
    ENDIF
    row + 1, col 0, "Statistics current as of: ",
    last_updt
    IF (style=3)
     row + 1, col 0, "Min Batch Time: ",
     min_hours_str, " Hours, ", min_mins_str,
     " Minutes, ", min_secs_str, " Seconds",
     row + 1, col 0, "Max Batch Time: ",
     max_hours_str, " Hours, ", max_mins_str,
     " Minutes, ", max_secs_str, " Seconds",
     row + 1, col 0, "Avg Batch Time: ",
     avg_hours_str, " Hours, ", avg_mins_str,
     " Minutes, ", avg_secs_str, " Seconds",
     row + 1, col 0, "Standard Deviation: ",
     std_hours_str, " Hours, ", std_mins_str,
     " Minutes, ", std_secs_str, " Seconds"
    ENDIF
    row + 2
   FOOT REPORT
    IF (cnt=0)
     col 0, "No data recorded for this readme set"
    ENDIF
   WITH nocounter, maxcol = 32000, nullreport,
    noheading
  ;end select
 ENDIF
 GO TO main
#exit_program
 CALL clear(1,1)
END GO
