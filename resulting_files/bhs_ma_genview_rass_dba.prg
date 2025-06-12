CREATE PROGRAM bhs_ma_genview_rass:dba
 SET rhead =
 "{\rtf1\ansi \deff0{\fonttbl{\f0\fswiss Arial;}}{\colortbl;\red0\green0\blue0;\red255\green255\blue255;}\deftab1134"
 SET rh2bu = "\plain \f0 \fs20 \b \cb2 \pard\sl0 "
 SET rh2bu2 = "\plain \f0 \fs20 \b \ul \cb2 \pard\sl0 "
 SET rh2bu3 = "\plain \f0 \fs20 \b \ul\ \cb2 \pard\sl0 "
 SET rh2u = "\plain \f0 \fs18 \u \cb2 \pard\sl0 "
 SET rh2b = "\plain \f0 \fs20 \b \cb2 \pard\sl0 "
 SET rh2bs = "\plain \f0 \fs18 \b  \cb2 \pard\sl0 "
 SET reol = "\par"
 SET wr = " \plain \f0 \fs18 \cb2 "
 SET wru = " \plain \f0 \fs18 \ul \cb2 "
 SET rtfeof = "}"
 SET lidx = 0
 SET ivflag = 0
 SET alertflag = 0
 SET labflag = 0
 SET labordflag = 0
 SET rtab = "\tab "
 DECLARE rass_result = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "RICHMONDAGITATIONSEDATIONSCALERASS"))
 SET temp_disp = fillstring(40," ")
 SET temp_disp1 = fillstring(40," ")
 SET temp_disp2 = fillstring(40," ")
 SET temp_disp3 = fillstring(40," ")
 RECORD reply(
   1 text = vc
   1 status_data
     2 status = c1
 )
 SET reply->text = rhead
 RECORD drec(
   1 line_cnt = i4
   1 display_line = vc
   1 line_qual[*]
     2 disp_line = vc
 )
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SELECT DISTINCT INTO "nl:"
  ce_event_disp = uar_get_code_display(ce.event_cd), result_units_disp = uar_get_code_display(ce
   .result_units_cd), normalcy_disp = uar_get_code_display(ce.normalcy_cd),
  date = format(ce.event_end_dt_tm,"mm/dd/yy hh:mm;;d"), name = substring(1,40,p.name_full_formatted)
  FROM clinical_event ce,
   person p,
   encounter e
  PLAN (e
   WHERE (e.encntr_id=request->visit[1].encntr_id))
   JOIN (ce
   WHERE ce.person_id=e.person_id
    AND (ce.event_end_dt_tm > (sysdate - 70))
    AND ce.event_cd IN (rass_result)
    AND ce.view_level=1
    AND ce.publish_flag=1
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
    AND ce.event_end_dt_tm >= cnvtlookbehind("1440,MIN",cnvtdatetime(curdate,curtime3))
    AND ce.result_status_cd != 31)
   JOIN (p
   WHERE ce.updt_id=p.person_id)
  ORDER BY ce.event_end_dt_tm DESC
  HEAD REPORT
   cnt = 0, temp_disp = "Richmond Agitation Sedation Scale (RASS)", drec->line_qual[lidx].disp_line
    = concat(rhead,rh2bu,rtab,rh2bu3,trim(temp_disp),
    reol,reol,wr),
   lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx)
  DETAIL
   cnt = (cnt+ 1)
   IF (cnt > 0)
    IF (ce.normal_low > " "
     AND ce.normal_high > " ")
     reference_range = build("(",ce.normal_low,"-",ce.normal_high,uar_get_code_display(ce
       .result_units_cd),
      ")")
    ELSE
     reference_range = "(Nrml rng unspecfd)"
    ENDIF
    lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line =
    concat(rtab,date,"  ",trim(ce_event_disp),"  ",
     trim(ce.result_val)," ",trim(result_units_disp),"  ",trim(normalcy_disp),
     "  ",name,reol)
   ENDIF
  FOOT REPORT
   row + 0
  WITH maxcol = 5000, nullreport, time = 30
 ;end select
 FOR (x = 1 TO lidx)
   SET reply->text = concat(reply->text,drec->line_qual[x].disp_line)
 ENDFOR
 SET reply->status_data.status = "S"
 SET reply->text = concat(reply->text,rtfeof)
 CALL echorecord(reply)
END GO
