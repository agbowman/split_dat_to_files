CREATE PROGRAM bhs_ops_toc_one_day:dba
 EXECUTE bhs_hlp_ccl
 DECLARE mf_begin = f8 WITH protect, noconstant(0)
 DECLARE mf_end = f8 WITH protect, noconstant(0)
 DECLARE mf_start = f8 WITH protect, noconstant(0)
 DECLARE mf_finish = f8 WITH protect, noconstant(0)
 DECLARE mf_cc_start = f8 WITH protect, noconstant(cnvtdatetime(curdate,170000))
 DECLARE mf_cc_finish = f8 WITH protect, noconstant(cnvtdatetime(curdate,173000))
 DECLARE mf_sysdate = f8 WITH protect, noconstant(cnvtdatetime(curdate,curtime3))
 DECLARE ml_status = i4 WITH protect, noconstant(0)
 DECLARE ml_mes_count = i4 WITH public, noconstant(0)
 DECLARE ms_new_start = vc WITH protect, noconstant("")
 IF (validate(reply->status_data[1].status)=0)
  RECORD reply(
    1 status_data[1]
      2 status = c1
      2 subeventstatus[1]
        3 operationname = vc
        3 operationstatus = vc
        3 targetobjectname = vc
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 SET reply->status_data[1].status = "F"
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="BHS_OPS_TRANS_CARE_CDA_ONE_DAY"
   AND di.info_name IN ("START DATE", "FINISH DATE", "STATUS", "COUNT")
  DETAIL
   IF (trim(di.info_name)="START DATE")
    mf_start = cnvtdate2(di.info_char,"MM/DD/YY")
   ELSEIF (trim(di.info_name)="FINISH DATE")
    mf_finish = cnvtdate2(di.info_char,"MM/DD/YY")
   ELSEIF (trim(di.info_name)="STATUS")
    ml_status = cnvtint(trim(di.info_char))
   ELSEIF (trim(di.info_name)="COUNT")
    ml_mes_count = cnvtint(trim(di.info_char))
   ENDIF
  WITH nocounter
 ;end select
 IF (ml_status=1)
  CALL echo("*** Error ***: The job still running")
  CALL bhs_sbr_log("stop","",0,"",0.0,
   "Failed: The job still running.","Still running","F")
  GO TO exit_program
 ENDIF
 IF (mf_sysdate > mf_cc_start
  AND mf_sysdate < mf_cc_finish)
  UPDATE  FROM dm_info di
   SET di.info_char = "0", di.updt_id = reqinfo->updt_id, di.updt_dt_tm = cnvtdatetime(curdate,
     curtime3),
    di.updt_cnt = (updt_cnt+ 1), di.updt_task = 0, di.updt_applctx = reqinfo->updt_applctx
   WHERE di.info_domain="BHS_OPS_TRANS_CARE_CDA_ONE_DAY"
    AND di.info_name="COUNT"
   WITH nocounter
  ;end update
  COMMIT
 ENDIF
 IF (ml_mes_count > 20000)
  CALL echo("*** Error ***: The total messages generating by today more than 20000")
  CALL bhs_sbr_log("stop","",0,"",0.0,
   "Failed: The total messages generating by today more than 20000","Message Limit","F")
  GO TO exit_program
 ENDIF
 IF (datetimediff(mf_finish,mf_start,1) <= 0)
  CALL echo("*** Error ***: Date range < 0")
  CALL bhs_sbr_log("stop","",0,"",0.0,
   "Failed: Begin date greater or equal to End date","End Time","F")
  GO TO exit_program
 ENDIF
 UPDATE  FROM dm_info di
  SET di.info_char = "1", di.updt_id = reqinfo->updt_id, di.updt_dt_tm = cnvtdatetime(curdate,
    curtime3),
   di.updt_cnt = (updt_cnt+ 1), di.updt_task = 0, di.updt_applctx = reqinfo->updt_applctx
  WHERE di.info_domain="BHS_OPS_TRANS_CARE_CDA_ONE_DAY"
   AND di.info_name="STATUS"
  WITH nocounter
 ;end update
 COMMIT
 SET mf_begin = cnvtdatetime(mf_start,000000)
 SET mf_end = cnvtdatetime(mf_start,235959)
 EXECUTE bhs_ops_toc_one_day_child format(mf_begin,"DD-MMM-YYYY HH:MM:SS;;Q"), format(mf_end,
  "DD-MMM-YYYY HH:MM:SS;;Q")
 SET ms_new_start = format(cnvtlookahead("1,D",mf_begin),"MM/DD/YY;;D")
 UPDATE  FROM dm_info di
  SET di.info_char = ms_new_start, di.updt_id = reqinfo->updt_id, di.updt_dt_tm = cnvtdatetime(
    curdate,curtime3),
   di.updt_cnt = (updt_cnt+ 1), di.updt_task = 0, di.updt_applctx = reqinfo->updt_applctx
  WHERE di.info_domain="BHS_OPS_TRANS_CARE_CDA_ONE_DAY"
   AND di.info_name="START DATE"
  WITH nocounter
 ;end update
 COMMIT
 UPDATE  FROM dm_info di
  SET di.info_char = cnvtstring(ml_mes_count), di.updt_id = reqinfo->updt_id, di.updt_dt_tm =
   cnvtdatetime(curdate,curtime3),
   di.updt_cnt = (updt_cnt+ 1), di.updt_task = 0, di.updt_applctx = reqinfo->updt_applctx
  WHERE di.info_domain="BHS_OPS_TRANS_CARE_CDA_ONE_DAY"
   AND di.info_name="COUNT"
  WITH nocounter
 ;end update
 COMMIT
 UPDATE  FROM dm_info di
  SET di.info_char = "0", di.updt_id = reqinfo->updt_id, di.updt_dt_tm = cnvtdatetime(curdate,
    curtime3),
   di.updt_cnt = (updt_cnt+ 1), di.updt_task = 0, di.updt_applctx = reqinfo->updt_applctx
  WHERE di.info_domain="BHS_OPS_TRANS_CARE_CDA_ONE_DAY"
   AND di.info_name="STATUS"
  WITH nocounter
 ;end update
 COMMIT
 SET reply->status_data[1].status = "S"
#exit_program
END GO
