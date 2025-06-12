CREATE PROGRAM chart_focus_content_install:dba
 FREE RECORD refreshreply
 RECORD refreshreply(
   1 requesturi = vc
   1 params = vc
   1 responsecode = i4
   1 responsetext = vc
   1 responsebody = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD installedreleases
 RECORD installedreleases(
   1 release[*]
     2 release_ident = vc
 )
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
 DECLARE validrevisioncheck(rev1=i4,rev2=i4,rev3=i4,funcname=vc) = i2
 SUBROUTINE validrevisioncheck(rev1,rev2,rev3,funcname)
   CALL echo(concat("Validating CCL Version for ",funcname))
   DECLARE targetrev = i4
   DECLARE systemrev = i4
   SET targetrev = (rev1 * 1000)
   SET targetrev = (targetrev+ (rev2 * 100))
   SET targetrev = (targetrev+ rev3)
   SET systemrev = (currev * 1000)
   SET systemrev = (systemrev+ (currevminor * 100))
   IF ((validate(currevminor2,- (1))=- (1)))
    IF ((validate(currdblink,- (1)) != - (1)))
     SET systemrev = (systemrev+ 13)
    ELSE
     IF ((validate(cursource,- (1)) != - (1)))
      SET systemrev = (systemrev+ 11)
     ELSE
      IF ((validate(curutc,- (1)) != - (1)))
       SET systemrev = (systemrev+ 9)
      ELSE
       IF ((validate(curreturn,- (1)) != - (1)))
        SET systemrev = (systemrev+ 5)
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ELSE
    SET systemrev = (systemrev+ currevminor2)
   ENDIF
   IF (targetrev <= systemrev)
    SELECT INTO "nl:"
     FROM dm_info
     WHERE info_domain="Readme CCL Revision Check"
      AND info_name="Validate Prior CCL Revision Execution Paths"
      AND info_char="AC010168 for Full Execution Path Testing In House"
     WITH nocounter
    ;end select
    IF (curqual=0)
     CALL echo(concat("The System is Capabale of Using ",funcname))
     RETURN(1)
    ELSE
     CALL echo(concat("The System is Capabale of Using ",funcname,
       " but will not for Testing Purposes."))
     RETURN(0)
    ENDIF
   ELSE
    CALL echo(concat("The System's CCL Revision does not Support ",funcname))
    RETURN(0)
   ENDIF
 END ;Subroutine
 SET readme_data->status = "F"
 SET readme_data->message = "Readme failure: Starting Script chart_focus_content_install.prg"
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE indx = i4 WITH protect, noconstant(1)
 DECLARE releasecount = i4 WITH protect, noconstant(0)
 CALL echo("Starting chart_focus_content_install")
 IF (validrevisioncheck(8,5,5,"cnvtjsontorec")=0)
  SET readme_data->status = "S"
  SET readme_data->message =
  "Readme auto-success: CCL version 8.5.5 required for ReadMe execution due to the use of cnvtrectojson and cnvtjsontorec"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM mp_release mr,
   mp_group mg
  PLAN (mr
   WHERE mr.release_ident IN ("MPAGES_6_0", "MPAGES_6_1", "MPAGES_6_2", "MPAGES_6_3", "MPAGES_6_4",
   "MPAGES_6_5", "MPAGES_6_6", "MPAGES_6_7", "MPAGES_6_8"))
   JOIN (mg
   WHERE mg.mp_release_id=mr.mp_release_id
    AND mg.group_type="BASE")
  DETAIL
   releasecount = (releasecount+ 1), stat = alterlist(installedreleases->release,releasecount),
   installedreleases->release[releasecount].release_ident = mr.release_ident
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Error retrieving MPages Release details from the MP_RELEASE table: ",errmsg)
  CALL echo("Error retrieving MPages Release details from the MP_RELEASE table")
  GO TO exit_script
 ENDIF
 DECLARE releasejson = vc WITH protect, noconstant("")
 FOR (indx = 1 TO releasecount)
   SET stat = initrec(refreshreply)
   CASE (installedreleases->release[indx].release_ident)
    OF "MPAGES_6_0":
     SET releasejson = "mpages-6-0.json"
    OF "MPAGES_6_1":
     SET releasejson = "mpages-6-1.json"
    OF "MPAGES_6_2":
     SET releasejson = "mpages-6-2.json"
    OF "MPAGES_6_3":
     SET releasejson = "mpages-6-3.json"
    OF "MPAGES_6_4":
     SET releasejson = "mpages-6-4.json"
    OF "MPAGES_6_5":
     SET releasejson = "mpages-6-5.json"
    OF "MPAGES_6_6":
     SET releasejson = "mpages-6-6.json"
    OF "MPAGES_6_7":
     SET releasejson = "mpages-6-7.json"
    OF "MPAGES_6_8":
     SET releasejson = "mpages-6-8.json"
   ENDCASE
   CALL echo(concat("Initiating refresh request for ",installedreleases->release[indx].release_ident)
    )
   EXECUTE mp_install_static_content_grp "cer_install:", releasejson
   CALL echorecord(refreshreply)
   IF ((refreshreply->status_data.status != "S"))
    CALL echo(concat("Error refreshing content for ",installedreleases->release[indx].release_ident))
    SET readme_data->message = refreshreply->status_data.subeventstatus[1].targetobjectvalue
    GO TO exit_script
   ENDIF
 ENDFOR
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Readme performed all required tasks"
#exit_script
 FREE RECORD refreshreply
 FREE RECORD installedreleases
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
