CREATE PROGRAM ams_rpt_expl_menu_search:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Search By:" = "NAME",
  "Search String" = "",
  "Full Audit" = 0
  WITH outdev, option, obj_name,
  full
 DECLARE iworktodo = i2 WITH protect, noconstant(0)
 DECLARE sstripstring = vc WITH protect, noconstant(trim(replace( $OBJ_NAME,"*",""),3))
 DECLARE ssearchstring = vc WITH protect, noconstant(cnvtupper(concat("*",trim(sstripstring,3),"*")))
 DECLARE sreportprogramname = vc WITH protect, noconstant("")
 FREE RECORD rdata
 RECORD rdata(
   1 qual[*]
     2 path = vc
     2 item_desc = c100
     2 parent_id = f8
     2 prog_name = c100
     2 parent_knt = i4
     2 parents[*]
       3 parent_id = f8
       3 parent_desc = c100
 )
 IF (textlen(trim(sstripstring,3)) < 1)
  SELECT INTO value( $OUTDEV)
   FROM (dummyt d  WITH seq = 1)
   PLAN (d)
   HEAD REPORT
    stemp = concat("Search String: ", $OBJ_NAME), col 10, "Invalid Search String",
    row + 1, col 10, stemp,
    row + 1, col 10, "Search String Can Not Be Blank or Only Contain *",
    row + 1
   WITH nocounter, nullreport, nolandscape,
    maxrow = 61, maxcol = 1000
  ;end select
  GO TO exit_script
 ENDIF
 SELECT
  IF (( $OPTION="NAME"))
   PLAN (em
    WHERE em.active_ind=1
     AND operator(cnvtupper(em.item_desc),"LIKE",patstring(ssearchstring,1))
     AND em.item_type="P")
  ELSE
  ENDIF
  INTO "nl:"
  object_name = em.item_name, em.menu_id, em.menu_parent_id
  FROM explorer_menu em
  PLAN (em
   WHERE em.active_ind=1
    AND operator(cnvtupper(em.item_name),"LIKE",patstring(ssearchstring,1))
    AND em.item_type="P")
  ORDER BY em.menu_id
  HEAD REPORT
   knt = 0
  DETAIL
   knt = (knt+ 1), stat = alterlist(rdata->qual,knt), rdata->qual[knt].item_desc = em.item_desc,
   rdata->qual[knt].parent_id = em.menu_parent_id, rdata->qual[knt].prog_name = cnvtupper(em
    .item_name)
   IF (em.menu_parent_id > 0)
    iworktodo = true
   ENDIF
  WITH nocounter
 ;end select
 WHILE (iworktodo)
  SET iworktodo = false
  SELECT
   qual_parent_id = rdata->qual[d1.seq].parent_id, rdata->qual[d1.seq].item_desc, em.item_desc
   FROM (dummyt d1  WITH seq = value(size(rdata->qual,5))),
    explorer_menu em
   PLAN (d1)
    JOIN (em
    WHERE (em.menu_id=rdata->qual[d1.seq].parent_id)
     AND em.active_ind=1)
   ORDER BY d1.seq, em.item_desc
   HEAD REPORT
    knt = 0, iworktodo = 0
   HEAD d1.seq
    knt = rdata->qual[d1.seq].parent_knt
   DETAIL
    knt = (knt+ 1)
    IF (knt > size(rdata->qual[d1.seq].parents,5))
     stat = alterlist(rdata->qual[d1.seq].parents,(knt+ 5))
    ENDIF
    IF (textlen(trim(rdata->qual[d1.seq].path,3)) > 0)
     rdata->qual[d1.seq].path = concat(trim(em.item_desc)," > ",trim(rdata->qual[d1.seq].path))
    ELSE
     rdata->qual[d1.seq].path = trim(em.item_desc)
    ENDIF
    rdata->qual[d1.seq].parents[knt].parent_desc = em.item_desc, rdata->qual[d1.seq].parents[knt].
    parent_id = em.menu_id, rdata->qual[d1.seq].parent_id = em.menu_parent_id
    IF (em.menu_parent_id > 0)
     iworktodo = true
    ENDIF
   FOOT  d1.seq
    rdata->qual[d1.seq].parent_knt = knt, stat = alterlist(rdata->qual[d1.seq].parents,knt)
   WITH nocounter
  ;end select
 ENDWHILE
 SELECT
  IF ( $FULL)
   top_folder = trim(substring(1,100,rdata->qual[d1.seq].parents[rdata->qual[d1.seq].parent_knt].
     parent_desc),3), report_name = trim(substring(1,100,rdata->qual[d1.seq].item_desc),3),
   program_name = trim(substring(1,100,rdata->qual[d1.seq].prog_name),3),
   path =
   IF (trim(rdata->qual[d1.seq].path)=trim(rdata->qual[d1.seq].parents[rdata->qual[d1.seq].parent_knt
    ].parent_desc,3)) ""
   ELSE rdata->qual[d1.seq].path
   ENDIF
   ORDER BY top_folder, path, program_name,
    0
   WITH nocounter, separator = " ", format,
    skipreport = 1
  ELSE
  ENDIF
  INTO value( $OUTDEV)
  d1.seq, d2.seq, qual_item_desc = trim(substring(1,100,rdata->qual[d1.seq].item_desc),3),
  parents_parent_desc = rdata->qual[d1.seq].parents[d2.seq].parent_desc
  FROM (dummyt d1  WITH seq = value(size(rdata->qual,5))),
   (dummyt d2  WITH seq = 1)
  PLAN (d1
   WHERE maxrec(d2,size(rdata->qual[d1.seq].parents,5)))
   JOIN (d2)
  ORDER BY d1.seq, d2.seq DESC
  HEAD REPORT
   col 0, "{PS/792 0 translate 90 rotate/}{F/8}{CPI/10}", row + 1,
   c1 = 25, y_pos = 25, y_off = 15,
   indnt = 17
  HEAD d1.seq
   IF (y_pos > 500)
    row + 1,
    CALL print(calcpos(c1,y_pos)), "Continued on next page....",
    BREAK
   ENDIF
   row + 1,
   CALL print(calcpos(c1,y_pos)), rdata->qual[d1.seq].parents[d2.seq].parent_desc,
   c1 = (c1+ indnt), y_pos = (y_pos+ y_off)
  HEAD d2.seq
   IF (y_pos > 550)
    row + 1,
    CALL print(calcpos(c1,y_pos)), "Continued on next page....",
    BREAK
   ENDIF
   IF (d2.seq > 1)
    row + 1,
    CALL print(calcpos(c1,y_pos)), "-> ",
    rdata->qual[d1.seq].parents[d2.seq].parent_desc
   ELSE
    sreportprogramname = concat("-> ",trim(rdata->qual[d1.seq].item_desc,3)," (",trim(rdata->qual[d1
      .seq].prog_name,3),")"), row + 1,
    CALL print(calcpos(c1,y_pos)),
    sreportprogramname
   ENDIF
   c1 = (c1+ indnt), y_pos = (y_pos+ y_off)
  FOOT  d1.seq
   c1 = 25, y_pos = (y_pos+ 24)
  WITH nocounter, separator = " ", format,
   maxcol = 1000, dio = 8
 ;end select
#exit_script
 SET script_ver = "000 10/16/13 Initial Release"
END GO
