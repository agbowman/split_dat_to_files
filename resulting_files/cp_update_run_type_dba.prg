CREATE PROGRAM cp_update_run_type:dba
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
 SET cnt_dirty = 0
 SET new_addendum_cd = 0.0
 SET new_cumaddendum_cd = 0.0
 SET new_cumulative_cd = 0.0
 SET new_cutoff_cd = 0.0
 SET new_final_cd = 0.0
 SET new_interimany_cd = 0.0
 SET new_interimcum_cd = 0.0
 SET new_periodic_cd = 0.0
 SET new_replacement_cd = 0.0
 SET new_splitcum_cd = 0.0
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE code_set=22550
   AND cv.active_ind=1
  HEAD REPORT
   do_nothing = 0
  DETAIL
   IF (cv.cdf_meaning="ADDENDUM")
    new_addendum_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="CUMULATIVE")
    new_cumulative_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="CUM ADDENDUM")
    new_cumaddendum_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="CUTOFF")
    new_cutoff_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="FINAL")
    new_final_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="INTERIM-ANY")
    new_interimany_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="INTERIM-CUM")
    new_interimcum_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="PERIODIC")
    new_periodic_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="REPLACEMENT")
    new_replacement_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="SPLIT CUM")
    new_splitcum_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  GO TO exit_script
 ENDIF
 SET old_addendum_cd = 0.0
 SET old_cumaddendum_cd = 0.0
 SET old_cumulative_cd = 0.0
 SET old_cutoff_cd = 0.0
 SET old_final_cd = 0.0
 SET old_interimany_cd = 0.0
 SET old_interimcum_cd = 0.0
 SET old_periodic_cd = 0.0
 SET old_replacement_cd = 0.0
 SET old_splitcum_cd = 0.0
 FREE RECORD old_cv
 RECORD old_cv(
   1 qual[*]
     2 code_value = f8
 )
 SET new_cum_value = 0.0
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE code_set=14119
   AND cv.active_ind=1
  HEAD REPORT
   do_nothing = 0
  DETAIL
   IF (cv.cdf_meaning="ADDENDUM")
    old_addendum_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="CUM ADDENDUM")
    old_cumaddendum_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="CUTOFF")
    old_cutoff_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="FINAL")
    old_final_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="INTERIM-ANY")
    old_interimany_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="INTERIM-CUM")
    old_interimcum_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="PERIODIC")
    old_periodic_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="REPLACEMENT")
    old_replacement_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="SPLIT CUM")
    old_splitcum_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 CALL echo(new_periodic_cd)
 CALL echo(old_periodic_cd)
 SELECT INTO "nl:"
  cr.dist_run_type_cd
  FROM chart_request cr
  WHERE ((cr.distribution_id+ 0) > 0)
   AND  NOT ( EXISTS (
  (SELECT
   cv.code_value
   FROM code_value cv
   WHERE cv.code_set=22550
    AND cv.code_value=cr.dist_run_type_cd)))
  HEAD REPORT
   cnt_dirty = 0
  DETAIL
   cnt_dirty += 1
  WITH nocounter
 ;end select
 SET statement = fillstring(200," ")
 SET co_statement = fillstring(200," ")
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=14119
   AND cv.cdf_meaning="CUM*"
   AND cv.cdf_meaning != "CUM ADDENDUM"
  HEAD REPORT
   cv_cnt = 0
  DETAIL
   cv_cnt += 1, stat = alterlist(old_cv->qual,cv_cnt), old_cv->qual[cv_cnt].code_value = cv
   .code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=22550
   AND cv.cdf_meaning="CUMULATIVE"
   AND cv.active_ind=1
  HEAD REPORT
   do_nothing = 0
  DETAIL
   new_cum_value = cv.code_value
  WITH nocounter
 ;end select
 SET old_cv_cnt = 0
 SET x = 0
 SET old_cv_cnt = size(old_cv->qual,5)
 FOR (x = 1 TO old_cv_cnt)
   CALL echo(old_cv->qual[x].code_value)
 ENDFOR
 IF (old_cv_cnt > 0)
  SET statement = build("cr.dist_run_type_cd in ( ",old_cv->qual[1].code_value)
  SET co_statement = build("co.param in (",'"',cnvtstring(old_cv->qual[1].code_value),'"')
  IF (old_cv_cnt > 1)
   FOR (x = 2 TO old_cv_cnt)
    SET statement = build(statement,",",old_cv->qual[x].code_value)
    SET co_statement = build(co_statement,",",'"',cnvtstring(old_cv->qual[x].code_value),'"')
   ENDFOR
  ENDIF
  SET statement = build(statement,")")
  SET co_statement = build(co_statement,")")
 ELSE
  SET statement = "0=1"
  SET co_statement = "0=1"
  CALL echo("no cums out there to use from old code_set")
 ENDIF
 CALL echo("statement follows")
 CALL echo(statement)
 CALL echo(co_statement)
 IF (cnt_dirty=0)
  EXECUTE FROM begin_update_co_table TO end_update_co_table
  GO TO exit_script
 ELSE
  FREE RECORD update_rec
  RECORD update_rec(
    1 qual[*]
      2 chart_request_id = f8
  )
  SET cnt_update = 0
  SELECT INTO "nl:"
   cr.chart_request_id
   FROM chart_request cr
   WHERE parser(statement)
   HEAD REPORT
    cnt_upate = 0
   DETAIL
    cnt_update += 1, stat = alterlist(update_rec->qual,cnt_update), update_rec->qual[cnt_update].
    chart_request_id = cr.chart_request_id
   WITH nocounter
  ;end select
  SET size_update = 0
  SET size_update = size(update_rec->qual,5)
  IF (new_cum_value > 0)
   UPDATE  FROM chart_request cr,
     (dummyt d  WITH seq = value(size_update))
    SET cr.dist_run_type_cd = new_cum_value
    PLAN (d)
     JOIN (cr
     WHERE (cr.chart_request_id=update_rec->qual[d.seq].chart_request_id)
      AND ((cr.distribution_id+ 0) > 0))
    WITH nocounter
   ;end update
  ENDIF
  UPDATE  FROM chart_request cr
   SET cr.dist_run_type_cd = new_addendum_cd
   WHERE cr.dist_run_type_cd=old_addendum_cd
    AND ((cr.distribution_id+ 0) > 0)
   WITH nocounter
  ;end update
  UPDATE  FROM chart_request cr
   SET cr.dist_run_type_cd = new_cumaddendum_cd
   WHERE cr.dist_run_type_cd=old_cumaddendum_cd
    AND ((cr.distribution_id+ 0) > 0)
   WITH nocounter
  ;end update
  UPDATE  FROM chart_request cr
   SET cr.dist_run_type_cd = new_cutoff_cd
   WHERE cr.dist_run_type_cd=old_cutoff_cd
    AND ((cr.distribution_id+ 0) > 0)
   WITH nocounter
  ;end update
  UPDATE  FROM chart_request cr
   SET cr.dist_run_type_cd = new_final_cd
   WHERE cr.dist_run_type_cd=old_final_cd
    AND ((cr.distribution_id+ 0) > 0)
   WITH nocounter
  ;end update
  UPDATE  FROM chart_request cr
   SET cr.dist_run_type_cd = new_interimany_cd
   WHERE cr.dist_run_type_cd=old_interimany_cd
    AND ((cr.distribution_id+ 0) > 0)
   WITH nocounter
  ;end update
  UPDATE  FROM chart_request cr
   SET cr.dist_run_type_cd = new_interimcum_cd
   WHERE cr.dist_run_type_cd=old_interimcum_cd
    AND ((cr.distribution_id+ 0) > 0)
   WITH nocounter
  ;end update
  UPDATE  FROM chart_request cr
   SET cr.dist_run_type_cd = new_periodic_cd
   WHERE cr.dist_run_type_cd=old_periodic_cd
    AND ((cr.distribution_id+ 0) > 0)
   WITH nocounter
  ;end update
  UPDATE  FROM chart_request cr
   SET cr.dist_run_type_cd = new_replacement_cd
   WHERE cr.dist_run_type_cd=old_replacement_cd
    AND ((cr.distribution_id+ 0) > 0)
   WITH nocounter
  ;end update
  UPDATE  FROM chart_request cr
   SET cr.dist_run_type_cd = new_splitcum_cd
   WHERE cr.dist_run_type_cd=old_splitcum_cd
    AND ((cr.distribution_id+ 0) > 0)
   WITH nocounter
  ;end update
  EXECUTE FROM begin_update_co_table TO end_update_co_table
 ENDIF
#begin_update_co_table
 CALL echo(build("co_statement = ",co_statement))
 UPDATE  FROM charting_operations co
  SET co.param = cnvtstring(new_cum_value)
  WHERE parser(co_statement)
 ;end update
 UPDATE  FROM charting_operations co
  SET co.param = cnvtstring(new_addendum_cd)
  WHERE co.param=cnvtstring(old_addendum_cd)
 ;end update
 UPDATE  FROM charting_operations co
  SET co.param = cnvtstring(new_cumaddendum_cd)
  WHERE co.param=cnvtstring(old_cumaddendum_cd)
 ;end update
 UPDATE  FROM charting_operations co
  SET co.param = cnvtstring(new_cutoff_cd)
  WHERE co.param=cnvtstring(old_cutoff_cd)
 ;end update
 UPDATE  FROM charting_operations co
  SET co.param = cnvtstring(new_final_cd)
  WHERE co.param=cnvtstring(old_final_cd)
 ;end update
 UPDATE  FROM charting_operations co
  SET co.param = cnvtstring(new_interimany_cd)
  WHERE co.param=cnvtstring(old_interimany_cd)
 ;end update
 UPDATE  FROM charting_operations co
  SET co.param = cnvtstring(new_interimcum_cd)
  WHERE co.param=cnvtstring(old_interimcum_cd)
 ;end update
 UPDATE  FROM charting_operations co
  SET co.param = cnvtstring(new_periodic_cd)
  WHERE co.param=cnvtstring(old_periodic_cd)
 ;end update
 UPDATE  FROM charting_operations co
  SET co.param = cnvtstring(new_replacement_cd)
  WHERE co.param=cnvtstring(old_replacement_cd)
 ;end update
 UPDATE  FROM charting_operations co
  SET co.param = cnvtstring(new_splitcum_cd)
  WHERE co.param=cnvtstring(old_splitcum_cd)
 ;end update
#end_update_co_table
#exit_script
 COMMIT
 SET readme_data->message = "Finished updating charting_operations and chart_request table"
 SET readme_data->status = "S"
 EXECUTE dm_readme_status
 COMMIT
END GO
