# SCS Errors

The following errors can show up in the failed error messages.

## error codes

| Error code                   | Meaning                                                                                                                                |
|------------------------------|----------------------------------------------------------------------------------------------------------------------------------------|
| `unknown_error`              | An error that is not yet categorized                                                                                                   |
| `filesystem_error`           | A filesystem operation has failed, or an invalid filesystem path was used                                                              |
| `workflow_timeout`           | A workflow (i.e.: processing of a file) took too long to complete and was aborted.                                                     |
| `max_retries_exceeded`       | A RabbitMQ message handled by consume mode was redelivered too many times                                                              |
| `duplicate_message`          | A RabbitMQ message with the same parameters as one currently being processed was detected and dropped.                                 |
| `skipped_pdf`                | A document that was previously processed was marked as failed. (avoided using the `--disable_skipped_as_failure` CLI flag)             |
| `unsupported_file_type`      | The detected type for a file is not supported.                                                                                         |
| `ebook_conversion_failed`    | The conversion from an e-book to PDF failed.                                                                                           |
| `office_conversion_failed`   | The conversion from an office document to PDF failed.                                                                                  |
| `tiff_conversion_error`      | The conversion from TIFF to PDF failed.                                                                                                |
| `tiff_page_size_error`       | A TIFF file exceeds the maximum allowed size.                                                                                          |
| `tiff_page_limit_exceeded`   | A TIFF has a number of pages that exceeds the maximum allowed.                                                                         |
| `corrupt_pdf_file`           | A PDF is corrupt, empty, or otherwise incompatible with the PDF utilities and libraries used by SCS.                                   |
| `split_pdf_error`            | A PDF file could not be split into multiple images.                                                                                    |
| `split_pdf_timeout error`    | A PDF split operation took longer than the maximum amount of time allowed.                                                             |
| `pdf_page_limit_exceeded`    | A PDF exceeded the maximum number of pages allowed.                                                                                    |
| `ocr_error`                  | The OCR component threw an error. See the [Mathpix API docs](https://docs.mathpix.com/#error-id-strings) for more information for more |
| `invalid_ocr_endpoint`       | An OCR endpoint resulting in a workflow with invalid step transitions.                                                                 |
| `invalid_page_number`        | While processing a page, the page number could not be retrieved.                                                                       |
| `corrupt_image`              | An image could not be read.                                                                                                            |
| `invalid_ocr_parameters`     | When initializing the OCR component, the parameters used were detected as invalid.                                                     |
| `markdown_conversion_failed` | The conversion to the Mathpix Markdown (MMD) format failed.                                                                            |
| `page_aggregation_error`     | A page was processed but its results could not be aggregated.                                                                          |