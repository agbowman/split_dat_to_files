CREATE PROGRAM bbt_upd_alpha_trans:dba
 RECORD reply(
   1 qual[*]
     2 spread_sheet_row = i4
     2 alpha_translation_id = f8
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
 SET new_alpha_translation_id = 0.0
 SET qual_cnt = 0
 SET stat = alterlist(reply->qual,10)
 SET alphatrans_count = size(request->alphatranslist,5)
 FOR (alphatrans = 1 TO alphatrans_count)
   IF ((request->alphatranslist[alphatrans].alpha_translation_id=0))
    SET new_alpha_translation_id = next_pathnet_seq(0)
    IF (curqual=0)
     CALL load_process_status("F","get next pathnet_seq",build(
       "get next pathnet_seq failed--alpha_translation_id =",request->alphatranslist[alphatrans].
       alpha_translation_id))
     GO TO exit_script
    ENDIF
    INSERT  FROM bb_alpha_translation bba
     SET bba.alpha_translation_id = new_alpha_translation_id, bba.alpha_barcode_value = request->
      alphatranslist[alphatrans].alpha_barcode_value, bba.alpha_translation_value = request->
      alphatranslist[alphatrans].alpha_translation_value,
      bba.updt_cnt = 0, bba.updt_dt_tm = cnvtdatetime(curdate,curtime3), bba.updt_id = reqinfo->
      updt_id,
      bba.updt_task = reqinfo->updt_task, bba.updt_applctx = reqinfo->updt_applctx, bba.active_ind =
      1,
      bba.active_status_cd = reqdata->active_status_cd, bba.active_status_dt_tm = cnvtdatetime(
       curdate,curtime3), bba.active_status_prsnl_id = reqinfo->updt_id
     WITH nocounter
    ;end insert
    IF (curqual=0)
     CALL load_process_status("F","insert into bb_alpha_translation",build(
       "insert into bb_alpha_translation failed--alpha_translation_id =",request->alphatranslist[
       alphatrans].alpha_translation_id))
     GO TO exit_script
    ENDIF
    SET qual_cnt = (qual_cnt+ 1)
    IF (mod(qual_cnt,10)=1
     AND qual_cnt != 1)
     SET stat = alterlist(reply->qual,(qual_cnt+ 9))
    ENDIF
    SET reply->qual[qual_cnt].spread_sheet_row = request->alphatranslist[alphatrans].spread_sheet_row
    SET reply->qual[qual_cnt].alpha_translation_id = new_alpha_translation_id
   ELSE
    SELECT INTO "nl:"
     bba.alpha_translation_id
     FROM bb_alpha_translation bba
     WHERE (bba.alpha_translation_id=request->alphatranslist[alphatrans].alpha_translation_id)
      AND (bba.updt_cnt=request->alphatranslist[alphatrans].updt_cnt)
     WITH nocounter, forupdate(bba)
    ;end select
    IF (curqual=0)
     CALL load_process_status("F","lock bb_alpha_translation forupdate",build(
       "lock bb_alpha_translation forupdate failed--alpha_translation_id =",request->alphatranslist[
       alphatrans].alpha_translation_id))
     GO TO exit_script
    ENDIF
    UPDATE  FROM bb_alpha_translation bba
     SET bba.active_ind = request->alphatranslist[alphatrans].active_ind, bba.updt_cnt = (bba
      .updt_cnt+ 1), bba.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      bba.updt_id = reqinfo->updt_id, bba.updt_task = reqinfo->updt_task, bba.updt_applctx = reqinfo
      ->updt_applctx,
      bba.active_status_cd =
      IF ((request->alphatranslist[alphatrans].active_ind=1)) reqdata->active_status_cd
      ELSE reqdata->inactive_status_cd
      ENDIF
      , bba.active_status_dt_tm = cnvtdatetime(curdate,curtime3), bba.active_status_prsnl_id =
      reqinfo->updt_id
     WHERE (bba.alpha_translation_id=request->alphatranslist[alphatrans].alpha_translation_id)
     WITH nocounter
    ;end update
    IF (curqual=0)
     CALL load_process_status("F","update into bb_alpha_translation",build(
       "update into bb_alpha_translation failed-alpha_translation_id =",request->alphatranslist[
       alphatrans].alpha_translation_id))
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
 SET stat = alterlist(reply->qual,qual_cnt)
 CALL load_process_status("S","SUCCESS","All records added/updated successfully")
 GO TO exit_script
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
   SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_upd_alpha_trans"
   SET reply->status_data.subeventstatus[count1].targetobjectvalue = sub_message
 END ;Subroutine
#exit_script
 IF ((reply->status_data.status="S"))
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
