CREATE PROGRAM dcp_apache_ops_diedinhosp:dba
 RECORD reply(
   1 ops_event = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = vc
       3 operationstatus = c1
       3 targetobjectname = vc
       3 targetobjectvalue = vc
 )
 RECORD patients(
   1 list[*]
     2 person_id = f8
     2 encntr_id = f8
     2 name = vc
     2 loc_cd = f8
     2 loc_name = vc
     2 ra_id = f8
     2 icu_admit_dt_tm = dq8
     2 hosp_disch_dt_tm = dq8
     2 icu_disch_dt_tm = dq8
     2 died_ind = i2
 )
 DECLARE last_date_time_checked = q8
 DECLARE pat_array_size = i4
 DECLARE meaning_code(p1,p1) = f8
 SET deceased_cd = 0.0
 SET expired_cd = 0.0
 SET deceased_cd = meaning_code(19,"DECEASED")
 SET expired_cd = meaning_code(19,"EXPIRED")
 EXECUTE FROM 1000_initialize TO 1099_initialize_exit
 EXECUTE FROM 1500_update_dm_info TO 1599_update_dm_info_exit
 EXECUTE FROM 2000_read TO 2099_read_exit
 CALL echo(build("pat_Array_size=",pat_array_size))
 IF (pat_array_size > 0)
  EXECUTE FROM 3000_update_ra TO 3099_update_ra_exit
 ELSE
  CALL echo("no patients to update")
 ENDIF
 GO TO 9999_exit_program
 SUBROUTINE meaning_code(mc_codeset,mc_meaning)
   SET mc_code = 0.0
   SET mc_text = fillstring(12," ")
   SET mc_text = mc_meaning
   SET mc_stat = uar_get_meaning_by_codeset(mc_codeset,nullterm(mc_text),1,mc_code)
   IF (mc_code > 0.0)
    RETURN(mc_code)
   ELSE
    RETURN(- (1.0))
   ENDIF
 END ;Subroutine
#1000_initialize
 SET failed_ind = "F"
 SET failed_text = fillstring(50," ")
 SET failed_text = "Script Failure"
 SET last_date_time_checked = cnvtdatetime("01-JAN-2000")
 SET found_dm_entry = 0
 SET pat_array_size = 0
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="APACHE"
   AND di.info_name="APACHE DIED IN HOSP LAST CHECKED-VER3"
  DETAIL
   found_dm_entry = 1, last_date_time_checked = di.info_date
  WITH nocounter
 ;end select
 SET ltc = format(last_date_time_checked,"@LONGDATETIME")
 CALL echo(build("last time_checked = ",ltc))
#1099_initialize_exit
#1500_update_dm_info
 IF (found_dm_entry=0)
  CALL echo("in INSERT DM_INFO")
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
  SET gm_i_dm_info2388_req->allow_partial_ind = 0
  SET gm_i_dm_info2388_req->info_domaini = 1
  SET gm_i_dm_info2388_req->info_namei = 1
  SET gm_i_dm_info2388_req->info_datei = 1
  SET gm_i_dm_info2388_req->info_chari = 0
  SET gm_i_dm_info2388_req->info_numberi = 0
  SET gm_i_dm_info2388_req->info_long_idi = 0
  SET gm_i_dm_info2388_req->info_daten = 0
  SET gm_i_dm_info2388_req->info_charn = 0
  SET gm_i_dm_info2388_req->info_numbern = 1
  SET stat = alterlist(gm_i_dm_info2388_req->qual,1)
  SET gm_i_dm_info2388_req->qual[1].info_domain = "APACHE"
  SET gm_i_dm_info2388_req->qual[1].info_name = "APACHE DIED IN HOSP LAST CHECKED-VER3"
  SET gm_i_dm_info2388_req->qual[1].info_date = cnvtdatetime(curdate,curtime3)
  EXECUTE gm_i_dm_info2388  WITH replace(request,gm_i_dm_info2388_req), replace(reply,
   gm_i_dm_info2388_rep)
  CALL echorecord(gm_i_dm_info2388_rep)
  IF ((gm_i_dm_info2388_rep->qual[1].status=1))
   CALL echo("need to commit")
   SET reqinfo->commit_ind = 1
   COMMIT
  ELSE
   SET reqinfo->commit_ind = 0
   CALL echo("no commit needed")
  ENDIF
  CALL echorecord(reply)
  FREE RECORD gm_i_dm_info2388_req
  FREE RECORD gm_i_dm_info2388_rep
 ELSE
  CALL echo("in UPDATE DM_INFO")
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
  SET gm_u_dm_info2388_req->allow_partial_ind = 1
  SET gm_u_dm_info2388_req->force_updt_ind = 1
  SET gm_u_dm_info2388_req->info_domainw = 1
  SET gm_u_dm_info2388_req->info_namew = 1
  SET gm_u_dm_info2388_req->info_datew = 0
  SET gm_u_dm_info2388_req->info_charw = 0
  SET gm_u_dm_info2388_req->info_numberw = 0
  SET gm_u_dm_info2388_req->info_long_idw = 0
  SET gm_u_dm_info2388_req->updt_applctxw = 0
  SET gm_u_dm_info2388_req->updt_dt_tmw = 0
  SET gm_u_dm_info2388_req->updt_cntw = 0
  SET gm_u_dm_info2388_req->updt_idw = 0
  SET gm_u_dm_info2388_req->updt_taskw = 0
  SET gm_u_dm_info2388_req->info_domainf = 0
  SET gm_u_dm_info2388_req->info_namef = 0
  SET gm_u_dm_info2388_req->info_datef = 1
  SET gm_u_dm_info2388_req->info_charf = 0
  SET gm_u_dm_info2388_req->info_numberf = 0
  SET gm_u_dm_info2388_req->info_long_idf = 0
  SET gm_u_dm_info2388_req->updt_cntf = 0
  SET stat = alterlist(gm_u_dm_info2388_req->qual,1)
  SET gm_u_dm_info2388_req->qual[1].info_domain = "APACHE"
  SET gm_u_dm_info2388_req->qual[1].info_name = "APACHE DIED IN HOSP LAST CHECKED-VER3"
  SET gm_u_dm_info2388_req->qual[1].info_date = cnvtdatetime(curdate,curtime3)
  EXECUTE gm_u_dm_info2388  WITH replace(request,gm_u_dm_info2388_req), replace(reply,
   gm_u_dm_info2388_rep)
  CALL echorecord(gm_u_dm_info2388_rep)
  IF ((gm_u_dm_info2388_rep->qual[1].status=1))
   CALL echo("need to commit")
   SET reqinfo->commit_ind = 1
   COMMIT
  ELSE
   SET reqinfo->commit_ind = 0
   CALL echo("no commit needed")
  ENDIF
  FREE RECORD gm_u_dm_info2388_req
  FREE RECORD gm_u_dm_info2388_rep
  CALL echorecord(reply)
 ENDIF
#1599_update_dm_info_exit
#2000_read
 SET pat_array_size = 0
 SET pat_counter = 0
 SELECT INTO "nl:"
  FROM risk_adjustment ra,
   encounter e,
   person p
  PLAN (ra
   WHERE ra.active_ind=1
    AND ra.icu_disch_dt_tm < cnvtdatetime("31-DEC-2100")
    AND ra.diedinicu_ind < 1)
   JOIN (e
   WHERE e.encntr_id=ra.encntr_id
    AND e.active_ind=1
    AND e.person_id=ra.person_id
    AND e.disch_disposition_cd > 0)
   JOIN (p
   WHERE p.person_id=ra.person_id
    AND p.active_ind=1)
  HEAD REPORT
   pat_counter = 0
  DETAIL
   IF (((e.updt_dt_tm >= cnvtdatetime(last_date_time_checked)) OR (ra.updt_dt_tm >= cnvtdatetime(
    last_date_time_checked))) )
    pat_counter = (pat_counter+ 1), stat = alterlist(patients->list,pat_counter), patients->list[
    pat_counter].name = p.name_full_formatted,
    patients->list[pat_counter].person_id = ra.person_id, patients->list[pat_counter].encntr_id = ra
    .encntr_id, patients->list[pat_counter].ra_id = ra.risk_adjustment_id,
    patients->list[pat_counter].hosp_disch_dt_tm = e.disch_dt_tm, patients->list[pat_counter].
    icu_admit_dt_tm = ra.icu_admit_dt_tm, patients->list[pat_counter].icu_disch_dt_tm = ra
    .icu_disch_dt_tm
    IF (e.disch_disposition_cd IN (deceased_cd, expired_cd))
     patients->list[pat_counter].died_ind = 1
    ELSE
     patients->list[pat_counter].died_ind = 0
    ENDIF
    IF (p.deceased_dt_tm > e.reg_dt_tm
     AND p.deceased_dt_tm <= e.disch_dt_tm)
     patients->list[pat_counter].died_ind = 1
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (pat_counter > 0)
  SET failed_ind = "S"
  SET failed_text = "Found Hospital Deaths to Update in Risk_Adjustment"
 ELSE
  SET failed_ind = "S"
  SET failed_text = "No Hospital Deaths to Update in Risk_Adjustment"
 ENDIF
 SET pat_array_size = size(patients->list,5)
 CALL echo(build("pat_Array_size=",pat_array_size))
#2099_read_exit
#3000_update_ra
 CALL echo("top of 3000")
 FOR (x = 1 TO pat_array_size)
   SET ra_id = patients->list[x].ra_id
   UPDATE  FROM risk_adjustment ra
    SET ra.diedinhospital_ind = - (1), ra.updt_dt_tm = datetimeadd(cnvtdatetime(curdate,curtime3),- (
      0.000694)), ra.updt_task = reqinfo->updt_task,
     ra.updt_applctx = reqinfo->updt_applctx, ra.updt_id = reqinfo->updt_id, ra.updt_cnt = (ra
     .updt_cnt+ 1)
    WHERE ra.risk_adjustment_id=ra_id
    WITH nocounter
   ;end update
   IF (curqual=0)
    CALL echo("error updating a record")
    SET failed_ind = "F"
    SET failed_text = "Error updating risk_adjustment row with Died Indicator."
    SET reqinfo->commit_ind = 0
   ELSE
    CALL echo("updated a record - should be intact")
    SET reqinfo->commit_ind = 1
    COMMIT
   ENDIF
 ENDFOR
#3099_update_ra_exit
#9999_exit_program
 CALL echo(build("commit_ind=",reqinfo->commit_ind))
 SET stat = alterlist(patients->list,0)
 SET reply->status_data.status = failed_ind
 SET reply->status_data.subeventstatus[1].targetobjectvalue = failed_text
 CALL echorecord(reply)
END GO
