CREATE PROGRAM cpmnotify_dcp_ce:dba
 SET modify = predeclare
 FREE RECORD reply
 RECORD reply(
   1 run_dt_tm = dq8
   1 overlay_ind = i2
   1 entity_list[*]
     2 entity_id = f8
     2 datalist[*]
       3 encntr_id = f8
       3 event_id = f8
       3 clinical_event_id = f8
       3 event_cd = f8
       3 event_cd_disp = vc
       3 event_class_cd = f8
       3 normalcy_cd = f8
       3 normal_low = vc
       3 normal_high = vc
       3 event_end_dt_tm = dq8
       3 result_status_cd = f8
       3 verified_prsnl_id = f8
       3 event_tag = vc
       3 performed_prsnl_id = f8
       3 updt_dt_tm = dq8
       3 result_units_cd = f8
       3 result_val = vc
       3 updt_id = f8
       3 parent_event_id = f8
       3 event_end_tz = i4
       3 med_result_list[*]
         4 admin_dosage = f8
         4 dosage_unit_cd = f8
         4 iv_event_cd = f8
         4 infused_volume = f8
         4 infused_volume_unit_cd = f8
       3 dynamic_label_id = f8
       3 dynamic_label_name = vc
       3 string_result_list[*]
         4 string_result_text = vc
         4 string_result_format_cd = f8
         4 equation_id = f8
         4 unit_of_measure_cd = f8
       3 io_total_result_list[*]
         4 suspect_flag = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD temppersons
 RECORD temppersons(
   1 person_list[*]
     2 person_id = f8
 )
 FREE RECORD tempevents
 RECORD tempevents(
   1 event_list[*]
     2 event_id = f8
     2 entity_idx = i4
     2 data_idx = i4
 )
 DECLARE reportfailure(opname=vc,opstatus=vc,targetname=vc,targetvalue=vc) = null
 DECLARE fillsubeventstatus(opname=vc,opstatus=vc,objname=vc,objvalue=vc) = null
 SUBROUTINE reportfailure(opname,opstatus,targetname,targetvalue)
  SET reply->status_data.status = "F"
  CALL fillsubeventstatus(opname,opstatus,targetname,targetvalue)
 END ;Subroutine
 SUBROUTINE fillsubeventstatus(opname,opstatus,objname,objvalue)
   DECLARE dcp_substatus_cnt = i4 WITH protect, noconstant(size(reply->status_data.subeventstatus,5))
   SET dcp_substatus_cnt = (dcp_substatus_cnt+ 1)
   IF (dcp_substatus_cnt != 1)
    SET stat = alter(reply->status_data.subeventstatus,dcp_substatus_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].operationname = trim(opname)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].targetobjectname = trim(objname)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].targetobjectvalue = trim(objvalue)
 END ;Subroutine
 DECLARE max_dt_tm = dq8 WITH protect, constant(cnvtdatetime("31-DEC-2100,00:00:00:00"))
 DECLARE cur_dt_tm = dq8 WITH protect, constant(cnvtdatetime(curdate,curtime3))
 DECLARE dscriptstarttime = dq8 WITH protect, noconstant(cnvtdatetime(curdate,curtime3))
 DECLARE dactionstarttime = dq8 WITH protect, noconstant(0)
 DECLARE delapsedtime = f8 WITH protect, noconstant(0.0)
 DECLARE itotalpersoncnt = i4 WITH protect, noconstant(size(request->entity_list,5))
 DECLARE itotaleventcnt = i4 WITH protect, noconstant(0)
 DECLARE iexpandstart = i4 WITH protect, noconstant(0)
 DECLARE iexpandsize = i4 WITH protect, noconstant(0)
 DECLARE iexpandtotal = i4 WITH protect, noconstant(0)
 DECLARE iexpandidx = i4 WITH protect, noconstant(0)
 DECLARE i = i4 WITH protect, noconstant(0)
 DECLARE ilocpos = i4 WITH protect, noconstant(0)
 DECLARE ientidx = i4 WITH protect, noconstant(0)
 DECLARE idatidx = i4 WITH protect, noconstant(0)
 DECLARE ilocidx = i4 WITH protect, noconstant(0)
 DECLARE error_code = i2 WITH protect, noconstant(0)
 DECLARE error_msg = vc WITH protect, noconstant("")
 DECLARE stat = i2 WITH protect, noconstant(false)
 DECLARE iscriptdebugind = i2 WITH protect, noconstant(0)
 IF (validate(request->debug_ind))
  SET iscriptdebugind = request->debug_ind
 ENDIF
 SET reply->status_data.status = "F"
 SET reply->run_dt_tm = cur_dt_tm
 SET dactionstarttime = cnvtdatetime(curdate,curtime3)
 SET iexpandsize = 20
 SET iexpandtotal = (ceil((cnvtreal(itotalpersoncnt)/ iexpandsize)) * iexpandsize)
 SET stat = alterlist(temppersons->person_list,iexpandtotal)
 FOR (i = 1 TO itotalpersoncnt)
   SET temppersons->person_list[i].person_id = request->entity_list[i].entity_id
 ENDFOR
 FOR (i = (itotalpersoncnt+ 1) TO iexpandtotal)
   SET temppersons->person_list[i].person_id = temppersons->person_list[itotalpersoncnt].person_id
 ENDFOR
 SET iexpandstart = 1
 SELECT INTO "nl:"
  FROM clinical_event ce,
   ce_dynamic_label cdl,
   (dummyt d1  WITH seq = value((1+ ((iexpandtotal - 1)/ iexpandsize))))
  PLAN (d1
   WHERE initarray(iexpandstart,evaluate(d1.seq,1,1,(iexpandstart+ iexpandsize))))
   JOIN (ce
   WHERE expand(iexpandidx,iexpandstart,(iexpandstart+ (iexpandsize - 1)),ce.person_id,temppersons->
    person_list[iexpandidx].person_id)
    AND ((ce.clinsig_updt_dt_tm+ 0) >= cnvtdatetime(request->last_run_dt_tm))
    AND ce.updt_dt_tm >= cnvtdatetime(request->last_run_dt_tm)
    AND ((ce.valid_until_dt_tm+ 0)=cnvtdatetime(max_dt_tm))
    AND ((ce.publish_flag+ 0)=1)
    AND ((ce.view_level+ 0) >= 1))
   JOIN (cdl
   WHERE cdl.ce_dynamic_label_id=ce.ce_dynamic_label_id)
  ORDER BY ce.person_id, ce.event_id
  HEAD REPORT
   stat = alterlist(reply->entity_list,itotalpersoncnt), ientidx = 0, itotaleventcnt = 0
  HEAD ce.person_id
   idatidx = 0, ientidx = (ientidx+ 1), reply->entity_list[ientidx].entity_id = ce.person_id
  DETAIL
   idatidx = (idatidx+ 1)
   IF (mod(idatidx,50)=1)
    stat = alterlist(reply->entity_list[ientidx].datalist,(idatidx+ 49))
   ENDIF
   reply->entity_list[ientidx].datalist[idatidx].updt_dt_tm = cnvtdatetime(ce.updt_dt_tm), reply->
   entity_list[ientidx].datalist[idatidx].encntr_id = ce.encntr_id, reply->entity_list[ientidx].
   datalist[idatidx].event_id = ce.event_id,
   reply->entity_list[ientidx].datalist[idatidx].clinical_event_id = ce.clinical_event_id, reply->
   entity_list[ientidx].datalist[idatidx].event_cd = ce.event_cd, reply->entity_list[ientidx].
   datalist[idatidx].event_class_cd = ce.event_class_cd,
   reply->entity_list[ientidx].datalist[idatidx].normalcy_cd = ce.normalcy_cd, reply->entity_list[
   ientidx].datalist[idatidx].normal_low = ce.normal_low, reply->entity_list[ientidx].datalist[
   idatidx].normal_high = ce.normal_high,
   reply->entity_list[ientidx].datalist[idatidx].event_end_dt_tm = ce.event_end_dt_tm, reply->
   entity_list[ientidx].datalist[idatidx].updt_dt_tm = ce.updt_dt_tm, reply->entity_list[ientidx].
   datalist[idatidx].result_status_cd = ce.result_status_cd,
   reply->entity_list[ientidx].datalist[idatidx].result_val = ce.result_val, reply->entity_list[
   ientidx].datalist[idatidx].verified_prsnl_id = ce.verified_prsnl_id, reply->entity_list[ientidx].
   datalist[idatidx].event_tag = ce.event_tag,
   reply->entity_list[ientidx].datalist[idatidx].performed_prsnl_id = ce.performed_prsnl_id, reply->
   entity_list[ientidx].datalist[idatidx].result_units_cd = ce.result_units_cd, reply->entity_list[
   ientidx].datalist[idatidx].updt_id = ce.updt_id,
   reply->entity_list[ientidx].datalist[idatidx].parent_event_id = ce.parent_event_id, reply->
   entity_list[ientidx].datalist[idatidx].event_end_tz = ce.event_end_tz
   IF (cdl.ce_dynamic_label_id > 0)
    reply->entity_list[ientidx].datalist[idatidx].dynamic_label_id = cdl.ce_dynamic_label_id, reply->
    entity_list[ientidx].datalist[idatidx].dynamic_label_name = cdl.label_name
   ENDIF
   itotaleventcnt = (itotaleventcnt+ 1)
   IF (mod(itotaleventcnt,50)=1)
    stat = alterlist(tempevents->event_list,(itotaleventcnt+ 49))
   ENDIF
   tempevents->event_list[itotaleventcnt].event_id = ce.event_id, tempevents->event_list[
   itotaleventcnt].entity_idx = ientidx, tempevents->event_list[itotaleventcnt].data_idx = idatidx
  FOOT  ce.person_id
   stat = alterlist(reply->entity_list[ientidx].datalist,idatidx)
  FOOT REPORT
   stat = alterlist(reply->entity_list,ientidx), stat = alterlist(tempevents->event_list,
    itotaleventcnt)
  WITH nocounter
 ;end select
 IF (iscriptdebugind=1)
  SET delapsedtime = datetimediff(cnvtdatetime(curdate,curtime3),dactionstarttime,5)
  CALL echo("*******************************************************")
  CALL echo(build("select from clinical_event = ",delapsedtime))
  CALL echo("*******************************************************")
 ENDIF
 IF (itotaleventcnt=0)
  GO TO exit_script
 ENDIF
 SET iexpandstart = 1
 SET iexpandsize = 100
 SET iexpandtotal = (ceil((cnvtreal(itotaleventcnt)/ iexpandsize)) * iexpandsize)
 SET stat = alterlist(tempevents->event_list,iexpandtotal)
 FOR (i = (itotaleventcnt+ 1) TO iexpandtotal)
   SET tempevents->event_list[i].event_id = tempevents->event_list[itotaleventcnt].event_id
 ENDFOR
 SET dactionstarttime = cnvtdatetime(curdate,curtime3)
 SET iexpandstart = 1
 SELECT INTO "nl:"
  FROM ce_med_result cmr,
   (dummyt d1  WITH seq = value((1+ ((iexpandtotal - 1)/ iexpandsize))))
  PLAN (d1
   WHERE initarray(iexpandstart,evaluate(d1.seq,1,1,(iexpandstart+ iexpandsize))))
   JOIN (cmr
   WHERE expand(iexpandidx,iexpandstart,(iexpandstart+ (iexpandsize - 1)),cmr.event_id,tempevents->
    event_list[iexpandidx].event_id)
    AND cmr.valid_until_dt_tm=cnvtdatetime(max_dt_tm))
  ORDER BY cmr.event_id
  HEAD cmr.event_id
   idatidx = 0, ientidx = 0, ilocpos = locateval(ilocidx,1,itotaleventcnt,cmr.event_id,tempevents->
    event_list[ilocidx].event_id)
   IF (ilocpos != 0)
    idatidx = tempevents->event_list[ilocpos].data_idx, ientidx = tempevents->event_list[ilocpos].
    entity_idx
   ENDIF
  DETAIL
   IF (cmr.event_id > 0
    AND idatidx != 0
    AND ientidx != 0)
    stat = alterlist(reply->entity_list[ientidx].datalist[idatidx].med_result_list,1), reply->
    entity_list[ientidx].datalist[idatidx].med_result_list[0].admin_dosage = cmr.admin_dosage, reply
    ->entity_list[ientidx].datalist[idatidx].med_result_list[0].dosage_unit_cd = cmr.dosage_unit_cd,
    reply->entity_list[ientidx].datalist[idatidx].med_result_list[0].iv_event_cd = cmr.iv_event_cd,
    reply->entity_list[ientidx].datalist[idatidx].med_result_list[0].infused_volume = cmr
    .infused_volume, reply->entity_list[ientidx].datalist[idatidx].med_result_list[0].
    infused_volume_unit_cd = cmr.infused_volume_unit_cd
   ENDIF
  WITH nocounter
 ;end select
 IF (iscriptdebugind=1)
  SET delapsedtime = datetimediff(cnvtdatetime(curdate,curtime3),dactionstarttime,5)
  CALL echo("*******************************************************")
  CALL echo(build("select from ce_med_result = ",delapsedtime))
  CALL echo("*******************************************************")
 ENDIF
 SET dactionstarttime = cnvtdatetime(curdate,curtime3)
 SET iexpandstart = 1
 SELECT INTO "nl:"
  FROM ce_string_result csr,
   (dummyt d1  WITH seq = value((1+ ((iexpandtotal - 1)/ iexpandsize))))
  PLAN (d1
   WHERE initarray(iexpandstart,evaluate(d1.seq,1,1,(iexpandstart+ iexpandsize))))
   JOIN (csr
   WHERE expand(iexpandidx,iexpandstart,(iexpandstart+ (iexpandsize - 1)),csr.event_id,tempevents->
    event_list[iexpandidx].event_id)
    AND csr.valid_until_dt_tm=cnvtdatetime(max_dt_tm))
  ORDER BY csr.event_id
  HEAD csr.event_id
   idatidx = 0, ientidx = 0, ilocpos = locateval(ilocidx,1,itotaleventcnt,csr.event_id,tempevents->
    event_list[ilocidx].event_id)
   IF (ilocpos != 0)
    idatidx = tempevents->event_list[ilocpos].data_idx, ientidx = tempevents->event_list[ilocpos].
    entity_idx
   ENDIF
  DETAIL
   IF (csr.event_id > 0
    AND idatidx != 0
    AND ientidx != 0)
    stat = alterlist(reply->entity_list[ientidx].datalist[idatidx].string_result_list,1), reply->
    entity_list[ientidx].datalist[idatidx].string_result_list[0].string_result_text = csr
    .string_result_text, reply->entity_list[ientidx].datalist[idatidx].string_result_list[0].
    string_result_format_cd = csr.string_result_format_cd,
    reply->entity_list[ientidx].datalist[idatidx].string_result_list[0].equation_id = csr.equation_id,
    reply->entity_list[ientidx].datalist[idatidx].string_result_list[0].unit_of_measure_cd = csr
    .unit_of_measure_cd
   ENDIF
  WITH nocounter
 ;end select
 IF (iscriptdebugind=1)
  SET delapsedtime = datetimediff(cnvtdatetime(curdate,curtime3),dactionstarttime,5)
  CALL echo("*******************************************************")
  CALL echo(build("select from ce_string_result = ",delapsedtime))
  CALL echo("*******************************************************")
 ENDIF
 SET dactionstarttime = cnvtdatetime(curdate,curtime3)
 SET iexpandstart = 1
 SELECT INTO "nl:"
  FROM ce_io_total_result ceio,
   (dummyt d1  WITH seq = value((1+ ((iexpandtotal - 1)/ iexpandsize))))
  PLAN (d1
   WHERE initarray(iexpandstart,evaluate(d1.seq,1,1,(iexpandstart+ iexpandsize))))
   JOIN (ceio
   WHERE expand(iexpandidx,iexpandstart,(iexpandstart+ (iexpandsize - 1)),ceio.event_id,tempevents->
    event_list[iexpandidx].event_id)
    AND ceio.valid_until_dt_tm=cnvtdatetime(max_dt_tm))
  ORDER BY ceio.event_id
  HEAD ceio.event_id
   idatidx = 0, ientidx = 0, ilocpos = locateval(ilocidx,1,itotaleventcnt,ceio.event_id,tempevents->
    event_list[ilocidx].event_id)
   IF (ilocpos != 0)
    idatidx = tempevents->event_list[ilocpos].data_idx, ientidx = tempevents->event_list[ilocpos].
    entity_idx
   ENDIF
  DETAIL
   IF (ceio.event_id > 0
    AND idatidx != 0
    AND ientidx != 0)
    stat = alterlist(reply->entity_list[ientidx].datalist[idatidx].io_total_result_list,1), reply->
    entity_list[ientidx].datalist[idatidx].io_total_result_list[0].suspect_flag = ceio.suspect_flag
   ENDIF
  WITH nocounter
 ;end select
 IF (iscriptdebugind=1)
  SET delapsedtime = datetimediff(cnvtdatetime(curdate,curtime3),dactionstarttime,5)
  CALL echo("*******************************************************")
  CALL echo(build("select from ce_io_total_result = ",delapsedtime))
  CALL echo("*******************************************************")
 ENDIF
#exit_script
 SET error_code = error(error_msg,1)
 IF (error_code != 0)
  CALL echo(build("ERROR: ",error_msg))
  SET reply->status_data.status = "F"
  CALL fillsubeventstatus("ERROR","F","cpmnotify_dcp_ce",error_msg)
 ELSEIF (size(reply->entity_list,5)=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF (iscriptdebugind=0)
  FREE RECORD temppersons
  FREE RECORD tempevents
 ENDIF
 SET delapsedtime = datetimediff(cnvtdatetime(curdate,curtime3),dscriptstarttime,5)
 CALL fillsubeventstatus("SELECT","S","cpmnotify_dcp_ce",build("Total time = ",delapsedtime))
 CALL fillsubeventstatus("SELECT","S","cpmnotify_dcp_ce",build("Total patients = ",itotalpersoncnt))
 CALL fillsubeventstatus("SELECT","S","cpmnotify_dcp_ce",build("Total events = ",itotaleventcnt))
 IF (iscriptdebugind=1)
  CALL echo("*******************************************************")
  CALL echo("cpmnotify_dcp_ce Last Modified = 004 04/04/11")
  CALL echo(build("cpmnotify_dcp_ce Total Time = ",delapsedtime))
  CALL echo(build("cpmnotify_dcp_ce Total Patients = ",itotalpersoncnt))
  CALL echo(build("cpmnotify_dcp_ce Total Events = ",itotaleventcnt))
  CALL echo("*******************************************************")
 ENDIF
 SET modify = nopredeclare
END GO
