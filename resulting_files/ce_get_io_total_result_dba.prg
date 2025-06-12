CREATE PROGRAM ce_get_io_total_result:dba
 DECLARE idx = i4 WITH noconstant(0)
 DECLARE nstart = i4 WITH noconstant(1)
 DECLARE nsize = i4 WITH constant(50)
 DECLARE ntotal2 = i4 WITH noconstant(0)
 DECLARE ntotal = i4 WITH noconstant(0)
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE error_msg = vc WITH noconstant(" ")
 DECLARE error_code = i4 WITH noconstant(0)
 DECLARE iotrvalidfromdttm = vc WITH public, noconstant("0=0")
 DECLARE iotrvaliduntildttm = vc WITH public, noconstant("0=0")
 IF ((request->all_versions=0))
  IF ((request->valid_from_dt_tm_ind=0))
   SET iotrvalidfromdttm = " iotr.valid_from_dt_tm <= cnvtdatetimeutc(request->valid_from_dt_tm) "
  ENDIF
  SET iotrvaliduntildttm = " iotr.valid_until_dt_tm >= cnvtdatetimeutc(request->valid_from_dt_tm) "
 ENDIF
 SET ntotal2 = size(request->event_list,5)
 SET ntotal = (ceil((cnvtreal(ntotal2)/ nsize)) * nsize)
 SET stat = alterlist(request->event_list,ntotal)
 FOR (idx = (ntotal2+ 1) TO ntotal)
   SET request->event_list[idx].event_id = request->event_list[ntotal2].event_id
 ENDFOR
 SELECT INTO "nl:"
  iotr.ce_io_total_result_id, updt_dt_tm_ind = nullind(iotr.updt_dt_tm), updt_task_ind = nullind(iotr
   .updt_task),
  updt_cnt_ind = nullind(iotr.updt_cnt), updt_applctx_ind = nullind(iotr.updt_applctx)
  FROM ce_io_total_result iotr,
   (dummyt d  WITH seq = value((1+ ((ntotal - 1)/ nsize))))
  PLAN (d
   WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nsize))))
   JOIN (iotr
   WHERE expand(idx,nstart,(nstart+ (nsize - 1)),iotr.event_id,request->event_list[idx].event_id)
    AND parser(iotrvaliduntildttm)
    AND parser(iotrvalidfromdttm))
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->reply_list,(cnt+ 9))
   ENDIF
   reply->reply_list[cnt].ce_io_total_result_id = iotr.ce_io_total_result_id, reply->reply_list[cnt].
   io_total_definition_id = iotr.io_total_definition_id, reply->reply_list[cnt].event_id = iotr
   .event_id,
   reply->reply_list[cnt].encntr_id = iotr.encntr_id, reply->reply_list[cnt].encntr_focused_ind =
   iotr.encntr_focused_ind, reply->reply_list[cnt].person_id = iotr.person_id,
   reply->reply_list[cnt].io_total_start_dt_tm = iotr.io_total_start_dt_tm, reply->reply_list[cnt].
   io_total_end_dt_tm = iotr.io_total_end_dt_tm, reply->reply_list[cnt].io_total_value = iotr
   .io_total_value,
   reply->reply_list[cnt].io_total_result_val = iotr.io_total_result_val, reply->reply_list[cnt].
   io_total_unit_cd = iotr.io_total_unit_cd, reply->reply_list[cnt].suspect_flag = iotr.suspect_flag,
   reply->reply_list[cnt].last_io_result_clinsig_dt_tm = iotr.last_io_result_clinsig_dt_tm, reply->
   reply_list[cnt].valid_from_dt_tm = iotr.valid_from_dt_tm, reply->reply_list[cnt].valid_until_dt_tm
    = iotr.valid_until_dt_tm,
   reply->reply_list[cnt].updt_dt_tm = iotr.updt_dt_tm, reply->reply_list[cnt].updt_dt_tm_ind =
   updt_dt_tm_ind, reply->reply_list[cnt].updt_id = iotr.updt_id,
   reply->reply_list[cnt].updt_task = iotr.updt_task, reply->reply_list[cnt].updt_task_ind =
   updt_task_ind, reply->reply_list[cnt].updt_cnt = iotr.updt_cnt,
   reply->reply_list[cnt].updt_cnt_ind = updt_cnt_ind, reply->reply_list[cnt].updt_applctx = iotr
   .updt_applctx, reply->reply_list[cnt].updt_applctx_ind = updt_applctx_ind
  WITH nocounter
 ;end select
 SET reply->qual = cnt
 SET error_code = error(error_msg,0)
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
 SET stat = alterlist(reply->reply_list,cnt)
END GO
