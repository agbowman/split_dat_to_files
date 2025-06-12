CREATE PROGRAM dm_snap_stats_get:dba
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
 FREE RECORD parse
 RECORD parse(
   1 where_clause = vc
 )
 DECLARE get_err_msg = c255
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE batch_size = i4 WITH protect, noconstant(0)
 DECLARE nstart = i4 WITH protect, noconstant(0)
 DECLARE cur_list_size = i4 WITH protect, noconstant(0)
 DECLARE loop_cnt = i4 WITH protect, noconstant(0)
 DECLARE new_list_size = i4 WITH protect, noconstant(0)
 DECLARE num1 = i4 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH noconstant(0)
 IF (size(dsr_request->qual,5) > 0)
  IF ((dsr_request->client_mnemonic IN ("", null)))
   SELECT INTO "nl:"
    FROM dm_info dm
    WHERE dm.info_domain="DATA MANAGEMENT"
     AND dm.info_name="CLIENT MNEMONIC"
    DETAIL
     dsr_request->client_mnemonic = dm.info_char
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL esmerror("ERROR: No client mnemonic found on dm_info",esmexit)
   ENDIF
  ENDIF
  IF ((dsr_request->domain_name IN ("", null)))
   SET dsr_request->domain_name = reqdata->domain
  ENDIF
  IF ((dsr_request->node_name IN ("", null)))
   SET dsr_request->node_name = curnode
  ENDIF
 ENDIF
 IF (((((currev * 10000)+ (currevminor * 100))+ currevminor2) >= 080204))
  SET batch_size = 25
  SET nstart = 1
  SET cur_list_size = size(dsr_request->qual,5)
  SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
  SET new_list_size = (loop_cnt * batch_size)
  SET num1 = 0
  SET stat = alterlist(dsr_request->qual,new_list_size)
  FOR (idx = (cur_list_size+ 1) TO new_list_size)
    SET dsr_request->qual[idx].snapshot_type = dsr_request->qual[cur_list_size].snapshot_type
  ENDFOR
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(loop_cnt)),
    dm_stat_snaps ds,
    dm_stat_snaps_values dv
   PLAN (d1
    WHERE assign(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
    JOIN (ds
    WHERE (ds.client_mnemonic=dsr_request->client_mnemonic)
     AND (ds.domain_name=dsr_request->domain_name)
     AND (ds.node_name=dsr_request->node_name)
     AND ds.stat_snap_dt_tm BETWEEN cnvtdatetime(dsr_request->from_stat_snap_dt_tm) AND cnvtdatetime(
     dsr_request->to_stat_snap_dt_tm)
     AND expand(num1,nstart,(nstart+ (batch_size - 1)),ds.snapshot_type,dsr_request->qual[num1].
     snapshot_type))
    JOIN (dv
    WHERE dv.dm_stat_snap_id=ds.dm_stat_snap_id)
   ORDER BY ds.dm_stat_snap_id
   HEAD REPORT
    cnt1 = 0
   HEAD ds.dm_stat_snap_id
    cnt1 = (cnt1+ 1)
    IF (cnt1 > size(dsr_reply->qual,5))
     stat = alterlist(dsr_reply->qual,(cnt1+ 9))
    ENDIF
    dsr_reply->qual[cnt1].stat_snap_dt_tm = cnvtdatetime(ds.stat_snap_dt_tm), dsr_reply->qual[cnt1].
    dm_stat_snap_id = ds.dm_stat_snap_id, dsr_reply->qual[cnt1].snapshot_type = ds.snapshot_type,
    dsr_reply->qual[cnt1].client_mnemonic = dsr_request->client_mnemonic, dsr_reply->qual[cnt1].
    domain_name = dsr_request->domain_name, dsr_reply->qual[cnt1].node_name = dsr_request->node_name,
    cnt2 = 0
   DETAIL
    cnt2 = (cnt2+ 1)
    IF (cnt2 > size(dsr_reply->qual[cnt1].qual,5))
     stat = alterlist(dsr_reply->qual[cnt1].qual,(cnt2+ 9))
    ENDIF
    dsr_reply->qual[cnt1].qual[cnt2].stat_name = replace(dv.stat_name,'"',"'",0), dsr_reply->qual[
    cnt1].qual[cnt2].stat_seq = dv.stat_seq, dsr_reply->qual[cnt1].qual[cnt2].stat_str_val = replace(
     dv.stat_str_val,'"',"'",0),
    dsr_reply->qual[cnt1].qual[cnt2].stat_type = dv.stat_type, dsr_reply->qual[cnt1].qual[cnt2].
    stat_number_val = dv.stat_number_val, dsr_reply->qual[cnt1].qual[cnt2].stat_date_val =
    cnvtdatetime(dv.stat_date_dt_tm),
    dsr_reply->qual[cnt1].qual[cnt2].stat_clob_val = replace(dv.stat_clob_val,'"',"'",0)
   FOOT  ds.snapshot_type
    stat = alterlist(dsr_reply->qual[cnt1].qual,cnt2)
   FOOT REPORT
    stat = alterlist(dsr_reply->qual,cnt1)
   WITH nocounter
  ;end select
  IF (error(get_err_msg,0) != 0)
   CALL esmerror(get_err_msg,esmexit)
  ENDIF
 ELSE
  SELECT INTO "nl:"
   FROM dm_stat_snaps ds,
    dm_stat_snaps_values dv,
    (dummyt d  WITH seq = value(size(dsr_request->qual,5)))
   PLAN (d)
    JOIN (ds
    WHERE (ds.client_mnemonic=dsr_request->client_mnemonic)
     AND (ds.domain_name=dsr_request->domain_name)
     AND (ds.node_name=dsr_request->node_name)
     AND (ds.snapshot_type=dsr_request->qual[d.seq].snapshot_type)
     AND ds.stat_snap_dt_tm BETWEEN cnvtdatetime(dsr_request->from_stat_snap_dt_tm) AND cnvtdatetime(
     dsr_request->to_stat_snap_dt_tm))
    JOIN (dv
    WHERE dv.dm_stat_snap_id=ds.dm_stat_snap_id)
   ORDER BY ds.dm_stat_snap_id
   HEAD REPORT
    cnt1 = 0
   HEAD ds.dm_stat_snap_id
    cnt1 = (cnt1+ 1)
    IF (cnt1 > size(dsr_reply->qual,5))
     stat = alterlist(dsr_reply->qual,(cnt1+ 9))
    ENDIF
    dsr_reply->qual[cnt1].stat_snap_dt_tm = cnvtdatetime(ds.stat_snap_dt_tm), dsr_reply->qual[cnt1].
    dm_stat_snap_id = ds.dm_stat_snap_id, dsr_reply->qual[cnt1].snapshot_type = ds.snapshot_type,
    dsr_reply->qual[cnt1].client_mnemonic = dsr_request->client_mnemonic, dsr_reply->qual[cnt1].
    domain_name = dsr_request->domain_name, dsr_reply->qual[cnt1].node_name = dsr_request->node_name,
    cnt2 = 0
   DETAIL
    cnt2 = (cnt2+ 1)
    IF (cnt2 > size(dsr_reply->qual[cnt1].qual,5))
     stat = alterlist(dsr_reply->qual[cnt1].qual,(cnt2+ 9))
    ENDIF
    dsr_reply->qual[cnt1].qual[cnt2].stat_name = replace(dv.stat_name,'"',"'",0), dsr_reply->qual[
    cnt1].qual[cnt2].stat_seq = dv.stat_seq, dsr_reply->qual[cnt1].qual[cnt2].stat_str_val = replace(
     dv.stat_str_val,'"',"'",0),
    dsr_reply->qual[cnt1].qual[cnt2].stat_type = dv.stat_type, dsr_reply->qual[cnt1].qual[cnt2].
    stat_number_val = dv.stat_number_val, dsr_reply->qual[cnt1].qual[cnt2].stat_date_val =
    cnvtdatetime(dv.stat_date_dt_tm),
    dsr_reply->qual[cnt1].qual[cnt2].stat_clob_val = replace(dv.stat_clob_val,'"',"'",0)
   FOOT  ds.snapshot_type
    stat = alterlist(dsr_reply->qual[cnt1].qual,cnt2)
   FOOT REPORT
    stat = alterlist(dsr_reply->qual,cnt1)
   WITH nocounter
  ;end select
  IF (error(get_err_msg,0) != 0)
   CALL esmerror(get_err_msg,esmexit)
  ENDIF
 ENDIF
#exit_program
END GO
