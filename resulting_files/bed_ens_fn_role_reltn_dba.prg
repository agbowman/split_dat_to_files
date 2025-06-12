CREATE PROGRAM bed_ens_fn_role_reltn:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE error_msg = vc
 SET error_flag = "N"
 SET comp_type_code_value = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=20500
   AND cv.active_ind=1
   AND cv.cdf_meaning="DEFRELNROLE"
  DETAIL
   comp_type_code_value = cv.code_value
  WITH nocounter
 ;end select
 SET prv_code_value = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=16409
   AND cv.active_ind=1
   AND cv.cdf_meaning="PRVRELN"
  DETAIL
   prv_code_value = cv.code_value
  WITH nocounter
 ;end select
 SET group_cnt = size(request->trlist,5)
 SET rltn_cnt = size(request->rltn_list,5)
 SET tracking_ref_cnt = 0.0
 FOR (i = 1 TO group_cnt)
   SET track_ref_id = 0.0
   SELECT INTO "NL:"
    FROM track_reference tr
    WHERE (tr.tracking_group_cd=request->trlist[i].code_value)
     AND tr.tracking_ref_type_cd=prv_code_value
     AND tr.active_ind=1
     AND (tr.display=request->role_display)
    DETAIL
     track_ref_id = tr.tracking_ref_id
    WITH nocounter
   ;end select
   SET unique_comp = fillstring(50," ")
   SET unique_comp = concat(trim(cnvtstring(request->trlist[i].code_value)),";",trim(cnvtstring(
      track_ref_id)))
   SET track_pref_id = 0.0
   SELECT INTO "NL:"
    FROM track_prefs tp
    PLAN (tp
     WHERE tp.comp_name="Default Relation"
      AND tp.comp_type_cd=comp_type_code_value
      AND tp.comp_pref="Role Cd"
      AND tp.comp_name_unq=unique_comp)
    DETAIL
     track_pref_id = tp.track_pref_id
    WITH nocounter
   ;end select
   IF (track_pref_id=0)
    SELECT INTO "NL:"
     j = seq(tracking_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      track_pref_id = cnvtreal(j)
     WITH format, counter
    ;end select
    INSERT  FROM track_prefs tp
     SET tp.track_pref_id = track_pref_id, tp.comp_name = "Default Relation", tp.comp_name_unq =
      unique_comp,
      tp.comp_pref = "Role Cd", tp.comp_type_cd = comp_type_code_value, tp.parent_pref_id = 0.0,
      tp.updt_dt_tm = cnvtdatetime(curdate,curtime3), tp.updt_id = reqinfo->updt_id, tp.updt_task =
      reqinfo->updt_task,
      tp.updt_cnt = 0, tp.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Unable to insert ",cnvtstring(unique_comp)," into track_prefs for role."
      )
     GO TO exit_script
    ENDIF
   ENDIF
   IF (rltn_cnt > 0)
    INSERT  FROM track_comp_prefs tcp,
      (dummyt d  WITH seq = rltn_cnt)
     SET tcp.sub_comp_name = "Default Relation", tcp.sub_comp_pref = cnvtstring(request->rltn_list[d
       .seq].code_value), tcp.sub_comp_type_cd = comp_type_code_value,
      tcp.track_pref_id = track_pref_id, tcp.track_pref_comp_id = seq(tracking_seq,nextval), tcp
      .updt_dt_tm = cnvtdatetime(curdate,curtime3),
      tcp.updt_id = reqinfo->updt_id, tcp.updt_cnt = 0, tcp.updt_applctx = reqinfo->updt_applctx
     PLAN (d
      WHERE (request->rltn_list[d.seq].action_flag=1))
      JOIN (tcp)
     WITH nocounter
    ;end insert
    DELETE  FROM track_comp_prefs tcp,
      (dummyt d  WITH seq = rltn_cnt)
     SET tcp.seq = 1
     PLAN (d
      WHERE (request->rltn_list[d.seq].action_flag=3))
      JOIN (tcp
      WHERE tcp.sub_comp_name="Default Relation"
       AND tcp.sub_comp_pref=cnvtstring(request->rltn_list[d.seq].code_value)
       AND tcp.sub_comp_type_cd=comp_type_code_value
       AND tcp.track_pref_id=track_pref_id)
     WITH nocounter
    ;end delete
   ENDIF
 ENDFOR
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_ENS_FN_ROLE_RELTN","  >> ERROR MSG: ",
   error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
