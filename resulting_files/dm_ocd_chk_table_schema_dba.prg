CREATE PROGRAM dm_ocd_chk_table_schema:dba
 RECORD reply(
   1 msg_cnt = i4
   1 msg[*]
     2 msg_text = vc
     2 sub_cnt = i4
     2 sub[*]
       3 sub_text = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->msg_cnt = 0
 SET stat = alterlist(reply->msg,0)
 SET reply->status_data.status = "F"
 SET dm_debug = 0
 IF (validate(dm_ocd_debug,- (1)) > 0)
  SET dm_debug = dm_ocd_debug
 ENDIF
 FREE RECORD str
 RECORD str(
   1 str = vc
   1 str2 = vc
 )
 FREE RECORD o_table
 RECORD o_table(
   1 col_cnt = i4
   1 cols[*]
     2 column_name = c30
     2 data_type = c9
     2 data_length = i4
     2 nullable = c1
     2 data_default = vc
   1 cons_cnt = i4
   1 cons[*]
     2 constraint_name = c30
     2 constraint_type = c1
     2 parent_table_name = c30
     2 col_cnt = i4
     2 cols[*]
       3 column_name = c30
       3 column_pos = i4
     2 dup_ind = i2
   1 ind_cnt = i4
   1 ind[*]
     2 index_name = c30
     2 unique_ind = i2
     2 col_cnt = i4
     2 cols[*]
       3 column_name = c30
       3 column_pos = i4
     2 dup_ind = i2
 )
 IF ((request->col_cnt > 0))
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(request->col_cnt))
   ORDER BY d.seq
   HEAD REPORT
    o_table->col_cnt = request->col_cnt, stat = alterlist(o_table->cols,o_table->col_cnt)
   DETAIL
    o_table->cols[d.seq].column_name = request->cols[d.seq].column_name, o_table->cols[d.seq].
    data_type = request->cols[d.seq].data_type, o_table->cols[d.seq].data_length = request->cols[d
    .seq].data_length,
    o_table->cols[d.seq].nullable = request->cols[d.seq].nullable, o_table->cols[d.seq].data_default
     = request->cols[d.seq].data_default
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->cons_cnt > 0))
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(request->cons_cnt))
   ORDER BY d.seq
   HEAD REPORT
    o_table->cons_cnt = request->cons_cnt, stat = alterlist(o_table->cons,o_table->cons_cnt)
   DETAIL
    o_table->cons[d.seq].constraint_name = request->cons[d.seq].constraint_name, o_table->cons[d.seq]
    .constraint_type = request->cons[d.seq].constraint_type, o_table->cons[d.seq].parent_table_name
     = request->cons[d.seq].parent_table_name,
    o_table->cons[d.seq].dup_ind = 0, o_table->cons[d.seq].col_cnt = 0, done = 0,
    cnt = 0, start_pos = 1, pos = findstring(",",request->cons[d.seq].columns,start_pos)
    WHILE (done=0)
      IF (pos=0)
       len = ((size(request->cons[d.seq].columns,1) - start_pos)+ 1), done = 1
      ELSE
       len = (pos - start_pos)
      ENDIF
      cnt = (cnt+ 1), o_table->cons[d.seq].col_cnt = cnt, stat = alterlist(o_table->cons[d.seq].cols,
       cnt),
      o_table->cons[d.seq].cols[cnt].column_name = substring(start_pos,len,request->cons[d.seq].
       columns), o_table->cons[d.seq].cols[cnt].column_pos = cnt, start_pos = (pos+ 1),
      pos = findstring(",",request->cons[d.seq].columns,start_pos)
    ENDWHILE
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->ind_cnt > 0))
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(request->ind_cnt))
   ORDER BY d.seq
   HEAD REPORT
    o_table->ind_cnt = request->ind_cnt, stat = alterlist(o_table->ind,o_table->ind_cnt)
   DETAIL
    o_table->ind[d.seq].index_name = request->ind[d.seq].index_name, o_table->ind[d.seq].unique_ind
     = request->ind[d.seq].unique_ind, o_table->ind[d.seq].col_cnt = 0,
    o_table->ind[d.seq].dup_ind = 0, done = 0, cnt = 0,
    start_pos = 1, pos = findstring(",",request->ind[d.seq].columns,start_pos)
    WHILE (done=0)
      IF (pos=0)
       len = ((size(request->ind[d.seq].columns,1) - start_pos)+ 1), done = 1
      ELSE
       len = (pos - start_pos)
      ENDIF
      cnt = (cnt+ 1), o_table->ind[d.seq].col_cnt = cnt, stat = alterlist(o_table->ind[d.seq].cols,
       cnt),
      o_table->ind[d.seq].cols[cnt].column_name = substring(start_pos,len,request->ind[d.seq].columns
       ), o_table->ind[d.seq].cols[cnt].column_pos = cnt, start_pos = (pos+ 1),
      pos = findstring(",",request->ind[d.seq].columns,start_pos)
    ENDWHILE
   WITH nocounter
  ;end select
 ENDIF
 IF (dm_debug=1)
  CALL echo("***")
  CALL echorecord(o_table)
  CALL echo("***")
 ENDIF
 FOR (icnt = 1 TO o_table->ind_cnt)
   SET diff_ind = 0
   SET str->str = ""
   SET match_cols = 0
   SELECT INTO "nl:"
    FROM (dummyt i  WITH seq = value(o_table->ind[icnt].col_cnt)),
     (dummyt t  WITH seq = value(o_table->col_cnt))
    PLAN (i)
     JOIN (t
     WHERE (o_table->ind[icnt].cols[i.seq].column_name=o_table->cols[t.seq].column_name))
    HEAD REPORT
     cnt = 0
    DETAIL
     IF (cnt=1)
      str->str = build(o_table->cols[t.seq].column_name)
     ELSE
      str->str = build(str->str,",",o_table->cols[t.seq].column_name)
     ENDIF
     match_cols = (match_cols+ 1)
    WITH nocounter
   ;end select
   IF ((match_cols=o_table->ind[icnt].col_cnt))
    SET diff_ind = 0
   ELSE
    SET diff_ind = 1
    SET cnt = 0
    SET str->str2 = ""
    SET reply->msg_cnt = (reply->msg_cnt+ 1)
    SET stat = alterlist(reply->msg,reply->msg_cnt)
    SET reply->msg[reply->msg_cnt].sub_cnt = 0
    SET stat = alterlist(reply->msg[reply->msg_cnt].sub,0)
    SELECT INTO "nl:"
     FROM (dummyt i  WITH seq = value(o_table->ind[icnt].col_cnt))
     PLAN (i
      WHERE findstring(trim(o_table->ind[icnt].cols[i.seq].column_name),str->str)=0)
     DETAIL
      cnt = (cnt+ 1), reply->msg[reply->msg_cnt].sub_cnt = cnt, stat = alterlist(reply->msg[reply->
       msg_cnt].sub,cnt),
      reply->msg[reply->msg_cnt].sub[cnt].sub_text = o_table->ind[icnt].cols[i.seq].column_name
     WITH nocounter
    ;end select
    SET reply->msg[reply->msg_cnt].msg_text = concat("Index ",trim(o_table->ind[icnt].index_name),
     " has ",trim(cnvtstring(cnt))," columns that are not on the OCD table.")
    IF (dm_debug=1)
     CALL echo("***")
     CALL echo(build("*** Index:",o_table->ind[icnt].index_name," has columns not on table!"))
     CALL echo("***")
    ENDIF
   ENDIF
 ENDFOR
 SET pk = 0
 SET pk_index = 0
 FOR (ccnt = 1 TO o_table->cons_cnt)
   IF ((o_table->cons[ccnt].constraint_type="P"))
    SET pk = ccnt
   ENDIF
   SET diff_ind = 0
   SET str->str = ""
   SET match_cols = 0
   SELECT INTO "nl:"
    FROM (dummyt c  WITH seq = value(o_table->cons[ccnt].col_cnt)),
     (dummyt t  WITH seq = value(o_table->col_cnt))
    PLAN (c)
     JOIN (t
     WHERE (o_table->cons[ccnt].cols[c.seq].column_name=o_table->cols[t.seq].column_name))
    HEAD REPORT
     cnt = 0
    DETAIL
     cnt = (cnt+ 1)
     IF (cnt=1)
      str->str = build(o_table->cols[t.seq].column_name)
     ELSE
      str->str = build(str->str,",",o_table->cols[t.seq].column_name)
     ENDIF
     match_cols = (match_cols+ 1)
    WITH nocounter
   ;end select
   IF ((match_cols=o_table->cons[ccnt].col_cnt))
    SET diff_ind = 0
   ELSE
    SET diff_ind = 1
    SET cnt = 0
    SET reply->msg_cnt = (reply->msg_cnt+ 1)
    SET stat = alterlist(reply->msg,reply->msg_cnt)
    SET reply->msg[reply->msg_cnt].sub_cnt = 0
    SET stat = alterlist(reply->msg[reply->msg_cnt].sub,0)
    SELECT INTO "nl:"
     FROM (dummyt c  WITH seq = value(o_table->cons[ccnt].col_cnt))
     PLAN (c
      WHERE findstring(trim(o_table->cons[ccnt].cols[c.seq].column_name),str->str)=0)
     DETAIL
      cnt = (cnt+ 1), reply->msg[reply->msg_cnt].sub_cnt = cnt, stat = alterlist(reply->msg[reply->
       msg_cnt].sub,cnt),
      reply->msg[reply->msg_cnt].sub[cnt].sub_text = o_table->cons[ccnt].cols[c.seq].column_name
     WITH nocounter
    ;end select
    SET reply->msg[reply->msg_cnt].msg_text = concat("Constraint ",trim(o_table->cons[ccnt].
      constraint_name)," has ",trim(cnvtstring(cnt))," columns that are not on the OCD table.")
    IF (dm_debug=1)
     CALL echo("***")
     CALL echo(build("*** Constraint:",o_table->cons[ccnt].constraint_name,
       " has columns not on table!"))
     CALL echo("***")
    ENDIF
   ENDIF
 ENDFOR
 IF (pk > 0)
  SET diff_ind = 0
  SET str->str = ""
  SET match_cols = 0
  SELECT INTO "nl:"
   FROM (dummyt c  WITH seq = value(o_table->cons[pk].col_cnt)),
    (dummyt t  WITH seq = value(o_table->col_cnt))
   PLAN (c)
    JOIN (t
    WHERE (o_table->cols[t.seq].nullable="Y")
     AND (o_table->cols[t.seq].column_name=o_table->cons[pk].cols[c.seq].column_name))
   DETAIL
    match_cols = (match_cols+ 1)
    IF (match_cols=1)
     str->str = build(o_table->cons[pk].cols[c.seq].column_name)
    ELSE
     str->str = build(str->str,",",o_table->cons[pk].cols[c.seq].column_name)
    ENDIF
   WITH nocounter
  ;end select
  IF (match_cols=0)
   SET diff_ind = 0
  ELSE
   SET diff_ind = 1
   SET reply->msg_cnt = (reply->msg_cnt+ 1)
   SET stat = alterlist(reply->msg,reply->msg_cnt)
   SET reply->msg[reply->msg_cnt].sub_cnt = 0
   SET stat = alterlist(reply->msg[reply->msg_cnt].sub,0)
   SET reply->msg[reply->msg_cnt].msg_text = concat("Primary key constraint ",trim(o_table->cons[pk].
     constraint_name)," has ",trim(cnvtstring(match_cols))," nullable columns.")
   SET done = 0
   SET cnt = 0
   SET start_pos = 1
   SET pos = findstring(",",str->str,start_pos)
   WHILE (done=0)
     IF (pos=0)
      SET len = ((size(str->str,1) - start_pos)+ 1)
      SET done = 1
     ELSE
      SET len = (pos - start_pos)
     ENDIF
     SET cnt = (cnt+ 1)
     SET reply->msg[reply->msg_cnt].sub_cnt = cnt
     SET stat = alterlist(reply->msg[reply->msg_cnt].sub,cnt)
     SET reply->msg[reply->msg_cnt].sub[cnt].sub_text = substring(start_pos,len,str->str)
     SET start_pos = (pos+ 1)
     SET pos = findstring(",",str->str,start_pos)
   ENDWHILE
   IF (dm_debug=1)
    CALL echo("***")
    CALL echo(build("*** PK Constraint:",o_table->cons[pk].constraint_name," has nullable columns!"))
    CALL echo("***")
   ENDIF
  ENDIF
  SET pk_index = 0
  FOR (j = 1 TO o_table->ind_cnt)
    SET match_cols = 0
    SELECT INTO "nl:"
     FROM (dummyt i  WITH seq = value(o_table->ind[j].col_cnt)),
      (dummyt c  WITH seq = value(o_table->cons[pk].col_cnt))
     PLAN (c)
      JOIN (i
      WHERE (o_table->ind[j].cols[i.seq].column_name=o_table->cons[pk].cols[c.seq].column_name)
       AND (o_table->ind[j].cols[i.seq].column_pos=o_table->cons[pk].cols[c.seq].column_pos))
     ORDER BY o_table->cons[pk].cols[c.seq].column_pos
     DETAIL
      match_cols = (match_cols+ 1)
     WITH nocounter
    ;end select
    IF ((match_cols=o_table->cons[pk].col_cnt)
     AND (match_cols=o_table->ind[j].col_cnt))
     SET pk_index = j
     SET j = o_table->ind_cnt
    ENDIF
  ENDFOR
  IF (pk_index=0)
   SET diff_ind = 1
   SET reply->msg_cnt = (reply->msg_cnt+ 1)
   SET stat = alterlist(reply->msg,reply->msg_cnt)
   SET reply->msg[reply->msg_cnt].sub_cnt = 0
   SET stat = alterlist(reply->msg[reply->msg_cnt].sub,0)
   SET reply->msg[reply->msg_cnt].msg_text = "Primary key index not found!"
   IF (dm_debug=1)
    CALL echo("***")
    CALL echo("*** Primary key index not found!")
    CALL echo("***")
   ENDIF
  ENDIF
 ENDIF
 SET c_max_cols = 0
 FOR (ccnt = 1 TO o_table->cons_cnt)
   SET c_max_cols = greatest(c_max_cols,o_table->cons[ccnt].col_cnt)
   SET icnt = 0
   FOR (i = 1 TO o_table->ind_cnt)
     IF ((o_table->ind[i].index_name=o_table->cons[ccnt].constraint_name))
      SET icnt = i
      SET i = o_table->ind_cnt
     ENDIF
   ENDFOR
   IF (icnt > 0)
    SET diff_ind = 0
    SET str->str = ""
    SET match_cols = 0
    SET match_cols = 0
    SELECT INTO "nl:"
     FROM (dummyt c  WITH seq = value(o_table->cons[ccnt].col_cnt)),
      (dummyt i  WITH seq = value(o_table->ind[icnt].col_cnt))
     PLAN (c)
      JOIN (i
      WHERE (o_table->ind[icnt].cols[i.seq].column_pos=o_table->cons[ccnt].cols[c.seq].column_pos)
       AND (o_table->ind[icnt].cols[i.seq].column_name=o_table->cons[ccnt].cols[c.seq].column_name))
     DETAIL
      match_cols = (match_cols+ 1)
      IF (match_cols=1)
       str->str = build(o_table->cons[ccnt].cols[c.seq].column_name)
      ELSE
       str->str = build(str->str,",",o_table->cons[ccnt].cols[c.seq].column_name)
      ENDIF
     WITH nocounter
    ;end select
    IF ((match_cols=o_table->ind[icnt].col_cnt)
     AND (match_cols=o_table->cons[ccnt].col_cnt))
     SET diff_ind = 0
    ELSE
     SET diff_ind = 1
     SET reply->msg_cnt = (reply->msg_cnt+ 1)
     SET stat = alterlist(reply->msg,reply->msg_cnt)
     SET reply->msg[reply->msg_cnt].sub_cnt = 0
     SET stat = alterlist(reply->msg[reply->msg_cnt].sub,0)
     SET cnt = 0
     IF ((match_cols != o_table->cons[ccnt].col_cnt))
      SELECT INTO "nl:"
       FROM (dummyt c  WITH seq = value(o_table->cons[ccnt].col_cnt))
       PLAN (c
        WHERE findstring(trim(o_table->cons[ccnt].cols[c.seq].column_name),str->str)=0)
       DETAIL
        cnt = (cnt+ 1), reply->msg[reply->msg_cnt].sub_cnt = cnt, stat = alterlist(reply->msg[reply->
         msg_cnt].sub,cnt),
        reply->msg[reply->msg_cnt].sub[cnt].sub_text = o_table->cons[ccnt].cols[c.seq].column_name
       WITH nocounter
      ;end select
     ENDIF
     IF ((match_cols != o_table->ind[icnt].col_cnt))
      SELECT INTO "nl:"
       FROM (dummyt i  WITH seq = value(o_table->ind[icnt].col_cnt))
       PLAN (i
        WHERE findstring(trim(o_table->ind[icnt].cols[i.seq].column_name),str->str)=0)
       DETAIL
        fnd = 0
        FOR (i = 1 TO reply->msg[reply->msg_cnt].sub_cnt)
          IF ((reply->msg[reply->msg_cnt].sub[i].sub_text=o_table->ind[icnt].cols[i.seq].column_name)
          )
           fnd = i, i = reply->msg[reply->msg_cnt].sub_cnt
          ENDIF
        ENDFOR
        IF (fnd=0)
         cnt = (cnt+ 1), reply->msg[reply->msg_cnt].sub_cnt = cnt, stat = alterlist(reply->msg[reply
          ->msg_cnt].sub,cnt),
         reply->msg[reply->msg_cnt].sub[cnt].sub_text = o_table->ind[icnt].cols[i.seq].column_name
        ENDIF
       WITH nocounter
      ;end select
     ENDIF
     SET reply->msg[reply->msg_cnt].msg_text = concat("Constraint ",trim(o_table->cons[ccnt].
       constraint_name)," and index ",trim(o_table->ind[icnt].index_name)," have ",
      trim(cnvtstring(cnt))," different columns.")
    ENDIF
   ENDIF
 ENDFOR
 FOR (ccnt = 1 TO o_table->cons_cnt)
   IF ((o_table->cons[ccnt].dup_ind=0))
    SET match_cols = 0
    SET diff_ind = 0
    SELECT
     IF ((o_table->cons[ccnt].constraint_type="R"))INTO "nl:"
      cname = o_table->cons[c.seq].constraint_name
      FROM (dummyt c  WITH seq = value(o_table->cons_cnt)),
       (dummyt cc  WITH seq = value(c_max_cols)),
       (dummyt dc  WITH seq = value(o_table->cons[ccnt].col_cnt))
      PLAN (c
       WHERE (o_table->cons[c.seq].constraint_name != o_table->cons[ccnt].constraint_name))
       JOIN (cc
       WHERE (cc.seq <= o_table->cons[c.seq].col_cnt))
       JOIN (dc
       WHERE (o_table->cons[ccnt].constraint_type=o_table->cons[c.seq].constraint_type)
        AND (o_table->cons[ccnt].parent_table_name=o_table->cons[c.seq].parent_table_name)
        AND (o_table->cons[ccnt].cols[dc.seq].column_name=o_table->cons[c.seq].cols[cc.seq].
       column_name)
        AND (o_table->cons[ccnt].cols[dc.seq].column_pos=o_table->cons[c.seq].cols[cc.seq].column_pos
       ))
      ORDER BY o_table->cons[c.seq].constraint_name, o_table->cons[c.seq].cols[cc.seq].column_pos
     ELSE INTO "nl:"
      cname = o_table->cons[c.seq].constraint_name
      FROM (dummyt c  WITH seq = value(o_table->cons_cnt)),
       (dummyt cc  WITH seq = value(c_max_cols)),
       (dummyt dc  WITH seq = value(o_table->cons[ccnt].col_cnt))
      PLAN (c
       WHERE (o_table->cons[c.seq].constraint_name != o_table->cons[ccnt].constraint_name)
        AND (o_table->cons[c.seq].constraint_type != "R"))
       JOIN (cc
       WHERE (cc.seq <= o_table->cons[c.seq].col_cnt))
       JOIN (dc
       WHERE (o_table->cons[ccnt].cols[dc.seq].column_name=o_table->cons[c.seq].cols[cc.seq].
       column_name)
        AND (o_table->cons[ccnt].cols[dc.seq].column_pos=o_table->cons[c.seq].cols[cc.seq].column_pos
       ))
      ORDER BY o_table->cons[c.seq].constraint_name, o_table->cons[c.seq].cols[cc.seq].column_pos
     ENDIF
     HEAD REPORT
      diff_ind = 0, cnt = 0
     HEAD cname
      match_cols = 0
     DETAIL
      match_cols = (match_cols+ 1)
     FOOT  cname
      IF ((match_cols=o_table->cons[ccnt].col_cnt)
       AND (match_cols=o_table->cons[c.seq].col_cnt))
       IF (diff_ind=0)
        diff_ind = 1, reply->msg_cnt = (reply->msg_cnt+ 1), stat = alterlist(reply->msg,reply->
         msg_cnt),
        reply->msg[reply->msg_cnt].sub_cnt = 0, stat = alterlist(reply->msg[reply->msg_cnt].sub,0)
        IF ((o_table->cons[ccnt].constraint_type="P"))
         str->str = "Primary key constraint"
        ELSEIF ((o_table->cons[ccnt].constraint_type="R"))
         str->str = "Foreign key constraint"
        ELSEIF ((o_table->cons[ccnt].constraint_type="U"))
         str->str = "Unique constraint"
        ELSE
         str->str = "Constraint"
        ENDIF
        reply->msg[reply->msg_cnt].msg_text = concat(str->str," ",trim(o_table->cons[ccnt].
          constraint_name)," has duplicates.")
       ENDIF
       cnt = (cnt+ 1), reply->msg[reply->msg_cnt].sub_cnt = cnt, stat = alterlist(reply->msg[reply->
        msg_cnt].sub,cnt),
       reply->msg[reply->msg_cnt].sub[cnt].sub_text = build(o_table->cons[c.seq].constraint_name)
      ENDIF
      o_table->cons[c.seq].dup_ind = 1
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
 SET i_max_cols = 0
 FOR (icnt = 1 TO o_table->ind_cnt)
   SET i_max_cols = greatest(i_max_cols,o_table->ind[icnt].col_cnt)
 ENDFOR
 FOR (icnt = 1 TO o_table->ind_cnt)
   IF ((o_table->ind[icnt].dup_ind=0))
    SET match_cols = 0
    SET diff_ind = 0
    SELECT INTO "nl:"
     iname = o_table->ind[c.seq].index_name
     FROM (dummyt c  WITH seq = value(o_table->ind_cnt)),
      (dummyt cc  WITH seq = value(i_max_cols)),
      (dummyt dc  WITH seq = value(o_table->ind[icnt].col_cnt))
     PLAN (c
      WHERE (o_table->ind[c.seq].index_name != o_table->ind[icnt].index_name))
      JOIN (cc
      WHERE (cc.seq <= o_table->ind[c.seq].col_cnt))
      JOIN (dc
      WHERE (o_table->ind[icnt].cols[dc.seq].column_name=o_table->ind[c.seq].cols[cc.seq].column_name
      )
       AND (o_table->ind[icnt].cols[dc.seq].column_pos=o_table->ind[c.seq].cols[cc.seq].column_pos))
     ORDER BY o_table->ind[c.seq].index_name, o_table->ind[c.seq].cols[cc.seq].column_pos
     HEAD REPORT
      diff_ind = 0, cnt = 0
     HEAD iname
      match_cols = 0
     DETAIL
      match_cols = (match_cols+ 1)
     FOOT  iname
      IF ((match_cols=o_table->ind[icnt].col_cnt)
       AND (match_cols=o_table->ind[c.seq].col_cnt))
       IF (diff_ind=0)
        diff_ind = 1, reply->msg_cnt = (reply->msg_cnt+ 1), stat = alterlist(reply->msg,reply->
         msg_cnt),
        reply->msg[reply->msg_cnt].sub_cnt = 0, stat = alterlist(reply->msg[reply->msg_cnt].sub,0),
        reply->msg[reply->msg_cnt].msg_text = concat("Index ",trim(o_table->ind[icnt].index_name),
         " has duplicates.")
       ENDIF
       cnt = (cnt+ 1), reply->msg[reply->msg_cnt].sub_cnt = cnt, stat = alterlist(reply->msg[reply->
        msg_cnt].sub,cnt),
       reply->msg[reply->msg_cnt].sub[cnt].sub_text = build(o_table->ind[c.seq].index_name)
      ENDIF
      o_table->ind[c.seq].dup_ind = 1
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
 IF ((reply->msg_cnt=0))
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 IF (dm_debug=1)
  CALL echo("***")
  CALL echorecord(reply)
  CALL echo("***")
 ENDIF
#end_program
END GO
