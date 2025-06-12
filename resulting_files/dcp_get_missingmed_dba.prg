CREATE PROGRAM dcp_get_missingmed:dba
 SET rhead =
 "{\rtf1\ansi \deff0{\fonttbl{\f0\fswiss Arial;}}{\colortbl;\red0\green0\blue0;\red255\green255\blue255;}\deftab1134"
 SET rh2r = "\plain \f0 \fs18 \cb2 \pard\sl0 "
 SET rh2b = "\plain \f0 \fs18 \b \cb2 \pard\sl0 "
 SET rh2bu = "\plain \f0 \fs18 \b \ul \cb2 \pard\sl0 "
 SET rh2u = "\plain \f0 \fs18 \u \cb2 \pard\sl0 "
 SET rh2i = "\plain \f0 \fs18 \i \cb2 \pard\sl0 "
 SET reol = "\par "
 SET rtab = "\tab "
 SET wr = " \plain \f0 \fs18 \cb2 "
 SET wb = " \plain \f0 \fs18 \b \cb2 "
 SET wu = " \plain \f0 \fs18 \ul \cb2 "
 SET wi = " \plain \f0 \fs18 \i \cb2 "
 SET wbi = " \plain \f0 \fs18 \b \i \cb2 "
 SET wiu = " \plain \f0 \fs18 \i \ul \cb2 "
 SET wbiu = " \plain \f0 \fs18 \b \ul \i \cb2 "
 SET rtfeof = "}"
 SET lidx = 0
 SET temp_disp1 = fillstring(200," ")
 SET a = fillstring(15," ")
 RECORD drec(
   1 line_cnt = i4
   1 display_line = vc
   1 line_qual[*]
     2 disp_line = vc
 )
 SELECT INTO "nl:"
  d.seq
  FROM (dummyt d  WITH seq = 1)
  PLAN (d)
  HEAD REPORT
   lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx), temp_disp1 = "Missing Med Notification",
   drec->line_qual[lidx].disp_line = concat(rhead,rh2bu,trim(temp_disp1),reol,wr)
  DETAIL
   lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = reol,
   lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat
   (wr,"   Patient Name :___________________________",reol,wr),
   lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat
   (wr,"             Number :__________________________",reol),
   lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat
   (wr,"         Room/Bed :__________________________",reol),
   lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat
   (wr,"   Medication Missing :______________________________",reol),
   lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat
   (wr,"   Ordered Information :_____________________________",reol),
   lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat
   (wr,"   Next Dose Due Time :_____________________________",reol),
   lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat
   (wr,"   Phone Number for Questions :______________________",reol)
  FOOT REPORT
   FOR (z = 1 TO lidx)
     reply->text = concat(reply->text,drec->line_qual[z].disp_line)
   ENDFOR
  WITH nocounter, maxcol = 132, maxrow = 500
 ;end select
 SET reply->text = concat(reply->text,rtfeof)
END GO
