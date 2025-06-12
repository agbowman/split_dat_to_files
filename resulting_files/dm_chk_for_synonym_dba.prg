CREATE PROGRAM dm_chk_for_synonym:dba
 IF (validate(syn_reply->status,"X")="X")
  FREE RECORD syn_reply
  RECORD syn_reply(
    1 status = c1
    1 synonym_ind = i2
  ) WITH persistscript
 ENDIF
 SET syn_reply->status = "F"
 SET syn_reply->synonym_ind = 0
 FREE RECORD syn
 RECORD syn(
   1 sch_install_ind = i2
   1 table_name = vc
   1 synonym_ind = i2
   1 str = vc
 )
 SET syn->table_name = cnvtupper( $1)
 SET syn->sch_install_ind = 0
 SET syn->synonym_ind = 1
 IF (validate(tgtdb->tbl_cnt,- (1)) > 0)
  SET syn->sch_install_ind = 1
 ENDIF
 IF ((syn->sch_install_ind=1))
  IF ((syn->table_name="ALLTABLES"))
   SELECT INTO "nl:"
    FROM all_synonyms s,
     (dummyt t  WITH seq = value(tgtdb->tbl_cnt))
    PLAN (t)
     JOIN (s
     WHERE s.owner="PUBLIC"
      AND (s.synonym_name=tgtdb->tbl[t.seq].tbl_name))
    DETAIL
     tgtdb->tbl[t.seq].synonym_ind = 0
    WITH nocounter
   ;end select
  ENDIF
 ELSE
  SELECT INTO "nl:"
   FROM all_synonyms s
   WHERE s.owner="PUBLIC"
    AND (s.synonym_name=syn->table_name)
   DETAIL
    syn->synonym_ind = 0
   WITH nocounter
  ;end select
 ENDIF
 IF ((syn->synonym_ind=1))
  SET syn_reply->synonym_ind = 1
 ENDIF
#exit_program
 SET syn_reply->status = "S"
END GO
