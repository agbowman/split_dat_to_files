CREATE PROGRAM dts_get_procedure:dba
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
 RECORD proc(
   1 cnt = i2
   1 qual[*]
     2 line = vc
 )
 SET lidx = 0
 SELECT INTO "nl:"
  FROM procedure p,
   (dummyt d1  WITH seq = 1),
   nomenclature n
  PLAN (p
   WHERE (p.encntr_id=request->visit[1].encntr_id)
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ((p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)) OR (p.end_effective_dt_tm=null)) )
   JOIN (d1)
   JOIN (n
   WHERE n.nomenclature_id=p.nomenclature_id)
  ORDER BY cnvtdatetime(p.proc_dt_tm)
  HEAD REPORT
   proc->cnt = 0
  DETAIL
   IF (((n.source_string > " ") OR (p.proc_ftdesc > " ")) )
    proc->cnt = (proc->cnt+ 1), stat = alterlist(proc->qual,proc->cnt), proc->qual[proc->cnt].line =
    p.proc_ftdesc
    IF (n.source_string > " ")
     proc->qual[proc->cnt].line = n.source_string
    ENDIF
   ENDIF
  WITH nocounter, outerjoin = d1, dontcare = n
 ;end select
 SELECT INTO "nl:"
  d.seq
  FROM (dummyt d  WITH seq = 1)
  PLAN (d)
  DETAIL
   lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat
   (wbu,"Procedure Summary",reol)
   IF ((proc->cnt > 0))
    FOR (x = 1 TO proc->cnt)
      lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line =
      concat(wr,trim(proc->qual[x].line),reol)
    ENDFOR
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
