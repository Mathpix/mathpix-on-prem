# SCS Page Tracking

If required, page tracking can be enabled by specifying the following arguments when starting the SCS consumer:

```
--influxdb_org ...
--influxdb_host ...
--influxdb_token ...
--influxdb_database ...
```

This configuration enables the SCS consumer servers to send anonymized page counts and timing information to an InfluxDB instance.

For customers using page-based accounting, we will provide the necessary values for these parameters.

## What Data Is Sent

We send data for every **image** processed, which includes the following fields:

```
image_id, job_id, name, ocr_time, pdf_id, segmentation_time, spell_check_time, time
```

Additionally, for every **PDF** processed, we send:

```
job_id, name, num_pages, pdf_id, split_time, time
```

> **Note:**  
> - The `name` field represents the customer name.  
> - The values for `image_id`, `job_id`, and `pdf_id` are hashed, ensuring that we cannot see the actual file names or job identifiers.

## Security

To safeguard sensitive information, identifiers such as image_id, job_id, and pdf_id are hashed using SHA-256 combined with a secret salt. This ensures the resulting hashes are not predictable and cannot be linked back to the original values. The original data remains unrecoverable, while the consistent hashing allows for internal tracking and analysis. 

The page tracking data is transmitted to an InfluxDB database, which is managed by InfluxData (https://www.influxdata.com/security/) who adheres to strong security and compliance standards such as SOC2 type 2.
