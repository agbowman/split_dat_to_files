CREATE PROGRAM dcp_get_genview_kardex1:dba
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
 RECORD temp(
   1 living_will = vc
   1 power_of_attorney = vc
   1 organ_donor = vc
   1 mobility = vc
   1 assistive_devices = vc
   1 prosthetic_devices = vc
   1 sensory_deficits = vc
   1 falls_risk_score = vc
   1 skin_integrity_score = vc
   1 nutritional_risk_score = vc
   1 bun = vc
   1 na = vc
   1 glucose = vc
   1 cr = vc
   1 k = vc
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
     AND c.event_cd IN (22438, 806086, 22482, 290055, 290058,
    22524, 22593, 442341, 788876, 788879,
    29130, 22204, 22220, 22218, 222205)
     AND c.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00"))
   ORDER BY c.event_cd, c.event_end_dt_tm DESC
   HEAD c.event_cd
    IF (c.event_cd=22438)
     temp->living_will = c.event_tag
    ELSEIF (c.event_cd=806086)
     temp->power_of_attorney = c.event_tag
    ELSEIF (c.event_cd=22482)
     temp->organ_donor = c.event_tag
    ELSEIF (c.event_cd=290055)
     temp->mobility = c.event_tag
    ELSEIF (c.event_cd=290058)
     temp->assistive_devices = c.event_tag
    ELSEIF (c.event_cd=22524)
     temp->prosthetic_devices = c.event_tag
    ELSEIF (c.event_cd=22593)
     temp->sensory_deficits = c.event_tag
    ELSEIF (c.event_cd=442341)
     temp->falls_risk_score = c.event_tag
    ELSEIF (c.event_cd=788876)
     temp->skin_integrity_score = c.event_tag
    ELSEIF (c.event_cd=788879)
     temp->nutritional_risk_score = c.event_tag
    ELSEIF (c.event_cd=29130)
     temp->bun = c.event_tag
    ELSEIF (c.event_cd=22204)
     temp->na = c.event_tag
    ELSEIF (c.event_cd=22220)
     temp->glucose = c.event_tag
    ELSEIF (c.event_cd=22218)
     temp->cr = c.event_tag
    ELSEIF (c.event_cd=22205)
     temp->k = c.event_tag
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = 1)
   PLAN (d)
   DETAIL
    lidx = (lidx+ 1), row + 1, stat = alterlist(drec->line_qual,lidx),
    drec->line_qual[lidx].disp_line = concat(rhead,rh2bu,"PATIENT DATA",reol,wr), lidx = (lidx+ 1),
    row + 1,
    stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = reol, lidx = (lidx+ 1),
    row + 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
     "        Living Will:  ",trim(temp->living_will),reol),
    lidx = (lidx+ 1), row + 1, stat = alterlist(drec->line_qual,lidx),
    drec->line_qual[lidx].disp_line = reol, lidx = (lidx+ 1), row + 1,
    stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
     "        Power of Attorney:  ",trim(temp->power_of_attorney),reol), lidx = (lidx+ 1),
    row + 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = reol,
    lidx = (lidx+ 1), row + 1, stat = alterlist(drec->line_qual,lidx),
    drec->line_qual[lidx].disp_line = concat("        Organ Donor:  ",trim(temp->organ_donor),reol),
    lidx = (lidx+ 1), row + 1,
    stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = reol, lidx = (lidx+ 1),
    row + 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
     "        Mobility:  ",trim(temp->mobility),reol),
    lidx = (lidx+ 1), row + 1, stat = alterlist(drec->line_qual,lidx),
    drec->line_qual[lidx].disp_line = reol, lidx = (lidx+ 1), row + 1,
    stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
     "        Assistive Devices:  ",trim(temp->assistive_devices),reol), lidx = (lidx+ 1),
    row + 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = reol,
    lidx = (lidx+ 1), row + 1, stat = alterlist(drec->line_qual,lidx),
    drec->line_qual[lidx].disp_line = concat("        Prosthetic Devices:  ",trim(temp->
      prosthetic_devices),reol), lidx = (lidx+ 1), row + 1,
    stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = reol, lidx = (lidx+ 1),
    row + 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
     "        Sensory Deficits:  ",trim(temp->sensory_deficits),reol),
    lidx = (lidx+ 1), row + 1, stat = alterlist(drec->line_qual,lidx),
    drec->line_qual[lidx].disp_line = reol, lidx = (lidx+ 1), row + 1,
    stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
     "        Falls Risk Score:  ",trim(temp->falls_risk_score),reol), lidx = (lidx+ 1),
    row + 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = reol,
    lidx = (lidx+ 1), row + 1, stat = alterlist(drec->line_qual,lidx),
    drec->line_qual[lidx].disp_line = concat("        Skin Integrity Score:  ",trim(temp->
      skin_integrity_score),reol), lidx = (lidx+ 1), row + 1,
    stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = reol, lidx = (lidx+ 1),
    row + 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
     "        Nutritional Risk Score:  ",trim(temp->nutritional_risk_score),reol),
    lidx = (lidx+ 1), row + 1, stat = alterlist(drec->line_qual,lidx),
    drec->line_qual[lidx].disp_line = reol, lidx = (lidx+ 1), row + 1,
    stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = reol, lidx = (lidx+ 1),
    row + 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(rh2bu,
     "DAILY LAB",reol,wr),
    lidx = (lidx+ 1), row + 1, stat = alterlist(drec->line_qual,lidx),
    drec->line_qual[lidx].disp_line = reol, lidx = (lidx+ 1), row + 1,
    stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat("        BUN:  ",
     trim(temp->bun),reol), lidx = (lidx+ 1),
    row + 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = reol,
    lidx = (lidx+ 1), row + 1, stat = alterlist(drec->line_qual,lidx),
    drec->line_qual[lidx].disp_line = concat("        Na:  ",trim(temp->na),reol), lidx = (lidx+ 1),
    row + 1,
    stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = reol, lidx = (lidx+ 1),
    row + 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
     "        Glucose:  ",trim(temp->glucose),reol),
    lidx = (lidx+ 1), row + 1, stat = alterlist(drec->line_qual,lidx),
    drec->line_qual[lidx].disp_line = reol, lidx = (lidx+ 1), row + 1,
    stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat("        Cr:  ",
     trim(temp->cr),reol), lidx = (lidx+ 1),
    row + 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = reol,
    lidx = (lidx+ 1), row + 1, stat = alterlist(drec->line_qual,lidx),
    drec->line_qual[lidx].disp_line = concat("        K:  ",trim(temp->k),reol), lidx = (lidx+ 1),
    row + 1,
    stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = reol
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
