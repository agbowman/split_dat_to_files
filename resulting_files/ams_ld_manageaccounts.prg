CREATE PROGRAM ams_ld_manageaccounts
 SET trace = rdbdebug
 SET trace = rdbbind
 RECORD import(
   1 t_index = i4
   1 records_per = i4
   1 qual_cnt = i4
   1 beg_index = i4
   1 end_index = i4
   1 length = i4
   1 qual[*]
     2 username = vc
 )
 RECORD users(
   1 person_cnt = i4
   1 qual[*]
     2 username = vc
 )
 RECORD export(
   1 qual_cnt = i4
   1 qual[*]
     2 username = vc
 )
 SET file_name = concat("ccluserdir:","securityresource.csv")
 SET import->records_per = 100
 FREE DEFINE rtl2
 DEFINE rtl2 file_name
 SELECT INTO "nl:"
  r.line
  FROM rtl2t r
  HEAD REPORT
   import->qual_cnt = 0, cnt = 0, header_cnt = 0
  DETAIL
   header_cnt = (header_cnt+ 1)
   IF (header_cnt > 1)
    cnt = (cnt+ 1), import->qual_cnt = (import->qual_cnt+ 1)
    IF (mod(import->qual_cnt,100)=1)
     stat = alterlist(import->qual,(import->qual_cnt+ 99))
    ENDIF
    import->beg_index = 1, import->end_index = 0
    FOR (i = 1 TO 1)
      import->end_index = findstring(",",r.line,import->beg_index), import->length = (import->
      end_index - import->beg_index)
      CASE (i)
       OF 1:
        import->qual[import->qual_cnt].username = concat(substring(import->beg_index,import->length,r
          .line),"#*")
      ENDCASE
      import->beg_index = (import->end_index+ 1)
    ENDFOR
   ENDIF
  FOOT REPORT
   IF (mod(import->qual_cnt,100) != 0)
    stat = alterlist(import->qual,import->qual_cnt)
   ENDIF
  WITH nocounter
 ;end select
 CALL echorecord(import)
 SET users->person_cnt = 0
 SELECT INTO "nl:"
  dseq = d.seq
  FROM (dummyt d  WITH seq = value(import->qual_cnt)),
   prsnl p
  PLAN (d)
   JOIN (p
   WHERE p.active_ind=1
    AND operator(p.username,"LIKE",notrim(patstring(import->qual[d.seq].username,1))))
  ORDER BY p.username
  HEAD REPORT
   null
  DETAIL
   users->person_cnt = (users->person_cnt+ 1)
   IF (mod(users->person_cnt,20)=1)
    stat = alterlist(users->qual,(users->person_cnt+ 19))
   ENDIF
   users->qual[users->person_cnt].username = p.username
  FOOT REPORT
   stat = alterlist(users->qual,users->person_cnt)
  WITH nocounter
 ;end select
 CALL echorecord(users)
 DECLARE found_flag = i2
 SELECT INTO "nl:"
  p.active_ind, p.person_id, p.username,
  ea.attribute_name, dseq = d.seq
  FROM (dummyt d  WITH seq = value(size(users->qual,5))),
   prsnl p,
   ea_user e,
   ea_user_attribute_reltn eu,
   ea_attribute ea
  PLAN (d)
   JOIN (p
   WHERE (p.username=users->qual[d.seq].username))
   JOIN (e
   WHERE p.username=e.username)
   JOIN (eu
   WHERE outerjoin(e.ea_user_id)=eu.ea_user_id)
   JOIN (ea
   WHERE outerjoin(eu.ea_attribute_id)=ea.ea_attribute_id)
  ORDER BY e.username
  HEAD REPORT
   cnt2 = 0
  HEAD e.username
   found_flag = 0
  DETAIL
   IF (ea.attribute_name="MANAGEACCOUNTS")
    found_flag = 1
   ENDIF
  FOOT  e.username
   IF (found_flag=0)
    cnt2 = (cnt2+ 1)
    IF (cnt2 > size(export->qual,5))
     stat = alterlist(export->qual,(cnt2+ 99))
    ENDIF
    export->qual[cnt2].username = e.username
   ENDIF
   found_flag = 0
  FOOT REPORT
   stat = alterlist(export->qual,cnt2), export->qual_cnt = cnt2
  WITH nocounter
 ;end select
 CALL echorecord(export)
 SELECT INTO "securityresource.csv"
  FROM (dummyt d  WITH seq = value(export->qual_cnt))
  HEAD REPORT
   tmp_str = build("Username          "), col 0, tmp_str,
   row + 1
  DETAIL
   tmp_str = build(export->qual[d.seq].username), col 0, tmp_str
   IF ((d.seq < export->qual_cnt))
    row + 1
   ENDIF
  WITH nocounter, format = variable, noformfeed,
   maxrow = 1, maxcol = 2500
 ;end select
END GO
