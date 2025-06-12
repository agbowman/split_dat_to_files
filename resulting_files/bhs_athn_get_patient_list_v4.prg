CREATE PROGRAM bhs_athn_get_patient_list_v4
 FREE RECORD req600142
 RECORD req600142(
   1 prsnl_id = f8
 ) WITH protect
 FREE RECORD rep600142
 RECORD rep600142(
   1 patient_lists[*]
     2 patient_list_id = f8
     2 name = vc
     2 description = vc
     2 patient_list_type_cd = f8
     2 owner_id = f8
     2 list_access_cd = f8
     2 arguments[*]
       3 argument_name = vc
       3 argument_value = vc
       3 parent_entity_name = vc
       3 parent_entity_id = f8
     2 encntr_type_filters[*]
     2 proxies[*]
   1 status_data
     2 status = c1
 ) WITH protect
 RECORD orequest(
   1 patient_list_id = f8
   1 patient_list_type_cd = f8
   1 best_encntr_flag = i2
   1 arguments[*]
     2 argument_name = vc
     2 argument_value = vc
     2 parent_entity_name = vc
     2 parent_entity_id = f8
   1 encntr_type_filters[*]
     2 encntr_type_cd = f8
     2 encntr_class_cd = f8
   1 patient_list_name = vc
   1 mv_flag = i2
   1 rmv_pl_rows_flag = i2
 )
 RECORD oreply(
   1 patient_list_id = f8
   1 name = vc
   1 description = vc
   1 patient_list_type_cd = f8
   1 owner_id = f8
   1 prsnl_access_cd = f8
   1 execution_dt_tm = dq8
   1 execution_status_cd = f8
   1 execution_status_disp = vc
   1 arguments[*]
     2 argument_name = vc
     2 argument_value = vc
     2 parent_entity_name = vc
     2 parent_entity_id = f8
   1 encntr_type_filters[*]
     2 encntr_type_cd = f8
   1 patients[*]
     2 person_id = f8
     2 person_name = vc
     2 encntr_id = f8
     2 priority = i4
     2 active_ind = i2
     2 filter_ind = i2
     2 responsible_prsnl_id = f8
     2 responsible_prsnl_name = vc
     2 responsible_reltn_cd = f8
     2 responsible_reltn_disp = vc
     2 responsible_reltn_id = f8
     2 responsible_reltn_flag = i2
     2 organization_id = f8
     2 confid_level_cd = f8
     2 confid_level_disp = c40
     2 confid_level = i4
     2 birthdate = dq8
     2 birth_tz = i4
     2 end_effective_dt_tm = dq8
     2 service_cd = f8
     2 service_disp = c40
     2 gender_cd = f8
     2 gender_disp = c40
     2 temp_location_cd = f8
     2 temp_location_disp = c40
     2 vip_cd = f8
     2 visit_reason = vc
     2 visitor_status_cd = f8
     2 visitor_status_disp = c40
     2 deceased_date = dq8
     2 deceased_tz = i4
     2 remove_ind = i4
     2 remove_dt_tm = dq8
   1 status_data
     2 status = c1
 )
 FREE RECORD output
 RECORD output(
   1 status = c1
   1 list[*]
     2 personid = f8
     2 personname = vc
     2 encounterid = f8
     2 priority = i4
     2 providerid = f8
     2 providerrelationshiptype = f8
     2 providerrelationship = vc
     2 providerrelationshipid = f8
     2 facilitycd = f8
     2 facility = vc
     2 nurseunitcd = f8
     2 nurseunit = vc
     2 room = vc
     2 bed = vc
     2 organizationid = f8
     2 preregdttm = vc
     2 regdttm = vc
     2 inpatientadmitdttm = vc
     2 estarrivedttm = vc
     2 encntrtypecd = f8
     2 encntrtypemean = vc
     2 encntrtypedisp = vc
     2 encntrtypeclasscd = f8
     2 encntrtypeclassmean = vc
     2 encntrtypeclassdisp = vc
     2 encntrstatuscd = f8
     2 encntrstatus = vc
     2 reasonforvisit = vc
     2 dischdttm = vc
     2 fin = vc
     2 mrn = vc
     2 cmrn = vc
     2 birthdttm = vc
     2 age = vc
     2 sexcd = f8
     2 sex = vc
     2 language = vc
     2 absbirthdttm = vc
     2 maritalstatus = vc
     2 lastencntrdttm = vc
     2 patienttype = vc
     2 attendingphysician = vc
     2 medservice = vc
     2 ethnicity_cd = vc
     2 ethnicity_display = vc
 )
 IF (( $2 <= 0.0))
  GO TO exit_script
 ELSEIF (( $3 <= 0))
  GO TO exit_script
 ENDIF
 DECLARE cmrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"CMRN"))
 DECLARE attenddoc_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",333,"ATTENDDOC"))
 DECLARE patientcnt = i4
 DECLARE status_filter_str = vc WITH protect, noconstant( $5)
 DECLARE patfiltercntvalidind = i2 WITH protect, noconstant(0.00)
 DECLARE stat = i2
 DECLARE idx = i4
 DECLARE pos = i4
 DECLARE indx = i4
 DECLARE indx1 = i4
 DECLARE responsible_reltn_disp = vc
 DECLARE errmsg = vc WITH protect, noconstant("Error occurred while retrive patient list.")
 FREE RECORD i_request
 RECORD i_request(
   1 prsnl_id = f8
 ) WITH protect
 FREE RECORD i_reply
 RECORD i_reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 SET i_request->prsnl_id =  $3
 IF ((i_request->prsnl_id > 0))
  CALL echorecord(i_request)
  EXECUTE bhs_athn_impersonate_user  WITH replace("REQUEST","I_REQUEST"), replace("REPLY","I_REPLY")
  IF ((i_reply->status_data.status != "S"))
   CALL echo("impersonate user failed...exiting!")
   GO TO exit_script
  ENDIF
 ENDIF
 SET req600142->prsnl_id =  $3
 CALL echorecord(req600142)
 SET stat1 = tdbexecute(600005,3200100,600142,"REC",req600142,
  "REC",rep600142,1)
 IF (stat1 > 0)
  SET errcode = error(errmsg,1)
  GO TO exit_script
 ENDIF
 IF ((rep600142->status_data.status="S"))
  FOR (idx = 1 TO size(rep600142->patient_lists,5))
    IF ((rep600142->patient_lists[idx].patient_list_id= $2))
     SET orequest->patient_list_id =  $2
     SET orequest->patient_list_type_cd = rep600142->patient_lists[idx].patient_list_type_cd
     SET orequest->best_encntr_flag = cnvtint( $4)
     SET stat = alterlist(orequest->arguments,size(rep600142->patient_lists[idx].arguments,5))
     FOR (idx1 = 1 TO size(rep600142->patient_lists[idx].arguments,5))
       SET patfiltercntvalidind = 1
       SET orequest->arguments[idx1].argument_name = rep600142->patient_lists[idx].arguments[idx1].
       argument_name
       SET orequest->arguments[idx1].argument_value = rep600142->patient_lists[idx].arguments[idx1].
       argument_value
       SET orequest->arguments[idx1].parent_entity_id = rep600142->patient_lists[idx].arguments[idx1]
       .parent_entity_id
       SET orequest->arguments[idx1].parent_entity_name = rep600142->patient_lists[idx].arguments[
       idx1].parent_entity_name
     ENDFOR
     SET idx = (size(rep600142->patient_lists,5)+ 1)
    ENDIF
  ENDFOR
 ENDIF
 IF (patfiltercntvalidind=0)
  GO TO exit_script
 ENDIF
 SET stat = tdbexecute(600005,3200100,600123,"rec",orequest,
  "rec",oreply)
 IF (stat > 0)
  SET errcode = error(errmsg,1)
  GO TO exit_script
 ENDIF
 IF (size(trim(status_filter_str,3)) > 0)
  SET where_status_filter = build(" e.encntr_status_cd in (",trim(status_filter_str,3),")")
 ELSE
  SET where_status_filter = build(" e.encntr_status_cd != 0")
 ENDIF
#exit_script
 SET output->status = evaluate(oreply->status_data.status,"F","F","S")
 IF (size(oreply->patients,5) > 0)
  SELECT INTO "nl:"
   attend_phys = p2.name_full_formatted
   FROM encounter e,
    person p,
    person_alias pa,
    encntr_prsnl_reltn epr,
    person p2
   PLAN (e
    WHERE expand(indx,1,size(oreply->patients,5),e.encntr_id,oreply->patients[indx].encntr_id)
     AND parser(where_status_filter))
    JOIN (p
    WHERE p.person_id=e.person_id
     AND p.active_ind=1
     AND p.beg_effective_dt_tm < sysdate
     AND p.end_effective_dt_tm > sysdate)
    JOIN (pa
    WHERE (pa.person_id= Outerjoin(e.person_id))
     AND (pa.active_ind= Outerjoin(1))
     AND (pa.person_alias_type_cd= Outerjoin(cmrn_cd))
     AND (pa.beg_effective_dt_tm< Outerjoin(sysdate))
     AND (pa.end_effective_dt_tm> Outerjoin(sysdate)) )
    JOIN (epr
    WHERE (epr.encntr_id= Outerjoin(e.encntr_id))
     AND (epr.encntr_prsnl_r_cd= Outerjoin(attenddoc_cd))
     AND (epr.active_ind= Outerjoin(1))
     AND (epr.beg_effective_dt_tm<= Outerjoin(sysdate))
     AND (epr.end_effective_dt_tm>= Outerjoin(sysdate)) )
    JOIN (p2
    WHERE (p2.person_id= Outerjoin(epr.prsnl_person_id))
     AND (p2.active_ind= Outerjoin(1))
     AND (p2.beg_effective_dt_tm<= Outerjoin(sysdate))
     AND (p2.end_effective_dt_tm>= Outerjoin(sysdate)) )
   ORDER BY e.encntr_id DESC
   HEAD e.encntr_id
    pos = locateval(indx1,1,size(oreply->patients,5),e.encntr_id,oreply->patients[indx1].encntr_id),
    priority = oreply->patients[pos].priority, responsible_prsnl_id = oreply->patients[pos].
    responsible_prsnl_id,
    responsible_reltn_id = oreply->patients[pos].responsible_reltn_id, responsible_reltn_cd = oreply
    ->patients[pos].responsible_reltn_cd, responsible_reltn_disp = oreply->patients[pos].
    responsible_reltn_disp,
    patientcnt += 1, stat = alterlist(output->list,patientcnt), output->list[patientcnt].personid = e
    .person_id,
    output->list[patientcnt].personname = p.name_full_formatted, output->list[patientcnt].encounterid
     = e.encntr_id, output->list[patientcnt].priority = priority,
    output->list[patientcnt].providerid = responsible_prsnl_id, output->list[patientcnt].
    providerrelationshiptype = responsible_reltn_cd, output->list[patientcnt].providerrelationship =
    responsible_reltn_disp,
    output->list[patientcnt].providerrelationshipid = responsible_reltn_id, output->list[patientcnt].
    facilitycd = e.loc_facility_cd, output->list[patientcnt].facility = uar_get_code_display(e
     .loc_facility_cd),
    output->list[patientcnt].nurseunitcd = e.loc_nurse_unit_cd, output->list[patientcnt].nurseunit =
    uar_get_code_display(e.loc_nurse_unit_cd), output->list[patientcnt].room = uar_get_code_display(e
     .loc_room_cd),
    output->list[patientcnt].bed = uar_get_code_display(e.loc_bed_cd), output->list[patientcnt].
    organizationid = e.organization_id, output->list[patientcnt].preregdttm = format(e.pre_reg_dt_tm,
     "mm/dd/yyyy hh:mm:ss;;d"),
    output->list[patientcnt].regdttm = format(e.reg_dt_tm,"mm/dd/yyyy hh:mm:ss;;d"), output->list[
    patientcnt].inpatientadmitdttm = format(e.inpatient_admit_dt_tm,"mm/dd/yyyy hh:mm:ss;;d"), output
    ->list[patientcnt].estarrivedttm = format(e.est_arrive_dt_tm,"mm/dd/yyyy hh:mm:ss;;d"),
    output->list[patientcnt].encntrtypecd = e.encntr_type_cd, output->list[patientcnt].encntrtypedisp
     = uar_get_code_display(e.encntr_type_cd), output->list[patientcnt].encntrtypemean =
    uar_get_code_meaning(e.encntr_type_cd),
    output->list[patientcnt].encntrtypeclasscd = e.encntr_type_class_cd, output->list[patientcnt].
    encntrtypeclassdisp = uar_get_code_display(e.encntr_type_class_cd), output->list[patientcnt].
    encntrtypeclassmean = uar_get_code_meaning(e.encntr_type_class_cd),
    output->list[patientcnt].encntrstatuscd = e.encntr_status_cd, output->list[patientcnt].
    encntrstatus = uar_get_code_display(e.encntr_status_cd), output->list[patientcnt].reasonforvisit
     = e.reason_for_visit,
    output->list[patientcnt].dischdttm = format(e.disch_dt_tm,"mm/dd/yyyy hh:mm:ss;;d")
    IF (2=textlen(trim(pa.alias,3)))
     output->list[patientcnt].mrn = build("00000",pa.alias)
    ELSEIF (3=textlen(trim(pa.alias,3)))
     output->list[patientcnt].mrn = build("0000",pa.alias)
    ELSEIF (4=textlen(trim(pa.alias,3)))
     output->list[patientcnt].mrn = build("000",pa.alias)
    ELSEIF (5=textlen(trim(pa.alias,3)))
     output->list[patientcnt].mrn = build("00",pa.alias)
    ELSEIF (6=textlen(trim(pa.alias,3)))
     output->list[patientcnt].mrn = build("0",pa.alias)
    ELSE
     output->list[patientcnt].mrn = pa.alias
    ENDIF
    output->list[patientcnt].birthdttm = format(p.birth_dt_tm,"mm/dd/yyyy hh:mm:ss;;d"), output->
    list[patientcnt].age = cnvtage(p.birth_dt_tm), output->list[patientcnt].sexcd = p.sex_cd,
    output->list[patientcnt].sex = uar_get_code_display(p.sex_cd), output->list[patientcnt].language
     = uar_get_code_display(p.language_cd), output->list[patientcnt].absbirthdttm = format(p
     .abs_birth_dt_tm,"mm/dd/yyyy hh:mm:ss;;d"),
    output->list[patientcnt].maritalstatus = uar_get_code_display(p.marital_type_cd), output->list[
    patientcnt].lastencntrdttm = format(p.last_encntr_dt_tm,"mm/dd/yyyy hh:mm:ss;;d")
    IF (((e.encntr_type_cd=679668) OR (((e.encntr_type_cd=679662) OR (((e.encntr_type_cd=679658) OR (
    ((e.encntr_type_cd=679656) OR (((e.encntr_type_cd=679659) OR (((e.encntr_type_cd=2495726) OR (((e
    .encntr_type_cd=309310) OR (((e.encntr_type_cd=679683) OR (((e.encntr_type_cd=679670) OR (((e
    .encntr_type_cd=679657) OR (((e.encntr_type_cd=679677) OR (((e.encntr_type_cd=309308) OR (((e
    .encntr_type_cd=309312) OR (((e.encntr_type_cd=679653) OR (((e.encntr_type_cd=679672) OR (((e
    .encntr_type_cd=679660) OR (((e.encntr_type_cd=679654) OR (((e.encntr_type_cd=679655) OR (e
    .encntr_type_cd=679664)) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )
     output->list[patientcnt].patienttype = "IP"
    ELSE
     output->list[patientcnt].patienttype = "OP"
    ENDIF
    output->list[patientcnt].attendingphysician = attend_phys, output->list[patientcnt].ethnicity_cd
     = cnvtstring(p.ethnic_grp_cd), output->list[patientcnt].ethnicity_display = uar_get_code_display
    (p.ethnic_grp_cd)
   WITH nocounter, time = 4.9, expand = 1
  ;end select
 ENDIF
 SET _memory_reply_string = cnvtrectojson(output)
 FREE RECORD output
END GO
