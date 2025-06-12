CREATE PROGRAM ams_pharm_cpoe_utility:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Facility:" = 0,
  "Product search:" = "",
  "Product:" = 0,
  "Product's Rx Mask:" = 0,
  "Product's primary:" = "",
  "Synonyms virtual viewed on:" = 0,
  "Product's short description:" = "",
  "Synonyms linked:" = 0
  WITH outdev, facilitycd, prodsearch,
  itemid, rxmask, primmnemonic,
  vvsyns, rxmnemonic, linksyns
 DECLARE incrementexecutioncnt(null) = null WITH protect
 DECLARE getmnemonic(synid=f8) = vc WITH protect
 DECLARE getitemdesc(itemid=f8) = vc WITH protect
 DECLARE getproductrxmask(itemid=f8) = i4 WITH protect
 DECLARE syn_rxmask_pos = i2 WITH protect, constant(5)
 DECLARE syn_vv_pos = i2 WITH protect, constant(7)
 DECLARE syn_link_pos = i2 WITH protect, constant(9)
 DECLARE syn_type_rx = f8 WITH protect, constant(uar_get_code_by("MEANING",6011,"RXMNEMONIC"))
 DECLARE syn_type_y = f8 WITH protect, constant(uar_get_code_by("MEANING",6011,"GENERICPROD"))
 DECLARE syn_type_z = f8 WITH protect, constant(uar_get_code_by("MEANING",6011,"TRADEPROD"))
 DECLARE desc_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",11000,"DESC"))
 DECLARE script_name = c22 WITH protect, constant("AMS_PHARM_CPOE_UTILITY")
 DECLARE detail_line = vc WITH protect, constant("Number of executions")
 DECLARE status = c1 WITH protect, noconstant("S")
 DECLARE statusstr = vc WITH protect
 DECLARE cclerror = vc WITH protect
 DECLARE listcheck = c1 WITH protect
 DECLARE listcnt = i4 WITH protect
 DECLARE synpos = i4 WITH protect
 DECLARE i = i4 WITH protect
 DECLARE vvaddcnt = i4 WITH protect
 DECLARE vvremovecnt = i4 WITH protect
 DECLARE linkaddcnt = i4 WITH protect
 DECLARE linkremovecnt = i4 WITH protect
 DECLARE updtrxmaskind = i4 WITH protect
 DECLARE rxmaskvalue = i4 WITH protect
 DECLARE itemdesc = vc WITH protect, noconstant(getitemdesc( $ITEMID))
 DECLARE disp = vc WITH protect
 RECORD vv_syns(
   1 list_sz = i4
   1 list[*]
     2 synonym_id = f8
     2 mnemonic = vc
     2 facility_cd = f8
     2 add_vv_ind = i2
     2 remove_vv_ind = i2
     2 updt_ind = i2
 ) WITH protect
 RECORD link_syns(
   1 list_sz = i4
   1 list[*]
     2 synonym_id = f8
     2 mnemonic = vc
     2 item_id = f8
     2 add_link_ind = i2
     2 remove_link_ind = i2
     2 updt_ind = i2
 ) WITH protect
 SET listcnt = 0
 SET listcheck = substring(1,1,reflect(parameter(syn_rxmask_pos,0)))
 IF (listcheck="L")
  WHILE (listcheck > " ")
    SET listcnt = (listcnt+ 1)
    SET listcheck = substring(1,1,reflect(parameter(syn_rxmask_pos,listcnt)))
    IF (listcheck="I")
     SET rxmaskvalue = (rxmaskvalue+ parameter(syn_rxmask_pos,listcnt))
    ENDIF
  ENDWHILE
 ELSEIF (parameter(syn_rxmask_pos,0) > 0)
  SET rxmaskvalue =  $RXMASK
 ENDIF
 SET listcnt = 0
 SET listcheck = substring(1,1,reflect(parameter(syn_vv_pos,0)))
 IF (listcheck="L")
  WHILE (listcheck > " ")
    SET listcnt = (listcnt+ 1)
    SET listcheck = substring(1,1,reflect(parameter(syn_vv_pos,listcnt)))
    IF (listcheck="F")
     SET vv_syns->list_sz = (vv_syns->list_sz+ 1)
     SET stat = alterlist(vv_syns->list,vv_syns->list_sz)
     SET vv_syns->list[vv_syns->list_sz].synonym_id = parameter(syn_vv_pos,listcnt)
     SET vv_syns->list[vv_syns->list_sz].mnemonic = getmnemonic(vv_syns->list[vv_syns->list_sz].
      synonym_id)
     SET vv_syns->list[vv_syns->list_sz].add_vv_ind = 1
     SET vv_syns->list[vv_syns->list_sz].updt_ind = 1
     SET vvaddcnt = (vvaddcnt+ 1)
    ENDIF
  ENDWHILE
 ELSEIF (parameter(syn_vv_pos,0) > 0.0)
  SET vv_syns->list_sz = 1
  SET stat = alterlist(vv_syns->list,vv_syns->list_sz)
  SET vv_syns->list[1].mnemonic = getmnemonic( $VVSYNS)
  SET vv_syns->list[1].synonym_id =  $VVSYNS
  SET vv_syns->list[1].add_vv_ind = 1
  SET vv_syns->list[1].updt_ind = 1
  SET vvaddcnt = (vvaddcnt+ 1)
 ENDIF
 SET listcnt = 0
 SET listcheck = substring(1,1,reflect(parameter(syn_link_pos,0)))
 IF (listcheck="L")
  WHILE (listcheck > " ")
    SET listcnt = (listcnt+ 1)
    SET listcheck = substring(1,1,reflect(parameter(syn_link_pos,listcnt)))
    IF (listcheck="F")
     SET link_syns->list_sz = (link_syns->list_sz+ 1)
     SET stat = alterlist(link_syns->list,link_syns->list_sz)
     SET link_syns->list[link_syns->list_sz].synonym_id = parameter(syn_link_pos,listcnt)
     SET link_syns->list[link_syns->list_sz].mnemonic = getmnemonic(link_syns->list[link_syns->
      list_sz].synonym_id)
     SET link_syns->list[link_syns->list_sz].item_id =  $ITEMID
     SET link_syns->list[link_syns->list_sz].add_link_ind = 1
     SET link_syns->list[link_syns->list_sz].updt_ind = 1
     SET linkaddcnt = (linkaddcnt+ 1)
    ENDIF
  ENDWHILE
 ELSEIF (parameter(syn_link_pos,0) > 0.0)
  SET link_syns->list_sz = 1
  SET stat = alterlist(link_syns->list,link_syns->list_sz)
  SET link_syns->list[1].item_id =  $ITEMID
  SET link_syns->list[1].synonym_id =  $LINKSYNS
  SET link_syns->list[1].mnemonic = getmnemonic( $LINKSYNS)
  SET link_syns->list[1].add_link_ind = 1
  SET link_syns->list[1].updt_ind = 1
  SET linkaddcnt = (linkaddcnt+ 1)
 ENDIF
 SELECT INTO "nl:"
  ocs.synonym_id
  FROM order_catalog_item_r ocir,
   order_catalog_synonym ocs,
   ocs_facility_r ofr
  PLAN (ocir
   WHERE (ocir.item_id= $ITEMID))
   JOIN (ocs
   WHERE ocs.catalog_cd=ocir.catalog_cd
    AND ocs.active_ind=1
    AND  NOT (ocs.mnemonic_type_cd IN (syn_type_rx, syn_type_y, syn_type_z))
    AND ocs.hide_flag=0)
   JOIN (ofr
   WHERE ofr.synonym_id=ocs.synonym_id
    AND ofr.facility_cd IN ( $FACILITYCD, 0.0))
  DETAIL
   synpos = locateval(i,1,vv_syns->list_sz,ocs.synonym_id,vv_syns->list[i].synonym_id)
   IF (synpos > 0)
    vv_syns->list[synpos].mnemonic = ocs.mnemonic, vv_syns->list[synpos].add_vv_ind = 0, vv_syns->
    list[synpos].updt_ind = 0,
    vvaddcnt = (vvaddcnt - 1)
   ELSE
    vv_syns->list_sz = (vv_syns->list_sz+ 1), stat = alterlist(vv_syns->list,vv_syns->list_sz),
    vv_syns->list[vv_syns->list_sz].mnemonic = ocs.mnemonic,
    vv_syns->list[vv_syns->list_sz].synonym_id = ofr.synonym_id, vv_syns->list[vv_syns->list_sz].
    facility_cd = ofr.facility_cd, vv_syns->list[vv_syns->list_sz].remove_vv_ind = 1,
    vv_syns->list[vv_syns->list_sz].updt_ind = 1, vvremovecnt = (vvremovecnt+ 1)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  ocs.synonym_id
  FROM order_catalog_item_r ocir,
   order_catalog_synonym ocs,
   synonym_item_r sir
  PLAN (ocir
   WHERE (ocir.item_id= $ITEMID))
   JOIN (ocs
   WHERE ocs.catalog_cd=ocir.catalog_cd)
   JOIN (sir
   WHERE sir.synonym_id=ocs.synonym_id
    AND sir.item_id=ocir.item_id)
  DETAIL
   synpos = locateval(i,1,link_syns->list_sz,ocs.synonym_id,link_syns->list[i].synonym_id)
   IF (synpos > 0)
    link_syns->list[synpos].mnemonic = ocs.mnemonic, link_syns->list[synpos].add_link_ind = 0,
    link_syns->list[synpos].updt_ind = 0,
    linkaddcnt = (linkaddcnt - 1)
   ELSE
    link_syns->list_sz = (link_syns->list_sz+ 1), stat = alterlist(link_syns->list,link_syns->list_sz
     ), link_syns->list[link_syns->list_sz].mnemonic = ocs.mnemonic,
    link_syns->list[link_syns->list_sz].synonym_id = sir.synonym_id, link_syns->list[link_syns->
    list_sz].item_id = sir.item_id, link_syns->list[link_syns->list_sz].remove_link_ind = 1,
    link_syns->list[link_syns->list_sz].updt_ind = 1, linkremovecnt = (linkremovecnt+ 1)
   ENDIF
  WITH nocounter
 ;end select
 IF (rxmaskvalue != getproductrxmask( $ITEMID))
  SET updtrxmaskind = 1
  UPDATE  FROM order_catalog_synonym ocs
   SET ocs.rx_mask = rxmaskvalue, ocs.updt_applctx = reqinfo->updt_applctx, ocs.updt_cnt = (ocs
    .updt_cnt+ 1),
    ocs.updt_dt_tm = cnvtdatetime(curdate,curtime3), ocs.updt_id = reqinfo->updt_id, ocs.updt_task =
    - (267)
   WHERE (ocs.item_id= $ITEMID)
   WITH nocounter
  ;end update
  IF (((curqual != 1) OR (error(cclerror,0) > 0)) )
   SET status = "F"
   SET statusstr = "Failed to update rx mask on order_catalog_synonym"
   GO TO exit_script
  ENDIF
 ENDIF
 IF (vvaddcnt > 0)
  INSERT  FROM (dummyt d  WITH seq = value(vv_syns->list_sz)),
    ocs_facility_r ofr
   SET ofr.facility_cd =  $FACILITYCD, ofr.synonym_id = vv_syns->list[d.seq].synonym_id, ofr
    .updt_applctx = reqinfo->updt_applctx,
    ofr.updt_cnt = 0, ofr.updt_dt_tm = cnvtdatetime(curdate,curtime3), ofr.updt_id = reqinfo->updt_id,
    ofr.updt_task = - (267)
   PLAN (d
    WHERE (vv_syns->list[d.seq].add_vv_ind=1)
     AND (vv_syns->list[d.seq].updt_ind=1))
    JOIN (ofr)
   WITH nocounter
  ;end insert
  IF (((curqual != vvaddcnt) OR (error(cclerror,0) > 0)) )
   SET status = "F"
   SET statusstr = "Failed to insert rows into ocs_facility_r"
   GO TO exit_script
  ENDIF
 ENDIF
 IF (vvremovecnt > 0)
  DELETE  FROM (dummyt d  WITH seq = value(vv_syns->list_sz)),
    ocs_facility_r ofr
   SET ofr.seq = 0
   PLAN (d
    WHERE (vv_syns->list[d.seq].remove_vv_ind=1)
     AND (vv_syns->list[d.seq].updt_ind=1))
    JOIN (ofr
    WHERE (ofr.facility_cd=vv_syns->list[d.seq].facility_cd)
     AND (ofr.synonym_id=vv_syns->list[d.seq].synonym_id))
   WITH nocounter
  ;end delete
  IF (((curqual != vvremovecnt) OR (error(cclerror,0) > 0)) )
   SET status = "F"
   SET statusstr = "Failed to delete rows from ocs_facility_r"
   GO TO exit_script
  ENDIF
 ENDIF
 IF (linkaddcnt > 0)
  INSERT  FROM (dummyt d  WITH seq = value(link_syns->list_sz)),
    synonym_item_r sir
   SET sir.item_id = link_syns->list[d.seq].item_id, sir.synonym_id = link_syns->list[d.seq].
    synonym_id, sir.updt_applctx = reqinfo->updt_applctx,
    sir.updt_cnt = 0, sir.updt_dt_tm = cnvtdatetime(curdate,curtime3), sir.updt_id = reqinfo->updt_id,
    sir.updt_task = - (267)
   PLAN (d
    WHERE (link_syns->list[d.seq].add_link_ind=1)
     AND (link_syns->list[d.seq].updt_ind=1))
    JOIN (sir)
   WITH nocounter
  ;end insert
  IF (((curqual != linkaddcnt) OR (error(cclerror,0) > 0)) )
   SET status = "F"
   SET statusstr = "Failed to insert rows into synonym_item_r"
   GO TO exit_script
  ENDIF
 ENDIF
 IF (linkremovecnt > 0)
  DELETE  FROM (dummyt d  WITH seq = value(link_syns->list_sz)),
    synonym_item_r sir
   SET sir.seq = 0
   PLAN (d
    WHERE (link_syns->list[d.seq].remove_link_ind=1)
     AND (link_syns->list[d.seq].updt_ind=1))
    JOIN (sir
    WHERE (sir.item_id=link_syns->list[d.seq].item_id)
     AND (sir.synonym_id=link_syns->list[d.seq].synonym_id))
   WITH nocounter
  ;end delete
  IF (((curqual != linkremovecnt) OR (error(cclerror,0) > 0)) )
   SET status = "F"
   SET statusstr = "Failed to delete rows from synonym_item_r"
   GO TO exit_script
  ENDIF
 ENDIF
 CALL incrementexecutioncnt(null)
 SUBROUTINE incrementexecutioncnt(null)
   DECLARE found = i2 WITH noconstant(0), protect
   DECLARE infonbr = i4 WITH protect
   DECLARE lastupdt = dq8 WITH protect
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="AMS_TOOLKIT"
     AND d.info_name=script_name
    DETAIL
     found = 1, infonbr = (d.info_number+ 1), lastupdt = d.updt_dt_tm
    WITH nocounter
   ;end select
   IF (found=0)
    INSERT  FROM dm_info d
     SET d.info_domain = "AMS_TOOLKIT", d.info_name = script_name, d.info_date = cnvtdatetime(curdate,
       curtime3),
      d.info_number = 1.0, d.info_char = detail_line, d.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      d.updt_cnt = 0, d.updt_id = reqinfo->updt_id, d.updt_task = - (267)
     WITH nocounter
    ;end insert
   ELSE
    UPDATE  FROM dm_info d
     SET d.info_number = infonbr, d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_cnt = (d
      .updt_cnt+ 1),
      d.updt_id = reqinfo->updt_id, d.updt_task = - (267)
     WHERE d.info_domain="AMS_TOOLKIT"
      AND d.info_name=script_name
     WITH nocounter
    ;end update
   ENDIF
   IF (error(cclerror,0) > 0)
    SET status = "F"
    SET statusstr = "Failed incrementing execution count"
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE getmnemonic(synid)
   DECLARE retval = vc WITH protect
   SELECT INTO "nl:"
    ocs.mnemonic
    FROM order_catalog_synonym ocs
    WHERE ocs.synonym_id=synid
    DETAIL
     retval = ocs.mnemonic
    WITH nocounter
   ;end select
   RETURN(retval)
 END ;Subroutine
 SUBROUTINE getitemdesc(itemid)
   DECLARE retval = vc WITH protect
   SELECT INTO "nl:"
    mi.value
    FROM med_identifier mi
    WHERE mi.item_id=itemid
     AND mi.med_identifier_type_cd=desc_cd
     AND mi.active_ind=1
     AND mi.primary_ind=1
     AND mi.med_product_id=0
    DETAIL
     retval = mi.value
    WITH nocounter
   ;end select
   RETURN(retval)
 END ;Subroutine
 SUBROUTINE getproductrxmask(itemid)
   DECLARE retval = i4 WITH protect
   SELECT INTO "nl:"
    ocs.rx_mask
    FROM order_catalog_synonym ocs
    WHERE ocs.item_id=itemid
    DETAIL
     retval = ocs.rx_mask
    WITH nocounter
   ;end select
   RETURN(retval)
 END ;Subroutine
#exit_script
 IF (status="F")
  ROLLBACK
  SELECT INTO  $OUTDEV
   FROM dummyt d
   DETAIL
    row 1, col 10, "Script failed to completed successfully",
    row + 1, col 10, statusstr,
    row + 1, col 10, cclerror
   WITH nocounter
  ;end select
 ELSEIF (status="S")
  COMMIT
  SELECT INTO  $OUTDEV
   FROM dummyt d
   DETAIL
    IF (updtrxmaskind=1)
     row + 1, disp = build2("Rx mask for ",itemdesc," updated to:"), col 10,
     disp
     IF (band(rxmaskvalue,1) > 0)
      row + 1, col 20, "Diluent"
     ENDIF
     IF (band(rxmaskvalue,2) > 0)
      row + 1, col 20, "Additive"
     ENDIF
     IF (band(rxmaskvalue,4) > 0)
      row + 1, col 20, "Med"
     ENDIF
    ENDIF
    IF (vvaddcnt > 0)
     row + 1, col 10, "Virtual viewed on:"
     FOR (i = 1 TO vv_syns->list_sz)
       IF ((vv_syns->list[i].add_vv_ind=1)
        AND (vv_syns->list[i].updt_ind=1))
        row + 1, col 20, vv_syns->list[i].mnemonic
       ENDIF
     ENDFOR
    ENDIF
    IF (vvremovecnt > 0)
     row + 1, col 10, "Virtual viewed off:"
     FOR (i = 1 TO vv_syns->list_sz)
       IF ((vv_syns->list[i].remove_vv_ind=1)
        AND (vv_syns->list[i].updt_ind=1))
        row + 1, col 20, vv_syns->list[i].mnemonic
       ENDIF
     ENDFOR
    ENDIF
    IF (linkaddcnt > 0)
     row + 1, disp = build2("Linked ",itemdesc," to:"), col 10,
     disp
     FOR (i = 1 TO link_syns->list_sz)
       IF ((link_syns->list[i].add_link_ind=1)
        AND (link_syns->list[i].updt_ind=1))
        row + 1, col 20, link_syns->list[i].mnemonic
       ENDIF
     ENDFOR
    ENDIF
    IF (linkremovecnt > 0)
     row + 1, disp = build2("Removed linking between ",itemdesc," and:"), col 10,
     disp
     FOR (i = 1 TO link_syns->list_sz)
       IF ((link_syns->list[i].remove_link_ind=1)
        AND (link_syns->list[i].updt_ind=1))
        row + 1, col 20, link_syns->list[i].mnemonic
       ENDIF
     ENDFOR
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SET last_mod = "002"
END GO
