CREATE PROGRAM dm_stat_user_experience_other:dba
 IF ( NOT (validate(dsr,0)))
  RECORD dsr(
    1 qual[*]
      2 stat_snap_dt_tm = dq8
      2 snapshot_type = c100
      2 client_mnemonic = c10
      2 domain_name = c20
      2 node_name = c30
      2 qual[*]
        3 stat_name = vc
        3 stat_seq = i4
        3 stat_str_val = vc
        3 stat_type = i4
        3 stat_number_val = f8
        3 stat_date_val = dq8
        3 stat_clob_val = vc
  )
 ENDIF
 DECLARE esmerror(msg=vc,ret=i2) = i2
 DECLARE esmcheckccl(z=vc) = i2
 DECLARE esmdate = f8
 DECLARE esmmsg = c196
 DECLARE esmcategory = c128
 DECLARE esmerrorcnt = i2
 SET esmexit = 0
 SET esmreturn = 1
 SET esmerrorcnt = 0
 SUBROUTINE esmerror(msg,ret)
   SET esmerrorcnt = (esmerrorcnt+ 1)
   IF (esmerrorcnt <= 3)
    SET esmdate = cnvtdatetime(curdate,curtime3)
    SET esmmsg = fillstring(196," ")
    SET esmmsg = substring(1,195,msg)
    SET esmcategory = fillstring(128," ")
    SET esmcategory = curprog
    EXECUTE dm_stat_error esmdate, esmmsg, esmcategory
    CALL echo(msg)
    CALL esmcheckccl("x")
   ELSE
    GO TO exit_program
   ENDIF
   IF (ret=esmexit)
    GO TO exit_program
   ENDIF
   SET esmerrorcnt = 0
   RETURN(esmreturn)
 END ;Subroutine
 SUBROUTINE esmcheckccl(z)
   SET cclerrmsg = fillstring(132," ")
   SET cclerrcode = error(cclerrmsg,0)
   IF (cclerrcode != 0)
    SET execrc = 1
    CALL esmerror(cclerrmsg,esmexit)
   ENDIF
   RETURN(esmreturn)
 END ;Subroutine
 DECLARE qualcnt = i4
 DECLARE ds_begin_snapshot = f8
 DECLARE ds_end_snapshot = f8
 DECLARE ds_cnt = i4 WITH protect, noconstant(0)
 DECLARE mn_powerplan_action_val = f8
 DECLARE entry_mode_review_val = f8
 DECLARE entry_mode_sign_val = f8
 DECLARE entry_mode_endorse_val = f8
 DECLARE event_cd_mdoc = f8
 DECLARE event_cd_doc = f8
 DECLARE event_cd_rad = f8
 DECLARE event_cd_txt = f8
 DECLARE event_cd_num = f8
 DECLARE event_cd_date = f8
 DECLARE event_cd_done = f8
 DECLARE event_cd_grp = f8
 DECLARE stat_seq = f8
 DECLARE completed_cd = f8
 DECLARE refused_cd = f8
 DECLARE requested_cd = f8
 DECLARE allergies_active_cd = f8
 DECLARE clin_notes_cd = f8
 DECLARE sign_action_cd = f8
 DECLARE powernote_cd = f8
 DECLARE powernoted_cd = f8
 DECLARE powerchart_cd = f8
 DECLARE undefined_cd = f8
 DECLARE write_dm_info(z=vc) = null
 DECLARE dsvm_error(msg=vc) = null
 SET ds_begin_snapshot = cnvtdatetime((curdate - 1),0)
 SET ds_end_snapshot = cnvtdatetime((curdate - 1),235959)
 SET stat_seq = 0
 SET stat = uar_get_meaning_by_codeset(21,"REVIEW",1,entry_mode_review_val)
 SET stat = uar_get_meaning_by_codeset(21,"SIGN",1,entry_mode_sign_val)
 SET stat = uar_get_meaning_by_codeset(21,"ENDORSE",1,entry_mode_endorse_val)
 SET stat = uar_get_meaning_by_codeset(53,"MDOC",1,event_cd_mdoc)
 SET stat = uar_get_meaning_by_codeset(53,"DOC",1,event_cd_doc)
 SET stat = uar_get_meaning_by_codeset(53,"RAD",1,event_cd_rad)
 SET stat = uar_get_meaning_by_codeset(53,"TXT",1,event_cd_txt)
 SET stat = uar_get_meaning_by_codeset(53,"NUM",1,event_cd_num)
 SET stat = uar_get_meaning_by_codeset(53,"DATE",1,event_cd_date)
 SET stat = uar_get_meaning_by_codeset(53,"DONE",1,event_cd_done)
 SET stat = uar_get_meaning_by_codeset(53,"GRP",1,event_cd_grp)
 SET type_cd_phone_msg = uar_get_code_by("MEANING",6026,"PHONE MSG")
 SET type_cd_renew = uar_get_code_by("MEANING",6003,"RENEW")
 SET stat = uar_get_meaning_by_codeset(16809,"ORDER",1,mn_powerplan_action_val)
 SET code_3m_aus = uar_get_code_by("MEANING",89,"3M-AUS")
 SET code_3m_can = uar_get_code_by("MEANING",89,"3M-CAN")
 SET code_3m = uar_get_code_by("MEANING",89,"3M")
 SET code_kodip = uar_get_code_by("MEANING",89,"KODIP")
 SET code_profile = uar_get_code_by("MEANING",89,"PROFILE")
 SET allergies_active_cd = uar_get_code_by("MEANING",48,"ACTIVE")
 SET allergies_inactive_cd = uar_get_code_by("MEANING",48,"INACTIVE")
 SET stat = uar_get_meaning_by_codeset(29520,"CLIN_NOTES",1,clin_notes_cd)
 SET stat = uar_get_meaning_by_codeset(21,"SIGN",1,sign_action_cd)
 SET stat = uar_get_meaning_by_codeset(29520,"POWERNOTE",1,powernote_cd)
 SET stat = uar_get_meaning_by_codeset(29520,"POWERNOTEED",1,powernoted_cd)
 SET stat = uar_get_meaning_by_codeset(29520,"UNDEFINED",1,undefined_cd)
 SET stat = uar_get_meaning_by_codeset(89,"POWERCHART",1,powerchart_cd)
 SET stat = uar_get_meaning_by_codeset(103,"COMPLETED",1,completed_cd)
 SET stat = uar_get_meaning_by_codeset(103,"REFUSED",1,refused_cd)
 SET stat = uar_get_meaning_by_codeset(103,"REQUESTED",1,requested_cd)
 SUBROUTINE dsvm_error(msg)
  DECLARE dsvm_err_msg = c132
  IF (error(dsvm_err_msg,0) > 0)
   ROLLBACK
   CALL esmerror(concat("Error: ",msg," ",dsvm_err_msg),esmreturn)
  ENDIF
 END ;Subroutine
 SET ds_cnt = 1
 SELECT INTO "nl:"
  cep.action_prsnl_id, cnt = count(*), cep.action_type_cd,
  pnl.name_last, pnl.name_first, pnl.username,
  pnl.physician_ind, pnl.position_cd, pnl.person_id
  FROM clinical_event ce,
   ce_event_prsnl cep,
   prsnl pnl
  WHERE ce.event_class_cd IN (event_cd_mdoc, event_cd_doc, event_cd_rad)
   AND ce.clinsig_updt_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot
   )
   AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
   AND ce.view_level=1
   AND ce.parent_event_id=ce.event_id
   AND ce.event_id=cep.event_id
   AND cep.action_type_cd IN (entry_mode_review_val, entry_mode_sign_val, entry_mode_endorse_val)
   AND cep.valid_until_dt_tm=ce.valid_until_dt_tm
   AND cep.action_status_cd IN (completed_cd, refused_cd, requested_cd)
   AND cep.action_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
   AND cep.action_prsnl_id=pnl.person_id
  GROUP BY cep.action_prsnl_id, cep.action_type_cd, pnl.name_last,
   pnl.name_first, pnl.username, pnl.physician_ind,
   pnl.position_cd, pnl.person_id
  HEAD REPORT
   IF (ds_cnt=1)
    qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm
     = cnvtdatetime(ds_begin_snapshot),
    dsr->qual[qualcnt].snapshot_type = "UE_INBOX_ACTIVITIES.2"
   ENDIF
   stat_seq_reviewed = 0, stat_seq_signed = 0, stat_seq_endorsed = 0
  DETAIL
   IF (mod(ds_cnt,10)=1)
    stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
   ENDIF
   CASE (cep.action_type_cd)
    OF entry_mode_review_val:
     dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UE_NBR_DOC_REVIEWED",dsr->qual[qualcnt].qual[ds_cnt
     ].stat_seq = stat_seq_reviewed,stat_seq_reviewed = (stat_seq_reviewed+ 1)
    OF entry_mode_sign_val:
     dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UE_NBR_DOC_SIGNED",dsr->qual[qualcnt].qual[ds_cnt].
     stat_seq = stat_seq_signed,stat_seq_signed = (stat_seq_signed+ 1)
    OF entry_mode_endorse_val:
     dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UE_NBR_DOC_ENDORSED",dsr->qual[qualcnt].qual[ds_cnt
     ].stat_seq = stat_seq_endorsed,stat_seq_endorsed = (stat_seq_endorsed+ 1)
   ENDCASE
   dsr->qual[qualcnt].qual[ds_cnt].stat_str_val = build(trim(substring(1,80,pnl.name_last)),"|",trim(
     substring(1,80,pnl.name_first)),"|",trim(pnl.username),
    "|",pnl.physician_ind,"|",uar_get_code_display(pnl.position_cd),"|",
    cnvtstring(pnl.person_id,11,2)), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt, dsr->
   qual[qualcnt].qual[ds_cnt].stat_type = 1,
   ds_cnt = (ds_cnt+ 1)
  WITH nocounter, orahintcbo("ORDERED INDEX(cep XIE1CE_EVENT_PRSNL)")
 ;end select
 CALL dsvm_error("UE_INBOX_ACTIVITIES - UE_NBR_DOC_REVIEWED-SIGNED-ENDORSED")
 SELECT INTO "nl:"
  cep.action_prsnl_id, cnt = count(*), cep.action_type_cd,
  pnl.name_last, pnl.name_first, pnl.username,
  pnl.physician_ind, pnl.position_cd, pnl.person_id
  FROM clinical_event ce,
   ce_event_prsnl cep,
   prsnl pnl
  WHERE ce.clinsig_updt_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(
   ds_end_snapshot)
   AND ((ce.event_class_cd IN (event_cd_txt, event_cd_num, event_cd_date, event_cd_done)) OR (ce
  .event_class_cd IN (event_cd_doc)
   AND ce.event_id != ce.parent_event_id
   AND  EXISTS (
  (SELECT
   ce_inner.event_id
   FROM clinical_event ce_inner
   WHERE ce_inner.event_class_cd=event_cd_grp
    AND ce_inner.event_id=ce.parent_event_id))))
   AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
   AND ce.view_level=1
   AND ce.event_id=cep.event_id
   AND cep.valid_until_dt_tm=ce.valid_until_dt_tm
   AND cep.action_status_cd IN (completed_cd, refused_cd, requested_cd)
   AND cep.action_type_cd IN (entry_mode_review_val, entry_mode_sign_val, entry_mode_endorse_val)
   AND cep.action_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
   AND cep.action_prsnl_id=pnl.person_id
  GROUP BY cep.action_prsnl_id, cep.action_type_cd, pnl.name_last,
   pnl.name_first, pnl.username, pnl.physician_ind,
   pnl.position_cd, pnl.person_id
  HEAD REPORT
   IF (ds_cnt=1)
    qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm
     = cnvtdatetime(ds_begin_snapshot),
    dsr->qual[qualcnt].snapshot_type = "UE_INBOX_ACTIVITIES.2"
   ENDIF
   stat_seq_reviewed = 0, stat_seq_signed = 0, stat_seq_endorsed = 0
  DETAIL
   IF (mod(ds_cnt,10)=1)
    stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
   ENDIF
   CASE (cep.action_type_cd)
    OF entry_mode_review_val:
     dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UE_NBR_RESULTS_REVIEWED",dsr->qual[qualcnt].qual[
     ds_cnt].stat_seq = stat_seq_reviewed,stat_seq_reviewed = (stat_seq_reviewed+ 1)
    OF entry_mode_sign_val:
     dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UE_NBR_RESULTS_SIGNED",dsr->qual[qualcnt].qual[
     ds_cnt].stat_seq = stat_seq_signed,stat_seq_signed = (stat_seq_signed+ 1)
    OF entry_mode_endorse_val:
     dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UE_NBR_RESULTS_ENDORSED",dsr->qual[qualcnt].qual[
     ds_cnt].stat_seq = stat_seq_endorsed,stat_seq_endorsed = (stat_seq_endorsed+ 1)
   ENDCASE
   dsr->qual[qualcnt].qual[ds_cnt].stat_str_val = build(trim(substring(1,80,pnl.name_last)),"|",trim(
     substring(1,80,pnl.name_first)),"|",trim(pnl.username),
    "|",pnl.physician_ind,"|",uar_get_code_display(pnl.position_cd),"|",
    cnvtstring(pnl.person_id,11,2)), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt, dsr->
   qual[qualcnt].qual[ds_cnt].stat_type = 1,
   ds_cnt = (ds_cnt+ 1)
  WITH nocounter, orahintcbo("ORDERED INDEX(cep XIE1CE_EVENT_PRSNL)")
 ;end select
 CALL dsvm_error("UE_INBOX_ACTIVITIES - UE_NBR_RESULTS_REVIEWED-SIGNED-ENDORSED")
 SELECT INTO "nl:"
  ta.msg_sender_id, cnt = count(*), pnl.name_last,
  pnl.name_first, pnl.username, pnl.physician_ind,
  pnl.position_cd, pnl.person_id
  FROM task_activity ta,
   prsnl pnl
  WHERE ta.task_type_cd=type_cd_phone_msg
   AND ta.task_create_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
   AND ta.msg_sender_id=pnl.person_id
  GROUP BY ta.msg_sender_id, pnl.name_last, pnl.name_first,
   pnl.username, pnl.physician_ind, pnl.position_cd,
   pnl.person_id
  HEAD REPORT
   IF (ds_cnt=1)
    qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm
     = cnvtdatetime(ds_begin_snapshot),
    dsr->qual[qualcnt].snapshot_type = "UE_INBOX_ACTIVITIES.2"
   ENDIF
   stat_seq = 0
  DETAIL
   IF (mod(ds_cnt,10)=1)
    stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
   ENDIF
   dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UE_NBR_GENERAL_MESSAGES_SENT", dsr->qual[qualcnt].
   qual[ds_cnt].stat_str_val = build(trim(substring(1,80,pnl.name_last)),"|",trim(substring(1,80,pnl
      .name_first)),"|",trim(pnl.username),
    "|",pnl.physician_ind,"|",uar_get_code_display(pnl.position_cd),"|",
    cnvtstring(pnl.person_id,11,2)), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
   dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
   ds_cnt = (ds_cnt+ 1),
   stat_seq = (stat_seq+ 1)
  WITH nocounter
 ;end select
 CALL dsvm_error("UE_INBOX_ACTIVITIES - UE_NBR_GENERAL_MESSAGES_SENT")
 SELECT INTO "nl:"
  ta.assign_prsnl_id, cnt = count(*), pnl.name_last,
  pnl.name_first, pnl.username, pnl.physician_ind,
  pnl.position_cd, pnl.person_id
  FROM task_activity t,
   task_activity_assignment ta,
   prsnl pnl
  WHERE t.task_type_cd=type_cd_phone_msg
   AND t.task_create_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
   AND t.task_id=ta.task_id
   AND ta.assign_prsnl_id=pnl.person_id
  GROUP BY ta.assign_prsnl_id, pnl.name_last, pnl.name_first,
   pnl.username, pnl.physician_ind, pnl.position_cd,
   pnl.person_id
  HEAD REPORT
   IF (ds_cnt=1)
    qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm
     = cnvtdatetime(ds_begin_snapshot),
    dsr->qual[qualcnt].snapshot_type = "UE_INBOX_ACTIVITIES.2"
   ENDIF
   stat_seq = 0
  DETAIL
   IF (mod(ds_cnt,10)=1)
    stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
   ENDIF
   dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UE_NBR_GENERAL_MESSAGES_RECV", dsr->qual[qualcnt].
   qual[ds_cnt].stat_str_val = build(trim(substring(1,80,pnl.name_last)),"|",trim(substring(1,80,pnl
      .name_first)),"|",trim(pnl.username),
    "|",pnl.physician_ind,"|",uar_get_code_display(pnl.position_cd),"|",
    cnvtstring(pnl.person_id,11,2)), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
   dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
   ds_cnt = (ds_cnt+ 1),
   stat_seq = (stat_seq+ 1)
  WITH nocounter
 ;end select
 CALL dsvm_error("UE_INBOX_ACTIVITIES - UE_NBR_GENERAL_MESSAGES_RECV")
 SELECT INTO "nl:"
  oa.action_personnel_id, cnt = count(*), pnl.name_last,
  pnl.name_first, pnl.username, pnl.physician_ind,
  pnl.position_cd, pnl.person_id
  FROM order_action oa,
   prsnl pnl
  WHERE oa.action_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
   AND oa.action_type_cd=type_cd_renew
   AND oa.action_personnel_id=pnl.person_id
  GROUP BY oa.action_personnel_id, pnl.name_last, pnl.name_first,
   pnl.username, pnl.physician_ind, pnl.position_cd,
   pnl.person_id
  HEAD REPORT
   IF (ds_cnt=1)
    qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm
     = cnvtdatetime(ds_begin_snapshot),
    dsr->qual[qualcnt].snapshot_type = "UE_INBOX_ACTIVITIES.2"
   ENDIF
   stat_seq = 0
  DETAIL
   IF (mod(ds_cnt,10)=1)
    stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
   ENDIF
   dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UE_NBR_RENEWAL_REQUESTS", dsr->qual[qualcnt].qual[
   ds_cnt].stat_str_val = build(trim(substring(1,80,pnl.name_last)),"|",trim(substring(1,80,pnl
      .name_first)),"|",trim(pnl.username),
    "|",pnl.physician_ind,"|",uar_get_code_display(pnl.position_cd),"|",
    cnvtstring(pnl.person_id,11,2)), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
   dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
   ds_cnt = (ds_cnt+ 1),
   stat_seq = (stat_seq+ 1)
  WITH nocounter
 ;end select
 CALL dsvm_error("UE_INBOX_ACTIVITIES - UE_NBR_RENEWAL_REQUESTS")
 SELECT INTO "nl:"
  o.review_personnel_id, cnt = count(*), pnl.name_last,
  pnl.name_first, pnl.username, pnl.physician_ind,
  pnl.position_cd, pnl.person_id
  FROM order_review o,
   prsnl pnl
  WHERE o.updt_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
   AND o.review_type_flag IN (1, 2, 3, 4)
   AND o.reviewed_status_flag IN (1, 5)
   AND o.action_sequence=1
   AND o.review_personnel_id=pnl.person_id
  GROUP BY o.review_personnel_id, pnl.name_last, pnl.name_first,
   pnl.username, pnl.physician_ind, pnl.position_cd,
   pnl.person_id
  HEAD REPORT
   IF (ds_cnt=1)
    qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm
     = cnvtdatetime(ds_begin_snapshot),
    dsr->qual[qualcnt].snapshot_type = "UE_INBOX_ACTIVITIES.2"
   ENDIF
   stat_seq = 0
  DETAIL
   IF (mod(ds_cnt,10)=1)
    stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
   ENDIF
   dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UE_NBR_ORDERS_APPROVED", dsr->qual[qualcnt].qual[
   ds_cnt].stat_str_val = build(trim(substring(1,80,pnl.name_last)),"|",trim(substring(1,80,pnl
      .name_first)),"|",trim(pnl.username),
    "|",pnl.physician_ind,"|",uar_get_code_display(pnl.position_cd),"|",
    cnvtstring(pnl.person_id,11,2)), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
   dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
   ds_cnt = (ds_cnt+ 1),
   stat_seq = (stat_seq+ 1)
  WITH nocounter
 ;end select
 CALL dsvm_error("UE_INBOX_ACTIVITIES - UE_NBR_ORDERS_APPROVED")
 IF (qualcnt > 0)
  SET stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt - 1))
 ENDIF
 EXECUTE dm_stat_snaps_load
 SET qualcnt = 0
 SET ds_cnt = 1
 DECLARE ptype_fnd = i2 WITH noconstant(0)
 RANGE OF p IS problem
 IF ((validate(p.problem_type_flag,- (999999))=- (999999)))
  SET ptype_fnd = 0
 ELSE
  SET ptype_fnd = 1
 ENDIF
 FREE RANGE p
 IF (ptype_fnd=1)
  SELECT INTO "nl:"
   p_inner.updt_id, cnt = count(*), pnl.name_last,
   pnl.name_first, pnl.username, pnl.physician_ind,
   pnl.position_cd, pnl.person_id
   FROM (
    (
    (SELECT DISTINCT
     p.problem_id, p.updt_id
     FROM problem p
     WHERE p.updt_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
      AND p.problem_type_flag=0
     WITH sqltype("f8","f8")))
    p_inner),
    prsnl pnl
   WHERE p_inner.updt_id=pnl.person_id
   GROUP BY p_inner.updt_id, pnl.name_last, pnl.name_first,
    pnl.username, pnl.physician_ind, pnl.position_cd,
    pnl.person_id
   HEAD REPORT
    IF (ds_cnt=1)
     qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm
      = cnvtdatetime(ds_begin_snapshot),
     dsr->qual[qualcnt].snapshot_type = "UE_PROBLEMS_DIAGNOSIS.2"
    ENDIF
    stat_seq = 0
   DETAIL
    IF (mod(ds_cnt,10)=1)
     stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
    ENDIF
    dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UE_NBR_PROBLEMS_CREATED", dsr->qual[qualcnt].qual[
    ds_cnt].stat_str_val = build(trim(substring(1,80,pnl.name_last)),"|",trim(substring(1,80,pnl
       .name_first)),"|",trim(pnl.username),
     "|",pnl.physician_ind,"|",uar_get_code_display(pnl.position_cd),"|",
     cnvtstring(pnl.person_id,11,2)), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
    dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq =
    stat_seq, ds_cnt = (ds_cnt+ 1),
    stat_seq = (stat_seq+ 1)
   WITH nocounter
  ;end select
  CALL dsvm_error("UE_PROBLEMS_DIAGNOSIS - UE_NBR_PROBLEMS_CREATED")
 ENDIF
 SELECT INTO "nl:"
  d_inner.updt_id, cnt = count(*), pnl.name_last,
  pnl.name_first, pnl.username, pnl.physician_ind,
  pnl.position_cd, pnl.person_id
  FROM (
   (
   (SELECT DISTINCT
    d.diagnosis_group, d.updt_id
    FROM diagnosis d
    WHERE d.updt_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
     AND  NOT (d.contributor_system_cd IN (code_3m_aus, code_3m_can, code_3m, code_kodip,
    code_profile))
     AND d.diagnosis_group > 0.0
    WITH sqltype("f8","f8")))
   d_inner),
   prsnl pnl
  WHERE d_inner.updt_id=pnl.person_id
  GROUP BY d_inner.updt_id, pnl.name_last, pnl.name_first,
   pnl.username, pnl.physician_ind, pnl.position_cd,
   pnl.person_id
  HEAD REPORT
   IF (ds_cnt=1)
    qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm
     = cnvtdatetime(ds_begin_snapshot),
    dsr->qual[qualcnt].snapshot_type = "UE_PROBLEMS_DIAGNOSIS.2"
   ENDIF
   stat_seq = 0
  DETAIL
   IF (mod(ds_cnt,10)=1)
    stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
   ENDIF
   dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UE_NBR_DIAGNOSIS_CREATED", dsr->qual[qualcnt].qual[
   ds_cnt].stat_str_val = build(trim(substring(1,80,pnl.name_last)),"|",trim(substring(1,80,pnl
      .name_first)),"|",trim(pnl.username),
    "|",pnl.physician_ind,"|",uar_get_code_display(pnl.position_cd),"|",
    cnvtstring(pnl.person_id,11,2)), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
   dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
   ds_cnt = (ds_cnt+ 1),
   stat_seq = (stat_seq+ 1)
  WITH nocounter
 ;end select
 CALL dsvm_error("UE_PROBLEMS_DIAGNOSIS - UE_NBR_DIAGNOSIS_CREATED")
 IF (ptype_fnd=1)
  SELECT INTO "nl:"
   p_inner.updt_id, cnt = count(*), pnl.name_last,
   pnl.name_first, pnl.username, pnl.physician_ind,
   pnl.position_cd, pnl.person_id
   FROM (
    (
    (SELECT DISTINCT
     p.problem_id, pa.updt_id
     FROM problem p,
      problem_action pa
     WHERE p.problem_type_flag=0
      AND pa.last_utc_ts BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
      AND pa.problem_instance_id=p.problem_instance_id
      AND pa.action_type_mean="REVIEW"
     WITH sqltype("f8","f8")))
    p_inner),
    prsnl pnl
   WHERE p_inner.updt_id=pnl.person_id
   GROUP BY p_inner.updt_id, pnl.name_last, pnl.name_first,
    pnl.username, pnl.physician_ind, pnl.position_cd,
    pnl.person_id
   HEAD REPORT
    IF (ds_cnt=1)
     qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm
      = cnvtdatetime(ds_begin_snapshot),
     dsr->qual[qualcnt].snapshot_type = "UE_PROBLEMS_DIAGNOSIS.2"
    ENDIF
    stat_seq = 0
   DETAIL
    IF (mod(ds_cnt,10)=1)
     stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
    ENDIF
    dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UE_NBR_PROBLEMS_REVIEWED", dsr->qual[qualcnt].qual[
    ds_cnt].stat_str_val = build(trim(substring(1,80,pnl.name_last)),"|",trim(substring(1,80,pnl
       .name_first)),"|",trim(pnl.username),
     "|",pnl.physician_ind,"|",uar_get_code_display(pnl.position_cd),"|",
     cnvtstring(pnl.person_id,11,2)), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
    dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq =
    stat_seq, ds_cnt = (ds_cnt+ 1),
    stat_seq = (stat_seq+ 1)
   WITH nocounter
  ;end select
  CALL dsvm_error("UE_PROBLEMS_DIAGNOSIS - UE_NBR_PROBLEMS_REVIEWED")
 ENDIF
 IF (qualcnt > 0)
  SET stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt - 1))
 ENDIF
 EXECUTE dm_stat_snaps_load
 SET qualcnt = 0
 SET ds_cnt = 1
 SELECT INTO "nl:"
  a.orig_prsnl_id, cnt = count(*), pnl.name_last,
  pnl.name_first, pnl.username, pnl.physician_ind,
  pnl.position_cd, pnl.person_id
  FROM allergy a,
   prsnl pnl
  WHERE a.created_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
   AND a.allergy_instance_id=a.allergy_id
   AND a.orig_prsnl_id=pnl.person_id
  GROUP BY a.orig_prsnl_id, pnl.name_last, pnl.name_first,
   pnl.username, pnl.physician_ind, pnl.position_cd,
   pnl.person_id
  HEAD REPORT
   IF (ds_cnt=1)
    qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm
     = cnvtdatetime(ds_begin_snapshot),
    dsr->qual[qualcnt].snapshot_type = "UE_ALLERGIES_HISTORIES.2"
   ENDIF
   stat_seq = 0
  DETAIL
   IF (mod(ds_cnt,10)=1)
    stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
   ENDIF
   dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UE_NBR_ALLERGIES_DOCUMENTED", dsr->qual[qualcnt].
   qual[ds_cnt].stat_str_val = build(trim(substring(1,80,pnl.name_last)),"|",trim(substring(1,80,pnl
      .name_first)),"|",trim(pnl.username),
    "|",pnl.physician_ind,"|",uar_get_code_display(pnl.position_cd),"|",
    cnvtstring(pnl.person_id,11,2)), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
   dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
   ds_cnt = (ds_cnt+ 1),
   stat_seq = (stat_seq+ 1)
  WITH nocounter
 ;end select
 CALL dsvm_error("UE_ALLERGIES_HISTORIES.2 - UE_NBR_ALLERGIES_DOCUMENTED")
 SELECT INTO "nl:"
  a.updt_id, cnt = count(*), pnl.name_last,
  pnl.name_first, pnl.username, pnl.physician_ind,
  pnl.position_cd, pnl.person_id
  FROM allergy a,
   prsnl pnl
  WHERE a.cancel_dt_tm = null
   AND a.allergy_instance_id != a.allergy_id
   AND a.created_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
   AND a.active_status_cd IN (allergies_active_cd, allergies_inactive_cd)
   AND a.updt_id=pnl.person_id
  GROUP BY a.updt_id, pnl.name_last, pnl.name_first,
   pnl.username, pnl.physician_ind, pnl.position_cd,
   pnl.person_id
  HEAD REPORT
   IF (ds_cnt=1)
    qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm
     = cnvtdatetime(ds_begin_snapshot),
    dsr->qual[qualcnt].snapshot_type = "UE_ALLERGIES_HISTORIES.2"
   ENDIF
   stat_seq = 0
  DETAIL
   IF (mod(ds_cnt,10)=1)
    stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
   ENDIF
   dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UE_NBR_ALLERGIES_MODIFIED", dsr->qual[qualcnt].qual[
   ds_cnt].stat_str_val = build(trim(substring(1,80,pnl.name_last)),"|",trim(substring(1,80,pnl
      .name_first)),"|",trim(pnl.username),
    "|",pnl.physician_ind,"|",uar_get_code_display(pnl.position_cd),"|",
    cnvtstring(pnl.person_id,11,2)), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
   dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
   ds_cnt = (ds_cnt+ 1),
   stat_seq = (stat_seq+ 1)
  WITH nocounter
 ;end select
 CALL dsvm_error("UE_ALLERGIES_HISTORIES.2 - UE_NBR_ALLERGIES_MODIFIED")
 SELECT INTO "nl:"
  a.cancel_prsnl_id, cnt = count(*), pnl.name_last,
  pnl.name_first, pnl.username, pnl.physician_ind,
  pnl.position_cd, pnl.person_id
  FROM allergy a,
   prsnl pnl
  WHERE a.cancel_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
   AND a.allergy_instance_id != a.allergy_id
   AND a.active_status_cd IN (allergies_active_cd, allergies_inactive_cd)
   AND a.cancel_prsnl_id=pnl.person_id
  GROUP BY a.cancel_prsnl_id, pnl.name_last, pnl.name_first,
   pnl.username, pnl.physician_ind, pnl.position_cd,
   pnl.person_id
  HEAD REPORT
   IF (ds_cnt=1)
    qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm
     = cnvtdatetime(ds_begin_snapshot),
    dsr->qual[qualcnt].snapshot_type = "UE_ALLERGIES_HISTORIES.2"
   ENDIF
   stat_seq = 0
  DETAIL
   IF (mod(ds_cnt,10)=1)
    stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
   ENDIF
   dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UE_NBR_ALLERGIES_REMOVED", dsr->qual[qualcnt].qual[
   ds_cnt].stat_str_val = build(trim(substring(1,80,pnl.name_last)),"|",trim(substring(1,80,pnl
      .name_first)),"|",trim(pnl.username),
    "|",pnl.physician_ind,"|",uar_get_code_display(pnl.position_cd),"|",
    cnvtstring(pnl.person_id,11,2)), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
   dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
   ds_cnt = (ds_cnt+ 1),
   stat_seq = (stat_seq+ 1)
  WITH nocounter
 ;end select
 CALL dsvm_error("UE_ALLERGIES_HISTORIES.2 - UE_NBR_ALLERGIES_REMOVED")
 IF (ptype_fnd=1)
  SELECT INTO "nl:"
   p_inner.updt_id, cnt = count(*), pnl.name_last,
   pnl.name_first, pnl.username, pnl.physician_ind,
   pnl.position_cd, pnl.person_id
   FROM (
    (
    (SELECT DISTINCT
     p.problem_id, p.updt_id
     FROM problem p
     WHERE p.updt_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
      AND p.problem_type_flag=1
     WITH sqltype("f8","f8")))
    p_inner),
    prsnl pnl
   WHERE p_inner.updt_id=pnl.person_id
   GROUP BY p_inner.updt_id, pnl.name_last, pnl.name_first,
    pnl.username, pnl.physician_ind, pnl.position_cd,
    pnl.person_id
   HEAD REPORT
    IF (ds_cnt=1)
     qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm
      = cnvtdatetime(ds_begin_snapshot),
     dsr->qual[qualcnt].snapshot_type = "UE_ALLERGIES_HISTORIES.2"
    ENDIF
    stat_seq = 0
   DETAIL
    IF (mod(ds_cnt,10)=1)
     stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
    ENDIF
    dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UE_NBR_PAST_MED_HISTORIES_DOCUMENTED", dsr->qual[
    qualcnt].qual[ds_cnt].stat_str_val = build(trim(substring(1,80,pnl.name_last)),"|",trim(substring
      (1,80,pnl.name_first)),"|",trim(pnl.username),
     "|",pnl.physician_ind,"|",uar_get_code_display(pnl.position_cd),"|",
     cnvtstring(pnl.person_id,11,2)), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
    dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq =
    stat_seq, ds_cnt = (ds_cnt+ 1),
    stat_seq = (stat_seq+ 1)
   WITH nocounter
  ;end select
  CALL dsvm_error("UE_ALLERGIES_HISTORIES.2 - UE_NBR_PAST_MED_HISTORIES_DOCUMENTED")
  IF (qualcnt > 0)
   SET stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt - 1))
  ENDIF
 ENDIF
 EXECUTE dm_stat_snaps_load
 SET qualcnt = 0
 SET ds_cnt = 1
 SELECT INTO "nl:"
  ce.performed_prsnl_id, cnt = count(*), pnl.name_last,
  pnl.name_first, pnl.username, pnl.physician_ind,
  pnl.position_cd, pnl.person_id
  FROM clinical_event ce,
   prsnl pnl
  WHERE ce.entry_mode_cd IN (clin_notes_cd, undefined_cd)
   AND ce.contributor_system_cd=powerchart_cd
   AND ce.event_class_cd=event_cd_mdoc
   AND ce.parent_event_id=ce.event_id
   AND ce.clinsig_updt_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot
   )
   AND ce.view_level=1
   AND ce.updt_cnt=1
   AND ce.performed_prsnl_id=pnl.person_id
  GROUP BY ce.performed_prsnl_id, pnl.name_last, pnl.name_first,
   pnl.username, pnl.physician_ind, pnl.position_cd,
   pnl.person_id
  HEAD REPORT
   IF (ds_cnt=1)
    qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm
     = cnvtdatetime(ds_begin_snapshot),
    dsr->qual[qualcnt].snapshot_type = "UE_DOCUMENTATION.2"
   ENDIF
   stat_seq = 0
  DETAIL
   IF (mod(ds_cnt,10)=1)
    stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
   ENDIF
   dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UE_NBR_CLIN_NOTES_DOCUMENTED", dsr->qual[qualcnt].
   qual[ds_cnt].stat_str_val = build(trim(substring(1,80,pnl.name_last)),"|",trim(substring(1,80,pnl
      .name_first)),"|",trim(pnl.username),
    "|",pnl.physician_ind,"|",uar_get_code_display(pnl.position_cd),"|",
    cnvtstring(pnl.person_id,11,2)), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
   dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
   ds_cnt = (ds_cnt+ 1),
   stat_seq = (stat_seq+ 1)
  WITH nocounter
 ;end select
 CALL dsvm_error("UE_DOCUMENTATION - UE_NBR_CLIN_NOTES_DOCUMENTED")
 SELECT INTO "nl:"
  cep.action_prsnl_id, cnt = count(*), pnl.name_last,
  pnl.name_first, pnl.username, pnl.physician_ind,
  pnl.position_cd, pnl.person_id
  FROM clinical_event ce,
   ce_event_prsnl cep,
   prsnl pnl
  WHERE ce.entry_mode_cd IN (clin_notes_cd, undefined_cd)
   AND ce.clinsig_updt_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot
   )
   AND ce.event_class_cd=event_cd_mdoc
   AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
   AND ce.view_level=1
   AND ce.event_id=cep.event_id
   AND cep.valid_until_dt_tm=ce.valid_until_dt_tm
   AND cep.action_type_cd=sign_action_cd
   AND cep.action_status_cd IN (completed_cd, refused_cd, requested_cd)
   AND cep.action_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
   AND cep.action_prsnl_id=pnl.person_id
  GROUP BY cep.action_prsnl_id, pnl.name_last, pnl.name_first,
   pnl.username, pnl.physician_ind, pnl.position_cd,
   pnl.person_id
  HEAD REPORT
   IF (ds_cnt=1)
    qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm
     = cnvtdatetime(ds_begin_snapshot),
    dsr->qual[qualcnt].snapshot_type = "UE_DOCUMENTATION.2"
   ENDIF
   stat_seq = 0
  DETAIL
   IF (mod(ds_cnt,10)=1)
    stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
   ENDIF
   dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UE_NBR_CLIN_NOTES_SIGNED", dsr->qual[qualcnt].qual[
   ds_cnt].stat_str_val = build(trim(substring(1,80,pnl.name_last)),"|",trim(substring(1,80,pnl
      .name_first)),"|",trim(pnl.username),
    "|",pnl.physician_ind,"|",uar_get_code_display(pnl.position_cd),"|",
    cnvtstring(pnl.person_id,11,2)), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
   dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
   ds_cnt = (ds_cnt+ 1),
   stat_seq = (stat_seq+ 1)
  WITH nocounter, orahintcbo("ORDERED INDEX(cep XIE1CE_EVENT_PRSNL)")
 ;end select
 CALL dsvm_error("UE_DOCUMENTATION - UE_NBR_CLIN_NOTES_SIGNED")
 SELECT INTO "nl:"
  ce.performed_prsnl_id, cnt = count(*), pnl.name_last,
  pnl.name_first, pnl.username, pnl.physician_ind,
  pnl.position_cd, pnl.person_id
  FROM clinical_event ce,
   prsnl pnl
  WHERE ce.entry_mode_cd IN (powernote_cd, powernoted_cd)
   AND ce.event_class_cd IN (event_cd_mdoc, event_cd_doc)
   AND ce.clinsig_updt_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot
   )
   AND ce.view_level=1
   AND ce.updt_cnt=1
   AND ce.performed_prsnl_id=pnl.person_id
  GROUP BY ce.performed_prsnl_id, pnl.name_last, pnl.name_first,
   pnl.username, pnl.physician_ind, pnl.position_cd,
   pnl.person_id
  HEAD REPORT
   IF (ds_cnt=1)
    qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm
     = cnvtdatetime(ds_begin_snapshot),
    dsr->qual[qualcnt].snapshot_type = "UE_DOCUMENTATION.2"
   ENDIF
   stat_seq = 0
  DETAIL
   IF (mod(ds_cnt,10)=1)
    stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
   ENDIF
   dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UE_NBR_POWER_NOTES_DOCUMENTED", dsr->qual[qualcnt].
   qual[ds_cnt].stat_str_val = build(trim(substring(1,80,pnl.name_last)),"|",trim(substring(1,80,pnl
      .name_first)),"|",trim(pnl.username),
    "|",pnl.physician_ind,"|",uar_get_code_display(pnl.position_cd),"|",
    cnvtstring(pnl.person_id,11,2)), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
   dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
   ds_cnt = (ds_cnt+ 1),
   stat_seq = (stat_seq+ 1)
  WITH nocounter
 ;end select
 CALL dsvm_error("UE_DOCUMENTATION - UE_NBR_POWER_NOTES_DOCUMENTED")
 SELECT INTO "nl:"
  cep.action_prsnl_id, cnt = count(*), pnl.name_last,
  pnl.name_first, pnl.username, pnl.physician_ind,
  pnl.position_cd, pnl.person_id
  FROM clinical_event ce,
   ce_event_prsnl cep,
   prsnl pnl
  WHERE ce.entry_mode_cd IN (powernote_cd, powernoted_cd)
   AND ce.clinsig_updt_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot
   )
   AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
   AND ce.event_class_cd IN (event_cd_mdoc, event_cd_doc)
   AND ce.view_level=1
   AND ce.event_id=cep.event_id
   AND cep.valid_until_dt_tm=ce.valid_until_dt_tm
   AND cep.action_type_cd=sign_action_cd
   AND cep.action_status_cd IN (completed_cd, refused_cd, requested_cd)
   AND cep.action_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
   AND cep.action_prsnl_id=pnl.person_id
  GROUP BY cep.action_prsnl_id, pnl.name_last, pnl.name_first,
   pnl.username, pnl.physician_ind, pnl.position_cd,
   pnl.person_id
  HEAD REPORT
   IF (ds_cnt=1)
    qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm
     = cnvtdatetime(ds_begin_snapshot),
    dsr->qual[qualcnt].snapshot_type = "UE_DOCUMENTATION.2"
   ENDIF
   stat_seq = 0
  DETAIL
   IF (mod(ds_cnt,10)=1)
    stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
   ENDIF
   dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UE_NBR_POWER_NOTES_SIGNED", dsr->qual[qualcnt].qual[
   ds_cnt].stat_str_val = build(trim(substring(1,80,pnl.name_last)),"|",trim(substring(1,80,pnl
      .name_first)),"|",trim(pnl.username),
    "|",pnl.physician_ind,"|",uar_get_code_display(pnl.position_cd),"|",
    cnvtstring(pnl.person_id,11,2)), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
   dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
   ds_cnt = (ds_cnt+ 1),
   stat_seq = (stat_seq+ 1)
  WITH nocounter, orahintcbo("ORDERED INDEX(cep XIE1CE_EVENT_PRSNL)")
 ;end select
 CALL dsvm_error("UE_DOCUMENTATION - UE_NBR_POWER_NOTES_SIGNED")
 IF (qualcnt > 0)
  SET stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt - 1))
 ENDIF
 EXECUTE dm_stat_snaps_load
 SET qualcnt = 0
 DECLARE modify_dlg_fnd = i2 WITH noconstant(0)
 RANGE OF ede IS eks_dlg_event
 IF (validate(ede.modify_dlg_name,"XXXXXX")="XXXXXX")
  SET modify_dlg_fnd = 0
 ELSE
  SET modify_dlg_fnd = 1
 ENDIF
 FREE RANGE ede
 SET ds_cnt = 1
 IF (modify_dlg_fnd=0)
  SELECT INTO "nl:"
   e.dlg_name, e.override_reason_cd, e.dlg_prsnl_id
   FROM eks_dlg_event e
   WHERE e.dlg_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
    AND e.dlg_name != "MUL_MED*"
    AND e.dlg_name > " "
   HEAD REPORT
    IF (ds_cnt=1)
     qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm
      = cnvtdatetime(ds_begin_snapshot),
     dsr->qual[qualcnt].snapshot_type = "UE_ALERT_DETAILS"
    ENDIF
    stat_seq = 0
   DETAIL
    IF (mod(ds_cnt,10)=1)
     stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
    ENDIF
    dsr->qual[qualcnt].qual[ds_cnt].stat_name = "DISCRETE_ALERTS", dsr->qual[qualcnt].qual[ds_cnt].
    stat_clob_val = build(trim(e.dlg_name),"||",uar_get_code_display(e.override_reason_cd),"||",
     cnvtstring(e.override_reason_cd,11,2),
     "||",cnvtstring(e.dlg_prsnl_id,11,2)), dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1,
    dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq, ds_cnt = (ds_cnt+ 1), stat_seq = (stat_seq+
    1)
   WITH nocounter
  ;end select
  CALL dsvm_error("UE_ALERT_DETAILS - DISCRETE_ALERTS")
  SELECT DISTINCT INTO "nl:"
   e.dlg_name
   FROM eks_dlg_event e
   WHERE e.override_reason_cd > 0
    AND e.dlg_name != "MUL_MED*"
    AND e.dlg_name > " "
    AND e.dlg_dt_tm BETWEEN cnvtdatetime((curdate - 30),0) AND cnvtdatetime((curdate - 1),235959)
   HEAD REPORT
    IF (ds_cnt=1)
     qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm
      = cnvtdatetime(ds_begin_snapshot),
     dsr->qual[qualcnt].snapshot_type = "UE_ALERT_DETAILS"
    ENDIF
    stat_seq = 0
   DETAIL
    IF (mod(ds_cnt,10)=1)
     stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
    ENDIF
    dsr->qual[qualcnt].qual[ds_cnt].stat_name = "OVERRIDDEN_ALERTS", dsr->qual[qualcnt].qual[ds_cnt].
    stat_clob_val = trim(e.dlg_name), dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1,
    dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq, ds_cnt = (ds_cnt+ 1), stat_seq = (stat_seq+
    1)
   WITH nocounter
  ;end select
  CALL dsvm_error("UE_ALERT_DETAILS - OVERRIDDEN_ALERTS")
 ELSE
  SELECT INTO "nl:"
   e.dlg_name, e.modify_dlg_name, e.override_reason_cd,
   e.dlg_prsnl_id
   FROM eks_dlg_event e
   WHERE e.dlg_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
    AND e.dlg_name != "MUL_MED*"
    AND e.dlg_name > " "
   HEAD REPORT
    IF (ds_cnt=1)
     qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm
      = cnvtdatetime(ds_begin_snapshot),
     dsr->qual[qualcnt].snapshot_type = "UE_ALERT_DETAILS"
    ENDIF
    stat_seq = 0
   DETAIL
    IF (mod(ds_cnt,10)=1)
     stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
    ENDIF
    dsr->qual[qualcnt].qual[ds_cnt].stat_name = "DISCRETE_ALERTS", dsr->qual[qualcnt].qual[ds_cnt].
    stat_clob_val = build(trim(e.dlg_name),"||",uar_get_code_display(e.override_reason_cd),"||",
     cnvtstring(e.override_reason_cd,11,2),
     "||",cnvtstring(e.dlg_prsnl_id,11,2),"||",trim(e.modify_dlg_name)), dsr->qual[qualcnt].qual[
    ds_cnt].stat_type = 1,
    dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq, ds_cnt = (ds_cnt+ 1), stat_seq = (stat_seq+
    1)
   WITH nocounter
  ;end select
  CALL dsvm_error("UE_ALERT_DETAILS - DISCRETE_ALERTS")
  SELECT DISTINCT INTO "nl:"
   val = build(e.dlg_name,"||",e.modify_dlg_name)
   FROM eks_dlg_event e
   WHERE e.override_reason_cd > 0
    AND e.dlg_name != "MUL_MED*"
    AND e.dlg_name > " "
    AND e.dlg_dt_tm BETWEEN cnvtdatetime((curdate - 30),0) AND cnvtdatetime((curdate - 1),235959)
   HEAD REPORT
    IF (ds_cnt=1)
     qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm
      = cnvtdatetime(ds_begin_snapshot),
     dsr->qual[qualcnt].snapshot_type = "UE_ALERT_DETAILS"
    ENDIF
    stat_seq = 0
   DETAIL
    IF (mod(ds_cnt,10)=1)
     stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
    ENDIF
    dsr->qual[qualcnt].qual[ds_cnt].stat_name = "OVERRIDDEN_ALERTS", dsr->qual[qualcnt].qual[ds_cnt].
    stat_clob_val = val, dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1,
    dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq, ds_cnt = (ds_cnt+ 1), stat_seq = (stat_seq+
    1)
   WITH nocounter
  ;end select
  CALL dsvm_error("UE_ALERT_DETAILS - OVERRIDDEN_ALERTS")
 ENDIF
 IF (qualcnt > 0)
  SET stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt - 1))
 ENDIF
 EXECUTE dm_stat_snaps_load
 SET qualcnt = 0
 SET ds_cnt = 1
 SELECT INTO "nl:"
  p_inner.action_prsnl_id, cnt = count(*), pnl.name_last,
  pnl.name_first, pnl.username, pnl.physician_ind,
  pnl.position_cd, pnl.person_id
  FROM (
   (
   (SELECT DISTINCT
    p.pw_group_nbr, pa.action_prsnl_id
    FROM pathway p,
     pathway_action pa
    WHERE p.order_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
     AND (pa.pathway_id=(p.pathway_id+ 0))
     AND pa.action_type_cd=mn_powerplan_action_val
    WITH sqltype("f8","f8")))
   p_inner),
   prsnl pnl
  WHERE p_inner.action_prsnl_id=pnl.person_id
  GROUP BY p_inner.action_prsnl_id, pnl.name_last, pnl.name_first,
   pnl.username, pnl.physician_ind, pnl.position_cd,
   pnl.person_id
  HEAD REPORT
   qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm =
   cnvtdatetime(ds_begin_snapshot),
   dsr->qual[qualcnt].snapshot_type = "UE_POWERPLANS", ds_cnt = 1, stat_seq = 0
  DETAIL
   IF (mod(ds_cnt,10)=1)
    stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
   ENDIF
   dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UE_NBR_POWERPLANS_SIGNED", dsr->qual[qualcnt].qual[
   ds_cnt].stat_str_val = build(trim(substring(1,80,pnl.name_last)),"|",trim(substring(1,80,pnl
      .name_first)),"|",trim(pnl.username),
    "|",pnl.physician_ind,"|",uar_get_code_display(pnl.position_cd),"|",
    cnvtstring(pnl.person_id,11,2)), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
   dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
   ds_cnt = (ds_cnt+ 1),
   stat_seq = (stat_seq+ 1)
  WITH nocounter
 ;end select
 CALL dsvm_error("UE_POWERPLANS - UE_NBR_POWERPLANS_SIGNED")
 IF (qualcnt > 0)
  SET stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt - 1))
 ENDIF
 EXECUTE dm_stat_snaps_load
 SET qualcnt = 0
 SET mn_open_chart_code_val = uar_get_code_by("MEANING",104,"CHARTACCESS")
 SELECT INTO "nl:"
  ppa.prsnl_id, cnt = count(*), pnl.name_last,
  pnl.name_first, pnl.username, pnl.physician_ind,
  pnl.position_cd, pnl.person_id
  FROM person_prsnl_activity ppa,
   prsnl pnl
  WHERE ppa.ppa_type_cd=mn_open_chart_code_val
   AND ppa.ppa_first_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
   AND ((ppa.prsnl_id+ 0)=pnl.person_id)
  GROUP BY ppa.prsnl_id, pnl.name_last, pnl.name_first,
   pnl.username, pnl.physician_ind, pnl.position_cd,
   pnl.person_id
  HEAD REPORT
   qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm =
   cnvtdatetime(ds_begin_snapshot),
   dsr->qual[qualcnt].snapshot_type = "UE_CHART_OPENS", ds_cnt = 1, stat_seq = 0
  DETAIL
   IF (mod(ds_cnt,10)=1)
    stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
   ENDIF
   dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UE_NBR_CHARTS_OPENED", dsr->qual[qualcnt].qual[ds_cnt
   ].stat_str_val = build(trim(substring(1,80,pnl.name_last)),"|",trim(substring(1,80,pnl.name_first)
     ),"|",trim(pnl.username),
    "|",pnl.physician_ind,"|",uar_get_code_display(pnl.position_cd),"|",
    cnvtstring(pnl.person_id,11,2)), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
   dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
   ds_cnt = (ds_cnt+ 1),
   stat_seq = (stat_seq+ 1)
  WITH nocounter
 ;end select
 CALL dsvm_error("UE_CHART_OPENS - UE_NBR_CHARTS_OPENED")
 IF (qualcnt > 0)
  SET stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt - 1))
 ENDIF
 EXECUTE dm_stat_snaps_load
 SET qualcnt = 0
 CALL write_dm_info("x")
 COMMIT
 SUBROUTINE write_dm_info(z)
   CALL echo("Updating DM_INFO with current snapshot dt/tm")
   UPDATE  FROM dm_info
    SET info_date = cnvtdatetime(ds_begin_snapshot)
    WHERE info_domain="DM_STAT_USER_EXPERIENCE"
     AND info_name="LAST_SNAPSHOT_DATE_TIME"
    WITH nocounter
   ;end update
   IF (curqual=0)
    INSERT  FROM dm_info
     SET info_domain = "DM_STAT_USER_EXPERIENCE", info_name = "LAST_SNAPSHOT_DATE_TIME", info_date =
      cnvtdatetime(ds_begin_snapshot)
     WITH nocounter
    ;end insert
   ENDIF
 END ;Subroutine
#exit_program
END GO
