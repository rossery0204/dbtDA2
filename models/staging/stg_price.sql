with union_tables as (
    select * from `rawbctc.price.*`
),

change_type as (
  select 
    maCK,
    case when instr(ngay,'/') >= 1 then REGEXP_SUBSTR(ngay, '[^/]+', 1, 1) else null end ngay,
    case when instr(ngay,'/') >= 1 then REGEXP_SUBSTR(ngay, '[^/]+', 1, 2) else null end thang,
    case when instr(ngay,'/') >= 1 then REGEXP_SUBSTR(ngay, '[^/]+', 1, 3) else null end nam,
    safe_cast(gia_dong_nghinVND as decimal) as gia_dong,
    safe_cast(gia_dieu_chinh_nghinVND as decimal) as gia_dieu_chinh,
    safe_cast(replace(GDKL_khoiluong,',','') as decimal) as khoi_luong_giao_dich
  from union_tables
),

add_date as (
  select 
    parse_date('%Y-%m-%d', concat(nam,'-',thang,'-',ngay)) as thoi_gian,
    *
  from change_type
),

add_quarter as (
  select 
      *,
     format_date('%Q', date(thoi_gian)) as quy
  from add_date
),

remove_null as (
    select distinct *,
    --     parse_date('%Y-%m-%d', concat(nam,'-',
    --   (case
    --     when quy = '1' then '01' 
    --     when quy = '2' then '04'
    --     when quy = '3' then '07'
    --     when quy = '4' then '10'
    --     else null end),'-','01')) as Thoi_gian_quy,
    from add_quarter
    where thoi_gian is not null
    and maCK is not null 
)

select distinct * from remove_null
order by maCK, thoi_gian