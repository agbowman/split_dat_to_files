CREATE PROGRAM cps_get_plan_info:dba
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 RECORD reply(
   1 health_plan_qual = i4
   1 health_plan[*]
     2 health_plan_id = f8
     2 plan_name = vc
     2 plan_desc = vc
     2 plan_type_cd = f8
     2 plan_type_disp = c40
     2 group_name = vc
     2 policy_nbr = vc
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 org_name = vc
     2 organization_id = f8
     2 sponsor_group_nbr = vc
     2 person_plan_reltn_qual = i4
     2 person_plan_reltn[*]
       3 person_plan_ind = i2
       3 encntr_id = f8
       3 person_plan_reltn_id = f8
       3 person_plan_r_cd = f8
       3 person_plan_r_disp = vc
       3 priority_seq = i4
       3 member_nbr = vc
     2 hp_financial_qual = i4
     2 hp_financial[*]
       3 copay = i4
       3 deductible = i4
     2 hp_alias_qual = i4
     2 hp_alias[*]
       3 alias = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET hp_count = 0
 SET e_count = 0
 SET code_value = 0
 SET cd_for_sponsor = 0
 SET code_set = 370
 SET cdf_meaning = "SPONSOR"
 EXECUTE cpm_get_cd_for_cdf
 SET cd_for_sponsor = code_value
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM encounter e,
   encntr_plan_reltn epr,
   health_plan h
  PLAN (e
   WHERE (e.person_id=request->person_id))
   JOIN (epr
   WHERE epr.encntr_id=e.encntr_id
    AND epr.active_ind=1
    AND epr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND epr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (h
   WHERE h.health_plan_id=epr.health_plan_id)
  ORDER BY h.health_plan_id, epr.priority_seq
  HEAD REPORT
   e_count = 0, stat = alterlist(reply->health_plan,10)
  HEAD h.health_plan_id
   e_count = (e_count+ 1)
   IF (mod(e_count,10)=1
    AND e_count != 1)
    stat = alterlist(reply->health_plan,(e_count+ 9))
   ENDIF
   reply->health_plan[e_count].health_plan_id = h.health_plan_id, reply->health_plan[e_count].
   plan_name = h.plan_name, reply->health_plan[e_count].plan_desc = h.plan_desc,
   reply->health_plan[e_count].plan_type_cd = h.plan_type_cd, reply->health_plan[e_count].group_name
    = h.group_name, reply->health_plan[e_count].policy_nbr = h.policy_nbr,
   reply->health_plan[e_count].beg_effective_dt_tm = cnvtdatetime(h.beg_effective_dt_tm), reply->
   health_plan[e_count].end_effective_dt_tm = cnvtdatetime(h.end_effective_dt_tm), knt = 0,
   stat = alterlist(reply->health_plan[e_count].person_plan_reltn,10)
  DETAIL
   knt = (knt+ 1)
   IF (mod(knt,10)=1
    AND knt != 1)
    stat = alterlist(reply->health_plan[e_count].person_plan_reltn,(knt+ 9))
   ENDIF
   reply->health_plan[e_count].person_plan_reltn[knt].encntr_id = epr.encntr_id, reply->health_plan[
   e_count].person_plan_reltn[knt].person_plan_reltn_id = epr.person_plan_reltn_id, reply->
   health_plan[e_count].person_plan_reltn[knt].priority_seq = epr.priority_seq,
   reply->health_plan[e_count].person_plan_reltn[knt].member_nbr = epr.member_nbr
  FOOT  h.health_plan_id
   reply->health_plan[e_count].person_plan_reltn_qual = knt, stat = alterlist(reply->health_plan[
    e_count].person_plan_reltn,knt)
  FOOT REPORT
   reply->health_plan_qual = e_count, stat = alterlist(reply->health_plan,e_count)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "ENCNTR_PLAN_RELTN"
  GO TO exit_script
 ENDIF
 IF ((reply->health_plan_qual < 1))
  GO TO skip_check
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(reply->health_plan_qual)),
   person_plan_reltn s
  PLAN (d
   WHERE d.seq > 0)
   JOIN (s
   WHERE (s.person_id=request->person_id)
    AND s.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND s.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND s.active_ind=1
    AND ((s.health_plan_id+ 0)=reply->health_plan[d.seq].health_plan_id))
  DETAIL
   FOR (i = 1 TO reply->health_plan[d.seq].person_plan_reltn_qual)
     reply->health_plan[d.seq].person_plan_reltn[i].person_plan_ind = true
   ENDFOR
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "PERSON_PLAN_CHECK"
  GO TO exit_script
 ENDIF
#skip_check
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM health_plan h,
   person_plan_reltn s,
   (dummyt d  WITH seq = value(reply->health_plan_qual)),
   (dummyt d1  WITH seq = 1)
  PLAN (s
   WHERE (s.person_id=request->person_id)
    AND s.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND s.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND s.active_ind=1)
   JOIN (h
   WHERE h.health_plan_id=s.health_plan_id)
   JOIN (d1)
   JOIN (d
   WHERE d.seq > 0
    AND (h.health_plan_id=reply->health_plan[d.seq].health_plan_id))
  ORDER BY s.health_plan_id, s.priority_seq
  HEAD REPORT
   hp_count = e_count, stat = alterlist(reply->health_plan,(hp_count+ 9))
  HEAD h.health_plan_id
   hp_count = (hp_count+ 1)
   IF (mod(hp_count,10)=1
    AND hp_count != 1)
    stat = alterlist(reply->health_plan,(hp_count+ 9))
   ENDIF
   reply->health_plan[hp_count].health_plan_id = h.health_plan_id, reply->health_plan[hp_count].
   plan_name = h.plan_name, reply->health_plan[hp_count].plan_desc = h.plan_desc,
   reply->health_plan[hp_count].plan_type_cd = h.plan_type_cd, reply->health_plan[hp_count].
   group_name = h.group_name, reply->health_plan[hp_count].policy_nbr = h.policy_nbr,
   reply->health_plan[hp_count].beg_effective_dt_tm = cnvtdatetime(h.beg_effective_dt_tm), reply->
   health_plan[hp_count].end_effective_dt_tm = cnvtdatetime(h.end_effective_dt_tm), knt = 0,
   stat = alterlist(reply->health_plan[hp_count].person_plan_reltn,10)
  DETAIL
   knt = (knt+ 1)
   IF (mod(knt,10)=1
    AND knt != 1)
    stat = alterlist(reply->health_plan[hp_count].person_plan_reltn,(knt+ 9))
   ENDIF
   reply->health_plan[hp_count].person_plan_reltn[knt].person_plan_ind = true, reply->health_plan[
   hp_count].person_plan_reltn[knt].person_plan_reltn_id = s.person_plan_reltn_id, reply->
   health_plan[hp_count].person_plan_reltn[knt].person_plan_r_cd = s.person_plan_r_cd,
   reply->health_plan[hp_count].person_plan_reltn[knt].priority_seq = s.priority_seq, reply->
   health_plan[hp_count].person_plan_reltn[knt].member_nbr = s.member_nbr
  FOOT  h.health_plan_id
   reply->health_plan[hp_count].person_plan_reltn_qual = knt, stat = alterlist(reply->health_plan[
    hp_count].person_plan_reltn,knt)
  FOOT REPORT
   reply->health_plan_qual = hp_count, stat = alterlist(reply->health_plan,hp_count)
  WITH nocounter, outerjoin = d1, dontexist
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "PERSON_PLAN_RELTN"
  GO TO exit_script
 ENDIF
 IF ((reply->health_plan_qual > 0))
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  SELECT INTO "nl:"
   d.seq, opr.beg_effective_dt_tm
   FROM org_plan_reltn opr,
    organization o,
    (dummyt d  WITH seq = value(reply->health_plan_qual))
   PLAN (d
    WHERE d.seq > 0)
    JOIN (opr
    WHERE (opr.health_plan_id=reply->health_plan[d.seq].health_plan_id)
     AND opr.org_plan_reltn_cd=cd_for_sponsor
     AND opr.active_ind=1)
    JOIN (o
    WHERE o.organization_id=opr.organization_id)
   ORDER BY d.seq, opr.beg_effective_dt_tm DESC
   HEAD d.seq
    reply->health_plan[d.seq].org_name = o.org_name, reply->health_plan[d.seq].organization_id = o
    .organization_id, reply->health_plan[d.seq].sponsor_group_nbr = opr.group_nbr
   WITH nocounter
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = select_error
   SET table_name = "ORG_PLAN_RELTN"
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((reply->health_plan_qual > 0))
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  SELECT INTO "nl:"
   d.seq
   FROM health_plan_alias a,
    (dummyt d  WITH seq = value(reply->health_plan_qual))
   PLAN (d
    WHERE d.seq > 0)
    JOIN (a
    WHERE (a.health_plan_id=reply->health_plan[d.seq].health_plan_id)
     AND a.active_ind=1
     AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   HEAD d.seq
    knt = 0, stat = alterlist(reply->health_plan[d.seq].hp_alias,10)
   DETAIL
    knt = (knt+ 1)
    IF (mod(knt,10)=1
     AND knt != 1)
     stat = alterlist(reply->health_plan[d.seq].hp_alias,(knt+ 9))
    ENDIF
    reply->health_plan[d.seq].hp_alias[knt].alias = a.alias
   FOOT  d.seq
    reply->health_plan[d.seq].hp_alias_qual = knt, stat = alterlist(reply->health_plan[d.seq].
     hp_alias,knt)
   WITH nocounter
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = select_error
   SET table_name = "HEALTH_PLAN_ALIAS"
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((reply->health_plan_qual > 0))
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  SELECT INTO "nl:"
   d.seq
   FROM hp_financial f,
    (dummyt d  WITH seq = value(reply->health_plan_qual))
   PLAN (d
    WHERE d.seq > 0)
    JOIN (f
    WHERE (f.health_plan_id=reply->health_plan[d.seq].health_plan_id)
     AND f.active_ind=1)
   HEAD d.seq
    knt = 0, stat = alterlist(reply->health_plan[d.seq].hp_financial,10)
   DETAIL
    knt = (knt+ 1)
    IF (mod(knt,10)=1
     AND knt != 1)
     stat = alterlist(reply->health_plan[d.seq].hp_financial,(knt+ 9))
    ENDIF
    reply->health_plan[d.seq].hp_financial[knt].copay = f.copay, reply->health_plan[d.seq].
    hp_financial[knt].deductible = f.deductible
   FOOT  d.seq
    reply->health_plan[d.seq].hp_financial_qual = knt, stat = alterlist(reply->health_plan[d.seq].
     hp_financial,knt)
   WITH nocounter
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = select_error
   SET table_name = "HP_FINANCIAL"
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 IF (failed != false)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  IF (failed=select_error)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSEIF (failed=insert_error)
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSEIF (failed=input_error)
   SET reply->status_data.subeventstatus[1].operationname = "VALIDATION"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSE
   SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ENDIF
 ELSEIF ((reply->health_plan_qual > 0))
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 SET script_version = "009 05/01/01 SF3151"
END GO
