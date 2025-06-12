CREATE PROGRAM bhs_athn_get_patient_list_v2
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE locidx = i4 WITH protect, noconstant(0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE epos = i4 WITH protect, noconstant(0)
 FREE RECORD req600123
 RECORD req600123(
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
 ) WITH protect
 FREE RECORD rep600123
 RECORD rep600123(
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
 ) WITH protect
 SET patient_list_type_cd = uar_get_code_by("MEANING",27360, $3)
 IF (( $2 <= 0.0))
  CALL echo("INVALID PATIENT LIST ID...EXITING")
  GO TO exit_script
 ELSEIF (patient_list_type_cd <= 0.0)
  CALL echo("INVALID PATIENT LIST TYPE...EXITING")
  GO TO exit_script
 ENDIF
 DECLARE patfilterparam = vc WITH protect, noconstant("")
 DECLARE patfilterblockcnt = i4 WITH protect, noconstant(0)
 DECLARE startpos = i4 WITH protect, noconstant(0)
 DECLARE endpos = i4 WITH protect, noconstant(0)
 DECLARE param = vc WITH protect, noconstant("")
 DECLARE block = vc WITH protect, noconstant("")
 DECLARE patfiltercnt = i4 WITH protect, noconstant(0)
 DECLARE patfiltercntvalidind = i2 WITH protect, noconstant(0)
 DECLARE stat = i2 WITH protect, noconstant(0)
 FREE RECORD patient_filter
 RECORD patient_filter(
   1 list[*]
     2 filter = vc
 ) WITH protect
 SET startpos = 1
 SET patfilterparam = trim( $5,3)
 CALL echo(build2("PATFILTER_PARAMS IS: ",patfilterparam))
 WHILE (size(patfilterparam) > 0)
   SET endpos = (findstring("|",patfilterparam,1) - 1)
   IF (endpos <= 0)
    SET endpos = size(patfilterparam)
   ENDIF
   CALL echo(build("ENDPOS:",endpos))
   IF (startpos < endpos)
    SET param = substring(1,endpos,patfilterparam)
    CALL echo(build("PARAM:",param))
    IF (size(param) > 0)
     CALL echo(build("ADDING PATIENT FILTER TO BLOCKLIST: ",param))
     SET patfilterblockcnt = (patfilterblockcnt+ 1)
     CALL echo(build("PATFILTERBLOCKCNT:",patfilterblockcnt))
     SET stat = alterlist(patient_filter->list,patfilterblockcnt)
     SET patient_filter->list[patfilterblockcnt].filter = param
    ENDIF
   ENDIF
   SET patfilterparam = substring((endpos+ 2),(size(patfilterparam) - endpos),patfilterparam)
   CALL echo(build("PATFILTERPARAM:",patfilterparam))
   CALL echo(build("SIZE(PATFILTERPARAM):",size(patfilterparam)))
 ENDWHILE
 SET stat = alterlist(req600123->arguments,patfilterblockcnt)
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
      CALL echo(build("ENDPOS:",endpos))
      IF (startpos < endpos)
       SET param = substring(1,endpos,block)
       CALL echo(build("PARAM:",param))
       IF (size(param) > 0)
        CALL echo(build("ADDING PATIENT FILTER TO ARGUMENTS: ",param))
        SET patfiltercnt = (patfiltercnt+ 1)
        CALL echo(build("PATFILTERCNT:",patfiltercnt))
        IF (patfiltercnt=1)
         SET req600123->arguments[idx].argument_name = param
        ELSEIF (patfiltercnt=2)
         SET req600123->arguments[idx].parent_entity_id = cnvtreal(param)
         SET patfiltercntvalidind = 1
        ELSEIF (patfiltercnt > 2)
         CALL echorecord(patient_filter)
         CALL echo("INVALID NUMBER OF PATIENT FILTER FIELDS (TOO MANY)...EXITING")
         CALL echo(
          "CHECK THAT PATIENT FILTERS CONTAINING RESERVED CHARACTERS USE APPROPRIATE ESCAPE SEQUENCE"
          )
         GO TO exit_script
        ENDIF
       ENDIF
      ENDIF
      SET block = substring((endpos+ 2),(size(block) - endpos),block)
      CALL echo(build("BLOCK:",block))
      CALL echo(size(block))
    ENDWHILE
   ENDIF
 ENDFOR
 IF (patfiltercntvalidind=0)
  CALL echo("INVALID NUMBER OF PATIENT FILTER FIELDS (TOO FEW)...EXITING")
  CALL echo(
   "CHECK THAT PATIENT FILTERS CONTAINING RESERVED CHARACTERS USE APPROPRIATE ESCAPE SEQUENCE")
  GO TO exit_script
 ENDIF
 DECLARE patient_cnt = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE applicationid = i4 WITH protect, constant(600005)
 DECLARE taskid = i4 WITH protect, constant(3200100)
 DECLARE requestid = i4 WITH protect, constant(600123)
 SET req600123->patient_list_id =  $2
 SET req600123->patient_list_type_cd = patient_list_type_cd
 SET req600123->best_encntr_flag = cnvtint( $4)
 CALL echorecord(req600123)
 CALL echo(build("TDBEXECUTE FOR ",requestid))
 SET stat = tdbexecute(applicationid,taskid,requestid,"REC",req600123,
  "REC",rep600123,1)
 IF (stat > 0)
  SET errcode = error(errmsg,1)
  CALL echo(build("TDBEXECUTE ",requestid," - ERROR CODE: ",errcode," - ERROR MESSAGE: ",
    errmsg))
  GO TO exit_script
 ENDIF
 CALL echorecord(rep600123)
 DECLARE status_filter_cnt = i4 WITH protect, noconstant(0)
 DECLARE status_filter_str = vc WITH protect, noconstant(" ")
 DECLARE fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"MRN"))
 DECLARE cmrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"CMRN"))
 DECLARE attenddoc_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",333,"ATTENDDOC"))
 DECLARE mrn_pool_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",263,"MRN"))
 DECLARE inpatient_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",69,"INPATIENT"))
 DECLARE observation_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",69,"OBSERVATION"))
 DECLARE emergency_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",69,"EMERGENCY"))
 FOR (idx = 1 TO size(req600123->arguments,5))
   IF (cnvtlower(req600123->arguments[idx].argument_name)="encntr_status"
    AND (req600123->arguments[idx].parent_entity_id > 0.0))
    SET status_filter_cnt = (status_filter_cnt+ 1)
    SET status_filter_str = build(status_filter_str,req600123->arguments[idx].parent_entity_id,",")
   ENDIF
 ENDFOR
 IF (status_filter_cnt > 0)
  SET status_filter_str = build("(",status_filter_str,")")
  SET where_status_filter = build(" E.ENCNTR_STATUS_CD IN ",replace(trim(status_filter_str,3),",)",
    ")",0))
 ELSE
  SET where_status_filter = build(" E.ENCNTR_STATUS_CD != 0")
 ENDIF
#exit_script
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
 ) WITH protect
 DECLARE patientcnt = i4 WITH protect, noconstant(0)
 SET output->status = evaluate(rep600123->status_data.status,"F","F","S")
 IF (size(rep600123->patients,5) > 0)
  SELECT INTO "NL:"
   attend_phys = p2.name_full_formatted, priority = rep600123->patients[d1.seq].priority,
   responsible_prsnl_id = rep600123->patients[d1.seq].responsible_prsnl_id,
   responsible_reltn_id = rep600123->patients[d1.seq].responsible_reltn_id, responsible_reltn_cd =
   rep600123->patients[d1.seq].responsible_reltn_cd, responsible_reltn_disp = rep600123->patients[d1
   .seq].responsible_reltn_disp
   FROM (dummyt d1  WITH seq = size(rep600123->patients,5)),
    encounter e,
    person p,
    encntr_alias ea,
    person_alias pa,
    person_alias pam,
    encntr_prsnl_reltn epr,
    person p2
   PLAN (d1)
    JOIN (e
    WHERE (e.encntr_id=rep600123->patients[d1.seq].encntr_id)
     AND parser(where_status_filter))
    JOIN (p
    WHERE p.person_id=e.person_id
     AND p.active_ind=1
     AND p.beg_effective_dt_tm < sysdate
     AND p.end_effective_dt_tm > sysdate)
    JOIN (ea
    WHERE ea.encntr_id=e.encntr_id
     AND ea.alias != " "
     AND ea.active_ind=1
     AND ea.encntr_alias_type_cd=fin_cd
     AND ea.beg_effective_dt_tm < sysdate
     AND ea.end_effective_dt_tm > sysdate)
    JOIN (pa
    WHERE pa.person_id=e.person_id
     AND pa.active_ind=1
     AND pa.person_alias_type_cd=cmrn_cd
     AND pa.beg_effective_dt_tm < sysdate
     AND pa.end_effective_dt_tm > sysdate)
    JOIN (pam
    WHERE pam.person_id=e.person_id
     AND pam.active_ind=1
     AND pam.person_alias_type_cd=mrn_cd
     AND pam.beg_effective_dt_tm < sysdate
     AND pam.end_effective_dt_tm > sysdate)
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
   ORDER BY e.encntr_id, ea.encntr_alias_type_cd, ea.beg_effective_dt_tm DESC
   HEAD e.encntr_id
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
    preregdttm = format(e.pre_reg_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"),
    output->list[patientcnt].regdttm = format(e.reg_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"), output->list[
    patientcnt].inpatientadmitdttm = format(e.inpatient_admit_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"), output
    ->list[patientcnt].estarrivedttm = format(e.est_arrive_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"),
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
    output->list[patientcnt].dischdttm = format(e.disch_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"), output->
    list[patientcnt].fin = trim(replace(replace(replace(replace(replace(ea.alias,"&","&amp;",0),"<",
         "&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), output->list[patientcnt].mrn =
    trim(replace(replace(replace(replace(replace(pam.alias,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),
       "'","&apos;",0),'"',"&quot;",0),3)
    IF (2=textlen(trim(pa.alias,3)))
     output->list[patientcnt].cmrn = build("00000",trim(replace(replace(replace(replace(replace(pa
            .alias,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3))
    ELSEIF (3=textlen(trim(pa.alias,3)))
     output->list[patientcnt].cmrn = build("0000",trim(replace(replace(replace(replace(replace(pa
            .alias,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3))
    ELSEIF (4=textlen(trim(pa.alias,3)))
     output->list[patientcnt].cmrn = build("000",trim(replace(replace(replace(replace(replace(pa
            .alias,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3))
    ELSEIF (5=textlen(trim(pa.alias,3)))
     output->list[patientcnt].cmrn = build("00",trim(replace(replace(replace(replace(replace(pa.alias,
            "&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3))
    ELSEIF (6=textlen(trim(pa.alias,3)))
     output->list[patientcnt].cmrn = build("0",trim(replace(replace(replace(replace(replace(pa.alias,
            "&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3))
    ELSE
     output->list[patientcnt].cmrn = trim(replace(replace(replace(replace(replace(pa.alias,"&",
           "&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3)
    ENDIF
    output->list[patientcnt].birthdttm = format(p.birth_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"), output->
    list[patientcnt].age = cnvtage(p.birth_dt_tm), output->list[patientcnt].sexcd = p.sex_cd,
    output->list[patientcnt].sex = trim(replace(replace(replace(replace(replace(uar_get_code_display(
           p.sex_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
    output->list[patientcnt].language = trim(replace(replace(replace(replace(replace(
          uar_get_code_display(p.language_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",
       0),'"',"&quot;",0),3), output->list[patientcnt].absbirthdttm = format(p.abs_birth_dt_tm,
     "MM/DD/YYYY HH:MM:SS;;D"),
    output->list[patientcnt].maritalstatus = trim(replace(replace(replace(replace(replace(
          uar_get_code_display(p.marital_type_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
       "&apos;",0),'"',"&quot;",0),3), output->list[patientcnt].lastencntrdttm = format(p
     .last_encntr_dt_tm,"MM/DD/YYYY HH:MM:SS;;D")
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
    output->list[patientcnt].medservice = trim(replace(replace(replace(replace(replace(
          uar_get_code_display(e.med_service_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
       "&apos;",0),'"',"&quot;",0),3)
   WITH nocounter, time = 60
  ;end select
 ENDIF
 DECLARE json = vc WITH protect, constant(cnvtrectojson(output))
 FREE RECORD req3011002
 RECORD req3011002(
   1 source_dir = vc
   1 source_filename = vc
   1 nbrlines = i4
   1 line[*]
     2 linedata = vc
   1 overflowpage[*]
     2 ofr_qual[*]
       3 ofr_line = vc
   1 isblob = c1
   1 document_size = i4
   1 document = vc
 ) WITH protect
 FREE RECORD rep3011002
 RECORD rep3011002(
   1 info_line[*]
     2 new_line = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 SET req3011002->source_filename = moutputdevice
 SET req3011002->isblob = "1"
 SET req3011002->document_size = size(json)
 SET req3011002->document = json
 EXECUTE eks_put_source  WITH replace(request,req3011002), replace(reply,rep3011002)
 CALL echorecord(rep3011002)
 FREE RECORD req3011002
 FREE RECORD rep3011002
 FREE RECORD req600123
 FREE RECORD rep600123
 FREE RECORD output
END GO
