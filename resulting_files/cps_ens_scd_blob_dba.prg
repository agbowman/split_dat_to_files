CREATE PROGRAM cps_ens_scd_blob:dba
 FREE RECORD compressed_blob
 RECORD compressed_blob(
   1 long_blobs[*]
     2 long_blob = vgc
     2 sequence_number = i4
     2 original_blob_length = i4
     2 compression_cd = f8
 )
 IF (validate(reply,"0")="0")
  RECORD reply(
    1 scd_blob_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
    1 cps_error
      2 cnt = i4
      2 data[*]
        3 code = i4
        3 severity_level = i4
        3 supp_err_txt = c32
        3 def_msg = vc
        3 row_data
          4 lvl_1_idx = i4
          4 lvl_2_idx = i4
          4 lvl_3_idx = i4
  )
 ENDIF
 IF (validate(cps_lock)=0)
  DECLARE cps_lock = i4 WITH public, constant(100)
  DECLARE cps_no_seq = i4 WITH public, constant(101)
  DECLARE cps_updt_cnt = i4 WITH public, constant(102)
  DECLARE cps_insuf_data = i4 WITH public, constant(103)
  DECLARE cps_update = i4 WITH public, constant(104)
  DECLARE cps_insert = i4 WITH public, constant(105)
  DECLARE cps_delete = i4 WITH public, constant(106)
  DECLARE cps_select = i4 WITH public, constant(107)
  DECLARE cps_auth = i4 WITH public, constant(108)
  DECLARE cps_inval_data = i4 WITH public, constant(109)
  DECLARE cps_ens_note_story_not_locked = i4 WITH public, constant(110)
  DECLARE cps_lock_msg = c33 WITH public, constant("Failed to lock all requested rows")
  DECLARE cps_no_seq_msg = c34 WITH public, constant("Failed to get next sequence number")
  DECLARE cps_updt_cnt_msg = c28 WITH public, constant("Failed to match update count")
  DECLARE cps_insuf_data_msg = c38 WITH public, constant("Request did not supply sufficient data")
  DECLARE cps_update_msg = c24 WITH public, constant("Failed on update request")
  DECLARE cps_insert_msg = c24 WITH public, constant("Failed on insert request")
  DECLARE cps_delete_msg = c24 WITH public, constant("Failed on delete request")
  DECLARE cps_select_msg = c24 WITH public, constant("Failed on select request")
  DECLARE cps_auth_msg = c34 WITH public, constant("Failed on authorization of request")
  DECLARE cps_inval_data_msg = c35 WITH public, constant("Request contained some invalid data")
  DECLARE cps_success = i4 WITH public, constant(0)
  DECLARE cps_success_info = i4 WITH public, constant(1)
  DECLARE cps_success_warn = i4 WITH public, constant(2)
  DECLARE cps_deadlock = i4 WITH public, constant(3)
  DECLARE cps_script_fail = i4 WITH public, constant(4)
  DECLARE cps_sys_fail = i4 WITH public, constant(5)
  SUBROUTINE cps_add_error(cps_errcode,severity_level,supp_err_txt,def_msg,idx1,idx2,idx3)
    SET reply->cps_error.cnt = (reply->cps_error.cnt+ 1)
    SET errcnt = reply->cps_error.cnt
    SET stat = alterlist(reply->cps_error.data,errcnt)
    SET reply->cps_error.data[errcnt].code = cps_errcode
    SET reply->cps_error.data[errcnt].severity_level = severity_level
    SET reply->cps_error.data[errcnt].supp_err_txt = supp_err_txt
    SET reply->cps_error.data[errcnt].def_msg = def_msg
    SET reply->cps_error.data[errcnt].row_data.lvl_1_idx = idx1
    SET reply->cps_error.data[errcnt].row_data.lvl_2_idx = idx2
    SET reply->cps_error.data[errcnt].row_data.lvl_3_idx = idx3
  END ;Subroutine
 ENDIF
 DECLARE very_unique_id = f8 WITH protect, noconstant(0)
 DECLARE ocfcomp_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",120,"OCFCOMP"))
 DECLARE nocomp_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",120,"NOCOMP"))
 DECLARE icompressedlen = i4 WITH protect, noconstant(0)
 DECLARE number_blobs = i4 WITH protect, noconstant(0)
 SET blob_failed = 0
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 SET number_blobs = size(request->long_blobs,5)
 IF (number_blobs=0)
  SET blob_failed = 1
  CALL cps_add_error(cps_insuf_data,cps_script_fail,"No BLOBS specified",cps_insuf_data_msg,0,
   0,0)
  GO TO exit_script
 ENDIF
 CALL scdgetuniqueid(very_unique_id)
 IF (blob_failed=1)
  GO TO exit_script
 ENDIF
 SET reply->scd_blob_id = very_unique_id
 SET stat = initrec(compressed_blob)
 SET stat = alterlist(compressed_blob->long_blobs,number_blobs)
 FOR (blob_idx = 1 TO number_blobs)
   SET icompressedlen = 0
   SET compressed_blob->long_blobs[blob_idx].long_blob = notrim(request->long_blobs[blob_idx].
    long_blob)
   SET compressed_blob->long_blobs[blob_idx].original_blob_length = size(request->long_blobs[blob_idx
    ].long_blob)
   SET iret = uar_ocf_compress(notrim(request->long_blobs[blob_idx].long_blob),size(request->
     long_blobs[blob_idx].long_blob),compressed_blob->long_blobs[blob_idx].long_blob,size(request->
     long_blobs[blob_idx].long_blob),icompressedlen)
   IF (((iret=0) OR ((icompressedlen >= compressed_blob->long_blobs[blob_idx].original_blob_length)
   )) )
    SET compressed_blob->long_blobs[blob_idx].compression_cd = nocomp_cd
    SET compressed_blob->long_blobs[blob_idx].long_blob = notrim(request->long_blobs[blob_idx].
     long_blob)
   ELSE
    SET compressed_blob->long_blobs[blob_idx].compression_cd = ocfcomp_cd
    SET compressed_blob->long_blobs[blob_idx].long_blob = substring(1,icompressedlen,notrim(
      compressed_blob->long_blobs[blob_idx].long_blob))
   ENDIF
 ENDFOR
 INSERT  FROM scd_blob b
  SET b.scd_blob_id = very_unique_id, b.format_cd = request->format_cd
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET blob_failed = 1
  CALL cps_add_error(cps_insert,cps_script_fail,"INSERTING SCD_BLOB",cps_insert_msg,0,
   0,0)
  GO TO exit_script
 ENDIF
 INSERT  FROM long_blob b,
   (dummyt d  WITH seq = value(number_blobs))
  SET b.long_blob_id = cnvtreal(seq(long_data_seq,nextval)), b.parent_entity_name = "SCD_BLOB", b
   .parent_entity_id = very_unique_id,
   b.long_blob = compressed_blob->long_blobs[d.seq].long_blob, b.blob_length = compressed_blob->
   long_blobs[d.seq].original_blob_length, b.updt_cnt = 0,
   b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo
   ->updt_task,
   b.updt_applctx = reqinfo->updt_applctx, b.active_ind = 1, b.active_status_cd = reqdata->
   active_status_cd,
   b.active_status_dt_tm = cnvtdatetime(curdate,curtime3), b.active_status_prsnl_id = reqinfo->
   updt_id, b.compression_cd = compressed_blob->long_blobs[d.seq].compression_cd
  PLAN (d)
   JOIN (b)
  WITH nocounter
 ;end insert
 IF (curqual != number_blobs)
  SET blob_failed = 1
  CALL cps_add_error(cps_insert,cps_script_fail,"INSERTING LONG BLOBS",cps_insert_msg,curqual,
   0,0)
  GO TO exit_script
 ENDIF
 SUBROUTINE scdgetuniqueid(dummy_var)
  SELECT INTO "nl:"
   next_seq = seq(scd_act_seq,nextval)"##################;rp0"
   FROM dual
   DETAIL
    very_unique_id = cnvtreal(next_seq)
   WITH format, nocounter
  ;end select
  IF (curqual=0)
   SET blob_failed = 1
   CALL cps_add_error(cps_select,cps_script_fail,"Getting INSERT IDS",cps_select_msg,0,
    0,0)
  ENDIF
 END ;Subroutine
#exit_script
 IF (blob_failed=0)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
