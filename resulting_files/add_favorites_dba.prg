CREATE PROGRAM add_favorites:dba
 RECORD internal(
   1 qual[*]
     2 status = i2
 )
 RECORD reply(
   1 favorite_list[*]
     2 favorite_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 SET favorite_id = 0.0
 SET added = 0
 SET favorites_to_add = size(request->favorite_list,5)
 SET stat = alterlist(internal->qual,favorites_to_add)
 IF (favorites_to_add=0)
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Favorite list must be greater than 0."
  GO TO exit_script
 ENDIF
 FOR (knt = 1 TO favorites_to_add)
   IF ((((request->favorite_list[knt].personnel_id > 0)
    AND (request->favorite_list[knt].personnel_group_id > 0)) OR ((request->favorite_list[knt].
   personnel_id=0)
    AND (request->favorite_list[knt].personnel_group_id=0))) )
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Either Personnel ID or Personnel Group ID must be set."
   ELSEIF ((request->favorite_list[knt].favorite_type_cd=0))
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Favorite Type Cd must be set."
   ELSEIF (((size(request->favorite_list[knt].parent_entity_name,1)=0) OR ((request->favorite_list[
   knt].parent_entity_id=0))) )
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Parent Entity Name and Parent Entity ID are required."
   ELSE
    SELECT INTO "nl:"
     nextseqnum = seq(carenet_seq,nextval)
     FROM dual
     DETAIL
      favorite_id = nextseqnum
     WITH format
    ;end select
    IF (favorite_id=0.0)
     GO TO exit_script
    ENDIF
    INSERT  FROM messaging_favorites mf
     SET mf.favorite_id = favorite_id, mf.prsnl_id = request->favorite_list[knt].personnel_id, mf
      .prsnl_group_id = request->favorite_list[knt].personnel_group_id,
      mf.favorite_type_cd = request->favorite_list[knt].favorite_type_cd, mf.parent_entity_name =
      request->favorite_list[knt].parent_entity_name, mf.parent_entity_id = request->favorite_list[
      knt].parent_entity_id,
      mf.updt_dt_tm = cnvtdatetime(curdate,curtime3), mf.updt_id = reqinfo->updt_id, mf.updt_task =
      reqinfo->updt_task,
      mf.updt_cnt = 0, mf.updt_applctx = reqinfo->updt_applctx
     WITH nocounter, status(internal->qual[knt].status)
    ;end insert
    IF (curqual > 0)
     IF ((internal->qual[knt].status > 0))
      SET added = (added+ 1)
      IF (added > 0)
       SET stat = alterlist(reply->favorite_list,added)
      ENDIF
      SET reply->favorite_list[added].favorite_id = favorite_id
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 IF (added=favorites_to_add)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSEIF (added != 0)
  SET reply->status_data.status = "P"
  SET reqinfo->commit_ind = 1
 ENDIF
 DECLARE ms_error_msg = vc WITH protect, noconstant("")
 IF (error(ms_error_msg,1) != 0)
  SET reply->status_data.subeventstatus[1].operationname = "Add Favorites"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "Run time error"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = ms_error_msg
 ENDIF
#exit_script
END GO
