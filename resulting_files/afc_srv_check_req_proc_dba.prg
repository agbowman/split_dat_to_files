CREATE PROGRAM afc_srv_check_req_proc:dba
 RECORD reply(
   1 step_qual = i2
   1 step_list[*]
     2 step_id = f8
     2 row_qual = i2
     2 row_list[*]
       3 format_script = vc
       3 request_number = f8
 )
 SET x = 0
 SET stat = alterlist(reply->step_list,request->step_qual)
 SET reply->step_qual = request->step_qual
 FOR (x = 0 TO request->step_qual)
   SET reply->step_list[x].step_id = request->step_list[x].step_id
   SET reply->step_list[x].row_qual = 0
   SET cnt = 0
   SELECT INTO "nl:"
    rp.format_script, rp.request_number
    FROM request_processing rp
    WHERE (destination_step_id=request->step_list[x].step_id)
     AND active_ind=1
    DETAIL
     cnt += 1, reply->step_list[x].row_qual = cnt, stat = alterlist(reply->step_list[x].row_list,cnt),
     reply->step_list[x].row_list[cnt].format_script = rp.format_script, reply->step_list[x].
     row_list[cnt].request_number = rp.request_number
    WITH nocounter
   ;end select
 ENDFOR
END GO
