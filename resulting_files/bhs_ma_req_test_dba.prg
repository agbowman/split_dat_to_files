CREATE PROGRAM bhs_ma_req_test:dba
 PROMPT
  "PRINTER " = "MINE",
  "ORDER_ID " = 1554616,
  "Object Name = " = "BHSREQ6_1"
 FREE SET request
 FREE RECORD request
 RECORD request(
   1 person_id = f8
   1 print_prsnl_id = f8
   1 order_qual[2]
     2 order_id = f8
     2 encntr_id = f8
     2 conversation_id = f8
   1 printer_name = c50
 )
 SET request->order_qual[1].order_id =  $2
 SELECT INTO "nl:"
  FROM orders o
  WHERE (o.order_id= $2)
  DETAIL
   request->order_qual[1].encntr_id = o.encntr_id, request->person_id = o.person_id
  WITH nocounter
 ;end select
 SET request->printer_name =  $1
 EXECUTE value( $3)
END GO
