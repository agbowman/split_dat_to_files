CREATE PROGRAM afc_rdm_upt_tier_matrix_dates:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 SET readme_data->status = "F"
 SET readme_data->message = "ReadMe Failed"
 FREE RECORD matrixdetails
 RECORD matrixdetails(
   1 tier_matrix[*]
     2 tier_group_cd = f8
     2 tier_group[*]
       3 tier_cell_id = f8
       3 tier_group_cd = f8
       3 tier_col_num = i4
       3 tier_row_num = i4
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
       3 ismatrixstartsandendssameday = i2
 ) WITH protect
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE batchcount = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH public, noconstant(0)
 DECLARE idx1 = i4 WITH public, noconstant(0)
 DECLARE idx2 = i4 WITH public, noconstant(0)
 DECLARE matrixcnt = i4 WITH public, noconstant(0)
 IF ( NOT (gettiermatrixdetails(0)))
  SET readme_data->message = concat("Failed to fetch the tier matrix rows which needs to be updated ",
   errmsg)
  GO TO exit_script
 ENDIF
 IF ( NOT (updatedateforoverlappingtiermatrix(0)))
  SET readme_data->message = concat("Failed to update the overlapping dates.",errmsg)
  GO TO exit_script
 ENDIF
 IF ( NOT (updatedatesforalltiermatrix(0)))
  SET readme_data->message = concat("Failed to update the e dates.",errmsg)
  GO TO exit_script
 ENDIF
 SUBROUTINE (gettiermatrixdetails(dummyvar=i2) =i2)
   SET batchcount = 0
   SET matrixcnt = 0
   SELECT INTO "nl:"
    FROM tier_matrix tm
    PLAN (tm
     WHERE tm.active_ind=true)
    ORDER BY tm.tier_group_cd, tm.beg_effective_dt_tm
    HEAD tm.tier_group_cd
     matrixcnt += 1
     IF (mod(matrixcnt,10)=1)
      stat = alterlist(matrixdetails->tier_matrix,(matrixcnt+ 9))
     ENDIF
     matrixdetails->tier_matrix[matrixcnt].tier_group_cd = tm.tier_group_cd, batchcount = 0
    DETAIL
     batchcount += 1
     IF (mod(batchcount,100)=1)
      stat = alterlist(matrixdetails->tier_matrix[matrixcnt].tier_group,(batchcount+ 99))
     ENDIF
     matrixdetails->tier_matrix[matrixcnt].tier_group[batchcount].tier_cell_id = tm.tier_cell_id,
     matrixdetails->tier_matrix[matrixcnt].tier_group[batchcount].tier_group_cd = tm.tier_group_cd,
     matrixdetails->tier_matrix[matrixcnt].tier_group[batchcount].tier_col_num = tm.tier_col_num,
     matrixdetails->tier_matrix[matrixcnt].tier_group[batchcount].tier_row_num = tm.tier_row_num
     IF (format(cnvtdatetimeutc(tm.beg_effective_dt_tm,1),"HH:MM:SS;;D") != "00:00:00")
      matrixdetails->tier_matrix[matrixcnt].tier_group[batchcount].beg_effective_dt_tm =
      cnvtdatetimeutc(cnvtdatetime(cnvtdate(cnvtint(build2(format(month(tm.beg_effective_dt_tm),
            "##;P0"),format(day(tm.beg_effective_dt_tm),"##;P0"),year(tm.beg_effective_dt_tm)))),0),2
       )
     ELSE
      matrixdetails->tier_matrix[matrixcnt].tier_group[batchcount].beg_effective_dt_tm = tm
      .beg_effective_dt_tm
     ENDIF
     IF (format(cnvtdatetimeutc(tm.end_effective_dt_tm,1),"HH:MM:SS;;D") != "00:00:00")
      matrixdetails->tier_matrix[matrixcnt].tier_group[batchcount].end_effective_dt_tm =
      cnvtdatetimeutc(cnvtdatetime(cnvtdate(cnvtint(build2(format(month(tm.end_effective_dt_tm),
            "##;P0"),format(day(tm.end_effective_dt_tm),"##;P0"),year(tm.end_effective_dt_tm)))),0),2
       )
     ELSE
      matrixdetails->tier_matrix[matrixcnt].tier_group[batchcount].end_effective_dt_tm = tm
      .end_effective_dt_tm
     ENDIF
     IF ((matrixdetails->tier_matrix[matrixcnt].tier_group[batchcount].beg_effective_dt_tm=
     matrixdetails->tier_matrix[matrixcnt].tier_group[batchcount].end_effective_dt_tm))
      matrixdetails->tier_matrix[matrixcnt].tier_group[batchcount].ismatrixstartsandendssameday =
      true
     ENDIF
    FOOT  tm.tier_group_cd
     stat = alterlist(matrixdetails->tier_matrix[matrixcnt].tier_group,batchcount)
    FOOT REPORT
     stat = alterlist(matrixdetails->tier_matrix,matrixcnt)
    WITH nocounter
   ;end select
   IF (error(errmsg,0) > 0)
    SET readme_data->message = concat("Failed to get the tier_matrix details",errmsg)
    GO TO exit_script
   ENDIF
   IF (batchcount > 0)
    RETURN(true)
   ELSE
    SET readme_data->status = "S"
    SET readme_data->message = "No tier matrix rows found whcih needs update"
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE (updatedatesforalltiermatrix(dummyvar=i2) =i2)
   SET idx = 0
   FOR (idx = 1 TO size(matrixdetails->tier_matrix,5))
     UPDATE  FROM tier_matrix tm,
       (dummyt d  WITH seq = size(matrixdetails->tier_matrix[idx].tier_group,5))
      SET tm.beg_effective_dt_tm = cnvtdatetimeutc(matrixdetails->tier_matrix[idx].tier_group[d.seq].
        beg_effective_dt_tm,0), tm.end_effective_dt_tm = cnvtdatetimeutc(matrixdetails->tier_matrix[
        idx].tier_group[d.seq].end_effective_dt_tm,0), tm.updt_cnt = (tm.updt_cnt+ 1),
       tm.updt_dt_tm = cnvtdatetime(sysdate), tm.updt_id = reqinfo->updt_id, tm.updt_task = reqinfo->
       updt_task
      PLAN (d)
       JOIN (tm
       WHERE (tm.tier_cell_id=matrixdetails->tier_matrix[idx].tier_group[d.seq].tier_cell_id))
      WITH nocounter
     ;end update
     IF (error(errmsg,0) > 0)
      SET readme_data->status = "F"
      SET readme_data->message = concat("Failed to update tier_matrix dates",errmsg)
      GO TO exit_script
     ENDIF
     COMMIT
   ENDFOR
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (updatedateforoverlappingtiermatrix(dummyvar=i2) =i2)
   SET idx = 0
   SET idx1 = 0
   SET idx2 = 0
   FOR (idx = 1 TO size(matrixdetails->tier_matrix,5))
     FOR (idx1 = 1 TO size(matrixdetails->tier_matrix[idx].tier_group,5))
       FOR (idx2 = 1 TO size(matrixdetails->tier_matrix[idx].tier_group,5))
         IF ((matrixdetails->tier_matrix[idx].tier_group[idx1].tier_group_cd=matrixdetails->
         tier_matrix[idx].tier_group[idx2].tier_group_cd))
          IF ((matrixdetails->tier_matrix[idx].tier_group[idx1].end_effective_dt_tm=matrixdetails->
          tier_matrix[idx].tier_group[idx2].beg_effective_dt_tm)
           AND (matrixdetails->tier_matrix[idx].tier_group[idx1].ismatrixstartsandendssameday != true
          ))
           SET matrixdetails->tier_matrix[idx].tier_group[idx1].end_effective_dt_tm = cnvtlookbehind(
            "1,D",matrixdetails->tier_matrix[idx].tier_group[idx1].end_effective_dt_tm)
          ENDIF
         ENDIF
       ENDFOR
     ENDFOR
   ENDFOR
 END ;Subroutine
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Readme performed all required tasks"
#exit_script
 IF ((readme_data->status != "S"))
  CALL echo("afc_rdm_upt_tier_matrix_dates Unsuccessful.")
  ROLLBACK
 ELSE
  CALL echo("readme_data->message Successful.")
  COMMIT
 ENDIF
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
