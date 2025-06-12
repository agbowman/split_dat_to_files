CREATE PROGRAM charted_view_details_retrieve:dba
 RECORD reply(
   1 charted_view_list[*]
     2 charted_view_id = f8
     2 charted_view_version = i2
     2 charting_view_disp = vc
     2 charted_section_list[*]
       3 charted_section_id = f8
       3 event_id_list[*]
         4 event_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE chartedviewid_cnt = i4 WITH protect, noconstant(0)
 DECLARE section_cnt = i4 WITH noconstant(0)
 DECLARE listchartindex = i4 WITH noconstant(0)
 DECLARE event_index = i4 WITH noconstant(0)
 DECLARE listsecindex = i4 WITH noconstant(0)
 DECLARE populatechartedviewdetails(null) = null
 DECLARE popualtechartedviewsectiondetails(null) = null
 DECLARE popualtechartedviewsectioneventdetails(null) = null
 SET reply->status_data.status = "F"
 SET chartedviewid_cnt = size(request->charted_view_list,5)
 IF (chartedviewid_cnt=0)
  GO TO exit_script
 ENDIF
 CALL populatechartedviewdetails(null)
 CALL popualtechartedviewsectiondetails(null)
 CALL popualtechartedviewsectioneventdetails(null)
 SUBROUTINE populatechartedviewdetails(null)
  SET stat = alterlist(reply->charted_view_list,chartedviewid_cnt)
  FOR (listchartindex = 1 TO chartedviewid_cnt)
    SELECT INTO "nl:"
     FROM nc_charted_view ncv
     WHERE (ncv.nc_charted_view_id=request->charted_view_list[listchartindex].charted_view_id)
     DETAIL
      reply->charted_view_list[listchartindex].charted_view_id = ncv.nc_charted_view_id, reply->
      charted_view_list[listchartindex].charting_view_disp = ncv.charting_view_disp,
      CALL getchartedviewversion(ncv.charted_view_clob,listchartindex)
     WITH nocounter
    ;end select
  ENDFOR
 END ;Subroutine
 SUBROUTINE popualtechartedviewsectiondetails(null)
   FOR (listchartindex = 1 TO chartedviewid_cnt)
     SET listsecindex = 0
     SELECT INTO "nl:"
      FROM nc_charted_section ncs
      WHERE (ncs.nc_charted_view_id=reply->charted_view_list[listchartindex].charted_view_id)
      DETAIL
       listsecindex += 1
       IF (mod(listsecindex,10)=1)
        stat = alterlist(reply->charted_view_list[listchartindex].charted_section_list,(listsecindex
         + 9))
       ENDIF
       reply->charted_view_list[listchartindex].charted_section_list[listsecindex].charted_section_id
        = ncs.nc_charted_section_id
      WITH nocounter
     ;end select
     SET stat = alterlist(reply->charted_view_list[listchartindex].charted_section_list,listsecindex)
   ENDFOR
 END ;Subroutine
 SUBROUTINE popualtechartedviewsectioneventdetails(null)
   FOR (listchartindex = 1 TO chartedviewid_cnt)
    SET section_cnt = size(reply->charted_view_list[listchartindex].charted_section_list,5)
    FOR (listsecindex = 1 TO section_cnt)
      SET event_index = 0
      SELECT INTO "nl:"
       FROM nc_charted_section_ce_r ncscr
       WHERE (ncscr.nc_charted_section_id=reply->charted_view_list[listchartindex].
       charted_section_list[listsecindex].charted_section_id)
       DETAIL
        event_index += 1
        IF (mod(event_index,10)=1)
         stat = alterlist(reply->charted_view_list[listchartindex].charted_section_list[listsecindex]
          .event_id_list,(event_index+ 9))
        ENDIF
        reply->charted_view_list[listchartindex].charted_section_list[listsecindex].event_id_list[
        event_index].event_id = ncscr.event_id
       WITH nocounter
      ;end select
      SET stat = alterlist(reply->charted_view_list[listchartindex].charted_section_list[listsecindex
       ].event_id_list,event_index)
    ENDFOR
   ENDFOR
 END ;Subroutine
 SUBROUTINE getchartedviewversion(charted_view_clob,chartedviewid_index)
   DECLARE chartedviewversionstring = vc WITH private, noconstant('chartedViewVersion":"')
   DECLARE idstring = vc WITH private, noconstant('","id"')
   SET pos1 = findstring(chartedviewversionstring,charted_view_clob)
   SET pos1 += textlen(chartedviewversionstring)
   SET pos2 = findstring(idstring,charted_view_clob)
   IF (pos1 > 0
    AND pos2 > pos1)
    SET reply->charted_view_list[chartedviewid_index].charted_view_version = cnvtint(substring(pos1,(
      pos2 - pos1),charted_view_clob))
   ENDIF
 END ;Subroutine
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
END GO
