CREATE PROGRAM aps_get_prsnl_by_loc:dba
 DECLARE subevent_add(op_name=vc(value),op_status=vc(value),obj_name=vc(value),obj_value=vc(value))
  = null WITH protect
 SUBROUTINE subevent_add(op_name,op_status,obj_name,obj_value)
   DECLARE se_itm = i4 WITH protect, noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
   SET se_itm = size(reply->status_data.subeventstatus,5)
   SET stat = alter(reply->status_data.subeventstatus,(se_itm+ 1))
   SET reply->status_data.subeventstatus[se_itm].operationname = cnvtupper(substring(1,25,trim(
      op_name)))
   SET reply->status_data.subeventstatus[se_itm].operationstatus = cnvtupper(substring(1,1,trim(
      op_status)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectname = cnvtupper(substring(1,25,trim(
      obj_name)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectvalue = obj_value
 END ;Subroutine
 DECLARE pathologist_cdf = vc WITH constant("PATHOLOGIST"), protect
 DECLARE pathresident_cdf = vc WITH constant("PATHRESIDENT"), protect
 DECLARE nresidentuser = i4 WITH protect
 DECLARE npathuser = i4 WITH protect
 DECLARE idx3 = i4 WITH protect
 DECLARE idx2 = i4 WITH protect
 DECLARE idx1 = i4 WITH protect
 DECLARE idx = i4 WITH protect
 DECLARE num = i4 WITH protect
 DECLARE qual = i4 WITH protect
 DECLARE pathresident_var = f8 WITH constant(uar_get_code_by("MEANING",357,pathresident_cdf)),
 protect
 DECLARE pathologist_var = f8 WITH constant(uar_get_code_by("MEANING",357,pathologist_cdf)), protect
 DECLARE ncodecd_var = f8 WITH constant(uar_get_code_by("MEANING",30300,"PRSNLLOCRLTN")), protect
 RECORD reply(
   1 qual[*]
     2 prsnl_id = f8
     2 prsnl_name = vc
     2 path_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD pcs_request(
   1 return_inactives_ind = i2
   1 group_must_exist_ind = i2
   1 personnel_id = f8
   1 personnel_name = vc
   1 type_qual[*]
     2 type_cd = f8
   1 group_qual[*]
     2 group_id = f8
   1 group_type_qual[*]
     2 cdf_meaning = c12
 )
 RECORD pcs_reply(
   1 qual[*]
     2 prsnl_id = f8
     2 prsnl_name = vc
     2 username = vc
     2 position_cd = f8
     2 position_disp = c40
     2 position_desc = c40
     2 position_mean = c12
     2 active_ind = i2
     2 group_qual[*]
       3 group_id = f8
       3 group_name = vc
       3 group_type_cd = f8
       3 group_type_disp = c40
       3 group_type_desc = c40
       3 group_type_mean = c12
       3 prsnl_group_reltn_id = f8
       3 group_description = vc
     2 physician_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD prsnl_rec(
   1 qual[*]
     2 person_id = f8
 )
 SET reply->status_data.status = "F"
 IF (((pathologist_var <= 0.0) OR (ncodecd_var <= 0.0)) )
  CALL subevent_add("SELECT","Z","CODE_VALUE",
   "No Pathologist or Personnel location code values found.")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  pr.person_id
  FROM prsnl_reltn pr
  WHERE (pr.parent_entity_id=request->location_cd)
   AND pr.parent_entity_name="LOCATION"
   AND pr.reltn_type_cd=ncodecd_var
   AND pr.active_ind=1
  HEAD REPORT
   nbr_items = 0, stat = alterlist(prsnl_rec->qual,5)
  DETAIL
   nbr_items = (nbr_items+ 1)
   IF (nbr_items > 5
    AND mod(nbr_items,5)=1)
    stat = alterlist(prsnl_rec->qual,(nbr_items+ 4))
   ENDIF
   prsnl_rec->qual[nbr_items].person_id = pr.person_id
  FOOT REPORT
   stat = alterlist(prsnl_rec->qual,nbr_items)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 FOR (idx = 1 TO size(prsnl_rec->qual,5))
   SET stat = initrec(pcs_reply)
   SET pcs_request->personnel_id = prsnl_rec->qual[idx].person_id
   SET stat = alterlist(pcs_request->group_type_qual,2)
   SET pcs_request->group_type_qual[1].cdf_meaning = pathologist_cdf
   SET pcs_request->group_type_qual[2].cdf_meaning = pathresident_cdf
   EXECUTE pcs_get_personnel  WITH replace("REQUEST",pcs_request), replace("REPLY",pcs_reply)
   IF ((pcs_reply->status_data.status="S"))
    FOR (idx2 = 1 TO size(pcs_reply->qual,5))
      SET npathuser = 0
      SET nresidentuser = 0
      FOR (idx3 = 1 TO size(pcs_reply->qual[idx2].group_qual,5))
        IF ((pcs_reply->qual[idx2].group_qual[idx3].group_type_cd=pathologist_var))
         SET npathuser = 1
        ELSEIF ((pcs_reply->qual[idx2].group_qual[idx3].group_type_cd=pathresident_var))
         SET nresidentuser = 1
        ENDIF
      ENDFOR
      IF (((npathuser=1) OR (nresidentuser=1)) )
       SET qual = (qual+ 1)
       SET stat = alterlist(reply->qual,qual)
       SET reply->qual[qual].prsnl_id = pcs_reply->qual[idx2].prsnl_id
       SET reply->qual[qual].prsnl_name = pcs_reply->qual[idx2].prsnl_name
       IF (npathuser=1)
        SET reply->qual[qual].path_ind = 1
       ELSEIF (nresidentuser=1)
        SET reply->qual[qual].path_ind = 2
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
 ENDFOR
 IF (qual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
END GO
