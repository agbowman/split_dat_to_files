CREATE PROGRAM bhs_gen_preop_last_inr:dba
 SET rhead =
 "{\rtf1\ansi \deff0{\fonttbl{\f0\fswiss Arial;}}{\colortbl;\red0\green0\blue0;\red255\green255\blue255;}\deftab1134"
 SET rh2bu3 = "\plain \f0 \fs20 \b \ul\ \cb2 \pard\sl0 "
 SET rh2bs = "\plain \f0 \fs18 \b \cb2 \pard\sl0 "
 SET reol = "\par"
 SET wr = " \plain \f0 \fs18 \cb2 "
 SET rtfeof = "}"
 SET lidx = 0
 DECLARE inr_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"INR"))
 DECLARE pocinr_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"POCINRRESULTS"))
 DECLARE inerror_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",8,"INERROR"))
 SET reply->text = rhead
 RECORD drec(
   1 line_cnt = i4
   1 display_line = vc
   1 line_qual[*]
     2 disp_line = vc
 )
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SELECT DISTINCT INTO "NL:"
  ce_event_disp = uar_get_code_display(ce.event_cd), result_units_disp = uar_get_code_display(ce
   .result_units_cd), normalcy_disp = uar_get_code_display(ce.normalcy_cd),
  date = format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;D")
  FROM clinical_event ce,
   encounter e
  PLAN (e
   WHERE (e.encntr_id=request->visit[1].encntr_id))
   JOIN (ce
   WHERE ce.person_id=e.person_id
    AND ce.event_cd IN (pocinr_cd, inr_cd)
    AND ce.view_level=1
    AND ce.publish_flag=1
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND ce.event_end_dt_tm >= cnvtdatetime((curdate - 3),0)
    AND ce.result_status_cd != inerror_cd)
  ORDER BY ce.event_end_dt_tm DESC, ce.parent_event_id
  HEAD REPORT
   drec->line_qual[lidx].disp_line = concat(rh2bu3,"INR since ",format(cnvtdatetime((curdate - 3),0),
     "MM/DD/YYYY HH:MM;;D"),wr," (Across Encounters)",
    reol,wr), lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx)
  HEAD ce.clinical_event_id
   drec->line_qual[lidx].disp_line = concat(rh2bs,date," "," ",trim(ce_event_disp),
    "  ",wr,trim(ce.result_val)," ",trim(result_units_disp),
    "  ",trim(normalcy_disp),reol), lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx)
  WITH nullreport
 ;end select
 FOR (x = 1 TO lidx)
   SET reply->text = concat(reply->text,drec->line_qual[x].disp_line)
 ENDFOR
 SET reply->status_data.status = "S"
 SET reply->text = concat(reply->text,rtfeof)
END GO
