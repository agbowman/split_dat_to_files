CREATE PROGRAM bbt_get_person_phenotype:dba
 RECORD reply(
   1 person_rh_phenotype_id = f8
   1 rh_phenotype_id = f8
   1 updt_cnt = i4
   1 fisher_race_disp = vc
   1 fr_nomenclature_id = f8
   1 wiener_disp = vc
   1 w_nomenclature_id = f8
   1 person_rh_pheno_rs_id = f8
   1 person_rh_pheno_rs_updt_cnt = i4
   1 antigenlist[*]
     2 person_antigen_id = f8
     2 antigen_cd = f8
     2 antigen_disp = c40
     2 updt_cnt = i4
   1 donor_rh_phenotype_id = f8
   1 dn_rh_phenotype_id = f8
   1 donor_updt_cnt = i4
   1 donor_fisher_race_disp = vc
   1 donor_fr_nomenclature_id = f8
   1 donor_wiener_disp = vc
   1 donor_w_nomenclature_id = f8
   1 donor_rh_pheno_rs_id = f8
   1 donor_rh_pheno_rs_updt_cnt = i4
   1 donor_antigenlist[*]
     2 donor_antigen_id = f8
     2 antigen_cd = f8
     2 antigen_disp = c40
     2 updt_cnt = i4
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
 SET type_cnt = 0
 SET qual_cnt = 0
 SET pa_cnt = 0
 SET select_ok_ind = 0
 SET stat = alterlist(reply->antigenlist,10)
 SELECT INTO "nl:"
  ptype.person_id, ptype.person_rh_phenotype_id, ptype.rh_phenotype_id,
  ptype.updt_cnt, btype.fr_nomenclature_id, btype.w_nomenclature_id,
  btype.rh_phenotype_id, table_ind = decode(ptype_r.seq,"PTR",pa.seq,"PA",n.seq,
   "NM","XX"), n.nomenclature_id,
  n.short_string"##########", pa.person_antigen_id, pa.antigen_cd,
  pa.updt_cnt, ptype_r.person_rh_pheno_rs_id, ptype_r.updt_cnt
  FROM person_rh_phenotype ptype,
   bb_rh_phenotype btype,
   (dummyt d  WITH seq = 1),
   nomenclature n,
   person_antigen pa,
   person_rh_pheno_result ptype_r
  PLAN (ptype
   WHERE ptype.active_ind=1
    AND (ptype.person_id=request->person_id))
   JOIN (btype
   WHERE btype.rh_phenotype_id=ptype.rh_phenotype_id
    AND btype.active_ind=1)
   JOIN (d
   WHERE d.seq=1)
   JOIN (((n
   WHERE ((n.nomenclature_id=btype.fr_nomenclature_id) OR (n.nomenclature_id=btype.w_nomenclature_id
   )) )
   ) ORJOIN ((((pa
   WHERE pa.person_rh_phenotype_id=ptype.person_rh_phenotype_id
    AND pa.active_ind=1)
   ) ORJOIN ((ptype_r
   WHERE ptype_r.person_rh_phenotype_id=ptype.person_rh_phenotype_id
    AND ptype_r.active_ind=1)
   )) ))
  ORDER BY ptype.person_rh_phenotype_id, table_ind
  HEAD REPORT
   select_ok_ind = 0, qual_cnt = 0, pa_cnt = 0
  HEAD ptype.person_rh_phenotype_id
   qual_cnt += 1, reply->person_rh_phenotype_id = ptype.person_rh_phenotype_id, reply->
   rh_phenotype_id = ptype.rh_phenotype_id,
   reply->updt_cnt = ptype.updt_cnt
  DETAIL
   IF (table_ind="NM")
    IF (btype.fr_nomenclature_id=n.nomenclature_id)
     reply->fisher_race_disp = n.short_string, reply->fr_nomenclature_id = btype.fr_nomenclature_id
    ELSEIF (btype.w_nomenclature_id=n.nomenclature_id)
     reply->wiener_disp = n.short_string, reply->w_nomenclature_id = btype.w_nomenclature_id
    ENDIF
   ELSEIF (table_ind="PA")
    pa_cnt += 1
    IF (mod(pa_cnt,10)=1
     AND pa_cnt != 1)
     stat = alterlist(reply->antigenlist,(pa_cnt+ 9))
    ENDIF
    reply->antigenlist[pa_cnt].person_antigen_id = pa.person_antigen_id, reply->antigenlist[pa_cnt].
    antigen_cd = pa.antigen_cd, reply->antigenlist[pa_cnt].updt_cnt = pa.updt_cnt
   ELSEIF (table_ind="PTR")
    reply->person_rh_pheno_rs_id = ptype_r.person_rh_pheno_rs_id, reply->person_rh_pheno_rs_updt_cnt
     = ptype_r.updt_cnt
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->antigenlist,pa_cnt), select_ok_ind = 1
  WITH nullreport, nocounter
 ;end select
 IF (select_ok_ind=1)
  IF (qual_cnt=0)
   CALL load_process_status("Z","select person_rh_phenotype",concat(
     "ZERO - no active person_rh_phenotype rows for person_id=",cnvtstring(request->person_id,32,2)))
  ELSEIF (qual_cnt=1)
   CALL load_process_status("S","select person_rh_phenotype","SUCCESS")
  ELSE
   CALL load_process_status("F","select person_rh_phenotype",
    "Multiple active person_rh_phenotype rows.  Cannot retrieve person rh_phenotype")
  ENDIF
 ELSE
  CALL load_process_status("F","select person_rh_phenotype","Select failed.  CCL Error.")
 ENDIF
 GO TO exit_script
 SUBROUTINE load_process_status(sub_status,sub_process,sub_message)
   SET reply->status_data.status = sub_status
   SET count1 += 1
   IF (count1 > 1)
    SET stat = alter(reply->status_data.subeventstatus,(count1+ 1))
   ENDIF
   SET reply->status_data.subeventstatus[count1].operationname = sub_process
   SET reply->status_data.subeventstatus[count1].operationstatus = sub_status
   SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_get_person_phenotype"
   SET reply->status_data.subeventstatus[count1].targetobjectvalue = sub_message
 END ;Subroutine
#exit_script
END GO
