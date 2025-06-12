CREATE PROGRAM dcp_get_pip_prsnl_reltn:dba
 RECORD reply(
   1 persons[*]
     2 person_id = f8
     2 p_reltns[*]
       3 reltn_cd = f8
       3 reltn_disp = vc
       3 reltn_mean = c12
     2 e_reltns[*]
       3 reltn_cd = f8
       3 reltn_disp = vc
       3 reltn_mean = c12
       3 encntr_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE idx = i4 WITH noconstant(0)
 DECLARE status = i2 WITH noconstant(0)
 DECLARE requestsize = i2 WITH constant(size(request->persons,5))
 DECLARE requestchunkcnt = i2 WITH noconstant(0)
 DECLARE chunksize = i2 WITH constant(20)
 DECLARE person_idx = i4 WITH noconstant(0)
 DECLARE encntr_idx = i4 WITH noconstant(0)
 DECLARE reltn_idx = i2 WITH noconstant(0)
 DECLARE replysize = i2 WITH noconstant(0)
 DECLARE replychunkcnt = i2 WITH noconstant(0)
 DECLARE buildreply(null) = null
 DECLARE normalizerequest(null) = null
 IF (requestsize < 1)
  GO TO endscript
 ENDIF
 SET trace = debug
 SET modify = predeclare
 SET reply->status_data.status = "F"
 CALL buildreply(null)
 CALL normalizerequest(null)
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = replychunkcnt),
   person_prsnl_reltn ppr
  PLAN (d1)
   JOIN (ppr
   WHERE expand(idx,(((d1.seq - 1) * chunksize)+ 1),(d1.seq * chunksize),ppr.person_id,reply->
    persons[idx].person_id)
    AND (ppr.prsnl_person_id=request->prsnl_id)
    AND ppr.active_ind=1
    AND ppr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  ORDER BY ppr.person_id, ppr.person_prsnl_reltn_id
  HEAD REPORT
   idx = 0, person_idx = 0
  HEAD ppr.person_id
   person_idx = locateval(idx,1,replysize,ppr.person_id,reply->persons[idx].person_id), reltn_idx = 0,
   status = alterlist(reply->persons[person_idx].p_reltns,10)
  HEAD ppr.person_prsnl_reltn_id
   reltn_idx = (reltn_idx+ 1)
   IF (mod(reltn_idx,10)=1)
    status = alterlist(reply->persons[person_idx].p_reltns,(reltn_idx+ 9))
   ENDIF
   reply->persons[person_idx].p_reltns[reltn_idx].reltn_cd = ppr.person_prsnl_r_cd
  FOOT  ppr.person_id
   status = alterlist(reply->persons[person_idx].p_reltns,reltn_idx)
  WITH nocounter
 ;end select
 SET status = alterlist(reply->persons,replysize)
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = requestchunkcnt),
   encntr_prsnl_reltn epr,
   encounter e
  PLAN (d1)
   JOIN (epr
   WHERE expand(idx,(((d1.seq - 1) * chunksize)+ 1),(d1.seq * chunksize),epr.encntr_id,request->
    persons[idx].encntr_id)
    AND (epr.prsnl_person_id=request->prsnl_id)
    AND epr.active_ind=1
    AND epr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND ((epr.expiration_ind+ 0)=0))
   JOIN (e
   WHERE e.encntr_id=epr.encntr_id)
  ORDER BY e.person_id, epr.encntr_prsnl_reltn_id
  HEAD REPORT
   idx = 0, person_idx = 0
  HEAD e.person_id
   person_idx = locateval(idx,1,replysize,e.person_id,reply->persons[idx].person_id), reltn_idx = 0,
   status = alterlist(reply->persons[person_idx].e_reltns,10)
  HEAD epr.encntr_prsnl_reltn_id
   reltn_idx = (reltn_idx+ 1)
   IF (mod(reltn_idx,10)=1)
    status = alterlist(reply->persons[person_idx].e_reltns,(reltn_idx+ 9))
   ENDIF
   reply->persons[person_idx].e_reltns[reltn_idx].encntr_id = epr.encntr_id, reply->persons[
   person_idx].e_reltns[reltn_idx].reltn_cd = epr.encntr_prsnl_r_cd
  FOOT  e.person_id
   status = alterlist(reply->persons[person_idx].e_reltns,reltn_idx)
  WITH nocounter
 ;end select
#endscript
 IF (size(reply->persons,5)=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
 SUBROUTINE buildreply(null)
  SELECT INTO "nl:"
   person_id = request->persons[d1.seq].person_id
   FROM (dummyt d1  WITH seq = requestsize)
   ORDER BY person_id
   HEAD REPORT
    status = alterlist(reply->persons,chunksize), person_idx = 0
   HEAD person_id
    person_idx = (person_idx+ 1), replysize = (replysize+ 1)
    IF (mod(person_idx,chunksize)=1)
     status = alterlist(reply->persons,(person_idx+ (chunksize - 1)))
    ENDIF
    reply->persons[person_idx].person_id = person_id
   FOOT REPORT
    replysize = person_idx, replychunkcnt = ceil(((replysize * 1.0)/ chunksize))
   WITH nocounter
  ;end select
  IF (mod(replysize,chunksize) != 0)
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = ((replychunkcnt * chunksize) - replysize))
    HEAD REPORT
     person_idx = 0
    DETAIL
     person_idx = (person_idx+ 1), reply->persons[(person_idx+ replysize)].person_id = reply->
     persons[replysize].person_id
    WITH nocounter
   ;end select
  ENDIF
 END ;Subroutine
 SUBROUTINE normalizerequest(null)
  SET requestchunkcnt = ceil(((requestsize * 1.0)/ chunksize))
  IF (mod(requestsize,chunksize) != 0)
   SET status = alterlist(request->persons,(requestchunkcnt * chunksize))
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = ((requestchunkcnt * chunksize) - requestsize))
    HEAD REPORT
     person_idx = 0
    DETAIL
     person_idx = (person_idx+ 1), request->persons[(person_idx+ requestsize)].encntr_id = request->
     persons[requestsize].encntr_id
    WITH nocounter
   ;end select
  ENDIF
 END ;Subroutine
 SET modify = nopredeclare
END GO
