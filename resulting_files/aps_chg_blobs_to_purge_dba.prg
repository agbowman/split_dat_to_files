CREATE PROGRAM aps_chg_blobs_to_purge:dba
 EXECUTE dmsmanagementrtl
 RECORD reply(
   1 ops_event = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp_csa_request(
   1 datasetuidlist[*]
     2 dataset_uid = c128
     2 storage_cd = f8
 )
 DECLARE failed = c1 WITH noconstant("F")
 DECLARE nbr_to_purge = i4 WITH noconstant(0)
 DECLARE happ = i4 WITH noconstant(0)
 DECLARE htask = i4 WITH noconstant(0)
 DECLARE hstep = i4 WITH noconstant(0)
 DECLARE hreq = i4 WITH noconstant(0)
 DECLARE hrep = i4 WITH noconstant(0)
 DECLARE hstatusdata = i4 WITH noconstant(0)
 DECLARE status = c1 WITH noconstant(" ")
 DECLARE huidqual = i4 WITH noconstant(0)
 DECLARE crmstat = i2 WITH noconstant(0)
 DECLARE srvstat = i2 WITH noconstant(0)
 DECLARE stat = i2 WITH noconstant(0)
 DECLARE ecrmok = i2 WITH constant(0)
 DECLARE uidindex = i4 WITH noconstant(0)
 DECLARE error_cnt = i2 WITH noconstant(0)
 DECLARE lmmfimagecnt = i4 WITH noconstant(0)
 DECLARE dmmfstoragecd = f8 WITH noconstant(0.0)
 DECLARE dmmfcachestoragecd = f8 WITH noconstant(0.0)
 DECLARE lversion = i4 WITH constant(0)
 SET stat = uar_get_meaning_by_codeset(25,"MMF",1,dmmfstoragecd)
 IF (dmmfstoragecd=0)
  CALL handle_errors("UAR","F","UAR","MMF","Failure - Error getting CODE_VALUE (25 - MMF).")
  GO TO exit_script
 ENDIF
 SET stat = uar_get_meaning_by_codeset(25,"APS_IMGCACHE",1,dmmfcachestoragecd)
 IF (dmmfcachestoragecd=0)
  CALL handle_errors("UAR","F","UAR","APS_IMGCACHE",
   "Failure - Error getting CODE_VALUE (25 - APS_IMGCACHE).")
  GO TO exit_script
 ENDIF
 SELECT DISTINCT INTO "nl:"
  abc.blob_identifier
  FROM ap_blob_cleanup abc
  ORDER BY abc.blob_identifier, 0
  HEAD REPORT
   nbr_to_purge = 0, lmmfimagecnt = 0
  DETAIL
   nbr_to_purge = (nbr_to_purge+ 1)
   IF (mod(nbr_to_purge,10)=1)
    stat = alterlist(temp_csa_request->datasetuidlist,(nbr_to_purge+ 9))
   ENDIF
   temp_csa_request->datasetuidlist[nbr_to_purge].dataset_uid = abc.blob_identifier, temp_csa_request
   ->datasetuidlist[nbr_to_purge].storage_cd = abc.storage_cd
   IF (((abc.storage_cd=dmmfstoragecd) OR (abc.storage_cd=dmmfcachestoragecd)) )
    lmmfimagecnt = (lmmfimagecnt+ 1)
   ENDIF
  FOOT REPORT
   stat = alterlist(temp_csa_request->datasetuidlist,nbr_to_purge)
  WITH nocounter
 ;end select
 IF (nbr_to_purge=0)
  GO TO exit_script
 ENDIF
 IF (nbr_to_purge > lmmfimagecnt)
  SET crmstat = uar_crmbeginapp(4110030,happ)
  IF (((crmstat != ecrmok) OR (happ=0)) )
   CALL handle_errors("GET","F","Application Handle",cnvtstring(crmstat),
    "Failure - Error getting app handle for 4110030.")
   GO TO exit_script
  ENDIF
  SET crmstat = uar_crmbegintask(happ,4118000,htask)
  IF (((crmstat != ecrmok) OR (htask=0)) )
   CALL handle_errors("GET","F","Task Handle",cnvtstring(crmstat),
    "Failure - Error getting task handle for 4118000.")
   GO TO exit_script
  ENDIF
  SET crmstat = uar_crmbeginreq(htask,"",4112105,hstep)
  IF (crmstat != ecrmok)
   CALL handle_errors("GET","F","Task Handle",cnvtstring(crmstat),
    "Failure - Error beginning request for 4112105.")
   GO TO exit_script
  ENDIF
  SET hreq = uar_crmgetrequest(hstep)
  IF (hreq=0)
   CALL handle_errors("GET","F","Request Handle",cnvtstring(hreq),
    "Failure - Error getting request structure for 4112105.")
   GO TO exit_script
  ENDIF
  FOR (uidindex = 1 TO nbr_to_purge)
    IF ((temp_csa_request->datasetuidlist[uidindex].storage_cd != dmmfstoragecd)
     AND (temp_csa_request->datasetuidlist[uidindex].storage_cd != dmmfcachestoragecd))
     SET huidqual = uar_srvadditem(hreq,"datasetuidList")
     SET srvstat = uar_srvsetstring(huidqual,"dataset_uid",temp_csa_request->datasetuidlist[uidindex]
      .dataset_uid)
    ENDIF
  ENDFOR
  SET crmstat = uar_crmperform(hstep)
  IF (crmstat=ecrmok)
   SET hrep = uar_crmgetreply(hstep)
   SET hstatusdata = uar_srvgetstruct(hrep,"status_data")
   CALL uar_srvgetstringfixed(hstatusdata,"status",status,1)
   IF (status != "S")
    CALL handle_errors("GET","F","Perform",cnvtstring(crmstat),
     "Failure - Error returned from server step 4112105.")
    GO TO exit_script
   ENDIF
  ELSE
   CALL handle_errors("GET","F","Perform",cnvtstring(crmstat),
    "Failure - Error performing server step 4112105.")
   GO TO exit_script
  ENDIF
 ENDIF
 IF (lmmfimagecnt > 0)
  FOR (uidindex = 1 TO nbr_to_purge)
    IF ((((temp_csa_request->datasetuidlist[uidindex].storage_cd=dmmfstoragecd)) OR ((
    temp_csa_request->datasetuidlist[uidindex].storage_cd=dmmfcachestoragecd))) )
     IF (negate(uar_dmsm_deletemediaobject(nullterm(temp_csa_request->datasetuidlist[uidindex].
        dataset_uid),lversion)))
      CALL handle_errors("DELETE","F","MMF File",cnvtstring(temp_csa_request->datasetuidlist[uidindex
        ].dataset_uid),"Failure - Error calling uar_DMSM_DeleteMediaObject.")
      GO TO exit_script
     ENDIF
    ENDIF
  ENDFOR
 ENDIF
 DELETE  FROM ap_blob_cleanup abc,
   (dummyt d  WITH seq = value(nbr_to_purge))
  SET abc.blob_identifier = temp_csa_request->datasetuidlist[d.seq].dataset_uid
  PLAN (d)
   JOIN (abc
   WHERE (abc.blob_identifier=temp_csa_request->datasetuidlist[d.seq].dataset_uid))
  WITH nocounter
 ;end delete
 IF (curqual=0)
  CALL handle_errors("DELETE","F","AP_BLOB_CLEANUP","Error deleting ap_blob_cleanup rows.",
   "Failure - Error deleting ap_blob_cleanup rows.")
  GO TO exit_script
 ENDIF
 FREE RECORD temp_csa_request
#exit_script
 IF (hreq != 0)
  SET crmstat = uar_crmendreq(hreq)
 ENDIF
 IF (htask != 0)
  SET crmstat = uar_crmendtask(htask)
 ENDIF
 IF (happ != 0)
  SET crmstat = uar_crmendapp(happ)
 ENDIF
 IF (failed="T")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 0
 ENDIF
 SUBROUTINE handle_errors(op_name,op_status,tar_name,tar_value,ops_msg)
   SET error_cnt = (error_cnt+ 1)
   IF (error_cnt > 1)
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[error_cnt].operationname = op_name
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = op_status
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = tar_name
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = tar_value
   SET reply->ops_event = ops_msg
   SET failed = "T"
 END ;Subroutine
END GO
