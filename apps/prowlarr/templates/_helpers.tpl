{{- define "prowlarr.name" -}}
prowlarr
{{- end -}}

{{- define "prowlarr.fullname" -}}
{{ include "prowlarr.name" . }}
{{- end -}}
