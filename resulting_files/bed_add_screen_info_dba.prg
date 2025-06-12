CREATE PROGRAM bed_add_screen_info:dba
 DECLARE screen_display = vc
 DECLARE screen_type = vc
 DECLARE screen_position = i4
 SET data_type_id = 35058
 FREE SET temp
 RECORD temp(
   1 qual[*]
     2 disp = vc
     2 pos = i4
 )
 FOR (x = 1 TO 6)
  IF (x=1)
   SET screen_type = "EXACTMATCH"
   SET stat = alterlist(temp->qual,3)
   SET temp->qual[1].disp = "Display"
   SET temp->qual[1].pos = 1
   SET temp->qual[2].disp = "Description"
   SET temp->qual[2].pos = 2
   SET temp->qual[3].disp = "Millennium Name (Primary Synonym)"
   SET temp->qual[3].pos = 3
  ELSEIF (x=2)
   SET screen_type = "REVIEWMATCHES"
   SET stat = alterlist(temp->qual,2)
   SET temp->qual[1].disp = "Display"
   SET temp->qual[1].pos = 1
   SET temp->qual[2].disp = "Millennium Name (Primary Synonym)"
   SET temp->qual[2].pos = 2
  ELSEIF (x=3)
   SET screen_type = "ONETOONE"
   SET stat = alterlist(temp->qual,5)
   SET temp->qual[1].disp = "Display"
   SET temp->qual[1].pos = 1
   SET temp->qual[2].disp = "Description"
   SET temp->qual[2].pos = 2
   SET temp->qual[3].disp = "Catalog Type"
   SET temp->qual[3].pos = 3
   SET temp->qual[4].disp = "Match Type"
   SET temp->qual[4].pos = 4
   SET temp->qual[5].disp = "Match Value"
   SET temp->qual[5].pos = 5
  ELSEIF (x=4)
   SET screen_type = "ONETOMANY"
   SET stat = alterlist(temp->qual,5)
   SET temp->qual[1].disp = "Display"
   SET temp->qual[1].pos = 1
   SET temp->qual[2].disp = "Description"
   SET temp->qual[2].pos = 2
   SET temp->qual[3].disp = "Catalog Type"
   SET temp->qual[3].pos = 3
   SET temp->qual[4].disp = "Match Type"
   SET temp->qual[4].pos = 4
   SET temp->qual[5].disp = "Match Value"
   SET temp->qual[5].pos = 5
  ELSEIF (x=5)
   SET screen_type = "MANUALITEMS"
   SET stat = alterlist(temp->qual,2)
   SET temp->qual[1].disp = "Display"
   SET temp->qual[1].pos = 1
   SET temp->qual[2].disp = "Description"
   SET temp->qual[2].pos = 2
  ELSEIF (x=6)
   SET screen_type = "MANUALMATCHES"
   SET stat = alterlist(temp->qual,1)
   SET temp->qual[1].disp = "Millennium Name (Primary Synonym)"
   SET temp->qual[1].pos = 1
  ENDIF
  INSERT  FROM br_cki_screen_info b,
    (dummyt d  WITH seq = value(size(temp->qual,5)))
   SET b.data_type_id = data_type_id, b.screen_type = screen_type, b.screen_position = temp->qual[d
    .seq].pos,
    b.screen_display = temp->qual[d.seq].disp
   PLAN (d)
    JOIN (b)
   WITH nocounter
  ;end insert
 ENDFOR
END GO
