CREATE PROGRAM aps_get_signature_line:dba
 IF ((request->called_ind != "Y"))
  RECORD reply(
    1 signature_line = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET building_signature_line = fillstring(3500," ")
 SET first_line_num = 1
 SELECT INTO "nl:"
  line_num = request->row_qual[d1.seq].line_num, row_qual = d1.seq, col_qual = d2.seq,
  position = request->row_qual[d1.seq].col_qual[d2.seq].position, value = request->row_qual[d1.seq].
  col_qual[d2.seq].value, max_size = request->row_qual[d1.seq].col_qual[d2.seq].max_size,
  literal_size = request->row_qual[d1.seq].col_qual[d2.seq].literal_size, literal_display = request->
  row_qual[d1.seq].col_qual[d2.seq].literal_display
  FROM (dummyt d1  WITH seq = value(size(request->row_qual,5))),
   (dummyt d2  WITH seq = value(request->max_cols))
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(request->row_qual[d1.seq].col_qual,5))
  ORDER BY line_num, col_qual
  HEAD REPORT
   chars_moved = 0, last_line_num = 0, piece_of_line = fillstring(3500," "),
   line_qual = fillstring(3500," ")
   FOR (loop = 1 TO value(size(request->row_qual,5)))
     IF ((request->row_qual[loop].line_num > last_line_num))
      last_line_num = request->row_qual[loop].line_num
     ENDIF
   ENDFOR
   first_pass = "Y"
  HEAD line_num
   IF (first_pass="Y")
    IF (line_num > 1)
     FOR (blank_line = 1 TO (request->row_qual[d1.seq].line_num - 1))
       building_signature_line = build(building_signature_line,line_qual,char(13),char(10))
     ENDFOR
    ENDIF
    first_pass = "N"
   ENDIF
   IF (d1.seq > 1)
    prev_line_num = request->row_qual[(d1.seq - 1)].line_num
   ENDIF
  HEAD col_qual
   IF ((request->row_qual[d1.seq].col_qual[col_qual].position > 0))
    literal_length = textlen(trim(request->row_qual[d1.seq].col_qual[col_qual].literal_display)),
    piece_of_line = substring(1,(request->row_qual[d1.seq].col_qual[col_qual].literal_size+
     literal_length),request->row_qual[d1.seq].col_qual[col_qual].literal_display)
    IF (piece_of_line > " ")
     beginning_pos = ((request->row_qual[d1.seq].col_qual[col_qual].literal_size+ literal_length)+
     request->row_qual[d1.seq].col_qual[col_qual].position), chars_moved = movestring(piece_of_line,1,
      line_qual,request->row_qual[d1.seq].col_qual[col_qual].position,textlen(piece_of_line))
    ELSE
     beginning_pos = request->row_qual[d1.seq].col_qual[col_qual].position
    ENDIF
    IF ((textlen(trim(request->row_qual[d1.seq].col_qual[col_qual].value)) > request->row_qual[d1.seq
    ].col_qual[col_qual].max_size))
     piece_of_line = substring(1,request->row_qual[d1.seq].col_qual[col_qual].max_size,request->
      row_qual[d1.seq].col_qual[col_qual].value)
    ELSE
     piece_of_line = substring(1,textlen(trim(request->row_qual[d1.seq].col_qual[col_qual].value)),
      request->row_qual[d1.seq].col_qual[col_qual].value)
    ENDIF
    chars_moved = movestring(piece_of_line,1,line_qual,beginning_pos,textlen(piece_of_line))
   ELSE
    literal_length = textlen(trim(request->row_qual[d1.seq].col_qual[col_qual].literal_display)),
    piece_of_line = substring(1,(request->row_qual[d1.seq].col_qual[col_qual].literal_size+
     literal_length),request->row_qual[d1.seq].col_qual[col_qual].literal_display)
    IF (piece_of_line > " ")
     beginning_pos = (((textlen(trim(line_qual))+ 1)+ request->row_qual[d1.seq].col_qual[col_qual].
     literal_size)+ literal_length), chars_moved = movestring(piece_of_line,1,line_qual,(textlen(trim
       (line_qual))+ 1),textlen(piece_of_line))
    ELSE
     beginning_pos = (((textlen(trim(line_qual))+ 1)+ request->row_qual[d1.seq].col_qual[col_qual].
     literal_size)+ literal_length)
    ENDIF
    IF ((textlen(trim(request->row_qual[d1.seq].col_qual[col_qual].value)) > request->row_qual[d1.seq
    ].col_qual[col_qual].max_size))
     piece_of_line = substring(1,request->row_qual[d1.seq].col_qual[col_qual].max_size,request->
      row_qual[d1.seq].col_qual[col_qual].value)
    ELSE
     piece_of_line = substring(1,textlen(trim(request->row_qual[d1.seq].col_qual[col_qual].value)),
      request->row_qual[d1.seq].col_qual[col_qual].value)
    ENDIF
    chars_moved = movestring(piece_of_line,1,line_qual,beginning_pos,textlen(piece_of_line))
   ENDIF
  FOOT  col_qual
   row + 0
  FOOT  line_num
   FOR (blank_line = (prev_line_num+ 1) TO (line_num - 1))
     building_signature_line = build(building_signature_line,char(13),char(10))
   ENDFOR
   IF (((textlen(trim(line_qual)) > 0) OR (validate(request->row_qual[d1.seq].suppress_line_ind,0)=0
   )) )
    IF (textlen(trim(building_signature_line)) > 0)
     building_signature_line = build(building_signature_line,line_qual,char(13),char(10))
    ELSE
     building_signature_line = build(line_qual,char(13),char(10))
    ENDIF
    line_qual = " "
   ENDIF
  FOOT REPORT
   reply->signature_line = building_signature_line
  WITH nocounter
 ;end select
END GO
