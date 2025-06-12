CREATE PROGRAM bhs_athn_get_appts_by_res_cd
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 DECLARE schstateparam = vc WITH protect, noconstant("")
 DECLARE schstatecd = f8 WITH protect, noconstant(0.0)
 DECLARE schstatecnt = i4 WITH protect, noconstant(0)
 DECLARE startpos = i4 WITH protect, noconstant(0)
 DECLARE endpos = i4 WITH protect, noconstant(0)
 DECLARE param = vc WITH protect, noconstant("")
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE jdx = i4 WITH protect, noconstant(0)
 DECLARE locidx = i4 WITH protect, noconstant(0)
 DECLARE loccnt = i4 WITH protect, noconstant(0)
 DECLARE encidx = i4 WITH protect, noconstant(0)
 DECLARE enccnt = i4 WITH protect, noconstant(0)
 DECLARE residx = i4 WITH protect, noconstant(0)
 DECLARE rescnt = i4 WITH protect, noconstant(0)
 DECLARE patidx = i4 WITH protect, noconstant(0)
 DECLARE patcnt = i4 WITH protect, noconstant(0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE state_cd_pos = i4 WITH protect, noconstant(0)
 DECLARE apptsort_pos = i4 WITH protect, noconstant(0)
 DECLARE valid_appt_found_ind = i2 WITH protect, noconstant(0)
 DECLARE c_facility_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",222,"FACILITY"))
 DECLARE c_building_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",222,"BUILDING"))
 DECLARE c_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE c_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"CMRN"))
 DECLARE t_line = vc
 FREE RECORD sch_states
 RECORD sch_states(
   1 list[*]
     2 state_cd = f8
 )
 FREE RECORD locations
 RECORD locations(
   1 list[*]
     2 location_cd = f8
     2 facility_cd = f8
     2 facility_disp = vc
 )
 FREE RECORD encounters
 RECORD encounters(
   1 list[*]
     2 person_id = f8
     2 encntr_id = f8
     2 fin = vc
     2 encntr_type_cd = f8
     2 encntr_type_class_cd = f8
 )
 FREE RECORD resources
 RECORD resources(
   1 list[*]
     2 scheduled_resource_cd = f8
     2 scheduled_resource_disp = vc
     2 service_resource_cd = f8
     2 service_resource_disp = vc
     2 location_cd = f8
     2 location_disp = vc
 )
 FREE RECORD patients
 RECORD patients(
   1 list[*]
     2 person_id = f8
     2 name_full_formatted = vc
     2 age_in_days = f8
     2 sex_cd = f8
     2 sex_disp = vc
     2 mrn = vc
     2 dob = vc
     2 age = vc
 )
 FREE RECORD apptsort
 RECORD apptsort(
   1 list[*]
     2 sch_event_id = f8
     2 sch_appt_id = f8
     2 schedule_seq = i4
 )
 FREE RECORD req_get_appt_resource
 RECORD req_get_appt_resource(
   1 call_echo_ind = i2
   1 security_ind = i2
   1 security_user_id = f8
   1 secured_scheme_id = f8
   1 secured_scheme_ind = i2
   1 load_order_diag_ind = i2
   1 disviewpat_ind = i2
   1 qual[*]
     2 resource_cd = f8
     2 beg_dt_tm = dq8
     2 end_dt_tm = dq8
     2 resource_ind = i2
     2 person_ind = i2
   1 load_block_schedule_ind = i2
 ) WITH protect
 FREE RECORD rep_get_appt_resource
 RECORD rep_get_appt_resource(
   1 qual_cnt = i4
   1 qual[*]
     2 resource_cd = f8
     2 person_id = f8
     2 qual_cnt = i4
     2 appointment[*]
       3 sch_appt_id = f8
       3 appt_type_cd = f8
       3 appt_type_desc = vc
       3 beg_dt_tm = dq8
       3 end_dt_tm = dq8
       3 sch_state_cd = f8
       3 sch_state_disp = vc
       3 state_meaning = vc
       3 sch_event_id = f8
       3 schedule_seq = i4
       3 schedule_id = f8
       3 location_cd = f8
       3 appt_reason_free = vc
       3 location_freetext = vc
       3 appt_synonym_cd = f8
       3 appt_synonym_free = vc
       3 duration = i4
       3 setup_duration = i4
       3 cleanup_duration = i4
       3 appt_scheme_id = f8
       3 req_prsnl_id = f8
       3 req_prsnl_name = vc
       3 primary_resource_cd = f8
       3 primary_resource_mnem = vc
       3 prsnl_id = vc
       3 prsnl = vc
       3 slot_type_id = f8
       3 slot_mnemonic = vc
       3 slot_scheme_id = f8
       3 description = vc
       3 apply_list_id = f8
       3 slot_state_cd = f8
       3 slot_state_meaning = vc
       3 def_slot_id = f8
       3 apply_slot_id = f8
       3 booking_id = f8
       3 contiguous_ind = i2
       3 bit_mask = i4
       3 interval = i4
       3 appttype_sec_ind = i2
       3 location_sec_ind = i2
       3 slottype_sec_ind = i2
       3 order_diagnosis = vc
       3 qual_cnt = i4
       3 patient[*]
         4 person_id = f8
         4 name = vc
         4 encntr_id = f8
         4 parent_id = f8
         4 person_hom_phone = vc
         4 person_bus_phone = vc
         4 birth_dt_tm = vc
       3 def_qual_cnt = i4
       3 def_qual[*]
         4 appt_def_id = f8
         4 beg_dt_tm = dq8
         4 end_dt_tm = dq8
         4 duration = i4
         4 slot_type_id = f8
         4 sch_flex_id = f8
         4 interval = i4
         4 slot_mnemonic = vc
         4 description = vc
         4 slot_scheme_id = f8
         4 slottype_sec_ind = i2
       3 patseen_dt_tm = dq8
       3 wait_time = vc
       3 anesthesia_type = vc
       3 primary_order = vc
       3 scheduling_comment = vc
       3 comment_sec_ind = i2
       3 block_schedule_ind = i2
       3 group_slot_link_value = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 IF (( $2 <= 0.0))
  CALL echo("INVALID RESOURCE CODE PARAMETER...EXITING")
  GO TO exit_script
 ELSEIF (((textlen( $3)=0) OR (cnvtdatetime( $3) <= 0)) )
  CALL echo("INVALID BEGIN DTTM PARAMETER...EXITING")
  GO TO exit_script
 ELSEIF (((textlen( $4)=0) OR (cnvtdatetime( $4) <= 0)) )
  CALL echo("INVALID END DTTM PARAMETER...EXITING")
  GO TO exit_script
 ELSEIF (textlen( $5)=0)
  CALL echo("INVALID SCHEDULED STATE PARAMETER...EXITING")
  GO TO exit_script
 ENDIF
 CALL echo("PARSING SCHEDULED STATE PARAMETER")
 SET startpos = 1
 SET schstateparam = trim( $5,3)
 WHILE (size(schstateparam) > 0)
   SET endpos = (findstring(",",schstateparam,1) - 1)
   IF (endpos <= 0)
    SET endpos = size(schstateparam)
   ENDIF
   CALL echo(build("ENDPOS:",endpos))
   IF (startpos < endpos)
    SET param = substring(1,endpos,schstateparam)
    CALL echo(build("PARAM:",param))
    SET schstatecd = uar_get_code_by("MEANING",14233,param)
    IF (schstatecd > 0.0)
     CALL echo(build("ADDING SCH_STATE_CD TO LIST: ",schstatecd))
     SET schstatecnt += 1
     CALL echo(build("SCHSTATECNT:",schstatecnt))
     SET stat = alterlist(sch_states->list,schstatecnt)
     SET sch_states->list[schstatecnt].state_cd = schstatecd
    ELSE
     CALL echo(build("STATE_CD LOOKUP FAILED!!!: ",param))
    ENDIF
   ENDIF
   SET schstateparam = substring((endpos+ 2),(size(schstateparam) - endpos),schstateparam)
   CALL echo(build("SCHSTATEPARAM:",schstateparam))
   CALL echo(size(schstateparam))
 ENDWHILE
 CALL echorecord(sch_states)
 SET stat = alterlist(req_get_appt_resource->qual,1)
 SET req_get_appt_resource->qual[1].resource_cd =  $2
 SET req_get_appt_resource->qual[1].resource_ind = 1
 SET req_get_appt_resource->qual[1].beg_dt_tm = cnvtdatetime( $3)
 SET req_get_appt_resource->qual[1].end_dt_tm = cnvtdatetime( $4)
 EXECUTE sch_get_appt_resource  WITH replace("REQUEST","REQ_GET_APPT_RESOURCE"), replace("REPLY",
  "REP_GET_APPT_RESOURCE")
 CALL echorecord(rep_get_appt_resource)
 IF ((rep_get_appt_resource->status_data.status="S")
  AND size(rep_get_appt_resource->qual,5) > 0
  AND (rep_get_appt_resource->qual[1].qual_cnt > 0))
  SET idx = 1
  WHILE ((idx <= rep_get_appt_resource->qual[1].qual_cnt)
   AND valid_appt_found_ind=0)
    SET pos = locateval(jdx,1,size(sch_states->list,5),rep_get_appt_resource->qual[1].appointment[idx
     ].sch_state_cd,sch_states->list[jdx].state_cd)
    IF (pos > 0)
     SET valid_appt_found_ind = 1
    ENDIF
    SET idx += 1
  ENDWHILE
 ENDIF
 IF (valid_appt_found_ind=1)
  SET loccnt = 0
  SET stat = alterlist(locations->list,size(rep_get_appt_resource->qual[1].appointment,5))
  SELECT INTO "NL:"
   FROM location_group lg,
    location_group lg2,
    location l
   PLAN (lg
    WHERE expand(idx,1,rep_get_appt_resource->qual[1].qual_cnt,lg.child_loc_cd,rep_get_appt_resource
     ->qual[1].appointment[idx].location_cd)
     AND ((lg.root_loc_cd+ 0)=0.0)
     AND ((lg.active_ind+ 0)=1)
     AND lg.location_group_type_cd=c_building_cd)
    JOIN (lg2
    WHERE lg2.child_loc_cd=lg.parent_loc_cd
     AND lg2.root_loc_cd=0
     AND lg2.active_ind=1
     AND lg2.location_group_type_cd=c_facility_cd)
    JOIN (l
    WHERE l.location_cd=lg2.parent_loc_cd
     AND l.active_ind=1)
   ORDER BY lg.child_loc_cd, lg2.parent_loc_cd
   HEAD lg.child_loc_cd
    locidx = locateval(idx,1,rep_get_appt_resource->qual[1].qual_cnt,lg.child_loc_cd,
     rep_get_appt_resource->qual[1].appointment[idx].location_cd)
   HEAD lg2.parent_loc_cd
    IF (locidx > 0)
     pos = locateval(idx,1,loccnt,lg.child_loc_cd,locations->list[idx].location_cd)
     IF (pos=0)
      loccnt += 1, locations->list[loccnt].location_cd = lg.child_loc_cd, locations->list[loccnt].
      facility_cd = lg2.parent_loc_cd,
      locations->list[loccnt].facility_disp = uar_get_code_display(locations->list[loccnt].
       facility_cd)
     ENDIF
    ENDIF
   WITH nocounter, time = 30, expand = 1
  ;end select
  SET stat = alterlist(locations->list,loccnt)
  CALL echorecord(locations)
 ENDIF
 IF (valid_appt_found_ind=1)
  SET stat = alterlist(encounters->list,size(rep_get_appt_resource->qual[1].appointment,5))
  FOR (idx = 1 TO size(rep_get_appt_resource->qual[1].appointment,5))
   SET pos = locateval(encidx,1,enccnt,rep_get_appt_resource->qual[1].appointment[idx].patient[1].
    encntr_id,encounters->list[encidx].encntr_id)
   IF (pos=0)
    SET enccnt += 1
    SET encounters->list[enccnt].encntr_id = rep_get_appt_resource->qual[1].appointment[idx].patient[
    1].encntr_id
    SET encounters->list[enccnt].person_id = rep_get_appt_resource->qual[1].appointment[idx].patient[
    1].person_id
   ENDIF
  ENDFOR
  SET stat = alterlist(encounters->list,enccnt)
  SELECT INTO "NL:"
   FROM encounter e,
    encntr_alias ea
   PLAN (e
    WHERE expand(idx,1,enccnt,e.encntr_id,encounters->list[idx].encntr_id)
     AND e.active_ind=1
     AND e.beg_effective_dt_tm < sysdate
     AND e.end_effective_dt_tm > sysdate)
    JOIN (ea
    WHERE ea.encntr_id=e.encntr_id
     AND ea.active_ind=1
     AND ea.beg_effective_dt_tm < sysdate
     AND ea.end_effective_dt_tm > sysdate
     AND ea.encntr_alias_type_cd=c_fin_cd)
   ORDER BY e.encntr_id, ea.encntr_alias_id
   HEAD e.encntr_id
    encidx = locateval(idx,1,enccnt,e.encntr_id,encounters->list[idx].encntr_id)
    IF (encidx > 0)
     encounters->list[encidx].fin = ea.alias, encounters->list[encidx].encntr_type_cd = e
     .encntr_type_cd, encounters->list[encidx].encntr_type_class_cd = e.encntr_type_class_cd
    ENDIF
   WITH nocounter, time = 30, expand = 1
  ;end select
  CALL echorecord(encounters)
 ENDIF
 IF (valid_appt_found_ind=1)
  SET stat = alterlist(resources->list,size(rep_get_appt_resource->qual[1].appointment,5))
  FOR (idx = 1 TO size(rep_get_appt_resource->qual[1].appointment,5))
   SET pos = locateval(residx,1,rescnt,rep_get_appt_resource->qual[1].appointment[idx].
    primary_resource_cd,resources->list[residx].scheduled_resource_cd)
   IF (pos=0)
    SET rescnt += 1
    SET resources->list[rescnt].scheduled_resource_cd = rep_get_appt_resource->qual[1].appointment[
    idx].primary_resource_cd
    SET resources->list[rescnt].scheduled_resource_disp = uar_get_code_display(resources->list[rescnt
     ].scheduled_resource_cd)
   ENDIF
  ENDFOR
  SET stat = alterlist(resources->list,rescnt)
  SELECT INTO "NL:"
   FROM sch_resource r,
    service_resource sr
   PLAN (r
    WHERE expand(idx,1,rescnt,r.resource_cd,resources->list[idx].scheduled_resource_cd)
     AND r.active_ind=1
     AND r.beg_effective_dt_tm < sysdate
     AND r.end_effective_dt_tm > sysdate)
    JOIN (sr
    WHERE sr.service_resource_cd=r.service_resource_cd
     AND sr.active_ind=1
     AND sr.beg_effective_dt_tm < sysdate
     AND sr.end_effective_dt_tm > sysdate)
   ORDER BY r.resource_cd
   HEAD r.resource_cd
    residx = locateval(idx,1,rescnt,r.resource_cd,resources->list[idx].scheduled_resource_cd)
    IF (residx > 0)
     IF (sr.service_resource_cd > 0)
      resources->list[residx].service_resource_cd = sr.service_resource_cd, resources->list[residx].
      service_resource_disp = uar_get_code_display(sr.service_resource_cd)
     ENDIF
     IF (sr.location_cd > 0)
      resources->list[residx].location_cd = sr.location_cd, resources->list[residx].location_disp =
      uar_get_code_display(sr.location_cd)
     ENDIF
    ENDIF
   WITH nocounter, time = 30, expand = 1
  ;end select
  CALL echorecord(resources)
 ENDIF
 IF (valid_appt_found_ind=1)
  SET stat = alterlist(patients->list,size(rep_get_appt_resource->qual[1].appointment,5))
  FOR (idx = 1 TO size(rep_get_appt_resource->qual[1].appointment,5))
   SET pos = locateval(patidx,1,patcnt,rep_get_appt_resource->qual[1].appointment[idx].patient[1].
    person_id,patients->list[patidx].person_id)
   IF (pos=0)
    SET patcnt += 1
    SET patients->list[patcnt].person_id = rep_get_appt_resource->qual[1].appointment[idx].patient[1]
    .person_id
   ENDIF
  ENDFOR
  SET stat = alterlist(patients->list,patcnt)
  SELECT INTO "NL:"
   FROM person p,
    person_alias pa
   PLAN (p
    WHERE expand(idx,1,patcnt,p.person_id,patients->list[idx].person_id)
     AND p.active_ind=1
     AND p.beg_effective_dt_tm < sysdate
     AND p.end_effective_dt_tm > sysdate)
    JOIN (pa
    WHERE pa.person_id=p.person_id
     AND pa.active_ind=1
     AND pa.beg_effective_dt_tm < sysdate
     AND pa.end_effective_dt_tm > sysdate
     AND pa.person_alias_type_cd=c_mrn_cd)
   ORDER BY p.person_id
   HEAD p.person_id
    patidx = locateval(idx,1,patcnt,p.person_id,patients->list[idx].person_id)
    IF (patidx > 0)
     patients->list[patidx].name_full_formatted = p.name_full_formatted, patients->list[patidx].
     age_in_days = datetimediff(sysdate,p.birth_dt_tm), patients->list[patidx].sex_cd = p.sex_cd,
     patients->list[patidx].sex_disp = uar_get_code_display(p.sex_cd), patients->list[patidx].mrn =
     pa.alias, patients->list[patidx].dob = format(p.birth_dt_tm,"MM/DD/YYYY HH:MM;;D"),
     patients->list[patidx].age = cnvtage(p.birth_dt_tm)
    ENDIF
   WITH nocounter, time = 30, expand = 1
  ;end select
  CALL echorecord(patients)
 ENDIF
 IF (valid_appt_found_ind=1)
  DECLARE sortcnt = i4 WITH protect, noconstant(0)
  SET stat = alterlist(apptsort->list,size(rep_get_appt_resource->qual[1].appointment,5))
  FOR (idx = 1 TO size(rep_get_appt_resource->qual[1].appointment,5))
   SET pos = locateval(locidx,1,sortcnt,rep_get_appt_resource->qual[1].appointment[idx].sch_event_id,
    apptsort->list[locidx].sch_event_id)
   IF (pos=0)
    SET sortcnt += 1
    SET apptsort->list[sortcnt].sch_event_id = rep_get_appt_resource->qual[1].appointment[idx].
    sch_event_id
    SET apptsort->list[sortcnt].sch_appt_id = rep_get_appt_resource->qual[1].appointment[idx].
    sch_appt_id
    SET apptsort->list[sortcnt].schedule_seq = rep_get_appt_resource->qual[1].appointment[idx].
    schedule_seq
   ELSEIF ((rep_get_appt_resource->qual[1].appointment[idx].schedule_seq > apptsort->list[pos].
   schedule_seq))
    SET apptsort->list[pos].sch_appt_id = rep_get_appt_resource->qual[1].appointment[idx].sch_appt_id
    SET apptsort->list[pos].schedule_seq = rep_get_appt_resource->qual[1].appointment[idx].
    schedule_seq
   ENDIF
  ENDFOR
  SET stat = alterlist(apptsort->list,sortcnt)
  CALL echorecord(apptsort)
 ENDIF
 FOR (i = 1 TO rep_get_appt_resource->qual_cnt)
   FOR (j = 1 TO rep_get_appt_resource->qual[i].qual_cnt)
     SELECT INTO "nl:"
      FROM sch_resource sr,
       prsnl pr
      PLAN (sr
       WHERE (sr.resource_cd=rep_get_appt_resource->qual[i].appointment[j].primary_resource_cd))
       JOIN (pr
       WHERE pr.person_id=sr.person_id)
      DETAIL
       rep_get_appt_resource->qual[i].appointment[j].prsnl_id = trim(cnvtstring(pr.person_id)),
       rep_get_appt_resource->qual[i].appointment[j].prsnl = pr.name_full_formatted
      WITH nocounter, time = 30
     ;end select
   ENDFOR
 ENDFOR
#exit_script
 IF (size(trim(moutputdevice,3)) > 0)
  DECLARE v1 = vc WITH protect, noconstant("")
  DECLARE v2 = vc WITH protect, noconstant("")
  DECLARE v3 = vc WITH protect, noconstant("")
  DECLARE v4 = vc WITH protect, noconstant("")
  DECLARE v5 = vc WITH protect, noconstant("")
  DECLARE v6 = vc WITH protect, noconstant("")
  DECLARE v7 = vc WITH protect, noconstant("")
  DECLARE v8 = vc WITH protect, noconstant("")
  DECLARE v9 = vc WITH protect, noconstant("")
  DECLARE v10 = vc WITH protect, noconstant("")
  DECLARE v11 = vc WITH protect, noconstant("")
  DECLARE v12 = vc WITH protect, noconstant("")
  DECLARE v13 = vc WITH protect, noconstant("")
  DECLARE v14 = vc WITH protect, noconstant("")
  DECLARE v15 = vc WITH protect, noconstant("")
  DECLARE v16 = vc WITH protect, noconstant("")
  DECLARE v17 = vc WITH protect, noconstant("")
  DECLARE v18 = vc WITH protect, noconstant("")
  DECLARE v19 = vc WITH protect, noconstant("")
  DECLARE v20 = vc WITH protect, noconstant("")
  DECLARE v21 = vc WITH protect, noconstant("")
  DECLARE v22 = vc WITH protect, noconstant("")
  DECLARE v23 = vc WITH protect, noconstant("")
  DECLARE v24 = vc WITH protect, noconstant("")
  DECLARE v25 = vc WITH protect, noconstant("")
  DECLARE v26 = vc WITH protect, noconstant("")
  DECLARE v27 = vc WITH protect, noconstant("")
  DECLARE v28 = vc WITH protect, noconstant("")
  DECLARE v29 = vc WITH protect, noconstant("")
  DECLARE v30 = vc WITH protect, noconstant("")
  DECLARE v31 = vc WITH protect, noconstant("")
  DECLARE v32 = vc WITH protect, noconstant("")
  DECLARE v33 = vc WITH protect, noconstant("")
  DECLARE facility_cd = f8 WITH protect, noconstant(0.0)
  DECLARE facility_disp = vc WITH protect, noconstant("")
  DECLARE resource_loc_cd = f8 WITH protect, noconstant(0.0)
  DECLARE resource_loc_disp = vc WITH protect, noconstant("")
  DECLARE name_full_formatted = vc WITH protect, noconstant("")
  DECLARE age_in_days = f8 WITH protect, noconstant(0.0)
  DECLARE sex_cd = f8 WITH protect, noconstant(0.0)
  DECLARE sex_disp = vc WITH protect, noconstant("")
  DECLARE mrn = vc WITH protect, noconstant("")
  DECLARE fin = vc WITH protect, noconstant("")
  DECLARE dob = vc WITH protect, noconstant("")
  DECLARE age = vc WITH protect, noconstant("")
  DECLARE sch_evnt_id = f8 WITH protect, noconstant(0)
  DECLARE encntr_type_cd = f8 WITH protect, noconstant(0)
  DECLARE encntr_type_class_cd = f8 WITH protect, noconstant(0)
  IF (valid_appt_found_ind=1)
   SELECT INTO value(moutputdevice)
    FROM (dummyt d  WITH seq = value(rep_get_appt_resource->qual[1].qual_cnt))
    PLAN (d
     WHERE d.seq > 0)
    HEAD REPORT
     html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
      '"',"UTF-8",'"'," ?>"), col 0, html_tag,
     row + 1, col + 1, "<ReplyMessage>",
     row + 1, v1 = build("<ResourceCD>",cnvtint( $2),"</ResourceCD>"), col + 1,
     v1, row + 1, t_line = concat("<Resource>",trim(uar_get_code_display(cnvtreal( $2))),
      "</Resource>"),
     col + 1, t_line, row + 1,
     col + 1, "<AppointmentList>", row + 1
    DETAIL
     state_cd_pos = locateval(jdx,1,size(sch_states->list,5),rep_get_appt_resource->qual[1].
      appointment[d.seq].sch_state_cd,sch_states->list[jdx].state_cd), apptsort_pos = locateval(jdx,1,
      size(apptsort->list,5),rep_get_appt_resource->qual[1].appointment[d.seq].sch_appt_id,apptsort->
      list[jdx].sch_appt_id), sch_evnt_id = rep_get_appt_resource->qual[1].appointment[d.seq].
     sch_event_id
     IF (state_cd_pos > 0
      AND apptsort_pos > 0
      AND sch_evnt_id > 0)
      col + 1, "<Appointment>", row + 1,
      v2 = build("<ScheduleEventId>",cnvtint(rep_get_appt_resource->qual[1].appointment[d.seq].
        sch_event_id),"</ScheduleEventId>"), col + 1, v2,
      row + 1, v3 = build("<ApptTypeCd>",cnvtint(rep_get_appt_resource->qual[1].appointment[d.seq].
        appt_type_cd),"</ApptTypeCd>"), col + 1,
      v3, row + 1, v4 = build("<ApptTypeDesc>",trim(replace(replace(replace(replace(replace(
             rep_get_appt_resource->qual[1].appointment[d.seq].appt_type_desc,"&","&amp;",0),"<",
            "&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</ApptTypeDesc>"),
      col + 1, v4, row + 1,
      v5 = build("<ApptSynonymCd>",cnvtint(rep_get_appt_resource->qual[1].appointment[d.seq].
        appt_synonym_cd),"</ApptSynonymCd>"), col + 1, v5,
      row + 1, v6 = build("<ApptSynonymFree>",trim(replace(replace(replace(replace(replace(
             rep_get_appt_resource->qual[1].appointment[d.seq].appt_synonym_free,"&","&amp;",0),"<",
            "&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</ApptSynonymFree>"), col + 1,
      v6, row + 1, v7 = build("<SchStateCd>",cnvtint(rep_get_appt_resource->qual[1].appointment[d.seq
        ].sch_state_cd),"</SchStateCd>"),
      col + 1, v7, row + 1,
      v8 = build("<SchStateMeaning>",trim(replace(replace(replace(replace(replace(
             rep_get_appt_resource->qual[1].appointment[d.seq].state_meaning,"&","&amp;",0),"<",
            "&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</SchStateMeaning>"), col + 1,
      v8,
      row + 1, v9 = build("<PatientId>",cnvtint(rep_get_appt_resource->qual[1].appointment[d.seq].
        patient[1].person_id),"</PatientId>"), col + 1,
      v9, row + 1, v10 = build("<EncounterId>",cnvtint(rep_get_appt_resource->qual[1].appointment[d
        .seq].patient[1].encntr_id),"</EncounterId>"),
      col + 1, v10, row + 1,
      encidx = locateval(idx,1,enccnt,rep_get_appt_resource->qual[1].appointment[d.seq].patient[1].
       encntr_id,encounters->list[idx].encntr_id)
      IF (encidx > 0)
       fin = encounters->list[encidx].fin, encntr_type_cd = encounters->list[encidx].encntr_type_cd,
       encntr_type_class_cd = encounters->list[encidx].encntr_type_class_cd
      ELSE
       fin = ""
      ENDIF
      patidx = locateval(idx,1,patcnt,rep_get_appt_resource->qual[1].appointment[d.seq].patient[1].
       person_id,patients->list[idx].person_id)
      IF (patidx > 0)
       name_full_formatted = patients->list[patidx].name_full_formatted, age_in_days = patients->
       list[patidx].age_in_days, sex_cd = patients->list[patidx].sex_cd,
       sex_disp = patients->list[patidx].sex_disp
       IF (2=textlen(trim(patients->list[patidx].mrn,3)))
        mrn = build("00000",trim(patients->list[patidx].mrn,3))
       ELSEIF (3=textlen(trim(patients->list[patidx].mrn,3)))
        mrn = build("0000",trim(patients->list[patidx].mrn,3))
       ELSEIF (4=textlen(trim(patients->list[patidx].mrn,3)))
        mrn = build("000",trim(patients->list[patidx].mrn,3))
       ELSEIF (5=textlen(trim(patients->list[patidx].mrn,3)))
        mrn = build("00",trim(patients->list[patidx].mrn,3))
       ELSEIF (6=textlen(trim(patients->list[patidx].mrn,3)))
        mrn = build("0",trim(patients->list[patidx].mrn,3))
       ELSE
        mrn = patients->list[patidx].mrn
       ENDIF
       dob = patients->list[patidx].dob, age = patients->list[patidx].age
      ELSE
       name_full_formatted = "", age_in_days = 0.0, sex_cd = 0.0,
       sex_disp = "", mrn = "", dob = "",
       age = ""
      ENDIF
      v11 = build("<PatientName>",trim(replace(replace(replace(replace(replace(name_full_formatted,
             "&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
       "</PatientName>"), col + 1, v11,
      row + 1, v12 = build("<PatientAgeInDays>",cnvtint(age_in_days),"</PatientAgeInDays>"), col + 1,
      v12, row + 1, v13 = build("<PatientSexCd>",cnvtint(sex_cd),"</PatientSexCd>"),
      col + 1, v13, row + 1,
      v14 = build("<PatientSexDisp>",trim(replace(replace(replace(replace(replace(sex_disp,"&",
             "&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
       "</PatientSexDisp>"), col + 1, v14,
      row + 1, v15 = build("<PatientFin>",trim(replace(replace(replace(replace(replace(fin,"&",
             "&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
       "</PatientFin>"), col + 1,
      v15, row + 1, v16 = build("<PatientMrn>",trim(replace(replace(replace(replace(replace(mrn,"&",
             "&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
       "</PatientMrn>"),
      col + 1, v16, row + 1,
      v17 = build("<BegDtTm>",format(rep_get_appt_resource->qual[1].appointment[d.seq].beg_dt_tm,
        "MM/DD/YYYY HH:MM;;D"),"</BegDtTm>"), col + 1, v17,
      row + 1, v18 = build("<EndDtTm>",format(rep_get_appt_resource->qual[1].appointment[d.seq].
        end_dt_tm,"MM/DD/YYYY HH:MM;;D"),"</EndDtTm>"), col + 1,
      v18, row + 1, t_line = concat("<PrsnlId>",rep_get_appt_resource->qual[1].appointment[d.seq].
       prsnl_id,"</PrsnlId>"),
      col + 1, t_line, row + 1,
      t_line = concat("<Prsnl>",trim(rep_get_appt_resource->qual[1].appointment[d.seq].prsnl),
       "</Prsnl>"), col + 1, t_line,
      row + 1, v19 = build("<LocationCd>",cnvtint(rep_get_appt_resource->qual[1].appointment[d.seq].
        location_cd),"</LocationCd>"), col + 1,
      v19, row + 1, v20 = build("<LocationDisp>",trim(replace(replace(replace(replace(replace(
             rep_get_appt_resource->qual[1].appointment[d.seq].location_freetext,"&","&amp;",0),"<",
            "&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</LocationDisp>"),
      col + 1, v20, row + 1,
      locidx = locateval(idx,1,loccnt,rep_get_appt_resource->qual[1].appointment[d.seq].location_cd,
       locations->list[idx].location_cd)
      IF (locidx > 0)
       facility_cd = locations->list[locidx].facility_cd, facility_disp = locations->list[locidx].
       facility_disp
      ELSE
       facility_cd = 0.0, facility_disp = ""
      ENDIF
      v21 = build("<FacilityCd>",cnvtint(facility_cd),"</FacilityCd>"), col + 1, v21,
      row + 1, v22 = build("<FacilityDisp>",trim(replace(replace(replace(replace(replace(
             facility_disp,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),
        3),"</FacilityDisp>"), col + 1,
      v22, row + 1, residx = locateval(idx,1,rescnt,rep_get_appt_resource->qual[1].appointment[d.seq]
       .primary_resource_cd,resources->list[idx].scheduled_resource_cd)
      IF (residx > 0)
       resource_loc_cd = resources->list[residx].location_cd, resource_loc_disp = resources->list[
       residx].location_disp
      ELSE
       resource_loc_cd = 0.0, resource_loc_disp = ""
      ENDIF
      v23 = build("<ResourceLocCd>",cnvtint(resource_loc_cd),"</ResourceLocCd>"), col + 1, v23,
      row + 1, v24 = build("<ResourceLocDisp>",trim(replace(replace(replace(replace(replace(
             resource_loc_disp,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
         "&quot;",0),3),"</ResourceLocDisp>"), col + 1,
      v24, row + 1, v25 = build("<PatientDob>",trim(replace(replace(replace(replace(replace(dob,"&",
             "&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
       "</PatientDob>"),
      col + 1, v25, row + 1,
      v26 = build("<PatientAge>",trim(replace(replace(replace(replace(replace(age,"&","&amp;",0),"<",
            "&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</PatientAge>"), col + 1, v26,
      row + 1, v27 = build("<EncounterTypeCd>",cnvtstring(encntr_type_cd),"</EncounterTypeCd>"), col
       + 1,
      v27, row + 1, v28 = build("<EncounterTypeDisp>",uar_get_code_display(encntr_type_cd),
       "</EncounterTypeDisp>"),
      col + 1, v28, row + 1,
      v29 = build("<EncounterTypeMean>",uar_get_code_meaning(encntr_type_cd),"</EncounterTypeMean>"),
      col + 1, v29,
      row + 1, v30 = build("<EncounterTypeClassCd>",cnvtstring(encntr_type_class_cd),
       "</EncounterTypeClassCd>"), col + 1,
      v30, row + 1, v31 = build("<EncounterTypeClassDisp>",uar_get_code_display(encntr_type_class_cd),
       "</EncounterTypeClassDisp>"),
      col + 1, v31, row + 1,
      v32 = build("<EncounterTypeClassMean>",uar_get_code_meaning(encntr_type_class_cd),
       "</EncounterTypeClassMean>"), col + 1, v32,
      row + 1
      IF (textlen(trim(rep_get_appt_resource->qual[1].appointment[d.seq].appt_reason_free,3)) > 0)
       v33 = build("<EncounterReason><VisitReason>",trim(replace(replace(replace(replace(replace(
              rep_get_appt_resource->qual[1].appointment[d.seq].appt_reason_free,"&","&amp;",0),"<",
             "&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
        "</VisitReason></EncounterReason>"), col + 1, v33,
       row + 1
      ENDIF
      col + 1, "</Appointment>", row + 1
     ENDIF
    FOOT REPORT
     col + 1, "</AppointmentList>", row + 1,
     col + 1, "</ReplyMessage>", row + 1
    WITH maxcol = 32000, nocounter, nullreport,
     formfeed = none, format = variable, time = 30
   ;end select
  ELSE
   SELECT INTO value(moutputdevice)
    FROM dummyt d
    PLAN (d)
    HEAD REPORT
     html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
      '"',"UTF-8",'"'," ?>"), col 0, html_tag,
     row + 1, col + 1, "<ReplyMessage>",
     row + 1, v1 = build("<ResourceCD>",cnvtint( $2),"</ResourceCD>"), col + 1,
     v1, row + 1, col + 1,
     "<AppointmentList>", row + 1
    FOOT REPORT
     col + 1, "</AppointmentList>", row + 1,
     col + 1, "</ReplyMessage>", row + 1
    WITH maxcol = 32000, nocounter, nullreport,
     formfeed = none, format = variable, time = 30
   ;end select
  ENDIF
 ENDIF
 FREE RECORD req_get_appt_resource
 FREE RECORD rep_get_appt_resource
 FREE RECORD sch_states
 FREE RECORD locations
 FREE RECORD encounters
 FREE RECORD resources
 FREE RECORD apptsort
END GO
