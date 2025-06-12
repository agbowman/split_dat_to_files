CREATE PROGRAM bhs_req_bbt_tst
 DECLARE call_program = vc WITH public
 SET call_program = "BHS_REQ_BBT"
 IF ( NOT (validate(request)))
  FREE RECORD request
  RECORD request(
    1 person_id = f8
    1 print_prsnl_id = f8
    1 order_qual[*]
      2 order_id = f8
      2 encntr_id = f8
      2 conversation_id = f8
    1 printer_name = c50
  )
  SET stat = alterlist(request->order_qual,1)
  SET request->person_id = 18756781
  SET request->order_qual[1].encntr_id = 50018505
  SET request->order_qual[1].order_id = 1122399307
  SET request->printer_name = "bmc155adm1"
 ENDIF
 EXECUTE bhs_req_04_layout call_program
END GO
