CREATE PROGRAM bhs_ma_genview_last_inr:dba
 SET rhead =
 "{\rtf1\ansi \deff0{\fonttbl{\f0\fswiss Arial;}}{\colortbl;\red0\green0\blue0;\red255\green255\blue255;}\deftab1134"
 SET rh2bu3 = "\plain \f0 \fs20 \b \ul\ \cb2 \pard\sl0 "
 SET rh2bs = "\plain \f0 \fs18 \b \cb2 \pard\sl0 "
 SET reol = "\par"
 SET wr = " \plain \f0 \fs18 \cb2 "
 SET rtfeof = "}"
 SET lidx = 0
 SET inrflag = 0
 SET inr_cnt = 0
 DECLARE o_incomplete_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"INCOMPLETE"))
 DECLARE o_inprocess_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"INPROCESS"))
 DECLARE o_ordered_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"ORDERED"))
 DECLARE o_pending_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"PENDING"))
 DECLARE o_suspended_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"SUSPENDED"))
 DECLARE o_pending_rev_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"PENDING REV"))
 DECLARE o_completed_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"COMPLETED"))
 DECLARE order_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6003,"ORDER"))
 DECLARE inr_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"INR"))
 DECLARE inrresultdateandlabname = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "INRRESULTDATEANDLABNAME")), protect
 DECLARE pocinr_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",93,"INRPOINTOFCARE"))
 DECLARE inerror_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",8,"INERROR"))
 DECLARE warfarin_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",200,"WARFARIN"))
 SET temp_disp = fillstring(40," ")
 SET temp_disp2 = fillstring(40," ")
 SET temp_disp3 = fillstring(40," ")
 SET temp_disp4 = fillstring(40," ")
 SET reply->text = rhead
 RECORD drec(
   1 line_cnt = i4
   1 display_line = vc
   1 line_qual[*]
     2 disp_line = vc
 )
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SELECT INTO "nl:"
  date2 = format(o.orig_order_dt_tm,"mm/dd/yy hh:mm;;d")
  FROM orders o
  PLAN (o
   WHERE (o.encntr_id=request->visit[1].encntr_id)
    AND o.catalog_cd=warfarin_cd
    AND o.order_status_cd IN (o_incomplete_cd, o_inprocess_cd, o_ordered_cd, o_pending_cd,
   o_pending_rev_cd)
    AND o.template_order_flag IN (0, 1))
  HEAD REPORT
   temp_disp3 = "Oral Anticoagulation Orders", temp_disp4 = "(All Active Orders)", drec->line_qual[
   lidx].disp_line = concat(rhead,rh2bu3,trim(temp_disp3),wr,trim(temp_disp4),
    reol,wr),
   lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx)
  HEAD o.order_id
   drec->line_qual[lidx].disp_line = concat(rh2bs,date2," "," ",trim(o.ordered_as_mnemonic),
    "  ",wr,o.clinical_display_line,reol), lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx)
  FOOT  o.order_id
   row + 0
  FOOT REPORT
   row + 0
  WITH maxcol = 5000, nullreport
 ;end select
 SELECT DISTINCT INTO "nl:"
  ce_event_disp = uar_get_code_display(ce.event_cd), result_units_disp = uar_get_code_display(ce
   .result_units_cd), normalcy_disp = uar_get_code_display(ce.normalcy_cd),
  date = format(ce.event_end_dt_tm,"mm/dd/yy hh:mm;;d")
  FROM clinical_event ce,
   encounter e
  PLAN (e
   WHERE (e.encntr_id=request->visit[1].encntr_id))
   JOIN (ce
   WHERE ce.person_id=e.person_id
    AND ce.event_cd IN (pocinr_cd, inr_cd, inrresultdateandlabname)
    AND ce.view_level=1
    AND ce.publish_flag=1
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
    AND ce.event_end_dt_tm <= cnvtdatetime(curdate,curtime)
    AND ce.result_status_cd != 31)
  ORDER BY ce.event_end_dt_tm DESC, ce.parent_event_id
  HEAD REPORT
   IF (inrflag=0)
    temp_disp = "Last INR", temp_disp2 = "(Across Encounters)", drec->line_qual[lidx].disp_line =
    concat(rhead,rh2bu3,trim(temp_disp),wr,trim(temp_disp2),
     reol,wr),
    lidx = (lidx+ 1), inrflag = (inrflag+ 1), stat = alterlist(drec->line_qual,lidx)
   ENDIF
  HEAD ce.clinical_event_id
   IF (inr_cnt=0)
    drec->line_qual[lidx].disp_line = concat(wr,date," "," ",trim(ce_event_disp),
     "  ",rh2bs,trim(ce.result_val)," ",trim(result_units_disp),
     "  ",trim(normalcy_disp),reol), lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx),
    inr_cnt = (inr_cnt+ 1)
   ENDIF
  FOOT  ce.clinical_event_id
   row + 0
  FOOT REPORT
   row + 0
  WITH maxcol = 5000, nullreport
 ;end select
 FOR (x = 1 TO lidx)
   SET reply->text = concat(reply->text,drec->line_qual[x].disp_line)
 ENDFOR
 SET reply->status_data.status = "S"
 SET reply->text = concat(reply->text,rtfeof)
END GO
