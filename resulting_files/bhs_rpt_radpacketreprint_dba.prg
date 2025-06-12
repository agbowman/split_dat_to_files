CREATE PROGRAM bhs_rpt_radpacketreprint:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Accession(enter accession same as example)" = "00000RA20040000001",
  "Script Name" = "bhsmaradreq",
  "Prints to" = 21399347.00
  WITH outdev, accession, script_name,
  s_prints_to
 EXECUTE reportrtl
 DECLARE mf_cs14192_ordered = f8 WITH constant(uar_get_code_by("MEANING",14192,"RADORDERED")),
 protect
 DECLARE mf_cs14192_inprocess = f8 WITH constant(uar_get_code_by("DISPLAYKEY",14192,"INPROCESS")),
 protect
 DECLARE mf_cs14192_completed = f8 WITH constant(uar_get_code_by("DISPLAYKEY",14192,"COMPLETED")),
 protect
 FREE RECORD request
 IF ( NOT (validate(request,0)))
  CALL echo("request structure did not exist")
  RECORD request(
    1 qual[1]
      2 packet_id = f8
      2 print_info[1]
        3 program_name = c20
        3 output_dest_cd = f8
        3 print_que = c20
        3 printer_dio = c20
    1 order_id = f8
    1 batch_selection = vc
    1 cur_fut_ind = vc
    1 order_id = f8
    1 order_packet_flag = i2
    1 print_point_cd = f8
    1 modified_ord_ind = i2
  )
 ELSE
  CALL echo("request structure existed")
  CALL echo(build("packet_id :",request->qual[1].packet_id))
 ENDIF
 IF ( NOT (validate(working_array,0)))
  RECORD working_array(
    1 reprint_flag = c1
    1 print_flag = c1
    1 debug_flag = c1
    1 from_prg = c1
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 ops_event = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET working_array->print_flag = "Y"
 SET working_array->reprint_flag = "Y"
 SET working_array->debug_flag = "Y"
 SET working_array->from_prg = "R"
 SELECT
  o.order_id, o.person_id, o.encntr_id,
  r.packet_id
  FROM order_radiology o,
   rad_packet r
  PLAN (o
   WHERE (o.accession= $ACCESSION)
    AND o.exam_status_cd IN (mf_cs14192_ordered, mf_cs14192_completed, mf_cs14192_inprocess))
   JOIN (r
   WHERE r.order_id=o.order_id)
  DETAIL
   request->qual[1].packet_id = r.packet_id, request->qual[1].print_info[1].program_name =
    $SCRIPT_NAME, request->qual[1].print_info[1].output_dest_cd =  $S_PRINTS_TO,
   request->qual[1].print_info[1].printer_dio = "8", request->order_id = o.order_id
  WITH nocounter
 ;end select
 SET request->order_packet_flag = 1
 IF (curqual > 0)
  EXECUTE rad_rpt_packet_reprint
 ELSE
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = "Exam Status must be Ordered, Complete or In Process", col 0,
    "{PS/792 0 translate 90 rotate/}",
    y_pos = 18, row + 1, "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1
   WITH dio = 08
  ;end select
 ENDIF
 CALL echo(build("status: ",reply->status_data.status))
END GO
