CREATE PROGRAM cpmcachemanager_loadcodesets:dba
 RECORD requestinput(
   1 codesetlist[*]
     2 codeset = i4
     2 lastupdt_dt_tm = dq8
 )
 RECORD reply(
   1 codesetlist[*]
     2 codeset = i4
     2 cache_ind = i2
     2 lastupdt_dt_tm = dq8
     2 codevaluelist[*]
       3 value_cd = f8
       3 code_set = i4
       3 collation_seq = i4
       3 code_disp = vc
       3 code_descr = vc
       3 meaning = vc
       3 display_key = vc
       3 cki = vc
       3 concept_cki = vc
       3 definition = vc
   1 listarray[*]
     2 codevaluelist[*]
       3 value_cd = f8
       3 code_set = i4
       3 collation_seq = i4
       3 code_disp = vc
       3 code_descr = vc
       3 meaning = vc
       3 display_key = vc
       3 cki = vc
       3 concept_cki = vc
       3 definition = vc
       3 active_ind = i2
       3 begin_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
       3 updt_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE max_list_size = i4 WITH constant(65535)
 SET actind = 0
 SET reply->status_data.status = "F"
 DECLARE count = i4
 SET count = 0
 DECLARE count1 = i4
 SET count1 = 0
 DECLARE count2 = i4
 SET count2 = 0
 DECLARE listsize = i4
 SET listsize = value(size(request->codesetlist,5))
 DECLARE i = i4
 SET i = 0
 IF ((request->loadmode=1))
  CALL echo("Loading all code        sets")
  SET count1 = 0
  SET stat = alterlist(reply->codesetlist,0)
  SELECT INTO "nl:"
   FROM code_value c,
    code_value_set cs
   PLAN (cs)
    JOIN (c
    WHERE c.code_set=cs.code_set
     AND c.active_ind=1
     AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   DETAIL
    IF ((reply->codesetlist[count1].codeset != c.code_set))
     count1 = (count1+ 1), stat = alterlist(reply->codesetlist,count1), reply->codesetlist[count1].
     codeset = c.code_set,
     count2 = 0
    ENDIF
    count = (count+ 1), count2 = (count2+ 1), reply->codesetlist[count1].codeset = c.code_set,
    stat = alterlist(reply->codesetlist[count1].codevaluelist,count2), reply->codesetlist[count1].
    codevaluelist[count2].value_cd = c.code_value, reply->codesetlist[count1].codevaluelist[count2].
    code_set = c.code_set,
    reply->codesetlist[count1].codevaluelist[count2].collation_seq = c.collation_seq, reply->
    codesetlist[count1].codevaluelist[count2].code_disp = c.display, reply->codesetlist[count1].
    codevaluelist[count2].code_descr = c.description,
    reply->codesetlist[count1].codevaluelist[count2].meaning = c.cdf_meaning, reply->codesetlist[
    count1].codevaluelist[count2].display_key = c.display_key, reply->codesetlist[count1].
    codevaluelist[count2].cki = c.cki,
    reply->codesetlist[count1].codevaluelist[count2].concept_cki = c.concept_cki, reply->codesetlist[
    count1].codevaluelist[count2].definition = c.definition
   WITH nocounter
  ;end select
 ELSEIF ((request->loadmode=2))
  SET count1 = 0
  SET count = 0
  SELECT INTO "nl:"
   info.info_name, info.updt_dt_tm
   FROM dm_info info
   WHERE info.info_domain="CODE SET UPDATE"
    AND info.updt_dt_tm >= cnvtdatetimeutc(request->lastupdt_dt_tm,2)
   DETAIL
    count = (count+ 1), stat = alterlist(requestinput->codesetlist,count), requestinput->codesetlist[
    count].codeset = cnvtint(trim(info.info_name)),
    requestinput->codesetlist[count].lastupdt_dt_tm = info.updt_dt_tm
   WITH nocounter
  ;end select
  SET listsize = count
  SET count = 0
  SET stat = alterlist(reply->codesetlist,0)
  FOR (i = 1 TO listsize)
    SET count2 = 0
    SELECT INTO "nl:"
     FROM code_value c,
      code_value_set cs
     PLAN (cs
      WHERE (cs.code_set=requestinput->codesetlist[i].codeset)
       AND cs.code_set > 0)
      JOIN (c
      WHERE cs.code_set=c.code_set
       AND c.active_ind=1
       AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
     DETAIL
      IF ((reply->codesetlist[count1].codeset != c.code_set))
       count1 = (count1+ 1), stat = alterlist(reply->codesetlist,count1), reply->codesetlist[count1].
       codeset = c.code_set,
       reply->codesetlist[count1].cache_ind = cs.cache_ind, reply->codesetlist[count1].lastupdt_dt_tm
        = requestinput->codesetlist[i].lastupdt_dt_tm, count2 = 0
      ENDIF
      count = (count+ 1), count2 = (count2+ 1), reply->codesetlist[count1].codeset = c.code_set,
      stat = alterlist(reply->codesetlist[count1].codevaluelist,count2), reply->codesetlist[count1].
      codevaluelist[count2].value_cd = c.code_value, reply->codesetlist[count1].codevaluelist[count2]
      .code_set = c.code_set,
      reply->codesetlist[count1].codevaluelist[count2].collation_seq = c.collation_seq, reply->
      codesetlist[count1].codevaluelist[count2].code_disp = c.display, reply->codesetlist[count1].
      codevaluelist[count2].code_descr = c.description,
      reply->codesetlist[count1].codevaluelist[count2].meaning = c.cdf_meaning, reply->codesetlist[
      count1].codevaluelist[count2].display_key = c.display_key, reply->codesetlist[count1].
      codevaluelist[count2].cki = c.cki,
      reply->codesetlist[count1].codevaluelist[count2].concept_cki = c.concept_cki, reply->
      codesetlist[count1].codevaluelist[count2].definition = c.definition
     WITH nocounter
    ;end select
    IF (count2=0)
     CALL echo(build("codeset: ",requestinput->codesetlist[i].codeset," no code value found!!!!!!"))
    ENDIF
  ENDFOR
 ELSEIF ((((request->loadmode=3)) OR ((request->loadmode=4))) )
  SET count = 0
  SET count1 = 0
  SET stat = alterlist(reply->codesetlist,0)
  FOR (i = 1 TO listsize)
    SET count2 = 0
    SELECT INTO "nl:"
     FROM code_value c,
      code_value_set cs
     PLAN (cs
      WHERE (cs.code_set=request->codesetlist[i].codeset)
       AND cs.code_set > 0)
      JOIN (c
      WHERE cs.code_set=c.code_set
       AND c.active_ind=1
       AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
     ORDER BY c.collation_seq, c.display_key, c.code_value
     DETAIL
      IF ((reply->codesetlist[count1].codeset != c.code_set))
       count1 = (count1+ 1), stat = alterlist(reply->codesetlist,count1), reply->codesetlist[count1].
       codeset = c.code_set,
       reply->codesetlist[count1].cache_ind = cs.cache_ind
      ENDIF
      count = (count+ 1), count2 = (count2+ 1)
      IF (count2 <= max_list_size)
       reply->codesetlist[count1].codeset = c.code_set, reply->codesetlist[count1].cache_ind = cs
       .cache_ind, stat = alterlist(reply->codesetlist[count1].codevaluelist,count2),
       reply->codesetlist[count1].codevaluelist[count2].value_cd = c.code_value, reply->codesetlist[
       count1].codevaluelist[count2].code_set = c.code_set, reply->codesetlist[count1].codevaluelist[
       count2].collation_seq = c.collation_seq,
       reply->codesetlist[count1].codevaluelist[count2].code_disp = c.display, reply->codesetlist[
       count1].codevaluelist[count2].code_descr = c.description, reply->codesetlist[count1].
       codevaluelist[count2].meaning = c.cdf_meaning,
       reply->codesetlist[count1].codevaluelist[count2].display_key = c.display_key, reply->
       codesetlist[count1].codevaluelist[count2].cki = c.cki, reply->codesetlist[count1].
       codevaluelist[count2].concept_cki = c.concept_cki,
       reply->codesetlist[count1].codevaluelist[count2].definition = c.definition
      ENDIF
     WITH nocounter
    ;end select
    IF (count2=0)
     CALL echo(build("codeset: ",request->codesetlist[i].codeset," no code value found!!!!!!"))
    ENDIF
    IF (count2 > max_list_size)
     CALL echo(build("codeset: ",request->codesetlist[i].codeset," exceeds 65535 values!!!!!!"))
     SET stat = alterlist(reply->codesetlist,0)
     SET count1 = 0
     SET reply->status_data.status = "X"
     GO TO exit_script
    ENDIF
  ENDFOR
 ELSEIF ((request->loadmode=5))
  DECLARE listarraycnt = i4 WITH noconstant(0)
  SELECT INTO "nl:"
   FROM code_value cv
   PLAN (cv
    WHERE cv.updt_dt_tm >= cnvtdatetime(request->lastupdt_dt_tm)
     AND cv.active_ind=1
     AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   HEAD REPORT
    count = 0, listarraycnt = 1, stat = alterlist(reply->listarray,listarraycnt),
    stat = alterlist(reply->listarray[listarraycnt].codevaluelist,10)
   DETAIL
    count = (count+ 1)
    IF (mod(count,10)=1
     AND count != 1
     AND count <= max_list_size)
     stat = alterlist(reply->listarray[listarraycnt].codevaluelist,(count+ 9))
    ELSEIF (count > max_list_size)
     stat = alterlist(reply->listarray[listarraycnt].codevaluelist,max_list_size), count = 1,
     listarraycnt = (listarraycnt+ 1),
     stat = alterlist(reply->listarray[listarraycnt],listarraycnt), stat = alterlist(reply->
      listarray[listarraycnt].codevaluelist,10)
    ENDIF
    reply->listarray[listarraycnt].codevaluelist[count].cki = cv.cki, reply->listarray[listarraycnt].
    codevaluelist[count].code_descr = cv.description, reply->listarray[listarraycnt].codevaluelist[
    count].code_disp = cv.display,
    reply->listarray[listarraycnt].codevaluelist[count].code_set = cv.code_set, reply->listarray[
    listarraycnt].codevaluelist[count].collation_seq = cv.collation_seq, reply->listarray[
    listarraycnt].codevaluelist[count].display_key = cv.display_key,
    reply->listarray[listarraycnt].codevaluelist[count].meaning = cv.cdf_meaning, reply->listarray[
    listarraycnt].codevaluelist[count].value_cd = cv.code_value, reply->listarray[listarraycnt].
    codevaluelist[count].concept_cki = cv.concept_cki,
    reply->listarray[listarraycnt].codevaluelist[count].definition = cv.definition
   FOOT REPORT
    stat = alterlist(reply->listarray[listarraycnt].codevaluelist,count)
   WITH nocounter
  ;end select
 ELSEIF ((request->loadmode=6))
  DECLARE listarraycnt = i4 WITH noconstant(0)
  SELECT INTO "nl:"
   FROM code_value cv
   PLAN (cv
    WHERE cv.updt_dt_tm >= cnvtdatetime(request->lastupdt_dt_tm))
   HEAD REPORT
    count = 0, listarraycnt = 1, stat = alterlist(reply->listarray,listarraycnt),
    stat = alterlist(reply->listarray[listarraycnt].codevaluelist,10)
   DETAIL
    count = (count+ 1)
    IF (mod(count,10)=1
     AND count != 1
     AND count <= max_list_size)
     stat = alterlist(reply->listarray[listarraycnt].codevaluelist,(count+ 9))
    ELSEIF (count > max_list_size)
     stat = alterlist(reply->listarray[listarraycnt].codevaluelist,max_list_size), count = 1,
     listarraycnt = (listarraycnt+ 1),
     stat = alterlist(reply->listarray[listarraycnt],listarraycnt), stat = alterlist(reply->
      listarray[listarraycnt].codevaluelist,10)
    ENDIF
    reply->listarray[listarraycnt].codevaluelist[count].value_cd = cv.code_value, reply->listarray[
    listarraycnt].codevaluelist[count].code_set = cv.code_set, reply->listarray[listarraycnt].
    codevaluelist[count].collation_seq = cv.collation_seq,
    reply->listarray[listarraycnt].codevaluelist[count].code_disp = cv.display, reply->listarray[
    listarraycnt].codevaluelist[count].code_descr = cv.description, reply->listarray[listarraycnt].
    codevaluelist[count].meaning = cv.cdf_meaning,
    reply->listarray[listarraycnt].codevaluelist[count].display_key = cv.display_key, reply->
    listarray[listarraycnt].codevaluelist[count].cki = cv.cki, reply->listarray[listarraycnt].
    codevaluelist[count].concept_cki = cv.concept_cki,
    reply->listarray[listarraycnt].codevaluelist[count].definition = cv.definition, reply->listarray[
    listarraycnt].codevaluelist[count].active_ind = cv.active_ind, reply->listarray[listarraycnt].
    codevaluelist[count].begin_effective_dt_tm = cv.begin_effective_dt_tm,
    reply->listarray[listarraycnt].codevaluelist[count].end_effective_dt_tm = cv.end_effective_dt_tm
   FOOT REPORT
    stat = alterlist(reply->listarray[listarraycnt].codevaluelist,count)
   WITH nocounter
  ;end select
 ELSEIF ((request->loadmode=7))
  DECLARE listarraycnt = i4 WITH noconstant(0)
  DECLARE rfrshcnt = i4 WITH noconstant(0)
  DECLARE rfrshsize = i4 WITH noconstant(size(request->codesetlist,5))
  DECLARE matchind = i2 WITH noconstant(0)
  SELECT INTO "nl:"
   FROM code_value cv
   WHERE cv.updt_dt_tm >= cnvtdatetime(request->lastupdt_dt_tm)
   HEAD REPORT
    count = 0, listarraycnt = 1, stat = alterlist(reply->listarray,listarraycnt),
    stat = alterlist(reply->listarray[listarraycnt].codevaluelist,10)
   DETAIL
    IF (rfrshsize > 0)
     matchind = 0
     FOR (rfrshcnt = 1 TO rfrshsize)
       IF ((request->codesetlist[rfrshcnt].codeset=cv.code_set))
        matchind = 1
        IF (cv.updt_dt_tm > cnvtdatetime(request->codesetlist[rfrshcnt].lastupdt_dt_tm))
         count = (count+ 1)
         IF (mod(count,10)=1
          AND count != 1
          AND count <= max_list_size)
          stat = alterlist(reply->listarray[listarraycnt].codevaluelist,(count+ 9))
         ELSEIF (count > max_list_size)
          stat = alterlist(reply->listarray[listarraycnt].codevaluelist,max_list_size), count = 1,
          listarraycnt = (listarraycnt+ 1),
          stat = alterlist(reply->listarray[listarraycnt],listarraycnt), stat = alterlist(reply->
           listarray[listarraycnt].codevaluelist,10)
         ENDIF
         reply->listarray[listarraycnt].codevaluelist[count].value_cd = cv.code_value, reply->
         listarray[listarraycnt].codevaluelist[count].code_set = cv.code_set, reply->listarray[
         listarraycnt].codevaluelist[count].collation_seq = cv.collation_seq,
         reply->listarray[listarraycnt].codevaluelist[count].code_disp = cv.display, reply->
         listarray[listarraycnt].codevaluelist[count].code_descr = cv.description, reply->listarray[
         listarraycnt].codevaluelist[count].meaning = cv.cdf_meaning,
         reply->listarray[listarraycnt].codevaluelist[count].display_key = cv.display_key, reply->
         listarray[listarraycnt].codevaluelist[count].cki = cv.cki, reply->listarray[listarraycnt].
         codevaluelist[count].concept_cki = cv.concept_cki,
         reply->listarray[listarraycnt].codevaluelist[count].definition = cv.definition, reply->
         listarray[listarraycnt].codevaluelist[count].active_ind = cv.active_ind, reply->listarray[
         listarraycnt].codevaluelist[count].begin_effective_dt_tm = cv.begin_effective_dt_tm,
         reply->listarray[listarraycnt].codevaluelist[count].end_effective_dt_tm = cv
         .end_effective_dt_tm
        ENDIF
       ENDIF
     ENDFOR
     IF (matchind=0)
      count = (count+ 1)
      IF (mod(count,10)=1
       AND count != 1
       AND count <= max_list_size)
       stat = alterlist(reply->listarray[listarraycnt].codevaluelist,(count+ 9))
      ELSEIF (count > max_list_size)
       stat = alterlist(reply->listarray[listarraycnt].codevaluelist,max_list_size), count = 1,
       listarraycnt = (listarraycnt+ 1),
       stat = alterlist(reply->listarray[listarraycnt],listarraycnt), stat = alterlist(reply->
        listarray[listarraycnt].codevaluelist,10)
      ENDIF
      reply->listarray[listarraycnt].codevaluelist[count].value_cd = cv.code_value, reply->listarray[
      listarraycnt].codevaluelist[count].code_set = cv.code_set, reply->listarray[listarraycnt].
      codevaluelist[count].collation_seq = cv.collation_seq,
      reply->listarray[listarraycnt].codevaluelist[count].code_disp = cv.display, reply->listarray[
      listarraycnt].codevaluelist[count].code_descr = cv.description, reply->listarray[listarraycnt].
      codevaluelist[count].meaning = cv.cdf_meaning,
      reply->listarray[listarraycnt].codevaluelist[count].display_key = cv.display_key, reply->
      listarray[listarraycnt].codevaluelist[count].cki = cv.cki, reply->listarray[listarraycnt].
      codevaluelist[count].concept_cki = cv.concept_cki,
      reply->listarray[listarraycnt].codevaluelist[count].definition = cv.definition, reply->
      listarray[listarraycnt].codevaluelist[count].active_ind = cv.active_ind, reply->listarray[
      listarraycnt].codevaluelist[count].begin_effective_dt_tm = cv.begin_effective_dt_tm,
      reply->listarray[listarraycnt].codevaluelist[count].end_effective_dt_tm = cv
      .end_effective_dt_tm
     ENDIF
    ELSE
     count = (count+ 1)
     IF (mod(count,10)=1
      AND count != 1
      AND count <= max_list_size)
      stat = alterlist(reply->listarray[listarraycnt].codevaluelist,(count+ 9))
     ELSEIF (count > max_list_size)
      stat = alterlist(reply->listarray[listarraycnt].codevaluelist,max_list_size), count = 1,
      listarraycnt = (listarraycnt+ 1),
      stat = alterlist(reply->listarray[listarraycnt],listarraycnt), stat = alterlist(reply->
       listarray[listarraycnt].codevaluelist,10)
     ENDIF
     reply->listarray[listarraycnt].codevaluelist[count].value_cd = cv.code_value, reply->listarray[
     listarraycnt].codevaluelist[count].code_set = cv.code_set, reply->listarray[listarraycnt].
     codevaluelist[count].collation_seq = cv.collation_seq,
     reply->listarray[listarraycnt].codevaluelist[count].code_disp = cv.display, reply->listarray[
     listarraycnt].codevaluelist[count].code_descr = cv.description, reply->listarray[listarraycnt].
     codevaluelist[count].meaning = cv.cdf_meaning,
     reply->listarray[listarraycnt].codevaluelist[count].display_key = cv.display_key, reply->
     listarray[listarraycnt].codevaluelist[count].cki = cv.cki, reply->listarray[listarraycnt].
     codevaluelist[count].concept_cki = cv.concept_cki,
     reply->listarray[listarraycnt].codevaluelist[count].definition = cv.definition, reply->
     listarray[listarraycnt].codevaluelist[count].active_ind = cv.active_ind, reply->listarray[
     listarraycnt].codevaluelist[count].begin_effective_dt_tm = cv.begin_effective_dt_tm,
     reply->listarray[listarraycnt].codevaluelist[count].end_effective_dt_tm = cv.end_effective_dt_tm
    ENDIF
   FOOT REPORT
    stat = alterlist(reply->listarray[listarraycnt].codevaluelist,count)
   WITH nocounter
  ;end select
 ELSEIF ((request->loadmode=8))
  DECLARE node_id = f8 WITH noconstant(0.0)
  DECLARE count = i4 WITH noconstant(0)
  DECLARE listarraycnt = i4 WITH noconstant(0)
  SELECT INTO "nl:"
   FROM code_value_node cvn
   WHERE trim(cnvtlower(request->node_name),3)=trim(cnvtlower(cvn.node_name),3)
   DETAIL
    node_id = cvn.code_value_node_id
   WITH nocounter
  ;end select
  IF (node_id=0)
   GO TO exit_script
  ENDIF
  RECORD changes(
    1 code_values[*]
      2 code_value = f8
      2 updt_dt_tm = dq8
  )
  DECLARE changed_cnt = i4 WITH noconstant(0)
  SELECT INTO "nl:"
   cvc.code_value, max_dt = max(cvc.updt_dt_tm)
   FROM code_value_changes cvc
   PLAN (cvc
    WHERE cvc.code_value_node_id=node_id)
   GROUP BY cvc.code_value
   HEAD REPORT
    stat = alterlist(changes->code_values,500)
   DETAIL
    changed_cnt = (changed_cnt+ 1)
    IF (mod(changed_cnt,500)=1
     AND changed_cnt != 1)
     stat = alterlist(changes->code_values,(changed_cnt+ 499))
    ENDIF
    changes->code_values[changed_cnt].code_value = cvc.code_value, changes->code_values[changed_cnt].
    updt_dt_tm = max_dt
   WITH nocounter
  ;end select
  SET stat = alterlist(changes->code_values,changed_cnt)
  CALL echorecord(changes)
  IF (changed_cnt=0)
   SET reply->status_data.status = "S"
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   changes->code_values[d.seq].code_value, cv.code_set, cv.collation_seq,
   cv.display, cv.description, cv.cdf_meaning,
   cv.display_key, cv.cki, cv.concept_cki,
   cv.definition, cv.active_ind, cv.begin_effective_dt_tm,
   cv.end_effective_dt_tm, changes->code_values[d.seq].updt_dt_tm
   FROM code_value cv,
    (dummyt d  WITH seq = value(size(changes->code_values,5)))
   PLAN (d)
    JOIN (cv
    WHERE (cv.code_value=changes->code_values[d.seq].code_value))
   HEAD REPORT
    count = 0, listarraycnt = 1, stat = alterlist(reply->listarray,listarraycnt),
    stat = alterlist(reply->listarray[listarraycnt].codevaluelist,500)
   DETAIL
    count = (count+ 1)
    IF (mod(count,500)=1
     AND count != 1
     AND count <= max_list_size)
     stat = alterlist(reply->listarray[listarraycnt].codevaluelist,(count+ 499))
    ELSEIF (count > max_list_size)
     stat = alterlist(reply->listarray[listarraycnt].codevaluelist,max_list_size), count = 1,
     listarraycnt = (listarraycnt+ 1),
     stat = alterlist(reply->listarray[listarraycnt],listarraycnt), stat = alterlist(reply->
      listarray[listarraycnt].codevaluelist,500)
    ENDIF
    reply->listarray[listarraycnt].codevaluelist[count].value_cd = changes->code_values[d.seq].
    code_value, reply->listarray[listarraycnt].codevaluelist[count].code_set = cv.code_set, reply->
    listarray[listarraycnt].codevaluelist[count].collation_seq = cv.collation_seq,
    reply->listarray[listarraycnt].codevaluelist[count].code_disp = cv.display, reply->listarray[
    listarraycnt].codevaluelist[count].code_descr = cv.description, reply->listarray[listarraycnt].
    codevaluelist[count].meaning = cv.cdf_meaning,
    reply->listarray[listarraycnt].codevaluelist[count].display_key = cv.display_key, reply->
    listarray[listarraycnt].codevaluelist[count].cki = cv.cki, reply->listarray[listarraycnt].
    codevaluelist[count].concept_cki = cv.concept_cki,
    reply->listarray[listarraycnt].codevaluelist[count].definition = cv.definition, reply->listarray[
    listarraycnt].codevaluelist[count].active_ind = cv.active_ind, reply->listarray[listarraycnt].
    codevaluelist[count].begin_effective_dt_tm = cv.begin_effective_dt_tm,
    reply->listarray[listarraycnt].codevaluelist[count].end_effective_dt_tm = cv.end_effective_dt_tm,
    reply->listarray[listarraycnt].codevaluelist[count].updt_dt_tm = changes->code_values[d.seq].
    updt_dt_tm
   FOOT REPORT
    stat = alterlist(reply->listarray[listarraycnt].codevaluelist,count)
   WITH nocounter, outerjoin = d
  ;end select
  CALL echo(build("count:",count))
 ELSE
  CALL echo("Invalid loadmode")
 ENDIF
 IF (count != 0)
  SET reply->status_data.status = "S"
  CALL echo(build("code loaded:        ",count))
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#exit_script
 CALL echo(build("codesetlist: ",count1))
END GO
