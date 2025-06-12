CREATE PROGRAM dcp_get_pat_reltn_by_type:dba
 SET modify = predeclare
 FREE RECORD reltn_types
 RECORD reltn_types(
   1 p_reltn_types[*]
     2 reltn_type_mean = c12
     2 reltn_type_cd = f8
   1 e_reltn_types[*]
     2 reltn_type_mean = c12
     2 reltn_type_cd = f8
 )
 FREE RECORD reply
 RECORD reply(
   1 persons[*]
     2 person_id = f8
     2 encntr_id = f8
     2 p_reltns[*]
       3 reltn_id = f8
       3 reltn_type_cd = f8
       3 reltn_type_disp = c40
       3 reltn_type_mean = c12
       3 prsnl_id = f8
     2 e_reltns[*]
       3 reltn_id = f8
       3 reltn_type_cd = f8
       3 reltn_type_disp = c40
       3 reltn_type_mean = c12
       3 prsnl_id = f8
   1 prsnls[*]
     2 prsnl_id = f8
     2 prsnl_disp = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE status = i2 WITH noconstant(0)
 DECLARE idx = i2 WITH noconstant(0)
 DECLARE person_idx = i2 WITH noconstant(0)
 DECLARE reltn_idx = i2 WITH noconstant(0)
 DECLARE prsnl_idx = i2 WITH noconstant(0)
 DECLARE requestsize = i2 WITH constant(size(request->persons,5))
 DECLARE requestchunkcnt = i2 WITH noconstant(0)
 DECLARE ptypesize = i2 WITH constant(size(request->p_reltn_types,5))
 DECLARE etypesize = i2 WITH constant(size(request->e_reltn_types,5))
 DECLARE replysize = i2 WITH noconstant(0)
 DECLARE chunksize = i2 WITH constant(20)
 DECLARE prsnlcnt = i2 WITH noconstant(0)
 DECLARE prsnlchunkcnt = i2 WITH noconstant(0)
 DECLARE returncnt = i2 WITH noconstant(0)
 DECLARE debug_ind = i2 WITH protect, noconstant(0)
 DECLARE error_msg = vc WITH protect, noconstant("")
 DECLARE error_code = i2 WITH protect, noconstant(false)
 DECLARE buildreply(null) = null
 DECLARE normalizerequst(null) = null
 DECLARE processrelationtypes(null) = null
 DECLARE processpersonnels(null) = null
 DECLARE selectpersonnelrelationships(null) = null
 DECLARE selectencounterrelationships(null) = null
 SET reply->status_data.status = "F"
 IF (validate(request->debug_ind)=1)
  IF ((request->debug_ind=1))
   SET trace = debug
   SET debug_ind = 1
  ENDIF
 ENDIF
 DECLARE reportfailure(opname=vc,opstatus=vc,targetname=vc,targetvalue=vc) = null
 DECLARE fillsubeventstatus(opname=vc,opstatus=vc,objname=vc,objvalue=vc) = null
 SUBROUTINE reportfailure(opname,opstatus,targetname,targetvalue)
  SET reply->status_data.status = "F"
  CALL fillsubeventstatus(opname,opstatus,targetname,targetvalue)
 END ;Subroutine
 SUBROUTINE fillsubeventstatus(opname,opstatus,objname,objvalue)
   DECLARE dcp_substatus_cnt = i4 WITH protect, noconstant(size(reply->status_data.subeventstatus,5))
   SET dcp_substatus_cnt = (dcp_substatus_cnt+ 1)
   IF (dcp_substatus_cnt != 1)
    SET stat = alter(reply->status_data.subeventstatus,dcp_substatus_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].operationname = trim(opname)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].targetobjectname = trim(objname)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].targetobjectvalue = trim(objvalue)
 END ;Subroutine
 CALL buildreply(null)
 CALL normalizerequest(null)
 CALL processrelationtypes(null)
 SET status = alterlist(reply->prsnls,10)
 IF (size(request->p_reltn_types,5) > 0)
  CALL selectpersonnelrelationships(null)
 ENDIF
 IF (size(request->e_reltn_types,5) > 0)
  CALL selectencounterrelationships(null)
 ENDIF
 IF (prsnlcnt > 0)
  CALL processpersonnels(null)
 ENDIF
 SUBROUTINE selectpersonnelrelationships(null)
  DECLARE psize = i2 WITH constant(size(reltn_types->p_reltn_types,5))
  SELECT INTO "nl:"
   ppr_person_prsnl_r_disp = uar_get_code_display(ppr.person_prsnl_r_cd), ppr_person_prsnl_r_mean =
   uar_get_code_meaning(ppr.person_prsnl_r_cd)
   FROM (dummyt d1  WITH seq = requestchunkcnt),
    person_prsnl_reltn ppr
   PLAN (d1)
    JOIN (ppr
    WHERE expand(idx,(((d1.seq - 1) * chunksize)+ 1),(d1.seq * chunksize),ppr.person_id,request->
     persons[idx].person_id)
     AND expand(reltn_idx,1,psize,ppr.person_prsnl_r_cd,reltn_types->p_reltn_types[reltn_idx].
     reltn_type_cd)
     AND ppr.active_ind=1
     AND ppr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   ORDER BY ppr.person_id, ppr.person_prsnl_reltn_id
   HEAD ppr.person_id
    person_idx = locateval(idx,1,replysize,ppr.person_id,reply->persons[idx].person_id), status =
    alterlist(reply->persons[person_idx].p_reltns,10), reltn_cnt = 0
   HEAD ppr.person_prsnl_reltn_id
    reltn_cnt = (reltn_cnt+ 1), returncnt = (returncnt+ 1)
    IF (mod(reltn_cnt,10)=1)
     status = alterlist(reply->persons[person_idx].p_reltns,(reltn_cnt+ 9))
    ENDIF
    reply->persons[person_idx].p_reltns[reltn_cnt].reltn_id = ppr.person_prsnl_reltn_id, reply->
    persons[person_idx].p_reltns[reltn_cnt].reltn_type_cd = ppr.person_prsnl_r_cd, reply->persons[
    person_idx].p_reltns[reltn_cnt].reltn_type_disp = ppr_person_prsnl_r_disp,
    reply->persons[person_idx].p_reltns[reltn_cnt].reltn_type_mean = ppr_person_prsnl_r_mean, reply->
    persons[person_idx].p_reltns[reltn_cnt].prsnl_id = ppr.prsnl_person_id
    IF (locateval(idx,1,prsnlcnt,ppr.prsnl_person_id,reply->prsnls[idx].prsnl_id)=0)
     prsnlcnt = (prsnlcnt+ 1)
     IF (mod(prsnlcnt,10)=1)
      status = alterlist(reply->prsnls,(prsnlcnt+ 9))
     ENDIF
     reply->prsnls[prsnlcnt].prsnl_id = ppr.prsnl_person_id
    ENDIF
   FOOT  ppr.person_id
    status = alterlist(reply->persons[person_idx].p_reltns,reltn_cnt)
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE selectencounterrelationships(null)
  DECLARE esize = i2 WITH constant(size(reltn_types->e_reltn_types,5))
  SELECT INTO "nl:"
   epr_encntr_prsnl_r_disp = uar_get_code_display(epr.encntr_prsnl_r_cd), epr_encntr_prsnl_r_mean =
   uar_get_code_meaning(epr.encntr_prsnl_r_cd)
   FROM (dummyt d1  WITH seq = requestchunkcnt),
    encntr_prsnl_reltn epr
   PLAN (d1)
    JOIN (epr
    WHERE expand(idx,(((d1.seq - 1) * chunksize)+ 1),(d1.seq * chunksize),epr.encntr_id,request->
     persons[idx].encntr_id)
     AND expand(reltn_idx,1,esize,epr.encntr_prsnl_r_cd,reltn_types->e_reltn_types[reltn_idx].
     reltn_type_cd)
     AND epr.active_ind=1
     AND epr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     AND ((epr.expiration_ind+ 0)=0)
     AND epr.encntr_id != 0)
   ORDER BY epr.encntr_id, epr.encntr_prsnl_reltn_id
   HEAD epr.encntr_id
    person_idx = locateval(idx,1,replysize,epr.encntr_id,reply->persons[idx].encntr_id), status =
    alterlist(reply->persons[person_idx].e_reltns,10), reltn_cnt = 0
   HEAD epr.encntr_prsnl_reltn_id
    reltn_cnt = (reltn_cnt+ 1), returncnt = (returncnt+ 1)
    IF (mod(reltn_cnt,10)=1)
     status = alterlist(reply->persons[person_idx].e_reltns,(reltn_cnt+ 9))
    ENDIF
    reply->persons[person_idx].e_reltns[reltn_cnt].reltn_id = epr.encntr_prsnl_reltn_id, reply->
    persons[person_idx].e_reltns[reltn_cnt].reltn_type_cd = epr.encntr_prsnl_r_cd, reply->persons[
    person_idx].e_reltns[reltn_cnt].reltn_type_disp = epr_encntr_prsnl_r_disp,
    reply->persons[person_idx].e_reltns[reltn_cnt].reltn_type_mean = epr_encntr_prsnl_r_mean, reply->
    persons[person_idx].e_reltns[reltn_cnt].prsnl_id = epr.prsnl_person_id
    IF (locateval(idx,1,prsnlcnt,epr.prsnl_person_id,reply->prsnls[idx].prsnl_id)=0)
     prsnlcnt = (prsnlcnt+ 1)
     IF (mod(prsnlcnt,10)=1)
      status = alterlist(reply->prsnls,(prsnlcnt+ 9))
     ENDIF
     reply->prsnls[prsnlcnt].prsnl_id = epr.prsnl_person_id
    ENDIF
   FOOT  epr.encntr_id
    status = alterlist(reply->persons[person_idx].e_reltns,reltn_cnt)
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE buildreply(null)
   SELECT INTO "nl:"
    person_id = request->persons[d1.seq].person_id, encntr_id = request->persons[d1.seq].encntr_id
    FROM (dummyt d1  WITH seq = requestsize)
    ORDER BY person_id
    HEAD REPORT
     status = alterlist(reply->persons,10), person_idx = 0
    DETAIL
     person_idx = (person_idx+ 1)
     IF (mod(person_idx,10)=1)
      status = alterlist(reply->persons,(person_idx+ 9))
     ENDIF
     reply->persons[person_idx].person_id = person_id, reply->persons[person_idx].encntr_id =
     encntr_id
    FOOT REPORT
     status = alterlist(reply->persons,person_idx), replysize = person_idx
    WITH nocounter
   ;end select
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
     person_idx = (person_idx+ 1), request->persons[(person_idx+ requestsize)].person_id = request->
     persons[requestsize].person_id, request->persons[(person_idx+ requestsize)].encntr_id = request
     ->persons[requestsize].encntr_id
    WITH nocounter
   ;end select
  ENDIF
 END ;Subroutine
 SUBROUTINE processrelationtypes(null)
   DECLARE index = i4 WITH protect, noconstant(0)
   DECLARE max_cnt = i4 WITH protect, constant(100)
   DECLARE occurrences = i4 WITH protect, noconstant(0)
   DECLARE arrcodelist[100] = f8 WITH protect
   DECLARE remain = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = ptypesize)
    HEAD REPORT
     reltn_idx = 0, count = 0, iterator = 0
    DETAIL
     occurrences = max_cnt, reltn_idx = (reltn_idx+ 1),
     CALL uar_get_code_list_by_meaning(331,nullterm(request->p_reltn_types[reltn_idx].reltn_type_mean
      ),1,occurrences,remain,arrcodelist)
     FOR (index = 1 TO occurrences)
       count = (count+ 1), iterator = (iterator+ 1)
       IF (mod(count,100)=1)
        status = alterlist(reltn_types->p_reltn_types,(count+ 99))
       ENDIF
       reltn_types->p_reltn_types[count].reltn_type_cd = arrcodelist[index], reltn_types->
       p_reltn_types[count].reltn_type_mean = request->p_reltn_types[reltn_idx].reltn_type_mean
     ENDFOR
     IF (remain > 0)
      occurrences = max_cnt,
      CALL uar_get_code_list_by_meaning(331,nullterm(request->p_reltn_types[reltn_idx].
       reltn_type_mean),1,occurrences,remain,arrcodelist)
      FOR (index = iterator TO occurrences)
        count = (count+ 1)
        IF (mod(count,100)=1)
         status = alterlist(reltn_types->p_reltn_types,(count+ 99))
        ENDIF
        reltn_types->p_reltn_types[count].reltn_type_cd = arrcodelist[index], reltn_types->
        p_reltn_types[count].reltn_type_mean = request->p_reltn_types[reltn_idx].reltn_type_mean
      ENDFOR
     ENDIF
    FOOT REPORT
     status = alterlist(reltn_types->p_reltn_types,count)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = etypesize)
    HEAD REPORT
     reltn_idx = 0, count = 0, iterator = 0
    DETAIL
     occurrences = max_cnt, reltn_idx = (reltn_idx+ 1),
     CALL uar_get_code_list_by_meaning(333,nullterm(request->e_reltn_types[reltn_idx].reltn_type_mean
      ),1,occurrences,remain,arrcodelist)
     FOR (index = 1 TO occurrences)
       count = (count+ 1), iterator = (iterator+ 1)
       IF (mod(count,100)=1)
        status = alterlist(reltn_types->e_reltn_types,(count+ 99))
       ENDIF
       reltn_types->e_reltn_types[count].reltn_type_cd = arrcodelist[index], reltn_types->
       e_reltn_types[count].reltn_type_mean = request->e_reltn_types[reltn_idx].reltn_type_mean
     ENDFOR
     IF (remain > 0)
      occurrences = max_cnt,
      CALL uar_get_code_list_by_meaning(333,nullterm(request->e_reltn_types[reltn_idx].
       reltn_type_mean),1,occurrences,remain,arrcodelist)
      FOR (index = iterator TO occurrences)
        count = (count+ 1)
        IF (mod(count,100)=1)
         status = alterlist(reltn_types->e_reltn_types,(count+ 99))
        ENDIF
        reltn_types->e_reltn_types[count].reltn_type_cd = arrcodelist[index], reltn_types->
        e_reltn_types[count].reltn_type_mean = request->e_reltn_types[reltn_idx].reltn_type_mean
      ENDFOR
     ENDIF
    FOOT REPORT
     status = alterlist(reltn_types->e_reltn_types,count)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE processpersonnels(null)
   SET prsnlchunkcnt = ceil(((prsnlcnt * 1.0)/ chunksize))
   IF (mod(prsnlcnt,chunksize) != 0)
    SET status = alterlist(reply->prsnls,(prsnlchunkcnt * chunksize))
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = ((prsnlchunkcnt * chunksize) - prsnlcnt))
     HEAD REPORT
      person_idx = 0
     DETAIL
      person_idx = (person_idx+ 1), reply->prsnls[(person_idx+ prsnlcnt)].prsnl_id = reply->prsnls[
      prsnlcnt].prsnl_id
     WITH nocounter
    ;end select
   ENDIF
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = prsnlchunkcnt),
     prsnl p
    PLAN (d1)
     JOIN (p
     WHERE expand(idx,(((d1.seq - 1) * chunksize)+ 1),(d1.seq * chunksize),p.person_id,reply->prsnls[
      idx].prsnl_id))
    HEAD REPORT
     person_idx = 0
    DETAIL
     person_idx = locateval(idx,1,prsnlcnt,p.person_id,reply->prsnls[idx].prsnl_id), reply->prsnls[
     person_idx].prsnl_disp = p.name_full_formatted
    FOOT REPORT
     status = alterlist(reply->prsnls,prsnlcnt)
    WITH nocounter
   ;end select
 END ;Subroutine
#exit_script
 SET error_code = error(error_msg,1)
 IF (error_code != 0)
  SET reply->status_data.status = "F"
  CALL fillsubeventstatus("ERROR","F","dcp_get_pat_reltn_by_type",error_msg)
 ELSEIF (returncnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF (debug_ind=1)
  CALL echorecord(reply)
  CALL echo("Script was last modified on: 001 01/24/11")
 ENDIF
END GO
