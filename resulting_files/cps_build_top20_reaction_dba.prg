CREATE PROGRAM cps_build_top20_reaction:dba
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
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 FREE RECORD reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD hold
 RECORD hold(
   1 qual_knt = i4
   1 qual[*]
     2 user_id = f8
     2 nomen_category_id = f8
     2 nomen_knt = i4
     2 nomen[*]
       3 item_knt = i4
       3 nomen_id = f8
 )
 FREE RECORD hold_top20
 RECORD hold_top20(
   1 qual_knt = i4
   1 qual[*]
     2 nomen_cat_list_id = f8
     2 nomen_id = f8
     2 list_sequence = i4
     2 item_knt = i4
 )
 FREE RECORD anchor
 RECORD anchor(
   1 dt_tm = dq8
 )
 SET code_value = 0.0
 SET code_set = 0
 SET cdf_meaning = fillstring(12," ")
 SET reaction_cd = 0.0
 SET stat = false
 SET low_knt = 5
 IF ((request->days_back < 1))
  SET anchor->dt_tm = datetimeadd(cnvtdatetime(curdate,curtime3),- (90))
 ELSE
  SET anchor->dt_tm = datetimeadd(cnvtdatetime(curdate,curtime3),request->days_back)
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM app_prefs ap,
   name_value_prefs nvp
  PLAN (ap
   WHERE ap.prsnl_id=0.0
    AND ap.position_cd=0.0
    AND ap.application_number=961000
    AND ap.active_ind=true)
   JOIN (nvp
   WHERE nvp.parent_entity_id=ap.app_prefs_id
    AND nvp.parent_entity_name="APP_PREFS"
    AND nvp.pvc_name="TOP20_REACTION_COUNT")
  HEAD REPORT
   low_knt = cnvtint(nvp.pvc_value)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "NAME_VALUE_PREFS"
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  item_knt = count(r.reaction_id), r.updt_id, r.reaction_nom_id
  FROM reaction r
  PLAN (r
   WHERE r.updt_id > 0
    AND r.reaction_nom_id > 0
    AND r.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND r.beg_effective_dt_tm >= cnvtdatetime(anchor->dt_tm)
    AND r.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND r.active_ind=true)
  GROUP BY r.updt_id, r.reaction_nom_id
  HAVING count(r.reaction_nom_id) >= low_knt
  ORDER BY r.updt_id, item_knt DESC
  HEAD REPORT
   knt = 0, stat = alterlist(hold->qual,10)
  HEAD r.updt_id
   knt = (knt+ 1)
   IF (mod(knt,10)=1
    AND knt != 1)
    stat = alterlist(hold->qual,(knt+ 9))
   ENDIF
   20_knt = 0, nknt = 0, hold->qual[knt].user_id = r.updt_id,
   stat = alterlist(hold->qual[knt].nomen,10)
  DETAIL
   20_knt = (20_knt+ 1)
   IF (20_knt <= 20)
    nknt = (nknt+ 1)
    IF (mod(nknt,10)=1
     AND nknt != 1)
     stat = alterlist(hold->qual[knt].nomen,(nknt+ 9))
    ENDIF
    hold->qual[knt].nomen[nknt].nomen_id = r.reaction_nom_id, hold->qual[knt].nomen[nknt].item_knt =
    item_knt
   ENDIF
  FOOT  r.updt_id
   hold->qual[knt].nomen_knt = nknt, stat = alterlist(hold->qual[knt].nomen,nknt)
  FOOT REPORT
   hold->qual_knt = knt, stat = alterlist(hold->qual,knt)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "REACTION"
  GO TO exit_script
 ENDIF
 IF ((hold->qual_knt < 1))
  GO TO exit_script
 ENDIF
 SET code_value = 0.0
 SET code_set = 25321
 SET cdf_meaning = "REACTION"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,reaction_cd)
 IF (stat > 0)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = concat("Failed to find the code_value for ",trim(cdf_meaning)," on code_set ",trim(
    cnvtstring(code_set)))
  GO TO exit_script
 ENDIF
 CALL echo("***")
 CALL echo(build("***   REACTION CODE :",reaction_cd))
 CALL echo("***")
 FOR (i = 1 TO hold->qual_knt)
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   SELECT INTO "nl:"
    FROM nomen_category nc
    PLAN (nc
     WHERE nc.parent_entity_name="PRSNL"
      AND (nc.parent_entity_id=hold->qual[i].user_id)
      AND nc.category_type_cd=reaction_cd
      AND nc.category_name="TOP_20_REACTION")
    DETAIL
     hold->qual[i].nomen_category_id = nc.nomen_category_id
    WITH nocounter
   ;end select
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = select_error
    SET table_name = "NOMEN_CATEGORY"
    GO TO exit_script
   ENDIF
   IF (curqual < 1)
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    SELECT INTO "nl:"
     nextseqnum = seq(nomenclature_seq,nextval)
     FROM dual
     DETAIL
      hold->qual[i].nomen_category_id = cnvtreal(nextseqnum)
     WITH format, nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = gen_nbr_error
     SET table_name = "NOMENCLATURE_SEQ"
     GO TO exit_script
    ENDIF
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    INSERT  FROM nomen_category nc
     SET nc.nomen_category_id = hold->qual[i].nomen_category_id, nc.category_name = "TOP_20_REACTION",
      nc.category_type_cd = reaction_cd,
      nc.parent_entity_name = "PRSNL", nc.parent_entity_id = hold->qual[i].user_id, nc.updt_cnt = 0,
      nc.updt_dt_tm = cnvtdatetime(curdate,curtime3), nc.updt_applctx = reqinfo->updt_applctx, nc
      .updt_id = reqinfo->updt_id,
      nc.updt_task = reqinfo->updt_task
     PLAN (nc
      WHERE 0=0)
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = insert_error
     SET table_name = "NOMEN_CATEGORY"
     GO TO exit_script
    ENDIF
    IF ((hold->qual[i].nomen_knt > 0))
     FOR (j = 1 TO hold->qual[i].nomen_knt)
       SET ierrcode = error(serrmsg,1)
       SET ierrcode = 0
       SET nomen_cat_list_id = 0.0
       SELECT INTO "nl:"
        nextseqnum = seq(nomenclature_seq,nextval)
        FROM dual
        DETAIL
         nomen_cat_list_id = cnvtreal(nextseqnum)
        WITH format, nocounter
       ;end select
       SET ierrcode = error(serrmsg,1)
       IF (ierrcode > 0)
        SET failed = gen_nbr_error
        SET table_name = "NOMENCLATURE_SEQ"
        GO TO exit_script
       ENDIF
       INSERT  FROM nomen_cat_list ncl
        SET ncl.nomen_cat_list_id = nomen_cat_list_id, ncl.parent_category_id = hold->qual[i].
         nomen_category_id, ncl.child_category_id = 0.0,
         ncl.nomenclature_id = hold->qual[i].nomen[j].nomen_id, ncl.list_sequence = j, ncl.child_flag
          = 2,
         ncl.updt_cnt = hold->qual[i].nomen[j].item_knt, ncl.updt_dt_tm = cnvtdatetime(curdate,
          curtime3), ncl.updt_applctx = reqinfo->updt_applctx,
         ncl.updt_id = reqinfo->updt_id, ncl.updt_task = reqinfo->updt_task
        PLAN (ncl
         WHERE 0=0)
        WITH nocounter
       ;end insert
       SET ierrcode = error(serrmsg,1)
       IF (ierrcode > 0)
        SET failed = insert_error
        SET table_name = "NOMEN_CAT_LIST"
        GO TO exit_script
       ENDIF
     ENDFOR
    ENDIF
    COMMIT
   ENDIF
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   DELETE  FROM nomen_cat_list ncl
    PLAN (ncl
     WHERE (ncl.parent_category_id=hold->qual[i].nomen_category_id))
    WITH nocounter
   ;end delete
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = delete_error
    SET table_name = "NOMEN_CAT_LIST"
    GO TO exit_script
   ENDIF
   IF ((hold->qual[i].nomen_knt > 0))
    FOR (j = 1 TO hold->qual[i].nomen_knt)
      SET ierrcode = error(serrmsg,1)
      SET ierrcode = 0
      SET nomen_cat_list_id = 0.0
      SELECT INTO "nl:"
       nextseqnum = seq(nomenclature_seq,nextval)
       FROM dual
       DETAIL
        nomen_cat_list_id = cnvtreal(nextseqnum)
       WITH format, nocounter
      ;end select
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET failed = gen_nbr_error
       SET table_name = "NOMENCLATURE_SEQ"
       GO TO exit_script
      ENDIF
      INSERT  FROM nomen_cat_list ncl
       SET ncl.nomen_cat_list_id = nomen_cat_list_id, ncl.parent_category_id = hold->qual[i].
        nomen_category_id, ncl.child_category_id = 0.0,
        ncl.nomenclature_id = hold->qual[i].nomen[j].nomen_id, ncl.list_sequence = j, ncl.child_flag
         = 2,
        ncl.updt_cnt = hold->qual[i].nomen[j].item_knt, ncl.updt_dt_tm = cnvtdatetime(curdate,
         curtime3), ncl.updt_applctx = reqinfo->updt_applctx,
        ncl.updt_id = reqinfo->updt_id, ncl.updt_task = reqinfo->updt_task
       PLAN (ncl
        WHERE 0=0)
       WITH nocounter
      ;end insert
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET failed = insert_error
       SET table_name = "NOMEN_CAT_LIST"
       GO TO exit_script
      ENDIF
    ENDFOR
   ENDIF
   COMMIT
 ENDFOR
#exit_script
 IF (failed != false)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  IF (failed=select_error)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSEIF (failed=insert_error)
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSEIF (failed=input_error)
   SET reply->status_data.subeventstatus[1].operationname = "VALIDATION"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSE
   SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ENDIF
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET script_version = "000 02/08/01 SF3151"
END GO
