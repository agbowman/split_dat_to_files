CREATE PROGRAM dm_stat_icdx_usage:dba
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
 DECLARE qualcnt = i4
 DECLARE ds_cnt = i4
 SET ds_begin_snapshot = cnvtdatetime((curdate - 1),0)
 SET ds_end_snapshot = cnvtdatetime((curdate - 1),235959)
 DECLARE dsvm_error(msg=vc) = null
 SET ds_cnt = 0
 SUBROUTINE dsvm_error(msg)
  DECLARE dsvm_err_msg = c132
  IF (error(dsvm_err_msg,0) > 0)
   ROLLBACK
   CALL esmerror(concat("Error: ",msg," ",dsvm_err_msg),esmreturn)
  ENDIF
 END ;Subroutine
 SELECT INTO "nl:"
  report_category = trim(f.find_name), report_description = trim(d.detail_description), report_status
   = evaluate(d.active_ind,1,"Enabled","Disabled"),
  last_run_date = format(max(l.end_dt_tm),";;q"), objects_found = s.object_found_cnt,
  objects_marked_as_reviewed = s.marked_as_reviewed_cnt
  FROM dm_text_find_summary s,
   dm_text_find_detail d,
   dm_text_find f,
   dm_text_find_log l
  WHERE (s.dm_text_find_cat_id=
  (SELECT
   c.dm_text_find_cat_id
   FROM dm_text_find_cat c
   WHERE c.find_category="ICD9"))
   AND s.dm_text_find_detail_id=d.dm_text_find_detail_id
   AND f.dm_text_find_id=d.dm_text_find_id
   AND l.dm_text_find_detail_id=d.dm_text_find_detail_id
   AND l.log_status IN ("SUCCESS", "INCOMPLETE")
  GROUP BY f.find_name, d.detail_description, d.active_ind,
   s.object_found_cnt, s.marked_as_reviewed_cnt
  HEAD REPORT
   qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm =
   cnvtdatetime((curdate - 1),0),
   dsr->qual[qualcnt].snapshot_type = "ICDX_USAGE", stat = alterlist(dsr->qual[qualcnt].qual,1)
  DETAIL
   ds_cnt = (ds_cnt+ 1)
   IF (mod(ds_cnt,10)=1)
    stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
   ENDIF
   dsr->qual[qualcnt].qual[ds_cnt].stat_name = "ICD-9", dsr->qual[qualcnt].qual[ds_cnt].stat_seq =
   ds_cnt, dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = build(report_category,"||",
    report_description,"||",report_status,
    "||",last_run_date,"||",objects_found,"||",
    objects_marked_as_reviewed)
  FOOT REPORT
   IF (ds_cnt=0)
    stat = alterlist(dsr->qual[qualcnt].qual,1), dsr->qual[qualcnt].qual[1].stat_name = "ICD-9", dsr
    ->qual[qualcnt].qual[1].stat_seq = 1,
    dsr->qual[qualcnt].qual[1].stat_str_val = "NO_NEW_DATA"
   ELSE
    stat = alterlist(dsr->qual[qualcnt].qual,ds_cnt)
   ENDIF
  WITH nocounter, nullreport
 ;end select
 CALL dsvm_error("ICDX_USAGE - ICD-9")
 EXECUTE dm_stat_snaps_load
#exit_program
END GO
