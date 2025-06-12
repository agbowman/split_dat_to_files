CREATE PROGRAM dcp_get_priv_activities
 RECORD reply(
   1 activitylist[*]
     2 activityident = c25
     2 activityname = vc
     2 privlist[*]
       3 privilege_cd = f8
       3 activitydefid = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE stat = i4 WITH noconstant(0)
 DECLARE log_status(operationname=vc,operationstatus=vc,targetobjectname=vc,targetobjectvalue=vc) =
 null
 DECLARE log_count = i4 WITH noconstant(0)
 SUBROUTINE log_status(operationname,operationstatus,targetobjectname,targetobjectvalue)
   IF ( NOT (validate(reply,0)))
    RETURN
   ENDIF
   SET log_count = size(reply->status_data.subeventstatus,5)
   IF (log_count=1)
    IF (trim(reply->status_data.subeventstatus[1].targetobjectname) > "")
     SET log_count = (log_count+ 1)
    ENDIF
   ELSE
    SET log_count = (log_count+ 1)
   ENDIF
   SET stat = alter(reply->status_data.subeventstatus,log_count)
   SET reply->status_data.subeventstatus[log_count].operationname = operationname
   SET reply->status_data.subeventstatus[log_count].operationstatus = operationstatus
   SET reply->status_data.subeventstatus[log_count].targetobjectname = targetobjectname
   SET reply->status_data.subeventstatus[log_count].targetobjectvalue = targetobjectvalue
 END ;Subroutine
 SET reply->status_data.status = "F"
 DECLARE activitycnt = i4 WITH noconstant(0)
 DECLARE dcp_script_version = vc
 DECLARE dynamicplan = vc
 SET dynamicplan = build(dynamicplan," apd.active_ind = 1")
 IF ((request->searchtype=0))
  SET dynamicplan = build(dynamicplan,
   " and cnvtupper(apd.activity_name) = patstring(cnvtupper(request->searchStr))")
 ENDIF
 IF ((request->searchtype=1))
  SET dynamicplan = build(dynamicplan,
   " and cnvtupper(apd.activity_identifier) = patstring(cnvtupper(request->searchStr))")
 ENDIF
 SELECT INTO "nl:"
  FROM activity_privilege_definition apd
  PLAN (apd
   WHERE parser(dynamicplan))
  HEAD apd.activity_identifier
   activityprivcnt = 0, activitycnt = (activitycnt+ 1)
   IF (activitycnt > size(reply->activitylist,5))
    stat = alterlist(reply->activitylist,(activitycnt+ 9))
   ENDIF
   reply->activitylist[activitycnt].activityname = apd.activity_name, reply->activitylist[activitycnt
   ].activityident = apd.activity_identifier
  DETAIL
   activityprivcnt = (activityprivcnt+ 1)
   IF (activityprivcnt > size(reply->activitylist[activitycnt].privlist,5))
    stat = alterlist(reply->activitylist[activitycnt].privlist,(activityprivcnt+ 9))
   ENDIF
   reply->activitylist[activitycnt].privlist[activityprivcnt].privilege_cd = apd.privilege_cd, reply
   ->activitylist[activitycnt].privlist[activityprivcnt].activitydefid = apd
   .activity_privilege_def_id
  FOOT  apd.activity_identifier
   IF (activityprivcnt > 0)
    stat = alterlist(reply->activitylist[activitycnt].privlist,activityprivcnt)
   ENDIF
  WITH nocounter
 ;end select
 IF (activitycnt > 0)
  SET stat = alterlist(reply->activitylist,activitycnt)
  CALL exitscript("S")
 ELSE
  SET logmsg = "No Activities Found"
  CALL log_status("GET","S","PRIVILEGE",logmsg)
  CALL exitscript("S")
 ENDIF
 SUBROUTINE exitscript(scriptstatus)
  IF (scriptstatus="F")
   SET reply->status_data.status = "F"
  ELSEIF (scriptstatus="Z")
   SET reply->status_data.status = "Z"
  ELSEIF (scriptstatus="S")
   SET reply->status_data.status = "S"
  ENDIF
  GO TO endscript
 END ;Subroutine
#endscript
 SET dcp_script_version = "000 01/02/07 JD5581"
END GO
