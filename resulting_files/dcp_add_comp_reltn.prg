CREATE PROGRAM dcp_add_comp_reltn
 SET modify = predeclare
 DECLARE comp_reltn_count = i2 WITH constant(value(size(request->compreltnlist,5)))
 DECLARE end_date_string = c20 WITH constant("31-DEC-2100 00:00:00")
 DECLARE active_cd = f8 WITH constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE cfailed = c1 WITH noconstant("F")
 DECLARE idx = i2 WITH noconstant(0)
 DECLARE isubeventstatuscount = i4 WITH protect, noconstant(0)
 DECLARE isubeventstatussize = i4 WITH protect, noconstant(value(size(reply->status_data.
    subeventstatus,5)))
 DECLARE last_mod = c3 WITH protect, noconstant(fillstring(3,"000"))
 DECLARE mod_date = c30 WITH protect, noconstant(fillstring(30," "))
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errcnt = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant(" ")
 DECLARE report_failure(opname=vc,opstatus=c1,targetname=vc,targetvalue=vc) = null
 IF (comp_reltn_count > 0)
  SET idx = locateval(idx,1,comp_reltn_count,"REMOVE",request->compreltnlist[idx].action_mean)
  IF (idx > 0)
   SELECT INTO "nl:"
    apcr.*
    FROM (dummyt d  WITH seq = value(comp_reltn_count)),
     act_pw_comp_r apcr
    PLAN (d
     WHERE cnvtupper(request->compreltnlist[d.seq].action_mean)="REMOVE")
     JOIN (apcr
     WHERE (apcr.act_pw_comp_s_id=request->compreltnlist[d.seq].act_pw_comp_s_id)
      AND (apcr.act_pw_comp_t_id=request->compreltnlist[d.seq].act_pw_comp_t_id)
      AND (apcr.type_mean=request->compreltnlist[d.seq].type_mean)
      AND (apcr.pathway_id=request->compreltnlist[d.seq].pathway_id)
      AND apcr.active_ind=1)
    WITH forupdatewait(apcr), nocounter
   ;end select
   IF (curqual=0)
    CALL report_failure("UPDATE","F","DCP_ADD_COMP_RELTN",
     "Failed to lock rows on ACT_PW_COMP_R table")
    GO TO exit_script
   ENDIF
   UPDATE  FROM act_pw_comp_r apcr,
     (dummyt d  WITH seq = value(comp_reltn_count))
    SET apcr.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), apcr.active_ind = 0, apcr
     .updt_dt_tm = cnvtdatetime(curdate,curtime3),
     apcr.updt_id = reqinfo->updt_id, apcr.updt_task = reqinfo->updt_task, apcr.updt_cnt = 0,
     apcr.updt_applctx = reqinfo->updt_applctx
    PLAN (d
     WHERE cnvtupper(request->compreltnlist[d.seq].action_mean)="REMOVE")
     JOIN (apcr
     WHERE (apcr.act_pw_comp_s_id=request->compreltnlist[d.seq].act_pw_comp_s_id)
      AND (apcr.act_pw_comp_t_id=request->compreltnlist[d.seq].act_pw_comp_t_id)
      AND (apcr.type_mean=request->compreltnlist[d.seq].type_mean)
      AND (apcr.pathway_id=request->compreltnlist[d.seq].pathway_id)
      AND apcr.active_ind=1)
    WITH nocounter
   ;end update
   IF (curqual=0)
    CALL report_failure("UPDATE","F","DCP_ADD_COMP_RELTN",
     "Failed to update a row on ACT_PW_COMP_R table")
    GO TO exit_script
   ENDIF
  ENDIF
  SET idx = 0
  SET idx = locateval(idx,1,comp_reltn_count,"INSERT",request->compreltnlist[idx].action_mean)
  IF (idx > 0)
   INSERT  FROM act_pw_comp_r apcr,
     (dummyt d  WITH seq = value(comp_reltn_count))
    SET apcr.act_pw_comp_s_id = request->compreltnlist[d.seq].act_pw_comp_s_id, apcr.act_pw_comp_t_id
      = request->compreltnlist[d.seq].act_pw_comp_t_id, apcr.type_mean = request->compreltnlist[d.seq
     ].type_mean,
     apcr.offset_quantity = request->compreltnlist[d.seq].offset_quantity, apcr.offset_unit_cd =
     request->compreltnlist[d.seq].offset_unit_cd, apcr.pathway_id = request->compreltnlist[d.seq].
     pathway_id,
     apcr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), apcr.end_effective_dt_tm =
     cnvtdatetime(end_date_string), apcr.active_ind = 1,
     apcr.active_status_cd = active_cd, apcr.updt_dt_tm = cnvtdatetime(curdate,curtime3), apcr
     .updt_id = reqinfo->updt_id,
     apcr.updt_task = reqinfo->updt_task, apcr.updt_cnt = 0, apcr.updt_applctx = reqinfo->
     updt_applctx
    PLAN (d
     WHERE cnvtupper(request->compreltnlist[d.seq].action_mean)="INSERT")
     JOIN (apcr)
    WITH nocounter
   ;end insert
   IF (curqual=0)
    CALL report_failure("INSERT","F","DCP_ADD_COMP_RELTN",
     "Failed to insert a new row into ACT_PW_COMP_R table")
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 SUBROUTINE report_failure(opname,opstatus,targetname,targetvalue)
   SET cfailed = "T"
   SET isubeventstatuscount = (isubeventstatuscount+ 1)
   IF (isubeventstatuscount > isubeventstatussize)
    SET isubeventstatussize = (isubeventstatussize+ 1)
    SET stat = alterlist(reply->status_data.subeventstatus,isubeventstatussize)
   ENDIF
   SET reply->status_data.subeventstatus[isubeventstatuscount].operationname = trim(opname)
   SET reply->status_data.subeventstatus[isubeventstatuscount].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[isubeventstatuscount].targetobjectname = trim(targetname)
   SET reply->status_data.subeventstatus[isubeventstatuscount].targetobjectvalue = trim(targetvalue)
 END ;Subroutine
#exit_script
 SET errcode = error(errmsg,0)
 WHILE (errcode != 0
  AND errcnt <= 50)
   SET errcnt = (errcnt+ 1)
   CALL report_failure("CCL ERROR","F","DCP_ADD_COMP_RELTN",errmsg)
   SET errcode = error(errmsg,0)
 ENDWHILE
 IF (cfailed="T")
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET last_mod = "003"
 SET mod_date = "July 20, 2011"
END GO
