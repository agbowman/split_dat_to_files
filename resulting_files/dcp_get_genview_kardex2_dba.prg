CREATE PROGRAM dcp_get_genview_kardex2:dba
 SET rhead =
 "{\rtf1\ansi \deff0{\fonttbl{\f0\fswiss Arial;}}{\colortbl;\red0\green0\blue0;\red255\green255\blue255;}\deftab1134"
 SET rh2r = "\plain \f0 \fs18 \cb2 \pard\sl0 "
 SET rh2b = "\plain \f0 \fs18 \b \cb2 \pard\sl0 "
 SET rh2bu = "\plain \f0 \fs18 \b \ul \cb2 \pard\sl0 "
 SET rh2u = "\plain \f0 \fs18 \u \cb2 \pard\sl0 "
 SET rh2i = "\plain \f0 \fs18 \i \cb2 \pard\sl0 "
 SET reol = "\par"
 SET rtab = "\tab"
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
 SET temp_disp2 = fillstring(200," ")
 SET temp_disp5 = fillstring(200," ")
 SET temp_disp6 = fillstring(200," ")
 SET a = fillstring(15," ")
 SET code_value = 0.0
 SET code_set = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET code_set = 6004
 SET cdf_meaning = "PENDING REV"
 EXECUTE cpm_get_cd_for_cdf
 SET pendingrev_cd = code_value
 SET code_set = 6004
 SET cdf_meaning = "ORDERED"
 EXECUTE cpm_get_cd_for_cdf
 SET ordered_cd = code_value
 SET code_set = 6004
 SET cdf_meaning = "INPROCESS"
 EXECUTE cpm_get_cd_for_cdf
 SET inprocess_cd = code_value
 RECORD drec(
   1 line_cnt = i4
   1 display_line = vc
   1 line_qual[*]
     2 disp_line = vc
 )
 RECORD temp(
   1 order_mnemonic = vc
   1 order_details = vc
   1 v[5]
     2 dt = vc
     2 t = vc
     2 p = vc
     2 r = vc
     2 s = vc
     2 d = vc
 )
 SET visit_cnt = 1
 FOR (x = 1 TO visit_cnt)
   SET temp->order_mnemonic = "Vital Signs"
   SET temp->order_details = "No active order found."
   SELECT INTO "nl:"
    o.order_id
    FROM orders o
    PLAN (o
     WHERE (o.encntr_id=request->visit[x].encntr_id)
      AND o.catalog_cd IN (429135, 5640215)
      AND o.order_status_cd IN (ordered_cd, pendingrev_cd, inprocess_cd))
    ORDER BY o.order_id DESC
    HEAD o.order_id
     temp->order_mnemonic = o.order_mnemonic, temp->order_details = o.clinical_display_line
    DETAIL
     row + 0
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    c.event_cd, c.event_end_dt_tm
    FROM clinical_event c
    PLAN (c
     WHERE (c.encntr_id=request->visit[x].encntr_id)
      AND c.view_level=1
      AND c.publish_flag=1
      AND c.event_cd IN (5645091, 5645092, 5645093, 5645094)
      AND c.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00"))
    ORDER BY c.event_end_dt_tm DESC
    HEAD REPORT
     vidx = 0
    HEAD c.event_end_dt_tm
     vidx = (vidx+ 1)
    DETAIL
     IF (vidx < 5)
      temp->v[vidx].dt = format(c.event_end_dt_tm,"mm/dd/yy hh:mm;;d")
      IF (c.event_cd=5645091)
       temp->v[vidx].t = trim(c.event_tag)
      ELSEIF (c.event_cd=5645092)
       temp->v[vidx].p = trim(c.event_tag)
      ELSEIF (c.event_cd=139213)
       temp->v[vidx].r = trim(c.event_tag)
      ELSEIF (c.event_cd=5645093)
       temp->v[vidx].s = trim(c.event_tag)
      ELSEIF (c.event_cd=5645094)
       temp->v[vidx].d = trim(c.event_tag)
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    d.seq
    FROM (dummyt d  WITH seq = 1)
    PLAN (d)
    HEAD REPORT
     lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx), temp_disp1 = "Vital Signs:",
     drec->line_qual[lidx].disp_line = concat(rhead,rh2bu,trim(temp_disp1),reol,wr), lidx = (lidx+ 1),
     stat = alterlist(drec->line_qual,lidx),
     drec->line_qual[lidx].disp_line = concat(wr,"Active Order: ",trim(temp->order_mnemonic),"   ",
      trim(temp->order_details))
    DETAIL
     lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = reol
     FOR (y = 1 TO 5)
       lidx = (lidx+ 1), row + 1, stat = alterlist(drec->line_qual,lidx),
       drec->line_qual[lidx].disp_line = concat(wr,trim(temp->v[y].dt),"           T:  ",trim(temp->
         v[y].t),rtab,
        "   P:  ",trim(temp->v[y].p),rtab,"   R:  ",trim(temp->v[y].r),
        rtab,"   BP:  ",trim(temp->v[y].s)," / ",trim(temp->v[y].d),
        reol)
     ENDFOR
    FOOT REPORT
     FOR (z = 1 TO lidx)
       reply->text = concat(reply->text,drec->line_qual[z].disp_line)
     ENDFOR
    WITH nocounter, maxcol = 500, maxrow = 500
   ;end select
 ENDFOR
 SET reply->status_data.status = "S"
 SET reply->text = concat(reply->text,rtfeof)
END GO
