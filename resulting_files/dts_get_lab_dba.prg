CREATE PROGRAM dts_get_lab:dba
 SET rhead =
 "{\rtf1\ansi \deff0{\fonttbl{\f0\fswiss Arial;}}{\colortbl;\red0\green0\blue0;\red255\green255\blue255;}\deftab1134"
 SET rh2r = "\plain \f0 \fs18 \cb2 \pard\sl0 "
 SET rh2b = "\plain \f0 \fs24 \b \cb2 \pard\sl0 "
 SET rh2bu = "\plain \f0 \fs18 \b \ul \cb2 \pard\sl0 "
 SET rh2u = "\plain \f0 \fs18 \u \cb2 \pard\sl0 "
 SET rh2i = "\plain \f0 \fs18 \i \cb2 \pard\sl0 "
 SET reol = "\par "
 SET rtab = "\tab "
 SET wr = " \plain \f0 \fs20 \cb2 "
 SET wb = " \plain \f0 \fs20 \b \cb2 "
 SET wu = " \plain \f0 \fs18 \ul \cb2 "
 SET wi = " \plain \f0 \fs18 \i \cb2 "
 SET wbi = " \plain \f0 \fs18 \b \i \cb2 "
 SET wiu = " \plain \f0 \fs18 \i \ul \cb2 "
 SET wbiu = " \plain \f0 \fs18 \b \ul \i \cb2 "
 SET wbu = " \plain \f0 \fs18 \b \ul \cb2 "
 SET rtfeof = "}"
 RECORD drec(
   1 line_cnt = i4
   1 display_line = vc
   1 line_qual[*]
     2 disp_line = vc
 )
 RECORD lab(
   1 cnt = i2
   1 qual[*]
     2 val = vc
     2 date = vc
     2 label = vc
     2 unit = vc
 )
 SET lidx = 0
 SET code_value = 0.0
 SET code_set = 0.0
 SET a_date = cnvtdatetime(curdate,curtime)
 SET inerror_cd = 0
 SET code_set = 8
 SET cdf_meaning = "INERROR"
 EXECUTE cpm_get_cd_for_cdf
 SET inerror_cd = code_value
 SET diff = 0
 SET beg_dt_tm = cnvtdatetime(curdate,curtime)
 SET end_dt_tm = cnvtdatetime(curdate,curtime)
 SET diff = datetimediff(cnvtdatetime(curdate,2359),cnvtdatetime(a_date))
 SET beg_dt_tm = cnvtdatetime((curdate - diff),0)
 SET end_dt_tm = cnvtdatetime((curdate - (diff - 1)),0)
 SELECT INTO "nl:"
  FROM v500_event_set_code vesc,
   v500_event_set_canon ves,
   v500_event_set_explode vese,
   clinical_event c,
   code_value cv,
   (dummyt d  WITH seq = 1),
   code_value cv2
  PLAN (vesc
   WHERE vesc.event_set_cd_disp_key IN ("CHEMISTRY", "HEMATOLOGY"))
   JOIN (ves
   WHERE ves.parent_event_set_cd=vesc.event_set_cd)
   JOIN (vese
   WHERE vese.event_set_cd=ves.event_set_cd)
   JOIN (c
   WHERE (c.person_id=request->person[1].person_id)
    AND (c.encntr_id=request->visit[1].encntr_id)
    AND c.event_cd=vese.event_cd
    AND c.view_level=1
    AND c.publish_flag=1
    AND c.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
    AND c.event_end_dt_tm >= cnvtdatetime(beg_dt_tm)
    AND c.event_end_dt_tm < cnvtdatetime(end_dt_tm)
    AND c.result_status_cd != inerror_cd)
   JOIN (cv
   WHERE cv.code_value=c.event_cd)
   JOIN (d)
   JOIN (cv2
   WHERE cv2.code_value=c.result_units_cd)
  ORDER BY cnvtdatetime(c.event_end_dt_tm)
  HEAD REPORT
   lab->cnt = 0
  DETAIL
   lab->cnt = (lab->cnt+ 1), stat = alterlist(lab->qual,lab->cnt), lab->qual[lab->cnt].val = c
   .event_tag,
   lab->qual[lab->cnt].label = cv.display, lab->qual[lab->cnt].unit = cv2.display
   IF ((lab->qual[lab->cnt].unit > " "))
    lab->qual[lab->cnt].val = concat(trim(lab->qual[lab->cnt].val)," ",trim(lab->qual[lab->cnt].unit)
     )
   ENDIF
   lab->qual[lab->cnt].date = format(c.event_end_dt_tm,"mm/dd/yy hh:mm;;d")
   IF ((lab->qual[lab->cnt].val > " "))
    lab->qual[lab->cnt].val = concat(trim(lab->qual[lab->cnt].date),"  ",trim(lab->qual[lab->cnt].
      label),": ",trim(lab->qual[lab->cnt].val))
   ENDIF
  WITH nocounter, outerjoin = d, dontcare = cv2
 ;end select
 SELECT INTO "nl:"
  d.seq
  FROM (dummyt d  WITH seq = 1)
  PLAN (d)
  DETAIL
   lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat
   (rhead,wr,"ADMISSION LAB WORK",reol)
   IF ((lab->cnt > 0))
    FOR (x = 1 TO lab->cnt)
      lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line =
      concat(wr,trim(lab->qual[x].val),reol)
    ENDFOR
   ELSE
    lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line =
    concat(wr,"No Lab Work Done on Admit Date",reol)
   ENDIF
   lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = reol
  FOOT REPORT
   FOR (z = 1 TO lidx)
     reply->text = concat(reply->text,drec->line_qual[z].disp_line)
   ENDFOR
  WITH nocounter, maxcol = 132, maxrow = 500
 ;end select
 SET reply->text = concat(reply->text,rtfeof)
END GO
