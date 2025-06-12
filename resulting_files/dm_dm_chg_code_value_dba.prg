CREATE PROGRAM dm_dm_chg_code_value:dba
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
 SET authentic_cd = 0.00
 SET unauthentic_cd = 0.00
 SET x = 0
 SET authcnt = 0
 SET display_key_dup_ind = 0
 SET cdf_meaning_dup_ind = 0
 SET active_ind_dup_ind = 0
 SET display_dup_ind = 0
 SET alias_dup_ind = 0
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
  FROM dm_adm_code_value c
  WHERE c.code_set=8
   AND c.cdf_meaning IN ("AUTH", "UNAUTH")
   AND datetimediff(c.schema_date,cnvtdatetime(request->schema_date))=0
  ORDER BY c.cdf_meaning
  DETAIL
   IF (authcnt=0)
    authentic_cd = c.code_value, authcnt = 1
   ELSE
    unauthentic_cd = c.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET dm_code_value = 0.00
 FOR (x = 1 TO qual_size)
   SELECT INTO "nl:"
    a.code_value
    FROM dm_adm_code_value a
    WHERE (a.cki=request->qual[x].cki)
    DETAIL
     dm_code_value = a.code_value
    WITH nocounter
   ;end select
   IF (curqual=0)
    SELECT INTO "nl:"
     xyz = seq(dm_ref_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      dm_code_value = cnvtreal(xyz)
     WITH format, nocounter
    ;end select
   ENDIF
   SET cdf_cont = 1
   SET cv_del_ind = 0
   IF (trim(request->qual[x].cdf_meaning) != null)
    SELECT INTO "nl:"
     c.cdf_meaning, c.delete_ind
     FROM dm_adm_common_data_foundation c
     WHERE c.cdf_meaning=trim(request->qual[x].cdf_meaning)
      AND (c.code_set=request->code_set)
      AND datetimediff(c.schema_date,cnvtdatetime(request->schema_date))=0
     DETAIL
      cv_del_ind = c.delete_ind
     WITH nocounter
    ;end select
    IF (curqual > 0)
     SET cdf_cont = 1
    ELSE
     SET cdf_cont = 0
    ENDIF
   ENDIF
   IF (((cv_del_ind=1) OR ((request->qual[x].delete_ind=1))) )
    SET cv_del_ind = 1
   ENDIF
   IF (cdf_cont=1)
    INSERT  FROM dm_adm_code_value c
     SET c.code_value = dm_code_value, c.schema_date = cnvtdatetime(request->schema_date), c.code_set
       = request->code_set,
      c.cdf_meaning =
      IF (trim(request->qual[x].cdf_meaning) != null) request->qual[x].cdf_meaning
      ELSE null
      ENDIF
      , c.display = request->qual[x].display, c.display_key = trim(cnvtupper(cnvtalphanum(request->
         qual[x].display))),
      c.description = request->qual[x].description, c.definition = request->qual[x].definition, c.cki
       = request->qual[x].cki,
      c.collation_seq = request->qual[x].collation_seq, c.active_ind = request->qual[x].active_ind, c
      .active_type_cd =
      IF ((request->qual[x].active_ind=1)) reqdata->active_status_cd
      ELSE reqdata->inactive_status_cd
      ENDIF
      ,
      c.data_status_cd =
      IF ((request->qual[x].authentic_ind=1)) authentic_cd
      ELSE unauthentic_cd
      ENDIF
      , c.updt_id = reqinfo->updt_id, c.updt_applctx = reqinfo->updt_applctx,
      c.updt_cnt = 0, c.updt_task = reqinfo->updt_task, c.active_dt_tm =
      IF ((request->qual[x].active_ind=1)) cnvtdatetime(curdate,curtime3)
      ENDIF
      ,
      c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.begin_effective_dt_tm = cnvtdatetime(curdate,
       curtime3), c.end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00.00"),
      c.inactive_dt_tm =
      IF ((request->qual[x].active_ind=0)) cnvtdatetime(curdate,curtime3)
      ENDIF
      , c.delete_ind = cv_del_ind
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
    SET reply->qual[x].code_value = dm_code_value
    SET reply->qual[x].status = "C"
   ENDIF
   COMMIT
 ENDFOR
 SET reply->status_data.status = "S"
#exit_script
 COMMIT
END GO
