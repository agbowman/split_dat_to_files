CREATE PROGRAM afc_upt_bim_end_dttm:dba
 PAINT
 SET width = 132
 SET modify = system
 SET endeffectivedatetime = fillstring(20," ")
#accept_dates
 CALL clear(1,1)
 CALL video(n)
 CALL video(n)
 CALL text(10,1,"Enter end_effective_dt_tm: ")
 CALL accept(10,30,"nndpppdnnnn;cs",format(curdate,"dd-mmm-yyyy;;d")
  WHERE format(cnvtdatetime(curaccept),"dd-mmm-yyyy;;d")=curaccept)
 SET enddate = concat(curaccept," 23:59:59.99")
 CALL text(12,1,concat("The date you entered is: ",enddate))
 CALL text(13,1,"Is this correct? (Y/N/Q): ")
 CALL accept(13,26,"X;C","Y"
  WHERE curaccept IN ("Y", "N", "Q", "y", "n",
  "q"))
 IF (cnvtupper(curaccept)="Y")
  CALL clear(1,1)
  CALL text(1,1,concat("Updating end_effective_dt_tm to ",enddate," ..."))
  GO TO update_bim
 ELSEIF (cnvtupper(curaccept)="N")
  GO TO accept_dates
 ELSEIF (cnvtupper(curaccept)="Q")
  GO TO exit_update
 ENDIF
#update_bim
 UPDATE  FROM bill_item_modifier bim
  SET bim.end_effective_dt_tm = cnvtdatetime(enddate)
  WHERE bim.bill_item_type_cd IN (
  (SELECT
   cv.code_value
   FROM code_value cv
   WHERE cv.code_set=13019
    AND cv.cdf_meaning="BILL CODE"
    AND cv.active_ind=1))
   AND bim.active_ind=1
   AND bim.end_effective_dt_tm >= cnvtdatetime(curdate,curtime)
  WITH nocounter
 ;end update
 GO TO commit_job
#commit_job
 CALL text(14,1,"Commit? (Y/N): ")
 CALL accept(14,16,"X;C","N"
  WHERE curaccept IN ("Y", "N", "y", "n"))
 IF (cnvtupper(curaccept)="Y")
  CALL text(15,1,"Commiting...")
  COMMIT
 ELSEIF (cnvtupper(curaccept)="N")
  CALL text(15,1,"Rollback...")
  ROLLBACK
 ENDIF
#exit_update
END GO
