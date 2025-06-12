CREATE PROGRAM bhs_req_bbt:dba
 DECLARE call_program = vc WITH public
 SET call_program = curprog
 IF (validate(request->template_name))
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
  SET request->person_id = 21927737.00
  SET request->order_qual[1].encntr_id = 174257044
  SET request->order_qual[1].order_id = 1122399307
  SET request->printer_name = "MINE"
 ENDIF
 DECLARE mf_cs16449_perfloc_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "PERFORMINGLOCATIONAMBULATORY"))
 DECLARE mf_cs220_labcorp_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"LABCORP"))
 DECLARE ml_labcorp_ind = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM order_detail od,
   code_value cv
  PLAN (od
   WHERE (od.order_id=request->order_qual[1].order_id)
    AND od.oe_field_id=mf_cs16449_perfloc_cd)
   JOIN (cv
   WHERE cv.code_value=od.oe_field_value)
  ORDER BY od.order_id, od.action_sequence DESC
  HEAD od.order_id
   IF (trim(cv.display_key,3)="LABCORP")
    ml_labcorp_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (ml_labcorp_ind=1)
  EXECUTE bhs_ma_amb_rln_req
  GO TO exit_script
 ENDIF
 EXECUTE bhs_req_04_layout call_program
#exit_script
END GO
