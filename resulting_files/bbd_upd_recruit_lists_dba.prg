CREATE PROGRAM bbd_upd_recruit_lists:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET modify = predeclare
 DECLARE errorhandler(operationstatus=c1,targetobjectname=c25,targetobjectvalue=vc) = null
 DECLARE script_name = c25 WITH protect, constant("BBD_UPD_RECRUIT_LISTS")
 DECLARE lstat = i4 WITH protect, noconstant(0)
 DECLARE llidx = i4 WITH public, noconstant(0)
 DECLARE lzidx = i4 WITH public, noconstant(0)
 DECLARE laidx = i4 WITH public, noconstant(0)
 DECLARE errmsg = c132 WITH protect, noconstant(fillstring(132," "))
 DECLARE error_check = i2 WITH protect, noconstant(error(errmsg,1))
 DECLARE dnewzipcodeid = f8 WITH protect, noconstant(0.0)
 DECLARE dnewantigenid = f8 WITH protect, noconstant(0.0)
 SET reply->status_data.status = "F"
 FOR (llidx = 1 TO size(request->recruitinglist,5))
   IF ((request->recruitinglist[llidx].add_change_ind=1))
    SELECT INTO "nl:"
     rl.display_name_key
     FROM bbd_recruiting_list rl
     WHERE (rl.display_name_key=request->recruitinglist[llidx].display_key)
      AND rl.active_ind=1
      AND rl.completed_ind=0
     WITH nocounter
    ;end select
    SET error_check = error(errmsg,0)
    IF (error_check != 0)
     CALL errorhandler("F","Select recruit list.",errmsg)
    ENDIF
    IF (curqual > 0)
     SET reply->status_data.status = "Z"
     GO TO set_status
    ELSE
     INSERT  FROM bbd_recruiting_list rl
      SET rl.list_id = request->recruitinglist[llidx].list_id, rl.active_ind = request->
       recruitinglist[llidx].active_ind, rl.completed_ind = request->recruitinglist[llidx].
       completed_ind,
       rl.display_name = request->recruitinglist[llidx].display, rl.display_name_key = request->
       recruitinglist[llidx].display_key, rl.donation_dt_tm = cnvtdatetime(request->recruitinglist[
        llidx].donation_dt_tm),
       rl.product_type_cd = request->recruitinglist[llidx].product_type_cd, rl.rare_type_cd = request
       ->recruitinglist[llidx].rare_type_cd, rl.special_interest_cd = request->recruitinglist[llidx].
       special_interest_cd,
       rl.abo_cd = request->recruitinglist[llidx].abo_cd, rl.rh_cd = request->recruitinglist[llidx].
       rh_cd, rl.race_cd = request->recruitinglist[llidx].race_cd,
       rl.organization_id = request->recruitinglist[llidx].organization_id, rl.last_outcome_cd =
       request->recruitinglist[llidx].last_outcome_cd, rl.contact_method_cd = request->
       recruitinglist[llidx].contact_method_cd,
       rl.max_donor_cnt = request->recruitinglist[llidx].max_donor_count, rl
       .preferred_donation_location_cd = request->recruitinglist[llidx].
       preferred_donation_location_cd, rl.multiple_list_ind = request->recruitinglist[llidx].
       multiple_list_ind,
       rl.lock_ind = request->recruitinglist[llidx].lock_ind, rl.updt_applctx = reqinfo->updt_applctx,
       rl.updt_cnt = 0,
       rl.updt_dt_tm = cnvtdatetime(curdate,curtime3), rl.updt_id = reqinfo->updt_id, rl.updt_task =
       reqinfo->updt_task
      WITH nocounter
     ;end insert
     SET error_check = error(errmsg,0)
     IF (error_check != 0)
      CALL errorhandler("F","Insert recruit list.",errmsg)
     ENDIF
     FOR (lzidx = 1 TO size(request->recruitinglist[llidx].zipcodelist,5))
       SET dnewzipcodeid = 0
       SELECT INTO "nl:"
        seqn = seq(pathnet_seq,nextval)
        FROM dual
        DETAIL
         dnewzipcodeid = seqn
        WITH format, counter
       ;end select
       SET error_check = error(errmsg,0)
       IF (error_check != 0)
        CALL errorhandler("F","Generate New ZipCodeID",errmsg)
       ENDIF
       INSERT  FROM bbd_recruiting_zipcode rz
        SET rz.zip_code_id = dnewzipcodeid, rz.active_ind = 1, rz.list_id = request->recruitinglist[
         llidx].list_id,
         rz.zip_code = request->recruitinglist[llidx].zipcodelist[lzidx].zip_code, rz.address_type_cd
          = request->recruitinglist[llidx].zipcodelist[lzidx].address_type_cd, rz.updt_applctx =
         reqinfo->updt_applctx,
         rz.updt_cnt = 0, rz.updt_dt_tm = cnvtdatetime(curdate,curtime3), rz.updt_id = reqinfo->
         updt_id,
         rz.updt_task = reqinfo->updt_task
        WITH nocounter
       ;end insert
       SET error_check = error(errmsg,0)
       IF (error_check != 0)
        CALL errorhandler("F","Insert New ZipCode.",errmsg)
       ENDIF
     ENDFOR
     FOR (laidx = 1 TO size(request->recruitinglist[llidx].antigenlist,5))
       SET dnewantigenid = 0
       SELECT INTO "nl:"
        seqn = seq(pathnet_seq,nextval)
        FROM dual
        DETAIL
         dnewantigenid = seqn
        WITH format, counter
       ;end select
       SET error_check = error(errmsg,0)
       IF (error_check != 0)
        CALL errorhandler("F","Generate New AntigenId",errmsg)
       ENDIF
       INSERT  FROM bbd_recruiting_antigen ra
        SET ra.active_ind = 1, ra.antigen_cd = request->recruitinglist[llidx].antigenlist[laidx].
         antigen_cd, ra.list_id = request->recruitinglist[llidx].list_id,
         ra.recruit_antigen_id = dnewantigenid, ra.updt_applctx = reqinfo->updt_applctx, ra.updt_cnt
          = 0,
         ra.updt_dt_tm = cnvtdatetime(curdate,curtime3), ra.updt_id = reqinfo->updt_id, ra.updt_task
          = reqinfo->updt_task
        WITH nocounter
       ;end insert
       SET error_check = error(errmsg,0)
       IF (error_check != 0)
        CALL errorhandler("F","Insert New Antigen.",errmsg)
       ENDIF
     ENDFOR
    ENDIF
   ELSEIF ((request->recruitinglist[llidx].add_change_ind=2))
    SELECT INTO "nl:"
     rl.list_id
     FROM bbd_recruiting_list rl
     WHERE (rl.list_id=request->recruitinglist[llidx].list_id)
      AND (rl.updt_cnt=request->recruitinglist[llidx].updt_cnt)
     WITH nocounter, forupdate(rl)
    ;end select
    SET error_check = error(errmsg,0)
    IF (error_check != 0)
     CALL errorhandler("F","Select existing list.",errmsg)
    ENDIF
    IF (curqual=0)
     CALL errorhandler("F","BBD_UPD_RECRUIT_LISTS","Row does not exist - BBD_RECRUITING_LIST.")
    ELSE
     UPDATE  FROM bbd_recruiting_list rl
      SET rl.completed_ind = request->recruitinglist[llidx].completed_ind, rl.active_ind = request->
       recruitinglist[llidx].active_ind, rl.lock_ind = request->recruitinglist[llidx].lock_ind,
       rl.updt_cnt = (request->recruitinglist[llidx].updt_cnt+ 1), rl.updt_dt_tm = cnvtdatetime(
        curdate,curtime3), rl.updt_id = reqinfo->updt_id,
       rl.updt_task = reqinfo->updt_task, rl.updt_applctx = reqinfo->updt_applctx
      WHERE (rl.list_id=request->recruitinglist[llidx].list_id)
       AND (rl.updt_cnt=request->recruitinglist[llidx].updt_cnt)
      WITH nocounter
     ;end update
     SET error_check = error(errmsg,0)
     IF (error_check != 0)
      CALL errorhandler("F","Update existing list.",errmsg)
     ENDIF
     IF (curqual > 0
      AND (request->recruitinglist[llidx].active_ind=0))
      SELECT INTO "nl:"
       rdr.person_id
       FROM bbd_recruiting_donor_reltn rdr
       WHERE (rdr.list_id=request->recruitinglist[llidx].list_id)
        AND rdr.active_ind=1
       WITH nocounter, forupdate(rdr)
      ;end select
      SET error_check = error(errmsg,0)
      IF (error_check != 0)
       CALL errorhandler("F","Select recruit donor.",errmsg)
      ENDIF
      IF (curqual > 0)
       UPDATE  FROM bbd_recruiting_donor_reltn rdr
        SET rdr.active_ind = 0, rdr.updt_cnt = (rdr.updt_cnt+ 1), rdr.updt_dt_tm = cnvtdatetime(
          curdate,curtime3),
         rdr.updt_id = reqinfo->updt_id, rdr.updt_task = reqinfo->updt_task, rdr.updt_applctx =
         reqinfo->updt_applctx
        WHERE (rdr.list_id=request->recruitinglist[llidx].list_id)
        WITH nocounter
       ;end update
       SET error_check = error(errmsg,0)
       IF (error_check != 0)
        CALL errorhandler("F","Update recruit donor.",errmsg)
       ENDIF
      ENDIF
     ENDIF
     FOR (lzidx = 1 TO size(request->recruitinglist[llidx].zipcodelist,5))
       SELECT INTO "nl:"
        rz.zip_code_id
        FROM bbd_recruiting_zipcode rz
        WHERE (rz.list_id=request->recruitinglist[llidx].list_id)
         AND (rz.zip_code=request->recruitinglist[llidx].zipcodelist[lzidx].zip_code)
         AND rz.active_ind=1
        WITH nocounter, forupdate(rz)
       ;end select
       SET error_check = error(errmsg,0)
       IF (error_check != 0)
        CALL errorhandler("F","Select list zipcodes.",errmsg)
       ENDIF
       UPDATE  FROM bbd_recruiting_zipcode rz
        SET rz.active_ind = 0, rz.updt_applctx = reqinfo->updt_applctx, rz.updt_cnt = (rz.updt_cnt+ 1
         ),
         rz.updt_dt_tm = cnvtdatetime(curdate,curtime3), rz.updt_id = reqinfo->updt_id, rz.updt_task
          = reqinfo->updt_task
        WHERE (rz.list_id=request->recruitinglist[llidx].list_id)
         AND (rz.zip_code=request->recruitinglist[llidx].zipcodelist[lzidx].zip_code)
         AND rz.active_ind=1
        WITH nocounter
       ;end update
       SET error_check = error(errmsg,0)
       IF (error_check != 0)
        CALL errorhandler("F","Update New ZipCode.",errmsg)
       ENDIF
     ENDFOR
     FOR (laidx = 1 TO size(request->recruitinglist[llidx].antigenlist,5))
       SELECT INTO "nl:"
        ra.recruit_antigen_id
        FROM bbd_recruiting_antigen ra
        WHERE (ra.list_id=request->recruitinglist[llidx].list_id)
         AND (ra.antigen_cd=request->recruitinglist[llidx].antigenlist[laidx].antigen_cd)
         AND ra.active_ind=1
        WITH nocounter, forupdate(ra)
       ;end select
       SET error_check = error(errmsg,0)
       IF (error_check != 0)
        CALL errorhandler("F","Select list antigens.",errmsg)
       ENDIF
       UPDATE  FROM bbd_recruiting_antigen ra
        SET ra.active_ind = 0, ra.updt_applctx = reqinfo->updt_applctx, ra.updt_cnt = (ra.updt_cnt+ 1
         ),
         ra.updt_dt_tm = cnvtdatetime(curdate,curtime3), ra.updt_id = reqinfo->updt_id, ra.updt_task
          = reqinfo->updt_task
        WHERE (ra.list_id=request->recruitinglist[llidx].list_id)
         AND (ra.antigen_cd=request->recruitinglist[llidx].antigenlist[laidx].antigen_cd)
         AND ra.active_ind=1
        WITH nocounter
       ;end update
       SET error_check = error(errmsg,0)
       IF (error_check != 0)
        CALL errorhandler("F","Update Antigen.",errmsg)
       ENDIF
     ENDFOR
    ENDIF
   ENDIF
 ENDFOR
 GO TO set_status
 SUBROUTINE errorhandler(operationstatus,targetobjectname,targetobjectvalue)
   DECLARE error_cnt = i2 WITH private, noconstant(0)
   SET error_cnt = size(reply->status_data.subeventstatus,5)
   IF (((error_cnt > 1) OR (error_cnt=1
    AND (reply->status_data.subeventstatus[error_cnt].operationstatus != ""))) )
    SET error_cnt = (error_cnt+ 1)
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[error_cnt].operationname = script_name
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = operationstatus
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = targetobjectname
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = targetobjectvalue
   SET reqinfo->commit_ind = 0
   GO TO exit_script
 END ;Subroutine
#set_status
 IF ((reply->status_data.status="Z"))
  SET reply->status_data.subeventstatus[1].operationname = script_name
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "BBD_UPD_RECRUIT_LISTS"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Recruitment List - Duplicate Name exists."
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
#exit_script
END GO
