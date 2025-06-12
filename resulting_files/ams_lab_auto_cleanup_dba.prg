CREATE PROGRAM ams_lab_auto_cleanup:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
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
 SET script_failed = false
 SET table_name = fillstring(50," ")
 DECLARE serrmsg = vc WITH protect, noconstant("")
 DECLARE ierrcode = i2 WITH protect, noconstant(0)
 DECLARE bamsassociate = i2 WITH protect, noconstant(false)
 EXECUTE ams_define_toolkit_common
 SET bamsassociate = isamsuser(reqinfo->updt_id)
 IF ( NOT (bamsassociate))
  SET script_failed = exe_error
  SET serrmsg = "User must be a Cerner AMS associate to run this program from Explorer Menu"
  GO TO exit_script
 ENDIF
 DECLARE read_var = f8 WITH constant(uar_get_code_by("MEANING",29161,"READ")), protect
 DECLARE unread_var = f8 WITH constant(uar_get_code_by("MEANING",29161,"UNREAD")), protect
 RECORD review_items(
   1 qual[*]
     2 review_id = f8
 )
 SET cnt = 0
 SET numdelete = 0.0
 SET loopcnt = 0
 SET ucnt = 50000.0
 SELECT INTO "nl:"
  FROM pcs_queue_assignment pqa,
   pcs_review_item pri
  PLAN (pqa
   WHERE pqa.review_status_cd=unread_var
    AND pqa.pending_dt_tm BETWEEN cnvtlookbehind("1,M") AND cnvtdatetime(curdate,curtime3))
   JOIN (pri
   WHERE pqa.review_id=pri.review_id
    AND pri.pending_dt_tm BETWEEN cnvtlookbehind("1,M") AND cnvtdatetime(curdate,curtime3))
  ORDER BY pqa.review_id
  HEAD pqa.review_id
   cnt = (cnt+ 1), stat = alterlist(review_items->qual,cnt), review_items->qual[cnt].review_id = pri
   .review_id
  WITH nocounter
 ;end select
 SET numdelete = size(review_items->qual,5)
 SET loopcnt = round((numdelete/ ucnt),0)
 IF (numdelete=0)
  CALL echo(build(">>> !! No unread orders found.."))
 ELSE
  CALL echo(build(">>> No. of review items to update: ",numdelete))
  CALL echo(build("LoopCount-> ",loopcnt))
  IF (((numdelete/ ucnt) > loopcnt))
   SET loopcnt = (loopcnt+ 1)
   CALL echo(build(">>>Updated loopCnt: ",loopcnt))
  ENDIF
  SET uidxstart = 0
  SET uidxend = 0
  FOR (x = 1 TO loopcnt)
    SET uidxend = (uidxstart+ ucnt)
    UPDATE  FROM (dummyt d1  WITH seq = value(cnt)),
      pcs_review_item pri
     SET pri.review_status_cd = read_var, pri.updt_applctx = reqinfo->updt_applctx, pri.updt_task =
      reqinfo->updt_task,
      pri.updt_cnt = (pri.updt_cnt+ 1), pri.updt_id = reqinfo->updt_id, pri.updt_dt_tm = cnvtdatetime
      (curdate,curtime3)
     PLAN (d1
      WHERE d1.seq BETWEEN uidxstart AND uidxend)
      JOIN (pri
      WHERE (pri.review_id=review_items->qual[d1.seq].review_id))
     WITH nocounter
    ;end update
    UPDATE  FROM (dummyt d1  WITH seq = value(cnt)),
      pcs_queue_assignment pqa
     SET pqa.review_status_cd = read_var, pqa.updt_applctx = reqinfo->updt_applctx, pqa.updt_task =
      reqinfo->updt_task,
      pqa.updt_cnt = (pqa.updt_cnt+ 1), pqa.updt_id = reqinfo->updt_id, pqa.updt_dt_tm = cnvtdatetime
      (curdate,curtime3)
     PLAN (d1
      WHERE d1.seq BETWEEN uidxstart AND uidxend)
      JOIN (pqa
      WHERE (pqa.review_id=review_items->qual[d1.seq].review_id))
     WITH nocounter
    ;end update
    COMMIT
    SET uidxstart = uidxend
  ENDFOR
  CALL echo(">>> Updated and Comitted.....")
 ENDIF
#exit_script
 IF (script_failed != false)
  SELECT INTO value( $OUTDEV)
   message = trim(substring(1,200,serrmsg),3)
   FROM (dummyt d  WITH seq = 1)
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
 IF (script_failed != exe_error)
  CALL updtdminfo(trim(cnvtupper(curprog),3))
 ENDIF
END GO
