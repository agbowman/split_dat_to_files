CREATE PROGRAM dcp_upd_announcement:dba
 EXECUTE prefrtl
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 cnt = i2
   1 qual[*]
     2 dcpentityreltnid = f8
     2 appprefsid = f8
 )
 FREE RECORD pref_temp
 RECORD pref_temp(
   1 knt = i4
   1 list[*]
     2 pref_id = f8
 )
 RECORD tempphysicianannouncement(
   1 cnt = i2
   1 qual[*]
     2 pcannouncementtextid = f8
     2 appprefsid = f8
 )
 SET reply->status_data.status = "F"
 SET modify = predeclare
 DECLARE longtextid = f8 WITH noconstant(0.0)
 DECLARE dcpentityreltnid = f8 WITH noconstant(0.0)
 DECLARE appprefsid = f8 WITH noconstant(0.0)
 DECLARE count1 = i4 WITH noconstant(0)
 DECLARE systemappprefsid = f8 WITH noconstant(0.0)
 DECLARE dcp_mean = vc WITH noconstant(fillstring(12," "))
 DECLARE namevalueprefsid = f8 WITH noconstant(0.0)
 DECLARE dcp_type = i2 WITH noconstant(0)
 DECLARE script_version = vc WITH noconstant(fillstring(12," "))
 DECLARE stat = i2 WITH noconstant(0)
 DECLARE pos_cnt = i4 WITH constant(size(request->qual,5))
 DECLARE beg_dt_tm = dq8 WITH noconstant
 DECLARE end_dt_tm = dq8 WITH noconstant
 DECLARE positioncd = f8 WITH noconstant(0.0)
 DECLARE mainannouncemententrypoint(null) = null
 DECLARE updatenonphysicianannouncement(null) = null
 DECLARE updatephysicianannouncement(null) = null
 DECLARE deleteallpositionlevelnonphysicianannouncement(null) = null
 DECLARE deleteallpositionlevelphysicianannouncement(null) = null
 DECLARE updatepreference(null) = null
 DECLARE updatenewprefmodel(null) = null
 DECLARE deleteuserpreference(dn=vc) = null
 DECLARE getuseridfromname(name=vc) = vc
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
 IF ((request->beg_effective_dt_tm <= 0))
  SET beg_dt_tm = cnvtdatetime(curdate,curtime)
 ELSE
  SET beg_dt_tm = cnvtdatetime(request->beg_effective_dt_tm)
 ENDIF
 IF ((request->end_effective_dt_tm <= 0))
  SET end_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00")
 ELSE
  SET end_dt_tm = cnvtdatetime(request->end_effective_dt_tm)
 ENDIF
 CALL mainannouncemententrypoint(null)
 SUBROUTINE mainannouncemententrypoint(null)
   IF ((request->physician_ind=0))
    CALL updatenonphysicianannouncement(null)
    FOR (x = 1 TO pos_cnt)
     SET positioncd = request->qual[x].position_cd
     IF (positioncd=0)
      CALL updatephysicianannouncement(null)
     ENDIF
    ENDFOR
    FOR (x = 1 TO pos_cnt)
     SET positioncd = request->qual[x].position_cd
     IF (positioncd=0)
      CALL deleteallpositionlevelnonphysicianannouncement(null)
      CALL deleteallpositionlevelphysicianannouncement(null)
     ENDIF
    ENDFOR
   ELSEIF ((request->physician_ind=1))
    CALL updatephysicianannouncement(null)
   ENDIF
   IF ((request->application_number=3202004))
    CALL updatenewprefmodel(null)
   ENDIF
   CALL updatepreference(null)
 END ;Subroutine
 GO TO exit_script
 SUBROUTINE updatenonphysicianannouncement(null)
   FOR (x = 1 TO pos_cnt)
     SET positioncd = request->qual[x].position_cd
     SET longtextid = 0.0
     IF (positioncd > 0)
      SELECT INTO "nl:"
       d.seq
       FROM dcp_entity_reltn d
       WHERE d.entity_reltn_mean=dcp_mean
        AND d.entity1_id=positioncd
        AND d.entity1_name="CODE_VALUE"
       DETAIL
        longtextid = d.entity2_id
       WITH nocounter
      ;end select
      IF (longtextid > 0)
       SELECT INTO "nl:"
        l.long_text_id
        FROM long_text l
        WHERE l.long_text_id=longtextid
        WITH nocounter, forupdate(l)
       ;end select
       IF (curqual=0)
        CALL echo("Lock row for LONG_TEXT update failed")
        GO TO exit_script
       ENDIF
       UPDATE  FROM long_text l
        SET l.long_text = request->text
        WHERE l.long_text_id=longtextid
        WITH nocounter
       ;end update
       UPDATE  FROM dcp_entity_reltn d
        SET d.begin_effective_dt_tm = cnvtdatetime(beg_dt_tm), d.end_effective_dt_tm = cnvtdatetime(
          end_dt_tm)
        WHERE d.entity2_id=longtextid
        WITH nocounter
       ;end update
      ELSE
       SELECT INTO "nl:"
        j = seq(long_data_seq,nextval)
        FROM dual
        DETAIL
         longtextid = cnvtreal(j)
        WITH format, nocounter
       ;end select
       SELECT INTO "nl:"
        j = seq(carenet_seq,nextval)
        FROM dual
        DETAIL
         dcpentityreltnid = cnvtreal(j)
        WITH format, nocounter
       ;end select
       INSERT  FROM dcp_entity_reltn d
        SET d.dcp_entity_reltn_id = dcpentityreltnid, d.entity_reltn_mean = dcp_mean, d.entity1_id =
         positioncd,
         d.entity1_display = " ", d.entity1_name = "CODE_VALUE", d.entity2_id = longtextid,
         d.entity2_display = "ANNOUNCEMENT", d.entity2_name = "LONG_BLOB", d.rank_sequence = 0,
         d.active_ind = 1, d.begin_effective_dt_tm = cnvtdatetime(beg_dt_tm), d.end_effective_dt_tm
          = cnvtdatetime(end_dt_tm),
         d.updt_cnt = 0, d.updt_id = reqinfo->updt_id, d.updt_task = reqinfo->updt_task,
         d.updt_applctx = request->application_number, d.updt_dt_tm = cnvtdatetime(curdate,curtime)
        WITH nocounter
       ;end insert
       INSERT  FROM long_text l
        SET l.long_text_id = longtextid, l.parent_entity_name = "DCP_ENTITY_RELTN", l
         .parent_entity_id = dcpentityreltnid,
         l.long_text = request->text, l.active_ind = 1, l.active_status_cd = reqdata->
         active_status_cd,
         l.active_status_prsnl_id = reqinfo->updt_id, l.active_status_dt_tm = cnvtdatetime(curdate,
          curtime3), l.updt_cnt = 0,
         l.updt_dt_tm = cnvtdatetime(curdate,curtime3), l.updt_id = reqinfo->updt_id, l.updt_applctx
          = reqinfo->updt_applctx,
         l.updt_task = reqinfo->updt_task
        WITH nocounter
       ;end insert
      ENDIF
     ELSE
      SELECT INTO "nl:"
       d.seq
       FROM dcp_entity_reltn d
       WHERE d.entity_reltn_mean=dcp_mean
        AND d.entity1_id=0
        AND d.entity1_display="SYSTEM"
       DETAIL
        longtextid = d.entity2_id
       WITH nocounter
      ;end select
      IF (longtextid > 0)
       SELECT INTO "nl:"
        l.long_text_id
        FROM long_text l
        WHERE l.long_text_id=longtextid
        WITH nocounter, forupdate(l)
       ;end select
       IF (curqual=0)
        CALL echo("Lock row for LONG_TEXT update failed")
        GO TO exit_script
       ENDIF
       UPDATE  FROM long_text l
        SET l.long_text = request->text
        WHERE l.long_text_id=longtextid
       ;end update
       UPDATE  FROM dcp_entity_reltn d
        SET d.begin_effective_dt_tm = cnvtdatetime(beg_dt_tm), d.end_effective_dt_tm = cnvtdatetime(
          end_dt_tm)
        WHERE d.entity2_id=longtextid
       ;end update
      ELSE
       SELECT INTO "nl:"
        j = seq(long_data_seq,nextval)
        FROM dual
        DETAIL
         longtextid = cnvtreal(j)
        WITH format, nocounter
       ;end select
       SELECT INTO "nl:"
        j = seq(carenet_seq,nextval)
        FROM dual
        DETAIL
         dcpentityreltnid = cnvtreal(j)
        WITH format, nocounter
       ;end select
       INSERT  FROM dcp_entity_reltn d
        SET d.dcp_entity_reltn_id = dcpentityreltnid, d.entity_reltn_mean = dcp_mean, d.entity1_id =
         0,
         d.entity1_display = "SYSTEM", d.entity1_name = " ", d.entity2_id = longtextid,
         d.entity2_display = "ANNOUNCEMENT", d.entity2_name = "LONG_BLOB", d.rank_sequence = 0,
         d.active_ind = 1, d.begin_effective_dt_tm = cnvtdatetime(beg_dt_tm), d.end_effective_dt_tm
          = cnvtdatetime(end_dt_tm),
         d.updt_cnt = 0, d.updt_id = reqinfo->updt_id, d.updt_task = reqinfo->updt_task,
         d.updt_applctx = request->application_number, d.updt_dt_tm = cnvtdatetime(curdate,curtime)
        WITH nocounter
       ;end insert
       INSERT  FROM long_text l
        SET l.long_text_id = longtextid, l.parent_entity_name = "DCP_ENTITY_RELTN", l
         .parent_entity_id = dcpentityreltnid,
         l.long_text = request->text, l.active_ind = 1, l.active_status_cd = reqdata->
         active_status_cd,
         l.active_status_prsnl_id = reqinfo->updt_id, l.active_status_dt_tm = cnvtdatetime(curdate,
          curtime3), l.updt_cnt = 0,
         l.updt_dt_tm = cnvtdatetime(curdate,curtime3), l.updt_id = reqinfo->updt_id, l.updt_applctx
          = reqinfo->updt_applctx,
         l.updt_task = reqinfo->updt_task
        WITH nocounter
       ;end insert
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE updatephysicianannouncement(null)
   FOR (x = 1 TO pos_cnt)
     SET positioncd = request->qual[x].position_cd
     SET longtextid = 0.0
     IF (positioncd > 0)
      SELECT INTO "nl:"
       p.seq
       FROM pc_announcement_text p
       WHERE p.entity_reltn_mean_text=dcp_mean
        AND p.position_cd=positioncd
       DETAIL
        longtextid = p.announcement_long_text_id
       WITH nocounter
      ;end select
      IF (longtextid > 0)
       SELECT INTO "nl:"
        l.long_text_id
        FROM long_text l
        WHERE l.long_text_id=longtextid
        WITH nocounter, forupdate(l)
       ;end select
       IF (curqual=0)
        CALL echo("Lock row for LONG_TEXT update failed")
        GO TO exit_script
       ENDIF
       UPDATE  FROM long_text l
        SET l.long_text = request->text
        WHERE l.long_text_id=longtextid
        WITH nocounter
       ;end update
       UPDATE  FROM pc_announcement_text p
        SET p.beg_effective_dt_tm = cnvtdatetime(beg_dt_tm), p.end_effective_dt_tm = cnvtdatetime(
          end_dt_tm)
        WHERE p.announcement_long_text_id=longtextid
        WITH nocounter
       ;end update
      ELSE
       SELECT INTO "nl:"
        j = seq(long_data_seq,nextval)
        FROM dual
        DETAIL
         longtextid = cnvtreal(j)
        WITH format, nocounter
       ;end select
       SELECT INTO "nl:"
        j = seq(carenet_seq,nextval)
        FROM dual
        DETAIL
         dcpentityreltnid = cnvtreal(j)
        WITH format, nocounter
       ;end select
       INSERT  FROM long_text l
        SET l.long_text_id = longtextid, l.parent_entity_name = "PC_ANNOUNCEMENT_TEXT", l
         .parent_entity_id = dcpentityreltnid,
         l.long_text = request->text, l.active_ind = 1, l.active_status_cd = reqdata->
         active_status_cd,
         l.active_status_prsnl_id = reqinfo->updt_id, l.active_status_dt_tm = cnvtdatetime(curdate,
          curtime3), l.updt_cnt = 0,
         l.updt_dt_tm = cnvtdatetime(curdate,curtime3), l.updt_id = reqinfo->updt_id, l.updt_applctx
          = reqinfo->updt_applctx,
         l.updt_task = reqinfo->updt_task
        WITH nocounter
       ;end insert
       INSERT  FROM pc_announcement_text p
        SET p.pc_announcement_text_id = dcpentityreltnid, p.entity_reltn_mean_text = dcp_mean, p
         .position_cd = positioncd,
         p.announcement_long_text_id = longtextid, p.physician_ind = request->physician_ind, p
         .beg_effective_dt_tm = cnvtdatetime(beg_dt_tm),
         p.end_effective_dt_tm = cnvtdatetime(end_dt_tm), p.updt_cnt = 0, p.updt_id = reqinfo->
         updt_id,
         p.updt_task = reqinfo->updt_task, p.updt_applctx = request->application_number, p.updt_dt_tm
          = cnvtdatetime(curdate,curtime)
        WITH nocounter
       ;end insert
      ENDIF
     ELSE
      SELECT INTO "nl:"
       p.seq
       FROM pc_announcement_text p
       WHERE p.entity_reltn_mean_text=dcp_mean
        AND p.position_cd=0
       DETAIL
        longtextid = p.announcement_long_text_id
       WITH nocounter
      ;end select
      IF (longtextid > 0)
       SELECT INTO "nl:"
        l.long_text_id
        FROM long_text l
        WHERE l.long_text_id=longtextid
        WITH nocounter, forupdate(l)
       ;end select
       IF (curqual=0)
        CALL echo("Lock row for LONG_TEXT update failed")
        GO TO exit_script
       ENDIF
       UPDATE  FROM long_text l
        SET l.long_text = request->text
        WHERE l.long_text_id=longtextid
       ;end update
       UPDATE  FROM pc_announcement_text p
        SET p.beg_effective_dt_tm = cnvtdatetime(beg_dt_tm), p.end_effective_dt_tm = cnvtdatetime(
          end_dt_tm)
        WHERE p.announcement_long_text_id=longtextid
       ;end update
      ELSE
       SELECT INTO "nl:"
        j = seq(long_data_seq,nextval)
        FROM dual
        DETAIL
         longtextid = cnvtreal(j)
        WITH format, nocounter
       ;end select
       SELECT INTO "nl:"
        j = seq(carenet_seq,nextval)
        FROM dual
        DETAIL
         dcpentityreltnid = cnvtreal(j)
        WITH format, nocounter
       ;end select
       INSERT  FROM long_text l
        SET l.long_text_id = longtextid, l.parent_entity_name = "PC_ANNOUNCEMENT_TEXT", l
         .parent_entity_id = dcpentityreltnid,
         l.long_text = request->text, l.active_ind = 1, l.active_status_cd = reqdata->
         active_status_cd,
         l.active_status_prsnl_id = reqinfo->updt_id, l.active_status_dt_tm = cnvtdatetime(curdate,
          curtime3), l.updt_cnt = 0,
         l.updt_dt_tm = cnvtdatetime(curdate,curtime3), l.updt_id = reqinfo->updt_id, l.updt_applctx
          = reqinfo->updt_applctx,
         l.updt_task = reqinfo->updt_task
        WITH nocounter
       ;end insert
       INSERT  FROM pc_announcement_text p
        SET p.pc_announcement_text_id = dcpentityreltnid, p.entity_reltn_mean_text = dcp_mean, p
         .position_cd = 0,
         p.announcement_long_text_id = longtextid, p.physician_ind = request->physician_ind, p
         .beg_effective_dt_tm = cnvtdatetime(beg_dt_tm),
         p.end_effective_dt_tm = cnvtdatetime(end_dt_tm), p.updt_cnt = 0, p.updt_id = reqinfo->
         updt_id,
         p.updt_task = reqinfo->updt_task, p.updt_applctx = request->application_number, p.updt_dt_tm
          = cnvtdatetime(curdate,curtime)
        WITH nocounter
       ;end insert
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE deleteallpositionlevelnonphysicianannouncement(null)
   SET count1 = 0
   SELECT INTO "nl:"
    d.dcp_entity_reltn_id
    FROM dcp_entity_reltn d
    WHERE d.entity_reltn_mean=dcp_mean
     AND d.entity1_name="CODE_VALUE"
     AND d.entity1_id > 0
    HEAD REPORT
     count1 = 0
    DETAIL
     count1 = (count1+ 1), stat = alterlist(temp->qual,count1), temp->qual[count1].dcpentityreltnid
      = d.dcp_entity_reltn_id
    WITH nocounter
   ;end select
   IF (count1 > 0)
    DELETE  FROM (dummyt d  WITH seq = value(count1)),
      long_text l
     SET l.seq = 1
     PLAN (d)
      JOIN (l
      WHERE l.parent_entity_name="DCP_ENTITY_RELTN"
       AND (l.parent_entity_id=temp->qual[d.seq].dcpentityreltnid))
     WITH nocounter
    ;end delete
    DELETE  FROM (dummyt d  WITH seq = value(count1)),
      dcp_entity_reltn e
     SET e.seq = 1
     PLAN (d)
      JOIN (e
      WHERE (e.dcp_entity_reltn_id=temp->qual[d.seq].dcpentityreltnid))
     WITH nocounter
    ;end delete
   ENDIF
 END ;Subroutine
 SUBROUTINE deleteallpositionlevelphysicianannouncement(null)
   SET count1 = 0
   SELECT INTO "nl:"
    p.pc_announcement_text_id
    FROM pc_announcement_text p
    WHERE p.entity_reltn_mean_text=dcp_mean
     AND p.position_cd > 0
    HEAD REPORT
     count1 = 0
    DETAIL
     count1 = (count1+ 1), stat = alterlist(tempphysicianannouncement->qual,count1),
     tempphysicianannouncement->qual[count1].pcannouncementtextid = p.pc_announcement_text_id
    WITH nocounter
   ;end select
   IF (count1 > 0)
    DELETE  FROM (dummyt d  WITH seq = value(count1)),
      pc_announcement_text p
     SET p.seq = 1
     PLAN (d)
      JOIN (p
      WHERE (p.pc_announcement_text_id=tempphysicianannouncement->qual[d.seq].pcannouncementtextid))
     WITH nocounter
    ;end delete
    DELETE  FROM (dummyt d  WITH seq = value(count1)),
      long_text l
     SET l.seq = 1
     PLAN (d)
      JOIN (l
      WHERE l.parent_entity_name="PC_ANNOUNCEMENT_TEXT"
       AND (l.parent_entity_id=tempphysicianannouncement->qual[d.seq].pcannouncementtextid))
     WITH nocounter
    ;end delete
   ENDIF
 END ;Subroutine
 SUBROUTINE updatepreference(null)
   SET systemappprefsid = 0
   SELECT INTO "nl:"
    a.app_prefs_id
    FROM app_prefs a
    WHERE (a.application_number=request->application_number)
     AND a.position_cd=0
     AND a.prsnl_id=0
    DETAIL
     systemappprefsid = a.app_prefs_id
    WITH nocounter
   ;end select
   FOR (x = 1 TO pos_cnt)
    SET positioncd = request->qual[x].position_cd
    IF (positioncd=0)
     SELECT INTO "nl:"
      FROM name_value_prefs n,
       app_prefs a
      PLAN (n
       WHERE n.pvc_name="SHOW_ANNOUNCE"
        AND n.parent_entity_name="APP_PREFS")
       JOIN (a
       WHERE a.app_prefs_id=n.parent_entity_id
        AND (a.application_number=request->application_number))
      HEAD REPORT
       knt = 0, stat = alterlist(pref_temp->list,10)
      DETAIL
       knt = (knt+ 1)
       IF (mod(knt,10)=1
        AND knt != 1)
        stat = alterlist(pref_temp->list,(knt+ 10))
       ENDIF
       pref_temp->list[knt].pref_id = n.name_value_prefs_id
      FOOT REPORT
       pref_temp->knt = knt, stat = alterlist(pref_temp->list,knt)
      WITH nocounter
     ;end select
     IF ((pref_temp->knt > 0))
      DELETE  FROM name_value_prefs n,
        (dummyt d  WITH seq = value(pref_temp->knt))
       SET n.seq = 1
       PLAN (d
        WHERE d.seq > 0)
        JOIN (n
        WHERE (n.name_value_prefs_id=pref_temp->list[d.seq].pref_id))
       WITH nocounter
      ;end delete
     ENDIF
     IF (systemappprefsid > 0)
      INSERT  FROM name_value_prefs nvp
       SET nvp.name_value_prefs_id = seq(carenet_seq,nextval), nvp.parent_entity_name = "APP_PREFS",
        nvp.parent_entity_id = systemappprefsid,
        nvp.pvc_name = "SHOW_ANNOUNCE", nvp.pvc_value = "1", nvp.active_ind = 1,
        nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), nvp.updt_id = reqinfo->updt_id, nvp
        .updt_task = reqinfo->updt_task,
        nvp.updt_applctx = reqinfo->updt_applctx, nvp.updt_cnt = 0
       WITH nocounter
      ;end insert
     ELSE
      SELECT INTO "nl:"
       j = seq(carenet_seq,nextval)
       FROM dual
       DETAIL
        appprefsid = cnvtreal(j)
       WITH format, nocounter
      ;end select
      INSERT  FROM app_prefs ap
       SET ap.app_prefs_id = appprefsid, ap.application_number = request->application_number, ap
        .position_cd = 0,
        ap.prsnl_id = 0, ap.active_ind = 1, ap.updt_dt_tm = cnvtdatetime(curdate,curtime3),
        ap.updt_id = reqinfo->updt_id, ap.updt_task = reqinfo->updt_task, ap.updt_applctx = reqinfo->
        updt_applctx,
        ap.updt_cnt = 0
       WITH nocounter
      ;end insert
      INSERT  FROM name_value_prefs nvp
       SET nvp.name_value_prefs_id = seq(carenet_seq,nextval), nvp.parent_entity_name = "APP_PREFS",
        nvp.parent_entity_id = appprefsid,
        nvp.pvc_name = "SHOW_ANNOUNCE", nvp.pvc_value = "1", nvp.active_ind = 1,
        nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), nvp.updt_id = reqinfo->updt_id, nvp
        .updt_task = reqinfo->updt_task,
        nvp.updt_applctx = reqinfo->updt_applctx, nvp.updt_cnt = 0
       WITH nocounter
      ;end insert
     ENDIF
    ELSE
     DELETE  FROM name_value_prefs n
      WHERE n.name_value_prefs_id IN (
      (SELECT
       n.name_value_prefs_id
       FROM app_prefs a,
        name_value_prefs n,
        prsnl p
       WHERE (a.application_number=request->application_number)
        AND a.prsnl_id != 0
        AND p.person_id=a.prsnl_id
        AND p.position_cd=positioncd
        AND n.parent_entity_id=a.app_prefs_id
        AND n.parent_entity_name="APP_PREFS"
        AND n.pvc_name="SHOW_ANNOUNCE"))
      WITH nocounter
     ;end delete
     SET appprefsid = 0
     SELECT INTO "nl:"
      a.app_prefs_id
      FROM app_prefs a
      WHERE (a.application_number=request->application_number)
       AND a.position_cd=positioncd
       AND a.prsnl_id=0
      DETAIL
       appprefsid = a.app_prefs_id
      WITH nocounter
     ;end select
     IF (appprefsid > 0)
      SET namevalueprefsid = 0
      SELECT INTO "nl:"
       n.name_value_prefs_id
       FROM name_value_prefs n
       WHERE n.parent_entity_id=appprefsid
        AND n.parent_entity_name="APP_PREFS"
        AND n.pvc_name="SHOW_ANNOUNCE"
       DETAIL
        namevalueprefsid = n.name_value_prefs_id
       WITH nocounter
      ;end select
      IF (namevalueprefsid > 0)
       SELECT INTO "nl:"
        n.name_value_prefs_id
        FROM name_value_prefs n
        WHERE n.name_value_prefs_id=namevalueprefsid
        WITH nocounter, forupdate(n)
       ;end select
       IF (curqual=0)
        GO TO exit_script
       ENDIF
       UPDATE  FROM name_value_prefs n
        SET n.pvc_value = "1"
        WHERE n.name_value_prefs_id=namevalueprefsid
        WITH nocounter
       ;end update
      ELSE
       INSERT  FROM name_value_prefs nvp
        SET nvp.name_value_prefs_id = seq(carenet_seq,nextval), nvp.parent_entity_name = "APP_PREFS",
         nvp.parent_entity_id = appprefsid,
         nvp.pvc_name = "SHOW_ANNOUNCE", nvp.pvc_value = "1", nvp.active_ind = 1,
         nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), nvp.updt_id = reqinfo->updt_id, nvp
         .updt_task = reqinfo->updt_task,
         nvp.updt_applctx = reqinfo->updt_applctx, nvp.updt_cnt = 0
        WITH nocounter
       ;end insert
      ENDIF
     ELSE
      SELECT INTO "nl:"
       j = seq(carenet_seq,nextval)
       FROM dual
       DETAIL
        appprefsid = cnvtreal(j)
       WITH format, nocounter
      ;end select
      INSERT  FROM app_prefs ap
       SET ap.app_prefs_id = appprefsid, ap.application_number = request->application_number, ap
        .position_cd = positioncd,
        ap.prsnl_id = 0, ap.active_ind = 1, ap.updt_dt_tm = cnvtdatetime(curdate,curtime3),
        ap.updt_id = reqinfo->updt_id, ap.updt_task = reqinfo->updt_task, ap.updt_applctx = reqinfo->
        updt_applctx,
        ap.updt_cnt = 0
       WITH nocounter
      ;end insert
      INSERT  FROM name_value_prefs nvp
       SET nvp.name_value_prefs_id = seq(carenet_seq,nextval), nvp.parent_entity_name = "APP_PREFS",
        nvp.parent_entity_id = appprefsid,
        nvp.pvc_name = "SHOW_ANNOUNCE", nvp.pvc_value = "1", nvp.active_ind = 1,
        nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), nvp.updt_id = reqinfo->updt_id, nvp
        .updt_task = reqinfo->updt_task,
        nvp.updt_applctx = reqinfo->updt_applctx, nvp.updt_cnt = 0
       WITH nocounter
      ;end insert
     ENDIF
    ENDIF
   ENDFOR
   DELETE  FROM name_value_prefs n
    WHERE n.pvc_name="SCRIPT_NAME"
     AND n.parent_entity_id != systemappprefsid
    WITH nocounter
   ;end delete
   IF (systemappprefsid > 0)
    SELECT INTO "nl:"
     FROM name_value_prefs n
     WHERE n.parent_entity_id=systemappprefsid
      AND n.parent_entity_name="APP_PREFS"
      AND n.pvc_name="SCRIPT_NAME"
      AND n.pvc_value="DO NOT DELETE! USED FOR ANNOUNCEMENTS"
     WITH nocounter
    ;end select
    IF (curqual=0)
     INSERT  FROM name_value_prefs nvp
      SET nvp.name_value_prefs_id = seq(carenet_seq,nextval), nvp.parent_entity_name = "APP_PREFS",
       nvp.parent_entity_id = systemappprefsid,
       nvp.pvc_name = "SCRIPT_NAME", nvp.pvc_value = "DO NOT DELETE! USED FOR ANNOUNCEMENTS", nvp
       .active_ind = 1,
       nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), nvp.updt_id = reqinfo->updt_id, nvp.updt_task
        = reqinfo->updt_task,
       nvp.updt_applctx = reqinfo->updt_applctx, nvp.updt_cnt = 0
      WITH nocounter
     ;end insert
    ENDIF
   ELSE
    SELECT INTO "nl:"
     j = seq(carenet_seq,nextval)
     FROM dual
     DETAIL
      appprefsid = cnvtreal(j)
     WITH format, nocounter
    ;end select
    INSERT  FROM app_prefs ap
     SET ap.app_prefs_id = appprefsid, ap.application_number = request->application_number, ap
      .position_cd = 0,
      ap.prsnl_id = 0, ap.active_ind = 1, ap.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      ap.updt_id = reqinfo->updt_id, ap.updt_task = reqinfo->updt_task, ap.updt_applctx = reqinfo->
      updt_applctx,
      ap.updt_cnt = 0
     WITH nocounter
    ;end insert
    INSERT  FROM name_value_prefs nvp
     SET nvp.name_value_prefs_id = seq(carenet_seq,nextval), nvp.parent_entity_name = "APP_PREFS",
      nvp.parent_entity_id = appprefsid,
      nvp.pvc_name = "SCRIPT_NAME", nvp.pvc_value = "DO NOT DELETE! USED FOR ANNOUNCEMENTS", nvp
      .active_ind = 1,
      nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), nvp.updt_id = reqinfo->updt_id, nvp.updt_task
       = reqinfo->updt_task,
      nvp.updt_applctx = reqinfo->updt_applctx, nvp.updt_cnt = 0
     WITH nocounter
    ;end insert
   ENDIF
 END ;Subroutine
 SUBROUTINE updatenewprefmodel(null)
   FREE RECORD userswithpref
   RECORD userswithpref(
     1 prefs[*]
       2 dn = vc
       2 personid = vc
   )
   DECLARE lprefstat = i4 WITH noconstant(0)
   DECLARE hprefdir = i4 WITH noconstant(0)
   DECLARE ientrycnt = i2 WITH noconstant(0)
   DECLARE ientry = i2 WITH noconstant(0)
   DECLARE hentry = i4 WITH private, noconstant(0)
   DECLARE sentryname = c255 WITH noconstant("")
   DECLARE ilen = i2 WITH noconstant(0)
   DECLARE npreferr = i2 WITH private, noconstant(0)
   DECLARE spreferrmsg = c255 WITH private, noconstant("")
   DECLARE lpreferrmsglen = i4 WITH noconstant(0)
   DECLARE personid = vc WITH private, noconstant("")
   SET hprefdir = uar_prefcreateinstance(18)
   IF (hprefdir > 0)
    SET lprefstat = uar_prefsetbasedn(hprefdir,nullterm("prefcontext=user,prefroot=prefroot"))
    SET lprefstat = uar_prefaddfilter(hprefdir,nullterm("prefgroup=application"))
    SET lprefstat = uar_prefaddfilter(hprefdir,nullterm("prefgroup=webexperience"))
    SET lprefstat = uar_prefaddfilter(hprefdir,nullterm("prefgroup=announcement"))
    SET lprefstat = uar_prefaddfilter(hprefdir,nullterm("prefentry=showannouncement"))
    SET lprefstat = uar_prefaddfilter(hprefdir,nullterm("prefvalue=0"))
    SET lprefstat = uar_prefperform(hprefdir)
    IF (lprefstat=1)
     SET npreferr = uar_prefgetlasterror()
     SET ientrycnt = 0
     SET lprefstat = uar_prefgetentrycount(hprefdir,ientrycnt)
     SET stat = alterlist(userswithpref->prefs,ientrycnt)
     FOR (ientry = 0 TO (ientrycnt - 1))
       SET hentry = 0
       SET hentry = uar_prefgetentry(hprefdir,ientry)
       IF (hentry > 0)
        SET ilen = 255
        SET sentryname = ""
        SET lprefstat = uar_prefgetentryname(hentry,sentryname,ilen)
        SET sentryname = substring(1,(ilen - 1),sentryname)
        SET userswithpref->prefs[(ientry+ 1)].dn = sentryname
        SET personid = getuseridfromname(sentryname)
        SET userswithpref->prefs[(ientry+ 1)].personid = trim(personid)
       ENDIF
     ENDFOR
    ELSE
     SET npreferr = uar_prefgetlasterror()
     SET lprefstat = uar_prefformatmessage(spreferrmsg,255)
    ENDIF
   ELSE
    SET npreferr = uar_prefgetlasterror()
    SET lprefstat = uar_prefformatmessage(spreferrmsg,255)
   ENDIF
   CALL uar_prefdestroyinstance(hprefdir)
   FOR (x = 1 TO pos_cnt)
    SET positioncd = request->qual[x].position_cd
    IF (positioncd=0)
     DECLARE i = i4 WITH private, noconstant(0)
     FOR (i = 1 TO ientrycnt)
       CALL deleteuserpreference(userswithpref->prefs[i].dn)
     ENDFOR
    ELSE
     DECLARE dnname = c255 WITH noconstant("")
     DECLARE count = i4 WITH public, noconstant(0)
     FREE RECORD personidrec
     RECORD personidrec(
       1 personids[*]
         2 personid = vc
     )
     SET count = 0
     SELECT INTO "nl:"
      personid = trim(format(p.person_id,"##########.##;;F"),3)
      FROM prsnl p
      WHERE (p.position_cd=request->position_cd)
       AND p.active_ind=1
       AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      HEAD REPORT
       stat = alterlist(personidrec->personids,10)
      DETAIL
       count = (count+ 1)
       IF (mod(count,10)=1
        AND count != 1)
        stat = alterlist(personidrec->personids,(count+ 9))
       ENDIF
       personidrec->personids[count].personid = personid
      FOOT REPORT
       stat = alterlist(personidrec->personids,count)
      WITH nocounter
     ;end select
     DECLARE i = i4 WITH private, noconstant(0)
     DECLARE j = i4 WITH private, noconstant(0)
     FOR (i = 1 TO count)
       FOR (j = 1 TO ientrycnt)
         IF ((personidrec->personids[i].personid=userswithpref->prefs[j].personid))
          CALL deleteuserpreference(userswithpref->prefs[j].dn)
          SET j = (ientrycnt+ 1)
         ENDIF
       ENDFOR
     ENDFOR
    ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE deleteuserpreference(dn)
   DECLARE hinst = i4 WITH private, noconstant(0)
   DECLARE hstat = i4 WITH private, noconstant(0)
   DECLARE prefdeletedn = i4 WITH private, constant(19)
   DECLARE npreferr = i4 WITH private, noconstant(0)
   DECLARE spreferrmsg = c255 WITH private, noconstant("")
   SET hinst = uar_prefcreateinstance(prefdeletedn)
   IF (hinst > 0)
    SET hstat = uar_prefadddn(hinst,nullterm(dn))
    SET hstat = uar_prefperform(hinst)
    IF (hstat=0)
     SET npreferr = uar_prefgetlasterror()
     SET hstat = uar_prefformatmessage(spreferrmsg,255)
    ENDIF
    CALL uar_prefdestroyinstance(hinst)
   ENDIF
 END ;Subroutine
 SUBROUTINE getuseridfromname(name)
   DECLARE substr = vc
   DECLARE pos = i4
   DECLARE size = i2 WITH noconstant(size(name))
   SET pos = findstring("prefgroup",name,1,1)
   SET substr = substring((pos+ 10),size,name)
   SET size = size(substr)
   SET pos = findstring(",",substr,1,0)
   RETURN(substring(1,(pos - 1),substr))
 END ;Subroutine
#exit_script
 IF (curqual=0)
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 FREE RECORD temp
 FREE RECORD pref_temp
 FREE RECORD userswithpref
 FREE RECORD tempphysicianannouncement
 SET script_version = "013 02/04/16 DM027278"
END GO
