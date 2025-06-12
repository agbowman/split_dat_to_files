CREATE PROGRAM dm_stat_gather_sizing:dba
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
 DECLARE dsr_cnt = i4
 DECLARE sizing_errmsg = c255
 DECLARE sizing_flag = i2
 SET sizing_flag = 0
 SET stat = alterlist(dsr->qual,2)
 SELECT INTO "nl:"
  FROM user_tables ut
  ORDER BY ut.table_name
  HEAD REPORT
   dsr_cnt = 0, dsr->qual[1].stat_snap_dt_tm = cnvtdatetime(curdate,curtime3), dsr->qual[1].
   snapshot_type = "TABLE_SIZE_BYTES",
   dsr->qual[2].stat_snap_dt_tm = cnvtdatetime(curdate,curtime3), dsr->qual[2].snapshot_type =
   "TABLE_SIZE_ROWS"
  HEAD ut.table_name
   dsr_cnt = (dsr_cnt+ 1)
   IF (mod(dsr_cnt,50)=1)
    stat = alterlist(dsr->qual[1].qual,(dsr_cnt+ 49)), stat = alterlist(dsr->qual[2].qual,(dsr_cnt+
     49))
   ENDIF
   dsr->qual[1].qual[dsr_cnt].stat_name = trim(cnvtupper(ut.table_name),3), dsr->qual[1].qual[dsr_cnt
   ].stat_type = 1
   IF (currdb="ORACLE")
    dsr->qual[1].qual[dsr_cnt].stat_number_val = (ut.blocks * 8192)
   ELSEIF (currdb="DB2UDB")
    dsr->qual[1].qual[dsr_cnt].stat_number_val = (ut.blocks * 16384)
   ENDIF
   dsr->qual[2].qual[dsr_cnt].stat_name = trim(cnvtupper(ut.table_name),3), dsr->qual[2].qual[dsr_cnt
   ].stat_type = 1, dsr->qual[2].qual[dsr_cnt].stat_number_val = ut.num_rows
  FOOT REPORT
   stat = alterlist(dsr->qual[1].qual,dsr_cnt), stat = alterlist(dsr->qual[2].qual,dsr_cnt)
  WITH nocounter
 ;end select
 IF (error(sizing_errmsg,0) > 0)
  SET sizing_flag = 1
  GO TO exit_program
 ENDIF
 EXECUTE dm_stat_snaps_load
 CALL esmcheckccl("x")
 SELECT INTO "nl:"
  FROM user_indexes ui
  WHERE ui.last_analyzed IS NOT null
  ORDER BY ui.index_name
  HEAD REPORT
   dsr_cnt = 0, stat = alterlist(dsr->qual,2), dsr->qual[1].stat_snap_dt_tm = cnvtdatetime(curdate,
    curtime3),
   dsr->qual[1].snapshot_type = "INDEX_SIZE_LEAF_BYTES", dsr->qual[2].stat_snap_dt_tm = cnvtdatetime(
    curdate,curtime3), dsr->qual[2].snapshot_type = "INDEX_SIZE_DISTINCT_KEYS"
  HEAD ui.index_name
   dsr_cnt = (dsr_cnt+ 1)
   IF (mod(dsr_cnt,50)=1)
    stat = alterlist(dsr->qual[1].qual,(dsr_cnt+ 49)), stat = alterlist(dsr->qual[2].qual,(dsr_cnt+
     49))
   ENDIF
   dsr->qual[1].qual[dsr_cnt].stat_name = trim(cnvtupper(ui.index_name),3), dsr->qual[1].qual[dsr_cnt
   ].stat_type = 1
   IF (currdb="ORACLE")
    dsr->qual[1].qual[dsr_cnt].stat_number_val = (ui.leaf_blocks * 8192)
   ELSEIF (currdb="DB2UDB")
    dsr->qual[1].qual[dsr_cnt].stat_number_val = (ui.leaf_blocks * 16384)
   ENDIF
   dsr->qual[2].qual[dsr_cnt].stat_name = trim(cnvtupper(ui.index_name),3), dsr->qual[2].qual[dsr_cnt
   ].stat_type = 1, dsr->qual[2].qual[dsr_cnt].stat_number_val = ui.distinct_keys
  FOOT REPORT
   stat = alterlist(dsr->qual[1].qual,dsr_cnt), stat = alterlist(dsr->qual[2].qual,dsr_cnt)
  WITH nocounter
 ;end select
 IF (error(sizing_errmsg,0) > 0)
  SET sizing_flag = 1
  GO TO exit_program
 ENDIF
 EXECUTE dm_stat_snaps_load
 CALL esmcheckccl("x")
#exit_program
 IF (sizing_flag=1)
  CALL esmerror(sizing_errmsg,esmreturn)
 ENDIF
 FREE RECORD dsr
END GO
