CREATE PROGRAM ce_get_string_result:dba
 DECLARE srvalidfromdttm = vc WITH public, noconstant("0=0")
 DECLARE srvaliduntildttm = vc WITH public, noconstant("0=0")
 IF ((request->all_versions=0))
  IF ((request->valid_from_dt_tm_ind=0))
   SET srvalidfromdttm = " sr.valid_from_dt_tm <= cnvtdatetimeutc(request->valid_from_dt_tm) "
  ENDIF
  SET srvaliduntildttm = " sr.valid_until_dt_tm >= cnvtdatetimeutc(request->valid_from_dt_tm) "
 ENDIF
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE idx = i4
 DECLARE ntotal = i4
 DECLARE ntotal2 = i4
 DECLARE nsize = i4 WITH constant(50)
 DECLARE nstart = i4 WITH noconstant(1)
 DECLARE error_msg = vc WITH noconstant(" ")
 DECLARE error_code = i4 WITH noconstant(0)
 SET ntotal2 = value(size(request->event_list,5))
 SET ntotal = (ceil((cnvtreal(ntotal2)/ nsize)) * nsize)
 SET stat = alterlist(request->event_list,ntotal)
 FOR (idx = (ntotal2+ 1) TO ntotal)
   SET request->event_list[idx].event_id = request->event_list[ntotal2].event_id
 ENDFOR
 SELECT INTO "nl:"
  sr.event_id, sr.valid_from_dt_tm, valid_from_dt_tm_ind = nullind(sr.valid_from_dt_tm),
  sr.valid_until_dt_tm, valid_until_dt_tm_ind = nullind(sr.valid_until_dt_tm), sr.string_result_text,
  sr.string_result_format_cd, sr.equation_id, sr.last_norm_dt_tm,
  last_norm_dt_tm_ind = nullind(sr.last_norm_dt_tm), sr.unit_of_measure_cd, sr.feasible_ind,
  feasible_ind_ind = nullind(sr.feasible_ind), sr.inaccurate_ind, inaccurate_ind_ind = nullind(sr
   .inaccurate_ind),
  sr.updt_dt_tm, updt_dt_tm_ind = nullind(sr.updt_dt_tm), sr.updt_id,
  sr.updt_task, updt_task_ind = nullind(sr.updt_task), sr.updt_cnt,
  updt_cnt_ind = nullind(sr.updt_cnt), sr.updt_applctx, updt_applctx_ind = nullind(sr.updt_applctx),
  sr.calculation_equation, sr.string_long_text_id
  FROM (dummyt d1  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
   ce_string_result sr,
   long_text lt
  PLAN (d1
   WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ nsize))))
   JOIN (sr
   WHERE expand(idx,nstart,(nstart+ (nsize - 1)),sr.event_id,request->event_list[idx].event_id)
    AND parser(srvaliduntildttm)
    AND parser(srvalidfromdttm))
   JOIN (lt
   WHERE sr.string_long_text_id=lt.long_text_id)
  HEAD REPORT
   outbuf = fillstring(32000,""), retlen = 0, offset = 0
  DETAIL
   cnt += 1
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->reply_list,(cnt+ 9))
   ENDIF
   IF (sr.string_long_text_id=0)
    reply->reply_list[cnt].string_result_text = sr.string_result_text
   ELSE
    offset = 0, retlen = 1
    WHILE (retlen > 0)
      retlen = blobget(outbuf,offset,lt.long_text), reply->reply_list[cnt].string_result_text =
      concat(reply->reply_list[cnt].string_result_text,outbuf), offset += 32000
    ENDWHILE
   ENDIF
   reply->reply_list[cnt].event_id = sr.event_id, reply->reply_list[cnt].valid_from_dt_tm = sr
   .valid_from_dt_tm, reply->reply_list[cnt].valid_from_dt_tm_ind = valid_from_dt_tm_ind,
   reply->reply_list[cnt].valid_until_dt_tm = sr.valid_until_dt_tm, reply->reply_list[cnt].
   valid_until_dt_tm_ind = valid_until_dt_tm_ind, reply->reply_list[cnt].string_result_format_cd = sr
   .string_result_format_cd,
   reply->reply_list[cnt].equation_id = sr.equation_id, reply->reply_list[cnt].last_norm_dt_tm = sr
   .last_norm_dt_tm, reply->reply_list[cnt].last_norm_dt_tm_ind = last_norm_dt_tm_ind,
   reply->reply_list[cnt].unit_of_measure_cd = sr.unit_of_measure_cd, reply->reply_list[cnt].
   feasible_ind = sr.feasible_ind, reply->reply_list[cnt].feasible_ind_ind = feasible_ind_ind,
   reply->reply_list[cnt].inaccurate_ind = sr.inaccurate_ind, reply->reply_list[cnt].
   inaccurate_ind_ind = inaccurate_ind_ind, reply->reply_list[cnt].updt_dt_tm = sr.updt_dt_tm,
   reply->reply_list[cnt].updt_dt_tm_ind = updt_dt_tm_ind, reply->reply_list[cnt].updt_id = sr
   .updt_id, reply->reply_list[cnt].updt_task = sr.updt_task,
   reply->reply_list[cnt].updt_task_ind = updt_task_ind, reply->reply_list[cnt].updt_cnt = sr
   .updt_cnt, reply->reply_list[cnt].updt_cnt_ind = updt_cnt_ind,
   reply->reply_list[cnt].updt_applctx = sr.updt_applctx, reply->reply_list[cnt].updt_applctx_ind =
   updt_applctx_ind, reply->reply_list[cnt].calculation_equation = sr.calculation_equation,
   reply->reply_list[cnt].string_long_text_id = sr.string_long_text_id
  WITH nocounter, rdbarrayfetch = 1
 ;end select
 SET reply->qual = cnt
 SET error_code = error(error_msg,0)
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
 SET stat = alterlist(reply->reply_list,cnt)
END GO
