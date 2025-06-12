CREATE PROGRAM cps_fix_string_index:dba
 RECORD upd_list(
   1 qual_knt = i4
   1 qual[*]
     2 id = f8
 )
 SET true = 1
 SET false = 0
 SET continue = true
 SET knt = 0
 SET current_id = 0.0
 SET last_id = 0.0
 WHILE (continue=true)
   SELECT INTO "nl:"
    n.normalized_string_id
    FROM normalized_string_index n
    PLAN (n
     WHERE n.normalized_string_id > current_id)
    ORDER BY n.normalized_string_id
    HEAD REPORT
     knt = 0, stat = alterlist(upd_list->qual,100)
    DETAIL
     knt = (knt+ 1)
     IF (mod(knt,100)=1
      AND knt != 1)
      stat = alterlist(upd_list->qual,(knt+ 99))
     ENDIF
     upd_list->qual[knt].id = n.normalized_string_id
    FOOT REPORT
     current_id = n.normalized_string_id, upd_list->qual_knt = knt, stat = alterlist(upd_list->qual,
      knt)
    WITH nocounter, maxqual(n,100)
   ;end select
   IF (curqual < 1)
    GO TO end_program
   ENDIF
   UPDATE  FROM normalized_string_index n,
     (dummyt d  WITH seq = value(upd_list->qual_knt))
    SET d.seq = 1, n.normalized_string = concat(trim(n.normalized_string)," ")
    PLAN (d
     WHERE d.seq > 0)
     JOIN (n
     WHERE (n.normalized_string_id=upd_list->qual[d.seq].id))
   ;end update
   COMMIT
   IF ((upd_list->qual_knt < 100))
    SET continue = false
   ENDIF
 ENDWHILE
 GO TO end_program
#end_program
END GO
