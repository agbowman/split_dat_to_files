CREATE PROGRAM bhs_eks_rad_req_alt_print:dba
 FREE RECORD m_request
 RECORD m_request(
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
   1 order_packet_flag = i2
   1 print_point_cd = f8
   1 modified_ord_ind = i2
 )
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
 DECLARE mf_bmceddiagnostic_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",221,
   "BMCEDDIAGNOSTIC"))
 DECLARE mf_requisition_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",5800,"REQUISITION"))
 DECLARE mf_activestatus_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE mf_inactivestatus_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"INACTIVE"))
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_output_dest_cd = f8 WITH protect, noconstant(0.00)
 DECLARE ms_printer = vc WITH protect, noconstant(" ")
 DECLARE ms_radreqscript = vc WITH protect, noconstant(" ")
 SET reqdata->data_status_cd = mf_auth_cd
 SET reqdata->active_status_cd = mf_activestatus_cd
 SET reqdata->inactive_status_cd = mf_inactivestatus_cd
 SET working_array->print_flag = "Y"
 SET working_array->reprint_flag = "Y"
 SET working_array->debug_flag = "N"
 SET working_array->from_prg = "E"
 CALL echo(build2("mf_BMCEDDIAGNOSTIC_CD: ",mf_bmceddiagnostic_cd))
 SELECT INTO "nl:"
  FROM output_dest_xref odx,
   output_dest od,
   device d
  PLAN (odx
   WHERE odx.parent_entity_id=561916753.00
    AND odx.parent_entity_name="SERVICE_RESOURCE"
    AND odx.usage_type_cd=mf_requisition_cd)
   JOIN (od
   WHERE od.output_dest_cd=odx.output_dest_cd)
   JOIN (d
   WHERE d.device_cd=od.device_cd)
  HEAD REPORT
   ms_printer = trim(d.name,3), ms_radreqscript = trim(od.script,3), mf_output_dest_cd = od
   .output_dest_cd
  WITH nocounter
 ;end select
 SELECT
  o.order_id, o.person_id, o.encntr_id,
  r.packet_id
  FROM order_radiology o,
   orders os,
   rad_packet r
  PLAN (o
   WHERE o.order_id=trigger_orderid)
   JOIN (os
   WHERE os.order_id=o.order_id)
   JOIN (r
   WHERE r.order_id=o.order_id)
  DETAIL
   reqdata->contributor_system_cd = os.contributor_system_cd, m_request->order_id = o.order_id,
   m_request->qual[1].packet_id = r.packet_id,
   m_request->qual[1].print_info[1].program_name = ms_radreqscript, m_request->qual[1].print_info[1].
   output_dest_cd = mf_output_dest_cd, m_request->qual[1].print_info[1].print_que = ms_printer,
   m_request->qual[1].print_info[1].printer_dio = "8"
  WITH nocounter
 ;end select
 SET m_request->order_packet_flag = 0
 CALL echo("****** execute rad_rpt_packet_reprint ******")
 EXECUTE rad_rpt_packet_reprint  WITH replace("REQUEST",m_request)
 CALL echo(build("status: ",reply->status_data.status))
 CALL echorecord(m_request)
#exit_script
 SET retval = 100
 SET log_message = concat("Radiology requisition printed to: ",build(ms_printer))
END GO
