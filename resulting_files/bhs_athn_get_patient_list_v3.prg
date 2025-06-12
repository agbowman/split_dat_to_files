CREATE PROGRAM bhs_athn_get_patient_list_v3
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
 FREE RECORD patient_filter
 RECORD patient_filter(
   1 list[*]
     2 filter = vc
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
 )
 DECLARE patient_list_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",27360, $3))
 IF (( $2 <= 0.0))
  GO TO exit_script
 ELSEIF (patient_list_type_cd <= 0.0)
  GO TO exit_script
 ENDIF
 DECLARE fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"MRN"))
 DECLARE cmrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"CMRN"))
 DECLARE attenddoc_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",333,"ATTENDDOC"))
 DECLARE mrn_pool_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",263,"MRN"))
 DECLARE inpatient_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",69,"INPATIENT"))
 DECLARE observation_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",69,"OBSERVATION"))
 DECLARE emergency_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",69,"EMERGENCY"))
 DECLARE patientcnt = i4
 DECLARE status_filter_cnt = i4
 DECLARE status_filter_str = vc WITH protect, noconstant(" ")
 DECLARE patfilterparam = vc
 DECLARE patfilterblockcnt = i4
 DECLARE startpos = i4
 DECLARE endpos = i4
 DECLARE param = vc
 DECLARE block = vc
 DECLARE patfiltercnt = i4
 DECLARE patfiltercntvalidind = i2
 DECLARE stat = i2
 DECLARE idx = i4
 DECLARE locidx = i4
 DECLARE pos = i4
 DECLARE epos = i4
 DECLARE indx = i4
 DECLARE indx1 = i4
 DECLARE responsible_reltn_disp = vc
 DECLARE patient_cnt = i4
 DECLARE errmsg = vc
 SET orequest->patient_list_id =  $2
 SET orequest->patient_list_type_cd = patient_list_type_cd
 SET orequest->best_encntr_flag = cnvtint( $4)
 SET patfilterparam = trim( $5,3)
 SET startpos = 1
 WHILE (size(patfilterparam) > 0)
   SET endpos = (findstring("|",patfilterparam,1) - 1)
   IF (endpos <= 0)
    SET endpos = size(patfilterparam)
   ENDIF
   IF (startpos < endpos)
    SET param = substring(1,endpos,patfilterparam)
    IF (size(param) > 0)
     SET patfilterblockcnt = (patfilterblockcnt+ 1)
     SET stat = alterlist(patient_filter->list,patfilterblockcnt)
     SET patient_filter->list[patfilterblockcnt].filter = param
    ENDIF
   ENDIF
   SET patfilterparam = substring((endpos+ 2),(size(patfilterparam) - endpos),patfilterparam)
 ENDWHILE
 SET stat = alterlist(orequest->arguments,patfilterblockcnt)
 FOR (idx = 1 TO patfilterblockcnt)
   SET block = patient_filter->list[idx].filter
   SET patfiltercnt = 0
   SET startpos = 0
   IF (((idx=1) OR (patfiltercntvalidind=1)) )
    SET patfiltercntvalidind = 0
    WHILE (size(block) > 0)
      SET endpos = (findstring(";",block,1) - 1)
      IF (endpos <= 0)
       SET endpos = size(block)
      ENDIF
      IF (startpos < endpos)
       SET param = substring(1,endpos,block)
       IF (size(param) > 0)
        SET patfiltercnt = (patfiltercnt+ 1)
        IF (patfiltercnt=1)
         SET orequest->arguments[idx].argument_name = param
        ELSEIF (patfiltercnt=2)
         SET orequest->arguments[idx].parent_entity_id = cnvtreal(param)
         SET patfiltercntvalidind = 1
        ELSEIF (patfiltercnt > 2)
         GO TO exit_script
        ENDIF
       ENDIF
      ENDIF
      SET block = substring((endpos+ 2),(size(block) - endpos),block)
    ENDWHILE
   ENDIF
 ENDFOR
 IF (patfiltercntvalidind=0)
  GO TO exit_script
 ENDIF
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
 FOR (idx = 1 TO size(orequest->arguments,5))
   IF (cnvtupper(orequest->arguments[idx].argument_name)="PRSNL_ID")
    SET i_request->prsnl_id = orequest->arguments[idx].parent_entity_id
    SET idx = (size(orequest->arguments,5)+ 1)
   ENDIF
 ENDFOR
 IF ((i_request->prsnl_id > 0))
  CALL echorecord(i_request)
  EXECUTE bhs_athn_impersonate_user  WITH replace("REQUEST","I_REQUEST"), replace("REPLY","I_REPLY")
  IF ((i_reply->status_data.status != "S"))
   CALL echo("IMPERSONATE USER FAILED...EXITING!")
   GO TO exit_script
  ENDIF
 ENDIF
 SET stat = tdbexecute(600005,3200100,600123,"rec",orequest,
  "rec",oreply)
 IF (stat > 0)
  SET errcode = error(errmsg,1)
  GO TO exit_script
 ENDIF
 FOR (idx = 1 TO size(orequest->arguments,5))
   IF (cnvtlower(orequest->arguments[idx].argument_name)="encntr_status"
    AND (orequest->arguments[idx].parent_entity_id > 0.0))
    SET status_filter_cnt = (status_filter_cnt+ 1)
    SET status_filter_str = build(status_filter_str,orequest->arguments[idx].parent_entity_id,",")
   ENDIF
 ENDFOR
 IF (status_filter_cnt > 0)
  SET status_filter_str = build("(",status_filter_str,")")
  SET where_status_filter = build(" e.encntr_status_cd in ",replace(trim(status_filter_str,3),",)",
    ")",0))
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
    WHERE pa.person_id=outerjoin(e.person_id)
     AND pa.active_ind=outerjoin(1)
     AND pa.person_alias_type_cd=outerjoin(cmrn_cd)
     AND pa.beg_effective_dt_tm < outerjoin(sysdate)
     AND pa.end_effective_dt_tm > outerjoin(sysdate))
    JOIN (epr
    WHERE epr.encntr_id=outerjoin(e.encntr_id)
     AND epr.encntr_prsnl_r_cd=outerjoin(attenddoc_cd)
     AND epr.active_ind=outerjoin(1)
     AND epr.beg_effective_dt_tm <= outerjoin(sysdate)
     AND epr.end_effective_dt_tm >= outerjoin(sysdate))
    JOIN (p2
    WHERE p2.person_id=outerjoin(epr.prsnl_person_id)
     AND p2.active_ind=outerjoin(1)
     AND p2.beg_effective_dt_tm <= outerjoin(sysdate)
     AND p2.end_effective_dt_tm >= outerjoin(sysdate))
   ORDER BY e.encntr_id DESC
   HEAD e.encntr_id
    pos = locateval(indx1,1,size(oreply->patients,5),e.encntr_id,oreply->patients[indx1].encntr_id),
    priority = oreply->patients[pos].priority, responsible_prsnl_id = oreply->patients[pos].
    responsible_prsnl_id,
    responsible_reltn_id = oreply->patients[pos].responsible_reltn_id, responsible_reltn_cd = oreply
    ->patients[pos].responsible_reltn_cd, responsible_reltn_disp = oreply->patients[pos].
    responsible_reltn_disp,
    patientcnt = (patientcnt+ 1), stat = alterlist(output->list,patientcnt), output->list[patientcnt]
    .personid = e.person_id,
    output->list[patientcnt].personname = trim(replace(replace(replace(replace(replace(p
          .name_full_formatted,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
      "&quot;",0),3), output->list[patientcnt].encounterid = e.encntr_id, output->list[patientcnt].
    priority = priority,
    output->list[patientcnt].providerid = responsible_prsnl_id, output->list[patientcnt].
    providerrelationshiptype = responsible_reltn_cd, output->list[patientcnt].providerrelationship =
    trim(replace(replace(replace(replace(replace(responsible_reltn_disp,"&","&amp;",0),"<","&lt;",0),
        ">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
    output->list[patientcnt].providerrelationshipid = responsible_reltn_id, output->list[patientcnt].
    facilitycd = e.loc_facility_cd, output->list[patientcnt].facility = trim(replace(replace(replace(
        replace(replace(uar_get_code_display(e.loc_facility_cd),"&","&amp;",0),"<","&lt;",0),">",
        "&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
    output->list[patientcnt].nurseunitcd = e.loc_nurse_unit_cd, output->list[patientcnt].nurseunit =
    trim(replace(replace(replace(replace(replace(uar_get_code_display(e.loc_nurse_unit_cd),"&",
          "&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), output->list[
    patientcnt].room = trim(replace(replace(replace(replace(replace(uar_get_code_display(e
           .loc_room_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3
     ),
    output->list[patientcnt].bed = trim(replace(replace(replace(replace(replace(uar_get_code_display(
           e.loc_bed_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3
     ), output->list[patientcnt].organizationid = e.organization_id, output->list[patientcnt].
    preregdttm = format(e.pre_reg_dt_tm,"mm/dd/yyyy hh:mm:ss;;d"),
    output->list[patientcnt].regdttm = format(e.reg_dt_tm,"mm/dd/yyyy hh:mm:ss;;d"), output->list[
    patientcnt].inpatientadmitdttm = format(e.inpatient_admit_dt_tm,"mm/dd/yyyy hh:mm:ss;;d"), output
    ->list[patientcnt].estarrivedttm = format(e.est_arrive_dt_tm,"mm/dd/yyyy hh:mm:ss;;d"),
    output->list[patientcnt].encntrtypecd = e.encntr_type_cd, output->list[patientcnt].encntrtypedisp
     = trim(replace(replace(replace(replace(replace(uar_get_code_display(e.encntr_type_cd),"&",
          "&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), output->list[
    patientcnt].encntrtypemean = trim(replace(replace(replace(replace(replace(uar_get_code_meaning(e
           .encntr_type_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0
      ),3),
    output->list[patientcnt].encntrtypeclasscd = e.encntr_type_class_cd, output->list[patientcnt].
    encntrtypeclassdisp = trim(replace(replace(replace(replace(replace(uar_get_code_display(e
           .encntr_type_class_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
      "&quot;",0),3), output->list[patientcnt].encntrtypeclassmean = trim(replace(replace(replace(
        replace(replace(uar_get_code_meaning(e.encntr_type_class_cd),"&","&amp;",0),"<","&lt;",0),">",
        "&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
    output->list[patientcnt].encntrstatuscd = e.encntr_status_cd, output->list[patientcnt].
    encntrstatus = trim(replace(replace(replace(replace(replace(uar_get_code_display(e
           .encntr_status_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",
      0),3), output->list[patientcnt].reasonforvisit = trim(replace(replace(replace(replace(replace(e
          .reason_for_visit,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0
      ),3),
    output->list[patientcnt].dischdttm = format(e.disch_dt_tm,"mm/dd/yyyy hh:mm:ss;;d"), output->
    list[patientcnt].fin = "", output->list[patientcnt].mrn = ""
    IF (2=textlen(trim(pa.alias,3)))
     output->list[patientcnt].mrn = build("00000",trim(replace(replace(replace(replace(replace(pa
            .alias,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3))
    ELSEIF (3=textlen(trim(pa.alias,3)))
     output->list[patientcnt].mrn = build("0000",trim(replace(replace(replace(replace(replace(pa
            .alias,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3))
    ELSEIF (4=textlen(trim(pa.alias,3)))
     output->list[patientcnt].mrn = build("000",trim(replace(replace(replace(replace(replace(pa.alias,
            "&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3))
    ELSEIF (5=textlen(trim(pa.alias,3)))
     output->list[patientcnt].mrn = build("00",trim(replace(replace(replace(replace(replace(pa.alias,
            "&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3))
    ELSEIF (6=textlen(trim(pa.alias,3)))
     output->list[patientcnt].mrn = build("0",trim(replace(replace(replace(replace(replace(pa.alias,
            "&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3))
    ELSE
     output->list[patientcnt].mrn = trim(replace(replace(replace(replace(replace(pa.alias,"&","&amp;",
           0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3)
    ENDIF
    output->list[patientcnt].birthdttm = format(p.birth_dt_tm,"mm/dd/yyyy hh:mm:ss;;d"), output->
    list[patientcnt].age = cnvtage(p.birth_dt_tm), output->list[patientcnt].sexcd = p.sex_cd,
    output->list[patientcnt].sex = trim(replace(replace(replace(replace(replace(uar_get_code_display(
           p.sex_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
    output->list[patientcnt].language = trim(replace(replace(replace(replace(replace(
          uar_get_code_display(p.language_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",
       0),'"',"&quot;",0),3), output->list[patientcnt].absbirthdttm = format(p.abs_birth_dt_tm,
     "mm/dd/yyyy hh:mm:ss;;d"),
    output->list[patientcnt].maritalstatus = trim(replace(replace(replace(replace(replace(
          uar_get_code_display(p.marital_type_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
       "&apos;",0),'"',"&quot;",0),3), output->list[patientcnt].lastencntrdttm = format(p
     .last_encntr_dt_tm,"mm/dd/yyyy hh:mm:ss;;d")
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
    output->list[patientcnt].attendingphysician = trim(replace(replace(replace(replace(replace(
          attend_phys,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
    output->list[patientcnt].medservice = ""
   WITH nocounter, time = 4.9, expand = 1
  ;end select
 ENDIF
 CALL echojson(output, $1)
END GO
