CREATE PROGRAM bed_get_proposed_srvres:dba
 FREE SET reply
 RECORD reply(
   01 sglist[*]
     02 br_proposed_srvres_id = f8
     02 display = vc
     02 slist[*]
       03 br_proposed_srvres_id = f8
       03 display = vc
       03 description = vc
       03 meaning = vc
       03 catalog_type_cd = f8
       03 catalog_type_mean = vc
       03 catalog_type_display = vc
       03 activity_type_cd = f8
       03 activity_type_mean = vc
       03 activity_type_display = vc
       03 proposed_ind = i2
       03 sslist[*]
         04 br_proposed_srvres_id = f8
         04 display = vc
         04 description = vc
         04 meaning = vc
         04 catalog_type_cd = f8
         04 catalog_type_mean = vc
         04 catalog_type_display = vc
         04 activity_type_cd = f8
         04 activity_type_mean = vc
         04 activity_type_display = vc
         04 activity_subtype_cd = f8
         04 activity_subtype_mean = vc
         04 activity_subtype_display = vc
         04 proposed_ind = i2
         04 automated_ind = i2
         04 blist[*]
           05 br_proposed_srvres_id = f8
           05 display = vc
           05 description = vc
           05 meaning = vc
           05 catalog_type_cd = f8
           05 catalog_type_mean = vc
           05 catalog_type_display = vc
           05 activity_type_cd = f8
           05 activity_type_mean = vc
           05 activity_type_display = vc
           05 activity_subtype_cd = f8
           05 activity_subtype_mean = vc
           05 activity_subtype_display = vc
           05 proposed_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "S"
 SET option_nbr = 0
 SET sgcnt = 0
 SET scnt = 0
 SET sscnt = 0
 SET bcnt = 0
 IF ((request->srvres_option_nbr > 0))
  SET option_nbr = request->srvres_option_nbr
 ELSE
  SET option_nbr = 1
 ENDIF
 IF ((request->load_service_resource=1))
  SELECT INTO "nl:"
   FROM br_proposed_srvres bps1,
    br_proposed_srvres bps2,
    br_proposed_srvres bps3,
    br_proposed_srvres bps4
   PLAN (bps1
    WHERE bps1.srvres_level=1
     AND bps1.srvres_option_nbr=option_nbr)
    JOIN (bps2
    WHERE bps2.parent_id=outerjoin(bps1.br_proposed_srvres_id)
     AND bps2.srvres_option_nbr=outerjoin(option_nbr)
     AND bps2.srvres_level=outerjoin(2))
    JOIN (bps3
    WHERE bps3.parent_id=outerjoin(bps2.br_proposed_srvres_id)
     AND bps3.srvres_option_nbr=outerjoin(option_nbr)
     AND bps3.srvres_level=outerjoin(3))
    JOIN (bps4
    WHERE bps4.parent_id=outerjoin(bps3.br_proposed_srvres_id)
     AND bps4.srvres_option_nbr=outerjoin(option_nbr)
     AND bps4.srvres_level=outerjoin(4))
   ORDER BY bps1.br_proposed_srvres_id, bps2.br_proposed_srvres_id, bps3.br_proposed_srvres_id,
    bps4.br_proposed_srvres_id
   HEAD REPORT
    sgcnt = 0, scnt = 0, sscnt = 0,
    bcnt = 0
   HEAD bps1.br_proposed_srvres_id
    sgcnt = (sgcnt+ 1), stat = alterlist(reply->sglist,sgcnt), reply->sglist[sgcnt].
    br_proposed_srvres_id = bps1.br_proposed_srvres_id,
    reply->sglist[sgcnt].display = bps1.display, scnt = 0
   HEAD bps2.br_proposed_srvres_id
    IF (bps2.br_proposed_srvres_id > 0)
     scnt = (scnt+ 1), stat = alterlist(reply->sglist[sgcnt].slist,scnt), reply->sglist[sgcnt].slist[
     scnt].br_proposed_srvres_id = bps2.br_proposed_srvres_id,
     reply->sglist[sgcnt].slist[scnt].display = bps2.display, reply->sglist[sgcnt].slist[scnt].
     description = bps2.description, reply->sglist[sgcnt].slist[scnt].meaning = bps2.meaning,
     reply->sglist[sgcnt].slist[scnt].activity_type_cd = bps2.activity_type_cd, reply->sglist[sgcnt].
     slist[scnt].catalog_type_cd = bps2.catalog_type_cd, reply->sglist[sgcnt].slist[scnt].
     proposed_ind = bps2.proposed_ind
    ENDIF
    sscnt = 0
   HEAD bps3.br_proposed_srvres_id
    IF (bps3.br_proposed_srvres_id > 0)
     sscnt = (sscnt+ 1), stat = alterlist(reply->sglist[sgcnt].slist[scnt].sslist,sscnt), reply->
     sglist[sgcnt].slist[scnt].sslist[sscnt].br_proposed_srvres_id = bps3.br_proposed_srvres_id,
     reply->sglist[sgcnt].slist[scnt].sslist[sscnt].display = bps3.display, reply->sglist[sgcnt].
     slist[scnt].sslist[sscnt].description = bps3.description, reply->sglist[sgcnt].slist[scnt].
     sslist[sscnt].meaning = bps3.meaning,
     reply->sglist[sgcnt].slist[scnt].sslist[sscnt].activity_type_cd = bps3.activity_type_cd, reply->
     sglist[sgcnt].slist[scnt].sslist[sscnt].activity_subtype_cd = bps3.activity_subtype_cd, reply->
     sglist[sgcnt].slist[scnt].sslist[sscnt].catalog_type_cd = bps3.catalog_type_cd,
     reply->sglist[sgcnt].slist[scnt].sslist[sscnt].proposed_ind = bps3.proposed_ind, reply->sglist[
     sgcnt].slist[scnt].sslist[sscnt].automated_ind = bps3.automated_ind
    ENDIF
    bcnt = 0
   DETAIL
    IF (bps4.br_proposed_srvres_id > 0)
     bcnt = (bcnt+ 1), stat = alterlist(reply->sglist[sgcnt].slist[scnt].sslist[sscnt].blist,bcnt),
     reply->sglist[sgcnt].slist[scnt].sslist[sscnt].blist[bcnt].br_proposed_srvres_id = bps4
     .br_proposed_srvres_id,
     reply->sglist[sgcnt].slist[scnt].sslist[sscnt].blist[bcnt].display = bps4.display, reply->
     sglist[sgcnt].slist[scnt].sslist[sscnt].blist[bcnt].description = bps4.description, reply->
     sglist[sgcnt].slist[scnt].sslist[sscnt].blist[bcnt].meaning = bps4.meaning,
     reply->sglist[sgcnt].slist[scnt].sslist[sscnt].blist[bcnt].activity_type_cd = bps4
     .activity_type_cd, reply->sglist[sgcnt].slist[scnt].sslist[sscnt].blist[bcnt].
     activity_subtype_cd = bps4.activity_subtype_cd, reply->sglist[sgcnt].slist[scnt].sslist[sscnt].
     blist[bcnt].catalog_type_cd = bps4.catalog_type_cd,
     reply->sglist[sgcnt].slist[scnt].sslist[sscnt].blist[bcnt].proposed_ind = bps4.proposed_ind
    ENDIF
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM br_proposed_srvres bps1,
    br_proposed_srvres bps2,
    br_proposed_srvres bps3
   PLAN (bps1
    WHERE bps1.srvres_level=1
     AND bps1.srvres_option_nbr=option_nbr)
    JOIN (bps2
    WHERE bps2.parent_id=outerjoin(bps1.br_proposed_srvres_id)
     AND bps2.srvres_option_nbr=outerjoin(option_nbr)
     AND bps2.srvres_level=outerjoin(2))
    JOIN (bps3
    WHERE bps3.parent_id=outerjoin(bps2.br_proposed_srvres_id)
     AND bps3.srvres_option_nbr=outerjoin(option_nbr)
     AND bps3.srvres_level=outerjoin(3))
   ORDER BY bps1.br_proposed_srvres_id, bps2.br_proposed_srvres_id, bps3.br_proposed_srvres_id
   HEAD REPORT
    sgcnt = 0, scnt = 0, sscnt = 0,
    bcnt = 0
   HEAD bps1.br_proposed_srvres_id
    sgcnt = (sgcnt+ 1), stat = alterlist(reply->sglist,sgcnt), reply->sglist[sgcnt].
    br_proposed_srvres_id = bps1.br_proposed_srvres_id,
    reply->sglist[sgcnt].display = bps1.display, scnt = 0
   HEAD bps2.br_proposed_srvres_id
    IF (bps2.br_proposed_srvres_id > 0)
     scnt = (scnt+ 1), stat = alterlist(reply->sglist[sgcnt].slist,scnt), reply->sglist[sgcnt].slist[
     scnt].br_proposed_srvres_id = bps2.br_proposed_srvres_id,
     reply->sglist[sgcnt].slist[scnt].display = bps2.display, reply->sglist[sgcnt].slist[scnt].
     description = bps2.description, reply->sglist[sgcnt].slist[scnt].meaning = bps2.meaning,
     reply->sglist[sgcnt].slist[scnt].activity_type_cd = bps2.activity_type_cd, reply->sglist[sgcnt].
     slist[scnt].catalog_type_cd = bps2.catalog_type_cd, reply->sglist[sgcnt].slist[scnt].
     proposed_ind = bps2.proposed_ind
    ENDIF
    sscnt = 0
   HEAD bps3.br_proposed_srvres_id
    IF (bps3.br_proposed_srvres_id > 0)
     sscnt = (sscnt+ 1), stat = alterlist(reply->sglist[sgcnt].slist[scnt].sslist,sscnt), reply->
     sglist[sgcnt].slist[scnt].sslist[sscnt].br_proposed_srvres_id = bps3.br_proposed_srvres_id,
     reply->sglist[sgcnt].slist[scnt].sslist[sscnt].display = bps3.display, reply->sglist[sgcnt].
     slist[scnt].sslist[sscnt].description = bps3.description, reply->sglist[sgcnt].slist[scnt].
     sslist[sscnt].meaning = bps3.meaning,
     reply->sglist[sgcnt].slist[scnt].sslist[sscnt].activity_type_cd = bps3.activity_type_cd, reply->
     sglist[sgcnt].slist[scnt].sslist[sscnt].activity_subtype_cd = bps3.activity_subtype_cd, reply->
     sglist[sgcnt].slist[scnt].sslist[sscnt].catalog_type_cd = bps3.catalog_type_cd,
     reply->sglist[sgcnt].slist[scnt].sslist[sscnt].proposed_ind = bps3.proposed_ind, reply->sglist[
     sgcnt].slist[scnt].sslist[sscnt].automated_ind = bps3.automated_ind
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 DECLARE save_ct_cd = f8
 DECLARE save_ct_mean = vc
 DECLARE save_ct_display = vc
 DECLARE save_at_cd = f8
 DECLARE save_at_mean = vc
 DECLARE save_at_display = vc
 DECLARE save_ast_cd = f8
 DECLARE save_ast_mean = vc
 DECLARE save_ast_display = vc
 SET save_ct_cd = 0.0
 SET save_at_cd = 0.0
 SET save_ast_cd = 0.0
 FOR (x = 1 TO sgcnt)
  SET scnt = size(reply->sglist[x].slist,5)
  FOR (y = 1 TO scnt)
    IF ((reply->sglist[x].slist[y].catalog_type_cd > 0))
     IF ((reply->sglist[x].slist[y].catalog_type_cd != save_ct_cd))
      SELECT INTO "nl:"
       FROM code_value c
       PLAN (c
        WHERE (c.code_value=reply->sglist[x].slist[y].catalog_type_cd))
       DETAIL
        save_ct_cd = c.code_value, save_ct_mean = c.cdf_meaning, save_ct_display = c.display
       WITH nocounter
      ;end select
      IF (curqual=0)
       SET save_ct_cd = reply->sglist[x].slist[y].catalog_type_cd
       SET save_ct_mean = ""
       SET save_ct_display = ""
      ENDIF
     ENDIF
     SET reply->sglist[x].slist[y].catalog_type_mean = save_ct_mean
     SET reply->sglist[x].slist[y].catalog_type_display = save_ct_display
    ENDIF
    IF ((reply->sglist[x].slist[y].activity_type_cd > 0))
     IF ((reply->sglist[x].slist[y].activity_type_cd != save_at_cd))
      SELECT INTO "nl:"
       FROM code_value c
       PLAN (c
        WHERE (c.code_value=reply->sglist[x].slist[y].activity_type_cd))
       DETAIL
        save_at_cd = c.code_value, save_at_mean = c.cdf_meaning, save_at_display = c.display
       WITH nocounter
      ;end select
      IF (curqual=0)
       SET save_at_cd = reply->sglist[x].slist[y].activity_type_cd
       SET save_at_mean = ""
       SET save_at_display = ""
      ENDIF
     ENDIF
     SET reply->sglist[x].slist[y].activity_type_mean = save_at_mean
     SET reply->sglist[x].slist[y].activity_type_display = save_at_display
    ENDIF
    SET sscnt = size(reply->sglist[x].slist[y].sslist,5)
    FOR (z = 1 TO sscnt)
      SET reply->sglist[x].slist[y].sslist[z].catalog_type_mean = reply->sglist[x].slist[y].
      catalog_type_mean
      SET reply->sglist[x].slist[y].sslist[z].catalog_type_display = reply->sglist[x].slist[y].
      catalog_type_display
      SET reply->sglist[x].slist[y].sslist[z].activity_type_mean = reply->sglist[x].slist[y].
      activity_type_mean
      SET reply->sglist[x].slist[y].sslist[z].activity_type_display = reply->sglist[x].slist[y].
      activity_type_display
      IF ((reply->sglist[x].slist[y].sslist[z].activity_subtype_cd > 0))
       IF ((reply->sglist[x].slist[y].sslist[z].activity_subtype_cd != save_ast_cd))
        SELECT INTO "nl:"
         FROM code_value c
         PLAN (c
          WHERE (c.code_value=reply->sglist[x].slist[y].sslist[z].activity_subtype_cd))
         DETAIL
          save_ast_cd = c.code_value, save_ast_mean = c.cdf_meaning, save_ast_display = c.display
         WITH nocounter
        ;end select
        IF (curqual=0)
         SET save_ast_cd = reply->sglist[x].slist[y].sslist[z].activity_subtype_cd
         SET save_ast_mean = ""
         SET save_ast_display = ""
        ENDIF
       ENDIF
       SET reply->sglist[x].slist[y].sslist[z].activity_subtype_mean = save_ast_mean
       SET reply->sglist[x].slist[y].sslist[z].activity_subtype_display = save_ast_display
      ENDIF
      SET bcnt = size(reply->sglist[x].slist[y].sslist[z].blist,5)
      FOR (j = 1 TO bcnt)
        SET reply->sglist[x].slist[y].sslist[z].blist[j].catalog_type_mean = reply->sglist[x].slist[y
        ].sslist[z].catalog_type_mean
        SET reply->sglist[x].slist[y].sslist[z].blist[j].catalog_type_display = reply->sglist[x].
        slist[y].sslist[z].catalog_type_display
        SET reply->sglist[x].slist[y].sslist[z].blist[j].activity_type_mean = reply->sglist[x].slist[
        y].sslist[z].activity_type_mean
        SET reply->sglist[x].slist[y].sslist[z].blist[j].activity_type_display = reply->sglist[x].
        slist[y].sslist[z].activity_type_display
        SET reply->sglist[x].slist[y].sslist[z].blist[j].activity_subtype_mean = reply->sglist[x].
        slist[y].sslist[z].activity_subtype_mean
        SET reply->sglist[x].slist[y].sslist[z].blist[j].activity_subtype_display = reply->sglist[x].
        slist[y].sslist[z].activity_subtype_display
      ENDFOR
    ENDFOR
  ENDFOR
 ENDFOR
#exit_script
 CALL echorecord(reply)
END GO
