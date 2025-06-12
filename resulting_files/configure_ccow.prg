CREATE PROGRAM configure_ccow
 PAINT
 CALL video(n)
 IF (validate(ccow_info,1))
  FREE RECORD ccow_info
 ENDIF
 IF (validate(ccow_upd_info,1))
  FREE RECORD ccow_upd_info
 ENDIF
 RECORD ccow_info(
   1 qual[*]
     2 suffix = vc
     2 alias_pool_cd = f8
     2 code_set = i4
     2 display = vc
     2 unique_id = vc
     2 encntr_context = f8
 )
 RECORD ccow_upd_info(
   1 suffix = vc
   1 alias_pool_cd = f8
   1 unique_id = vc
   1 encntr_context = f8
 )
 DECLARE currrow = i2 WITH noconstant(3), private
 DECLARE count = i2 WITH noconstant(0), private
 DECLARE i = i2 WITH noconstant(0), private
 DECLARE ccow_info_line = vc WITH noconstant(fillstring(100," "))
 DECLARE stat = i4 WITH noconstant(0), private
#start_over
 EXECUTE dcp_get_ccow_config
 SET count = size(ccow_info->qual,5)
 CALL clear(1,1)
 CALL box(2,1,23,80)
 CALL text(1,25,"CCOW Configuration Tool")
 SET currrow = 3
 IF (count > 0)
  CALL text(currrow,10,"Currently Configured CCOW aliases")
  SET currrow = (currrow+ 1)
  FOR (i = 1 TO count)
    SET ccow_info_line = build("ID: ",ccow_info->qual[i].unique_id," Suffix: ",ccow_info->qual[i].
     suffix,", Alias Pool: ")
    SET ccow_info_line = build(ccow_info_line,ccow_info->qual[i].display)
    SET ccow_info_line = build(ccow_info_line,",  Encounter Context: ")
    IF ((ccow_info->qual[i].encntr_context=1))
     SET ccow_info_line = build(ccow_info_line,"Y")
    ELSE
     SET ccow_info_line = build(ccow_info_line,"N")
    ENDIF
    CALL text(currrow,5,ccow_info_line)
    SET currrow = (currrow+ 1)
  ENDFOR
  SET currrow = (currrow+ 1)
 ELSE
  CALL text(currrow,10,"There are no currently configured CCOW aliases")
  SET currrow = (currrow+ 2)
 ENDIF
 CALL text(currrow,10,"A) Add New CCOW Alias Pool and Suffix")
 SET currrow = (currrow+ 2)
 IF (count > 0)
  CALL text(currrow,10,"B) Update CCOW Alias Pool for Suffix")
  CALL text((currrow+ 2),10,"C) Delete CCOW Alias Pool and Suffix")
  SET currrow = (currrow+ 4)
 ENDIF
 CALL text(currrow,10,"D) Convert rows from EsiConfigTool")
 CALL text((currrow+ 2),10,"E) Quit")
 CALL text((currrow+ 4),04,"Choice? ")
#accept_choice
 CALL accept((currrow+ 4),28,"A(1);CU")
 SET usr_choice = curaccept
 CASE (usr_choice)
  OF "A":
   GO TO add_row
  OF "B":
   GO TO update_row
  OF "C":
   GO TO delete_row
  OF "D":
   EXECUTE dcp_cnv_ccow_config
   COMMIT
   GO TO start_over
  OF "E":
   GO TO 9999_end
  ELSE
   GO TO start_over
 ENDCASE
#delete_row
 CALL clear(1,1)
 CALL box(2,1,23,80)
 CALL text(1,25,"Delete CCOW Row")
 SET currrow = 6
 CALL text(currrow,10,"Currently Configured CCOW aliases")
 SET currrow = (currrow+ 1)
 FOR (i = 1 TO count)
   SET ccow_info_line = build("ID: ",ccow_info->qual[i].unique_id," Suffix: ",ccow_info->qual[i].
    suffix,", Alias Pool: ")
   SET ccow_info_line = build(ccow_info_line,ccow_info->qual[i].display)
   SET ccow_info_line = build(ccow_info_line,",  Encounter Context: ")
   IF ((ccow_info->qual[i].encntr_context=1))
    SET ccow_info_line = build(ccow_info_line,"Y")
   ELSE
    SET ccow_info_line = build(ccow_info_line,"N")
   ENDIF
   CALL text(currrow,5,ccow_info_line)
   SET currrow = (currrow+ 1)
 ENDFOR
 CALL text((currrow+ 1),04,"Which ID should be deleted? ")
 CALL accept((currrow+ 1),50,"P(15);C")
 SET usr_choice = curaccept
 SET ccow_upd_info->unique_id = curaccept
 EXECUTE gm_dm_info2388_def "D"
 DECLARE gm_d_dm_info2388_vc(icol_name=vc,ival=vc,iqual=i4) = i2
 SUBROUTINE gm_d_dm_info2388_vc(icol_name,ival,iqual)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_d_dm_info2388_req->qual,5) < iqual)
    SET stat = alterlist(gm_d_dm_info2388_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "info_domain":
     SET gm_d_dm_info2388_req->qual[iqual].info_domain = ival
     SET gm_d_dm_info2388_req->info_domainw = 1
    OF "info_name":
     SET gm_d_dm_info2388_req->qual[iqual].info_name = ival
     SET gm_d_dm_info2388_req->info_namew = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SET stat = gm_d_dm_info2388_vc("INFO_DOMAIN","CCOW",1)
 SET stat = gm_d_dm_info2388_vc("INFO_NAME",ccow_upd_info->unique_id,1)
 EXECUTE gm_d_dm_info2388  WITH replace(request,gm_d_dm_info2388_req), replace(reply,
  gm_d_dm_info2388_rep)
 FREE RECORD gm_d_dm_info2388_req
 FREE RECORD gm_d_dm_info2388_rep
 COMMIT
 SET stat = alterlist(ccow_info->qual,0)
 GO TO start_over
#update_row
 CALL clear(1,1)
 CALL box(2,1,23,80)
 CALL text(1,25,"Update the Alias Pool Code for a suffix")
 SET currrow = 6
 CALL text(currrow,10,"Currently Configured CCOW aliases")
 SET currrow = (currrow+ 1)
 FOR (i = 1 TO count)
   SET ccow_info_line = build("ID: ",ccow_info->qual[i].unique_id," Suffix: ",ccow_info->qual[i].
    suffix,", Alias Pool: ")
   SET ccow_info_line = build(ccow_info_line,ccow_info->qual[i].display)
   SET ccow_info_line = build(ccow_info_line,",  Encounter Context: ")
   IF ((ccow_info->qual[i].encntr_context=1))
    SET ccow_info_line = build(ccow_info_line,"Y")
   ELSE
    SET ccow_info_line = build(ccow_info_line,"N")
   ENDIF
   CALL text(currrow,5,ccow_info_line)
   SET currrow = (currrow+ 1)
 ENDFOR
 CALL text((currrow+ 1),04,"Which ID should be updated? ")
 CALL accept((currrow+ 1),50,"P(15);C")
 SET usr_choice = curaccept
 SET ccow_upd_info->unique_id = curaccept
 CALL text((currrow+ 3),04,"Change suffix to what value? ")
 CALL accept((currrow+ 3),50,"P(15);C")
 SET usr_choice = curaccept
 SET ccow_upd_info->suffix = curaccept
 CALL text((currrow+ 5),04,"Change Alias Pool Cd to what value? ")
 CALL accept((currrow+ 5),50,"9(10)")
 SET ccow_upd_info->alias_pool_cd = curaccept
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
 SET stat = gm_u_dm_info2388_vc("INFO_DOMAIN","CCOW",1,0,1)
 SET stat = gm_u_dm_info2388_vc("INFO_NAME",ccow_upd_info->unique_id,1,0,1)
 SET stat = gm_u_dm_info2388_f8("INFO_NUMBER",ccow_upd_info->alias_pool_cd,1,0,0)
 SET stat = gm_u_dm_info2388_vc("INFO_CHAR",ccow_upd_info->suffix,1,0,0)
 EXECUTE gm_u_dm_info2388  WITH replace(request,gm_u_dm_info2388_req), replace(reply,
  gm_u_dm_info2388_rep)
 FREE RECORD gm_u_dm_info2388_req
 FREE RECORD gm_u_dm_info2388_rep
 SET stat = alterlist(ccow_info->qual,0)
 COMMIT
 GO TO start_over
#add_row
 CALL clear(1,1)
 CALL box(2,1,23,80)
 CALL text(1,25,"Add an Alias Pool Code and Suffix")
 SET currrow = 6
 CALL text(currrow,04,"Input unique ID: ")
 CALL accept(currrow,50,"P(15);C")
 SET usr_choice = curaccept
 SET ccow_upd_info->unique_id = curaccept
 CALL text((currrow+ 2),04,"Which suffix should be added? ")
 CALL accept((currrow+ 2),50,"P(15);C")
 SET usr_choice = curaccept
 SET ccow_upd_info->suffix = curaccept
 CALL text((currrow+ 4),04,"What is the alias pool code value? ")
 CALL accept((currrow+ 4),50,"9(10)")
 SET ccow_upd_info->alias_pool_cd = curaccept
 CALL text((currrow+ 6),04,"Is this an encounter context subject? ")
 CALL accept((currrow+ 6),50,"A(1);CU","N"
  WHERE curaccept IN ("Y", "N"))
 IF (curaccept="Y")
  SET ccow_upd_info->encntr_context = 1
 ELSE
  SET ccow_upd_info->encntr_context = 0
 ENDIF
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
 SET stat = gm_i_dm_info2388_f8("info_number",ccow_upd_info->alias_pool_cd,1,0)
 SET stat = gm_i_dm_info2388_vc("info_domain","CCOW",1,0)
 SET stat = gm_i_dm_info2388_vc("info_name",ccow_upd_info->unique_id,1,0)
 SET stat = gm_i_dm_info2388_vc("info_char",ccow_upd_info->suffix,1,0)
 SET stat = gm_i_dm_info2388_f8("info_long_id",ccow_upd_info->encntr_context,1,0)
 EXECUTE gm_i_dm_info2388  WITH replace(request,gm_i_dm_info2388_req), replace(reply,
  gm_i_dm_info2388_rep)
 FREE RECORD gm_i_dm_info2388_req
 FREE RECORD gm_i_dm_info2388_rep
 SET stat = alterlist(ccow_info->qual,0)
 COMMIT
 GO TO start_over
#9999_end
 FREE RECORD ccow_info
 FREE RECORD ccow_upd_info
 COMMIT
 CALL clear(1,1)
END GO
