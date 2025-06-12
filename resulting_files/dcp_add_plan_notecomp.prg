CREATE PROGRAM dcp_add_plan_notecomp
 SET modify = predeclare
 DECLARE create_type_code = f8 WITH constant(uar_get_code_by("MEANING",16829,"CREATE"))
 DECLARE comp_count = i2 WITH constant(value(size(request->complist,5)))
 DECLARE i = i2 WITH noconstant(0)
 DECLARE stat = i2 WITH noconstant(0)
 DECLARE cfailed = c1 WITH noconstant("F")
 DECLARE comp_text_id = f8 WITH noconstant(0.0)
 DECLARE isubeventstatuscount = i4 WITH protect, noconstant(0)
 DECLARE isubeventstatussize = i4 WITH protect, noconstant(value(size(reply->status_data.
    subeventstatus,5)))
 DECLARE last_mod = c3 WITH protect, noconstant(fillstring(3,"000"))
 DECLARE mod_date = c30 WITH protect, noconstant(fillstring(30," "))
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errcnt = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant(" ")
 DECLARE report_failure(opname=vc,opstatus=c1,targetname=vc,targetvalue=vc) = null
 IF (comp_count <= 0)
  CALL report_failure("INSERT","F","DCP_ADD_PLAN_NOTECOMP","Nothing to INSERT - compList is EMPTY")
  GO TO exit_script
 ENDIF
 FOR (i = 1 TO comp_count)
   SET comp_text_id = 0.0
   SELECT INTO "nl:"
    nextseqnum = seq(long_data_seq,nextval)
    FROM dual
    DETAIL
     comp_text_id = nextseqnum
    WITH nocounter
   ;end select
   IF (comp_text_id=0.0)
    CALL report_failure("INSERT","F","DCP_ADD_PLAN_NOTECOMP",
     "Unable to generate comp_text_id from long_data_seq")
    GO TO exit_script
   ENDIF
   INSERT  FROM long_text lt
    SET lt.long_text_id = comp_text_id, lt.parent_entity_name = "ACT_PW_COMP", lt.parent_entity_id =
     request->complist[i].act_pw_comp_id,
     lt.long_text = request->complist[i].comp_text, lt.active_ind = 1, lt.active_status_cd = reqdata
     ->active_status_cd,
     lt.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lt.active_status_prsnl_id = reqinfo->
     updt_id, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_cnt = 0,
     lt.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    CALL report_failure("INSERT","F","DCP_ADD_PLAN_NOTECOMP",
     "Failed to insert a new row into LONG_TEXT table")
    GO TO exit_script
   ENDIF
   INSERT  FROM act_pw_comp apc
    SET apc.act_pw_comp_id = request->complist[i].act_pw_comp_id, apc.pathway_id = request->complist[
     i].pathway_id, apc.pathway_comp_id = request->complist[i].pathway_comp_id,
     apc.comp_type_cd = request->complist[i].comp_type_cd, apc.comp_status_cd = 0.0, apc
     .parent_entity_id = comp_text_id,
     apc.parent_entity_name = request->complist[i].parent_entity_name, apc.dcp_clin_cat_cd = request
     ->complist[i].dcp_clin_cat_cd, apc.dcp_clin_sub_cat_cd = request->complist[i].
     dcp_clin_sub_cat_cd,
     apc.sequence = request->complist[i].sequence, apc.encntr_id = request->complist[i].encntr_id,
     apc.person_id = request->complist[i].person_id,
     apc.active_ind = 1, apc.persistent_ind = request->complist[i].persistent_ind, apc
     .ref_prnt_ent_name = request->complist[i].ref_prnt_ent_name,
     apc.ref_prnt_ent_id = request->complist[i].ref_prnt_ent_id, apc.comp_label = request->complist[i
     ].comp_label, apc.chemo_ind = 0,
     apc.chemo_related_ind = request->complist[i].chemo_related_ind, apc.display_format_xml =
     IF (trim(request->complist[i].display_format_xml) > " ") trim(request->complist[i].
       display_format_xml)
     ELSE "<xml />"
     ENDIF
     , apc.last_action_seq = 1,
     apc.updt_dt_tm = cnvtdatetime(curdate,curtime3), apc.updt_id = reqinfo->updt_id, apc.updt_task
      = reqinfo->updt_task,
     apc.updt_cnt = 0, apc.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    CALL report_failure("INSERT","F","DCP_ADD_PLAN_NOTECOMP",
     "Failed to insert a new row into ACT_PW_COMP table")
    GO TO exit_script
   ENDIF
   INSERT  FROM pw_comp_action pca
    SET pca.act_pw_comp_id = request->complist[i].act_pw_comp_id, pca.pw_comp_action_seq = 1, pca
     .comp_status_cd = 0.0,
     pca.action_type_cd = create_type_code, pca.action_dt_tm = cnvtdatetime(curdate,curtime3), pca
     .action_tz = request->user_tz,
     pca.action_prsnl_id = reqinfo->updt_id, pca.parent_entity_id = comp_text_id, pca
     .parent_entity_name = request->complist[i].parent_entity_name,
     pca.updt_dt_tm = cnvtdatetime(curdate,curtime3), pca.updt_id = reqinfo->updt_id, pca.updt_task
      = reqinfo->updt_task,
     pca.updt_cnt = 0, pca.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    CALL report_failure("INSERT","F","DCP_ADD_PLAN_NOTECOMP",
     "Failed to insert a new row into PW_COMP_ACTION table")
    GO TO exit_script
   ENDIF
 ENDFOR
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
   CALL report_failure("CCL ERROR","F","DCP_ADD_PLAN_NOTECOMP",errmsg)
   SET errcode = error(errmsg,0)
 ENDWHILE
 IF (cfailed="T")
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET last_mod = "006"
 SET mod_date = "July 20, 2011"
END GO
