CREATE PROGRAM cva_get_inbound_tree:dba
 RECORD reply(
   1 qual[*]
     2 inner_qual[*]
       3 level = i4
       3 parent_loc_cd = f8
       3 location_cd = f8
       3 display = c40
       3 description = c60
       3 cdf_meaning = c12
       3 sequence = i4
       3 rel_status_ind = i2
       3 loc_status_ind = i2
       3 qual[*]
         4 alias = vc
         4 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE deleted = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"DELETED"))
 DECLARE outidx = i4 WITH noconstant(1)
 DECLARE outcnt = i4 WITH noconstant(0)
 DECLARE inidx = i4 WITH noconstant(1)
 DECLARE allocate = i4 WITH noconstant(0)
 DECLARE aliascnt = i4 WITH noconstant(0)
 DECLARE num = i4 WITH noconstant(0)
 DECLARE nstart = i4 WITH noconstant(1)
 DECLARE ntotal = i4 WITH noconstant(0)
 DECLARE lg1query = vc WITH noconstant("0=0")
 DECLARE cv1query = vc WITH noconstant("0=0")
 DECLARE lg2query = vc WITH noconstant("0=0")
 DECLARE cv2query = vc WITH noconstant("0=0")
 DECLARE lg3query = vc WITH noconstant("0=0")
 DECLARE cv3query = vc WITH noconstant("0=0")
 DECLARE lg4query = vc WITH noconstant("0=0")
 DECLARE cv4query = vc WITH noconstant("0=0")
 DECLARE lg5query = vc WITH noconstant("0=0")
 DECLARE cv5query = vc WITH noconstant("0=0")
 DECLARE lg6query = vc WITH noconstant("0=0")
 DECLARE cv6query = vc WITH noconstant("0=0")
 DECLARE lg7query = vc WITH noconstant("0=0")
 DECLARE cv7query = vc WITH noconstant("0=0")
 DECLARE lg8query = vc WITH noconstant("0=0")
 DECLARE cv8query = vc WITH noconstant("0=0")
 IF ((request->get_all_flag=0))
  SET lg1query = build(" lg1.active_ind = 1",
   " and lg1.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)",
   " and lg1.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)")
  SET cv1query = build(" cv1.active_ind = (1)",
   " and cv1.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)",
   " and cv1.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)")
  SET lg2query = build(" lg2.active_ind = (1)",
   " and lg2.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)",
   " and lg2.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)")
  SET cv2query = build(" cv2.active_ind = (1)",
   " and cv2.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)",
   " and cv2.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)")
  SET lg3query = build(" lg3.active_ind = (1)",
   " and lg3.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)",
   " and lg3.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)")
  SET cv3query = build(" cv3.active_ind = (1)",
   " and cv3.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)",
   " and cv3.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)")
  SET lg4query = build(" lg4.active_ind = (1)",
   " and lg4.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)",
   " and lg4.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)")
  SET cv4query = build(" cv4.active_ind = (1)",
   " and cv4.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)",
   " and cv4.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)")
  SET lg5query = build(" lg5.active_ind = (1)",
   " and lg5.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)",
   " and lg5.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)")
  SET cv5query = build(" cv5.active_ind = (1)",
   " and cv5.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)",
   " and cv5.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)")
  SET lg6query = build(" lg6.active_ind = (1)",
   " and lg6.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)",
   " and lg6.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)")
  SET cv6query = build(" cv6.active_ind = (1)",
   " and cv6.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)",
   " and cv6.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)")
  SET lg7query = build(" lg7.active_ind = (1)",
   " and lg7.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)",
   " and lg7.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)")
  SET cv7query = build(" cv7.active_ind = (1)",
   " and cv7.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)",
   " and cv7.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)")
  SET lg8query = build(" lg8.active_ind = (1)",
   " and lg8.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)",
   " and lg8.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)")
  SET cv8query = build(" cv8.active_ind = (1)",
   " and cv8.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)",
   " and cv8.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)")
 ENDIF
 SELECT
  IF ((request->get_all_flag=0))
   FROM code_value c
   WHERE (c.code_value=request->qual[1].location_cd)
    AND c.active_type_cd != deleted
    AND c.active_ind=1
    AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
    AND c.end_effective_dt_tm >= cnvtdatetime(sysdate)
  ELSE
   FROM code_value c
   WHERE (c.code_value=request->qual[1].location_cd)
    AND c.active_type_cd != deleted
  ENDIF
  INTO "nl:"
  c.code_value
  DETAIL
   stat = alterlist(reply->qual,outidx), stat = alterlist(reply->qual[outidx].inner_qual,inidx),
   reply->qual[outidx].inner_qual[inidx].location_cd = c.code_value,
   reply->qual[outidx].inner_qual[inidx].display = c.display, reply->qual[outidx].inner_qual[inidx].
   description = c.description, reply->qual[outidx].inner_qual[inidx].cdf_meaning = c.cdf_meaning,
   reply->qual[outidx].inner_qual[inidx].parent_loc_cd = 0, reply->qual[outidx].inner_qual[inidx].
   level = 0
   IF (c.active_ind=1
    AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
    AND c.end_effective_dt_tm >= cnvtdatetime(sysdate))
    reply->qual[outidx].inner_qual[inidx].loc_status_ind = 1
   ELSE
    reply->qual[outidx].inner_qual[inidx].loc_status_ind = 0
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  IF (size(reply->qual,5) > 0)
   SELECT INTO "nl: "
    FROM location_group lg1,
     code_value cv1,
     location_group lg2,
     code_value cv2,
     location_group lg3,
     code_value cv3,
     location_group lg4,
     code_value cv4,
     location_group lg5,
     code_value cv5,
     location_group lg6,
     code_value cv6,
     location_group lg7,
     code_value cv7,
     location_group lg8,
     code_value cv8,
     dummyt d1,
     dummyt d2,
     dummyt d3,
     dummyt d4,
     dummyt d5,
     dummyt d6,
     dummyt d7
    PLAN (lg1
     WHERE (lg1.parent_loc_cd=request->qual[1].location_cd)
      AND (lg1.root_loc_cd=request->root_loc_cd)
      AND lg1.active_status_cd != deleted
      AND parser(lg1query))
     JOIN (cv1
     WHERE cv1.code_value=lg1.child_loc_cd
      AND cv1.active_type_cd != deleted
      AND parser(cv1query))
     JOIN (d1)
     JOIN (lg2
     WHERE lg2.parent_loc_cd=lg1.child_loc_cd
      AND (lg2.root_loc_cd=request->root_loc_cd)
      AND lg2.active_status_cd != deleted
      AND parser(lg2query))
     JOIN (cv2
     WHERE cv2.code_value=lg2.child_loc_cd
      AND cv2.active_type_cd != deleted
      AND parser(cv2query))
     JOIN (d2)
     JOIN (lg3
     WHERE lg3.parent_loc_cd=lg2.child_loc_cd
      AND (lg3.root_loc_cd=request->root_loc_cd)
      AND lg3.active_status_cd != deleted
      AND parser(lg3query))
     JOIN (cv3
     WHERE cv3.code_value=lg3.child_loc_cd
      AND cv3.active_type_cd != deleted
      AND parser(cv3query))
     JOIN (d3)
     JOIN (lg4
     WHERE lg4.parent_loc_cd=lg3.child_loc_cd
      AND (lg4.root_loc_cd=request->root_loc_cd)
      AND lg4.active_status_cd != deleted
      AND parser(lg4query))
     JOIN (cv4
     WHERE cv4.code_value=lg4.child_loc_cd
      AND cv4.active_type_cd != deleted
      AND parser(cv4query))
     JOIN (d4)
     JOIN (lg5
     WHERE lg5.parent_loc_cd=lg4.child_loc_cd
      AND (lg5.root_loc_cd=request->root_loc_cd)
      AND lg5.active_status_cd != deleted
      AND parser(lg5query))
     JOIN (cv5
     WHERE cv5.code_value=lg5.child_loc_cd
      AND cv5.active_type_cd != deleted
      AND parser(cv5query))
     JOIN (d5)
     JOIN (lg6
     WHERE lg6.parent_loc_cd=lg5.child_loc_cd
      AND (lg6.root_loc_cd=request->root_loc_cd)
      AND lg6.active_status_cd != deleted
      AND parser(lg6query))
     JOIN (cv6
     WHERE cv6.code_value=lg6.child_loc_cd
      AND cv6.active_type_cd != deleted
      AND parser(cv6query))
     JOIN (d6)
     JOIN (lg7
     WHERE lg7.parent_loc_cd=lg6.child_loc_cd
      AND (lg7.root_loc_cd=request->root_loc_cd)
      AND lg7.active_status_cd != deleted
      AND parser(lg7query))
     JOIN (cv7
     WHERE cv7.code_value=lg7.child_loc_cd
      AND cv7.active_type_cd != deleted
      AND parser(cv7query))
     JOIN (d7)
     JOIN (lg8
     WHERE lg8.parent_loc_cd=lg7.child_loc_cd
      AND (lg8.root_loc_cd=request->root_loc_cd)
      AND lg8.active_status_cd != deleted
      AND parser(lg8query))
     JOIN (cv8
     WHERE cv8.code_value=lg8.child_loc_cd
      AND cv8.active_type_cd != deleted
      AND parser(cv8query))
    ORDER BY lg1.child_loc_cd, lg2.child_loc_cd, lg3.child_loc_cd,
     lg4.child_loc_cd, lg5.child_loc_cd, lg6.child_loc_cd,
     lg7.child_loc_cd, lg8.child_loc_cd
    HEAD lg1.child_loc_cd
     IF (lg1.child_loc_cd > 0)
      inidx += 1
      IF (inidx > 64000)
       stat = alterlist(reply->qual[outidx].inner_qual,(inidx - 1)), outidx += 1, stat = alterlist(
        reply->qual,outidx),
       inidx = 1, allocate = 0
      ENDIF
      IF (inidx > allocate)
       allocate += 100, stat = alterlist(reply->qual[outidx].inner_qual,(allocate+ 100))
      ENDIF
      reply->qual[outidx].inner_qual[inidx].level = 1, reply->qual[outidx].inner_qual[inidx].sequence
       = lg1.sequence, reply->qual[outidx].inner_qual[inidx].parent_loc_cd = lg1.parent_loc_cd,
      reply->qual[outidx].inner_qual[inidx].location_cd = lg1.child_loc_cd, reply->qual[outidx].
      inner_qual[inidx].display = cv1.display, reply->qual[outidx].inner_qual[inidx].description =
      cv1.description,
      reply->qual[outidx].inner_qual[inidx].cdf_meaning = cv1.cdf_meaning
      IF (lg1.active_ind=1
       AND lg1.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND lg1.end_effective_dt_tm >= cnvtdatetime(sysdate))
       reply->qual[outidx].inner_qual[inidx].rel_status_ind = 1
      ELSE
       reply->qual[outidx].inner_qual[inidx].rel_status_ind = 0
      ENDIF
      IF (cv1.active_ind=1
       AND cv1.begin_effective_dt_tm <= cnvtdatetime(sysdate)
       AND cv1.end_effective_dt_tm >= cnvtdatetime(sysdate))
       reply->qual[outidx].inner_qual[inidx].loc_status_ind = 1
      ELSE
       reply->qual[outidx].inner_qual[inidx].loc_status_ind = 0
      ENDIF
     ENDIF
    HEAD lg2.child_loc_cd
     IF (lg2.child_loc_cd > 0)
      inidx += 1
      IF (inidx > 64000)
       stat = alterlist(reply->qual[outidx].inner_qual,(inidx - 1)), outidx += 1, stat = alterlist(
        reply->qual,outidx),
       inidx = 1, allocate = 0
      ENDIF
      IF (inidx > allocate)
       allocate += 100, stat = alterlist(reply->qual[outidx].inner_qual,(allocate+ 100))
      ENDIF
      reply->qual[outidx].inner_qual[inidx].level = 2, reply->qual[outidx].inner_qual[inidx].sequence
       = lg2.sequence, reply->qual[outidx].inner_qual[inidx].parent_loc_cd = lg2.parent_loc_cd,
      reply->qual[outidx].inner_qual[inidx].location_cd = lg2.child_loc_cd, reply->qual[outidx].
      inner_qual[inidx].display = cv2.display, reply->qual[outidx].inner_qual[inidx].description =
      cv2.description,
      reply->qual[outidx].inner_qual[inidx].cdf_meaning = cv2.cdf_meaning
      IF (lg2.active_ind=1
       AND lg2.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND lg2.end_effective_dt_tm >= cnvtdatetime(sysdate))
       reply->qual[outidx].inner_qual[inidx].rel_status_ind = 1
      ELSE
       reply->qual[outidx].inner_qual[inidx].rel_status_ind = 0
      ENDIF
      IF (cv2.active_ind=1
       AND cv2.begin_effective_dt_tm <= cnvtdatetime(sysdate)
       AND cv2.end_effective_dt_tm >= cnvtdatetime(sysdate))
       reply->qual[outidx].inner_qual[inidx].loc_status_ind = 1
      ELSE
       reply->qual[outidx].inner_qual[inidx].loc_status_ind = 0
      ENDIF
     ENDIF
    HEAD lg3.child_loc_cd
     IF (lg3.child_loc_cd > 0)
      inidx += 1
      IF (inidx > 64000)
       stat = alterlist(reply->qual[outidx].inner_qual,(inidx - 1)), outidx += 1, stat = alterlist(
        reply->qual,outidx),
       inidx = 1, allocate = 0
      ENDIF
      IF (inidx > allocate)
       allocate += 100, stat = alterlist(reply->qual[outidx].inner_qual,(allocate+ 100))
      ENDIF
      reply->qual[outidx].inner_qual[inidx].level = 3, reply->qual[outidx].inner_qual[inidx].sequence
       = lg3.sequence, reply->qual[outidx].inner_qual[inidx].parent_loc_cd = lg3.parent_loc_cd,
      reply->qual[outidx].inner_qual[inidx].location_cd = lg3.child_loc_cd, reply->qual[outidx].
      inner_qual[inidx].display = cv3.display, reply->qual[outidx].inner_qual[inidx].description =
      cv3.description,
      reply->qual[outidx].inner_qual[inidx].cdf_meaning = cv3.cdf_meaning
      IF (lg3.active_ind=1
       AND lg3.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND lg3.end_effective_dt_tm >= cnvtdatetime(sysdate))
       reply->qual[outidx].inner_qual[inidx].rel_status_ind = 1
      ELSE
       reply->qual[outidx].inner_qual[inidx].rel_status_ind = 0
      ENDIF
      IF (cv3.active_ind=1
       AND cv3.begin_effective_dt_tm <= cnvtdatetime(sysdate)
       AND cv3.end_effective_dt_tm >= cnvtdatetime(sysdate))
       reply->qual[outidx].inner_qual[inidx].loc_status_ind = 1
      ELSE
       reply->qual[outidx].inner_qual[inidx].loc_status_ind = 0
      ENDIF
     ENDIF
    HEAD lg4.child_loc_cd
     IF (lg4.child_loc_cd > 0)
      inidx += 1
      IF (inidx > 64000)
       stat = alterlist(reply->qual[outidx].inner_qual,(inidx - 1)), outidx += 1, stat = alterlist(
        reply->qual,outidx),
       inidx = 1, allocate = 0
      ENDIF
      IF (inidx > allocate)
       allocate += 100, stat = alterlist(reply->qual[outidx].inner_qual,(allocate+ 100))
      ENDIF
      reply->qual[outidx].inner_qual[inidx].level = 4, reply->qual[outidx].inner_qual[inidx].sequence
       = lg4.sequence, reply->qual[outidx].inner_qual[inidx].parent_loc_cd = lg4.parent_loc_cd,
      reply->qual[outidx].inner_qual[inidx].location_cd = lg4.child_loc_cd, reply->qual[outidx].
      inner_qual[inidx].display = cv4.display, reply->qual[outidx].inner_qual[inidx].description =
      cv4.description,
      reply->qual[outidx].inner_qual[inidx].cdf_meaning = cv4.cdf_meaning
      IF (lg4.active_ind=1
       AND lg4.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND lg4.end_effective_dt_tm >= cnvtdatetime(sysdate))
       reply->qual[outidx].inner_qual[inidx].rel_status_ind = 1
      ELSE
       reply->qual[outidx].inner_qual[inidx].rel_status_ind = 0
      ENDIF
      IF (cv4.active_ind=1
       AND cv4.begin_effective_dt_tm <= cnvtdatetime(sysdate)
       AND cv4.end_effective_dt_tm >= cnvtdatetime(sysdate))
       reply->qual[outidx].inner_qual[inidx].loc_status_ind = 1
      ELSE
       reply->qual[outidx].inner_qual[inidx].loc_status_ind = 0
      ENDIF
     ENDIF
    HEAD lg5.child_loc_cd
     IF (lg5.child_loc_cd > 0)
      inidx += 1
      IF (inidx > 64000)
       stat = alterlist(reply->qual[outidx].inner_qual,(inidx - 1)), outidx += 1, stat = alterlist(
        reply->qual,outidx),
       inidx = 1, allocate = 0
      ENDIF
      IF (inidx > allocate)
       allocate += 100, stat = alterlist(reply->qual[outidx].inner_qual,(allocate+ 100))
      ENDIF
      reply->qual[outidx].inner_qual[inidx].level = 5, reply->qual[outidx].inner_qual[inidx].sequence
       = lg5.sequence, reply->qual[outidx].inner_qual[inidx].parent_loc_cd = lg5.parent_loc_cd,
      reply->qual[outidx].inner_qual[inidx].location_cd = lg5.child_loc_cd, reply->qual[outidx].
      inner_qual[inidx].display = cv5.display, reply->qual[outidx].inner_qual[inidx].description =
      cv5.description,
      reply->qual[outidx].inner_qual[inidx].cdf_meaning = cv5.cdf_meaning
      IF (lg5.active_ind=1
       AND lg5.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND lg5.end_effective_dt_tm >= cnvtdatetime(sysdate))
       reply->qual[outidx].inner_qual[inidx].rel_status_ind = 1
      ELSE
       reply->qual[outidx].inner_qual[inidx].rel_status_ind = 0
      ENDIF
      IF (cv5.active_ind=1
       AND cv5.begin_effective_dt_tm <= cnvtdatetime(sysdate)
       AND cv5.end_effective_dt_tm >= cnvtdatetime(sysdate))
       reply->qual[outidx].inner_qual[inidx].loc_status_ind = 1
      ELSE
       reply->qual[outidx].inner_qual[inidx].loc_status_ind = 0
      ENDIF
     ENDIF
    HEAD lg6.child_loc_cd
     IF (lg6.child_loc_cd > 0)
      inidx += 1
      IF (inidx > 64000)
       stat = alterlist(reply->qual[outidx].inner_qual,(inidx - 1)), outidx += 1, stat = alterlist(
        reply->qual,outidx),
       inidx = 1, allocate = 0
      ENDIF
      IF (inidx > allocate)
       allocate += 100, stat = alterlist(reply->qual[outidx].inner_qual,(allocate+ 100))
      ENDIF
      reply->qual[outidx].inner_qual[inidx].level = 6, reply->qual[outidx].inner_qual[inidx].sequence
       = lg6.sequence, reply->qual[outidx].inner_qual[inidx].parent_loc_cd = lg6.parent_loc_cd,
      reply->qual[outidx].inner_qual[inidx].location_cd = lg6.child_loc_cd, reply->qual[outidx].
      inner_qual[inidx].display = cv6.display, reply->qual[outidx].inner_qual[inidx].description =
      cv6.description,
      reply->qual[outidx].inner_qual[inidx].cdf_meaning = cv6.cdf_meaning
      IF (lg6.active_ind=1
       AND lg6.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND lg6.end_effective_dt_tm >= cnvtdatetime(sysdate))
       reply->qual[outidx].inner_qual[inidx].rel_status_ind = 1
      ELSE
       reply->qual[outidx].inner_qual[inidx].rel_status_ind = 0
      ENDIF
      IF (cv6.active_ind=1
       AND cv6.begin_effective_dt_tm <= cnvtdatetime(sysdate)
       AND cv6.end_effective_dt_tm >= cnvtdatetime(sysdate))
       reply->qual[outidx].inner_qual[inidx].loc_status_ind = 1
      ELSE
       reply->qual[outidx].inner_qual[inidx].loc_status_ind = 0
      ENDIF
     ENDIF
    HEAD lg7.child_loc_cd
     IF (lg7.child_loc_cd > 0)
      inidx += 1
      IF (inidx > 64000)
       stat = alterlist(reply->qual[outidx].inner_qual,(inidx - 1)), outidx += 1, stat = alterlist(
        reply->qual,outidx),
       inidx = 1, allocate = 0
      ENDIF
      IF (inidx > allocate)
       allocate += 100, stat = alterlist(reply->qual[outidx].inner_qual,(allocate+ 100))
      ENDIF
      reply->qual[outidx].inner_qual[inidx].level = 7, reply->qual[outidx].inner_qual[inidx].sequence
       = lg7.sequence, reply->qual[outidx].inner_qual[inidx].parent_loc_cd = lg7.parent_loc_cd,
      reply->qual[outidx].inner_qual[inidx].location_cd = lg7.child_loc_cd, reply->qual[outidx].
      inner_qual[inidx].display = cv7.display, reply->qual[outidx].inner_qual[inidx].description =
      cv7.description,
      reply->qual[outidx].inner_qual[inidx].cdf_meaning = cv7.cdf_meaning
      IF (lg7.active_ind=1
       AND lg7.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND lg7.end_effective_dt_tm >= cnvtdatetime(sysdate))
       reply->qual[outidx].inner_qual[inidx].rel_status_ind = 1
      ELSE
       reply->qual[outidx].inner_qual[inidx].rel_status_ind = 0
      ENDIF
      IF (cv7.active_ind=1
       AND cv7.begin_effective_dt_tm <= cnvtdatetime(sysdate)
       AND cv7.end_effective_dt_tm >= cnvtdatetime(sysdate))
       reply->qual[outidx].inner_qual[inidx].loc_status_ind = 1
      ELSE
       reply->qual[outidx].inner_qual[inidx].loc_status_ind = 0
      ENDIF
     ENDIF
    HEAD lg8.child_loc_cd
     IF (lg8.child_loc_cd > 0)
      inidx += 1
      IF (inidx > 64000)
       stat = alterlist(reply->qual[outidx].inner_qual,(inidx - 1)), outidx += 1, stat = alterlist(
        reply->qual,outidx),
       inidx = 1, allocate = 0
      ENDIF
      IF (inidx > allocate)
       allocate += 100, stat = alterlist(reply->qual[outidx].inner_qual,(allocate+ 100))
      ENDIF
      reply->qual[outidx].inner_qual[inidx].level = 8, reply->qual[outidx].inner_qual[inidx].sequence
       = lg8.sequence, reply->qual[outidx].inner_qual[inidx].parent_loc_cd = lg8.parent_loc_cd,
      reply->qual[outidx].inner_qual[inidx].location_cd = lg8.child_loc_cd, reply->qual[outidx].
      inner_qual[inidx].display = cv8.display, reply->qual[outidx].inner_qual[inidx].description =
      cv8.description,
      reply->qual[outidx].inner_qual[inidx].cdf_meaning = cv8.cdf_meaning
      IF (lg8.active_ind=1
       AND lg8.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND lg8.end_effective_dt_tm >= cnvtdatetime(sysdate))
       reply->qual[outidx].inner_qual[inidx].rel_status_ind = 1
      ELSE
       reply->qual[outidx].inner_qual[inidx].rel_status_ind = 0
      ENDIF
      IF (cv8.active_ind=1
       AND cv8.begin_effective_dt_tm <= cnvtdatetime(sysdate)
       AND cv8.end_effective_dt_tm >= cnvtdatetime(sysdate))
       reply->qual[outidx].inner_qual[inidx].loc_status_ind = 1
      ELSE
       reply->qual[outidx].inner_qual[inidx].loc_status_ind = 0
      ENDIF
     ENDIF
    WITH nocounter, outerjoin = d1, outerjoin = d2,
     outerjoin = d3, outerjoin = d4, outerjoin = d5,
     outerjoin = d6, outerjoin = d7
   ;end select
   SET stat = alterlist(reply->qual[outidx].inner_qual,inidx)
   SET outcnt = size(reply->qual,5)
   SET outidx = 0
   SET inidx = 0
   WHILE (outidx < outcnt)
     SET outidx += 1
     SET ntotal = size(reply->qual[outidx].inner_qual,5)
     SELECT INTO "nl:"
      cva.alias
      FROM code_value_alias cva
      PLAN (cva
       WHERE expand(num,nstart,ntotal,cva.code_value,reply->qual[outidx].inner_qual[num].location_cd)
        AND (cva.contributor_source_cd=request->contributor_source_cd))
      HEAD cva.code_value
       aliascnt = 0, inidx = locateval(num,nstart,ntotal,cva.code_value,reply->qual[outidx].
        inner_qual[num].location_cd)
      DETAIL
       aliascnt += 1, stat = alterlist(reply->qual[outidx].inner_qual[inidx].qual,aliascnt), reply->
       qual[outidx].inner_qual[inidx].qual[aliascnt].alias = cva.alias,
       reply->qual[outidx].inner_qual[inidx].qual[aliascnt].updt_cnt = cva.updt_cnt
      WITH expand = 1, nocounter
     ;end select
   ENDWHILE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
END GO
