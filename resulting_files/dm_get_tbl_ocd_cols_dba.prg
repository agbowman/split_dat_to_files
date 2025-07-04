CREATE PROGRAM dm_get_tbl_ocd_cols:dba
 RECORD reply(
   1 qual[*]
     2 column_name = vc
     2 col_status = c1
   1 count = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET tname = fillstring(40," ")
 SET reply->status_data.status = "F"
 SET onumber = request->ocd_number
 SET tname = request->table_name
 SET reply->count = 0
 SET sch_version = request->rev_number
 SET ocd_flag = 0
 FREE SET r1
 RECORD r1(
   1 rev_date = dq8
   1 ocd_date = dq8
 )
 SET r1->rev_date = 0
 SET r1->ocd_date = 0
 SELECT INTO "nl:"
  b.schema_date
  FROM dm_schema_version b
  WHERE b.schema_version=sch_version
  DETAIL
   r1->rev_date = b.schema_date
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  b.schema_date
  FROM dm_afd_tables b,
   dm_alpha_features a
  WHERE b.table_name=tname
   AND b.alpha_feature_nbr != onumber
   AND a.alpha_feature_nbr=b.alpha_feature_nbr
   AND a.rev_number=sch_version
  DETAIL
   IF ((b.schema_date > r1->rev_date))
    r1->rev_date = b.schema_date
   ENDIF
   ocd_flag = 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  b.schema_date
  FROM dm_afd_tables b
  WHERE b.alpha_feature_nbr=onumber
   AND b.table_name=tname
  DETAIL
   IF ((b.schema_date > r1->ocd_date))
    r1->ocd_date = b.schema_date
   ENDIF
  WITH nocounter
 ;end select
 IF (ocd_flag=1)
  SELECT DISTINCT INTO "nl:"
   d.column_name
   FROM dm_afd_columns d,
    dm_afd_tables a
   WHERE a.table_name=tname
    AND datetimediff(a.schema_date,cnvtdatetime(r1->rev_date))=0
    AND d.alpha_feature_nbr=a.alpha_feature_nbr
    AND d.table_name=a.table_name
   ORDER BY d.column_name
   DETAIL
    reply->count = (reply->count+ 1), stat = alterlist(reply->qual,reply->count), reply->qual[reply->
    count].column_name = d.column_name,
    reply->qual[reply->count].col_status = "N"
   WITH nocounter
  ;end select
 ELSE
  SELECT DISTINCT INTO "nl:"
   d.column_name
   FROM dm_columns d
   WHERE d.table_name=tname
    AND datetimediff(d.schema_date,cnvtdatetime(r1->rev_date))=0
   ORDER BY d.column_name
   DETAIL
    reply->count = (reply->count+ 1), stat = alterlist(reply->qual,reply->count), reply->qual[reply->
    count].column_name = d.column_name,
    reply->qual[reply->count].col_status = "N"
   WITH nocounter
  ;end select
 ENDIF
 IF ((r1->ocd_date > r1->rev_date))
  IF (ocd_flag=1)
   SELECT DISTINCT INTO "nl:"
    a.column_name
    FROM dm_afd_columns a,
     dm_afd_tables b
    WHERE b.alpha_feature_nbr=onumber
     AND b.table_name=tname
     AND datetimediff(b.schema_date,cnvtdatetime(r1->ocd_date))=0
     AND a.alpha_feature_nbr=b.alpha_feature_nbr
     AND a.table_name=b.table_name
     AND  NOT ( EXISTS (
    (SELECT
     "X"
     FROM dm_afd_columns d,
      dm_afd_tables c
     WHERE c.table_name=tname
      AND datetimediff(c.schema_date,cnvtdatetime(r1->rev_date))=0
      AND c.alpha_feature_nbr != onumber
      AND d.table_name=c.table_name
      AND d.column_name=a.column_name
      AND d.alpha_feature_nbr=c.alpha_feature_nbr)))
    ORDER BY a.column_name
    DETAIL
     reply->count = (reply->count+ 1), stat = alterlist(reply->qual,reply->count), reply->qual[reply
     ->count].column_name = a.column_name,
     reply->qual[reply->count].col_status = "Y"
    WITH nocounter
   ;end select
  ELSE
   SELECT DISTINCT INTO "nl:"
    a.column_name
    FROM dm_afd_columns a,
     dm_afd_tables b
    WHERE b.alpha_feature_nbr=onumber
     AND b.table_name=tname
     AND datetimediff(b.schema_date,cnvtdatetime(r1->ocd_date))=0
     AND a.table_name=b.table_name
     AND a.alpha_feature_nbr=b.alpha_feature_nbr
     AND  NOT ( EXISTS (
    (SELECT
     "X"
     FROM dm_columns d
     WHERE d.table_name=tname
      AND datetimediff(d.schema_date,cnvtdatetime(r1->rev_date))=0
      AND d.column_name=a.column_name)))
    ORDER BY a.column_name
    DETAIL
     reply->count = (reply->count+ 1), stat = alterlist(reply->qual,reply->count), reply->qual[reply
     ->count].column_name = a.column_name,
     reply->qual[reply->count].col_status = "Y"
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
END GO
