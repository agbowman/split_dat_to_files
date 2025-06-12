CREATE PROGRAM afc_collection_setup:dba
 IF ((validate(request->nbr_of_recs,- (1))=- (1)))
  RECORD request(
    1 nbr_of_recs = i4
    1 qual[*]
      2 action = i2
      2 ext_id = f8
      2 ext_contributor_cd = f8
      2 parent_qual_ind = f8
      2 ext_owner_cd = f8
      2 ext_description = c100
      2 workload_only_ind = i2
      2 ext_short_desc = c50
      2 careset_ind = i2
      2 price_qual = i2
      2 prices[*]
        3 price_sched_id = f8
        3 price = f8
      2 billcode_qual = i2
      2 billcodes[*]
        3 billcode_sched_cd = f8
        3 billcode = c25
      2 child_qual = i2
      2 children[*]
        3 ext_id = f8
        3 ext_contributor_cd = f8
        3 ext_description = c100
        3 ext_short_desc = c50
        3 ext_owner_cd = f8
  )
 ENDIF
 RECORD reply(
   1 bill_item_qual = i4
   1 bill_item[*]
     2 bill_item_id = f8
   1 qual[*]
     2 bill_item_id = f8
   1 price_sched_items_qual = i2
   1 price_sched_items[*]
     2 price_sched_id = f8
     2 price_sched_items_id = f8
   1 bill_item_modifier_qual = i2
   1 bill_item_modifier[10]
     2 bill_item_mod_id = f8
   1 actioncnt = i2
   1 actionlist[*]
     2 action1 = vc
     2 action2 = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c20
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RECORD coll_type_cs(
   1 coll_type_qual = i4
   1 coll_type[*]
     2 code_value = f8
     2 display = c40
 )
 CALL echo("*****PM_HEADER_CCL.inc - 668615****")
 IF ((validate(gen_nbr_error,- (9))=- (9)))
  DECLARE gen_nbr_error = i2 WITH constant(3)
 ENDIF
 IF ((validate(insert_error,- (9))=- (9)))
  DECLARE insert_error = i2 WITH constant(4)
 ENDIF
 IF ((validate(update_error,- (9))=- (9)))
  DECLARE update_error = i2 WITH constant(5)
 ENDIF
 IF ((validate(replace_error,- (9))=- (9)))
  DECLARE replace_error = i2 WITH constant(6)
 ENDIF
 IF ((validate(delete_error,- (9))=- (9)))
  DECLARE delete_error = i2 WITH constant(7)
 ENDIF
 IF ((validate(undelete_error,- (9))=- (9)))
  DECLARE undelete_error = i2 WITH constant(8)
 ENDIF
 IF ((validate(remove_error,- (9))=- (9)))
  DECLARE remove_error = i2 WITH constant(9)
 ENDIF
 IF ((validate(attribute_error,- (9))=- (9)))
  DECLARE attribute_error = i2 WITH constant(10)
 ENDIF
 IF ((validate(lock_error,- (9))=- (9)))
  DECLARE lock_error = i2 WITH constant(11)
 ENDIF
 IF ((validate(none_found,- (9))=- (9)))
  DECLARE none_found = i2 WITH constant(12)
 ENDIF
 IF ((validate(select_error,- (9))=- (9)))
  DECLARE select_error = i2 WITH constant(13)
 ENDIF
 IF ((validate(add_history_error,- (9))=- (9)))
  DECLARE add_history_error = i2 WITH constant(14)
 ENDIF
 IF ((validate(transaction_error,- (9))=- (9)))
  DECLARE transaction_error = i2 WITH constant(15)
 ENDIF
 IF ((validate(none_found_ft,- (9))=- (9)))
  DECLARE none_found_ft = i2 WITH constant(16)
 ENDIF
 IF ((validate(failed,- (9))=- (9)))
  DECLARE failed = i2 WITH noconstant(false)
 ENDIF
 IF (validate(table_name,"ZZZ")="ZZZ")
  DECLARE table_name = vc WITH noconstant("")
  SET table_name = fillstring(50," ")
 ENDIF
 SET serrmsg = fillstring(132," ")
 SET reply->status_data.status = "F"
 SET specimen_codeset = 2052
 SET collection_type_codeset = 2058
 SET ext_owner_codeset = 106
 SET ext_owner_gen_lab = "GLB"
 SET ext_contrib_codeset = 13016
 SET ext_contrib_specimen = "SPECIMEN"
 SET ext_contrib_collection_type = "COLL TYPE"
 SET g_code_value = 0
 SET g_status_code_active = 0
 SET g_specimen_cd = 0.0
 SET g_specimen_disp = fillstring(40," ")
 SET g_collection_type_cd = 0.0
 SET g_collection_type_disp = fillstring(40," ")
 SET g_owner_cd = 0.0
#main
 SET failed = false
 SET log_handle = 0
 SET log_status = 0
 CALL log_createhandle(0)
 CALL log_message("Begin.")
 CALL get_contrib_codes(0)
 CALL get_owner_code(0)
 CALL load_items(0)
 CALL log_message("Done.")
 CALL log_destroyhandle(0)
 GO TO end_program
 CALL get_coll_type(0)
 IF (failed=false)
  CALL get_contrib_codes(0)
 ENDIF
 IF (failed=false)
  CALL get_owner_code(0)
 ENDIF
 IF (failed=false)
  CALL get_specimens(0)
 ENDIF
 IF (failed=false)
  EXECUTE afc_add_reference_api
 ENDIF
 CALL check_error(0)
#main_exit
 GO TO end_program
 SUBROUTINE load_items(dummy)
   DECLARE done_ind = i4 WITH protect, noconstant(0)
   DECLARE spec_cnt = i4 WITH protect, noconstant(0)
   DECLARE coll_cnt = i4 WITH protect, noconstant(0)
   DECLARE tot_spec_cnt = i4 WITH protect, noconstant(0)
   DECLARE tot_coll_cnt = i4 WITH protect, noconstant(0)
   DECLARE total_cnt = i4 WITH protect, noconstant(0)
   DECLARE total_load = i4 WITH protect, noconstant(0)
   DECLARE last_spec = f8 WITH protect, noconstant(0.0)
   SET done_ind = 0
   SET spec_cnt = 0
   SET coll_cnt = 0
   SET tot_spec_cnt = 0
   SET tot_coll_cnt = 0
   SET total_cnt = 0
   SET total_load = 0
   FREE DEFINE spec_cs
   FREE DEFINE coll_cs
   SELECT INTO TABLE spec_cs
    cv.code_value, cv.display
    FROM code_value cv
    WHERE cv.code_set=specimen_codeset
     AND cv.active_ind=1
    ORDER BY cv.code_value
    WITH nocounter
   ;end select
   SET tot_spec_cnt = curqual
   CALL log_message(build(tot_spec_cnt," specimens to load."))
   SELECT INTO TABLE coll_cs
    cv.code_value, cv.display
    FROM code_value cv
    WHERE cv.code_set=collection_type_codeset
     AND cv.active_ind=1
    ORDER BY cv.code_value
    WITH nocounter
   ;end select
   SET tot_coll_cnt = curqual
   CALL log_message(build(tot_coll_cnt," collection types."))
   SET total_cnt = (tot_spec_cnt * tot_coll_cnt)
   CALL log_message(build(total_cnt," total bill items."))
   SET last_spec = 0
   WHILE (done_ind=0)
     SET spec_cnt = 0
     SET coll_cnt = 0
     SELECT INTO "nl:"
      sc.code_value, sc.display, cc.code_value,
      cc.display
      FROM spec_cs sc,
       coll_cs cc
      PLAN (sc
       WHERE sc.code_value > last_spec)
       JOIN (cc)
      HEAD sc.code_value
       spec_cnt += 1, last_spec = sc.code_value, request->nbr_of_recs = spec_cnt,
       stat = alterlist(request->qual,spec_cnt), request->qual[spec_cnt].ext_id = sc.code_value,
       request->qual[spec_cnt].ext_contributor_cd = g_specimen_cd,
       request->qual[spec_cnt].parent_qual_ind = 1, request->qual[spec_cnt].ext_owner_cd = g_owner_cd,
       request->qual[spec_cnt].ext_description = concat("SPECIMEN: ",sc.display),
       request->qual[spec_cnt].ext_short_desc = sc.display, coll_cnt = 0, col 0,
       sc.display, row + 1
      DETAIL
       coll_cnt += 1, request->qual[spec_cnt].child_qual = coll_cnt, stat = alterlist(request->qual[
        spec_cnt].children,coll_cnt),
       request->qual[spec_cnt].children[coll_cnt].ext_id = cc.code_value, request->qual[spec_cnt].
       children[coll_cnt].ext_contributor_cd = g_collection_type_cd, request->qual[spec_cnt].
       children[coll_cnt].ext_description = concat("COLLECTION: ",cc.display),
       request->qual[spec_cnt].children[coll_cnt].ext_short_desc = cc.display, request->qual[spec_cnt
       ].children[coll_cnt].ext_owner_cd = g_owner_cd, col 10,
       cc.display, row + 1
      WITH maxqual(sc,25)
     ;end select
     EXECUTE afc_add_reference_api
     COMMIT
     SET total_load += (spec_cnt * coll_cnt)
     CALL log_message(concat(trim(cnvtstring(total_load),3)," of ",trim(cnvtstring(total_cnt),3),
       " bill items loaded."))
     IF (spec_cnt < 25)
      CALL echo("done.")
      SET done_ind = 1
     ENDIF
   ENDWHILE
   SET clean = remove("spec_cs.dat")
   SET clean = remove("coll_cs.dat")
 END ;Subroutine
 SUBROUTINE get_coll_type(l_dummy)
   CALL echo("inside GET_COLL_TYPE")
   SET table_name = "code_value"
   SET count = 0
   SELECT INTO "nl:"
    cv.code_value, cv.display
    FROM code_value cv
    WHERE cv.code_set=collection_type_codeset
     AND cv.active_ind=1
    HEAD REPORT
     stat = alterlist(coll_type_cs->coll_type,10)
    DETAIL
     count += 1
     IF (mod(count,10)=1
      AND count != 1)
      stat = alterlist(coll_type_cs->coll_type,(count+ 10))
     ENDIF
     coll_type_cs->coll_type[count].code_value = cv.code_value, coll_type_cs->coll_type[count].
     display = cv.display
    WITH nocounter
   ;end select
   SET stat = alterlist(coll_type_cs->coll_type,count)
   SET coll_type_cs->coll_type_qual = count
   IF (curqual=0)
    SET failed = select_error
    SET reply->status_data.subeventstatus[1].operationname = "Select"
    SET reply->status_data.subeventstatus[1].operationstatus = "s"
    SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "CODE_VALUE1"
    SET reply->status_data.status = "Z"
   ENDIF
 END ;Subroutine
 SUBROUTINE get_contrib_codes(l_dummy)
   CALL echo("inside GET_CONTRIB_CODES")
   SET table_name = "code_value"
   SELECT INTO "nl:"
    cv.code_value, cv.display, cv.cdf_meaning
    FROM code_value cv
    WHERE cv.code_set=ext_contrib_codeset
     AND cv.cdf_meaning IN (ext_contrib_specimen, ext_contrib_collection_type)
     AND cv.active_ind=true
    DETAIL
     IF (cv.cdf_meaning=ext_contrib_specimen)
      g_specimen_cd = cv.code_value, g_specimen_disp = cv.display
     ELSEIF (cv.cdf_meaning=ext_contrib_collection_type)
      g_collection_type_cd = cv.code_value, g_collection_type_disp = cv.display
     ELSE
      CALL echo("Could not find correct contributor codes"), failed = true
     ENDIF
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET failed = select_error
    SET reply->status_data.subeventstatus[1].operationname = "Select"
    SET reply->status_data.subeventstatus[1].operationstatus = "s"
    SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "CODE_VALUE2"
    SET reply->status_data.status = "Z"
   ENDIF
 END ;Subroutine
 SUBROUTINE get_owner_code(l_dummy)
   CALL echo("inside GET_OWNER_CODE")
   SET table_name = "code_value"
   SELECT INTO "nl:"
    cv.code_value, cv.display, cv.cdf_meaning
    FROM code_value cv
    WHERE cv.code_set=ext_owner_codeset
     AND cv.cdf_meaning=ext_owner_gen_lab
     AND cv.active_ind=true
    DETAIL
     g_owner_cd = cv.code_value
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET failed = select_error
    SET reply->status_data.subeventstatus[1].operationname = "Select"
    SET reply->status_data.subeventstatus[1].operationstatus = "s"
    SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "CODE_VALUE3"
    SET reply->status_data.status = "Z"
   ENDIF
 END ;Subroutine
 SUBROUTINE get_specimens(l_dummy)
   CALL echo("inside GET_SPECIMENS")
   SET count = 0
   SET i = 0
   SELECT INTO "nl:"
    cv.code_value, cv.display
    FROM code_value cv
    WHERE cv.code_set=specimen_codeset
     AND cv.active_ind=1
    HEAD REPORT
     stat = alterlist(request->qual,10)
    DETAIL
     count += 1
     IF (mod(count,10)=1
      AND count != 1)
      stat = alterlist(request->qual,(count+ 10))
     ENDIF
     request->qual[count].action = 1, request->qual[count].ext_id = cv.code_value, request->qual[
     count].ext_contributor_cd = g_specimen_cd,
     request->qual[count].parent_qual_ind = 1, request->qual[count].ext_owner_cd = g_owner_cd,
     request->qual[count].ext_description = concat("SPECIMEN:",cv.display),
     request->qual[count].ext_short_desc = cv.display, request->qual[count].ext_short_desc = cv
     .display, request->qual[count].child_qual = coll_type_cs->coll_type_qual,
     stat = alterlist(request->qual[count].children,coll_type_cs->coll_type_qual)
     FOR (i = 1 TO coll_type_cs->coll_type_qual)
       request->qual[count].children[i].ext_id = coll_type_cs->coll_type[i].code_value, request->
       qual[count].children[i].ext_contributor_cd = g_collection_type_cd, request->qual[count].
       children[i].ext_description = concat("COLLECTION:",coll_type_cs->coll_type[i].display),
       request->qual[count].children[i].ext_short_desc = coll_type_cs->coll_type[i].display, request
       ->qual[count].children[i].ext_owner_cd = g_owner_cd
     ENDFOR
    WITH nocounter
   ;end select
   SET stat = alterlist(request->qual,count)
   SET request->nbr_of_recs = count
   IF (curqual=0)
    SET failed = select_error
    SET reply->status_data.subeventstatus[1].operationname = "Select"
    SET reply->status_data.subeventstatus[1].operationstatus = "s"
    SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "CODE_VALUE4"
    SET reply->status_data.status = "Z"
   ENDIF
 END ;Subroutine
 SUBROUTINE dump_request(l_dummy)
   CALL echo("inside DUMP_REQUEST")
   SET i = 0
   SET j = 0
   FOR (i = 1 TO cnvtint(request->nbr_of_recs))
    CALL echo(build("Parent==>"," ext_id: ",request->qual[i].ext_id," ext_contributor_cd: ",request->
      qual[i].ext_contributor_cd,
      " ext_description:",request->qual[i].ext_description," ext_short_desc:",request->qual[i].
      ext_short_desc," ext_owner_cd: ",
      request->qual[i].ext_owner_cd))
    FOR (j = 1 TO request->qual[i].child_qual)
      CALL echo(build("Child===>"," ext_id: ",request->qual[i].children[j].ext_id,
        " ext_contributor_cd: ",request->qual[i].children[j].ext_contributor_cd,
        " ext_description: ",request->qual[i].children[j].ext_description," ext_short_desc: ",request
        ->qual[i].children[j].ext_short_desc," ext_owner_cd: ",
        request->qual[i].children[j].ext_owner_cd))
    ENDFOR
   ENDFOR
 END ;Subroutine
 SUBROUTINE check_error(l_dummy)
   IF (failed=false)
    SET reply->status_data.status = "S"
    SET reqinfo->commit_ind = true
   ELSE
    CASE (failed)
     OF gen_nbr_error:
      SET reply->status_data.subeventstatus[1].operationname = "GEN_NBR"
     OF insert_error:
      SET reply->status_data.subeventstatus[1].operationname = "INSERT"
     OF update_error:
      SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
     OF replace_error:
      SET reply->status_data.subeventstatus[1].operationname = "REPLACE"
     OF delete_error:
      SET reply->status_data.subeventstatus[1].operationname = "DELETE"
     OF undelete_error:
      SET reply->status_data.subeventstatus[1].operationname = "UNDELETE"
     OF remove_error:
      SET reply->status_data.subeventstatus[1].operationname = "REMOVE"
     OF attribute_error:
      SET reply->status_data.subeventstatus[1].operationname = "ATTRIBUTE"
     OF lock_error:
      SET reply->status_data.subeventstatus[1].operationname = "LOCK"
     ELSE
      SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
    ENDCASE
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = table_name
    SET reqinfo->commit_ind = false
    SET reply->status_data.subeventstatus[2].targetobjectname = "CCL_ERROR"
    SET reply->status_data.subeventstatus[2].targetobjectvalue = serrmsg
    SET reply->status_data.subeventstatus[2].operationname = "RECEIVE"
    SET reply->status_data.subeventstatus[2].operationstatus = "S"
   ENDIF
 END ;Subroutine
#end_program
 SUBROUTINE log_createhandle(dummy)
   CALL uar_syscreatehandle(log_handle,log_status)
 END ;Subroutine
 SUBROUTINE log_message(log_message_message)
   IF (log_handle != 0)
    CALL uar_sysevent(log_handle,2,"AFC_COLLECTION_SETUP",nullterm(log_message_message))
    CALL echo(log_message_message)
   ENDIF
 END ;Subroutine
 SUBROUTINE log_destroyhandle(dummy)
   CALL uar_sysdestroyhandle(log_handle)
 END ;Subroutine
 FREE SET coll_type_cs
END GO
