CREATE PROGRAM dcp_get_announcement:dba
 RECORD reply(
   1 qual_cnt = i4
   1 qual[*]
     2 text = vc
     2 postion_cd = f8
   1 announcement_text_expired_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE pos_cnt = i4 WITH constant(size(request->qual,5))
 DECLARE index = i4 WITH noconstant(0)
 DECLARE posview_cnt = i4 WITH noconstant(0)
 DECLARE type = f8
 DECLARE dcp_mean = vc WITH noconstant(fillstring(12," "))
 DECLARE positioncd = f8 WITH noconstant(0.0)
 DECLARE system_cnt = i4 WITH noconstant(0)
 DECLARE announcement_text_expired_ind = i4 WITH noconstant(0)
 DECLARE mainannouncemententrypoint(null) = null
 DECLARE getnonphysicianannouncement(null) = null
 DECLARE getphysicianannouncement(null) = null
 SET reply->status_data.status = "F"
 SET dcp_mean = fillstring(12," ")
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
    CALL getnonphysicianannouncement(null)
   ELSEIF ((request->physician_ind=1))
    CALL getphysicianannouncement(null)
   ENDIF
 END ;Subroutine
 GO TO exit_script
 SUBROUTINE getnonphysicianannouncement(null)
  IF (pos_cnt > 0)
   SELECT INTO "nl:"
    l.long_text_id
    FROM dcp_entity_reltn d,
     long_text l
    PLAN (d
     WHERE d.entity_reltn_mean=dcp_mean
      AND expand(index,1,pos_cnt,d.entity1_id,request->qual[index].position_cd)
      AND d.entity1_name="CODE_VALUE")
     JOIN (l
     WHERE l.long_text_id=d.entity2_id)
    HEAD REPORT
     posview_cnt = 0
     IF (pos_cnt=1)
      IF ((request->current_dt_tm != 0))
       IF ( NOT ((request->current_dt_tm BETWEEN d.begin_effective_dt_tm AND d.end_effective_dt_tm)))
        announcement_text_expired_ind = 1
       ENDIF
      ENDIF
     ENDIF
    DETAIL
     posview_cnt = (posview_cnt+ 1)
     IF (posview_cnt > size(reply->qual,5))
      stat = alterlist(reply->qual,(posview_cnt+ 10))
     ENDIF
     reply->qual[posview_cnt].text = l.long_text, reply->qual[posview_cnt].postion_cd = d.entity1_id,
     reply->announcement_text_expired_ind = announcement_text_expired_ind
    FOOT REPORT
     reply->qual_cnt = posview_cnt, stat = alterlist(reply->qual,posview_cnt)
    WITH nocounter
   ;end select
   IF (posview_cnt=pos_cnt)
    GO TO exit_script
   ENDIF
  ENDIF
  SELECT INTO "nl:"
   l.long_text_id
   FROM dcp_entity_reltn d,
    long_text l
   PLAN (d
    WHERE d.entity_reltn_mean=dcp_mean
     AND d.entity1_id=0
     AND d.entity1_display="SYSTEM")
    JOIN (l
    WHERE l.long_text_id=d.entity2_id)
   HEAD REPORT
    system_cnt = posview_cnt, announcement_text_expired_ind = 0
    IF (pos_cnt=1)
     IF ((request->current_dt_tm != 0))
      IF ( NOT ((request->current_dt_tm BETWEEN d.begin_effective_dt_tm AND d.end_effective_dt_tm)))
       announcement_text_expired_ind = 1
      ENDIF
     ENDIF
    ENDIF
   DETAIL
    system_cnt = (system_cnt+ 1)
    IF (system_cnt > size(reply->qual,5))
     stat = alterlist(reply->qual,(system_cnt+ 5))
    ENDIF
    reply->qual[system_cnt].text = l.long_text, reply->qual[system_cnt].postion_cd = 0.00, reply->
    announcement_text_expired_ind = announcement_text_expired_ind
   FOOT REPORT
    reply->qual_cnt = system_cnt, stat = alterlist(reply->qual,system_cnt)
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE getphysicianannouncement(null)
  IF (pos_cnt > 0)
   SELECT INTO "nl:"
    l.long_text_id
    FROM pc_announcement_text p,
     long_text l
    PLAN (p
     WHERE p.entity_reltn_mean_text=dcp_mean
      AND expand(index,1,pos_cnt,p.position_cd,request->qual[index].position_cd))
     JOIN (l
     WHERE l.long_text_id=p.announcement_long_text_id)
    HEAD REPORT
     posview_cnt = 0
     IF (pos_cnt=1)
      IF ((request->current_dt_tm != 0))
       IF ( NOT ((request->current_dt_tm BETWEEN p.beg_effective_dt_tm AND p.end_effective_dt_tm)))
        announcement_text_expired_ind = 1
       ENDIF
      ENDIF
     ENDIF
    DETAIL
     posview_cnt = (posview_cnt+ 1)
     IF (posview_cnt > size(reply->qual,5))
      stat = alterlist(reply->qual,(posview_cnt+ 10))
     ENDIF
     reply->qual[posview_cnt].text = l.long_text, reply->qual[posview_cnt].postion_cd = p.position_cd
    FOOT REPORT
     reply->qual_cnt = posview_cnt, stat = alterlist(reply->qual,posview_cnt), reply->
     announcement_text_expired_ind = announcement_text_expired_ind
    WITH nocounter
   ;end select
   IF (posview_cnt=pos_cnt)
    GO TO exit_script
   ENDIF
  ENDIF
  SELECT INTO "nl:"
   l.long_text_id
   FROM pc_announcement_text p,
    long_text l
   PLAN (p
    WHERE p.entity_reltn_mean_text=dcp_mean
     AND p.position_cd=0)
    JOIN (l
    WHERE l.long_text_id=p.announcement_long_text_id)
   HEAD REPORT
    system_cnt = posview_cnt, announcement_text_expired_ind = 0
    IF (pos_cnt=1)
     IF ((request->current_dt_tm != 0))
      IF ( NOT ((request->current_dt_tm BETWEEN p.beg_effective_dt_tm AND p.end_effective_dt_tm)))
       CALL echo(build("DEV_Inside if condition")), announcement_text_expired_ind = 1
      ENDIF
     ENDIF
    ENDIF
   DETAIL
    system_cnt = (system_cnt+ 1)
    IF (system_cnt > size(reply->qual,5))
     stat = alterlist(reply->qual,(system_cnt+ 5))
    ENDIF
    reply->qual[system_cnt].text = l.long_text, reply->qual[system_cnt].postion_cd = 0.00, reply->
    announcement_text_expired_ind = announcement_text_expired_ind
   FOOT REPORT
    reply->qual_cnt = system_cnt, stat = alterlist(reply->qual,system_cnt)
   WITH nocounter
  ;end select
 END ;Subroutine
#exit_script
 SET nreplycount = size(request->qual,5)
 IF (nreplycount=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
