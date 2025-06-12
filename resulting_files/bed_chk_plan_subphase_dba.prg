CREATE PROGRAM bed_chk_plan_subphase:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 power_plans[*]
      2 power_plan_id = f8
      2 display_description = vc
      2 version = i4
      2 active_ind = i2
      2 highest_powerplan_ver_id = f8
      2 beg_effective_dt_tm = dq8
      2 end_effective_dt_tm = dq8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE SET tempphases
 RECORD tempphases(
   1 phase[*]
     2 id = f8
 )
 DECLARE error_flag = vc
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET plancnt = 0
 SET totalplancnt = 0
 SET phasecnt = 0
 SET totalphasecnt = 0
 SELECT INTO "nl:"
  FROM pw_cat_reltn pcr,
   pathway_catalog pc
  PLAN (pcr
   WHERE (pcr.pw_cat_t_id=request->power_plan_id)
    AND pcr.type_mean="SUBPHASE")
   JOIN (pc
   WHERE pc.pathway_catalog_id=pcr.pw_cat_s_id
    AND pc.active_ind=1)
  ORDER BY pc.pathway_catalog_id
  HEAD REPORT
   stat = alterlist(reply->power_plans,10), stat = alterlist(tempphases->phase,10)
  HEAD pc.pathway_catalog_id
   IF (pc.type_mean="PHASE")
    phasecnt = (phasecnt+ 1), totalphasecnt = (totalphasecnt+ 1)
    IF (phasecnt > 10)
     stat = alterlist(tempphases->phase,(totalphasecnt+ 10)), phasecnt = 1
    ENDIF
    tempphases->phase[totalphasecnt].id = pc.pathway_catalog_id
   ELSEIF (((pc.type_mean="PATHWAY") OR (pc.type_mean="CAREPLAN")) )
    plancnt = (plancnt+ 1), totalplancnt = (totalplancnt+ 1)
    IF (plancnt > 10)
     stat = alterlist(reply->power_plans,(totalplancnt+ 10)), plancnt = 1
    ENDIF
    reply->power_plans[totalplancnt].active_ind = pc.active_ind, reply->power_plans[totalplancnt].
    beg_effective_dt_tm = pc.beg_effective_dt_tm, reply->power_plans[totalplancnt].
    display_description = pc.display_description,
    reply->power_plans[totalplancnt].end_effective_dt_tm = pc.end_effective_dt_tm, reply->
    power_plans[totalplancnt].highest_powerplan_ver_id = pc.version_pw_cat_id, reply->power_plans[
    totalplancnt].power_plan_id = pc.pathway_catalog_id,
    reply->power_plans[totalplancnt].version = pc.version
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->power_plans,totalplancnt), stat = alterlist(tempphases->phase,
    totalphasecnt)
  WITH nocounter
 ;end select
 IF (phasecnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = phasecnt),
    pw_cat_reltn pcr,
    pathway_catalog pc
   PLAN (d)
    JOIN (pcr
    WHERE (pcr.pw_cat_t_id=tempphases->phase[d.seq].id)
     AND pcr.type_mean="GROUP")
    JOIN (pc
    WHERE pc.pathway_catalog_id=pcr.pw_cat_s_id)
   ORDER BY pc.pathway_catalog_id
   HEAD REPORT
    stat = alterlist(reply->power_plans,(totalplancnt+ 10)), plancnt = 0
   HEAD pc.pathway_catalog_id
    plancnt = (plancnt+ 1), totalplancnt = (totalplancnt+ 1)
    IF (plancnt > 10)
     stat = alterlist(reply->power_plans,(totalplancnt+ 10)), plancnt = 1
    ENDIF
    reply->power_plans[totalplancnt].active_ind = pc.active_ind, reply->power_plans[totalplancnt].
    beg_effective_dt_tm = pc.beg_effective_dt_tm, reply->power_plans[totalplancnt].
    display_description = pc.display_description,
    reply->power_plans[totalplancnt].end_effective_dt_tm = pc.end_effective_dt_tm, reply->
    power_plans[totalplancnt].highest_powerplan_ver_id = pc.version_pw_cat_id, reply->power_plans[
    totalplancnt].power_plan_id = pc.pathway_catalog_id,
    reply->power_plans[totalplancnt].version = pc.version
   FOOT REPORT
    stat = alterlist(reply->power_plans,totalplancnt)
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
