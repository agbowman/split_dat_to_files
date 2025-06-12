CREATE PROGRAM daf_cmb_check_drr_allowed:dba
 IF (validate(cmb_drr_reply->status,"Z")="Z")
  RECORD cmb_drr_reply(
    1 status = c1
    1 message = vc
    1 gdpr_ind = i2
  )
 ENDIF
 DECLARE srv_message_number = i4 WITH protect, constant(99887785)
 DECLARE drr_dm_info_row = vc WITH protect, constant("DRR_FEATURE_FLAG")
 DECLARE srvmessage = i4 WITH protect, noconstant(0)
 DECLARE isdrrturnedon = i2 WITH public, noconstant(0)
 SET cmb_drr_reply->gdpr_ind = 0
 SELECT INTO "nl:"
  di.info_number
  FROM dm_info di
  WHERE di.info_domain=drr_dm_info_row
   AND di.info_name=drr_dm_info_row
  DETAIL
   IF (di.info_number=1)
    isdrrturnedon = 1, cmb_drr_reply->gdpr_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (isdrrturnedon=0)
  SET cmb_drr_reply->status = "S"
  SET cmb_drr_reply->message = "The GDPR Service is not enabled in this domain"
  GO TO exit_script
 ENDIF
 SET isdrrturnedon = 0
 SELECT INTO "nl:"
  di.info_number
  FROM dm_info di
  WHERE di.info_domain="Combine Service"
   AND di.info_name="GDPR Bypass Check"
  DETAIL
   isdrrturnedon = di.info_number
  WITH nocounter
 ;end select
 IF (isdrrturnedon=1)
  SET cmb_drr_reply->status = "S"
  SET cmb_drr_reply->message = "The GDPR Service is not enabled in this domain"
  SET cmb_drr_reply->gdpr_ind = 1
  GO TO exit_script
 ENDIF
 IF (validate(cmb_drr_request->parent_table,"ZZZ")="ZZZ")
  SET cmb_drr_reply->status = "F"
  SET cmb_drr_reply->message = "No parent_table value provided in request structure"
  GO TO exit_script
 ENDIF
 IF (validate(cmb_drr_request->from_xxx_id,- (1.0)) <= 0.00)
  SET cmb_drr_reply->status = "F"
  SET cmb_drr_reply->message = "No valid from_xxx_id value provided in request structure"
  GO TO exit_script
 ENDIF
 IF (validate(cmb_drr_request->to_xxx_id,- (1.0)) <= 0.00)
  SET cmb_drr_reply->status = "F"
  SET cmb_drr_reply->message = "No valid to_xxx_id value provided in request structure"
  GO TO exit_script
 ENDIF
 SET srvmessage = uar_srvselectmessage(srv_message_number)
 SET srvrequest = uar_srvcreaterequest(srvmessage)
 SET srvreply = uar_srvcreatereply(srvmessage)
 SET stat = uar_srvsetdouble(srvrequest,"fromEntityID",cmb_drr_request->from_xxx_id)
 SET stat = uar_srvsetdouble(srvrequest,"toEntityID",cmb_drr_request->to_xxx_id)
 SET stat = uar_srvsetdouble(srvrequest,"personID",cmb_drr_request->person_id)
 SET stat = uar_srvsetstring(srvrequest,"combineType",nullterm(trim(cmb_drr_request->parent_table)))
 SET srvstatus = uar_srvexecute(srvmessage,srvrequest,srvreply)
 IF (srvstatus=0)
  SET cmb_drr_reply->status = uar_srvgetstringptr(srvreply,"status")
  SET cmb_drr_reply->message = uar_srvgetstringptr(srvreply,"message")
 ELSEIF (srvstatus=1)
  SET cmb_drr_reply->status = "F"
  SET cmb_drr_reply->message =
  "The Data Record Retention Service (2031) does not appear to be running."
 ELSEIF (srvstatus=7)
  SET cmb_drr_reply->status = "F"
  SET cmb_drr_reply->message =
  "The Data Record Retention Service (2031) does not appear to be running."
 ELSE
  SET cmb_drr_reply->status = "F"
  SET cmb_drr_reply->message = concat("An unknown service status (",trim(cnvtstring(srvstatus)),
   ") was returned.")
 ENDIF
 SET stat = uar_srvdestroyinstance(srvrequest)
 SET stat = uar_srvdestroyinstance(srvreply)
#exit_script
END GO
