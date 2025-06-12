CREATE PROGRAM dcp_get_genview_clindemogs:dba
 SET mode_cd = 22616
 SET o2_cd = 22499
 SET ivther_cd = 22430
 SET act_cd = 147681
 SET pg_cd = 147542
 SET elim_cd = 22385
 SET diet_cd = 22370
 SET ino_cd = 147550
 SET rest_cd = 147553
 SET spec_cd = 22603
 SET bun_cd = 36840
 SET na_cd = 22204
 SET gluc_cd = 22220
 SET cr_cd = 22218
 SET k_cd = 22205
 SET hgb_cd = 22223
 SET hct_cd = 22224
 SET rhead =
 "{\rtf1\ansi \deff0{\fonttbl{\f0\fswissArial;}}{\colortbl;\red0\green0\blue0;\red255\green255\blue255;}\deftab1134"
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
 SET temp_disp2 = fillstring(200," ")
 SET temp_disp5 = fillstring(200," ")
 SET temp_disp6 = fillstring(200," ")
 RECORD temp(
   1 mode = vc
   1 o2 = vc
   1 ivther = vc
   1 act = vc
   1 pg = vc
   1 elim = vc
   1 diet = vc
   1 iando = vc
   1 fluidrx = vc
   1 special = vc
   1 bun = vc
   1 na = vc
   1 glucose = vc
   1 cr = vc
   1 k = vc
   1 hgb = vc
   1 hct = vc
 )
 RECORD drec(
   1 line_cnt = i4
   1 display_line = vc
   1 line_qual[*]
     2 disp_line = vc
 )
 SET visit_cnt = 1
 FOR (x = 1 TO visit_cnt)
  SELECT INTO "nl"
   c.clinical_event_id, c.event_cd, c.event_end_dt_tm
   FROM clinical_event c
   PLAN (c
    WHERE (c.encntr_id=request->visit[x].encntr_id)
     AND c.view_level=1
     AND c.publish_flag=1
     AND c.event_cd IN (mode_cd, o2_cd, ivther_cd, act_cd, pg_cd,
    elim_cd, diet_cd, ino_cd, rest_cd, spec_cd,
    bun_cd, na_cd, gluc_cd, cr_cd, k_cd,
    hgb_cd, hct_cd)
     AND c.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00"))
   ORDER BY c.event_cd, c.event_end_dt_tm DESC
   HEAD c.event_cd
    IF (c.event_cd=mode_cd)
     temp->mode = c.event_tag
    ELSEIF (c.event_cd=o2_cd)
     temp->o2 = c.event_tag
    ELSEIF (c.event_cd=ivther_cd)
     temp->ivther = c.event_tag
    ELSEIF (c.event_cd=act_cd)
     temp->act = c.event_tag
    ELSEIF (c.event_cd=pg_cd)
     temp->pg = c.event_tag
    ELSEIF (c.event_cd=elim_cd)
     temp->elim = c.event_tag
    ELSEIF (c.event_cd=diet_cd)
     temp->diet = c.event_tag
    ELSEIF (c.event_cd=ino_cd)
     temp->iando = c.event_tag
    ELSEIF (c.event_cd=rest_cd)
     temp->fluidrx = c.event_tag
    ELSEIF (c.event_cd=spec_cd)
     temp->special = c.event_tag
    ELSEIF (c.event_cd=bun_cd)
     temp->bun = c.event_tag
    ELSEIF (c.event_cd=na_cd)
     temp->na = c.event_tag
    ELSEIF (c.event_cd=gluc_cd)
     temp->glucose = c.event_tag
    ELSEIF (c.event_cd=cr_cd)
     temp->cr = c.event_tag
    ELSEIF (c.event_cd=k_cd)
     temp->k = c.event_tag
    ELSEIF (c.event_cd=hgb_cd)
     temp->hgb = c.event_tag
    ELSEIF (c.event_cd=hct_cd)
     temp->hct = c.event_tag
    ENDIF
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = 1)
   PLAN (d)
   DETAIL
    lidx = (lidx+ 1), row + 1, stat = alterlist(drec->line_qual,lidx),
    drec->line_qual[lidx].disp_line = concat(rhead,rh2bu,"PATIENT DATA",reol,wr), lidx = (lidx+ 1),
    row + 1,
    stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
     "        Mode of Transport:  ",trim(temp->mode),reol), lidx = (lidx+ 1),
    row + 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
     "        O2:  ",trim(temp->o2),reol),
    lidx = (lidx+ 1), row + 1, stat = alterlist(drec->line_qual,lidx),
    drec->line_qual[lidx].disp_line = concat("        IV Therapy:  ",trim(temp->ivther),reol), lidx
     = (lidx+ 1), row + 1,
    stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
     "        Activity:  ",trim(temp->act),reol), lidx = (lidx+ 1),
    row + 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
     "        Pregnant:  ",trim(temp->pg),reol),
    lidx = (lidx+ 1), row + 1, stat = alterlist(drec->line_qual,lidx),
    drec->line_qual[lidx].disp_line = concat("        Elimination:  ",trim(temp->elim),reol), lidx =
    (lidx+ 1), row + 1,
    stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
     "        Diet:  ",trim(temp->diet),reol), lidx = (lidx+ 1),
    row + 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
     "        I&O:  ",trim(temp->iando),reol),
    lidx = (lidx+ 1), row + 1, stat = alterlist(drec->line_qual,lidx),
    drec->line_qual[lidx].disp_line = concat("        Restrictions:  ",trim(temp->fluidrx),reol),
    lidx = (lidx+ 1), row + 1,
    stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
     "        Special Needs:  ",trim(temp->special),reol), lidx = (lidx+ 1),
    row + 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = reol,
    lidx = (lidx+ 1), row + 1, stat = alterlist(drec->line_qual,lidx),
    drec->line_qual[lidx].disp_line = concat(rh2bu,"DAILY LAB",reol,wr), lidx = (lidx+ 1), row + 1,
    stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat("        BUN:  ",
     trim(temp->bun),reol), lidx = (lidx+ 1),
    row + 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
     "        Na:  ",trim(temp->na),reol),
    lidx = (lidx+ 1), row + 1, stat = alterlist(drec->line_qual,lidx),
    drec->line_qual[lidx].disp_line = concat("        Glucose:  ",trim(temp->glucose),reol), lidx = (
    lidx+ 1), row + 1,
    stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat("        Cr:  ",
     trim(temp->cr),reol), lidx = (lidx+ 1),
    row + 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
     "        K:  ",trim(temp->k),reol),
    lidx = (lidx+ 1), row + 1, stat = alterlist(drec->line_qual,lidx),
    drec->line_qual[lidx].disp_line = concat("        Hgb:  ",trim(temp->hgb),reol), lidx = (lidx+ 1),
    row + 1,
    stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat("        Hct:  ",
     trim(temp->hct),reol)
   FOOT REPORT
    FOR (x = 1 TO lidx)
      reply->text = concat(reply->text,drec->line_qual[x].disp_line)
    ENDFOR
   WITH nocounter, maxcol = 500, maxrow = 800
  ;end select
 ENDFOR
 SET reply->status_data.status = "S"
 SET reply->text = concat(reply->text,rtfeof)
END GO
