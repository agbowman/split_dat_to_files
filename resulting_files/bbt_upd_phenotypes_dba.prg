CREATE PROGRAM bbt_upd_phenotypes:dba
 RECORD reply(
   1 qual[*]
     2 rh_phenotype_id = f8
     2 pheno_testing[*]
       3 rh_pheno_testing_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET qual_cnt = 0
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET nbr_ptype = 0
 SET nbr_ptest = 0
 SET new_phenotype_id = 0.0
 SET new_phenotest_id = 0.0
 SET ptype_cnt = 0
 SET ptest_cnt = 0
 SET stat = alterlist(reply->qual,10)
 SET ptype_cnt = size(request->qual,5)
 FOR (nbr_ptype = 1 TO ptype_cnt)
   IF ((request->qual[nbr_ptype].rh_phenotype_id=0))
    SET new_phenotype_id = next_pathnet_seq(0)
    IF (curqual=0)
     CALL load_process_status("F","get next pathnet_seq",build(
       "get next pathnet_seq failed--rh_phenotype_id =",request->qual[nbr_ptype].rh_phenotype_id))
     GO TO exit_script
    ENDIF
    INSERT  FROM bb_rh_phenotype ptype
     SET ptype.rh_phenotype_id = new_phenotype_id, ptype.w_nomenclature_id = request->qual[nbr_ptype]
      .w_nomenclature_id, ptype.fr_nomenclature_id = request->qual[nbr_ptype].fr_nomenclature_id,
      ptype.updt_cnt = 0, ptype.updt_dt_tm = cnvtdatetime(curdate,curtime3), ptype.updt_id = reqinfo
      ->updt_id,
      ptype.updt_task = reqinfo->updt_task, ptype.updt_applctx = reqinfo->updt_applctx, ptype
      .active_ind = 1,
      ptype.active_status_cd = reqdata->active_status_cd, ptype.active_status_dt_tm = cnvtdatetime(
       curdate,curtime3), ptype.active_status_prsnl_id = reqinfo->updt_id
     WITH nocounter
    ;end insert
    IF (curqual=0)
     CALL load_process_status("F","insert into bb_rh_phenotype",build(
       "insert into bb_rh_phenotype failed--rh_phenotype_id =",request->qual[nbr_ptype].
       rh_phenotype_id))
     GO TO exit_script
    ENDIF
    CALL process_pheno_testing(nbr_ptype,new_phenotype_id)
    SET stat = alterlist(reply->qual,nbr_ptype)
    SET reply->qual[nbr_ptype].rh_phenotype_id = new_phenotype_id
   ELSE
    IF ((request->qual[nbr_ptype].phenotype_change_ind=1))
     SELECT INTO "nl:"
      ptype.rh_phenotype_id
      FROM bb_rh_phenotype ptype
      WHERE (ptype.rh_phenotype_id=request->qual[nbr_ptype].rh_phenotype_id)
      WITH nocounter, forupdate(ptype)
     ;end select
     IF (curqual=0)
      CALL load_process_status("F","lock bb_rh_phenotype forupdate",build(
        "lock bb_rh_phenotype forupdate failed--rh_phenotype_id =",request->qual[nbr_ptype].
        rh_phenotype_id))
      GO TO exit_script
     ENDIF
     UPDATE  FROM bb_rh_phenotype ptype
      SET ptype.w_nomenclature_id = request->qual[nbr_ptype].w_nomenclature_id, ptype
       .fr_nomenclature_id = request->qual[nbr_ptype].fr_nomenclature_id, ptype.updt_cnt = (request->
       qual[nbr_ptype].updt_cnt+ 1),
       ptype.updt_dt_tm = cnvtdatetime(curdate,curtime3), ptype.updt_id = reqinfo->updt_id, ptype
       .updt_task = reqinfo->updt_task,
       ptype.updt_applctx = reqinfo->updt_applctx, ptype.active_ind = request->qual[nbr_ptype].
       active_ind, ptype.active_status_cd =
       IF ((request->qual[nbr_ptype].active_ind=1)) reqdata->active_status_cd
       ELSE reqdata->inactive_status_cd
       ENDIF
       ,
       ptype.active_status_dt_tm = cnvtdatetime(curdate,curtime3), ptype.active_status_prsnl_id =
       reqinfo->updt_id
      WHERE (ptype.rh_phenotype_id=request->qual[nbr_ptype].rh_phenotype_id)
       AND (ptype.updt_cnt=request->qual[nbr_ptype].updt_cnt)
      WITH nocounter
     ;end update
     IF (curqual=0)
      CALL load_process_status("F","update into bb_rh_pheno_type",build(
        "update into bb_rh_phenotype failed--rh_phenotype_id =",request->qual[nbr_ptype].
        rh_phenotype_id))
      GO TO exit_script
     ENDIF
    ENDIF
    CALL process_pheno_testing(nbr_ptype,request->qual[nbr_ptype].rh_phenotype_id)
   ENDIF
 ENDFOR
 CALL load_process_status("S","SUCCESS","All records added/updated successfully")
 GO TO exit_script
 SUBROUTINE process_pheno_testing(nptype,phenotype_id)
   SET stat = alterlist(reply->qual,10)
   SET ptest_cnt = size(request->qual[nptype].pheno_testing,5)
   FOR (nbr_ptest = 1 TO ptest_cnt)
     IF ((request->qual[nptype].pheno_testing[nbr_ptest].rh_pheno_testing_id=0.0))
      SET new_phenotest_id = next_pathnet_seq(0)
      IF (curqual=0)
       CALL load_process_status("F","get next pathnet_seq",build(
         "get next pathnet_seq failed--bb_pheno_testing_id =",request->qual[nptype].pheno_testing[
         nbr_ptest].rh_pheno_testing_id))
       GO TO exit_script
      ENDIF
      INSERT  FROM bb_rh_pheno_testing ptest
       SET ptest.rh_pheno_testing_id = new_phenotest_id, ptest.rh_phenotype_id = phenotype_id, ptest
        .special_testing_cd = request->qual[nptype].pheno_testing[nbr_ptest].special_testing_cd,
        ptest.sequence = request->qual[nptype].pheno_testing[nbr_ptest].sequence, ptest.updt_cnt = 0,
        ptest.updt_dt_tm = cnvtdatetime(curdate,curtime3),
        ptest.updt_id = reqinfo->updt_id, ptest.updt_task = reqinfo->updt_task, ptest.updt_applctx =
        reqinfo->updt_applctx,
        ptest.active_ind = 1, ptest.active_status_cd = reqdata->active_status_cd, ptest
        .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
        ptest.active_status_prsnl_id = reqinfo->updt_id
       WITH nocounter
      ;end insert
      IF (curqual=0)
       CALL load_process_status("F","insert into bb_rh_pheno_testing",build(
         "insert into bb_rh_pheno_testing failed--rh_pheno_testing_id =",request->qual[nptype].
         pheno_testing[nbr_ptest].rh_pheno_testing_id))
       GO TO exit_script
      ENDIF
      SET qual_cnt = (qual_cnt+ 1)
      IF (mod(qual_cnt,10)=1
       AND qual_cnt != 1)
       SET stat = alterlist(reply->qual[nptype].pheno_testing,(qual_cnt+ 9))
      ENDIF
     ELSE
      SELECT INTO "nl:"
       ptest.rh_pheno_testing_id
       FROM bb_rh_pheno_testing ptest
       WHERE (ptest.rh_pheno_testing_id=request->qual[nptype].pheno_testing[nbr_ptest].
       rh_pheno_testing_id)
        AND (ptest.updt_cnt=request->qual[nptype].pheno_testing[nbr_ptest].updt_cnt)
       WITH nocounter, forupdate(ptest)
      ;end select
      IF (curqual=0)
       CALL load_process_status("F","lock bb_rh_pheno_testing forupdate",build(
         "lock bb_rh_pheno_testing forupdate failed--rh_pheno_testing_id, updt_cnt =",request->qual[
         nptype].pheno_testing[nbr_ptest].rh_pheno_testing_id,request->qual[nptype].pheno_testing[
         nbr_ptest].updt_cnt))
       GO TO exit_script
      ENDIF
      UPDATE  FROM bb_rh_pheno_testing ptest
       SET ptest.sequence = request->qual[nptype].pheno_testing[nbr_ptest].sequence, ptest
        .special_testing_cd = request->qual[nptype].pheno_testing[nbr_ptest].special_testing_cd,
        ptest.updt_cnt = (ptest.updt_cnt+ 1),
        ptest.updt_dt_tm = cnvtdatetime(curdate,curtime3), ptest.updt_id = reqinfo->updt_id, ptest
        .updt_task = reqinfo->updt_task,
        ptest.updt_applctx = reqinfo->updt_applctx, ptest.active_ind = request->qual[nptype].
        pheno_testing[nbr_ptest].active_ind, ptest.active_status_cd =
        IF ((request->qual[nptype].pheno_testing[nbr_ptest].active_ind=1)) reqdata->active_status_cd
        ELSE reqdata->inactive_status_cd
        ENDIF
        ,
        ptest.active_status_dt_tm = cnvtdatetime(curdate,curtime3), ptest.active_status_prsnl_id =
        reqinfo->updt_id
       WHERE (ptest.rh_pheno_testing_id=request->qual[nptype].pheno_testing[nbr_ptest].
       rh_pheno_testing_id)
        AND (ptest.updt_cnt=request->qual[nptype].pheno_testing[nbr_ptest].updt_cnt)
       WITH nocounter
      ;end update
      IF (curqual=0)
       CALL load_process_status("F","update into bb_rh_pheno_testing",build(
         "update into bb_rh_pheno_testing failed--rh_pheno_testing_id =",request->qual[nptype].
         pheno_testing[nbr_ptest].rh_pheno_testing_id))
       GO TO exit_script
      ENDIF
     ENDIF
   ENDFOR
   SET stat = alterlist(reply->qual[nptype].pheno_testing,ptest_cnt)
 END ;Subroutine
 DECLARE next_pathnet_seq(pathnet_seq_dummy) = f8
 DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
 SUBROUTINE next_pathnet_seq(pathnet_seq_dummy)
   SET new_pathnet_seq = 0.0
   SELECT INTO "nl:"
    seqn = seq(pathnet_seq,nextval)
    FROM dual
    DETAIL
     new_pathnet_seq = seqn
    WITH format, nocounter
   ;end select
   RETURN(new_pathnet_seq)
 END ;Subroutine
 SUBROUTINE load_process_status(sub_status,sub_process,sub_message)
   SET reply->status_data.status = sub_status
   SET count1 = (count1+ 1)
   IF (count1 > 1)
    SET stat = alter(reply->status_data.subeventstatus,(count1+ 1))
   ENDIF
   SET reply->status_data.subeventstatus[count1].operationname = sub_process
   SET reply->status_data.subeventstatus[count1].operationstatus = sub_status
   SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_upd_phenotypes"
   SET reply->status_data.subeventstatus[count1].targetobjectvalue = sub_message
 END ;Subroutine
#exit_script
 IF ((reply->status_data.status="S"))
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
