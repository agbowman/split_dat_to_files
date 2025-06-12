CREATE PROGRAM cps_get_scd_blob:dba
 RECORD reply(
   1 format_cd = f8
   1 long_blobs[*]
     2 long_blob = vgc
     2 sequence_number = i4
     2 blob_length = i4
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
 DECLARE ocfcomp_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",120,"OCFCOMP"))
 DECLARE blob_out = vc
 IF (validate(cursysbit,32)=32)
  DECLARE uncompress_ret_len = i4
 ELSE
  DECLARE uncompress_ret_len = h
 ENDIF
 SET failed = 0
 SET reply->status_data.status = "F"
 SET lb_idx = 0
 SET stat = alterlist(reply->long_blobs,10)
 SELECT INTO "NL:"
  scd_blob_id = sb.scd_blob_id"###########################"
  FROM long_blob lb,
   scd_blob sb
  PLAN (sb
   WHERE (sb.scd_blob_id=request->scd_blob_id))
   JOIN (lb
   WHERE lb.parent_entity_id=sb.scd_blob_id
    AND lb.parent_entity_name="SCD_BLOB")
  ORDER BY lb.long_blob_id
  HEAD scd_blob_id
   reply->format_cd = sb.format_cd
  DETAIL
   lb_idx = (lb_idx+ 1)
   IF (mod(lb_idx,10)=0)
    stat = alterlist(reply->long_blobs,(lb_idx+ 10))
   ENDIF
   IF (lb.compression_cd=ocfcomp_cd)
    stat = memrealloc(blob_out,1,build("C",lb.blob_length)), uncompress_ret_len = 0,
    CALL uar_ocf_uncompress(notrim(lb.long_blob),textlen(notrim(lb.long_blob)),blob_out,lb
    .blob_length,uncompress_ret_len),
    reply->long_blobs[lb_idx].blob_length = uncompress_ret_len, reply->long_blobs[lb_idx].long_blob
     = notrim(blob_out)
   ELSE
    reply->long_blobs[lb_idx].long_blob = notrim(lb.long_blob)
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->long_blobs,lb_idx)
 IF (lb_idx > 0)
  SET reply->long_blobs[lb_idx].long_blob = trim(reply->long_blobs[lb_idx].long_blob,5)
 ENDIF
#exit_script
 IF (failed=0)
  SET reply->status_data.status = "S"
 ENDIF
END GO
