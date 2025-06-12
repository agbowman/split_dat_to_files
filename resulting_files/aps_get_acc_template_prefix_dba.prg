CREATE PROGRAM aps_get_acc_template_prefix:dba
 RECORD reply(
   1 qual[5]
     2 prefix_id = f8
     2 template_cd = f8
     2 template_disp = c40
     2 default_ind = i2
     2 active_ind = i2
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
 IF ((request->template_prefix_ind="P"))
  SELECT INTO "nl:"
   apatr.prefix_id
   FROM ap_prefix_accn_template_r apatr,
    code_value cv
   PLAN (apatr
    WHERE (request->template_prefix_value=apatr.prefix_id))
    JOIN (cv
    WHERE apatr.template_cd=cv.code_value)
   DETAIL
    cnt = (cnt+ 1)
    IF (mod(cnt,5)=1
     AND cnt != 1)
     stat = alter(reply->qual,(cnt+ 4))
    ENDIF
    reply->qual[cnt].prefix_id = apatr.prefix_id, reply->qual[cnt].template_cd = apatr.template_cd,
    reply->qual[cnt].template_disp = cv.display,
    reply->qual[cnt].active_ind = cv.active_ind, reply->qual[cnt].default_ind = apatr.default_ind,
    reply->qual[cnt].updt_cnt = apatr.updt_cnt
    IF (debug=1)
     CALL echo(build("Prefix_Id :",reply->qual[cnt].prefix_id)),
     CALL echo(build("Template_Cd :",reply->qual[cnt].template_cd)),
     CALL echo(build("Template_Disp :",reply->qual[cnt].template_disp)),
     CALL echo(build("Default_Ind :",reply->qual[cnt].default_ind)),
     CALL echo(build("Updt_Cnt :",reply->qual[cnt].updt_cnt))
    ENDIF
   FOOT REPORT
    stat = alter(reply->qual,cnt)
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   apatr.template_cd
   FROM ap_prefix_accn_template_r apatr
   PLAN (apatr
    WHERE (request->template_prefix_value=apatr.template_cd))
   DETAIL
    cnt = (cnt+ 1)
    IF (mod(cnt,5)=1
     AND cnt != 1)
     stat = alter(reply->qual,(cnt+ 4))
    ENDIF
    reply->qual[cnt].prefix_id = apatr.prefix_id, reply->qual[cnt].template_cd = apatr.template_cd,
    reply->qual[cnt].default_ind = apatr.default_ind,
    reply->qual[cnt].updt_cnt = apatr.updt_cnt
    IF (debug=1)
     CALL echo(build("Prefix_Id :",reply->qual[cnt].prefix_id)),
     CALL echo(build("Template_Cd :",reply->qual[cnt].template_cd)),
     CALL echo(build("Template_Disp :",reply->qual[cnt].template_disp)),
     CALL echo(build("Default_Ind :",reply->qual[cnt].default_ind)),
     CALL echo(build("Updt_Cnt :",reply->qual[cnt].updt_cnt))
    ENDIF
   FOOT REPORT
    stat = alter(reply->qual,cnt)
   WITH nocounter
  ;end select
 ENDIF
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  SET stat = alter(reply->qual,0)
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_sub
END GO
