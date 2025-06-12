CREATE PROGRAM ags_mak_pvd_prsnl_tasks:dba
 CALL echo("***")
 CALL echo("***   BEG AGS_MAK_PVD_PRSNL_TASKS")
 CALL echo("***")
 DECLARE found_prsnl = i2 WITH public, noconstant(true)
 DECLARE found_info = i2 WITH public, noconstant(false)
 DECLARE min_batch_id = f8 WITH public, noconstant(0.0)
 DECLARE max_batch_id = f8 WITH public, noconstant(0.0)
 DECLARE temp_batch_id = f8 WITH public, noconstant(0.0)
 DECLARE batch_size = i4 WITH public, constant(5000)
 DECLARE max_task_size = i4 WITH public, noconstant(1000000)
 IF ((data_info->task_size > 0))
  SET max_task_size = data_info->task_size
 ENDIF
 SET log->qual_knt = (log->qual_knt+ 1)
 SET stat = alterlist(log->qual,log->qual_knt)
 SET log->qual[log->qual_knt].smsgtype = "INFO"
 SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
 SET log->qual[log->qual_knt].smsg = "BEG >> AGS_MAK_PVD_PRSNL_TASKS"
 CALL echo("***")
 CALL echo("***   DM_INFO Check")
 CALL echo("***")
 SELECT INTO "nl:"
  FROM dm_info di
  PLAN (di
   WHERE di.info_name="PROVIDER_DIRECTORY"
    AND di.info_domain="AGS")
  DETAIL
   found_info = true
  WITH nocounter
 ;end select
 IF (found_info=false)
  EXECUTE gm_dm_info2388_def "I"
  DECLARE gm_i_dm_info2388_vc(icol_name=vc,ival=vc,iqual=i4,null_ind=i2) = i2
  DECLARE gm_i_dm_info2388_dq8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) = i2
  DECLARE gm_i_dm_info2388_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) = i2
  SUBROUTINE gm_i_dm_info2388_f8(icol_name,ival,iqual,null_ind)
    DECLARE stat = i2 WITH protect, noconstant(0)
    IF (size(gm_i_dm_info2388_req->qual,5) < iqual)
     SET stat = alterlist(gm_i_dm_info2388_req->qual,iqual)
     IF (stat=0)
      CALL echo("can not expand request structure")
      RETURN(0)
     ENDIF
    ENDIF
    CASE (cnvtlower(icol_name))
     OF "info_number":
      SET gm_i_dm_info2388_req->qual[iqual].info_number = ival
      SET gm_i_dm_info2388_req->info_numberi = 1
     OF "info_long_id":
      IF (null_ind=1)
       CALL echo("error can not set this column to null")
       RETURN(0)
      ENDIF
      SET gm_i_dm_info2388_req->qual[iqual].info_long_id = ival
      SET gm_i_dm_info2388_req->info_long_idi = 1
     ELSE
      CALL echo("invalid column name passed")
      RETURN(0)
    ENDCASE
    RETURN(1)
  END ;Subroutine
  SUBROUTINE gm_i_dm_info2388_dq8(icol_name,ival,iqual,null_ind)
    DECLARE stat = i2 WITH protect, noconstant(0)
    IF (size(gm_i_dm_info2388_req->qual,5) < iqual)
     SET stat = alterlist(gm_i_dm_info2388_req->qual,iqual)
     IF (stat=0)
      CALL echo("can not expand request structure")
      RETURN(0)
     ENDIF
    ENDIF
    CASE (cnvtlower(icol_name))
     OF "info_date":
      SET gm_i_dm_info2388_req->qual[iqual].info_date = cnvtdatetime(ival)
      SET gm_i_dm_info2388_req->info_datei = 1
     OF "updt_dt_tm":
      IF (null_ind=1)
       CALL echo("error can not set this column to null")
       RETURN(0)
      ENDIF
      SET gm_i_dm_info2388_req->qual[iqual].updt_dt_tm = cnvtdatetime(ival)
      SET gm_i_dm_info2388_req->updt_dt_tmi = 1
     ELSE
      CALL echo("invalid column name passed")
      RETURN(0)
    ENDCASE
    RETURN(1)
  END ;Subroutine
  SUBROUTINE gm_i_dm_info2388_vc(icol_name,ival,iqual,null_ind)
    DECLARE stat = i2 WITH protect, noconstant(0)
    IF (size(gm_i_dm_info2388_req->qual,5) < iqual)
     SET stat = alterlist(gm_i_dm_info2388_req->qual,iqual)
     IF (stat=0)
      CALL echo("can not expand request structure")
      RETURN(0)
     ENDIF
    ENDIF
    CASE (cnvtlower(icol_name))
     OF "info_domain":
      IF (null_ind=1)
       CALL echo("error can not set this column to null")
       RETURN(0)
      ENDIF
      SET gm_i_dm_info2388_req->qual[iqual].info_domain = ival
      SET gm_i_dm_info2388_req->info_domaini = 1
     OF "info_name":
      IF (null_ind=1)
       CALL echo("error can not set this column to null")
       RETURN(0)
      ENDIF
      SET gm_i_dm_info2388_req->qual[iqual].info_name = ival
      SET gm_i_dm_info2388_req->info_namei = 1
     OF "info_char":
      SET gm_i_dm_info2388_req->qual[iqual].info_char = ival
      SET gm_i_dm_info2388_req->info_chari = 1
     ELSE
      CALL echo("invalid column name passed")
      RETURN(0)
    ENDCASE
    RETURN(1)
  END ;Subroutine
  SET gm_i_dm_info2388_req->allow_partial_ind = 0
  SET gm_i_dm_info2388_req->info_domaini = 1
  SET gm_i_dm_info2388_req->info_namei = 1
  SET gm_i_dm_info2388_req->info_datei = 0
  SET gm_i_dm_info2388_req->info_chari = 0
  SET gm_i_dm_info2388_req->info_numberi = 1
  SET gm_i_dm_info2388_req->info_long_idi = 0
  SET gm_i_dm_info2388_req->info_daten = 1
  SET gm_i_dm_info2388_req->info_charn = 1
  SET gm_i_dm_info2388_req->info_numbern = 0
  SET stat = alterlist(gm_i_dm_info2388_req->qual,1)
  SET gm_i_dm_info2388_req->qual[1].info_domain = "AGS"
  SET gm_i_dm_info2388_req->qual[1].info_name = "PROVIDER_DIRECTORY"
  SET gm_i_dm_info2388_req->qual[1].info_number = 1
  EXECUTE gm_i_dm_info2388  WITH replace(request,gm_i_dm_info2388_req), replace(reply,
   gm_i_dm_info2388_rep)
  FREE RECORD gm_i_dm_info2388_req
  FREE RECORD gm_i_dm_info2388_rep
 ENDIF
 CALL echo("***")
 CALL echo("***   Find PRSNL Batch Id Values")
 CALL echo("***")
 SET min_batch_id = 0.0
 SET max_batch_id = 0.0
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  little_id = min(p.ags_prsnl_data_id), big_id = max(p.ags_prsnl_data_id)
  FROM ags_prsnl_data p
  PLAN (p
   WHERE (p.ags_job_id=data_info->ags_job_id)
    AND p.status="LOADING")
  FOOT REPORT
   min_batch_id = little_id, max_batch_id = big_id
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "GET BATCH_ID VALUES"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("GET PRSNL BATCH_ID VALUES :: Select Error :: ",trim(
    serrmsg))
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 CALL echo("***")
 CALL echo(build("***   AGS_PRSNL_DATA min_batch_id :",min_batch_id))
 CALL echo(build("***   AGS_PRSNL_DATA max_batch_id :",max_batch_id))
 CALL echo("***")
 IF (((min_batch_id < 1) OR (max_batch_id < 1)) )
  SET found_prsnl = false
  SET ilog_status = 2
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "WARNING"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = "No PRSNL task found"
  GO TO exit_script
 ENDIF
 CALL echo("***")
 CALL echo("***   Insert PRSNL Task")
 CALL echo("***")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 INSERT  FROM ags_task t
  SET t.ags_task_id = seq(gs_seq,nextval), t.ags_job_id = data_info->ags_job_id, t.task_type =
   "PRSNL",
   t.batch_program = "ags_load_prsnl", t.batch_start_id = min_batch_id, t.batch_end_id = max_batch_id,
   t.batch_size = batch_size, t.status = "WAITING", t.status_dt_tm = cnvtdatetime(curdate,curtime3)
  PLAN (t
   WHERE 1=1)
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  ROLLBACK
  SET failed = insert_error
  SET table_name = "AGS_TASK"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("INSERT AGS_TASK ITEMS :: Insert Error :: ",trim(serrmsg
    ))
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 COMMIT
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 UPDATE  FROM ags_prsnl_data o
  SET o.status = "WAITING", o.status_dt_tm = cnvtdatetime(curdate,curtime3)
  PLAN (o
   WHERE (o.ags_job_id=data_info->ags_job_id)
    AND o.status="LOADING")
  WITH nocounter
 ;end update
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  ROLLBACK
  SET failed = update_error
  SET table_name = "AGS_PRSNL_DATA"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("UPDATE AGS_PRSNL_DATA ITEMS :: Update Error :: ",trim(
    serrmsg))
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 COMMIT
#exit_script
 SET log->qual_knt = (log->qual_knt+ 1)
 SET stat = alterlist(log->qual,log->qual_knt)
 SET log->qual[log->qual_knt].smsgtype = "INFO"
 SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
 SET log->qual[log->qual_knt].smsg = "END >> AGS_MAK_PVD_PRSNL_TASKS"
 CALL echo("***")
 CALL echo("***   END AGS_MAK_PVD_PRSNL_TASKS")
 CALL echo("***")
 SET script_ver = "002 08/03/06"
END GO
