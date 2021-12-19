set @startDate:= '2021-11-30';
set @endDate:= '2021-11-30';
set @locationId:= 11;
SELECT 
    'Number of clients Treated for cryptococcal meningitis' AS 'Idicator',
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
            TIMESTAMPDIFF(MONTH, c.cryptococcal_tx_start_date, m.endDate) AS 'months_on_cryptococcal_treatment',
            c.cryptococcal_tx_start_date,
            c.cryptococcal_tx_end_date,
            m.cur_arv_meds,
            m.arv_start_date,
            m.age,
            m.gender,
            fhs.cd4_1,
            fhs.cd4_1_date,
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
    LEFT JOIN amrs.patient_identifier i ON (i.patient_id = m.person_id
        AND i.identifier_type = 28
        AND i.voided = 0)
    LEFT JOIN etl.flat_cryptococcal_summary c ON (c.person_id = m.person_id
        AND m.encounter_id = c.encounter_id)
    LEFT JOIN etl.flat_hiv_summary_v15b fhs ON (fhs.person_id = m.person_id
        AND fhs.encounter_id = m.encounter_id)
    WHERE
        m.on_art_this_month = 1
            AND c.cryptococcal_tx_start_date >= DATE_FORMAT(@startDate, '%Y-%m-1')
            AND c.on_cryptococcal_tx = 1
            AND m.location_id = @locationId
            AND m.endDate >= @startDate
            AND m.endDate <= @endDate
    GROUP BY m.person_id) `b`
GROUP BY b.location_id