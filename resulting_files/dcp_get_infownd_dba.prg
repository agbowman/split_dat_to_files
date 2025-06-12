CREATE PROGRAM dcp_get_infownd:dba
 RECORD reply(
   1 name_full_formatted = vc
   1 diagqual_cnt = i4
   1 diagqual[*]
     2 diag_dt_tm = dq8
     2 diag_prsnl_name = vc
     2 diag_ftdesc = vc
     2 diag_type_cd = f8
     2 diag_type_disp = vc
     2 source_identifier = vc
   1 alqual_cnt = i4
   1 alqual[*]
     2 substance_ftdesc = vc
     2 onset_dt_tm = dq8
     2 reaction_status_cd = f8
     2 reaction_class_cd = f8
     2 reaction_class_disp = vc
     2 severity_cd = f8
     2 severity_disp = vc
   1 updt_dt_tm = dq8
   1 lookup_status = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET modify = predeclare
 SET reply->status_data.status = "F"
 DECLARE diag_cnt = i2 WITH noconstant(0)
 DECLARE al_cnt = i2 WITH noconstant(0)
 DECLARE temp_cnt = i2 WITH noconstant(0)
 DECLARE cancel_cd = f8 WITH noconstant(0.0)
 DECLARE x = i2 WITH noconstant(0)
 DECLARE stat = i2 WITH noconstant(0)
 SET cancel_cd = uar_get_code_by("MEANING",12025,"CANCELED")
 CALL echo(build("cancel_cd:",cancel_cd))
 SELECT INTO "nl:"
  FROM diagnosis d,
   (dummyt d1  WITH seq = 1),
   person p,
   (dummyt d2  WITH seq = 1),
   nomenclature n
  PLAN (d
   WHERE (d.person_id=request->person_id)
    AND d.active_ind=1
    AND d.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ((d.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)) OR (d.end_effective_dt_tm=null)) )
   JOIN (d1)
   JOIN (p
   WHERE p.person_id=d.diag_prsnl_id)
   JOIN (d2)
   JOIN (n
   WHERE n.nomenclature_id=d.nomenclature_id)
  ORDER BY d.diag_dt_tm
  HEAD REPORT
   diag_cnt = 0, stat = alterlist(reply->diagqual,5)
  DETAIL
   diag_cnt = (diag_cnt+ 1)
   IF (diag_cnt > size(reply->diagqual,5))
    stat = alterlist(reply->diagqual,(diag_cnt+ 10))
   ENDIF
   reply->diagqual[diag_cnt].diag_ftdesc = d.diag_ftdesc
   IF (trim(n.source_string) > "")
    reply->diagqual[diag_cnt].diag_ftdesc = n.source_string
   ENDIF
   reply->diagqual[diag_cnt].source_identifier = n.source_identifier, reply->diagqual[diag_cnt].
   diag_dt_tm = d.diag_dt_tm, reply->diagqual[diag_cnt].diag_type_cd = d.diag_type_cd
   IF (trim(d.diag_prsnl_name) > " ")
    reply->diagqual[diag_cnt].diag_prsnl_name = d.diag_prsnl_name
   ELSE
    reply->diagqual[diag_cnt].diag_prsnl_name = p.name_full_formatted
   ENDIF
  FOOT REPORT
   reply->diagqual_cnt = diag_cnt
  WITH nocounter, outerjoin = d1, dontcare = p,
   dontcare = n
 ;end select
 SELECT INTO "nl"
  FROM allergy a,
   nomenclature n,
   (dummyt d2  WITH seq = 1),
   reaction r,
   nomenclature n2
  PLAN (a
   WHERE (a.person_id=request->person_id)
    AND a.reaction_status_cd != cancel_cd
    AND a.active_ind=1
    AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ((a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)) OR (a.end_effective_dt_tm=null)) )
   JOIN (n
   WHERE n.nomenclature_id=a.substance_nom_id)
   JOIN (d2)
   JOIN (r
   WHERE a.allergy_id=r.allergy_id
    AND r.active_ind=1
    AND r.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    AND r.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (n2
   WHERE n2.nomenclature_id=r.reaction_nom_id)
  ORDER BY a.onset_dt_tm
  HEAD REPORT
   al_cnt = 0, stat = alterlist(reply->alqual,5)
  HEAD a.allergy_id
   al_cnt = (al_cnt+ 1)
   IF (al_cnt > size(reply->alqual,5))
    stat = alterlist(reply->alqual,(al_cnt+ 10))
   ENDIF
   reply->alqual[al_cnt].substance_ftdesc = a.substance_ftdesc
   IF (n.source_string > " ")
    reply->alqual[al_cnt].substance_ftdesc = n.source_string
   ENDIF
   reply->alqual[al_cnt].onset_dt_tm = a.onset_dt_tm, reply->alqual[al_cnt].reaction_status_cd = a
   .reaction_status_cd, reply->alqual[al_cnt].severity_cd = a.severity_cd,
   reaction_cnt = 0
  DETAIL
   IF (textlen(trim(r.reaction_ftdesc)) > 0)
    reply->alqual[al_cnt].reaction_class_disp = concat(reply->alqual[al_cnt].reaction_class_disp,", ",
     r.reaction_ftdesc), reaction_cnt = (reaction_cnt+ 1)
   ENDIF
   IF (textlen(trim(n2.source_string)) > 0)
    reply->alqual[al_cnt].reaction_class_disp = concat(reply->alqual[al_cnt].reaction_class_disp,", ",
     n2.source_string), reaction_cnt = (reaction_cnt+ 1)
   ENDIF
  FOOT  a.allergy_id
   IF (reaction_cnt > 0)
    reply->alqual[al_cnt].reaction_class_disp = substring(3,textlen(reply->alqual[al_cnt].
      reaction_class_disp),reply->alqual[al_cnt].reaction_class_disp)
   ENDIF
  FOOT REPORT
   reply->alqual_cnt = al_cnt
  WITH nocounter, outerjoin = d2
 ;end select
 SELECT INTO "nl"
  FROM person p
  WHERE (p.person_id=request->person_id)
  HEAD REPORT
   x = 0
  DETAIL
   reply->name_full_formatted = p.name_full_formatted
  WITH nocounter
 ;end select
#exit_script
 IF (diag_cnt > 0)
  SET stat = alterlist(reply->diagqual,diag_cnt)
 ENDIF
 IF (al_cnt > 0)
  SET stat = alterlist(reply->alqual,al_cnt)
 ENDIF
 SET temp_cnt = (diag_cnt+ al_cnt)
 IF (temp_cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 FOR (x = 1 TO reply->alqual_cnt)
   CALL echo(build("************allergies**********"))
   CALL echo(build("substance_disp:",reply->alqual[x].substance_ftdesc))
   CALL echo(build("onset_dt_tm:",reply->alqual[x].onset_dt_tm))
   CALL echo(build("react_class:",reply->alqual[x].reaction_class_cd))
   CALL echo(build("severity_cd:",reply->alqual[x].severity_cd))
   CALL echo(build("reaction_status_cd:",reply->alqual[x].reaction_status_cd))
 ENDFOR
END GO
