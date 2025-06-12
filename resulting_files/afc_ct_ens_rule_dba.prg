CREATE PROGRAM afc_ct_ens_rule:dba
 DECLARE afc_ct_ens_rule_version = vc WITH private, noconstant("318193.FT.001")
 RECORD reply(
   1 rule_cnt = i4
   1 rules[*]
     2 rule_id = f8
     2 long_text_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE icnt = i4 WITH public, noconstant(0)
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 SET stat = alterlist(reply->rules,size(request->rules,5))
 SET reply->rule_cnt = size(reply->rules,5)
 FOR (icnt = 1 TO reply->rule_cnt)
   SET reply->rules[icnt].rule_id = - (1)
   SET reply->rules[icnt].long_text_id = - (1)
   IF ((request->rules[icnt].active_ind != 0))
    IF ((request->rules[icnt].rule_id=0))
     SELECT INTO "nl:"
      next_seq = seq(long_data_seq,nextval)"###############;rp0"
      FROM dual
      DETAIL
       reply->rules[icnt].long_text_id = next_seq
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      next_seq = seq(pft_ref_seq,nextval)"###############;rp0"
      FROM dual
      DETAIL
       reply->rules[icnt].rule_id = next_seq
      WITH nocounter
     ;end select
     IF ((reply->rules[icnt].long_text_id != 0))
      INSERT  FROM long_text_reference l
       SET l.long_text_id = reply->rules[icnt].long_text_id, l.long_text = request->rules[icnt].
        long_text
       WITH nocounter
      ;end insert
     ENDIF
     IF ((reply->rules[icnt].rule_id != 0))
      INSERT  FROM cs_cpp_rule r
       SET r.cs_cpp_rule_id = reply->rules[icnt].rule_id, r.cs_cpp_ruleset_id = request->rules[icnt].
        ruleset_id, r.rule_name = request->rules[icnt].rule_name,
        r.long_text_id = reply->rules[icnt].long_text_id, r.priority_nbr = request->rules[icnt].
        priority_nbr, r.process_ind = request->rules[icnt].process_ind,
        r.charge_status_ind = request->rules[icnt].charge_status_ind, r.rule_beg_dt_tm = cnvtdatetime
        (curdate,curtime3), r.rule_end_dt_tm = cnvtdatetime("31-DEC-2100 23:59:59"),
        r.active_ind = 1, r.updt_cnt = 1, r.updt_id = reqinfo->updt_id,
        r.updt_dt_tm = cnvtdatetime(curdate,curtime3), r.updt_task = reqinfo->updt_task, r
        .updt_applctx = reqinfo->updt_applctx
       WITH nocounter
      ;end insert
     ENDIF
    ELSE
     IF ((request->rules[icnt].long_text != "-1"))
      UPDATE  FROM long_text_reference l
       SET l.long_text = request->rules[icnt].long_text
       WHERE (l.long_text_id=request->rules[icnt].long_text_id)
       WITH nocounter
      ;end update
     ENDIF
     UPDATE  FROM cs_cpp_rule r
      SET r.cs_cpp_ruleset_id = request->rules[icnt].ruleset_id, r.rule_name =
       IF ((request->rules[icnt].rule_name="-1")) r.rule_name
       ELSE request->rules[icnt].rule_name
       ENDIF
       , r.long_text_id =
       IF ((request->rules[icnt].long_text_id=- (1))) r.long_text_id
       ELSE request->rules[icnt].long_text_id
       ENDIF
       ,
       r.priority_nbr =
       IF ((request->rules[icnt].priority_nbr=- (1))) r.priority_nbr
       ELSE request->rules[icnt].priority_nbr
       ENDIF
       , r.process_ind =
       IF ((request->rules[icnt].process_ind=- (1))) r.process_ind
       ELSE request->rules[icnt].process_ind
       ENDIF
       , r.rule_beg_dt_tm =
       IF ((request->rules[icnt].rule_beg_dt_tm=0)) r.rule_beg_dt_tm
       ELSE cnvtdatetime(request->rules[icnt].rule_beg_dt_tm)
       ENDIF
       ,
       r.rule_end_dt_tm =
       IF ((request->rules[icnt].rule_end_dt_tm=0)) r.rule_end_dt_tm
       ELSE cnvtdatetime(request->rules[icnt].rule_end_dt_tm)
       ENDIF
       , r.charge_status_ind =
       IF ((request->rules[icnt].charge_status_ind=- (1))) r.charge_status_ind
       ELSE request->rules[icnt].charge_status_ind
       ENDIF
       , r.active_ind = 1,
       r.updt_cnt = 1, r.updt_id = reqinfo->updt_id, r.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       r.updt_task = reqinfo->updt_task, r.updt_applctx = reqinfo->updt_applctx
      WHERE (r.cs_cpp_rule_id=request->rules[icnt].rule_id)
      WITH nocounter
     ;end update
     SET reply->rules[icnt].rule_id = request->rules[icnt].rule_id
     SET reply->rules[icnt].long_text_id = request->rules[icnt].long_text_id
    ENDIF
   ELSE
    UPDATE  FROM long_text_reference l
     SET l.active_ind = 0, l.active_status_dt_tm = cnvtdatetime(curdate,curtime3)
     WHERE (l.long_text_id=request->rules[icnt].long_text_id)
     WITH nocounter
    ;end update
    UPDATE  FROM cs_cpp_rule r
     SET r.active_ind = 0
     WHERE (r.cs_cpp_rule_id=request->rules[icnt].rule_id)
     WITH nocounter
    ;end update
    SET reply->rules[icnt].rule_id = request->rules[icnt].rule_id
    SET reply->rules[icnt].long_text_id = request->rules[icnt].long_text_id
   ENDIF
 ENDFOR
 SET v_errmsg2 = fillstring(132," ")
 SET v_err_code2 = 0
 SET v_err_code2 = error(v_errmsg2,1)
 IF (v_err_code2=0)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.subeventstatus[1].targetobjectname = cnvtstring(v_err_code2)
  SET reply->status_data.subeventstatus[1].targetobjectvalue = v_errmsg2
 ENDIF
END GO
