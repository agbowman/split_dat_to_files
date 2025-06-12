CREATE PROGRAM cls_example1
 SET ordmnem = uar_get_code_by("DISPLAYKEY",200,"URINALYSIS")
 SELECT INTO  $1
  ordernum = o.order_id"#######;p0", orderstat = uar_get_code_display(o.order_status_cd), origination
   = o.orig_order_dt_tm"mm/dd/yyyy hh:mm:ss ;;d",
  display = substring(1,100,o.order_detail_display_line)
  FROM orders o
  WHERE o.catalog_cd=ordmnem
  ORDER BY o.orig_order_dt_tm DESC
 ;end select
END GO
