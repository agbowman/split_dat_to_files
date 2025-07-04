CREATE PROGRAM bed_ens_sn_pref_cards:dba
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
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET failed = "N"
 SET ornurse_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=14258
   AND cv.cdf_meaning="ORNURSE"
   AND cv.active_ind=1
  DETAIL
   ornurse_cd = cv.code_value
  WITH nocounter
 ;end select
 SET active_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=48
   AND cv.cdf_meaning="ACTIVE"
   AND cv.active_ind=1
  DETAIL
   active_cd = cv.code_value
  WITH nocounter
 ;end select
 SET ccnt = 0
 SET ccnt = size(request->clist,5)
 IF (ccnt=0)
  GO TO exit_script
 ENDIF
 FOR (c = 1 TO ccnt)
   SET scnt = 0
   SET scnt = size(request->clist[c].slist,5)
   SET icnt = 0
   SET icnt = size(request->clist[c].ilist,5)
   IF (icnt=0)
    GO TO exit_script
   ENDIF
   IF (scnt > 0
    AND (request->clist[c].slist[1].surgeon_id > 0))
    FOR (s = 1 TO scnt)
      SET found_ind = 0
      SELECT INTO "NL:"
       FROM preference_card pc
       WHERE (pc.catalog_cd=request->clist[c].catalog_code_value)
        AND (pc.prsnl_id=request->clist[c].slist[s].surgeon_id)
        AND pc.surg_specialty_id=0.0
        AND (pc.surg_area_cd=request->clist[c].surg_area_code_value)
        AND pc.active_ind=1
        AND pc.doc_type_cd=ornurse_cd
       DETAIL
        found_ind = 1
       WITH nocounter
      ;end select
      IF (found_ind=0)
       SET new_pref_card_id = 0.0
       SELECT INTO "nl:"
        z = seq(reference_seq,nextval)
        FROM dual
        DETAIL
         new_pref_card_id = cnvtreal(z)
        WITH format, nocounter
       ;end select
       CALL create_preference_card(new_pref_card_id,request->clist[c].slist[s].surgeon_id)
       CALL create_pref_card_pick_list(new_pref_card_id)
      ENDIF
    ENDFOR
   ELSE
    SET new_pref_card_id = 0.0
    SELECT INTO "nl:"
     z = seq(reference_seq,nextval)
     FROM dual
     DETAIL
      new_pref_card_id = cnvtreal(z)
     WITH format, nocounter
    ;end select
    CALL create_preference_card(new_pref_card_id,0.0)
    CALL create_pref_card_pick_list(new_pref_card_id)
   ENDIF
 ENDFOR
 GO TO exit_script
 SUBROUTINE create_preference_card(pref_card_id,prsnl_id)
   SET ierrcode = 0
   INSERT  FROM preference_card pc
    SET pc.pref_card_id = pref_card_id, pc.catalog_cd = request->clist[c].catalog_code_value, pc
     .prsnl_id = prsnl_id,
     pc.surg_specialty_id = 0.0, pc.surg_area_cd = request->clist[c].surg_area_code_value, pc
     .template_ind = 0,
     pc.template_desc_cd = 0.0, pc.pref_card_type_flag = 0, pc.hist_avg_dur = 0,
     pc.tot_nbr_cases = 0, pc.override_hist_avg_dur = 0, pc.override_tot_nbr_cases = 0,
     pc.override_lookback_nbr = 0, pc.long_text_id = 0.0, pc.data_status_cd = 0.0,
     pc.active_ind = 1, pc.active_status_cd = active_cd, pc.active_status_dt_tm = cnvtdatetime(
      curdate,curtime),
     pc.active_status_prsnl_id = reqinfo->updt_id, pc.create_dt_tm = cnvtdatetime(curdate,curtime),
     pc.create_prsnl_id = reqinfo->updt_id,
     pc.create_task = reqinfo->updt_task, pc.create_applctx = reqinfo->updt_applctx, pc.updt_cnt = 0,
     pc.updt_dt_tm = cnvtdatetime(curdate,curtime), pc.updt_id = reqinfo->updt_id, pc.updt_task =
     reqinfo->updt_task,
     pc.updt_applctx = reqinfo->updt_applctx, pc.locked_applctx = 0, pc.num_cases_rec_avg = 0,
     pc.rec_avg_dur = 0, pc.doc_type_cd = ornurse_cd, pc.last_used_dt_tm = null
    WITH nocounter
   ;end insert
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = "Y"
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE create_pref_card_pick_list(pref_card_id)
   FOR (i = 1 TO icnt)
     SET ierrcode = 0
     INSERT  FROM pref_card_pick_list pl
      SET pl.pref_card_pick_list_id = seq(reference_seq,nextval), pl.pref_card_id = pref_card_id, pl
       .parent_entity_name = " ",
       pl.parent_entity_id = 0.0, pl.request_open_qty = request->clist[c].ilist[i].open_qty, pl
       .request_hold_qty = request->clist[c].ilist[i].hold_qty,
       pl.sched_item_ind = 0, pl.updt_cnt = 0, pl.updt_dt_tm = cnvtdatetime(curdate,curtime),
       pl.updt_id = reqinfo->updt_id, pl.updt_task = reqinfo->updt_task, pl.updt_applctx = reqinfo->
       updt_applctx,
       pl.active_ind = 1, pl.active_status_cd = active_cd, pl.active_status_prsnl_id = reqinfo->
       updt_id,
       pl.active_status_dt_tm = cnvtdatetime(curdate,curtime), pl.beg_effective_dt_tm = cnvtdatetime(
        curdate,curtime), pl.end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00.00"),
       pl.parent_pack_id = 0.0, pl.create_applctx = reqinfo->updt_applctx, pl.create_dt_tm =
       cnvtdatetime(curdate,curtime),
       pl.create_prsnl_id = reqinfo->updt_id, pl.create_task = reqinfo->updt_task, pl.item_id =
       request->clist[c].ilist[i].item_id
      WITH nocounter
     ;end insert
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET failed = "Y"
      GO TO exit_script
     ENDIF
   ENDFOR
 END ;Subroutine
#exit_script
 IF (failed="Y")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 CALL echorecord(reply)
END GO
