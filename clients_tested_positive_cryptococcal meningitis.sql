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
     i.identifier as 'ccc-no',
    m.person_id,
    m.location_id,
    m.clinic,
    m.cur_arv_meds,
    m.arv_start_date,
    fhs.cd4_1,
    fhs.cd4_1_date,
	fl.serum_crag,
    fl.test_datetime as 'lab_summary_test_date',
    c.RESULT,
    c.TEST_DATE,
    m.age,
    m.gender,
    case
      when m.gender = 'M' AND m.age <= 14 then 1
      ELSE NULL
    end as 'male_0_to_14',
    case
      when m.gender = 'M' AND m.age >= 15 then 1
      ELSE NULL
    end as 'male_15_and_above',
    case
      when m.gender = 'F' AND m.age <= 14 then 1
      ELSE NULL
    end as 'female_0_to_14',
    case
      when m.gender = 'F' AND m.age >= 15 then 1
      ELSE NULL
    end as 'female_15_and_above'
FROM
    etl.hiv_monthly_report_dataset_frozen m
        LEFT JOIN
    etl.flat_hiv_summary_v15b fhs ON (fhs.encounter_id = m.encounter_id)
    left join etl.flat_labs_and_imaging fl on (fl.person_id = m.person_id AND fl.serum_crag IS NOT NULL)
    left join etl.lab_crag_test c on (c.person_id = m.person_id)
     left join amrs.patient_identifier i on (i.patient_id = m.person_id AND i.identifier_type = 28 and i.voided = 0)
WHERE
    m.on_art_this_month = 1
        AND m.location_id = @locationId
        AND (fl.serum_crag IS NOT NULL OR c.RESULT IS NOT NULL)
        AND (fl.serum_crag = 664 or  c.RESULT = 'POS')
        AND m.endDate >= @startDate
        AND m.endDate <= @endDate
        group by m.person_id) `b`
GROUP BY b.location_id