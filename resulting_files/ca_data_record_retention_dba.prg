CREATE PROGRAM ca_data_record_retention:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE inextuid = i4 WITH protect, noconstant(1)
 RECORD encntr_aux_field(
   1 arrive_dt_tm = dq8
   1 create_dt_tm = dq8
   1 disch_dt_tm = dq8
   1 est_arrive_dt_tm = dq8
   1 encntr_status_cd = f8
   1 encntr_type_cd = f8
   1 location_cd = f8
   1 loc_temp_cd = f8
   1 reason_for_visit = vc
   1 reg_dt_tm = dq8
   1 updt_dt_tm = dq8
   1 encntr_alias[*]
     2 alias = vc
     2 encntr_alias_type_cd = f8
   1 encntr_prsnl_reltn[*]
     2 encntr_prsnl_reltn_id = f8
     2 encntr_prsnl_r_cd = f8
     2 prsnl_person_id = f8
 )
 FREE RECORD req600327
 RECORD req600327(
   1 person_id = f8
   1 select_encntr_meaning = c12
   1 ignore_security = i2
   1 restrict_encntr_meaning = i2
 )
 FREE RECORD rep600327
 RECORD rep600327(
   1 encntr_id = f8
   1 time_zone_index = i4
   1 lookup_status = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SUBROUTINE (createdatefield(parenthandle=i4,name=vc,uid=i4,parentuid=i4,dtvalue=dq8) =i2)
   DECLARE hfield = i4 WITH private, noconstant(0)
   SET hfield = uar_srvadditem(parenthandle,"fields")
   SET stat = uar_srvsetstring(hfield,"name",nullterm(name))
   SET stat = uar_srvsetshort(hfield,"_dtValue",1)
   IF ((uid=- (1)))
    SET stat = uar_srvsetlong(hfield,"UID",getnextuid(0))
   ELSE
    SET stat = uar_srvsetlong(hfield,"UID",uid)
   ENDIF
   SET stat = uar_srvsetlong(hfield,"parentUID",parentuid)
   SET stat = uar_srvsetdate(hfield,"dtValue",cnvtdatetime(dtvalue))
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (createdoublefield(parenthandle=i4,name=vc,uid=i4,parentuid=i4,dblvalue=f8) =i2)
   DECLARE hfield = i4 WITH private, noconstant(0)
   SET hfield = uar_srvadditem(parenthandle,"fields")
   SET stat = uar_srvsetstring(hfield,"name",nullterm(name))
   SET stat = uar_srvsetshort(hfield,"_dblValue",1)
   IF ((uid=- (1)))
    SET stat = uar_srvsetlong(hfield,"UID",getnextuid(0))
   ELSE
    SET stat = uar_srvsetlong(hfield,"UID",uid)
   ENDIF
   SET stat = uar_srvsetlong(hfield,"parentUID",parentuid)
   SET stat = uar_srvsetdouble(hfield,"dblValue",dblvalue)
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (createlistfield(parenthandle=i4,name=vc,uid=i4,parentuid=i4) =i2)
   DECLARE hfield = i4 WITH private, noconstant(0)
   SET hfield = uar_srvadditem(parenthandle,"fields")
   SET stat = uar_srvsetstring(hfield,"name",nullterm(name))
   SET stat = uar_srvsetshort(hfield,"_listValue",1)
   IF ((uid=- (1)))
    SET stat = uar_srvsetlong(hfield,"UID",getnextuid(0))
   ELSE
    SET stat = uar_srvsetlong(hfield,"UID",uid)
   ENDIF
   SET stat = uar_srvsetlong(hfield,"parentUID",parentuid)
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (createlongfield(parenthandle=i4,name=vc,uid=i4,parentuid=i4,longvalue=i4) =i2)
   DECLARE hfield = i4 WITH private, noconstant(0)
   SET hfield = uar_srvadditem(parenthandle,"fields")
   SET stat = uar_srvsetstring(hfield,"name",nullterm(name))
   SET stat = uar_srvsetshort(hfield,"_longValue",1)
   IF ((uid=- (1)))
    SET stat = uar_srvsetlong(hfield,"UID",getnextuid(0))
   ELSE
    SET stat = uar_srvsetlong(hfield,"UID",uid)
   ENDIF
   SET stat = uar_srvsetlong(hfield,"parentUID",parentuid)
   SET stat = uar_srvsetlong(hfield,"longValue",longvalue)
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (createstringfield(parenthandle=i4,name=vc,uid=i4,parentuid=i4,strvalue=vc) =i2)
   DECLARE hfield = i4 WITH private, noconstant(0)
   SET hfield = uar_srvadditem(parenthandle,"fields")
   SET stat = uar_srvsetstring(hfield,"name",nullterm(name))
   SET stat = uar_srvsetshort(hfield,"_strValue",1)
   IF ((uid=- (1)))
    SET stat = uar_srvsetlong(hfield,"UID",getnextuid(0))
   ELSE
    SET stat = uar_srvsetlong(hfield,"UID",uid)
   ENDIF
   SET stat = uar_srvsetlong(hfield,"parentUID",parentuid)
   SET stat = uar_srvsetstring(hfield,"strValue",nullterm(strvalue))
   RETURN(true)
 END ;Subroutine
 DECLARE getnextuid(dummy) = i4
 SUBROUTINE getnextuid(dummy)
   DECLARE nextuid = i4 WITH protect, noconstant(inextuid)
   SET inextuid += 1
   RETURN(nextuid)
 END ;Subroutine
 SUBROUTINE (populateencntrauxiliaryfields(encntrid=f8) =i2)
   DECLARE active_status_cd = f8 WITH protect, constant(reqdata->active_status_cd)
   SELECT INTO "nl:"
    FROM encounter e,
     encntr_alias ea,
     encntr_prsnl_reltn epr
    PLAN (e
     WHERE e.encntr_id=encntrid
      AND (e.active_ind= Outerjoin(1))
      AND (e.active_status_cd= Outerjoin(active_status_cd))
      AND (e.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(sysdate)))
      AND (e.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
     JOIN (ea
     WHERE (ea.encntr_id= Outerjoin(e.encntr_id))
      AND (ea.active_ind= Outerjoin(1))
      AND (ea.active_status_cd= Outerjoin(active_status_cd))
      AND (ea.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(sysdate)))
      AND (ea.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
     JOIN (epr
     WHERE (epr.encntr_id= Outerjoin(e.encntr_id))
      AND (epr.active_ind= Outerjoin(1))
      AND (epr.active_status_cd= Outerjoin(active_status_cd))
      AND (epr.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(sysdate)))
      AND (epr.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
    ORDER BY e.encntr_id, ea.encntr_alias_id, epr.encntr_prsnl_reltn_id
    HEAD REPORT
     ea_cnt = 0, epr_cnt = 0, idx_found = 0
    HEAD e.encntr_id
     encntr_aux_field->arrive_dt_tm = e.arrive_dt_tm, encntr_aux_field->create_dt_tm = e.create_dt_tm,
     encntr_aux_field->disch_dt_tm = e.disch_dt_tm,
     encntr_aux_field->est_arrive_dt_tm = e.est_arrive_dt_tm, encntr_aux_field->encntr_status_cd = e
     .encntr_status_cd, encntr_aux_field->encntr_type_cd = e.encntr_type_cd,
     encntr_aux_field->location_cd = e.location_cd, encntr_aux_field->loc_temp_cd = e.loc_temp_cd,
     encntr_aux_field->reason_for_visit = e.reason_for_visit,
     encntr_aux_field->reg_dt_tm = e.reg_dt_tm, encntr_aux_field->updt_dt_tm = e.updt_dt_tm
    HEAD ea.encntr_alias_id
     ea_cnt += 1, stat = alterlist(encntr_aux_field->encntr_alias,ea_cnt), encntr_aux_field->
     encntr_alias[ea_cnt].alias = ea.alias,
     encntr_aux_field->encntr_alias[ea_cnt].encntr_alias_type_cd = ea.encntr_alias_type_cd
    HEAD epr.encntr_prsnl_reltn_id
     idx_found = locateval(idx_found,1,size(encntr_aux_field->encntr_prsnl_reltn,5),epr
      .encntr_prsnl_reltn_id,encntr_aux_field->encntr_prsnl_reltn[idx_found].encntr_prsnl_reltn_id)
     IF (idx_found=0)
      epr_cnt += 1, stat = alterlist(encntr_aux_field->encntr_prsnl_reltn,epr_cnt), encntr_aux_field
      ->encntr_prsnl_reltn[epr_cnt].encntr_prsnl_reltn_id = epr.encntr_prsnl_reltn_id,
      encntr_aux_field->encntr_prsnl_reltn[epr_cnt].encntr_prsnl_r_cd = epr.encntr_prsnl_r_cd,
      encntr_aux_field->encntr_prsnl_reltn[epr_cnt].prsnl_person_id = epr.prsnl_person_id
     ENDIF
    WITH nocounter
   ;end select
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (getfacilitybyencounter(encounterid=f8) =f8)
   DECLARE facilitycd = f8 WITH protect, noconstant(0.0)
   IF (encounterid > 0.0)
    SELECT INTO "nl:"
     FROM encounter e
     PLAN (e
      WHERE e.encntr_id=encounterid)
     DETAIL
      facilitycd = e.loc_facility_cd
     WITH nocounter
    ;end select
   ENDIF
   RETURN(facilitycd)
 END ;Subroutine
 IF (validate(pfmt_ibus_ignore_security,0)=0)
  DECLARE pfmt_ibus_ignore_security = i2
  SELECT INTO "nl:"
   FROM dm_info di
   PLAN (di
    WHERE di.info_domain="pfmt_ibus"
     AND di.info_name="ignore_security")
   DETAIL
    pfmt_ibus_ignore_security = cnvtint(di.info_number)
   WITH nocounter
  ;end select
 ENDIF
 SUBROUTINE (getbestencounterid(personid=f8) =f8)
   DECLARE bestencounterid = f8 WITH private, noconstant(0.0)
   IF (personid > 0.0)
    SET stat = initrec(req600327)
    SET stat = initrec(rep600327)
    SET req600327->person_id = personid
    SET req600327->ignore_security = pfmt_ibus_ignore_security
    EXECUTE pts_get_the_best_encntr  WITH replace("REQUEST","REQ600327"), replace("REPLY","REP600327"
     )
    SET bestencounterid = rep600327->encntr_id
   ENDIF
   RETURN(bestencounterid)
 END ;Subroutine
 SUBROUTINE (getfacilitybyany(facilitycdin=f8,encounteridin=f8,personidin=f8) =f8)
   IF (facilitycdin > 0.0)
    RETURN(facilitycdin)
   ENDIF
   DECLARE encounterid = f8 WITH private, noconstant(encounteridin)
   IF (encounterid <= 0.0
    AND personidin > 0.0)
    SET encounterid = getbestencounterid(personidin)
   ENDIF
   DECLARE facilitycd = f8 WITH private, noconstant(0.0)
   SET facilitycd = getfacilitybyencounter(encounterid)
   RETURN(facilitycd)
 END ;Subroutine
 SUBROUTINE (setlogicaldomainfield(parenthandle=i4,parentuid=i4,personid=f8) =i2)
   DECLARE logical_domain_id = f8
   SELECT INTO "nl:"
    FROM person p
    PLAN (p
     WHERE p.person_id=personid)
    DETAIL
     logical_domain_id = p.logical_domain_id
    WITH nocounter
   ;end select
   CALL createdoublefield(parenthandle,"core.logical_domain_id",- (1),parentuid,logical_domain_id)
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (setlogicaldomainfield2(parenthandle=i4,parentuid=i4,encounterid=f8) =i2)
   DECLARE logical_domain_id = f8
   SELECT INTO "nl:"
    FROM person p,
     encounter e
    PLAN (e
     WHERE e.encntr_id=encounterid)
     JOIN (p
     WHERE p.person_id=e.person_id)
    DETAIL
     logical_domain_id = p.logical_domain_id
    WITH nocounter
   ;end select
   CALL createdoublefield(parenthandle,"core.logical_domain_id",- (1),parentuid,logical_domain_id)
   RETURN(true)
 END ;Subroutine
 DECLARE readconfig(dummy) = i2
 IF (validate(info_domain,999)=999)
  DECLARE info_domain = vc WITH protect, noconstant("ca_data_record_retention.prg")
 ENDIF
 IF (validate(info_name,999)=999)
  DECLARE info_name = vc WITH protect, noconstant("LOG_MSGVIEW")
 ENDIF
 IF (validate(log_msgview,999)=999)
  DECLARE log_msgview = i2 WITH protect, noconstant(0)
 ENDIF
 IF (validate(execmsgrtl,999)=999)
  DECLARE execmsgrtl = i2 WITH protect, constant(1)
 ENDIF
 IF (validate(emsglog_commit,999)=999)
  DECLARE emsglog_commit = i4 WITH protect, constant(0)
 ENDIF
 IF (validate(emsglvl_debug,999)=999)
  DECLARE emsglvl_debug = i4 WITH protect, constant(4)
 ENDIF
 IF (validate(msg_debug,999)=999)
  DECLARE msg_debug = i4 WITH protect, noconstant(0)
 ENDIF
 IF (validate(msg_default,999)=999)
  DECLARE msg_default = i4 WITH protect, noconstant(0)
 ENDIF
 CALL cclmain(0)
 GO TO exit_script
 DECLARE cclmain(dummy) = i2
 SUBROUTINE cclmain(dummy)
   CALL readconfig(0)
   CALL performejscall(0)
   RETURN(true)
 END ;Subroutine
 DECLARE performejscall(dummy) = i2
 SUBROUTINE performejscall(dummy)
   CALL msgwrite("**** CAREAWARE IBUS GDPR EVENT NOTIFICATION - Process BEGINS****")
   DECLARE data_domain = vc WITH private, constant("PATIENT")
   DECLARE data_domain_encounter = vc WITH private, constant("ENCOUNTER")
   DECLARE domain_contributor = vc WITH private, constant("ca_data_record_retention.prg")
   DECLARE encounter_event = vc WITH private, constant("ENCOUNTER")
   DECLARE count = i4 WITH noconstant(0)
   DECLARE hmsg_patient = i4 WITH private, noconstant(0)
   DECLARE hreq_patient = i4 WITH private, noconstant(0)
   DECLARE hrep_patient = i4 WITH private, noconstant(0)
   DECLARE ipersonsuid = i4 WITH private, noconstant(0)
   DECLARE ipersonuid = i4 WITH private, noconstant(0)
   DECLARE hmsg_encounter = i4 WITH private, noconstant(0)
   DECLARE hreq_encounter = i4 WITH private, noconstant(0)
   DECLARE hrep_encounter = i4 WITH private, noconstant(0)
   DECLARE iencountersuid = i4 WITH private, noconstant(0)
   DECLARE iencounteruid = i4 WITH private, noconstant(0)
   DECLARE i = i4 WITH private, noconstant(0)
   EXECUTE srvrtl
   CALL msgwrite("Fetching encounters for pateint with person ID :")
   CALL msgwrite(cnvtstring(request->person_id))
   FREE RECORD encounterholder
   RECORD encounterholder(
     1 encounter[*]
       2 encounter_id = f8
   )
   IF ((request->process="DELETE"))
    SELECT INTO "nl:"
     FROM encounter0077drr r
     WHERE (r.person_id=request->person_id)
     DETAIL
      count += 1, stat = alterlist(encounterholder->encounter,count), encounterholder->encounter[
      count].encounter_id = r.encntr_id
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "nl:"
     FROM encounter e
     WHERE (e.person_id=request->person_id)
     DETAIL
      count += 1, stat = alterlist(encounterholder->encounter,count), encounterholder->encounter[
      count].encounter_id = e.encntr_id
     WITH nocounter
    ;end select
   ENDIF
   SET hmsg_patient = uar_srvselectmessage(4700001)
   SET hreq_patient = uar_srvcreaterequest(hmsg_patient)
   SET stat = uar_srvsetstring(hreq_patient,"domain",nullterm(data_domain))
   SET stat = uar_srvsetstring(hreq_patient,"contributor",nullterm(domain_contributor))
   SET hevent = uar_srvadditem(hreq_patient,"events")
   SET stat = uar_srvsetstring(hevent,"event",nullterm(encounter_event))
   SET ipersonsuid = getnextuid(0)
   CALL createlistfield(hevent,"patients",ipersonsuid,0)
   SET ieventuid = getnextuid(0)
   CALL createlistfield(hevent,"patients.notification",ieventuid,ipersonsuid)
   CALL createdoublefield(hevent,"persons.person.o_person_id",- (1),ieventuid,request->person_id)
   CALL createdoublefield(hevent,"persons.person.n_person_id",- (1),ieventuid,request->person_id)
   IF ((request->process="RESTRICT"))
    CALL createlongfield(hevent,"persons.person.hide",- (1),ieventuid,1)
    CALL createlongfield(hevent,"persons.person.unhide",- (1),ieventuid,0)
    CALL createlongfield(hevent,"persons.person.delete",- (1),ieventuid,0)
   ELSEIF ((request->process="UNRESTRICT"))
    CALL createlongfield(hevent,"persons.person.hide",- (1),ieventuid,0)
    CALL createlongfield(hevent,"persons.person.unhide",- (1),ieventuid,1)
    CALL createlongfield(hevent,"persons.person.delete",- (1),ieventuid,0)
   ELSEIF ((request->process="DELETE"))
    CALL createlongfield(hevent,"persons.person.hide",- (1),ieventuid,0)
    CALL createlongfield(hevent,"persons.person.unhide",- (1),ieventuid,0)
    CALL createlongfield(hevent,"persons.person.delete",- (1),ieventuid,1)
   ENDIF
   SET hrep_patient = uar_srvcreatereply(hmsg_patient)
   SET stat = uar_srvexecute(hmsg_patient,hreq_patient,hrep_patient)
   CALL uar_srvdestroyinstance(hrep_patient)
   CALL uar_srvdestroyinstance(hreq_patient)
   SET hmsg_encounter = uar_srvselectmessage(4700001)
   SET hreq_encounter = uar_srvcreaterequest(hmsg_encounter)
   SET stat = uar_srvsetstring(hreq_encounter,"domain",nullterm(data_domain_encounter))
   SET stat = uar_srvsetstring(hreq_encounter,"contributor",nullterm(domain_contributor))
   SET hevent = uar_srvadditem(hreq_encounter,"events")
   SET stat = uar_srvsetstring(hevent,"event",nullterm(encounter_event))
   SET iencountersuid = getnextuid(0)
   CALL createlistfield(hevent,"encounters",iencountersuid,(iencountersuid - 1))
   FOR (i = 1 TO count)
     SET iencounteruid = getnextuid(0)
     CALL createlistfield(hevent,"encounters.encounter",iencounteruid,iencountersuid)
     IF ((request->process="RESTRICT"))
      CALL createlongfield(hevent,"encounters.encounter.hide",- (1),iencounteruid,1)
      CALL createlongfield(hevent,"encounters.encounter.unhide",- (1),iencounteruid,0)
      CALL createlongfield(hevent,"encounters.encounter.delete",- (1),iencounteruid,0)
     ELSEIF ((request->process="UNRESTRICT"))
      CALL createlongfield(hevent,"encounters.encounter.hide",- (1),iencounteruid,0)
      CALL createlongfield(hevent,"encounters.encounter.unhide",- (1),iencounteruid,1)
      CALL createlongfield(hevent,"encounters.encounter.delete",- (1),iencounteruid,0)
     ELSEIF ((request->process="DELETE"))
      CALL createlongfield(hevent,"encounters.encounter.hide",- (1),iencounteruid,0)
      CALL createlongfield(hevent,"encounters.encounter.unhide",- (1),iencounteruid,0)
      CALL createlongfield(hevent,"encounters.encounter.delete",- (1),iencounteruid,1)
     ENDIF
     CALL createstringfield(hevent,"encounters.encounter.encntr_id",- (1),iencounteruid,cnvtstring(
       encounterholder->encounter[i].encounter_id))
   ENDFOR
   SET hrep_patient = uar_srvcreatereply(hmsg_encounter)
   SET stat = uar_srvexecute(hmsg_encounter,hreq_encounter,hrep_encounter)
   CALL uar_srvdestroyinstance(hrep_encounter)
   CALL uar_srvdestroyinstance(hreq_encounter)
   RETURN(true)
   CALL msgwrite("**** CAREAWARE IBUS GDPR EVENT NOTIFICATION - Process ENDS****")
 END ;Subroutine
 SUBROUTINE readconfig(null)
   IF (validate(execmsgrtl,999)=999)
    EXECUTE msgrtl
   ENDIF
   SET msg_default = uar_msgdefhandle()
   SET msg_debug = uar_msgopen("data_record_retention_dbg")
   CALL uar_msgsetlevel(msg_debug,emsglvl_debug)
   SELECT INTO "nl:"
    FROM dm_info di
    PLAN (di
     WHERE di.info_domain=info_domain
      AND di.info_name=info_name)
    DETAIL
     log_msgview = cnvtint(di.info_number)
    WITH nocounter
   ;end select
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (msgwrite(msg=vc) =i2)
  SET log_msgview = 1
  IF (log_msgview=1)
   CALL uar_msgwrite(msg_debug,emsglog_commit,nullterm("DRR"),emsglvl_debug,nullterm(msg))
  ENDIF
 END ;Subroutine
#exit_script
 SET reply->status_data.status = "S"
END GO
