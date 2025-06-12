CREATE PROGRAM ecf_clean_ft_allergy:dba
 FREE SET clean_al
 RECORD clean_al(
   1 list[*]
     2 allergy_id = f8
     2 old_ftdesc = vc
     2 new_ftdesc = vc
 )
 DECLARE allist_cnt = i4 WITH noconstant(0)
 DECLARE rcnt = i4 WITH noconstant(0)
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE info_domain="MULTUM"
   AND info_name="ecf_clean_ft_allergy"
  DETAIL
   rcnt = 1
  WITH nocounter
 ;end select
 IF (rcnt > 0)
  CALL echo(concat("*** Freetext Allergy Cleanup Already Complete."))
  CALL echo(concat("*** Freetext Allergy Cleanup Already Complete."))
  CALL echo(concat("*** Freetext Allergy Cleanup Already Complete."))
  GO TO exit_script
 ENDIF
 INSERT  FROM dm_info
  SET info_domain = "MULTUM", info_name = "ecf_clean_ft_allergy", updt_dt_tm = cnvtdatetime(curdate,
    curtime3),
   updt_task = reqinfo->updt_task
  WITH nocounter
 ;end insert
 UPDATE  FROM nomenclature n
  SET n.source_string = null
  WHERE n.nomenclature_id=0.0
   AND n.source_string="0"
  WITH nocounter, check
 ;end update
 SELECT INTO "nl:"
  FROM allergy a,
   allergy b
  PLAN (a
   WHERE a.substance_nom_id=0
    AND a.substance_ftdesc="0")
   JOIN (b
   WHERE a.allergy_id=b.allergy_id
    AND a.allergy_id=b.allergy_instance_id)
  DETAIL
   allist_cnt = (allist_cnt+ 1), stat = alterlist(clean_al->list,allist_cnt), clean_al->list[
   allist_cnt].allergy_id = a.allergy_id,
   clean_al->list[allist_cnt].old_ftdesc = a.substance_ftdesc, clean_al->list[allist_cnt].new_ftdesc
    = b.substance_ftdesc
  WITH check, nocounter
 ;end select
 CALL echo(concat("*** UPDATING ",build(allist_cnt)," ALLERGY ROWS."))
 CALL echo(concat("*** UPDATING ",build(allist_cnt)," ALLERGY ROWS."))
 CALL echo(concat("*** UPDATING ",build(allist_cnt)," ALLERGY ROWS."))
 IF (allist_cnt > 0)
  UPDATE  FROM allergy al,
    (dummyt d  WITH seq = value(allist_cnt))
   SET al.substance_ftdesc = clean_al->list[d.seq].new_ftdesc, al.updt_dt_tm = cnvtdatetime(curdate,
     curtime3)
   PLAN (d
    WHERE d.seq > 0)
    JOIN (al
    WHERE (al.allergy_id=clean_al->list[d.seq].allergy_id)
     AND (al.substance_ftdesc=clean_al->list[d.seq].old_ftdesc))
   WITH nocounter
  ;end update
  CALL echo(concat("*** UPDATED ",build(curqual)," ALLERGY ROWS."))
  CALL echo(concat("*** UPDATED ",build(curqual)," ALLERGY ROWS."))
  CALL echo(concat("*** UPDATED ",build(curqual)," ALLERGY ROWS."))
 ENDIF
 COMMIT
#exit_script
END GO
