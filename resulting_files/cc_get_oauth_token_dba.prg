CREATE PROGRAM cc_get_oauth_token:dba
 PROMPT
  "Output to File/Printer/MINE (Default: MINE): " = "MINE"
  WITH outdev
 FREE RECORD oauthreply
 RECORD oauthreply(
   1 header = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE oauthmsg = i4 WITH noconstant(0)
 DECLARE oauthreq = i4 WITH noconstant(0)
 DECLARE oauthrep = i4 WITH noconstant(0)
 DECLARE oauthstatus = i4 WITH noconstant(0)
 DECLARE oauth_response = i4 WITH noconstant(0)
 DECLARE success_ind = i4 WITH noconstant(0)
 DECLARE oauth_token = vc
 DECLARE oauth_token_secret = vc
 DECLARE oauth_consumer_key = vc
 DECLARE oauth_accessor_secret = vc
 DECLARE header = vc
 SET oauthreply->status_data.status = "F"
 SET oauthmsg = uar_srvselectmessage(99999115)
 IF (oauthmsg=0)
  GO TO endprogram
 ENDIF
 SET oauthreq = uar_srvcreaterequest(oauthmsg)
 SET oauthrep = uar_srvcreatereply(oauthmsg)
 SET stat = uar_srvexecute(oauthmsg,oauthreq,oauthrep)
 SET oauthstatus = uar_srvgetstruct(oauthrep,"status")
 SET success_ind = uar_srvgetshort(oauthstatus,"success_ind")
 IF (success_ind=0)
  GO TO endprogram
 ENDIF
 SET oauth_response = uar_srvgetstruct(oauthrep,"oauth_response")
 SET oauth_token = uar_srvgetstringptr(oauth_response,"oauth_token")
 SET oauth_token_secret = uar_srvgetstringptr(oauth_response,"oauth_token_secret")
 SET oauth_consumer_key = uar_srvgetstringptr(oauth_response,"oauth_consumer_key")
 SET oauth_accessor_secret = uar_srvgetstringptr(oauth_response,"oauth_accessor_secret")
 SET header = concat('OAuth oauth_token="',oauth_token,'"')
 SET header = concat(header,',oauth_consumer_key="',oauth_consumer_key,'"')
 SET header = concat(header,',oauth_signature_method="PLAINTEXT"')
 SET timestamp = datetimediff(cnvtdatetime(curdate,curtime3),cnvtdatetime("01-JAN-1970 00:00:00"),5)
 SET header = concat(header,',oauth_timestamp="',trim(cnvtstring(timestamp)),'"')
 SET header = concat(header,',oauth_nonce=""')
 SET header = concat(header,',oauth_version="1.0"')
 SET header = concat(header,',oauth_signature="',oauth_accessor_secret,"%26",oauth_token_secret,
  '"')
 SET oauthreply->header = header
 SET oauthreply->status_data.status = "S"
#endprogram
 SET _memory_reply_string = cnvtrectojson(oauthreply)
 FREE RECORD oauthreply
END GO
