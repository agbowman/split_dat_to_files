CREATE PROGRAM cs_commit_client_report:dba
 FOR (x = 1 TO request->t01commit_qual)
   UPDATE  FROM charge c
    SET c.posted_cd = 999, c.posted_dt_tm = cnvtdatetime(concat(format(curdate,"DD-MMM-YYYY;;D"),
       " 23:59:59.99"))
    WHERE (c.charge_item_id=request->t01commit[x].charge_item_id)
    WITH nocounter
   ;end update
 ENDFOR
 COMMIT
END GO
