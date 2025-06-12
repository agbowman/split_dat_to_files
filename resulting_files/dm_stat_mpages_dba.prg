CREATE PROGRAM dm_stat_mpages:dba
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
 DECLARE curmin = f8 WITH protect, noconstant(0)
 DECLARE curmax = f8 WITH protect, noconstant(0)
 DECLARE maxid = f8 WITH protect, noconstant(0)
 DECLARE num = i4 WITH protect, noconstant(0)
 DECLARE numpages = i4 WITH protect, noconstant(0)
 DECLARE objname = vc WITH protect, noconstant("")
 DECLARE functiondata = vc WITH protect, noconstant("")
 DECLARE clientmnemonic = vc WITH protect, noconstant("UNKNOWN")
 DECLARE chunk_size = i4 WITH protect, constant(225000)
 DECLARE numbuckets = i4 WITH protect, constant(16)
 DECLARE ms_snapshot_type = vc WITH protect, constant("MPAGES")
 DECLARE ms_info_domain = vc WITH protect, constant("DM_STAT_MPAGES")
 DECLARE ms_nodata_stat = vc WITH protect, constant("NO_NEW_DATA")
 DECLARE ms_snapshot_time = dq8 WITH protect, constant(cnvtdatetime((curdate - 1),0))
 DECLARE buildbucketdata(position=i4) = null
 DECLARE createbuckets(index=i4) = null
 DECLARE dsvm_error(msg=vc) = null
 FREE RECORD mpages
 RECORD mpages(
   1 qual[*]
     2 script_name = vc
     2 execution_cnt = i4
     2 total_time = i4
     2 sum_sq = i4
     2 bucket_str = vc
     2 buckets[*]
       3 value = f8
       3 count = i4
 )
 RECORD seq_ids(
   1 qual[*]
     2 seq_val = f8
 )
 RECORD m_dm2_seq_stat(
   1 n_status = i4
   1 s_error_msg = vc
 ) WITH protect
 SELECT INTO "nl:"
  min_id = min(cra.report_event_id), max_id = max(cra.report_event_id)
  FROM ccl_report_audit cra
  WHERE cra.updt_dt_tm BETWEEN cnvtdatetime((curdate - 1),0) AND cnvtdatetime((curdate - 1),235959)
  DETAIL
   maxid = max_id, curmin = min_id, curmax = (min_id+ chunk_size)
   IF (curmax > maxid)
    curmax = maxid
   ENDIF
  WITH nocounter
 ;end select
 WHILE (curmin <= maxid)
   SELECT INTO "nl:"
    object_name = trim(cra.object_name), mpage = piece(cra.object_params,",",10,"NotFound",1), cra
    .updt_id,
    elapsed_seconds = datetimediff(cra.end_dt_tm,cra.begin_dt_tm,5)
    FROM ccl_report_audit cra
    WHERE cra.report_event_id BETWEEN curmin AND curmax
    DETAIL
     IF (object_name="MP_DRIVER")
      objname = build(object_name,"||",cra.updt_id,"||",mpage)
     ELSE
      objname = build(object_name,"||",cra.updt_id,"||")
     ENDIF
     idx = locateval(num,1,size(mpages->qual,5),objname,mpages->qual[num].script_name)
     IF (idx=0)
      numpages = (numpages+ 1)
      IF (mod(numpages,100)=1)
       stat = alterlist(mpages->qual,(numpages+ 99))
      ENDIF
      idx = numpages, mpages->qual[idx].script_name = objname, mpages->qual[idx].execution_cnt = 1,
      mpages->qual[idx].total_time = elapsed_seconds, mpages->qual[idx].sum_sq = (elapsed_seconds *
      elapsed_seconds),
      CALL createbuckets(idx)
     ELSE
      mpages->qual[idx].execution_cnt = (mpages->qual[idx].execution_cnt+ 1), mpages->qual[idx].
      total_time = (mpages->qual[idx].total_time+ elapsed_seconds), mpages->qual[idx].sum_sq = (
      mpages->qual[idx].sum_sq+ (elapsed_seconds * elapsed_seconds))
     ENDIF
     bucketfound = 0, bucketitr = 1
     IF (elapsed_seconds > 10)
      mpages->qual[idx].buckets[numbuckets].count = (mpages->qual[idx].buckets[numbuckets].count+ 1),
      bucketfound = 1
     ENDIF
     WHILE (bucketfound=0
      AND bucketitr <= numbuckets)
      IF ((elapsed_seconds <= mpages->qual[idx].buckets[bucketitr].value))
       mpages->qual[idx].buckets[bucketitr].count = (mpages->qual[idx].buckets[bucketitr].count+ 1),
       bucketfound = 1
      ENDIF
      ,bucketitr = (bucketitr+ 1)
     ENDWHILE
    FOOT REPORT
     stat = alterlist(mpages->qual,numpages)
    WITH nocounter
   ;end select
   CALL dsvm_error("DM_STAT_MPAGES - MPAGES")
   SET curmin = (curmax+ 1)
   SET curmax = (curmin+ chunk_size)
   IF (curmax > maxid)
    SET curmax = maxid
   ENDIF
 ENDWHILE
 IF (size(mpages->qual,5)=0)
  SET stat = alterlist(mpages->qual,1)
  SET mpages->qual[1].script_name = ms_nodata_stat
 ENDIF
 SET stat = alterlist(seq_ids->qual,1)
 EXECUTE dm2_dar_get_bulk_seq "SEQ_IDS->QUAL", 1, "SEQ_VAL",
 1, "DM_CLINICAL_SEQ"
 IF ((m_dm2_seq_stat->n_status != 1))
  CALL esmerror("dm2_dar_get_bulk_seq call failed",esmexit)
 ENDIF
 SELECT INTO "nl:"
  dmi.info_char
  FROM dm_info dmi
  WHERE dmi.info_domain="DATA MANAGEMENT"
   AND dmi.info_name="CLIENT MNEMONIC"
  DETAIL
   clientmnemonic = dmi.info_char
  WITH nocounter
 ;end select
 INSERT  FROM dm_stat_snaps dss
  SET dss.dm_stat_snap_id = seq_ids->qual[1].seq_val, dss.client_mnemonic = clientmnemonic, dss
   .domain_name = substring(1,20,reqdata->domain),
   dss.node_name = trim(curnode), dss.snapshot_type = ms_snapshot_type, dss.stat_snap_dt_tm =
   cnvtdatetime(ms_snapshot_time),
   dss.updt_id = reqinfo->updt_id, dss.updt_dt_tm = cnvtdatetime(curdate,curtime2), dss.updt_task =
   reqinfo->updt_task,
   dss.updt_applctx = reqinfo->updt_applctx, dss.updt_cnt = 0
  WITH nocounter
 ;end insert
 IF ((mpages->qual[1].script_name != ms_nodata_stat))
  FOR (scriptitr = 1 TO size(mpages->qual,5))
    CALL buildbucketdata(scriptitr)
  ENDFOR
 ENDIF
 INSERT  FROM dm_stat_snaps_values dssv,
   (dummyt d1  WITH seq = size(mpages->qual,5))
  SET dssv.dm_stat_snap_id = seq_ids->qual[1].seq_val, dssv.stat_name = substring(1,255,mpages->qual[
    d1.seq].script_name), dssv.stat_type = 2,
   dssv.stat_number_val = 0, dssv.stat_date_dt_tm = null, dssv.stat_seq = d1.seq,
   dssv.stat_clob_val = trim(mpages->qual[d1.seq].bucket_str,3), dssv.updt_id = reqinfo->updt_id,
   dssv.updt_dt_tm = cnvtdatetime(curdate,curtime2),
   dssv.updt_task = reqinfo->updt_task, dssv.updt_applctx = reqinfo->updt_applctx, dssv.updt_cnt = 0
  PLAN (d1)
   JOIN (dssv)
  WITH nocounter
 ;end insert
 COMMIT
 SUBROUTINE buildbucketdata(position)
   SET functiondata = build(mpages->qual[position].execution_cnt,"||",mpages->qual[position].
    total_time,"||",mpages->qual[position].sum_sq)
   FOR (bucketitr = 1 TO numbuckets)
     SET functiondata = build(functiondata,"||",trim(format(mpages->qual[position].buckets[bucketitr]
        .value,"####.#"),3),"||",mpages->qual[position].buckets[bucketitr].count)
   ENDFOR
   SET mpages->qual[position].bucket_str = functiondata
 END ;Subroutine
 SUBROUTINE createbuckets(index)
   SET stat = alterlist(mpages->qual[index].buckets,numbuckets)
   SET mpages->qual[index].buckets[1].value = 0.5
   SET mpages->qual[index].buckets[2].value = 1.0
   SET mpages->qual[index].buckets[3].value = 1.5
   SET mpages->qual[index].buckets[4].value = 2.0
   SET mpages->qual[index].buckets[5].value = 2.5
   SET mpages->qual[index].buckets[6].value = 3.0
   SET mpages->qual[index].buckets[7].value = 3.5
   SET mpages->qual[index].buckets[8].value = 4.0
   SET mpages->qual[index].buckets[9].value = 4.5
   SET mpages->qual[index].buckets[10].value = 5.0
   SET mpages->qual[index].buckets[11].value = 6.0
   SET mpages->qual[index].buckets[12].value = 7.0
   SET mpages->qual[index].buckets[13].value = 8.0
   SET mpages->qual[index].buckets[14].value = 9.0
   SET mpages->qual[index].buckets[15].value = 10.0
   SET mpages->qual[index].buckets[16].value = 9999.0
 END ;Subroutine
 SUBROUTINE dsvm_error(msg)
  DECLARE dsvm_err_msg = c132
  IF (error(dsvm_err_msg,0) > 0)
   ROLLBACK
   CALL esmerror(concat("Error: ",msg," ",dsvm_err_msg),esmreturn)
   GO TO exitscript
  ENDIF
 END ;Subroutine
#exitscript
END GO
