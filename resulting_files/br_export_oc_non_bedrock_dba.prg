CREATE PROGRAM br_export_oc_non_bedrock:dba
 RECORD temp(
   1 oclist[5000]
     2 catalog_cd = f8
     2 catalog_type = vc
     2 activity_type = vc
     2 subactivity_type = vc
     2 primary = vc
     2 ancillary = vc
     2 dcp = vc
     2 desc = vc
     2 othername1 = vc
     2 othername2 = vc
     2 othername3 = vc
     2 othername4 = vc
     2 othername5 = vc
 )
 SET cnt = 0
 SELECT INTO "nl:"
  FROM code_value c,
   order_catalog oc,
   code_value c2,
   order_catalog_synonym ocs,
   code_value c3
  PLAN (c
   WHERE c.code_set=6000
    AND c.active_ind=1)
   JOIN (oc
   WHERE oc.catalog_type_cd=c.code_value
    AND oc.active_ind=1)
   JOIN (c2
   WHERE c2.code_value=oc.activity_type_cd
    AND c2.active_ind=1)
   JOIN (ocs
   WHERE ocs.catalog_cd=oc.catalog_cd
    AND ocs.active_ind=1
    AND ((ocs.mnemonic_type_cd=2579) OR (((ocs.mnemonic_type_cd=2581) OR (ocs.mnemonic_type_cd=2583
   )) )) )
   JOIN (c3
   WHERE c3.code_value=outerjoin(ocs.activity_subtype_cd))
  HEAD REPORT
   cnt = 0
  HEAD oc.catalog_cd
   cnt = (cnt+ 1)
   IF (cnt > 5000)
    stat = alter(temp->oclist,cnt)
   ENDIF
   temp->oclist[cnt].catalog_cd = ocs.catalog_cd, temp->oclist[cnt].catalog_type = replace(c
    .display_key,","," ",0), temp->oclist[cnt].desc = replace(oc.description,","," ",0),
   temp->oclist[cnt].activity_type = replace(c2.display_key,","," ",0)
  DETAIL
   IF (ocs.mnemonic_type_cd=2583)
    temp->oclist[cnt].primary = replace(ocs.mnemonic,","," ",0)
    IF (c3.code_value > 0)
     temp->oclist[cnt].subactivity_type = replace(c3.display_key,",","  ",0)
    ENDIF
   ELSEIF (ocs.mnemonic_type_cd=2581)
    temp->oclist[cnt].dcp = replace(ocs.mnemonic,","," ",0)
   ELSEIF (ocs.mnemonic_type_cd=2579)
    temp->oclist[cnt].ancillary = replace(ocs.mnemonic,","," ",0)
   ENDIF
  WITH nocounter
 ;end select
 CALL echo(build("start count = ",cnvtstring(cnt)))
 SELECT INTO "nl:"
  FROM code_value c,
   br_auto_order_catalog oc,
   code_value c2,
   br_auto_oc_synonym ocs,
   code_value c3
  PLAN (c
   WHERE c.code_set=6000
    AND c.active_ind=1)
   JOIN (oc
   WHERE oc.catalog_type_cd=c.code_value)
   JOIN (c2
   WHERE c2.code_value=oc.activity_type_cd)
   JOIN (ocs
   WHERE ocs.catalog_cd=oc.catalog_cd
    AND ((ocs.mnemonic_type_cd=2579) OR (((ocs.mnemonic_type_cd=2581) OR (ocs.mnemonic_type_cd=2583
   )) )) )
   JOIN (c3
   WHERE c3.code_value=outerjoin(ocs.activity_subtype_cd))
  HEAD oc.catalog_cd
   cnt = (cnt+ 1)
   IF (cnt > 5000)
    stat = alter(temp->oclist,cnt)
   ENDIF
   temp->oclist[cnt].catalog_cd = ocs.catalog_cd, temp->oclist[cnt].catalog_type = replace(c
    .display_key,","," ",0), temp->oclist[cnt].desc = replace(oc.description,","," ",0),
   temp->oclist[cnt].activity_type = replace(c2.display_key,","," ",0)
  DETAIL
   IF (ocs.mnemonic_type_cd=2583)
    temp->oclist[cnt].primary = replace(ocs.mnemonic,","," ",0)
    IF (c3.code_value > 0)
     temp->oclist[cnt].subactivity_type = replace(c3.display_key,",","  ",0)
    ENDIF
   ELSEIF (ocs.mnemonic_type_cd=2581)
    temp->oclist[cnt].dcp = replace(ocs.mnemonic,","," ",0)
   ELSEIF (ocs.mnemonic_type_cd=2579)
    temp->oclist[cnt].ancillary = replace(ocs.mnemonic,","," ",0)
   ENDIF
  WITH nocounter
 ;end select
 CALL echo(build("total count = ",cnvtstring(cnt)))
 IF (cnt < 5000)
  SET stat = alter(temp->oclist,cnt)
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = cnt),
   br_other_names bon
  PLAN (d)
   JOIN (bon
   WHERE (bon.parent_entity_id=temp->oclist[d.seq].catalog_cd)
    AND bon.parent_entity_name="CODE_VALUE")
  HEAD d.seq
   oncnt = 0
  DETAIL
   oncnt = (oncnt+ 1)
   IF (oncnt=1)
    temp->oclist[d.seq].othername1 = replace(bon.alias_name,","," ",0)
   ELSEIF (oncnt=2)
    temp->oclist[d.seq].othername2 = replace(bon.alias_name,","," ",0)
   ELSEIF (oncnt=3)
    temp->oclist[d.seq].othername3 = replace(bon.alias_name,","," ",0)
   ELSEIF (oncnt=4)
    temp->oclist[d.seq].othername4 = replace(bon.alias_name,","," ",0)
   ELSEIF (oncnt=5)
    temp->oclist[d.seq].othername5 = replace(bon.alias_name,","," ",0)
   ENDIF
  WITH nocounter
 ;end select
 DECLARE line = vc
 SELECT INTO "br_export_oc.csv"
  catalog_cd = temp->oclist[d.seq].catalog_cd, catalog_type = temp->oclist[d.seq].catalog_type,
  activity_type = temp->oclist[d.seq].activity_type,
  subactivity_type = temp->oclist[d.seq].subactivity_type, primary = temp->oclist[d.seq].primary,
  ancillary = temp->oclist[d.seq].ancillary,
  dcp = temp->oclist[d.seq].dcp, desc = temp->oclist[d.seq].desc, othername1 = temp->oclist[d.seq].
  othername1,
  othername2 = temp->oclist[d.seq].othername2, othername3 = temp->oclist[d.seq].othername3,
  othername4 = temp->oclist[d.seq].othername4,
  othername5 = temp->oclist[d.seq].othername5
  FROM (dummyt d  WITH seq = cnt)
  HEAD REPORT
   line = concat("catalog_cd,catalog_type,activity_type,subactivity_type,",
    "primary,ancillary,dcp,desc,othername1,othername2,othername3,","othername4,othername5"), col 0,
   line,
   line = ""
  DETAIL
   IF ((temp->oclist[d.seq].catalog_type <= ""))
    temp->oclist[d.seq].catalog_type = "."
   ENDIF
   IF ((temp->oclist[d.seq].activity_type <= ""))
    temp->oclist[d.seq].activity_type = "."
   ENDIF
   IF ((temp->oclist[d.seq].subactivity_type <= ""))
    temp->oclist[d.seq].subactivity_type = "."
   ENDIF
   IF ((temp->oclist[d.seq].primary <= ""))
    temp->oclist[d.seq].primary = "."
   ENDIF
   IF ((temp->oclist[d.seq].ancillary <= ""))
    temp->oclist[d.seq].ancillary = "."
   ENDIF
   IF ((temp->oclist[d.seq].dcp <= ""))
    temp->oclist[d.seq].dcp = "."
   ENDIF
   IF ((temp->oclist[d.seq].desc <= ""))
    temp->oclist[d.seq].desc = "."
   ENDIF
   IF ((temp->oclist[d.seq].othername1 <= ""))
    temp->oclist[d.seq].othername1 = "."
   ENDIF
   IF ((temp->oclist[d.seq].othername2 <= ""))
    temp->oclist[d.seq].othername2 = "."
   ENDIF
   IF ((temp->oclist[d.seq].othername3 <= ""))
    temp->oclist[d.seq].othername3 = "."
   ENDIF
   IF ((temp->oclist[d.seq].othername4 <= ""))
    temp->oclist[d.seq].othername4 = "."
   ENDIF
   IF ((temp->oclist[d.seq].othername5 <= ""))
    temp->oclist[d.seq].othername5 = "."
   ENDIF
   row + 1, line = concat(line,trim(cnvtstring(temp->oclist[d.seq].catalog_cd)),","), line = concat(
    line,trim(temp->oclist[d.seq].catalog_type),","),
   line = concat(line,trim(temp->oclist[d.seq].activity_type),","), line = concat(line,trim(temp->
     oclist[d.seq].subactivity_type),","), line = concat(line,trim(temp->oclist[d.seq].primary),","),
   line = concat(line,trim(temp->oclist[d.seq].ancillary),","), line = concat(line,trim(temp->oclist[
     d.seq].dcp),","), line = concat(line,trim(temp->oclist[d.seq].desc),","),
   line = concat(line,trim(temp->oclist[d.seq].othername1),","), line = concat(line,trim(temp->
     oclist[d.seq].othername2),","), line = concat(line,trim(temp->oclist[d.seq].othername3),","),
   line = concat(line,trim(temp->oclist[d.seq].othername4),","), line = concat(line,trim(temp->
     oclist[d.seq].othername5)), col 0,
   line, line = ""
  WITH nocounter, format = variable, maxcol = 1999,
   noformfeed, maxrow = 1
 ;end select
END GO
