CREATE PROGRAM dm_cmb_refresh_dcc:dba
 DECLARE dcrd_refresh_dcc_ind = i2
 SET dcrd_refresh_dcc_ind = 0
 CALL echo("refreshing combine children table")
 SELECT INTO "nl:"
  d.parent_table
  FROM dm_cmb_children d
  WITH maxqual(d,100)
 ;end select
 IF (curqual < 100)
  SET dcrd_refresh_dcc_ind = 1
 ENDIF
 IF (call_script="DM_CALL_COMBINE")
  SELECT INTO "nl:"
   FROM dm_info d
   WHERE d.info_domain="DATA MANAGEMENT"
    AND d.info_name="CMB_LAST_UPDT"
   DETAIL
    dcrd_reply->cmb_last_updt = d.info_date
   WITH forupdatewait(d)
  ;end select
  SELECT INTO "nl:"
   FROM dm_info d
   WHERE d.info_domain="DATA MANAGEMENT"
    AND d.info_name="USERLASTUPDT"
   DETAIL
    dcrd_reply->schema_last_updt = d.info_date
   WITH nocounter
  ;end select
  IF ((dcrd_reply->schema_last_updt=0))
   SET dcrd_reply->error_msg = "USERLASTUPDT not found in DM_INFO table."
   SET dcrd_reply->err_ind = 1
   SET error_table = "DM_INFO"
   GO TO end_dcrd
  ELSEIF ((((dcrd_reply->schema_last_updt > dcrd_reply->cmb_last_updt)) OR (dcrd_refresh_dcc_ind=1))
  )
   FREE RECORD ct_error
   RECORD ct_error(
     1 message = vc
     1 err_ind = i2
   )
   EXECUTE dm_ins_user_cmb_children
   IF ((ct_error->err_ind=1))
    IF (size(trim(ct_error->message,3)))
     SET dcrd_reply->err_ind = 1
     SET dcrd_reply->err_msg = ct_error->message
     GO TO end_dcrd
    ENDIF
   ENDIF
  ELSE
   ROLLBACK
  ENDIF
  SET ecode = error(emsg,1)
  IF (ecode != 0)
   SET dcrd_reply->err_ind = 1
   SET dcrd_reply->err_msg = emsg
   GO TO end_dcrd
  ENDIF
 ELSE
  IF (dcrd_refresh_dcc_ind=1)
   SET dcrd_reply->err_ind = 1
   SET dcrd_reply->err_msg =
   "Combine called by uncombine, and DM_CMB_CHILDREN not populated correctly. Please log a point with Cerner!"
   GO TO end_dcrd
  ENDIF
  SELECT INTO "nl:"
   FROM dm_info d
   WHERE d.info_domain="DATA MANAGEMENT"
    AND d.info_name="CMB_LAST_UPDT"
   DETAIL
    dcrd_reply->cmb_last_updt = d.info_date
   WITH nocounter
  ;end select
 ENDIF
#end_dcrd
END GO
