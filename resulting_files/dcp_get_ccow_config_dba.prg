CREATE PROGRAM dcp_get_ccow_config:dba
 DECLARE stat = i4 WITH noconstant(0)
 DECLARE count = i4 WITH noconstant(0)
 DECLARE i = i4 WITH noconstant(0)
 DECLARE found = i2 WITH noconstant(0)
 SET stat = alterlist(ccow_info->qual,0)
 SELECT INTO "nl:"
  FROM dm_info di,
   code_value cv
  PLAN (di
   WHERE di.info_domain="CCOW")
   JOIN (cv
   WHERE outerjoin(di.info_number)=cv.code_value)
  DETAIL
   count = (count+ 1)
   IF (count > size(ccow_info->qual,5))
    stat = alterlist(ccow_info->qual,(count+ 9))
   ENDIF
   ccow_info->qual[count].suffix = trim(di.info_char), ccow_info->qual[count].alias_pool_cd = di
   .info_number, ccow_info->qual[count].code_set = cv.code_set,
   ccow_info->qual[count].display = cv.display, ccow_info->qual[count].unique_id = trim(di.info_name),
   ccow_info->qual[count].encntr_context = di.info_long_id
  WITH nocounter
 ;end select
 SET stat = alterlist(ccow_info->qual,count)
 IF (trim(ccow_info->qual[1].suffix)="")
  EXECUTE gm_dm_info2388_def "U"
  DECLARE gm_u_dm_info2388_vc(icol_name=vc,ival=vc,iqual=i4,null_ind=i2,wq_ind=i2) = i2
  DECLARE gm_u_dm_info2388_dq8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2,wq_ind=i2) = i2
  DECLARE gm_u_dm_info2388_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2,wq_ind=i2) = i2
  DECLARE gm_u_dm_info2388_i4(icol_name=vc,ival=i4,iqual=i4,null_ind=i2,wq_ind=i2) = i2
  SUBROUTINE gm_u_dm_info2388_f8(icol_name,ival,iqual,null_ind,wq_ind)
    DECLARE stat = i2 WITH protect, noconstant(0)
    IF (size(gm_u_dm_info2388_req->qual,5) < iqual)
     SET stat = alterlist(gm_u_dm_info2388_req->qual,iqual)
     IF (stat=0)
      CALL echo("can not expand request structure")
      RETURN(0)
     ENDIF
    ENDIF
    CASE (cnvtlower(icol_name))
     OF "info_number":
      IF (null_ind=1)
       SET gm_u_dm_info2388_req->info_numberf = 2
      ELSE
       SET gm_u_dm_info2388_req->info_numberf = 1
      ENDIF
      SET gm_u_dm_info2388_req->qual[iqual].info_number = ival
      IF (wq_ind=1)
       SET gm_u_dm_info2388_req->info_numberw = 1
      ENDIF
     OF "info_long_id":
      IF (null_ind=1)
       CALL echo("error can not set this column to null")
       RETURN(0)
      ENDIF
      SET gm_u_dm_info2388_req->info_long_idf = 1
      SET gm_u_dm_info2388_req->qual[iqual].info_long_id = ival
      IF (wq_ind=1)
       SET gm_u_dm_info2388_req->info_long_idw = 1
      ENDIF
     ELSE
      CALL echo("invalid column name passed")
      RETURN(0)
    ENDCASE
    RETURN(1)
  END ;Subroutine
  SUBROUTINE gm_u_dm_info2388_i4(icol_name,ival,iqual,null_ind,wq_ind)
    DECLARE stat = i2 WITH protect, noconstant(0)
    IF (size(gm_u_dm_info2388_req->qual,5) < iqual)
     SET stat = alterlist(gm_u_dm_info2388_req->qual,iqual)
     IF (stat=0)
      CALL echo("can not expand request structure")
      RETURN(0)
     ENDIF
    ENDIF
    CASE (cnvtlower(icol_name))
     OF "updt_cnt":
      IF (null_ind=1)
       CALL echo("error can not set this column to null")
       RETURN(0)
      ENDIF
      SET gm_u_dm_info2388_req->updt_cntf = 1
      SET gm_u_dm_info2388_req->qual[iqual].updt_cnt = ival
      IF (wq_ind=1)
       SET gm_u_dm_info2388_req->updt_cntw = 1
      ENDIF
     ELSE
      CALL echo("invalid column name passed")
      RETURN(0)
    ENDCASE
    RETURN(1)
  END ;Subroutine
  SUBROUTINE gm_u_dm_info2388_dq8(icol_name,ival,iqual,null_ind,wq_ind)
    DECLARE stat = i2 WITH protect, noconstant(0)
    IF (size(gm_u_dm_info2388_req->qual,5) < iqual)
     SET stat = alterlist(gm_u_dm_info2388_req->qual,iqual)
     IF (stat=0)
      CALL echo("can not expand request structure")
      RETURN(0)
     ENDIF
    ENDIF
    CASE (cnvtlower(icol_name))
     OF "info_date":
      IF (null_ind=1)
       SET gm_u_dm_info2388_req->info_datef = 2
      ELSE
       SET gm_u_dm_info2388_req->info_datef = 1
      ENDIF
      SET gm_u_dm_info2388_req->qual[iqual].info_date = cnvtdatetime(ival)
      IF (wq_ind=1)
       SET gm_u_dm_info2388_req->info_datew = 1
      ENDIF
     OF "updt_dt_tm":
      IF (null_ind=1)
       CALL echo("error can not set this column to null")
       RETURN(0)
      ENDIF
      SET gm_u_dm_info2388_req->updt_dt_tmf = 1
      SET gm_u_dm_info2388_req->qual[iqual].updt_dt_tm = cnvtdatetime(ival)
      IF (wq_ind=1)
       SET gm_u_dm_info2388_req->updt_dt_tmw = 1
      ENDIF
     ELSE
      CALL echo("invalid column name passed")
      RETURN(0)
    ENDCASE
    RETURN(1)
  END ;Subroutine
  SUBROUTINE gm_u_dm_info2388_vc(icol_name,ival,iqual,null_ind,wq_ind)
    DECLARE stat = i2 WITH protect, noconstant(0)
    IF (size(gm_u_dm_info2388_req->qual,5) < iqual)
     SET stat = alterlist(gm_u_dm_info2388_req->qual,iqual)
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
      SET gm_u_dm_info2388_req->info_domainf = 1
      SET gm_u_dm_info2388_req->qual[iqual].info_domain = ival
      IF (wq_ind=1)
       SET gm_u_dm_info2388_req->info_domainw = 1
      ENDIF
     OF "info_name":
      IF (null_ind=1)
       CALL echo("error can not set this column to null")
       RETURN(0)
      ENDIF
      SET gm_u_dm_info2388_req->info_namef = 1
      SET gm_u_dm_info2388_req->qual[iqual].info_name = ival
      IF (wq_ind=1)
       SET gm_u_dm_info2388_req->info_namew = 1
      ENDIF
     OF "info_char":
      IF (null_ind=1)
       SET gm_u_dm_info2388_req->info_charf = 2
      ELSE
       SET gm_u_dm_info2388_req->info_charf = 1
      ENDIF
      SET gm_u_dm_info2388_req->qual[iqual].info_char = ival
      IF (wq_ind=1)
       SET gm_u_dm_info2388_req->info_charw = 1
      ENDIF
     ELSE
      CALL echo("invalid column name passed")
      RETURN(0)
    ENDCASE
    RETURN(1)
  END ;Subroutine
  FOR (i = 1 TO count)
    SET stat = gm_u_dm_info2388_vc("INFO_DOMAIN","CCOW",i,0,1)
    SET stat = gm_u_dm_info2388_vc("INFO_NAME",ccow_info->qual[i].unique_id,i,0,1)
    SET stat = gm_u_dm_info2388_f8("INFO_NUMBER",ccow_info->qual[i].alias_pool_cd,i,0,0)
    SET stat = gm_u_dm_info2388_vc("INFO_CHAR",ccow_info->qual[i].unique_id,i,0,0)
    SET stat = gm_u_dm_info2388_f8("INFO_LONG_ID",ccow_info->qual[i].encntr_context,i,0,0)
    SET ccow_info->qual[i].suffix = ccow_info->qual[i].unique_id
  ENDFOR
  EXECUTE gm_u_dm_info2388  WITH replace(request,gm_u_dm_info2388_req), replace(reply,
   gm_u_dm_info2388_rep)
  FREE RECORD gm_u_dm_info2388_req
  FREE RECORD gm_u_dm_info2388_rep
 ENDIF
 IF (count > 0)
  FOR (i = 1 TO count)
    CALL echo(build("Unique Id: ",ccow_info->qual[i].unique_id))
    CALL echo(build("Suffix: ",ccow_info->qual[i].suffix))
    CALL echo(build("Alias_pool_cd: ",ccow_info->qual[i].alias_pool_cd))
  ENDFOR
 ELSE
  CALL echo("No system configuration rows defined for CCOW")
 ENDIF
END GO
