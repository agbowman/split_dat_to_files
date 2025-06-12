CREATE PROGRAM dcp_get_alias_from_personid:dba
 RECORD reply(
   1 qual[*]
     2 alias = vc
     2 alias_pool_cd = f8
     2 encntr_id = f8
     2 encntr_alias_type_cd = f8
     2 person_alias_type_cd = f8
     2 formatted_alias = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD encntr_search(
   1 qual[*]
     2 alias_pool_cd = f8
 )
 RECORD person_search(
   1 qual[*]
     2 alias_pool_cd = f8
 )
 SET reply->status_data.status = "F"
 DECLARE count = i2 WITH public, noconstant(0)
 DECLARE person_count = i2 WITH public, noconstant(0)
 DECLARE stat = i4 WITH public, noconstant(0)
 DECLARE reqsize = i2 WITH public, noconstant(0)
 DECLARE i = i2 WITH public, noconstant(0)
 IF ((request->encntr_only=1))
  SET reqsize = size(request->qual,5)
  FOR (i = 1 TO reqsize)
    IF ((request->qual[i].encntr_only=1))
     SET count = (count+ 1)
     IF (count > size(encntr_search->qual,5))
      SET stat = alterlist(encntr_search->qual,(count+ 9))
     ENDIF
     SET encntr_search->qual[count].alias_pool_cd = request->qual[i].alias_pool_cd
    ELSE
     SET person_count = (person_count+ 1)
     IF (person_count > size(person_search->qual,5))
      SET stat = alterlist(person_search->qual,(person_count+ 9))
     ENDIF
     SET person_search->qual[person_count].alias_pool_cd = request->qual[i].alias_pool_cd
    ENDIF
  ENDFOR
  SET stat = alterlist(encntr_search->qual,count)
  SET stat = alterlist(person_search->qual,person_count)
  SET count = 0
  SELECT INTO "nl:"
   FROM encntr_alias ea,
    encounter e,
    (dummyt d  WITH seq = size(encntr_search->qual,5))
   PLAN (d)
    JOIN (ea
    WHERE (ea.alias_pool_cd=encntr_search->qual[d.seq].alias_pool_cd)
     AND ea.active_ind=1
     AND (ea.encntr_id=request->encntr_id)
     AND ea.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
     AND ea.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    JOIN (e
    WHERE e.encntr_id=ea.encntr_id
     AND e.active_ind=1
     AND (e.person_id=request->person_id)
     AND e.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
     AND e.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   DETAIL
    count = (count+ 1)
    IF (count > size(reply->qual,5))
     stat = alterlist(reply->qual,(count+ 9))
    ENDIF
    reply->qual[count].alias = ea.alias, reply->qual[count].alias_pool_cd = ea.alias_pool_cd, reply->
    qual[count].encntr_id = ea.encntr_id
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM person_alias pa,
    (dummyt d  WITH seq = size(person_search->qual,5))
   PLAN (d)
    JOIN (pa
    WHERE (pa.alias_pool_cd=person_search->qual[d.seq].alias_pool_cd)
     AND (pa.person_id=request->person_id)
     AND pa.active_ind=1
     AND pa.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
     AND pa.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   DETAIL
    count = (count+ 1)
    IF (count > size(reply->qual,5))
     stat = alterlist(reply->qual,(count+ 9))
    ENDIF
    reply->qual[count].alias = pa.alias, reply->qual[count].alias_pool_cd = pa.alias_pool_cd
   WITH nocounter
  ;end select
 ELSE
  IF ((request->encntr_alias_type_cd != 0))
   SELECT INTO "nl:"
    FROM encounter e,
     encntr_alias ea,
     alias_pool ap
    PLAN (e
     WHERE (e.person_id=request->person_id)
      AND e.active_ind=1
      AND e.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
      AND e.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     JOIN (ea
     WHERE (ea.encntr_alias_type_cd=request->encntr_alias_type_cd)
      AND ea.active_ind=1
      AND ea.encntr_id=e.encntr_id
      AND ea.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
      AND ea.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     JOIN (ap
     WHERE ea.alias_pool_cd=ap.alias_pool_cd
      AND ap.active_ind=1)
    DETAIL
     count = (count+ 1)
     IF (count > size(reply->qual,5))
      stat = alterlist(reply->qual,(count+ 9))
     ENDIF
     IF (ea.alias_pool_cd != 0.0)
      reply->qual[count].formatted_alias = cnvtalias(ea.alias,ea.alias_pool_cd)
     ELSE
      reply->qual[count].formatted_alias = cnvtalias(ea.alias,ap.format_mask)
     ENDIF
     reply->qual[count].alias = ea.alias, reply->qual[count].alias_pool_cd = ea.alias_pool_cd, reply
     ->qual[count].encntr_id = ea.encntr_id,
     reply->qual[count].encntr_alias_type_cd = ea.encntr_alias_type_cd
    WITH nocounter
   ;end select
  ELSEIF ((request->person_alias_type_cd != 0))
   SELECT INTO "nl:"
    FROM person_alias pa,
     alias_pool ap
    PLAN (pa
     WHERE (pa.person_alias_type_cd=request->person_alias_type_cd)
      AND (pa.person_id=request->person_id)
      AND pa.active_ind=1
      AND pa.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
      AND pa.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     JOIN (ap
     WHERE pa.alias_pool_cd=ap.alias_pool_cd
      AND ap.active_ind=1)
    DETAIL
     count = (count+ 1)
     IF (count > size(reply->qual,5))
      stat = alterlist(reply->qual,(count+ 9))
     ENDIF
     IF (pa.alias_pool_cd != 0.0)
      reply->qual[count].formatted_alias = cnvtalias(pa.alias,pa.alias_pool_cd)
     ELSE
      reply->qual[count].formatted_alias = cnvtalias(pa.alias,ap.format_mask)
     ENDIF
     reply->qual[count].alias = pa.alias, reply->qual[count].alias_pool_cd = pa.alias_pool_cd, reply
     ->qual[count].person_alias_type_cd = pa.person_alias_type_cd
    WITH nocounter
   ;end select
  ELSE
   SELECT INTO "nl:"
    FROM encounter e,
     encntr_alias ea,
     (dummyt d  WITH seq = size(request->qual,5)),
     alias_pool ap
    PLAN (d)
     JOIN (e
     WHERE (e.person_id=request->person_id)
      AND e.active_ind=1
      AND e.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
      AND e.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     JOIN (ea
     WHERE (ea.alias_pool_cd=request->qual[d.seq].alias_pool_cd)
      AND ea.active_ind=1
      AND ea.encntr_id=e.encntr_id
      AND ea.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
      AND ea.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     JOIN (ap
     WHERE ea.alias_pool_cd=ap.alias_pool_cd
      AND ap.active_ind=1)
    DETAIL
     count = (count+ 1)
     IF (count > size(reply->qual,5))
      stat = alterlist(reply->qual,(count+ 9))
     ENDIF
     IF (ea.alias_pool_cd != 0.0)
      reply->qual[count].formatted_alias = cnvtalias(ea.alias,ea.alias_pool_cd)
     ELSE
      reply->qual[count].formatted_alias = cnvtalias(ea.alias,ap.format_mask)
     ENDIF
     reply->qual[count].alias = ea.alias, reply->qual[count].alias_pool_cd = ea.alias_pool_cd, reply
     ->qual[count].encntr_id = ea.encntr_id
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM person_alias pa,
     (dummyt d  WITH seq = size(request->qual,5)),
     alias_pool ap
    PLAN (d)
     JOIN (pa
     WHERE (pa.alias_pool_cd=request->qual[d.seq].alias_pool_cd)
      AND (pa.person_id=request->person_id)
      AND pa.active_ind=1
      AND pa.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
      AND pa.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     JOIN (ap
     WHERE pa.alias_pool_cd=ap.alias_pool_cd
      AND ap.active_ind=1)
    DETAIL
     count = (count+ 1)
     IF (count > size(reply->qual,5))
      stat = alterlist(reply->qual,(count+ 9))
     ENDIF
     IF (pa.alias_pool_cd != 0.0)
      reply->qual[count].formatted_alias = cnvtalias(pa.alias,pa.alias_pool_cd)
     ELSE
      reply->qual[count].formatted_alias = cnvtalias(pa.alias,ap.format_mask)
     ENDIF
     reply->qual[count].alias = pa.alias, reply->qual[count].alias_pool_cd = pa.alias_pool_cd
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 SET reply->status_data.status = "Z"
 SET stat = alterlist(reply->qual,count)
 FREE RECORD person_search
 FREE RECORD encntr_search
 CALL echorecord(reply)
END GO
