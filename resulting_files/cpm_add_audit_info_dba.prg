CREATE PROGRAM cpm_add_audit_info:dba
 DECLARE next_nbr = f8
 SELECT INTO "nl:"
  y = seq(cpmprocess_que_seq,nextval)"##################;rp0"
  FROM dual
  DETAIL
   next_nbr = cnvtreal(y)
  WITH nocounter
 ;end select
 DECLARE info_name = c255
 DECLARE info_char = c255
 DECLARE eventcnt = i4
 DECLARE partcnt = i4
 SET eventcnt = size(request->event_list,5)
 IF (size(trim(request->context)) <= 0)
  SET request->context = "|||||"
 ENDIF
 IF (eventcnt <= 0)
  SET info_name = build(request->context,request->network_acc_id,"|||",next_nbr,"|")
  INSERT  FROM dm_info t
   SET t.info_domain = "AUDIT_EVENT_LOG", t.info_name = info_name, t.info_date = cnvtdatetime(request
     ->event_dt_tm),
    t.info_char = "||||||", t.info_long_id = request->prsnl_id, t.updt_dt_tm = cnvtdatetime(sysdate),
    t.updt_cnt = 0, t.updt_id = reqinfo->updt_id, t.updt_task = reqinfo->updt_task,
    t.updt_applctx = reqinfo->updt_applctx
   WITH nocounter
  ;end insert
  IF (curqual=0)
   GO TO exit_script
  ENDIF
 ELSE
  FOR (e = 1 TO eventcnt)
   SET partcnt = size(request->event_list[e].participants,5)
   IF (partcnt <= 0)
    SET info_name = build(request->context,request->network_acc_id,"|",e,"||",
     next_nbr,"|")
    INSERT  FROM dm_info t
     SET t.info_domain = "AUDIT_EVENT_LOG", t.info_name = info_name, t.info_date = cnvtdatetime(
       request->event_dt_tm),
      t.info_char = concat(request->event_list[e].event_name,"|",request->event_list[e].event_type,
       "|||||"), t.info_long_id = request->prsnl_id, t.updt_dt_tm = cnvtdatetime(sysdate),
      t.updt_cnt = 0, t.updt_id = reqinfo->updt_id, t.updt_task = reqinfo->updt_task,
      t.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     GO TO exit_script
    ENDIF
   ELSE
    FOR (p = 1 TO partcnt)
      SET info_char = fillstring(255," ")
      SET info_char = concat(request->event_list[e].event_name,"|",request->event_list[e].event_type,
       "|",request->event_list[e].participants[p].participant_type,
       "|",request->event_list[e].participants[p].participant_role_cd,"|",request->event_list[e].
       participants[p].participant_id_type,"|",
       request->event_list[e].participants[p].data_life_cycle,"|")
      SET info_name = build(request->context,request->network_acc_id,"|",e,"|",
       p,"|",next_nbr,"|")
      INSERT  FROM dm_info t
       SET t.info_domain = "AUDIT_EVENT_LOG", t.info_name = info_name, t.info_date = cnvtdatetime(
         request->event_dt_tm),
        t.info_char = info_char, t.info_number = request->event_list[e].participants[p].
        participant_id, t.info_long_id = request->prsnl_id,
        t.updt_dt_tm = cnvtdatetime(sysdate), t.updt_cnt = 0, t.updt_id = reqinfo->updt_id,
        t.updt_task = reqinfo->updt_task, t.updt_applctx = reqinfo->updt_applctx
       WITH nocounter
      ;end insert
      IF (curqual=0)
       GO TO exit_script
      ENDIF
    ENDFOR
   ENDIF
  ENDFOR
 ENDIF
#exit_script
 COMMIT
END GO
