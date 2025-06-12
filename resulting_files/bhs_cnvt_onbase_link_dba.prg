CREATE PROGRAM bhs_cnvt_onbase_link:dba
 DECLARE ml_loop_ind = i4 WITH protect, noconstant(1)
 DECLARE ml_exp_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_for_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_updt_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_ins_cnt = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE mf_start_pos = f8 WITH protect, noconstant( $1)
 DECLARE mf_end_pos = f8 WITH protect, noconstant( $2)
 FREE RECORD onbase
 RECORD onbase(
   1 cnt = i4
   1 qual[*]
     2 blob_handle = vc
     2 onbase_stage_id = f8
     2 onbase_url = vc
     2 updt_qual = i4
 )
 FREE RECORD cis
 RECORD cis(
   1 cnt = i4
   1 qual[*]
     2 blob_handle = vc
     2 event_id = f8
     2 valid_date = f8
 )
 SET onbase->cnt = 0
 SET stat = alterlist(onbase->qual,0)
 SELECT INTO "nl:"
  FROM bhs_onbase_stage@jtest bos
  WHERE bos.onbase_stage_id >= mf_start_pos
   AND bos.onbase_stage_id < mf_end_pos
   AND bos.update_ind=0
  DETAIL
   onbase->cnt = (onbase->cnt+ 1), stat = alterlist(onbase->qual,onbase->cnt), onbase->qual[onbase->
   cnt].blob_handle = bos.blob_handle,
   onbase->qual[onbase->cnt].onbase_url = bos.onbase_url, onbase->qual[onbase->cnt].onbase_stage_id
    = bos.onbase_stage_id
  WITH nocounter, maxqual(bos,1000)
 ;end select
 SET errcode = error(errmsg,0)
 IF (errcode != 0)
  CALL echo("ERROR")
  CALL echo(errmsg)
  GO TO exit_script
 ENDIF
 IF ((onbase->cnt != 0))
  FOR (ml_for_cnt = 1 TO onbase->cnt)
    SET cis->cnt = 0
    SET stat = alterlist(cis->qual,0)
    SET ml_updt_cnt = (ml_updt_cnt+ 1)
    SET mf_total_rows = (mf_total_rows+ 1)
    CALL echo(build("WORKING ON #",mf_total_rows))
    SELECT INTO "nl:"
     FROM ce_blob_result cbr
     WHERE cbr.blob_handle=patstring(concat(trim(onbase->qual[ml_for_cnt].blob_handle,3),"*"))
     DETAIL
      cis->cnt = (cis->cnt+ 1), stat = alterlist(cis->qual,cis->cnt), cis->qual[cis->cnt].event_id =
      cbr.event_id,
      cis->qual[cis->cnt].blob_handle = cbr.blob_handle, cis->qual[cis->cnt].valid_date = cbr
      .valid_until_dt_tm
     WITH nocounter
    ;end select
    SET errcode = error(errmsg,0)
    IF (errcode != 0)
     CALL echo("ERROR")
     CALL echo(errmsg)
     GO TO exit_script
    ENDIF
    IF ((cis->cnt > 0))
     FOR (ml_ins_cnt = 1 TO cis->cnt)
       CALL echo(build("Inserting# ",ml_ins_cnt," ::: ",mf_total_rows))
       INSERT  FROM (v500_bhs.onbase_conv_saves@jtest bocs)
        SET bocs.event_id = cis->qual[ml_ins_cnt].event_id, bocs.blob_handle = cis->qual[ml_ins_cnt].
         blob_handle, bocs.valid_until_dt_tm = cnvtdatetime(cis->qual[ml_ins_cnt].valid_date),
         bocs.updt_dt_tm = cnvtdatetime(curdate,curtime3)
        WITH nocounter
       ;end insert
       SET errcode = error(errmsg,0)
       IF (errcode != 0)
        CALL echo("ERROR")
        CALL echo(errmsg)
        GO TO exit_script
       ENDIF
     ENDFOR
     CALL echo("Updating main row")
     UPDATE  FROM ce_blob_result cbr
      SET cbr.storage_cd = 643452.00, cbr.blob_handle = onbase->qual[ml_for_cnt].onbase_url
      WHERE cbr.blob_handle=patstring(concat(trim(onbase->qual[ml_for_cnt].blob_handle,3),"*"))
      WITH nocounter
     ;end update
     SET errcode = error(errmsg,0)
     IF (errcode != 0)
      CALL echo("ERROR")
      CALL echo(errmsg)
      GO TO exit_script
     ENDIF
     COMMIT
    ENDIF
  ENDFOR
  UPDATE  FROM bhs_onbase_stage@jtest bos
   SET update_ind = 1
   WHERE expand(ml_exp_cnt,1,onbase->cnt,bos.onbase_stage_id,onbase->qual[ml_exp_cnt].onbase_stage_id
    )
   WITH nocounter
  ;end update
  SET errcode = error(errmsg,0)
  IF (errcode != 0)
   CALL echo("ERROR")
   CALL echo(errmsg)
   GO TO exit_script
  ENDIF
  COMMIT
 ENDIF
#exit_script
END GO
