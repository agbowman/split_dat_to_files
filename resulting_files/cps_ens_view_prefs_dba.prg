CREATE PROGRAM cps_ens_view_prefs:dba
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 RECORD reply(
   1 qual_knt = i4
   1 qual[*]
     2 application_number = i4
     2 position_cd = f8
     2 prsnl_id = f8
     2 view_knt = i4
     2 views[*]
       3 view_prefs_id = f8
       3 frame_type = c12
       3 view_name = c12
       3 view_seq = i4
       3 pref_knt = i4
       3 pref[*]
         4 name_value_prefs_id = f8
         4 pref_name = c32
         4 pref_value = vc
         4 merge_name = vc
         4 merge_id = f8
         4 sequence = i4
       3 view_comp_knt = i4
       3 view_comp[*]
         4 view_comp_prefs_id = f8
         4 comp_name = c12
         4 comp_seq = i4
         4 pref_knt = i4
         4 pref[*]
           5 name_value_prefs_id = f8
           5 pref_name = c32
           5 pref_value = vc
           5 merge_name = vc
           5 merge_id = f8
           5 sequence = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET dvar = 0
 IF ((request->qual_knt > 0))
  SET reply->qual_knt = request->qual_knt
  SET stat = alterlist(reply->qual,reply->qual_knt)
  FOR (i = 1 TO request->qual_knt)
    IF ((request->qual[i].prsnl_id > 0))
     SET request->qual[i].position_cd = 0.0
    ENDIF
    SET reply->qual[i].application_number = request->qual[i].application_number
    SET reply->qual[i].position_cd = request->qual[i].position_cd
    SET reply->qual[i].prsnl_id = request->qual[i].prsnl_id
    SET reply->qual[i].view_knt = request->qual[i].view_knt
    SET stat = alterlist(reply->qual[i].views,reply->qual[i].view_knt)
    IF ((request->qual[i].view_knt > 0))
     FOR (j = 1 TO request->qual[i].view_knt)
       SET reply->qual[i].views[j].frame_type = request->qual[i].views[j].frame_type
       SET reply->qual[i].views[j].view_name = request->qual[i].views[j].view_name
       SET reply->qual[i].views[j].view_seq = request->qual[i].views[j].view_seq
       SET reply->qual[i].views[j].pref_knt = request->qual[i].views[j].pref_knt
       SET stat = alterlist(reply->qual[i].views[j].pref,reply->qual[i].views[j].pref_knt)
       SET reply->qual[i].views[j].view_comp_knt = request->qual[i].views[j].view_comp_knt
       SET stat = alterlist(reply->qual[i].views[j].view_comp,reply->qual[i].views[j].view_comp_knt)
       IF ((request->qual[i].views[j].view_prefs_id > 0))
        SET reply->qual[i].views[j].view_prefs_id = request->qual[i].views[j].view_prefs_id
        CALL update_view(i,j)
        IF (failed != false)
         SET table_name = "UPDATE_VIEW"
         GO TO exit_script
        ENDIF
       ELSE
        SET ierrcode = error(serrmsg,1)
        SET ierrcode = 0
        SELECT INTO "nl:"
         FROM view_prefs vp
         PLAN (vp
          WHERE (vp.prsnl_id=request->qual[i].prsnl_id)
           AND (vp.position_cd=request->qual[i].position_cd)
           AND (vp.application_number=request->qual[i].application_number)
           AND (vp.frame_type=request->qual[i].views[j].frame_type)
           AND (vp.view_name=request->qual[i].views[j].view_name)
           AND (vp.view_seq=request->qual[i].views[j].view_seq))
         HEAD REPORT
          request->qual[i].views[j].view_prefs_id = vp.view_prefs_id
         WITH nocounter
        ;end select
        SET ierrcode = error(serrmsg,1)
        IF (ierrcode > 0)
         SET failed = select_error
         SET table_name = "VIEW_PREFS"
         GO TO exit_script
        ENDIF
        IF (curqual < 1)
         SET new_id = 0.0
         CALL generate_id(dvar)
         IF (failed != false)
          SET table_name = "GENERATE_ID"
          GO TO exit_script
         ENDIF
         SET request->qual[i].views[j].view_prefs_id = new_id
         SET reply->qual[i].views[j].view_prefs_id = new_id
         CALL insert_view(i,j)
         IF (failed != false)
          SET table_name = "INSERT_VIEW"
          GO TO exit_script
         ENDIF
        ELSE
         SET reply->qual[i].views[j].view_prefs_id = request->qual[i].views[j].view_prefs_id
         CALL update_view(i,j)
         IF (failed != false)
          SET table_name = "UPDATE_VIEW"
          GO TO exit_script
         ENDIF
        ENDIF
       ENDIF
       IF ((request->qual[i].views[j].pref_knt > 0))
        FOR (k = 1 TO request->qual[i].views[j].pref_knt)
          SET reply->qual[i].views[j].pref[k].pref_name = request->qual[i].views[j].pref[k].pref_name
          SET reply->qual[i].views[j].pref[k].pref_value = request->qual[i].views[j].pref[k].
          pref_value
          SET reply->qual[i].views[j].pref[k].merge_name = request->qual[i].views[j].pref[k].
          merge_name
          SET reply->qual[i].views[j].pref[k].merge_id = request->qual[i].views[j].pref[k].merge_id
          SET reply->qual[i].views[j].pref[k].sequence = request->qual[i].views[j].pref[k].sequence
          IF ((request->qual[i].views[j].pref[k].name_value_prefs_id > 0))
           SET reply->qual[i].views[j].pref[k].name_value_prefs_id = request->qual[i].views[j].pref[k
           ].name_value_prefs_id
           CALL update_view_pref(i,j,k)
           IF (failed != false)
            SET table_name = "UPDATE_VIEW_PREF"
            GO TO exit_script
           ENDIF
          ELSE
           SET ierrcode = error(serrmsg,1)
           SET ierrcode = 0
           SELECT INTO "nl:"
            FROM name_value_prefs nvp
            PLAN (nvp
             WHERE (nvp.parent_entity_id=request->qual[i].views[j].view_prefs_id)
              AND nvp.parent_entity_name="VIEW_PREFS"
              AND (nvp.pvc_name=request->qual[i].views[j].pref[k].pref_name))
            HEAD REPORT
             request->qual[i].views[j].pref[k].name_value_prefs_id = nvp.name_value_prefs_id
            WITH nocounter
           ;end select
           SET ierrcode = error(serrmsg,1)
           IF (ierrcode > 0)
            SET failed = select_error
            SET table_name = "NAME_VALUE_PREFS"
            GO TO exit_script
           ENDIF
           IF (curqual < 1)
            SET new_id = 0.0
            CALL generate_id(dvar)
            IF (failed != false)
             SET table_name = "GENERATE_ID"
             GO TO exit_script
            ENDIF
            SET request->qual[i].views[j].pref[k].name_value_prefs_id = new_id
            SET reply->qual[i].views[j].pref[k].name_value_prefs_id = new_id
            CALL insert_view_pref(i,j,k)
            IF (failed != false)
             SET table_name = "INSERT_VIEW_PREF"
             GO TO exit_script
            ENDIF
           ELSE
            SET reply->qual[i].views[j].pref[k].name_value_prefs_id = request->qual[i].views[j].pref[
            k].name_value_prefs_id
            CALL update_view_pref(i,j,k)
            IF (failed != false)
             SET table_name = "UPDATE_VIEW_PREF"
             GO TO exit_script
            ENDIF
           ENDIF
          ENDIF
        ENDFOR
       ENDIF
       IF ((request->qual[i].views[j].view_comp_knt > 0))
        SET reply->qual[i].views[j].view_comp_knt = request->qual[i].views[j].view_comp_knt
        SET stat = alterlist(reply->qual[i].views[j].view_comp,reply->qual[i].views[j].view_comp_knt)
        FOR (k = 1 TO request->qual[i].views[j].view_comp_knt)
          SET reply->qual[i].views[j].view_comp[k].comp_name = request->qual[i].views[j].view_comp[k]
          .comp_name
          SET reply->qual[i].views[j].view_comp[k].comp_seq = request->qual[i].views[j].view_comp[k].
          comp_seq
          SET reply->qual[i].views[j].view_comp[k].pref_knt = request->qual[i].views[j].view_comp[k].
          pref_knt
          SET stat = alterlist(reply->qual[i].views[j].view_comp[k].pref,reply->qual[i].views[j].
           view_comp[k].pref_knt)
          IF ((request->qual[i].views[j].view_comp[k].view_comp_prefs_id > 0))
           SET reply->qual[i].views[j].view_comp[k].view_comp_prefs_id = request->qual[i].views[j].
           view_comp[k].view_comp_prefs_id
           CALL update_view_comp(i,j,k)
           IF (failed != false)
            SET table_name = "UPDATE_VIEW_COMP"
            GO TO exit_script
           ENDIF
          ELSE
           SET ierrcode = error(serrmsg,1)
           SET ierrcode = 0
           SELECT INTO "nl:"
            FROM view_comp_prefs vcp
            PLAN (vcp
             WHERE (vcp.prsnl_id=request->qual[i].prsnl_id)
              AND (vcp.position_cd=request->qual[i].position_cd)
              AND (vcp.application_number=request->qual[i].application_number)
              AND (vcp.view_name=request->qual[i].views[j].view_name)
              AND (vcp.view_seq=request->qual[i].views[j].view_seq)
              AND (vcp.comp_name=request->qual[i].views[j].view_comp[k].comp_name)
              AND (vcp.comp_seq=request->qual[i].views[j].view_comp[k].comp_seq))
            HEAD REPORT
             request->qual[i].views[j].view_comp[k].view_comp_prefs_id = vcp.view_comp_prefs_id
            WITH nocounter
           ;end select
           SET ierrcode = error(serrmsg,1)
           IF (ierrcode > 0)
            SET failed = select_error
            SET table_name = "NAME_VALUE_PREFS"
            GO TO exit_script
           ENDIF
           IF (curqual < 1)
            SET new_id = 0.0
            CALL generate_id(dvar)
            IF (failed != false)
             SET table_name = "GENERATE_ID"
             GO TO exit_script
            ENDIF
            SET request->qual[i].views[j].view_comp[k].view_comp_prefs_id = new_id
            SET reply->qual[i].views[j].view_comp[k].view_comp_prefs_id = new_id
            CALL insert_view_comp(i,j,k)
            IF (failed != false)
             SET table_name = "INSERT_VIEW_COMP"
             GO TO exit_script
            ENDIF
           ELSE
            SET reply->qual[i].views[j].view_comp[k].view_comp_prefs_id = request->qual[i].views[j].
            view_comp[k].view_comp_prefs_id
            CALL update_view_comp(i,j,k)
            IF (failed != false)
             SET table_name = "UPDATE_VIEW_COMP"
             GO TO exit_script
            ENDIF
           ENDIF
          ENDIF
          IF ((request->qual[i].views[j].view_comp[k].pref_knt > 0))
           FOR (m = 1 TO request->qual[i].views[j].view_comp[k].pref_knt)
             SET reply->qual[i].views[j].view_comp[k].pref[m].pref_name = request->qual[i].views[j].
             view_comp[k].pref[m].pref_name
             SET reply->qual[i].views[j].view_comp[k].pref[m].pref_value = request->qual[i].views[j].
             view_comp[k].pref[m].pref_value
             SET reply->qual[i].views[j].view_comp[k].pref[m].merge_name = request->qual[i].views[j].
             view_comp[k].pref[m].merge_name
             SET reply->qual[i].views[j].view_comp[k].pref[m].merge_id = request->qual[i].views[j].
             view_comp[k].pref[m].merge_id
             SET reply->qual[i].views[j].view_comp[k].pref[m].sequence = request->qual[i].views[j].
             view_comp[k].pref[m].sequence
             IF ((request->qual[i].views[j].view_comp[k].pref[m].name_value_prefs_id > 0))
              SET reply->qual[i].views[j].view_comp[k].pref[m].name_value_prefs_id = request->qual[i]
              .views[j].view_comp[k].pref[m].name_value_prefs_id
              CALL update_view_comp_pref(i,j,k,m)
              IF (failed != false)
               SET table_name = "UPDATE_VIEW_COMP_PREF"
               GO TO exit_script
              ENDIF
             ELSE
              SET ierrcode = error(serrmsg,1)
              SET ierrcode = 0
              SELECT INTO "nl:"
               FROM name_value_prefs nvp
               PLAN (nvp
                WHERE (nvp.parent_entity_id=request->qual[i].views[j].view_comp[k].view_comp_prefs_id
                )
                 AND (nvp.pvc_name=request->qual[i].views[j].view_comp[k].pref[m].pref_name))
               HEAD REPORT
                request->qual[i].views[j].view_comp[k].pref[m].name_value_prefs_id = nvp
                .name_value_prefs_id
               WITH nocounter
              ;end select
              SET ierrcode = error(serrmsg,1)
              IF (ierrcode > 0)
               SET failed = select_error
               SET table_name = "NAME_VALUE_PREFS"
               GO TO exit_script
              ENDIF
              IF (curqual < 1)
               SET new_id = 0.0
               CALL generate_id(dvar)
               IF (failed != false)
                SET table_name = "GENERATE_ID"
                GO TO exit_script
               ENDIF
               SET request->qual[i].views[j].view_comp[k].pref[m].name_value_prefs_id = new_id
               SET reply->qual[i].views[j].view_comp[k].pref[m].name_value_prefs_id = new_id
               CALL insert_view_comp_pref(i,j,k,m)
               IF (failed != false)
                SET table_name = "INSERT_VIEW_COMP_PREF"
                GO TO exit_script
               ENDIF
              ELSE
               SET reply->qual[i].views[j].view_comp[k].pref[m].name_value_prefs_id = request->qual[i
               ].views[j].view_comp[k].pref[m].name_value_prefs_id
               CALL update_view_comp_pref(i,j,k,m)
               IF (failed != false)
                SET table_name = "UPDATE_VIEW_COMP_PREF"
                GO TO exit_script
               ENDIF
              ENDIF
             ENDIF
           ENDFOR
          ENDIF
        ENDFOR
       ENDIF
     ENDFOR
    ENDIF
  ENDFOR
 ENDIF
 GO TO exit_script
 SUBROUTINE generate_id(lvar)
   CALL echo("***")
   CALL echo("***   GENERATE_ID called")
   CALL echo("***")
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   SELECT INTO "nl:"
    temp_id = seq(carenet_seq,nextval)
    FROM dual
    DETAIL
     new_id = cnvtreal(temp_id)
    WITH nocounter
   ;end select
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = gen_nbr_error
   ENDIF
 END ;Subroutine
 SUBROUTINE update_view(aidx,bidx)
   CALL echo("***")
   CALL echo("***   UPDATE_VIEW called")
   CALL echo("***")
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   UPDATE  FROM view_prefs vp
    SET active_ind = true, vp.updt_cnt = (vp.updt_cnt+ 1), vp.updt_id = reqinfo->updt_id,
     vp.updt_dt_tm = cnvtdatetime(sysdate), vp.updt_task = reqinfo->updt_task, vp.updt_applctx =
     reqinfo->updt_applctx
    WHERE (vp.view_prefs_id=request->qual[aidx].views[bidx].view_prefs_id)
     AND vp.active_ind=false
    WITH nocounter
   ;end update
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = update_error
   ENDIF
 END ;Subroutine
 SUBROUTINE insert_view(aidx,bidx)
   CALL echo("***")
   CALL echo("***   INSERT_VIEW called")
   CALL echo("***")
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   INSERT  FROM view_prefs vp
    SET vp.view_prefs_id = request->qual[aidx].views[bidx].view_prefs_id, vp.prsnl_id = request->
     qual[aidx].prsnl_id, vp.position_cd = request->qual[aidx].position_cd,
     vp.application_number = request->qual[aidx].application_number, vp.frame_type = request->qual[
     aidx].views[bidx].frame_type, vp.view_name = request->qual[aidx].views[bidx].view_name,
     vp.view_seq = request->qual[aidx].views[bidx].view_seq, vp.active_ind = true, vp.updt_id =
     reqinfo->updt_id,
     vp.updt_cnt = 0, vp.updt_dt_tm = cnvtdatetime(sysdate), vp.updt_task = reqinfo->updt_task,
     vp.updt_applctx = reqinfo->updt_applctx
    WHERE 0=0
    WITH nocounter
   ;end insert
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = insert_error
   ENDIF
 END ;Subroutine
 SUBROUTINE update_view_pref(aidx,bidx,cidx)
   CALL echo("***")
   CALL echo("***   UPDATE_VIEW_PREF called")
   CALL echo("***")
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   UPDATE  FROM name_value_prefs nvp
    SET nvp.active_ind = true, nvp.pvc_value = request->qual[aidx].views[bidx].pref[cidx].pref_value,
     nvp.merge_name = request->qual[aidx].views[bidx].pref[cidx].merge_name,
     nvp.merge_id = request->qual[aidx].views[bidx].pref[cidx].merge_id, nvp.sequence = request->
     qual[aidx].views[bidx].pref[cidx].sequence, nvp.updt_cnt = (nvp.updt_cnt+ 1),
     nvp.updt_id = reqinfo->updt_id, nvp.updt_dt_tm = cnvtdatetime(sysdate), nvp.updt_task = reqinfo
     ->updt_task,
     nvp.updt_applctx = reqinfo->updt_applctx
    WHERE (nvp.name_value_prefs_id=request->qual[aidx].views[bidx].pref[cidx].name_value_prefs_id)
     AND (nvp.parent_entity_id=request->qual[aidx].views[bidx].view_prefs_id)
     AND nvp.parent_entity_name="VIEW_PREFS"
    WITH nocounter
   ;end update
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = update_error
   ENDIF
 END ;Subroutine
 SUBROUTINE insert_view_pref(aidx,bidx,cidx)
   CALL echo("***")
   CALL echo("***   INSERT_VIEW_PREF called")
   CALL echo("***")
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   INSERT  FROM name_value_prefs nvp
    SET nvp.name_value_prefs_id = request->qual[aidx].views[bidx].pref[cidx].name_value_prefs_id, nvp
     .parent_entity_id = request->qual[aidx].views[bidx].view_prefs_id, nvp.parent_entity_name =
     "VIEW_PREFS",
     nvp.pvc_name = request->qual[aidx].views[bidx].pref[cidx].pref_name, nvp.pvc_value = request->
     qual[aidx].views[bidx].pref[cidx].pref_value, nvp.merge_name = request->qual[aidx].views[bidx].
     pref[cidx].merge_name,
     nvp.merge_id = request->qual[aidx].views[bidx].pref[cidx].merge_id, nvp.sequence = request->
     qual[aidx].views[bidx].pref[cidx].sequence, nvp.active_ind = true,
     nvp.updt_id = reqinfo->updt_id, nvp.updt_cnt = 0, nvp.updt_dt_tm = cnvtdatetime(sysdate),
     nvp.updt_task = reqinfo->updt_task, nvp.updt_applctx = reqinfo->updt_applctx
    WHERE 0=0
    WITH nocounter
   ;end insert
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = insert_error
   ENDIF
 END ;Subroutine
 SUBROUTINE update_view_comp(aidx,bidx,cidx)
   CALL echo("***")
   CALL echo("***   UPDATE_VIEW_COMP called")
   CALL echo("***")
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   UPDATE  FROM view_comp_prefs vcp
    SET vcp.active_ind = true, vcp.updt_cnt = (vcp.updt_cnt+ 1), vcp.updt_id = reqinfo->updt_id,
     vcp.updt_dt_tm = cnvtdatetime(sysdate), vcp.updt_task = reqinfo->updt_task, vcp.updt_applctx =
     reqinfo->updt_applctx
    WHERE (vcp.view_comp_prefs_id=request->qual[aidx].views[bidx].view_comp[cidx].view_comp_prefs_id)
     AND vcp.active_ind=false
   ;end update
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = update_error
   ENDIF
 END ;Subroutine
 SUBROUTINE insert_view_comp(aidx,bidx,cidx)
   CALL echo("***")
   CALL echo("***   INSERT_VIEW_COMP called")
   CALL echo("***")
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   INSERT  FROM view_comp_prefs vcp
    SET vcp.view_comp_prefs_id = request->qual[aidx].views[bidx].view_comp[cidx].view_comp_prefs_id,
     vcp.prsnl_id = request->qual[aidx].prsnl_id, vcp.position_cd = request->qual[aidx].position_cd,
     vcp.application_number = request->qual[aidx].application_number, vcp.view_name = request->qual[
     aidx].views[bidx].view_name, vcp.view_seq = request->qual[aidx].views[bidx].view_seq,
     vcp.comp_name = request->qual[aidx].views[bidx].view_comp[cidx].comp_name, vcp.comp_seq =
     request->qual[aidx].views[bidx].view_comp[cidx].comp_seq, vcp.active_ind = true,
     vcp.updt_id = reqinfo->updt_id, vcp.updt_cnt = 0, vcp.updt_dt_tm = cnvtdatetime(sysdate),
     vcp.updt_task = reqinfo->updt_task, vcp.updt_applctx = reqinfo->updt_applctx
    WHERE 0=0
    WITH nocounter
   ;end insert
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = insert_error
   ENDIF
 END ;Subroutine
 SUBROUTINE update_view_comp_pref(aidx,bidx,cidx,didx)
   CALL echo("***")
   CALL echo("***   UPDATE_VIEW_COMP_PREF called")
   CALL echo("***")
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   UPDATE  FROM name_value_prefs nvp
    SET nvp.active_ind = true, nvp.pvc_value = request->qual[aidx].views[bidx].view_comp[cidx].pref[
     didx].pref_value, nvp.merge_name = request->qual[aidx].views[bidx].view_comp[cidx].pref[didx].
     merge_name,
     nvp.merge_id = request->qual[aidx].views[bidx].view_comp[cidx].pref[didx].merge_id, nvp.sequence
      = request->qual[aidx].views[bidx].view_comp[cidx].pref[didx].sequence, nvp.updt_cnt = (nvp
     .updt_cnt+ 1),
     nvp.updt_id = reqinfo->updt_id, nvp.updt_dt_tm = cnvtdatetime(sysdate), nvp.updt_task = reqinfo
     ->updt_task,
     nvp.updt_applctx = reqinfo->updt_applctx
    WHERE (nvp.name_value_prefs_id=request->qual[aidx].views[bidx].view_comp[cidx].pref[didx].
    name_value_prefs_id)
     AND (nvp.parent_entity_id=request->qual[aidx].views[bidx].view_comp[cidx].view_comp_prefs_id)
     AND nvp.parent_entity_name="VIEW_COMP_PREFS"
    WITH nocounter
   ;end update
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = update_error
   ENDIF
 END ;Subroutine
 SUBROUTINE insert_view_comp_pref(aidx,bidx,cidx,didx)
   CALL echo("***")
   CALL echo("***   INSERT_VIEW_COMP_PREF called")
   CALL echo("***")
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   INSERT  FROM name_value_prefs nvp
    SET nvp.name_value_prefs_id = request->qual[aidx].views[bidx].view_comp[cidx].pref[didx].
     name_value_prefs_id, nvp.parent_entity_id = request->qual[aidx].views[bidx].view_comp[cidx].
     view_comp_prefs_id, nvp.parent_entity_name = "VIEW_COMP_PREFS",
     nvp.pvc_name = request->qual[aidx].views[bidx].view_comp[cidx].pref[didx].pref_name, nvp
     .pvc_value = request->qual[aidx].views[bidx].view_comp[cidx].pref[didx].pref_value, nvp
     .merge_name = request->qual[aidx].views[bidx].view_comp[cidx].pref[didx].merge_name,
     nvp.merge_id = request->qual[aidx].views[bidx].view_comp[cidx].pref[didx].merge_id, nvp.sequence
      = request->qual[aidx].views[bidx].view_comp[cidx].pref[didx].sequence, nvp.active_ind = true,
     nvp.updt_id = reqinfo->updt_id, nvp.updt_cnt = 0, nvp.updt_dt_tm = cnvtdatetime(sysdate),
     nvp.updt_task = reqinfo->updt_task, nvp.updt_applctx = reqinfo->updt_applctx
    WHERE 0=0
    WITH nocounter
   ;end insert
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = insert_error
   ENDIF
 END ;Subroutine
#exit_script
 IF (failed != false)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  IF (failed=select_error)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSEIF (failed=insert_error)
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSEIF (failed=input_error)
   SET reply->status_data.subeventstatus[1].operationname = "VALIDATION"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSE
   SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ENDIF
 ELSEIF ((reply->qual_knt > 0))
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = true
 ELSE
  SET reply->status_data.status = "Z"
  SET reqinfo->commit_ind = true
 ENDIF
 SET script_version = "001 02/23/01 SF3151"
END GO
