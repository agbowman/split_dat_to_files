CREATE PROGRAM dcp_get_pl_lifetime_reltn:dba
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE arg_nbr = i4 WITH noconstant(cnvtint(size(request->arguments,5)))
 DECLARE counter = i4 WITH noconstant(1)
 DECLARE lifetime_cd = vc WITH noconstant(fillstring(1000," "))
 DECLARE prsnl_id = f8 WITH noconstant(0.0)
 DECLARE ppr_where = vc WITH noconstant(fillstring(1000," "))
 DECLARE lifetime_ind = i2 WITH noconstant(0)
 FOR (counter = 1 TO arg_nbr)
   CASE (request->arguments[counter].argument_name)
    OF "lifetime_reltn_cd":
     SET lifetime_cd = concat(lifetime_cd,cnvtstring(request->arguments[counter].parent_entity_id),
      ",")
     SET lifetime_ind = 1
    OF "prsnl_id":
     SET prsnl_id = cnvtreal(request->arguments[counter].parent_entity_id)
   ENDCASE
 ENDFOR
 IF (lifetime_ind=1)
  SET lifetime_cd = substring(1,(size(lifetime_cd,1) - 1),lifetime_cd)
  SET ppr_where = concat("ppr.prsnl_person_id = prsnl_id"," and ppr.person_prsnl_r_cd in (",
   lifetime_cd,") and ppr.active_ind = 1",
   " and ppr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)",
   " and ppr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)")
 ELSE
  SET ppr_where = concat("ppr.prsnl_person_id = prsnl_id"," and ppr.active_ind = 1",
   " and ppr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)",
   " and ppr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)")
 ENDIF
 SELECT INTO "nl:"
  FROM person_prsnl_reltn ppr,
   person p,
   dcp_pl_prioritization pr
  PLAN (ppr
   WHERE parser(trim(ppr_where)))
   JOIN (p
   WHERE p.person_id=ppr.person_id
    AND p.active_ind=1)
   JOIN (pr
   WHERE outerjoin(p.person_id)=pr.person_id
    AND pr.patient_list_id=outerjoin(request->patient_list_id))
  ORDER BY p.person_id
  HEAD p.person_id
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->patients,(cnt+ 9))
   ENDIF
   reply->patients[cnt].person_id = p.person_id, reply->patients[cnt].person_name = p
   .name_full_formatted, reply->patients[cnt].encntr_id = 0,
   reply->patients[cnt].priority = pr.priority
   IF (ppr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    reply->patients[cnt].active_ind = 1
   ELSE
    reply->patients[cnt].active_ind = 0
   ENDIF
  FOOT REPORT
   p.person_id, stat = alterlist(reply->patients,cnt)
  WITH nocounter
 ;end select
 IF (cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
