CREATE PROGRAM bhs_ma_gen_painscore:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 DECLARE painintensity_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"PAININTENSITY")),
 protect
 DECLARE intensityofpain_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"INTENSITYOFPAIN")),
 protect
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
  SET request->visit[1].encntr_id = 50660844.00
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
   1 first_score_p = vc
   1 first_score_p_dt = f8
   1 second_score_p = vc
   1 second_score_p_dt = f8
   1 first_score_i = vc
   1 first_score_i_dt = f8
   1 second_score_i = vc
   1 second_score_i_dt = f8
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
    AND ((ce.event_cd+ 0) IN (painintensity_var, intensityofpain_var))
    AND ce.publish_flag=1
    AND ce.valid_until_dt_tm > sysdate
    AND ce.event_tag != "In Error")
  ORDER BY ce.event_cd, ce.event_end_dt_tm
  HEAD REPORT
   var_clinical_event_id = 0, var_clinical_event2_id = 0
  HEAD ce.event_cd
   CALL echo(ce.event_cd),
   CALL echo(ce.result_val)
   CASE (ce.event_cd)
    OF painintensity_var:
     CALL echo("painintensity_var")results->first_score_p = concat(trim(ce.result_val,3),"    ",
      format(ce.event_end_dt_tm,"mm/dd/yyyy hh:mm;;d")),results->first_score_p_dt = ce
     .event_end_dt_tm,
     var_clinical_event_id = ce.clinical_event_id
    OF intensityofpain_var:
     CALL echo("intensityofpain_var")results->first_score_i = concat(trim(ce.result_val,3),"    ",
      format(ce.event_end_dt_tm,"mm/dd/yyyy hh:mm;;d")),results->first_score_i_dt = ce
     .event_end_dt_tm,
     var_clinical_event2_id = ce.clinical_event_id,
     CALL echo(build("results->first_score_i:",results->first_score_i))
     CALL echo(concat(trim(ce.result_val,3),"    ",format(ce.event_end_dt_tm,"mm/dd/yyyy hh:mm;;d")))
   ENDCASE
  DETAIL
   CASE (ce.event_cd)
    OF painintensity_var:
     IF (ce.clinical_event_id != var_clinical_event_id)
      results->second_score_p = concat(trim(ce.result_val,3),"    ",format(ce.event_end_dt_tm,
        "mm/dd/yyyy hh:mm;;d")), results->second_score_p_dt = ce.event_end_dt_tm
     ENDIF
    OF intensityofpain_var:
     IF (ce.clinical_event_id != var_clinical_event2_id)
      results->second_score_i = concat(trim(ce.result_val,3),"    ",format(ce.event_end_dt_tm,
        "mm/dd/yyyy hh:mm;;d")), results->second_score_i_dt = ce.event_end_dt_tm
     ENDIF
   ENDCASE
  WITH nocounter
 ;end select
 CALL echorecord(results)
 IF (curqual=0)
  SET results->first_score_p = "No Documentation"
  SET results->first_score_i = "No Documentation"
 ENDIF
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = "PAIN SCORES"
 SET drec->line_qual[lidx].disp_line = concat(rhead,rh2bu,trim(temp_disp1),reol,reol)
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = concat("First Pain Intensity Score: ",wr,results->first_score_p)
 SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = concat("Last Pain Intensity Score: ",wr,results->second_score_p)
 SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol,reol)
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = concat("First Intensity of Pain Score: ",wr,results->first_score_i)
 SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = concat("Last Intensity of Pain Score: ",wr,results->second_score_i)
 SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 FOR (x = 1 TO lidx)
   SET reply->text = concat(reply->text,drec->line_qual[x].disp_line)
 ENDFOR
 SET reply->status_data.status = "S"
 SET reply->text = concat(reply->text,rtfeof)
 CALL echo(reply->text)
 FREE RECORD dlrec
 FREE RECORD request
END GO
