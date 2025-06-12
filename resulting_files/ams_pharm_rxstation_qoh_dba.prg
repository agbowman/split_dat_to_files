CREATE PROGRAM ams_pharm_rxstation_qoh:dba
 PROMPT
  "Enter MINE/CRT/printer/file:" = "MINE",
  "Enter the facility (* for all):" = ""
  WITH outdev, facility
 DECLARE cformat = c50 WITH protect, constant(fillstring(50,"#"))
 DECLARE nfacilitycounter = i2 WITH protect, noconstant(0)
 EXECUTE rx_get_facs_for_prsnl_rr_incl  WITH replace("REQUEST","PRSNL_FACS_REQ"), replace("REPLY",
  "PRSNL_FACS_REPLY")
 SET stat = alterlist(prsnl_facs_req->qual,1)
 CALL echo(build("Reqinfo->updt_id --",reqinfo->updt_id))
 CALL echo(build("curuser --",curuser))
 SET prsnl_facs_req->qual[1].username = trim(curuser)
 SET prsnl_facs_req->qual[1].person_id = reqinfo->updt_id
 EXECUTE rx_get_facs_for_prsnl  WITH replace("REQUEST","PRSNL_FACS_REQ"), replace("REPLY",
  "PRSNL_FACS_REPLY")
 CALL echo(build("Size of facility list in prg--",size(prsnl_facs_reply->qual[1].facility_list,5)))
 FREE RECORD facility_list
 RECORD facility_list(
   1 qual[*]
     2 facility_cd = f8
 )
 SET stat = alterlist(facility_list->qual,value(size(prsnl_facs_reply->qual[1].facility_list,5)))
 FOR (x = 1 TO size(prsnl_facs_reply->qual[1].facility_list,5))
   CALL echo(build("Checking facility --",trim(format(prsnl_facs_reply->qual[1].facility_list[x].
       facility_cd,cformat),3)))
   CALL echo(build("against --", $FACILITY))
   IF ((trim(format(prsnl_facs_reply->qual[1].facility_list[x].facility_cd,cformat),3)= $FACILITY))
    SET nfacilitycounter = (nfacilitycounter+ 1)
    SET facility_list->qual[nfacilitycounter].facility_cd = prsnl_facs_reply->qual[1].facility_list[x
    ].facility_cd
   ENDIF
 ENDFOR
 SET stat = alterlist(facility_list->qual,nfacilitycounter)
 SET nfacactualsize = size(facility_list->qual,5)
 CALL echo(build("nFacActualSize --",nfacactualsize))
 IF (nfacactualsize=0)
  CALL echo("*** User does not have access to facility selection ***")
  GO TO exit_script
 ENDIF
 SELECT DISTINCT INTO  $OUTDEV
  cluster = uar_get_code_display(lgdev.parent_loc_cd), ndc = mi.value_key, quan_on_hand = qoh.qty
  FROM location_group lgfac,
   location_group lgbuild,
   location_group lgdev,
   item_control_info ici,
   med_def_flex mdf,
   med_flex_object_idx mfoi,
   med_identifier mi,
   quantity_on_hand qoh,
   (dummyt d  WITH seq = value(size(facility_list->qual,5)))
  PLAN (d)
   JOIN (lgfac
   WHERE (lgfac.parent_loc_cd=facility_list->qual[d.seq].facility_cd)
    AND lgfac.location_group_type_cd=value(uar_get_code_by("MEANING",222,"FACILITY"))
    AND ((lgfac.active_ind+ 0)=1))
   JOIN (lgbuild
   WHERE lgbuild.parent_loc_cd=lgfac.child_loc_cd
    AND lgbuild.location_group_type_cd=value(uar_get_code_by("MEANING",222,"BUILDING"))
    AND ((lgbuild.active_ind+ 0)=1))
   JOIN (lgdev
   WHERE lgdev.parent_loc_cd=lgbuild.child_loc_cd
    AND ((lgdev.root_loc_cd+ 0)=value(uar_get_code_by("MEANING",222,"RXSVIEW")))
    AND ((lgdev.active_ind+ 0)=1)
    AND lgdev.location_group_type_cd=value(uar_get_code_by("MEANING",222,"ADMCLUSTER")))
   JOIN (ici
   WHERE ici.location_cd=lgdev.child_loc_cd)
   JOIN (mdf
   WHERE mdf.item_id=ici.item_id
    AND mdf.flex_type_cd=value(uar_get_code_by("MEANING",4062,"SYSTEM")))
   JOIN (mfoi
   WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
    AND mfoi.flex_object_type_cd=value(uar_get_code_by("MEANING",4063,"MEDPRODUCT"))
    AND mfoi.sequence=1)
   JOIN (mi
   WHERE mi.med_product_id=mfoi.parent_entity_id
    AND mi.med_identifier_type_cd=value(uar_get_code_by("MEANING",11000,"NDC")))
   JOIN (qoh
   WHERE qoh.location_cd=outerjoin(ici.location_cd)
    AND qoh.item_id=outerjoin(ici.item_id)
    AND qoh.active_ind=outerjoin(1)
    AND qoh.locator_cd=outerjoin(0))
  ORDER BY lgfac.parent_loc_cd, lgbuild.parent_loc_cd, lgdev.parent_loc_cd,
   lgdev.child_loc_cd, mi.item_id
  WITH nocounter, separator = " ", format,
   compress
 ;end select
END GO
