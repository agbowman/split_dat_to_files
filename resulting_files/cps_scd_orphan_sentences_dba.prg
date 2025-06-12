CREATE PROGRAM cps_scd_orphan_sentences:dba
 FREE RECORD reply
 RECORD reply(
   1 qual[*]
     2 orphan_id = f8
     2 possible_scr_term_hier_id[*]
       3 scr_term_hier_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE j = i4 WITH protect, noconstant(0)
 DECLARE orphan_sent_cnt = i4 WITH protect, noconstant(0)
 DECLARE para_cnt = i4 WITH protect, noconstant(0)
 DECLARE i = i4 WITH protect, noconstant(1)
 DECLARE sourceiszerofound = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SET orphan_sent_cnt = size(request->orphanhierid_qual,5)
 SET stat = alterlist(reply->qual,orphan_sent_cnt)
 SET para_cnt = size(request->patternid_qual,5)
 IF (orphan_sent_cnt <= 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "EXECUTE"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "Script"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Orphan list empty!"
  GO TO exit_script
 ENDIF
 CALL retrieveorphansent(null)
 SET reply->status_data.status = "S"
#exit_script
 SUBROUTINE retrieveorphansent(null)
  SET i = 1
  FOR (i = 1 TO orphan_sent_cnt)
    SELECT INTO "nl:"
     FROM scr_term_hier sth,
      scr_term_hier sthh
     PLAN (sth
      WHERE (sth.scr_term_hier_id=request->orphanhierid_qual[i].orphan_hier_id))
      JOIN (sthh
      WHERE sthh.source_term_hier_id=sth.source_term_hier_id
       AND expand(idx,1,para_cnt,sthh.scr_pattern_id,request->patternid_qual[idx].pattern_id))
     HEAD REPORT
      j = 0, sourceiszerofound = 0
     DETAIL
      reply->qual[i].orphan_id = request->orphanhierid_qual[i].orphan_hier_id
      IF (sth.source_term_hier_id != 0.0)
       j = (j+ 1)
       IF (j > 0
        AND mod(j,10)=1)
        stat = alterlist(reply->qual[i].possible_scr_term_hier_id,(j+ 9))
       ENDIF
       reply->qual[i].possible_scr_term_hier_id[j].scr_term_hier_id = sthh.scr_term_hier_id
      ELSE
       IF (sourceiszerofound=0)
        j = (j+ 1)
        IF (j > 0
         AND mod(j,10)=1)
         stat = alterlist(reply->qual[i].possible_scr_term_hier_id,(j+ 9))
        ENDIF
        reply->qual[i].possible_scr_term_hier_id[j].scr_term_hier_id = request->orphanhierid_qual[i].
        orphan_hier_id, sourceiszerofound = 1
       ENDIF
      ENDIF
     FOOT REPORT
      stat = alterlist(reply->qual[i].possible_scr_term_hier_id,j)
    ;end select
  ENDFOR
 END ;Subroutine
END GO
