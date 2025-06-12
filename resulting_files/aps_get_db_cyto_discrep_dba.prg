CREATE PROGRAM aps_get_db_cyto_discrep:dba
 RECORD reply(
   1 reference_range_factor_id = f8
   1 alpha_qual[1]
     2 nomenclature_id = f8
     2 nomenclature_disp = c40
     2 alpha_sequence = i4
   1 disc_var_qual[*]
     2 reference_range_factor_id = f8
     2 nomenclature_x_id = f8
     2 nomenclature_y_id = f8
     2 hcfa_flag = i2
     2 internal_flag = i2
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
 SET cnt = 0
 SET beg_discvar_qual_size = 5
 DECLARE reference_range_factor_id = f8 WITH protect, noconstant(0.0)
#script
 SELECT INTO "nl:"
  ar.reference_range_factor_id, ar.nomenclature_id
  FROM alpha_responses ar,
   reference_range_factor rrf,
   nomenclature n
  PLAN (rrf
   WHERE (request->diag_task_assay_cd=rrf.task_assay_cd)
    AND 1=rrf.active_ind)
   JOIN (ar
   WHERE rrf.reference_range_factor_id=ar.reference_range_factor_id
    AND ar.active_ind=1)
   JOIN (n
   WHERE ar.nomenclature_id=n.nomenclature_id)
  HEAD REPORT
   reference_range_factor_id = rrf.reference_range_factor_id, reply->reference_range_factor_id =
   reference_range_factor_id
  DETAIL
   cnt = (cnt+ 1)
   IF (cnt > 1)
    stat = alter(reply->alpha_qual,cnt)
   ENDIF
   reply->alpha_qual[cnt].nomenclature_disp = n.mnemonic, reply->alpha_qual[cnt].nomenclature_id = ar
   .nomenclature_id, reply->alpha_qual[cnt].alpha_sequence = ar.sequence
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "ALPHA RESPONSES"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "DB_CYTO_DISCREP"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF (cnt != 0)
  SET stat = alter(reply->alpha_qual,cnt)
 ELSE
  SET stat = alter(reply->alpha_qual,1)
 ENDIF
 SELECT INTO "nl:"
  cdd.reference_range_factor_id
  FROM cyto_diag_discrepancy cdd
  WHERE reference_range_factor_id=cdd.reference_range_factor_id
  HEAD REPORT
   cnt = 0, beg_discvar_qual_size = 5, stat = alterlist(reply->disc_var_qual,beg_discvar_qual_size)
  DETAIL
   cnt = (cnt+ 1)
   IF (cnt > beg_discvar_qual_size)
    stat = alterlist(reply->disc_var_qual,cnt)
   ENDIF
   reply->disc_var_qual[cnt].reference_range_factor_id = cdd.reference_range_factor_id, reply->
   disc_var_qual[cnt].nomenclature_x_id = cdd.nomenclature_x_id, reply->disc_var_qual[cnt].
   nomenclature_y_id = cdd.nomenclature_y_id,
   reply->disc_var_qual[cnt].hcfa_flag = cdd.hcfa_flag, reply->disc_var_qual[cnt].internal_flag = cdd
   .internal_flag, reply->disc_var_qual[cnt].updt_cnt = cdd.updt_cnt
  FOOT REPORT
   stat = alterlist(reply->disc_var_qual,cnt)
  WITH nocounter
 ;end select
END GO
