CREATE PROGRAM bhs_find_ivset_from_orderidold:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Order_id" = 0
  WITH outdev, orderid
 IF (( $ORDERID > 0))
  SET temporderid =  $ORDERID
 ENDIF
 CALL echo(temporderid)
 DECLARE truesyndesc = vc
 SET truesynid = 0.0
 SET truesyndesc = ""
 SET actionseq = 0
 SET tempsyn = 0
 SET compseqcnt = 0
 SET tempcat_cd = 0
 SET truecat_cd = 0
 SET compcnt = 0
 SET code_value = 0
 SET code_set = 0.0
 SET code_set = 6011
 SET cdf_meaning = "PRIMARY"
 EXECUTE cpm_get_cd_for_cdf
 SET cprimary = code_value
 FREE RECORD cat
 RECORD cat(
   1 qual[*]
     2 catcd = f8
     2 matchcnt = i2
     2 synqualcnt = i2
     2 synqual[*]
       3 synid = f8
       3 oefieldmeaningid = f8
       3 oefieldval = vc
       3 oecdvalue = f8
 )
 FREE RECORD catcopy
 RECORD catcopy(
   1 qual[*]
     2 catcd = f8
     2 matchcnt = i2
     2 synqual[*]
       3 synid = f8
       3 vol = f8
       3 volunit = f8
       3 strength = f8
       3 strengthunit = f8
 )
 SET actionseq = 1
 SELECT INTO "NL:"
  FROM order_ingredient oi
  WHERE oi.order_id=temporderid
   AND oi.action_sequence=actionseq
  ORDER BY oi.comp_sequence DESC
  HEAD oi.order_id
   compseqcnt = oi.comp_sequence, tempsyn = oi.synonym_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("failed to find order Ingredient row")
  GO TO ext
 ENDIF
 CALL echo(build("TempSYN:",tempsyn))
 SET catcnt = 0
 SELECT INTO "NL:"
  FROM cs_component c1,
   cs_component c2,
   order_ingredient oi
  PLAN (c1
   WHERE c1.comp_id=tempsyn)
   JOIN (c2
   WHERE c2.catalog_cd=c1.catalog_cd)
   JOIN (oi
   WHERE oi.order_id=outerjoin(temporderid)
    AND oi.synonym_id=outerjoin(c2.comp_id)
    AND oi.action_sequence=outerjoin(actionseq))
  ORDER BY c2.catalog_cd
  HEAD c2.catalog_cd
   compcnt = 0, tempcat_cd = c2.catalog_cd,
   CALL echo(build("catalogCD:",c2.catalog_cd))
  HEAD c2.comp_id
   compcnt = (compcnt+ 1)
   IF (oi.order_id < 1)
    tempcat_cd = 0
   ENDIF
   CALL echo(build("__________",tempcat_cd)),
   CALL echo(build("______________",oi.order_detail_display_line))
  FOOT  c2.catalog_cd
   IF (tempcat_cd > 0
    AND compcnt=compseqcnt)
    truecat_cd = tempcat_cd, catcnt = (catcnt+ 1), stat = alterlist(cat->qual,catcnt),
    cat->qual[catcnt].catcd = tempcat_cd
   ENDIF
  WITH nocounter
 ;end select
 CALL echo(build("############",truecat_cd))
 CALL echo("Cat matches")
 CALL echorecord(cat)
 CALL echo("TEST")
 CALL echo(size(cat->qual,5))
 IF (((curqual <= 0) OR (size(cat->qual,5) <= 0)) )
  CALL echo("failed to find any Catalog IvSet matches")
  GO TO ext
 ENDIF
 IF (size(cat->qual,5)=1)
  CALL echo("First Select only found one CatIVSet so we can find the Syn and exit Exit here")
  GO TO findsynandexit
 ENDIF
 SET maxnumsynrec = 0
 CALL echo("@@@@@@@@@ Store Order Details @@@@@@@@@@@@@@@@@@@")
 SET syncnt = 0
 SELECT INTO outdev
  cs.*, osd.*
  FROM cs_component cs,
   order_sentence os,
   order_sentence_detail osd,
   (dummyt d  WITH seq = catcnt)
  PLAN (d)
   JOIN (cs
   WHERE (cs.catalog_cd=cat->qual[d.seq].catcd))
   JOIN (os
   WHERE os.order_sentence_id=cs.order_sentence_id)
   JOIN (osd
   WHERE osd.order_sentence_id=os.order_sentence_id)
  ORDER BY cs.catalog_cd, cs.comp_id
  HEAD cs.catalog_cd
   syncnt = 0
  DETAIL
   syncnt = (syncnt+ 1), cat->qual[d.seq].synqualcnt = syncnt, stat = alterlist(cat->qual[d.seq].
    synqual,syncnt),
   cat->qual[d.seq].synqual[syncnt].synid = cs.comp_id, cat->qual[d.seq].synqual[syncnt].
   oefieldmeaningid = osd.oe_field_id
   IF (osd.default_parent_entity_name="CODE_VALUE")
    cat->qual[d.seq].synqual[syncnt].oecdvalue = osd.default_parent_entity_id
   ENDIF
   cat->qual[d.seq].synqual[syncnt].oefieldval = osd.oe_field_display_value
   IF (syncnt > maxnumsynrec)
    maxnumsynrec = syncnt
   ENDIF
  WITH format, separator = " ", nullreport
 ;end select
 CALL echorecord(cat)
 CALL echo("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
 CALL echo("########## 'order_sentence_detail to order_detail' #########")
 SELECT INTO "NL:"
  FROM order_detail od,
   (dummyt d  WITH seq = size(cat->qual,5)),
   (dummyt d1  WITH seq = maxnumsynrec)
  PLAN (d)
   JOIN (d1
   WHERE (d1.seq < cat->qual[d.seq].synqualcnt))
   JOIN (od
   WHERE od.order_id=outerjoin(temporderid)
    AND od.oe_field_display_value=outerjoin(cat->qual[d.seq].synqual[d1.seq].oefieldval)
    AND od.oe_field_id=outerjoin(cat->qual[d.seq].synqual[d1.seq].oefieldmeaningid))
  DETAIL
   IF (od.oe_field_meaning_id > 0)
    CALL echo(d.seq),
    CALL echo(build("d1:",d1.seq)), cat->qual[d.seq].matchcnt = (cat->qual[d.seq].matchcnt+ 1)
   ENDIF
  WITH format, separator = " ", nullreport
 ;end select
 CALL echorecord(cat)
 SET maxmatch = 0
 FOR (x = 1 TO size(cat->qual,5))
   IF ((cat->qual[x].matchcnt > maxmatch))
    SET maxmatch = cat->qual[x].matchcnt
   ENDIF
 ENDFOR
 CALL echo(build("Max number of detail matches: ",maxmatch))
 CALL echo("############################################################")
 CALL echo("********** elimnate catalogIVSets with fewer detail matches *********")
 SET vol = 12718
 SET volunit = 12719
 SET strength = 12715
 SET strengthunit = 12716
 SET catcopycnt = 0
 SET syncnt = 0
 FOR (x = 1 TO size(cat->qual,5))
  CALL echo(build("**",cat->qual[x].matchcnt))
  IF ((cat->qual[x].matchcnt=maxmatch))
   SET catcopycnt = (catcopycnt+ 1)
   SET stat = alterlist(catcopy->qual,catcopycnt)
   SET catcopy->qual[catcopycnt].catcd = cat->qual[x].catcd
   SET stat = alterlist(catcopy->qual[catcopycnt].synqual,size(cat->qual[x].synqual,5))
   SET stat = alterlist(catcopy->qual[catcopycnt].synqual,1)
   SET syncnt = 1
   SET tempsyn = cat->qual[x].synqual[1].synid
   SET catcopy->qual[catcopycnt].synqual[syncnt].synid = cat->qual[x].synqual[1].synid
   FOR (y = 1 TO size(cat->qual[x].synqual,5))
     IF ((cat->qual[x].synqual[y].synid != tempsyn))
      SET stat = alterlist(catcopy->qual[catcopycnt].synqual,(size(catcopy->qual[catcopycnt].synqual,
        5)+ 1))
      SET syncnt = (syncnt+ 1)
      SET tempsyn = cat->qual[x].synqual[y].synid
      SET catcopy->qual[catcopycnt].synqual[syncnt].synid = cat->qual[x].synqual[y].synid
     ENDIF
     CALL echo(cat->qual[x].synqual[y].oefieldmeaningid)
     IF ((cat->qual[x].synqual[y].oefieldmeaningid=vol))
      SET catcopy->qual[catcopycnt].synqual[syncnt].vol = cnvtreal(cnvtalphanum(cat->qual[x].synqual[
        y].oefieldval))
     ELSEIF ((cat->qual[x].synqual[y].oefieldmeaningid=volunit))
      SET catcopy->qual[catcopycnt].synqual[syncnt].volunit = cat->qual[x].synqual[y].oecdvalue
     ELSEIF ((cat->qual[x].synqual[y].oefieldmeaningid=strength))
      SET catcopy->qual[catcopycnt].synqual[syncnt].strength = cnvtreal(cnvtalphanum(cat->qual[x].
        synqual[y].oefieldval))
     ELSEIF ((cat->qual[x].synqual[y].oefieldmeaningid=strengthunit))
      SET catcopy->qual[catcopycnt].synqual[syncnt].strengthunit = cat->qual[x].synqual[y].oecdvalue
     ENDIF
   ENDFOR
  ENDIF
 ENDFOR
 CALL echo("!!!!!!")
 CALL echorecord(catcopy)
 CALL echo("*********************************************************************")
 SET ingmatchcnt = 0
 IF (size(catcopy->qual,5) > 1)
  CALL echo("processed order_details - We still have more then one CatIVSet match")
  CALL echo(build("&&",size(catcopy->qual,5)))
  SELECT INTO  $OUTDEV
   FROM order_ingredient oi,
    order_catalog_synonym ocs,
    (dummyt d  WITH seq = size(catcopy->qual,5)),
    (dummyt d1  WITH seq = size(catcopy->qual[d.seq].synqual,5))
   PLAN (d)
    JOIN (ocs
    WHERE (ocs.catalog_cd=catcopy->qual[d.seq].catcd)
     AND ocs.mnemonic_type_cd=2583
     AND ocs.active_ind=1)
    JOIN (d1)
    JOIN (oi
    WHERE oi.order_id=temporderid
     AND oi.action_sequence=1
     AND (oi.synonym_id=catcopy->qual[d.seq].synqual[d1.seq].synid)
     AND (((oi.strength=catcopy->qual[d.seq].synqual[d1.seq].strength)
     AND (oi.strength_unit=catcopy->qual[d.seq].synqual[d1.seq].strengthunit)) OR ((oi.volume=catcopy
    ->qual[d.seq].synqual[d1.seq].vol)
     AND (oi.volume_unit=catcopy->qual[d.seq].synqual[d1.seq].volunit))) )
   HEAD ocs.synonym_id
    ingmatchcnt = 0
   DETAIL
    ingmatchcnt = (ingmatchcnt+ 1),
    CALL echo(build("detCnt",ingmatchcnt))
   FOOT  ocs.synonym_id
    CALL echo(build("footCnt",ingmatchcnt)),
    CALL echo(build("size",size(catcopy->qual[d.seq].synqual,5)))
    IF (ingmatchcnt=size(catcopy->qual[d.seq].synqual,5))
     truesynid = ocs.synonym_id, truesyndesc = ocs.mnemonic
    ENDIF
    catcopy->qual[d.seq].matchcnt = (catcopy->qual[d.seq].matchcnt+ 1)
   WITH format, separator = " ", nullreport
  ;end select
  IF (curqual > 0
   AND truesynid=0)
   SET tempmaxcnt = 0
   SET dupmaxsizefound = 0
   FOR (x = 1 TO size(catcopy->qual,5))
     IF ((catcopy->qual[x].matchcnt >= tempmaxcnt))
      IF ((catcopy->qual[x].matchcnt=tempmaxcnt))
       SET dupmaxsizefound = 1
      ELSE
       SET dupmaxsizefound = 0
      ENDIF
      SET tempmaxcnt = catcopy->qual[x].matchcnt
      SET tempcatcd = catcopy->qual[x].catcd
     ENDIF
   ENDFOR
   IF (dupmaxsizefound=0)
    CALL echo("found an CatIVSet that is unique enough")
    SET truecat_cd = tempcatcd
   ELSE
    CALL echo("Two or more sets had the same number of matching components")
   ENDIF
  ENDIF
 ELSEIF (size(catcopy->qual,5)=1)
  CALL echo("processed order_details - We only have one CatIVSet match")
  SELECT INTO "NL:"
   FROM order_catalog_synonym ocs,
    (dummyt d  WITH seq = size(catcopy->qual,5))
   PLAN (d)
    JOIN (ocs
    WHERE (ocs.catalog_cd=catcopy->qual[d.seq].catcd)
     AND ocs.mnemonic_type_cd=2583
     AND ocs.active_ind=1)
   DETAIL
    truesynid = ocs.synonym_id, truesyndesc = ocs.mnemonic
  ;end select
 ENDIF
#findsynandexit
 IF (truecat_cd > 0
  AND truesynid=0)
  CALL echo("CatCopyRec - catIVSet - orderSentenceDetail to order_ingredient match failed")
  CALL echo("Default to 'generic 'trueMatch'")
  SELECT INTO "NL:"
   ocs.synonym_id, ocs.catalog_cd
   FROM order_catalog_synonym ocs
   WHERE ocs.catalog_cd=truecat_cd
    AND ocs.mnemonic_type_cd=cprimary
    AND ocs.active_ind=1
   DETAIL
    truesynid = ocs.synonym_id, truesyndesc = ocs.mnemonic,
    CALL echo(build(ocs.mnemonic,":",ocs.synonym_id))
   WITH nocounter
  ;end select
  CALL echo(build("ivSetSynonymId:",truesynid))
 ENDIF
 CALL echo(build("IVSynonymCd:",truesynid))
 IF (truesynid < 1)
  SET truesynid = 999999
 ENDIF
 SELECT INTO  $OUTDEV
  FROM dummyt
  HEAD REPORT
   msg1 = build2("IvSetSynId:       ",cnvtstring(truesynid)), msg2 = build2("IvSetMnemonic:    ",
    truesyndesc), col 0,
   "{PS/792 0 translate 90 rotate/}", y_pos = 1, row + 1,
   "{F/1}{CPI/9}",
   CALL print(calcpos(36,(y_pos+ 0))), row + 2,
   msg1, row + 2, msg2
  WITH dio = 08, mine, time = 5
 ;end select
 GO TO trueext
#ext
 SET truesynid = 999999
 CALL echo(build("Not Found SnyId: ",truesynid))
#trueext
 CALL echo(build("CatIvSet SynID Pass Outbound:",truesynid))
END GO
