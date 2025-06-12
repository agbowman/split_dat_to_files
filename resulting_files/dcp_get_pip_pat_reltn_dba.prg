CREATE PROGRAM dcp_get_pip_pat_reltn:dba
 RECORD reply(
   1 qual[*]
     2 person_id = f8
     2 encntr_id = f8
     2 reltn_id = f8
     2 p_reltns[*]
       3 reltn_type_cd = f8
       3 reltn_type_disp = c40
       3 reltn_type_mean = c12
       3 prsnl_id = f8
       3 prsnl_disp = vc
     2 e_reltns[*]
       3 reltn_type_cd = f8
       3 reltn_type_disp = c40
       3 reltn_type_mean = c12
       3 prsnl_id = f8
       3 prsnl_disp = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 encntr_cnt = i4
   1 encntrs[*]
     2 encntr_id = f8
   1 person_cnt = i4
   1 persons[*]
     2 person_id = f8
 )
 SET modify = predeclare
 SET reply->status_data.status = "F"
 DECLARE sz = i4 WITH noconstant(size(request->persons,5))
 IF (sz=0)
  GO TO finish
 ENDIF
 DECLARE x = i4 WITH noconstant(0)
 DECLARE stat = i2 WITH noconstant(0)
 DECLARE finalize_flag = i2 WITH noconstant(0)
 CALL echo(build("Size",sz))
 DECLARE initializereply(null) = null
 DECLARE processrequest(null) = null
 DECLARE finalizereply(null) = null
 CALL initializereply(null)
 CALL processrequest(null)
 DECLARE locate_cnt = i4 WITH noconstant(size(reply->qual,5))
 DECLARE ex_prsn_cnt = i4 WITH noconstant(temp->person_cnt), protect
 DECLARE ex_prsn_index = i4 WITH noconstant(0), protect
 DECLARE ex_prsn_start = i4 WITH noconstant(1), protect
 DECLARE ex_prsn_max = i4 WITH constant(50), protect
 DECLARE ex_prsn_chunk_cnt = i4 WITH constant(ceil(((ex_prsn_cnt * 1.0)/ ex_prsn_max))), protect
 DECLARE ex_prsn_max_size = i4 WITH constant((ex_prsn_chunk_cnt * ex_prsn_max)), protect
 DECLARE prsn_idx = i4 WITH noconstant(0), protect
 SET stat = alterlist(temp->persons,ex_prsn_max_size)
 FOR (x = (ex_prsn_cnt+ 1) TO ex_prsn_max_size)
   SET temp->persons[x].person_id = temp->persons[ex_prsn_cnt].person_id
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(ex_prsn_chunk_cnt)),
   person_prsnl_reltn ppr,
   prsnl prs
  PLAN (d1
   WHERE assign(ex_prsn_start,evaluate(d1.seq,1,1,(ex_prsn_start+ ex_prsn_max))))
   JOIN (ppr
   WHERE expand(ex_prsn_index,ex_prsn_start,((ex_prsn_start+ ex_prsn_max) - 1),ppr.person_id,temp->
    persons[ex_prsn_index].person_id)
    AND ppr.active_ind=1
    AND ppr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (prs
   WHERE prs.person_id=ppr.prsnl_person_id)
  ORDER BY ppr.person_id
  HEAD ppr.person_id
   idx = locateval(prsn_idx,1,locate_cnt,ppr.person_id,reply->qual[prsn_idx].person_id), pprcnt = 0
  DETAIL
   pprcnt = (pprcnt+ 1)
   IF (mod(pprcnt,10)=1)
    stat = alterlist(reply->qual[idx].p_reltns,(pprcnt+ 9))
   ENDIF
   reply->qual[idx].p_reltns[pprcnt].reltn_type_cd = ppr.person_prsnl_r_cd, reply->qual[idx].
   p_reltns[pprcnt].prsnl_id = ppr.prsnl_person_id
   IF (ppr.prsnl_person_id > 0)
    reply->qual[idx].p_reltns[pprcnt].prsnl_disp = prs.name_full_formatted
   ELSE
    reply->qual[idx].p_reltns[pprcnt].prsnl_disp = ppr.ft_prsnl_name
   ENDIF
  FOOT  ppr.person_id
   stat = alterlist(reply->qual[idx].p_reltns,pprcnt)
  WITH nocounter
 ;end select
 CALL echorecord(reply)
 DECLARE ex_encntr_cnt = i4 WITH noconstant(temp->encntr_cnt), protect
 DECLARE ex_encntr_index = i4 WITH noconstant(0), protect
 DECLARE ex_encntr_start = i4 WITH noconstant(1), protect
 DECLARE ex_encntr_max = i4 WITH constant(50), protect
 DECLARE ex_encntr_chunk_cnt = i4 WITH constant(ceil(((ex_encntr_cnt * 1.0)/ ex_encntr_max))),
 protect
 DECLARE ex_encntr_max_size = i4 WITH constant((ex_encntr_chunk_cnt * ex_encntr_max)), protect
 DECLARE encntr_idx = i4 WITH noconstant(0)
 SET stat = alterlist(temp->encntrs,ex_encntr_max_size)
 FOR (x = (ex_encntr_cnt+ 1) TO ex_encntr_max_size)
   SET temp->encntrs[x].encntr_id = temp->encntrs[ex_encntr_cnt].encntr_id
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(ex_encntr_chunk_cnt)),
   encntr_prsnl_reltn epr,
   prsnl prs
  PLAN (d1
   WHERE assign(ex_encntr_start,evaluate(d1.seq,1,1,(ex_encntr_start+ ex_encntr_max))))
   JOIN (epr
   WHERE expand(ex_encntr_index,ex_encntr_start,((ex_encntr_start+ ex_encntr_max) - 1),epr.encntr_id,
    temp->encntrs[ex_encntr_index].encntr_id)
    AND epr.active_ind=1
    AND epr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND ((epr.expiration_ind+ 0)=0))
   JOIN (prs
   WHERE prs.person_id=epr.prsnl_person_id)
  ORDER BY epr.encntr_id
  HEAD REPORT
   stat = 0, eprcnt = 0
  HEAD epr.encntr_id
   idx = locateval(encntr_idx,1,locate_cnt,epr.encntr_id,reply->qual[encntr_idx].encntr_id), eprcnt
    = 0
  DETAIL
   eprcnt = (eprcnt+ 1)
   IF (mod(eprcnt,10)=1)
    stat = alterlist(reply->qual[idx].e_reltns,(eprcnt+ 9))
   ENDIF
   reply->qual[idx].reltn_id = epr.encntr_prsnl_reltn_id, reply->qual[idx].e_reltns[eprcnt].
   reltn_type_cd = epr.encntr_prsnl_r_cd, reply->qual[idx].e_reltns[eprcnt].prsnl_id = epr
   .prsnl_person_id
   IF (epr.prsnl_person_id > 0)
    reply->qual[idx].e_reltns[eprcnt].prsnl_disp = prs.name_full_formatted
   ELSE
    reply->qual[idx].e_reltns[eprcnt].prsnl_disp = epr.ft_prsnl_name
   ENDIF
  FOOT  epr.encntr_id
   stat = alterlist(reply->qual[idx].e_reltns,eprcnt)
  WITH nocounter
 ;end select
 FREE SET temp
 IF (finalize_flag=1)
  CALL finalizereply(null)
 ENDIF
#finish
 IF (sz=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SUBROUTINE initializereply(null)
   DECLARE i = i4 WITH noconstant(0), private
   SET stat = alterlist(reply->qual,sz)
   FOR (i = 1 TO sz)
    SET reply->qual[i].person_id = request->persons[i].person_id
    SET reply->qual[i].encntr_id = request->persons[i].encntr_id
   ENDFOR
 END ;Subroutine
 SUBROUTINE processrequest(null)
   SET temp->person_cnt = 0
   SET temp->encntr_cnt = 0
   SET stat = alterlist(temp->encntrs,sz)
   SET stat = alterlist(temp->persons,sz)
   SELECT INTO "nl:"
    person_id = request->persons[d.seq].person_id
    FROM (dummyt d  WITH seq = value(size(request->persons,5)))
    ORDER BY person_id
    HEAD person_id
     temp->person_cnt = (temp->person_cnt+ 1), temp->persons[temp->person_cnt].person_id = request->
     persons[d.seq].person_id
    DETAIL
     IF ((request->persons[d.seq].encntr_id > 0))
      temp->encntr_cnt = (temp->encntr_cnt+ 1), temp->encntrs[temp->encntr_cnt].encntr_id = request->
      persons[d.seq].encntr_id
     ENDIF
    FOOT REPORT
     IF ((temp->person_cnt < sz))
      finalize_flag = 1
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE finalizereply(null)
   DECLARE y = i2 WITH noconstant(0), private
   DECLARE z = i2 WITH noconstant(0), private
   DECLARE rcnt = i2 WITH noconstant(0), private
   FOR (x = 1 TO (sz - 1))
     FOR (y = (x+ 1) TO sz)
       IF ((reply->qual[x].person_id=reply->qual[y].person_id))
        SET rcnt = size(reply->qual[x].p_reltns,5)
        SET stat = alterlist(reply->qual[y].p_reltns,rcnt)
        FOR (z = 1 TO rcnt)
          SET reply->qual[y].p_reltns[z].prsnl_disp = reply->qual[x].p_reltns[z].prsnl_disp
          SET reply->qual[y].p_reltns[z].prsnl_id = reply->qual[x].p_reltns[z].prsnl_id
          SET reply->qual[y].p_reltns[z].reltn_type_cd = reply->qual[x].p_reltns[z].reltn_type_cd
        ENDFOR
       ENDIF
     ENDFOR
   ENDFOR
 END ;Subroutine
END GO
