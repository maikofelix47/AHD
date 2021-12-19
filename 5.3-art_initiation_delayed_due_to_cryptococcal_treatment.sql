set @startDate:= '2021-11-30';
set @endDate:= '2021-11-30';
set @locationId:= 1;
SELECT 
    'Number of client whose ART initiation was delayed due to cryptococcal meningitis treatment' as Indiator,
    b.clinic,
    b.location_id,
    COUNT(b.male_0_to_14) AS 'male_0_to_14',
    COUNT(b.male_15_and_above) AS 'male_15_and_above',
    COUNT(b.female_0_to_14) AS 'female_0_to_14',
    COUNT(b.female_15_and_above) AS 'female_15_and_above',
    COUNT(b.person_id) AS 'total'
FROM
    (SELECT 
        i.identifier AS 'ccc no',
            m.person_id,
            m.location_id,
            m.clinic,
            r.obs_datetime,
            r.arv_delay_reasons_text as 'arv_not_started_reason',
            m.cur_arv_meds,
            m.arv_start_date,
            m.age,
            m.gender,
            CASE
                WHEN m.gender = 'M' AND m.age <= 14 THEN 1
                ELSE NULL
            END AS 'male_0_to_14',
            CASE
                WHEN m.gender = 'M' AND m.age >= 15 THEN 1
                ELSE NULL
            END AS 'male_15_and_above',
            CASE
                WHEN m.gender = 'F' AND m.age <= 14 THEN 1
                ELSE NULL
            END AS 'female_0_to_14',
            CASE
                WHEN m.gender = 'F' AND m.age >= 15 THEN 1
                ELSE NULL
            END AS 'female_15_and_above'
    FROM
        etl.hiv_monthly_report_dataset_frozen m
       join etl.flat_arv_delay_reasons_text r on (r.person_id = m.person_id)
    LEFT JOIN amrs.patient_identifier i ON (i.patient_id = m.person_id
        AND i.identifier_type = 28
        AND i.voided = 0)
    WHERE
        m.status = 'active'
            AND m.location_id = @locationId
            AND r.concept_id = 1505
            AND r.value_coded = 5622
            AND DATE_FORMAT(r.obs_datetime, '%Y-%m') = DATE_FORMAT(m.endDate, '%Y-%m')
            AND m.endDate >= @startDate
            AND m.endDate <= @endDate
    GROUP BY m.person_id) `b`
GROUP BY b.location_id