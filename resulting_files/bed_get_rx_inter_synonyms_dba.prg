CREATE PROGRAM bed_get_rx_inter_synonyms:dba
 FREE SET reply
 RECORD reply(
   1 ingredients[*]
     2 id = f8
     2 synonyms[*]
       3 id = f8
       3 mnemonic = vc
       3 mnemonic_type
         4 code_value = f8
         4 display = vc
         4 mean = vc
       3 hide_flag = i2
     2 catalog_code_value = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET rcnt = 0
 SET icnt = 0
 SET fcnt = 0
 DECLARE prim_cd = f8
 DECLARE dcp_cd = f8
 DECLARE brand_cd = f8
 DECLARE c_cd = f8
 DECLARE e_cd = f8
 DECLARE m_cd = f8
 DECLARE n_cd = f8
 DECLARE pharm_id = f8
 DECLARE synonym_mnemonic = vc
 DECLARE ord_cd = f8
 SET prim_cd = uar_get_code_by("MEANING",6011,"PRIMARY")
 SET dcp_cd = uar_get_code_by("MEANING",6011,"DCP")
 SET brand_cd = uar_get_code_by("MEANING",6011,"BRANDNAME")
 SET c_cd = uar_get_code_by("MEANING",6011,"DISPDRUG")
 SET e_cd = uar_get_code_by("MEANING",6011,"IVNAME")
 SET m_cd = uar_get_code_by("MEANING",6011,"GENERICTOP")
 SET n_cd = uar_get_code_by("MEANING",6011,"TRADETOP")
 SET ord_cd = uar_get_code_by("MEANING",6003,"ORDER")
 SET strength_format = 0
 SET volume_format = 0
 FREE SET temp
 RECORD temp(
   1 ingredients[*]
     2 id = f8
     2 synonyms[*]
       3 id = f8
       3 mnemonic = vc
       3 type
         4 code_value = f8
         4 display = vc
         4 mean = vc
       3 add_ind = i2
       3 fac[*]
         4 cd = f8
       3 hide_flag = i2
 )
 SET icnt = size(request->ingredients,5)
 SET stat = alterlist(reply->ingredients,icnt)
 SET stat = alterlist(temp->ingredients,icnt)
 FOR (x = 1 TO icnt)
  SET reply->ingredients[x].id = request->ingredients[x].id
  SET temp->ingredients[x].id = request->ingredients[x].id
 ENDFOR
 SELECT INTO "nl:"
  FROM order_entry_format oef
  PLAN (oef
   WHERE oef.oe_format_name IN ("Pharmacy Volume Med", "Pharmacy Strength Med")
    AND oef.action_type_cd=ord_cd)
  DETAIL
   IF (oef.oe_format_name="Pharmacy Volume Med")
    volume_format = oef.oe_format_id
   ENDIF
   IF (oef.oe_format_name="Pharmacy Strength Med")
    strength_format = oef.oe_format_id
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  synonym_mnemonic = cnvtupper(ocs.mnemonic)
  FROM (dummyt d  WITH seq = value(icnt)),
   order_catalog_item_r ocir,
   order_catalog_synonym ocs,
   order_catalog oc
  PLAN (d)
   JOIN (ocir
   WHERE (ocir.item_id=request->ingredients[d.seq].id))
   JOIN (oc
   WHERE oc.catalog_cd=ocir.catalog_cd
    AND oc.active_ind=1)
   JOIN (ocs
   WHERE ocs.catalog_cd=oc.catalog_cd
    AND ocs.mnemonic_type_cd IN (prim_cd, dcp_cd, brand_cd, c_cd, e_cd,
   m_cd, n_cd)
    AND ocs.active_ind=1)
  ORDER BY d.seq, synonym_mnemonic
  HEAD d.seq
   cnt = 0, reply->ingredients[d.seq].catalog_code_value = ocs.catalog_cd
  HEAD ocs.synonym_id
   IF (band(ocs.rx_mask,4) > 0)
    IF ((((request->strength_ind=1)
     AND ocs.oe_format_id=strength_format) OR ((request->volume_ind=1)
     AND ocs.oe_format_id=volume_format)) )
     IF ((request->powerorders_ind=1)
      AND ocs.hide_flag=0)
      cnt = (cnt+ 1), stat = alterlist(temp->ingredients[d.seq].synonyms,cnt), temp->ingredients[d
      .seq].synonyms[cnt].id = ocs.synonym_id,
      temp->ingredients[d.seq].synonyms[cnt].mnemonic = ocs.mnemonic, temp->ingredients[d.seq].
      synonyms[cnt].type.code_value = ocs.mnemonic_type_cd, temp->ingredients[d.seq].synonyms[cnt].
      type.display = uar_get_code_display(ocs.mnemonic_type_cd),
      temp->ingredients[d.seq].synonyms[cnt].type.mean = uar_get_code_meaning(ocs.mnemonic_type_cd),
      temp->ingredients[d.seq].synonyms[cnt].hide_flag = ocs.hide_flag, temp->ingredients[d.seq].
      synonyms[cnt].add_ind = 1
     ELSEIF ((request->powerorders_ind=0))
      cnt = (cnt+ 1), stat = alterlist(temp->ingredients[d.seq].synonyms,cnt), temp->ingredients[d
      .seq].synonyms[cnt].id = ocs.synonym_id,
      temp->ingredients[d.seq].synonyms[cnt].mnemonic = ocs.mnemonic, temp->ingredients[d.seq].
      synonyms[cnt].type.code_value = ocs.mnemonic_type_cd, temp->ingredients[d.seq].synonyms[cnt].
      type.display = uar_get_code_display(ocs.mnemonic_type_cd),
      temp->ingredients[d.seq].synonyms[cnt].type.mean = uar_get_code_meaning(ocs.mnemonic_type_cd),
      temp->ingredients[d.seq].synonyms[cnt].hide_flag = ocs.hide_flag, temp->ingredients[d.seq].
      synonyms[cnt].add_ind = 1
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 CALL echorecord(temp)
 IF ((request->powerorders_ind=1))
  FOR (q = 1 TO icnt)
    SET cnt = size(temp->ingredients[q].synonyms,5)
    IF (cnt > 0)
     SET fcnt = 0
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(cnt)),
       ocs_facility_r o
      PLAN (d)
       JOIN (o
       WHERE (o.synonym_id=temp->ingredients[q].synonyms[d.seq].id))
      ORDER BY d.seq, o.facility_cd DESC
      HEAD d.seq
       fcnt = 0
      DETAIL
       fcnt = (fcnt+ 1), stat = alterlist(temp->ingredients[q].synonyms[d.seq].fac,fcnt), temp->
       ingredients[q].synonyms[d.seq].fac[fcnt].cd = o.facility_cd
      WITH nocounter
     ;end select
    ENDIF
    FOR (x = 1 TO cnt)
     SET fcnt = size(temp->ingredients[q].synonyms[x].fac,5)
     IF (((size(request->facilities,5)=0) OR ((request->facilities[1].code_value=0))) )
      FOR (y = 1 TO fcnt)
        IF ((temp->ingredients[q].synonyms[x].fac[y].cd=0)
         AND (temp->ingredients[q].synonyms[x].add_ind != 0))
         SET temp->ingredients[q].synonyms[x].add_ind = 1
        ELSE
         SET temp->ingredients[q].synonyms[x].add_ind = 0
        ENDIF
      ENDFOR
      IF (fcnt=0)
       SET temp->ingredients[q].synonyms[x].add_ind = 0
      ENDIF
     ELSE
      FOR (z = 1 TO size(request->facilities,5))
        SET fac_found = 0
        IF (fcnt=0)
         SET fac_found = 0
        ENDIF
        FOR (y = 1 TO fcnt)
          IF ((temp->ingredients[q].synonyms[x].fac[y].cd IN (request->facilities[z].code_value, 0)))
           SET fac_found = 1
          ELSE
           IF (fac_found != 1)
            SET fac_found = 0
           ENDIF
          ENDIF
        ENDFOR
        IF (fac_found=0)
         SET temp->ingredients[q].synonyms[x].add_ind = 0
        ENDIF
      ENDFOR
     ENDIF
    ENDFOR
  ENDFOR
 ENDIF
 FOR (x = 1 TO icnt)
  SET cnt = size(temp->ingredients[x].synonyms,5)
  FOR (y = 1 TO cnt)
    IF ((temp->ingredients[x].synonyms[y].add_ind=1))
     SET rcnt = (rcnt+ 1)
     SET stat = alterlist(reply->ingredients[x].synonyms,rcnt)
     SET reply->ingredients[x].synonyms[rcnt].id = temp->ingredients[x].synonyms[y].id
     SET reply->ingredients[x].synonyms[rcnt].mnemonic = temp->ingredients[x].synonyms[y].mnemonic
     SET reply->ingredients[x].synonyms[rcnt].mnemonic_type.code_value = temp->ingredients[x].
     synonyms[y].type.code_value
     SET reply->ingredients[x].synonyms[rcnt].mnemonic_type.display = temp->ingredients[x].synonyms[y
     ].type.display
     SET reply->ingredients[x].synonyms[rcnt].mnemonic_type.mean = temp->ingredients[x].synonyms[y].
     type.mean
     SET reply->ingredients[x].synonyms[rcnt].hide_flag = temp->ingredients[x].synonyms[y].hide_flag
    ENDIF
  ENDFOR
 ENDFOR
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
