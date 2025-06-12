CREATE PROGRAM bhsreq7_tst:dba
 FREE RECORD request
 RECORD request(
   1 person_id = f8
   1 print_prsnl_id = f8
   1 order_qual[1]
     2 order_id = f8
     2 encntr_id = f8
     2 conversation_id = f8
   1 printer_name = c50
 )
 SELECT INTO "nl:"
  FROM orders o
  PLAN (o
   WHERE o.order_id=5454961853.0)
  HEAD REPORT
   request->person_id = o.person_id, request->print_prsnl_id = reqinfo->updt_id, request->order_qual[
   1].order_id = o.order_id,
   request->order_qual[1].encntr_id = o.encntr_id
  WITH nocounter
 ;end select
 SET request->printer_name = "BMCWH1GIM4"
 SET trace = recpersist
 EXECUTE bhsreq7_2
 SET trace = norecpersist
END GO
