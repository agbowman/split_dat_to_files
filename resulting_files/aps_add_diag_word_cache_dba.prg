CREATE PROGRAM aps_add_diag_word_cache:dba
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
   1 word_qual[*]
     2 word_exists_ind = i2
 )
 DECLARE nfailed = i2 WITH noconstant(0)
 DECLARE nqualcount = i2 WITH noconstant(0)
 DECLARE ndminfoindicator = i2 WITH noconstant(0)
 DECLARE nupdateindicator = i2 WITH noconstant(0)
 DECLARE nnumbertoinsert = i2 WITH noconstant(0)
 SET reply->status_data.status = "F"
 SET nnumbertoinsert = cnvtint(size(request->word_qual,5))
 SET stat = alterlist(temp->word_qual,nnumbertoinsert)
 DECLARE initdminfoinsert(nsubdummy=i2) = i2 WITH protect
 SUBROUTINE initdminfoinsert(nsubdummy)
   EXECUTE gm_dm_info2388_def "I"
   DECLARE gm_i_dm_info2388_vc(icol_name=vc,ival=vc,iqual=i4,null_ind=i2) = i2
   DECLARE gm_i_dm_info2388_dq8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) = i2
   DECLARE gm_i_dm_info2388_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) = i2
   SUBROUTINE gm_i_dm_info2388_f8(icol_name,ival,iqual,null_ind)
     DECLARE stat = i2 WITH protect, noconstant(0)
     IF (size(gm_i_dm_info2388_req->qual,5) < iqual)
      SET stat = alterlist(gm_i_dm_info2388_req->qual,iqual)
      IF (stat=0)
       CALL echo("can not expand request structure")
       RETURN(0)
      ENDIF
     ENDIF
     CASE (cnvtlower(icol_name))
      OF "info_number":
       SET gm_i_dm_info2388_req->qual[iqual].info_number = ival
       SET gm_i_dm_info2388_req->info_numberi = 1
      OF "info_long_id":
       IF (null_ind=1)
        CALL echo("error can not set this column to null")
        RETURN(0)
       ENDIF
       SET gm_i_dm_info2388_req->qual[iqual].info_long_id = ival
       SET gm_i_dm_info2388_req->info_long_idi = 1
      ELSE
       CALL echo("invalid column name passed")
       RETURN(0)
     ENDCASE
     RETURN(1)
   END ;Subroutine
   SUBROUTINE gm_i_dm_info2388_dq8(icol_name,ival,iqual,null_ind)
     DECLARE stat = i2 WITH protect, noconstant(0)
     IF (size(gm_i_dm_info2388_req->qual,5) < iqual)
      SET stat = alterlist(gm_i_dm_info2388_req->qual,iqual)
      IF (stat=0)
       CALL echo("can not expand request structure")
       RETURN(0)
      ENDIF
     ENDIF
     CASE (cnvtlower(icol_name))
      OF "info_date":
       SET gm_i_dm_info2388_req->qual[iqual].info_date = cnvtdatetime(ival)
       SET gm_i_dm_info2388_req->info_datei = 1
      OF "updt_dt_tm":
       IF (null_ind=1)
        CALL echo("error can not set this column to null")
        RETURN(0)
       ENDIF
       SET gm_i_dm_info2388_req->qual[iqual].updt_dt_tm = cnvtdatetime(ival)
       SET gm_i_dm_info2388_req->updt_dt_tmi = 1
      ELSE
       CALL echo("invalid column name passed")
       RETURN(0)
     ENDCASE
     RETURN(1)
   END ;Subroutine
   SUBROUTINE gm_i_dm_info2388_vc(icol_name,ival,iqual,null_ind)
     DECLARE stat = i2 WITH protect, noconstant(0)
     IF (size(gm_i_dm_info2388_req->qual,5) < iqual)
      SET stat = alterlist(gm_i_dm_info2388_req->qual,iqual)
      IF (stat=0)
       CALL echo("can not expand request structure")
       RETURN(0)
      ENDIF
     ENDIF
     CASE (cnvtlower(icol_name))
      OF "info_domain":
       IF (null_ind=1)
        CALL echo("error can not set this column to null")
        RETURN(0)
       ENDIF
       SET gm_i_dm_info2388_req->qual[iqual].info_domain = ival
       SET gm_i_dm_info2388_req->info_domaini = 1
      OF "info_name":
       IF (null_ind=1)
        CALL echo("error can not set this column to null")
        RETURN(0)
       ENDIF
       SET gm_i_dm_info2388_req->qual[iqual].info_name = ival
       SET gm_i_dm_info2388_req->info_namei = 1
      OF "info_char":
       SET gm_i_dm_info2388_req->qual[iqual].info_char = ival
       SET gm_i_dm_info2388_req->info_chari = 1
      ELSE
       CALL echo("invalid column name passed")
       RETURN(0)
     ENDCASE
     RETURN(1)
   END ;Subroutine
 END ;Subroutine
 DECLARE initdminfodelete(nsubdummy=i2) = i2 WITH protect
 SUBROUTINE initdminfodelete(nsubdummy)
   EXECUTE gm_dm_info2388_def "D"
   DECLARE gm_d_dm_info2388_vc(icol_name=vc,ival=vc,iqual=i4) = i2
   SUBROUTINE gm_d_dm_info2388_vc(icol_name,ival,iqual)
     DECLARE stat = i2 WITH protect, noconstant(0)
     IF (size(gm_d_dm_info2388_req->qual,5) < iqual)
      SET stat = alterlist(gm_d_dm_info2388_req->qual,iqual)
      IF (stat=0)
       CALL echo("can not expand request structure")
       RETURN(0)
      ENDIF
     ENDIF
     CASE (cnvtlower(icol_name))
      OF "info_domain":
       SET gm_d_dm_info2388_req->qual[iqual].info_domain = ival
       SET gm_d_dm_info2388_req->info_domainw = 1
      OF "info_name":
       SET gm_d_dm_info2388_req->qual[iqual].info_name = ival
       SET gm_d_dm_info2388_req->info_namew = 1
      ELSE
       CALL echo("invalid column name passed")
       RETURN(0)
     ENDCASE
     RETURN(1)
   END ;Subroutine
 END ;Subroutine
 DECLARE initdminfoupdate(nsubdummy=i2) = i2 WITH protect
 SUBROUTINE initdminfoupdate(nsubdummy)
   EXECUTE gm_dm_info2388_def "U"
   DECLARE gm_u_dm_info2388_vc(icol_name=vc,ival=vc,iqual=i4,null_ind=i2,wq_ind=i2) = i2
   DECLARE gm_u_dm_info2388_dq8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2,wq_ind=i2) = i2
   DECLARE gm_u_dm_info2388_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2,wq_ind=i2) = i2
   DECLARE gm_u_dm_info2388_i4(icol_name=vc,ival=i4,iqual=i4,null_ind=i2,wq_ind=i2) = i2
   SUBROUTINE gm_u_dm_info2388_f8(icol_name,ival,iqual,null_ind,wq_ind)
     DECLARE stat = i2 WITH protect, noconstant(0)
     IF (size(gm_u_dm_info2388_req->qual,5) < iqual)
      SET stat = alterlist(gm_u_dm_info2388_req->qual,iqual)
      IF (stat=0)
       CALL echo("can not expand request structure")
       RETURN(0)
      ENDIF
     ENDIF
     CASE (cnvtlower(icol_name))
      OF "info_number":
       IF (null_ind=1)
        SET gm_u_dm_info2388_req->info_numberf = 2
       ELSE
        SET gm_u_dm_info2388_req->info_numberf = 1
       ENDIF
       SET gm_u_dm_info2388_req->qual[iqual].info_number = ival
       IF (wq_ind=1)
        SET gm_u_dm_info2388_req->info_numberw = 1
       ENDIF
      OF "info_long_id":
       IF (null_ind=1)
        CALL echo("error can not set this column to null")
        RETURN(0)
       ENDIF
       SET gm_u_dm_info2388_req->info_long_idf = 1
       SET gm_u_dm_info2388_req->qual[iqual].info_long_id = ival
       IF (wq_ind=1)
        SET gm_u_dm_info2388_req->info_long_idw = 1
       ENDIF
      ELSE
       CALL echo("invalid column name passed")
       RETURN(0)
     ENDCASE
     RETURN(1)
   END ;Subroutine
   SUBROUTINE gm_u_dm_info2388_i4(icol_name,ival,iqual,null_ind,wq_ind)
     DECLARE stat = i2 WITH protect, noconstant(0)
     IF (size(gm_u_dm_info2388_req->qual,5) < iqual)
      SET stat = alterlist(gm_u_dm_info2388_req->qual,iqual)
      IF (stat=0)
       CALL echo("can not expand request structure")
       RETURN(0)
      ENDIF
     ENDIF
     CASE (cnvtlower(icol_name))
      OF "updt_cnt":
       IF (null_ind=1)
        CALL echo("error can not set this column to null")
        RETURN(0)
       ENDIF
       SET gm_u_dm_info2388_req->updt_cntf = 1
       SET gm_u_dm_info2388_req->qual[iqual].updt_cnt = ival
       IF (wq_ind=1)
        SET gm_u_dm_info2388_req->updt_cntw = 1
       ENDIF
      ELSE
       CALL echo("invalid column name passed")
       RETURN(0)
     ENDCASE
     RETURN(1)
   END ;Subroutine
   SUBROUTINE gm_u_dm_info2388_dq8(icol_name,ival,iqual,null_ind,wq_ind)
     DECLARE stat = i2 WITH protect, noconstant(0)
     IF (size(gm_u_dm_info2388_req->qual,5) < iqual)
      SET stat = alterlist(gm_u_dm_info2388_req->qual,iqual)
      IF (stat=0)
       CALL echo("can not expand request structure")
       RETURN(0)
      ENDIF
     ENDIF
     CASE (cnvtlower(icol_name))
      OF "info_date":
       IF (null_ind=1)
        SET gm_u_dm_info2388_req->info_datef = 2
       ELSE
        SET gm_u_dm_info2388_req->info_datef = 1
       ENDIF
       SET gm_u_dm_info2388_req->qual[iqual].info_date = cnvtdatetime(ival)
       IF (wq_ind=1)
        SET gm_u_dm_info2388_req->info_datew = 1
       ENDIF
      OF "updt_dt_tm":
       IF (null_ind=1)
        CALL echo("error can not set this column to null")
        RETURN(0)
       ENDIF
       SET gm_u_dm_info2388_req->updt_dt_tmf = 1
       SET gm_u_dm_info2388_req->qual[iqual].updt_dt_tm = cnvtdatetime(ival)
       IF (wq_ind=1)
        SET gm_u_dm_info2388_req->updt_dt_tmw = 1
       ENDIF
      ELSE
       CALL echo("invalid column name passed")
       RETURN(0)
     ENDCASE
     RETURN(1)
   END ;Subroutine
   SUBROUTINE gm_u_dm_info2388_vc(icol_name,ival,iqual,null_ind,wq_ind)
     DECLARE stat = i2 WITH protect, noconstant(0)
     IF (size(gm_u_dm_info2388_req->qual,5) < iqual)
      SET stat = alterlist(gm_u_dm_info2388_req->qual,iqual)
      IF (stat=0)
       CALL echo("can not expand request structure")
       RETURN(0)
      ENDIF
     ENDIF
     CASE (cnvtlower(icol_name))
      OF "info_domain":
       IF (null_ind=1)
        CALL echo("error can not set this column to null")
        RETURN(0)
       ENDIF
       SET gm_u_dm_info2388_req->info_domainf = 1
       SET gm_u_dm_info2388_req->qual[iqual].info_domain = ival
       IF (wq_ind=1)
        SET gm_u_dm_info2388_req->info_domainw = 1
       ENDIF
      OF "info_name":
       IF (null_ind=1)
        CALL echo("error can not set this column to null")
        RETURN(0)
       ENDIF
       SET gm_u_dm_info2388_req->info_namef = 1
       SET gm_u_dm_info2388_req->qual[iqual].info_name = ival
       IF (wq_ind=1)
        SET gm_u_dm_info2388_req->info_namew = 1
       ENDIF
      OF "info_char":
       IF (null_ind=1)
        SET gm_u_dm_info2388_req->info_charf = 2
       ELSE
        SET gm_u_dm_info2388_req->info_charf = 1
       ENDIF
       SET gm_u_dm_info2388_req->qual[iqual].info_char = ival
       IF (wq_ind=1)
        SET gm_u_dm_info2388_req->info_charw = 1
       ENDIF
      ELSE
       CALL echo("invalid column name passed")
       RETURN(0)
     ENDCASE
     RETURN(1)
   END ;Subroutine
 END ;Subroutine
 DECLARE cleanupdminfoinsert(nsubdummy=i2) = i2 WITH protect
 SUBROUTINE cleanupdminfoinsert(nsubdummy)
  FREE RECORD gm_i_dm_info2388_req
  FREE RECORD gm_i_dm_info2388_rep
 END ;Subroutine
 DECLARE cleanupdminfodelete(nsubdummy=i2) = i2 WITH protect
 SUBROUTINE cleanupdminfodelete(nsubdummy)
  FREE RECORD gm_d_dm_info2388_req
  FREE RECORD gm_d_dm_info2388_rep
 END ;Subroutine
 DECLARE cleanupdminfoupdate(nsubdummy=i2) = i2 WITH protect
 SUBROUTINE cleanupdminfoupdate(nsubdummy)
  FREE RECORD gm_u_dm_info2388_req
  FREE RECORD gm_u_dm_info2388_rep
 END ;Subroutine
 DECLARE insertdminfo(dinfonumber=f8,sinfodomain=vc,sinfoname=vc,sinfochar=vc,dinfolongid=f8) = i2
 WITH protect
 SUBROUTINE insertdminfo(dinfonumber,sinfodomain,sinfoname,sinfochar,dinfolongid)
   SET stat = gm_i_dm_info2388_f8("info_number",dinfonumber,1,0)
   SET stat = gm_i_dm_info2388_vc("info_domain",sinfodomain,1,0)
   SET stat = gm_i_dm_info2388_vc("info_name",sinfoname,1,0)
   SET stat = gm_i_dm_info2388_vc("info_char",sinfochar,1,0)
   SET stat = gm_i_dm_info2388_f8("info_long_id",dinfolongid,1,0)
   EXECUTE gm_i_dm_info2388  WITH replace("REQUEST","GM_I_DM_INFO2388_REQ"), replace("REPLY",
    "GM_I_DM_INFO2388_REP")
   IF ((gm_i_dm_info2388_rep->status_data.status="S"))
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 DECLARE updatedminfo(dinfonumber=f8,sinfodomain=vc,sinfoname=vc,sinfochar=vc,dinfolongid=f8,
  ldminfoupdtcnt=i4) = i2 WITH protect
 SUBROUTINE updatedminfo(dinfonumber,sinfodomain,sinfoname,sinfochar,dinfolongid,ldminfoupdtcnt)
   SET stat = gm_u_dm_info2388_f8("info_number",dinfonumber,1,0,0)
   SET stat = gm_u_dm_info2388_vc("info_domain",sinfodomain,1,0,1)
   SET stat = gm_u_dm_info2388_vc("info_name",sinfoname,1,0,1)
   SET stat = gm_u_dm_info2388_vc("info_char",sinfochar,1,0,0)
   SET stat = gm_u_dm_info2388_f8("info_long_id",dinfolongid,1,0,0)
   SET stat = gm_u_dm_info2388_i4("updt_cnt",ldminfoupdtcnt,1,0,0)
   EXECUTE gm_u_dm_info2388  WITH replace("REQUEST","GM_U_DM_INFO2388_REQ"), replace("REPLY",
    "GM_U_DM_INFO2388_REP")
   IF ((gm_u_dm_info2388_rep->status_data.status="S"))
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 DECLARE deletedminfo(sinfodomain=vc,sinfoname=vc) = i2 WITH protect
 SUBROUTINE deletedminfo(sinfodomain,sinfoname)
   SET stat = gm_d_dm_info2388_vc("info_domain",sinfodomain,1)
   SET stat = gm_d_dm_info2388_vc("info_name",sinfoname,1)
   EXECUTE gm_d_dm_info2388  WITH replace("REQUEST","GM_D_DM_INFO2388_REQ"), replace("REPLY",
    "GM_D_DM_INFO2388_REP")
   IF ((gm_d_dm_info2388_rep->status_data.status="S"))
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 IF (nnumbertoinsert=0)
  SET reply->status_data.status = "S"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="ANATOMIC PATHOLOGY"
   AND di.info_name="SNOMED CACHE RANKED"
   AND di.info_number=1
  DETAIL
   ndminfoindicator = 1
  WITH nocounter
 ;end select
 IF (ndminfoindicator=0)
  UPDATE  FROM ap_diag_word_cache adwc
   SET adwc.cache_ranking = 0
   WHERE 1=1
   WITH nocounter
  ;end update
  CALL initdminfoinsert(0)
  SET stat = insertdminfo(1.0,"ANATOMIC PATHOLOGY","SNOMED CACHE RANKED","",0.0)
  IF (stat=0)
   SET nfailed = 1
  ENDIF
  CALL cleanupdminfoinsert(0)
  IF (nfailed=1)
   SET reply->status_data.subeventstatus[1].operationname = "Insert"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "DM_INFO"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "Call to dm_info table failed..."
   SET reply->status_data.status = "F"
   ROLLBACK
   GO TO exit_script
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM ap_diag_word_cache adwc,
   (dummyt d  WITH seq = value(nnumbertoinsert))
  PLAN (d)
   JOIN (adwc
   WHERE (adwc.source_vocabulary_cd=request->source_vocabulary_cd)
    AND (adwc.diagnostic_word=request->word_qual[d.seq].word1))
  DETAIL
   temp->word_qual[d.seq].word_exists_ind = 1, nupdateindicator = 1
  WITH nocounter, forupdate(adwc)
 ;end select
 IF (nupdateindicator=1)
  UPDATE  FROM ap_diag_word_cache adwc,
    (dummyt d  WITH seq = value(nnumbertoinsert))
   SET adwc.word_frequency = (adwc.word_frequency+ request->word_qual[d.seq].word_hits), adwc
    .cache_ranking = ((adwc.word_frequency+ request->word_qual[d.seq].word_hits) * request->
    word_qual[d.seq].phrase_cnt), adwc.last_cache_ind = 1,
    adwc.updt_cnt = (adwc.updt_cnt+ 1), adwc.updt_dt_tm = cnvtdatetime(curdate,curtime3), adwc
    .updt_id = reqinfo->updt_id,
    adwc.updt_task = reqinfo->updt_task, adwc.updt_applctx = reqinfo->updt_applctx
   PLAN (d
    WHERE (temp->word_qual[d.seq].word_exists_ind=1))
    JOIN (adwc
    WHERE (adwc.source_vocabulary_cd=request->source_vocabulary_cd)
     AND (adwc.diagnostic_word=request->word_qual[d.seq].word1))
   WITH nocounter
  ;end update
  SET nqualcount = (nqualcount+ curqual)
  IF (nqualcount=nnumbertoinsert)
   SET reply->status_data.status = "S"
   COMMIT
   GO TO exit_script
  ENDIF
 ENDIF
 INSERT  FROM ap_diag_word_cache adwc,
   (dummyt d  WITH seq = value(nnumbertoinsert))
  SET adwc.diagnostic_word = request->word_qual[d.seq].word1, adwc.snglr_diagnostic_word = request->
   word_qual[d.seq].singular_form_of_word1, adwc.source_vocabulary_cd = request->source_vocabulary_cd,
   adwc.word_frequency = request->word_qual[d.seq].word_frequency, adwc.last_cache_ind = 1, adwc
   .cache_ranking = (request->word_qual[d.seq].word_frequency * request->word_qual[d.seq].phrase_cnt),
   adwc.updt_cnt = 0, adwc.updt_dt_tm = cnvtdatetime(curdate,curtime3), adwc.updt_id = reqinfo->
   updt_id,
   adwc.updt_task = reqinfo->updt_task, adwc.updt_applctx = reqinfo->updt_applctx
  PLAN (d
   WHERE (temp->word_qual[d.seq].word_exists_ind != 1))
   JOIN (adwc)
  WITH nocounter
 ;end insert
 SET nqualcount = (nqualcount+ curqual)
 IF (nqualcount != nnumbertoinsert)
  SET reply->status_data.subeventstatus[1].operationname = "Insert"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "AP_DIAG_WORD_CACHE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "nQualCount != nNumberToInsert..."
  SET reply->status_data.status = "F"
  ROLLBACK
 ELSE
  SET reply->status_data.status = "S"
  COMMIT
 ENDIF
#exit_script
END GO
