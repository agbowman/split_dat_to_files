CREATE PROGRAM ce_get_events_by_result_set:dba
 DECLARE resultsetidsize = i4 WITH constant(size(request->result_set_id_list,5))
 DECLARE relationtypesize = i4 WITH constant(size(request->relation_type_list,5))
 DECLARE nsize = i4 WITH constant(60)
 DECLARE rsize = i4 WITH constant(40)
 DECLARE ntotal = i4 WITH noconstant(0)
 DECLARE ntotal2 = i4 WITH noconstant(0)
 DECLARE nstart = i4 WITH noconstant(0)
 DECLARE idx = i4 WITH noconstant(0)
 DECLARE relationstart = i4 WITH noconstant(1)
 DECLARE relationidx = i4 WITH noconstant(0)
 DECLARE resultcnt = i4 WITH noconstant(0)
 DECLARE error_msg = vc WITH noconstant(" ")
 DECLARE error_code = i4 WITH noconstant(0)
 DECLARE record_status_draft = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(48,"DRAFT",1,record_status_draft)
 SET max_date = cnvtdatetime("31-DEC-2100 00:00:00")
 IF (resultsetidsize)
  SET ntotal2 = resultsetidsize
  SET ntotal = (ceil((cnvtreal(ntotal2)/ nsize)) * nsize)
  SET stat = alterlist(request->result_set_id_list,ntotal)
  FOR (idx = (ntotal2+ 1) TO ntotal)
    SET request->result_set_id_list[idx].result_set_id = request->result_set_id_list[resultsetidsize]
    .result_set_id
  ENDFOR
  SET idx = 0
  SET nstart = 1
 ELSE
  GO TO exit_script
 ENDIF
 IF (relationtypesize > rsize)
  SET reply->error_msg = "relation_type_list can contain a max of 40 items"
  GO TO exit_script
 ELSEIF (relationtypesize > 0
  AND relationtypesize < rsize)
  SET stat = alterlist(request->relation_type_list,rsize)
  FOR (relationidx = (relationtypesize+ 1) TO rsize)
    SET request->relation_type_list[relationidx].relation_type_cd = request->relation_type_list[
    relationtypesize].relation_type_cd
  ENDFOR
  SET relationidx = 0
 ENDIF
 SELECT
  IF (relationtypesize > 0)
   PLAN (d1
    WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ nsize))))
    JOIN (rsl
    WHERE expand(idx,nstart,(nstart+ (nsize - 1)),rsl.result_set_id,request->result_set_id_list[idx].
     result_set_id)
     AND rsl.valid_until_dt_tm=cnvtdatetime(max_date)
     AND expand(relationidx,relationstart,rsize,rsl.relation_type_cd,request->relation_type_list[
     relationidx].relation_type_cd))
    JOIN (ce
    WHERE rsl.event_id=ce.event_id
     AND ce.record_status_cd != record_status_draft)
  ELSE
   PLAN (d1
    WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ nsize))))
    JOIN (rsl
    WHERE expand(idx,nstart,(nstart+ (nsize - 1)),rsl.result_set_id,request->result_set_id_list[idx].
     result_set_id)
     AND rsl.valid_until_dt_tm=cnvtdatetime(max_date))
    JOIN (ce
    WHERE rsl.event_id=ce.event_id
     AND ce.record_status_cd != record_status_draft)
  ENDIF
  INTO "nl:"
  rsl.result_set_id, rsl.event_id
  FROM ce_result_set_link rsl,
   clinical_event ce,
   (dummyt d1  WITH seq = value((1+ ((ntotal - 1)/ nsize))))
  ORDER BY rsl.result_set_id, rsl.event_id
  HEAD rsl.event_id
   resultcnt += 1
   IF (mod(resultcnt,10)=1)
    stat = alterlist(reply->event_id_list,(resultcnt+ 10))
   ENDIF
   reply->event_id_list[resultcnt].event_id = rsl.event_id
  FOOT REPORT
   stat = alterlist(reply->event_id_list,resultcnt)
 ;end select
 SET error_code = error(error_msg,0)
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
#exit_script
END GO
