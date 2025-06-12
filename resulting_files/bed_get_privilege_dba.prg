CREATE PROGRAM bed_get_privilege:dba
 FREE SET reply
 RECORD reply(
   1 plist[*]
     2 priv_loc_reltn_id = f8
     2 person_id = f8
     2 position_code_value = f8
     2 position_display = vc
     2 position_mean = vc
     2 ppr_code_value = f8
     2 ppr_display = vc
     2 ppr_mean = vc
     2 location_code_value = f8
     2 location_display = vc
     2 location_mean = vc
     2 priv_list[*]
       3 privilege_id = f8
       3 privilege_code_value = f8
       3 privilege_display = vc
       3 privilege_mean = vc
       3 priv_value_code_value = f8
       3 priv_value_display = vc
       3 priv_value_mean = vc
       3 elist[*]
         4 privilege_exception_id = f8
         4 priv_exception_id = f8
         4 priv_exception_name = vc
         4 exception_type_code_value = f8
         4 exception_type_display = vc
         4 exception_type_mean = vc
         4 exception_entity_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET tot_count = 0
 SET count = 0
 SET tot_privcount = 0
 SET privcount = 0
 SET tot_ecount = 0
 SET ecount = 0
 SET last_priv_loc_reltn_id = 0.0
 SET stat = alterlist(reply->plist,50)
 DECLARE pparse = vc
 DECLARE privilege_parse = vc
 DECLARE priv_value_parse = vc
 DECLARE exception_parse = vc
 DECLARE temp_string = vc
 SET pcount = size(request->plist,5)
 SET privilege_cnt = size(request->privilege_list,5)
 SET priv_value_cnt = size(request->priv_value_list,5)
 SET exception_cnt = size(request->exception_type_list,5)
 SET yes_code_value = 0.0
 SET yes_display = fillstring(40," ")
 SET yes_cdf = fillstring(12," ")
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=6017
   AND cv.cdf_meaning="YES"
   AND cv.active_ind=1
  DETAIL
   yes_code_value = cv.code_value, yes_display = cv.display, yes_cdf = cv.cdf_meaning
  WITH nocounter
 ;end select
 SET pparse = "plr.active_ind = 1 "
 IF (pcount > 0)
  FOR (x = 1 TO pcount)
    SET temp_string = fillstring(100," ")
    IF ((request->plist[x].person_id > 0))
     SET temp_string = build("plr.person_id = ",request->plist[x].person_id)
    ELSE
     SET temp_string = concat("plr.person_id >= 0")
    ENDIF
    IF ((request->plist[x].position_code_value > 0))
     SET temp_string = build(temp_string," and plr.position_cd = ",request->plist[x].
      position_code_value)
    ELSE
     SET temp_string = concat(temp_string," and plr.position_cd >= 0")
    ENDIF
    IF ((request->plist[x].ppr_code_value > 0))
     SET temp_string = build(temp_string," and plr.ppr_cd = ",request->plist[x].ppr_code_value)
    ELSE
     SET temp_string = concat(temp_string," and plr.ppr_cd >= 0")
    ENDIF
    IF ((request->plist[x].location_code_value > 0))
     SET temp_string = build(temp_string," and plr.location_cd = ",request->plist[x].
      location_code_value)
    ELSE
     SET temp_string = concat(temp_string," and plr.location_cd >= 0")
    ENDIF
    IF (validate(request->plist[x].privilege_id))
     IF ((request->plist[x].privilege_id > 0))
      SET temp_string = build(temp_string," and plr.privilege_id = ",request->plist[x].privilege_id)
     ENDIF
    ENDIF
    IF (x=1)
     SET pparse = concat(pparse," and ((",temp_string,")")
    ELSE
     SET pparse = concat(pparse," or (",temp_string,")")
    ENDIF
  ENDFOR
  SET pparse = concat(pparse,")")
 ENDIF
 FOR (y = 1 TO privilege_cnt)
   SET privilege_parse = fillstring(100," ")
   SET privilege_code_value = request->privilege_list[y].code_value
   SET privilege_parse = build("priv.active_ind = 1 and ",
    " priv.priv_loc_reltn_id = plr.priv_loc_reltn_id and "," priv.privilege_cd = ",request->
    privilege_list[y].code_value)
   IF (priv_value_cnt > 0)
    FOR (x = 1 TO priv_value_cnt)
      SET temp_string = fillstring(100," ")
      IF ((request->priv_value_list[x].code_value > 0))
       SET temp_string = build("priv.priv_value_cd = ",request->priv_value_list[x].code_value)
      ELSE
       SET temp_string = concat("priv.priv_value_cd >= 0")
      ENDIF
      IF (x=1)
       SET priv_value_parse = concat(priv_value_parse," and (",temp_string)
      ELSE
       SET priv_value_parse = concat(priv_value_parse," or ",temp_string)
      ENDIF
    ENDFOR
    SET priv_value_parse = concat(priv_value_parse,")")
    SET privilege_parse = concat(privilege_parse,priv_value_parse)
   ENDIF
   SET exception_parse = concat(
    "pe.active_ind = outerjoin(1) and pe.privilege_id = outerjoin(priv.privilege_id) ")
   IF (exception_cnt > 0)
    FOR (x = 1 TO exception_cnt)
      SET temp_string = fillstring(100," ")
      IF ((request->exception_type_list[x].code_value > 0))
       SET temp_string = build("pe.exception_type_cd = outerjoin(",request->exception_type_list[x].
        code_value,")")
      ELSE
       SET temp_string = concat("pe.exception_type_cd >= outerjoin(0)")
      ENDIF
      IF (x=1)
       SET exception_parse = concat(exception_parse," and ((",temp_string,")")
      ELSE
       SET exception_parse = concat(exception_parse," or (",temp_string,")")
      ENDIF
    ENDFOR
    SET exception_parse = concat(exception_parse,")")
   ENDIF
   SET priv_display = fillstring(40," ")
   SET priv_cdf = fillstring(12," ")
   SELECT INTO "NL:"
    FROM code_value cv
    WHERE cv.active_ind=1
     AND cv.code_set=6016
     AND cv.code_value=privilege_code_value
    DETAIL
     priv_display = cv.display, priv_cdf = cv.cdf_meaning
    WITH nocounter
   ;end select
   CALL echo(build("pparse = ",pparse))
   SELECT INTO "NL:"
    FROM priv_loc_reltn plr,
     code_value cv1,
     code_value cv2,
     code_value cv3,
     privilege priv,
     privilege_exception pe,
     code_value cv6016,
     code_value cv6017,
     code_value cv12033,
     code_value cv,
     nomenclature n,
     dummyt d,
     dummyt d1,
     dummyt d2,
     dummyt d3,
     dummyt d4,
     dummyt d5,
     dummyt d6
    PLAN (plr
     WHERE parser(pparse))
     JOIN (cv1
     WHERE cv1.code_value=plr.position_cd)
     JOIN (cv2
     WHERE cv2.code_value=plr.ppr_cd)
     JOIN (cv3
     WHERE cv3.code_value=plr.location_cd)
     JOIN (d)
     JOIN (priv
     WHERE parser(privilege_parse))
     JOIN (d3)
     JOIN (cv6016
     WHERE cv6016.code_set=6016
      AND cv6016.active_ind=1
      AND cv6016.code_value=priv.privilege_cd)
     JOIN (d4)
     JOIN (cv6017
     WHERE cv6017.code_set=6017
      AND cv6017.active_ind=1
      AND cv6017.code_value=priv.priv_value_cd)
     JOIN (d2)
     JOIN (pe
     WHERE parser(exception_parse))
     JOIN (d1)
     JOIN (cv
     WHERE cv.active_ind=1
      AND cv.code_value=pe.exception_type_cd)
     JOIN (d5)
     JOIN (n
     WHERE n.nomenclature_id=pe.exception_id)
     JOIN (d6)
     JOIN (cv12033
     WHERE cv12033.code_set=12033
      AND cv12033.active_ind=1
      AND cv12033.code_value=pe.exception_id)
    ORDER BY plr.person_id, plr.position_cd, plr.ppr_cd,
     plr.location_cd, priv.privilege_cd, priv.priv_value_cd,
     n.source_string, cv12033.display
    HEAD plr.priv_loc_reltn_id
     CALL echo("inside header"), tot_count = (tot_count+ 1), count = (count+ 1)
     IF (count > 50)
      stat = alterlist(reply->plist,(tot_count+ 50)), count = 0
     ENDIF
     reply->plist[tot_count].priv_loc_reltn_id = plr.priv_loc_reltn_id, reply->plist[tot_count].
     person_id = plr.person_id, reply->plist[tot_count].position_code_value = plr.position_cd,
     reply->plist[tot_count].position_display = cv1.display, reply->plist[tot_count].position_mean =
     cv1.cdf_meaning, reply->plist[tot_count].ppr_code_value = plr.ppr_cd,
     reply->plist[tot_count].ppr_display = cv2.display, reply->plist[tot_count].ppr_mean = cv2
     .cdf_meaning, reply->plist[tot_count].location_code_value = plr.location_cd,
     reply->plist[tot_count].location_display = cv3.display, reply->plist[tot_count].location_mean =
     cv3.cdf_meaning, tot_privcount = 0,
     privcount = 0, tot_ecount = 0, ecount = 0
    HEAD priv.privilege_id
     IF (tot_privcount=0)
      stat = alterlist(reply->plist[tot_count].priv_list,20)
     ENDIF
     tot_privcount = (tot_privcount+ 1), privcount = (privcount+ 1)
     IF (privcount > 20)
      stat = alterlist(reply->plist[tot_count].priv_list,(tot_privcount+ 20)), privcount = 0
     ENDIF
     reply->plist[tot_count].priv_list[tot_privcount].privilege_id = priv.privilege_id
     IF (priv.privilege_cd <= 0.0)
      reply->plist[tot_count].priv_list[tot_privcount].privilege_code_value = privilege_code_value,
      reply->plist[tot_count].priv_list[tot_privcount].privilege_display = priv_display, reply->
      plist[tot_count].priv_list[tot_privcount].privilege_mean = priv_cdf,
      reply->plist[tot_count].priv_list[tot_privcount].priv_value_code_value = yes_code_value, reply
      ->plist[tot_count].priv_list[tot_privcount].priv_value_display = yes_display, reply->plist[
      tot_count].priv_list[tot_privcount].priv_value_mean = yes_cdf
     ELSE
      reply->plist[tot_count].priv_list[tot_privcount].privilege_code_value = priv.privilege_cd,
      reply->plist[tot_count].priv_list[tot_privcount].privilege_display = cv6016.display, reply->
      plist[tot_count].priv_list[tot_privcount].privilege_mean = cv6016.cdf_meaning,
      reply->plist[tot_count].priv_list[tot_privcount].priv_value_code_value = priv.priv_value_cd,
      reply->plist[tot_count].priv_list[tot_privcount].priv_value_display = cv6017.display, reply->
      plist[tot_count].priv_list[tot_privcount].priv_value_mean = cv6017.cdf_meaning
     ENDIF
     tot_ecount = 0, ecount = 0
    DETAIL
     IF (pe.privilege_exception_id > 0)
      IF (tot_ecount=0)
       stat = alterlist(reply->plist[tot_count].priv_list[tot_privcount].elist,20)
      ENDIF
      tot_ecount = (tot_ecount+ 1), ecount = (ecount+ 1)
      IF (ecount > 20)
       stat = alterlist(reply->plist[tot_count].priv_list[tot_privcount].elist,(tot_ecount+ 20)),
       ecount = 0
      ENDIF
      reply->plist[tot_count].priv_list[tot_privcount].elist[tot_ecount].privilege_exception_id = pe
      .privilege_exception_id, reply->plist[tot_count].priv_list[tot_privcount].elist[tot_ecount].
      priv_exception_id = pe.exception_id, reply->plist[tot_count].priv_list[tot_privcount].elist[
      tot_ecount].priv_exception_name = " ",
      reply->plist[tot_count].priv_list[tot_privcount].elist[tot_ecount].exception_entity_name = pe
      .exception_entity_name
      CASE (pe.exception_entity_name)
       OF "NOMENCLATURE":
        reply->plist[tot_count].priv_list[tot_privcount].elist[tot_ecount].priv_exception_name = n
        .source_string
       OF "CLASSIFICATION":
        reply->plist[tot_count].priv_list[tot_privcount].elist[tot_ecount].priv_exception_name =
        cv12033.display
      ENDCASE
      reply->plist[tot_count].priv_list[tot_privcount].elist[tot_ecount].exception_type_code_value =
      pe.exception_type_cd, reply->plist[tot_count].priv_list[tot_privcount].elist[tot_ecount].
      exception_type_mean = cv.cdf_meaning, reply->plist[tot_count].priv_list[tot_privcount].elist[
      tot_ecount].exception_type_display = cv.display
     ENDIF
    FOOT  priv.privilege_id
     stat = alterlist(reply->plist[tot_count].priv_list[tot_privcount].elist,tot_ecount)
    FOOT  plr.priv_loc_reltn_id
     stat = alterlist(reply->plist[tot_count].priv_list,tot_privcount)
    WITH outerjoin = d, outerjoin = d2, outerjoin = d3,
     outerjoin = d4, outerjoin = d5, outerjoin = d6,
     outerjoin = d1, dontcare = cv6016, dontcare = cv6017,
     dontcare = pe, dontcare = cv, dontcare = n,
     dontcare = cv12033, nocounter
   ;end select
 ENDFOR
 SET stat = alterlist(reply->plist,tot_count)
 IF (tot_count > 0)
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
