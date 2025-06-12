CREATE PROGRAM admitdiag:dba
 IF (validate(reply->text,"-1")="-1")
  FREE RECORD reply
  RECORD reply(
    1 text = vc
    1 format = i4
  ) WITH protect
 ENDIF
 FREE RECORD a_diag
 RECORD a_diag(
   1 l_cnt = i4
   1 list[*]
     2 f_diag_id = f8
     2 s_diag_name = vc
 ) WITH protect
 DECLARE ml_admit_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17,"ADMIT"))
 DECLARE s_text = vc WITH protect, noconstant("")
 DECLARE l_idx = i4 WITH protect, noconstant(0)
 SELECT DISTINCT INTO "nl:"
  dx.encntr_id, n.source_string
  FROM diagnosis dx,
   nomenclature n
  PLAN (dx
   WHERE (dx.person_id=request->person_id)
    AND (dx.encntr_id=request->encntr_id)
    AND dx.diag_type_cd=ml_admit_cd
    AND dx.active_ind=1
    AND dx.end_effective_dt_tm > sysdate)
   JOIN (n
   WHERE n.nomenclature_id=dx.nomenclature_id
    AND n.active_ind=1)
  HEAD REPORT
   a_diag->l_cnt = 0
  DETAIL
   a_diag->l_cnt = (a_diag->l_cnt+ 1), stat = alterlist(a_diag->list,a_diag->l_cnt), a_diag->list[
   a_diag->l_cnt].f_diag_id = dx.diagnosis_id,
   a_diag->list[a_diag->l_cnt].s_diag_name = n.source_string
  WITH nocounter
 ;end select
 SET s_text = concat("<html><body><table border=0 cellspacing=0 cellpadding=0 width=100%>",
  ^<tr><td><p style='font-family: "Arial", "sans-serif"; font-size: 12pt'>^)
 IF ((a_diag->l_cnt > 0))
  FOR (l_idx = 1 TO a_diag->l_cnt)
    IF ((l_idx=a_diag->l_cnt))
     SET s_text = concat(s_text," ",a_diag->list[l_idx].s_diag_name)
    ELSE
     SET s_text = concat(s_text," ",a_diag->list[l_idx].s_diag_name,";")
    ENDIF
  ENDFOR
 ENDIF
 SET s_text = concat(s_text,"</p></td></tr></table></body></html>")
 SET reply->text = s_text
 SET reply->format = 1
 CALL echorecord(reply)
 FREE RECORD a_diag
#exit_script
END GO
