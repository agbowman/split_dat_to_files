CREATE PROGRAM dd_upd_label_type_codes_readme:dba
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
 DECLARE err_code = f8 WITH protect, noconstant(0.0)
 DECLARE error_msg = vc WITH protect, noconstant("")
 DECLARE getcodevalue(cdfmean=vc) = f8
 DECLARE updatelabeltypecode(displaytext=vc,labelid=f8) = null
 DECLARE updatetemplatetolabelrel(labelidwithtypecd=f8,labelidwithouttypecd=f8) = null
 DECLARE deleteobsoletelabel(labelid=f8) = null
 DECLARE wkfcdfmean = vc WITH protect
 DECLARE clipboardcdfmean = vc WITH protect
 DECLARE favcdfmean = vc WITH protect
 DECLARE clipboarddisplaytext = vc WITH protect
 DECLARE favoritedisplaytext = vc WITH protect
 DECLARE clipboardcode = f8
 DECLARE wkftypecode = f8
 DECLARE favcode = f8
 DECLARE ndx = i4 WITH noconstant(0), public
 SET wkfcdfmean = "WKF_COMP"
 SET clipboardcdfmean = "CLIPBOARD"
 SET favcdfmean = "FAVORITE"
 SET clipboarddisplaytext = "clipboard"
 SET favoritedisplaytext = "favorite"
 SET clipboardcode = getcodevalue(clipboardcdfmean)
 SET wkftypecode = getcodevalue(wkfcdfmean)
 SET favcode = getcodevalue(favcdfmean)
 SET readme_data->status = "F"
 SET readme_data->message = concat("Error - Failed to update reference labels:",error_msg)
 FREE RECORD label
 RECORD label(
   1 qual[*]
     2 id = f8
     2 displaytext = vc
     2 labeltypecode = f8
     2 userid = f8
 )
 SELECT INTO "nl:"
  FROM dd_ref_label drl
  WHERE drl.dd_ref_label_id != 0.0
  HEAD REPORT
   count = 0
  DETAIL
   count = (count+ 1)
   IF (mod(count,50)=1)
    stat = alterlist(label->qual,(count+ 49))
   ENDIF
   label->qual[count].id = drl.dd_ref_label_id, label->qual[count].displaytext = drl.display_txt,
   label->qual[count].labeltypecode = drl.label_type_cd,
   label->qual[count].userid = drl.user_id
  FOOT REPORT
   stat = alterlist(label->qual,count)
  WITH nocounter
 ;end select
 SET err_code = error(error_msg,1)
 IF (err_code > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Error - Failed to read reference labels:",error_msg)
  GO TO exit_script
 ENDIF
 FOR (outerindex = 1 TO size(label->qual,5))
   SET dsptxt = label->qual[outerindex].displaytext
   SET userid = label->qual[outerindex].userid
   SET pos = locateval(ndx,(outerindex+ 1),size(label->qual,5),dsptxt,label->qual[ndx].displaytext,
    userid,label->qual[ndx].userid)
   IF (pos > 0)
    IF ((label->qual[outerindex].labeltypecode > label->qual[pos].labeltypecode))
     CALL updatetemplatetolabelrel(label->qual[outerindex].id,label->qual[pos].id)
     CALL deleteobsoletelabel(label->qual[pos].id)
    ELSE
     CALL updatetemplatetolabelrel(label->qual[pos].id,label->qual[outerindex].id)
     CALL deleteobsoletelabel(label->qual[outerindex].id)
    ENDIF
   ENDIF
   IF ((label->qual[outerindex].displaytext=clipboarddisplaytext))
    CALL updatelabeltypecode(clipboardcode,label->qual[outerindex].id)
   ELSEIF ((label->qual[outerindex].displaytext=favoritedisplaytext))
    CALL updatelabeltypecode(favcode,label->qual[outerindex].id)
   ELSE
    CALL updatelabeltypecode(wkftypecode,label->qual[outerindex].id)
   ENDIF
 ENDFOR
 SUBROUTINE updatelabeltypecode(labeltypecode,labelid)
   UPDATE  FROM dd_ref_label drl
    SET drl.label_type_cd = labeltypecode
    WHERE drl.dd_ref_label_id=labelid
    WITH nocounter
   ;end update
   SET err_code = error(error_msg,1)
   IF (err_code > 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("Error - failed to update labels:",error_msg)
    ROLLBACK
    GO TO exit_script
   ELSE
    COMMIT
   ENDIF
 END ;Subroutine
 SUBROUTINE getcodevalue(cdfmean)
   DECLARE codeval = f8
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_value > 0
     AND cv.cdf_meaning=cdfmean
     AND cv.active_ind=1
     AND cv.code_set=32003
    FOOT REPORT
     codeval = cv.code_value
    WITH nocounter
   ;end select
   SET err_code = error(error_msg,1)
   IF (err_code > 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("Error - failed to get code values:",error_msg)
    GO TO exit_script
   ENDIF
   RETURN(codeval)
 END ;Subroutine
 SUBROUTINE updatetemplatetolabelrel(labelidwithtypecd,labelidwithouttypecd)
   UPDATE  FROM dd_ref_tmplt_lbl_r drl
    SET drl.dd_ref_label_id = labelidwithtypecd
    WHERE drl.dd_ref_label_id=labelidwithouttypecd
    WITH nocounter
   ;end update
   SET err_code = error(error_msg,1)
   IF (err_code > 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("Error - failed to update labels:",error_msg)
    ROLLBACK
    GO TO exit_script
   ELSE
    COMMIT
   ENDIF
 END ;Subroutine
 SUBROUTINE deleteobsoletelabel(labelid)
   DELETE  FROM dd_ref_label
    WHERE dd_ref_label_id=labelid
    WITH nocounter
   ;end delete
   SET err_code = error(error_msg,1)
   IF (err_code > 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("Error - failed to update labels:",error_msg)
    ROLLBACK
    GO TO exit_script
   ELSE
    COMMIT
   ENDIF
 END ;Subroutine
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Reference labels were updated."
#exit_script
 FREE RECORD label
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
