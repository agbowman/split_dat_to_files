CREATE PROGRAM dts_get_meds:dba
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
 RECORD ord(
   1 cnt = i2
   1 qual[*]
     2 type = vc
     2 line = vc
 )
 SET lidx = 0
 SET code_value = 0.0
 SET code_set = 0.0
 SET code_set = 6004
 SET cdf_meaning = "ORDERED"
 EXECUTE cpm_get_cd_for_cdf
 SET ordered_cd = code_value
 SET code_set = 6004
 SET cdf_meaning = "INPROCESS"
 EXECUTE cpm_get_cd_for_cdf
 SET inprocess_cd = code_value
 SELECT INTO "nl:"
  FROM orders o,
   order_detail od
  PLAN (o
   WHERE (o.encntr_id=request->visit[1].encntr_id)
    AND o.order_status_cd IN (ordered_cd, inprocess_cd)
    AND o.catalog_type_cd=583)
   JOIN (od
   WHERE o.order_id=od.order_id
    AND od.oe_field_id=330478)
  ORDER BY cnvtdatetime(o.current_start_dt_tm)
  HEAD REPORT
   ord->cnt = 0
  HEAD o.order_id
   ord->cnt = (ord->cnt+ 1), stat = alterlist(ord->qual,ord->cnt), ord->qual[ord->cnt].type = o
   .order_mnemonic,
   ord->qual[ord->cnt].line = o.clinical_display_line, ord->qual[ord->cnt].line = concat(trim(ord->
     qual[ord->cnt].type)," - ",trim(ord->qual[ord->cnt].line))
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  d.seq
  FROM (dummyt d  WITH seq = 1)
  PLAN (d)
  DETAIL
   lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat
   (rhead,wr,"DISCHARGE MEDICATIONS",reol)
   IF ((ord->cnt > 0))
    FOR (x = 1 TO ord->cnt)
      lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line =
      concat(wr,trim(ord->qual[x].line),reol)
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
