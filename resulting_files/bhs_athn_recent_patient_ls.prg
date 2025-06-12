CREATE PROGRAM bhs_athn_recent_patient_ls
 DECLARE f_mrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4,
   "CORPORATEMEDICALRECORDNUMBER"))
 DECLARE f_fin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE f_prsnl_id = f8 WITH protect, constant( $2)
 SET list_params =  $3
 SET no_of_pairs =  $4
 IF (no_of_pairs > 0)
  FREE RECORD param
  RECORD param(
    1 qual[*]
      2 enc_id = i4
  )
  SET param_list = replace(replace(replace(replace(replace(list_params,"ltpercgt","%",0),"ltampgt",
      "&",0),"ltsquotgt","'",0),"ltscolgt",";",0),"ltpipgt","|",0)
  FOR (i = 1 TO no_of_pairs)
   SET stat = alterlist(param->qual,i)
   SET param->qual[i].enc_id = cnvtint(piece(param_list,"|",i,"N/A"))
  ENDFOR
  SELECT INTO  $1
   pat_name = trim(replace(replace(replace(replace(replace(trim(p.name_full_formatted,3),"&","&amp;",
         0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), gender = trim(replace(
     replace(replace(replace(replace(trim(uar_get_code_display(p.sex_cd),3),"&","&amp;",0),"<","&lt;",
        0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), marital_status = uar_get_code_display(p
    .marital_type_cd),
   dob = format(p.birth_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"), absolutedob = format(p.abs_birth_dt_tm,
    "MM/DD/YYYY HH:MM:SS;;D"), age = cnvtage(p.birth_dt_tm),
   bed = trim(replace(replace(replace(replace(replace(trim(uar_get_code_display(e.loc_bed_cd),3),"&",
         "&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), room = trim(
    replace(replace(replace(replace(replace(trim(uar_get_code_display(e.loc_room_cd),3),"&","&amp;",0
         ),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), reg_dt = format(e
    .reg_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"),
   prereg_dt = format(e.pre_reg_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"), estarrival_dt = format(e
    .est_arrive_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"), admit_dt = format(e.inpatient_admit_dt_tm,
    "MM/DD/YYYY HH:MM:SS;;D"),
   disch_dt = format(e.disch_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"), rov = trim(replace(replace(replace(
       replace(replace(trim(e.reason_for_visit,3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
      "&apos;",0),'"',"&quot;",0),3), med_service = trim(replace(replace(replace(replace(replace(trim
         (uar_get_code_display(e.med_service_cd),3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
      "&apos;",0),'"',"&quot;",0),3),
   language = trim(replace(replace(replace(replace(replace(trim(uar_get_code_display(p.language_cd),3
          ),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), p
   .person_id, e.encntr_id,
   mrn = trim(cnvtalias(pa.alias,pa.alias_pool_cd),3), fin = trim(cnvtalias(ea.alias,ea.alias_pool_cd
     ),3), encntr_status = trim(replace(replace(replace(replace(replace(trim(uar_get_code_display(e
           .encntr_status_cd),3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
     "&quot;",0),3),
   attend_phys = trim(replace(replace(replace(replace(replace(trim(pm_get_encntr_prsnl("ATTENDDOC",e
           .encntr_id,sysdate),3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
     "&quot;",0),3), admit_phys = trim(replace(replace(replace(replace(replace(trim(
          pm_get_encntr_prsnl("ADMITDOC",e.encntr_id,sysdate),3),"&","&amp;",0),"<","&lt;",0),">",
       "&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), refer_phys = trim(replace(replace(replace(
       replace(replace(trim(pm_get_encntr_prsnl("REFERDOC",e.encntr_id,sysdate),3),"&","&amp;",0),"<",
        "&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
   pcp_phys = trim(replace(replace(replace(replace(replace(trim(pm_get_person_prsnl("PCP",e.person_id,
           sysdate),3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
   epr =
   IF (r_ep.encntr_id != 0) "YES"
   ELSE "NO"
   ENDIF
   , ppr =
   IF (r_pp.person_id != 0) "YES"
   ELSE "NO"
   ENDIF
   ,
   last_enct_dt = format(p.last_encntr_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"), e.loc_facility_cd,
   facilityname = trim(replace(replace(replace(replace(replace(trim(uar_get_code_display(e
           .loc_facility_cd),3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
     "&quot;",0),3),
   nurseunit = trim(replace(replace(replace(replace(replace(trim(uar_get_code_display(e
           .loc_nurse_unit_cd),3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
     "&quot;",0),3), encountertypename = trim(replace(replace(replace(replace(replace(trim(
          uar_get_code_display(e.encntr_type_cd),3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
      "&apos;",0),'"',"&quot;",0),3), patienttype =
   IF (((e.encntr_type_cd=679668) OR (((e.encntr_type_cd=679662) OR (((e.encntr_type_cd=679658) OR (
   ((e.encntr_type_cd=679656) OR (((e.encntr_type_cd=679659) OR (((e.encntr_type_cd=2495726) OR (((e
   .encntr_type_cd=309310) OR (((e.encntr_type_cd=679683) OR (((e.encntr_type_cd=679670) OR (((e
   .encntr_type_cd=679657) OR (((e.encntr_type_cd=679677) OR (((e.encntr_type_cd=309308) OR (((e
   .encntr_type_cd=309312) OR (((e.encntr_type_cd=679653) OR (((e.encntr_type_cd=679672) OR (((e
   .encntr_type_cd=679660) OR (((e.encntr_type_cd=679654) OR (((e.encntr_type_cd=679655) OR (e
   .encntr_type_cd=679664)) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ) "IP"
   ELSE "OP"
   ENDIF
   ,
   e_encntr_type_class_cd = cnvtstring(e.encntr_type_class_cd), e_encntr_type_class_disp =
   uar_get_code_display(e.encntr_type_class_cd), e_encntr_type_class_mean = uar_get_code_meaning(e
    .encntr_type_class_cd)
   FROM (dummyt d1  WITH seq = value(size(param->qual,5))),
    encounter e,
    person p,
    person_alias pa,
    encntr_alias ea,
    encntr_prsnl_reltn r_ep,
    person_prsnl_reltn r_pp
   PLAN (d1)
    JOIN (e
    WHERE (e.encntr_id=param->qual[d1.seq].enc_id)
     AND e.active_ind=1
     AND e.active_status_cd=188)
    JOIN (p
    WHERE p.person_id=e.person_id)
    JOIN (pa
    WHERE pa.person_id=p.person_id
     AND pa.person_alias_type_cd=f_mrn_cd
     AND pa.beg_effective_dt_tm < sysdate
     AND pa.end_effective_dt_tm > sysdate
     AND pa.active_ind=1)
    JOIN (ea
    WHERE ea.encntr_id=e.encntr_id
     AND ea.encntr_alias_type_cd=f_fin_cd
     AND ea.beg_effective_dt_tm < sysdate
     AND ea.end_effective_dt_tm > sysdate
     AND ea.active_ind=1)
    JOIN (r_ep
    WHERE (r_ep.encntr_id= Outerjoin(e.encntr_id))
     AND (r_ep.beg_effective_dt_tm< Outerjoin(sysdate))
     AND (r_ep.end_effective_dt_tm> Outerjoin(sysdate))
     AND (r_ep.active_ind= Outerjoin(1))
     AND (r_ep.prsnl_person_id= Outerjoin(f_prsnl_id)) )
    JOIN (r_pp
    WHERE (r_pp.person_id= Outerjoin(e.person_id))
     AND (r_pp.beg_effective_dt_tm< Outerjoin(sysdate))
     AND (r_pp.end_effective_dt_tm> Outerjoin(sysdate))
     AND (r_pp.active_ind= Outerjoin(1))
     AND (r_pp.prsnl_person_id= Outerjoin(f_prsnl_id)) )
   ORDER BY d1.seq
   HEAD REPORT
    html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
     '"',"UTF-8",'"'," ?>"), col 0, html_tag,
    row + 1, col + 1, "<ReplyMessage>"
   HEAD e.encntr_id
    col + 1, "<Patient>", row + 1,
    p_patid = build("<PatientId>",cnvtint(e.person_id),"</PatientId>"), col + 1, p_patid,
    row + 1, pname = build("<FullName>",pat_name,"</FullName>"), col + 1,
    pname, row + 1, pgenderid = build("<GenderId>",cnvtstring(p.sex_cd),"</GenderId>"),
    col + 1, pgenderid, row + 1,
    pgender = build("<Gender>",gender,"</Gender>"), col + 1, pgender,
    row + 1, pdob = build("<DOB>",dob,"</DOB>"), col + 1,
    pdob, row + 1, p_age = build("<Age>",age,"</Age>"),
    col + 1, p_age, row + 1,
    p_lan = build("<Language>",language,"</Language>"), col + 1, p_lan,
    row + 1
    IF (2=textlen(trim(mrn,3)))
     p_mrn = build("<Mrn>","00000",mrn,"</Mrn>")
    ELSEIF (3=textlen(trim(mrn,3)))
     p_mrn = build("<Mrn>","0000",mrn,"</Mrn>")
    ELSEIF (4=textlen(trim(mrn,3)))
     p_mrn = build("<Mrn>","000",mrn,"</Mrn>")
    ELSEIF (5=textlen(trim(mrn,3)))
     p_mrn = build("<Mrn>","00",mrn,"</Mrn>")
    ELSEIF (6=textlen(trim(mrn,3)))
     p_mrn = build("<Mrn>","0",mrn,"</Mrn>")
    ELSE
     p_mrn = build("<Mrn>",mrn,"</Mrn>")
    ENDIF
    col + 1, p_mrn, row + 1,
    p_marital = build("<MaritalStatus>",marital_status,"</MaritalStatus>"), col + 1, p_marital,
    row + 1, p_absdob = build("<AbsoluteBirthDateTime>",absolutedob,"</AbsoluteBirthDateTime>"), col
     + 1,
    p_absdob, row + 1, p_lstencdt = build("<LastEncounterDateTime>",last_enct_dt,
     "</LastEncounterDateTime>"),
    col + 1, p_lstencdt, row + 1,
    p_pcp = build("<PrimaryCarePhysician>",pcp_phys,"</PrimaryCarePhysician>"), col + 1, p_pcp,
    row + 1, ethnic_grp_cd = build("<EthnicityId>",cnvtstring(p.ethnic_grp_cd),"</EthnicityId>"), col
     + 1,
    ethnic_grp_cd, row + 1, ethnic_grp_disp = build("<EthnicityDisp>",trim(replace(replace(replace(
         replace(replace(trim(uar_get_code_display(p.ethnic_grp_cd),3),"&","&amp;",0),"<","&lt;",0),
         ">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</EthnicityDisp>"),
    col + 1, ethnic_grp_disp, row + 1,
    col + 1, "<Encounters>", row + 1,
    col + 1, "<Encounter>", row + 1,
    p_encid = build("<EncounterId>",cnvtint(e.encntr_id),"</EncounterId>"), col + 1, p_encid,
    row + 1, col + 1, p_patid,
    row + 1, p_bed = build("<Bed>",bed,"</Bed>"), col + 1,
    p_bed, row + 1, p_bedid = build("<BedId>",cnvtint(e.loc_bed_cd),"</BedId>"),
    col + 1, p_bedid, row + 1,
    p_room = build("<Room>",room,"</Room>"), col + 1, p_room,
    row + 1, p_reg_dt = build("<RegistrationDateTime>",reg_dt,"</RegistrationDateTime>"), col + 1,
    p_reg_dt, row + 1, p_prereg_dt = build("<PreRegistrationDateTime>",prereg_dt,
     "</PreRegistrationDateTime>"),
    col + 1, p_prereg_dt, row + 1,
    p_estarr_dt = build("<EstimateArriveDateTime>",estarrival_dt,"</EstimateArriveDateTime>"), col +
    1, p_estarr_dt,
    row + 1, p_admit_dt = build("<AdmitDateTime>",admit_dt,"</AdmitDateTime>"), col + 1,
    p_admit_dt, row + 1, p_disch_dt = build("<DischDateTime>",disch_dt,"</DischDateTime>"),
    col + 1, p_disch_dt, row + 1,
    p_rov = build("<ReasonForVisit>",rov,"</ReasonForVisit>"), col + 1, p_rov,
    row + 1, p_ms = build("<MedService>",med_service,"</MedService>"), col + 1,
    p_ms, row + 1, p_fin = build("<Fin>",fin,"</Fin>"),
    col + 1, p_fin, row + 1,
    p_es = build("<EncounterStatus>",encntr_status,"</EncounterStatus>"), col + 1, p_es,
    row + 1, p_attend = build("<AttendingPhysician>",attend_phys,"</AttendingPhysician>"), col + 1,
    p_attend, row + 1, p_admit = build("<AdmittingPhysician>",admit_phys,"</AdmittingPhysician>"),
    col + 1, p_admit, row + 1,
    p_refer = build("<ReferringPhysician>",refer_phys,"</ReferringPhysician>"), col + 1, p_refer,
    row + 1, p_epr = build("<EncounterLevelRelationship>",epr,"</EncounterLevelRelationship>"), col
     + 1,
    p_epr, row + 1, p_ppr = build("<PersonLevelRelationship>",ppr,"</PersonLevelRelationship>"),
    col + 1, p_ppr, row + 1,
    p_fac = build("<FacilityId>",cnvtint(e.loc_facility_cd),"</FacilityId>"), col + 1, p_fac,
    row + 1, p_fac_n = build("<FacilityName>",facilityname,"</FacilityName>"), col + 1,
    p_fac_n, row + 1, p_enctype = build("<EncounterTypeId>",cnvtint(e.encntr_type_cd),
     "</EncounterTypeId>"),
    col + 1, p_enctype, row + 1,
    p_enctype_n = build("<EncounterTypeString>",encountertypename,"</EncounterTypeString>"), col + 1,
    p_enctype_n,
    row + 1, p_nurseunit = build("<NurseUnit>",nurseunit,"</NurseUnit>"), col + 1,
    p_nurseunit, row + 1, p_nurseunitid = build("<NurseUnitId>",cnvtint(e.loc_nurse_unit_cd),
     "</NurseUnitId>"),
    col + 1, p_nurseunitid, row + 1,
    p_patienttype = build("<PatientType>",patienttype,"</PatientType>"), col + 1, p_patienttype,
    row + 1, e_type_class_cd = build("<EncounterTypeClassId>",e_encntr_type_class_cd,
     "</EncounterTypeClassId>"), col + 1,
    e_type_class_cd, row + 1, e_type_class_disp = build("<EncounterTypeClassDisp>",
     e_encntr_type_class_disp,"</EncounterTypeClassDisp>"),
    col + 1, e_type_class_disp, row + 1,
    e_type_class_mean = build("<EncounterTypeClassMean>",e_encntr_type_class_mean,
     "</EncounterTypeClassMean>"), col + 1, e_type_class_mean,
    row + 1, col + 1, "</Encounter>",
    row + 1, col + 1, "</Encounters>",
    row + 1, col + 1, "</Patient>",
    row + 1
   FOOT REPORT
    col + 1, "</ReplyMessage>", row + 1
   WITH nocounter, nullreport, formfeed = none,
    maxcol = 1000, format = variable, maxrow = 0,
    time = 20
  ;end select
  FREE RECORD param
 ELSE
  SELECT INTO  $1
   FROM dummyt d
   HEAD REPORT
    html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
     '"',"UTF-8",'"'," ?>"), col 0, html_tag,
    row + 1, col + 1, "<ReplyMessage>",
    row + 1, col + 1, "</ReplyMessage>"
   WITH format, separator = "", maxcol = 100
  ;end select
 ENDIF
END GO
