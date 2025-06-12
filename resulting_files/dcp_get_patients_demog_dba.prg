CREATE PROGRAM dcp_get_patients_demog:dba
 SET modify = predeclare
 RECORD reply(
   1 qual[*]
     2 person_id = f8
     2 name_full_formatted = vc
     2 age = vc
     2 ssn = vc
     2 name_last = vc
     2 name_first = vc
     2 mrn = vc
     2 fin = vc
     2 birth_dt_tm = dq8
     2 birth_prec_flag = i2
     2 enctr_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE last_mod = c3 WITH private, noconstant("")
 DECLARE mod_date = c10 WITH private, noconstant("")
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE person_cnt = i4 WITH protect, noconstant(0)
 DECLARE req_person_cnt = i4 WITH protect, noconstant(size(request->persons,5))
 DECLARE cssn = f8 WITH constant(uar_get_code_by("MEANING",4,"SSN"))
 DECLARE cmrn = f8 WITH constant(uar_get_code_by("MEANING",4,"MRN"))
 DECLARE cfin = f8 WITH constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE cviewssnpriv = f8 WITH constant(uar_get_code_by("MEANING",6016,"VIEWSSN"))
 DECLARE isprivgranted = i2 WITH protect, noconstant(0)
 DECLARE cviewssnyes = f8 WITH constant(uar_get_code_by("MEANING",6017,"YES"))
 DECLARE checkviewssnpriv(null) = null
 SET reply->status_data.status = "F"
 SET stat = alterlist(reply->qual,req_person_cnt)
 CALL checkviewssnpriv(null)
 SELECT INTO "n1:"
  FROM (dummyt d1  WITH seq = value(req_person_cnt)),
   person p,
   (left JOIN person_alias pa ON pa.person_id=p.person_id
    AND pa.person_alias_type_cd IN (cssn, cmrn)
    AND pa.active_ind=1),
   (left JOIN encounter e ON e.person_id=p.person_id
    AND (request->persons[d1.seq].enctr_id > 0.0)),
   (left JOIN encntr_alias ea ON ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=cfin
    AND (request->persons[d1.seq].enctr_id > 0.0)
    AND (ea.encntr_id=request->persons[d1.seq].enctr_id))
  PLAN (d1)
   JOIN (p
   WHERE (p.person_id=request->persons[d1.seq].person_id)
    AND p.active_ind=1)
   JOIN (pa)
   JOIN (e)
   JOIN (ea)
  HEAD d1.seq
   reply->qual[d1.seq].person_id = p.person_id, reply->qual[d1.seq].name_full_formatted = p
   .name_full_formatted
   IF (p.deceased_dt_tm=null)
    reply->qual[d1.seq].age = cnvtage(cnvtdate2(format(p.birth_dt_tm,"mm/dd/yyyy;;d"),"mm/dd/yyyy"),
     cnvtint(format(p.birth_dt_tm,"hhmm;;m")))
   ELSE
    reply->qual[d1.seq].age = cnvtage(cnvtdate2(format(p.birth_dt_tm,"mm/dd/yyyy;;d"),"mm/dd/yyyy"),
     cnvtint(format(p.birth_dt_tm,"hhmm;;m")),cnvtdate2(format(p.deceased_dt_tm,"mm/dd/yyyy;;d"),
      "mm/dd/yyyy"),cnvtint(format(p.deceased_dt_tm,"hhmm;;m")))
   ENDIF
   reply->qual[d1.seq].name_first = p.name_first, reply->qual[d1.seq].name_last = p.name_last, reply
   ->qual[d1.seq].birth_dt_tm = cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p.birth_tz),1),
   reply->qual[d1.seq].birth_prec_flag = validate(p.birth_prec_flag,null)
   IF ((request->persons[d1.seq].enctr_id > 0.0))
    reply->qual[d1.seq].fin = cnvtalias(ea.alias,ea.alias_pool_cd), reply->qual[d1.seq].enctr_id =
    request->persons[d1.seq].enctr_id
   ENDIF
  DETAIL
   IF (pa.person_alias_type_cd=cssn)
    IF (isprivgranted != 0)
     reply->qual[d1.seq].ssn = cnvtalias(pa.alias,pa.alias_pool_cd)
    ELSE
     reply->qual[d1.seq].ssn = ""
    ENDIF
   ELSEIF (pa.person_alias_type_cd=cmrn)
    reply->qual[d1.seq].mrn = cnvtalias(pa.alias,pa.alias_pool_cd)
   ENDIF
  WITH nocounter
 ;end select
 SUBROUTINE checkviewssnpriv(null)
  SELECT INTO "nl:"
   FROM priv_loc_reltn pl,
    privilege p
   PLAN (pl
    WHERE (((pl.position_cd=reqinfo->position_cd)) OR ((pl.person_id=reqinfo->updt_id))) )
    JOIN (p
    WHERE p.priv_loc_reltn_id=pl.priv_loc_reltn_id
     AND p.privilege_cd=cviewssnpriv
     AND p.priv_value_cd=cviewssnyes)
   ORDER BY p.privilege_cd
   HEAD p.privilege_cd
    isprivgranted = 1
   WITH nocounter
  ;end select
  IF (isprivgranted=0)
   SELECT INTO "nl:"
    FROM priv_loc_reltn pl,
     privilege p,
     person_prsnl_reltn r
    PLAN (r
     WHERE (r.prsnl_person_id=reqinfo->updt_id)
      AND r.active_ind=1)
     JOIN (pl
     WHERE pl.ppr_cd=r.person_prsnl_r_cd)
     JOIN (p
     WHERE p.priv_loc_reltn_id=pl.priv_loc_reltn_id
      AND p.privilege_cd=cviewssnpriv
      AND p.priv_value_cd=cviewssnyes)
    ORDER BY p.privilege_cd
    HEAD p.privilege_cd
     isprivgranted = 1
    WITH nocounter
   ;end select
  ENDIF
 END ;Subroutine
 SET errcode = error(errmsg,1)
 IF (errcode > 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus.operationname = errmsg
 ELSEIF (size(reply->qual,5) > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echo(build("result=",size(reply->qual,5)))
 SET last_mod = "004"
 SET mod_date = "04/18/2014"
 SET modify = nopredeclare
END GO
