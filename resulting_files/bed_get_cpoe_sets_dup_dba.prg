CREATE PROGRAM bed_get_cpoe_sets_dup:dba
 FREE SET reply
 RECORD reply(
   1 sets[*]
     2 catalog_code_value = f8
     2 dups[*]
       3 description = vc
       3 primary_mnemonic = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET temp_dup
 RECORD temp_dup(
   1 sets[*]
     2 catalog_code_value = f8
     2 dup_ind = i2
     2 dup_desc = vc
     2 dup_pm = vc
     2 ingredients[*]
       3 synonym_id = f8
       3 order_sentence_display = vc
 )
 SET reply->status_data.status = "F"
 SET scnt = size(request->sets,5)
 IF (scnt=0)
  GO TO exit_script
 ENDIF
 SET catalog_type_cd = uar_get_code_by("MEANING",6000,"PHARMACY")
 SET activity_type_cd = uar_get_code_by("MEANING",106,"PHARMACY")
 SET cs_ord_cd = uar_get_code_by("MEANING",6030,"ORDERABLE")
 SET stat = alterlist(reply->sets,scnt)
 FOR (x = 1 TO scnt)
   SET reply->sets[x].catalog_code_value = request->sets[x].catalog_code_value
   SET icnt = size(request->sets[x].ingredients,5)
   IF (icnt > 0)
    SET tcnt = 0
    SELECT INTO "nl:"
     FROM order_catalog oc,
      cs_component cc,
      order_sentence os
     PLAN (oc
      WHERE oc.catalog_type_cd=catalog_type_cd
       AND oc.activity_type_cd=activity_type_cd
       AND oc.orderable_type_flag=8
       AND oc.active_ind=1
       AND (oc.catalog_cd != request->sets[x].catalog_code_value))
      JOIN (cc
      WHERE cc.catalog_cd=oc.catalog_cd
       AND cc.comp_type_cd=cs_ord_cd
       AND (cc.comp_id=request->sets[x].ingredients[1].synonym_id))
      JOIN (os
      WHERE os.order_sentence_id=outerjoin(cc.order_sentence_id)
       AND os.order_sentence_display_line=outerjoin(request->sets[x].ingredients[1].
       order_sentence_display)
       AND os.order_sentence_id > outerjoin(0))
     ORDER BY oc.catalog_cd
     HEAD REPORT
      cnt = 0, tcnt = 0, stat = alterlist(temp_dup->sets,10)
     HEAD oc.catalog_cd
      IF ((((request->sets[x].ingredients[1].order_sentence_display > " ")
       AND (os.order_sentence_display_line=request->sets[x].ingredients[1].order_sentence_display))
       OR ((request->sets[x].ingredients[1].order_sentence_display IN ("", " ", null))
       AND cc.order_sentence_id=0)) )
       cnt = (cnt+ 1), tcnt = (tcnt+ 1)
       IF (cnt > 10)
        stat = alterlist(temp_dup->sets,(tcnt+ 10)), cnt = 1
       ENDIF
       temp_dup->sets[tcnt].catalog_code_value = oc.catalog_cd, temp_dup->sets[tcnt].dup_ind = 1,
       temp_dup->sets[tcnt].dup_desc = oc.description,
       temp_dup->sets[tcnt].dup_pm = oc.primary_mnemonic
      ENDIF
     FOOT REPORT
      stat = alterlist(temp_dup->sets,tcnt)
     WITH nocounter
    ;end select
    IF (tcnt > 0)
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(tcnt)),
       cs_component cc,
       order_sentence os
      PLAN (d)
       JOIN (cc
       WHERE (cc.catalog_cd=temp_dup->sets[d.seq].catalog_code_value)
        AND cc.comp_type_cd=cs_ord_cd)
       JOIN (os
       WHERE os.order_sentence_id=outerjoin(cc.order_sentence_id)
        AND os.order_sentence_id > outerjoin(0))
      ORDER BY d.seq, cc.comp_id
      HEAD d.seq
       ccnt = 0, ctcnt = 0, stat = alterlist(temp_dup->sets[d.seq].ingredients,10)
      HEAD cc.comp_id
       ccnt = (ccnt+ 1), ctcnt = (ctcnt+ 1)
       IF (ccnt > 10)
        stat = alterlist(temp_dup->sets[d.seq].ingredients,(ctcnt+ 10)), ccnt = 1
       ENDIF
       temp_dup->sets[d.seq].ingredients[ctcnt].synonym_id = cc.comp_id, temp_dup->sets[d.seq].
       ingredients[ctcnt].order_sentence_display = os.order_sentence_display_line
      FOOT  d.seq
       stat = alterlist(temp_dup->sets[d.seq].ingredients,ctcnt)
      WITH nocounter
     ;end select
     SET dup_cnt = 0
     FOR (t = 1 TO tcnt)
       SET icnt2 = size(temp_dup->sets[t].ingredients,5)
       IF (icnt2=icnt)
        FOR (i = 1 TO icnt2)
          SET num = 0
          SET tindex = 0
          SET tindex = locateval(num,1,icnt,temp_dup->sets[t].ingredients[i].order_sentence_display,
           request->sets[x].ingredients[num].order_sentence_display,
           temp_dup->sets[t].ingredients[i].synonym_id,request->sets[x].ingredients[num].synonym_id)
          IF (tindex <= 0)
           SET temp_dup->sets[t].dup_ind = 0
          ENDIF
        ENDFOR
       ELSE
        SET temp_dup->sets[t].dup_ind = 0
       ENDIF
       IF ((temp_dup->sets[t].dup_ind=1))
        SET dup_cnt = (dup_cnt+ 1)
        SET stat = alterlist(reply->sets[x].dups,dup_cnt)
        SET reply->sets[x].dups[dup_cnt].description = temp_dup->sets[t].dup_desc
        SET reply->sets[x].dups[dup_cnt].primary_mnemonic = temp_dup->sets[t].dup_pm
       ENDIF
     ENDFOR
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
