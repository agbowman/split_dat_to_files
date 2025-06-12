CREATE PROGRAM aps_get_acc_template_by_id:dba
 RECORD reply(
   1 active_ind = i2
   1 name = c40
   1 template_cd = f8
   1 updt_cnt = i4
   1 acc_template_qual[*]
     2 template_detail_id = f8
     2 detail_name = c16
     2 detail_flag = i2
     2 detail_id = f8
     2 detail_disp = c40
     2 carry_forward_ind = i2
     2 carry_forward_spec_ind = i2
     2 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET debug = 0
 SELECT INTO "nl:"
  cv.active_ind, cv.code_value, cv.display
  FROM code_value cv
  PLAN (cv
   WHERE (request->template_cd=cv.code_value))
  DETAIL
   reply->active_ind = cv.active_ind, reply->name = cv.display, reply->template_cd = cv.code_value,
   reply->updt_cnt = cv.updt_cnt
   IF (debug=1)
    CALL echo(build("Active_Ind :",reply->active_ind)),
    CALL echo(build("Name :",reply->name)),
    CALL echo(build("Template_Cd :",reply->template_cd))
   ENDIF
   stat = alterlist(reply->acc_template_qual,12)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  SET stat = alterlist(reply->acc_template_qual,0)
  GO TO exit_sub
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SELECT INTO "nl:"
  attd.template_cd
  FROM ap_accn_template_detail aatd
  PLAN (aatd
   WHERE (request->template_cd=aatd.template_cd))
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,12)=1
    AND cnt != 1)
    stat = alterlist(reply->acc_template_qual,(cnt+ 11))
   ENDIF
   reply->acc_template_qual[cnt].template_detail_id = aatd.template_detail_id, reply->
   acc_template_qual[cnt].detail_name = aatd.detail_name, reply->acc_template_qual[cnt].detail_flag
    = aatd.detail_flag,
   reply->acc_template_qual[cnt].detail_id = aatd.detail_id, reply->acc_template_qual[cnt].
   carry_forward_ind = aatd.carry_forward_ind, reply->acc_template_qual[cnt].carry_forward_spec_ind
    = aatd.carry_forward_spec_ind,
   reply->acc_template_qual[cnt].updt_cnt = aatd.updt_cnt
   IF (debug=1)
    CALL echo(build("Template_Detail_Id :",reply->acc_template_qual[cnt].template_detail_id)),
    CALL echo(build("Detail_Name :",reply->acc_template_qual[cnt].detail_name)),
    CALL echo(build("Detail_Flag :",reply->acc_template_qual[cnt].detail_flag)),
    CALL echo(build("Detail_ID :",reply->acc_template_qual[cnt].detail_id)),
    CALL echo(build("Carry_Forward :",reply->acc_template_qual[cnt].carry_forward_ind)),
    CALL echo(build("Carry_Forward_Spec :",reply->acc_template_qual[cnt].carry_forward_spec_ind)),
    CALL echo(build("Updt_Cnt :",reply->acc_template_qual[cnt].updt_cnt))
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->acc_template_qual,cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "S"
  SET stat = alterlist(reply->acc_template_qual,0)
  GO TO exit_sub
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 FOR (x = 1 TO size(reply->acc_template_qual,5))
  IF ((((reply->acc_template_qual[x].detail_name="REQ_PHYSICIAN")) OR ((reply->acc_template_qual[x].
  detail_name="COPYTO_PHYSICIAN"))) )
   SELECT INTO "nl:"
    prsnl.person_id
    FROM prsnl p
    PLAN (p
     WHERE (reply->acc_template_qual[x].detail_id=p.person_id))
    DETAIL
     reply->acc_template_qual[x].detail_disp = p.name_full_formatted
     IF (debug=1)
      CALL echo(build("Detail_Name :",reply->acc_template_qual[x].detail_name)),
      CALL echo(build("Detail_Disp :",reply->acc_template_qual[x].detail_disp)),
      CALL echo(build("Detail_Id :",reply->acc_template_qual[x].detail_id))
     ENDIF
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET reply->status_data.status = "P"
    SET stat = alterlist(reply->acc_template_qual,0)
    GO TO exit_sub
   ELSE
    SET reply->status_data.status = "S"
   ENDIF
  ENDIF
  IF ((((reply->acc_template_qual[x].detail_name="SPECIMEN_CODE")) OR ((reply->acc_template_qual[x].
  detail_name="ORDER_LOCATION"))) )
   SELECT INTO "nl:"
    code_value.code_value
    FROM code_value cv
    PLAN (cv
     WHERE (reply->acc_template_qual[x].detail_id=cv.code_value))
    DETAIL
     reply->acc_template_qual[x].detail_disp = cv.display
     IF (debug=1)
      CALL echo(build("Detail_Name :",reply->acc_template_qual[x].detail_name)),
      CALL echo(build("Detail_Disp :",reply->acc_template_qual[x].detail_disp)),
      CALL echo(build("Detail_Id :",reply->acc_template_qual[x].detail_id))
     ENDIF
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET reply->status_data.status = "P"
    SET stat = alterlist(reply->acc_template_qual,0)
    GO TO exit_sub
   ELSE
    SET reply->status_data.status = "S"
   ENDIF
  ENDIF
 ENDFOR
#exit_sub
END GO
