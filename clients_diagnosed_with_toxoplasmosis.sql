set @startDate:= '2021-11-30';
set @endDate:= '2021-11-30';
set @locationId:= 1;
SELECT 
    b.clinic,
    b.location_id,
    COUNT(b.male_0_to_14) AS 'male_0_to_14',
    COUNT(b.male_0_to_14) AS 'male_15_and_above',
    COUNT(b.female_0_to_14) AS 'female_0_to_14',
    COUNT(b.female_15_and_above) AS 'female_15_and_above'
FROM
    (SELECT 
        i.identifier AS 'ccc-no',
            m.person_id,
            m.location_id,
            m.clinic,
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
    JOIN amrs.obs o ON (m.person_id = o.person_id
        AND o.concept_id = 6048
        AND voided = 0)
    LEFT JOIN amrs.encounter e ON (e.encounter_id = o.encounter_id)
    LEFT JOIN amrs.patient_identifier i ON (i.patient_id = m.person_id
        AND i.identifier_type = 28
        AND i.voided = 0)
    WHERE
        o.value_coded IN (990 , 2129)
            AND m.on_art_this_month = 1
            AND m.location_id = @locationId
            AND DATE_FORMAT(o.obs_datetime, '%Y-%m') = DATE_FORMAT(m.endDate, '%Y-%m')
            AND m.endDate >= @startDate
            AND m.endDate <= @endDate
    GROUP BY o.person_id) `b`
GROUP BY b.location_id