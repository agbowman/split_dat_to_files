CREATE PROGRAM dcp_get_pathway_reviews:dba
 SET modify = predeclare
 DECLARE s_script_name = vc WITH protect, constant("dcp_get_pathway_reviews")
 DECLARE l_phase_count = i4 WITH protect, constant(value(size(request->phases,5)))
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE lreviewcount = i4 WITH protect, noconstant(0)
 DECLARE lreviewsize = i4 WITH protect, noconstant(0)
 DECLARE lsubeventstatuscount = i4 WITH protect, noconstant(0)
 DECLARE lsubeventstatussize = i4 WITH protect, noconstant(value(size(reply->status_data.
    subeventstatus,5)))
 DECLARE last_mod = c3 WITH protect, noconstant(fillstring(3,"000"))
 DECLARE mod_date = c30 WITH protect, noconstant(fillstring(30," "))
 DECLARE set_script_status(cstatus=c1,soperationname=vc,coperationstatus=c1,stargetobjectname=vc,
  stargetobjectvalue=vc) = null
 SET reply->status_data.status = "S"
 IF (l_phase_count < 1)
  CALL set_script_status("Z","BEGIN","Z",s_script_name,"The phase list was empty.")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  pr.pathway_id
  FROM pathway_review pr
  PLAN (pr
   WHERE expand(idx,1,l_phase_count,pr.pathway_id,request->phases[idx].phase_id))
  ORDER BY pr.pathway_id
  HEAD REPORT
   idx = 0, lreviewcount = 0, lreviewsize = 0
  DETAIL
   IF (pr.active_ind=1)
    lreviewcount = (lreviewcount+ 1)
    IF (lreviewsize < lreviewcount)
     lreviewsize = (lreviewsize+ 20), stat = alterlist(reply->reviews,lreviewsize)
    ENDIF
    reply->reviews[lreviewcount].pathway_review_id = pr.pathway_review_id, reply->reviews[
    lreviewcount].phase_id = pr.pathway_id, reply->reviews[lreviewcount].pw_action_seq = pr
    .pw_action_seq,
    reply->reviews[lreviewcount].review_status_flag = pr.review_status_flag, reply->reviews[
    lreviewcount].review_type_flag = pr.review_type_flag, reply->reviews[lreviewcount].updt_cnt = pr
    .updt_cnt
   ENDIF
  FOOT REPORT
   IF (lreviewcount > 0)
    IF (lreviewcount < lreviewsize)
     stat = alterlist(reply->reviews,lreviewcount)
    ENDIF
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 IF (lreviewcount <= 0)
  CALL set_script_status("S","SELECT","S",s_script_name,"No data qualified from PATHWAY_REVIEW")
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
 SET mod_date = "July 20, 2011"
END GO
