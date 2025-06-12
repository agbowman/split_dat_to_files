CREATE PROGRAM dcp_cnv_ccow_config:dba
 DECLARE contributor_sys_code = f8 WITH noconstant(0.0)
 DECLARE alias_field_cd = f8 WITH noconstant(0.0)
 DECLARE count = i2 WITH noconstant(0)
 DECLARE i = i2 WITH noconstant(0)
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=89
   AND cv.display_key="CCOW"
  DETAIL
   contributor_sys_code = cv.code_value
  WITH nocounter
 ;end select
 CALL echo(build("Found Contributor System Code value: ",contributor_sys_code))
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=317
   AND cv.cdf_meaning="IDINT"
  DETAIL
   alias_field_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM esi_alias_trans eat
  PLAN (eat
   WHERE eat.contributor_system_cd=contributor_sys_code
    AND eat.esi_alias_field_cd=alias_field_cd
    AND eat.alias_entity_name="PERSON")
  DETAIL
   count = (count+ 1)
   IF (count > size(ccow_info->qual,5))
    stat = alterlist(ccow_info->qual,(count+ 9))
   ENDIF
   ccow_info->qual[count].suffix = eat.esi_assign_auth, ccow_info->qual[count].alias_pool_cd = eat
   .alias_pool_cd, ccow_info->qual[count].code_set = 263,
   ccow_info->qual[count].unique_id = eat.esi_assign_auth,
   CALL echo(build("Found CCOW suffix: ",eat.esi_assign_auth)),
   CALL echo(build("With alias_pool_cd: ",eat.alias_pool_cd))
 ;end select
 SET stat = alterlist(ccow_info->qual,count)
 IF (count >= 1)
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
  FOR (i = 1 TO count)
    SET stat = gm_i_dm_info2388_f8("info_number",ccow_info->qual[i].alias_pool_cd,i,0)
    SET stat = gm_i_dm_info2388_vc("info_domain","CCOW",i,0)
    SET stat = gm_i_dm_info2388_vc("info_name",ccow_info->qual[i].unique_id,i,0)
    SET stat = gm_i_dm_info2388_vc("info_char",ccow_info->qual[i].suffix,i,0)
  ENDFOR
  EXECUTE gm_i_dm_info2388  WITH replace(request,gm_i_dm_info2388_req), replace(reply,
   gm_i_dm_info2388_rep)
  FREE RECORD gm_i_dm_info2388_req
  FREE RECORD gm_i_dm_info2388_rep
 ENDIF
END GO
