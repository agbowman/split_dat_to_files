CREATE PROGRAM dcp_get_trans_relate_event_cds:dba
 RECORD request(
   1 transfer_type_cd = f8
   1 qual[*]
     2 source_event_cd = f8
     2 associated_identifier_cd = f8
 )
 RECORD reply(
   1 transfer_type_cd = f8
   1 qual[*]
     2 target_event_cd = f8
     2 source_event_cd = f8
     2 associated_identifier_cd = f8
   1 status_data
     2 status = c1
 )
 DECLARE num = i4 WITH noconstant(0)
 DECLARE index = i4 WITH noconstant(0)
 DECLARE nstart = i4 WITH noconstant(1)
 DECLARE batch_size = i4 WITH constant(25)
 SET cur_list_size = size(request->qual,5)
 SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
 SET new_list_size = (loop_cnt * batch_size)
 SET stat = alterlist(reply->qual,new_list_size)
 SET reply->status_data.status = "F"
 SET reply->transfer_type_cd = request->transfer_type_cd
 FOR (idx = 1 TO cur_list_size)
  SET reply->qual[idx].source_event_cd = request->qual[idx].source_event_cd
  SET reply->qual[idx].associated_identifier_cd = request->qual[idx].associated_identifier_cd
 ENDFOR
 FOR (idx = (cur_list_size+ 1) TO new_list_size)
  SET reply->qual[idx].source_event_cd = reply->qual[cur_list_size].source_event_cd
  SET reply->qual[idx].associated_identifier_cd = reply->qual[cur_list_size].associated_identifier_cd
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(loop_cnt)),
   dcp_cf_trans_event_cd_r r
  PLAN (d1
   WHERE assign(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
   JOIN (r
   WHERE expand(num,nstart,(nstart+ (batch_size - 1)),r.source_event_cd,reply->qual[num].
    source_event_cd,
    r.association_identifier_cd,reply->qual[num].associated_identifier_cd)
    AND (r.cf_transfer_type_cd=reply->transfer_type_cd)
    AND r.active_ind=1)
  HEAD REPORT
   index = 0
  DETAIL
   index = locateval(num,1,cur_list_size,r.source_event_cd,reply->qual[num].source_event_cd,
    r.association_identifier_cd,reply->qual[num].associated_identifier_cd), reply->qual[index].
   target_event_cd = r.target_event_cd
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->qual,cur_list_size)
 IF (cur_list_size=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(request)
 CALL echorecord(reply)
END GO
