CREATE PROGRAM bhs_ma_gen_results:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 DECLARE fallrisklevel = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"FALLRISKLEVEL")), protect
 DECLARE totalfallsriskscore = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"TOTALFALLSRISKSCORE"
   )), protect
 DECLARE abileft_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"ABILEFT")), protect
 DECLARE abiright_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"ABIRIGHT")), protect
 DECLARE activity = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,"ACTIVITY")), protect
 DECLARE otherpressureulcerlocationv = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "OTHERPRESSUREULCERLOCATIONV")), protect
 DECLARE otherpressureulcerlocationiv = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "OTHERPRESSUREULCERLOCATIONIV")), protect
 DECLARE otherpressureulcerlocationiii = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "OTHERPRESSUREULCERLOCATIONIII")), protect
 DECLARE otherpressureulcerlocationii = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "OTHERPRESSUREULCERLOCATIONII")), protect
 DECLARE otherpressureulcerlocationi = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "OTHERPRESSUREULCERLOCATIONI")), protect
 DECLARE weight_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"WEIGHT"))
 DECLARE height_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"HEIGHT"))
 CALL echorecord(request)
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 output_device = vc
    1 script_name = vc
    1 person_cnt = i4
    1 person[*]
      2 person_id = f8
    1 visit_cnt = i4
    1 visit[1]
      2 encntr_id = f8
    1 prsnl_cnt = i4
    1 prsnl[*]
      2 prsnl_id = f8
    1 nv_cnt = i4
    1 nv[*]
      2 pvc_name = vc
      2 pvc_value = vc
    1 batch_selection = vc
  )
  SET request->visit[1].encntr_id = 62799583.00
  SET request->output_device = "MINE"
  SET request->visit_cnt = 1
  CALL echo(build("validate =",validate(request)))
 ENDIF
 SET eid = request->visit[1].encntr_id
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 text = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 FREE RECORD dlrec
 RECORD drec(
   1 line_cnt = i4
   1 dislay_line = vc
   1 line_qual[*]
     2 disp_line = vc
 )
 FREE RECORD results
 RECORD results(
   1 painscore = vc
   1 ciwa = vc
   1 glasgow = vc
   1 braden = vc
   1 height = vc
   1 weight = vc
   1 falls = vc
   1 total_fall_risk = vc
   1 fall_risk_level = vc
   1 falls_ped = vc
   1 braden_q = vc
   1 restraint = vc
   1 seizure = vc
   1 suicide = vc
   1 companion = vc
   1 violenceplan = vc
   1 vitals = vc
   1 io_12 = vc
   1 io_24 = vc
   1 io[*]
     2 type = vc
     2 hour_range = vc
     2 io_line = vc
   1 intake_line_cnt = i4
   1 intake_line[*]
     2 column1 = vc
     2 column2 = vc
   1 output_line_cnt = i4
   1 output_line[*]
     2 column1 = vc
     2 column2 = vc
   1 activity[*]
     2 ordmnemonic = vc
     2 orddate = vc
   1 lastbm = vc
   1 neuro = vc
   1 cardio = vc
   1 respiratory = vc
   1 gi = vc
   1 gu = vc
   1 musculosk = vc
   1 integ = vc
   1 pain_assmt = vc
   1 patgoal = vc
   1 earlywarning = vc
   1 rass_score = vc
   1 cam1 = vc
   1 cam2 = vc
   1 cam3 = vc
   1 cam4 = vc
   1 gest_age = vc
   1 deliv_type = vc
   1 neonate_abs = vc
   1 dry_weight = vc
   1 mat_tox = vc
   1 mat_med_prg = vc
   1 mat_med_ld = vc
   1 risk_mtrnl = vc
   1 risk_neonate = vc
   1 birth_comp = vc
   1 bmi = vc
 )
 SET x = 1
 SET lidx = 0
 SET tmp_display1 = fillstring(30," ")
 DECLARE temp_disp1 = vc
 SET o_ordered_cd = uar_get_code_by("MEANING",6004,"ORDERED")
 SET rhead = "{\rtf1\ansi \deff0{\fonttbl{\f0\fswiss Arial;}}"
 SET rh2r = "\plain \f0 \fs18 \cb2 \pard\sl0 "
 SET rh2b = "\plain \f0 \fs18 \b \cb2 \pard\sl0 "
 SET rh2bu = "\plain \f0 \fs18 \b \ul \cb2 \pard\sl0 "
 SET rh2u = "\plain \f0 \fs18 \u \cb2 \pard\sl0 "
 SET rh2i = "\plain \f0 \fs18 \i \cb2 \pard\sl0 "
 SET reol = "\par"
 SET rtab = "\tab "
 SET wr = " \plain \f0 \fs18 "
 SET wb = " \plain \f0 \fs18 \b \cb2"
 SET wu = " \plain \f0 \fs18 \ul \cb "
 SET wi = " \plain \f0 \fs18 \i \cb2 "
 SET wbi = " \plain \f0 \fs18 \b \i \cb2 "
 SET wiu = " \plain \f0 \fs18 \i \ul \cb2 "
 SET wbiu = " \plain \f0 \fs18 \b \ul \i \cb2 "
 SET rtfeof = "}"
 SET painscore = uar_get_code_by("displaykey",72,"110PAINSCALESCORE")
 SET ciwa = uar_get_code_by("displaykey",72,"ALCOHOLWITHDRAWALSCORE")
 SET glasgow = uar_get_code_by("displaykey",72,"GLASGOWCOMASCORE")
 SET braden = uar_get_code_by("displaykey",72,"BRADENSCORE")
 SET falls = uar_get_code_by("displaykey",72,"FALLSRISKSCORE")
 SET falls_peds = uar_get_code_by("displaykey",72,"GRAFPIFSCORE")
 SET braden_q = uar_get_code_by("displayKey",72,"BRADENQSCOREPEDIATRICS")
 SET violenceplan = uar_get_code_by("displaykey",72,"VIOLENCEASSESSMENTPREVENTIONPLAN")
 SET lastbm = uar_get_code_by("displaykey",72,"LASTBOWELMOVEMENT")
 SET patgoal = uar_get_code_by("displaykey",72,"PATIENTSSTATEDGOAL")
 SET earlywarning = uar_get_code_by("displaykey",72,"EARLYWARNINGSCORE")
 SET rass_score = uar_get_code_by("displaykey",72,"RICHMONDAGITATIONSEDATIONSCALERASS")
 SET cam1 = uar_get_code_by("displaykey",72,"CAMISPATIENTINATTENTIVE")
 SET cam2 = uar_get_code_by("displaykey",72,"CAMISTHINKINGDISORGANIZED")
 SET cam3 = uar_get_code_by("displaykey",72,"CAMLEVELOFCONSCIOUSNESSALTERED")
 SET cam4 = uar_get_code_by("displaykey",72,"CAMMENTALSTATUSCHANGES")
 SET gest_age = uar_get_code_by("displaykey",72,"ESTIMATEDGESTATIONALAGEBYEXAM")
 SET deliv_type = uar_get_code_by("displaykey",72,"DELIVERYTYPE")
 SET neonate_abs = uar_get_code_by("displaykey",72,"NEOABSTINENCETOTALSCORE")
 SET dry_weight = uar_get_code_by("displaykey",72,"DRYWEIGHT")
 SET mat_tox = uar_get_code_by("displaykey",72,"TOXICOLOGYSCREENONMOTHER")
 SET mat_med_prg = uar_get_code_by("displaykey",72,"MATERNALMEDICATIONSDURINGPREGNANCY")
 SET mat_med_ld = uar_get_code_by("displaykey",72,"MATERNALMEDICATIONSDURINGLD")
 SET risk_mtrnl = uar_get_code_by("displaykey",72,"MATERNALRISKFACTORSAFFECTINGNEONATE")
 SET risk_neonate = uar_get_code_by("displaykey",72,"RISKFACTORSINUTERONEONATE")
 SET birth_comp = uar_get_code_by("displaykey",72,"BIRTHCOMPLICATIONS")
 SET neuro = uar_get_code_by("displaykey",72,"NEURO")
 SET respiratory = uar_get_code_by("displaykey",72,"RESPIRATORY")
 SET gi = uar_get_code_by("displaykey",72,"GI")
 SET gu = uar_get_code_by("displaykey",72,"GU")
 SET musculosk = uar_get_code_by("displaykey",72,"MUSCULOSKELETAL")
 SET integ = uar_get_code_by("displaykey",72,"INTEGUMENTARY")
 SET cardio = uar_get_code_by("displaykey",72,"CARDIOVASCULAR")
 SET bmi = uar_get_code_by("DISPLAYKEY",72,"BODYMASSINDEX")
 SELECT INTO "nl:"
  temp1 = trim(format(ce.event_end_dt_tm,"MM/DD/YYYY hh:mm;;d"),3)
  FROM clinical_event ce
  PLAN (ce
   WHERE ce.encntr_id=eid
    AND ((ce.event_cd+ 0) IN (painscore, ciwa, glasgow, braden, falls,
   violenceplan, falls_peds, braden_q, height_cd, weight_cd,
   lastbm, patgoal, earlywarning, rass_score, cam1,
   cam2, cam3, cam4, gest_age, deliv_type,
   neonate_abs, dry_weight, mat_tox, mat_med_prg, mat_med_ld,
   risk_mtrnl, risk_neonate, birth_comp, neuro, respiratory,
   gi, gu, musculosk, integ, cardio,
   bmi, fallrisklevel, totalfallsriskscore))
    AND ce.view_level=1
    AND ce.valid_until_dt_tm > sysdate
    AND ce.event_tag != "In Error")
  ORDER BY ce.event_end_dt_tm
  DETAIL
   IF (ce.event_cd=patgoal)
    results->patgoal = concat(trim(ce.event_tag)," ",concat(format(ce.clinsig_updt_dt_tm,
       "mm/dd/yy hh:mm;;q")))
   ELSEIF (ce.event_cd=earlywarning)
    results->earlywarning = concat(trim(ce.event_tag)," ",concat(format(ce.clinsig_updt_dt_tm,
       "mm/dd/yy hh:mm;;q")))
   ELSEIF (ce.event_cd=rass_score)
    results->rass_score = concat(trim(ce.event_tag)," ",concat(format(ce.clinsig_updt_dt_tm,
       "mm/dd/yy hh:mm;;q")))
   ELSEIF (ce.event_cd=cam1)
    results->cam1 = concat(trim(ce.event_tag)," ",concat(format(ce.clinsig_updt_dt_tm,
       "mm/dd/yy hh:mm;;q")))
   ELSEIF (ce.event_cd=cam2)
    results->cam2 = concat(trim(ce.event_tag)," ",concat(format(ce.clinsig_updt_dt_tm,
       "mm/dd/yy hh:mm;;q")))
   ELSEIF (ce.event_cd=cam3)
    results->cam3 = concat(trim(ce.event_tag)," ",concat(format(ce.clinsig_updt_dt_tm,
       "mm/dd/yy hh:mm;;q")))
   ELSEIF (ce.event_cd=cam4)
    results->cam4 = concat(trim(ce.event_tag)," ",concat(format(ce.clinsig_updt_dt_tm,
       "mm/dd/yy hh:mm;;q")))
   ELSEIF (ce.event_cd=gest_age)
    results->gest_age = concat(trim(ce.event_tag)," ",concat(format(ce.clinsig_updt_dt_tm,
       "mm/dd/yy hh:mm;;q")))
   ELSEIF (ce.event_cd=deliv_type)
    results->deliv_type = concat(trim(ce.event_tag)," ",concat(format(ce.clinsig_updt_dt_tm,
       "mm/dd/yy hh:mm;;q")))
   ELSEIF (ce.event_cd=painscore)
    results->painscore = concat(trim(ce.event_tag)," ",concat(format(ce.clinsig_updt_dt_tm,
       "mm/dd/yy hh:mm;;q")))
   ELSEIF (ce.event_cd=ciwa)
    results->ciwa = concat(trim(ce.event_tag)," ",concat(format(ce.clinsig_updt_dt_tm,
       "mm/dd/yy hh:mm;;q")))
   ELSEIF (ce.event_cd=glasgow)
    results->glasgow = concat(trim(ce.event_tag)," ",concat(format(ce.clinsig_updt_dt_tm,
       "mm/dd/yy hh:mm;;q")))
   ELSEIF (ce.event_cd=neonate_abs)
    results->neonate_abs = concat(trim(ce.event_tag)," ",concat(format(ce.clinsig_updt_dt_tm,
       "mm/dd/yy hh:mm;;q")))
   ELSEIF (ce.event_cd=braden)
    results->braden = concat(trim(ce.event_tag)," ",concat(format(ce.clinsig_updt_dt_tm,
       "mm/dd/yy hh:mm;;q")))
   ELSEIF (ce.event_cd=falls)
    results->falls = concat(trim(ce.event_tag)," ",concat(format(ce.clinsig_updt_dt_tm,
       "mm/dd/yy hh:mm;;q")))
   ELSEIF (ce.event_cd=violenceplan)
    results->violenceplan = concat(format(ce.clinsig_updt_dt_tm,"mm/dd/yy hh:mm;;q"))
   ELSEIF (ce.event_cd=falls_peds)
    results->falls_ped = concat(ce.event_tag)
   ELSEIF (ce.event_cd=braden_q)
    results->braden_q = concat(ce.event_tag)
   ELSEIF (ce.event_cd=height_cd)
    results->height = concat(trim(ce.result_val,3)," ",trim(uar_get_code_display(ce.result_units_cd),
      3)," ",temp1)
   ELSEIF (ce.event_cd=weight_cd)
    results->weight = concat(trim(ce.result_val,3)," ",trim(uar_get_code_display(ce.result_units_cd),
      3)," ",temp1)
   ELSEIF (ce.event_cd=bmi)
    results->bmi = concat(trim(ce.result_val,3)," ",temp1)
   ELSEIF (ce.event_class_cd=223)
    results->lastbm = concat(substring(7,2,ce.result_val),"/",substring(9,2,ce.result_val),"/",
     substring(3,4,ce.result_val),
     " ")
   ELSEIF (ce.event_cd=dry_weight)
    results->dry_weight = concat(trim(ce.event_tag)," ",concat(format(ce.clinsig_updt_dt_tm,
       "mm/dd/yy hh:mm;;q")))
   ELSEIF (ce.event_cd=mat_tox)
    results->mat_tox = concat(trim(ce.event_tag)," ",concat(format(ce.clinsig_updt_dt_tm,
       "mm/dd/yy hh:mm;;q")))
   ELSEIF (ce.event_cd=mat_med_prg)
    results->mat_med_prg = concat(trim(ce.event_tag)," ",concat(format(ce.clinsig_updt_dt_tm,
       "mm/dd/yy hh:mm;;q")))
   ELSEIF (ce.event_cd=mat_med_ld)
    results->mat_med_ld = concat(trim(ce.event_tag)," ",concat(format(ce.clinsig_updt_dt_tm,
       "mm/dd/yy hh:mm;;q")))
   ELSEIF (ce.event_cd=risk_mtrnl)
    results->risk_mtrnl = concat(trim(ce.event_tag)," ",concat(format(ce.clinsig_updt_dt_tm,
       "mm/dd/yy hh:mm;;q")))
   ELSEIF (ce.event_cd=risk_neonate)
    results->risk_neonate = concat(trim(ce.event_tag)," ",concat(format(ce.clinsig_updt_dt_tm,
       "mm/dd/yy hh:mm;;q")))
   ELSEIF (ce.event_cd=birth_comp)
    results->birth_comp = concat(trim(ce.event_tag)," ",concat(format(ce.clinsig_updt_dt_tm,
       "mm/dd/yy hh:mm;;q")))
   ELSEIF (ce.event_cd=neuro)
    results->neuro = concat(trim(ce.event_tag)," ",concat(format(ce.clinsig_updt_dt_tm,
       "mm/dd/yy hh:mm;;q")))
   ELSEIF (ce.event_cd=cardio)
    results->cardio = concat(trim(ce.event_tag)," ",concat(format(ce.clinsig_updt_dt_tm,
       "mm/dd/yy hh:mm;;q")))
   ELSEIF (ce.event_cd=respiratory)
    results->respiratory = concat(trim(ce.event_tag)," ",concat(format(ce.clinsig_updt_dt_tm,
       "mm/dd/yy hh:mm;;q")))
   ELSEIF (ce.event_cd=gi)
    results->gi = concat(trim(ce.event_tag)," ",concat(format(ce.clinsig_updt_dt_tm,
       "mm/dd/yy hh:mm;;q")))
   ELSEIF (ce.event_cd=gu)
    results->gu = concat(trim(ce.event_tag)," ",concat(format(ce.clinsig_updt_dt_tm,
       "mm/dd/yy hh:mm;;q")))
   ELSEIF (ce.event_cd=musculosk)
    results->musculosk = concat(trim(ce.event_tag)," ",concat(format(ce.clinsig_updt_dt_tm,
       "mm/dd/yy hh:mm;;q")))
   ELSEIF (ce.event_cd=integ)
    results->integ = concat(trim(ce.event_tag)," ",concat(format(ce.clinsig_updt_dt_tm,
       "mm/dd/yy hh:mm;;q")))
   ELSEIF (ce.event_cd=fallrisklevel)
    results->fall_risk_level = concat(trim(ce.event_tag)," ",concat(format(ce.clinsig_updt_dt_tm,
       "mm/dd/yy hh:mm;;q")))
   ELSEIF (ce.event_cd=totalfallsriskscore)
    results->total_fall_risk = concat(trim(ce.event_tag)," ",concat(format(ce.clinsig_updt_dt_tm,
       "mm/dd/yy hh:mm;;q")))
   ENDIF
  WITH nocounter
 ;end select
 SET restraints = uar_get_code_by("displaykey",106,"RESTRAINTS")
 SET seizure = uar_get_code_by("displaykey",200,"SEIZUREPRECAUTIONS")
 SET suicide = uar_get_code_by("displaykey",200,"SUICIDEPRECAUTIONS")
 SET companion = uar_get_code_by("displaykey",200,"CONSTANTCOMPANION")
 SELECT INTO "nl:"
  FROM orders o
  PLAN (o
   WHERE o.encntr_id=eid
    AND ((o.activity_type_cd=restraints) OR (o.catalog_cd IN (seizure, suicide, companion, activity)
    AND o.order_status_cd=o_ordered_cd)) )
  ORDER BY o.current_start_dt_tm
  HEAD REPORT
   temp = fillstring(100," "), c = 0
  DETAIL
   IF (o.activity_type_cd=restraints
    AND o.order_status_cd=o_ordered_cd)
    results->restraint = concat(trim(o.order_mnemonic)," ",trim(o.clinical_display_line))
   ELSEIF (o.catalog_cd=seizure)
    results->seizure = "Seizure Precautions"
   ELSEIF (o.catalog_cd=suicide)
    results->suicide = "Suicide Precautions"
   ELSEIF (o.catalog_cd=companion)
    results->companion = trim(o.order_mnemonic)
   ELSEIF (o.catalog_cd=activity)
    c = (c+ 1), stat = alterlist(results->activity,c), results->activity[c].ordmnemonic = trim(o
     .clinical_display_line),
    results->activity[c].orddate = trim(format(o.current_start_dt_tm,"mm/dd/yyyy hh:mm;;q"))
   ENDIF
  WITH nocounter
 ;end select
 SET tempc = uar_get_code_by("displaykey",72,"TEMPERATURE")
 SET o2_sat = uar_get_code_by("displaykey",72,"OXYGENSATURATION")
 SET pulse = uar_get_code_by("displaykey",72,"PULSERATE")
 SET rr = uar_get_code_by("displaykey",72,"RESPIRATORYRATE")
 SET sbp = uar_get_code_by("displaykey",72,"SYSTOLICBLOODPRESSURE")
 SET dbp = uar_get_code_by("displaykey",72,"DIASTOLICBLOODPRESSURE")
 SET fb = uar_get_code_by("description",93,"IO")
 SET intake_cd = uar_get_code_by("displaykey",93,"INTAKE")
 SET output_cd = uar_get_code_by("displaykey",93,"OUTPUT")
 SELECT INTO "nl:"
  temp2 = format(ce.event_end_dt_tm,"MM/DD/YYYY hh:mm;;d")
  FROM clinical_event ce
  PLAN (ce
   WHERE ce.encntr_id=eid
    AND ((ce.event_cd+ 0) IN (tempc, o2_sat, pulse, rr, sbp,
   dbp, abileft_var, abiright_var))
    AND ce.view_level=1
    AND ce.valid_until_dt_tm > sysdate)
  ORDER BY ce.event_cd, ce.valid_from_dt_tm DESC
  HEAD REPORT
   temp = fillstring(500,"")
  HEAD ce.event_cd
   IF ((results->vitals > " "))
    temp = concat("\par","  ",trim(temp2),"_",trim(ce.event_title_text),
     ": ",trim(ce.event_tag)), results->vitals = concat(results->vitals,temp)
   ELSE
    results->vitals = concat(reol," ",trim(temp2),"_",trim(ce.event_title_text),
     ": ",trim(ce.event_tag))
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  12hr_ind =
  IF (ce.event_end_dt_tm > datetimeadd(cnvtdatetime(curdate,curtime),- ((720/ 1440.0)))) 1
  ELSE 0
  ENDIF
  FROM v500_event_set_canon es,
   v500_event_set_explode ese,
   clinical_event ce
  PLAN (es
   WHERE es.parent_event_set_cd=fb)
   JOIN (ese
   WHERE ese.event_set_cd=es.event_set_cd)
   JOIN (ce
   WHERE ce.event_cd=ese.event_cd
    AND ce.view_level=1
    AND ce.encntr_id=eid)
  HEAD REPORT
   12_intake_val = 0.0, 12_output_val = 0.0, 12_balance = 0.0,
   24_intake_val = 0.0, 24_output_val = 0.0, 24_balance = 0.0
  DETAIL
   IF (12hr_ind=1)
    num = cnvtreal(ce.result_val)
    IF (es.event_set_cd=intake_cd)
     12_intake_val = (12_intake_val+ num)
    ELSEIF (es.event_set_cd=output_cd)
     12_output_val = (12_output_val+ num)
    ENDIF
   ELSE
    num = cnvtreal(ce.result_val)
    IF (es.event_set_cd=intake_cd)
     24_intake_val = (24_intake_val+ num)
    ELSEIF (es.event_set_cd=output_cd)
     24_output_val = (24_output_val+ num)
    ENDIF
   ENDIF
  FOOT REPORT
   12_balance = (12_intake_val - 12_output_val), results->io_12 = concat(reol,rtab," ",
    "12 Hr Total Intake: ",cnvtstring(12_intake_val),
    reol,rtab," ","12 Hr Total Ouput: ",cnvtstring(12_output_val),
    reol,rtab," ","12 Hr Balance: ",cnvtstring(12_balance)), 24_balance = (24_intake_val -
   24_output_val),
   results->io_24 = concat(reol,rtab," ","24 Hr Total Intake: ",cnvtstring(24_intake_val),
    reol,rtab," ","24 Hr Total Ouput: ",cnvtstring(24_output_val),
    reol,rtab," ","24 Hr Balance: ",cnvtstring(24_balance))
  WITH nocounter
 ;end select
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = "ASSESSMENT RESULTS"
 SET drec->line_qual[lidx].disp_line = concat(rhead,rh2bu,trim(temp_disp1),reol,reol)
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = concat("Patient's Stated Goal: ",wr,results->patgoal)
 SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = "BIOPHYSICAL ASSESSMENT"
 SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 IF ((results->neuro > " "))
  SET temp_disp1 = concat("Neuro: ",wr,results->neuro)
  SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 ENDIF
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 IF ((results->cardio > " "))
  SET temp_disp1 = concat("Cardiovascular: ",wr,results->cardio)
  SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 ENDIF
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 IF ((results->respiratory > " "))
  SET temp_disp1 = concat("Respiratory: ",wr,results->respiratory)
  SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 ENDIF
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 IF ((results->gi > " "))
  SET temp_disp1 = concat("GI: ",wr,results->gi)
  SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 ENDIF
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 IF ((results->gu > " "))
  SET temp_disp1 = concat("GU: ",wr,results->gu)
  SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 ENDIF
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 IF ((results->musculosk > " "))
  SET temp_disp1 = concat("Musculoskeletal: ",wr,results->musculosk)
  SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 ENDIF
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 IF ((results->integ > " "))
  SET temp_disp1 = concat("Integumentary: ",wr,results->integ)
  SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 ENDIF
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 IF ((results->earlywarning > " "))
  SET temp_disp1 = concat("Early Warning Score: ",wr,results->earlywarning)
  SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 ENDIF
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 IF ((results->rass_score > " "))
  SET temp_disp1 = concat("RASS Score: ",wr,results->rass_score)
  SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 ENDIF
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 IF ((results->cam1 > " "))
  SET temp_disp1 = concat("CAM Is Patient Inattentive: ",wr,results->cam1)
  SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 ENDIF
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 IF ((results->cam2 > " "))
  SET temp_disp1 = concat("CAM Is Thinking Disorganized: ",wr,results->cam2)
  SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 ENDIF
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 IF ((results->cam3 > " "))
  SET temp_disp1 = concat("CAM Level of Consciousness Altered: ",wr,results->cam3)
  SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 ENDIF
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 IF ((results->cam4 > " "))
  SET temp_disp1 = concat("CAM Mental Status Change: ",wr,results->cam4)
  SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 ENDIF
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 IF ((results->gest_age > " "))
  SET temp_disp1 = concat("Gestational Age: ",wr,results->gest_age)
  SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 ENDIF
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 IF ((results->deliv_type > " "))
  SET temp_disp1 = concat("Delivery Type: ",wr,results->deliv_type)
  SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 ENDIF
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 IF ((results->painscore > " "))
  SET temp_disp1 = concat("Pain Score: ",wr,results->painscore)
  SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 ENDIF
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 IF ((results->ciwa > " "))
  SET temp_disp1 = concat("CIWA Score: ",wr,results->ciwa)
  SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 ENDIF
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 IF ((results->glasgow > " "))
  SET temp_disp1 = concat("Glasgow Score: ",wr,results->glasgow)
  SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 ENDIF
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 IF ((results->neonate_abs > " "))
  SET temp_disp1 = concat("Neonatal Abstinence Score: ",wr,results->neonate_abs)
  SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 ENDIF
 IF ((results->braden > " "))
  SET lidx = (lidx+ 1)
  SET stat = alterlist(drec->line_qual,lidx)
  SET temp_disp1 = concat("Braden Score: ",wr,results->braden)
  SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 ELSEIF ((results->falls_ped > " "))
  SET lidx = (lidx+ 1)
  SET stat = alterlist(drec->line_qual,lidx)
  SET temp_disp1 = concat("Braden Score: ",wr,results->braden_q)
  SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 ELSE
  SET lidx = (lidx+ 1)
  SET stat = alterlist(drec->line_qual,lidx)
  SET temp_disp1 = concat("Braden Score: ")
  SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 ENDIF
 IF ((results->total_fall_risk > " "))
  SET lidx = (lidx+ 1)
  SET stat = alterlist(drec->line_qual,lidx)
  SET temp_disp1 = concat("Falls Risk Score: ",wr,results->total_fall_risk,reol,wb,
   "Fall Risk Level: ",wr,results->fall_risk_level)
  SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 ELSEIF ((results->falls_ped > " "))
  SET lidx = (lidx+ 1)
  SET stat = alterlist(drec->line_qual,lidx)
  SET temp_disp1 = concat("Falls Risk Score: ",wr,results->falls_ped)
  SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 ELSE
  SET lidx = (lidx+ 1)
  SET stat = alterlist(drec->line_qual,lidx)
  SET temp_disp1 = concat("Falls Risk Score: ")
  SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 ENDIF
 IF ((results->violenceplan > " "))
  SET lidx = (lidx+ 1)
  SET stat = alterlist(drec->line_qual,lidx)
  SET temp_disp1 = concat("Violence Prevention Plan: ",wr,results->violenceplan)
  SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 ENDIF
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 IF ((results->restraint > " "))
  SET temp_disp1 = concat("Restraint Type: ",wr,results->restraint)
  SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 ENDIF
 IF ((results->seizure > ""))
  SET lidx = (lidx+ 1)
  SET stat = alterlist(drec->line_qual,lidx)
  SET temp_disp1 = concat("<<",trim(results->seizure),">>")
  SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 ENDIF
 IF ((results->suicide > ""))
  SET lidx = (lidx+ 1)
  SET stat = alterlist(drec->line_qual,lidx)
  SET temp_disp1 = concat("<<",results->suicide,">>")
  SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 ENDIF
 IF ((results->companion > ""))
  SET lidx = (lidx+ 1)
  SET stat = alterlist(drec->line_qual,lidx)
  SET temp_disp1 = concat("<<",results->companion,">>")
  SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 ENDIF
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 IF ((results->vitals > " "))
  SET temp_disp1 = concat("Vital Signs: ",wr,results->vitals)
  SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 ENDIF
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 IF ((results->height > " "))
  SET temp_disp1 = concat("Height: ",wr,results->height)
  SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 ENDIF
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 IF ((results->weight > " "))
  SET temp_disp1 = concat("Weight: ",wr,results->weight)
  SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 ENDIF
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 IF ((results->dry_weight > " "))
  SET temp_disp1 = concat("Dry Weight: ",wr,results->dry_weight)
  SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 ENDIF
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 IF ((results->lastbm > " "))
  SET temp_disp1 = concat("Last BM: ",wr,results->lastbm)
  SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 ENDIF
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 IF ((results->bmi > " "))
  SET temp_disp1 = concat("BMI: ",wr,results->bmi)
  SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 ENDIF
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 IF ((results->io_12 > " "))
  SET temp_disp1 = concat("12 Hr Intake/Output/Balance: ",wr,results->io_12)
  SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 ENDIF
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 IF ((results->io_24 > " "))
  SET temp_disp1 = concat("24 Hr Intake/Output/Balance: ",wr,results->io_24)
  SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 ENDIF
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 IF ((results->mat_tox > " "))
  SET temp_disp1 = concat("Maternal Toxicology Screen: ",wr,results->mat_tox)
  SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 ENDIF
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 IF ((results->mat_med_prg > " "))
  SET temp_disp1 = concat("Maternal Meds During Pregnancy: ",wr,results->mat_med_prg)
  SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 ENDIF
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 IF ((results->mat_med_ld > " "))
  SET temp_disp1 = concat("Maternal Meds During L&D: ",wr,results->mat_med_ld)
  SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 ENDIF
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 IF ((results->risk_mtrnl > " "))
  SET temp_disp1 = concat("Risk Factors in Utero Maternal: ",wr,results->risk_mtrnl)
  SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 ENDIF
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 IF ((results->risk_neonate > " "))
  SET temp_disp1 = concat("Risk Factors in Utero Neonate: ",wr,results->risk_neonate)
  SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 ENDIF
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 IF ((results->birth_comp > " "))
  SET temp_disp1 = concat("Birth Complications: ",wr,results->birth_comp)
  SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 ENDIF
 FOR (x = 1 TO lidx)
   SET reply->text = concat(reply->text,drec->line_qual[x].disp_line)
 ENDFOR
 SET reply->status_data.status = "S"
 SET reply->text = concat(reply->text,rtfeof)
 CALL echo(reply->text)
 FREE RECORD dlrec
 FREE RECORD request
END GO
