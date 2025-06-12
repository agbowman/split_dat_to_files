CREATE PROGRAM charted_view_id_retrieve:dba
 RECORD reply(
   1 charted_view_id_list[*]
     2 event_id = f8
     2 view_id = f8
     2 version = i2
     2 view_disp = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET eventid_cnt = size(request->event_id_list,5)
 IF (eventid_cnt=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->charted_view_id_list,eventid_cnt)
 FOR (listindex = 0 TO eventid_cnt)
   SELECT INTO "nl:"
    FROM nc_charted_section_ce_r ncscer,
     nc_charted_section ncs,
     nc_charted_view ncv
    PLAN (ncscer
     WHERE (ncscer.event_id=request->event_id_list[listindex].event_id))
     JOIN (ncs
     WHERE ncs.nc_charted_section_id=ncscer.nc_charted_section_id)
     JOIN (ncv
     WHERE ncv.nc_charted_view_id=ncs.nc_charted_view_id)
    DETAIL
     reply->charted_view_id_list[listindex].event_id = request->event_id_list[listindex].event_id,
     reply->charted_view_id_list[listindex].view_id = ncv.nc_charted_view_id, reply->
     charted_view_id_list[listindex].view_disp = ncv.charting_view_disp,
     CALL getchartedviewversion(ncv.charted_view_clob,listindex)
    WITH nocounter
   ;end select
 ENDFOR
 SUBROUTINE getchartedviewversion(charted_view_clob,listindex)
   DECLARE chartedviewversionstring = vc WITH private, noconstant('chartedViewVersion":"')
   DECLARE idstring = vc WITH private, noconstant('","id"')
   SET pos1 = findstring(chartedviewversionstring,charted_view_clob)
   SET pos1 += textlen(chartedviewversionstring)
   SET pos2 = findstring(idstring,charted_view_clob)
   IF (pos1 > 0
    AND pos2 > pos1)
    SET reply->charted_view_id_list[listindex].version = cnvtint(substring(pos1,(pos2 - pos1),
      charted_view_clob))
   ENDIF
 END ;Subroutine
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
END GO
