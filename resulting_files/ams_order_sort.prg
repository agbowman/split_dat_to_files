CREATE PROGRAM ams_order_sort
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "folder_name" = 0
  WITH outdev, folder_name
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
 DECLARE bamsassociate = i2 WITH protect, noconstant(false)
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
 FREE RECORD get_folder_request
 RECORD get_folder_request(
   1 alt_sel_category_id = f8
 )
 FREE RECORD temp_request
 RECORD temp_request(
   1 alt_sel_category_id = f8
   1 upd_asc_ind = i2
   1 short_description = vc
   1 long_description = vc
   1 child_cat_ind = i2
   1 owner_id = f8
   1 security_flag = i2
   1 updt_cnt = i4
   1 del_aos_ordsents_ind = i2
   1 aosadd_cnt = i4
   1 aosadd_qual[*]
     2 sequence = i4
     2 list_type = i4
     2 synonym_id = f8
     2 child_alt_sel_cat_id = f8
     2 order_sentence_id = f8
     2 pathway_catalog_id = f8
     2 pw_cat_synonym_id = f8
     2 regimen_cat_synonym_id = f8
   1 aosupd_cnt = i4
   1 aosupd_qual[*]
     2 sequence = i4
     2 list_type = i4
     2 synonym_id = f8
     2 child_alt_sel_cat_id = f8
     2 order_sentence_id = f8
     2 pathway_catalog_id = f8
     2 pw_cat_synonym_id = f8
     2 regimen_cat_synonym_id = f8
   1 aosdel_cnt = i4
   1 aosdel_qual[*]
     2 sequence = i4
 )
 CALL echorecord(get_folder_request)
 SET get_folder_request->alt_sel_category_id =  $FOLDER_NAME
 EXECUTE orm_get_aos_folder_contents:dba  WITH replace("REQUEST",get_folder_request), replace("REPLY",
  get_folder_reply)
 SELECT INTO "nl:"
  asl.alt_sel_category_id, ocs.mnemonic
  FROM alt_sel_list asl,
   alt_sel_cat ascat,
   order_catalog_synonym ocs
  PLAN (asl
   WHERE (asl.alt_sel_category_id= $FOLDER_NAME))
   JOIN (ascat
   WHERE ascat.alt_sel_category_id=asl.alt_sel_category_id)
   JOIN (ocs
   WHERE ocs.synonym_id=asl.synonym_id)
  ORDER BY ocs.mnemonic_key_cap
  HEAD asl.alt_sel_category_id
   temp_request->alt_sel_category_id = ascat.alt_sel_category_id, temp_request->short_description =
   ascat.short_description, temp_request->long_description = ascat.long_description,
   temp_request->child_cat_ind = ascat.child_cat_ind, temp_request->owner_id = ascat.owner_id,
   temp_request->security_flag = ascat.security_flag,
   temp_request->updt_cnt = ascat.updt_cnt, temp_request->aosdel_cnt = 0, temp_request->aosupd_cnt =
   0,
   temp_request->aosadd_cnt = 0, cnt = 0,
   CALL echo(temp_request->alt_sel_category_id),
   CALL echo("samm")
  HEAD ocs.mnemonic
   cnt = (cnt+ 1)
   IF (mod(cnt,25)=1)
    stat = alterlist(temp_request->aosadd_qual,(cnt+ 24))
   ENDIF
   temp_request->aosadd_qual[cnt].sequence = cnt, temp_request->aosadd_qual[cnt].list_type = asl
   .list_type, temp_request->aosadd_qual[cnt].synonym_id = asl.synonym_id,
   temp_request->aosadd_qual[cnt].child_alt_sel_cat_id = asl.child_alt_sel_cat_id, temp_request->
   aosadd_qual[cnt].order_sentence_id = asl.order_sentence_id, temp_request->aosadd_qual[cnt].
   pathway_catalog_id = asl.pathway_catalog_id,
   temp_request->aosadd_qual[cnt].pw_cat_synonym_id = asl.pw_cat_synonym_id
  FOOT  asl.alt_sel_category_id
   stat = alterlist(temp_request->aosadd_qual,cnt), temp_request->aosadd_cnt = cnt,
   CALL echorecord(temp_request),
   CALL echo("calling standard script now")
 ;end select
 EXECUTE orm_upd_aos_cat_info:dba  WITH replace("REQUEST",temp_request)
 SELECT INTO  $OUTDEV
  status = "Orders Are Sucessfully Sorted"
  FROM dummyt d1
  WITH nocounter, format
 ;end select
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
END GO
