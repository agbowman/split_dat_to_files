CREATE PROGRAM dm_stat_db_metrics:dba
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
 DECLARE ds_cnt = i4 WITH noconstant(0)
 DECLARE ds_cnt2 = i4 WITH noconstant(0)
 DECLARE asm_exists = i2 WITH noconstant(0)
 DECLARE error_msg = c255
 SET error_msg = ""
 SET stat = alterlist(dsr->qual,1)
 SET dsr->qual[1].stat_snap_dt_tm = cnvtdatetime((curdate - 1),0)
 SET dsr->qual[1].snapshot_type = "DB_METRICS.3"
 SET stat = alterlist(dsr->qual.qual,10)
 SELECT INTO "nl:"
  result = sum(bytes)
  FROM dba_data_files
  FOOT REPORT
   dsr->qual[1].qual[1].stat_name = "DB_TOTAL_SPACE", dsr->qual[1].qual[1].stat_number_val = result,
   dsr->qual[1].qual[1].stat_type = 1
  WITH nocounter
 ;end select
 IF (error(error_msg,0) != 0)
  CALL esmerror(error_msg,esmexit)
 ENDIF
 SELECT INTO "nl:"
  result = sum(bytes)
  FROM dba_segments
  FOOT REPORT
   dsr->qual[1].qual[2].stat_name = "DB_USED_SPACE", dsr->qual[1].qual[2].stat_number_val = result,
   dsr->qual[1].qual[2].stat_type = 1
  WITH nocounter
 ;end select
 IF (error(error_msg,0) != 0)
  CALL esmerror(error_msg,esmexit)
 ENDIF
 SELECT INTO "nl:"
  result = sum((blocks * block_size))
  FROM v$archived_log
  WHERE completion_time >= cnvtdatetimeutc(cnvtdatetime((curdate - 1),0),2)
   AND completion_time <= cnvtdatetimeutc(cnvtdatetime((curdate - 1),235959),2)
   AND (dest_id=
  (SELECT
   min(dest_id)
   FROM v$archived_log
   WHERE standby_dest="NO"))
  FOOT REPORT
   dsr->qual[1].qual[3].stat_name = "DB_ARCHIVE_LOG_GROWTH", dsr->qual[1].qual[3].stat_number_val =
   result, dsr->qual[1].qual[3].stat_type = 1
  WITH nocounter
 ;end select
 IF (error(error_msg,0) != 0)
  CALL esmerror(error_msg,esmexit)
 ENDIF
 SELECT INTO "nl:"
  cnt = count(1)
  FROM dba_views
  WHERE view_name="V_$ASM_DISKGROUP"
  DETAIL
   asm_exists = cnt
  WITH nocounter
 ;end select
 IF (asm_exists)
  SELECT INTO "nl:"
   group_number, name = trim(name), sector_size,
   block_size, state, type,
   total_mb, free_mb, used_mb = (total_mb - free_mb)
   FROM v$asm_diskgroup ad
   HEAD REPORT
    ds_cnt = 4, ds_cnt2 = 0
   DETAIL
    IF (mod(ds_cnt,10)=1)
     stat = alterlist(dsr->qual[1].qual,(ds_cnt+ 9))
    ENDIF
    dsr->qual[1].qual[ds_cnt].stat_name = "DB_ASM_DISKGROUPS", dsr->qual[1].qual[ds_cnt].
    stat_clob_val = build(name,"||",ad.total_mb,"||",ad.free_mb,
     "||",used_mb,"||",ad.group_number,"||",
     ad.sector_size,"||",ad.block_size,"||",ad.state,
     "||",ad.type), dsr->qual[1].qual[ds_cnt].stat_type = 1,
    dsr->qual[1].qual[ds_cnt].stat_seq = ds_cnt2, ds_cnt = (ds_cnt+ 1), ds_cnt2 = (ds_cnt2+ 1)
   FOOT REPORT
    IF (ds_cnt2=0)
     dsr->qual[1].qual[ds_cnt].stat_str_val = "NO_ASM_CONFIGURED", dsr->qual[1].qual[ds_cnt].
     stat_type = 1, ds_cnt = (ds_cnt+ 1)
    ENDIF
   WITH nocounter, nullreport
  ;end select
  IF (error(error_msg,0) != 0)
   CALL esmerror(error_msg,esmexit)
  ENDIF
 ELSE
  SET ds_cnt = 4
  SET dsr->qual[1].qual[ds_cnt].stat_str_val = "NO_ASM_CONFIGURED"
  SET dsr->qual[1].qual[ds_cnt].stat_type = 1
  SET ds_cnt = (ds_cnt+ 1)
 ENDIF
 SELECT INTO "nl:"
  type = "DATA", name = ddf.tablespace_name, data_bytes = sum(ddf.bytes)
  FROM dba_data_files ddf
  GROUP BY ddf.tablespace_name
  HAVING ((1=1) UNION (
   (SELECT
    type = "TEMPS", name = "N/A", data_bytes = sum(dtf.bytes)
    FROM dba_temp_files dtf
    HAVING ((1=1) UNION (
     (SELECT
      type = "LOGS", name = "N/A", data_bytes = sum(vl.bytes)
      FROM v$log vl))) )))
  HEAD REPORT
   ds_cnt2 = 0
  DETAIL
   IF (mod(ds_cnt,10)=1)
    stat = alterlist(dsr->qual[1].qual,(ds_cnt+ 9))
   ENDIF
   dsr->qual[1].qual[ds_cnt].stat_name = "DB_DATAFILES", dsr->qual[1].qual[ds_cnt].stat_str_val =
   build(type,"||",name,"||",data_bytes), dsr->qual[1].qual[ds_cnt].stat_type = 1,
   dsr->qual[1].qual[ds_cnt].stat_seq = ds_cnt2, ds_cnt = (ds_cnt+ 1), ds_cnt2 = (ds_cnt2+ 1)
  WITH nocounter, rdbunion
 ;end select
 SET stat = alterlist(dsr->qual[1].qual,(ds_cnt - 1))
 EXECUTE dm_stat_snaps_load
END GO
