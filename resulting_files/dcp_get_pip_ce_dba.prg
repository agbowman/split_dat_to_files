CREATE PROGRAM dcp_get_pip_ce:dba
 SET modify = predeclare
 FREE RECORD reply
 RECORD reply(
   1 run_dt_tm = dq8
   1 overlay_ind = i2
   1 person_list[*]
     2 person_id = f8
     2 datalist[*]
       3 encntr_id = f8
       3 event_id = f8
       3 parent_event_id = f8
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
       3 event_end_tz = i4
       3 dynamic_label_id = f8
       3 dynamic_label_name = vc
       3 string_result_list[*]
         4 string_result_text = vc
         4 string_result_format_cd = f8
         4 equation_id = f8
         4 unit_of_measure_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
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
 FREE RECORD tempeventidlist
 RECORD tempeventidlist(
   1 event_id_list[*]
     2 event_id = f8
     2 person_idx = i4
     2 data_idx = i4
 )
 FREE RECORD tempdynamiclabellist
 RECORD tempdynamiclabellist(
   1 dynamic_id_list[*]
     2 ce_dynamic_label_id = f8
     2 person_idx = i4
     2 data_idx = i4
 )
 SET reply->status_data.status = "F"
 DECLARE nodata_ind = i2 WITH protect, noconstant(0)
 DECLARE script_version = c12 WITH protect, noconstant(fillstring(12," "))
 DECLARE debugind = i2 WITH protect, noconstant(0)
 DECLARE serrormsg = vc WITH protect, noconstant("")
 DECLARE ierrorcode = i2 WITH protect, noconstant(0)
 DECLARE max_dt_tm = dq8 WITH protect, constant(cnvtdatetime("31-DEC-2100,00:00:00:00"))
 DECLARE cur_dt_tm = f8 WITH protect, noconstant(cnvtdatetime(curdate,curtime3))
 SET reply->run_dt_tm = cnvtdatetime(curdate,curtime3)
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE event_set_filters = vc WITH protect, noconstant(fillstring(1000," "))
 DECLARE event_set_qual = vc WITH protect, noconstant(fillstring(1000," "))
 DECLARE reqpatientslist = i4 WITH protect, constant(size(request->person_list,5))
 DECLARE es_cnt = i4 WITH protect, noconstant(size(request->event_set_list,5))
 DECLARE act_mean_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",25651,"VIEWRESULT"))
 IF (reqpatientslist=0)
  CALL fillsubeventstatus("dcp_get_pip_ce","Z","REQUEST",
   "Unable to get 'person_list' count from the request.")
  SET nodata_ind = 1
  GO TO exits
 ENDIF
 IF (validate(request->debug_ind))
  SET debugind = request->debug_ind
 ENDIF
 IF (debugind=1)
  CALL echo("*******************************************************")
  CALL echo("Request")
  CALL echorecord(request)
  CALL echo("*******************************************************")
 ENDIF
 DECLARE geteventsets(seventset=vc(ref)) = null
 DECLARE clinicalevententriesforpatientslevel(null) = null
 DECLARE cedynamiclabel(null) = null
 DECLARE identifystringresults(null) = null
 CALL geteventsets(event_set_qual)
 CALL clinicalevententriesforpatientslevel(null)
 CALL cedynamiclabel(null)
 CALL identifystringresults(null)
 SUBROUTINE geteventsets(seventset)
   IF (debugind=1)
    CALL echo("*Entering GetEventSets subroutine*")
   ENDIF
   SET event_set_filters = trim(cnvtstring(request->event_set_list[1].event_set_cd,20,2),3)
   FOR (i = 2 TO es_cnt)
     SET event_set_filters = concat(trim(event_set_filters),", ",trim(cnvtstring(request->
        event_set_list[i].event_set_cd,20,2),3))
   ENDFOR
   SET event_set_qual = trim(concat("ese.event_set_cd in (",trim(event_set_filters),")"))
   IF (debugind=1)
    CALL echo("*Leaving GetEventSets subroutine*")
   ENDIF
 END ;Subroutine
 SUBROUTINE clinicalevententriesforpatientslevel(null)
   IF (debugind=1)
    CALL echo("*Entering ClinicalEventEntriesForPatientsLevel subroutine*")
   ENDIF
   FREE RECORD tempperson
   RECORD tempperson(
     1 person_list[*]
       2 person_id = f8
   )
   DECLARE datacnt = i4 WITH protect, noconstant(0)
   DECLARE eventcnt = i4 WITH protect, noconstant(0)
   DECLARE percnt = i4 WITH protect, noconstant(0)
   DECLARE labelcnt = i4 WITH protect, noconstant(0)
   DECLARE numper = i4 WITH protect, noconstant(0)
   DECLARE expand_sizeper = i4 WITH protect, constant(20)
   DECLARE expand_startper = i4 WITH protect, noconstant(1)
   DECLARE expand_stopper = i4 WITH protect, noconstant(20)
   DECLARE expand_totalper = i4 WITH protect, noconstant(0)
   SET expand_totalper = (ceil((cnvtreal(reqpatientslist)/ expand_sizeper)) * expand_sizeper)
   SET stat = alterlist(tempperson->person_list,expand_totalper)
   FOR (idx = 1 TO expand_totalper)
     IF (idx <= reqpatientslist)
      SET tempperson->person_list[idx].person_id = request->person_list[idx].person_id
     ELSE
      SET tempperson->person_list[idx].person_id = request->person_list[reqpatientslist].person_id
     ENDIF
   ENDFOR
   IF (es_cnt > 0
    AND (request->event_set_list[1].event_set_cd > 0))
    DECLARE eventlistcnt = i4 WITH protect, constant(size(request->event_set_list,5))
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value((expand_totalper/ expand_sizeper))),
      clinical_event ce,
      v500_event_set_explode ese
     PLAN (d
      WHERE assign(expand_startper,evaluate(d.seq,1,1,(expand_startper+ expand_sizeper)))
       AND assign(expand_stopper,(expand_startper+ (expand_sizeper - 1))))
      JOIN (ce
      WHERE expand(numper,expand_startper,expand_stopper,ce.person_id,tempperson->person_list[numper]
       .person_id)
       AND ((ce.clinsig_updt_dt_tm+ 0) >= cnvtdatetime(request->beg_dt_tm))
       AND ce.updt_dt_tm >= cnvtdatetime(request->beg_dt_tm)
       AND ((ce.clinsig_updt_dt_tm+ 0) < cnvtdatetime(request->end_dt_tm))
       AND ((ce.publish_flag+ 0)=1)
       AND ((ce.view_level+ 0) >= 1)
       AND ((ce.valid_until_dt_tm+ 0)=cnvtdatetime(max_dt_tm))
       AND  NOT (((ce.updt_id+ 0)=request->prsnl_id)))
      JOIN (ese
      WHERE ese.event_cd=ce.event_cd
       AND parser(event_set_qual)
       AND  NOT ( EXISTS (
      (SELECT
       dal.parent_entity_id
       FROM dcp_activity_log dal
       WHERE dal.parent_entity_id=ce.event_id
        AND dal.parent_entity_name="CLINICAL_EVENT"
        AND dal.activity_dt_tm >= ce.clinsig_updt_dt_tm
        AND dal.parent_entity_dt_tm >= ce.clinsig_updt_dt_tm
        AND ((dal.prsnl_id+ 0)=request->prsnl_id)
        AND dal.activity_type_cd=act_mean_cd))))
     ORDER BY ce.person_id, ce.event_id
     HEAD REPORT
      stat = alterlist(reply->person_list,reqpatientslist), percnt = 0, labelcnt = 0,
      eventcnt = 0
     HEAD ce.person_id
      percnt = (percnt+ 1), reply->person_list[percnt].person_id = ce.person_id, datacnt = 0
     HEAD ce.event_id
      datacnt = (datacnt+ 1)
      IF (mod(datacnt,100)=1)
       stat = alterlist(reply->person_list[percnt].datalist,(datacnt+ 99))
      ENDIF
      eventcnt = (eventcnt+ 1)
      IF (mod(eventcnt,100)=1)
       stat = alterlist(tempeventidlist->event_id_list,(eventcnt+ 99))
      ENDIF
      reply->person_list[percnt].datalist[datacnt].updt_dt_tm = cnvtdatetime(ce.updt_dt_tm), reply->
      person_list[percnt].datalist[datacnt].encntr_id = ce.encntr_id, reply->person_list[percnt].
      datalist[datacnt].event_id = ce.event_id,
      tempeventidlist->event_id_list[eventcnt].event_id = ce.event_id, tempeventidlist->
      event_id_list[eventcnt].person_idx = percnt, tempeventidlist->event_id_list[eventcnt].data_idx
       = datacnt,
      reply->person_list[percnt].datalist[datacnt].parent_event_id = ce.parent_event_id, reply->
      person_list[percnt].datalist[datacnt].clinical_event_id = ce.clinical_event_id, reply->
      person_list[percnt].datalist[datacnt].event_cd = ce.event_cd,
      reply->person_list[percnt].datalist[datacnt].event_class_cd = ce.event_class_cd, reply->
      person_list[percnt].datalist[datacnt].normalcy_cd = ce.normalcy_cd, reply->person_list[percnt].
      datalist[datacnt].normal_low = ce.normal_low,
      reply->person_list[percnt].datalist[datacnt].normal_high = ce.normal_high, reply->person_list[
      percnt].datalist[datacnt].event_end_dt_tm = ce.event_end_dt_tm, reply->person_list[percnt].
      datalist[datacnt].result_status_cd = ce.result_status_cd,
      reply->person_list[percnt].datalist[datacnt].result_val = ce.result_val, reply->person_list[
      percnt].datalist[datacnt].verified_prsnl_id = ce.verified_prsnl_id, reply->person_list[percnt].
      datalist[datacnt].event_tag = ce.event_tag,
      reply->person_list[percnt].datalist[datacnt].performed_prsnl_id = ce.performed_prsnl_id, reply
      ->person_list[percnt].datalist[datacnt].result_units_cd = ce.result_units_cd, reply->
      person_list[percnt].datalist[datacnt].updt_id = ce.updt_id,
      reply->person_list[percnt].datalist[datacnt].event_end_tz = ce.event_end_tz
      IF (ce.ce_dynamic_label_id > 0)
       labelcnt = (labelcnt+ 1)
       IF (mod(labelcnt,100)=1)
        stat = alterlist(tempdynamiclabellist->dynamic_id_list,(labelcnt+ 99))
       ENDIF
       tempdynamiclabellist->dynamic_id_list[labelcnt].ce_dynamic_label_id = ce.ce_dynamic_label_id,
       tempdynamiclabellist->dynamic_id_list[labelcnt].person_idx = percnt, tempdynamiclabellist->
       dynamic_id_list[labelcnt].data_idx = datacnt
      ENDIF
     FOOT  ce.person_id
      stat = alterlist(reply->person_list[percnt].datalist,datacnt)
     FOOT REPORT
      stat = alterlist(tempeventidlist->event_id_list,eventcnt), stat = alterlist(
       tempdynamiclabellist->dynamic_id_list,labelcnt), stat = alterlist(reply->person_list,percnt)
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value((expand_totalper/ expand_sizeper))),
      clinical_event ce
     PLAN (d
      WHERE assign(expand_startper,evaluate(d.seq,1,1,(expand_startper+ expand_sizeper)))
       AND assign(expand_stopper,(expand_startper+ (expand_sizeper - 1))))
      JOIN (ce
      WHERE expand(numper,expand_startper,expand_stopper,ce.person_id,tempperson->person_list[numper]
       .person_id)
       AND ((ce.clinsig_updt_dt_tm+ 0) >= cnvtdatetime(request->beg_dt_tm))
       AND ce.updt_dt_tm >= cnvtdatetime(request->beg_dt_tm)
       AND ((ce.clinsig_updt_dt_tm+ 0) < cnvtdatetime(request->end_dt_tm))
       AND ((ce.publish_flag+ 0)=1)
       AND ((ce.view_level+ 0) >= 1)
       AND ((ce.valid_until_dt_tm+ 0)=cnvtdatetime(max_dt_tm))
       AND  NOT (((ce.updt_id+ 0)=request->prsnl_id))
       AND  NOT ( EXISTS (
      (SELECT
       dal.parent_entity_id
       FROM dcp_activity_log dal
       WHERE dal.parent_entity_id=ce.event_id
        AND dal.parent_entity_name="CLINICAL_EVENT"
        AND dal.activity_dt_tm >= ce.clinsig_updt_dt_tm
        AND dal.parent_entity_dt_tm >= ce.clinsig_updt_dt_tm
        AND ((dal.prsnl_id+ 0)=request->prsnl_id)
        AND dal.activity_type_cd=act_mean_cd))))
     ORDER BY ce.person_id, ce.event_id
     HEAD REPORT
      stat = alterlist(reply->person_list,reqpatientslist), percnt = 0, eventcnt = 0,
      labelcnt = 0
     HEAD ce.person_id
      percnt = (percnt+ 1), reply->person_list[percnt].person_id = ce.person_id, datacnt = 0
     HEAD ce.event_id
      datacnt = (datacnt+ 1)
      IF (mod(datacnt,100)=1)
       stat = alterlist(reply->person_list[percnt].datalist,(datacnt+ 99))
      ENDIF
      eventcnt = (eventcnt+ 1)
      IF (mod(eventcnt,100)=1)
       stat = alterlist(tempeventidlist->event_id_list,(eventcnt+ 99))
      ENDIF
      reply->person_list[percnt].datalist[datacnt].updt_dt_tm = cnvtdatetime(ce.updt_dt_tm), reply->
      person_list[percnt].datalist[datacnt].encntr_id = ce.encntr_id, reply->person_list[percnt].
      datalist[datacnt].event_id = ce.event_id,
      tempeventidlist->event_id_list[eventcnt].event_id = ce.event_id, tempeventidlist->
      event_id_list[eventcnt].person_idx = percnt, tempeventidlist->event_id_list[eventcnt].data_idx
       = datacnt,
      reply->person_list[percnt].datalist[datacnt].parent_event_id = ce.parent_event_id, reply->
      person_list[percnt].datalist[datacnt].clinical_event_id = ce.clinical_event_id, reply->
      person_list[percnt].datalist[datacnt].event_cd = ce.event_cd,
      reply->person_list[percnt].datalist[datacnt].event_class_cd = ce.event_class_cd, reply->
      person_list[percnt].datalist[datacnt].normalcy_cd = ce.normalcy_cd, reply->person_list[percnt].
      datalist[datacnt].normal_low = ce.normal_low,
      reply->person_list[percnt].datalist[datacnt].normal_high = ce.normal_high, reply->person_list[
      percnt].datalist[datacnt].event_end_dt_tm = ce.event_end_dt_tm, reply->person_list[percnt].
      datalist[datacnt].result_status_cd = ce.result_status_cd,
      reply->person_list[percnt].datalist[datacnt].result_val = ce.result_val, reply->person_list[
      percnt].datalist[datacnt].verified_prsnl_id = ce.verified_prsnl_id, reply->person_list[percnt].
      datalist[datacnt].event_tag = ce.event_tag,
      reply->person_list[percnt].datalist[datacnt].performed_prsnl_id = ce.performed_prsnl_id, reply
      ->person_list[percnt].datalist[datacnt].result_units_cd = ce.result_units_cd, reply->
      person_list[percnt].datalist[datacnt].updt_id = ce.updt_id,
      reply->person_list[percnt].datalist[datacnt].event_end_tz = ce.event_end_tz
      IF (ce.ce_dynamic_label_id > 0)
       labelcnt = (labelcnt+ 1)
       IF (mod(labelcnt,100)=1)
        stat = alterlist(tempdynamiclabellist->dynamic_id_list,(labelcnt+ 99))
       ENDIF
       tempdynamiclabellist->dynamic_id_list[labelcnt].ce_dynamic_label_id = ce.ce_dynamic_label_id,
       tempdynamiclabellist->dynamic_id_list[labelcnt].person_idx = percnt, tempdynamiclabellist->
       dynamic_id_list[labelcnt].data_idx = datacnt
      ENDIF
     FOOT  ce.person_id
      stat = alterlist(reply->person_list[percnt].datalist,datacnt)
     FOOT REPORT
      stat = alterlist(tempeventidlist->event_id_list,eventcnt), stat = alterlist(
       tempdynamiclabellist->dynamic_id_list,labelcnt), stat = alterlist(reply->person_list,percnt)
     WITH nocounter
    ;end select
   ENDIF
   IF (debugind=1)
    CALL echo("*Leaving ClinicalEventEntriesForPatientLevel subroutine*")
   ENDIF
 END ;Subroutine
 SUBROUTINE cedynamiclabel(null)
   IF (debugind=1)
    CALL echo("*Entering CeDynamicLabel subroutine*")
   ENDIF
   FREE RECORD tempdynamiclist
   RECORD tempdynamiclist(
     1 dynamiclist[*]
       2 dynamic_id = f8
   )
   DECLARE labellistcount = i4 WITH constant(size(tempdynamiclabellist->dynamic_id_list,5))
   IF (labellistcount > 0)
    DECLARE cesridx = i4 WITH noconstant(0), protect
    DECLARE locpos = i4 WITH noconstant(0), protect
    DECLARE locidx = i4 WITH noconstant(0), protect
    DECLARE dataidx = i4 WITH noconstant(0), protect
    DECLARE personidx = i4 WITH noconstant(0), protect
    DECLARE numlabel = i4 WITH protect, noconstant(0)
    DECLARE expand_sizelabel = i4 WITH protect, constant(20)
    DECLARE expand_startlabel = i4 WITH protect, noconstant(1)
    DECLARE expand_stoplabel = i4 WITH protect, noconstant(20)
    DECLARE expand_totallabel = i4 WITH protect, noconstant(0)
    SET expand_totallabel = (ceil((cnvtreal(labellistcount)/ expand_sizelabel)) * expand_sizelabel)
    SET stat = alterlist(tempdynamiclist->dynamiclist,expand_totallabel)
    FOR (idx = 1 TO expand_totallabel)
      IF (idx <= labellistcount)
       SET tempdynamiclist->dynamiclist[idx].dynamic_id = tempdynamiclabellist->dynamic_id_list[idx].
       ce_dynamic_label_id
      ELSE
       SET tempdynamiclist->dynamiclist[idx].dynamic_id = tempdynamiclabellist->dynamic_id_list[
       labellistcount].ce_dynamic_label_id
      ENDIF
    ENDFOR
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value((expand_totallabel/ expand_sizelabel))),
      ce_dynamic_label cdl
     PLAN (d
      WHERE assign(expand_startlabel,evaluate(d.seq,1,1,(expand_startlabel+ expand_sizelabel)))
       AND assign(expand_stoplabel,(expand_startlabel+ (expand_sizelabel - 1))))
      JOIN (cdl
      WHERE expand(numlabel,expand_startlabel,expand_stoplabel,cdl.ce_dynamic_label_id,
       tempdynamiclist->dynamiclist[numlabel].dynamic_id))
     ORDER BY cdl.ce_dynamic_label_id
     HEAD cdl.ce_dynamic_label_id
      dataidx = 0, personidx = 0
      FOR (idx = 1 TO labellistcount)
        IF ((cdl.ce_dynamic_label_id=tempdynamiclabellist->dynamic_id_list[idx].ce_dynamic_label_id))
         dataidx = tempdynamiclabellist->dynamic_id_list[idx].data_idx, personidx =
         tempdynamiclabellist->dynamic_id_list[idx].person_idx
         IF (cdl.ce_dynamic_label_id != 0
          AND dataidx != 0
          AND personidx != 0)
          reply->person_list[personidx].datalist[dataidx].dynamic_label_id = cdl.ce_dynamic_label_id,
          reply->person_list[personidx].datalist[dataidx].dynamic_label_name = cdl.label_name
         ENDIF
        ENDIF
      ENDFOR
     WITH nocounter
    ;end select
   ENDIF
   IF (debugind=1)
    CALL echo("*Leaving CeDynamicLabel subroutine*")
   ENDIF
 END ;Subroutine
 SUBROUTINE identifystringresults(null)
   IF (debugind=1)
    CALL echo("*Entering IdentifyStringResults subroutine*")
   ENDIF
   DECLARE event_id_count = i4 WITH constant(size(tempeventidlist->event_id_list,5))
   IF (event_id_count > 0)
    DECLARE csr_expand_idx = i4 WITH noconstant(0), protect
    DECLARE exp_max_ei_cnt_str = i4 WITH constant(100), protect
    DECLARE ei_idx_cnt_str = i4 WITH constant(ceil(((event_id_count * 1.0)/ exp_max_ei_cnt_str))),
    protect
    DECLARE ei_max_cnt_str = i4 WITH constant((ei_idx_cnt_str * exp_max_ei_cnt_str)), protect
    DECLARE ei_start_str = i4 WITH noconstant(1), protect
    DECLARE event_count = i4 WITH constant(size(tempeventidlist->event_id_list,5))
    SET stat = alterlist(tempeventidlist->event_id_list,ei_max_cnt_str)
    FOR (ei_idx_str = (event_count+ 1) TO ei_max_cnt_str)
      SET tempeventidlist->event_id_list[ei_idx_str].event_id = tempeventidlist->event_id_list[
      event_count].event_id
    ENDFOR
    DECLARE locpos_str = i4 WITH noconstant(0)
    DECLARE entidx_str = i4 WITH noconstant(0)
    DECLARE datidx_str = i4 WITH noconstant(0)
    DECLARE locidx_str = i4 WITH noconstant(0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(ei_idx_cnt_str)),
      ce_string_result csr
     PLAN (d
      WHERE assign(ei_start_str,evaluate(d.seq,1,1,(ei_start_str+ exp_max_ei_cnt_str))))
      JOIN (csr
      WHERE expand(csr_expand_idx,ei_start_str,(ei_start_str+ (exp_max_ei_cnt_str - 1)),csr.event_id,
       tempeventidlist->event_id_list[csr_expand_idx].event_id)
       AND csr.valid_until_dt_tm > cnvtdatetime(cur_dt_tm))
     ORDER BY csr.event_id
     HEAD csr.event_id
      datidx_str = 0, entidx_str = 0, locpos_str = locateval(locidx_str,1,event_count,csr.event_id,
       tempeventidlist->event_id_list[locidx_str].event_id)
      IF (locpos_str != 0)
       datidx_str = tempeventidlist->event_id_list[locpos_str].data_idx, entidx_str = tempeventidlist
       ->event_id_list[locpos_str].person_idx
      ENDIF
     DETAIL
      IF (csr.event_id > 0
       AND datidx_str != 0
       AND entidx_str != 0)
       stat = alterlist(reply->person_list[entidx_str].datalist[datidx_str].string_result_list,1),
       reply->person_list[entidx_str].datalist[datidx_str].string_result_list[1].string_result_text
        = csr.string_result_text, reply->person_list[entidx_str].datalist[datidx_str].
       string_result_list[1].string_result_format_cd = csr.string_result_format_cd,
       reply->person_list[entidx_str].datalist[datidx_str].string_result_list[1].equation_id = csr
       .equation_id, reply->person_list[entidx_str].datalist[datidx_str].string_result_list[1].
       unit_of_measure_cd = csr.unit_of_measure_cd
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   IF (debugind=1)
    CALL echo("*Leaving IdentifyStringResults subroutine*")
   ENDIF
 END ;Subroutine
#exits
 SET ierrorcode = error(serrormsg,1)
 IF (ierrorcode != 0)
  CALL echo("*********************************")
  CALL echo(build("ERROR MESSAGE : ",serrormsg))
  CALL echo("*********************************")
  CALL fillsubeventstatus("ERROR","F","dcp_get_pip_ce",serrormsg)
  SET reply->status_data.status = "F"
 ELSEIF (nodata_ind=1)
  SET reply->status_data.status = "Z"
 ELSEIF (size(reply->person_list,5)=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET script_version = "05 09/30/11"
 IF (debugind=1)
  CALL echorecord(request)
  CALL echorecord(reply)
  CALL echo(build("Script Version: ",script_version))
 ELSE
  FREE RECORD tempeventidlist
  FREE RECORD tempdynamiclabellist
 ENDIF
 SET modify = nopredeclare
END GO
