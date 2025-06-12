CREATE PROGRAM ams_ppr_security:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Action_Type" = "",
  "Audit (OR) Commit" = 0,
  "Select the UserName(s)" = 0,
  "Select the Institution(s) and Department(s)" = 0,
  "Select the Section(s) and SubSection(s)" = 0,
  "Select the Resource" = 0,
  "" = 0,
  "" = 0,
  "Select the User" = 0,
  "Select the User(s)" = 0
  WITH outdev, script, action,
  username, institution, department,
  section, subsection, resource,
  copy_from_user, copy_to_users
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
 IF (( $SCRIPT="A"))
  FREE RECORD data
  RECORD data(
    1 qual_p[*]
      2 prsnl_id = f8
      2 prsnl_name = vc
      2 qual_s[*]
        3 service_resource_cd = f8
        3 service_resource_name = vc
        3 data_exist = i4
  )
  FREE RECORD event
  RECORD event(
    1 qual_pr[*]
      2 prsnl_id = f8
      2 qual_sr[*]
        3 service_resource_cd = f8
  )
  FREE RECORD request
  RECORD request(
    1 qual[*]
      2 prsnl_id = f8
      2 service_resource_cd = f8
  )
  SELECT INTO "nl:"
   FROM prsnl p
   PLAN (p
    WHERE p.person_id IN ( $USERNAME)
     AND p.active_ind=1
     AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   ORDER BY p.person_id
   HEAD REPORT
    stat = alterlist(data->qual_p,100), cntp = 0
   HEAD p.person_id
    cntp = (cntp+ 1)
    IF (mod(cntp,10)=1
     AND cntp > 100)
     stat = alterlist(data->qual_p,(cntp+ 9))
    ENDIF
    data->qual_p[cntp].prsnl_id = p.person_id, data->qual_p[cntp].prsnl_name = substring(1,200,p
     .name_full_formatted)
   FOOT REPORT
    stat = alterlist(data->qual_p,cntp)
   WITH nocounter
  ;end select
  CALL echorecord(data)
  SET count_p = cnvtint(value(size(data->qual_p,5)))
  FOR (x = 1 TO count_p BY 1)
    SELECT INTO "nl:"
     FROM service_resource sr
     PLAN (sr
      WHERE sr.service_resource_cd IN ( $INSTITUTION,  $DEPARTMENT,  $SECTION,  $SUBSECTION,
       $RESOURCE)
       AND sr.active_ind=1
       AND sr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     ORDER BY sr.service_resource_cd
     HEAD REPORT
      stat = alterlist(data->qual_p[x].qual_s,100), cnts = 0
     HEAD sr.service_resource_cd
      cnts = (cnts+ 1)
      IF (mod(cnts,10)=1
       AND cnts > 100)
       stat = alterlist(data->qual_p[x].qual_s,(cnts+ 9))
      ENDIF
      data->qual_p[x].qual_s[cnts].service_resource_cd = sr.service_resource_cd, data->qual_p[x].
      qual_s[cnts].service_resource_name = uar_get_code_description(sr.service_resource_cd)
     FOOT REPORT
      stat = alterlist(data->qual_p[x].qual_s,cnts)
     WITH nocounter
    ;end select
  ENDFOR
  CALL echorecord(data)
  SET count_d = cnvtint(value(size(data->qual_p,5)))
  FOR (y = 1 TO count_d BY 1)
   SET count_d1 = value(size(data->qual_p[y].qual_s,5))
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(count_d1)),
     prsnl_service_resource_reltn pr
    PLAN (d1)
     JOIN (pr
     WHERE (pr.prsnl_id=data->qual_p[y].prsnl_id)
      AND (pr.service_resource_cd=data->qual_p[y].qual_s[d1.seq].service_resource_cd)
      AND pr.updt_dt_tm < cnvtdatetime(curdate,curtime3))
    DETAIL
     data->qual_p[y].qual_s[d1.seq].data_exist = 1
    WITH nocounter
   ;end select
  ENDFOR
  CALL echorecord(data)
  SET count_e = cnvtint(value(size(data->qual_p,5)))
  FOR (z = 1 TO count_e BY 1)
   SET count_e1 = value(size(data->qual_p[z].qual_s,5))
   SELECT INTO "nl:"
    FROM (dummyt d2  WITH seq = value(count_e)),
     (dummyt d3  WITH seq = value(count_e1))
    PLAN (d2
     WHERE d2.seq <= size(data->qual_p,5))
     JOIN (d3
     WHERE d3.seq <= size(data->qual_p[d2.seq].qual_s,5))
    HEAD REPORT
     stat = alterlist(event->qual_pr,100), cntpr = 0
    HEAD d2.seq
     cntpr = (cntpr+ 1)
     IF (mod(cntpr,10)=1
      AND cntpr > 100)
      stat = alterlist(event->qual_pr,(cntpr+ 9))
     ENDIF
     event->qual_pr[cntpr].prsnl_id = data->qual_p[d2.seq].prsnl_id, stat = alterlist(event->qual_pr[
      cntpr].qual_sr,100), cntsr = 0
    DETAIL
     IF ((data->qual_p[d2.seq].qual_s[d3.seq].data_exist=0))
      cntsr = (cntsr+ 1)
      IF (mod(cntsr,10)=1
       AND cntsr > 100)
       stat = alterlist(event->qual_pr[cntpr].qual_sr,(cntsr+ 9))
      ENDIF
      event->qual_pr[cntpr].qual_sr[cntsr].service_resource_cd = data->qual_p[d2.seq].qual_s[d3.seq].
      service_resource_cd
     ENDIF
    FOOT  d2.seq
     stat = alterlist(event->qual_pr[cntpr].qual_sr,cntsr)
    FOOT REPORT
     stat = alterlist(event->qual_pr,cntpr)
    WITH nocounter
   ;end select
  ENDFOR
  CALL echorecord(event)
  SET count_r = value(size(event->qual_pr,5))
  FOR (j = 1 TO count_r BY 1)
   SET count_r1 = value(size(event->qual_pr[j].qual_sr,5))
   IF (count_r1 > 0)
    SELECT INTO "nl:"
     FROM (dummyt d4  WITH seq = value(count_r)),
      (dummyt d5  WITH seq = value(count_r1))
     PLAN (d4
      WHERE d4.seq <= size(event->qual_pr,5))
      JOIN (d5
      WHERE d5.seq <= size(event->qual_pr[d4.seq].qual_sr,5))
     HEAD REPORT
      stat = alterlist(request->qual,100), cntr = 0
     DETAIL
      IF ((event->qual_pr[d4.seq].qual_sr[d5.seq].service_resource_cd > 0))
       cntr = (cntr+ 1)
       IF (mod(cntr,10)=1
        AND cntr > 100)
        stat = alterlist(request->qual,(cntr+ 9))
       ENDIF
       request->qual[cntr].prsnl_id = event->qual_pr[d4.seq].prsnl_id, request->qual[cntr].
       service_resource_cd = event->qual_pr[d4.seq].qual_sr[d5.seq].service_resource_cd
      ENDIF
     FOOT REPORT
      stat = alterlist(request->qual,cntr)
     WITH nocounter
    ;end select
   ENDIF
  ENDFOR
  IF (( $ACTION=0))
   SET prsnl_display = value(size(data->qual_p,5))
   FOR (i = 1 TO prsnl_display BY 1)
    SET service_resource_display = value(size(data->qual_p[i].qual_s,5))
    SELECT INTO  $OUTDEV
     name = substring(1,200,data->qual_p[d7.seq].prsnl_name), service_resource = substring(1,200,data
      ->qual_p[d7.seq].qual_s[d8.seq].service_resource_name), action =
     IF ((data->qual_p[d7.seq].qual_s[d8.seq].data_exist=0)) "Will be Inserted"
     ELSEIF ((data->qual_p[d7.seq].qual_s[d8.seq].data_exist=1)) "Already exists"
     ENDIF
     FROM (dummyt d7  WITH seq = value(prsnl_display)),
      (dummyt d8  WITH seq = value(service_resource_display))
     PLAN (d7
      WHERE d7.seq <= size(data->qual_p,5))
      JOIN (d8
      WHERE d8.seq <= size(data->qual_p[d7.seq].qual_s,5))
     ORDER BY name, service_resource
     WITH separator = " ", format, nocounter
    ;end select
   ENDFOR
  ENDIF
  IF (( $ACTION=1))
   SET service_resource_insert = value(size(request->qual,5))
   IF (service_resource_insert > 0)
    INSERT  FROM prsnl_service_resource_reltn psr,
      (dummyt d  WITH seq = value(service_resource_insert))
     SET psr.prsnl_id = request->qual[d.seq].prsnl_id, psr.service_resource_cd = request->qual[d.seq]
      .service_resource_cd, psr.updt_cnt = 0,
      psr.updt_dt_tm = cnvtdatetime(curdate,curtime3), psr.updt_id = reqinfo->updt_id, psr.updt_task
       = reqinfo->updt_task,
      psr.updt_applctx = reqinfo->updt_applctx
     PLAN (d)
      JOIN (psr)
     WITH nocounter
    ;end insert
    COMMIT
   ENDIF
   SET prsnl_display = value(size(data->qual_p,5))
   FOR (i = 1 TO prsnl_display BY 1)
    SET service_resource_display = value(size(data->qual_p[i].qual_s,5))
    SELECT INTO  $OUTDEV
     name = substring(1,200,data->qual_p[d7.seq].prsnl_name), service_resource = substring(1,200,data
      ->qual_p[d7.seq].qual_s[d8.seq].service_resource_name), action =
     IF ((data->qual_p[d7.seq].qual_s[d8.seq].data_exist=0)) "Inserted"
     ELSEIF ((data->qual_p[d7.seq].qual_s[d8.seq].data_exist=1)) "Already exists"
     ENDIF
     FROM (dummyt d7  WITH seq = value(prsnl_display)),
      (dummyt d8  WITH seq = value(service_resource_display))
     PLAN (d7
      WHERE d7.seq <= size(data->qual_p,5))
      JOIN (d8
      WHERE d8.seq <= size(data->qual_p[d7.seq].qual_s,5))
     ORDER BY name, service_resource
     WITH separator = " ", format, nocounter
    ;end select
   ENDFOR
  ENDIF
  FREE RECORD data
  FREE RECORD event
  FREE RECORD request
 ELSEIF (( $SCRIPT="R"))
  FREE RECORD data
  RECORD data(
    1 qual_p[*]
      2 prsnl_id = f8
      2 prsnl_name = vc
      2 qual_s[*]
        3 service_resource_cd = f8
        3 service_resource_name = vc
        3 data_exist = i4
  )
  FREE RECORD event
  RECORD event(
    1 qual_pr[*]
      2 prsnl_id = f8
      2 qual_sr[*]
        3 service_resource_cd = f8
  )
  FREE RECORD request
  RECORD request(
    1 qual[*]
      2 prsnl_id = f8
      2 service_resource_cd = f8
  )
  SELECT INTO "nl:"
   FROM prsnl p
   PLAN (p
    WHERE p.person_id IN ( $USERNAME)
     AND p.active_ind=1
     AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   ORDER BY p.person_id
   HEAD REPORT
    stat = alterlist(data->qual_p,100), cntp = 0
   HEAD p.person_id
    cntp = (cntp+ 1)
    IF (mod(cntp,10)=1
     AND cntp > 100)
     stat = alterlist(data->qual_p,(cntp+ 9))
    ENDIF
    data->qual_p[cntp].prsnl_id = p.person_id, data->qual_p[cntp].prsnl_name = substring(1,200,p
     .name_full_formatted)
   FOOT REPORT
    stat = alterlist(data->qual_p,cntp)
   WITH nocounter
  ;end select
  SET count_p = cnvtint(value(size(data->qual_p,5)))
  FOR (x = 1 TO count_p BY 1)
    SELECT INTO "nl:"
     FROM service_resource sr
     PLAN (sr
      WHERE sr.service_resource_cd IN ( $INSTITUTION,  $DEPARTMENT,  $SECTION,  $SUBSECTION,
       $RESOURCE)
       AND sr.active_ind=1
       AND sr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     ORDER BY sr.service_resource_cd
     HEAD REPORT
      stat = alterlist(data->qual_p[x].qual_s,100), cnts = 0
     HEAD sr.service_resource_cd
      cnts = (cnts+ 1)
      IF (mod(cnts,10)=1
       AND cnts > 100)
       stat = alterlist(data->qual_p[x].qual_s,(cnts+ 9))
      ENDIF
      data->qual_p[x].qual_s[cnts].service_resource_cd = sr.service_resource_cd, data->qual_p[x].
      qual_s[cnts].service_resource_name = uar_get_code_description(sr.service_resource_cd)
     FOOT REPORT
      stat = alterlist(data->qual_p[x].qual_s,cnts)
     WITH nocounter
    ;end select
  ENDFOR
  SET count_d = cnvtint(value(size(data->qual_p,5)))
  FOR (y = 1 TO count_d BY 1)
   SET count_d1 = value(size(data->qual_p[y].qual_s,5))
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(count_d1)),
     prsnl_service_resource_reltn pr
    PLAN (d1)
     JOIN (pr
     WHERE (pr.prsnl_id=data->qual_p[y].prsnl_id)
      AND (pr.service_resource_cd=data->qual_p[y].qual_s[d1.seq].service_resource_cd)
      AND pr.updt_dt_tm < cnvtdatetime(curdate,curtime3))
    DETAIL
     data->qual_p[y].qual_s[d1.seq].data_exist = 1
    WITH nocounter
   ;end select
  ENDFOR
  CALL echorecord(data)
  SET count_e = cnvtint(value(size(data->qual_p,5)))
  FOR (z = 1 TO count_e BY 1)
   SET count_e1 = value(size(data->qual_p[z].qual_s,5))
   SELECT INTO "nl:"
    FROM (dummyt d2  WITH seq = value(count_e)),
     (dummyt d3  WITH seq = value(count_e1))
    PLAN (d2
     WHERE d2.seq <= size(data->qual_p,5))
     JOIN (d3
     WHERE d3.seq <= size(data->qual_p[d2.seq].qual_s,5))
    HEAD REPORT
     stat = alterlist(event->qual_pr,100), cntpr = 0
    HEAD d2.seq
     cntpr = (cntpr+ 1)
     IF (mod(cntpr,10)=1
      AND cntpr > 100)
      stat = alterlist(event->qual_pr,(cntpr+ 9))
     ENDIF
     event->qual_pr[cntpr].prsnl_id = data->qual_p[d2.seq].prsnl_id, stat = alterlist(event->qual_pr[
      cntpr].qual_sr,100), cntsr = 0
    DETAIL
     IF ((data->qual_p[d2.seq].qual_s[d3.seq].data_exist=1))
      cntsr = (cntsr+ 1)
      IF (mod(cntsr,10)=1
       AND cntsr > 100)
       stat = alterlist(event->qual_pr[cntpr].qual_sr,(cntsr+ 9))
      ENDIF
      event->qual_pr[cntpr].qual_sr[cntsr].service_resource_cd = data->qual_p[d2.seq].qual_s[d3.seq].
      service_resource_cd
     ENDIF
    FOOT  d2.seq
     stat = alterlist(event->qual_pr[cntpr].qual_sr,cntsr)
    FOOT REPORT
     stat = alterlist(event->qual_pr,cntpr)
    WITH nocounter
   ;end select
  ENDFOR
  CALL echorecord(event)
  SET count_r = value(size(event->qual_pr,5))
  FOR (j = 1 TO count_r BY 1)
   SET count_r1 = value(size(event->qual_pr[j].qual_sr,5))
   IF (count_r1 > 0)
    SELECT INTO "nl:"
     FROM (dummyt d4  WITH seq = value(count_r)),
      (dummyt d5  WITH seq = value(count_r1))
     PLAN (d4
      WHERE d4.seq <= size(event->qual_pr,5))
      JOIN (d5
      WHERE d5.seq <= size(event->qual_pr[d4.seq].qual_sr,5))
     HEAD REPORT
      stat = alterlist(request->qual,100), cntr = 0
     DETAIL
      IF ((event->qual_pr[d4.seq].qual_sr[d5.seq].service_resource_cd > 0))
       cntr = (cntr+ 1)
       IF (mod(cntr,10)=1
        AND cntr > 100)
        stat = alterlist(request->qual,(cntr+ 9))
       ENDIF
       request->qual[cntr].prsnl_id = event->qual_pr[d4.seq].prsnl_id, request->qual[cntr].
       service_resource_cd = event->qual_pr[d4.seq].qual_sr[d5.seq].service_resource_cd
      ENDIF
     FOOT REPORT
      stat = alterlist(request->qual,cntr)
     WITH nocounter
    ;end select
   ENDIF
  ENDFOR
  CALL echorecord(request)
  IF (( $ACTION=0))
   SET prsnl_display = value(size(data->qual_p,5))
   FOR (i = 1 TO prsnl_display BY 1)
    SET service_resource_display = value(size(data->qual_p[i].qual_s,5))
    SELECT INTO  $OUTDEV
     name = substring(1,200,data->qual_p[d7.seq].prsnl_name), service_resource = substring(1,200,data
      ->qual_p[d7.seq].qual_s[d8.seq].service_resource_name), action =
     IF ((data->qual_p[d7.seq].qual_s[d8.seq].data_exist=0)) "Do not Exist"
     ELSEIF ((data->qual_p[d7.seq].qual_s[d8.seq].data_exist=1)) "Will be Deleted"
     ENDIF
     FROM (dummyt d7  WITH seq = value(prsnl_display)),
      (dummyt d8  WITH seq = value(service_resource_display))
     PLAN (d7
      WHERE d7.seq <= size(data->qual_p,5))
      JOIN (d8
      WHERE d8.seq <= size(data->qual_p[d7.seq].qual_s,5))
     ORDER BY name
     WITH separator = " ", format, nocounter
    ;end select
   ENDFOR
  ENDIF
  IF (( $ACTION=1))
   SET service_resource_delete = value(size(request->qual,5))
   IF (service_resource_delete > 0)
    DELETE  FROM prsnl_service_resource_reltn psr,
      (dummyt d  WITH seq = value(service_resource_delete))
     SET psr.seq = 1
     PLAN (d)
      JOIN (psr
      WHERE (psr.prsnl_id=request->qual[d.seq].prsnl_id)
       AND (psr.service_resource_cd=request->qual[d.seq].service_resource_cd))
     WITH nocounter
    ;end delete
    COMMIT
   ENDIF
   SET prsnl_display = value(size(data->qual_p,5))
   FOR (i = 1 TO prsnl_display BY 1)
    SET service_resource_display = value(size(data->qual_p[i].qual_s,5))
    SELECT INTO  $OUTDEV
     name = substring(1,200,data->qual_p[d7.seq].prsnl_name), service_resource = substring(1,200,data
      ->qual_p[d7.seq].qual_s[d8.seq].service_resource_name), action =
     IF ((data->qual_p[d7.seq].qual_s[d8.seq].data_exist=0)) "Do not Exist"
     ELSEIF ((data->qual_p[d7.seq].qual_s[d8.seq].data_exist=1)) "Deleted"
     ENDIF
     FROM (dummyt d7  WITH seq = value(prsnl_display)),
      (dummyt d8  WITH seq = value(service_resource_display))
     PLAN (d7
      WHERE d7.seq <= size(data->qual_p,5))
      JOIN (d8
      WHERE d8.seq <= size(data->qual_p[d7.seq].qual_s,5))
     ORDER BY name
     WITH separator = " ", format, nocounter
    ;end select
   ENDFOR
  ENDIF
  FREE RECORD data
  FREE RECORD event
  FREE RECORD request
 ELSEIF (( $SCRIPT="C"))
  FREE RECORD request
  RECORD request(
    1 copyfrom_prsnl_id = f8
    1 prsnl[*]
      2 copyto_prsnl_id = f8
  )
  FREE RECORD temp_sr
  RECORD temp_sr(
    1 qual[*]
      2 service_recource_cd = f8
      2 service_resource_name = vc
  )
  FREE RECORD temp_pr
  RECORD temp_pr(
    1 qual[*]
      2 person_id = f8
      2 person_name = vc
  )
  SELECT INTO "nl:"
   FROM prsnl p
   WHERE (p.person_id= $COPY_FROM_USER)
    AND p.active_ind=1
    AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
   DETAIL
    request->copyfrom_prsnl_id = p.person_id
   WITH nocounter
  ;end select
  CALL echorecord(request)
  SELECT INTO "nl:"
   FROM prsnl p1
   WHERE p1.person_id IN ( $COPY_TO_USERS)
    AND p1.active_ind=1
    AND p1.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
   ORDER BY p1.person_id
   HEAD REPORT
    stat = alterlist(request->prsnl,100), cntp = 0
   HEAD p1.person_id
    cntp = (cntp+ 1)
    IF (mod(cntp,10)=1
     AND cntp > 100)
     stat = alterlist(request->prsnl,(cntp+ 9))
    ENDIF
    request->prsnl[cntp].copyto_prsnl_id = p1.person_id
   FOOT REPORT
    stat = alterlist(request->prsnl,cntp)
   WITH nocounter
  ;end select
  CALL echorecord(request)
  SELECT INTO "nl:"
   FROM prsnl_service_resource_reltn pr
   PLAN (pr
    WHERE (pr.prsnl_id= $COPY_FROM_USER))
   HEAD REPORT
    stat = alterlist(temp_sr->qual,100), cnts = 0
   HEAD pr.service_resource_cd
    cnts = (cnts+ 1)
    IF (mod(cnts,10)=1
     AND cnts > 100)
     stat = alterlist(temp_sr->qual,(cnts+ 9))
    ENDIF
    temp_sr->qual[cnts].service_recource_cd = pr.service_resource_cd, temp_sr->qual[cnts].
    service_resource_name = uar_get_code_description(pr.service_resource_cd)
   FOOT REPORT
    stat = alterlist(temp_sr->qual,cnts)
   WITH nocounter
  ;end select
  CALL echorecord(temp_sr)
  SELECT INTO "nl:"
   FROM prsnl p2
   WHERE p2.person_id IN ( $COPY_TO_USERS)
    AND p2.active_ind=1
    AND p2.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
   HEAD REPORT
    stat = alterlist(temp_pr->qual,100), cntpr = 0
   HEAD p2.person_id
    cntpr = (cntpr+ 1)
    IF (mod(cntpr,10)=1
     AND cntpr > 100)
     stat = alterlist(temp_pr->qual,(cntpr+ 9))
    ENDIF
    temp_pr->qual[cntpr].person_id = p2.person_id, temp_pr->qual[cntpr].person_name = substring(1,200,
     p2.name_full_formatted)
   FOOT REPORT
    stat = alterlist(temp_pr->qual,cntpr)
   WITH nocounter
  ;end select
  CALL echorecord(temp_pr)
  IF (( $ACTION=0))
   SELECT INTO  $OUTDEV
    name = substring(1,50,temp_pr->qual[d1.seq].person_name), service_resource = substring(1,50,
     temp_sr->qual[d2.seq].service_resource_name), action = "Will be Copied"
    FROM (dummyt d1  WITH seq = value(size(temp_pr->qual,5))),
     (dummyt d2  WITH seq = value(size(temp_sr->qual,5)))
    PLAN (d1
     WHERE d1.seq <= size(temp_pr->qual,5))
     JOIN (d2
     WHERE d2.seq <= size(temp_sr->qual,5))
    ORDER BY name, service_resource
    WITH separator = " ", format, nocounter
   ;end select
  ENDIF
  IF (( $ACTION=1))
   IF ((request->copyfrom_prsnl_id > 0))
    EXECUTE ppr_upd_servres_access_copy
   ENDIF
   SELECT INTO  $OUTDEV
    name = substring(1,50,temp_pr->qual[d1.seq].person_name), service_resource = substring(1,50,
     temp_sr->qual[d2.seq].service_resource_name), action = "Copied"
    FROM (dummyt d1  WITH seq = value(size(temp_pr->qual,5))),
     (dummyt d2  WITH seq = value(size(temp_sr->qual,5)))
    PLAN (d1
     WHERE d1.seq <= size(temp_pr->qual,5))
     JOIN (d2
     WHERE d2.seq <= size(temp_sr->qual,5))
    ORDER BY name, service_resource
    WITH separator = " ", format, nocounter
   ;end select
  ENDIF
  FREE RECORD request
  FREE RECORD temp_pr
  FREE RECORD temp_sr
 ENDIF
#exit_script
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
 SET script_ver = "002"
END GO
