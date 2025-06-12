CREATE PROGRAM bed_ens_office_orgs:dba
 IF (validate(last_mod,"NO_MOD")="NO_MOD")
  DECLARE last_mod = c6 WITH noconstant(" "), private
 ENDIF
 SET last_mod = "444219"
 FREE RECORD reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH persistscript
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 DECLARE bstatus = i2 WITH noconstant(false)
 DECLARE lcnt = i4 WITH noconstant(0)
 DECLARE ltotal = i4 WITH noconstant(0)
 DECLARE lreqcnt = i4 WITH noconstant(0)
 DECLARE lreqtotal = i4 WITH noconstant(0)
 DECLARE lindex = i4 WITH noconstant(0)
 DECLARE doprid = f8 WITH noconstant(0.0)
 DECLARE dreltncd = f8 WITH noconstant(0.0)
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 IF ((validate(bdebugme,- (9))=- (9)))
  DECLARE bdebugme = i2 WITH noconstant(false)
 ENDIF
 SET stat = uar_get_meaning_by_codeset(370,"INSOFFICE",1,dreltncd)
 IF (dreltncd <= 0.0)
  CALL echo("*** Unable to load 'INSOFFICE' code value from code set 370, exiting script.")
  SET reply->status_data.operationname = "CHECK BUILD"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "BUILD"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "BED_ENS_OFFICE_ORGS - Unable to load 'INSOFFICE' code value from code set 370"
  GO TO 9999_exit_program
 ENDIF
 IF ((request->health_plan_id <= 0.0))
  CALL echo("*** Request health_plan_id is invalid, exiting script.")
  SET reply->status_data.operationname = "CHECK REQUEST"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "REQUEST"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "BED_ENS_OFFICE_ORGS - REQUEST HEALTH_PLAN_ID IS INVALID"
  GO TO 9999_exit_program
 ENDIF
 IF (bdebugme)
  CALL echorecord(reply)
 ENDIF
 DECLARE add_reltn(officeorgid=f8) = i2
 DECLARE rmv_reltn(officeorgid=f8) = i2
 FREE RECORD currentreltns
 RECORD currentreltns(
   1 list[*]
     2 office_org_id = f8
     2 found_match = i2
 )
 SELECT INTO "nl:"
  opr.health_plan_id
  FROM org_plan_reltn opr
  WHERE (opr.health_plan_id=request->health_plan_id)
   AND opr.org_plan_reltn_cd=dreltncd
   AND opr.active_ind=1
   AND opr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
  DETAIL
   lcnt = (lcnt+ 1), stat = alterlist(currentreltns->list,lcnt), currentreltns->list[lcnt].
   office_org_id = opr.organization_id
  WITH nocounter
 ;end select
 SET ltotal = lcnt
 SET lreqtotal = size(request->office_orgs,5)
 IF (ltotal=0)
  IF (bdebugme)
   CALL echo("*** No existing rows qualified.")
  ENDIF
  IF (lreqtotal=0)
   CALL echo("*** No office orgs passed in request, exiting script.")
   SET reply->status_data.status = "S"
   GO TO 9999_exit_program
  ENDIF
  FOR (lreqcnt = 1 TO lreqtotal)
   SET bstatus = add_reltn(request->office_orgs[lreqcnt].office_org_id)
   IF (bstatus != true)
    SET reply->status_data.status = "F"
    GO TO 9999_exit_program
   ENDIF
  ENDFOR
 ELSE
  IF (bdebugme)
   CALL echo("*** Current relationships:")
   CALL echorecord(currentreltns)
  ENDIF
  FOR (lreqcnt = 1 TO lreqtotal)
   SET lindex = locateval(lcnt,1,ltotal,request->office_orgs[lreqcnt].office_org_id,currentreltns->
    list[lcnt].office_org_id)
   IF (lindex > 0)
    IF (bdebugme)
     CALL echo(build2("*** Found match on ",build(currentreltns->list[lindex].office_org_id)))
    ENDIF
    SET currentreltns->list[lindex].found_match = true
   ELSE
    SET bstatus = add_reltn(request->office_orgs[lreqcnt].office_org_id)
    IF (bstatus != true)
     SET reply->status_data.status = "F"
     GO TO 9999_exit_program
    ENDIF
   ENDIF
  ENDFOR
  IF (bdebugme)
   CALL echo("*** After match logic:")
   CALL echorecord(currentreltns)
  ENDIF
  FOR (lcnt = 1 TO ltotal)
    IF ((currentreltns->list[lcnt].found_match != true))
     SET bstatus = rmv_reltn(currentreltns->list[lcnt].office_org_id)
     IF (bstatus != true)
      SET reply->status_data.status = "F"
      GO TO 9999_exit_program
     ENDIF
    ENDIF
  ENDFOR
 ENDIF
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
 GO TO 9999_exit_program
 SUBROUTINE add_reltn(officeorgid)
   IF (bdebugme)
    CALL echo(build2("*** Start add_reltn() for ",build(officeorgid)))
   ENDIF
   IF (officeorgid <= 0.0)
    CALL echo("*** add_reltn() officeOrgId is invalid, exiting script")
    SET reply->status_data.operationname = "CHECK PARAM"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "REQUEST"
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "BED_ENS_OFFICE_ORGS - ADD_RELTN() OFFICE_ORG_ID IS INVALID"
    RETURN(false)
   ENDIF
   SET doprid = 0.0
   SELECT INTO "nl:"
    y = seq(organization_seq,nextval)
    FROM dual
    DETAIL
     doprid = cnvtreal(y)
    WITH format, counter
   ;end select
   IF (((curqual=0) OR (doprid=0.0)) )
    CALL echo("*** Generating new org_plan_reltn_id failed")
    SET reply->status_data.operationname = "GEN SEQ"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "SEQ"
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "BED_ENS_OFFICE_ORGS - ADD_RELTN() UNABLE TO GENERATE NEW ORG_PLAN_RELTN_ID"
    RETURN(false)
   ENDIF
   SET ierrcode = 0
   INSERT  FROM org_plan_reltn opr
    SET opr.org_plan_reltn_id = doprid, opr.health_plan_id = request->health_plan_id, opr
     .organization_id = officeorgid,
     opr.org_plan_reltn_cd = dreltncd, opr.data_status_cd = reqdata->auth_auth_cd, opr
     .data_status_dt_tm = cnvtdatetime(curdate,curtime3),
     opr.data_status_prsnl_id = reqinfo->updt_id, opr.beg_effective_dt_tm = cnvtdatetime(curdate,
      curtime3), opr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"),
     opr.active_ind = 1, opr.active_status_cd = reqdata->active_status_cd, opr.active_status_prsnl_id
      = reqinfo->updt_id,
     opr.active_status_dt_tm = cnvtdatetime(curdate,curtime3), opr.updt_dt_tm = cnvtdatetime(curdate,
      curtime3), opr.updt_applctx = reqinfo->updt_applctx,
     opr.updt_cnt = 0, opr.updt_id = reqinfo->updt_id, opr.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    CALL echo("*** rmv_reltn() unable to insert new org_plan_reltn row, exiting script.")
    SET reply->status_data.operationname = "INSERT"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "INSERT"
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "BED_ENS_OFFICE_ORGS - ADD_RELTN() UNABLE TO INSERT NEW ORG_PLAN_RELTN ROW"
    RETURN(false)
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE rmv_reltn(officeorgid)
   IF (bdebugme)
    CALL echo(build2("*** Start rmv_reltn() for ",build(officeorgid)))
   ENDIF
   IF (officeorgid <= 0.0)
    CALL echo("*** rmv_reltn() officeOrgId is invalid, exiting script")
    SET reply->status_data.operationname = "CHECK PARAM"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "REQUEST"
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "BED_ENS_OFFICE_ORGS - RMV_RELTN() OFFICE_ORG_ID IS INVALID"
    RETURN(false)
   ENDIF
   SET doprid = 0.0
   SELECT INTO "nl:"
    opr.org_plan_reltn_id
    FROM org_plan_reltn opr
    WHERE (opr.health_plan_id=request->health_plan_id)
     AND opr.organization_id=officeorgid
     AND opr.org_plan_reltn_cd=dreltncd
     AND opr.active_ind=1
    DETAIL
     doprid = opr.org_plan_reltn_id
    WITH forupdatewait(opr)
   ;end select
   IF (((curqual=0) OR (doprid <= 0.0)) )
    CALL echo("*** rmv_reltn() unable to lock org_plan_reltn row, exiting script.")
    SET reply->status_data.operationname = "LOCK"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "LOCK"
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "BED_ENS_OFFICE_ORGS - RMV_RELTN() UNABLE TO LOCK ORG_PLAN_RELTN ROW FOR UPDATE"
    RETURN(false)
   ENDIF
   SET ierrcode = 0
   UPDATE  FROM org_plan_reltn opr
    SET opr.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), opr.active_ind = 0, opr
     .active_status_cd = reqdata->inactive_status_cd,
     opr.active_status_prsnl_id = reqinfo->updt_id, opr.active_status_dt_tm = cnvtdatetime(curdate,
      curtime3), opr.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     opr.updt_applctx = reqinfo->updt_applctx, opr.updt_cnt = (opr.updt_cnt+ 1), opr.updt_id =
     reqinfo->updt_id,
     opr.updt_task = reqinfo->updt_task
    WHERE opr.org_plan_reltn_id=doprid
    WITH nocounter
   ;end update
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    CALL echo("*** rmv_reltn() unable to update org_plan_reltn row, exiting script.")
    SET reply->status_data.operationname = "UPDATE"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "UPDATE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "BED_ENS_OFFICE_ORGS - ADD_RELTN() UNABLE TO UPDATE ORG_PLAN_RELTN ROW"
    RETURN(false)
   ENDIF
   RETURN(true)
 END ;Subroutine
#9999_exit_program
 FREE RECORD currentreltns
END GO
