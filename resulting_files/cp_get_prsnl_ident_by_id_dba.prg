CREATE PROGRAM cp_get_prsnl_ident_by_id:dba
 RECORD reply(
   1 name_full = vc
   1 name_initials = vc
   1 name_first = vc
   1 name_last = vc
   1 name_middle = vc
   1 name_title = vc
   1 username = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE name_type_cd = f8
 IF ((request->person_flag=0))
  SET stat = uar_get_meaning_by_codeset(213,"PRSNL",1,name_type_cd)
 ELSE
  SET stat = uar_get_meaning_by_codeset(213,"CURRENT",1,name_type_cd)
 ENDIF
 SET reply->status_data.status = "F"
 SET errmsg = fillstring(132," ")
 SELECT
  IF ((request->person_flag=0))
   FROM prsnl p,
    person_name pn
   PLAN (p
    WHERE (p.person_id=request->person_id))
    JOIN (pn
    WHERE pn.person_id=outerjoin(p.person_id)
     AND pn.name_type_cd=outerjoin(name_type_cd))
  ELSE
   FROM person p,
    person_name pn
   PLAN (p
    WHERE (p.person_id=request->person_id))
    JOIN (pn
    WHERE pn.person_id=outerjoin(p.person_id)
     AND pn.name_type_cd=outerjoin(name_type_cd))
  ENDIF
  INTO "nl:"
  ORDER BY pn.end_effective_dt_tm DESC, pn.active_ind DESC
  HEAD REPORT
   first_name = 1
  DETAIL
   IF (first_name)
    reply->name_full = p.name_full_formatted, reply->name_first = p.name_first, reply->name_last = p
    .name_last
    IF ((request->person_flag=0))
     reply->name_middle = pn.name_middle, reply->username = validate(p.username,"")
    ELSE
     reply->name_middle = validate(p.name_middle,"")
    ENDIF
    reply->name_initials = pn.name_initials, reply->name_title = pn.name_title, first_name = 0
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET errorcode = error(errmsg,0)
  IF (errorcode != 0)
   SET reply->status_data.status = "F"
   SET reply->status_data.operationname = "SELECT"
   SET reply->status_data.operationstatus = "F"
   SET reply->status_data.targetobjectname = "ErrorMessage"
   SET reply->status_data.targetobjectvalue = errmsg
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
