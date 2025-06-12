CREATE PROGRAM cp_get_prsnl_name_by_id:dba
 FREE RECORD reply
 RECORD reply(
   1 name_full = vc
   1 name_first = vc
   1 name_last = vc
   1 name_middle = vc
   1 name_title = vc
   1 found_name = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET prsnl_type_cd = 0.0
 SET current_type_cd = 0.0
 SET code_set = 213
 SET cdf_meaning = fillstring(12," ")
 SET code_value = 0.0
 SET cdf_meaning = "PRSNL"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,code_value)
 SET prsnl_type_cd = code_value
 SELECT INTO "nl:"
  pn.person_id, pn.name_type_cd, pn.name_full,
  name_type = uar_get_code_description(pn.name_type_cd)
  FROM person_name pn
  WHERE (pn.person_id=request->person_id)
   AND pn.active_ind=1
   AND pn.name_type_cd IN (prsnl_type_cd)
  HEAD REPORT
   do_nothing = 0
  HEAD pn.person_id
   reply->name_full = pn.name_full, reply->name_first = pn.name_first, reply->name_last = pn
   .name_last,
   reply->name_middle = pn.name_middle, reply->name_title = pn.name_title
   IF ((((reply->name_last > " ")) OR ((((reply->name_first > " ")) OR ((reply->name_full > " ")))
   )) )
    reply->found_name = 1
   ELSE
    reply->found_name = 0
   ENDIF
  DETAIL
   do_nothing = 0
  WITH nocounter, maxrec = 1
 ;end select
 IF ((reply->found_name=0))
  SELECT INTO "nl:"
   p.person_id, p.name_full_formatted
   FROM prsnl p
   WHERE (p.person_id=request->person_id)
    AND p.active_ind=1
   HEAD REPORT
    do_nothing = 1
   DETAIL
    reply->name_full = p.name_full_formatted, reply->name_first = p.name_first, reply->name_last = p
    .name_last,
    reply->name_middle = " ", reply->name_title = " "
    IF ((((reply->name_last > " ")) OR ((((reply->name_first > " ")) OR ((reply->name_full > " ")))
    )) )
     reply->found_name = 1
    ELSE
     reply->found_name = 0
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF ((reply->found_name=1))
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
