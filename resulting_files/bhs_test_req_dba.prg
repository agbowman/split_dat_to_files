CREATE PROGRAM bhs_test_req:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Requisition Name" = "",
  "Queue Name" = "",
  "Patient Account #" = ""
  WITH outdev, prompt1, prompt2,
  prompt3
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
 SELECT INTO "nl:"
  FROM encntr_alias ea
  PLAN (ea
   WHERE ea.alias=trim( $4)
    AND ea.encntr_alias_type_cd=1077
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > sysdate)
  HEAD REPORT
   stat = alterlist(request->order_qual,1), request->order_qual[1].encntr_id = ea.encntr_id, request
   ->printer_name = trim( $3)
  WITH nocounter
 ;end select
END GO
