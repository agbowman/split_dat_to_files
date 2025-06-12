CREATE PROGRAM dm_stat_gather_dbconfig:dba
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
 RECORD dsr_request(
   1 from_stat_snap_dt_tm = dq8
   1 to_stat_snap_dt_tm = dq8
   1 client_mnemonic = vc
   1 domain_name = vc
   1 node_name = vc
   1 qual[*]
     2 snapshot_type = vc
 )
 RECORD dsr_reply(
   1 qual[*]
     2 stat_snap_dt_tm = dq8
     2 dm_stat_snap_id = f8
     2 snapshot_type = vc
     2 client_mnemonic = vc
     2 domain_name = vc
     2 node_name = vc
     2 qual[*]
       3 stat_name = vc
       3 stat_seq = i4
       3 stat_str_val = vc
       3 stat_type = i4
       3 stat_number_val = f8
       3 stat_date_val = dq8
       3 stat_clob_val = vc
 )
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
 DECLARE mystat = i4 WITH noconstant(0)
 DECLARE x = i4
 DECLARE error_msg = vc WITH noconstant("")
 SET mystat = alterlist(dsr->qual,2)
 SET dsr->qual[1].snapshot_type = "DB_CONFIG"
 SET dsr->qual[1].stat_snap_dt_tm = cnvtdatetime((curdate - 1),000000)
 SET mystat = alterlist(dsr->qual[1].qual,1)
 SET dsr->qual[2].snapshot_type = "SEQUENCE_VALUE_CHECK"
 SET dsr->qual[2].stat_snap_dt_tm = cnvtdatetime((curdate - 1),000000)
 SET mystat = alterlist(dsr->qual[2].qual,1)
 SELECT INTO "nl:"
  oraversion = version
  FROM v$instance
  DETAIL
   dsr->qual[1].qual[1].stat_name = "ORACLE VERSION", dsr->qual[1].qual[1].stat_type = 2, dsr->qual[1
   ].qual[1].stat_str_val = oraversion
  WITH nocounter
 ;end select
 IF (error(error_msg,0) != 0)
  CALL esmerror(error_msg,esmreturn)
 ENDIF
 SELECT INTO "nl:"
  p.name, p.value
  FROM v$parameter p
  HEAD REPORT
   x = 1
  DETAIL
   IF (x=size(dsr->qual[1].qual,5))
    stat = alterlist(dsr->qual[1].qual,(x+ 10))
   ENDIF
   x = (x+ 1), dsr->qual[1].qual[x].stat_name = p.name, dsr->qual[1].qual[x].stat_type = 2,
   dsr->qual[1].qual[x].stat_str_val = p.value
  FOOT REPORT
   mystat = alterlist(dsr->qual[1].qual,x)
  WITH nocounter
 ;end select
 IF (error(error_msg,0) != 0)
  CALL esmerror(error_msg,esmreturn)
 ENDIF
 SELECT INTO "nl:"
  seq_name = s.sequence_name, seq_last_number = (s.last_number - s.cache_size)
  FROM user_sequences s
  WHERE s.last_number > 1
  HEAD REPORT
   x = 0
  DETAIL
   IF (x=size(dsr->qual[2].qual,5))
    stat = alterlist(dsr->qual[2].qual,(x+ 10))
   ENDIF
   IF (seq_last_number > 0)
    x = (x+ 1), dsr->qual[2].qual[x].stat_name = seq_name, dsr->qual[2].qual[x].stat_number_val =
    seq_last_number,
    dsr->qual[2].qual[x].stat_type = 1
   ENDIF
  FOOT REPORT
   mystat = alterlist(dsr->qual[2].qual,x)
  WITH nocounter
 ;end select
 IF (error(error_msg,0) != 0)
  CALL esmerror(error_msg,esmexit)
 ENDIF
 FOR (x = 1 TO size(dsr->qual[2].qual,5))
   IF ((dsr->qual[2].qual[x].stat_number_val > 0))
    INSERT  FROM dm_info
     SET info_domain = concat("RDDS SEQ MATCH:",dsr->qual[2].qual[x].stat_name), info_name = format(
       curdate,"YYYYMM;;D"), info_number = cnvtint(dsr->qual[2].qual[x].stat_number_val),
      info_date = cnvtdatetime(curdate,0), updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id =
      reqinfo->updt_id,
      updt_task = reqinfo->updt_task, updt_applctx = reqinfo->updt_applctx, updt_cnt = 0
    ;end insert
   ENDIF
 ENDFOR
 IF (error(error_msg,0) != 0)
  CALL esmerror(error_msg,esmreturn)
 ENDIF
 EXECUTE dm_stat_snaps_load
 CALL esmcheckccl("x")
#exit_program
END GO
