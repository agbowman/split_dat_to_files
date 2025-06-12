CREATE PROGRAM dm_solcap_put:dba
 DECLARE i_solcap_str = vc WITH protect, noconstant(" ")
 DECLARE v_info_domain = vc WITH protect, noconstant(" ")
 DECLARE v_info_name = vc WITH protect, noconstant(" ")
 DECLARE v_seq_val = f8 WITH protect, noconstant(0.0)
 DECLARE dsp_tok_pos = i4 WITH protect, noconstant(0)
 DECLARE dsp_rec_pos = i4 WITH protect, noconstant(0)
 DECLARE dsp_err_msg = vc WITH protect, noconstant("")
 SET v_info_domain = build2(cnvtupper(dm_solcap_req->solution_name),"|",dm_solcap_req->solcap_num)
 IF ((validate(dm_solcap_req->token_cnt,- (123))=- (123)))
  SET dm_solcap_reply->status = "F"
  SET dm_solcap_reply->message = "Record Structure dm_solcap_req is not defined"
  GO TO exit_dsp
 ELSE
  SET dm_solcap_reply->status = "S"
 ENDIF
 IF ((dm_solcap_req->token_cnt=0))
  SET dm_solcap_reply->status = "S"
  SET dm_solcap_reply->message = "There were no rows to insert."
  GO TO exit_dsp
 ENDIF
 SELECT INTO "nl:"
  v_seq_id = seq(dm_seq,nextval)
  FROM dual
  DETAIL
   v_seq_val = v_seq_id
  WITH nocounter
 ;end select
 SET v_info_name = build(dm_solcap_req->solcap_name,"|",v_seq_val)
 FOR (dsp_tok_pos = 1 TO dm_solcap_req->token_cnt)
   IF (dsp_tok_pos > 1)
    SET i_solcap_str = build(i_solcap_str,"|")
   ENDIF
   SET i_solcap_str = build(i_solcap_str,dm_solcap_req->token_qual[dsp_tok_pos].token_name,"=",
    dm_solcap_req->token_qual[dsp_tok_pos].token_value)
   FOR (dsp_rec_pos = 1 TO dm_solcap_req->token_qual[dsp_tok_pos].pair_cnt)
     IF ((dm_solcap_req->token_qual[dsp_tok_pos].token_name="CAT_NAME"))
      IF ((dm_solcap_req->token_qual[dsp_tok_pos].pair_qual[dsp_rec_pos].pair_value_str > " "))
       SET i_solcap_str = build(i_solcap_str,"|",dm_solcap_req->token_qual[dsp_tok_pos].pair_qual[
        dsp_rec_pos].pair_name,"=",dm_solcap_req->token_qual[dsp_tok_pos].pair_qual[dsp_rec_pos].
        pair_value_str)
      ENDIF
      SET i_solcap_str = build(i_solcap_str,"|",dm_solcap_req->token_qual[dsp_tok_pos].pair_qual[
       dsp_rec_pos].pair_name,"=",dm_solcap_req->token_qual[dsp_tok_pos].pair_qual[dsp_rec_pos].
       pair_value_num)
     ELSE
      IF ((dm_solcap_req->token_qual[dsp_tok_pos].pair_qual[dsp_rec_pos].pair_value_str > " "))
       SET i_solcap_str = build(i_solcap_str,"|","VALUE_STR=",dm_solcap_req->token_qual[dsp_tok_pos].
        pair_qual[dsp_rec_pos].pair_value_str)
      ENDIF
      SET i_solcap_str = build(i_solcap_str,"|","VALUE_NUM=",dm_solcap_req->token_qual[dsp_tok_pos].
       pair_qual[dsp_rec_pos].pair_value_num)
     ENDIF
   ENDFOR
 ENDFOR
 INSERT  FROM dm_info di
  SET di.info_domain = v_info_domain, di.info_name = v_info_name, di.info_char = i_solcap_str,
   di.info_date = cnvtdatetime(curdate,curtime3), di.info_number = dm_solcap_req->solcap_deg_use, di
   .updt_cnt = 0,
   di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_applctx = reqinfo->updt_applctx, di
   .updt_id = reqinfo->updt_id
  WITH nocounter
 ;end insert
 SET err_num = error(dsp_err_msg,1)
 IF (err_num > 0)
  SET dm_solcap_reply->status = "F"
  SET dm_solcap_reply->message = dsp_err_msg
  GO TO exit_dsp
 ELSE
  COMMIT
 ENDIF
#exit_dsp
END GO
