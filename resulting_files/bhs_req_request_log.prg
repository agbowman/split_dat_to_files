CREATE PROGRAM bhs_req_request_log
 DECLARE new_seq = f8
 SELECT INTO "nl:"
  bhsy = seq(bhs_req_request_hx_seq,nextval)"##################;rp0"
  FROM dual
  DETAIL
   new_seq = cnvtreal(bhsy)
  WITH format, counter
 ;end select
 SET ord_cnt = size(request->order_qual,5)
 IF ((request->print_prsnl_id=0))
  SET print_request_flag = 1
 ELSE
  SET print_request_flag = 2
 ENDIF
 IF (validate(reprint_ind,0))
  SET print_request_flag = 3
 ENDIF
 DECLARE i = i4
 INSERT  FROM bhs_req_request_hx
  SET execute_dt_tm = cnvtdatetime(curdate,curtime3), execute_request_flg = print_request_flag,
   execute_request_node = curnode,
   order_cnt = ord_cnt, person_id = request->person_id, printer_name = request->printer_name,
   print_prnl_id = request->print_prsnl_id, req_request_hx_id = new_seq
  WITH nocounter
 ;end insert
 FOR (i = 1 TO ord_cnt)
   INSERT  FROM bhs_req_request_ord_hx
    SET conversation_id = request->order_qual[i].conversation_id, encntr_id = request->order_qual[i].
     encntr_id, order_id = request->order_qual[i].order_id,
     order_num = i, req_request_hx_id = new_seq
    WITH nocounter
   ;end insert
 ENDFOR
 COMMIT
END GO
