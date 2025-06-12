CREATE PROGRAM dcp_apache_trending:dba
 RECORD reply(
   1 apache_day[*]
     2 day_pred_ind = i2
     2 hosp_rod = i4
     2 icu_rod = i4
     2 active_tx = i4
     2 aps = i4
     2 tiss = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = vc
       3 operationstatus = c1
       3 targetobjectname = vc
       3 targetobjectvalue = vc
 )
 DECLARE meaning_code(p1,p2) = f8
 EXECUTE FROM 1000_initialize TO 1999_initialize_exit
 EXECUTE FROM 2000_read TO 2999_read_exit
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
 SET max_cc_day = 0
#1999_initialize_exit
#2000_read
 SELECT INTO "nl:"
  FROM risk_adjustment ra,
   risk_adjustment_day rad
  PLAN (ra
   WHERE (ra.person_id=request->person_id)
    AND (ra.encntr_id=request->encntr_id)
    AND ra.icu_admit_dt_tm=cnvtdatetime(request->icu_admit_dt_tm)
    AND ra.active_ind=1)
   JOIN (rad
   WHERE rad.risk_adjustment_id=ra.risk_adjustment_id
    AND rad.aps_score >= 0
    AND rad.active_ind=1)
  ORDER BY rad.cc_day
  HEAD rad.cc_day
   stat = alterlist(reply->apache_day,(rad.cc_day+ 1)), reply->apache_day[rad.cc_day].day_pred_ind =
   1, reply->apache_day[rad.cc_day].aps = rad.aps_score,
   reply->apache_day[rad.cc_day].hosp_rod = - (1), reply->apache_day[rad.cc_day].icu_rod = - (1),
   reply->apache_day[(rad.cc_day+ 1)].active_tx = - (1),
   reply->apache_day[rad.cc_day].active_tx = - (1), reply->apache_day[rad.cc_day].active_tx = - (1),
   reply->apache_day[(rad.cc_day+ 1)].tiss = - (1),
   reply->apache_day[1].tiss = - (1)
  DETAIL
   null
  FOOT  rad.cc_day
   max_cc_day = rad.cc_day
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM risk_adjustment ra,
   risk_adjustment_day rad,
   risk_adjustment_outcomes rao
  PLAN (ra
   WHERE (ra.person_id=request->person_id)
    AND (ra.encntr_id=request->encntr_id)
    AND ra.icu_admit_dt_tm=cnvtdatetime(request->icu_admit_dt_tm)
    AND ra.active_ind=1)
   JOIN (rad
   WHERE rad.risk_adjustment_id=ra.risk_adjustment_id
    AND rad.outcome_status >= 0
    AND rad.active_ind=1)
   JOIN (rao
   WHERE rao.risk_adjustment_day_id=rad.risk_adjustment_day_id
    AND rao.active_ind=1)
  ORDER BY rad.cc_day
  HEAD rad.cc_day
   IF (rad.cc_day=max_cc_day)
    stat = alterlist(reply->apache_day,(rad.cc_day+ 1))
   ENDIF
   reply->apache_day[rad.cc_day].day_pred_ind = 1, null
  DETAIL
   IF (rao.equation_name="HSP_DEATH")
    reply->apache_day[rad.cc_day].hosp_rod = round((rao.outcome_value * 100),0)
   ELSEIF (rao.equation_name="ICU_DEATH")
    reply->apache_day[rad.cc_day].icu_rod = round((rao.outcome_value * 100),0)
   ELSEIF (rao.equation_name="ACT_TMR")
    reply->apache_day[(rad.cc_day+ 1)].active_tx = round((rao.outcome_value * 100),0)
   ELSEIF (rao.equation_name="NTL_ACT_DAY1"
    AND rad.cc_day=1
    AND rad.activetx_ind=1)
    reply->apache_day[rad.cc_day].active_tx = round((rao.outcome_value * 100),0)
   ELSEIF (rao.equation_name="ACT_ICU_EVER"
    AND rad.cc_day=1
    AND rad.activetx_ind=0)
    reply->apache_day[rad.cc_day].active_tx = round((rao.outcome_value * 100),0)
   ELSEIF (rao.equation_name="TISS_TMR")
    reply->apache_day[(rad.cc_day+ 1)].tiss = round(rao.outcome_value,0)
   ELSEIF (rao.equation_name="1ST_TISS")
    reply->apache_day[1].tiss = round(rao.outcome_value,0)
   ENDIF
   IF (rad.cc_day=1
    AND ra.admit_diagnosis IN ("CARDARREST", "POISON", "NTCOMA", "CARDSHOCK", "PAPMUSCLE",
   "S-VALVAM", "S-VALVAO", "S-VALVMI", "S-VALVMR", "S-VALVPULM",
   "SVALVTRI", "S-CABGAOV", "S-CABGMIV", "S-CABGMVR", "S-CABGVALV",
   "S-LIVTRAN", "S-AAANEUUP", "S-TAANEURU", "S-CABG", "S-CABGREDO",
   "S-CABGROTH", "S-CABGWOTH"))
    reply->apache_day[1].active_tx = 99
   ENDIF
  WITH nocounter
 ;end select
 IF (max_cc_day=0)
  SET reply->status_data.status = "Z"
 ELSE
  FOR (x = 1 TO max_cc_day)
    IF ((reply->apache_day[x].day_pred_ind != 1))
     SET reply->apache_day[x].day_pred_ind = 0
    ENDIF
  ENDFOR
  SET reply->status_data.status = "S"
 ENDIF
#2999_read_exit
#9999_exit_program
 CALL echorecord(reply)
END GO
