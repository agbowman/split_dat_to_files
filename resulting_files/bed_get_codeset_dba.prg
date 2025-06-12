CREATE PROGRAM bed_get_codeset:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 codes[*]
      2 code_set = i4
      2 code_list[*]
        3 code_value = f8
        3 display = vc
        3 meaning = vc
        3 active_ind = i2
        3 gen_info
          4 description = vc
          4 definition = vc
          4 collation_seq = i4
          4 concept_cki = vc
          4 cki = vc
          4 display_key = vc
        3 alias[*]
          4 source = f8
          4 alias = vc
          4 meaning = vc
        3 extension[*]
          4 name = vc
          4 value = vc
        3 parent[*]
          4 code = f8
          4 code_set = i4
          4 description = vc
          4 display = vc
          4 meaning = vc
        3 child[*]
          4 code = f8
          4 code_set = i4
          4 description = vc
          4 display = vc
          4 meaning = vc
          4 active_ind = i2
      2 code_set_display = vc
      2 too_many_codes = i4
    1 error_msg = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = vc
        3 operationstatus = c1
        3 targetobjectname = vc
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE error_msg = vc
 CALL echo("HERE")
 CALL echorecord(request)
 SET error_flag = "F"
 SET reply->status_data.status = "F"
 SET code = 0
 SET i = 0
 SET ii = 0
 SET jj = 0
 SET x = 0
 SET sze = size(request->code_list,5)
 SET stat = alterlist(reply->codes,sze)
 DECLARE cs_parse = vc
 IF (sze=0)
  SET error_flag = "T"
  SET error_msg = "Request for codes is empty"
  GO TO exit_program
 ENDIF
 FOR (ii = 1 TO sze)
   SET ssize = size(request->code_list[ii].search_list,5)
   IF ((request->code_list[ii].code_value > 0))
    SET cs_parse = build("c.code_value = ",request->code_list[ii].code_value)
   ELSE
    SET reply->codes[ii].code_set = request->code_list[ii].code_set
    SET cs_parse = build("c.code_set = ",request->code_list[ii].code_set)
    SELECT INTO "nl:"
     FROM code_value_set cvs
     PLAN (cvs
      WHERE (cvs.code_set=reply->codes[ii].code_set))
     DETAIL
      reply->codes[ii].code_set_display = cvs.display
     WITH nocounter
    ;end select
   ENDIF
   CALL echo(cs_parse)
   SELECT INTO "nl:"
    FROM code_value c
    PLAN (c
     WHERE parser(cs_parse)
      AND ((c.active_ind=1) OR ((request->load.inactive_ind=1))) )
    ORDER BY c.cdf_meaning, c.display_key
    HEAD c.code_set
     reply->codes[ii].code_set = c.code_set, jj = 0
    HEAD c.code_value
     match_ind = 1
     IF (ssize > 0)
      match_ind = 0
      FOR (y = 1 TO ssize)
        mean_match = 0, disp_match = 0, desc_match = 0
        IF ((request->code_list[ii].search_list[y].mean > "  *"))
         IF ((c.cdf_meaning=request->code_list[ii].search_list[y].mean))
          mean_match = 1
         ENDIF
        ELSE
         mean_match = 1
        ENDIF
        IF ((request->code_list[ii].search_list[y].display > "  *"))
         IF (c.display_key=cnvtupper(cnvtalphanum(substring(1,40,request->code_list[ii].search_list[y
            ].display))))
          disp_match = 1
         ENDIF
        ELSE
         disp_match = 1
        ENDIF
        IF ((request->code_list[ii].search_list[y].description > "  *"))
         IF (cnvtupper(c.description)=cnvtupper(request->code_list[ii].search_list[y].description))
          desc_match = 1
         ENDIF
        ELSE
         desc_match = 1
        ENDIF
        IF (match_ind=0)
         IF (mean_match=1
          AND disp_match=1
          AND desc_match=1)
          match_ind = 1
         ENDIF
        ENDIF
      ENDFOR
     ENDIF
     IF (validate(request->max_reply,0) > 0)
      IF (match_ind=1
       AND (jj <= request->max_reply))
       jj = (jj+ 1), stat = alterlist(reply->codes[ii].code_list,jj), code = c.code_value,
       reply->codes[ii].code_list[jj].code_value = c.code_value, reply->codes[ii].code_list[jj].
       display = trim(c.display,3), reply->codes[ii].code_list[jj].meaning = cnvtupper(trim(c
         .cdf_meaning,3)),
       reply->codes[ii].code_list[jj].active_ind = c.active_ind
       IF (request->load.general_info_ind)
        reply->codes[ii].code_list[jj].gen_info.description = trim(c.description,3), reply->codes[ii]
        .code_list[jj].gen_info.definition = trim(c.definition,3), reply->codes[ii].code_list[jj].
        gen_info.collation_seq = c.collation_seq,
        reply->codes[ii].code_list[jj].gen_info.concept_cki = c.concept_cki, reply->codes[ii].
        code_list[jj].gen_info.cki = c.cki, reply->codes[ii].code_list[jj].gen_info.display_key = c
        .display_key
       ENDIF
      ENDIF
      IF ((jj > request->max_reply))
       reply->codes[ii].too_many_codes = 1
      ENDIF
     ELSE
      reply->codes[ii].too_many_codes = 0
      IF (match_ind=1)
       jj = (jj+ 1), stat = alterlist(reply->codes[ii].code_list,jj), code = c.code_value,
       reply->codes[ii].code_list[jj].code_value = c.code_value, reply->codes[ii].code_list[jj].
       display = trim(c.display,3), reply->codes[ii].code_list[jj].meaning = cnvtupper(trim(c
         .cdf_meaning,3)),
       reply->codes[ii].code_list[jj].active_ind = c.active_ind
       IF (request->load.general_info_ind)
        reply->codes[ii].code_list[jj].gen_info.description = trim(c.description,3), reply->codes[ii]
        .code_list[jj].gen_info.definition = trim(c.definition,3), reply->codes[ii].code_list[jj].
        gen_info.collation_seq = c.collation_seq,
        reply->codes[ii].code_list[jj].gen_info.concept_cki = c.concept_cki, reply->codes[ii].
        code_list[jj].gen_info.cki = c.cki, reply->codes[ii].code_list[jj].gen_info.display_key = c
        .display_key
       ENDIF
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (curqual > 0)
    IF ((request->load.alias_ind=1))
     IF (jj > 0)
      SET i = 0
      SELECT INTO "nl:"
       FROM (dummyt d  WITH seq = value(jj)),
        code_value_alias a
       PLAN (d)
        JOIN (a
        WHERE (a.code_value=reply->codes[ii].code_list[d.seq].code_value)
         AND ((a.contributor_source_cd+ 0) > 0.0)
         AND trim(a.alias,3) > " ")
       ORDER BY d.seq, a.contributor_source_cd, a.alias
       HEAD d.seq
        i = 0
       HEAD a.alias
        i = (i+ 1), stat = alterlist(reply->codes[ii].code_list[d.seq].alias,i), reply->codes[ii].
        code_list[d.seq].alias[i].source = a.contributor_source_cd,
        reply->codes[ii].code_list[d.seq].alias[i].alias = trim(a.alias,3), reply->codes[ii].
        code_list[d.seq].alias[i].meaning = cnvtupper(trim(a.alias_type_meaning,3))
       WITH nocounter
      ;end select
     ENDIF
    ENDIF
    IF ((request->load.extension_ind=1))
     IF (jj > 0)
      SET i = 0
      SELECT INTO "nl:"
       FROM (dummyt d  WITH seq = value(jj)),
        code_value_extension e
       PLAN (d)
        JOIN (e
        WHERE (e.code_value=reply->codes[ii].code_list[d.seq].code_value)
         AND trim(e.field_name,3) > " "
         AND trim(e.field_value,3) > " ")
       ORDER BY d.seq, e.field_name
       HEAD d.seq
        i = 0
       HEAD e.field_name
        i = (i+ 1), stat = alterlist(reply->codes[ii].code_list[d.seq].extension,i), reply->codes[ii]
        .code_list[d.seq].extension[i].name = cnvtupper(trim(e.field_name,3)),
        reply->codes[ii].code_list[d.seq].extension[i].value = trim(e.field_value,3)
       WITH nocounter
      ;end select
     ENDIF
    ENDIF
    IF ((request->load.parent_ind=1))
     FOR (y = 1 TO jj)
       FREE SET p_temp
       RECORD p_temp(
         1 parent[*]
           2 code = f8
           2 code_set = i4
           2 description = vc
           2 display = vc
           2 meaning = vc
       )
       SET i = 0
       SELECT INTO "nl:"
        FROM code_value_group g,
         code_value c
        PLAN (g
         WHERE (g.child_code_value=reply->codes[ii].code_list[y].code_value)
          AND ((g.parent_code_value+ 0) > 0.0))
         JOIN (c
         WHERE c.code_value=g.parent_code_value
          AND trim(c.display,3) > " ")
        ORDER BY g.child_code_value, c.code_value
        HEAD g.child_code_value
         i = (i+ 0)
        HEAD c.code_value
         i = (i+ 1), stat = alterlist(p_temp->parent,i), p_temp->parent[i].code = c.code_value,
         p_temp->parent[i].code_set = c.code_set, p_temp->parent[i].description = trim(c.description,
          3), p_temp->parent[i].display = trim(c.display,3),
         p_temp->parent[i].meaning = cnvtupper(trim(c.cdf_meaning,3))
        WITH nocounter
       ;end select
       SET stat = alterlist(reply->codes[ii].code_list[y].parent,i)
       SET x = 0
       IF (i > 0)
        SELECT INTO "nl:"
         dkey = cnvtupper(cnvtalphanum(p_temp->parent[d.seq].display))
         FROM (dummyt d  WITH seq = i)
         ORDER BY dkey
         DETAIL
          x = (x+ 1), reply->codes[ii].code_list[y].parent[x].code = p_temp->parent[d.seq].code,
          reply->codes[ii].code_list[y].parent[x].code_set = p_temp->parent[d.seq].code_set,
          reply->codes[ii].code_list[y].parent[x].description = p_temp->parent[d.seq].description,
          reply->codes[ii].code_list[y].parent[x].display = p_temp->parent[d.seq].display, reply->
          codes[ii].code_list[y].parent[x].meaning = p_temp->parent[d.seq].meaning
         WITH nocounter
        ;end select
       ENDIF
     ENDFOR
    ENDIF
    IF ((request->load.child_ind=1))
     FOR (y = 1 TO jj)
       FREE SET c_temp
       RECORD c_temp(
         1 child[*]
           2 code = f8
           2 code_set = i4
           2 description = vc
           2 display = vc
           2 meaning = vc
           2 active_ind = i2
       )
       SET i = 0
       SELECT INTO "nl:"
        FROM code_value_group g,
         code_value c
        PLAN (g
         WHERE (g.parent_code_value=reply->codes[ii].code_list[y].code_value)
          AND ((g.child_code_value+ 0) > 0.0))
         JOIN (c
         WHERE c.code_value=g.child_code_value
          AND trim(c.display,3) > " ")
        ORDER BY g.parent_code_value, c.code_value
        HEAD g.parent_code_value
         i = (i+ 0)
        HEAD c.code_value
         i = (i+ 1), stat = alterlist(c_temp->child,i), c_temp->child[i].code = c.code_value,
         c_temp->child[i].code_set = c.code_set, c_temp->child[i].description = trim(c.description,3),
         c_temp->child[i].display = trim(c.display,3),
         c_temp->child[i].meaning = cnvtupper(trim(c.cdf_meaning,3)), c_temp->child[i].active_ind = c
         .active_ind
        WITH nocounter
       ;end select
       SET stat = alterlist(reply->codes[ii].code_list[y].child,i)
       SET x = 0
       IF (i > 0)
        SELECT INTO "nl:"
         dkey = cnvtupper(cnvtalphanum(c_temp->child[d.seq].display))
         FROM (dummyt d  WITH seq = i)
         ORDER BY dkey
         DETAIL
          x = (x+ 1), reply->codes[ii].code_list[y].child[x].code = c_temp->child[d.seq].code, reply
          ->codes[ii].code_list[y].child[x].code_set = c_temp->child[d.seq].code_set,
          reply->codes[ii].code_list[y].child[x].description = c_temp->child[d.seq].description,
          reply->codes[ii].code_list[y].child[x].display = c_temp->child[d.seq].display, reply->
          codes[ii].code_list[y].child[x].meaning = c_temp->child[d.seq].meaning,
          reply->codes[ii].code_list[y].child[x].active_ind = c_temp->child[d.seq].active_ind
         WITH nocounter
        ;end select
       ENDIF
     ENDFOR
    ENDIF
   ENDIF
 ENDFOR
 IF (jj=0)
  SET reply->status_data.status = "Z"
  GO TO exit_program
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_program
 IF (error_flag="T")
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat(" >> PROGRAM NAME:  bed_get_codeset  >> ERROR MESSAGE: ",error_msg)
 ENDIF
 CALL echorecord(reply)
END GO
