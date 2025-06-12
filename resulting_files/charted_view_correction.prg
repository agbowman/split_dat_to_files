CREATE PROGRAM charted_view_correction
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter the Charted View ID to be corrected" = "0",
  "Enter the correct STATUS_CD to be used" = "0",
  "Enter the full path to the file. If not applicable, leave blank" = ""
  WITH outdev, charted_view_id, view_status_cd,
  file_path
 DECLARE readchartingviews(null) = null WITH protect
 DECLARE getchartedviewclob(null) = null WITH protect
 DECLARE getchartedviewnoteid(null) = null WITH protect
 DECLARE populatestatuscds(null) = null WITH protect
 DECLARE updateviews(null) = null WITH protect
 DECLARE getreport(null) = null
 DECLARE charted_view_id = f8 WITH protect, constant(cnvtreal( $CHARTED_VIEW_ID))
 DECLARE charted_view_status_cd = f8 WITH protect, constant(cnvtreal( $VIEW_STATUS_CD))
 DECLARE file_path = vc WITH protect, noconstant(trim( $FILE_PATH,3))
 DECLARE csv_stat = i2 WITH protect, noconstant(1)
 DECLARE view_count = i4 WITH protect, noconstant(0)
 DECLARE incorrect_input_count = i4 WITH protect, noconstant(0)
 DECLARE incorrect_view_id_input_msg = vc WITH protect, constant(
  "The input Charting View ID does not exist")
 DECLARE incorrect_status_cd_input_msg = vc WITH protect, constant(
  "The input status cd does not exist in code set 8")
 DECLARE continue = i2 WITH protect, noconstant(true)
 DECLARE status_cd_exist = i2 WITH protect, noconstant(false)
 DECLARE view_updated = i4 WITH protect, noconstant(0)
 DECLARE pos1 = i4 WITH protect, noconstant(0)
 DECLARE pos2 = i4 WITH protect, noconstant(0)
 DECLARE status_count = i4 WITH protect, noconstant(0)
 DECLARE incorrect_input_file_msg = vc WITH protect, noconstant("")
 FREE RECORD view_list
 RECORD view_list(
   1 views[*]
     2 view_id = f8
     2 view_status_cd = f8
     2 note_id = f8
 )
 FREE RECORD viewclob
 RECORD viewclob(
   1 chartedview[*]
     2 chartedviewid = f8
     2 clob = vc
 )
 FREE RECORD statuscds
 RECORD statuscds(
   1 statuses[*]
     2 statuscd = f8
 )
 FREE RECORD viewincorrectinput
 RECORD viewincorrectinput(
   1 views[*]
     2 view_id = f8
     2 message = vc
 )
 FREE RECORD tempclob
 RECORD tempclob(
   1 clob[*]
     2 tempclobstring = vc
 )
 SET stat = alterlist(tempclob->clob,1)
 CALL readchartingviews(null)
 IF (incorrect_input_file_msg="")
  CALL getchartedviewclob(null)
  CALL getchartedviewnoteid(null)
  CALL populatestatuscds(null)
  CALL updateviews(null)
 ENDIF
 CALL getreport(null)
 SUBROUTINE readchartingviews(null)
   IF (file_path="")
    SET stat = alterlist(view_list->views,1)
    SET view_list->views[1].view_id = charted_view_id
    SET view_list->views[1].view_status_cd = charted_view_status_cd
    SET view_count += 1
   ELSE
    SET csv_stat = findfile(file_path)
    IF (csv_stat=0)
     SET incorrect_input_file_msg = build("Failed to find csv file:",file_path)
    ELSE
     FREE DEFINE rtl
     DEFINE rtl file_path
     SELECT INTO "nl:"
      view_id = cnvtreal(piece(r.line,",",1,"0",3)), status_cd = cnvtreal(piece(r.line,",",2,"0",3))
      FROM rtlt r
      PLAN (r)
      DETAIL
       IF (view_id > 0)
        view_count += 1
        IF (mod(view_count,10)=1)
         stat = alterlist(view_list->views,(view_count+ 10))
        ENDIF
        view_list->views[view_count].view_id = view_id, view_list->views[view_count].view_status_cd
         = status_cd
       ENDIF
      WITH nocounter
     ;end select
     SET stat = alterlist(view_list->views,view_count)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE getchartedviewclob(null)
  SET stat = alterlist(viewclob->chartedview,view_count)
  FOR (viewidx = 1 TO view_count)
    SELECT DISTINCT INTO "nl:"
     n.nc_charted_view_id, n.charted_view_clob
     FROM nc_charted_view n
     WHERE (n.nc_charted_view_id=view_list->views[viewidx].view_id)
     DETAIL
      viewclob->chartedview[viewidx].chartedviewid = n.nc_charted_view_id, viewclob->chartedview[
      viewidx].clob = n.charted_view_clob
     WITH nocounter
    ;end select
  ENDFOR
 END ;Subroutine
 SUBROUTINE getchartedviewnoteid(null)
   DECLARE notesring = vc WITH private, noconstant('noteId":"')
   DECLARE notetypesring = vc WITH private, noconstant('","noteTypeCd"')
   FOR (viewidx = 1 TO view_count)
     SET tempclob->clob[1].tempclobstring = viewclob->chartedview[viewidx].clob
     SET pos1 = findstring(notesring,tempclob->clob[1].tempclobstring)
     IF (pos1 > 0)
      SET pos1 += textlen(notesring)
      SET pos2 = findstring(notetypesring,tempclob->clob[1].tempclobstring)
      SET notestring = substring(pos1,(pos2 - pos1),tempclob->clob[1].tempclobstring)
      SET view_list->views[viewidx].note_id = cnvtreal(notestring)
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE populatestatuscds(null)
  SELECT DISTINCT INTO "nl:"
   cv.code_value, cv.display
   FROM code_value cv
   WHERE cv.code_set=8
    AND cv.active_ind=1
   DETAIL
    status_count += 1
    IF (mod(status_count,10)=1)
     stat = alterlist(statuscds->statuses,(status_count+ 9))
    ENDIF
    statuscds->statuses[status_count].statuscd = cv.code_value
   WITH nocounter
  ;end select
  SET stat = alterlist(statuscds->statuses,status_count)
 END ;Subroutine
 SUBROUTINE (checkstatuscdexist(statuscdvalue=f8) =i2 WITH protect)
   DECLARE statusidx = i4 WITH protect, noconstant(0)
   DECLARE pos = i4 WITH protect, noconstant(0)
   SET pos = locateval(statusidx,1,size(statuscds->statuses,5),statuscdvalue,statuscds->statuses[
    statusidx].statuscd)
   IF (pos > 0)
    RETURN(true)
   ENDIF
   RETURN(false)
 END ;Subroutine
 SUBROUTINE updateviews(null)
  FOR (viewidx = 1 TO view_count)
    SET continue = true
    SELECT DISTINCT INTO "nl:"
     n.nc_charted_view_id
     FROM nc_charted_view n
     WHERE (n.nc_charted_view_id=view_list->views[viewidx].view_id)
    ;end select
    IF (curqual=0)
     SET incorrect_input_count += 1
     IF (mod(incorrect_input_count,10)=1)
      SET stat = alterlist(viewincorrectinput->views,(incorrect_input_count+ 9))
     ENDIF
     SET viewincorrectinput->views[incorrect_input_count].view_id = view_list->views[viewidx].view_id
     SET viewincorrectinput->views[incorrect_input_count].message = incorrect_view_id_input_msg
     SET continue = false
    ENDIF
    IF (continue=true)
     SET status_cd_exist = checkstatuscdexist(view_list->views[viewidx].view_status_cd)
     IF (status_cd_exist=false)
      SET incorrect_input_count += 1
      IF (mod(incorrect_input_count,10)=1)
       SET stat = alterlist(viewincorrectinput->views,(incorrect_input_count+ 9))
      ENDIF
      SET viewincorrectinput->views[incorrect_input_count].view_id = view_list->views[viewidx].
      view_id
      SET viewincorrectinput->views[incorrect_input_count].message = incorrect_status_cd_input_msg
      SET continue = false
     ENDIF
    ENDIF
    IF (continue=true)
     UPDATE  FROM nc_charted_view n
      SET n.status_cd = view_list->views[viewidx].view_status_cd
      WHERE (n.nc_charted_view_id=view_list->views[viewidx].view_id)
      WITH nocounter
     ;end update
     IF ((view_list->views[viewidx].note_id > 0))
      UPDATE  FROM clinical_event ce
       SET ce.result_status_cd = view_list->views[viewidx].view_status_cd
       WHERE (ce.event_id=view_list->views[viewidx].note_id)
        AND ce.valid_until_dt_tm > cnvtdatetime(sysdate)
       WITH nocounter
      ;end update
     ENDIF
     SET view_updated += 1
    ENDIF
  ENDFOR
  SET stat = alterlist(viewincorrectinput->views,incorrect_input_count)
 END ;Subroutine
 SUBROUTINE getreport(null)
   SELECT INTO  $OUTDEV
    FROM dummyt d1
    HEAD REPORT
     col 00, "********************************* START OF REPORT *********************************",
     row + 1
     IF (incorrect_input_file_msg != "")
      col 05, incorrect_input_file_msg, row + 2
     ELSE
      col 05, "Number of Charting Views updated:", col 40,
      view_updated, row + 2
      IF (incorrect_input_count > 0)
       row + 1, col 05,
       "---------------------------------------------------------------------------------",
       row + 1, col 05,
       "                           Incorrect input message                               ",
       row + 1, col 05,
       "---------------------------------------------------------------------------------",
       row + 1, col 15, "View_ID",
       col 40, "Message", row + 1,
       col 05, "---------------------------------------------------------------------------------",
       row + 1
      ENDIF
      FOR (viewidx = 1 TO incorrect_input_count)
        col 15, viewincorrectinput->views[viewidx].view_id, col 40,
        viewincorrectinput->views[viewidx].message, row + 1
      ENDFOR
     ENDIF
    FOOT REPORT
     row + 1, col 00,
     "********************************* END OF REPORT ***********************************"
    WITH nocounter
   ;end select
 END ;Subroutine
END GO
