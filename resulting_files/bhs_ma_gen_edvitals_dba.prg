CREATE PROGRAM bhs_ma_gen_edvitals:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 DECLARE temp_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"TEMPERATURE")), protect
 DECLARE temp_route_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"TEMPERATUREROUTE")),
 protect
 DECLARE pulse_rate_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"PULSERATE")), protect
 DECLARE resp_rate_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"RESPIRATORYRATE")),
 protect
 DECLARE o2_sat_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"OXYGENSATURATION")), protect
 DECLARE o2_liters_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"LITERSPERMINUTE")),
 protect
 DECLARE o2_mode_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"MODEOFDELIVERYOXYGEN")),
 protect
 DECLARE bp_sys_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"SYSTOLICBLOODPRESSURE")),
 protect
 DECLARE bp_dia_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"DIASTOLICBLOODPRESSURE")),
 protect
 DECLARE bp_site_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"BLOODPRESSURESITES")),
 protect
 DECLARE weight_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"WEIGHT")), protect
 IF ( NOT (validate(request->visit[1].encntr_id,0)))
  FREE RECORD request
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
  SET request->visit[1].encntr_id = 51106832.00
  SET request->output_device = "MINE"
  SET request->visit_cnt = 1
 ENDIF
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
 FREE RECORD drec
 RECORD drec(
   1 line_cnt = i4
   1 dislay_line = vc
   1 line_qual[*]
     2 disp_line = vc
 )
 FREE RECORD results
 RECORD results(
   1 temp
     2 first_score = vc
     2 second_score = vc
   1 temp_route
     2 first_score = vc
     2 second_score = vc
   1 pulse_rate
     2 first_score = vc
     2 second_score = vc
   1 resp_rate
     2 first_score = vc
     2 second_score = vc
   1 o2_sat
     2 first_score = vc
     2 second_score = vc
   1 o2_liters
     2 first_score = vc
     2 second_score = vc
   1 o2_mode
     2 first_score = vc
     2 second_score = vc
   1 bp_sys
     2 first_score = vc
     2 second_score = vc
   1 bp_dia
     2 first_score = vc
     2 second_score = vc
   1 bp_site
     2 first_score = vc
     2 second_score = vc
   1 weight
     2 first_score = vc
     2 second_score = vc
 )
 SET x = 1
 SET lidx = 0
 SET tmp_display1 = fillstring(30," ")
 DECLARE temp_disp1 = vc
 SET rhead = "{\rtf1\ansi \deff0{\fonttbl{\f0\fswiss Arial;}}"
 SET rh2r = "\plain \f0 \fs18 \cb2 \pard\sl0 "
 SET rh2b = "\plain \f0 \fs18 \b \cb2 \pard\sl0 "
 SET rh2bu = "\plain \f0 \fs18 \b \ul \cb2 \pard\sl0 "
 SET rh2u = "\plain \f0 \fs18 \u \cb2 \pard\sl0 "
 SET rh2i = "\plain \f0 \fs18 \i \cb2 \pard\sl0 "
 SET reol = "\par "
 SET rtab = "\tab "
 SET wr = " \plain \f0 \fs18 "
 SET wb = " \plain \f0 \fs18 \b \cb2 "
 SET wu = " \plain \f0 \fs18 \ul \cb "
 SET wi = " \plain \f0 \fs18 \i \cb2 "
 SET wbi = " \plain \f0 \fs18 \b \i \cb2 "
 SET wiu = " \plain \f0 \fs18 \i \ul \cb2 "
 SET wbiu = " \plain \f0 \fs18 \b \ul \i \cb2 "
 SET rtfeof = "}"
 SELECT INTO "nl:"
  FROM clinical_event ce
  PLAN (ce
   WHERE (ce.encntr_id=request->visit[1].encntr_id)
    AND ((ce.event_cd+ 0) IN (temp_var, temp_route_var, pulse_rate_var, resp_rate_var, o2_sat_var,
   o2_liters_var, o2_mode_var, bp_sys_var, bp_dia_var, bp_site_var,
   weight_var))
    AND ce.publish_flag=1
    AND ce.valid_until_dt_tm > sysdate
    AND ce.event_tag != "In Error")
  ORDER BY ce.event_cd, ce.event_end_dt_tm
  HEAD REPORT
   var_clinical_event_id = 0
  HEAD ce.event_cd
   CASE (ce.event_cd)
    OF temp_var:
     results->temp.first_score = concat(trim(ce.result_val,3),"    ",format(ce.event_end_dt_tm,
       "mm/dd/yyyy hh:mm;;d")),var_clinical_event_id = ce.clinical_event_id
    OF temp_route_var:
     results->temp_route.first_score = concat(trim(ce.result_val,3),"    ",format(ce.event_end_dt_tm,
       "mm/dd/yyyy hh:mm;;d")),var_clinical_event_id = ce.clinical_event_id
    OF pulse_rate_var:
     results->pulse_rate.first_score = concat(trim(ce.result_val,3),"    ",format(ce.event_end_dt_tm,
       "mm/dd/yyyy hh:mm;;d")),var_clinical_event_id = ce.clinical_event_id
    OF resp_rate_var:
     results->resp_rate.first_score = concat(trim(ce.result_val,3),"    ",format(ce.event_end_dt_tm,
       "mm/dd/yyyy hh:mm;;d")),var_clinical_event_id = ce.clinical_event_id
    OF o2_sat_var:
     results->o2_sat.first_score = concat(trim(ce.result_val,3),"    ",format(ce.event_end_dt_tm,
       "mm/dd/yyyy hh:mm;;d")),var_clinical_event_id = ce.clinical_event_id
    OF o2_liters_var:
     results->o2_liters.first_score = concat(trim(ce.result_val,3),"    ",format(ce.event_end_dt_tm,
       "mm/dd/yyyy hh:mm;;d")),var_clinical_event_id = ce.clinical_event_id
    OF o2_mode_var:
     results->o2_mode.first_score = concat(trim(ce.result_val,3),"    ",format(ce.event_end_dt_tm,
       "mm/dd/yyyy hh:mm;;d")),var_clinical_event_id = ce.clinical_event_id
    OF bp_sys_var:
     results->bp_sys.first_score = concat(trim(ce.result_val,3),"    ",format(ce.event_end_dt_tm,
       "mm/dd/yyyy hh:mm;;d")),var_clinical_event_id = ce.clinical_event_id
    OF bp_dia_var:
     results->bp_dia.first_score = concat(trim(ce.result_val,3),"    ",format(ce.event_end_dt_tm,
       "mm/dd/yyyy hh:mm;;d")),var_clinical_event_id = ce.clinical_event_id
    OF bp_site_var:
     results->bp_site.first_score = concat(trim(ce.result_val,3),"    ",format(ce.event_end_dt_tm,
       "mm/dd/yyyy hh:mm;;d")),var_clinical_event_id = ce.clinical_event_id
    OF weight_var:
     results->weight.first_score = concat(trim(ce.result_val,3),"    ",format(ce.event_end_dt_tm,
       "mm/dd/yyyy hh:mm;;d")),var_clinical_event_id = ce.clinical_event_id
   ENDCASE
  DETAIL
   CASE (ce.event_cd)
    OF temp_var:
     IF (ce.clinical_event_id != var_clinical_event_id)
      results->temp.second_score = concat(trim(ce.result_val,3),"    ",format(ce.event_end_dt_tm,
        "mm/dd/yyyy hh:mm;;d"))
     ENDIF
    OF temp_route_var:
     IF (ce.clinical_event_id != var_clinical_event_id)
      results->temp_route.second_score = concat(trim(ce.result_val,3),"    ",format(ce
        .event_end_dt_tm,"mm/dd/yyyy hh:mm;;d"))
     ENDIF
    OF pulse_rate_var:
     IF (ce.clinical_event_id != var_clinical_event_id)
      results->pulse_rate.second_score = concat(trim(ce.result_val,3),"    ",format(ce
        .event_end_dt_tm,"mm/dd/yyyy hh:mm;;d"))
     ENDIF
    OF resp_rate_var:
     IF (ce.clinical_event_id != var_clinical_event_id)
      results->resp_rate.second_score = concat(trim(ce.result_val,3),"    ",format(ce.event_end_dt_tm,
        "mm/dd/yyyy hh:mm;;d"))
     ENDIF
    OF o2_sat_var:
     IF (ce.clinical_event_id != var_clinical_event_id)
      results->o2_sat.second_score = concat(trim(ce.result_val,3),"    ",format(ce.event_end_dt_tm,
        "mm/dd/yyyy hh:mm;;d"))
     ENDIF
    OF o2_liters_var:
     IF (ce.clinical_event_id != var_clinical_event_id)
      results->o2_liters.second_score = concat(trim(ce.result_val,3),"    ",format(ce.event_end_dt_tm,
        "mm/dd/yyyy hh:mm;;d"))
     ENDIF
    OF o2_mode_var:
     IF (ce.clinical_event_id != var_clinical_event_id)
      results->o2_mode.second_score = concat(trim(ce.result_val,3),"    ",format(ce.event_end_dt_tm,
        "mm/dd/yyyy hh:mm;;d"))
     ENDIF
    OF bp_sys_var:
     IF (ce.clinical_event_id != var_clinical_event_id)
      results->bp_sys.second_score = concat(trim(ce.result_val,3),"    ",format(ce.event_end_dt_tm,
        "mm/dd/yyyy hh:mm;;d"))
     ENDIF
    OF bp_dia_var:
     IF (ce.clinical_event_id != var_clinical_event_id)
      results->bp_dia.second_score = concat(trim(ce.result_val,3),"    ",format(ce.event_end_dt_tm,
        "mm/dd/yyyy hh:mm;;d"))
     ENDIF
    OF bp_site_var:
     IF (ce.clinical_event_id != var_clinical_event_id)
      results->bp_site.second_score = concat(trim(ce.result_val,3),"    ",format(ce.event_end_dt_tm,
        "mm/dd/yyyy hh:mm;;d"))
     ENDIF
    OF weight_var:
     IF (ce.clinical_event_id != var_clinical_event_id)
      results->weight.second_score = concat(trim(ce.result_val,3),"    ",format(ce.event_end_dt_tm,
        "mm/dd/yyyy hh:mm;;d"))
     ENDIF
   ENDCASE
  WITH nocounter
 ;end select
 CALL echorecord(results)
 SET temp_disp1 = " "
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = "VITAL SIGNS"
 SET drec->line_qual[lidx].disp_line = concat(rhead,rh2bu,trim(temp_disp1),reol,reol)
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = " "
 SET temp_disp1 = concat("First Temperature: ",wr,results->temp.first_score)
 SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = " "
 SET temp_disp1 = concat("Last Temperature: ",wr,results->temp.second_score)
 SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = " "
 SET temp_disp1 = concat("First Temperature Route: ",wr,results->temp_route.first_score)
 SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = " "
 SET temp_disp1 = concat("Last Temperature Route: ",wr,results->temp_route.second_score)
 SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = " "
 SET temp_disp1 = concat("First Pulse Rate: ",wr,results->pulse_rate.first_score)
 SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = " "
 SET temp_disp1 = concat("Last Pulse Rate: ",wr,results->pulse_rate.second_score)
 SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = " "
 SET temp_disp1 = concat("First Respiratory Rate: ",wr,results->resp_rate.first_score)
 SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = " "
 SET temp_disp1 = concat("Last Respiratory Rate: ",wr,results->resp_rate.second_score)
 SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = " "
 SET temp_disp1 = concat("First Oxygen Saturation: ",wr,results->o2_sat.first_score)
 SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = " "
 SET temp_disp1 = concat("Last Oxygen Saturation: ",wr,results->o2_sat.second_score)
 SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = " "
 SET temp_disp1 = concat("First O2 l/min: ",wr,results->o2_liters.first_score)
 SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 SET lidx = (lidx+ 1)
 SET temp_disp1 = " "
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = concat("Last O2 l/min: ",wr,results->o2_liters.second_score)
 SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = " "
 SET temp_disp1 = concat("First O2 delivery mode: ",wr,results->o2_mode.first_score)
 SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = " "
 SET temp_disp1 = concat("Last O2 delivery mode: ",wr,results->o2_mode.second_score)
 SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = " "
 SET temp_disp1 = concat("First Systolic BP: ",wr,results->bp_sys.first_score)
 SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = " "
 SET temp_disp1 = concat("Last Systolic BP: ",wr,results->bp_sys.second_score)
 SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = " "
 SET temp_disp1 = concat("First Diastolic BP: ",wr,results->bp_dia.first_score)
 SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = " "
 SET temp_disp1 = concat("Last Diastolic BP: ",wr,results->bp_dia.second_score)
 SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = " "
 SET temp_disp1 = concat("First BP Site: ",wr,results->bp_site.first_score)
 SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = " "
 SET temp_disp1 = concat("Last BP Site: ",wr,results->bp_site.second_score)
 SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = " "
 SET temp_disp1 = concat("First Weight: ",wr,results->weight.first_score)
 SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = " "
 SET temp_disp1 = concat("Last Weight: ",wr,results->weight.second_score)
 SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 FOR (x = 1 TO lidx)
   SET reply->text = concat(reply->text,drec->line_qual[x].disp_line)
 ENDFOR
 SET reply->status_data.status = "S"
 SET reply->text = concat(reply->text,rtfeof)
 CALL echo(reply->text)
 FREE RECORD drec
 FREE RECORD request
END GO
