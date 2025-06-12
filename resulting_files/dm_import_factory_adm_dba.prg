CREATE PROGRAM dm_import_factory_adm:dba
 SET feature_found = "N"
 SET numelts = size(requestin->list_0,5)
 FOR (lvar = 1 TO numelts)
   SELECT INTO "nl:"
    a.feature_status
    FROM dm_features a
    PLAN (a
     WHERE a.feature_number=cnvtint(requestin->list_0[lvar].feature_number))
    DETAIL
     feature_status = a.feature_status
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET feature_found = "N"
    INSERT  FROM dm_features a
     SET a.feature_number = cnvtint(requestin->list_0[lvar].feature_number), a.feature_status =
      requestin->list_0[lvar].feature_status, a.description = substring(1,40,requestin->list_0[lvar].
       feature_description),
      a.created_by = "dm_import_factory_adm", a.create_dt_tm = cnvtdatetime(curdate,curtime3)
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET feature_status = "F"
    ELSE
     SET feature_status = "S"
    ENDIF
   ELSE
    SET feature_found = "Y"
    UPDATE  FROM dm_features a
     SET a.feature_status = requestin->list_0[lvar].feature_status, a.description = substring(1,40,
       requestin->list_0[lvar].feature_description)
     WHERE a.feature_number=cnvtint(requestin->list_0[lvar].feature_number)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET feature_status = "F"
    ELSE
     SET feature_status = "S"
    ENDIF
   ENDIF
   COMMIT
   SELECT INTO "dm_import_factory_adm.log"
    d.seq
    FROM (dummyt d  WITH seq = 1)
    DETAIL
     row + 1, col 0, "Feature No: ",
     requestin->list_0[lvar].feature_number
     IF (feature_found="N")
      col 62, "ADD"
     ELSE
      col 62, "UPDATE"
     ENDIF
     IF (feature_status="S")
      " SUCCESS "
     ELSE
      " FAILED  "
     ENDIF
     curdate"dd-mmm-yyyy;;d", "-", curtime"hh:mm;;m"
     IF ((reqinfo->commit_ind=3))
      row + 2, col 0, "**** IMPORT TERMINATED BECAUSE OF DATA ERROR **** "
     ENDIF
    WITH nocounter, append, format = variable,
     noformfeed, maxcol = 200, maxrow = 1
   ;end select
   SET person_id = 0.0
 ENDFOR
#exit_pgm
END GO
