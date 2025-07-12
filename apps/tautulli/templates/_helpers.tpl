{{- define "tautulli.fullname" -}}
{{- printf "%s-%s" .Release.Name "tautulli" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
