CREATE PROGRAM ec_delete_order_profile_prefs:dba
 PROMPT
  "Enter person_id (Enter 0 to delete order profile prefs for all users): " = "empty",
  "Enter position_cd (Enter 0 to delete order profile prefs for all users): " = "empty",
  "Delete Ordlist-customview(1), Medlist-customview(2), or both(3): " = 0
  WITH personid, positioncd, typeflag
 FREE SET prefs
 RECORD prefs(
   1 entries[*]
     2 entry_id = f8
 )
 DECLARE spositioncd = vc WITH noconstant(cnvtstring( $POSITIONCD,19,2)), protect
 DECLARE stypeflag = i2 WITH noconstant(cnvtint( $TYPEFLAG)), protect
 DECLARE stype = vc
 DECLARE spersonid = vc WITH noconstant(cnvtstring( $PERSONID,19,2)), protect
 DECLARE usercontext = c255 WITH noconstant(""), protect
 DECLARE batchsize = i4 WITH noconstant(1000), protect
 DECLARE errmsg = vc WITH noconstant(fillstring(132," ")), protect
 DECLARE errcode = i4 WITH noconstant(1), protect
 DECLARE checkerror(emsg=vc,eoperation=vc) = null
 DECLARE entrycnt = i4 WITH noconstant(0), protect
 SET j = (size(spersonid,1)+ 10)
 SET usercontext = concat("prefgroup=",spersonid)
 SELECT INTO "nc_test.log"
  msg = build2("[",format(cnvtdatetime(curdate,curtime3),"@SHORTDATETIME"),"] Error: ")
  FROM dummyt d
  PLAN (d)
  DETAIL
   col 0, msg, row + 1,
   spositioncd, row + 1, spersonid,
   row + 1, stypeflag, row + 1
  WITH nocounter, append, maxcol = 1001
 ;end select
 IF (((( $PERSONID="empty")) OR (((( $POSITIONCD="empty")) OR (( $TYPEFLAG=0))) )) )
  CALL echo("Invalid prompt entries. Exiting script.")
  GO TO exit_script
 ENDIF
 IF (((stypeflag > 3) OR (stypeflag < 1)) )
  CALL echo("Invalid pref type. Exiting script.")
  GO TO exit_script
 ENDIF
 IF (stypeflag=1)
  SET stype = "ordlist-customview"
 ELSEIF (stypeflag=2)
  SET stype = "medlist-customview"
 ELSE
  SET stype = "ALL"
 ENDIF
#get_entries
 SET cnt = 0
 IF (trim( $PERSONID,3)="0"
  AND trim( $POSITIONCD,3)="0")
  CALL echo(build2("Preparing to delete ",stype," prefs for all users"))
  IF (stypeflag IN (1, 2))
   SELECT INTO "nl:"
    p7.entry_id
    FROM prefdir_entrydata p1,
     prefdir_entrydata p2,
     prefdir_entrydata p3,
     prefdir_entrydata p4,
     prefdir_entrydata p5,
     prefdir_entrydata p6,
     prefdir_entrydata p7
    PLAN (p1
     WHERE p1.dist_name_short="prefcontext=user,prefroot=prefroot")
     JOIN (p2
     WHERE p2.parent_id=p1.entry_id)
     JOIN (p3
     WHERE p3.parent_id=p2.entry_id
      AND substring(1,19,p3.dist_name_short)="prefgroup=component")
     JOIN (p4
     WHERE p4.parent_id=p3.entry_id
      AND substring(1,12,p4.dist_name_short)="prefgroup=om")
     JOIN (p5
     WHERE p5.parent_id=p4.entry_id
      AND substring(1,21,p5.dist_name_short)="prefgroup=powerorders")
     JOIN (p6
     WHERE p6.parent_id=p5.entry_id
      AND substring(1,22,p6.dist_name_short)="prefgroup=orderprofile")
     JOIN (p7
     WHERE p7.parent_id=p6.entry_id
      AND substring(1,28,p7.dist_name_short)=concat("prefgroup=",stype)
      AND (p7.entry_id=
     (SELECT
      p8.parent_id
      FROM prefdir_entrydata p8
      WHERE p8.parent_id=p7.entry_id)))
    DETAIL
     cnt = (cnt+ 1), stat = alterlist(prefs->entries,cnt), prefs->entries[cnt].entry_id = p7.entry_id
    WITH nocounter, maxrec = value(batchsize)
   ;end select
  ELSE
   SELECT INTO "nl:"
    p7.entry_id
    FROM prefdir_entrydata p1,
     prefdir_entrydata p2,
     prefdir_entrydata p3,
     prefdir_entrydata p4,
     prefdir_entrydata p5,
     prefdir_entrydata p6,
     prefdir_entrydata p7
    PLAN (p1
     WHERE p1.dist_name_short="prefcontext=user,prefroot=prefroot")
     JOIN (p2
     WHERE p2.parent_id=p1.entry_id)
     JOIN (p3
     WHERE p3.parent_id=p2.entry_id
      AND substring(1,19,p3.dist_name_short)="prefgroup=component")
     JOIN (p4
     WHERE p4.parent_id=p3.entry_id
      AND substring(1,12,p4.dist_name_short)="prefgroup=om")
     JOIN (p5
     WHERE p5.parent_id=p4.entry_id
      AND substring(1,21,p5.dist_name_short)="prefgroup=powerorders")
     JOIN (p6
     WHERE p6.parent_id=p5.entry_id
      AND substring(1,22,p6.dist_name_short)="prefgroup=orderprofile")
     JOIN (p7
     WHERE p7.parent_id=p6.entry_id
      AND ((substring(1,28,p7.dist_name_short)="prefgroup=medlist-customview") OR (substring(1,28,p7
      .dist_name_short)="prefgroup=ordlist-customview"))
      AND (p7.entry_id=
     (SELECT
      p8.parent_id
      FROM prefdir_entrydata p8
      WHERE p8.parent_id=p7.entry_id)))
    DETAIL
     cnt = (cnt+ 1), stat = alterlist(prefs->entries,cnt), prefs->entries[cnt].entry_id = p7.entry_id
    WITH nocounter, maxrec = value(batchsize)
   ;end select
  ENDIF
 ELSEIF (cnvtreal(trim( $PERSONID,3)) > 0)
  CALL echo(build2("Preparing to delete ",stype," preferences for person_id: ",spersonid))
  IF (stypeflag IN (1, 2))
   SELECT INTO "nl:"
    p7.entry_id
    FROM prefdir_entrydata p1,
     prefdir_entrydata p2,
     prefdir_entrydata p3,
     prefdir_entrydata p4,
     prefdir_entrydata p5,
     prefdir_entrydata p6,
     prefdir_entrydata p7
    PLAN (p1
     WHERE p1.dist_name_short="prefcontext=user,prefroot=prefroot")
     JOIN (p2
     WHERE p2.parent_id=p1.entry_id
      AND substring(1,j,p2.dist_name_short)=usercontext)
     JOIN (p3
     WHERE p3.parent_id=p2.entry_id
      AND substring(1,19,p3.dist_name_short)="prefgroup=component")
     JOIN (p4
     WHERE p4.parent_id=p3.entry_id
      AND substring(1,12,p4.dist_name_short)="prefgroup=om")
     JOIN (p5
     WHERE p5.parent_id=p4.entry_id
      AND substring(1,21,p5.dist_name_short)="prefgroup=powerorders")
     JOIN (p6
     WHERE p6.parent_id=p5.entry_id
      AND substring(1,22,p6.dist_name_short)="prefgroup=orderprofile")
     JOIN (p7
     WHERE p7.parent_id=p6.entry_id
      AND substring(1,28,p7.dist_name_short)=concat("prefgroup=",stype)
      AND (p7.entry_id=
     (SELECT
      p8.parent_id
      FROM prefdir_entrydata p8
      WHERE p8.parent_id=p7.entry_id)))
    DETAIL
     cnt = (cnt+ 1), stat = alterlist(prefs->entries,cnt), prefs->entries[cnt].entry_id = p7.entry_id
    WITH nocounter, maxrec = value(batchsize)
   ;end select
  ELSE
   SELECT INTO "nl:"
    p7.entry_id
    FROM prefdir_entrydata p1,
     prefdir_entrydata p2,
     prefdir_entrydata p3,
     prefdir_entrydata p4,
     prefdir_entrydata p5,
     prefdir_entrydata p6,
     prefdir_entrydata p7
    PLAN (p1
     WHERE p1.dist_name_short="prefcontext=user,prefroot=prefroot")
     JOIN (p2
     WHERE p2.parent_id=p1.entry_id
      AND substring(1,j,p2.dist_name_short)=usercontext)
     JOIN (p3
     WHERE p3.parent_id=p2.entry_id
      AND substring(1,19,p3.dist_name_short)="prefgroup=component")
     JOIN (p4
     WHERE p4.parent_id=p3.entry_id
      AND substring(1,12,p4.dist_name_short)="prefgroup=om")
     JOIN (p5
     WHERE p5.parent_id=p4.entry_id
      AND substring(1,21,p5.dist_name_short)="prefgroup=powerorders")
     JOIN (p6
     WHERE p6.parent_id=p5.entry_id
      AND substring(1,22,p6.dist_name_short)="prefgroup=orderprofile")
     JOIN (p7
     WHERE p7.parent_id=p6.entry_id
      AND ((substring(1,28,p7.dist_name_short)="prefgroup=medlist-customview") OR (substring(1,28,p7
      .dist_name_short)="prefgroup=ordlist-customview"))
      AND (p7.entry_id=
     (SELECT
      p8.parent_id
      FROM prefdir_entrydata p8
      WHERE p8.parent_id=p7.entry_id)))
    DETAIL
     cnt = (cnt+ 1), stat = alterlist(prefs->entries,cnt), prefs->entries[cnt].entry_id = p7.entry_id
    WITH nocounter, maxrec = value(batchsize)
   ;end select
  ENDIF
 ELSE
  CALL echo(build("Preparing to delete preferences for position_cd: ",spositioncd))
  IF (stypeflag IN (1, 2))
   SELECT INTO "nl:"
    p7.entry_id
    FROM prefdir_entrydata p1,
     prefdir_entrydata p2,
     prefdir_entrydata p3,
     prefdir_entrydata p4,
     prefdir_entrydata p5,
     prefdir_entrydata p6,
     prefdir_entrydata p7,
     prefdir_group pg
    PLAN (p1
     WHERE p1.dist_name_short="prefcontext=user,prefroot=prefroot")
     JOIN (p2
     WHERE p2.parent_id=p1.entry_id)
     JOIN (pg
     WHERE pg.entry_id=p2.entry_id
      AND (pg.value=
     (SELECT
      trim(concat(cnvtstring(p.person_id),".00"),3)
      FROM prsnl p
      WHERE p.position_cd=cnvtreal(spositioncd))))
     JOIN (p3
     WHERE p3.parent_id=p2.entry_id
      AND substring(1,19,p3.dist_name_short)="prefgroup=component")
     JOIN (p4
     WHERE p4.parent_id=p3.entry_id
      AND substring(1,12,p4.dist_name_short)="prefgroup=om")
     JOIN (p5
     WHERE p5.parent_id=p4.entry_id
      AND substring(1,21,p5.dist_name_short)="prefgroup=powerorders")
     JOIN (p6
     WHERE p6.parent_id=p5.entry_id
      AND substring(1,22,p6.dist_name_short)="prefgroup=orderprofile")
     JOIN (p7
     WHERE p7.parent_id=p6.entry_id
      AND substring(1,28,p7.dist_name_short)=concat("prefgroup=",stype)
      AND (p7.entry_id=
     (SELECT
      p8.parent_id
      FROM prefdir_entrydata p8
      WHERE p8.parent_id=p7.entry_id)))
    DETAIL
     cnt = (cnt+ 1), stat = alterlist(prefs->entries,cnt), prefs->entries[cnt].entry_id = p7.entry_id
    WITH nocounter, maxrec = value(batchsize)
   ;end select
  ELSE
   SELECT INTO "nl:"
    p7.entry_id
    FROM prefdir_entrydata p1,
     prefdir_entrydata p2,
     prefdir_entrydata p3,
     prefdir_entrydata p4,
     prefdir_entrydata p5,
     prefdir_entrydata p6,
     prefdir_entrydata p7,
     prefdir_group pg
    PLAN (p1
     WHERE p1.dist_name_short="prefcontext=user,prefroot=prefroot")
     JOIN (p2
     WHERE p2.parent_id=p1.entry_id)
     JOIN (pg
     WHERE pg.entry_id=p2.entry_id
      AND (pg.value=
     (SELECT
      trim(concat(cnvtstring(p.person_id),".00"),3)
      FROM prsnl p
      WHERE p.position_cd=cnvtreal(spositioncd))))
     JOIN (p3
     WHERE p3.parent_id=p2.entry_id
      AND substring(1,19,p3.dist_name_short)="prefgroup=component")
     JOIN (p4
     WHERE p4.parent_id=p3.entry_id
      AND substring(1,12,p4.dist_name_short)="prefgroup=om")
     JOIN (p5
     WHERE p5.parent_id=p4.entry_id
      AND substring(1,21,p5.dist_name_short)="prefgroup=powerorders")
     JOIN (p6
     WHERE p6.parent_id=p5.entry_id
      AND substring(1,22,p6.dist_name_short)="prefgroup=orderprofile")
     JOIN (p7
     WHERE p7.parent_id=p6.entry_id
      AND ((substring(1,28,p7.dist_name_short)="prefgroup=medlist-customview") OR (substring(1,28,p7
      .dist_name_short)="prefgroup=ordlist-customview"))
      AND (p7.entry_id=
     (SELECT
      p8.parent_id
      FROM prefdir_entrydata p8
      WHERE p8.parent_id=p7.entry_id)))
    DETAIL
     cnt = (cnt+ 1), stat = alterlist(prefs->entries,cnt), prefs->entries[cnt].entry_id = p7.entry_id
    WITH nocounter, maxrec = value(batchsize)
   ;end select
  ENDIF
 ENDIF
 IF (cnt=0)
  CALL echo("No preferences found. Exiting script.")
  GO TO exit_script
 ENDIF
 SET entrycnt = 0
 SET entrycnt = size(prefs->entries,5)
 DELETE  FROM prefdir_acl pa,
   (dummyt d  WITH seq = value(entrycnt))
  SET pa.seq = 1
  PLAN (d)
   JOIN (pa
   WHERE pa.entry_id IN (
   (SELECT
    pd.descendant_id
    FROM prefdir_descendant pd
    WHERE (pd.ancestor_id=prefs->entries[d.seq].entry_id))))
  WITH nocounter
 ;end delete
 CALL checkerror("ERROR: Cannot delete from PREFDIR_ACL","DELETE")
 DELETE  FROM prefdir_alias pa,
   (dummyt d  WITH seq = value(entrycnt))
  SET pa.seq = 1
  PLAN (d)
   JOIN (pa
   WHERE pa.entry_id IN (
   (SELECT
    pd.descendant_id
    FROM prefdir_descendant pd
    WHERE (pd.ancestor_id=prefs->entries[d.seq].entry_id))))
  WITH nocounter
 ;end delete
 CALL checkerror("ERROR: Cannot delete from PREFDIR_ALIAS","DELETE")
 DELETE  FROM prefdir_allowedvalues pa,
   (dummyt d  WITH seq = value(entrycnt))
  SET pa.seq = 1
  PLAN (d)
   JOIN (pa
   WHERE pa.entry_id IN (
   (SELECT
    pd.descendant_id
    FROM prefdir_descendant pd
    WHERE (pd.ancestor_id=prefs->entries[d.seq].entry_id))))
  WITH nocounter
 ;end delete
 CALL checkerror("ERROR: Cannot delete from PREFDIR_ALLOWEDVALUES","DELETE")
 DELETE  FROM prefdir_context pc,
   (dummyt d  WITH seq = value(entrycnt))
  SET pc.seq = 1
  PLAN (d)
   JOIN (pc
   WHERE pc.entry_id IN (
   (SELECT
    pd.descendant_id
    FROM prefdir_descendant pd
    WHERE (pd.ancestor_id=prefs->entries[d.seq].entry_id))))
  WITH nocounter
 ;end delete
 CALL checkerror("ERROR: Cannot delete from PREFDIR_CONTEXT","DELETE")
 DELETE  FROM prefdir_description pd,
   (dummyt d  WITH seq = value(entrycnt))
  SET pd.seq = 1
  PLAN (d)
   JOIN (pd
   WHERE pd.entry_id IN (
   (SELECT
    pd.descendant_id
    FROM prefdir_descendant pd
    WHERE (pd.ancestor_id=prefs->entries[d.seq].entry_id))))
  WITH nocounter
 ;end delete
 CALL checkerror("ERROR: Cannot delete from PREFDIR_DESCRIPTION","DELETE")
 DELETE  FROM prefdir_displayname pd,
   (dummyt d  WITH seq = value(entrycnt))
  SET pd.seq = 1
  PLAN (d)
   JOIN (pd
   WHERE pd.entry_id IN (
   (SELECT
    pd.descendant_id
    FROM prefdir_descendant pd
    WHERE (pd.ancestor_id=prefs->entries[d.seq].entry_id))))
  WITH nocounter
 ;end delete
 CALL checkerror("ERROR: Cannot delete from PREFDIR_DISPLAYNAME","DELETE")
 DELETE  FROM prefdir_entry pe,
   (dummyt d  WITH seq = value(entrycnt))
  SET pe.seq = 1
  PLAN (d)
   JOIN (pe
   WHERE pe.entry_id IN (
   (SELECT
    pd.descendant_id
    FROM prefdir_descendant pd
    WHERE (pd.ancestor_id=prefs->entries[d.seq].entry_id))))
  WITH nocounter
 ;end delete
 CALL checkerror("ERROR: Cannot delete from PREFDIR_ENTRY","DELETE")
 DELETE  FROM prefdir_group pg,
   (dummyt d  WITH seq = value(entrycnt))
  SET pg.seq = 1
  PLAN (d)
   JOIN (pg
   WHERE pg.entry_id IN (
   (SELECT
    pd.descendant_id
    FROM prefdir_descendant pd
    WHERE (pd.ancestor_id=prefs->entries[d.seq].entry_id))))
  WITH nocounter
 ;end delete
 CALL checkerror("ERROR: Cannot delete from PREFDIR_GROUP","DELETE")
 DELETE  FROM prefdir_multivalue pm,
   (dummyt d  WITH seq = value(entrycnt))
  SET pm.seq = 1
  PLAN (d)
   JOIN (pm
   WHERE pm.entry_id IN (
   (SELECT
    pd.descendant_id
    FROM prefdir_descendant pd
    WHERE (pd.ancestor_id=prefs->entries[d.seq].entry_id))))
  WITH nocounter
 ;end delete
 CALL checkerror("ERROR: Cannot delete from PREFDIR_MULTIVALUE","DELETE")
 DELETE  FROM prefdir_pointer pp,
   (dummyt d  WITH seq = value(entrycnt))
  SET pp.seq = 1
  PLAN (d)
   JOIN (pp
   WHERE pp.entry_id IN (
   (SELECT
    pd.descendant_id
    FROM prefdir_descendant pd
    WHERE (pd.ancestor_id=prefs->entries[d.seq].entry_id))))
  WITH nocounter
 ;end delete
 CALL checkerror("ERROR: Cannot delete from PREFDIR_POINTER","DELETE")
 DELETE  FROM prefdir_policy pp,
   (dummyt d  WITH seq = value(entrycnt))
  SET pp.seq = 1
  PLAN (d)
   JOIN (pp
   WHERE pp.entry_id IN (
   (SELECT
    pd.descendant_id
    FROM prefdir_descendant pd
    WHERE (pd.ancestor_id=prefs->entries[d.seq].entry_id))))
  WITH nocounter
 ;end delete
 CALL checkerror("ERROR: Cannot delete from PREFDIR_POLICY","DELETE")
 DELETE  FROM prefdir_root pr,
   (dummyt d  WITH seq = value(entrycnt))
  SET pr.seq = 1
  PLAN (d)
   JOIN (pr
   WHERE pr.entry_id IN (
   (SELECT
    pd.descendant_id
    FROM prefdir_descendant pd
    WHERE (pd.ancestor_id=prefs->entries[d.seq].entry_id))))
  WITH nocounter
 ;end delete
 CALL checkerror("ERROR: Cannot delete from PREFDIR_ROOT","DELETE")
 DELETE  FROM prefdir_source ps,
   (dummyt d  WITH seq = value(entrycnt))
  SET ps.seq = 1
  PLAN (d)
   JOIN (ps
   WHERE ps.entry_id IN (
   (SELECT
    pd.descendant_id
    FROM prefdir_descendant pd
    WHERE (pd.ancestor_id=prefs->entries[d.seq].entry_id))))
  WITH nocounter
 ;end delete
 CALL checkerror("ERROR: Cannot delete from PREFDIR_SOURCE","DELETE")
 DELETE  FROM prefdir_type pt,
   (dummyt d  WITH seq = value(entrycnt))
  SET pt.seq = 1
  PLAN (d)
   JOIN (pt
   WHERE pt.entry_id IN (
   (SELECT
    pd.descendant_id
    FROM prefdir_descendant pd
    WHERE (pd.ancestor_id=prefs->entries[d.seq].entry_id))))
  WITH nocounter
 ;end delete
 CALL checkerror("ERROR: Cannot delete from PREFDIR_TYPE","DELETE")
 DELETE  FROM prefdir_value pv,
   (dummyt d  WITH seq = value(entrycnt))
  SET pv.seq = 1
  PLAN (d)
   JOIN (pv
   WHERE pv.entry_id IN (
   (SELECT
    pd.descendant_id
    FROM prefdir_descendant pd
    WHERE (pd.ancestor_id=prefs->entries[d.seq].entry_id))))
  WITH nocounter
 ;end delete
 CALL checkerror("ERROR: Cannot delete from PREFDIR_VALUE","DELETE")
 DELETE  FROM long_text_reference lr,
   (dummyt d  WITH seq = value(entrycnt))
  SET lr.seq = 1
  PLAN (d)
   JOIN (lr
   WHERE (lr.parent_entity_id=prefs->entries[d.seq].entry_id)
    AND lr.parent_entity_name="PREFDIR_ENTRYDATA")
  WITH nocounter
 ;end delete
 CALL checkerror("ERROR: Cannot delete from LONG_TEXT_REFERENCE","DELETE")
 DELETE  FROM prefdir_entrydata pe,
   (dummyt d  WITH seq = value(entrycnt))
  SET pe.seq = 1
  PLAN (d)
   JOIN (pe
   WHERE pe.entry_id IN (
   (SELECT
    pd.descendant_id
    FROM prefdir_descendant pd
    WHERE (pd.ancestor_id=prefs->entries[d.seq].entry_id))))
  WITH nocounter
 ;end delete
 CALL checkerror("ERROR: Cannot delete from PREFDIR_ENTRYDATA","DELETE")
 UPDATE  FROM prefdir_entrydata pe,
   (dummyt d  WITH seq = value(entrycnt))
  SET pe.updt_dt_tm = cnvtdatetime(curdate,curtime3), pe.updt_cnt = (pe.updt_cnt+ 1), pe.updt_id =
   999999,
   pe.updt_task = 999999, pe.updt_applctx = 999999
  PLAN (d)
   JOIN (pe
   WHERE pe.entry_id IN (
   (SELECT
    pd.ancestor_id
    FROM prefdir_descendant pd
    WHERE (pd.descendant_id=prefs->entries[d.seq].entry_id))))
  WITH nocounter
 ;end update
 CALL checkerror("ERROR: Cannot update into PREFDIR_ENTRYDATA","UPDATE")
 DELETE  FROM prefdir_descendant pd,
   (dummyt d  WITH seq = value(entrycnt))
  SET pd.seq = 1
  PLAN (d)
   JOIN (pd
   WHERE pd.descendant_id IN (
   (SELECT
    pd2.descendant_id
    FROM prefdir_descendant pd2
    WHERE (pd2.ancestor_id=prefs->entries[d.seq].entry_id))))
  WITH nocounter
 ;end delete
 CALL checkerror("ERROR: Cannot delete from PREFDIR_DESCENDANT","DELETE")
 COMMIT
 GO TO get_entries
 SUBROUTINE checkerror(emsg,eoperation)
  SET errcode = error(errmsg,1)
  IF (errcode != 0)
   ROLLBACK
   CALL echo("Found errors. Writing out errors to ec_delete_order_profile_prefs.log. Exiting script."
    )
   SELECT INTO "ec_delete_order_profile_prefs.log"
    msg = build2("[",format(cnvtdatetime(curdate,curtime3),"@SHORTDATETIME"),"] Error: ",trim(emsg),
     " :: ",
     errmsg)
    FROM dummyt d
    PLAN (d)
    DETAIL
     col 0, msg, row + 1
    WITH nocounter, append, maxcol = 1001
   ;end select
   GO TO exit_script
  ENDIF
 END ;Subroutine
#exit_script
END GO
