CREATE PROGRAM dm_ctm_domain_load:dba
 IF ( NOT (validate(cm_domain_request,0)))
  FREE SET cm_domain_request
  RECORD cm_domain_request(
    1 domain_cnt = i4
    1 domain_list[*]
      2 domain_name = vc
      2 domain_desc = vc
  )
 ENDIF
 IF ( NOT (validate(cm_domain_reply,0)))
  FREE SET cm_domain_reply
  RECORD cm_domain_reply(
    1 status = vc
    1 message = vc
  )
 ENDIF
 SET cm_domain_reply->status = "F"
 SET cm_domain_reply->message = "Failed to import domains list into DM_INFO"
 DECLARE dcdl_err_msg = vc WITH protect, noconstant("")
 DECLARE dcdl_load_cnt = i4 WITH protect, noconstant(0)
 IF (size(cm_domain_request->domain_list,5) < 1)
  SET cm_domain_reply->status = "F"
  SET cm_domain_reply->message = "The request structure CM_DOMAIN_REQUEST is not filled out."
  GO TO exit_script
 ENDIF
 FOR (dcdl_load_cnt = 1 TO cm_domain_request->domain_cnt)
   SELECT INTO "nl:"
    FROM content_property cp
    WHERE (cp.domain_name=cm_domain_request->domain_list[dcdl_load_cnt].domain_name)
     AND cp.property_type=0
    WITH nocounter
   ;end select
   IF (error(dcdl_err_msg,1) > 0)
    SET cm_domain_reply->status = "F"
    SET cm_domain_reply->message = concat("Failed to retrieve data from CONTENT_PROPERTY: ",
     dcdl_err_msg)
    ROLLBACK
    GO TO exit_script
   ELSE
    COMMIT
   ENDIF
   IF (curqual=0)
    SET cm_domain_reply->status = "F"
    SET cm_domain_reply->message = concat("Data was not found in the CONTENT_PROPERTY table ",
     "for domain: ",cm_domain_request->domain_list[dcdl_load_cnt].domain_name)
    GO TO exit_script
   ENDIF
   IF (findstring("CSVCONV2-",cm_domain_request->domain_list[dcdl_load_cnt].domain_desc)=0)
    SET cm_domain_reply->status = "F"
    SET cm_domain_reply->message = 'Domain description must be prefixed with "CSVCONV2-".'
    ROLLBACK
    GO TO exit_script
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info
    WHERE info_domain="KNOWLEDGE INDEX APPLICATIONS"
     AND (info_name=cm_domain_request->domain_list[dcdl_load_cnt].domain_desc)
     AND (info_char=cm_domain_request->domain_list[dcdl_load_cnt].domain_name)
    WITH nocounter
   ;end select
   IF (error(dcdl_err_msg,1) > 0)
    SET cm_domain_reply->status = "F"
    SET cm_domain_reply->message = concat("Failed to retrieve data from DM_INFO: ",dcdl_err_msg)
    ROLLBACK
    GO TO exit_script
   ELSE
    COMMIT
   ENDIF
   IF (curqual=0)
    INSERT  FROM dm_info
     SET info_domain = "KNOWLEDGE INDEX APPLICATIONS", info_name = cm_domain_request->domain_list[
      dcdl_load_cnt].domain_desc, info_char = cm_domain_request->domain_list[dcdl_load_cnt].
      domain_name
     WITH nocounter
    ;end insert
    IF (error(dcdl_err_msg,1) > 0)
     SET cm_domain_reply->status = "F"
     SET cm_domain_reply->message = concat(
      "Failed to update table dm_info with CSVCONV2 domain info: ",dcdl_err_msg)
     ROLLBACK
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
 COMMIT
 SET cm_domain_reply->status = "S"
 SET cm_domain_reply->message = "Successfully imported domains list into DM_INFO"
#exit_script
END GO
