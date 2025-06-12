CREATE PROGRAM bed_ens_prsnl_notify:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE physician_ind = i2
 SET position_cnt = 0
 SET position_cnt = size(request->poslist,5)
 SET retain_physician_ind = validate(request->retain_physician_ind,0)
 FOR (pos = 1 TO position_cnt)
   SET person_cnt = 0
   SET person_cnt = size(request->poslist[pos].plist,5)
   FOR (per = 1 TO person_cnt)
     IF ((request->poslist[pos].plist[per].action_flag=1))
      SELECT INTO "nl:"
       FROM br_position_cat_comp bpcc
       PLAN (bpcc
        WHERE (bpcc.position_cd=request->poslist[pos].position_cd))
       DETAIL
        physician_ind = bpcc.physician_ind
       WITH nocounter
      ;end select
      IF (curqual=0)
       SELECT INTO "nl:"
        FROM prsnl p
        PLAN (p
         WHERE (p.person_id=request->poslist[pos].plist[per].person_id))
        DETAIL
         physician_ind = p.physician_ind
        WITH nocounter
       ;end select
       IF (curqual=0)
        SET physician_ind = 0
       ENDIF
      ENDIF
      IF ((request->poslist[pos].update_prsnl_flag=1))
       UPDATE  FROM prsnl pr
        SET pr.position_cd = request->poslist[pos].position_cd, pr.physician_ind =
         IF (retain_physician_ind=1) pr.physician_ind
         ELSE physician_ind
         ENDIF
         , pr.updt_dt_tm = cnvtdatetime(curdate,curtime),
         pr.updt_id = reqinfo->updt_id, pr.updt_task = reqinfo->updt_task, pr.updt_cnt = (pr.updt_cnt
         + 1),
         pr.updt_applctx = reqinfo->updt_applctx
        WHERE (pr.person_id=request->poslist[pos].plist[per].person_id)
        WITH nocounter
       ;end update
      ENDIF
     ELSEIF ((request->poslist[pos].plist[per].action_flag=3))
      IF ((request->poslist[pos].update_prsnl_flag=1))
       UPDATE  FROM prsnl pr
        SET pr.position_cd = 0.0, pr.updt_dt_tm = cnvtdatetime(curdate,curtime), pr.updt_id = reqinfo
         ->updt_id,
         pr.updt_task = reqinfo->updt_task, pr.updt_cnt = (pr.updt_cnt+ 1), pr.updt_applctx = reqinfo
         ->updt_applctx
        WHERE (pr.person_id=request->poslist[pos].plist[per].person_id)
        WITH nocounter
       ;end update
      ENDIF
     ENDIF
   ENDFOR
 ENDFOR
 GO TO exitscript
#exitscript
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
END GO
