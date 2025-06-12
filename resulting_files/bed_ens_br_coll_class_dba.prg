CREATE PROGRAM bed_ens_br_coll_class:dba
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
 RECORD request_cv(
   1 cd_value_list[1]
     2 action_flag = i2
     2 cdf_meaning = vc
     2 cki = vc
     2 code_set = i4
     2 code_value = f8
     2 collation_seq = i4
     2 concept_cki = vc
     2 definition = vc
     2 description = vc
     2 display = vc
     2 begin_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 active_ind = i2
     2 display_key = vc
 )
 FREE RECORD reply_cv
 RECORD reply_cv(
   1 curqual = i4
   1 qual[*]
     2 status = i2
     2 error_num = i4
     2 error_msg = vc
     2 code_value = f8
     2 cki = vc
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 tlist[*]
     2 code_value = f8
     2 display_key = c40
 )
 SET reply->status_data.status = "F"
 SET dummy_parm1 = 0
 SET dummy_parm2 = 0
 SET fcnt = size(request->flist,5)
 IF (fcnt=0)
  GO TO exit_script
 ENDIF
 FOR (f = 1 TO fcnt)
   SET facility_specific = 0
   SELECT INTO "NL:"
    FROM br_coll_class bcc
    WHERE (bcc.activity_type=request->activity_type)
     AND (bcc.facility_id=request->flist[f].facility_id)
    DETAIL
     facility_specific = 1
    WITH nocounter
   ;end select
   IF (facility_specific=0)
    SET any_facility_specific = 0
    SELECT INTO "NL:"
     FROM br_coll_class bcc
     WHERE bcc.facility_id > 0.0
     DETAIL
      any_facility_specific = 1
     WITH nocounter
    ;end select
    IF (any_facility_specific=0)
     SET tlist_cnt = 0
     SELECT INTO "NL:"
      FROM code_value cv,
       br_coll_class bcc
      PLAN (cv
       WHERE cv.code_set=231)
       JOIN (bcc
       WHERE bcc.code_value=outerjoin(cv.code_value))
      DETAIL
       IF (bcc.activity_type != "RLI")
        tlist_cnt = (tlist_cnt+ 1), stat = alterlist(temp->tlist,tlist_cnt), temp->tlist[tlist_cnt].
        code_value = cv.code_value,
        temp->tlist[tlist_cnt].display_key = cv.display_key
       ENDIF
      WITH nocounter
     ;end select
     FOR (t = 1 TO tlist_cnt)
       SET request_cv->cd_value_list[1].action_flag = 3
       SET request_cv->cd_value_list[1].code_set = 231
       SET request_cv->cd_value_list[1].code_value = temp->tlist[t].code_value
       SET request_cv->cd_value_list[1].display_key = temp->tlist[t].display_key
       SET trace = recpersist
       EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
     ENDFOR
    ENDIF
    INSERT  FROM br_coll_class
     (activity_type, collection_class, proposed_name_suffix,
     facility_id, display_name, storage_tracking_ind,
     code_value, updt_cnt, updt_dt_tm,
     updt_id, updt_task, updt_applctx)(SELECT
      bcc.activity_type, bcc.collection_class, bcc.proposed_name_suffix,
      request->flist[f].facility_id, bcc.display_name, bcc.storage_tracking_ind,
      bcc.code_value, 0, cnvtdatetime(curdate,curtime),
      reqinfo->updt_id, reqinfo->updt_task, reqinfo->updt_applctx
      FROM br_coll_class bcc
      WHERE bcc.facility_id=0.0
       AND (bcc.activity_type=request->activity_type))
     WITH nocounter
    ;end insert
   ENDIF
   SET ccnt = size(request->flist[f].clist,5)
   FOR (c = 1 TO ccnt)
     SET row_exists = 0
     SET curr_disp_name = fillstring(10," ")
     SET curr_stor_track_ind = 0
     SET coll_class_cd_value = 0.0
     SELECT INTO "NL:"
      FROM br_coll_class bcc
      WHERE (bcc.activity_type=request->activity_type)
       AND (bcc.collection_class=request->flist[f].clist[c].collection_class)
       AND (bcc.facility_id=request->flist[f].facility_id)
      DETAIL
       row_exists = 1, curr_disp_name = bcc.display_name, curr_stor_track_ind = bcc
       .storage_tracking_ind,
       coll_class_cd_value = bcc.code_value
      WITH nocounter
     ;end select
     IF (row_exists=0)
      CALL insert_code_value(dummy_parm1)
      IF ((reply_cv->status_data.status="S")
       AND (reply_cv->qual[1].code_value > 0))
       SET coll_class_cd_value = reply_cv->qual[1].code_value
       CALL insert_collection_class(dummy_parm1)
       CALL insert_br_coll_class(dummy_parm1)
      ENDIF
     ELSE
      IF (coll_class_cd_value > 0.0)
       IF ((((curr_disp_name != request->flist[f].clist[c].display_name)) OR ((curr_stor_track_ind
        != request->flist[f].clist[c].storage_tracking_ind))) )
        IF ((curr_disp_name != request->flist[f].clist[c].display_name))
         CALL update_code_value(dummy_parm1)
        ENDIF
        IF ((curr_stor_track_ind != request->flist[f].clist[c].storage_tracking_ind))
         CALL update_collection_class(dummy_parm1)
        ENDIF
        CALL update_br_coll_class(dummy_parm1)
       ENDIF
      ELSE
       CALL insert_code_value(dummy_parm1)
       IF ((reply_cv->status_data.status="S")
        AND (reply_cv->qual[1].code_value > 0))
        SET coll_class_cd_value = reply_cv->qual[1].code_value
        CALL insert_collection_class(dummy_parm1)
        CALL update_br_coll_class(dummy_parm1)
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
 ENDFOR
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
 CALL echorecord(reply)
 GO TO exit_script
 SUBROUTINE insert_code_value(dummy_parm2)
   SET request_cv->cd_value_list[1].action_flag = 1
   SET request_cv->cd_value_list[1].code_set = 231
   SET request_cv->cd_value_list[1].code_value = 0.0
   SET request_cv->cd_value_list[1].display = request->flist[f].clist[c].display_name
   SET request_cv->cd_value_list[1].display_key = " "
   SET request_cv->cd_value_list[1].description = request->flist[f].clist[c].collection_class
   SET request_cv->cd_value_list[1].definition = request->flist[f].clist[c].collection_class
   SET request_cv->cd_value_list[1].concept_cki = " "
   SET request_cv->cd_value_list[1].active_ind = 1
   SET trace = recpersist
   EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
 END ;Subroutine
 SUBROUTINE update_code_value(dummy_parm2)
   SET request_cv->cd_value_list[1].action_flag = 2
   SET request_cv->cd_value_list[1].code_set = 231
   SET request_cv->cd_value_list[1].code_value = coll_class_cd_value
   SET request_cv->cd_value_list[1].display = request->flist[f].clist[c].display_name
   SET request_cv->cd_value_list[1].display_key = " "
   SET request_cv->cd_value_list[1].definition = request->flist[f].clist[c].display_name
   SET request_cv->cd_value_list[1].active_ind = 1
   SET trace = recpersist
   EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
 END ;Subroutine
 SUBROUTINE insert_collection_class(dummy_parm2)
  IF ((request->flist[f].clist[c].storage_tracking_ind=1))
   SET cont_id_print = "B"
  ELSE
   SET cont_id_print = "N"
  ENDIF
  INSERT  FROM collection_class cc
   SET cc.coll_class_cd = coll_class_cd_value, cc.max_class_volume = 10.0, cc.max_class_vol_units =
    null,
    cc.updt_applctx = reqinfo->updt_applctx, cc.updt_dt_tm = cnvtdatetime(curdate,curtime), cc
    .updt_id = reqinfo->updt_id,
    cc.updt_cnt = 0, cc.updt_task = reqinfo->updt_task, cc.max_accession_size = 12,
    cc.max_class_vol_units_cd = 0.0, cc.def_storage_minutes = 0, cc.symbology = "A",
    cc.smg_barcode_adjust = 0, cc.smg_format = "L", cc.container_id_print = cont_id_print,
    cc.transfer_temp_cd = 0.0, cc.storage_temp_cd = 0.0, cc.sequence = 0
   WITH nocounter
  ;end insert
 END ;Subroutine
 SUBROUTINE update_collection_class(dummy_parm2)
  IF ((request->flist[f].clist[c].storage_tracking_ind=1))
   SET cont_id_print = "B"
  ELSE
   SET cont_id_print = "N"
  ENDIF
  UPDATE  FROM collection_class cc
   SET cc.container_id_print = cont_id_print, cc.updt_applctx = reqinfo->updt_applctx, cc.updt_dt_tm
     = cnvtdatetime(curdate,curtime),
    cc.updt_id = reqinfo->updt_id, cc.updt_cnt = 0, cc.updt_task = reqinfo->updt_task
   WHERE cc.coll_class_cd=coll_class_cd_value
   WITH nocounter
  ;end update
 END ;Subroutine
 SUBROUTINE insert_br_coll_class(dummy_parm2)
  SET prop_name_suff = fillstring(6," ")
  INSERT  FROM br_coll_class bcc
   SET bcc.activity_type = request->activity_type, bcc.collection_class = request->flist[f].clist[c].
    collection_class, bcc.proposed_name_suffix = prop_name_suff,
    bcc.facility_id = request->flist[f].facility_id, bcc.display_name = request->flist[f].clist[c].
    display_name, bcc.storage_tracking_ind = request->flist[f].clist[c].storage_tracking_ind,
    bcc.code_value = coll_class_cd_value, bcc.updt_cnt = 0, bcc.updt_dt_tm = cnvtdatetime(curdate,
     curtime),
    bcc.updt_id = reqinfo->updt_id, bcc.updt_task = reqinfo->updt_task, bcc.updt_applctx = reqinfo->
    updt_applctx
   WITH nocounter
  ;end insert
 END ;Subroutine
 SUBROUTINE update_br_coll_class(dummy_parm2)
   UPDATE  FROM br_coll_class bcc
    SET bcc.display_name = request->flist[f].clist[c].display_name, bcc.storage_tracking_ind =
     request->flist[f].clist[c].storage_tracking_ind, bcc.code_value = coll_class_cd_value,
     bcc.updt_cnt = (bcc.updt_cnt+ 1), bcc.updt_dt_tm = cnvtdatetime(curdate,curtime), bcc.updt_id =
     reqinfo->updt_id,
     bcc.updt_task = reqinfo->updt_task, bcc.updt_applctx = reqinfo->updt_applctx
    WHERE (bcc.activity_type=request->activity_type)
     AND (bcc.collection_class=request->flist[f].clist[c].collection_class)
     AND (bcc.facility_id=request->flist[f].facility_id)
    WITH nocounter
   ;end update
 END ;Subroutine
#exit_script
END GO
