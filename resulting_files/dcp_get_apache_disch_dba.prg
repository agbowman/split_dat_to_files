CREATE PROGRAM dcp_get_apache_disch:dba
 RECORD reply(
   1 risk_adjustment_id = f8
   1 consec_vent_days = i2
   1 consec_pa_days = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = vc
       3 operationstatus = c1
       3 targetobjectname = vc
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 cc_day[*]
     2 beg_dt_tm = dq8
     2 end_dt_tm = dq8
 )
 DECLARE meaning_code(p1,p2) = f8
 EXECUTE FROM 1000_initialize TO 1099_initialize_exit
 EXECUTE FROM 2000_read TO 2099_read_exit
 GO TO 9999_exit_program
 SUBROUTINE meaning_code(mc_codeset,mc_meaning)
   SET mc_code = 0.0
   SET mc_text = fillstring(12," ")
   SET mc_text = mc_meaning
   SET mc_stat = uar_get_meaning_by_codeset(mc_codeset,nullterm(mc_text),1,mc_code)
   IF (mc_code > 0.0)
    RETURN(mc_code)
   ELSE
    RETURN(- (1.0))
   ENDIF
 END ;Subroutine
#1000_initialize
 SET reply->status_data.status = "F"
 SET cc_day = 0
 SET ra_entry_found = "N"
 SET vent_cnt = 0
 SET pa_cnt = 0
#1099_initialize_exit
#2000_read
 EXECUTE FROM 2100_read_risk_adjustment TO 2199_risk_adjustment_exit
 SET reply->status_data.status = "S"
#2099_read_exit
#2100_read_risk_adjustment
 SELECT INTO "nl:"
  FROM risk_adjustment ra
  PLAN (ra
   WHERE (ra.person_id=request->person_id)
    AND (ra.encntr_id=request->encntr_id)
    AND ra.icu_admit_dt_tm=cnvtdatetime(request->icu_admit_dt_tm)
    AND ra.active_ind=1)
  HEAD REPORT
   data_loaded = "N"
  DETAIL
   IF (data_loaded="N")
    data_loaded = "Y", ra_entry_found = "Y", reply->risk_adjustment_id = ra.risk_adjustment_id
   ENDIF
  WITH nocounter
 ;end select
 SET pa_cnt = 0
 SET vent_cnt = 0
 SELECT INTO "nl:"
  FROM risk_adjustment_day rad
  PLAN (rad
   WHERE (rad.risk_adjustment_id=reply->risk_adjustment_id)
    AND rad.active_ind=1)
  ORDER BY rad.cc_day
  HEAD REPORT
   pa_cnt = 0, vent_cnt = 0, keep_counting_pa = "Y",
   keep_counting_vent = "Y"
  DETAIL
   IF (keep_counting_pa="Y")
    IF (rad.pa_line_today_ind=1)
     pa_cnt = (pa_cnt+ 1)
    ELSE
     keep_counting_pa = "N"
    ENDIF
   ENDIF
   IF (keep_counting_vent="Y")
    IF (rad.vent_today_ind=1)
     vent_cnt = (vent_cnt+ 1)
    ELSE
     keep_counting_vent = "N"
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SET reply->consec_pa_days = pa_cnt
 SET reply->consec_vent_days = vent_cnt
 IF (ra_entry_found != "Y")
  SET reply->risk_adjustment_id = 0.0
 ENDIF
#2199_risk_adjustment_exit
#9999_exit_program
 CALL echorecord(reply)
END GO
