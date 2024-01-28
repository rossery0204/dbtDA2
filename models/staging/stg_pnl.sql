with union_tables as (
    select * from `rawbctc.pnl.*`
),

remove_null as (
    select distinct * from union_tables
    where Thoi_gian is not null 
    and Doanh_thu_thuan_ve_ban_hang_va_cung_cap_dich_vu is not null
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
    safe_cast(replace(Doanh_thu_thuan_ve_ban_hang_va_cung_cap_dich_vu,',','') as int64) as Revenue,
    safe_cast(replace(Loi_nhuan_gop_ve_ban_hang_va_cung_cap_dich_vu,',','') as int64) as Gross_profit,
    (ifnull(safe_cast(replace(Tong_loi_nhuan_ke_toan_truoc_thue,',','') as int64),0) + ifnull(safe_cast(replace(Trong_do__Chi_phi_lai_vay,',','') as int64),0)) as EBIT,
    safe_cast(replace(Trong_do__Chi_phi_lai_vay,',','') as int64) as Interest_cost,
    safe_cast(replace(Lai_co_ban_tren_co_phieu,',','') as int64) as EPS,
    safe_cast(replace(Loi_nhuan_sau_thue_cong_ty_me,',','') as int64) as PAT,
    safe_cast(replace(Tong_loi_nhuan_ke_toan_truoc_thue,',','') as int64) as Tong_loi_nhuan_ke_toan_truoc_thue
    from seperate_data
)

select distinct *
from select_data
where Revenue is not null
order by Cong_ty, Nam, Quy