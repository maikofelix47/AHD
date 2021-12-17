set @startDate:= '2021-11-30';
set @endDate:= '2021-11-30';
set @locationId:= 11;
SELECT
b.*,
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
    m.arv_start_date,
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
    left join amrs.patient_identifier i on (i.patient_id = m.person_id AND i.identifier_type = 28 and i.voided = 0)
WHERE
    m.started_art_this_month = 1
        AND m.location_id = @locationId
        AND m.endDate >= @startDate
        AND m.endDate <= @endDate
        group by m.person_id
        ) `b`
        group by b.location_id