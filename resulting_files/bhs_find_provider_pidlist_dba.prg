CREATE PROGRAM bhs_find_provider_pidlist:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 RECORD groups(
   1 qual[*]
     2 groupnum = i4
     2 group_name = vc
     2 group_full_name = vc
 )
 SET gcnt = 0
 RECORD flatgr(
   1 qual[*]
     2 groupnum = i4
     2 group_name = vc
     2 group_id = f8
     2 group_desc = vc
 )
 SET fcnt = 0
 RECORD person(
   1 qual[*]
     2 person_id = f8
     2 name = vc
     2 prsnl_alias = vc
     2 locationgroupnum = i4
     2 group_id = f8
     2 group_desc = vc
     2 extralocs = vc
     2 group_full_name = vc
     2 labordcnt = i4
     2 labeventcnt = i4
     2 radordcnt = i4
     2 radeventcnt = i4
     2 totlabordcnt = i4
     2 totlabeventcnt = i4
     2 totradordcnt = i4
     2 totradeventcnt = i4
 )
 SET pcnt = 0
 SET stat = alterlist(groups->qual,200)
 SET gcnt = (gcnt+ 1)
 SET groups->qual[gcnt].groupnum = gcnt
 SET groups->qual[gcnt].group_name = "COUNSELGYNGRP"
 SET groups->qual[gcnt].group_full_name = "Counseling & Gynecology Group, P.C."
 SET gcnt = (gcnt+ 1)
 SET groups->qual[gcnt].groupnum = gcnt
 SET groups->qual[gcnt].group_name = "VALLEYMEDASSC"
 SET groups->qual[gcnt].group_full_name = "Valley Medical Associates"
 SET gcnt = (gcnt+ 1)
 SET groups->qual[gcnt].groupnum = gcnt
 SET groups->qual[gcnt].group_name = "PONROBERTAJELLOMD"
 SET groups->qual[gcnt].group_full_name = "Roberto B. Salva-Otero, M.D., LLC"
 SET gcnt = (gcnt+ 1)
 SET groups->qual[gcnt].groupnum = gcnt
 SET groups->qual[gcnt].group_name = "PONRICHARDWARNERMD"
 SET groups->qual[gcnt].group_full_name = "Richard S. Warner, M.D."
 SET gcnt = (gcnt+ 1)
 SET groups->qual[gcnt].groupnum = gcnt
 SET groups->qual[gcnt].group_name = "FRANKLINGASTROENTEROLOGY"
 SET groups->qual[gcnt].group_full_name = "Franklin Gastroenterology PC"
 SET gcnt = (gcnt+ 1)
 SET groups->qual[gcnt].groupnum = gcnt
 SET groups->qual[gcnt].group_name = "ORCHARD MEDICAL ASSOCIATES"
 SET groups->qual[gcnt].group_full_name = "Orchard Medical Associates"
 SET gcnt = (gcnt+ 1)
 SET groups->qual[gcnt].groupnum = gcnt
 SET groups->qual[gcnt].group_name = "REDWOODPEDIADOLMD"
 SET groups->qual[gcnt].group_full_name = "Redwood Pediatric & Adolescent Medicine"
 SET gcnt = (gcnt+ 1)
 SET groups->qual[gcnt].groupnum = gcnt
 SET groups->qual[gcnt].group_name = "PEDIATRICCAREASC"
 SET groups->qual[gcnt].group_full_name = "PediCare Associates"
 SET gcnt = (gcnt+ 1)
 SET groups->qual[gcnt].groupnum = gcnt
 SET groups->qual[gcnt].group_name = "NEWENGORTHOPED"
 SET groups->qual[gcnt].group_full_name = "New England Orthopedic Surgeons"
 SET gcnt = (gcnt+ 1)
 SET groups->qual[gcnt].groupnum = gcnt
 SET groups->qual[gcnt].group_name = "WBROOKFIELDFAM"
 SET groups->qual[gcnt].group_full_name = "West Brookfield Family Practice"
 SET gcnt = (gcnt+ 1)
 SET groups->qual[gcnt].groupnum = gcnt
 SET groups->qual[gcnt].group_name = "HOLYOKEPEDIASSC"
 SET groups->qual[gcnt].group_full_name = "Holyoke Pediatric Associates, LLP"
 SET gcnt = (gcnt+ 1)
 SET groups->qual[gcnt].groupnum = gcnt
 SET groups->qual[gcnt].group_name = "HAMPDENUROLOGYA"
 SET groups->qual[gcnt].group_full_name = "Hampden Urological Associates"
 SET gcnt = (gcnt+ 1)
 SET groups->qual[gcnt].groupnum = gcnt
 SET groups->qual[gcnt].group_name = "PIONEERVALUROLG"
 SET groups->qual[gcnt].group_full_name = "Pioneer Valley Urology"
 SET gcnt = (gcnt+ 1)
 SET groups->qual[gcnt].groupnum = gcnt
 SET groups->qual[gcnt].group_name = "PIONVALCARDCAREW"
 SET groups->qual[gcnt].group_full_name = "Pioneer Valley Cardiology"
 SET gcnt = (gcnt+ 1)
 SET groups->qual[gcnt].groupnum = gcnt
 SET groups->qual[gcnt].group_name = "SUMNERPEDIATRICS*"
 SET groups->qual[gcnt].group_full_name = "Sumner Pediatrics"
 SET gcnt = (gcnt+ 1)
 SET groups->qual[gcnt].groupnum = gcnt
 SET groups->qual[gcnt].group_name = "RIVERBEND*"
 SET groups->qual[gcnt].group_full_name = "RIVERBEND"
 SET gcnt = (gcnt+ 1)
 SET groups->qual[gcnt].groupnum = gcnt
 SET groups->qual[gcnt].group_name = "SPFLDMEDASSC*"
 SET groups->qual[gcnt].group_full_name = "Springfield Medical Associates"
 SET gcnt = (gcnt+ 1)
 SET groups->qual[gcnt].groupnum = gcnt
 SET groups->qual[gcnt].group_name = "SPORTSREHABMED*"
 SET groups->qual[gcnt].group_full_name = "Pioneer Spine and Sports Physician"
 SET gcnt = (gcnt+ 1)
 SET groups->qual[gcnt].groupnum = gcnt
 SET groups->qual[gcnt].group_name = "EARNOSETHROAT"
 SET groups->qual[gcnt].group_full_name = "ENT Surgeons of Western New England"
 SET gcnt = (gcnt+ 1)
 SET groups->qual[gcnt].groupnum = gcnt
 SET groups->qual[gcnt].group_name = "PIONEERVALNEHPR"
 SET groups->qual[gcnt].group_full_name = "Pioneer Valley Nephrology"
 SET gcnt = (gcnt+ 1)
 SET tmpcnt = gcnt
 SET groups->qual[gcnt].groupnum = tmpcnt
 SET groups->qual[gcnt].group_name = "HAMPDENCOMEDGRP"
 SET groups->qual[gcnt].group_full_name = "Hampden County Physician Associates"
 SET gcnt = (gcnt+ 1)
 SET groups->qual[gcnt].groupnum = tmpcnt
 SET groups->qual[gcnt].group_name = "HAMPDENCOPHYSSURGERY"
 SET groups->qual[gcnt].group_full_name = "Hampden County Physician Associates"
 SET gcnt = (gcnt+ 1)
 SET groups->qual[gcnt].groupnum = tmpcnt
 SET groups->qual[gcnt].group_name = "HAMPDENCOUNTYHOSPITALISTS"
 SET groups->qual[gcnt].group_full_name = "Hampden County Physician Associates"
 SET stat = alterlist(groups->qual,gcnt)
 SET fcnt = 0
 SELECT
  *
  FROM prsnl_group p,
   (dummyt d  WITH seq = gcnt)
  PLAN (d)
   JOIN (p
   WHERE operator(p.prsnl_group_name_key,"like",patstring(groups->qual[d.seq].group_name,1)))
  DETAIL
   fcnt = (fcnt+ 1), stat = alterlist(flatgr->qual,fcnt), flatgr->qual[fcnt].groupnum = groups->qual[
   d.seq].groupnum,
   flatgr->qual[fcnt].group_name = p.prsnl_group_name, flatgr->qual[fcnt].group_id = p.prsnl_group_id,
   flatgr->qual[fcnt].group_desc = groups->qual[d.seq].group_name
  WITH nocounter
 ;end select
 SET pcnt = 0
 SELECT INTO "NL:"
  groupnum = flatgr->qual[d.seq].groupnum, p.person_id, p.name_full_formatted,
  pg.prsnl_group_name
  FROM prsnl_group pg,
   prsnl_group_reltn pgr,
   prsnl p,
   (dummyt d  WITH seq = fcnt)
  PLAN (d)
   JOIN (pg
   WHERE (pg.prsnl_group_id=flatgr->qual[d.seq].group_id))
   JOIN (pgr
   WHERE pgr.prsnl_group_id=outerjoin(pg.prsnl_group_id)
    AND pgr.active_ind=outerjoin(1))
   JOIN (p
   WHERE p.person_id=outerjoin(pgr.person_id))
  ORDER BY groupnum, p.person_id
  HEAD REPORT
   stat = 0
  HEAD groupnum
   stat = 0
  HEAD p.person_id
   pcnt = (pcnt+ 1), stat = alterlist(person->qual,pcnt), person->qual[pcnt].name = trim(p
    .name_full_formatted,3),
   person->qual[pcnt].person_id = p.person_id, person->qual[pcnt].locationgroupnum = groupnum, person
   ->qual[pcnt].group_id = pg.prsnl_group_id,
   person->qual[pcnt].group_desc = flatgr->qual[d.seq].group_desc, pos = 0, locnum = 0,
   pos = locateval(locnum,1,size(groups->qual,5),groupnum,groups->qual[locnum].groupnum), person->
   qual[pcnt].group_full_name = groups->qual[pos].group_full_name
  FOOT REPORT
   tempgcnt = 6, pcnt = (pcnt+ 1), stat = alterlist(person->qual,pcnt),
   person->qual[pcnt].name = "Vinagre MD, Jose M", person->qual[pcnt].person_id = 751100, person->
   qual[pcnt].locationgroupnum = tempgcnt,
   person->qual[pcnt].group_id = 0, person->qual[pcnt].group_desc = "Orchard Medical Associates",
   person->qual[pcnt].group_full_name = "Orchard Medical Associates",
   pcnt = (pcnt+ 1), stat = alterlist(person->qual,pcnt), person->qual[pcnt].name =
   "Epstein MD, Kevin G",
   person->qual[pcnt].person_id = 749198, person->qual[pcnt].locationgroupnum = tempgcnt, person->
   qual[pcnt].group_id = 0,
   person->qual[pcnt].group_desc = " Orchard Medical Associates", person->qual[pcnt].group_full_name
    = "Orchard Medical Associates", gcnt = (gcnt+ 1),
   pcnt = (pcnt+ 1), stat = alterlist(person->qual,pcnt), person->qual[pcnt].name =
   "David Chadbourne, MD",
   person->qual[pcnt].person_id = 748915, person->qual[pcnt].locationgroupnum = gcnt, person->qual[
   pcnt].group_id = 0,
   person->qual[pcnt].group_desc = " David Chadbourne, MD", person->qual[pcnt].group_full_name =
   "David Chadbourne, MD", gcnt = (gcnt+ 1),
   pcnt = (pcnt+ 1), stat = alterlist(person->qual,pcnt), person->qual[pcnt].name =
   "James m. Freeman",
   person->qual[pcnt].person_id = 749302, person->qual[pcnt].locationgroupnum = gcnt, person->qual[
   pcnt].group_id = 0,
   person->qual[pcnt].group_desc = "James m. Freeman", person->qual[pcnt].group_full_name =
   "James m. Freeman", gcnt = (gcnt+ 1),
   pcnt = (pcnt+ 1), stat = alterlist(person->qual,pcnt), person->qual[pcnt].name =
   "Robert S. Howe, M.D.",
   person->qual[pcnt].person_id = 749619, person->qual[pcnt].locationgroupnum = gcnt, person->qual[
   pcnt].group_id = 0,
   person->qual[pcnt].group_desc = "Robert S. Howe, M.D.", person->qual[pcnt].group_full_name =
   "Robert S. Howe, M.D.", gcnt = (gcnt+ 1),
   pcnt = (pcnt+ 1), stat = alterlist(person->qual,pcnt), person->qual[pcnt].name =
   "Robert P. Hoffman M.D. PC",
   person->qual[pcnt].person_id = 749602, person->qual[pcnt].locationgroupnum = gcnt, person->qual[
   pcnt].group_id = 0,
   person->qual[pcnt].group_desc = "Robert P. Hoffman M.D. PC", person->qual[pcnt].group_full_name =
   "Robert P. Hoffman M.D. PC", gcnt = (gcnt+ 1),
   pcnt = (pcnt+ 1), stat = alterlist(person->qual,pcnt), person->qual[pcnt].name =
   "Llorens MD, Jose E",
   person->qual[pcnt].person_id = 750016, person->qual[pcnt].locationgroupnum = gcnt, person->qual[
   pcnt].group_id = 0,
   person->qual[pcnt].group_desc = "Llorens MD, Jose E", person->qual[pcnt].group_full_name =
   "Llorens MD, Jose E", gcnt = (gcnt+ 1),
   pcnt = (pcnt+ 1), stat = alterlist(person->qual,pcnt), person->qual[pcnt].name =
   "Gary K. Booth, MD",
   person->qual[pcnt].person_id = 748770, person->qual[pcnt].locationgroupnum = gcnt, person->qual[
   pcnt].group_id = 0,
   person->qual[pcnt].group_desc = "Swift River Medical Associates", person->qual[pcnt].
   group_full_name = "Swift River Medical Associates", pcnt = (pcnt+ 1),
   stat = alterlist(person->qual,pcnt), person->qual[pcnt].name = "Steve Anderson, MD", person->qual[
   pcnt].person_id = 748585,
   person->qual[pcnt].locationgroupnum = gcnt, person->qual[pcnt].group_id = 0, person->qual[pcnt].
   group_desc = "Swift River Medical Associates",
   person->qual[pcnt].group_full_name = "Swift River Medical Associates"
  WITH format, separator = " "
 ;end select
 DECLARE templist = vc WITH noconstant(" ")
 SELECT INTO "NL:"
  pgr.person_id, group = person->qual[d.seq].group_id, pg.prsnl_group_name,
  b.name
  FROM prsnl_group_reltn pgr,
   prsnl_group pg,
   (dummyt d  WITH seq = pcnt)
  PLAN (d)
   JOIN (pgr
   WHERE (pgr.person_id=person->qual[d.seq].person_id)
    AND cnvtdatetime(curdate,curtime) BETWEEN pgr.beg_effective_dt_tm AND pgr.end_effective_dt_tm
    AND pgr.active_ind=1)
   JOIN (pg
   WHERE pg.prsnl_group_id=pgr.prsnl_group_id
    AND pg.active_ind=1
    AND cnvtdatetime(curdate,curtime) BETWEEN pg.beg_effective_dt_tm AND pg.end_effective_dt_tm)
  ORDER BY pgr.person_id
  HEAD pgr.person_id
   stat = 0, templist = ""
  DETAIL
   pos = 0, locnum = 0, pos = locateval(locnum,1,size(flatgr->qual,5),pgr.prsnl_group_id,flatgr->
    qual[locnum].group_id)
   IF (pos <= 0)
    IF (textlen(trim(templist,3)) <= 0)
     templist = concat(pg.prsnl_group_name)
    ELSE
     templist = concat(templist," / ",pg.prsnl_group_name)
    ENDIF
   ENDIF
  FOOT  pgr.person_id
   pos = 0, locnum = 0, pos = locateval(locnum,1,size(person->qual,5),pgr.person_id,person->qual[
    locnum].person_id)
   IF (pos > 0)
    person->qual[pos].extralocs = templist
   ENDIF
  WITH format, separator = " "
 ;end select
 SELECT INTO  $OUTDEV
  location = substring(1,50,person->qual[d.seq].group_full_name), name = substring(1,50,person->qual[
   d.seq].name), alias = pa.alias,
  pid = person->qual[d.seq].person_id, p.name_full_formatted, otherlocations = substring(1,100,person
   ->qual[d.seq].extralocs),
  morethenonelocation =
  IF ((person->qual[d.seq].extralocs > " ")) 1
  ELSE 0
  ENDIF
  FROM (dummyt d  WITH seq = pcnt),
   prsnl_alias pa,
   dummyt d1,
   prsnl p
  PLAN (d)
   JOIN (d1)
   JOIN (pa
   WHERE (pa.person_id=person->qual[d.seq].person_id)
    AND pa.prsnl_alias_type_cd=1086.00
    AND cnvtdatetime(curdate,curtime) >= pa.beg_effective_dt_tm
    AND cnvtdatetime(curdate,curtime) <= pa.end_effective_dt_tm
    AND  NOT (cnvtupper(pa.alias) IN ("PN*", "EN*"))
    AND pa.active_ind=1)
   JOIN (p
   WHERE p.person_id=pa.person_id)
  ORDER BY morethenonelocation DESC, location, name
  WITH format, separator = " ", outerjoin = d1
 ;end select
END GO
