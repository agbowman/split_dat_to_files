CREATE PROGRAM dm_stat_gather_sql_deltas:dba
 IF ( NOT (validate(dsr,0)))
  RECORD dsr(
    1 qual[*]
      2 stat_snap_dt_tm = dq8
      2 snapshot_type = c100
      2 client_mnemonic = c10
      2 domain_name = c20
      2 node_name = c30
      2 qual[*]
        3 stat_name = vc
        3 stat_seq = i4
        3 stat_str_val = vc
        3 stat_type = i4
        3 stat_number_val = f8
        3 stat_date_val = dq8
        3 stat_clob_val = vc
  )
 ENDIF
 DECLARE esmerror(msg=vc,ret=i2) = i2
 DECLARE esmcheckccl(z=vc) = i2
 DECLARE esmdate = f8
 DECLARE esmmsg = c196
 DECLARE esmcategory = c128
 DECLARE esmerrorcnt = i2
 SET esmexit = 0
 SET esmreturn = 1
 SET esmerrorcnt = 0
 SUBROUTINE esmerror(msg,ret)
   SET esmerrorcnt = (esmerrorcnt+ 1)
   IF (esmerrorcnt <= 3)
    SET esmdate = cnvtdatetime(curdate,curtime3)
    SET esmmsg = fillstring(196," ")
    SET esmmsg = substring(1,195,msg)
    SET esmcategory = fillstring(128," ")
    SET esmcategory = curprog
    EXECUTE dm_stat_error esmdate, esmmsg, esmcategory
    CALL echo(msg)
    CALL esmcheckccl("x")
   ELSE
    GO TO exit_program
   ENDIF
   IF (ret=esmexit)
    GO TO exit_program
   ENDIF
   SET esmerrorcnt = 0
   RETURN(esmreturn)
 END ;Subroutine
 SUBROUTINE esmcheckccl(z)
   SET cclerrmsg = fillstring(132," ")
   SET cclerrcode = error(cclerrmsg,0)
   IF (cclerrcode != 0)
    SET execrc = 1
    CALL esmerror(cclerrmsg,esmexit)
   ENDIF
   RETURN(esmreturn)
 END ;Subroutine
 FREE RECORD stat_errors
 RECORD stat_errors(
   1 errmsg = vc
   1 fail_ind = i2
 )
 FREE RECORD tempa_dsr
 RECORD tempa_dsr(
   1 qual[*]
     2 dm_stat_snap_id = f8
     2 stat_name = vc
     2 score = f8
     2 hash_value = vc
     2 executions = f8
     2 disk_reads = f8
     2 buffer_gets = f8
     2 rows_processed = f8
     2 script_name = vc
     2 score_delta = f8
     2 executions_delta = f8
     2 disk_reads_delta = f8
     2 buffer_gets_delta = f8
     2 rows_processed_delta = f8
     2 duration = f8
 )
 FREE RECORD tempb_dsr
 RECORD tempb_dsr(
   1 qual[*]
     2 dm_stat_snap_id = f8
     2 stat_name = vc
     2 score = f8
     2 executions = f8
     2 disk_reads = f8
     2 buffer_gets = f8
     2 rows_processed = f8
     2 script_name = vc
 )
 DECLARE timeperiod_a = f8 WITH noconstant(0.0)
 DECLARE timeperiod_b = f8 WITH noconstant(0.0)
 DECLARE found_ind = i2
 DECLARE time_diff = f8
 DECLARE average_score = f8
 DECLARE snap_cnt_a = i4
 DECLARE snap_cnt_b = i4
 SELECT INTO "nl:"
  FROM dm_stat_snaps s,
   (
   (
   (SELECT
    max_time = max(stat_snap_dt_tm)
    FROM dm_stat_snaps
    WHERE snapshot_type="TOP_SQL"
     AND (stat_snap_dt_tm !=
    (SELECT
     max(t.stat_snap_dt_tm)
     FROM dm_stat_snaps t
     WHERE t.snapshot_type="TOP_SQL"))
    WITH sqltype("DQ8")))
   ds)
  WHERE s.snapshot_type="TOP_SQL"
   AND s.stat_snap_dt_tm >= ds.max_time
  HEAD REPORT
   timeperiod_b = s.stat_snap_dt_tm, temp_ind = 1
  DETAIL
   IF (temp_ind=0)
    timeperiod_a = s.stat_snap_dt_tm
   ENDIF
   temp_ind = 0
  FOOT REPORT
   time_diff = datetimediff(timeperiod_a,timeperiod_b,4)
  WITH nocounter
 ;end select
 IF (error(stat_errors->errmsg,0) > 0)
  SET stat_errors->fail_ind = 1
  GO TO exit_program
 ENDIF
 IF (((timeperiod_a=0.0) OR (timeperiod_b=0.0)) )
  CALL echo("TOP_SQL data was not found")
  GO TO exit_program
 ENDIF
 SET stat = alterlist(dsr->qual,1)
 SET dsr->qual[1].snapshot_type = "TOP_SQL_DELTAS"
 SET dsr->qual[1].stat_snap_dt_tm = cnvtdatetime(timeperiod_a)
 SELECT INTO "nl:"
  FROM dm_stat_snaps ds,
   dm_stat_snaps_values dv
  PLAN (ds
   WHERE ds.snapshot_type="TOP_SQL"
    AND ds.stat_snap_dt_tm=cnvtdatetime(timeperiod_a))
   JOIN (dv
   WHERE ds.dm_stat_snap_id=dv.dm_stat_snap_id)
  ORDER BY ds.stat_snap_dt_tm, ds.snapshot_type, dv.stat_name,
   dv.stat_seq
  HEAD REPORT
   snap_cnt_a = 0
  HEAD dv.stat_name
   snap_cnt_a = (snap_cnt_a+ 1)
   IF (mod(snap_cnt_a,10)=1)
    stat = alterlist(tempa_dsr->qual,(snap_cnt_a+ 49))
   ENDIF
   tempa_dsr->qual[snap_cnt_a].stat_name = dv.stat_name, tempa_dsr->qual[snap_cnt_a].dm_stat_snap_id
    = dv.dm_stat_snap_id
  DETAIL
   IF (dv.stat_seq=0)
    tempa_dsr->qual[snap_cnt_a].score = dv.stat_number_val
   ELSEIF (dv.stat_seq=1)
    tempa_dsr->qual[snap_cnt_a].hash_value = dv.stat_str_val
   ELSEIF (dv.stat_seq=2)
    tempa_dsr->qual[snap_cnt_a].executions = dv.stat_number_val
   ELSEIF (dv.stat_seq=3)
    tempa_dsr->qual[snap_cnt_a].disk_reads = dv.stat_number_val
   ELSEIF (dv.stat_seq=4)
    tempa_dsr->qual[snap_cnt_a].buffer_gets = dv.stat_number_val
   ELSEIF (dv.stat_seq=5)
    tempa_dsr->qual[snap_cnt_a].rows_processed = dv.stat_number_val
   ELSEIF (dv.stat_seq=6)
    tempa_dsr->qual[snap_cnt_a].script_name = dv.stat_str_val
   ENDIF
  FOOT REPORT
   stat = alterlist(tempa_dsr->qual,snap_cnt_a)
  WITH nocounter
 ;end select
 IF (error(stat_errors->errmsg,0) > 0)
  SET stat_errors->fail_ind = 1
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  FROM dm_stat_snaps ds,
   dm_stat_snaps_values dv
  PLAN (ds
   WHERE ds.snapshot_type="TOP_SQL"
    AND ds.stat_snap_dt_tm=cnvtdatetime(timeperiod_b))
   JOIN (dv
   WHERE ds.dm_stat_snap_id=dv.dm_stat_snap_id)
  ORDER BY ds.stat_snap_dt_tm, ds.snapshot_type, dv.stat_name,
   dv.stat_seq
  HEAD REPORT
   snap_cnt_b = 0
  HEAD dv.stat_name
   snap_cnt_b = (snap_cnt_b+ 1)
   IF (mod(snap_cnt_b,10)=1)
    stat = alterlist(tempb_dsr->qual,(snap_cnt_b+ 49))
   ENDIF
   tempb_dsr->qual[snap_cnt_b].stat_name = dv.stat_name, tempb_dsr->qual[snap_cnt_b].dm_stat_snap_id
    = dv.dm_stat_snap_id
  DETAIL
   IF (dv.stat_seq=0)
    tempb_dsr->qual[snap_cnt_b].score = dv.stat_number_val
   ELSEIF (dv.stat_seq=2)
    tempb_dsr->qual[snap_cnt_b].executions = dv.stat_number_val
   ELSEIF (dv.stat_seq=3)
    tempb_dsr->qual[snap_cnt_b].disk_reads = dv.stat_number_val
   ELSEIF (dv.stat_seq=4)
    tempb_dsr->qual[snap_cnt_b].buffer_gets = dv.stat_number_val
   ELSEIF (dv.stat_seq=5)
    tempb_dsr->qual[snap_cnt_b].rows_processed = dv.stat_number_val
   ELSEIF (dv.stat_seq=6)
    tempb_dsr->qual[snap_cnt_b].script_name = dv.stat_str_val
   ENDIF
  FOOT REPORT
   stat = alterlist(tempb_dsr->qual,snap_cnt_b)
  WITH nocounter
 ;end select
 IF (error(stat_errors->errmsg,0) > 0)
  SET stat_errors->fail_ind = 1
  GO TO exit_program
 ENDIF
 SELECT DISTINCT INTO "nl:"
  FROM dm_stat_snaps ds,
   dm_stat_snaps_values dv
  PLAN (ds
   WHERE ds.snapshot_type="DB SCORE"
    AND ds.stat_snap_dt_tm=cnvtdatetime(timeperiod_b))
   JOIN (dv
   WHERE dv.dm_stat_snap_id=ds.dm_stat_snap_id
    AND dv.stat_name="AVERAGE DB SCORE"
    AND dv.stat_type=1)
  HEAD REPORT
   avg_cnt = 0
  DETAIL
   average_score = dv.stat_number_val
  WITH nocounter
 ;end select
 IF (error(stat_errors->errmsg,0) > 0)
  SET stat_errors->fail_ind = 1
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = snap_cnt_a),
   (dummyt d2  WITH seq = snap_cnt_b)
  PLAN (d)
   JOIN (d2
   WHERE (tempa_dsr->qual[d.seq].stat_name=tempb_dsr->qual[d2.seq].stat_name))
  DETAIL
   tempa_dsr->qual[d.seq].score_delta = ((tempa_dsr->qual[d.seq].score - tempb_dsr->qual[d2.seq].
   score)/ time_diff), tempa_dsr->qual[d.seq].executions_delta = ((tempa_dsr->qual[d.seq].executions
    - tempb_dsr->qual[d2.seq].executions)/ time_diff), tempa_dsr->qual[d.seq].disk_reads_delta = ((
   tempa_dsr->qual[d.seq].disk_reads - tempb_dsr->qual[d2.seq].disk_reads)/ time_diff),
   tempa_dsr->qual[d.seq].buffer_gets_delta = ((tempa_dsr->qual[d.seq].buffer_gets - tempb_dsr->qual[
   d2.seq].buffer_gets)/ time_diff), tempa_dsr->qual[d.seq].rows_processed_delta = ((tempa_dsr->qual[
   d.seq].rows_processed - tempb_dsr->qual[d2.seq].rows_processed)/ time_diff), tempa_dsr->qual[d.seq
   ].duration = time_diff
  WITH nocounter
 ;end select
 IF (error(stat_errors->errmsg,0) > 0)
  SET stat_errors->fail_ind = 1
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = snap_cnt_a)
  WHERE (tempa_dsr->qual[d.seq].duration=0)
  DETAIL
   tempa_dsr->qual[d.seq].score_delta = ((tempa_dsr->qual[d.seq].score - average_score)/ time_diff),
   tempa_dsr->qual[d.seq].executions_delta = (tempa_dsr->qual[d.seq].executions/ time_diff),
   tempa_dsr->qual[d.seq].disk_reads_delta = (tempa_dsr->qual[d.seq].disk_reads/ time_diff),
   tempa_dsr->qual[d.seq].buffer_gets_delta = (tempa_dsr->qual[d.seq].buffer_gets/ time_diff),
   tempa_dsr->qual[d.seq].rows_processed_delta = (tempa_dsr->qual[d.seq].rows_processed/ time_diff),
   tempa_dsr->qual[d.seq].duration = time_diff
  WITH nocounter
 ;end select
 IF (error(stat_errors->errmsg,0) > 0)
  SET stat_errors->fail_ind = 1
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = snap_cnt_a),
   dm_stat_snaps_values dv
  PLAN (d
   WHERE (tempa_dsr->qual[d.seq].score_delta >= 60000))
   JOIN (dv
   WHERE (dv.dm_stat_snap_id=tempa_dsr->qual[d.seq].dm_stat_snap_id)
    AND (dv.stat_name=tempa_dsr->qual[d.seq].stat_name)
    AND dv.stat_seq > 6)
  ORDER BY dv.stat_name, dv.stat_seq
  HEAD REPORT
   cnt = 0
  HEAD dv.stat_name
   temp_stat_seq = 7, cnt = (cnt+ 1)
   IF (mod(cnt,50)=1)
    stat = alterlist(dsr->qual[1].qual,(cnt+ 49))
   ENDIF
   dsr->qual[1].qual[cnt].stat_number_val = tempa_dsr->qual[d.seq].score_delta, dsr->qual[1].qual[cnt
   ].stat_date_val = null, dsr->qual[1].qual[cnt].stat_name = dv.stat_name,
   dsr->qual[1].qual[cnt].stat_seq = 0, dsr->qual[1].qual[cnt].stat_type = 1, cnt = (cnt+ 1)
   IF (mod(cnt,50)=1)
    stat = alterlist(dsr->qual[1].qual,(cnt+ 49))
   ENDIF
   dsr->qual[1].qual[cnt].stat_str_val = tempa_dsr->qual[d.seq].hash_value, dsr->qual[1].qual[cnt].
   stat_date_val = null, dsr->qual[1].qual[cnt].stat_name = dv.stat_name,
   dsr->qual[1].qual[cnt].stat_seq = 1, dsr->qual[1].qual[cnt].stat_type = 2, cnt = (cnt+ 1)
   IF (mod(cnt,50)=1)
    stat = alterlist(dsr->qual[1].qual,(cnt+ 49))
   ENDIF
   dsr->qual[1].qual[cnt].stat_number_val = tempa_dsr->qual[d.seq].executions_delta, dsr->qual[1].
   qual[cnt].stat_date_val = null, dsr->qual[1].qual[cnt].stat_name = dv.stat_name,
   dsr->qual[1].qual[cnt].stat_seq = 2, dsr->qual[1].qual[cnt].stat_type = 1, cnt = (cnt+ 1)
   IF (mod(cnt,50)=1)
    stat = alterlist(dsr->qual[1].qual,(cnt+ 49))
   ENDIF
   dsr->qual[1].qual[cnt].stat_number_val = tempa_dsr->qual[d.seq].disk_reads_delta, dsr->qual[1].
   qual[cnt].stat_date_val = null, dsr->qual[1].qual[cnt].stat_name = dv.stat_name,
   dsr->qual[1].qual[cnt].stat_seq = 3, dsr->qual[1].qual[cnt].stat_type = 1, cnt = (cnt+ 1)
   IF (mod(cnt,50)=1)
    stat = alterlist(dsr->qual[1].qual,(cnt+ 49))
   ENDIF
   dsr->qual[1].qual[cnt].stat_number_val = tempa_dsr->qual[d.seq].buffer_gets_delta, dsr->qual[1].
   qual[cnt].stat_date_val = null, dsr->qual[1].qual[cnt].stat_name = dv.stat_name,
   dsr->qual[1].qual[cnt].stat_seq = 4, dsr->qual[1].qual[cnt].stat_type = 1, cnt = (cnt+ 1)
   IF (mod(cnt,50)=1)
    stat = alterlist(dsr->qual[1].qual,(cnt+ 49))
   ENDIF
   dsr->qual[1].qual[cnt].stat_number_val = tempa_dsr->qual[d.seq].rows_processed_delta, dsr->qual[1]
   .qual[cnt].stat_date_val = null, dsr->qual[1].qual[cnt].stat_name = dv.stat_name,
   dsr->qual[1].qual[cnt].stat_seq = 5, dsr->qual[1].qual[cnt].stat_type = 1, cnt = (cnt+ 1)
   IF (mod(cnt,50)=1)
    stat = alterlist(dsr->qual[1].qual,(cnt+ 49))
   ENDIF
   dsr->qual[1].qual[cnt].stat_str_val = tempa_dsr->qual[d.seq].script_name, dsr->qual[1].qual[cnt].
   stat_date_val = null, dsr->qual[1].qual[cnt].stat_name = dv.stat_name,
   dsr->qual[1].qual[cnt].stat_seq = 6, dsr->qual[1].qual[cnt].stat_type = 2, cnt = (cnt+ 1)
   IF (mod(cnt,50)=1)
    stat = alterlist(dsr->qual[1].qual,(cnt+ 49))
   ENDIF
   dsr->qual[1].qual[cnt].stat_number_val = tempa_dsr->qual[d.seq].duration, dsr->qual[1].qual[cnt].
   stat_date_val = null, dsr->qual[1].qual[cnt].stat_name = dv.stat_name,
   dsr->qual[1].qual[cnt].stat_seq = 7, dsr->qual[1].qual[cnt].stat_type = 1
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,50)=1)
    stat = alterlist(dsr->qual[1].qual,(cnt+ 49))
   ENDIF
   temp_stat_seq = (temp_stat_seq+ 1), dsr->qual[1].qual[cnt].stat_str_val = dv.stat_str_val, dsr->
   qual[1].qual[cnt].stat_date_val = null,
   dsr->qual[1].qual[cnt].stat_name = dv.stat_name, dsr->qual[1].qual[cnt].stat_seq = temp_stat_seq,
   dsr->qual[1].qual[cnt].stat_type = 2
  FOOT REPORT
   stat = alterlist(dsr->qual[1].qual,cnt)
  WITH nocounter
 ;end select
 IF (error(stat_errors->errmsg,0) > 0)
  SET stat_errors->fail_ind = 1
  GO TO exit_program
 ENDIF
 EXECUTE dm_stat_snaps_load
#exit_program
 IF ((stat_errors->fail_ind=1))
  CALL esmerror(stat_errors->errmsg,esmreturn)
 ENDIF
 FREE RECORD tempa_dsr
 FREE RECORD tempb_dsr
 FREE RECORD stat_errors
END GO
