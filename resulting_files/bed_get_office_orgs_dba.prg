CREATE PROGRAM bed_get_office_orgs:dba
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
   1 health_plans[*]
     2 health_plan_id = f8
     2 office_orgs[*]
       3 org_id = f8
       3 org_name = vc
 ) WITH persistscript
 SET reply->status_data.status = "F"
 DECLARE ltemp = i4 WITH noconstant(0)
 DECLARE lcnt = i4 WITH noconstant(0)
 DECLARE lorgcnt = i4 WITH noconstant(0)
 DECLARE lreqsize = i4 WITH noconstant(0)
 DECLARE lindex = i4 WITH noconstant(0)
 DECLARE dreltncd = f8 WITH noconstant(0.0)
 IF ((validate(bdebugme,- (9))=- (9)))
  DECLARE bdebugme = i2 WITH noconstant(false)
 ENDIF
 SET stat = uar_get_meaning_by_codeset(370,"INSOFFICE",1,dreltncd)
 IF (dreltncd <= 0.0)
  CALL echo("*** Unable to load 'INSOFFICE' code value from code set 370, exiting script")
  SET reply->status_data.operationname = "CHECK BUILD"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "BUILD"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "BED_GET_OFFICE_ORGS - Unable to load 'INSOFFICE' code value from code set 370"
  GO TO 9999_exit_program
 ENDIF
 SET lreqsize = size(request->health_plans,5)
 IF (lreqsize=0)
  CALL echo("*** Request is empty, exiting script")
  SET reply->status_data.operationname = "CHECK REQUEST"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "REQUEST"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "BED_GET_OFFICE_ORGS - REQUEST IS EMPTY"
  GO TO 9999_exit_program
 ENDIF
 IF (bdebugme)
  CALL echorecord(reply)
 ENDIF
 SELECT INTO "nl:"
  o.org_id
  FROM org_plan_reltn opr,
   organization o
  PLAN (opr
   WHERE expand(ltemp,1,lreqsize,opr.health_plan_id,request->health_plans[ltemp].health_plan_id)
    AND opr.org_plan_reltn_cd=dreltncd
    AND opr.active_ind=1
    AND opr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND opr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (o
   WHERE o.organization_id=opr.organization_id
    AND o.active_ind=1)
  ORDER BY opr.health_plan_id, o.org_name
  HEAD opr.health_plan_id
   lcnt = (size(reply->health_plans,5)+ 1), stat = alterlist(reply->health_plans,lcnt), reply->
   health_plans[lcnt].health_plan_id = opr.health_plan_id
  DETAIL
   lorgcnt = (size(reply->health_plans[lcnt].office_orgs,5)+ 1), stat = alterlist(reply->
    health_plans[lcnt].office_orgs,lorgcnt), reply->health_plans[lcnt].office_orgs[lorgcnt].org_id =
   o.organization_id,
   reply->health_plans[lcnt].office_orgs[lorgcnt].org_name = o.org_name
  WITH nocounter
 ;end select
 IF (lcnt=0)
  IF (bdebugme)
   CALL echo("*** No rows qualified, exiting script")
  ENDIF
  SET reply->status_data.status = "Z"
  GO TO 9999_exit_program
 ENDIF
 IF (bdebugme)
  CALL echorecord(reply)
 ENDIF
 SET reply->status_data.status = "S"
#9999_exit_program
END GO
