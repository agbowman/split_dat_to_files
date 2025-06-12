CREATE PROGRAM cv_utl_upd_form_ref_id:dba
 PROMPT
  "Enter DATASET INTERNAL NAME: (e.g. STS or ACC02) [STS02] = " = "STS02",
  "Enter FORM DESCRIPTION NAME: (In dcp_forms_ref table) = " = " ",
  "Enter FORM_TYPE_MEAN = " = " "
 DECLARE cv_get_case_date_ec(dataset_id=f8) = f8
 DECLARE cv_get_code_by_dataset(dataset_id=f8,short_name=vc) = f8
 DECLARE cv_get_code_by(string_type=vc,code_set=i4,value=vc) = f8
 DECLARE l_case_date = vc WITH protect
 DECLARE l_case_date_dta = f8 WITH protect, noconstant(- (1.0))
 DECLARE l_case_date_ec = f8 WITH protect, noconstant(- (1.0))
 DECLARE get_code_ret = f8 WITH protect, noconstant(- (1.0))
 DECLARE dataset_prefix = vc WITH protect
 SUBROUTINE cv_get_case_date_ec(dataset_id_param)
   SET l_case_date = " "
   SET l_case_date_dta = - (1.0)
   SET l_case_date_ec = - (1.0)
   SELECT INTO "nl:"
    d.case_date_mean
    FROM cv_dataset d
    WHERE d.dataset_id=dataset_id_param
    DETAIL
     l_case_date = d.case_date_mean
    WITH nocounter
   ;end select
   IF (size(trim(l_case_date)) > 0)
    SET l_case_date_dta = cv_get_code_by("MEANING",14003,nullterm(l_case_date))
    IF (l_case_date_dta > 0.0)
     SELECT INTO "nl:"
      dta.event_cd
      FROM discrete_task_assay dta
      WHERE dta.task_assay_cd=l_case_date_dta
      DETAIL
       l_case_date_ec = dta.event_cd
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   RETURN(l_case_date_ec)
 END ;Subroutine
 SUBROUTINE cv_get_code_by_dataset(dataset_id_param,short_name)
   SET dataset_prefix = " "
   SET get_code_ret = - (1.0)
   SELECT INTO "nl:"
    d.dataset_internal_name
    FROM cv_dataset d
    WHERE d.dataset_id=dataset_id_param
    DETAIL
     CASE (d.dataset_internal_name)
      OF "STS02":
       dataset_prefix = "ST02"
      ELSE
       dataset_prefix = d.dataset_internal_name
     ENDCASE
    WITH nocounter
   ;end select
   CALL echo(build("dataset_prefix:",dataset_prefix))
   IF (size(trim(dataset_prefix)) > 0)
    SELECT INTO "nl:"
     x.event_cd
     FROM cv_xref x
     WHERE x.xref_internal_name=concat(trim(dataset_prefix),"_",short_name)
     DETAIL
      get_code_ret = x.event_cd
     WITH nocounter
    ;end select
   ENDIF
   CALL echo(build("get_code_ret:",get_code_ret))
   RETURN(get_code_ret)
 END ;Subroutine
 SUBROUTINE cv_get_code_by(string_type,code_set_param,value)
   SET get_code_ret = uar_get_code_by(nullterm(string_type),code_set_param,nullterm(trim(value)))
   IF (get_code_ret <= 0.0)
    CALL echo(concat("Failed uar_get_code_by(",string_type,",",trim(cnvtstring(code_set_param)),",",
      value,")"))
    SELECT
     IF (string_type="MEANING")
      WHERE cv.code_set=code_set_param
       AND cv.cdf_meaning=value
     ELSEIF (string_type="DISPLAYKEY")
      WHERE cv.code_set=code_set_param
       AND cv.display_key=value
     ELSEIF (string_type="DISPLAY")
      WHERE cv.code_set=code_set_param
       AND cv.display=value
     ELSEIF (string_type="DESCRIPTION")
      WHERE cv.code_set=code_set_param
       AND cv.description=value
     ELSE
      WHERE cv.code_value=0.0
     ENDIF
     INTO "nl:"
     FROM code_value cv
     DETAIL
      get_code_ret = cv.code_value
     WITH nocounter
    ;end select
    CALL echo(concat("code_value lookup result =",cnvtstring(get_code_ret)))
   ENDIF
   RETURN(get_code_ret)
 END ;Subroutine
 IF (validate(request,"notdefined") != "notdefined")
  CALL echo("Request Record is already defined!")
 ELSE
  RECORD request(
    1 application_nbr = i4
    1 parent_entity_id = f8
    1 parent_entity_name = vc
    1 person_id = f8
    1 pref_cd = f8
    1 pref_domain = vc
    1 pref_dt_tm = dq8
    1 pref_id = f8
    1 pref_name = vc
    1 pref_nbr = i4
    1 pref_section = vc
    1 pref_str = vc
    1 reference_ind = i2
  )
 ENDIF
 DECLARE re_entry = c1 WITH protect, noconstant("T")
 DECLARE form_upd_failed = c1 WITH protect, noconstant("T")
 DECLARE dataset_param = vc WITH protect, noconstant(cnvtupper(trim( $1,3)))
 DECLARE form_ref_param = vc WITH protect, noconstant(cnvtupper(trim( $2,3)))
 DECLARE form_type_mean = vc WITH protect, noconstant(trim( $3))
 DECLARE form_type_cd = f8 WITH protect
 IF (size(form_type_mean) > 0)
  SET form_type_cd = cv_get_code_by("MEANING",22309,nullterm(form_type_mean))
 ENDIF
 SELECT INTO "nl:"
  FROM cv_dataset cd
  WHERE cd.dataset_internal_name=dataset_param
  DETAIL
   request->parent_entity_id = cd.dataset_id, request->parent_entity_name = "CV_DATASET"
   IF (form_type_cd > 0.0)
    request->pref_name = build(cd.dataset_internal_name,"_",form_type_mean)
   ELSE
    request->pref_name = cd.dataset_internal_name
   ENDIF
   request->pref_cd = form_type_cd
  WITH nocounter
 ;end select
 IF (curqual=0)
  GO TO loop_ctr_script
 ENDIF
 SELECT INTO "nl:"
  FROM dcp_forms_ref dfr
  WHERE cnvtupper(trim(dfr.description,3))=form_ref_param
  DETAIL
   request->pref_str = dfr.description, request->pref_nbr = 0, request->pref_dt_tm = dfr.updt_dt_tm,
   request->pref_domain = "CVNET", request->application_nbr = 4100522, request->pref_section =
   "CV Dataset Form",
   request->parent_entity_name = "DCP_FORMS_REF", request->parent_entity_id = dfr.dcp_forms_ref_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  GO TO loop_ctr_script
 ENDIF
 SELECT INTO "nl:"
  FROM dm_prefs dp
  WHERE (dp.pref_domain=request->pref_domain)
   AND (dp.pref_section=request->pref_section)
   AND (dp.pref_name=request->pref_name)
   AND (dp.application_nbr=request->application_nbr)
  DETAIL
   request->pref_id = dp.pref_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  EXECUTE dm_ins_dm_prefs
 ELSE
  EXECUTE dm_upd_dm_prefs
 ENDIF
 SET re_entry = "F"
 SET form_upd_failed = "F"
#loop_ctr_script
 IF (re_entry="T")
  CALL echo(
   "The name entered is incorrect, type 'cv_utl_upd_form_ref_id go' and enter the correct names!")
 ENDIF
#exit_script
 IF (form_upd_failed="T")
  ROLLBACK
 ELSE
  COMMIT
  CALL echo("DM_PREFS table has been updated and action commited!")
  FREE RECORD request
 ENDIF
 DECLARE cv_utl_upd_form_ref_id_vrsn = vc WITH private, constant("MOD 004 02/24/06 BM9013")
END GO
