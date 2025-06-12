CREATE PROGRAM afc_get_person_encounter_info:dba
 IF ( NOT (validate(log_error)))
  DECLARE log_error = i4 WITH protect, constant(0)
 ENDIF
 IF ( NOT (validate(log_warning)))
  DECLARE log_warning = i4 WITH protect, constant(1)
 ENDIF
 IF ( NOT (validate(log_audit)))
  DECLARE log_audit = i4 WITH protect, constant(2)
 ENDIF
 IF ( NOT (validate(log_info)))
  DECLARE log_info = i4 WITH protect, constant(3)
 ENDIF
 IF ( NOT (validate(log_debug)))
  DECLARE log_debug = i4 WITH protect, constant(4)
 ENDIF
 DECLARE __lpahsys = i4 WITH protect, noconstant(0)
 DECLARE __lpalsysstat = i4 WITH protect, noconstant(0)
 IF (validate(logmessage,char(128))=char(128))
  SUBROUTINE (logmessage(psubroutine=vc,pmessage=vc,plevel=i4) =null)
    DECLARE cs23372_failed_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",23372,"FAILED"))
    DECLARE hmsg = i4 WITH protect, noconstant(0)
    DECLARE hreq = i4 WITH protect, noconstant(0)
    DECLARE hrep = i4 WITH protect, noconstant(0)
    DECLARE hobjarray = i4 WITH protect, noconstant(0)
    DECLARE srvstatus = i4 WITH protect, noconstant(0)
    DECLARE submit_log = i4 WITH protect, constant(4099455)
    CALL echo("")
    CALL echo("::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::")
    IF (size(trim(psubroutine,3)) > 0)
     CALL echo(concat(curprog," : ",psubroutine,"() : ",pmessage))
    ELSE
     CALL echo(concat(curprog," : ",pmessage))
    ENDIF
    CALL echo("::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::")
    CALL echo("")
    SET __lpahsys = 0
    SET __lpalsysstat = 0
    CALL uar_syscreatehandle(__lpahsys,__lpalsysstat)
    IF (__lpahsys > 0)
     CALL uar_sysevent(__lpahsys,plevel,curprog,nullterm(pmessage))
     CALL uar_sysdestroyhandle(__lpahsys)
    ENDIF
    IF (plevel=log_error)
     SET hmsg = uar_srvselectmessage(submit_log)
     SET hreq = uar_srvcreaterequest(hmsg)
     SET hrep = uar_srvcreatereply(hmsg)
     SET hobjarray = uar_srvadditem(hreq,"objArray")
     SET stat = uar_srvsetdouble(hobjarray,"final_status_cd",cs23372_failed_cd)
     SET stat = uar_srvsetstring(hobjarray,"task_name",nullterm(curprog))
     SET stat = uar_srvsetstring(hobjarray,"completion_msg",nullterm(pmessage))
     SET stat = uar_srvsetdate(hobjarray,"end_dt_tm",cnvtdatetime(sysdate))
     SET stat = uar_srvsetstring(hobjarray,"current_node_name",nullterm(curnode))
     SET stat = uar_srvsetstring(hobjarray,"server_name",nullterm(build(curserver)))
     SET srvstatus = uar_srvexecute(hmsg,hreq,hrep)
     IF (srvstatus != 0)
      CALL echo(build2("Execution of pft_save_system_activity_log was not successful"))
     ENDIF
     CALL uar_srvdestroyinstance(hreq)
     CALL uar_srvdestroyinstance(hrep)
    ENDIF
  END ;Subroutine
 ENDIF
 IF ( NOT (validate(go_to_exit_script)))
  DECLARE go_to_exit_script = i2 WITH constant(1)
 ENDIF
 IF ( NOT (validate(dont_go_to_exit_script)))
  DECLARE dont_go_to_exit_script = i2 WITH constant(0)
 ENDIF
 IF (validate(beginservice,char(128))=char(128))
  SUBROUTINE (beginservice(pversion=vc) =null)
   CALL logmessage("",concat("version:",pversion," :Begin Service"),log_debug)
   CALL setreplystatus("F","Begin Service")
  END ;Subroutine
 ENDIF
 IF (validate(exitservicesuccess,char(128))=char(128))
  SUBROUTINE (exitservicesuccess(pmessage=vc) =null)
    DECLARE errmsg = vc WITH noconstant(" ")
    DECLARE errcode = i2 WITH noconstant(1)
    IF (size(trim(pmessage,3)) > 0)
     CALL logmessage("",pmessage,log_info)
    ENDIF
    IF ((((currevminor2+ (currevminor * 100))+ (currev * 10000)) >= 080311))
     IF (curdomain IN ("SURROUND", "SOLUTION"))
      SET errmsg = fillstring(132," ")
      SET errcode = error(errmsg,1)
      IF (errcode != 0)
       CALL exitservicefailure(errmsg,true)
      ELSE
       CALL logmessage("","Exit Service - SUCCESS",log_debug)
       CALL setreplystatus("S",evaluate(pmessage,"","Exit Service - SUCCESS",pmessage))
       SET reqinfo->commit_ind = true
      ENDIF
     ELSE
      CALL logmessage("","Exit Service - SUCCESS",log_debug)
      CALL setreplystatus("S",evaluate(pmessage,"","Exit Service - SUCCESS",pmessage))
      SET reqinfo->commit_ind = true
     ENDIF
    ELSE
     CALL logmessage("","Exit Service - SUCCESS",log_debug)
     CALL setreplystatus("S",evaluate(pmessage,"","Exit Service - SUCCESS",pmessage))
     SET reqinfo->commit_ind = true
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(exitservicefailure,char(128))=char(128))
  SUBROUTINE (exitservicefailure(pmessage=vc,exitscriptind=i2) =null)
    CALL addtracemessage("",evaluate(trim(pmessage),trim(""),"Exit Service - FAILURE",pmessage))
    CALL logmessage("",evaluate(trim(pmessage),trim(""),"Exit Service - FAILURE",pmessage),log_error)
    IF (validate(reply->failure_stack.failures))
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].operationname = reply->failure_stack.failures[1].
     programname
     SET reply->status_data.subeventstatus[1].targetobjectname = reply->failure_stack.failures[1].
     routinename
     SET reply->status_data.subeventstatus[1].targetobjectvalue = reply->failure_stack.failures[1].
     message
    ELSE
     CALL setreplystatus("F",evaluate(trim(pmessage),trim(""),"Exit Service - FAILURE",pmessage))
    ENDIF
    SET reqinfo->commit_ind = false
    IF (exitscriptind)
     GO TO exit_script
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(exitservicenodata,char(128))=char(128))
  SUBROUTINE (exitservicenodata(pmessage=vc,exitscriptind=i2) =null)
    IF (size(trim(pmessage,3)) > 0)
     CALL logmessage("",pmessage,log_info)
    ENDIF
    CALL logmessage("","Exit Service - NO DATA",log_debug)
    CALL setreplystatus("Z",evaluate(pmessage,"","Exit Service - NO DATA",pmessage))
    SET reqinfo->commit_ind = false
    IF (exitscriptind)
     GO TO exit_script
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(setreplystatus,char(128))=char(128))
  SUBROUTINE (setreplystatus(pstatus=vc,pmessage=vc) =null)
    IF (validate(reply->status_data))
     SET reply->status_data.status = nullterm(pstatus)
     SET reply->status_data.subeventstatus[1].operationstatus = nullterm(pstatus)
     SET reply->status_data.subeventstatus[1].operationname = nullterm(curprog)
     SET reply->status_data.subeventstatus[1].targetobjectvalue = nullterm(pmessage)
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(addtracemessage,char(128))=char(128))
  SUBROUTINE (addtracemessage(proutinename=vc,pmessage=vc) =null)
   CALL logmessage(proutinename,pmessage,log_debug)
   IF (validate(reply->failure_stack))
    DECLARE failcnt = i4 WITH protect, noconstant((size(reply->failure_stack.failures,5)+ 1))
    SET stat = alterlist(reply->failure_stack.failures,failcnt)
    SET reply->failure_stack.failures[failcnt].programname = nullterm(curprog)
    SET reply->failure_stack.failures[failcnt].routinename = nullterm(proutinename)
    SET reply->failure_stack.failures[failcnt].message = nullterm(pmessage)
   ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(addstatusdetail,char(128))=char(128))
  SUBROUTINE (addstatusdetail(pentityid=f8,pdetailflag=i4,pdetailmessage=vc) =null)
    IF (validate(reply->status_detail))
     DECLARE detailcnt = i4 WITH protect, noconstant((size(reply->status_detail.details,5)+ 1))
     SET stat = alterlist(reply->status_detail.details,detailcnt)
     SET reply->status_detail.details[detailcnt].entityid = pentityid
     SET reply->status_detail.details[detailcnt].detailflag = pdetailflag
     SET reply->status_detail.details[detailcnt].detailmessage = nullterm(pdetailmessage)
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(copystatusdetails,char(128))=char(128))
  SUBROUTINE (copystatusdetails(pfromrecord=vc(ref),prtorecord=vc(ref)) =null)
    IF (validate(pfromrecord->status_detail)
     AND validate(prtorecord->status_detail))
     DECLARE fromidx = i4 WITH protect, noconstant(0)
     DECLARE fromcnt = i4 WITH protect, noconstant(size(pfromrecord->status_detail.details,5))
     DECLARE toidx = i4 WITH protect, noconstant(size(prtorecord->status_detail.details,5))
     DECLARE fromparamidx = i4 WITH protect, noconstant(0)
     DECLARE toparamcnt = i4 WITH protect, noconstant(0)
     FOR (fromidx = 1 TO fromcnt)
       SET toidx += 1
       SET stat = alterlist(prtorecord->status_detail.details,toidx)
       SET prtorecord->status_detail.details[toidx].entityid = pfromrecord->status_detail.details[
       fromidx].entityid
       SET prtorecord->status_detail.details[toidx].detailflag = pfromrecord->status_detail.details[
       fromidx].detailflag
       SET prtorecord->status_detail.details[toidx].detailmessage = pfromrecord->status_detail.
       details[fromidx].detailmessage
       SET toparamcnt = 0
       FOR (fromparamidx = 1 TO size(pfromrecord->status_detail.details[fromidx].parameters,5))
         SET toparamcnt += 1
         SET stat = alterlist(prtorecord->status_detail.details[toidx].parameters,toparamcnt)
         SET prtorecord->status_detail.details[toidx].parameters[toparamcnt].paramname = pfromrecord
         ->status_detail.details[fromidx].parameters[fromparamidx].paramname
         SET prtorecord->status_detail.details[toidx].parameters[toparamcnt].paramvalue = pfromrecord
         ->status_detail.details[fromidx].parameters[fromparamidx].paramvalue
       ENDFOR
     ENDFOR
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(addstatusdetailparam,char(128))=char(128))
  SUBROUTINE (addstatusdetailparam(pdetailidx=i4,pparamname=vc,pparamvalue=vc) =null)
    IF (validate(reply->status_detail))
     IF (validate(reply->status_detail.details[pdetailidx].parameters))
      DECLARE paramcnt = i4 WITH protect, noconstant((size(reply->status_detail.details[pdetailidx].
        parameters,5)+ 1))
      SET stat = alterlist(reply->status_detail.details[pdetailidx].parameters,paramcnt)
      SET reply->status_detail.details[pdetailidx].parameters[paramcnt].paramname = pparamname
      SET reply->status_detail.details[pdetailidx].parameters[paramcnt].paramvalue = pparamvalue
     ENDIF
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(copytracemessages,char(128))=char(128))
  SUBROUTINE (copytracemessages(pfromrecord=vc(ref),prtorecord=vc(ref)) =null)
    IF (validate(pfromrecord->failure_stack)
     AND validate(prtorecord->failure_stack))
     DECLARE fromidx = i4 WITH protect, noconstant(0)
     DECLARE fromcnt = i4 WITH protect, noconstant(size(pfromrecord->failure_stack.failures,5))
     DECLARE toidx = i4 WITH protect, noconstant(size(prtorecord->failure_stack.failures,5))
     FOR (fromidx = 1 TO fromcnt)
       SET toidx += 1
       SET stat = alterlist(prtorecord->failure_stack.failures,toidx)
       SET prtorecord->failure_stack.failures[toidx].programname = pfromrecord->failure_stack.
       failures[fromidx].programname
       SET prtorecord->failure_stack.failures[toidx].routinename = pfromrecord->failure_stack.
       failures[fromidx].routinename
       SET prtorecord->failure_stack.failures[toidx].message = pfromrecord->failure_stack.failures[
       fromidx].message
     ENDFOR
    ENDIF
  END ;Subroutine
 ENDIF
 CALL beginservice("453226.020")
 RECORD reply(
   1 person_encounter_qual = i2
   1 person_encounter[*]
     2 person_name = vc
     2 person_id = f8
     2 mrn = vc
     2 fin = vc
     2 dob = dq8
     2 age = vc
     2 sex_cd = f8
     2 sex_disp = c40
     2 sex_desc = c60
     2 sex_mean = c12
     2 location_cd = f8
     2 location_disp = c40
     2 location_desc = c60
     2 location_mean = c12
     2 room_cd = f8
     2 room_disp = c40
     2 room_desc = c60
     2 room_mean = c12
     2 bed_cd = f8
     2 bed_disp = c40
     2 bed_desc = c60
     2 bed_mean = c12
     2 attending_physician = vc
     2 physician_id = f8
     2 admitting_physician = vc
     2 admit_phys_id = f8
     2 admit_type_cd = f8
     2 registration_dt_tm = dq8
     2 discharge_dt_tm = dq8
     2 encntr_type_cd = f8
     2 encntr_type_disp = c40
     2 encntr_type_desc = c60
     2 encntr_type_mean = c12
     2 ssn = vc
     2 person_mrn = vc
     2 person_community_mrn = vc
     2 organization_id = f8
     2 loc_nurse_unit_cd = f8
     2 loc_facility_cd = f8
     2 loc_building_cd = f8
     2 health_plan_id = f8
     2 primary_health_plan = vc
     2 primary_health_plans_qual = i2
     2 primary_health_plans[*]
       3 health_plan_id = f8
       3 deduct_amt = f8
       3 primary_health_plan = vc
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
     2 financial_class_cd = f8
     2 financial_class_disp = c40
     2 financial_class_desc = c60
     2 financial_class_mean = c12
     2 ref_phys_id = f8
     2 referring_physician = vc
     2 ord_phys_id = f8
     2 ordering_physician = vc
     2 ren_phys_id = f8
     2 rendering_physician = vc
     2 perf_loc_cd = f8
     2 perf_loc_disp = c40
     2 perf_loc_desc = c60
     2 perf_loc_mean = c12
     2 secondary_health_plan_id = f8
     2 secondary_health_plan = vc
     2 deduct_amt = f8
     2 program_service_cd = f8
     2 birth_tz = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET count1 = 0
 SET stat = alterlist(reply->person_encounter,count1)
 DECLARE code_set = i4
 DECLARE cdf_meaning = c12
 DECLARE cnt = i4
 DECLARE attenddoc = f8
 SET code_set = 333
 SET cdf_meaning = "ATTENDDOC"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,attenddoc)
 CALL echo(build("ATTENDDOC: ",cnvtstring(attenddoc,17,2)))
 DECLARE finnbr = f8
 SET code_set = 319
 SET cdf_meaning = "FIN NBR"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,finnbr)
 DECLARE mrn = f8
 SET code_set = 319
 SET cdf_meaning = "MRN"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,mrn)
 DECLARE ssn = f8
 SET code_set = 4
 SET cdf_meaning = "SSN"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,ssn)
 DECLARE community_mrn = f8
 SET code_set = 4
 SET cdf_meaning = "MRN"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,community_mrn)
 DECLARE person_community_mrn = f8
 SET code_set = 4
 SET cdf_meaning = "CMRN"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,person_community_mrn)
 DECLARE ordering_physician = f8
 SET code_set = 333
 SET cdf_meaning = "ORDERDOC"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,ordering_physician)
 CALL echo(build("ORDERING_PHYSICIAN = ",ordering_physician))
 DECLARE referring_physician = f8
 SET code_set = 333
 SET cdf_meaning = "REFERDOC"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,referring_physician)
 CALL echo(build("REFERRING_PHYSICIAN = ",referring_physician))
 DECLARE admitdoc = f8
 SET code_set = 333
 SET cdf_meaning = "ADMITDOC"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,admitdoc)
 CALL echo(build("ADMITDOC: ",cnvtstring(admitdoc,17,2)))
 DECLARE cobcnt = i4
 SELECT INTO "nl:"
  e.*
  FROM encounter e
  WHERE (e.encntr_id=request->encntr_id)
   AND e.active_ind=1
  DETAIL
   count1 += 1, stat = alterlist(reply->person_encounter,count1), reply->person_encounter[count1].
   person_id = e.person_id,
   reply->person_encounter[count1].location_cd = e.loc_nurse_unit_cd, reply->person_encounter[count1]
   .room_cd = e.loc_room_cd, reply->person_encounter[count1].bed_cd = e.loc_bed_cd,
   reply->person_encounter[count1].discharge_dt_tm = e.disch_dt_tm, reply->person_encounter[count1].
   encntr_type_cd = e.encntr_type_cd, reply->person_encounter[count1].registration_dt_tm = e
   .reg_dt_tm,
   reply->person_encounter[count1].perf_loc_cd = e.location_cd, reply->person_encounter[count1].
   admit_type_cd = e.admit_type_cd, reply->person_encounter[count1].organization_id = e
   .organization_id,
   reply->person_encounter[count1].loc_nurse_unit_cd = e.loc_nurse_unit_cd, reply->person_encounter[
   count1].loc_facility_cd = e.loc_facility_cd, reply->person_encounter[count1].loc_building_cd = e
   .loc_building_cd,
   reply->person_encounter[count1].program_service_cd = e.program_service_cd
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->person_encounter,count1)
 SET reply->person_encounter_qual = count1
 CALL echo(build("person_encounter_qual = ",count1))
 IF (count1 > 0)
  SELECT INTO "nl:"
   p.*
   FROM person p,
    (dummyt d1  WITH seq = value(reply->person_encounter_qual))
   PLAN (d1)
    JOIN (p
    WHERE (p.person_id=reply->person_encounter[d1.seq].person_id)
     AND p.active_ind=1)
   DETAIL
    reply->person_encounter[d1.seq].person_name = p.name_full_formatted, reply->person_encounter[d1
    .seq].age = cnvtage(cnvtdate(p.birth_dt_tm),1), reply->person_encounter[d1.seq].dob = p
    .birth_dt_tm,
    reply->person_encounter[d1.seq].sex_cd = p.sex_cd,
    CALL getbirthtimezone(d1.seq,p.birth_tz)
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   ea.*, pr.*
   FROM encntr_prsnl_reltn ea,
    prsnl pr,
    (dummyt d1  WITH seq = value(reply->person_encounter_qual))
   PLAN (d1)
    JOIN (ea
    WHERE (ea.encntr_id=request->encntr_id)
     AND ea.encntr_prsnl_r_cd=attenddoc
     AND ea.active_ind=1
     AND ea.beg_effective_dt_tm < cnvtdatetime(curdate,curtime)
     AND ea.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
    JOIN (pr
    WHERE pr.person_id=ea.prsnl_person_id
     AND pr.active_ind=1)
   DETAIL
    reply->person_encounter[d1.seq].attending_physician = pr.name_full_formatted, reply->
    person_encounter[d1.seq].physician_id = pr.person_id, reply->person_encounter[d1.seq].ren_phys_id
     = pr.person_id,
    reply->person_encounter[d1.seq].rendering_physician = pr.name_full_formatted,
    CALL echo(concat("Attending Physician: ",cnvtstring(pr.person_id,17,2)))
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   ea.*
   FROM encntr_alias ea,
    (dummyt d1  WITH seq = value(reply->person_encounter_qual))
   PLAN (d1)
    JOIN (ea
    WHERE (ea.encntr_id=request->encntr_id)
     AND ea.encntr_alias_type_cd=finnbr
     AND ea.active_ind=1
     AND ea.beg_effective_dt_tm < cnvtdatetime(curdate,curtime)
     AND ea.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
   DETAIL
    reply->person_encounter[d1.seq].fin = cnvtalias(ea.alias,ea.alias_pool_cd)
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   ea.*
   FROM encntr_alias ea,
    (dummyt d1  WITH seq = value(reply->person_encounter_qual))
   PLAN (d1)
    JOIN (ea
    WHERE (ea.encntr_id=request->encntr_id)
     AND ea.encntr_alias_type_cd=mrn
     AND ea.active_ind=1
     AND ea.beg_effective_dt_tm < cnvtdatetime(curdate,curtime)
     AND ea.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
   DETAIL
    reply->person_encounter[d1.seq].mrn = cnvtalias(ea.alias,ea.alias_pool_cd)
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   pa.*
   FROM person_alias pa,
    (dummyt d1  WITH seq = value(reply->person_encounter_qual))
   PLAN (d1)
    JOIN (pa
    WHERE (pa.person_id=reply->person_encounter[d1.seq].person_id)
     AND pa.person_alias_type_cd=ssn
     AND pa.active_ind=1
     AND pa.beg_effective_dt_tm < cnvtdatetime(curdate,curtime)
     AND pa.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
   DETAIL
    reply->person_encounter[d1.seq].ssn = cnvtalias(pa.alias,pa.alias_pool_cd)
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   ea.*
   FROM person_alias pa,
    (dummyt d1  WITH seq = value(reply->person_encounter_qual))
   PLAN (d1)
    JOIN (pa
    WHERE (pa.person_id=reply->person_encounter[d1.seq].person_id)
     AND pa.person_alias_type_cd=community_mrn
     AND pa.active_ind=1
     AND pa.beg_effective_dt_tm < cnvtdatetime(curdate,curtime)
     AND pa.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
   DETAIL
    reply->person_encounter[d1.seq].person_mrn = cnvtalias(pa.alias,pa.alias_pool_cd)
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   ea.*
   FROM person_alias pa,
    (dummyt d1  WITH seq = value(reply->person_encounter_qual))
   PLAN (d1)
    JOIN (pa
    WHERE (pa.person_id=reply->person_encounter[d1.seq].person_id)
     AND pa.person_alias_type_cd=person_community_mrn
     AND pa.active_ind=1
     AND pa.beg_effective_dt_tm < cnvtdatetime(curdate,curtime)
     AND pa.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
   DETAIL
    reply->person_encounter[d1.seq].person_community_mrn = cnvtalias(pa.alias,pa.alias_pool_cd)
   WITH nocounter
  ;end select
  SELECT DISTINCT INTO "nl:"
   FROM encounter e,
    (dummyt d1  WITH seq = value(reply->person_encounter_qual))
   PLAN (d1)
    JOIN (e
    WHERE (e.encntr_id=request->encntr_id)
     AND e.active_ind=1)
   DETAIL
    reply->person_encounter[d1.seq].financial_class_cd = e.financial_class_cd
   WITH nocounter
  ;end select
  SELECT DISTINCT INTO "nl:"
   FROM encntr_plan_reltn e,
    (dummyt d1  WITH seq = value(reply->person_encounter_qual))
   PLAN (d1)
    JOIN (e
    WHERE (e.encntr_id=request->encntr_id)
     AND e.priority_seq=1
     AND e.active_ind=1
     AND e.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime)
     AND e.end_effective_dt_tm >= cnvtdatetime(curdate,curtime))
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt += 1
   FOOT REPORT
    IF (cnt=1)
     reply->person_encounter[d1.seq].health_plan_id = e.health_plan_id, reply->person_encounter[d1
     .seq].deduct_amt = e.deduct_amt
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM health_plan h,
    (dummyt d1  WITH seq = value(reply->person_encounter_qual))
   PLAN (d1)
    JOIN (h
    WHERE (h.health_plan_id=reply->person_encounter[d1.seq].health_plan_id))
   DETAIL
    reply->person_encounter[d1.seq].primary_health_plan = h.plan_name
   WITH nocounter
  ;end select
  IF (validate(reply->person_encounter[value(reply->person_encounter_qual)].primary_health_plans_qual
   ))
   SELECT INTO "nl:"
    FROM encntr_plan_cob epc,
     encntr_plan_cob_reltn epcr,
     encntr_plan_reltn epr,
     health_plan hp,
     (dummyt d1  WITH seq = value(reply->person_encounter_qual))
    PLAN (d1)
     JOIN (epc
     WHERE (epc.encntr_id=request->encntr_id)
      AND epc.active_ind=true)
     JOIN (epcr
     WHERE epcr.encntr_plan_cob_id=epc.encntr_plan_cob_id
      AND epcr.active_ind=true
      AND epcr.priority_seq=1)
     JOIN (epr
     WHERE epr.encntr_plan_reltn_id=epcr.encntr_plan_reltn_id
      AND epr.active_ind=true)
     JOIN (hp
     WHERE hp.health_plan_id=epr.health_plan_id)
    ORDER BY epr.beg_effective_dt_tm
    HEAD REPORT
     cobcnt = 0
    DETAIL
     cobcnt += 1
     IF (validate(reply->person_encounter[d1.seq].primary_health_plans_qual))
      reply->person_encounter[d1.seq].primary_health_plans_qual = cobcnt
     ENDIF
     IF (validate(reply->person_encounter[d1.seq].primary_health_plans))
      stat = alterlist(reply->person_encounter[d1.seq].primary_health_plans,cobcnt), reply->
      person_encounter[d1.seq].primary_health_plans[cobcnt].health_plan_id = epr.health_plan_id,
      reply->person_encounter[d1.seq].primary_health_plans[cobcnt].deduct_amt = epr.deduct_amt,
      reply->person_encounter[d1.seq].primary_health_plans[cobcnt].primary_health_plan = hp.plan_name,
      reply->person_encounter[d1.seq].primary_health_plans[cobcnt].beg_effective_dt_tm = epr
      .beg_effective_dt_tm, reply->person_encounter[d1.seq].primary_health_plans[cobcnt].
      end_effective_dt_tm = epr.end_effective_dt_tm
     ENDIF
    WITH nocounter
   ;end select
   IF (cobcnt=0)
    SELECT INTO "nl:"
     FROM encntr_plan_reltn epr,
      health_plan hp,
      (dummyt d1  WITH seq = value(reply->person_encounter_qual))
     PLAN (d1)
      JOIN (epr
      WHERE (epr.encntr_id=request->encntr_id)
       AND epr.active_ind=true
       AND epr.priority_seq=1)
      JOIN (hp
      WHERE hp.health_plan_id=epr.health_plan_id)
     ORDER BY epr.beg_effective_dt_tm
     HEAD REPORT
      cnt = 0
     DETAIL
      cnt += 1
      IF (validate(reply->person_encounter[d1.seq].primary_health_plans_qual))
       reply->person_encounter[d1.seq].primary_health_plans_qual = cnt
      ENDIF
      IF (validate(reply->person_encounter[d1.seq].primary_health_plans))
       stat = alterlist(reply->person_encounter[d1.seq].primary_health_plans,cnt), reply->
       person_encounter[d1.seq].primary_health_plans[cnt].health_plan_id = epr.health_plan_id, reply
       ->person_encounter[d1.seq].primary_health_plans[cnt].deduct_amt = epr.deduct_amt,
       reply->person_encounter[d1.seq].primary_health_plans[cnt].primary_health_plan = hp.plan_name,
       reply->person_encounter[d1.seq].primary_health_plans[cnt].beg_effective_dt_tm = epr
       .beg_effective_dt_tm, reply->person_encounter[d1.seq].primary_health_plans[cnt].
       end_effective_dt_tm = epr.end_effective_dt_tm
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
  ENDIF
  SELECT DISTINCT INTO "nl:"
   FROM encntr_plan_reltn e,
    (dummyt d1  WITH seq = value(reply->person_encounter_qual)),
    health_plan hp
   PLAN (d1)
    JOIN (e
    WHERE (e.encntr_id=request->encntr_id)
     AND e.priority_seq=2
     AND e.active_ind=1
     AND e.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime)
     AND e.end_effective_dt_tm >= cnvtdatetime(curdate,curtime))
    JOIN (hp
    WHERE hp.health_plan_id=e.health_plan_id)
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt += 1
   FOOT REPORT
    IF (cnt=1)
     reply->person_encounter[d1.seq].secondary_health_plan_id = e.health_plan_id, reply->
     person_encounter[d1.seq].secondary_health_plan = hp.plan_name
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM encntr_prsnl_reltn e,
    prsnl p,
    (dummyt d1  WITH seq = value(reply->person_encounter_qual))
   PLAN (d1)
    JOIN (e
    WHERE (e.encntr_id=request->encntr_id)
     AND e.encntr_prsnl_r_cd=ordering_physician
     AND e.active_ind=1
     AND e.beg_effective_dt_tm < cnvtdatetime(curdate,curtime)
     AND e.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
    JOIN (p
    WHERE p.person_id=e.prsnl_person_id)
   DETAIL
    reply->person_encounter[d1.seq].ord_phys_id = p.person_id, reply->person_encounter[d1.seq].
    ordering_physician = p.name_full_formatted
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM encntr_prsnl_reltn e,
    prsnl p,
    (dummyt d1  WITH seq = value(reply->person_encounter_qual))
   PLAN (d1)
    JOIN (e
    WHERE (e.encntr_id=request->encntr_id)
     AND e.encntr_prsnl_r_cd=referring_physician
     AND e.active_ind=1
     AND e.beg_effective_dt_tm < cnvtdatetime(curdate,curtime)
     AND e.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
    JOIN (p
    WHERE p.person_id=e.prsnl_person_id)
   DETAIL
    reply->person_encounter[d1.seq].ref_phys_id = p.person_id, reply->person_encounter[d1.seq].
    referring_physician = p.name_full_formatted
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   ea.*, pr.*
   FROM encntr_prsnl_reltn ea,
    prsnl pr,
    (dummyt d1  WITH seq = value(reply->person_encounter_qual))
   PLAN (d1)
    JOIN (ea
    WHERE (ea.encntr_id=request->encntr_id)
     AND ea.encntr_prsnl_r_cd=admitdoc
     AND ea.active_ind=1
     AND ea.beg_effective_dt_tm < cnvtdatetime(curdate,curtime)
     AND ea.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
    JOIN (pr
    WHERE pr.person_id=ea.prsnl_person_id
     AND pr.active_ind=1)
   DETAIL
    reply->person_encounter[d1.seq].admitting_physician = pr.name_full_formatted, reply->
    person_encounter[d1.seq].admit_phys_id = pr.person_id,
    CALL echo(build("admitting physician: ",reply->person_encounter[d1.seq].admitting_physician))
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].operationname = "Select"
   SET reply->status_data.subeventstatus[1].operationstatus = "s"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "ENCOUNTER"
   SET reply->status_data.status = "Z"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
 IF (validate(debug,0)=1)
  CALL echorecord(reply)
 ENDIF
 SUBROUTINE (getbirthtimezone(index=i4,birth_tz=i4) =i2)
   IF (validate(reply->person_encounter[index].birth_tz))
    SET reply->person_encounter[index].birth_tz = birth_tz
   ENDIF
 END ;Subroutine
END GO
