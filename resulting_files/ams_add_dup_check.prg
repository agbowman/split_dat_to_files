CREATE PROGRAM ams_add_dup_check
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select Audit/Commit" = "",
  "File Name:" = ""
  WITH outdev, auditcommit, filename
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed_mess = false
 SET table_name = fillstring(50," ")
 DECLARE ierrcode = i2 WITH protect, noconstant(0)
 DECLARE bamsassociate = i2 WITH protect, noconstant(false)
 DECLARE smessage = vc WITH protect, noconstant("")
 CALL echo("Entering ams add Duplicate Check")
 FREE RECORD rdata
 RECORD rdata(
   1 qual_knt = i4
   1 qual[*]
     2 object_name = vc
     2 user_name = vc
     2 compiled_dt_tm = vc
     2 source_name = vc
 )
 DECLARE application = vc
 DECLARE position = vc
 DECLARE level1 = vc
 DECLARE pref_name = vc
 DECLARE pref_value = vc
 FOR (i = 1 TO value(size(file_content->qual,5)))
   FREE RECORD request
   RECORD request(
     1 catalog_cd = f8
     1 dup_add_cnt = i4
     1 dup_upd_cnt = i4
     1 add_qual[*]
       2 dup_check_seq = i4
       2 exact_hit_action_cd = f8
       2 min_behind = i4
       2 min_behind_action_cd = f8
       2 min_ahead = i4
       2 min_ahead_action_cd = f8
       2 active_ind = i2
       2 outpat_flex_ind = i2
       2 outpat_min_behind = i4
       2 outpat_min_behind_action_cd = f8
       2 outpat_min_ahead = i4
       2 outpat_min_ahead_action_cd = f8
       2 outpat_exact_hit_action_cd = f8
   )
   SET stat = alterlist(request->add_qual,1)
   SET catalog = trim(file_content->qual[i].order_name)
   CALL echo(build2("Catalog is ",catalog))
   SELECT
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=200
     AND cv.display=catalog
    DETAIL
     CALL echo(cv.code_value), request->catalog_cd = cv.code_value
    WITH nocounter
   ;end select
   SET name = request->catalog_cd
   CALL echo(request->catalog_cd)
   SET request->add_qual[1].dup_check_seq = cnvtint(file_content->qual[i].dup_check_seq)
   SET exact_action = trim(file_content->qual[i].exact_action)
   SELECT
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=6001
     AND cv.display=exact_action
    DETAIL
     request->add_qual[1].exact_hit_action_cd = cv.code_value
    WITH nocounter
   ;end select
   SET request->add_qual[1].min_behind = cnvtint(file_content->qual[i].behind_min)
   SET behind_action = trim(file_content->qual[i].behind_action)
   SELECT
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=6001
     AND cv.display=behind_action
    DETAIL
     request->add_qual[1].min_behind_action_cd = cv.code_value
    WITH nocounter
   ;end select
   SET request->add_qual[1].min_ahead = cnvtint(file_content->qual[i].ahead_min)
   SET ahead_action = trim(file_content->qual[i].ahead_action)
   SELECT
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=6001
     AND cv.display=ahead_action
    DETAIL
     request->add_qual[1].min_ahead_action_cd = cv.code_value
    WITH nocounter
   ;end select
   SET request->add_qual[1].active_ind = cnvtint(file_content->qual[i].active)
   SET request->add_qual[1].outpat_flex_ind = cnvtint(file_content->qual[i].output_flex_indicator)
   SET request->add_qual[1].outpat_min_behind = cnvtint(file_content->qual[i].output_behind_min)
   SET outpat_min_behind_action = trim(file_content->qual[i].output_behind_action)
   SELECT
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=6001
     AND cv.display=outpat_min_behind_action
    DETAIL
     request->add_qual[1].outpat_min_behind_action_cd = cv.code_value
    WITH nocounter
   ;end select
   SET request->add_qual[1].outpat_min_ahead = cnvtint(file_content->qual[i].output_ahead_min)
   SET outpat_min_ahead_action = trim(file_content->qual[i].output_ahead_action)
   SELECT
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=6001
     AND cv.display=outpat_min_ahead_action
    DETAIL
     request->add_qual[1].outpat_min_ahead_action_cd = cv.code_value
    WITH nocounter
   ;end select
   SET outpat_exact_hit_action = trim(file_content->qual[i].output_exact_action)
   SELECT
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=6001
     AND cv.display=outpat_exact_hit_action
    DETAIL
     request->add_qual[1].outpat_exact_hit_action_cd = cv.code_value
    WITH nocounter
   ;end select
   SET request->dup_add_cnt = 1
   SET request->dup_upd_cnt = 0
   CALL echo("after loading request_details")
   CALL echorecord(request)
   EXECUTE orm_upd_oc_dup_check  WITH replace("REQUEST",request)
   CALL echo("Ending execution")
 ENDFOR
#exit_script
 SET script_ver = " 000 09/15/15 SS034541  Initial Release "
END GO
