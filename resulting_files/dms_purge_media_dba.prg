CREATE PROGRAM dms_purge_media:dba
 CALL echo("<==================== Entering DMS_PURGE_MEDIA Script ====================>")
 FREE SET maxver
 DECLARE maxver = vc WITH constant("maxVersion")
 FREE SET expdur
 DECLARE expdur = vc WITH constant("expirationDuration")
 FREE SET name
 DECLARE name = vc WITH constant("name")
 FREE SET stat
 DECLARE stat = i4 WITH noconstant(0)
 FREE SET totaldel
 DECLARE totaldel = i4 WITH noconstant(0)
 FREE SET htypelist
 DECLARE htypelist = i4 WITH noconstant(0)
 FREE SET numcontent
 DECLARE numcontent = i4 WITH noconstant(0)
 FREE SET purgequal
 DECLARE purgequal = i4 WITH noconstant(0)
 FREE SET hcontenttype
 DECLARE hcontenttype = i4 WITH noconstant(0)
 FREE SET hprops
 DECLARE hprops = i4 WITH noconstant(0)
 FREE SET valueint
 DECLARE valueint = i4 WITH noconstant(0)
 FREE SET namecontent
 DECLARE namecontent = c64
 FREE SET tempstring
 DECLARE tempstring = vc
 FREE SET sizecontent
 DECLARE sizecontent = i4 WITH noconstant(0)
 FREE SET failtype
 DECLARE failtype = i4 WITH noconstant(0)
 FREE SET errmsg
 DECLARE errmsg = vc WITH noconstant("DMS Purge Script Failure")
 FREE SET x
 DECLARE x = i4 WITH noconstant
 FREE SET y
 DECLARE y = i4 WITH noconstant
 FREE SET contenttypes
 RECORD contenttypes(
   1 qualcontent[*]
     2 content_type = vc
     2 max_versions = i4
     2 exp_duration = i4
 )
 FREE SET delrequest
 RECORD delrequest(
   1 qual[*]
     2 dms_media_instance_id = f8
     2 identifier = vc
     2 is_parent = i2
     2 version = i4
 )
 FREE SET mmfdelobjreq
 RECORD mmfdelobjreq(
   1 dms_media_instance_id = f8
   1 identifier = vc
   1 version = i4
 )
 FREE SET delgrprequest
 RECORD delgrprequest(
   1 identifier = vc
   1 version = i4
   1 delete_members = i2
 )
 RECORD getownershiprequest(
   1 media_object_identifier = vc
 )
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 ops_event = vc
    1 purge_count = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 EXECUTE dmsmanagementrtl
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 SET htypelist = uar_dmsm_getcontenttypelist()
 IF (htypelist=0)
  SET errmsg = "DMS Purge Script Failure - DMSM_GetContentTypeList"
  GO TO script_fail
 ENDIF
 IF (negate(uar_srv_getpropcount(htypelist,numcontent)))
  SET errmsg = "DMS Purge Script Failure - SRV_GetPropCount failed"
  SET failtype = 1
  GO TO script_fail
 ENDIF
 IF (numcontent=0)
  SET errmsg = "DMS Purge Script Failure - Zero content types defined."
  SET failtype = 1
  GO TO script_fail
 ENDIF
 CALL echo(build("numContent",numcontent))
 SET stat = alterlist(contenttypes->qualcontent,numcontent)
 FOR (x = 1 TO numcontent)
   SET tempstring = trim(cnvtstring(value((x - 1))))
   IF (negate(uar_srv_getprophandle(htypelist,nullterm(tempstring),hcontenttype)))
    SET errmsg = "DMS Purge Script Failure - SRV_GetPropHandle failed"
    SET failtype = 1
    GO TO script_fail
   ENDIF
   SET hprops = uar_dmsm_getcontenttypeprops(hcontenttype)
   IF (hprops=0)
    SET errmsg = "DMS Purge Script Failure - DMSM_GetContentTypeProps"
    SET failtype = 2
    GO TO script_fail
   ENDIF
   SET namecontent = ""
   SET sizecontent = 64
   IF (negate(uar_srv_getpropstring(hprops,nullterm(name),namecontent,sizecontent)))
    SET errmsg = "DMS Purge Script Failure - SRV_GetPropString failed."
    SET failtype = 3
    GO TO script_fail
   ENDIF
   SET contenttypes->qualcontent[x].content_type = trim(namecontent)
   IF (negate(uar_srv_getpropint(hprops,nullterm(maxver),valueint)))
    SET errmsg = "DMS Purge Script Failure - SRV_GetPropInt(Max Version)"
    SET failtype = 3
    GO TO script_fail
   ENDIF
   SET contenttypes->qualcontent[x].max_versions = valueint
   IF (negate(uar_srv_getpropint(hprops,nullterm(expdur),valueint)))
    SET errmsg = "DMS Purge Script Failure - SRV_GetPropInt(Exp Duration)"
    SET failtype = 3
    GO TO script_fail
   ENDIF
   SET contenttypes->qualcontent[x].exp_duration = valueint
   IF (negate(uar_srv_closehandle(hcontenttype)))
    SET errmsg = "DMS Purge Script Failure - SRV_CloseHandle hContentType failed."
    GO TO script_fail
   ENDIF
   IF (negate(uar_srv_closehandle(hprops)))
    SET errmsg = "DMS Purge Script Failure - SRV_CloseHandle hProps failed."
    GO TO script_fail
   ENDIF
 ENDFOR
 IF (negate(uar_srv_closehandle(htypelist)))
  SET errmsg = "DMS Purge Script Failure - SRV_CloseHandle hTypeList failed."
  GO TO script_fail
 ENDIF
 FOR (y = 1 TO numcontent)
   SET purgequal = 0
   FREE SET stat
   DECLARE stat = i4 WITH noconstant(0)
   SET stat = alterlist(delrequest->qual,0)
   IF ((contenttypes->qualcontent[y].exp_duration >= 0))
    FREE RECORD mediaids
    RECORD mediaids(
      1 qual[*]
        2 identifier = vc
        2 ver_count = i4
        2 is_parent = i2
        2 is_child = i2
    )
    FREE SET countmedia
    DECLARE countmedia = i4 WITH noconstant(0)
    FREE SET newidflag
    DECLARE newidflag = i2 WITH noconstant(0)
    FREE SET purgeidx
    DECLARE purgeidx = i4 WITH noconstant(0)
    SET expiredate = datetimeadd(cnvtdatetime(curdate,curtime),- (contenttypes->qualcontent[y].
     exp_duration))
    SELECT INTO "nl:"
     *
     FROM dms_content_type dct,
      dms_media_instance dmr,
      dms_media_identifier dmid
     PLAN (dct
      WHERE dct.content_type_key=value(contenttypes->qualcontent[y].content_type))
      JOIN (dmr
      WHERE dmr.dms_content_type_id=dct.dms_content_type_id
       AND dmr.dms_media_instance_id > 0)
      JOIN (dmid
      WHERE dmid.dms_media_identifier_id=dmr.dms_media_identifier_id)
     ORDER BY dmr.dms_media_identifier_id, dmr.version DESC
     HEAD REPORT
      countmedia = 0
     HEAD dmr.dms_media_identifier_id
      IF (dmr.created_dt_tm <= cnvtdatetime(expiredate))
       countmedia += 1
       IF (mod(countmedia,20)=1)
        stat = alterlist(mediaids->qual,(countmedia+ 19))
       ENDIF
       mediaids->qual[countmedia].identifier = dmid.media_object_identifier, mediaids->qual[
       countmedia].ver_count = 0, newidflag = 1
       IF (dmr.dms_media_identifier_group_id=0.0)
        mediaids->qual[countmedia].is_parent = 0, mediaids->qual[countmedia].is_child = 0
       ELSEIF (dmr.dms_media_identifier_id=dmr.dms_media_identifier_group_id)
        mediaids->qual[countmedia].is_parent = 1, mediaids->qual[countmedia].is_child = 0
       ELSE
        mediaids->qual[countmedia].is_parent = 0, mediaids->qual[countmedia].is_child = 1
       ENDIF
      ENDIF
     DETAIL
      IF (newidflag=1)
       mediaids->qual[countmedia].ver_count += 1
      ENDIF
     FOOT  dmr.dms_media_identifier_id
      newidflag = 0
     FOOT REPORT
      stat = alterlist(mediaids->qual,countmedia)
     WITH nocounter
    ;end select
    FOR (purgeidx = 1 TO countmedia)
      IF ((mediaids->qual[purgeidx].is_child=0))
       FREE RECORD getownershipreply
       RECORD getownershipreply(
         1 object_owners[*]
           2 ownership_uid = vc
         1 group_owners[*]
           2 ownership_uid = vc
         1 status_data
           2 status = c1
           2 subeventstatus[1]
             3 operationname = c25
             3 operationstatus = c1
             3 targetobjectname = c25
             3 targetobjectvalue = vc
       )
       IF ((mediaids->qual[purgeidx].is_parent=0))
        SET mmfdelobjreq->dms_media_instance_id = 0.0
        SET mmfdelobjreq->identifier = mediaids->qual[purgeidx].identifier
        SET mmfdelobjreq->version = 0
        SET getownershiprequest->media_object_identifier = mmfdelobjreq->identifier
        EXECUTE mmf_get_ownerships  WITH replace("REQUEST","GETOWNERSHIPREQUEST"), replace("REPLY",
         "GETOWNERSHIPREPLY")
        IF (size(getownershipreply->object_owners,5)=0
         AND size(getownershipreply->group_owners,5)=0)
         EXECUTE mmf_delete_media_object  WITH replace("REQUEST",mmfdelobjreq)
         IF ((reply->status_data.status="F"))
          GO TO script_fail
         ELSEIF ((reply->status_data.status="S"))
          SET totaldel += mediaids->qual[purgeidx].ver_count
         ENDIF
        ENDIF
       ELSE
        SET delgrprequest->identifier = mediaids->qual[purgeidx].identifier
        SET delgrprequest->version = 0
        SET delgrprequest->delete_members = 1
        SET getownershiprequest->media_object_identifier = delgrprequest->identifier
        EXECUTE mmf_get_ownerships  WITH replace("REQUEST","GETOWNERSHIPREQUEST"), replace("REPLY",
         "GETOWNERSHIPREPLY")
        IF (size(getownershipreply->object_owners,5)=0
         AND size(getownershipreply->group_owners,5)=0)
         EXECUTE mmf_delete_media_group  WITH replace("REQUEST","DELGRPREQUEST")
         IF ((reply->status_data.status="F"))
          GO TO script_fail
         ELSEIF ((reply->status_data.status="S"))
          SET totaldel += mediaids->qual[purgeidx].ver_count
         ENDIF
        ENDIF
       ENDIF
       SET reply->status_data.status = "F"
       SET reqinfo->commit_ind = 0
      ENDIF
    ENDFOR
   ENDIF
   FREE SET stat
   DECLARE stat = i4 WITH noconstant(0)
   IF ((contenttypes->qualcontent[y].max_versions >= 0))
    SELECT INTO "nl:"
     dct.dms_content_type_id, dct.content_type_key, dmv.dms_media_instance_id,
     dmid.media_object_identifier, dmv.version
     FROM dms_content_type dct,
      dms_media_instance dmv,
      dms_media_identifier dmid
     PLAN (dct
      WHERE (dct.content_type_key=contenttypes->qualcontent[y].content_type))
      JOIN (dmv
      WHERE dmv.dms_content_type_id=dct.dms_content_type_id
       AND dmv.dms_media_instance_id > 0
       AND dmv.created_by_id >= 0)
      JOIN (dmid
      WHERE dmid.dms_media_identifier_id=dmv.dms_media_identifier_id)
     ORDER BY dmv.dms_media_identifier_id, dmv.version DESC
     HEAD dmv.dms_media_identifier_id
      currmax = 0
     DETAIL
      currmax += 1
      IF ((currmax > contenttypes->qualcontent[y].max_versions))
       purgequal += 1
       IF (mod(purgequal,100)=1)
        stat = alterlist(delrequest->qual,(purgequal+ 99))
       ENDIF
       delrequest->qual[purgequal].dms_media_instance_id = dmv.dms_media_instance_id
       IF (dmv.dms_media_identifier_id=dmv.dms_media_identifier_group_id)
        delrequest->qual[purgequal].is_parent = 1, delrequest->qual[purgequal].version = dmv.version,
        delrequest->qual[purgequal].identifier = dmid.media_object_identifier
       ELSE
        delrequest->qual[purgequal].is_parent = 0
       ENDIF
      ENDIF
     FOOT REPORT
      stat = alterlist(delrequest->qual,purgequal)
     WITH nocounter
    ;end select
   ENDIF
   IF (purgequal > 1000)
    SET nextgrand = 1001
    SET done = 0
    WHILE (done=0)
     IF ((purgequal < (nextgrand+ 1000)))
      FOR (j = nextgrand TO purgequal)
        FREE RECORD getownershipreply
        RECORD getownershipreply(
          1 object_owners[*]
            2 ownership_uid = vc
          1 group_owners[*]
            2 ownership_uid = vc
          1 status_data
            2 status = c1
            2 subeventstatus[1]
              3 operationname = c25
              3 operationstatus = c1
              3 targetobjectname = c25
              3 targetobjectvalue = vc
        )
        IF ((delrequest->qual[j].is_parent=0))
         SET mmfdelobjreq->dms_media_instance_id = delrequest->qual[j].dms_media_instance_id
         SET getownershiprequest->media_object_identifier = delrequest->qual[j].identifier
         EXECUTE mmf_get_ownerships  WITH replace("REQUEST","GETOWNERSHIPREQUEST"), replace("REPLY",
          "GETOWNERSHIPREPLY")
         IF (size(getownershipreply->object_owners,5)=0
          AND size(getownershipreply->group_owners,5)=0)
          EXECUTE mmf_delete_media_object  WITH replace("REQUEST",mmfdelobjreq)
          IF ((reply->status_data.status="F"))
           GO TO script_fail
          ELSEIF ((reply->status_data.status="S"))
           SET totaldel += 1
          ENDIF
         ENDIF
        ELSE
         SET delgrprequest->identifier = delrequest->qual[j].identifier
         SET delgrprequest->version = delrequest->qual[j].version
         SET delgrprequest->delete_members = 1
         SET getownershiprequest->media_object_identifier = delgrprequest->identifier
         EXECUTE mmf_get_ownerships  WITH replace("REQUEST","GETOWNERSHIPREQUEST"), replace("REPLY",
          "GETOWNERSHIPREPLY")
         IF (size(getownershipreply->object_owners,5)=0
          AND size(getownershipreply->group_owners,5)=0)
          EXECUTE mmf_delete_media_group  WITH replace("REQUEST","DELGRPREQUEST")
          IF ((reply->status_data.status="F"))
           GO TO script_fail
          ELSEIF ((reply->status_data.status="S"))
           SET totaldel += 1
          ENDIF
         ENDIF
        ENDIF
        SET reply->status_data.status = "F"
        SET reqinfo->commit_ind = 0
      ENDFOR
      SET done = 1
     ELSE
      FOR (j = nextgrand TO (nextgrand+ 999))
        FREE RECORD getownershipreply
        RECORD getownershipreply(
          1 object_owners[*]
            2 ownership_uid = vc
          1 group_owners[*]
            2 ownership_uid = vc
          1 status_data
            2 status = c1
            2 subeventstatus[1]
              3 operationname = c25
              3 operationstatus = c1
              3 targetobjectname = c25
              3 targetobjectvalue = vc
        )
        IF ((delrequest->qual[j].is_parent=0))
         SET mmfdelobjreq->dms_media_instance_id = delrequest->qual[j].dms_media_instance_id
         SET getownershiprequest->media_object_identifier = delrequest->qual[j].identifier
         EXECUTE mmf_get_ownerships  WITH replace("REQUEST","GETOWNERSHIPREQUEST"), replace("REPLY",
          "GETOWNERSHIPREPLY")
         IF (size(getownershipreply->object_owners,5)=0
          AND size(getownershipreply->group_owners,5)=0)
          EXECUTE mmf_delete_media_object  WITH replace("REQUEST",mmfdelobjreq)
          IF ((reply->status_data.status="F"))
           GO TO script_fail
          ELSEIF ((reply->status_data.status="S"))
           SET totaldel += 1
          ENDIF
         ENDIF
        ELSE
         SET delgrprequest->identifier = delrequest->qual[j].identifier
         SET delgrprequest->version = delrequest->qual[j].version
         SET delgrprequest->delete_members = 1
         SET getownershiprequest->media_object_identifier = delgrprequest->identifier
         EXECUTE mmf_get_ownerships  WITH replace("REQUEST","GETOWNERSHIPREQUEST"), replace("REPLY",
          "GETOWNERSHIPREPLY")
         IF (size(getownershipreply->object_owners,5)=0
          AND size(getownershipreply->group_owners,5)=0)
          EXECUTE mmf_delete_media_group  WITH replace("REQUEST","DELGRPREQUEST")
          IF ((reply->status_data.status="F"))
           GO TO script_fail
          ELSEIF ((reply->status_data.status="S"))
           SET totaldel += 1
          ENDIF
         ENDIF
        ENDIF
        SET reply->status_data.status = "F"
        SET reqinfo->commit_ind = 0
      ENDFOR
      SET nextgrand += 1000
     ENDIF
     COMMIT
    ENDWHILE
    FREE SET stat
    DECLARE stat = i4 WITH noconstant(0)
    SET stat = alterlist(delrequest->qual,1000)
   ENDIF
   IF (purgequal > 0)
    FREE SET dmspind
    DECLARE dmspind = i4 WITH noconstant(1)
    FREE SET sizedelreq
    DECLARE sizedelreq = i4 WITH constant(size(delrequest->qual,5))
    FOR (dmspind = 1 TO sizedelreq)
      FREE RECORD getownershipreply
      RECORD getownershipreply(
        1 object_owners[*]
          2 ownership_uid = vc
        1 group_owners[*]
          2 ownership_uid = vc
        1 status_data
          2 status = c1
          2 subeventstatus[1]
            3 operationname = c25
            3 operationstatus = c1
            3 targetobjectname = c25
            3 targetobjectvalue = vc
      )
      IF ((delrequest->qual[dmspind].is_parent=0))
       SET mmfdelobjreq->dms_media_instance_id = delrequest->qual[dmspind].dms_media_instance_id
       SET getownershiprequest->media_object_identifier = delrequest->qual[j].identifier
       EXECUTE mmf_get_ownerships  WITH replace("REQUEST","GETOWNERSHIPREQUEST"), replace("REPLY",
        "GETOWNERSHIPREPLY")
       IF (size(getownershipreply->object_owners,5)=0
        AND size(getownershipreply->group_owners,5)=0)
        EXECUTE mmf_delete_media_object  WITH replace("REQUEST",mmfdelobjreq)
        IF ((reply->status_data.status="F"))
         GO TO script_fail
        ELSEIF ((reply->status_data.status="S"))
         SET totaldel += 1
        ENDIF
       ENDIF
      ELSE
       SET delgrprequest->identifier = delrequest->qual[dmspind].identifier
       SET delgrprequest->version = delrequest->qual[dmspind].version
       SET delgrprequest->delete_members = 1
       SET getownershiprequest->media_object_identifier = delgrprequest->identifier
       EXECUTE mmf_get_ownerships  WITH replace("REQUEST","GETOWNERSHIPREQUEST"), replace("REPLY",
        "GETOWNERSHIPREPLY")
       IF (size(getownershipreply->object_owners,5)=0
        AND size(getownershipreply->group_owners,5)=0)
        EXECUTE mmf_delete_media_group  WITH replace("REQUEST","DELGRPREQUEST")
        IF ((reply->status_data.status="F"))
         GO TO script_fail
        ELSEIF ((reply->status_data.status="S"))
         SET totaldel += 1
        ENDIF
       ENDIF
      ENDIF
      SET reply->status_data.status = "F"
      SET reqinfo->commit_ind = 0
    ENDFOR
    COMMIT
   ENDIF
 ENDFOR
 SET reply->status_data.status = "S"
 IF (totaldel > 0)
  SET reply->ops_event = build("DMS Purge Successful: Rows Deleted->",totaldel)
 ELSE
  SET reply->ops_event = "DMS Purge Successful. None to purge."
 ENDIF
 SET reply->purge_count = totaldel
 SET reqinfo->commit_ind = 1
 GO TO exit_script
#script_fail
 IF (failtype > 2)
  IF (negate(uar_srv_closehandle(hprops)))
   SET errmsg = build2(errmsg,"->During error cleanup SRV_CloseHandle hProps failed.")
   GO TO script_errmsg
  ENDIF
 ENDIF
 IF (failtype > 1)
  IF (negate(uar_srv_closehandle(hcontenttype)))
   SET errmsg = build2(errmsg,"->During error cleanup SRV_CloseHandle hContentType failed.")
   GO TO script_errmsg
  ENDIF
 ENDIF
 IF (failtype > 0)
  IF (negate(uar_srv_closehandle(htypelist)))
   SET errmsg = build2(errmsg,"->During error cleanup SRV_CloseHandle hTypeList failed.")
   GO TO script_errmsg
  ENDIF
 ENDIF
#script_errmsg
 SET reply->ops_event = build("DMS Purge Failed->",errmsg)
#exit_script
 CALL echorecord(reply)
 CALL echo("<==================== Exiting DMS_PURGE_MEDIA Script ====================>")
END GO
