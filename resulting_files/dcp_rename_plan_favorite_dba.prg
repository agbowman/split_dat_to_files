CREATE PROGRAM dcp_rename_plan_favorite:dba
 SET modify = predeclare
 DECLARE hrequest = i4 WITH protect, noconstant(0)
 DECLARE hreply = i4 WITH protect, noconstant(0)
 DECLARE hmsg = i4 WITH protect, noconstant(0)
 DECLARE hitem = i4 WITH protect, noconstant(0)
 DECLARE hitemstatus = i4 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE ppr_reply_status = c1 WITH protect, noconstant("")
 DECLARE ppr_emsg = vc WITH protect, noconstant("")
 IF ((validate(request->owner_id,- (1234))=- (1234)))
  FREE RECORD request
  RECORD request(
    1 owner_id = f8
    1 name = vc
    1 pathway_customized_plan_id = f8
  )
  SET request->owner_id =  $1
  SET request->name =  $2
  SET request->pathway_customized_plan_id =  $3
 ENDIF
 IF (validate(reply->status_data.status,"-99")="-99")
  FREE RECORD reply
  RECORD reply(
    1 message = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 EXECUTE srvrtl
 SET hmsg = uar_srvselectmessage(601471)
 IF (hmsg=0)
  SET reply->status_data.status = "F"
  SET reply->message = "Failed to select message for request 601471"
  CALL echo("*** Failed to select message for request 601471")
  GO TO exit_program
 ENDIF
 SET hrequest = uar_srvcreaterequest(hmsg)
 IF (hrequest=0)
  SET reply->status_data.status = "F"
  SET reply->message = build("Failed to create request for handle: ",hmsg)
  CALL echo(build("*** Failed to create request for handle: ",hmsg))
  GO TO exit_program
 ENDIF
 SET hreply = uar_srvcreatereply(hmsg)
 IF (hreply=0)
  SET reply->status_data.status = "F"
  SET reply->message = build("Failed to create reply for handle: ",hmsg)
  CALL echo(build("*** Failed to create reply for handle: ",hmsg))
  GO TO exit_program
 ENDIF
 SET hitem = uar_srvgetstruct(hrequest,"criteria")
 SET stat = uar_srvsetdouble(hitem,"owner_id",request->owner_id)
 SET stat = uar_srvsetstring(hitem,"name",nullterm(request->name))
 SET stat = uar_srvexecute(hmsg,hrequest,hreply)
 SET hitemstatus = uar_srvgetstruct(hreply,"status_data")
 SET ppr_reply_status = uar_srvgetstringptr(hitemstatus,"status")
 IF (ppr_reply_status="S")
  SET reply->status_data.status = "F"
  SET reply->message = concat("Plan name: ",request->name," already exists")
  CALL echo(concat("*** Plan name: ",request->name))
  CALL echo(build("***  already exists for prsnl_id: ",request->owner_id))
 ELSEIF (ppr_reply_status="Z")
  UPDATE  FROM pathway_customized_plan p
   SET p.plan_name = request->name, p.plan_name_key = cnvtupper(request->name), p.updt_id = reqinfo->
    updt_id,
    p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->updt_applctx, p.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    p.updt_cnt = (p.updt_cnt+ 1)
   WHERE (p.pathway_customized_plan_id=request->pathway_customized_plan_id)
   WITH nocounter
  ;end update
  IF (error(ppr_emsg,1) != 0)
   SET reply->status_data.status = "F"
   SET reply->message = concat("Update failed with error: ",ppr_emsg)
   CALL echo(concat("*** Update failed with error: ",ppr_emsg))
  ENDIF
  IF (curqual)
   SET reply->status_data.status = "S"
   SET reply->message = "Rename successful"
   CALL echo("*** Rename successful")
   CALL echo(concat("***  new plan name: ",request->name))
   CALL echo(build("***  prsnl_id: ",request->owner_id))
  ELSE
   SET reply->status_data.status = "F"
   SET reply->message = "Update failed to qualify any rows"
   CALL echo(build("*** Update failed to qualify any rows on pathway_customized_plan_id: ",request->
     pathway_customized_plan_id))
  ENDIF
 ELSE
  SET reply->status_data.status = "F"
  SET reply->message = "Fail status return from request call 601471"
  CALL echo("*** Fail status return from request call 601471")
 ENDIF
#exit_program
 SET stat = uar_srvdestroyinstance(hmsg)
 IF (hrequest)
  SET stat = uar_srvdestroyinstance(hrequest)
 ENDIF
 IF (hreply)
  SET stat = uar_srvdestroyinstance(hreply)
 ENDIF
 SET modify = nopredeclare
 IF ((reply->status_data.status != "F"))
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echo(concat("*** Status: ",reply->status_data.status))
END GO
