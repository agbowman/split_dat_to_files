CREATE PROGRAM dcp_apache_patientlist:dba
 RECORD reply(
   1 plist[*]
     2 name_full_formatted = vc
     2 mrn = vc
     2 person_id = f8
     2 elist[*]
       3 fin = vc
       3 reg_dt_tm = dq8
       3 disch_dt_tm = dq8
       3 encntr_id = f8
       3 selist[*]
         4 nu_room_bed_disp = vc
         4 icu_admit_dt_tm = dq8
         4 icu_disch_dt_tm = dq8
         4 risk_adjustment_id = f8
         4 error_code = f8
         4 error_string = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = vc
       3 operationstatus = c1
       3 targetobjectname = vc
       3 targetobjectvalue = vc
 )
 DECLARE meaning_code(p1,p2) = f8
 DECLARE get_error_string(p1=f8,p2=vc) = vc
 EXECUTE FROM 1000_initialize TO 1099_initialize_exit
 EXECUTE FROM 2000_read TO 2099_read_exit
 GO TO 9999_exit_program
#1000_initialize
 SET reply->status_data.status = "F"
 SET pcnt = 0
 SET ecnt = 0
 SET secnt = 0
 SET ra_entry_found = "N"
 SET facility_cd = 0.0
 SET building_cd = 0.0
 SET nurse_unit_cd = 0.0
 IF ((request->loc_nurse_unit_cd > 0.0))
  SELECT INTO "nl:"
   FROM nurse_unit nu
   PLAN (nu
    WHERE (nu.location_cd=request->loc_nurse_unit_cd))
   DETAIL
    facility_cd = nu.loc_facility_cd, building_cd = nu.loc_building_cd, nurse_unit_cd = nu
    .location_cd
   WITH nocounter
  ;end select
  SET disch_dt_tm = cnvtdatetime("31-DEC-2100")
 ELSE
  IF ((request->active_pts_only=1))
   SET disch_dt_tm = cnvtdatetime("31-DEC-2100")
  ELSE
   SET disch_dt_tm = cnvtdatetime((curdate - 730),0)
  ENDIF
 ENDIF
 DECLARE nu_rm_bd = vc
 DECLARE nu = vc
 DECLARE rm = vc
 DECLARE bd = vc
 SET fin_cd = meaning_code(319,"FIN NBR")
 SET mrn_cd = meaning_code(319,"MRN")
 SET lookback_dt_tm = cnvtdatetime((curdate - 120),0)
 DECLARE f_text = vc
 SET day_str = "   "
#1099_initialize_exit
#2000_read
 RECORD temp(
   1 ra_list[*]
     2 ra_id = f8
     2 max_cc_day = i4
     2 rad_id = f8
     2 error_code = f8
 )
 SELECT INTO "nl:"
  day = min(rad.cc_day), rad.risk_adjustment_id
  FROM risk_adjustment_day rad,
   risk_adjustment ra
  PLAN (ra
   WHERE ra.active_ind=1)
   JOIN (rad
   WHERE rad.risk_adjustment_id=ra.risk_adjustment_id
    AND rad.active_ind=1
    AND rad.outcome_status < 0)
  GROUP BY rad.risk_adjustment_id
  HEAD REPORT
   tmp_cnt = 0
  FOOT  rad.risk_adjustment_id
   tmp_cnt = (tmp_cnt+ 1)
   IF (mod(tmp_cnt,100)=1)
    stat = alterlist(temp->ra_list,(tmp_cnt+ 99))
   ENDIF
   temp->ra_list[tmp_cnt].ra_id = rad.risk_adjustment_id, temp->ra_list[tmp_cnt].max_cc_day = day
  WITH nocounter
 ;end select
 DECLARE num = i4
 DECLARE num2 = i4
 DECLARE index = i4
 DECLARE index2 = i4
 SET listsize = size(temp->ra_list,5)
 SET tmp_batch_size = 50
 SET batch_size = tmp_batch_size
 IF (listsize < tmp_batch_size)
  SET batch_size = listsize
 ENDIF
 SET loop_cnt = ceil((cnvtreal(listsize)/ batch_size))
 SET nstart = 1
 SET new_list_size = (loop_cnt * batch_size)
 SET stat = alterlist(temp->ra_list,new_list_size)
 FOR (idx = (listsize+ 1) TO new_list_size)
  SET temp->ra_list[idx].ra_id = temp->ra_list[listsize].ra_id
  SET temp->ra_list[idx].max_cc_day = temp->ra_list[listsize].max_cc_day
 ENDFOR
 SELECT INTO "nl:"
  FROM risk_adjustment_day rad,
   (dummyt d  WITH seq = value(loop_cnt))
  PLAN (d
   WHERE assign(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
   JOIN (rad
   WHERE expand(num,nstart,(nstart+ (batch_size - 1)),rad.risk_adjustment_id,temp->ra_list[num].ra_id,
    rad.cc_day,temp->ra_list[num].max_cc_day)
    AND rad.active_ind=1)
  DETAIL
   index = locateval(num,1,listsize,rad.risk_adjustment_id,temp->ra_list[num].ra_id)
   IF (index > 0)
    temp->ra_list[index].rad_id = rad.risk_adjustment_day_id, temp->ra_list[index].error_code = rad
    .outcome_status
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(temp->ra_list,listsize)
 IF ((request->active_pts_only=1))
  SELECT INTO "nl:"
   FROM risk_adjustment ra,
    risk_adjustment_day rad,
    person p,
    encounter e
   PLAN (ra
    WHERE ra.active_ind=1)
    JOIN (rad
    WHERE rad.risk_adjustment_id=ra.risk_adjustment_id
     AND rad.cc_day=1
     AND rad.active_ind=1
     AND ((ra.icu_disch_dt_tm=cnvtdatetime("31-DEC-2100")) OR (ra.icu_disch_dt_tm < cnvtdatetime(
     "31-DEC-2100")
     AND  NOT (((rad.outcome_status >= 0) OR (rad.outcome_status IN (- (23117), - (23100), - (23103))
    )) ))) )
    JOIN (p
    WHERE p.person_id=ra.person_id
     AND p.active_ind=1)
    JOIN (e
    WHERE e.encntr_id=ra.encntr_id
     AND e.active_ind=1)
   ORDER BY ra.person_id, ra.encntr_id, cnvtdatetime(ra.icu_admit_dt_tm)
   HEAD REPORT
    pcnt = 0, ecnt = 0, secnt = 0
   DETAIL
    pcnt = (pcnt+ 1)
    IF (mod(pcnt,100)=1)
     stat = alterlist(reply->plist,(pcnt+ 99))
    ENDIF
    reply->plist[pcnt].person_id = ra.person_id, reply->plist[pcnt].name_full_formatted = p
    .name_full_formatted, ecnt = 1,
    stat = alterlist(reply->plist[pcnt].elist,ecnt), reply->plist[pcnt].elist[ecnt].encntr_id = ra
    .encntr_id, reply->plist[pcnt].elist[ecnt].reg_dt_tm = cnvtdatetime(e.reg_dt_tm),
    reply->plist[pcnt].elist[ecnt].disch_dt_tm = cnvtdatetime(e.disch_dt_tm), secnt = 1, stat =
    alterlist(reply->plist[pcnt].elist[ecnt].selist,secnt),
    reply->plist[pcnt].elist[ecnt].selist[secnt].icu_admit_dt_tm = cnvtdatetime(ra.icu_admit_dt_tm)
    IF (ra.icu_disch_dt_tm < cnvtdatetime("31-DEC-2100"))
     reply->plist[pcnt].elist[ecnt].selist[secnt].icu_disch_dt_tm = cnvtdatetime(ra.icu_disch_dt_tm)
    ELSE
     reply->plist[pcnt].elist[ecnt].selist[secnt].icu_disch_dt_tm = 0
    ENDIF
    reply->plist[pcnt].elist[ecnt].selist[secnt].risk_adjustment_id = ra.risk_adjustment_id, index2
     = locateval(num2,1,listsize,reply->plist[pcnt].elist[1].selist[1].risk_adjustment_id,temp->
     ra_list[num2].ra_id)
    IF (index2 > 0)
     reply->plist[pcnt].elist[1].selist[1].error_code = temp->ra_list[index2].error_code, day_str =
     cnvtstring(temp->ra_list[index2].max_cc_day,3,0,r)
     IF (day_str="00*")
      day_str = cnvtstring(temp->ra_list[index2].max_cc_day,2,0,rs)
      IF (day_str="0*")
       day_str = cnvtstring(temp->ra_list[index2].max_cc_day,1,0,r)
      ENDIF
     ENDIF
     reply->plist[pcnt].elist[1].selist[1].error_string = get_error_string(temp->ra_list[index2].
      error_code,day_str)
    ENDIF
   FOOT REPORT
    stat = alterlist(reply->plist,pcnt)
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM risk_adjustment ra,
    risk_adjustment_day rad,
    person p,
    encounter e
   PLAN (ra
    WHERE ra.active_ind=1
     AND ra.icu_disch_dt_tm < cnvtdatetime("31-DEC-2100"))
    JOIN (rad
    WHERE ra.risk_adjustment_id=rad.risk_adjustment_id
     AND rad.cc_day=1
     AND rad.active_ind=1
     AND ((rad.outcome_status >= 0) OR (rad.outcome_status IN (- (23117), - (23100), - (23103)))) )
    JOIN (p
    WHERE p.person_id=ra.person_id
     AND p.active_ind=1)
    JOIN (e
    WHERE e.encntr_id=ra.encntr_id
     AND ((e.disch_dt_tm >= cnvtdatetime(lookback_dt_tm)) OR (e.disch_dt_tm=null))
     AND e.active_ind=1)
   ORDER BY ra.person_id, ra.encntr_id, cnvtdatetime(ra.icu_admit_dt_tm)
   HEAD REPORT
    pcnt = 0, ecnt = 0, secnt = 0
   DETAIL
    pcnt = (pcnt+ 1)
    IF (mod(pcnt,100)=1)
     stat = alterlist(reply->plist,(pcnt+ 99))
    ENDIF
    reply->plist[pcnt].person_id = ra.person_id, reply->plist[pcnt].name_full_formatted = p
    .name_full_formatted, ecnt = 1,
    stat = alterlist(reply->plist[pcnt].elist,ecnt), reply->plist[pcnt].elist[ecnt].encntr_id = ra
    .encntr_id, reply->plist[pcnt].elist[ecnt].reg_dt_tm = cnvtdatetime(e.reg_dt_tm),
    reply->plist[pcnt].elist[ecnt].disch_dt_tm = cnvtdatetime(e.disch_dt_tm), secnt = 1, stat =
    alterlist(reply->plist[pcnt].elist[ecnt].selist,secnt),
    reply->plist[pcnt].elist[ecnt].selist[secnt].icu_admit_dt_tm = cnvtdatetime(ra.icu_admit_dt_tm)
    IF (ra.icu_disch_dt_tm < cnvtdatetime("31-DEC-2100"))
     reply->plist[pcnt].elist[ecnt].selist[secnt].icu_disch_dt_tm = cnvtdatetime(ra.icu_disch_dt_tm)
    ELSE
     reply->plist[pcnt].elist[ecnt].selist[secnt].icu_disch_dt_tm = 0
    ENDIF
    reply->plist[pcnt].elist[ecnt].selist[secnt].risk_adjustment_id = ra.risk_adjustment_id, reply->
    plist[pcnt].elist[ecnt].selist[secnt].error_code = 0, index2 = locateval(num2,1,listsize,reply->
     plist[pcnt].elist[1].selist[1].risk_adjustment_id,temp->ra_list[num2].ra_id)
    IF (index2 > 0)
     reply->plist[pcnt].elist[1].selist[1].error_code = temp->ra_list[index2].error_code, day_str =
     cnvtstring(temp->ra_list[index2].max_cc_day,3,0,r)
     IF (day_str="00*")
      day_str = cnvtstring(temp->ra_list[index2].max_cc_day,2,0,rs)
      IF (day_str="0*")
       day_str = cnvtstring(temp->ra_list[index2].max_cc_day,1,0,r)
      ENDIF
     ENDIF
     reply->plist[pcnt].elist[1].selist[1].error_string = get_error_string(temp->ra_list[index2].
      error_code,day_str)
    ENDIF
   FOOT REPORT
    stat = alterlist(reply->plist,pcnt)
   WITH nocounter
  ;end select
 ENDIF
 SET replysize = size(reply->plist,5)
 IF (replysize > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 IF (replysize > 0)
  SET tmp_batch_size = 100
  SET batch_size = tmp_batch_size
  IF (replysize < tmp_batch_size)
   SET batch_size = replysize
  ENDIF
  SET loop_cnt = ceil((cnvtreal(replysize)/ batch_size))
  SET nstart = 1
  SET new_list_size = (loop_cnt * batch_size)
  SET stat = alterlist(reply->plist,new_list_size)
  FOR (idx = (replysize+ 1) TO new_list_size)
    SET reply->plist[idx].person_id = reply->plist[replysize].person_id
    SET stat = alterlist(reply->plist[idx].elist,1)
    SET stat = alterlist(reply->plist[idx].elist[1].selist,1)
    SET reply->plist[idx].elist[1].encntr_id = reply->plist[replysize].elist[1].encntr_id
    SET reply->plist[idx].elist[1].selist[1].icu_admit_dt_tm = reply->plist[replysize].elist[1].
    selist[1].icu_admit_dt_tm
    SET reply->plist[idx].elist[1].selist[1].icu_disch_dt_tm = reply->plist[replysize].elist[1].
    selist[1].icu_disch_dt_tm
    SET reply->plist[idx].elist[1].selist[1].error_code = reply->plist[replysize].elist[1].selist[1].
    error_code
  ENDFOR
  SELECT INTO "nl:"
   FROM encntr_loc_hist elh,
    (dummyt d  WITH seq = value(loop_cnt))
   PLAN (d
    WHERE assign(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
    JOIN (elh
    WHERE expand(num,nstart,(nstart+ (batch_size - 1)),elh.encntr_id,reply->plist[num].elist[1].
     encntr_id)
     AND elh.active_ind=1
     AND elh.loc_nurse_unit_cd > 0.0)
   ORDER BY elh.encntr_id, elh.end_effective_dt_tm DESC, elh.beg_effective_dt_tm DESC
   HEAD elh.encntr_id
    index = locateval(num,1,replysize,elh.encntr_id,reply->plist[num].elist[1].encntr_id), nu_rm_bd
     = " "
    IF (elh.encntr_loc_hist_id > 0)
     nu = trim(uar_get_code_display(elh.loc_nurse_unit_cd)), rm = trim(uar_get_code_display(elh
       .loc_room_cd)), bd = trim(uar_get_code_display(elh.loc_bed_cd))
     IF (rm > " ")
      nu_rm_bd = concat(nu,":",rm)
      IF (bd > " ")
       nu_rm_bd = concat(nu_rm_bd,"-",bd)
      ENDIF
     ELSE
      nu_rm_bd = nu
     ENDIF
    ENDIF
    WHILE (index > 0)
     reply->plist[index].elist[1].selist[1].nu_room_bed_disp = nu_rm_bd,index = locateval(num,(index
      + 1),replysize,elh.encntr_id,reply->plist[num].elist[1].encntr_id)
    ENDWHILE
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM encntr_alias ea,
    (dummyt d  WITH seq = value(loop_cnt))
   PLAN (d
    WHERE assign(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
    JOIN (ea
    WHERE expand(num,nstart,(nstart+ (batch_size - 1)),ea.encntr_id,reply->plist[num].elist[1].
     encntr_id)
     AND ea.encntr_alias_type_cd IN (fin_cd, mrn_cd)
     AND ea.active_ind=1
     AND ea.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
     AND ea.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   ORDER BY ea.end_effective_dt_tm DESC
   DETAIL
    index = locateval(num,1,replysize,ea.encntr_id,reply->plist[num].elist[1].encntr_id)
    WHILE (index > 0)
     IF (ea.encntr_alias_type_cd=fin_cd)
      reply->plist[index].elist[1].fin = cnvtalias(ea.alias,ea.alias_pool_cd)
     ELSEIF (ea.encntr_alias_type_cd=mrn_cd)
      reply->plist[index].mrn = cnvtalias(ea.alias,ea.alias_pool_cd)
     ENDIF
     ,index = locateval(num,(index+ 1),replysize,ea.encntr_id,reply->plist[num].elist[1].encntr_id)
    ENDWHILE
   WITH nocounter
  ;end select
  SET stat = alterlist(reply->plist,replysize)
 ENDIF
#2099_read_exit
 SUBROUTINE get_error_string(error_code,day_str)
   SET f_text = fillstring(500," ")
   IF (error_code < 0)
    CASE (error_code)
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
      SET f_text = concat("Valid values for meds, eyes, motor & verbal required (Day ",trim(day_str),
       "). Unable to calculate predictions.")
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
      SET f_text = concat("An unrecognized error occurred - error number ",cnvtstring(error_code),
       " (Day ",trim(day_str),"). Unable to calculate predictions.")
    ENDCASE
   ENDIF
   RETURN(f_text)
 END ;Subroutine
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
#9999_exit_program
 CALL echorecord(reply)
END GO
