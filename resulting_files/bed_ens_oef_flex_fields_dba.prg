CREATE PROGRAM bed_ens_oef_flex_fields:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 error_msg = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 SET oef_cnt = size(request->oef_list,5)
 IF (oef_cnt=0)
  GO TO exit_script
 ENDIF
 DECLARE default_value = vc
 FOR (o = 1 TO oef_cnt)
  SET flist_cnt = size(request->oef_list[o].flist,5)
  FOR (x = 1 TO flist_cnt)
    DELETE  FROM accept_format_flexing aff
     WHERE (aff.oe_format_id=request->oef_list[o].oe_format_id)
      AND (aff.action_type_cd=request->oef_list[o].action_type_cd)
      AND (aff.flex_cd=request->oef_list[o].flist[x].code_value)
      AND (aff.flex_type_flag=request->oef_list[o].flex_type_flag)
     WITH nocounter
    ;end delete
    SET fld_cnt = size(request->oef_list[o].flist[x].fld_list,5)
    FOR (f = 1 TO fld_cnt)
     IF ((((request->oef_list[o].flist[x].fld_list[f].field_type=6)) OR ((request->oef_list[o].flist[
     x].fld_list[f].field_type=12))) )
      SET default_value = fillstring(100," ")
      SET default_parent_entity_name = "CODE_VALUE  "
      SET default_parent_entity_id = request->oef_list[o].flist[x].fld_list[f].flex_value
     ELSEIF ((request->oef_list[o].flist[x].fld_list[f].field_type=9))
      IF ((request->oef_list[o].flist[x].fld_list[f].flex_value > 0))
       SET default_value = fillstring(100," ")
       SET default_parent_entity_name = "CODE_VALUE  "
       SET default_parent_entity_id = request->oef_list[o].flist[x].fld_list[f].flex_value
      ELSE
       IF ((request->oef_list[o].flist[x].fld_list[f].flex_display=" "))
        SET default_value = fillstring(100," ")
       ELSE
        SET default_value = concat("~",request->oef_list[o].flist[x].fld_list[f].flex_display)
       ENDIF
       SET default_parent_entity_name = "CODE_VALUE  "
       SET default_parent_entity_id = 0.0
      ENDIF
     ELSEIF ((request->oef_list[o].flist[x].fld_list[f].field_type=10))
      SET default_value = fillstring(100," ")
      SET default_parent_entity_name = "NOMENCLATURE"
      SET default_parent_entity_id = request->oef_list[o].flist[x].fld_list[f].flex_value
     ELSEIF ((request->oef_list[o].flist[x].fld_list[f].field_type=13))
      IF ((request->oef_list[o].flist[x].fld_list[f].flex_display=" "))
       SET default_value = fillstring(100," ")
      ELSE
       SET default_value = concat("~",request->oef_list[o].flist[x].fld_list[f].flex_display)
      ENDIF
      SET default_parent_entity_name = "PERSON      "
      SET default_parent_entity_id = 0.0
     ELSEIF ((request->oef_list[o].flist[x].fld_list[f].field_type=8))
      IF ((request->oef_list[o].flist[x].fld_list[f].flex_display=" "))
       SET default_value = fillstring(100," ")
      ELSE
       SET default_value = concat("~",request->oef_list[o].flist[x].fld_list[f].flex_display)
      ENDIF
      SET default_parent_entity_name = "PERSON      "
      SET default_parent_entity_id = request->oef_list[o].flist[x].fld_list[f].flex_value
     ELSEIF ((request->oef_list[o].flist[x].fld_list[f].field_type=11))
      IF ((request->oef_list[o].flist[x].fld_list[f].flex_value > 0))
       SET default_value = cnvtstring(request->oef_list[o].flist[x].fld_list[f].flex_value)
      ELSE
       SET default_value = " "
      ENDIF
      SET default_parent_entity_name = fillstring(32," ")
      SET default_parent_entity_id = 0.0
     ELSE
      SET default_value = request->oef_list[o].flist[x].fld_list[f].flex_display
      SET default_parent_entity_name = fillstring(32," ")
      SET default_parent_entity_id = 0.0
     ENDIF
     INSERT  FROM accept_format_flexing aff
      SET aff.oe_format_id = request->oef_list[o].oe_format_id, aff.oe_field_id = request->oef_list[o
       ].flist[x].fld_list[f].field_id, aff.action_type_cd = request->oef_list[o].action_type_cd,
       aff.flex_type_flag = request->oef_list[o].flex_type_flag, aff.flex_cd = request->oef_list[o].
       flist[x].code_value, aff.accept_flag = request->oef_list[o].flist[x].fld_list[f].
       flex_accept_flag,
       aff.lock_on_modify_flag = request->oef_list[o].flist[x].fld_list[f].flex_lock_on_modify_flag,
       aff.carry_fwd_plan_ind = request->oef_list[o].flist[x].fld_list[f].flex_carry_fwd_plan_ind,
       aff.default_value = default_value,
       aff.updt_cnt = 0, aff.updt_dt_tm = cnvtdatetime(curdate,curtime), aff.updt_id = reqinfo->
       updt_id,
       aff.updt_task = reqinfo->updt_task, aff.updt_applctx = reqinfo->updt_applctx, aff
       .default_parent_entity_name = default_parent_entity_name,
       aff.default_parent_entity_id = default_parent_entity_id, aff.flex_parent_entity_name = null,
       aff.flex_parent_entity_id = 0.0
      WITH nocounter
     ;end insert
    ENDFOR
  ENDFOR
 ENDFOR
#exit_script
 IF (oef_cnt > 0)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 CALL echorecord(reply)
END GO
