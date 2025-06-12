CREATE PROGRAM dm_ins_upd_code_value:dba
 RECORD reply(
   1 qual[*]
     2 code_value = f8
     2 status = c1
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 RECORD str(
   1 qual[10]
     2 str = vc
 )
 SET authentic_cd = 0.00
 SET unauthentic_cd = 0.00
 SET x = 0
 SET authcnt = 0
 SET display_key_dup_ind = 0
 SET cdf_meaning_dup_ind = 0
 SET active_ind_dup_ind = 0
 SET display_dup_ind = 0
 SET alias_dup_ind = 0
 SET definition_dup_ind = 0
 SET chg_access_ind = 0
 SET reply->status_data.status = "F"
 SET qual_size = size(request->qual,5)
 SET cur_updt_cnt = 0
 SET cur_active_ind = 0
 SET stat = alterlist(reply->qual,qual_size)
 SET new_code_value = 0.00
 SET disp_key = fillstring(40," ")
 SELECT INTO "nl:"
  c.code_value, c.cdf_meaning
  FROM code_value c
  WHERE c.code_set=8
   AND c.cdf_meaning IN ("AUTH", "UNAUTH")
  ORDER BY c.cdf_meaning
  DETAIL
   IF (authcnt=0)
    authentic_cd = c.code_value, authcnt = 1
   ELSE
    unauthentic_cd = c.code_value
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  cvs.display_key_dup_ind, cvs.cdf_meaning_dup_ind, cvs.active_ind_dup_ind,
  cvs.display_dup_ind, cvs.alias_dup_ind, cvs.definition_dup_ind,
  cvs.chg_access_ind
  FROM code_value_set cvs
  WHERE (cvs.code_set=request->code_set)
  DETAIL
   display_key_dup_ind = cvs.display_key_dup_ind, cdf_meaning_dup_ind = cvs.cdf_meaning_dup_ind,
   active_ind_dup_ind = cvs.active_ind_dup_ind,
   display_dup_ind = cvs.display_dup_ind, alias_dup_ind = cvs.alias_dup_ind, definition_dup_ind = cvs
   .definition_dup_ind,
   chg_access_ind = cvs.chg_access_ind
  WITH nocounter
 ;end select
 FOR (x = 1 TO qual_size)
   SET disp_key = trim(cnvtalphanum(cnvtupper(request->qual[x].display)))
   SET parser_buffer[18] = fillstring(132," ")
   SET parser_number = 0
   SET new_code_value = 0.00
   SET parser_buffer[1] = 'select into "nl:" c.*'
   SET parser_buffer[2] = "from code_value c"
   SET req_code_set = request->code_set
   SET parser_buffer[3] = "where c.code_set = req_code_set"
   SET parser_number = 3
   IF (display_key_dup_ind=1)
    SET parser_number += 1
    SET parser_buffer[parser_number] = "  and c.display_key = disp_key"
   ENDIF
   IF (display_dup_ind=1)
    SET parser_number += 1
    SET str->qual[1].str = request->qual[x].display
    SET parser_buffer[parser_number] = "  and c.display = str->qual[1]->str"
   ENDIF
   IF (cdf_meaning_dup_ind=1)
    IF ((request->qual[x].cdf_meaning > ""))
     SET parser_number += 1
     SET str->qual[2].str = request->qual[x].cdf_meaning
     SET parser_buffer[parser_number] = "  and c.cdf_meaning = str->qual[2]->str"
    ELSE
     SET parser_number += 1
     SET parser_buffer[parser_number] = "  and c.cdf_meaning = NULL"
    ENDIF
   ENDIF
   IF (definition_dup_ind=1)
    IF ((request->qual[x].definition > ""))
     SET parser_number += 1
     SET str->qual[3].str = request->qual[x].definition
     SET parser_buffer[parser_number] = "  and c.definition = str->qual[3]->str"
    ELSE
     SET parser_number += 1
     SET parser_buffer[parser_number] = "  and c.definition = NULL"
    ENDIF
   ENDIF
   IF (active_ind_dup_ind=1)
    SET parser_number += 1
    SET parser_buffer[parser_number] = "  and c.active_ind = request->qual[x]->active_ind"
   ENDIF
   IF (display_dup_ind=0
    AND display_key_dup_ind=0
    AND cdf_meaning_dup_ind=0
    AND active_ind_dup_ind=0
    AND definition_dup_ind=0
    AND alias_dup_ind=0)
    SET parser_number += 1
    SET str->qual[3].str = request->qual[x].display
    SET parser_buffer[parser_number] = "  and c.display = str->qual[3]->str"
   ENDIF
   SET parser_number += 1
   SET parser_buffer[parser_number] = "detail"
   SET parser_number += 1
   SET parser_buffer[parser_number] = "  new_code_value = c.code_value"
   SET parser_number += 1
   SET parser_buffer[parser_number] = "with nocounter go"
   FOR (z = 1 TO parser_number)
     CALL parser(parser_buffer[z],1)
   ENDFOR
   IF (curqual > 0)
    IF ((new_code_value != request->qual[x].code_value))
     SET reply->qual[x].code_value = request->qual[x].code_value
     SET reply->qual[x].status = "Z"
    ELSE
     SELECT INTO "nl:"
      c.*
      FROM code_value c
      WHERE (c.code_value=request->qual[x].code_value)
       AND (c.code_set=request->code_set)
      DETAIL
       cur_updt_cnt = c.updt_cnt, cur_active_ind = c.active_ind
      WITH nocounter, forupdate(c)
     ;end select
     IF (curqual=0)
      SET temp = 1
     ELSEIF ((cur_updt_cnt != request->qual[x].updt_cnt))
      SET reply->qual[x].code_value = request->qual[x].code_value
      SET reply->qual[x].status = "T"
     ELSE
      UPDATE  FROM code_value c
       SET c.cdf_meaning =
        IF ((request->qual[x].cdf_meaning > " ")) request->qual[x].cdf_meaning
        ELSE null
        ENDIF
        , c.display = request->qual[x].display, c.display_key = trim(cnvtupper(cnvtalphanum(request->
           qual[x].display))),
        c.description = request->qual[x].description, c.definition = request->qual[x].definition, c
        .collation_seq = request->qual[x].collation_seq,
        c.active_ind = request->qual[x].active_ind, c.active_type_cd =
        IF ((request->qual[x].active_ind=1)) reqdata->active_status_cd
        ELSE reqdata->inactive_status_cd
        ENDIF
        , c.data_status_cd =
        IF ((request->qual[x].authentic_ind=1)) authentic_cd
        ELSE unauthentic_cd
        ENDIF
        ,
        c.updt_id = reqinfo->updt_id, c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt = (c
        .updt_cnt+ 1),
        c.updt_task = reqinfo->updt_task, c.active_dt_tm =
        IF ((request->qual[x].active_ind=1)
         AND cur_active_ind=0) cnvtdatetime(sysdate)
        ELSE c.active_dt_tm
        ENDIF
        , c.updt_dt_tm = cnvtdatetime(sysdate),
        c.begin_effective_dt_tm = cnvtdatetime(sysdate), c.end_effective_dt_tm = cnvtdatetime(
         "31-dec-2100 00:00:00.00"), c.inactive_dt_tm =
        IF ((request->qual[x].active_ind=0)
         AND cur_active_ind=1) cnvtdatetime(sysdate)
        ELSE c.inactive_dt_tm
        ENDIF
       WHERE (c.code_value=request->qual[x].code_value)
       WITH nocounter
      ;end update
      IF (curqual > 0)
       SET reply->qual[x].code_value = request->qual[x].code_value
       SET reply->qual[x].status = "S"
      ELSE
       SET reply->qual[x].code_value = request->qual[x].code_value
       SET reply->qual[x].status = "X"
      ENDIF
     ENDIF
    ENDIF
   ELSE
    IF ((request->qual[x].code_value=0))
     SELECT INTO "nl:"
      xyz = seq(reference_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       new_code_value = cnvtreal(xyz)
      WITH format, nocounter
     ;end select
     INSERT  FROM code_value c
      SET c.code_value = new_code_value, c.code_set = request->code_set, c.cdf_meaning =
       IF ((request->qual[x].cdf_meaning > " ")) request->qual[x].cdf_meaning
       ELSE null
       ENDIF
       ,
       c.display = request->qual[x].display, c.display_key = trim(cnvtupper(cnvtalphanum(request->
          qual[x].display))), c.description = request->qual[x].description,
       c.definition = request->qual[x].definition, c.collation_seq = request->qual[x].collation_seq,
       c.active_ind = request->qual[x].active_ind,
       c.active_type_cd =
       IF ((request->qual[x].active_ind=1)) reqdata->active_status_cd
       ELSE reqdata->inactive_status_cd
       ENDIF
       , c.data_status_cd =
       IF ((request->qual[x].authentic_ind=1)) authentic_cd
       ELSE unauthentic_cd
       ENDIF
       , c.updt_id = reqinfo->updt_id,
       c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt = 0, c.updt_task = reqinfo->updt_task,
       c.active_dt_tm =
       IF ((request->qual[x].active_ind=1)) cnvtdatetime(sysdate)
       ENDIF
       , c.updt_dt_tm = cnvtdatetime(sysdate), c.begin_effective_dt_tm = cnvtdatetime(sysdate),
       c.end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00.00"), c.inactive_dt_tm =
       IF ((request->qual[x].active_ind=0)) cnvtdatetime(sysdate)
       ENDIF
      WITH nocounter
     ;end insert
     IF (curqual > 0)
      SET reply->qual[x].code_value = new_code_value
      SET reply->qual[x].status = "S"
     ELSE
      SET reply->qual[x].code_value = new_code_value
      SET reply->qual[x].status = "Y"
     ENDIF
    ELSE
     SELECT INTO "nl:"
      c.*
      FROM code_value c
      WHERE (c.code_value=request->qual[x].code_value)
       AND (c.code_set=request->code_set)
      DETAIL
       cur_updt_cnt = c.updt_cnt, cur_active_ind = c.active_ind
      WITH nocounter, forupdate(c)
     ;end select
     IF (curqual=0)
      SET temp = 1
     ELSEIF ((cur_updt_cnt != request->qual[x].updt_cnt))
      SET reply->qual[x].code_value = request->qual[x].code_value
      SET reply->qual[x].status = "T"
     ELSE
      UPDATE  FROM code_value c
       SET c.cdf_meaning =
        IF ((request->qual[x].cdf_meaning > " ")) request->qual[x].cdf_meaning
        ELSE null
        ENDIF
        , c.display = request->qual[x].display, c.display_key = trim(cnvtupper(cnvtalphanum(request->
           qual[x].display))),
        c.description = request->qual[x].description, c.definition = request->qual[x].definition, c
        .collation_seq = request->qual[x].collation_seq,
        c.active_ind = request->qual[x].active_ind, c.active_type_cd =
        IF ((request->qual[x].active_ind=1)) reqdata->active_status_cd
        ELSE reqdata->inactive_status_cd
        ENDIF
        , c.data_status_cd =
        IF ((request->qual[x].authentic_ind=1)) authentic_cd
        ELSE unauthentic_cd
        ENDIF
        ,
        c.updt_id = reqinfo->updt_id, c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt = (c
        .updt_cnt+ 1),
        c.updt_task = reqinfo->updt_task, c.active_dt_tm =
        IF ((request->qual[x].active_ind=1)
         AND cur_active_ind=0) cnvtdatetime(sysdate)
        ELSE c.active_dt_tm
        ENDIF
        , c.updt_dt_tm = cnvtdatetime(sysdate),
        c.begin_effective_dt_tm = cnvtdatetime(sysdate), c.end_effective_dt_tm = cnvtdatetime(
         "31-dec-2100 00:00:00.00"), c.inactive_dt_tm =
        IF ((request->qual[x].active_ind=0)
         AND cur_active_ind=1) cnvtdatetime(sysdate)
        ELSE c.inactive_dt_tm
        ENDIF
       WHERE (c.code_value=request->qual[x].code_value)
       WITH nocounter
      ;end update
      IF (curqual > 0)
       SET reply->qual[x].code_value = request->qual[x].code_value
       SET reply->qual[x].status = "S"
      ELSE
       SET reply->qual[x].code_value = request->qual[x].code_value
       SET reply->qual[x].status = "X"
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   COMMIT
 ENDFOR
 SET reply->status_data.status = "S"
END GO
