CREATE PROGRAM dcp_get_genview_kardex4:dba
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
 RECORD drec(
   1 line_cnt = i4
   1 display_line = vc
   1 line_qual[*]
     2 disp_line = vc
 )
 RECORD temp(
   1 allergies = vc
   1 code = vc
 )
 SET temp->allergies = "N"
 SET person_cnt = 1
 FOR (x = 1 TO person_cnt)
   SELECT INTO "nl:"
    a.allergy_id
    FROM allergy a
    PLAN (a
     WHERE (a.person_id=request->person[x].person_id)
      AND a.active_ind=1
      AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND ((a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)) OR (a.end_effective_dt_tm=null
     )) )
    DETAIL
     temp->allergies = "Y"
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    c.event_code, c.event_end_dt_tm
    FROM clinical_event c
    PLAN (c
     WHERE (c.person_id=request->person[x].person_id)
      AND c.view_level=1
      AND c.publish_flag=1
      AND c.event_cd=139178
      AND c.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00"))
    ORDER BY c.event_cd, c.event_end_dt_tm
    DETAIL
     temp->code = c.event_tag
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    d.seq
    FROM (dummyt d  WITH seq = 1)
    PLAN (d)
    DETAIL
     lidx = (lidx+ 1), row + 1, stat = alterlist(drec->line_qual,lidx),
     drec->line_qual[lidx].disp_line = concat(rhead,rh2bu,"Code Status: ",trim(temp->code),reol,
      wr), lidx = (lidx+ 1), row + 1,
     stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = reol, lidx = (lidx+ 1),
     row + 1, stat = alterlist(drec->line_qual,lidx)
     IF ((temp->allergies="Y"))
      drec->line_qual[lidx].disp_line = concat(wiu,"ALLERGIES",reol,wr), lidx = (lidx+ 1), row + 1,
      stat = alterlist(drec->line_qual,lidx)
     ELSE
      drec->line_qual[lidx].disp_line = concat(wb,"NKA",reol,wr)
     ENDIF
    FOOT REPORT
     FOR (x = 1 TO lidx)
       reply->text = concat(reply->text,drec->line_qual[x].disp_line)
     ENDFOR
    WITH nocounter, maxcol = 500, maxrow = 500
   ;end select
 ENDFOR
 SET reply->status_data.status = "S"
 SET reply->text = concat(reply->text,rtfeof)
END GO
