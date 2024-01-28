with union_tables as (
    select * from `rawbctc.cashflow.*`
),

remove_null as (
    select distinct * from union_tables
    where Thoi_gian is not null 
    and Tien_va_tuong_duong_tien_cuoi_ky is not null
),

seperate_data as (
    select
    case when instr(Thoi_gian,'_') >= 1 then REGEXP_SUBSTR(Thoi_gian, '^Quy+([0-9])', 1, 1) else null end Quy,
    case when instr(Thoi_gian,'_') >= 1 then REGEXP_SUBSTR(Thoi_gian, '[^_]+', 1, 2) else null end Nam,
    case when instr(Thoi_gian,'_') >= 1 then REGEXP_SUBSTR(Thoi_gian, '[^_]+', 1, 3) else null end Cong_ty,
    *
from remove_null
),

select_data as (
    select
    Cong_ty,
    parse_date('%Y-%m-%d', concat(Nam,'-',
      (case
        when Quy = '1' then '01' 
        when Quy = '2' then '04'
        when Quy = '3' then '07'
        when Quy = '4' then '10'
        else null end),'-','01')) as Thoi_gian,
    Quy,
    Nam,
    safe_cast(replace(Luu_chuyen_tien_thuan_tu_hoat_dong_kinh_doanh,',','') as int64) as OCF,
    safe_cast(replace(Luu_chuyen_tien_thuan_tu_hoat_dong_dau_tu,',','') as int64) as ICF,
    safe_cast(replace(Luu_chuyen_tien_thuan_tu_hoat_dong_tai_chinh,',','') as int64) as CFF,
    safe_cast(replace(Tien_va_tuong_duong_tien_cuoi_ky,',','') as int64) as Tien_cuoi_ky,
    (ifnull(safe_cast(replace(Tien_chi_de_mua_sam_xay_dung_TSCD_va_cac_tai_san_dai_han_khac,',','') as int64),0)  
    + ifnull(safe_cast(replace(Tien_thu_tu_thanh_ly_nhuong_ban_TSCD_va_cac_tai_san_dai_han_khac,',','') as int64),0))  as CAPEX
    from seperate_data
)

select distinct
    Cong_ty, Nam, Quy, Thoi_gian,
    OCF, 
    OCF + CAPEX as FCF, 
    --(OCF+CAPEX)/OCF as FCFtoOCF, 
    ICF,
    CFF,
    CAPEX,
    --OCF/pnl.Revenue  as OCFM,
    Tien_cuoi_ky
from select_data
where OCF is not null
order by Cong_ty, Nam, Quy