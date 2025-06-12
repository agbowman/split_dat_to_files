CREATE PROGRAM cco_apacheiv_upgrade_repredict:dba
 PROMPT
  "Enter ICU_ADMIT_DT_TM, Must be >= 01-JAN-2002 00:00:00:" = "*"
 DECLARE count = i4
 DECLARE vcnt = i4
 SET vdate = cnvtdatetime("01-JAN-2002 00:00:00")
 FREE RECORD request
 RECORD request(
   1 person_id = f8
   1 encntr_id = f8
   1 cc_start_day = i2
   1 icu_admit_dt_tm = dq8
 )
 RECORD recalc_list(
   1 count = i4
   1 list[*]
     2 person_id = f8
     2 encntr_id = f8
     2 icu_admit_dt_tm = dq8
     2 person_id = f8
 )
 EXECUTE apachertl
 IF (cnvtdatetime( $1) > vdate)
  SET vdate = cnvtdatetime( $1)
 ENDIF
 SELECT INTO "nl:"
  FROM risk_adjustment ra,
   risk_adjustment_day rad
  PLAN (ra
   WHERE ra.active_ind=1)
   JOIN (rad
   WHERE ra.risk_adjustment_id=rad.risk_adjustment_id
    AND rad.active_ind=1
    AND rad.cc_day=1
    AND ra.icu_admit_dt_tm >= cnvtdatetime(vdate))
  HEAD REPORT
   recalc_list->count = 0, count = 0
  DETAIL
   count = (count+ 1), stat = alterlist(recalc_list->list,count), recalc_list->list[count].encntr_id
    = ra.encntr_id,
   recalc_list->list[count].person_id = ra.person_id, recalc_list->list[count].icu_admit_dt_tm = ra
   .icu_admit_dt_tm, recalc_list->count = count
  WITH nocounter
 ;end select
 CALL echo(build("going to recalc patients =",recalc_list->count))
 FOR (x = 1 TO recalc_list->count)
   SET request->encntr_id = recalc_list->list[x].encntr_id
   SET request->person_id = recalc_list->list[x].person_id
   SET request->icu_admit_dt_tm = recalc_list->list[x].icu_admit_dt_tm
   SET request->cc_start_day = 1
   EXECUTE dcp_recalc_apache_predictions
 ENDFOR
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="APACHE"
   AND di.info_name="APACHE IV UPGRADE REPREDICTION"
  DETAIL
   vcnt = count
  WITH nocounter
 ;end select
 IF (vcnt=0)
  INSERT  FROM dm_info di
   SET di.info_domain = "APACHE", di.info_name = "APACHE IV UPGRADE REPREDICTION", di.info_date =
    cnvtdatetime(vdate),
    di.updt_dt_tm = cnvtdatetime(curdate,curtime), di.updt_id = reqinfo->updt_id, di.updt_applctx =
    reqinfo->updt_applctx,
    di.updt_task = reqinfo->updt_task
  ;end insert
 ELSE
  UPDATE  FROM dm_info di
   SET di.info_date = cnvtdatetime(vdate), di.updt_dt_tm = cnvtdatetime(curdate,curtime), di.updt_id
     = reqinfo->updt_id,
    di.updt_applctx = reqinfo->updt_applctx, di.updt_cnt = (updt_cnt+ 1), di.updt_task = reqinfo->
    updt_task
   WHERE di.info_domain="APACHE"
    AND di.info_name="APACHE IV UPGRADE REPREDICTION"
   WITH noncounter
  ;end update
 ENDIF
 COMMIT
END GO
