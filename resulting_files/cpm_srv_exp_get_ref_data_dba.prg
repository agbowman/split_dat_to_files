CREATE PROGRAM cpm_srv_exp_get_ref_data:dba
 CALL echo("Check expedite_processing")
 SET reply->loglevel = 0
 SET reply->onind = 0
 SELECT INTO "nl:"
  e.log_level
  FROM expedite_processing e
  WHERE e.on_ind=1
  DETAIL
   reply->loglevel = e.log_level, reply->onind = e.on_ind
  WITH nocounter
 ;end select
 IF ((reply->onind=0))
  GO TO end_script
 ENDIF
 RECORD addtlphys(
   1 admitdoc = f8
   1 orderdoc = f8
   1 consultdoc = f8
   1 physlist[*]
     2 physcd = f8
 ) WITH persist
 DECLARE iret = i4
 DECLARE codeset = i4
 DECLARE meaning = c12
 DECLARE index = i4
 DECLARE codevalue = f8
 SET codeset = 333
 SET meaning = "ADMITDOC"
 SET index = 1
 SET codevalue = 0.0
 SET iret = uar_get_meaning_by_codeset(codeset,meaning,1,codevalue)
 IF (iret=0)
  SET addtlphys->admitdoc = codevalue
 ENDIF
 SET meaning = "ORDERDOC"
 SET index = 1
 SET codevalue = 0.0
 SET iret = uar_get_meaning_by_codeset(codeset,meaning,1,codevalue)
 IF (iret=0)
  SET addtlphys->orderdoc = codevalue
 ENDIF
 DECLARE docmeaning = vc
 DECLARE physcnt = i2
 SET physcnt = 0
 SELECT DISTINCT INTO "nl:"
  ec.encntr_prsnl_r_cd
  FROM expedite_params ep,
   expedite_copy ec
  PLAN (ep
   WHERE ep.expedite_params_id > 0)
   JOIN (ec
   WHERE ec.expedite_params_id=ep.expedite_params_id)
  HEAD REPORT
   physcnt = 0
  DETAIL
   docmeaning = trim(uar_get_code_meaning(ec.encntr_prsnl_r_cd)), physcnt = (physcnt+ 1)
   IF (mod(physcnt,10)=1)
    stat = alterlist(addtlphys->physlist,(physcnt+ 10))
   ENDIF
   addtlphys->physlist[physcnt].physcd = ec.encntr_prsnl_r_cd
   IF (docmeaning="CONSULTDOC")
    addtlphys->consultdoc = ec.encntr_prsnl_r_cd
   ENDIF
  FOOT REPORT
   stat = alterlist(addtlphys->physlist,physcnt)
  WITH nocounter
 ;end select
 CALL echo("Read cross referenced devices")
 DECLARE devcnt = i2
 SELECT INTO "nl:"
  dxr.parent_entity_id, dxr.parent_entity_name, od.output_dest_cd,
  rdt.output_format_cd
  FROM device_xref dxr,
   output_dest od,
   remote_device rd,
   remote_device_type rdt,
   dummyt d1
  PLAN (dxr
   WHERE dxr.parent_entity_name IN ("LOCATION", "SERVICE_RESOURCE", "ORGANIZATION", "PRSNL"))
   JOIN (od
   WHERE od.device_cd=dxr.device_cd)
   JOIN (d1)
   JOIN (rd
   WHERE rd.device_cd=od.device_cd)
   JOIN (rdt
   WHERE rdt.remote_dev_type_id=rd.remote_dev_type_id)
  HEAD REPORT
   devcnt = 0
  DETAIL
   devcnt = (devcnt+ 1)
   IF (mod(devcnt,10)=1)
    stat = alterlist(reply->device,(devcnt+ 10))
   ENDIF
   reply->device[devcnt].xrefid = dxr.parent_entity_id, reply->device[devcnt].xrefname = dxr
   .parent_entity_name, reply->device[devcnt].destcd = od.output_dest_cd,
   reply->device[devcnt].formatcd = rdt.output_format_cd
  FOOT REPORT
   stat = alterlist(reply->device,devcnt)
  WITH outerjoin = d1, nocounter
 ;end select
 CALL echo("Read parameters")
 DECLARE paramcnt = i2
 DECLARE copycnt = i2
 SELECT INTO "nl:"
  ep.expedite_params_id, ep.chart_content_flag, ep.copy_ind,
  ep.chart_format_id, ep.output_dest_cd, ep.output_flag,
  ec.encntr_prsnl_r_cd
  FROM expedite_params ep,
   expedite_copy ec,
   dummyt d1
  PLAN (ep
   WHERE ep.expedite_params_id > 0)
   JOIN (d1)
   JOIN (ec
   WHERE ec.expedite_params_id=ep.expedite_params_id)
  HEAD REPORT
   paramcnt = 0
  HEAD ep.expedite_params_id
   paramcnt = (paramcnt+ 1)
   IF (mod(paramcnt,10)=1)
    stat = alterlist(reply->param,(paramcnt+ 10))
   ENDIF
   reply->param[paramcnt].paramsid = ep.expedite_params_id, reply->param[paramcnt].contentflg = ep
   .chart_content_flag, reply->param[paramcnt].copyind = ep.copy_ind,
   reply->param[paramcnt].formatid = ep.chart_format_id, reply->param[paramcnt].destcd = ep
   .output_dest_cd, reply->param[paramcnt].devicecd = ep.output_device_cd,
   reply->param[paramcnt].outputflg = ep.output_flag, copycnt = 0
  DETAIL
   IF (ep.copy_ind=1)
    copycnt = (copycnt+ 1)
    IF (mod(copycnt,10)=1)
     stat = alterlist(reply->param[paramcnt].copy,(copycnt+ 10))
    ENDIF
    reply->param[paramcnt].copy[copycnt].copycd = ec.encntr_prsnl_r_cd
   ENDIF
  FOOT  ep.expedite_params_id
   stat = alterlist(reply->param[paramcnt].copy,copycnt)
  FOOT REPORT
   stat = alterlist(reply->param,paramcnt)
  WITH outerjoin = d1, nocounter
 ;end select
 DECLARE trigcnt = i2
 DECLARE rowcnt = i2
 DECLARE respcnt = i2
 CALL echo("Read Triggers")
 SELECT INTO "nl:"
  et.name, et.organization_id, et.location_cd,
  et.location_context_flag, et.report_priority_cd, et.result_range_cd,
  et.result_status_cd, et.result_cd, et.result_nbr,
  et.report_processing_cd, et.report_processing_nbr, et.service_resource_cd,
  et.catalog_type_cd, et.activity_type_cd, et.catalog_cd,
  et.task_assay_cd, et.order_complete_flag, et.provider_id,
  et.discharged_flag, et.mic_ver_flag, et.mic_cor_flag,
  et.mic_com_flag, et.mic_after_com_flag, et.reference_task_id,
  epr.expedite_params_id, ecr.nomenclature_id, ecr.coded_response_cd
  FROM expedite_trigger et,
   expedite_params_r epr,
   expedite_coded_resp ecr,
   dummyt d
  PLAN (et
   WHERE et.active_ind > 0)
   JOIN (epr
   WHERE epr.expedite_trigger_id=et.expedite_trigger_id)
   JOIN (d)
   JOIN (ecr
   WHERE ecr.expedite_trigger_id=et.expedite_trigger_id
    AND ((ecr.nomenclature_id > 0) OR (ecr.coded_response_cd > 0)) )
  ORDER BY epr.precedence_seq, et.name_key
  HEAD REPORT
   trigcnt = 0
  HEAD et.name_key
   trigcnt = (trigcnt+ 1), stat = alterlist(reply->trigger,trigcnt), reply->trigger[trigcnt].paramsid
    = epr.expedite_params_id,
   reply->trigger[trigcnt].name = et.name, rowcnt = 0
  HEAD et.expedite_trigger_id
   rowcnt = (rowcnt+ 1), stat = alterlist(reply->trigger[trigcnt].trigrow,rowcnt), reply->trigger[
   trigcnt].trigrow[rowcnt].orgid = et.organization_id,
   reply->trigger[trigcnt].trigrow[rowcnt].loccd = et.location_cd, reply->trigger[trigcnt].trigrow[
   rowcnt].loccontext = et.location_context_flag, reply->trigger[trigcnt].trigrow[rowcnt].rptprtycd
    = et.report_priority_cd,
   reply->trigger[trigcnt].trigrow[rowcnt].rsltrangecd = et.result_range_cd, reply->trigger[trigcnt].
   trigrow[rowcnt].rsltstatuscd = et.result_status_cd, reply->trigger[trigcnt].trigrow[rowcnt].rsltcd
    = et.result_cd,
   reply->trigger[trigcnt].trigrow[rowcnt].rsltnbr = et.result_nbr, reply->trigger[trigcnt].trigrow[
   rowcnt].rptproccd = et.report_processing_cd, reply->trigger[trigcnt].trigrow[rowcnt].rptprocnbr =
   et.report_processing_nbr,
   reply->trigger[trigcnt].trigrow[rowcnt].srvrescd = et.service_resource_cd, reply->trigger[trigcnt]
   .trigrow[rowcnt].cattypecd = et.catalog_type_cd, reply->trigger[trigcnt].trigrow[rowcnt].acttypecd
    = et.activity_type_cd,
   reply->trigger[trigcnt].trigrow[rowcnt].catcd = et.catalog_cd, reply->trigger[trigcnt].trigrow[
   rowcnt].taskassaycd = et.task_assay_cd, reply->trigger[trigcnt].trigrow[rowcnt].ordcompleteflag =
   et.order_complete_flag,
   reply->trigger[trigcnt].trigrow[rowcnt].provid = et.provider_id, reply->trigger[trigcnt].trigrow[
   rowcnt].dischargeflag = et.discharged_flag, reply->trigger[trigcnt].trigrow[rowcnt].micver = et
   .mic_ver_flag,
   reply->trigger[trigcnt].trigrow[rowcnt].miccor = et.mic_cor_flag, reply->trigger[trigcnt].trigrow[
   rowcnt].miccom = et.mic_com_flag, reply->trigger[trigcnt].trigrow[rowcnt].micaftercom = et
   .mic_after_com_flag,
   reply->trigger[trigcnt].trigrow[rowcnt].referencetaskid = et.reference_task_id, respcnt = 0
  DETAIL
   IF (((ecr.coded_response_cd > 0) OR (ecr.nomenclature_id > 0)) )
    respcnt = (respcnt+ 1), stat = alterlist(reply->trigger[trigcnt].trigrow[rowcnt].codedresp,
     respcnt)
    IF (ecr.coded_response_cd=0)
     reply->trigger[trigcnt].trigrow[rowcnt].codedresp[respcnt].codedresponsecd = 0, reply->trigger[
     trigcnt].trigrow[rowcnt].codedresp[respcnt].nomenid = ecr.nomenclature_id
    ELSE
     reply->trigger[trigcnt].trigrow[rowcnt].codedresp[respcnt].codedresponsecd = ecr
     .coded_response_cd, reply->trigger[trigcnt].trigrow[rowcnt].codedresp[respcnt].nomenid = 0
    ENDIF
   ENDIF
  WITH outerjoin = d, nocounter
 ;end select
#end_script
END GO
