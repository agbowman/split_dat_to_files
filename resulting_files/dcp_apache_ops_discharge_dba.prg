CREATE PROGRAM dcp_apache_ops_discharge:dba
 RECORD reply(
   1 ops_event = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = vc
       3 operationstatus = c1
       3 targetobjectname = vc
       3 targetobjectvalue = vc
 )
 RECORD patients(
   1 list[*]
     2 person_id = f8
     2 encntr_id = f8
     2 name = vc
     2 loc_cd = f8
     2 loc_name = vc
     2 ra_id = f8
     2 icu_admit_dt_tm = dq8
     2 hosp_disch_dt_tm = dq8
     2 icu_disch_dt_tm = dq8
     2 died_in_hosp_ind = i2
     2 died_in_icu_ind = i2
 )
 RECORD disch_request(
   1 risk_adjustment_id = f8
   1 admit_time_chg_ind = i2
   1 new_icu_admit_dt_tm = dq8
   1 disch_time_chg_ind = i2
   1 new_icu_disch_dt_tm = dq8
 )
 RECORD disch_reply(
   1 risk_adjustment_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = vc
       3 operationstatus = c1
       3 targetobjectname = vc
       3 targetobjectvalue = vc
 )
 DECLARE meaning_code(p1,p2) = f8
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
 SET deceased_cd = meaning_code(19,"DECEASED")
 SET expired_cd = meaning_code(19,"EXPIRED")
 SET pat_counter = 0
 SET transfer_count = 0
 SELECT INTO "nl:"
  FROM risk_adjustment ra,
   person p,
   encounter e
  PLAN (ra
   WHERE ra.active_ind=1
    AND ra.icu_disch_dt_tm=cnvtdatetime("31-DEC-2100"))
   JOIN (p
   WHERE p.person_id=ra.person_id
    AND p.active_ind=1)
   JOIN (e
   WHERE e.encntr_id=ra.encntr_id
    AND e.active_ind=1)
  HEAD REPORT
   pat_counter = 0
  DETAIL
   pat_counter = (pat_counter+ 1), stat = alterlist(patients->list,pat_counter), patients->list[
   pat_counter].name = p.name_full_formatted,
   patients->list[pat_counter].person_id = ra.person_id, patients->list[pat_counter].encntr_id = ra
   .encntr_id, patients->list[pat_counter].ra_id = ra.risk_adjustment_id,
   patients->list[pat_counter].hosp_disch_dt_tm = e.disch_dt_tm, patients->list[pat_counter].
   icu_admit_dt_tm = ra.icu_admit_dt_tm, patients->list[pat_counter].icu_disch_dt_tm = ra
   .icu_disch_dt_tm
   IF (e.disch_disposition_cd IN (deceased_cd, expired_cd))
    patients->list[pat_counter].died_in_hosp_ind = 1
   ELSEIF (p.deceased_dt_tm > e.reg_dt_tm
    AND p.deceased_dt_tm <= e.disch_dt_tm)
    patients->list[pat_counter].died_in_hosp_ind = 1
   ENDIF
   IF (cnvtdatetime(e.disch_dt_tm) > cnvtdatetime(ra.icu_admit_dt_tm))
    patients->list[pat_counter].icu_disch_dt_tm = cnvtdatetime(e.disch_dt_tm)
    IF ((patients->list[pat_counter].died_in_hosp_ind=1))
     patients->list[pat_counter].died_in_icu_ind = 1
    ENDIF
    transfer_count = (transfer_count+ 1),
    CALL echo(build("got an encounter discharge for ",p.name_full_formatted))
   ENDIF
  WITH nocounter
 ;end select
 CALL echorecord(patients)
 SET reply->status_data.status = "S"
 IF (curqual <= 0)
  GO TO 9999_exit_program
 ENDIF
 SET pat_array_size = size(patients->list,5)
 DECLARE strip_seconds = c2 WITH protect, constant("MI")
 RECORD temp_last_icu(
   1 icu_disch_dt_tm = dq8
 )
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = pat_array_size),
   encntr_loc_hist elh,
   location l
  PLAN (d)
   JOIN (elh
   WHERE (elh.encntr_id=patients->list[d.seq].encntr_id)
    AND elh.active_ind=1
    AND datetimetrunc(elh.transaction_dt_tm,strip_seconds) > cnvtdatetime(patients->list[d.seq].
    icu_admit_dt_tm)
    AND datetimetrunc(elh.transaction_dt_tm,strip_seconds) < cnvtdatetime(patients->list[d.seq].
    icu_disch_dt_tm))
   JOIN (l
   WHERE l.location_cd=elh.loc_nurse_unit_cd)
  ORDER BY d.seq, elh.transaction_dt_tm
  HEAD d.seq
   got_transfer = 0, patients->list[d.seq].died_in_icu_ind = 0, got_trans_icu = 0,
   temp_last_icu->icu_disch_dt_tm = 0
  DETAIL
   IF (got_transfer=0
    AND l.icu_ind != 1)
    IF (got_trans_icu=0)
     temp_last_icu->icu_disch_dt_tm = datetimetrunc(elh.transaction_dt_tm,strip_seconds),
     got_trans_icu = 1
    ENDIF
    IF (((l.apache_reltn_flag != 1) OR ((patients->list[d.seq].died_in_hosp_ind=1))) )
     CALL echo(build("RA_ID=",patients->list[d.seq].ra_id)),
     CALL echo(build("not an ICU",d.seq,"loc=",patients->list[d.seq].loc_name)),
     CALL echo(build("going to unit",elh.loc_nurse_unit_cd)),
     CALL echo(build("patient being discharged =",patients->list[d.seq].name)), patients->list[d.seq]
     .icu_disch_dt_tm = temp_last_icu->icu_disch_dt_tm, got_transfer = 1,
     transfer_count = (transfer_count+ 1)
    ENDIF
   ENDIF
   IF (l.icu_ind=1)
    got_transfer = 0, got_trans_icu = 0
   ENDIF
  FOOT  d.seq
   IF ((patients->list[d.seq].died_in_hosp_ind=1)
    AND cnvtdatetime(patients->list[d.seq].icu_disch_dt_tm)=cnvtdatetime(patients->list[d.seq].
    hosp_disch_dt_tm))
    patients->list[d.seq].died_in_icu_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 CALL echorecord(patients)
 CALL echo(build("transfer_count=",transfer_count))
 IF (transfer_count > 0)
  FOR (finalloopcnt = 1 TO pat_array_size)
    IF (cnvtdatetime(patients->list[finalloopcnt].icu_disch_dt_tm) != cnvtdatetime("31-DEC-2100"))
     CALL echo(build("GOING TO CHANGE A DISCHARGE DATE",finalloopcnt,patients->list[finalloopcnt].
       icu_disch_dt_tm))
     SET disch_request->risk_adjustment_id = patients->list[finalloopcnt].ra_id
     SET disch_request->admit_time_chg_ind = 0
     SET disch_request->new_icu_admit_dt_tm = cnvtdatetime(patients->list[finalloopcnt].
      icu_admit_dt_tm)
     SET disch_request->disch_time_chg_ind = 1
     SET disch_request->new_icu_disch_dt_tm = cnvtdatetime(patients->list[finalloopcnt].
      icu_disch_dt_tm)
     CALL echorecord(disch_request)
     CALL echo("setting died in ICU!!!!")
     UPDATE  FROM risk_adjustment ra
      SET ra.diedinicu_ind = patients->list[finalloopcnt].died_in_icu_ind, ra.updt_cnt = (updt_cnt+ 1
       ), ra.updt_dt_tm = cnvtdatetime(curdate,curtime3)
      WHERE (ra.risk_adjustment_id=patients->list[finalloopcnt].ra_id)
      WITH nocounter
     ;end update
     EXECUTE dcp_upd_apache_adm_disch:dba  WITH replace("REQUEST","DISCH_REQUEST"), replace("REPLY",
      "DISCH_REPLY")
    ENDIF
  ENDFOR
 ENDIF
#9999_exit_program
 CALL echorecord(reply)
END GO
