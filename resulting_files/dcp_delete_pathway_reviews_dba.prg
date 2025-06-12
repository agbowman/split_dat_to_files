CREATE PROGRAM dcp_delete_pathway_reviews:dba
 SET modify = predeclare
 RECORD to_update(
   1 reviews[*]
     2 pathway_review_id = f8
 )
 DECLARE s_script_name = vc WITH protect, constant("dcp_delete_pathway_reviews")
 DECLARE l_review_count = i4 WITH protect, constant(value(size(request->reviews,5)))
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE lreviewcount = i4 WITH protect, noconstant(0)
 DECLARE lreviewsize = i4 WITH protect, noconstant(0)
 DECLARE lfailurecount = i4 WITH protect, noconstant(0)
 DECLARE lsubeventstatuscount = i4 WITH protect, noconstant(0)
 DECLARE lsubeventstatussize = i4 WITH protect, noconstant(value(size(reply->status_data.
    subeventstatus,5)))
 DECLARE last_mod = c3 WITH protect, noconstant(fillstring(3,"000"))
 DECLARE mod_date = c30 WITH protect, noconstant(fillstring(30," "))
 DECLARE set_script_status(cstatus=c1,soperationname=vc,coperationstatus=c1,stargetobjectname=vc,
  stargetobjectvalue=vc) = null
 SET reply->status_data.status = "S"
 IF (l_review_count < 1)
  CALL set_script_status("Z","BEGIN","Z",s_script_name,"The phase list was empty.")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  pr.pathway_review_id
  FROM pathway_review pr
  PLAN (pr
   WHERE expand(idx,1,l_review_count,pr.pathway_review_id,request->reviews[idx].pathway_review_id))
  ORDER BY pr.pathway_review_id
  HEAD REPORT
   idx = 0, lreviewcount = 0, lreviewsize = 0,
   lfailurecount = 0
  DETAIL
   idx = locateval(idx,1,l_review_count,pr.pathway_review_id,request->reviews[idx].pathway_review_id)
   IF (idx > 0)
    IF ((pr.updt_cnt != request->reviews[idx].updt_cnt))
     lfailurecount = (lfailurecount+ 1),
     CALL set_script_status("F","SELECT","F",s_script_name,concat("Pathway review (",
      "pathway_review_id = ",build(pr.pathway_review_id),",expected updt_cnt = ",build(request->
       review[idx].updt_cnt),
      ",actual updt_cnt = ",build(pr.updt_cnt),") has already been updated by another process"))
    ELSE
     lreviewcount = (lreviewcount+ 1)
     IF (lreviewsize < lreviewcount)
      lreviewsize = (lreviewsize+ 20), stat = alterlist(to_update->reviews,lreviewsize)
     ENDIF
     to_update->reviews[lreviewcount].pathway_review_id = request->reviews[idx].pathway_review_id
    ENDIF
   ENDIF
  FOOT REPORT
   IF (lreviewcount > 0)
    IF (lreviewcount < lreviewsize)
     stat = alterlist(to_update->reviews,lreviewcount)
    ENDIF
   ENDIF
  WITH forupdate(pr), nocounter, expand = 1
 ;end select
 IF (curqual <= 0)
  CALL set_script_status("F","SELECT","F",s_script_name,"Failed to lock rows on PATHWAY_REVIEW")
  GO TO exit_script
 ENDIF
 IF (lfailurecount > 0)
  CALL set_script_status("F","SELECT","F",s_script_name,"Select from PATHWAY_REVIEW failed")
  GO TO exit_script
 ENDIF
 IF (lreviewcount <= 0)
  CALL set_script_status("Z","SELECT","Z",s_script_name,"No data qualified from PATHWAY_REVIEW")
  GO TO exit_script
 ENDIF
 UPDATE  FROM (dummyt d  WITH seq = value(size(to_update->reviews,5))),
   pathway_review pr
  SET pr.active_ind = 0, pr.updt_dt_tm = cnvtdatetime(curdate,curtime3), pr.updt_id = reqinfo->
   updt_id,
   pr.updt_task = reqinfo->updt_task, pr.updt_cnt = (pr.updt_cnt+ 1), pr.updt_applctx = reqinfo->
   updt_applctx
  PLAN (d)
   JOIN (pr
   WHERE (pr.pathway_review_id=to_update->reviews[d.seq].pathway_review_id))
  WITH nocounter
 ;end update
 IF (curqual=0)
  CALL set_script_status("F","UPDATE","F",s_script_name,
   "Failed to update rows on the pathway_notification table.")
  GO TO exit_script
 ENDIF
 SUBROUTINE set_script_status(cstatus,soperationname,coperationstatus,stargetobjectname,
  stargetobjectvalue)
   IF ((reply->status_data.status="S"))
    SET reply->status_data.status = cstatus
   ELSEIF (cstatus="F")
    SET reply->status_data.status = cstatus
   ENDIF
   SET lsubeventstatuscount = (lsubeventstatuscount+ 1)
   IF (lsubeventstatuscount > lsubeventstatussize)
    SET lsubeventstatussize = (lsubeventstatussize+ 1)
    SET stat = alterlist(reply->status_data.subeventstatus,lsubeventstatussize)
   ENDIF
   SET reply->status_data.subeventstatus[lsubeventstatuscount].operationname = substring(1,25,trim(
     soperationname))
   SET reply->status_data.subeventstatus[lsubeventstatuscount].operationstatus = trim(
    coperationstatus)
   SET reply->status_data.subeventstatus[lsubeventstatuscount].targetobjectname = substring(1,25,trim
    (stargetobjectname))
   SET reply->status_data.subeventstatus[lsubeventstatuscount].targetobjectvalue = trim(
    stargetobjectvalue)
 END ;Subroutine
#exit_script
 DECLARE lerrorcode = i4 WITH protect, noconstant(0)
 DECLARE serrormessage = vc WITH protect, noconstant(" ")
 DECLARE lerrcnt = i4 WITH protect, noconstant(0)
 SET lerrorcode = error(serrormessage,0)
 WHILE (lerrorcode != 0
  AND lerrcnt <= 100)
   SET lerrcnt = (lerrcnt+ 1)
   CALL set_script_status("F","CCL ERROR","F",s_script_name,trim(serrormessage))
   SET lerrorcode = error(serrormessage,0)
 ENDWHILE
 SET last_mod = "001"
 SET mod_date = "May 03, 2011"
END GO
