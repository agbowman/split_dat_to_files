CREATE PROGRAM bhs_dup_mrn_load_temp_child:dba
 DECLARE ml_mrn_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_qual_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_loop = i4 WITH protect, noconstant(0)
 DECLARE ms_err_msg = vc WITH protect, noconstant("")
 SET ml_mrn_cnt = size(requestin->list_0,5)
 FOR (ml_loop = 1 TO ml_mrn_cnt)
   IF (textlen(requestin->list_0[ml_loop].end_eff_dt_tm) <= 1
    AND (requestin->list_0[ml_loop].facilitycode IN ("BMRN", "FMRN", "MMRN", "WMRN")))
    SELECT INTO "nl:"
     FROM bhs_dup_mrn c
     WHERE (c.cn=requestin->list_0[ml_loop].cmrn)
     WITH nocounter
    ;end select
    IF (curqual=0)
     CASE (requestin->list_0[ml_loop].facilitycode)
      OF "BMRN":
       INSERT  FROM bhs_dup_mrn j
        SET j.cn = requestin->list_0[ml_loop].cmrn, j.bmc_mrn = requestin->list_0[ml_loop].facilityid,
         j.bmc_processed_ind = 0,
         j.fmc_processed_ind = 0, j.mlh_processed_ind = 0, j.bwh_processed_ind = 0,
         j.updt_cnt = 0, j.updt_dt_tm = cnvtdatetime(curdate,curtime3), j.updt_id = reqinfo->updt_id
        WITH nocounter
       ;end insert
      OF "FMRN":
       INSERT  FROM bhs_dup_mrn j
        SET j.cn = requestin->list_0[ml_loop].cmrn, j.fmc_mrn = requestin->list_0[ml_loop].facilityid,
         j.bmc_processed_ind = 0,
         j.fmc_processed_ind = 0, j.mlh_processed_ind = 0, j.bwh_processed_ind = 0,
         j.updt_cnt = 0, j.updt_dt_tm = cnvtdatetime(curdate,curtime3), j.updt_id = reqinfo->updt_id
        WITH nocounter
       ;end insert
      OF "MMRN":
       INSERT  FROM bhs_dup_mrn j
        SET j.cn = requestin->list_0[ml_loop].cmrn, j.mlh_mrn = requestin->list_0[ml_loop].facilityid,
         j.bmc_processed_ind = 0,
         j.fmc_processed_ind = 0, j.mlh_processed_ind = 0, j.bwh_processed_ind = 0,
         j.updt_cnt = 0, j.updt_dt_tm = cnvtdatetime(curdate,curtime3), j.updt_id = reqinfo->updt_id
        WITH nocounter
       ;end insert
      OF "WMRN":
       INSERT  FROM bhs_dup_mrn j
        SET j.cn = requestin->list_0[ml_loop].cmrn, j.bwh_mrn = requestin->list_0[ml_loop].facilityid,
         j.bmc_processed_ind = 0,
         j.fmc_processed_ind = 0, j.mlh_processed_ind = 0, j.bwh_processed_ind = 0,
         j.updt_cnt = 0, j.updt_dt_tm = cnvtdatetime(curdate,curtime3), j.updt_id = reqinfo->updt_id
        WITH nocounter
       ;end insert
     ENDCASE
    ELSE
     CASE (requestin->list_0[ml_loop].facilitycode)
      OF "BMRN":
       UPDATE  FROM bhs_dup_mrn b
        SET b.bmc_mrn = requestin->list_0[ml_loop].facilityid, b.updt_cnt = (b.updt_cnt+ 1), b
         .updt_dt_tm = cnvtdatetime(curdate,curtime3),
         b.updt_id = reqinfo->updt_id
        WHERE (b.cn=requestin->list_0[ml_loop].cmrn)
       ;end update
      OF "FMRN":
       UPDATE  FROM bhs_dup_mrn b
        SET b.fmc_mrn = requestin->list_0[ml_loop].facilityid, b.updt_cnt = (b.updt_cnt+ 1), b
         .updt_dt_tm = cnvtdatetime(curdate,curtime3),
         b.updt_id = reqinfo->updt_id
        WHERE (b.cn=requestin->list_0[ml_loop].cmrn)
       ;end update
      OF "MMRN":
       UPDATE  FROM bhs_dup_mrn b
        SET b.mlh_mrn = requestin->list_0[ml_loop].facilityid, b.updt_cnt = (b.updt_cnt+ 1), b
         .updt_dt_tm = cnvtdatetime(curdate,curtime3),
         b.updt_id = reqinfo->updt_id
        WHERE (b.cn=requestin->list_0[ml_loop].cmrn)
       ;end update
      OF "WMRN":
       UPDATE  FROM bhs_dup_mrn b
        SET b.bwh_mrn = requestin->list_0[ml_loop].facilityid, b.updt_cnt = (b.updt_cnt+ 1), b
         .updt_dt_tm = cnvtdatetime(curdate,curtime3),
         b.updt_id = reqinfo->updt_id
        WHERE (b.cn=requestin->list_0[ml_loop].cmrn)
       ;end update
     ENDCASE
    ENDIF
    SET ml_qual_cnt = (ml_qual_cnt+ curqual)
    IF (error(ms_err_msg,1) > 0)
     ROLLBACK
    ELSE
     COMMIT
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 CALL echo("****************************")
 CALL echo(build("Requestin cnt = ",ml_mrn_cnt))
 CALL echo(build("Qual cnt      = ",ml_qual_cnt))
 CALL echo("----------------------------")
END GO
