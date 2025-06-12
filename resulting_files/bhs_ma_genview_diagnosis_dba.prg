CREATE PROGRAM bhs_ma_genview_diagnosis:dba
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
 SET getnum = fillstring(20," ")
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
 SET person_cnt = 1
 FOR (x = 1 TO person_cnt)
   SELECT INTO "nl"
    d.diagnosis_id
    FROM diagnosis d,
     (dummyt d1  WITH seq = 1),
     nomenclature n
    PLAN (d
     WHERE (d.encntr_id=request->visit[x].encntr_id)
      AND d.active_ind=1
      AND d.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND ((d.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)) OR (d.end_effective_dt_tm=null
     )) )
     JOIN (d1)
     JOIN (n
     WHERE n.nomenclature_id=d.nomenclature_id)
    ORDER BY d.active_status_dt_tm DESC
    HEAD REPORT
     lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx), temp_disp1 = "Diagnosis:",
     drec->line_qual[lidx].disp_line = concat(rhead,rh2bu,trim(temp_disp1),reol,wr), ";;T"
    DETAIL
     temp_disp1 = fillstring(200," "), temp_disp2 = fillstring(200," "), temp_disp5 = fillstring(200,
      " "),
     temp_disp6 = fillstring(200," "), status = fillstring(40," ")
     IF (((n.source_string > " ") OR (d.diagnosis_display > " ")) )
      row + 1, lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx),
      temp_disp1 = substring(1,40,d.diagnosis_display)
      IF (n.source_string > " ")
       temp_disp1 = n.source_string
      ENDIF
      status = uar_get_code_display(d.diag_type_cd), temp_disp3 = "Diagnosed: ", temp_disp4 = format(
       d.diag_dt_tm,"mm/dd/yyyy;;d"),
      drec->line_qual[lidx].disp_line = concat("        ",trim(temp_disp1)," (",trim(temp_disp3),trim
       (temp_disp4),
       ")   ",trim(status),reol), ";;T"
     ENDIF
    FOOT REPORT
     FOR (x = 1 TO lidx)
      reply->text = concat(reply->text,drec->line_qual[x].disp_line)";;T"
     ENDFOR
    WITH nocounter, outerjoin = d1, dontcare = n,
     dontcare = r, outerjoin = d2, dontcare = n2
   ;end select
 ENDFOR
 IF (curqual=0)
  SET lidx = (lidx+ 1)
  SET stat = alterlist(drec->line_qual,lidx)
  SET temp_disp1 = "Diagnoses:"
  SET drec->line_qual[lidx].disp_line = concat(rhead,rh2bu,trim(temp_disp1),reol,wr)
  SET lidx = (lidx+ 1)
  SET stat = alterlist(drec->line_qual,lidx)
  SET temp_disp = "         NO KNOWN DIAGNOSIS"
  SET drec->line_qual[lidx].disp_line = concat(wb,trim(temp_disp),reol)
  FOR (x = 1 TO lidx)
    SET reply->text = concat(reply->text,drec->line_qual[x].disp_line)
  ENDFOR
 ENDIF
 SET reply->status_data.status = "S"
 SET reply->text = concat(reply->text,rtfeof)
END GO
