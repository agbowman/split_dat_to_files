CREATE PROGRAM br_get_auto_processes:dba
 FREE SET reply
 RECORD reply(
   1 qual[*]
     2 step_cat_mean = vc
     2 plist[*]
       3 process_name = vc
       3 process_ind = i2
       3 hide_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 RECORD pcotemp(
   1 plist[25]
     2 process_name = vc
 )
 SET pcocnt = 25
 SET pcotemp->plist[1].process_name = "REGSCHED"
 SET pcotemp->plist[2].process_name = "CHARTPREP"
 SET pcotemp->plist[3].process_name = "CHECKIN"
 SET pcotemp->plist[4].process_name = "PTINTAKE"
 SET pcotemp->plist[5].process_name = "PROVASSESS"
 SET pcotemp->plist[6].process_name = "EASYSCRIPT"
 SET pcotemp->plist[7].process_name = "SUPERBILL"
 SET pcotemp->plist[8].process_name = "NONPROVVISIT"
 SET pcotemp->plist[9].process_name = "CHECKOUT"
 SET pcotemp->plist[10].process_name = "MEDADMIN"
 SET pcotemp->plist[11].process_name = "IMMADMIN"
 SET pcotemp->plist[12].process_name = "ORDERCOMP"
 SET pcotemp->plist[13].process_name = "RESULTNOTIFY"
 SET pcotemp->plist[14].process_name = "PHONEMSG"
 SET pcotemp->plist[15].process_name = "MEDREFILL"
 SET pcotemp->plist[16].process_name = "COSIGN"
 SET pcotemp->plist[17].process_name = "SIGNTRANS"
 SET pcotemp->plist[18].process_name = "HIM"
 SET pcotemp->plist[19].process_name = "TRANS"
 SET pcotemp->plist[20].process_name = "CHGENTRY"
 SET pcotemp->plist[21].process_name = "BILLCLAIM"
 SET pcotemp->plist[22].process_name = "REPORTING"
 SET pcotemp->plist[23].process_name = "POWERNOTE"
 SET pcotemp->plist[24].process_name = "ALLDOCTYPES"
 SET pcotemp->plist[25].process_name = "PROFILESANDFORMS"
 SET reply->status_data.status = "F"
 SET catcnt = size(request->clist,5)
 IF (catcnt=0)
  SET reply->status_data.subeventstatus[1].operationname = "select"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "BR_GET_AUTO_PROCESSES"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Invalid script call."
  GO TO exit_script
 ELSE
  SET stat = alterlist(reply->qual,catcnt)
 ENDIF
 FOR (x = 1 TO catcnt)
  SET reply->qual[x].step_cat_mean = request->clist[x].step_cat_mean
  IF ((request->clist[x].step_cat_mean="PCO"))
   SET stat = alterlist(reply->qual[x].plist,pcocnt)
   FOR (y = 1 TO pcocnt)
     SET reply->qual[x].plist[y].process_name = pcotemp->plist[y].process_name
     SET reply->qual[x].plist[y].process_ind = 0
     SET reply->qual[x].plist[y].hide_ind = 0
     IF ((pcotemp->plist[y].process_name="REGSCHED"))
      SET reply->qual[x].plist[y].hide_ind = 1
      SELECT INTO "nl:"
       FROM br_name_value bnv
       PLAN (bnv
        WHERE bnv.br_nv_key1="STEP_CAT_MEAN"
         AND bnv.br_name IN ("ERM", "ESM")
         AND bnv.default_selected_ind=1)
       DETAIL
        reply->qual[x].plist[y].hide_ind = 0
       WITH nocounter
      ;end select
      IF ((reply->qual[x].plist[y].hide_ind=1))
       SELECT INTO "nl:"
        FROM br_name_value bnv
        PLAN (bnv
         WHERE bnv.br_nv_key1="SOLUTION_STATUS"
          AND bnv.br_name IN ("GOING_LIVE", "LIVE_IN_PROD")
          AND bnv.br_value IN ("ERM", "ESM"))
        DETAIL
         reply->qual[x].plist[y].hide_ind = 0
        WITH nocounter
       ;end select
      ENDIF
     ELSEIF ((pcotemp->plist[y].process_name="BILLCLAIM"))
      SET reply->qual[x].plist[y].hide_ind = 1
      SELECT INTO "nl:"
       FROM br_name_value bnv
       PLAN (bnv
        WHERE bnv.br_nv_key1="STEP_CAT_MEAN"
         AND bnv.br_name="PROFIT"
         AND bnv.default_selected_ind=1)
       DETAIL
        reply->qual[x].plist[y].hide_ind = 0
       WITH nocounter
      ;end select
      IF ((reply->qual[x].plist[y].hide_ind=1))
       SELECT INTO "nl:"
        FROM br_name_value bnv
        PLAN (bnv
         WHERE bnv.br_nv_key1="SOLUTION_STATUS"
          AND bnv.br_name IN ("GOING_LIVE", "LIVE_IN_PROD")
          AND bnv.br_value="PROFIT")
        DETAIL
         reply->qual[x].plist[y].hide_ind = 0
        WITH nocounter
       ;end select
      ENDIF
     ENDIF
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = pcocnt),
     br_name_value bnv
    PLAN (d)
     JOIN (bnv
     WHERE bnv.br_nv_key1="AUTOPROCESSES"
      AND (bnv.br_name=reply->qual[x].plist[d.seq].process_name))
    DETAIL
     IF (cnvtint(bnv.br_value)=1)
      reply->qual[x].plist[d.seq].process_ind = 1
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
 ENDFOR
 SET reply->status_data.status = "S"
#exit_script
 CALL echorecord(reply)
END GO
