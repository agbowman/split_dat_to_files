CREATE PROGRAM ams_scd_cleanup_invalid_macro:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select the Username" = ""
  WITH outdev, username
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
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 SET readme_data->status = "F"
 SET readme_data->message = "Readme failed: starting script scd_cleanup_invalid_macros..."
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE st_preterm_cd = f8 WITH protect, noconstant(0.0)
 DECLARE st_author_id = f8 WITH protect, noconstant(0.0)
 DECLARE icount = i4 WITH protect, noconstant(0)
 FREE RECORD story
 RECORD story(
   1 story_idx[*]
     2 scd_story_id = f8
 )
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=15749
   AND cv.cdf_meaning="PRETERM"
   AND cv.active_ind=1
  DETAIL
   st_preterm_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM prsnl p
  WHERE p.username=value( $USERNAME)
   AND p.active_ind=1
  DETAIL
   st_author_id = p.person_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to perform a select query on code_value table: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT DISTINCT INTO "nl:"
  st.scd_story_id
  FROM scd_sentence se,
   scd_story st
  PLAN (st
   WHERE st.author_id=st_author_id
    AND st.story_type_cd=st_preterm_cd)
   JOIN (se
   WHERE se.scd_story_id=st.scd_story_id
    AND se.scr_term_hier_id=0.0)
  ORDER BY st.scd_story_id
  HEAD REPORT
   icount = 0
  HEAD st.scd_story_id
   icount = (icount+ 1)
   IF (mod(icount,10)=1)
    stat = alterlist(story->story_idx,(icount+ 9))
   ENDIF
   story->story_idx[icount].scd_story_id = st.scd_story_id
  FOOT REPORT
   IF (icount > 0)
    stat = alterlist(story->story_idx,icount)
   ENDIF
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to perform a select query on scd_story table : ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 IF (curqual=0)
  SET readme_data->status = "S"
  SET readme_data->message = "Success: 0 records qualified"
  GO TO exit_script
 ENDIF
 DELETE  FROM scd_term t,
   (dummyt d  WITH seq = value(icount))
  SET t.seq = 1
  PLAN (d)
   JOIN (t
   WHERE (t.scd_story_id=story->story_idx[d.seq].scd_story_id))
  WITH nocounter
 ;end delete
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to delete from scd_term table: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 DELETE  FROM scd_sentence s,
   (dummyt d  WITH seq = value(icount))
  SET s.seq = 1
  PLAN (d)
   JOIN (s
   WHERE (s.scd_story_id=story->story_idx[d.seq].scd_story_id))
  WITH nocounter
 ;end delete
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to delete from scd_sentence table: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 DELETE  FROM scd_paragraph p,
   (dummyt d  WITH seq = value(icount))
  SET p.seq = 1
  PLAN (d)
   JOIN (p
   WHERE (p.scd_story_id=story->story_idx[d.seq].scd_story_id))
  WITH nocounter
 ;end delete
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to delete from scd_paragragh table: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 DELETE  FROM scd_story_pattern ss,
   (dummyt d  WITH seq = value(icount))
  SET ss.seq = 1
  PLAN (d)
   JOIN (ss
   WHERE (ss.scd_story_id=story->story_idx[d.seq].scd_story_id))
  WITH nocounter
 ;end delete
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to delete from scd_story_pattern table: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 DELETE  FROM scd_story_org_reltn sso,
   (dummyt d  WITH seq = value(icount))
  SET sso.seq = 1
  PLAN (d)
   JOIN (sso
   WHERE (sso.scd_story_id=story->story_idx[d.seq].scd_story_id))
  WITH nocounter
 ;end delete
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to delete from scd_story_org_reltn table: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 DELETE  FROM scd_story sst,
   (dummyt d  WITH seq = value(icount))
  SET sst.seq = 1
  PLAN (d)
   JOIN (sst
   WHERE (sst.scd_story_id=story->story_idx[d.seq].scd_story_id))
  WITH nocounter
 ;end delete
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to delete from scd_story table: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Readme performed all required tasks"
 SELECT INTO  $OUTDEV
  FROM (dummyt d  WITH seq = 1)
  PLAN (d)
  HEAD REPORT
   col 5, "Invalid PowerNote Macro Settings for the User was Cleaned Up"
  WITH nocounter
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
 FREE RECORD story
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
