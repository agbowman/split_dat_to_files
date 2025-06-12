CREATE PROGRAM dm_stat_gather_db_smry:dba
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
 DECLARE last_stat_id = f8
 DECLARE first_stat_id = f8
 DECLARE time_diff = i4
 RECORD eod(
   1 qual[*]
     2 first_stat_id = f8
     2 first_stat_dt_tm = dq8
     2 last_stat_id = f8
     2 last_stat_dt_tm = dq8
 )
 SET prev_date = cnvtdate(datetimeadd(cnvtdatetime(curdate,curtime),- (1)))
 CALL echo(prev_date)
 FREE RECORD parse
 RECORD parse(
   1 where_clause = vc
 )
 DECLARE smry_err_msg = c255
 IF (currdb="ORACLE")
  SELECT INTO "nl:"
   dm.dm_stat_snap_id
   FROM dm_stat_snaps dm,
    dm_stat_snaps_values ds
   PLAN (dm
    WHERE dm.stat_snap_dt_tm BETWEEN cnvtdatetime(prev_date,0) AND cnvtdatetime(prev_date,235959)
     AND dm.snapshot_type="DB_STATS")
    JOIN (ds
    WHERE ds.dm_stat_snap_id=dm.dm_stat_snap_id
     AND ds.stat_name=cnvtlower("LOGONS CUMULATIVE"))
   ORDER BY dm.stat_snap_dt_tm DESC
   HEAD REPORT
    logons_cnt = 0, first_time = "y", cnt = 0
   DETAIL
    IF (first_time="y")
     cnt = (cnt+ 1)
     IF (cnt > size(eod->qual,5))
      stat = alterlist(eod->qual,(cnt+ 9))
     ENDIF
     logons_cnt = ds.stat_number_val, eod->qual[cnt].last_stat_id = ds.dm_stat_snap_id, eod->qual[cnt
     ].last_stat_dt_tm = cnvtdatetime(dm.stat_snap_dt_tm),
     eod->qual[cnt].first_stat_id = ds.dm_stat_snap_id, eod->qual[cnt].first_stat_dt_tm =
     cnvtdatetime(dm.stat_snap_dt_tm), first_time = "n"
    ELSEIF (logons_cnt > ds.stat_number_val)
     logons_cnt = ds.stat_number_val, eod->qual[cnt].first_stat_id = ds.dm_stat_snap_id, eod->qual[
     cnt].first_stat_dt_tm = cnvtdatetime(dm.stat_snap_dt_tm)
    ELSE
     first_time = "y"
    ENDIF
   FOOT REPORT
    stat = alterlist(eod->qual,cnt)
   WITH nocounter
  ;end select
  IF (error(smry_err_msg,0) != 0)
   CALL esmerror(smry_err_msg,esmexit)
  ENDIF
 ELSEIF (currdb="DB2UDB")
  SELECT INTO "nl:"
   dm.dm_stat_snap_id
   FROM dm_stat_snaps dm,
    dm_stat_snaps_values ds
   PLAN (dm
    WHERE dm.stat_snap_dt_tm BETWEEN cnvtdatetime(prev_date,0) AND cnvtdatetime(prev_date,235959)
     AND dm.snapshot_type="DB_STATS")
    JOIN (ds
    WHERE ds.dm_stat_snap_id=dm.dm_stat_snap_id
     AND ds.stat_name="DB_CONN_TIME")
   ORDER BY dm.stat_snap_dt_tm DESC
   HEAD REPORT
    first_time = "y", cnt = 0
   DETAIL
    IF (first_time="y")
     cnt = (cnt+ 1)
     IF (cnt > size(eod->qual,5))
      stat = alterlist(eod->qual,(cnt+ 9))
     ENDIF
     conn_dt_tm = cnvtdatetime(ds.stat_date_dt_tm), eod->qual[cnt].last_stat_id = ds.dm_stat_snap_id,
     eod->qual[cnt].last_stat_dt_tm = cnvtdatetime(dm.stat_snap_dt_tm),
     eod->qual[cnt].first_stat_id = ds.dm_stat_snap_id, eod->qual[cnt].first_stat_dt_tm =
     cnvtdatetime(dm.stat_snap_dt_tm), first_time = "n"
    ELSEIF (conn_dt_tm=cnvtdatetime(ds.stat_date_dt_tm))
     eod->qual[cnt].first_stat_id = ds.dm_stat_snap_id, eod->qual[cnt].first_stat_dt_tm =
     cnvtdatetime(dm.stat_snap_dt_tm)
    ELSE
     first_time = "y"
    ENDIF
   FOOT REPORT
    stat = alterlist(eod->qual,cnt)
   WITH nocounter
  ;end select
  IF (error(smry_err_msg,0) != 0)
   CALL esmerror(smry_err_msg,esmexit)
  ENDIF
 ENDIF
 SET time_diff = 0
 FOR (x = 1 TO size(eod->qual,5))
  SET temp_time = datetimediff(eod->qual[x].last_stat_dt_tm,eod->qual[x].first_stat_dt_tm,4)
  IF (temp_time > time_diff)
   SET time_diff = datetimediff(eod->qual[x].last_stat_dt_tm,eod->qual[x].first_stat_dt_tm,4)
   SET first_stat_id = eod->qual[x].first_stat_id
   SET last_stat_id = eod->qual[x].last_stat_id
  ENDIF
 ENDFOR
 SET stat = alterlist(dsr->qual,1)
 SET dsr->qual[1].stat_snap_dt_tm = cnvtdatetime(curdate,curtime3)
 SET dsr->qual[1].snapshot_type = "DB_STATS_DELTA"
 SELECT INTO "nl:"
  dv.stat_number_val, dv.stat_name
  FROM dm_stat_snaps_values dv,
   dm_stat_snaps ds
  PLAN (ds
   WHERE ds.dm_stat_snap_id IN (first_stat_id, last_stat_id))
   JOIN (dv
   WHERE dv.dm_stat_snap_id=ds.dm_stat_snap_id
    AND dv.stat_type=1)
  ORDER BY dv.stat_name, ds.stat_snap_dt_tm DESC
  HEAD REPORT
   count = 0
  HEAD dv.stat_name
   count = (count+ 1)
   IF (count > size(dsr->qual[1].qual,5))
    stat = alterlist(dsr->qual[1].qual,(count+ 9))
   ENDIF
  DETAIL
   IF (ds.dm_stat_snap_id=first_stat_id)
    first_stat_nbr = dv.stat_number_val
   ELSE
    last_stat_nbr = dv.stat_number_val
   ENDIF
  FOOT  dv.stat_name
   dsr->qual[1].qual[count].stat_name = dv.stat_name, dsr->qual[1].qual[count].stat_seq = 1, dsr->
   qual[1].qual[count].stat_type = 1,
   dsr->qual[1].qual[count].stat_number_val = ((last_stat_nbr - first_stat_nbr)/ cnvtreal(time_diff))
  FOOT REPORT
   stat = alterlist(dsr->qual[1].qual,count)
  WITH nocounter
 ;end select
 IF (error(smry_err_msg,0) != 0)
  CALL esmerror(smry_err_msg,esmexit)
 ENDIF
 EXECUTE dm_stat_snaps_load
 CALL esmcheckccl("x")
#exit_program
 FREE RECORD eod
END GO
