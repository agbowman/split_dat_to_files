CREATE PROGRAM cv_chart_request:dba
 IF (validate(stat)=0)
  DECLARE stat = i4 WITH protect
 ENDIF
 IF (validate(cv_log_stat_cnt)=0)
  DECLARE cv_log_stat_cnt = i4
  DECLARE cv_log_msg_cnt = i4
  DECLARE cv_debug = i2 WITH constant(4)
  DECLARE cv_info = i2 WITH constant(3)
  DECLARE cv_audit = i2 WITH constant(2)
  DECLARE cv_warning = i2 WITH constant(1)
  DECLARE cv_error = i2 WITH constant(0)
  DECLARE cv_log_levels[5] = c8
  SET cv_log_levels[1] = "ERROR  :"
  SET cv_log_levels[2] = "WARNING:"
  SET cv_log_levels[3] = "AUDIT  :"
  SET cv_log_levels[4] = "INFO   :"
  SET cv_log_levels[5] = "DEBUG  :"
  RECORD temp_text(
    1 qual[*]
      2 text = vc
  )
  DECLARE null_dt_tm = dq8 WITH protect, noconstant(cnvtdatetime("31-DEC-2100 00:00:00"))
  DECLARE null_f8 = f8 WITH protect, noconstant(0.000001)
  DECLARE cv_log_error_file = i4 WITH noconstant(0)
  IF (currdbname IN ("PROV", "SOLT", "SURD"))
   SET cv_log_error_file = 1
  ENDIF
  DECLARE cv_err_msg = vc WITH noconstant(fillstring(128," "))
  DECLARE cv_log_file_name = vc WITH noconstant(build("cer_temp:CV_DEFAULT",cnvtstring(curtime2),
    ".dat"))
  DECLARE cv_log_error_string = vc WITH noconstant(fillstring(32000," "))
  DECLARE cv_log_error_string_cnt = i4
  CALL cv_log_msg(cv_info,"CV_LOG_MSG version: 002 10/16/08 AR012547")
 ENDIF
 CALL cv_log_msg(cv_info,concat("*** Entering ",curprog," at ",format(cnvtdatetime(sysdate),
    "@SHORTDATETIME")))
 IF (validate(request)=1
  AND (reqdata->loglevel >= cv_info))
  IF (cv_log_error_file=1)
   CALL echorecord(request,cv_log_file_name,1)
  ENDIF
  CALL echorecord(request)
 ENDIF
 SUBROUTINE (cv_log_stat(log_lev=i2,op_name=vc,op_stat=c1,obj_name=vc,obj_value=vc) =null)
   SET cv_log_stat_cnt = (size(reply->status_data.subeventstatus,5)+ 1)
   SET stat = alterlist(reply->status_data.subeventstatus,cv_log_stat_cnt)
   SET reply->status_data.subeventstatus[cv_log_stat_cnt].operationname = op_name
   SET reply->status_data.subeventstatus[cv_log_stat_cnt].operationstatus = op_stat
   SET reply->status_data.subeventstatus[cv_log_stat_cnt].targetobjectname = obj_name
   SET reply->status_data.subeventstatus[cv_log_stat_cnt].targetobjectvalue = obj_value
   IF ((reqdata->loglevel >= log_lev))
    CALL cv_log_msg(log_lev,build("Subevent:",nullterm(op_name),"=",nullterm(op_stat),"::",
      nullterm(obj_name),"::",obj_value))
   ENDIF
 END ;Subroutine
 SUBROUTINE (cv_log_msg(log_lev=i2,the_message=vc(byval)) =null)
   IF ((reqdata->loglevel >= log_lev))
    SET cv_err_msg = fillstring(128," ")
    SET cv_err_msg = concat("**",nullterm(cv_log_levels[(log_lev+ 1)]),trim(the_message)," at :",
     format(cnvtdatetime(sysdate),"@SHORTDATETIME"))
    CALL echo(cv_err_msg)
    IF (cv_log_error_file=1)
     SET cv_log_error_string_cnt += 1
     SET cv_log_error_string = build(cv_log_error_string,char(10),cv_err_msg)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (cv_log_msg_post(script_vrsn=vc) =null)
  IF ((reqdata->loglevel >= cv_info))
   IF (validate(reply))
    IF (cv_log_error_file=1
     AND validate(request)=1)
     CALL echorecord(request,cv_log_file_name,1)
    ENDIF
    CALL echorecord(reply)
   ENDIF
   CALL cv_log_msg(cv_info,concat("*** Leaving ",curprog," version:",script_vrsn," at ",
     format(cnvtdatetime(sysdate),"@SHORTDATETIME")))
  ENDIF
  IF (cv_log_error_string_cnt > 0)
   CALL cv_log_msg(cv_info,concat("*** The Error Log File is: ",cv_log_file_name))
   EXECUTE cv_log_flush_message
   SET cv_log_msg_cnt = 0
  ENDIF
 END ;Subroutine
 IF (validate(reply)=0)
  RECORD reply(
    1 chart_request[*]
      2 chart_request_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 RECORD cp_add_chart_request_req(
   1 qual[*]
     2 scope_flag = i2
     2 person_id = f8
     2 encntr_id = f8
     2 order_id = f8
     2 accession_nbr = c20
     2 chart_format_id = f8
     2 distribution_id = f8
     2 dist_run_type_cd = f8
     2 dist_run_dt_tm = dq8
     2 dist_terminator_ind = i2
     2 dist_initiator_ind = i2
     2 reader_group = c15
     2 date_range_ind = i2
     2 begin_dt_tm = dq8
     2 end_dt_tm = dq8
     2 page_range_ind = i2
     2 begin_page = i4
     2 end_page = i4
     2 print_complete_flag = i2
     2 chart_pending_flag = i2
     2 output_dest_cd = f8
     2 output_device_cd = f8
     2 rrd_deliver_dt_tm = dq8
     2 rrd_country_access = c3
     2 rrd_area_code = c10
     2 rrd_exchange = c10
     2 rrd_phone_suffix = c30
     2 request_type = i4
     2 addl_copies = i4
     2 prsnl_person_id = f8
     2 prsnl_person_r_cd = f8
     2 trigger_id = f8
     2 trigger_type = c15
     2 file_storage_cd = f8
     2 file_storage_location = vc
     2 event_ind = i2
     2 trigger_name = c100
     2 prsnl_reltn_id = f8
     2 chart_route_id = f8
     2 sequence_group_id = f8
     2 event_id_list[*]
       3 cr_event_id = f8
       3 event_id = f8
       3 result_status_cd = f8
     2 prov[*]
       3 person_id = f8
       3 r_cd = f8
       3 copy_ind = i2
     2 encntr_list[*]
       3 encntr_id = f8
     2 chart_sect_list[*]
       3 chart_section_id = f8
     2 suppress_mrpnodata_ind = i2
     2 order_list[*]
       3 order_id = f8
     2 group_order_id = f8
     2 order_group_flag = i4
     2 result_lookup_ind = i2
 )
 RECORD cp_add_chart_request_rep(
   1 qual[*]
     2 chart_request_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD out_dest(
   1 dests[*]
     2 device_cd = f8
     2 output_dest_cd = f8
     2 output_device_cd = f8
     2 usage_type_cd = f8
 )
 DECLARE phys_cnt = i4 WITH protect, noconstant(size(request->ref_phys,5))
 DECLARE phys_idx = i4 WITH protect
 DECLARE event_cnt = i4 WITH protect, noconstant(size(request->event,5))
 DECLARE event_idx = i4 WITH protect
 DECLARE rep_qual_cnt = i4 WITH protect
 DECLARE reply_qual_idx = i4 WITH protect
 DECLARE c_event_class_doc = f8 WITH protect, constant(uar_get_code_by("MEANING",53,"DOC"))
 DECLARE c_usage_type_fax = f8 WITH protect, constant(uar_get_code_by("MEANING",3000,"FAX"))
 DECLARE c_usage_type_printer = f8 WITH protect, constant(uar_get_code_by("MEANING",3000,"PRINTER"))
 DECLARE c_encntr_prsnl_r_referdoc = f8 WITH protect, constant(uar_get_code_by("MEANING",333,
   "REFERDOC"))
 SET stat = alterlist(out_dest->dests,phys_cnt)
 IF (phys_cnt=0)
  CALL cv_log_stat(cv_warning,"REQUEST","Z","SIZE(REQUEST->REF_PHYS,5)","0")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(phys_cnt)),
   device_xref dx,
   output_dest od
  PLAN (d)
   JOIN (dx
   WHERE dx.parent_entity_name="PRSNL"
    AND (dx.parent_entity_id=request->ref_phys[d.seq].ref_phys_id)
    AND dx.usage_type_cd IN (c_usage_type_fax, c_usage_type_printer))
   JOIN (od
   WHERE od.device_cd=dx.device_cd)
  DETAIL
   out_dest->dests[d.seq].device_cd = od.device_cd, out_dest->dests[d.seq].output_dest_cd = od
   .output_dest_cd, out_dest->dests[d.seq].usage_type_cd = dx.usage_type_cd
  WITH nocounter
 ;end select
 SET phys_idx = locateval(phys_idx,1,phys_cnt,0.0,out_dest->dests[phys_idx].output_dest_cd)
 IF (phys_idx > 0)
  IF ((request->default_output_dest_cd > 0.0))
   SELECT INTO "nl:"
    FROM output_dest od
    WHERE (od.output_dest_cd=request->default_output_dest_cd)
    DETAIL
     WHILE (phys_idx > 0)
       out_dest->dests[phys_idx].device_cd = od.device_cd, out_dest->dests[phys_idx].output_dest_cd
        = request->default_output_dest_cd, phys_idx = locateval(phys_idx,(phys_idx+ 1),phys_cnt,0.0,
        out_dest->dests[phys_idx].output_dest_cd)
     ENDWHILE
    WITH nocounter
   ;end select
  ELSE
   CALL cv_log_stat(cv_audit,"OUTPUT_DEST","Z",build("prsnl_id=",request->ref_phys[phys_idx].
     ref_phys_id),"No device_xref and no default_output_dest_cd")
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  rdt.output_format_cd
  FROM (dummyt d  WITH seq = value(phys_cnt)),
   remote_device rd,
   remote_device_type rdt
  PLAN (d
   WHERE (out_dest->dests[d.seq].usage_type_cd=c_usage_type_fax))
   JOIN (rd
   WHERE (rd.device_cd=out_dest->dests[d.seq].device_cd)
    AND rd.remote_dev_type_id > 0.0)
   JOIN (rdt
   WHERE rdt.remote_dev_type_id=rd.remote_dev_type_id)
  DETAIL
   out_dest->dests[d.seq].output_device_cd = rdt.output_format_cd
  WITH nocounter
 ;end select
 IF ((reqdata->loglevel >= cv_info))
  CALL echorecord(out_dest)
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(event_cnt)),
   clinical_event ce
  PLAN (d)
   JOIN (ce
   WHERE (ce.parent_event_id=request->event[d.seq].event_id)
    AND ce.valid_until_dt_tm=cnvtdatetime(null_dt_tm)
    AND ((ce.event_id+ 0.0) != ce.parent_event_id)
    AND ce.event_class_cd=c_event_class_doc
    AND (ce.result_status_cd != reqdata->auth_inerror_cd))
  DETAIL
   event_idx = locateval(event_idx,1,event_cnt,ce.parent_event_id,request->event[event_idx].event_id),
   event_cnt += 1, stat = alterlist(request->event,event_cnt,event_idx),
   request->event[(event_idx+ 1)].event_id = ce.event_id
  WITH nocounter
 ;end select
 SET stat = alterlist(cp_add_chart_request_req->qual,phys_cnt)
 FOR (phys_idx = 1 TO phys_cnt)
   SET cp_add_chart_request_req->qual[phys_idx].scope_flag = 6
   SET cp_add_chart_request_req->qual[phys_idx].person_id = request->person_id
   SET cp_add_chart_request_req->qual[phys_idx].encntr_id = request->encntr_id
   SET cp_add_chart_request_req->qual[phys_idx].chart_format_id = request->chart_format_id
   SET cp_add_chart_request_req->qual[phys_idx].date_range_ind = 1
   SET cp_add_chart_request_req->qual[phys_idx].begin_dt_tm = cnvtdatetime("01-JAN-1800")
   SET cp_add_chart_request_req->qual[phys_idx].end_dt_tm = cnvtdatetime(sysdate)
   SET cp_add_chart_request_req->qual[phys_idx].output_dest_cd = out_dest->dests[phys_idx].
   output_dest_cd
   SET cp_add_chart_request_req->qual[phys_idx].output_device_cd = out_dest->dests[phys_idx].
   output_device_cd
   SET cp_add_chart_request_req->qual[phys_idx].request_type = 2
   SET cp_add_chart_request_req->qual[phys_idx].prsnl_person_id = request->ref_phys[phys_idx].
   ref_phys_id
   SET cp_add_chart_request_req->qual[phys_idx].prsnl_person_r_cd = c_encntr_prsnl_r_referdoc
   SET stat = alterlist(cp_add_chart_request_req->qual[phys_idx].event_id_list,event_cnt)
   FOR (event_idx = 1 TO event_cnt)
     SET cp_add_chart_request_req->qual[phys_idx].event_id_list[event_idx].event_id = request->event[
     event_idx].event_id
   ENDFOR
   SET cp_add_chart_request_req->qual[phys_idx].result_lookup_ind = 1
 ENDFOR
 FREE RECORD out_dest
 CALL echorecord(cp_add_chart_request_req)
 EXECUTE cp_add_chart_request  WITH replace("REQUEST","CP_ADD_CHART_REQUEST_REQ"), replace("REPLY",
  "CP_ADD_CHART_REQUEST_REP")
 CALL echorecord(cp_add_chart_request_rep)
 SET rep_qual_cnt = size(cp_add_chart_request_rep->qual,5)
 SET stat = alterlist(reply->chart_request,rep_qual_cnt)
 FOR (reply_qual_idx = 1 TO rep_qual_cnt)
   SET reply->chart_request[reply_qual_idx].chart_request_id = cp_add_chart_request_rep->qual[
   reply_qual_idx].chart_request_id
 ENDFOR
 SET reply->status_data.status = "S"
#exit_script
 IF ((reply->status_data.status="S"))
  SET reqinfo->commit_ind = 1
 ELSE
  CALL echorecord(request)
  CALL echorecord(cp_add_chart_request_req)
  CALL echorecord(cp_add_chart_request_rep)
  CALL echorecord(reply)
  SET reqinfo->commit_ind = 0
 ENDIF
 FREE RECORD cp_add_chart_request_req
 FREE RECORD cp_add_chart_request_rep
 CALL cv_log_msg_post("MOD 003 08/02/2007 MH914")
END GO
