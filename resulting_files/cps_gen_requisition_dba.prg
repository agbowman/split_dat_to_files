CREATE PROGRAM cps_gen_requisition:dba
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 IF ( NOT (validate(reply,0)))
  FREE SET reply
  RECORD reply(
    1 node = vc
    1 print_qual[*]
      2 requisition_object_name = vc
      2 output_file_name = vc
      2 output_dest_cd = f8
      2 printer_name = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 IF ( NOT (validate(req_reply,0)))
  FREE SET req_reply
  RECORD req_reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 IF ( NOT (validate(req_request,0)))
  FREE SET req_request
  RECORD req_request(
    1 person_id = f8
    1 print_prsnl_id = f8
    1 order_qual[*]
      2 order_id = f8
      2 encntr_id = f8
      2 conversation_id = f8
    1 printer_name = vc
  )
 ENDIF
 IF ( NOT (validate(temp_struct,0)))
  FREE SET temp_struct
  RECORD temp_struct(
    1 person_qual[*]
      2 person_id = f8
      2 qual[*]
        3 object_name = vc
        3 output_dest_cd = f8
        3 printer_name = vc
        3 order_qual[*]
          4 order_id = f8
          4 encntr_id = f8
  )
 ENDIF
 DECLARE piter = i4 WITH noconstant(0)
 DECLARE oiter = i4 WITH noconstant(0)
 DECLARE temp_status = c1 WITH protect
 DECLARE printer_cnt = i4 WITH noconstant(0)
 DECLARE replycnt = i4 WITH protect, noconstant(0)
 SET modify = skipsrvmsg
 SET reply->status_data.status = "F"
 IF ((request->person_id > 0.0))
  SET piter = 1
  SET stat = alterlist(temp_struct->person_qual,piter)
  SET temp_struct->person_qual[piter].person_id = request->person_id
  SELECT INTO "nl:"
   req = build(request->order_qual[d.seq].requisition_object_name,"_",request->order_qual[d.seq].
    fax_ind), printer = substring(1,255,request->order_qual[d.seq].printer_name)
   FROM (dummyt d  WITH seq = value(size(request->order_qual,5)))
   PLAN (d
    WHERE (request->order_qual[d.seq].order_id > 0))
   ORDER BY req, printer
   HEAD REPORT
    req_dummy = 0, printer_cnt = 0
   HEAD req
    req_dummy += 1
   HEAD printer
    printer_cnt += 1, oiter = 0, stat = alterlist(temp_struct->person_qual[piter].qual,printer_cnt),
    stat = alterlist(reply->print_qual,printer_cnt), temp_struct->person_qual[piter].qual[printer_cnt
    ].object_name = request->order_qual[d.seq].requisition_object_name, temp_struct->person_qual[
    piter].qual[printer_cnt].printer_name = request->order_qual[d.seq].printer_name
    IF ((request->order_qual[d.seq].fax_ind=0))
     temp_struct->person_qual[piter].qual[printer_cnt].output_dest_cd = request->order_qual[d.seq].
     output_dest_cd
    ELSEIF ((request->order_qual[d.seq].fax_ind=1))
     temp_struct->person_qual[piter].qual[printer_cnt].output_dest_cd = - (1)
    ELSE
     temp_status = "F", reply->status_data.status = temp_status, reply->status_data.subeventstatus[1]
     .operationname = "Set Output Destination",
     reply->status_data.subeventstatus[1].operationstatus = temp_status, reply->status_data.
     subeventstatus[1].targetobjectname = "fax_ind", reply->status_data.subeventstatus[1].
     targetobjectvalue = build(request->order_qual[d.seq].fax_ind)
    ENDIF
   DETAIL
    oiter += 1, stat = alterlist(temp_struct->person_qual[piter].qual[printer_cnt].order_qual,oiter),
    temp_struct->person_qual[piter].qual[printer_cnt].order_qual[oiter].order_id = request->
    order_qual[d.seq].order_id,
    temp_struct->person_qual[piter].qual[printer_cnt].order_qual[oiter].encntr_id = request->
    order_qual[d.seq].encntr_id
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   req = build(request->order_qual[d.seq].requisition_object_name,"_",request->order_qual[d.seq].
    fax_ind), printer = substring(1,255,request->order_qual[d.seq].printer_name), person = o
   .person_id
   FROM (dummyt d  WITH seq = value(size(request->order_qual,5))),
    orders o
   PLAN (d)
    JOIN (o
    WHERE (o.order_id=request->order_qual[d.seq].order_id))
   ORDER BY o.person_id, req, printer
   HEAD person
    piter += 1, stat = alterlist(temp_struct->person_qual,piter), temp_struct->person_qual[piter].
    person_id = person,
    replycnt += printer_cnt, req_dummy = 0, printer_cnt = 0
   HEAD req
    req_dummy += 1
   HEAD printer
    printer_cnt += 1, oiter = 0, stat = alterlist(temp_struct->person_qual[piter].qual,printer_cnt),
    stat = alterlist(reply->print_qual,(replycnt+ printer_cnt)), temp_struct->person_qual[piter].
    qual[printer_cnt].object_name = request->order_qual[d.seq].requisition_object_name, temp_struct->
    person_qual[piter].qual[printer_cnt].printer_name = request->order_qual[d.seq].printer_name
    IF ((request->order_qual[d.seq].fax_ind=0))
     temp_struct->person_qual[piter].qual[printer_cnt].output_dest_cd = request->order_qual[d.seq].
     output_dest_cd
    ELSEIF ((request->order_qual[d.seq].fax_ind=1))
     temp_struct->person_qual[piter].qual[printer_cnt].output_dest_cd = - (1)
    ELSE
     temp_status = "F", reply->status_data.status = temp_status, reply->status_data.subeventstatus[1]
     .operationname = "Set Output Destination",
     reply->status_data.subeventstatus[1].operationstatus = temp_status, reply->status_data.
     subeventstatus[1].targetobjectname = "fax_ind", reply->status_data.subeventstatus[1].
     targetobjectvalue = build(request->order_qual[d.seq].fax_ind)
    ENDIF
   DETAIL
    oiter += 1, stat = alterlist(temp_struct->person_qual[piter].qual[printer_cnt].order_qual,oiter),
    temp_struct->person_qual[piter].qual[printer_cnt].order_qual[oiter].order_id = request->
    order_qual[d.seq].order_id,
    temp_struct->person_qual[piter].qual[printer_cnt].order_qual[oiter].encntr_id = request->
    order_qual[d.seq].encntr_id
   WITH nocounter
  ;end select
 ENDIF
 DECLARE strfilename = vc WITH protect
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE x_cnt = i4 WITH protect, noconstant(0)
 DECLARE y_cnt = i4 WITH protect, noconstant(0)
 DECLARE z_cnt = i4 WITH protect, noconstant(0)
 SET reply->node = curnode
 FOR (piter = 1 TO value(size(temp_struct->person_qual,5)))
   SET replycnt = value(size(reply->print_qual,5))
   SET cnt = value(size(temp_struct->person_qual[piter].qual,5))
   FOR (x_cnt = 1 TO cnt)
     FREE SET req_request
     RECORD req_request(
       1 person_id = f8
       1 print_prsnl_id = f8
       1 order_qual[*]
         2 order_id = f8
         2 encntr_id = f8
         2 conversation_id = f8
       1 printer_name = vc
     )
     SET z_cnt += 1
     SET req_request->person_id = temp_struct->person_qual[piter].person_id
     SET req_request->print_prsnl_id = request->print_prsnl_id
     SET order_cnt = value(size(temp_struct->person_qual[piter].qual[x_cnt].order_qual,5))
     SET stat = alterlist(req_request->order_qual,order_cnt)
     FOR (y_cnt = 1 TO order_cnt)
      SET req_request->order_qual[y_cnt].order_id = temp_struct->person_qual[piter].qual[x_cnt].
      order_qual[y_cnt].order_id
      SET req_request->order_qual[y_cnt].encntr_id = temp_struct->person_qual[piter].qual[x_cnt].
      order_qual[y_cnt].encntr_id
     ENDFOR
     IF ((temp_struct->person_qual[piter].qual[x_cnt].output_dest_cd >= 0)
      AND x_cnt <= replycnt)
      EXECUTE cpm_create_file_name "rxreq", "dat"
      SET req_request->printer_name = cpm_cfn_info->file_name_full_path
      SET reply->print_qual[z_cnt].output_file_name = cpm_cfn_info->file_name_full_path
      SET reply->print_qual[z_cnt].output_dest_cd = temp_struct->person_qual[piter].qual[x_cnt].
      output_dest_cd
      SET reply->print_qual[z_cnt].printer_name = temp_struct->person_qual[piter].qual[x_cnt].
      printer_name
      SET reply->print_qual[z_cnt].requisition_object_name = temp_struct->person_qual[piter].qual[
      x_cnt].object_name
     ENDIF
     SET strfilename = concat("execute ",temp_struct->person_qual[piter].qual[x_cnt].object_name,
      " with replace('REQUEST', 'REQ_REQUEST')",", replace('REPLY', 'REQ_REPLY')"," go")
     CALL echo(strfilename)
     SET trace = recpersist
     CALL parser(strfilename)
     IF (temp_status != "S")
      IF (req_reply="S")
       SET temp_status = "S"
      ENDIF
     ENDIF
     SET trace = norecpersist
   ENDFOR
 ENDFOR
 SET modify = noskipsrvmsg
 SET modify = nopredeclare
 SET reply->status_data.status = temp_status
 SET script_ver = "004 10/31/07 NB016599"
END GO
