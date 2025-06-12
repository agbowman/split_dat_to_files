CREATE PROGRAM dm_stat_gather_sql_smry:dba
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
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE batch_size = i4 WITH protect, noconstant(0)
 DECLARE nstart = i4 WITH protect, noconstant(0)
 DECLARE cur_list_size = i4 WITH protect, noconstant(0)
 DECLARE loop_cnt = i4 WITH protect, noconstant(0)
 DECLARE new_list_size = i4 WITH protect, noconstant(0)
 DECLARE num1 = i4 WITH protect, noconstant(0)
 DECLARE error_msg = vc WITH noconstant("")
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE mystat = i4 WITH noconstant(0)
 FREE RECORD temp_dsr
 RECORD temp_dsr(
   1 qual[*]
     2 dm_stat_snap_id = f8
     2 stat_name = vc
 )
 SET prev_date = cnvtdate(datetimeadd(cnvtdatetime(curdate,curtime),- (1)))
 SET mystat = alterlist(dsr->qual,1)
 SET dsr->qual[1].snapshot_type = "TOP_SQL_SMRY"
 SET dsr->qual[1].stat_snap_dt_tm = cnvtdatetime((curdate - 1),0)
 SELECT INTO "nl:"
  FROM dm_stat_snaps ds,
   dm_stat_snaps_values dv
  PLAN (ds
   WHERE ds.snapshot_type="TOP_SQL_DELTAS"
    AND ds.stat_snap_dt_tm BETWEEN cnvtdatetime(prev_date,0) AND cnvtdatetime(prev_date,235959))
   JOIN (dv
   WHERE ds.dm_stat_snap_id=dv.dm_stat_snap_id
    AND dv.stat_seq=0
    AND dv.stat_type=1)
  ORDER BY dv.stat_name, dv.stat_number_val DESC
  HEAD REPORT
   snap_cnt = 0
  HEAD dv.stat_name
   snap_cnt = (snap_cnt+ 1)
   IF (mod(snap_cnt,50)=1)
    mystat = alterlist(temp_dsr->qual,(snap_cnt+ 49))
   ENDIF
   temp_dsr->qual[snap_cnt].stat_name = dv.stat_name, temp_dsr->qual[snap_cnt].dm_stat_snap_id = dv
   .dm_stat_snap_id
  FOOT REPORT
   mystat = alterlist(temp_dsr->qual,snap_cnt)
  WITH nocounter
 ;end select
 IF (error(error_msg,0) != 0)
  CALL esmerror(error_msg,esmexit)
 ENDIF
 IF (curqual=0)
  CALL esmerror("ERROR: TOP_SQL_DELTAS data doesn't exist",esmexit)
 ENDIF
 IF (((((currev * 10000)+ (currevminor * 100))+ currevminor2) >= 080204))
  SET batch_size = 25
  SET nstart = 1
  SET cur_list_size = size(temp_dsr->qual,5)
  SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
  SET new_list_size = (loop_cnt * batch_size)
  SET num1 = 0
  SET mystat = alterlist(temp_dsr->qual,new_list_size)
  FOR (idx = (cur_list_size+ 1) TO new_list_size)
   SET temp_dsr->qual[idx].dm_stat_snap_id = temp_dsr->qual[cur_list_size].dm_stat_snap_id
   SET temp_dsr->qual[idx].stat_name = temp_dsr->qual[cur_list_size].stat_name
  ENDFOR
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(loop_cnt)),
    dm_stat_snaps_values dv
   PLAN (d1
    WHERE assign(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
    JOIN (dv
    WHERE expand(num1,nstart,(nstart+ (batch_size - 1)),dv.dm_stat_snap_id,temp_dsr->qual[num1].
     dm_stat_snap_id,
     dv.stat_name,temp_dsr->qual[num1].stat_name)
     AND ((dv.stat_seq=0
     AND dv.stat_type=1) OR (dv.stat_seq > 7
     AND dv.stat_type=2)) )
   ORDER BY dv.stat_name, dv.stat_seq
   HEAD REPORT
    cnt = 0
   DETAIL
    IF (cnt=size(dsr->qual[1].qual,5))
     mystat = alterlist(dsr->qual[1].qual,(cnt+ 100))
    ENDIF
    cnt = (cnt+ 1)
    IF (dv.stat_seq=0)
     dsr->qual[1].qual[cnt].stat_number_val = dv.stat_number_val, dsr->qual[1].qual[cnt].stat_name =
     dv.stat_name, dsr->qual[1].qual[cnt].stat_seq = dv.stat_seq,
     dsr->qual[1].qual[cnt].stat_type = 1
    ELSE
     dsr->qual[1].qual[cnt].stat_str_val = dv.stat_str_val, dsr->qual[1].qual[cnt].stat_name = dv
     .stat_name, dsr->qual[1].qual[cnt].stat_seq = dv.stat_seq,
     dsr->qual[1].qual[cnt].stat_type = 2
    ENDIF
   FOOT REPORT
    mystat = alterlist(dsr->qual[1].qual,cnt)
   WITH nocounter
  ;end select
  IF (error(error_msg,0) != 0)
   CALL esmerror(error_msg,esmexit)
  ENDIF
 ELSE
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(size(temp_dsr->qual,5))),
    dm_stat_snaps_values dv
   PLAN (d)
    JOIN (dv
    WHERE (dv.dm_stat_snap_id=temp_dsr->qual[d.seq].dm_stat_snap_id)
     AND (dv.stat_name=temp_dsr->qual[d.seq].stat_name)
     AND ((dv.stat_seq=0
     AND dv.stat_type=1) OR (dv.stat_seq > 7
     AND dv.stat_type=2)) )
   ORDER BY dv.stat_name, dv.stat_seq
   HEAD REPORT
    cnt = 0
   DETAIL
    IF (cnt=size(dsr->qual[1].qual,5))
     mystat = alterlist(dsr->qual[1].qual,(cnt+ 100))
    ENDIF
    cnt = (cnt+ 1)
    IF (dv.stat_seq=0)
     dsr->qual[1].qual[cnt].stat_number_val = dv.stat_number_val, dsr->qual[1].qual[cnt].stat_name =
     dv.stat_name, dsr->qual[1].qual[cnt].stat_seq = dv.stat_seq,
     dsr->qual[1].qual[cnt].stat_type = 1
    ELSE
     dsr->qual[1].qual[cnt].stat_str_val = dv.stat_str_val, dsr->qual[1].qual[cnt].stat_name = dv
     .stat_name, dsr->qual[1].qual[cnt].stat_seq = dv.stat_seq,
     dsr->qual[1].qual[cnt].stat_type = 2
    ENDIF
   FOOT REPORT
    mystat = alterlist(dsr->qual[1].qual,cnt)
   WITH nocounter
  ;end select
  IF (error(error_msg,0) != 0)
   CALL esmerror(error_msg,esmexit)
  ENDIF
 ENDIF
 EXECUTE dm_stat_snaps_load
 CALL esmcheckccl("x")
#exit_program
END GO
