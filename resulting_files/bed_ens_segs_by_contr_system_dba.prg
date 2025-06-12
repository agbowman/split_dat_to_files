CREATE PROGRAM bed_ens_segs_by_contr_system:dba
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
 SET tcnt = 0
 SET tcnt = size(request->types,5)
 FOR (t = 1 TO tcnt)
   SET scnt = size(request->types[t].segments,5)
   FOR (s = 1 TO scnt)
     IF ((request->types[t].segments[s].action_flag=1))
      INSERT  FROM br_contr_seg_r b
       SET b.br_contr_seg_r_id = seq(bedrock_seq,nextval), b.br_contr_type_r_id = request->types[t].
        interface_type_id, b.segment_name = request->types[t].segments[s].segment,
        b.required_ind = request->types[t].segments[s].required_ind, b.updt_cnt = 0, b.updt_dt_tm =
        cnvtdatetime(curdate,curtime3),
        b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->
        updt_applctx
       WITH nocounter
      ;end insert
     ELSEIF ((request->types[t].segments[s].action_flag=3))
      DELETE  FROM br_contr_seg_r b
       WHERE (b.br_contr_type_r_id=request->types[t].interface_type_id)
        AND (b.segment_name=request->types[t].segments[s].segment)
       WITH nocounter
      ;end delete
     ENDIF
   ENDFOR
   SET acnt = size(request->types[t].activity_types,5)
   FOR (a = 1 TO acnt)
     IF ((request->types[t].activity_types[a].action_flag=1))
      INSERT  FROM br_contr_act_r b
       SET b.br_contr_act_r_id = seq(bedrock_seq,nextval), b.br_contr_type_r_id = request->types[t].
        interface_type_id, b.activity_type_cd = request->types[t].activity_types[a].code_value,
        b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id,
        b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx
       WITH nocounter
      ;end insert
     ELSEIF ((request->types[t].activity_types[a].action_flag=3))
      DELETE  FROM br_contr_act_r b
       WHERE (b.br_contr_type_r_id=request->types[t].interface_type_id)
        AND (b.activity_type_cd=request->types[t].activity_types[a].code_value)
       WITH nocounter
      ;end delete
     ENDIF
   ENDFOR
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
