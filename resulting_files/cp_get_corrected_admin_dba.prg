CREATE PROGRAM cp_get_corrected_admin:dba
 RECORD reply(
   1 qual[*]
     2 verified_dt_tm = dq8
     2 verified_tz = i4
     2 verified_prsnl = vc
     2 init_dosage = f8
     2 admin_dosage = f8
     2 dosage_unit = c40
     2 initial_volume = f8
     2 infusion_unit = c40
     2 infusion_rate = f8
     2 site = c40
     2 route = c40
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET errmsg = fillstring(132," ")
 SELECT INTO "nl:"
  FROM ce_med_result cmr,
   clinical_event ce,
   prsnl p
  PLAN (cmr
   WHERE (cmr.event_id=request->event_id)
    AND cmr.valid_from_dt_tm < cnvtdatetime(request->valid_from_dt_tm))
   JOIN (ce
   WHERE ce.event_id=cmr.event_id
    AND ce.valid_from_dt_tm=cmr.valid_from_dt_tm)
   JOIN (p
   WHERE p.person_id=outerjoin(ce.verified_prsnl_id)
    AND p.active_ind=outerjoin(1)
    AND p.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
  ORDER BY cmr.valid_until_dt_tm DESC
  HEAD REPORT
   correctcnt = 0
  DETAIL
   correctcnt = (correctcnt+ 1)
   IF (mod(correctcnt,5)=1)
    stat = alterlist(reply->qual,(correctcnt+ 4))
   ENDIF
   reply->qual[correctcnt].verified_dt_tm = ce.verified_dt_tm, reply->qual[correctcnt].verified_tz =
   validate(ce.verified_tz,0), reply->qual[correctcnt].verified_prsnl = p.name_full_formatted,
   reply->qual[correctcnt].admin_dosage = cmr.admin_dosage, reply->qual[correctcnt].dosage_unit =
   uar_get_code_display(cmr.dosage_unit_cd), reply->qual[correctcnt].initial_volume = cmr
   .initial_volume,
   reply->qual[correctcnt].infusion_unit = uar_get_code_display(cmr.infusion_unit_cd), reply->qual[
   correctcnt].infusion_rate = cmr.infusion_rate, reply->qual[correctcnt].site = uar_get_code_display
   (cmr.admin_site_cd),
   reply->qual[correctcnt].route = uar_get_code_display(cmr.admin_route_cd)
  FOOT REPORT
   stat = alterlist(reply->qual,correctcnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET errorcode = error(errmsg,0)
  IF (errorcode != 0)
   SET reply->status_data.status = "F"
   SET reply->status_data.operationname = "SELECT"
   SET reply->status_data.operationstatus = "F"
   SET reply->status_data.targetobjectname = "ErrorMessage"
   SET reply->status_data.targetobjectvalue = errmsg
  ELSE
   SET reply->status_data.status = "Z"
   SET reply->status_data.operationname = "SELECT"
   SET reply->status_data.operationstatus = "Z"
   SET reply->status_data.targetobjectname = "Qualifications"
   SET reply->status_data.targetobjectvalue = "No matching records"
  ENDIF
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
