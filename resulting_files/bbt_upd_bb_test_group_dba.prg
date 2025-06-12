CREATE PROGRAM bbt_upd_bb_test_group:dba
 RECORD reply(
   1 bb_test_group_id = f8
   1 qual[*]
     2 catalog_cd = f8
     2 bb_group_component_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET new_bb_test_group_id = 0.0
 SET new_bb_group_component_id = 0.0
 SET qual_cnt = 0
 SET cmpnt_cnt = 0
 SET cmpnt = 0
 SET stat = alterlist(reply->qual,10)
 IF ((request->bb_test_group_id=0))
  SET new_bb_test_group_id = next_pathnet_seq(0)
  IF (curqual=0)
   CALL load_process_status("F","get next pathnet_seq",build(
     "get next pathnet_seq failed--bb_test_group_id =",request->bb_test_group_id))
   GO TO exit_script
  ENDIF
  INSERT  FROM bb_test_group btg
   SET btg.bb_test_group_id = new_bb_test_group_id, btg.test_group_description = request->
    test_group_description, btg.test_group_display = request->test_group_display,
    btg.updt_cnt = 0, btg.updt_dt_tm = cnvtdatetime(curdate,curtime3), btg.updt_id = reqinfo->updt_id,
    btg.updt_task = reqinfo->updt_task, btg.updt_applctx = reqinfo->updt_applctx, btg.active_ind = 1,
    btg.active_status_cd = reqdata->active_status_cd, btg.active_status_dt_tm = cnvtdatetime(curdate,
     curtime3), btg.active_status_prsnl_id = reqinfo->updt_id
   WITH nocounter
  ;end insert
  IF (curqual=0)
   CALL load_process_status("F","insert into bb_test_group",build(
     "insert into bb_test_group failed--bb_test_group_id =",request->bb_test_group_id))
   GO TO exit_script
  ENDIF
  CALL process_bb_group_component(new_bb_test_group_id)
  SET reply->bb_test_group_id = new_bb_test_group_id
 ELSE
  IF ((request->test_group_changed_ind=1))
   SELECT INTO "nl:"
    btg.bb_test_group_id
    FROM bb_test_group btg
    WHERE (btg.bb_test_group_id=request->bb_test_group_id)
     AND (btg.updt_cnt=request->updt_cnt)
    WITH nocounter, forupdate(btg)
   ;end select
   IF (curqual=0)
    CALL load_process_status("F","lock bb_test_group forupdate",build(
      "lock bb_test_group forupdate failed--bb_test_group_id =",request->bb_test_group_id))
    GO TO exit_script
   ENDIF
   UPDATE  FROM bb_test_group btg
    SET btg.test_group_description = request->test_group_description, btg.updt_cnt = (btg.updt_cnt+ 1
     ), btg.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     btg.updt_id = reqinfo->updt_id, btg.updt_task = reqinfo->updt_task, btg.updt_applctx = reqinfo->
     updt_applctx,
     btg.active_ind = request->active_ind, btg.active_status_cd =
     IF ((request->active_ind=1)) reqdata->active_status_cd
     ELSE reqdata->inactive_status_cd
     ENDIF
     , btg.active_status_dt_tm = cnvtdatetime(curdate,curtime3),
     btg.active_status_prsnl_id = reqinfo->updt_id
    WHERE (btg.bb_test_group_id=request->bb_test_group_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    CALL load_process_status("F","update into bb_test_group",build(
      "update into bb_test_group failed--bb_test_group_id =",request->bb_test_group_id))
    GO TO exit_script
   ENDIF
  ENDIF
  CALL process_bb_group_component(request->bb_test_group_id)
 ENDIF
 CALL load_process_status("S","SUCCESS","All records added/updated successfully")
 GO TO exit_script
 SUBROUTINE process_bb_group_component(sub_bb_test_group_id)
   SET stat = alterlist(reply->qual,10)
   SET cmpnt_cnt = size(request->cmpntlist,5)
   FOR (cmpnt = 1 TO cmpnt_cnt)
     IF ((request->cmpntlist[cmpnt].bb_group_component_id=0))
      SET new_bb_group_component_id = next_pathnet_seq(0)
      IF (curqual=0)
       CALL load_process_status("F","get next pathnet_seq",build(
         "get next pathnet_seq failed--bb_test_group_id =",request->cmpntlist[cmpnt].bb_test_group_id
         ))
       GO TO exit_script
      ENDIF
      INSERT  FROM bb_group_component bgc
       SET bgc.bb_group_component_id = new_bb_group_component_id, bgc.bb_test_group_id =
        sub_bb_test_group_id, bgc.catalog_cd = request->cmpntlist[cmpnt].catalog_cd,
        bgc.sequence = request->cmpntlist[cmpnt].sequence, bgc.updt_cnt = 0, bgc.updt_dt_tm =
        cnvtdatetime(curdate,curtime3),
        bgc.updt_id = reqinfo->updt_id, bgc.updt_task = reqinfo->updt_task, bgc.updt_applctx =
        reqinfo->updt_applctx,
        bgc.active_ind = 1, bgc.active_status_cd = reqdata->active_status_cd, bgc.active_status_dt_tm
         = cnvtdatetime(curdate,curtime3),
        bgc.active_status_prsnl_id = reqinfo->updt_id
       WITH nocounter
      ;end insert
      IF (curqual=0)
       CALL load_process_status("F","insert into bb_group_component",build(
         "insert into bb_group_component failed--bb_test_group_id =",request->cmpntlist[cmpnt].
         bb_test_group_id))
       GO TO exit_script
      ENDIF
      SET qual_cnt = (qual_cnt+ 1)
      IF (mod(qual_cnt,10)=1
       AND qual_cnt != 1)
       SET stat = alterlist(reply->qual,(qual_cnt+ 9))
      ENDIF
      SET reply->qual[qual_cnt].catalog_cd = request->cmpntlist[cmpnt].catalog_cd
      SET reply->qual[qual_cnt].bb_group_component_id = new_bb_group_component_id
     ELSE
      SELECT INTO "nl:"
       bgc.bb_group_component_id
       FROM bb_group_component bgc
       WHERE (bgc.bb_group_component_id=request->cmpntlist[cmpnt].bb_group_component_id)
        AND (bgc.updt_cnt=request->cmpntlist[cmpnt].updt_cnt)
       WITH nocounter, forupdate(bgc)
      ;end select
      IF (curqual=0)
       CALL load_process_status("F","lock bb_group_component forupdate",build(
         "lock bb_group_component forupdate failed--bb_test_group_id =",request->cmpntlist[cmpnt].
         bb_test_group_id))
       GO TO exit_script
      ENDIF
      UPDATE  FROM bb_group_component bgc
       SET bgc.sequence = request->cmpntlist[cmpnt].sequence, bgc.updt_cnt = (bgc.updt_cnt+ 1), bgc
        .updt_dt_tm = cnvtdatetime(curdate,curtime3),
        bgc.updt_id = reqinfo->updt_id, bgc.updt_task = reqinfo->updt_task, bgc.updt_applctx =
        reqinfo->updt_applctx,
        bgc.active_ind = request->cmpntlist[cmpnt].active_ind, bgc.active_status_cd =
        IF ((request->cmpntlist[cmpnt].active_ind=1)) reqdata->active_status_cd
        ELSE reqdata->inactive_status_cd
        ENDIF
        , bgc.active_status_dt_tm = cnvtdatetime(curdate,curtime3),
        bgc.active_status_prsnl_id = reqinfo->updt_id
       WHERE (bgc.bb_group_component_id=request->cmpntlist[cmpnt].bb_group_component_id)
       WITH nocounter
      ;end update
      IF (curqual=0)
       CALL load_process_status("F","update into bb_group_component",build(
         "update into bb_group_component failed--bb_test_group_id =",request->cmpntlist[cmpnt].
         bb_test_group_id))
       GO TO exit_script
      ENDIF
     ENDIF
   ENDFOR
   SET stat = alterlist(reply->qual,qual_cnt)
 END ;Subroutine
 DECLARE next_pathnet_seq(pathnet_seq_dummy) = f8
 DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
 SUBROUTINE next_pathnet_seq(pathnet_seq_dummy)
   SET new_pathnet_seq = 0.0
   SELECT INTO "nl:"
    seqn = seq(pathnet_seq,nextval)
    FROM dual
    DETAIL
     new_pathnet_seq = seqn
    WITH format, nocounter
   ;end select
   RETURN(new_pathnet_seq)
 END ;Subroutine
 SUBROUTINE load_process_status(sub_status,sub_process,sub_message)
   SET reply->status_data.status = sub_status
   SET count1 = (count1+ 1)
   IF (count1 > 1)
    SET stat = alter(reply->status_data.subeventstatus,(count1+ 1))
   ENDIF
   SET reply->status_data.subeventstatus[count1].operationname = sub_process
   SET reply->status_data.subeventstatus[count1].operationstatus = sub_status
   SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_upd_bb_test_group"
   SET reply->status_data.subeventstatus[count1].targetobjectvalue = sub_message
 END ;Subroutine
#exit_script
 IF ((reply->status_data.status="S"))
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
