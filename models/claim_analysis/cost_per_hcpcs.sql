select 
    hcpcs_code,
    rendering_npi,
    year(claim_start_date) as claim_year,
    count(claims.claim_id) as claim_count,
    sum(paid_amount) as paid_amount,
    sum(charge_amount) as charge_amount,
    concat('$',round(sum(paid_amount)/count(claims.claim_id),2)) as paid_amount_per_claim

from
    {{ref('medical_claim')}} as claims
    inner join 
    (select
       claim_id

    from
        (select max(claim_line_number) as max_line, claim_id
        from  {{ref('medical_claim')}}
        group by claim_id)
    where max_line =1) as one_line_claims on one_line_claims.claim_id = claims.claim_id
group by hcpcs_code, rendering_npi, claim_year
order by claim_count desc