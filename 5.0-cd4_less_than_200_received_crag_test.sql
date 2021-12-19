set @startDate:= '2021-11-30';
set @endDate:= '2021-11-30';
set @locationId:= 1;
SELECT 
    'Number of clients CD4 < 200 who received a Crag Test for cryptococcal meningitis' AS Indicator,
    b.clinic,
    b.location_id,
    COUNT(b.male_0_to_14) AS 'male_0_to_14',
    COUNT(b.male_15_and_above) AS 'male_15_and_above',
    COUNT(b.female_0_to_14) AS 'female_0_to_14',
    COUNT(b.female_15_and_above) AS 'female_15_and_above',
    COUNT(b.person_id) AS 'total'
FROM
    (SELECT 
        i.identifier AS 'ccc-no',
            m.person_id,
            m.location_id,
            m.clinic,
            m.cur_arv_meds,
            m.arv_start_date,
            fhs.cd4_1,
            fhs.cd4_1_date,
            fl.serum_crag,
            fl.test_datetime AS 'lab_summary_test_date',
            c.RESULT,
            c.TEST_DATE,
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
    LEFT JOIN etl.flat_hiv_summary_v15b fhs ON (fhs.encounter_id = m.encounter_id)
    LEFT JOIN etl.flat_labs_and_imaging fl ON (fl.person_id = m.person_id
        AND fl.serum_crag IS NOT NULL)
    LEFT JOIN etl.lab_crag_test c ON (c.person_id = m.person_id)
    LEFT JOIN amrs.patient_identifier i ON (i.patient_id = m.person_id
        AND i.identifier_type = 28
        AND i.voided = 0)
    WHERE
        m.on_art_this_month = 1
            AND m.location_id = @locationId
            AND fhs.cd4_1 < 200
            AND (fl.serum_crag IS NOT NULL
            OR c.RESULT IS NOT NULL)
            AND (fl.test_datetime >= DATE_FORMAT(@startDate, '%Y-%m-1')
            OR c.TEST_DATE >= DATE_FORMAT(@startDate, '%Y-%m-1'))
            AND m.endDate >= @startDate
            AND m.endDate <= @endDate
    GROUP BY m.person_id) `b`
GROUP BY b.location_id