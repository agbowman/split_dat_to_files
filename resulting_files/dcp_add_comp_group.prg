CREATE PROGRAM dcp_add_comp_group
 SET modify = predeclare
 DECLARE comp_group_count = i2 WITH constant(value(size(request->compgrouplist,5)))
 DECLARE end_date_string = c20 WITH constant("31-DEC-2100 00:00:00")
 DECLARE active_cd = f8 WITH constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE cfailed = c1 WITH noconstant("F")
 DECLARE idx = i2 WITH noconstant(0)
 DECLARE bfailed = i2 WITH noconstant(0)
 DECLARE isubeventstatuscount = i4 WITH protect, noconstant(0)
 DECLARE isubeventstatussize = i4 WITH protect, noconstant(value(size(reply->status_data.
    subeventstatus,5)))
 DECLARE last_mod = c3 WITH protect, noconstant(fillstring(3,"000"))
 DECLARE mod_date = c30 WITH protect, noconstant(fillstring(30," "))
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errcnt = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant(" ")
 DECLARE report_failure(opname=vc,opstatus=c1,targetname=vc,targetvalue=vc) = null
 IF (comp_group_count > 0)
  SET idx = 0
  SET idx = locateval(idx,1,comp_group_count,"INSERT",request->compgrouplist[idx].action_mean)
  IF (idx > 0)
   INSERT  FROM act_pw_comp_g apcg,
     (dummyt d  WITH seq = value(comp_group_count))
    SET apcg.act_pw_comp_g_id = request->compgrouplist[d.seq].act_pw_comp_g_id, apcg.act_pw_comp_id
      = request->compgrouplist[d.seq].act_pw_comp_id, apcg.pathway_id = request->compgrouplist[d.seq]
     .pathway_id,
     apcg.pw_comp_seq = request->compgrouplist[d.seq].pw_comp_seq, apcg.type_mean = request->
     compgrouplist[d.seq].type_mean, apcg.included_ind = request->compgrouplist[d.seq].included_ind,
     apcg.description = request->compgrouplist[d.seq].description, apcg.updt_dt_tm = cnvtdatetime(
      curdate,curtime3), apcg.updt_id = reqinfo->updt_id,
     apcg.updt_task = reqinfo->updt_task, apcg.updt_cnt = 0, apcg.updt_applctx = reqinfo->
     updt_applctx,
     apcg.linking_rule_flag = request->compgrouplist[d.seq].linking_rule_flag, apcg
     .linking_rule_quantity = request->compgrouplist[d.seq].linking_rule_quantity, apcg
     .anchor_component_ind = request->compgrouplist[d.seq].anchor_component_ind,
     apcg.override_reason_flag = request->compgrouplist[d.seq].override_reason_flag
    PLAN (d
     WHERE cnvtupper(request->compgrouplist[d.seq].action_mean)="INSERT")
     JOIN (apcg)
    WITH nocounter
   ;end insert
   IF (curqual=0)
    CALL report_failure("INSERT","F","DCP_ADD_COMP_GROUP",
     "Failed to insert a new row into ACT_PW_COMP_G table")
    GO TO exit_script
   ENDIF
  ENDIF
  SET idx = 0
  SET idx = locateval(idx,1,comp_group_count,"UPDATE",request->compgrouplist[idx].action_mean)
  IF (idx > 0)
   SET bfailed = 1
   SELECT INTO "nl:"
    FROM act_pw_comp_g apcg,
     (dummyt d  WITH seq = value(comp_group_count))
    PLAN (d
     WHERE cnvtupper(request->compgrouplist[d.seq].action_mean)="UPDATE")
     JOIN (apcg
     WHERE (apcg.act_pw_comp_g_id=request->compgrouplist[d.seq].act_pw_comp_g_id)
      AND (apcg.act_pw_comp_id=request->compgrouplist[d.seq].act_pw_comp_id))
    HEAD REPORT
     bonefailed = 0
    DETAIL
     IF (bonefailed=0
      AND (apcg.updt_cnt != request->compgrouplist[d.seq].updt_cnt))
      bonefailed = 1
     ENDIF
    FOOT REPORT
     bfailed = bonefailed
    WITH nocounter, forupdate(d)
   ;end select
   IF (bfailed=1)
    CALL report_failure("SELECT","F","DCP_ADD_COMP_GROUP",
     "Failed to find existing rows in the ACT_PW_COMP_G table")
    GO TO exit_script
   ENDIF
   UPDATE  FROM act_pw_comp_g apcg,
     (dummyt d  WITH seq = value(comp_group_count))
    SET apcg.pathway_id = request->compgrouplist[d.seq].pathway_id, apcg.pw_comp_seq = request->
     compgrouplist[d.seq].pw_comp_seq, apcg.type_mean = request->compgrouplist[d.seq].type_mean,
     apcg.included_ind = request->compgrouplist[d.seq].included_ind, apcg.description = request->
     compgrouplist[d.seq].description, apcg.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     apcg.updt_id = reqinfo->updt_id, apcg.updt_task = reqinfo->updt_task, apcg.updt_cnt = (apcg
     .updt_cnt+ 1),
     apcg.updt_applctx = reqinfo->updt_applctx, apcg.linking_rule_flag = request->compgrouplist[d.seq
     ].linking_rule_flag, apcg.linking_rule_quantity = request->compgrouplist[d.seq].
     linking_rule_quantity,
     apcg.anchor_component_ind = request->compgrouplist[d.seq].anchor_component_ind, apcg
     .override_reason_flag = request->compgrouplist[d.seq].override_reason_flag
    PLAN (d
     WHERE cnvtupper(request->compgrouplist[d.seq].action_mean)="UPDATE")
     JOIN (apcg
     WHERE (apcg.act_pw_comp_g_id=request->compgrouplist[d.seq].act_pw_comp_g_id)
      AND (apcg.act_pw_comp_id=request->compgrouplist[d.seq].act_pw_comp_id))
    WITH nocounter
   ;end update
   IF (curqual=0)
    CALL report_failure("UPDATE","F","DCP_ADD_COMP_GROUP",
     "Failed to update a row in the ACT_PW_COMP_G table")
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
   CALL report_failure("CCL ERROR","F","DCP_ADD_COMP_GROUP",errmsg)
   SET errcode = error(errmsg,0)
 ENDWHILE
 IF (cfailed="T")
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET last_mod = "001"
 SET mod_date = "May 16, 2013"
END GO
