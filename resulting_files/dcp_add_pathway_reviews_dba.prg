CREATE PROGRAM dcp_add_pathway_reviews:dba
 SET modify = predeclare
 DECLARE s_script_name = vc WITH protect, constant("dcp_add_pathway_reviews")
 DECLARE l_review_count = i4 WITH protect, constant(value(size(request->reviews,5)))
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE isubeventstatuscount = i4 WITH protect, noconstant(0)
 DECLARE isubeventstatussize = i4 WITH protect, noconstant(value(size(reply->status_data.
    subeventstatus,5)))
 DECLARE last_mod = c3 WITH protect, noconstant(fillstring(3,"000"))
 DECLARE mod_date = c30 WITH protect, noconstant(fillstring(30," "))
 DECLARE set_script_status(cstatus=c1,soperationname=vc,coperationstatus=c1,stargetobjectname=vc,
  stargetobjectvalue=vc) = null
 SET reply->status_data.status = "S"
 IF (l_review_count < 1)
  CALL set_script_status("Z","BEGIN","Z",s_script_name,"The review list was empty.")
  GO TO exit_script
 ENDIF
 INSERT  FROM (dummyt d  WITH seq = value(l_review_count)),
   pathway_review pr
  SET pr.active_ind = 1, pr.pathway_id = request->reviews[d.seq].pathway_id, pr.pathway_review_id =
   seq(carenet_seq,nextval),
   pr.pw_action_seq = request->reviews[d.seq].pw_action_seq, pr.review_status_flag = request->
   reviews[d.seq].review_status_flag, pr.review_type_flag = request->reviews[d.seq].review_type_flag,
   pr.updt_dt_tm = cnvtdatetime(curdate,curtime3), pr.updt_id = reqinfo->updt_id, pr.updt_task =
   reqinfo->updt_task,
   pr.updt_cnt = 0, pr.updt_applctx = reqinfo->updt_applctx
  PLAN (d)
   JOIN (pr)
  WITH nocounter
 ;end insert
 IF (curqual=0)
  CALL set_script_status("F","INSERT","F",s_script_name,
   "Failed to insert rows into the pathway_review table.")
  GO TO exit_script
 ENDIF
 SUBROUTINE set_script_status(cstatus,soperationname,coperationstatus,stargetobjectname,
  stargetobjectvalue)
   IF ((reply->status_data.status="S"))
    SET reply->status_data.status = cstatus
   ELSEIF (cstatus="F")
    SET reply->status_data.status = cstatus
   ENDIF
   SET isubeventstatuscount = (isubeventstatuscount+ 1)
   IF (isubeventstatuscount > isubeventstatussize)
    SET isubeventstatussize = (isubeventstatussize+ 1)
    SET stat = alterlist(reply->status_data.subeventstatus,isubeventstatussize)
   ENDIF
   SET reply->status_data.subeventstatus[isubeventstatuscount].operationname = substring(1,25,trim(
     soperationname))
   SET reply->status_data.subeventstatus[isubeventstatuscount].operationstatus = trim(
    coperationstatus)
   SET reply->status_data.subeventstatus[isubeventstatuscount].targetobjectname = substring(1,25,trim
    (stargetobjectname))
   SET reply->status_data.subeventstatus[isubeventstatuscount].targetobjectvalue = trim(
    stargetobjectvalue)
 END ;Subroutine
#exit_script
 DECLARE lerrorcode = i4 WITH protect, noconstant(0)
 DECLARE lerrorcount = i4 WITH protect, noconstant(0)
 DECLARE serrormessage = vc WITH protect, noconstant(" ")
 SET lerrorcode = error(serrormessage,0)
 WHILE (lerrorcode != 0
  AND lerrorcount <= 50)
   SET lerrorcount = (lerrorcount+ 1)
   CALL set_script_status("F","CCL ERROR","F",s_script_name,trim(serrormessage))
   SET lerrorcode = error(serrormessage,0)
 ENDWHILE
 SET last_mod = "000"
 SET mod_date = "March 18, 2013"
END GO
