CREATE PROGRAM dcp_del_announcement:dba
 FREE RECORD temp
 RECORD temp(
   1 knt = i4
   1 list[*]
     2 long_text_id = f8
     2 dcp_entity_reltn_id = f8
 )
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE pos_cnt = i4 WITH constant(size(request->qual,5))
 DECLARE positioncd = f8 WITH noconstant(0.0)
 DECLARE index = i4 WITH noconstant(0)
 DECLARE posview_cnt = i4 WITH noconstant(0)
 SET reply->status_data.status = "F"
 SET long_text_id = 0.0
 SET dcp_entity_reltn_id = 0.0
 SET dcp_mean = fillstring(12," ")
 DECLARE mainannouncemententrypoint(null) = null
 DECLARE deletenonphysicianannouncement(null) = null
 DECLARE deletephysicianannouncement(null) = null
 CASE (request->dcp_type)
  OF 1:
   SET dcp_type = 1
  OF 2:
   SET dcp_type = 2
  OF 3:
   SET dcp_type = 3
  OF 4:
   SET dcp_type = 4
  ELSE
   SET dcp_type = 0
 ENDCASE
 IF (dcp_type=0)
  CASE (request->application_number)
   OF 600005:
    SET dcp_mean = "PSN/ANNOUNCE"
   OF 600006:
    SET dcp_mean = "CNT ANNOUNCE"
   OF 610000:
    SET dcp_mean = "INT ANNOUNCE"
   OF 250021:
    SET dcp_mean = "CVR ANNOUNCE"
   OF 820000:
    SET dcp_mean = "SNT ANNOUNCE"
   OF 4006000:
    SET dcp_mean = "PR ANNOUNCE"
   OF 4250111:
    SET dcp_mean = "FNT ANNOUNCE"
   OF 4100001:
    SET dcp_mean = "CVT ANNOUNCE"
   OF 4180000:
    SET dcp_mean = "CMR ANNOUNCE"
   OF 961000:
    SET dcp_mean = "PCO ANNOUNCE"
   OF 3202004:
    SET dcp_mean = "WEB ANNOUNCE"
  ENDCASE
 ELSEIF (dcp_type=1)
  CASE (request->application_number)
   OF 600005:
    SET dcp_mean = "PC PCSTMT"
   OF 600006:
    SET dcp_mean = "CNT PCSTMT"
   OF 610000:
    SET dcp_mean = "INT PCSTMT"
   OF 250021:
    SET dcp_mean = "CVR PCSTMT"
   OF 820000:
    SET dcp_mean = "SNT PCSTMT"
   OF 4006000:
    SET dcp_mean = "PR PCSTMT"
   OF 4250111:
    SET dcp_mean = "FNT PCSTMT"
   OF 4100001:
    SET dcp_mean = "CVT PCSTMT"
   OF 4180000:
    SET dcp_mean = "CMR PCSTMT"
   OF 961000:
    SET dcp_mean = "PCO PCSTMT"
  ENDCASE
 ELSEIF (dcp_type=2)
  CASE (request->application_number)
   OF 600005:
    SET dcp_mean = "PC TCHDR"
   OF 600006:
    SET dcp_mean = "CNT TCHDR"
   OF 610000:
    SET dcp_mean = "INT TCHDR"
   OF 250021:
    SET dcp_mean = "CVR TCHDR"
   OF 820000:
    SET dcp_mean = "SNT TCHDR"
   OF 4006000:
    SET dcp_mean = "PR TCHDR"
   OF 4250111:
    SET dcp_mean = "FNT TCHDR"
   OF 4100001:
    SET dcp_mean = "CVT TCHDR"
   OF 4180000:
    SET dcp_mean = "CMR TCHDR"
   OF 961000:
    SET dcp_mean = "PCO TCHDR"
  ENDCASE
 ELSEIF (dcp_type=3)
  CASE (request->application_number)
   OF 600005:
    SET dcp_mean = "PC BCHDR"
   OF 600006:
    SET dcp_mean = "CNT BCHDR"
   OF 610000:
    SET dcp_mean = "INT BCHDR"
   OF 250021:
    SET dcp_mean = "CVR BCHDR"
   OF 820000:
    SET dcp_mean = "SNT BCHDR"
   OF 4006000:
    SET dcp_mean = "PR BCHDR"
   OF 4250111:
    SET dcp_mean = "FNT BCHDR"
   OF 4100001:
    SET dcp_mean = "CVT BCHDR"
   OF 4180000:
    SET dcp_mean = "CMR BCHDR"
   OF 961000:
    SET dcp_mean = "PCO BCHDR"
  ENDCASE
 ELSEIF (dcp_type=4)
  CASE (request->application_number)
   OF 600005:
    SET dcp_mean = "PC CCPG"
   OF 600006:
    SET dcp_mean = "CNT CCPG"
   OF 610000:
    SET dcp_mean = "INT CCPG"
   OF 250021:
    SET dcp_mean = "CVR CCPG"
   OF 820000:
    SET dcp_mean = "SNT CCPG"
   OF 4006000:
    SET dcp_mean = "PR CCPG"
   OF 4250111:
    SET dcp_mean = "FNT CCPG"
   OF 4100001:
    SET dcp_mean = "CVT CCPG"
   OF 4180000:
    SET dcp_mean = "CMR CCPG"
   OF 961000:
    SET dcp_mean = "PCO CCPG"
  ENDCASE
 ENDIF
 CALL mainannouncemententrypoint(null)
 SUBROUTINE mainannouncemententrypoint(null)
   IF ((request->physician_ind=0))
    CALL deletenonphysicianannouncement(null)
    IF (pos_cnt > 0)
     SET positioncd = request->qual[1].position_cd
     IF (positioncd=0)
      CALL deletephysicianannouncement(null)
     ENDIF
    ENDIF
   ELSEIF ((request->physician_ind=1))
    CALL deletephysicianannouncement(null)
   ENDIF
 END ;Subroutine
 SUBROUTINE deletenonphysicianannouncement(null)
  IF (pos_cnt > 0)
   SET positioncd = request->qual[1].position_cd
   IF (positioncd > 0)
    SELECT INTO "nl:"
     d.seq
     FROM dcp_entity_reltn d
     PLAN (d
      WHERE d.entity_reltn_mean=dcp_mean
       AND expand(index,1,pos_cnt,d.entity1_id,request->qual[index].position_cd)
       AND d.entity1_name="CODE_VALUE")
     HEAD REPORT
      posview_cnt = 0
     DETAIL
      posview_cnt = (posview_cnt+ 1)
      IF (posview_cnt > size(temp->list,5))
       stat = alterlist(temp->list,(posview_cnt+ 10))
      ENDIF
      temp->list[posview_cnt].long_text_id = d.entity2_id, temp->list[posview_cnt].
      dcp_entity_reltn_id = d.dcp_entity_reltn_id
     FOOT REPORT
      temp->knt = posview_cnt, stat = alterlist(temp->list,posview_cnt)
     WITH nocounter
    ;end select
    IF ((temp->knt > 0))
     DELETE  FROM long_text l,
       (dummyt d  WITH seq = value(temp->knt))
      SET l.seq = 1
      PLAN (d
       WHERE d.seq > 0)
       JOIN (l
       WHERE (l.long_text_id=temp->list[d.seq].long_text_id))
      WITH nocounter
     ;end delete
    ENDIF
    IF ((temp->knt > 0))
     DELETE  FROM dcp_entity_reltn de,
       (dummyt d  WITH seq = value(temp->knt))
      SET de.seq = 1
      PLAN (d
       WHERE d.seq > 0)
       JOIN (de
       WHERE (de.dcp_entity_reltn_id=temp->list[d.seq].dcp_entity_reltn_id))
      WITH nocounter
     ;end delete
    ENDIF
   ELSE
    SELECT INTO "nl:"
     d.seq
     FROM dcp_entity_reltn d
     PLAN (d
      WHERE d.entity_reltn_mean=dcp_mean
       AND d.entity1_id=0
       AND d.entity1_display="SYSTEM")
     DETAIL
      long_text_id = d.entity2_id, dcp_entity_reltn_id = d.dcp_entity_reltn_id
     WITH nocounter
    ;end select
    IF (long_text_id > 0)
     DELETE  FROM long_text l
      PLAN (l
       WHERE l.long_text_id=long_text_id)
      WITH nocounter
     ;end delete
    ENDIF
    IF (dcp_entity_reltn_id > 0)
     DELETE  FROM dcp_entity_reltn d
      PLAN (d
       WHERE d.dcp_entity_reltn_id=dcp_entity_reltn_id)
      WITH nocounter
     ;end delete
    ENDIF
   ENDIF
  ENDIF
  FREE RECORD temp
 END ;Subroutine
 SUBROUTINE deletephysicianannouncement(null)
  IF (pos_cnt > 0)
   SET positioncd = request->qual[1].position_cd
   IF (positioncd > 0)
    SELECT INTO "nl:"
     p.seq
     FROM pc_announcement_text p
     PLAN (p
      WHERE p.entity_reltn_mean_text=dcp_mean
       AND expand(index,1,pos_cnt,p.position_cd,request->qual[index].position_cd))
     HEAD REPORT
      posview_cnt = 0
     DETAIL
      posview_cnt = (posview_cnt+ 1)
      IF (posview_cnt > size(temp->list,5))
       stat = alterlist(temp->list,(posview_cnt+ 10))
      ENDIF
      temp->list[posview_cnt].long_text_id = p.announcement_long_text_id, temp->list[posview_cnt].
      dcp_entity_reltn_id = p.pc_announcement_text_id
     FOOT REPORT
      temp->knt = posview_cnt, stat = alterlist(temp->list,posview_cnt)
     WITH nocounter
    ;end select
    IF ((temp->knt > 0))
     DELETE  FROM pc_announcement_text p,
       (dummyt d  WITH seq = value(temp->knt))
      SET p.seq = 1
      PLAN (d
       WHERE d.seq > 0)
       JOIN (p
       WHERE (p.pc_announcement_text_id=temp->list[d.seq].dcp_entity_reltn_id))
      WITH nocounter
     ;end delete
    ENDIF
    IF ((temp->knt > 0))
     DELETE  FROM long_text l,
       (dummyt d  WITH seq = value(temp->knt))
      SET l.seq = 1
      PLAN (d
       WHERE d.seq > 0)
       JOIN (l
       WHERE (l.long_text_id=temp->list[d.seq].long_text_id))
      WITH nocounter
     ;end delete
    ENDIF
   ELSE
    SELECT INTO "nl:"
     p.seq
     FROM pc_announcement_text p
     PLAN (p
      WHERE p.entity_reltn_mean_text=dcp_mean
       AND p.position_cd=0)
     DETAIL
      long_text_id = p.announcement_long_text_id, dcp_entity_reltn_id = p.pc_announcement_text_id
     WITH nocounter
    ;end select
    IF (dcp_entity_reltn_id > 0)
     DELETE  FROM pc_announcement_text p
      PLAN (p
       WHERE p.pc_announcement_text_id=dcp_entity_reltn_id)
      WITH nocounter
     ;end delete
    ENDIF
    IF (long_text_id > 0)
     DELETE  FROM long_text l
      PLAN (l
       WHERE l.long_text_id=long_text_id)
      WITH nocounter
     ;end delete
    ENDIF
   ENDIF
  ENDIF
  FREE RECORD temp
 END ;Subroutine
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
END GO
