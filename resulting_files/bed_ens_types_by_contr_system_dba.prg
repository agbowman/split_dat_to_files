CREATE PROGRAM bed_ens_types_by_contr_system:dba
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD new_segs(
   1 segments[*]
     2 name = vc
     2 required_ind = i2
 )
 RECORD delete_segs(
   1 segments[*]
     2 id = f8
 )
 RECORD update_segs(
   1 segments[*]
     2 id = f8
     2 required_ind = i2
 )
 RECORD current_types(
   1 types[*]
     2 interface_type_id = f8
     2 interface_type = vc
     2 in_out_ind = i2
     2 segments[*]
       3 segment = vc
 )
 RECORD current_sets(
   1 sets[*]
     2 id = f8
     2 segment = vc
     2 code_set = i4
     2 delete_ind = i2
 )
 SET reply->status_data.status = "F"
 DECLARE error_msg = vc
 SET error_flag = "N"
 SET hold_br_name_value_id = 0.0
 SELECT INTO "NL:"
  FROM br_name_value b
  WHERE b.br_nv_key1="ALIAS_REG_QUESTION"
   AND b.br_name=cnvtstring(request->contributor_system_code_value)
  DETAIL
   hold_br_name_value_id = b.br_name_value_id
  WITH nocounter
 ;end select
 IF (hold_br_name_value_id > 0.0)
  UPDATE  FROM br_name_value b
   SET b.br_value = cnvtstring(request->reply_to_reg_question), b.updt_cnt = (b.updt_cnt+ 1), b
    .updt_dt_tm = cnvtdatetime(curdate,curtime3),
    b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->
    updt_applctx
   WHERE b.br_name_value_id=hold_br_name_value_id
   WITH nocounter
  ;end update
 ELSE
  INSERT  FROM br_name_value b
   SET b.br_name_value_id = seq(bedrock_seq,nextval), b.br_nv_key1 = "ALIAS_REG_QUESTION", b.br_name
     = cnvtstring(request->contributor_system_code_value),
    b.br_value = cnvtstring(request->reply_to_reg_question), b.updt_cnt = 0, b.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->
    updt_applctx
   WITH nocounter
  ;end insert
 ENDIF
 IF (curqual=0)
  SET error_flag = "Y"
  SET error_msg = "Unable to update into br_name_value"
  GO TO exit_script
 ENDIF
 SET tcnt = 0
 SET tcnt = size(request->types,5)
 FOR (t = 1 TO tcnt)
   IF ((request->types[t].action_flag=1))
    INSERT  FROM br_contr_type_r b
     SET b.br_contr_type_r_id = seq(bedrock_seq,nextval), b.contributor_system_cd = request->
      contributor_system_code_value, b.interface_type = substring(1,60,request->types[t].
       interface_type),
      b.in_out_flg = request->types[t].in_out_ind, b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(
       curdate,curtime3),
      b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->
      updt_applctx
     WITH nocounter
    ;end insert
   ELSEIF ((request->types[t].action_flag=2))
    IF ((request->types[t].in_out_ind != 3))
     SET current_direction = 0
     SELECT INTO "NL:"
      FROM br_contr_type_r b
      WHERE (b.br_contr_type_r_id=request->types[t].interface_type_id)
      DETAIL
       current_direction = b.in_out_flg
      WITH nocounter
     ;end select
     SET scnt = 0
     IF ((request->types[t].in_out_ind=1))
      SELECT INTO "NL:"
       FROM br_type_seg_r b
       WHERE (b.interface_type=request->types[t].interface_type)
        AND b.inbound_ind=1
       DETAIL
        scnt = (scnt+ 1), stat = alterlist(new_segs->segments,scnt), new_segs->segments[scnt].name =
        b.segment_name,
        new_segs->segments[scnt].required_ind = b.required_ind
       WITH nocounter
      ;end select
     ELSE
      SELECT INTO "NL:"
       FROM br_type_seg_r b
       WHERE (b.interface_type=request->types[t].interface_type)
        AND b.outbound_ind=1
       DETAIL
        scnt = (scnt+ 1), stat = alterlist(new_segs->segments,scnt), new_segs->segments[scnt].name =
        b.segment_name,
        new_segs->segments[scnt].required_ind = b.required_ind
       WITH nocounter
      ;end select
     ENDIF
     SET dcnt = 0
     SET ucnt = 0
     SELECT INTO "NL:"
      FROM br_contr_seg_r b
      WHERE (b.br_contr_type_r_id=request->types[t].interface_type_id)
      DETAIL
       found_ind = 0, new_seg_required_ind = 0
       FOR (s = 1 TO scnt)
         IF ((b.segment_name=new_segs->segments[s].name))
          found_ind = 1, new_seg_required_ind = new_segs->segments[s].required_ind, s = (scnt+ 1)
         ENDIF
       ENDFOR
       IF (found_ind=0)
        dcnt = (dcnt+ 1), stat = alterlist(delete_segs->segments,dcnt), delete_segs->segments[dcnt].
        id = b.br_contr_seg_r_id
       ENDIF
       IF (found_ind=1
        AND b.required_ind != new_seg_required_ind)
        ucnt = (ucnt+ 1), stat = alterlist(update_segs->segments,ucnt), update_segs->segments[ucnt].
        id = b.br_contr_seg_r_id,
        update_segs->segments[ucnt].required_ind = new_seg_required_ind
       ENDIF
      WITH nocounter
     ;end select
     FOR (d = 1 TO dcnt)
       DELETE  FROM br_contr_seg_r b
        WHERE (b.br_contr_seg_r_id=delete_segs->segments[d].id)
        WITH nocounter
       ;end delete
     ENDFOR
     FOR (u = 1 TO ucnt)
       UPDATE  FROM br_contr_seg_r b
        SET b.required_ind = update_segs->segments[d].required_ind, b.updt_cnt = (b.updt_cnt+ 1), b
         .updt_dt_tm = cnvtdatetime(curdate,curtime3),
         b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->
         updt_applctx
        WHERE (b.br_contr_seg_r_id=update_segs->segments[d].id)
        WITH nocounter
       ;end update
     ENDFOR
    ENDIF
    UPDATE  FROM br_contr_type_r b
     SET b.in_out_flg = request->types[t].in_out_ind, b.updt_cnt = (b.updt_cnt+ 1), b.updt_dt_tm =
      cnvtdatetime(curdate,curtime3),
      b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->
      updt_applctx
     WHERE (b.br_contr_type_r_id=request->types[t].interface_type_id)
     WITH nocounter
    ;end update
   ELSEIF ((request->types[t].action_flag=3))
    DELETE  FROM br_contr_type_r b
     WHERE (b.br_contr_type_r_id=request->types[t].interface_type_id)
     WITH nocounter
    ;end delete
    DELETE  FROM br_contr_seg_r b
     WHERE (b.br_contr_type_r_id=request->types[t].interface_type_id)
     WITH nocounter
    ;end delete
   ENDIF
 ENDFOR
 SET typecnt = 0
 SELECT INTO "NL:"
  FROM br_contr_type_r bt,
   br_contr_seg_r bs
  PLAN (bt
   WHERE (bt.contributor_system_cd=request->contributor_system_code_value))
   JOIN (bs
   WHERE bs.br_contr_type_r_id=bt.br_contr_type_r_id)
  ORDER BY bt.br_contr_type_r_id
  HEAD bt.br_contr_type_r_id
   typecnt = (typecnt+ 1), stat = alterlist(current_types->types,typecnt), current_types->types[
   typecnt].interface_type_id = bt.br_contr_type_r_id,
   current_types->types[typecnt].interface_type = bt.interface_type, current_types->types[typecnt].
   in_out_ind = bt.in_out_flg, segcnt = 0
  DETAIL
   IF (bs.br_contr_seg_r_id > 0)
    segcnt = (segcnt+ 1), stat = alterlist(current_types->types[typecnt].segments,segcnt),
    current_types->types[typecnt].segments[segcnt].segment = bs.segment_name
   ENDIF
  WITH nocounter
 ;end select
 SET cscnt = 0
 SELECT INTO "NL:"
  FROM br_contr_cs_r b
  WHERE (b.contributor_system_cd=request->contributor_system_code_value)
  DETAIL
   cscnt = (cscnt+ 1), stat = alterlist(current_sets->sets,cscnt), current_sets->sets[cscnt].id = b
   .br_contr_cs_r_id,
   current_sets->sets[cscnt].segment = b.segment_name, current_sets->sets[cscnt].code_set = b.codeset,
   current_sets->sets[cscnt].delete_ind = 1
  WITH nocounter
 ;end select
 FOR (c = 1 TO cscnt)
   FOR (t = 1 TO typecnt)
    SET segcnt = size(current_types->types[t].segments,5)
    FOR (s = 1 TO segcnt)
      IF ((current_sets->sets[c].segment=current_types->types[t].segments[s].segment))
       SELECT INTO "NL:"
        FROM br_type_seg_r bt,
         br_seg_field_r bs
        PLAN (bt
         WHERE (bt.interface_type=current_types->types[t].interface_type)
          AND (bt.segment_name=current_types->types[t].segments[s].segment))
         JOIN (bs
         WHERE bs.br_type_seg_r_id=bt.br_type_seg_r_id)
        DETAIL
         IF ((((current_types->types[t].in_out_ind IN (1, 3))
          AND bt.inbound_ind=1) OR ((current_types->types[t].in_out_ind IN (2, 3))
          AND bt.outbound_ind=1)) )
          IF ((bs.codeset=current_sets->sets[c].code_set))
           current_sets->sets[c].delete_ind = 0
          ENDIF
         ENDIF
        WITH nocounter
       ;end select
       IF ((current_sets->sets[c].delete_ind=0))
        SET s = (segcnt+ 1)
        SET t = (typecnt+ 1)
       ENDIF
      ENDIF
    ENDFOR
   ENDFOR
 ENDFOR
 FOR (c = 1 TO cscnt)
   IF ((current_sets->sets[c].delete_ind=1))
    DELETE  FROM br_contr_cs_r b
     WHERE (b.br_contr_cs_r_id=current_sets->sets[c].id)
    ;end delete
   ENDIF
 ENDFOR
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#exit_script
 CALL echorecord(reply)
END GO
