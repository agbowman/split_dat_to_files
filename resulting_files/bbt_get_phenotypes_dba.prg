CREATE PROGRAM bbt_get_phenotypes:dba
 RECORD reply(
   1 qual[*]
     2 fr_nomenclature_id = f8
     2 w_nomenclature_id = f8
     2 rh_phenotype_id = f8
     2 updt_cnt = i4
     2 active_ind = i2
     2 pheno_testing[*]
       3 rh_pheno_testing_id = f8
       3 special_testing_cd = f8
       3 special_testing_disp = vc
       3 sequence = i4
       3 updt_cnt = i4
       3 active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET count2 = 0
 SET select_ok_ind = 0
 SELECT INTO "nl:"
  ptype.rh_pheno_testing_id, ptest_rec = decode(ptest.sequence,"Y","N")
  FROM bb_rh_phenotype ptype,
   (dummyt d1  WITH seq = 1),
   bb_rh_pheno_testing ptest
  PLAN (ptype
   WHERE ptype.active_ind=1)
   JOIN (d1
   WHERE d1.seq=1)
   JOIN (ptest
   WHERE ptest.rh_phenotype_id=ptype.rh_phenotype_id
    AND ptest.active_ind=1)
  ORDER BY ptype.rh_phenotype_id, ptest.sequence
  HEAD REPORT
   count1 = 0
  HEAD ptype.rh_phenotype_id
   count1 = (count1+ 1)
   IF (mod(count1,10)=1)
    stat = alterlist(reply->qual,(count1+ 9))
   ENDIF
   stat = alterlist(reply->qual,count1), reply->qual[count1].fr_nomenclature_id = ptype
   .fr_nomenclature_id, reply->qual[count1].w_nomenclature_id = ptype.w_nomenclature_id,
   reply->qual[count1].rh_phenotype_id = ptype.rh_phenotype_id, reply->qual[count1].updt_cnt = ptype
   .updt_cnt, reply->qual[count1].active_ind = ptype.active_ind,
   count2 = 0
  DETAIL
   IF (ptest_rec="Y")
    count2 = (count2+ 1)
    IF (mod(count2,10)=1)
     stat = alterlist(reply->qual[count1].pheno_testing,(count2+ 9))
    ENDIF
    reply->qual[count1].pheno_testing[count2].rh_pheno_testing_id = ptest.rh_pheno_testing_id, reply
    ->qual[count1].pheno_testing[count2].special_testing_cd = ptest.special_testing_cd, reply->qual[
    count1].pheno_testing[count2].sequence = ptest.sequence,
    reply->qual[count1].pheno_testing[count2].updt_cnt = ptest.updt_cnt, reply->qual[count1].
    pheno_testing[count2].active_ind = ptest.active_ind
   ENDIF
  FOOT  ptype.rh_phenotype_id
   stat = alterlist(reply->qual[count1].pheno_testing,count2)
  FOOT REPORT
   stat = alterlist(reply->qual,count1), select_ok_ind = 1
  WITH nocounter, outerjoin(d1), nullreport
 ;end select
 IF (select_ok_ind=1)
  IF (curqual=0)
   CALL load_process_status("Z","select bb_rh_phenotype/bb_rh_pheno_testing",
    "ZERO rows found on bb_rh_phenotype/bb_rh_pheno_testing")
  ELSE
   CALL load_process_status("S","select bb_rh_phenotype/bb_rh_pheno_testing","SUCCESS")
  ENDIF
 ELSE
  CALL load_process_status("F","select bb_rh_phenotype/bb_rh_pheno_testing",
   "Select on bb_rh_phenotype/bb_rh_pheno_testing FAILED")
 ENDIF
 GO TO exit_script
 SUBROUTINE load_process_status(sub_status,sub_process,sub_message)
   SET reply->status_data.status = sub_status
   SET count1 = (count1+ 1)
   IF (count1 > 1)
    SET stat = alter(reply->status_data.subeventstatus,(count1+ 1))
   ENDIF
   SET reply->status_data.subeventstatus[count1].operationname = sub_process
   SET reply->status_data.subeventstatus[count1].operationstatus = sub_status
   SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_get_phenotypes"
   SET reply->status_data.subeventstatus[count1].targetobjectvalue = sub_message
 END ;Subroutine
#exit_script
END GO
