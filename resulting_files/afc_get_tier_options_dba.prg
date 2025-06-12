CREATE PROGRAM afc_get_tier_options:dba
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
 CALL beginservice("CHARGSRV-15373.010")
 RECORD reply(
   1 group_qual = i4
   1 group[*]
     2 tier_group_code = f8
     2 tier_group_disp = c40
     2 tier_group_desc = c60
     2 tier_group_mean = c12
     2 tier_group_updt = i4
     2 cell_qual = i4
     2 cell[*]
       3 tier_cell_id = f8
       3 tier_col_num = i4
       3 tier_row_num = i4
       3 tier_cell_type_cd = f8
       3 tier_cell_type_disp = c40
       3 tier_cell_type_desc = c60
       3 tier_cell_type_mean = c12
       3 tier_cell_value = f8
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
       3 active_ind = i4
       3 tier_cell_entity_name = c32
       3 tier_cell_string = c50
       3 physician_name = vc
     2 cellgroupcount = i4
     2 cellgroup[*]
       3 celllistcount = i4
       3 celllist[*]
         4 tier_cell_id = f8
         4 tier_col_num = i4
         4 tier_row_num = i4
         4 tier_cell_type_cd = f8
         4 tier_cell_type_disp = c40
         4 tier_cell_type_desc = c60
         4 tier_cell_type_mean = c12
         4 tier_cell_value = f8
         4 beg_effective_dt_tm = dq8
         4 end_effective_dt_tm = dq8
         4 active_ind = i4
         4 tier_cell_entity_name = c32
         4 tier_cell_string = c50
         4 physician_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
   1 ismaximumlimitexceeded = i2
 )
 RECORD price_sched_cdm(
   1 price_sched_arr[*]
     2 code_value = f8
 )
 RECORD org_cdm(
   1 org_arr[*]
     2 code_value = f8
 )
 RECORD itf_cdm(
   1 itf_arr[*]
     2 code_value = f8
 )
 RECORD flat_disc_cdm(
   1 flat_disc_arr[*]
     2 code_value = f8
 )
 RECORD diagreqd_cdm(
   1 diagreqd_arr[*]
     2 code_value = f8
 )
 RECORD physreqd_cdm(
   1 physreqd_arr[*]
     2 code_value = f8
 )
 RECORD instfinnbr_cdm(
   1 instfinnbr_arr[*]
     2 code_value = f8
 )
 SET reply->status_data.status = "F"
 IF ( NOT (validate(record_max_limit)))
  DECLARE record_max_limit = i4 WITH protect, constant(60000)
 ENDIF
 DECLARE totaltiermatrixrowcnt = i4 WITH protect, noconstant(0)
 DECLARE cellgrpcntidx = i4 WITH protect, noconstant(0)
 DECLARE cellgroupcnt = i4 WITH protect, noconstant(0)
 DECLARE celllistcnt = i4 WITH protect, noconstant(0)
 DECLARE g_priceadjfac_cd = f8
 SET stat = uar_get_meaning_by_codeset(13036,"PRICEADJFAC",1,g_priceadjfac_cd)
 CALL echo(build("PRICEADJFAC Cd: ",g_priceadjfac_cd))
 DECLARE iret = i4
 DECLARE g_price_sched_cd = f8
 DECLARE cdf_meaning = c12
 DECLARE code_set = i4
 DECLARE count1 = i4
 DECLARE count2 = i4
 DECLARE i = i4
 SET cdf_meaning = "PRICESCHED"
 SET code_set = 13036
 SET count1 = 1
 SET iret = uar_get_meaning_by_codeset(code_set,cdf_meaning,count1,g_price_sched_cd)
 IF (iret=0)
  SET stat = alterlist(price_sched_cdm->price_sched_arr,count1)
  SET price_sched_cdm->price_sched_arr[1].code_value = g_price_sched_cd
 ELSE
  CALL echo("Failure. g_price_sched_cd")
 ENDIF
 IF (count1 > 1)
  FOR (count2 = 2 TO count1)
    SET i = count2
    SET iret = uar_get_meaning_by_codeset(code_set,cdf_meaning,i,g_price_sched_cd)
    IF (iret=0)
     SET price_sched_cdm->price_sched_arr[count2].code_value = g_price_sched_cd
    ELSE
     CALL echo("Failure.")
    ENDIF
  ENDFOR
 ENDIF
 SET count1 = 0
 DECLARE iret = i4
 DECLARE g_org_cd = f8
 DECLARE cdf_meaning = c12
 DECLARE code_set = i4
 DECLARE count1 = i4
 DECLARE count2 = i4
 DECLARE i = i4
 SET cdf_meaning = "ORG"
 SET code_set = 13036
 SET count1 = 1
 SET iret = uar_get_meaning_by_codeset(code_set,cdf_meaning,count1,g_org_cd)
 IF (iret=0)
  SET stat = alterlist(org_cdm->org_arr,count1)
  SET org_cdm->org_arr[1].code_value = g_org_cd
 ELSE
  CALL echo("Failure. g_org_cd")
 ENDIF
 IF (count1 > 1)
  FOR (count2 = 2 TO count1)
    SET i = count2
    SET iret = uar_get_meaning_by_codeset(code_set,cdf_meaning,i,g_org_cd)
    IF (iret=0)
     SET org_cdm->org_arr[count2].code_value = g_org_cd
    ELSE
     CALL echo("Failure.")
    ENDIF
  ENDFOR
 ENDIF
 SET count1 = 0
 DECLARE iret = i4
 DECLARE g_interface_cd = f8
 DECLARE cdf_meaning = c12
 DECLARE code_set = i4
 DECLARE count1 = i4
 DECLARE count2 = i4
 DECLARE i = i4
 SET cdf_meaning = "INTERFACE"
 SET code_set = 13036
 SET count1 = 1
 SET iret = uar_get_meaning_by_codeset(code_set,cdf_meaning,count1,g_interface_cd)
 IF (iret=0)
  SET stat = alterlist(itf_cdm->itf_arr,count1)
  SET itf_cdm->itf_arr[1].code_value = g_interface_cd
 ELSE
  CALL echo("Falure.")
 ENDIF
 IF (count1 > 1)
  FOR (count2 = 2 TO count1)
    SET i = count2
    SET iret = uar_get_meaning_by_codeset(code_set,cdf_meaning,i,g_interface_cd)
    IF (iret=0)
     SET itf_cdm->itf_arr[count2].code_value = g_interface_cd
    ELSE
     CALL echo("Failure.")
    ENDIF
  ENDFOR
 ENDIF
 SET count1 = 0
 DECLARE iret = i4
 DECLARE g_flat_disc_cd = f8
 DECLARE cdf_meaning = c12
 DECLARE code_set = i4
 DECLARE count1 = i4
 DECLARE count2 = i4
 DECLARE i = i4
 SET cdf_meaning = "FLAT_DISC"
 SET code_set = 13036
 SET count1 = 1
 SET iret = uar_get_meaning_by_codeset(code_set,cdf_meaning,count1,g_flat_disc_cd)
 IF (iret=0)
  SET stat = alterlist(flat_disc_cdm->flat_disc_arr,count1)
  SET flat_disc_cdm->flat_disc_arr[1].code_value = g_flat_disc_cd
 ELSE
  CALL echo("Falure: FLAT_DISC_CD.")
 ENDIF
 IF (count1 > 1)
  FOR (count2 = 2 TO count1)
    SET i = count2
    SET iret = uar_get_meaning_by_codeset(code_set,cdf_meaning,i,g_flat_disc_cd)
    IF (iret=0)
     SET flat_disc_cdm->flat_disc_arr[count2].code_value = g_flat_disc_cd
    ELSE
     CALL echo("Failure. flat_disc")
    ENDIF
  ENDFOR
 ENDIF
 SET count1 = 0
 DECLARE iret = i4
 DECLARE g_diagreqd_cd = f8
 DECLARE cdf_meaning = c12
 DECLARE code_set = i4
 DECLARE count1 = i4
 DECLARE count2 = i4
 DECLARE i = i4
 SET cdf_meaning = "DIAGREQD"
 SET code_set = 13036
 SET count1 = 1
 SET iret = uar_get_meaning_by_codeset(code_set,cdf_meaning,count1,g_diagreqd_cd)
 IF (iret=0)
  SET stat = alterlist(diagreqd_cdm->diagreqd_arr,count1)
  SET diagreqd_cdm->diagreqd_arr[1].code_value = g_diagreqd_cd
 ELSE
  CALL echo("Falure.")
 ENDIF
 IF (count1 > 1)
  FOR (count2 = 2 TO count1)
    SET i = count2
    SET iret = uar_get_meaning_by_codeset(code_set,cdf_meaning,i,g_diagreqd_cd)
    IF (iret=0)
     SET diagreqd_cdm->diagreqd_arr[count2].code_value = g_diagreqd_cd
    ELSE
     CALL echo("Failure.")
    ENDIF
  ENDFOR
 ENDIF
 SET count1 = 0
 DECLARE iret = i4
 DECLARE g_physreqd_cd = f8
 DECLARE cdf_meaning = c12
 DECLARE code_set = i4
 DECLARE count1 = i4
 DECLARE count2 = i4
 DECLARE i = i4
 SET cdf_meaning = "PHYSREQD"
 SET code_set = 13036
 SET count1 = 1
 SET iret = uar_get_meaning_by_codeset(code_set,cdf_meaning,count1,g_physreqd_cd)
 IF (iret=0)
  SET stat = alterlist(physreqd_cdm->physreqd_arr,count1)
  SET physreqd_cdm->physreqd_arr[1].code_value = g_physreqd_cd
 ELSE
  CALL echo("Falure.")
 ENDIF
 IF (count1 > 1)
  FOR (count2 = 2 TO count1)
    SET i = count2
    SET iret = uar_get_meaning_by_codeset(code_set,cdf_meaning,i,g_physreqd_cd)
    IF (iret=0)
     SET physreqd_cdm->physreqd_arr[count2].code_value = g_physreqd_cd
    ELSE
     CALL echo("Failure.")
    ENDIF
  ENDFOR
 ENDIF
 SET count1 = 0
 DECLARE iret = i4
 DECLARE g_instfinnbr_cd = f8
 DECLARE cdf_meaning = c12
 DECLARE code_set = i4
 DECLARE count1 = i4
 DECLARE count2 = i4
 DECLARE i = i4
 SET cdf_meaning = "INSTFINNBR"
 SET code_set = 13036
 SET count1 = 1
 SET iret = uar_get_meaning_by_codeset(code_set,cdf_meaning,count1,g_instfinnbr_cd)
 IF (iret=0)
  SET stat = alterlist(instfinnbr_cdm->instfinnbr_arr,count1)
  SET instfinnbr_cdm->instfinnbr_arr[1].code_value = g_instfinnbr_cd
 ELSE
  CALL echo("Failure.")
 ENDIF
 IF (count1 > 1)
  FOR (count2 = 2 TO count1)
    SET i = count2
    SET iret = uar_get_meaning_by_codeset(code_set,cdf_meaning,i,g_instfinnbr_cd)
    IF (iret=0)
     SET org_cdm->instfinnbr_arr[count2].code_value = g_instfinnbr_cd
    ELSE
     CALL echo("Failure.")
    ENDIF
  ENDFOR
 ENDIF
 SET count1 = 0
 SET count1 = 0
 SET count2 = 0
 SET maxarray = 10
 SELECT INTO "nl:"
  totalcellcount = count(DISTINCT t.tier_cell_id)
  FROM tier_matrix t
  WHERE (t.tier_group_cd=request->tier_group_cd)
   AND t.active_ind=1
  DETAIL
   totaltiermatrixrowcnt = totalcellcount
  WITH nocounter
 ;end select
 IF (totaltiermatrixrowcnt < record_max_limit)
  SELECT INTO "nl:"
   FROM tier_matrix t
   WHERE (t.tier_group_cd=request->tier_group_cd)
    AND t.active_ind=1
   ORDER BY t.tier_group_cd, cnvtdatetime(t.beg_effective_dt_tm), cnvtdatetime(t.end_effective_dt_tm),
    t.tier_row_num, t.tier_col_num
   HEAD t.tier_group_cd
    count1 += 1, stat = alterlist(reply->group,count1), reply->group[count1].tier_group_code = t
    .tier_group_cd,
    reply->group[count1].tier_group_mean = uar_get_code_meaning(t.tier_group_cd), reply->group[count1
    ].tier_group_disp = uar_get_code_display(t.tier_group_cd),
    CALL echo("DESCRIPTION"),
    CALL echo(reply->group[count1].tier_group_disp), reply->group[count1].tier_group_desc =
    uar_get_code_description(t.tier_group_cd),
    CALL echo("TIER_GROUP_UPDT"),
    CALL echo(reply->group[count1].tier_group_updt), count2 = 0
   DETAIL
    IF (t.tier_cell_id > 0)
     count2 += 1, stat = alterlist(reply->group[count1].cell,count2), reply->group[count1].cell[
     count2].tier_cell_id = t.tier_cell_id,
     reply->group[count1].cell[count2].tier_col_num = t.tier_col_num, reply->group[count1].cell[
     count2].tier_row_num = t.tier_row_num, reply->group[count1].cell[count2].tier_cell_type_cd = t
     .tier_cell_type_cd,
     reply->group[count1].cell[count2].tier_cell_value =
     IF ((reply->group[count1].cell[count2].tier_cell_type_cd=g_price_sched_cd)) t.tier_cell_value_id
     ELSEIF ((reply->group[count1].cell[count2].tier_cell_type_cd=g_org_cd)) t.tier_cell_value_id
     ELSEIF ((reply->group[count1].cell[count2].tier_cell_type_cd=g_interface_cd)) t
      .tier_cell_value_id
     ELSEIF ((reply->group[count1].cell[count2].tier_cell_type_cd IN (g_flat_disc_cd,
     g_priceadjfac_cd))) t.tier_cell_value
     ELSEIF ((reply->group[count1].cell[count2].tier_cell_type_cd=g_diagreqd_cd)) t.tier_cell_value
     ELSEIF ((reply->group[count1].cell[count2].tier_cell_type_cd=g_physreqd_cd)) t.tier_cell_value
     ELSE t.tier_cell_value_id
     ENDIF
     , reply->group[count1].cell[count2].tier_cell_string = t.tier_cell_string, reply->group[count1].
     cell[count2].beg_effective_dt_tm = cnvtdatetimeutc(t.beg_effective_dt_tm,0),
     reply->group[count1].cell[count2].tier_cell_entity_name = t.tier_cell_entity_name
     IF ( NOT (t.end_effective_dt_tm BETWEEN cnvtdatetime("31-dec-2100 00:00:00.00") AND cnvtdatetime
     ("31-dec-2100 23:59:59.99")))
      reply->group[count1].cell[count2].end_effective_dt_tm = cnvtdatetimeutc(t.end_effective_dt_tm,0
       )
     ENDIF
     reply->group[count1].cell[count2].active_ind = t.active_ind
    ENDIF
    reply->group[count1].cell_qual = count2
   WITH nocounter
  ;end select
  IF (size(reply->group,5) > 0)
   SELECT INTO "nl:"
    FROM code_value cv,
     (dummyt d1  WITH seq = value(reply->group_qual))
    PLAN (d1)
     JOIN (cv
     WHERE (cv.code_value=reply->group[d1.seq].tier_group_code))
    DETAIL
     reply->group[d1.seq].tier_group_updt = cv.updt_cnt
    WITH nocounter
   ;end select
  ENDIF
  IF (size(reply->group[1].cell,5) > 0)
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(size(reply->group[1].cell,5))),
     prsnl p
    PLAN (d1
     WHERE (reply->group[1].cell[d1.seq].tier_cell_entity_name="PRSNL"))
     JOIN (p
     WHERE (p.person_id=reply->group[1].cell[d1.seq].tier_cell_value))
    DETAIL
     reply->group[1].cell[d1.seq].physician_name = p.name_full_formatted
    WITH nocounter
   ;end select
  ENDIF
  SET reply->group_qual = count1
 ELSE
  IF (validate(reply->ismaximumlimitexceeded))
   SET reply->ismaximumlimitexceeded = true
   SELECT INTO "nl:"
    FROM tier_matrix t
    WHERE (t.tier_group_cd=request->tier_group_cd)
     AND t.active_ind=1
    ORDER BY t.tier_group_cd, cnvtdatetime(t.beg_effective_dt_tm), cnvtdatetime(t.end_effective_dt_tm
      ),
     t.tier_row_num, t.tier_col_num
    HEAD t.tier_group_cd
     count1 += 1, stat = alterlist(reply->group,count1), cellgroupcnt = 1,
     stat = alterlist(reply->group[count1].cellgroup,cellgroupcnt), reply->group[count1].
     tier_group_code = t.tier_group_cd, reply->group[count1].tier_group_mean = uar_get_code_meaning(t
      .tier_group_cd),
     reply->group[count1].tier_group_disp = uar_get_code_display(t.tier_group_cd),
     CALL echo("DESCRIPTION"),
     CALL echo(reply->group[count1].tier_group_disp),
     reply->group[count1].tier_group_desc = uar_get_code_description(t.tier_group_cd),
     CALL echo("TIER_GROUP_UPDT"),
     CALL echo(reply->group[count1].tier_group_updt)
    DETAIL
     IF (t.tier_cell_id > 0)
      IF (celllistcnt >= record_max_limit)
       IF (size(reply->group[count1].cellgroup,5) > 0)
        reply->group[count1].cellgroup[cellgroupcnt].celllistcount = celllistcnt
       ENDIF
       cellgroupcnt += 1, stat = alterlist(reply->group[count1].cellgroup,cellgroupcnt), celllistcnt
        = 0
      ENDIF
      celllistcnt += 1
      IF (size(reply->group[count1].cellgroup,5) > 0)
       stat = alterlist(reply->group[count1].cellgroup[cellgroupcnt].celllist,celllistcnt), reply->
       group[count1].cellgroup[cellgroupcnt].celllist[celllistcnt].tier_cell_id = t.tier_cell_id,
       reply->group[count1].cellgroup[cellgroupcnt].celllist[celllistcnt].tier_col_num = t
       .tier_col_num,
       reply->group[count1].cellgroup[cellgroupcnt].celllist[celllistcnt].tier_row_num = t
       .tier_row_num, reply->group[count1].cellgroup[cellgroupcnt].celllist[celllistcnt].
       tier_cell_type_cd = t.tier_cell_type_cd, reply->group[count1].cellgroup[cellgroupcnt].
       celllist[celllistcnt].tier_cell_value =
       IF ((reply->group[count1].cellgroup[cellgroupcnt].celllist[celllistcnt].tier_cell_type_cd=
       g_price_sched_cd)) t.tier_cell_value_id
       ELSEIF ((reply->group[count1].cellgroup[cellgroupcnt].celllist[celllistcnt].tier_cell_type_cd=
       g_org_cd)) t.tier_cell_value_id
       ELSEIF ((reply->group[count1].cellgroup[cellgroupcnt].celllist[celllistcnt].tier_cell_type_cd=
       g_interface_cd)) t.tier_cell_value_id
       ELSEIF ((reply->group[count1].cellgroup[cellgroupcnt].celllist[celllistcnt].tier_cell_type_cd
        IN (g_flat_disc_cd, g_priceadjfac_cd))) t.tier_cell_value
       ELSEIF ((reply->group[count1].cellgroup[cellgroupcnt].celllist[celllistcnt].tier_cell_type_cd=
       g_diagreqd_cd)) t.tier_cell_value
       ELSEIF ((reply->group[count1].cellgroup[cellgroupcnt].celllist[celllistcnt].tier_cell_type_cd=
       g_physreqd_cd)) t.tier_cell_value
       ELSE t.tier_cell_value_id
       ENDIF
       ,
       reply->group[count1].cellgroup[cellgroupcnt].celllist[celllistcnt].tier_cell_string = t
       .tier_cell_string, reply->group[count1].cellgroup[cellgroupcnt].celllist[celllistcnt].
       beg_effective_dt_tm = cnvtdatetimeutc(t.beg_effective_dt_tm,0), reply->group[count1].
       cellgroup[cellgroupcnt].celllist[celllistcnt].tier_cell_entity_name = t.tier_cell_entity_name
       IF ( NOT (t.end_effective_dt_tm BETWEEN cnvtdatetime("31-dec-2100 00:00:00.00") AND
       cnvtdatetime("31-dec-2100 23:59:59.99")))
        reply->group[count1].cellgroup[cellgroupcnt].celllist[celllistcnt].end_effective_dt_tm =
        cnvtdatetimeutc(t.end_effective_dt_tm,0)
       ENDIF
       reply->group[count1].cellgroup[cellgroupcnt].celllist[celllistcnt].active_ind = t.active_ind
      ENDIF
      reply->group[count1].cellgroup[cellgroupcnt].celllistcount = celllistcnt
     ENDIF
    WITH nocounter
   ;end select
   IF (size(reply->group,5) > 0)
    SELECT INTO "nl:"
     FROM code_value cv,
      (dummyt d1  WITH seq = value(reply->group_qual))
     PLAN (d1)
      JOIN (cv
      WHERE (cv.code_value=reply->group[d1.seq].tier_group_code))
     DETAIL
      reply->group[d1.seq].tier_group_updt = cv.updt_cnt
     WITH nocounter
    ;end select
   ENDIF
   IF (cellgroupcnt > 0)
    SET reply->group[count1].cellgroupcount = cellgroupcnt
   ENDIF
   FOR (cellgrpcntidx = 1 TO reply->group[1].cellgroupcount)
     IF (size(reply->group[1].cellgroup[cellgrpcntidx].celllist,5) > 0)
      SELECT INTO "nl:"
       FROM (dummyt d1  WITH seq = value(size(reply->group[1].cellgroup[cellgrpcntidx].celllist,5))),
        prsnl p
       PLAN (d1
        WHERE (reply->group[1].cellgroup[cellgrpcntidx].celllist[d1.seq].tier_cell_entity_name=
        "PRSNL"))
        JOIN (p
        WHERE (p.person_id=reply->group[1].cellgroup[cellgrpcntidx].celllist[d1.seq].tier_cell_value)
        )
       DETAIL
        reply->group[1].cellgroup[cellgrpcntidx].celllist[d1.seq].physician_name = p
        .name_full_formatted
       WITH nocounter
      ;end select
     ENDIF
   ENDFOR
   SET reply->group_qual = count1
  ENDIF
 ENDIF
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "Select"
  SET reply->status_data.subeventstatus[1].operationstatus = "s"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "BILL_ITEM"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
