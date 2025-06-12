CREATE PROGRAM afc_get_prsnl_id:dba
 FREE RECORD sac_def_pos_req
 RECORD sac_def_pos_req(
   1 personnel_id = f8
 )
 FREE RECORD sac_def_pos_list_req
 RECORD sac_def_pos_list_req(
   1 personnels[*]
     2 personnel_id = f8
 )
 FREE RECORD sac_def_pos_rep
 RECORD sac_def_pos_rep(
   1 position_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD sac_def_pos_list_rep
 RECORD sac_def_pos_list_rep(
   1 personnels[*]
     2 personnel_id = f8
     2 personnel_found = i2
     2 position_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD sac_cur_pos_rep
 RECORD sac_cur_pos_rep(
   1 position_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE getdefaultposition(null) = i2
 DECLARE getmultipledefaultpositions(null) = i2
 DECLARE getcurrentposition(null) = i2
 EXECUTE sacrtl
 SUBROUTINE getdefaultposition(null)
   DECLARE stat = i2 WITH protect
   SET stat = initrec(sac_def_pos_rep)
   SET sac_def_pos_rep->status_data.subeventstatus[1].operationname = "GetDefaultPosition"
   SET sac_def_pos_rep->status_data.subeventstatus[1].targetobjectname = "POSITION_CD"
   SELECT INTO "nl:"
    p.position_cd
    FROM prsnl p
    WHERE (p.person_id=sac_def_pos_req->personnel_id)
    DETAIL
     sac_def_pos_rep->position_cd = p.position_cd
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET sac_def_pos_rep->status_data.status = "Z"
    SET sac_def_pos_rep->status_data.subeventstatus[1].operationstatus = "Z"
    SET sac_def_pos_rep->status_data.subeventstatus[1].targetobjectvalue = build2("Personnel ID of ",
     cnvtstring(sac_def_pos_req->personnel_id,17)," does not exist.")
    RETURN(0)
   ENDIF
   IF ((sac_def_pos_rep->position_cd < 0))
    SET sac_def_pos_rep->status_data.status = "F"
    SET sac_def_pos_rep->status_data.subeventstatus[1].operationstatus = "F"
    SET sac_def_pos_rep->status_data.subeventstatus[1].targetobjectvalue = build2(
     "Invalid POSITION_CD of ",cnvtstring(sac_def_pos_rep->position_cd,17),". Value is less than 0.")
    RETURN(0)
   ENDIF
   SET sac_def_pos_rep->status_data.status = "S"
   SET sac_def_pos_rep->status_data.subeventstatus[1].operationstatus = "S"
   RETURN(1)
 END ;Subroutine
 SUBROUTINE getmultipledefaultpositions(null)
   DECLARE stat = i2 WITH protect
   SET stat = initrec(sac_def_pos_list_rep)
   SET sac_def_pos_list_rep->status_data.subeventstatus[1].operationname =
   "GetMultipleDefaultPositions"
   SET sac_def_pos_list_rep->status_data.subeventstatus[1].targetobjectname = "POSITION_CD"
   DECLARE prsnl_list_size = i4 WITH protect
   SET prsnl_list_size = size(sac_def_pos_list_req->personnels,5)
   IF (prsnl_list_size=0)
    SET sac_def_pos_list_rep->status_data.status = "F"
    SET sac_def_pos_list_rep->status_data.subeventstatus[1].operationstatus = "F"
    SET sac_def_pos_list_rep->status_data.subeventstatus[1].targetobjectvalue = build2(
     "No personnel IDs set in request list of size ",cnvtstring(prsnl_list_size))
    RETURN(0)
   ENDIF
   SET stat = alterlist(sac_def_pos_list_rep->personnels,prsnl_list_size)
   FOR (x = 1 TO prsnl_list_size)
     SET sac_def_pos_list_rep->personnels[x].personnel_id = sac_def_pos_list_req->personnels[x].
     personnel_id
     SET sac_def_pos_list_rep->personnels[x].personnel_found = 0
     SET sac_def_pos_list_rep->personnels[x].position_cd = - (1)
   ENDFOR
   DECLARE prsnl_idx = i4 WITH protect
   DECLARE expand_idx = i4 WITH protect
   DECLARE actual_idx = i4 WITH protect
   SELECT INTO "nl:"
    p.position_cd
    FROM prsnl p
    WHERE expand(prsnl_idx,1,prsnl_list_size,p.person_id,sac_def_pos_list_req->personnels[prsnl_idx].
     personnel_id)
    DETAIL
     actual_idx = locateval(expand_idx,1,prsnl_list_size,p.person_id,sac_def_pos_list_rep->
      personnels[expand_idx].personnel_id), sac_def_pos_list_rep->personnels[actual_idx].
     personnel_found = 1, sac_def_pos_list_rep->personnels[actual_idx].position_cd = p.position_cd
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET sac_def_pos_list_rep->status_data.status = "Z"
    SET sac_def_pos_list_rep->status_data.subeventstatus[1].operationstatus = "Z"
    SET sac_def_pos_list_rep->status_data.subeventstatus[1].targetobjectvalue = build2(
     "No personnels found in request list of size ",cnvtstring(prsnl_list_size))
    RETURN(0)
   ENDIF
   SET sac_def_pos_list_rep->status_data.status = "S"
   SET sac_def_pos_list_rep->status_data.subeventstatus[1].operationstatus = "S"
   RETURN(1)
 END ;Subroutine
 SUBROUTINE getcurrentposition(null)
   DECLARE stat = i2 WITH protect
   SET stat = initrec(sac_cur_pos_rep)
   SET sac_cur_pos_rep->status_data.subeventstatus[1].operationname = "GetCurrentPosition"
   SET sac_cur_pos_rep->status_data.subeventstatus[1].targetobjectname = "POSITION_CD"
   SET sac_cur_pos_rep->status_data.status = "F"
   SET sac_cur_pos_rep->status_data.subeventstatus[1].operationstatus = "F"
   DECLARE hpositionhandle = i4 WITH protect, noconstant(0)
   DECLARE clearhandle = i4 WITH protect, noconstant(0)
   SET hpositionhandle = uar_sacgetcurrentpositions()
   IF (hpositionhandle=0)
    CALL echo("Get Position failed: Unable to get the position handle.")
    SET sac_cur_pos_rep->status_data.subeventstatus[1].targetobjectvalue =
    "Get Current Position Failed: Unable to get the position handle."
    SET clearhandle = uar_sacclosehandle(hpositionhandle)
    RETURN(0)
   ENDIF
   DECLARE positioncnt = i4 WITH protect, noconstant(0)
   SET positioncnt = uar_srvgetitemcount(hpositionhandle,nullterm("Positions"))
   IF (positioncnt != 1)
    CALL echo("Get Position failed: Position count was not exactly 1.")
    SET sac_cur_pos_rep->status_data.subeventstatus[1].targetobjectvalue = build2(
     "Get Current Position Failed: ",cnvtstring(positioncnt,1)," positions returned.")
    SET clearhandle = uar_sacclosehandle(hpositionhandle)
    RETURN(0)
   ENDIF
   DECLARE hpositionlisthandle = i4 WITH protect, noconstant(0)
   SET hpositionlisthandle = uar_srvgetitem(hpositionhandle,nullterm("Positions"),0)
   IF (hpositionlisthandle=0)
    CALL echo("Get Position item failed: Unable to retrieve current position.")
    SET sac_cur_pos_rep->status_data.subeventstatus[1].targetobjectvalue =
    "Get Current Position Failed: Unable to retrieve current position."
    SET clearhandle = uar_sacclosehandle(hpositionlisthandle)
    SET clearhandle = uar_sacclosehandle(hpositionhandle)
    RETURN(0)
   ENDIF
   SET sac_cur_pos_rep->position_cd = uar_srvgetdouble(hpositionlisthandle,nullterm("PositionCode"))
   SET sac_cur_pos_rep->status_data.status = "S"
   SET sac_cur_pos_rep->status_data.subeventstatus[1].operationstatus = "S"
   SET clearhandle = uar_sacclosehandle(hpositionlisthandle)
   SET clearhandle = uar_sacclosehandle(hpositionhandle)
   RETURN(1)
 END ;Subroutine
 RECORD reply(
   1 person_id = f8
   1 username = vc
   1 position_cd = f8
   1 charge_type_cd = f8
   1 credit_type_cd = f8
   1 cea_type_cd = f8
   1 ref_cont_cd = f8
   1 group_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=13028
   AND cv.cdf_meaning="CHARGE NOW"
   AND cv.active_ind=1
  DETAIL
   reply->charge_type_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=13028
   AND cv.cdf_meaning="CREDIT NOW"
   AND cv.active_ind=1
  DETAIL
   reply->credit_type_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=13029
   AND cv.cdf_meaning="COMPLETE"
   AND cv.active_ind=1
  DETAIL
   reply->cea_type_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=13016
   AND cv.cdf_meaning="CHARGE EVENT"
   AND cv.active_ind=1
  DETAIL
   reply->ref_cont_cd = cv.code_value
  WITH nocounter
 ;end select
 IF ((request->prsnl_id=0))
  SELECT INTO "nl:"
   p.person_id
   FROM prsnl p
   WHERE (p.username=request->username)
   DETAIL
    sac_def_pos_req->personnel_id = p.person_id, reply->person_id = p.person_id,
    CALL echo(p.person_id)
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   p.username
   FROM prsnl p
   WHERE (p.person_id=request->prsnl_id)
   DETAIL
    sac_def_pos_req->personnel_id = p.person_id, reply->username = p.username,
    CALL echo(p.username)
   WITH nocounter
  ;end select
 ENDIF
 IF (getdefaultposition(null))
  SET reply->position_cd = sac_def_pos_rep->position_cd
 ELSE
  SET reply->status_data.status = sac_def_pos_rep->status_data.status
  GO TO end_program
 ENDIF
 SELECT INTO "nl:"
  FROM prsnl_group p
  WHERE (p.prsnl_group_type_cd=
  (SELECT
   cv.code_value
   FROM code_value cv
   WHERE cv.code_set=357
    AND cv.cdf_meaning="SERVPROV"))
   AND p.active_ind=1
  DETAIL
   reply->group_id = p.prsnl_group_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "Select"
  SET reply->status_data.subeventstatus[1].operationstatus = "s"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "PRSNL"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#end_program
END GO
