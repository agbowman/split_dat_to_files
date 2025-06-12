CREATE PROGRAM dcp_apache_subencntrs:dba
 RECORD reply(
   1 plist[*]
     2 person_id = f8
     2 encntr_id = f8
     2 selist[*]
       3 nu_room_bed_disp = vc
       3 icu_admit_dt_tm = dq8
       3 icu_disch_dt_tm = dq8
       3 risk_adjustment_id = f8
       3 error_code = f8
       3 error_string = vc
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
 SET ambulatory_type_cd = meaning_code(222,"AMBULATORY")
 SET census_type_cd = meaning_code(339,"CENSUS")
 SET nurse_unit_type_cd = meaning_code(222,"NURSEUNIT")
 SET room_type_cd = meaning_code(222,"ROOM")
 SET attend_doc_cd = meaning_code(333,"ATTENDDOC")
 DECLARE nu_rm_bd = vc
 SET pcnt = size(request->plist,5)
 SET stat = alterlist(reply->plist,pcnt)
 SET day_str = "   "
 DECLARE f_text = vc
#1999_initialize_exit
#2000_read
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(pcnt)),
   risk_adjustment ra,
   encounter e,
   encntr_loc_hist elh
  PLAN (d)
   JOIN (ra
   WHERE (ra.person_id=request->plist[d.seq].person_id)
    AND (ra.encntr_id=request->plist[d.seq].encntr_id)
    AND ra.active_ind=1)
   JOIN (e
   WHERE e.encntr_id=ra.encntr_id)
   JOIN (elh
   WHERE outerjoin(e.encntr_id)=elh.encntr_id)
  ORDER BY d.seq, cnvtdatetime(ra.icu_admit_dt_tm)
  HEAD d.seq
   reply->plist[d.seq].person_id = request->plist[d.seq].person_id, reply->plist[d.seq].encntr_id =
   request->plist[d.seq].encntr_id, secnt = 0
  HEAD ra.icu_admit_dt_tm
   secnt = (secnt+ 1), stat = alterlist(reply->plist[d.seq].selist,secnt), reply->plist[d.seq].
   selist[secnt].icu_admit_dt_tm = cnvtdatetime(ra.icu_admit_dt_tm),
   reply->plist[d.seq].selist[secnt].icu_disch_dt_tm = cnvtdatetime(ra.icu_disch_dt_tm), reply->
   plist[d.seq].selist[secnt].risk_adjustment_id = ra.risk_adjustment_id, nu_rm_bd = " "
  DETAIL
   IF (elh.encntr_loc_hist_id > 0
    AND ra.icu_admit_dt_tm >= cnvtdatetime(elh.beg_effective_dt_tm)
    AND ra.icu_admit_dt_tm <= cnvtdatetime(elh.end_effective_dt_tm))
    nu = trim(uar_get_code_display(elh.loc_nurse_unit_cd)), rm = trim(uar_get_code_display(elh
      .loc_room_cd)), bd = trim(uar_get_code_display(elh.loc_bed_cd))
    IF (rm > " ")
     nu_rm_bd = build(nu,":",rm)
     IF (bd > " ")
      nu_rm_bd = build(nu_rm_bd,"-",bd)
     ENDIF
    ELSE
     nu_rm_bd = nu
    ENDIF
    reply->plist[d.seq].selist[secnt].nu_room_bed_disp = trim(nu_rm_bd)
   ELSE
    nu = trim(uar_get_code_display(e.loc_nurse_unit_cd)), rm = trim(uar_get_code_display(e
      .loc_room_cd)), bd = trim(uar_get_code_display(e.loc_bed_cd))
    IF (rm > " ")
     nu_rm_bd = build(nu,":",rm)
     IF (bd > " ")
      nu_rm_bd = build(nu_rm_bd,"-",bd)
     ENDIF
    ELSE
     nu_rm_bd = nu
    ENDIF
    reply->plist[d.seq].selist[secnt].nu_room_bed_disp = trim(nu_rm_bd)
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
  FOR (x = 1 TO pcnt)
   SET secnt = size(reply->plist[x].selist,5)
   FOR (y = 1 TO secnt)
     SELECT INTO "nl:"
      FROM risk_adjustment_day rad
      PLAN (rad
       WHERE (rad.risk_adjustment_id=reply->plist[x].selist[y].risk_adjustment_id)
        AND rad.active_ind=1)
      ORDER BY rad.cc_day DESC
      HEAD REPORT
       eflag = "N"
      DETAIL
       IF (rad.outcome_status < 0)
        ecode = rad.outcome_status, eflag = "Y", day_str = cnvtstring(rad.cc_day,3,0,r)
        IF (day_str="00*")
         day_str = cnvtstring(rad.cc_day,2,0,r)
         IF (day_str="0*")
          day_str = cnvtstring(rad.cc_day,1,0,r)
         ENDIF
        ENDIF
       ENDIF
      FOOT REPORT
       IF (eflag="Y")
        reply->plist[x].selist[y].error_code = ecode
       ENDIF
      WITH nocounter
     ;end select
     IF ((reply->plist[x].selist[y].error_code < 0))
      CASE (reply->plist[x].selist[y].error_code)
       OF - (22001):
        SET f_text = concat("Valid Temperature required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (22002):
        SET f_text = concat("Valid Heart Rate required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (22003):
        SET f_text = concat("Valid Resp Rate required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (22004):
        SET f_text = concat("Valid Mean BP required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (22005):
        SET f_text = concat("Valid Sodium required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (22006):
        SET f_text = concat("Valid Glucose required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (22007):
        SET f_text = concat("Valid Albumin required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (22008):
        SET f_text = concat("Valid Creatinine required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (22009):
        SET f_text = concat("Valid BUN required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (22010):
        SET f_text = concat("Valid WBC required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (22011):
        SET f_text = concat("Valid Urine Output required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (22012):
        SET f_text = concat("Valid Bilirubin required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (22013):
        SET f_text = concat("Valid PCO2 & pH required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (22014):
        SET f_text = concat("Valid Hematocrit required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (22015):
        SET f_text = concat("Valid paO2 & pcO2 required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (22017):
        SET f_text = concat("Valid values for meds, eyes, motor & verbal required (Day ",trim(day_str
          ),"). Unable to calculate predictions.")
       OF - (22018):
        SET f_text = concat("Valid Heart Rate, Resp Rate & Mean BP required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (22019):
        SET f_text = concat("Minimum of 4 valid lab values required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23009):
        SET f_text = concat("Valid ICU Day required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23010):
        SET f_text = concat("Valid APS for today required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23011):
        SET f_text = concat("Valid APS for day one required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23013):
        SET f_text = concat("Valid DOB required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23014):
        SET f_text = concat("Valid Hosp Admit Date required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23015):
        SET f_text = concat("Valid ICU Admit Date required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23016):
        SET f_text = concat("Valid Admission Diagnosis required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23017):
        SET f_text = concat("Valid Admission Source required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23018):
        SET f_text = concat("Valid gender required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23019):
        SET f_text = concat("Valid Meds Indicator required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23020):
        SET f_text = concat("Valid Eye value (GCS) required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23021):
        SET f_text = concat("Valid Motor value (GCS) required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23022):
        SET f_text = concat("Valid Verbal value (GCS) required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23023):
        SET f_text = concat("Valid Thrombolytics Indicator required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23024):
        SET f_text = concat("Valid AIDS Indicator required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23025):
        SET f_text = concat("Valid Hepatic Failure Indicator required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23026):
        SET f_text = concat("Valid Lymphoma Indicator required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23027):
        SET f_text = concat("Valid Metastatic Cancer Indicator required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23028):
        SET f_text = concat("Valid Leukemia Indicator required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23029):
        SET f_text = concat("Valid Immunosuppression Indicator required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23030):
        SET f_text = concat("Valid Cirrhosis Indicator required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23031):
        SET f_text = concat("Valid Elective Surgery Indicator required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23032):
        SET f_text = concat("Valid Active Treatment Indicator required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23033):
        SET f_text = concat("Valid chronic health information required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23034):
        SET f_text = concat("Valid readmission information required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23035):
        SET f_text = concat("Valid internal mammory artery information required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23036):
        SET f_text = "Unable to calculate predictions, Hosp admission date is too early."
       OF - (23037):
        SET f_text = concat("Valid Eye value (GCS) required for Day 1(Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23038):
        SET f_text = concat("Valid Motor value (GCS) required for Day 1(Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23039):
        SET f_text = concat("Valid Verbal value (GCS) required for Day 1(Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23040):
        SET f_text = "Unable to calculate predictions, ICU admission date is too early."
       OF - (23100):
        SET f_text = "Nonpredictive diagnosis, unable to calculate predictions."
       OF - (23103):
        SET f_text = "Nonpredictive patient age (<16 years), unable to calculate predictions."
       OF - (23110):
        SET f_text = "Invalid Age, unable to calculate predictions."
       OF - (23115):
        SET f_text = concat("Valid Creatinine required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23116):
        SET f_text = concat("Valid Eject FX information required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23117):
        SET f_text = "Nonpredictive admission source (ICU), unable to calculate predictions."
       OF - (23118):
        SET f_text = concat("Valid Dicharge Location required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23119):
        SET f_text = concat("Valid Visit Number information required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23120):
        SET f_text = concat("Valid AMI Location information required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       ELSE
        SET f_text = concat("An unrecognized error occurred - error number ",cnvtstring(reply->plist[
          x].selist[y].error_code)," (Day ",trim(day_str),"). Unable to calculate predictions.")
      ENDCASE
      SET reply->plist[x].selist[y].error_string = f_text
     ENDIF
     IF ((reply->plist[x].selist[y].error_code=- (1)))
      SELECT INTO "nl:"
       FROM risk_adjustment_day rad
       PLAN (rad
        WHERE (rad.risk_adjustment_id=reply->plist[x].selist[y].risk_adjustment_id)
         AND rad.active_ind=1)
       ORDER BY rad.cc_day
       HEAD REPORT
        missed_day_found = "N", compare_nbr = 1, missed_day = 0
       DETAIL
        IF (missed_day_found="N")
         IF (rad.cc_day=compare_nbr)
          compare_nbr = (compare_nbr+ 1)
         ELSE
          missed_day = compare_nbr, missed_day_found = "Y", day_str = cnvtstring(compare_nbr,3,0,r)
         ENDIF
        ENDIF
       FOOT REPORT
        IF (missed_day > 0
         AND missed_day_found="Y")
         IF (day_str="00*")
          day_str = cnvtstring(missed_day,2,0,r)
          IF (day_str="0*")
           day_str = cnvtstring(missed_day,1,0,r)
          ENDIF
         ENDIF
         reply->plist[x].selist[y].error_string = concat("Missing data for day ",day_str,
          ". Unable to calculate predictions.")
        ENDIF
       WITH nocounter
      ;end select
     ENDIF
   ENDFOR
  ENDFOR
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#2999_read_exit
#9999_exit_program
 CALL echorecord(reply)
END GO
