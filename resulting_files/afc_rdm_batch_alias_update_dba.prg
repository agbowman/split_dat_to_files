CREATE PROGRAM afc_rdm_batch_alias_update:dba
 SET afc_rdm_batch_alias_update = "78042.FT.000"
 DECLARE parsestr = c255
 DECLARE b_start = f8
 DECLARE b_end = f8
 SET b_start = cnvtreal( $1)
 SET b_end = cnvtreal( $2)
 IF (currdb="ORACLE")
  CALL echo(build("Updating Batch:",batch_start,"--",batch_end))
  FREE SET parsestr
  SET parsestr = build("rdb update bce_event_log b set b.batch_alias_key = ",
   "upper(translate(b.batch_alias, concat(",
   "concat('A~` !@#$%^&*()_-+=[]{}|\:;<,>.?/',chr(34)),chr(39)), 'A')) ",
   "where b.bce_event_log_id >= ",cnvtstring(b_start),
   " and b.bce_event_log_id <= ",cnvtstring(b_end)," and trim(' ' from b.batch_alias) is not NULL",
   " go")
  CALL parser(parsestr)
 ELSE
  CALL echo(build("Updating Batch:",batch_start,"--",batch_end))
  FREE RECORD bce_list
  RECORD bce_list(
    1 qual[*]
      2 bce_event_log_id = f8
      2 batch_alias = vc
  )
  SELECT INTO "nl:"
   FROM bce_event_log b
   WHERE b.batch_alias != " "
    AND b.bce_event_log_id >= b_start
    AND b.bce_event_log_id <= b_end
   HEAD REPORT
    counter = 0
   DETAIL
    counter = (counter+ 1)
    IF (mod(counter,50)=1)
     stat = alterlist(bce_list->qual,(counter+ 49))
    ENDIF
    bce_list->qual[counter].bce_event_log_id = b.bce_event_log_id, bce_list->qual[counter].
    batch_alias = cnvtupper(cnvtalphanum(b.batch_alias))
   FOOT REPORT
    stat = alterlist(bce_list->qual,counter)
   WITH nocounter
  ;end select
  UPDATE  FROM (dummyt d  WITH seq = size(bce_list->qual,5)),
    bce_event_log b
   SET b.batch_alias_key = bce_list->qual[d.seq].batch_alias
   PLAN (d)
    JOIN (b
    WHERE (b.bce_event_log_id=bce_list->qual[d.seq].bce_event_log_id))
  ;end update
 ENDIF
END GO
