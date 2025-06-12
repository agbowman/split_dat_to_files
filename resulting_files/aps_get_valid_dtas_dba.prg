CREATE PROGRAM aps_get_valid_dtas:dba
 RECORD reply(
   1 dta_qual[*]
     2 mnemonic = c50
     2 task_assay_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE subevent_add(op_name=vc(value),op_status=vc(value),obj_name=vc(value),obj_value=vc(value))
  = null WITH protect
 SUBROUTINE subevent_add(op_name,op_status,obj_name,obj_value)
   DECLARE se_itm = i4 WITH protect, noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
   SET se_itm = size(reply->status_data.subeventstatus,5)
   SET stat = alter(reply->status_data.subeventstatus,(se_itm+ 1))
   SET reply->status_data.subeventstatus[se_itm].operationname = cnvtupper(substring(1,25,trim(
      op_name)))
   SET reply->status_data.subeventstatus[se_itm].operationstatus = cnvtupper(substring(1,1,trim(
      op_status)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectname = cnvtupper(substring(1,25,trim(
      obj_name)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectvalue = obj_value
 END ;Subroutine
#script
 SET reply->status_data.status = "F"
 SET cnt = 0
 DECLARE sbb_activity_type = c12 WITH constant("BB")
 DECLARE lbb_processing_type_cs = i4 WITH constant(1635)
 DECLARE sno_spcl_proc_ord_type = c12 WITH constant("NO SPCL PROC")
 DECLARE lresult_processing_type_cs = i4 WITH constant(1636)
 DECLARE shistory_upd_proc_type = c12 WITH constant("HISTRY & UPD")
 DECLARE shistory_only_proc_type = c12 WITH constant("HISTRY ONLY")
 DECLARE sab_scrn_intp_proc_type = c12 WITH constant("AB SCRN INTP")
 DECLARE sabsc_ci_proc_type = c12 WITH constant("ABSC CI")
 DECLARE sno_spcl_proc_proc_type = c12 WITH constant("NO SPCL PROC")
 DECLARE lresult_type_cs = i4 WITH constant(289)
 DECLARE stext_res_type = c12 WITH constant("1")
 DECLARE salpha_res_type = c12 WITH constant("2")
 DECLARE sinterp_res_type = c12 WITH constant("4")
 DECLARE sonline_codeset_res_type = c12 WITH constant("9")
 DECLARE sactivitycdfmeaning = c12 WITH noconstant(fillstring(12," "))
 DECLARE dnospclprocordertypecd = f8 WITH noconstant(0.0)
 DECLARE dhistoryupdproctypecd = f8 WITH noconstant(0.0)
 DECLARE dhistoryonlyproctypecd = f8 WITH noconstant(0.0)
 DECLARE dabscrnintpproctypecd = f8 WITH noconstant(0.0)
 DECLARE dabscciproctypecd = f8 WITH noconstant(0.0)
 DECLARE dnospclprocproctypecd = f8 WITH noconstant(0.0)
 DECLARE dalpharesulttypecd = f8 WITH noconstant(0.0)
 DECLARE donlinecodesetresulttypecd = f8 WITH noconstant(0.0)
 DECLARE dtextresulttypecd = f8 WITH noconstant(0.0)
 DECLARE dinterpresulttypecd = f8 WITH noconstant(0.0)
 DECLARE nidx = i2 WITH noconstant(0)
 DECLARE errmsg = c132 WITH protect, noconstant(fillstring(132," "))
 DECLARE error_check = i2 WITH protect, noconstant(error(errmsg,1))
 DECLARE stat = i4 WITH protect, noconstant(0)
 SET sactivitycdfmeaning = uar_get_code_meaning(request->activity_type_cd)
 IF (sactivitycdfmeaning=sbb_activity_type)
  IF ((request->status_flag=2))
   SET dnospclprocordertypecd = uar_get_code_by("MEANING",lbb_processing_type_cs,nullterm(
     sno_spcl_proc_ord_type))
   SET dhistoryupdproctypecd = uar_get_code_by("MEANING",lresult_processing_type_cs,nullterm(
     shistory_upd_proc_type))
   SET dhistoryonlyproctypecd = uar_get_code_by("MEANING",lresult_processing_type_cs,nullterm(
     shistory_only_proc_type))
   SET dabscrnintpproctypecd = uar_get_code_by("MEANING",lresult_processing_type_cs,nullterm(
     sab_scrn_intp_proc_type))
   SET dabscciproctypecd = uar_get_code_by("MEANING",lresult_processing_type_cs,nullterm(
     sabsc_ci_proc_type))
   SET dnospclprocproctypecd = uar_get_code_by("MEANING",lresult_processing_type_cs,nullterm(
     sno_spcl_proc_proc_type))
   SET donlinecodesetresulttypecd = uar_get_code_by("MEANING",lresult_type_cs,nullterm(
     sonline_codeset_res_type))
   SET dalpharesulttypecd = uar_get_code_by("MEANING",lresult_type_cs,nullterm(salpha_res_type))
   SET dtextresulttypecd = uar_get_code_by("MEANING",lresult_type_cs,nullterm(stext_res_type))
   SET dinterpresulttypecd = uar_get_code_by("MEANING",lresult_type_cs,nullterm(sinterp_res_type))
   IF (((dnospclprocordertypecd=0.0) OR (((dhistoryupdproctypecd=0.0) OR (((dhistoryonlyproctypecd=
   0.0) OR (((dabscrnintpproctypecd=0.0) OR (((dabscciproctypecd=0.0) OR (((dnospclprocproctypecd=0.0
   ) OR (((donlinecodesetresulttypecd=0.0) OR (((dalpharesulttypecd=0.0) OR (((dtextresulttypecd=0.0)
    OR (dinterpresulttypecd=0.0)) )) )) )) )) )) )) )) )) )
    CALL subevent_add("UAR","F","code set 1635 1636 289",build("at least one code value not found: ",
      sno_spcl_proc_ord_type,",",shistory_upd_proc_type,",",
      shistory_only_proc_type,",",sab_scrn_intp_proc_type,",",sabsc_ci_proc_type,
      ",",sno_spcl_proc_proc_type,",",stext_res_type,",",
      salpha_res_type,",",sinterp_res_type,",",sonline_codeset_res_type))
    GO TO exit_script
   ENDIF
   SELECT INTO "nl:"
    dta.mnemonic
    FROM discrete_task_assay dta,
     sign_line_dta_r sldr
    PLAN (dta
     WHERE (dta.activity_type_cd=request->activity_type_cd)
      AND dta.active_ind=1)
     JOIN (sldr
     WHERE outerjoin(dta.task_assay_cd)=sldr.task_assay_cd
      AND sldr.task_assay_cd=null)
    DETAIL
     IF (dta.default_result_type_cd IN (dtextresulttypecd, dinterpresulttypecd))
      cnt = (cnt+ 1)
      IF (cnt > size(reply->dta_qual,5))
       stat = alterlist(reply->dta_qual,(cnt+ 9))
      ENDIF
      reply->dta_qual[cnt].mnemonic = dta.mnemonic, reply->dta_qual[cnt].task_assay_cd = dta
      .task_assay_cd
     ELSEIF (dta.default_result_type_cd IN (dalpharesulttypecd, donlinecodesetresulttypecd))
      IF (((dta.bb_result_processing_cd IN (dhistoryupdproctypecd, dhistoryonlyproctypecd)
       AND dta.default_result_type_cd IN (dalpharesulttypecd, donlinecodesetresulttypecd)) OR (dta
      .bb_result_processing_cd IN (dabscrnintpproctypecd, dabscciproctypecd)
       AND dta.default_result_type_cd=dalpharesulttypecd)) )
       cnt = (cnt+ 1)
       IF (cnt > size(reply->dta_qual,5))
        stat = alterlist(reply->dta_qual,(cnt+ 9))
       ENDIF
       reply->dta_qual[cnt].mnemonic = dta.mnemonic, reply->dta_qual[cnt].task_assay_cd = dta
       .task_assay_cd
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   SET error_check = error(errmsg,0)
   IF (error_check != 0)
    CALL errorhandler("F","Select bb dta information",errmsg)
    GO TO exit_script
   ENDIF
   SELECT INTO "nl:"
    dta.task_assay_cd
    FROM discrete_task_assay dta,
     profile_task_r ptr,
     service_directory sd,
     sign_line_dta_r sldr
    PLAN (dta
     WHERE (dta.activity_type_cd=request->activity_type_cd)
      AND dta.active_ind=1)
     JOIN (ptr
     WHERE dta.task_assay_cd=ptr.task_assay_cd
      AND ptr.active_ind=1)
     JOIN (sd
     WHERE ptr.catalog_cd=sd.catalog_cd)
     JOIN (sldr
     WHERE outerjoin(dta.task_assay_cd)=sldr.task_assay_cd
      AND sldr.task_assay_cd=null)
    DETAIL
     IF (dta.default_result_type_cd=dalpharesulttypecd
      AND sd.bb_processing_cd IN (dnospclprocordertypecd, 0.0)
      AND dta.bb_result_processing_cd IN (dnospclprocproctypecd, 0.0))
      nindex = locateval(nidx,1,cnt,dta.task_assay_cd,reply->dta_qual[nidx].task_assay_cd)
      IF (nindex=0)
       cnt = (cnt+ 1)
       IF (cnt > size(reply->dta_qual,5))
        stat = alterlist(reply->dta_qual,(cnt+ 9))
       ENDIF
       reply->dta_qual[cnt].mnemonic = dta.mnemonic, reply->dta_qual[cnt].task_assay_cd = dta
       .task_assay_cd
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   SET error_check = error(errmsg,0)
   IF (error_check != 0)
    CALL errorhandler("F","Select bb dta information",errmsg)
    GO TO exit_script
   ENDIF
   SET stat = alterlist(reply->dta_qual,cnt)
  ENDIF
 ELSE
  SELECT
   IF ((request->status_flag=0))INTO "nl:"
    dta.mnemonic, dta.task_assay_cd
    FROM dummyt d,
     sign_line_dta_r sldr,
     discrete_task_assay dta,
     code_value cv
    PLAN (cv
     WHERE cv.code_set=289
      AND ((cv.cdf_meaning="1") OR (cv.cdf_meaning="4")) )
     JOIN (dta
     WHERE dta.default_result_type_cd=cv.code_value
      AND (dta.activity_type_cd=request->activity_type_cd))
     JOIN (d
     WHERE 1=d.seq)
     JOIN (sldr
     WHERE sldr.task_assay_cd=dta.task_assay_cd
      AND (sldr.activity_subtype_cd=request->activity_subtype_cd)
      AND ((sldr.status_flag=0) OR (((sldr.status_flag=1) OR (sldr.status_flag=2)) )) )
   ELSEIF ((((request->status_flag=1)) OR ((request->status_flag=2))) )INTO "nl:"
    dta.mnemonic, dta.task_assay_cd
    FROM dummyt d,
     sign_line_dta_r sldr,
     discrete_task_assay dta,
     code_value cv
    PLAN (cv
     WHERE cv.code_set=289
      AND ((cv.cdf_meaning="1") OR (cv.cdf_meaning="4")) )
     JOIN (dta
     WHERE dta.default_result_type_cd=cv.code_value
      AND (dta.activity_type_cd=request->activity_type_cd))
     JOIN (d
     WHERE 1=d.seq)
     JOIN (sldr
     WHERE sldr.task_assay_cd=dta.task_assay_cd
      AND (sldr.activity_subtype_cd=request->activity_subtype_cd)
      AND ((sldr.status_flag=0) OR ((sldr.status_flag=request->status_flag))) )
   ELSE INTO "nl:"
    dta.mnemonic, dta.task_assay_cd
    FROM dummyt d,
     sign_line_dta_r sldr,
     discrete_task_assay dta,
     code_value cv
    PLAN (cv
     WHERE cv.code_set=289
      AND ((cv.cdf_meaning="1") OR (cv.cdf_meaning="4")) )
     JOIN (dta
     WHERE dta.default_result_type_cd=cv.code_value
      AND (dta.activity_type_cd=request->activity_type_cd))
     JOIN (d
     WHERE 1=d.seq)
     JOIN (sldr
     WHERE sldr.task_assay_cd=dta.task_assay_cd
      AND (sldr.activity_subtype_cd=request->activity_subtype_cd)
      AND (sldr.status_flag=request->status_flag))
   ENDIF
   HEAD REPORT
    cnt = 0, stat = alterlist(reply->dta_qual,5)
   DETAIL
    cnt = (cnt+ 1)
    IF (mod(cnt,5)=1
     AND cnt != 1)
     stat = alterlist(reply->dta_qual,(cnt+ 4))
    ENDIF
    reply->dta_qual[cnt].mnemonic = dta.mnemonic, reply->dta_qual[cnt].task_assay_cd = dta
    .task_assay_cd
   FOOT REPORT
    stat = alterlist(reply->dta_qual,cnt)
   WITH nocounter, outerjoin = d, dontexist
  ;end select
 ENDIF
 IF (size(reply->dta_qual,5)=0)
  SET reply->status_data.status = "Z"
  SET stat = alterlist(reply->dta_qual,0)
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
END GO
