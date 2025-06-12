CREATE PROGRAM bed_ens_ccn_loc_reltn:dba
 FREE SET reply
 RECORD reply(
   1 ccn[*]
     2 id = f8
     2 locations[*]
       3 reltn_id = f8
       3 point_of_service[*]
         4 reltn_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET delete_hist
 RECORD delete_hist(
   1 deleted_item[*]
     2 parent_entity_id = f8
     2 parent_entity_name = vc
 )
 DECLARE delete_hist_cnt = i4 WITH noconstant(0), protect
 DECLARE cnt = i4 WITH noconstant(0), protect
 SET reply->status_data.status = "F"
 DECLARE error_flag = vc WITH protect
 DECLARE serrmsg = vc WITH protect
 DECLARE ierrcode = i4 WITH protect
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 DECLARE bederror(errordescription=vc) = null
 DECLARE bederrorcheck(errordescription=vc) = null
 SUBROUTINE bederror(errordescription)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = errordescription
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE bederrorcheck(errordescription)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   CALL bederror(errordescription)
  ENDIF
 END ;Subroutine
 SET ccnt = size(request->ccn,5)
 SET stat = alterlist(reply->ccn,ccnt)
 FOR (c = 1 TO ccnt)
   SET reply->ccn[c].id = request->ccn[c].id
 ENDFOR
 FOR (c = 1 TO ccnt)
   SET lcnt = size(request->ccn[c].locations,5)
   SET stat = alterlist(reply->ccn[c].locations,lcnt)
   FOR (l = 1 TO lcnt)
     SET reply->ccn[c].locations[l].reltn_id = request->ccn[c].locations[l].reltn_id
   ENDFOR
   IF (lcnt > 0)
    SELECT INTO "nl:"
     FROM br_ccn_loc_ptsvc_reltn b,
      (dummyt d  WITH seq = value(lcnt))
     PLAN (d
      WHERE (request->ccn[c].locations[d.seq].action_flag=3))
      JOIN (b
      WHERE (b.br_ccn_loc_reltn_id=request->ccn[c].locations[d.seq].reltn_id)
       AND b.active_ind=1
       AND b.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     HEAD REPORT
      stat = alterlist(delete_hist->deleted_item,(delete_hist_cnt+ 10)), cnt = 0
     DETAIL
      cnt = (cnt+ 1)
      IF (cnt > 10)
       cnt = 1, stat = alterlist(delete_hist->deleted_item,(delete_hist_cnt+ 10))
      ENDIF
      delete_hist_cnt = (delete_hist_cnt+ 1), delete_hist->deleted_item[delete_hist_cnt].
      parent_entity_id = b.br_ccn_loc_ptsvc_reltn_id, delete_hist->deleted_item[delete_hist_cnt].
      parent_entity_name = "BR_CCN_LOC_PTSVC_RELTN"
     FOOT REPORT
      stat = alterlist(delete_hist->deleted_item,delete_hist_cnt)
     WITH nocounter
    ;end select
    CALL bederrorcheck("DELETEPTSVCHIST1")
    DELETE  FROM br_ccn_loc_ptsvc_reltn b,
      (dummyt d  WITH seq = value(lcnt))
     SET b.seq = 1
     PLAN (d
      WHERE (request->ccn[c].locations[d.seq].action_flag=3))
      JOIN (b
      WHERE (b.br_ccn_loc_reltn_id=request->ccn[c].locations[d.seq].reltn_id)
       AND b.active_ind=1
       AND b.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     WITH nocounter
    ;end delete
    CALL bederrorcheck("DELETEPTSVC1")
    SELECT INTO "nl:"
     FROM br_ccn_loc_reltn b,
      (dummyt d  WITH seq = value(lcnt))
     PLAN (d
      WHERE (request->ccn[c].locations[d.seq].action_flag=3))
      JOIN (b
      WHERE (b.br_ccn_loc_reltn_id=request->ccn[c].locations[d.seq].reltn_id)
       AND b.active_ind=1
       AND b.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     HEAD REPORT
      stat = alterlist(delete_hist->deleted_item,(delete_hist_cnt+ 10)), cnt = 0
     DETAIL
      cnt = (cnt+ 1)
      IF (cnt > 10)
       cnt = 1, stat = alterlist(delete_hist->deleted_item,(delete_hist_cnt+ 10))
      ENDIF
      delete_hist_cnt = (delete_hist_cnt+ 1), delete_hist->deleted_item[delete_hist_cnt].
      parent_entity_id = b.br_ccn_loc_reltn_id, delete_hist->deleted_item[delete_hist_cnt].
      parent_entity_name = "BR_CCN_LOC_RELTN"
     FOOT REPORT
      stat = alterlist(delete_hist->deleted_item,delete_hist_cnt)
     WITH nocounter
    ;end select
    CALL bederrorcheck("DELETECCNLOCHIST")
    DELETE  FROM br_ccn_loc_reltn b,
      (dummyt d  WITH seq = value(lcnt))
     SET b.seq = 1
     PLAN (d
      WHERE (request->ccn[c].locations[d.seq].action_flag=3))
      JOIN (b
      WHERE (b.br_ccn_loc_reltn_id=request->ccn[c].locations[d.seq].reltn_id)
       AND b.active_ind=1
       AND b.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     WITH nocounter
    ;end delete
    CALL bederrorcheck("DELETECCNLOC")
   ENDIF
   SET new_loc_reltn_id = 0.0
   FOR (l = 1 TO lcnt)
     IF ((request->ccn[c].locations[l].action_flag=1))
      SET new_loc_reltn_id = 0.0
      SELECT INTO "nl:"
       z = seq(bedrock_seq,nextval)
       FROM dual
       DETAIL
        new_loc_reltn_id = cnvtreal(z)
       WITH nocounter
      ;end select
      INSERT  FROM br_ccn_loc_reltn b
       SET b.br_ccn_loc_reltn_id = new_loc_reltn_id, b.br_ccn_id = request->ccn[c].id, b.location_cd
         = request->ccn[c].locations[l].code_value,
        b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_task =
        reqinfo->updt_task,
        b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = 0, b.orig_br_ccn_loc_reltn_id =
        new_loc_reltn_id,
        b.active_ind = 1, b.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), b
        .end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00")
       WITH nocounter
      ;end insert
      CALL bederrorcheck("INSERTCCNLOCRELTN")
      SET reply->ccn[c].locations[l].reltn_id = new_loc_reltn_id
     ENDIF
     SET pcnt = size(request->ccn[c].locations[l].point_of_service,5)
     SET stat = alterlist(reply->ccn[c].locations[l].point_of_service,pcnt)
     FOR (p = 1 TO pcnt)
       SET reply->ccn[c].locations[l].point_of_service[p].reltn_id = request->ccn[c].locations[l].
       point_of_service[p].reltn_id
     ENDFOR
     IF (pcnt > 0)
      UPDATE  FROM br_ccn_loc_ptsvc_reltn b,
        (dummyt d  WITH seq = value(pcnt))
       SET b.ptsvc_code_nbr = request->ccn[c].locations[l].point_of_service[d.seq].
        point_of_service_code, b.encntr_type_cd = request->ccn[c].locations[l].point_of_service[d.seq
        ].encounter_type_code_value, b.updt_dt_tm = cnvtdatetime(curdate,curtime3),
        b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->
        updt_applctx,
        b.updt_cnt = (b.updt_cnt+ 1)
       PLAN (d
        WHERE (request->ccn[c].locations[l].point_of_service[d.seq].action_flag=2))
        JOIN (b
        WHERE (b.br_ccn_loc_ptsvc_reltn_id=request->ccn[c].locations[l].point_of_service[d.seq].
        reltn_id)
         AND b.active_ind=1
         AND b.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
       WITH nocounter
      ;end update
      CALL bederrorcheck("UPDTATEPTSVC")
      SELECT INTO "nl:"
       FROM br_ccn_loc_ptsvc_reltn b,
        (dummyt d  WITH seq = value(pcnt))
       PLAN (d
        WHERE (request->ccn[c].locations[l].point_of_service[d.seq].action_flag=3))
        JOIN (b
        WHERE (b.br_ccn_loc_ptsvc_reltn_id=request->ccn[c].locations[l].point_of_service[d.seq].
        reltn_id)
         AND b.active_ind=1
         AND b.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
       HEAD REPORT
        stat = alterlist(delete_hist->deleted_item,(delete_hist_cnt+ 10)), cnt = 0
       DETAIL
        cnt = (cnt+ 1)
        IF (cnt > 10)
         cnt = 1, stat = alterlist(delete_hist->deleted_item,(delete_hist_cnt+ 10))
        ENDIF
        delete_hist_cnt = (delete_hist_cnt+ 1), delete_hist->deleted_item[delete_hist_cnt].
        parent_entity_id = b.br_ccn_loc_ptsvc_reltn_id, delete_hist->deleted_item[delete_hist_cnt].
        parent_entity_name = "BR_CCN_LOC_PTSVC_RELTN"
       FOOT REPORT
        stat = alterlist(delete_hist->deleted_item,delete_hist_cnt)
       WITH nocounter
      ;end select
      CALL bederrorcheck("DELETEPTSVCHIST1")
      DELETE  FROM br_ccn_loc_ptsvc_reltn b,
        (dummyt d  WITH seq = value(pcnt))
       SET b.seq = 1
       PLAN (d
        WHERE (request->ccn[c].locations[l].point_of_service[d.seq].action_flag=3))
        JOIN (b
        WHERE (b.br_ccn_loc_ptsvc_reltn_id=request->ccn[c].locations[l].point_of_service[d.seq].
        reltn_id)
         AND b.active_ind=1
         AND b.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
       WITH nocounter
      ;end delete
      CALL bederrorcheck("DELETEPTSVC")
     ENDIF
     SET new_loc_ptsvc_reltn_id = 0.0
     FOR (p = 1 TO pcnt)
       IF ((request->ccn[c].locations[l].point_of_service[p].action_flag=1))
        SET new_loc_ptsvc_reltn_id = 0.0
        SELECT INTO "nl:"
         z = seq(bedrock_seq,nextval)
         FROM dual
         DETAIL
          new_loc_ptsvc_reltn_id = cnvtreal(z)
         WITH nocounter
        ;end select
        INSERT  FROM br_ccn_loc_ptsvc_reltn b
         SET b.br_ccn_loc_ptsvc_reltn_id = new_loc_ptsvc_reltn_id, b.br_ccn_loc_reltn_id =
          IF ((request->ccn[c].locations[l].action_flag=1)) new_loc_reltn_id
          ELSE request->ccn[c].locations[l].reltn_id
          ENDIF
          , b.ptsvc_code_nbr = request->ccn[c].locations[l].point_of_service[p].point_of_service_code,
          b.encntr_type_cd = request->ccn[c].locations[l].point_of_service[p].
          encounter_type_code_value, b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id =
          reqinfo->updt_id,
          b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = 0,
          b.orig_br_ccn_loc_ptsvc_r_id = new_loc_ptsvc_reltn_id, b.active_ind = 1, b
          .beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
          b.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00")
         WITH nocounter
        ;end insert
        CALL bederrorcheck("INSERTPTSVC")
        SET reply->ccn[c].locations[l].point_of_service[p].reltn_id = new_loc_ptsvc_reltn_id
       ENDIF
     ENDFOR
   ENDFOR
 ENDFOR
 IF (delete_hist_cnt > 0)
  INSERT  FROM br_delete_hist his,
    (dummyt d  WITH seq = delete_hist_cnt)
   SET his.br_delete_hist_id = seq(bedrock_seq,nextval), his.parent_entity_name = delete_hist->
    deleted_item[d.seq].parent_entity_name, his.parent_entity_id = delete_hist->deleted_item[d.seq].
    parent_entity_id,
    his.updt_dt_tm = cnvtdatetime(curdate,curtime3), his.updt_id = reqinfo->updt_id, his.updt_task =
    reqinfo->updt_task,
    his.updt_cnt = 0, his.updt_applctx = reqinfo->updt_applctx, his.create_dt_tm = cnvtdatetime(
     curdate,curtime3)
   PLAN (d)
    JOIN (his)
   WITH nocounter
  ;end insert
  CALL bederrorcheck("DELETEINSERT")
 ENDIF
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
 CALL echorecord(reply)
END GO
