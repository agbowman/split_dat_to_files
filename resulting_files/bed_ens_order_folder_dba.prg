CREATE PROGRAM bed_ens_order_folder:dba
 FREE SET reply
 RECORD reply(
   1 id_list[*]
     2 folder_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD positions(
   1 plist[*]
     2 position_code_value = f8
     2 detail_prefs_id = f8
     2 pvc_name = c32
 )
 SET reply->status_data.status = "F"
 SET fcnt = size(request->flist,5)
 SET stat = alterlist(reply->id_list,fcnt)
 FOR (f = 1 TO fcnt)
   IF ((request->flist[f].action_flag=1))
    SET new_folder_id = 0.0
    SELECT INTO "nl:"
     z = seq(reference_seq,nextval)
     FROM dual
     DETAIL
      new_folder_id = cnvtreal(z)
     WITH format, nocounter
    ;end select
    INSERT  FROM alt_sel_cat ac
     SET ac.alt_sel_category_id = new_folder_id, ac.short_description = request->flist[f].
      short_description, ac.long_description = request->flist[f].long_description,
      ac.owner_id = 0.0, ac.security_flag = 2, ac.updt_cnt = 0,
      ac.updt_dt_tm = cnvtdatetime(curdate,curtime), ac.updt_id = reqinfo->updt_id, ac.updt_task =
      reqinfo->updt_task,
      ac.updt_applctx = reqinfo->updt_applctx, ac.child_cat_ind = 0, ac.long_description_key_cap =
      cnvtupper(request->flist[f].long_description),
      ac.ahfs_ind = 0, ac.adhoc_ind = 0, ac.source_component_flag = request->flist[f].component_flag,
      ac.folder_flag = 1
     WITH nocounter
    ;end insert
    IF ((request->flist[f].source_name > " "))
     INSERT  FROM br_of_parent_reltn b
      SET b.alt_sel_category_id = new_folder_id, b.source_id = request->flist[f].source_id, b
       .source_name = request->flist[f].source_name,
       b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(curdate,curtime), b.updt_id = reqinfo->updt_id,
       b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
    ENDIF
    SET reply->id_list[f].folder_id = new_folder_id
   ELSEIF ((request->flist[f].action_flag=2))
    UPDATE  FROM alt_sel_cat ac
     SET ac.short_description = request->flist[f].short_description, ac.long_description = request->
      flist[f].long_description, ac.long_description_key_cap = cnvtupper(request->flist[f].
       long_description),
      ac.updt_cnt = (ac.updt_cnt+ 1), ac.updt_id = reqinfo->updt_id, ac.updt_dt_tm = cnvtdatetime(
       curdate,curtime),
      ac.updt_task = reqinfo->updt_task, ac.updt_applctx = reqinfo->updt_applctx
     WHERE (ac.alt_sel_category_id=request->flist[f].folder_id)
     WITH nocounter
    ;end update
   ELSEIF ((request->flist[f].action_flag=3))
    IF ((request->flist[f].component_flag=1))
     SET stat = alterlist(positions->plist,20)
     SET pcnt = 0
     SET alterlist_pcnt = 0
     SELECT INTO "NL:"
      FROM name_value_prefs nvp,
       detail_prefs dp
      PLAN (nvp
       WHERE nvp.parent_entity_name="DETAIL_PREFS"
        AND nvp.pvc_name="ES_TAB_ID_3_*"
        AND nvp.pvc_value=cnvtstring(request->flist[f].folder_id)
        AND nvp.active_ind=1)
       JOIN (dp
       WHERE (dp.application_number=request->flist[f].application_number)
        AND dp.detail_prefs_id=nvp.parent_entity_id
        AND dp.active_ind=1)
      DETAIL
       alterlist_pcnt = (alterlist_pcnt+ 1)
       IF (alterlist_pcnt > 20)
        stat = alterlist(positions->plist,(pcnt+ 20)), alterlist_pcnt = 1
       ENDIF
       pcnt = (pcnt+ 1), positions->plist[pcnt].position_code_value = dp.position_cd, positions->
       plist[pcnt].detail_prefs_id = dp.detail_prefs_id,
       positions->plist[pcnt].pvc_name = nvp.pvc_name
      WITH nocounter
     ;end select
     SET stat = alterlist(positions->plist,pcnt)
     FOR (p = 1 TO pcnt)
       SET tab_nbr = cnvtint(substring(13,2,positions->plist[p].pvc_name))
       SET tab_cnt = 0
       SELECT INTO "NL:"
        FROM name_value_prefs nvp
        WHERE nvp.parent_entity_name="DETAIL_PREFS"
         AND (nvp.parent_entity_id=positions->plist[p].detail_prefs_id)
         AND nvp.pvc_name="ES_TAB_COUNT_3"
         AND nvp.active_ind=1
        DETAIL
         tab_cnt = cnvtint(nvp.pvc_value)
        WITH nocounter
       ;end select
       DELETE  FROM name_value_prefs nvp
        WHERE nvp.parent_entity_name="DETAIL_PREFS"
         AND (nvp.parent_entity_id=positions->plist[p].detail_prefs_id)
         AND (nvp.pvc_name=positions->plist[p].pvc_name)
         AND nvp.pvc_value=cnvtstring(request->flist[f].folder_id)
        WITH nocounter
       ;end delete
       SET old_tab_nbr = (tab_nbr+ 1)
       FOR (old_tab_nbr = old_tab_nbr TO tab_cnt)
         SET nvp_id = 0.0
         SET tab_name = concat("ES_TAB_ID_3_",cnvtstring(old_tab_nbr))
         SELECT INTO "NL:"
          FROM name_value_prefs nvp
          WHERE nvp.parent_entity_name="DETAIL_PREFS"
           AND (nvp.parent_entity_id=positions->plist[p].detail_prefs_id)
           AND nvp.pvc_name=tab_name
           AND nvp.active_ind=1
          DETAIL
           nvp_id = nvp.name_value_prefs_id
          WITH nocounter
         ;end select
         SET tab_name = concat("ES_TAB_ID_3_",cnvtstring((old_tab_nbr - 1)))
         UPDATE  FROM name_value_prefs nvp
          SET nvp.pvc_name = tab_name, nvp.updt_cnt = (nvp.updt_cnt+ 1), nvp.updt_id = reqinfo->
           updt_id,
           nvp.updt_dt_tm = cnvtdatetime(curdate,curtime), nvp.updt_task = reqinfo->updt_task, nvp
           .updt_applctx = reqinfo->updt_applctx
          WHERE nvp.name_value_prefs_id=nvp_id
          WITH nocounter
         ;end update
       ENDFOR
       UPDATE  FROM name_value_prefs nvp
        SET nvp.pvc_value = cnvtstring((tab_cnt - 1)), nvp.updt_cnt = (nvp.updt_cnt+ 1), nvp.updt_id
          = reqinfo->updt_id,
         nvp.updt_dt_tm = cnvtdatetime(curdate,curtime), nvp.updt_task = reqinfo->updt_task, nvp
         .updt_applctx = reqinfo->updt_applctx
        WHERE nvp.parent_entity_name="DETAIL_PREFS"
         AND (nvp.parent_entity_id=positions->plist[p].detail_prefs_id)
         AND nvp.pvc_name="ES_TAB_COUNT_3"
        WITH nocounter
       ;end update
     ENDFOR
    ELSEIF ((request->flist[f].component_flag=2))
     UPDATE  FROM name_value_prefs nvp
      SET nvp.pvc_value = " "
      WHERE nvp.parent_entity_name="APP_PREFS"
       AND nvp.pvc_name IN ("INPT_CATALOG_BROWSER_ROOT", "INPT_CATALOG_BROWSER_HOME")
       AND nvp.pvc_value=cnvtstring(request->flist[f].folder_id)
      WITH nocounter
     ;end update
    ENDIF
    DELETE  FROM alt_sel_list al
     WHERE (al.child_alt_sel_cat_id=request->flist[f].folder_id)
     WITH nocounter
    ;end delete
    DELETE  FROM alt_sel_list asl
     WHERE (asl.alt_sel_category_id=request->flist[f].folder_id)
     WITH nocounter
    ;end delete
    DELETE  FROM alt_sel_cat ac
     WHERE (ac.alt_sel_category_id=request->flist[f].folder_id)
     WITH nocounter
    ;end delete
    DELETE  FROM br_of_parent_reltn b
     WHERE (b.alt_sel_category_id=request->flist[f].folder_id)
     WITH nocounter
    ;end delete
   ELSEIF ((request->flist[f].action_flag=4))
    IF ((request->flist[f].component_flag=1))
     SET stat = alterlist(positions->plist,20)
     SET pcnt = 0
     SET alterlist_pcnt = 0
     SELECT INTO "NL:"
      FROM name_value_prefs nvp,
       detail_prefs dp
      PLAN (nvp
       WHERE nvp.parent_entity_name="DETAIL_PREFS"
        AND nvp.pvc_name="ES_TAB_ID_3_*"
        AND nvp.pvc_value=cnvtstring(request->flist[f].folder_id)
        AND nvp.active_ind=1)
       JOIN (dp
       WHERE (dp.application_number=request->flist[f].application_number)
        AND dp.detail_prefs_id=nvp.parent_entity_id
        AND dp.active_ind=1)
      DETAIL
       alterlist_pcnt = (alterlist_pcnt+ 1)
       IF (alterlist_pcnt > 20)
        stat = alterlist(positions->plist,(pcnt+ 20)), alterlist_pcnt = 1
       ENDIF
       pcnt = (pcnt+ 1), positions->plist[pcnt].position_code_value = dp.position_cd, positions->
       plist[pcnt].detail_prefs_id = dp.detail_prefs_id,
       positions->plist[pcnt].pvc_name = nvp.pvc_name
      WITH nocounter
     ;end select
     SET stat = alterlist(positions->plist,pcnt)
     FOR (p = 1 TO pcnt)
       SET tab_nbr = cnvtint(substring(13,2,positions->plist[p].pvc_name))
       SET tab_cnt = 0
       SELECT INTO "NL:"
        FROM name_value_prefs nvp
        WHERE nvp.parent_entity_name="DETAIL_PREFS"
         AND (nvp.parent_entity_id=positions->plist[p].detail_prefs_id)
         AND nvp.pvc_name="ES_TAB_COUNT_3"
         AND nvp.active_ind=1
        DETAIL
         tab_cnt = cnvtint(nvp.pvc_value)
        WITH nocounter
       ;end select
       DELETE  FROM name_value_prefs nvp
        WHERE nvp.parent_entity_name="DETAIL_PREFS"
         AND (nvp.parent_entity_id=positions->plist[p].detail_prefs_id)
         AND (nvp.pvc_name=positions->plist[p].pvc_name)
         AND nvp.pvc_value=cnvtstring(request->flist[f].folder_id)
        WITH nocounter
       ;end delete
       SET old_tab_nbr = (tab_nbr+ 1)
       FOR (old_tab_nbr = old_tab_nbr TO tab_cnt)
         SET nvp_id = 0.0
         SET tab_name = concat("ES_TAB_ID_3_",cnvtstring(old_tab_nbr))
         SELECT INTO "NL:"
          FROM name_value_prefs nvp
          WHERE nvp.parent_entity_name="DETAIL_PREFS"
           AND (nvp.parent_entity_id=positions->plist[p].detail_prefs_id)
           AND nvp.pvc_name=tab_name
           AND nvp.active_ind=1
          DETAIL
           nvp_id = nvp.name_value_prefs_id
          WITH nocounter
         ;end select
         SET tab_name = concat("ES_TAB_ID_3_",cnvtstring((old_tab_nbr - 1)))
         UPDATE  FROM name_value_prefs nvp
          SET nvp.pvc_name = tab_name, nvp.updt_cnt = (nvp.updt_cnt+ 1), nvp.updt_id = reqinfo->
           updt_id,
           nvp.updt_dt_tm = cnvtdatetime(curdate,curtime), nvp.updt_task = reqinfo->updt_task, nvp
           .updt_applctx = reqinfo->updt_applctx
          WHERE nvp.name_value_prefs_id=nvp_id
          WITH nocounter
         ;end update
       ENDFOR
       UPDATE  FROM name_value_prefs nvp
        SET nvp.pvc_value = cnvtstring((tab_cnt - 1)), nvp.updt_cnt = (nvp.updt_cnt+ 1), nvp.updt_id
          = reqinfo->updt_id,
         nvp.updt_dt_tm = cnvtdatetime(curdate,curtime), nvp.updt_task = reqinfo->updt_task, nvp
         .updt_applctx = reqinfo->updt_applctx
        WHERE nvp.parent_entity_name="DETAIL_PREFS"
         AND (nvp.parent_entity_id=positions->plist[p].detail_prefs_id)
         AND nvp.pvc_name="ES_TAB_COUNT_3"
        WITH nocounter
       ;end update
     ENDFOR
    ELSEIF ((request->flist[f].component_flag=2))
     UPDATE  FROM name_value_prefs nvp
      SET nvp.pvc_value = " "
      WHERE nvp.parent_entity_name="APP_PREFS"
       AND nvp.pvc_name="INPT_CATALOG_BROWSER_ROOT"
       AND nvp.pvc_value=cnvtstring(request->flist[f].folder_id)
      WITH nocounter
     ;end update
     UPDATE  FROM name_value_prefs nvp
      SET nvp.pvc_value = " "
      WHERE nvp.parent_entity_name="APP_PREFS"
       AND nvp.pvc_name="INPT_CATALOG_BROWSER_HOME"
       AND nvp.pvc_value=cnvtstring(request->flist[f].folder_id)
      WITH nocounter
     ;end update
    ENDIF
   ENDIF
 ENDFOR
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
 CALL echorecord(reply)
END GO
