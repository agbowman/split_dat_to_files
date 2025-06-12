CREATE PROGRAM bed_get_rx_patcare_synonyms:dba
 FREE SET reply
 RECORD reply(
   1 ingredients[*]
     2 id = f8
     2 synonyms[*]
       3 id = f8
       3 mnemonic = vc
       3 hide_flag = i2
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
 SET prim_cd = uar_get_code_by("MEANING",6011,"PRIMARY")
 SET dcp_cd = uar_get_code_by("MEANING",6011,"DCP")
 SET brand_cd = uar_get_code_by("MEANING",6011,"BRANDNAME")
 SET c_cd = uar_get_code_by("MEANING",6011,"DISPDRUG")
 SET e_cd = uar_get_code_by("MEANING",6011,"IVNAME")
 SET m_cd = uar_get_code_by("MEANING",6011,"GENERICTOP")
 SET n_cd = uar_get_code_by("MEANING",6011,"TRADETOP")
 FREE SET temp
 RECORD temp(
   1 ingredients[*]
     2 id = f8
     2 synonyms[*]
       3 id = f8
       3 mnemonic = vc
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
 DECLARE ocs_parse = vc
 SET ocs_parse = " ocs.active_ind = 1"
 IF (validate(request->intermittent_ind))
  IF ((request->intermittent_ind=1))
   SET ocs_parse = build(ocs_parse," and ocs.intermittent_ind = 1")
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(icnt)),
   order_catalog_item_r ir,
   order_catalog_synonym ocs
  PLAN (d)
   JOIN (ir
   WHERE (ir.item_id=request->ingredients[d.seq].id))
   JOIN (ocs
   WHERE ocs.catalog_cd=ir.catalog_cd
    AND ocs.mnemonic_type_cd IN (prim_cd, dcp_cd, brand_cd, c_cd, e_cd,
   m_cd, n_cd)
    AND parser(ocs_parse))
  ORDER BY d.seq
  HEAD d.seq
   cnt = 0, diluent_ind = 0, additive_ind = 0,
   medication_ind = 0
   IF ((request->ingredients[d.seq].rx_mask > 0))
    IF (band(request->ingredients[d.seq].rx_mask,1) > 0)
     diluent_ind = 1
    ENDIF
    IF (band(request->ingredients[d.seq].rx_mask,2) > 0)
     additive_ind = 1
    ENDIF
    IF (band(request->ingredients[d.seq].rx_mask,4) > 0)
     medication_ind = 1
    ENDIF
   ENDIF
  HEAD ocs.synonym_id
   IF ((request->ingredients[d.seq].rx_mask > 0))
    IF (((additive_ind=1) OR (((diluent_ind=1) OR (medication_ind=1)) )) )
     IF (((diluent_ind=1
      AND band(ocs.rx_mask,1) > 0) OR (((additive_ind=1
      AND band(ocs.rx_mask,2) > 0) OR (medication_ind=1
      AND band(ocs.rx_mask,4) > 0)) )) )
      IF ((request->powerorders_ind=1)
       AND ocs.hide_flag=0)
       cnt = (cnt+ 1), stat = alterlist(temp->ingredients[d.seq].synonyms,cnt), temp->ingredients[d
       .seq].synonyms[cnt].id = ocs.synonym_id,
       temp->ingredients[d.seq].synonyms[cnt].mnemonic = ocs.mnemonic, temp->ingredients[d.seq].
       synonyms[cnt].hide_flag = ocs.hide_flag, temp->ingredients[d.seq].synonyms[cnt].add_ind = 1
       IF ((request->ingredients[d.seq].titrate_ind=1)
        AND ocs.ingredient_rate_conversion_ind=0)
        temp->ingredients[d.seq].synonyms[cnt].add_ind = 0
       ENDIF
      ELSEIF ((request->powerorders_ind=0))
       cnt = (cnt+ 1), stat = alterlist(temp->ingredients[d.seq].synonyms,cnt), temp->ingredients[d
       .seq].synonyms[cnt].id = ocs.synonym_id,
       temp->ingredients[d.seq].synonyms[cnt].mnemonic = ocs.mnemonic, temp->ingredients[d.seq].
       synonyms[cnt].hide_flag = ocs.hide_flag, temp->ingredients[d.seq].synonyms[cnt].add_ind = 1
       IF ((request->ingredients[d.seq].titrate_ind=1)
        AND ocs.ingredient_rate_conversion_ind=0)
        temp->ingredients[d.seq].synonyms[cnt].add_ind = 0
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ELSE
    IF ((request->powerorders_ind=1)
     AND ocs.hide_flag=0)
     cnt = (cnt+ 1), stat = alterlist(temp->ingredients[d.seq].synonyms,cnt), temp->ingredients[d.seq
     ].synonyms[cnt].id = ocs.synonym_id,
     temp->ingredients[d.seq].synonyms[cnt].mnemonic = ocs.mnemonic, temp->ingredients[d.seq].
     synonyms[cnt].hide_flag = ocs.hide_flag, temp->ingredients[d.seq].synonyms[cnt].add_ind = 1
     IF ((request->ingredients[d.seq].titrate_ind=1)
      AND ocs.ingredient_rate_conversion_ind=0)
      temp->ingredients[d.seq].synonyms[cnt].add_ind = 0
     ENDIF
    ELSEIF ((request->powerorders_ind=0))
     cnt = (cnt+ 1), stat = alterlist(temp->ingredients[d.seq].synonyms,cnt), temp->ingredients[d.seq
     ].synonyms[cnt].id = ocs.synonym_id,
     temp->ingredients[d.seq].synonyms[cnt].mnemonic = ocs.mnemonic, temp->ingredients[d.seq].
     synonyms[cnt].hide_flag = ocs.hide_flag, temp->ingredients[d.seq].synonyms[cnt].add_ind = 1
     IF ((request->ingredients[d.seq].titrate_ind=1)
      AND ocs.ingredient_rate_conversion_ind=0)
      temp->ingredients[d.seq].synonyms[cnt].add_ind = 0
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
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
   SET rcnt = 0
   FOR (y = 1 TO cnt)
     IF ((temp->ingredients[x].synonyms[y].add_ind=1))
      SET found = 0
      FOR (z = 1 TO size(reply->ingredients[x].synonyms,5))
        IF ((temp->ingredients[x].synonyms[y].id=reply->ingredients[x].synonyms[z].id))
         SET found = 1
        ENDIF
      ENDFOR
      IF (found=0)
       SET rcnt = (rcnt+ 1)
       SET stat = alterlist(reply->ingredients[x].synonyms,rcnt)
       SET reply->ingredients[x].synonyms[rcnt].id = temp->ingredients[x].synonyms[y].id
       SET reply->ingredients[x].synonyms[rcnt].mnemonic = temp->ingredients[x].synonyms[y].mnemonic
       SET reply->ingredients[x].synonyms[rcnt].hide_flag = temp->ingredients[x].synonyms[y].
       hide_flag
      ENDIF
     ENDIF
   ENDFOR
 ENDFOR
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
