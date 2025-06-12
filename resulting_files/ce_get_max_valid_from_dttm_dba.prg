CREATE PROGRAM ce_get_max_valid_from_dttm:dba
 DECLARE reply_cnt = i4 WITH noconstant(0)
 DECLARE idx = i4
 DECLARE new_list_size = i4
 DECLARE cur_list_size = i4
 DECLARE batch_size = i4 WITH constant(20)
 DECLARE nstart = i4
 DECLARE loop_cnt = i4
 DECLARE server_date = dq8 WITH protect, noconstant(validate(request->current_dt_tm,cnvtdatetime((
    curdate - 7),curtime3)))
 SET server_date = evaluate(server_date,0.0,cnvtdatetime((curdate - 7),curtime3),server_date)
 SET reply->max_valid_from_dt_tm = cnvtdatetime("1-jan-1800 00:00:00")
 SET cur_list_size = size(request->req_list,5)
 SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
 SET new_list_size = (loop_cnt * batch_size)
 SET nstart = 1
 SET num1 = 0
 SET stat = alterlist(request->req_list,new_list_size)
 IF (cur_list_size <= 0)
  GO TO exit_script
 ENDIF
 SET error_msg = fillstring(255," ")
 SET error_code = 0
 FOR (idx = (cur_list_size+ 1) TO new_list_size)
   SET request->req_list[idx].person_id = request->req_list[cur_list_size].person_id
 ENDFOR
 SELECT
  IF (cur_list_size=1)
   FROM clinical_event ce
   WHERE (ce.person_id=request->req_list[1].person_id)
    AND ce.valid_from_dt_tm >= cnvtdatetimeutc(server_date)
  ELSE
   FROM (dummyt d1  WITH seq = value(loop_cnt)),
    clinical_event ce
   PLAN (d1
    WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
    JOIN (ce
    WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),ce.person_id,request->req_list[idx].person_id)
     AND ce.valid_from_dt_tm >= cnvtdatetimeutc(server_date))
   ORDER BY maxdate DESC
  ENDIF
  INTO "nl:"
  maxdate = max(ce.valid_from_dt_tm)
  HEAD REPORT
   reply->max_valid_from_dt_tm = maxdate
  WITH nocounter
 ;end select
 SET error_code = error(error_msg,0)
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
#exit_script
END GO
