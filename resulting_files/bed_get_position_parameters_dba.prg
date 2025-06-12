CREATE PROGRAM bed_get_position_parameters:dba
 FREE SET reply
 RECORD reply(
   1 positions[*]
     2 code_value = f8
     2 app_grp_rel_exist_ind = i2
     2 psn_level_prefs_exist_ind = i2
     2 psn_loc_level_prefs_exist_ind = i2
     2 privs_exist_ind = i2
     2 prov_rel_exist_ind = i2
     2 task_list_views_exist_ind = i2
     2 task_reltn_exist_ind = i2
     2 note_type_reltn_exist_ind = i2
     2 time_frame_reltn_exist_ind = i2
     2 pal_psn_views_exist_ind = i2
     2 pal_psn_loc_views_exist_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET pcnt = size(request->positions,5)
 SET stat = alterlist(reply->positions,pcnt)
 FOR (p = 1 TO pcnt)
   SET reply->positions[p].code_value = request->positions[p].code_value
   IF ((request->check_app_grp_rel_ind=1))
    SELECT INTO "NL:"
     FROM application_group ap
     WHERE (ap.position_cd=request->positions[p].code_value)
     DETAIL
      reply->positions[p].app_grp_rel_exist_ind = 1
     WITH nocounter
    ;end select
   ENDIF
   IF ((request->check_psn_level_prefs_ind=1))
    SELECT INTO "NL:"
     FROM view_prefs pref
     WHERE (pref.position_cd=request->positions[p].code_value)
      AND pref.active_ind=1
     DETAIL
      reply->positions[p].psn_level_prefs_exist_ind = 1
     WITH nocounter
    ;end select
    IF ((reply->positions[p].psn_level_prefs_exist_ind=0))
     SELECT INTO "NL:"
      FROM view_comp_prefs pref
      WHERE (pref.position_cd=request->positions[p].code_value)
       AND pref.active_ind=1
      DETAIL
       reply->positions[p].psn_level_prefs_exist_ind = 1
      WITH nocounter
     ;end select
     IF ((reply->positions[p].psn_level_prefs_exist_ind=0))
      SELECT INTO "NL:"
       FROM detail_prefs pref
       WHERE (pref.position_cd=request->positions[p].code_value)
        AND pref.active_ind=1
       DETAIL
        reply->positions[p].psn_level_prefs_exist_ind = 1
       WITH nocounter
      ;end select
      IF ((reply->positions[p].psn_level_prefs_exist_ind=0))
       SELECT INTO "NL:"
        FROM app_prefs pref
        WHERE (pref.position_cd=request->positions[p].code_value)
         AND pref.active_ind=1
        DETAIL
         reply->positions[p].psn_level_prefs_exist_ind = 1
        WITH nocounter
       ;end select
       IF ((reply->positions[p].psn_level_prefs_exist_ind=0))
        DECLARE pos = vc
        DECLARE posstr = c255 WITH noconstant("")
        SET b = 0
        SET pos = cnvtstring(request->positions[p].code_value)
        SET b = (textlen(pos)+ 10)
        SET posstr = concat("prefgroup=",trim(pos))
        SELECT INTO "NL:"
         FROM prefdir_entrydata p1,
          prefdir_entrydata p2,
          prefdir_entrydata p3
         PLAN (p1
          WHERE p1.dist_name_short="prefcontext=position,prefroot=prefroot")
          JOIN (p2
          WHERE p2.parent_id=p1.entry_id
           AND substring(1,b,p2.dist_name)=posstr)
          JOIN (p3
          WHERE p3.parent_id=p2.entry_id)
         DETAIL
          reply->positions[p].psn_level_prefs_exist_ind = 1
         WITH nocounter
        ;end select
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   IF ((request->check_psn_loc_level_prefs_ind=1))
    DECLARE pos = vc
    DECLARE posstr = c255 WITH noconstant("")
    SET b = 0
    SET pos = cnvtstring(request->positions[p].code_value)
    SET b = (textlen(pos)+ 10)
    SET posstr = concat("prefgroup=",trim(pos))
    SELECT INTO "NL:"
     FROM prefdir_entrydata p1,
      prefdir_entrydata p2,
      prefdir_entrydata p3
     PLAN (p1
      WHERE p1.dist_name_short="prefcontext=position location,prefroot=prefroot")
      JOIN (p2
      WHERE p2.parent_id=p1.entry_id
       AND substring(1,b,p2.dist_name)=posstr)
      JOIN (p3
      WHERE p3.parent_id=p2.entry_id)
     DETAIL
      reply->positions[p].psn_loc_level_prefs_exist_ind = 1
     WITH nocounter
    ;end select
   ENDIF
   IF ((request->check_privs_ind=1))
    SELECT INTO "NL:"
     FROM priv_loc_reltn plr,
      privilege p,
      privilege pe
     PLAN (plr
      WHERE plr.person_id=0.0
       AND (plr.position_cd=request->positions[p].code_value)
       AND plr.ppr_cd=0.0
       AND plr.location_cd=0.0
       AND plr.active_ind=1)
      JOIN (p
      WHERE p.priv_loc_reltn_id=outerjoin(plr.priv_loc_reltn_id)
       AND p.active_ind=outerjoin(1))
      JOIN (pe
      WHERE pe.priv_loc_reltn_id=outerjoin(plr.priv_loc_reltn_id)
       AND pe.active_ind=outerjoin(1))
     DETAIL
      IF (((p.priv_loc_reltn_id > 0) OR (pe.priv_loc_reltn_id > 0)) )
       reply->positions[p].privs_exist_ind = 1
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   IF ((request->check_prov_rel_ind=1))
    SELECT INTO "NL:"
     FROM psn_ppr_reltn ppr
     WHERE (ppr.position_cd=request->positions[p].code_value)
      AND ppr.active_ind=1
     DETAIL
      reply->positions[p].prov_rel_exist_ind = 1
     WITH nocounter
    ;end select
   ENDIF
   IF ((request->check_task_list_views_ind=1))
    SELECT INTO "NL:"
     FROM tl_tab_position_xref t
     WHERE (t.position_cd=request->positions[p].code_value)
      AND t.active_ind=1
     DETAIL
      reply->positions[p].task_list_views_exist_ind = 1
     WITH nocounter
    ;end select
   ENDIF
   IF ((request->check_task_reltn_ind=1))
    SELECT INTO "NL:"
     FROM order_task_position_xref o
     WHERE (o.position_cd=request->positions[p].code_value)
     DETAIL
      reply->positions[p].task_reltn_exist_ind = 1
     WITH nocounter
    ;end select
   ENDIF
   IF ((request->check_note_type_reltn_ind=1))
    SELECT INTO "NL:"
     FROM note_type_list n
     WHERE (n.role_type_cd=request->positions[p].code_value)
      AND n.note_type_id > 0
     DETAIL
      reply->positions[p].note_type_reltn_exist_ind = 1
     WITH nocounter
    ;end select
   ENDIF
   IF ((request->check_time_frame_reltn_ind=1))
    SELECT INTO "NL:"
     FROM tl_tf_position_xref t
     WHERE (t.position_cd=request->positions[p].code_value)
     DETAIL
      reply->positions[p].time_frame_reltn_exist_ind = 1
     WITH nocounter
    ;end select
   ENDIF
   IF ((request->check_pal_psn_views_ind=1))
    SELECT INTO "NL:"
     FROM pip p
     WHERE (p.position_cd=request->positions[p].code_value)
      AND p.location_cd=0
      AND p.prsnl_id=0
     DETAIL
      reply->positions[p].pal_psn_views_exist_ind = 1
     WITH nocounter
    ;end select
   ENDIF
   IF ((request->check_pal_psn_loc_views_ind=1))
    SELECT INTO "NL:"
     FROM pip p
     WHERE (p.position_cd=request->positions[p].code_value)
      AND p.location_cd > 0
      AND p.prsnl_id=0
     DETAIL
      reply->positions[p].pal_psn_loc_views_exist_ind = 1
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
 SET reply->status_data.status = "S"
#exit_script
 CALL echorecord(reply)
END GO
