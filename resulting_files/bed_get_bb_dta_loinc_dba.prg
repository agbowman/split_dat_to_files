CREATE PROGRAM bed_get_bb_dta_loinc:dba
 RECORD reply(
   1 assays[*]
     2 task_assay_cd = f8
     2 task_assay_disp = vc
     2 task_assay_desc = vc
     2 loinc_codes[*]
       3 concept_ident_bb_dta_id = f8
       3 concept_cki = vc
       3 loinc_code = vc
       3 ignore_ind = i2
       3 concept_type_flag = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET modify = predeclare
 DECLARE script_name = c24 WITH constant("bed_get_bb_dta_loinc")
 DECLARE dgen_lab_cat_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE dbb_actvty_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE dord_absc_ci_cd = f8 WITH protect, noconstant(0.0)
 DECLARE dord_antibdy_scrn_cd = f8 WITH protect, noconstant(0.0)
 DECLARE dord_pat_abo_cd = f8 WITH protect, noconstant(0.0)
 DECLARE dord_xm_cd = f8 WITH protect, noconstant(0.0)
 DECLARE dord_no_spcl_pr_cd = f8 WITH protect, noconstant(0.0)
 DECLARE dres_ab_scr_int_cd = f8 WITH protect, noconstant(0.0)
 DECLARE dres_absc_ci_cd = f8 WITH protect, noconstant(0.0)
 DECLARE dres_histry_updt_cd = f8 WITH protect, noconstant(0.0)
 DECLARE dres_histry_only_cd = f8 WITH protect, noconstant(0.0)
 DECLARE dres_no_spcl_pr_cd = f8 WITH protect, noconstant(0.0)
 DECLARE lcnt = i4 WITH protect, noconstant(0)
 DECLARE lidx = i4 WITH protect, noconstant(0)
 DECLARE lidxdtahold = i4 WITH protect, noconstant(0)
 DECLARE lidx2 = i4 WITH protect, noconstant(0)
 DECLARE lcnt2 = i4 WITH protect, noconstant(0)
 DECLARE lidxloinchold = i4 WITH protect, noconstant(0)
 DECLARE serrormsg = vc WITH protect, noconstant("")
 DECLARE error_check = i4 WITH protect, noconstant(0)
 DECLARE uar_error = vc WITH protect, noconstant("")
 DECLARE nstat = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SET nstat = uar_get_meaning_by_codeset(6000,"GENERAL LAB",1,dgen_lab_cat_type_cd)
 IF (dgen_lab_cat_type_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve catalogy type code with meaning of ","GENERAL LAB",".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SET nstat = uar_get_meaning_by_codeset(106,"BB",1,dbb_actvty_type_cd)
 IF (dbb_actvty_type_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve activity type code with meaning of ","BB",".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SET nstat = uar_get_meaning_by_codeset(1635,"PATIENT ABO",1,dord_pat_abo_cd)
 IF (dord_pat_abo_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve Ord Proc Type code with meaning of ","PATIENT ABO",".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SET nstat = uar_get_meaning_by_codeset(1635,"ABSC CI",1,dord_absc_ci_cd)
 IF (dord_absc_ci_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve Ord Proc Type code with meaning of ","ABSC CI",".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SET nstat = uar_get_meaning_by_codeset(1635,"ANTIBDY SCRN",1,dord_antibdy_scrn_cd)
 IF (dord_antibdy_scrn_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve Ord Proc Type code with meaning of ","ANTIBDY SCRN",".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SET nstat = uar_get_meaning_by_codeset(1635,"XM",1,dord_xm_cd)
 IF (dord_xm_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve Ord Proc Type code with meaning of ","XM",".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SET nstat = uar_get_meaning_by_codeset(1635,"NO SPCL PROC",1,dord_no_spcl_pr_cd)
 IF (dord_no_spcl_pr_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve Ord Proc Type code with meaning of ","NO SPCL PROC",".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SET nstat = uar_get_meaning_by_codeset(1636,"HISTRY & UPD",1,dres_histry_updt_cd)
 IF (dres_histry_updt_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve Result Proc type code with meaning of ","HISTRY & UPD",
   ".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SET nstat = uar_get_meaning_by_codeset(1636,"HISTRY ONLY",1,dres_histry_only_cd)
 IF (dres_histry_only_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve Result Proc type code with meaning of ","HISTRY ONLY",
   ".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SET nstat = uar_get_meaning_by_codeset(1636,"AB SCRN INTP",1,dres_ab_scr_int_cd)
 IF (dres_ab_scr_int_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve Result Proc type code with meaning of ","AB SCRN INTP",
   ".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SET nstat = uar_get_meaning_by_codeset(1636,"ABSC CI",1,dres_absc_ci_cd)
 IF (dres_absc_ci_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve Result Proc type code with meaning of ","ABSC CI",".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SET nstat = uar_get_meaning_by_codeset(1636,"NO SPCL PROC",1,dres_no_spcl_pr_cd)
 IF (dres_no_spcl_pr_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve Result Proc type code with meaning of ","NO SPCL PROC",
   ".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SELECT
  IF ((request->concept_type_flag=0))
   PLAN (oc
    WHERE oc.catalog_type_cd=dgen_lab_cat_type_cd
     AND oc.activity_type_cd=dbb_actvty_type_cd
     AND oc.active_ind=1)
    JOIN (sd
    WHERE sd.catalog_cd=oc.catalog_cd
     AND ((sd.bb_processing_cd+ 0) IN (dord_pat_abo_cd, dord_absc_ci_cd, dord_antibdy_scrn_cd,
    dord_xm_cd, dord_no_spcl_pr_cd,
    0.0))
     AND sd.active_ind=1)
    JOIN (ptr
    WHERE ptr.catalog_cd=sd.catalog_cd
     AND ptr.active_ind=1)
    JOIN (dta
    WHERE dta.task_assay_cd=ptr.task_assay_cd
     AND ((dta.activity_type_cd+ 0)=dbb_actvty_type_cd)
     AND ((dta.bb_result_processing_cd+ 0) IN (dres_histry_updt_cd, dres_histry_only_cd,
    dres_ab_scr_int_cd, dres_absc_ci_cd, dres_no_spcl_pr_cd,
    0.0))
     AND dta.active_ind=1)
    JOIN (cibd
    WHERE ((cibd.task_assay_cd=dta.task_assay_cd
     AND cibd.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND cibd.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
     AND cibd.active_ind=1) OR (cibd.task_assay_cd=0.0)) )
  ELSE
   PLAN (oc
    WHERE oc.catalog_type_cd=dgen_lab_cat_type_cd
     AND oc.activity_type_cd=dbb_actvty_type_cd
     AND oc.active_ind=1)
    JOIN (sd
    WHERE sd.catalog_cd=oc.catalog_cd
     AND ((sd.bb_processing_cd+ 0) IN (dord_pat_abo_cd, dord_absc_ci_cd, dord_antibdy_scrn_cd,
    dord_xm_cd, dord_no_spcl_pr_cd,
    0.0))
     AND sd.active_ind=1)
    JOIN (ptr
    WHERE ptr.catalog_cd=sd.catalog_cd
     AND ptr.active_ind=1)
    JOIN (dta
    WHERE dta.task_assay_cd=ptr.task_assay_cd
     AND ((dta.activity_type_cd+ 0)=dbb_actvty_type_cd)
     AND ((dta.bb_result_processing_cd+ 0) IN (dres_histry_updt_cd, dres_histry_only_cd,
    dres_ab_scr_int_cd, dres_absc_ci_cd, dres_no_spcl_pr_cd,
    0.0))
     AND dta.active_ind=1)
    JOIN (cibd
    WHERE ((cibd.task_assay_cd=dta.task_assay_cd
     AND cibd.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND cibd.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
     AND cibd.active_ind=1
     AND (cibd.concept_type_flag=request->concept_type_flag)) OR (cibd.task_assay_cd=0.0)) )
  ENDIF
  INTO "nl:"
  FROM order_catalog oc,
   service_directory sd,
   discrete_task_assay dta,
   profile_task_r ptr,
   concept_ident_bb_dta cibd
  ORDER BY dta.task_assay_cd
  DETAIL
   lidxdtahold = locateval(lidx,1,size(reply->assays,5),dta.task_assay_cd,reply->assays[lidx].
    task_assay_cd)
   IF (lidxdtahold=0)
    nvalidassay = 0
    IF (sd.bb_processing_cd=dord_pat_abo_cd)
     IF (dta.bb_result_processing_cd IN (dres_histry_updt_cd, dres_histry_only_cd))
      nvalidassay = 1
     ENDIF
    ENDIF
    IF (sd.bb_processing_cd IN (dord_absc_ci_cd, dord_antibdy_scrn_cd))
     IF (dta.bb_result_processing_cd IN (dres_ab_scr_int_cd, dres_absc_ci_cd))
      nvalidassay = 1
     ENDIF
    ENDIF
    IF (sd.bb_processing_cd=dord_xm_cd)
     IF (dta.bb_result_processing_cd=dres_histry_updt_cd)
      nvalidassay = 1
     ENDIF
    ENDIF
    IF (sd.bb_processing_cd IN (dord_no_spcl_pr_cd, 0.0))
     IF (dta.bb_result_processing_cd IN (dres_no_spcl_pr_cd, 0.0))
      nvalidassay = 1
     ENDIF
    ENDIF
    IF (nvalidassay=1)
     lcnt = (lcnt+ 1)
     IF (lcnt > size(reply->assays,5))
      nstat = alterlist(reply->assays[lcnt],(lcnt+ 10))
     ENDIF
     reply->assays[lcnt].task_assay_cd = dta.task_assay_cd
     IF (cibd.concept_ident_bb_dta_id > 0.0)
      lcnt2 = 1, nstat = alterlist(reply->assays[lcnt].loinc_codes,lcnt2), reply->assays[lcnt].
      loinc_codes[lcnt2].concept_ident_bb_dta_id = cibd.concept_ident_bb_dta_id,
      reply->assays[lcnt].loinc_codes[lcnt2].concept_type_flag = cibd.concept_type_flag, reply->
      assays[lcnt].loinc_codes[lcnt2].concept_cki = cibd.concept_cki, reply->assays[lcnt].
      loinc_codes[lcnt2].loinc_code = replace(cibd.concept_cki,"LOINC!","",1),
      reply->assays[lcnt].loinc_codes[lcnt2].ignore_ind = cibd.ignore_ind
     ENDIF
    ENDIF
   ELSE
    IF (cibd.concept_ident_bb_dta_id > 0.0)
     lidxloinchold = locateval(lidx2,1,size(reply->assays[lidxdtahold].loinc_codes,5),cibd
      .concept_ident_bb_dta_id,reply->assays[lidxdtahold].loinc_codes[lidx2].concept_ident_bb_dta_id)
     IF (lidxloinchold=0)
      lcnt2 = (size(reply->assays[lidxdtahold].loinc_codes,5)+ 1), nstat = alterlist(reply->assays[
       lidxdtahold].loinc_codes,lcnt2), reply->assays[lidxdtahold].loinc_codes[lcnt2].
      concept_ident_bb_dta_id = cibd.concept_ident_bb_dta_id,
      reply->assays[lidxdtahold].loinc_codes[lcnt2].concept_type_flag = cibd.concept_type_flag, reply
      ->assays[lidxdtahold].loinc_codes[lcnt2].concept_cki = cibd.concept_cki, reply->assays[
      lidxdtahold].loinc_codes[lcnt2].loinc_code = replace(cibd.concept_cki,"LOINC!","",1),
      reply->assays[lidxdtahold].loinc_codes[lcnt2].ignore_ind = cibd.ignore_ind
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SET nstat = alterlist(reply->assays,lcnt)
 SET error_check = error(serrormsg,0)
 IF (error_check != 0)
  CALL errorhandler("F","Select DTA and LOINC",serrormsg)
 ENDIF
 DECLARE errorhandler(operationstatus=c1,targetobjectname=c25,targetobjectvalue=vc) = null
 SUBROUTINE errorhandler(operationstatus,targetobjectname,targetobjectvalue)
   DECLARE error_cnt = i2 WITH private, noconstant(0)
   SET error_cnt = size(reply->status_data.subeventstatus,5)
   IF (((error_cnt > 1) OR (error_cnt=1
    AND (reply->status_data.subeventstatus[error_cnt].operationstatus != ""))) )
    SET error_cnt = (error_cnt+ 1)
    SET nstat = alter(reply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[error_cnt].operationname = script_name
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = operationstatus
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = targetobjectname
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = targetobjectvalue
   GO TO exit_script
 END ;Subroutine
 IF (lcnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#exit_script
 SET modify = nopredeclare
END GO
