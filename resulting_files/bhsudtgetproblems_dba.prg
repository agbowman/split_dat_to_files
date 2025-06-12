CREATE PROGRAM bhsudtgetproblems:dba
 DECLARE mn_debug_flag = i4 WITH protect, constant(validate(bhs_debug_flag,0))
 DECLARE ms_table_row_b = vc WITH protect, constant("<td><p><span>")
 DECLARE ms_table_row_e = vc WITH protect, constant("</span></p></td>")
 DECLARE mf_sensitive_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",12033,"SENSITIVE"))
 DECLARE mf_active_life_cycle_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",12030,
   "ACTIVE"))
 DECLARE mf_snmct_cd = f8 WITH public, constant(uar_get_code_by("MEANING",400,"SNMCT"))
 DECLARE mf_icd9_cd = f8 WITH public, constant(uar_get_code_by("MEANING",400,"ICD9"))
 DECLARE mf_imo_cd = f8 WITH public, constant(uar_get_code_by("MEANING",400,"IMO"))
 DECLARE ms_text = vc WITH protect, noconstant(" ")
 DECLARE cnt = i4 WITH protect, noconstant(0)
 IF (validate(reply->text)=0)
  FREE RECORD reply
  RECORD reply(
    1 text = vc
    1 format = i4
  )
 ENDIF
 FREE RECORD probs
 RECORD probs(
   1 prob[*]
     2 beg_effective_dt_tm = vc
     2 text = vc
 )
 IF (mn_debug_flag >= 1)
  CALL echo("Start of script bhs_udt_get_problems")
 ENDIF
 SELECT INTO "nl:"
  FROM problem p,
   nomenclature n
  PLAN (p
   WHERE (p.person_id=request->person_id)
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ((p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)) OR (p.end_effective_dt_tm=null))
    AND p.classification_cd != mf_sensitive_cd
    AND p.life_cycle_status_cd=mf_active_life_cycle_cd
    AND p.data_status_cd=25)
   JOIN (n
   WHERE n.nomenclature_id=outerjoin(p.nomenclature_id)
    AND n.source_vocabulary_cd IN (mf_snmct_cd, mf_icd9_cd, mf_imo_cd))
  ORDER BY p.person_id, cnvtdatetime(p.onset_dt_tm) DESC
  HEAD p.person_id
   cnt = 0, stat = alterlist(probs->prob,10)
  DETAIL
   IF (((n.source_string > " ") OR (p.problem_ftdesc > " ")) )
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=1)
     stat = alterlist(probs->prob,(cnt+ 10))
    ENDIF
    IF (p.nomenclature_id > 0)
     probs->prob[cnt].text = n.source_string
    ELSE
     probs->prob[cnt].text = p.problem_ftdesc
    ENDIF
    probs->prob[cnt].beg_effective_dt_tm = substring(1,14,format(p.beg_effective_dt_tm,
      "@SHORTDATE;;Q"))
   ENDIF
  FOOT REPORT
   stat = alterlist(probs->prob,cnt)
  WITH nocounter
 ;end select
 IF (mn_debug_flag >= 8)
  CALL echo("Echoing the populated problem list")
  CALL echorecord(probs)
 ENDIF
 SET ms_text = concat("<html><body><table border=0 cellspacing=0 cellpadding=0>",
  "<tr><td valign=top><p><b>","<span>","Problem","</span></b></p></td></tr>")
 IF (size(probs->prob,5) > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(size(probs->prob,5)))
   DETAIL
    ms_text = concat(ms_text,"<tr>"), ms_text = concat(ms_text,ms_table_row_b,probs->prob[d.seq].text,
     ms_table_row_e), ms_text = concat(ms_text,"</tr>")
   WITH nocounter
  ;end select
 ENDIF
 SET ms_text = concat(ms_text,"</table></body></html>")
 SET reply->text = ms_text
 SET reply->format = 1
 IF (mn_debug_flag >= 5)
  CALL echo(build("reply->text:",reply->text))
 ENDIF
#exit_script
 IF (mn_debug_flag >= 4)
  CALL echorecord(reply)
 ENDIF
 FREE RECORD probs
 IF (mn_debug_flag >= 1)
  CALL echo("End of script bhs_udt_get_problems")
 ENDIF
END GO
