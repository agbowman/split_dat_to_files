CREATE PROGRAM cps_get_prsnl_by_name:dba
 RECORD context(
   1 person_id = f8
   1 person_max = i4
 )
 RECORD reply(
   1 prsnl_qual = i4
   1 prsnl[*]
     2 person_id = f8
     2 name_last = vc
     2 name_first = vc
     2 name_full_formatted = vc
     2 email = vc
     2 username = vc
     2 prsnl_type_cd = f8
     2 position_cd = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 updt_cnt = i4
     2 name_middle = vc
     2 name_suffix = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->prsnl_qual = 0
 SET stat = alterlist(reply->prsnl,10)
 SET reply->status_data.status = "F"
 SET count1 = 0
 IF ((request->exact_ind > 0))
  GO TO get_exact
 ENDIF
 IF ((request->person_max <= 0)
  AND (context->person_max > 0))
  SET request->person_max = context->person_max
 ENDIF
 SELECT
  IF ((context->person_id > 0))
   PLAN (n
    WHERE (n.person_id > context->person_id)
     AND n.active_ind=1
     AND n.username != null
     AND n.username > " "
     AND n.name_last_key=patstring(cnvtupper(request->person_name))
     AND n.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND n.end_effective_dt_tm >= cnvtdatetime(sysdate))
    JOIN (p
    WHERE p.person_id=n.person_id)
    JOIN (d
    WHERE d.seq=1)
    JOIN (p2
    WHERE p2.person_id=p.person_id)
  ELSE
   PLAN (n
    WHERE n.person_id > 0
     AND n.active_ind=1
     AND n.username != null
     AND n.username > " "
     AND n.name_last_key=patstring(cnvtupper(request->person_name))
     AND n.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND n.end_effective_dt_tm >= cnvtdatetime(sysdate))
    JOIN (p
    WHERE p.person_id=n.person_id)
    JOIN (d
    WHERE d.seq=1)
    JOIN (p2
    WHERE p2.person_id=p.person_id)
  ENDIF
  DISTINCT INTO "nl:"
  n.person_id
  FROM prsnl n,
   person p,
   (dummyt d  WITH seq = 1),
   person_name p2
  HEAD REPORT
   count1 = 0
  HEAD n.person_id
   count1 += 1
   IF (size(reply->prsnl,5) <= count1)
    stat = alterlist(reply->prsnl,(count1+ 10))
   ENDIF
   reply->prsnl[count1].person_id = n.person_id, reply->prsnl[count1].updt_cnt = n.updt_cnt, reply->
   prsnl[count1].email = n.email,
   reply->prsnl[count1].username = n.username, reply->prsnl[count1].name_last = n.name_last, reply->
   prsnl[count1].name_first = n.name_first,
   reply->prsnl[count1].name_full_formatted = n.name_full_formatted, reply->prsnl[count1].
   prsnl_type_cd = n.prsnl_type_cd, reply->prsnl[count1].position_cd = n.position_cd,
   reply->prsnl[count1].name_middle = p.name_middle, reply->prsnl[count1].name_suffix = p2
   .name_suffix, reply->prsnl[count1].beg_effective_dt_tm = cnvtdatetime(n.beg_effective_dt_tm),
   reply->prsnl[count1].end_effective_dt_tm = cnvtdatetime(n.end_effective_dt_tm)
  FOOT REPORT
   stat = alterlist(reply->prsnl,count1), reply->prsnl_qual = count1, context->person_id = reply->
   prsnl[count1].person_id,
   context->person_max = request->person_max
  WITH nocounter, maxqual(n,value(request->person_max)), outerjoin = d,
   maxqual(p2,1)
 ;end select
 IF (count1=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 GO TO end_program
#get_exact
 SELECT INTO "nl:"
  FROM prsnl n,
   person p,
   (dummyt d  WITH seq = 1),
   person_name p2
  PLAN (n
   WHERE n.name_last_key=cnvtupper(request->name_last)
    AND n.name_first_key=patstring(cnvtupper(request->name_first))
    AND n.active_ind > 0
    AND n.username != null
    AND n.username > " "
    AND n.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND n.end_effective_dt_tm >= cnvtdatetime(sysdate))
   JOIN (p
   WHERE p.person_id=n.person_id)
   JOIN (d
   WHERE d.seq=1)
   JOIN (p2
   WHERE p2.person_id=n.person_id)
  HEAD REPORT
   count1 = 0
  HEAD n.person_id
   count1 += 1
   IF (size(reply->prsnl,5) <= count1)
    stat = alterlist(reply->prsnl,(count1+ 10))
   ENDIF
   reply->prsnl[count1].person_id = n.person_id, reply->prsnl[count1].updt_cnt = n.updt_cnt, reply->
   prsnl[count1].email = n.email,
   reply->prsnl[count1].username = n.username, reply->prsnl[count1].name_last = n.name_last, reply->
   prsnl[count1].name_first = n.name_first,
   reply->prsnl[count1].name_full_formatted = n.name_full_formatted, reply->prsnl[count1].
   prsnl_type_cd = n.prsnl_type_cd, reply->prsnl[count1].position_cd = n.position_cd,
   reply->prsnl[count1].name_middle = p.name_middle, reply->prsnl[count1].name_suffix = p2
   .name_suffix, reply->prsnl[count1].beg_effective_dt_tm = cnvtdatetime(n.beg_effective_dt_tm),
   reply->prsnl[count1].end_effective_dt_tm = cnvtdatetime(n.end_effective_dt_tm)
  FOOT REPORT
   stat = alterlist(reply->prsnl,count1), reply->prsnl_qual = count1, context->person_id = reply->
   prsnl[count1].person_id,
   context->person_max = request->person_max
  WITH nocounter, maxqual(n,value(request->person_max)), outerjoin = d,
   maxqual(p2,1)
 ;end select
 IF (count1=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#end_program
END GO
