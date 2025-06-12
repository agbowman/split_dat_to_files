CREATE PROGRAM cv_upd_sts_part_prefs:dba
 PROMPT
  "Enter Participant Number = " = " ",
  "Enter Dataset Internal Name [STS03] = " = "STS03",
  "Enable Harvest Export of 'Cost Link' (Y/N) [Y] = " = "Y",
  "Enable Harvest Export of 'STS Trial Link Number' (Y/N) [Y] = " = "Y",
  "Enable Harvest Export of 'Date of Birth' (Y/N) [Y] = " = "Y",
  "Enable Harvest Export of 'Patient Zip Code' (Y/N) [Y] = " = "Y",
  "Enable Harvest Export of 'Surgeon ID' (Y/N) [Y] = " = "Y"
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
 EXECUTE gm_code_value0619_def "U"
 DECLARE gm_u_code_value0619_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_code_value0619_i4(icol_name=vc,ival=i4,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_code_value0619_vc(icol_name=vc,ival=vc,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_code_value0619_i2(icol_name=vc,ival=i2,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_code_value0619_dq8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 SUBROUTINE gm_u_code_value0619_f8(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_code_value0619_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_code_value0619_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "code_value":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_code_value0619_req->code_valuef = 1
     SET gm_u_code_value0619_req->qual[iqual].code_value = ival
     IF (wq_ind=1)
      SET gm_u_code_value0619_req->code_valuew = 1
     ENDIF
    OF "active_type_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_code_value0619_req->active_type_cdf = 1
     SET gm_u_code_value0619_req->qual[iqual].active_type_cd = ival
     IF (wq_ind=1)
      SET gm_u_code_value0619_req->active_type_cdw = 1
     ENDIF
    OF "data_status_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_code_value0619_req->data_status_cdf = 1
     SET gm_u_code_value0619_req->qual[iqual].data_status_cd = ival
     IF (wq_ind=1)
      SET gm_u_code_value0619_req->data_status_cdw = 1
     ENDIF
    OF "data_status_prsnl_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_code_value0619_req->data_status_prsnl_idf = 1
     SET gm_u_code_value0619_req->qual[iqual].data_status_prsnl_id = ival
     IF (wq_ind=1)
      SET gm_u_code_value0619_req->data_status_prsnl_idw = 1
     ENDIF
    OF "active_status_prsnl_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_code_value0619_req->active_status_prsnl_idf = 1
     SET gm_u_code_value0619_req->qual[iqual].active_status_prsnl_id = ival
     IF (wq_ind=1)
      SET gm_u_code_value0619_req->active_status_prsnl_idw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_u_code_value0619_i2(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_code_value0619_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_code_value0619_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "active_ind":
     IF (null_ind=1)
      SET gm_u_code_value0619_req->active_indf = 2
     ELSE
      SET gm_u_code_value0619_req->active_indf = 1
     ENDIF
     SET gm_u_code_value0619_req->qual[iqual].active_ind = ival
     IF (wq_ind=1)
      SET gm_u_code_value0619_req->active_indw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_u_code_value0619_i4(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_code_value0619_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_code_value0619_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "code_set":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_code_value0619_req->code_setf = 1
     SET gm_u_code_value0619_req->qual[iqual].code_set = ival
     IF (wq_ind=1)
      SET gm_u_code_value0619_req->code_setw = 1
     ENDIF
    OF "collation_seq":
     IF (null_ind=1)
      SET gm_u_code_value0619_req->collation_seqf = 2
     ELSE
      SET gm_u_code_value0619_req->collation_seqf = 1
     ENDIF
     SET gm_u_code_value0619_req->qual[iqual].collation_seq = ival
     IF (wq_ind=1)
      SET gm_u_code_value0619_req->collation_seqw = 1
     ENDIF
    OF "updt_cnt":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_code_value0619_req->updt_cntf = 1
     SET gm_u_code_value0619_req->qual[iqual].updt_cnt = ival
     IF (wq_ind=1)
      SET gm_u_code_value0619_req->updt_cntw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_u_code_value0619_dq8(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_code_value0619_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_code_value0619_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "active_dt_tm":
     IF (null_ind=1)
      SET gm_u_code_value0619_req->active_dt_tmf = 2
     ELSE
      SET gm_u_code_value0619_req->active_dt_tmf = 1
     ENDIF
     SET gm_u_code_value0619_req->qual[iqual].active_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_code_value0619_req->active_dt_tmw = 1
     ENDIF
    OF "inactive_dt_tm":
     IF (null_ind=1)
      SET gm_u_code_value0619_req->inactive_dt_tmf = 2
     ELSE
      SET gm_u_code_value0619_req->inactive_dt_tmf = 1
     ENDIF
     SET gm_u_code_value0619_req->qual[iqual].inactive_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_code_value0619_req->inactive_dt_tmw = 1
     ENDIF
    OF "updt_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_code_value0619_req->updt_dt_tmf = 1
     SET gm_u_code_value0619_req->qual[iqual].updt_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_code_value0619_req->updt_dt_tmw = 1
     ENDIF
    OF "begin_effective_dt_tm":
     IF (null_ind=1)
      SET gm_u_code_value0619_req->begin_effective_dt_tmf = 2
     ELSE
      SET gm_u_code_value0619_req->begin_effective_dt_tmf = 1
     ENDIF
     SET gm_u_code_value0619_req->qual[iqual].begin_effective_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_code_value0619_req->begin_effective_dt_tmw = 1
     ENDIF
    OF "end_effective_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_code_value0619_req->end_effective_dt_tmf = 1
     SET gm_u_code_value0619_req->qual[iqual].end_effective_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_code_value0619_req->end_effective_dt_tmw = 1
     ENDIF
    OF "data_status_dt_tm":
     IF (null_ind=1)
      SET gm_u_code_value0619_req->data_status_dt_tmf = 2
     ELSE
      SET gm_u_code_value0619_req->data_status_dt_tmf = 1
     ENDIF
     SET gm_u_code_value0619_req->qual[iqual].data_status_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_code_value0619_req->data_status_dt_tmw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_u_code_value0619_vc(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_code_value0619_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_code_value0619_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "cdf_meaning":
     IF (null_ind=1)
      SET gm_u_code_value0619_req->cdf_meaningf = 2
     ELSE
      SET gm_u_code_value0619_req->cdf_meaningf = 1
     ENDIF
     SET gm_u_code_value0619_req->qual[iqual].cdf_meaning = ival
     IF (wq_ind=1)
      SET gm_u_code_value0619_req->cdf_meaningw = 1
     ENDIF
    OF "display":
     IF (null_ind=1)
      SET gm_u_code_value0619_req->displayf = 2
     ELSE
      SET gm_u_code_value0619_req->displayf = 1
     ENDIF
     SET gm_u_code_value0619_req->qual[iqual].display = ival
     IF (wq_ind=1)
      SET gm_u_code_value0619_req->displayw = 1
     ENDIF
    OF "display_key":
     SET gm_u_code_value0619_req->qual[iqual].display_key = ival
     IF (wq_ind=1)
      SET gm_u_code_value0619_req->display_keyw = 1
     ENDIF
    OF "description":
     IF (null_ind=1)
      SET gm_u_code_value0619_req->descriptionf = 2
     ELSE
      SET gm_u_code_value0619_req->descriptionf = 1
     ENDIF
     SET gm_u_code_value0619_req->qual[iqual].description = ival
     IF (wq_ind=1)
      SET gm_u_code_value0619_req->descriptionw = 1
     ENDIF
    OF "definition":
     IF (null_ind=1)
      SET gm_u_code_value0619_req->definitionf = 2
     ELSE
      SET gm_u_code_value0619_req->definitionf = 1
     ENDIF
     SET gm_u_code_value0619_req->qual[iqual].definition = ival
     IF (wq_ind=1)
      SET gm_u_code_value0619_req->definitionw = 1
     ENDIF
    OF "cki":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_code_value0619_req->ckif = 1
     SET gm_u_code_value0619_req->qual[iqual].cki = ival
     IF (wq_ind=1)
      SET gm_u_code_value0619_req->ckiw = 1
     ENDIF
    OF "concept_cki":
     IF (null_ind=1)
      SET gm_u_code_value0619_req->concept_ckif = 2
     ELSE
      SET gm_u_code_value0619_req->concept_ckif = 1
     ENDIF
     SET gm_u_code_value0619_req->qual[iqual].concept_cki = ival
     IF (wq_ind=1)
      SET gm_u_code_value0619_req->concept_ckiw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 DECLARE upd_code_value_table(code_value=f8,code_set=i4,meaning=vc) = i2
 DECLARE part_str = vc WITH constant(trim( $1)), protect
 DECLARE part_nbr = i4 WITH constant(cnvtint(part_str)), protect
 DECLARE dataset_internal_name = vc WITH constant(trim( $2)), protect
 DECLARE ds_id = f8 WITH noconstant(0.0), protect
 DECLARE pref_failed = c1 WITH private, noconstant("T")
 DECLARE dataset_prefix = vc WITH protect
 DECLARE part_pool_mean = vc WITH protect
 DECLARE part_pool_cd = f8 WITH noconstant(0.0), protect
 DECLARE ret = i2 WITH protect, noconstant(0)
 FREE RECORD sts_opt_fields
 RECORD sts_opt_fields(
   1 opt_field[*]
     2 opt_field_name = vc
     2 opt_field_id = f8
 )
 IF (validate(cv_action,"notdefined") != "notdefined")
  CALL echo("cv_action record is already defined!")
 ELSE
  RECORD cv_action(
    1 action_list[*]
      2 pref_name = vc
      2 pref_section = vc
      2 pref_str = vc
      2 pref_id = f8
      2 pref_ind = i2
      2 pref_nbr = i4
      2 dataset_id = f8
  )
 ENDIF
 IF (part_nbr=0)
  CALL echo("Participant number must be non-zero")
  GO TO exit_script
 ENDIF
 IF (dataset_internal_name="STS02")
  SET dataset_prefix = "ST02"
 ELSE
  SET dataset_prefix = dataset_internal_name
 ENDIF
 SELECT INTO "nl:"
  FROM cv_dataset cd
  WHERE cd.dataset_internal_name=dataset_internal_name
  DETAIL
   ds_id = cd.dataset_id, part_pool_mean = cd.alias_pool_mean
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("Dataset is not in cv_dataset table!")
  GO TO exit_script
 ENDIF
 SET part_pool_cd = cv_get_code_by("MEANING",263,nullterm(part_pool_mean))
 IF (part_pool_cd <= 0.0)
  CALL echo("No Participant alias_pool_cd found")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM organization_alias oa
  WHERE oa.alias=part_str
   AND ((oa.alias_pool_cd+ 0)=part_pool_cd)
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo(build("Participant not found for part_str:",part_str))
  GO TO exit_script
 ENDIF
 DECLARE patid_pool_cd = f8 WITH noconstant(0.0), protect
 DECLARE patid_pool_mean = vc WITH protect
 DECLARE patid_disp_pre = vc WITH constant("STS Patient ID")
 DECLARE patid_mean_pre = vc WITH constant("STSPID")
 DECLARE patid_disp_key = vc
 DECLARE patid_disp = vc
 DECLARE patid_mean = vc
 DECLARE patid_mean_cur = vc
 SET patid_disp = concat(patid_disp_pre,part_str)
 SET patid_disp_key = concat(trim(cnvtupper(cnvtalphanum(patid_disp_pre))),part_str)
 SET patid_mean = concat(patid_mean_pre,part_str)
 CALL echo(concat("disp_key:",patid_disp_key,":"))
 CALL echo(concat("mean:",patid_mean,":"))
 SELECT INTO "nl:"
  cv.code_value, cv.cdf_meaning
  FROM code_value cv
  WHERE cv.display_key=patid_disp_key
   AND cv.code_set=263
   AND cv.active_ind=1
  DETAIL
   patid_pool_cd = cv.code_value, patid_mean_cur = cv.cdf_meaning
  WITH nocounter
 ;end select
 IF (patid_pool_cd > 0.0)
  IF (patid_mean != patid_mean_cur)
   SELECT INTO "nl:"
    FROM common_data_foundation cdf
    WHERE cdf.code_set=263
     AND cdf.cdf_meaning=patid_mean
    WITH nocounter
   ;end select
   IF (curqual=0)
    INSERT  FROM common_data_foundation cdf
     SET cdf.code_set = 263, cdf.cdf_meaning = patid_mean, cdf.updt_dt_tm = cnvtdatetime(curdate,
       curtime),
      cdf.display = patid_disp, cdf.definition = patid_disp
     WITH nocounter
    ;end insert
   ENDIF
   SET ret = upd_code_value_table(patid_pool_cd,263,patid_mean)
   IF (ret=0)
    CALL echo(build("FAILED in updating Patient ID alias pool cdf_meaning:",patid_mean))
   ELSE
    CALL echo(build("UPDATED Patient ID alias pool cdf_meaning:",patid_mean))
   ENDIF
  ELSE
   CALL echo(build("VERIFIED Patient ID alias pool already has correct meaning:",patid_mean))
  ENDIF
 ELSE
  CALL echo(build("FAILED to find Patient ID alias pool for participant:",part_str))
 ENDIF
 SET stat = alterlist(sts_opt_fields->opt_field,5)
 SET sts_opt_fields->opt_field[1].opt_field_name = "COSTLINK"
 SET sts_opt_fields->opt_field[2].opt_field_name = "STSTLINK"
 SET sts_opt_fields->opt_field[3].opt_field_name = "DOB"
 SET sts_opt_fields->opt_field[4].opt_field_name = "PATZIP"
 SET sts_opt_fields->opt_field[5].opt_field_name = "SURGID"
 SET stat = alterlist(cv_action->action_list,5)
 SET cv_action->action_list[1].pref_str = trim(cnvtupper( $3),3)
 SET cv_action->action_list[2].pref_str = trim(cnvtupper( $4),3)
 SET cv_action->action_list[3].pref_str = trim(cnvtupper( $5),3)
 SET cv_action->action_list[4].pref_str = trim(cnvtupper( $6),3)
 SET cv_action->action_list[5].pref_str = trim(cnvtupper( $7),3)
 DECLARE ctrl_cnt = i4 WITH private, noconstant(0)
 DECLARE ctrl_idx = i4 WITH private, noconstant(0)
 SET ctrl_cnt = size(cv_action->action_list,5)
 FOR (ctrl_idx = 1 TO ctrl_cnt)
   SET cv_action->action_list[ctrl_idx].pref_section = trim(cnvtupper(concat("OPTIONAL_FIELD_",
      part_str)),3)
   SET cv_action->action_list[ctrl_idx].dataset_id = ds_id
   SET cv_action->action_list[ctrl_idx].pref_nbr = part_nbr
 ENDFOR
 SELECT INTO "nl:"
  FROM cv_xref cx,
   (dummyt d  WITH seq = size(sts_opt_fields->opt_field,5))
  PLAN (d)
   JOIN (cx
   WHERE cx.xref_internal_name=concat(dataset_prefix,"_",sts_opt_fields->opt_field[d.seq].
    opt_field_name))
  DETAIL
   sts_opt_fields->opt_field[d.seq].opt_field_id = cx.xref_id, sts_opt_fields->opt_field[d.seq].
   opt_field_name = trim(cnvtupper(cx.xref_internal_name),3)
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("xref is not in cv_xref table!")
  GO TO exit_script
 ENDIF
 IF (validate(request,"notdefined") != "notdefined")
  CALL echo("Request Record is already defined!")
 ELSE
  RECORD request(
    1 application_nbr = i4
    1 parent_entity_id = f8
    1 parent_entity_name = c32
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
 SELECT INTO "nl:"
  FROM dm_prefs dp,
   (dummyt d  WITH seq = value(ctrl_cnt))
  PLAN (d)
   JOIN (dp
   WHERE dp.pref_domain IN ("CVNET", "CVNet")
    AND (dp.pref_section=cv_action->action_list[d.seq].pref_section)
    AND (dp.pref_name=sts_opt_fields->opt_field[d.seq].opt_field_name)
    AND dp.parent_entity_name="CV_DATASET"
    AND (dp.parent_entity_id=cv_action->action_list[d.seq].dataset_id))
  DETAIL
   cv_action->action_list[d.seq].pref_ind = 1, cv_action->action_list[d.seq].pref_id = dp.pref_id
  WITH nocounter
 ;end select
 IF (curqual > 0)
  CALL echo("Previous records were sent for updating!")
 ELSE
  CALL echo("New records were sent for insertion!")
 ENDIF
 CALL echorecord(cv_action)
 FOR (ctrl_idx = 1 TO ctrl_cnt)
   SET request->application_nbr = 4100522
   SET request->parent_entity_id = cv_action->action_list[ctrl_idx].dataset_id
   SET request->parent_entity_name = "CV_DATASET"
   SET request->pref_cd = sts_opt_fields->opt_field[ctrl_idx].opt_field_id
   SET request->pref_domain = "CVNET"
   SET request->pref_id = cv_action->action_list[ctrl_idx].pref_id
   SET request->pref_name = sts_opt_fields->opt_field[ctrl_idx].opt_field_name
   SET request->pref_section = cv_action->action_list[ctrl_idx].pref_section
   SET request->pref_str = cv_action->action_list[ctrl_idx].pref_str
   SET request->pref_nbr = cv_action->action_list[ctrl_idx].pref_nbr
   SET request->pref_dt_tm = cnvtdatetime(curdate,curtime3)
   SET request->reference_ind = 1
   IF ((cv_action->action_list[ctrl_idx].pref_ind=0))
    EXECUTE dm_ins_dm_prefs
   ELSE
    EXECUTE dm_upd_dm_prefs
   ENDIF
 ENDFOR
 SET pref_failed = "F"
 SUBROUTINE upd_code_value_table(code_value,code_set,meaning)
   CALL gm_u_code_value0619_f8("code_value",code_value,1,0,1)
   CALL gm_u_code_value0619_i4("code_set",code_set,1,0,1)
   CALL gm_u_code_value0619_vc("cdf_meaning",meaning,1,0,0)
   CALL gm_u_code_value0619_i2("active_ind",1,1,0,0)
   SET gm_u_code_value0619_req->force_updt_ind = 1
   EXECUTE gm_u_code_value0619_nouar  WITH replace("REQUEST",gm_u_code_value0619_req), replace(
    "REPLY",gm_u_code_value0619_rep)
   IF ((gm_u_code_value0619_rep->curqual=1)
    AND (gm_u_code_value0619_rep->qual[1].status=1))
    RETURN(1)
   ELSEIF ((gm_u_code_value0619_rep->curqual > 1))
    CALL echo("Updating multiple rows not allowed.")
    RETURN(0)
   ELSEIF ((gm_u_code_value0619_rep->curqual=0))
    CALL echo("Did not attempt to update any rows.")
    RETURN(0)
   ELSEIF ((gm_u_code_value0619_rep->qual[1].status=0))
    CALL echo("Attempt to update code_value table failed.")
    RETURN(0)
   ENDIF
   RETURN(0)
 END ;Subroutine
#exit_script
 IF (pref_failed="T")
  ROLLBACK
  CALL echo("Exit without updating optional fields!")
 ELSE
  COMMIT
  CALL echo("DM_pref table has been updated and action commited!")
  FREE RECORD request
 ENDIF
 DECLARE cv_upd_sts_part_prefs_vrsn = vc WITH private, constant("MOD 003 BM9013 02/23/06")
END GO
