CREATE PROGRAM dcp_evaluate_witness_required
 SET modify = predeclare
 RECORD reply(
   1 witness_req_ind = f8
   1 flex_routes[*]
     2 route_cd = f8
     2 witness_req_ind = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD internal(
   1 group[*]
     2 synonym_id = f8
     2 facility_cd = f8
     2 group_id = f8
     2 obj_cnt = i2
     2 flex_nbr_value = f8
     2 flex_str_value_txt = vc
     2 data[*]
       3 group_id = f8
       3 flex_obj_type_cd = f8
       3 flex_obj_cd = f8
 )
 DECLARE last_mod = c3 WITH private, noconstant("")
 DECLARE mod_date = c10 WITH private, noconstant("")
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE errcode = i2 WITH protect, noconstant(0)
 DECLARE maxobjcnt = i4 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE age_cd = f8 WITH protect, noconstant(0.0)
 DECLARE returnage = f8 WITH protect, noconstant(0.0)
 DECLARE location = f8 WITH constant(uar_get_code_by("MEANING",4000047,"LOCATION"))
 DECLARE route = f8 WITH constant(uar_get_code_by("MEANING",4000047,"ROUTE"))
 DECLARE ivevent = f8 WITH constant(uar_get_code_by("MEANING",4000047,"IVEVENT"))
 DECLARE age = f8 WITH constant(uar_get_code_by("MEANING",4000047,"AGECODE"))
 DECLARE agecodeset = f8 WITH constant(4000048.00)
 DECLARE selectcombos(null) = null
 DECLARE evaluatedata(null) = null
 DECLARE getflexroutes(null) = null
 DECLARE calcage(null) = f8
 DECLARE getagecd(age=f8) = null
 DECLARE getocswitreqflag(null) = null
 SET reply->status_data.status = "F"
 SET returnage = calcage(null)
 IF (returnage > 0.0)
  CALL getagecd(returnage)
 ENDIF
 CALL selectcombos(null)
 CALL evaluatedata(null)
#exit_script
 IF ((reply->status_data.status="Z"))
  CALL getocswitreqflag(null)
 ENDIF
 FREE SET internal
 SET modify = nopredeclare
 SUBROUTINE selectcombos(null)
   DECLARE objcnt = i4 WITH protect, noconstant(0)
   DECLARE groupcnt = i4 WITH protect, noconstant(0)
   SELECT INTO "NL:"
    FROM ocs_attr_xcptn oax
    PLAN (oax
     WHERE (oax.synonym_id=request->synonym_id)
      AND (oax.facility_cd=request->facility_cd)
      AND (oax.ocs_col_name_cd=request->ocs_col_name_cd))
    ORDER BY oax.ocs_attr_xcptn_group_id
    HEAD REPORT
     groupcnt = 0
    HEAD oax.ocs_attr_xcptn_group_id
     groupcnt = (groupcnt+ 1), objcnt = 0, stat = alterlist(internal->group,groupcnt),
     internal->group[groupcnt].synonym_id = oax.synonym_id, internal->group[groupcnt].facility_cd =
     oax.facility_cd, internal->group[groupcnt].group_id = oax.ocs_attr_xcptn_group_id,
     internal->group[groupcnt].flex_nbr_value = oax.flex_nbr_value, internal->group[groupcnt].
     flex_str_value_txt = oax.flex_str_value_txt
    DETAIL
     objcnt = (objcnt+ 1)
     IF (objcnt > maxobjcnt)
      maxobjcnt = objcnt
     ENDIF
     stat = alterlist(internal->group[groupcnt].data,objcnt), internal->group[groupcnt].data[objcnt].
     group_id = oax.ocs_attr_xcptn_group_id, internal->group[groupcnt].data[objcnt].flex_obj_type_cd
      = oax.flex_obj_type_cd,
     internal->group[groupcnt].data[objcnt].flex_obj_cd = oax.flex_obj_cd, internal->group[groupcnt].
     flex_nbr_value = oax.flex_nbr_value, internal->group[groupcnt].flex_str_value_txt = oax
     .flex_str_value_txt
    FOOT  oax.ocs_attr_xcptn_group_id
     internal->group[groupcnt].obj_cnt = objcnt
    WITH nocounter
   ;end select
   SET errcode = error(errmsg,1)
   IF (errcode > 0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus.operationname = concat("SR - ",errmsg)
    GO TO exit_script
   ELSEIF (curqual=0)
    SET reply->status_data.status = "Z"
    SET reply->status_data.subeventstatus.operationname = "Zero Qual on OAX"
    GO TO exit_script
   ENDIF
   IF (validate(request->debug_ind))
    CALL echorecord(internal)
   ENDIF
 END ;Subroutine
 SUBROUTINE evaluatedata(null)
   DECLARE locchk = i2 WITH protect, noconstant(1)
   DECLARE routechk = i2 WITH protect, noconstant(1)
   DECLARE ivchk = i2 WITH protect, noconstant(1)
   DECLARE agechk = i2 WITH protect, noconstant(1)
   DECLARE iget = i2 WITH protect, noconstant(0)
   DECLARE flexroutecnt = i4 WITH protect, noconstant(0)
   DECLARE routecd = f8 WITH protect, noconstant(0.0)
   DECLARE chkrt = i4 WITH protect, noconstant(0)
   DECLARE x = i4 WITH protect, noconstant(0)
   DECLARE witreqflag = f8 WITH protect, noconstant(0.0)
   SELECT INTO "NL:"
    group_id = internal->group[d.seq].group_id, obj_type_cd = internal->group[d.seq].data[d1.seq].
    flex_obj_type_cd, object_cnt = internal->group[d.seq].obj_cnt
    FROM (dummyt d  WITH seq = value(size(internal->group,5))),
     (dummyt d1  WITH seq = value(maxobjcnt))
    PLAN (d)
     JOIN (d1
     WHERE d1.seq <= cnvtint(size(internal->group[d.seq].data,5))
      AND (internal->group[d.seq].data[d1.seq].group_id=internal->group[d.seq].group_id))
    ORDER BY object_cnt, group_id, obj_type_cd
    HEAD group_id
     routecd = 0.0, witreqflag = 0.0, locchk = 1,
     routechk = 1, ivchk = 1, agechk = 1
     IF (validate(request->debug_ind))
      CALL echo(build("************** group_id = ",group_id))
     ENDIF
     IF ((reply->status_data.status != "S"))
      reply->status_data.status = "Z", reply->status_data.subeventstatus.operationname =
      "Could Not Find a Match", reply->witness_req_ind = - (1)
     ENDIF
    HEAD obj_type_cd
     IF ((internal->group[d.seq].data[d1.seq].flex_obj_type_cd=location))
      IF ((request->location_cd > 0.0))
       locchk = locateval(iget,1,size(internal->group[d.seq].data,5),request->location_cd,internal->
        group[d.seq].data[d1.seq].flex_obj_cd)
       IF (validate(request->debug_ind))
        CALL echo(build("LocChk = ",locchk))
       ENDIF
      ELSE
       locchk = 0
      ENDIF
     ENDIF
     IF ((internal->group[d.seq].data[d1.seq].flex_obj_type_cd=route))
      IF ((request->route_cd > 0.0))
       routechk = locateval(iget,1,size(internal->group[d.seq].data,5),request->route_cd,internal->
        group[d.seq].data[d1.seq].flex_obj_cd)
       IF (validate(request->debug_ind))
        CALL echo(build("RouteChk = ",routechk))
       ENDIF
      ELSE
       routechk = 0
      ENDIF
      routecd = internal->group[d.seq].data[d1.seq].flex_obj_cd, witreqflag = internal->group[d.seq].
      flex_nbr_value
     ENDIF
     IF ((internal->group[d.seq].data[d1.seq].flex_obj_type_cd=ivevent))
      IF ((request->ivevent_cd > 0.0))
       ivchk = locateval(iget,1,size(internal->group[d.seq].data,5),request->ivevent_cd,internal->
        group[d.seq].data[d1.seq].flex_obj_cd)
       IF (validate(request->debug_ind))
        CALL echo(build("IVChk = ",ivchk))
       ENDIF
      ELSE
       ivchk = 0
      ENDIF
     ENDIF
     IF ((internal->group[d.seq].data[d1.seq].flex_obj_type_cd=age))
      IF (age_cd > 0.0)
       agechk = locateval(iget,1,size(internal->group[d.seq].data,5),age_cd,internal->group[d.seq].
        data[d1.seq].flex_obj_cd)
       IF (validate(request->debug_ind))
        CALL echo(build("AgeChk = ",agechk))
       ENDIF
      ELSE
       agechk = 0
      ENDIF
     ENDIF
    FOOT  group_id
     IF (locchk
      AND routechk
      AND ivchk
      AND agechk)
      IF (validate(request->debug_ind))
       CALL echo(build("*************************MATCH--->GroupId = ",group_id))
      ENDIF
      reply->status_data.status = "S", reply->status_data.subeventstatus.operationname =
      "Match Found", reply->witness_req_ind = internal->group[d.seq].flex_nbr_value
     ENDIF
     IF (locchk
      AND ivchk
      AND agechk
      AND routecd != 0.0)
      chkrt = locateval(x,1,size(reply->flex_routes,5),routecd,reply->flex_routes[x].route_cd)
      IF (chkrt=0)
       IF (validate(request->debug_ind))
        CALL echo(build("Flex Route = ",routecd)),
        CALL echo(build("witness_req_flag = ",witreqflag))
       ENDIF
       flexroutecnt = (flexroutecnt+ 1), stat = alterlist(reply->flex_routes,flexroutecnt), reply->
       flex_routes[flexroutecnt].route_cd = routecd,
       reply->flex_routes[flexroutecnt].witness_req_ind = witreqflag
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   SET errcode = error(errmsg,1)
   IF (errcode > 0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus.operationname = concat("EV - ",errmsg)
    GO TO exit_script
   ELSEIF (curqual=0)
    SET reply->status_data.status = "Z"
    SET reply->status_data.subeventstatus.operationname = "Zero qual in Eval"
    GO TO exit_script
   ELSEIF ((reply->status_data.status != "S"))
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE calcage(null)
   DECLARE age = f8 WITH protect, noconstant(0.0)
   SELECT INTO "NL:"
    FROM person p
    PLAN (p
     WHERE (p.person_id=request->patient_id))
    HEAD REPORT
     age = 0.0
    HEAD p.person_id
     age = datetimediff(cnvtdatetime(curdate,curtime3),p.birth_dt_tm,4)
    WITH nocounter
   ;end select
   SET errcode = error(errmsg,1)
   IF (errcode > 0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus.operationname = concat("CA - ",errmsg)
    GO TO exit_script
   ENDIF
   RETURN(age)
 END ;Subroutine
 SUBROUTINE getagecd(age)
   SELECT INTO "NL:"
    FROM code_value_extension cve
    PLAN (cve
     WHERE cve.code_set=agecodeset)
    ORDER BY cnvtreal(cve.field_value) DESC
    DETAIL
     IF (age <= cnvtreal(cve.field_value))
      age_cd = cve.code_value
     ENDIF
    WITH nocounter
   ;end select
   IF (validate(request->debug_ind))
    CALL echo(build("AgeCd = ",age_cd))
   ENDIF
   SET errcode = error(errmsg,1)
   IF (errcode > 0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus.operationname = concat("GAC - ",errmsg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE getocswitreqflag(null)
   SELECT INTO "NL:"
    FROM order_catalog_synonym ocs
    PLAN (ocs
     WHERE (ocs.synonym_id=request->synonym_id))
    DETAIL
     reply->witness_req_ind = ocs.witness_flag
    WITH nocounter
   ;end select
   IF (validate(request->debug_ind))
    CALL echo(build("ocs witness flag = ",reply->witness_req_ind))
   ENDIF
   SET errcode = error(errmsg,1)
   IF (errcode > 0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus.operationname = concat("GOWRF - ",errmsg)
    GO TO exit_script
   ENDIF
   IF (curqual > 0)
    SET reply->status_data.status = "S"
    SET reply->status_data.subeventstatus.operationname = "top level witness flag"
   ENDIF
 END ;Subroutine
 SET last_mod = "000"
 SET mod_date = "05/05/2006"
END GO
