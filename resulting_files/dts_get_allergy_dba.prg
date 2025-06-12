CREATE PROGRAM dts_get_allergy:dba
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
 SET temp_disp2 = fillstring(200," ")
 SET temp_disp5 = fillstring(200," ")
 SET temp_disp6 = fillstring(200," ")
 SET code_value = 0.0
 SET code_set = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET canceled_cd = 0
 SET code_set = 12025
 SET cdf_meaning = "CANCELED"
 EXECUTE cpm_get_cd_for_cdf
 SET canceled_cd = code_value
 RECORD drec(
   1 line_cnt = i4
   1 display_line = vc
   1 line_qual[*]
     2 disp_line = vc
 )
 SET person_cnt = 1
 FOR (x = 1 TO person_cnt)
   SELECT INTO "nl"
    a.allergy_id, n.nomenclature_id, r.reaction_id,
    n2.nomenclature_id
    FROM allergy a,
     (dummyt d1  WITH seq = 1),
     nomenclature n,
     (dummyt d2  WITH seq = 1),
     reaction r,
     (dummyt d3  WITH seq = 1),
     nomenclature n2
    PLAN (a
     WHERE (a.person_id=request->person[x].person_id)
      AND a.active_ind=1
      AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND ((a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)) OR (a.end_effective_dt_tm=null
     ))
      AND a.reaction_status_cd != canceled_cd)
     JOIN (d1)
     JOIN (n
     WHERE n.nomenclature_id=a.substance_nom_id)
    ORDER BY a.onset_dt_tm
    HEAD REPORT
     lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx), temp_disp1 = "ALLERGIES",
     drec->line_qual[lidx].disp_line = concat(rhead,wr,trim(temp_disp1),reol,wr), ";;T"
    DETAIL
     temp_disp1 = fillstring(200," "), temp_disp2 = fillstring(200," "), temp_disp5 = fillstring(200,
      " "),
     temp_disp6 = fillstring(200," ")
     IF (((n.source_string > " ") OR (a.substance_ftdesc > " "))
      AND a.onset_dt_tm != null)
      row + 1, lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx),
      temp_disp1 = a.substance_ftdesc
      IF (n.source_string > " ")
       temp_disp1 = n.source_string
      ENDIF
      temp_disp2 = fillstring(27," ")
     ENDIF
    FOOT REPORT
     FOR (x = 1 TO lidx)
      reply->text = concat(reply->text,drec->line_qual[x].disp_line)";;T"
     ENDFOR
    WITH nocounter, outerjoin(n)
   ;end select
 ENDFOR
 IF (curqual=0)
  SET lidx = (lidx+ 1)
  SET stat = alterlist(drec->line_qual,lidx)
  SET temp_disp1 = "ALLERGIES"
  SET drec->line_qual[lidx].disp_line = concat(rhead,wr,trim(temp_disp1),reol,wr)
  SET lidx = (lidx+ 1)
  SET stat = alterlist(drec->line_qual,lidx)
  SET temp_disp = "         "
  SET drec->line_qual[lidx].disp_line = concat(wb,trim(temp_disp),reol)
  FOR (x = 1 TO lidx)
    SET reply->text = concat(reply->text,drec->line_qual[x].disp_line)
  ENDFOR
 ENDIF
 SET reply->text = concat(reply->text,rtfeof)
END GO
