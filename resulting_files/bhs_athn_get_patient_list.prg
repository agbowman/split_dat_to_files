CREATE PROGRAM bhs_athn_get_patient_list
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
 SELECT INTO  $1
  attend_phys = pm_get_encntr_prsnl("ATTENDDOC",e.encntr_id,sysdate), priority = rep600123->patients[
  d1.seq].priority, responsible_prsnl_id = rep600123->patients[d1.seq].responsible_prsnl_id,
  responsible_reltn_id = rep600123->patients[d1.seq].responsible_reltn_id, responsible_reltn_cd =
  rep600123->patients[d1.seq].responsible_reltn_cd, responsible_reltn_disp = rep600123->patients[d1
  .seq].responsible_reltn_disp
  FROM (dummyt d1  WITH seq = size(rep600123->patients,5)),
   encounter e,
   person p,
   encntr_alias ea,
   person_alias pa,
   person_alias pam
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
  ORDER BY e.encntr_id, ea.encntr_alias_type_cd, ea.beg_effective_dt_tm DESC
  HEAD REPORT
   html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
    '"',"UTF-8",'"'," ?>"), col 0, html_tag,
   row + 1, col + 1, "<ReplyMessage>",
   row + 1, v0 = build("<Status>",rep600123->status_data.status,"</Status>"), col + 1,
   v0, row + 1, col + 1,
   "<Patients>", row + 1
  HEAD e.encntr_id
   col + 1, "<Patient>", row + 1,
   v1 = build("<PersonId>",cnvtint(e.person_id),"</PersonId>"), col + 1, v1,
   row + 1, v2 = build("<PersonName>",trim(replace(replace(replace(replace(replace(p
          .name_full_formatted,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
      "&quot;",0),3),"</PersonName>"), col + 1,
   v2, row + 1, v3 = build("<EncounterId>",cnvtint(e.encntr_id),"</EncounterId>"),
   col + 1, v3, row + 1,
   v4 = build("<Priority>",cnvtint(priority),"</Priority>"), col + 1, v4,
   row + 1, v5 = build("<ProviderId>",cnvtint(responsible_prsnl_id),"</ProviderId>"), col + 1,
   v5, row + 1, v6 = build("<ProviderRelationshipType>",cnvtint(responsible_reltn_cd),
    "</ProviderRelationshipType>"),
   col + 1, v6, row + 1,
   v7 = build("<ProviderRelationship>",trim(replace(replace(replace(replace(replace(
          responsible_reltn_disp,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
      "&quot;",0),3),"</ProviderRelationship>"), col + 1, v7,
   row + 1, v8 = build("<ProviderRelationshipId>",cnvtint(responsible_reltn_id),
    "</ProviderRelationshipId>"), col + 1,
   v8, row + 1, v9 = build("<FacilityCd>",cnvtint(e.loc_facility_cd),"</FacilityCd>"),
   col + 1, v9, row + 1,
   v10 = build("<Facility>",trim(replace(replace(replace(replace(replace(uar_get_code_display(e
           .loc_facility_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",
      0),3),"</Facility>"), col + 1, v10,
   row + 1, v11 = build("<NurseUnitCd>",cnvtint(e.loc_nurse_unit_cd),"</NurseUnitCd>"), col + 1,
   v11, row + 1, v12 = build("<NurseUnit>",trim(replace(replace(replace(replace(replace(
          uar_get_code_display(e.loc_nurse_unit_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
       "&apos;",0),'"',"&quot;",0),3),"</NurseUnit>"),
   col + 1, v12, row + 1,
   v13 = build("<Room>",trim(replace(replace(replace(replace(replace(uar_get_code_display(e
           .loc_room_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3
     ),"</Room>"), col + 1, v13,
   row + 1, v14 = build("<Bed>",trim(replace(replace(replace(replace(replace(uar_get_code_display(e
           .loc_bed_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
    "</Bed>"), col + 1,
   v14, row + 1, v15 = build("<OrganizationId>",cnvtint(e.organization_id),"</OrganizationId>"),
   col + 1, v15, row + 1,
   v16 = build("<PreRegDtTm>",format(e.pre_reg_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"),"</PreRegDtTm>"), col
    + 1, v16,
   row + 1, v17 = build("<RegDtTm>",format(e.reg_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"),"</RegDtTm>"), col
    + 1,
   v17, row + 1, v18 = build("<InpatientAdmitDtTm>",format(e.inpatient_admit_dt_tm,
     "MM/DD/YYYY HH:MM:SS;;D"),"</InpatientAdmitDtTm>"),
   col + 1, v18, row + 1,
   v19 = build("<EstArriveDtTm>",format(e.est_arrive_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"),
    "</EstArriveDtTm>"), col + 1, v19,
   row + 1, v20 = build("<EncntrTypeClassCd>",cnvtint(e.encntr_type_cd),"</EncntrTypeClassCd>"), col
    + 1,
   v20, row + 1, v211 = build("<EncntrTypeClassId>",cnvtstring(e.encntr_type_class_cd),
    "</EncntrTypeClassId>"),
   col + 1, v211, row + 1,
   v212 = build("<EncntrTypeClassCode>",trim(replace(replace(replace(replace(replace(
          uar_get_code_meaning(e.encntr_type_class_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
       "&apos;",0),'"',"&quot;",0),3),"</EncntrTypeClassCode>"), col + 1, v212,
   row + 1, v21 = build("<EncntrTypeClass>",trim(replace(replace(replace(replace(replace(
          uar_get_code_display(e.encntr_type_class_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
       "&apos;",0),'"',"&quot;",0),3),"</EncntrTypeClass>"), col + 1,
   v21, row + 1, v22 = build("<EncntrTypeCd>",cnvtint(e.encntr_type_cd),"</EncntrTypeCd>"),
   col + 1, v22, row + 1,
   v23 = build("<EncntrType>",trim(replace(replace(replace(replace(replace(uar_get_code_display(e
           .encntr_type_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0
      ),3),"</EncntrType>"), col + 1, v23,
   row + 1, v231 = build("<EncntrTypeCode>",trim(replace(replace(replace(replace(replace(
          uar_get_code_meaning(e.encntr_type_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
       "&apos;",0),'"',"&quot;",0),3),"</EncntrTypeCode>"), col + 1,
   v231, row + 1, v24 = build("<EncntrStatusCd>",cnvtint(e.encntr_status_cd),"</EncntrStatusCd>"),
   col + 1, v24, row + 1,
   v25 = build("<EncntrStatus>",trim(replace(replace(replace(replace(replace(uar_get_code_display(e
           .encntr_status_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",
      0),3),"</EncntrStatus>"), col + 1, v25,
   row + 1, v26 = build("<ReasonForVisit>",trim(replace(replace(replace(replace(replace(e
          .reason_for_visit,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0
      ),3),"</ReasonForVisit>"), col + 1,
   v26, row + 1, v27 = build("<DischDtTm>",format(e.disch_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"),
    "</DischDtTm>"),
   col + 1, v27, row + 1,
   v28 = build("<Fin>",trim(replace(replace(replace(replace(replace(ea.alias,"&","&amp;",0),"<",
         "&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</Fin>"), col + 1, v28,
   row + 1, v29 = build("<Mrn>",trim(replace(replace(replace(replace(replace(pam.alias,"&","&amp;",0),
         "<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</Mrn>"), col + 1,
   v29, row + 1
   IF (2=textlen(trim(pa.alias,3)))
    v37 = build("<CMRN>","00000",trim(replace(replace(replace(replace(replace(pa.alias,"&","&amp;",0),
          "<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</CMRN>")
   ELSEIF (3=textlen(trim(pa.alias,3)))
    v37 = build("<CMRN>","0000",trim(replace(replace(replace(replace(replace(pa.alias,"&","&amp;",0),
          "<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</CMRN>")
   ELSEIF (4=textlen(trim(pa.alias,3)))
    v37 = build("<CMRN>","000",trim(replace(replace(replace(replace(replace(pa.alias,"&","&amp;",0),
          "<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</CMRN>")
   ELSEIF (5=textlen(trim(pa.alias,3)))
    v37 = build("<CMRN>","00",trim(replace(replace(replace(replace(replace(pa.alias,"&","&amp;",0),
          "<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</CMRN>")
   ELSEIF (6=textlen(trim(pa.alias,3)))
    v37 = build("<CMRN>","0",trim(replace(replace(replace(replace(replace(pa.alias,"&","&amp;",0),"<",
          "&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</CMRN>")
   ELSE
    v37 = build("<CMRN>",trim(replace(replace(replace(replace(replace(pa.alias,"&","&amp;",0),"<",
          "&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</CMRN>")
   ENDIF
   col + 1, v37, row + 1,
   v30 = build("<BirthDtTm>",format(p.birth_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"),"</BirthDtTm>"), col + 1,
   v30,
   row + 1, v30a = build("<Age>",cnvtage(p.birth_dt_tm),"</Age>"), col + 1,
   v30a, row + 1, v31 = build("<SexCd>",cnvtint(p.sex_cd),"</SexCd>"),
   col + 1, v31, row + 1,
   v32 = build("<Sex>",trim(replace(replace(replace(replace(replace(uar_get_code_display(p.sex_cd),
          "&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</Sex>"),
   col + 1, v32,
   row + 1, v33 = build("<Language>",trim(replace(replace(replace(replace(replace(
          uar_get_code_display(p.language_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",
       0),'"',"&quot;",0),3),"</Language>"), col + 1,
   v33, row + 1, v34 = build("<AbsBirthDtTm>",format(p.abs_birth_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"),
    "</AbsBirthDtTm>"),
   col + 1, v34, row + 1,
   v35 = build("<MaritalStatus>",trim(replace(replace(replace(replace(replace(uar_get_code_display(p
           .marital_type_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",
      0),3),"</MaritalStatus>"), col + 1, v35,
   row + 1, v36 = build("<LastEncntrDtTm>",format(p.last_encntr_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"),
    "</LastEncntrDtTm>"), col + 1,
   v36, row + 1
   IF (((e.encntr_type_cd=679668) OR (((e.encntr_type_cd=679662) OR (((e.encntr_type_cd=679658) OR (
   ((e.encntr_type_cd=679656) OR (((e.encntr_type_cd=679659) OR (((e.encntr_type_cd=2495726) OR (((e
   .encntr_type_cd=309310) OR (((e.encntr_type_cd=679683) OR (((e.encntr_type_cd=679670) OR (((e
   .encntr_type_cd=679657) OR (((e.encntr_type_cd=679677) OR (((e.encntr_type_cd=309308) OR (((e
   .encntr_type_cd=309312) OR (((e.encntr_type_cd=679653) OR (((e.encntr_type_cd=679672) OR (((e
   .encntr_type_cd=679660) OR (((e.encntr_type_cd=679654) OR (e.encntr_type_cd=679655)) )) )) )) ))
   )) )) )) )) )) )) )) )) )) )) )) )) )
    v38 = build("<PatientType>","IP","</PatientType>")
   ELSE
    v38 = build("<PatientType>","OP","</PatientType>")
   ENDIF
   col + 1, v38, row + 1,
   v39 = build("<AttendingPhysician>",trim(replace(replace(replace(replace(replace(attend_phys,"&",
          "&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
    "</AttendingPhysician>"), col + 1, v39,
   row + 1, v40 = build("<AdmittingPhysician>",trim(replace(replace(replace(replace(replace(" ","&",
          "&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
    "</AdmittingPhysician>"), col + 1,
   v40, row + 1, v41 = build("<ReferringPhysician>",trim(replace(replace(replace(replace(replace(" ",
          "&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
    "</ReferringPhysician>"),
   col + 1, v41, row + 1,
   v42 = build("<PrimaryCarePhysician>",trim(replace(replace(replace(replace(replace(" ","&","&amp;",
          0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</PrimaryCarePhysician>"
    ), col + 1, v42,
   row + 1, v43 = build("<MedService>",trim(replace(replace(replace(replace(replace(
          uar_get_code_display(e.med_service_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
       "&apos;",0),'"',"&quot;",0),3),"</MedService>"), col + 1,
   v43, row + 1, col + 1,
   "</Patient>", row + 1
  FOOT REPORT
   col + 1, "</Patients>", row + 1,
   col + 1, "</ReplyMessage>", row + 1
  WITH maxcol = 32000, nocounter, nullreport,
   formfeed = none, format = variable, time = 60
 ;end select
 FREE RECORD req600123
 FREE RECORD rep600123
END GO
