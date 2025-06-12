CREATE PROGRAM bed_get_oef_fields:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 oe_format_id = f8
    1 action_type_cd = f8
    1 flex_type_flag = i2
    1 catalog_type_cd = f8
    1 catalog_type_display = c40
    1 catalog_type_meaning = c12
    1 flist[*]
      2 flex_param_code_value = f8
      2 flex_param_display = c40
      2 flex_param_mean = c12
      2 fld_list[*]
        3 field_id = f8
        3 field_name = vc
        3 field_label = vc
        3 field_type = i2
        3 field_codeset = i4
        3 default_accept_flag = i2
        3 min_val = f8
        3 max_val = f8
        3 oe_field_meaning = c25
        3 default_display = vc
        3 default_value = f8
        3 default_cdf_meaning = c12
        3 default_plus_days = i2
        3 default_plus_minutes = i2
        3 default_n_ind = i2
        3 flex_accept_flag_ind = i2
        3 flex_accept_flag = i2
        3 flex_default_ind = i2
        3 flex_display = vc
        3 flex_value = f8
        3 flex_cdf_meaning = c12
        3 flex_plus_days = i2
        3 flex_plus_minutes = i2
        3 flex_n_ind = i2
        3 flex_lock_on_modify_flag = i2
        3 flex_carry_fwd_plan_ind = i2
        3 flex_lock_on_modify_flag_ind = i2
        3 default_lock_on_modify_flag = i2
        3 flex_carry_fwd_plan_ind_ind = i2
        3 default_carry_fwd_plan_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE cd_set = i4
 DECLARE cd_value = f8
 DECLARE cd_display = c40
 DECLARE cd_meaning = c12
 SET reply->status_data.status = "F"
 SET flex_cnt = size(request->flex_list,5)
 IF (flex_cnt=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->flist,flex_cnt)
 FOR (f = 1 TO flex_cnt)
   SET reply->oe_format_id = request->oe_format_id
   SET reply->action_type_cd = request->action_type_cd
   SET reply->flex_type_flag = request->flex_type_flag
   SET reply->flist[f].flex_param_code_value = request->flex_list[f].flex_param_code_value
   SELECT INTO "NL:"
    FROM code_value cv
    WHERE (cv.code_value=request->flex_list[f].flex_param_code_value)
    DETAIL
     IF ((((reply->flex_type_flag=0)) OR ((reply->flex_type_flag=1))) )
      reply->flist[f].flex_param_display = cv.description
     ELSE
      reply->flist[f].flex_param_display = cv.display
     ENDIF
     reply->flist[f].flex_param_mean = cv.cdf_meaning
    WITH nocounter
   ;end select
   SELECT INTO "NL:"
    FROM order_entry_format oef,
     code_value cv
    PLAN (oef
     WHERE (oef.oe_format_id=request->oe_format_id)
      AND (oef.action_type_cd=request->action_type_cd))
     JOIN (cv
     WHERE cv.code_value=oef.catalog_type_cd
      AND cv.active_ind=1)
    DETAIL
     reply->catalog_type_cd = cv.code_value, reply->catalog_type_display = cv.display, reply->
     catalog_type_meaning = cv.cdf_meaning
    WITH nocounter
   ;end select
   SET stat = alterlist(reply->flist[f].fld_list,40)
   SET alterlist_cnt = 0
   SET fld_cnt = 0
   SELECT INTO "NL:"
    FROM oe_format_fields off,
     order_entry_fields oef,
     oe_field_meaning ofm
    PLAN (off
     WHERE (off.oe_format_id=request->oe_format_id)
      AND (off.action_type_cd=request->action_type_cd))
     JOIN (oef
     WHERE oef.oe_field_id=off.oe_field_id)
     JOIN (ofm
     WHERE ofm.oe_field_meaning_id=oef.oe_field_meaning_id)
    ORDER BY off.group_seq, off.field_seq
    DETAIL
     alterlist_cnt = (alterlist_cnt+ 1)
     IF (alterlist_cnt > 40)
      stat = alterlist(reply->flist[f].fld_list,(fld_cnt+ 40)), alterlist_cnt = 1
     ENDIF
     fld_cnt = (fld_cnt+ 1), reply->flist[f].fld_list[fld_cnt].field_id = off.oe_field_id, reply->
     flist[f].fld_list[fld_cnt].field_name = oef.description,
     reply->flist[f].fld_list[fld_cnt].field_label = off.label_text, reply->flist[f].fld_list[fld_cnt
     ].field_type = oef.field_type_flag, reply->flist[f].fld_list[fld_cnt].field_codeset = oef
     .codeset,
     reply->flist[f].fld_list[fld_cnt].default_accept_flag = off.accept_flag, reply->flist[f].
     fld_list[fld_cnt].min_val = oef.min_val, reply->flist[f].fld_list[fld_cnt].max_val = oef.max_val,
     reply->flist[f].fld_list[fld_cnt].oe_field_meaning = ofm.oe_field_meaning, reply->flist[f].
     fld_list[fld_cnt].default_lock_on_modify_flag = off.lock_on_modify_flag, reply->flist[f].
     fld_list[fld_cnt].default_carry_fwd_plan_ind = off.carry_fwd_plan_ind
     IF (((oef.field_type_flag=6) OR (((oef.field_type_flag=10) OR (oef.field_type_flag=12)) )) )
      reply->flist[f].fld_list[fld_cnt].default_display = " ", reply->flist[f].fld_list[fld_cnt].
      default_value = off.default_parent_entity_id, reply->flist[f].fld_list[fld_cnt].
      default_cdf_meaning = " "
     ELSEIF (oef.field_type_flag=9)
      IF (off.default_parent_entity_id > 0)
       reply->flist[f].fld_list[fld_cnt].default_display = " ", reply->flist[f].fld_list[fld_cnt].
       default_value = off.default_parent_entity_id, reply->flist[f].fld_list[fld_cnt].
       default_cdf_meaning = " "
      ELSE
       reply->flist[f].fld_list[fld_cnt].default_display = substring(2,99,off.default_value), reply->
       flist[f].fld_list[fld_cnt].default_value = 0.0, reply->flist[f].fld_list[fld_cnt].
       default_cdf_meaning = " "
      ENDIF
     ELSEIF (oef.field_type_flag=8)
      reply->flist[f].fld_list[fld_cnt].default_display = " ", reply->flist[f].fld_list[fld_cnt].
      default_value = 0.0, reply->flist[f].fld_list[fld_cnt].default_cdf_meaning = replace(off
       .default_value,char(126),"",0)
     ELSEIF (oef.field_type_flag=7)
      IF (cnvtupper(off.default_value) IN ("1", "YES", "Y"))
       reply->flist[f].fld_list[fld_cnt].default_display = "1"
      ELSEIF (cnvtupper(off.default_value) IN ("0", "NO", "N"))
       reply->flist[f].fld_list[fld_cnt].default_display = "0"
      ELSE
       reply->flist[f].fld_list[fld_cnt].default_display = off.default_value
      ENDIF
      reply->flist[f].fld_list[fld_cnt].default_value = 0.0, reply->flist[f].fld_list[fld_cnt].
      default_cdf_meaning = " "
     ELSEIF (((oef.field_type_flag=3) OR (oef.field_type_flag=5)) )
      reply->flist[f].fld_list[fld_cnt].default_value = 0.0, reply->flist[f].fld_list[fld_cnt].
      default_cdf_meaning = " "
      IF (substring(1,1,off.default_value)="T")
       reply->flist[f].fld_list[fld_cnt].default_display = off.default_value, t_pos = findstring("T+",
        off.default_value,1,1)
       IF (t_pos > 0)
        semi_pos = findstring(";",off.default_value,t_pos,1), beg_pos = (t_pos+ 2)
        IF (semi_pos > 0)
         end_pos = (semi_pos - 1)
        ELSE
         end_pos = size(off.default_value,1)
        ENDIF
        len = ((end_pos - beg_pos)+ 1), reply->flist[f].fld_list[fld_cnt].default_plus_days = cnvtint
        (substring(beg_pos,len,off.default_value))
       ELSE
        reply->flist[f].fld_list[fld_cnt].default_plus_days = 0
       ENDIF
       n_pos = findstring("N",off.default_value,1,1)
       IF (n_pos > 0)
        reply->flist[f].fld_list[fld_cnt].default_n_ind = 1, n_pos = findstring("N+",off
         .default_value,1,1)
        IF (n_pos > 0)
         beg_pos = (n_pos+ 2), end_pos = size(off.default_value,1), len = ((end_pos - beg_pos)+ 1),
         reply->flist[f].fld_list[fld_cnt].default_plus_minutes = cnvtint(substring(beg_pos,len,off
           .default_value))
        ELSE
         reply->flist[f].fld_list[fld_cnt].default_plus_minutes = 0
        ENDIF
       ELSE
        reply->flist[f].fld_list[fld_cnt].default_plus_minutes = 0, reply->flist[f].fld_list[fld_cnt]
        .default_n_ind = 0
       ENDIF
      ELSE
       reply->flist[f].fld_list[fld_cnt].default_display = " ", reply->flist[f].fld_list[fld_cnt].
       default_plus_days = 0, reply->flist[f].fld_list[fld_cnt].default_plus_minutes = 0,
       reply->flist[f].fld_list[fld_cnt].default_n_ind = 0
      ENDIF
     ELSE
      IF (oef.field_type_flag=13)
       reply->flist[f].fld_list[fld_cnt].default_display = substring(2,99,off.default_value)
      ELSE
       reply->flist[f].fld_list[fld_cnt].default_display = off.default_value
      ENDIF
      reply->flist[f].fld_list[fld_cnt].default_value = 0.0, reply->flist[f].fld_list[fld_cnt].
      default_cdf_meaning = " "
     ENDIF
     reply->flist[f].fld_list[fld_cnt].flex_accept_flag_ind = 0, reply->flist[f].fld_list[fld_cnt].
     flex_default_ind = 0, reply->flist[f].fld_list[fld_cnt].flex_lock_on_modify_flag_ind = off
     .lock_on_modify_flag,
     reply->flist[f].fld_list[fld_cnt].flex_lock_on_modify_flag = off.lock_on_modify_flag, reply->
     flist[f].fld_list[fld_cnt].flex_carry_fwd_plan_ind = off.carry_fwd_plan_ind
     IF (off.carry_fwd_plan_ind=0)
      reply->flist[f].fld_list[fld_cnt].flex_carry_fwd_plan_ind_ind = 1
     ELSE
      reply->flist[f].fld_list[fld_cnt].flex_carry_fwd_plan_ind_ind = 0
     ENDIF
    WITH nocounter
   ;end select
   SET stat = alterlist(reply->flist[f].fld_list,fld_cnt)
   IF (fld_cnt > 0)
    SELECT INTO "NL:"
     FROM (dummyt d  WITH seq = fld_cnt),
      accept_format_flexing aff
     PLAN (d
      WHERE (reply->flist[f].fld_list[d.seq].field_id > 0))
      JOIN (aff
      WHERE (aff.oe_format_id=request->oe_format_id)
       AND (aff.oe_field_id=reply->flist[f].fld_list[d.seq].field_id)
       AND (aff.action_type_cd=request->action_type_cd)
       AND (aff.flex_cd=request->flex_list[f].flex_param_code_value)
       AND (aff.flex_type_flag=request->flex_type_flag))
     DETAIL
      reply->flist[f].fld_list[d.seq].flex_accept_flag = aff.accept_flag
      IF ((reply->flist[f].fld_list[d.seq].flex_accept_flag != reply->flist[f].fld_list[d.seq].
      default_accept_flag))
       reply->flist[f].fld_list[d.seq].flex_accept_flag_ind = 1
      ENDIF
      reply->flist[f].fld_list[d.seq].flex_lock_on_modify_flag = aff.lock_on_modify_flag, reply->
      flist[f].fld_list[d.seq].flex_lock_on_modify_flag_ind = aff.lock_on_modify_flag, reply->flist[f
      ].fld_list[d.seq].flex_carry_fwd_plan_ind = aff.carry_fwd_plan_ind
      IF (aff.carry_fwd_plan_ind=0)
       reply->flist[f].fld_list[d.seq].flex_carry_fwd_plan_ind_ind = 1
      ELSE
       reply->flist[f].fld_list[d.seq].flex_carry_fwd_plan_ind_ind = 0
      ENDIF
      IF ((((reply->flist[f].fld_list[d.seq].field_type=6)) OR ((((reply->flist[f].fld_list[d.seq].
      field_type=10)) OR ((reply->flist[f].fld_list[d.seq].field_type=12))) )) )
       reply->flist[f].fld_list[d.seq].flex_display = " ", reply->flist[f].fld_list[d.seq].flex_value
        = aff.default_parent_entity_id, reply->flist[f].fld_list[d.seq].flex_cdf_meaning = " "
       IF ((reply->flist[f].fld_list[d.seq].flex_value != reply->flist[f].fld_list[d.seq].
       default_value))
        reply->flist[f].fld_list[d.seq].flex_default_ind = 1
       ENDIF
      ELSEIF ((reply->flist[f].fld_list[d.seq].field_type=9))
       IF (aff.default_parent_entity_id > 0)
        reply->flist[f].fld_list[d.seq].flex_display = " ", reply->flist[f].fld_list[d.seq].
        flex_value = aff.default_parent_entity_id, reply->flist[f].fld_list[d.seq].flex_cdf_meaning
         = " "
       ELSE
        reply->flist[f].fld_list[d.seq].flex_display = substring(2,99,aff.default_value), reply->
        flist[f].fld_list[d.seq].flex_value = 0.0, reply->flist[f].fld_list[d.seq].flex_cdf_meaning
         = " "
       ENDIF
       IF ((((reply->flist[f].fld_list[d.seq].flex_value != reply->flist[f].fld_list[d.seq].
       default_value)) OR ((reply->flist[f].fld_list[d.seq].flex_display != reply->flist[f].fld_list[
       d.seq].default_display))) )
        reply->flist[f].fld_list[d.seq].flex_default_ind = 1
       ENDIF
      ELSEIF ((reply->flist[f].fld_list[d.seq].field_type=8))
       reply->flist[f].fld_list[d.seq].flex_display = substring(2,99,aff.default_value), reply->
       flist[f].fld_list[d.seq].flex_value = aff.default_parent_entity_id, reply->flist[f].fld_list[d
       .seq].flex_cdf_meaning = substring(2,99,aff.default_value)
       IF ((reply->flist[f].fld_list[d.seq].flex_cdf_meaning != reply->flist[f].fld_list[d.seq].
       default_cdf_meaning))
        reply->flist[f].fld_list[d.seq].flex_default_ind = 1
       ENDIF
      ELSEIF ((reply->flist[f].fld_list[d.seq].field_type=7))
       IF (cnvtupper(aff.default_value) IN ("1", "YES", "Y"))
        reply->flist[f].fld_list[d.seq].flex_display = "1"
       ELSEIF (cnvtupper(aff.default_value) IN ("0", "NO", "N"))
        reply->flist[f].fld_list[d.seq].flex_display = "0"
       ELSE
        reply->flist[f].fld_list[d.seq].flex_display = aff.default_value
       ENDIF
       reply->flist[f].fld_list[d.seq].flex_value = 0.0, reply->flist[f].fld_list[d.seq].
       flex_cdf_meaning = " "
       IF ((reply->flist[f].fld_list[d.seq].flex_display != reply->flist[f].fld_list[d.seq].
       default_display))
        reply->flist[f].fld_list[d.seq].flex_default_ind = 1
       ENDIF
      ELSEIF ((((reply->flist[f].fld_list[d.seq].field_type=3)) OR ((reply->flist[f].fld_list[d.seq].
      field_type=5))) )
       reply->flist[f].fld_list[d.seq].flex_value = 0.0, reply->flist[f].fld_list[d.seq].
       flex_cdf_meaning = " "
       IF (substring(1,1,aff.default_value)="T")
        reply->flist[f].fld_list[d.seq].flex_display = aff.default_value, t_pos = findstring("T+",aff
         .default_value,1,1)
        IF (t_pos > 0)
         semi_pos = findstring(";",aff.default_value,t_pos,1), beg_pos = (t_pos+ 2)
         IF (semi_pos > 0)
          end_pos = (semi_pos - 1)
         ELSE
          end_pos = size(aff.default_value,1)
         ENDIF
         len = ((end_pos - beg_pos)+ 1), reply->flist[f].fld_list[d.seq].flex_plus_days = cnvtint(
          substring(beg_pos,len,aff.default_value))
        ELSE
         reply->flist[f].fld_list[d.seq].flex_plus_days = 0
        ENDIF
        n_pos = findstring("N",aff.default_value,1,1)
        IF (n_pos > 0)
         reply->flist[f].fld_list[d.seq].flex_n_ind = 1, n_pos = findstring("N+",aff.default_value,1,
          1)
         IF (n_pos > 0)
          beg_pos = (n_pos+ 2), end_pos = size(aff.default_value,1), len = ((end_pos - beg_pos)+ 1),
          reply->flist[f].fld_list[d.seq].flex_plus_minutes = cnvtint(substring(beg_pos,len,aff
            .default_value))
         ELSE
          reply->flist[f].fld_list[d.seq].flex_plus_minutes = 0
         ENDIF
        ELSE
         reply->flist[f].fld_list[d.seq].flex_plus_minutes = 0, reply->flist[f].fld_list[d.seq].
         flex_n_ind = 0
        ENDIF
       ELSE
        reply->flist[f].fld_list[d.seq].flex_display = " ", reply->flist[f].fld_list[d.seq].
        flex_plus_days = 0, reply->flist[f].fld_list[d.seq].flex_plus_minutes = 0,
        reply->flist[f].fld_list[d.seq].flex_n_ind = 0
       ENDIF
       IF ((reply->flist[f].fld_list[d.seq].flex_display != reply->flist[f].fld_list[d.seq].
       default_display))
        reply->flist[f].fld_list[d.seq].flex_default_ind = 1
       ENDIF
      ELSEIF ((reply->flist[f].fld_list[d.seq].field_type=11))
       reply->flist[f].fld_list[d.seq].flex_value = cnvtreal(aff.default_value), reply->flist[f].
       fld_list[d.seq].flex_display = " ", reply->flist[f].fld_list[d.seq].flex_cdf_meaning = " "
      ELSE
       IF ((reply->flist[f].fld_list[d.seq].field_type=13))
        reply->flist[f].fld_list[d.seq].flex_display = substring(2,99,aff.default_value)
       ELSE
        reply->flist[f].fld_list[d.seq].flex_display = aff.default_value
       ENDIF
       reply->flist[f].fld_list[d.seq].flex_value = 0.0, reply->flist[f].fld_list[d.seq].
       flex_cdf_meaning = " "
       IF ((reply->flist[f].fld_list[d.seq].flex_display != reply->flist[f].fld_list[d.seq].
       default_display))
        reply->flist[f].fld_list[d.seq].flex_default_ind = 1
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   FOR (x = 1 TO fld_cnt)
     IF ((((reply->flist[f].fld_list[x].field_type=6)) OR ((((reply->flist[f].fld_list[x].field_type=
     9)) OR ((reply->flist[f].fld_list[x].field_type=12))) )) )
      IF ((reply->flist[f].fld_list[x].default_value > 0.0))
       SELECT INTO "NL:"
        FROM code_value cv
        WHERE (cv.code_set=reply->flist[f].fld_list[x].field_codeset)
         AND (cv.code_value=reply->flist[f].fld_list[x].default_value)
        DETAIL
         reply->flist[f].fld_list[x].default_display = cv.display, reply->flist[f].fld_list[x].
         default_cdf_meaning = cv.cdf_meaning
        WITH nocounter
       ;end select
      ENDIF
      IF ((reply->flist[f].fld_list[x].flex_value > 0.0))
       SELECT INTO "NL:"
        FROM code_value cv
        WHERE (cv.code_set=reply->flist[f].fld_list[x].field_codeset)
         AND (cv.code_value=reply->flist[f].fld_list[x].flex_value)
        DETAIL
         reply->flist[f].fld_list[x].flex_display = cv.display, reply->flist[f].fld_list[x].
         flex_cdf_meaning = cv.cdf_meaning
        WITH nocounter
       ;end select
      ENDIF
     ELSEIF ((reply->flist[f].fld_list[x].field_type=10))
      IF ((reply->flist[f].fld_list[x].default_value > 0.0))
       SELECT INTO "NL:"
        FROM nomenclature n
        WHERE (n.nomenclature_id=reply->flist[f].fld_list[x].default_value)
        DETAIL
         reply->flist[f].fld_list[x].default_display = n.source_string
        WITH nocounter
       ;end select
      ENDIF
      IF ((reply->flist[f].fld_list[x].flex_value > 0.0))
       SELECT INTO "NL:"
        FROM nomenclature n
        WHERE (n.nomenclature_id=reply->flist[f].fld_list[x].flex_value)
        DETAIL
         reply->flist[f].fld_list[x].flex_display = n.source_string
        WITH nocounter
       ;end select
      ENDIF
     ELSEIF ((reply->flist[f].fld_list[x].field_type=8))
      IF ((reply->flist[f].fld_list[x].default_cdf_meaning > " "))
       SELECT INTO "NL:"
        FROM code_value cv
        WHERE cv.code_set=333
         AND (cv.cdf_meaning=reply->flist[f].fld_list[x].default_cdf_meaning)
        DETAIL
         reply->flist[f].fld_list[x].default_display = cv.display, reply->flist[f].fld_list[x].
         default_value = cv.code_value
        WITH nocounter
       ;end select
      ENDIF
      IF ((reply->flist[f].fld_list[x].flex_cdf_meaning > " "))
       SELECT INTO "NL:"
        FROM code_value cv
        WHERE cv.code_set=333
         AND (cv.cdf_meaning=reply->flist[f].fld_list[x].flex_cdf_meaning)
        DETAIL
         reply->flist[f].fld_list[x].flex_display = cv.display, reply->flist[f].fld_list[x].
         flex_value = cv.code_value
        WITH nocounter
       ;end select
      ENDIF
     ELSEIF ((reply->flist[f].fld_list[x].field_type=11))
      IF ((reply->flist[f].fld_list[x].flex_value > 0))
       SELECT INTO "NL:"
        FROM output_dest od
        WHERE (od.output_dest_cd=reply->flist[f].fld_list[x].flex_value)
        DETAIL
         IF (od.description > " ")
          reply->flist[f].fld_list[x].flex_display = od.description
         ELSE
          reply->flist[f].fld_list[x].flex_display = od.name
         ENDIF
        WITH nocounter
       ;end select
       IF ((reply->flist[f].fld_list[x].flex_display != reply->flist[f].fld_list[x].default_display))
        SET reply->flist[f].fld_list[x].flex_default_ind = 1
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
 ENDFOR
#exit_script
 IF (flex_cnt > 0)
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
