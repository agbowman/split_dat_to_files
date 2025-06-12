CREATE PROGRAM ams_security_utility:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Action Type" = 0,
  "Select the Position(s)" = 0,
  "Select the Application Group(s)" = 0,
  "Audit OR Commit " = 0
  WITH outdev, script, position,
  app_group, action
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 DECLARE serrmsg = vc WITH protect, noconstant("")
 DECLARE ierrcode = i2 WITH protect, noconstant(0)
 DECLARE bamsassociate = i2 WITH protect, noconstant(false)
 DECLARE smessage = vc WITH protect, noconstant("")
 FREE RECORD rdata
 RECORD rdata(
   1 qual_knt = i4
   1 qual[*]
     2 object_name = vc
     2 user_name = vc
     2 compiled_dt_tm = vc
     2 source_name = vc
 )
 EXECUTE ams_define_toolkit_common
 SET bamsassociate = isamsuser(reqinfo->updt_id)
 IF ( NOT (bamsassociate))
  SET failed = exe_error
  SET serrmsg = "User must be a Cerner AMS associate to run this program from Explorer Menu"
  GO TO exit_script
 ENDIF
 IF (( $SCRIPT=1))
  FREE RECORD temp_request
  FREE RECORD request
  RECORD temp_request(
    1 qual[*]
      2 position_cd = f8
      2 pos_display = vc
      2 qual_ap[*]
        3 app_group_cd = f8
        3 appgroup_display = vc
        3 data_exist = i4
  )
  RECORD request(
    1 qual_pos[*]
      2 position_cd = f8
      2 qual_appgrp[*]
        3 app_group_cd = f8
        3 app_group_id = f8
  )
  SELECT INTO "nl:"
   FROM code_value cv
   WHERE cv.code_set=88
    AND cv.code_value IN ( $POSITION)
    AND cv.active_ind=1
    AND cv.end_effective_dt_tm > cnvtdatetime(sysdate)
   ORDER BY cv.code_value
   HEAD REPORT
    stat = alterlist(temp_request->qual,100), countp = 0
   DETAIL
    countp = (countp+ 1)
    IF (mod(countp,10)=1
     AND countp > 100)
     stat = alterlist(temp_request->qual,(countp+ 9))
    ENDIF
    temp_request->qual[countp].position_cd = cv.code_value, temp_request->qual[countp].pos_display =
    trim(substring(1,50,cv.display))
   FOOT REPORT
    stat = alterlist(temp_request->qual,countp)
   WITH nocounter
  ;end select
  SET countag = 0
  SET count_pos = 0
  SET count_pos = value(size(temp_request->qual,5))
  FOR (x = 1 TO count_pos BY 1)
    SELECT INTO "nl:"
     FROM code_value cv1
     WHERE cv1.code_set=500
      AND cv1.code_value IN ( $APP_GROUP)
      AND cv1.active_ind=1
      AND cv1.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     HEAD REPORT
      countag = 0, count_pos = 0, count_pos = value(size(temp_request->qual,5)),
      stat = alterlist(temp_request->qual[x].qual_ap,100)
     DETAIL
      countag = (countag+ 1)
      IF (mod(countag,10)=1
       AND countag > 100)
       stat = alterlist(temp_request->qual[x].qual_ap,(countag+ 9))
      ENDIF
      temp_request->qual[x].qual_ap[countag].app_group_cd = cv1.code_value, temp_request->qual[x].
      qual_ap[countag].appgroup_display = trim(substring(1,50,cv1.display))
     FOOT REPORT
      stat = alterlist(temp_request->qual[x].qual_ap,countag)
     WITH nocounter
    ;end select
  ENDFOR
  SET recur_cnt = value(size(temp_request->qual,5))
  FOR (i = 1 TO recur_cnt BY 1)
    SET nbr_of_records = 0
    SET nbr_of_records = value(size(temp_request->qual[i].qual_ap,5))
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(nbr_of_records)),
      application_group ag
     PLAN (d)
      JOIN (ag
      WHERE (ag.app_group_cd=temp_request->qual[i].qual_ap[d.seq].app_group_cd)
       AND (ag.position_cd=temp_request->qual[i].position_cd)
       AND ag.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     DETAIL
      temp_request->qual[i].qual_ap[d.seq].data_exist = 1
     WITH nocounter
    ;end select
  ENDFOR
  SET nbr_of_pos = value(size(temp_request->qual,5))
  FOR (n = 1 TO nbr_of_pos BY 1)
    SET nbr_of_ag = 0
    SET nbr_of_ag = value(size(temp_request->qual[n].qual_ap,5))
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = value(nbr_of_pos)),
      (dummyt d2  WITH seq = value(nbr_of_ag))
     PLAN (d1
      WHERE d1.seq <= size(temp_request->qual,5))
      JOIN (d2
      WHERE d2.seq <= size(temp_request->qual[d1.seq].qual_ap,5))
     HEAD REPORT
      stat = alterlist(request->qual_pos,10), cntp = 0
     HEAD d1.seq
      cntp = (cntp+ 1)
      IF (mod(cntp,10)=1
       AND cntp > 10)
       stat = alterlist(request->qual_pos,(cntp+ 9))
      ENDIF
      request->qual_pos[cntp].position_cd = temp_request->qual[d1.seq].position_cd, cntag = 0, stat
       = alterlist(request->qual_pos[d1.seq].qual_appgrp,10)
     DETAIL
      IF ((temp_request->qual[d1.seq].qual_ap[d2.seq].data_exist=0))
       cntag = (cntag+ 1)
       IF (mod(cntag,10)=1
        AND cntag > 10)
        stat = alterlist(request->qual_pos[d1.seq].qual_appgrp,(cntag+ 9))
       ENDIF
       request->qual_pos[cntp].qual_appgrp[cntag].app_group_cd = temp_request->qual[d1.seq].qual_ap[
       d2.seq].app_group_cd
      ENDIF
     FOOT  d1.seq
      stat = alterlist(request->qual_pos[d1.seq].qual_appgrp,cntag)
     FOOT REPORT
      stat = alterlist(request->qual_pos,cntp)
     WITH nocounter
    ;end select
    SET failures = 0
    IF (curqual=0)
     SET failures = (failures+ 1)
     GO TO exit_script_2
    ENDIF
  ENDFOR
  IF (( $ACTION=0))
   SET pos_disp = value(size(temp_request->qual,5))
   FOR (j = 1 TO pos_disp BY 1)
     SET appgroup_disp = 0
     SET apgroup_disp = value(size(temp_request->qual[j].qual_ap,5))
     SET action_1 = trim(substring(1,25,"Will be Inserted"))
     SET action_2 = trim(substring(1,25,"already exists"))
     SELECT INTO  $OUTDEV
      position = temp_request->qual[d1.seq].pos_display
      "##################################################", application_group = temp_request->qual[d1
      .seq].qual_ap[d2.seq].appgroup_display"##################################################",
      status =
      IF ((temp_request->qual[d1.seq].qual_ap[d2.seq].data_exist=0)) action_1
      ELSEIF ((temp_request->qual[d1.seq].qual_ap[d2.seq].data_exist=1)) action_2
      ENDIF
      FROM (dummyt d1  WITH seq = value(pos_disp)),
       (dummyt d2  WITH seq = value(apgroup_disp))
      PLAN (d1
       WHERE d1.seq <= size(temp_request->qual,5))
       JOIN (d2
       WHERE d2.seq <= size(temp_request->qual[d1.seq].qual_ap,5))
      ORDER BY temp_request->qual[d1.seq].pos_display, temp_request->qual[d1.seq].qual_ap[d2.seq].
       appgroup_display
      WITH separator = " ", format, ncounter
     ;end select
   ENDFOR
   GO TO exit_script_1
  ENDIF
  IF (( $ACTION=1))
   SET recur_cnt = size(request->qual_pos,5)
   FOR (y = 1 TO recur_cnt BY 1)
     SET number_to_insert = size(request->qual_pos[y].qual_appgrp,5)
     SET stat = alterlist(request->qual_pos[y].qual_appgrp,number_to_insert)
     FOR (z = 1 TO number_to_insert BY 1)
       SELECT INTO "nl:"
        nextseqnum = seq(reference_seq,nextval)
        FROM dual
        DETAIL
         request->qual_pos[y].qual_appgrp[z].app_group_id = nextseqnum
        WITH nocounter
       ;end select
     ENDFOR
     SET failures = 0
     IF (curqual=0)
      SET failures = (failures+ 1)
      GO TO exit_script_2
     ENDIF
   ENDFOR
   SET number_of_positions = value(size(request->qual_pos,5))
   FOR (a = 1 TO number_of_positions BY 1)
    SET number_to_insert = value(size(request->qual_pos[a].qual_appgrp,5))
    INSERT  FROM application_group a,
      (dummyt d  WITH seq = value(number_to_insert))
     SET a.seq = 1, a.application_group_id = request->qual_pos[a].qual_appgrp[d.seq].app_group_id, a
      .position_cd = request->qual_pos[a].position_cd,
      a.app_group_cd = request->qual_pos[a].qual_appgrp[d.seq].app_group_cd, a.person_id = 0, a
      .beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
      a.end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00.00"), a.updt_dt_tm = cnvtdatetime(
       curdate,curtime3), a.updt_id = reqinfo->updt_id,
      a.updt_task = reqinfo->updt_task, a.updt_cnt = 0, a.updt_applctx = reqinfo->updt_applctx
     PLAN (d)
      JOIN (a)
     WITH nocounter
    ;end insert
   ENDFOR
#exit_script_2
   IF (failures=0)
    SET reqinfo->commit_ind = 1
   ELSE
    SET reqinfo->commit_ind = 0
   ENDIF
   SET pos_disp = value(size(temp_request->qual,5))
   FOR (j = 1 TO pos_disp BY 1)
     SET appgroup_disp = 0
     SET apgroup_disp = value(size(temp_request->qual[j].qual_ap,5))
     SET action_1 = trim(substring(1,25,"Inserted"))
     SET action_2 = trim(substring(1,25,"already exists"))
     SELECT INTO  $OUTDEV
      position = temp_request->qual[d1.seq].pos_display
      "##################################################", application_group = temp_request->qual[d1
      .seq].qual_ap[d2.seq].appgroup_display"##################################################",
      status =
      IF ((temp_request->qual[d1.seq].qual_ap[d2.seq].data_exist=0)) action_1
      ELSEIF ((temp_request->qual[d1.seq].qual_ap[d2.seq].data_exist=1)) action_2
      ENDIF
      FROM (dummyt d1  WITH seq = value(pos_disp)),
       (dummyt d2  WITH seq = value(apgroup_disp))
      PLAN (d1
       WHERE d1.seq <= size(temp_request->qual,5))
       JOIN (d2
       WHERE d2.seq <= size(temp_request->qual[d1.seq].qual_ap,5))
      ORDER BY temp_request->qual[d1.seq].pos_display, temp_request->qual[d1.seq].qual_ap[d2.seq].
       appgroup_display
      WITH separator = " ", format, ncounter
     ;end select
   ENDFOR
   FREE RECORD temp_request
   FREE RECORD request
  ENDIF
#exit_script_1
  IF (failed != false)
   SELECT INTO value( $OUTDEV)
    message = trim(substring(1,200,serrmsg),3)
    FROM (dummyt d  WITH seq = 1)
    WITH nocounter, format, separator = " "
   ;end select
  ENDIF
  IF (failed != exe_error)
   CALL updtdminfo(trim(cnvtupper(curprog),3))
  ENDIF
  FREE RECORD temp_request
  FREE RECORD request
 ELSEIF (( $SCRIPT=0))
  FREE RECORD temp_request
  FREE RECORD request
  RECORD temp_request(
    1 qual[*]
      2 position_cd = f8
      2 pos_display = vc
      2 qual_ap[*]
        3 app_group_cd = f8
        3 appgroup_display = vc
        3 data_exist = i4
  )
  RECORD request(
    1 qual_pos[*]
      2 position_cd = f8
      2 qual_appgrp[*]
        3 app_group_cd = f8
  )
  SELECT INTO "nl:"
   FROM code_value cv
   WHERE cv.code_set=88
    AND cv.code_value IN ( $POSITION)
    AND cv.active_ind=1
    AND cv.end_effective_dt_tm > cnvtdatetime(sysdate)
   ORDER BY cv.code_value
   HEAD REPORT
    stat = alterlist(temp_request->qual,100), countp = 0
   DETAIL
    countp = (countp+ 1)
    IF (mod(countp,10)=1
     AND countp > 100)
     stat = alterlist(temp_request->qual,(countp+ 9))
    ENDIF
    temp_request->qual[countp].position_cd = cv.code_value, temp_request->qual[countp].pos_display =
    trim(substring(1,50,cv.display))
   FOOT REPORT
    stat = alterlist(temp_request->qual,countp)
   WITH nocounter
  ;end select
  SET countag = 0
  SET count_pos = 0
  SET count_pos = value(size(temp_request->qual,5))
  FOR (x = 1 TO count_pos BY 1)
    SELECT INTO "nl:"
     FROM code_value cv1
     WHERE cv1.code_set=500
      AND cv1.code_value IN ( $APP_GROUP)
      AND cv1.active_ind=1
      AND cv1.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     HEAD REPORT
      countag = 0, count_pos = 0, count_pos = value(size(temp_request->qual,5)),
      stat = alterlist(temp_request->qual[x].qual_ap,100)
     DETAIL
      countag = (countag+ 1)
      IF (mod(countag,10)=1
       AND countag > 100)
       stat = alterlist(temp_request->qual[x].qual_ap,(countag+ 9))
      ENDIF
      temp_request->qual[x].qual_ap[countag].app_group_cd = cv1.code_value, temp_request->qual[x].
      qual_ap[countag].appgroup_display = trim(substring(1,50,cv1.display))
     FOOT REPORT
      stat = alterlist(temp_request->qual[x].qual_ap,countag)
     WITH nocounter
    ;end select
  ENDFOR
  SET recur_cnt = value(size(temp_request->qual,5))
  FOR (i = 1 TO recur_cnt BY 1)
    SET nbr_of_records = 0
    SET nbr_of_records = value(size(temp_request->qual[i].qual_ap,5))
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(nbr_of_records)),
      application_group ag
     PLAN (d)
      JOIN (ag
      WHERE (ag.app_group_cd=temp_request->qual[i].qual_ap[d.seq].app_group_cd)
       AND (ag.position_cd=temp_request->qual[i].position_cd)
       AND ag.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     DETAIL
      temp_request->qual[i].qual_ap[d.seq].data_exist = 1
     WITH nocounter
    ;end select
  ENDFOR
  SET nbr_of_pos = value(size(temp_request->qual,5))
  FOR (n = 1 TO nbr_of_pos BY 1)
    SET nbr_of_ag = 0
    SET nbr_of_ag = value(size(temp_request->qual[n].qual_ap,5))
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = value(nbr_of_pos)),
      (dummyt d2  WITH seq = value(nbr_of_ag))
     PLAN (d1
      WHERE d1.seq <= size(temp_request->qual,5))
      JOIN (d2
      WHERE d2.seq <= size(temp_request->qual[d1.seq].qual_ap,5))
     HEAD REPORT
      stat = alterlist(request->qual_pos,10), cntp = 0
     HEAD d1.seq
      cntp = (cntp+ 1)
      IF (mod(cntp,10)=1
       AND cntp > 10)
       stat = alterlist(request->qual_pos,(cntp+ 9))
      ENDIF
      request->qual_pos[cntp].position_cd = temp_request->qual[d1.seq].position_cd, cntag = 0, stat
       = alterlist(request->qual_pos[d1.seq].qual_appgrp,10)
     DETAIL
      IF ((temp_request->qual[d1.seq].qual_ap[d2.seq].data_exist=1))
       cntag = (cntag+ 1)
       IF (mod(cntag,10)=1
        AND cntag > 10)
        stat = alterlist(request->qual_pos[d1.seq].qual_appgrp,(cntag+ 9))
       ENDIF
       request->qual_pos[cntp].qual_appgrp[cntag].app_group_cd = temp_request->qual[d1.seq].qual_ap[
       d2.seq].app_group_cd
      ENDIF
     FOOT  d1.seq
      stat = alterlist(request->qual_pos[d1.seq].qual_appgrp,cntag)
     FOOT REPORT
      stat = alterlist(request->qual_pos,cntp)
     WITH nocounter
    ;end select
  ENDFOR
  IF (( $ACTION=0))
   SET pos_disp = value(size(temp_request->qual,5))
   FOR (j = 1 TO pos_disp BY 1)
     SET appgroup_disp = 0
     SET apgroup_disp = value(size(temp_request->qual[j].qual_ap,5))
     SET action_1 = trim(substring(1,25,"Will be deleted"))
     SET action_2 = trim(substring(1,25,"does not exist"))
     SELECT INTO  $OUTDEV
      position = temp_request->qual[d1.seq].pos_display
      "##################################################", application_group = temp_request->qual[d1
      .seq].qual_ap[d2.seq].appgroup_display"##################################################",
      status =
      IF ((temp_request->qual[d1.seq].qual_ap[d2.seq].data_exist=1)) action_1
      ELSEIF ((temp_request->qual[d1.seq].qual_ap[d2.seq].data_exist=0)) action_2
      ENDIF
      FROM (dummyt d1  WITH seq = value(pos_disp)),
       (dummyt d2  WITH seq = value(apgroup_disp))
      PLAN (d1
       WHERE d1.seq <= size(temp_request->qual,5))
       JOIN (d2
       WHERE d2.seq <= size(temp_request->qual[d1.seq].qual_ap,5))
      ORDER BY temp_request->qual[d1.seq].pos_display, temp_request->qual[d1.seq].qual_ap[d2.seq].
       appgroup_display
      WITH separator = " ", format, ncounter
     ;end select
   ENDFOR
   GO TO exit_script_3
  ENDIF
  IF (( $ACTION=1))
   SET number_of_positions = value(size(request->qual_pos,5))
   FOR (a = 1 TO number_of_positions BY 1)
     SET number_to_delete = value(size(request->qual_pos[a].qual_appgrp,5))
     DELETE  FROM application_group a,
       (dummyt d  WITH seq = value(number_to_delete))
      SET a.seq = 1
      PLAN (d)
       JOIN (a
       WHERE (a.position_cd=request->qual_pos[a].position_cd)
        AND (a.app_group_cd=request->qual_pos[a].qual_appgrp[d.seq].app_group_cd))
      WITH nocounter
     ;end delete
     COMMIT
   ENDFOR
   SET pos_disp = value(size(temp_request->qual,5))
   FOR (j = 1 TO pos_disp BY 1)
     SET appgroup_disp = 0
     SET apgroup_disp = value(size(temp_request->qual[j].qual_ap,5))
     SET action_1 = trim(substring(1,25,"deleted"))
     SET action_2 = trim(substring(1,25,"does not exist"))
     SELECT INTO  $OUTDEV
      position = temp_request->qual[d1.seq].pos_display
      "##################################################", application_group = temp_request->qual[d1
      .seq].qual_ap[d2.seq].appgroup_display"##################################################",
      status =
      IF ((temp_request->qual[d1.seq].qual_ap[d2.seq].data_exist=1)) action_1
      ELSEIF ((temp_request->qual[d1.seq].qual_ap[d2.seq].data_exist=0)) action_2
      ENDIF
      FROM (dummyt d1  WITH seq = value(pos_disp)),
       (dummyt d2  WITH seq = value(apgroup_disp))
      PLAN (d1
       WHERE d1.seq <= size(temp_request->qual,5))
       JOIN (d2
       WHERE d2.seq <= size(temp_request->qual[d1.seq].qual_ap,5))
      ORDER BY temp_request->qual[d1.seq].pos_display, temp_request->qual[d1.seq].qual_ap[d2.seq].
       appgroup_display
      WITH separator = " ", format, ncounter
     ;end select
   ENDFOR
   FREE RECORD temp_request
   FREE RECORD request
  ENDIF
#exit_script_3
  IF (failed != false)
   SELECT INTO value( $OUTDEV)
    message = trim(substring(1,200,serrmsg),3)
    FROM (dummyt d  WITH seq = 1)
    WITH nocounter, format, separator = " "
   ;end select
  ENDIF
  IF (failed != exe_error)
   CALL updtdminfo(trim(cnvtupper(curprog),3))
  ENDIF
  FREE RECORD temp_request
  FREE RECORD request
 ENDIF
END GO
