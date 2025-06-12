CREATE PROGRAM bed_ens_fn_toolbar:dba
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
 FREE SET temp_tp
 RECORD temp_tp(
   1 tlist[*]
     2 track_pref_id = f8
 )
 SET reply->status_data.status = "F"
 DECLARE error_msg = vc
 DECLARE sub_comp_prefs = vc
 SET error_flag = "N"
 SET tp_cnt = 0
 SET tot_tpcnt = 0
 SET form_code_value = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=20500
   AND cv.active_ind=1
   AND cv.cdf_meaning="FORMASSOC"
  DETAIL
   form_code_value = cv.code_value
  WITH nocounter
 ;end select
 SET group_cnt = size(request->trlist,5)
 SET bar_cnt = size(request->blist,5)
 SET position_cnt = size(request->plist,5)
 IF (((group_cnt=0) OR (position_cnt=0)) )
  GO TO exit_script
 ENDIF
 FOR (i = 1 TO group_cnt)
   FOR (x = 1 TO position_cnt)
     DECLARE tp_parse = vc
     SET tp_parse = build(" tp.comp_name_unq = '",trim(cnvtstring(request->plist[x].code_value)),";",
      trim(cnvtstring(request->trlist[i].code_value)),"' and ",
      " tp.comp_pref = '",trim(cnvtstring(request->trlist[i].code_value)),"*' and ",
      " tp.comp_type_cd = ",form_code_value,
      " and tp.parent_pref_id = 0.0")
     CALL echo(tp_parse)
     DELETE  FROM track_comp_prefs tcp
      WHERE (tcp.track_pref_id=
      (SELECT
       tp.track_pref_id
       FROM track_prefs tp
       WHERE parser(tp_parse)))
      WITH nocounter
     ;end delete
     DELETE  FROM track_prefs tp
      WHERE parser(tp_parse)
      WITH nocounter
     ;end delete
   ENDFOR
 ENDFOR
 IF (bar_cnt > 0)
  INSERT  FROM track_prefs tp,
    (dummyt d  WITH seq = group_cnt),
    (dummyt d2  WITH seq = position_cnt)
   SET tp.track_pref_id = seq(tracking_seq,nextval), tp.comp_name = request->trlist[d.seq].display,
    tp.comp_name_unq = concat(trim(cnvtstring(request->plist[d2.seq].code_value)),";",trim(cnvtstring
      (request->trlist[d.seq].code_value))),
    tp.comp_pref = concat(trim(cnvtstring(request->trlist[d.seq].code_value))), tp.comp_type_cd =
    form_code_value, tp.parent_pref_id = 0.0,
    tp.updt_dt_tm = cnvtdatetime(curdate,curtime3), tp.updt_id = reqinfo->updt_id, tp.updt_task =
    reqinfo->updt_task,
    tp.updt_applctx = reqinfo->updt_applctx, tp.updt_cnt = 0
   PLAN (d)
    JOIN (d2)
    JOIN (tp)
   WITH nocounter
  ;end insert
  SELECT INTO "NL:"
   FROM track_prefs tp,
    (dummyt d  WITH seq = group_cnt),
    (dummyt d2  WITH seq = position_cnt)
   PLAN (d)
    JOIN (d2)
    JOIN (tp
    WHERE tp.comp_type_cd=form_code_value
     AND tp.parent_pref_id=0.0
     AND tp.comp_name_unq=concat(trim(cnvtstring(request->plist[d2.seq].code_value)),";",trim(
      cnvtstring(request->trlist[d.seq].code_value))))
   HEAD REPORT
    stat = alterlist(temp_tp->tlist,50)
   DETAIL
    tot_tpcnt = (tot_tpcnt+ 1), tp_cnt = (tp_cnt+ 1)
    IF (tp_cnt > 50)
     stat = alterlist(temp_tp->tlist,(tot_tpcnt+ 50)), tp_cnt = 1
    ENDIF
    temp_tp->tlist[tot_tpcnt].track_pref_id = tp.track_pref_id
   FOOT REPORT
    stat = alterlist(temp_tp->tlist,tot_tpcnt)
   WITH nocounter
  ;end select
  FOR (x = 1 TO tot_tpcnt)
    FOR (i = 1 TO 8)
      SET sub_comp_pref = fillstring(50," ")
      IF (i <= bar_cnt)
       IF ((request->blist[i].action_type=1))
        SET sub_comp_pref = concat(trim(cnvtstring(request->blist[i].action_type)),";",trim(
          cnvtstring(request->blist[i].option)),";",trim(cnvtstring(request->blist[i].action)),
         ";",trim(cnvtstring(request->blist[i].visible_ind)),";",trim(cnvtstring(request->blist[i].
           icon)))
       ELSEIF ((request->blist[i].action_type=2))
        SET sub_comp_pref = concat(trim(cnvtstring(request->blist[i].action_type)),";",trim(
          cnvtstring(request->blist[i].option)),";",trim(cnvtstring(request->blist[i].visible_ind)),
         ";",trim(cnvtstring(request->blist[i].icon)))
       ELSEIF ((request->blist[i].action_type=3))
        SET sub_comp_pref = concat(trim(cnvtstring(request->blist[i].action_type)),";",trim(
          cnvtstring(request->blist[i].visible_ind)),";",trim(cnvtstring(request->blist[i].icon)))
       ENDIF
      ENDIF
      INSERT  FROM track_comp_prefs tcp
       SET tcp.track_pref_comp_id = seq(tracking_seq,nextval), tcp.track_pref_id = temp_tp->tlist[x].
        track_pref_id, tcp.sub_comp_name = concat("Action Id",trim(cnvtstring(i))),
        tcp.sub_comp_pref =
        IF (sub_comp_pref > " ") sub_comp_pref
        ELSE null
        ENDIF
        , tcp.sub_comp_type_cd = form_code_value, tcp.updt_dt_tm = cnvtdatetime(curdate,curtime3),
        tcp.updt_id = reqinfo->updt_id, tcp.updt_applctx = reqinfo->updt_applctx, tcp.updt_cnt = 0
       WITH nocounter
      ;end insert
    ENDFOR
  ENDFOR
 ENDIF
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_ENS_FN_TOOLBAR","  >> ERROR MSG: ",error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
