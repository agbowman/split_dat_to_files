CREATE PROGRAM corrupted_charted_view_report
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter start date from when the data has to be corrected" = "CURDATE",
  "Enter end date to when the data has to be corrected" = "CURDATE"
  WITH outdev, start_date, end_date
 DECLARE calculatestartandenddate(null) = null WITH protect
 DECLARE getchartedviewclob(null) = null WITH protect
 DECLARE getchartedviewnoteidandsectionids(null) = null WITH protect
 DECLARE getchartedsectionclob(null) = null WITH protect
 DECLARE getchartedvalueids(null) = null WITH protect
 DECLARE populatestatuscds(null) = null WITH protect
 DECLARE populatecorruptedviewfromtempview(null) = null WITH protect
 DECLARE getcorruptedviews(null) = null WITH protect
 DECLARE getreport(null) = null WITH protect
 DECLARE startdate = dq8 WITH protect, noconstant(cnvtdatetime( $START_DATE))
 DECLARE enddate = dq8 WITH protect, noconstant(cnvtdatetime( $END_DATE))
 DECLARE inerror_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"INERROR"))
 DECLARE unchartedviewcount = i4 WITH protect, noconstant(0)
 DECLARE chartedsectioncount = i4 WITH protect, noconstant(0)
 DECLARE statuscount = i4 WITH protect, noconstant(0)
 DECLARE corruptedviewcount = i4 WITH protect, noconstant(0)
 DECLARE emptystring = vc WITH protect, constant("  --  ")
 DECLARE viewidx = i4 WITH protect, noconstant(0)
 DECLARE valueidx = i4 WITH protect, noconstant(0)
 DECLARE sectionidx = i4 WITH protect, noconstant(0)
 DECLARE pos1 = i4 WITH protect, noconstant(0)
 DECLARE pos2 = i4 WITH protect, noconstant(0)
 DECLARE expand_index = i4 WITH protect, noconstant(0)
 DECLARE corruptedviewindicator = i2 WITH protect, noconstant(false)
 FREE RECORD viewclob
 RECORD viewclob(
   1 chartedview[*]
     2 chartedviewid = f8
     2 clob = vc
     2 chartedsection[*]
       3 chartedsectionid = f8
       3 clob = vc
 )
 FREE RECORD sections
 RECORD sections(
   1 section[*]
     2 section_id = vc
 )
 FREE RECORD unchartedviews
 RECORD unchartedviews(
   1 unchartedview[*]
     2 chartedviewid = f8
     2 noteid = f8
     2 sections[*]
       3 sectionid = f8
       3 chartedvalues[*]
         4 chartedvalueid = f8
 )
 FREE RECORD corruptedviews
 RECORD corruptedviews(
   1 corruptedview[*]
     2 chartedviewid = f8
     2 chartedviewname = vc
     2 chartedviewstatuscd = i4
     2 chartedviewstatusdisplay = vc
     2 encntrid = f8
     2 noteid = f8
     2 noteidstatuscd = i4
     2 noteidstatusdisplay = vc
     2 sections[*]
       3 sectionid = f8
       3 sectionname = vc
       3 chartedvalues[*]
         4 chartedvalueid = f8
         4 chartedvaluestatuscd = i4
         4 chartedvaluestatusdisplay = vc
 )
 FREE RECORD tempview
 RECORD tempview(
   1 chartedviewid = f8
   1 chartedviewname = vc
   1 chartedviewstatuscd = f8
   1 chartedviewstatusdisplay = vc
   1 encntrid = f8
   1 noteid = f8
   1 noteidstatuscd = f8
   1 noteidstatusdisplay = vc
   1 sections[*]
     2 sectionid = f8
     2 sectionname = vc
     2 chartedvalues[*]
       3 chartedvalueid = f8
       3 chartedvaluestatuscd = f8
       3 chartedvaluestatusdisplay = vc
 )
 FREE RECORD statuscds
 RECORD statuscds(
   1 statuses[*]
     2 statuscd = f8
     2 statuscddisplay = vc
 )
 FREE RECORD tempclob
 RECORD tempclob(
   1 clob[*]
     2 tempclobstring = vc
 )
 SET stat = alterlist(tempclob->clob,1)
 CALL calculatestartandenddate(null)
 CALL getchartedviewclob(null)
 CALL getchartedviewnoteidandsectionids(null)
 CALL getchartedsectionclob(null)
 CALL getchartedvalueids(null)
 CALL populatestatuscds(null)
 CALL getcorruptedviews(null)
 CALL getreport(null)
 SUBROUTINE calculatestartandenddate(null)
  IF (( $END_DATE=null))
   SET enddate = cnvtdatetime(sysdate)
  ELSE
   SET enddate = cnvtlookahead("1,D",enddate)
  ENDIF
  IF (( $START_DATE=null))
   SET startdate = cnvtlookbehind("7,D",enddate)
  ENDIF
 END ;Subroutine
 SUBROUTINE getchartedviewclob(null)
  SELECT DISTINCT INTO "nl:"
   n.nc_charted_view_id, n.charted_view_clob
   FROM nc_charted_view n
   WHERE n.status_cd=inerror_cd
    AND n.create_dt_tm BETWEEN cnvtdatetime(startdate) AND cnvtdatetime(enddate)
   DETAIL
    unchartedviewcount += 1
    IF (mod(unchartedviewcount,10)=1)
     stat = alterlist(viewclob->chartedview,(unchartedviewcount+ 9))
    ENDIF
    viewclob->chartedview[unchartedviewcount].chartedviewid = n.nc_charted_view_id, viewclob->
    chartedview[unchartedviewcount].clob = n.charted_view_clob
   WITH nocounter
  ;end select
  SET stat = alterlist(viewclob->chartedview,unchartedviewcount)
 END ;Subroutine
 SUBROUTINE getchartedviewnoteidandsectionids(null)
   DECLARE num = i4 WITH private, noconstant(0)
   DECLARE sectionsring = vc WITH private, noconstant('"chartedSectionIds":[')
   DECLARE versionnsring = vc WITH private, noconstant('],"chartedViewVersion":')
   DECLARE notesring = vc WITH private, noconstant('noteId":"')
   DECLARE notetypesring = vc WITH private, noconstant('","noteTypeCd"')
   SET stat = alterlist(unchartedviews->unchartedview,unchartedviewcount)
   FOR (viewidx = 1 TO unchartedviewcount)
     SET unchartedviews->unchartedview[viewidx].chartedviewid = viewclob->chartedview[viewidx].
     chartedviewid
     SET tempclob->clob[1].tempclobstring = viewclob->chartedview[viewidx].clob
     SET pos1 = findstring(notesring,tempclob->clob[1].tempclobstring)
     IF (pos1 > 0)
      SET pos1 += textlen(notesring)
      SET pos2 = findstring(notetypesring,tempclob->clob[1].tempclobstring)
      SET notestring = substring(pos1,(pos2 - pos1),tempclob->clob[1].tempclobstring)
      SET unchartedviews->unchartedview[viewidx].noteid = cnvtreal(notestring)
     ELSE
      SET unchartedviews->unchartedview[viewidx].noteid = 0
     ENDIF
     SET num = 0
     SET idx = 0
     SET pos1 = findstring(sectionsring,tempclob->clob[1].tempclobstring)
     SET pos1 += textlen(sectionsring)
     SET pos2 = findstring(versionnsring,tempclob->clob[1].tempclobstring)
     IF (pos2 > pos1)
      SET secstring = substring(pos1,(pos2 - pos1),tempclob->clob[1].tempclobstring)
      SET num = arraysplit(sections->section[idx].section_id,idx,secstring,",",3)
      SET sectioncount = size(sections->section,5)
      SET stat = alterlist(unchartedviews->unchartedview[viewidx].sections,sectioncount)
      FOR (x = 1 TO sectioncount)
        SET unchartedviews->unchartedview[viewidx].sections[x].sectionid = cnvtreal(sections->
         section[x].section_id)
      ENDFOR
      SET stat = alterlist(sections->section,0)
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE getchartedsectionclob(null)
   FOR (viewidx = 1 TO unchartedviewcount)
     SET chartedsectioncount = 0
     SET idx = 0
     SELECT DISTINCT INTO "nl:"
      n.nc_charted_section_id, n.charted_section_clob
      FROM nc_charted_section n
      WHERE expand(expand_index,1,size(unchartedviews->unchartedview[viewidx].sections,5),n
       .nc_charted_section_id,unchartedviews->unchartedview[viewidx].sections[expand_index].sectionid
       )
      DETAIL
       chartedsectioncount += 1
       IF (mod(chartedsectioncount,10)=1)
        stat = alterlist(viewclob->chartedview[viewidx].chartedsection,(chartedsectioncount+ 9))
       ENDIF
       viewclob->chartedview[viewidx].chartedsection[chartedsectioncount].chartedsectionid = n
       .nc_charted_section_id, viewclob->chartedview[viewidx].chartedsection[chartedsectioncount].
       clob = n.charted_section_clob
      WITH nocounter
     ;end select
     SET stat = alterlist(viewclob->chartedview[viewidx].chartedsection,chartedsectioncount)
   ENDFOR
 END ;Subroutine
 SUBROUTINE getchartedvalueids(null)
   DECLARE len = i4 WITH private, noconstant(0)
   DECLARE chartedvaluecount = i4 WITH private, noconstant(0)
   DECLARE chartedvaluestringlen = i4 WITH private, noconstant(0)
   DECLARE chartedvalueid = i4 WITH private, noconstant(0)
   DECLARE chartedvaluestring = vc WITH private, noconstant('"chartedValueId":"')
   DECLARE valuestring = vc WITH private, noconstant("")
   SET chartedvaluestringlen = textlen(chartedvaluestring)
   FOR (viewidx = 1 TO unchartedviewcount)
    SET sectioncount = size(unchartedviews->unchartedview[viewidx].sections,5)
    FOR (sectionidx = 1 TO sectioncount)
      SET chartedvaluecount = 0
      SET tempclob->clob[1].tempclobstring = viewclob->chartedview[viewidx].chartedsection[sectionidx
      ].clob
      SET pos1 = findstring(chartedvaluestring,tempclob->clob[1].tempclobstring)
      WHILE (pos1 > 0)
        SET pos1 += chartedvaluestringlen
        SET len = textlen(tempclob->clob[1].tempclobstring)
        SET len -= pos1
        SET tempclob->clob[1].tempclobstring = substring(pos1,len,tempclob->clob[1].tempclobstring)
        SET pos2 = findstring('"',tempclob->clob[1].tempclobstring)
        SET pos2 -= 1
        SET valuestring = substring(1,pos2,tempclob->clob[1].tempclobstring)
        SET chartedvaluecount += 1
        SET chartedvalueid = cnvtreal(valuestring)
        IF (mod(chartedvaluecount,10)=1)
         SET stat = alterlist(unchartedviews->unchartedview[viewidx].sections[sectionidx].
          chartedvalues,(chartedvaluecount+ 9))
        ENDIF
        SET unchartedviews->unchartedview[viewidx].sections[sectionidx].chartedvalues[
        chartedvaluecount].chartedvalueid = chartedvalueid
        SET pos1 = findstring(chartedvaluestring,tempclob->clob[1].tempclobstring)
      ENDWHILE
      SET stat = alterlist(unchartedviews->unchartedview[viewidx].sections[sectionidx].chartedvalues,
       chartedvaluecount)
    ENDFOR
   ENDFOR
 END ;Subroutine
 SUBROUTINE populatestatuscds(null)
  SELECT DISTINCT INTO "nl:"
   cv.code_value, cv.display
   FROM code_value cv
   WHERE cv.code_set=8
    AND cv.active_ind=1
   DETAIL
    statuscount += 1
    IF (mod(statuscount,10)=1)
     stat = alterlist(statuscds->statuses,(statuscount+ 9))
    ENDIF
    statuscds->statuses[statuscount].statuscd = cv.code_value, statuscds->statuses[statuscount].
    statuscddisplay = cv.display
   WITH nocounter
  ;end select
  SET stat = alterlist(statuscds->statuses,statuscount)
 END ;Subroutine
 SUBROUTINE (getstatuscddisplay(statuscdvalue=f8) =vc WITH protect)
   DECLARE statusidx = i4 WITH protect, noconstant(0)
   DECLARE pos = i4 WITH protect, noconstant(0)
   IF (statuscdvalue=0)
    RETURN(emptystring)
   ENDIF
   SET pos = locateval(statusidx,1,size(statuscds->statuses,5),statuscdvalue,statuscds->statuses[
    statusidx].statuscd)
   RETURN(statuscds->statuses[pos].statuscddisplay)
 END ;Subroutine
 SUBROUTINE getcorruptedviews(null)
   SET corruptedviewcount = 0
   DECLARE unchartedviewcount = i4 WITH protect, constant(size(unchartedviews->unchartedview,5))
   FOR (viewidx = 1 TO unchartedviewcount)
     SELECT DISTINCT INTO "nl:"
      n.nc_charted_view_id, n.status_cd, n.encntr_id,
      nv.view_name
      FROM nc_charted_view n,
       nc_charting_view nv
      WHERE (n.nc_charted_view_id=unchartedviews->unchartedview[viewidx].chartedviewid)
       AND nv.nc_charting_view_id=n.nc_charting_view_id
      DETAIL
       tempview->chartedviewid = n.nc_charted_view_id, tempview->chartedviewname = nv.view_name
       IF ((tempview->chartedviewname=""))
        tempview->chartedviewname = emptystring
       ENDIF
       tempview->chartedviewstatuscd = n.status_cd, tempview->chartedviewstatusdisplay =
       getstatuscddisplay(n.status_cd), tempview->encntrid = n.encntr_id
      WITH nocounter
     ;end select
     CALL populatecorruptedviewnoteid(unchartedviews->unchartedview[viewidx].noteid)
     CALL populatecorruptedviewsections(viewidx)
     CALL populatecorruptedviewfromtempview(null)
   ENDFOR
   SET stat = alterlist(corruptedviews->corruptedview,corruptedviewcount)
 END ;Subroutine
 SUBROUTINE (populatecorruptedviewnoteid(noteid=f8) =null WITH protect)
   IF (noteid=0)
    SET tempview->noteid = 0
    SET tempview->noteidstatuscd = 0
    SET tempview->noteidstatusdisplay = emptystring
   ELSE
    SELECT DISTINCT INTO "nl:"
     c.event_id, c.result_status_cd
     FROM clinical_event c
     WHERE c.event_id=noteid
      AND c.valid_until_dt_tm > cnvtdatetime(sysdate)
     DETAIL
      tempview->noteid = c.event_id, tempview->noteidstatuscd = c.result_status_cd, tempview->
      noteidstatusdisplay = getstatuscddisplay(c.result_status_cd)
     WITH nocounter
    ;end select
   ENDIF
 END ;Subroutine
 SUBROUTINE (populatecorruptedviewsections(viewindx=i4) =null WITH protect)
   SET chartedsectioncount = size(unchartedviews->unchartedview[viewidx].sections,5)
   SET stat = alterlist(tempview->sections,chartedsectioncount)
   FOR (sectionidx = 1 TO chartedsectioncount)
    SELECT
     n.nc_charting_section_id, ns.section_name
     FROM nc_charted_section n,
      nc_charting_section ns
     WHERE (n.nc_charted_section_id=unchartedviews->unchartedview[viewindx].sections[sectionidx].
     sectionid)
      AND ns.nc_charting_section_id=n.nc_charting_section_id
     DETAIL
      tempview->sections[sectionidx].sectionid = n.nc_charted_section_id, tempview->sections[
      sectionidx].sectionname = ns.section_name
      IF ((tempview->sections[sectionidx].sectionname=""))
       tempview->sections[sectionidx].sectionname = emptystring
      ENDIF
     WITH nocounter
    ;end select
    CALL populatecorruptedviewvalues(viewindx,sectionidx)
   ENDFOR
 END ;Subroutine
 SUBROUTINE (populatecorruptedviewvalues(viewindx=i4,sectionindx=i4) =null WITH protect)
   SET chartedvaluecount = size(unchartedviews->unchartedview[viewidx].sections[sectionindx].
    chartedvalues,5)
   SET stat = alterlist(tempview->sections[sectionindx].chartedvalues,chartedvaluecount)
   SET valueidx = 0
   SELECT DISTINCT INTO "nl:"
    c.event_id, c.result_status_cd
    FROM clinical_event c
    WHERE expand(expand_index,1,chartedvaluecount,c.event_id,unchartedviews->unchartedview[viewidx].
     sections[sectionindx].chartedvalues[expand_index].chartedvalueid)
     AND c.valid_until_dt_tm > cnvtdatetime(sysdate)
    DETAIL
     valueidx += 1
     IF (mod(valueidx,10)=1)
      stat = alterlist(tempview->sections[sectionindx].chartedvalues,(valueidx+ 9))
     ENDIF
     tempview->sections[sectionindx].chartedvalues[valueidx].chartedvalueid = c.event_id, tempview->
     sections[sectionindx].chartedvalues[valueidx].chartedvaluestatuscd = c.result_status_cd,
     tempview->sections[sectionindx].chartedvalues[valueidx].chartedvaluestatusdisplay =
     getstatuscddisplay(c.result_status_cd)
    WITH nocounter
   ;end select
   SET stat = alterlist(tempview->sections[sectionindx].chartedvalues,valueidx)
 END ;Subroutine
 SUBROUTINE populatecorruptedviewfromtempview(null)
   SET corruptedviewindicator = false
   IF ((tempview->noteid > 0)
    AND (tempview->noteidstatuscd != inerror_cd))
    SET corruptedviewindicator = true
   ENDIF
   SET chartedsectioncount = size(tempview->sections,5)
   FOR (sectionidx = 1 TO chartedsectioncount)
    SET chartedvaluecount = size(tempview->sections[sectionidx].chartedvalues,5)
    FOR (valueidx = 1 TO chartedvaluecount)
      IF ((tempview->sections[sectionidx].chartedvalues[valueidx].chartedvaluestatuscd != inerror_cd)
      )
       SET corruptedviewindicator = true
      ENDIF
    ENDFOR
   ENDFOR
   IF (corruptedviewindicator=false)
    RETURN
   ENDIF
   SET corruptedviewcount += 1
   IF (mod(corruptedviewcount,10)=1)
    SET stat = alterlist(corruptedviews->corruptedview,(corruptedviewcount+ 9))
   ENDIF
   SET corruptedviews->corruptedview[corruptedviewcount].chartedviewid = tempview->chartedviewid
   SET corruptedviews->corruptedview[corruptedviewcount].chartedviewname = tempview->chartedviewname
   SET corruptedviews->corruptedview[corruptedviewcount].chartedviewstatuscd = tempview->
   chartedviewstatuscd
   SET corruptedviews->corruptedview[corruptedviewcount].chartedviewstatusdisplay = tempview->
   chartedviewstatusdisplay
   SET corruptedviews->corruptedview[corruptedviewcount].encntrid = tempview->encntrid
   SET corruptedviews->corruptedview[corruptedviewcount].noteid = tempview->noteid
   SET corruptedviews->corruptedview[corruptedviewcount].noteidstatuscd = tempview->noteidstatuscd
   SET corruptedviews->corruptedview[corruptedviewcount].noteidstatusdisplay = tempview->
   noteidstatusdisplay
   SET stat = alterlist(corruptedviews->corruptedview[corruptedviewcount].sections,
    chartedsectioncount)
   FOR (sectionidx = 1 TO chartedsectioncount)
     SET corruptedviews->corruptedview[corruptedviewcount].sections[sectionidx].sectionid = tempview
     ->sections[sectionidx].sectionid
     SET corruptedviews->corruptedview[corruptedviewcount].sections[sectionidx].sectionname =
     tempview->sections[sectionidx].sectionname
     SET chartedvaluecount = size(tempview->sections[sectionidx].chartedvalues,5)
     SET stat = alterlist(corruptedviews->corruptedview[corruptedviewcount].sections[sectionidx].
      chartedvalues,chartedvaluecount)
     FOR (valueidx = 1 TO chartedvaluecount)
       SET corruptedviews->corruptedview[corruptedviewcount].sections[sectionidx].chartedvalues[
       valueidx].chartedvalueid = tempview->sections[sectionidx].chartedvalues[valueidx].
       chartedvalueid
       SET corruptedviews->corruptedview[corruptedviewcount].sections[sectionidx].chartedvalues[
       valueidx].chartedvaluestatuscd = tempview->sections[sectionidx].chartedvalues[valueidx].
       chartedvaluestatuscd
       SET corruptedviews->corruptedview[corruptedviewcount].sections[sectionidx].chartedvalues[
       valueidx].chartedvaluestatusdisplay = tempview->sections[sectionidx].chartedvalues[valueidx].
       chartedvaluestatusdisplay
     ENDFOR
   ENDFOR
 END ;Subroutine
 SUBROUTINE getreport(null)
   IF (corruptedviewcount > 0)
    SELECT INTO  $OUTDEV
     FROM (dummyt d1  WITH seq = value(size(corruptedviews->corruptedview,5)))
     PLAN (d1)
     HEAD REPORT
      col 00,
      "***************************************** START OF REPORT ************************************************",
      row + 2,
      col 05, "Total Views corrupted: ", col 30,
      corruptedviewcount
     DETAIL
      row + 4, col 05,
      "----------------------------------------------------------------------------------------------------------",
      row + 1, col 05, "View_ID",
      col 20, "View_Name", col 40,
      "ViewStatusCD", col 55, "ViewStatus",
      col 80, "Note_ID", col 95,
      "NoteStatusCD", col 110, "NoteStatus",
      row + 1, col 05,
      "----------------------------------------------------------------------------------------------------------",
      row + 1, col 00, corruptedviews->corruptedview[d1.seq].chartedviewid,
      col 20, corruptedviews->corruptedview[d1.seq].chartedviewname, col 40,
      corruptedviews->corruptedview[d1.seq].chartedviewstatuscd, col 55, corruptedviews->
      corruptedview[d1.seq].chartedviewstatusdisplay,
      col 75, corruptedviews->corruptedview[d1.seq].noteid, col 95,
      corruptedviews->corruptedview[d1.seq].noteidstatuscd, col 110, corruptedviews->corruptedview[d1
      .seq].noteidstatusdisplay,
      row + 1, col 05,
      "----------------------------------------------------------------------------------------------------------",
      chartedsectioncount = size(corruptedviews->corruptedview[d1.seq].sections,5)
      FOR (sectionidx = 1 TO chartedsectioncount)
        row + 1, col 15,
        "---------------------------------------------------------------------------------",
        row + 1, col 25, "Section_ID",
        col 50, "Section_Name", row + 1,
        col 15, "---------------------------------------------------------------------------------",
        row + 1,
        col 20, corruptedviews->corruptedview[d1.seq].sections[sectionidx].sectionid, col 50,
        corruptedviews->corruptedview[d1.seq].sections[sectionidx].sectionname, chartedvaluecount =
        size(corruptedviews->corruptedview[d1.seq].sections[sectionidx].chartedvalues,5)
        IF (chartedvaluecount > 0)
         row + 1, col 25, "-----------------------------------------------------------------",
         row + 1, col 35, "Event_ID",
         col 50, "ResultStatusCD", col 70,
         "ResultStatus", row + 1, col 25,
         "-----------------------------------------------------------------"
        ENDIF
        FOR (valueidx = 1 TO chartedvaluecount)
          row + 1, col 30, corruptedviews->corruptedview[d1.seq].sections[sectionidx].chartedvalues[
          valueidx].chartedvalueid,
          col 50, corruptedviews->corruptedview[d1.seq].sections[sectionidx].chartedvalues[valueidx].
          chartedvaluestatuscd, col 70,
          corruptedviews->corruptedview[d1.seq].sections[sectionidx].chartedvalues[valueidx].
          chartedvaluestatusdisplay
        ENDFOR
        IF (chartedvaluecount > 0)
         row + 1, col 25, "-----------------------------------------------------------------"
        ENDIF
        row + 1, col 15,
        "---------------------------------------------------------------------------------"
      ENDFOR
      row + 1, col 05,
      "----------------------------------------------------------------------------------------------------------"
     FOOT REPORT
      row + 4, col 00,
      "******************************************* END OF REPORT *************************************************"
     WITH nocounter
    ;end select
   ENDIF
 END ;Subroutine
END GO
