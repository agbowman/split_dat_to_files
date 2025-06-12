CREATE PROGRAM ce_get_intake_output_result:dba
 DECLARE idx = i4 WITH noconstant(0)
 DECLARE nstart = i4 WITH noconstant(1)
 DECLARE nsize = i4 WITH constant(50)
 DECLARE ntotal2 = i4 WITH noconstant(0)
 DECLARE ntotal = i4 WITH noconstant(0)
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE error_msg = vc WITH noconstant(" ")
 DECLARE error_code = i4 WITH noconstant(0)
 DECLARE iorvalidfromdttm = vc WITH public, noconstant("0=0")
 DECLARE iorvaliduntildttm = vc WITH public, noconstant("0=0")
 IF ((request->all_versions=0))
  IF ((request->valid_from_dt_tm_ind=0))
   SET iorvalidfromdttm = " ior.valid_from_dt_tm <= cnvtdatetimeutc(request->valid_from_dt_tm) "
  ENDIF
  SET iorvaliduntildttm = " ior.valid_until_dt_tm >= cnvtdatetimeutc(request->valid_from_dt_tm) "
 ENDIF
 SET ntotal2 = size(request->event_list,5)
 SET ntotal = (ceil((cnvtreal(ntotal2)/ nsize)) * nsize)
 SET stat = alterlist(request->event_list,ntotal)
 FOR (idx = (ntotal2+ 1) TO ntotal)
   SET request->event_list[idx].event_id = request->event_list[ntotal2].event_id
 ENDFOR
 SELECT INTO "nl:"
  ior.ce_io_result_id, io_start_dt_tm_ind = nullind(ior.io_start_dt_tm), io_end_dt_tm_ind = nullind(
   ior.io_end_dt_tm),
  valid_from_dt_tm_ind = nullind(ior.valid_from_dt_tm), valid_until_dt_tm_ind = nullind(ior
   .valid_until_dt_tm), updt_dt_tm_ind = nullind(ior.updt_dt_tm),
  updt_task_ind = nullind(ior.updt_task), updt_cnt_ind = nullind(ior.updt_cnt), updt_applctx_ind =
  nullind(ior.updt_applctx)
  FROM ce_intake_output_result ior,
   (dummyt d  WITH seq = value((1+ ((ntotal - 1)/ nsize))))
  PLAN (d
   WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nsize))))
   JOIN (ior
   WHERE expand(idx,nstart,(nstart+ (nsize - 1)),ior.event_id,request->event_list[idx].event_id)
    AND parser(iorvaliduntildttm)
    AND parser(iorvalidfromdttm))
  DETAIL
   cnt += 1
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->reply_list,(cnt+ 9))
   ENDIF
   reply->reply_list[cnt].ce_io_result_id = ior.ce_io_result_id, reply->reply_list[cnt].io_result_id
    = ior.io_result_id, reply->reply_list[cnt].event_id = ior.event_id,
   reply->reply_list[cnt].person_id = ior.person_id, reply->reply_list[cnt].encntr_id = ior.encntr_id,
   reply->reply_list[cnt].io_start_dt_tm = ior.io_start_dt_tm,
   reply->reply_list[cnt].io_start_dt_tm_ind = io_start_dt_tm_ind, reply->reply_list[cnt].
   io_end_dt_tm = ior.io_end_dt_tm, reply->reply_list[cnt].io_end_dt_tm_ind = io_end_dt_tm_ind,
   reply->reply_list[cnt].io_type_flag = ior.io_type_flag, reply->reply_list[cnt].io_volume = ior
   .io_volume, reply->reply_list[cnt].io_status_cd = ior.io_status_cd,
   reply->reply_list[cnt].reference_event_id = ior.reference_event_id, reply->reply_list[cnt].
   reference_event_cd = ior.reference_event_cd, reply->reply_list[cnt].valid_from_dt_tm = ior
   .valid_from_dt_tm,
   reply->reply_list[cnt].valid_from_dt_tm_ind = valid_from_dt_tm_ind, reply->reply_list[cnt].
   valid_until_dt_tm = ior.valid_until_dt_tm, reply->reply_list[cnt].valid_until_dt_tm_ind =
   valid_until_dt_tm_ind,
   reply->reply_list[cnt].updt_dt_tm = ior.updt_dt_tm, reply->reply_list[cnt].updt_dt_tm_ind =
   updt_dt_tm_ind, reply->reply_list[cnt].updt_id = ior.updt_id,
   reply->reply_list[cnt].updt_task = ior.updt_task, reply->reply_list[cnt].updt_task_ind =
   updt_task_ind, reply->reply_list[cnt].updt_cnt = ior.updt_cnt,
   reply->reply_list[cnt].updt_cnt_ind = updt_cnt_ind, reply->reply_list[cnt].updt_applctx = ior
   .updt_applctx, reply->reply_list[cnt].updt_applctx_ind = updt_applctx_ind
  WITH nocounter
 ;end select
 SET reply->qual = cnt
 SET error_code = error(error_msg,0)
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
 SET stat = alterlist(reply->reply_list,cnt)
END GO
