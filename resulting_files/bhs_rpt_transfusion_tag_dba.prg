CREATE PROGRAM bhs_rpt_transfusion_tag:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "FIN:" = "801583707",
  "Form:" = 0
  WITH outdev, fin, form
 CALL echo("Inside bhs_rpt_home_care_discharge")
 SET formeventid =  $FORM
 DECLARE encntr_id = f8
 DECLARE errmsg = vc WITH noconstant(" ")
 IF (validate(request->visit[1].encntr_id)=1)
  SET encntr_id = request->visit[1].encntr_id
  SET outputdev = request->output_device
 ELSE
  SET outputdev =  $OUTDEV
  CALL echo("Get Encounter from FIN")
  SELECT INTO "NL:"
   FROM encntr_alias ea
   WHERE (ea.alias= $FIN)
    AND ea.active_ind=1
   HEAD ea.encntr_id
    encntr_id = ea.encntr_id
   WITH nocounter
  ;end select
 ENDIF
 IF (encntr_id <= 0)
  CALL echo("encntr failed")
  GO TO exit_program
 ENDIF
 DECLARE becont = i4
 DECLARE tempox = vc WITH noconstant(" ")
 CALL echo("declare constants")
 DECLARE cmrn = f8 WITH constant(validatecodevalue("MEANING",4,"CMRN")), protect
 DECLARE finnbr = f8 WITH constant(validatecodevalue("MEANING",319,"FIN NBR")), protect
 DECLARE orderdoc = f8 WITH constant(validatecodevalue("MEANING",333,"ORDERDOC")), protect
 DECLARE ordered = f8 WITH constant(validatecodevalue("DISPLAYKEY",6004,"ORDERED")), protect
 DECLARE canceled = f8 WITH constant(validatecodevalue("DISPLAYKEY",6004,"CANCELED")), protect
 DECLARE deleted = f8 WITH constant(validatecodevalue("DISPLAYKEY",6004,"DELETED")), protect
 DECLARE incomplete = f8 WITH constant(validatecodevalue("DISPLAYKEY",6004,"INCOMPLETE")), protect
 DECLARE orderedaction = f8 WITH constant(validatecodevalue("DISPLAYKEY",6003,"ORDER")), protect
 DECLARE altered = f8 WITH constant(validatecodevalue("MEANING",8,"ALTERED")), protect
 DECLARE modified = f8 WITH constant(validatecodevalue("MEANING",8,"MODIFIED")), protect
 DECLARE auth = f8 WITH constant(validatecodevalue("MEANING",8,"AUTH")), protect
 DECLARE primary = f8 WITH constant(validatecodevalue("DISPLAYKEY",6011,"PRIMARY")), protect
 DECLARE admit = f8 WITH constant(validatecodevalue("MEANING",17,"ADMIT")), protect
 DECLARE transfusiontagform = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,"TRANSFUSIONTAGFORM"
   )), protect
 DECLARE autotransfusionbloodrecoveryform = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "AUTOTRANSFUSIONBLOODRECOVERYFORM")), protect
 DECLARE ldh = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,"LDH")), protect
 DECLARE cbc = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,"CBC")), protect
 DECLARE inr = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,"INR")), protect
 DECLARE fibrinogen = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,"FIBRINOGEN")), protect
 DECLARE ntprobnp = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,"NTPROBNP")), protect
 DECLARE ptt = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,"PTT")), protect
 DECLARE reticcount = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,"RETICCOUNT")), protect
 DECLARE rh = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,"RH")), protect
 DECLARE abo = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,"ABO")), protect
 DECLARE bloodtype = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,"BLOODTYPE")), protect
 DECLARE antibodyscreen = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,"ANTIBODYSCREEN")),
 protect
 DECLARE pmhtroponintemplate = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "PMHTROPONINTEMPLATE")), protect
 DECLARE troponini = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,"TROPONINI")), protect
 DECLARE troponintquant = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,"TROPONINTQUANT")),
 protect
 DECLARE troponint1 = f8 WITH constant(709363), protect
 DECLARE troponint2 = f8 WITH constant(2821152), protect
 DECLARE rhtestonly1 = f8 WITH constant(709363), protect
 DECLARE rhtestonly2 = f8 WITH constant(2821152), protect
 DECLARE mf_transfusionstarttime = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "TRANSFUSIONSTARTTIME")), protect
 DECLARE mf_temperaturestart = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,"TEMPERATURESTART")
  ), protect
 DECLARE mf_temperatureroutestart = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "TEMPERATUREROUTESTART")), protect
 DECLARE mf_pulseratestart = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,"PULSERATESTART")),
 protect
 DECLARE mf_respiratoryratestart = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "RESPIRATORYRATESTART")), protect
 DECLARE mf_systolicbloodpressurestart = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "SYSTOLICBLOODPRESSURESTART")), protect
 DECLARE mf_diastolicbloodpressurestart = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "DIASTOLICBLOODPRESSURESTART")), protect
 DECLARE mf_oxygensaturationstart = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "OXYGENSATURATIONSTART")), protect
 DECLARE mf_transfusionstartplus15min = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "TRANSFUSIONSTARTPLUS15MIN")), protect
 DECLARE mf_temperature15min = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,"TEMPERATURE15MIN")
  ), protect
 DECLARE mf_temperatureroute15min = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "TEMPERATUREROUTE15MIN")), protect
 DECLARE mf_pulserate15min = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,"PULSERATE15MIN")),
 protect
 DECLARE mf_respiratoryrate15min = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "RESPIRATORYRATE15MIN")), protect
 DECLARE mf_systolicbloodpressure15min = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "SYSTOLICBLOODPRESSURE15MIN")), protect
 DECLARE mf_diastolicbloodpressure15min = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "DIASTOLICBLOODPRESSURE15MIN")), protect
 DECLARE mf_oxygensaturation15min = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "OXYGENSATURATION15MIN")), protect
 DECLARE mf_transfusionendtime = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "TRANSFUSIONENDTIME")), protect
 DECLARE mf_temperatureend = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,"TEMPERATUREEND")),
 protect
 DECLARE mf_temperaturerouteend = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "TEMPERATUREROUTEEND")), protect
 DECLARE mf_pulserateend = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,"PULSERATEEND")),
 protect
 DECLARE mf_respiratoryrateend = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "RESPIRATORYRATEEND")), protect
 DECLARE mf_systolicbloodpressureend = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "SYSTOLICBLOODPRESSUREEND")), protect
 DECLARE mf_diastolicbloodpressureend = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "DIASTOLICBLOODPRESSUREEND")), protect
 DECLARE mf_oxygensaturationend = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "OXYGENSATURATIONEND")), protect
 DECLARE mf_albuminvol = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,"ALBUMINVOL")), protect
 DECLARE mf_cryoprecipitate = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,"CRYOPRECIPITATE")),
 protect
 DECLARE mf_factorviia = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,"FACTORVIIA")), protect
 DECLARE mf_factorviiivol = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,"FACTORVIIIVOL")),
 protect
 DECLARE mf_factorixcomplex = f8
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE code_set=72
   AND display_key="FACTORIXCOMPLEX"
   AND display="Factor IX Complex"
   AND active_ind=1
  DETAIL
   mf_factorixcomplex = cv.code_value
  WITH nocounter
 ;end select
 DECLARE mf_factorixvol = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,"FACTORIXVOL")), protect
 DECLARE mf_ffp = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,"FFP")), protect
 DECLARE mf_granulocytes = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,"GRANULOCYTES")),
 protect
 DECLARE mf_ivig = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,"IVIG")), protect
 DECLARE mf_platelets = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,"PLATELETS")), protect
 DECLARE mf_rbcvol = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,"RBCVOL")), protect
 DECLARE mf_rhimmuneglobulin = f8 WITH constant(validatecodevalue("DISPLAY",72,"Rh Immune Globulin")),
 protect
 DECLARE mf_bloodproductamountinfused = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "BLOODPRODUCTAMOUNTINFUSED")), protect
 DECLARE mf_transfusionreactiondescription = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "TRANSFUSIONREACTIONDESCRIPTION")), protect
 DECLARE previousreactiontotransfusion = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "PREVIOUSREACTIONTOTRANSFUSION")), protect
 DECLARE bloodtransfusionreaction = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "BLOODTRANSFUSIONREACTION")), protect
 FREE RECORD info
 RECORD info(
   1 person_id = f8
   1 name = vc
   1 dob = vc
   1 cmrn = vc
   1 fin = vc
   1 orderingphy = vc
   1 lastnurseunit = vc
   1 admitdx = vc
   1 problems = vc
   1 formname = vc
   1 formdttm = vc
   1 previousreactionq = vc
   1 previousreaction = vc
   1 labs = vc
   1 labsval = vc
   1 labsdttm = vc
   1 intake = vc
   1 weight = vc
   1 meds = vc
   1 medsdttm = vc
   1 medsstatus = vc
   1 oxygen = vc
   1 oxygendttm = vc
   1 oxygenstatus = vc
   1 aborh = vc
   1 aborhval = vc
   1 aborhdttm = vc
   1 antibody = vc
   1 antibodyval = vc
   1 antibodydttm = vc
   1 transfusionstarttime = vc
   1 temperaturestart = vc
   1 temperatureroutestart = vc
   1 pulseratestart = vc
   1 respiratoryratestart = vc
   1 systolicbloodpressurestart = vc
   1 diastolicbloodpressurestart = vc
   1 oxygensaturationstart = vc
   1 transfusionstartplus15min = vc
   1 temperature15min = vc
   1 temperatureroute15min = vc
   1 pulserate15min = vc
   1 respiratoryrate15min = vc
   1 systolicbloodpressure15min = vc
   1 diastolicbloodpressure15min = vc
   1 oxygensaturation15min = vc
   1 transfusionendtime = vc
   1 temperatureend = vc
   1 temperaturerouteend = vc
   1 pulserateend = vc
   1 respiratoryrateend = vc
   1 systolicbloodpressureend = vc
   1 diastolicbloodpressureend = vc
   1 oxygensaturationend = vc
   1 amountinfused = vc
   1 transfusionreactiondescription = vc
 )
 SET info->name = "(No data available)"
 SET info->dob = "(No data available)"
 SET info->cmrn = "(No data available)"
 SET info->fin = "(No data available)"
 SET info->orderingphy = "(No data available)"
 SET info->lastnurseunit = "(No data available)"
 SET info->admitdx = "(No data available)"
 SET info->problems = "(No data available)"
 SET info->formname = "(No data available)"
 SET info->previousreactionq = "(No data available)"
 SET info->labs = "(No data available)"
 SET info->intake = "(No data available)"
 SET info->weight = "(No data available)"
 SET info->meds = "(No data available)"
 SET info->oxygen = "(No data available)"
 SET info->aborh = "(No data available)"
 SET info->antibody = "(No data available)"
 CALL echo(build("load patient demographics (FIN):", $FIN))
 SELECT INTO "NL:"
  FROM encounter e,
   person p,
   encntr_loc_hist elh,
   person_alias pa,
   encntr_alias ea
  PLAN (e
   WHERE e.encntr_id=encntr_id)
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (elh
   WHERE elh.encntr_id=e.encntr_id
    AND cnvtdatetime(curdate,curtime3) BETWEEN elh.beg_effective_dt_tm AND elh.end_effective_dt_tm
    AND elh.active_ind=1)
   JOIN (pa
   WHERE pa.person_id=outerjoin(p.person_id)
    AND pa.active_ind=outerjoin(1)
    AND pa.person_alias_type_cd=outerjoin(cmrn)
    AND outerjoin(cnvtdatetime(curdate,curtime3)) >= pa.beg_effective_dt_tm
    AND outerjoin(cnvtdatetime(curdate,curtime3)) <= pa.end_effective_dt_tm)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=finnbr
    AND ea.active_ind=1)
  DETAIL
   info->person_id = p.person_id, info->name = concat(trim(p.name_first,3)," ",trim(p.name_last,3)),
   info->dob = format(p.birth_dt_tm,"DD-MMM-YY HH:MM:SS;;q"),
   info->cmrn = trim(pa.alias,3), info->fin = trim(ea.alias,3), info->lastnurseunit =
   uar_get_code_display(e.loc_nurse_unit_cd)
  WITH format, separator = " "
 ;end select
 CALL echo("load admitting DX")
 SELECT INTO "NL:"
  d.beg_effective_dt_tm, d.diagnosis_id
  FROM diagnosis d
  WHERE d.encntr_id=encntr_id
   AND d.active_ind=1
   AND cnvtdatetime(curdate,curtime3) BETWEEN d.beg_effective_dt_tm AND d.end_effective_dt_tm
   AND d.diag_type_cd IN (admit)
  ORDER BY d.beg_effective_dt_tm
  HEAD REPORT
   stat = 0, cnt = 0, info->admitdx = " "
  DETAIL
   cnt = (cnt+ 1)
   IF (cnt > 1)
    info->admitdx = concat(info->admitdx,char(10))
   ENDIF
   info->admitdx = concat(info->admitdx,d.diagnosis_display)
  WITH nocounter
 ;end select
 CALL echo("load Problems")
 SELECT INTO "NL:"
  p.beg_effective_dt_tm, p.problem_id
  FROM problem p
  WHERE (p.person_id=info->person_id)
   AND p.active_ind=1
   AND cnvtdatetime(curdate,curtime3) BETWEEN p.beg_effective_dt_tm AND p.end_effective_dt_tm
   AND p.data_status_cd IN (altered, modified, auth)
  ORDER BY p.beg_effective_dt_tm
  HEAD REPORT
   stat = 0, cnt = 0, info->problems = " "
  DETAIL
   cnt = (cnt+ 1),
   CALL echo(cnt)
   IF (cnt > 1)
    info->problems = concat(info->problems,char(10)),
    CALL echo("test")
   ENDIF
   info->problems = concat(info->problems,p.annotated_display)
  WITH nocounter
 ;end select
 CALL echo("load instances of powerForms and DTAs")
 SELECT
  ce.event_end_dt_tm
  FROM clinical_event ce
  WHERE ce.encntr_id=encntr_id
   AND ce.event_cd IN (transfusiontagform, autotransfusionbloodrecoveryform,
  previousreactiontotransfusion, bloodtransfusionreaction)
   AND ce.result_status_cd IN (altered, modified, auth)
   AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
  ORDER BY ce.event_end_dt_tm DESC
  HEAD REPORT
   frmcnt = 0, info->formname = " "
  DETAIL
   IF (ce.event_cd IN (transfusiontagform))
    frmcnt = (frmcnt+ 1)
    IF (frmcnt > 1)
     info->formname = concat(info->formname,char(10)), info->formdttm = concat(info->formdttm,char(10
       ))
    ENDIF
    info->formdttm = concat(info->formdttm,format(cnvtdatetime(ce.event_end_dt_tm),
      "DD-MMM_YY HH:MM:SS;;q")), info->formname = concat(info->formname,uar_get_code_display(ce
      .event_cd))
   ELSEIF (ce.event_cd=previousreactiontotransfusion)
    info->previousreactionq = ce.event_tag
   ELSEIF (ce.event_cd=bloodtransfusionreaction)
    info->previousreaction = concat("Reaction: ",ce.event_tag)
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("load labs")
 SELECT
  ce.event_end_dt_tm
  FROM clinical_event ce
  WHERE ce.encntr_id=encntr_id
   AND ce.event_cd IN (ldh, cbc, inr, fibrinogen, ntprobnp,
  ptt, reticcount, rh, abo, bloodtype,
  rhtestonly1, rhtestonly2, antibodyscreen, troponini, troponintquant,
  troponint1, troponint2)
   AND ce.result_status_cd IN (altered, modified, auth)
   AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
   AND ce.view_level=1
   AND ce.publish_flag=1
   AND ce.result_val > " "
  ORDER BY ce.event_cd, ce.event_end_dt_tm DESC
  HEAD REPORT
   cnt = 0, cnt2 = 0, cnt3 = 0
  DETAIL
   IF (ce.event_cd IN (ldh, cbc, inr, fibrinogen, ntprobnp,
   ptt, reticcount)
    AND ce.event_end_dt_tm >= cnvtdatetime((curdate - 3),curtime3))
    cnt = (cnt+ 1)
    IF (cnt=1)
     info->labs = " "
    ELSE
     info->labs = concat(info->labs,char(10)), info->labsval = concat(info->labsval,char(10)), info->
     labsdttm = concat(info->labsdttm,char(10))
    ENDIF
    info->labsdttm = concat(info->labsdttm,format(cnvtdatetime(ce.event_end_dt_tm),
      "DD-MMM_YY HH:MM:SS;;q")), info->labs = concat(info->labs,uar_get_code_display(ce.event_cd)),
    info->labsval = concat(info->labsval,ce.result_val," ",uar_get_code_display(ce.result_units_cd))
   ELSEIF (ce.event_cd IN (rh, abo, bloodtype, rhtestonly1, rhtestonly2))
    cnt2 = (cnt2+ 1)
    IF (cnt2=1)
     info->aborh = " ", info->aborh = uar_get_code_display(ce.event_cd), info->aborhval = concat(ce
      .result_val," ",uar_get_code_display(ce.result_units_cd)),
     info->aborhdttm = format(cnvtdatetime(ce.event_end_dt_tm),"DD-MMM_YY HH:MM:SS;;q")
    ENDIF
   ELSEIF (ce.event_cd IN (antibodyscreen))
    cnt3 = (cnt3+ 1)
    IF (cnt3=1)
     info->antibody = " "
    ELSE
     info->antibody = concat(info->antibody,char(10)), info->antibodyval = concat(info->antibodyval,
      char(10)), info->antibodydttm = concat(info->antibodydttm,char(10))
    ENDIF
    info->antibodydttm = concat(info->antibodydttm,format(cnvtdatetime(ce.event_end_dt_tm),
      "DD-MMM_YY HH:MM:SS;;q")), info->antibody = concat(info->antibody,uar_get_code_display(ce
      .event_cd)), info->antibodyval = concat(info->antibodyval,ce.result_val," ",
     uar_get_code_display(ce.result_units_cd))
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("load IO and Vitals")
 FREE RECORD dlrec
 RECORD dlrec(
   1 encntr_total = i4
   1 seq[*]
     2 encntr_id = f8
     2 person_id = f8
     2 total_vitals = i4
     2 vitals[*]
       3 temp_result = vc
       3 temp_range = vc
       3 systolic_bp_result = vc
       3 systolic_bp_range = vc
       3 diastolic_bp_result = vc
       3 diastolic_bp_range = vc
       3 resp_rate_result = vc
       3 resp_rate_range = vc
       3 pulse_result = vc
       3 pulse_range = vc
       3 o2_sat_result = vc
       3 o2_sat_range = vc
       3 liters_per_min = vc
       3 mode_of_delivery = vc
     2 weights[*]
       3 weight_dt_tm = vc
       3 weight_value = vc
       3 weight_unit = vc
     2 weight_tot_unit = vc
     2 weight_change = f8
     2 weight_up_down = c5
     2 total_titrate_cnt = i4
     2 titrate[*]
       3 12_io_line = vc
       3 12_io_total = vc
       3 24_io_line = vc
       3 24_io_total = vc
     2 total_io = i4
     2 io[*]
       3 type = vc
       3 hour_range = vc
       3 io_line = vc
     2 intake_line_cnt = i4
     2 intake_line[*]
       3 column1 = vc
       3 column2 = vc
     2 output_line_cnt = i4
     2 output_line[*]
       3 column1 = vc
       3 column2 = vc
 ) WITH persistscript
 EXECUTE bhs_incl_rounds_get_vital_io
 SET dlrec->encntr_total = 1
 SET stat = alterlist(dlrec->seq,1)
 SET dlrec->seq[1].encntr_id = encntr_id
 SET dlrec->seq[1].person_id = info->person_id
 CALL echo("get IO")
 CALL get_io(0)
 CALL echo("get vitals")
 CALL get_vitals(0)
 FOR (x = 1 TO size(dlrec->seq[1].io,5))
   IF ((dlrec->seq[1].io[x].hour_range="12")
    AND (dlrec->seq[1].io[x].type="I"))
    IF (x=1)
     SET info->intake = " "
    ELSE
     SET info->intake = concat(info->intake,char(10))
    ENDIF
    SET info->intake = concat(info->intake,dlrec->seq[1].io[x].io_line)
   ENDIF
 ENDFOR
 IF (size(dlrec->seq[1].weights,5) > 0)
  SET info->weight = concat(dlrec->seq[1].weights[1].weight_value,dlrec->seq[1].weights[1].
   weight_unit,"  ",dlrec->seq[1].weights[1].weight_dt_tm)
 ENDIF
 CALL echorecord(info)
 CALL echo("load Med orders")
 SELECT INTO "nl:"
  oi.catalog_cd, o.orig_order_dt_tm
  FROM order_catalog_synonym ocs,
   order_ingredient oi,
   orders o
  PLAN (ocs
   WHERE ocs.mnemonic_key_cap IN ("ONDANSETRON", "ONDANSETRON HYDROCHLORIDE", "DIPHENHYDRAMINE",
   "DIPHENHYDRAMINE HYDROCHLORIDE", "PROMETHAZINE",
   "PROCHLORPERAZINE", "FAMOTIDINE", "EPINEPHRINE", "CALCIUM GLUCONATE 10% IV", "CALCIUM GLUCONATE",
   "CALCIUM CARBONATE", "MEPERIDINE", "LORAZEPAM", "HYDROCORTISONE", "FUROSEMIDE",
   "CIMETIDINE", "ACETAMINOPHEN")
    AND ocs.mnemonic_type_cd=primary)
   JOIN (o
   WHERE o.encntr_id=encntr_id
    AND  NOT (o.order_status_cd IN (canceled, deleted, incomplete)))
   JOIN (oi
   WHERE oi.order_id=o.order_id
    AND oi.catalog_cd=ocs.catalog_cd
    AND oi.action_sequence IN (
   (SELECT
    oa.action_sequence
    FROM order_action oa
    WHERE oa.order_id=o.order_id
     AND oa.action_type_cd=orderedaction)))
  ORDER BY oi.catalog_cd, o.orig_order_dt_tm DESC
  HEAD REPORT
   cnt = 0
  HEAD oi.catalog_cd
   orderadded = o.order_id, cnt = (cnt+ 1)
   IF (cnt=1)
    info->meds = " "
   ELSE
    info->meds = concat(info->meds,char(10)), info->medsdttm = concat(info->medsdttm,char(10)), info
    ->medsstatus = concat(info->medsstatus,char(10))
   ENDIF
   info->medsdttm = concat(info->medsdttm,format(cnvtdatetime(o.orig_order_dt_tm),
     "DD-MMM_YY HH:MM:SS;;q")), info->meds = concat(info->meds,
    IF (textlen(o.order_mnemonic) > 90) concat(substring(1,90,o.order_mnemonic),"...")
    ELSE o.order_mnemonic
    ENDIF
    ), info->medsstatus = concat(info->medsstatus,uar_get_code_display(o.order_status_cd)),
   CALL echo(o.order_id)
  HEAD o.orig_order_dt_tm
   stat = 0
  DETAIL
   IF (o.order_status_cd=ordered
    AND o.order_id != orderadded)
    cnt = (cnt+ 1), info->meds = concat(info->meds,char(10)), info->medsdttm = concat(info->medsdttm,
     char(10)),
    info->medsstatus = concat(info->medsstatus,char(10)), info->medsdttm = concat(info->medsdttm,
     format(cnvtdatetime(o.orig_order_dt_tm),"DD-MMM_YY HH:MM:SS;;q")), info->meds = concat(info->
     meds,
     IF (textlen(o.order_mnemonic) > 90) concat(substring(1,90,o.order_mnemonic),"...")
     ELSE o.order_mnemonic
     ENDIF
     ),
    info->medsstatus = concat(info->medsstatus,uar_get_code_display(o.order_status_cd))
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("load O2 orders")
 SELECT INTO "nl:"
  o.orig_order_dt_tm, o.order_id
  FROM order_catalog_synonym ocs,
   orders o,
   order_detail od,
   order_entry_fields oef1,
   dummyt d
  PLAN (ocs
   WHERE ocs.mnemonic_key_cap IN ("OXYGEN VIA*", "VENTILATOR*")
    AND ocs.mnemonic_type_cd=primary)
   JOIN (o
   WHERE o.encntr_id=encntr_id
    AND o.catalog_cd=ocs.catalog_cd
    AND  NOT (o.order_status_cd IN (canceled, deleted, incomplete)))
   JOIN (d)
   JOIN (od
   WHERE od.order_id=o.order_id
    AND od.oe_field_id IN (
   (SELECT
    oef.oe_field_id
    FROM order_entry_fields oef
    WHERE oef.oe_field_id=od.oe_field_id
     AND cnvtupper(oef.description) IN ("*FIO2*", "*LITER*"))))
   JOIN (oef1
   WHERE oef1.oe_field_id=od.oe_field_id)
  ORDER BY o.orig_order_dt_tm DESC, o.order_id
  HEAD REPORT
   cnt = 0
  HEAD o.order_id
   cnt = (cnt+ 1)
   IF (cnt=1)
    info->oxygen = " "
   ELSE
    info->oxygen = concat(info->oxygen,char(10)), info->oxygendttm = concat(info->oxygendttm,char(10)
     ), info->oxygenstatus = concat(info->oxygenstatus,char(10))
   ENDIF
   info->oxygendttm = concat(info->oxygendttm,format(cnvtdatetime(o.orig_order_dt_tm),
     "DD-MMM_YY HH:MM:SS;;q")), tempox = concat(trim(o.order_mnemonic,3)," - ",trim(oef1.description,
     3)," ",trim(od.oe_field_display_value,3)), info->oxygen = concat(info->oxygen,
    IF (textlen(tempox) > 90) concat(substring(1,90,o.order_mnemonic),"...")
    ELSE tempox
    ENDIF
    ),
   info->oxygenstatus = concat(info->oxygenstatus,uar_get_code_display(o.order_status_cd))
  WITH outerjoin = d
 ;end select
 CALL echo("load trans form DTAS")
 SELECT INTO "nl:"
  FROM clinical_event ce,
   clinical_event ce1,
   clinical_event ce2,
   prsnl pr
  PLAN (ce
   WHERE ce.encntr_id=encntr_id
    AND ce.event_id=formeventid
    AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime)
    AND ce.result_status_cd IN (altered, modified, auth))
   JOIN (ce1
   WHERE ce1.parent_event_id=ce.event_id
    AND ce1.valid_until_dt_tm >= cnvtdatetime(curdate,curtime)
    AND ce1.result_status_cd IN (altered, modified, auth))
   JOIN (ce2
   WHERE ce2.parent_event_id=ce1.event_id
    AND ce2.valid_until_dt_tm >= cnvtdatetime(curdate,curtime)
    AND ce2.result_status_cd IN (altered, modified, auth)
    AND ce2.event_cd IN (mf_transfusionstarttime, mf_temperaturestart, mf_temperatureroutestart,
   mf_pulseratestart, mf_respiratoryratestart,
   mf_systolicbloodpressurestart, mf_diastolicbloodpressurestart, mf_oxygensaturationstart,
   mf_transfusionstartplus15min, mf_temperature15min,
   mf_temperatureroute15min, mf_pulserate15min, mf_respiratoryrate15min,
   mf_systolicbloodpressure15min, mf_diastolicbloodpressure15min,
   mf_oxygensaturation15min, mf_transfusionendtime, mf_temperatureend, mf_temperaturerouteend,
   mf_pulserateend,
   mf_respiratoryrateend, mf_systolicbloodpressureend, mf_diastolicbloodpressureend,
   mf_oxygensaturationend, mf_albuminvol,
   mf_cryoprecipitate, mf_factorviia, mf_factorviiivol, mf_factorixcomplex, mf_factorixvol,
   mf_ffp, mf_granulocytes, mf_ivig, mf_platelets, mf_rbcvol,
   mf_rhimmuneglobulin, mf_bloodproductamountinfused, mf_transfusionreactiondescription))
   JOIN (pr
   WHERE pr.person_id=ce2.performed_prsnl_id)
  ORDER BY ce.encntr_id, ce.parent_event_id, ce1.parent_event_id,
   ce2.event_cd, ce2.event_end_dt_tm DESC
  HEAD ce.encntr_id
   i_instance_cnt = 0, i_consent_cnt = 0, i_vital_cnt = 0,
   i_infused_cnt = 0, i_reaction_cnt = 0
  HEAD ce.parent_event_id
   i_trandta_cnt = 0, i_consent_cnt = 0, i_vital_cnt = 0,
   i_infused_cnt = 0, i_reaction_cnt = 0, i_instance_cnt = (i_instance_cnt+ 1)
  HEAD ce2.event_cd
   s_tran_result = build2(trim(ce2.event_tag)," ",trim(uar_get_code_display(ce2.result_units_cd)))
   IF (ce2.event_cd=mf_transfusionstarttime)
    ready_time = concat(format(cnvtdate2(substring(3,8,ce2.event_tag),"yyyymmdd"),"DD-MMM-YYYY;;D"),
     " ",format(cnvttime(cnvtmin(cnvtint(substring(11,6,ce2.event_tag)),2)),"HH:MM:SS;;M")), info->
    transfusionstarttime = ready_time, i_vital_cnt = (i_vital_cnt+ 1)
   ELSEIF (ce2.event_cd=mf_temperaturestart)
    info->temperaturestart = s_tran_result, i_vital_cnt = (i_vital_cnt+ 1)
   ELSEIF (ce2.event_cd=mf_temperatureroutestart)
    info->temperatureroutestart = s_tran_result, i_vital_cnt = (i_vital_cnt+ 1)
   ELSEIF (ce2.event_cd=mf_pulseratestart)
    info->pulseratestart = s_tran_result, i_vital_cnt = (i_vital_cnt+ 1)
   ELSEIF (ce2.event_cd=mf_respiratoryratestart)
    info->respiratoryratestart = s_tran_result, i_vital_cnt = (i_vital_cnt+ 1)
   ELSEIF (ce2.event_cd=mf_systolicbloodpressurestart)
    info->systolicbloodpressurestart = s_tran_result, i_vital_cnt = (i_vital_cnt+ 1)
   ELSEIF (ce2.event_cd=mf_diastolicbloodpressurestart)
    info->diastolicbloodpressurestart = s_tran_result, i_vital_cnt = (i_vital_cnt+ 1)
   ELSEIF (ce2.event_cd=mf_oxygensaturationstart)
    info->oxygensaturationstart = s_tran_result, i_vital_cnt = (i_vital_cnt+ 1)
   ELSEIF (ce2.event_cd=mf_transfusionstartplus15min)
    ready_time = concat(format(cnvtdate2(substring(3,8,ce2.event_tag),"yyyymmdd"),"DD-MMM-YYYY;;D"),
     " ",format(cnvttime(cnvtmin(cnvtint(substring(11,6,ce2.event_tag)),2)),"HH:MM:SS;;M")), info->
    transfusionstartplus15min = ready_time, i_vital_cnt = (i_vital_cnt+ 1)
   ELSEIF (ce2.event_cd=mf_temperature15min)
    info->temperature15min = s_tran_result, i_vital_cnt = (i_vital_cnt+ 1)
   ELSEIF (ce2.event_cd=mf_temperatureroute15min)
    info->temperatureroute15min = s_tran_result, i_vital_cnt = (i_vital_cnt+ 1)
   ELSEIF (ce2.event_cd=mf_pulserate15min)
    info->pulserate15min = s_tran_result, i_vital_cnt = (i_vital_cnt+ 1)
   ELSEIF (ce2.event_cd=mf_respiratoryrate15min)
    info->respiratoryrate15min = s_tran_result, i_vital_cnt = (i_vital_cnt+ 1)
   ELSEIF (ce2.event_cd=mf_systolicbloodpressure15min)
    info->systolicbloodpressure15min = s_tran_result, i_vital_cnt = (i_vital_cnt+ 1)
   ELSEIF (ce2.event_cd=mf_diastolicbloodpressure15min)
    info->diastolicbloodpressure15min = s_tran_result, i_vital_cnt = (i_vital_cnt+ 1)
   ELSEIF (ce2.event_cd=mf_oxygensaturation15min)
    info->oxygensaturation15min = s_tran_result, i_vital_cnt = (i_vital_cnt+ 1)
   ELSEIF (ce2.event_cd=mf_transfusionendtime)
    ready_time = concat(format(cnvtdate2(substring(3,8,ce2.event_tag),"yyyymmdd"),"DD-MMM-YYYY;;D"),
     " ",format(cnvttime(cnvtmin(cnvtint(substring(11,6,ce2.event_tag)),2)),"HH:MM:SS;;M")), info->
    transfusionendtime = ready_time, i_vital_cnt = (i_vital_cnt+ 1)
   ELSEIF (ce2.event_cd=mf_temperatureend)
    info->temperatureend = s_tran_result, i_vital_cnt = (i_vital_cnt+ 1)
   ELSEIF (ce2.event_cd=mf_temperaturerouteend)
    info->temperaturerouteend = s_tran_result, i_vital_cnt = (i_vital_cnt+ 1)
   ELSEIF (ce2.event_cd=mf_pulserateend)
    info->pulserateend = s_tran_result, i_vital_cnt = (i_vital_cnt+ 1)
   ELSEIF (ce2.event_cd=mf_respiratoryrateend)
    info->respiratoryrateend = s_tran_result, i_vital_cnt = (i_vital_cnt+ 1)
   ELSEIF (ce2.event_cd=mf_systolicbloodpressureend)
    info->systolicbloodpressureend = s_tran_result, i_vital_cnt = (i_vital_cnt+ 1)
   ELSEIF (ce2.event_cd=mf_diastolicbloodpressureend)
    info->diastolicbloodpressureend = s_tran_result, i_vital_cnt = (i_vital_cnt+ 1)
   ELSEIF (ce2.event_cd=mf_oxygensaturationend)
    info->oxygensaturationend = s_tran_result, i_vital_cnt = (i_vital_cnt+ 1)
   ELSEIF (ce2.event_cd IN (mf_albuminvol, mf_cryoprecipitate, mf_factorviia, mf_factorviiivol,
   mf_factorixcomplex,
   mf_factorixvol, mf_ffp, mf_granulocytes, mf_ivig, mf_platelets,
   mf_rbcvol, mf_rhimmuneglobulin, mf_bloodproductamountinfused))
    info->amountinfused = concat(trim(uar_get_code_display(ce2.event_cd),3)," - ",s_tran_result)
   ELSEIF (ce2.event_cd=mf_transfusionreactiondescription)
    info->transfusionreactiondescription = s_tran_result, i_reaction_cnt = (i_reaction_cnt+ 1)
   ENDIF
  WITH nocounter
 ;end select
 CALL echorecord(info)
 CALL echo("Print report")
 EXECUTE reportrtl
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
 DECLARE headsec(ncalc=i2) = f8 WITH protect
 DECLARE headsecabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE linesec(ncalc=i2) = f8 WITH protect
 DECLARE linesecabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE patientsec(ncalc=i2) = f8 WITH protect
 DECLARE patientsecabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE admitdxsec(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE admitdxsecabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE problemsec(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE problemsecabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE formssec(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE formssecabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE reactionsec(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE reactionsecabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE labssec(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE labssecabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE reactioninfosec(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE reactioninfosecabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE medssec(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE medssecabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE o2sec(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE o2secabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE vitalssec(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE tablerow(ncalc=i2) = f8 WITH protect
 DECLARE tablerowabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow1(ncalc=i2) = f8 WITH protect
 DECLARE tablerow1abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow2(ncalc=i2) = f8 WITH protect
 DECLARE tablerow2abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow8(ncalc=i2) = f8 WITH protect
 DECLARE tablerow8abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow9(ncalc=i2) = f8 WITH protect
 DECLARE tablerow9abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow3(ncalc=i2) = f8 WITH protect
 DECLARE tablerow3abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow4(ncalc=i2) = f8 WITH protect
 DECLARE tablerow4abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow5(ncalc=i2) = f8 WITH protect
 DECLARE tablerow5abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE vitalssecabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE staticsec(ncalc=i2) = f8 WITH protect
 DECLARE tablerow7(ncalc=i2) = f8 WITH protect
 DECLARE tablerow7abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow11(ncalc=i2) = f8 WITH protect
 DECLARE tablerow11abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow14(ncalc=i2) = f8 WITH protect
 DECLARE tablerow14abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow6(ncalc=i2) = f8 WITH protect
 DECLARE tablerow6abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow12(ncalc=i2) = f8 WITH protect
 DECLARE tablerow12abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow13(ncalc=i2) = f8 WITH protect
 DECLARE tablerow13abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow10(ncalc=i2) = f8 WITH protect
 DECLARE tablerow10abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE staticsecabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE footsec(ncalc=i2) = f8 WITH protect
 DECLARE footsecabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE initializereport(dummy) = null WITH protect
 DECLARE _hreport = i4 WITH noconstant(0), protect
 DECLARE _yoffset = f8 WITH noconstant(0.0), protect
 DECLARE _xoffset = f8 WITH noconstant(0.0), protect
 DECLARE rpt_render = i2 WITH constant(0), protect
 DECLARE _crlf = vc WITH constant(concat(char(13),char(10))), protect
 DECLARE rpt_calcheight = i2 WITH constant(1), protect
 DECLARE _yshift = f8 WITH noconstant(0.0), protect
 DECLARE _xshift = f8 WITH noconstant(0.0), protect
 DECLARE _sendto = vc WITH noconstant(""), protect
 DECLARE _rpterr = i2 WITH noconstant(0), protect
 DECLARE _rptstat = i2 WITH noconstant(0), protect
 DECLARE _oldfont = i4 WITH noconstant(0), protect
 DECLARE _oldpen = i4 WITH noconstant(0), protect
 DECLARE _dummyfont = i4 WITH noconstant(0), protect
 DECLARE _dummypen = i4 WITH noconstant(0), protect
 DECLARE _fdrawheight = f8 WITH noconstant(0.0), protect
 DECLARE _rptpage = i4 WITH noconstant(0), protect
 DECLARE _outputtype = i2 WITH noconstant(rpt_postscript), protect
 DECLARE _bholdcontinue = i2 WITH noconstant(0), protect
 DECLARE _bcontadmitdxsec = i2 WITH noconstant(0), protect
 DECLARE _remadmitdxfld = i2 WITH noconstant(1), protect
 DECLARE _remabodttm = i2 WITH noconstant(1), protect
 DECLARE _remabofld = i2 WITH noconstant(1), protect
 DECLARE _remabofldval = i2 WITH noconstant(1), protect
 DECLARE _bcontproblemsec = i2 WITH noconstant(0), protect
 DECLARE _remproblemsfld = i2 WITH noconstant(1), protect
 DECLARE _remantibodydttm = i2 WITH noconstant(1), protect
 DECLARE _remabofld4 = i2 WITH noconstant(1), protect
 DECLARE _remabofld6 = i2 WITH noconstant(1), protect
 DECLARE _bcontformssec = i2 WITH noconstant(0), protect
 DECLARE _remformfld = i2 WITH noconstant(1), protect
 DECLARE _remformdttm = i2 WITH noconstant(1), protect
 DECLARE _bcontreactionsec = i2 WITH noconstant(0), protect
 DECLARE _remyes_nodta = i2 WITH noconstant(1), protect
 DECLARE _remfidreaction = i2 WITH noconstant(1), protect
 DECLARE _bcontlabssec = i2 WITH noconstant(0), protect
 DECLARE _remlabs = i2 WITH noconstant(1), protect
 DECLARE _remlabsdatetm = i2 WITH noconstant(1), protect
 DECLARE _remlabval = i2 WITH noconstant(1), protect
 DECLARE _bcontreactioninfosec = i2 WITH noconstant(0), protect
 DECLARE _remweightfld = i2 WITH noconstant(1), protect
 DECLARE _remintakefld = i2 WITH noconstant(1), protect
 DECLARE _bcontmedssec = i2 WITH noconstant(0), protect
 DECLARE _remmedsfld = i2 WITH noconstant(1), protect
 DECLARE _remmedsdttmfld = i2 WITH noconstant(1), protect
 DECLARE _remmedsstatusfld = i2 WITH noconstant(1), protect
 DECLARE _bconto2sec = i2 WITH noconstant(0), protect
 DECLARE _remmedsfld = i2 WITH noconstant(1), protect
 DECLARE _remmedsdttmfld = i2 WITH noconstant(1), protect
 DECLARE _remmedsstatusfld = i2 WITH noconstant(1), protect
 DECLARE _bcontvitalssec = i2 WITH noconstant(0), protect
 DECLARE _remmedsfld = i2 WITH noconstant(1), protect
 DECLARE _remmedsfld1 = i2 WITH noconstant(1), protect
 DECLARE _times8bu0 = i4 WITH noconstant(0), protect
 DECLARE _times80 = i4 WITH noconstant(0), protect
 DECLARE _times8b0 = i4 WITH noconstant(0), protect
 DECLARE _times12b0 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _times200 = i4 WITH noconstant(0), protect
 DECLARE _pen0s0c0 = i4 WITH noconstant(0), protect
 DECLARE _pen2s1c0 = i4 WITH noconstant(0), protect
 DECLARE _pen1s3c0 = i4 WITH noconstant(0), protect
 DECLARE _pen5s0c0 = i4 WITH noconstant(0), protect
 DECLARE _pen5s1c0 = i4 WITH noconstant(0), protect
 DECLARE _pen10s0c0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
 SUBROUTINE pagebreak(dummy)
   SET _rptpage = uar_rptendpage(_hreport)
   SET _rptpage = uar_rptstartpage(_hreport)
   SET _yoffset = rptreport->m_margintop
 END ;Subroutine
 SUBROUTINE finalizereport(ssendreport)
   SET _rptpage = uar_rptendpage(_hreport)
   SET _rptstat = uar_rptendreport(_hreport)
   DECLARE sfilename = vc WITH noconstant(trim(ssendreport)), private
   DECLARE bprint = i2 WITH noconstant(0), private
   IF (textlen(sfilename) > 0)
    SET bprint = checkqueue(sfilename)
    IF (bprint)
     EXECUTE cpm_create_file_name "RPT", "PS"
     SET sfilename = cpm_cfn_info->file_name_path
    ENDIF
   ENDIF
   SET _rptstat = uar_rptprinttofile(_hreport,nullterm(sfilename))
   IF (bprint)
    SET spool value(sfilename) value(ssendreport) WITH deleted
   ENDIF
   DECLARE _errorfound = i2 WITH noconstant(0), protect
   DECLARE _errcnt = i2 WITH noconstant(0), protect
   SET _errorfound = uar_rptfirsterror(_hreport,rpterror)
   WHILE (_errorfound=rpt_errorfound
    AND _errcnt < 512)
     SET _errcnt = (_errcnt+ 1)
     SET stat = alterlist(rpterrors->errors,_errcnt)
     SET rpterrors->errors[_errcnt].m_severity = rpterror->m_severity
     SET rpterrors->errors[_errcnt].m_text = rpterror->m_text
     SET rpterrors->errors[_errcnt].m_source = rpterror->m_source
     SET _errorfound = uar_rptnexterror(_hreport,rpterror)
   ENDWHILE
   SET _rptstat = uar_rptdestroyreport(_hreport)
 END ;Subroutine
 SUBROUTINE headsec(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headsecabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headsecabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.500000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 20
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.375
    SET _oldfont = uar_rptsetfont(_hreport,_times200)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Preliminary Investigation of Suspected Reaction to Human Blood Product",char(0)))
    SET rptsd->m_flags = 16
    SET rptsd->m_y = (offsety+ 0.323)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.208
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(format(cnvtdatetime(curdate,curtime3),
       ";;q"),char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE linesec(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = linesecabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE linesecabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.060000), private
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen5s1c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.032),(offsetx+ 7.500),(offsety+
     0.032))
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE patientsec(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = patientsecabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE patientsecabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.590000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 5.813
    SET rptsd->m_height = 0.250
    SET _oldfont = uar_rptsetfont(_hreport,_times12b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(info->name,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.188)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Birthdate:",char(0)))
    SET rptsd->m_y = (offsety+ 0.188)
    SET rptsd->m_x = (offsetx+ 2.875)
    SET rptsd->m_width = 0.625
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Nurse Unit:",char(0)))
    SET rptsd->m_y = (offsety+ 0.313)
    SET rptsd->m_x = (offsetx+ 2.875)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Ordering Phy:",char(0)))
    SET rptsd->m_y = (offsety+ 0.313)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.938
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("CMRN:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.188)
    SET rptsd->m_x = (offsetx+ 0.563)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times80)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(info->dob,char(0)))
    SET rptsd->m_y = (offsety+ 0.313)
    SET rptsd->m_x = (offsetx+ 0.438)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(info->cmrn,char(0)))
    SET rptsd->m_y = (offsety+ 0.313)
    SET rptsd->m_x = (offsetx+ 3.625)
    SET rptsd->m_width = 3.250
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(info->orderingphy,char(0)))
    SET rptsd->m_y = (offsety+ 0.188)
    SET rptsd->m_x = (offsetx+ 3.500)
    SET rptsd->m_width = 2.823
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(info->lastnurseunit,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.438)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.688
    SET rptsd->m_height = 0.146
    SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("ACCT:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.438)
    SET rptsd->m_x = (offsetx+ 0.438)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.167
    SET _dummyfont = uar_rptsetfont(_hreport,_times80)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(info->fin,char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE admitdxsec(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = admitdxsecabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE admitdxsecabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   IF (bcontinue=0)
    SET _remadmitdxfld = 1
    SET _remabodttm = 1
    SET _remabofld = 1
    SET _remabofldval = 1
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 0.938
   SET rptsd->m_height = 0.188
   SET _oldfont = uar_rptsetfont(_hreport,_times8b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Admit Diagnosis:",char(0)))
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 3.188
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _holdremadmitdxfld = _remadmitdxfld
   IF (_remadmitdxfld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remadmitdxfld,((size(info
        ->admitdx) - _remadmitdxfld)+ 1),info->admitdx)))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remadmitdxfld = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remadmitdxfld,((size(info->admitdx) -
       _remadmitdxfld)+ 1),info->admitdx)))))
     SET _remadmitdxfld = (_remadmitdxfld+ rptsd->m_drawlength)
    ELSE
     SET _remadmitdxfld = 0
    ENDIF
    SET growsum = (growsum+ _remadmitdxfld)
   ENDIF
   SET rptsd->m_flags = 4
   IF (ncalc=rpt_render
    AND _holdremadmitdxfld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremadmitdxfld,((size(
        info->admitdx) - _holdremadmitdxfld)+ 1),info->admitdx)))
   ELSE
    SET _remadmitdxfld = _holdremadmitdxfld
   ENDIF
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 3.250)
   SET rptsd->m_width = 0.625
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("ABO/Rh:",char(0)))
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 6.375)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _holdremabodttm = _remabodttm
   IF (_remabodttm > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remabodttm,((size(info->
        aborhdttm) - _remabodttm)+ 1),info->aborhdttm)))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remabodttm = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remabodttm,((size(info->aborhdttm) -
       _remabodttm)+ 1),info->aborhdttm)))))
     SET _remabodttm = (_remabodttm+ rptsd->m_drawlength)
    ELSE
     SET _remabodttm = 0
    ENDIF
    SET growsum = (growsum+ _remabodttm)
   ENDIF
   SET rptsd->m_flags = 4
   IF (ncalc=rpt_render
    AND _holdremabodttm > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremabodttm,((size(
        info->aborhdttm) - _holdremabodttm)+ 1),info->aborhdttm)))
   ELSE
    SET _remabodttm = _holdremabodttm
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.250)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremabofld = _remabofld
   IF (_remabofld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remabofld,((size(info->
        aborh) - _remabofld)+ 1),info->aborh)))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remabofld = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remabofld,((size(info->aborh) -
       _remabofld)+ 1),info->aborh)))))
     SET _remabofld = (_remabofld+ rptsd->m_drawlength)
    ELSE
     SET _remabofld = 0
    ENDIF
    SET growsum = (growsum+ _remabofld)
   ENDIF
   SET rptsd->m_flags = 4
   IF (ncalc=rpt_render
    AND _holdremabofld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremabofld,((size(info
        ->aborh) - _holdremabofld)+ 1),info->aborh)))
   ELSE
    SET _remabofld = _holdremabofld
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.938)
   SET rptsd->m_width = 1.313
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremabofldval = _remabofldval
   IF (_remabofldval > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remabofldval,((size(info
        ->aborhval) - _remabofldval)+ 1),info->aborhval)))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remabofldval = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remabofldval,((size(info->aborhval) -
       _remabofldval)+ 1),info->aborhval)))))
     SET _remabofldval = (_remabofldval+ rptsd->m_drawlength)
    ELSE
     SET _remabofldval = 0
    ENDIF
    SET growsum = (growsum+ _remabofldval)
   ENDIF
   SET rptsd->m_flags = 4
   IF (ncalc=rpt_render
    AND _holdremabofldval > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremabofldval,((size(
        info->aborhval) - _holdremabofldval)+ 1),info->aborhval)))
   ELSE
    SET _remabofldval = _holdremabofldval
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE problemsec(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = problemsecabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE problemsecabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   IF (bcontinue=0)
    SET _remproblemsfld = 1
    SET _remantibodydttm = 1
    SET _remabofld4 = 1
    SET _remabofld6 = 1
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 0.938
   SET rptsd->m_height = 0.188
   SET _oldfont = uar_rptsetfont(_hreport,_times8b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Problems:",char(0)))
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 3.188
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _holdremproblemsfld = _remproblemsfld
   IF (_remproblemsfld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remproblemsfld,((size(
        info->problems) - _remproblemsfld)+ 1),info->problems)))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remproblemsfld = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remproblemsfld,((size(info->problems) -
       _remproblemsfld)+ 1),info->problems)))))
     SET _remproblemsfld = (_remproblemsfld+ rptsd->m_drawlength)
    ELSE
     SET _remproblemsfld = 0
    ENDIF
    SET growsum = (growsum+ _remproblemsfld)
   ENDIF
   SET rptsd->m_flags = 4
   IF (ncalc=rpt_render
    AND _holdremproblemsfld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremproblemsfld,((size
       (info->problems) - _holdremproblemsfld)+ 1),info->problems)))
   ELSE
    SET _remproblemsfld = _holdremproblemsfld
   ENDIF
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 3.250)
   SET rptsd->m_width = 0.625
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Antibody:",char(0)))
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 6.375)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _holdremantibodydttm = _remantibodydttm
   IF (_remantibodydttm > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remantibodydttm,((size(
        info->antibodydttm) - _remantibodydttm)+ 1),info->antibodydttm)))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remantibodydttm = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remantibodydttm,((size(info->antibodydttm
        ) - _remantibodydttm)+ 1),info->antibodydttm)))))
     SET _remantibodydttm = (_remantibodydttm+ rptsd->m_drawlength)
    ELSE
     SET _remantibodydttm = 0
    ENDIF
    SET growsum = (growsum+ _remantibodydttm)
   ENDIF
   SET rptsd->m_flags = 4
   IF (ncalc=rpt_render
    AND _holdremantibodydttm > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremantibodydttm,((
       size(info->antibodydttm) - _holdremantibodydttm)+ 1),info->antibodydttm)))
   ELSE
    SET _remantibodydttm = _holdremantibodydttm
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.250)
   SET rptsd->m_width = 1.188
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremabofld4 = _remabofld4
   IF (_remabofld4 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remabofld4,((size(info->
        antibody) - _remabofld4)+ 1),info->antibody)))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remabofld4 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remabofld4,((size(info->antibody) -
       _remabofld4)+ 1),info->antibody)))))
     SET _remabofld4 = (_remabofld4+ rptsd->m_drawlength)
    ELSE
     SET _remabofld4 = 0
    ENDIF
    SET growsum = (growsum+ _remabofld4)
   ENDIF
   SET rptsd->m_flags = 4
   IF (ncalc=rpt_render
    AND _holdremabofld4 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremabofld4,((size(
        info->antibody) - _holdremabofld4)+ 1),info->antibody)))
   ELSE
    SET _remabofld4 = _holdremabofld4
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.938)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremabofld6 = _remabofld6
   IF (_remabofld6 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remabofld6,((size(info->
        antibodyval) - _remabofld6)+ 1),info->antibodyval)))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remabofld6 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remabofld6,((size(info->antibodyval) -
       _remabofld6)+ 1),info->antibodyval)))))
     SET _remabofld6 = (_remabofld6+ rptsd->m_drawlength)
    ELSE
     SET _remabofld6 = 0
    ENDIF
    SET growsum = (growsum+ _remabofld6)
   ENDIF
   SET rptsd->m_flags = 4
   IF (ncalc=rpt_render
    AND _holdremabofld6 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremabofld6,((size(
        info->antibodyval) - _holdremabofld6)+ 1),info->antibodyval)))
   ELSE
    SET _remabofld6 = _holdremabofld6
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE formssec(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = formssecabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE formssecabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   IF (bcontinue=0)
    SET _remformfld = 1
    SET _remformdttm = 1
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.625
   SET rptsd->m_height = 0.188
   SET _oldfont = uar_rptsetfont(_hreport,_times8b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Hemotherapy Chronology:",char(0)))
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.094)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.875
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _holdremformfld = _remformfld
   IF (_remformfld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remformfld,((size(info->
        formname) - _remformfld)+ 1),info->formname)))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remformfld = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remformfld,((size(info->formname) -
       _remformfld)+ 1),info->formname)))))
     SET _remformfld = (_remformfld+ rptsd->m_drawlength)
    ELSE
     SET _remformfld = 0
    ENDIF
    SET growsum = (growsum+ _remformfld)
   ENDIF
   SET rptsd->m_flags = 4
   IF (ncalc=rpt_render
    AND _holdremformfld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremformfld,((size(
        info->formname) - _holdremformfld)+ 1),info->formname)))
   ELSE
    SET _remformfld = _holdremformfld
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 6.375)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremformdttm = _remformdttm
   IF (_remformdttm > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remformdttm,((size(info->
        formdttm) - _remformdttm)+ 1),info->formdttm)))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remformdttm = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remformdttm,((size(info->formdttm) -
       _remformdttm)+ 1),info->formdttm)))))
     SET _remformdttm = (_remformdttm+ rptsd->m_drawlength)
    ELSE
     SET _remformdttm = 0
    ENDIF
    SET growsum = (growsum+ _remformdttm)
   ENDIF
   SET rptsd->m_flags = 4
   IF (ncalc=rpt_render
    AND _holdremformdttm > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremformdttm,((size(
        info->formdttm) - _holdremformdttm)+ 1),info->formdttm)))
   ELSE
    SET _remformdttm = _holdremformdttm
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE reactionsec(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = reactionsecabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE reactionsecabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.190000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   IF (bcontinue=0)
    SET _remyes_nodta = 1
    SET _remfidreaction = 1
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.625
   SET rptsd->m_height = 0.188
   SET _oldfont = uar_rptsetfont(_hreport,_times8b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Previous Reaction to Transfusion:",
      char(0)))
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.625)
   SET rptsd->m_width = 0.688
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _holdremyes_nodta = _remyes_nodta
   IF (_remyes_nodta > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remyes_nodta,((size(info
        ->previousreactionq) - _remyes_nodta)+ 1),info->previousreactionq)))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remyes_nodta = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remyes_nodta,((size(info->
        previousreactionq) - _remyes_nodta)+ 1),info->previousreactionq)))))
     SET _remyes_nodta = (_remyes_nodta+ rptsd->m_drawlength)
    ELSE
     SET _remyes_nodta = 0
    ENDIF
    SET growsum = (growsum+ _remyes_nodta)
   ENDIF
   SET rptsd->m_flags = 4
   IF (ncalc=rpt_render
    AND _holdremyes_nodta > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremyes_nodta,((size(
        info->previousreactionq) - _holdremyes_nodta)+ 1),info->previousreactionq)))
   ELSE
    SET _remyes_nodta = _holdremyes_nodta
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.375)
   SET rptsd->m_width = 5.125
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremfidreaction = _remfidreaction
   IF (_remfidreaction > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfidreaction,((size(
        info->previousreaction) - _remfidreaction)+ 1),info->previousreaction)))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remfidreaction = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfidreaction,((size(info->
        previousreaction) - _remfidreaction)+ 1),info->previousreaction)))))
     SET _remfidreaction = (_remfidreaction+ rptsd->m_drawlength)
    ELSE
     SET _remfidreaction = 0
    ENDIF
    SET growsum = (growsum+ _remfidreaction)
   ENDIF
   SET rptsd->m_flags = 4
   IF (ncalc=rpt_render
    AND _holdremfidreaction > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfidreaction,((size
       (info->previousreaction) - _holdremfidreaction)+ 1),info->previousreaction)))
   ELSE
    SET _remfidreaction = _holdremfidreaction
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE labssec(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = labssecabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE labssecabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.310000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   IF (bcontinue=0)
    SET _remlabs = 1
    SET _remlabsdatetm = 1
    SET _remlabval = 1
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 0.438
   SET rptsd->m_height = 0.188
   SET _oldfont = uar_rptsetfont(_hreport,_times8b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Labs:",char(0)))
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 3.125
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _holdremlabs = _remlabs
   IF (_remlabs > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlabs,((size(info->labs
        ) - _remlabs)+ 1),info->labs)))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabs = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabs,((size(info->labs) - _remlabs)+ 1
       ),info->labs)))))
     SET _remlabs = (_remlabs+ rptsd->m_drawlength)
    ELSE
     SET _remlabs = 0
    ENDIF
    SET growsum = (growsum+ _remlabs)
   ENDIF
   SET rptsd->m_flags = 4
   IF (ncalc=rpt_render
    AND _holdremlabs > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremlabs,((size(info->
        labs) - _holdremlabs)+ 1),info->labs)))
   ELSE
    SET _remlabs = _holdremlabs
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 6.375)
   SET rptsd->m_width = 1.313
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremlabsdatetm = _remlabsdatetm
   IF (_remlabsdatetm > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlabsdatetm,((size(info
        ->labsdttm) - _remlabsdatetm)+ 1),info->labsdttm)))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabsdatetm = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabsdatetm,((size(info->labsdttm) -
       _remlabsdatetm)+ 1),info->labsdttm)))))
     SET _remlabsdatetm = (_remlabsdatetm+ rptsd->m_drawlength)
    ELSE
     SET _remlabsdatetm = 0
    ENDIF
    SET growsum = (growsum+ _remlabsdatetm)
   ENDIF
   SET rptsd->m_flags = 4
   IF (ncalc=rpt_render
    AND _holdremlabsdatetm > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremlabsdatetm,((size(
        info->labsdttm) - _holdremlabsdatetm)+ 1),info->labsdttm)))
   ELSE
    SET _remlabsdatetm = _holdremlabsdatetm
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.250)
   SET rptsd->m_width = 2.625
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremlabval = _remlabval
   IF (_remlabval > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlabval,((size(info->
        labsval) - _remlabval)+ 1),info->labsval)))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabval = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabval,((size(info->labsval) -
       _remlabval)+ 1),info->labsval)))))
     SET _remlabval = (_remlabval+ rptsd->m_drawlength)
    ELSE
     SET _remlabval = 0
    ENDIF
    SET growsum = (growsum+ _remlabval)
   ENDIF
   SET rptsd->m_flags = 4
   IF (ncalc=rpt_render
    AND _holdremlabval > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremlabval,((size(info
        ->labsval) - _holdremlabval)+ 1),info->labsval)))
   ELSE
    SET _remlabval = _holdremlabval
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE reactioninfosec(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = reactioninfosecabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE reactioninfosecabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.440000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   IF (bcontinue=0)
    SET _remweightfld = 1
    SET _remintakefld = 1
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = 0.188
   SET _oldfont = uar_rptsetfont(_hreport,_times8b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Reaction Information:",char(0)))
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.438)
   SET rptsd->m_width = 5.125
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _holdremweightfld = _remweightfld
   IF (_remweightfld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remweightfld,((size(info
        ->weight) - _remweightfld)+ 1),info->weight)))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remweightfld = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remweightfld,((size(info->weight) -
       _remweightfld)+ 1),info->weight)))))
     SET _remweightfld = (_remweightfld+ rptsd->m_drawlength)
    ELSE
     SET _remweightfld = 0
    ENDIF
    SET growsum = (growsum+ _remweightfld)
   ENDIF
   SET rptsd->m_flags = 4
   IF (ncalc=rpt_render
    AND _holdremweightfld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremweightfld,((size(
        info->weight) - _holdremweightfld)+ 1),info->weight)))
   ELSE
    SET _remweightfld = _holdremweightfld
   ENDIF
   SET rptsd->m_y = (offsety+ 0.125)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 0.438
   SET rptsd->m_height = 0.188
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Weight:",char(0)))
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.563)
   SET rptsd->m_width = 4.990
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremintakefld = _remintakefld
   IF (_remintakefld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remintakefld,((size(info
        ->intake) - _remintakefld)+ 1),info->intake)))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remintakefld = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remintakefld,((size(info->intake) -
       _remintakefld)+ 1),info->intake)))))
     SET _remintakefld = (_remintakefld+ rptsd->m_drawlength)
    ELSE
     SET _remintakefld = 0
    ENDIF
    SET growsum = (growsum+ _remintakefld)
   ENDIF
   SET rptsd->m_flags = 4
   IF (ncalc=rpt_render
    AND _holdremintakefld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremintakefld,((size(
        info->intake) - _holdremintakefld)+ 1),info->intake)))
   ELSE
    SET _remintakefld = _holdremintakefld
   ENDIF
   SET rptsd->m_y = (offsety+ 0.250)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 0.813
   SET rptsd->m_height = 0.188
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Intake 12h:",char(0)))
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE medssec(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = medssecabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE medssecabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   IF (bcontinue=0)
    SET _remmedsfld = 1
    SET _remmedsdttmfld = 1
    SET _remmedsstatusfld = 1
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 0.875
   SET rptsd->m_height = 0.188
   SET _oldfont = uar_rptsetfont(_hreport,_times8b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Medications:",char(0)))
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 4.938
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _holdremmedsfld = _remmedsfld
   IF (_remmedsfld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remmedsfld,((size(info->
        meds) - _remmedsfld)+ 1),info->meds)))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remmedsfld = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remmedsfld,((size(info->meds) -
       _remmedsfld)+ 1),info->meds)))))
     SET _remmedsfld = (_remmedsfld+ rptsd->m_drawlength)
    ELSE
     SET _remmedsfld = 0
    ENDIF
    SET growsum = (growsum+ _remmedsfld)
   ENDIF
   SET rptsd->m_flags = 4
   IF (ncalc=rpt_render
    AND _holdremmedsfld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremmedsfld,((size(
        info->meds) - _holdremmedsfld)+ 1),info->meds)))
   ELSE
    SET _remmedsfld = _holdremmedsfld
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 6.375)
   SET rptsd->m_width = 1.063
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremmedsdttmfld = _remmedsdttmfld
   IF (_remmedsdttmfld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remmedsdttmfld,((size(
        info->medsdttm) - _remmedsdttmfld)+ 1),info->medsdttm)))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remmedsdttmfld = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remmedsdttmfld,((size(info->medsdttm) -
       _remmedsdttmfld)+ 1),info->medsdttm)))))
     SET _remmedsdttmfld = (_remmedsdttmfld+ rptsd->m_drawlength)
    ELSE
     SET _remmedsdttmfld = 0
    ENDIF
    SET growsum = (growsum+ _remmedsdttmfld)
   ENDIF
   SET rptsd->m_flags = 4
   IF (ncalc=rpt_render
    AND _holdremmedsdttmfld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremmedsdttmfld,((size
       (info->medsdttm) - _holdremmedsdttmfld)+ 1),info->medsdttm)))
   ELSE
    SET _remmedsdttmfld = _holdremmedsdttmfld
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.063)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremmedsstatusfld = _remmedsstatusfld
   IF (_remmedsstatusfld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remmedsstatusfld,((size(
        info->medsstatus) - _remmedsstatusfld)+ 1),info->medsstatus)))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remmedsstatusfld = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remmedsstatusfld,((size(info->medsstatus)
        - _remmedsstatusfld)+ 1),info->medsstatus)))))
     SET _remmedsstatusfld = (_remmedsstatusfld+ rptsd->m_drawlength)
    ELSE
     SET _remmedsstatusfld = 0
    ENDIF
    SET growsum = (growsum+ _remmedsstatusfld)
   ENDIF
   SET rptsd->m_flags = 4
   IF (ncalc=rpt_render
    AND _holdremmedsstatusfld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremmedsstatusfld,((
       size(info->medsstatus) - _holdremmedsstatusfld)+ 1),info->medsstatus)))
   ELSE
    SET _remmedsstatusfld = _holdremmedsstatusfld
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE o2sec(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = o2secabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE o2secabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   IF (bcontinue=0)
    SET _remmedsfld = 1
    SET _remmedsdttmfld = 1
    SET _remmedsstatusfld = 1
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 4.375
   SET rptsd->m_height = 0.188
   SET _oldfont = uar_rptsetfont(_hreport,_times8b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Supplemental oxygen use:",char(0)))
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 4.938
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _holdremmedsfld = _remmedsfld
   IF (_remmedsfld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remmedsfld,((size(info->
        oxygen) - _remmedsfld)+ 1),info->oxygen)))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remmedsfld = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remmedsfld,((size(info->oxygen) -
       _remmedsfld)+ 1),info->oxygen)))))
     SET _remmedsfld = (_remmedsfld+ rptsd->m_drawlength)
    ELSE
     SET _remmedsfld = 0
    ENDIF
    SET growsum = (growsum+ _remmedsfld)
   ENDIF
   SET rptsd->m_flags = 4
   IF (ncalc=rpt_render
    AND _holdremmedsfld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremmedsfld,((size(
        info->oxygen) - _holdremmedsfld)+ 1),info->oxygen)))
   ELSE
    SET _remmedsfld = _holdremmedsfld
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 6.375)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremmedsdttmfld = _remmedsdttmfld
   IF (_remmedsdttmfld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remmedsdttmfld,((size(
        info->oxygendttm) - _remmedsdttmfld)+ 1),info->oxygendttm)))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remmedsdttmfld = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remmedsdttmfld,((size(info->oxygendttm)
        - _remmedsdttmfld)+ 1),info->oxygendttm)))))
     SET _remmedsdttmfld = (_remmedsdttmfld+ rptsd->m_drawlength)
    ELSE
     SET _remmedsdttmfld = 0
    ENDIF
    SET growsum = (growsum+ _remmedsdttmfld)
   ENDIF
   SET rptsd->m_flags = 4
   IF (ncalc=rpt_render
    AND _holdremmedsdttmfld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremmedsdttmfld,((size
       (info->oxygendttm) - _holdremmedsdttmfld)+ 1),info->oxygendttm)))
   ELSE
    SET _remmedsdttmfld = _holdremmedsdttmfld
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.063)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremmedsstatusfld = _remmedsstatusfld
   IF (_remmedsstatusfld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remmedsstatusfld,((size(
        info->oxygenstatus) - _remmedsstatusfld)+ 1),info->oxygenstatus)))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remmedsstatusfld = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remmedsstatusfld,((size(info->
        oxygenstatus) - _remmedsstatusfld)+ 1),info->oxygenstatus)))))
     SET _remmedsstatusfld = (_remmedsstatusfld+ rptsd->m_drawlength)
    ELSE
     SET _remmedsstatusfld = 0
    ENDIF
    SET growsum = (growsum+ _remmedsstatusfld)
   ENDIF
   SET rptsd->m_flags = 4
   IF (ncalc=rpt_render
    AND _holdremmedsstatusfld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremmedsstatusfld,((
       size(info->oxygenstatus) - _holdremmedsstatusfld)+ 1),info->oxygenstatus)))
   ELSE
    SET _remmedsstatusfld = _holdremmedsstatusfld
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE vitalssec(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = vitalssecabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerowabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerowabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.185988), private
   SET rptsd->m_flags = 32
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.177
   SET rptsd->m_height = 0.186
   SET _oldfont = uar_rptsetfont(_hreport,_times8bu0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen2s1c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2("Transfusion start:",char(0))
      ))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.177)
   SET rptsd->m_width = 1.448
   SET rptsd->m_height = 0.186
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(info->transfusionstarttime,
       char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.625)
   SET rptsd->m_width = 0.375
   SET rptsd->m_height = 0.186
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2("Temp:",char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 3.000)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.186
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(info->temperaturestart,char(0
        ))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 4.125)
   SET rptsd->m_width = 0.688
   SET rptsd->m_height = 0.186
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2("Temp Route:",char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 4.813)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.186
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(info->temperatureroutestart,
       char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 5.938)
   SET rptsd->m_width = 0.437
   SET rptsd->m_height = 0.186
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2("Pulse:",char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 6.375)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.186
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(info->pulseratestart,char(0))
      ))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.177),offsety,(offsetx+ 1.177),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.625),offsety,(offsetx+ 2.625),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.000),offsety,(offsetx+ 3.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.125),offsety,(offsetx+ 4.125),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.813),offsety,(offsetx+ 4.813),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.938),offsety,(offsetx+ 5.938),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.375),offsety,(offsetx+ 6.375),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.500),offsety,(offsetx+ 7.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 7.500),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 7.500),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow1(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow1abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow1abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.185988), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.177
   SET rptsd->m_height = 0.186
   SET _oldfont = uar_rptsetfont(_hreport,_times8b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,"")
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.177)
   SET rptsd->m_width = 0.000
   SET rptsd->m_height = 0.186
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2("RR:",char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.177)
   SET rptsd->m_width = 0.260
   SET rptsd->m_height = 0.186
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2("RR:",char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.438)
   SET rptsd->m_width = 1.187
   SET rptsd->m_height = 0.186
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(info->respiratoryratestart,
       char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.625)
   SET rptsd->m_width = 0.375
   SET rptsd->m_height = 0.186
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2("SBP:",char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 3.000)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.186
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(info->
       systolicbloodpressurestart,char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 4.125)
   SET rptsd->m_width = 0.688
   SET rptsd->m_height = 0.186
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2("DBP:",char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 4.813)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.186
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(info->
       diastolicbloodpressurestart,char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 5.938)
   SET rptsd->m_width = 0.437
   SET rptsd->m_height = 0.186
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2("O2 Sat:",char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 6.375)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.186
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(info->oxygensaturationstart,
       char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.177),offsety,(offsetx+ 1.177),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.177),offsety,(offsetx+ 1.177),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.438),offsety,(offsetx+ 1.438),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.625),offsety,(offsetx+ 2.625),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.000),offsety,(offsetx+ 3.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.125),offsety,(offsetx+ 4.125),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.813),offsety,(offsetx+ 4.813),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.938),offsety,(offsetx+ 5.938),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.375),offsety,(offsetx+ 6.375),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.500),offsety,(offsetx+ 7.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 7.500),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 7.500),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow2(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow2abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow2abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.113660), private
   SET rptsd->m_flags = 32
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.177
   SET rptsd->m_height = 0.114
   SET _oldfont = uar_rptsetfont(_hreport,_times8bu0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen1s3c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,"")
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.177)
   SET rptsd->m_width = 0.260
   SET rptsd->m_height = 0.114
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s3c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,"")
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.438)
   SET rptsd->m_width = 6.062
   SET rptsd->m_height = 0.114
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s3c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,"")
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.177),offsety,(offsetx+ 1.177),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.438),offsety,(offsetx+ 1.438),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.500),offsety,(offsetx+ 7.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 7.500),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 7.500),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow8(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow8abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow8abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.196322), private
   SET rptsd->m_flags = 32
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.177
   SET rptsd->m_height = 0.196
   SET _oldfont = uar_rptsetfont(_hreport,_times8bu0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen1s3c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2("Transfusion 15 min:",char(0)
       )))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.177)
   SET rptsd->m_width = 1.448
   SET rptsd->m_height = 0.196
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(info->
       transfusionstartplus15min,char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.625)
   SET rptsd->m_width = 0.375
   SET rptsd->m_height = 0.196
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2("Temp:",char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 3.000)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.196
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(info->temperature15min,char(0
        ))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 4.125)
   SET rptsd->m_width = 0.688
   SET rptsd->m_height = 0.196
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2("Temp Route:",char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 4.813)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.196
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(info->temperatureroutestart,
       char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 5.938)
   SET rptsd->m_width = 0.437
   SET rptsd->m_height = 0.196
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2("Pulse:",char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 6.375)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.196
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(info->pulserate15min,char(0))
      ))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.177),offsety,(offsetx+ 1.177),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.625),offsety,(offsetx+ 2.625),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.000),offsety,(offsetx+ 3.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.125),offsety,(offsetx+ 4.125),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.813),offsety,(offsetx+ 4.813),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.938),offsety,(offsetx+ 5.938),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.375),offsety,(offsetx+ 6.375),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.500),offsety,(offsetx+ 7.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 7.500),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 7.500),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow9(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow9abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow9abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.175653), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.177
   SET rptsd->m_height = 0.176
   SET _oldfont = uar_rptsetfont(_hreport,_times8b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,"")
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.177)
   SET rptsd->m_width = 0.000
   SET rptsd->m_height = 0.176
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2("RR:",char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.177)
   SET rptsd->m_width = 0.260
   SET rptsd->m_height = 0.176
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2("RR:",char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.438)
   SET rptsd->m_width = 1.187
   SET rptsd->m_height = 0.176
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(info->respiratoryrate15min,
       char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.625)
   SET rptsd->m_width = 0.375
   SET rptsd->m_height = 0.176
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2("SBP:",char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 3.000)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.176
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(info->
       systolicbloodpressure15min,char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 4.125)
   SET rptsd->m_width = 0.688
   SET rptsd->m_height = 0.176
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2("DBP:",char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 4.813)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.176
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(info->
       diastolicbloodpressure15min,char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 5.938)
   SET rptsd->m_width = 0.437
   SET rptsd->m_height = 0.176
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2("O2 Sat:",char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 6.375)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.176
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(info->oxygensaturation15min,
       char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.177),offsety,(offsetx+ 1.177),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.177),offsety,(offsetx+ 1.177),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.438),offsety,(offsetx+ 1.438),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.625),offsety,(offsetx+ 2.625),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.000),offsety,(offsetx+ 3.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.125),offsety,(offsetx+ 4.125),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.813),offsety,(offsetx+ 4.813),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.938),offsety,(offsetx+ 5.938),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.375),offsety,(offsetx+ 6.375),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.500),offsety,(offsetx+ 7.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 7.500),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 7.500),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow3(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow3abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow3abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.113660), private
   SET rptsd->m_flags = 32
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.177
   SET rptsd->m_height = 0.114
   SET _oldfont = uar_rptsetfont(_hreport,_times8bu0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen1s3c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,"")
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.177)
   SET rptsd->m_width = 0.260
   SET rptsd->m_height = 0.114
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s3c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,"")
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.438)
   SET rptsd->m_width = 6.062
   SET rptsd->m_height = 0.114
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s3c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,"")
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.177),offsety,(offsetx+ 1.177),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.438),offsety,(offsetx+ 1.438),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.500),offsety,(offsetx+ 7.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 7.500),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 7.500),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow4(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow4abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow4abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.154990), private
   SET rptsd->m_flags = 32
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.177
   SET rptsd->m_height = 0.155
   SET _oldfont = uar_rptsetfont(_hreport,_times8bu0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen1s3c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2("Transfusion end",char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.177)
   SET rptsd->m_width = 1.448
   SET rptsd->m_height = 0.155
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(info->transfusionendtime,char
       (0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.625)
   SET rptsd->m_width = 0.375
   SET rptsd->m_height = 0.155
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2("Temp:",char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 3.000)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.155
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(info->temperatureend,char(0))
      ))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 4.125)
   SET rptsd->m_width = 0.688
   SET rptsd->m_height = 0.155
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2("Temp Route:",char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 4.813)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.155
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(info->temperaturerouteend,
       char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 5.938)
   SET rptsd->m_width = 0.437
   SET rptsd->m_height = 0.155
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2("Pulse:",char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 6.375)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.155
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(info->pulserateend,char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.177),offsety,(offsetx+ 1.177),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.625),offsety,(offsetx+ 2.625),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.000),offsety,(offsetx+ 3.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.125),offsety,(offsetx+ 4.125),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.813),offsety,(offsetx+ 4.813),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.938),offsety,(offsetx+ 5.938),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.375),offsety,(offsetx+ 6.375),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.500),offsety,(offsetx+ 7.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 7.500),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 7.500),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow5(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow5abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow5abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.154990), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.177
   SET rptsd->m_height = 0.155
   SET _oldfont = uar_rptsetfont(_hreport,_times8b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,"")
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.177)
   SET rptsd->m_width = 0.000
   SET rptsd->m_height = 0.155
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2("RR:",char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.177)
   SET rptsd->m_width = 0.260
   SET rptsd->m_height = 0.155
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2("RR:",char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.438)
   SET rptsd->m_width = 1.187
   SET rptsd->m_height = 0.155
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(info->respiratoryrateend,char
       (0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.625)
   SET rptsd->m_width = 0.375
   SET rptsd->m_height = 0.155
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2("SBP:",char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 3.000)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.155
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(info->
       systolicbloodpressureend,char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 4.125)
   SET rptsd->m_width = 0.688
   SET rptsd->m_height = 0.155
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2("DBP:",char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 4.813)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.155
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(info->
       diastolicbloodpressureend,char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 5.938)
   SET rptsd->m_width = 0.437
   SET rptsd->m_height = 0.155
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2("O2 Sat:",char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 6.375)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.155
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(info->oxygensaturationend,
       char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.177),offsety,(offsetx+ 1.177),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.177),offsety,(offsetx+ 1.177),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.438),offsety,(offsetx+ 1.438),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.625),offsety,(offsetx+ 2.625),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.000),offsety,(offsetx+ 3.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.125),offsety,(offsetx+ 4.125),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.813),offsety,(offsetx+ 4.813),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.938),offsety,(offsetx+ 5.938),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.375),offsety,(offsetx+ 6.375),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.500),offsety,(offsetx+ 7.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 7.500),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 7.500),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE vitalssecabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(1.750000), private
   DECLARE holdheight = f8 WITH noconstant(0.0), private
   DECLARE growsum = i4 WITH noconstant(0), private
   IF (bcontinue=0)
    SET _remmedsfld = 1
    SET _remmedsfld1 = 1
   ENDIF
   SET _oldpen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _yoffset = (offsety+ 0.000)
    SET holdheight = 0
    SET holdheight = (holdheight+ tablerow(rpt_render))
    SET holdheight = (holdheight+ tablerow1(rpt_render))
    SET holdheight = (holdheight+ tablerow2(rpt_render))
    SET holdheight = (holdheight+ tablerow8(rpt_render))
    SET holdheight = (holdheight+ tablerow9(rpt_render))
    SET holdheight = (holdheight+ tablerow3(rpt_render))
    SET holdheight = (holdheight+ tablerow4(rpt_render))
    SET holdheight = (holdheight+ tablerow5(rpt_render))
    SET _yoffset = offsety
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 1.500)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 3.313
   SET rptsd->m_height = 0.188
   SET _oldfont = uar_rptsetfont(_hreport,_times8b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Signs and Symptoms of Suspected Transfusion Reaction:",char(0)))
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 1.500)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.750)
   SET rptsd->m_width = 4.750
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _holdremmedsfld = _remmedsfld
   IF (_remmedsfld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remmedsfld,((size(info->
        transfusionreactiondescription) - _remmedsfld)+ 1),info->transfusionreactiondescription)))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remmedsfld = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remmedsfld,((size(info->
        transfusionreactiondescription) - _remmedsfld)+ 1),info->transfusionreactiondescription)))))
     SET _remmedsfld = (_remmedsfld+ rptsd->m_drawlength)
    ELSE
     SET _remmedsfld = 0
    ENDIF
    SET growsum = (growsum+ _remmedsfld)
   ENDIF
   SET rptsd->m_flags = 4
   IF (ncalc=rpt_render
    AND _holdremmedsfld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremmedsfld,((size(
        info->transfusionreactiondescription) - _holdremmedsfld)+ 1),info->
       transfusionreactiondescription)))
   ELSE
    SET _remmedsfld = _holdremmedsfld
   ENDIF
   SET rptsd->m_y = (offsety+ 1.323)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Volume Transfused:",char(0)))
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 1.323)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.000)
   SET rptsd->m_width = 6.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   SET _holdremmedsfld1 = _remmedsfld1
   IF (_remmedsfld1 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remmedsfld1,((size(info->
        amountinfused) - _remmedsfld1)+ 1),info->amountinfused)))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remmedsfld1 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remmedsfld1,((size(info->amountinfused)
        - _remmedsfld1)+ 1),info->amountinfused)))))
     SET _remmedsfld1 = (_remmedsfld1+ rptsd->m_drawlength)
    ELSE
     SET _remmedsfld1 = 0
    ENDIF
    SET growsum = (growsum+ _remmedsfld1)
   ENDIF
   SET rptsd->m_flags = 4
   IF (ncalc=rpt_render
    AND _holdremmedsfld1 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremmedsfld1,((size(
        info->amountinfused) - _holdremmedsfld1)+ 1),info->amountinfused)))
   ELSE
    SET _remmedsfld1 = _holdremmedsfld1
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE staticsec(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = staticsecabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow7(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow7abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow7abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.250
   SET _oldfont = uar_rptsetfont(_hreport,_times80)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2("Assigned Pool Number:",char(
        0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.125)
   SET rptsd->m_width = 6.375
   SET rptsd->m_height = 0.250
   SET _dummypen = uar_rptsetpen(_hreport,_pen5s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,"")
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.125),offsety,(offsetx+ 1.125),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.500),offsety,(offsetx+ 7.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 7.500),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 7.500),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow11(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow11abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow11abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 7.500
   SET rptsd->m_height = 0.250
   SET _oldfont = uar_rptsetfont(_hreport,_times80)
   SET _oldpen = uar_rptsetpen(_hreport,_pen5s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,"")
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.500),offsety,(offsetx+ 7.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 7.500),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 7.500),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow14(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow14abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow14abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.115849), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 7.500
   SET rptsd->m_height = 0.116
   SET _oldfont = uar_rptsetfont(_hreport,_times8b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,"")
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.500),offsety,(offsetx+ 7.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 7.500),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 7.500),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow6(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow6abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow6abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.188923), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 7.500
   SET rptsd->m_height = 0.189
   SET _oldfont = uar_rptsetfont(_hreport,_times8b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(
       "Summary of Diagnostic Investigation:",char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.500),offsety,(offsetx+ 7.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 7.500),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 7.500),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow12(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow12abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow12abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.248580), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.249
   SET _oldfont = uar_rptsetfont(_hreport,_times80)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2("Clerical Check:",char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.750)
   SET rptsd->m_width = 6.750
   SET rptsd->m_height = 0.249
   SET _dummypen = uar_rptsetpen(_hreport,_pen5s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,"")
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.750),offsety,(offsetx+ 0.750),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.500),offsety,(offsetx+ 7.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 7.500),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 7.500),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow13(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow13abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow13abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.562
   SET rptsd->m_height = 0.250
   SET _oldfont = uar_rptsetfont(_hreport,_times80)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(
       "Assessment of infusion practice:",char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.562)
   SET rptsd->m_width = 5.938
   SET rptsd->m_height = 0.250
   SET _dummypen = uar_rptsetpen(_hreport,_pen5s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,"")
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.562),offsety,(offsetx+ 1.562),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.500),offsety,(offsetx+ 7.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 7.500),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 7.500),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow10(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow10abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow10abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.248731), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.875
   SET rptsd->m_height = 0.249
   SET _oldfont = uar_rptsetfont(_hreport,_times80)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2(
       "Conclusion of serological investigation: ",char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.875)
   SET rptsd->m_width = 5.625
   SET rptsd->m_height = 0.249
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen5s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,"")
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.875),offsety,(offsetx+ 1.875),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.500),offsety,(offsetx+ 7.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 7.500),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 7.500),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE staticsecabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(3.420000), private
   DECLARE holdheight = f8 WITH noconstant(0.0), private
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen0s0c0)
    IF (ncalc=rpt_render)
     SET _yoffset = (offsety+ 1.688)
     SET holdheight = 0
     SET holdheight = (holdheight+ tablerow7(rpt_render))
     SET holdheight = (holdheight+ tablerow11(rpt_render))
     SET holdheight = (holdheight+ tablerow14(rpt_render))
     SET holdheight = (holdheight+ tablerow6(rpt_render))
     SET holdheight = (holdheight+ tablerow12(rpt_render))
     SET holdheight = (holdheight+ tablerow13(rpt_render))
     SET holdheight = (holdheight+ tablerow10(rpt_render))
     SET _yoffset = offsety
    ENDIF
    SET rptsd->m_flags = 20
    SET rptsd->m_borders = rpt_sdbottomborder
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 1.125)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.313
    SET _oldfont = uar_rptsetfont(_hreport,_times8b0)
    SET _dummypen = uar_rptsetpen(_hreport,_pen10s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Blood Product Code",char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Blood Product Code",char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 6.500)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Age of Product At Issue",char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 5.438)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Date of Collection",char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 4.375)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Date/time Issued",char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 3.313)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("ABO/Rh",char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 2.250)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Unit ID Number/Lot Number",char(0)))
    SET rptsd->m_y = (offsety+ 0.375)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    SET rptsd->m_y = (offsety+ 0.375)
    SET rptsd->m_x = (offsetx+ 6.500)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    SET rptsd->m_y = (offsety+ 0.375)
    SET rptsd->m_x = (offsetx+ 5.438)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    SET rptsd->m_y = (offsety+ 0.375)
    SET rptsd->m_x = (offsetx+ 4.375)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    SET rptsd->m_y = (offsety+ 0.375)
    SET rptsd->m_x = (offsetx+ 3.313)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    SET rptsd->m_y = (offsety+ 0.375)
    SET rptsd->m_x = (offsetx+ 2.250)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    SET rptsd->m_y = (offsety+ 0.375)
    SET rptsd->m_x = (offsetx+ 1.125)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    SET rptsd->m_y = (offsety+ 0.625)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    SET rptsd->m_y = (offsety+ 0.625)
    SET rptsd->m_x = (offsetx+ 6.500)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    SET rptsd->m_y = (offsety+ 0.625)
    SET rptsd->m_x = (offsetx+ 5.438)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    SET rptsd->m_y = (offsety+ 0.625)
    SET rptsd->m_x = (offsetx+ 4.375)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    SET rptsd->m_y = (offsety+ 0.625)
    SET rptsd->m_x = (offsetx+ 3.313)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    SET rptsd->m_y = (offsety+ 0.625)
    SET rptsd->m_x = (offsetx+ 2.250)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    SET rptsd->m_y = (offsety+ 0.625)
    SET rptsd->m_x = (offsetx+ 1.125)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    SET rptsd->m_y = (offsety+ 0.875)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    SET rptsd->m_y = (offsety+ 0.875)
    SET rptsd->m_x = (offsetx+ 6.500)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    SET rptsd->m_y = (offsety+ 0.875)
    SET rptsd->m_x = (offsetx+ 5.438)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    SET rptsd->m_y = (offsety+ 0.875)
    SET rptsd->m_x = (offsetx+ 4.375)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    SET rptsd->m_y = (offsety+ 0.875)
    SET rptsd->m_x = (offsetx+ 3.313)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    SET rptsd->m_y = (offsety+ 0.875)
    SET rptsd->m_x = (offsetx+ 2.250)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    SET rptsd->m_y = (offsety+ 0.875)
    SET rptsd->m_x = (offsetx+ 1.125)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    SET rptsd->m_y = (offsety+ 1.125)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    SET rptsd->m_y = (offsety+ 1.125)
    SET rptsd->m_x = (offsetx+ 6.500)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    SET rptsd->m_y = (offsety+ 1.125)
    SET rptsd->m_x = (offsetx+ 5.438)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    SET rptsd->m_y = (offsety+ 1.125)
    SET rptsd->m_x = (offsetx+ 4.375)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    SET rptsd->m_y = (offsety+ 1.125)
    SET rptsd->m_x = (offsetx+ 3.313)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    SET rptsd->m_y = (offsety+ 1.125)
    SET rptsd->m_x = (offsetx+ 2.250)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    SET rptsd->m_y = (offsety+ 1.125)
    SET rptsd->m_x = (offsetx+ 1.125)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    SET rptsd->m_y = (offsety+ 1.375)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    SET rptsd->m_y = (offsety+ 1.375)
    SET rptsd->m_x = (offsetx+ 6.500)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    SET rptsd->m_y = (offsety+ 1.375)
    SET rptsd->m_x = (offsetx+ 5.438)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    SET rptsd->m_y = (offsety+ 1.375)
    SET rptsd->m_x = (offsetx+ 4.375)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    SET rptsd->m_y = (offsety+ 1.375)
    SET rptsd->m_x = (offsetx+ 3.313)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    SET rptsd->m_y = (offsety+ 1.375)
    SET rptsd->m_x = (offsetx+ 2.250)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    SET rptsd->m_y = (offsety+ 1.375)
    SET rptsd->m_x = (offsetx+ 1.125)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE footsec(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footsecabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE footsecabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 64
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 6.500)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.250
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(rpt_pageofpage,char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 100
   SET rptreport->m_reportname = "BHS_RPT_TRANSFUSION_TAG"
   SET rptreport->m_pagewidth = 8.50
   SET rptreport->m_pageheight = 11.00
   SET rptreport->m_orientation = rpt_portrait
   SET rptreport->m_marginleft = 0.50
   SET rptreport->m_marginright = 0.50
   SET rptreport->m_margintop = 0.50
   SET rptreport->m_marginbottom = 0.50
   SET rptreport->m_horzprintoffset = _xshift
   SET rptreport->m_vertprintoffset = _yshift
   SET _yoffset = rptreport->m_margintop
   SET _xoffset = rptreport->m_marginleft
   SET _hreport = uar_rptcreatereport(rptreport,_outputtype,rpt_inches)
   SET _rpterr = uar_rptseterrorlevel(_hreport,rpt_error)
   SET _rptstat = uar_rptstartreport(_hreport)
   SET _rptpage = uar_rptstartpage(_hreport)
   CALL _createfonts(0)
   CALL _createpens(0)
 END ;Subroutine
 SUBROUTINE _createfonts(dummy)
   SET rptfont->m_recsize = 50
   SET rptfont->m_fontname = rpt_times
   SET rptfont->m_pointsize = 10
   SET rptfont->m_bold = rpt_off
   SET rptfont->m_italic = rpt_off
   SET rptfont->m_underline = rpt_off
   SET rptfont->m_strikethrough = rpt_off
   SET rptfont->m_rgbcolor = rpt_black
   SET _times100 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 20
   SET _times200 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 12
   SET rptfont->m_bold = rpt_on
   SET _times12b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 8
   SET _times8b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_bold = rpt_off
   SET _times80 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_bold = rpt_on
   SET rptfont->m_underline = rpt_on
   SET _times8bu0 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penwidth = 0.005
   SET rptpen->m_penstyle = 1
   SET _pen5s1c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penwidth = 0.000
   SET rptpen->m_penstyle = 0
   SET _pen0s0c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penwidth = 0.002
   SET rptpen->m_penstyle = 1
   SET _pen2s1c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penwidth = 0.001
   SET rptpen->m_penstyle = 3
   SET _pen1s3c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penwidth = 0.005
   SET rptpen->m_penstyle = 0
   SET _pen5s0c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penwidth = 0.010
   SET _pen10s0c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 SET d0 = initializereport(0)
 SET d0 = headsec(rpt_render)
 SET d0 = linesec(rpt_render)
 SET d0 = patientsec(rpt_render)
 SET d0 = linesec(rpt_render)
 SET d0 = admitdxsec(rpt_render,8.5,becont)
 IF (((_yoffset+ problemsec(rpt_calcheight,8.5,becont)) > 10))
  SET d0 = pgbreak(1)
 ENDIF
 SET d0 = linesec(rpt_render)
 SET d0 = problemsec(rpt_render,8.5,becont)
 IF (((_yoffset+ formssec(rpt_calcheight,8.5,becont)) > 10))
  SET d0 = pgbreak(1)
 ENDIF
 SET d0 = linesec(rpt_render)
 SET d0 = formssec(rpt_render,8.5,becont)
 IF (((_yoffset+ reactionsec(rpt_calcheight,8.5,becont)) > 10))
  SET d0 = pgbreak(1)
 ENDIF
 SET d0 = linesec(rpt_render)
 SET d0 = reactionsec(rpt_render,8.5,becont)
 IF (((_yoffset+ labssec(rpt_calcheight,8.5,becont)) > 10))
  SET d0 = pgbreak(1)
 ENDIF
 SET d0 = linesec(rpt_render)
 SET d0 = labssec(rpt_render,8.5,becont)
 IF (((_yoffset+ reactioninfosec(rpt_calcheight,8.5,becont)) > 10))
  SET d0 = pgbreak(1)
 ENDIF
 SET d0 = linesec(rpt_render)
 SET d0 = reactioninfosec(rpt_render,8.5,becont)
 IF ((((_yoffset+ medssec(rpt_calcheight,8.5,becont))+ o2sec(rpt_calcheight,8.5,becont)) > 10))
  SET d0 = pgbreak(1)
 ENDIF
 SET d0 = linesec(rpt_render)
 SET d0 = medssec(rpt_render,8.5,becont)
 SET d0 = linesec(rpt_render)
 SET d0 = o2sec(rpt_render,8.5,becont)
 IF (((_yoffset+ vitalssec(rpt_calcheight,8.5,becont)) > 10))
  SET d0 = pgbreak(1)
 ENDIF
 SET d0 = linesec(rpt_render)
 SET d0 = vitalssec(rpt_render,8.5,becont)
 IF (((_yoffset+ staticsec(rpt_calcheight)) > 10))
  SET d0 = pgbreak(1)
 ENDIF
 SET d0 = linesec(rpt_render)
 SET d0 = staticsec(rpt_render)
 SET d0 = linesec(rpt_render)
 SET d0 = footsec(rpt_render)
 SET d0 = finalizereport(value(outputdev))
 SUBROUTINE pgbreak(dummy)
   CALL echo("Page break")
   SET d0 = linesec(rpt_render)
   SET d0 = footsec(rpt_render)
   SET d0 = pagebreak(dummy)
   SET d0 = headsec(rpt_render)
 END ;Subroutine
 SUBROUTINE validatecodevalue(type,codeset,val)
   SET codeval = 0.0
   SET codeval = uar_get_code_by(value(type),codeset,value(val))
   IF (codeval <= 0)
    SET errmsg = concat("failed finding code_val - type: ",type," codeset:",build(codeset)," val:",
     val)
    IF (validate(reqinfo->updt_id) > 0
     AND (reqinfo->updt_id > 0))
     SET euser = build(reqinfo->updt_id)
    ELSE
     SET euser = curuser
    ENDIF
    SET esubject = concat(trim(curnode,3)," - ",trim(curprog,3),"- userID:",trim(euser,3),
     " - Code Value error")
    CALL uar_send_mail("core.cis@bhs.org",esubject,errmsg,"discernCCL@bhs.org",5,
     "IPM.NOTE")
    GO TO exit_program
   ELSE
    CALL echo(concat("type: ",type," codeset:",build(codeset)," val:",
      val," Code_value=",cnvtstring(codeval)))
   ENDIF
   RETURN(codeval)
 END ;Subroutine
#exit_program
 IF (textlen(trim(errmsg,3)) > 0)
  CALL echo(errmsg)
  SELECT INTO value(outputdev)
   FROM dummyt
   HEAD REPORT
    msg1 = errmsg, col 0, "{PS/792 0 translate 90 rotate/}",
    y_pos = 18, row + 1, "{F/1}{CPI/12}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1
   WITH dio = 08, mine, time = 5
  ;end select
  DECLARE hlog = i4 WITH protect, noconstant(0)
  DECLARE hstat = i4 WITH protect, noconstant(0)
 ENDIF
END GO
