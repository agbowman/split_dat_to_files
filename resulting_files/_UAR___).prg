  WHERE ((r.line="*DECLARE *UAR_*") OR (r.line="*CREATE PROGRAM*"))
  WITH nocounter
 ;end select
 SET stat = remove(tmpname)
END GO
