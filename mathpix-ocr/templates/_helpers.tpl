{{- /*
Create a “full name” for every K8s resource in this chart, truncated to 63 chars.
*/ -}}
{{- define "mathpix-ocr.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end -}}
