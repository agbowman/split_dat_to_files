CREATE PROGRAM cpmnotify_dcp_adt_alerts:dba
 SET exec_time = cnvtdatetime(curdate,curtime3)
 IF (validate(debug_ind,0) != 1)
  SET debug_ind = 0
 ENDIF
 RECORD reply(
   1 run_dt_tm = dq8
   1 overlay_ind = i2
   1 entity_list[*]
     2 entity_id = f8
     2 data_cnt = i4
     2 datalist[*]
       3 hint_id = f8
       3 hint_dt_tm = dq8
       3 location_cd = f8
       3 hint_type_cd = f8
       3 hint_processing_cd = f8
       3 name_full_formatted = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE act = f8 WITH protect, constant(uar_get_code_by("MEANING",359576,"ACT"))
 DECLARE defer = f8 WITH protect, constant(uar_get_code_by("MEANING",359576,"DEFER"))
 DECLARE batch_size = i4 WITH protect, constant(20)
 DECLARE cur_list_size = i4 WITH protect, noconstant(size(request->entity_list,5))
 DECLARE new_list_size = i4 WITH protect, noconstant(0)
 DECLARE x = i4 WITH protect, noconstant(1)
 DECLARE ex_cnt = i4 WITH protect, noconstant(0)
 DECLARE ex_idx = i4 WITH protect, noconstant(0)
 DECLARE ev_idx = i4 WITH protect, noconstant(0)
 DECLARE pn_idx = i4 WITH protect, noconstant(0)
 DECLARE data_cnt = i4 WITH protect, noconstant(0)
 IF (cur_list_size=0)
  GO TO exit_program
 ENDIF
 SET ex_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
 SET new_list_size = (ex_cnt * batch_size)
 SET stat = alterlist(request->entity_list,new_list_size)
 SET stat = alterlist(reply->entity_list,new_list_size)
 FOR (ex_idx = 1 TO new_list_size)
   IF (ex_idx > cur_list_size)
    SET request->entity_list[ex_idx].entity_id = request->entity_list[cur_list_size].entity_id
    SET reply->entity_list[ex_idx].entity_id = request->entity_list[cur_list_size].entity_id
   ELSE
    SET reply->entity_list[ex_idx].entity_id = request->entity_list[ex_idx].entity_id
   ENDIF
 ENDFOR
 IF (debug_ind=1)
  CALL echorecord(request)
 ENDIF
 SET reply->overlay_ind = 1
 SET reply->run_dt_tm = cnvtdatetime(curdate,curtime3)
 SELECT INTO "nl:"
  bah.hint_id, bah.hint_dt_tm, bah.location_cd,
  bah.hint_type_cd, bah.hint_processing_cd
  FROM (dummyt d1  WITH seq = value(ex_cnt)),
   bmdi_association_hints bah
  PLAN (d1
   WHERE initarray(x,evaluate(d1.seq,1,1,(x+ batch_size))))
   JOIN (bah
   WHERE expand(ex_idx,x,(x+ (batch_size - 1)),bah.person_id,request->entity_list[ex_idx].entity_id)
    AND bah.hint_processing_cd IN (act, defer)
    AND bah.active_ind=1)
  ORDER BY bah.person_id
  HEAD bah.person_id
   pn_idx = locateval(ev_idx,1,cur_list_size,bah.person_id,request->entity_list[ev_idx].entity_id),
   data_cnt = 0
  DETAIL
   data_cnt = (data_cnt+ 1)
   IF (mod(data_cnt,5)=1)
    stat = alterlist(reply->entity_list[pn_idx].datalist,(data_cnt+ 4))
   ENDIF
   reply->entity_list[pn_idx].datalist[data_cnt].hint_id = bah.hint_id, reply->entity_list[pn_idx].
   datalist[data_cnt].hint_dt_tm = cnvtdatetime(bah.hint_dt_tm), reply->entity_list[pn_idx].datalist[
   data_cnt].location_cd = bah.location_cd,
   reply->entity_list[pn_idx].datalist[data_cnt].hint_type_cd = bah.hint_type_cd, reply->entity_list[
   pn_idx].datalist[data_cnt].hint_processing_cd = bah.hint_processing_cd
  FOOT  bah.person_id
   reply->entity_list[pn_idx].data_cnt = data_cnt, stat = alterlist(reply->entity_list[pn_idx].
    datalist,data_cnt)
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->entity_list,cur_list_size)
 FOR (ex_idx = 1 TO cur_list_size)
   IF ((reply->entity_list[ex_idx].data_cnt=0))
    SET stat = alterlist(reply->entity_list[ex_idx].datalist,1)
    SET reply->entity_list[ex_idx].datalist[1].hint_id = - (1.0)
    SET reply->entity_list[ex_idx].datalist[1].hint_dt_tm = cnvtdatetime(curdate,curtime3)
   ENDIF
 ENDFOR
 SET reply->status_data.status = "S"
#exit_program
 IF (debug_ind=1)
  CALL echorecord(reply)
  CALL echo(build("EXECUTION TIME IN SECONDS: ",datetimediff(cnvtdatetime(curdate,curtime3),exec_time,
     5)))
 ENDIF
END GO
