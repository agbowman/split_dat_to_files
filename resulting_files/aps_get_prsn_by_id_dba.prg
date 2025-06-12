CREATE PROGRAM aps_get_prsn_by_id:dba
 DECLARE mrn_var = f8 WITH constant(uar_get_code_by("MEANING",319,"MRN")), protect
 DECLARE fin_var = f8 WITH constant(uar_get_code_by("MEANING",319,"FIN NBR")), protect
 DECLARE cmrn_var = f8 WITH constant(uar_get_code_by("MEANING",4,"CMRN")), protect
 DECLARE name_type_cd = f8 WITH constant(uar_get_code_by("MEANING",213,"PRSNL")), protect
 DECLARE cnt = i4 WITH protect
 DECLARE pos = i4 WITH protect
 DECLARE x = i4 WITH protect
 RECORD reply(
   1 qual[*]
     2 person_id = f8
     2 encntr_id = f8
     2 persn_typ = vc
     2 name_first = vc
     2 name_middle = vc
     2 name_last = vc
     2 name_full = vc
     2 gender = vc
     2 dob = vc
     2 prsn_mrn = vc
     2 user_name = vc
     2 gender_cd = f8
     2 prsn_fin = vc
     2 prsn_cmrn = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET cnt = size(request->qual,5)
 SET reply->status_data.status = "F"
 SELECT INTO "nl"
  p.name_first, p.name_last, p.person_id,
  p1.name_middle
  FROM prsnl p,
   person_name p1,
   (dummyt d  WITH seq = value(cnt))
  PLAN (d)
   JOIN (p
   WHERE (p.person_id=request->qual[d.seq].person_id)
    AND trim(request->qual[d.seq].persn_typ)="PRSNL"
    AND (request->qual[d.seq].person_id != 0.0))
   JOIN (p1
   WHERE (p1.person_id= Outerjoin(p.person_id))
    AND (p1.name_type_cd= Outerjoin(name_type_cd))
    AND (p1.active_ind= Outerjoin(1))
    AND (p1.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(sysdate)))
    AND (p1.end_effective_dt_tm>= Outerjoin(cnvtdatetime(sysdate))) )
  ORDER BY p.person_id
  HEAD REPORT
   x = 0
  DETAIL
   x += 1, stat = alterlist(reply->qual,x), reply->qual[x].person_id = p.person_id,
   reply->qual[x].name_first = p.name_first, reply->qual[x].name_last = p.name_last, reply->qual[x].
   name_middle = p1.name_middle,
   reply->qual[x].name_full = p.name_full_formatted, reply->qual[x].user_name = p.username, reply->
   qual[x].persn_typ = "PRSNL"
  WITH nocounter
 ;end select
 SELECT INTO "nl"
  p_sex_disp = uar_get_code_display(p.sex_cd), pa.alias
  FROM encounter e,
   person p,
   person_alias pa,
   (dummyt d  WITH seq = value(cnt))
  PLAN (d)
   JOIN (e
   WHERE (e.encntr_id=request->qual[d.seq].encntr_id)
    AND trim(request->qual[d.seq].persn_typ)="PERSON"
    AND (request->qual[d.seq].encntr_id != 0.0))
   JOIN (p
   WHERE e.person_id=p.person_id)
   JOIN (pa
   WHERE (pa.person_id= Outerjoin(p.person_id))
    AND (pa.person_alias_type_cd= Outerjoin(cmrn_var))
    AND (pa.active_ind= Outerjoin(1)) )
  ORDER BY e.encntr_id
  HEAD e.encntr_id
   x += 1, stat = alterlist(reply->qual,x), reply->qual[x].person_id = p.person_id,
   reply->qual[x].persn_typ = "PERSON", reply->qual[x].encntr_id = e.encntr_id, reply->qual[x].
   name_first = p.name_first,
   reply->qual[x].name_middle = p.name_middle, reply->qual[x].name_last = p.name_last, reply->qual[x]
   .name_full = p.name_full_formatted,
   reply->qual[x].dob = datetimezoneformat(p.birth_dt_tm,p.birth_tz,"yyyyMMddHHmmss"), reply->qual[x]
   .gender = p_sex_disp, reply->qual[x].gender_cd = p.sex_cd,
   reply->qual[x].prsn_cmrn = pa.alias
  WITH nocounter
 ;end select
 SET cnt = size(reply->qual,5)
 IF (cnt > 0)
  SELECT INTO "nl"
   ea.alias
   FROM encntr_alias ea,
    (dummyt d  WITH seq = value(cnt))
   PLAN (d
    WHERE (reply->qual[d.seq].encntr_id != 0))
    JOIN (ea
    WHERE (ea.encntr_id=reply->qual[d.seq].encntr_id)
     AND ea.encntr_alias_type_cd IN (fin_var, mrn_var)
     AND ea.active_ind=1)
   DETAIL
    IF (ea.encntr_alias_type_cd=fin_var)
     reply->qual[d.seq].prsn_fin = ea.alias
    ELSE
     reply->qual[d.seq].prsn_mrn = ea.alias
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
