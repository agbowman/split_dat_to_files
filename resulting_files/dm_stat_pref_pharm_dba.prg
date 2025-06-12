CREATE PROGRAM dm_stat_pref_pharm:dba
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
 DECLARE ms_snapshot_type = vc WITH protect, constant("PREF_PHARM")
 DECLARE ms_last_run_time = dq8
 DECLARE ms_this_run_time = dq8 WITH constant(cnvtdatetime(curdate,curtime3))
 DECLARE ms_snapshot_time = dq8 WITH constant(cnvtdatetime((curdate - 1),0))
 DECLARE delimiter = c3 WITH constant("{]|")
 DECLARE ms_info_domain = vc WITH constant("DM_STAT_PREF_PHARM")
 DECLARE dsvm_error(msg=vc) = null
 DECLARE ds_cnt = i4
 DECLARE isfullrun = i4 WITH protect, noconstant(0)
 DECLARE min_id = f8 WITH protect, noconstant(0)
 DECLARE max_id = f8 WITH protect, noconstant(0)
 DECLARE mn_snapshot_id = f8 WITH protect, noconstant(0)
 DECLARE num_chunks = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain=ms_info_domain
   AND di.info_name IN ("LAST_RUN_TIME", "LAST_FULL_RUN_TIME")
  HEAD REPORT
   isfullrun = 0
  DETAIL
   IF (di.info_name="LAST_FULL_RUN_TIME")
    IF (((datetimediff(cnvtdatetime(curdate,curtime3),di.info_date) >= 32) OR (day(curdate)=22)) )
     isfullrun = 1
    ENDIF
   ELSEIF (di.info_name="LAST_RUN_TIME")
    ms_last_run_time = di.info_date
   ENDIF
  FOOT REPORT
   IF (isfullrun=1)
    ms_last_run_time = cnvtdatetime("01-JAN-1800 00:00:00")
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  DELETE  FROM dm_info di
   WHERE ((di.info_domain="DM_STAT_PREF_PHARM") OR (di.info_domain="DM_STAT_PREF_PHARM.*"))
  ;end delete
  INSERT  FROM dm_info di
   SET di.info_domain = ms_info_domain, di.info_name = "LAST_RUN_TIME", di.info_date = cnvtdatetime(
     "01-JAN-1800 00:00:00")
   WITH nocounter
  ;end insert
  INSERT  FROM dm_info di
   SET di.info_domain = ms_info_domain, di.info_name = "LAST_FULL_RUN_TIME", di.info_date =
    cnvtdatetime("01-JAN-1800 00:00:00")
   WITH nocounter
  ;end insert
  SET ms_last_run_time = cnvtdatetime("01-JAN-1800 00:00:00")
  SET isfullrun = 1
  COMMIT
 ENDIF
 SET ds_cnt = 1
 SET qualcnt = 0
 SET stat_seq = 0
 SET stat = initrec(dsr)
 SELECT INTO "nl:"
  dm.person_id, pref_domain = trim(dm.pref_domain), pref_section = trim(dm.pref_section),
  pref_name = trim(dm.pref_name), dm.pref_nbr, dm.pref_cd,
  dm.pref_dt_tm, pref_str =
  IF (dm.pref_cd > 0) uar_get_code_display(dm.pref_cd)
  ELSE trim(dm.pref_str)
  ENDIF
  , dm.parent_entity_id,
  parent_entity_name = trim(dm.parent_entity_name), dm.reference_ind
  FROM dm_prefs dm
  WHERE updt_dt_tm BETWEEN cnvtdatetime(ms_last_run_time) AND cnvtdatetime(ms_this_run_time)
  HEAD REPORT
   IF (size(dsr->qual,5)=0)
    qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm
     = ms_snapshot_time,
    dsr->qual[qualcnt].snapshot_type = ms_snapshot_type
   ENDIF
  DETAIL
   IF (mod(ds_cnt,100)=1)
    stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 99))
   ENDIF
   dsr->qual[qualcnt].qual[ds_cnt].stat_name = "PREF_PHARM", dsr->qual[qualcnt].qual[ds_cnt].
   stat_clob_val = build(dm.person_id,delimiter,pref_domain,delimiter,pref_section,
    delimiter,pref_name,delimiter,dm.pref_nbr,delimiter,
    dm.pref_cd,delimiter,dm.pref_dt_tm,delimiter,pref_str,
    delimiter,dm.parent_entity_id,delimiter,parent_entity_name,delimiter,
    dm.reference_ind), dsr->qual[qualcnt].qual[ds_cnt].stat_type = 0,
   dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq, ds_cnt = (ds_cnt+ 1), stat_seq = (stat_seq+ 1
   )
  FOOT REPORT
   IF (ds_cnt=1)
    stat = alterlist(dsr->qual[qualcnt].qual,1), dsr->qual[qualcnt].qual[1].stat_name = "NO_NEW_DATA",
    ds_cnt = (ds_cnt+ 1)
   ENDIF
   stat = alterlist(dsr->qual[qualcnt].qual,ds_cnt), dsr->qual[qualcnt].qual[ds_cnt].stat_name =
   "FULL_RUN_IND", dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = isfullrun
  WITH nocounter, nullreport
 ;end select
 CALL dsvm_error("PREF_PHARM - PREF_PHARM")
 UPDATE  FROM dm_info di
  SET di.info_date = cnvtdatetime(ms_this_run_time)
  WHERE di.info_domain=ms_info_domain
   AND di.info_name="LAST_RUN_TIME"
  WITH nocounter
 ;end update
 IF (isfullrun=1)
  UPDATE  FROM dm_info di
   SET di.info_date = cnvtdatetime(ms_this_run_time)
   WHERE di.info_domain=ms_info_domain
    AND di.info_name="LAST_FULL_RUN_TIME"
   WITH nocounter
  ;end update
 ENDIF
 EXECUTE dm_stat_snaps_load
 COMMIT
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
