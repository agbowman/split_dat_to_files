CREATE PROGRAM afc_del_dup_pm_rpt_field:dba
 RECORD dup_fld(
   1 dups[*]
     2 fn = vc
     2 fd = vc
     2 tn = vc
     2 rt = vc
 )
 SET count1 = 0
 SELECT INTO "nl:"
  f.field_name, f.field_display, f.table_name,
  f.field_report_type, count(*)
  FROM pm_rpt_field f
  WHERE f.field_report_type="A"
  GROUP BY f.field_name, f.field_display, f.table_name,
   f.field_report_type
  HAVING count(*) > 1
  DETAIL
   count1 = (count1+ 1), stat = alterlist(dup_fld->dups,count1), dup_fld->dups[count1].fn = f
   .field_name,
   dup_fld->dups[count1].fd = f.field_display, dup_fld->dups[count1].tn = f.table_name, dup_fld->
   dups[count1].rt = f.field_report_type,
   CALL echo(dup_fld->dups[count1].fn)
  WITH nocounter
 ;end select
 RECORD dup_key(
   1 dups[*]
     2 field_id = f8
     2 save_field_id = f8
 )
 SET last_field_id = 0.0
 SET dup_cnt = 0
 SELECT INTO "nl:"
  d1.seq, f.field_id, f.field_name,
  f.field_display, f.table_name, f.field_report_type
  FROM pm_rpt_field f,
   (dummyt d1  WITH seq = value(size(dup_fld->dups,5)))
  PLAN (d1)
   JOIN (f
   WHERE (f.field_name=dup_fld->dups[d1.seq].fn)
    AND (f.field_display=dup_fld->dups[d1.seq].fd)
    AND (f.table_name=dup_fld->dups[d1.seq].tn)
    AND (f.field_report_type=dup_fld->dups[d1.seq].rt))
  ORDER BY d1.seq
  HEAD d1.seq
   last_field_id = f.field_id
  DETAIL
   IF (last_field_id != f.field_id)
    dup_cnt = (dup_cnt+ 1), stat = alterlist(dup_key->dups,dup_cnt), dup_key->dups[dup_cnt].field_id
     = f.field_id,
    dup_key->dups[dup_cnt].save_field_id = last_field_id,
    CALL echo(build("dup: ",f.field_id," save: ",last_field_id))
   ENDIF
  WITH nocounter
 ;end select
 IF (dup_cnt=0)
  CALL echo("No duplicates found.")
  GO TO end_prog
 ELSE
  CALL echo(build(dup_cnt," duplicates found."))
 ENDIF
 UPDATE  FROM pm_rpt_header p,
   (dummyt d1  WITH seq = value(size(dup_key->dups,5)))
  SET p.field_id = dup_key->dups[d1.seq].save_field_id
  PLAN (d1)
   JOIN (p
   WHERE (p.field_id=dup_key->dups[d1.seq].field_id))
  WITH nocounter
 ;end update
 UPDATE  FROM pm_rpt_filter p,
   (dummyt d1  WITH seq = value(size(dup_key->dups,5)))
  SET p.field_id = dup_key->dups[d1.seq].save_field_id
  PLAN (d1)
   JOIN (p
   WHERE (p.field_id=dup_key->dups[d1.seq].field_id))
  WITH nocounter
 ;end update
 UPDATE  FROM pm_rpt_group p,
   (dummyt d1  WITH seq = value(size(dup_key->dups,5)))
  SET p.field_id = dup_key->dups[d1.seq].save_field_id
  PLAN (d1)
   JOIN (p
   WHERE (p.field_id=dup_key->dups[d1.seq].field_id))
  WITH nocounter
 ;end update
 UPDATE  FROM pm_rpt_order p,
   (dummyt d1  WITH seq = value(size(dup_key->dups,5)))
  SET p.field_id = dup_key->dups[d1.seq].save_field_id
  PLAN (d1)
   JOIN (p
   WHERE (p.field_id=dup_key->dups[d1.seq].field_id))
  WITH nocounter
 ;end update
 DELETE  FROM pm_rpt_field p,
   (dummyt d1  WITH seq = value(size(dup_key->dups,5)))
  SET p.seq = 1
  PLAN (d1)
   JOIN (p
   WHERE (p.field_id=dup_key->dups[d1.seq].field_id))
  WITH nocounter
 ;end delete
#end_prog
 COMMIT
 CALL echo("Done.")
END GO
